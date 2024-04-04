@isTest
public class GoogleDrive_Datafactory {
   
    	public static void createTestAccount(){
       
           Account acc = new Account();
                  acc.Name='Test';
                  insert acc;
          }
    	public static void createTestAccountwithmetadata(){
       
           Account acc = new Account();
                  acc.Name='Test';
                  insert acc;
          }
    public static  Contact ContactCreation(){
         
          Contact con = new Contact();
            con.FirstName = 'fName';
            con.LastName = 'lName';
            con.UUID__c='cfb6460a-ff0a-c76a-ac48-671cef69c13456'  + Integer.valueof((Math.random() * 1000));
        insert con;
        return con;
            
    }
   
    public static  GoogleDriveFolder__c GoogledrivefolderCreation(string Contactid){
        
        GoogleDriveFolder__c googledrivefolder = new GoogleDriveFolder__c();
        
        googledrivefolder.Name = 'Municorn';
        googledrivefolder.Contact__c = Contactid;
        googledrivefolder.GoogleDrive_ID__c = '1v2-E6U0LaRezjBOfNYPC89R8-lDnWFAY';
        insert googledrivefolder;
        return googledrivefolder;
    }
  
    public static  GoogleDriveFile__c GoogledrivefileCreation(string patientid, string googlefolderid){
            GoogleDriveFile__c googledrive = new GoogleDriveFile__c();
        
        googledrive.Name = 'Test';
        googledrive.Preview_Link__c ='https://drive.google.com/uc?id=1v2-E6U0LaRezjBOfNYPC89R8-lDnWFAY&export';
        googledrive.Google_Drivefolder_id__c = googlefolderId;
        googledrive.GoogleDrive_ID__c ='1xOmAgjp8oPWFK-11H6R8SNfNYHN2kCpH';
        googledrive.ContentType__c = 'image/jpeg';
        googledrive.ThumbnailLink__c = 'https://lh3.googleusercontent.com/drive-storage/AKHj6E7hMj2OBXPYkEvh2Pl2kZA13kZnC6Hu4PKM1ojFO6tygzggIO95SZ8OhYOOz0TGpqFl8_89uMmuSBNRO8E3iMKFiZeczBzFcLdDazUTyQ=s220';
        googledrive.Contact__c =patientid;
        insert googledrive;
        return googledrive;
    }
    public static SYS_OAuthConfig__c createTestSysOauthWithAccessToken(){
        SYS_OAuthConfig__c oauthRecord = new SYS_OAuthConfig__c();
        oauthRecord.Name = 'GoogleDrive';
        oauthRecord.Client_Id__c = 'testPublicKey';
        oauthRecord.Access_Token__c = 'testAccessToken';
        oauthRecord.Test_Mode__c = true;
        oauthRecord.Grant_Type__c = 'authorization_code';
        oauthRecord.Integration_Type__c = 'Stripe';
        oauthRecord.Token_type__c = 'Bearer';
        oauthRecord.Config_ID__c = 'SYSOAUTH-' + Integer.valueof((Math.random() * 1000));
        insert oauthRecord;
        return oauthRecord;
    }
}