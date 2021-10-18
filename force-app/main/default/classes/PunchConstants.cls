/************************************************************************************************************************************
Class Name     :  PunchConstants
Purpose        :  Class to store all the constants used by Punchh application
History        :                                                            
-------                                                            
VERSION  AUTHOR                 DATE              	DETAIL                              	TICKET REFERENCE/ NO.
1.       Briskminds           2020-07-02         	Original Version                        Unknown
													
@Testsuite:  {ConfigurationCompController_Test}
*************************************************************************************************************************************/

public with sharing class PunchConstants {
    public static final String SAVE_TEST_ENDPOINT = '/servicecloud/configuration';  //Save and test connection end point
    public static final String SCHEDULE_LIST_ENDPOINT = '/servicecloud/schedule/list'; // Get schedule list endpoint
    public static final String CUSTOM_SETTING_NAME = 'Punchh Configuration'; // Custom Setting name
    public static final String SCHDEULE_ENDPOINT = '/servicecloud/schedule'; //Schedule delete and schedule history endpoint
    public static final String OBJECT_ENDPOINT = '/object';

    public static final String DATA_SUBMISSION_ERROR = 'The server encountered an error. Retry submitting after changing the data.'; //Error message
    public static final String FETCH_DATA_ERROR = 'The server encountered an error fetching the data. Refresh the page or retry later.';
    public static final String ALL_ERROR = 'The server is unreachable. Try again after some time.';

    public static final String CONFIGURATION_TEST_SUCESS_MESSAGE = 'Connection successful'; //Success message
    public static final String CONFIGURATION_TEST_FAIL_MESSAGE = 'Connection failed. Verify configuration details and try again.';
    public static final String CONFIGURATION_SAVE_SUCESS_MESSAGE = 'Configuration details are successfully saved'; //Success message
    public static final String CONFIGURATION_SAVE_FAIL_MESSAGE = 'Configuration details are not saved. Please try again.';

    public static final String SECHEDULE_CREATE_SUCCESS_MESSAGE = 'Schedule {ID} has been successfully created.';
    public static final String SECHEDULE_CREATE_ERROR_MESSAGE = 'An unexpected error occurred when creating the schedule. Please try again.';
    public static final String SECHEDULE_CREATE_VALIDATION_ERROR_MESSAGE = 'Please complete configuration in the Punchh dashboard before proceeding.';

    public static final String DELETE_SUCCESS_MESSAGE = 'Schedule {ID} has been successfully deleted.';
    public static final String DELETE_ERROR_MESSAGE = 'An unexpected error occurred when deleting the schedule. Please try again.';

    public static final String SECHEDULE_UPDATE_SUCCESS_MESSAGE = 'Schedule {ID} has been successfully updated.';
    public static final String SECHEDULE_UPDATE_ERROR_MESSAGE = 'An unexpected error occurred when updating the schedule. Please try again.';

    public static final String SECHEDULE_HISTORY_SUCCESS_MESSAGE = 'Schedule history succussfully fetch';
    public static final String SECHEDULE_HISTORY_ERROR_MESSAGE = 'Schedule history unsuccussfully fetch';

    public static final String FILED_MAPPING = 'Click here{link} to complete the field mapping section before proceeding.';

    public static final String[] OBJECT_TYPES = new String[]{'Contact'};
}