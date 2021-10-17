public class BlubProductShopping {
    
    @AuraEnabled
    public static ProductData fetchProductRecords(String parentId){
        Set<String> childProductId = new Set<String>();
        ProductData proDataObj = new ProductData();
        if(String.isNotBlank(parentId)){
            try{
                List<Product2> childObjList = [SELECT Id, Name FROM Product2 WHERE Parent_Product__c = :parentId];
                if(!childObjList.isEmpty()){
                    for(Product2 p : childObjList){
                        childProductId.add(p.Id);
                    }
                    List<Product_Attribute__c> productAttrList = [SELECT Id, Name FROM Product_Attribute__c];
                    List<Product_Value__c> productValueList = [SELECT Id, Name, Value__c, Product__c, Product_Attribute__c FROM Product_Value__c  WHERE Product__c IN : childProductId];
                    Map<String,List<String>> attributeValueMap = new Map<String,List<String>>();
                    Map<String,List<String>> proIdWithValuesMap = new  Map<String,List<String>>();
                    if(!(productAttrList.isEmpty() && productValueList.isEmpty())){
                        for(Product_Attribute__c pAtt : productAttrList){
                            Set<String> tempValueSet = new Set<String>();
                            for(Product_Value__c pVal : productValueList){
                                if(pAtt.Id == pVal.Product_Attribute__c){
                                    tempValueSet.add(pVal.Value__c);
                                }
                            }
                            for(String productId : childProductId){
                                List<String> tempValueList = new List<String>();
                                for(Product_Value__c pVal : productValueList){
                                    if(pVal.Product__c == productId){
                                        tempValueList.add(pVal.Value__c);
                                    }
                                }
                                proIdWithValuesMap.put(productId,tempValueList);
                            }
                            if(String.isNotBlank(pAtt.Name) && !tempValueSet.isEmpty()){
                                List<String> convertSetToList = new List<String>(tempValueSet);
                                attributeValueMap.put(pAtt.Name,convertSetToList);
                            }
                        }
                        proDataObj.attributeValueMap = attributeValueMap;
                        proDataObj.proIdWithValuesMap = proIdWithValuesMap;
                    }
                }
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());    
            }
        }
        return proDataObj;
    }
    public class ProductData{
        @AuraEnabled public Map<String,List<String>> attributeValueMap;
        @AuraEnabled public Map<String,List<String>> proIdWithValuesMap;
    }
}