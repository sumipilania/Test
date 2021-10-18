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
        component.set('v.pageNumber',1);           
        var selected = component.find("pageSize").get("v.value");
        var total = component.get('v.totalRecSize');
        component.set('v.totalPageSize',Math.ceil(total/selected));
        component.set("v.start",0);
        component.set("v.end",(selected-1));
        component.set("v.recordsPageSize",selected);        
        var paginationList = [];        
        var recList = component.get("v.allRecordsList"); 
        var total = component.get('v.totalRecSize');	
        var pageList = [];
        pageList.push(1,2,3,4,5);             
        component.set("v.pageList",pageList);  
        for(var i=0; i< selected; i++)            
        {        
            if(total>i)
            {
                paginationList.push(recList[i]);            
            }
        }        
        component.set("v.data", paginationList);
    },
    
    //Previous Button
    handlePrev : function(component, event, helper) {
        component.set('v.pageNumber',component.get('v.pageNumber')-1);
        var recList = component.get("v.allRecordsList");
        var end = parseInt(component.get("v.end"));
        var start = parseInt(component.get("v.start"));
        var pageSize = parseInt(component.get("v.recordsPageSize"));
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++)
        {
            if(i > -1)
            {
                paginationList.push(recList[i]);
                counter ++;
            }
            else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.start",start);
        component.set("v.end",end);
        component.set("v.data", paginationList); 
        helper.managePageListNextPrevious(component);
    },
    
    //Next Button
    handleNext : function(component, event, helper) {
        component.set('v.pageNumber',component.get('v.pageNumber')+1);        
        var recList = component.get("v.allRecordsList");
        var end = parseInt(component.get("v.end"));
        var start = parseInt(component.get("v.start"));  
        var pageSize = parseInt(component.get("v.recordsPageSize"));       
        var paginationList = [];
        var counter = 0;
        var len = parseInt(recList.length);
        for(var i = end + 1; i < end + pageSize + 1; i++)
        {            
            if(len > i)
            {
                paginationList.push(recList[i]);
                counter++ ;
            }
        }
        start = start + counter;
        end = end + counter;
        component.set("v.start",start);
        component.set("v.end",end);
        component.set("v.data", paginationList);
        helper.managePageListNextPrevious(component);
    },
    
    //First Button
    handleFirst : function(component, event, helper) {
        component.set('v.pageNumber',1);
        var recSize = component.get("v.recordsPageSize");
        var paginationList = [];        
        var recList = component.get("v.allRecordsList"); 
        for(var i=0; i< recSize; i++)            
        {            
            paginationList.push(recList[i]);            
        }        
        component.set("v.data", paginationList); 
        var pageList = [];
        pageList.push(1,2,3,4,5);             
        component.set("v.pageList",pageList); 
    },
    
    //Last Button
    handleLast : function(component, event, helper) {
        component.set('v.pageNumber',component.get('v.totalPageSize')); 
        var total = parseInt(component.get('v.totalPageSize'));
        var recSize = component.get("v.recordsPageSize");
        var paginationList = [];        
        var recList = component.get("v.allRecordsList"); 
        var recLen = component.get("v.totalRecSize"); 
        for(var i=recSize; i>0 ; i--)            
        {            
            paginationList.push(recList[recLen-i]);            
        }        
        component.set("v.data", paginationList);
        var pageList = [];
        pageList.push(total-4,total-3,total-2,total-1,total);             
        component.set("v.pageList",pageList); 
    },
    
    processMe : function (component, event, helper) {
        var index =parseInt(event.target.getAttribute('data-index')); 
        var val = parseInt(event.target.getAttribute('data-value')); 
        var recSize = parseInt(component.get("v.recordsPageSize"));       
        var totalPage = parseInt(component.get('v.totalPageSize'));
        var paginationList = [];        
        var recList = component.get("v.allRecordsList"); 
        var len = parseInt(recList.length);
        var i = (val-1)*recSize;
        var startTemp = i;
        var endTemp = (i+recSize)-1;    
        for(; i<(recSize)*val; i++)            
        {   
            if(len>i)
            {
                paginationList.push(recList[i]);                            
            }
        }        
        component.set("v.data", paginationList);
        component.set("v.start", startTemp);       
        component.set("v.end", endTemp);
        component.set("v.pageNumber", val); 
        var len = parseInt(component.get("v.pageList").length);
        if(len==5)
        {
            if(!(index==2))
            {
                helper.managePageList(val,index,component);
            }            
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