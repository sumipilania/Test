public class UserManagerTriggerHandler {
    
    public static void managerAccessLevel(Map<Id, User> oldUserMap, Map<Id, User> newUserMap){
        Set<Id> oldManagerUserId = new Set<Id>();
        Set<Id> newInsertUserIds = new Set<Id>();
        List<CaseShare> caseShareInsertList = new List<CaseShare>();
        for (User usObj : oldUserMap.values()){
            if(oldUserMap.get(usObj.Id).ManagerID != newUserMap.get(usObj.Id).ManagerID){
                oldManagerUserId.add(usObj.ManagerID);
            }
        }

        if(oldManagerUserId.size() > 0){
            List<CaseShare> newCaseShareObjIds = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, RowCause FROM CaseShare where UserOrGroupId IN : oldManagerUserId AND RowCause = 'Owner'];

            for(User usObj : newUserMap.values()){
                if(newUserMap.get(usObj.Id).Manager.ManagerID != oldUserMap.get(usObj.Id).Manager.ManagerID){
                    newInsertUserIds.add(usObj.Manager.ManagerID);
                    oldManagerUserId.add(oldUserMap.get(usObj.Id).Manager.ManagerID);
                }
                newInsertUserIds.add(usObj.ManagerID);
            }

            for(CaseShare csShareObj : newCaseShareObjIds){
                for(Id userId : newInsertUserIds){
                    CaseShare caseShareObj  = new CaseShare(); 
                    caseShareObj.CaseId  = csShareObj.CaseId;
                    caseShareObj.UserOrGroupId = userId;
                    caseShareObj.CaseAccessLevel = 'Edit'; 
                    caseShareInsertList.add(caseShareObj);
                }
            }
            List<CaseShare> dltOldUserShareRecord = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, RowCause FROM CaseShare where UserOrGroupId IN : oldManagerUserId AND RowCause = 'Manual'];
            
            if(caseShareInsertList.size() > 0){
                insert caseShareInsertList;
            }
            if(dltOldUserShareRecord.size() > 0){
                delete dltOldUserShareRecord;
            }
            
            
        }
    }

}