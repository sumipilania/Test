public class CommunityPayment_GatewaySevice {
    
    public static String httpCallout(String endPoint, String method, String body, Map<String,String> headerMap){     
        HttpRequest req1 = new HttpRequest();
        req1.setMethod(method);
        req1.setEndpoint(endPoint);
        req1.setBody(body);
        for(String sKey : headerMap.keyset())
        {
            req1.setHeader(sKey,headerMap.get(sKey));
        }
        req1.setTimeout(60*1000);
        Http h1 = new Http();       
        HttpResponse httpRes = h1.send(req1);
        String resp = httpRes.getBody();
        return resp;
    }
    public static String bodyOfCreditCard(String APIkey, String transKey, String Amt, String cardNum, String expdate, String cvvCode){
        String body = '{"createTransactionRequest": {"merchantAuthentication": {"name": "'+APIkey+'","transactionKey": "'+transKey+'"},"refId": "123456","transactionRequest": {"transactionType": "authOnlyTransaction","amount": "'+Amt+'","payment": {"creditCard": {"cardNumber": "'+cardNum+'","expirationDate": "'+expdate+'","cardCode": "'+cvvCode+'"}}}}}';        
        return body;
    }
    public static String bodyOfecheck(String APIkey, String transKey, String Amt, String routingNum, String accNo, String nameOnAcc){
        String body = '{"createTransactionRequest": {"merchantAuthentication": {"name": "'+APIkey+'","transactionKey": "'+transKey+'"},"refId": "123456","transactionRequest": {"transactionType": "authOnlyTransaction","amount": "'+Amt+'","payment": {"bankAccount": {"routingNumber": "'+routingNum+'","accountNumber": "'+accNo+'","nameOnAccount": "'+nameOnAcc+'"}}}}}';                        
        return body;
    }
}