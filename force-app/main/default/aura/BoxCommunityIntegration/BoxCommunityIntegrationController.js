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
    
    //Authorization 
    authorizationBox : function(component, event, helper) {       
        var action = component.get('c.boxAuth');	
        action.setParams({
            
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {
                var code='';
                var parsedUrl = new URL(window.location.href);
                code = parsedUrl.searchParams.get("code");
                var url = response.getReturnValue();  
                if(code=='' || code==null)
                {
                    if(!(url=='validToken' || url=='validRefToken'))
                    {
                        window.location.href = url;                        
                    }
                    else
                    {
                        helper.fetchAllFilesFolder(component); 
                    }
                } 
                else
                {
                    helper.accessTokenFetch(component,code);    
                }
            }
        });
        $A.enqueueAction(action);  
    },
    
    //File and Folder List
    filesAndFolder : function(component, event, helper) {
        var name = event.target.getAttribute('data-name');
        var id = event.target.getAttribute('data-id');   
        component.set('v.pathId',id);
        var breadList = component.get('v.breadCrumbList');
        breadList.push({ name:name, id:id});	        
        component.set('v.breadCrumbList',breadList);        
        var action = component.get('c.allFilesFolder');	
        action.setParams({
            folderId : id
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
    
    //Breadcrumb Maintain
    breadCrumMthod : function(component, event, helper) {
        var id = event.target.getAttribute('data-index');
        component.set('v.pathId',id);
        var action = component.get('c.allFilesFolder');	
        action.setParams({
            folderId : id
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {                     
                var jsonString = response.getReturnValue();                                    
                helper.jsonToWrapper(component, jsonString);   
                helper.breadCrumbMaintain(component,id);  
            }
        });
        $A.enqueueAction(action);             
    },
    
    //Delete File and Folder
    deleteHandler : function(component, event, helper) {
        var id = event.target.getAttribute('data-index');       
        var type = event.target.getAttribute('data-type'); 
        var action = component.get('c.deleteFileFolder');	
        action.setParams({
            folderId : id,
            fileFolderType : type
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
    
    //Download File
    fileDownload : function(component, event, helper) {
        var fileId = event.target.getAttribute('data-index');  
        var action = component.get('c.downloadFile');	
        action.setParams({
            fileId : fileId
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS')
            {                    
                var url = response.getReturnValue();
                window.location.href = url;               
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
    
    //action fire after create folder
    onChildAttrFolderChange : function(component, event, helper) {    
        var action = component.get('c.allFilesFolder');	
        action.setParams({
            folderId : component.get('v.pathId'),
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
    
    //Action fire after upload file
    onChildAttrChange : function(component, event, helper) {     
        var action = component.get('c.allFilesFolder');	
        action.setParams({
            folderId : component.get('v.pathId'),
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
    
    
})