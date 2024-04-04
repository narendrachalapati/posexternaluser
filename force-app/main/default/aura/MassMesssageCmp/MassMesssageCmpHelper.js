({
    MAX_FILE_SIZE: 2097152, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000, //Chunk Max size 750Kb 

    logConsoleDebug: function (debugString, type) {
        // component.logConsoleDebug(s, 'log');
        var enableConsoleDebug = true;
        if (enableConsoleDebug) {
            if (type == 'table') {
                console.table(debugString);
            } else {
                console.log(debugString);
            }
        }
    },

    openConfirm: function (component, event) {
        var resultofclick;
        var sobjectlist = component.get('v.selectedlistofrecords');
        var contacttemp = component.get('v.selectedlistofrecords');
        var contactcount = contacttemp.length;
        var messagefillin = component.get('v.currentMessage');
        if (messagefillin !== "" && messagefillin !== null && sobjectlist.length !== 0) {
            this.LightningConfirm.open({

                message: 'Selected contacts are : ' + contactcount,
                theme: 'warning',
                label: 'Please Confirm to send',
            }).then((result) => {
                // result is true if clicked "OK"
                // result is false if clicked "Cancel"
                console.log('confirm result is', result);
                resultofclick = result;
                console.log('resultofclick' + resultofclick);

                if (resultofclick == true) {
                    component.set('v.isLoading', true);
                    component.displayMessage('Success', 'Messages are in progress ', 'Success', 'dismissible');
                    console.log('methhod called');
                    if(component.get("v.mmsPreview")) {
                        console.log('content ',component.get('v.mmsPreview'));
                        var fileContents = component.get('v.mmsPreview');
                        var base64 = 'base64,';
                        var dataStart = fileContents.indexOf(base64) + base64.length;

                        fileContents = fileContents.substring(dataStart);
                        // this.uploadProcess(component, contentFile);
                        // set a default size or startpostiton as 0 
                        var startPosition = 0;
                        // var fileContents = component.get("v.mmsPreview");
                        // calculate the end size or endPostion using Math.min() function which is return the min. value   
                        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

                        // start with the initial chunk, and set the attachId(last parameter)is null in begin
                        this.uploadInChunk(component, fileContents, startPosition, endPosition, '');
                    }
                    else {
                        this.createActivities(component, event);
                    }
                    
                    
                }
            });
        } else {
            component.set('v.isLoading', false);
            component.displayMessage('warning', ' select any list view  AND Fill the Message', 'warning', 'dismissible');
        }

    },
                
    //On Focus Send Message TextArea
    onFocusSendMessage: function (component) {
        var messageinput = document.querySelector(".message-input");
        if (messageinput) {
            messageinput.style.height = '145px';
        }   
    },

    //On Focus Out Send Message TextArea
    onFocusOutSendMessage: function (component) {
        var messageinput = document.querySelector(".message-input");
        if (messageinput) {
            messageinput.style.height = 'max-content';
        }
    },            
                
	//Count SMS Characters and Max Characters and No of SMS As Per Plivo
    countCharactersAndSMS: function(text) {
        var length = text.length;
        var hasSevenBitCharacters = new RegExp('^[A-Za-z0-9@£$¥èéùìòÇØøÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ!"#¤%&\'()*+,-./:;<=>?¡ÄÖÑÜ§¿äöñüà€\\r\\n]+$').test(text);
        var hasUnicodeCharacters = /[\u0080-\uFFFF]/.test(text);
        var maxCharacters, maxSMS;

        if (hasSevenBitCharacters) {
            maxCharacters = 160;
            maxSMS = 160;
        } else if (hasUnicodeCharacters) {
            maxCharacters = 70;
            maxSMS = 67;
        } else {
            maxCharacters = 160;
            maxSMS = 153;
        }

        var smsCount = Math.ceil(length / maxSMS);

        return {
            characters: length,
            sms: smsCount,
            maxCharacters: maxCharacters
        };
    },
                
    createActivities: function (component, event) {
        var tempsobject = component.get('v.selectedlistofrecords');
        
        console.log('sobject' + tempsobject);
        console.table(tempsobject);
        
        var sobjectIdList = [];
        for (var i = 0; i < tempsobject.length; i++) {
            console.log('forloopin');
            var tempsobjectId = tempsobject[i].Id;
            console.log('tempsobjectId' + tempsobjectId);
            sobjectIdList.push(tempsobjectId);
            //Do something
        }
        console.table(sobjectIdList);

        var message = component.get('v.currentMessage');
        var activityaction = component.get('c.createActivity');
        var attachmentId = component.get('v.currentAttachId');
        var currentfileType = component.get("v.fileType");
        activityaction.setParams({
            messagebody: message,
            messageSubject: 'Outbound SMS Bulk send',
            recordIdList: sobjectIdList,
            sObjectApiName: component.get('v.sObjectApiName') ? component.get('v.sObjectApiName') : '',
            phoneNumber: component.get('v.selectedPhoneNumber') ? component.get('v.selectedPhoneNumber') : '',
            attachmentId: attachmentId,
            currentfileType: currentfileType,
        });
        activityaction.setCallback(this, function (response) {
            var state = response.getState();
            console.log('listviewstate' + state);
            if (state == "SUCCESS") {
                var Listofactivities = response.getReturnValue();
                component.set('v.Activitylist', Listofactivities);
                component.set('v.isLoading', false);
                console.log('SUCCESS reset init');
                this.reset(component);
            } else { // if any callback error, display error msg
                console.log('Error in Calling API');
                component.set('v.isLoading', false);
                var errors = response.getError();
                console.log('errors' + errors[0].message);
                console.table(errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.displayMessage('Failure!', 'Failed to Call API : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(activityaction);
    },

    reset : function (component) {
        component.set('v.mmsPreview', '');
        component.set('v.currentAttachId', '');
        component.set('v.currentMessage', '');
        component.set('v.smsCount', 0);
        component.set('v.isLoading', false);

        var messageinput = document.querySelector( ".message-input"); 
        if(messageinput) {
            messageinput.value = '';
            messageinput.style.height = '45px';
        }

    },

    uploadHelper: function (component, event) {
        // start/show the loading spinner   
        component.set("v.isLoading", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        this.logConsoleDebug('File ' + file, 'log');
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.isLoading", false);
            this.displayMessage('Error', 'File size cannot exceed ' + this.formatBytes(self.MAX_FILE_SIZE) + ' Selected file size: ' + this.formatBytes(file.size), 'Error', 'dismissible');
            return;
        }
        if ((file.type !== 'image/png') && (file.type !== 'image/jpg') && (file.type !== 'image/jpeg')) {
            component.set("v.isLoading", false);
            this.displayMessage('Error', 'Invalid File type :: Accepted file types are: image/png,image/jpg,image/jpeg ', 'Error', 'dismissible');
            return;
        }
        component.set('v.fileName', file.name);
        component.set('v.fileType', file.type);
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function () {
            console.log('file read onload');
            var fileContents = objFileReader.result;
            component.set('v.mmsPreview', fileContents);
            
            component.set("v.isLoading", false);
            console.log('file read onload' + fileContents);
            // var base64 = 'base64,';
            // var dataStart = fileContents.indexOf(base64) + base64.length;

            // fileContents = fileContents.substring(dataStart);
            // this.logConsoleDebug('fileContents ' + fileContents, 'log');

            // call the uploadProcess method 
            // self.uploadProcess(component, file, fileContents);
        });

        objFileReader.readAsDataURL(file);
    },

    // //Verify and Chunk Attachment
    uploadProcess: function (component, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // var fileContents = component.get("v.mmsPreview");
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, fileContents, startPosition, endPosition, '');
    },

    //Attachment Chunking
    uploadInChunk: function (component, fileContents, startPosition, endPosition, attachId) {
        var tempsobject = component.get('v.selectedlistofrecords');
        
        console.log('sobject' + tempsobject);
        console.table(tempsobject);
        
        var sobjectIdList = [];
        for (var i = 0; i < tempsobject.length; i++) {
            console.log('forloopin');
            var tempsobjectId = tempsobject[i].Id;
            console.log('tempsobjectId' + tempsobjectId);
            sobjectIdList.push(tempsobjectId);
            //Do something
        }

        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        var fileName = component.get("v.fileName");
        var fileType = component.get("v.fileType");
        action.setParams({
            parentIds: sobjectIdList,
            fileName: fileName,
            base64Data: encodeURIComponent(getchunk),
            contentType: fileType,
            fileId: attachId
        });

        // set call back 
        action.setCallback(this, function (response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, fileContents, startPosition, endPosition, attachId);
                } else {
                    // this.displayMessage('Success', 'Success File Uploaded Successfully ' + attachId, 'Success','dismissible');
                    this.logConsoleDebug('Attachment Id ' + attachId, 'log');
                    component.set("v.currentAttachId", attachId);
                    this.createActivities(component);
                    // component.set("v.isLoading", false);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                this.displayMessage('Error', 'Error in Uploading Image: ' + response.getReturnValue(), 'Error', 'dismissible');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.logConsoleDebug("Error message: " + errors[0].message, 'log');
                        this.displayMessage('Error', 'Error in Uploading Image: ' + errors[0].message, 'Error', 'dismissible');
                    }
                } else {
                    this.logConsoleDebug("Unknown error", 'log');
                    this.displayMessage('Error', 'Error in Uploading Image: Unknown error ', 'Error', 'dismissible');
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },

})