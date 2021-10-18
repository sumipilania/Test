({
    //All Records List
    fetchAccRec : function(component) {
        var obj = component.get("v.objName");
        var fieldList = component.get("v.fieldList");
        var query = fieldList.toString();  
        var offset = component.get("v.offSet");        
        var action = component.get('c.showFieldDynamically');
        action.setParams({
            objName : obj,
            query : query,
            offSet : offset 
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){                
                var mainList = response.getReturnValue();              
                var headerList = mainList.wrapList;
                var dataList = mainList.sObjList;              
                component.set('v.totalRecords', mainList.totalRecords);              
                var tempHeaderList = [];
                for(var i in headerList)
                {                    
                    tempHeaderList.push({label: headerList[i].fieldLabel, fieldName: headerList[i].fieldApi});       
                }               
                component.set("v.columnsList", tempHeaderList);                
                var fieldsList = component.get('v.fieldList');
                var oldDataList = component.get('v.data');                              
                for(var i=0;i<dataList.length;i++) {
                    var temp = [];                    
                    for(var j=0;j<fieldsList.length;j++){                        
                        var fil = fieldsList[j];
                        temp.push(dataList[i][fil]);
                    }
                    oldDataList.push({'Id':dataList[i].Id,'values':temp});
                }     
                component.set('v.data',oldDataList);
            }
        });
        $A.enqueueAction(action); 
    }
})