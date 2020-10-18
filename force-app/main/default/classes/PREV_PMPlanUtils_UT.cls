@isTest(seeAllData = true)
private class PREV_PMPlanUtils_UT 
{
    static testMethod void PREV_PMPlanUtilsUnitTest()
    {
        RecordType ExpProcess_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC.INTF_WebservicesDef.INTF_Request req = new SVMXC.INTF_WebservicesDef.INTF_Request();
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringLstMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        
        //Data Creation for the different Sceneries
        Account acc = new Account();
        acc.Name = 'ServiceMax';
        insert acc;
        
        Product2 prod = new Product2();
        prod.Name = 'Product0001';
        insert prod;
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        insert loc;
        
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        IB.SVMXC__Company__c = acc.Id;
        IB.SVMXC__Site__c = loc.Id;
        IB.SVMXC__Product__c = prod.Id;
        insert IB;
        
        SVMXC__Service_Contract__c SC = new SVMXC__Service_Contract__c();
        insert SC;
        
        SVMXC__Service_Contract_Products__c CP = new SVMXC__Service_Contract_Products__c();
        CP.SVMXC__Installed_Product__c = IB.Id;
        CP.SVMXC__Service_Contract__c = SC.Id;
        insert CP;
        
        SVMXC__PM_Plan_Template__c PMCat = new SVMXC__PM_Plan_Template__c();
        insert PMCat;
        
        SVMXC__PM_Applicable_Product__c applcblProd = new SVMXC__PM_Applicable_Product__c();
        applcblProd.SVMXC__PM_Plan_Template__c = PMCat.Id;
        applcblProd.SVMXC__Product__c = prod.Id;
        insert applcblProd;
        
        SVMXC__PM_Plan__c pmPlan = new SVMXC__PM_Plan__c();
        pmPlan.SVMXC__Account__c = acc.Id;
        pmPlan.SVMXC__Location__c = loc.Id;
        pmPlan.SVMXC__PM_Plan_Template__c = PMCat.iD;
        pmPlan.SVMXC__Service_Contract__c = SC.Id;
        pmPlan.SVMXC__Coverage_Type__c = 'ACCOUNT (VISIT ONLY)';
        insert pmPlan;
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add('Account');
        lstStringLstMapReq.add(strLstMap);
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap1.key = 'PM Plan';
        strLstMap1.valueList.add(pmPlan.Id);
        lstStringLstMapReq.add(strLstMap1);
        
        //Calling the Generation of PM Plan method for Account
        PREV_PMPlanUtils pmUtil = new PREV_PMPlanUtils();
        
        req.stringListMap = lstStringLstMapReq;
        pmUtil.PREV_CalculatePMPlanDetails(req);
        
        lstStringLstMapReq.clear();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add('SC');
        lstStringLstMapReq.add(strLstMap);
        
        strLstMap1.key = 'PM Plan';
        strLstMap1.valueList.add(pmPlan.Id);
        lstStringLstMapReq.add(strLstMap1);
        //Calling the Generation of PM Plan method for Service Contract
        req.stringListMap = lstStringLstMapReq;
        pmUtil.PREV_CalculatePMPlanDetails(req);
        
        
        lstStringLstMapReq.clear();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add('Location');
        lstStringLstMapReq.add(strLstMap);
        
        strLstMap1.key = 'PM Plan';
        strLstMap1.valueList.add(pmPlan.Id);
        lstStringLstMapReq.add(strLstMap1);
        //Calling the Generation of PM Plan method for Installed Product
        req.stringListMap = lstStringLstMapReq;
        pmUtil.PREV_CalculatePMPlanDetails(req);
        pmUtil.getTAG001();
        pmUtil.getTAG002();
        
        // Create temporary data
        Account objAccount = new Account();
        objAccount.Name = 'Account-01';
        insert objAccount;
        
        date startDate = system.today();
        date endDate = startDate.addDays(10);
        
        SVMXC__Service_Contract__c SconObject;
        SconObject = new SVMXC__Service_Contract__c();                                         
        SconObject.Name='SCON-0001';
        SconObject.SVMXC__Company__c = objAccount.Id;
        SconObject.SVMXC__Activation_Notes__c = 'Its with Unit Test Case';
        SconObject.SVMXC__Start_Date__c = startDate;
        SconObject.SVMXC__End_Date__c = endDate;
        insert SconObject;
        
        SVMXC__PM_Plan__c objPlan1 = new SVMXC__PM_Plan__c();
        objPlan1.SVMXC__Status__c = 'Active'; 
        objPlan1.SVMXC__Service_Contract__c = SconObject.Id;
        objPlan1.Name = 'SCON-001';
        insert objPlan1;
        system.assert(objPlan1.SVMXC__Service_Contract__c != null);
        
        List<SVMXC__Service_Order__c> lstWorkOrder = new List<SVMXC__Service_Order__c>();
        lstWorkOrder.add(new SVMXC__Service_Order__c(SVMXC__Order_Status__c = 'Open', SVMXC__PM_Plan__c = objPlan1.Id, SVMXC__Is_PM_Work_Order__c = true));
        insert lstWorkOrder;
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest objINTF_SFMReq = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        objINTF_SFMReq.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        objINTF_SFMReq.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCONID',string.valueOf(SconObject.Id)));
        pmUtil.PREV_CancelPMForContract(objINTF_SFMReq);
        
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstTargetRecAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        lstTargetRecAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('Id', objPlan1.Id));
        
        SVMXC.INTF_WebServicesDef.INTF_Record r = new SVMXC.INTF_WebServicesDef.INTF_Record();
        r.targetRecordId = objPlan1.Id;
        r.targetRecordAsKeyValue = lstTargetRecAsKeyValue;
        
        List<SVMXC.INTF_WebServicesDef.INTF_Record> lstwrapObjHeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        lstwrapObjHeaderRecord.add(r);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject objHdrTargetRecord = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        objHdrTargetRecord.records = lstwrapObjHeaderRecord;
        objHdrTargetRecord.objName = 'SVMXC__PM_Plan__c';
        
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqPMPlanForCancelPM = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        reqPMPlanForCancelPM.headerRecord = objHdrTargetRecord;
        
        pmUtil.PREV_CancelPMPlan(reqPMPlanForCancelPM);
        
        SVMXC__PM_Plan__c objPMPlan = new SVMXC__PM_Plan__c();
        objPMPlan.Name = 'Test_PM_Plan';
        objPMPlan.SVMXC__Account__c = objAccount.Id;
        objPMPlan.SVMXC__Service_Contract__c = SconObject.Id;
        objPMPlan.SVMXC__Start_Date__c = date.today();
        objPMPlan.SVMXC__End_Date__c = date.today().addDays(365);
        objPMPlan.SVMXC__Status__c = 'Active';
        insert objPMPlan;

        list<SVMXC__PM_Schedule_Definition__c> lstPMScheduleDef = new list<SVMXC__PM_Schedule_Definition__c>();
        for(integer j=1; j<3; j++)
        {
            SVMXC__PM_Schedule_Definition__c objPMScheduleDef = new SVMXC__PM_Schedule_Definition__c();
            objPMScheduleDef.SVMXC__PM_Plan__c = objPMPlan.Id;
            objPMScheduleDef.SVMXC__Schedule_Type__c = 'Time Based';
            objPMScheduleDef.SVMXC__Frequency__c = 5*j;
            if(j==1)
                objPMScheduleDef.SVMXC__Frequency_Unit__c = 'WEEKS';
            else if(j==2)
                objPMScheduleDef.SVMXC__Frequency_Unit__c = 'MONTHS';
            else if(j==3)
                objPMScheduleDef.SVMXC__Frequency_Unit__c = 'YEARS';
            else
                objPMScheduleDef.SVMXC__Frequency_Unit__c = 'WEEKS';
            lstPMScheduleDef.add(objPMScheduleDef);
        }
        insert lstPMScheduleDef;
        
        SVMXC__Installed_Product__c objIB = new SVMXC__Installed_Product__c();
        objIB.Name = 'Test IB';
        insert objIB;
        
        list<SVMXC__PM_Coverage__c> lstPMCvrg = new list<SVMXC__PM_Coverage__c>();
        for(integer j=0; j<10; j++)
        {
            SVMXC__PM_Coverage__c objPMCvrg = new SVMXC__PM_Coverage__c();
            objPMCvrg.SVMXC__PM_Plan__c = objPMPlan.Id;
            objPMCvrg.SVMXC__Product_Name__c = objIB.Id;
            lstPMCvrg.add(objPMCvrg);
        }
        insert lstPMCvrg;

        list<SVMXC__PM_Schedule__c> lstPMSchedule = new list<SVMXC__PM_Schedule__c>();
        for(integer j=0; j<2; j++)
        {
            lstPMSchedule.add(new SVMXC__PM_Schedule__c(SVMXC__PM_Plan__c = objPMPlan.Id, SVMXC__Last_Run_Date__c = date.today(), SVMXC__PM_Schedule_Definition__c = lstPMScheduleDef[j].Id, SVMXC__Scheduled_On__c = date.today().addDays(5)));
        }
        insert lstPMSchedule;
        
        INTF_WebServicesDef.INTF_Request reqToCalcNxtSchedule = new INTF_WebServicesDef.INTF_Request();
        reqToCalcNxtSchedule.recordIds = new List<String>();
        reqToCalcNxtSchedule.recordIds.add(objPMPlan.Id);
        reqToCalcNxtSchedule.stringListMap = new List<INTF_WebServicesDef.INTF_StringListMap>();
        List<String> lstPMScheduleDefIDs = new List<String>();
        for(SVMXC__PM_Schedule_Definition__c objPMScheduleDef : lstPMScheduleDef)
            lstPMScheduleDefIDs.add(objPMScheduleDef.Id);
        reqToCalcNxtSchedule.stringListMap.add(new INTF_WebServicesDef.INTF_StringListMap('SCHEDULEID', lstPMScheduleDefIDs));
        pmUtil.PREV_CalculateNextSchedule(reqToCalcNxtSchedule);
    }
    
    
    
    static testMethod void PREV_PMPlanUtilsUnitTest2()
    {
        RecordType ExpProcess_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC.INTF_WebservicesDef.INTF_Request req = new SVMXC.INTF_WebservicesDef.INTF_Request();
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringLstMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        
        //Data Creation for the different Sceneries
        Account acc = new Account();
        acc.Name = 'ServiceMax';
        insert acc;
        
        Product2 prod = new Product2();
        prod.Name = 'Product0001';
        insert prod;
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        insert loc;
        
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        IB.SVMXC__Company__c = acc.Id;
        IB.SVMXC__Site__c = loc.Id;
        IB.SVMXC__Product__c = prod.Id;
        insert IB;
        
        SVMXC__Service_Contract__c SC = new SVMXC__Service_Contract__c();
        insert SC;
        
        SVMXC__Service_Contract_Products__c CP = new SVMXC__Service_Contract_Products__c();
        CP.SVMXC__Installed_Product__c = IB.Id;
        CP.SVMXC__Service_Contract__c = SC.Id;
        insert CP;
        
        SVMXC__PM_Plan_Template__c PMCat = new SVMXC__PM_Plan_Template__c();
        insert PMCat;
        
        SVMXC__PM_Applicable_Product__c applcblProd = new SVMXC__PM_Applicable_Product__c();
        applcblProd.SVMXC__PM_Plan_Template__c = PMCat.Id;
        applcblProd.SVMXC__Product__c = prod.Id;
        insert applcblProd;
        
        SVMXC__PM_Plan__c pmPlan = new SVMXC__PM_Plan__c();
        pmPlan.SVMXC__Account__c = acc.Id;
        pmPlan.SVMXC__Location__c = loc.Id;
        pmPlan.SVMXC__PM_Plan_Template__c = PMCat.iD;
        pmPlan.SVMXC__Service_Contract__c = SC.Id;
        pmPlan.SVMXC__Coverage_Type__c = 'ACCOUNT (VISIT ONLY)';
        insert pmPlan;
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add('Account');
        lstStringLstMapReq.add(strLstMap);
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap1.key = 'PM Plan';
        strLstMap1.valueList.add(pmPlan.Id);
        lstStringLstMapReq.add(strLstMap1);
        
        //Calling the Generation of PM Plan method for Account
        PREV_PMPlanUtils pmUtil = new PREV_PMPlanUtils();
        
        req.stringListMap = lstStringLstMapReq;
        pmUtil.PREV_CalculatePMPlanDetails(req);
        
        //Account Based PM Plan
        pmPlan.SVMXC__Coverage_Type__c = 'ACCOUNT (VISIT ONLY)';
        update pmPlan;
        lstStringLstMapReq.clear();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add('Account');
        lstStringLstMapReq.add(strLstMap);
        strLstMap1.key = 'PM Plan';
        strLstMap1.valueList.add(pmPlan.Id);
        lstStringLstMapReq.add(strLstMap1);
        req.stringListMap = lstStringLstMapReq;
        pmUtil.PREV_CalculatePMPlanDetails(req);
        
        //Product Based PM Plan
        pmPlan.SVMXC__Coverage_Type__c = 'PRODUCT (MUST HAVE IB)';
        update pmPlan;
        lstStringLstMapReq.clear();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add('Account');
        lstStringLstMapReq.add(strLstMap);
        strLstMap1.key = 'PM Plan';
        strLstMap1.valueList.add(pmPlan.Id);
        lstStringLstMapReq.add(strLstMap1);
        req.stringListMap = lstStringLstMapReq;
        pmUtil.PREV_CalculatePMPlanDetails(req);
        
        
        //Location Based PM Plan
        pmPlan.SVMXC__Coverage_Type__c = 'LOCATION (MUST HAVE LOCATION)';
        update pmPlan;
        lstStringLstMapReq.clear();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add('Account');
        lstStringLstMapReq.add(strLstMap);
        strLstMap1.key = 'PM Plan';
        strLstMap1.valueList.add(pmPlan.Id);
        lstStringLstMapReq.add(strLstMap1);
        req.stringListMap = lstStringLstMapReq;
        pmUtil.PREV_CalculatePMPlanDetails(req);
        
       //Account Based PM Plan
        pmPlan.SVMXC__Coverage_Type__c = 'ACCOUNT (VISIT ONLY)';
        update pmPlan;
        lstStringLstMapReq.clear();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add('Location');
        lstStringLstMapReq.add(strLstMap);
        strLstMap1.key = 'PM Plan';
        strLstMap1.valueList.add(pmPlan.Id);
        lstStringLstMapReq.add(strLstMap1);
        req.stringListMap = lstStringLstMapReq;
        pmUtil.PREV_CalculatePMPlanDetails(req);
        
        //Product Based PM Plan
        pmPlan.SVMXC__Coverage_Type__c = 'PRODUCT (MUST HAVE IB)';
        update pmPlan;
        lstStringLstMapReq.clear();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add('Location');
        lstStringLstMapReq.add(strLstMap);
        strLstMap1.key = 'PM Plan';
        strLstMap1.valueList.add(pmPlan.Id);
        lstStringLstMapReq.add(strLstMap1);
        req.stringListMap = lstStringLstMapReq;
        pmUtil.PREV_CalculatePMPlanDetails(req);
        
        //Location Based PM Plan
        pmPlan.SVMXC__Coverage_Type__c = 'LOCATION (MUST HAVE LOCATION)';
        update pmPlan;
        lstStringLstMapReq.clear();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add('Location');
        lstStringLstMapReq.add(strLstMap);
        strLstMap1.key = 'PM Plan';
        strLstMap1.valueList.add(pmPlan.Id);
        lstStringLstMapReq.add(strLstMap1);
        req.stringListMap = lstStringLstMapReq;
        pmUtil.PREV_CalculatePMPlanDetails(req);
    }
    
    static testMethod void getApplyMapping_Test()
    { 
        map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>(); 
        map<String,Schema.SObjectType> Allobj = new map<String,Schema.SObjectType>();
        gd = Schema.getGlobalDescribe();
        if(gd.size() > 0)
        {
            for(Schema.SObjectType s : gd.values()) 
            {
                Schema.DescribeSObjectResult result = s.getDescribe();
                Allobj.put(result.getName(),s);
            }
        }
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        System.assertEquals(true, lstRecType != null);
        String TargetManager = '';
        String ObjectMapping = '';
        String Fieldmapping = '';
        String ProcessNodeObj = '';
        for(RecordType r : lstRecType)
        {   
            if(r.Name == 'Target Manager')
                TargetManager = r.id;
            if(r.Name == 'Object Mapping')  
                ObjectMapping = r.id;
            if(r.Name == 'Field Mapping')
                Fieldmapping = r.id;    
            if(r.Name == 'Process Node Objects')    
                ProcessNodeObj = r.id;
        }
                
       //-------------------------------DATA PREPARATION------------------------------------------------------------------//
        SVMXC__ServiceMax_Processes__c ObjectMap = new SVMXC__ServiceMax_Processes__c();
        ObjectMap.SVMXC__Target_Object_Name__c = 'SVMXC__Installed_Product__c';
        ObjectMap.RecordTypeId =lstRecType[0].Id;
        ObjectMap.SVMXC__MapID__c='CUSTOMMAP0001';
        ObjectMap.SVMXC__Name__c = 'CUSTOMMAP0001';
        ObjectMap.RecordTypeId = ObjectMapping;
        insert ObjectMap;
        
        list<SVMXC__ServiceMax_Config_Data__c> FieldMapList = new list<SVMXC__ServiceMax_Config_Data__c>();        
        SVMXC__ServiceMax_Config_Data__c FieldMap = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap.RecordTypeId =Fieldmapping;
        FieldMap.SVMXC__MapID__c = ObjectMap.Id ;
        FieldMap.SVMXC__Source_Field_Name__c ='SVMXC__City__c' ;
        FieldMap.SVMXC__Target_Field_Name__c ='SVMXC__City__c' ;
        FieldMapList.add(FieldMap); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap1 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap1.RecordTypeId =Fieldmapping;
        FieldMap1.SVMXC__MapID__c = ObjectMap.Id ;
        FieldMap1.SVMXC__Source_Field_Name__c ='SVMXC__Contact__c' ;
        FieldMap1.SVMXC__Target_Field_Name__c ='SVMXC__Contact__c' ;
        FieldMapList.add(FieldMap1); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap2 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap2.RecordTypeId =Fieldmapping;
        FieldMap2.SVMXC__MapID__c = ObjectMap.Id ;
        FieldMap2.SVMXC__Source_Field_Name__c ='SVMXC__Date_Shipped__c' ;
        FieldMap2.SVMXC__Target_Field_Name__c ='SVMXC__Date_Shipped__c' ;
        FieldMapList.add(FieldMap2);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap3 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap3.RecordTypeId =Fieldmapping;
        FieldMap3.SVMXC__MapID__c = ObjectMap.Id ;
        FieldMap3.SVMXC__Source_Field_Name__c ='SVMXC__Latitude__c' ;
        FieldMap3.SVMXC__Target_Field_Name__c ='SVMXC__Latitude__c' ;
        FieldMapList.add(FieldMap3);
        
        insert FieldMapList;       
        
        Account acc1 = new Account();
        acc1.Name = 'Maxplore';
        acc1.AccountNumber = 'acc0002';
        acc1.Phone = null;
        acc1.Fax = null ;
        acc1.Website = 'www.maxplore.com';
        acc1.Sic = 'sicnumber001';
        insert acc1;
        
        Contact cont1 = new Contact();
        cont1.Account=acc1;
        cont1.FirstName = 'Ranjeet';
        cont1.LastName = 'Jaiswal';
        insert cont1 ;
        
        Product2 pro= new Product2();
        pro.Family = 'Apple';
        pro.IsActive = true;
        pro.ProductCode = '0001';
        pro.Name = 'Apple';
        insert pro;
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c();
        IB1.Name = 'TopLevel';
        IB1.SVMXC__Product__c = pro.id; 
        IB1.SVMXC__City__c = 'Bangalore';
        IB1.SVMXC__Contact__c = cont1.id;
        IB1.SVMXC__Date_Shipped__c = system.today();
        IB1.SVMXC__Latitude__c = 123;
        insert IB1;
        SVMXC__Installed_Product__c IB2 = new SVMXC__Installed_Product__c();
        IB2.Name = 'Parent';
        IB2.SVMXC__Product__c = pro.id;
        IB2.SVMXC__Parent__c =  IB1.id;
        insert IB2;  
        list<Sobject> SobjList = new list<Sobject>();
        SobjList.add(IB2);
        INTF_applyMapping MappingObj = new INTF_applyMapping();
        MappingObj.getApplyMapping(SobjList, ObjectMap.id, IB1.id, true, Allobj);
        ObjectMap.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        update ObjectMap;
        MappingObj.getApplyMapping(SobjList, ObjectMap.id, IB1.id, false, Allobj);
        
        //For Record Type
        SVMXC__ServiceMax_Processes__c ObjectMap2 = new SVMXC__ServiceMax_Processes__c();
        ObjectMap2.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjectMap2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjectMap2.RecordTypeId =lstRecType[0].Id;
        ObjectMap2.SVMXC__MapID__c='CUSTOMMAP00001';
        ObjectMap2.SVMXC__Name__c = 'CUSTOMMAP00001';
        ObjectMap2.RecordTypeId = ObjectMapping;
        insert ObjectMap2;
        
        SVMXC__ServiceMax_Config_Data__c FieldMap4 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap4.RecordTypeId =Fieldmapping;
        FieldMap4.SVMXC__MapID__c = ObjectMap2.Id ;
        FieldMap4.SVMXC__Display_Value__c ='Estimate' ;
        FieldMap4.SVMXC__Target_Field_Name__c ='RecordTypeId' ;
        FieldMapList.add(FieldMap4); 
        
        upsert FieldMapList;
        
         SVMXC__Service_Order__c workorder = new SVMXC__Service_Order__c(
                                                    SVMXC__Order_Status__c = 'Open',
                                                    SVMXC__Priority__c = 'Medium',
                                                    SVMXC__Order_Type__c = 'Field Service'
                                                    );
        insert workorder;
        SVMXC__Service_Order_Line__c wd = new SVMXC__Service_Order_Line__c();
        wd.SVMXC__Service_Order__c = workorder.id;
        wd.SVMXC__Line_Type__c = 'Parts';
        wd.SVMXC__Use_Price_From_Pricebook__c = true;
        wd.SVMXC__Actual_Price2__c = 100;
        wd.SVMXC__Actual_Quantity2__c = 100;
        wd.SVMXC__Date_Received__c = system.today();
        wd.SVMXC__Discount__c = 10;
        wd.SVMXC__Received_City__c = 'Bangalore';
        insert wd;
        SVMXC__Service_Order_Line__c wd1 = new SVMXC__Service_Order_Line__c();
        list<Sobject> SobjList1 = new list<Sobject>();
        SobjList1.add(wd1);
        MappingObj.getApplyMapping(SobjList1, ObjectMap2.id, wd.id, false, Allobj);
        
        //For Value mapping
        //For Record Type
        SVMXC__ServiceMax_Processes__c ObjectMap3 = new SVMXC__ServiceMax_Processes__c();
        ObjectMap3.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjectMap3.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjectMap3.RecordTypeId =lstRecType[0].Id;
        ObjectMap3.SVMXC__MapID__c='CUSTOMMAP00001';
        ObjectMap3.SVMXC__Name__c = 'CUSTOMMAP00001';
        ObjectMap3.RecordTypeId = ObjectMapping;
        insert ObjectMap3;
        
        SVMXC__ServiceMax_Config_Data__c FieldMap5 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap5.RecordTypeId =Fieldmapping;
        FieldMap5.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap5.SVMXC__Display_Value__c ='Estimate' ;
        FieldMap5.SVMXC__Target_Field_Name__c ='RecordTypeId' ;
        FieldMapList.add(FieldMap5); 
        
        
        SVMXC__ServiceMax_Config_Data__c FieldMap6 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap6.RecordTypeId =Fieldmapping;
        FieldMap6.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap6.SVMXC__Display_Value__c ='parts' ;
        FieldMap6.SVMXC__Target_Field_Name__c ='SVMXC__Line_Type__c' ;
        FieldMapList.add(FieldMap6); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap7 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap7.RecordTypeId =Fieldmapping;
        FieldMap7.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap7.SVMXC__Display_Value__c ='true' ;
        FieldMap7.SVMXC__Target_Field_Name__c ='SVMXC__Use_Price_From_Pricebook__c' ;
        FieldMapList.add(FieldMap7); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap8 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap8.RecordTypeId =Fieldmapping;
        FieldMap8.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap8.SVMXC__Display_Value__c ='100' ;
        FieldMap8.SVMXC__Target_Field_Name__c ='SVMXC__Actual_Price2__c' ;
        FieldMapList.add(FieldMap8);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap9 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap9.RecordTypeId =Fieldmapping;
        FieldMap9.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap9.SVMXC__Display_Value__c ='100' ;
        FieldMap9.SVMXC__Target_Field_Name__c ='SVMXC__Actual_Quantity2__c' ;
        FieldMapList.add(FieldMap9); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap10 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap10.RecordTypeId =Fieldmapping;
        FieldMap10.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap10.SVMXC__Display_Value__c ='Today' ;
        FieldMap10.SVMXC__Target_Field_Name__c ='SVMXC__Date_Received__c' ;
        FieldMapList.add(FieldMap10); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap11 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap11.RecordTypeId =Fieldmapping;
        FieldMap11.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap11.SVMXC__Display_Value__c ='10' ;
        FieldMap11.SVMXC__Target_Field_Name__c ='SVMXC__Discount__c' ;
        FieldMapList.add(FieldMap11);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap12 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap12.RecordTypeId =Fieldmapping;
        FieldMap12.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap12.SVMXC__Display_Value__c ='Bangalore' ;
        FieldMap12.SVMXC__Target_Field_Name__c ='SVMXC__Received_City__c' ; 
        FieldMapList.add(FieldMap12);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap13 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap13.RecordTypeId =Fieldmapping;
        FieldMap13.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap13.SVMXC__Display_Value__c ='Today' ;
        FieldMap13.SVMXC__Target_Field_Name__c ='SVMXC__Start_Date_and_Time__c';
        FieldMapList.add(FieldMap13); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap14 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap14.RecordTypeId =Fieldmapping;
        FieldMap14.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap14.SVMXC__Display_Value__c ='Tomorrow' ;
        FieldMap14.SVMXC__Target_Field_Name__c ='SVMXC__Canceled_On__c';
        FieldMapList.add(FieldMap14);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap15 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap15.RecordTypeId =Fieldmapping;
        FieldMap15.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap15.SVMXC__Display_Value__c ='Yesterday' ;
        FieldMap15.SVMXC__Target_Field_Name__c ='SVMXC__Closed_On__c';
        FieldMapList.add(FieldMap15);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap16 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap16.RecordTypeId =Fieldmapping;
        FieldMap16.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap16.SVMXC__Display_Value__c ='Yesterday' ;
        FieldMap16.SVMXC__Target_Field_Name__c ='SVMXC__Date_Requested__c';
        FieldMapList.add(FieldMap16);
        
        upsert FieldMapList; 
        map<String,Sobject> SourceRecIdTargetObjMap = new map<String,Sobject>();
        SourceRecIdTargetObjMap.put(wd.id,wd);
        MappingObj.getValueMapping(SobjList1, ObjectMap3.id, Allobj);
        new PREV_PMPlanUtils().getApplyMappingPmPlan(ObjectMap2.id,SourceRecIdTargetObjMap,false,Allobj);
        MappingObj.getValueMappingAsKeyValue(SobjList1, ObjectMap3.Id, Allobj);
        
        
    }
}