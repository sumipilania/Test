({
    sendMessage : function(component, event) {
        var body = component.find("bodyBox").get("v.value");
        var recordId = component.get("v.recordId");
        var action = component.get("c.sendMessage");
        action.setParams({
            contId : recordId,
            message: body
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                if(resp=='Success'){
                    var recList = component.get("v.recList");
                    recList.push({"Status":"Outbound","Body":body});
                    component.set("v.recList",recList);
                    component.find("bodyBox").set("v.value","");
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Something Wrong!",
                        "type" : "Error",
                        "message": "Something Wrong Please check phone number"
                    });
                    toastEvent.fire(); 
                }
            }
        });
        $A.enqueueAction(action);
        
    }
})