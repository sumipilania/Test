@isTest
class CommunityPaymentTest {
  
    @isTest
    static void dropbox_test(){                 
        Test.setMock(HTTPCalloutMock.class, new CommunityPaymentMock()); 
         //CommunityPayment_GatewayController.echeck('12345', '368541254', 'Test');
        CommunityPayment_GatewayController.creditCard('1234567896213', '09', '20', '123');
    }    
   
}