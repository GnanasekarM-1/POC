@isTest
private class SFM_ValidateExpression_UT
{
   static testMethod void SFM_validateExpression_UT_Test()
        {
        /*------------Data Creation------------*/

        List<RecordType> RtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
        List<RecordType> ConfigDataRtype = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Expressions' ];
         
        //------ Creating an Account------
        Account ac=new Account();
        ac.Name = 'Test Account';
        insert ac;
        system.assertEquals('Test Account', ac.Name);

        SVMXC__Service_Order__c WorkOrderData = new SVMXC__Service_Order__c();
        WorkOrderData.SVMXC__Priority__c='High';
        WorkOrderData.SVMXC__Company__c=ac.id;
        WorkOrderData.SVMXC__Order_Type__c='Open';
        WorkOrderData.SVMXC__Scheduled_Date__c =  date.newinstance(2010,12,17);
        WorkOrderData.SVMXC__Group_Email__c= 'abc@xyz.com';
        WorkOrderData.SVMXC__PM_Tasks_Created__c=TRUE;
        WorkOrderData.SVMXC__Actual_Initial_Response__c=datetime.newInstance(2008, 12, 1, 12, 30, 2);
        insert WorkOrderData;
        system.assertEquals('Open', WorkOrderData.SVMXC__Order_Type__c);

        //------Creating Process Data------
        SVMXC__ServiceMax_Processes__c procssObj = new SVMXC__ServiceMax_Processes__c();
        procssObj.SVMXC__ProcessID__c='PROCESS11';
        procssObj.SVMXC__SettingId__c = 'PROCESS11';
        procssObj.SVMXC__MapID__c='PROCESS11';
        procssObj.SVMXC__Name__c = 'PROCESS22';
        procssObj.RecordTypeId=RtypeLst[0].Id;
        procssObj.SVMXC__Source_Object_Name__c='SVMXC__Service_Order__c';
        procssObj.SVMXC__Advance_Expression__c = '';
        insert procssObj; 
        system.assertEquals('PROCESS22', procssObj.SVMXC__Name__c);

        //------Creating Config Data------
        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
        configData1.RecordTypeId = ConfigDataRtype[0].Id;
        configData1.SVMXC__Operator__c ='eq';
        configData1.SVMXC__Operand__c = 'Open';
        configData1.SVMXC__Field_Name__c = '.SVMXC__Order_Type__c';
        insert configData1;
        system.assertEquals('Open', configData1.SVMXC__Operand__c);

        SVMXC__ServiceMax_Config_Data__c configData2 = new SVMXC__ServiceMax_Config_Data__c();
        configData2.RecordTypeId = ConfigDataRtype[0].Id;
        configData2.SVMXC__Operator__c ='ne';
        configData2.SVMXC__Operand__c = 'High';
        configData2.SVMXC__Field_Name__c = 'SVMXC__Priority__c';
        insert configData2;
        system.assertEquals('SVMXC__Priority__c', configData2.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData3 = new SVMXC__ServiceMax_Config_Data__c();
        configData3.RecordTypeId = ConfigDataRtype[0].Id;
        configData3.SVMXC__Operator__c ='eq';  
        configData3.SVMXC__Operand__c = '10/12/2010';
        configData3.SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c';
        insert configData3;
        system.assertEquals('SVMXC__Scheduled_Date__c', configData3.SVMXC__Field_Name__c);

        //start test to check different operator

        SVMXC__ServiceMax_Config_Data__c configData31 = new SVMXC__ServiceMax_Config_Data__c();
        configData31.RecordTypeId = ConfigDataRtype[0].Id;
        configData31.SVMXC__Operator__c ='ne';  
        configData31.SVMXC__Operand__c = '10/12/2010';
        configData31.SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c';
        insert configData31;
        system.assertEquals('SVMXC__Scheduled_Date__c', configData31.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData32 = new SVMXC__ServiceMax_Config_Data__c();
        configData32.RecordTypeId = ConfigDataRtype[0].Id;
        configData32.SVMXC__Operator__c ='gt';  
        configData32.SVMXC__Operand__c = '10/12/2010';
        configData32.SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c';
        insert configData32;
        system.assertEquals('SVMXC__Scheduled_Date__c', configData32.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData33 = new SVMXC__ServiceMax_Config_Data__c();
        configData33.RecordTypeId = ConfigDataRtype[0].Id;
        configData33.SVMXC__Operator__c ='lt';  
        configData33.SVMXC__Operand__c = '10/12/2010';
        configData33.SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c';
        insert configData33;
        system.assertEquals('SVMXC__Scheduled_Date__c', configData33.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData34 = new SVMXC__ServiceMax_Config_Data__c();
        configData34.RecordTypeId = ConfigDataRtype[0].Id;
        configData34.SVMXC__Operator__c ='ge'; 
        configData34.SVMXC__Operand__c = '10/12/2010';
        configData34.SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c';
        insert configData34;
        system.assertEquals('SVMXC__Scheduled_Date__c', configData34.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData35 = new SVMXC__ServiceMax_Config_Data__c();
        configData35.RecordTypeId = ConfigDataRtype[0].Id;
        configData35.SVMXC__Operator__c ='le';  
        configData35.SVMXC__Operand__c = '10/12/2010';
        configData35.SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c';
        insert configData35;
        system.assertEquals('SVMXC__Scheduled_Date__c', configData35.SVMXC__Field_Name__c);
        //close test

        SVMXC__ServiceMax_Config_Data__c configData4 = new SVMXC__ServiceMax_Config_Data__c();
        configData4.RecordTypeId = ConfigDataRtype[0].Id;
        configData4.SVMXC__Operator__c ='contains';
        configData4.SVMXC__Operand__c = 'a@b.com';
        configData4.SVMXC__Field_Name__c = 'SVMXC__Group_Email__c';
        insert configData4;
        system.assertEquals('SVMXC__Group_Email__c', configData4.SVMXC__Field_Name__c);

        //start test to check different operator 
        SVMXC__ServiceMax_Config_Data__c configData41 = new SVMXC__ServiceMax_Config_Data__c();
        configData41.RecordTypeId = ConfigDataRtype[0].Id;
        configData41.SVMXC__Operator__c ='notcontain';
        configData41.SVMXC__Operand__c = 'a@b.com';
        configData41.SVMXC__Field_Name__c = 'SVMXC__Group_Email__c';
        insert configData41;
        system.assertEquals('SVMXC__Group_Email__c', configData41.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData42 = new SVMXC__ServiceMax_Config_Data__c();
        configData42.RecordTypeId = ConfigDataRtype[0].Id;
        configData42.SVMXC__Operator__c ='starts';
        configData42.SVMXC__Operand__c = 'a@b.com';
        configData42.SVMXC__Field_Name__c = 'SVMXC__Group_Email__c';
        insert configData42;
        system.assertEquals('SVMXC__Group_Email__c', configData42.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData43 = new SVMXC__ServiceMax_Config_Data__c();
        configData43.RecordTypeId = ConfigDataRtype[0].Id;
        configData43.SVMXC__Operator__c ='in';
        configData43.SVMXC__Operand__c = 'a@b.com';
        configData43.SVMXC__Field_Name__c = 'SVMXC__Group_Email__c';
        insert configData43;
        system.assertEquals('SVMXC__Group_Email__c', configData43.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData44 = new SVMXC__ServiceMax_Config_Data__c();
        configData44.RecordTypeId = ConfigDataRtype[0].Id;
        configData44.SVMXC__Operator__c ='notin';
        configData44.SVMXC__Operand__c = 'a@b.com';
        configData44.SVMXC__Field_Name__c = 'SVMXC__Group_Email__c';
        insert configData44;
        system.assertEquals('SVMXC__Group_Email__c', configData44.SVMXC__Field_Name__c);
        //end test

        SVMXC__ServiceMax_Config_Data__c configData5 = new SVMXC__ServiceMax_Config_Data__c();
        configData5.RecordTypeId = ConfigDataRtype[0].Id;
        configData5.SVMXC__Operator__c ='eq';
        configData5.SVMXC__Operand__c = 'TURE';
        configData5.SVMXC__Field_Name__c = 'SVMXC__PM_Tasks_Created__c';
        insert configData5;
        system.assertEquals('SVMXC__PM_Tasks_Created__c', configData5.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData6 = new SVMXC__ServiceMax_Config_Data__c();
        configData6.RecordTypeId = ConfigDataRtype[0].Id;
        configData6.SVMXC__Operator__c ='eq';
        configData6.SVMXC__Operand__c = 'abcdpqrs';
        configData6.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        insert configData6;
        system.assertEquals('SVMXC__Company__c', configData6.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData7 = new SVMXC__ServiceMax_Config_Data__c();
        configData7.RecordTypeId = ConfigDataRtype[0].Id;
        configData7.SVMXC__Operator__c ='eq';
        configData7.SVMXC__Operand__c = '2008/12/1';
        configData7.SVMXC__Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        insert configData7;
        system.assertEquals('SVMXC__Actual_Initial_Response__c', configData7.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData8 = new SVMXC__ServiceMax_Config_Data__c();
        configData8.RecordTypeId = ConfigDataRtype[0].Id;
        configData8.SVMXC__Operator__c ='eq';
        configData8.SVMXC__Operand__c = '2008/12/1';
        configData8.SVMXC__Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        insert configData8;
        system.assertEquals('SVMXC__Actual_Initial_Response__c', configData8.SVMXC__Field_Name__c);

        SVMXC__ServiceMax_Config_Data__c configData9 = new SVMXC__ServiceMax_Config_Data__c();
        configData9.RecordTypeId = ConfigDataRtype[0].Id;
        configData9.SVMXC__Operator__c ='ne';
        configData9.SVMXC__Operand__c = '2008/12/1';
        configData9.SVMXC__Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        insert configData9;
        system.assertEquals('SVMXC__Actual_Initial_Response__c', configData9.SVMXC__Field_Name__c);
        
        SVMXC__ServiceMax_Config_Data__c configData91 = new SVMXC__ServiceMax_Config_Data__c();
        configData91.RecordTypeId = ConfigDataRtype[0].Id;
        configData91.SVMXC__Operator__c ='le';
        configData91.SVMXC__Operand__c = '2008/12/1';
        configData91.SVMXC__Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        insert configData91;
        system.assertEquals('SVMXC__Actual_Initial_Response__c', configData91.SVMXC__Field_Name__c);
        
        SVMXC__ServiceMax_Config_Data__c configData92 = new SVMXC__ServiceMax_Config_Data__c();
        configData92.RecordTypeId = ConfigDataRtype[0].Id;
        configData92.SVMXC__Operator__c ='ge';
        configData92.SVMXC__Operand__c = '2008/12/1';
        configData92.SVMXC__Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        insert configData92;
        system.assertEquals('SVMXC__Actual_Initial_Response__c', configData92.SVMXC__Field_Name__c);
        
        SVMXC__ServiceMax_Config_Data__c configData93 = new SVMXC__ServiceMax_Config_Data__c();
        configData93.RecordTypeId = ConfigDataRtype[0].Id;
        configData93.SVMXC__Operator__c ='lt';
        configData93.SVMXC__Operand__c = '2008/12/1';
        configData93.SVMXC__Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        insert configData93;
        system.assertEquals('SVMXC__Actual_Initial_Response__c', configData93.SVMXC__Field_Name__c);
        
        SVMXC__ServiceMax_Config_Data__c configData94 = new SVMXC__ServiceMax_Config_Data__c();
        configData94.RecordTypeId = ConfigDataRtype[0].Id;
        configData94.SVMXC__Operator__c ='gt';
        configData94.SVMXC__Operand__c = '2008/12/1';
        configData94.SVMXC__Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        insert configData94;
        system.assertEquals('SVMXC__Actual_Initial_Response__c', configData94.SVMXC__Field_Name__c);

        //------Creating Config Data List ------         
        List<SVMXC__ServiceMax_Config_Data__c> configDataLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        configDataLst.add(configData1);
        configDataLst.add(configData2);
        configDataLst.add(configData3);
        //start test to check different operator
        configDataLst.add(configData31);
        configDataLst.add(configData32);
        configDataLst.add(configData33);
        configDataLst.add(configData34);
        configDataLst.add(configData35);
        //end test
        configDataLst.add(configData4);
        //start test to check different operator
        configDataLst.add(configData41);
        configDataLst.add(configData42);
        configDataLst.add(configData43);
        configDataLst.add(configData44);
        //end test
        configDataLst.add(configData5);
        configDataLst.add(configData6);
        configDataLst.add(configData7);

        List<SVMXC__ServiceMax_Config_Data__c> configDataLst1 = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> configDataLst2 = new List<SVMXC__ServiceMax_Config_Data__c>();
        configDataLst1.add(configData8);
        configDataLst2.add(configData9);
        configDataLst2.add(configData91);
        configDataLst2.add(configData92);
        configDataLst2.add(configData93);
        configDataLst2.add(configData94);

        //------Creating Expression Object using Process Object and Config Data List ------
        SFM_WrapperDef.SFM_Expression expressionsObj = new SFM_WrapperDef.SFM_Expression(procssObj,configDataLst);
        SFM_WrapperDef.SFM_Expression expressionsObj1 = new SFM_WrapperDef.SFM_Expression(procssObj,configDataLst1);
        SFM_WrapperDef.SFM_Expression expressionsObj2 = new SFM_WrapperDef.SFM_Expression(procssObj,configDataLst2);

        //------Creating Expression List ------
        List<SFM_WrapperDef.SFM_Expression> expressionsList = new List<SFM_WrapperDef.SFM_Expression>();
        expressionsList.add(expressionsObj);
        SFM_WrapperDef.SFM_Request_Expression ExpReq = new SFM_WrapperDef.SFM_Request_Expression(expressionsList);
        List<SFM_WrapperDef.SFM_Expression> expressionsList1 = new List<SFM_WrapperDef.SFM_Expression>();
        List<SFM_WrapperDef.SFM_Expression> expressionsList2 = new List<SFM_WrapperDef.SFM_Expression>();
        expressionsList1.add(expressionsObj1);
        expressionsList2.add(expressionsObj2);
        SFM_WrapperDef.SFM_Request_Expression ExpReq1 = new SFM_WrapperDef.SFM_Request_Expression(expressionsList1);
        SFM_WrapperDef.SFM_Request_Expression ExpReq2 = new SFM_WrapperDef.SFM_Request_Expression(expressionsList2);

        /*------------Instance Of Class---------*/ 
        SFM_validateExpression validateExpressionObj = new SFM_validateExpression();

        /*------------Method Calling------------*/ 
        validateExpressionObj.SFM_validateExpression(ExpReq);
        validateExpressionObj.SFM_validateExpression(ExpReq1);
        validateExpressionObj.SFM_validateExpression(ExpReq2);
        validateExpressionObj.getInputDateFormat(2017,01,02);
        validateExpressionObj.getInputDateFormat();
        
        SVMXC__ServiceMax_Config_Data__c configData1a = new SVMXC__ServiceMax_Config_Data__c();
        configData1a.RecordTypeId = ConfigDataRtype[0].Id;
        configData1a.SVMXC__Operator__c ='eq';
        configData1a.SVMXC__Operand__c = 'abcdpqrs';
        configData1a.SVMXC__Field_Name__c = 'svmxC__site__c';
        insert configData1a;
        
        validateExpressionObj.buildWhereClause(true,configData6);
        validateExpressionObj.buildWhereClause(true,configData1a);
        
   }
}