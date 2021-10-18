global class BatchEmailCSVController implements Database.Batchable<sObject>
{
    //start executation from start method and pass query in execute method
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        //pass yesterday created records
        return Database.getQueryLocator([Select LastName, Status__c, Birthdate, Import_Date_Time__c, Import_Boolean_Type__c, Import_Text_Area__c From Contact Where CreatedDate = Today]);
    }
    
    //All business logic write here
    global void execute(Database.BatchableContext bc, List<Contact> recordsList)
    {
        List<Contact> updateContactList = new List<Contact>();
        for(Contact con : recordsList)
        {
            //update yesterday records status ready for approval
            con.Status__c = 'Ready for Approval'; 
            updateContactList.add(con);
        }
        update updateContactList;
        //Csv File Header
         String finalCsv = 'LastName,Status,BirthDay,Import Date/Time,Boolean Value,Text Area\n';
        for(Contact con : recordsList)
        {
            //Create csv string
           String tempStr=con.LastName+' '+','+con.Status__c+' '+','+con.Birthdate+' '+','+con.Import_Date_Time__c+' '+','+con.Import_Boolean_Type__c+' '+',"'+con.Import_Text_Area__c+'"'+'\n';            
           finalCsv+=tempstr;
        }
        
        //Send Email 
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalCsv);
        string csvname= 'Contact.csv'; //CSV File Name
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);  //Content Send
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string>{'sumit.pilaniya@briskminds.com'}; //Email id which you want to send
        String subject ='Contact CSV'; //Subject of Email
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('Contact CSV ');  //Body of Email
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc}); //Send CSV
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        
    }    
    global void finish(Database.BatchableContext bc)
    {
        
    }    
}