({
    checkStatusOfDeploy : function(component) {
        var action = component.get('c.checkCodeStatus');
        action.setParams({
            statusId : component.get("v.asyncId")
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){
                var resList = [];
                resList = response.getReturnValue();
                var state = resList[0];
                if(state=='Completed'){
                    component.set("v.successFlag",true);
                    component.set("v.Spinner", false);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type"  : "success",
                        "message": "Your Code Successfully deployed"
                    });
                    toastEvent.fire();
                }else if(state=='Failed'){
                    component.set("v.successFlag",true);
                    component.set("v.Spinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type"  : "Error",
                        "message": resList[1]
                    });
                    
                    toastEvent.fire();
                    
                }
            }
            component.set("v.saveFlag", true);
            component.set("v.deployFlag", true);
            component.set("v.editFlag", false);
            component.set("v.readFlag", true);
        });
        $A.enqueueAction(action); 
    }
})