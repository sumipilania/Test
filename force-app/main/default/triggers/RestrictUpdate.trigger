trigger RestrictUpdate on Account (before insert, before update ) {
        if(Trigger.isUpdate){
            System.debug('Trigger.oldMap=='+Trigger.oldMap);
            System.debug('Trigger.newMap=='+Trigger.newMap);
            List<Account> accList = new List<Account>();
           // Database.upsert(new Account(Name='accList'), false);
            //System.debug('resp=='+[SELECT Name,Id from Account where Name='accList']);
            accList.add(new Account(Name='Rest'));
            for(Account acc : Trigger.old){
                acc.Name = 'unUpdate';
                accList.add(acc);
            }
            System.debug('Before');
           Database.UpsertResult[] svResult =   Database.upsert(accList, false);
             System.debug('after');
    }
}