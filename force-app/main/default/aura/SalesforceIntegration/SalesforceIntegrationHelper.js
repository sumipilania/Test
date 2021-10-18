({
    //Column Field Store Using Wrapper Class
    showColumFields : function(component) {
        var selObjName = component.get('v.objApiName');
        var fieldApi = component.get('v.selectedFieldApi');  
        var action = component.get('c.showFieldDynamically');
        action.setParams({
            objName: selObjName,
            fieldList: fieldApi
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){
                var dynmaicFieldList = [];
                var tempList = response.getReturnValue();            
                for(var field in tempList){
                    dynmaicFieldList.push({label: tempList[field].fieldLabel , fieldName: tempList[field].fieldApi , type: tempList[field].type, sortable: tempList[field].sortable});           
                }
                component.set('v.columnsList',dynmaicFieldList);
                this.showRecords(component);
            }
        });
        $A.enqueueAction(action);  
    },
    
    //Records Fetch
    showRecords :  function(component) {
        var selObjName = component.get('v.objApiName');
        var queryString = component.get('v.fieldApi');
        var action = component.get('c.showDynmaicRecords');	
        var total = component.get('v.totalRecSize');	
        action.setParams({
            objName: selObjName,
            query: queryString
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {                     
                var jsonParseStr = JSON.parse(response.getReturnValue());
                var records = jsonParseStr.records;
                var tempDataList = [];
                for(var i in records){
                    tempDataList.push(records[i]);
                }
                component.set('v.data',tempDataList);                
            }
        });
        $A.enqueueAction(action);        
    }
    
})