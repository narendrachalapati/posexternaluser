@isTest
public class GDrive_MokServer {
    
    Map<String, HttpResponse> router;

    public static MultiStaticResourceCalloutMock startServer(){
        MultiStaticResourceCalloutMock multimockServer = new MultiStaticResourceCalloutMock();
        multimockServer.setStaticResource('https://www.googleapis.com/upload/drive/v2/files?uploadType=multipart', 'GDriveFileResp'); 
        multimockServer.setStaticResource('https://www.googleapis.com/drive/v3/files', 'GDriveFolderResp');
        multimockServer.setStaticResource('https://www.googleapis.com/drive/v3/files/1BtmgK5-2TAnDwBRJRf9_2FxAtCU34bEw/permissions', 'GDrivePermissionResp');
        multimockServer.setStaticResource('https://www.googleapis.com/upload/drive/v2/files/1xOmAgjp8oPWFK-11H6R8SNfNYHN2kCpH', 'GDriveFileEditResp');
        multimockServer.setStaticResource('https://sheets.googleapis.com/v4/spreadsheets', 'SpreadsheetResp');
        multimockServer.setStaticResource('https://sheets.googleapis.com/v4/spreadsheets/empty', 'SpreadsheetEmptyresp');
        
        multimockServer.setStatusCode(200);
        multimockServer.setHeader('Content-Type', 'application/json');
        return multimockServer;
    }
  public static MultiStaticResourceCalloutMock stopServer(){
        MultiStaticResourceCalloutMock multimockServer = new MultiStaticResourceCalloutMock();
        multimockServer.setStaticResource('https://sheets.googleapis.com/v4/spreadsheets', 'SpreadsheetResp');
        multimockServer.setStatusCode(400);
        multimockServer.setHeader('Content-Type', 'application/json');
        return multimockServer;
    }

}