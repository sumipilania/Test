public class CaseRecordTypeController {
    @AuraEnabled 
    public static List<sObject> fetchRecordTypeList(){
        try {
            return [Select Id, Name From RecordType Where SobjectType = 'Contact'];
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
    }
    @AuraEnabled 
    public static Case fetchCaseRecord(Id caseId){
        System.debug('caseId=='+caseId);
        try {
            return [Select ContactEmail, CaseNumber From Case Where Id = :caseId limit 1];
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
    }
}