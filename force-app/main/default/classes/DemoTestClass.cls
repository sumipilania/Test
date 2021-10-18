@isTest
public class DemoTestClass {
    
    @isTest(SeeAllData=true)
    static void m1()
    {
        Account[] acc = [Select name from Account]; 
        System.debug('MY Acc='+acc);
    }
     @isTest
    static void m2()
    {
        Account[] acc2 = [Select name from Account]; 
        System.debug('MY M2='+acc2);
    }

}