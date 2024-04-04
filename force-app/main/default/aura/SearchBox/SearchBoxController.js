({
    doInit: function (component, event, helper) {
        component.setDefaultState = function () {
            var defaultState = component.get("v.defaultState");
            component.set("v.selected", defaultState && defaultState['selected'] !== undefined ? defaultState['selected'] : false);
            component.set("v.searchText", defaultState && defaultState['searchText'] !== undefined ? defaultState['searchText'] : '');
            component.set("v.searchResult", undefined);
        };
        component.find("search-box").focus();
    },
    onEnterText: function (component, event, helper) {
        var action = component.get('c.search');
        action.setParams({
            objectType: component.get('v.sobject'),
            filterParams: component.get('v.filterParams'),
            searchText: component.get('v.searchText'),
            selectFields: component.get('v.selectFields'),
            searchOnField: component.get('v.searchOnField'),
            numRecords: component.get('v.numRecords')
        });
        action.setCallback(this, function (data) {
            var errors = data.getError();
            if (errors && Array.isArray(errors) && errors.length > 0) {
                if (failure) failure(errors[0].message);
                else alert('Failed to perform action!');
            } else {
                component.set('v.searchResult', data.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    onSelect: function (component, event, helper) {
        var sobject = event.getParam('clicked-search-result');
        component.set("v.selected", true);
        component.set("v.searchText", sobject[component.get('v.searchOnField')]);

        var triggerEvent = component.getEvent('select');
        triggerEvent.setParams({
            'search-result': sobject
        });
        triggerEvent.fire();
    },
    cancelSelection: function (component, event, helper) {
        if (component.get("v.selected")) {
            component.set("v.selected", false);
            component.set("v.searchText", '');
            component.set("v.searchResult", undefined);

            var triggerEvent = component.getEvent('select');
            triggerEvent.setParams({
                'search-result': undefined,
                'event': 'cancel-click'
            });
            triggerEvent.fire();
        }
    },
    lostFocus: function (component, event, helper) {
        setTimeout(function () {
            if (component.get('v.selected') === false) {
                component.setDefaultState();

                var triggerEvent = component.getEvent('select');
                triggerEvent.setParams({
                    'search-result': undefined,
                    'event': 'lost-focus'
                });
                triggerEvent.fire();
            }
        }, 100);
    }
});