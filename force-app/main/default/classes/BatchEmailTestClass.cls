@isTest
private class BatchEmailTestClass 
{
    @testSetup
    static void setup() 
    {
        List<Contact> conList = new List<Contact>();
        for (Integer i=1; i<=20; i++) 
        {
            conList.add(new Contact(firstname='first',lastname='last'));
        }
        insert conList;
        Date d1 = System.today().addDays(-1);
        for(Contact c1 : conList)
        {
            Test.setCreatedDate(c1.Id, dateTime.newInstance(date.newInstance(d1.year(), d1.month(), d1.day()), time.newInstance(00, 00, 00, 00)));  
        } 
    }
    @isTest static void btach_test()
    {
        Test.startTest();
        BatchEmailCSVController obj = new BatchEmailCSVController();
        Database.executeBatch(obj);
        Test.stopTest();
        System.assertEquals(20, [select count() from contact where Status__c = 'Ready for Approval']);
    }
}