@isTest
public class CommunityPaymentMock implements HttpCalloutMock {    
    public HTTPResponse respond(HTTPRequest request)
    {   
        String tempBody;
        HTTPResponse res = new HTTPResponse();      
        if(request.getEndpoint()=='https://apitest.authorize.net/xml/v1/request.api'){
            System.debug('Mock temp 232323232');
           tempBody = '{"transactionResponse":{"responseCode":"1","authCode":"HH5414","avsResultCode":"Y","cvvResultCode":"S","cavvResultCode":"6","transId":"2149186848","refTransID":"","transHash":"FE3CE11E9F7670D3ECD606E455B7C222","accountNumber":"XXXX0015","accountType":"Mastercard","messages":[{"code":"1","description":"This transaction has been approved."}],"userFields":[{"name":"MerchantDefinedFieldName1","value":"MerchantDefinedFieldValue1"},{"name":"favorite_color","value":"blue"}]},"refId":"123456","messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}';
           //tempBody = '{"data": [{"s": "a", "i": 1}]}';
           //
         
            res = CommunityPaymentMock.httpHit(tempBody);
        }        
        return res;
    }   
    public static HTTPResponse httpHit(String body)
    {
        HTTPResponse response = new HTTPResponse();
        response.setBody(body);
        response.setStatusCode(200);
        return response;
    }   
}