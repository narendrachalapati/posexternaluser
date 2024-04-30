public with sharing class QB_InboundApplicationService   extends SYS_ApplicationService{
    public QB_InboundApplicationService() {

    }
    public override  List<sObject> transformJsonToSObject(String jsonBody,String resource,SYS_IntegrationLog__c log) {
        Object responseType = JSON.deserializeUntyped(jsonBody);
       
        Object JSONwithoutrootkey;
        if(SYS_DataCache.log.Parent__c==Null){
        if(responseType instanceof Map<String,Object>){
            JSONwithoutrootkey = (((Map<String, Object>)responseType).values())[0];
           
            //((Map<String, Object>)responseType).get(JSONForUpsert);
            jsonBody = JSON.serialize(JSONwithoutrootkey);
             
        }

    }
  
  
     
      List<sObject> sobjlist=  SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource,(log.Type__c=='INBOUND'));
     
     
      
        return sobjlist;
    
    }
    
}