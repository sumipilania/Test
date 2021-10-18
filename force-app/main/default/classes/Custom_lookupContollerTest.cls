@isTest
class Custom_lookupContollerTest {
    
    @testSetup static void insert_records(){
        List<Account> li =new List<Account>();
        for(integer i=1;i<=9;i++){
            li.add(new Account(name='acc'+i));
        }
        insert li;
    }
    @isTest static void lookup_test(){
       List<Custom_LookupController.RecordsData> obj = Custom_LookupController.fetchRecords('Account', 'Name', 'acc', '5');
        System.assertEquals(obj.size(), 5);
    }
    
}