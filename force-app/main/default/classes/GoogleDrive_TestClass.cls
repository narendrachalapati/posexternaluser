@isTest
public class GoogleDrive_TestClass {
@isTest
    public static void gettingdetailsbyrecordidTest(){
          Contact con = GoogleDrive_Datafactory.ContactCreation();
        GoogleDriveFolder__c GDrivefolder = GoogleDrive_Datafactory.GoogledrivefolderCreation(con.Id);
         GoogleDriveFile__c googlefile = GoogleDrive_Datafactory.GoogledrivefileCreation(con.Id,GDrivefolder.Id);
        CustomfileuploaderController.gettingdetailsbyrecordid(con.Id,con.UUID__c);
         
    }
    
   @isTest
    public static void uploadFile_gTest(){ 
        Test.startTest();
          Account acc =  GsuiteTestDatafactory.createAccountwithmetadata();    
        SYS_OAuthConfig__c SYSconfigue = GsuiteTestDatafactory.createTestSysOauthWithAccessToken(acc.Id);
        Contact con = GsuiteTestDatafactory.createContactwithaccount(acc.Id);
        // GoogleDriveFolder__c GDrivefolder = GoogleDrive_Datafactory.GoogledrivefolderCreation(con.Id);
         Test.stopTest();
         Test.setMock(HttpCalloutMock.class, GDrive_MokServer.startServer());  
  
        GoogleDriveFile__c googlefile = CustomfileuploaderController.uploadFile_g(con.Id,'AccountId', 'Testuploadfile', '', 'image/png');
        system.assert(googlefile != null);
       }
       @isTest
    public static void EditFile_gTest(){ 
        Test.startTest();
             
        Account acc =  GsuiteTestDatafactory.createAccountwithmetadata();    
        SYS_OAuthConfig__c SYSconfigue = GsuiteTestDatafactory.createTestSysOauthWithAccessToken(acc.Id);
        Contact con = GsuiteTestDatafactory.createContactwithaccount(acc.Id);
      //  GsuiteTestDatafactory.GoogledrivefileCreation('','');
        GoogleDriveFolder__c GDrivefolder = GsuiteTestDatafactory.GoogledrivefolderCreation(con.Id);
        GoogleDriveFile__c googlefile = GsuiteTestDatafactory.GoogledrivefileCreation(con.Id,GDrivefolder.Id);
       // GoogleDriveFile__c googlefile = CustomfileuploaderController.EditFile_g(Gdrive.Id,'GoogledrivefileEdit','','');

         Test.stopTest();
         Test.setMock(HttpCalloutMock.class, GDrive_MokServer.startServer());  
  
      GoogleDriveFile__c googlefileres =  CustomfileuploaderController.EditFile_g(googlefile.Id, 'Test', '', 'image/jpeg');
        
       system.debug(googlefileres!=null);
}
       @isTest
    public static void creategooglefolderTest(){ 
        Test.startTest();
             
         Account acc =  GsuiteTestDatafactory.createAccountwithmetadata();    
        SYS_OAuthConfig__c SYSconfigue = GsuiteTestDatafactory.createTestSysOauthWithAccessToken(acc.Id);
        Contact con = GsuiteTestDatafactory.createContactwithaccount(acc.Id);
      //  GsuiteTestDatafactory.GoogledrivefileCreation('','');
        GoogleDriveFolder__c GDrivefolder = GsuiteTestDatafactory.GoogledrivefolderCreation(con.Id);
         Test.stopTest();
         Test.setMock(HttpCalloutMock.class, GDrive_MokServer.startServer());  
  
     string GooglefolderId =   CustomfileuploaderController.creategooglefolder(SYSconfigue.Access_Token__c, '', GDrivefolder.Id, '');
       system.assert(GooglefolderId != null); 
       
}
}