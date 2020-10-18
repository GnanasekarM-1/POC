@isTest
private with sharing class CONF_ManageWOBillingProcesses_UT
{
    static testMethod void CONF_ManageWOBillingProcesses_UnitTest()
    {
        RecordType WOBilProcess_Rtype = [select Id from RecordType where Name='Work Order Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        
        CONF_ManageWOBillingProcesses manageWOPro = new CONF_ManageWOBillingProcesses();
        
        List<SVMXC__ServiceMax_Processes__c> lstProcess = new List<SVMXC__ServiceMax_Processes__c>();
        
        SVMXC__ServiceMax_Processes__c pro1 = new SVMXC__ServiceMax_Processes__c();
        pro1.SVMXC__IsStandard__c = true;
        pro1.SVMXC__ProcessId__c = 'WOBillingProcess009';
        pro1.SVMXC__Name__C = 'WOBillingProcess009';
        pro1.SVMXC__Description__c = 'WOBillingProcess009';
        pro1.SVMXC__Select__c = false;
        pro1.RecordTypeId = WOBilProcess_Rtype.Id;
        lstProcess.add(pro1);
        
        SVMXC__ServiceMax_Processes__c pro2 = new SVMXC__ServiceMax_Processes__c();
        pro2.SVMXC__IsStandard__c = false;
        pro2.SVMXC__ProcessId__c = 'WOBillingProcess010';
        pro2.SVMXC__Name__C = 'WOBillingProcess010';
        pro2.SVMXC__Description__c = 'WOBillingProcess010';
        pro2.SVMXC__Select__c = false;
        pro2.RecordTypeId = WOBilProcess_Rtype.Id;
        lstProcess.add(pro2);
        
        insert lstProcess;
        
        CONF_ManageWOBillingProcesses manageWOPro1 = new CONF_ManageWOBillingProcesses();
        manageWOPro1.StdView();
        manageWOPro1.CONF_CL_WOBillingProcess();
        manageWOPro1.CONF_CL_WOBillingProcessCustm();
        manageWOPro1.CONF_ED_WOBillingProcess();
        manageWOPro1.CONF_DL_WOBillingProcess();
        manageWOPro1.CONF_NW_WOBillingProcess();
        manageWOPro1.backToSetupHome();
        
        pro1.SVMXC__Select__c = true;
        update pro1;
        
        lstProcess.clear();
        SVMXC__ServiceMax_Processes__c pro3 = new SVMXC__ServiceMax_Processes__c();
        pro3.SVMXC__IsStandard__c = true;
        pro3.SVMXC__ProcessId__c = 'WOBillingProcess011';
        pro3.SVMXC__Name__C = 'WOBillingProcess011';
        pro3.SVMXC__Description__c = 'WOBillingProcess011';
        pro3.SVMXC__Select__c = true;
        pro3.RecordTypeId = WOBilProcess_Rtype.Id;
        lstProcess.add(pro3);
        
        SVMXC__ServiceMax_Processes__c pro4 = new SVMXC__ServiceMax_Processes__c();
        pro4.SVMXC__IsStandard__c = false;
        pro4.SVMXC__ProcessId__c = 'WOBillingProcess012';
        pro4.SVMXC__Name__C = 'WOBillingProcess012';
        pro4.SVMXC__Description__c = 'WOBillingProcess012';
        pro4.SVMXC__Select__c = true;
        pro4.RecordTypeId = WOBilProcess_Rtype.Id;
        lstProcess.add(pro4);
        
        insert lstProcess;
        
        CONF_ManageWOBillingProcesses manageWOPro2 = new CONF_ManageWOBillingProcesses();
        manageWOPro2.StdView();
        manageWOPro2.CONF_CL_WOBillingProcess();
        
        pro2.SVMXC__Select__c = true;
        update pro2;
        
        CONF_ManageWOBillingProcesses manageWOPro3 = new CONF_ManageWOBillingProcesses();
        manageWOPro3.CONF_CL_WOBillingProcessCustm();
        manageWOPro3.CONF_ED_WOBillingProcess();
        manageWOPro3.CONF_DL_WOBillingProcess();
        
        pro3.SVMXC__Select__c = false;
        update pro3;
        
        pro4.SVMXC__Select__c = false;
        update pro4;
        
        CONF_ManageWOBillingProcesses manageWOPro4 = new CONF_ManageWOBillingProcesses();
        manageWOPro4.StdView();
        manageWOPro4.CONF_CL_WOBillingProcess();
        manageWOPro4.CONF_ED_WOBillingProcess();
        manageWOPro4.CONF_CL_WOBillingProcessCustm();
        manageWOPro4.CONF_DL_WOBillingProcess();
        
        manageWOPro4.getHLPURL();
        manageWOPro4.getHLPTITLE();
        manageWOPro4.getTAG001();
        manageWOPro4.getTAG002();
        manageWOPro4.getTAG003();
        manageWOPro4.getTAG004();
        manageWOPro4.getTAG005();
        manageWOPro4.getTAG006();
        manageWOPro4.getTAG007();
        manageWOPro4.getTAG008();
        manageWOPro4.getTAG009();
        manageWOPro4.getTAG010();
        manageWOPro4.getTAG011();
        manageWOPro4.getTAG012();
        manageWOPro4.getTAG013();
        manageWOPro4.getTAG014();
        manageWOPro4.getTAG015();
        manageWOPro4.getTAG016();
        manageWOPro4.getTAG017();
        manageWOPro4.getTAG018();
        manageWOPro4.getTAG019();
    }
}