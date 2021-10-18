@isTest
public class TestRestrictContactByName {
    @isTest static void TestDeleteAccountWithOneContact() {
        // Test data setup
        // Create an account with an opportunity, and then try to delete it
        Contact con = new Contact(LastName='INVALIDNAME');
        insert con;
        
              
        // Perform test
        Test.startTest();
        Database.DeleteResult result = Database.delete(con, false);
        Test.stopTest();
        // Verify 
        // In this case the deletion should have been stopped by the trigger,
        // so verify that we got back an error.
        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Cannot delete account with related opportunities.',
                             result.getErrors()[0].getMessage());
    }

}