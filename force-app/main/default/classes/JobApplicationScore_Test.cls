@isTest
class JobApplicationScore_Test {
    @testSetup static void insertRecords(){
        Test.startTest();
        insert new Job_Position__c(Name='Test');
        Test.stopTest();
    }
    
    @isTest static void fetchRecords_list(){
        Test.startTest();
        JobApplicantController con = new JobApplicantController();
        JobApplicantController.RecordsList wrapper = new JobApplicantController.RecordsList();
        Job_Position__c parent = [SELECT Id from Job_Position__c];
        insert new Candidate_Application__c(Name='Child',Job_Position__c=parent.Id);
        wrapper = JobApplicantController.fetchRecords(parent.Id);
        System.assertEquals(1, wrapper.childList.size());
        Test.stopTest();
    }
}