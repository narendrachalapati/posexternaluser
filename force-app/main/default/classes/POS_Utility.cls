public without sharing class POS_Utility {
    
    public class PosControllerException extends Exception {}
    
    /* this hook is called when we initially fetching the  product to display in container */
    public static List < CatalogItem__c > initialproductsfetch(string accountId) {
        List < CatalogItem__c > catalogItem = new list < CatalogItem__c > ();
        try {
            String product = 'SELECT ' + SYS_Helper.getAllFieldsFor('CatalogItem__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('CatalogCategory__c') + ' FROM CatalogCategory__r)' +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('CatalogItemVariation__c') + ' FROM CatalogItemVariations__r ORDER BY Ordinal__c ASC)' +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('CatalogItem_Image__c') + ' FROM CatalogItem_Image__r ORDER BY createddate DESC)' +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Modifiers_on_Item__c') + ' FROM Modifiers_on_Items__r)' +
                ' FROM CatalogItem__c WHERE Name != \'Tip\' AND Name != \'Wallet\' AND ProductType__c != \'APPOINTMENTS_SERVICE\'  AND Square_Id__c != null AND Is_Deleted__c != true AND Account__c =:accountId ORDER BY Name ASC';
            
            catalogItem = Database.query(product);
            system.debug('productNDR' + catalogItem);
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
                    ', ' + SYS_Helper.getAllParentFields('customer__r.', 'contact') +
                    ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Order_Item__c') + ' FROM Order_Items__r  ORDER BY createddate DESC )' +
                    ' FROM  Order__c  WHERE Order_Type__c = \'POS\'  AND Status__c != \'Completed\' AND customer__c =: customerId  AND Account__c =:accountId LIMIT 1';
                system.debug('orderSearchNDR' + orderSearch);
                searchOrderList = Database.query(orderSearch);
            } else {
                String orderSearch = 'SELECT ' + SYS_Helper.getAllFieldsFor('Order__c') +
                    ', ' + SYS_Helper.getAllParentFields('customer__r.', 'contact') +
                    ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Order_Item__c') + ' FROM Order_Items__r  ORDER BY createddate DESC )' +
                    ' FROM  Order__c  WHERE Order_Type__c = \'POS\'  AND Status__c != \'Completed\' AND customer__c =: customerId  AND Account__c =:accountId  AND Id =:orderId LIMIT 1';
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
                newDraftOrder.Customer__c = customerId;
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
    public static void OrderlineItem(order__c order,string memberId, string selectedItem, string selectedVariant, string selectedModifier,Decimal amount,integer quantity, string notes, Map<Id, CatalogItem__c> catItemMap) {
        
        Order_Item__c orderItemNew = new Order_Item__c();
        orderItemNew.Order__c = order.Id;
        orderItemNew.Item_Status__c =  'New';
        orderItemNew.CatalogItem__c = selectedItem;
        if(string.isNotBlank(selectedVariant)){
            orderItemNew.CatalogItemVariation__c = selectedVariant;
        }
        if(string.isNotBlank(selectedModifier)){
            orderItemNew.CatalogModifier__c = selectedModifier;
        }else{
            CatalogItem__c catalogItem = catItemMap.get(selectedItem);
            if(catalogItem.CatalogItemVariations__r.size()==1){
                orderItemNew.CatalogItemVariation__c = catalogItem.CatalogItemVariations__r[0].Id;
                orderItemNew.Total_Price__c = catalogItem.CatalogItemVariations__r[0].PriceMoney__c;
            }
            
        }
        if(quantity > 0){
            orderItemNew.Quantity__c = quantity;
        }else{
            orderItemNew.Quantity__c = 1;
        }
        if(string.isNotBlank(notes)){
            orderItemNew.Notes__c = notes;
        }else{
            orderItemNew.Notes__c = '';
        }
        if(amount>0){
            orderItemNew.Total_Price__c = amount;
        }
        
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
    /*This helper class is called when User clicks the Product only when options are there for the user selected product*/
    public static CatalogItem__c getSelectedProductUtil(string prodId,Map<Id,catalogItem__c> catalogItemsMap) {
        CatalogItem__c catlogItemutil = catalogItemsMap.get(prodId);
        return catlogItemutil;
        
    }
    public static List<Catalog_Modifer_List__c> getSelectedModifiers(CatalogItem__c catalogItem) {
        Set<Id> ModifierListIdSet = new set<Id>();
        List < Catalog_Modifer_List__c > catalogModifierListList = new list < Catalog_Modifer_List__c > ();
         for(Modifiers_on_Item__c ModifiersonItem : catalogItem.Modifiers_on_Items__r){
            ModifierListIdSet.add(ModifiersonItem.Catalog_Modifer_List__c);
            
        }
        
        String modifierListObj = 'SELECT ' + SYS_Helper.getAllFieldsFor('Catalog_Modifer_List__c') +
            ', ( SELECT ' + SYS_Helper.getAllFieldsFor('CatalogModifier__c') + ' FROM CatalogModifier__r)' +
            ' FROM Catalog_Modifer_List__c WHERE Id IN : ModifierListIdSet ';
        catalogModifierListList = Database.query(modifierListObj);
        system.debug('ModifierNDR' + catalogModifierListList);
        return catalogModifierListList;
    }
    /*This helper class is called for deleteing the orderlineintem*/
    public static string deleteOrderItemUtil(string orderItemId,string lastdeletedItem) {
        Boolean isDelete;
        if((string.isNotBlank(orderItemId)) && (lastdeletedItem != orderItemId) ){
            list<Order_Item__c> orderedItems =[SELECT Id from Order_Item__c wHERE Id=:orderItemId];
            if(orderedItems.size()>0){
                delete orderedItems;
            }
            
            isDelete = true;
            lastdeletedItem = orderItemId;
        }
        
        return lastdeletedItem;
    }
    public static order__c orderUpdateUtil(order__c order) {
        
        if(order != null){
            order.Status__c = 'Active';
            update order;
            
        }
        return order;
    }
}