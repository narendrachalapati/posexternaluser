@IsTest
public class Gspreadsheet_sys_ApplicationserviceTest {

 @IsTest
    public  static void preprocessJSONForOutboundTest(){
        SYS_TestDataFactory.createObjectSettingLog();
           HttpRequest req = new HttpRequest();
           req.setEndpoint('https://sheets.googleapis.com/v4/spreadsheets');
           req.setMethod('POST');
      Account acct =    Gspreadsheet_Datafactory.createTestRecords();
        SYS_IntegrationLog__c intlog =  Gspreadsheet_Datafactory.syslog(acct.id);
       // list<SYS_IntegrationLog__c> log = [SELECT Id,Status__c,Integration_Setting__c from SYS_IntegrationLog__c];
        string jsonBody = '{"spreadsheetUrl":"","properties":{"title":"Connect-Adisolsteam"}}';
        Gspreadsheet_sys_Applicationservice gap = new Gspreadsheet_sys_Applicationservice();
        gap.preprocessJSONForOutbound(intlog, jsonBody, req);
        
    }

}