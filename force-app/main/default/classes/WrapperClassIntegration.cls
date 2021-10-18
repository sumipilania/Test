public class WrapperClassIntegration 
{
    public List<Entry> entries {get;set;} //Entries Object in JSON
    public String link {get;set;} //Temporary Link to Used Download File  	
    public class Entry
    {
        public String name {get;set;} //Access Files And Folder Using Name
        public String tag {get;set;}  // Identify Which is file and which Folder
        public String id {get;set;}	  //Id of folder and files
    }  
}