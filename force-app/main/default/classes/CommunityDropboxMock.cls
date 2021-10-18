@isTest
public class CommunityDropboxMock implements HttpCalloutMock {    
    public HTTPResponse respond(HTTPRequest request)
    {   
        String tempBody;
        HTTPResponse res = new HTTPResponse();      
        if(request.getEndpoint()=='https://api.dropbox.com/1/oauth2/token?grant_type=authorization_code&code=123&redirect_uri=http/briskminds.com'){      
            tempBody = '{"access_token":"sumit"}';
            res = CommunityDropboxMock.httpHit(tempBody); 
        }  
        else if(request.getEndpoint()=='https://api.dropboxapi.com/2/files/list_folder'){
            System.debug('Mock temp');
             tempBody = '{".tag":"fol"}';
            res = CommunityDropboxMock.httpHit(tempBody);
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