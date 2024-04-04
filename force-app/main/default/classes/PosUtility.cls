public without sharing class PosUtility {

    public static Order__c createOrderItemsutility(Id orderId, String selectedProductsValues) {
        Order__c checkOrderStatus = PMA_SearchController.getOrderDetailsByIdOrUUID(orderId);
        System.debug('checkOrderStatus  ' + checkOrderStatus);
        List < Order_Item__c > orderItemList = new List < Order_Item__c > ();
        Id productVendorId;
        Integer maxIntValue = 2147483647; // Maximum integer value
        Integer i = 1;
        System.debug('selectedProductsValues ' + selectedProductsValues);
 
        Map<Id, Product_Option__c> idProdOptionMap = new Map<Id, Product_Option__c>();
        Set<Id> prodOptionIdSet = new Set<Id>();
        List < PMA_ProductsController.SelectedProductWrapper > prodWrapperList = (List < PMA_ProductsController.SelectedProductWrapper > ) JSON.deserialize(selectedProductsValues, List <PMA_ProductsController.SelectedProductWrapper>.class);
        for (PMA_ProductsController.SelectedProductWrapper selectedProduct: prodWrapperList) {
            prodOptionIdSet.add(selectedProduct.product.Id);
        }
        List<Product_Option__c> productoptionList = [SELECT Id,Name,Option_Total_Price__c,Product__c,Available_Stock_Quantity__c,Is_Option_Available__c,CreatedDate,LastModifiedDate,
            Product__r.Name,Product__r.Type__c,Product__r.Catalog__c,Product__r.Catalog__r.Name,Product__r.Catalog__r.Catalog__c,Product__r.Catalog__r.Catalog__r.Name,Product__r.Unit_Price__c,Product__r.Account__c,Product__r.Account__r.Name,Product__r.Active__c,Product__r.Contact__c,
            Product__r.Enable_Order_Fullfillment__c,Product__r.Minimum_Age__c, Product__r.Special_Minimum_Age__c, Product__r.Special_Status__c,Product__r.Product_Code__c,Product__r.Product_Description__c,
            Product__r.Product_Family__c,Product__r.Product_SKU__c,Product__r.Quantity_Unit_Of_Measure__c,Product__r.UUID__c,Product__r.Allow_scheduling__c,Product__r.OwnerId,Product__r.CreatedDate,Product__r.LastModifiedDate
             FROM Product_Option__c WHERE Id IN :prodOptionIdSet];
 
        for(Product_Option__c optionRecord :productoptionList){
            idProdOptionMap.put(optionRecord.Id, optionRecord);
        } 
 
        for (PMA_ProductsController.SelectedProductWrapper selectedProduct: prodWrapperList) {
            Product_Option__c tempOptionRecord = idProdOptionMap.get(selectedProduct.product.Id);
            Integer tempavailableQuantity = (tempOptionRecord.Available_Stock_Quantity__c != NULL) ? ( (tempOptionRecord.Available_Stock_Quantity__c > maxIntValue) ? maxIntValue : Integer.valueOf(tempOptionRecord.Available_Stock_Quantity__c) ) : 0;
            Integer posStockQuantity = selectedProduct.quantity;
            Integer currentStockAvailability = tempavailableQuantity;
            Integer productQuantity = 0;
            Boolean enableOrderTracking = (String.isNotBlank(selectedProduct.product.Product__c)) ? selectedProduct.product.Product__r.Enable_Order_Fullfillment__c : FALSE;
            
            if(currentStockAvailability < posStockQuantity){
                productQuantity = currentStockAvailability;
            }else{
                productQuantity = posStockQuantity;
            }
 
            if(productQuantity > 0){
                Order_Item__c orderItemNew = new Order_Item__c();
                orderItemNew.Order__c = orderId;
                orderItemNew.Item_Status__c = (enableOrderTracking == TRUE) ? 'New' : 'Closed';
                orderItemNew.Product_Option__c = selectedProduct.product.Id;
                orderItemNew.Quantity__c = productQuantity;
                orderItemNew.Notes__c = selectedProduct.orderNotes;
                orderItemList.add(orderItemNew);
                if(i == 1){
                    productVendorId = selectedProduct.product.Product__r.Contact__c;    
                }
                i++;
            }
        }
        
        if(orderItemList.size() > 0 ){
            System.debug('orderItemList  ' + orderItemList);
            insert orderItemList;
        }
 
        if (( (checkOrderStatus.Vendor__c == null) && (productVendorId != null) ) || (checkOrderStatus.Status__c == 'Draft') ) {
            if ( (checkOrderStatus.Vendor__c == null) && (productVendorId != null) ) {
                checkOrderStatus.Vendor__c = productVendorId;
            }
            if (checkOrderStatus.Status__c == 'Draft') {
                checkOrderStatus.Status__c = 'Active';
            }
            update checkOrderStatus;
        }
 
        Order__c currentOrder = PMA_SearchController.getOrderDetailsByIdOrUUID(orderId);
        System.debug('currentOrder  ' + currentOrder);
        return currentOrder;
    }
     //To create Tip Order Item record

     public static Order__c createTipOrderItemUtility(Id orderId, Decimal TipAmount, Decimal TipPercent) {
         List<Product_Option__c> optionRecords  = [SELECT Id,Name,Available_Stock_Quantity__c,Is_Option_Available__c,Option_Total_Price__c,Product__c,Product__r.Enable_Order_Fullfillment__c,IsDeleted,CreatedDate,LastModifiedDate FROM Product_Option__c WHERE Name = 'Tip'];
         Product_Option__c optionRecord = new Product_Option__c();
         Boolean enableOrderTracking = FALSE;
         if( (optionRecords.size() > 0) && (TipAmount > 0) ){
             optionRecord = optionRecords[0];
             enableOrderTracking = ( String.isNotBlank(optionRecord.Product__c)) ? optionRecord.Product__r.Enable_Order_Fullfillment__c : FALSE;
             
             Order_Item__c orderItemNew = new Order_Item__c();
             orderItemNew.Order__c = orderId;
             orderItemNew.Item_Status__c =  (enableOrderTracking == TRUE) ? 'New' : 'Closed';
             if( optionRecord != null ){
                 orderItemNew.Product_Option__c = optionRecord.Id;
             } 
             orderItemNew.Quantity__c = 1;
             orderItemNew.Total_Price__c = TipAmount;
             orderItemNew.Notes__c = 'Added '+TipPercent + '% Tip';
             insert orderItemNew;
         }
         Order__c currentOrder = PMA_SearchController.getOrderDetailsByIdOrUUID(orderId);
         return currentOrder;
     }

     public static string GuestUsercreateDraftOrderRecordutility( Id memberId , Id AccountId){
        // Order__C getOrderDetails = new Order__c();
        string gettingorderuuid;
         List<Order__c> searchOrderList = [SELECT Id, Name, Order_Type__c, Member__c, Member__r.Name, Member__r.Active__c, Member__r.Balance__c, Member__r.Default_Payment_Method__c,
                                           Vendor__c, Vendor__r.Name, Account__c, Account__r.Name, Status__c, 
                                           Total_Price__c, UUID__c, CreatedDate, LastModifiedDate, OwnerId FROM Order__c
             WHERE (Order_Type__c = 'POS')  AND (Status__c != 'Completed') AND Member__c =: memberId  AND Account__c =:AccountId LIMIT 1];
             if(searchOrderList.size() == 0){
             //Create Draft Order
             String orderUUID = SYS_Helper.getUUID();
             Order__c newDraftOrder = new Order__c();
             newDraftOrder.Order_Type__c = 'POS';
             newDraftOrder.Status__c = 'Draft';
             newDraftOrder.Account__c = AccountId;
             newDraftOrder.Member__c = memberId;
             newDraftOrder.UUID__c = orderUUID;
             insert newDraftOrder;
             gettingorderuuid = orderUUID;
 
         }else{
             gettingorderuuid = searchOrderList[0].UUID__c;
         }
         
         return gettingorderuuid;
     }
     public static Order__c getOrderDetailsByIdOrUUIDutility( String orderIdOrUUID ){
        Order__c currentOrder = new Order__c();
        system.debug('orderIdOrUUIDNDR'+orderIdOrUUID);
        //Product_Option__c,Product_Option__r.Product__c,Product_Option__r.Product__r.Enable_Order_Fullfillment__c
        if( (orderIdOrUUID.length()==15) || (orderIdOrUUID.length()==18) ){
            system.debug('UserInfo.getUserId()  ' + UserInfo.getUserId() );
            UserRecordAccess ura = [SELECT RecordId,HasReadAccess 
            FROM UserRecordAccess 
            WHERE UserId=:UserInfo.getUserId() 
                AND RecordId = :orderIdOrUUID 
            LIMIT 200];
            system.debug('ura' + ura);

            currentOrder = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c,Member__r.Card_Update_Link__c,
            Member__r.Default_Payment_Method__c, Member__r.AllowComplimentaryOrders__c, Member__r.Age__c,Member__r.Balance__c,
            Member__r.Birthdate,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId,
            (SELECT
            Id,Name,Order__c,Product__c,Product_Name__c,Quantity__c,List_Price__c,Line_Total_Price__c,Total_Price__c,Notes__c,CreatedDate,LastModifiedDate,Product_Option__c,Product_Option__r.Product__c,Product_Option__r.Available_Stock_Quantity__c,Product_Option__r.Product__r.Enable_Order_Fullfillment__c
            FROM Order_Items__r) FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND ( Id
            =: orderIdOrUUID ) ];
          
        }
        else{
            currentOrder = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c,Member__r.Card_Update_Link__c,
            Member__r.Default_Payment_Method__c, Member__r.AllowComplimentaryOrders__c, Member__r.Age__c,Member__r.Balance__c,
            Member__r.Birthdate,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId,
            (SELECT
            Id,Name,Order__c,Product__c,Product_Name__c,Quantity__c,List_Price__c,Line_Total_Price__c,Total_Price__c,Notes__c,CreatedDate,LastModifiedDate,Product_Option__c,Product_Option__r.Product__c,Product_Option__r.Available_Stock_Quantity__c,Product_Option__r.Product__r.Enable_Order_Fullfillment__c
            FROM Order_Items__r) FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND (
            UUID__c =: orderIdOrUUID ) ];
            system.debug('currentOrderNDR'+ currentOrder);
        }
        return currentOrder;
    }
    
    public static PMA_SearchController.StripeApiTokensWrap fetchStripeApiToken(String recordId) {
        List<SYS_OAuthConfig__c> oauthList = new List<SYS_OAuthConfig__c>();
        SYS_OAuthConfig__c oauthRecord = new SYS_OAuthConfig__c();

        try{
             oauthList = [SELECT Id, Name, Account__c, Account__r.Name, Integration_Type__c,
                Grant_Type__c,
                Test_Mode__c, Client_Id__c, Access_Token__c FROM SYS_OAuthConfig__c WHERE Account__c =: recordId AND
                Integration_Type__c = 'Stripe'];
            oauthRecord = (oauthList.size()>0) ? oauthList[0] : new SYS_OAuthConfig__c();    
            PMA_SearchController.StripeApiTokensWrap tokensWrapper = new PMA_SearchController.StripeApiTokensWrap( oauthRecord.Account__r.Name, oauthRecord.Client_Id__c, oauthRecord.Access_Token__c, oauthRecord.Test_Mode__c );
            return tokensWrapper;
        }catch(Exception ex){
            throw new System.AuraHandledException(
                'Failed to Find SYS_OAuthConfig Record' + ex);
        }
    }
    public static Contact ContactrecordfetchUtility(string recordId) {
        Contact Contactdata;
        try {
          String Contactstring = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact') +
            +' FROM Contact WHERE (Id =: recordId)';
          system.debug('members serch' + Contactstring);
          Contactdata = Database.query(Contactstring);
          
          system.debug('fetchRecordNDR' + Contactdata);
    
        } catch (Exception e) {
          System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return (Contactdata != null) ? (Contactdata) : (new Contact());
      }

}