@RestResource(urlMapping='/MyPersonal1Account/*')
global with sharing class RestResorceClass {

    @HttpDelete
    global static void doDelete() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Account account = [SELECT Id FROM Account WHERE Id = :accountId];
        delete account;
    }
  
    @HttpGet
    global static Account doGe() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Account result = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :accountId];
        System.debug('result=='+result);
        return result;
    }
  
  @HttpPost
    global static String doPost(String name) {
        Account account = new Account();
        account.Name = name;
        insert account;
        return account.Id;
    }
    @HttpPut
    global static String doPut(String accId,String phone) {
        System.debug('accId=='+accId);
        System.debug('phone=='+phone);
        Account result = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :accId];
        result.Phone = phone;
        update result;
        return result.Id;
    }
}