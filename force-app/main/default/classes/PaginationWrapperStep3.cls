public class PaginationWrapperStep3 {
    
    public String queryField{get;set;}//Query String Hold
    public String queryObject{get;set;}  //Selected Object hold   
    public List<String> fieldList{get;set;}//list of selected field which you want to show on UI
    public String rId{get;set;}//Fetch  id's in wrapper list
    public List<sobject> deleteRecords;//Selected Records Delete hold all value
    public Integer size{get;set;}//Maintain Records Size
    public List<SelectOption> paginationSizeOptions{get;set;}// Option on How many reocrds show at a time
    public Map<Id, WrapperClass> mapHoldingSelectedRecords{get;set;} //Hold state by Map
    public ApexPages.StandardSetController setCon{get;set;} //Query Fetch Using Standard Set Controller
    public List<WrapperClass> wrapClassList{get;set;}
    public List<String> indexList{get;set;}//Filters Alphbaet label
    public String alphaSeries{get;set;}//Hold Ony by One Alphabet we click on link
    public List<String> otherList{get;set;} //'Other' Alphbaet label
    public String csv {get;set;} //String for Csv comma seprated column and records hold
    public String sortField{get;set;}//Field Name for sorting
    public String sortDir{get;set;}//select order of soring asc and desc
    
    public PaginationWrapperStep3() {
        size=5;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        mapHoldingSelectedRecords = new Map<Id, WrapperClass>(); //State Maintain by Using Map  
        setCon = new ApexPages.StandardSetController(new List<Account>()); //First Time Class Load
        indexList=new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','Other','All'}; //Filter Label
        otherList=new List<String>{'A%','B%','C%','D%','E%','F%','G%','H%','I%','J%','K%','L%','M%','N%','O%','P%','Q%','R%','S%','T%','U%','V%','W%','X%','Y%','Z%'}; //'Other' link value in Filters
     	sortField='Name';
        sortDir='asc';
       wrapClassList=new List<WrapperClass>();
     }
    
    //Query Fetch Records
    public void apexStanadredControl()
    {
        try{
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator('SELECT '  +  queryField  + 'FROM ' +  queryObject + ' order by ' + sortField + ' ' + sortDir));
        }
        catch(Exception c)
        {
            new List<WrapperClass>(); 
        }
    }
    
    //Add Fields With record in wrapper class
    public void fetchWrapperList()
    {
        wrapClassList=new List<WrapperClass>();
        setCon.setPageSize(size);
        for(sobject s: (List<sObject>) setCon.getRecords())
        {
            
            if(mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(s.id)){
                wrapClassList.add(mapHoldingSelectedRecords.get(s.id));
            }
            else{
                wrapClassList.add(new WrapperClass(s,false));
            }
        }
    }
    
    //Without Use Getter And Setter in Call Function By Vf Page to Initlization Of Component
    public void tempCall()
    {
        apexStanadredControl();  
        fetchWrapperList();
    }
    
    //Specific Record Delete
    public void deleteSpecificRec()
    {
        System.debug('My id=='+rid);
        Database.delete(rId); //Delete Record Specific Id
        tempCall();
    }
    
    //Selected Records Are Deleted
    public void deleteSelectedRec()
    {
        deleteRecords=new List<sobject>();
        for(WrapperClass rec: wrapClassList)
        {
            if(rec.selected==true)
            {
                deleteRecords.add(rec.sobjecIns);
            }
        }
        Database.delete(deleteRecords);
        tempCall();
    }
    public void refreshPageSize() {
        setCon.setPageSize(size);
        updateSearchItemsMap();
        fetchWrapperList();
       }
   
    //Performing Sorting
    public void toggleSort()
    {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        tempCall();
    }
    
    //Filters Alphabetacilly 
    public void listOfAlpha()
    {
        if(alphaSeries.equals('All'))
        {
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator('SELECT '  +  queryField  + 'FROM ' +  queryObject + ' order by ' + sortField + ' ' + sortDir));
        }
        else if(alphaSeries.equals('Other'))
        {
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator('SELECT '  +  queryField  + 'FROM ' +  queryObject +' where NOT name  LIKE :otherList'));
        }
        else
        {
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator('SELECT '  +  queryField  + 'FROM ' +  queryObject +' where name LIKE \''+ alphaSeries+'%\''));
        }
       fetchWrapperList();
    }
   
    // return total number of pages for page set
    Public Integer getTotalPages(){
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
        Decimal pages = totalSize/pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    // returns the first page of the page set
    public void first() {
        updateSearchItemsMap();
        setCon.first();
        fetchWrapperList();
    }
    
    // returns the last page of the page set
    public void last() {
        updateSearchItemsMap();
        setCon.last();
        fetchWrapperList();
    }
    
    // returns the previous page of the page set
    public void previous() {
        updateSearchItemsMap();
        setCon.previous();
        fetchWrapperList();
    }
    
    // returns the next page of the page set
    public void next() {
        System.debug('My Header=='+csv);
        updateSearchItemsMap();
        setCon.next();
        fetchWrapperList();
    }
    
    //This is the method which manages to remove the deselected records, and keep the records which are selected in map.
    public void updateSearchItemsMap() {
        for(WrapperClass wrp : wrapClassList){
            if(wrp.selected){
                mapHoldingSelectedRecords.put(wrp.sobjecIns.id, wrp);
            }
            if(wrp.selected == false && mapHoldingSelectedRecords.containsKey(wrp.sobjecIns.id)){
                mapHoldingSelectedRecords.remove(wrp.sobjecIns.id);
            }
        }
    }
    
    public void downloadCsv()
    {
        updateSearchItemsMap();
        csv='';
        Integer i=1;
        for(String fieldHeader : fieldList)
        {
            if(i==fieldList.size())
            {
                csv=csv+'\"'+fieldHeader+'\"';
                i++;
            }
            else
            {
                csv=csv+'\"'+fieldHeader+'\",';
                i++;
            }
         }
        csv=csv+'\\n';
        String recData='';
        String row;
        List<sobject> sObjectList = new List<sObject>();
        for(WrapperClass s : mapHoldingSelectedRecords.values())
        {
            row='';
            if(s.selected == true)
            {
                for(String fieldWrap : fieldList)
                {
                    row=row+'\"'+s.sobjecIns.get(fieldWrap)+'\",';   
                }
                row=row+'\\n';
            }
            csv=csv+row;
         }
    }
    
    //Wrapper Class
    public class WrapperClass {
        public sobject sobjecIns {get; set;}
        public Boolean selected {get; set;}
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public WrapperClass(sobject a, boolean b) {
            sobjecIns = a;
            selected = b;
         }
    }
}