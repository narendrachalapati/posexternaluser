public with sharing class Gspreadsheet_sys_Applicationservice extends SYS_ApplicationService {

  Public Override String preprocessJSONForOutbound(SYS_IntegrationLog__c log, String jsonBody, HttpRequest req) {
    /*--*/
    SYS_debug.log('Default preprocessJSONForOutbound called');

    if (req.getHeader('content-type') == 'application/x-www-form-urlencoded') {
      String formUrlEncodedBody = '';
      Map < String, Object > jsonobj = SYS_Helper.getFlatKeys(jsonBody, SYS_DataCacheFactory.FLAT_KEY_PATTERN); //(Map<String,Object>)JSON.deserializeUntyped(flatJSON);
      List < String > reqkeymap = new List < String > (jsonobj.keySet());
      List < String > keyValueList = new List < String > ();
      reqkeymap.sort();

      for (String key: reqkeymap) {
        if (!String.isBlank(key) /*&& jsonobj.get(key) != '' && (jsonobj.get(key)) instanceOf String*/ ) {

          keyValueList.add(key.toLowerCase() + '=' + EncodingUtil.urlEncode(String.valueOf(jsonobj.get(key) != NULL ? jsonobj.get(key) : ''), 'UTF-8'));
        }
      }
      formUrlEncodedBody = String.join(keyValueList, '&');
      log.data1__c = formUrlEncodedBody;

      jsonBody = formUrlEncodedBody;
    } else if (req.getHeader('content-type') == 'multipart/form-data') {
      //TODO form-data with boundary calculation
    } else {
      //TODO throw exception invalid header or just log
      Map < String, Object > newflatKeyMap = new Map < String, Object > ();
      JSONParser parser = JSON.createParser(jsonBody);
      List < String > values = new List < String > ();
      while (parser.nextToken() != null) {
        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
          values = new List < String > ();
        } else if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
          values.add(parser.getText());
        } else if (parser.getCurrentToken() == JSONToken.END_ARRAY) {
          break;
        }
      }
      system.debug(values);
      //preprocessJson
      String finalJSON = jsonBody.replace('\n', ' ');
      Object convert = System.JSON.deserializeUntyped(finalJSON);
      Object  convertnew = System.JSON.deserializeUntyped('{}');
      newflatKeyMap = (SYS_Helper.getFlatKeys(finalJSON, 'A.B'));
      //string metakey = (String)((Map < String, Object > ) convert).get('metadatakey');
      ((Map < String, Object > ) convertnew).put('majorDimension', 'ROWS' );
      ((Map < String, Object > ) convertnew).put('values', (new List < list < string >> {
          values}));
     // ((Map < String, Object > ) convertnew).put('values', values );
      string midformJSON = JSON.serialize(convertnew);
        system.debug('midformJSONNDR' + midformJSON);
        jsonBody = midformJSON.replace('\\', ' ');
        system.debug('jsonBodyNDR' + jsonBody);
        log.data0__c = jsonBody;
    }
    return jsonBody;
  }
}