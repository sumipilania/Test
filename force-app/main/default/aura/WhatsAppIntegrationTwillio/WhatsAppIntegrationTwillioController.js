({
    
    handleClick : function(component, event, helper) {
        helper.sendMessage(component, event);
    },
    
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.fetchChat");
        action.setParams({
            conId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(parseInt(result.length) > 0){
                    component.set("v.compFlag", true);
                    var tempList = [];
                    for(var i in result){
                        tempList.push({"Status":result[i].StatusMsg__c, "Body":result[i].Body__c});
                    }
                    component.set("v.recList", tempList);
                }else{
                    component.set("v.compFlag", false);
                }
            }           
        });
        $A.enqueueAction(action);
    },
    startChat : function(component, event, helper) {
        component.set("v.compFlag", true);
    },
    
    bodyMsg : function(component, event, helper) {
    }
    
})