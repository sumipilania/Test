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
                window.location.href = 'https://sumitbriskmindcommunit-developer-edition.ap15.force.com/sumitbriskminds/s/?tabset-187cb=9be65';
            }
        });
        $A.enqueueAction(action);       
    },
    
    //Get All folder json
    fetchAllFilesFolder : function(component){
        var action = component.get('c.allFilesFolder');	
        action.setParams({
            folderId : 'root'
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
    
    //Convert json to wrapper
    jsonToWrapper : function(component, jsonString) {
        var jsonParseStr = JSON.parse(jsonString);
        var ent = jsonParseStr.files;               
        var len = jsonParseStr.files.length;
        var fileList = [];           
        for(var i=0;i<=len-1;i++)
        {
            if(ent[i].mimeType=='application/vnd.google-apps.folder')
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
    
    //Maintain breadcrum after click on
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
    
    //After delete, delete file and folder id from List
    afterdelete : function(component,id) {     
        var folListOld = component.get('v.fileFolderList'); 
        var fileList = []; 
        var len = (folListOld.length)-1;        
        for(var i=0;i<=(folListOld.length)-1;i++)
        {
            if(!(folListOld[i].id==id))
            {                
                fileList.push(folListOld[i]);                                                                                                                    
            }  			               
        }                      
        component.set('v.fileFolderList',fileList);   
    }   
})