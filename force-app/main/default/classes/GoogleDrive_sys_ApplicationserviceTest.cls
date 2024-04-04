@isTest
public class GoogleDrive_sys_ApplicationserviceTest {
@isTest
    public static void gettingdetailsbyrecordidTest(){
         string jsonRecord ='{"parents": "1zPhNkNNthwpzS4vxdikW6IDkLAC8z-Ge","name": "001Dn00000Y4sh8IAB","kind": "drive#file","mimeType": "application/vnd.google-apps.folder","subparents":"45678"}';
            GoogleDrive_sys_Applicationservice googleapply = new GoogleDrive_sys_Applicationservice();
       string finaljson =  googleapply.sanitizeJSONForOutbound(jsonRecord);
        system.assert(finaljson!=null);
    }
    @isTest
    public static void gettingdetailsbyrecordidTestparentempty(){
         string jsonRecord ='{"name": "001Dn00000Y4sh8IAB","kind": "drive#file","mimeType": "application/vnd.google-apps.folder","subparents":"45678"}';
        GoogleDrive_sys_Applicationservice googleapply = new GoogleDrive_sys_Applicationservice();
       string finaljson =  googleapply.sanitizeJSONForOutbound(jsonRecord);
        system.assert(finaljson!=null);
    }
}