public without sharing class CalendarUtility {
    public String headerdata{get;set;}
    public String urlvalue{get;set;}
    public String url{get;set;}

    public String availableSlotMap { get; set; }

    public static Integer SLOT_COUNT = 4;

    public String memberObjectApiName{
        set {
            memberObjectApiName = value;
        }
        get {
            if (memberObjectApiName == NULL) {
                memberObjectApiName = 'Contact';
            }
            return memberObjectApiName;
        }
    }

    public List<Account> accountsList { get; set; }
    // public Account account { get; set; }

    public List<Contact> contactsList { get; set; }
    // public Contact contact { get; set; }

    public MemberWrapper memberWrapperData { get; set; }

    public List<Product__c> schedulingProductsList {
        get {
            if (schedulingProductsList == NULL) {
                schedulingProductsList = new List < Product__c > ();
            }
            return schedulingProductsList;
        }
        set {
            schedulingProductsList = value;
        }
    }
    public Product__c selectedschedulingProduct { get; set; }
    public String displayTimeZone { get; set; }
    public String selectedDisplayTimeZone { get; set; }

    public String calenderError { get; set; }
    public String specificError { get; set; }
    public String memberuuid { get; set; }
    public String currentSessionId { get; set; }
    public String selectedproductuuid { get; set; }
    public String selectedappointmentUuid { get; set; }
    public String startDatetime { get; set; }
    public String endDateTime { get; set; }

    public Datetime shiftStartDateTime { get; set; }
    public Datetime shiftEndDateTime { get; set; }
    public String meetDuration { get; set; }
    public String selectedDateFormatted { get; set; }
    public String selectedDateWeekDay { get; set; }

    //Initial and Final Booking Slots
    public List<Datetime> initialBookingSlots { get; set; }
    public List<Datetime> availableBookingSlots { get; set; }
    public List<String> availableBookingSlotsUTC { get; set; }
    public List<String> availableBookingSlotsTimezone { get; set; }
    public Map<String, String> availableBookingSlotsUTCMap { get; set; }

    public String freebusyResponseJson { get; set; }

    //Schedule Appointment
    public String selectedAppointmentStartDateTime { get; set; }
    public Map<String, String> appointmentUuidTimeSlotMap { get; set; }
    //Booking Confirmation Status
    public String createAppointmentResponse { get; set; }
    public Integer createAppointmentResponseStatusCode { get; set; }
    public String createAppointmentResponseStatus { get; set; }
    public List<Appointment_Scheduling__c> selectedMemberScheduledAppointments{
        get{
            if(selectedMemberScheduledAppointments == NULL){
                selectedMemberScheduledAppointments = new List<Appointment_Scheduling__c>();
            }
            return selectedMemberScheduledAppointments;
        }
        set{
            selectedMemberScheduledAppointments = value;
        }
    }
    public Boolean showScheduledAppointmentDetails{
        get{
            if(showScheduledAppointmentDetails == NULL){
                showScheduledAppointmentDetails = false;
            }
            return showScheduledAppointmentDetails;
        }
        set{
            showScheduledAppointmentDetails = value;
        }
    }
    public String confirmedAppointmentStartTime { get; set; }
    public String confirmedAppointmentEndTime { get; set; }
    //Cancell Appointment 
    public Integer cancellAppointmentResponseStatusCode { get; set; }

    //Calendar component for Wizard.
    public String uuid { get; set; }
    public ToDo__c todorecord { get; set; }
    public Boolean isComponent { get; set; }

    // MemberDetails Wrapper
    public class MemberWrapper {
        public String accountId {get;set;}
        public String objectApiName {get;set;}
        public String memberid {get;set;}
        public String memberuuid {get;set;}
        public String memberName {get;set;}
        public String memberEmail {get;set;}
        public String memberPhone {get;set;}
        public String memberFormattedPhone {get;set;}
        public Account accountRecord {
            set {
                accountRecord = value;
            }
            get {
                if (accountRecord == NULL) {
                    return new Account();
                }
                return accountRecord;
            }
        }
        public Contact contactRecord {
            set {
                contactRecord = value;
            }
            get {
                if (contactRecord == NULL) {
                    return new Contact();
                }
                return contactRecord;
            }
        }
        public MemberWrapper(Account accRecord) {
            objectApiName = 'Account';
            accountId = accRecord.Id;
            memberid = accRecord.Id;
            memberuuid = accRecord.UUID__c;
            memberName = accRecord.Name;
            memberEmail = accRecord.Email__c;
            memberPhone = accRecord.Phone;
            memberFormattedPhone = accRecord.Formatted_Phone_Number__c;
            accountRecord = accRecord;
        }

        public MemberWrapper(Contact contRecord) {
            objectApiName = 'Contact';
            accountId = contRecord.Account.Id;
            memberid = contRecord.Id;
            memberuuid = contRecord.UUID__c;
            memberName = contRecord.Name;
            memberEmail = contRecord.Email;
            memberPhone = contRecord.Phone_Number__c;
            memberFormattedPhone = contRecord.Formatted_Phone_Number__c;
            contactRecord = contRecord;
        }
    }

    // freeBusyRequestJSON Wrapper
    public class freeBusyRequestJSON {
        public String timeMin; //2023-02-01T14:00:00.000Z
        public String timeMax; //2023-02-17T23:00:00.000Z
        public Integer calendarExpansionMax; //50
        public Integer groupExpansionMax; //100
        public String timeZone; //UTC
        public cls_items[] items;
        public freeBusyRequestJSON parse(String json) {
            return (freeBusyRequestJSON) System.JSON.deserialize(json, freeBusyRequestJSON.class);
        }
    }

    public class cls_items {
        public String id; //c_9tnsdnol964pp3u3c5codtmkdo@group.calendar.google.com
    }
    
    //Fetch Member Details
    public MemberWrapper getMemberDetails(String objectApiName, String memberuuid) {
        if(objectApiName == 'Account'){
            String accountsListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Account') +
            ' FROM Account WHERE UUID__c =: memberuuid';
            accountsList = Database.query(accountsListQuery);
            if (accountsList.size() > 0) {
                // account = accountsList[0];
                memberWrapperData = new MemberWrapper(accountsList[0]);
                // memberWrapperData.registerAccount(accountsList[0]);
            }
        }
        if(objectApiName == 'Contact'){
            String contactsListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact') +
            ', ' + SYS_Helper.getAllParentFields('Account.', 'Account') +
            ' FROM Contact WHERE UUID__c =: memberuuid';
            contactsList = Database.query(contactsListQuery);
            if (contactsList.size() > 0) {
                // contact = contactsList[0];
                memberWrapperData = new MemberWrapper(contactsList[0]);
                // memberWrapperData.registerContact(contactsList[0]);
            }
        }
        return memberWrapperData;
    }

    //Fetch Scheduling Products List
    public List<Product__c> getSchedulingProducts(String objectApiName, String memberuuid) {
        //For AOA GET Account Id
        Id accountRecordId = memberWrapperData.accountId;
        String schedulingProductsListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Product__c') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ' FROM Product__c WHERE Google_Shift_Calendar_Id__c != NULL AND Google_Booking_Calendar_Id__c != NULL AND Meet_Duration__c != NULL AND Allow_scheduling__c = TRUE';

        if(objectApiName == 'Contact'){
            schedulingProductsListQuery = schedulingProductsListQuery + ' AND Account__r.Id =: accountRecordId';
        }    
        List<Product__c> getSchedulingProductsList = Database.query(schedulingProductsListQuery);
        return getSchedulingProductsList;
    }

    //Fetch Scheduling Product
    public Product__c getSchedulingProductByUUID(String objectApiName, String productuuid) {
        //For AOA GET Account Id
        Id accountRecordId = memberWrapperData.accountId;
        String fetchSchedulingProductQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Product__c') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ' FROM Product__c WHERE UUID__c =: productuuid AND Allow_scheduling__c = TRUE';
        if(objectApiName == 'Contact'){
            fetchSchedulingProductQuery = fetchSchedulingProductQuery + ' AND Account__r.Id =: accountRecordId';
        }    
        List<Product__c> getSchedulingProduct = Database.query(fetchSchedulingProductQuery);
        return (getSchedulingProduct.size() > 0) ? getSchedulingProduct[0] : new Product__c();
    }

    //Fetch Upcoming Appointments
    public List<Appointment_Scheduling__c> getUpcomingAppointments(String objectApiName, String memberuuid) {
        List<Appointment_Scheduling__c> upcomingAppointments = new List<Appointment_Scheduling__c>();
        List<String> excludeAppointmentStatusList = new List<String>{'cancelled'};
        Datetime currentDateTime = Datetime.now();
        String selectedMemberScheduledAppointmentsQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Appointment_Scheduling__c') +
        ', ' + SYS_Helper.getAllParentFields('Product__r.', 'Product__c') +
        ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
        ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
        ' FROM Appointment_Scheduling__c WHERE ';
        if(objectApiName == 'Account'){
            selectedMemberScheduledAppointmentsQuery = selectedMemberScheduledAppointmentsQuery + 'Account__r.UUID__c =: memberuuid AND';
        }
        if(objectApiName == 'Contact'){
            selectedMemberScheduledAppointmentsQuery = selectedMemberScheduledAppointmentsQuery + 'Contact__r.UUID__c =: memberuuid AND';
        }
        selectedMemberScheduledAppointmentsQuery = selectedMemberScheduledAppointmentsQuery + ' Status__c NOT IN :excludeAppointmentStatusList AND StartDate__c >= :currentDateTime ORDER BY StartDate__c DESC LIMIT 5';
        upcomingAppointments = Database.query(selectedMemberScheduledAppointmentsQuery);

        return upcomingAppointments;
    }

    //Build Outbound HttpRequest Add accoundid param , int type
    public HttpResponse buildOutboundHttpRequest(String IntegrationName, String calloutMethod, String calloutUrl, String requestJsonBody) {
        //For AOA GET Account Id
        String accountRecordId = memberWrapperData != NULL ? memberWrapperData.accountId : '';
        // System.debug('accountRecordId ' + accountRecordId);
        //Init Appservice and DataCache
        if (this.isComponent != NULL) {
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                '0019H00000CrdZ3QAJ',
                IntegrationName,
                IntegrationName,
                'AppointmentScheduling'
            );
        }
        else if (SYS_DataCacheFactory.accountId == NULL && String.isNotBlank(accountRecordId)) {
            // SYS_DataCacheFactory init = new SYS_DataCacheFactory(
            //     IntegrationName,
            //     'AppointmentScheduling'
            // );
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                accountRecordId,
                IntegrationName,
                IntegrationName,
                'AppointmentScheduling'
            );
        }
        else if (SYS_DataCacheFactory.accountId != NULL) {
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                SYS_DataCacheFactory.accountId,
                IntegrationName,
                IntegrationName,
                'AppointmentScheduling'
            );
        }
        
        
        // SYS_ApplicationService appService = new SYS_ApplicationService();

        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setMethod(calloutMethod);
        req.setEndpoint(calloutUrl);

        
        // Set Headers For Calendar
        List<HttpHeaders__mdt> httpHeader = SYS_DataCacheFactory.headerSetting;
        for (HttpHeaders__mdt head: httpHeader) {
            SYS_debug.log('header is = ' + head.header_name__c + ' ' + head.Value__c);
            req.setHeader(String.valueOf(head.header_name__c), String.valueOf(head.Value__c));
        }
        String oauthGrantType = SYS_DataCacheFactory.integrationSetting.AuthenticationType__c;
        if (oauthGrantType.toLowerCase() == 'oauth') {
            List < SYS_OAuthConfig__c > configs = SYS_DataCacheFactory.authRec;
            if (configs.size() > 0) {
                if ((configs[0].Grant_Type__c == 'authorization_code') && (configs[0].Token_type__c == 'Bearer')) {
                    req.setHeader('Authorization', configs[0].Token_type__c + ' ' + configs[0].Access_Token__c);
                }
            }
        }

        req.setBody(requestJsonBody);
        HttpResponse resp = http.send(req);
        System.debug('Outbound Request json:' + requestJsonBody);

        String outboundResponse = resp.getBody();
        System.debug('Outbound Response: ' + outboundResponse);
        
        return resp;
    }

    //To Check FreeBusy Slots Based on Product and Time Range
    public String freeBusyCheck(String productuuid, Datetime checkstartDatetime, Datetime checkendDateTime) {
        String startDateTimeString, endDateTimeString, shiftCalendarId, bookingCalendarId;
        try {
            selectedschedulingProduct = getSchedulingProductByUUID(memberObjectApiName, productuuid);
            shiftCalendarId = selectedschedulingProduct.Google_Shift_Calendar_Id__c;
            bookingCalendarId = selectedschedulingProduct.Google_Booking_Calendar_Id__c;
            startDateTimeString = checkstartDatetime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            endDateTimeString = checkendDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

        String IntegrationName = 'Calendar';
        String calloutMethod = 'POST';
        String calloutUrl = 'https://www.googleapis.com/calendar/v3/freeBusy';
        
        List<cls_items> cls_itemsList = new List<cls_items>();
        cls_items shiftcls_item = new cls_items();
        shiftcls_item.Id = shiftCalendarId;
        cls_itemsList.add(shiftcls_item);

        cls_items bookingcls_item = new cls_items();
        bookingcls_item.Id = bookingCalendarId;
        cls_itemsList.add(bookingcls_item);

        freeBusyRequestJSON freeBusyrequestJosnWrapper = new freeBusyRequestJSON();
        freeBusyrequestJosnWrapper.timeMin = startDateTimeString;
        freeBusyrequestJosnWrapper.timeMax = endDateTimeString;
        freeBusyrequestJosnWrapper.timeZone = 'UTC';
        freeBusyrequestJosnWrapper.calendarExpansionMax = 50;
        freeBusyrequestJosnWrapper.groupExpansionMax = 100;
        freeBusyrequestJosnWrapper.items = cls_itemsList;

        String requestJsonBody = JSON.serialize(freeBusyrequestJosnWrapper);
        HttpResponse resp = buildOutboundHttpRequest(IntegrationName, calloutMethod, calloutUrl, requestJsonBody);
        String freeBusyResponse = resp.getBody();
        
        return freeBusyResponse;
    }

    //init Data from page params
    public CalendarUtility(){
        // checkPageValidity();

        
        // this.slotMap = JSON.serialize(getAvailableSlotMap(this.selectedproductuuid, this.startDatetime, dayCount));
    }

    //External Page Validity Check
    public void checkPageValidity(){
        try{
            Boolean isProductFound = false;
            
            memberuuid = String.isNotBlank(ApexPages.currentPage().getParameters().get('memberuuid')) ? 
            ApexPages.currentPage().getParameters().get('memberuuid') : ApexPages.currentPage().getParameters().get('uuid');
            selectedproductuuid = ApexPages.currentPage().getParameters().get('productuuid');
            currentSessionId = ApexPages.currentPage().getParameters().get('currentSessionId');

            headerdata = ApexPages.currentPage().getHeaders().get('Host');        
            urlvalue = Apexpages.currentPage().getUrl();        
            url = 'https://' + headerdata+ urlvalue;
            
            if (String.isBlank(memberuuid)) {
                calenderError = System.Label.ADS_InvalidMemberuuid;
                // calenderError = 'Oops! No Patient found missing parameter';
            } else if ((memberuuid != null) && (memberObjectApiName != null)) {
                memberWrapperData = getMemberDetails(memberObjectApiName, memberuuid);
            } 
            
            if(memberWrapperData == null) {
                calenderError = System.Label.ADS_NoMemberFound;
                // calenderError = 'Oops! No Patient found';
            }
            
            //GET Scheduling Product Datails
            schedulingProductsList = getSchedulingProducts(memberObjectApiName, memberuuid);

            //Fetch Upcoming Appointments
            selectedMemberScheduledAppointments = getUpcomingAppointments(memberObjectApiName, memberuuid);
            //Generate TimeslotsString for Upcoming Appointments
            generateUpcomingAppointmentsTitles(selectedMemberScheduledAppointments);
            
            if( String.isNotBlank(selectedproductuuid) && (schedulingProductsList.size() > 0) ){
                for(Product__c iterProduct : schedulingProductsList){
                    if(iterProduct.UUID__c == selectedproductuuid){
                        selectedschedulingProduct = iterProduct;
                        isProductFound = true;
                        break;
                    }
                }
                if(!isProductFound){
                    selectedproductuuid = '';
                    specificError = System.Label.ADS_InvalidProductUrl;
                }
                
            }
        }catch(Exception ex){
            System.debug(ex.getMessage()+'\n'+ex.getStackTraceString());
            calenderError = 'Oops! Exception Occured ' + ex.getMessage();
        }
    }

    //Fetch Upcoming Appointments
    public void fetchUpcomingAppointments(){
        try{
        selectedMemberScheduledAppointments = getUpcomingAppointments(memberObjectApiName, memberuuid);
        //Generate TimeslotsString for Upcoming Appointments
        generateUpcomingAppointmentsTitles(selectedMemberScheduledAppointments);
        }catch(Exception ex){
            System.debug(ex.getMessage()+'\n'+ex.getStackTraceString());
            calenderError = 'Oops! Exception Occured ' + ex.getMessage();
        }
    }

    //Generate TimeslotsString for Upcoming Appointments
    public void generateUpcomingAppointmentsTitles(List<Appointment_Scheduling__c> selectedMemberScheduledAppointments){
        appointmentUuidTimeSlotMap = new Map<String,String>();
        //Set TimeZone
        displayTimeZone = String.isNotBlank(displayTimeZone) ? displayTimeZone : 'America/Los_Angeles' ;
        for(Appointment_Scheduling__c apptRec: selectedMemberScheduledAppointments){
            Datetime apptStart = apptRec.StartDate__c;
            Datetime appEnd = apptRec.EndDate__c;
            String convertedStartDate = (apptStart != null) ? apptStart.format('MM/dd/YYYY', displayTimeZone) : '';
            String convertedStartDateTimeString = (apptStart != null) ? apptStart.format('hh:mm a', displayTimeZone) : '';
            String convertedEndDateTimeString = (appEnd != null) ? appEnd.format('hh:mm a', displayTimeZone) : '';
            String appointSlotTitle = apptRec.Product__r.Name +' - '+ convertedStartDate + ' ' + convertedStartDateTimeString +' - '+convertedEndDateTimeString;
            appointmentUuidTimeSlotMap.put(apptRec.UUID__c, appointSlotTitle);
        }
    }

    //Format Datetime to ISO String
    public String formatDateTimetoISOString(Datetime tempDatetimeToFormatted){
        String tempavailableSlotString = tempDatetimeToFormatted.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        return tempavailableSlotString;
    }

    //Set Shift Start Datetime Roundto next Interval
    public DateTime roundToNextInterval(DateTime startDateTimetoRoundOff, Integer slotInterval) {
        Boolean isNearestHour = ((slotInterval > 0) && (slotInterval <= 59)) ? false : true;
        Integer minutesInGMT = startDateTimetoRoundOff.minuteGMT();
        Integer nearestOffsetMinutes = 0; 
        if( (minutesInGMT != 0) && (minutesInGMT < slotInterval) ){
            nearestOffsetMinutes = slotInterval - minutesInGMT;
        }else{
            while(minutesInGMT > slotInterval){
                minutesInGMT = minutesInGMT - slotInterval;
            }
            nearestOffsetMinutes = slotInterval - minutesInGMT;
        }

        if( isNearestHour ){
            if (minutesInGMT != 0) {
                return startDateTimetoRoundOff.addHours(1).addMinutes(-minutesInGMT);
            }
        }else{ //06:58
            if(nearestOffsetMinutes != 0 && minutesInGMT != 0){
                return startDateTimetoRoundOff.addMinutes(nearestOffsetMinutes);
            }           
        }
        return startDateTimetoRoundOff;
    }

    public List<Datetime> getInitialSlots(Datetime StartDateTime, Datetime EndDateTime, Integer slotInterval ) {
        List<Datetime> timeSlots = new List<Datetime>();

        if( (StartDateTime < EndDateTime) && (StartDateTime != EndDateTime) ) {
            timeSlots.add(StartDateTime);
        }

        while (StartDateTime != EndDateTime) {
            StartDateTime = (StartDateTime.addMinutes(slotInterval));
            if(StartDateTime >= EndDateTime){
                break;
            }else{
                timeSlots.add(StartDateTime);
            }            
        }
        
        System.debug('timeSlots ' + timeSlots);
        return timeSlots;
    }

    public List<String> getGMTStringDatetime(List<Datetime> dateTimeslotsList){
        List<String> datetimeStringList = new List<String>();
        for(Datetime itertempdateTimeslot :dateTimeslotsList){
            datetimeStringList.add(String.valueOfGmt(itertempdateTimeslot));
        }
        return datetimeStringList;
    }

    public Datetime resetSecondsToZero(Datetime datetimeToReset) {
        Integer startTimeSeconds = datetimeToReset.secondGMT();
        startTimeSeconds = (startTimeSeconds != 0) ? 60 - startTimeSeconds : 0;
        datetimeToReset = datetimeToReset.addSeconds(startTimeSeconds);
        return datetimeToReset;
    }
    
    //To Check FreeBusy Slots Based on Product and Time Range
    public void checkFreeBusyonSelectedDate() {
        try {
displayTimeZone = String.isNotBlank(displayTimeZone) ? displayTimeZone : 'America/Los_Angeles' ;
            Integer slotInterval;
            meetDuration = selectedschedulingProduct.Meet_Duration__c;
            slotInterval = (String.isNotBlank(meetDuration)) ? Integer.valueof(meetDuration) : 0;
            String googleShiftCalendarId = selectedschedulingProduct.Google_Shift_Calendar_Id__c;
            String googleBookingCalendarId = selectedschedulingProduct.Google_Booking_Calendar_Id__c;
            String minimumLeadTimeString = selectedschedulingProduct.Minimum_Lead_Time__c;
            Integer minimumLeadTime = (String.isNotBlank(minimumLeadTimeString)) ? Integer.valueof(minimumLeadTimeString) : 0;


            initialBookingSlots = new List<Datetime>();
            availableBookingSlots = new List<Datetime>();
            availableBookingSlotsUTC = new List<String>();

            //Populate StartDateTime and EndDateTime for checking Free Busy Check
            DateTime startDatetimeVariable = freeBusyResponseWrapper.formatDateTime(startDatetime, 'YYYY-MM-DDThh:mm:ssZ');
            DateTime endDateTimeVariable = freeBusyResponseWrapper.formatDateTime(endDateTime, 'YYYY-MM-DDThh:mm:ssZ');
            
            startDatetimeVariable = resetSecondsToZero(startDatetimeVariable);
            startDatetimeVariable = startDatetimeVariable.addMinutes(minimumLeadTime);
            startDatetimeVariable = roundToNextInterval(startDatetimeVariable, slotInterval);
            System.debug('startDatetimeVariable new ' + startDatetimeVariable);
            endDateTimeVariable = resetSecondsToZero(endDateTimeVariable);
            System.debug('endDateTimeVariable new ' + endDateTimeVariable);

            selectedDateFormatted = startDatetimeVariable.format('MMMM, dd YYYY', displayTimeZone);
            selectedDateWeekDay = startDatetimeVariable.format('EEEE', displayTimeZone);

            freebusyResponseJson = freeBusyCheck(selectedproductuuid, startDatetimeVariable, endDateTimeVariable);

            //Parse freeBusyResponse
            FreeBusyResponseWrapper freeBusyResponseObject = freeBusyResponseWrapper.parse(freebusyResponseJson);

            Map<String , List<freeBusyResponseWrapper.Busy>> calendarIdBusySlotsListMap = freeBusyResponseObject?.calendars?.calendarIdBusySlotsMap;

            if( calendarIdBusySlotsListMap.containsKey(googleShiftCalendarId) ){
                List<freeBusyResponseWrapper.Busy> shiftBusySlots = calendarIdBusySlotsListMap.get(googleShiftCalendarId);
                // Map<Long , Datetime> slotsTimeDateMap = new Map<Long , Datetime>();
                // List<Long> timeSlotsMilliseconds = new List<Long>();
                List<Datetime> tempshiftStartDateTimeList = new List<Datetime>();
                List<Datetime> tempshiftEndDateTimeList = new List<Datetime>();
                if( shiftBusySlots.size() > 0 ){
                    for(freeBusyResponseWrapper.Busy tempShiftSlot : shiftBusySlots){
                        tempshiftStartDateTimeList.add(resetSecondsToZero(tempShiftSlot.start_x));
                        tempshiftEndDateTimeList.add(resetSecondsToZero(tempShiftSlot.end_x));
                    }
                    shiftStartDateTime = tempshiftStartDateTimeList[0];
                    shiftEndDateTime = tempshiftEndDateTimeList[0]; 
                    for(Datetime itertempShiftStartTime :tempshiftStartDateTimeList){
                        shiftStartDateTime = (shiftStartDateTime <= itertempShiftStartTime) ? shiftStartDateTime : itertempShiftStartTime;
                    }
                    for(Datetime itertempShiftEndTime :tempshiftEndDateTimeList){
                        shiftEndDateTime = (shiftEndDateTime >= itertempShiftEndTime) ? shiftEndDateTime : itertempShiftEndTime;
                    }
                }
            }
            System.debug('startDatetimeVariable new ' + startDatetimeVariable);
            System.debug('shiftStartDateTime ' + shiftStartDateTime);
            System.debug('shiftEndDateTime ' + shiftEndDateTime);
            System.debug('slotInterval ' + slotInterval);
            
            //Check if shiftStartDateTime shiftEndDateTime are empty or not
            //Check if Initial slots are empty or not exit with exception
            initialBookingSlots = getInitialSlots(shiftStartDateTime, shiftEndDateTime, slotInterval );
            System.debug('initialBookingSlots ' + initialBookingSlots);            

            List<freeBusyResponseWrapper.Busy> busySlotsWrapperList = new List<freeBusyResponseWrapper.Busy>();
            if( calendarIdBusySlotsListMap.containsKey(googleBookingCalendarId) ){
                List<freeBusyResponseWrapper.Busy> bookingCalendarBusySlots = calendarIdBusySlotsListMap.get(googleBookingCalendarId);
                if( bookingCalendarBusySlots.size() > 0 ){
                    busySlotsWrapperList = bookingCalendarBusySlots;
                }else {
                    availableBookingSlots = initialBookingSlots;
                }
            }else{
                availableBookingSlots = initialBookingSlots;
            }

            availableBookingSlots = getFinalSlots(busySlotsWrapperList, initialBookingSlots);
            System.debug('availableBookingSlots ' + availableBookingSlots);
            getDateTimeSlotsBasedonTimezone();
            if ((availableBookingSlots != null) && (availableBookingSlots.size() > 0)) {
                for (Datetime iteravailableSlot: availableBookingSlots) {
                    String tempavailabledateTime = String.valueOfGmt(iteravailableSlot);
                    availableBookingSlotsUTC.add(tempavailabledateTime);
                }
            }
            System.debug('availableBookingSlotsUTC ' + availableBookingSlotsUTC);

        } catch (Exception ex) {
            System.debug('Exception ex ' + ex);
            System.debug('Exception ex ' + ex.getstacktraceString());
        }
    }

    public List<Datetime> getFinalSlots(List<freeBusyResponseWrapper.Busy> busySlots, List<Datetime> initialSlots){
        List<Datetime> finalSlots = new List<Datetime>();
        List<Datetime> tempBusySlots = new List<Datetime>();
        if( (initialSlots.size() > 0) && (busySlots.size() > 0) ){
            for (Datetime iterinitialSlot: initialSlots) {
                for (freeBusyResponseWrapper.Busy iterbusySlotWrap: busySlots) {
                    if( ( (iterbusySlotWrap.start_x <= iterinitialSlot) && (iterinitialSlot < iterbusySlotWrap.end_x) ) ){
                        tempBusySlots.add(iterinitialSlot);
                    }
                }
            }

            // Clear Filtered Busy Slots
            for(Datetime iterinitialSlotSlice : initialSlots){
                if(!tempBusySlots.contains(iterinitialSlotSlice)){
                    finalSlots.add(iterinitialSlotSlice);
                }
            }
        }else{
            finalSlots = initialSlots;
        }
        return finalSlots;
    }

    
    public void getDateTimeSlotsBasedonTimezone(){
        availableBookingSlotsTimezone = new List<String>();
        availableBookingSlotsUTCMap = new Map<String, String>();

        //Set TimeZone
        displayTimeZone = String.isNotBlank(displayTimeZone) ? displayTimeZone : 'America/Los_Angeles' ;
        
        if( (availableBookingSlots != null) && (availableBookingSlots.size() > 0) ){
            for (Datetime iterUtcDateTime: availableBookingSlots) {
                String tempavailableSlotString = formatDateTimetoISOString(iterUtcDateTime);
                System.debug('tempavailableSlotString ' + tempavailableSlotString);

                String convertedDateTimeString = (iterUtcDateTime != null) ? iterUtcDateTime.format('hh:mm a', displayTimeZone) : '';
                availableBookingSlotsTimezone.add(convertedDateTimeString);
                
                availableBookingSlotsUTCMap.put(tempavailableSlotString, convertedDateTimeString);
            }
        }
    }

    public void cancelAppointment() {
        try {
            System.debug('selectedappointmentUuid ' + selectedappointmentUuid);
            if (String.isNotBlank(selectedappointmentUuid)) {

                Appointment_Scheduling__c fetchAppointmentDetails = AppointmentSchedulingService.getAppointmentDetails(selectedappointmentUuid);
                String calendarId = fetchAppointmentDetails.Google_Booking_Calendar_Id__c;
                String eventId = fetchAppointmentDetails.Google_Calendar_Event_Id__c;

                // Update Calendar Event Request for Cancell a event
                GoogleCalenderEventWrapper eventWrapper = new GoogleCalenderEventWrapper();
                eventWrapper.status = 'cancelled';
                eventWrapper.addStartDatetime(formatDateTimetoISOString(fetchAppointmentDetails.StartDate__c));
                eventWrapper.addEndDatetime(formatDateTimetoISOString(fetchAppointmentDetails.EndDate__c));
                String newjsonBody = JSON.serialize(eventWrapper, true);
                Object eventWrapperObject = System.JSON.deserializeUntyped(newjsonBody);
                ((Map<String, Object>)eventWrapperObject).remove('attendees'); 
                newjsonBody = JSON.serialize(eventWrapperObject);
                newjsonBody = newjsonBody.replaceAll('end_x', 'end');
                newjsonBody = newjsonBody.replaceAll('dateTime_x', 'dateTime');

                String IntegrationName = 'Calendar';
                String calloutMethod = 'PUT';
                String calloutUrl = 'https://www.googleapis.com/calendar/v3/calendars/'+ calendarId +'/events/'+ eventId +'?sendNotifications=true&sendUpdates=all&maxAttendees=1';
                HttpResponse resp = buildOutboundHttpRequest(IntegrationName, calloutMethod, calloutUrl, newjsonBody);
                System.debug('#### resp status: '+resp.getStatus());
                System.debug('#### resp code: '+resp.getStatusCode()); 
                cancellAppointmentResponseStatusCode = resp.getStatusCode();
                if(resp.getStatusCode() == 200){
                    //Update Appointment Status to Cancel
                    fetchAppointmentDetails.Status__c = 'cancelled';
                    Appointment_Scheduling__c updateAppointment = AppointmentSchedulingService.updateAppointment(fetchAppointmentDetails);
                    //Fetch Upcoming Appointments
                    // List<String> excludeAppointmentStatusList = new List<String>{'cancelled'};
                    // Datetime currentDateTime = Datetime.now();
                    // String selectedMemberScheduledAppointmentsQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Appointment_Scheduling__c') +
                    // ', ' + SYS_Helper.getAllParentFields('Product__r.', 'Product__c') +
                    // ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                    // ' FROM Appointment_Scheduling__c WHERE Account__r.UUID__c =: memberuuid AND Status__c NOT IN :excludeAppointmentStatusList AND StartDate__c >= :currentDateTime ORDER BY StartDate__c DESC LIMIT 5';
                    // selectedMemberScheduledAppointments = Database.query(selectedMemberScheduledAppointmentsQuery);
                }else{
                    //Show Error Message
                    specificError = 'API: Failed to Cancel Appointment';
                }
                fetchUpcomingAppointments();
            } else {
                specificError = 'Please Select an Appointment to Cancel';
            }

        } catch (Exception ex) {
            specificError = ex.getMessage();
        }
    }

    public void checkinAppointment() {
        try {
            System.debug('selectedappointmentUuid ' + selectedappointmentUuid);
            if (String.isNotBlank(selectedappointmentUuid)) {

                Appointment_Scheduling__c fetchAppointmentDetails = AppointmentSchedulingService.getAppointmentDetails(selectedappointmentUuid);
                String calendarId = fetchAppointmentDetails.Google_Booking_Calendar_Id__c;
                String eventId = fetchAppointmentDetails.Google_Calendar_Event_Id__c;

                fetchAppointmentDetails.Status__c = 'checked-in';
                Appointment_Scheduling__c updateAppointment = AppointmentSchedulingService.updateAppointment(fetchAppointmentDetails);
                fetchUpcomingAppointments();
            } else {
                specificError = 'Please Select an Appointment to Check-In';
            }

        } catch (Exception ex) {
            specificError = ex.getMessage();
        }
    }

    public void createAppointment() {
        try {
            memberWrapperData = getMemberDetails(memberObjectApiName, memberuuid);
            
            Datetime appointmentStartDateTime = freeBusyResponseWrapper.formatDateTime(selectedAppointmentStartDateTime, 'YYYY-MM-DDThh:mm:ssZ');
            Boolean hasDuplicateAppointments = AppointmentSchedulingService.hasDuplicateAppointments(appointmentStartDateTime, selectedschedulingProduct.Google_Booking_Calendar_Id__c);
            System.debug('hasDuplicateAppointments ' + hasDuplicateAppointments);
            if(hasDuplicateAppointments){
                specificError = 'Selected slot is already booked. Please refresh and book another slot';
                return;
            }
            Integer slotInterval = (String.isNotBlank(meetDuration)) ? Integer.valueof(meetDuration) : 0;
            Datetime appointmentEndDateTime = (appointmentStartDateTime.addMinutes(slotInterval));
            String appointmentEndDateTimeISOString = formatDateTimetoISOString(appointmentEndDateTime);
            String MeetTitle = 'Appointment for ' + memberWrapperData.memberName + ' - ' + selectedschedulingProduct.Name;
            String appointmentMember = String.isNotBlank(memberWrapperData?.memberEmail) ? memberWrapperData.memberEmail : '';

            confirmedAppointmentStartTime = appointmentStartDateTime.format('hh:mm a', displayTimeZone); 
            confirmedAppointmentEndTime = appointmentEndDateTime.format('hh:mm a', displayTimeZone);

            // Create Calendar Event Request selectedMemberScheduledAppointments
            GoogleCalenderEventWrapper createEventWrapper = new GoogleCalenderEventWrapper();
            system.debug('SelectedprodNDR'+selectedschedulingProduct.Virtual_Appointment__c);
            system.debug('SelectedprodNDR'+selectedschedulingProduct);
            if(selectedschedulingProduct.Virtual_Appointment__c){
                createEventWrapper.confrencedatacreate(SYS_Helper.getUUID(),'pending','hangoutsMeet'); 
            }
            createEventWrapper.location = (selectedschedulingProduct.Location__c);
            createEventWrapper.summary = MeetTitle;
            createEventWrapper.addStartDatetime(selectedAppointmentStartDateTime);
            createEventWrapper.addEndDatetime(appointmentEndDateTimeISOString);  
           
            if(String.isNotBlank(appointmentMember)){
                createEventWrapper.addAttendees(appointmentMember);
            }
            String newjsonBody = JSON.serialize(createEventWrapper, true);
            system.debug('newjsonBodyNDR' + newjsonBody);
            Object eventWrapperObject = System.JSON.deserializeUntyped(newjsonBody);
            if(String.isBlank(appointmentMember)){
                ((Map<String, Object>)eventWrapperObject).remove('attendees'); 
            }
            newjsonBody = JSON.serialize(eventWrapperObject);
            newjsonBody = newjsonBody.replaceAll('end_x', 'end');
            newjsonBody = newjsonBody.replaceAll('dateTime_x', 'dateTime');
            System.debug('newjsonBody ' + newjsonBody);
            String Google_Booking_Calendar_Id = selectedschedulingProduct.Google_Booking_Calendar_Id__c;
            String IntegrationName = 'Calendar';
            String calloutMethod = 'POST';
            String calloutUrl = 'https://www.googleapis.com/calendar/v3/calendars/'+ Google_Booking_Calendar_Id +'/events?sendNotifications=true&sendUpdates=all&maxAttendees=1&conferenceDataVersion=1';
            HttpResponse resp = buildOutboundHttpRequest(IntegrationName, calloutMethod, calloutUrl, newjsonBody);
            System.debug('#### resp status: '+resp.getStatus());
            System.debug('#### resp code: '+resp.getStatusCode()); 
            createAppointmentResponse = resp.getBody();
            createAppointmentResponseStatusCode = resp.getStatusCode();
            createAppointmentResponseStatus = resp.getStatus();
            if(createAppointmentResponseStatusCode == 201 || createAppointmentResponseStatusCode == 200){
                showScheduledAppointmentDetails = true;
                createAppointmentResponse = createAppointmentResponse.replaceAll('dateTime','dateTime_x').replaceAll('end','end_x');
                System.debug('createAppointmentResponse ' + createAppointmentResponse);
                // Map<String, Object> newflatKeyMap = (SYS_Helper.getFlatKeys(createAppointmentResponse ,'A.B'));  
                // String googleCalendarEventId = (String)newflatKeyMap.get('id');
                GoogleCalenderEventResponseWrapper GoogleCreateEventResponse = GoogleCalenderEventResponseWrapper.parse(createAppointmentResponse);
                
                String googleCalendarEventId = GoogleCreateEventResponse.id;
                String googleCalendarEventStatus = GoogleCreateEventResponse.status;
                String hangoutmeetURL = GoogleCreateEventResponse.hangoutLink;
                String googleCalendarEventTimezone = GoogleCreateEventResponse.start.timeZone;
                Boolean IsActive = true;
                displayTimeZone = String.isNotBlank(displayTimeZone) ? displayTimeZone : 'America/Los_Angeles' ;
                Id contactRecordId = (memberObjectApiName == 'Contact') ? memberWrapperData.memberid: null; 
                Id accountRecordId = (memberObjectApiName == 'Account') ? memberWrapperData.memberid: ( (memberObjectApiName == 'Contact') ? memberWrapperData.accountId : null); 
               
                Appointment_Scheduling__c bookedAppointment = AppointmentSchedulingService.createNewAppointmenthangoutlink(MeetTitle, appointmentStartDateTime, appointmentEndDateTime, meetDuration, MeetTitle, accountRecordId, contactRecordId, selectedschedulingProduct.Id, appointmentMember, Google_Booking_Calendar_Id, googleCalendarEventId, 
                googleCalendarEventStatus, googleCalendarEventTimezone, displayTimeZone, IsActive,hangoutmeetURL);
                System.debug('googleCalendarEventTimezone ' + googleCalendarEventTimezone);
                System.debug('bookedAppointment ' + bookedAppointment);
                if (this.todorecord != NULL)  {
                    String goalId = this.todorecord.Goal__c;
                    Boolean updateGoalStatus = GoalUtility.updateAppointmentSchedulingForGoal('', goalId, bookedAppointment.Id);
                    
                    // Goal__c goal = new Goal__c(Id = goalId, Appointment_Scheduling__c = bookedAppointment.Id);
                    // update goal;
                }
                //Fetch Upcoming Appointments
                // List<String> excludeAppointmentStatusList = new List<String>{'cancelled'};
                // Datetime currentDateTime = Datetime.now();
                // String selectedMemberScheduledAppointmentsQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Appointment_Scheduling__c') +
                // ', ' + SYS_Helper.getAllParentFields('Product__r.', 'Product__c') +
                // ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                // ' FROM Appointment_Scheduling__c WHERE Account__r.UUID__c =: memberuuid AND Status__c NOT IN :excludeAppointmentStatusList AND StartDate__c >= :currentDateTime ORDER BY StartDate__c DESC LIMIT 5';
                // selectedMemberScheduledAppointments = Database.query(selectedMemberScheduledAppointmentsQuery);
                fetchUpcomingAppointments();
            }            
            
        } catch (Exception ex) {
            specificError = ex.getMessage();
            System.debug('Exception ' +  ex.getMessage());
            System.debug('Exception ' +  ex.getStackTraceString());
            // throw new AuraHandledException(ex.getMessage());
        }
    }

    public void changeSelectedProductUuid(){
        selectedproductuuid = selectedproductuuid;
        meetDuration = '';
        selectedDateFormatted = '';
        selectedDateWeekDay = '';
        shiftStartDateTime = null;
        shiftEndDateTime = null;
        initialBookingSlots = new List<Datetime>();
        availableBookingSlots = new List<Datetime>();
        availableBookingSlotsUTC = new List<String>();
        availableBookingSlotsTimezone = new List<String>();
        availableBookingSlotsUTCMap = new Map<String, String>();
        createAppointmentResponseStatusCode = null;
        showScheduledAppointmentDetails = false;
        confirmedAppointmentStartTime = ''; 
        confirmedAppointmentEndTime = '';
        selectedappointmentUuid = '';
        cancellAppointmentResponseStatusCode = null;

        System.debug('schedulingProductsList ' + schedulingProductsList.size());
        for(Product__c iterProduct : schedulingProductsList){
            if(iterProduct.UUID__c == selectedproductuuid){
                selectedschedulingProduct = iterProduct;
                break;
            }
        }
    }

    public void changeSelectedDisplayTimeZone(){
        System.debug('selectedDisplayTimeZone ' + selectedDisplayTimeZone);
        displayTimeZone = selectedDisplayTimeZone ;     
        getDateTimeSlotsBasedonTimezone();   
    }

    /**
     * Exception class
     */
    public class CalendarUtilityException extends Exception {}

    //Fetch Member Details
    /**
     * @brief to fetch Member information from memberId or uuid.
     * @param[1] Member Id or UUID
     */
    public MemberWrapper getMemberDetailsbyIdorUuid(String memberIdorUuid) {
        String accountsListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Account') +
        ' FROM Account WHERE ';
        if ((memberIdorUuid.length() == 15) || (memberIdorUuid.length() == 18)) {
            accountsListQuery += 'Id =: memberIdorUuid';
        } else {
            accountsListQuery += 'UUID__c =: memberIdorUuid';
        }
        List<Account> accountRecords = Database.query(accountsListQuery);
        if (accountRecords.size() > 0) {
            memberWrapperData = new MemberWrapper(accountRecords[0]);
        }
        return memberWrapperData;
    }
    
    /**
     * @brief to fetch product information from productuuid.
     * @param[1] product uuid
     */
    public Product__c getProductDetails(String productuuid) {
        String query = 'SELECT ' + 
            SYS_Helper.getAllFieldsFor('Product__c') + ', ' + 
            SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ' FROM Product__c WHERE UUID__c =: productuuid';

        List<Product__c> productRecord = Database.query(query);
        if(productRecord != NULL && productRecord.size() > 0) {
            return productRecord[0];
        }
        else {
            throw new CalendarUtilityException('No products found with UUID :: '+productuuid);
        }
    }

    /**
     * @brief fetch available slot from google calendar.
     * @param[1] product identifier.
     * @param[2] count for future days for which the availablity needed to be fetched. 
     * @return google calendar response body as string.
     */

    public String freeBusyCheck(String productuuid, DateTime startDateTime, Integer dayCount) {
        String startDateTimeString, endDateTimeString, shiftCalendarId, bookingCalendarId, meetDuration, result;
        try {
            if(memberWrapperData != NULL) {
                selectedschedulingProduct = getSchedulingProductByUUID(memberObjectApiName, productuuid);
            }
            if(selectedschedulingProduct == NULL ) {
                selectedschedulingProduct = getProductDetails(productuuid);
            }
            DateTime startDatetimeVariable = startDateTime; 
            DateTime endDateTimeVariable = startDatetimeVariable.addDays(dayCount);
            // Datetime localDatetime = Datetime.now();
            // Convert the local DateTime to UTC
            // Datetime utcDatetime = localDatetime.addHours(-localDatetime.getTimezoneOffset());
            //  if (startDatetimeVariable < utcDatetime) {
            //     System.debug()
            //     startDatetimeVariable = DateTime.now();
            //  }
            
            shiftCalendarId = selectedschedulingProduct.Google_Shift_Calendar_Id__c;
            bookingCalendarId = selectedschedulingProduct.Google_Booking_Calendar_Id__c;
            startDateTimeString = startDatetimeVariable.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            endDateTimeString = endDateTimeVariable.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');

            String IntegrationName = 'Calendar';
            String calloutMethod = 'POST';
            String calloutUrl = 'https://www.googleapis.com/calendar/v3/freeBusy';
            
            List<cls_items> cls_itemsList = new List<cls_items>();
            cls_items shiftcls_item = new cls_items();
            shiftcls_item.Id = shiftCalendarId;
            cls_itemsList.add(shiftcls_item);

            cls_items bookingcls_item = new cls_items();
            bookingcls_item.Id = bookingCalendarId;
            cls_itemsList.add(bookingcls_item);

            freeBusyRequestJSON freeBusyrequestJosnWrapper = new freeBusyRequestJSON();
            freeBusyrequestJosnWrapper.timeMin = startDateTimeString;
            freeBusyrequestJosnWrapper.timeMax = endDateTimeString;
            freeBusyrequestJosnWrapper.timeZone = DialogFlow_Helper.TIMEZONE;
            freeBusyrequestJosnWrapper.calendarExpansionMax = 50;
            freeBusyrequestJosnWrapper.groupExpansionMax = 100;
            freeBusyrequestJosnWrapper.items = cls_itemsList;

            String requestJsonBody = JSON.serialize(freeBusyrequestJosnWrapper);
            HttpResponse resp = buildOutboundHttpRequest(IntegrationName, calloutMethod, calloutUrl, requestJsonBody);
            result = resp.getBody();
            System.debug('freeBusyResponse: ' + result);
        } catch (Exception ex) {
            throw new CalendarUtilityException('Freebusy error '+ex.getMessage() + ex.getStackTraceString());
        }

        return result;
    }

    /**
     * @brief get start datetime to pass to free-busy google api.
     */

    public Datetime getStartDateTime(Datetime providedDatetime, Integer minimumLeadTime, Integer slotInterval) {
        DateTime result = providedDatetime;
        // System.debug('providedDatetime '+providedDatetime);
        result = resetSecondsToZero(result);
        // System.debug('resetSecondsToZero '+result);
        result = result.addMinutes(minimumLeadTime);
        // System.debug('addMinutes(minimumLeadTime) '+result);
        result = roundToNextInterval(result, slotInterval);
        // System.debug('roundToNextInterval '+result);
        return result;
     }
     /**
      * @brief caller method for slot
      */
    public void fetchAvailableSlot() {
        try {
            Integer daycount = Integer.valueOf(apexpages.currentPage().getParameters().get('dayCount'));
            System.debug('daycount '+daycount);

            DateTime startDatetimeVariable = freeBusyResponseWrapper.formatDateTime(this.startDatetime, 'YYYY-MM-DDThh:mm:ssZ');
            
            Map<String, List<DateTime>> result = getAvailableSlotMap(this.selectedproductuuid, startDatetimeVariable, dayCount);
            this.availableSlotMap = JSON.serializepretty(result);
            availableBookingSlotsTimezone.add('01:00 AM');
            availableBookingSlotsTimezone.add('02:00 AM');
            availableBookingSlotsTimezone.add('03:00 AM');
            availableBookingSlotsTimezone.add('04:00 AM');
            
        } catch (Exception e) {
            System.debug(e.getMessage()+e.getStackTraceString());
        }
    }

    public void sample() {
        this.availableSlotMap = 'why why!!';
    }

     /**
      * @brief to get the available slot map
      * @return the map of date and available slots
      */
    public Map<String, List<DateTime>> getAvailableSlotMap(String productuuid, DateTime startDateTime, Integer dayCount) {
        Map<String, List<DateTime>> availableSlotMap = new Map<String, List<DateTime>>();
        DateTime shiftStartDateTime, shiftEndDateTime;
        try {
            Product__c selectedschedulingProduct = getProductDetails(productuuid);
            String googleShiftCalendarId = selectedschedulingProduct.Google_Shift_Calendar_Id__c;
            String googleBookingCalendarId = selectedschedulingProduct.Google_Booking_Calendar_Id__c;
            Integer slotInterval = (String.isNotBlank(selectedschedulingProduct.Meet_Duration__c)) ? 
                Integer.valueof(selectedschedulingProduct.Meet_Duration__c) : 0;
            this.meetDuration = selectedschedulingProduct.Meet_Duration__c;
            String minimumLeadTimeString = selectedschedulingProduct.Minimum_Lead_Time__c;
            Integer minimumLeadTime = (String.isNotBlank(minimumLeadTimeString)) ? Integer.valueof(minimumLeadTimeString) : 0;
            startDateTime = getStartDateTime(startDateTime, minimumLeadTime, slotInterval);
            System.debug('startDateTime '+startDateTime);
            // startDateTime = startDateTime.addMinutes(-1);
            String response = freeBusyCheck(productuuid, startDateTime, dayCount);
            // String response = '{"kind":"calendar#freeBusy","timeMin":"2023-09-17T06:14:12.000Z","timeMax":"2023-09-19T06:14:12.000Z","calendars":{"c_18silva8h85tbavoapq08emu0o@group.calendar.google.com":{"busy":[{"start":"2023-09-17T15:00:00Z","end":"2023-09-17T20:00:00Z"},{"start":"2023-09-18T15:00:00Z","end":"2023-09-18T20:00:00Z"}]},"c_pq799u40jicsqr9ijhtg4e3r3g@group.calendar.google.com":{"busy":[{"start":"2023-09-17T15:00:00Z","end":"2023-09-17T15:30:00Z"},{"start":"2023-09-17T16:00:00Z","end":"2023-09-17T16:30:00Z"},{"start":"2023-09-17T18:30:00Z","end":"2023-09-17T19:30:00Z"},{"start":"2023-09-18T15:00:00Z","end":"2023-09-18T15:30:00Z"}]}}}';
            // String response = '{"kind":"calendar#freeBusy","timeMin":"2023-09-17T06:14:12.000Z","timeMax":"2023-09-19T06:14:12.000Z","calendars":{"c_18silva8h85tbavoapq08emu0o@group.calendar.google.com":{"busy":[]},"c_pq799u40jicsqr9ijhtg4e3r3g@group.calendar.google.com":{"busy":[]}}}';
            FreeBusyResponseWrapper freeBusyResponseObject = freeBusyResponseWrapper.parse(response);

            Map<String , List<freeBusyResponseWrapper.Busy>> calendarIdBusySlotsListMap = freeBusyResponseObject?.calendars?.calendarIdBusySlotsMap;
            
            System.debug('startDateTime '+startDateTime);

            if( calendarIdBusySlotsListMap.containsKey(googleShiftCalendarId) ){
                List<freeBusyResponseWrapper.Busy> shiftBusySlots = calendarIdBusySlotsListMap.get(googleShiftCalendarId);
                
                if( shiftBusySlots.size() > 0 ){
                    shiftStartDateTime = resetSecondsToZero(shiftBusySlots[0].start_x);
                    shiftEndDateTime = resetSecondsToZero(shiftBusySlots[0].end_x);
                    List<DateTime> allStartTimeSlot = new List<DateTime>();
                    for (freeBusyResponseWrapper.Busy tempShiftSlot : shiftBusySlots) {
                        DateTime startTime = resetSecondsToZero(tempShiftSlot.start_x);
                        DateTime endTime = resetSecondsToZero(tempShiftSlot.end_x);
                        
                        shiftStartDateTime = (shiftStartDateTime < startTime) ? shiftStartDateTime : startTime;
                        shiftEndDateTime = (shiftEndDateTime > endTime) ? shiftEndDateTime : endTime;
                        // System.debug('TIME SHIFT START '+shiftStartDateTime+' : '+startTime);
                        // System.debug('TIME SHIFT END '+shiftEndDateTime+' : '+endTime);
                        // String datekey = startTime.formatGMT('yyyy-MM-dd');
                        // List<Datetime> timeSlots = getInitialSlots(startTime, endTime, slotInterval);
                        // if (!availableSlotMap.containsKey(datekey)) {
                        //     availableSlotMap.put(datekey, timeSlots); //slots from shift calendar
                        // } else {
                        //     availableSlotMap.get(datekey).addAll(timeSlots);
                        // }
                        // allStartTimeSlot.addAll(timeSlots);
                        availableSlotMap = generateSlots(startTime, endTime, slotInterval, availableSlotMap, allStartTimeSlot);
                    }
                    Map<Datetime, Integer> sfBusySlotsMap = getBusySlotMap(allStartTimeSlot, googleBookingCalendarId);
                    System.debug('SF LOCAL '+JSON.serializePretty(sfBusySlotsMap));
                    
                    System.debug('BEFORE '+JSON.serializePretty(availableSlotMap));
                    if (calendarIdBusySlotsListMap.containsKey(googleBookingCalendarId)) {
                        List<freeBusyResponseWrapper.Busy> bookingCalendarBusySlots = calendarIdBusySlotsListMap.get(googleBookingCalendarId);
                        Map<String, List<freeBusyResponseWrapper.Busy>> busySlotInBookingCal = new Map<String, List<freeBusyResponseWrapper.Busy>>();
                        
                        for (freeBusyResponseWrapper.Busy tempShiftSlot : bookingCalendarBusySlots) {
                            DateTime startTime = resetSecondsToZero(tempShiftSlot.start_x);
                            DateTime endTime = resetSecondsToZero(tempShiftSlot.end_x);
                            String datekey = startTime.formatGMT('yyyy-MM-dd');
                            if (!busySlotInBookingCal.containsKey(datekey)) {
                                busySlotInBookingCal.put(datekey, new List<freeBusyResponseWrapper.Busy>{tempShiftSlot});
                            } else {
                                busySlotInBookingCal.get(datekey).add(tempShiftSlot);
                            }
                        }
                        // System.debug('booking busy slot'+JSON.serializePretty(busySlotInBookingCal));
                        for (String datekey : availableSlotMap.keySet()) {
                            // System.debug('datekey '+datekey);
                            if (availableSlotMap.get(datekey) != NULL && availableSlotMap.get(datekey).size() > 0) {
                                for (Integer i = availableSlotMap.get(datekey).size() - 1 ; i>=0 ;i--) {
                                    DateTime slotTime = availableSlotMap.get(datekey)[i];
                                    // System.debug('slotTime '+slotTime+'slot local '+sfBusySlotsMap.get(slotTime)+' iter '+i);
                                    
                                    if (busySlotInBookingCal.containsKey(datekey) && busySlotInBookingCal.get(datekey) != NULL) {
                                        for(freeBusyResponseWrapper.Busy busyWrapper : busySlotInBookingCal.get(datekey)) {
                                            DateTime startTime = resetSecondsToZero(busyWrapper.start_x);
                                            DateTime endTime = resetSecondsToZero(busyWrapper.end_x);
                                            // Boolean x = slotTime >= startTime && slotTime<endTime;
                                            // Boolean y = sfBusySlotsMap.get(slotTime) != NULL && sfBusySlotsMap.get(slotTime) >= THRESHOLD;
                                            // System.debug('start end '+startTime+' '+endTime+' slot '+slotTime+' cond '+x+' condy'+y);
                                            if (slotTime >= startTime && slotTime<endTime 
                                            && sfBusySlotsMap.get(slotTime) != NULL && sfBusySlotsMap.get(slotTime) >= THRESHOLD) {
                                                availableSlotMap.get(datekey).remove(i);
                                                break;
                                            }
                                        }
                                    }
                                }

                            }
                        }
                    }
                }
                System.debug('FINAL'+JSON.serializePretty(availableSlotMap));
            }

            // List<Datetime> initialBookingSlots, availableBookingSlots;

            // initialBookingSlots = getInitialSlots(shiftStartDateTime, shiftEndDateTime, slotInterval);

            // List<freeBusyResponseWrapper.Busy> busySlotsWrapperList = new List<freeBusyResponseWrapper.Busy>();
            // if ( calendarIdBusySlotsListMap.containsKey(googleBookingCalendarId) ) {
            //     List<freeBusyResponseWrapper.Busy> bookingCalendarBusySlots = calendarIdBusySlotsListMap.get(googleBookingCalendarId);
            //     if ( bookingCalendarBusySlots.size() > 0 ) {
            //         busySlotsWrapperList = bookingCalendarBusySlots;
            //     }
            // }
            // availableBookingSlots = getFinalSlotsNew(busySlotsWrapperList, initialBookingSlots);
            // System.debug(JSON.serializePretty(getBusySlotMap(initialBookingSlots)));
            // // Map<>
            // for(DateTime slot : availableBookingSlots) {
            //     if (slot != NULL) {
            //         String dateValue = slot.formatGMT('yyyy-MM-dd');
                    
            //         if (!availableSlotMap.containsKey(dateValue)) {
            //             availableSlotMap.put(dateValue, new List<DateTime>{slot});
            //         }
            //         else {
            //             availableSlotMap.get(dateValue).add(slot);
            //         }
            //     }
            // }

        } catch (Exception e) {
            throw new CalendarUtilityException('Freebusy error '+e.getMessage() + e.getStackTraceString());
        }
        System.debug(JSON.serializePretty(availableSlotMap));
        return availableSlotMap;
    }
    /**
     * @brief filter all busy slots from the list of available slots
     */

    //  public List<DateTime> filterBusySlots()

     /**
     * @brief this method is used to check the slot is available, to allow duplicate bookings
     * @param[1] 
     */

     public static Boolean allowAppointmentBooking(Datetime appointmentStartDateTime, String Google_Booking_Calendar_Id) {
        String appointmentListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Appointment_Scheduling__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Product__r.', 'Product__c') +
                ' FROM Appointment_Scheduling__c WHERE StartDate__c =: appointmentStartDateTime AND Google_Booking_Calendar_Id__c =: Google_Booking_Calendar_Id AND Status__c = \'confirmed\'';
        List<Appointment_Scheduling__c> appointmentList = Database.query(appointmentListQuery);
        return (appointmentList.size() <= SLOT_COUNT) ? true : false;
    }

    /**
     * @brief get the threshold
     */
    public static Integer THRESHOLD{
        get{
            Integer val;
            try {
                val = Integer.valueOf(Label.ADS_booking_threshold);
            } catch (Exception e) {
                val = 1;
            }
            return val;
        }
    }

    /**
     * @brief filter method to allow multiple appointment.
     */
    public Boolean isSlotAvailable(Map<Datetime, Integer> sfBusySlotsMap, DateTime slotTime) {
        Boolean result = sfBusySlotsMap.get(slotTime) != NULL && sfBusySlotsMap.get(slotTime) >= THRESHOLD;
        return result;
    }

    /**
     * @brief generates the final slots after filtering the busyslots
     */

    // public List<Datetime> getFinalSlotsNew(List<freeBusyResponseWrapper.Busy> busySlots, List<Datetime> initialSlots){
    //     List<Datetime> finalSlots = new List<Datetime>();
    //     List<Datetime> tempBusySlots = new List<Datetime>();
    //     Map<Datetime, Integer> busySlotMap = getBusySlotMap(initialSlots);
    //     if( (initialSlots.size() > 0) && (busySlots.size() > 0) ){
    //         for (Datetime iterinitialSlot: initialSlots) {
    //             for (freeBusyResponseWrapper.Busy iterbusySlotWrap: busySlots) {
    //                 if( ( (iterbusySlotWrap.start_x <= iterinitialSlot) && 
    //                 (iterinitialSlot < iterbusySlotWrap.end_x) ) ){
    //                     if ( (busySlotMap.get(iterinitialSlot) != NULL && busySlotMap.get(iterinitialSlot) >= THRESHOLD)) {
    //                         tempBusySlots.add(iterinitialSlot);
    //                     }
    //                 }
    //             }
    //         }

    //         // Clear Filtered Busy Slots
    //         for(Datetime iterinitialSlotSlice : initialSlots){
    //             if(!tempBusySlots.contains(iterinitialSlotSlice)){
    //                 finalSlots.add(iterinitialSlotSlice);
    //             }
    //         }
    //     }else{
    //         finalSlots = initialSlots;
    //     }
    //     return finalSlots;
    // }

    /**
     * @brief get local busy slot map, bulk query
     */
    public Map<Datetime, Integer> getBusySlotMap(List<Datetime> initialSlots, String Google_Booking_Calendar_Id) {
        Map<Datetime, Integer> result = new Map<Datetime, Integer>();
        String query = 'SELECT id, StartDate__c, Status__c FROM Appointment_Scheduling__c WHERE StartDate__c IN :initialSlots AND Google_Booking_Calendar_Id__c =: Google_Booking_Calendar_Id AND Status__c = \'confirmed\' LIMIT 10000';
        List<Appointment_Scheduling__c> schedules = Database.query(query);

        if(schedules != NULL && schedules.size() > 0) {
            for(Appointment_Scheduling__c record : schedules) {
                if (!result.containsKey(record.StartDate__c)) {
                    result.put(record.StartDate__c, 1);
                } else {
                    System.debug('appointment '+record.Id);
                    result.put(record.StartDate__c, result.get(record.StartDate__c) + 1);
                }
            }
        }
        System.debug('busyMap '+JSON.serializePretty(result));
        return result;
    }

    public Map<String, List<DateTime>> generateSlots(DateTime startTime, DateTime endTime, Integer slotInterval, 
    Map<String, List<DateTime>> availableSlotMap, List<DateTime> allStartTimeSlot) {
        List<Datetime> timeSlots = getInitialSlots(startTime, endTime, slotInterval);

        for (DateTime slot : timeSlots) {
            String datekey = slot.formatGMT('yyyy-MM-dd');
            if (!availableSlotMap.containsKey(datekey)) {
                availableSlotMap.put(datekey, new List<DateTime>{slot}); //slots from shift calendar
            } else {
                availableSlotMap.get(datekey).add(slot);
            }
            allStartTimeSlot.add(slot);
        }
        return availableSlotMap;
    }


    /**
     * @brief this method is used to fetch all the available slots
     * 
    */

    //  public static Map<String, List<DateTime>> getAllSlots() {

    //  }
}