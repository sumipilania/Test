@isTest
class LazyLoadingControllerTest {
    
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
        LazyLoadingController.DynamicWrapper obj = LazyLoadingController.showFieldDynamically('Account', 'Name,Id,Type', '20');
        System.assertEquals(50, obj.totalRecords);
        Test.stopTest();
           
    }
}