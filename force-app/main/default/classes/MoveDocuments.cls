global class MoveDocuments implements Database.Batchable<SObject>  {

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id, documentId__c From Contact');
    }

    global void execute(Database.BatchableContext BC, List<sObject> invoiceList){

        Set<Id> docIdSet = new Set<Id>();
        for(Sobject obj : invoiceList) {
            if(String.isNotBlank((String) obj.get('documentId__c'))) {
                docIdSet.add((String) obj.get('documentId__c'));
            }
        }

        if(!docIdSet.isEmpty()) {
            List<Document> docList = [Select Id, FolderId From Document where Id IN: docIdSet];
            Folder quoteFolder = [Select Id From Folder Where DeveloperName = 'Quotes' AND NameSpacePrefix = 'SBQQ' LIMIT 1];
            Folder targetFolder = [Select Id From Folder Where DeveloperName = 'MD_Netsuite_Documents'];
            if(!docList.isEmpty()) {
                List<Document> docToUpdateList = new List<Document>();
                for(Document doc : docList) {
                    if(String.isNotBlank(doc.FolderId) &&  String.isNotBlank(quoteFolder.Id) && Id.valueOf(doc.FolderId) != Id.valueOf(quoteFolder.Id)) {
                        doc.FolderId = targetFolder.Id;
                        docToUpdateList.add(doc);
                    }
                }
                if(!docToUpdateList.isEmpty()) {
                    update docToUpdateList;
                }
            }
        }
    }


    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        System.abortJob(a.id);
    }
}