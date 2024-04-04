public with sharing class mediaUploadJSON{
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
    }
    public static List<String> parse(String json){
        // mediaUploadJSON objjson = mediaUploadJSON.parse(json);
        List<String> mediaUrls = new List<String>();
        mediaUploadJSON objjson = (mediaUploadJSON) System.JSON.deserialize(json, mediaUploadJSON.class);
        List<mediaUploadJSON.cls_objects> objList = objjson.objects;
        System.debug('mediaUploadJSON ' + objList);
        for(mediaUploadJSON.cls_objects  line:objList){
            System.debug('cls_object.media_url ' + line.media_url);
            mediaUrls.add(line.media_url );
        }

        return mediaUrls;
    }
}