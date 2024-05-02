({
        
        MAX_FILE_SIZE: 4000000, //Max file size 4.5 MB 
        CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
         
        uploadHelper: function(component, event) {
            // get the selected files using aura:id [return array of files]
            var fileInput = component.find("fuploader").get("v.files");
            // get the first file using array index[0]  
            var file = fileInput[0];
            var self = this;
            // check the selected file size, if select file size greter then MAX_FILE_SIZE,
            // then show a alert msg to user,hide the loading spinner and return from function  
            if (file.size > self.MAX_FILE_SIZE) {
                component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
                return;
            }
             
            // create a FileReader object 
            var objFileReader = new FileReader();
            // set onload function of FileReader object   
            objFileReader.onload = $A.getCallback(function() {
                var fileContents = objFileReader.result;
                var base64 = 'base64,';
                var dataStart = fileContents.indexOf(base64) + base64.length;
               
                fileContents = fileContents.substring(dataStart);
                // call the uploadProcess method 
                self.uploadProcess(component, file, fileContents);
            });
             
            objFileReader.readAsDataURL(file);
        },
         
        uploadProcess: function(component, file, fileContents) {
            // set a default size or startpostiton as 0 
            var startPosition = 0;
            // calculate the end size or endPostion using Math.min() function which is return the min. value   
          // var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        var endPosition = Math.max(fileContents.length, startPosition + this.CHUNK_SIZE);
            // start with the initial chunk, and set the attachId(last parameter)is null in begin
            this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
        },
         
         
        uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
            // call the apex method 'SaveFile'
            var getchunk = fileContents.substring(startPosition, endPosition);
            var action = component.get("c.GdriveFileupload");
            var base64mod = 'data:'+file.type +';base64,'+ encodeURIComponent(getchunk);
            component.set('v.Contenttype',file.type);
            var Contenttype = file.type;
            console.log('Contenttype' + Contenttype);
            this.imagepreview(component,Contenttype);
            console.log('encodeURIComponent(getchunk)NDR' + base64mod);
            action.setParams({
                RecordId: component.get("v.recordId"),
                accountMergeField:  component.get('v.AccountField'),
                Tittle: file.name,
                base64Data: encodeURIComponent(getchunk),
                contentType: file.type,
               // fileId: attachId
            });
             
            // set call back 
            action.setCallback(this, function(response) {
                // store the response / Attachment Id   
                attachId = response.getReturnValue();
               
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('attachId' + attachId);
                    console.table(attachId);
                    component.set('v.Downloadlink',attachId.DownloadLink__c);
                    component.set('v.previewlink',attachId.ThumbnailLink__c);
                    // update the start position with end postion
                    startPosition = endPosition;
                    endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

                    // check if the start postion is still less then end postion 
                    // then call again 'uploadInChunk' method , 
                    // else, diaply alert msg and hide the loading spinner
                    if (startPosition < endPosition) {
                        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                    } else {
                      //  alert('File has been uploaded successfully');
                    }
                    // handel the response errors        
                } else if (state === "INCOMPLETE") {
                   // alert("From server: " + response.getReturnValue());
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            // enqueue the action
            $A.enqueueAction(action);
        },
        imagepreview: function(component,Contenttype) {
            var image = component.get('v.imageicon');
            var Doc = component.get('v.Docicon');
            var file = component.get('v.fileicon');
            var imageurl = component.get('v.base64');
            console.log('imageurl ' + imageurl);
             if (Contenttype === 'image/jpeg' || Contenttype === 'image/gif' || Contenttype === 'image/png' || Contenttype === 'image/jpg') {
                 if(imageurl != null){
                     component.set('v.imagepreview',imageurl);
                 }else{
                    component.set('v.imagepreview',image); 
                 }
                 console.log(component.get('v.imageicon'));
               } else if (Contenttype ==='application/msword') {
                 component.set('v.imagepreview',Doc);
                 console.log(component.get('v.imagepreview'));
               } else {
                 component.set('v.imagepreview',file);
                 console.log(component.get('v.imagepreview'));
               }
               
         },
           EditHelper: function(component, event) {
            // get the selected files using aura:id [return array of files]
            var fileInput = component.find("fEdit").get("v.files");
            // get the first file using array index[0]  
            var file = fileInput[0];
            var self = this;
            // check the selected file size, if select file size greter then MAX_FILE_SIZE,
            // then show a alert msg to user,hide the loading spinner and return from function  
            if (file.size > self.MAX_FILE_SIZE) {
                component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
                return;
            }
             
            // create a FileReader object 
            var objFileReader = new FileReader();
            // set onload function of FileReader object   
            objFileReader.onload = $A.getCallback(function() {
                var fileContents = objFileReader.result;
                var base64 = 'base64,';
                var dataStart = fileContents.indexOf(base64) + base64.length;
               
                fileContents = fileContents.substring(dataStart);
                // call the uploadProcess method 
                self.Editprocess(component, file, fileContents);
            });
             
            objFileReader.readAsDataURL(file);
        },
     Editprocess: function(component, file, fileContents) {
            // set a default size or startpostiton as 0 
            var startPosition = 0;
            // calculate the end size or endPostion using Math.min() function which is return the min. value   
            var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
             
            // start with the initial chunk, and set the attachId(last parameter)is null in begin
            this.EditInChunk(component, file, fileContents, startPosition, endPosition, '');
        },
            
    EditInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
            // call the apex method 'SaveFile'
            var getchunk = fileContents.substring(startPosition, endPosition);
            var googlefileid = component.get("v.googlefilerecid");
            console.log('googlefileid' + googlefileid);
            var action = component.get("c.EditFile_g");
            var base64mod = 'data:'+file.type +';base64,'+ encodeURIComponent(getchunk);
            component.set('v.Contenttype',file.type);
            var Contenttype = file.type;
            console.log('Contenttype' + Contenttype);
            this.imagepreview(component,Contenttype);
            console.log('encodeURIComponent(getchunk)NDR' + base64mod);
            action.setParams({
                googlefileid: googlefileid,
                Tittle: file.name,
                base64Data: encodeURIComponent(getchunk),
                contentType: file.type,
               // fileId: attachId
            });
             
            // set call back 
            action.setCallback(this, function(response) {
                // store the response / Attachment Id   
                attachId = response.getReturnValue();
               
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('attachId' + attachId);
                    console.table(attachId);
                    component.set('v.Downloadlink',attachId.DownloadLink__c);
                    component.set('v.previewlink',attachId.ThumbnailLink__c);
                    // update the start position with end postion
                    startPosition = endPosition;
                    endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

                    // check if the start postion is still less then end postion 
                    // then call again 'uploadInChunk' method , 
                    // else, diaply alert msg and hide the loading spinner
                    if (startPosition < endPosition) {
                        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                    } else {
                      //  alert('File has been uploaded successfully');
                    }
                    // handel the response errors        
                } else if (state === "INCOMPLETE") {
                   // alert("From server: " + response.getReturnValue());
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            // enqueue the action
            $A.enqueueAction(action);
        },
    })