@isTest
class ClientPaginationTest {
    
    @testSetup static void records_insert()
    {
        Test.startTest();
        List<Account> acc =new List<Account>();
        for(Integer i=1;i<=50;i++)
        {
            acc.add(new Account(Name='ac'+i));
        }
        insert acc;
        Test.stopTest();
    }
    
    @isTest static void test_cases()
    {     
        Test.startTest();
        ClientSidePaginationController obj = new ClientSidePaginationController();
        Map<String,String> objMap = ClientSidePaginationController.getObjectList();
        System.assertEquals(false, objMap.containsKey('event'));
        ClientSidePaginationController.getObjectFields('Account');
        Integer size =  ClientSidePaginationController.totalRecords('Account');
        System.assertEquals(50, size);     
        List<String> fieldList = new List<String>();
        fieldList.add('Name');
        fieldList.add('Phone');
        ClientSidePaginationController.showFieldDynamically('Account', fieldList);
        List<sObject> sobjList = ClientSidePaginationController.showDynmaicRecords('Account','Name,Phone');
        System.assertEquals(50, sobjList.size());
        Test.stopTest();
           
    }
}