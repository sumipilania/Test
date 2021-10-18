@isTest
public class DropBoxMockClass implements HttpCalloutMock {
    Integer i=1;
    public HTTPResponse respond(HTTPRequest request)
    {
        DropBoxIntegrationController o = new DropBoxIntegrationController();
        HTTPResponse res = new HTTPResponse();
        String tempBody;
        String redirect_url = 'https://c.ap15.visual.force.com/apex/DropBoxIntegrationPage';
        //o.code = 'Httpcode';
        if(request.getEndpoint()=='https://www.dropbox.com/1/oauth2/authorize?response_type=code&client_id='+o.key +'&redirect_uri='+o.redirect_uri)
        {
            tempBody = '{"example":"test"}';
        } 
        else if(request.getEndpoint()=='https://api.dropbox.com/1/oauth2/token?grant_type=authorization_code&code=null&redirect_uri=https://c.ap15.visual.force.com/apex/DropBoxIntegrationPage')
        {
            tempBody = '{"access_token":"sumit"}';
            res = DropBoxMockClass.httpHit(tempBody); 
        }   
        else if(request.getEndpoint()=='https://api.dropboxapi.com/2/files/list_folder')
        {  
          if(i<=4)
          {
            PageReference PageRef = Page.DropBoxIntegrationPage;
            Test.setCurrentPage(PageRef);
            ApexPages.currentPage().getParameters().put('brKey', '123');  
            ApexPages.currentPage().getParameters().put('brVal', 'Test2');
            tempBody = '{"entries": [{".tag": "folder","name": "Test1","id": "id:qsWnS2zu3OAAAAAAAAAADA" },{".tag": "file","name": "VisualForce.docx","id": "id:qsWnS2zu3OAAAAAAAAAAKg"}]}';
            res = DropBoxMockClass.httpHit(tempBody);
            i++;
          }
          if(i<=7 && i>=5)
          {
            PageReference PageRef = Page.DropBoxIntegrationPage;
            Test.setCurrentPage(PageRef);
            ApexPages.currentPage().getParameters().put('brKeyRev', 'Tes1');  
            tempBody = '{"entries": [{".tag": "folder","name": "Test1","id": "id:qsWnS2zu3OAAAAAAAAAADA" },{".tag": "file","name": "VisualForce.docx","id": "id:qsWnS2zu3OAAAAAAAAAAKg"}]}';
            res = DropBoxMockClass.httpHit(tempBody);
          
          }
        } 
        else if(request.getEndpoint()=='https://content.dropboxapi.com/2/files/upload')
        {
            tempBody = 'Blob[11]';
            res = DropBoxMockClass.httpHit(tempBody); 
        }
        else if(request.getEndpoint()=='https://api.dropboxapi.com/2/files/get_temporary_link')
        {  
            PageReference PageRef = Page.DropBoxIntegrationPage;
            Test.setCurrentPage(PageRef);
            ApexPages.currentPage().getParameters().put('downloadId', '123');  
            tempBody = '{"entries": [{".tag": "folder","name": "Test1","id": "id:qsWnS2zu3OAAAAAAAAAADA" },{".tag": "file","name": "VisualForce.docx","id": "id:qsWnS2zu3OAAAAAAAAAAKg"}]}';
            res = DropBoxMockClass.httpHit(tempBody);
        }
        return res;
    }
    public static HTTPResponse httpHit(String body)
    {
        HTTPResponse response = new HTTPResponse();
        response.setBody(body);
        response.setStatusCode(200);
        return response;
    }
    
}