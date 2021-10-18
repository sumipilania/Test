({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId"); //Parent id dynamic
        var action = component.get('c.fetchRecords');	
        action.setParams({
            parentRecId : recordId
        });
        action.setCallback(this, function(response){
            var state  = response.getState();
            if(state === 'SUCCESS'){
                console.log('resp===',response);
                var parentList = response.getReturnValue().parentList;  //parent List
                var childList = response.getReturnValue().childList;  //Child List
                var parentQualificationList = parentList[0].Qualification__c.split(";"); //Qualification list
                var parentSpokenList = parentList[0].Spoken_Language__c.split(";"); //Spoken languange list
                var parentTechnicalList = parentList[0].Technical_Language__c.split(";"); //Technical languange list
                var childRecordList = []; //All child Reords List store
                var headerList = [];
                headerList.push({Name:parentList[0].Name,Exprience:parentList[0].Exprience__c,Qualification:parentList[0].Qualification__c.replace(/;/g, " "),Spoken:parentList[0].Spoken_Language__c.replace(/;/g, " "),Technical:parentList[0].Technical_Language__c.replace(/;/g, " ")});
                component.set('v.headerData',headerList); //Headre store
                for(var i in childList){
                    
                    //temperarory store list in json
                    var tempExpList = [];
                    var tempQualification = [];
                    var tempSpoken = [];
                    var tempTechnical = [];
                    
                    //Calucuate count of green box
                    var qualificationCount = 0; 
                    var spokenCount = 0;
                    var technicalCount = 0;
                    var childExp = parseInt(childList[i].Exprience__c);
                    var parentExp = parseInt(parentList[0].Exprience__c);
                    var expDifference = 0;
                    var tempPercent = 0;
                    
                    //calculate parent child experience
                    if(childExp > parentExp){
                        tempExpList.push({value:parentExp, color:'green'});
                        expDifference = childExp - parentExp;
                        tempPercent = parentExp;
                        tempExpList.push({value:expDifference, color:'yellow'});
                    }else{
                        tempExpList.push({value:childExp, color:'green'});
                        expDifference = childExp - parentExp;
                        tempPercent = childExp;
                        tempExpList.push({value:expDifference, color:'red'});
                    }                   
                    var childQualificationList = childList[i].Qualification__c.split(";");
                    var childSpokenList = childList[i].Spoken_Language__c.split(";");
                    var childTechnicalList = childList[i].Technical_Language__c.split(";");
                    
                    //Store red green yellow box Qualification List
                    for(var cq in childQualificationList){
                        if(parentQualificationList.includes(childQualificationList[cq])){
                            tempQualification.push({value:childQualificationList[cq],color:'green'});
                            qualificationCount++;
                        }else{
                            tempQualification.push({value:childQualificationList[cq],color:'yellow'});
                        }
                    }
                    for(var pq in parentQualificationList){
                        if(!(childQualificationList.includes(parentQualificationList[pq]))){
                            tempQualification.push({value:parentQualificationList[pq],color:'red'});
                        }
                    }
                    
                    //Store red green yellow box Spoken languange List
                    for(var cq in childSpokenList){
                        if(parentSpokenList.includes(childSpokenList[cq])){
                            tempSpoken.push({value:childSpokenList[cq],color:'green'});
                            spokenCount++;
                        }else{
                            tempSpoken.push({value:childSpokenList[cq],color:'yellow'});
                        }
                    }
                    for(var pq in parentSpokenList){
                        if(!(childSpokenList.includes(parentSpokenList[pq]))){
                            tempSpoken.push({value:parentSpokenList[pq],color:'red'});
                        }
                    }
                    
                    //Store red green yellow box Technical languange List
                    for(var cq in childTechnicalList){
                        if(parentTechnicalList.includes(childTechnicalList[cq])){
                            tempTechnical.push({value:childTechnicalList[cq],color:'green'});
                            technicalCount++;
                        }else{
                            tempTechnical.push({value:childTechnicalList[cq],color:'yellow'});
                        }
                    }
                    for(var pq in parentTechnicalList){
                        if(!(childTechnicalList.includes(parentTechnicalList[pq]))){
                            tempTechnical.push({value:parentTechnicalList[pq],color:'red'});
                        }
                    }
                    
                    //Caluclate Score of child records
                    var qualificationPercent = parseFloat(qualificationCount * 100 / parentQualificationList.length);
                    var spokenPercent = parseFloat(spokenCount * 100 / parentSpokenList.length);
                    var technicalPercent = parseFloat(technicalCount * 100 / parentTechnicalList.length);
                    var expPercent = parseFloat(tempPercent * 100 / parentExp);
                    var result = parseFloat(qualificationPercent + spokenPercent + technicalPercent + expPercent);
                    result = result * 100 /400;
                    childRecordList.push({Name:childList[i].Name,experience:tempExpList,qualification:tempQualification,spoken:tempSpoken,technical:tempTechnical,score:result.toFixed(2)});
                }
                component.set('v.childRecordsList',childRecordList); //store data in childrecordslist
            }
            else if(state === 'ERROR'){
                alert(response.getError());
            }
        });
        $A.enqueueAction(action);  
    }
})