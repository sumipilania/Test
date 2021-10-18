public class MyControllerAccount {
    
    Public Integer size{get;set;}
    Public Integer noOfRecords{get; set;}
    public List<SelectOption> paginationSizeOptions{get;set;}
    public String soql {get;set;}
    public List <Account> AccountList1 = New List <Account>();
    public String soqlsort {get;set;}
    public List <Account> AccountList2 = New List <Account>();
    //show how many records at a time
    public MyControllerAccount(){
        size=10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
    }
    //Show records from SObject 
    public ApexPages.StandardSetController con{
        get {
            if(con == null) {
                soql = 'select id,Name,Phone,Industry,BillingState from Account';
                AccountList1 = Database.query(soql + ' order by ' + sortField + ' ' + sortDir ); 
                con = new ApexPages.StandardSetController(AccountList1);
                con.setPageSize(size);
                noOfRecords = con.getResultSize();
            }
            return con;
        }
        set;
    }
    //Sorting Fields Wise
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        soqlsort = 'select id,Name,Phone,Industry,BillingState from Account'; 
        AccountList2 = Database.query(soqlsort + ' order by ' + sortField + ' ' + sortDir ); 
        con = new ApexPages.StandardSetController(AccountList2);
        con.setPageSize(size);
        noOfRecords = con.getResultSize();
    }
    //Select Ascending and Descending order
    public String sortDir {
       get  { 
           if (sortDir == null)
       	   {  
             sortDir = 'asc'; 
           } 
           return sortDir;
       }
        set;
    }
    
    //To reterive field wise sorting
    public String sortField {
        get  { 
            if (sortField == null) {
                sortField = 'Name'; 
            } return sortField;  
        }
        set;
    } 
    //get all records
    public List<Account> getAccounts() {
        return (List<Account>)con.getRecords();
    }
    //Reload Page
    public PageReference refreshPageSize() {
        //System.debug('Run Success');
        con.setPageSize(size);
        return null;
    }
    
 }