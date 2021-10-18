({
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    },
    closeModel : function(component, event, helper) {
        component.set("v.openModel", false);  
    },
    
    doInit : function(component, event, helper) {
        component.set("v.flagSave", "true");
        var action = component.get("c.requiredField");         
        action.setParams({
            sObjName :  component.get("v.sObjApiName"),
            fieldList : component.get("v.fieldApiList")
        });        
        action.setCallback(this, function(response) {
            var res = response.getReturnValue();
            console.log(res);
            component.set("v.recordList", res);  
        });           
        $A.enqueueAction(action); 
    },
    
    successHandler : function(component, event, helper) {  
      component.set("v.openModel", false);
    },
    submitHandler : function(component, event, helper) {
         event.preventDefault();
        console.log('Submit');
         component.find("accForm").submit();
    }
})