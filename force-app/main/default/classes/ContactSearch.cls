public class ContactSearch {

    public static Contact[] searchForContacts(String namee, String mailing)
    {
        Contact[] con=[select ID, Name from Contact where(LastName=:namee AND MailingPostalCode=:mailing)];
        return con;
    }
}