public without sharing class POS_Utility {
    
    public class PosControllerException extends Exception {}
    
    /* this hook is called when we initially fetching the  product to display in container */
    public static List < CatalogItem__c > initialproductsfetch(string accountId) {
        List < CatalogItem__c > catalogItem = new list < CatalogItem__c > ();
        try {
            String product = 'SELECT ' + SYS_Helper.getAllFieldsFor('CatalogItem__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Catalog__r.', 'Catalog__c') +
                ', ' + SYS_Helper.getAllParentFields('Catalog__r.Catalog__r.', 'Catalog__c') +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('CatalogItemVariation__c') + ' FROM CatalogItemVariations__r)' +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('CatalogModifier__c') + ' FROM CatalogModifier__r)' +
                ' FROM CatalogItem__c WHERE Name != \'Tip\' AND Name != \'Wallet\' AND Product_Family__c = \'POS\' AND Is_Variants_Available__c > 0  AND Square_Id__c != null AND Account__c =:accountId ORDER BY Name ASC';
            system.debug('productNDR' + product);
            catalogItem = Database.query(product);
            //  ImageController.getShortendImageName(prodOption.Name);
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
            throw new PosControllerException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        return catalogItem;
    }
    
    /* This hook is called onload of component for search or create of order helper*/
    public static List < Order__c > searchDraftOrder(string accountId, string customerId, string orderId) {
        List < Order__c > searchOrderList = new list < Order__c > ();
        try {
            if (string.isBlank(orderId)) {
                String orderSearch = 'SELECT ' + SYS_Helper.getAllFieldsFor('Order__c') +
                    ', ' + SYS_Helper.getAllParentFields('Member__r.', 'contact') +
                    ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Order_Item__c') + ' FROM Order_Items__r  ORDER BY createddate DESC )' +
                    ' FROM  Order__c  WHERE Order_Type__c = \'POS\'  AND Status__c != \'Completed\' AND Member__c =: customerId  AND Account__c =:accountId LIMIT 1';
                system.debug('orderSearchNDR' + orderSearch);
                searchOrderList = Database.query(orderSearch);
            } else {
                String orderSearch = 'SELECT ' + SYS_Helper.getAllFieldsFor('Order__c') +
                    ', ' + SYS_Helper.getAllParentFields('Member__r.', 'contact') +
                    ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Order_Item__c') + ' FROM Order_Items__r  ORDER BY createddate DESC )' +
                    ' FROM  Order__c  WHERE Order_Type__c = \'POS\'  AND Status__c != \'Completed\' AND Member__c =: customerId  AND Account__c =:accountId  AND Id =:orderId LIMIT 1';
                system.debug('orderSearchNDR' + orderSearch);
                searchOrderList = Database.query(orderSearch);
                
            }
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
            throw new PosControllerException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        return searchOrderList;
    }
    /* This hook is called onload of component for search or create of order */
    public static Order__c DraftOrderCreation(string accountId, string customerId) {
        List < Order__c > searchDraftOrderList = new list < Order__c > ();
        try {
            searchDraftOrderList = POS_Utility.searchDraftOrder(accountId, customerId, '');
            
            if (searchDraftOrderList.size() == 0) {
                Order__c newDraftOrder = new Order__c();
                String orderUUID = SYS_Helper.getUUID();
                newDraftOrder.Account__c = accountId;
                newDraftOrder.Member__c = customerId;
                newDraftOrder.Status__c = 'Draft';
                newDraftOrder.UUID__c = orderUUID;
                newDraftOrder.Order_Type__c = 'POS';
                insert newDraftOrder;
                searchDraftOrderList = POS_Utility.searchDraftOrder(accountId, customerId, newDraftOrder.Id);
                
            }
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
            throw new PosControllerException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        system.debug('searchDraftOrderList' + searchDraftOrderList);
        return (searchDraftOrderList.size() > 0) ? (searchDraftOrderList[0]) : (new Order__c());
    }
    
    /*#########
    Hook is called when orderlineitem  adding
        ###############*/
    public static void OrderlineItem(order__c order,string memberId, string selectedItem,List<CatalogItem__c> ProductsList) {
        Map<Id, CatalogItem__c> catalogItemMap = new Map<Id, CatalogItem__c>();
        
        for(CatalogItem__c catalogprod : ProductsList){
            catalogItemMap.put(catalogprod.Id, catalogprod);
        }
        Order_Item__c orderItemNew = new Order_Item__c();
        orderItemNew.Order__c = order.Id;
        orderItemNew.Item_Status__c =  'New';
        orderItemNew.CatalogItem__c = selectedItem;
        // orderItemNew.CatalogItemVariation__c = selectedItem;
        //// orderItemNew.CatalogModifier__c = selectedItem;
        orderItemNew.Quantity__c = 1;
        insert orderItemNew;
        //   orderItemNew.Notes__c = selectedProduct.orderNotes;
        //  orderItemList.add(orderItemNew);
        // order
    }
    /*on key enter filtering the Product*/
    public static List < CatalogItem__c > productSearchUtil(string productName,list<catalogItem__c> productList) {
        list<catalogItem__c> catItemList = new list<CatalogItem__c> ();
        if(string.isNotBlank(productName) ){
        for (catalogItem__c catalogItem : productList) {
            if (catalogItem.Name.toLowerCase().contains(productName.toLowerCase())) {
                catItemList.add(catalogItem);
            }
            
        }
        system.debug('catItemListNdr' + catItemList );
        return catItemList;
    }else{
        return productList;
    }
        
    }
}