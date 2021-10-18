public class DynmaicSobjectFieldPopup {
    
    @AuraEnabled
    public static List<DynamicField> requiredField(String sObjName, List<String> fieldList){
        List<DynamicField> fieldWrapper = new List<DynamicField>();
        Map<String, Schema.SObjectField> sObjectfields = Schema.getGlobalDescribe().get(sObjName).getDescribe().SObjectType.getDescribe().fields.getMap();
        for(Schema.SObjectField field : sObjectfields.values()){                 
            Schema.DescribeFieldResult fieldResult = field.getDescribe();                    
            if(fieldResult.isCreateable()  && !fieldResult.isNillable() && !fieldResult.isDefaultedOnCreate()){  
                if(!(fieldList.contains(field.getDescribe().getName()))){
                    fieldWrapper.add(new DynamicField(field.getDescribe().getLabel(), field.getDescribe().getName()));
                }
            }
            if(fieldList.size() > 0){
                if(fieldList.contains(field.getDescribe().getName())){
                    fieldWrapper.add(new DynamicField(field.getDescribe().getLabel(), field.getDescribe().getName()));
                }
            }
        }
        if(fieldWrapper.size()==0){
            fieldWrapper.add(new DynamicField('Name', 'Name'));
        }
        return fieldWrapper;
    }
    
    //Colum Variable Store
    public class DynamicField{
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public String fieldApi;
        
        public DynamicField(String fieldLabel, String fieldApi){
            this.fieldLabel = fieldLabel;
            this.fieldApi = fieldApi;
        }
    }
}