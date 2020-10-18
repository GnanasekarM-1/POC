@isTest
private with sharing class CONF_ManagePMProcesses_UT
{
    static testMethod void CONF_ManagePMProcesses_UnitTest()
    {
        RecordType PMProcess_Rtype = [select Id from RecordType where Name='PM Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        
        CONF_ManagePMProcesses MngPMObj = new CONF_ManagePMProcesses();
        MngPMObj.getHLPURL();
        MngPMObj.getHLPTITLE();
        MngPMObj.getTAG001();
        MngPMObj.getTAG002();
        MngPMObj.getTAG003();
        MngPMObj.getTAG004();
        MngPMObj.getTAG005();
        MngPMObj.getTAG006();
        MngPMObj.getTAG007();
        MngPMObj.getTAG008();
        MngPMObj.getTAG009();
        MngPMObj.getTAG010();
        MngPMObj.getTAG011();
        MngPMObj.getTAG012();
        MngPMObj.getTAG013();
        MngPMObj.getTAG014();
        MngPMObj.getTAG015();
        MngPMObj.getTAG016();
        MngPMObj.getTAG017();
        MngPMObj.getTAG018();
        MngPMObj.getTAG019();
        
        List<SVMXC__ServiceMax_Processes__c> lstProcess = new List<SVMXC__ServiceMax_Processes__c>();
        
        SVMXC__ServiceMax_Processes__c pro1 = new SVMXC__ServiceMax_Processes__c();
        pro1.SVMXC__IsStandard__c = true;
        pro1.SVMXC__ProcessId__c = 'PMProcess111';
        pro1.SVMXC__Name__C = 'PMProcess111';
        pro1.SVMXC__Description__c = 'PMProcess111';
        pro1.SVMXC__Select__c = false;
        pro1.RecordTypeId = PMProcess_Rtype.Id;
        lstProcess.add(pro1);
        
        SVMXC__ServiceMax_Processes__c pro2 = new SVMXC__ServiceMax_Processes__c();
        pro2.SVMXC__IsStandard__c = false;
        pro2.SVMXC__ProcessId__c = 'PMProcess222';
        pro2.SVMXC__Name__C = 'PMProcess222';
        pro2.SVMXC__Description__c = 'PMProcess222';
        pro2.SVMXC__Select__c = false;
        pro2.RecordTypeId = PMProcess_Rtype.Id;
        lstProcess.add(pro2);
        
        insert lstProcess;
        
        CONF_ManagePMProcesses MngPMObj1 = new CONF_ManagePMProcesses();
        MngPMObj1.StdView();
        MngPMObj1.CONF_CL_PMProcess();
        MngPMObj1.CONF_CL_PMProcessCustm();
        MngPMObj1.CONF_ED_PMProcess();
        MngPMObj1.CONF_DL_PMProcess();
        MngPMObj1.CONF_NW_PMProcess();
        MngPMObj1.backToSetupHome();
        
        pro1.SVMXC__Select__c = true;
        update pro1;
        
        lstProcess.clear();
        SVMXC__ServiceMax_Processes__c pro3 = new SVMXC__ServiceMax_Processes__c();
        pro3.SVMXC__IsStandard__c = true;
        pro3.SVMXC__ProcessId__c = 'PMProcess333';
        pro3.SVMXC__Name__C = 'PMProcess333';
        pro3.SVMXC__Description__c = 'PMProcess333';
      
        pro3.RecordTypeId = PMProcess_Rtype.Id;
        lstProcess.add(pro3);
        
        SVMXC__ServiceMax_Processes__c pro4 = new SVMXC__ServiceMax_Processes__c();
        pro4.SVMXC__IsStandard__c = false;
        pro4.SVMXC__ProcessId__c = 'PMProcess444';
        pro4.SVMXC__Name__C = 'PMProcess444';
        pro4.SVMXC__Description__c = 'PMProcess444';
       
        pro4.RecordTypeId = PMProcess_Rtype.Id;
        lstProcess.add(pro4);
        
        insert lstProcess;
        
        CONF_ManagePMProcesses mngPMobj2 = new CONF_ManagePMProcesses();
        mngPMobj2.StdView();
        mngPMobj2.CONF_CL_PMProcess();
        
        pro2.SVMXC__Select__c = true;
        update pro2;
        
        CONF_ManagePMProcesses mngPMobj3 = new CONF_ManagePMProcesses();
        mngPMobj3.CONF_CL_PMProcessCustm();
        mngPMobj3.CONF_ED_PMProcess();
        mngPMobj3.CONF_DL_PMProcess();
        
        pro3.SVMXC__Select__c = false;
        update pro3;
        
        pro4.SVMXC__Select__c = false;
        update pro4;
        
        CONF_ManagePMProcesses mngPMobj4 = new CONF_ManagePMProcesses();
        mngPMobj4.StdView();
        mngPMobj4.CONF_CL_PMProcess();
        mngPMobj4.CONF_ED_PMProcess();
        mngPMobj4.CONF_CL_PMProcessCustm();
        mngPMobj4.CONF_DL_PMProcess();
        
        
    }
}