({
    //Get Access Token
    accessTokenFetch : function(component,code) {
        var action = component.get('c.AccessToken');	
        action.setParams({
            codeVal : code
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {   
                window.location.href = 'https://sumitbriskmindcommunit-developer-edition.ap15.force.com/sumitbriskminds/s/?tabset-187cb=59ac8';
            }
        });
        $A.enqueueAction(action);       
    },
    
    //Get aLL File and Folder
    fetchAllFilesFolder : function(component){
        //component.set('v.initlizeFlag',true);
        var action = component.get('c.allFilesFolder');	
        action.setParams({
            folderId : 0
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {  
                var jsonString = response.getReturnValue();
                console.log(jsonString);
                this.jsonToWrapper(component, jsonString);
            }
        });
        $A.enqueueAction(action);
    },
    
    //Convert Json to Wrapper
    jsonToWrapper : function(component, jsonString) {
        var jsonParseStr = JSON.parse(jsonString);
        var ent = jsonParseStr.item_collection.entries;               
        var len = jsonParseStr.item_collection.entries.length;
        var fileList = [];           
        for(var i=0;i<=len-1;i++)
        {
            if(ent[i].type=='folder')
            {
                fileList.push(ent[i]);
            }
            else
            {              
                fileList.push(ent[i]);                                                                                                                    
            }                    
        }                
        component.set('v.fileFolderList',fileList);    
    },
    
    //Afetr click on breadcrumb maintain List
    breadCrumbMaintain : function(component,id) {     
        var bList = component.get('v.breadCrumbList');
        var tempList = [];
        //var createPathFolder ="";
        for(var bKey in bList)
        {
            if(!(bList[bKey].id==id))
            {
                tempList.push({ name:bList[bKey].name, id:bList[bKey].id});
            }
            else if(bList[bKey].id==id)
            {
                tempList.push({ name:bList[bKey].name, id:bList[bKey].id});
                break;
            }         
        }    
        component.set('v.breadCrumbList',tempList);
    },
    
    //After delete refersh file
    afterdelete : function(component) {
        var pathId = component.get('v.pathId');                
        var action = component.get('c.allFilesFolder');	
        action.setParams({
            folderId : pathId,
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {                     
                var jsonString = response.getReturnValue();                                    
                this.jsonToWrapper(component, jsonString);                  
            }
        });
        $A.enqueueAction(action); 
    }   
})