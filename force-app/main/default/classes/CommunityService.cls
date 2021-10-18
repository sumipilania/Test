public class CommunityService {
    public static String authtication_dropbox(String key, String redirect_uri)   
    {
        return 'https://www.dropbox.com/1/oauth2/authorize?response_type=code&client_id='+key+'&redirect_uri='+redirect_uri;
    }
    public static String tokenAccess(String code, String redirect_url)
    {
        return  'https://api.dropbox.com/1/oauth2/token?grant_type=authorization_code&code='
            +code+'&redirect_uri='+redirect_url;
    }
    public static String bodyOfFile()
    {
        return  '{"path": "","recursive": false,"include_media_info": false,"include_deleted": false,"include_has_explicit_shared_members": false,"include_mounted_folders": true,"include_non_downloadable_files": true}';
    }
    public static String fileInFolder(String idOfFile)
    {
        return  '{"path": "'+idOfFile+'","recursive": false,"include_media_info": false,"include_deleted": false,"include_has_explicit_shared_members": false,"include_mounted_folders": true,"include_non_downloadable_files": true}';
    }
    public static String deleteFile(String pathFile)
    {
        return  '{"path": "'+pathFile+'"}';
    }
     public static String createFolderPath(String pathFile)
    {
        return  '{"path": "'+pathFile+'","autorename": false}';
    }
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
        System.debug('Generic Res=='+res.getBody());
        return res.getBody();
    }
    
    
}