public class siteurl{
    
    public siteurl(){
         System.debug('Const');
        System.debug('ApexPages.currentPage().getUrl();==='+ApexPages.currentPage().getUrl());
        System.debug('ApexPages.currentPage()==='+ApexPages.currentPage());
    }
    /**
        * Webkul Software.
        *
        * @category Webkul
        * @author Webkul
        * @copyright Copyright (c) 2010-2018 Webkul Software Private Limited (https://webkul.com)
        * @license https://store.webkul.com/license.html
        */
    public List<String> getSiteUrl(){ 
        List<Site> siteList = [SELECT GuestUserId, Name,MasterLabel, Subdomain, OptionsRequireHttps, UrlPathPrefix FROM Site WHERE Status = 'Active' Limit 1000];
        
        List<String> siteFullUrlList = new List<String>();
        /** We can get instance of the org from organisation object **/
        Organization org = [SELECT InstanceName,Name, IsSandbox, OrganizationType FROM Organization];
        if(siteList != null && siteList.size() != 0) {
            for(Site s: siteList) {
                if(s.Subdomain != null) {
                    String httpStr = 'http://';
                    if(s.OptionsRequireHttps == true) {
                        httpStr = 'https://';
                    }
                    String siteFullUrl = httpStr;
                    if(org.IsSandbox == true) {
                        siteFullUrl += UserInfo.getUserName().substringAfterLast('.')+'-';
                    }
                    siteFullUrl += s.Subdomain + '.';
                    siteFullUrl += (org.IsSandbox || org.OrganizationType == 'Developer Edition' ? (org.InstanceName.toLowerCase() + '.') : '') + 'force.com';
                    if(s.UrlPathPrefix != null) {
                        siteFullUrl += '/'+s.UrlPathPrefix; 
                    }
                    siteFullUrlList.add(siteFullUrl);
                }
            }
            
        }  
        System.debug('siteFullUrlList='+siteFullUrlList);
        return siteFullUrlList;
    }
}