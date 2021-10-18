public class ServiceIntegartionClass 
{
    //At a time user authorized
    public static String authtication_dropbox(String key, String redirect_url)   
    {
        return 'https://www.dropbox.com/1/oauth2/authorize?response_type=code&client_id='+key+'&redirect_uri='+redirect_url;
    }
    
    //That time user have token and authorized
    public static String tokenAccess(String code, String redirect_url)
    {
        return  'https://api.dropbox.com/1/oauth2/token?grant_type=authorization_code&code='
            +code+'&redirect_uri='+redirect_url;
    }
    
    //Find Path to Access File And Folder
    public static String bodyOfFile()
    {
        return  '{"path": "","recursive": false,"include_media_info": false,"include_deleted": false,"include_has_explicit_shared_members": false,"include_mounted_folders": true,"include_non_downloadable_files": true}';
    }
    
    //Access Files and Folder inside Folder
    public static String fileInFolder(String pathFile)
    {
        return  '{"path": "'+pathFile+'","recursive": false,"include_media_info": false,"include_deleted": false,"include_has_explicit_shared_members": false,"include_mounted_folders": true,"include_non_downloadable_files": true}';
    }
   
    //Generic Method to Use Callout
    public static String genericHttp(String endPoint, String method, Blob body, Map<String,String> headerMap)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(method);
        req.setTimeout(60*1000);
        for(String sKey : headerMap.keyset())
        {
            req.setHeader(sKey,headerMap.get(sKey));
        }
        req.setBodyAsBlob(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();
    }
}