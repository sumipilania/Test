trigger UserManagerTrigger on User (after update) {
    if(Trigger.isUpdate){
        UserManagerTriggerHandler.managerAccessLevel(Trigger.oldMap, Trigger.newMap);
    }
}