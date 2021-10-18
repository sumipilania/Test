public with sharing class UserManagerTriggerHandler1 {
    static List<CaseShare> insertShareReords = new List<CaseShare>();
    public static void managerAccessLevel(Map<Id, User> oldMap, Map<Id, User> newMap){
        Set<Id> allOldUserManagersId = new Set<Id>();
        List<CaseShare> deleteShareReords = new List<CaseShare>();

         for (User obj : oldMap.values()){
            User newObj = newMap.get(obj.Id);
            if(obj.ManagerID != newObj.ManagerID){
                allOldUserManagersId.add(obj.ManagerID);
                allOldUserManagersId.add(obj.Manager.ManagerID);
            }
        }
        Map<Id, CaseShare> allOldManagersCaseMap = new  Map<Id, CaseShare>([SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, RowCause FROM CaseShare where UserOrGroupId IN : allOldUserManagersId AND RowCause = 'Manual' AND CaseAccessLevel='Edit']);
     
        if(allOldManagersCaseMap.size() > 0){
            for (User obj : newMap.values()){
                User oldObj = oldMap.get(obj.Id);
                if(obj.Manager.ManagerID != null && oldObj.Manager.ManagerID != null){
                    if(obj.Manager.ManagerID !=  oldObj.Manager.ManagerID){
                        UserManagerTriggerHandler1.insertShareRecords(allOldManagersCaseMap.get(oldObj.Manager.ManagerID), obj.Manager.ManagerID);
                        deleteShareReords.add(allOldManagersCaseMap.get(oldObj.Manager.ManagerID));
                    }
                }else{
                    if(obj.Manager.ManagerID != null){
                        UserManagerTriggerHandler1.insertShareRecords(allOldManagersCaseMap.get(oldObj.Manager.ManagerID), obj.Manager.ManagerID);
                    }
                    if(oldObj.Manager.ManagerID != null){
                        deleteShareReords.add(allOldManagersCaseMap.get(oldObj.Manager.ManagerID));
                    }
                }
            }
         }
        if(insertShareReords.size() > 0){
            insert insertShareReords;
        }
        if(deleteShareReords.size() > 0){
            insert deleteShareReords;
        }
    }

    public static void insertShareRecords(CaseShare caseObj, String userId){
        CaseShare caseShareWithManager  = new CaseShare(); 
        caseShareWithManager.CaseId  = caseObj.Id;
        caseShareWithManager.UserOrGroupId = userId;
        caseShareWithManager.CaseAccessLevel = 'Edit'; 
        insertShareReords.add(caseShareWithManager);
    }

}