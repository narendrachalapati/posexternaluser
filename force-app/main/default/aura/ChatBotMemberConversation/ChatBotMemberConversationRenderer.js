({
    unrender: function (component,helper) {
        this.superUnrender();
        window.clearInterval(component.get("v.setIntervalId"));
        component.set("v.setIntervalId","");
    }, 
})