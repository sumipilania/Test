({
    //upload and create model hide
    closeModel : function(component, event, helper) {
        component.set("v.openUploadModel", false);  
        component.set("v.createFolder", false);
    },
    
    //upolad file
    uploadFileHandler : function(component, event, helper) {       
        helper.upload(component);
    },
    
    //create folder
    createFolderHandler : function(component, event, helper) {
        var pathId = component.get("v.parentId");
        var folName = component.get("v.inputTextFolderName");               
        if(folName==undefined || folName=='')
        {
            alert('Please Enter Any Folder Name');
        }
        else
        {   
            component.set("v.inputTextFolderName",undefined);       
            var flag = component.get("v.childResFolder");
            var changeFlag = (flag==false) ? true : false;
            var action = component.get("c.createFolder");         
            action.setParams({
                parentId : pathId,
                folderName : folName
            });            
            action.setCallback(this, function(response) {
                var res = response.getReturnValue();  
                component.set("v.childResFolder", changeFlag);
                component.set("v.createFolder", false);                
            });           
            $A.enqueueAction(action);  
        }
    },
    
    //get value inpted text(File Name)
    getInputValueHandler : function(component, event, helper) {
        component.set("v.inputTextFolderName", event.getSource().get("v.value"));
    }   
})