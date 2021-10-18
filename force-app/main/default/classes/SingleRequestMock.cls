/************************************************************************************************************************************
Class Name     :  SingleRequestMock
Purpose        :  Mock class for the test classes
History        :                                                            
-------                                                            
VERSION  AUTHOR                 DATE              	DETAIL                              	TICKET REFERENCE/ NO.
1.       Briskminds             2020-07-02         	Original Version                        Unknown
													
*************************************************************************************************************************************/
@isTest
public with sharing class SingleRequestMock implements HttpCalloutMock {
        
    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;
    
    /*
    * Constrcutor: SingleRequestMock
    * Description: Set all dummy request and response 
    * Parameters: code, status, body, responseHeader
    * Returns: none
    * Ticket: Unknown
    */
    public SingleRequestMock(Integer code, String status, String body,
                                        Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
        this.responseHeaders = responseHeaders;
    }

    /*
    * Method Name: respond
    * Description: Get dummy response for according to request
    * Parameters: req
    * Returns: HTTPResponse
    * Ticket: Unknown
    */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        resp.setStatus(status);
        if (bodyAsBlob != null) {
            resp.setBodyAsBlob(bodyAsBlob);
        } else {
            resp.setBody(bodyAsString);
        }

        if (responseHeaders != null) {
                for (String key : responseHeaders.keySet()) {
                    resp.setHeader(key, responseHeaders.get(key));
                }
        }
        return resp;
    }
}