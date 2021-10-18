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
    
    //At the time of initlization and fill all map value in list
    doInit : function(component, event, helper) {
        var action = component.get('c.fetchMetaDetail');
        action.setParams({
            'ObjectName' : component.get("v.sObjApiName") ,
            'parentField': component.get("v.controlField"),
            'childField': component.get("v.depField") 
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){
                var recMap = response.getReturnValue().recTypeMap;
                var conMap = response.getReturnValue().pickListMap;
                var depRemMap = response.getReturnValue().depRemoveMap;
                var tempRecMap = [];
                for(var key in recMap){
                    tempRecMap.push({key:key, value:recMap[key]}); 
                }
                var contolMap = [];
                for(var key in conMap){
                    contolMap.push({key:key, value:conMap[key]}); 
                }
                var depRemoMap = [];
                for(var key in depRemMap){
                    if(depRemMap[key].length!=0){
                        depRemoMap.push({key:key, value:depRemMap[key]});
                    }
                }
                component.set("v.recList", tempRecMap);
                component.set("v.controlMapList",contolMap);
                component.set("v.depRemList",depRemoMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    //When chnage controlling field than manage value of record type
    onSelectChange : function(component, event, helper) {
        var contrlFieldName = event.getSource().get("v.value");
        var depId = component.find("depId").set("v.value","None");
        var recList = component.get("v.recList");
        var tempControlList = [];
        if(!(contrlFieldName=='None')){
            component.set("v.depFlag",true);
            for(var i in recList){
                if(recList[i].key==contrlFieldName){
                    for(var j in recList[i].value){
                        tempControlList.push(recList[i].value[j]);;
                    }
                    component.set("v.controlList",tempControlList);
                    break;
                }
            }
        }
    },
    
    //When chnage dependent field value from controlling field
    onSelectControlChange : function(component, event, helper) {
        var controlFieldName = event.getSource().get("v.value");
        var contlDepListMap = component.get("v.controlMapList");
        var recTypeName = component.find("recTypeId").get("v.value");
        var depRemList = component.get("v.depRemList");
        var tempDepList = [];
        if(!(controlFieldName=='None')){
            component.set("v.depFlag",false);
            for(var i in contlDepListMap){
                if(contlDepListMap[i].key==controlFieldName){
                    for(var j in contlDepListMap[i].value){
                        tempDepList.push(contlDepListMap[i].value[j]);;
                    }
                    component.set("v.depList",tempDepList);
                    break;
                }
            }
            
            //Remove which value when metadata create relation between dependent picklist from record type
            for(var k in depRemList){
                if(depRemList[k].key==recTypeName){
                    var mainDepVal = tempDepList.filter( function( el ) {
                        return depRemList[k].value.indexOf( el ) < 0;
                    } );
                    component.set("v.depList",mainDepVal);
                    break;
                }
            }
        }else{
            component.find("depId").set("v.value","None");
            component.set("v.depFlag",true);
        }
    }
})