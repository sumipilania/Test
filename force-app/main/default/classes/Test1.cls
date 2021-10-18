public class Test1 {
    @AuraEnabled
    public static List<Account> fetchList() {
		return [SELECT Id, Name FROM Account LIMIT 15];
	}
}