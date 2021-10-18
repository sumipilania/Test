trigger preventDeletion on Faculty__c(before delete){
   for(Faculty__c pa : Trigger.Old){
        Student__c[] chlist = [select id, Faculty__c from Student__c where Faculty__c =: pa.id];  //list to hold child matches the parent

        if(chlist.size()>0) {

            pa.adderror('Child record is refering this record...So, you cannot delete it...!');

        }
   }
}