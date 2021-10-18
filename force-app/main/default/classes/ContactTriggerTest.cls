@isTest
class ContactTriggerTest {
    
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
    static void insert_testCases(){
        Test.startTest();
        Account accRec=[Select id from Account limit 1];
        
        //Insert First time Contact Record
        Contact conSingleRecord = new Contact(LastName='s1', AccountId=accRec.id);
        insert conSingleRecord;
        System.assertEquals(1, [select Contact_Sequence__c from contact where AccountId = :accRec.id AND id = :conSingleRecord.id][0].Contact_Sequence__c);
        
        //Insert Records when Account have already child contact
        Contact conSingleRecord1 = new Contact(LastName='s2', AccountId=accRec.id);
        insert conSingleRecord1;
        System.assertEquals(2, [select Contact_Sequence__c from contact where AccountId = :accRec.id AND id = :conSingleRecord1.id][0].Contact_Sequence__c);
        
        //Insert Records in bulk
        List<Contact> conBulk=new List<Contact>();
        for(Integer i=3;i<=10;i++)
        {
            conBulk.add(new Contact(LastName='s'+i,AccountId=accRec.id));
        }
        insert conBulk; 
        System.assertEquals(10, [select Contact_Sequence__c from contact where AccountId = :accRec.id AND id = :conBulk[7].id][0].Contact_Sequence__c);
        
        //If We can't insert any account
        Contact conSingleRecord2 = new Contact(LastName='s11');
        insert conSingleRecord2;
        System.assertEquals(null, [select Contact_Sequence__c from contact where AccountId = :null AND id = :conSingleRecord2.id][0].Contact_Sequence__c);
        Test.stopTest();
        
    }
    
    @isTest
    static void delete_testCases()
    {
        Test.startTest();
        Account accRec=[Select id from Account limit 1];
        List<Contact> con=new List<Contact>();
        for(Integer i=1;i<=10;i++)
        {
            con.add(new Contact(LastName='s'+i,AccountId=accRec.id));
        }
        insert con;
        
        //Single Delete
        System.assertEquals(10, con.size());
        List<Contact> conDelete = new List<Contact>([Select id, LastName, Contact_Sequence__c from Contact where AccountId= :accRec.id AND Contact_Sequence__c = 5]);
        delete conDelete;
        List<Contact> afterConDelete = new List<Contact>([Select  LastName,Contact_Sequence__c from Contact where AccountId= :accRec.id]);
        System.assertEquals(5, afterConDelete[4].Contact_Sequence__c );
        
        
        //Bulk Reocrds Delete
        System.assertEquals(9, afterConDelete.size());
        List<Contact> conDel = [Select id, LastName, Contact_Sequence__c from Contact where AccountId= :accRec.id AND Contact_Sequence__c IN (5,2,8)];
        delete conDel;
        List<Contact> bulkafterConDelete = new List<Contact>([Select  LastName,Contact_Sequence__c from Contact where AccountId= :accRec.id]);
        System.assertEquals(6, bulkafterConDelete.size());
        System.assertEquals(1, bulkafterConDelete[0].Contact_Sequence__c );
        
        //Multiple Account Related Contact Delete Same time
        List<Account> accRec1=[Select id,Name from Account limit 2];
        List<Contact> mulCon = new List<Contact>();
        for(Integer i=1 ; i<=10; i++)
        {
            mulCon.add(new Contact(LastName='Test1'+i, AccountId = accRec1[0].id)); 
            mulCon.add(new Contact(LastName='Test2'+i, AccountId = accRec1[1].id)); 
        }
        insert mulCon;
        List<Contact> conDel1= [Select id, LastName, Contact_Sequence__c from Contact where AccountId= :accRec1[0].id AND Contact_Sequence__c IN (5,4,8)];
        List<Contact> conDel2= [Select id, LastName, Contact_Sequence__c from Contact where AccountId= :accRec1[1].id AND Contact_Sequence__c IN (4,6,9)];
        delete conDel1;
        delete conDel2;
        List<Contact> mulBulkafterConDelete = new List<Contact>([Select  LastName,Contact_Sequence__c from Contact where AccountId= :accRec1[0].id]);
        List<Contact> mulBulkafterConDelete1 = new List<Contact>([Select  LastName,Contact_Sequence__c from Contact where AccountId= :accRec1[1].id]);
        System.assertEquals(3, mulBulkafterConDelete[2].Contact_Sequence__c );
        System.assertEquals(2, mulBulkafterConDelete1[1].Contact_Sequence__c );
        Test.stopTest();
        
    }
    @isTest
    static void unDelete_testCases()
    {
        Test.startTest();
        Account accRec=[Select id from Account limit 1];
        List<Contact> con=new List<Contact>();
        for(Integer i=1;i<=10;i++)
        {
            con.add(new Contact(LastName='s'+i,AccountId=accRec.id));
        }
        insert con;
        List<Contact> conDelete1 = new List<Contact>([Select id, LastName, Contact_Sequence__c from Contact where AccountId= :accRec.id AND Contact_Sequence__c = 5]);
        delete conDelete1;
        List<Contact> conUnDelete = new List<Contact>([SELECT Id, Name, Contact_Sequence__c  FROM Contact WHERE IsDeleted = true AND Contact_Sequence__c = 5 ALL ROWS] );
        try{
            undelete conUnDelete;
        }
        catch(DmlException e)
        {
            Contact afterConUnDelete = [Select Id,LastName, Contact_Sequence__c from Contact where LastName='s5' limit 1];
            System.assertEquals(10, afterConUnDelete.Contact_Sequence__c);
        }
        Test.stopTest();
    }
    
    @isTest
    static void updateSequence_testCases()
    {
        Test.startTest();
        //Reparenting
        List<Account> accRec1=[Select id,Name from Account];
        List<Contact> mulConUpdate = new List<Contact>();
        for(Integer i=1 ; i<=10; i++)
        {
            mulConUpdate.add(new Contact(LastName='Test1'+i, AccountId = accRec1[0].id)); 
            mulConUpdate.add(new Contact(LastName='Test2'+i, AccountId = accRec1[1].id)); 
            mulConUpdate.add(new Contact(LastName='Test3'+i, AccountId = accRec1[2].id)); 
        }
        insert mulConUpdate;
        List<Contact> conList1 = [Select id, LastName, Contact_Sequence__c from Contact where AccountId= : accRec1[0].id];
        List<Contact> updateList = new List<Contact>();
        System.assertEquals(10, conList1.size());
        updateList.add(new Contact(id=conList1[5].id, AccountId=accRec1[1].id));
        updateList.add(new Contact(id=conList1[2].id, AccountId = accRec1[2].id));
        update updateList;
        List<Contact> tempConList1 = [Select id, LastName, Contact_Sequence__c from Contact where AccountId= : accRec1[0].id];
        System.assertEquals(8, tempConList1.size());
        
        //Normal Update on Single Record
        List<Contact> upCon = [Select id, LastName, Contact_Sequence__c from Contact where AccountId= : accRec1[2].id ORDER BY Contact_Sequence__c ASC];
        Contact co2 = upCon[3];
        co2.Contact_Sequence__c = 6;
        update co2;
        List<Contact> conUpSingle = new List<Contact>([Select  LastName,Contact_Sequence__c from Contact where AccountId= :accRec1[2].id AND LastName = 'Test34']);
        System.assertEquals(6,conUpSingle[0].Contact_Sequence__c);
        
        
        //Mutliple Records
        List<Contact> conListMul = new List<Contact>();
        List<Contact> co1 =[Select ID,Name, Contact_Sequence__c from Contact where AccountID= : accRec1[2].id];
        for(Contact c : co1){
            if(c.Name == 'Test32'){
                c.Contact_Sequence__c = 4 ; 
                conListMul.add(c); 
            } 
            if(c.Name == 'Test35'){
                c.Contact_Sequence__c = 7; 
                conListMul.add(c); 
            }
            if(c.Name == 'Test37'){
                c.Contact_Sequence__c = 1; 
                conListMul.add(c); 
            } 
        }
        update conListMul;
        List<Contact> conUpMul = new List<Contact>([Select  LastName,Contact_Sequence__c from Contact where AccountId= :accRec1[2].id AND LastName = 'Test35']);
        System.assertEquals(7,conUpMul[0].Contact_Sequence__c);
        
        Test.stopTest();
    }
}