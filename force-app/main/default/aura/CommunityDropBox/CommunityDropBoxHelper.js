({
    //Fetch Access token
    accessTokenFetch : function(component,code) {
        var action = component.get('c.AccessToken');	
        action.setParams({
            codeVal : code
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {    
                window.location.href = 'https://sumitbriskmindcommunit-developer-edition.ap15.force.com/sumitbriskminds/s/?tabset-187cb=2';
            }
        });
        $A.enqueueAction(action);       
    },
    
    //Fetch All Filder and Files
    showAllFilesAndFolders :  function(component) {
        component.set('v.initlizeFlag',true);
        var action = component.get('c.allFilesFolder');	
        action.setParams({
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
    },
    
    //respose to convert wrapper
    jsonToWrapper : function(component, jsonString) {
        var jsonParseStr = JSON.parse(jsonString);
        var ent = jsonParseStr.entries;               
        var len = jsonParseStr.entries.length;
        var fileList = [];           
        for(var i=0;i<=len-1;i++)
        {
            if(ent[i].tag=='folder')
            {
                fileList.push(ent[i]);
            }
            else
            {
                if(!(ent[i].id=="id:qsWnS2zu3OAAAAAAAAAACQ" || ent[i].id=="id:qsWnS2zu3OAAAAAAAAAACg"))
                {
                    fileList.push(ent[i]);                    
                }                                                                                   
            }                    
        }                
        component.set('v.fileFolderList',fileList);    
    },
    
    //breadcrub maintain
    breadCrumbMaintain : function(component,pathId) {     
        var bList = component.get('v.breadCrumb');
        var tempList = [];
        var createPathFolder ="";
        for(var bKey in bList)
        {
            if(!(bList[bKey].id==pathId))
            {
                tempList.push({ name:bList[bKey].name, id:bList[bKey].id});
                createPathFolder = createPathFolder+'/'+bList[bKey].name;
            }
            else if(bList[bKey].id==pathId)
            {
                createPathFolder = createPathFolder+'/'+bList[bKey].name;
                tempList.push({ name:bList[bKey].name, id:bList[bKey].id});
                break;
            }
            
        }    
        component.set('v.breadCrumb',tempList);
        component.set('v.folderPath',createPathFolder);
    },
    
    //After delete hit api
    afterdelete : function(component) {
        var pathId = component.get('v.pathId');                
        var action = component.get('c.filesInFolder');	
        action.setParams({
            idOfFile : pathId,
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