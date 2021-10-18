public class MyPicklistController {
    
    //--gets list of all objects 
    Map<String, Schema.SObjectType> globalDescribeObj = Schema.getGlobalDescribe();
    
    //---for api names
    List<String> apiNames = new List<String>(); //---for api names
    public String selectedObject {get;set;} //--gets the selected objects
   // public String selectedObjectCopy {get;set;}
    Public List<SelectOption> objectNames{get;set;} //--for object names 
    public List<String> addselectedFieldleft {get; set;} //--left side string
    public List<String> addselectedFieldright {get;set;} //--right side string
    public List<SelectOption> ObjectFieldstoright {get;set;} //---right side select option
    public List<SelectOption> availableFields{get;set;} //------left side select option
    public Map<String,String> getAllLeftField{get; set;}  //---stores the value of left select option to get the api, label name
    public List<String> showFields {get; set;}
    Public Boolean check{get;set;} // to disable component
    public Boolean flag{get;set;} //to disable lists
    public String query{get;set;} // gets the query of selected fields 
    Public MyPicklistController() { 
        fetchAllSobjects();  
    }
    //getting list of all sobjects
    public void fetchAllSobjects() {
       // PaginationComponentControllerWrapper pcw = new PaginationComponentControllerWrapper();
        check = false;
        objectNames = new List<SelectOption>{new SelectOption('None','None')};
             showFields = new List<String>();
            //GETTING THE API NAMES
            for(string objectApi : globalDescribeObj.keyset()){             
                apiNames.add(objectApi);
            }
        if(apiNames.size() > 0 ) {
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(apiNames);
            for(Schema.DescribeSobjectResult describeResult  : results){                
                if(describeResult.isUpdateable()  && describeResult.isSearchable() &&  describeResult.isQueryable()) { 
                    objectNames.add(new SelectOption(describeResult.getName(),describeResult.getLabel()));
                } 
            }
        }
        
    }
    
    //getting list of all fields from selected object
    public void fetchSobjectFields() {
      // PaginationComponentControllerWrapper pcw = new PaginationComponentControllerWrapper();
        query = null;
        flag = true;
        showFields.clear();
        getAllLeftField = new Map<String,String>();
        getAllLeftField.clear();
        ObjectFieldstoright = new List<SelectOption>();
        availableFields =  new List<SelectOption>();
        if(selectedObject != 'None') {
            check = false;
            Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(selectedObject).getDescribe().SObjectType.getDescribe().fields.getMap();
            for(Schema.SObjectField field : fields.values())            
            {          
                Schema.DescribeFieldResult fieldResult = field.getDescribe();            
                // check whether field is isUpdateable            
                if(fieldResult.isAccessible() && fieldResult.isUpdateable() && fieldResult.isCreateable() )                
                {               
                    //availableFields 
                    availableFields.add(new SelectOption(field.getDescribe().getName(),field.getDescribe().getLabel()));
                    getAllLeftField.put(field.getDescribe().getName(),field.getDescribe().getLabel()); 
                }
            }
            //selectedObjectCopy = selectedObject;
        } else {
            flag = false;
            check = false;
        }
    }
    //reset the page values
    public PageReference reset() {
        PageReference newpage = new PageReference(System.currentPageReference().getURL());        
        return newpage.setRedirect(true);
    }
    
    //adding the fields to rigth and removing selected fields from left
    public void addFields(){
        System.debug('add method');
        //showFields = new List<String>();
        for(String fields :addselectedFieldleft) { 
            ObjectFieldstoright.add(new selectOption(fields,getAllLeftField.get(fields)));
            System.debug(ObjectFieldstoright);
            availableFields.remove(availableFields.indexOf(new selectOption(fields,getAllLeftField.get(fields))));
        }
        System.debug('field in query '+showFields);
        showFields.clear();
        
      /*  for(selectOption o:ObjectFieldstoright) {
            showFields.add(o.getValue());
        }
        System.debug(showFields);*/
    }
    
    //adding the fields to left and removing selected fields from right
    public void removeFields() {
        System.debug('removeFields');
       //showFields = new List<String>();
        for(String fields :addselectedFieldright) { 
            availableFields.add(new selectOption(fields,getAllLeftField.get(fields)));
            ObjectFieldstoright.remove(ObjectFieldstoright.indexOf(new selectOption(fields,getAllLeftField.get(fields))));
        }     
        System.debug(' show field '+showFields);
        showFields.clear();
       /* System.debug(showFields);
        for(selectOption o:ObjectFieldstoright) {
            showFields.add(o.getValue());
        }
        System.debug(showFields);*/
    }
    
    
    
    public void process() { 
        
        System.debug('process');
        //showFields = new List<String>();
        for(selectOption o:ObjectFieldstoright) {
            showFields.add(o.getValue());
        }
        System.debug('field for query from process method '+showFields);
        
        check=true;
        query='';
        Integer compareSize=1;
        System.debug('fields: '+showFields);        
        for(String fields:showFields) {
            if(compareSize==showFields.size()) {
                query = query + fields;
            } else {
                query = query+fields+' ,';
                compareSize++;
            }
        }
        query = query +' from ' +selectedObject;
         System.debug('query from process: '+query);
        System.debug('selected obj '+selectedObject);
        
    }
}