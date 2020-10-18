@isTest(seeAllData = true)
private class SMAX_OptiMax_EngineUtils_UT{
    static String dispatchprocessId;
    static String territoryId;
        
        static testMethod void SMAX_OptiMax_EngineUtils_UnitTest()
    {
        test.startTest();
        SMAX_OptiMax_EngineUtils c = new SMAX_OptiMax_EngineUtils();
        SMAX_OptiMax_EngineUtils.stachRank sr = new SMAX_OptiMax_EngineUtils.stachRank();
        list<Id> lstWorkOrderIds = new List<Id>();
        list<SVMXC__Service_Order__c> lstWorkOrders = new list<SVMXC__Service_Order__c>();
        Id id;
        map<Id, list<SMAX_OptiMax_EngineUtils.stachRank>> mapWorkOrderStackRank = new map<Id, list<SMAX_OptiMax_EngineUtils.stachRank>>();      
        set<Id> setTechnicianIds = new set<Id>();       
        
        // update for Setting value SORG001_SET002
        List<string> lstSetIds = new List<string>();
        lstSetIds.add('SORG001_SET002');
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfig = [SELECT id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Unique_ID__c IN: lstSetIds];
        system.debug('================' + lstConfig);
        for(SVMXC__ServiceMax_Config_Data__c config : lstConfig)
        {
            config.SVMXC__Display_Value__c = 'TRUE';
            config.SVMXC__Internal_Value__c = 'TRUE';
        }
        update lstConfig;
        
        SVMXC__Service_Group__c objGroup = new SVMXC__Service_Group__c();
        objGroup.Name = 'TestGroup';
        objGroup.SVMXC__Active__c = true;
        objGroup.SVMXC__Select__c = true;
        insert objGroup;
        System.assertEquals(objGroup.Name,'TestGroup');
        
        c.buildQualifiedTechnicians(lstWorkOrderIds, lstWorkOrders, id);
        
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
        objTerritory.Name = 'TestTerritory';
        insert objTerritory;
        System.assertEquals(objTerritory.Name,'TestTerritory');
        
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        objTechnician.Name = 'TestTechnician';
        objTechnician.SVMXC__Service_Group__c = objGroup.id;
        objTechnician.SVMXC__Active__c = true;
        objTechnician.SVMXC__Service_Territory__c = objTerritory.id;
        insert objTechnician;
        System.assertEquals(objTechnician.Name,'TestTechnician');
        
        setTechnicianIds.add(objTechnician.id);
        
        SVMXC__Service_Order__c objWorkOrder1 = new SVMXC__Service_Order__c();
        objWorkOrder1.SVMXC__Preferred_Technician__c = objTechnician.id;
        SVMXC__Service_Order__c objWorkOrder2 = new SVMXC__Service_Order__c();
        objWorkOrder2.SVMXC__Preferred_Technician__c = objTechnician.id;
        lstWorkOrders.add(objWorkOrder1);
        lstWorkOrders.add(objWorkOrder2);
        insert lstWorkOrders;
        System.assertEquals(lstWorkOrders.size(),2);
        
        lstWorkOrderIds.add(objWorkOrder1.id);
        lstWorkOrderIds.add(objWorkOrder2.id);
        id = objTerritory.id;           
        
        SVMXC__ServiceMax_Processes__c pro = new SVMXC__ServiceMax_Processes__c();
        pro.SVMXC__ProcessID__c = 'testingDispatch';
        pro.SVMXC__Name__c = 'testingDispatch';
        pro.SVMXC__Weight_Tech_Eligibility__c = 12323;
        pro.SVMXC__Weight_Skill_Match__c = 12323;
        pro.SVMXC__Weight_Product_Specialization__c = 12323;
        pro.SVMXC__Weight_Preferred_Technician__c = 12323;
        pro.RecordTypeId = [select id from RecordType where Name = 'Contract Billing Process'].Id;
                
        SVMXC__ServiceMax_Processes__c pro1 = new SVMXC__ServiceMax_Processes__c();
        pro1.RecordTypeId = [select id from RecordType where Name = 'SVMX Rule'].Id;
        pro1.SVMXC__Rule_Type__c = 'Skill Matching';
        pro1.SVMXC__Active__c = true;
        insert pro1;
        System.assertEquals(pro1.id != null, true);
        
        SVMXC__ServiceMax_Processes__c pro2 = new SVMXC__ServiceMax_Processes__c();
        pro2.RecordTypeId = [select id from RecordType where Name = 'SVMX Rule'].Id;
        pro2.SVMXC__Rule_Type__c = 'Skill Matching';
        pro2.SVMXC__Active__c = true;
        pro2.SVMXC__Node_Parent__c = pro1.id;
                
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        lstProcess.add(pro);
        lstProcess.add(pro2);
        insert lstProcess;
        System.assertEquals(lstProcess.size(), 2);
        
        map<Id, SVMXC__ServiceMax_Processes__c> mapRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        String expressionType;
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();        
        SVMXC__ServiceMax_Config_Data__c objConfigData = new SVMXC__ServiceMax_Config_Data__c();
        objConfigData.RecordTypeId = [select id from RecordType where Name = 'Applicable Skills'].Id;
        objConfigData.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objConfigData.SVMXC__Expression_Rule__c = pro.Id;
        objConfigData.SVMXC__Required__c = true;
        objConfigData.SVMXC__Sequence__c = 1;
        objConfigData.SVMXC__Operator__c = '+';
        objConfigData.SVMXC__Operand__c = 'a';
        objConfigData.SVMXC__Target_Field_Name__c = 'SVMXC__Preferred_Technician__c';
                
        SVMXC__ServiceMax_Config_Data__c objConfigData1 = new SVMXC__ServiceMax_Config_Data__c();
        objConfigData1.RecordTypeId = [select id from RecordType where Name = 'Expressions'].Id;        
        objConfigData1.SVMXC__Expression_Type__c = 'Tech_Eligibility';
        objConfigData1.SVMXC__Expression_Rule__c = pro1.Id;
        objConfigData1.SVMXC__Required__c = true;
        objConfigData1.SVMXC__Sequence__c = 1;
        objConfigData1.SVMXC__Operator__c = '+';
        objConfigData1.SVMXC__Operand__c = 'a';
        objConfigData1.SVMXC__Target_Field_Name__c = 'SVMXC__Preferred_Technician__c';
                
        SVMXC__ServiceMax_Config_Data__c objConfigData2 = new SVMXC__ServiceMax_Config_Data__c();
        objConfigData2.RecordTypeId = [select id from RecordType where Name = 'Applicable Skills'].Id;
        objConfigData2.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objConfigData2.SVMXC__Expression_Rule__c = pro2.Id;
        objConfigData2.SVMXC__Required__c = true;
        objConfigData2.SVMXC__Sequence__c = 1;
        objConfigData2.SVMXC__Operator__c = '+';
        objConfigData2.SVMXC__Operand__c = 'a';
        objConfigData2.SVMXC__Target_Field_Name__c = 'SVMXC__Preferred_Technician__c';
        
        lstConfigData.add(objConfigData);
        lstConfigData.add(objConfigData1);
        lstConfigData.add(objConfigData2);
        insert lstConfigData;
        System.assertEquals(lstConfigData.size(), 3);
                
        mapRules.put(pro1.id, pro1);
        expressionType = 'Skill_Eligibility';
        c.getWorkOrderExpression(mapRules, expressionType);
        
        expressionType = 'Tech_Eligibility';
        c.getWorkOrderExpression(mapRules, expressionType);
        
        SVMXC__Skill__c objSkill = new SVMXC__Skill__c();
        objSkill.SVMXC__Active__c = true;
        objSkill.SVMXC__Select__c = true;
        insert objSkill;
        System.assertEquals(objSkill.id != null, true);
        
        SVMXC__Service_Group_Skills__c objGroupSkill = new SVMXC__Service_Group_Skills__c();
        objGroupSkill.SVMXC__Skill__c = objSkill.Id;
        objGroupSkill.SVMXC__Skill_Level__c = 23;
        objGroupSkill.SVMXC__Group_Member__c = objTechnician.id;
        objGroupSkill.SVMXC__Availability_Start_Date__c = date.today();
        objGroupSkill.SVMXC__Availability_End_Date__c =  date.today().addDays(1);       
        objGroupSkill.SVMXC__Service_Group__c = objGroup.id;
        insert objGroupSkill;
        System.assertEquals(objGroupSkill.id != null, true);
        
        c.getDispatchProcessProperties(pro.Id);
        //c.getDispatchProcessProperties(null);
        c.buildQualifiedTechnicians(lstWorkOrderIds, lstWorkOrders, id);        
        c.scoreProcessor(mapWorkOrderStackRank);
        c.buildSkillScore(lstWorkOrders,setTechnicianIds);
        
        list<Product2> lstProduct = new list<Product2>();
        Product2 p1 = new Product2();
        p1.Name = 'TestProduct';
        p1.Family = 'testfamily';
        p1.SVMXC__Product_Line__c = 'testline';
        lstProduct.add(p1);
        insert lstProduct;
        System.assertEquals(lstProduct.size(), 1);
        
        SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch multiCriteriaTechMatchObject = new SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch();
        
        SVMXC__Service_Group_Product__c objGroupProduct = new SVMXC__Service_Group_Product__c();
        objGroupProduct.SVMXC__Product__c = p1.id;
        objGroupProduct.SVMXC__Service_Group__c = objGroup.id;
        objGroupProduct.SVMXC__Group_Member__c = objTechnician.id;
        insert objGroupProduct; 
        System.assertEquals(objGroupProduct.id != null, true);
        c.buildQualifiedTechnicians(lstWorkOrderIds, lstWorkOrders, id);
        c.isProductSpecializationMatchesProduct(objGroupProduct, lstProduct);
        multiCriteriaTechMatchObject.isProductSpecializationMatchesProduct(objGroupProduct, lstProduct);
        
        SVMXC__Service_Group_Product__c objGroupProduct1 = new SVMXC__Service_Group_Product__c();
        objGroupProduct1.SVMXC__Service_Group__c = objGroup.id;
        objGroupProduct1.SVMXC__Product_Family__c = p1.Family;
        objGroupProduct1.SVMXC__Group_Member__c = objTechnician.id;
        insert objGroupProduct1;
        System.assertEquals(objGroupProduct1.id != null, true);
        c.isProductSpecializationMatchesProduct(objGroupProduct1, lstProduct);
        multiCriteriaTechMatchObject.isProductSpecializationMatchesProduct(objGroupProduct, lstProduct);
        
        SVMXC__Service_Group_Product__c objGroupProduct2 = new SVMXC__Service_Group_Product__c();
        objGroupProduct2.SVMXC__Service_Group__c = objGroup.id;
        objGroupProduct2.SVMXC__Product_Line__c = p1.SVMXC__Product_Line__c;
        objGroupProduct2.SVMXC__Group_Member__c = objTechnician.id;
        insert objGroupProduct2;
        System.assertEquals(objGroupProduct2.id != null, true);
        c.isProductSpecializationMatchesProduct(objGroupProduct2, lstProduct);   
        multiCriteriaTechMatchObject.isProductSpecializationMatchesProduct(objGroupProduct, lstProduct);
        lstProduct.clear();
        c.isProductSpecializationMatchesProduct(objGroupProduct2, lstProduct);
        multiCriteriaTechMatchObject.isProductSpecializationMatchesProduct(objGroupProduct, lstProduct);
        
        list<SVMXC__ServiceMax_Config_Data__c> eligibilities = new list<SVMXC__ServiceMax_Config_Data__c>();
        String strAdvanceExpression = 'T';
        eligibilities.add(objConfigData);
        eligibilities.add(objConfigData1);
        eligibilities.add(objConfigData2);
        c.matchTechnicianEligibility(objTechnician, objWorkOrder1, eligibilities, strAdvanceExpression);
        
        test.stopTest();
    }
    static testMethod void SMAX_OptiMax_EngineUtils_UnitTest1()
    {
        test.startTest();
        SMAX_OptiMax_EngineUtils objSMAX_OptiMax_EngineUtils = new SMAX_OptiMax_EngineUtils();
        SMAX_OptiMax_EngineUtils.techAddress objtechAddress = new SMAX_OptiMax_EngineUtils.techAddress();
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where IsActive = true limit 2];
        SVMXC__Service_Group__c objGroup = new SVMXC__Service_Group__c();
        objGroup.Name = 'TestGroup';
        objGroup.SVMXC__Active__c = true;
        objGroup.SVMXC__Select__c = true;
        insert objGroup;
        
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
        objTerritory.Name = 'TestTerritory';
        insert objTerritory;
        System.assertEquals(objTerritory.Name,'TestTerritory');
        
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        objTechnician.Name = 'TestTechnician';
        objTechnician.SVMXC__Service_Group__c = objGroup.id;
        objTechnician.SVMXC__Active__c = true;
        objTechnician.SVMXC__City__c = 'Bangalore';
        objTechnician.SVMXC__Service_Territory__c = objTerritory.id;
        objTechnician.SVMXC__Working_Hours__c = lBH[0].id;
        insert objTechnician;
            SVMXC__Service_Group_Members__c objTechnician1 = new SVMXC__Service_Group_Members__c();
        objTechnician1.Name = 'TestTechnician1';
        objTechnician1.SVMXC__Service_Group__c = objGroup.id;
        objTechnician1.SVMXC__Active__c = true;
        objTechnician1.SVMXC__City__c = 'Bangalore';
        objTechnician1.SVMXC__Service_Territory__c = objTerritory.id;
        objTechnician1.SVMXC__Working_Hours__c = lBH[1].id;
        objTechnician1.SVMXC__Salesforce_User__c = Userinfo.getUserId();
        insert objTechnician1;

            SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c();
        objTechnician2.Name = 'TestTechnician2';
        objTechnician2.SVMXC__Service_Group__c = objGroup.id;
        objTechnician2.SVMXC__Active__c = true;
        objTechnician2.SVMXC__City__c = 'Bangalore';
        objTechnician2.SVMXC__Service_Territory__c = objTerritory.id;
        objTechnician2.SVMXC__Working_Hours__c=lBH[1].id;
        objTechnician2.SVMXC__Enable_Scheduling__c = true;
        insert objTechnician2;
        
        SMAX_OptiMax_EngineUtils.techAddress objtechAddress1 = new SMAX_OptiMax_EngineUtils.techAddress(objTechnician.id,'Mg road bangalore',12.975174,77.607995);
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
        svmxprocess.SVMXC__Name__c = 'Optimized Batch DisPatch Pro';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Optimized Batch';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c= date.Today()+1;
        svmxprocess.SVMXC__Schedule_Event__c = true;
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        insert svmxprocess;
        List<SVMXC__ServiceMax_Config_Data__c> configLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='Open';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        configLst.add(oConf);
        insert configLst;
        
        list<SVMXC__Service_Order__c> lstWO1 = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c nWO1 = new SVMXC__Service_Order__c();
        nWO1.SVMXC__Zip__c = '11111';           
        nWO1.SVMXC__Order_Status__c='Open';
        nWO1.SVMXC__Priority__c='Low';
        nWO1.SVMXC__Order_Type__c='Field Service';
        nWO1.SVMXC__Purpose_of_Visit__c='Repair';
        nWO1.SVMXC__Billing_Type__c = 'Contract';
        nWO1.SVMXC__City__c = 'Bangalore';
        nWO1.SVMXC__Group_Member__c = objTechnician.id;
        nWO1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        nWO1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        nWO1.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO1.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO1.SVMXC__Locked_By_DC__c = false;
        nWO1.SVMXC__Service_Duration__c = 60;
        nWO1.Driving_Time__c = 60;
        lstWO1.add(nWO1);
        SVMXC__Service_Order__c nWO2 = new SVMXC__Service_Order__c();
        nWO2.SVMXC__Zip__c = '11111';           
        nWO2.SVMXC__Order_Status__c='Open';
        nWO2.SVMXC__Priority__c='Low';
        nWO2.SVMXC__Order_Type__c='Field Service';
        nWO2.SVMXC__Purpose_of_Visit__c='Repair';
        nWO2.SVMXC__Billing_Type__c = 'Contract';
        nWO2.SVMXC__City__c = 'Bangalore';
        nWO2.SVMXC__Group_Member__c = objTechnician1.id;
        nWO2.SVMXC__Scheduled_Date_Time__c = datetime.now();
        nWO2.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        nWO2.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO2.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO2.SVMXC__Locked_By_DC__c = false;
        nWO2.SVMXC__Service_Duration__c = 60;
        nWO2.Driving_Time__c = 60;
        lstWO1.add(nWO2);
        
        SVMXC__Service_Order__c nWO3 = new SVMXC__Service_Order__c();
        nWO3.SVMXC__Zip__c = '11111';           
        nWO3.SVMXC__Order_Status__c='Open';
        nWO3.SVMXC__Priority__c='Low';
        nWO3.SVMXC__Order_Type__c='Field Service';
        nWO3.SVMXC__Purpose_of_Visit__c='Repair';
        nWO3.SVMXC__Billing_Type__c = 'Contract';
        nWO3.SVMXC__City__c = 'Bangalore';
        nWO3.SVMXC__Group_Member__c = objTechnician2.id;
        nWO3.SVMXC__Scheduled_Date_Time__c = datetime.now();
        nWO3.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        nWO3.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO3.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO3.SVMXC__Locked_By_DC__c = true;
        nWO3.SVMXC__Service_Duration__c = 60;
        nWO3.Driving_Time__c = 60;
        lstWO1.add(nWO3);
        insert lstWO1;
        
        INTF_WebServicesDef.INTF_StringMap strMap1 = new INTF_WebServicesDef.INTF_StringMap();
        strMap1.key = 'WORKORDERID';
        strMap1.value = nWO1.id;
        INTF_WebServicesDef.INTF_StringMap strMap2 = new INTF_WebServicesDef.INTF_StringMap();
        strMap2.key = 'DISPATCHPROCESSID';
        strMap2.value = svmxprocess.id;
        INTF_WebServicesDef.INTF_StringMap strMap3 = new INTF_WebServicesDef.INTF_StringMap();
        strMap3.key = 'TERRITORYID';
        strMap3.value = objTerritory.id;
        list<INTF_WebServicesDef.INTF_StringMap> lststringMap = new list<INTF_WebServicesDef.INTF_StringMap>();
        lststringMap.add(strMap1);
        lststringMap.add(strMap2);
        lststringMap.add(strMap3);
        INTF_WebServicesDef.INTF_Request req = new INTF_WebServicesDef.INTF_Request();
        req.stringMap = lststringMap;
                SVMXC__ServiceMax_Processes__c svmxEligprocess = new SVMXC__ServiceMax_Processes__c();
        svmxEligprocess.SVMXC__Name__c = 'Test Eligibility';
        svmxEligprocess.RecordTypeId = RuleRecordTypeId;
        svmxEligprocess.SVMXC__Rule_Type__c = 'Tech Eligibility';
        insert svmxEligprocess;
        SVMXC__ServiceMax_Processes__c svmxSkillprocess = new SVMXC__ServiceMax_Processes__c();
        svmxSkillprocess.SVMXC__Name__c = 'Test Skill Match';
        svmxSkillprocess.RecordTypeId = RuleRecordTypeId;
        svmxSkillprocess.SVMXC__Rule_Type__c = 'Skill Matching';
        insert svmxSkillprocess;
        SVMXC__ServiceMax_Processes__c svmxSkillprochild = new SVMXC__ServiceMax_Processes__c();
        svmxSkillprochild.SVMXC__Name__c = 'Test Skill Match1';
        svmxSkillprochild.RecordTypeId = RuleRecordTypeId;
        svmxSkillprochild.SVMXC__Rule_Type__c = 'Skill Matching';
        svmxSkillprochild.SVMXC__Node_Parent__c = svmxSkillprocess.id;
        insert svmxSkillprochild;
        List<SVMXC__ServiceMax_Config_Data__c> configLst1 = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c confelg = new SVMXC__ServiceMax_Config_Data__c(
        RecordTypeId =ExpressionRTypeId,
        SVMXC__Expression_Rule__c = svmxEligprocess.id,
        SVMXC__Active__c = true,
        SVMXC__Field_Name__c = 'SVMXC__Order_Status__c',
        SVMXC__Operator__c = 'eq',
        SVMXC__Operand__c = 'Open',
        SVMXC__Expression_Type__c = 'Tech_Eligibility',
        SVMXC__Sequence__c = 1.0,
        SVMXC__Display_Type__c ='STRING'   
        );
        configLst1.add(confelg);
        SVMXC__ServiceMax_Config_Data__c confelgMatch = new SVMXC__ServiceMax_Config_Data__c(
        RecordTypeId =ExpressionRTypeId,
        SVMXC__Expression_Rule__c = svmxEligprocess.id,
        SVMXC__Active__c = true,
        SVMXC__Field_Name__c = 'SVMXC__City__c',
        SVMXC__Target_Field_Name__c = 'SVMXC__City__c',
        SVMXC__Operator__c = 'eq',
        SVMXC__Expression_Type__c = 'Tech_Match',
        SVMXC__Sequence__c = 1.0,
        SVMXC__Display_Type__c ='STRING'   
        );
        configLst1.add(confelgMatch);
        SVMXC__Skill__c testskill = new SVMXC__Skill__c();
        testskill.Name ='TestSkill';
        testskill.SVMXC__Active__c =true;
        insert testskill;
        SVMXC__Skill__c testskill1 = new SVMXC__Skill__c();
        testskill1.Name ='TestSkill1';
        testskill1.SVMXC__Active__c =true;
        insert testskill1;
        SVMXC__ServiceMax_Config_Data__c confSkill = new SVMXC__ServiceMax_Config_Data__c(
        RecordTypeId =ExpressionRTypeId,
        SVMXC__Expression_Rule__c = svmxSkillprocess.id,
        SVMXC__Active__c = true,
        SVMXC__Field_Name__c = 'SVMXC__Order_Status__c',
        SVMXC__Operator__c = 'eq',
        SVMXC__Operand__c = 'Open',
        SVMXC__Expression_Type__c = 'Skill_Eligibility',
        SVMXC__Sequence__c = 1.0,
        SVMXC__Display_Type__c ='STRING'   
        );
        configLst1.add(confSkill);
        SVMXC__ServiceMax_Config_Data__c confSkill1 = new SVMXC__ServiceMax_Config_Data__c(
        RecordTypeId =ExpressionRTypeId,
        SVMXC__Expression_Rule__c = svmxSkillprocess.id,
        SVMXC__Active__c = true,
        SVMXC__Skill__c = testskill.id,
        SVMXC__Minimum_Level__c = 4,
        SVMXC__Required__c = true,
        SVMXC__Expression_Type__c = 'Applicable Skills',
        SVMXC__Sequence__c = 1.0 
        );
        configLst1.add(confSkill1);
        
        SVMXC__ServiceMax_Config_Data__c confSkill2 = new SVMXC__ServiceMax_Config_Data__c(
        RecordTypeId =ExpressionRTypeId,
        SVMXC__Expression_Rule__c = svmxSkillprocess.id,
        SVMXC__Active__c = true,
        SVMXC__Skill__c = testskill1.id,
        SVMXC__Minimum_Level__c = 4,
        SVMXC__Expression_Type__c = 'Applicable Skills',
        SVMXC__Sequence__c = 1.0 
        );
        configLst1.add(confSkill2);
        SVMXC__ServiceMax_Config_Data__c confSkillChild = new SVMXC__ServiceMax_Config_Data__c(
        RecordTypeId =ExpressionRTypeId,
        SVMXC__Expression_Rule__c = svmxSkillprochild.id,
        SVMXC__Active__c = true,
        SVMXC__Field_Name__c = 'SVMXC__City__c',
        SVMXC__Operator__c = 'eq',
        SVMXC__Operand__c = 'Bangalore',
        SVMXC__Expression_Type__c = 'Skill_Eligibility',
        SVMXC__Sequence__c = 1.0,
        SVMXC__Display_Type__c ='STRING'   
        );
        configLst1.add(confSkillChild);
        SVMXC__ServiceMax_Config_Data__c confSkillChild1 = new SVMXC__ServiceMax_Config_Data__c(
        RecordTypeId =ExpressionRTypeId,
        SVMXC__Expression_Rule__c = svmxSkillprochild.id,
        SVMXC__Active__c = true,
        SVMXC__Skill__c = testskill.id,
        SVMXC__Minimum_Level__c = 4,
        SVMXC__Required__c = true,
        SVMXC__Expression_Type__c = 'Applicable Skills',
        SVMXC__Sequence__c = 1.0 
        );
        configLst1.add(confSkillChild1);
        insert configLst1;
        SVMXC__Service_Group_Skills__c TechExpertise = new SVMXC__Service_Group_Skills__c();
        TechExpertise.SVMXC__Skill__c = testskill.id;
        TechExpertise.SVMXC__Skill_Level__c = 5;
        TechExpertise.SVMXC__Service_Group__c = objGroup.id;
        TechExpertise.SVMXC__Group_Member__c = objTechnician.id;
        insert TechExpertise;
        SVMXC__Service_Group_Skills__c TechExpertise1 = new SVMXC__Service_Group_Skills__c();
        TechExpertise1.SVMXC__Skill__c = testskill1.id;
        TechExpertise1.SVMXC__Skill_Level__c = 5;
        TechExpertise1.SVMXC__Service_Group__c = objGroup.id;
        TechExpertise1.SVMXC__Group_Member__c = objTechnician.id;
        insert TechExpertise1;
        
    
        list<SVMXC__Service_Group_Members__c> lstTechnicians = new list<SVMXC__Service_Group_Members__c> ();
        lstTechnicians.add(objTechnician);
        lstTechnicians.add(objTechnician1);
        lstTechnicians.add(objTechnician2);
        set<Id> setTechnicianIds = new set<Id>();
        setTechnicianIds.add(objTechnician.id);
        setTechnicianIds.add(objTechnician1.id);
        setTechnicianIds.add(objTechnician2.id);
        
        Event e1 = new Event();
    e1.ActivityDate = system.today();
    e1.StartDateTime =system.now().addminutes(-120);
    e1.endDateTime =system.now().addminutes(-60);
    e1.ActivityDateTime = e1.StartDateTime;
    e1.Subject = 'test';
    e1.OwnerId = Userinfo.getUserId(); 
    e1.WhatId=nWO1.Id;
    e1.Description='Test Desc';
    insert e1;

     SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c();
    SMAX_Event1.SVMXC__ActivityDate__c = system.today();
    SMAX_Event1.SVMXC__ActivityDateTime__c = system.now().addminutes(-120);
    SMAX_Event1.SVMXC__StartDateTime__c = system.now().addminutes(-60);
    SMAX_Event1.SVMXC__DurationInMinutes__c = 60;
    SMAX_Event1.SVMXC__EndDateTime__c = system.now().addminutes(120);
    SMAX_Event1.SVMXC__Technician__c = objTechnician1.Id;
    SMAX_Event1.SVMXC__WhatId__c = nWO1.Id;
    insert SMAX_Event1;
                      
        Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();    

        ////////////////////////
        list<BusinessHours> lstBusinessHours = new list<BusinessHours>();
        SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
                    
        lstBusinessHours = [Select Id, IsDefault,IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                            from BusinessHours
                            where IsActive = TRUE];
        lstBusinessHours = clsOMaxExtension.getCompleteBusinessHour(lstBusinessHours);
        for(BusinessHours bh : lstBusinessHours)
        {
            mapBusinessHours.put(bh.Id, bh);
            
        }
        ////////////////////////

        objSMAX_OptiMax_EngineUtils.OMAX_BuildQualifiedTechnicians_WS(req);
        objSMAX_OptiMax_EngineUtils.findCurrentTechnicianLocation(lstTechnicians,system.now(),mapBusinessHours);
        objSMAX_OptiMax_EngineUtils.buildSkills(lstWO1);
        SMAX_OptiMax_Engine_WS.Expertise_WP objExpertise_WP = new SMAX_OptiMax_Engine_WS.Expertise_WP();
        list<SMAX_OptiMax_Engine_WS.Expertise_WP> lstExpertise_WP = new list<SMAX_OptiMax_Engine_WS.Expertise_WP>();
        lstExpertise_WP.add(objExpertise_WP);
    SMAX_OptiMax_Engine_WS.Product_WP objProduct_WP = new SMAX_OptiMax_Engine_WS.Product_WP();
    list<SMAX_OptiMax_Engine_WS.Product_WP> lstProduct_WP = new list<SMAX_OptiMax_Engine_WS.Product_WP>();
    lstProduct_WP.add(objProduct_WP);
    SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now().addminutes(-60),System.now());
    list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstExecutionTime_WP = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
    lstExecutionTime_WP.add(objExecutionTime_WP);
    SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP = new SMAX_OptiMax_Engine_WS.Technician_WP(objTechnician,lstExecutionTime_WP,lstProduct_WP,lstExpertise_WP,null);
    objSMAX_OptiMax_EngineUtils.updateTechnicianCurrentAddress(objTechnician_WP,objtechAddress1);  
    objSMAX_OptiMax_EngineUtils.buildSkillScore(lstWO1,setTechnicianIds);
    objSMAX_OptiMax_EngineUtils.getRunType(lBH[0],true);
     objSMAX_OptiMax_EngineUtils.getRunType(lBH[0],false);
    
    //Sandeep
    SMAX_OptiMax_EngineUtils.techAddress techAddressObj = new SMAX_OptiMax_EngineUtils.techAddress();
    objSMAX_OptiMax_EngineUtils.updateTechnicianCurrentAddress(objTechnician_WP,techAddressObj);
        

    test.stopTest();
    }
    
    
    static testMethod void buildQualifiedTechnicians_Test() {
    Test.startTest();
    //Creating data 
    list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ]; 
        if(lstSettingValues != null && lstSettingValues.size() > 0){
            lstSettingValues[0].SVMXC__Internal_Value__c='True';
            //upsert lstSettingValues;
        }

        map<string, Map<String, String>> svmxSettingListTest = new map<string, Map<String, String>>();
        map<String,String> settingValues = new map<String,String>();
        settingValues.put('SET014','True');
        svmxSettingListTest.put('OMAX001',settingValues);
        SVMX_Constants.AllsvmxSettingList = svmxSettingListTest;

        case c = new case();
        Account account = new Account(
                                                Name ='Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                ); 
        insert account;
        System.assertEquals('Account', account.Name);
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        
        Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
        insert contact;
        System.assertEquals('Last', contact.LastName);
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c(Name= 'Territory2',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory2',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=1.0,SVMXC__Max_Distance__c=5,SVMXC__Average_Speed__c=70.0);
        insert Territory2;
        
        territoryId = Territory2.Id;
        set<String> setTerritoryIds = new set<String>();
        setTerritoryIds.add(territoryId);
        
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType];
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c = '11111111';
        oConf.SVMXC__Operator__c = 'eq';
        oConf.SVMXC__Expression_Rule__c = svmxprocess.Id;
        
        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               svmxprocess.RecordTypeId = rt.ID;
            } 
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
            } 
        }
        
        svmxprocess.SVMXC__Territory__c = Territory2.Id;
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess.SVMXC__Weight_Node_Type__c =1;
        svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess.SVMXC__Frequency__c =1;
        svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess.SVMXC__Tolerance__c = 30;
        svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess;
        dispatchprocessId = svmxprocess.Id;
        
        List<SVMXC__Service_Order__c> lstQTLWo = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c workOrderQTL = new SVMXC__Service_Order__c();
        workOrderQTL.SVMXC__Case__c = c.Id;
        workOrderQTL.SVMXC__Company__c = account.Id;
        workOrderQTL.SVMXC__Contact__c =contact.Id;
        workOrderQTL.SVMXC__Latitude__c = 40.739582;
        workOrderQTL.SVMXC__Longitude__c = -73.980772;
        workOrderQTL.SVMXC__Street__c = 'Street1';
        workOrderQTL.SVMXC__City__c = 'BANGALORE';
        workOrderQTL.SVMXC__State__c = 'Karnataka';
        workOrderQTL.SVMXC__Country__c = 'India';
        workOrderQTL.SVMXC__Zip__c = '11111111';
        workOrderQTL.SVMXC__Order_Status__c = 'Open';
        workOrderQTL.SVMXC__Priority__c = 'Medium';
        workOrderQTL.SVMXC__Order_Type__c = 'Field Service';
        workOrderQTL.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
        workOrderQTL.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrderQTL.SVMXC__Primary_Territory__c = Territory2.Id;
        workOrderQTL.SVMXC__OptiMax_status__c = '';
        workOrderQTL.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrderQTL.SVMXC__Dispatch_Process__c = dispatchprocessId;
        workOrderQTL.SVMXC__Service_Duration__c = 6000;
        workOrderQTL.SVMXC__Locked_By_DC__c = true;
        workOrderQTL.SVMXC__Scheduled_Date_Time__c  = system.now().addDays(3);
        lstQTLWo.add(workOrderQTL);

        SVMXC__Service_Order__c workOrderQTL1 = new SVMXC__Service_Order__c();
        workOrderQTL1.SVMXC__Case__c = c.Id;
        workOrderQTL1.SVMXC__Company__c = account.Id;
        workOrderQTL1.SVMXC__Contact__c =contact.Id;
        workOrderQTL1.SVMXC__Latitude__c = 40.739582;
        workOrderQTL1.SVMXC__Longitude__c = -73.980772;
        workOrderQTL1.SVMXC__Street__c = 'Street1';
        workOrderQTL1.SVMXC__City__c = 'DELHI';
        workOrderQTL1.SVMXC__State__c = 'Karnataka';
        workOrderQTL1.SVMXC__Country__c = 'India';
        workOrderQTL1.SVMXC__Zip__c = '11111111';
        workOrderQTL1.SVMXC__Order_Status__c = 'Open';
        workOrderQTL1.SVMXC__Priority__c = 'Medium';
        workOrderQTL1.SVMXC__Order_Type__c = 'Field Service';
        workOrderQTL1.SVMXC__Purpose_of_Visit__c = 'Training';
        workOrderQTL1.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
        workOrderQTL1.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrderQTL1.SVMXC__Primary_Territory__c = Territory2.Id;
        workOrderQTL1.SVMXC__OptiMax_status__c = '';
        workOrderQTL1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrderQTL1.SVMXC__Dispatch_Process__c = dispatchprocessId;
        workOrderQTL1.SVMXC__Service_Duration__c = 6000;
        workOrderQTL1.SVMXC__Locked_By_DC__c = true;
        workOrderQTL1.SVMXC__Scheduled_Date_Time__c  = system.now().addDays(3);
        lstQTLWo.add(workOrderQTL1);

        insert lstQTLWo;
        
        //Create technicans
        SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c();
        sgroup.SVMXC__Country__c = 'India';
        sgroup.SVMXC__City__c = 'Bangalore';
        Insert sgroup;
        System.assertEquals('India', sgroup.SVMXC__Country__c);
        
        SVMXC__Skill__c objSkillnstallation = new SVMXC__Skill__c();
        objSkillnstallation.Name = 'SkillInstall2';
        objSkillnstallation.SVMXC__Skill_Category__c = 'Installation';
        insert objSkillnstallation;

        SVMXC__Skill__c objSkillnstallation1 = new SVMXC__Skill__c();
        objSkillnstallation1.Name = 'SkillInstall3';
        objSkillnstallation1.SVMXC__Skill_Category__c = 'Installation';
        insert objSkillnstallation1;
        
        List<SVMXC__Service_Group_Members__c> technicians= new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
        tech1.SVMXC__Service_Territory__c =Territory2.Id;
        tech1.SVMXC__Fixed_Cost__c = 2.0;
        tech1.SVMXC__Latitude_Home__c = 37.407843;
        tech1.SVMXC__Longitude_Home__c = -122.008637;
        tech1.SVMXC__Street__c = 'Street 1';
        tech1.SVMXC__City__c = 'Bangalore';
        tech1.SVMXC__State__c = 'Karnataka';
        tech1.SVMXC__Zip__c = '11111111';
        tech1.SVMXC__Country__c = 'India';
        tech1.SVMXC__Per_hour_Cost__c = 2.0; 
        tech1.SVMXC__Per_Mile_Cost__c = 1.0;
        tech1.SVMXC__Average_Speed__c = 2.0;
        tech1.SVMXC__Max_Daily_Hours__c = 2.0;
        tech1.SVMXC__Max_Distance__c = 5.0;
        tech1.SVMXC__Enable_Scheduling__c = true;
        tech1.SVMXC__Service_Group__c =sgroup.Id; 
        if(lBH != NULL && lBH.size()>0)
            tech1.SVMXC__Working_Hours__c = lBH[0].id;
        tech1.SVMXC__Active__c  = true;
        technicians.add(tech1);

        SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
        tech.SVMXC__Service_Territory__c = Territory2.Id;
        tech.SVMXC__Fixed_Cost__c = 2.0;
        tech.SVMXC__Latitude_Home__c = 37.407843;
        tech.SVMXC__Longitude_Home__c = -122.008637;
        tech.SVMXC__Street__c = 'Street 1';
        tech.SVMXC__City__c = 'Bangalore';
        tech.SVMXC__State__c = 'Karnataka';
        tech.SVMXC__Zip__c = '11111111';
        tech.SVMXC__Country__c = 'India';
        tech.SVMXC__Per_hour_Cost__c = 2.0; 
        tech.SVMXC__Per_Mile_Cost__c = 1.0;
        tech.SVMXC__Average_Speed__c = 2.0;
        tech.SVMXC__Max_Daily_Hours__c = 2.0;
        tech.SVMXC__Max_Distance__c = 5.0;
        tech.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        tech.SVMXC__Enable_Scheduling__c = true;
        tech.SVMXC__Service_Group__c = sgroup.Id; 
        tech.SVMXC__Active__c  = true;
        if(lBH != NULL && lBH.size()>0)
            tech.SVMXC__Working_Hours__c = lBH[0].id;
        technicians.add(tech);
        Insert technicians;
        
        SVMXC__Service_Group_Skills__c skillForTech = new SVMXC__Service_Group_Skills__c(SVMXC__Service_Group__c = sgroup.Id, SVMXC__Skill__c = objSkillnstallation.Id, SVMXC__Group_Member__c = tech.Id);
        SVMXC__Service_Group_Skills__c skillForTech1 = new SVMXC__Service_Group_Skills__c(SVMXC__Service_Group__c = sgroup.Id, SVMXC__Skill__c = objSkillnstallation.Id, SVMXC__Group_Member__c = tech.Id, SVMXC__Skill_Level__c = 9.0);
        insert skillForTech;
        insert skillForTech1;

        //Create Eligibility Matching Rules
        Id eligibilityProcessId;
        Id eligibilityExpressionId;
        Id skillProcessId;
        Id skillExpressionId;
        Id applicableSkillRectypeId;
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'SVMX Rule' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
                eligibilityProcessId = rt.Id;
                skillProcessId = rt.Id;
            }
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                eligibilityExpressionId = rt.Id;
                skillExpressionId = rt.Id;
            }
            if(rt.Name == 'Applicable Skills' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                applicableSkillRectypeId = rt.Id;
            }
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstRuleProcess = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstRuleExpressionConf = new list<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_1 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_1.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Name__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Description__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Select__c = true;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objEligibilityRule_1.SVMXC__Sequence__c = 1.0000;
        lstRuleProcess.add(objEligibilityRule_1);
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_1 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_1.SVMXC__Name__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Description__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Select__c = true;               
        objSkillMatchingRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_1.SVMXC__Sequence__c = 0.0000;
        objSkillMatchingRule_1.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_1.RecordTypeId = skillProcessId;
        lstRuleProcess.add(objSkillMatchingRule_1);
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_2 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_2.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Name__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Description__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Select__c = false;
        objEligibilityRule_2.SVMXC__Sequence__c = 2.0000;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        lstRuleProcess.add(objEligibilityRule_2);
        
        insert lstRuleProcess;
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_2 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_2.SVMXC__Name__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Description__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Select__c = false;
        objSkillMatchingRule_2.SVMXC__Sequence__c = 1.0000;
        objSkillMatchingRule_2.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_2.RecordTypeId = skillProcessId;
        objSkillMatchingRule_2.SVMXC__Node_Parent__c = objSkillMatchingRule_1.Id;
        insert objSkillMatchingRule_2;
        
        SVMXC__ServiceMax_Config_Data__c objEligibilityCriteria = new  SVMXC__ServiceMax_Config_Data__c();
        objEligibilityCriteria.RecordTypeId = eligibilityExpressionId;
        objEligibilityCriteria.SVMXC__Expression_Type__c = 'Tech_Eligibility';
        objEligibilityCriteria.SVMXC__Expression_Rule__c = objEligibilityRule_1.id;
        objEligibilityCriteria.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objEligibilityCriteria.SVMXC__Operator__c = 'eq';
        objEligibilityCriteria.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objEligibilityCriteria);
        
        SVMXC__ServiceMax_Config_Data__c objSkillEligibility_1 = new  SVMXC__ServiceMax_Config_Data__c();
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.RecordTypeId = skillExpressionId;
        objSkillEligibility_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objSkillEligibility_1.SVMXC__Operator__c = 'eq';
        objSkillEligibility_1.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objSkillEligibility_1); 
        
        SVMXC__ServiceMax_Config_Data__c skilApplicable_1 = new  SVMXC__ServiceMax_Config_Data__c();
        skilApplicable_1.SVMXC__Skill__c = objSkillnstallation.id;
        skilApplicable_1.RecordTypeId = applicableSkillRectypeId;
        skilApplicable_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;        
        lstRuleExpressionConf.add(skilApplicable_1);

        SVMXC__ServiceMax_Config_Data__c skilApplicable_2 = new  SVMXC__ServiceMax_Config_Data__c();
        skilApplicable_2.SVMXC__Skill__c = objSkillnstallation1.id;
        skilApplicable_2.RecordTypeId = applicableSkillRectypeId;
        skilApplicable_2.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;        
        lstRuleExpressionConf.add(skilApplicable_2);
        
        insert lstRuleExpressionConf;       
                        
        SVMXC__ServiceMax_Processes__c dProcess = new SVMXC__ServiceMax_Processes__c();
        dProcess.RecordTypeId = [select id from RecordType where Name = 'SVMX Rule'].Id;
        dProcess.SVMXC__Rule_Type__c = 'Skill Matching';
        dProcess.SVMXC__Weight_Tech_Eligibility__c = 12323;
        dProcess.SVMXC__Weight_Skill_Match__c = 12323;
        dProcess.SVMXC__Weight_Product_Specialization__c = 12323;
        dProcess.SVMXC__Weight_Preferred_Technician__c = 12323;
        dProcess.SVMXC__Active__c = true;
        insert dProcess;
           
        map<Id, SVMXC__ServiceMax_Processes__c> mapDP = new map<Id, SVMXC__ServiceMax_Processes__c>();
        
        mapDP.put(dProcess.id, dProcess);
        
        SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch clsQTLComputation = new SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch();
        map<string, Map<String, String>> mapAllSettings=SVMX_Constants.AllsvmxSettingList;
        clsQTLComputation.buildQualifiedTechnicians(lstQTLWo,mapAllSettings,setTerritoryIds,mapDP);
        
        
        map<Id, SVMXC__ServiceMax_Processes__c> mapWorkOrdersDP = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, list<SMAX_OptiMax_EngineUtils.stachRank>> mapWorkOrderStackRank1 = new map<Id, list<SMAX_OptiMax_EngineUtils.stachRank>>();  
        SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch smaxEngineUtils = new SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch();      
        smaxEngineUtils.scoreProcessor(mapWorkOrderStackRank1, mapWorkOrdersDP);
                
        Test.stopTest();   
        
    }    
    
    // Technician Violation
    static testMethod void SMAX_OptiMax_EngineUtils_UnitTestForTechnicianViolations()
    {
    
        test.startTest();
        
        String jobId;
    
        //Creating data 
        case c = new case();
        Account account = new Account(
                                                Name ='Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                ); 
        insert account;
        System.assertEquals('Account', account.Name);
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        
        Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
        insert contact;
        System.assertEquals('Last', contact.LastName);  
        
        SVMXC__Territory__c T1 = new SVMXC__Territory__c(Name= 'T1',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'T1',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=2.0,SVMXC__Max_Distance__c=100,SVMXC__Average_Speed__c=50.0);
        insert T1;
        territoryId = T1.Id;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c = '11111111';
        oConf.SVMXC__Operator__c = 'eq';
        oConf.SVMXC__Expression_Rule__c =svmxprocess.Id;
        
        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               svmxprocess.RecordTypeId = rt.ID;
            }
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
            } 
        }
        
        svmxprocess.SVMXC__Territory__c = T1.Id;
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess.SVMXC__Weight_Node_Type__c =1;
        svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess.SVMXC__Frequency__c =1;
        svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess.SVMXC__Tolerance__c = 60;
        svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess;
        dispatchprocessId = svmxprocess.Id;
        System.assertEquals(true, svmxprocess != null);
        
        insert oConf;
        System.assertEquals(true, oConf != null);
        
        List<SVMXC__Service_Order__c> Wo_List = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Case__c = c.Id;
        workOrder1.SVMXC__Company__c = account.Id;
        workOrder1.SVMXC__Contact__c =contact.Id;
        workOrder1.SVMXC__Latitude__c = 40.739582;
        workOrder1.SVMXC__Longitude__c = -73.980772;
        workOrder1.SVMXC__Street__c = 'Street1';
        workOrder1.SVMXC__City__c = 'BANGALORE';
        workOrder1.SVMXC__State__c = 'Karnataka';
        workOrder1.SVMXC__Country__c = 'India';
        workOrder1.SVMXC__Zip__c = '11111111';
        workOrder1.SVMXC__Order_Status__c = 'Open';
        workOrder1.SVMXC__Priority__c = 'Medium';
        workOrder1.SVMXC__Order_Type__c = 'Field Service';
        workOrder1.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
        workOrder1.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrder1.SVMXC__Primary_Territory__c = T1.Id;
        workOrder1.SVMXC__OptiMax_status__c = '';
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Dispatch_Process__c = svmxprocess.Id;
        workOrder1.SVMXC__Service_Duration__c = 6000;
        workOrder1.SVMXC__Locked_By_DC__c = true;
        workOrder1.SVMXC__Scheduled_Date_Time__c = system.today();
        workOrder1.SVMXC__Driving_Time__c = 30;
        workOrder1.SVMXC__Qualified_Technicians__c = '[{"valid":false,"tName":"MizaLatLong","tech":"a1DF0000008fpCZMAY","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza1","tech":"a1DF0000008fusxMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza2","tech":"a1DF0000008fut2MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza3","tech":"a1DF0000008fut7MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza4","tech":"a1DF0000008fvCeMAI","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"TestTech","tech":"a1DF0000008fz6yMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10}]';
        Wo_List.add(workOrder1);
        
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Case__c = c.Id;
        workOrder2.SVMXC__Company__c = account.Id;
        workOrder2.SVMXC__Contact__c =contact.Id;
        workOrder2.SVMXC__Latitude__c = 40.739582;
        workOrder2.SVMXC__Longitude__c = -73.980772;
        workOrder2.SVMXC__Street__c = 'Street1';
        workOrder2.SVMXC__City__c = 'BANGALORE';
        workOrder2.SVMXC__State__c = 'Karnataka';
        workOrder2.SVMXC__Country__c = 'India';
        workOrder2.SVMXC__Zip__c = '11111111';
        workOrder2.SVMXC__Order_Status__c = 'Open';
        workOrder2.SVMXC__Priority__c = 'Medium';
        workOrder2.SVMXC__Order_Type__c = 'Field Service';
        workOrder2.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
        workOrder2.SVMXC__Preferred_Start_Time__c = system.now().addDays(-2);
        workOrder2.SVMXC__Preferred_End_Time__c = system.now().addDays(5);
        workOrder2.SVMXC__Primary_Territory__c = T1.Id;
        workOrder2.SVMXC__OptiMax_status__c = '';
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder2.SVMXC__Dispatch_Process__c = svmxprocess.Id;
        workOrder2.SVMXC__Service_Duration__c = 50000;
        workOrder2.SVMXC__Locked_By_DC__c = true;
        Wo_List.add(workOrder2);
        //Insert workOrder2;
        insert Wo_List;
        System.assertEquals(true, Wo_List != null);
        
        //SMAX_OptiMax_Engine_WS.WorkOrder_WP woTEST = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrder1);
        
        
        SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c();
        sgroup.SVMXC__Country__c = 'India';
        sgroup.SVMXC__City__c = 'Bangalore';
        Insert sgroup;
        System.assertEquals('India', sgroup.SVMXC__Country__c);
        
        SVMXC__Skill__c objSkillCreation = new SVMXC__Skill__c();
        objSkillCreation.Name = 'Configuration';
        objSkillCreation.SVMXC__Skill_Category__c = 'Installation';       
        insert objSkillCreation;
        
        SVMXC__Skill__c objSkillCreation1 = new SVMXC__Skill__c();
        objSkillCreation1.Name = 'Repair1';
        objSkillCreation1.SVMXC__Skill_Category__c = 'Configuration';       
        insert objSkillCreation1;
        
                
        List<SVMXC__Service_Group_Members__c> technicians= new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
        tech1.SVMXC__Service_Territory__c =T1.Id;
        ////tech.SVMXC__Salesforce_User__c = UserId.Id;
        tech1.SVMXC__Fixed_Cost__c = 2.0;
        tech1.SVMXC__Latitude_Home__c = 37.407843;
        tech1.SVMXC__Longitude_Home__c = -122.008637;
        tech1.SVMXC__Street__c = 'Street 1';
        tech1.SVMXC__City__c = 'Bangalore';
        tech1.SVMXC__State__c = 'Karnataka';
        tech1.SVMXC__Zip__c = '11111111';
        tech1.SVMXC__Country__c = 'India';
        tech1.SVMXC__Per_hour_Cost__c = 2.0; 
        tech1.SVMXC__Per_Mile_Cost__c = 1.0;
        tech1.SVMXC__Average_Speed__c = 2.0;
        tech1.SVMXC__Max_Daily_Hours__c = 2.0;
        tech1.SVMXC__Max_Distance__c = 5.0;
        // tech1.SVMXC__Max_Weekly_Hours__c = 7.0;
        // tech1.SVMXC__Capacity__c = 1.0;
        tech1.SVMXC__Enable_Scheduling__c = true;
        tech1.SVMXC__Service_Group__c =sgroup.Id; 
        if(lBH != NULL && lBH.size()>0)
        tech1.SVMXC__Working_Hours__c = lBH[0].id;
        technicians.add(tech1);
        
        SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
        tech.SVMXC__Service_Territory__c =T1.Id;
        ////tech.SVMXC__Salesforce_User__c = UserId.Id;
        tech.SVMXC__Fixed_Cost__c = 2.0;
        tech.SVMXC__Latitude_Home__c = 37.407843;
        tech.SVMXC__Longitude_Home__c = -122.008637;
        tech.SVMXC__Street__c = 'Street 1';
        tech.SVMXC__City__c = 'Bangalore';
        tech.SVMXC__State__c = 'Karnataka';
        tech.SVMXC__Zip__c = '11111111';
        tech.SVMXC__Country__c = 'India';
        tech.SVMXC__Per_hour_Cost__c = 2.0; 
        tech.SVMXC__Per_Mile_Cost__c = 1.0;
        tech.SVMXC__Average_Speed__c = 2.0;
        tech.SVMXC__Max_Daily_Hours__c = 2.0;
        tech.SVMXC__Max_Distance__c = 5.0;
        tech.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        // tech.SVMXC__Max_Weekly_Hours__c = 7.0;
        // tech.SVMXC__Capacity__c = 1.0;
        tech.SVMXC__Enable_Scheduling__c = true;
        tech.SVMXC__Service_Group__c =sgroup.Id; 
        if(lBH != NULL && lBH.size()>0)
        tech.SVMXC__Working_Hours__c = lBH[0].id;
        technicians.add(tech);
                
        Insert technicians;
        
        List<Event> SF_Event_L = new List<Event>();
        Event SF_Event = new Event();
        SF_Event.ActivityDate = System.today();
        SF_Event.ActivityDateTime = System.now();
        SF_Event.StartDateTime = SF_Event.ActivityDateTime;
        SF_Event.DurationInMinutes = 60;
        SF_Event.EndDateTime = System.now().addHours(1);
        SF_Event.OwnerId = UserInfo.getUserId();
        SF_Event_L.add(SF_Event);
        Event SF_Event2 = new Event();
        SF_Event2.ActivityDate = System.today().addDays(1);
        SF_Event2.ActivityDateTime = System.now().addDays(1);
        SF_Event2.StartDateTime = SF_Event2.ActivityDateTime;
        SF_Event2.DurationInMinutes = 60;
        SF_Event2.EndDateTime = System.now().addHours(1).addDays(1);
        SF_Event2.OwnerId = UserInfo.getUserId();
        SF_Event_L.add(SF_Event2);
        //insert SF_Event_L;
        System.assertEquals(true, SF_Event_L != null);
        
        System.debug('Just before Initiate Job:1');
        SVMXC__Skill__c sk = new SVMXC__Skill__c(Name = 'TEST');
        insert sk;
        SVMXC__Service_Group_Skills__c gmS = new SVMXC__Service_Group_Skills__c(SVMXC__Group_Member__c = tech.Id, SVMXC__Skill__c = sk.Id, SVMXC__Service_Group__c = sgroup.Id);
        insert gmS;
        Product2 prod = new Product2(Name = 'TP');
        insert prod;
        SVMXC__Service_Group_Product__c gmP = new SVMXC__Service_Group_Product__c(SVMXC__Group_Member__c = tech.Id, SVMXC__Product__c = prod.Id, SVMXC__Service_Group__c = sgroup.Id);
        insert gmP;
        
        //SMAX_OptiMax_Engine_WS OmaxEngineWs = new SMAX_OptiMax_Engine_WS();
        System.debug('Just before Initiate Job:2');
        //Initiate Jobs
        SMAX_OptiMax_Engine_WS.opInitateJobs_WP OmaxEngineWsInitjobs = new SMAX_OptiMax_Engine_WS.opInitateJobs_WP();
        OmaxEngineWsInitjobs.getworkOrder_LWP();
        OmaxEngineWsInitjobs.gettechnician_LWP();
        OmaxEngineWsInitjobs.getExec_SettingsMap();
        
        SVMXC__Service_Group_Members__c t = new SVMXC__Service_Group_Members__c();
        List<Time> ListeventTime = new List<Time>();
        List<Product2> products = new List<Product2>();
        List<SVMXC__Service_Group_Skills__c> skills = new List<SVMXC__Service_Group_Skills__c>();
        
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP OmaxEngineWsET = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
        List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstWsET = new List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        SMAX_OptiMax_Engine_WS.Product_WP OmaxEngineWsProd = new SMAX_OptiMax_Engine_WS.Product_WP();
        List<SMAX_OptiMax_Engine_WS.Product_WP> lstprodwp = new List<SMAX_OptiMax_Engine_WS.Product_WP>();
        SMAX_OptiMax_Engine_WS.Expertise_WP OmaxEngineWsExp = new SMAX_OptiMax_Engine_WS.Expertise_WP();
        List<SMAX_OptiMax_Engine_WS.Expertise_WP> lstExpwp = new List<SMAX_OptiMax_Engine_WS.Expertise_WP>();
        
        SMAX_OptiMax_Engine_WS.Technician_WP OmaxEngineWsTechws = new SMAX_OptiMax_Engine_WS.Technician_WP(t,lstWsET,lstprodwp,lstExpwp); 
        OmaxEngineWsTechws.gettechProduct_WPL();
        OmaxEngineWsTechws.gettechExpertise_WPL();
        SMAX_OptiMax_Engine_WS.ExcSetting_WP OmaxEngineWsEset = new SMAX_OptiMax_Engine_WS.ExcSetting_WP();
        
        //Oncomplete Jobs WS
        List<SVMXC__SVMX_Jobs__c> lstJobs = new list<SVMXC__SVMX_Jobs__c>();
        SVMXC__SVMX_Jobs__c jobs = new SVMXC__SVMX_Jobs__c();
        jobs.SVMXC__SVMX_Process__c = svmxprocess.Id;
        jobs.SVMXC__Territory__c = T1.Id;
        jobs.SVMXC__Age__c = 2000;
        jobs.SVMXC__Start_Time__c =system.now();
        jobs.SVMXC__OptiMax_Message__c = 'In Progress';
        jobs.SVMXC__End_Time__c =  system.now().addDays(1);
        jobs.SVMXC__Message__c = workOrder1.Id+'~|~'+SF_Event_L[0].Id;
        lstJobs.add(jobs);
        
        SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
        job1.SVMXC__SVMX_Process__c = svmxprocess.Id;
        job1.SVMXC__Territory__c = T1.Id;
        job1.SVMXC__OptiMax_Message__c = 'In Progress';
        job1.SVMXC__Start_Time__c = system.now();
        lstJobs.add(job1);
        
        SVMXC__SVMX_Jobs__c job2 = new SVMXC__SVMX_Jobs__c();
        job2.SVMXC__SVMX_Process__c = svmxprocess.Id;
        job2.SVMXC__Territory__c = T1.Id;
        job2.SVMXC__OptiMax_Message__c = 'In Progress';
        job2.SVMXC__Start_Time__c = system.now().addDays(-2);
        lstJobs.add(job2);
        
        insert lstJobs;
        System.assertEquals(true, jobs != null);
        
        //Violation info
        List<SMAX_OptiMax_Engine_WS.Violations_WP> woViolations = new List<SMAX_OptiMax_Engine_WS.Violations_WP>();
        SMAX_OptiMax_Engine_WS.Violations_WP woViolation = new SMAX_OptiMax_Engine_WS.Violations_WP();
        woViolation.attribute='Node';
        woViolation.category='Time Constraints';
        woViolation.value='Time Exceded';
        woViolations.add(woViolation);
        
        //Desination info
        SMAX_OptiMax_Engine_WS.DestinationNodes_WP dest1 = new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
        dest1.sequenceNo = 1;
        dest1.workorderId = workOrder1.Id;
        dest1.arraivalTime = system.now()-10;
        dest1.departureTime = system.now()-5;
        dest1.drivingTime = 5;
        dest1.violations_WPL=woViolations;
        List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP> dest_O1 = new List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP>();
        dest_O1.add(dest1);
        //Desination info
        SMAX_OptiMax_Engine_WS.DestinationNodes_WP dest2 = new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
        dest2.sequenceNo = 1;
        dest2.workorderId = workOrder2.Id + '_' + SF_Event2.Id;
        dest2.arraivalTime = system.now()-10;
        dest2.departureTime = system.now()-5;
        dest2.drivingTime = 5;
        dest2.violations_WPL=woViolations;
        List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP> dest_O2 = new List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP>();
        dest_O2.add(dest2);
        
        //Route Info
        SMAX_OptiMax_Engine_WS.Route_WP route1 = new SMAX_OptiMax_Engine_WS.Route_WP();
        route1.routeId = 'ROUTE1';
        route1.resourceId = tech.Id+'_DAY1';
        route1.destinationNodes_WPL = dest_O1;
        //Route Info
        SMAX_OptiMax_Engine_WS.Route_WP route2 = new SMAX_OptiMax_Engine_WS.Route_WP();
        route2.routeId = 'ROUTE1';
        route2.resourceId = tech1.Id+'_DAY1';
        route2.destinationNodes_WPL = dest_O2;
        
        List<SMAX_OptiMax_Engine_WS.Route_WP> routes = new List<SMAX_OptiMax_Engine_WS.Route_WP>();
        routes.add(route1);
        routes.add(route2);
        
        SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP OmaxEngineWsipcompjobs = new SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP();
        OmaxEngineWsipcompjobs.dispatchProcessId = svmxprocess.Id; 
        OmaxEngineWsipcompjobs.territoryId = T1.Id;
        OmaxEngineWsipcompjobs.jobId = jobs.id;
        OmaxEngineWsipcompjobs.gettotalRouteTime_WP();
        OmaxEngineWsipcompjobs.settotalRouteTime_WP(OmaxEngineWsipcompjobs.totalRouteTime_WP);
        OmaxEngineWsipcompjobs.route_WPL=routes;
        System.debug('TEST LOG101:'+OmaxEngineWsipcompjobs.getroute_WPL());
        OmaxEngineWsipcompjobs.getstatics_WPL();
        OmaxEngineWsipcompjobs.setstatics_WPL(OmaxEngineWsipcompjobs.statics_WPL);
        OmaxEngineWsipcompjobs.getexeLog_WPL();
        OmaxEngineWsipcompjobs.setexeLog_WPL(OmaxEngineWsipcompjobs.exeLog_WPL);
        
        List<SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP> WO_LatLng_L = new List<SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP>();
        SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP WO_LatLng = new SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP();
        WO_LatLng.workOrderId = workOrder2.Id;
        WO_LatLng.location = new SMAX_OptiMax_Engine_WS.Location_WP('0','0');
        WO_LatLng_L.add(WO_LatLng);
        OmaxEngineWsipcompjobs.workOrder_WPL = WO_LatLng_L;
        
        SMAX_OptiMax_Engine_WS.TotalRouteTime_WP OmaxEngineWsTrTime = new SMAX_OptiMax_Engine_WS.TotalRouteTime_WP();
        SMAX_OptiMax_Engine_WS.Route_WP OmaxEngineWsRWP = new SMAX_OptiMax_Engine_WS.Route_WP();
        OmaxEngineWsRWP.routeId= 'abcd';
        OmaxEngineWsRWP.resourceId= 'abcd';
               
        OmaxEngineWsRWP.getviolations_WPL();
        OmaxEngineWsRWP.setviolations_WPL(OmaxEngineWsRWP.getviolations_WPL());
        OmaxEngineWsRWP.getdestinationNodes_WPL();

        SMAX_OptiMax_Engine_WS.DestinationNodes_WP  OmaxEngineWsDnwp= new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
        OmaxEngineWsDnwp.violations_WPL=woViolations;
        OmaxEngineWsDnwp.workorderId=workOrder1.Id;
        OmaxEngineWsDnwp.getviolations_WP();
        OmaxEngineWsDnwp.setviolations_WPL(OmaxEngineWsDnwp.getviolations_WP());
        
        List<SMAX_OptiMax_Engine_WS.ExeLog_WP> lstOmaxEngineWsELp = new List<SMAX_OptiMax_Engine_WS.ExeLog_WP>();
        
        SMAX_OptiMax_Engine_WS.Statics_WP OmaxEngineWsSwp = new SMAX_OptiMax_Engine_WS.Statics_WP();
        SMAX_OptiMax_Engine_WS.ExeLog_WP OmaxEngineWsELp = new SMAX_OptiMax_Engine_WS.ExeLog_WP();
        OmaxEngineWsELp.logLevel = -1;
        OmaxEngineWsELp.message = 'No work orders available';
        lstOmaxEngineWsELp.add(OmaxEngineWsELp);
        SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP OmaxEngineWsODl = new SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP();
        SMAX_OptiMax_Engine_WS.TechnicianDetail_WP OmaxEngineWsOD2 = new SMAX_OptiMax_Engine_WS.TechnicianDetail_WP();
        ////SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(UserId.Id,T1.Id,svmxprocess.Id);
        //SMAX_OptiMax_Engine_WS.SMAX_Complete_OptiMax_Job_WS(OmaxEngineWsipcompjobs);
        
        //Get the list of all the active Business Hours and put them in a map
        String strDefaultBHourId;
        list<BusinessHours> lstBusinessHours = new list<BusinessHours>();
        Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();
        SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
                    
        lstBusinessHours = [Select Id, IsDefault,IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                            from BusinessHours
                            where IsActive = TRUE];
        lstBusinessHours = clsOMaxExtension.getCompleteBusinessHour(lstBusinessHours);
        for(BusinessHours bh : lstBusinessHours)
        {
            mapBusinessHours.put(bh.Id, bh);
            if(bh.IsDefault == TRUE)
                strDefaultBHourId=bh.Id;
        }
        
        List<SVMXC__Service_Group_Members__c> lstOptiMaxOPTechs= new List<SVMXC__Service_Group_Members__c>();
        
        lstOptiMaxOPTechs = [Select Id, Name, SVMXC__Working_Hours__c, SVMXC__Service_Group__r.SVMXC__Email__c, SVMXC__Salesforce_User__c, SVMXC__Enable_Scheduling__c,
                                SVMXC__Service_Group__c, SVMXC__Email__c
                                from SVMXC__Service_Group_Members__c
                                where SVMXC__Active__c = TRUE];   
                                
        
        String strLogger = '';
        SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils omaxViolationUtils = new SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils();
        String strTechnicianViolations = omaxViolationUtils.checkViolations(workOrder1, OmaxEngineWsipcompjobs.jobId, mapBusinessHours, svmxprocess, lstOptiMaxOPTechs, strLogger, strDefaultBHourId);
        omaxViolationUtils.getOMAX002TAG001();
        omaxViolationUtils.getOMAX002TAG002();
        omaxViolationUtils.getOMAX002TAG003();
        omaxViolationUtils.getOMAX002TAG004();
        omaxViolationUtils.getOMAX002TAG005();
        omaxViolationUtils.getOMAX002TAG006();
        omaxViolationUtils.getOMAX002TAG008();

        //Sandeep
        SVMXC__Skill__c Skillobj = new SVMXC__Skill__c();
        Skillobj.Name = 'HardWare';
        Skillobj.SVMXC__Skill_Category__c = 'Installation';       
        insert Skillobj;
        
        SMAX_OptiMax_EngineUtils.skill skill1 = new SMAX_OptiMax_EngineUtils.skill(Skillobj.id,'Hardware', true, 3);
        
        SVMXC__Skill__c Skillobj2 = new SVMXC__Skill__c();
        Skillobj2.Name = 'Test Skill';
        Skillobj2.SVMXC__Skill_Category__c = 'Installation'; 
        insert Skillobj2;
        
        SMAX_OptiMax_EngineUtils.skill skill2 = new SMAX_OptiMax_EngineUtils.skill(Skillobj2.id,'Test Skill', false, 3);    
        
        list<SMAX_OptiMax_EngineUtils.skill> lstOfSkills = new list<SMAX_OptiMax_EngineUtils.skill>();
        lstOfSkills.add(skill1);
        lstOfSkills.add(skill2);
        
        SMAX_OptiMax_EngineUtils OptiMaxEngineUtilsObj = new SMAX_OptiMax_EngineUtils();
        
        OptiMaxEngineUtilsObj.makeUniqueSkillList(lstOfSkills);
        
        SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch multiCriteriaTechMatchObject = new SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch();
        multiCriteriaTechMatchObject.makeUniqueSkillList(lstOfSkills);

        String strTechnicianOverTimeViolations = omaxViolationUtils.checkOvertimeViolations(System.now(),lstBusinessHours.get(0), svmxprocess, OmaxEngineWsipcompjobs.jobId);
        
        SVMXC__ServiceMax_Processes__c objSVMXProcess = new SVMXC__ServiceMax_Processes__c();
        objSVMXProcess.SVMXC__Weight_Tech_Eligibility__c=10;
        objSVMXProcess.SVMXC__Weight_Skill_Match__c=5;
        objSVMXProcess.SVMXC__Weight_Product_Specialization__c=1;
        objSVMXProcess.SVMXC__Weight_Preferred_Technician__c=10;
        multiCriteriaTechMatchObject.getDispatchProcessScores(objSVMXProcess);
        
        
        List<SVMXC__Service_Group_Skills__c> lstOptiMaxSkill = new List<SVMXC__Service_Group_Skills__c>();      
        SVMXC__Service_Group_Skills__c skillV = new SVMXC__Service_Group_Skills__c();
        skillV.SVMXC__Group_Member__c = tech1.id;
        skillV.SVMXC__Service_Group__c = sgroup.Id;   
        lstOptiMaxSkill.add(skillV);        
        
        
        SVMXC__Service_Group_Skills__c skillV1 = new SVMXC__Service_Group_Skills__c();
        skillV1.SVMXC__Group_Member__c = tech.id;
        skillV1.SVMXC__Service_Group__c = sgroup.Id;  
        lstOptiMaxSkill.add(skillV1);   
                
        Insert lstOptiMaxSkill;
        
        SVMXC__Service_Order__c workOrder3 = new SVMXC__Service_Order__c();
        workOrder3.SVMXC__Case__c = c.Id;
        workOrder3.SVMXC__Company__c = account.Id;
        workOrder3.SVMXC__Contact__c =contact.Id;
        workOrder3.SVMXC__Latitude__c = 40.739582;
        workOrder3.SVMXC__Longitude__c = -73.980772;
        workOrder3.SVMXC__Street__c = 'Street1';
        workOrder3.SVMXC__City__c = 'BANGALORE';
        workOrder3.SVMXC__State__c = 'Karnataka';
        workOrder3.SVMXC__Country__c = 'India';
        workOrder3.SVMXC__Zip__c = '11111111';
        workOrder3.SVMXC__Order_Status__c = 'Open';
        workOrder3.SVMXC__Priority__c = 'Medium';
        workOrder3.SVMXC__Order_Type__c = 'Field Service';
        workOrder3.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
        workOrder3.SVMXC__Preferred_Start_Time__c = system.now().addDays(-2);
        workOrder3.SVMXC__Preferred_End_Time__c = system.now().addDays(5);
        workOrder3.SVMXC__Primary_Territory__c = T1.Id;
        workOrder3.SVMXC__OptiMax_status__c = '';
        workOrder3.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder3.SVMXC__Dispatch_Process__c = svmxprocess.Id;
        workOrder3.SVMXC__Service_Duration__c = 50000;
        workOrder3.SVMXC__Locked_By_DC__c = true;
        workOrder3.SVMXC__Group_Member__c = tech.id;
        
        Map<Id, List<SVMXC__Service_Group_Skills__c>> mapTechIdSkills= new Map<Id, List<SVMXC__Service_Group_Skills__c>>();

        mapTechIdSkills.put(tech.id, lstOptiMaxSkill);
        mapTechIdSkills.put(tech1.id, lstOptiMaxSkill);
        
        omaxViolationUtils.checkSkillViolations(mapTechIdSkills, workOrder3, strLogger, OmaxEngineWsipcompjobs.jobId);
        
        
    
         //BEGIN : checkSLAViolations(SVMXC__Service_Order__c objWorkOrder, Map<String, BusinessHours> mapBusinessHours, String jobId, String strLogger){
           SVMXC__Territory__c ter = createTerritory(null); 
            Product2 violationProd  =  createProduct2();
            SVMXC__Service_Group_Members__c violationTech = createTechnicianforViolationTest(createServiceGroupId(),ter.id);
            SVMXC__Service_Order__c violationWO = createWorkorderforViolationTest(violationTech.id,svmxprocess.id,violationProd.Id);
            SVMXC__SVMX_Jobs__c violationJob = createJob(svmxprocess.Id,ter.Id);
        
          violationWO.SVMXC__Scheduled_Date_Time__c = system.now();
          violationWO.SVMXC__Driving_Time__c = 60;
          violationWO.SVMXC__Service_Duration__c = 7200;
          violationWO.SVMXC__Preferred_Start_Time__c = system.now().addMinutes(30);
          violationWO.SVMXC__Preferred_End_Time__c = system.now().addMinutes(60);
          update violationWO;
          omaxViolationUtils.checkSLAViolations(violationWO,null,violationJob.Id,strlogger);
          
          violationWO.SVMXC__Preferred_Start_Time__c = system.now().addMinutes(180);
          violationWO.SVMXC__Preferred_End_Time__c = system.now().addMinutes(60);
          update violationWO;
          omaxViolationUtils.checkSLAViolations(violationWO,null,violationJob.Id,strlogger);
          
           violationWO.SVMXC__Violation_Message__c =null;
            update violationWO;
            omaxViolationUtils.checkSLAViolations(violationWO,null,violationJob.Id,strlogger);
        //END : checkSLAViolations(SVMXC__Service_Order__c objWorkOrder, Map<String, BusinessHours> mapBusinessHours, String jobId, String strLogger){
        
         //BEGIN :  expertisePerTech(set<String> setScheduledTechs)
        SVMXC__Service_Group_Members__c violationTech11 = createTechnicianforViolationTest(createServiceGroupId(),ter.id);
         Product2 violationProd2  =  createProduct2();
         
         SVMXC__Service_Group_Product__c servicGroupproduct = new SVMXC__Service_Group_Product__c(SVMXC__Group_Member__c = violationTech.Id, SVMXC__Product__c = violationProd.Id, SVMXC__Service_Group__c = violationTech.SVMXC__Service_Group__c);
         insert servicGroupproduct;
         SVMXC__Service_Group_Product__c servicGroupproduct1 = new SVMXC__Service_Group_Product__c(SVMXC__Group_Member__c = violationTech11.Id, SVMXC__Product__c = violationProd2.Id, SVMXC__Service_Group__c = violationTech11.SVMXC__Service_Group__c);
         insert servicGroupproduct1;
         
         Set<String> techIds = new Set<String>();
         techIds.add(violationTech11.Id); techIds.add(violationTech.Id);
         omaxViolationUtils.expertisePerTech(techIds);
         
          SVMXC__Service_Group_Skills__c gmS1 = new SVMXC__Service_Group_Skills__c(SVMXC__Group_Member__c = violationTech.Id, SVMXC__Skill__c = Skillobj.Id, SVMXC__Service_Group__c = violationTech.SVMXC__Service_Group__c);
          insert gmS1;
          SVMXC__Service_Group_Skills__c gmS2 = new SVMXC__Service_Group_Skills__c(SVMXC__Group_Member__c = violationTech11.Id, SVMXC__Skill__c = Skillobj2.Id, SVMXC__Service_Group__c = violationTech11.SVMXC__Service_Group__c);
          insert gmS2;
          omaxViolationUtils.skillsPerTech(techIds);
         //END :  expertisePerTech(set<String> setScheduledTechs)
        
        
       //BEGIN : test checkProductExprtseViolations(Map<Id, String> mapTechIdProduct, SVMXC__Service_Order__c objWorkOrder, String jobId, String strLogger)
            Map<Id,String> techNPoductMap  = new Map<Id,String>();
            //Pick a workorder with product and technician without product
            omaxViolationUtils.checkProductExprtseViolations(techNPoductMap,violationWO,violationJob.Id,strlogger);
            //Pick a workorder with product and technician with the same  product
            techNPoductMap.put(violationTech.Id,'randomProdId');
            omaxViolationUtils.checkProductExprtseViolations(techNPoductMap,violationWO,violationJob.Id,strlogger);
        //END : test checkProductExprtseViolations(Map<Id, String> mapTechIdProduct, SVMXC__Service_Order__c objWorkOrder, String jobId, String strLogger)
        
         //BEGIN : test checkEligibilityRuleViolations(SVMXC__Service_Order__c objWorkOrder, String jobId, String strLogger)
            List<SMAX_OptiMax_EngineUtils.stachRanK> stRankList = new List<SMAX_OptiMax_EngineUtils.stachRanK>();
            SMAX_OptiMax_EngineUtils.stachRanK techStackRank = createStackRank(violationTech.id,'Mandatory');
            stRankList.add(techStackRank);
            String JSONString = JSON.serialize(stRankList);
            violationWO.SVMXC__Qualified_Technicians__c = JSONString;
            update violationWO;
            omaxViolationUtils.checkEligibilityRuleViolations(violationWO,violationJob.Id,strlogger);
             
             violationWO.SVMXC__Violation_Message__c =null;
             update violationWO;
             omaxViolationUtils.checkEligibilityRuleViolations(violationWO,violationJob.Id,strlogger);
         //END : test checkEligibilityRuleViolations(SVMXC__Service_Order__c objWorkOrder, String jobId, String strLogger)
        
              
       // BEGIN : test checkPrefrdMandtProhbtTechViolations(SVMXC__Service_Order__c objWorkOrder, String jobId, String strLogger, String techName)
        SVMXC__Service_Group_Members__c violationTech1 = createTechnicianforViolationTest(createServiceGroupId(),ter.id);
        
        stRankList = new List<SMAX_OptiMax_EngineUtils.stachRanK>();
        SMAX_OptiMax_EngineUtils.stachRanK techStackRank2 = createStackRank(violationTech.id,'NotMandatory');
        SMAX_OptiMax_EngineUtils.stachRanK techStackRank3 = createStackRank(violationTech1.id,'Mandatory');
        stRankList.add(techStackRank2);stRankList.add(techStackRank3);
        violationWO.SVMXC__Qualified_Technicians__c = JSON.serialize(stRankList);
        update violationWO;
        omaxViolationUtils.checkPrefrdMandtProhbtTechViolations(violationWO,violationJob.Id,strlogger,'Rahul');
        
        stRankList = new List<SMAX_OptiMax_EngineUtils.stachRanK>();
        SMAX_OptiMax_EngineUtils.stachRanK techStackRank4 = createStackRank(violationTech.id,'Prohibited');
        stRankList.add(techStackRank4);stRankList.add(techStackRank4);
        violationWO.SVMXC__Qualified_Technicians__c = JSON.serialize(stRankList);
        update violationWO;
        omaxViolationUtils.checkPrefrdMandtProhbtTechViolations(violationWO,violationJob.Id,strlogger,'Rahul');
        
        stRankList = new List<SMAX_OptiMax_EngineUtils.stachRanK>();
        SMAX_OptiMax_EngineUtils.stachRanK techStackRank6 = createStackRank(violationTech.id,'NOTPreferred');
        SMAX_OptiMax_EngineUtils.stachRanK techStackRank7 = createStackRank(violationTech1.id,'Preferred');
        stRankList.add(techStackRank6);stRankList.add(techStackRank7);
        violationWO.SVMXC__Qualified_Technicians__c = JSON.serialize(stRankList);
        update violationWO;
        omaxViolationUtils.checkPrefrdMandtProhbtTechViolations(violationWO,violationJob.Id,strlogger,'Rahul');
      
        violationWO.SVMXC__Violation_Message__c =null;
        update violationWO;
        omaxViolationUtils.checkPrefrdMandtProhbtTechViolations(violationWO,violationJob.Id,strlogger,'Rahul');
       // END : test checkPrefrdMandtProhbtTechViolations(SVMXC__Service_Order__c objWorkOrder, String jobId, String strLogger, String techName)
        
       violationWO.SVMXC__Skill_Set__c = '[{"skillName":"hardware","skillLevel":5,"skillId":"a1RG0000002fCLLMA2","isSkillMandatory":true},{"skillName":"software","skillLevel":5,"skillId":"a1RG0000002fCLQMA2","isSkillMandatory":true}]';
       update violationWO;
       SMAX_OptiMax_EngineUtils.fetchSkills(violationWO);
       
       
       
        
        test.stopTest();    
   } 
   
   //MPX realted logic
    static testMethod void testGetWorkOrderResourcePreference(){
        test.startTest();
        WSCH_TestDataFactory.createOptimizationSettings('OptiMax,ServicePower', 'True');
        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;

        insert technician;

        SVMXC__Site__c siteObject = new SVMXC__Site__c();
        siteObject.Name = 'Site1';

        insert siteObject;

        Account accountObject = new Account();
        accountObject.AccountNumber = '0011';
        accountObject.Name = 'Test Name';

        insert accountObject;
        
        Contact cont = new Contact();
        cont.LastName='Last';
        cont.AccountId =accountObject.Id;
        cont.Email='svmxmailfortest@gmail.com';
        
        insert cont;
        
        Product2 prodCloseWO = new Product2();
        prodCloseWO.Name = 'prodPR';
        prodCloseWO.ProductCode='prodPR';
        prodCloseWO.SVMXC__Inherit_Parent_Warranty__c =True;
        
        insert prodCloseWO;
        
        SVMXC__Installed_Product__c IBObject = new SVMXC__Installed_Product__c();
        IBObject.Name = 'Test IB1';
        IBObject.SVMXC__Status__c = 'Installed';
        IBObject.SVMXC__Product__c = prodCloseWO.Id;
        IBObject.SVMXC__Date_Installed__c = System.Today();
        IBObject.SVMXC__Contact__c = cont.Id;
        IBObject.SVMXC__Company__c = accountObject.Id;
        
        //insert IBObject;

        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        
        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        bookJobWorkOrder.SVMXC__Preferred_Technician__c = technician.Id;
        bookJobWorkOrder.SVMXC__Skill_Set__c = '[{"skillName":"hardware","skillLevel":5,"skillId":"a1RG0000002fCLLMA2","isSkillMandatory":true},{"skillName":"software","skillLevel":5,"skillId":"a1RG0000002fCLQMA2","isSkillMandatory":true}]';
        bookJobWorkOrder.SVMXC__Site__c = siteObject.Id;
        bookJobWorkOrder.SVMXC__Company__c = accountObject.Id;

        insert bookJobWorkOrder;

        SVMXC__Resource_Preference__c resPref = new SVMXC__Resource_Preference__c();
        resPref.SVMXC__Company__c = accountObject.Id;
        //resPref.SVMXC__Component__c = IBObject.id;
        resPref.SVMXC__Site__c = siteObject.id;
        resPref.SVMXC__Group_Member__c = technician.id;
        resPref.SVMXC__Preference_Type__c = 'Preferred';
        
        insert resPref;
        
        List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
        lstWO.add(bookJobWorkOrder);
        List<SVMXC__Resource_Preference__c> lstResPref  = new List<SVMXC__Resource_Preference__c>();
        lstResPref = WORD_Service_Order_Resources.getResourcePreferences(lstWO);
        Map<Id,SVMXC__Service_Order__c> mapOldWO = new Map<Id,SVMXC__Service_Order__c>();
        mapOldWO.put(bookJobWorkOrder.id, bookJobWorkOrder);
        
        SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch clsQTLComputation = new SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch();
        clsQTLComputation.getWorkOrderResourcePreference(lstWO);
        test.stopTest(); 
}

    private static SVMXC__SVMX_Jobs__c createJob(String processId,String terId){
       SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
        job1.SVMXC__SVMX_Process__c = processId;
        job1.SVMXC__Territory__c = terId;
        job1.SVMXC__OptiMax_Message__c = 'In Progress';
        job1.SVMXC__Start_Time__c = system.now();
        insert job1;
        return job1;
    }
    
    private static Product2 createProduct2()
    {
         Product2 product1 = new Product2();
           product1.Name = 'Laptop';
            insert product1;
            return product1;
    }

   private static SVMXC__Service_Group_Members__c createTechnicianforViolationTest(String groupId,String terrId){
   
     SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c();
        objTechnician2.Name = 'TestTechnician2';
        objTechnician2.SVMXC__Service_Group__c = groupId;
        objTechnician2.SVMXC__Active__c = true;
        objTechnician2.SVMXC__City__c = 'Bangalore';
        objTechnician2.SVMXC__Service_Territory__c = terrId;
        objTechnician2.SVMXC__Enable_Scheduling__c = true;
        insert objTechnician2;
        
        return objTechnician2;
   }
   
   private static SMAX_OptiMax_EngineUtils.stachRanK createStackRank(String techId,String prefType){
     SMAX_OptiMax_EngineUtils.stachRank techStRank = new SMAX_OptiMax_EngineUtils.stachRank();
          techStRank.tech = techId;
          techStRank.tName = 'Rahul';
          techStRank.valid =false;
          techStRank.eligible=0;
          techStRank.eligible=0;
          techStRank.skillR=0;
          techStRank.skillO=0.0;
          techStRank.stackRank=2;
          techStRank.eligibleRuleName= 'ViolationRule';
          techStRank.prefType = prefType;
          return techStRank;
   }
   
   
   private static SVMXC__Service_Order__c createWorkorderforViolationTest(String technicianId,String processId,String productId){
     SVMXC__Service_Order__c nWO3 = new SVMXC__Service_Order__c();
        nWO3.SVMXC__Zip__c = '11111';           
        nWO3.SVMXC__Order_Status__c='Open';
        nWO3.SVMXC__Priority__c='Low';
        nWO3.SVMXC__Order_Type__c='Field Service';
        nWO3.SVMXC__Purpose_of_Visit__c='Repair';
        nWO3.SVMXC__Billing_Type__c = 'Contract';
        nWO3.SVMXC__City__c = 'Bangalore';
        nWO3.SVMXC__Group_Member__c = technicianId;
        nWO3.SVMXC__Scheduled_Date_Time__c = datetime.now();
        nWO3.SVMXC__Dispatch_Process__c =  processId;
        nWO3.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO3.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO3.SVMXC__Locked_By_DC__c = true;
        nWO3.SVMXC__Service_Duration__c = 60;
        nWO3.Driving_Time__c = 60;
        nWO3.SVMXC__Product__c = productId;
       
        insert nWO3;
        
        return nWO3;
   } 

   //Begin : Sadiya - Spring 17 - UT Coverage for Overnight Logic
   static testMethod void SMAX_OptiMax_OvernightUtils_UnitTest()
    { 
       SVMXC__SM_Overnight_Stay_Policy__c opolicy = createOverNightPolicy();
       SVMXC__Territory__c ter = createTerritory(opolicy);
       SVMXC__Service_Group_Members__c tech1 = createTechnician(ter.id,opolicy);
       SVMXC__Service_Group_Members__c tech2 = createTechnician(ter.id,null);
       List<SVMXC__Service_Group_Members__c> technicians = new List<SVMXC__Service_Group_Members__c>();
       technicians.add(tech1);
       technicians.add(tech2);
       
       Map<String,SVMXC__SM_Overnight_Stay_Policy__c> techNOvernightPolicy = new Map<String,SVMXC__SM_Overnight_Stay_Policy__c>();
       techNOvernightPolicy.put(tech1.Id,opolicy);
       SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP techAdd = new SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP();
       String strLogger = 'Log';
       String terid = ter.id;
       
       SMAX_OptiMax_EngineUtils.OMAX_OvernightUtils omaxOvernightUtils = new SMAX_OptiMax_EngineUtils.OMAX_OvernightUtils();
       omaxOvernightUtils.getTerritoryOvernightPolicy(ter,technicians);
       omaxOvernightUtils.getOvernightPoliciesByTeritory(terid);
       omaxOvernightUtils.updateTechnicianAddtionalWithOvernightPlicy(tech1,techNOvernightPolicy,techAdd,true);
       omaxOvernightUtils.updateTechnicianAddtionalWithOvernightPlicy(tech1,techNOvernightPolicy,techAdd,false);
       omaxOvernightUtils.buildWorkOrderAddtiionalDetails();
       
       

    }
    
    
    
     private static SVMXC__SM_Overnight_Stay_Policy__c createOverNightPolicy(){
        SVMXC__SM_Overnight_Stay_Policy__c poicy = new SVMXC__SM_Overnight_Stay_Policy__c();
        poicy.SVMXC__SM_Active__c =  true;
        poicy.SVMXC__SM_Allow_Friday_ONS__c = true;
        poicy.SVMXC__SM_Allow_Monday_ONS__c = true;
        poicy.SVMXC__SM_Allow_Saturday_ONS__c = true;
        poicy.SVMXC__SM_Allow_Sunday_ONS__c = true;
        poicy.SVMXC__SM_Allow_Thursday_ONS__c = true;
        poicy.SVMXC__SM_Allow_Tuesday_ONS__c= true;
        poicy.SVMXC__SM_Allow_Wednesday_ONS__c= true;
        poicy.SVMXC__SM_Consecutive_ONS_Per_Week__c= 2;
        poicy.SVMXC__SM_Total_ONS_Per_Week__c= 4;
        poicy.SVMXC__SM_Drive_Distance_Threshold__c= 20;
        poicy.SVMXC__SM_Drive_Time_Threshold__c= 20;
        poicy.SVMXC__SM_Policy_Override__c= true  ;
        
        insert poicy ;
        return poicy ;
    
    }
    
    
     
     private static SVMXC__Territory__c createTerritory(SVMXC__SM_Overnight_Stay_Policy__c oPolicy){
        SVMXC__Territory__c ecoTeritory = new SVMXC__Territory__c();
         ecoTeritory.Name = 'Ter-UT';
         if(null != oPolicy){
            ecoTeritory.SVMXC__SM_Overnight_Stay_Policy__c = oPolicy.id;
         }
         insert ecoTeritory;
         return ecoTeritory;
    }
    
    
     private static SVMXC__Service_Group_Members__c createTechnician(String terId,SVMXC__SM_Overnight_Stay_Policy__c oPolicy){
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'ECO_Tech_UT';
        technician.SVMXC__City__c = 'Bangalore';
        technician.SVMXC__Country__c = 'India';
        technician.SVMXC__Zip__c = '560030';
        technician.SVMXC__Service_Territory__c = terId;
        technician.SVMXC__Service_Group__c= createServiceGroupId();
        if(null != oPolicy){
            technician.SVMXC__SM_Overnight_Stay_Policy__c = oPolicy.id;
        }
        insert technician;
        return technician;
        
    }
    
    private static String createServiceGroupId(){
     SVMXC__Service_Group__c segroup = new SVMXC__Service_Group__c();
     segroup.Name = 'TestGroup-UT';
     insert segroup;
     return segroup.id;
    }
    
    static testMethod void coverWrappers() {
        
        SMAX_OptiMax_EngineUtils.SkillSet skillSet = new SMAX_OptiMax_EngineUtils.SkillSet();
        skillSet.skillName = 'name';
        skillSet.skillId = 'skillId';
        skillSet.skillLevel = 'level';
        skillSet.isSkillMandatory = 'mandatory';
        
        
        List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstWOTimeWindows = new List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP exec_wp = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
        exec_wp.startDateTime = system.now();
        exec_wp.endDateTime = system.now() + 1;
        lstWOTimeWindows.add(exec_wp);
        
        Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP> mapWrkOrdrTimeWindows = new Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        mapWrkOrdrTimeWindows.put(system.now().Date(), exec_wp);
        
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        insert bookJobWorkOrder;
        
        SMAX_OptiMax_EngineUtils.skill skill_wp = new SMAX_OptiMax_EngineUtils.skill(Id.valueOf(bookJobWorkOrder.Id),'name',true,12);
        SMAX_OptiMax_EngineUtils.techAddress techAddress = new SMAX_OptiMax_EngineUtils.techAddress(Id.valueOf(bookJobWorkOrder.Id), 'address', Decimal.valueOf('12'), Decimal.valueOf('12'));
        
        List<Businesshours> lstBusinessHours = [Select Id, IsDefault,IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                            from BusinessHours
                            where IsActive = TRUE limit 1];
        
        SMAX_OptiMax_EngineUtils.constructExecTimeWindows(system.now(), system.now() + 1, lstWOTimeWindows, mapWrkOrdrTimeWindows, bookJobWorkOrder, lstBusinessHours[0]);
        SMAX_OptiMax_EngineUtils.constructExecTimeWindows(system.now(), system.now(), lstWOTimeWindows, mapWrkOrdrTimeWindows, bookJobWorkOrder, lstBusinessHours[0]);
    }
}