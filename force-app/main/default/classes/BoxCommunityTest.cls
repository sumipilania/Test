@isTest
class BoxCommunityTest {
  
    @isTest
    static void dropbox_test(){                 
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new BoxCommunityMock()); 
        String file = BoxCommunityController.allFilesFolder('1');
        String delfile = BoxCommunityController.deleteFileFolder('1', 'hy');
        String downfile = BoxCommunityController.downloadFile('2');
        String create = BoxCommunityController.createFolder('2', 'Test');
        String upload = BoxCommunityController.uploadFiles('root', 'body', 'temp', '1254');
        String accToken = BoxCommunityController.AccessToken('123');        
        Test.stopTest();        
    }    
    @isTest
    static void dropbox_test_drop(){  
        BoxCredentials__c settings = new BoxCredentials__c();
        settings.AccessToken__c = 'accessToekn';
        settings.expires_in__c= System.now().addseconds(-360);
        settings.Redirect_url__c = 'http/briskminds.com';
        settings.Refersh_token__c = 'ref_token';
        insert settings;
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new BoxCommunityMock());         
        String auth =  BoxCommunityController.boxAuth();       
        Test.stopTest();        
    }    
}