({  
    //Payment Through Credit Card  
    placeOrderHandler : function(component, event, helper) {
        var card = component.find("cardId").get("v.value");
        var cvv = component.find("cvv").get("v.value");
        var month = component.find("month").get("v.value");
        var year = component.find("year").get("v.value");
        component.set("v.transIdflag",false);
        component.set("v.errorFlag",false);               
        if(card=='' || cvv=='' || month=='' || year==''){
            component.set("v.flag",true);
            component.set("v.errorFlag",true);
            component.set("v.errorMsg","Please Fill All Fields"); 
        }
        else{
            if(!(isNaN(cvv) || isNaN(card))){
                if(card.length>=13 && cvv.length>=3){
                    helper.creaditCard(component); 
                }
                else{
                    component.set("v.flag",true);
                    component.set("v.errorFlag",true);
                    component.set("v.errorMsg","Please Check Numbers of digit");
                }
            }
            else{
                component.set("v.flag",true);
                component.set("v.errorFlag",true);
                component.set("v.errorMsg","Please Check Format");
            }
        }
    },
    
    //Payment Through eCheck
    echeckHandler : function(component, event, helper) {        
        var routId = component.find("routId").get("v.value");
        var accNo = component.find("accNo").get("v.value");
        var name = component.find("accName").get("v.value");
        component.set("v.transIdflag",false);
        component.set("v.errorFlag",false);        
        if(routId=='' || accNo=='' || name==''){
            component.set("v.flag",true);
            component.set("v.errorFlag",true);
            component.set("v.errorMsg","Please Fill All Fields"); 
        }else{
            if(!(isNaN(routId) || isNaN(accNo))){                
                helper.eCheckBank(component);
            }
            else{
                component.set("v.flag",true);
                component.set("v.errorFlag",true);
                component.set("v.errorMsg","Please Check Format");
            }
        }        
    },
    
    //Show echeck UI
    echeckShow : function(component, event, helper){
        component.set("v.creditCardFlag",false);
        component.set("v.echeckFlag",true);
    },
    
    //Show Credit Card UI
    creditCardShow : function(component, event, helper){
        component.set("v.echeckFlag",false);
        component.set("v.creditCardFlag",true);
    },
    
    //Close Modal
    closeModel : function(component, event, helper){        
        component.set("v.flag",false);
    }   
})