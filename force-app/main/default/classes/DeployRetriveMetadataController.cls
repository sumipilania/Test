public with sharing class DeployRetriveMetadataController {
    public String recId;
    public OrgDeatil__c orgDetail;
    public List<String> recData;
    public String code='';
    public DeployRetriveMetadataController() {
        System.debug('constr');
        System.debug(' apexpages.currentpage().getparameters()='+ apexpages.currentpage().getparameters());
        System.debug(' apexpages.currentpage().getparameters().get='+ apexpages.currentpage().getparameters().get('state'));
        recData = apexpages.currentpage().getparameters().get('state').split(',');
        code = apexpages.currentpage().getparameters().get('code');
        System.debug('code='+code);
        System.debug('recData='+recData);
    }
    
    public PageReference redirectPage(){
        System.debug('callMethod');
        PageReference pr;
        String resp =  fetchAccessToken();
        if(String.isNotBlank(resp)){
            Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(resp); //Fetch Access Token
            String accessToken = (String) meta.get('access_token');
            String refToken = (String) meta.get('refresh_token');
            String idToken = (String) meta.get('id_token');
            String instanceUrl = (String) meta.get('instance_url');
            String userId = (String) meta.get('id');
            System.debug('accessToken='+accessToken);
            System.debug('refToken='+refToken);
            if(String.isNotBlank(accessToken) && String.isNotBlank(refToken) && recData.size()>0){
                System.debug('recData[0]='+recData[0]);
                if(recData[0].equals('undefined')){        
                    System.debug('if');
                    OrgDeatil__c obj =  new OrgDeatil__c(Name=recData[1], Org_Type__c = recData[2], Custom_Url__c =  recData[3], Access_Token__c = accessToken, Refersh_Token__c = refToken, Id_Token__c = idToken ,Instance_Url__c = instanceUrl, User_Id__c = userId);
                    insert obj;
                    System.debug('objId='+obj.Id);
                    pr = new PageReference('https://sumit-pilaniya-light9domain-dev-ed.lightning.force.com/'+obj.Id);
                }
                else{
                    System.debug('else');
                    OrgDeatil__c orgObj = [SELECT Name, Org_Type__c, Custom_Url__c, Access_Token__c, Refersh_Token__c, Id_Token__c, Instance_Url__c, User_Id__c  FROM OrgDeatil__c WHERE Id =:recData[0] LIMIT 1];
                    orgObj.Name = recData[1];
                    orgObj.Org_Type__c = recData[2];
                    orgObj.Custom_Url__c =  recData[3];
                    orgObj.Access_Token__c = accessToken;
                    orgObj.Refersh_Token__c = refToken;
                    orgObj.Id_Token__c = idToken;
                    orgObj.Instance_Url__c = instanceUrl;
                    orgObj.User_Id__c = userId;
                    update orgObj;
                    pr = new PageReference('https://sumit-pilaniya-light9domain-dev-ed.lightning.force.com/'+recData[0]);
                }
            }
        }
        return pr;
    }
    
    public String fetchAccessToken(){
        Metadata_Creditional__mdt metaObj = [SELECT Client_Key__c, Secret_Key__c From Metadata_Creditional__mdt where Developername = 'ConnectApp_Key'];
        System.debug('fetch metaObj='+metaObj);
        String endPoint = 'https://login.salesforce.com/services/oauth2/token?grant_type=authorization_code&code='+code+'&client_id='+metaObj.Client_Key__c+'&client_secret='+metaObj.Secret_Key__c+'&redirect_uri=https://sumit-pilaniya-light9domain-dev-ed--c.visualforce.com/apex/deployRetriveMetadataRedirectPage';
        Blob blobBody;
        System.debug('before');
        String resp = RestServiceCallout.restCallout(endPoint, 'POST', blobBody, null, new  Map<String,String>());
        System.debug('after='+resp);
        return resp;
    }
    
    @AuraEnabled
    public static RecordData fetchRecord(String recId){
        RecordData recObj = new RecordData();
        Metadata_Creditional__mdt metaObj = [SELECT Client_Key__c From Metadata_Creditional__mdt where Developername = 'ConnectApp_Key'];        recObj.redirectUrl = '/services/oauth2/authorize?client_id='+metaObj.Client_Key__c+'&prompt=login&redirect_uri=https://sumit-pilaniya-light9domain-dev-ed--c.visualforce.com/apex/deployRetriveMetadataRedirectPage&response_type=code';
        System.debug('clientKey='+metaObj.Client_Key__c);
        System.debug('recordId='+recId);
        if(String.isNotBlank(recId)){
            recObj.orgObjRecord = [SELECT Name, Org_Type__c, Custom_Url__c FROM OrgDeatil__c WHERE Id =:recId LIMIT 1];
        }
        return recObj;
    }
    
    public class RecordData{
        @AuraEnabled public  OrgDeatil__c orgObjRecord;
        @AuraEnabled public  String redirectUrl;
    }
    
}