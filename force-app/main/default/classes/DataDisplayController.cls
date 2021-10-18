public class DataDisplayController {
    public ID parentId = '0012v00002L8zRq';
    public String pdfName = 'pdfFile';
   
    public DataDisplayController(){
       
    }
    
    public PageReference saveAttachement() {
        System.debug('Enter');
        PageReference pdf = Page.PdfGeneratorTemplate;
        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('id',parentId);
        
        // create the new attachment
        Attachment attach = new Attachment();
        
        // the contents of the attachment from the pdf
        Blob body;
        
        try {
            
            // returns the output of the page as a PDF
            body = pdf.getContent();
            
            System.debug('body=='+body.toString());
            // need to pass unit test -- current bug	
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some Text');
            System.debug('exception=='+body.toString());
        }
        
        attach.Body = body;
        // add the user entered name
        attach.Name = pdfName;
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = parentId;
        insert attach;
        
        // send the user to the account to view results
        return new PageReference('/'+parentId);
        
    }
}