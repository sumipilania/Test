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
                component.set('v.allRecordsList',response.getReturnValue()); 
                component.set('v.recordsPageSize',5);
                var recordsSize = component.get('v.recordsPageSize');
                component.set("v.start",0);
                component.set("v.end",(recordsSize-1));
                var recordList = [];
                console.log(response.getReturnValue());
                for(var i=0; i<recordsSize; i++)
                {
                    if(total>i)
                    {
                        recordList.push(response.getReturnValue()[i]);
                    }
                }    
                 console.log(recordList);
                component.set('v.data',recordList); 
                component.set('v.totalPageSize',Math.ceil(total/5));
                component.find("pageSize").set("v.value",5);
                var pageList = [];  
                var totalPageNo = component.get('v.totalPageSize');
                for(var i=1; i<=totalPageNo;i++)
                {
                    if(i<=5)
                    {
                        pageList.push(i);  
                        
                    }
                }
                component.set("v.pageList",pageList); 
            }
        });
        $A.enqueueAction(action);        
    },
    
    managePageList : function (val,index,component) {
        var totalPage = parseInt(component.get('v.totalPageSize'));
        var currentPageNo = parseInt(component.get('v.pageNumber'));
        
        if(!(val==(totalPage-1)))
        {                
            if(currentPageNo<=(totalPage-2) && val!=totalPage)
            {               
                var pageList = [];
                if(val<=3)
                {                
                    pageList.push(1,2,3,4,5);
                }  
                else if(val>=3)
                {                                
                    pageList.push(val-2,val-1,val,val+1,val+2);                                                         
                }                
            }
            else
            {
                var pageList = [];
                pageList.push(val-4,val-3,val-2,val-1,val); 
            }
        }
        else
        {
            
            var pageList = [];
            pageList.push(val-3,val-2,val-1,val,val+1);                        
        }
        component.set("v.pageList",pageList);               
    },
    
    managePageListNextPrevious : function (component) {
        var currentPageNo = parseInt(component.get('v.pageNumber'));
        var totalPage = parseInt(component.get('v.totalPageSize'));   
        if(currentPageNo<=(totalPage-2))
        {
            var pageList = []; 
            if(currentPageNo<=3)
            {                
                pageList.push(1,2,3,4,5);
            }
            else if(currentPageNo>3)
            {                          
                pageList.push(currentPageNo-2,currentPageNo-1,currentPageNo,currentPageNo+1,currentPageNo+2);            
            }    
            component.set("v.pageList",pageList); 
        }                
    },
    
    //Sort Data
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
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