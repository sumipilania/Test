@isTest(SeeAllData=true)
public class DriveCommunityTest {
    @isTest
    static void drive_test(){                 
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new DriveCommunityMock());       
        String file = DriveCommunityController.allFilesFolder('1');
        String delfile = DriveCommunityController.deleteFileFolder('1');
        String downfile = DriveCommunityController.downloadFile('2');
        String create = DriveCommunityController.createFolder('2', 'Test');
        String upload = DriveCommunityController.uploadFiles('root', 'body', 'temp.pdf', '12365', 'pdf');
        String accToken = DriveCommunityController.AccessToken('123');  
        Test.stopTest();        
    }    
    @isTest
    static void drive_test_other(){ 
        
        DriveCredentials__c settings = new DriveCredentials__c();
        settings.AccessToken__c = 'accessToekn';
        settings.expires_in__c= System.now().addseconds(-360);
        settings.Redirect_url__c = 'http/briskminds.com';
        settings.Refersh_token__c = 'ref_token';
        insert settings;
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new DriveCommunityMock()); 
        String auth =  DriveCommunityController.driveAuth();               
        Test.stopTest();        
    }    
}