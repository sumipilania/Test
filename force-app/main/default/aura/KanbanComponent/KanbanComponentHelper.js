({
    updatePickVal : function(component, recId, pField, pVal) {
        //Id recId, String kanbanField, String kanbanNewValue
        var action = component.get("c.getUpdateStage");
        action.setParams({
            "recId":recId,
            "kanbanField":pField,
            "kanbanNewValue":pVal
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                document.getElementById(recId).style.backgroundColor = "#04844b";
                setTimeout(function(){ document.getElementById(recId).style.backgroundColor = ""; }, 300);
                this.kanbanCreate(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    kanbanCreate :  function(component){
        var action = component.get("c.getKanbanWrap");
        action.setParams({
            "objName":component.get("v.objName"),
            "objFields":component.get("v.objFields"),
            "kanbanField":component.get("v.kanbanPicklistField")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {     
                var temp = response.getReturnValue();    
                console.log(temp);
                var custs = [];
                for(var key in temp){
                    custs.push({value:temp[key], key:key});
                }
                if(custs.length!=0){
                    component.set("v.kanbanData", custs);
                }else{
                    alert('Knaban field is invalid');
                }    
            }
        });
        $A.enqueueAction(action);
    }
})