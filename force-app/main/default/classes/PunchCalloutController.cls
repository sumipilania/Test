/************************************************************************************************************************************
Class Name     :  PunchCalloutController
Purpose        :  Apex controller for the LWC comp ConfigurationComp
History        :                                                            
-------                                                            
VERSION  AUTHOR                 DATE              	DETAIL                              	TICKET REFERENCE/ NO.
1.       Briskminds             2020-07-02         	Original Version                        Unknown
													
@Testsuite:  {PunchCalloutController_Test}
*************************************************************************************************************************************/

public with sharing class PunchCalloutController {

    /*
    * Method Name: validateOrSaveConnection
    * Description: A signle method to validate and Save the Punchh connection
    * Parameters: 
    * Returns: String
    * Ticket: Unknown
    */
    @AuraEnabled
    public static PunchhCalloutUtility.ConfigJson validateOrSaveConnection(String inputJson) {
        try {
            PunchhCalloutUtility.ConfigJson configResult = new PunchhCalloutUtility.ConfigJson();
            if(String.isNotBlank(inputJson)) {

                PunchhCalloutUtility.ConfigJson config = (PunchhCalloutUtility.ConfigJson)JSON.deserialize(inputJson, PunchhCalloutUtility.ConfigJson.class);
                Map<String, String> headerMap = new Map<String, String>();
                config.body = config.body.replace('putOrgId', UserInfo.getOrganizationId());
                String endPoint = config.configData.apiEndpoint + PunchConstants.SAVE_TEST_ENDPOINT;  
                String method = 'POST';
                headerMap.put('Content-Type', 'application/json');
                HttpResponse res = PunchhCalloutUtility.genericCallout(endPoint, method, null, config.body, headerMap);
                configResult = new PunchhCalloutUtility.ConfigJson();

                if(res.getBody() != null && res.getStatusCode() == 200) {
                    configResult = (PunchhCalloutUtility.ConfigJson)JSON.deserialize(res.getBody(), PunchhCalloutUtility.ConfigJson.class);
                    configResult.statusCode = 200;
                    if(configResult.status) {
                        configResult.configData = config.configData;
                        configResult.message = PunchConstants.CONFIGURATION_TEST_SUCESS_MESSAGE;
                            if(config.action.equalsIgnoreCase('Save') && configResult != null && configResult.status && res.getHeader('Authorization') != null) {
                                configResult.configData.accessToken = res.getHeader('Authorization');
                                configResult.configData.recId = PunchhCalloutUtility.saveOrUpdateConfig(configResult.configData);
                                configResult.message = PunchConstants.CONFIGURATION_SAVE_SUCESS_MESSAGE;
                            }
                            configResult.configData.accessToken = null;
                    } else {
                        return configResult;
                    }
                } else if(res.getStatusCode() == 500 || res.getStatusCode() == 404) {
                    configResult.statusCode = 500;
                    configResult.message = PunchConstants.DATA_SUBMISSION_ERROR;
                } else if(res.getStatusCode() == 408) {
                    configResult.statusCode = 408;
                    configResult.message = PunchConstants.All_ERROR;
                } else {
                    configResult.message = config.action.equalsIgnoreCase('Save') ? PunchConstants.CONFIGURATION_SAVE_FAIL_MESSAGE : PunchConstants.CONFIGURATION_TEST_FAIL_MESSAGE;
                } 
            }
            return configResult;

        } catch(exception e) {
            String errorMsg = e.getMessage();
            if(errorMsg.containsIgnoreCase(PunchConstants.SAVE_TEST_ENDPOINT)) {
                errorMsg =  e.getMessage().replace(PunchConstants.SAVE_TEST_ENDPOINT, ' ');
            }
            throw new AuraHandledException(errorMsg);
        }        
    }    
    
    /*
    * Method Name: getConfiguration
    * Description: Method to get the configuration record from custom setting
    * Parameters: none
    * Returns: String
    * Ticket: Unknown
    */
    @AuraEnabled
    public static String getConfiguration() {
        try {
            PunchhCalloutUtility.ConfigJson cj = new PunchhCalloutUtility.ConfigJson();
            PunchhCalloutUtility.Configuration data = new PunchhCalloutUtility.Configuration();
            for(Punch_Configuration__c con : [SELECT Id, Admin_Key__c, Client_Id__c, Punchh_URL__c, 
                                                Secret_Id__c, API_Endpoint__c, Access_Token__c, 
                                                Access_Token_Var2__c FROM Punch_Configuration__c LIMIT 1]) {
                data.recId = con.Id;
                data.apiEndpoint = con.API_Endpoint__c;
                data.adminKey = con.Admin_Key__c;
                data.clientId = con.Client_Id__c;
                data.punchhUrl = con.Punchh_URL__c;
                data.clientSecret = con.Secret_Id__c;
            }
            cj.configData = data;
            cj.status = (data.recId == null) ? false : true;
            return JSON.serialize(cj);
        } catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * Method Name: getScheduleList
    * Description: Method to get schedule list
    * Parameters: none
    * Returns: Object
    * Ticket: Unknown
    */
    @AuraEnabled
    public static PunchhCalloutUtility.ScheduleList getScheduleList() {
        try {
            PunchhCalloutUtility.ScheduleList scheduleList = new PunchhCalloutUtility.ScheduleList(); 
            Punch_Configuration__c getConfigurationLocal = Punch_Configuration__c.getValues(PunchConstants.CUSTOM_SETTING_NAME);
            
            if(getConfigurationLocal != null) {
                Map<String, String> headerMap = new Map<String, String>();
                String endPoint = getConfigurationLocal.API_Endpoint__c + PunchConstants.SCHEDULE_LIST_ENDPOINT;  
                String method = 'GET';
                headerMap.put('Content-Type', 'application/json');
                headerMap.put('Authorization', 'Bearer ' + PunchhCalloutUtility.getAccessToken(getConfigurationLocal));

                HttpResponse res = PunchhCalloutUtility.genericCallout(endPoint, method, null, null, headerMap);
                if(res.getBody() != null && res.getStatusCode() == 200) {
                    scheduleList = (PunchhCalloutUtility.ScheduleList)JSON.deserialize(res.getBody(),  PunchhCalloutUtility.ScheduleList.class);
                    scheduleList.statusCode = 200;
                } else if(res.getStatusCode() == 401) {
                    scheduleList.statusCode = 401;
                } else if(res.getStatusCode() == 500) {
                    scheduleList.statusCode = 500;
                    scheduleList.message = PunchConstants.FETCH_DATA_ERROR;
                } else if(res.getStatusCode() == 408) {
                    scheduleList.statusCode = 408;
                    scheduleList.message = PunchConstants.All_ERROR;
                } else {
                    scheduleList.message = PunchConstants.FETCH_DATA_ERROR;
                }
            }
            return scheduleList;
        } catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }

    /*
    * Method Name: deleteSchedule
    * Description: Method to delete schedule
    * Parameters: scheduleid, scheduleName
    * Returns: String, String
    * Ticket: Unknown
    */
    @AuraEnabled
    public static PunchhCalloutUtility.ResponseData deleteSchedule(String scheduleId, String scheduleName) {
        PunchhCalloutUtility.ResponseData response; 
        try {
            if(String.isNotBlank(scheduleId) && String.isNotBlank(scheduleName)) {
                response = new PunchhCalloutUtility.ResponseData();
                Punch_Configuration__c getConfigurationLocal = Punch_Configuration__c.getValues(PunchConstants.CUSTOM_SETTING_NAME);
                
                if(getConfigurationLocal != null) {
                    Map<String, String> headerMap = new Map<String, String>();
                    String endPoint = getConfigurationLocal.API_Endpoint__c + PunchConstants.SCHDEULE_ENDPOINT + '/' + scheduleId;  
                    String method = 'DELETE';
                    headerMap.put('Content-Type', 'application/json');
                    headerMap.put('Authorization', 'Bearer ' + PunchhCalloutUtility.getAccessToken(getConfigurationLocal));
                    HttpResponse res = PunchhCalloutUtility.genericCallout(endPoint, method, null, null, headerMap);
                    if(String.isNotBlank(res.getBody()) && res.getStatusCode() == 200) {
                        response.statusCode = 200;
                        response.data = res.getBody();
                        response.message = PunchConstants.DELETE_SUCCESS_MESSAGE.replace('{ID}', '"'+ scheduleName +'"');
                    } else if(res.getStatusCode() == 401) {
                        response.statusCode = 401;
                    } else if(res.getStatusCode() == 500) {
                        response.statusCode = 500;
                        response.message = PunchConstants.FETCH_DATA_ERROR;
                    } else if(res.getStatusCode() == 408) {
                        response.statusCode = 408;
                        response.message = PunchConstants.All_ERROR;
                    } else {
                        response.message = PunchConstants.DELETE_ERROR_MESSAGE;
                    }
                } 
            }
            
            return response;
        } catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * Method Name: getPunchAndSfObjects
    * Description: Method to get fields from punchh and salesforfce
    * Parameters: none
    * Returns: String
    * Ticket: Unknown
    */
    @AuraEnabled
    public static PunchhCalloutUtility.FieldMappingMetaData getPunchAndSfObjects() {
        try {
            PunchhCalloutUtility.FieldMappingMetaData response = new PunchhCalloutUtility.FieldMappingMetaData(); 
            Punch_Configuration__c getConfigurationLocal = Punch_Configuration__c.getValues(PunchConstants.CUSTOM_SETTING_NAME);
            
            if(getConfigurationLocal != null) {
                Map<String, String> headerMap = new Map<String, String>();
                String endPoint = getConfigurationLocal.API_Endpoint__c + PunchConstants.SCHDEULE_ENDPOINT + PunchConstants.OBJECT_ENDPOINT;  
                String method = 'GET';
                headerMap.put('Content-Type', 'application/json');
                headerMap.put('Authorization', 'Bearer ' + PunchhCalloutUtility.getAccessToken(getConfigurationLocal));
                HttpResponse res = PunchhCalloutUtility.genericCallout(endPoint, method, null, null, headerMap);
                if(String.isNotBlank(res.getBody()) && res.getStatusCode() == 200) {
                    response = (PunchhCalloutUtility.FieldMappingMetaData)JSON.deserialize(res.getBody(),  PunchhCalloutUtility.FieldMappingMetaData.class);
                    response.sfData = PunchhCalloutUtility.describeObjects();
                    response.statusCode = 200;
                } else if(res.getStatusCode() == 401) {
                    response.statusCode = 401;
                } else if(res.getStatusCode() == 408) {
                    response.statusCode = 408;
                    response.message = PunchConstants.All_ERROR;
                } else {
                    response.message = PunchConstants.FETCH_DATA_ERROR;
                } 
            } 
            return response;
        } catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * Method Name: getSfCount
    * Description: salesforce record count
    * Parameters: query
    * Returns: Integer
    * Ticket: Unknown
    */
    @AuraEnabled
    public static Integer getSfRecordCount(String query) {
        Integer count;
        if(String.isNotBlank(query)) {
            query = query + ' WITH SECURITY_ENFORCED';
            count =  Database.countQuery(query);
        }
        return count;
    }

    /*
    * Method Name: createSchedule
    * Description: create schedule record
    * Parameters: requestJson
    * Returns: String
    * Ticket: Unknown
    */
    @AuraEnabled
    public static PunchhCalloutUtility.ResponseData createSchedule(String requestJson) {
        PunchhCalloutUtility.ResponseData response = new PunchhCalloutUtility.ResponseData(); 
        Boolean updateOrCreate = false;

        if(String.isNotBlank(requestJson)) {
            try {
                Punch_Configuration__c getConfigurationLocal = Punch_Configuration__c.getValues(PunchConstants.CUSTOM_SETTING_NAME);
                if(getConfigurationLocal != null) {
                    Map<String, String> headerMap = new Map<String, String>();
                    String endPoint = getConfigurationLocal.API_Endpoint__c + PunchConstants.SCHDEULE_ENDPOINT;
                    String method = 'POST';
                    if(requestJson.contains('"id":')) {
                        method = 'PUT';
                        updateOrCreate = true;
                    }
                    String strBody = requestJson;
                    headerMap.put('Content-Type', 'application/json');
                    headerMap.put('Authorization', 'Bearer ' + PunchhCalloutUtility.getAccessToken(getConfigurationLocal));
                    HttpResponse res = PunchhCalloutUtility.genericCallout(endPoint, method, null, strBody, headerMap);
                    
                    if(String.isNotBlank(res.getBody()) && (res.getStatusCode() == 200 || res.getStatusCode() == 400)) {
                        PunchhCalloutUtility.CreateSchedule csObj = (PunchhCalloutUtility.CreateSchedule)JSON.deserialize(res.getBody(),  PunchhCalloutUtility.CreateSchedule.class);
                        response.data = res.getBody();
                        response.statusCode = 200;
                        if(csObj.status) {
                            response.message = updateOrCreate ? PunchConstants.SECHEDULE_UPDATE_SUCCESS_MESSAGE.replace('{ID}', '"' +csObj.data.name +'"') : PunchConstants.SECHEDULE_CREATE_SUCCESS_MESSAGE.replace('{ID}', '"' +csObj.data.name +'"');
                        } else {
                            response.message = csObj.error;
                        }
                    } else if(res.getStatusCode() == 401) {
                        response.statusCode = 401;
                    } else if(res.getStatusCode() == 500) {
                        response.statusCode = 500;
                        response.message = PunchConstants.FETCH_DATA_ERROR;
                    } else if(res.getStatusCode() == 408) {
                        response.statusCode = 408;
                        response.message = PunchConstants.All_ERROR;
                    } else {
                        response.message = updateOrCreate ? PunchConstants.SECHEDULE_UPDATE_ERROR_MESSAGE : PunchConstants.SECHEDULE_CREATE_ERROR_MESSAGE;
                    }
                } 
               
            } catch(exception e) {
                throw new AuraHandledException(e.getMessage());
            } 
        }
        return response;
    }

    /*
    * Method Name: getScheduleHistory
    * Description: Fetch the schedule history records
    * Parameters: String scheduleId
    * Returns: ResponseData
    * Ticket: Unknown
    */
    @AuraEnabled
    public static PunchhCalloutUtility.ResponseData getScheduleHistory(String scheduleId) {
        PunchhCalloutUtility.ResponseData response = new PunchhCalloutUtility.ResponseData(); 
        
        if(String.isNotBlank(scheduleId)) {
            try {
                Punch_Configuration__c getConfigurationLocal = Punch_Configuration__c.getValues(PunchConstants.CUSTOM_SETTING_NAME);
                
                if(getConfigurationLocal != null) {
                    Map<String, String> headerMap = new Map<String, String>();
                    String endPoint = getConfigurationLocal.API_Endpoint__c + PunchConstants.SCHDEULE_ENDPOINT + '/' + scheduleId + '/batch';  
                    String method = 'GET';
                    headerMap.put('Content-Type', 'application/json');
                    headerMap.put('Authorization', 'Bearer ' + PunchhCalloutUtility.getAccessToken(getConfigurationLocal));
                    HttpResponse res = PunchhCalloutUtility.genericCallout(endPoint, method, null, null, headerMap);
                    if(res.getStatusCode() == 200) {
                        response.data = res.getBody();
                        response.statusCode = 200;
                        response.message = PunchConstants.SECHEDULE_HISTORY_SUCCESS_MESSAGE;
                    } else if(res.getStatusCode() == 401) {
                        response.statusCode = 401;
                    } else if(res.getStatusCode() == 500) {
                        response.statusCode = 500;
                        response.message = PunchConstants.FETCH_DATA_ERROR;
                    } else if(res.getStatusCode() == 408) {
                        response.statusCode = 408;
                        response.message = PunchConstants.All_ERROR;
                    } else {
                        response.message = PunchConstants.SECHEDULE_HISTORY_ERROR_MESSAGE;
                    }
                } 
            } catch(exception e) {
                throw new AuraHandledException(e.getMessage());
            } 
        }
        return response;
    }
}