@isTest
class ServerSidePagination_Test {
    
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
        ServerPaginationApexController obj = new ServerPaginationApexController();
        Map<String,String> objMap = ServerPaginationApexController.getObjectList();
        System.assertEquals(false, objMap.containsKey('event'));
        ServerPaginationApexController.getObjectFields('Account');
        Integer size =  ServerPaginationApexController.totalRecords('Account');
        System.assertEquals(50, size);     
        List<String> fieldList = new List<String>();
        fieldList.add('Name');
        fieldList.add('Phone');
        ServerPaginationApexController.showFieldDynamically('Account', fieldList);
        List<sObject> sobjList = ServerPaginationApexController.showDynmaicRecords('Account','Name,Phone', 'Name', 5, 0);
        System.assertEquals(5, sobjList.size());
           
    }
}