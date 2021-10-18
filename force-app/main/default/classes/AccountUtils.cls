public class AccountUtils {
    
    public static List<Account> accountsByState(String billing) {
        List<Account> accList = [SELECT Id, Name from Account WHERE BillingState =:billing];
        return accList;
    }
    
    public static void test() {
        EmailTemplate emltemplate = [SELECT Id, Name FROM EmailTemplate Where DeveloperName='Html_Template' LIMIT 1];
        List<Messaging.SingleEmailMessage> singleMssgList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emltemplate.id, '0052v00000XEVjBAAX', '00Q2v00001iC35W');
        String emailSubject = email.getSubject();
        String emailTextBody = email.getPlainTextBody();
        email.setSaveAsActivity(false);
        //email.setToAddresses(new List<String>{'sumit.pilaniya@briskminds.com'});
        email.setSubject(emailSubject);
        email.setPlainTextBody(emailTextBody);
        email.setCcAddresses(new List<String>{'ambika.shekhawat@briskminds.com'});
        //email.setTargetObjectId('0052v00000XEVjBAAX');
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        for(Messaging.SendEmailResult result :results) {
            if (result.success) 
            {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            } 
        }               
        
    }
    
    public static void sendMail(List<Lead> updatedLeadList) {
        Integer usedEmail = Limits.getEmailInvocations();
        Integer emailLimit = Limits.getLimitEmailInvocations();
        System.debug('usedEmail : '+usedEmail);
        System.debug('emailLimit : '+emailLimit);
        EmailTemplate emltemplate = [SELECT Id, Name FROM EmailTemplate Where DeveloperName='Html_Template' LIMIT 1];
        //List<String> ccLeadsEmailList = new List<String>{'kgibson@amarok.com.invalid', 'dcarson@amarok.com.invalid', 'claymon@amarok.com.invalid', 'ecoffey@amarok.com.invalid'};
        if(usedEmail < emailLimit) {
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emltemplate.id, userInfo.getUserId(), '');
            String body = '<b>Congratulations!</b><br/><br/> '+lead.Name+' with '+lead.Company+' has been upgraded to Sales Ready Lead status. Please qualify as soon as possible.*<br/> Phone '+lead.Phone+'<br/><br/> Thanks';          
            message.setHtmlBody(body);
            message.setSenderDisplayName('Company Support');            
            //message.setCcAddresses(ccLeadsEmailList);
            message.toAddresses = (new list<string> {'CorporatecapitalUSA@gmail.com'});
            // message.setTargetObjectId(lead.OwnerId);
            messageList.add(message);
            
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messageList);
                for(Messaging.SendEmailResult result :results) {
                    if (result.success) 
                    {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    } 
                }               
            } catch(Exception e) {
                System.debug('got following error : '+e.getMessage());  
            }
            
        } else {
            System.debug('email limit has been exceed');
        }
    }
    
    
    public static void sendEmailWithTemplate() {
        EmailTemplate emltemplate = [SELECT Id, Name, Body FROM EmailTemplate Where DeveloperName='Text_Email_Lead' LIMIT 1];
        List<Lead> leads = [Select id, company,OwnerId, name from lead where company != null limit 2];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> listOfOwners = new List<String>{'0052v00000eJr6TAAS', '0052v00000f3UBKAA2'};
            for(Lead l : leads) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setTargetObjectId(l.OwnerId); 
                mail.setTemplateId(emltemplate.Id); 
                //mail.setWhatId(l.Id);
                mail.setBccSender(false); 
                mail.setUseSignature(false); 
                mail.setSenderDisplayName('Card Division'); 
                mail.setSaveAsActivity(false);
                emailList.add(mail);
                for(String userId : listOfOwners) {
                    Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage(); 
                    mail1.setTargetObjectId(userId); 
                    mail1.setTemplateId(emltemplate.Id); 
                    //mail.setWhatId(l.Id); 
                    mail1.setBccSender(false); 
                    mail1.setUseSignature(false); 
                    mail1.setSenderDisplayName('Card Division'); 
                    mail1.setSaveAsActivity(false);
                    emailList.add(mail1);
                }
            }
        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            for(Messaging.SendEmailResult result :results) {
                if (result.success) 
                {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                } 
            }               
        } catch(Exception e) {
            System.debug('got following error : '+e.getMessage());  
        }
    }
    
    public static void demo() {
        EmailTemplate emltemplate = [SELECT Id, Name, Body FROM EmailTemplate Where DeveloperName='Text_Email_Lead' LIMIT 1];
        List<Lead> leads = [Select id, company,OwnerId, name from lead where company != null limit 10];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> listOfOwners = new List<String>{'0052v00000eJr6TAAS', '0052v00000f3UBKAA2'};
            for(Lead l : leads) {
                System.debug('name='+l.name);
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emltemplate.Id, l.OwnerId, l.Id);
                String emailSubject = email.getSubject();
                String emailTextBody = email.getPlainTextBody();
                email.setSaveAsActivity(false);
                email.setTargetObjectId(l.OwnerId); 
                email.setSenderDisplayName('Company Support');   
                email.setSubject(emailSubject);
                email.setPlainTextBody(emailTextBody);
                // email.setCcAddresses(ccLeadsEmailList);
                // email.setCcAddresses(new List<String>{'CorporatecapitalUSA@gmail.com'});
                emailList.add(email);
                for(String userId : listOfOwners) {
                    Messaging.SingleEmailMessage email1 = Messaging.renderStoredEmailTemplate(emltemplate.Id, userId, l.Id);
                    String emailSubject1 = email.getSubject();
                    String emailTextBody1 = email.getPlainTextBody();
                    email1.setSaveAsActivity(false);
                    email1.setTargetObjectId(userId); 
                    email1.setSenderDisplayName('Company Support');   
                    email1.setSubject(emailSubject1);
                    email1.setPlainTextBody(emailTextBody1);
                    emailList.add(email1);
                }
            }
        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            for(Messaging.SendEmailResult result :results) {
                if (result.success) 
                {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                } 
            }               
        } catch(Exception e) {
            System.debug('got following error : '+e.getMessage());  
        }
    }
    
    
    public static void newEmail() {
        EmailTemplate emltemplate = [SELECT Id, Name, Body FROM EmailTemplate Where DeveloperName='Text_Email_Lead' LIMIT 1];
        List<Lead> leads = [Select id, company,OwnerId, name from lead where createdDate=Today AND company != null limit 1];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Lead l : leads) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(emltemplate.Id);
            mail.setTargetObjectId(l.OwnerId);
            //mail.setTreatTargetObjectAsRecipient(false);
            //mail.setWhatId(l.Id);
            // mail.setCcaddresses(new list<string>{'anamikashrma1998@gmail.com'});
            mail.setSaveAsActivity(true);
            mail.setUseSignature(false);
            emailList.add(mail);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
        for(Messaging.SendEmailResult result :results) {
            if (result.success)
            {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
    }
}