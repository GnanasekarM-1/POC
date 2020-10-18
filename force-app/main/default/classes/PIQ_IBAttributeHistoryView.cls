public with sharing class PIQ_IBAttributeHistoryView {
    public PIQ_IBAttributeHistoryView() {

    }

    @AuraEnabled
    public static String getIBRecordId(String recordId, String fieldName){
        system.debug('Test Log: ' + fieldName+ '--- recordId: '+recordId);
        String response = '';

        if(!String.isBlank(recordId)){

            string strKeyPrefix = recordId.substring(0, 3);
            string strObjName = '';
            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            for(String strObj : allObjs.keySet())
            {
                Schema.DescribeSObjectResult describeResult = allObjs.get(strObj).getDescribe();
                if(describeResult.getKeyPrefix() != null && describeResult.getKeyPrefix().equals(strKeyPrefix))
                {
                    strObjName = describeResult.getName();
                    break;
                }
            }

            try{
                if(!String.isBlank(strObjName) && !String.IsBlank(fieldName)){
                    
                    String query = 'Select ' + fieldName + ' from ' + strObjName + ' where Id = :recordId';
                    system.debug('Query prepared is - ' + query);
                    
                    list<SObject> lstRecords = Database.query(query);
                    if(lstRecords != NULL && lstRecords.size() > 0){
                        response = (String) lstRecords[0].get(fieldName);
                    }
                }
            }catch(exception ex){
                throw new AuraHandledException('Error while loading Attribute history view. ' +  ex.getMessage());
            }
            
        }
        return response;
    }
}