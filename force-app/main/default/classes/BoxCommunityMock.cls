@isTest
public class BoxCommunityMock implements HttpCalloutMock {    
    public HTTPResponse respond(HTTPRequest request)
    {   
        String tempBody;
        HTTPResponse res = new HTTPResponse();      
       if(request.getEndpoint()=='https://app.box.com/api/oauth2/token?'){
            System.debug('Mock temp');
             tempBody = '{"token_type":"Bearer","access_token":"Sumit","refresh_token":"ref_token","expires_in":-3600}';
            res = BoxCommunityMock.httpHit(tempBody);
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