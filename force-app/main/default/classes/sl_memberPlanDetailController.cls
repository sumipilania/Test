public with sharing class sl_memberPlanDetailController {

    @AuraEnabled
    public static List<Member_Plan__c> getMemberPlanRecords(String caseId){
       //List<MemberPlan> memPlanList;
       List<Member_Plan__c> memPlanList;
        try {
            if(String.isNotBlank(caseId)) {
                Case c = [SELECT Id, ContactId FROM Case WHERE Id =: caseId];
               // memPlanList = [SELECT Id, Name, (SELECT Id, Name FROM CoverageBenefits) FROM MemberPlan WHERE Patient__c =: c.ContactId AND EffectiveFrom < TODAY AND EffectiveTo > TODAY];
              //  memcov.memPlanList = memPlanList;
              memPlanList = [SELECT Id, Name, (SELECT Id, Name, Dollar_Limit__c, Network_Status__c FROM Coverage_benefits__r) FROM Member_Plan__c WHERE Contact__c =: c.ContactId];
            }
            //memPlanList = null;
            return memPlanList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean cloneMemberPlanAndCoverage(String memberPlanFieldsStr, String memberPlanId, List<Coverage_benefit__c> insertCoverageBenifits) {
        try {
            if(String.isNotBlank(memberPlanFieldsStr)) {
                System.debug('memberPlanFieldsStr='+memberPlanFieldsStr);
                String memberQueryFields = 'SELECT ' + memberPlanFieldsStr + ' Name, Member FROM MemberPlan WHERE Id=:'+memberPlanId;
                System.debug('memberQueryFields='+memberQueryFields);
                System.debug('memberPlanId='+memberPlanId);
                System.debug('insertCoverageBenifits='+insertCoverageBenifits);
                System.debug('insertCoverageBenifits size='+insertCoverageBenifits.size());
                // MemberPlan memObj = (MemberPlan)Database.query(memberQueryFields)[0];
                // MemberPlan memCloneCopy  = memObj.clone(false, true);
                // insert memCloneCopy;  
            }
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}