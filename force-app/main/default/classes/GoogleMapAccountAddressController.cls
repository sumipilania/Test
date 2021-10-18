public class GoogleMapAccountAddressController {
    
    @AuraEnabled
    public static String fetchAccountLocation(Id parentRecId){
        List<GooglMap__mdt> mapMetadata = [SELECT API_Key__c From GooglMap__mdt];       
        System.debug('mapMetadata=='+mapMetadata);
        return '';
    }
}