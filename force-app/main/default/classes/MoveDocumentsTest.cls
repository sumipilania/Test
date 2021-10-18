@isTest
private class MoveDocumentsTest {
    @testSetup static void insertFolderAndDocument(){
        //Test.startTest();
        List<Folder> quoteFolder = [Select Id From Folder Where DeveloperName = 'Quotes' AND NameSpacePrefix = 'SBQQ' LIMIT 1];
        List<Folder> targetFolder = [Select Id From Folder Where DeveloperName = 'MD_Netsuite_Documents' limit 1];
        System.debug('quoteFolder=='+quoteFolder);
        System.debug('targetFolder=='+targetFolder);
        insert new Document(Name='Quotes',FolderId=targetFolder[0].Id);
        
        
        List<Document> documentObjList = [Select Id, Name From Document];
        System.debug('documentObjList=='+documentObjList);
        String docId = documentObjList[0].Id;
        System.debug('docId=='+docId);
        insert new Contact(LastName='test',documentId__c=docId);
        
        
        //Test.stopTest();
    }
    
    @isTest static void batchExcute(){
        
        Test.startTest();
        System.debug('Folder=='+[Select Id, Name From Folder]);
        
        MoveDocuments moveObj = new MoveDocuments();
        Id batchId = Database.executeBatch(moveObj);
        System.debug('Idd=='+batchId);
        Test.stopTest();
    }
}