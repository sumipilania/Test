@isTest
class InboundEmailTestClass 
{
   @isTest static void inbound_test()
   {
       Test.startTest();
       Messaging.InboundEmail email  = new Messaging.InboundEmail();
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       env.fromAddress = 'sumitpilania123@gmail.com';
       env.toAddress = 'inboundemailservices@j-nuzlpjnbgg4mi3d9u36t5hef2jgjf3tini1waxsk2cmeeg1jl.2v-13d7leae.ap15.apex.salesforce.com';
       email.plainTextBody = 'Contact#LastName#ABC##Account#Name#Acc1##Contact#LastName#XYZ';
       InboundEmailController obj =new InboundEmailController();
       Messaging.InboundEmailResult result = obj.handleInboundEmail(email,env); 
       System.assertEquals(true, result.success);
       Test.stopTest();
   }
}