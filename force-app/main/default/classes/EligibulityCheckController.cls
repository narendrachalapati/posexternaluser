public with sharing class EligibulityCheckController {
    @AuraEnabled
    public string memberrecordid {get; set; }
    @AuraEnabled
    public string Accountrecordid {get;set;}
    @AuraEnabled
    public string todorecordId {get; set; }
    public string AppointmentId {get; set; }
    @AuraEnabled
    public ToDo__c todorecord {get; set; }
    @AuraEnabled
    public string uuid {get;set;} 
    public Decimal CopayAmount {get;set;} 
    public Copay__c Copay {get;set;} 
    public Decimal Amount {get;set;}
    public Double TotalAmount {get;set;}
    @AuraEnabled
    public list < Insurance__c > InsurenceList {get; set;}
    public  Insurance__c  SelectedInsurance {get; set;}
    public List < SelectOption > insuranceOptions {get; set; }
    public string selctedInsuranceoption {get;set; } 
   
    public Appointment_Scheduling__c Appointment {get;set; }
       /*********************************************************************
   * ***********************************************************
   * This Hook is for getting the Details of Insurance Details Along with Appoint ment info  By using the 
   * Recordid and with additional filters.
   */
    public void insuranceData() {
      system.debug('todorecordId NDR' + todorecordId);
      InsurenceList = EligibulityUtility.insuranceDataUtility(memberrecordid);
      Appointment = EligibulityUtility.AppointmentDataUtility(memberrecordid,AppointmentId);
      if (InsurenceList.size() > 0) {
        CopayAmount = InsurenceList[0].Copay__c;
        system.debug('CopayAmountNDR' + CopayAmount);
      }
      insuranceOptions = new List<SelectOption>();
     
      for (Insurance__c insurance : InsurenceList) {
        system.debug('insurenceNDR' + insurance.Id + insurance.Name);
        insuranceOptions.add(new SelectOption(insurance.Id, insurance.Name));
      }
      system.debug('AppointmentListNDR' + Appointment);
      if (Appointment != null) {
       
          system.debug('#################Appointmentinfo ################################');
          system.debug('AppoinmentNDR' + Appointment.Id + Appointment.Name);
          system.debug('#################Appointmentinfo ################################');
         TotalAmount = Appointment.Product__r.Max_Price__c;
         if(TotalAmount != null){
        Amount = (CopayAmount / 100) * TotalAmount;
      }
        system.debug('Amount NDR' + Amount);
      }
      system.debug('InsurenceList' + InsurenceList);
    }
    public void copayCheck() {
      SelectedInsurance = EligibulityUtility.copayCheckUtility(
          InsurenceList, selctedInsuranceoption);
      system.debug('SelectedInsurance' + SelectedInsurance);
      //if (SelectedInsurance != null) {
        CopayAmount = SelectedInsurance.Copay__c;
        Amount = (CopayAmount / 100) * TotalAmount;
        system.debug('CopayAmountNDR' + CopayAmount);
     // }
    }
    public void tOdocomplete() {
      system.debug(
          '#################ToDo Complete ################################');
      system.debug('todorecordId NDR' + todorecordId);
      todorecord = EligibulityUtility.todoCompleteUtility(
          todorecordId, Amount, memberrecordid);
      // string todorecordId,Decimal Amount,string memberrecordid
      system.debug(
          '#################ToDo Complete ################################');
    }
  }