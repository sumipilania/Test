/************************************************************************************************************************************
Class Name     :  PunchhCalloutUtility
Purpose        :  A utility class to write all the methods related to Punchh Callouts
History        :                                                            
-------                                                            
VERSION  AUTHOR                 DATE              	DETAIL                              	TICKET REFERENCE/ NO.
1.       Briskminds           2020-07-02         	Original Version                        Unknown
													
@Testsuite:  {}
*************************************************************************************************************************************/
public with sharing class PunchhCalloutUtility {

    /*
    * Method Name: genericCallout
    * Description: A generic method to make all the HTTP callout
    * Parameters: String endPoint, String method, Blob blobBody, String strBody, Map<String, String> headerMap
    * Returns: HttpResponse
    * Ticket: Unknown
    */
    public static HttpResponse genericCallout(String endPoint, String method, Blob blobBody, String strBody, Map<String, String> headerMap){

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(method);
      
        for(String sKey : headerMap.keyset()){
            req.setHeader(sKey, headerMap.get(sKey));
        }
        if(String.isNotBlank(strBody)){
            req.setBody(strBody);
        }
        if(blobBody != null){
            req.setBodyAsBlob(blobBody);
        }
      
        Http h = new Http();
        return h.send(req);      
    }

    /*
    * Method Name: getAccessToken
    * Description: A generic method to get the access token
    * Parameters: Punch_Configuration__c getConfigurationLocal
    * Returns: String
    * Ticket: Unknown
    */
    public static String getAccessToken(Punch_Configuration__c getConfigurationLocal) {
        String accessToken = null;
        if(String.isNotBlank(getConfigurationLocal.Access_Token_Var2__c)) {
            accessToken = getConfigurationLocal.Access_Token__c + getConfigurationLocal.Access_Token_Var2__c;
        } else {
            accessToken = getConfigurationLocal.Access_Token__c;
        }
        return accessToken;
    }

    /*
    * Method Name: describeObjects
    * Description: Method to get fields salesforfce
    * Parameters: none
    * Returns: Object
    * Ticket: Unknown
    */
    public static List<PunchhCalloutUtility.Attributes> describeObjects() {
        List<PunchhCalloutUtility.Attributes> sfData = new List<PunchhCalloutUtility.Attributes>();
        for(Schema.DescribeSobjectResult results : Schema.describeSObjects(PunchConstants.OBJECT_TYPES)) {
            Map<String, Schema.SObjectField> sObjectfields = results.fields.getMap();
            PunchhCalloutUtility.Attributes atr = new PunchhCalloutUtility.Attributes();
            List<PunchhCalloutUtility.FieldMetadata> attributes = new List<PunchhCalloutUtility.FieldMetadata>();
            for(Schema.SObjectField field : sObjectfields.values()) {    
                Schema.DescribeFieldResult fieldResult = field.getDescribe();
                if(fieldResult.isFilterable() && fieldResult.isAccessible()) {
                    PunchhCalloutUtility.FieldMetadata fm = new PunchhCalloutUtility.FieldMetadata();
                    fm.label = fieldResult.getLabel();
                    fm.name = fieldResult.getName();
                    fm.type = String.valueOf(fieldResult.getType());
                    attributes.add(fm);
                }
            }
            atr.attributes = attributes;
            atr.label = results.getName();
            atr.name = results.getName();
            sfData.add(atr);
        }
        return sfData;
    }

    /*
    * Method Name: saveOrUpdateConfig
    * Description: Method to save or update the configuration record in custom setting
    * Parameters: PunchhCalloutUtility.Configuration config
    * Returns: void
    * Ticket: Unknown
    */
    public static String saveOrUpdateConfig(PunchhCalloutUtility.Configuration config) {
        String configId = config.recId;
        Punch_Configuration__c configObj = new Punch_Configuration__c();

        if(String.isNotBlank(configId)) {
            configObj.Id = configId;
        }

        configObj.API_Endpoint__c = config.apiEndpoint;
        configObj.Admin_Key__c = config.adminKey;
        configObj.Client_Id__c = config.clientId;
        configObj.Punchh_URL__c = config.punchhUrl;
        configObj.Secret_Id__c = config.clientSecret;
        if(config.accessToken.length() > 255) {
            configObj.Access_Token__c = config.accessToken.substring(0, 250);
            configObj.Access_Token_Var2__c = config.accessToken.substring(250, config.accessToken.length());
        } else {
            configObj.Access_Token__c = config.accessToken;
        }
        
        configObj.Name = PunchConstants.CUSTOM_SETTING_NAME;
        upsert configObj;

        return configObj.Id;
    }

    // Wrapper Classes
    public class ConfigJson {
        @AuraEnabled 
        public Boolean status;
        @AuraEnabled 
        public String action;
        @AuraEnabled 
        public String body;
        @AuraEnabled 
        public String sfOrgId;
        @AuraEnabled 
        public String error;
        @AuraEnabled
        public Configuration configData;
        @AuraEnabled
        public String data;
        @AuraEnabled 
        public String message;
        @AuraEnabled 
        public Integer statusCode;
    }

    public class Configuration {
        @AuraEnabled
        public String adminKey;
        @AuraEnabled
        public String clientId;
        @AuraEnabled
        public String punchhUrl;
        @AuraEnabled
        public String clientSecret;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String accessToken;
        @AuraEnabled
        public String apiEndpoint;
        @AuraEnabled
        public String recId;
    }

    public class CreateSchedule {
        @AuraEnabled
        public Data data;
        @AuraEnabled
        public Boolean status;
        @AuraEnabled
        public String error;
    }

    public class ScheduleList {
        @AuraEnabled
        public List<Data> data;
        @AuraEnabled
        public Boolean status;
        @AuraEnabled
        public List<String> error;
        @AuraEnabled
        public Integer statusCode;
        @AuraEnabled 
        public String message;

    }

    public class FieldMapping {
        @AuraEnabled
        public String punchhAttr;
        @AuraEnabled
        public String salesforceAttr;
    }

    public class Data {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String configId;
        @AuraEnabled
        public List<FieldMapping> fieldMapping;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public String batchQuery;
        @AuraEnabled
        public String userType;
        @AuraEnabled
        public String frequency;
        @AuraEnabled
        public Integer interval;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String startTime;
        @AuraEnabled
        public String timezone;
        @AuraEnabled
        public String lastRun;
        @AuraEnabled
        public Boolean active;
        @AuraEnabled
        public Integer businessId;
        @AuraEnabled
        public String businessName;
        @AuraEnabled
        public Boolean isDeleted;
        @AuraEnabled
        public String storeNumber;
    }

    public class FieldMappingMetaData {
        @AuraEnabled
        public Boolean status;
        @AuraEnabled
        public List<Attributes> data;
        @AuraEnabled
        public List<Attributes> sfData;
        @AuraEnabled 
        public String message;
        @AuraEnabled 
        public Integer statusCode;
    }

    public class Attributes {
        @AuraEnabled
        public List<FieldMetadata> attributes;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String name;
    }

    public class FieldMetadata {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Boolean readonly;
        @AuraEnabled
        public Boolean required;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String inputType;
    }

    public class ResponseData {
        @AuraEnabled 
        public String data;
        @AuraEnabled 
        public String message;
        @AuraEnabled 
        public Integer statusCode;
    }

}