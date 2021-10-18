public class RecordTypeController {
    
    @AuraEnabled 
    public static List<sObject> fetchRecordTypeList(){
        return [Select Id, Name From RecordType Where SobjectType = 'RecordType__c'];
    }
}