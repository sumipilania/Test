/*
Created by   -    Sumit Pilaniya
Date		  -    16/08/2019
Description  -    Trigger for Manatian Sequence Number if user perform any DML Operation
*/

public class ContactSequenceTriggerHandler
{
     public static Set<String> recUpdate = new Set<String>();
    
    public static void newOrOldMapValue(Map<Id, Contact> oldRecordsMap,Map<Id, Contact> newRecordsMap, Integer uniqIdMethod)
    {
          Set<Id> newSetAccId = new Set<Id>(); //Hold Unique Account Id Trigger.OldMap
        Set<Id> oldSetAccId = new Set<Id>(); //Hold Unique Account Id Trigger.NewMap
		 //Store All Acc Id with old Contact value
        for(Contact con : oldRecordsMap.values())
        {
            if(!(String.isBlank(con.AccountId))) 
            {
                oldSetAccId.add(con.AccountId);
            }
        }
        
        //Store All Acc Id with new Contact value
        for(Contact con : newRecordsMap.values())
        {
            if(!(String.isBlank(con.AccountId))) 
            {
                newSetAccId.add(con.AccountId);   
            }
        }
        
        //Fetch all new updated records List
        List<Account> newAccContactList = new List<Account>([SELECT Id,Name, (SELECT Id, Name, Contact_Sequence__c FROM Contacts ORDER BY Contact_Sequence__c ASC) FROM Account WHERE Id IN : newSetAccId]);
        
        //Fetch all old  records List
        List<Account> oldAccContactList = new List<Account>([SELECT Id,Name, (SELECT Id, Name, Contact_Sequence__c FROM Contacts ORDER BY Contact_Sequence__c ASC) FROM Account WHERE Id IN : oldSetAccId]);
              
    }
    
    //Insert Records
    public static void insertSequence(Map<Id, Contact> newContactRecords) 
    {
        List<Contact> contactUpdate = new List<Contact>(); //Update All Previous and New Records
        Set<Id> uniqueAccountId = new Set<Id>(); //Hold Unique Account Id
        for(Contact con : newContactRecords.values()) // bulk multiple accound id store
        {
            //Check Contact Parent Account Id blank or not
            if(!(String.isBlank(con.AccountId))) 
            {
                uniqueAccountId.add(con.AccountId);
            }
        }
        
        //find particular account id to how many contact records 
        List<Account> accIdContactRec = new List<Account>([SELECT Id,Name, (SELECT Id, Name, Contact_Sequence__c FROM Contacts ORDER BY Id) FROM Account WHERE Id IN : uniqueAccountId]);
             
        //Multiple Accound Iteration
        for(Account acc : accIdContactRec)
        {
            Integer seqNum=0; // Chnage Sequence number
            List<Contact> oldContacts = new  List<Contact>(); //Hold old list of contact records of particular account
            List<Contact> newContacts = new  List<Contact>(); //Hold new list of contact records of particular account
            
            //this loop fetch all contact which associated from particular account
            for(Contact con : acc.Contacts)  
            {
                //For fill old and new list if records is already there or not make old and new records list
                if(newContactRecords.containsKey(con.id)) 
                {
                    newContacts.add(con);  
                }
                else
                {
                    oldContacts.add(con);
                }
            }
            
            //this loop reassign sequence number if they have already there
            for(Contact con : oldContacts) 
            {  
                con.Contact_Sequence__c = ++seqNum;
                contactUpdate.add(con);
            }
            
            //this loop assign increase by 1 based on previous sequence number
            for(Contact con : newContacts)
            { 
                con.Contact_Sequence__c = ++seqNum;
                contactUpdate.add(con);
            }
        }
        
        //only execute if list have any records
        if(contactUpdate.size()>0){ 
            update contactUpdate;  
        }
    }
    
    //Delete Records
    public static void deleteSequence(Map<Id,Contact> deleteRecords)
    {
        Integer tempMin = 0; //Store minimum value from bulk records
        Set<Id> uniqueAccountId = new Set<Id>(); //Hold Unique Account Id
        List<Contact> contactUpdate = new List<Contact>(); //Update All Records List

        // map<Id,Integer> accountIdWithSeqNumber = new map<Id,Integer>();
        for(Contact con : deleteRecords.values())
        {
            //Check Contact Parent Account Id blank or not
            if(!(String.isBlank(con.AccountId)))
            {
                uniqueAccountId.add(con.AccountId);
            }       
        }
        
        //Store all child records from particular account 
        List<Account> accContactList = new List<Account>([SELECT Id,Name, (SELECT Id, Name, Contact_Sequence__c FROM Contacts ORDER BY Contact_Sequence__c ASC) FROM Account WHERE Id IN : uniqueAccountId]);
        
        //Multiple Accound Id iteratation
        for(Account acc : accContactList)
        {
            for(Contact con : deleteRecords.values())
            {
                //Find Minimum values from bulk records
                if(acc.Id == con.AccountId)
                {
                    if(tempMin > con.Contact_Sequence__c || tempMin == 0)
                    {
                        tempMin = (Integer)con.Contact_Sequence__c; 
                    }
                }
                
            }
            for(Contact con : acc.Contacts)
            {
                if(con.Contact_Sequence__c > tempMin)
                {
                    con.Contact_Sequence__c = tempMin++;
                    contactUpdate.add(con);
                }                
            }
        }
        
        //only execute if list have any records
        if(contactUpdate.size()>0){ 
            update contactUpdate; 
        } 
    }
    
    //Undelete Records
    public static void undeleteSequence(Map<Id, Contact> undeleteRecordList)
    {
        List<Contact> conListSeq = new List<Contact>(); //update list
        Set<Id> uniqueAccountId = new Set<Id>(); //Hold Unique Account Id
        
        // bulk multiple accound id store
        for(Contact con : undeleteRecordList.values())
        {
            if(!(String.isBlank(con.AccountId))) //Check Contact Parent Account Id blank or not
            {
                uniqueAccountId.add(con.AccountId);
            }
        }
        
        //Store all child records from particular account 
        List<Account> accContactList = new List<Account>([SELECT Id,Name, (SELECT Id, Name, Contact_Sequence__c FROM Contacts) FROM Account WHERE Id IN : uniqueAccountId]);
        
        //Multiple Accound Id iteratation
        for(Account acc : accContactList)
        {
            List<Contact> oldContacts = new  List<Contact>(); //Hold old list of contact records of particular account
            List<Contact> newContacts = new  List<Contact>(); //Hold new list of contact records of particular account
            
            //For fill old and new list if records is already there or not make old and new records list
            for(Contact con : acc.Contacts)
            {
                if(undeleteRecordList.containsKey(con.id)) 
                {
                    newContacts.add(con);  //Store all new records
                }
                else
                {
                    oldContacts.add(con); //Store all old records
                }               
            }
            Integer sizeContact=oldContacts.size();//Calculate old records list size
            
            //this loop assign increase by 1 based on old records list size
            for(Contact con : newContacts) 
            { 
                con.Contact_Sequence__c = ++sizeContact;
                conListSeq.add(con);
            } 
        }
        
        //only execute if list have any records
        if(conListSeq.size()>0)
        { 
            update conListSeq;
        }
    }
    
    //Reparenting Method And Update Method
    public static void updateSequence(Map<ID,Contact> oldRecordsMap, Map<Id,Contact> newRecordsMap)
    {
        
        Map<Id,Contact> updateListWithMap = new Map<Id,Contact>();//Remove Duplication in List during updation 
        Set<Id> newSetAccId = new Set<Id>(); //Hold Unique Account Id Trigger.OldMap
        Set<Id> oldSetAccId = new Set<Id>(); //Hold Unique Account Id Trigger.NewMap
        List<Contact> contactUpdate = new List<Contact>(); //Update All Records List
        
        //Store All Acc Id with old Contact value
        for(Contact con : oldRecordsMap.values())
        {
            if(!(String.isBlank(con.AccountId))) 
            {
                oldSetAccId.add(con.AccountId);
            }
        }
        
        //Store All Acc Id with new Contact value
        for(Contact con : newRecordsMap.values())
        {
            if(!(String.isBlank(con.AccountId))) 
            {
                newSetAccId.add(con.AccountId);   
            }
        }
        
        //Fetch all new updated records List
        List<Account> newAccContactList = new List<Account>([SELECT Id,Name, (SELECT Id, Name, Contact_Sequence__c FROM Contacts ORDER BY Contact_Sequence__c ASC) FROM Account WHERE Id IN : newSetAccId]);
        
        //Fetch all old  records List
        List<Account> oldAccContactList = new List<Account>([SELECT Id,Name, (SELECT Id, Name, Contact_Sequence__c FROM Contacts ORDER BY Contact_Sequence__c ASC) FROM Account WHERE Id IN : oldSetAccId]);
      
        //Handle Recursion Problem
       
            //This condition check in case reparenting
            if(!(oldSetAccId.equals(newSetAccId)))
            {
                //This loop re-sequence records which parent change  
                for(Account acc : oldAccContactList)
                {
                    Integer tempOldSize = 0;
                    for(Contact con : acc.Contacts)
                    {
                        con.Contact_Sequence__c = ++tempOldSize;
                        contactUpdate.add(con);
                    }
                }
                
                //This loop manage new uptaded parent records
                for(Account acc : newAccContactList)
                {
                    List<Contact> oldContacts = new  List<Contact>(); //Hold old list of contact records of particular account
                    List<Contact> newContacts = new  List<Contact>(); //Hold new list of contact records of particular account
                    for(Contact con : acc.Contacts)
                    {      
                        if(oldRecordsMap.containsKey(con.Id))
                        {
                            oldContacts.add(con);
                        }
                        else
                        {
                            newContacts.add(con);
                        }
                    }
                    
                    //calculate size old list to re-sequence new list
                    Integer newTempSize = newContacts.size();
                    for(Contact con : oldContacts)
                    {   
                        if(!recUpdate.contains(con.id))
                        {
                            con.Contact_Sequence__c = ++newTempSize;
                            contactUpdate.add(con);
                            recUpdate.add(con.id);
                        }
                        
                    }
                }
            }
            
            //This condition check wheather normal update case this block not execute in case of reparenting
            else if(!(oldRecordsMap.equals(newRecordsMap)))
            {
                Integer count;//re-sequence without updated records
                List<Integer> sortNewMapSeq = new List<Integer>();//This list hold trigger new sequence number
                Map<Id,Contact> accountIdWithContactList = new Map<Id,Contact>();// this map used for hold all without updated records
                
                
                //All records fetch related update records
                for(Account acc : newAccContactList)
                {
                    count = 1;
                    sortNewMapSeq.clear();
                    accountIdWithContactList.clear();
                    
                    
                    //this loop hold all without updated records
                    for(Contact con : acc.Contacts) {
                        if(!newRecordsMap.containsKey(con.Id)) {
                            accountIdWithContactList.put(con.id,con);  
                        }
                    }
                    
                    //Particular account related contact records store 
                    for(Contact newCon : newRecordsMap.values())
                    {
                        if(acc.id == newCon.AccountId)
                        {
                            sortNewMapSeq.add((Integer)newCon.Contact_Sequence__c);
                        }
                    }
                    sortNewMapSeq.sort();
                    
                    //resequence without updated records
                    for(Contact accListCon : accountIdWithContactList.values())
                    {
                        if(!recUpdate.contains(accListCon.id))
                        {
                            for(Integer contactNew : sortNewMapSeq)
                            {
                                if((accListCon.Contact_Sequence__c != contactNew || accListCon.Contact_Sequence__c == contactNew) 
                                   && (contactNew != count))
                                {
                                    accListCon.Contact_Sequence__c = count;
                                }
                                else if((accListCon.Contact_Sequence__c != contactNew || accListCon.Contact_Sequence__c == contactNew) 
                                        && (contactNew != count || contactNew == count))
                                {
                                    accListCon.Contact_Sequence__c = ++count; 
                                    
                                }
                            }
                            contactUpdate.add(accListCon); 
                            recUpdate.add(accListCon.id);
                            count++;
                        }
                    } 
                    
                }
            }
        
        
        //Remove duplication id in list we use map
        updateListWithMap.putAll(contactUpdate);
        if(updateListWithMap.size()>0)
        { 
              update updateListWithMap.values();
        }
    }
}