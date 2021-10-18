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
    
    //get access token
    accessToken : function(component, event, helper) {       
        var action = component.get('c.dropAuth');	
        action.setParams({
            
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){
                var code='';
                var parsedUrl = new URL(window.location.href);
                code = parsedUrl.searchParams.get("code");
                var url = response.getReturnValue();
                if(code=='' || code==null){                  
                    if(!(url=='validToken')) {
                        window.location.href = url;                        
                    }
                    else{
                        helper.showAllFilesAndFolders(component); 
                    }
                } 
                else{
                    helper.accessTokenFetch(component,code);    
                }
            }
        });
        $A.enqueueAction(action);  
    },
    
    //Show all files and folder
    filesAndFolder : function(component, event, helper) {
        var path = event.target.getAttribute('data-path');
        var name = event.target.getAttribute('data-name');
        var id = event.target.getAttribute('data-id');
        component.set('v.folderPath',path);
        component.set('v.pathId',id);
        component.set('v.breadFolId',id);
        var breadList = component.get('v.breadCrumb');
        breadList.push({ name:name, id:id});	        
        component.set('v.breadCrumb',breadList);        
        var action = component.get('c.filesInFolder');	
        action.setParams({
            idOfFile : id,
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {                     
                var jsonString = response.getReturnValue();                                    
                helper.jsonToWrapper(component, jsonString);               
            }
        });
        $A.enqueueAction(action);  
    },
    
    //Delete File and Folder Handler
    deleteHandler : function(component, event, helper) {
        var path = event.target.getAttribute('data-index');        
        var action = component.get('c.deleteFileFolders');	
        action.setParams({
            pathOfFiles : path,
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {               
                var jsonString = response.getReturnValue();
                helper.afterdelete(component);                   
            }
        });
        $A.enqueueAction(action); 
    },
    
    //Maintain Breadcrumb
    breadCrumMthod : function(component, event, helper) {
        var pathId = event.target.getAttribute('data-index');
        component.set('v.breadFolId',pathId);  
        component.set('v.pathId',pathId); 
        var action = component.get('c.filesInFolder');	
        action.setParams({
            idOfFile : pathId,
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {                     
                var jsonString = response.getReturnValue();                                    
                helper.jsonToWrapper(component, jsonString);   
                helper.breadCrumbMaintain(component,pathId);  
            }
        });
        $A.enqueueAction(action);             
    },
    
    //Download File Hanlder
    fileDownload : function(component, event, helper) {
        var fileId = event.target.getAttribute('data-index');  
        var action = component.get('c.downloadFile');	
        action.setParams({
            idOfFile : fileId,
            accesstoken :  component.get('v.accToken')
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {                    
                var jsonParseStr = JSON.parse(response.getReturnValue());
                var fileLink = jsonParseStr.link;         
                window.location.href = fileLink;               
            }
        });
        $A.enqueueAction(action);         
    },
    
    //Create folder model show
    createFolderHandler : function(component, event, helper) {
        component.set('v.isOpen',true);
        component.set('v.createFolderFlag',true);
    },
    
    //upload file modal show
    uploadFileHandler : function(component, event, helper) {
        component.set('v.isOpen',true);
        component.set('v.uploadFolderFlag',true);
    },
    
    //Action fire after upload file
    onChildAttrChange : function(component, event, helper) {     
        var action = component.get('c.filesInFolder');	
        action.setParams({
            idOfFile : component.get('v.breadFolId'),
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {                     
                var jsonString = response.getReturnValue();           
                helper.jsonToWrapper(component, jsonString);                  
            }
        });
        $A.enqueueAction(action);    
    },
    
    //action fire after create folder
    onChildAttrFolderChange : function(component, event, helper) {    
        var action = component.get('c.filesInFolder');	
        action.setParams({
            idOfFile : component.get('v.breadFolId'),
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {                     
                var jsonString = response.getReturnValue();            
                helper.jsonToWrapper(component, jsonString);                  
            }
        });
        $A.enqueueAction(action);   
    }
})