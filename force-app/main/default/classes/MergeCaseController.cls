public with sharing class MergeCaseController {
    @AuraEnabled
    public static CaseRecordWrapper fetchRecord(){
      List<RecordWrapper> recordData = new List<RecordWrapper>();
      CaseRecordWrapper csObj = new CaseRecordWrapper();
        String fetchField = 'CaseNumber,OwnerId,ContactId,CreatedById,CreatedDate,ClosedDate,Priority,Subject,Type,AccountId';
        List<String> fieldList = fetchField.split(',');
        System.debug('fieldList='+fieldList);
        Map<String, Schema.SObjectField> sObjectfields = Schema.getGlobalDescribe().get('Case').getDescribe().SObjectType.getDescribe().fields.getMap();
        recordData.add(new RecordWrapper('', '', false));
        for(Schema.SObjectField field : sObjectfields.values())            
        {    
            
            Schema.DescribeFieldResult fieldResult = field.getDescribe();                    
            if(fieldList.contains(fieldResult.getName())){    
              System.debug(fieldResult.getName()); 
              recordData.add(new RecordWrapper(fieldResult.getName(), fieldResult.getLabel(), fieldResult.isUpdateable()));

            }
        }  
            csObj.headerList = recordData;
            csObj.recordList = Database.query('SELECT '+fetchField+' FROM Case');
            return csObj;
        }
        
        @AuraEnabled
        public static String mergeRecords(Case updateCaseObj, List<Case> deleteCaseObjList){
            System.debug('updateCaseObj='+updateCaseObj);
            System.debug('deleteCaseObjList='+deleteCaseObjList);
            System.debug('len='+deleteCaseObjList.size());
            if(updateCaseObj != null){
                update updateCaseObj;
            }
            if(deleteCaseObjList.size() > 0){
                delete deleteCaseObjList;
            }
            return 'Success';
        }
    public class CaseRecordWrapper{
        @AuraEnabled public List<Case> recordList;
        @AuraEnabled public List<RecordWrapper> headerList;
    } 
     public class RecordWrapper{
        @AuraEnabled public String fieldApiName;
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public Boolean isEditable;
      
         RecordWrapper(String fieldApiName, String fieldLabel, Boolean isEditable){
            this.fieldApiName = fieldApiName;
            this.fieldLabel = fieldLabel;   
            this.isEditable = isEditable;
        }
         
    }
        
}