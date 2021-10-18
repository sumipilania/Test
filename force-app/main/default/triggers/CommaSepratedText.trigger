trigger CommaSepratedText on Account (after insert, after update) {

    if(Trigger.isUpdate){
        System.debug('Insert');
        CommaSeptTriggerHandler.onUpdate(Trigger.oldMap);
    }
        
}