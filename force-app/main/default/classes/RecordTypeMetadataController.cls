/*
 Create by			:	Sumit Pilaniya
 Description		:	Create metadata and handle all thing of record type, controlling and dependent picklist field
*/

public  class RecordTypeMetadataController {
   
    //binary-to-text encoding schemes 
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    //Get wrapper to fetch all record tye, controlling and dependent field relation between all these picklist
    @AuraEnabled
    public static PicklistWrapper fetchMetaDetail(String ObjectName, string parentField, string childField){
        PicklistWrapper pw = new PicklistWrapper();
        List<RecordsTypePicklist__mdt> objList = [SELECT RemoveDepPicklist__c,ControllingList__c,RecorTypeList__c FROM RecordsTypePicklist__mdt]; //Fetch custom metadata list
        Set<String> uniqueRecList = new Set<String>();
        List<String> controllingValues;
        Set<String> cntrlList;
        Set<String> removePickListVal;
        
        //Get unique record type set 
        for(RecordsTypePicklist__mdt m : objList){
            uniqueRecList.add(m.RecorTypeList__c);
        }
        Map<String,List<String>> recMainMap = new Map<String,List<String>>();
        Map<String,List<String>> depRemoveMap = new Map<String,List<String>>();
        
        //Get remove denependent map and record type with controlling list map 
        for(String rec : uniqueRecList){
            cntrlList = new Set<String>();
            removePickListVal = new Set<String>();
            for(RecordsTypePicklist__mdt m : objList){
                if(rec.equals(m.RecorTypeList__c)){
                    cntrlList.add(m.ControllingList__c);
                    if(m.RemoveDepPicklist__c!=null){
                        removePickListVal.add(m.RemoveDepPicklist__c);
                    }
                }
                
            }
            controllingValues = new List<String>(cntrlList);
            recMainMap.put(rec,controllingValues); 
            depRemoveMap.put(rec, new List<String>(removePickListVal));
        }
        
        //Store all values PicklistWrapper class
        pw.recTypeMap = recMainMap;
        pw.depRemoveMap  = depRemoveMap;
        pw.pickListMap = RecordTypeMetadataController.getDependentPicklist(ObjectName, parentField, childField);
        return pw;
    }
    
    //Fetch map which is contains which dependent value based on controoling field
    @AuraEnabled
    public static Map<String,List<String>> getDependentPicklist(String objectName, string parentField, string childField) {
        Map<String,List<String>> pickListMap = new Map<String,List<String>>();
        PicklistWrapper pw = new PicklistWrapper();
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(objectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        List<String> controllingValues = new List<String>();
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            pickListMap.put(ple.getLabel(), new List<String>());
            controllingValues.add(ple.getLabel());
        }
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    pickListMap.get(controllingValues.get(i)).add(plew.label);
                }
            }
        }
        return pickListMap;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }
    
    public class PicklistWrapper{
        @AuraEnabled
        public Map<String, List<String>> pickListMap;
        @AuraEnabled
        public  Map<String,List<String>> recTypeMap;
        @AuraEnabled
        public  Map<String,List<String>> depRemoveMap;
    }
    
    public class PicklistEntryWrapper{
        public String label;
        public String validFor;
    }
}