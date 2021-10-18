@isTest
public class PaginationStep2TestClass {
    @isTest
    static void paginationTestCases()
    {
        DynamicObjectPagenationController d=new DynamicObjectPagenationController();
        d.selectedobj='None';
        d.selObjFields();
        d.selectedobj='Account';
        d.selObjFields();
        
        d.deselectedValues.add(new SelectOption('Id','Id'));
        d.deselectedValues.add(new SelectOption('Name','Name'));
        d.deselectedValues.add(new SelectOption('Phone','Phone'));
       
        
        System.assertEquals(0,d.selectedValues.size());
        System.assertEquals(54,d.deselectedValues.size());
        d.leftSelected.add('Id');
        d.leftSelected.add('Name');
        d.addList();
        System.assertEquals(2,d.selectedValues.size());
        System.assertEquals(52,d.deselectedValues.size());
        
        d.rightSelected.add('Id');
        d.rightSelected.add('Name');
        System.assertEquals(2,d.selectedValues.size());
        System.assertEquals(52,d.deselectedValues.size());
        d.removeList();
        System.assertEquals(54,d.deselectedValues.size());
        System.assertEquals(0,d.selectedValues.size());     
        
        d.selectedValues.add(new SelectOption('Id','Id'));
        d.selectedValues.add(new SelectOption('Name','Name'));
        d.fetchList();
        System.assertEquals('Id , Name ',d.fieldNameProcess);
        
        PageReference pr=page.DynamicObjectPagenationPage;
        Test.setCurrentPage(pr);
        d.resetPage();
    }
    
}