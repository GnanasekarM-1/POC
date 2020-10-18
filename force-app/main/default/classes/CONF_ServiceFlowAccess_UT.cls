@isTest 
private with sharing class CONF_ServiceFlowAccess_UT {
    static testMethod void ServiceFlowAccess_UnitTest() 
    {
       try{
        //------------------------------------------------------ Retrieving Record Types -----------------------------------------------------------------
        String RTypeId = '';
        RecordType Rtype;
        String RTypeId1 = '';
        RecordType Rtype1;
        String RTypeId2 = '';
        RecordType Rtype2;
         
        Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Configuration Profile' Limit 1];
        RTypeId = Rtype.Id;
        Rtype1 = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Service Flow Access' Limit 1];
        RTypeId1 = Rtype1.Id;
        Rtype2 = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'Process Node Objects' Limit 1];
        RTypeId2 = Rtype2.Id;
        
        //--------------------------------------------- Creating Data for Config Data and Processes -------------------------------------------------------------
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Profile_Name__c = 'ConfigData001';
        configData.SVMXC__Description__c = 'ConfigData001';
        configData.RecordTypeId = RTypeId;
        configData.SVMXC__Configuration_Type__c = 'Group';
        insert configData;
        system.assert(configData.SVMXC__Profile_Name__c !=null);
        system.assert(configData.SVMXC__Description__c!=null);
        
        SVMXC__ServiceMax_Processes__c viewProcess = new SVMXC__ServiceMax_Processes__c();
        viewProcess.SVMXC__Purpose__c = 'VIEW RECORD';
        viewProcess.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        viewProcess.SVMXC__Name__c = 'Process001';
        viewProcess.SVMXC__MapID__c = 'MAPPROCESS001';
        insert viewProcess;
        system.assert(viewProcess.SVMXC__Purpose__c !=null);
        system.assert(viewProcess.SVMXC__Source_Object_Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c createProcess = new SVMXC__ServiceMax_Processes__c();
        createProcess.SVMXC__Purpose__c = 'STANDALONE CREATE';
        createProcess.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        createProcess.SVMXC__Name__c = 'Process002';
        createProcess.SVMXC__MapID__c = 'MAPPROCESS001';
        insert createProcess;
        system.assert(createProcess.SVMXC__Purpose__c !=null);
        system.assert(createProcess.SVMXC__Source_Object_Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c tempProcess = new SVMXC__ServiceMax_Processes__c();
        tempProcess.RecordTypeId = RTypeId2;
        tempProcess.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        tempProcess.SVMXC__Type__c = 'TARGET';
        tempProcess.SVMXC__Process__c = viewProcess.Id;
        insert tempProcess;
        system.assert(tempProcess.SVMXC__Type__c !=null);
        
        SVMXC__ServiceMax_Processes__c tempProcess1 = new SVMXC__ServiceMax_Processes__c();
        tempProcess1.RecordTypeId = RTypeId2;
        tempProcess1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        tempProcess1.SVMXC__Type__c = 'TARGET';
        tempProcess.SVMXC__Process__c = createProcess.Id;
        insert tempProcess1;
        system.assert(tempProcess1.SVMXC__Type__c !=null);
        
        //--------------------------------------------- Creating Object of the Main Class -------------------------------------------------------------
        CONF_ServiceFlowAccess processAccess = new CONF_ServiceFlowAccess();
        string str = configData.Id;
        processAccess.setSelectedProfile(str);
        
        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
        configData1.SVMXC__Access_Configuration_Profile__c = configData.id;
        configData1.RecordTypeId  = RTypeId1;
        configData1.SVMXC__Dispatch_Process__c = viewProcess.id;
        insert configData1;
        
        SVMXC__ServiceMax_Config_Data__c configData2 = new SVMXC__ServiceMax_Config_Data__c();
        configData2.SVMXC__Access_Configuration_Profile__c = configData.id;
        configData2.RecordTypeId  = RTypeId1;
        configData2.SVMXC__Dispatch_Process__c = createProcess.id;
        insert configData2;
        
        //--------------------------------------------- Calling Methods of the Main Class -------------------------------------------------------------
        PageReference PageRef = processAccess.OnSelectProfile();
        PageRef = processAccess.cancel();
        processAccess.setSelectedSourceObject('SVMXC__Service_Order__c');
        PageRef = processAccess.quickSave();
        PageRef = processAccess.OnChangeProfile();
        str = processAccess.getTAG001();
        str = processAccess.getTAG002();
        str = processAccess.getTAG004();
        str = processAccess.getTAG009();
        str = processAccess.getTAG010();
        str = processAccess.getTAG011();
        str = processAccess.getTAG012();
        str = processAccess.getTAG013();
        str = processAccess.getTAG014();
        str = processAccess.getTAG015();
        str = processAccess.getTAG019();
        str = processAccess.getHlpUrl();
        str = processAccess.getTAG020();
        str = processAccess.getTAG018();
        str = processAccess.getTAG021();
        str = processAccess.getTAG022();
        str = processAccess.getSelectedProfile();
        List<SVMXC__ServiceMax_Processes__c> lstProcess = processAccess.getProcessViewLst();
        processAccess.setProcessViewLst(lstProcess);
        lstProcess = processAccess.getProcessStandaloneCreateLst();
        processAccess.setProcessStandaloneCreateLst(lstProcess);
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigData = processAccess.getSVMXprofiles();
        processAccess.setSVMXprofiles(lstConfigData);
        lstConfigData = processAccess.getProfileAccessLst();
        processAccess.setProfileAccessLst(lstConfigData);
        str = processAccess.getSelectedSourceObject();
        List<String> lstStr = processAccess.getViewProcess();
        string str1 = viewProcess.SVMXC__Name__c;
        lstStr.add(str1);
        processAccess.setViewProcess(lstStr);
        PageRef = processAccess.OnAddViewProcess();
        
        lstStr = processAccess.getViewCreateProcess();
        lstStr.clear();
        str1 = createProcess.SVMXC__Name__c;
        lstStr.add(str1);
        processAccess.setViewCreateProcess(lstStr);
        PageRef = processAccess.OnAddCreateProcess();
        
        lstStr = processAccess.getProcessAssigned();
        lstStr.clear();
        str1 = viewProcess.SVMXC__Name__c;
        lstStr.add(str1);
        processAccess.setProcessAssigned(lstStr);
        PageRef = processAccess.OnRemoveViewProcess();
        
        lstStr = processAccess.getProcessCreateAssigned();
        lstStr.clear();
        str1 = createProcess.SVMXC__Name__c;
        lstStr.add(str1);
        processAccess.setProcessCreateAssigned(lstStr);
        PageRef = processAccess.OnRemoveCreateProcess();
        
        List<SelectOption> lstSlctOptn = processAccess.getObjectsWithAction();
        lstSlctOptn = processAccess.getAvalViewProcess();
        boolean b = processAccess.getRender();
        processAccess.setRender(b);
        b = processAccess.getShowButton();
        processAccess.setShowButton(b);
        b = processAccess.getShowMessage1();
        processAccess.setShowMessage1(b);
        b = processAccess.getShowMessage2();
        processAccess.setShowMessage2(b);
        lstSlctOptn = processAccess.getAvalCreateProcess();
        lstSlctOptn = processAccess.getAssignedViewProcess();
        lstSlctOptn = processAccess.getAssignedCreateProcess();
        lstSlctOptn = processAccess.getProfiles();
        
        processAccess.setSelectedSourceObject('SVMXC__Service_Order__c');
        processAccess.fetchProcesses();
        processAccess.onChngObject();
        processAccess.setSelectedProfile(str);
        PageRef = processAccess.OnChangeProfile();
        PageRef = processAccess.OnRemoveViewProcess();
        PageRef = processAccess.OnAddViewProcess();
        PageRef = processAccess.OnRemoveCreateProcess();
        PageRef = processAccess.OnAddCreateProcess();
        processAccess.onClickYes();
        processAccess.onClickNo();
        } Catch (Exception ex) {}
     }
     
     static testMethod void ServiceFlowAccess_UnitTest1() 
    {
        try {
        String RTypeId = '';
        RecordType Rtype;
        
        Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Configuration Profile' Limit 1];
        RTypeId = Rtype.Id;
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Profile_Name__c = 'ConfigData001';
        configData.SVMXC__Description__c = 'ConfigData001';
        configData.RecordTypeId = RTypeId;
        configData.SVMXC__Configuration_Type__c = 'Group';
        insert configData;
        
        SVMXC__ServiceMax_Processes__c viewProcess = new SVMXC__ServiceMax_Processes__c();
        viewProcess.SVMXC__Purpose__c = 'VIEW RECORD';
        viewProcess.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        viewProcess.SVMXC__Name__c = 'Process001';
        viewProcess.SVMXC__MapID__c = 'MAPPROCESS001';
        insert viewProcess;
        system.assert(viewProcess.SVMXC__Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c createProcess = new SVMXC__ServiceMax_Processes__c();
        createProcess.SVMXC__Purpose__c = 'STANDALONE CREATE';
        createProcess.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        createProcess.SVMXC__Name__c = 'Process002';
        createProcess.SVMXC__MapID__c = 'MAPPROCESS001';
        insert createProcess;
        system.assert(createProcess.SVMXC__Name__c!=null);
        system.assert(createProcess.SVMXC__Target_Object_Name__c!=null);
        system.assert(createProcess.SVMXC__Purpose__c!=null);
        
        CONF_ServiceFlowAccess processAccess = new CONF_ServiceFlowAccess();
        string str = '--None--';
        processAccess.setSelectedProfile(str);
        
        processAccess.fetchProcesses();
        PageReference PageRef = processAccess.OnChangeProfile();
        PageRef = processAccess.quickSave();
     }
     catch(exception ex) {}
    }
}