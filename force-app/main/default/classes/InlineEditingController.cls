public with sharing class InlineEditingController {

    @AuraEnabled
    public static RecordWrapper fetchObjectWrapper(String allFields, String objectName){
      List<HeaderWrapper> headerList = new List<HeaderWrapper>();
      RecordWrapper recWrpperObj = new RecordWrapper();
    //  System.debug('allFields='+allFields);
    //  System.debug('objectName='+objectName);
      if(String.isNotBlank(allFields) && String.isNotBlank(objectName)){
        // String fetchField = 'CaseNumber,OwnerId,ContactId,CreatedById,CreatedDate,ClosedDate,Priority,Subject,Type,AccountId';
            List<String> fieldList = allFields.split(',');
         //   System.debug('fieldList='+fieldList);
            Map<String, Schema.SObjectField> sObjectfields = Schema.getGlobalDescribe().get(objectName).getDescribe().SObjectType.getDescribe().fields.getMap();
            for(Schema.SObjectField field : sObjectfields.values()) {    
                Schema.DescribeFieldResult fieldResult = field.getDescribe();   
              //  System.debug('data==='+fieldResult.getName());     
                if(fieldList.contains(fieldResult.getName())){ 
                // System.debug(fieldResult.getName()); 
                 Boolean fieldType =String.valueOf(fieldResult.getType()).equals('REFERENCE');
                 String refFieldName;
                 if(fieldType){
                     System.debug('getRelationshipName='+fieldResult.getRelationshipName());
                     refFieldName = fieldResult.getRelationshipName() + '.Name';
                     allFields = allFields+','+refFieldName;

                 }
                 headerList.add(new HeaderWrapper(fieldResult.getName(), fieldResult.getLabel(), fieldResult.isUpdateable(),  fieldType, fieldResult.getRelationshipName(), fieldResult.isSortable()));
                }
            }  
            System.debug('allFields='+allFields);
            recWrpperObj.headerList = headerList;
            recWrpperObj.recordList = Database.query('SELECT '+allFields+' FROM '+objectName +' LIMIT 200 Offset 700 ');
        }
        return recWrpperObj;
    }

    @AuraEnabled
    public static String updateObjectRecord(List<SObject> updateSObjectList){
        System.debug('updateSObjectList'+updateSObjectList);
        String response;
        try{
            if(updateSObjectList.size() > 0){
                update updateSObjectList;
                response = 'Success';
            }
        }
       catch(Exception e){
           System.debug('msg==='+e.getMessage());
           //response = e.getMessage();
           response = '';
           for (Integer i = 0; i < e.getNumDml(); i++) {
             response = response+e.getDmlMessage(i)+'\n';
            }
       }
        return response;
    }
/*
    @AuraEnabled
    public static List<Contact> getParentRecord(){
        List<Contact> conList = [SELECT Id, Name FROM objName LIMIT 200 OFFSET 700];
        return conList;
    }
*/
    public class RecordWrapper{
        @AuraEnabled public List<SObject> recordList;
        @AuraEnabled public List<HeaderWrapper> headerList;
    } 
     public class HeaderWrapper{
        @AuraEnabled public String fieldApiName;
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public Boolean isEditable;
        @AuraEnabled public Boolean fieldType;
        @AuraEnabled public String fieldRefernceName;
        @AuraEnabled public String fieldRefernceId;
        @AuraEnabled public Boolean isSortable;
      
        public HeaderWrapper(String fieldApiName, String fieldLabel, Boolean isEditable, Boolean fieldType, String fieldRefernceName, Boolean isSortable){
            this.fieldApiName = fieldApiName;
            this.fieldLabel = fieldLabel;   
            this.isEditable = isEditable;
            this.fieldType = fieldType;
            this.fieldRefernceName = fieldRefernceName;
            this.isSortable = isSortable;
        }
         
    }
  
}