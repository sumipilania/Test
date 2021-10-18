public class Step2 {
    public Map<String,schema.SObjectType> allobj{get;set;}
    Public Map<String,schema.SObjectField> selobjmap{get;set;}
    public List<String> objnames{get;set;}
   
    Public List<selectoption> options{get;set;}
    Public List<selectoption> objfieldoptions{get;set;}
    Public String selectedobj{get;set;}
    
    Public List<String> leftSelected {get;set;}
    Public List<String> rightSelected {get;set;}
    //Show Object List and Fields List and List and Set Created Objetct
    public Step2()
    {
        allobj=schema.getGlobalDescribe();
        objnames= new List<string>();
        options=new List<selectoption>();
        leftSelected = new List<String>();
        rightSelected = new List<String>();
        //selobjfields=new Map<String,schema.SObjectField>();
        objnames.addAll(allobj.keySet());
        objnames.sort();
        for(string s:objnames)
        {
            options.add(new selectoption(s,s));
           
        } 
      //  System.debug(options);
       selectedobj='acceptedeventrelation';
       getSelObjFields();
       
    }
    //Fetch Fields from SObject
    public void getSelObjFields()
    {
       // System.debug('obj' +allobj);
        // Schema.DescribeFieldResult dfr = Schema.SObjectType.Account.fields.Name;
        Schema.DescribeSObjectResult  dfr = allobj.get(selectedobj).getDescribe();
        selobjmap =dfr.fields.getMap();
        //System.debug('fields' +selobjfields);
        leftSelected= new List<string>();
        objfieldoptions=new List<selectoption>();
        leftSelected.addAll(selobjmap.keySet());
        for(string s1:leftSelected)
        {
            objfieldoptions.add(new selectoption(s1,s1));
            System.debug('Before'+objfieldoptions);
        }   
        System.debug('after'+objfieldoptions);
         rightSelected.clear();
    }
    //Store Selected Fields Add Button
    public PageReference getSelect(){
        rightSelected.clear();
        for(String s : leftSelected){
            leftSelected.remove(s.indexOf(s));
            rightSelected.add(s);
        }
        return null;
    }
    //Store Not Selected Fields Remove Button
     public PageReference getDeselect(){    
        leftSelected.clear();
        for(String s : rightSelected){
            rightSelected.remove(s.indexOf(s));
            leftSelected.add(s);
        }
        return null;
    }
    public List<SelectOption> getDeselectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> objList = new List<String>();
        objList.addAll(leftSelected);
        objList.sort();
        for(String s : objList){
            options.add(new SelectOption(s,s));
        }
        return options;
    }
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> objList = new List<String>();
        objList.addAll(rightSelected);
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
}