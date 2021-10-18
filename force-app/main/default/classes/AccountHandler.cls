public class AccountHandler {
    
    public static void insertNewAccount(String name1)
    {
        Student__c ac=new Student__c(Name=name1,Faculty__c='a012v00001zPVXj');
        insert ac;
        System.debug(ac);
 
}
}