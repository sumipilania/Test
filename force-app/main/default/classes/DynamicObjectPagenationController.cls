/*  Class Name = DynamicObjectPagenationController
Name = Sumit Pilaniya
Date = 10/07/2019
Description = This class based on dynamic apex and Show all fields in avaliable list and we can add remove fields from selected list  
*/

public class DynamicObjectPagenationController {
    public Map<String,schema.SObjectType> allobj;  //Store all dynamic object 
    public List<String> objnames{get;set;}//Store all dynamic object's api name
    Public List<selectoption> options{get;set;}// hold all object option list
    Public String selectedobj{get;set;}//hold Selected object
    Public List<String> leftSelected {get;set;}//selected list from avaliable list
    Public List<String> rightSelected {get;set;}// hold selected list from right side 
    public String fieldNameProcess{get;set;}//make a query from fields
    public boolean flag{get;set;}//manage show and hide output panel
    public boolean showComp{get;set;}//manage component hide and show
    public List<SelectOption> deselectedValues{get;set;}//Avaliable fields store from dynamic object
    public Map<String,String> fieldsApiMap{get; set;}//Map which hold api name and label  
    public List<SelectOption> selectedValues{get;set;}//selected field show in right side
    public List<String> rightFieldApiNameList{get;set;}//list which make a query and send apex to controller 
    
    //Initlizae all memebers and fetch dynamic object
    public DynamicObjectPagenationController()
    {
        allobj=schema.getGlobalDescribe();
        objnames = new List<string>();
        options = new List<selectoption>();
        leftSelected = new List<String>();
        rightSelected = new List<String>();
        objnames.addAll(allobj.keySet());
        objnames.sort();
        options=new List<selectoption>{new selectoption('None','None')};
            Schema.DescribeSobjectResult[] results  = Schema.describeSObjects(objnames);   
        for(Schema.DescribeSobjectResult describeResult  : results){                
            if(describeResult.isQueryable() && describeResult.isSearchable() && describeResult.isUndeletable()) {                    
                options.add(new SelectOption(describeResult.getName(),describeResult.getLabel()));
            }
        }
    }
    
    //Fetch Fields from SObject
    public void selObjFields()
    {    
        deselectedValues =  new List<SelectOption>();
        selectedValues =  new List<SelectOption>();
        fieldsApiMap = new Map<String,String>();
        fieldsApiMap.clear();
        if(selectedobj.equals('None'))
        {
            flag = false;
        }
        else
        { 
            flag = true;
            showComp = false;
            Map<String, Schema.SObjectField> sObjectfields = Schema.getGlobalDescribe().get(selectedobj).getDescribe().SObjectType.getDescribe().fields.getMap();
            for(Schema.SObjectField field : sObjectfields.values())            
            {          
                Schema.DescribeFieldResult fieldResult = field.getDescribe();                    
                if(fieldResult.isAccessible() && fieldResult.isCreateable() && fieldResult.isSortable() )                
                {               
                    deselectedValues.add(new SelectOption(field.getDescribe().getName(),field.getDescribe().getLabel()));
                    fieldsApiMap.put(field.getDescribe().getName(),field.getDescribe().getLabel()); 
                }
            }
        }    
    }
    
    //Add fields selected fields from avaliable list to selected list
    public void addList(){
        for(String fields :leftSelected) { 
            selectedValues.add(new selectOption(fields,fieldsApiMap.get(fields)));
            deselectedValues.remove(deselectedValues.indexOf(new selectOption(fields,fieldsApiMap.get(fields))));
        }
    }
    
    //Remove fields from selected list to avaliable list
    public void removeList(){    
        for(String fields :rightSelected) { 
            deselectedValues.add(new selectOption(fields,fieldsApiMap.get(fields)));
            selectedValues.remove(selectedValues.indexOf(new selectOption(fields,fieldsApiMap.get(fields))));
        }     
    }
    
    //Reset Page
    public PageReference resetPage() {
        PageReference newpage = new PageReference(System.currentPageReference().getURL());
        newpage.setRedirect(true);
        return newpage;
    }
    
    //In this method we made query of fields which is fatch from sObject
    public void fetchList()
    {
        rightFieldApiNameList=new List<String>();  
        for(selectOption o:selectedValues) {
            rightFieldApiNameList.add(o.getValue());
        }
        showComp=true;
        Integer sizeEqual = 1;
        fieldNameProcess = '';
        for(String field:rightFieldApiNameList)
        {
            if(sizeEqual == rightFieldApiNameList.size())
            {
                fieldNameProcess=fieldNameProcess+field+' ';
            }
            else
            {
                fieldNameProcess = fieldNameProcess+field+' , ';
                sizeEqual++;
            }
        }
       
    }
}