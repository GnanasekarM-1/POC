@isTest
private with sharing class CONF_ManageShippingProcesses_UT
{
    static testMethod void CONF_ManageShippingProcesses_UnitTest() 
    {
        CONF_ManageShippingProcesses manage = new CONF_ManageShippingProcesses();
        
        RecordType ShippingProcess_Rtype = [select Id from RecordType where Name='Shipping Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC__ServiceMax_Processes__c stndProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c custmProcess = new SVMXC__ServiceMax_Processes__c();
        
        stndProcess.RecordTypeId = ShippingProcess_Rtype.Id;
        stndProcess.SVMXC__Name__C = 'SHIP0000001';
        stndProcess.SVMXC__IsStandard__c = true;
        stndProcess.SVMXC__ProcessId__c = 'SHIP0000001';
        stndProcess.SVMXC__Select__c = false;
        insert stndProcess;
        
        custmProcess.RecordTypeId = ShippingProcess_Rtype.Id;
        custmProcess.SVMXC__Name__C = 'SHIP0000002';
        custmProcess.SVMXC__IsStandard__c = false;
        custmProcess.SVMXC__ProcessId__c = 'SHIP0000002';
        custmProcess.SVMXC__Select__c = false;
        insert custmProcess;
        
        manage = new CONF_ManageShippingProcesses();
        pagereference pgRef = manage.StdView();
        pgRef = manage.StdClone();
        pgRef = manage.backToSetupHome();
        pgRef = manage.newShpProcess();
        pgRef = manage.editShpProcess();
        pgRef = manage.CustmClone();
        pgRef = manage.delShpProcess();
        
        stndProcess.SVMXC__Select__c = true;
        update stndProcess;
        custmProcess.SVMXC__Select__c = true;
        update custmProcess;
        
        manage = new CONF_ManageShippingProcesses();
        pgRef = manage.StdView();
        pgRef = manage.StdClone();
        pgRef = manage.editShpProcess();
        pgRef = manage.CustmClone();
        pgRef = manage.delShpProcess();
        
        SVMXC__ServiceMax_Processes__c stndProcess1 = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c custmProcess1 = new SVMXC__ServiceMax_Processes__c();
        
        stndProcess1.RecordTypeId = ShippingProcess_Rtype.Id;
        stndProcess1.SVMXC__Name__C = 'SHIP0000003';
        stndProcess1.SVMXC__IsStandard__c = true;
        stndProcess1.SVMXC__ProcessId__c = 'SHIP0000003';
        stndProcess1.SVMXC__Select__c = true;
        insert stndProcess1;
        
        custmProcess1.RecordTypeId = ShippingProcess_Rtype.Id;
        custmProcess1.SVMXC__Name__C = 'SHIP0000004';
        custmProcess1.SVMXC__IsStandard__c = false;
        custmProcess1.SVMXC__ProcessId__c = 'SHIP0000004';
        custmProcess1.SVMXC__Select__c = true;
        insert custmProcess1;
        
        manage = new CONF_ManageShippingProcesses();
        pgRef = manage.StdView();
        pgRef = manage.StdClone();
        pgRef = manage.editShpProcess();
        pgRef = manage.CustmClone();
        pgRef = manage.delShpProcess();
        
        string str = manage.getTAG001();
        str = manage.getTAG002();
        str = manage.getTAG003();
        str = manage.getTAG004();
        str = manage.getTAG005();
        str = manage.getTAG006();
        str = manage.getTAG007();
        str = manage.getTAG008();
        str = manage.getTAG009();
        str = manage.getTAG010();
        str = manage.getTAG011();
        str = manage.getTAG012();
        str = manage.getTAG013();
        str = manage.getTAG014();
        str = manage.getTAG015();
        str = manage.getTAG016();
        str = manage.getTAG017();
        str = manage.getTAG018();
        
        List<SVMXC__ServiceMax_Processes__c> LstPro = manage.getstndProcessLst();
        manage.setstndProcessLst(LstPro);
        LstPro = manage.getcustmProcessLst();
        manage.setcustmProcessLst(LstPro);
        boolean b = manage.getDisableStdBtn();
        manage.setDisableStdBtn(b);
        b = manage.getDisableCusBtn();
    }
}