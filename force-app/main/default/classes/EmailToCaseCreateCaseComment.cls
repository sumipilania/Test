global class EmailToCaseCreateCaseComment implements Messaging.InboundEmailHandler 
{
    /*
     global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
        System.debug('Sumit');
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();  // Result Hold Record successfully insert or not
        String bodyOfEmail = email.plainTextBody;  //Hold Body of Email
        String[] strLineOfRows = bodyOfEmail.split('##');  //store particular rag of single object one by one
        List<sObject> listInsert = new List<sObject>();  //Hold all object records
        
        //Iterate till how many object and row
        for(Integer i=0; i<strLineOfRows.size(); i++)
        {
            String tempStr = strLineOfRows[i];  //one by one row insert
            String[] columName = tempStr.split('#'); //Object name, Filed Name, Records
            String objName=columName[0];
            String FiledName = columName[1];
            String records = columName[2];
            SObject convertSObjType = Schema.getGlobalDescribe().get(objName).newSObject();  //String Convert into sObject and create instance of object
            convertSObjType.put(FiledName,records); //Map hold fieldName and Value
            listInsert.add(convertSObjType); //hold List all map
        }
        
        //insert sObject records
        insert listInsert;
        return result;
    }
*/
     global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		System.debug('Suymit');
         Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          return result;
      }
}