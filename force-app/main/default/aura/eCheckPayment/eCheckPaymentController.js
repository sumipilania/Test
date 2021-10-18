({

    placeOrderHandler : function(component, event, helper) {
        var card = component.find("cardId").get("v.value");
        var cvv = component.find("cvv").get("v.value");
         var month = component.find("month").get("v.value");
         var year = component.find("year").get("v.value");
        console.log('card==',card);
        console.log('cvv==',cvv);
        if(card=='' || cvv=='' || month=='' || year==''){
            component.set("v.flag",true);
             component.set("v.errorFlag",true);
            component.set("v.errorMsg","Please Fill All Fields"); 
        }else{
            if(!(isNaN(cvv) || isNaN(card))){
                console.log('inide');
                helper.creaditCard(component);
            }
            else{
                component.set("v.flag",true);
                  component.set("v.errorFlag",true);
                component.set("v.errorMsg","Please Check Format");
            }
        }
    },
   
    echeckHandler : function(component, event, helper) {
         var action = component.get('c.echeck');
        action.setParams({
            routingNum : '12354',
            accNo : '325411',
            nameOnAcc : 'Sumit'
            
            
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {
				var result = response.getReturnValue();
                console.log('resp==',result);
               // component.set("v.flag",true);
                console.log('id===',result[0].transId);
               var tranId = result[0].transId;
                if(tranId=='0'){
                    // component.set("v.transIdflag",false);
                     //component.set("v.errorFlag",true);
                     //component.set("v.errorMsg",result[0].errors[0].errorText);
                }else{
                     // component.set("v.errorFlag",false);
                    //component.set("v.transIdflag",true);
                    //component.set("v.errorMsg",result[0].messages[0].description);
//                    component.set("v.transId",tranId);
                    
                }                                
            }
        });
        $A.enqueueAction(action);  
    },
    closeModel : function(component, event, helper){
        component.set("v.flag",false);
    }   
    
})