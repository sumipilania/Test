public class ContactAndLeadSearch {
    
    public static List<List< SObject>> searchContactsAndLeads(String temp)
    {
        List<List<sObject>> searchList = [FIND :temp IN ALL FIELDS 
                   RETURNING Contact(FirstName, LastName),Lead(FirstName,LastName)];
        Contact[] searchContacts = (Contact[])searchList[0];
        Lead[] searchLead = (Lead[])searchList[1];
		System.debug('Found the following accounts.');
		for (Lead a : searchLead) {
    		System.debug(a.FirstName+' , '+a.LastName);
		}
		System.debug('Found the following contacts.');
		for (Contact c : searchContacts) {
    		System.debug(c.LastName + ', ' + c.FirstName);
    	}
        return searchList;
    }

}