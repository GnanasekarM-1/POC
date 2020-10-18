@isTest
private with sharing class CONF_ManageSCONBillingProcesses_UT
{
    static testMethod void CONF_ManageSCONBillingProcesses_UnitTest()
    {
        RecordType SCONBilProcess_Rtype = [select Id from RecordType where Name='Contract Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        
        CONF_ManageSCONBillingProcesses manageSCONPro = new CONF_ManageSCONBillingProcesses();
        
        List<SVMXC__ServiceMax_Processes__c> lstProcess = new List<SVMXC__ServiceMax_Processes__c>();
        
        SVMXC__ServiceMax_Processes__c pro1 = new SVMXC__ServiceMax_Processes__c();
        pro1.SVMXC__IsStandard__c = true;
        pro1.SVMXC__ProcessId__c = 'SCONBillingProcess009';
        pro1.SVMXC__Name__C = 'SCONBillingProcess009';
        pro1.SVMXC__Description__c = 'SCONBillingProcess009';
        pro1.SVMXC__Select__c = false;
        pro1.RecordTypeId = SCONBilProcess_Rtype.Id;
        lstProcess.add(pro1);
        
        SVMXC__ServiceMax_Processes__c pro2 = new SVMXC__ServiceMax_Processes__c();
        pro2.SVMXC__IsStandard__c = false;
        pro2.SVMXC__ProcessId__c = 'SCONBillingProcess010';
        pro2.SVMXC__Name__C = 'SCONBillingProcess010';
        pro2.SVMXC__Description__c = 'SCONBillingProcess010';
        pro2.SVMXC__Select__c = false;
        pro2.RecordTypeId = SCONBilProcess_Rtype.Id;
        lstProcess.add(pro2);
        
        insert lstProcess;
        
        CONF_ManageSCONBillingProcesses manageSCONPro1 = new CONF_ManageSCONBillingProcesses();
        manageSCONPro1.StdView();
        manageSCONPro1.CONF_CL_SCBillingProcess();
        manageSCONPro1.CONF_CL_SCBillingProcessCustm();
        manageSCONPro1.CONF_ED_SCBillingProcess();
        manageSCONPro1.CONF_DL_SCBillingProcess();
        manageSCONPro1.CONF_NW_SCBillingProcess();
        manageSCONPro1.backToSetupHome();
        
        pro1.SVMXC__Select__c = true;
        update pro1;
        
        lstProcess.clear();
        SVMXC__ServiceMax_Processes__c pro3 = new SVMXC__ServiceMax_Processes__c();
        pro3.SVMXC__IsStandard__c = true;
        pro3.SVMXC__ProcessId__c = 'SCONBillingProcess011';
        pro3.SVMXC__Name__C = 'SCONBillingProcess011';
        pro3.SVMXC__Description__c = 'SCONBillingProcess011';
        pro3.SVMXC__Select__c = true;
        pro3.RecordTypeId = SCONBilProcess_Rtype.Id;
        lstProcess.add(pro3);
        
        SVMXC__ServiceMax_Processes__c pro4 = new SVMXC__ServiceMax_Processes__c();
        pro4.SVMXC__IsStandard__c = false;
        pro4.SVMXC__ProcessId__c = 'SCONBillingProcess012';
        pro4.SVMXC__Name__C = 'SCONBillingProcess012';
        pro4.SVMXC__Description__c = 'SCONBillingProcess012';
        pro4.SVMXC__Select__c = true;
        pro4.RecordTypeId = SCONBilProcess_Rtype.Id;
        lstProcess.add(pro4);
        
        insert lstProcess;
        
        CONF_ManageSCONBillingProcesses manageSCONPro2 = new CONF_ManageSCONBillingProcesses();
        manageSCONPro2.StdView();
        manageSCONPro2.CONF_CL_SCBillingProcess();
        
        pro2.SVMXC__Select__c = true;
        update pro2;
        
        CONF_ManageSCONBillingProcesses manageSCONPro3 = new CONF_ManageSCONBillingProcesses();
        manageSCONPro3.CONF_CL_SCBillingProcessCustm();
        manageSCONPro3.CONF_ED_SCBillingProcess();
        manageSCONPro3.CONF_DL_SCBillingProcess();
        
        pro3.SVMXC__Select__c = false;
        update pro3;
        
        pro4.SVMXC__Select__c = false;
        update pro4;
        
        CONF_ManageSCONBillingProcesses manageSCONPro4 = new CONF_ManageSCONBillingProcesses();
        manageSCONPro4.StdView();
        manageSCONPro4.CONF_CL_SCBillingProcess();
        manageSCONPro4.CONF_ED_SCBillingProcess();
        manageSCONPro4.CONF_CL_SCBillingProcessCustm();
        manageSCONPro4.CONF_DL_SCBillingProcess();
        
        manageSCONPro4.getHLPURL();
        manageSCONPro4.getHLPTITLE();
        manageSCONPro4.getTAG001();
        manageSCONPro4.getTAG002();
        manageSCONPro4.getTAG003();
        manageSCONPro4.getTAG004();
        manageSCONPro4.getTAG005();
        manageSCONPro4.getTAG006();
        manageSCONPro4.getTAG007();
        manageSCONPro4.getTAG008();
        manageSCONPro4.getTAG009();
        manageSCONPro4.getTAG010();
        manageSCONPro4.getTAG011();
        manageSCONPro4.getTAG012();
        manageSCONPro4.getTAG013();
        manageSCONPro4.getTAG014();
        manageSCONPro4.getTAG015();
        manageSCONPro4.getTAG016();
        manageSCONPro4.getTAG017();
        manageSCONPro4.getTAG018();
        manageSCONPro4.getTAG019();
    }
}