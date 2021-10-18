({
    doInit : function(component, event, helper) {
        var action = component.get("c.fetchRecordTypeList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var recTypeList = response.getReturnValue();
                var tempRecList = [];
                for(var i in recTypeList){
                    tempRecList.push({'label': recTypeList[i].Name, 'value':  recTypeList[i].Id});
                }
                component.set("v.recList", tempRecList);
            }
            else if (state === "ERROR") {
                helper.customShowToast('Error',response.getError()[0].message,'pester','error');
            }
        });
        $A.enqueueAction(action);
    },
    onSelectChange : function(component, event, helper) {
        component.set("v.recordTypeId",event.getSource().get("v.value"));
    },
    handleClick : function(component, event, helper) {
        component.set("v.createContactFlag", true);
    },
    cancelClick : function(component, event, helper) {
        component.set("v.createContactFlag", false);
    },
    handleLoad : function(component, event, helper) {
        //component.set("v.spinnerFlag", true);
    },
    handleError : function(component, event, helper) {
        console.log('ErrorIn');
        console.log('output==',event.getParam("output").fieldErrors);
        console.log('message==',event.getParam("message"));
        console.log('detail==',event.getParam("detail"));
        console.log('error==',event.getParam("error"));
    },
    handleSubmit : function(component, event, helper) {
        event.preventDefault();
        component.set("v.spinnerFlag", true);
        var action = component.get("c.fetchCaseRecord");
        action.setParams({ 
            caseId : component.get("v.recordId") 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var caseObj = response.getReturnValue();
                var fields = event.getParam('fields');
                fields.Email = caseObj.ContactEmail;
                component.find('recordEditFormId').submit(fields);
                component.set("v.spinnerFlag", false);
               component.set("v.createContactFlag", false);
               helper.customShowToast('Success','Your contact successfully created','pester','success');
            }
            else if (state === "ERROR") {
                let error = response.getError();
                if(Array.isArray(error) && error.length > 0){
                    helper.customShowToast('Error', error[0].message, 'pester', 'error');                    
                }
            }
        });
        $A.enqueueAction(action);
    }
})