@isTest
private class CONF_ManageForwardShipments_UT{
    static testmethod void CONF_ManageForwardShipment_UnitTest1(){
        //data
        /*RecordType Rtype_FwdShipment = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'Forward Shipment Process'];
        SVMXC__ServiceMax_Processes__c FwdShipmentRec = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =Rtype_FwdShipment.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'SampleProcess-SVMX001',
                                            SVMXC__ProcessId__c = 'SampleProcess-SVMX001',
                                            SVMXC__IsStandard__c = false,
                                            SVMXC__Select__c = true
                                            );
        insert FwdShipmentRec;*/
        CONF_ManageForwardShipments ManageForwardShipmentInstance = new CONF_ManageForwardShipments();
        ManageForwardShipmentInstance.backToSetupHome();
        ManageForwardShipmentInstance.newRcvProcess();
        ManageForwardShipmentInstance.editRcvProcess();
        ManageForwardShipmentInstance.CustmClone();
        ManageForwardShipmentInstance.delRcvProcess();
        ManageForwardShipmentInstance.getTag001();
        //ManageForwardShipmentInstance.getTag002();
        //ManageForwardShipmentInstance.getTag003();
        ManageForwardShipmentInstance.getTag004();
        ManageForwardShipmentInstance.getTag005();
        ManageForwardShipmentInstance.getTag006();
        ManageForwardShipmentInstance.getTag007();
        ManageForwardShipmentInstance.getTag008();
        ManageForwardShipmentInstance.getTag009();
        ManageForwardShipmentInstance.getTag010();
        ManageForwardShipmentInstance.getTag011();
        ManageForwardShipmentInstance.getTag012();
        ManageForwardShipmentInstance.getTag013();
        ManageForwardShipmentInstance.getTag014();
        ManageForwardShipmentInstance.getTag015();
        //ManageForwardShipmentInstance.getHLPURL();
    }
    static testmethod void CONF_ManageForwardShipment_UnitTest2(){
        //data
        RecordType Rtype_FwdShipment = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'Forward Shipment Process'];
        List<SVMXC__ServiceMax_Processes__c> lst_FwdShipmentProcess = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c FwdShipmentRec = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =Rtype_FwdShipment.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'SampleProcess-SVMX001',
                                            SVMXC__ProcessId__c = 'SampleProcess-SVMX001',
                                            SVMXC__IsStandard__c = false,
                                            SVMXC__Select__c = true
                                            );
        insert FwdShipmentRec;
        lst_FwdShipmentProcess.add(FwdShipmentRec);
        CONF_ManageForwardShipments ManageForwardShipmentInstance = new CONF_ManageForwardShipments();
        ManageForwardShipmentInstance.backToSetupHome();
        ManageForwardShipmentInstance.newRcvProcess();
        ManageForwardShipmentInstance.editRcvProcess();
        ManageForwardShipmentInstance.CustmClone();
        ManageForwardShipmentInstance.delRcvProcess();
        ManageForwardShipmentInstance.getTag001();
        ManageForwardShipmentInstance.getTag002();
        ManageForwardShipmentInstance.getTag003();
        ManageForwardShipmentInstance.getTag004();
        ManageForwardShipmentInstance.getTag005();
        ManageForwardShipmentInstance.getTag006();
        ManageForwardShipmentInstance.getTag007();
        ManageForwardShipmentInstance.getTag008();
        ManageForwardShipmentInstance.getTag009();
        ManageForwardShipmentInstance.getTag010();
        ManageForwardShipmentInstance.getTag011();
        ManageForwardShipmentInstance.getTag012();
        ManageForwardShipmentInstance.getTag013();
        ManageForwardShipmentInstance.getTag014();
        ManageForwardShipmentInstance.getTag015();
        ManageForwardShipmentInstance.BackToHomePage();
        ManageForwardShipmentInstance.getcustmProcessLst();
        ManageForwardShipmentInstance.setcustmProcessLst(lst_FwdShipmentProcess);
        ManageForwardShipmentInstance.getDisableCusBtn();
    }
}