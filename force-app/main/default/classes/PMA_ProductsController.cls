public with sharing class PMA_ProductsController {
    public ToDo__c todorecord { get; set; }
    public string uuid { get; set; }
    private static TransactionService txnService = new TransactionService();
    private static StripeService stripeService = new StripeService();

    //Fetch All Categories
    @AuraEnabled
    public static List<Catalog__c> getAllCategorys(){
        List<Catalog__c> newCatList = new List<Catalog__c>();
        String newCat = 'SELECT ' + SYS_Helper.getAllFieldsFor('Catalog__c') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ', ' + SYS_Helper.getAllParentFields('Catalog__r.', 'Catalog__c') +
            +' FROM Catalog__c';

        newCatList = Database.query(newCat); 
        //newCatList = [SELECT Id,Name,Catalog__c,Catalog__r.Name,Account__c FROM Catalog__c]; 
        System.debug('newCatList ' + newCatList);
		return newCatList;
    }
    //To create Tip Order Item record
    @AuraEnabled
    public static Order__c createTipOrderItem(Id orderId, Decimal TipAmount, Decimal TipPercent) {
        Order__c currentOrder = PosUtility.createTipOrderItemUtility(orderId,TipAmount,TipPercent);
        return currentOrder;
    }
     //method for wallet money 
     @AuraEnabled
     public static Order_Item__c Paywithwallet(Order__C orderrecd, Decimal Discountedprice,Decimal walletbalance,Decimal deductionAmount) {
        List<Product_Option__c> optionRecords  = [SELECT Id,Name,Available_Stock_Quantity__c,Is_Option_Available__c,Option_Total_Price__c,Product__c,Product__r.Enable_Order_Fullfillment__c,IsDeleted,CreatedDate,LastModifiedDate FROM Product_Option__c WHERE Name = 'Wallet'];
        Product_Option__c optionRecord = new Product_Option__c();
        optionRecord = optionRecords[0];
       Order_Item__c  orderitem = new Order_Item__c();
        if(walletbalance>0){
        
         orderitem.Order__c = orderrecd.Id;
         orderitem.Total_Price__c = Discountedprice;
         orderitem.Item_Status__c = 'Closed';
         orderitem.Quantity__c = 1;
         if( optionRecord != null ){
            orderitem.Product_Option__c = optionRecord.Id;
        } 
         insert orderitem;
         Balance_Transaction__c balancetrance = new Balance_Transaction__c();
         balancetrance.Contact__c = orderrecd.Member__c;
         balancetrance.Type__c = 'Debit';
         balancetrance.Amount__c = deductionAmount;
         insert balancetrance;
         }
         return orderitem;
     }
   //To create Order Item records
   @AuraEnabled
   public static Order__c createOrderItems(Id orderId, String selectedProductsValues) {
    Order__c currentOrder = PosUtility.createOrderItemsutility(orderId,selectedProductsValues);
            return currentOrder;
   }
    //To create Payment Intent Record
    @AuraEnabled
    public static List<Payment_Intent__c> createPaymentFromOrder(Id orderId, Double paymentAmount ) {
        List<Payment_Intent__c> paymentRequests = new List<Payment_Intent__c>();
        Order__c order = new Order__c();
        order = [SELECT Id, Name, Account__c, Account__r.Name, Account__r.OwnerId, Account__r.Plivo_Country_Code__c,
            Account__r.Plivo_Sender_Id__c, Account__r.Plivo_PHLO_Id__c, Account__r.Phone, Account__r.Fax, Member__c,
            Member__r.Name, Member__r.Email, Member__r.Default_Payment_Method__c, Order_Type__c, Status__c, Vendor__c,
            Total_Price__c, UUID__c, CreatedDate, LastModifiedDate, OwnerId,
            (SELECT Id, Name, Line_Total_Price__c, List_Price__c, Order__c, Product__c, Quantity__c, Total_Price__c,
                CreatedDate, LastModifiedDate FROM Order_Items__r)
            FROM Order__c
            WHERE Id =: orderId AND ( (Status__c = 'Active') OR (Status__c = 'Draft') )
        ];
        System.debug('currentOrder  ' + order);
       
        //Payment Intent Init
        Date firstChargeDate = System.TODAY();
        String frequency = 'single';
        String paymentType = 'immediate';
        Id accountId = order.Account__c;
        Id contactId = order.Member__c;
        Double amount = paymentAmount;
        String email = order.Member__r.Email;
        String paymentName = 'Payment for '+order.Account__r.Name+' Services Rendered by ' + order.Member__r.Name;
        paymentRequests.add(PaymentIntentService.createNewPaymentIntent(paymentName , contactId, accountId, orderId, paymentType, amount, email, frequency, firstChargeDate));
        return paymentRequests;
    }
 //wallet amount deduction by orderlineitem creation with negitive amount



    @AuraEnabled
    public static Map<String, String> getIntegrationMetadata(Id accountRecordId,String IntegrationType){
        try {
            Map<String, String> IntegrationMetadata = new Map<String, String>();
            SYS_DataCacheFactory datacheMapofMetadata = new SYS_DataCacheFactory(new List<String>{accountRecordId}, IntegrationType, null, null);
            IntegrationMetadata = SYS_DataCacheFactory.metadata;
            System.debug(IntegrationMetadata);
            return IntegrationMetadata;
        } catch (Exception e) {
            throw new PMA_SearchController.SYS_AuthException(
                'Failed to Find Metadata Records', e);
        }
    }

    @AuraEnabled
    public static String createActivity(String messageBody, String messageSubject, String recordId) {
        Boolean invokeOutboundFlow = true;
        String type = 'sms';
        List<String> mediaUrls = new List<String>();
        String integrationSetting = 'Plivo';
        String fromPhone = ChatBotController.getDefaultPhoneNumber(integrationSetting);
        String toPhone, email;
        //Fetch Contact for Account Lookup 
        String findCustomerQuery = 'SELECT Id, Name, Email, Phone_Number__c, Formatted_Phone_Number__c, AccountId FROM Contact WHERE Id =:recordId LIMIT 1';
        List<Contact> findCustomer = Database.query(findCustomerQuery);
        if(findCustomer.size() > 0){
            toPhone = findCustomer[0].Formatted_Phone_Number__c;
            email = findCustomer[0].Email;
        }

        Activity__c activityCreate = CustomActivityService.createActivity(invokeOutboundFlow, type, mediaUrls, messageBody, messageSubject, fromPhone, toPhone, recordId);

        return (activityCreate != null) ? activityCreate.Id : null;
    }

    @AuraEnabled
    public static String calloutSynchronousOutbound(Id recId, String objSetting, String apexHandler, String direction, String accountMergeField) {
        String CalloutStatus = ChatBotController.calloutSynchronousOutbound(recId, objSetting, apexHandler, direction, accountMergeField);
        return CalloutStatus;
    }   

    //To Create Complimentary Transactions From Intent Record
    @AuraEnabled
    public static Transaction__c processComplimentaryPayment(Payment_Intent__c paymentRequest, Order__c currentOrderRecord) {
        System.debug('Payment request =' + paymentRequest );
        Transaction__c txn =  new Transaction__c();
        txn.Name =  paymentRequest.Name;  
        txn.Description__c = paymentRequest.Account__r.Name + ' Services Rendered';
        txn.Account__c = paymentRequest.Account__c;
        txn.Contact__c = paymentRequest.Contact__c;
        txn.Payment_Intent__c = paymentRequest.Id;
        txn.Amount__c = paymentRequest.Amount__c;
        txn.CurrencyCode__c = paymentRequest.Currency_Code__c;
        txn.TransactionDate__c = Datetime.now();
        txn.uuid__c = SYS_Helper.getUUID();
        txn.Status__c = 'succeeded';
        txn.Transaction_Type__c = 'Complimentary';
        if(currentOrderRecord.Member__r.AllowComplimentaryOrders__c==false)
        txn.Transaction_Type__c = 'Wallet';
        insert txn;
        //Mark Order Status Completed
        Order__c currentOrder = new Order__c();
        currentOrder.Id = paymentRequest.Order__C;
        currentOrder.Status__c = 'Completed';
        update currentOrder;
        //Mark Intent Status Completed
        paymentRequest.Status__c = 'payment_done';
        update paymentRequest;
        return txnService.getTransaction(txn.Id);
    }

    //To Process Payment From Intent Record
    @AuraEnabled
    public static Stripe.Payment processPaymentsByDefaultSource(List<Payment_Intent__c> paymentRequests, Stripe.UserPaymentRequest stripePaymentRequest) {
        System.debug('Payment request =' + paymentRequests +
                ', stripe payment request=' + stripePaymentRequest);
        Stripe.Payments paymentResponses = stripeService.processPayments(paymentRequests, stripePaymentRequest);
        return ( paymentResponses.payments.size() > 0 ) ? paymentResponses.payments[0] : paymentResponses.payments[0];
    }

    @AuraEnabled
    public static List<Stripe.Card> getUserPaymentMethods(Id contactId) {
        return stripeService.getPaymentMethods(contactId).cards;
    }

    //To Delete Order records
    @AuraEnabled
    public static Boolean deleteOrderRecord(Id orderId) {
        Order__c orderRecord = PMA_SearchController.getOrderDetailsByIdOrUUID(orderId);
        System.debug('orderRecord  ' + orderRecord);
        delete orderRecord;
        return true;
    }
    //To Delete Order Item record
    @AuraEnabled
    public static Order__c deleteOrderItem(Id orderId, Id orderItemId) {
        Order__c checkOrderStatus = PMA_SearchController.getOrderDetailsByIdOrUUID(orderId);
        System.debug('checkOrderStatus  ' + checkOrderStatus);
        List < Order_Item__c > orderItemList = new List < Order_Item__c > ();
        for (Order_Item__c currentOrderItem: checkOrderStatus.Order_Items__r) {
            if(currentOrderItem.Id == orderItemId){
                orderItemList.add(currentOrderItem);
            }
        }
        System.debug('orderItemList  ' + orderItemList);
        delete orderItemList;

        Order__c currentOrder = PMA_SearchController.getOrderDetailsByIdOrUUID(orderId);
        System.debug('currentOrder  ' + currentOrder);
        return currentOrder;
    }
    //To Delete Order Item record
    @AuraEnabled
    public static list<Order_Item__c> updateOrderItem(Id orderId, Id orderItemId) {
        Order__c checkOrderStatus = PMA_SearchController.getOrderDetailsByIdOrUUID(orderId);
        System.debug('checkOrderStatus  ' + checkOrderStatus);
        List < Order_Item__c > orderItemList = new List < Order_Item__c > ();
        for (Order_Item__c currentOrderItem: checkOrderStatus.Order_Items__r) {
            if(currentOrderItem.Id == orderItemId){
                Decimal quantity = currentOrderItem.Quantity__c;
                Decimal updatedQuantity =  quantity + 1;
                Decimal totalprice =  currentOrderItem.List_Price__c * updatedQuantity;
                system.debug('totalprice'+totalprice);
                currentOrderItem.Total_Price__c = totalprice;
                currentOrderItem.Quantity__c = updatedQuantity ;
                orderItemList.add(currentOrderItem);
            }
        }
        System.debug('orderItemList  ' + orderItemList);
        update orderItemList;
        return orderItemList;


    }
    //To Return Transaction Details
    @AuraEnabled
    public static Transaction__c getTransactionDetails(Id txId) {
        Transaction__c txn = txnService.getTransaction(txId);
        return txn;
    }

    //To return initial records
    @AuraEnabled
    public static Map<Id, SelectedProductWrapper> getAllProductRecords( String orderIdOrUUID ) {
        List<Product__c> productsList = new List<Product__c>();
        Map <Id, SelectedProductWrapper > mapProductsList = new Map <Id, SelectedProductWrapper >();
        Order__c currentOrder = PMA_SearchController.getOrderDetailsByIdOrUUID( orderIdOrUUID );
        Decimal memberAge = currentOrder.Member__r.Age__c;

        try {           
            String product = 'SELECT ' + SYS_Helper.getAllFieldsFor('CatalogItem__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            	', ' + SYS_Helper.getAllParentFields('Catalog__r.', 'Catalog__c') +
                ', ' + SYS_Helper.getAllParentFields('Catalog__r.Catalog__r.', 'Catalog__c') +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Product_Option__c') + ' FROM Product_Option__r)' +
                ' FROM CatalogItem__c WHERE Name != \'Tip\' AND Name != \'Wallet\' AND Product_Family__c = \'POS\' AND Is_options_Available__c > 0 ORDER BY Name ASC';
            productsList = Database.query(product); 
           system.debug('productsList:::'+ productsList);
            //Init Record Picture Urls
            List<Id> WhattIdsList = new List<Id>(); 
            for( Product__c prod: productsList){
                WhattIdsList.add(prod.Id);
            }             
            Map<Id, String> WhattIdRecordImagesMap = ImageController.loadWhattIdRecordImagesMap(WhattIdsList);

            for( Product__c prod: productsList){

                String recordPictureURL = WhattIdRecordImagesMap.get(prod.Id);
                recordPictureURL = (String.IsNotBlank(recordPictureURL)) ? recordPictureURL : 'noimage';
                System.debug('Prod Name ' + prod.Name + ' recordPictureURL '+ recordPictureURL);
                Decimal prodAge = ( prod.Special_Status__c == true ) ? ( prod.Special_Minimum_Age__c ) :  (prod.Minimum_Age__c);
                Boolean prodVisible = ( ( prodAge == null ) || ( prodAge <= memberAge) ) ? true : false;                
                SelectedProductWrapper selectedproduct = new SelectedProductWrapper();
                selectedproduct.baseproduct = prod;
                selectedproduct.optionsCount = prod.Product_Option__r.size();
                selectedproduct.quantity = 1;
                selectedproduct.isVisible = prodVisible;
                selectedproduct.prodMinimumAge = prodAge;
                selectedproduct.shortNameCode = ImageController.getShortendImageName(prod.Name);
                selectedproduct.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
                selectedproduct.pictureURL = recordPictureURL;

                Map<Id, Map <Id, SelectedProductWrapper > > iterProductMapOptionsWrapper = new Map<Id, Map <Id, SelectedProductWrapper > >();

                Map<Id, SelectedProductWrapper > mapProductOptionsList = new Map<Id, SelectedProductWrapper >();
                for( Product_Option__c prodOption: prod.Product_Option__r){
                     recordPictureURL = WhattIdRecordImagesMap.get(prodOption.Id);
                     recordPictureURL = (String.IsNotBlank(recordPictureURL)) ? recordPictureURL : 'noimage';
                    // System.debug('Prod Name ' + prodOption.Name + ' recordPictureURL '+ recordPictureURL);
                    // Decimal prodAge = ( prodOption.Product__r.Special_Status__c == true ) ? ( prodOption.Product__r.Special_Minimum_Age__c ) :  (prodOption.Product__r.Minimum_Age__c);
                    // Boolean prodVisible = ( ( prodAge == null ) || ( prodAge <= memberAge) ) ? true : false;                
                    SelectedProductWrapper iterSelectedproductOption = new SelectedProductWrapper();
                    iterSelectedproductOption.product = prodOption;
                    iterSelectedproductOption.quantity = 1;
                    iterSelectedproductOption.isVisible = prodVisible;
                    iterSelectedproductOption.prodMinimumAge = prodAge;
                    iterSelectedproductOption.shortNameCode = ImageController.getShortendImageName(prodOption.Name);
                    iterSelectedproductOption.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
                    iterSelectedproductOption.pictureURL = recordPictureURL;
                    mapProductOptionsList.put(prodOption.Id, iterSelectedproductOption);
                }
                if (mapProductOptionsList.size() > 0) {
                    iterProductMapOptionsWrapper.put(prod.Id, mapProductOptionsList);
                    selectedproduct.productMapOptionsWrapper = iterProductMapOptionsWrapper;
                    mapProductsList.put(prod.Id, selectedproduct);
                } else {
                    SelectedProductWrapper selectedStandaloneproduct = new SelectedProductWrapper();
                    selectedStandaloneproduct.baseproduct = prod;
                    selectedStandaloneproduct.quantity = 1;
                    selectedStandaloneproduct.isVisible = true;
                    selectedStandaloneproduct.prodMinimumAge = 9999;
                    selectedStandaloneproduct.shortNameCode = ImageController.getShortendImageName(prod.Name);
                    selectedStandaloneproduct.hasPictureURL = false;
                    selectedStandaloneproduct.pictureURL = 'noimage';
                    selectedStandaloneproduct.productPrice = 0;
                    selectedStandaloneproduct.totalProductPrice = 0;
                    selectedStandaloneproduct.availableStockQuantity = 0;
                    mapProductOptionsList.put(prod.Id, selectedStandaloneproduct);
                    iterProductMapOptionsWrapper.put(prod.Id, mapProductOptionsList);

                    selectedproduct.productMapOptionsWrapper = iterProductMapOptionsWrapper;
                    mapProductsList.put(prod.Id, selectedproduct);
                    
                }
                system.debug(mapProductsList);
            }
        } catch (Exception e) {
            //TODO add  to wrapper to pmaexception wrapper(class,method ,exception) and insert into log
            System.debug('Got Exception: ' + e.getMessage());
        }
        return mapProductsList;
    }
    @AuraEnabled(cacheable=true)
    public static Map<Id, SelectedProductWrapper> initialproductsfetch() {
        List<Product__c> productsList = new List<Product__c>();
        Map <Id, SelectedProductWrapper > mapProductsList = new Map <Id, SelectedProductWrapper >();
        try {           
            String product = 'SELECT ' + SYS_Helper.getAllFieldsFor('CatalogItem__c') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ', ' + SYS_Helper.getAllParentFields('Catalog__r.', 'Catalog__c') +
            ', ' + SYS_Helper.getAllParentFields('Catalog__r.Catalog__r.', 'Catalog__c') +
            ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Product_Option__c') + ' FROM Product_Option__r)' +
            ' FROM CatalogItem__c WHERE Name != \'Tip\' AND Name != \'Wallet\' AND Product_Family__c = \'POS\' AND Is_options_Available__c > 0 ORDER BY Name ASC';
        productsList = Database.query(product); 
       system.debug('productsList:::'+ productsList);
            //Init Record Picture Urls
            List<Id> WhattIdsList = new List<Id>(); 
            for( Product__c prod: productsList){
                WhattIdsList.add(prod.Id);
            }             
            Map<Id, String> WhattIdRecordImagesMap = ImageController.loadWhattIdRecordImagesMap(WhattIdsList);

            for( Product__c prod: productsList){

                String recordPictureURL = WhattIdRecordImagesMap.get(prod.Id);
                recordPictureURL = (String.IsNotBlank(recordPictureURL)) ? recordPictureURL : 'noimage';
                System.debug('Prod Name ' + prod.Name + ' recordPictureURL '+ recordPictureURL);
                Decimal prodAge = ( prod.Special_Status__c == true ) ? ( prod.Special_Minimum_Age__c ) :  (prod.Minimum_Age__c);
                Boolean prodVisible = true;                
                SelectedProductWrapper selectedproduct = new SelectedProductWrapper();
                selectedproduct.baseproduct = prod;
                selectedproduct.optionsCount = prod.Product_Option__r.size();
                selectedproduct.quantity = 1;
                selectedproduct.isVisible = prodVisible;
                selectedproduct.prodMinimumAge = prodAge;
                selectedproduct.shortNameCode = ImageController.getShortendImageName(prod.Name);
                selectedproduct.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
                selectedproduct.pictureURL = recordPictureURL;

                Map<Id, Map <Id, SelectedProductWrapper > > iterProductMapOptionsWrapper = new Map<Id, Map <Id, SelectedProductWrapper > >();

                Map<Id, SelectedProductWrapper > mapProductOptionsList = new Map<Id, SelectedProductWrapper >();
                for( Product_Option__c prodOption: prod.Product_Option__r){
                     recordPictureURL = WhattIdRecordImagesMap.get(prodOption.Id);
                     recordPictureURL = (String.IsNotBlank(recordPictureURL)) ? recordPictureURL : 'noimage';
                    // System.debug('Prod Name ' + prodOption.Name + ' recordPictureURL '+ recordPictureURL);
                    // Decimal prodAge = ( prodOption.Product__r.Special_Status__c == true ) ? ( prodOption.Product__r.Special_Minimum_Age__c ) :  (prodOption.Product__r.Minimum_Age__c);
                    // Boolean prodVisible = ( ( prodAge == null ) || ( prodAge <= memberAge) ) ? true : false;                
                    SelectedProductWrapper iterSelectedproductOption = new SelectedProductWrapper();
                    iterSelectedproductOption.product = prodOption;
                    iterSelectedproductOption.quantity = 1;
                    iterSelectedproductOption.isVisible = prodVisible;
                    iterSelectedproductOption.prodMinimumAge = prodAge;
                    iterSelectedproductOption.shortNameCode = ImageController.getShortendImageName(prodOption.Name);
                    iterSelectedproductOption.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
                    iterSelectedproductOption.pictureURL = recordPictureURL;
                    mapProductOptionsList.put(prodOption.Id, iterSelectedproductOption);
                }
                if (mapProductOptionsList.size() > 0) {
                    iterProductMapOptionsWrapper.put(prod.Id, mapProductOptionsList);
                    selectedproduct.productMapOptionsWrapper = iterProductMapOptionsWrapper;
                    mapProductsList.put(prod.Id, selectedproduct);
                } else {
                    SelectedProductWrapper selectedStandaloneproduct = new SelectedProductWrapper();
                    selectedStandaloneproduct.baseproduct = prod;
                    selectedStandaloneproduct.quantity = 1;
                    selectedStandaloneproduct.isVisible = true;
                    selectedStandaloneproduct.prodMinimumAge = 9999;
                    selectedStandaloneproduct.shortNameCode = ImageController.getShortendImageName(prod.Name);
                    selectedStandaloneproduct.hasPictureURL = false;
                    selectedStandaloneproduct.pictureURL = 'noimage';
                    selectedStandaloneproduct.productPrice = 0;
                    selectedStandaloneproduct.totalProductPrice = 0;
                    selectedStandaloneproduct.availableStockQuantity = 0;
                    mapProductOptionsList.put(prod.Id, selectedStandaloneproduct);
                    iterProductMapOptionsWrapper.put(prod.Id, mapProductOptionsList);

                    selectedproduct.productMapOptionsWrapper = iterProductMapOptionsWrapper;
                    mapProductsList.put(prod.Id, selectedproduct);
                    
                }
                system.debug(mapProductsList);
            }
        } catch (Exception e) {
            //TODO add  to wrapper to pmaexception wrapper(class,method ,exception) and insert into log
            System.debug('Got Exception: ' + e.getMessage());
        }
        return mapProductsList;
    }
    @AuraEnabled
    public static Order__c getOrderDetails( String orderIdOrUUID ){
        Order__c currentOrder = PMA_SearchController.getOrderDetailsByIdOrUUID( orderIdOrUUID );
        return currentOrder;
    }
    
    //To Return Contact Details
    @AuraEnabled
    public static Contact getContactDetails(String recordId) {
        Contact cont = new Contact();
        if(String.isNotBlank(recordId)){
            cont = ChatBotController.getContactDetails(recordId);
        }
        return cont;
    }
  
    @AuraEnabled
    public static User fetchCurrentUser() {
        // query current user information  
        User currentUserRecord = PMA_SearchController.fetchCurrentUser();

        return currentUserRecord;
    }
    @AuraEnabled
    public static Stripe.PaymentMethods getmemberPaymentMethods(Id contactId) {
        return stripeService.getPaymentMethods(contactId);
    }
    // wrapper class selectedProduct.PricebookEntries[0].UnitPrice -- 
    public class SelectedProductWrapper {
        @AuraEnabled
        public Integer quantity = 0;
        @AuraEnabled
        public Product_Option__c product = new Product_Option__c ();
        @AuraEnabled
        public Product__c baseproduct = new Product__c ();
        
        @AuraEnabled
        public Map<Id, Map <Id, SelectedProductWrapper > > productMapOptionsWrapper = new Map <Id, Map <Id, SelectedProductWrapper > >();
        @AuraEnabled
        public Integer optionsCount = 0;
       
        @AuraEnabled
        public Double productPrice{
            get { if(optionsCount > 0 && product != null){
                productPrice = product.Option_Total_Price__c;
              
            }else{
                productPrice = baseproduct.Default_Price__c;
            }
            return  productPrice;
                }set{}
        }
        @AuraEnabled
        public Double totalProductPrice{
            get { return (productPrice != null) ? productPrice * quantity : 0; }set{}
        }
        @AuraEnabled
        public Double availableStockQuantity{
            get { if( product != null){
                availableStockQuantity = product.Available_Stock_Quantity__c;
            }else{
                availableStockQuantity = baseproduct.Available_Stock_Quantity__c ;
            }
            return availableStockQuantity;
        }set{}
        }
        @AuraEnabled
        public Boolean isVisible;
        @AuraEnabled
        public Decimal prodMinimumAge;
        @AuraEnabled
        public String orderNotes;
        @AuraEnabled
        public String shortNameCode;
        @AuraEnabled
        public Boolean hasPictureURL = false;
        @AuraEnabled
        public String pictureURL;
    }
}