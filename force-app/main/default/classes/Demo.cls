public class Demo
{
    public string accId = '0012v00002L8zRqAAJ';
    public Demo(){
        System.debug('Constructor');
        //callMethod();
    }                 
    public PageReference callMethod(){
        System.debug('callMethod');
        insert new Account(Name='vfCall');
        PageReference pr = new PageReference('https://sumit-pilaniya-light9domain-dev-ed.lightning.force.com/'+accId);
        return pr;
    }
    //By SharSolutions
   public class MyPickListInfo
   {
        public String validFor;
   }

public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField)
{
    Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    Schema.DescribeSObjectResult describeResult = objType.getDescribe();
    Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
    Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
    List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
    List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
     System.debug('controllingValues size='+controllingValues.size());
	 System.debug('dependentValues size='+dependentValues.size());

    
    for(Schema.PicklistEntry currControllingValue : controllingValues)
    {
       // System.debug('ControllingField: Label:' + currControllingValue.getLabel());
        controllingInfo.put(currControllingValue.getLabel(), new List<String>());
    }

    for(Schema.PicklistEntry currDependentValue : dependentValues)
    {
         // System.debug('currDependentValue:' + currDependentValue.getLabel());
        
        String jsonString = JSON.serialize(currDependentValue);

        MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);

        String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();

       // System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);

        Integer baseCount = 0;
  //System.debug(' hexString.getChars()='+ hexString.getChars());
     //    System.debug(' size='+ hexString.getChars().size());
      for(Integer curr : hexString.getChars())
        {
           // System.debug('curr='+curr);
            Integer val = 0;

            if(curr >= 65)
            {
                val = curr - 65 + 10;
            }
            else
            {
                val = curr - 48;
            }

            if((val & 8) == 8)
            {
                //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getLabel());
                controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
            }
            if((val & 4) == 4)
            {
               // System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getLabel());
                controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
            }
            if((val & 2) == 2)
            {
               // System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
            }
            if((val & 1) == 1)
            {
              //  System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
            }

            baseCount += 4;
        }         
    } 

   // System.debug('ControllingInfo: ' + controllingInfo);

    return controllingInfo;
	}
    
    
//Pass dependent field parameter e.g.: Account.YourDependentField__c
public static Map<Object,List<String>> getDependentPicklistValues(Schema.sObjectField dependentField){
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
    	List<String> cityList = new List<String> {'Aurora', 'London', 'Cork', 'Pune', 'New York City', 'Yonkers', 'Jodhpur', 'Mirzapur'};
    	Map<String, String> myMap = new Map<String, String>();
        //Get dependent field result
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        //Get dependent field controlling field 
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        //Check controlling field is not null
        
        if(controllerField == null){
            return null;
        } 
        //Get controlling field result
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        //Get controlling field picklist values if controlling field is not a checkbox
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
        //It is used to decode the characters of the validFor fields. 
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
         
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            if (entry.isActive()){
            //The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                //System.debug('base64chars='+base64chars);
                for (Integer i = 0; i < controllerValues.size(); i++){
                    Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                    //System.debug('controllerValue='+controllerValue);
                    Integer bitIndex = i / 6;
                    //System.debug('bitIndex='+bitIndex);
                    Integer bitShift = 5 - Math.mod(i, 6 );
                   // System.debug('bitShift='+bitShift);
                    if(controllerValue == null || bitIndex < base64chars.size() && (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                        continue;
                    } 
                    if (!dependentPicklistValues.containsKey(controllerValue)){
                        dependentPicklistValues.put(controllerValue, new List<String>());
                    }
                    dependentPicklistValues.get(controllerValue).add(entry.getLabel());
                    if(cityList.contains(entry.getLabel())) {
                        myMap.put(entry.getLabel(), String.valueOf(controllerValue));
                    }
                }
            }
        }
    	System.debug('myMap='+myMap);
        return dependentPicklistValues;
    }
}