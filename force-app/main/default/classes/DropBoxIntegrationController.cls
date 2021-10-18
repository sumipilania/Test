/*
 Created By         :    Sumit Pilaniya
 Date               :    10/09/2019
 Description        :    Dropbox Integration Upload Files, Show all Files And Folder, Breadcrumb Sequence Maintain  

*/


public class DropBoxIntegrationController
{
    public String code; //To Stor code in url
    public string key;  //Client Id fetch from Custom Metadata
    public string secret; // Secret Id fetch from Custom Metadata
    public string redirect_uri = 'https://c.ap15.visual.force.com/apex/DropBoxIntegrationPage'; //Redirect the URL
    public String accesstoken;  //Access token to access to files and folder and used to all hits 
    public String allFilesFolderRes; // Temp String to Remove dots from Json String
    public Map<String,String> fileFolderName{get;set;} //Map to Store Folder Name
    public Map<String,String> fileNames{get;set;}  // Map to Store Files Name
    public String pathOfFiles; // Store Path Of file to retrive files
    public Map<String,String> breadSequence{get;set;} //Breadcum Manage this map
    public Map<String,String> breadSequenceTemp; //Temporary breadSequence map store 
    public String breadKey; //Store id of files
    public String breadVal;  //Store Name of files
    public String breadKeyRev; //Store Breadcum Key
    public Blob uploadFileContent{get;set;} //File Content in Blob
    public String uploadFileName{get;set;} //file Nameof Upload
    public  String bKeyPathOfFiles; //Fetch files and folder make path
    public String tempLink{get;set;} //Download Files using Temporary link
    public String folRes;
    public DropBoxIntegrationController()
    {
        fileFolderName = new Map<String,String>();
        fileNames = new Map<String,String>();
        breadSequence = new Map<String,String>();
        breadSequence.put('HOME','HOME'); //Breadcoumb store First value Root files fetch
        breadSequenceTemp = new Map<String,String>();
        breadSequenceTemp.put('HOME','HOME');
        allFilesFolderRes = '';
        pathOfFiles = '';
    }
    
    //Authorization to use this method 
    public PageReference dropAuth()
    {
        List<DropBox_Integration_Key__mdt> customList =[SELECT Client_Key__c, Secret_Key__c FROM DropBox_Integration_Key__mdt]; //Fetch client and screat id from Custom Metadata
        for(DropBox_Integration_Key__mdt obj : customList)
        {
            key = obj.Client_Key__c;  //Client Id
            secret = obj.Secret_Key__c; //Secret Id
        }
        
        //First time code null
        code = ApexPages.currentPage().getParameters().get('code');
        if(code != '' && code != null)
        {
            AccessToken();//Access Token Fetch
            return null;
        }
        else
        {
            return new PageReference(ServiceIntegartionClass.authtication_dropbox(key,redirect_uri));  //Redirect after authorization
        }
        
    }
    
    //Fetch access toekn
    public void AccessToken()
    {  
        Map<String,String> httpHeader = new  Map<String,String>();  //Store HttpRequest Header
        String tokenuri = ServiceIntegartionClass.tokenAccess(code,redirect_uri);
        String endpoint = tokenuri;  //HttpRequest Endpoint
        String method = 'POST'; //HttpRequest Method 
        Blob headerValue = Blob.valueOf(key + ':' + secret); 
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue); //Blob Convert into String
        httpHeader.put('Authorization', authorizationHeader);
        Blob bodyOfReq=Blob.valueOf(''); //Body send as Blob
        folRes = ServiceIntegartionClass.genericHttp(endpoint,method,bodyOfReq,httpHeader); //Call Generic Http Method in Service Method and return Response
        Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(folRes); //Fetch Access Token
        accesstoken = (String) meta.get('access_token'); //Store Access Token
        allFilesFolder(); //First Time All Root Files And Folder Show
    }
    
    //All Files And Folder Show
    public void allFilesFolder()
    {
        fileFolderName.clear(); //Every Method fill According To folder
        fileNames.clear();  //Every Method fill According To Files
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.dropboxapi.com/2/files/list_folder';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');
        String bodyFile = ServiceIntegartionClass.bodyOfFile();
        Blob bodyOfReq= Blob.valueOf(bodyFile);
        allFilesFolderRes =  ServiceIntegartionClass.genericHttp(endpoint,method,bodyOfReq,httpHeader);
        String tempFiles = allFilesFolderRes.replace('.tag', 'tag');
        WrapperBind(tempFiles);
    }
    
    //Fetch File and Folder inside Folder
    public void filesInFolder()
    {
        pathOfFiles = '';
        fileFolderName.clear();
        fileNames.clear();
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.dropboxapi.com/2/files/list_folder';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');
        breadKey = ApexPages.currentPage().getParameters().get('brKey');
        breadVal = ApexPages.currentPage().getParameters().get('brVal');
        breadSequence.put(breadKey,breadVal);
        for(String sKey : breadSequence.keySet())
        {
            if(!(sKey.equals('HOME')))
            {
                pathOfFiles = pathOfFiles+'/'+breadSequence.get(sKey);
            }
        }
        String bodyFile = ServiceIntegartionClass.fileInFolder(pathOfFiles);
        Blob bodyOfReq= Blob.valueOf(bodyFile);
        folRes = ServiceIntegartionClass.genericHttp(endpoint,method,bodyOfReq,httpHeader);
        String tempFiles = folRes.replace('.tag', 'tag');
        WrapperBind(tempFiles);
    }
    
    //Maintain Breadcrumb functionallity
    public void breadCrumbMethod()
    {
        fileFolderName.clear();
        fileNames.clear();
        bKeyPathOfFiles='';
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.dropboxapi.com/2/files/list_folder';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');
        breadKeyRev = ApexPages.currentPage().getParameters().get('brKeyRev');
       
        Map<String,String> breadSequenceTemp = new Map<String,String>();
        breadSequenceTemp.put('HOME','HOME');
        for(String bKey : breadSequence.keySet()) 
        {   
            if(breadKeyRev.equals('HOME'))
            {
                break;
            }
            else if(!(bKey.equals(breadKeyRev)))
            {
                if(!bKey.equals('HOME'))
                {
                    breadSequenceTemp.put(bKey,breadSequence.get(bKey));
                    bKeyPathOfFiles = bKeyPathOfFiles+'/'+breadSequence.get(bKey);
                }
            }
            else if(bKey.equals(breadKeyRev))
            {     
                breadSequenceTemp.put(bKey,breadSequence.get(bKey));
                bKeyPathOfFiles = bKeyPathOfFiles+'/'+breadSequence.get(bKey);
                break;
            }
        }   
        breadSequence = new Map<String,String>();
        breadSequence = breadSequenceTemp;
        String bodyFile = ServiceIntegartionClass.fileInFolder(bKeyPathOfFiles);
        Blob bodyOfReq= Blob.valueOf(bodyFile);
        folRes = ServiceIntegartionClass.genericHttp(endpoint,method,bodyOfReq,httpHeader);
        String tempFiles = folRes.replace('.tag', 'tag');
        WrapperBind(tempFiles);
        pathOfFiles = bKeyPathOfFiles;
    }  
   
    //Upload files
    public void uploadFiles()
    {
        if(uploadFileName!=null && uploadFileName!='')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'File Successfully Upload'));
            blob  b = uploadFileContent; //Input File Content
            String uploadFilePath='';
            uploadFilePath = pathOfFiles + '/' + uploadFileName;
            Map<String,String> httpHeader = new  Map<String,String>();
            String endpoint = 'https://content.dropboxapi.com/2/files/upload';
            String method = 'POST';
            httpHeader.put('Authorization', 'Bearer '+accesstoken);
            httpHeader.put('Content-Type', 'application/octet-stream');
            httpHeader.put('Dropbox-API-Arg','{"path": "'+uploadFilePath+'","mode": "add","autorename": true,"mute": false,"strict_conflict": false}');
            Blob bodyOfReq= b;
            folRes = ServiceIntegartionClass.genericHttp(endpoint,method,bodyOfReq,httpHeader);
             uploadFileName = '';
            afterUploadFile(pathOfFiles);    
        }
        else
        {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Select Any File'));
        }    
       
    }
    
    //After Upload Again Hit Http Request
    public void afterUploadFile(String locPathOfFiles)
    {
        fileFolderName.clear();
        fileNames.clear();
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.dropboxapi.com/2/files/list_folder';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');
        String bodyFile = ServiceIntegartionClass.fileInFolder(locPathOfFiles);
        Blob bodyOfReq= Blob.valueOf(bodyFile);
        folRes = ServiceIntegartionClass.genericHttp(endpoint,method,bodyOfReq,httpHeader);
        String tempFiles = folRes.replace('.tag', 'tag'); //Replace .tag from tag
        WrapperBind(tempFiles);
    }
    
    //Download Files
    public void downloadFile()
    {
        String downloadFileName = ApexPages.currentPage().getParameters().get('downloadId');
        String wholePath = '';
        wholePath = pathOfFiles;
        wholePath = wholePath+'/'+downloadFileName; //Make Path of Download File
        Map<String,String> httpHeader = new  Map<String,String>();
        String endpoint = 'https://api.dropboxapi.com/2/files/get_temporary_link';
        String method = 'POST';
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        httpHeader.put('Content-Type', 'application/json');
        Blob bodyOfReq= Blob.valueOf('{"path": "'+wholePath+'"}');
        folRes = ServiceIntegartionClass.genericHttp(endpoint,method,bodyOfReq,httpHeader);
        WrapperClassIntegration c = (WrapperClassIntegration)JSON.deserialize(folRes,WrapperClassIntegration.class);
        tempLink = c.link; //Temperory link
    }
    
    //Every time we fill Folder and files Name
    public void WrapperBind(String jsonStr)
    {
        WrapperClassIntegration c = (WrapperClassIntegration)JSON.deserialize(jsonStr,WrapperClassIntegration.class); //deserialize in wrapper class
        for(WrapperClassIntegration.Entry e : c.entries)
        {
            if(e.tag.equals('folder'))
            {
                fileFolderName.put(e.id,e.name);   //Folder Name Store In Map
            }
            else
            {
                //Not Show Restricted files Using Custom Label
                if(!(e.id.equals(System.Label.FileId1) || (e.id.equals(System.Label.FileId2))))
                {
                    fileNames.put(e.id,e.name); //Store Files Name In Map
                }   
            }   
        } 
        
    }
}