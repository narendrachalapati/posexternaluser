({
    productoptionsclick : function(component, event, selectedproductId, selectedproductOptionId, IsOptionSelection) {
        console.log('helper crossed');
        var logApiResponses = true;
        var selectedItem = event.currentTarget;
        var selectedProdId = (selectedproductOptionId == '') ? selectedItem.dataset.id : selectedproductOptionId; // Selected Product Id
        console.log('selectedProdId' + selectedProdId);
        let currentselectedProdElement ;
        if (IsOptionSelection) {
            currentselectedProdElement = document.querySelector('[data-optionid="' + selectedProdId + '"]');
            console.log('currentselectedProdElement' + currentselectedProdElement);
            console.table(currentselectedProdElement);
        } else {
            currentselectedProdElement = document.querySelector('[data-id="' + selectedproductId + '"]');
        }
       

         var message = 'Product Added Successfully';
        //Check if Order is Still Active or Closed
        var orderUUID = component.get("v.orderUUID");
        var checkOrderisOpenaction = component.get('c.getOrderDetails');
        checkOrderisOpenaction.setParams({
            "orderIdOrUUID" : orderUUID,
        });
        checkOrderisOpenaction.setCallback(this,function(response){
            var state = response.getState();
            if(state != 'SUCCESS'){
                console.log('Failed checkOrderisOpenaction ');
                component.redirectToHome();
            }
        });
        $A.enqueueAction(checkOrderisOpenaction);

        //Fetch All Product Options Map 
        var tempAllProductsMap = new Map( Object.entries( component.get('v.allProductsMap') ) );
        
        // Log All Products Map Data
        if (logApiResponses) { console.log('Init v.allProductsMap '); }
        if (logApiResponses) { console.table( tempAllProductsMap ); }

        var selectedproduct = tempAllProductsMap.get(selectedproductId);
        console.log('selectedproduct' + selectedproduct);
        var selectedprodoptions = new Map(Object.entries(selectedproduct.productMapOptionsWrapper));
        var SelectedProductFilteredOptionsMap = new Map(Object.entries(selectedprodoptions.get(selectedproductId)));


        //Fetch Current Selected Products Options Map
        var tempSelectedProductsMap = new Map(component.get('v.selectedProductsMap'));
        //Get Selected Product Option Initial Data from  All Product Options Map
        var currentSelectedProductFromDataMap = SelectedProductFilteredOptionsMap.get(selectedProdId);
        //Store Selected Product Stock
        var selectedProdStock = 0;
        // Log Selected Products Data
        if (logApiResponses) { console.log('Init selectedProdId ' + selectedProdId); }
        if (logApiResponses) { console.table(currentSelectedProductFromDataMap); }

        if(tempSelectedProductsMap.has(selectedProdId) ){ 
            var previousSelectedProductFromDataMaptemp = tempSelectedProductsMap.get(selectedProdId);
            selectedProdStock = previousSelectedProductFromDataMaptemp.availableStockQuantity - previousSelectedProductFromDataMaptemp.quantity;
        }else{
            selectedProdStock = currentSelectedProductFromDataMap.availableStockQuantity;
        }

        //Mark Product Not Available
        if(selectedProdStock <= 1){
            if((selectedproductOptionId !== '') && (selectedproductOptionId !== null) && (selectedproductOptionId !== undefined) ){
                
                var Inactiveprodoptions =component.get('v.Inactiveprodoptions');
                
                var prodoptioncheck = Inactiveprodoptions.includes(selectedproductOptionId);
                console.log('prodoptioncheck ' + prodoptioncheck);
                if(prodoptioncheck != true){
                    Inactiveprodoptions.push(selectedproductOptionId);
                    console.log('Inactiveprodoptions'+Inactiveprodoptions);
                    component.set("v.Inactiveprodoptions", Inactiveprodoptions);
                }
            }
            currentselectedProdElement.classList.add("inactiveProduct");
        }else{
             if(currentselectedProdElement.classList.contains("inactiveProduct")) {
                 currentselectedProdElement.classList.remove("inactiveProduct");
            }            
        }
        
        //Show Out of stock message
        if(selectedProdStock <= 0){
            component.displayMessage('Error', 'Product was Out of Stock ', 'Error','dismissible');
            return;
        }


        if(tempSelectedProductsMap.has(selectedProdId) ){ 
            var previousSelectedProductFromDataMap = tempSelectedProductsMap.get(selectedProdId);
            var productQuantity = previousSelectedProductFromDataMap.quantity + 1;
            var singleProductPrice = previousSelectedProductFromDataMap.product.Option_Total_Price__c;
            var netUnitPrice = singleProductPrice * productQuantity;
            currentSelectedProductFromDataMap.quantity = productQuantity;
            currentSelectedProductFromDataMap.productPrice = singleProductPrice;
            currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;
            tempSelectedProductsMap.set(selectedProdId, currentSelectedProductFromDataMap ); 
            if (logApiResponses) { console.log('Inside else if has exist in cart selectedProductsMap '); }
        } else{
            var productQuantity = 1;
            var singleProductPrice = currentSelectedProductFromDataMap.product.Option_Total_Price__c;
            var netUnitPrice = singleProductPrice * productQuantity ;
            currentSelectedProductFromDataMap.quantity = productQuantity;
            currentSelectedProductFromDataMap.productPrice = singleProductPrice;
            currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;
            tempSelectedProductsMap.set(selectedProdId, currentSelectedProductFromDataMap ); 
            if (logApiResponses) { console.log('Inside else new product add to selectedProductsMap '); }
        }
        console.log('tempSelectedProductsMap');
		console.table(tempSelectedProductsMap);
        component.set('v.selectedProductsMap',tempSelectedProductsMap);

        var preprocessMapToObject= Object.fromEntries(tempSelectedProductsMap);
        var processedObjectToString = JSON.stringify(preprocessMapToObject);       

        component.fireApplicationEventCall('posCommunicationEvent' , message, processedObjectToString );
      
    },
    OrderReapethandler : function(component, event, selectedproductId, selectedproductOptionId, IsOptionSelection, quantity) {
        console.log(' OrderReapethandler helper crossed');
        var logApiResponses = true;
        var selectedItem = event.currentTarget;
        var selectedProdId = (selectedproductOptionId == '') ? selectedItem.dataset.id : selectedproductOptionId; // Selected Product Id
        console.log('selectedProdId' + selectedProdId);
        let currentselectedProdElement ;
        if (IsOptionSelection) {
            currentselectedProdElement = document.querySelector('[data-optionid="' + selectedProdId + '"]');
            console.log('currentselectedProdElement' + currentselectedProdElement);
            console.table(currentselectedProdElement);
        } else {
            currentselectedProdElement = document.querySelector('[data-id="' + selectedproductId + '"]');
        }
       

         var message = 'Product Added Successfully';
        //Check if Order is Still Active or Closed
        var orderUUID = component.get("v.orderUUID");
        var checkOrderisOpenaction = component.get('c.getOrderDetails');
        checkOrderisOpenaction.setParams({
            "orderIdOrUUID" : orderUUID,
        });
        checkOrderisOpenaction.setCallback(this,function(response){
            var state = response.getState();
            if(state != 'SUCCESS'){
                console.log('Failed checkOrderisOpenaction ');
                component.redirectToHome();
            }
        });
        $A.enqueueAction(checkOrderisOpenaction);

        //Fetch All Product Options Map 
        var tempAllProductsMap = new Map( Object.entries( component.get('v.allProductsMap') ) );
        
        // Log All Products Map Data
        if (logApiResponses) { console.log('Init v.allProductsMap '); }
        if (logApiResponses) { console.table( tempAllProductsMap ); }

        var selectedproduct = tempAllProductsMap.get(selectedproductId);
        console.log('selectedproduct' + selectedproduct);
        var selectedprodoptions = new Map(Object.entries(selectedproduct.productMapOptionsWrapper));
        var SelectedProductFilteredOptionsMap = new Map(Object.entries(selectedprodoptions.get(selectedproductId)));


        //Fetch Current Selected Products Options Map
        var tempSelectedProductsMap = new Map(component.get('v.selectedProductsMap'));
        //Get Selected Product Option Initial Data from  All Product Options Map
        var currentSelectedProductFromDataMap = SelectedProductFilteredOptionsMap.get(selectedProdId);
        //Store Selected Product Stock
        var selectedProdStock = 0;
        // Log Selected Products Data
        if (logApiResponses) { console.log('Init selectedProdId ' + selectedProdId); }
        if (logApiResponses) { console.table(currentSelectedProductFromDataMap); }

        if(tempSelectedProductsMap.has(selectedProdId) ){ 
            var previousSelectedProductFromDataMaptemp = tempSelectedProductsMap.get(selectedProdId);
            selectedProdStock = previousSelectedProductFromDataMaptemp.availableStockQuantity - previousSelectedProductFromDataMaptemp.quantity;
        }else{
            selectedProdStock = currentSelectedProductFromDataMap.availableStockQuantity;
        }

        //Mark Product Not Available
        if(selectedProdStock <= 1){
            if((selectedproductOptionId !== '') && (selectedproductOptionId !== null) && (selectedproductOptionId !== undefined) ){
                
                var Inactiveprodoptions =component.get('v.Inactiveprodoptions');
                
                var prodoptioncheck = Inactiveprodoptions.includes(selectedproductOptionId);
                console.log('prodoptioncheck ' + prodoptioncheck);
                if(prodoptioncheck != true){
                    Inactiveprodoptions.push(selectedproductOptionId);
                    console.log('Inactiveprodoptions'+Inactiveprodoptions);
                    component.set("v.Inactiveprodoptions", Inactiveprodoptions);
                }
            }
           // currentselectedProdElement.classList.add("inactiveProduct");
        }else{
            // if(currentselectedProdElement.classList.contains("inactiveProduct")) {
            //     currentselectedProdElement.classList.remove("inactiveProduct");
            // }            
        }
        
        //Show Out of stock message
        if(selectedProdStock <= 0){
            component.displayMessage('Error', 'Product was Out of Stock ', 'Error','dismissible');
            return;
        }


        if(tempSelectedProductsMap.has(selectedProdId) ){ 
            var previousSelectedProductFromDataMap = tempSelectedProductsMap.get(selectedProdId);
            var productQuantity = parseInt(previousSelectedProductFromDataMap.quantity) + parseInt(quantity);
            var singleProductPrice = previousSelectedProductFromDataMap.product.Option_Total_Price__c;
            var netUnitPrice = singleProductPrice * productQuantity;
            currentSelectedProductFromDataMap.quantity = productQuantity;
            currentSelectedProductFromDataMap.productPrice = singleProductPrice;
            currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;
            tempSelectedProductsMap.set(selectedProdId, currentSelectedProductFromDataMap ); 
            if (logApiResponses) { console.log('Inside else if has exist in cart selectedProductsMap '); }
        } else{
            var productQuantity = 1;
            var singleProductPrice = currentSelectedProductFromDataMap.product.Option_Total_Price__c;
            var netUnitPrice = singleProductPrice * productQuantity ;
            currentSelectedProductFromDataMap.quantity = quantity;
            currentSelectedProductFromDataMap.productPrice = singleProductPrice;
            currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;
            tempSelectedProductsMap.set(selectedProdId, currentSelectedProductFromDataMap ); 
            if (logApiResponses) { console.log('Inside else new product add to selectedProductsMap '); }
        }
        console.log('tempSelectedProductsMap');
		console.table(tempSelectedProductsMap);
        component.set('v.selectedProductsMap',tempSelectedProductsMap);

        var preprocessMapToObject= Object.fromEntries(tempSelectedProductsMap);
        var processedObjectToString = JSON.stringify(preprocessMapToObject);       

        component.fireApplicationEventCall('posCommunicationEvent' , message, processedObjectToString );
      
    }
})