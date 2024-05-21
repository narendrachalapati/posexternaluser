public without sharing class EligibulityUtility {
   /*********************************************************************
   * ***********************************************************
   * This Hook is for getting the Details of Insurance Details From By using the 
   * Recordid and with additional filters.
   */
  
  public static list < Insurance__c > insuranceDataUtility(string contactRecordId) {
    List < Insurance__c > InsurenceList = new list < Insurance__c > ();
    //List <Appointment_Scheduling__c> AppointmentList = new list <Appointment_Scheduling__c>();
    try {
      String insurencestring = 'SELECT ' + SYS_Helper.getAllFieldsFor('Insurance__c') +
        ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
        ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Copay__c') + ' FROM Copay__r)' +
        ' FROM Insurance__c WHERE (Contact__c =: contactRecordId)';
      system.debug('members serch' + insurencestring);
      InsurenceList = Database.query(insurencestring);
      system.debug('fetchRecordNDR' + InsurenceList);

    } catch (Exception e) {
      System.debug('The following exception has occurred: ' + e.getMessage());
    }
    return (InsurenceList.size() > 0) ? (InsurenceList) : (new List < Insurance__c > ());
  }
  /*********************************************************************
   * ***********************************************************
   * This Hook is for getting the Details of Appointment From By using the 
   * Recordid and with additional filters.
   */
  public static  Appointment_Scheduling__c  AppointmentDataUtility(string contactRecordId , string AppointmentId) {
   // List < Appointment_Scheduling__c > AppointmentList = new list < Appointment_Scheduling__c > ();
   Appointment_Scheduling__c  Appointment;
    try {

      string Appointmentstring = 'SELECT ' + SYS_Helper.getAllFieldsFor('Appointment_Scheduling__c') +
        ', ' + SYS_Helper.getAllParentFields('Product__r.', 'Product__c') +
        ' FROM Appointment_Scheduling__c WHERE (StartDate__c >=today) AND (Contact__c =: contactRecordId) AND (Id =: AppointmentId)';
      system.debug('Appointmentstring NDR' + Appointmentstring);
      Appointment = Database.query(Appointmentstring);
      system.debug('Appointmentstring NDR' + Appointment);
    } catch (Exception e) {
      System.debug('The following exception has occurred: ' + e.getMessage());
    }
    return (Appointment != null) ? (Appointment) : (new Appointment_Scheduling__c ());
  }

  public static Insurance__c copayCheckUtility(List < Insurance__c > insuranceList, string insuranceId) {
    Map < Id, Insurance__c > insuranceMap = new Map < Id, Insurance__c > ();
    for (Insurance__c insuranceiter: insuranceList) {
      insuranceMap.put(insuranceiter.Id, insuranceiter);

    }
    Insurance__c insurance = insuranceMap.get(insuranceId);
    system.debug('insurance NDR ' + insurance);
    return insurance;
  }
  /*********************************************************************
   * ***********************************************************
   * This Hook is for Adding Balance record and marking the todo as complete
   */
  public static ToDo__c todoCompleteUtility(string todorecordId, Decimal Amount, string memberrecordid) {
    system.debug('todorecordId' + todorecordId);
    List < Appointment_Scheduling__c > AppointmentList = new list < Appointment_Scheduling__c > ();
    String Appointmentstring = 'SELECT ' + SYS_Helper.getAllFieldsFor('Appointment_Scheduling__c') +
      ', ' + SYS_Helper.getAllParentFields('Product__r.', 'Product__c') +
      ' FROM Appointment_Scheduling__c WHERE (Contact__c =: memberrecordid) AND Status__c=\'Status__c\'';
    system.debug('members serch' + Appointmentstring);
    AppointmentList = Database.query(Appointmentstring);
    system.debug('members serch' + AppointmentList);
    Balance_Transaction__c BalanceTransaction = new Balance_Transaction__c();
    BalanceTransaction.Type__c = 'Debit';
    BalanceTransaction.Amount__c = Amount;
    BalanceTransaction.Contact__c = memberrecordid;
    insert BalanceTransaction;
    ToDo__c todorec = [SELECT Status__c From ToDo__c WHERE Id =: todorecordId];
    todorec.Status__c = 'Completed';
    update todorec;
    return todorec;

  }

}