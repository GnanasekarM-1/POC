global class SNSCallout
{
    @future(callout=true)
    public static void callingOut(String requestBody)
    {
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();                
        list<string> lstSubModules = new list<string>{'MOBN001'};
        map<string, Map<String, String>> AllsvmxSettingList = new map<string, Map<String, String>>();            
        system.debug(loggingLevel.WARN, '=====1= Settings Size' + SVMX_Constants.AllsvmxSettingList);
        AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);    
        String region ='US';
        Map<String,String> mapOfSettingValue  = new Map<String,String>();
        if(AllsvmxSettingList !=NULL && AllsvmxSettingList.containsKey('MOBN001'))
            mapOfSettingValue = AllsvmxSettingList.get('MOBN001');
            
        if(mapOfSettingValue !=NULL && mapOfSettingValue.containsKey('SET003'))
            region = mapOfSettingValue.get('SET003');
            
        System.debug(LoggingLevel.WARN, 'Request Body ='+requestBody);
        HttpRequest newRequest = new HttpRequest();
        if(region=='US')
        {
            newRequest.setEndPoint(System.Label.US_SNSEndPoint);
            newRequest.setHeader('x-api-key',System.Label.US_SNSMicroServiceApiKey);
        }
        else
        {
            newRequest.setEndPoint(System.Label.EU_SNSEndPoint);
            newRequest.setHeader('x-api-key',System.Label.EU_SNSMicroServiceApiKey);            
        }
        
        newRequest.setHeader('Content-type', 'application/json');
        newRequest.setMethod('POST'); 
        newRequest.setBody(requestBody);           
        Http newHttp = new Http();
        HttpResponse newResponse;
        try
        {
            newResponse = newHttp.send(newRequest);
        }
        catch(Exception exceptionHandling)
        {
            system.debug(LoggingLevel.WARN, 'Exception ' + exceptionHandling);
            system.debug(LoggingLevel.WARN, 'Exception Message ' + exceptionHandling.getMessage());            
        }
        List<String> listOfAllUninstalledArns = new List<String>();
        if(newResponse!=NULL)
        {
            System.debug(LoggingLevel.WARN,'Response ='+newResponse.getBody());
            System.debug(LoggingLevel.WARN,'Response ='+newResponse); 
            if(newResponse.getStatusCode()==200)
            {            
                String responseBody = newResponse.getBody();
                List<ARN> arnList = (List<ARN>)JSON.deserialize(responseBody,List<ARN>.class);            
                for(ARN newARN:arnList)
                {
                    if(newARN.StatusCode=='400')
                    {
                        listOfAllUninstalledArns.add(newARN.arn);   
                    }
                }
            }
        }
        if(!listOfAllUninstalledArns.isEmpty())                
        {
            List<SVMXC__SM_SNS_Detail__c> listOfDetails = new List<SVMXC__SM_SNS_Detail__c>();
            for(SVMXC__SM_SNS_Detail__c newDetails:[Select Id,SVMXC__SM_User__c,SVMXC__SM_TargetArn__c,SVMXC__SM_Status__c,SVMXC__SM_IsActive__c From SVMXC__SM_SNS_Detail__c Where SVMXC__SM_TargetArn__c IN:listOfAllUninstalledArns])
            {
                
                newDetails.SVMXC__SM_Status__c='UnInstalled';
                newDetails.SVMXC__SM_IsActive__c=false;
                listOfDetails.add(newDetails);
            }
            
            system.debug(LoggingLevel.WARN, 'listOfDetails =' + listOfDetails); 
            update listOfDetails;   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
    }
    
    public class ARN
    {
        public String arn;
        public String StatusCode;
    }
}