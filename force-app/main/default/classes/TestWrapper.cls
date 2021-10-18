public class TestWrapper
{
 wrapper objwrapper;
 List<wrapper> lstwrapper=new List<wrapper>();
  public integer rowIndex{get;set;}
 
  public TestWrapper(){
  lst = new list<wrapper>();
     List<Account> lstaccount=[select name,industry,type from account]; 

     for(integer i=0;i<lstaccount.size();i++)
     {
       objwrapper=new wrapper();
       objwrapper.act=lstaccount[i];
        objwrapper.isEdit = false;
       objwrapper.rowNo = lst.size();
       lst.add(objwrapper);
     }
     
  }
 public List<wrapper> lst{get;set;}
 public pagereference editmethid(){
     if(lst.size()>rowIndex){
         lst[rowIndex].isEdit = true;
     }
     return null;
 }

  public pagereference savemethid(){
     if(lst.size()>rowIndex){
         update lst[rowIndex].act;   
         lst[rowIndex].isEdit = false;
     }
     return null;
 }

 public class wrapper{
 public Account act{get;set;}
 public integer rowNo {get;set;}
 public boolean isEdit{get;set;}
 }
}