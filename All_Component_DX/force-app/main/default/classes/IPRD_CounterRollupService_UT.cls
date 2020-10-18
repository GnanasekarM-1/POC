@isTest(seealldata = false)
public class IPRD_CounterRollupService_UT {
    static Map<String,Id> RecordTypeIdMap = new Map<String,Id> ();
    static testmethod void testRunRollupBatch(){
        //Inserting Configuration Data
        getRecordTypeIds();
        Id HeaderRecId = insertScheduleHeaderRecord();
        Map<String,Id> expressionMap = createExpressionProcess();
        Id schedulerDetailRecId = insertScheduleDetailRecord(HeaderRecId,expressionMap.get('SchedulerId')); 
        
        //Inserting Test Data
        Id ServiceContractId = insertServiceContract();
        Id ProdId = insertProduct();
        Id IBId = insertInstalledProd(ProdId,ServiceContractId);
        insertCoveredProduct(ServiceContractId,IBId);
        
        //Inserting Counter Definition and Counter Reading Records
         insertCounterDefinition(expressionMap.get('CounterRuleId'),IBId);  

        SVMXC__ServiceMax_Config_Data__c configRec = [SELECT Id, Namespace__c,
                                                             Class_Name__c,
                                                             Previous_Execution_Completed_On__c, Previous_Execution_Status__c, 
                                                             Previous_Execution_Started_On__c, Object_Name__c, 
                                                             Expression_Rule__r.Parent_Object_Criteria__c,
                                                             SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c, 
                                                             SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c, SVMXC__Dispatch_Process__r.SVMXC__Assign_To_Dispatcher__c,
                                                             SVMXC__Dispatch_Process__r.SVMXC__Capture_Log__c
                                                             FROM SVMXC__ServiceMax_Config_Data__c WHERE ID = :schedulerDetailRecId];
                
        test.startTest();
        SFM_ScheduledBatch batchInstance = new SFM_ScheduledBatch();
        batchInstance.scheduleDetailConfig = configRec;
        Database.executebatch(batchInstance);
        Database.executebatch(batchInstance);
        test.stopTest();
        
    }
    
    static Id insertScheduleHeaderRecord(){
        SVMXC__ServiceMax_Processes__c scheduleHeaderRec = new SVMXC__ServiceMax_Processes__c();
        scheduleHeaderRec.RecordtypeId = RecordTypeIdMap.get('Schedule_Header');
        scheduleHeaderRec.SVMXC__Name__c = 'Test Scheduler Header';
        scheduleHeaderRec.SVMXC__ProcessID__c = 'Test_Scheduler_Header';
        scheduleHeaderRec.SVMXC__Active__c = true;
        scheduleHeaderRec.SVMXC__Dispatch_Timezone__c = 'Asia/Kolkata';
        scheduleHeaderRec.SVMXC__Assign_To_Dispatcher__c = userinfo.getUserId() ;
        scheduleHeaderRec.SVMXC__Capture_Log__c = true;
        insert scheduleHeaderRec;
        return scheduleHeaderRec.Id;
    }
    
    static Map<String,Id> createExpressionProcess(){
        List<SVMXC__ServiceMax_Processes__c> ruleList = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> exprList = new List<SVMXC__ServiceMax_Config_Data__c>();
        Map<String,Id> expressionMap = new Map<String,Id>();
        
        SVMXC__ServiceMax_Processes__c expressionProcess = new SVMXC__ServiceMax_Processes__c();
        expressionProcess.RecordTypeId = recordTypeIdMap.get('SVMX_Rule');
        expressionProcess.SVMXC__Name__c = 'Test Rule Expression';
        expressionProcess.SVMXC__ProcessID__c = 'Test_Rule_Expression_for_Rollup';
        expressionProcess.SVMXC__Rule_Type__c = 'Named Expression';
        expressionProcess.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Contract__c';
        expressionProcess.SVMXC__Parent_Error_Msg__c = 'This record does not meet the qualification criteria for this SFM Transaction';
        expressionProcess.SVMXC__Parent_Object_Criteria__c = 'SVMXC__Active__c = True';
        expressionProcess.SVMXC__SettingID__c = 'Test_Rule_Expression_for_Rollup';
        ruleList.add(expressionProcess);
        
        SVMXC__ServiceMax_Processes__c counterRule = new SVMXC__ServiceMax_Processes__c();
        counterRule.RecordTypeId = recordTypeIdMap.get('SVMX_Rule');
        counterRule.SVMXC__Name__c = 'Test Counter Rule';
        counterRule.SVMXC__ProcessID__c = 'Test_Counter_Rule';
        counterRule.SVMXC__Rule_Type__c = 'Counters';
        counterRule.SVMXC__Parent_Object_Criteria__c = 'IsActive=True';
        ruleList.add(counterRule);
        
        insert ruleList;
        expressionMap.put('SchedulerId',expressionProcess.Id);
        expressionMap.put('CounterRuleId',counterRule.Id);
        
        SVMXC__ServiceMax_Config_Data__c expressionConfig = new SVMXC__ServiceMax_Config_Data__c();
        expressionConfig.RecordTypeId = recordTypeIdMap.get('Expressions');
        expressionConfig.SVMXC__Field_Name__c = 'SVMXC__Active__c';
        expressionConfig.SVMXC__Display_Type__c = 'boolean';
        expressionConfig.SVMXC__Expression_Type__c = 'EXP_Named';
        expressionConfig.SVMXC__Ownership_Type__c = 'All Records';
        expressionConfig.SVMXC__Operand__c = 'True';
        expressionConfig.SVMXC__Operator__c = 'eq';
        expressionConfig.SVMXC__Sort_Order__c = 'Ascending';
        expressionConfig.SVMXC__Expression_Rule__c = expressionProcess.Id;
        exprList.add(expressionConfig);
        
        SVMXC__ServiceMax_Config_Data__c ruleExp = new SVMXC__ServiceMax_Config_Data__c();
        ruleExp.RecordTypeId = recordTypeIdMap.get('Expressions');
        ruleExp.SVMXC__Field_Name__c = 'IsActive';
        ruleExp.SVMXC__Display_Type__c = 'BOOLEAN';
        ruleExp.SVMXC__Expression_Type__c = 'IPRD_Counters';
        ruleExp.SVMXC__Ownership_Type__c = 'All Records';
        ruleExp.SVMXC__Operand__c = 'True';
        ruleExp.SVMXC__Operator__c = 'eq';
        ruleExp.SVMXC__Sort_Order__c = 'Ascending';
        ruleExp.SVMXC__Expression_Rule__c = counterRule.Id;
        exprList.add(ruleExp);
        insert exprList;
        return expressionMap;
        
        
    }    
    Static Id insertScheduleDetailRecord(Id HeaderRecId,Id expressionID){
        SVMXC__ServiceMax_Config_Data__c scheduleDetailRec = new SVMXC__ServiceMax_Config_Data__c();  
        scheduleDetailRec.recordTypeId = RecordTypeIdMap.get('Schedule_Detail');
        scheduleDetailRec.SVMXC__Schedule_Type__c = 'Services';
        scheduleDetailRec.SVMXC__Class_Name__c = 'IPRD_CounterRollupService';
        scheduleDetailRec.SVMXC__Active__c = true;
        scheduleDetailRec.SVMXC__Object_Name__c = 'SVMXC__Service_Contract__c';
        scheduleDetailRec.SVMXC__Dispatch_Process__c = HeaderRecId;
        scheduleDetailRec.SVMXC__Expression_Rule__c = expressionID;
        insert scheduleDetailRec;
        return scheduleDetailRec.Id;
    }
    
    static Id insertServiceContract(){
        SVMXC__Service_Contract__c serviceContract = new SVMXC__Service_Contract__c();
        serviceContract.SVMXC__Active__c = true;
        serviceContract.SVMXC__Start_Date__c = System.today() - 30 ;
        serviceContract.SVMXC__End_Date__c = System.today() + 30;
        insert serviceContract;
        return serviceContract.Id;
    } 
    
    static void insertCoveredProduct(Id ServiceContractId,Id IBId){
        SVMXC__Service_Contract_Products__c covProduct = new SVMXC__Service_Contract_Products__c();
        covProduct.SVMXC__Service_Contract__c = ServiceContractId;
        covProduct.SVMXC__Installed_Product__c = IBId;
        insert covProduct;
    }
    
    static Id insertInstalledProd(Id prodId,Id ServiceContractId){
        SVMXC__Installed_Product__c installProd = new SVMXC__Installed_Product__c();    
        installProd.SVMXC__Product__c = prodId;
        installProd.SVMXC__Service_Contract__c = ServiceContractId;
        installProd.SVMXC__Status__c = 'Installed';
        insert installProd;
        return installProd.Id;
    }
    
    static Id insertProduct(){
        Product2 prodRec = new Product2();
        prodRec.Name = 'Test Product';
        prodRec.IsActive = true;
        insert prodRec;
        return prodRec.Id;
    }
    
    static void insertCounterDefinition(Id counterDefId,Id IBId){
        List<SVMXC__Counter_Details__c> DefnList = new List<SVMXC__Counter_Details__c>();
        SVMXC__Counter_Details__c counterDef1 = new SVMXC__Counter_Details__c();
        counterDef1.SVMXC__Counter_Name__c = 'Counter Def 1';
        counterDef1.SVMXC__Counter_Type__c = 'Increasing';
        counterDef1.SVMXC__Counter_Rule__c = counterDefId;
        counterDef1.RecordTypeId = RecordTypeIdMap.get('Definition');
        counterDef1.SVMXC__Max_Value__c = 100;
        counterDef1.SVMXC__Min_Value__c = 0;
        counterDef1.SVMXC__Grows_Reduces_By__c = 1;
        DefnList.add(counterDef1);
       
        SVMXC__Counter_Details__c counterDef2 = new SVMXC__Counter_Details__c();
        counterDef2.SVMXC__Counter_Name__c = 'Counter Def 2';
        counterDef2.SVMXC__Counter_Type__c = 'Increasing';
        counterDef2.SVMXC__Counter_Rule__c = counterDefId;
        counterDef2.RecordTypeId = RecordTypeIdMap.get('Definition');
        counterDef2.SVMXC__Max_Value__c = 100;
        counterDef2.SVMXC__Min_Value__c = 0;
        counterDef2.SVMXC__Grows_Reduces_By__c = 1;   
        DefnList.add(counterDef2);
        
        insert DefnList;
        DefnList.clear();
        
        SVMXC__Counter_Details__c counterRead1 = new SVMXC__Counter_Details__c();
        counterRead1.SVMXC__Counter_Name__c = 'Counter Read 1';
        counterRead1.SVMXC__Counter_Type__c = 'Increasing';
        counterRead1.RecordTypeId = RecordTypeIdMap.get('Reading');
        counterRead1.SVMXC__Max_Value__c = 100;
        counterRead1.SVMXC__Min_Value__c = 0;
        counterRead1.SVMXC__Counter_Reading__c = 0;
        counterRead1.SVMXC__Is_Latest__c = true;
        counterRead1.SVMXC__Counter_Definition__c = counterDef1.id;
        counterRead1.SVMXC__Installed_Product__c = IBId;
        counterRead1.SVMXC__Reading_Date__c = system.now();
        counterRead1.SVMXC__Last_Reading__c = 0;
        DefnList.add(counterRead1);    
        
        SVMXC__Counter_Details__c counterRead2 = new SVMXC__Counter_Details__c();
        counterRead2.SVMXC__Counter_Name__c = 'Counter Read 1';
        counterRead2.SVMXC__Counter_Type__c = 'Increasing';
        counterRead2.RecordTypeId = RecordTypeIdMap.get('Reading');
        counterRead2.SVMXC__Max_Value__c = 100;
        counterRead2.SVMXC__Min_Value__c = 0;
        counterRead2.SVMXC__Counter_Reading__c = 0;
        counterRead2.SVMXC__Is_Latest__c = true;
        counterRead2.SVMXC__Counter_Definition__c = counterDef2.id;
        counterRead2.SVMXC__Installed_Product__c = IBId;
        counterRead2.SVMXC__Reading_Date__c = system.now();
        DefnList.add(counterRead2);         
        
        insert DefnList;
        
    }
    
    static void getRecordTypeIds(){
        for(RecordType rec : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c','SVMXC__Counter_Details__c') AND isActive = true]){
           recordTypeIdMap.put(rec.DeveloperName, rec.Id); 
        }        
    }
}