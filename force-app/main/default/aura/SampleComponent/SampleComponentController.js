({
    doAction : function(component, event, helper) {
        var msg = 'Welcome to Salesforce Ohana';
        var msgMethod = component.get("v.vfMsgMethod");
        msgMethod(msg, function(){
            //handle callback
        });
    }
})