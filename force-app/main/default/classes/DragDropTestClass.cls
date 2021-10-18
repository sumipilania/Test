@isTest
class DragDropTestClass 
{
    @TestSetup
    static void accountInsert()
    {
        List <Account> acc = new List<Account>();
        for(Integer i=1 ; i<=2; i++)
        {
            acc.add(new Account(Name='TestAccount1'));
            acc.add(new Account(Name='TestAccount2'));
            acc.add(new Account(Name='TestAccount3'));
        }
        insert acc;
    }
    
    @isTest
    static void insertAttachement()
    {
        Test.startTest();
        Account accRec=[Select id from Account limit 1];
        for(Integer i=1;i<=10;i++)
        {
            String myString1 = 'Body of Attachent'+i;
            DragDropAccountController.doUploadAttachment(accRec.id,myString1,'File1'+i);
        }
        List<Attachment> attList= [SELECT Id FROM Attachment WHERE ParentId = :accRec.id];
        System.assertEquals(10,attList.size());
        Test.stopTest();
    }
}