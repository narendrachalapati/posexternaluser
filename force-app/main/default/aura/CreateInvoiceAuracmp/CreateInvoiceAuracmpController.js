({
	onInit : function(component, event, helper) {
		helper.GettingProjectinfohelper(component);
        //setting the current date for the invoice date
		const today = new Date();
        const dd = String(today.getDate()).padStart(2, '0'); // Day
        const mm = String(today.getMonth() + 1).padStart(2, '0'); // Month (January is 0)
        const yyyy = today.getFullYear(); // Year
        const formattedDate =  yyyy + '-' + mm + '-' + dd;
		var duedate =Number(dd) + 10;
		const formattedDueDate =  duedate + '-'+mm + '-' + yyyy ;
        component.set("v.Invoicedate", formattedDate);
		component.set("v.Duedate", formattedDueDate);
        console.log('invociedate' + component.get('v.Invoicedate'));
		
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
	onEnterDate: function (component, event,helper) {
        component.set('v.Invoicedate',event.target.value);
		console.log(event.target.value);
		var Amount = component.get('v.Amount');
		var Invoicedate = new Date(component.get('v.Invoicedate'));
		var Description = component.get('v.Description');
		var DueDate = new Date(Invoicedate);
		DueDate.setDate(DueDate.getDate() + 10);
	// Format the date as "dd-mm-yyyy"
        var day = DueDate.getDate().toString().padStart(2, '0');
        var month = (DueDate.getMonth() + 1).toString().padStart(2, '0'); // Months are zero-based
        var year = DueDate.getFullYear();

        var formattedDueDate = day + '-' + month + '-' + year;
		component.set('v.Duedate', formattedDueDate);
		console.log('DueDateNDR ' + formattedDueDate);
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
		console.log(Description);
		if(Amount!=null && Amount!='' && Invoicedate!=null && Invoicedate!='' && Description !=null && Description!=''){
			component.set('v.ButtonEnable',true);
		}else{
			component.set('v.ButtonEnable',false);
		}
	},
	 // Function to chain the above promises
	 FinalInvoicehandling : function(component, event, helper) {
		var createInvoiceRecordPromise = helper.createInvoiceRecord(component);
		createInvoiceRecordPromise
		.then($A.getCallback(function(invoiceRecord) {
                console.log(invoiceRecord);
                // After successful invoice creation, make the synchronous callout
                return helper.makeSynchronousCallout(component);
            }))
			.then($A.getCallback(function(sobjectrec) {
                console.log(sobjectrec);
                // After successful invoice creation, make the synchronous callout
                return helper.makeSynchronousEmailCallout(component);
            }))
            .then($A.getCallback(function(Sysobjectrec) {
                console.log(Sysobjectrec);
                // Handle additional success actions
            }))
            .catch($A.getCallback(function(error) {
                console.error(error);
                // Handle any errors that occurred during the operations
            }));
    },
	Projectchange: function (component, event, helper) {
		let selectedValue = event.getSource().get("v.value");
        console.log("Selected Value: " + selectedValue);
		component.set('v.selectedProjectId',selectedValue);
		helper.GettingselectedProject(component,selectedValue);
	},
	onChange: function (cmp, evt, helper) {
	   //alert(cmp.find('term').get('v.value') + ' pie is good.');
	   var  selectedterm = cmp.find('term').get('v.value');
	   console.log('selectedtermNDR' + selectedterm);
	   cmp.set('v.Selectedterm',selectedterm);
	   var invoicedate = cmp.get('v.Invoicedate');
		console.log('invoicedateNDR' + invoicedate);
	   if(selectedterm==5){
		var duedate = helper.dueDatePreparation(invoicedate,10);
		cmp.set('v.Duedate',duedate);
        console.log(duedate);
	   }
	   if(selectedterm==1){
		var duedate = helper.dueDatePreparation(invoicedate,0);
		cmp.set('v.Duedate',duedate);
        console.log(duedate);
	   }
	   if(selectedterm==2){
		var duedate = helper.dueDatePreparation(invoicedate , 15);
		cmp.set('v.Duedate',duedate);
        console.log(duedate);
	   }
	   if(selectedterm==3){
		var duedate = helper.dueDatePreparation(invoicedate,30);
		cmp.set('v.Duedate',duedate);
        console.log(duedate);
	   }
	   if(selectedterm==4){
		var duedate = helper.dueDatePreparation(invoicedate,60);
		cmp.set('v.Duedate',duedate);
        console.log(duedate);
	   }
	
	},

})