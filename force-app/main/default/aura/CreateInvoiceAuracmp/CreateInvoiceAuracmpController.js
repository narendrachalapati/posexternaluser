({
	onInit : function(component, event, helper) {
		helper.GettingProjectinfohelper(component);
	},
	Createinvoicehandler : function(component, event, helper) {
		helper.CreatingInvoiceRecordHelper(component);
		
	},
	onEnterAmount: function (component, event) {
		var key = event.which || event.keyCode;
		console.log(key);
		if (key >= 48 && key <= 57) {
	    component.set('v.Amount',event.target.value);
        console.log(event.target.value);
		var Amount = component.get('v.Amount');
        var Invoicedate = component.get('v.Invoicedate');
        var Description = component.get('v.Description');
		if(Amount!=null && Amount!='' && Invoicedate!=null && Invoicedate!='' && Description !=null && Description!=''){
			component.set('v.ButtonEnable',true);
		}else{
			component.set('v.ButtonEnable',false);
		}
	
}
	},
	onEnterAmountchange: function (component, event) {
		
        component.set('v.Amount',event.target.value);
		console.log(event.target.value);
		var Amount = component.get('v.Amount');
        var Invoicedate = component.get('v.Invoicedate');
        var Description = component.get('v.Description');
		if(Amount!=null && Amount!='' && Invoicedate!=null && Invoicedate!='' && Description !=null && Description!=''){
			component.set('v.ButtonEnable',true);
		}else{
			component.set('v.ButtonEnable',false);
		}
	},
	onEnterDate: function (component, event) {
        component.set('v.Invoicedate',event.target.value);
		console.log(event.target.value);
		var Amount = component.get('v.Amount');
        var Invoicedate = component.get('v.Invoicedate');
        var Description = component.get('v.Description');
		if(Amount!=null && Amount!='' && Invoicedate!=null && Invoicedate!='' && Description !=null && Description!=''){
			component.set('v.ButtonEnable',true);
		}else{
			component.set('v.ButtonEnable',false);
		}
	},
	onEnterDescription: function (component, event) {

        component.set('v.Description',event.target.value);
		var Amount = component.get('v.Amount');
        var Invoicedate = component.get('v.Invoicedate');
        var Description = component.get('v.Description');
		if(Amount!=null && Amount!='' && Invoicedate!=null && Invoicedate!='' && Description !=null && Description!=''){
			component.set('v.ButtonEnable',true);
		}else{
			component.set('v.ButtonEnable',false);
		}
	}
})