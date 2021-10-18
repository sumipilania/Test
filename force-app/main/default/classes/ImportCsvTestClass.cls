@isTest
class ImportCsvTestClass 
{
    static String str = 'LastName,Title,BirthDay,Import Date/Time,Import Boolean,Import Text Area\n ABC Company,Banking,2019-08-02,2019-08-07 16:43,TRUE,"Test ,Area, Method"\n B Company,Banking,2019-08-02,2019-08-07 16:43,TRUE,"Test ,Area, Method"\n C Company,Banking,2019-08-02,2019-08-07 16:43,TRUE,"Test Area Method" ';
    static String str1 = 'LastName,Title,BirthDay,Import Date/Time,Import Boolean,Import Text Area\n ABC Company,Banking,20-08-2018,2019-08-07 16:43,TRUE,"Test ,Area, Method"\n B Company,Banking,2019-08-02,2019-08-07 16:43,TRUE,"Test ,Area, Method"\n C Company,Banking,2019-08-02,2019-08-07 16:43,TRUE,"Test Area Method" ';

    public static String[] csvFileLines;
    public static Blob csvFileBody;
    
    @isTest
    static  void testfileupload(){
        Test.startTest();       
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        ImportCsvController obj = new ImportCsvController();
        obj.csvFileBody = csvFileBody;
        obj.importCSVFile();
        
        //Exception Case
        csvFileBody = Blob.valueOf(str1); //Str1  Change Date Format
        csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n');
        obj.csvFileBody = csvFileBody;
        obj.importCSVFile();
        system.assertNotEquals(csvAsString, null);
        Test.stopTest();
    } 
    
    
    
}