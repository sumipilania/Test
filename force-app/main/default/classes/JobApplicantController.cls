public class JobApplicantController {
    
    @AuraEnabled
    public static RecordsList fetchRecords(Id parentRecId){
        RecordsList recWrapperList = new RecordsList();
        //Parent Records List
        recWrapperList.parentList = [SELECT Id,Name,Exprience__c,Qualification__c,Spoken_Language__c,Technical_Language__c,(SELECT Id, Name,Exprience__c,Qualification__c,Spoken_Language__c,Technical_Language__c FROM Candidate_Applications__r) FROM Job_Position__c WHERE Id = :parentRecId];
		 //Child Records List
        recWrapperList.childList = recWrapperList.parentList[0].Candidate_Applications__r;
        return recWrapperList;
    }
    public class RecordsList{
        @AuraEnabled public List<Job_Position__c> parentList;
        @AuraEnabled public List<Candidate_Application__c> childList;
    }
}