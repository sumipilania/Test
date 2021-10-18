public class SalesforceToSalesforceIntegration {
    public static String clientId = '3MVG9G9pzCUSkzZvBSVfOyH8jKPZSfQ4Uhk5tOdoNtn2xU8uP6cAagP9rypQiJL2ayR3AuQ24fOIQj9cWVCzy';
    public static String clientSecret = '1E1E387674C565A6D2F4FE5427B8E26C9A29651396EA345D0B50F57E2F8FA0A6';
    public static String username = 'sumitsalesforce7737@gmail.com';
    public static String password = '17MCAL031';
    
    
    
    @AuraEnabled
    public static Map<String,String> getObjectList()
    {
        Map<String,String> options = new Map<String,String>();
        Map<String,schema.SObjectType> allobj=schema.getGlobalDescribe();
        List<string> objnames = new List<string>();
        objnames.addAll(allobj.keySet());
        objnames.sort();
        Schema.DescribeSobjectResult[] results  = Schema.describeSObjects(objnames);   
        for(Schema.DescribeSobjectResult describeResult  : results){                
            if(describeResult.isQueryable() && describeResult.isSearchable() && describeResult.isUndeletable() && !describeResult.isCustom()) {                    
                options.put(describeResult.getName(),describeResult.getLabel());
            }
        }
        return options;
    }
    
    @AuraEnabled
    public static Map<String, String> getObjectFields(String objName) 
    {
        Map<String, String> retVal = new Map<String, String>();
        if(!objName.equals(''))
        {
            Map<String, Schema.SObjectField> sObjectfields = Schema.getGlobalDescribe().get(objName).getDescribe().SObjectType.getDescribe().fields.getMap();
            for(Schema.SObjectField field : sObjectfields.values())            
            {          
                Schema.DescribeFieldResult fieldResult = field.getDescribe();                    
                if(fieldResult.isAccessible() && fieldResult.isCreateable() && fieldResult.isSortable() && !fieldResult.isCustom())                
                {   
                    retVal.put(field.getDescribe().getName(),field.getDescribe().getLabel()); 
                }
            }   
        }                  
        return retVal;
    }
    
    //Wrapper For Columns Show
    @AuraEnabled
    public static List<DynamicWrapper> showFieldDynamically(String objName, List<String> fieldList) 
    {
        List<DynamicWrapper> wrapList = new List<DynamicWrapper>();
        if(!objName.equals(''))
        {
            Map<String, Schema.SObjectField> sObjectfields = Schema.getGlobalDescribe().get(objName).getDescribe().SObjectType.getDescribe().fields.getMap();
            for(Schema.SObjectField field : sObjectfields.values())            
            {                 
                Schema.DescribeFieldResult fieldResult = field.getDescribe();                    
                if(fieldResult.isAccessible() && fieldResult.isCreateable() && fieldResult.isSortable() )                
                {   
                    if(fieldList.contains(field.getDescribe().getName()))
                    {
                        DynamicWrapper myWrap = new DynamicWrapper();    
                        myWrap.fieldLabel = field.getDescribe().getLabel();  
                        myWrap.fieldApi = field.getDescribe().getName(); 
                        myWrap.type = field.getDescribe().getType(); 
                        myWrap.sortable = true;
                        wrapList.add(myWrap); 
                    }
                }
            }
        }
        System.debug('call method');
        SalesforceToSalesforceIntegration.authorization();
        return wrapList;
    }
    
    @AuraEnabled
    public static void authorization(){
        System.debug('inside');
        Map<String,String> httpHeader = new  Map<String,String>();  //Store HttpRequest Header
        String endpoint ='https://login.salesforce.com/services/oauth2/token'; //HttpRequest Endpoint        
        String method = 'POST'; //HttpRequest Method 
        Blob body=null;
        String strBody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;   
        String resp = SalesforceToSalesforceIntegrationService.genericHttp(endpoint, method, body, strBody, httpHeader);
        Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(resp); //Fetch Access Token
        String accesstoken = (String) meta.get('access_token'); //Store Access Token
        List<Salesforce_Integration__c> sObjList = [SELECT 	AccessToken__c From Salesforce_Integration__c];
        Integer i = 0;
        System.debug('size-==='+sObjList.size());
        if(sObjList.size()>0){
                sObjList[0].AccessToken__c = accesstoken;
                upsert sObjList;
        }
        else{
             System.debug('else');
            insert new Salesforce_Integration__c(Name=String.valueOf(++i),AccessToken__c=accesstoken);
        }
        
        
    }
    
     @AuraEnabled
    public static String showDynmaicRecords(String objName, String query) 
    {
        List<Salesforce_Integration__c> sObjList = [SELECT 	AccessToken__c From Salesforce_Integration__c];
        String accesstoken = sObjList[0].AccessToken__c;
        String queryRec = 'SELECT+'+query+'+FROM+'+objName;
        System.debug('queryRec=='+queryRec);
        Map<String,String> httpHeader = new  Map<String,String>();  //Store HttpRequest Header
        String endpoint ='https://ap15.salesforce.com/services/data/v25.0/query?q='+queryRec; //HttpRequest Endpoint        
        String method = 'GET'; //HttpRequest Method 
        httpHeader.put('Authorization', 'Bearer '+accesstoken);
        Blob body=null;
        String strBody = null;   
        String resp = SalesforceToSalesforceIntegrationService.genericHttp(endpoint, method, body, strBody, httpHeader);
        return resp;
    }
    
    //Colum Variable Store
    public class DynamicWrapper
    {
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public String fieldApi;
        @AuraEnabled public Schema.DisplayType type;
        @AuraEnabled public boolean sortable;
    }
    
}