@isTest
class CommunityDropboxTestClass {
    @testSetup static void methodName() {
        Test.startTest();
        DropboxCredentials__c settings = new DropboxCredentials__c();
        settings.AccessToken__c = 'accessToekn';
        settings.RedirectUrl__c = 'http/briskminds.com';
        insert settings;
        Test.stopTest();
    }
    @isTest
    static void dropbox_test(){ 
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new CommunityDropboxMock());  
        String resDrop = CommunityDropBoxApexController.dropAuth();
        System.assertEquals('validToken', resDrop);
        String resFolder = CommunityDropBoxApexController.allFilesFolder();
        String file = CommunityDropBoxApexController.filesInFolder('1');
        String deletefile = CommunityDropBoxApexController.deleteFileFolders('/Home');       
        String downlodFile = CommunityDropBoxApexController.downloadFile('2');       
        String uploadFile = CommunityDropBoxApexController.uploadFiles('1', 'Hi All', 'temp.txt');      
        String createFile = CommunityDropBoxApexController.createFolder('Lib');
        String accToken = CommunityDropBoxApexController.AccessToken('123');                   
        Test.stopTest();        
    }    
}