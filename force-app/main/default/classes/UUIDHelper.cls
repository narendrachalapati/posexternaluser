public with sharing class UUIDHelper {
    public UUIDHelper() {

    }

    public static String getObjectApiName(Id recordId) {
        return recordId.getSObjectType().getDescribe().getName();
    }

    public static String getAllFieldsFor(String objName){
        return (String.join(getAllFields(objName),', '));
    }

    public static String getAllParentFields(String prefix, String objName) {
        List<String> fields = getAllFields(objName);
        for(Integer i=0; i<fields.size(); i++) {
            fields[i] = prefix + fields[i];
        }

        return (String.join(fields,', '));
    }

    public static List<String> getAllFields(String objName) {
        objName = namespacePrefix + objName;

        List<String> fields = new List<String>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            Schema.DescribefieldResult field = sfield.getDescribe();
            // if(field.isAccessible())
                fields.add(field.getname()?.toLowerCase());
        }
        return fields;
    }

    public static String getUUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }

    private static String namespace;
    public static String namespacePrefix {
        get {
            if(namespace == null) {
                String[] parts = String.valueOf(LookupController.class).split('\\.', 2);
                namespace = parts.size() == 2 ? parts[0] : '';
            }
            return namespace != NULL ? namespace : ''; 
        }
    }
}