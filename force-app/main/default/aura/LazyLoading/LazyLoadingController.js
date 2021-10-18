({
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    },
    
    //Fetch All Records List when Component Load
    fetchAccList :  function(component,event,helper){        
        helper.fetchAccRec(component);
    },
    
    //When Scroller Move
    scroll : function(component,event, helper){
        var divObj = component.find("divHeight").getElement();
        var top = parseInt(divObj.scrollTop);
        top = top + 1;
        if(top + divObj.clientHeight >= divObj.scrollHeight)
        {
            var offSet = parseInt(component.get('v.offSet'));
            var totalRecords = parseInt(component.get('v.totalRecords'));         
            if(totalRecords >= offSet ){
                var offset = parseInt(component.get("v.offSet"));
                component.set("v.offSet",offset+20);
                var oldData = component.get('v.data');               
                helper.fetchAccRec(component);
            }    
            else{
                alert('We have already on Last records');
            }           
        }
    }       
})