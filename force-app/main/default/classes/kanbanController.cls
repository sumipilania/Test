/*
Created By     :       Sumit Pilaniya
Date           :       04/11/2019
Description    :       Kanban view update records using drag and drop 

*/

public class kanbanController {
    
    //Fetch records map according kanban field
    @AuraEnabled
    public static  Map<String, List<sObject>> getKanbanWrap(String objName, String[] objFields, String kanbanField) {
        try{
            List<String> lstPickvals=new List<String>();
            Map<String, Schema.SObjectField> sObjectfields = Schema.getGlobalDescribe().get(objName).getDescribe().SObjectType.getDescribe().fields.getMap();         
            Schema.DescribeFieldResult fieldResult = sObjectfields.get(kanbanField).getDescribe();    
            Schema.DisplayType type = fieldResult.getType();
            Map<String, List<sObject>> picMap = new Map<String, List<sObject>>();
            if(type ==  Schema.DisplayType.Picklist)
            {
                for (Schema.PicklistEntry a : fieldResult.getPickListValues())
                    lstPickvals.add(a.getValue());
                String query = 'SELECT Id, ';
                for(String s:objFields){
                    query += s+' ,';
                }
                query = query.removeEnd(',');
                query += ' FROM ' + objName;
                List<sObject> sObj = Database.query(query);
                for(String picVal : lstPickvals){
                    List<sObject> val = new List<sObject>();
                    for(sObject s : sObj){
                        if(picVal==s.get(kanbanField)){
                            val.add(s);
                        }               
                    }
                    picMap.put(picVal,val);
                }            
            }
            return picMap;
        }
        catch(Exception e){
            return new Map<String, List<sObject>>();
        }
    }
    
    //Update records using Id
    @AuraEnabled
    public static String getUpdateStage(Id recId, String kanbanField, String kanbanNewValue) {
        SObject o1 = recId.getSObjectType().newSObject(recId);
        o1.put(kanbanField,kanbanNewValue);
        update o1;
        return 'Success';
    }
}