public class TestPopup {
@TestVisible private final opportunity opp;
    public ApexPages.StandardController stdCon;
    public boolean isChanged{get;set;}
    public string callfunc{get;set;}
    public opportunity currentOpp{
        get{
            currentopp=[select leadSource from opportunity where id=:this.opp.id limit 1];
        return currentopp;
        }
        set;}

    public TestPopup(ApexPages.StandardController stdCon){
        this.opp=(opportunity)stdCon.getRecord();
        
    }  
    public void test(){
        if(currentOpp.LeadSource!=this.opp.LeadSource){
            isChanged=true;
        }
        update this.opp;
    }
    public pagereference redirectMethod(){
        PageReference pageRef=new PageReference('/' + this.opp.id);
        return pageRef;
    }
}