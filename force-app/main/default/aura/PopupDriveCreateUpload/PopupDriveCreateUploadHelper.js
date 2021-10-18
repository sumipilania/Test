({
    //Fetch all required data like name body
    upload : function(component) {        
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];  
        if(file==undefined){
            alert('Please Select File');
        }
        else{                     
            var fr = new FileReader();  
            var self = this;
            fr.onload = function(evt) {
                var fileContents = window.btoa(evt.target.result);
                self.uploadFile(component, file, fileContents);
                var flag = component.get("v.childRes");
                var changeFlag = (flag==false) ? true : false;
                component.set("v.childRes", changeFlag);
                component.set("v.openUploadModel", false);                               
            };            
            fr.readAsBinaryString(file);
        }              
    },
    
    //upload file using apex
    uploadFile: function(component, file, fileContents) {                 
        var action = component.get("c.uploadFiles");         
        action.setParams({
            parentId: component.get("v.parentId"),
            uploadFileContent: fileContents, 
            uploadFileName: file.name,
            fileSize: file.size,
            filetype : file.type           
        });        
        action.setCallback(this, function(response) {
            var res = response.getReturnValue();                              
        });           
        $A.enqueueAction(action);        
    }
})