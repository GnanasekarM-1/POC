@isTest
Private with sharing class SFM_DeployExpression_UT
 {
    static testMethod void SFM_DeployExpression_UT_Test()
    {
       String RTypeId = '';
       RecordType Rtype;
       
       String RTypeId1 = '';
       RecordType Rtype1;
       
       //------------------ Querying the Record Types for the SVMX Action --------------------------
       Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SVMX Rule' Limit 1];
       RTypeId = Rtype.Id;
        
        Rtype1 = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Expressions' Limit 1];
        RTypeId1 = Rtype1.Id;
        
       SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
       process.SVMXC__Name__c = 'process001';
       process.SVMXC__Rule_Type__c = 'Named Expression';
       process.SVMXC__ProcessID__c = 'process001';
       process.SVMXC__SettingID__c = 'setting001';
       process.RecordTypeId = RTypeId;
       insert process;
       
       System.assertEquals(true, process != null);
       
       List<SVMXC__ServiceMax_Config_Data__c> expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
       SVMXC__ServiceMax_Config_Data__c expDtl = new SVMXC__ServiceMax_Config_Data__c();
       expDtl.RecordTypeId = RTypeId1;
       expDtl.SVMXC__Expression_Type__c = 'EXP_Named';
       expDtl.SVMXC__Expression_Rule__c = process.id;
       expressionDetails.add(expDtl);
       
       System.assertEquals(true, expressionDetails != null);
       
       List<SVMXC.SFM_WrapperDef.SFM_Expression> expressions = new List<SVMXC.SFM_WrapperDef.SFM_Expression>();
       SFM_WrapperDef.SFM_Expression exp1 = new SFM_WrapperDef.SFM_Expression(process,expressionDetails);
       //exp1.namedExpression = process;
       expressions.add(exp1);
       //insert expressions;
       
       System.assertEquals(true, expressions != null);
       
       SFM_WrapperDef.SFM_Request_Expression request = new SFM_WrapperDef.SFM_Request_Expression(expressions);
       
       System.assertEquals(true, request != null);
       
       SFM_DeployExpression deployExp = new SFM_DeployExpression();
       SFM_WrapperDef.SFM_Response response = deployExp.SFM_DeployExpression(request);
    }
    
    static testMethod void SFM_DeployExpression_UT_Test1()
    {
       List<SVMXC.SFM_WrapperDef.SFM_Expression> expressions = new List<SVMXC.SFM_WrapperDef.SFM_Expression>();
       SFM_WrapperDef.SFM_Expression exp1 = new SFM_WrapperDef.SFM_Expression();
       //exp1.namedExpression = process;
       expressions.add(exp1);
       //insert expressions;
       
       System.assertEquals(true, expressions != null);
       
       SFM_WrapperDef.SFM_Request_Expression request = new SFM_WrapperDef.SFM_Request_Expression(expressions);
       
        System.assertEquals(true, request != null);
        
       SFM_DeployExpression deployExp = new SFM_DeployExpression();
       SFM_WrapperDef.SFM_Response response = deployExp.SFM_DeployExpression(request);
    }
   
 }