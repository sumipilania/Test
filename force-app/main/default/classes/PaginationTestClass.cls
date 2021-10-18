@isTest
class PaginationTestClass {
    @TestSetup
    static void fetchRecords(){
        List<Account> accLst = new List<Account>();
        for(integer i=1; i<=100; i++){
            accLst.add(new Account(Name='a'+i));
        }
        insert accLst;
    }
    
    @isTest
    static void basic_TestCases(){
        
        Test.startTest();
        PaginationWrapperStep3 p=new PaginationWrapperStep3();
        PaginationWrapperStep3.WrapperClass obj=new PaginationWrapperStep3.WrapperClass(new Account(),false);
        p.queryObject = ' Account ';
        p.queryField = ' Id , Name ';
        System.assertEquals(0,p.setCon.getResultSize());
        p.apexStanadredControl();
        System.assertEquals(100,p.setCon.getResultSize());
        
        p.fetchWrapperList();
        system.assertEquals(false, obj.selected);
        
        system.assertEquals(5, p.wrapClassList.size());
        p.wrapClassList[3].selected=true;
        p.updateSearchItemsMap();
        p.fetchWrapperList();
        p.tempCall();
        
        system.assertEquals(100, p.setCon.getResultSize());
        String recName='a1';
        p.rId=Database.query('select id from account where name =: recName').id;
        p.deleteSpecificRec();
        system.assertEquals(99, p.setCon.getResultSize()); 
        
        p.wrapClassList[4].selected=true;
        p.wrapClassList[2].selected=true;
        p.deleteSelectedRec();
        system.assertEquals(97, p.setCon.getResultSize());
        
        p.setCon.setPageSize(5);
        p.refreshPageSize();
        System.assertEquals(5, p.wrapClassList.size());
        p.setCon.setPageSize(10);
        p.size=10;
        p.refreshPageSize();
        p.apexStanadredControl();
        System.assertEquals(10, p.wrapClassList.size());
        
        p.sortDir='asc';
        p.toggleSort();
        
        p.alphaSeries='All';
        p.listOfAlpha();
        System.assertEquals(10, p.wrapClassList.size());
        
        p.alphaSeries='Other';
        insert new Account(Name='-');
        p.listOfAlpha();
        System.assertEquals(1, p.setCon.getResultSize());
        
        p.alphaSeries='B';
        p.listOfAlpha();
        System.assertEquals(0, p.setCon.getResultSize());
        
        p.getTotalPages();
        
        p.first();
        System.assertEquals(1,p.setCon.getPageNumber());
        
      
   	   p.last();
       p.tempCall();
       Decimal pageNum=p.setCon.getResultSize() / p.setCon.getPageSize();
       System.assertEquals(9,(Integer)pageNum.round(System.RoundingMode.CEILING));
        
       p.tempCall();
       p.next();
       string nextStr=p.wrapClassList[0].sobjecIns.get('Name').toString();
	   System.assertEquals('a9', nextStr);
     
       p.tempCall();
       p.previous();
       string prevStr=p.wrapClassList[1].sobjecIns.get('Name').toString();
       System.debug('Index='+prevStr);
	   System.assertEquals('a98', prevStr); 
     
 	  p.tempCall();
      List<String> fList=new List<String>(); 
      fList.add('Name');
      fList.add('id');  
      p.fieldList=fList;
      p.downloadCsv(); 
      Test.stopTest(); 
    }
}