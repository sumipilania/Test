/************************************************************************************************************************************
Class Name     :  PunchCalloutController_Test
Purpose        :  Apex Test Class for PunchCalloutController and PunchCalloutUtility
History        :                                                            
-------                                                            
VERSION  AUTHOR                 DATE              	DETAIL                              	TICKET REFERENCE/ NO.
1.       Briskminds             2020-07-02         	Original Version                        Unknown
													
*************************************************************************************************************************************/

@isTest
private with sharing class PunchCalloutController_Test {

    /*
    * Method Name: insertCustomSetting
    * Description: setup method to create the test records
    * Parameters: none
    * Returns: none
    * Ticket: Unknown
    */
    @testSetup
    private static void insertCustomSetting() {
        insert new Punch_Configuration__c(
            Name = PunchConstants.CUSTOM_SETTING_NAME,
            Admin_Key__c = 'abhajhjuhjhu',
            Client_Id__c = 'kkkkjkkdfjdkfdkfkdmfkdfkd',
            Punchh_URL__c = 'https://saleforce.punchh.io',
            Secret_Id__c = 'jjjldlfjdfdfdfdfdfdf',
            API_Endpoint__c = 'https://goclient-sfservicecloud.punchh.io/api/v1',
            Access_Token__c = 'mnndjfjdfdfdfdfdf',
            Access_Token_Var2__c ='klklklkl'
        );

        List<Contact> conList = new List<Contact>();
        for(Integer i=1; i<50 ;i++){
            conList.add(new Contact(LastName ='test'+i));
        }
        insert conList;
    }

    /*
    * Method Name: validateOrSaveConnectionPositiveTest
    * Description: configuration positive test cases
    * Parameters: none
    * Returns: none
    * Ticket: Unknown
    */
    @isTest
    private static void validateOrSaveConnectionPositiveTest() {
        Punch_Configuration__c punchhObj = [SELECT Id FROM Punch_Configuration__c LIMIT 1];
        String inputJson = '{"status":true,"sfOrgId":null,"configData":{"recId":"'+punchhObj.Id+'","punchhUrl":"https://sfmarketcloud.punchh.io","id":null,"clientSecret":"2a097609760c71e067f22b99626be745e19b5300fe2c8e4f7544232b1c0ed3d0","clientId":"bf4fbaa9eeda9a035d2bc09d740236ca1669c87b7a7bbe6c4f2df920849788ff","apiEndpoint":"https://goclient-sfservicecloud.punchh.io/api/v1","adminKey":"NDNaDnyhtpbJ2LBfKuzb","accessToken":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJiaWQiOjksImNpZCI6IjVlZmFjNjRmZGMzZGI2MzUxMDYyZTNjMiIsImJfbmFtZSI6IlNGTUMgRGVtbyIsImFkbWluX2lkIjoiIiwiYnV1aWQiOiIiLCJ0ZW5hbnQiOiIiLCJzY28iOiIiLCJpc3MiOiJQdW5jaGgtc2FsZXNmb3JjZS1jbGllbnQifQ.4Sp8Q0jClz9_DE2sQf3rDpUScOEMGJF_mp-CxyuXOj7FlFwl1zpNHcreMn3CTDQoi2j9NKv3JbgtebqhZ4FPZA"},"body":"{\\"clientId\\":\\"bf4fbaa9eeda9a035d2bc09d740236ca1669c87b7a7bbe6c4f2df920849788ff\\",\\"clientSecret\\":\\"2a097609760c71e067f22b99626be745e19b5300fe2c8e4f7544232b1c0ed3d0\\",\\"punchhUrl\\":\\"https://sfmarketcloud.punchh.io\\",\\"adminKey\\":\\"NDNaDnyhtpbJ2LBfKuzb\\",\\"sfOrgId\\":\\"putOrgId\\",\\"action\\":\\"Save\\"}","action":"Save"}';
        String positiveResponseJson  = '{ "status": true, "data": "Configuration has been saved successfully." }';
        Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Authorization', 'accesstoken');
        
        SingleRequestMock validateReq = new SingleRequestMock(200, 'Complete', positiveResponseJson, responseHeaders);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        String validateOrSaveConnectionEndpoint = 'https://goclient-sfservicecloud.punchh.io/api/v1/servicecloud/configuration';
        endpoint2TestResp.put(validateOrSaveConnectionEndpoint, validateReq);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        PunchhCalloutUtility.ConfigJson response = PunchCalloutController.validateOrSaveConnection(inputJson);
        System.assertEquals(200, response.statusCode); 
        Test.stopTest();
    }

    /*
    * Method Name: validateOrSaveConnectionNegativeTest
    * Description: configuration negative test cases
    * Parameters: none
    * Returns: none
    * Ticket: Unknown
    */
    @isTest
    private static void validateOrSaveConnectionNegativeTest() {
        String inputJson = '{"status":true,"sfOrgId":null,"configData":{"recId":"123","punchhUrl":"https://sfmarketcloud.punchh.io","id":null,"clientSecret":"2a097609760c71e067f22b99626be745e19b5300fe2c8e4f7544232b1c0ed3d0","clientId":"bf4fbaa9eeda9a035d2bc09d740236ca1669c87b7a7bbe6c4f2df920849788ff","apiEndpoint":"https://goclient-sfservicecloud.punchh.io/api/v1","adminKey":"NDNaDnyhtpbJ2LBfKuzb","accessToken":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJiaWQiOjksImNpZCI6IjVlZmFjNjRmZGMzZGI2MzUxMDYyZTNjMiIsImJfbmFtZSI6IlNGTUMgRGVtbyIsImFkbWluX2lkIjoiIiwiYnV1aWQiOiIiLCJ0ZW5hbnQiOiIiLCJzY28iOiIiLCJpc3MiOiJQdW5jaGgtc2FsZXNmb3JjZS1jbGllbnQifQ.4Sp8Q0jClz9_DE2sQf3rDpUScOEMGJF_mp-CxyuXOj7FlFwl1zpNHcreMn3CTDQoi2j9NKv3JbgtebqhZ4FPZA"},"body":"{\\"clientId\\":\\"bf4fbaa9eeda9a035d2bc09d740236ca1669c87b7a7bbe6c4f2df920849788ff\\",\\"clientSecret\\":\\"2a097609760c71e067f22b99626be745e19b5300fe2c8e4f7544232b1c0ed3d0\\",\\"punchhUrl\\":\\"https://sfmarketcloud.punchh.io\\",\\"adminKey\\":\\"NDNaDnyhtpbJ2LBfKuzb\\",\\"sfOrgId\\":\\"putOrgId\\",\\"action\\":\\"Save\\"}","action":"Save"}';
        String negativeResponseJson = '{"status": false, "error": "Either Client ID or Client secret or the combination is incorrect. Verify and try again." }';
        Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Authorization', 'accesstoken');
        
        SingleRequestMock negative = new SingleRequestMock(401, 'Complete', negativeResponseJson, responseHeaders);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        String validateOrSaveConnectionEndpoint = 'https://goclient-sfservicecloud.punchh.io/api/v1/servicecloud/configuration';
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        endpoint2TestResp.put(validateOrSaveConnectionEndpoint, negative);
        Test.startTest(); 
        negative = new SingleRequestMock(500, 'error', negativeResponseJson, responseHeaders);
        endpoint2TestResp.put(validateOrSaveConnectionEndpoint, negative);
        PunchhCalloutUtility.ConfigJson response = PunchCalloutController.validateOrSaveConnection(inputJson);
        System.assertEquals(500, response.statusCode);
            
        negative = new SingleRequestMock(408, 'error', negativeResponseJson, responseHeaders);
        endpoint2TestResp.put(validateOrSaveConnectionEndpoint, negative);
        response = PunchCalloutController.validateOrSaveConnection(inputJson);
        System.assertEquals(408, response.statusCode);
            
        negative = new SingleRequestMock(406, 'error', negativeResponseJson, responseHeaders);
        endpoint2TestResp.put(validateOrSaveConnectionEndpoint, negative);
        response = PunchCalloutController.validateOrSaveConnection(inputJson);
        System.assertEquals(null, response.statusCode);
        Test.stopTest();
    }

    /*
    * Method Name: getScheduleListTest
    * Description: Get schedule list positive or negative test cases
    * Parameters: none
    * Returns: none
    * Ticket: Unknown
    */
    @isTest
    private static void getScheduleListTest() {
        String positiveNegativeJsonResponse = '{ "status": true, "data": [ { "id": "5efe06c23d8dd462a013010e", "configId": "5eea20b882b82d8651c586f1", "fieldMapping": [ { "punchhAttr": "external_source_id", "salesforceAttr": "Id" }, { "punchhAttr": "email", "salesforceAttr": "Email" }, { "punchhAttr": "first_name", "salesforceAttr": "FirstName" }, { "punchhAttr": "last_name", "salesforceAttr": "LastName" }, { "punchhAttr": "phone", "salesforceAttr": "Phone" }, { "punchhAttr": "birthday", "salesforceAttr": "Birthdate" }, { "punchhAttr": "zipcode", "salesforceAttr": "OtherPostalCode" } ], "name": "Schedule 1", "objectName": "Contact", "batchQuery": "SELECT Contact.Id,Contact.Email, Contact.FirstName, Contact.LastName, Contact.Phone, Contact.Birthdate, Contact.OtherPostalCode FROM Contact", "userType": "loyalty", "frequency": "daily", "interval": 1, "startDate": "2021-07-26", "startTime": "04:10 PM", "timezone": "America/Los_Angeles", "lastRun": "0001-01-01T00:00:00Z", "active": true, "businessId": 9, "businessName": "SFMC Demo", "isDeleted": false } ] }';
        SingleRequestMock positive = new SingleRequestMock(200, 'data', positiveNegativeJsonResponse, null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        String getScheduleListEndpoint = 'https://goclient-sfservicecloud.punchh.io/api/v1/servicecloud/schedule/list';
        endpoint2TestResp.put(getScheduleListEndpoint, positive);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();

        //Positive
        PunchhCalloutUtility.ScheduleList response1 = PunchCalloutController.getScheduleList();
        System.assertEquals(200, response1.statusCode);

        //Negative
        SingleRequestMock negative = new SingleRequestMock(401, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(getScheduleListEndpoint, negative);
        PunchhCalloutUtility.ScheduleList response2 = PunchCalloutController.getScheduleList();
        System.assertEquals(401, response2.statusCode);

        //Negative
        negative = new SingleRequestMock(500, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(getScheduleListEndpoint, negative);
        PunchhCalloutUtility.ScheduleList response3 = PunchCalloutController.getScheduleList();
        System.assertEquals(500, response3.statusCode);

        //Negative
        negative = new SingleRequestMock(408, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(getScheduleListEndpoint, negative);
        PunchhCalloutUtility.ScheduleList response4 = PunchCalloutController.getScheduleList();
        System.assertEquals(408, response4.statusCode);

        //Negative
        negative = new SingleRequestMock(405, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(getScheduleListEndpoint, negative);
        PunchhCalloutUtility.ScheduleList response5 = PunchCalloutController.getScheduleList();
        System.assertEquals(null, response5.statusCode);
        Test.stopTest();
    }

    /*
    * Method Name: deleteScheduleTest
    * Description: Delete schedule positive or negative cases
    * Parameters: schedule id
    * Returns: String
    * Ticket: Unknown
    */
    @isTest
    private static void deleteScheduleTest() {
        String positiveNegativeJsonResponse = '{ "status": true, "data": "deleted successfully" }';
        SingleRequestMock positive = new SingleRequestMock(200, 'Complete', positiveNegativeJsonResponse, null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        String deleteListEndpoint = 'https://goclient-sfservicecloud.punchh.io/api/v1/servicecloud/schedule/123';
        endpoint2TestResp.put(deleteListEndpoint, positive);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();

        //Positive
        PunchhCalloutUtility.ResponseData response = PunchCalloutController.deleteSchedule('123', 'test');
        System.assertEquals(200, response.statusCode);

        //Negative
        SingleRequestMock negative = new SingleRequestMock(401, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(deleteListEndpoint, negative);
        PunchhCalloutUtility.ResponseData response1 = PunchCalloutController.deleteSchedule('123', 'test');
        System.assertEquals(401, response1.statusCode);

        //Negative
        negative = new SingleRequestMock(500, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(deleteListEndpoint, negative);
        PunchhCalloutUtility.ResponseData response2 = PunchCalloutController.deleteSchedule('123', 'test');
        System.assertEquals(500, response2.statusCode);

        //Negative
        negative = new SingleRequestMock(408, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(deleteListEndpoint, negative);
        PunchhCalloutUtility.ResponseData response3 = PunchCalloutController.deleteSchedule('123', 'test');
        System.assertEquals(408, response3.statusCode);

        //Negative
        negative = new SingleRequestMock(406, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(deleteListEndpoint, negative);
        PunchhCalloutUtility.ResponseData respons4 = PunchCalloutController.deleteSchedule('123', 'test');
        System.assertEquals(null, respons4.statusCode);
        Test.stopTest();
    }

    /*
    * Method Name: getPunchAndSfObjectsTest
    * Description: Punch object positive or negative cases
    * Parameters: schedule id
    * Returns: String
    * Ticket: Unknown
    */
    @isTest
    private static void getPunchAndSfObjectsTest() {
        String getPunchAndSfObjectsListEndpoint = 'https://goclient-sfservicecloud.punchh.io/api/v1/servicecloud/schedule/object';
        String positiveNegativeJsonResponse = '{"status":true,"data":[{"name":"loyalty","label":"Loyalty","attributes":[{"name":"external_source_id","label":"SalesforceUser ID","type":"string","required":true,"readonly":true,"inputType":"select"},{"name":"email","label":"Email ID","type":"string","required":true,"readonly":false,"inputType":"select"},{"name":"first_name","label":"First Name","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"last_name","label":"Last Name","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"birthday","label":"Birthday","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"anniversary","label":"Anniversary","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"phone","label":"Phone","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"unsubscribed","label":"Unsubscribed to Notifications?","type":"boolean","required":false,"readonly":false,"inputType":"select"},{"name":"secondary_email","label":"Secondary Email","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"city","label":"City","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"zip_code","label":"Zip Code","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"address_line1","label":"Address Line 1","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"address_line2","label":"Address Line 2","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"state","label":"State","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"office_phone","label":"Office Phone","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"country","label":"Country","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"cell_phone","label":"Cell Phone","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"gender","label":"Gender","type":"string","required":false,"readonly":false,"inputType":"select"}]},{"name":"eclub","label":"eClub","attributes":[{"name":"external_source_id","label":"SalesforceUser ID","type":"string","required":true,"readonly":true,"inputType":"select"},{"name":"store_number","label":"Store Number","type":"string","required":true,"readonly":false,"inputType":"text"},{"name":"email","label":"Email ID","type":"string","required":true,"readonly":false,"inputType":"select"},{"name":"first_name","label":"First Name","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"last_name","label":"Last Name","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"phone","label":"Phone Number","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"address_line1","label":"Address","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"state","label":"State","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"zip_code","label":"Zip Code","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"birthday","label":"Birthday","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"title","label":"Title","type":"string","required":false,"readonly":false,"inputType":"select"},{"name":"gender","label":"Gender","type":"string","required":false,"readonly":false,"inputType":"select"}]}]}';
        SingleRequestMock positive = new SingleRequestMock(200, 'Complete', positiveNegativeJsonResponse, null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(getPunchAndSfObjectsListEndpoint, positive);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();

        //Positive
        PunchhCalloutUtility.FieldMappingMetaData response = PunchCalloutController.getPunchAndSfObjects();
        System.assertEquals(200, response.statusCode);

        //Negative
        SingleRequestMock negative = new SingleRequestMock(401, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(getPunchAndSfObjectsListEndpoint, negative);
        response = PunchCalloutController.getPunchAndSfObjects();
        System.assertEquals(401, response.statusCode);

        //Negative
        negative = new SingleRequestMock(408, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(getPunchAndSfObjectsListEndpoint, negative);
        response = PunchCalloutController.getPunchAndSfObjects();
        System.assertEquals(408, response.statusCode);
        Test.stopTest();
    }

    /*
    * Method Name: createScheduleTest
    * Description: Create schedule positive or negative cases
    * Parameters: schedule id
    * Returns: String
    * Ticket: Unknown
    */    
    @isTest
    private static void createScheduleTest() {
        String createScheduleListEndpoint = 'https://goclient-sfservicecloud.punchh.io/api/v1/servicecloud/schedule';
        String positiveNegativeJsonResponse = '{"status": false, "error": "Schedule not successfully created" }';
        SingleRequestMock positive = new SingleRequestMock(200, 'Complete', positiveNegativeJsonResponse, null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(createScheduleListEndpoint, positive);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        String body = '{"id":"123"}';

        //Positive
        PunchhCalloutUtility.ResponseData response = PunchCalloutController.createSchedule(body);
        System.assertEquals(200, response.statusCode);

        SingleRequestMock negative = new SingleRequestMock(401, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(createScheduleListEndpoint, negative);
        response = PunchCalloutController.createSchedule(body);
        System.assertEquals(401, response.statusCode);
        
        //Negative
        negative = new SingleRequestMock(500, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(createScheduleListEndpoint, negative);
        response = PunchCalloutController.createSchedule(body);
        System.assertEquals(500, response.statusCode);

        //Negative
        negative = new SingleRequestMock(408, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(createScheduleListEndpoint, negative);
        response = PunchCalloutController.createSchedule(body);
        System.assertEquals(408, response.statusCode);

        //Negative
        negative = new SingleRequestMock(406, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(createScheduleListEndpoint, negative);
        response = PunchCalloutController.createSchedule(body);
        System.assertEquals(null, response.statusCode);
        Test.stopTest();
        
    }

    /*
    * Method Name: getScheduleHistoryTest
    * Description: Schedule history positive or negative cases
    * Parameters: schedule id
    * Returns: String
    * Ticket: Unknown
    */   
    @isTest
    private static void getScheduleHistoryTest() {
        String getScheduleHistoryEndpoint = 'https://goclient-sfservicecloud.punchh.io/api/v1/servicecloud/schedule/123/batch';
        String positiveNegativeJsonResponse = '{"status": false, "error": "Schedule not successfully created" }';
        SingleRequestMock positive = new SingleRequestMock(200, 'Complete', positiveNegativeJsonResponse, null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(getScheduleHistoryEndpoint, positive);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();

        //Positive
        PunchhCalloutUtility.ResponseData response = PunchCalloutController.getScheduleHistory('123');
        System.assertEquals(200, response.statusCode);

        //Negative
        SingleRequestMock negative = new SingleRequestMock(401, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(getScheduleHistoryEndpoint, negative);
        response = PunchCalloutController.getScheduleHistory('123');
        System.assertEquals(401, response.statusCode);
        
        //Negative
        negative = new SingleRequestMock(500, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(getScheduleHistoryEndpoint, negative);
        response = PunchCalloutController.getScheduleHistory('123');
        System.assertEquals(500, response.statusCode);

        //Negative
        negative = new SingleRequestMock(408, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(getScheduleHistoryEndpoint, negative);
        response = PunchCalloutController.getScheduleHistory('123');
        System.assertEquals(408, response.statusCode);

        //Negative
        negative = new SingleRequestMock(406, 'error', positiveNegativeJsonResponse, null);
        endpoint2TestResp.put(getScheduleHistoryEndpoint, negative);
        response = PunchCalloutController.getScheduleHistory('123');
        System.assertEquals(null, response.statusCode);
        Test.stopTest();
    }

    /*
    * Method Name: getSfRecordCountOrGetConfigurationTest
    * Description: Use aggregate query
    * Parameters: schedule id
    * Returns: String
    * Ticket: Unknown
    */  
    @isTest
    private static void getSfRecordCountOrGetConfigurationTest(){
        Test.startTest();
        //getSfRecordCount
        String query = 'SELECT COUNT() FROM Contact';
        Integer response = PunchCalloutController.getSfRecordCount(query);

         // getConfiguration
         String configResponse = PunchCalloutController.getConfiguration();
         PunchhCalloutUtility.ConfigJson config = (PunchhCalloutUtility.ConfigJson)JSON.deserialize(configResponse,  PunchhCalloutUtility.ConfigJson.class);
         System.assertEquals(true, config.status); 
        Test.stopTest();
    }

}