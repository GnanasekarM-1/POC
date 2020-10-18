/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * The PREV_PMAutomation_UT is for unit testing of the class PREV_PMAutomation and PREV_PMAutomationImpl
 *
 * @author Manish Kushwah
 * @version 19.3
 * @since 2019
 */
/*****************************************************************************************************
 *   Name                   Date              Comment
 *****************************************************************************************************
 *   Manish Kushwah         10 October 2019     Created.
 *   Manish Kushwah         16 December 2019    Updated Test methods.
 *****************************************************************************************************/

 @isTest(SeeAllData=true)
 private class PREV_PMAutomation_UT{

    @isTest static void createPMPlanFromAccount_Test1(){
        SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request = new SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest();

        String strPMplanId = createTestDataForAccount();
        request.pmPlanIdList = new List<String>{strPMplanId};
        Test.startTest();
        SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = PREV_PMAutomation.createPMPlanFromAccount(request);
        System.assert(response != null);
        System.assert(response.success == true);

        //already created schedules
        response = PREV_PMAutomation.createPMPlanFromAccount(request);
        System.assert(response != null);
        System.assert(response.success == false);
        Test.stopTest();
    }

    @isTest static void createPMPlanFromAccount_Test2(){
        SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request = new SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest();

        String strPMplanId = createTestDataForAccount();
        request.pmPlanIdList = new List<String>{strPMplanId};
        Test.startTest();

        List<SVMXC__PM_Plan__c> lstPMPlan = [SELECT SVMXC__Coverage_Type__c FROM SVMXC__PM_Plan__c WHERE Id =: strPMplanId];
        if(!lstPMPlan.isEmpty()){
            lstPMPlan[0].SVMXC__Coverage_Type__c = 'Account (Visit Only)';
            update lstPMPlan;

            SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = PREV_PMAutomation.createPMPlanFromAccount(request);
            System.assert(response != null);
            System.assert(response.success == true);
        }
        Test.stopTest();
    }

    @isTest static void createPMPlanFromLOC_Test1(){
        SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request = new SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest();

        String strPMplanId = createTestDataForLocation();
        request.pmPlanIdList = new List<String>{strPMplanId};
        Test.startTest();
        SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = PREV_PMAutomation.createPMPlanFromLOC(request);
        System.assert(response != null);
        System.assert(response.success == true);
        
        //already created schedules
        response = PREV_PMAutomation.createPMPlanFromLOC(request);
        System.assert(response != null);
        System.assert(response.success == false);
        Test.stopTest();
    }
     
     @isTest static void createPMPlanFromLOC_Test2(){
         SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request = new SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest();
         
        String strPMplanId = createTestDataForLocation();
        request.pmPlanIdList = new List<String>{strPMplanId};
        Test.startTest();
        List<SVMXC__PM_Plan__c> lstPMPlan = [SELECT SVMXC__Coverage_Type__c FROM SVMXC__PM_Plan__c WHERE Id =: strPMplanId];
        if(!lstPMPlan.isEmpty()){
            lstPMPlan[0].SVMXC__Coverage_Type__c = 'Account (Visit Only)';
            update lstPMPlan;

            SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = PREV_PMAutomation.createPMPlanFromLOC(request);
            System.assert(response != null);
            System.assert(response.success == true);
        }
        Test.stopTest();
     }

    @isTest static void createPMPlanFromSC_Test1(){
        SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request = new SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest();
        
        String strPMplanId = createTestDataForSC();
        request.pmPlanIdList = new List<String>{strPMplanId};
        Test.startTest();
        SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = PREV_PMAutomation.createPMPlanFromSC(request);
        System.assert(response != null);
        System.assert(response.success == true);
        
        //already created schedules
        response = PREV_PMAutomation.createPMPlanFromSC(request);
        System.assert(response != null);
        System.assert(response.success == false);
        Test.stopTest();
    }
     
    @isTest static void createPMPlanFromSC_Test2(){
         SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request = new SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest();
         
        String strPMplanId = createTestDataForSC();
        request.pmPlanIdList = new List<String>{strPMplanId};
        Test.startTest();
        List<SVMXC__PM_Plan__c> lstPMPlan = [SELECT SVMXC__Coverage_Type__c FROM SVMXC__PM_Plan__c WHERE Id =: strPMplanId];
        if(!lstPMPlan.isEmpty()){
            lstPMPlan[0].SVMXC__Coverage_Type__c = 'Account (Visit Only)';
            update lstPMPlan;

            SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = PREV_PMAutomation.createPMPlanFromSC(request);
            System.assert(response != null);
            System.assert(response.success == true);
        }
        Test.stopTest();
     }

    @isTest static void createPMPlanFromIB_Test1(){
        SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request = new SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest();

        String strPMplanId = createTestDataForIB();
        request.pmPlanIdList = new List<String>{strPMplanId};
        Test.startTest();
        SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = PREV_PMAutomation.createPMPlanFromIB(request);
        System.assert(response != null);
        System.assert(response.success == true);
        
        //already created schedules
        response = PREV_PMAutomation.createPMPlanFromIB(request);
        System.assert(response != null);
        System.assert(response.success == false);
        Test.stopTest();
    }
     
    @isTest static void createPMPlanFromIB_Test_ValidTemplate(){
        SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request = new SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest();

        String strPMplanId = createTestDataForIB();
        request.pmPlanIdList = new List<String>{strPMplanId};
        Test.startTest();
        List<SVMXC__PM_Plan__c> lstPMPlan = [SELECT SVMXC__PM_Plan_Template__c FROM SVMXC__PM_Plan__c WHERE Id =: strPMplanId];
        if(!lstPMPlan.isEmpty()){
            lstPMPlan[0].SVMXC__PM_Plan_Template__c = null;
            update lstPMPlan;

            SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = PREV_PMAutomation.createPMPlanFromIB(request);
            System.assert(response != null);
            System.assert(response.success == false);
        }
        Test.stopTest();
    }
     
    @isTest static void createPMPlanFromIB_Test_ValidSchType(){
        SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request = new SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest();

        String strPMplanId = createTestDataForIB();
        request.pmPlanIdList = new List<String>{strPMplanId};
        Test.startTest();
        List<SVMXC__PM_Plan__c> lstPMPlan = [SELECT SVMXC__Schedule_Type__c FROM SVMXC__PM_Plan__c WHERE Id =: strPMplanId];
        if(!lstPMPlan.isEmpty()){
            lstPMPlan[0].SVMXC__Schedule_Type__c = 'Condition Based';
            update lstPMPlan;

            SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = PREV_PMAutomation.createPMPlanFromIB(request);
            System.assert(response != null);
            System.assert(response.success == false);
        }
        Test.stopTest();
    }

    @isTest static void WrapperClassCover_Test(){
        Test.startTest();
        SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request = new SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest();
        request.pmPlanIdList = new List<String>();

        SVMXC.PREV_PMAutomation.PREV_PMAutomationResult automationResult = new SVMXC.PREV_PMAutomation.PREV_PMAutomationResult();
        automationResult.pmPlanId = 'test';
        automationResult.errorMessage = 'test';
        automationResult.success = false;

        SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = new SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse();
        response.success = true;
        response.message = 'test';
        response.messageType = 'test';
        response.results = new List<SVMXC.PREV_PMAutomation.PREV_PMAutomationResult>{automationResult};
        Test.stopTest();
    }

    static String createTestDataForAccount(){
        Account acc = new Account();
        acc.Name = 'TestAcc';
        insert acc;

        Product2 objProduct = new Product2();
        objProduct.Name = 'Laptop';
        objProduct.ProductCode = 'LAP001';
        objProduct.IsActive = true;
        objProduct.SVMXC__Product_Line__c = 'Accessory';
        objProduct.Family = 'Accessory';
        insert objProduct;

        SVMXC__Installed_Product__c objIB = new SVMXC__Installed_Product__c();
        objIB.SVMXC__Product__c = objProduct.id;
        objIB.SVMXC__Status__c = 'Installed';
        objIB.SVMXC__Date_Installed__c = System.Today().addDays(-10);
        objIB.SVMXC__Company__c = acc.id;
        insert objIB;

        SVMXC__PM_Plan_Template__c objPMTemplate = new SVMXC__PM_Plan_Template__c();
        objPMTemplate.Name = 'TestTemplate';
        objPMTemplate.SVMXC__Coverage_Type__c = 'Product (Must Have IB)';
        objPMTemplate.SVMXC__SM_Schedule_Type__c = 'Time Based';
        insert objPMTemplate;

        SVMXC__PM_Applicable_Product__c objAppProduct = new SVMXC__PM_Applicable_Product__c();
        objAppProduct.SVMXC__Product__c = objProduct.id;
        objAppProduct.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        insert objAppProduct;

        SVMXC__PM_Schedule_Template__c objSchTemplate = new SVMXC__PM_Schedule_Template__c();
        objSchTemplate.SVMXC__Sequence__c = 1.00;
        objSchTemplate.SVMXC__Schedule_Type__c = 'Time Based';
        objSchTemplate.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        objSchTemplate.SVMXC__Frequency__c = 1.00;
        objSchTemplate.SVMXC__Frequency_Unit__c = 'Months';
        objSchTemplate.SVMXC__Recurring__c = true;
        insert objSchTemplate;

        SVMXC__PM_Plan__c objPMplan = new SVMXC__PM_Plan__c();
        objPMplan.Name = 'TestPMPlan';
        objPMplan.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        objPMplan.SVMXC__Start_Date__c = System.Today().addDays(-15);
        objPMplan.SVMXC__End_Date__c = System.Today().addMonths(12);
        objPMplan.SVMXC__Coverage_Type__c = 'Product (Must Have IB)';
        objPMplan.SVMXC__Account__c = acc.id;
        objPMplan.SVMXC__Status__c = 'Active';
        objPMplan.SVMXC__Schedule_Type__c = 'Time Based';
        insert objPMplan;

        return objPMplan.id;
    }
     
     static String createTestDataForLocation(){
        List<RecordType> RTypeList = [SELECT Id, Name from RecordType where SobjectType = 'SVMXC__Site__c' AND RecordType.Name = 'Standard Location'];
        
        Account acc = new Account();
        acc.Name = 'TestAcc';
        insert acc;
        
        SVMXC__Site__c objLocation = new SVMXC__Site__c();
        objLocation.RecordTypeId = RTypeList[0].id;
        objLocation.Name = 'TestLocation';
        objLocation.SVMXC__Street__c = 'MG Road';
        objLocation.SVMXC__City__c = 'Bangalore';
        objLocation.SVMXC__State__c = 'Karnataka';
        objLocation.SVMXC__Country__c = 'India';
        insert objLocation;
         
        Product2 objProduct = new Product2();
        objProduct.Name = 'Laptop';
        objProduct.ProductCode = 'LAP001';
        objProduct.IsActive = true;
        objProduct.SVMXC__Product_Line__c = 'Accessory';
        objProduct.Family = 'Accessory';
        insert objProduct;

        SVMXC__Installed_Product__c objIB = new SVMXC__Installed_Product__c();
        objIB.SVMXC__Product__c = objProduct.id;
        objIB.SVMXC__Status__c = 'Installed';
        objIB.SVMXC__Date_Installed__c = System.Today().addDays(-10);
        objIB.SVMXC__Company__c = acc.id;
        objIB.SVMXC__Site__c = objLocation.id;
        insert objIB;

        SVMXC__PM_Plan_Template__c objPMTemplate = new SVMXC__PM_Plan_Template__c();
        objPMTemplate.Name = 'TestTemplate';
        objPMTemplate.SVMXC__Coverage_Type__c = 'Product (Must Have IB)';
        objPMTemplate.SVMXC__SM_Schedule_Type__c = 'Time Based';
        insert objPMTemplate;

        SVMXC__PM_Applicable_Product__c objAppProduct = new SVMXC__PM_Applicable_Product__c();
        objAppProduct.SVMXC__Product__c = objProduct.id;
        objAppProduct.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        insert objAppProduct;

        SVMXC__PM_Schedule_Template__c objSchTemplate = new SVMXC__PM_Schedule_Template__c();
        objSchTemplate.SVMXC__Sequence__c = 1.00;
        objSchTemplate.SVMXC__Schedule_Type__c = 'Time Based';
        objSchTemplate.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        objSchTemplate.SVMXC__Frequency__c = 1.00;
        objSchTemplate.SVMXC__Frequency_Unit__c = 'Months';
        objSchTemplate.SVMXC__Recurring__c = true;
        insert objSchTemplate;

        SVMXC__PM_Plan__c objPMplan = new SVMXC__PM_Plan__c();
        objPMplan.Name = 'TestPMPlan';
        objPMplan.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        objPMplan.SVMXC__Start_Date__c = System.Today().addDays(-15);
        objPMplan.SVMXC__End_Date__c = System.Today().addMonths(12);
        objPMplan.SVMXC__Coverage_Type__c = 'Location (Must Have Location)';
        objPMplan.SVMXC__Account__c = acc.id;
        objPMplan.SVMXC__Status__c = 'Active';
        objPMplan.SVMXC__Schedule_Type__c = 'Time Based';
        objPMplan.SVMXC__Location__c = objLocation.id;
        insert objPMplan;

        return objPMplan.id;
    }
     
     static String createTestDataForSC(){
        List<RecordType> RTypeList = [SELECT Id, Name from RecordType where SobjectType = 'SVMXC__Site__c' AND RecordType.Name = 'Standard Location'];
        
        Account acc = new Account();
        acc.Name = 'TestAcc';
        insert acc;
        
        SVMXC__Site__c objLocation = new SVMXC__Site__c();
        objLocation.RecordTypeId = RTypeList[0].id;
        objLocation.Name = 'TestLocation';
        objLocation.SVMXC__Street__c = 'MG Road';
        objLocation.SVMXC__City__c = 'Bangalore';
        objLocation.SVMXC__State__c = 'Karnataka';
        objLocation.SVMXC__Country__c = 'India';
        insert objLocation;
         
        Product2 objProduct = new Product2();
        objProduct.Name = 'Laptop';
        objProduct.ProductCode = 'LAP001';
        objProduct.IsActive = true;
        objProduct.SVMXC__Product_Line__c = 'Accessory';
        objProduct.Family = 'Accessory';
        insert objProduct;

        SVMXC__Installed_Product__c objIB = new SVMXC__Installed_Product__c();
        objIB.SVMXC__Product__c = objProduct.id;
        objIB.SVMXC__Status__c = 'Installed';
        objIB.SVMXC__Date_Installed__c = System.Today().addDays(-10);
        objIB.SVMXC__Company__c = acc.id;
        objIB.SVMXC__Site__c = objLocation.id;
        insert objIB;
         
        SVMXC__Service_Contract__c objSC = new SVMXC__Service_Contract__c();
        objSC.Name = 'Test SC';
        objSC.SVMXC__Company__c = acc.id;
        objSC.SVMXC__Active__c = true;
        objSC.SVMXC__Start_Date__c = System.Today().addDays(-15);
        objSC.SVMXC__End_Date__c = System.Today().addMonths(12);
        insert objSC;
        
        SVMXC__Service_Contract_Products__c objCovrdProd = new SVMXC__Service_Contract_Products__c();
        objCovrdProd.SVMXC__Service_Contract__c = objSC.id;
        objCovrdProd.SVMXC__Start_Date__c = System.Today();
        objCovrdProd.SVMXC__End_Date__c = System.Today().addMonths(2);
        objCovrdProd.SVMXC__Installed_Product__c = objIB.id;
        insert objCovrdProd;
        
        SVMXC__PM_Plan_Template__c objPMTemplate = new SVMXC__PM_Plan_Template__c();
        objPMTemplate.Name = 'TestTemplate';
        objPMTemplate.SVMXC__Coverage_Type__c = 'Product (Must Have IB)';
        objPMTemplate.SVMXC__SM_Schedule_Type__c = 'Time Based';
        insert objPMTemplate;

        SVMXC__PM_Applicable_Product__c objAppProduct = new SVMXC__PM_Applicable_Product__c();
        objAppProduct.SVMXC__Product__c = objProduct.id;
        objAppProduct.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        insert objAppProduct;

        SVMXC__PM_Schedule_Template__c objSchTemplate = new SVMXC__PM_Schedule_Template__c();
        objSchTemplate.SVMXC__Sequence__c = 1.00;
        objSchTemplate.SVMXC__Schedule_Type__c = 'Time Based';
        objSchTemplate.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        objSchTemplate.SVMXC__Frequency__c = 1.00;
        objSchTemplate.SVMXC__Frequency_Unit__c = 'Months';
        objSchTemplate.SVMXC__Recurring__c = true;
        insert objSchTemplate;

        SVMXC__PM_Plan__c objPMplan = new SVMXC__PM_Plan__c();
        objPMplan.Name = 'TestPMPlan';
        objPMplan.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        objPMplan.SVMXC__Start_Date__c = System.Today().addDays(-15);
        objPMplan.SVMXC__End_Date__c = System.Today().addMonths(12);
        objPMplan.SVMXC__Coverage_Type__c = 'Product (Must Have IB)';
        objPMplan.SVMXC__Account__c = acc.id;
        objPMplan.SVMXC__Status__c = 'Active';
        objPMplan.SVMXC__Schedule_Type__c = 'Time Based';
        objPMplan.SVMXC__Service_Contract__c = objSC.id;
        insert objPMplan;

        return objPMplan.id;
    }
     
     static String createTestDataForIB(){
        List<RecordType> RTypeList = [SELECT Id, Name from RecordType where SobjectType = 'SVMXC__Site__c' AND RecordType.Name = 'Standard Location'];
        
        Account acc = new Account();
        acc.Name = 'TestAcc';
        insert acc;
        
        SVMXC__Site__c objLocation = new SVMXC__Site__c();
        objLocation.RecordTypeId = RTypeList[0].id;
        objLocation.Name = 'TestLocation';
        objLocation.SVMXC__Street__c = 'MG Road';
        objLocation.SVMXC__City__c = 'Bangalore';
        objLocation.SVMXC__State__c = 'Karnataka';
        objLocation.SVMXC__Country__c = 'India';
        insert objLocation;
         
        Product2 objProduct = new Product2();
        objProduct.Name = 'Laptop';
        objProduct.ProductCode = 'LAP001';
        objProduct.IsActive = true;
        objProduct.SVMXC__Product_Line__c = 'Accessory';
        objProduct.Family = 'Accessory';
        insert objProduct;

        SVMXC__Installed_Product__c objIB = new SVMXC__Installed_Product__c();
        objIB.SVMXC__Product__c = objProduct.id;
        objIB.SVMXC__Status__c = 'Installed';
        objIB.SVMXC__Date_Installed__c = System.Today().addDays(-10);
        objIB.SVMXC__Company__c = acc.id;
        objIB.SVMXC__Site__c = objLocation.id;
        insert objIB;
        
        SVMXC__PM_Plan_Template__c objPMTemplate = new SVMXC__PM_Plan_Template__c();
        objPMTemplate.Name = 'TestTemplate';
        objPMTemplate.SVMXC__Coverage_Type__c = 'Product (Must Have IB)';
        objPMTemplate.SVMXC__SM_Schedule_Type__c = 'Time Based';
        insert objPMTemplate;

        SVMXC__PM_Applicable_Product__c objAppProduct = new SVMXC__PM_Applicable_Product__c();
        objAppProduct.SVMXC__Product__c = objProduct.id;
        objAppProduct.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        insert objAppProduct;

        SVMXC__PM_Schedule_Template__c objSchTemplate = new SVMXC__PM_Schedule_Template__c();
        objSchTemplate.SVMXC__Sequence__c = 1.00;
        objSchTemplate.SVMXC__Schedule_Type__c = 'Time Based';
        objSchTemplate.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        objSchTemplate.SVMXC__Frequency__c = 1.00;
        objSchTemplate.SVMXC__Frequency_Unit__c = 'Months';
        objSchTemplate.SVMXC__Recurring__c = true;
        insert objSchTemplate;

        SVMXC__PM_Plan__c objPMplan = new SVMXC__PM_Plan__c();
        objPMplan.Name = 'TestPMPlan';
        objPMplan.SVMXC__PM_Plan_Template__c = objPMTemplate.id;
        objPMplan.SVMXC__Start_Date__c = System.Today().addDays(-15);
        objPMplan.SVMXC__End_Date__c = System.Today().addMonths(12);
        objPMplan.SVMXC__Coverage_Type__c = 'Product (Must Have IB)';
        objPMplan.SVMXC__Account__c = acc.id;
        objPMplan.SVMXC__Status__c = 'Active';
        objPMplan.SVMXC__Schedule_Type__c = 'Time Based';
        insert objPMplan;
        
        SVMXC__PM_Coverage__c objPMCov = new SVMXC__PM_Coverage__c();
        objPMCov.SVMXC__PM_Plan__c = objPMplan.id;
        objPMCov.SVMXC__Product_Name__c = objIB.id;
        insert objPMCov;
        
        return objPMplan.id;
    }
}