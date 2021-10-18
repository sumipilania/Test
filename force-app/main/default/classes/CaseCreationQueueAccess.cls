public class CaseCreationQueueAccess {
    @InvocableMethod
    public static void caseRecordAccess(List<Case> caseObjList){
        List<CaseShare> insertShareReords = new List<CaseShare>();
        Set<Id> allUsersId = new Set<Id>();
        Set<Id> queueInsideGroupId = new Set<Id>();
    if(caseObjList.size() > 0){
            List<GroupMember> groupMemberList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =: caseObjList[0].OwnerId];
           if(groupMemberList.size() > 0){
                for(GroupMember memberObj : groupMemberList){
                    if(String.valueOf(memberObj.UserOrGroupId.getSObjectType()).toLowerCase() == 'group'){
                        queueInsideGroupId.add(memberObj.UserOrGroupId);
                    }else{
                        allUsersId.add(memberObj.UserOrGroupId);
                    }
                }
                if(queueInsideGroupId.size() > 0){
                    List<GroupMember> groupInsideQueueList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN : queueInsideGroupId];
                    for(GroupMember memberObj : groupInsideQueueList){
                            allUsersId.add(memberObj.UserOrGroupId);
                    }
                    
                    if(allUsersId.size() > 0){
                       List<User> allUserList = [SELECT Name, ManagerID, Manager.ManagerID FROM User WHERE Id IN :allUsersId];
                        if(allUserList.size() > 0){
                            for(User userObj : allUserList){
                                if(userObj.ManagerID != null){
                                    CaseShare caseObjManager  = new CaseShare(); 
                                    caseObjManager.CaseId  = caseObjList[0].Id;
                                    caseObjManager.UserOrGroupId = userObj.ManagerID;
                                    caseObjManager.CaseAccessLevel = 'Edit'; 
                                    insertShareReords.add(caseObjManager);
                                    if(userObj.Manager.ManagerID != null){
                                        CaseShare caseObjManagerToManager  = new CaseShare(); 
                                        caseObjManagerToManager.CaseId  = caseObjList[0].Id;
                                        caseObjManagerToManager.UserOrGroupId = userObj.Manager.ManagerID;
                                        caseObjManagerToManager.CaseAccessLevel = 'Edit'; 
                                        insertShareReords.add(caseObjManagerToManager);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if(insertShareReords.size() > 0){
            insert insertShareReords;
        }
    }
}