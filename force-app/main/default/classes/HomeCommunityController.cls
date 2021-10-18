public class HomeCommunityController {
    
    @AuraEnabled
    public static sObject userDetail()
    {    
        User us = new User();
        us = [Select Id,Name,Email,FullPhotoUrl from User where Id=:userinfo.getuserId()];
        System.debug('us=='+us);       
        return us;
    }
    
}