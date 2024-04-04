({

// Your renderer method overrides go here
unrender: function (cmp,helper) {
    this.superUnrender();
    console.log('clear interval due to unrender');
    window.clearInterval(cmp.get("v.setIntervalId"));
    cmp.set("v.setIntervalId","");
}

})