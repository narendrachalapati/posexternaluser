public with sharing class POS_Utility {
    public static List<CatalogItem__c> initialproductsfetch(string accountId) {
        List<CatalogItem__c> catalogItem = new list<CatalogItem__c>();
        String product = 'SELECT ' + SYS_Helper.getAllFieldsFor('CatalogItem__c') +
        ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
        ', ' + SYS_Helper.getAllParentFields('Catalog__r.', 'Catalog__c') +
        ', ' + SYS_Helper.getAllParentFields('Catalog__r.Catalog__r.', 'Catalog__c') +
        ', ( SELECT ' + SYS_Helper.getAllFieldsFor('CatalogItemVariation__c') + ' FROM CatalogItemVariations__r)' +
        ' FROM CatalogItem__c WHERE Name != \'Tip\' AND Name != \'Wallet\' AND Product_Family__c = \'POS\' AND Is_options_Available__c > 0  AND Square_Id__c != null AND Account__c =:accountId ORDER BY Name ASC';
        system.debug('productNDR' + product);
        catalogItem = Database.query(product); 
        system.debug(catalogItem);
        return catalogItem;
    }
}