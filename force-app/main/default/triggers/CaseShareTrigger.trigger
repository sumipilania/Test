trigger CaseShareTrigger on Case (after update) {
    if(Trigger.isUpdate){
        CaseShareTriggerHandler.manageCaseShareRecordAccess(Trigger.newMap, Trigger.oldMap);
    }
}