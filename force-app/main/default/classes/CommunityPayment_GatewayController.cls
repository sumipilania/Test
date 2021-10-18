/*
Created By         :    Sumit Pilaniya
Date               :    24/10/2019
Description        :    Payment Gateway using Authorization.net credit card and echeck  
*/


public class CommunityPayment_GatewayController {
    
    //Method to pay using credit card
    @AuraEnabled
    public static List<Object> creditCard(String cardNumber, String expMonth, String expYear, String cvv){
        List<PaymentGateway__mdt> customList =[SELECT API__c, 	Transaction_Key__c FROM PaymentGateway__mdt Where DeveloperName = 'AuthPayment' limit 1]; //Fetch client and screat id from Custom Metadata
        String Api_Key = customList[0].API__c;  //API Key
        String Transaction_Key = customList[0].Transaction_Key__c; //Transaction Key
        String amount = '500';
        String expDate = expMonth + expYear;
        Map<String,String> httpHeader = new  Map<String,String>();        
        String endpoint = 'https://apitest.authorize.net/xml/v1/request.api';
        String method = 'POST';
        String body = CommunityPayment_GatewaySevice.bodyOfCreditCard(Api_Key,Transaction_Key,amount,cardNumber,expDate,cvv);
        httpHeader.put('content-type', 'application/json');
        httpHeader.put('Content-length', String.valueOf(body.length()));
        String resp = CommunityPayment_GatewaySevice.httpCallout(endpoint, method, body, httpHeader);
        List<Object> objList = new List<Object>();    
        Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(resp.substring(1,resp.length())) ;
        for(string keyStr : responseMap.keyset()){
            objList.add(responseMap.get(keyStr));
        }
        return objList;
    }    
    
    //Method to pay using eCheck
    @AuraEnabled
    public static List<Object> echeck(String routingNum, String accNo, String nameOnAcc){             
        List<PaymentGateway__mdt> customList =[SELECT API__c, 	Transaction_Key__c FROM PaymentGateway__mdt Where DeveloperName = 'AuthPayment' limit 1]; //Fetch API Key and Transaction Key from Custom Metadata
        String Api_Key = customList[0].API__c;  //API Key
        String Transaction_Key = customList[0].Transaction_Key__c; //Transaction Key
        String amount = '500';
        Map<String,String> httpHeader = new  Map<String,String>();        
        String endpoint = 'https://apitest.authorize.net/xml/v1/request.api';
        String method = 'POST';
        String body = CommunityPayment_GatewaySevice.bodyOfecheck(Api_Key,Transaction_Key,amount,routingNum, accNo, nameOnAcc);
        httpHeader.put('content-type', 'application/json');
        httpHeader.put('Content-length', String.valueOf(body.length()));
        String resp = CommunityPayment_GatewaySevice.httpCallout(endpoint, method, body, httpHeader);        
        List<Object> objList = new List<Object>();              
        Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(resp.substring(1,resp.length())) ;
        for(string keyStr : responseMap.keyset()){
            objList.add(responseMap.get(keyStr));
        }
        return objList;
    }    
}