public with sharing class RetrieveMetadataController {
    public static final Integer METADATA_API_VERSION = Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));
        
    public static String renewAccessToken(String recId){
        OrgDeatil__c orgObj = [SELECT Name, Custom_Url__c, Refersh_Token__c, Instance_Url__c, User_Id__c  FROM OrgDeatil__c WHERE Id =:recId LIMIT 1];
        System.debug('orgObj='+orgObj);
        Metadata_Creditional__mdt metaObj = [SELECT Client_Key__c, Secret_Key__c From Metadata_Creditional__mdt where Developername = 'ConnectApp_Key'];
        String response;
        if(orgObj != null && metaObj != null){
            response = RestServiceCallout.renewAccessTokenFromRefToken(orgObj.Custom_Url__c, metaObj.Client_Key__c, metaObj.Secret_Key__c, orgObj.Refersh_Token__c);
                System.debug('renewAccessToken response='+response);
                if(response == null){
                    response = null;
                }else{
                    Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(response); //Fetch Access Token
                    if(meta != null){
                        String accessToken = (String) meta.get('access_token');
                        System.debug('accessToken='+accessToken);
                        response = accessToken;
                    }
                }
        }
        return response;
    }

    @AuraEnabled
    public static MetadataRecords litsOfMetadata(String recId){
        MetadataRecords metadataObj = new MetadataRecords();
        List<String> metadataTypeNames  = new List<String>();
        if(String.isNotBlank(recId)){
            try{     
                MetadataService.MetadataPort service = createService(recId);
                MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(METADATA_API_VERSION);
                if(describeResult != null){
                    for(MetadataService.DescribeMetadataObject metadataObject : describeResult.metadataObjects){
                        if(!metadataObject.inFolder){
                            metadataTypeNames.add(metadataObject.xmlName);
                            if(metadataObject.childXmlNames!=null){
                                for(String childXmlName : metadataObject.childXmlNames)
                                    if(childXmlName!=null)
                                    metadataTypeNames.add(childXmlName);
                            }	
                        }
                    }
                        metadataTypeNames.sort();
                        metadataObj.dataList = metadataTypeNames;
                        metadataObj.expireAccessTokenCheck = true;
                        System.debug('metadataTypeNames='+metadataTypeNames);	
                 }
                
                }
                catch(Exception e){
                    System.debug('My exception='+e);
                    String response = RetrieveMetadataController.renewAccessToken(recId);
                    System.debug('excep response='+response);
                    if(response == null){
                        metadataObj = null;
                    }
                    else{
                        metadataObj.expireAccessTokenCheck = false;
                        metadataTypeNames.add(response);
                        metadataObj.dataList = metadataTypeNames;
        
                    }
                }
        }
      
        System.debug('metadataObj='+metadataObj);
        return metadataObj;
    }

    @AuraEnabled
    public static MetadataRecords listMetadataItems(String recId, String MetaDataType){
        System.debug('recId='+recId);
        System.debug('MetaDataType='+MetaDataType);
        Set<String> metadataTypeNames = new Set<String>();
        MetadataRecords metadataObj = new MetadataRecords();
        if(String.isNotBlank(recId) && String.isNotBlank(MetaDataType)){
        try{
                MetadataService.MetadataPort service = createService(recId);				
                List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();		
                MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
                queryLayout.type_x = MetaDataType;
               // queryLayout.folder =  MetadataFolder;
                queries.add(queryLayout);		
                MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, METADATA_API_VERSION);
                if(fileProperties != null){
                    for(MetadataService.FileProperties fileProperty : fileProperties)
                    metadataTypeNames.add(fileProperty.fullName);
                    //metadataTypeNames.sort();
                }
                System.debug('fullNames='+metadataTypeNames);
                metadataObj.dataList = new List<String>(metadataTypeNames);
                metadataObj.expireAccessTokenCheck = true;

            }
            catch(Exception e){
                System.debug('My exception='+e);
                String response = RetrieveMetadataController.renewAccessToken(recId);
                System.debug('excep response='+response);
                if(response == null){
                    metadataObj = null;
                }
                else{
                    metadataObj.expireAccessTokenCheck = false;
                    metadataTypeNames.add(response);
                    metadataObj.dataList = new List<String>(metadataTypeNames);
                }
            }
            System.debug('metadataObj='+metadataObj);
        }
        return metadataObj;
    }

    @AuraEnabled
    public static MetadataRecords retrieveMetadataItem(String recId, String MetaDataType, List<String> MetaDataItem){
        System.debug('recId='+recId);
        System.debug('MetaDataItem='+MetaDataItem);
        System.debug('MetaDataType='+MetaDataType);
        List<String> metadataTypeNames = new List<String>();
        MetadataRecords metadataObj = new MetadataRecords();
        if(String.isNotBlank(recId) && String.isNotBlank(MetaDataType) && MetaDataItem.size() > 0){
            try{
                MetadataService.MetadataPort service = createService(recId);				
                MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
                retrieveRequest.apiVersion = METADATA_API_VERSION;
                retrieveRequest.packageNames = null;
                retrieveRequest.singlePackage = true;
                retrieveRequest.specificFiles = null;
                retrieveRequest.unpackaged = new MetadataService.Package_x();
                retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
                MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
                packageType.name = MetaDataType; 
                packageType.members = MetaDataItem;
                retrieveRequest.unpackaged.types.add(packageType);
                MetadataService.AsyncResult AsyncResult = service.retrieve(retrieveRequest);
                if(AsyncResult != null){
                    System.debug('AsyncResult='+AsyncResult);
                    System.debug('AsyncResult Id='+AsyncResult.Id);
                    metadataObj.expireAccessTokenCheck = true;
                    metadataTypeNames.clear();
                    metadataTypeNames.add(AsyncResult.Id);
                    metadataObj.dataList = metadataTypeNames;
                }
              
            } catch(Exception e){
                System.debug('My exception='+e);
                String response = RetrieveMetadataController.renewAccessToken(recId);
                System.debug('excep response='+response);
                if(response == null){
                    metadataObj = null;
                }
                else{
                    metadataObj.expireAccessTokenCheck = false;
                    metadataTypeNames.clear();
                    metadataTypeNames.add(response);
                    metadataObj.dataList = metadataTypeNames;
                }
            }

        }
        return metadataObj;
    }

    @AuraEnabled
    public static MetadataRecords checkAsyncRequest(String recId, String asyncResultId){
        System.debug('recId='+recId);
        System.debug('asyncResultId='+asyncResultId);
        MetadataRecords metadataObj = new MetadataRecords();
        List<String> metadataTypeNames = new List<String>();
        if(String.isNotBlank(recId) && String.isNotBlank(asyncResultId)){
            try{
                MetadataService.MetadataPort service = createService(recId);
                MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(asyncResultId, true);
                if(retrieveResult != null){
                    System.debug('retrieveResult.done='+retrieveResult.done);
                    metadataObj.asynCheck = retrieveResult.done;
                    if(retrieveResult.done){
                        if(retrieveResult.status.equalsIgnoreCase('Succeeded')){
                            System.debug('Not Success=');
                            String MetaDataRetrieveZip = retrieveResult.zipFile;
                            System.debug('MetaDataRetrieveZip='+MetaDataRetrieveZip);
                            metadataTypeNames.add(MetaDataRetrieveZip);
                            metadataObj.dataList = metadataTypeNames;
                        }
                    }
                }
                 metadataObj.expireAccessTokenCheck = true;
            }
            catch(Exception e){
                System.debug('My exception='+e);
                String response = RetrieveMetadataController.renewAccessToken(recId);
                System.debug('excep response='+response);
                if(response == null){
                    metadataObj = null;
                }
                else{
                    metadataObj.expireAccessTokenCheck = false;
                    metadataTypeNames.add(response);
                    metadataObj.dataList = metadataTypeNames;
                }
            }
        }
        return metadataObj;
    }
    

    @AuraEnabled
    public static Boolean saveNewAccessToken(String recId, String accessToken){
        Boolean success = false;
        System.debug('saveNewAccessToken recId='+recId);
        System.debug('saveNewAccessToken accessToken='+accessToken);
        if(String.isNotBlank(recId) && String.isNotBlank(accessToken)){
             OrgDeatil__c orgObj = [SELECT Name, Access_Token__c  FROM OrgDeatil__c WHERE Id =:recId LIMIT 1];
             if(orgObj != null){
                orgObj.Access_Token__c = accessToken;
                update orgObj;
                success = true;
             }
        }
         return success;
    }

    // Deploy Metadata
    @AuraEnabled
    public static MetadataRecords deployZip(
        String recId, 
        String zipData, 
        Boolean allowMissingFiles, 
        Boolean autoUpdatePackage, 
        Boolean checkOnly, 
        Boolean ignoreWarnings, 
        Boolean performRetrieve, 
        Boolean rollbackOnError, 
        List<String> runTests, 
        Boolean purgeOnDelete,
        String testLevel,
        Boolean singlePackage
        )
	{
        System.debug('recId='+recId);
        System.debug('zipData='+zipData);
        List<String> metadataTypeNames = new List<String>();
        MetadataRecords metadataObj	= new MetadataRecords();	
        if(String.isNotBlank(recId) && String.isNotBlank(zipData)){
            try{
                MetadataService.MetadataPort service = createService(recId);
                MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
                deployOptions.allowMissingFiles = allowMissingFiles;
                deployOptions.autoUpdatePackage = autoUpdatePackage;
                deployOptions.checkOnly = checkOnly;
                deployOptions.ignoreWarnings = ignoreWarnings;
                deployOptions.performRetrieve = performRetrieve;
                deployOptions.purgeOnDelete = purgeOnDelete;
                deployOptions.rollbackOnError = rollbackOnError;
                deployOptions.testLevel = testLevel;
                deployOptions.singlePackage = singlePackage;	
                deployOptions.runTests = runTests;

                MetadataService.AsyncResult AsyncResult = service.deploy(zipData, deployOptions);	
                System.debug('AsyncResult='+AsyncResult);
                metadataObj.expireAccessTokenCheck = true;
                metadataTypeNames.clear();
                metadataTypeNames.add(AsyncResult.Id);
                metadataObj.dataList = metadataTypeNames;	
                System.debug('metadataObj='+metadataObj);
		
            } catch(Exception e){
                    System.debug('My exception='+e);
                    String response = RetrieveMetadataController.renewAccessToken(recId);
                    System.debug('excep response='+response);
                    if(response == null){
                        metadataObj = null;
                    }
                    else{
                        metadataObj.expireAccessTokenCheck = false;
                        metadataTypeNames.clear();
                        metadataTypeNames.add(response);
                        metadataObj.dataList = metadataTypeNames;
                    }
            }
        }	
		return metadataObj;
	}	
    
    @AuraEnabled
	public static MetadataRecords checkAsyncRequestDeploy(String recId, String asyncResultId){	
        System.debug('recId='+recId);
        System.debug('asyncResultId='+asyncResultId);
        MetadataRecords metadataObj = new MetadataRecords();
        List<String> metadataTypeNames = new List<String>();
        if(String.isNotBlank(recId) && String.isNotBlank(asyncResultId)){
            try{
                MetadataService.MetadataPort service = createService(recId);
                MetadataService.DeployResult deployResult = service.checkDeployStatus(asyncResultId, true);
                metadataObj.asynCheck = deployResult.done;
                metadataObj.deploySuccess = deployResult.success;
                metadataObj.expireAccessTokenCheck = true;
                System.debug('deployResult.done='+deployResult.done);
                System.debug('deployResult.success='+deployResult.success);
                if(deployResult.done){
                    if(!deployResult.success){
                        if(deployResult.details!=null && deployResult.details.componentFailures!=null){
                            MetadataService.DeployMessage deployMessage = deployResult.details.componentFailures[0];
                                if(deployMessage.problem!=null){
                                        String deployFail =	deployMessage.fileName + ' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + deployMessage.problem;
                                        System.debug('deployFail='+deployFail);
                                        metadataTypeNames.clear();
                                        metadataTypeNames.add(deployFail);
                                        metadataObj.dataList = metadataTypeNames;
                                }
                        }
                    }      
                }
            }
            catch(Exception e){
                System.debug('My exception='+e);
                String response = RetrieveMetadataController.renewAccessToken(recId);
                System.debug('excep response='+response);
                if(response == null){
                    metadataObj = null;
                }
                else{
                    metadataObj.expireAccessTokenCheck = false;
                    metadataTypeNames.clear();
                    metadataTypeNames.add(response);
                    metadataObj.dataList = metadataTypeNames;
                }
            }
        }
		return metadataObj;
    }

    public static MetadataService.MetadataPort createService(String recId){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort(); 
        if(String.isNotBlank(recId)){
            service.SessionHeader = new MetadataService.SessionHeader_element();
            OrgDeatil__c orgData = [SELECT Access_Token__c FROM OrgDeatil__c WHERE Id =:recId limit 1];
            if(orgData != null){
                System.debug('orgData='+orgData);
                service.SessionHeader.sessionId = orgData.Access_Token__c;
            }
        }	
        return service;
    }	
    
    public class MetadataRecords{
        @AuraEnabled public Boolean expireAccessTokenCheck;
        @AuraEnabled public List<String> dataList;
        @AuraEnabled public  Boolean asynCheck;
        @AuraEnabled public Boolean deployFail;
        @AuraEnabled public Boolean deploySuccess;
    }
   
 
}