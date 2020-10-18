@isTest
private class SFM_ExecuteAPEX_UT {

    static testMethod void SFM_ExecuteAPEX_Test() 
    {
        Account objAcc = new Account();
        objAcc.Name = 'TestingName';
        insert objAcc;
        System.assert(objAcc.Id != null);
        
        RecordType recrdTyp = new RecordType();
        
        recrdTyp = [select Id from RecordType where Name='SF Action'and SobjectType='SVMXC__ServiceMax_Processes__c' limit 1];
        
        SVMXC__ServiceMax_Processes__c objPrcss = new SVMXC__ServiceMax_Processes__c();
        objPrcss.SVMXC__Service_Namespace__c = 'SVMXC';
        objPrcss.SVMXC__Service_Class_Name__c = 'ClassName';
        objPrcss.SVMXC__Service_Method_Name__c = 'MethodName';
        objPrcss.SVMXC__Parent_Error_Msg__c = 'This is processing message';
        objPrcss.SVMXC__ProcessID__c = 'PrcssesId';
        objPrcss.RecordTypeId = recrdTyp.Id;
        Insert objPrcss;
        
        System.currentPageReference().getParameters().put('SVMX_recordId', objAcc.Id);
        System.currentPageReference().getParameters().put('SVMX_processId', 'PrcssesId');
        //System.currentPageReference().getParameters().put('SVMX_NxtStepID', 'Testing...');
        System.currentPageReference().getParameters().put('SVMX_title', 'Title of WS');
        
        
        
        SFM_ExecuteAPEX objSFMExecute = new SFM_ExecuteAPEX();
        objSFMExecute.onloadfun();
        objSFMExecute.shoErrConfMsg();
        //objSFMExecute.callMethWOMsg();
        objSFMExecute.strRespoMsg='testing';
        objSFMExecute.strNxtURL='testing';
        objSFMExecute.strNavigateTo = '../apex/conf_setuphome';
        
        objSFMExecute.showWarnMsg();
        objSFMExecute.showInfoMsg();
        objSFMExecute.webServiceFailWM();
        objSFMExecute.doContinue();
        objSFMExecute.goBack();
        objSFMExecute.getTAG002();
        objSFMExecute.getTAG003();
        objSFMExecute.strNxtURL = '../apex/conf_setuphome';
        objSFMExecute.doContinue();
        objSFMExecute.strNxtPrcssId = 'testing';
        objSFMExecute.showInfoMsg();
        objSFMExecute.strNxtURL = '/RecordId';
        objSFMExecute.showWarnMsg();
        objSFMExecute.callMethWOMsg();
        objSFMExecute.strRecordId = 'RecordId';
        objSFMExecute.strNxtURL = '/RecordId';
        objSFMExecute.callMethWOMsg();
        objSFMExecute.showWarnMsg();
        objSFMExecute.strNxtURL = '../apex/conf_setuphome';
        objSFMExecute.callMethWOMsg();
        objSFMExecute.strRespoMsg = '<Start><First></First><faultstring>Testing String</faultstring></Start>';
        objSFMExecute.shoErrConfMsg();
        
    }
}