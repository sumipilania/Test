/*
Created By         :    Sumit Pilaniya
Date               :    6/10/2019
Description        :    Drive Integration Create Folder, Download File, Upload Files, Show all Files And Folder, Breadcrumb Sequence Maintain  
*/

public class DriveCommunityController {
    
    public static  String redirect_uri = 'https://sumitbriskmindcommunit-developer-edition.ap15.force.com/sumitbriskminds/s/?tabset-187cb=9be65';
    
    //Get Client Id or secret Id
    public static List<DropBox_Integration_Key__mdt> keysQuery(){
        List<DropBox_Integration_Key__mdt> customList =[SELECT Client_Key__c, Secret_Key__c FROM DropBox_Integration_Key__mdt Where DeveloperName = 'DriveKey' limit 1]; //Fetch client and screat id from Custom Metadat
        return customList;
    }
    
    //Fetch all infor like accesstoken, ref token, expire time
    public static List<Integration__c> integrationInfo(){
        User us = [Select ContactId from User where Id=:userinfo.getuserId()];
        List<Integration__c> ob = [SELECT AccessToken__c, Contact_Name__c, Record_type__c, Refersh_token__c, DateTime__c From Integration__c WHERE Contact_Name__c =:us.ContactId AND Record_type__c = 'Drive'];       
        return ob;
    } 
    
    //Get code value from URL
    @AuraEnabled
    public static String driveAuth(){
        List<DropBox_Integration_Key__mdt> customList = DriveCommunityController.keysQuery();
        String client_key = customList[0].Client_Key__c;  //Client Id 
        String clientsecret = customList[0].Secret_Key__c; //Secret Id 
        List<Integration__c> integration = DriveCommunityController.integrationInfo();
        String resp ='';
        if(integration.size() == 0){
            resp = DriveService.authtication_drive(client_key, redirect_uri);
        }
        else{
            String accesstoken = integration[0].AccessToken__c;
            String refToken = integration[0].Refersh_token__c;
            DateTime expireTime = integration[0].DateTime__c;       
            if(System.now()>expireTime){
                String refResp = DriveCommunityController.refershTokenCheck(refToken);
                Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(refResp); //Fetch Access Token
                String tokenType = (String) meta.get('token_type');
                try{
                    //When Refersh token expire
                    if(tokenType.equalsIgnoreCase('Bearer')){
                        String newaccesstoken = (String) meta.get('access_token'); //Store Access Token 
                        Integer newexpireTime = (Integer) meta.get('expires_in');
                        DateTime expire = System.now().addSeconds(newexpireTime); 
                        List<Integration__c> tempIntegration = DriveCommunityController.integrationInfo();
                        tempIntegration[0].AccessToken__c = newaccesstoken;
                        tempIntegration[0].DateTime__c = expire;
                        upsert tempIntegration;
                        resp = 'validRefToken';
                    }
                }
                catch(Exception e){
                    resp = DriveService.authtication_drive(client_key, redirect_uri);
                }
            }
            else{
                resp = 'validToken';
            }
        }
        return resp;    
    }
    
    //Get access token from refersh token
    @AuraEnabled   
    public static String refershTokenCheck(String refToken){       
        List<DropBox_Integration_Key__mdt> customList = DriveCommunityController.keysQuery();
        String client_key = customList[0].Client_Key__c;  //Client Id 
        String clientsecret = customList[0].Secret_Key__c; //Secret Id    
        Map<String,String> httpHeader = new  Map<String,String>();  //Store HttpRequest Header
        String endpoint ='https://accounts.google.com/o/oauth2/token'; //HttpRequest Endpoint        
        String method = 'POST'; //HttpRequest Method 
        Blob body=null;
        httpHeader.put('Content-type', 'application/x-www-form-urlencoded');
        String strBody = 'refresh_token='+refToken+'&client_id='+client_key+'&client_secret='+clientsecret+'&redirect_uri='+redirect_uri+'&grant_type=refresh_token';   
        httpHeader.put('Content-length', String.valueOf(strBody.length()));
        String resp = DriveService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;
    }
    
    //get Access token
    @AuraEnabled
    public static String AccessToken(String codeVal)
    {  
        List<DropBox_Integration_Key__mdt> customList = DriveCommunityController.keysQuery();
        String client_key = customList[0].Client_Key__c;  //Client Id 
        String clientsecret = customList[0].Secret_Key__c; //Secret Id          
        Map<String,String> httpHeader = new  Map<String,String>();  //Store HttpRequest Header
        String endpoint ='https://accounts.google.com/o/oauth2/token'; //HttpRequest Endpoint        
        String method = 'POST'; //HttpRequest Method 
        Blob body=null;
        httpHeader.put('Content-type', 'application/x-www-form-urlencoded');
        String strBody = 'code='+codeVal+'&client_id='+client_key+'&client_secret='+clientsecret+'&redirect_uri='+redirect_uri+'&grant_type=authorization_code';   
        httpHeader.put('Content-length', String.valueOf(strBody.length()));
        String resp = DriveService.genericHttp(endpoint, method, body, strBody, httpHeader);
        Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(resp); //Fetch Access Token
        String accesstoken = (String) meta.get('access_token'); //Store Access Token 
        Integer expireTime = (Integer) meta.get('expires_in');
        String newRefToken = (String) meta.get('refresh_token');        
        DateTime expire = System.now().addSeconds(expireTime);  
        List<Integration__c> integration = DriveCommunityController.integrationInfo();
        if(integration.size() > 0){
            integration[0].AccessToken__c = accesstoken;
            integration[0].DateTime__c = expire;
            if(!(newRefToken==null || newRefToken=='')){
                integration[0].Refersh_token__c = newRefToken;
            }
            upsert integration;
        }
        else{
            User us = [Select ContactId from User where Id=:userinfo.getuserId()];     
            upsert new Integration__c(Contact_Name__c = us.ContactId, AccessToken__c = accesstoken,	Refersh_token__c = newRefToken, DateTime__c = expire, Record_type__c = 'Drive'); 
        }
        return 'accesstoken';
    }
    
    //Get All File and Folder List
    @AuraEnabled
    public static String allFilesFolder(String folderId)
    { 
        List<Integration__c> integration = DriveCommunityController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://www.googleapis.com/drive/v3/files?q=%27'+folderId+'%27%20in%20parents%20and%20trashed=false&orderBy=folder';
        String method = 'GET';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        Blob body=null;
        String strBody ='';
        String resp = DriveService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;
    }
    
    //Delete File and Folder
    @AuraEnabled
    public static String deleteFileFolder(String folderId)
    { 
        List<Integration__c> integration = DriveCommunityController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;  
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://www.googleapis.com/drive/v3/files/'+folderId;
        String method = 'DELETE';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        Blob body=null;
        String strBody ='';
        String resp = DriveService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;
    }
    
    //Download File From Url
    @AuraEnabled
    public static String downloadFile(String fileId)
    {   
        List<Integration__c> integration = DriveCommunityController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;   
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://www.googleapis.com/drive/v2/files/'+fileId;
        String method = 'GET';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        Blob body=null;
        String strBody ='';
        String resp = DriveService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;
    }
    
    //Create Folder use Parent Id
    @AuraEnabled
    public static String createFolder(String parentId, String folderName)
    {  
        List<Integration__c> integration = DriveCommunityController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;   
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://www.googleapis.com/drive/v3/files';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');
        httpHeader.put('Accept', 'application/json');
        Blob body=null;
        String strBody ='{"name": "'+folderName+'","mimeType": "application/vnd.google-apps.folder","parents": ["'+parentId+'"]}';
        String resp = DriveService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;
    }
    
    //upload File
    @AuraEnabled
    public static String uploadFiles(String parentId, String uploadFileContent, String uploadFileName, String fileSize, String filetype)
    {  
        
        List<Integration__c> integration = DriveCommunityController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;                                                                              
        String boundary = '----------9889464542212';
        String delimiter = '\r\n--' + boundary + '\r\n';
        String close_delim = '\r\n--' + boundary + '--';
        String bodyEncoded = uploadFileContent;
        String bodyCon = delimiter + 'Content-Type: application/json\r\n\r\n' + '{ "title" : "' + uploadFileName + '",' + ' "mimeType" : "' + filetype + '",' + '"parents": [{"id": "'+parentId+'"}] }' + delimiter + 'Content-Type: ' + filetype + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + bodyEncoded + close_delim;
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://www.googleapis.com/upload/drive/v2/files?uploadType=multipart';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer ' + accessToken);
        httpHeader.put('Content-Type', 'multipart/mixed; boundary="' + boundary + '"');
        httpHeader.put('Content-length', String.valueOf(fileSize));
        String strBody = bodyCon;
        Blob body=null;
        String resp = DriveService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;               
    }
}