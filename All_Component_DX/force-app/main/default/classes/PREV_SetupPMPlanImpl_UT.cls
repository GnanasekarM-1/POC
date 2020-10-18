@isTest(seeAllData=true)
public class PREV_SetupPMPlanImpl_UT {

    static testMethod void getPMPlanDetails(){
         Date TodayDate  = Date.today();
        
        // Insert template and it's schedule template
        SVMXC__PM_Plan_Template__c templateRec = new SVMXC__PM_Plan_Template__c(name = 'test template',
                                                                                    SVMXC__SM_Adjustment_Activity_Date__c = 'SVMXC__Completed_Date_Time__c',
                                                                                    SVMXC__SM_Advanced_Expression__c = '1 OR 2',
                                                                                    SVMXC__Coverage_Type__c = 'Product (Must Have IB)',
                                                                                    SVMXC__SM_Schedule_Type__c = 'Condition Based',
                                                                                    SVMXC__SM_Adjustment_Type__c = 'Actual'
                                                                                    );
        
        insert templateRec; 
        
        Account testAc = new Account (name = 'Test Account1231231');
        insert testAc;
        
        SVMXC__Service_Level__c testSLA = new SVMXC__Service_Level__c(name = 'Test SLA');
        insert testSLA; 
        
        SVMXC__Service_Contract__c scRec = new SVMXC__Service_Contract__c(name = 'Test Service Contract',
                                                                              SVMXC__Company__c = testAc.id, 
                                                                              SVMXC__Service_Level__c = testSLA.id
                                                                              );
        insert scRec; 
        
        SVMXC__Task_Template__c testTaskTemplateRec = new SVMXC__Task_Template__c(
                                                                                        SVMXC__Template_Name__c  = 'Test Task Template'  
                                                                                        );
        insert testTaskTemplateRec; 
        
        PREV_SetupPMPlan_Wrapper.PM_Plan_Request request = new PREV_SetupPMPlan_Wrapper.PM_Plan_Request();
        request.pmTemplateId = templateRec.id;
        request.mode = 'SC';
        request.pmPlanDataUpdates = new PREV_SetupPMPlan_Wrapper.PM_Plan_Data();
        request.pmPlanDataUpdates.startDate = String.valueOf(TodayDate); 
        request.pmPlanDataUpdates.endDate = String.valueOf(TodayDate.addMonths(1));
        request.sourceId = scRec.id;
        
        
        PREV_SetupPMPlanImpl implClass = new PREV_SetupPMPlanImpl();
        PREV_SetupPMPlan_Wrapper.PM_Plan_Response response = new PREV_SetupPMPlan_Wrapper.PM_Plan_Response();
        response = implClass.getPMPlanDetails(request); 
    }
    
    static testMethod void callingPMPlanMethods(){
    
        // Insert template and it's schedule template
        SVMXC__PM_Plan_Template__c templateRec = new SVMXC__PM_Plan_Template__c(name = 'test template',
                                                                                    SVMXC__SM_Adjustment_Activity_Date__c = 'SVMXC__Completed_Date_Time__c',
                                                                                    SVMXC__SM_Advanced_Expression__c = '1 OR 2',
                                                                                    SVMXC__Coverage_Type__c = 'Product (Must Have IB)',
                                                                                    SVMXC__SM_Schedule_Type__c = 'Condition Based',
                                                                                    SVMXC__SM_Adjustment_Type__c = 'Actual'
                                                                                    );
        
        insert templateRec; 
        
        Account testAc = new Account (name = 'Test Account747yf73');
        insert testAc;
        
        SVMXC__Service_Level__c testSLA = new SVMXC__Service_Level__c(name = 'Test SLA');
        insert testSLA; 
        
        SVMXC__Service_Contract__c scRec = new SVMXC__Service_Contract__c(name = 'Test Service Contract',
                                                                              SVMXC__Company__c = testAc.id, 
                                                                              SVMXC__Service_Level__c = testSLA.id
                                                                              );
        insert scRec; 
        
        SVMXC__Task_Template__c testTaskTemplateRec = new SVMXC__Task_Template__c(
                                                                                        SVMXC__Template_Name__c  = 'Test Task Template'  
                                                                                        );
        insert testTaskTemplateRec;

        SVMXC__Site__c locRec = new SVMXC__Site__c();
        locRec.name = 'Bombay';
        insert locRec;

        SVMXC__Installed_Product__c ibRec = new SVMXC__Installed_Product__c();
        ibRec.name = 'test prod';
        insert ibRec;
        
        Product2 testProd = new Product2();
        testProd.name = 'product2';
        insert testProd;

    
        PREV_SetupPMPlan pmPlanCls = new PREV_SetupPMPlan();
        pmPlanCls.getUserInfo();
        PREV_SetupPMPlan.getPMPlanData('{"sourceId":"'+scRec.id +'","mode":"SC"}');
        PREV_SetupPMPlan.getPMPlanData('{"sourceId":"'+ibRec.id +'","mode":"IB"}');
        PREV_SetupPMPlan.getPMPlanData('{"sourceId":"'+testAc.id +'","mode":"Account"}');
        PREV_SetupPMPlan.getPMPlanData('{"sourceId":"'+locRec.id +'","mode":"Location"}');
        PREV_SetupPMPlan.getPMTemplateDetails('{"pmTemplateId":"'+templateRec.id +'","pmPlanDataUpdates":{"serviceContractId":"'+scRec.id +'","accountId":"'+testAc.id +'","startDate":"Invalid date","endDate":"Invalid date"},"mode":"SC"}');
        PREV_SetupPMPlan.getsearchData('{"objAPIName":"Account","searchtext":"abc"}');
        PREV_SetupPMPlan.savePMPlanData('{"sourceId":"'+scRec.id +'","mode":"SC","pmPlanDataUpdates":{"pmPlanName":"Test Pm Plan","endDate":"2017-03-31 00:00:00","startDate":"2017-03-01 00:00:00","pmPlanTemplateId":null,"serviceContractId":"'+scRec.id +'","selectedCovergaeType":"Product (Must Have IB)","slaId":null,"accountId":"'+testAc.id+'","description":"","selectedScheduleType":"Condition Based","coverageList":[],"pmTemplateDetail":{"workOrderPurpose":null,"templateName":null,"templateId":null,"scheduleType":null,"productName":null,"product":null,"installedProductFilter":null,"coverageType":null,"conditionRuleList":[],"advancedExpression":null,"activityDate":null}}}');
        PREV_SetupPMPlan.getCovergaeTechnicalAtt('{"coverageId":"'+ibRec.id+'","productId":"'+ testProd.id +'","pmPlanRecord":{"conditionType":"Usage_Frequency"}}');
        PREV_SetupPMPlan.validateExp('{"conditionRuleList":[{"isRowHasError":false,"conditionRuleId":null,"sequence":"1","selectedField":"","selectedOperator":"EYI","frequency":"1.00","startAt":"2017-06-25","threshold":null,"stopAt":"2017-09-22","selectedAdjustmentType":null,"minAdjustment":null,"maxAdjustment":null,"adjustmentVal":null,"selectedAdjustedUnit":null,"fieldAttType":null,"fieldDataType":"Date","selectedFreqUnit":"Weeks"},{"isRowHasError":false,"conditionRuleId":null,"sequence":"2","selectedField":"SVMXC__Longitude__c","selectedOperator":"EYI","frequency":"1.00","startAt":"0","threshold":null,"stopAt":"250","selectedAdjustmentType":null,"minAdjustment":null,"maxAdjustment":null,"adjustmentVal":null,"selectedAdjustedUnit":null,"fieldAttType":"Schema","fieldDataType":"Number","selectedFreqUnit":"Count"}],"advancedExpression":"1 AND 2"}');
        PREV_SetupPMPlan.createScheduleRec('{"conditionRuleList":[{"isRowHasError":false,"conditionRuleId":null,"sequence":"1","selectedField":"","selectedOperator":"EYI","frequency":"1.00","startAt":"2017-06-25","threshold":null,"stopAt":"2017-09-22","selectedAdjustmentType":null,"minAdjustment":null,"maxAdjustment":null,"adjustmentVal":null,"selectedAdjustedUnit":null,"fieldAttType":null,"fieldDataType":"Date","selectedFreqUnit":"Weeks"},{"isRowHasError":false,"conditionRuleId":null,"sequence":"2","selectedField":"SVMXC__Longitude__c","selectedOperator":"EYI","frequency":"1.00","startAt":"0","threshold":null,"stopAt":"250","selectedAdjustmentType":null,"minAdjustment":null,"maxAdjustment":null,"adjustmentVal":null,"selectedAdjustedUnit":null,"fieldAttType":"Schema","fieldDataType":"Number","selectedFreqUnit":"Count"}],"coverageId":"01t0G000005ZN6AQAW","pmPlanRecord":{"conditionType":"Usage_Frequency","startDate":"2017-07-06 00:00:00","pmTemplateDetail":{"conditionRuleList":[{"isRowHasError":false,"conditionRuleId":null,"sequence":"1","selectedField":"","selectedOperator":"EYI","frequency":"1.00","startAt":"2017-06-25","threshold":null,"stopAt":"2017-09-22","selectedAdjustmentType":null,"minAdjustment":null,"maxAdjustment":null,"adjustmentVal":null,"selectedAdjustedUnit":null,"fieldAttType":null,"fieldDataType":"Date","selectedFreqUnit":"Weeks"},{"isRowHasError":false,"conditionRuleId":null,"sequence":"2","selectedField":"SVMXC__Longitude__c","selectedOperator":"EYI","frequency":"1.00","startAt":"0","threshold":null,"stopAt":"250","selectedAdjustmentType":null,"minAdjustment":null,"maxAdjustment":null,"adjustmentVal":null,"selectedAdjustedUnit":null,"fieldAttType":"Schema","fieldDataType":"Number","selectedFreqUnit":"Count"}]}},"advancedExpression":"1 AND 2","workOrderPurposeId":null}');

        //Get condition grid fields
        PREV_SetupPMPlanImpl objPREV_SetupPMPlanImpl = new PREV_SetupPMPlanImpl();
        objPREV_SetupPMPlanImpl.getConditionGridFields('dummyId', 'Usage_Frequency');

        String strAdvExpr = objPREV_SetupPMPlanImpl.advancedExp(3);
        System.assertEquals(strAdvExpr, '1 AND 2 AND 3');

        //
        Map<String,String> mapUniqOrderSeq = new Map<String,String>();
        for(Integer j=1 ;  j<=5; j++){
            mapUniqOrderSeq.put(String.valueOf(j), '~'+String.valueOf(j));
        }
        String ruleJson = '{"rules":[{"value":null,"stopAt":"2017-09-22","order":"1","operator":"EYI","datatype":"Date","attrValue":"2017-07-04","attrType":"Literal","attrName":"TODAY","attrLabel":null,"adjValue":null,"adjUnit":null,"adjType":null,"adjMin":null,"adjMax":null},{"value":null,"stopAt":"250","order":"2","operator":"EYI","datatype":"Number","attrValue":"0","attrType":"Schema","attrName":"SVMXC__Longitude__c","attrLabel":null,"adjValue":null,"adjUnit":null,"adjType":null,"adjMin":null,"adjMax":null},{"value":null,"stopAt":"2020-07-15","order":"3","operator":"EYI","datatype":"Date","attrValue":"2017-07-04","attrType":"Literal","attrName":"TODAY","attrLabel":null,"adjValue":"","adjUnit":"","adjType":"","adjMin":"","adjMax":""}]}';
        objPREV_SetupPMPlanImpl.actualOpNameMethod(ruleJson, '1 AND 2 AND 3', mapUniqOrderSeq);

        ruleJson = '{"rules":[{"value":"Bangalore","stopAt":null,"order":"1","operator":"eq","datatype":"TEXT","attrValue":null,"attrType":"Schema","attrName":"SVMXC__City__c","attrLabel":"City","adjValue":null,"adjUnit":null,"adjType":null,"adjMin":null,"adjMax":null},{"value":"15","stopAt":null,"order":"2","operator":"gt","datatype":"Number","attrValue":null,"attrType":"Schema","attrName":"SVMXC__Longitude__c","attrLabel":"Longitude","adjValue":null,"adjUnit":null,"adjType":null,"adjMin":null,"adjMax":null},{"value":"Installed","stopAt":null,"order":"3","operator":"eq","datatype":"PICKLIST","attrValue":null,"attrType":"Schema","attrName":"SVMXC__Status__c","attrLabel":"Status","adjValue":null,"adjUnit":null,"adjType":null,"adjMin":null,"adjMax":null},{"value":"2017-07-03","stopAt":null,"order":"4","operator":"lt","datatype":"DATE","attrValue":null,"attrType":"Schema","attrName":"SVMXC__Service_Contract_End_Date__c","attrLabel":"Service Contract End Date","adjValue":null,"adjUnit":null,"adjType":null,"adjMin":null,"adjMax":null}]}';
        objPREV_SetupPMPlanImpl.actualOpNameMethodForCriteria(ruleJson, '(1 AND 2) OR (3 AND 4)', mapUniqOrderSeq);
        //

        objPREV_SetupPMPlanImpl.createIBCoverage(new SVMXC__PM_Plan__c(), new SVMXC__PM_Plan_Template__c(), 'Account');
        objPREV_SetupPMPlanImpl.createIBCoverage(new SVMXC__PM_Plan__c(), new SVMXC__PM_Plan_Template__c(), 'Location');
        objPREV_SetupPMPlanImpl.createIBCoverage(new SVMXC__PM_Plan__c(), new SVMXC__PM_Plan_Template__c(), 'SC');
    }
}