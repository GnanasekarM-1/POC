@isTest(seeAllData = true)
class PREV_Conditional_Engine_Batch_UT {
    
    static Map<String,Id> recordTypeIdMap = new Map<String,Id>();
    static List<SVMXC__ServiceMax_Config_Data__c> configRecordList = new List<SVMXC__ServiceMax_Config_Data__c>();
    //static Id conditionPMPlanId;
    
    static testMethod void invoke_Conditional_PM_Engine_TestMethod(){
        getRecordtypeIdMap();
       
        Id processId = insertConditionProcess();
        Id conditionPMPlanId = insertPMPlan();
        insertCoverages(conditionPMPlanId);
        
        test.startTest();
        PREV_Conditional_Engine_Batch batchable = new PREV_Conditional_Engine_Batch();
        batchable.setProcessIds = new Set<String>{processId}; //Conditional Process IDs
        
        Database.executeBatch(batchable);
        test.stopTest();
    }
    
    static testMethod void invoke_Future_Adjustment_TestMethod(){
        getRecordtypeIdMap();
       
        Id processId = insertConditionProcess();
        Id conditionPMPlanId = insertPMPlan();
        insertCoverages(conditionPMPlanId);
        createWorkOrder(conditionPMPlanId);
        test.startTest();
        List<SVMXC__Service_Order__c> woList = [SELECT Id, SVMXC__PM_Plan__c, SVMXC__PM_Plan__r.SVMXC__SM_Adjustment_Activity_Date__c, SVMXC__SM_PM_Activity__c FROM SVMXC__Service_Order__c WHERE SVMXC__PM_Plan__c =: conditionPMPlanId];
        
        woList[0].SVMXC__Completed_Date_Time__c = Datetime.newInstance(2017, 15, 01);
        update woList;
        test.stopTest();
    }
    
    static testMethod void invoke_Criteria_Based_TestMethod(){
        getRecordtypeIdMap();
       
        Id processId = insertConditionProcess();
        Id conditionPMPlanId = insertCriteriaPMPlan();
        insertCriteriaCoverages(conditionPMPlanId);
        
        
        PREV_Conditional_Engine_Batch batchable = new PREV_Conditional_Engine_Batch();
        batchable.setProcessIds = new Set<String>{processId}; //Conditional Process IDs
        
        Database.executeBatch(batchable);
        
        test.startTest();
        Database.executeBatch(batchable);
        test.stopTest();     
        
    } 
    
    static testMethod void negative_Case_TestMethod (){
        getRecordtypeIdMap();
       
        Id processId = insertConditionProcess();
        Id conditionPMPlanId = insertCriteriaPMPlan();
        insertCriteriaCoverages(conditionPMPlanId); 
        List<SVMXC__PM_Schedule__c> pmScheduleList = [SELECT Id,SVMXC__SM_Expression_Internal_Value__c FROM SVMXC__PM_Schedule__c 
                                                        WHERE SVMXC__PM_Plan__c =: conditionPMPlanId];
        System.assert(pmScheduleList.size() > 0);
        pmScheduleList[0].SVMXC__SM_Expression_Internal_Value__c = '{"Rule": [' +
                                                                   '{"Order": "1","attrName": "Temperature","operator": "EQ","attrValue": "30.5","datatype": "Number","attrType": "Technical","stopAt": "32","adjType": "fixed","adjValue": "0.5","adjMin": "0.25","adjMax": "1","adjUnit": "count"' +
                                                                   '{"Order": "2","attrName": "Today","operator": "gt","attrValue": "2017-01-01","datatype": "Date","attrType": "Literal","stopAt": "2017-02-05","adjType": "Actual","adjValue": "","adjMin": "5","adjMax": "30","adjUnit": "days" }'+
                                                                   '{"Order": "3","attrName": "SVMXC__Longitude__c","operator": "lt","attrValue": "120","datatype": "Number","attrType": "Schema","stopAt": "50","adjType": "Actual","adjValue": "","adjMin": "10","adjMax": "30","adjUnit": "count" }]}';
        update pmScheduleList;
        
        test.startTest();
        PREV_Conditional_Engine_Batch batchable = new PREV_Conditional_Engine_Batch();
        batchable.setProcessIds = new Set<String>{processId}; //Conditional Process IDs
        
        Database.executeBatch(batchable);           
        test.stopTest();
    } 
        
    static void createWorkOrder(Id conditionPMPlanId){
       
        SVMXC__Service_Order__c workOrderRec1 = new SVMXC__Service_Order__c(SVMXC__PM_Plan__c = conditionPMPlanId, SVMXC__Is_PM_Work_Order__c = true);
        insert workOrderRec1;
        
        List<SVMXC__PM_Schedule__c> pmScheduleList = [SELECT Id, SVMXC__SM_PM_Coverage__c, SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c, SVMXC__SM_Status__c FROM SVMXC__PM_Schedule__c WHERE 
                                                  SVMXC__SM_Sequence__c = 1 AND SVMXC__PM_Plan__c =: conditionPMPlanId];

        System.assert(pmScheduleList.size() == 1, 'PM Schedules not found');
        pmScheduleList[0].SVMXC__SM_Status__c = 'Work Order Created';
        update pmScheduleList;
        
        

              
        SVMXC__PM_History__c pmHistory = new SVMXC__PM_History__c();    
        pmHistory.SVMXC__Installed_Product__c =   pmScheduleList[0].SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c;
        pmHistory.SVMXC__PM_Plan__c =  conditionPMPlanId;
        pmHistory.SVMXC__SM_PM_Schedule__c =  pmScheduleList[0].Id;
        pmHistory.SVMXC__Work_Order__c = workOrderRec1.Id;   
       insert pmHistory;
        
       
    }
    
    static void getRecordtypeIdMap(){
        for(RecordType recordtypeRec : [SELECT Id, Name FROM RecordType WHERE sObjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c','SVMXC__Task_Template__c') AND isActive = true]){
            recordTypeIdMap.put(recordtypeRec.Name, recordtypeRec.Id);
        }
    }
   
    static Id insertCriteriaPMPlan(){
        SVMXC__PM_Plan__c pmPlan = new SVMXC__PM_Plan__c();
        pmPlan.Name = 'Conditional Test Plan UT';
        pmPlan.SVMXC__Status__c = 'Active';
        pmPlan.SVMXC__Schedule_Type__c = 'Condition Based';
        pmPlan.SVMXC__SM_Condition_Type__c = 'Criteria_Comparison';
        pmPlan.SVMXC__Coverage_Type__c = 'Product';
        pmPlan.SVMXC__Start_Date__c = System.today();
        pmPlan.SVMXC__End_Date__c = System.today() + 365; 
        pmPlan.SVMXC__SM_Adjustment_Activity_Date__c = 'SVMXC__Completed_Date_Time__c';
        pmPlan.OwnerId = Userinfo.getUserId();
        insert pmPlan;
        return pmPlan.Id;
    }
    
    static Id insertPMPlan(){
        SVMXC__PM_Plan__c pmPlan = new SVMXC__PM_Plan__c();
        pmPlan.Name = 'Conditional Test Plan UT';
        pmPlan.SVMXC__Status__c = 'Active';
        pmPlan.SVMXC__Schedule_Type__c = 'Condition Based';
        pmPlan.SVMXC__Coverage_Type__c = 'Product';
        pmPlan.SVMXC__Start_Date__c = System.today();
        pmPlan.SVMXC__End_Date__c = System.today() + 365; 
        pmPlan.SVMXC__SM_Adjustment_Activity_Date__c = 'SVMXC__Completed_Date_Time__c';
        pmPlan.OwnerId = Userinfo.getUserId();
        insert pmPlan;
        return pmPlan.Id;
    }
    
    static void insertCriteriaCoverages(Id pmPlanId){
        SVMXC__PM_Coverage__c coverage1 = new SVMXC__PM_Coverage__c();
        coverage1.SVMXC__PM_Plan__c = pmPlanId;
        coverage1.SVMXC__SM_Advanced_Expression__c = '1 OR 2 OR 3';
        coverage1.SVMXC__Product_Name__c = insertInstalledProduct();
        insert coverage1;
        insertCriteriaPMSchedules(pmPlanId,coverage1.Id);
    }
    
    static void insertCriteriaPMSchedules(Id planId, Id coverageId){
        List<SVMXC__PM_Schedule__c> scheduleOutputList = new List<SVMXC__PM_Schedule__c>();

        SVMXC__PM_Schedule__c scheduleOutput1 = new SVMXC__PM_Schedule__c();
        scheduleOutput1.SVMXC__SM_Work_Order_Purpose__c = insertTaskTemplate();
        scheduleOutput1.SVMXC__PM_Plan__c = planId;
        scheduleOutput1.SVMXC__SM_PM_Coverage__c = coverageId;
        scheduleOutput1.SVMXC__SM_Expression_Internal_Value__c = '{"Rules": [' +
                                                                   '{"Order": "1","attrName": "Temperature","operator": "EQ","attrValue": "30.5","datatype": "Number","attrType": "Technical","stopAt": "32","adjType": "fixed","adjValue": "0.5","adjMin": "0.25","adjMax": "1","adjUnit": "count"},' +
                                                                   '{"Order": "2","attrName": "Today","operator": "gt","attrValue": "2017-01-01","datatype": "Date","attrType": "Literal","stopAt": "2017-02-05","adjType": "Actual","adjValue": "","adjMin": "5","adjMax": "30","adjUnit": "days" },'+
                                                                   '{"Order": "3","attrName": "SVMXC__Longitude__c","operator": "lt","attrValue": "120","datatype": "Number","attrType": "Schema","stopAt": "50","adjType": "Actual","adjValue": "","adjMin": "10","adjMax": "30","adjUnit": "count" }]}';
        scheduleOutput1.SVMXC__SM_Sequence__c = 1;
        scheduleOutputList.add(scheduleOutput1);


        insert scheduleOutputList;
    }    
    static void insertCoverages(Id pmPlanId){
        SVMXC__PM_Coverage__c coverage1 = new SVMXC__PM_Coverage__c();
        coverage1.SVMXC__PM_Plan__c = pmPlanId;
        coverage1.SVMXC__SM_Advanced_Expression__c = '1 OR 2 OR 3';
        coverage1.SVMXC__Product_Name__c = insertInstalledProduct();
        insert coverage1;
        insertPMSchedules(pmPlanId,coverage1.Id);
    }

    static Id insertTaskTemplate(){
        SVMXC__Task_Template__c taskTemplate = new SVMXC__Task_Template__c();
        taskTemplate.SVMXC__Template_Name__c = 'Test Template';
        taskTemplate.SVMXC__Template_Type__c = 'Preventive Maintenance';
        taskTemplate.RecordTypeId = recordTypeIdMap.get('Templates');
        insert taskTemplate;

        SVMXC__Task_Template__c taskTemplate2 = new SVMXC__Task_Template__c();
        taskTemplate2.SVMXC__Template_Name__c = 'Test Template';
        taskTemplate2.SVMXC__Template_Type__c = 'Preventive Maintenance';
        taskTemplate2.RecordTypeId = recordTypeIdMap.get('Tasks');
        taskTemplate2.SVMXC__Task_Template__c = taskTemplate.Id; 
        taskTemplate2.SVMXC__Description__c = 'Test Description';
        taskTemplate2.SVMXC__Priority__c = 'High';
        insert taskTemplate2;

        SVMXC__Required_Part__c requiredPart = new SVMXC__Required_Part__c();
        requiredPart.SVMXC__Product__c = insertProduct('Child Product'); 
        requiredPart.SVMXC__Quantity__c = 2;
        requiredPart.SVMXC__Work_Order_Purpose__c = taskTemplate.Id;
        insert requiredPart;

        return taskTemplate.Id;
    }

    static void insertPMSchedules(Id planId, Id coverageId){
        List<SVMXC__PM_Schedule__c> scheduleOutputList = new List<SVMXC__PM_Schedule__c>();

        SVMXC__PM_Schedule__c scheduleOutput1 = new SVMXC__PM_Schedule__c();
        scheduleOutput1.SVMXC__SM_Work_Order_Purpose__c = insertTaskTemplate();
        scheduleOutput1.SVMXC__PM_Plan__c = planId;
        scheduleOutput1.SVMXC__SM_PM_Coverage__c = coverageId;
        scheduleOutput1.SVMXC__SM_Expression_Internal_Value__c = '{"Rules": [' +
                                                                   '{"Order": "1","attrName": "Temperature","operator": "EYI","attrValue": "30.5","datatype": "Number","attrType": "Technical","stopAt": "32","adjType": "fixed","adjValue": "0.5","adjMin": "0.25","adjMax": "1","adjUnit": "count"},' +
                                                                   '{"Order": "2","attrName": "Today","operator": "EYI","attrValue": "2017-01-01","datatype": "Date","attrType": "Literal","stopAt": "2017-02-05","adjType": "Actual","adjValue": "","adjMin": "5","adjMax": "30","adjUnit": "days" },'+
                                                                   '{"Order": "3","attrName": "SVMXC__Longitude__c","operator": "EYD","attrValue": "120","datatype": "Number","attrType": "Schema","stopAt": "50","adjType": "Actual","adjValue": "","adjMin": "10","adjMax": "30","adjUnit": "count" }]}';
        scheduleOutput1.SVMXC__SM_Sequence__c = 1;
        scheduleOutputList.add(scheduleOutput1);

        SVMXC__PM_Schedule__c scheduleOutput2 = new SVMXC__PM_Schedule__c();
        scheduleOutput2.SVMXC__SM_Work_Order_Purpose__c = insertTaskTemplate();
        scheduleOutput2.SVMXC__PM_Plan__c = planId;
        scheduleOutput2.SVMXC__SM_PM_Coverage__c = coverageId;
        scheduleOutput2.SVMXC__SM_Expression_Internal_Value__c = '{"Rules": [{"Order": "1","attrName": "Temperature","operator": "EYI","attrValue": "31","datatype": "Number","attrType": "Technical","stopAt": "32","adjType": "fixed","adjValue": "0.5","adjMin": "0.25","adjMax": "1","adjUnit": "count"},' +
                                                                   '{"Order": "2","attrName": "Today","operator": "EYI","attrValue": "2017-02-01","datatype": "Date","attrType": "Literal","stopAt": "2017-02-05","adjType": "Actual","adjValue": "","adjMin": "5","adjMax": "30","adjUnit": "days"},' +
                                                                   '{"Order": "3","attrName": "SVMXC__Longitude__c","operator": "EYD","attrValue": "100","datatype": "Number","attrType": "Schema","stopAt": "50","adjType": "Actual","adjValue": "","adjMin": "10","adjMax": "30","adjUnit": "count" }]}';
        scheduleOutput2.SVMXC__SM_Sequence__c = 2;
        scheduleOutputList.add(scheduleOutput2);

        insert scheduleOutputList;
    }

    static Id insertInstalledProduct(){
        SVMXC__Installed_Product__c installedProduct = new SVMXC__Installed_Product__c();
        installedProduct.SVMXC__Status__c = 'Installed';
        installedProduct.Name = 'Test IB';
        installedProduct.SVMXC__Product__c = insertProduct('test Product');
        installedProduct.SVMXC__Preferred_Technician__c = insertGroupMember();
        installedProduct.SVMXC__Longitude__c = 100;
        insert installedProduct;

        SVMXC__SM_IB_Technical_Attributes__c ibAttribute = new SVMXC__SM_IB_Technical_Attributes__c();
        ibAttribute.SVMXC__SM_Attr_Name__c = 'Temperature';
        ibAttribute.SVMXC__SM_Attr_Value__c = '31';
        ibAttribute.SVMXC__SM_IsActive__c = true;
        ibAttribute.SVMXC__SM_Installed_Product_id__c = installedProduct.Id;
        insert ibAttribute;

        return installedProduct.Id;

    }
    
    static Id insertGroupMember(){
        SVMXC__Service_Group_Members__c groupMem = new SVMXC__Service_Group_Members__c();
        groupMem.SVMXC__Salesforce_User__c = insertUser();
        groupMem.SVMXC__Active__c = true;
        groupMem.SVMXC__Service_Group__c = insertServiceGroup();
        insert groupMem;
        return groupMem.Id;
    }
    
    static Id insertServiceGroup(){
        SVMXC__Service_Group__c serGroup = new SVMXC__Service_Group__c();
        serGroup.SVMXC__Active__c = true;
        serGroup.SVMXC__Group_Type__c = 'Both';
        serGroup.Name = 'testgroup';
        insert serGroup;
        return serGroup.Id;
    }
    
    static Id insertUser(){
        Profile profileRec = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User userRec = new User(Alias = 'technu', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='TechnicianUser1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileRec.Id, isActive=true,
            TimeZoneSidKey='America/Los_Angeles', UserName='techUser@servicemax.com');
        insert userRec;
        return userRec.Id;
    } 

    static Id insertProduct(String name){
        Product2 prodRecord = new Product2();
        prodRecord.Name = name;
        insert prodRecord;
        return prodRecord.Id;
    } 
    
    static Id insertConditionProcess(){

        SVMXC__ServiceMax_Processes__c conditional_PMProcess = new SVMXC__ServiceMax_Processes__c();
        conditional_PMProcess.SVMXC__Name__c = 'Conditional Test Process UT';
        conditional_PMProcess.SVMXC__ProcessID__c = 'Conditional_Test_Process_UT';
        conditional_PMProcess.SVMXC__Description__c = 'For Testing';        
        conditional_PMProcess.RecordTypeId = recordTypeIdMap.get('PM Process');
        conditional_PMProcess.SVMXC__Create_Work_Order__c = 'One per Product';
        conditional_PMProcess.SVMXC__Frequency__c = 365;
        conditional_PMProcess.SVMXC__Active__c = true;
        conditional_PMProcess.SVMXC__Product_Match_Enabled__c = true;
        conditional_PMProcess.SVMXC__Email_On_Error__c = 'sachin.s@servicemax.com';
        conditional_PMProcess.SVMXC__Email_On_Success__c = 'sachin.s@servicemax.com';
        conditional_PMProcess.SVMXC__Target_Object_Name__c = 'Task';
        conditional_PMProcess.SVMXC__Capture_Log__c = true;
        conditional_PMProcess.SVMXC__Include_Parent__c = true;
        conditional_PMProcess.SVMXC__Assign_Case_To__c = 'User';
        conditional_PMProcess.SVMXC__Case_Assign_To_User__c = UserInfo.getUserId();
        conditional_PMProcess.SVMXC__Assign_Work_Order_To__c = 'Primary Technician';
        conditional_PMProcess.SVMXC__SM_Do_Not_Create_New_WO__c = true;
        conditional_PMProcess.SVMXC__SM_Do_Not_Create_WO_Within__c = 5;
        conditional_PMProcess.SVMXC__Module__c = insertCriteria();
        
        conditional_PMProcess.SVMXC__Process__c = insertMappingProcess('SVMXC__Service_Order__c', 'Case', 'WOTOCASE');
        insertFieldMappingWOCase(conditional_PMProcess.SVMXC__Process__c);

        conditional_PMProcess.SVMXC__Process1__c = insertMappingProcess('SVMXC__Task_Template__c', 'Task','TemplateToTask');
        insertFieldMappingTemplateTask(conditional_PMProcess.SVMXC__Process1__c);

        conditional_PMProcess.SVMXC__Process2__c = insertMappingProcess('SVMXC__Required_Part__c', 'SVMXC__Service_Order_Line__c', 'PartToWorkOrderLine');
        insertFieldMappingPartWOLine(conditional_PMProcess.SVMXC__Process2__c);        

        conditional_PMProcess.SVMXC__Node_Parent__c = insertMappingProcess('SVMXC__Installed_Product__c', 'SVMXC__Service_Order__c', 'IBtoWorkOrder');
        insertFieldMappingPartIBWO(conditional_PMProcess.SVMXC__Node_Parent__c); 

        if(!configRecordList.isEmpty())
            insert configRecordList;

        insert conditional_PMProcess;
        return conditional_PMProcess.Id;
    }

    Static Id insertCriteria(){
        SVMXC__ServiceMax_Processes__c criteriaRuleProcess = new SVMXC__ServiceMax_Processes__c();
        criteriaRuleProcess.SVMXC__Rule_Type__c = 'Named Expression';
        criteriaRuleProcess.RecordTypeId = recordTypeIdMap.get('SVMX Rule');
        criteriaRuleProcess.SVMXC__Source_Object_Name__c = 'SVMXC__PM_Plan__c';
        criteriaRuleProcess.SVMXC__SettingID__c = 'SampleTestRule';
        criteriaRuleProcess.SVMXC__Advance_Expression__c = '1';
        criteriaRuleProcess.SVMXC__Parent_Object_Criteria__c = 'Name =\'Conditional Test Plan UT\'';
        insert criteriaRuleProcess;
        return criteriaRuleProcess.Id;
    }

    static Id insertMappingProcess(String sourceObjName, String targetObjName, String mappingId){
        SVMXC__ServiceMax_Processes__c mappingProcess = new SVMXC__ServiceMax_Processes__c();
        mappingProcess.SVMXC__MapID__c = mappingId;
        mappingProcess.SVMXC__Name__c = mappingId;
        mappingProcess.RecordTypeId = recordTypeIdMap.get('Object Mapping');
        mappingProcess.SVMXC__Source_Object_Name__c = sourceObjName;
        mappingProcess.SVMXC__Target_Object_Name__c = targetObjName;
        mappingProcess.SVMXC__Active__c = true;
        insert mappingProcess;
        return mappingProcess.Id;
    }

    static void insertFieldMappingWOCase(Id mappingProcessID){
        
        SVMXC__ServiceMax_Config_Data__c configData = createMappingInstance(mappingProcessID);
        configData.SVMXC__Source_Field_Name__c = 'SVMXC__Company__c';
        configData.SVMXC__Target_Field_Name__c = 'AccountId';
        configRecordList.add(configData);

        SVMXC__ServiceMax_Config_Data__c configData2 = createMappingInstance(mappingProcessID);
        configData.SVMXC__Source_Field_Name__c = 'SVMXC__Contact__c';
        configData.SVMXC__Target_Field_Name__c = 'ContactId';
        configRecordList.add(configData2);

    }

    static void insertFieldMappingTemplateTask(Id mappingProcessID){


        SVMXC__ServiceMax_Config_Data__c configData = createMappingInstance(mappingProcessID);
        configData.SVMXC__Source_Field_Name__c = 'SVMXC__Description__c';
        configData.SVMXC__Target_Field_Name__c = 'Description';
        configRecordList.add(configData);

        SVMXC__ServiceMax_Config_Data__c configData2 = createMappingInstance(mappingProcessID);
        configData.SVMXC__Source_Field_Name__c = 'SVMXC__Priority__c';
        configData.SVMXC__Target_Field_Name__c = 'Priority';
        configRecordList.add(configData2);

    }

    static void insertFieldMappingPartWOLine(Id mappingProcessID){

        SVMXC__ServiceMax_Config_Data__c configData = createMappingInstance(mappingProcessID);
        configData.SVMXC__Display_Value__c = 'Usage/Consumption';
        configData.SVMXC__Target_Field_Name__c = 'RecordTypeId';
        configRecordList.add(configData);

        SVMXC__ServiceMax_Config_Data__c configData2 = createMappingInstance(mappingProcessID);
        configData.SVMXC__Display_Value__c = 'Parts';
        configData.SVMXC__Target_Field_Name__c = 'SVMXC__Line_Type__c';
        configRecordList.add(configData2);


    }  

    static void insertFieldMappingPartIBWO(Id mappingProcessID){

        SVMXC__ServiceMax_Config_Data__c configData = createMappingInstance(mappingProcessID);
        configData.SVMXC__Source_Field_Name__c = 'SVMXC__Company__c';
        configData.SVMXC__Target_Field_Name__c = 'SVMXC__Company__c';
        configRecordList.add(configData);

        SVMXC__ServiceMax_Config_Data__c configData2 = createMappingInstance(mappingProcessID);
        configData.SVMXC__Source_Field_Name__c = 'Id';
        configData.SVMXC__Target_Field_Name__c = 'SVMXC__Component__c';
        configRecordList.add(configData2);

    }      

    static SVMXC__ServiceMax_Config_Data__c createMappingInstance(Id mappingProcessID){
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.RecordTypeId = recordTypeIdMap.get('Field Mapping');
        configData.SVMXC__Configuration_Type__c = 'Field Mapping';
        configData.SVMXC__Active__c = true;
        //configData.SVMXC__Source_Field_Name__c = 'SVMXC__Description__c';
        configData.SVMXC__MapID__c = mappingProcessID;
        return configData;
    }
}