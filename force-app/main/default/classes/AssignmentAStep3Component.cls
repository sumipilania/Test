public class AssignmentAStep3Component {
    
    public String queryField{
        get{
            return queryField;
        }
        set;}
    public String queryObject{
        get{
            
            return queryObject;
        }set;}        
    public List<String> fieldList{
        get{
            return fieldList;
        }
        
        set;}
    public String rId{get;set;}
    
    public List<sobject> deleteRecords;
    public Integer size{get;set;}
    public Integer noOfRecords{get; set;}
    public List<SelectOption> paginationSizeOptions{get;set;}
    
  //  public List<WrapperClass> wrapperRecordList{get;set;}
    public Map<Id, WrapperClass> mapHoldingSelectedRecords{get;set;}
    
    // public String soqlQuery='SELECT '  +  queryField  + 'FROM ' +  queryObject;
    // 
    public AssignmentAStep3Component()
    {
        
        size=5;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        mapHoldingSelectedRecords = new Map<Id, WrapperClass>();
        try{
            init();
        }
        catch(Exception e)
        {
            System.debug('Const Sent Con');
            setCon = new ApexPages.StandardSetController(new List<Account>());
            
        }
        
    }
    
    public void init()
    {
        System.debug('init');
        
        wrapperRecordList = new List<WrapperClass>();
        for(sobject s: (List<sObject>) setCon.getRecords())
        {
            if(mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(s.id)){
                wrapperRecordList.add(mapHoldingSelectedRecords.get(s.id));
            }
            else{
                wrapperRecordList.add(new WrapperClass(s,false));
            }
        }
    }
       
public List<WrapperClass> wrapperRecordList{get;set;}
    
    public ApexPages.StandardSetController setCon{get;set;}
    
    
    
    /*  public List<WrapperClass> getwrapClassList()
{
wrapClassList=new List<WrapperClass>();
setCon = new ApexPages.StandardSetController(Database.getQueryLocator('SELECT '  +  queryField  + 'FROM ' +  queryObject));
for(sobject s: (List<sObject>) setCon.getRecords())
{
if(mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(s.id)){
wrapClassList.add(mapHoldingSelectedRecords.get(s.id));

}
else{
wrapClassList.add(new WrapperClass(s,false));
}
}
return wrapClassList;
}*/
public void initSetCtrl(){
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator('SELECT '  +  queryField  + 'FROM ' +  queryObject));
            init();
            
            
            
            // sets the number of records to show in each page view
            setCon.setPageSize(size);

}
    
    public void deleteSpecificRec()
    {
        Database.delete(rId); //Delete Record Specific Id
    }
    public void deleteSelectedRec()
    {
        deleteRecords=new List<sobject>();
        for(WrapperClass rec: wrapperRecordList)
        {
            if(rec.selected==true)
            {
                deleteRecords.add(rec.sobjecIns);
            }
            
        }
        Database.delete(deleteRecords);
    }
    public void refreshPageSize() {
        //System.debug('Run Success');
        
        setCon.setPageSize(size);
        
    }
    
    
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    
    /** indicates whether there are more records before the current page set.*/
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    /** returns the page number of the current page set*/
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    /** return total number of pages for page set*/
    Public Integer getTotalPages(){
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
        Decimal pages = totalSize/pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    
    /** returns the first page of the page set*/
    public void first() {
        updateSearchItemsMap();
        setCon.first();
        init();
    }
    
    /** returns the last page of the page set*/
    public void last() {
        updateSearchItemsMap();
        setCon.last();
        init();
    }
    
    /** returns the previous page of the page set*/
    public void previous() {
        updateSearchItemsMap();
        setCon.previous();
        init();
    }
    
    /** returns the next page of the page set*/
    public void next() {
        updateSearchItemsMap();
        setCon.next();
        init();
    }
    
    //This is the method which manages to remove the deselected records, and keep the records which are selected in map.
    public void updateSearchItemsMap() {
        //System.debug('My List'+wrapClassList);
        for(WrapperClass wrp : wrapperRecordList){
            if(wrp.selected){
                mapHoldingSelectedRecords.put(wrp.sobjecIns.id, wrp);
            }
            if(wrp.selected == false && mapHoldingSelectedRecords.containsKey(wrp.sobjecIns.id)){
                mapHoldingSelectedRecords.remove(wrp.sobjecIns.id);
            }
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