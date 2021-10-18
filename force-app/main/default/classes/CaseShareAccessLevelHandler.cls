public with sharing class CaseShareAccessLevelHandler {
   public static void insertCaseShareRecordBasedOnUser(List<Case> caseObjList){
    List<CaseShare> caseShareObjList = new List<CaseShare>();
        Set<Id> setOfUserId = new Set<Id>();
        for(Case caseObj : caseObjList){
            setOfUserId.add(caseObj.OwnerId);
        }
        System.debug('setOfUserId='+setOfUserId);
        Map<ID, User> userObjMap = new Map<ID, User>([SELECT Name, ManagerID, Manager.Name, Manager.ManagerID FROM User WHERE Id IN :setOfUserId]);
        System.debug('userObjMap='+userObjMap);
        for(Case caseObj : caseObjList){
            if(userObjMap.containsKey(caseObj.OwnerId)){
                User userObj = userObjMap.get(caseObj.OwnerId);
                if(userObj.ManagerID != null){
                    CaseShare subCaseManager  = new CaseShare(); 
                    subCaseManager.CaseId  = caseObj.Id;
                    subCaseManager.UserOrGroupId = userObj.ManagerID;
                    subCaseManager.CaseAccessLevel = 'Edit'; 
                    caseShareObjList.add(subCaseManager);
                    if(userObj.Manager.ManagerID != null){
                        CaseShare managerCase  = new CaseShare(); 
                        managerCase.CaseId  = caseObj.Id;
                        managerCase.UserOrGroupId = userObj.Manager.ManagerID;
                        managerCase.CaseAccessLevel = 'Edit'; 
                        caseShareObjList.add(managerCase);
                    }
                }
            }
        }
        if(caseShareObjList.size() > 0){
            insert caseShareObjList;
        }
   }


   public static void insertCaseShareRecordBasedOnQueue(List<Case> caseObjList){
    Set<Id> listOfUserId = new Set<Id>();
    Set<Id> managerIdSet = new Set<Id>();
    Set<Id> caseOwnerIds = new Set<Id>();
    for(Case csObj :caseObjList){
        caseOwnerIds.add(csObj.OwnerId);
    }
    List<CaseShare> caseShareObjList = new List<CaseShare>();
    List<GroupMember> userGroupMemeber = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :caseOwnerIds];
    System.debug('userGroupMemeber='+userGroupMemeber);
    if(userGroupMemeber.size() > 0){
        for(GroupMember groupMemObj : userGroupMemeber){
            listOfUserId.add(groupMemObj.UserOrGroupId);
        }
        
        List<GroupMember> getPublicGroupMember = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where GroupId IN :listOfUserId AND Group.Type='Regular'];
        if(getPublicGroupMember.size() > 0){
            for(GroupMember publicGroupObj : getPublicGroupMember){
                listOfUserId.add(publicGroupObj.UserOrGroupId);
            }
            List<User> userList = [SELECT Name, ManagerID, Manager.ManagerID FROM User WHERE Id IN :listOfUserId];
            if(userList.size() > 0){
                for(User userObj : userList){
                    if(userObj.ManagerID != null){
                        managerIdSet.add(userObj.ManagerID);
                    }
                    
                    if(userObj.Manager.ManagerID != null){
                        managerIdSet.add(userObj.Manager.ManagerID);
                    }
                    
                }
            }
            if(managerIdSet.size() > 0){
                for(Case caseObj : caseObjList){
                for(Id managerIds : managerIdSet){
                    CaseShare caseShareObj  = new CaseShare(); 
                    caseShareObj.CaseId  = caseObj.Id;
                    caseShareObj.UserOrGroupId = managerIds;
                    caseShareObj.CaseAccessLevel = 'Edit'; 
                    caseShareObjList.add(caseShareObj);
                }
            }
            }
        }
    }
    if(caseShareObjList.size() > 0){
        insert caseShareObjList;
    }
   }
}