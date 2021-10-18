public class NewCaseListController {
    
      public List<Case> getNewCases()
    {
        List<Case> lst = [Select CaseNumber from Case where status='New'];
        return lst;
     }

}