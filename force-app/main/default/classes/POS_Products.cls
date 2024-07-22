public with sharing class POS_Products {
    public string memberrecordId {get; set; }
    public string accountrecId {get; set; }
    public string uuid {get; set; }
    public string todorecordId {get; set; }
    public List<CatalogItem__c> catalogItemList {get; set; }
    public void   fetchProducts() {
        catalogItemList = new list<CatalogItem__c>();
        catalogItemList= POS_Utility.initialproductsfetch(accountrecId);
    }
}