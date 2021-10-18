/*
 Created By	 		:	 Sumit Pilaniya
 Description	 	:	Custom Editior to deploy your code in apex class and any compile time error come than show after deployment 
*/

public class CustomEditorController {
    public static String endpoint = 'https://sumit-pilaniya-light9domain-dev-ed.my.salesforce.com/services/data/v46.0/tooling/sobjects';
    public static String queryEndPoint = 'https://sumit-pilaniya-light9domain-dev-ed.my.salesforce.com/services/data/v46.0/tooling/query/?q=';
    public static String sessionId = Page.SessionId.getContent().toString();
    @AuraEnabled 
    public static List<sObject> fetchApexClass(){
        return [Select id,Name,body From ApexClass];
    }
    @AuraEnabled 
    public static List<sObject> fetchBody(String classId){
        return [Select id,Name,body From ApexClass Where id=:classId];
        
    }
    
    @AuraEnabled 
    public static List<String> containerDetailCheck(String classId, String classBody, String className){
        // String sessionId = Page.SessionId.getContent().toString();
        String body = null;
        String queryEndPoint = 'https://sumit-pilaniya-light9domain-dev-ed.my.salesforce.com/services/data/v46.0/tooling/query/?q=Select+id,Name+from+MetadataContainer+where+name=\'' + className + '\'';
        String metaDataContainerResp = CustomEditorController.httpCallout(queryEndPoint,body,'GET');
        ContainerDetail obj  = (ContainerDetail)JSON.deserialize(metaDataContainerResp,ContainerDetail.class); //deserialize in wrapper class
        Integer size = obj.size;
        String containerId = '';
        if(size==0){
            body = '{"Name":"'+className+'"}';
            String createMetadataResp = CustomEditorController.httpCallout(endpoint+'/MetadataContainer',body,'POST');
            Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(createMetadataResp); //Fetch Access Token
            containerId = (String) meta.get('id');
        }else{
            containerId = obj.records[0].Id;
        }
        List<String> containerList = new List<String>();
        String apexMId = apexMember(classId,classBody,containerId);
        containerList.add(containerId);
        containerList.add(apexMId);
        
        return containerList;
    }
    
    @AuraEnabled 
    public static String apexMember(String classId, String classBody, String containerId){
        String body = null;
        String apexMId ='';
        String apexMemeberResp = CustomEditorController.httpCallout(queryEndPoint+'Select+id,FullName,ContentEntityId+from+ApexClassMember+where+ContentEntityId=\'' + classId + '\'+AND+MetadataContainerId=\'' + containerId + '\'',body,'GET');
        ContainerDetail obj  = (ContainerDetail)JSON.deserialize(apexMemeberResp,ContainerDetail.class); //deserialize in wrapper class
        if(obj.size==0){
            body =  '{"MetadataContainerId" : "'+containerId+'", "ContentEntityId" : "'+classId+'",'+classBody+'}';
            apexMemeberResp = CustomEditorController.httpCallout(endpoint+'/ApexClassMember',body,'POST');
            Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(apexMemeberResp); //Fetch Access Token
            apexMId = (String) meta.get('id');
            
        }else{
            body = null;
            apexMId = obj.records[0].Id;
            String apexMembDlt = CustomEditorController.httpCallout(endpoint+'/ApexClassMember/'+apexMId,body,'DELETE');
            body =  '{"MetadataContainerId" : "'+containerId+'", "ContentEntityId" : "'+classId+'",'+classBody+'}';
            apexMemeberResp = CustomEditorController.httpCallout(endpoint+'/ApexClassMember',body,'POST');
            Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(apexMemeberResp); //Fetch Access Token
            apexMId = (String) meta.get('id');
        }
        return apexMId;
    }
    
    @AuraEnabled 
    public static String containerAsyncRequest(String containerId, String apexMid, String classId){
        String body =  '{"MetadataContainerId" : "'+containerId+'", "isCheckOnly": "false"}';
        String asyncRequestResp = CustomEditorController.httpCallout(endpoint+'/containerAsyncRequest',body,'POST');
        Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(asyncRequestResp); //Fetch Access Token
        String statusId = (String) meta.get('id');
        return statusId;
    }
    
     @AuraEnabled  
    public static List<String> checkCodeStatus(String statusId){
        List<String> resp = new List<String>();
        String body = null;
        String checkStatus = CustomEditorController.httpCallout(endpoint+'/containerAsyncRequest/'+statusId,body,'GET');
        Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(checkStatus); //Fetch Access Token
        String stateRes = (String) meta.get('State');
        if(stateRes.equalsIgnoreCase('Completed')){
            resp.add('Completed');
        }
        else{
            if(stateRes.equalsIgnoreCase('Failed')){
                resp.add('Failed');
                ContainerDetail obj  = (ContainerDetail)JSON.deserialize(checkStatus,ContainerDetail.class); //deserialize in wrapper class
				 resp.add(obj.DeployDetails.allComponentMessages[0].problem);
            }
        }
      return resp;
    }
    
    public static String httpCallout(String endpoint, String body, String method){
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        if(!(body==null || body=='')){
            req.setBody(body);
        }
        Http httpreq = new Http();
        HttpResponse res = httpreq.send(req);
        return res.getBody();
    }
    
    public class ContainerDetail {
        public RecordList DeployDetails;
        public List<RecordList> records;
        public Integer size;
    }
    
    public class RecordList{
        public List<ProblemDetail> allComponentMessages;
        public String Id;	
        public String Name;	
    }
    
    public class ProblemDetail{
         public String problem;
    }
}