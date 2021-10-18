({
	getInfo : function(component, event, helper) {       
        var action = component.get('c.userDetail');	
        action.setParams({
            
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {
                var resp = response.getReturnValue();
                console.log(resp);
               component.set('v.userObj',resp);

            }
        });
        $A.enqueueAction(action);  
    },
})