public class RestServiceCallout {
    public static String renewAccessTokenFromRefToken(String endPoint, String clientKey, String secretKey, String refreshToken){
        System.debug('before endPoint='+endPoint);
        endPoint = endPoint+'/services/oauth2/token?grant_type=refresh_token&client_id='+clientKey+'&client_secret='+secretKey+'&refresh_token='+refreshToken;
        System.debug('aftr endPoint='+endPoint);
        Blob blobBody;
        String response = RestServiceCallout.restCallout(endPoint, 'POST', blobBody, null, new  Map<String,String>());
        return response;
    }
    
    public static String restCallout(String endPoint, String method, Blob body, String strBody, Map<String,String> headerMap){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(method);
        req.setTimeout(60*1000);
        System.debug('headerMap size==');
        System.debug('headerMap size=='+headerMap.size());
        if(headerMap.size() > 0){
            for(String sKey : headerMap.keyset()){
                req.setHeader(sKey,headerMap.get(sKey));
            }
        }
    
        if(String.isNotBlank(strBody)){
            req.setBody(strBody);
        }
        
      
        if(!(body==null)){
            req.setBodyAsBlob(body);
        }
        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('res.getStatusCode()=='+res.getStatusCode());
        String response;
        if(res.getStatusCode()==200){
            System.debug('res1='+res);
            System.debug('res1='+res);
            response = res.getBody();
        }
        else if(res.getStatusCode()==401){
            response = null;
        }
       System.debug('res.getBody()='+res.getBody());
        return response;
    }
}