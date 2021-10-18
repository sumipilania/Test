@isTest
class RecordTypeMetadataTest {
    
    @isTest static void fetchSobjList(){
        Test.startTest();
        RecordTypeMetadataController.PicklistWrapper wrpObj = RecordTypeMetadataController.fetchMetaDetail('RecordType__c', 'Controlling__c', 'DependentList__c');
        System.assertEquals(3, wrpObj.recTypeMap.size()); //Rectype size
        System.assertEquals(3, wrpObj.recTypeMap.get('FirstRecType').size()); //FirstRecType value of list size
        System.assertEquals(1, wrpObj.depRemoveMap.get('FirstRecType').size()); //Remove dependent picklist size 
        System.assertEquals(2, wrpObj.pickListMap.get('Maharashtra').size()); //Dependent list size of Maharashtra key
        Test.stopTest();
    }
    
}