({
    MAX_FILE_SIZE: 2097152, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000, //Chunk Max size 750Kb 
    //Helper Methods
    //Show Toaster
    displayMessage: function (title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },

    //Generate UUID
    uuid4: function () {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0,
                v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    },

    //Print Console log or Table
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

    //Check is ISJSON or Not
    isJson: function (str) {
        try {
            JSON.parse(str);
        } catch (e) {
            return false;
        }
        return true;
    },
    
    //Check is Valid Phone or not
    IsValidPhoneNumber : function (input_str) {
        var re = /^\(?(\d{3})\)?[- ]?(\d{3})[- ]?(\d{4})$/;
        return re.test(input_str);
    },

    //Format Bytes to Text
    formatBytes: function (bytes) {
        var decimals=2;
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const dm = decimals < 0 ? 0 : decimals;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    },

    //Check is Mobile
    isMobile: function () {
        var a = navigator.userAgent || navigator.vendor || window.opera;
        return /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4));
    },

    //Check Undefined and return Blanks or null
    getBlankorNullForInvalidData: function (valueToCheck , returnBlank) {
        var cleanedValue = valueToCheck;
        if ( (valueToCheck == "undefined") || (valueToCheck == null) ){
            if(returnBlank){
                cleanedValue = '';
            }else{
                cleanedValue = null;
            }
        }        
        return cleanedValue;
    },

    //Scroll Section to Conversation Bottom
    scrolltoConversationBottom : function (component, event, helper) {
        try {
            var isIsolatedComponent = component.get('v.isIsolatedComponent');
            var componentUniqueName = component.get('v.componentUniqueName');
            var conversationScroll;
            var scrolltochatscreenfooter;
            if (isIsolatedComponent) {
                conversationScroll = document.querySelector("." + componentUniqueName + ".messagesdetailtab .chat-scroll-body");
                scrolltochatscreenfooter = document.querySelector("." + componentUniqueName + ".messagesdetailtab .emptyconversation");
            } else {
                conversationScroll = document.querySelector("." + componentUniqueName + " .chat-scroll-body");
                scrolltochatscreenfooter = document.querySelector("." + componentUniqueName + " .emptyconversation");
            }
            if (conversationScroll) {
                var conversationElementHeight = conversationScroll.clientHeight;
                var conversationScrollHeight = conversationScroll.scrollHeight;
                var IsScrollbarVisible = (conversationScrollHeight > conversationElementHeight) ? true : false;
                if ((conversationScrollHeight > 100) && IsScrollbarVisible) {
                    this.logConsoleDebug('scrolltoConversationBottom ', 'log');
                    
                    if (scrolltochatscreenfooter) {
                        window.setTimeout(function () {
                            scrolltochatscreenfooter.scrollIntoView({ behavior: 'smooth', block: 'end' });
                            // scrolltochatscreenfooter.scrollIntoView(true);
                        }, 2000);
                    }
                    // conversationScroll.scrollTo({
                    //     left: 0,
                    //     top: conversationScrollHeight,
                    //     behavior: "smooth"
                    // });
                    // component.set('v.scrollToBottom', false);
                }
            }
        } catch (ex) {
            this.logConsoleDebug('Exception in scrolltoConversationBottom ' + ex, 'log');
        }
    },

    //Fire Application Event
    fireApplicationEventCallWithParams: function (eventControllerName, params) {
        var appEvent = $A.get('e.c:' + eventControllerName);
        appEvent.setParams(params);
        this.logConsoleDebug('*** ' + 'Sending messagedata' + ' *** ' + params, 'log');
        this.logConsoleDebug('*** ' + 'Sending application event' + ' *** ' + eventControllerName, 'log');
        appEvent.fire();
        this.logConsoleDebug('*** ' + 'Sent application event successfully' + ' *** ' + eventControllerName, 'log');
    },

    fireApplicationEventCall: function (eventControllerName, showLoader, aurcomponentname, controllermethod, searchkey, storedActivityNumber, currentContactId) {
        var appEvent = $A.get('e.c:' + eventControllerName);
        appEvent.setParams({
            "aurcomponentname": aurcomponentname,
            "showLoader": showLoader,
            "controllermethod": controllermethod,
            "searchkey": searchkey,
            "storedActivityNumber": storedActivityNumber,
            "currentContactId": currentContactId
        });
        this.logConsoleDebug('*** ' + 'Sending Poolind Event Params' + ' *** ', 'log');
        this.logConsoleDebug('*** ' + 'aurcomponentname' + ' *** ' + aurcomponentname, 'log');
        this.logConsoleDebug('*** ' + 'controllermethod' + ' *** ' + controllermethod, 'log');
        this.logConsoleDebug('*** ' + 'searchkey' + ' *** ' + searchkey, 'log');
        this.logConsoleDebug('*** ' + 'storedActivityNumber' + ' *** ' + storedActivityNumber, 'log');
        this.logConsoleDebug('*** ' + 'currentContactId' + ' *** ' + currentContactId, 'log');
        this.logConsoleDebug('*** ' + 'Sending application event' + ' *** ' + eventControllerName, 'log');
        appEvent.fire();
        this.logConsoleDebug('*** ' + 'Sent application event successfully' + ' *** ' + eventControllerName, 'log');
    },

    //Pooling Helper Methods
    //Call Polling Application Event when No Bypass
    refreshDatainUI: function (component, event, helper) {
        // does whatever you need it to actually do - probably signs them out or stops polling the server for info
        var inprogressAction = (component.get("v.userInteraction") != undefined) ? component.get("v.userInteraction") : false;
        this.logConsoleDebug('Pooling Status ' + inprogressAction, 'log');
        var componentUniqueName = component.get('v.componentUniqueName');
        if (inprogressAction == false) {
            this.logConsoleDebug('Pooling Status fetchLatestActivityRecords ' + inprogressAction, 'log');
            var latestActivityNum = component.get('v.latestActivityNum');
            latestActivityNum = ((latestActivityNum != undefined) && (latestActivityNum != null)) ? latestActivityNum : 0.0;
            this.logConsoleDebug('Parameter to send latestActivityNum is: ' + latestActivityNum, 'log');
            var contactPhoneNumber = component.get('v.contactPhoneNumber');
            contactPhoneNumber = ((contactPhoneNumber == undefined) || (contactPhoneNumber == null) || (contactPhoneNumber == '')) ? '' : contactPhoneNumber;
            var recordId = component.get('v.recordId');
            recordId = ((recordId == undefined) || (recordId == null) || (recordId == '')) ? '' : recordId;
            this.fireApplicationEventCall('InboxApplicationEvent', false, componentUniqueName, 'contactSearch', '', latestActivityNum, contactPhoneNumber, recordId);
        } else {
            this.logConsoleDebug('Pooling Status resetTimer ' + inprogressAction, 'log');
            this.resetTimer();
        }
        this.logConsoleDebug('Done refreshApex', 'log');
    },

    //Reset Pooling Timer
    resetTimer: function (component, event, helper) {
        this.logConsoleDebug('resetTimer', 'log');
        var setIntervalId = component.get("v.setIntervalId");
        window.clearInterval(setIntervalId);
        component.set("v.setIntervalId", "");
        this.startTimer();
    },

    //Init Pooling Timer
    startTimer: function (component, event, helper) {
        this.logConsoleDebug('startTimer: ' + component.get("v.timeoutInMiliseconds"), 'log');
        var timeoutInMiliseconds = (component.get("v.timeoutInMiliseconds") == undefined) ? 10000 : component.get("v.timeoutInMiliseconds");
        this.logConsoleDebug(timeoutInMiliseconds, 'log');
        // window.setTimeout returns an Id that can be used to start and stop a timer
        var timeoutId = window.setInterval(
            $A.getCallback(function () {
                this.refreshDatainUI();
            }), timeoutInMiliseconds
        );
        component.set("v.setIntervalId", timeoutId);
    },

    //Attachment Upload Helper
    uploadHelper: function (component, event) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        this.logConsoleDebug('File ' + file, 'log');
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            this.displayMessage('Error', 'File size cannot exceed ' + this.formatBytes(self.MAX_FILE_SIZE) + ' Selected file size: ' + this.formatBytes(file.size), 'Error', 'dismissible');
            return;
        }
        if ((file.type !== 'image/png') && (file.type !== 'image/jpg') && (file.type !== 'image/jpeg')) {
            component.set("v.showLoadingSpinner", false);
            this.displayMessage('Error', 'Invalid File type :: Accepted file types are: image/png,image/jpg,image/jpeg ', 'Error', 'dismissible');
            return;
        }
        component.set('v.fileType', file.type);
        component.get("v.fileType");
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function () {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;

            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });

        objFileReader.readAsDataURL(file);
    },

    //Verify and Chunk Attachment
    uploadProcess: function (component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },

    //Attachment Chunking
    uploadInChunk: function (component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
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
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    // this.displayMessage('Success', 'Success File Uploaded Successfully ' + attachId, 'Success','dismissible');
                    this.logConsoleDebug('Attachment Id ' + attachId, 'log');
                    component.set("v.currentAttachId", attachId);
                    component.set("v.showLoadingSpinner", false);
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

    //INIT Fancybox
    setupFancybox: function (component, event, helper) {
        this.logConsoleDebug('Init Facny Box', 'log');
        try {
            jQuery("document").ready(function(){
                $("a.fancybox").fancybox({
                    'modal': true,
                    'closeExisting': true,
                    'transitionIn': 'elastic',
                    'transitionOut': 'elastic',
                    'speedIn': 600,
                    'speedOut': 200,
                    'overlayShow': false,
                    'hideOnContentClick': false,
                    'closeBtn': true,
                    'helpers': {
                        'overlay': {
                            'closeClick': false,
                        }
                    }
                });
            });
        } catch (e) {
            this.logConsoleDebug('Failed to Load Fancybox Library ' + e, 'log');
        }
    },

    //On Focus Send Message TextArea
    onFocusSendMessage: function (component) {
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        var componentUniqueName = component.get('v.componentUniqueName');
        var messageinput;
        if (isIsolatedComponent) {
            messageinput = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-input");
        } else {
            messageinput = document.querySelector("." + componentUniqueName + " .message-input");
        }
        if (messageinput) {
            messageinput.style.height = '145px';
        }   
        //Decrease Conversation Scroller Height
        // var conversationScroll;
        // if (isIsolatedComponent) {
        //     conversationScroll = document.querySelector("."+componentUniqueName + ".messagesdetailtab .chat-scroll-body");
        // } else {
        //     conversationScroll = document.querySelector("."+componentUniqueName + " .chat-scroll-body");
        // }
        // if(conversationScroll){
        //     var conversationScrollHeight = conversationScroll.offsetHeight;
        //     conversationScroll.style.height = ( conversationScrollHeight - 100 ) + 'px';
        // }
    },

    //On Focus Out Send Message TextArea
    onFocusOutSendMessage: function (component) {
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        var componentUniqueName = component.get('v.componentUniqueName');
        var messageinput;
        if (isIsolatedComponent) {
            messageinput = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-input");
        } else {
            messageinput = document.querySelector("." + componentUniqueName + " .message-input");
        }
        if (messageinput) {
            messageinput.style.height = 'max-content';
            //let messageinputheight = messageinput.scrollHeight;
            //if(messageinputheight > 45){
            //    messageinput.style.height = messageinputheight + 'px';
            //}else{
            //    messageinput.style.height = '45px';
            //}            
        }   
        //reset Conversation Scroller Height
        // var conversationScroll;
        // if (isIsolatedComponent) {
        //     conversationScroll = document.querySelector("."+componentUniqueName + ".messagesdetailtab .chat-scroll-body");
        // } else {
        //     conversationScroll = document.querySelector("."+componentUniqueName + " .chat-scroll-body");
        // }
        // if(conversationScroll){
        //     var conversationScrollHeight = conversationScroll.offsetHeight;
        //     conversationScroll.style.height = ( conversationScrollHeight + 100 ) + 'px';
        // }
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

    //ServerCallUsingPromise
    ServerCallUsingPromise : function( component, method, params ) {
        var self = this;
        var promiseInstance = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get(method);
            if(params){
                action.setParams(params);
            }
            self.logConsoleDebug('****param to controller:' + JSON.stringify(params), 'log');
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }else if(state === "ERROR"){
                    var errors = response.getError();
                    self.logConsoleDebug('Errorin promise call ' + errors, 'log');
                    reject(response.getError() );
                }
            });
            $A.enqueueAction(action);
        }));            
        return promiseInstance;
    },
     
    //Init Messages based on member select Change or Page Load
    InitMemberMessagesList : function (component, event, helper, isPrevious) {
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        var groupName = component.get('v.componentUniqueName'); 
        component.set('v.memberInitRelatedActivities', '');
        component.set('v.memberPreviousRelatedActivities', '');
        component.set('v.latestActivitiesList', []);
        component.set('v.latestActivitiesMap', {});

        component.set('v.selectedPhoneNumber', '');
        component.set('v.selectedTemplate', '');

        component.set('v.isMemberOptedOut', false);
        component.set('v.memberConsentStatus', '');

        component.set('v.currentMessage', '');
        // Call the helper function to calculate the character count, SMS count, and Max character Length
        var result = helper.countCharactersAndSMS('');
        var messageFieldMaxLength = result.maxCharacters;
        var messageCharacterCount = result.characters;
        var smsCount = result.sms;
        component.set('v.messageFieldMaxLength', messageFieldMaxLength);  
        component.set('v.messageCharacterCount', messageCharacterCount);  
        component.set('v.smsCount', smsCount); 
        component.set('v.currentMessagesListPage' , 1);
        component.set('v.ShowPosQuickActions', false);
        
        var messagesLimitPerPage = component.get('v.messagesLimitPerPage');
        var currentMessagesListPage = component.get('v.currentMessagesListPage');        
        var isPrevious = false; // On Load its not Prevoius message fetch Action
        this.logConsoleDebug('Page Size: ' + messagesLimitPerPage + 'Current Page: ' + currentMessagesListPage, 'log');
        var messagesdetailtabElement;
        if (isIsolatedComponent) {
            component.set("v.memberObjectapiname" , component.get("v.objectapiname") );
            messagesdetailtabElement = document.querySelector("."+groupName + ".messagesdetailtab");
        } else {
            messagesdetailtabElement = document.querySelector("."+groupName + " .messagesdetailtab");
        }
        if(messagesdetailtabElement){
            messagesdetailtabElement.classList.add("activetab");
        }

        //Fetch Contact Details
        var memberObjectapiname = component.get("v.memberObjectapiname"); 
        var contactRecordId = component.get("v.recordId");
        contactRecordId = this.getBlankorNullForInvalidData(contactRecordId, true);
        
        if( (contactRecordId != '') && (memberObjectapiname == 'Contact') ){
            var actionContact = component.get('c.getContactDetails'); 
            actionContact.setParams({
                'recordIdOrUUID': contactRecordId
            });
            actionContact.setCallback(this, function (response) // gettingresponse back from apex method
            {
                var state = response.getState(); // getting the state
                if (state === 'SUCCESS') {
                    var responseselectedContactDetails = response.getReturnValue();
                    this.logConsoleDebug(responseselectedContactDetails, 'table');
                    component.set('v.selectedContactRecord', responseselectedContactDetails); // setting the value in attribute
                    var recordTypeName = responseselectedContactDetails.RecordType.DeveloperName;
                    var ShowPosQuickActions = ( (recordTypeName == 'Member') ? true : false);
                    this.logConsoleDebug('getContactDetails ' + recordTypeName, 'log');
                    component.set('v.ShowPosQuickActions', ShowPosQuickActions );
                    
                    this.getDefaultPhoneNumber(component, event, helper ); 
                    //Queued 3 apex methods
                    //to set the from phone number
                } else {
                    this.logConsoleDebug('Error Call getContactDetails ', 'log');
                    // Failure
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            this.logConsoleDebug('Failed to getContactDetails : ' + errors[0].message, 'log');
                        }
                    }

                    this.getDefaultPhoneNumber(component, event, helper ); 
                    //Queued 3 apex methods
                    //to set the from phone number
                }
            });
            $A.enqueueAction(actionContact);
        } else {
            this.getDefaultPhoneNumber(component, event, helper ); 
            //Queued 3 apex methods
            //to set the from phone number
        }
        
    },

    //Fetch Activities Based on Pagination
    getMessagesList : function (component, event, helper, isPrevious) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var contactPhoneNumber = component.get('v.contactPhoneNumber');
        contactPhoneNumber = this.getBlankorNullForInvalidData(contactPhoneNumber, true);
        var messagesLimitPerPage = component.get('v.messagesLimitPerPage');
        var currentMessagesListPage = component.get('v.currentMessagesListPage');       

        var getMessagesByRecordIdAPiCall = component.get('c.getMessagesByRecordId');
        getMessagesByRecordIdAPiCall.setParams({
            'recordId': recordId,
            'phoneNumber': contactPhoneNumber,
            'messagesLimitPerPage': messagesLimitPerPage,
            'currentPage': currentMessagesListPage
        });
        //getting the response from the apex class
        getMessagesByRecordIdAPiCall.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var inboxMemberWrapper = response.getReturnValue();
                //setting the response from apex class to the attribute     
                if(isPrevious == false ){
                    var externalNumber = this.getBlankorNullForInvalidData(inboxMemberWrapper.externalPhoneNumber, true);
                    component.set('v.memberInitRelatedActivities', inboxMemberWrapper);
                    component.set('v.contactName', inboxMemberWrapper.contactName);
                    component.set('v.contactPhoneNumber', inboxMemberWrapper.contactPhoneNumber);
                    component.set('v.memberObjectapiname', inboxMemberWrapper.objectApiName);
                    component.set('v.selectedPhoneNumber', externalNumber);
                    component.set('v.hasPictureURL', inboxMemberWrapper.hasPictureURL); 
                    component.set('v.pictureURL', inboxMemberWrapper.pictureURL);
                    component.set('v.shortNameCode', inboxMemberWrapper.shortNameCode);
                    component.set('v.totalPages', inboxMemberWrapper.totalPages);
                    component.set('v.totalActivityRecords', inboxMemberWrapper.totalActivityRecords);
                    //Reset Latest platform event activities
                    component.set('v.latestActivitiesList', []);
                    component.set('v.latestActivitiesMap', {});
                    this.logConsoleDebug(inboxMemberWrapper, 'table'); 
                    var self = this;
                    window.setTimeout($A.getCallback(function () {
                        self.scrolltoConversationBottom(component, event, helper);
                    }), 1000);   
                    window.setTimeout($A.getCallback(function () {
                        self.scrolltoConversationBottom(component, event, helper);
                    }), 5000);                 
                    component.set('v.isLoading', false);

                } else { //Load Previous Messages
                    var memberPreviousRelatedActivities = component.get('v.memberPreviousRelatedActivities');
                    //paginatedActivitiesList
                    if (((memberPreviousRelatedActivities.paginatedActivitiesList != undefined)) && (memberPreviousRelatedActivities.paginatedActivitiesList.length != 0)) {
                        //Prepend New meesages in the current allactivities list
                        inboxMemberWrapper.paginatedActivitiesList = [...inboxMemberWrapper.paginatedActivitiesList, ...memberPreviousRelatedActivities.paginatedActivitiesList];
                    }
                    component.set('v.memberPreviousRelatedActivities', inboxMemberWrapper);
                    component.set('v.contactName', inboxMemberWrapper.contactName);
                    component.set('v.contactPhoneNumber', inboxMemberWrapper.contactPhoneNumber);
                    component.set('v.hasPictureURL', inboxMemberWrapper.hasPictureURL);
                    component.set('v.pictureURL', inboxMemberWrapper.pictureURL); 
                    component.set('v.shortNameCode', inboxMemberWrapper.shortNameCode); 
                    component.set('v.totalPages', inboxMemberWrapper.totalPages);
                    component.set('v.totalActivityRecords', inboxMemberWrapper.totalActivityRecords);
                    this.logConsoleDebug(inboxMemberWrapper, 'table');
                    component.set('v.isLoading', false);
                }       
            } else {
                // Failure
                component.set('v.isLoading', false);
                this.logConsoleDebug('Error in Retriving Activitys', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to Retrive Activities : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(getMessagesByRecordIdAPiCall);
    },    

    //Fetch Contact with Latest message
    searchContacts : function (component, event, helper) {
        var componentUniqueName = component.get('v.componentUniqueName');
        var searchText = component.get('v.searchText');
        var storedActivityNumber = component.get('v.latestActivityNum');
        storedActivityNumber = ((storedActivityNumber != undefined) && (storedActivityNumber != null)) ? storedActivityNumber : 0.0;
        var currentRecordId = component.get('v.recordId');
        currentRecordId = ((currentRecordId == undefined) || (currentRecordId == null) || (currentRecordId == '')) ? '' : currentRecordId;
        var contactPhoneNumber = component.get('v.contactPhoneNumber');
        contactPhoneNumber = ((contactPhoneNumber == undefined) || (contactPhoneNumber == null) || (contactPhoneNumber == '')) ? '' : contactPhoneNumber;
        var initActivityWrapper = component.get('c.contactSearch');
        initActivityWrapper.setParams({
            'searchkey': searchText,
            'storedActivityNumber': storedActivityNumber,
            'contactPhoneNumber': contactPhoneNumber,
            'currentRecordId': currentRecordId
        });
        //getting the response from the apex class
        initActivityWrapper.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var activityWrapper = response.getReturnValue();
                //setting the response from apex class to the attribute     
                component.set('v.activitywrapper', activityWrapper);
                component.set('v.isLoading', false);
                this.logConsoleDebug(activityWrapper, 'table');
                if ((activityWrapper.length == 0) && (this.IsValidPhoneNumber(searchText))) {
                    this.logConsoleDebug('isValidPhone ', 'log');
                    component.set('v.showSendMessagetoNewPhone', true);
                    // document.querySelector("."+componentUniqueName + " .sendQuickMessageNewPhone").style.display = 'block';
                }
            } else {
                // Failure
                component.set('v.isLoading', false);
                this.logConsoleDebug('Error in Retriving Activitys', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to Retrive Activities : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(initActivityWrapper);
    },

    //Mark Activities as Read
    markActivitiesAsRead : function (component, event, helper) {
        var componentUniqueName = component.get('v.componentUniqueName');
        var currentRecordId = component.get('v.recordId');
        currentRecordId = ((currentRecordId == undefined) || (currentRecordId == null) || (currentRecordId == '')) ? '' : currentRecordId;
        var contactPhoneNumber = component.get('v.contactPhoneNumber');
        contactPhoneNumber = ((contactPhoneNumber == undefined) || (contactPhoneNumber == null) || (contactPhoneNumber == '')) ? '' : contactPhoneNumber;
        var markMessagesAsReadAction = component.get('c.markMessagesAsRead');
        markMessagesAsReadAction.setParams({
            'recordId': currentRecordId,
            'phoneNumber': contactPhoneNumber
        });
        //getting the response from the apex class
        markMessagesAsReadAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var activitiesReadStatus = response.getReturnValue();
                //setting the response from apex class to the attribute 
                //send communication event to refresh left component data 
                //Send Event to ChatBotMembers Component to Refresh Members List
                var eventName = 'refreshInboxMemberList';
                var eventSource = 'ChatBotMemberConversation';
                var eventAction = 'refreshInboxMembers';
                var groupName = component.get('v.componentUniqueName');
                helper.logConsoleDebug('groupName ChatBotMemberConversation ' + groupName, 'log');  
                helper.fireApplicationEventCallWithParams('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'{"eventName":"' + eventName + '","eventSource":"' + eventSource + '","eventAction":"' + eventAction + '","groupName":"' + groupName + '"}' } );    
                // component.set('v.isLoading', false);
            } else {
                // Failure
                component.set('v.isLoading', false);
                this.logConsoleDebug('Error in marking Messages as Read', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to mark Messages as Read : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(markMessagesAsReadAction);
    },

    //Send SMS Outbound
    sendOutboundSMS : function (component, event, helper) {
        this.logConsoleDebug('sendOutboundSMS Called', 'log');
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        var componentUniqueName = component.get('v.componentUniqueName');
        var currentMessage = component.get('v.currentMessage');
        currentMessage = currentMessage.trim();

        var messageinput;
        if (isIsolatedComponent) {
            messageinput = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-input");
        } else {
            messageinput = document.querySelector("."+componentUniqueName + " .message-input"); 
        }

        if(messageinput){
            messageinput.value = '';
            messageinput.style.height = '45px';
            // this.onFocusOutSendMessage(component);
        }

        var defaultnomessagesdiv;
        if (isIsolatedComponent) {
            defaultnomessagesdiv = document.querySelector("." + componentUniqueName + ".messagesdetailtab .defaultnomessagesdiv");
        } else {
            defaultnomessagesdiv = document.querySelector("."+componentUniqueName + " .defaultnomessagesdiv"); 
        }

        if(defaultnomessagesdiv){
            defaultnomessagesdiv.style.display = 'none';
        }
        component.set('v.currentMessage', '');
        if ((currentMessage == '') || (currentMessage == undefined)) {
            this.logConsoleDebug(' currentMessage is blank ' + currentMessage, 'log');
            this.displayMessage('Error!', 'Please Enter some Message', 'error', 'dismissible');
            return false;
        }
        // component.set('v.isLoading', true);
        component.set('v.showLoadingSpinner', true);
        component.set("v.userInteraction", true);
        this.logConsoleDebug('currentMessage ' + currentMessage, 'log');
        var messageSubject = 'Inbox - Outbound SMS';
        var recordId = component.get('v.recordId');
        var contactPhoneNumber = component.get('v.contactPhoneNumber');
        this.logConsoleDebug("messageDetails contactPhoneNumber " + contactPhoneNumber, 'log');
        var userAccountId = component.get("v.AccountId");

        this.logConsoleDebug("messageDetails selectedPhoneNumber " + component.get('v.selectedPhoneNumber'), 'log');
        this.logConsoleDebug("messageDetails defaultPhoneNumber " + component.get('v.defaultPhoneNumber'), 'log');
        this.logConsoleDebug("messageDetails exp " + component.get('v.selectedPhoneNumber') ? component.get('v.selectedPhoneNumber') : component.get('v.defaultPhoneNumber'), 'log');
        var action = component.get('c.createActivity');
        action.setParams({
            'type': 'sms',
            'mediaUrls': [],
            'messagebody': currentMessage,
            'messageSubject': messageSubject,
            'fromPhone': component.get('v.selectedPhoneNumber') ? component.get('v.selectedPhoneNumber') : component.get('v.defaultPhoneNumber'),
            'toPhone': contactPhoneNumber,
            'recordId': recordId,
            'accountId' : userAccountId
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); // getting the state
            // component.set('v.showLoadingSpinner', false);
            if (state === "SUCCESS") {
                var self = this;
                window.setTimeout($A.getCallback(function () {
                    self.scrolltoConversationBottom(component, event, helper);
                }), 500);
                window.setTimeout($A.getCallback(function () {
                    self.scrolltoConversationBottom(component, event, helper);
                }), 2000);
                this.logConsoleDebug('SUCCESSFULLY Created SMS activity', 'log');
                var activityrecord = response.getReturnValue();
                if ((activityrecord != undefined) && (activityrecord != null)) {
                    let SMSCalloutaction = component.get("c.plivoSmsCalloutSynchronous");
                    SMSCalloutaction.setParams({
                        "recordId": activityrecord.Id,
                        "httpMethod": 'POST',
                        "operationType": 'INSERT',
                        "integrationSetting": 'Plivo',
                        "objectSetting": 'PlivoSMS'
                    });
                    SMSCalloutaction.setCallback(this, function (response) {
                        let state = response.getState();
                        this.logConsoleDebug('SMS Callback ' + state, 'log');
                        window.setTimeout($A.getCallback(function () {
                            self.scrolltoConversationBottom(component, event, helper);
                        }), 500);   
                        window.setTimeout($A.getCallback(function () {
                            self.scrolltoConversationBottom(component, event, helper);
                        }), 2000); 
                        if (state === 'SUCCESS') {
                            var responseSmsActivity = response.getReturnValue();
                            var smsStatus = responseSmsActivity.Status__c;
                            this.logConsoleDebug('Apex responseSmsActivity:', 'log');
                            this.logConsoleDebug(responseSmsActivity, 'table');
                            this.logConsoleDebug('SMS Status ' + responseSmsActivity.Status__c, 'log');
                            if(smsStatus != 'Failed	'){
                                component.set("v.userInteraction", false);
                                // component.set('v.isLoading', false);
                                // component.set('v.showLoadingSpinner', false);
                            } else {
                                this.displayMessage('Failure!', 'Failed to Send SMS. Status: ' + sysLogStatus, 'error', 'dismissible');
                                component.set("v.userInteraction", false);
                                // component.set('v.isLoading', false);
                                // component.set('v.showLoadingSpinner', false);
                            }

                        } else if (state === "ERROR") {
                            var errors = response.getError();
                            component.set("v.userInteraction", false);
                            // component.set('v.isLoading', false);
                            component.set('v.showLoadingSpinner', false);
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    this.displayMessage('Failure!', 'Failed to Send SMS. Status: ' + errors[0].message, 'error', 'dismissible');
                                }
                            } else {
                                this.displayMessage('Failure!', 'Failed to Send SMS. Status: Unknown error', 'error', 'dismissible');
                            }
                        }
                    });

                    $A.enqueueAction(SMSCalloutaction);
                }

            } else {
                // Failure
                this.logConsoleDebug('Error in Creation of SMS Activity ', 'log');
                component.set("v.userInteraction", false);
                // component.set('v.isLoading', false);
                component.set('v.showLoadingSpinner', false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to Create SMS Activity : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(action);

    },

    //Send MMS Outbound
    sendOutboundMMS : function (component, event, helper) {
        this.logConsoleDebug('sendOutboundMMS Called', 'log');
        // component.set('v.isLoading', true);
        component.set('v.showLoadingSpinner', true);
        component.set("v.userInteraction", true);
        
        var attachId = component.get("v.currentAttachId");
        var currentfileType = component.get("v.fileType");

        var recordId = component.get("v.recordId");
        var contactPhoneNumber = component.get('v.contactPhoneNumber');
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        var componentUniqueName = component.get('v.componentUniqueName');
        var messageSubject = 'Inbox - Outbound MMS';
        this.logConsoleDebug("messageDetails contactPhoneNumber " + contactPhoneNumber, 'log');
        var messageinput;
        if (isIsolatedComponent) {
            messageinput = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-input");
        } else {
            messageinput = document.querySelector("."+componentUniqueName + " .message-input"); 
        }

        if(messageinput){
            messageinput.value = '';
            messageinput.style.height = '45px';
            // this.onFocusOutSendMessage(component);
        }

        var defaultnomessagesdiv;
        if (isIsolatedComponent) {
            defaultnomessagesdiv = document.querySelector("." + componentUniqueName + ".messagesdetailtab .defaultnomessagesdiv");
        } else {
            defaultnomessagesdiv = document.querySelector("."+componentUniqueName + " .defaultnomessagesdiv"); 
        }

        if(defaultnomessagesdiv){
            defaultnomessagesdiv.style.display = 'none';
        }
        var userAccountId = component.get("v.AccountId");

        var mediaUploadAPI = component.get('c.submitAttachment');
        mediaUploadAPI.setParams({
            'contentVersionId': attachId,
            'currentfileType' : currentfileType,
            'messageSubject': messageSubject,
            'fromPhone': component.get('v.selectedPhoneNumber') ? component.get('v.selectedPhoneNumber') : component.get('v.defaultPhoneNumber'),
            'toPhone': contactPhoneNumber,
            'recordId': recordId,
            'accountId' : userAccountId
        });
        mediaUploadAPI.setCallback(this, function (response) {
            var state = response.getState(); // getting the state
            // component.set('v.showLoadingSpinner', false);
            if (state === "SUCCESS") {
                var self = this;
                window.setTimeout($A.getCallback(function () {
                    self.scrolltoConversationBottom(component, event, helper);
                }), 500);
                window.setTimeout($A.getCallback(function () {
                    self.scrolltoConversationBottom(component, event, helper);
                }), 2000);
                this.logConsoleDebug('SUCCESSFULLY Created MMS activity', 'log');
                var uploadApiResponseWrapper = response.getReturnValue();
                helper.logConsoleDebug('mediaResponse uploadApiResponseWrapper ' + uploadApiResponseWrapper, 'log');
                if(uploadApiResponseWrapper.status == 'success'){
                    let MMSCalloutaction = component.get("c.plivoSmsCalloutSynchronous");
                    MMSCalloutaction.setParams({
                        "recordId": uploadApiResponseWrapper.activityRecord.Id,
                        "httpMethod": 'POST',
                        "operationType": 'INSERT',
                        "integrationSetting": 'Plivo',
                        "objectSetting": 'PlivoSMS'
                    });
                    MMSCalloutaction.setCallback(this, function (response) {
                        let state = response.getState();
                        this.logConsoleDebug('MMS Callback ' + state, 'log');
                        window.setTimeout($A.getCallback(function () {
                            self.scrolltoConversationBottom(component, event, helper);
                        }), 500);   
                        window.setTimeout($A.getCallback(function () {
                            self.scrolltoConversationBottom(component, event, helper);
                        }), 2000);      
                        if (state === 'SUCCESS') {
                            var responseMmsActivity = response.getReturnValue();
                            var mmsStatus = responseMmsActivity.Status__c;
                            this.logConsoleDebug('Apex responseMmsActivity:', 'log');
                            this.logConsoleDebug(responseMmsActivity, 'table');
                            this.logConsoleDebug('MMS Status ' + responseMmsActivity.Status__c, 'log');
                            if(mmsStatus != 'Failed	'){
                                component.set("v.userInteraction", false);
                                // component.set('v.isLoading', false);
                                // component.set('v.showLoadingSpinner', false);
                            } else {
                                this.displayMessage('Failure!', 'Failed to Send MMS. Status: ' + sysLogStatus, 'error', 'dismissible');
                                component.set("v.userInteraction", false);
                                // component.set('v.isLoading', false);
                                // component.set('v.showLoadingSpinner', false);
                            }
                        } else if (state === "ERROR") {
                            var errors = response.getError();
                            component.set("v.userInteraction", false);
                            // component.set('v.isLoading', false);
                            component.set('v.showLoadingSpinner', false);
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    this.displayMessage('Failure!', 'Failed to Send MMS. Status: ' + errors[0].message, 'error', 'dismissible');
                                }
                            } else {
                                this.displayMessage('Failure!', 'Failed to Send MMS. Status: Unknown error', 'error', 'dismissible');
                            }

                        }
                    });

                    $A.enqueueAction(MMSCalloutaction);
                } else {//Show Upload Api Error
                    component.set("v.userInteraction", false);
                    // component.set('v.isLoading', false);
                    component.set('v.showLoadingSpinner', false);
                    var uploadErrorMessage = uploadApiResponseWrapper.errorMessage;
                    this.displayMessage('File Upload Failed!', 'Failed: ' + uploadErrorMessage, 'error', 'dismissible');
                }

            } else {
                // Failure
                this.logConsoleDebug('Error in Creation of MMS Activity ', 'log');
                component.set("v.userInteraction", false);
                // component.set('v.isLoading', false);
                component.set('v.showLoadingSpinner', false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to Create MMS Activity : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(mediaUploadAPI);

    },

    navigateToPOSOrderSelection : function (component, orderUUID ) {
        this.logConsoleDebug('navigateToPOSOrderSelection', 'log');
        component.set('v.orderUUID' , orderUUID);
        component.set('v.showPosContainer' , true);
        // window.clearInterval(component.get("v.setIntervalId"));
        // component.set("v.setIntervalId","");
    },

    getAllFromPhoneNumbers : function (component, event, helper) {
        var getAllFromNumbers = component.get('c.getAllFromNumbers');
        getAllFromNumbers.setParams({
            "integrationSetting": 'Plivo',
            "objectSetting": 'PlivoSMS'
        });
        //getting the response from the apex class
        getAllFromNumbers.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set('v.isLoading', false);
                component.set("v.fromPhoneNumbers", response.getReturnValue());
                response.getReturnValue().forEach(i => {
                    if(i.selected) {
                        component.set("v.selectedPhoneNumber", i.phoneNumber);
                        helper.logConsoleDebug('selected phone ', i.phoneNumber, 'log');
                    }
                })
                if(!component.get('v.selectedPhoneNumber')) {
                    let defaultNumber = component.get('v.defaultPhoneNumber') ? component.get('v.defaultPhoneNumber') : '';
                    component.set("v.selectedPhoneNumber", defaultNumber);
                    console.log('selected default phone ', defaultNumber);
                }
                this.getMessagesList(component, event, helper, false);


            } else {
                // Failure
                this.getMessagesList(component, event, helper, false);
                component.set('v.isLoading', false);
                this.logConsoleDebug('Error in Retriving PhoneNumbers', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to Retrive Phone Numbers : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(getAllFromNumbers);
    },

    getAllSMSTemplates : function (component, event, helper) {
        var getAllSMSTemplates = component.get('c.getAllSMSTemplates');
        getAllSMSTemplates.setParams({
            "recordId" : component.get('v.recordId')
        });
        //getting the response from the apex class
        getAllSMSTemplates.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set('v.isLoading', false);
                component.set("v.smsTemplates", response.getReturnValue());
                

            } else {
                // Failure
                component.set('v.isLoading', false);
                this.logConsoleDebug('Error while retriving SMS Templates', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to Retrive SMS Templates : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        if(component.get('v.recordId'))
            $A.enqueueAction(getAllSMSTemplates);
    },

    getParsedBody : function (component, event, helper, templateBody) {
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        var componentUniqueName = component.get('v.componentUniqueName');
        var getParsedResponse = component.get('c.getParsedResponse');
        getParsedResponse.setParams({
            "recordId" : component.get('v.recordId') ,
            "smsbody" : templateBody
        });
        //getting the response from the apex class
        getParsedResponse.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                var fetchedTemplateResponse = response.getReturnValue();
                component.set("v.currentMessage", fetchedTemplateResponse);
                
                var messageinput;
                if (isIsolatedComponent) {
                    messageinput = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-input");
                } else {
                    messageinput = document.querySelector("."+componentUniqueName + " .message-input"); 
                }

                if(messageinput){
                    messageinput.value = fetchedTemplateResponse;
                }

                this.logConsoleDebug('fetchedTemplateResponse currentMessage' + component.get("v.currentMessage"), 'log');

            } else {
                // Failure
                component.set('v.isLoading', false);
                this.logConsoleDebug('Error while parsing templates', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to parse SMS Template : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(getParsedResponse);
    },

    getDefaultPhoneNumber : function (component, event, helper) {
        var getDefaultPhoneNumber = component.get('c.getDefaultPhoneNumber');
        getDefaultPhoneNumber.setParams({
            "integrationSetting": 'Plivo'
        });
        //getting the response from the apex class
        getDefaultPhoneNumber.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                var defaultFromNumber = response.getReturnValue();
                component.set('v.defaultPhoneNumber', defaultFromNumber); 

                this.getAllFromPhoneNumbers(component, event, helper);

            } else {
                // Failure
                this.getAllFromPhoneNumbers(component, event, helper);
                component.set('v.isLoading', false);
                this.logConsoleDebug('Error in getting default phoneneumber', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to Retrive default phone number : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(getDefaultPhoneNumber);
    },

    checkContactPointConsentStatus : function (component, event, helper) {
        var memberPhoneNumber = component.get('v.contactPhoneNumber');
        var virtualPhoneNumber = component.get('v.selectedPhoneNumber');
        var checkContactPointConsentStatus = component.get('c.checkContactPointConsentStatus');
        checkContactPointConsentStatus.setParams({
            "memberPhoneNumber": memberPhoneNumber,
            "virtualPhoneNumber": virtualPhoneNumber
        });
        //getting the response from the apex class
        checkContactPointConsentStatus.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // component.set('v.isLoading', false);
                var contactPointConsentStatus = response.getReturnValue();
                component.set('v.memberConsentStatus', contactPointConsentStatus); 
                if(contactPointConsentStatus == 'Opt Out'){
                    component.set('v.isMemberOptedOut', true); 
                } else {
                    component.set('v.isMemberOptedOut', false); 
                }
                var contactName = component.get("v.contactName");
                var selectedPhoneNumber = component.get("v.selectedPhoneNumber");
                var Opt_Out_Warning_Message = $A.get("$Label.c.Opt_Out_Warning_Message");
                Opt_Out_Warning_Message = Opt_Out_Warning_Message.replace("{!0}", contactName);
                Opt_Out_Warning_Message = Opt_Out_Warning_Message.replace("{!1}", selectedPhoneNumber);
                component.set("v.Opt_Out_Warning_Message", Opt_Out_Warning_Message);

            } else {
                // Failure
                // component.set('v.isLoading', false);
                this.logConsoleDebug('Error in getting checkContactPointConsentStatus', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to checkContactPointConsentStatus : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(checkContactPointConsentStatus);
    },

    navigateToInboxFromPOS : function (component, event) {
        this.logConsoleDebug('navigateToInboxFromPOS', 'log');

        var componentUniqueName = component.get('v.componentUniqueName');
        //Send Event to ChatBot Component to show ChatBot
        var eventName = 'showChatBot';
        var eventSource = 'ChatBotMemberConversation';
        var eventAction = 'showChatBot';
        this.fireApplicationEventCallWithParams('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'{"eventName":"' + eventName + '","eventSource":"' + eventSource + '","eventAction":"' + eventAction + '","groupName":"' + componentUniqueName + '"}' } );

        // var setIntervalId = component.get("v.setIntervalId");
        // if( (setIntervalId == undefined) || (setIntervalId == null) || (setIntervalId == "") ){
        //     this.startTimer(component,event, helper);
        // } 
        component.set('v.showPosContainer' , false);
        component.set('v.activityid',"");
    },

    navigateToInboxFromScheduler : function (component, event) {
        this.logConsoleDebug('navigateToInboxFromScheduler', 'log');

        var componentUniqueName = component.get('v.componentUniqueName');
        //Send Event to ChatBot Component to show ChatBot
        var eventName = 'showChatBot';
        var eventSource = 'ChatBotMemberConversation';
        var eventAction = 'showChatBot';
        this.fireApplicationEventCallWithParams('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'{"eventName":"' + eventName + '","eventSource":"' + eventSource + '","eventAction":"' + eventAction + '","groupName":"' + componentUniqueName + '"}' } );
        
        // var setIntervalId = component.get("v.setIntervalId");
        // if( (setIntervalId == undefined) || (setIntervalId == null) || (setIntervalId == "") ){
        //     this.startTimer(component,event, helper);
        // } 
        component.set('v.ShowScheduling' , false);
        component.set('v.activityid',"");
        this.logConsoleDebug('selectedContactRecord ' + component.get('v.selectedContactRecord'), 'log'); 
        this.logConsoleDebug(component.get('v.selectedContactRecord'), 'table');  
    }

})