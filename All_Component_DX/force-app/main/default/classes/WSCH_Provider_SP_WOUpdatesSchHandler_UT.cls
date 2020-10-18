@isTest
(SeeAllData=true)
public class WSCH_Provider_SP_WOUpdatesSchHandler_UT {
    public WSCH_Provider_SP_WOUpdatesSchHandler_UT() {
        List<SVMXC__ServiceMax_Config_Data__c> lstConf = [SELECT id,SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Unique_ID__c IN ('DCON004_SET006')];

    for(SVMXC__ServiceMax_Config_Data__c confObj : lstConf)
        {
        confObj.SVMXC__Display_Value__c = 'true';
        confObj.SVMXC__Internal_Value__c = 'true';
        confObj.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        }

        if(!lstConf.isEmpty()){
			Database.update(lstConf);
    }
  }
    static{
        	WSCH_Provider_SP_WOUpdatesSchHandler_UT woSchHandler = new WSCH_Provider_SP_WOUpdatesSchHandler_UT();
        
    }
    static testMethod void testWOUpdateSchHanler(){
        WSCH_Provider_SP_WOUpdatesSchHandler.WO_UPDATES_BATCHAPEX_NAME = 'WSCH_Provider_SP_WOUpdatesBatchApex';
        WSCH_Provider_SP_WOUpdatesSchHandler.startBatchApex(10);
    }
    static testMethod void testMaxQ(){
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

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='Open';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        territory.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory;

        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'South West Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'SWR';
        insert territory1;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__OptiMax_Status__c ='';
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75005';
        workOrder1.SVMXC__Order_Status__c='Open';
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 60;
        workOrder1.SVMXC__OptiMax_Status__c = '';
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrders.add(workOrder1);
		
		Database.insert(workOrders);
		
		list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = new list<SVMXC__SVMX_Optimizer__c>();
		
		SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
		optimizer.SVMXC__WhatId__c = String.valueOf(workOrder.id);
		optimizer.SVMXC__WhatType__c = 'WORK_ORDER';
		optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_WO';
		optimizer.SVMXC__Optimizer_Status__c = 'BATCH_QUEUED';
		optimizer.SVMXC__Optimizer_Retry_Count__c = 0;
		lstSVMXOptimizer.add(optimizer);
		
		SVMXC__SVMX_Optimizer__c optimizer1 = new SVMXC__SVMX_Optimizer__c();
		optimizer1.SVMXC__WhatId__c = String.valueOf(workOrder1.id);
		optimizer1.SVMXC__WhatType__c = 'WORK_ORDER';
		optimizer1.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_WO';
		optimizer1.SVMXC__Optimizer_Status__c = 'BATCH_QUEUED';
		optimizer1.SVMXC__Optimizer_Retry_Count__c = 0;
		lstSVMXOptimizer.add(optimizer1);
		
		Database.insert(lstSVMXOptimizer);
        
        WSCH_Provider_SP_WOUpdatesSchHandler.startMaxQ();
    }
}