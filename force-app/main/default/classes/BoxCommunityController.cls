/*
Created By         :    Sumit Pilaniya
Date               :    30/09/2019
Description        :    Box Integration Create Folder, Download File, Upload Files, Show all Files And Folder, Breadcrumb Sequence Maintain  
*/


public class BoxCommunityController {
    
    public static  String redirect_uri = 'https://sumitbriskmindcommunit-developer-edition.ap15.force.com/sumitbriskminds/s/?tabset-187cb=59ac8';
    
    //Get Client Id or secret Id
    public static List<DropBox_Integration_Key__mdt> keysQuery()
    {
        List<DropBox_Integration_Key__mdt> customList =[SELECT Client_Key__c, Secret_Key__c FROM DropBox_Integration_Key__mdt Where DeveloperName = 'Box_key' limit 1]; //Fetch client and screat id from Custom Metadat
        return customList;
    }
    
    //Access token, Ref token Fetch
    public static List<Integration__c> integrationInfo(){
        User us = [Select ContactId from User where Id=:userinfo.getuserId()];
        List<Integration__c> ob = [SELECT AccessToken__c, Contact_Name__c, Record_type__c, Refersh_token__c, DateTime__c From Integration__c WHERE Contact_Name__c =:us.ContactId AND Record_type__c = 'Box'];       
        return ob;
    } 
    
    //Get code value from URL
    @AuraEnabled
    public static String boxAuth()
    {
        List<DropBox_Integration_Key__mdt> customList = BoxCommunityController.keysQuery();
        String client_key = customList[0].Client_Key__c;  //Client Id 
        String clientsecret = customList[0].Secret_Key__c; //Secret Id 
        List<Integration__c> integration = BoxCommunityController.integrationInfo();
        String resp ='';
        
        if(integration.size() == 0){
            resp = BoxCommunityService.authtication_box(client_key, redirect_uri, clientsecret);
        }
        else{
            String accesstoken = integration[0].AccessToken__c;
            String refToken = integration[0].Refersh_token__c;
            DateTime expireTime = integration[0].DateTime__c; 

            if(System.now()>expireTime){
                String refResp = BoxCommunityController.refershTokenCheck(refToken);
                Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(refResp); //Fetch Access Token
                String tokenType = (String) meta.get('token_type');
                try{
                    //When Refersh token expire
                    if(tokenType.equalsIgnoreCase('Bearer'))
                    {
                        String newaccesstoken = (String) meta.get('access_token'); //Store Access Token 
                        String newRefToken = (String) meta.get('refresh_token');
                        Integer newexpireTime = (Integer) meta.get('expires_in');
                        DateTime expire = System.now().addSeconds(newexpireTime);  
                        List<Integration__c> tempIntegration = BoxCommunityController.integrationInfo();
                        tempIntegration[0].AccessToken__c = newaccesstoken;
                        tempIntegration[0].Refersh_token__c = newRefToken;
                        tempIntegration[0].DateTime__c = expire;
                        upsert tempIntegration;
                        resp = 'validRefToken';
                    }
                    else{
                        resp = BoxCommunityService.authtication_box(client_key, redirect_uri, clientsecret);
                    }  
                }
                catch(Exception e){
                    resp = BoxCommunityService.authtication_box(client_key, redirect_uri, clientsecret);
                }
            }
            else{
                resp = 'validToken';
            }
        }
        return resp;
    }
    
    //Get access token from refersh token
    public static String refershTokenCheck(String refToken)
    {       
        List<DropBox_Integration_Key__mdt> customList = BoxCommunityController.keysQuery();
        String client_key = customList[0].Client_Key__c;  //Client Id 
        String clientsecret = customList[0].Secret_Key__c; //Secret Id                 
        Map<String,String> httpHeader = new  Map<String,String>();  //Store HttpRequest Header
        String endpoint ='https://app.box.com/api/oauth2/token?'; //HttpRequest Endpoint       
        String method = 'POST'; //HttpRequest Method 
        Blob body;
        httpHeader.put('Content-Type','application/x-www-form-urlencoded');
        httpHeader.put('Accept','application/json');                
        String strBody = 'grant_type=refresh_token'+
            '&refresh_token='+refToken+
            '&client_id='+client_key+
            '&client_secret='+clientsecret;                
        String resp = BoxCommunityService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;
    }
    
    //get Access token
    @AuraEnabled
    public static String AccessToken(String codeVal)
    {  
        List<DropBox_Integration_Key__mdt> customList = BoxCommunityController.keysQuery();
        String client_key = customList[0].Client_Key__c;  //Client Id 
        String clientsecret = customList[0].Secret_Key__c; //Secret Id        
        Map<String,String> httpHeader = new  Map<String,String>();  //Store HttpRequest Header
        String endpoint ='https://app.box.com/api/oauth2/token?'; //HttpRequest Endpoint        
        String method = 'POST'; //HttpRequest Method 
        Blob body;
        httpHeader.put('Content-Type','application/x-www-form-urlencoded');
        httpHeader.put('Accept','application/json');        
        String strBody = 'grant_type=authorization_code'+
            '&code='+codeVal+
            '&client_id='+client_key+
            '&client_secret='+clientsecret;       
        String resp = BoxCommunityService.genericHttp(endpoint, method, body, strBody, httpHeader);
        Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(resp); //Fetch Access Token
        String accesstoken = (String) meta.get('access_token'); //Store Access Token 
        Integer expireTime = (Integer) meta.get('expires_in');
        String newRefToken = (String) meta.get('refresh_token');
        DateTime expire = System.now().addSeconds(expireTime);
        
        List<Integration__c> integration = BoxCommunityController.integrationInfo();
        if(integration.size() > 0){
            integration[0].AccessToken__c = accesstoken;
            integration[0].Refersh_token__c = newRefToken;
            integration[0].DateTime__c = expire;
            upsert integration;
        }
        else{
            User us = [Select ContactId from User where Id=:userinfo.getuserId()];     
            upsert new Integration__c(Contact_Name__c = us.ContactId, AccessToken__c = accesstoken,	Refersh_token__c = newRefToken, DateTime__c = expire, Record_type__c = 'Box'); 
        }
        return 'accesstoken';
    }
    
    //Get All File and Folder List
    @AuraEnabled
    public static String allFilesFolder(String folderId)
    {
        System.debug('allFilesFolder');
        List<Integration__c> integration = BoxCommunityController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;
        System.debug('accesstoken==='+accesstoken);
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.box.com/2.0/folders/'+folderId;
        String method = 'GET';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        Blob body=null;
        String strBody ='';
        String resp = BoxCommunityService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;
    }
    
    //Delete File and Folder
    @AuraEnabled
    public static String deleteFileFolder(String folderId, String fileFolderType)
    {
        List<Integration__c> integration = BoxCommunityController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;
        String endpoint ='';    
        Map<String,String> httpHeader = new  Map<String,String>();
        if(fileFolderType.equalsIgnoreCase('folder')) {
            endpoint = 'https://api.box.com/2.0/folders/'+folderId+'?recursive=true';
        }
        else{
            endpoint = 'https://api.box.com/2.0/files/'+folderId;
        }
        String method = 'DELETE';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        Blob body=null;
        String strBody ='';
        String resp = BoxCommunityService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;
    }
    
    //Download File From Url
    @AuraEnabled
    public static String downloadFile(String fileId)
    { 
        List<Integration__c> integration = BoxCommunityController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;  
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.box.com/2.0/files/'+fileId+'/content';
        String method = 'GET';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type','application/json');
        httpHeader.put('Accept','application/json');
        Blob body=null;
        String strBody ='';
        String resp = BoxCommunityService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;
    }  
    
    //Create Folder use Parent Id
    @AuraEnabled       
    public static String createFolder(String parentId, String folderName)
    {    
        List<Integration__c> integration = BoxCommunityController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;      
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.box.com/2.0/folders';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');       
        Blob body=null;
        String strBody ='{"name": "'+folderName+'","parent": { "id": "'+parentId+'" }}';
        String resp = BoxCommunityService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;
    }  
    
    //upload File
    @AuraEnabled
    public static String uploadFiles(String parentId, String uploadFileContent, String uploadFileName, String fileSize)
    {     
        List<Integration__c> integration = BoxCommunityController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;
        Blob bodyOfFile= EncodingUtil.base64Decode(uploadFileContent);
        blob base64EncodeFile=base64EncodeFileContent(bodyOfFile,uploadFileName);
        String boundary = '----------------------------741e90d31eff';
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://upload.box.com/api/2.0/files/content?parent_id='+parentId;
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer ' + accessToken);
        httpHeader.put('Content-Type','multipart/form-data; boundary='+boundary);
        httpHeader.put('Content-Length',String.valueof(fileSize));
        Blob body=base64EncodeFile;
        String strBody = '';
        String resp = BoxCommunityService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;      
    }
    
    //convert file body base64
    public static blob base64EncodeFileContent(Blob file_body, String file_name){
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('=')){
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
        return bodyBlob;
    }
}