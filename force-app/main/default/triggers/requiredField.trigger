trigger requiredField on Test1__c (before insert, before update) {
for(Test1__c ts:trigger.new)
{
 if((ts.desc__c==null))
 {
    ts.addError('required field');
 }
}

}