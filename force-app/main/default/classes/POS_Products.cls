public with sharing class POS_Products {
    public class PosProductsException extends Exception {}
    public string memberrecordId {get; set; }
    public string accountrecId {get; set; }
    public string uuid {get; set; }
    public string todorecordId {get; set; }
    public order__c order {get; set; }
    public string selectedProductId {get; set; }
    public List<CatalogItem__c> catalogItemList {get; set; }
    public List<Productwrapper> productwrapperList {get; set; }
    public string productSearchName {get; set; }
    public Map<Id, CatalogItem__c> catItemMap {get; set; }
    public CatalogItem__c selectedProduct {get; set; }
    public string selectedProductVariant {get; set; }
    public string selectedProductModifer {get; set; }
    public Decimal OrderAmount {get; set; }
    public Decimal TotalOrderAmount {get; set; }
    public string orderLineId {get; set; }
    public Boolean isDeleted {get; set; }
    public Boolean isModalOpen {get; set; }
    public Boolean iscartloaded {get; set; }
    public Boolean isproductsloaded {get; set; }
    public integer quantity {get; set; }
    public string notes {get; set; }
    public string  lastdeletedItem {get; set; }
    public void   fetchProducts() {
        catalogItemList = new list<CatalogItem__c>();
        catItemMap = new Map<Id, CatalogItem__c>();
        catalogItemList= POS_Utility.initialproductsfetch(accountrecId);
        system.debug('catalogItemListNDR' + catalogItemList.size());
        productwrapperList = new List<Productwrapper>();
        for(CatalogItem__c catalogitemIter:catalogItemList){
            //  if(catalogitemIter.CatalogItemVariations__r.size()>0){
                catItemMap.put(catalogitemIter.Id, catalogitemIter);
                system.debug('catalogitemIterNDR' + catalogitemIter);
                Productwrapper prodwrapper = new Productwrapper();
                prodwrapper.catalogVariantsCount = catalogitemIter.CatalogItemVariations__r.size();
                prodwrapper.catalogModifierCount = catalogitemIter.CatalogModifier__r.size();
                prodwrapper.shortNameCode= ImageController.getShortendImageName(catalogitemIter.Name);
                prodwrapper.catalogItem = catalogitemIter;
                
                productwrapperList.add(prodwrapper);
                
            //  }
        }
        system.debug('productwrappersize'+ productwrapperList.size());
        isproductsloaded = true;
    }
    public void   getorderDetails() {
        order = new order__c();
        order = POS_Utility.DraftOrderCreation(accountrecId,memberrecordId);
        iscartloaded = true;
    }
    /*this hook is called when we adding the item into the cart*/
    public void  addingToCart() {
        POS_Utility.OrderlineItem(order, memberrecordId, selectedProductId,selectedProductVariant,selectedProductModifer,OrderAmount,quantity,notes,catItemMap);
        selectedProduct = new CatalogItem__c();
        system.debug('selectedProductNDR' + selectedProduct);
        isModalOpen = false;
       
    }
    /*on key enter filtering the Product*/
    public  void productSearch() {
        List<CatalogItem__c>ItemList = new list<CatalogItem__c>();
        ItemList =  POS_Utility.productSearchUtil(productSearchName,catalogItemList);
        productwrapperList = new List<Productwrapper>();
        for(CatalogItem__c catalogitemIter:ItemList){
            //  if(catalogitemIter.CatalogItemVariations__r.size()>0){
                system.debug('catalogitemIterNDR' + catalogitemIter);
                Productwrapper prodwrapper = new Productwrapper();
                prodwrapper.catalogVariantsCount = catalogitemIter.CatalogItemVariations__r.size();
                prodwrapper.shortNameCode= ImageController.getShortendImageName(catalogitemIter.Name);
                prodwrapper.catalogItem = catalogitemIter;
                
                productwrapperList.add(prodwrapper);
                system.debug('filteredProdNDR' + productwrapperList);
            //  }
            
        }
    }
    /*This helper class is called when User clicks the Product only when options are there for the user selected product*/
    public void getSelectedProductDetails() {
        selectedProduct = new CatalogItem__c();
        selectedProduct = POS_Utility.getSelectedProductUtil(selectedProductId,catItemMap);
        isModalOpen = true;
        
    }
     /*This helper class is called when User clicks the Product only when options are there for the user selected product*/
     public void deSelectedProductDetails() {
        selectedProduct = new CatalogItem__c();
        system.debug('selectedProductNDR' + selectedProduct);
        isModalOpen = false;
        }
     /*This  method is called for deleteing the orderlineintem*/
    public void orderLineDelete() {
        lastdeletedItem =   POS_Utility.deleteOrderItemUtil(orderLineId,lastdeletedItem);
       
    }
     /*This  method is called for doing apicallout to square*/
     public void orderApiCallout() {
    SquarePaymentUtility.ApiCalloutSynchronousWithRecordId(AccountrecId,order.Id,'POST','INSERT','Square','Square_Orders');
    }
    /*This  method is called for for updating the order status to active*/
    public void updateorder(){
        POS_Utility.orderUpdateUtil(order);
    }
    public class Productwrapper {
        
        public String shortNameCode {get; set; }
        public String imageUrl {get; set; }
        public CatalogItem__c catalogItem {get; set; }
        public integer catalogVariantsCount {get; set; }
        public integer catalogModifierCount {get; set; } 
        
    }
    
    
}