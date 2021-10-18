({
    //Send Detail for Payment through credit card
    creaditCard : function(component) {
        var card = component.find("cardId").get("v.value");
        var month = component.find("month").get("v.value");
        var year = component.find("year").get("v.value");
        var cvv = component.find("cvv").get("v.value");        
        var action = component.get('c.creditCard');
        action.setParams({
            cardNumber : card,
            expMonth : month,
            expYear : year,
            cvv : cvv            
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {
                var result = response.getReturnValue();                
                component.set("v.flag",true);
                component.set("v.transIdflag",false);
                component.set("v.errorFlag",false);                
                var tranId = result[0].transId;
                if(tranId=='0'){
                    component.set("v.transIdflag",false);
                    component.set("v.errorFlag",true);
                    component.set("v.errorMsg",result[0].errors[0].errorText);
                }
                else{
                    component.set("v.errorFlag",false);
                    component.set("v.transIdflag",true);
                    component.set("v.errorMsg",result[0].messages[0].description);
                    component.set("v.transId",tranId);                    
                }                                
            }
        });
        $A.enqueueAction(action);          
    },
    
     //Send Detail for Payment through eCheck
    eCheckBank :function(component) {
        var routId = component.find("routId").get("v.value");
        var accNo = component.find("accNo").get("v.value");
        var name = component.find("accName").get("v.value");
        var action = component.get('c.echeck');  
        action.setParams({
            routingNum : routId,
            accNo : accNo,
            nameOnAcc : name     
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {
                var result = response.getReturnValue();                
                component.set("v.flag",true);                
                var tranId = result[0].transId;
                if(tranId=='0'){
                    component.set("v.transIdflag",false);
                    component.set("v.errorFlag",true);
                    component.set("v.errorMsg",result[0].errors[0].errorText);
                }else{
                    component.set("v.errorFlag",false);
                    component.set("v.transIdflag",true);
                    component.set("v.errorMsg",result[0].messages[0].description);
                    component.set("v.transId",tranId);                   
                }                                
            }
        });
        $A.enqueueAction(action);  
    }
})