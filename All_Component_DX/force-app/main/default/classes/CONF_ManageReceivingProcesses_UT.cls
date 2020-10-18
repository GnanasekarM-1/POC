@isTest
private with sharing class CONF_ManageReceivingProcesses_UT
{
    static testMethod void CONF_ManageReceivingProcesses_UnitTest() 
    {
        RecordType ReceivingProcess_Rtype = [Select Id from RecordType where Name='Receiving Process' and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC__ServiceMax_Processes__c stndProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c custmProcess = new SVMXC__ServiceMax_Processes__c();
        
        stndProcess.RecordTypeId = ReceivingProcess_Rtype.Id;
        stndProcess.SVMXC__Name__C = 'Receiving Process 1';
        stndProcess.SVMXC__IsStandard__c = true;
        stndProcess.SVMXC__ProcessId__c = 'Receiving Process 1';
        stndProcess.SVMXC__Select__c = false;
        insert stndProcess;
        
        custmProcess.RecordTypeId = ReceivingProcess_Rtype.Id;
        custmProcess.SVMXC__Name__C = 'Receiving Process 2';
        custmProcess.SVMXC__IsStandard__c = false;
        custmProcess.SVMXC__ProcessId__c = 'Receiving Process 2';
        custmProcess.SVMXC__Select__c = false;
        insert custmProcess;
        
        CONF_ManageReceivingProcesses ManageReceivingProcessObj = new CONF_ManageReceivingProcesses();
        ManageReceivingProcessObj.StdView();
        ManageReceivingProcessObj.StdClone();
        ManageReceivingProcessObj.backToSetupHome();
        ManageReceivingProcessObj.CustmClone();
        
        stndProcess.SVMXC__Select__c = true;
        update stndProcess;
        custmProcess.SVMXC__Select__c = true;
        update custmProcess;
        
        ManageReceivingProcessObj = new CONF_ManageReceivingProcesses();
        ManageReceivingProcessObj.StdView();
        ManageReceivingProcessObj.StdClone();
        ManageReceivingProcessObj.CustmClone();
        
        SVMXC__ServiceMax_Processes__c stndProcess1 = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c custmProcess1 = new SVMXC__ServiceMax_Processes__c();
        
        stndProcess1.RecordTypeId = ReceivingProcess_Rtype.Id;
        stndProcess1.SVMXC__Name__C = 'Receiving Process 3';
        stndProcess1.SVMXC__IsStandard__c = true;
        stndProcess1.SVMXC__ProcessId__c = 'Receiving Process 3';
        stndProcess1.SVMXC__Select__c = true;
        insert stndProcess1;
        
        custmProcess1.RecordTypeId = ReceivingProcess_Rtype.Id;
        custmProcess1.SVMXC__Name__C = 'Receiving Process 4';
        custmProcess1.SVMXC__IsStandard__c = false;
        custmProcess1.SVMXC__ProcessId__c = 'Receiving Process 4';
        custmProcess1.SVMXC__Select__c = true;
        insert custmProcess1;
        
        ManageReceivingProcessObj = new CONF_ManageReceivingProcesses();
        ManageReceivingProcessObj.StdView();
        ManageReceivingProcessObj.StdClone();
        ManageReceivingProcessObj.CustmClone();
        
        ManageReceivingProcessObj.getTAG001();
        ManageReceivingProcessObj.getTAG002();
        ManageReceivingProcessObj.getTAG003();
        ManageReceivingProcessObj.getTAG004();
        ManageReceivingProcessObj.getTAG005();
        ManageReceivingProcessObj.getTAG006();
        ManageReceivingProcessObj.getTAG007();
        ManageReceivingProcessObj.getTAG008();
        ManageReceivingProcessObj.getTAG009();
        ManageReceivingProcessObj.getTAG010();
        ManageReceivingProcessObj.getTAG011();
        ManageReceivingProcessObj.getTAG012();
        ManageReceivingProcessObj.getTAG013();
        
        List<SVMXC__ServiceMax_Processes__c> LstPro = ManageReceivingProcessObj.getstndProcessLst();
        ManageReceivingProcessObj.setstndProcessLst(LstPro);
        LstPro = ManageReceivingProcessObj.getcustmProcessLst();
        ManageReceivingProcessObj.setcustmProcessLst(LstPro);
        boolean b = ManageReceivingProcessObj.getDisableStdBtn();
        ManageReceivingProcessObj.setDisableStdBtn(b);
        b = ManageReceivingProcessObj.getDisableCusBtn();
        ManageReceivingProcessObj.newRcvProcess();
        ManageReceivingProcessObj.editRcvProcess();
        ManageReceivingProcessObj.delRcvProcess();
        ManageReceivingProcessObj.getTag014();
        ManageReceivingProcessObj.getTag015();
        ManageReceivingProcessObj.getTag015();
        ManageReceivingProcessObj.getHLPURL();
    }
}