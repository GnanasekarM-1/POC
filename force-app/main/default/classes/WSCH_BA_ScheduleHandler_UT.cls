@isTest
(SeeAllData=true)
private class WSCH_BA_ScheduleHandler_UT {
    static testmethod void testWSCH_BA_ScheduleHandler() {
        Test.startTest();
            String strDate = WSCH_BA_ScheduleHandler.getSchedulerExpression(Datetime.now());
            //WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.WO_BATCH_CLASS_NAME,WSCH_Constants.BATCH_APEX_START_TIME);
            
            
            String DispatchProRecordTypeId = '';
            String ExpressionRTypeId = '';
            String RuleRecordTypeId = '';
            String FldMapRecordTypeId = '';
            String TCRT = '';
            RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
            for(RecordType rt : rts) //Loop to take a record type at a time
            {
                if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                   DispatchProRecordTypeId = rt.ID;
                else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                   ExpressionRTypeId = rt.ID;
                else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                    RuleRecordTypeId = rt.id;
                else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                    FldMapRecordTypeId = rt.id;
                else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                    TCRT = rt.id;
            }
            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
            svmxprocess.RecordTypeId = DispatchProRecordTypeId;
            svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
            svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
            insert svmxprocess;
            
            SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
            wo.SVMXC__Dispatch_Process__c = svmxprocess.id;
            wo.SVMXC__OptiMax_Status__c = 'OPT_TENTATIVE';
            wo.SVMXC__OptiMax_Status__c = 'OPT_BATCH';
            insert wo;

            WSCH_BA_ScheduleHandler.startBatchApex('WSCH_SP_WorkOrderBatchApex',10);
        Test.stopTest();
    }
}