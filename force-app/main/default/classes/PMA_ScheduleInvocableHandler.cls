global without sharing class PMA_ScheduleInvocableHandler {
    
    global class MyInvocableVariable {
        @InvocableVariable(label='Contact Id' required=true)  
        global Id recId;
    
        @InvocableVariable(label='Contact Current Value' required=true)
        global Contact newVal;

        @InvocableVariable(label= 'Order Type' description='mention the order type to create order, if order Id is missing.' required = true)
        global String orderType;
    }

    @InvocableMethod(label='Capture and Create Subscrption Order and Subscription' description='To Create Subscription Order and Subscription')
    global static void captureContactChangeRequest(List<MyInvocableVariable> myInvocableVariableList) {
        if(myInvocableVariableList.size() == 0) return;

        List<Id> catalogIds = new List<Id>();
        try {
            for(MyInvocableVariable var:myInvocableVariableList) {
                Id catalogId = var.newVal?.Subscribed_Products_Catalog__c != NULL ?
                var.newVal?.Subscribed_Products_Catalog__c : var.newVal?.Account.Subscription_Products_Catalog__c;
                catalogIds.add(catalogId);
            }
            System.debug('SP catalogIds'+catalogIds);
            Map<String, Map<String, Product_Option__c>> catalogOptionMap = getCatalogOptionMap(catalogIds);

        
            for(MyInvocableVariable var:myInvocableVariableList) { 
                Id catalogId = var.newVal?.Subscribed_Products_Catalog__c != NULL ?
                var.newVal?.Subscribed_Products_Catalog__c : var.newVal?.Account.Subscription_Products_Catalog__c;
                if(Limits.getDMLStatements() < 100) {
                    System.debug('SP map '+catalogOptionMap.get(catalogId));
                    createOrder(var, catalogOptionMap.get(catalogId));
                } 
            }
        } catch(Exception e) {
            System.debug('Error '+e.getStackTraceString()+e.getmessage());
            handleError(e);
        }
    }

    public static String getBillingFrequency(String optionRecordId){
        String subscriptionFrequency = 'month';
        if(String.isNotBlank(optionRecordId)) {
            List<Product_Option_Component__c> subscriptionOptionComponentRecord = [SELECT Id, Product_Option__c, Billing_Frequency__c FROM Product_Option_Component__c WHERE Product_Option__c =: optionRecordId LIMIT 1];
            if(subscriptionOptionComponentRecord.size() > 0) {
                subscriptionFrequency = subscriptionOptionComponentRecord[0].Billing_Frequency__c;
            }
        } 
        return subscriptionFrequency;
    }

    public static void createOrder(MyInvocableVariable var, Map<String, Product_Option__c> planOptionRecordMap) {

        Boolean createNewSubscriptionOrder = false;
        if( (var.newVal?.Member_Type__c == 'Subscriber') && (planOptionRecordMap.containsKey('Initiation Fees')) && (planOptionRecordMap.containsKey('Membership Fees')) && (planOptionRecordMap.containsKey('Family Add-on')) ){
            Decimal initaitonProductPrice = planOptionRecordMap.get('Initiation Fees')?.Option_Total_Price__c;
            Decimal membershipProductPrice = planOptionRecordMap.get('Membership Fees')?.Option_Total_Price__c;
            Decimal familyaddonProductPrice = planOptionRecordMap.get('Family Add-on')?.Option_Total_Price__c;
            String contactMembershipType = var.newVal?.Membership_Type__c;//Individual Family

            if( (contactMembershipType == 'Individual') && (membershipProductPrice != 0.0) ){
                createNewSubscriptionOrder = true;
            }
            if( (contactMembershipType == 'Family') && (familyaddonProductPrice != 0.0) ){
                createNewSubscriptionOrder = true;
            }
        }

        if(createNewSubscriptionOrder){
            Order__c order = new Order__c(
                Account__c = var.newVal.AccountId,
                Member__c = var.newVal.Id,
                Order_Type__c = var.orderType,
                Status__c = 'Active'
            );
            order.UUID__c = SYS_Helper.getUUID();
            
            Database.insert(order);
        
            if(order.Id != NULL && (var.newVal?.Member_Type__c == 'Subscriber') && (planOptionRecordMap.containsKey('Initiation Fees')) && (planOptionRecordMap.containsKey('Membership Fees')) && (planOptionRecordMap.containsKey('Family Add-on'))) {
                
                insertOrderLineItems(planOptionRecordMap, var.newVal, order);
                Order__c fetchorder = [SELECT Id, Name, Member__c, Account__c, Account__r.Name, Account__r.OwnerId,
                                        Account__r.Plivo_Country_Code__c, Account__r.Plivo_Sender_Id__c, Account__r.Plivo_PHLO_Id__c,
                                        Account__r.Phone, Account__r.Fax, Account__r.Subscription_Products_Catalog__c,
                                        Member__r.Member_Type__c, Member__r.Membership_Type__c,
                                        Order_Type__c, Status__c, Vendor__c, Total_Price__c, UUID__c,
                                        CreatedDate, LastModifiedDate, OwnerId,
                                        (SELECT Id, Name, Line_Total_Price__c, List_Price__c, Order__c, Product_Option__c, Product_Option__r.Name,
                                        Product_Option__r.Product__c,Product_Option__r.Product__r.Product_Family__c, Product_Option__r.Product__r.Plan__c, Quantity__c, Total_Price__c, CreatedDate, LastModifiedDate FROM Order_Items__r)
                                        FROM Order__c
                                        WHERE Id =: order.Id AND(Order_Type__c = 'Subscription') AND(Status__c = 'Active')
                                        ];
                createSubscription(fetchorder);

            }
        }
            
    }

    public static void createSubscription(Order__c order) {
        String billingFrequency;
        //Fetch Billing Frequency for MemberShip Product
        for(Order_Item__c iterOrderItem : order.Order_Items__r) {
            if( isMembershipProduct(iterOrderItem?.Product_Option__r?.Product__r?.Plan__c) && (iterOrderItem?.Product_Option__r?.Product__r?.Plan__c == 'Membership Fees') ) {
                String membershipProductOptionId = iterOrderItem?.Product_Option__c;
                billingFrequency = getBillingFrequency(membershipProductOptionId);
            }
        }

        Subscription__c sub = new Subscription__c();
        sub.Account__c = order.Account__c;
        sub.Contact__c = order.Member__c;
        sub.PMA_Order__c = order.Id;
        Datetime subscriptionDatetime = Datetime.now();
        if(billingFrequency == 'day') {
            subscriptionDatetime = subscriptionDatetime.addDays(1);
            sub.Start_Date__c = subscriptionDatetime?.addHours(3);
        } else if(billingFrequency == 'week') {
            subscriptionDatetime = subscriptionDatetime.addDays(7);
            sub.Start_Date__c = subscriptionDatetime?.addHours(3);
        } else if(billingFrequency == 'month') {
            subscriptionDatetime = subscriptionDatetime.addMonths(1);
            sub.Start_Date__c = Datetime.newInstance(subscriptionDatetime.year(), subscriptionDatetime.month(), 1 )?.addHours(3);
        } else { // if(billingFrequency == 'year')
            subscriptionDatetime = subscriptionDatetime.addYears(1);
            sub.Start_Date__c = Datetime.newInstance(subscriptionDatetime.year(), subscriptionDatetime.month(), 1 )?.addHours(3);
            sub.Start_Date__c = subscriptionDatetime?.addHours(3);
        }        

        insert sub;
        List<Subscription_Item__c> items = new List<Subscription_Item__c>();
        System.debug('SP oi'+order.Order_Items__r?.size());
        for(Order_Item__c oi:order.Order_Items__r) {
            System.debug('SP oi'+oi.Product_Option__r.Product__r.Plan__c);
            if(isMembershipProduct(oi?.Product_Option__r?.Product__r?.Plan__c)) {
                Subscription_Item__c si = new Subscription_Item__c();
                si.Subscription__c = sub.Id;
                si.Quantity__c = oi.Quantity__c;
                si.Price__c = getPriceId(oi.Product_Option__c);
                items.add(si);
            }
        }
        insert items;
        

    }

    //TODO -move it to integration metadata
    private static Boolean isMembershipProduct(String planName) {
        String keys = 'Membership Fees,Family Add-on';
        for(String key:keys.split(',')) {
            if(planName?.contains(key)) {
                return true;
            }
        }
        return false;
    }

    private static String getPriceId(String productId){
        String priceId;
        List<Product_Option_Component__c> price = [SELECT id from Product_Option_Component__c 
                                                    WHERE Product_Option__c = :productId LIMIT 1];
        if(price.size() > 0) {
            priceId = price[0].Id;
        }
        return priceId;
    }

    private static void handleError(Exception e) {
        SYS_IntegrationLog__c errorLog = new SYS_IntegrationLog__c();
        errorLog.data0__c = 'Exception type :' + e.getTypeName() +' Error in Creation of Subscription';
        errorLog.Message__c = e.getStackTraceString()+' : '+e.getMessage()+' : '+e.getCause();
        errorLog.Type__c = 'RESPONSE';
        errorLog.Status__c = 'ERROR';
        errorLog.How_To_Process__c = 'ignore_log';
        Database.insert(errorLog);
    }

    private static void insertOrderLineItems(Map<String, Product_Option__c> planOptionRecordMap, Contact contactRecordnewVal, Order__c order) {
        Boolean enableInitFeeProductOrderTracking, enableMembershipProductOrderTracking, enableFamilyAddonProductOrderTracking = false; 
        List < Order_Item__c > OrderItemsList = new List < Order_Item__c >();    
        Id orderId = order.Id;
        // Plan Types -- Initiation Fees  Membership Fees  Family Add-on
        enableInitFeeProductOrderTracking = planOptionRecordMap.get('Initiation Fees')?.Product__r?.Enable_Order_Fullfillment__c;
        enableMembershipProductOrderTracking = planOptionRecordMap.get('Membership Fees')?.Product__r?.Enable_Order_Fullfillment__c;
        enableFamilyAddonProductOrderTracking = planOptionRecordMap.get('Family Add-on')?.Product__r?.Enable_Order_Fullfillment__c;

        if(contactRecordnewVal.Active__c == false){
            //Instantiate InitiationFee OrderItem          
            Order_Item__c InitFeesOrderItemRecord = new Order_Item__c();
            InitFeesOrderItemRecord.Order__c = orderId;
            InitFeesOrderItemRecord.Product_Option__c = planOptionRecordMap.get('Initiation Fees').Id;
            InitFeesOrderItemRecord.Quantity__c = 1;
            InitFeesOrderItemRecord.Total_Price__c =  planOptionRecordMap.get('Initiation Fees').Option_Total_Price__c;
            InitFeesOrderItemRecord.Item_Status__c = (enableInitFeeProductOrderTracking == TRUE) ? 'New' : 'Closed';
            
            System.debug(InitFeesOrderItemRecord);
            OrderItemsList.add(InitFeesOrderItemRecord);
        }
                    
        //Instantiate MembershipFee OrderItem
        Order_Item__c MembershipFeeOrderItemRecord = new Order_Item__c();
        MembershipFeeOrderItemRecord.Order__c = orderId;
        MembershipFeeOrderItemRecord.Product_Option__c = planOptionRecordMap.get('Membership Fees').Id;
        MembershipFeeOrderItemRecord.Quantity__c = 1;
        MembershipFeeOrderItemRecord.Total_Price__c = planOptionRecordMap.get('Membership Fees').Option_Total_Price__c;
        MembershipFeeOrderItemRecord.Item_Status__c = (enableMembershipProductOrderTracking == TRUE) ? 'New' : 'Closed';
        
        System.debug(MembershipFeeOrderItemRecord);
        OrderItemsList.add(MembershipFeeOrderItemRecord);
        if(contactRecordnewVal.Membership_Type__c == 'Family'){
            //Instantiate Family Add-on OrderItem
            Order_Item__c FamilyAddonFeeOrderItemRecord = new Order_Item__c();
            FamilyAddonFeeOrderItemRecord.Order__c = orderId;
            FamilyAddonFeeOrderItemRecord.Product_Option__c = planOptionRecordMap.get('Family Add-on').Id;
            FamilyAddonFeeOrderItemRecord.Quantity__c = 1;
            FamilyAddonFeeOrderItemRecord.Total_Price__c = planOptionRecordMap.get('Membership Fees').Option_Total_Price__c;
            FamilyAddonFeeOrderItemRecord.Item_Status__c = (enableFamilyAddonProductOrderTracking == TRUE) ? 'New' : 'Closed';
            
            System.debug(FamilyAddonFeeOrderItemRecord);
            OrderItemsList.add(FamilyAddonFeeOrderItemRecord);
        }
        if(OrderItemsList.size()>0){
            System.debug('Order__c '+Schema.sObjectType.Order_Item__c.fields.Order__c.isCreateable());
            System.debug('Total_Price__c '+Schema.sObjectType.Order_Item__c.fields.Total_Price__c.isCreateable());
            System.debug('Item_Status__c '+Schema.sObjectType.Order_Item__c.fields.Item_Status__c.isCreateable());
            System.debug('Quantity__c '+Schema.sObjectType.Order_Item__c.fields.Quantity__c.isCreateable());
            System.debug('Order_Item__c obj access'+Order_Item__c.sObjectType.getDescribe().accessible);
            Database.insert(OrderItemsList, false);
        }
        
    }

    private static Map<String, Map<String, Product_Option__c>> getCatalogOptionMap(List<Id> catalogIds) {
        
        Map<String, Map<String, Product_Option__c>> catalogOptionMap = new Map<String, Map<String, Product_Option__c>>();

        List<Product_Option__c> membershipProductsList = [SELECT Id, Name, Option_Total_Price__c, Product__c, Available_Stock_Quantity__c,
                    Is_Option_Available__c, CreatedDate, LastModifiedDate,
                    Product__r.Name, Product__r.Catalog__c, Product__r.Catalog__r.Name, Product__r.Catalog__r.Catalog__c,
                    Product__r.Catalog__r.Catalog__r.Name, Product__r.Unit_Price__c, Product__r.Account__c,
                    Product__r.Account__r.Name, Product__r.Active__c, Product__r.Contact__c,
                    Product__r.Enable_Order_Fullfillment__c, Product__r.Minimum_Age__c, Product__r.Special_Minimum_Age__c,
                    Product__r.Special_Status__c, Product__r.Product_Code__c, Product__r.Product_Description__c,
                    Product__r.Product_Family__c, Product__r.Plan__c, Product__r.Product_SKU__c,
                    Product__r.Quantity_Unit_Of_Measure__c, Product__r.UUID__c, Product__r.Allow_scheduling__c,
                    Product__r.Stripe_Product_Id__c, Product__r.Stripe_Product_Default_Price__c, Product__r.OwnerId,
                    Product__r.CreatedDate, Product__r.LastModifiedDate
                    FROM Product_Option__c WHERE Product__r.Product_Family__c = 'Membership Fees'
                    AND Product__r.Catalog__c in: catalogIds ORDER BY Name ASC
                ];
        System.debug('catalog '+membershipProductsList.size());
        for(Id catalog:catalogIds) {
            Map<String, Product_Option__c> planOptionRecordMap = new Map<String, Product_Option__c>();
            for(Product_Option__c optionRec:membershipProductsList){
                if( !planOptionRecordMap.containsKey(optionRec.Product__r.Plan__c) ){
                    planOptionRecordMap.put(optionRec.Product__r.Plan__c, optionRec);
                }
            }
            if(!catalogOptionMap.containsKey(catalog)) {
                catalogOptionMap.put(catalog, planOptionRecordMap);
            }
        }

        return catalogOptionMap;
    }
}