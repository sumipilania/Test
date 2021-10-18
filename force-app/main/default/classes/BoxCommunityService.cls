public with sharing class BoxCommunityService {
    public static String authtication_box(String client_key, String redirect_uri, String clientsecret)  {
      return 'https://account.box.com/api/oauth2/authorize?response_type=code&client_id='+client_key+'&redirect_uri='+redirect_uri+'&='+clientsecret;  
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
        System.debug('my res===='+res);
         String downloadUrl=res.getHeader('Location');
            if(downloadUrl==null || downloadUrl==''){
                return res.getBody();
            }
            else {
                return downloadUrl;
            }
        
    }
    
}