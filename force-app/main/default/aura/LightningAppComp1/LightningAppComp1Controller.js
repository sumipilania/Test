({
    // Method to fire application event
        fireApplicationEvent: function(component, event, helper) {
          
        var appEvent = $A.get("e.c:LightningApplicationEvent");
        appEvent.setParams({
            message: "Hello"
        });
        appEvent.fire();
        },
    
    // Method to  handle application event
    handleApplicationEvent: function(component, event, helper) {
           event.preventDefault(); 
         console.log('App1');
     
        var id = component.get('v.id');
        //alert('Application event in source component '+id);
    }
})