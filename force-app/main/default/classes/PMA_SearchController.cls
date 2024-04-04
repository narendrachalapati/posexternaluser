public without sharing class PMA_SearchController {
    // wrapper class membersOrdersWrapper
    public class membersOrdersWrapper {
        @AuraEnabled
        public Order__c order = new Order__c();
        @AuraEnabled
        public Contact member = new Contact();
        @AuraEnabled
        public String shortNameCode;
        @AuraEnabled
        public Boolean hasPictureURL = false;
        @AuraEnabled
        public String pictureURL;
    }

    @AuraEnabled
    public static List<membersOrdersWrapper> getOpenTabMembers(){
     
        List<Order__c> ordersList = new List< Order__c >();
        List<membersOrdersWrapper> orderWrapperList = new List<membersOrdersWrapper>();
        
        ordersList = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c,Member__r.Age__c,Member__r.Subscribed_Products_Catalog__r.Name,Member__r.Subscribed_Products_Catalog__r.Priority__c,Member__r.Subscribed_Products_Catalog__r.Subscription_colour__c,Member__r.Subscribed_Products_Catalog__c,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND ( Status__c != 'Closed' ) ];
        System.debug('ordersList '  + ordersList);

        //Init Record Picture Urls
        List<Id> WhattIdsList = new List<Id>(); 
        Set<Id> WhattIdsSet = new Set<Id>(); 
        for(Order__c order: ordersList){
            WhattIdsSet.add(order.Member__c);
        }
        WhattIdsList.addAll(WhattIdsSet);
        Map<Id, String> WhattIdRecordImagesMap = ImageController.loadWhattIdRecordImagesMap(WhattIdsList);

        for(Order__c order: ordersList){
            String recordPictureURL = WhattIdRecordImagesMap.get(order.Member__c);
            recordPictureURL = (String.IsNotBlank(recordPictureURL)) ? recordPictureURL : 'noimage';
            System.debug('Member Name ' + order.Member__r.Name + ' recordPictureURL '+ recordPictureURL);
            membersOrdersWrapper currentOrder = new membersOrdersWrapper();
            currentOrder.order = order;
            currentOrder.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
            currentOrder.shortNameCode = ImageController.getShortendImageName(order.Member__r.Name);
            currentOrder.pictureURL = recordPictureURL;
            orderWrapperList.add(currentOrder);
        }
        return orderWrapperList;
    }
    @AuraEnabled
    public static List<membersOrdersWrapper> searchActiveMembers(String keyword){
        List<membersOrdersWrapper> memberWrapperList = new List<membersOrdersWrapper>();
        List<Order__c> ordersList = new List< Order__c >();
        Set<Id> memberIds= new Set<Id>();
        List < Contact > membersList = new List< Contact >();
        
        ordersList = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c, Member__r.Default_Payment_Method__c,Member__r.Subscribed_Products_Catalog__r.Name,Member__r.Subscribed_Products_Catalog__c,Member__r.Subscribed_Products_Catalog__r.Subscription_colour__c,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId FROM Order__c WHERE ( Order_Type__c = 'POS' ) AND ( Status__c != 'Completed' ) AND ( Status__c != 'Closed' ) ];
        for(Order__c iterOrder : ordersList){
            memberIds.add(iterOrder.Member__c);
       }

        //Init Record Picture Urls
        List<Id> WhattIdsList = new List<Id>(); 
        WhattIdsList.addAll(memberIds);
        Map<Id, String> WhattIdRecordImagesMap = ImageController.loadWhattIdRecordImagesMap(WhattIdsList);
       
        RecordType memberRecordType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Member'];
        String memberRecordTypeId = (memberRecordType!=null) ? memberRecordType.Id : '' ;
        if(String.isNotBlank(memberRecordTypeId) && String.isNotBlank(keyword)){
            string tempkeyword= '%' + keyword + '%';

            String members = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact') +
            ', ' + SYS_Helper.getAllParentFields('Subscribed_Products_Catalog__r.', 'Catalog__c') +
            ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Subscription__c') + ' FROM Subscriptions__r)'
            
            + ' FROM Contact WHERE (RecordTypeId =: memberRecordTypeId) AND (Active__c = TRUE) AND ( (Phone_Number__c LIKE : tempkeyword ) OR ( LastName LIKE : tempkeyword )  OR ( FirstName LIKE : tempkeyword ) ) AND (Id NOT IN  : memberIds) LIMIT 15';
            system.debug('members serch' + members);
            membersList = Database.query(members); 

            
                System.debug('searched keyword'+ keyword);
                System.debug('searched membersList'+ membersList);
                for(Contact member : membersList){
                    String recordPictureURL = WhattIdRecordImagesMap.get(member.Id);
                    recordPictureURL = (String.IsNotBlank(recordPictureURL)) ? recordPictureURL : 'noimage';
                    System.debug('Member Name ' + member.Name + ' recordPictureURL '+ recordPictureURL);
                    membersOrdersWrapper currentMember = new membersOrdersWrapper();
                    currentMember.member = member;
                    currentMember.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
                    currentMember.shortNameCode = ImageController.getShortendImageName(member.Name);
                    currentMember.pictureURL = recordPictureURL;
                    memberWrapperList.add(currentMember);   
                }
        }
        return memberWrapperList; 
    }
    @AuraEnabled
    public static Order__c getOrderDetailsByIdOrUUID( String orderIdOrUUID ){
        Order__c currentOrder = new Order__c();
        currentOrder = PosUtility.getOrderDetailsByIdOrUUIDutility(orderIdOrUUID);
        return currentOrder;
    }
    
    @AuraEnabled
    public static Order__c createDraftOrderRecord( Id memberId ){
        Order__C getOrderDetails = new Order__c();
        List<Order__c> searchOrderList = [SELECT Id, Name, Order_Type__c, Member__c, Member__r.Name, Member__r.Active__c, Member__r.Balance__c, Member__r.Default_Payment_Method__c, Vendor__c, Vendor__r.Name, Account__c, Account__r.Name, Status__c, Total_Price__c, UUID__c, CreatedDate, LastModifiedDate, OwnerId FROM Order__c
            WHERE (Order_Type__c = 'POS')  AND (Status__c != 'Completed') AND Member__c =: memberId LIMIT 1];
        User currentUserRecord = [SELECT ContactId,ContactId__c,Contact.Name,Contact.AccountId,Contact.Account.Name,Email,FirstName,Id,IsActive,LastName,MobilePhone,Name,Phone,ProfileId,Username,UserRoleId,UserType FROM User WHERE Id =: UserInfo.getUserId() ];
        Id vendorAccountId;
        if(String.isNotBlank(currentUserRecord.ContactId)){
            vendorAccountId = currentUserRecord.Contact.AccountId;
        }else if(String.isNotBlank(currentUserRecord.ContactId__c )){
            Contact searchContact = [SELECT Id, Name, Account.Name, AccountId FROM Contact WHERE Id =: currentUserRecord.ContactId__c];
            vendorAccountId = searchContact.AccountId;
        }else{
            vendorAccountId = null;
        }
        if(searchOrderList.size() == 0){
            //Create Draft Order
            String orderUUID = SYS_Helper.getUUID();
            Order__c newDraftOrder = new Order__c();
            newDraftOrder.Order_Type__c = 'POS';
            newDraftOrder.Status__c = 'Draft';
            newDraftOrder.Account__c = vendorAccountId;
            newDraftOrder.Member__c = memberId;
            newDraftOrder.UUID__c = orderUUID;
            insert newDraftOrder;
            getOrderDetails = getOrderDetailsByIdOrUUID(orderUUID);
        }else{
            getOrderDetails = getOrderDetailsByIdOrUUID(searchOrderList[0].UUID__c);
        }
        
        return getOrderDetails;
    }
 @AuraEnabled
    public static string GuestUsercreateDraftOrderRecord( Id memberId , Id AccountId){
     string  gettingorderuuid = PosUtility.GuestUsercreateDraftOrderRecordutility(memberId,AccountId);
        return gettingorderuuid;
    }
    @AuraEnabled
    public static User fetchCurrentUser() {
        // query current user information  
        User currentUserRecord = [SELECT ContactId, ContactId__c, Contact.Name, Contact.AccountId, Contact.Account.Name, Email,
            FirstName, Id, IsActive, LastName, MobilePhone, Name, Phone, ProfileId, Profile.UserLicense.Name, Contact.RecordType.Name,
            Username, UserRoleId, UserType FROM User WHERE Id =: UserInfo.getUserId()
        ];

        return currentUserRecord;
    }
    
    @AuraEnabled
    public static CurrentUserWrap fetchCurrentUserWrapper() {
        List<Contact> contactList = new List<Contact>();
        Contact contRec = new Contact();
        // query current user information  
        User userRec = [SELECT ContactId, ContactId__c, Contact.Name,Contact.Balance__c, Contact.AccountId, Contact.Account.Name, Email,
            FirstName, Id, IsActive, LastName, MobilePhone, Name, Phone, ProfileId, Profile.UserLicense.Name, Contact.RecordType.Name,
            Username, UserRoleId, UserType FROM User WHERE Id =: UserInfo.getUserId()
        ];
        String contactId = String.isNotBlank(userRec.ContactId) ? (userRec.ContactId) : ( String.isNotBlank(userRec.ContactId__c) ? userRec.ContactId__c : null ) ;
        if( String.isNotBlank(contactId) ){
            contactList = [SELECT Id,
            Name,FirstName,LastName,Email,AccountId,Balance__c,Phone_Number__c,Formatted_Phone_Number__c,Gender__c,Active__c,StripeCustomerId__c,UUID__c,OwnerId,RecordTypeId,RecordType.Name,Account.Name,
            Account.OwnerId , Account.Plivo_Country_Code__c,Account.Plivo_Sender_Id__c, Account.Plivo_PHLO_Id__c,
            Account.Phone,Account.Fax FROM Contact WHERE Id =: contactId];
        }
        if( contactList.size() > 0 ){
            contRec = contactList[0];
        }
        CurrentUserWrap cuserWrap = new CurrentUserWrap( userRec, contRec );
        return cuserWrap;
    }

    @AuraEnabled
    public static StripeApiTokensWrap fetchStripeApiToken(String recordId) {
        try{
        	StripeApiTokensWrap tokensWrapper = PosUtility.fetchStripeApiToken(recordId);
            return tokensWrapper;
        }catch(Exception ex){
            throw new System.AuraHandledException(
                'Failed to Find SYS_OAuthConfig Record' + ex);
        }
    }

    @AuraEnabled
    public static List < Activity__c > fetchActionRecordRelatedActivities(String actionRecordId) {
        List<Activity__c> allrelatedActivitiesList = new List<Activity__c>(); 
        String allrelatedActivitiesQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Activity__c') +
                ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Media_URL__c') + ' FROM Media_Urls__r)' +
                ' FROM Activity__c WHERE ActionId__c =: actionRecordId ORDER BY When__c ASC';
        allrelatedActivitiesList = Database.query(allrelatedActivitiesQuery); 
        return (allrelatedActivitiesList.size() > 0 ) ? allrelatedActivitiesList : new List<Activity__c>();
    }

    @AuraEnabled
    public static List<Order_Item__c> getOrderItemsForFulfillment(){
        List<Order_Item__c> ordersList = new List< Order_Item__c >();
        ordersList = [SELECT Id,Name,Order__c,Item_Status__c,Product__c,Product__r.Name,Product_Name__c,Quantity__c,
        List_Price__c,Line_Total_Price__c,Total_Price__c,Notes__c,
        CreatedDate,LastModifiedDate,
        Order__r.Name,Order__r.Order_Type__c,Order__r.Member__c,Order__r.Member__r.Name,
        Order__r.Member__r.Active__c, Order__r.Member__r.Default_Payment_Method__c,Order__r.Member__r.Age__c,Order__r.Vendor__c,Order__r.Vendor__r.Name,
        Order__r.Account__c,Order__r.Account__r.Name,Order__r.Status__c,Order__r.Total_Price__c,
        Order__r.UUID__c,Order__r.CreatedDate,Order__r.LastModifiedDate,Order__r.OwnerId FROM Order_Item__c WHERE ( Order__r.Order_Type__c = 'POS' ) AND (  Order__r.Status__c != 'Closed' ) ];
        System.debug('ordersList '  + ordersList);
        return  ordersList;
    }
    
    @AuraEnabled
    public static kanbanWrap getKanbanWrapperDetails_Apex(String sObjectName, String[] sObjectFields, String sObjectPickListFieldApiName) {
        List<String> lstPickvals=new List<String>();
        for (Schema.PicklistEntry a : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(sObjectPickListFieldApiName).getDescribe().getPickListValues()) {
            lstPickvals.add(a.getValue());
        }
        String query = 'SELECT Id, ';
        for(String fields : sObjectFields){
            query += fields + ' ,';
        }
        query = query.removeEnd(',');
        query += ' FROM ' + sObjectName + ' WHERE Order__r.Order_Type__c = \'POS\' AND Order__r.Status__c != \'Closed\'' ;
        System.debug('query '+ query);
        List< Order_Item__c > orderItemList = Database.query(query);

        List<orderItemOptionComponentWrap> optionComponentWrapperRecords = new List<orderItemOptionComponentWrap> ();
        Map < Id, List < Product_Option_Component__c > > mapofOptionComponents = new Map < Id, List < Product_Option_Component__c > > ();

        List < Product_Option_Component__c > optionComponentList = [SELECT Product_Option__c, Id, Name, Product_Inventory__c, Required_Quantity__c, Unit_Price__c, Available_Stock_Quantity__c, Is_Non_Inventory__c, Is_Option_Available__c, CreatedDate, LastModifiedDate FROM Product_Option_Component__c];
        System.debug('optionComponentList ' + optionComponentList);
        for (Product_Option_Component__c opcompRecord: optionComponentList) {
            if (mapofOptionComponents.containsKey(opcompRecord.Product_Option__c)) {
                List < Product_Option_Component__c > tempList = mapofOptionComponents.get(opcompRecord.Product_Option__c);
                tempList.add(opcompRecord);
                mapofOptionComponents.put(opcompRecord.Product_Option__c, tempList);
            } else {
                List < Product_Option_Component__c > tempList = new List < Product_Option_Component__c > ();
                tempList.add(opcompRecord);
                mapofOptionComponents.put(opcompRecord.Product_Option__c, tempList);
            }
        }
        System.debug('mapofOptionComponents ' + mapofOptionComponents);

        for(Order_Item__c orderItemrecord : orderItemList){
            orderItemOptionComponentWrap optionComponentWrap = new orderItemOptionComponentWrap();
            optionComponentWrap.orderLineItemRecord = orderItemrecord;
            optionComponentWrap.optionComponentRecords = mapofOptionComponents.get(orderItemrecord.Product_Option__c);
            optionComponentWrapperRecords.add(optionComponentWrap);
        }
        
        return new kanbanWrap(optionComponentWrapperRecords, lstPickvals);
    }
    
    @AuraEnabled
    public static String getUpdatePickListValue_Apex(Id recordId, String sObjectPickListFieldApiName, String pickListUpdatedValue) {
        SObject sObjectRecord = recordId.getSObjectType().newSObject(recordId);
        sObjectRecord.put(sObjectPickListFieldApiName, pickListUpdatedValue);
        update sObjectRecord;
        return 'Success';
    }
    @AuraEnabled
    public static list<Catalog__c> subscriptioncatalog() {
        list<Catalog__c> catlog = [select Id,Name,Catalog__c,Subscription_colour__c from Catalog__c where Catalog__r.Name='Subscription'];
        return catlog;
    }
    @AuraEnabled
    public static Map<Id, SelectedProductWrapper> initialproductsfetch() {
        List<Product__c> productsList = new List<Product__c>();
        Map <Id, SelectedProductWrapper > mapProductsList = new Map <Id, SelectedProductWrapper >();
        try {           
            String product = 'SELECT ' + SYS_Helper.getAllFieldsFor('Product__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            	', ' + SYS_Helper.getAllParentFields('Catalog__r.', 'Catalog__c') +
                ', ' + SYS_Helper.getAllParentFields('Catalog__r.Catalog__r.', 'Catalog__c') +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Product_Option__c') + ' FROM Product_Option__r)' +
                ' FROM Product__c WHERE Name != \'Tip\' AND Name != \'Wallet\' AND Product_Family__c = \'POS\' AND Is_options_Available__c > 0 ORDER BY Name ASC';
            productsList = Database.query(product); 
            //AND Is_options_Available__c > 0
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
    public class orderItemOptionComponentWrap{
        @AuraEnabled
        public Order_Item__c orderLineItemRecord {get;set;}
        @AuraEnabled
        public List<Product_Option_Component__c> optionComponentRecords {get;set;}
    }
    
    public class kanbanWrap{
        @AuraEnabled
        public List<orderItemOptionComponentWrap> records {get;set;}
        @AuraEnabled
        public List<String> pickVals {get;set;}
        
        public kanbanWrap(List<orderItemOptionComponentWrap> recs, List<String> pVals){
            this.records = recs;
            this.pickVals = pVals;
        }
    }

    public class CurrentUserWrap{
        @AuraEnabled
        public User userRecord {get;set;}
        @AuraEnabled
        public Contact contactRecord {get;set;}
        
        public CurrentUserWrap(User userRec, Contact contRec){
            this.userRecord = userRec;
            this.contactRecord = contRec;
        }
    }
    
    public class StripeApiTokensWrap{
        @AuraEnabled
        public String Name {get;set;}

        @AuraEnabled
        public String PublicKey {get;set;}

        @AuraEnabled
        public String accessToken {get;set;}

        @AuraEnabled
        public Boolean testMode {get;set;}

        public StripeApiTokensWrap(){} 

        public StripeApiTokensWrap(String Name, String PublicKey, String accessToken, Boolean testMode){
            this.Name = Name;
            this.PublicKey = PublicKey;
            this.accessToken = accessToken;
            this.testMode = testMode;
        }
    }

    public class SYS_AuthException extends Exception {}
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