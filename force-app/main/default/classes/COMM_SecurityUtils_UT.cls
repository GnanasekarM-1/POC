@isTest
public class COMM_SecurityUtils_UT {
    
    static testMethod void testIsDeletableObject() {
        
        Test.startTest();
        
        String objectAPIName = 'SVMXC__Servicemax_Processes__c';
        Boolean returnValue = COMM_SecurityUtils.getInstance().isDeletableObject( objectAPIName );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testIsDeletableObject_Check_Disabled() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = false;
        Boolean returnValue = COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Servicemax_Processes__c' );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }

    static testMethod void testVerifyFieldAccess_List_SObject_Updateable_ignore_Field() {
        
        Test.startTest();
        
        SVMXC__Servicemax_Processes__c servicemaxProcesses = new SVMXC__Servicemax_Processes__c();
        servicemaxProcesses.SVMXC__Name__c = 'Process Name';
        servicemaxProcesses.SVMXC__ProcessID__c = 'Process ID';
        
        List<SVMXC__Servicemax_Processes__c> servicemaxProcessesList = new List<SVMXC__Servicemax_Processes__c> {
            servicemaxProcesses
        };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( servicemaxProcessesList, COMM_SecurityUtils.Access.Updateable, true );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_List_SObject_Accessible() {
        
        Test.startTest();
        
        SVMXC__Servicemax_Processes__c servicemaxProcesses = new SVMXC__Servicemax_Processes__c();
        servicemaxProcesses.SVMXC__Name__c = 'Process Name';
        servicemaxProcesses.SVMXC__ProcessID__c = 'Process ID';
        
        List<SVMXC__Servicemax_Processes__c> servicemaxProcessesList = new List<SVMXC__Servicemax_Processes__c> {
            servicemaxProcesses
        };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( servicemaxProcessesList, COMM_SecurityUtils.Access.Accessible );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
        
    static testMethod void testVerifyFieldAccess_SObject_Accessible() {
        
        Test.startTest();
        
        SVMXC__Servicemax_Processes__c servicemaxProcesses = new SVMXC__Servicemax_Processes__c();
        servicemaxProcesses.SVMXC__Name__c = 'Process Name';
        servicemaxProcesses.SVMXC__ProcessID__c = 'Process ID';
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( servicemaxProcesses, COMM_SecurityUtils.Access.Accessible );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObject_Createable() {
        
        Test.startTest();
        
        SVMXC__Servicemax_Processes__c servicemaxProcesses = new SVMXC__Servicemax_Processes__c();
        servicemaxProcesses.SVMXC__Name__c = 'Process Name';
        servicemaxProcesses.SVMXC__ProcessID__c = 'Process ID';
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( servicemaxProcesses, COMM_SecurityUtils.Access.Createable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObject_Updateable() {
        
        Test.startTest();
        
        SVMXC__Servicemax_Processes__c servicemaxProcesses = new SVMXC__Servicemax_Processes__c();
        servicemaxProcesses.SVMXC__Name__c = 'Process Name';
        servicemaxProcesses.SVMXC__ProcessID__c = 'Process ID';
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( servicemaxProcesses, COMM_SecurityUtils.Access.Updateable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObject_Upsertable() {
        
        Test.startTest();
        
        SVMXC__Servicemax_Processes__c servicemaxProcesses = new SVMXC__Servicemax_Processes__c();
        servicemaxProcesses.SVMXC__Name__c = 'Process Name';
        servicemaxProcesses.SVMXC__ProcessID__c = 'Process ID';
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( servicemaxProcesses, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObject_Check_Disabled() {
        
        Test.startTest();
        
        SVMXC__Servicemax_Processes__c servicemaxProcesses = new SVMXC__Servicemax_Processes__c();
        servicemaxProcesses.SVMXC__Name__c = 'Process Name';
        servicemaxProcesses.SVMXC__ProcessID__c = 'Process ID';
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = false;
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( servicemaxProcesses, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_List_Of_Fields_Accessible() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Service_Order__c';
        List<String> fieldList = new List<String> { 'SVMXC__Company__r.SVMXC__Preferred_Technician__c' };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, fieldList, COMM_SecurityUtils.Access.Accessible );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_List_Of_Fields_Createable() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        List<String> fieldList = new List<String> { 'SVMXC__Name__c', 'SVMXC__ProcessID__c' };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, fieldList, COMM_SecurityUtils.Access.Createable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_List_Of_Fields_Updateable() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        List<String> fieldList = new List<String> { 'SVMXC__Name__c', 'SVMXC__ProcessID__c' };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, fieldList, COMM_SecurityUtils.Access.Updateable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_List_Of_Fields_Upsertable() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        List<String> fieldList = new List<String> { 'SVMXC__Name__c', 'SVMXC__ProcessID__c' };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, fieldList, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    } 
    
    static testMethod void testVerifyFieldAccess_List_Of_Fields_Check_Disabled() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        List<String> fieldList = new List<String> { 'SVMXC__Name__c', 'SVMXC__ProcessID__c' };
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = false;
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, fieldList, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    } 
    
    static testMethod void testVerifyFieldAccess_Field_Check_Disabled() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = false;
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, 'SVMXC__Name__c', COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    } 
    
    static testMethod void testVerifyFieldAccess_SObjectField_Accessible() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Name__c'), COMM_SecurityUtils.Access.Accessible );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObjectField_Createable() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Name__c'), COMM_SecurityUtils.Access.Createable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObjectField_Updateable() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Name__c'), COMM_SecurityUtils.Access.Updateable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObjectField_Upsertable() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Name__c'), COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObjectField_Check_Disabled() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = false;
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Name__c'), COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_DescribeFieldResult_Accessible() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Name__c').getDescribe(), COMM_SecurityUtils.Access.Accessible );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_DescribeFieldResult_Accessible_AutoNumber() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('Name').getDescribe(), COMM_SecurityUtils.Access.Accessible );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_DescribeFieldResult_Createable() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Name__c').getDescribe(), COMM_SecurityUtils.Access.Createable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_DescribeFieldResult_Updateable() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Name__c').getDescribe(), COMM_SecurityUtils.Access.Updateable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_DescribeFieldResult_Updateable_Reference() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Business_Hours__c').getDescribe(), COMM_SecurityUtils.Access.Updateable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_DescribeFieldResult_Upsertable() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Name__c').getDescribe(), COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_DescribeFieldResult_Check_Disabled() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = false;
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Name__c').getDescribe(), COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_DescribeFieldResult_ReadOnly() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('LastModifiedDate').getDescribe(), COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(!returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_DescribeFieldResult_Invalid_DescribeFieldResult() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( (Schema.DescribeFieldResult) null, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(!returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_DescribeFieldResult_AccessType() {
        
        Test.startTest();
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('LastModifiedDate').getDescribe(), null );
        
        System.assert(!returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObjectField_Invalid_SObjectField() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( (Schema.SObjectField) null, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(!returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObjectField_Invalid_AccessType() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('SVMXC__Name__c'), null );
        
        System.assert(!returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObjectField_ReadOnly() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        String objectName = 'SVMXC__Servicemax_Processes__c';
        Map<String, Schema.SObjectField> sobjectFieldMap = COMM_SecurityUtils.getInstance().getSObjectFieldMap( objectName );
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectFieldMap.get('LastModifiedDate'), COMM_SecurityUtils.Access.Upsertable );
        
        System.assert(!returnValue);
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_List_Of_Fields_ReadOnlyField() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().systemFieldsSet.clear();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        String objectName = 'SVMXC__Servicemax_Processes__c';
        List<String> fieldList = new List<String> { 'SVMXC__Name__c', 'SVMXC__ProcessID__c', 'LastModifiedDate' };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, fieldList, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert( !returnValue );
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_List_Of_Reference_Fields_ReadOnlyField() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().systemFieldsSet.clear();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        String objectName = 'SVMXC__Servicemax_Processes__c';
        List<String> fieldList = new List<String> { 'SVMXC__Default_Location__r.LastModifiedDate' };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, fieldList, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert( !returnValue );
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_List_Of_Fields_SystemField() {
        
        Test.startTest();
        
        String objectName = 'SVMXC__Servicemax_Processes__c';
        List<String> fieldList = new List<String> { 'SVMXC__Name__c', 'SVMXC__ProcessID__c', 'LastModifiedDate' };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, fieldList, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert( returnValue );
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_List_Of_Fields_Invalid_ObjectName() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        List<String> fieldList = new List<String> { 'SVMXC__Name__c', 'SVMXC__ProcessID__c', 'LastModifiedDate' };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( null, fieldList, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert( !returnValue );
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_List_Of_Fields_Invalid_Field_Name() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        String objectName = 'SVMXC__Servicemax_Processes__c';
        List<String> fieldList = new List<String> { 'SVMXC__Name__c', 'SVMXC__ProcessID__c', 'InvalidField' };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, fieldList, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert( !returnValue );
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_List_Of_Fields_Invalid_AccessType() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        String objectName = 'SVMXC__Servicemax_Processes__c';
        List<String> fieldList = new List<String> { 'SVMXC__Name__c', 'SVMXC__ProcessID__c' };
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, fieldList, null );
        
        System.assert( !returnValue );
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObject_Invalid_SObject() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( (SObject) null, COMM_SecurityUtils.Access.Accessible );
        
        System.assert( !returnValue );
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObject_Invalid_AccessType() {
        
        Test.startTest();
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = true;
        SVMXC__Servicemax_Processes__c servicemaxProcesses = new SVMXC__Servicemax_Processes__c();
        servicemaxProcesses.SVMXC__Name__c = 'Process Name';
        servicemaxProcesses.SVMXC__ProcessID__c = 'Process ID';
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( servicemaxProcesses, null );
        
        System.assert( !returnValue );
        
        Test.stopTest();
    }
    
    static testMethod void testVerifyFieldAccess_SObject_Queried_Record() {
        
        Test.startTest();
        
        String accountName = 'Account Name';
        
        Account accountRecord = new Account();
        accountRecord.Name = accountName;
        
        insert accountRecord;
        
        SObject accountSObject = [SELECT Id, Name FROM Account WHERE Name = :accountName ];
        
        Boolean returnValue = COMM_SecurityUtils.getInstance().verifyFieldAccess( accountSObject, COMM_SecurityUtils.Access.Upsertable );
        
        System.assert( returnValue );
        
        Test.stopTest();
    }
    static testMethod void testisCreateableandAccessbleObject() {
        
        Test.startTest();
        
        String objectAPIName = 'SVMXC__Servicemax_Processes__c';
        Boolean returnValue = COMM_SecurityUtils.getInstance().isCreateable( objectAPIName );
        
        System.assert(returnValue);
        
        Boolean retVal = COMM_SecurityUtils.getInstance().isAccessible( objectAPIName );
        
        Test.stopTest();
    }  
}