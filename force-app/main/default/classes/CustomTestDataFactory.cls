public class CustomTestDataFactory {
    
    public static List<sobject> createSObjectRecords(String sobjName, String apiFieldName, Integer numOfRecords){
        List<sObject> sObjList = new List<sObject>();
        for(Integer i = 1; i <= numOfRecords; i++){
           // sObjList.add(new sobjName())
        }
        insert sObjList;
        return sObjList;
    }

}