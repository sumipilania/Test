({  
    doInit : function(component, event, helper) {
        var action = component.get('c.fetchApexClass');
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.classNameList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    },
    
    onSelectChange : function(component, event, helper) {
        component.set("v.Spinner", true);
        var classId = event.getSource().get("v.value");
        component.set("v.classId",classId);
        var action = component.get('c.fetchBody');
        action.setParams({
            classId : component.get("v.classId"),
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){
                var classNamelst =  response.getReturnValue();
                component.set("v.body",classNamelst[0].Body);
                component.set("v.className",classNamelst[0].Name);
                component.set("v.Spinner", false);
                component.set("v.readFlag", true);
                component.set("v.saveFlag", true);
                component.set("v.deployFlag", true);
                component.set("v.editFlag", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    edit : function(component, event, helper) {
        component.set("v.readFlag", false);
        component.set("v.saveFlag", false);
        component.set("v.deployFlag", true);
        component.set("v.editFlag", true);
    },
    
    save : function(component, event, helper) {
        component.set("v.Spinner", true);
        var body = component.get("v.body");
        var jsonBody = {};
        jsonBody.Body = body;
        var tempBody = JSON.stringify(jsonBody);
        tempBody = tempBody.substring(1, (tempBody.length-1));
        var action = component.get('c.containerDetailCheck');
        action.setParams({
            classId : component.get("v.classId"),
            classBody : tempBody,
            className : "ThirdContainer"
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){
                var containerList = response.getReturnValue();
                component.set("v.containerId",containerList[0]);
                component.set("v.apexMemId",containerList[1]);
                component.set("v.Spinner", false);
                component.set("v.saveFlag", true);
                component.set("v.deployFlag", false);
                component.set("v.editFlag", false);
            }
        });
        $A.enqueueAction(action); 
    },
    
    deploy : function(component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.successFlag",false);
        var action = component.get('c.containerAsyncRequest');
        action.setParams({
            containerId : component.get("v.containerId"),
            apexMid     : component.get("v.apexMemId"),
            classId : component.get("v.classId")
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.asyncId",response.getReturnValue());
                window.setInterval(
                    $A.getCallback(function() { 
                        var success = component.get("v.successFlag");
                        if(success==false){
                            helper.checkStatusOfDeploy(component);
                        }
                    }), 3000
                );  
            }
        });
        $A.enqueueAction(action); 
    },
})