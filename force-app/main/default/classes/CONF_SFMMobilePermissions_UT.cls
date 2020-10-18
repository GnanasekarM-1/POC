@isTest 
private with sharing class CONF_SFMMobilePermissions_UT {

    static testMethod void testOnPageLoad(){
        CONF_SFMMobilePermissions.onPageLoad();
    }
    
    static testMethod void testOnChangeProfile(){
        CONF_SFMMobilePermissions.Request request = new CONF_SFMMobilePermissions.Request();
    
        request.processType = 'VIEW RECORD';
        String RTConfig = '', RTServiceFlow = '', RTProcessNode = '';
        RecordType Rtype, Rtype1, Rtype2;
         
        RTConfig = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Configuration Profile' Limit 1].id;
        RTServiceFlow = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Service Flow Access' Limit 1].id;
        RTProcessNode = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'Process Node Objects' Limit 1].Id;
        
        //--------------------------------------------- Creating Data for Config Data and Processes -------------------------------------------------------------
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Profile_Name__c = 'ConfigData001';
        configData.SVMXC__Description__c = 'ConfigData001';
        configData.RecordTypeId = RTConfig;
        configData.SVMXC__Configuration_Type__c = 'Group';
        insert configData;
        system.assert(configData.SVMXC__Profile_Name__c !=null);
        system.assert(configData.SVMXC__Description__c!=null);
        
        SVMXC__ServiceMax_Processes__c viewProcess = new SVMXC__ServiceMax_Processes__c();
        viewProcess.SVMXC__Purpose__c = 'VIEW RECORD';
        viewProcess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        viewProcess.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        viewProcess.SVMXC__Name__c = 'Process001';
        viewProcess.SVMXC__MapID__c = 'MAPPROCESS001';
        insert viewProcess;
        system.assert(viewProcess.SVMXC__Purpose__c !=null);
        system.assert(viewProcess.SVMXC__Source_Object_Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c createProcess = new SVMXC__ServiceMax_Processes__c();
        createProcess.SVMXC__Purpose__c = 'STANDALONE CREATE';
        viewProcess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        createProcess.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        createProcess.SVMXC__Name__c = 'Process002';
        createProcess.SVMXC__MapID__c = 'MAPPROCESS001';
        insert createProcess;
        system.assert(createProcess.SVMXC__Purpose__c !=null);
        system.assert(createProcess.SVMXC__Source_Object_Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c tempProcess = new SVMXC__ServiceMax_Processes__c();
        tempProcess.RecordTypeId = RTProcessNode;
        tempProcess.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        tempProcess.SVMXC__Type__c = 'TARGET';
        tempProcess.SVMXC__Process__c = viewProcess.Id;
        insert tempProcess;
        system.assert(tempProcess.SVMXC__Type__c !=null);
        
        SVMXC__ServiceMax_Processes__c tempProcess1 = new SVMXC__ServiceMax_Processes__c();
        tempProcess1.RecordTypeId = RTProcessNode;
        tempProcess1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        tempProcess1.SVMXC__Type__c = 'TARGET';
        tempProcess.SVMXC__Process__c = createProcess.Id;
        insert tempProcess1;
        system.assert(tempProcess1.SVMXC__Type__c !=null);

        request.svmxProfile = configData.Id;
        CONF_SFMMobilePermissions.onChangeProfile(JSON.serialize(request));
    }
    
    static testMethod void testOnChangeProcessType(){
        CONF_SFMMobilePermissions.Request request = new CONF_SFMMobilePermissions.Request();
    
        request.processType = 'STANDALONE CREATE';
        for(SVMXC__ServiceMax_Config_Data__c eachProfile : [Select Id, SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c = 'Configuration Profile' and SVMXC__Configuration_Type__c = 'Group' Order By SVMXC__Profile_Name__c limit 1])
            request.svmxProfile = eachProfile.Id;
        CONF_SFMMobilePermissions.onChangeProcessType(JSON.serialize(request));
    }
    
    static testMethod void testOnChangeObject(){
        CONF_SFMMobilePermissions.Request request = new CONF_SFMMobilePermissions.Request();
    
        request.processType = 'VIEW RECORD';
        request.objectName = 'Account';
        for(SVMXC__ServiceMax_Config_Data__c eachProfile : [Select Id, SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c = 'Configuration Profile' and SVMXC__Configuration_Type__c = 'Group' Order By SVMXC__Profile_Name__c limit 1])
            request.svmxProfile = eachProfile.Id;
        CONF_SFMMobilePermissions.onChangeObject(JSON.serialize(request));
    }
    
    static testMethod void testOnSearchOrSort(){
        CONF_SFMMobilePermissions.Request request = new CONF_SFMMobilePermissions.Request();
    
        request.processType = 'STANDALONE CREATE';
        for(SVMXC__ServiceMax_Config_Data__c eachProfile : [Select Id, SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c = 'Configuration Profile' and SVMXC__Configuration_Type__c = 'Group' Order By SVMXC__Profile_Name__c limit 1])
            request.svmxProfile = eachProfile.Id;
        CONF_SFMMobilePermissions.onSearchOrSort(JSON.serialize(request));
    }
    
    static testMethod void testSave(){
        CONF_SFMMobilePermissions.Request request = new CONF_SFMMobilePermissions.Request();
        
        string RTTargetManager = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'Target Manager' Limit 1].Id;
        
        //create standard Create processes
        SVMXC__ServiceMax_Processes__c stdCreateProcess = new SVMXC__ServiceMax_Processes__c();
        stdCreateProcess.SVMXC__Purpose__c = 'STANDALONE CREATE';
        stdCreateProcess.SVMXC__ProcessID__c = 'SVMXEVT_003';
        stdCreateProcess.SVMXC__isPrivate__c = true;
        stdCreateProcess.SVMXC__isStandard__c = true;
        stdCreateProcess.RecordTypeId = RTTargetManager;
        insert stdCreateProcess;
        system.assert(stdCreateProcess.SVMXC__Purpose__c !=null);
        
        //create standard Create processes
        SVMXC__ServiceMax_Processes__c stdCreateProcess1 = new SVMXC__ServiceMax_Processes__c();
        stdCreateProcess1.SVMXC__Purpose__c = 'STANDALONE CREATE';
        stdCreateProcess1.SVMXC__ProcessID__c = 'EVT_003';
        stdCreateProcess1.SVMXC__isPrivate__c = true;
        stdCreateProcess1.SVMXC__isStandard__c = true;
        stdCreateProcess1.RecordTypeId = RTTargetManager;
        stdCreateProcess1.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        insert stdCreateProcess1;
        system.assert(stdCreateProcess1.SVMXC__Purpose__c !=null);
        
        //create standard View processes
        SVMXC__ServiceMax_Processes__c stdViewProcess = new SVMXC__ServiceMax_Processes__c();
        stdViewProcess.SVMXC__Purpose__c = 'VIEW RECORD';
        stdViewProcess.SVMXC__ProcessID__c = 'EVT_005';
        stdViewProcess.SVMXC__isPrivate__c = true;
        stdViewProcess.SVMXC__isStandard__c = true;
        stdViewProcess.RecordTypeId = RTTargetManager;
        stdViewProcess.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        insert stdViewProcess;
        system.assert(stdViewProcess.SVMXC__Purpose__c !=null);
        
        //create standard View processes
        SVMXC__ServiceMax_Processes__c stdViewProcess1 = new SVMXC__ServiceMax_Processes__c();
        stdViewProcess1.SVMXC__Purpose__c = 'VIEW RECORD';
        stdViewProcess1.SVMXC__ProcessID__c = 'SVMXEVT_005';
        stdViewProcess1.SVMXC__isPrivate__c = true;
        stdViewProcess1.SVMXC__isStandard__c = true;
        stdViewProcess1.RecordTypeId = RTTargetManager;
        stdViewProcess1.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        insert stdViewProcess1;
        system.assert(stdViewProcess1.SVMXC__Purpose__c !=null);
        
        SVMXC__ServiceMax_Processes__c viewProcess = new SVMXC__ServiceMax_Processes__c();
        viewProcess.SVMXC__Purpose__c = 'VIEW RECORD';
        viewProcess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        viewProcess.SVMXC__Name__c = 'Process001';
        viewProcess.SVMXC__MapID__c = 'MAPPROCESS001';
        viewProcess.SVMXC__ProcessID__c = 'Process001';
        viewProcess.RecordTypeId = RTTargetManager;
        
        insert viewProcess;
        system.assert(viewProcess.SVMXC__Purpose__c !=null);
        
        request.processDetails = new List<CONF_SFMMobilePermissions.ProcessDetails>();
        
        CONF_SFMMobilePermissions.ProcessDetails insertProcessDetails = new CONF_SFMMobilePermissions.ProcessDetails();
        insertProcessDetails.processDetails = new List<CONF_SFMMobilePermissions.ProcessDetails>();
         
        insertProcessDetails.name = 'INSERT';
        insertProcessDetails.processDetails.add(new CONF_SFMMobilePermissions.ProcessDetails(viewProcess.Id,'','','',''));
        insertProcessDetails.processDetails.add(new CONF_SFMMobilePermissions.ProcessDetails(stdViewProcess1.Id,'','','',''));
        insertProcessDetails.processDetails.add(new CONF_SFMMobilePermissions.ProcessDetails(stdCreateProcess1.Id,'','','',''));
        
        request.processDetails.add(insertProcessDetails);
        for(SVMXC__ServiceMax_Config_Data__c eachProfile : [Select Id, SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c = 'Configuration Profile' and SVMXC__Configuration_Type__c = 'Group' Order By SVMXC__Profile_Name__c limit 1])
            request.svmxProfile = eachProfile.Id;
        try{
            CONF_SFMMobilePermissions.save(JSON.serialize(request));
        }
        catch(Exception e)
        {}
    }
    
    static testMethod void testaddAllChecklist(){
        CONF_SFMMobilePermissions.Request request = new CONF_SFMMobilePermissions.Request();
        request.processDetails = new List<CONF_SFMMobilePermissions.ProcessDetails>();
        for(SVMXC__ServiceMax_Config_Data__c eachProfile : [Select Id, SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c = 'Configuration Profile' and SVMXC__Configuration_Type__c = 'Group' Order By SVMXC__Profile_Name__c limit 1])
            request.svmxProfile = eachProfile.Id;
        try{
            CONF_SFMMobilePermissions.addAllChecklist(JSON.serialize(request));
        }
        catch(Exception e)
        {}
    }
}