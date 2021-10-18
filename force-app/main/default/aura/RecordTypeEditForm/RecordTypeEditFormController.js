({
    /*call apex controller method "fetchContentDocument" to get salesforce file records*/
    doInit : function(component, event, helper) {
        var action = component.get("c.fetchRecordTypeList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('respp===',response.getReturnValue());
                component.set("v.recList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },
    onSelectChange : function(component, event, helper) {
        var recId = event.getSource().get("v.value");
        component.set("v.recodId",recId);
    },
    
    onParent : function(component, event, helper) {
	   //Parent Selected Id
	    console.log(component.find("parent").get("v.value"));
    }
})