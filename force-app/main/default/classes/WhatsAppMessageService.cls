public class WhatsAppMessageService {
    
    @AuraEnabled
    public static List<WhatsAppTwilioBackup__c> fetchChat(Id conId){
        List<WhatsAppTwilioBackup__c> objList = [SELECT Contact__c, From__c,StatusMsg__c,To__c, Body__c From WhatsAppTwilioBackup__c where Contact__c =:conId Order By Id];
        return objList;
    }
    
    @AuraEnabled
    public static String sendMessage(Id contId,String message){
        Contact con = [SELECT Id,Name, Phone from Contact where id =:contId limit 1];
        String resp = '';
        String mobileno = con.Phone;
        errorResponseWrapper erw;
        final String fromNumber = '+14155238886'; 
        String account = 'AC2d767f4c09e54312df52fcd2a3c751c5';  
        String token   = 'b994a029737f1d8d84d0088b18e5e7c3';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/'+account+'/Messages.json');
        req.setMethod('POST'); 
        req.setHeader('Content-Type','application/json');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        Blob headerValue = Blob.valueOf(account + ':' + token);
        String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        if(mobileno != null)
        {
            string jsonString='From='+EncodingUtil.urlEncode('whatsapp:'+fromNumber, 'UTF-8')+'&Body='+EncodingUtil.urlEncode(message, 'UTF-8')+'&To='+EncodingUtil.urlEncode('whatsapp:'+mobileno+'', 'UTF-8')+'';
            req.setBody(jsonString);
            try{
                Http http = new Http();
                HTTPResponse res = http.send(req);
                erw =(errorResponseWrapper)json.deserialize(res.getBody(),errorResponseWrapper.class);
                if(res.getStatusCode()==201){
                    insert new WhatsAppTwilioBackup__c(Contact__c=con.Id,StatusMsg__c='Outbound',To__c=mobileno,From__c=fromNumber,Body__c=message);
                    resp = 'Success';
                }
                else{
                    resp = erw.message;
                }
            }
            catch(Exception e){
            } 
        }
        return resp;
    }
    
    public static void fetchRespFromWhatsapp(){
        String to = apexpages.currentpage().getparameters().get('To').remove('whatsapp:');
        String form = apexpages.currentpage().getparameters().get('From').remove('whatsapp:');
        String body = apexpages.currentpage().getparameters().get('Body');
        String mediaUrl = apexpages.currentpage().getparameters().get('MediaUrl0');
        if(body==null || body==''){
            body = mediaUrl;
        }
        List<WhatsAppTwilioBackup__c> whtObj = [SELECT Contact__c,Name, Id From WhatsAppTwilioBackup__c where To__c =:form AND From__c =:to limit 1 ];
        String conId = whtObj[0].Contact__c;
        insert new WhatsAppTwilioBackup__c(Contact__c=conId,StatusMsg__c='Inbound',To__c=to,From__c=form,Body__c=body);
    }
    
    public class errorResponseWrapper{
        String code;
        String message;
        String moreInfo;
        String status;    
    }
}