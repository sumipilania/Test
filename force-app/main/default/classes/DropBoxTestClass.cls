@isTest
public class DropBoxTestClass {
    @isTest static void testGet(){
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new DropBoxMockClass());
        
        DropBoxIntegrationController obj = new DropBoxIntegrationController();
        obj.dropAuth();
        obj.AccessToken();
        obj.filesInFolder();
        obj.uploadFileName = 'File1';
        obj.uploadFileContent = Blob.valueOf('FileContent');
        obj.uploadFiles();
        obj.downloadFile();
        obj.breadCrumbMethod();
        
        Test.stopTest();
    }
    
}