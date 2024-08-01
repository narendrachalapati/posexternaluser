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
    public void   fetchProducts() {
        catalogItemList = new list<CatalogItem__c>();
        catalogItemList= POS_Utility.initialproductsfetch(accountrecId);
        system.debug('catalogItemListNDR' + catalogItemList.size());
        productwrapperList = new List<Productwrapper>();
        for(CatalogItem__c catalogitemIter:catalogItemList){
          //  if(catalogitemIter.CatalogItemVariations__r.size()>0){
                system.debug('catalogitemIterNDR' + catalogitemIter);
                Productwrapper prodwrapper = new Productwrapper();
                prodwrapper.catalogVariantsCount = catalogitemIter.CatalogItemVariations__r.size();
                prodwrapper.shortNameCode= ImageController.getShortendImageName(catalogitemIter.Name);
                prodwrapper.catalogItem = catalogitemIter;
                
                productwrapperList.add(prodwrapper);
          //  }
        }
        system.debug('productwrappersize'+ productwrapperList.size());
    }
    public void   getorderDetails() {
        order = new order__c();
        order = POS_Utility.DraftOrderCreation(accountrecId,memberrecordId);
    }
    /*this hook is called when we adding the item into the cart*/
    public void  addingToCart() {
        POS_Utility.OrderlineItem(order, memberrecordId, selectedProductId,catalogItemList);
    }
     /*on key enter filtering the Product*/
     public  void productSearch() {
        catalogItemList =  POS_Utility.productSearchUtil(productSearchName,catalogItemList);
        productwrapperList = new List<Productwrapper>();
        for(CatalogItem__c catalogitemIter:catalogItemList){
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
    public class Productwrapper {
        
        public String shortNameCode {get; set; }
        public CatalogItem__c catalogItem {get; set; }
        public integer catalogVariantsCount {get; set; }
        
    }
    
    
}