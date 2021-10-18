@isTest
class ServerPaginationTest {
    
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
        ServerPagination obj = new ServerPagination();
        Map<String,String> objMap = ServerPagination.getObjectList();
        System.assertEquals(false, objMap.containsKey('event'));
        ServerPagination.getObjectFields('Account'); 
        String query = 'SELECT Name, Id FROM Account ORDER BY Id LIMIT 5';
        ServerPagination.DynamicRecordsAndHeader wrapObj = ServerPagination.showFieldDynamically(query,'Account');
        System.debug('Obj=='+wrapObj);
        System.assertEquals(wrapObj.totalRecords,50);
           
    }
}