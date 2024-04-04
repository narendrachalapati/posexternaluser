@isTest
public class Gspreadsheet_Datafactory {
  public static Account createTestRecords(){
      //List<Account> accts = new List<Account>();       
       // for(Integer i=0;i<numAccts;i++) {
            Account acct = new Account();
            acct.Name = 'Municorn Test Account';
            acct.Phone = '(999) 999-9999';
            acct.Formatted_Phone_Number__c = '19999999999';
            acct.Website = 'municorn.ai/Care/index.html';
            acct.UUID__c = SYS_Helper.getUUID();
            //accts.add(a);
        
        insert acct;

   return acct;
  }
    
   public static SYS_IntegrationLog__c syslog( string accid){
  SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert('{"properties":{"title":"Connect-Adisolsteam"}}');
        newSysLog.Status__c = SYS_Constants.NEW_STATUS;
        newSysLog.Type__c = SYS_Constants.OUTBOUND;
        newSysLog.Integration_Setting__c = 'SpreadSheet';
        newSysLog.SYS_Operation_Type__c = 'INSERT';
        newSysLog.whatid__c = accid;
        newSysLog.ObjectSettingId__c = 'SpreadSheet';
        newSysLog.How_to_process__c = 'use_object_setting';
        // insert newSysLog;
        SYS_Helper.insertLog(newSysLog);
        return newSysLog;
    }
}