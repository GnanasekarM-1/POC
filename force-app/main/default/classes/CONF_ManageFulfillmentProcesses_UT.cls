@isTest
private class CONF_ManageFulfillmentProcesses_UT
{
    static testMethod void CONF_ManageFulfillmentProcesses_UT_Test()
    {
        CONF_ManageFulfillmentProcesses MFP1 = new CONF_ManageFulfillmentProcesses();
        RecordType RT1 = [select Id, Name from RecordType where Name = 'Fulfillment Process' and SobjectType = 'SVMXC__ServiceMax_Processes__c' limit 1];
        RecordType RT2 = [select Id, Name from RecordType where Name = 'SVMX Rule' and SobjectType = 'SVMXC__ServiceMax_Processes__c' limit 1];
        
        SVMXC__ServiceMax_Processes__c CPL = new SVMXC__ServiceMax_Processes__c();
        CPL.SVMXC__Select__c = true;
        CPL.SVMXC__ProcessId__c = 'PID';
        CPL.SVMXC__Name__c = 'Shashank';
        CPL.SVMXC__Description__c = 'test shashank';
        CPL.SVMXC__IsStandard__c = false;
        CPL.RecordTypeId = RT1.Id;
        insert CPL;
    
        List <ID> custmProcessLst = new List<ID>();
        custmProcessLst.add(CPL.ID);
            
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.SVMXC__City__c = 'Bangalore';
        insert loc;
        
        SVMXC__ServiceMax_Processes__c LPR = new SVMXC__ServiceMax_Processes__c();
        LPR.SVMXC__Name__c = 'Panchal';
        LPR.RecordTypeId = RT2.Id;
        LPR.SVMXC__ProcessID__c = 'PID';
        LPR.SVMXC__Sequence__c = 1;
        LPR.SVMXC__Select__c = true;
        LPR.SVMXC__Rule_Type__c = 'FulFillment Path';
        LPR.SVMXC__Parent_Column_Name__c = 'Parent Column';
        LPR.SVMXC__Default_Location__c = loc.Id;
        //LPR.SVMXC__Default_Location__r = 
        LPR.SVMXC__Submodule__c = CPL.Id;
        LPR.SVMXC__Process__c = CPL.Id;
        LPR.SVMXC__IsDefault__c = true;
        //LPR.LastModifiedDate =
        insert LPR;
        //List<ID> lstPathRules = new L<ID>();
        //lstPathRules.add(LPR.ID); 
        
        CONF_ManageFulfillmentProcesses MFP = new CONF_ManageFulfillmentProcesses();
        MFP.editRcvProcess();
        
        MFP.CustmClone();
        MFP.delRcvProcess();
        MFP.backToSetupHome();
        MFP.newRcvProcess();
        
        List<SVMXC__ServiceMax_Processes__c> o = MFP.getcustmProcessLst();
        MFP.setcustmProcessLst(o);
        boolean b = MFP.getDisableStdBtn();
        MFP.setDisableStdBtn(b);
        MFP.getDisableCusBtn();
        
        MFP.getTag001();
        MFP.getTag002();
        //MFP.getTag003();
        MFP.getTag004();
        MFP.getTag005();
        MFP.getTag006();
        MFP.getTag007();
        MFP.getTag008();
        MFP.getTag009();
        MFP.getTag010();
        //MFP.getTag011();
        MFP.getTag012();
        MFP.getTag013();
        MFP.getTag014();
        MFP.getTag015();
        MFP.getHLPURL();
        MFP.getTag017();
        MFP.getTag018();
        MFP.getTag019();
    }
}