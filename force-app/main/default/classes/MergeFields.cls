public with sharing class MergeFields {
    
    public static String parseBody(Id recordId, String content) {
        Set<String> allApis = new Set<String>();
        String objectAPI = '';
    
        objectAPI = getObjectAPI(recordId);
        allApis.addAll(getFields(content, objectAPI));
        
        System.debug('allApis ' + allApis);
        String objectFields = '';
        for(String field : allApis)
        {
            objectFields += field + ', ';
        }
        if(objectFields != '')
        {
            objectFields = objectFields.substring(0, objectFields.length() - 2);
            String queryStr = 'select ' + objectFields + ' from ' + objectAPI + ' where Id = :recordId';
            System.debug('queryStr ' + queryStr);
            Map<String, String> tempMap = new Map<String, String>();
            for(sObject obj : Database.query(queryStr))
            {
                System.debug('obj allApis Database.query ' + obj);
                for(String field : allApis)
                {
                    System.debug('obj allApis Database.query ' + obj);
                    if(field == 'Owner.Name'){
                        tempMap.put('OwnerFullName', String.valueOf(getFieldValue(obj, field)));
                    }else{
                        tempMap.put(field, String.valueOf(getFieldValue(obj, field)));
                    }
                    
                }
				System.debug('tempMap ' + tempMap);
                content = match(content, tempMap, objectAPI);
            }
            System.debug(content);
            return content;
        }
        return content;
    }
    

    public static Map<Id, String> parse(Set<Id> ids, String content)
    {
        Set<String> allApis = new Set<String>();
        String objectAPI = '';
        for(Id objId : ids)
        {
            objectAPI = getObjectAPI(objId);
            allApis.addAll(getFields(content, objectAPI));
            break;
        }
        System.debug('allApis ' + allApis);
        String objectFields = '';
        for(String field : allApis)
        {
            objectFields += field + ', ';
        }
        if(objectFields != '')
        {
            Map<Id, String> objectIdToNewContent = new Map<Id, String>();
            objectFields = objectFields.substring(0, objectFields.length() - 2);
            String queryStr = 'select ' + objectFields + ' from ' + objectAPI + ' where Id in :ids';
            System.debug('queryStr ' + queryStr);
            Map<String, String> tempMap = new Map<String, String>();
            for(sObject obj : Database.query(queryStr))
            {
                System.debug('obj allApis Database.query ' + obj);
                for(String field : allApis)
                {
                    System.debug('obj allApis Database.query ' + obj);
                    if(field == 'Owner.Name'){
                        tempMap.put('OwnerFullName', String.valueOf(getFieldValue(obj, field)));
                    }else{
                        tempMap.put(field, String.valueOf(getFieldValue(obj, field)));
                    }
                    
                }
				System.debug('tempMap ' + tempMap);
                objectIdToNewContent.put(obj.Id, match(content, tempMap, objectAPI));
            }
            System.debug(objectIdToNewContent);
            return objectIdToNewContent;
        }
        
        Map<Id, String> objectIdToContent = new Map<Id, String>();
        for(Id objId : ids)
        {
            objectIdToContent.put(objId, content);
        }
        return objectIdToContent;
    }

    public static Object getFieldValue(SObject entity, String fieldName)
    {
        if(entity == null || fieldName == 'OwnerFullName')
        {
            return null;
        }

        if(fieldName.contains('.'))
        {
            return getFieldValue(entity.getSObject(fieldName.substringBefore('.')), fieldName.substringAfter('.'));
        }
        else
        {
            return entity.get(fieldName);
        }
    }

    private static Set<String> getFields(String content, String objectAPI)
    {
        Set<String> fieldApis = new Set<String>();
        Matcher m = Pattern.compile('(\\{!\\s*' + objectAPI + '\\.([A-Za-z\\._0-9]+)\\s*\\})').matcher(content);
        Set<String> matchFields = new Set<String>();
        while(m.find())
        {
            String merge_field = m.group(2);
            if(merge_field == 'OwnerFullName'){
                merge_field = 'Owner.Name';
            }
            fieldApis.add(merge_field);
        }

        return fieldApis;
    }

    private static String match(String content, Map<String, String> obj, String objectAPI)
    {
        Matcher m = Pattern.compile('(\\{!\\s*' + objectAPI + '\\.([A-Za-z\\._0-9]+)\\s*\\})').matcher(content);
        Set<String> matchFields = new Set<String>();
        while(m.find())
        {
            String merge_field = (String)m.group(0);
            String field = (String)m.group(2);

            String value;
            try
            {
                value = (String)obj.get(field);
            }
            catch(Exception e)
            {
                value = '';
            }
            if(value != null)
            {
                content = content.replace(merge_field, value);
            }
            else
            {
                content = content.replace(merge_field, '');
            }
        }

        return content;
    }

    private static String getObjectAPI(String recordId)
    {
        String keyCode  = recordId.subString(0,3);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType objectInstance : gd.values())
        {
            if(objectInstance.getDescribe().getKeyPrefix() == keyCode)
            {
                return objectInstance.getDescribe().getName();
            }
        }
        return null;
    }
}