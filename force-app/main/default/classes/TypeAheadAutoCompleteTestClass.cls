@isTest
class TypeAheadAutoCompleteTestClass 
{
    
    @TestSetup static void insertRecords()
    {
        List <Account> acc = new List<Account>();
        for(Integer i=1 ; i<=40; i++)
        {
            acc.add(new Account(Name='TestAccount1'+i));
            
        }
        insert acc;
    }
    
    @isTest static void autoComplete_test()
    {
        Test.startTest();
        TypeAheadComponentController obj = new TypeAheadComponentController();
        obj.objectFieldName = 'Name';
        obj.searchTerm = 'Acc';
        List<String> nameList = TypeAheadComponentController.autoCompleteMethod('Acc', 'Account');
        System.assertEquals(20, nameList.size());
        
        obj.queryString = 'Acc';
        TypeAheadComponentController.objectName = 'Account';
        obj.detailPageShow();
        Test.stopTest();
    }
}