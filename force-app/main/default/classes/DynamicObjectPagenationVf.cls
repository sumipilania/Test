public class DynamicObjectPagenationVf {
    public Map<String,schema.SObjectType> allobj{get;set;}  //fetch
    Public Map<String,schema.SObjectField> selobjmap{get;set;}
    public List<String> objnames{get;set;}
    
    Public List<selectoption> options{get;set;}
    Public List<selectoption> objfieldoptions{get;set;}
    Public String selectedobj{get;set;}
    public List<String> rightValuesList{get;set;}
    
    public Set<string> leftValues{get;set;}
    public Set<String> rightValues{get;set;}
    
    Public List<String> leftSelected {get;set;}
    Public List<String> rightSelected {get;set;}
    
    public String fieldNameProcess{get;set;}
    public boolean flag{get;set;}
    public boolean showComp{get;set;}
    
    //Show Object List and Fields List and List and Set Created Objetct
    public DynamicObjectPagenationVf()
    {
        allobj=schema.getGlobalDescribe();
        rightValues= new Set<String>();
        objnames= new List<string>();
        options=new List<selectoption>();
        leftSelected = new List<String>();
        rightSelected = new List<String>();
        objnames.addAll(allobj.keySet());
        objnames.sort();
        options=new List<selectoption>{new selectoption('None','None')};
            Schema.DescribeSobjectResult[] results  = Schema.describeSObjects(objnames);   
        for(Schema.DescribeSobjectResult describeResult  : results){                
            if(describeResult.isAccessible() && describeResult.isUpdateable() && describeResult.isCreateable() && describeResult.isQueryable() && describeResult.isSearchable()) {                    
                options.add(new SelectOption(describeResult.getName(),describeResult.getLabel()));
            }
        }
        
    }
    //Fetch Fields from SObject
    public void getSelObjFields()
    {      
        if(selectedobj.equals('None'))
        {
            flag=false;
        }
        else
        {
            flag=true;
            showComp=false;
            Schema.DescribeSObjectResult  dfr = allobj.get(selectedobj).getDescribe();
            selobjmap =dfr.fields.getMap();
            leftValues= new Set<string>();
            objfieldoptions=new List<selectoption>();
            leftValues.addAll(selobjmap.keySet());
            rightValues.clear();
        }    
    }
    //Store Selected Fields Add Button
    public void addList(){
        rightSelected.clear();
        for(String s : leftSelected){
            //  System.debug('index='+s.indexOf(s)); 
            //  System.debug('Select='+leftSelected);
            leftValues.remove(s);  
            rightValues.add(s);
        }
        
    }
    //Store Not Selected Fields Remove Button
    public void removeList(){    
        leftSelected.clear();
        for(String s : rightSelected){
            rightValues.remove(s);
            leftValues.add(s);
        }
        
    }
    //Show All Fields without selected
    public List<SelectOption> getDeselectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> objList = new List<String>();
        //System.debug(leftValues); 
        objList.addAll(leftValues);
        objList.sort();
        for(String s : objList){
            options.add(new SelectOption(s,s));
        } 
        return options;
    }
    //Show All selected Fields
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> objList = new List<String>();
        objList.addAll(rightvalues);
        objList.sort();
        for(String s : objList){
            options.add(new SelectOption(s,s));
        }
        return options;
        
    }
    public PageReference resetPage() {
        PageReference newpage = new PageReference(System.currentPageReference().getURL());
        newpage.setRedirect(true);
        return newpage;
    }
    public void fetchList()
    {
        
        rightValuesList=new List<String>(rightValues);
        showComp=true;
        Integer sizeEqual=1;
        fieldNameProcess='';
        //System.debug('fields=='+rightValues);
        for(String field:rightValues)
        {
            if(sizeEqual==rightValues.size())
            {
                fieldNameProcess=fieldNameProcess+field+' ';
            }
            else
            {
                fieldNameProcess=fieldNameProcess+field+' , ';
                sizeEqual++;
            }
        }
      
    }
}