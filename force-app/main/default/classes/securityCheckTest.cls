public class securityCheckTest {
    
    public static List<Test1__c> objList {get; set;}
    public static void test() {
        List<Test1__c> obj = [SELECT name,fbfd__c, My__c FROM Test1__c WITH SECURITY_ENFORCED];
        System.debug('obj='+obj+' \nlength='+obj.size());
        objList = obj;
       // objList = obj;
    }

}