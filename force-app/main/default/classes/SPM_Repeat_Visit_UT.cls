@isTest
public class SPM_Repeat_Visit_UT {
    
    private static RecordType spmRuleRecordType;
    private static RecordType spmDetailsRecordType;
    
    static testMethod void testBasicFlow(){
        setup();
        Id processId = insertProcess();
        insertConfigData(processId, calculationMethod);
        insertWorkOrders();
        
        SPM_Repeat_Visit RepeatVisitFlow = new SPM_Repeat_Visit(null);
        System.assert(RepeatVisitFlow != null);
        
        Test.startTest();
        
        Database.QueryLocator queryLocator = RepeatVisitFlow.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        RepeatVisitFlow.execute(null, records); 
        RepeatVisitFlow.finish(null);
        Test.stopTest();
    }
    
    static testMethod void testBasicFlowWithSchedule(){
        setup();
        Id processId = insertProcess();
        insertConfigData( processId, calculationMethod );
        insertWorkOrders();

        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Repeat_Visit RepeatVisitFlow = new SPM_Repeat_Visit(scheduleData);
        System.assert(RepeatVisitFlow != null );
        Test.startTest();
        
        Database.QueryLocator queryLocator = RepeatVisitFlow.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        RepeatVisitFlow.execute(null, records);
        
        RepeatVisitFlow.finish( null );
        Test.stopTest();
    }
    
    
    static testMethod void testBasicFlowWithoutCompariosnFields(){
        setup();
        Id processId = insertProcess();
        insertConfigData( processId, calculationMethodWithoutComparisonFields );
        insertWorkOrders();

        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Repeat_Visit RepeatVisitFlow = new SPM_Repeat_Visit(scheduleData);
        System.assert(RepeatVisitFlow != null );
        Test.startTest();
       
        Database.QueryLocator queryLocator = RepeatVisitFlow.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        RepeatVisitFlow.execute(null, records);
        
        RepeatVisitFlow.finish( null );
        Test.stopTest();
    }
    
    private static void setup() {
        if(spmRuleRecordType == null){
            spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];    
        }
        
        if(spmDetailsRecordType == null){
            spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];    
        }        
    }
    
    private static void insertWorkOrders() {
        SVMXC__Service_Group__c serviceTeam = new SVMXC__Service_Group__c();
        serviceTeam.Name = 'US Remote Team';        
        insert serviceTeam;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'Brendum';
        technician.SVMXC__Service_Group__c = serviceTeam.Id;
        
        insert technician;
        
        Account acc = new Account();
        acc.Name = 'Cool Cars';        
        insert acc;
        
        SVMXC__Site__c site = new SVMXC__Site__c();
        site.name = 'Roseville';
        insert site;

        SVMXC__Installed_Product__c topLevelInstalledProduct = new SVMXC__Installed_Product__c();
        topLevelInstalledProduct.Name = 'IB-LB_PR0001';        
        insert topLevelInstalledProduct;
        
        SVMXC__Installed_Product__c installedProduct = new SVMXC__Installed_Product__c();
        installedProduct.Name = 'IB-LB_PR0004';
        installedProduct.SVMXC__Top_Level__c = topLevelInstalledProduct.Id;
        insert installedProduct;
        
        SVMXC__Service_Order__c serviceOrder = new SVMXC__Service_Order__c();
        serviceOrder.SVMXC__Group_Member__c  = technician.Id;
        serviceOrder.SVMXC__Closed_On__c = System.today().addDays(1);        
        serviceOrder.SVMXC__Company__c = acc.Id;
        serviceOrder.SVMXC__Site__c = site.Id;
        serviceOrder.SVMXC__Order_Status__c = 'Closed';
        serviceOrder.SVMXC__Component__c = installedProduct.Id;  
        serviceOrder.SVMXC__Top_Level__c = topLevelInstalledProduct.Id;
        insert serviceOrder;


        SVMXC__Service_Order__c secondServiceOrder = new SVMXC__Service_Order__c();
        secondServiceOrder.SVMXC__Group_Member__c = technician.Id;
        secondServiceOrder.SVMXC__Closed_On__c = System.today().addDays(1);        
        secondServiceOrder.SVMXC__Company__c = acc.Id;
        secondServiceOrder.SVMXC__Site__c = site.Id;
        secondServiceOrder.SVMXC__Order_Status__c = 'Closed';
        secondServiceOrder.SVMXC__Component__c = installedProduct.Id;  
        secondServiceOrder.SVMXC__Top_Level__c = topLevelInstalledProduct.Id;
        insert secondServiceOrder;


        SVMXC__Service_Order__c thirdServiceOrder = new SVMXC__Service_Order__c();
        thirdServiceOrder.SVMXC__Group_Member__c = technician.Id;
        thirdServiceOrder.SVMXC__Closed_On__c = System.today().addDays(1);        
        thirdServiceOrder.SVMXC__Company__c = acc.Id;
        thirdServiceOrder.SVMXC__Site__c = site.Id;
        thirdServiceOrder.SVMXC__Order_Status__c = 'Closed';
        thirdServiceOrder.SVMXC__Component__c = installedProduct.Id;    
        thirdServiceOrder.SVMXC__Top_Level__c = topLevelInstalledProduct.Id;
        thirdServiceOrder.SVMXC__Related_Work_Order__c = secondServiceOrder.Id;
        insert thirdServiceOrder;
        
        SVMXC__Service_Order__c fourthServiceOrder = new SVMXC__Service_Order__c();
        fourthServiceOrder.SVMXC__Group_Member__c = technician.Id;
        fourthServiceOrder.SVMXC__Closed_On__c = System.today().addDays(1);        
        fourthServiceOrder.SVMXC__Company__c = acc.Id;
        fourthServiceOrder.SVMXC__Site__c = site.Id;
        fourthServiceOrder.SVMXC__Order_Status__c = 'Closed';
        fourthServiceOrder.SVMXC__Component__c = installedProduct.Id;    
        fourthServiceOrder.SVMXC__Top_Level__c = topLevelInstalledProduct.Id;
        //fourthServiceOrder.createdDate = System.today().addDays(-150);    
        insert fourthServiceOrder;
        Test.setCreatedDate(fourthServiceOrder.Id, System.today().addDays(-150));
        
        
        SVMXC__Service_Order__c fifthServiceOrder = new SVMXC__Service_Order__c();
        fifthServiceOrder.SVMXC__Group_Member__c = technician.Id;
        fifthServiceOrder.SVMXC__Closed_On__c = System.today().addDays(1);        
        fifthServiceOrder.SVMXC__Company__c = acc.Id;
        fifthServiceOrder.SVMXC__Site__c = site.Id;
        fifthServiceOrder.SVMXC__Order_Status__c = 'Closed';
        fifthServiceOrder.SVMXC__Component__c = installedProduct.Id;    
        fifthServiceOrder.SVMXC__Top_Level__c = topLevelInstalledProduct.Id;
        fifthServiceOrder.SVMXC__Related_Work_Order__c = fourthServiceOrder.Id;
        insert fifthServiceOrder;

    }
    
    private static Id insertProcess() {
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.RepeatVisit.name();
        process.SVMXC__Name__c = 'Repeat Visit';
        insert process;
        return process.Id;
    }
    
    private static void insertConfigData(Id processId, String configurationJSON){
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.RecordTypeId = spmDetailsRecordType.Id;
        configData.SVMXC__Dispatch_Process__c = processId;
        configData.SVMXC__Formula__c = configurationJSON;
        configData.SVMXC__Active__c = true;
        insert configData;
        
        //calculationMethod = calculationMethod.replace( 'a10F0000005OCUvIAO', configData.Id );
        //configData.SVMXC__Formula__c = calculationMethod;
        update configData;
    }
    
    private static String calculationMethod = '{"targetObjectName":"SVMXC__SPM_Repeat_Visit__c","targetObjectLabel":"SPM - Repeat Visit","sourceObjectName":"SVMXC__Service_Order__c","sourceObjectLabel":"Work Order","recordId":"a10F0000005OCUvIAO","parameterInfoList":[{"sourceObjectName":null,"sourceObjectField":"Account","sourceFieldName":"SVMXC__Company__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Account","label":"Select the source for the Account field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Location","sourceFieldName":"SVMXC__Site__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Site__c","label":"Select the source for the Location field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"InstallProduct","sourceFieldName":"SVMXC__Component__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Installed_Product__c","label":"Select the source for the Installed Product field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"RepeatVisitQualifier","sourceFieldName":"Location;Account;Installed Product","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select one or more fields to be considered for RepeatVisit","isPicklistValue":false,"isMultiSelect":true,"displayType":"PICKLIST"},{"sourceObjectName":null,"sourceObjectField":"hasPrimaryWorkOrder","sourceFieldName":"Yes","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Reference to Primary Work Order","isPicklistValue":false,"isMultiSelect":false,"displayType":"PICKLIST"},{"sourceObjectName":null,"sourceObjectField":"RepeatVisitWindow","sourceFieldName":"30","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the timeframe for RepeatVisit window","isPicklistValue":false,"isMultiSelect":false,"displayType":"PICKLIST"}],"objectMappingDetailsList":[{"targetObjectName":"SVMXC__SPM_Repeat_Visit__c","sourceObjectName":"SVMXC__Service_Order__c","referenceObjectName":false,"objectMappingList":null,"mapId":"","label":"Select the Object Mapping to be applied for this metrics"}],"name":"CN-0002552896","methodDisplayName":null,"method":"SPMREPEATVISIT: Standard","lastModifiedOn":"2/22/2016 5:31 PM","isActive":true,"expressionDetailsList":[{"sourceObjectName":null,"label":"Select the expression to qualify work orders for this metric","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"EXPR060"},{"sourceObjectName":"SVMXC__Service_Order__c","label":"Criteria for qualifying the Repeat Visit Work Order","expressionType":"WorkOrderCriteria","expressionRuleList":null,"expressionRuleId":"EXPR043"}],"appliesTo":"Configuration to find out the Repeat Visit Metrics"}';  
    private static String calculationMethodWithoutComparisonFields = '{"targetObjectName":"SVMXC__SPM_Repeat_Visit__c","targetObjectLabel":"SPM - Repeat Visit","sourceObjectName":"SVMXC__Service_Order__c","sourceObjectLabel":"Work Order","recordId":"a10F0000005PUyrIAG","parameterInfoList":[{"sourceObjectName":null,"sourceObjectField":"Account","sourceFieldName":"SVMXC__Company__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Account","label":"Select the source for the Account field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Location","sourceFieldName":"SVMXC__Site__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Site__c","label":"Choose the field to source Location from","isPicklistValue":false,"isMultiSelect":false,"isCriteria":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"InstallProduct","sourceFieldName":"SVMXC__Component__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Installed_Product__c","label":"Select the source for the Installed Product field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":false,"displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"ServiceDeliveredOn","sourceFieldName":"SVMXC__Closed_On__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Choose the field to source Service Delivered On from","isPicklistValue":false,"isMultiSelect":false,"isCriteria":false,"displayType":"DATETIME"},{"sourceObjectName":null,"sourceObjectField":"RepeatVisitQualifier","sourceFieldName":"","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select one or more fields to be considered for RepeatVisit","isPicklistValue":false,"isMultiSelect":true,"isCriteria":true,"displayType":"PICKLIST"},{"sourceObjectName":null,"sourceObjectField":"hasPrimaryWorkOrder","sourceFieldName":"Yes","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Reference to Primary Work Order","isPicklistValue":false,"isMultiSelect":false,"isCriteria":true,"displayType":"PICKLIST"},{"sourceObjectName":null,"sourceObjectField":"RepeatVisitWindow","sourceFieldName":"7","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the timeframe for RepeatVisit window","isPicklistValue":false,"isMultiSelect":false,"isCriteria":true,"displayType":"PICKLIST"}],"objectMappingDetailsList":[{"targetObjectName":"SVMXC__SPM_Repeat_Visit__c","sourceObjectName":"SVMXC__Service_Order__c","referenceObjectName":false,"objectMappingList":null,"mapId":"Recall_with_WO_Map","label":"Select the Object Mapping to be applied for this metrics"}],"name":"CN-0002824705","methodDisplayName":null,"method":"SPMREPEATVISIT: Standard","lastModifiedOn":"3/21/2016 11:51 AM","isActive":true,"expressionDetailsList":[{"sourceObjectName":null,"label":"Select the expression to qualify work orders for this metric","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"EXPR060"},{"sourceObjectName":"SVMXC__Service_Order__c","label":"Qualifying criteria for a reacalled work order","expressionType":"WorkOrderCriteria","expressionRuleList":null,"expressionRuleId":"EXPR076"}],"appliesTo":"Configuration to pull the work-orders that were recalled recently."}';


}