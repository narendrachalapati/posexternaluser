public with sharing class GoogleDrive_sys_Applicationservice extends SYS_ApplicationService {

    public Override String sanitizeJSONForOutbound(String jsonRecord){
         //Deserilize JSON and Map Keys 
         Map<String, Object> newflatKeyMap = new Map<String, Object>();
        /* if(jsonRecord==null){
            jsonRecord = '{"kind":"drive#file","id":"1_Hozddl9sH4HhLWdGjznicZmd82mphWq","name":"a0vDn0000042RSSIA2","mimeType":"application/vnd.google-apps.folder"}';
      
         }*/
           String finalJSON = jsonRecord.replace('\n',' ');
         Object convert  = System.JSON.deserializeUntyped(finalJSON);
 
        // if(convert instanceof Map<String, Object>&& ( ((Map<String, Object>)convert).get('resourceType') == 'drive#file')) {
            String parentsid,subparentsid;
            newflatKeyMap = (SYS_Helper.getFlatKeys(finalJSON ,'A.B'));
            parentsid = (String)newflatKeyMap.get('parents');
            subparentsid = (String)newflatKeyMap.get('subparents');
            system.debug(parentsid);
            system.debug(subparentsid);
            system.debug('parentid'+String.isBlank(parentsid));
            if(string.isNotBlank(parentsid) ){
            list<string>Parentidlist = new list<String>();
           
            if(subparentsid != null)
                Parentidlist.add(subparentsid);
            else
                Parentidlist.add(parentsid);
            
            ((Map<String, Object>)convert).remove('parents');
            ((Map<String, Object>)convert).remove('subparents');
             if(Parentidlist.size()>0){

            ((Map<String, Object>)convert).put('parents', Parentidlist);
            }
            system.debug('convert'+ convert);
            string  midformJSON = JSON.serialize(convert);
            finalJSON = midformJSON.replace('\n',' ');
            system.debug('finalJSONNarendra'+finalJSON);
       //  }
            }else{
                ((Map<String, Object>)convert).remove('parents');   
               // ((Map<String, Object>)convert).put('test','Narendra'); 
                string  midformJSON = JSON.serialize(convert);
            finalJSON = midformJSON.replace('\n',' ');
            system.debug('finalJSONNarendra'+finalJSON);
            }

       
        return finalJSON;
    }
}