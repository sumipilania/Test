/************************************************************************************************************************************
Class Name     :  MultiRequestMock
Purpose        :  Mock class to handle the multiple requests for the test classes
History        :                                                            
-------                                                            
VERSION  AUTHOR                 DATE              	DETAIL                              	TICKET REFERENCE/ NO.
1.       Briskminds             2020-07-02         	Original Version                        Unknown
													
*************************************************************************************************************************************/

public with sharing class MultiRequestMock implements HttpCalloutMock {
    
    Map<String, HttpCalloutMock> requests;
 
    /*
    * Constrcutor: MultiRequestMock
    * Description: Parameter constructor to store map enpoint with multiple request
    * Parameters: requests
    * Returns: none
    * Ticket: Unknown
    */
    public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }
 
    /*
    * Method Name: respond
    * Description: Check callout is wrong or not
    * Parameters: req
    * Returns: HTTPResponse
    * Ticket: Unknown
    */
    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        } else {
            return new HttpResponse();
        }
    }
 
    /*
    * Method Name: addRequestMock
    * Description: Method to add the mock request
    * Parameters: String url, HttpCalloutMock mock
    * Returns: HTTPResponse
    * Ticket: Unknown
    */
    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}