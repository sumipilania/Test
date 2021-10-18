({
    doInit : function(component, event, helper) {
        var action = component.get("c.fetchContentDocument");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('respp===',response.getReturnValue());
                component.set('v.dataList', response.getReturnValue());
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);  
    },
    downloadDocument : function(component, event, helper){

  var sendDataProc = component.get("v.sendData");
     console.log('hyyyyyyyyyyyyyyy==',component.get('v.dataList'));
  var dataToSend = component.get('v.dataList');

  //invoke vf page js method
  sendDataProc(dataToSend, function(){
              //handle callback
  });
 }
    
 
})