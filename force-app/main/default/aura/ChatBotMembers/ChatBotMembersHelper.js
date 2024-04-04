({
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

    //Get Screen Height
    fetchScreenHeight: function () {
        var viewportheight;
        // oneHeader oneAppNavContainer
        // the more standards compliant browsers (mozilla/netscape/opera/IE7) use window.innerWidth and window.innerHeight
        if (typeof window.innerWidth != 'undefined') {
            viewportheight = window.innerHeight
        }

        // IE6 in standards compliant mode (i.e. with a valid doctype as the first line in the document)
        else if (typeof document.documentElement != 'undefined' && typeof document.documentElement.clientWidth != 'undefined' && document.documentElement.clientWidth != 0) {
            viewportheight = document.documentElement.clientHeight
        }

        // older versions of IE
        else {
            viewportheight = document.getElementsByTagName('body')[0].clientHeight
        }
        this.logConsoleDebug('*** ' + 'viewportheight' + ' *** ' + viewportheight, 'log');
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

    //Fire Application Event
    fireApplicationEventCallWithParams: function (eventControllerName, params) {
        try {
            var appEvent = $A.get('e.c:' + eventControllerName);
            appEvent.setParams(params);
            this.logConsoleDebug('*** ' + 'Sending messagedata' + ' *** ' + params, 'log');
            this.logConsoleDebug('*** ' + 'Sending application event' + ' *** ' + eventControllerName, 'log');
            appEvent.fire();
            this.logConsoleDebug('*** ' + 'Sent application event successfully' + ' *** ' + eventControllerName, 'log');
        } catch (e) {
            console.log('Excepetion Got ' + e);
        }
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
            var latestActivityNum = component.get('v.SelectedLatestActivityNum');
            latestActivityNum = ((latestActivityNum != undefined) && (latestActivityNum != null)) ? latestActivityNum : 0.0;
            this.logConsoleDebug('Parameter to send latestActivityNum is: ' + latestActivityNum, 'log');
            
            var contactPhoneNumber = component.get('v.SelectedContactPhone');
            contactPhoneNumber = ((contactPhoneNumber == undefined) || (contactPhoneNumber == null) || (contactPhoneNumber == '')) ? '' : contactPhoneNumber;
            var recordId = component.get('v.SelectedRecordId');
            recordId = ((recordId == undefined) || (recordId == null) || (recordId == '')) ? '' : recordId;

            this.fireApplicationEventCall('InboxApplicationEvent', false, componentUniqueName, 'contactSearch', '', latestActivityNum, contactPhoneNumber, recordId);
            // this.fireApplicationEventCallWithParams('componentCommunicationEvent', { "aurcomponentname": 'ChatBotMembers', "componentUniqueName": componentUniqueName, "showLoader": false, "controllermethod": 'contactserch', "searchkey": '', "storedActivityNumber": latestActivityNum, "currentContactId": currentContactId });            
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
            
    //Fetch Contact with Latest message
    searchContacts : function (component, event, helper) {
        var componentUniqueName = component.get('v.componentUniqueName');
        var searchText = component.get('v.searchText');
        var storedActivityNumber = component.get('v.SelectedLatestActivityNum');
        storedActivityNumber = ((storedActivityNumber != undefined) && (storedActivityNumber != null)) ? storedActivityNumber : 0.0;
        var currentRecordId = component.get('v.SelectedRecordId');
        currentRecordId = ((currentRecordId == undefined) || (currentRecordId == null) || (currentRecordId == '')) ? '' : currentRecordId;
        var contactPhoneNumber = component.get('v.SelectedContactPhone');
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
            //alert('state'+response.getState());
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
})