trigger OrderEventTrigger on Order_Event__e (after insert) {
 List<Task> taskList = new List<Task>();
    
    // Get queue Id for case owner
    //Group queue = [SELECT Id FROM Group WHERE Name='Regional Dispatch' AND Type='Queue'];
       
    // Iterate through each notification.
    for (Order_Event__e event : Trigger.New) {
        if (event.Has_Shipped__c== true) {
            // Create Case to dispatch new team.
            Task cs = new Task();
            cs.Priority = 'Medium';
            cs.Subject = 'Follow up on shipped order ' + event.Order_Number__c;
            cs.OwnerId = event.CreatedById;
            taskList.add(cs);
        }
   }
    insert taskList;
}