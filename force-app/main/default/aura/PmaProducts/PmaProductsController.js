({
    onInit: function (component, event, helper) {
        var logApiResponses = true;
        component.set("v.Inactiveprodoptions", []);
        // component.set('v.isLoading',true);
        function initToaster() {
            toastr.options = {
                "closeButton": true,
                "newestOnTop": false,
                "progressBar": true,
                "positionClass": "toast-top-right",
                "preventDuplicates": true,
                "onclick": null,
                "showDuration": "300",
                "hideDuration": "1000",
                "timeOut": "5000",
                "extendedTimeOut": "1000",
                "showEasing": "swing",
                "hideEasing": "linear",
                "showMethod": "fadeIn",
                "hideMethod": "fadeOut"
            };
        }
        try{
            var bodyStyles = document.body.style;
            var screenHeight = window.screen.height;
            var gridSizeMaxHeight = screenHeight - 370;
            gridSizeMaxHeight = gridSizeMaxHeight - ( gridSizeMaxHeight % 205);
            bodyStyles.setProperty('--scroll-height', screenHeight+ 'px');
            bodyStyles.setProperty('--scroll-height-gridsize', gridSizeMaxHeight+ 'px');
        }catch(ex){
            console.log('Exception ' + ex);
            console.table(ex);
        }      

        component.redirectToHome = function () {
            var urlPath = '/'; //Invalid POS Member Open Tab
            component.displayMessage('Failure', 'POS Invalid or Expired Order..', 'Error','dismissible');
            var currentuserrec = component.get("v.userInfo");
            console.log('currentuserrec ' + currentuserrec);
            if( (currentuserrec!= undefined) || (currentuserrec != null) ){
                console.log('currentuserrec ' + currentuserrec.Contact.RecordType.Name);
                if( ( currentuserrec.Contact.RecordType.Name == 'Manager' ) ){
                    urlPath = '/search-members'; //Invalid POS Member Open Tab For Manager
                }
            }
            $A.get("e.force:navigateToURL").setParams({ 
                "url": urlPath 
             }).fire();   
        };
        
        component.fireApplicationEventCall = function (eventControllerName, message, processedObjectToString) {
            var appEvent = $A.get('e.c:' + eventControllerName);
            appEvent.setParams({
                "message" : message,
                "selectedproducts":processedObjectToString
            });
            if (logApiResponses) { console.log('*** ' + 'Sending messagedata' + ' *** ' + processedObjectToString ); }   
            if (logApiResponses) { console.log('*** ' + 'Sending application event' + ' *** ' + eventControllerName ); }   
            appEvent.fire();
            if (logApiResponses) { console.log('*** ' + 'Sent application event successfully' + ' *** ' + eventControllerName); } 
        };

        component.displayMessage = function (title, message, type, mode) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": mode,
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        };

        component.apiCall = function (controllerMethodName , params, success, failure) {
                       
            try {
                var action = component.get('c.' + controllerMethodName);
                Object.keys(params).forEach(key => {
                    if (params[key] === undefined) {
                        params[key] = '';
                    }
                });
                action.setParams(params);
                action.setCallback(this, function (data) {
                    if (logApiCallResponses) console.log(data.getError());
                    var errors = data.getError();
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        if (failure) {
                            failure(errors[0].message);
                        } else {
                            if (logApiCallResponses) {
                                console.log(errors);
                            }
                        }
                    } else {
                        
                        if (logApiCallResponses) console.log(data.getReturnValue());
                        if (success) success(data.getReturnValue());
                    }
                });
                $A.enqueueAction(action);
            } catch (error) {
                
                failure(error);
            }
        };

        component.checkCatagoryAvailability = function (arraytoSearch, serachVal) {
            return arraytoSearch.some(function(arrVal) {
              return serachVal === arrVal;
            });
        };

        component.resetCategoriesFilter = function (){
            component.set('v.selectedCategoryId', 'All');
            component.set('v.selectedCategoryname', 'All');
            component.set('v.searchText', '');
            var allCategoriesData = component.get('v.allCategoriesData');
            var newselectedCategoryData = allCategoriesData.filter(function (category) {
                return category.Catalog__c == null;
            });
            component.set('v.selectedCategoryData',newselectedCategoryData);
            var productData = component.get('v.productData');//Fetch all Products List

            component.set('v.selectedProductsData',productData);

            
};

        component.refreshCategoriesFilter = function (selectedcategoryid, selectedCategoryname){
            var categorylevelfilter = 'root';
            component.set('v.selectedCategoryId' , selectedcategoryid);
            component.set('v.selectedCategoryname' , selectedCategoryname);
    
            var allCategoriesData = component.get('v.allCategoriesData');
            var productData = component.get('v.productData');//Fetch all Products List
            let getAllRelatedCategories = [];
    
            if(selectedcategoryid != 'All'){
                var selectedCategoriesData = allCategoriesData.filter(function (category) {
                    return (category.Catalog__c == selectedcategoryid );
                });
                if(selectedCategoriesData.length > 0){
                    component.set('v.selectedCategoryData',selectedCategoriesData);
                    categorylevelfilter = ( selectedcategoryid == selectedCategoriesData[0].Catalog__c ) ? 'childroot' : 'child' ; 
                }
                //TODO Match upto n Levels Depth
                // For Root Catagory Able to Store all Related Categories
                getAllRelatedCategories.push(selectedcategoryid);
                for (let i = 0; i < allCategoriesData.length; i++) {
                    if (allCategoriesData[i].Catalog__c == selectedcategoryid) {
                        getAllRelatedCategories.push(allCategoriesData[i].Id);
                    }
                }
    
            }else{
                component.resetCategoriesFilter();
            }
    
            if(selectedcategoryid != 'All'){//Check if Any Category Filtered Applied or Not
                var selectedProductsData = new Array();
                console.log('categorylevelfilter ' + categorylevelfilter);
                if(categorylevelfilter == 'childroot'){
                    selectedProductsData = productData.filter(function (prodOption) {
                        console.log('prodOptionNDR'+prodOption);
                        var isRelatedCategory = component.checkCatagoryAvailability(getAllRelatedCategories, prodOption.baseproduct.Catalog__c);
                        return (  isRelatedCategory == true );
                    });
                }else{
                    selectedProductsData = productData.filter(function (prodOption) {
                        return ( prodOption.baseproduct.Catalog__c == selectedcategoryid );
                    });
                }
                component.set('v.selectedProductsData',selectedProductsData);
            }else{
                component.set('v.selectedProductsData',productData);
            }
        };

        component.reloadProductsandCatagoryCache = function (){
            var selectedCategoryId = component.get('v.selectedCategoryId');
            var selectedCategoryname = component.get('v.selectedCategoryname');
            var orderUUID = component.get("v.orderUUID"); 
            var isproductsdata = component.get("v.productsfromcontactserch");
            console.log('isproductsdata' + isproductsdata);
        if(isproductsdata==false){

       
            //Fetch all Products Option Data
            var action = component.get("c.getAllProductRecords");
            action.setParams({
                "orderIdOrUUID" : orderUUID,
            });
            action.setCallback(this, function (response) {
                //Init Map
               var state = response.getState();
               if (state == "SUCCESS") {
                   // Init() Map of <Id, Wrapper> Onetime Load From Database
                   var allProductsMap = response.getReturnValue();
                    component.set('v.allProductsMap',allProductsMap);
                    //For Aura attribute Iterate for UI
                    let productObjectData = Object.values(allProductsMap);
                    component.set('v.productData',productObjectData);
                    component.set('v.selectedProductsData',productObjectData);
                    component.refreshCategoriesFilter(selectedCategoryId,selectedCategoryname);
               } else { // if any callback error, display error msg
                component.displayMessage('Error', 'An error occurred during Order Initialization ' + state, 'Error','dismissible');
               }
           });
           $A.enqueueAction(action);
        }
           //Fetch all Products Categorys
           var fetchAllcategoriesaction = component.get("c.getAllCategorys");
           fetchAllcategoriesaction.setCallback(this, function (response) {
                //Init Map
               var state = response.getState();
               if (state == "SUCCESS") {
                   // Init() Map of <Id, Wrapper> Onetime Load From Database
                   var allCategoriesData = response.getReturnValue();
                    component.set('v.allCategoriesData',allCategoriesData);
                    component.refreshCategoriesFilter(selectedCategoryId,selectedCategoryname);             
               } else { // if any callback error, display error msg
                component.displayMessage('Error', 'An error occurred during Fetching Categories ' + state, 'Error','dismissible');
               }
           });
           $A.enqueueAction(fetchAllcategoriesaction);
        
            
        };

        var orderUUID = component.get("v.orderUUID");
        //Set Current User Details
        var userContactWrap = component.get("v.userContactWrap");
        component.set("v.userInfo", userContactWrap.userRecord);
        var isproductsdata = component.get("v.productsfromcontactserch");
        console.log('isproductsdata' + isproductsdata);
        if(isproductsdata==false){
        //Fetch all Products Option Data
        var action = component.get("c.getAllProductRecords");
        action.setParams({
            "orderIdOrUUID" : orderUUID,
        });
        action.setCallback(this, function (response) {
            //Init Map
           var state = response.getState();
           if (state == "SUCCESS") {
               // Init() Map of <Id, Wrapper> Onetime Load From Database
               var allProductsMap = response.getReturnValue();
               console.log('allProductsMap;;;' + allProductsMap);
               console.table(allProductsMap);
                component.set('v.allProductsMap',allProductsMap);
                //For Aura attribute Iterate for UI
                let productObjectData = Object.values(allProductsMap);
                component.set('v.productData',productObjectData);
                component.set('v.selectedProductsData',productObjectData);
                console.log('productObjectData;;;' + productObjectData);
                console.table(productObjectData);
           } else { // if any callback error, display error msg
            component.displayMessage('Error', 'An error occurred during Order Initialization ' + state, 'Error','dismissible');
           }
       });
       $A.enqueueAction(action);
    }else{
       var productObjectData = component.get("v.productData")
       console.log('productObjectData' + productObjectData);
        component.set('v.selectedProductsData',productObjectData); 
    }
       //Fetch all Products Categorys
       var fetchAllcategoriesaction = component.get("c.getAllCategorys");
       fetchAllcategoriesaction.setCallback(this, function (response) {
            //Init Map
           var state = response.getState();
           if (state == "SUCCESS") {
               // Init() Map of <Id, Wrapper> Onetime Load From Database
               var allCategoriesData = response.getReturnValue();
                component.set('v.allCategoriesData',allCategoriesData);

                var selectedCategoriesData = allCategoriesData.filter(function (category) {
                    return category.Catalog__c == null;
                });
                component.set('v.selectedCategoryData',selectedCategoriesData);              
           } else { // if any callback error, display error msg
            component.displayMessage('Error', 'An error occurred during Fetching Categories ' + state, 'Error','dismissible');
           }
       });
       $A.enqueueAction(fetchAllcategoriesaction);       

    },
    refreshData: function (component, event, helper) {
        component.set('v.isLoading',true);
        var selectedCategoryId = component.get('v.selectedCategoryId');
        var selectedCategoryname = component.get('v.selectedCategoryname');
        var orderUUID = component.get("v.orderUUID");

        //Fetch all Products Option Data
        var action = component.get("c.getAllProductRecords");
        action.setParams({
            "orderIdOrUUID" : orderUUID,
        });
        action.setCallback(this, function (response) {
            //Init Map
           var state = response.getState();
           if (state == "SUCCESS") {
               // Init() Map of <Id, Wrapper> Onetime Load From Database
               var allProductsMap = response.getReturnValue();
                component.set('v.allProductsMap',allProductsMap);
                //For Aura attribute Iterate for UI
                let productObjectData = Object.values(allProductsMap);
                component.set('v.productData',productObjectData);
                component.set('v.selectedProductsData',productObjectData);
                component.refreshCategoriesFilter(selectedCategoryId,selectedCategoryname);
                component.set('v.isLoading',false);
           } else { // if any callback error, display error msg
            component.displayMessage('Error', 'An error occurred during Order Initialization ' + state, 'Error','dismissible');
           }
       });
       $A.enqueueAction(action);

       //Fetch all Products Categorys
       var fetchAllcategoriesaction = component.get("c.getAllCategorys");
       fetchAllcategoriesaction.setCallback(this, function (response) {
            //Init Map
           var state = response.getState();
           if (state == "SUCCESS") {
               // Init() Map of <Id, Wrapper> Onetime Load From Database
               var allCategoriesData = response.getReturnValue();
                component.set('v.allCategoriesData',allCategoriesData);
                component.refreshCategoriesFilter(selectedCategoryId,selectedCategoryname);             
           } else { // if any callback error, display error msg
            component.displayMessage('Error', 'An error occurred during Fetching Categories ' + state, 'Error','dismissible');
           }
       });
       $A.enqueueAction(fetchAllcategoriesaction);

        
    },
    showCatalogOptions: function (component, event, helper) { 
        console.log("showCatalogOptions");
        component.set('v.isLoading',true);
        var selectedItem = event.currentTarget;
        var selectedcategoryid = selectedItem.dataset.categoryid;
        var selectedCategoryname= selectedItem.dataset.categoryname;
        component.refreshCategoriesFilter(selectedcategoryid,selectedCategoryname);
        component.set('v.isLoading',false);
    },

    clearSelectedCategory: function (component, event, helper) { 
        component.resetCategoriesFilter();
    },

    onEnterProductSearchText: function (component, event, helper) {
        var searchText = event.target.value;
        component.set('v.searchText', searchText);
        console.log('searchText'+ searchText);
        var selectedCategoryId = component.get('v.selectedCategoryId');
        var selectedCategoryname = component.get('v.selectedCategoryname');
        var selectedProductsData = component.get('v.selectedProductsData');
        var filteredProductsData = selectedProductsData.filter(function (prodOption) {
            let query = searchText.toLowerCase();
            return ( prodOption.baseproduct.Name.toLowerCase().indexOf(query) >= 0 );
        });

        if(searchText != '' ){
            component.set('v.selectedProductsData', filteredProductsData);
        } else{
            component.refreshCategoriesFilter( selectedCategoryId, selectedCategoryname );
        }
        
    },
    
    productClickHandler : function(component, event, helper) {
        console.log('methodcalled');
        var logApiResponses = true;
        var selectedItem = event.currentTarget;
        var selectedproductid = selectedItem.dataset.productid; // Selected Product Id
        var selectedoptionid = selectedItem.dataset.optionid; // Selected Product Option Id
        console.log('selectedproductid '+selectedproductid);
        console.log('selectedoptionid '+selectedoptionid);
        var IsOptionSelection = true;
        helper.productoptionsclick(component, event, selectedproductid, selectedoptionid, IsOptionSelection);
       // component.set('v.counter',component.get('v.counter')+1); 
        component.set('v.Popup',false);
    },

    handleProductDeletionCartEvent : function (cmp, event) {
        var logApiResponses = true;
        //Received Action Message
        var message = event.getParam("message");
        if (logApiResponses) { console.log('Received Message: ' + message); }
        //Received JSON String
        var selectedproductsString = event.getParam("selectedproducts");
        console.log('selectedproductsString' + selectedproductsString);
        selectedproductsString = (selectedproductsString !== '{}') ? selectedproductsString : '';
        if (logApiResponses) { console.log('Received selectedproductsString' ); }
        if (logApiResponses) { console.log(selectedproductsString); }

        //Fetch All Product Options Map 
        var tempAllProductsMapafterDeletion = new Map( Object.entries( cmp.get('v.allProductsMap') ) );

        if((selectedproductsString !== '') && (selectedproductsString !== null) && (selectedproductsString !== undefined) ){
             //1 Json String to JSON Object Conversion
            let productObjectData = JSON.parse(selectedproductsString);
            console.log('ObjType:: ' + typeof productObjectData);
            console.table(productObjectData);
          
            // 2 JSON Object To Map Conversion
            let allSelectedProductsMap = new Map(); 
            for (var value in productObjectData) {
                allSelectedProductsMap.set(value, productObjectData[value]);
            }
            let availableProducts = new Array();
            for (let [prodrecordId, value] of  allSelectedProductsMap.entries()) {
                let availableStockQty = value.availableStockQuantity - value.quantity;
                let baseprodid  = value.product.Product__c;
                console.log('baseprodid::' + baseprodid);
                if(availableStockQty >= 1){
                    availableProducts.push(baseprodid);
                }
            }
            
            availableProducts.forEach(function(baseprodid) {
                let currentselectedProdElement = document.querySelector('[data-id="'+baseprodid+'"]');
                console.log('currentselectedProdElement' + currentselectedProdElement);
                console.table(currentselectedProdElement);
                if(currentselectedProdElement.classList.contains("inactiveProduct")) {
                    currentselectedProdElement.classList.remove("inactiveProduct"); 
                }  
                console.log(baseprodid);
            });

            if (logApiResponses) { console.log('allSelectedProductsMap' ); }
            if (logApiResponses) { console.table(allSelectedProductsMap); }

            if (logApiResponses) { console.log('tempAllProductsMapafterDeletion' ); }
            if (logApiResponses) { console.table(tempAllProductsMapafterDeletion); }

            //Not able to Assign map to Aura Attribute 
            console.log('ObjType:: ' + typeof allSelectedProductsMap);
            cmp.set("v.selectedProductsMap", allSelectedProductsMap);
            cmp.set("v.selectedproductsString", selectedproductsString);

            if (logApiResponses) { console.log('selectedproductsString' + selectedproductsString ); }
            if (logApiResponses) { console.log('No Resetted Cart' ); }
         } else{
            //Reset Selected Products quantity after Add to Cart
            cmp.set("v.selectedProductsMap", new Map()); 
            cmp.set("v.selectedproductsString", '');
            cmp.reloadProductsandCatagoryCache();
         }
               
    },

    productNotEligible : function (component, event) {
        var selectedItem = event.currentTarget;
        var isstockavailable = selectedItem.dataset.isstockavailable;
        if(isstockavailable == 'false'){
            component.displayMessage('Error', 'Product was Out of Stock ', 'Error','dismissible');
        }else{
            component.displayMessage('Error', 'You are not Eligible to Order this Product ', 'Error','dismissible');
        }
        
    },

    handleCompoentCommunication : function(cmp, event,helper) {
        var message = event.getParam("message");
        var eventMessage = event.getParam("eventMessage");
        var isLoading = event.getParam("isLoading");
        console.log('PmaProducts Message Received message ' + message);
        console.log('PmaProducts Message Received eventMessage ' + eventMessage);
        console.log('PmaProducts Message Received isLoading ' + isLoading);
        console.log('PmaProducts Message Received in Container Component');
        if(eventMessage == 'hideproducts'){
            cmp.set('v.showProductsComponent',false);
        }
        if(eventMessage == 'showproducts'){
            cmp.set('v.showProductsComponent',true);
        }
        if(eventMessage == 'Repeating order'){
            console.log('Repeating order');
         let repeatedoproducts = JSON.parse(message);
          var selectedproductOptionId = repeatedoproducts.prodoptionid;
    
          console.log('selectedproductOptionId' + selectedproductOptionId);
          var IsOptionSelection = true;
          var selectedProdId = repeatedoproducts.productid;
          var quantity = repeatedoproducts.quantity;
         helper.OrderReapethandler(cmp, event, selectedProdId, selectedproductOptionId, IsOptionSelection,quantity);

        }
    },
    productOptionsfilter : function(component, event,helper) {
        try{       
        var selectedItem = event.currentTarget;
        var selectedProdId = selectedItem.dataset.id; // Selected Product Id
        var selectedProdOptionsCount = selectedItem.dataset.optionscount; // Selected Product optionscount
        console.log('selectedProdId:::'+selectedProdId);
        var tempAllProductsMap = new Map( Object.entries( component.get('v.allProductsMap') ) );
        console.log('productData'+ typeof tempAllProductsMap);
        console.table(tempAllProductsMap);
        
        if (tempAllProductsMap.has(selectedProdId)) {
            var selectedproduct = tempAllProductsMap.get(selectedProdId);
            var selectedprodoptions = new Map(Object.entries(selectedproduct.productMapOptionsWrapper));
            var SelectedProductFilteredOptionsMap = selectedprodoptions.get(selectedProdId);

            console.table(SelectedProductFilteredOptionsMap);
            if(SelectedProductFilteredOptionsMap !=null || SelectedProductFilteredOptionsMap !=undefined ){
                component.set('v.selectedproductoptionMap', SelectedProductFilteredOptionsMap);
                console.log('selectedprodoptionsv2setup' + component.get('v.selectedproductoptionMap'));
            }
           
            var selectedprodoptiondata = Object.values(SelectedProductFilteredOptionsMap);
            console.log('selectedprodoptiondata');
            console.table(selectedprodoptiondata);
            var selectedProductsMap = component.get('v.selectedProductsMap');
            // Iterate over Filtered Options Data to Check Stock
            selectedprodoptiondata.forEach(function(iterSelectedprodoption){
                //Check if Product was outofstock
                if( (selectedProductsMap != null) && ( selectedProductsMap.has(iterSelectedprodoption.product.Id) ) ){
                    var IterSelectedOption = selectedProductsMap.get(iterSelectedprodoption.product.Id);
                    var IterAvailableStock = iterSelectedprodoption.availableStockQuantity - IterSelectedOption.quantity;
                    IterAvailableStock = (IterAvailableStock > 0) ? IterAvailableStock: 0;
                    if(IterAvailableStock == 0){
                        iterSelectedprodoption.product.Is_Option_Available__c = false;
                    } else {
                        iterSelectedprodoption.product.Is_Option_Available__c = true;
                    }
                }
            });
            if(selectedprodoptiondata !=null && selectedprodoptiondata !=undefined){
            component.set('v.filtedoptions', selectedprodoptiondata);
            }
            if (selectedProdOptionsCount > 1) {   
                component.set('v.counter', 0); 
                component.set('v.Popup',true);
                console.log('popup'+ component.get('v.Popup'));
                /*
                var  Inactiveprodoption = component.get('v.Inactiveprodoptions');
                if(Inactiveprodoption.length > 0 ){
                   console.log('inactiveproductexists');
                   for (let i = 0; i < Inactiveprodoption.length; i++) {
                   let currentselectedProdElement = document.querySelector('[data-optionid="' + Inactiveprodoption[i] + '"]');
                   //  let  currentselectedProdElement = document.getElementsByName( Inactiveprodoption[i]);
                    // alert(currentselectedProdElement);
                     console.log('currentselectedProdElement'+ currentselectedProdElement);
                    
                     if(currentselectedProdElement !== null){
                     currentselectedProdElement[0].classList.add("inactiveProduct");
                     console.log('currentselectedProdElement crossed');
                     }
                    // console.log( currentselectedProdElement.classList.add("inactiveProduct"));
                     }
                }
                */
          
            } 
            if (selectedProdOptionsCount == 1) {
                var optionIdList = Object.keys(SelectedProductFilteredOptionsMap);
                var selectedproductOptionId = (optionIdList.length > 0 ) ? optionIdList[0] : '';
                var IsOptionSelection = false;
                helper.productoptionsclick(component, event, selectedProdId, selectedproductOptionId, IsOptionSelection);
                //component.displayMessage('sucess', 'Product is added to cart', 'sucess','dismissible');
              //  component.displayMessage('Success!', 'Product is added to cart!', 'success','dismissible');
            }

        }
        }catch(ex){
            console.log('Exception ' + ex);
            console.table(ex);
        }    
      },

      handlecancle : function(component, event,helper) {
        component.set('v.Popup',false);
      },
      
      communicationforcontactsearch : function(component, event,helper) {
       var allproductsmap = component.get('v.allProductsMap');  
       console.log('allproductsmap++' + allproductsmap);
       var processedObjectToString = JSON.stringify(allproductsmap);
       console.log('processedObjectToString' + processedObjectToString);
       component.fireApplicationEventCall('ContactcommunicationEvent', {
        
        message: processedObjectToString,
        showchild:false,
        showparent:true
     });

      }
    })