public class Custom_LookupController {
    
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String limitCount) {
        List<RecordsData> recordsDataList = new List<RecordsData>();
        String query = 'SELECT ' + filterField + ' FROM '+objectName +' WHERE '+filterField+' LIKE '+ '\'' + searchString +'%\' LIMIT ' +limitCount; 
        for(SObject s : Database.query(query)) {
            recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
        }     
        return recordsDataList;
    } 
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}