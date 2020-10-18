global class SNSMobClientData
{   
    webservice static INTF_WebServicesDef.INTF_SFMResponse insertClientDetails(INTF_WebServicesDef.INTF_SFMRequest requestIn)
    {
        INTF_WebServicesDef.INTF_SFMResponse newResponse = new INTF_WebServicesDef.INTF_SFMResponse();
        newResponse.eventType=requestIn.eventType;
        newResponse.eventName=requestIn.eventName;            
        newResponse.errors = new List<INTF_WebServicesDef.SVMXError>();                    
        try
        {
            String userId,targetArn;
            userId = requestIn.userId;
            targetArn = requestIn.value;
            System.debug(LoggingLevel.WARN,'userId ='+userId);
            System.debug(LoggingLevel.WARN,'targetArn ='+targetArn);            
            System.debug(LoggingLevel.WARN,'Request  ='+requestIn);                        
            System.debug(LoggingLevel.WARN,'Executing EventType  ='+requestIn.eventType+'Event name='+requestIn.eventname);               
            List< SVMXC__SM_SNS_Detail__c > listOfDetails = [Select Id,SVMXC__SM_Status__c,SVMXC__SM_IsActive__c,SVMXC__SM_User__c,SVMXC__SM_TargetArn__c From SVMXC__SM_SNS_Detail__c Where SVMXC__SM_User__c =:userId and SVMXC__SM_TargetArn__c=:targetArn ];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA          
            if(requestIn.eventType=='PULSE' && requestIn.eventName=='LOGGEDIN')
            {
                if(listOfDetails.isEmpty())                
                {
                    SVMXC__SM_SNS_Detail__c newDetails = new SVMXC__SM_SNS_Detail__c();
                    newDetails.SVMXC__SM_User__c = userId;
                    newDetails.SVMXC__SM_TargetArn__c =targetArn;
                    newDetails.SVMXC__SM_IsActive__c = true;
                    newDetails.SVMXC__SM_Status__c='Registered';
                    insert newDetails;       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA           
                }
                else 
                {
                    listOfDetails[0].SVMXC__SM_User__c = userId;
                    listOfDetails[0].SVMXC__SM_TargetArn__c =targetArn;
                    listOfDetails[0].SVMXC__SM_IsActive__c = true;
                    listOfDetails[0].SVMXC__SM_Status__c='Registered';                    
                    update listOfDetails;   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
                newResponse.success=true;

            }
            else if(requestIn.eventType=='PULSE' && requestIn.eventName=='LOGGEDOUT')
            {

                if(listOfDetails.isEmpty())
                {
                    newResponse.success=false;
                    newResponse.message='There is no entry to Delete';
                    INTF_WebServicesDef.SVMXError newError = new INTF_WebServicesDef.SVMXError();
                    newError.errorMsg = 'There is no entry to Delete';
                    newResponse.errors.add(newError);              
                }
                else
                {
                    listOfDetails[0].SVMXC__SM_Status__c = 'UnRegistered'; 
                    listOfDetails[0].SVMXC__SM_IsActive__c = false;                    
                    update listOfDetails[0];              
                    newResponse.success=true;                    
                }
            }
            else if(requestIn.eventType=='PULSE' && requestIn.eventName=='GETPULSECONFIG')
            {
                SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();                
                list<string> lstSubModules = new list<string>{'MOBN001'};
                map<string, Map<String, String>> AllsvmxSettingList = new map<string, Map<String, String>>();            
                system.debug(loggingLevel.WARN, '=====1= Settings Size' + SVMX_Constants.AllsvmxSettingList);
                AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);    
                String region ='US';
                Map<String,String> mapOfSettingValue  = new Map<String,String>();
                if(AllsvmxSettingList !=NULL && AllsvmxSettingList.containsKey('MOBN001'))
                {
                    mapOfSettingValue = AllsvmxSettingList.get('MOBN001');
                }
                if(mapOfSettingValue !=NULL && mapOfSettingValue.containsKey('SET003'))
                {
                    region = mapOfSettingValue.get('SET003');
                }
                
                if(region=='US')
                {
                    INTF_WebServicesDef.SVMXMap newMapUS = new INTF_WebServicesDef.SVMXMap();
                    newMapUS.key='arn';
                    newMapUS.value=System.Label.US_SNSMicroServicePlatformARN ;
                    newResponse.valueMap.add(newMapUS); 
                    newMapUS = new INTF_WebServicesDef.SVMXMap();
                    newMapUS.key='IdentityPool';
                    newMapUS.value=System.Label.US_SNSMicroserviceCognitoPoolId ;
                    newResponse.valueMap.add(newMapUS);                    
                }
                else
                {
                    INTF_WebServicesDef.SVMXMap newMapEU = new INTF_WebServicesDef.SVMXMap();
                    newMapEU.key='arn';
                    newMapEU.value=System.Label.EU_SNSMicroServicePlatformARN;
                    newResponse.valueMap.add(newMapEU);                      
                    newMapEU = new INTF_WebServicesDef.SVMXMap();
                    newMapEU.key='IdentityPool';
                    newMapEU.value=System.Label.EU_SNSMicroserviceCognitoPoolId ;
                    newResponse.valueMap.add(newMapEU);                    
                }
                String platform = 'Salesforce';
                if(mapOfSettingValue!=NULL && mapOfSettingValue.containsKey('SET002'))
                {
                    platform = mapOfSettingValue.get('SET002');
                }
                newResponse.success=true;                            
                INTF_WebServicesDef.SVMXMap newMap = new INTF_WebServicesDef.SVMXMap();
                newMap.key='PushNotification';
                newMap.value=platform;
                newResponse.valueMap.add(newMap);               
            }
            System.debug(LoggingLevel.WARN,'Response  ='+newResponse);
            return newResponse;
        }
        catch(Exception exceptionalHandling)
        {
            newResponse.success=false;
            newResponse.message=exceptionalHandling.getMessage();
            INTF_WebServicesDef.SVMXError newError = new INTF_WebServicesDef.SVMXError();
            newError.errorMsg = exceptionalHandling.getMessage();
            newResponse.errors.add(newError);
            return newResponse;
        }
    }  
    
}