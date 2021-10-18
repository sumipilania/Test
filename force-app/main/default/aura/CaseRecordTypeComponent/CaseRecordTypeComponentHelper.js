({
    customShowToast : function(title,message,mode,type) { 
        let toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                "title": title,
                "message": message,
                "mode" : mode,
                "type" : type
            });
            toastEvent.fire();
        }
    }
})