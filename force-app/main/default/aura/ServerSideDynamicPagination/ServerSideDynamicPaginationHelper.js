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
            if(state === 'SUCCESS')
            {
  	            var dynmaicFieldList = [];
                var tempList = response.getReturnValue();            
                for(var field in tempList)
                {
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
        var offsetSize = component.get('v.offsetSize');
        var limitSize = component.get('v.limitSize');
        var sortField = component.get('v.sortField');
        var action = component.get('c.showDynmaicRecords');	
        var total = component.get('v.totalRecSize');		
        action.setParams({
            objName: selObjName,
            query: queryString,
            sortField: sortField,
            limitSize: limitSize,
            offsetSize: offsetSize
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {     
                var tempList = response.getReturnValue();
                component.set('v.data',response.getReturnValue()); 
                var sizeof =  component.get('v.data');
                component.set('v.totalPageSize',Math.ceil(total/limitSize));  
            }
        });
        $A.enqueueAction(action);        
    },
    
    //Sort Data
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        console.log('reverse=='+reverse);
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.data", data);
    },
    
    //Ascending and Decending
    sortBy: function (field, reverse, primer) {
        var key = primer ?
        function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})