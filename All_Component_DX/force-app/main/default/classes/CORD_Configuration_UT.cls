@isTest//(SeeAllData=true)
public class CORD_Configuration_UT {
    static testMethod void CORD_Configuration_test1(){
        CORD_Configuration.JSRGetFCOConfigurationList('');
        SVMXC__SM_Change_Order_Configuration__c fcoConfig = new SVMXC__SM_Change_Order_Configuration__c();
        fcoConfig.SVMXC__SM_Active__c = true;
        fcoConfig.SVMXC__SM_Description__c = 'Test';
        fcoConfig.SVMXC__SM_Email__c = 'test@example.com';
        fcoConfig.SVMXC__SM_Name__c = 'Test';
        
        insert fcoConfig;
        
        Id recdType1Id = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND DeveloperName = 'Configuration_Profile'].Id;
        Id recdType2Id = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND DeveloperName = 'Configuration_Access'].Id;
        List<SVMXC__ServiceMax_Config_Data__c> listConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=recdType1Id,SVMXC__Configuration_Type__c='Group', SVMXC__Active__c = true);
        listConfigData.add(configData1);
        
        SVMXC__ServiceMax_Config_Data__c configData2 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__SM_CORD_Config__c=fcoConfig.id);
        listConfigData.add(configData2);
        
        SVMXC__ServiceMax_Config_Data__c configData3 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=recdType1Id,SVMXC__Configuration_Type__c='Group', SVMXC__Active__c = true);
        listConfigData.add(configData3);
		
        insert listConfigData;
        
        SVMXC__ServiceMax_Config_Data__c sfdcProfile = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Access_Configuration_Profile__c = configData3.Id,RecordTypeId=recdType2Id);
        insert sfdcProfile;
        
        CORD_Configuration.JSRGetProfileData('');
        CORD_WrapperDef.FCO_Request request =  new CORD_WrapperDef.FCO_Request();
        request.fcoConfigId = fcoConfig.id;
        String fcoRequest = JSON.Serialize(request);
        
        CORD_Configuration.JSRGetFCOConfigurationList('');
        CORD_Configuration.JSRCloneFCOConfig(fcoRequest);
        CORD_Configuration.JSRCloneFCOConfig('12323');
        
        CORD_Configuration.JSRGetConfigData(fcoRequest);
        CORD_Configuration.JSRGetConfigData('12323');
        
        RecordType objectMappingRT = [select Id from RecordType where Name= 'Object Mapping'and SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        List<SVMXC__ServiceMax_Processes__c> processList = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__c='ProcessObjectMapping', SVMXC__Source_Object_Name__c='SVMXC__Installed_Product__c', SVMXC__Target_Object_Name__c='SVMXC__Service_Order__c',SVMXC__MapID__c='MAP001002A',RecordTypeId = objectMappingRT.Id, SVMXC__Active__c = true, SVMXC__Mode_Of_Execution__c = 'Interactive', SVMXC__SM_Include_Object_Data_Set__c =  true);
       	processList.add(process1); 
        
        SVMXC__ServiceMax_Processes__c process2 = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__c='ProcessObjectMapping', SVMXC__Source_Object_Name__c='SVMXC__SM_Change_Order__c', SVMXC__Target_Object_Name__c='SVMXC__Service_Order__c',SVMXC__MapID__c='MAP001002A',RecordTypeId = objectMappingRT.Id, SVMXC__Active__c = true, SVMXC__Mode_Of_Execution__c = 'Interactive', SVMXC__SM_Include_Object_Data_Set__c =  true);
        processList.add(process2); 
        insert processList;
   
        CORD_Configuration.JSRGetProcessData('');
        CORD_Configuration.JSRGetProfileData('');

        CORD_WrapperDef.FCO_Request request1 =  new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FCOConfigurationInfo saveConfigData = new CORD_WrapperDef.FCOConfigurationInfo();
        saveConfigData.fcoConfigId = fcoConfig.id;
        saveConfigData.fcoConfigStatus = false;
        saveConfigData.profileIdList.add(configData1.Id);
        saveConfigData.assignmentToBeDeleted.add(configData2.id);
        request1.configurationInfo = saveConfigData;
        String fcoRequest1 = JSON.Serialize(request1);
	
        CORD_Configuration.JSRSaveConfigData(fcoRequest1);
        CORD_Configuration.JSRSaveConfigData('');
        
        CORD_Configuration.JSRGetCustomLabels('');      
        CORD_Configuration.JSRDeleteFCOConfig(fcoRequest); 
        CORD_Configuration.JSRDeleteFCOConfig(fcoRequest); 
        CORD_Configuration.JSRGetConfigData(fcoRequest);
        
        saveConfigData.assignmentToBeDeleted.add('123');
        request1.configurationInfo = saveConfigData;
        String fcoRequest2 = JSON.Serialize(request1);
	
        CORD_Configuration.JSRSaveConfigData(fcoRequest2);
        
        saveConfigData.assignmentToBeDeleted.add('123');
        request1.configurationInfo = saveConfigData;
        String fcoRequest3 = JSON.Serialize(request1);
	
        CORD_Configuration.JSRSaveConfigData(fcoRequest3);
    }
}