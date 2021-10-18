/*
 Created by   -    Sumit Pilaniya
 Date		  -    27/08/2019
 Description  -    Import CSV File With Date, Date/Time, Text Area with Comma, Boolean

  */


public class ImportCsvController 
{
    public Blob csvFileBody{get;set;} //All Body and Content of file in blob
    public string csvAsString{get;set;}  //Blob convert into String which hold
    public String[] csvFileLines{get;set;}  //All row insert one by one
    public List<Contact> conlist{get;set;}  //Insert Contact List
    
    public ImportCsvController()
    {
        csvFileLines = new String[]{};
        conlist = New List<Contact>(); 
        csvAsString = '';
    }
    
    //Import CSV File
    public void importCSVFile()
    {
        try{
            csvAsString = csvFileBody.toString();  //Blob into String
            csvFileLines = csvAsString.split('\n'); //Colum wise split
            
            //Till File Length
            for(Integer i=0;i<csvFileLines.size();i++)   
            {
                Contact conObj = new Contact();  //Contact Object Creation
                String tempStr = csvFileLines[i];  //Row wise fetch Text area Matter with comma
                String tempTextArea = tempStr.substringAfter('"');   //" After Data Fetch
                tempTextArea = tempTextArea.substringBefore('"');//" Before Data Fetch
                string[] csvRecordData = csvFileLines[i].split(','); //Fetch Colum wise
                conObj.Lastname = csvRecordData[0]; //Add List wise Colum        
                conObj.Title = csvRecordData[1];
                System.debug(csvRecordData[2]);
                conObj.Birthdate = Date.valueOf(csvRecordData[2]);
                conObj.Import_Date_Time__c =  Date.valueOf(csvRecordData[3]);   
                conObj.Import_Boolean_Type__c = Boolean.valueOf(csvRecordData[4]);  
                conObj.Import_Text_Area__c = tempTextArea;  
                conlist.add(conObj); //Add All List  
            }
           //insert conlist; //Insert All Records
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }  
    }
}