/*
 Created by   -    Sumit Pilaniya
 Date		  -    24/08/2019
 Description  -    Drag and Drop Files with Progress bar

  */


global class DragDropAccountController {
    
    public DragDropAccountController(ApexPages.StandardController controller){}
    
    @RemoteAction
    global static String doUploadAttachment(String acctId, String attachmentBody, String attachmentName)
    {
        Attachment att = new Attachment(Name = attachmentName, ParentId = acctId, body = EncodingUtil.base64Decode(attachmentBody));
        insert att;
        return acctId;
    }
}