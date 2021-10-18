({
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    //Dynmaic Object Name List
    fetchList : function(component, event, helper) {
        var action = component.get('c.getObjectList');
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){
                var objList = [];
                var conts = response.getReturnValue();
                for(var key in conts){
                    objList.push({value:conts[key], key:key});
                }
                component.set("v.objNameList", objList);
            }
        });
        $A.enqueueAction(action); 
    },
    
    //Selected Object Show Fields
    onSelectChange : function(component, event, helper) {
        component.set('v.tableFlag', false);
        var selectCmp = component.find("selectedObjName").get("v.value");
        component.set('v.objApiName',selectCmp);
        var selObjName = component.get('v.objApiName');
        component.set('v.selectedFieldApi',null);
        var action = component.get('c.getObjectFields');
        action.setParams({
            objName: selObjName
        });
        action.setCallback(this, function(response){
            var options = [];
            var fieldMap = response.getReturnValue(); 
            for (var k in fieldMap) {
                options.push({ value:k, label:fieldMap[k]});	
            }
            component.set('v.options', options);
            component.set('v.flag', true);            
        });
        $A.enqueueAction(action);
    },
    
    handleChange :  function(component, event, helper) {
        component.set('v.fieldApi', event.getParam("value").toString());  
    },
    
    showSelectedFields : function(component, event, helper) {
        component.set('v.tableFlag', true);
        helper.showColumFields(component);
        
    }
})