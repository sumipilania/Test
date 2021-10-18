//RestResorcesClass used for rest resource

public class RestResourceTesting {
    public static String globalEndPoint = 'https://sumit-pilaniya-light9domain-dev-ed.my.salesforce.com/services/apexrest/';
    public static String sessionId = Page.SessionId.getContent().toString();
    
    public static String getRecords(String endPoint){
        Map<String,String> headerMap = new Map<String,String>();  //RestResourceTesting.getRecords('MyPersonal1Account/0012v00002L8zRu')
        headerMap.put('Content-Type', 'application/json');
        headerMap.put('Authorization','Bearer ' + sessionId);
        String resp = RestResourceTesting.genericHttp(globalEndPoint+endPoint,'GET',null,null,headerMap);
        System.debug('resp==='+resp);
        return resp;
    }
    public static String putRecords(String endPoint,String body){
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Content-Type', 'application/json');		//RestResourceTesting.putRecords('MyPersonal1Account/','{"name":"Generic"}') Note:- name variable same as post request insert record name
        headerMap.put('Authorization','Bearer ' + sessionId);  
        String resp = RestResourceTesting.genericHttp(globalEndPoint+endPoint,'POST',body,null,headerMap);
        System.debug('resp==='+resp);
        return resp;
    }
    public static String dltRecord(String endPoint){
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Content-Type', 'application/json');		 //RestResourceTesting.dltRecord('MyPersonal1Account/0012v00002narf3')
        headerMap.put('Authorization','Bearer ' + sessionId);  
        String resp = RestResourceTesting.genericHttp(globalEndPoint+endPoint,'DELETE',null,null,headerMap);
        System.debug('resp==='+resp);
        return resp;
    }
    public static String genericHttp(String endPoint, String method,String strBody, Blob body, Map<String,String> headerMap)
    {
        System.debug('');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(method);
        req.setTimeout(60*1000);
        for(String sKey : headerMap.keyset()){
            req.setHeader(sKey,headerMap.get(sKey));
        }
        System.debug('Step 111111111111');
        if(String.isNotEmpty(strBody)){
            System.debug('Step 2');
            req.setBody(strBody);  
        }else if(body!=null){
            System.debug('Step 3');
            req.setBodyAsBlob(body);
        }
        System.debug('Step 4');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();
    }
    
}