function posPageLoaded() {
   
    var productwrap =  '{!productwrapperList}';
    console.table(productwrap);
    var posProductPageListenerAdded = false;
    var posPageWrapperContainer = document.querySelector('.product-cart-wrap');
    
    if ((posPageWrapperContainer) && (!posProductPageListenerAdded)) {
        posProductPageListenerAdded = true;
        // Click handler for entire DIV posPageWrapperContainer
        posPageWrapperContainer.addEventListener('click', function (e) {
            console.log('methodcalled product-wrapper');
            // Click handler for entire DIV product-wrapper
            if ((e.target.classList.contains('product-wrapper'))) {
                console.log('methodcalled product-wrapper');
                var selectedProductElement = e.target;
                var selectedProductId = selectedProductElement.getAttribute('data-ProductId');
                console.log('selectedProductIdNDR ' + selectedProductId);
                addtocart(selectedProductId);
                gettingorderDetails();
           }
        });
    }

    //Chain Another Action functions 
    gettingorderDetails();
}
function productFiltering() {
    var product = document.getElementById("productname");
    console.log('x-value' + product.value);
    var productname = product.value;
    ProductFiltering(productname);
    
  }