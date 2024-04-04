({
	doInit : function(component, helper) {
        var sobject = component.get('v.object');
        var fieldName = component.get('v.fieldName');
       	component.set("v.fieldValue", sobject[fieldName]);
        component.set("v.Id", sobject.Id);
    },
    onSelect : function(component, event, helper) {
        var event = component.getEvent('select');
        event.setParams({
            'clicked-search-result': component.get('v.object')
        });
        event.fire();
    }
})