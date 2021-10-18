/*
Created By         :    Sumit Pilaniya
Date               :    22/09/2019
Description        :    Dropbox Integration Create Folder, Download File, Upload Files, Show all Files And Folder, Breadcrumb Sequence Maintain  
*/

public class CommunityDropBoxApexController {  
    
    public static  String redirect_uri = 'https://sumitbriskmindcommunit-developer-edition.ap15.force.com/sumitbriskminds/s/?tabset-187cb=2';
    
    //Drop Box Credentials Like access token, redirect url
    public static DropboxCredentials__c accessTokenQuery()
    {
        DropboxCredentials__c ob = 	DropboxCredentials__c.getInstance();
        return ob;
    }
    
    //Access token fetch
    public static List<Integration__c> integrationInfo(){
        User us = [Select ContactId from User where Id=:userinfo.getuserId()];
        List<Integration__c> ob = [SELECT AccessToken__c, Contact_Name__c, Record_type__c, Refersh_token__c From Integration__c WHERE Contact_Name__c =:us.ContactId AND Record_type__c = 'Dropbox'];
        return ob;
    }   
    
    //Get code value from URL
    @AuraEnabled
    public static String dropAuth()
    { 
        List<DropBox_Integration_Key__mdt> customList =[SELECT Client_Key__c, Secret_Key__c FROM DropBox_Integration_Key__mdt Where DeveloperName = 'DropBox_Key' limit 1]; //Fetch client and screat id from Custom Metadata
        String client_key = customList[0].Client_Key__c;  //Client Id 
        String clientsecret = customList[0].Secret_Key__c; //Secret Id
        List<Integration__c> integration = CommunityDropBoxApexController.integrationInfo();
        String resp ='';
        if(integration.size() == 0){
            resp =  CommunityService.authtication_dropbox(client_key, redirect_uri);
        }
        else{         
            resp = 'validToken';
        }              
        return resp;
    }
    
    //Get Access token
    @AuraEnabled
    public static String AccessToken(String codeVal)
    {  
        
        List<DropBox_Integration_Key__mdt> customList =[SELECT Client_Key__c, Secret_Key__c FROM DropBox_Integration_Key__mdt limit 1]; //Fetch client and screat id from Custom Metadata
        String key = customList[0].Client_Key__c;  //Client Id 
        String secret = customList[0].Secret_Key__c; //Secret Id
        Map<String,String> httpHeader = new  Map<String,String>();  //Store HttpRequest Header
        String tokenuri = CommunityService.tokenAccess(codeVal,redirect_uri);
        String endpoint = tokenuri;  //HttpRequest Endpoint
        String method = 'POST'; //HttpRequest Method 
        Blob headerValue = Blob.valueOf(key + ':' + secret); 
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue); //Blob Convert into String
        httpHeader.put('Authorization', authorizationHeader);
        Blob bodyOfReq=Blob.valueOf(''); //Body send as Blob
        String folRes = CommunityService.genericHttp(endpoint,method,bodyOfReq,httpHeader); //Call Generic Http Method in Service Method and return Response
        Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(folRes); //Fetch Access Token
        String accesstoken = (String) meta.get('access_token');  
        User us = [Select ContactId from User where Id=:userinfo.getuserId()];     
        insert new Integration__c(Contact_Name__c = us.ContactId, AccessToken__c = accesstoken, Record_type__c = 'Dropbox');        
        return 'accesstoken';        
    }
    
    //Get All File and Folder List
    @AuraEnabled
    public static String allFilesFolder()
    {
        List<Integration__c> integration = CommunityDropBoxApexController.integrationInfo();    
        String accesstoken = integration[0].AccessToken__c;
        String allFilesFolderRes='';
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.dropboxapi.com/2/files/list_folder';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');
        String bodyFile = CommunityService.bodyOfFile();
        Blob bodyOfReq= Blob.valueOf(bodyFile);
        allFilesFolderRes =  ServiceIntegartionClass.genericHttp(endpoint,method,bodyOfReq,httpHeader);
        String tempFiles = allFilesFolderRes.replace('.tag', 'tag');
        return tempFiles;
    }
    
    //Get Files from Folder Id
    @AuraEnabled
    public static String filesInFolder(String idOfFile)
    {
        List<Integration__c> integration = CommunityDropBoxApexController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;
        String folRes = '';
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.dropboxapi.com/2/files/list_folder';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');
        String bodyFile = CommunityService.fileInFolder(idOfFile);
        Blob bodyOfReq= Blob.valueOf(bodyFile);
        folRes = ServiceIntegartionClass.genericHttp(endpoint,method,bodyOfReq,httpHeader);
        String tempFiles = folRes.replace('.tag', 'tag');
        return tempFiles;
    }
    
    //Delete File and Folder
    @AuraEnabled
    public static String deleteFileFolders(String pathOfFiles)
    {
        List<Integration__c> integration = CommunityDropBoxApexController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;   
        String folRes = '';
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.dropboxapi.com/2/files/delete_v2';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');
        String bodyFile = CommunityService.deleteFile(pathOfFiles);
        Blob bodyOfReq= Blob.valueOf(bodyFile);
        folRes = CommunityService.genericHttp(endpoint,method,bodyOfReq,httpHeader);
        String tempFiles = folRes.replace('.tag', 'tag');
        return tempFiles;
    }
    
    //Download File From Url
    @AuraEnabled
    public static String downloadFile(String idOfFile)
    {
        List<Integration__c> integration = CommunityDropBoxApexController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;    
        String folRes = '';
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.dropboxapi.com/2/files/get_temporary_link';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');
        Blob bodyOfReq= Blob.valueOf('{"path": "'+idOfFile+'"}');
        folRes = CommunityService.genericHttp(endpoint,method,bodyOfReq,httpHeader);
        String tempFiles = folRes.replace('.tag', 'tag');       
        return tempFiles;
    }
    
    //Upload File
    @AuraEnabled
    public static String uploadFiles(String parentId, String uploadFileContent, String uploadFileName)
    {
        List<Integration__c> integration = CommunityDropBoxApexController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;     
        String folRes = '';
        String uploadFilePath='';
        uploadFilePath = parentId + '/' + uploadFileName;
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://content.dropboxapi.com/2/files/upload';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/octet-stream');
        httpHeader.put('Dropbox-API-Arg','{"path": "'+uploadFilePath+'","mode": "add","autorename": true,"mute": false,"strict_conflict": false}');
        Blob bodyOfReq= EncodingUtil.base64Decode(uploadFileContent);
        folRes = ServiceIntegartionClass.genericHttp(endpoint,method,bodyOfReq,httpHeader);
        String tempFiles = folRes.replace('.tag', 'tag');
        return tempFiles;
    }
    
    //Create Folder use Parent Id
    @AuraEnabled
    public static String createFolder(String pathOfFolder)
    {
        List<Integration__c> integration = CommunityDropBoxApexController.integrationInfo();
        String accesstoken = integration[0].AccessToken__c;
        String folRes = '';
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.dropboxapi.com/2/files/create_folder_v2';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');
        String bodyFile = CommunityService.createFolderPath(pathOfFolder);
        Blob bodyOfReq= Blob.valueOf(bodyFile);
        folRes = CommunityService.genericHttp(endpoint,method,bodyOfReq,httpHeader);
        String tempFiles = folRes.replace('.tag', 'tag');
        return tempFiles;
    }
}