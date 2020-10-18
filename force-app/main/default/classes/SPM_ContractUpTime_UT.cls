@isTest
global class SPM_ContractUpTime_UT {
    
    private static RecordType spmRuleRecordType;
    private static RecordType spmDetailsRecordType;
    private static SVMXC__Service_Contract__c objContract;
    private static SVMXC__Service_Contract_Products__c objCoveredProduct = new SVMXC__Service_Contract_Products__c ();
    private static List<SVMXC__Down_Time__c> lstDownTime = new List<SVMXC__Down_Time__c>();
    
    static testMethod void Test_With_Start_End_Outside_of_previous_Month_In_Downtime() {
        setup();
        Id processId = insertProcess();
        insertConfigData1( processId );
        setupTestData();
        
        if(lstDownTime != null && lstDownTime.size()>0){
            lstDownTime[0].SVMXC__Duration__c = 0;
            lstDownTime[0].SVMXC__Start_Time__c = System.Now().addMonths(-2);
            lstDownTime[0].SVMXC__End_Time__c = System.Now().addMonths(-1);
            
            lstDownTime[1].SVMXC__Duration__c = 0;
            lstDownTime[1].SVMXC__Start_Time__c = System.Now().addMonths(-1);
            lstDownTime[1].SVMXC__End_Time__c = System.Now();
            
            update lstDownTime;
            
            objContract.SVMXC__Business_Hours__c = null;
            update objContract;
            Test.startTest();
            SPM_ContractUpTime upDwonTime = new SPM_ContractUpTime(null);
			System.assert(upDwonTime != null );
            Database.executeBatch(upDwonTime);
            Test.stopTest();
        }       
    }
	static testMethod void test_with_TrendingEnabled_Setting() {
        setup();
        Id processId = insertProcess();
        insertConfigData1( processId );
        setupTestData();
        
        if(lstDownTime != null && lstDownTime.size()>0){
            lstDownTime[0].SVMXC__Duration__c = 0;
            lstDownTime[0].SVMXC__Start_Time__c = System.Now().addMonths(-2);
            lstDownTime[0].SVMXC__End_Time__c = System.Now().addMonths(-1);
            
            lstDownTime[1].SVMXC__Duration__c = 0;
            lstDownTime[1].SVMXC__Start_Time__c = System.Now().addMonths(-1);
            lstDownTime[1].SVMXC__End_Time__c = System.Now();
            
            update lstDownTime;
            
            objContract.SVMXC__Business_Hours__c = null;
            update objContract;
            Test.startTest();
            SPM_ContractUpTime upDwonTime = new SPM_ContractUpTime(null);
			upDwonTime.isTrendingEnabled=true;
            System.assert(upDwonTime != null );
            Database.executeBatch(upDwonTime);
            Test.stopTest();
        }       
    }
    
    static testMethod void Test_With_No_Duration_In_Downtime() {
        setup();
        Id processId = insertProcess();
        insertConfigData1( processId );
        setupTestData();
        
        if(lstDownTime != null && lstDownTime.size()>0){
            lstDownTime[0].SVMXC__Duration__c = 0;
            lstDownTime[0].SVMXC__Start_Time__c = System.today().addDays(-2);
            lstDownTime[0].SVMXC__End_Time__c = System.today().addDays(-1);
            update lstDownTime[0];
            
            Test.startTest();
            SPM_ContractUpTime upDwonTime = new SPM_ContractUpTime(null);
            System.assert(upDwonTime != null );
            Database.executeBatch(upDwonTime);
            Test.stopTest();
        }       
    }
    
    static testMethod void Test_With_No_Start_End_Date_Of_Covered_Product() {
        setup();
        Id processId = insertProcess();
        insertConfigData1( processId );
        setupTestData();
        
        objCoveredProduct.SVMXC__Start_Date__c = null;
        objCoveredProduct.SVMXC__End_Date__c = null;
        update objCoveredProduct;
        
        Test.startTest();
        SPM_ContractUpTime upDwonTime = new SPM_ContractUpTime(null);
        System.assert(upDwonTime != null );
        Database.executeBatch(upDwonTime);
        Test.stopTest();
    }
    
    static testMethod void Test_with_Consider_Downtime() {
        setup();
        Id processId = insertProcess();
        insertConfigData1( processId );
        setupTestData();
        
        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        insert scheduleData;
        
        Test.startTest();
        SPM_ContractUpTime upDwonTime = new SPM_ContractUpTime(scheduleData);
        System.assert(upDwonTime != null );
        Database.executeBatch(upDwonTime);
        //Database.executeBatch(upDwonTime);
        Test.stopTest();
    }
    
    static testMethod void Test_With_Consider_Work_order() {
        setup();
        Id processId = insertProcess();
        insertConfigData2( processId );
        setupTestData();
        
        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        insert scheduleData;
        
        Test.startTest();
        SPM_ContractUpTime upDwonTime = new SPM_ContractUpTime(scheduleData);
        System.assert(upDwonTime != null );
        Database.executeBatch(upDwonTime);
        Database.executeBatch(upDwonTime);
        Test.stopTest();
    }
    
    private static void setup() {
        
        if( spmRuleRecordType == null ) {
            spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];    
        }
        
        if( spmDetailsRecordType == null ) {
            spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];    
        }        
    }
    
    private static void setupTestData() {
        Account acc = new Account();
        acc.Name = 'Account Name';
        insert acc;
        
        Product2 pro = new Product2();
        pro.Name = 'Product Name';
        pro.IsActive = true;
        insert pro;
        
        String BusiHourId = [SELECT Id FROM BusinessHours WHERE IsDefault = true].id;
        
        objContract = new SVMXC__Service_Contract__c();
        objContract.Name = 'New SPM Service Contract '+Math.round(Math.random()*500);
        objContract.SVMXC__Active__c = true;
        objContract.SVMXC__Company__c = acc.id;
        objContract.SVMXC__Start_Date__c = System.today().addMonths(-4);
        objContract.SVMXC__End_Date__c = System.today().addMonths(4);
        objContract.SVMXC__Business_Hours__c = BusiHourId;
        insert objContract;
        
        SVMXC__Installed_Product__c objInstalledProduct = new SVMXC__Installed_Product__c();
        objInstalledProduct.Name = 'IB00'+Math.round(Math.random()*30);
        objInstalledProduct.SVMXC__Product__c = pro.id;
        objInstalledProduct.SVMXC__Status__c = 'Installed';
        objInstalledProduct.SVMXC__Company__c = acc.id;
        objInstalledProduct.SVMXC__Serial_Lot_Number__c = 'SN000'+Math.round(Math.random()*30);
        objInstalledProduct.SVMXC__Date_Installed__c = System.today();
        insert objInstalledProduct;
        
        objCoveredProduct = new SVMXC__Service_Contract_Products__c ();
        objCoveredProduct.SVMXC__Service_Contract__c = objContract.id;
        objCoveredProduct.SVMXC__Installed_Product__c = objInstalledProduct.id;
        objCoveredProduct.SVMXC__Start_Date__c = objContract.SVMXC__Start_Date__c;
        objCoveredProduct.SVMXC__End_Date__c = objContract.SVMXC__End_Date__c;
        insert objCoveredProduct;
        
        SVMXC__Service_Order__c serviceOrder = new SVMXC__Service_Order__c();
        serviceOrder.SVMXC__Product__c = pro.Id;
        serviceOrder.SVMXC__Company__c = acc.Id;
        serviceOrder.SVMXC__Top_Level__c = objInstalledProduct.id;
        serviceOrder.SVMXC__Component__c = objInstalledProduct.id;
        serviceOrder.SVMXC__Service_Contract__c = objContract.id;
        serviceOrder.SVMXC__Closed_On__c = System.Now().addMonths(-1);
        insert serviceOrder;
        
        lstDownTime = new List<SVMXC__Down_Time__c>();
        SVMXC__Down_Time__c objDownTime = new SVMXC__Down_Time__c();
        objDownTime.SVMXC__Duration__c = 200;
        objDownTime.SVMXC__Service_Order__c = serviceOrder.id;
        objDownTime.SVMXC__Start_Time__c = System.Now().addMonths(-1);
        lstDownTime.add(objDownTime);
        
        SVMXC__Down_Time__c objDownTime1 = new SVMXC__Down_Time__c();
        objDownTime1.SVMXC__Service_Order__c = serviceOrder.id;
        objDownTime1.SVMXC__Start_Time__c = System.Now().addMonths(-1);
        objDownTime1.SVMXC__End_Time__c = System.Now().addMonths(-1).addMinutes(2);
        lstDownTime.add(objDownTime1);
        insert lstDownTime;
    }
    
    private static Id insertProcess() {
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.UpDownTime.name();
        process.SVMXC__Name__c = 'Contract Up Time';
        
        insert process;
        
        return process.Id;
    }
    
    private static void insertConfigData1( Id processId ) {
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.RecordTypeId = spmDetailsRecordType.Id;
        configData.SVMXC__Dispatch_Process__c = processId;
        configData.SVMXC__Formula__c = calculationMethod1;
        configData.SVMXC__Active__c = true;
        
        insert configData;
        calculationMethod1.replace( 'a10F0000006AhELIA0', configData.Id );
        
        configData.SVMXC__Formula__c = calculationMethod1;
        update configData;
    }
    
    //Consider downtime
    private static String calculationMethod1 = '{"targetObjectName":"SVMXC__SPM_Contract_Up_Time__c","targetObjectLabel":"SPM - Contract Up Time","sourceObjectName":"SVMXC__Service_Contract__c","sourceObjectLabel":"Service/Maintenance Contract","recordId":"a10F0000005PQmbIAG","parameterInfoList":[{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"InstallProduct","sourceFieldName":"SVMXC__Component__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Installed_Product__c","label":"Select the source for the Installed Product field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Contract__c","sourceObjectField":"BusinessHours","sourceFieldName":"SVMXC__Business_Hours__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"BusinessHours","label":"Select the source for the Business Hours field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"ClosedOn","sourceFieldName":"SVMXC__Closed_On__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the source for the Fixed On Date field","isPicklistValue":false,"isMultiSelect":false,"displayType":"DATETIME"},{"sourceObjectName":null,"sourceObjectField":"considerDownTimeFrom","sourceFieldName":"Down Time","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Consider Downtime from:","isPicklistValue":false,"isMultiSelect":false,"displayType":"PICKLIST"}],"objectMappingDetailsList":[{"targetObjectName":"SVMXC__SPM_Contract_Up_Time__c","sourceObjectName":"SVMXC__Service_Contract__c","referenceObjectName":false,"objectMappingList":null,"mapId":"NONE","label":"Select the Object Mapping to be applied for this metrics"}],"name":"CN-0002811687","methodDisplayName":null,"method":"SPMUPTIME: Subtract Downtime from Uptime","lastModifiedOn":"3/15/2016 3:13 PM","isActive":true,"expressionDetailsList":[{"sourceObjectName":null,"label":"Select the expression to qualify covered products for this metric","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"EXPR031"},{"sourceObjectName":"SVMXC__Service_Order__c","label":"Select the expression to qualify work orders for this metric","expressionType":"WorkOrderCriteria","expressionRuleList":null,"expressionRuleId":"EXPR086"}],"appliesTo":"Test"}';
    
    private static void insertConfigData2( Id processId ) {
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.RecordTypeId = spmDetailsRecordType.Id;
        configData.SVMXC__Dispatch_Process__c = processId;
        configData.SVMXC__Formula__c = calculationMethod2;
        configData.SVMXC__Active__c = true;
        
        insert configData;
        calculationMethod2.replace( 'a10F0000006AhELIA0', configData.Id );
        
        configData.SVMXC__Formula__c = calculationMethod2;
        update configData;
    }
    //Consider Work order
    private static String calculationMethod2 = '{"targetObjectName":"SVMXC__SPM_Contract_Up_Time__c","targetObjectLabel":"SPM - Contract Up Time","sourceObjectName":"SVMXC__Service_Contract__c","sourceObjectLabel":"Service/Maintenance Contract","recordId":"a10F0000005PQmbIAG","parameterInfoList":[{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"InstallProduct","sourceFieldName":"SVMXC__Component__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Installed_Product__c","label":"Select the source for the Installed Product field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Contract__c","sourceObjectField":"BusinessHours","sourceFieldName":"SVMXC__Business_Hours__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"BusinessHours","label":"Select the source for the Business Hours field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"ClosedOn","sourceFieldName":"SVMXC__Closed_On__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the source for the Fixed On Date field","isPicklistValue":false,"isMultiSelect":false,"displayType":"DATETIME"},{"sourceObjectName":null,"sourceObjectField":"considerDownTimeFrom","sourceFieldName":"Work Order","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Consider Downtime from:","isPicklistValue":false,"isMultiSelect":false,"displayType":"PICKLIST"}],"objectMappingDetailsList":[{"targetObjectName":"SVMXC__SPM_Contract_Up_Time__c","sourceObjectName":"SVMXC__Service_Contract__c","referenceObjectName":false,"objectMappingList":null,"mapId":"NONE","label":"Select the Object Mapping to be applied for this metrics"}],"name":"CN-0002811687","methodDisplayName":null,"method":"SPMUPTIME: Subtract Downtime from Uptime","lastModifiedOn":"3/15/2016 2:28 PM","isActive":true,"expressionDetailsList":[{"sourceObjectName":null,"label":"Select the expression to qualify covered products for this metric","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"EXPR031"},{"sourceObjectName":"SVMXC__Service_Order__c","label":"Select the expression to qualify work orders for this metric","expressionType":"WorkOrderCriteria","expressionRuleList":null,"expressionRuleId":"EXPR086"}],"appliesTo":"Test"}';  
}