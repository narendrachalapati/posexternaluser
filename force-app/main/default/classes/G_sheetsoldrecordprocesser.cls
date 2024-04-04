public with sharing class G_sheetsoldrecordprocesser implements Database.Batchable < sObject > , Database.Stateful, Database.AllowsCallouts,schedulable {

  public List < Id > AccountIdlist;
  public Integer accountCount;
  public Id AccountId;
  public G_sheetsoldrecordprocesser(List < Id > AccountIdlist) {
    this.AccountIdlist = AccountIdlist;
    this.accountCount = AccountIdlist.size();
  }
  public Database.QueryLocator start(Database.BatchableContext BC) {
    //String accountId = '001Hp00002kZNupIAG';
    Id accid = AccountIdlist[0];
    String type = 'SpreadSheet';
    SYS_DataCacheFactory init = new SYS_DataCacheFactory(
      accid,
      type,
      type,
      'object_api_name');
      string ObjectApiName = 'Contact';
    String query = 'SELECT ' + SYS_Helper.getAllFieldsFor(ObjectApiName) + '  FROM  ' + ObjectApiName;
    String whereClause = ' WHERE AccountId in (' + '\'' + String.escapeSingleQuotes(accid) + '\')';
   // List < Sobject > sobjectrecList = Database.query(String.escapeSingleQuotes(query) + whereClause);
    //string orderedfields = SYS_DataCacheFactory.metadata.get('object_api_name');
   // String query = 'SELECT id,SpreadSheet_Id__c,SpreadSheet__c from Contact';
    system.debug('queryContact' + query);
    return Database.getQueryLocator(String.escapeSingleQuotes(query) + whereClause);
  }
  public void execute(Database.BatchableContext BC, List < Contact > sojectlist) {
    string Gsheetid = G_sheetsoldrecordprocesserhandler.Spreadsheetid(sojectlist);
    string accountId = AccountIdlist[0];

    // if(){
    //  string  = G_sheetsoldrecordprocesserhandler.spreadsheetCreation(accountId);
    //}
    string responsebody = G_sheetsoldrecordprocesserhandler.Clearsheet(Gsheetid, accountId);
    system.debug('Gsheetid' + Gsheetid);
    for (Contact sobj: sojectlist) {
      sobj.SpreadSheet__c = Gsheetid;
      sobj.Gsheetsync__c = false;
    }
    update sojectlist;
  }
  //Schedulable Excute
  public void execute(SchedulableContext SC) {
    List < Id > accidList = new List < Id > ();
    List < Account > AccountIdlist = [SELECT ID from Account];
    for (Account Accountid: AccountIdlist) {
      accidList.add(Accountid.Id);

    }
    accidList.remove(0);
    for (Integer i = 0, j = 0; i < accidList.size(); i++) {
      database.executebatch(new G_sheetsoldrecordprocesser(accidList));
    }

  }

  public void finish(Database.BatchableContext BC) {
   

  }
}