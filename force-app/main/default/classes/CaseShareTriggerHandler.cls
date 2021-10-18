public class CaseShareTriggerHandler {
    public static void manageCaseShareRecordAccess(Map<Id, Case> newMap, Map<Id, Case> oldMap){
        Map<String, Set<Id>> conditionWithCaseIdMap = new Map<String, Set<Id>>{
            'user-user' => new Set<Id>(),
            'user-group' => new Set<Id>(),
            'group-user' => new Set<Id>(),
            'group-group' => new Set<Id>()
        };

        Set<Id> userIdSet = new Set<Id>();
        Set<Id> groupIdSet = new Set<Id>();

        Map<Id, Set<Id>> oldCaseUserIdMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> newCaseUserIdMap = new Map<Id, Set<Id>>();


        Map<Id, Id> oldGroupCaseIdMap = new Map<Id, Id>();
        Map<Id, Id> newGroupCaseIdMap = new Map<Id, Id>();

        for(Case obj : newMap.values()){
            Case oldObj = oldMap.get(obj.Id);
            if(oldObj.OwnerId != obj.OwnerId){
                String oldOwnerType = String.valueOf(oldObj.OwnerId.getSobjectType()).toLowerCase();
                String newOwnerType = String.valueOf(obj.OwnerId.getSobjectType()).toLowerCase();

                conditionWithCaseIdMap.get(oldOwnerType + '-' + newOwnerType).add(obj.Id);

                Set<Id> oldUserSet = new Set<Id>();
                Set<Id> newUserSet = new Set<Id>();
                oldCaseUserIdMap.put(obj.Id, oldUserSet);
                newCaseUserIdMap.put(obj.Id, newUserSet);
                
                if(oldOwnerType == 'user'){
                    userIdSet.add(oldObj.OwnerId);
                    oldUserSet.add(oldObj.OwnerId);
                } else{
                    groupIdSet.add(oldObj.OwnerId);
                    oldGroupCaseIdMap.put(oldObj.OwnerId, obj.Id);
                }
                if(newOwnerType == 'user'){
                    userIdSet.add(obj.OwnerId);
                    newUserSet.add(oldObj.OwnerId);
                } else{
                    groupIdSet.add(obj.OwnerId);
                    newGroupCaseIdMap.put(obj.OwnerId, obj.Id);
                }
            }
        }

        if(!groupIdSet.isEmpty()){
            Map<Id, Group> groupMap = new Map<Id, Group>([
                SELECT 
                    Id, Type, Name, Email, OwnerId, DeveloperName,
                    (
                        Select GroupId, UserOrGroupId FROM GroupMembers
                    )
                FROM Group 
                WHERE Id IN: groupIdSet
            ]);
            //Map<Id, Set<Id>> queueUserMap = new Map<Id, Set<Id>>();
            Map<Id, Id> groupToQueryMap = new Map<Id, Id>();
            for(Group queueObj : groupMap.values()){
                if(queueObj.GroupMembers != null && !queueObj.GroupMembers.isEmpty()){
                    for(GroupMember memberObj : queueObj.GroupMembers){
                        if(String.valueOf(memberObj.UserOrGroupId.getSObjectType()).toLowerCase() == 'group'){
                            groupToQueryMap.put(memberObj.UserOrGroupId, queueObj.Id);
                        } else{ 
                            Boolean isOldGroup = oldGroupCaseIdMap.containsKey(queueObj.Id);
                            if(isOldGroup){  
                                Id caseId = oldGroupCaseIdMap.get(queueObj.Id);
                                if(oldCaseUserIdMap.containsKey(caseId)){
                                    oldCaseUserIdMap.get(caseId).add(memberObj.UserOrGroupId);
                                } else{
                                    oldCaseUserIdMap.put(caseId, new Set<Id>{ memberObj.UserOrGroupId});
                                }
                            } else{
                                Id caseId = newGroupCaseIdMap.get(queueObj.Id);
                                if(newCaseUserIdMap.containsKey(caseId)){
                                    newCaseUserIdMap.get(caseId).add(memberObj.UserOrGroupId);
                                } else{
                                    newCaseUserIdMap.put(caseId, new Set<Id>{ memberObj.UserOrGroupId});
                                }
                            }
                            userIdSet.add(memberObj.UserOrGroupId);
                        }
                    }
                }
            }
            if(!groupToQueryMap.isEmpty()){
                Map<Id, Group> queriedGroupMap = new Map<Id, Group>([
                    SELECT 
                        Id, Type, Name, Email, OwnerId, DeveloperName,
                        (
                            Select GroupId, UserOrGroupId FROM GroupMembers
                        )
                    FROM Group 
                    WHERE Id IN: groupToQueryMap.keyset()
                ]);
                if(!queriedGroupMap.isEmpty()){
                    for(Group groupObj : queriedGroupMap.values()){
                        if(groupObj.GroupMembers != null && groupObj.GroupMembers.isEmpty()){
                            for(GroupMember memberObj : groupObj.GroupMembers){
                                Id queueId = groupToQueryMap.get(groupObj.Id);
                                Boolean isOldGroup = oldGroupCaseIdMap.containsKey(queueId);
                                if(isOldGroup){  
                                    Id caseId = oldGroupCaseIdMap.get(queueId);
                                    if(oldCaseUserIdMap.containsKey(caseId)){
                                        oldCaseUserIdMap.get(caseId).add(memberObj.UserOrGroupId);
                                    } else{
                                        oldCaseUserIdMap.put(caseId, new Set<Id>{ memberObj.UserOrGroupId});
                                    }
                                } else{
                                    Id caseId = newGroupCaseIdMap.get(queueId);
                                    if(newCaseUserIdMap.containsKey(caseId)){
                                        newCaseUserIdMap.get(caseId).add(memberObj.UserOrGroupId);
                                    } else{
                                        newCaseUserIdMap.put(caseId, new Set<Id>{ memberObj.UserOrGroupId});
                                    }
                                }
                                userIdSet.add(memberObj.UserOrGroupId);
                            }
                        }
                    }       
                }
            }
        }
        
        if(!userIdSet.isEmpty()){
            Map<Id, User> allUserMap = new Map<Id, User>([SELECT Id, Name, ManagerId, Manager.ManagerId  FROM User Where Id IN: userIdSet]);
            Map<Id, Set<Id>> caseUserToCreateMap = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> caseUserToDeleteMap = new Map<Id, Set<Id>>();
            for(String condition : conditionWithCaseIdMap.keyset()){
                Set<Id> caseIdSet = conditionWithCaseIdMap.get(condition);
                if(!caseIdSet.isEmpty()){
                    if(condition == 'user-user'){
                        for(Id caseId : caseIdSet){
                            Case oldObj = oldMap.get(caseId);
                            Case newObj = newMap.get(caseId);
                            User oldUser = allUserMap.get(oldObj.OwnerId);
                            User newUser = allUserMap.get(newObj.OwnerId);
                            if(newUser != null && String.isNotBlank(newUser.ManagerId)){
                                if(caseUserToCreateMap.containsKey(caseId)){
                                    caseUserToCreateMap.get(caseId).add(newUser.ManagerId);
                                } else{
                                    caseUserToCreateMap.put(caseId, new Set<Id>{ newUser.ManagerId});
                                }
                                if(String.isNotBlank(newUser.Manager.ManagerId)){
                                    caseUserToCreateMap.get(caseId).add(newUser.Manager.ManagerId);
                                }
                            }
                            if(oldUser != null && String.isNotBlank(oldUser.ManagerId)){
                                if(caseUserToDeleteMap.containsKey(caseId)){
                                    caseUserToDeleteMap.get(caseId).add(oldUser.ManagerId);
                                } else{
                                    caseUserToDeleteMap.put(caseId, new Set<Id>{ oldUser.ManagerId});
                                }                                    
                                if(String.isNotBlank(oldUser.Manager.ManagerId)){
                                    caseUserToDeleteMap.get(caseId).add(oldUser.Manager.ManagerId);
                                }
                            }
                        }
                    } else if(condition == 'user-group'){
                        for(Id caseId : caseIdSet){
                            Case oldObj = oldMap.get(caseId);
                            Case newObj = newMap.get(caseId);
                            User oldUser = allUserMap.get(oldObj.OwnerId);
                            // delete old user manager record
                            if(oldUser != null && String.isNotBlank(oldUser.ManagerId)){
                                if(caseUserToDeleteMap.containsKey(caseId)){
                                    caseUserToDeleteMap.get(caseId).add(oldUser.ManagerId);
                                } else{
                                    caseUserToDeleteMap.put(caseId, new Set<Id>{ oldUser.ManagerId});
                                }                                    
                                if(String.isNotBlank(oldUser.Manager.ManagerId)){
                                    caseUserToDeleteMap.get(caseId).add(oldUser.Manager.ManagerId);
                                }
                            }
                            Set<Id> newUserSet = newCaseUserIdMap.get(caseId);
                            if(!newUserSet.isEmpty()){
                                for(Id newUserId : newUserSet){
                                    User newUser = allUserMap.get(newUserId);
                                    if(newUser != null && String.isNotBlank(newUser.ManagerId)){
                                        if(caseUserToCreateMap.containsKey(caseId)){
                                            caseUserToCreateMap.get(caseId).add(newUser.ManagerId);
                                        } else{
                                            caseUserToCreateMap.put(caseId, new Set<Id>{ newUser.ManagerId});
                                        }
                                        if(String.isNotBlank(newUser.Manager.ManagerId)){
                                            caseUserToCreateMap.get(caseId).add(newUser.Manager.ManagerId);
                                        }
                                    }
                                }
                            }
                        }
                    } else if(condition == 'group-user'){
                        for(Id caseId : caseIdSet){
                            Case oldObj = oldMap.get(caseId);
                            Case newObj = newMap.get(caseId);
                            User newUser = allUserMap.get(newObj.OwnerId);
                            // delete old user manager record
                            if(newUser != null && String.isNotBlank(newUser.ManagerId)){
                                if(caseUserToCreateMap.containsKey(caseId)){
                                    caseUserToCreateMap.get(caseId).add(newUser.ManagerId);
                                } else{
                                    caseUserToCreateMap.put(caseId, new Set<Id>{ newUser.ManagerId});
                                }
                                if(String.isNotBlank(newUser.Manager.ManagerId)){
                                    caseUserToCreateMap.get(caseId).add(newUser.Manager.ManagerId);
                                }
                            }
                            Set<Id> oldUserSet = oldCaseUserIdMap.get(caseId);
                            if(!oldUserSet.isEmpty()){
                                for(Id oldUserId : oldUserSet){
                                    User oldUser = allUserMap.get(oldUserId);
                                    if(oldUser != null && String.isNotBlank(oldUser.ManagerId)){
                                        if(caseUserToDeleteMap.containsKey(caseId)){
                                            caseUserToDeleteMap.get(caseId).add(oldUser.ManagerId);
                                        } else{
                                            caseUserToDeleteMap.put(caseId, new Set<Id>{ oldUser.ManagerId});
                                        }                                    
                                        if(String.isNotBlank(oldUser.Manager.ManagerId)){
                                            caseUserToDeleteMap.get(caseId).add(oldUser.Manager.ManagerId);
                                        }
                                    }
                                }
                            }
                        }
                    } else if(condition == 'group-group'){
                        for(Id caseId : caseIdSet){
                            Set<Id> oldUserSet = oldCaseUserIdMap.get(caseId);
                            if(!oldUserSet.isEmpty()){
                                for(Id oldUserId : oldUserSet){
                                    User oldUser = allUserMap.get(oldUserId);
                                    if(oldUser != null && String.isNotBlank(oldUser.ManagerId)){
                                        if(caseUserToDeleteMap.containsKey(caseId)){
                                            caseUserToDeleteMap.get(caseId).add(oldUser.ManagerId);
                                        } else{
                                            caseUserToDeleteMap.put(caseId, new Set<Id>{ oldUser.ManagerId});
                                        }                                    
                                        if(String.isNotBlank(oldUser.Manager.ManagerId)){
                                            caseUserToDeleteMap.get(caseId).add(oldUser.Manager.ManagerId);
                                        }
                                    }
                                }
                            }

                            Set<Id> newUserSet = newCaseUserIdMap.get(caseId);
                            if(!newUserSet.isEmpty()){
                                for(Id newUserId : newUserSet){
                                    User newUser = allUserMap.get(newUserId);
                                    if(newUser != null && String.isNotBlank(newUser.ManagerId)){
                                        if(caseUserToCreateMap.containsKey(caseId)){
                                            caseUserToCreateMap.get(caseId).add(newUser.ManagerId);
                                        } else{
                                            caseUserToCreateMap.put(caseId, new Set<Id>{ newUser.ManagerId});
                                        }
                                        if(String.isNotBlank(newUser.Manager.ManagerId)){
                                            caseUserToCreateMap.get(caseId).add(newUser.Manager.ManagerId);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //compare both share records map        
            if(!caseUserToCreateMap.isEmpty()){
                List<CaseShare> recordsToCreateList = new List<CaseShare>();
                for(Id caseId : caseUserToCreateMap.keyset()){
                    Set<Id> userToGiveAccessSet = caseUserToCreateMap.get(caseId);
                    if(!userToGiveAccessSet.isEmpty()){
                        Set<Id> idToRemoveSet = new Set<Id>();
                        for(Id userToGiveAccessId : userToGiveAccessSet){
                            if(caseUserToDeleteMap.containsKey(caseId) && caseUserToDeleteMap.get(caseId) != null 
                                && caseUserToDeleteMap.get(caseId).contains(userToGiveAccessId)){
                                caseUserToDeleteMap.get(caseId).remove(userToGiveAccessId);
                                //No need to create this user access for this caseId
                            } else{
                                recordsToCreateList.add(new CaseShare(
                                    CaseId  = caseId,
                                    UserOrGroupId = userToGiveAccessId,
                                    CaseAccessLevel = 'Edit',
                                    RowCause = 'Manual'
                                ));
                            }
                        }
                    }
                }
                if(!recordsToCreateList.isEmpty()){
                    Database.SaveResult[] insertResult = Database.insert(recordsToCreateList, false);
                }
            }

            if(!caseUserToDeleteMap.isEmpty()){
                Set<Id> usersToFetchSet = new Set<Id>();
                for(Id caseId : caseUserToDeleteMap.keyset()){
                    if(!caseUserToDeleteMap.get(caseId).isEmpty()){
                        usersToFetchSet.addAll(caseUserToDeleteMap.get(caseId));
                    }
                }
                if(!usersToFetchSet.isEmpty()){
                    Map<Id, CaseShare> caseShareMap = new Map<Id, CaseShare>([
                        SELECT 
                            Id, CaseId, UserOrGroupId, CaseAccessLevel, RowCause 
                        FROM CaseShare 
                        WHERE RowCause = 'Manual' AND CaseAccessLevel = 'Edit' AND CaseId IN: caseUserToDeleteMap.keyset()
                        AND UserOrGroupId IN: usersToFetchSet
                    ]);
                    if(!caseShareMap.isEmpty()){
                        List<CaseShare> recordsToDeleteList = new List<CaseShare>();
                        for(CaseShare obj : caseShareMap.values()){
                            Set<Id> usersToDeleteSet = caseUserToDeleteMap.get(obj.CaseId);
                            if(usersToDeleteSet != null && usersToDeleteSet.contains(obj.UserOrGroupId)){
                                recordsToDeleteList.add(obj);
                            }
                        }
                        if(!recordsToDeleteList.isEmpty()){
                            Database.DeleteResult[] deleteResult = Database.delete(recordsToDeleteList, false);
                        }
                    }
                }
            }
        }
    }    
}