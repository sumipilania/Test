public class A {
     
    Set<String> picklistValues = new Set<String> {'New York','California','Texas','Los Angeles','Chicago','San Francisco', 'Washington'};
    Public List<String> leftSelected {get;set;}
    Public List<String> rightSelected {get;set;}
    Set<String> leftValues = new Set<String>();
    Set<String> rightValues = new Set<String>();
     
    public A(){
        leftSelected = new List<String>();
        rightSelected = new List<String>();
        leftValues.addAll(picklistValues);
    }
     
    public PageReference getSelect(){
        rightSelected.clear();
        for(String s : leftSelected){
            leftValues.remove(s);
            rightValues.add(s);
        }
        return null;
    }
     
    public PageReference getDeselect(){    
        leftSelected.clear();
        for(String s : rightSelected){
            rightValues.remove(s);
            leftValues.add(s);
        }
        return null;
    }
     
    public List<SelectOption> getDeselectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> objList = new List<String>();
        objList.addAll(leftValues);
        objList.sort();
        for(String s : objList){
            options.add(new SelectOption(s,s));
        }
        return options;
    }
     
    public List<SelectOption> getSelectedValues(){
         
        List<SelectOption> options = new List<SelectOption>();
        List<String> objList = new List<String>();
        objList.addAll(rightvalues);
        objList.sort();
        for(String s : objList){
            options.add(new SelectOption(s,s));
String j = ' ';
        }
        return options;
    }
}