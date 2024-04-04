public with sharing class G_sheetsoldrecordprocesserhandler {
  /**************  this class is the helper class for the 
     G_sheetsoldrecordprocesser batch Apex class for giving the checks
     ***************************/
  public static string Spreadsheetid(list < Contact > sobjlist) {

    system.debug(sobjlist);
    list < Contact > conlist = new list < Contact > ();
    if (sobjlist.size() > 0) {
      for (Contact sobj: sobjlist) {
        system.debug(sobj.SpreadSheet__c);
        if (String.isNotEmpty(sobj.SpreadSheet__c)) {
          conlist.add(sobj);
        }
      }

    } else {
      system.debug('list has zero records');
    }
    system.debug(conlist);
    system.debug(conlist[0].SpreadSheet__c);
    return conlist[0].SpreadSheet__c;
  }
  /************** Http callout for clearing the records
   ***************************/
  public static string Clearsheet(string spreadsheetid, string accountId) {
    string url = 'https://sheets.googleapis.com/v4/spreadsheets/' + spreadsheetid + '/values/Sheet1:clear';
    list < SYS_OAuthConfig__c > sysoauth = [SELECT Access_Token__c from SYS_OAuthConfig__c
      where Integration_Type__c = 'SpreadSheet'
      AND Account__c =: accountId
    ];

    system.debug('url' + url);
    // Instantiate a new Http object
    Http h = new Http();
    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('POST');
    req.setBody('{}');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', 'Bearer ' + sysoauth[0].Access_Token__c);
    HttpResponse res = h.send(req);
    system.debug('res.getBody(): ' + res.getBody());
    system.debug('res.getBody(): ' + res.getStatus());
    return res.getBody();
  }
  /************** Http callout for Getting the provided id sheetvalues the records
   ***************************/
  public static string getSheetvalues(string spreadsheetid, string accountId,string objectname) {
    string url = 'https://sheets.googleapis.com/v4/spreadsheets/' + spreadsheetid + '/values/Sheet1';
      Map < String, Object > newflatKeyMap = new Map < String, Object > ();
    list < SYS_OAuthConfig__c > sysoauth = [SELECT Access_Token__c from SYS_OAuthConfig__c
      where Integration_Type__c = 'SpreadSheet'
      AND Account__c =: accountId
    ];

    system.debug('url' + url);
    // Instantiate a new Http object
    Http h = new Http();
    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('GET');

    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', 'Bearer ' + sysoauth[0].Access_Token__c);
    HttpResponse res = h.send(req);
    system.debug('res.getBody(): ' + res.getBody());
    system.debug('res.getBody(): ' + res.getStatus());
    string reponcebody  = res.getBody(); 
    //String str = JSON.serialize(dt); 
    system.debug('Getjson'+ JSON.serialize(reponcebody.replace('\n', ' ')) );
    String finalJSON = reponcebody.replace('\n', ' ');
    Object convert = System.JSON.deserializeUntyped(reponcebody);
    newflatKeyMap = (SYS_Helper.getFlatKeys(finalJSON, 'A.B'));
   List<Object> valuesList = ((List<Object>)((Map<String, Object>)convert).get('values'));
   
      
    system.debug('valuesList'+valuesList);
    return res.getBody();
  }
 /************** Http callout for creating  the spreadsheet in the external system records
   ***************************/
  public static string spreadsheetCreation(string accountId) {
    string Name, spreadsheetId, spreadsheetUrl, tittle;
    string url = 'https://sheets.googleapis.com/v4/spreadsheets';
    list < SYS_OAuthConfig__c > sysoauth = [SELECT Access_Token__c, Account__r.Name from SYS_OAuthConfig__c
      where Integration_Type__c = 'SpreadSheet'
      AND Account__c =: accountId
    ];
    system.debug('url' + url);
    tittle = sysoauth[0].Account__r.Name;
    system.debug('tittle' + tittle);
    String requestbody = '{"properties": {"title":' + '"' + tittle + '"}}';

    // Instantiate a new Http object
    Http h = new Http();
    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('POST');
    req.setBody(requestbody);
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', 'Bearer ' + sysoauth[0].Access_Token__c);
    HttpResponse res = h.send(req);
    system.debug('res.getBody(): ' + res.getBody());
    system.debug('res.getBody(): ' + res.getStatus());
    string jsonRecord = res.getBody();
    //Deserilize JSON and Map Keys 
    Map < String, Object > newflatKeyMap = new Map < String, Object > ();
    String finalJSON = jsonRecord.replace('\n', ' ');
    Object convert = System.JSON.deserializeUntyped(finalJSON);
    newflatKeyMap = (SYS_Helper.getFlatKeys(finalJSON, 'A.B'));
    spreadsheetId = (String) newflatKeyMap.get('spreadsheetId');
    spreadsheetUrl = (String) newflatKeyMap.get('spreadsheetUrl');
    system.debug('spreadsheetId' + spreadsheetId);
    if (String.isNotEmpty(spreadsheetId)) {
      SpreadSheet__c spread = new SpreadSheet__c();
      spread.SpreadSheet_Id__c = spreadsheetId;
      spread.Name = Name + accountId;
      spread.Account__c = accountId;
      spread.spreadsheetUrl__c = spreadsheetUrl;
      insert spread;
    }
    return res.getBody();

  }

}