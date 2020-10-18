/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has implementation of all defined FCO Configuration APIs. These methods are 
 * invoked by both REST services and JSR calls.
 *
 * @author Nidhi Hegde
 * @version 20.2
 * @since 2020
 */

public with sharing class CORD_ConfigurationImpl {
    public CORD_WrapperDef.FCO_Response getFCOConfigurationList() {
        
        System.debug( LoggingLevel.INFO, 'getFieldChangeOrdersList() - enter' );
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        
        try {
            List<CORD_WrapperDef.FCOConfigurationInfo > objFCOConfigInfoList = new List<CORD_WrapperDef.FCOConfigurationInfo >();

            for(SVMXC__SM_Change_Order_Configuration__c objFCO : [SELECT Id, Name, SVMXC__SM_Name__c, SVMXC__SM_Active__c,SVMXC__SM_Description__c,lastmodifieddate FROM SVMXC__SM_Change_Order_Configuration__c]){//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                CORD_WrapperDef.FCOConfigurationInfo objFCOConfigInfo = new CORD_WrapperDef.FCOConfigurationInfo();
                objFCOConfigInfo.fcoConfigId = objFCO.Id;
                objFCOConfigInfo.fcoConfigname= objFCO.SVMXC__SM_Name__c;
                objFCOConfigInfo.fcoConfigdescription= objFCO.SVMXC__SM_Description__c;
                objFCOConfigInfo.fcoConfigstatus = objFCO.SVMXC__SM_Active__c;
                objFCOConfigInfo.lastModifiedDate= objFCO.lastmodifieddate.Date();
                objFCOConfigInfoList.add(objFCOConfigInfo);
            }
            response.data = objFCOConfigInfoList;
        }
            
        catch(Exception e ){
            response.success = false;
            response.message = e.getMessage();
            System.debug( LoggingLevel.ERROR, 'getFCOConfigurationList() : Failed to retrieve FCO records list; Error=' + e.getStackTraceString() );
        }
        system.debug('response=='+response);
        return response;
    }
    
    public CORD_WrapperDef.FCO_Response deleteFCOConfiguration(CORD_WrapperDef.FCO_Request request) {
        
        System.debug( LoggingLevel.INFO, 'deleteFCOConfiguration() - enter=='+ request);
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        
        
        try {
            Boolean FCOConfigToDelete = false;
            List<SVMXC__SM_Change_Order__c> listChangeOrders = new List<SVMXC__SM_Change_Order__c>();
            SVMXC__SM_Change_Order_Configuration__c FCOConfigToBeDeleted = new SVMXC__SM_Change_Order_Configuration__c();
            for(SVMXC__SM_Change_Order_Configuration__c FCOConfig : [SELECT Id,(Select Id From SVMXC__Change_Orders__r Where SVMXC__SM_Status__c!='Completed' And SVMXC__SM_Status__c!='Canceled') FROM SVMXC__SM_Change_Order_Configuration__c where id=:request.fcoConfigId]){//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                FCOConfigToBeDeleted = FCOConfig;
                if(FCOConfig.SVMXC__Change_Orders__r.size()>0){
                    listChangeOrders.addAll(FCOConfig.SVMXC__Change_Orders__r);
                } 
            }
            if(FCOConfigToBeDeleted.Id!=null && listChangeOrders.size()==0){
                delete FCOConfigToBeDeleted;
                response.message = system.label.FCO002_TAG001; 
                response.success =true;
            }else if(FCOConfigToBeDeleted.Id==null){
                response.success = false;
                response.message = system.label.FCO001_TAG003;
            }else if(listChangeOrders.size()>0){
                response.success = false;
                response.message = system.label.FCO002_TAG033;
            }
      
        }
        
        catch(Exception e ){
            response.success = false;
            response.message = e.getMessage();
            System.debug( LoggingLevel.ERROR, 'deleteFCOConfiguration() : Failed to retrieve FCO records list; Error=' + e.getStackTraceString() );
        }
        return response;
    }
    
    public CORD_WrapperDef.FCO_Response cloneFCOConfiguration(CORD_WrapperDef.FCO_Request request) {
        
        System.debug( LoggingLevel.INFO, 'cloneFCOConfiguration() - enter=='+ request);
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        
        try {
            List<SVMXC__SM_Change_Order_Configuration__c> FCOConfigToBeCloned = [SELECT Id,Name,SVMXC__SM_Active__c,SVMXC__SM_Description__c,SVMXC__SM_Email__c,SVMXC__SM_Name__c, SVMXC__SM_Process1__c, SVMXC__SM_Process2__c,SVMXC__SM_Process1__r.Name, SVMXC__SM_Process2__r.Name  FROM SVMXC__SM_Change_Order_Configuration__c where id=:request.fcoConfigId];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(FCOConfigToBeCloned.size()>0){
                SVMXC__SM_Change_Order_Configuration__c objFCO = FCOConfigToBeCloned[0];
                CORD_WrapperDef.FCOConfigurationInfo objFCOConfigInfo = new CORD_WrapperDef.FCOConfigurationInfo();
                objFCOConfigInfo.fcoConfigname= system.label.FCO001_TAG006 + ' '+ objFCO.SVMXC__SM_Name__c;
                objFCOConfigInfo.fcoConfigdescription= objFCO.SVMXC__SM_Description__c;
                objFCOConfigInfo.fcoConfigstatus= objFCO.SVMXC__SM_Active__c;  
                objFCOConfigInfo.process1_Id = objFCO.SVMXC__SM_Process1__c;
                objFCOConfigInfo.process2_Id = objFCO.SVMXC__SM_Process2__c;
                objFCOConfigInfo.email = objFCO.SVMXC__SM_Email__c;

                response.data = objFCOConfigInfo;
                response.success =true;
            }else{
                response.success = false;
                response.message = system.label.FCO001_TAG003;
            }           
      
        }
        
        catch(Exception e ){
            response.success = false;
            response.message = e.getMessage();
            System.debug( LoggingLevel.ERROR, 'cloneFCOConfiguration() : Failed to retrieve FCO records list; Error=' + e.getStackTraceString() );
        }
        return response;
    }
    
    public CORD_WrapperDef.FCO_Response getConfigData(CORD_WrapperDef.FCO_Request request) {       
        System.debug( LoggingLevel.INFO, 'getConfigData() - enter=='+ request);       
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            List<SVMXC__SM_Change_Order_Configuration__c> configData = [SELECT Id,Name,SVMXC__SM_Active__c,SVMXC__SM_Description__c,SVMXC__SM_Email__c,SVMXC__SM_Name__c, SVMXC__SM_Process1__c, SVMXC__SM_Process2__c,SVMXC__SM_Process1__r.SVMXC__Name__c, SVMXC__SM_Process2__r.SVMXC__Name__c ,(Select Id,SVMXC__Access_Configuration_Profile__c,SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c, SVMXC__Access_Configuration_Profile__r.SVMXC__Description__c, SVMXC__SM_CORD_Config__c From SVMXC__ServiceMax_Config_Data__r) FROM SVMXC__SM_Change_Order_Configuration__c where id=:request.fcoConfigId];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(configData.size()>0){
                SVMXC__SM_Change_Order_Configuration__c objFCO = configData[0];
                CORD_WrapperDef.FCOConfigurationInfo objFCOConfigInfo = new CORD_WrapperDef.FCOConfigurationInfo();
                objFCOConfigInfo.fcoConfigId = objFCO.Id;
                objFCOConfigInfo.fcoConfigname= objFCO.SVMXC__SM_Name__c;
                objFCOConfigInfo.fcoConfigdescription= objFCO.SVMXC__SM_Description__c;
                objFCOConfigInfo.fcoConfigstatus= objFCO.SVMXC__SM_Active__c;              
                objFCOConfigInfo.process1_Id = objFCO.SVMXC__SM_Process1__c;
                objFCOConfigInfo.process2_Id = objFCO.SVMXC__SM_Process2__c;
                objFCOConfigInfo.email = objFCO.SVMXC__SM_Email__c;
                for(SVMXC__ServiceMax_Config_Data__c svmxConfigData : objFCO.SVMXC__ServiceMax_Config_Data__r){
                    CORD_WrapperDef.AssignmentData assignmentData = new CORD_WrapperDef.AssignmentData();
                    assignmentData.assignmentId = svmxConfigData.Id;
                    assignmentData.profileId = svmxConfigData.SVMXC__Access_Configuration_Profile__c;
                    assignmentData.fcoConfigId = svmxConfigData.SVMXC__SM_CORD_Config__c;
                    assignmentData.profileName = svmxConfigData.SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c;
                    assignmentData.description = svmxConfigData.SVMXC__Access_Configuration_Profile__r.SVMXC__Description__c;
              
                    objFCOConfigInfo.assignmentData.add(assignmentData);
                }
                response.data = objFCOConfigInfo;
                response.success =true;
            }else{
                response.success = false;
                response.message = system.label.FCO001_TAG003;
            }
      
        }
        
        catch(Exception e ){
            response.success = false;
            response.message = e.getMessage();
            System.debug( LoggingLevel.ERROR, 'getConfigData() : Failed to retrieve Configuration record; Error=' + e.getStackTraceString() );
        }
        return response;
    }
    
    public CORD_WrapperDef.FCO_Response saveConfigData(CORD_WrapperDef.FCO_Request request) {
        System.debug( LoggingLevel.INFO, 'saveConfigData() - enter=='+ request);       
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            SVMXC__SM_Change_Order_Configuration__c fcoConfig = new SVMXC__SM_Change_Order_Configuration__c();
            List<SVMXC__SM_Change_Order__c> listChangeOrders = new List<SVMXC__SM_Change_Order__c>();
            CORD_WrapperDef.FCOConfigurationInfo objFCOConfigInfo  = request.configurationInfo;
            if(String.isNotBlank(objFCOConfigInfo.fcoConfigId)){
                for(SVMXC__SM_Change_Order_Configuration__c existingFCOConfig : [SELECT Id,(Select Id From SVMXC__Change_Orders__r Where SVMXC__SM_Status__c!='Completed' And SVMXC__SM_Status__c!='Canceled') FROM SVMXC__SM_Change_Order_Configuration__c where id=:objFCOConfigInfo.fcoConfigId]){//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(existingFCOConfig.SVMXC__Change_Orders__r.size()>0){
                        listChangeOrders.addAll(existingFCOConfig.SVMXC__Change_Orders__r);
                    } 
                }
            }
            if(objFCOConfigInfo.fcoConfigstatus == false && listChangeOrders.size()>0){
                response.success = false;
                response.message = system.label.FCO002_TAG033;
            }else{
                if(String.isNotBlank(objFCOConfigInfo.fcoConfigId)){
                    fcoConfig.Id= objFCOConfigInfo.fcoConfigId;
                }
                fcoConfig.SVMXC__SM_Name__c = objFCOConfigInfo.fcoConfigname;
                fcoConfig.SVMXC__SM_Description__c = objFCOConfigInfo.fcoConfigdescription;
                fcoConfig.SVMXC__SM_Active__c = objFCOConfigInfo.fcoConfigstatus;            
                if(String.isNotBlank(objFCOConfigInfo.process1_Id)){
                    fcoConfig.SVMXC__SM_Process1__c = objFCOConfigInfo.process1_Id;
                }
                if(String.isNotBlank(objFCOConfigInfo.process2_Id)){
                    fcoConfig.SVMXC__SM_Process2__c = objFCOConfigInfo.process2_Id;
                }
                fcoConfig.SVMXC__SM_Email__c = objFCOConfigInfo.email;
                
                upsert fcoConfig;
                objFCOConfigInfo.fcoConfigId = fcoConfig.Id;//Send back newly created config record Id
                
                //Save Assignment Info
                if(objFCOConfigInfo.profileIdList != null && objFCOConfigInfo.profileIdList.size()>0){
                    system.debug('objFCOConfigInfo.profileIdList=='+objFCOConfigInfo.profileIdList);
                    Id recdTypeId = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND developerName = 'Change_Order_Access'].Id;
                    List<SVMXC__ServiceMax_Config_Data__c> listConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
                    for(String data : objFCOConfigInfo.profileIdList){
                        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
                        configData.RecordTypeId = recdTypeId;
                        configData.SVMXC__SM_CORD_Config__c = fcoConfig.Id;
                        configData.SVMXC__Access_Configuration_Profile__c = data;
                        listConfigData.add(configData);
                    }
                    
                    insert listConfigData;
                    if(objFCOConfigInfo.assignmentData != null){
                        objFCOConfigInfo.assignmentData.clear();
                    }else{
                        objFCOConfigInfo.assignmentData = new List<CORD_WrapperDef.AssignmentData>();
                    }
                    for(SVMXC__ServiceMax_Config_Data__c svmxConfigData : [Select Id,SVMXC__Access_Configuration_Profile__c,SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c, SVMXC__Access_Configuration_Profile__r.SVMXC__Description__c, SVMXC__SM_CORD_Config__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__SM_CORD_Config__c = :fcoConfig.Id]){
                        system.debug('svmxConfigData=='+svmxConfigData);
                        CORD_WrapperDef.AssignmentData assignmentData = new CORD_WrapperDef.AssignmentData();
                        assignmentData.assignmentId = svmxConfigData.Id;
                        assignmentData.profileId = svmxConfigData.SVMXC__Access_Configuration_Profile__c;
                        assignmentData.fcoConfigId = svmxConfigData.SVMXC__SM_CORD_Config__c;
                        assignmentData.profileName = svmxConfigData.SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c;
                        assignmentData.description = svmxConfigData.SVMXC__Access_Configuration_Profile__r.SVMXC__Description__c;
                  
                        objFCOConfigInfo.assignmentData.add(assignmentData);
                    }
                 }
                
                //Delete Assignment Records
                if(objFCOConfigInfo.assignmentToBeDeleted != null && objFCOConfigInfo.assignmentToBeDeleted.size()>0){
                    system.debug('objFCOConfigInfo.assignmentToBeDeleted=='+objFCOConfigInfo.assignmentToBeDeleted);
                    List<SVMXC__ServiceMax_Config_Data__c> recordsToBeDeleted = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c where id IN : objFCOConfigInfo.assignmentToBeDeleted];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(recordsToBeDeleted.size()>0){
                        delete recordsToBeDeleted;
                        //response.message = system.label.FCO002_TAG001; 
                        response.success =true;
    
                        objFCOConfigInfo.assignmentData.clear();
                    for(SVMXC__ServiceMax_Config_Data__c svmxConfigData : [Select Id,SVMXC__Access_Configuration_Profile__c,SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c, SVMXC__Access_Configuration_Profile__r.SVMXC__Description__c, SVMXC__SM_CORD_Config__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__SM_CORD_Config__c = :fcoConfig.Id]){
                        CORD_WrapperDef.AssignmentData assignmentData = new CORD_WrapperDef.AssignmentData();
                        assignmentData.assignmentId = svmxConfigData.Id;
                        assignmentData.profileId = svmxConfigData.SVMXC__Access_Configuration_Profile__c;
                        assignmentData.fcoConfigId = svmxConfigData.SVMXC__SM_CORD_Config__c;
                        assignmentData.profileName = svmxConfigData.SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c;
                        assignmentData.description = svmxConfigData.SVMXC__Access_Configuration_Profile__r.SVMXC__Description__c;
                  
                        objFCOConfigInfo.assignmentData.add(assignmentData);
                    }
                    }else{
                        response.success = false;
                        response.message += ', ' + system.label.FCO001_TAG003;
                    }
                 }
    
                response.data = objFCOConfigInfo;
                response.success =true;
            }
        }
        
        catch(Exception e ){
            response.success = false;
            response.message = e.getMessage();
            System.debug( LoggingLevel.ERROR, 'saveConfigData() : Failed to save Configuration record; Error=' + e.getStackTraceString() );
        }
        return response;
    }
    public CORD_WrapperDef.FCO_Response getProcessData() {
        System.debug( LoggingLevel.INFO, 'getProcessData() - enter==');       
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        CORD_WrapperDef.ProcessData processData = new CORD_WrapperDef.ProcessData();
        List<CORD_WrapperDef.keyValuePair> process1DataList = new List<CORD_WrapperDef.keyValuePair>();
        List<CORD_WrapperDef.keyValuePair> process2DataList = new List<CORD_WrapperDef.keyValuePair>();
        try {           
            for(SVMXC__ServiceMax_Processes__c sfmProcess : [Select Id,SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c = 'Object Mapping' AND SVMXC__Source_Object_Name__c='SVMXC__Installed_Product__c' AND SVMXC__Target_Object_Name__c='SVMXC__Service_Order__c']){//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                CORD_WrapperDef.keyValuePair process1Data = new CORD_WrapperDef.keyValuePair(sfmProcess.Id,sfmProcess.SVMXC__Name__c);
                process1DataList.add(process1Data);
            }
            processData.process1Data = process1DataList;

            for(SVMXC__ServiceMax_Processes__c sfmProcess : [Select Id,SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c = 'Object Mapping' AND SVMXC__Source_Object_Name__c='SVMXC__SM_Change_Order__c' AND SVMXC__Target_Object_Name__c='SVMXC__Service_Order__c']){//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                CORD_WrapperDef.keyValuePair process2Data = new CORD_WrapperDef.keyValuePair(sfmProcess.Id,sfmProcess.SVMXC__Name__c);
                process2DataList.add(process2Data);
            }
            processData.process2Data = process2DataList;

            response.data = processData;
            response.success = true;
        }
        
        catch(Exception e ){
            response.success = false;
            response.message = e.getMessage();
            System.debug( LoggingLevel.ERROR, 'getProcessData() : Failed to retrieve SFM Mappings; Error=' + e.getStackTraceString() );
        }
        return response;
    }

    public CORD_WrapperDef.FCO_Response getProfileData() {
        System.debug( LoggingLevel.INFO, 'getProfileData() - enter==');       
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        List<CORD_WrapperDef.SearchedProduct> profileDataList = new List<CORD_WrapperDef.SearchedProduct>();
        try {       
            for(SVMXC__ServiceMax_Config_Data__c sfmConfigData : [Select Id,SVMXC__Description__c,SVMXC__Profile_Name__c,(Select id From SVMXC__SVMX_Config_Data2__r where SVMXC__RecordType_Name__c = 'Configuration Access') From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Profile' And SVMXC__Configuration_Type__c='Group' And SVMXC__Active__c = true]){//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(sfmConfigData.SVMXC__SVMX_Config_Data2__r.size()>0){// BAC-5920 This is to check if Config Profile has SFDC Profiles.
                    CORD_WrapperDef.SearchedProduct profileData = new CORD_WrapperDef.SearchedProduct();
                    profileData.value = sfmConfigData.Id;
                    profileData.label = sfmConfigData.SVMXC__Profile_Name__c;
                    profileData.meta = sfmConfigData.SVMXC__Description__c;
                    profileData.icon = '';
                    profileDataList.add(profileData);
                }
            }
            response.data = profileDataList;
            response.success = true;
        }
        
        catch(Exception e ){
            response.success = false;
            response.message = e.getMessage();
            System.debug( LoggingLevel.ERROR, 'getProfileData() : Failed to retrieve Profiles; Error=' + e.getStackTraceString() );
        }
        return response;
    
    }

    public CORD_WrapperDef.FCO_Response getCustomLabels() {
        System.debug( LoggingLevel.INFO, 'getCustomLabels() - enter==');   
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        List<CORD_WrapperDef.KeyValuePair> listCustomLabels = new List<CORD_WrapperDef.KeyValuePair>();
                
        //custom labels
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG001',system.label.FCO002_TAG001));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG002',system.label.FCO002_TAG002));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG003',system.label.FCO002_TAG003));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG004',system.label.FCO002_TAG004));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG005',system.label.FCO002_TAG005));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG006',system.label.FCO002_TAG006));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG007',system.label.FCO002_TAG007));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG008',system.label.FCO002_TAG008));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG009',system.label.FCO002_TAG009));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG010',system.label.FCO002_TAG010));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG011',system.label.FCO002_TAG011));
        
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG012',system.label.FCO002_TAG012));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG013',system.label.FCO002_TAG013));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG014',system.label.FCO002_TAG014));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG015',system.label.FCO002_TAG015));
        
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG016',system.label.FCO002_TAG016));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG017',system.label.FCO002_TAG017));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG018',system.label.FCO002_TAG018));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG019',system.label.FCO002_TAG019));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG020',system.label.FCO002_TAG020));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG021',system.label.FCO002_TAG021));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG022',system.label.FCO002_TAG022));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG023',system.label.FCO002_TAG023)); 
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG024',system.label.FCO002_TAG024));  
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG025',system.label.FCO002_TAG025)); 
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG026',system.label.FCO002_TAG026)); 
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG027',system.label.FCO002_TAG027));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG028',system.label.FCO002_TAG028)); 
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG029',system.label.FCO002_TAG029));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG030',system.label.FCO002_TAG030));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG031',system.label.FCO002_TAG031)); 
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG032',system.label.FCO002_TAG032));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG034',system.label.FCO002_TAG034));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG035',system.label.FCO002_TAG035)); 
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG036',system.label.FCO002_TAG036));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG037',system.label.FCO002_TAG037)); 
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG038',system.label.FCO002_TAG038));
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG039',system.label.FCO002_TAG039)); 
        listCustomLabels.add(new CORD_WrapperDef.KeyValuePair('FCO002_TAG040',system.label.FCO002_TAG040));                                                                                                  
                                                
        

        response.data = listCustomLabels;
        response.success = true;
        
        return response;
    }
    
}