@isTest
public class TestVerifyDate {
    
    @isTest static void test1()
    {
        Date d1=date.newInstance(2019, 5, 20);
		Date d2=date.newInstance(2019, 5, 25);
        Date result=VerifyDate.CheckDates(d1,d2);
        System.assertEquals(d2, d2);
    }
    @isTest static void test2()
    {
        Date d1=date.newInstance(2019, 5, 25);
		Date d2=date.newInstance(2019, 5, 22);
        Date result=VerifyDate.CheckDates(d1,d2);
    }

}