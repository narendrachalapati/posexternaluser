({
    doinit : function(component, event, helper) {
        helper.getAllSMSTemplates(component, event, helper);
        component.set('v.selectedTemplate', '');
    },

    idChange : function(component, event, helper) {
        helper.logConsoleDebug('id changed -'+ component.get('v.recordId'), 'log');
        helper.getAllSMSTemplates(component, event, helper);
        component.set('v.selectedTemplate', '');
    },

    sObjectApiNameChange : function(component, event, helper) {
        helper.logConsoleDebug('id changed -'+ component.get('v.sObjectApiName'), 'log');
        helper.getAllSMSTemplates(component, event, helper);
        component.set('v.selectedTemplate', '');
    },

    handleTemplateChange: function(component, event, helper) {
        let templateIndex = component.find('select-template').get('v.value');
        component.set('v.selectedTemplate', templateIndex);
        helper.logConsoleDebug('template index' + templateIndex +' recordId '+ component.get('v.recordId'), 'log');
        component.set('v.isLoading', true);
        let template = ( (templateIndex != "") && component.get('v.smsTemplates') && component.get('v.smsTemplates')[templateIndex]) ? component.get('v.smsTemplates')[templateIndex].body : '';
        helper.logConsoleDebug('template index' + templateIndex +' template '+ template, 'log');
        helper.getParsedBody(component, event, helper, template); 
    },

})