({
    doint: function (component, event, helper) {
        component.set("v.isLoading", true);

        var recordId = component.get('v.recordId');
        var isAccountBasedMapper = component.get('v.isAccountBasedMapper');
        var getProductDetailsAction = component.get('c.getProductDetails');
        getProductDetailsAction.setParams({
            "productRecordId" : recordId
        });
        getProductDetailsAction.setCallback(this,function(response){
            var state = response.getState();
            if(state== 'SUCCESS'){
                component.set("v.isLoading", false);
                var productRecord = response.getReturnValue();
                component.set('v.productRecord',productRecord);
                try {
                    var accountRecordId = productRecord.Account__c;
                    component.set('v.accountRecordId', accountRecordId);
                    var GoogleBookingCalendarId = productRecord.Google_Booking_Calendar_Id__c;
                    component.set('v.selectedProductBookingCalendarId', GoogleBookingCalendarId);
                    var GoogleShiftCalendarId = productRecord.Google_Shift_Calendar_Id__c;
                    component.set('v.selectedProductShiftCalendarId', GoogleShiftCalendarId);
                    component.getCalendarsList();
                } catch (ex) {
                    helper.displayMessage('Exception!', 'Failed to Fetch Product Details Exception: Name: ' + ex.name + ' Message: ' + ex.message, 'error', 'dismissible');
                }
            }else{
                helper.logConsoleDebug('Failed to Fetch Product Details', 'log');
                var errors = response.getError();
                component.set("v.isLoading", false);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayMessage('Failure!', 'Failed to Fetch Product Details: '+errors[0].message, 'error','dismissible');
                    }
                }
                else{
                    helper.displayMessage('Failure!', 'Failed to Fetch Product Details: Unknown error', 'error','dismissible');
                }
            }
        });
        $A.enqueueAction(getProductDetailsAction);  

        component.getCalendarsList = function(){
            component.set("v.isLoading", true);
            // var recordId = component.get('v.recordId');
            var isAccountBasedMapper = component.get('v.isAccountBasedMapper');
            var accountRecordId = component.get('v.accountRecordId');
            var calendarsListAction = component.get('c.ListofCalendars'); 
            calendarsListAction.setParams({
                "isAccountBasedMapper" : isAccountBasedMapper,
                "accountRecordId" : accountRecordId,
            });
            calendarsListAction.setCallback(this, function (response) 
                {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        var calendarList = response.getReturnValue();
                        component.set('v.calendarList', calendarList);
                        var isBookingCalendarAssociated = false;
                        var isShiftCalendarAssociated = false;
                        var GoogleBookingCalendarId = component.get('v.selectedProductBookingCalendarId');
                        var GoogleShiftCalendarId = component.get('v.selectedProductShiftCalendarId');
                        if( (GoogleBookingCalendarId!= undefined) && (GoogleBookingCalendarId!= '') ){
                            calendarList.every(calendarRecord => {
                                if (calendarRecord.Google_Calendar_Id__c == GoogleBookingCalendarId) {
                                    isBookingCalendarAssociated = true;
                                    return false;
                                }
                                return true;
                            });
                        }
                        if( (GoogleShiftCalendarId!= undefined) && (GoogleShiftCalendarId!= '') ){
                            calendarList.every(calendarRecord => {
                                if (calendarRecord.Google_Calendar_Id__c == GoogleShiftCalendarId) {
                                    isShiftCalendarAssociated = true;
                                    return false;
                                }
                                return true;
                            });
                        }
                        helper.logConsoleDebug('isBookingCalendarAssociated ' + isBookingCalendarAssociated, 'log');
                        helper.logConsoleDebug('isShiftCalendarAssociated ' + isShiftCalendarAssociated, 'log');
                        component.set('v.isBookingCalendarAssociated', isBookingCalendarAssociated);
                        component.set('v.isShiftCalendarAssociated', isShiftCalendarAssociated);
                        component.set("v.isLoading", false);
                    } else {
                        var errors = response.getError();
                        component.set("v.isLoading", false);
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                helper.displayMessage('Failure!', 'Error in Loading Calendars : ' + errors[0].message, 'error', 'dismissible');
                            }
                        }
                    }
                });
            $A.enqueueAction(calendarsListAction);
        };

              
    },//INIT Handler End

    associateCalendarWithProduct: function(component, event, helper) {
        component.set("v.isLoading", true);
        var productId = component.get('v.recordId');
        var ctarget = event.currentTarget;
        var calendarType = ctarget.dataset.calendartype;
        var calendarId = ctarget.dataset.calendarid;
        var calendarSysKey = ctarget.dataset.calendarkey;

        var updateProductWithCalendarKeyAction = component.get('c.updateProductWithCalendarKey');
        updateProductWithCalendarKeyAction.setParams({
            calendarType: calendarType,
            productId: productId,
            calendarSysKey: calendarSysKey,
            calendarId: calendarId
        });
        updateProductWithCalendarKeyAction.setCallback(this, function (response) 
        {
            var state = response.getState(); 
            if (state === 'SUCCESS') {
                var productRecord = response.getReturnValue();
                component.set('v.productRecord',productRecord);
                component.set('v.selectedProductBookingCalendarId', productRecord.Google_Booking_Calendar_Id__c);
                component.getCalendarsList();
                helper.displayMessage('Success!', productRecord.Name + ' was Successfully linked to Calendar ', 'Success', 'dismissible');
                component.set("v.isLoading", false);
                //Refresh View
                $A.get('e.force:refreshView').fire();
                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } else {
                var errors = response.getError();
                component.set("v.isLoading", false);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayMessage('Failure!', 'Failed to Link Product with Calendar : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }

        });
        $A.enqueueAction(updateProductWithCalendarKeyAction);

    },
    
    CreateShiftCalendar: function(component, event, helper) {
        component.set("v.CreateCalendarTitle", "Create Shift Calendar");
        component.set("v.CalendarNamePrefix", "S-");
        component.set("v.CalendarType", "Shift Calendar");
        component.set("v.showCreateCalendar", true);
        component.set("v.showExistingCalendars", false);
    },

    CreateBookingCalendar: function(component, event, helper) {
        component.set("v.CreateCalendarTitle", "Create Booking Calendar");
        component.set("v.CalendarNamePrefix", "B-");
        component.set("v.CalendarType", "Booking Calendar");
        component.set("v.showCreateCalendar", true);
        component.set("v.showExistingCalendars", false);
    },

    hideCreateCalendar: function(component, event, helper) {
        component.set("v.showCreateCalendar", false);
        component.set("v.showExistingCalendars", true);
    },

    handleCreateCalendarSubmit: function (component, event, helper) {
        event.preventDefault(); // stop the form from submitting
        component.set("v.isLoading", true);
        var productId = component.get('v.recordId');
        var isAccountBasedMapper = component.get('v.isAccountBasedMapper');
        var accountRecordId = component.get('v.accountRecordId');
        var configTimeZone = component.get('v.productRecord.TimeZone__c');
        var calendarName = component.find("summary").get("v.value");
        if( (calendarName == undefined) || (calendarName == '') ){
            helper.displayMessage('Failure!', 'Please Enter Calendar Name', 'error', 'dismissible');
            component.set("v.isLoading", false);
            return;
        }
        var calenderNamePrefix = component.get("v.CalendarNamePrefix");
        calendarName = calenderNamePrefix + '' + calendarName;
        var calendarType = component.get("v.CalendarType");

        var createCustomCalendarAction = component.get('c.createCustomCalendar');
        createCustomCalendarAction.setParams({
            isAccountBasedMapper: isAccountBasedMapper,
            accountRecordId: accountRecordId,
            calendarName: calendarName,
            productId: productId,
            calendarType: calendarType,
            configTimeZone: configTimeZone
        });
        createCustomCalendarAction.setCallback(this, function (response) 
        {
            var state = response.getState(); 
            if (state === 'SUCCESS') {
                var newCustomCalendarResponse = response.getReturnValue();
                var customCalendarRecordId = newCustomCalendarResponse.Id;
                helper.logConsoleDebug('customCalendarRecordId ' + customCalendarRecordId, 'log');
                component.getCalendarsList();
                helper.displayMessage('Success!', calendarName + ' was Successfully Created', 'Success', 'dismissible');
                component.set("v.isLoading", false);
                component.set("v.showCreateCalendar", false);
                component.set("v.showExistingCalendars", true);
                //Refresh View
                $A.get('e.force:refreshView').fire();
                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } else {
                var errors = response.getError();
                component.set("v.isLoading", false);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayMessage('Failure!', 'Failed to Create new Calendar : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }

        });
        $A.enqueueAction(createCustomCalendarAction);
    },
})