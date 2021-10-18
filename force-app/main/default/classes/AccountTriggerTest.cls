@isTest
public class AccountTriggerTest {
    @isTest
    static void test1() {
        List<Account> accList= new List<Account>();
        for(Integer i=1; i<=200; i++) {
            accList.add(new Account(Name ='test '+i, ShippingState = 'CAA', BillingState='CA'));
        }
        if(accList.size() > 0) {
            insert accList;
        }
    }
}