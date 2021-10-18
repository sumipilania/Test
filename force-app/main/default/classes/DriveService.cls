public class DriveService {
    public static String authtication_drive(String client_key, String redirect_uri)  {
        String key = EncodingUtil.urlEncode(client_key,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        String authuri = '';
        authuri = 'https://accounts.google.com/o/oauth2/auth?'+
                'client_id='+key+
                '&response_type=code'+
                '&scope=https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive'+
                '&redirect_uri='+uri+
                '&state=security_token%3D138r5719ru3e1%26url%3Dhttps://oa2cb.example.com/myHome&'+
                '&login_hint=jsmith@example.com&'+
                'access_type=offline';
       
        return authuri;    
    }
    
     public static String genericHttp(String endPoint, String method, Blob body, String strBody, Map<String,String> headerMap){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(method);
        req.setTimeout(60*1000);
        for(String sKey : headerMap.keyset()){
            req.setHeader(sKey,headerMap.get(sKey));
        }
        if(!(strBody=='' || strBody==null)){
            req.setBody(strBody);
        }
        if(!(body==null)){
             req.setBodyAsBlob(body);
        }
      
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();
            
    }
    
}