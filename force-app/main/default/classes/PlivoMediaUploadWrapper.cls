public with sharing class PlivoMediaUploadWrapper{
    public String api_id;	//befc2dda-d622-11ec-92ce-0242ac110003
    public cls_objects[] objects;
    public class cls_objects {
        public String content_type;	//image/png
        public String file_name;	//kindpng_4521500.png
        public String media_id;	//5aa6ece8-3191-4197-9c67-2da00bc4bb84
        public String media_url;	//https://media.plivo.com/Account/MAZJM3ZDZLNWRKZWJJYW/Media/5aa6ece8-3191-4197-9c67-2da00bc4bb84
        public Integer size;	//304010
        public String status;	//success
        public Integer status_code;	//201
        public String upload_time;	//2022-05-17T20:48:46.567842703Z
        public String error_message;    //content type is unsupported
        public Integer error_code;	//130
    }

    public static PlivoMediaUploadWrapper parse(String json) {
		return (PlivoMediaUploadWrapper) System.JSON.deserialize(json, PlivoMediaUploadWrapper.class);
	}

    public static List<String> parseMediaUrls(String json){
        List<String> mediaUrls = new List<String>();
        PlivoMediaUploadWrapper objjson = (PlivoMediaUploadWrapper) System.JSON.deserialize(json, PlivoMediaUploadWrapper.class);
        List<PlivoMediaUploadWrapper.cls_objects> objList = objjson.objects;
        for(PlivoMediaUploadWrapper.cls_objects line:objList){
            if(line.status == 'success'){
                mediaUrls.add(line.media_url);
            }            
        }
        return mediaUrls;
    }

    public static List<String> parseErrorMessages(String json){
        List<String> errorMessages = new List<String>();
        PlivoMediaUploadWrapper objjson = (PlivoMediaUploadWrapper) System.JSON.deserialize(json, PlivoMediaUploadWrapper.class);
        List<PlivoMediaUploadWrapper.cls_objects> objList = objjson.objects;
        for(PlivoMediaUploadWrapper.cls_objects line:objList){
            if(line.status == 'failed'){
                errorMessages.add(line.error_message);
            }            
        }
        return errorMessages;
    }
}