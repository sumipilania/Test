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
        action.setParams({
            
        });
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
            component.set('v.pageNumber',1);
            component.set('v.offsetSize',0);
            component.set('v.limitSize',5);
          
        });
        $A.enqueueAction(action);
    },
    
    //Make Query String  Selected Field
    handleChange :  function(component, event, helper) {
        component.set('v.fieldApi', event.getParam("value").toString());  
    },
    
    //Show Selected Field 
    showSelectedFields : function(component, event, helper) {
        component.set('v.tableFlag', true);
        var selObjName = component.get('v.objApiName');
        var action = component.get('c.totalRecords');      
        action.setParams({
            objName: selObjName
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {
                component.set('v.totalRecSize',response.getReturnValue());   
                component.set('v.pageNumber',1);
            }
        });
        $A.enqueueAction(action); 
        helper.showColumFields(component);    
    },
    
    //Selected Page Records Size Show
    onSelectPageSize : function(component, event, helper) {
        component.set('v.limitSize',component.find("pageSize").get("v.value"));
        var pageSize = component.get('v.limitSize');
        var total = component.get('v.totalRecSize');
        component.set('v.totalPageSize',Math.ceil(total/pageSize));  
        component.set('v.offsetSize',0);
        component.set('v.pageNumber',1);  
        helper.showRecords(component);  
    },
    
    //Previous Button
    handlePrev : function(component, event, helper) {
        component.set('v.pageNumber',component.get('v.pageNumber')-1);
        var preSize = component.get('v.offsetSize') - component.get('v.limitSize');
        component.set('v.offsetSize',preSize);      
        helper.showRecords(component);
    },
    
    //Next Button
    handleNext : function(component, event, helper) {
        component.set('v.pageNumber',component.get('v.pageNumber')+1);
        var nextSize = parseInt(component.get('v.offsetSize')) + parseInt(component.get('v.limitSize'));
        component.set('v.offsetSize',nextSize); 
        helper.showRecords(component);
    },
    
    //First Button
    handleFirst : function(component, event, helper) {
        component.set('v.offsetSize',0);
        component.set('v.pageNumber',1);
        helper.showRecords(component);
    },
    
    //Last Button
    handleLast : function(component, event, helper) {
        var lastRecords = parseInt(component.get('v.totalRecSize')) - parseInt(component.get('v.limitSize'));
        component.set('v.offsetSize', Math.abs(lastRecords));
        component.set('v.pageNumber',component.get('v.totalPageSize'));
        helper.showRecords(component);
    },
    
    //Sorting Based On Column Wise
    updateColumnSorting : function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    }
})