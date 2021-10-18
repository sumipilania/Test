public class CustomEditButtonControlller {
    
    public static Account acct;
    public Id avd {get;set;}
    public CustomEditButtonControlller(ApexPages.StandardController stdController) {
        acct = (Account)stdController.getRecord();
      System.debug('acct Cons='+acct);
    }
    
    public PageReference onpageLoad()
    {
        avd = acct.id;
        PageReference editPage = new PageReference('/'+acct.id+'/e?nooverride=1');
        editPage.getParameters().put('retURL','/'+'0012v00002jskZNAAY');
        editPage.setRedirect(true);
        System.debug('onload acct='+acct);
        return editPage; 
    }
   
}