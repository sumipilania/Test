({
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
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
        });
        $A.enqueueAction(action);
    },
    
    //Make Query String  Selected Field
    handleChange :  function(component, event, helper) {
        component.set('v.fieldApi', event.getParam("value").toString());  
    },
    
    //Show Selected Field 
    showSelectedFields : function(component, event, helper) {        
        helper.showHeaders(component,event);    
    },
    
    //Selected Page Records Size Show
    onSelectPageSize : function(component, event, helper) {
        component.set('v.limitSize',component.find("pageSize").get("v.value"));
        var pageSize = component.get('v.limitSize');
        var total = component.get('v.totalRecSize');
        component.set('v.totalPageSize',Math.ceil(total/pageSize));  
        component.set('v.pageNumber',1);  
        var queryField = component.get('v.fieldApi');
        var selObjName = component.get('v.objApiName');
        var limitSize = component.get('v.limitSize');
        var query = 'SELECT '+queryField+' FROM '+selObjName+' ORDER BY Id LIMIT '+limitSize;
        component.set("v.query",query);
        helper.showRecords(component,event);  
    },
    
    //Previous Button
    handlePrev : function(component, event, helper) {
        component.set('v.pageNumber',component.get('v.pageNumber')-1);
        var recList = component.get('v.allRecList');       
        var queryField = component.get('v.fieldApi');
        var selObjName = component.get('v.objApiName');
        var limitSize = component.get('v.limitSize'); 
        var firstRecId = recList[0]['Id'];               
        var query = 'SELECT '+queryField+' FROM '+selObjName+' WHERE Id < \''+firstRecId+ '\' ORDER BY Id DESC LIMIT '+limitSize;        
        component.set("v.query",query);    
        helper.showRecords(component,event);        
    },
    
    //Next Button
    handleNext : function(component, event, helper) {
        component.set('v.pageNumber',component.get('v.pageNumber')+1);
        var recList = component.get('v.allRecList');
        var queryField = component.get('v.fieldApi');
        var selObjName = component.get('v.objApiName');
        var limitSize = component.get('v.limitSize');
        var len = parseInt(recList.length-1);        
        var lastRecId = recList[len]['Id'];        
        var query = 'SELECT '+queryField+' FROM '+selObjName+' WHERE Id > \''+lastRecId+ '\' ORDER BY Id LIMIT '+limitSize;        
        component.set("v.query",query);
        helper.showRecords(component,event);
    },
    
    //First Button
    handleFirst : function(component, event, helper) {
        component.set('v.pageNumber',1);
        var queryField = component.get('v.fieldApi');
        var selObjName = component.get('v.objApiName');
        var limitSize = component.get('v.limitSize');
        var query = 'SELECT '+queryField+' FROM '+selObjName+' ORDER BY Id LIMIT '+limitSize;
        component.set("v.query",query);
        helper.showRecords(component,event);
    },
    
    //Last Button
    handleLast : function(component, event, helper) {       
        component.set('v.pageNumber',component.get('v.totalPageSize'));
        var recList = component.get('v.allRecList');
        var queryField = component.get('v.fieldApi');
        var selObjName = component.get('v.objApiName');
        var limitSize = component.get('v.limitSize');     
        var query = 'SELECT '+queryField+' FROM '+selObjName+' ORDER BY Id DESC LIMIT '+limitSize;        
        component.set("v.query",query);    
        helper.showRecords(component,event);
    },
    
    //Header Checkbox Maintain
    allCheckboxHandler : function (component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.checked");
        component.set('v.allCheckBox',selectedHeaderCheck);
        helper.allCheckBox(component,event);
        
    },
    
    //Check box maintain
    checkBoxHandler : function (component, event, helper) {
        //helper.checkboxMaintain(component, event);
        var selectId = event.getSource().get("v.value");
        var isChecked = event.getSource().get("v.checked");
        var dataList = component.get('v.data');
        var limitSize = parseInt(component.get('v.limitSize')); 
        var tempList = component.get('v.checkBoxList');
        var count =  component.get('v.headerCount');
        for(var i in dataList){
            if(isChecked==true && selectId==dataList[i].Id){
                tempList.push(dataList[i].Id);
                count++;
            }
            else if(isChecked==false && selectId==dataList[i].Id){                
                for(var j in tempList){                    
                    if(tempList[j]==selectId){                        
                        tempList.splice(j, 1);
                        count--;
                    }
                }                                
            }
        }
        component.set('v.headerCount',count);
        var len = parseInt(tempList.length);               
        if(count==limitSize){
            component.set('v.allCheckBox',true);
        }else{
            component.set('v.allCheckBox',false);
        }                
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