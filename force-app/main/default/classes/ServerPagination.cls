/*
Created By			: Sumit Pilaniya
Description			: Server Side Pagination Every Click Request For Server Side 
Date			    : 19/09/2019 

*/

public class ServerPagination
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
                if(fieldResult.isAccessible() && fieldResult.isSortable() )                
                {   
                    retVal.put(field.getDescribe().getName(),field.getDescribe().getLabel()); 
                }
            }   
        }                  
        return retVal;
    }
    
    //Dynamic Records Fetch And Total records
    @AuraEnabled
    public static DynamicRecordsAndHeader showFieldDynamically(String query, String selObjName) 
    {       
        DynamicRecordsAndHeader ob = new DynamicRecordsAndHeader();               
        ob.totalRecords = Database.countQuery('SELECT Count() from '+selObjName);
        ob.recordsList = Database.query(query);       
        return ob;
    }
    
    //Store SObject List and Total records of object
    public class DynamicRecordsAndHeader
    {              
        @AuraEnabled public List<sObject> recordsList;
        @AuraEnabled public Integer totalRecords;       
    }   
}