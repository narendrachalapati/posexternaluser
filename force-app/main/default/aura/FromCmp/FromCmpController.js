({
    doinit : function(component, event, helper) {

        helper.getAllFromPhoneNumbers(component, event, helper);
        let selectedNumber = component.get('v.selectedNumber');
        if(!selectedNumber)
            helper.getDefaultPhoneNumber(component, event, helper);
    },

    selectedNumberChange : function(component, event, helper) {
        helper.getAllFromPhoneNumbers(component, event, helper);
    },

    handlePhoneNumber: function(component, event, helper) {
        let fromNumber = component.find('select-from-number').get('v.value');

        helper.childComponentEvent(component, event, helper, fromNumber);
        helper.logConsoleDebug('selected number change' + fromNumber, 'log');
    }
})