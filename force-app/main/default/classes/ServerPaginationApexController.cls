public class ServerPaginationApexController
{
    //Dynamic Object List
    @AuraEnabled
    public static Map<String,String> getObjectList()
    {
        Map<String,String> options = new Map<String,String>();
        Map<String,schema.SObjectType> allobj=schema.getGlobalDescribe();
        List<string> objnames = new List<string>();
        objnames.addAll(allobj.keySet());
        objnames.sort();
        Schema.DescribeSobjectResult[] results  = Schema.describeSObjects(objnames);   
        for(Schema.DescribeSobjectResult describeResult  : results){                
            if(describeResult.isQueryable() && describeResult.isSearchable() && describeResult.isUndeletable()) {                    
                options.put(describeResult.getName(),describeResult.getLabel());
            }
        }
        return options;
    }
    
    //Colum Fetch
    @AuraEnabled
    public static Map<String, String> getObjectFields(String objName) 
    {
        Map<String, String> retVal = new Map<String, String>();
        if(!objName.equals(''))
        {
            Map<String, Schema.SObjectField> sObjectfields = Schema.getGlobalDescribe().get(objName).getDescribe().SObjectType.getDescribe().fields.getMap();
            for(Schema.SObjectField field : sObjectfields.values())            
            {          
                Schema.DescribeFieldResult fieldResult = field.getDescribe();                    
                if(fieldResult.isAccessible() && fieldResult.isCreateable() && fieldResult.isSortable() )                
                {   
                    retVal.put(field.getDescribe().getName(),field.getDescribe().getLabel()); 
                }
            }   
        }                  
        return retVal;
    }
    
    //Total Records Size
    @AuraEnabled
    public static Integer totalRecords(String objName) 
    { 
        String query = 'SELECT Count() from '+objName;
        Integer totalRec = Database.countQuery(query);
        return totalRec;
    }  
    
    //Wrapper For Columns Show
    @AuraEnabled
    public static List<DynamicWrapper> showFieldDynamically(String objName, List<String> fieldList) 
    {
        List<DynamicWrapper> wrapList = new List<DynamicWrapper>();
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
                        myWrap.type = field.getDescribe().getType(); 
                        myWrap.sortable = true;
                        wrapList.add(myWrap); 
                    }
                }
            }
        }                 
        return wrapList;
    }
    
    //Maintain Pagination Next Previous Last First Diaplay Records Size
    @AuraEnabled
    public static List<sObject> showDynmaicRecords(String objName, String query, String sortField, Integer limitSize, Integer offsetSize) 
    {
        String queryRec = 'SELECT '+query+' FROM '+objName+ ' ORDER BY ' +sortField+' LIMIT '+limitSize+' OFFSET ' + offsetSize;
        List<sObject> sObjectList = Database.query(queryRec);
        return sObjectList;
    }
    
    //Colum Variable Store
    public class DynamicWrapper
    {
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public String fieldApi;
        @AuraEnabled public Schema.DisplayType type;
        @AuraEnabled public boolean sortable;
    }
}