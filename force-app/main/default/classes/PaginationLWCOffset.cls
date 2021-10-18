public class PaginationLWCOffset {

  @AuraEnabled
   public static RecordWrapper fetchAccountList(String query,String selObjName){
        System.debug('query=='+query);
        Integer count = Database.countQuery('SELECT Count() from '+selObjName);
       return new RecordWrapper(Database.query(query),count);
   }

   public class RecordWrapper{
   @AuraEnabled public List<sObject> recList;
  @AuraEnabled  public Integer totalRec;
    public RecordWrapper(List<sObject> recList, Integer totalRec){
      this.recList = recList;
      this.totalRec = totalRec;

    }
   }
}