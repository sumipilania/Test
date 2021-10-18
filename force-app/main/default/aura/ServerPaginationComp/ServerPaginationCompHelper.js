({
    //Column Field Store Using Wrapper Class
    showHeaders : function(component,event) {
        component.set('v.limitSize',5);
        var fieldListApi = component.get('v.selectedFieldApi');
        var queryField = component.get('v.fieldApi');
        var selObjName = component.get('v.objApiName');
        var limitSize = component.get('v.limitSize');
        var optionsList  = component.get("v.options");
        var mainHeaderList = [];   
        for(var i in fieldListApi)
        {
            for(var j in optionsList)
            {                
                if(optionsList[j].value==fieldListApi[i])
                {                      
                    mainHeaderList.push({label: optionsList[j].label, fieldName: optionsList[j].value});                   
                }
            }
        }
        component.set('v.columnsList',mainHeaderList);
        var query = 'SELECT '+queryField+' FROM '+selObjName+' ORDER BY Id LIMIT '+limitSize;
        component.set("v.query",query);
        component.set('v.pageNumber',1);
        component.set('v.checkBoxList','');
        component.set('v.tableFlag', true);
        var data = component.get('v.data');
        data.push('start');
        component.set('v.data',data);
        component.find("pageSize").set("v.value",5);
        this.showRecords(component,event);
        
    },
    
    showRecords : function(component,event) {             
        var query = component.get('v.query');
        var selObjName = component.get('v.objApiName');
        var action = component.get('c.showFieldDynamically');
        action.setParams({
            query : query,
            selObjName: selObjName
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {
                var resp = response.getReturnValue();
                var recList = resp.recordsList;                                
                component.set('v.allRecList',recList);        
                component.set('v.totalRecSize',resp.totalRecords);         
                var mainHeaderList = component.get('v.columnsList');                
                var actualList = [];                
                var temp = [];
                for(var i in recList) {                    
                    var temp1 = [];
                    for(var j in mainHeaderList){
                        var fil = mainHeaderList[j].fieldName;
                        temp1.push(recList[i][fil]);                                               
                    }                    
                    temp.push({'Id':recList[i].Id,'values':temp1, isChecked:false});                     
                }               
                component.set('v.data',temp);
                var limitSize = component.get('v.limitSize');
                var total = component.get('v.totalRecSize');
                component.set('v.totalPageSize',Math.ceil(total/limitSize));
                var label = event.getSource().get("v.label");                
                if(label=='Prev' || label=='Last')
                {                   
                    this.reverseList(component);                    
                } 
                component.set('v.headerCount',0);
                this.checkboxMaintain(component);      
            }
        });
        $A.enqueueAction(action); 
    },
    
    //Reverse List
    reverseList : function (component) {        
        var data = component.get('v.data');
        var recList = component.get('v.allRecList');       
        var revDataList = [];
        var revAllList = [];
        var len = parseInt(data.length - 1);        
        for(var i = len; i>=0 ; i--)
        {
            revDataList.push(data[i]);
            revAllList.push(recList[i]);
        }        
        component.set('v.data',revDataList);
        component.set('v.allRecList',revAllList);
    },
    
    //Maintain Checkbox
    checkboxMaintain : function (component){
        var dataList = component.get('v.data');
        var tempList = component.get('v.checkBoxList');        
        var actualList = [];        
        var count = 0;
        var headCount = 0;
        if(tempList.length > 0)
        {
            for(var i in dataList)
            {   
                if(tempList.includes(dataList[i].Id))
                {                    
                    actualList.push({'Id':dataList[i].Id,'values':dataList[i].values, isChecked:true});
                    count++;
                    headCount++;
                }
                else
                {
                    actualList.push({'Id':dataList[i].Id,'values':dataList[i].values, isChecked:false});
                    count = 0;
                }                                
            }
            if(count==0){
                component.set('v.allCheckBox',false);
            }
            else{
                component.set('v.allCheckBox',true);
            }            
            component.set('v.data',actualList);            
        }        
        var limitSize = parseInt(component.get('v.limitSize'));
        var headerCount =  component.get('v.headerCount');
        if(headerCount==limitSize || count==limitSize){
            
            component.set('v.allCheckBox',true);
        }else{
            component.set('v.headerCount',headCount);
            component.set('v.allCheckBox',false);
        }                
    },
    
    //Header Checkox
    allCheckBox : function(component,event){        
        var selectedHeaderCheck = component.get('v.allCheckBox');
        var dataList = component.get('v.data');        
        var tempList = component.get('v.checkBoxList');        
        var actualList = [];
        for(var i in dataList){
            if(selectedHeaderCheck==true){
                actualList.push({'Id':dataList[i].Id,'values':dataList[i].values, isChecked:true});
                if(!(tempList.includes(dataList[i].Id)))
                {                    
                    tempList.push(dataList[i].Id);
                }                
            }
            else
            {
                actualList.push({'Id':dataList[i].Id,'values':dataList[i].values, isChecked:false});            
            }
        }        
        component.set('v.data',actualList);
    },
    
    //Sort Data
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");       
        var reverse = sortDirection;      
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.data", data);
    },
    
    //Ascending and Decending
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
    }
})