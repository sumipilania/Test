trigger TestTriggerOnContact on Contact (before update, after update) {
    
    if(Trigger.isBefore)
    {
        for(Contact con : Trigger.new)
        {
             System.debug('Before New'+con.Contact_Sequence__c);
        }
        for(Contact con : Trigger.old)
        {
             System.debug('Before old'+con.Contact_Sequence__c);
        }
    }
     if(Trigger.isAfter)
    {
         for(Contact con : Trigger.new)
        {
             System.debug('after New'+con.Contact_Sequence__c);
        }
       for(Contact con : Trigger.old)
        {
             System.debug('After New'+con.Contact_Sequence__c);
        }
       
    }
    
    
    

}