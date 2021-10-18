public class TypeAheadComponentController {
    public static String objectName{get;set;} //Select Object Name
    public String objectFieldName{get;set;}// Field Name
    public String searchTerm{get;set;} //String Which you search
    public String queryString{get;set;} //query pass to search and show detail page
    public  List<sObject> sObj{get;set;}//List of object to store  
    
    public TypeAheadComponentController(){
    }
    //Remoting to call from jQuery
    @RemoteAction
    public static List<String> autoCompleteMethod(String searchTerm, String objectName) 
    {
        String filter = ' like \'%' +searchTerm + '%\'';  //Fetch Name using  like Query
        String soql = 'select id, Name';
        soql = soql + ' from ' + objectName + ' where name' + filter;
        soql = soql +' limit 20';
        List<String> returnField = new List<String>();   //Return name of list which you want to search
        List<sObject> obj = Database.query(soql);
        
        //Return name of list
        for(sObject sObj : obj)
        {
            String tempStr = (String)sObj.get('Name');
            returnField.add(tempStr);
        } 
        return returnField;
    }
    
    //Detail Page Show
    public void detailPageShow() {
        sObj = Database.query('Select ID, Name from '+objectName+ ' where name LIKE :queryString');   
    }
    
}