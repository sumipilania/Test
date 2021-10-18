/*
 Created By     :       Sumit Pilaniya
 Date           :       23/10/2019
 Description    :       Lazy Loading using custom table show at a time 20 records

 */


public class LazyLoadingController {
    
    
    //fetch colum and records list
    @AuraEnabled
    public static DynamicWrapper showFieldDynamically(String objName, String query, String offSet) 
    {        
        DynamicWrapper sObj = new DynamicWrapper();
        List<DynamicWrapper> wrapList1 = new List<DynamicWrapper>();
        List<String> fieldList = query.split(',');
        if(!objName.equals(''))
        {
            Map<String, Schema.SObjectField> sObjectfields = Schema.getGlobalDescribe().get(objName).getDescribe().SObjectType.getDescribe().fields.getMap();
            for(Schema.SObjectField field : sObjectfields.values())            
            {      
                Schema.DescribeFieldResult fieldResult = field.getDescribe();                    
                if(fieldResult.isAccessible() && fieldResult.isCreateable() && fieldResult.isSortable() )                
                {   
                    if(fieldList.contains(field.getDescribe().getName()))
                    {
                        DynamicWrapper myWrap = new DynamicWrapper();    
                        myWrap.fieldLabel = field.getDescribe().getLabel();  
                        myWrap.fieldApi = field.getDescribe().getName();
                        wrapList1.add(myWrap); 
                    }
                }
            }
        }  
        sObj.wrapList = wrapList1;
        String queryString = 'SELECT '+query+' FROM '+objName+' LIMIT 20 OFFSET '+offSet;
        sObj.sObjList =  Database.query(queryString);
        sObj.totalRecords = Database.countQuery('SELECT Count() from '+objName); //Total records
        return sObj;
    }
    
    //Colum Variable Store
    public class DynamicWrapper
    {
        @AuraEnabled public List<DynamicWrapper> wrapList ;
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public String fieldApi;
        @AuraEnabled public List<sObject> sObjList;
        @AuraEnabled public Integer totalRecords;    
    }   
}