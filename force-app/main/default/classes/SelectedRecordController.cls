public with sharing class SelectedRecordController {
    public List<Account> selAccLst;
    public String accIds;

    // Constructor
    public SelectedRecordController(ApexPages.StandardSetController cntlr){
         selAccLst = cntlr.getSelected(); //get selected records from account list view
         accIds = '';  
         for(Account acc : selAccLst){
             accIds += acc.Id + ','; //build list of ids string concatenated with comma                         
          }
         accIds = accIds.removeEnd(','); 
    } 

    public PageReference redirectToLC(){
          String returnUrl = '/lightning/cmp/c__ShowSelectedRecord?c__listofAccounts='+accIds;
          PageReference pgReturnPage = new PageReference(returnUrl);
          pgReturnPage.setRedirect(true);
          return pgReturnPage;
    }
}