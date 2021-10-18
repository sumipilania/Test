({
	creaditCard : function(component) {
         var card = component.find("cardId").get("v.value");
       var month = component.find("month").get("v.value");
         var year = component.find("year").get("v.value");
       var cvv = component.find("cvv").get("v.value");
      //  var cvvCheck = component.get("v.cvvCheck");
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
                console.log('resp==',result);
                component.set("v.flag",true);
                console.log('id===',result[0].transId);
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