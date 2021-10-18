public class SalesforceToSalesforceIntegrationService {
    
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