@isTest
private class CONF_ManageViewPermission_UT 
{
    static testMethod void CONF_ManageViewPermission_UT_Test()
    {
        CONF_ManageViewPermission objMngViePermsn = new CONF_ManageViewPermission();
        
        RecordType RTProcess = [select Id from RecordType where Name = 'View Definition' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RTCfgDta = [select Id from RecordType where Name = 'View Access' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__ServiceMax_Processes__c objPrcss = new SVMXC__ServiceMax_Processes__c();
        objPrcss.RecordTypeId = RTProcess.Id;
        objPrcss.SVMXC__Rule_Type__c = 'Custom_View';
        insert objPrcss;
        
        
        objMngViePermsn.lstSVMXPrcss = [select Id, SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where RecordTypeId =: RTProcess.Id and SVMXC__Rule_Type__c = : 'Custom_View'];
        
        //Create ServiceTeam
        SVMXC__Service_Group__c objServiceTeam = new SVMXC__Service_Group__c();
        objServiceTeam.name='TestServiceTeam';
        insert objServiceTeam;
        
        SVMXC__Service_Group__c objServiceTeam1 = new SVMXC__Service_Group__c();
        objServiceTeam1.name='TestServiceTeam1';
        insert objServiceTeam1;

        //Create Territory
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
        objTerritory.name='TestTerritory';
        insert objTerritory;
        
        SVMXC__Territory__c objTerritory1 = new SVMXC__Territory__c();
        objTerritory1.name='TestTerritory1';
        insert objTerritory1;
        
        
        //ServiceMax Config Data
        SVMXC__ServiceMax_Config_Data__c objCfg = new SVMXC__ServiceMax_Config_Data__c();
        objCfg.RecordTypeId = RTCfgDta.Id;
        objCfg.SVMXC__Configuration_Type__c = 'Custom_View';
        objCfg.SVMXC__Dispatch_Process__c = objPrcss.Id;
        objCfg.SVMXC__Access_To__c = 'Dispatcher';
        objCfg.SVMXC__Service_Group__c =objServiceTeam.Id;
        insert objCfg;
        
        SVMXC__ServiceMax_Config_Data__c objCfg1 = new SVMXC__ServiceMax_Config_Data__c();
        objCfg1.RecordTypeId = RTCfgDta.Id;
        objCfg1.SVMXC__Configuration_Type__c = 'Custom_View';
        objCfg1.SVMXC__Dispatch_Process__c = objPrcss.Id;
        objCfg1.SVMXC__Access_To__c = 'Dispatcher';
        objCfg1.SVMXC__Territory__c =objTerritory.Id;
        insert objCfg1;
        
        objMngViePermsn.getLstSVMXCfgDtaTeam();
        objMngViePermsn.getLstSVMXCfgDtaTerritory();
        objMngViePermsn.getServiceTeams();
        objMngViePermsn.getLstTerritory();
        objMngViePermsn.getSelPrcssOptn();
        
        
        List<selectOption> lstTempOptn = new List<selectOption>();
        lstTempOptn.add(new SelectOption('test1', 'test1'));    
        lstTempOptn.add(new SelectOption('test2', 'test2'));
        
        objMngViePermsn.sortingSelectOption(lstTempOptn);
        
        
        objMngViePermsn.exeQuerry();
        objMngViePermsn.onChangeProcessOptn();
        objMngViePermsn.SVMX_GOTeam();
        objMngViePermsn.SVMX_GOTerritory();
        objMngViePermsn.SVMX_AddTeam();
        objMngViePermsn.SVMX_AddSelectedTeam();
        objMngViePermsn.SVMX_AddTerritory();
        objMngViePermsn.SVMX_AddSelectedTerritory();
        objMngViePermsn.SVMX_DeleteTeam();
        objMngViePermsn.SVMX_DeleteTerritory();
        objMngViePermsn.saveData();
        objMngViePermsn.quickSave();
        objMngViePermsn.saveNClose();
        objMngViePermsn.cancel();
        objMngViePermsn.SVMX_BackToTeam();
        objMngViePermsn.SVMX_BackToTerritory();
        
        String SearchKeyword='test';
        String SearchTerriKeyword='test';
        objMngViePermsn.SVMX_GOTeam();
        objMngViePermsn.SVMX_GOTerritory();
        
        list<SVMXC__Service_Group__c> lstTeam = new list<SVMXC__Service_Group__c>();
        
        SVMXC__Service_Group__c objServiceTeam2 = new SVMXC__Service_Group__c();
        objServiceTeam2.name='TestServiceTeam2';
        objServiceTeam2.SVMXC__Select__c=true;
        lstTeam.add(objServiceTeam2);
        insert lstTeam;
        objMngViePermsn.ServiceTeams.addall(lstTeam);
        
        list<SVMXC__Territory__c> lstTerritory = new list<SVMXC__Territory__c>();
        
        SVMXC__Territory__c objTerritory2 = new SVMXC__Territory__c();
        objTerritory2.name='TestTerritory2';
        objTerritory2.SVMXC__Select__c=true;
        lstTerritory.add(objTerritory2);
        insert lstTerritory;
        objMngViePermsn.lstTerritory.addall(lstTerritory);
        
        objMngViePermsn.SVMX_AddSelectedTeam();
        objMngViePermsn.SVMX_AddSelectedTerritory();
        
        
        
        list<SVMXC__ServiceMax_Config_Data__c> lstCfgDataTeam = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c objCfg2 = new SVMXC__ServiceMax_Config_Data__c();
        objCfg2.RecordTypeId = RTCfgDta.Id;
        objCfg2.SVMXC__Configuration_Type__c = 'Custom_View';
        objCfg2.SVMXC__Dispatch_Process__c = objPrcss.Id;
        objCfg2.SVMXC__Access_To__c = 'Dispatcher';
        objCfg2.SVMXC__Service_Group__c =objServiceTeam2.Id;
        lstCfgDataTeam.add(objCfg2);
        insert lstCfgDataTeam;
        objMngViePermsn.lstSVMXCfgDtaTeam.addall(lstCfgDataTeam);
        
        objMngViePermsn.SVMX_DeleteTeam();
        
        list<SVMXC__ServiceMax_Config_Data__c> lstCfgDataTerritory = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c objCfg3 = new SVMXC__ServiceMax_Config_Data__c();
        objCfg3.RecordTypeId = RTCfgDta.Id;
        objCfg3.SVMXC__Configuration_Type__c = 'Custom_View';
        objCfg3.SVMXC__Dispatch_Process__c = objPrcss.Id;
        objCfg3.SVMXC__Access_To__c = 'Dispatcher';
        objCfg3.SVMXC__Territory__c =objTerritory2.Id;
        lstCfgDataTerritory.add(objCfg3);
        insert lstCfgDataTerritory;
        objMngViePermsn.lstSVMXCfgDtaTerritory.addall(lstCfgDataTerritory);
        
        objMngViePermsn.SVMX_DeleteTerritory();
                
        SVMXC__ServiceMax_Processes__c objPrcss1 = new SVMXC__ServiceMax_Processes__c();
        objPrcss1.RecordTypeId = RTProcess.Id;
        objPrcss1.SVMXC__Rule_Type__c = 'Custom_View1';
        insert objPrcss1;
        
        objMngViePermsn.exeQuerry();
        
       //calling tags
        objMngViePermsn.getTAG001();
        objMngViePermsn.getTAG002();
        objMngViePermsn.getTAG003();
        objMngViePermsn.getTAG004();
        objMngViePermsn.getTAG005();
        objMngViePermsn.getTAG006();
       // objMngViePermsn.getTAG007();
        //objMngViePermsn.getTAG008();
       // objMngViePermsn.getTAG009();
        //objMngViePermsn.getTAG010();
        //objMngViePermsn.getTAG011();
        objMngViePermsn.getTAG012();
        objMngViePermsn.getTAG013();
        objMngViePermsn.getTAG014();
        //objMngViePermsn.getTAG015();
       // objMngViePermsn.getTAG016();
        objMngViePermsn.getTAG017();
        objMngViePermsn.getTAG018();
        objMngViePermsn.getTAG019();
        objMngViePermsn.getTAG020();
        objMngViePermsn.getTAG021();
        objMngViePermsn.getTAG022();
        objMngViePermsn.getTAG023();
        objMngViePermsn.getTAG024();
        objMngViePermsn.getTAG025();
        objMngViePermsn.getTAG026();
        objMngViePermsn.getTAG027();
        //objMngViePermsn.getTAG028();
        objMngViePermsn.getTAG029();
        objMngViePermsn.getTAG030();
    }
}