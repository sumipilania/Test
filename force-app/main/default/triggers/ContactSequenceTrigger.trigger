trigger ContactSequenceTrigger on Contact (after insert, after delete, after undelete, after update) 
{
     if(Trigger.isInsert) //Only Execute insert record
    {
        ContactSequenceTriggerHandler.insertSequence(Trigger.newMap); //all id's of new contact records and call handler class method  
    }
    
    if(Trigger.isDelete)
    {
        ContactSequenceTriggerHandler.deleteSequence(Trigger.oldMap);
    }
    if(Trigger.isUndelete)
    {
        ContactSequenceTriggerHandler.undeleteSequence(Trigger.newMap);
    } 
    
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        ContactSequenceTriggerHandler.updateSequence(Trigger.oldMap, Trigger.newMap);   
    }
    
}