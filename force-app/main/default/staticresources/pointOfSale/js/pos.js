var selectedProductId;
var selectedProductvariantId;
var selectedProductmodifierId;
var orderAmount;
var modierAmount;
function posPageLoaded() {
   
    var productwrap =  '{!productwrapperList}';
    console.table(productwrap);
    var posProductPageListenerAdded = false;
    var posPageWrapperContainer = document.querySelector('.product-cart-wrap');
    
    if ((posPageWrapperContainer) && (!posProductPageListenerAdded)) {
        posProductPageListenerAdded = true;
        // Click handler for entire DIV posPageWrapperContainer
        posPageWrapperContainer.addEventListener('click', function (e) {
           
          
            //############################## Click handler for onclick of Base Product catalog item
            // #########################
            if ((e.target.classList.contains('product-wrapper'))) {
                console.log('methodcalled product-wrapper');
                var selectedProductElement = e.target;
                 selectedProductId = selectedProductElement.getAttribute('data-ProductId');
                var selectedProdOptionCount = selectedProductElement.getAttribute('data-variantscount'); //data-ModifierCount
                var selectedProdBasePrice = selectedProductElement.getAttribute('data-defaultprice'); //Default Price
                console.log('selectedProductIdNDR ' + selectedProductId + ' '+ selectedProdOptionCount);
                if(selectedProdOptionCount>1){
                    selectedProductDetails(selectedProductId);
                  var modalwindow = document.querySelector('.ProductVariant-modal');
                  modalwindow.style.display='block';
                  var skeletonload = document.querySelector('.skeletonclass');
                  console.log('skeletonloadNDR' + skeletonload);
                  skeletonload.style.display='block';
               
                 
                }else{
                    orderAmount =  selectedProdBasePrice;
                    console.log('orderAmountNDR' + orderAmount);
                   addtocart(selectedProductId,'','',orderAmount,1,'');

                   gettingorderDetails();
                }
                
             }
             // Catalog selection click listner
             if ((e.target.classList.contains('catVariants'))) {
                console.log('methodcalled catVariants');
                var selectedProductElement = e.target;
                 selectedProductvariantId = selectedProductElement.getAttribute('data-catalogvatiant');
                 variantAmount = selectedProductElement.getAttribute('data-variantamount');
                console.log('variantAmount' + variantAmount);
                orderAmount =  variantAmount;
                var navLinkCurrentActiveElementsList = document.querySelectorAll(".catVariants.onselect-color");
                
                if(navLinkCurrentActiveElementsList) {
                    navLinkCurrentActiveElementsList.forEach( function(iterActiveNavElement) {
                        // Remove "active" class from any other active link
                        iterActiveNavElement.classList.remove('onselect-color');
                    });
                }
                    if(selectedProductElement) {
                        // Add "active" class to the setSelectedTab link
                        selectedProductElement.classList.add('onselect-color');
                    }
              console.log('selectedProductvariantId : ' + selectedProductvariantId);
            }
             //########################## Catalog modifier selection click listner ########################
             if ((e.target.classList.contains('catmodifier'))) {
                console.log('methodcalled catmodifier');
                var selectedProductElement = e.target;
                 selectedProductmodifierId = selectedProductElement.getAttribute('data-catalogmodifier');
                 modierAmount = selectedProductElement.getAttribute('data-modifierAmount');
                 var sum = parseInt(orderAmount) + parseInt(modierAmount);
                //var roundedSum = parseFloat(sum.toFixed(2)); // Result: 2.69
                orderAmount=sum;
                var navLinkCurrentActiveElementsList = document.querySelectorAll(".catVariants.onselect-color");
                    if(selectedProductElement) {
                        // Add "active" class to the setSelectedTab link
                        selectedProductElement.classList.add('onselect-color');
                    }
              console.log('selectedcatalogmodifierId : ' + selectedProductmodifierId);
            }
              //################## Catalog modifier selection click listner ##############
              if ((e.target.classList.contains('addbutton'))) {
                console.log('methodcalled addbutton');
                var selectedProductElement = e.target;
                console.log('selectedProductId ' +selectedProductId + 'selectedProductvariantId '+selectedProductvariantId+'selectedProductmodifierId '+selectedProductmodifierId);
                var posOrderQuantity = document.querySelector('.posorderquantity');
                var quantity = posOrderQuantity.value;
                var posOrdernotes = document.querySelector('.posordernotes');
                var note = posOrdernotes.value;
                if (selectedProductvariantId != null) {
                    orderAmount = orderAmount*quantity;
                    addtocart(selectedProductId,selectedProductvariantId,selectedProductmodifierId,orderAmount,quantity,note);
                    var closemodals = document.querySelectorAll(".ProductVariant-modal");
                    closemodals.forEach(function(modal) {
                        modal.style.display = 'none';
                    });
                    gettingorderDetails();
                }
                  
             }
               //################## Order line Delete  click listner ##############
               if ((e.target.classList.contains('fafadelete'))) {
                console.log('methodcalled orderdelete');
                var selectedProductElement = e.target;
                 // Find the parent <tr> and hide it
              const parentTr = selectedProductElement.closest('tr');
              parentTr.style.display = 'none';
               var orderlineId = selectedProductElement.getAttribute('data-orderlineid');
               console.log('orderlineId NDR' + orderlineId);
               deleteOrderLine(orderlineId);
            }
        //Close Modal Lisner
          //Close Modal Lisner
          if ((e.target.classList.contains('close'))) {
            console.log('methodcalled catmodifier');
            var selectedProductElement = e.target;
            selectedProductId = '';
            deselectproduct();
            var closemodals = document.querySelectorAll(".ProductVariant-modal");
            closemodals.forEach(function(modal) {
                modal.style.display = 'none';
            });
          
      
        }
      
        });
        // / onkeyup handler for entire DIV posPageWrapperContainer
        posPageWrapperContainer.addEventListener('keyup', function (e) {
            
             // Click handler for entire DIV product-wrapper
             if ((e.target.classList.contains('product-search'))) {
               
                console.log('methodcalled onkeyup calld product search');
                var searchedProductElement = e.target; //productSearch
               var productname = searchedProductElement.value;
               ProductFiltering(productname);
             }

        });
    }
   
    gettingorderDetails();
}

function onmodalopenaction() {
var navLinkCurrentActiveElementsList = document.querySelectorAll(".catVariants");
console.log(navLinkCurrentActiveElementsList);
//   if(navLinkCurrentActiveElementsList.length > 0){
  navLinkCurrentActiveElementsList[0].click();
//   }

}
