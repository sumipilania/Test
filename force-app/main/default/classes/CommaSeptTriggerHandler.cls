public class CommaSeptTriggerHandler {
    
    public static void onUpdate(Map<Id, Account> oldAccountMap){
        Set<Id> uniqueAccountId = new Set<Id>(); //Hold Unique Account Id
        Set<Contact> updateList = new Set<Contact>();
        List<Contact> deleteList = new List<Contact>();
        for(Account acc : oldAccountMap.values()){
            if(!(String.isBlank(acc.Id))){
                uniqueAccountId.add(acc.Id);
            }
        }
        List<Account> accIdContactRec = new List<Account>([SELECT Id, Name, Comma_Seprated_Text__c, (SELECT Id, Name, LastName FROM Contacts ORDER BY Id) FROM Account WHERE Id IN : uniqueAccountId]);
        Integer temp = 0;
        for(Account acc : accIdContactRec)
        {
            String tempStr = acc.Comma_Seprated_Text__c;
            if(!(tempStr=='' || tempStr==null)){
                Set<String> uniqueStrSet = new Set<String>(tempStr.split(','));
                List<String> uniqueStr = new List<String>(uniqueStrSet);
                if(uniqueStr.size() <= acc.Contacts.size()){
                    Integer count = 0;
                    for(Contact con : acc.Contacts)  
                    {
                        for(Integer i = count; i<uniqueStr.size(); i++){
                                con.LastName=uniqueStr[i];
                                updateList.add(con);
                                break;
                        }
                        if(count>=uniqueStr.size()){
                                deleteList.add(con);
                        }   
                        count++;
                    }
                    temp = 3;
                }
                else{
                    for(Integer i = acc.Contacts.size(); i<uniqueStr.size(); i++){
                        updateList.add(new Contact(LastName=uniqueStr[i],AccountId=acc.Id));
                    }
                    temp = 2;
                }
            }
            else{
                updateList.addAll(acc.Contacts);
                temp = 1;
            }
        }
        
        if(deleteList.size()>0){
            System.debug('deleteList==='+deleteList.size());
            delete deleteList;
        }
        List<Contact> uniqueUpdateList = new List<Contact>(updateList);
        if(temp==1 && uniqueUpdateList.size()>0){
            delete uniqueUpdateList;
        }
        else if(temp==2 && uniqueUpdateList.size()>0){
            insert uniqueUpdateList;
        }
        else if(temp==3 && uniqueUpdateList.size()>0){
            System.debug('uniqueUpdateList==='+uniqueUpdateList.size());
            update uniqueUpdateList;
        }
    }
    
}