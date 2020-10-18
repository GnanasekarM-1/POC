@isTest(SeeAllData=true)
Private class COMM_Utils_UT {
   
    static testMethod void COMM_Utils_UT_Test() 
    {
      try 
      {
                //Test for getting Default Picklist Value  
        List<String> lstStr = new List<String>();
        lstStr.add('SVMXC__Status__c');
        Schema.DescribeSObjectResult dsoResult = Account.sObjectType.getDescribe();
        Map<String, SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
        
                    // Get tags for CONF data validation submodule
        // SVMXC.COMM_Utils_ManageTags commUtilTags = new SVMXC.COMM_Utils_s();
        Map<String, String> svmxTagList;
        
                    // Build a valid installation key
        //Date FutExpDate = Date.Today() +25;//Changed due to UT failure, 06/01/2011 -HH
        Date myDate = date.newinstance(1960, 2, 17);
        Date FutExpDate =  myDate.addDays(2);
        String canonical = userInfo.getOrganizationId() + '~' + String.valueOf(FutExpDate);                        
        String ValidInstKey =  EncodingUtil.base64Encode(Blob.valueOf(canonical));
        
                    // Build an expired installation key
        //Date PastExpDate = Date.Today() - 50;//Changed due to UT failure, 06/01/2011 -HH
        Date PastExpDate = mydate.addDays(- 2);
        canonical = userInfo.getOrganizationId() + '~' + String.valueOf(PastExpDate);                        
        String ExpInstKey =  EncodingUtil.base64Encode(Blob.valueOf(canonical));

                    // Build an invalid installation key
        canonical = 'SOMEJUNKORGID' + '~' + String.valueOf(FutExpDate);                        
        String BadInstKey =  EncodingUtil.base64Encode(Blob.valueOf(canonical));

                    // Build an null installation key
        canonical = '' + '~' + String.valueOf(FutExpDate);                        
        String nullInstKey =  EncodingUtil.base64Encode(Blob.valueOf(canonical));

                    // Build an null Key date
        canonical = userInfo.getOrganizationId() + '~' + '';                        
        String nullKeyDt =  EncodingUtil.base64Encode(Blob.valueOf(canonical));
        
        //hh 2008/feb/04
        SVMXC.COMM_Utils svmxComm = new SVMXC.COMM_Utils(); //class instance
        
        SVMXC__ServiceMax_Processes__c obj = new SVMXC__ServiceMax_Processes__c();
        svmxComm.SVMX_IsValidInstallationKey(ValidInstKey, obj);       
        svmxComm.SVMX_IsValidInstallationKey(ExpInstKey, obj);
        svmxComm.SVMX_IsValidInstallationKey(BadInstKey, obj);
        svmxComm.SVMX_IsValidInstallationKey(nullInstKey, obj);
        svmxComm.SVMX_IsValidInstallationKey(nullKeyDt, obj);

        svmxComm.SVMX_getDefaultPicklistValue('Product2','Family');
                //Calling Methods in COMM_Utils class with False
        List<String> fieldList2 = svmxComm.SVMX_getFieldList(fieldMap,false);      
        String fieldNames2 = svmxComm.SVMX_getFieldNamesFromList(fieldList2);
                //Calling Methods in COMM_Utils class
        List<String> fieldList = svmxComm.SVMX_getFieldList(fieldMap,true);      
        String fieldNames = svmxComm.SVMX_getFieldNamesFromList(fieldList);
        svmxComm.SVMX_getDefaultPicklistValue('SVMXC__Installed_Product__c',lstStr);
        String defval = svmxComm.SVMX_getDefaultPicklistValue('Accounts','Rating');
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c oConf1 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c oConf2 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c oConf3 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c oConf4 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c oConf5 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c oConf6 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c oConf7 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c oConf8 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c oConf9 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c oConf10 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c oConf11 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Processes__c CounterRuleList = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c> confList= new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' ];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
               oConf1.RecordTypeId = rt.ID;
               oConf2.RecordTypeId = rt.ID;
               oConf3.RecordTypeId = rt.ID;
               oConf4.RecordTypeId = rt.ID;
               oConf5.RecordTypeId = rt.ID;
               oConf6.RecordTypeId = rt.ID;
               oConf7.RecordTypeId = rt.ID;
               oConf8.RecordTypeId = rt.ID;
               oConf9.RecordTypeId = rt.ID;
               oConf10.RecordTypeId = rt.ID;
               oConf11.RecordTypeId = rt.ID;
            } 
            
            if(rt.Name == 'SVMX Rule' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               CounterRuleList.RecordTypeId = rt.ID;
            }
            
        }
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='Name';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='Product1';
        oConf.SVMXC__Operator__c='eq';
        oConf.SVMXC__Sequence__c=1;
        insert oconf;

        oConf1.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf1.SVMXC__Field_Name__c='Name';
        oConf1.SVMXC__Display_Type__c = 'STRING';
        oConf1.SVMXC__Operand__c='Product2';
        oConf1.SVMXC__Operator__c='NE';
        oConf1.SVMXC__Sequence__c=1;
        insert oconf1;

        oConf2.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf2.SVMXC__Field_Name__c='Name';
        oConf2.SVMXC__Display_Type__c = 'STRING';
        oConf2.SVMXC__Operand__c='Prod';
        oConf2.SVMXC__Operator__c='starts';
        oConf2.SVMXC__Sequence__c=2;
        insert oconf2;

        oConf3.SVMXC__Expression_Type__c = 'DISP_Process_Entry11';
        oConf3.SVMXC__Field_Name__c='Name';
        oConf3.SVMXC__Display_Type__c = 'STRING';
        oConf3.SVMXC__Operand__c='product1';
        oConf3.SVMXC__Operator__c='contains';
        oConf3.SVMXC__Sequence__c=1;
        insert oconf3;

        oConf4.SVMXC__Expression_Type__c = 'DISP_Process_Entry1';
        oConf4.SVMXC__Field_Name__c='IsActive';
        oConf4.SVMXC__Display_Type__c = 'Boolean';
        oConf4.SVMXC__Operand__c='true';
        oConf4.SVMXC__Operator__c='eq';
        oConf4.SVMXC__Sequence__c=4;
        insert oconf4;

        oConf5.SVMXC__Expression_Type__c = 'DISP_Process_Entry1';
        oConf5.SVMXC__Field_Name__c='IsActive';
        oConf5.SVMXC__Display_Type__c = 'Boolean';
        oConf5.SVMXC__Operand__c='false';
        oConf5.SVMXC__Operator__c='ne';
        oConf5.SVMXC__Sequence__c=5;
        insert oconf5;

        oConf6.SVMXC__Expression_Type__c = 'DISP_Process_Entry1';
        oConf6.SVMXC__Field_Name__c='CreatedDate';
        oConf6.SVMXC__Display_Type__c = 'DATETIME';
        oConf6.SVMXC__Operand__c=String.valueof(system.now());
        oConf6.SVMXC__Operator__c='eq';
        oConf6.SVMXC__Sequence__c=6;
        insert oconf6;

        oConf7.SVMXC__Expression_Type__c = 'DISP_Process_Entry1';
        oConf7.SVMXC__Field_Name__c='CreatedDate';
        oConf7.SVMXC__Display_Type__c = 'DATETIME';
        oConf7.SVMXC__Operand__c=String.valueof(system.now()-10);
        oConf7.SVMXC__Operator__c='ne';
        oConf7.SVMXC__Sequence__c=7;
        insert oconf7;

        oConf11.SVMXC__Expression_Type__c = 'DISP_Process_Entry1';
        oConf11.SVMXC__Field_Name__c='CreatedDate';
        oConf11.SVMXC__Display_Type__c = 'DATETIME';
        oConf11.SVMXC__Operand__c=String.valueof(system.now()+2);
        oConf11.SVMXC__Operator__c='gt';
        oConf11.SVMXC__Sequence__c=8;
        insert oconf11;

        oConf8.SVMXC__Expression_Type__c = 'DISP_Process_Entry1';
        oConf8.SVMXC__Field_Name__c='CreatedDate';
        oConf8.SVMXC__Display_Type__c = 'DATETIME';
        oConf8.SVMXC__Operand__c=String.valueof(system.now());
        oConf8.SVMXC__Operator__c='ge';
        oConf8.SVMXC__Sequence__c=9;
        insert oconf8;

        oConf9.SVMXC__Expression_Type__c = 'DISP_Process_Entry1';
        oConf9.SVMXC__Field_Name__c='CreatedDate';
        oConf9.SVMXC__Display_Type__c = 'DATETIME';
        oConf9.SVMXC__Operand__c=String.valueof(system.now()-2);
        oConf9.SVMXC__Operator__c='lt';
        oConf9.SVMXC__Sequence__c=10;
        insert oconf9;

        oConf10.SVMXC__Expression_Type__c = 'DISP_Process_Entry1';
        oConf10.SVMXC__Field_Name__c='CreatedDate';
        oConf10.SVMXC__Display_Type__c = 'DATETIME';
        oConf10.SVMXC__Operand__c=String.valueof(system.now());
        oConf10.SVMXC__Operator__c='le';
        oConf10.SVMXC__Sequence__c=11;
        insert oconf10;

        Product2 prod = new Product2(Name = 'Product1',SVMXC__Inherit_Parent_Warranty__c=true,SVMXC__Product_Line__c='accessory,desktop',SVMXC__Tracking__c='Serialized,Lot/Batch Tracked',SVMXC__Unit_Of_Measure__c='Each,Gallon',IsActive=true);
        insert prod;

        Map<String,String> typemap = new Map<String,String>();
        typemap.put('Name','TEXTAREA');

        Map<String, Schema.SObjectField> IBfieldMap = Schema.SObjectType.Product2.fields.getMap();
            for(Schema.SObjectField lON : IBfieldMap.values()){
                Schema.DescribeFieldResult D = lON.getDescribe();
                TypeMap.put(D.getName(),D.getType().name());                

            }
        CounterRuleList.SVMXC__Advance_Expression__c=null;
        CounterRuleList.SVMXC__Description__c='Description';
        CounterRuleList.SVMXC__Name__c='Rule1';
        CounterRuleList.SVMXC__Select__c =true;
        CounterRuleList.SVMXC__Rule_Type__c='Counters';
        insert CounterRuleList;

        list<SVMXC__ServiceMax_Config_Data__c> TConfgLst = new list<SVMXC__ServiceMax_Config_Data__c>();
        Map<String,list<SVMXC__ServiceMax_Config_Data__c>> ExpressionMap = new Map<String,list<SVMXC__ServiceMax_Config_Data__c>>();
        list<SVMXC__ServiceMax_Config_Data__c> TempConfigList = new list<SVMXC__ServiceMax_Config_Data__c>();
        TempConfigList.add(oconf);
        TempConfigList.add(oconf1);
        TempConfigList.add(oconf2);
        TempConfigList.add(oconf3);
        TempConfigList.add(oconf4);
        TempConfigList.add(oconf5);
        TempConfigList.add(oconf6);
        TempConfigList.add(oconf7);
        TempConfigList.add(oconf8);
        TempConfigList.add(oconf9);
        TempConfigList.add(oconf10);
        TempConfigList.add(oconf11);
        
        ExpressionMap.put(CounterRuleList.Id,TempConfigList);
        TConfgLst = ExpressionMap.get(CounterRuleList.Id);
        system.assertNotEquals(TConfgLst,null);
        svmxComm.SVMX_ExpressionParsing(Prod,TypeMap,TConfgLst, null);
        svmxComm.SVMX_ExpressionParsing(Prod,TypeMap,TConfgLst, ' 1 AND 2 OR 3 AND 4 ');
        svmxComm.SVMX_ExpressionParsing(Prod,TypeMap,TConfgLst, ' 1 OR 0 ');
        svmxComm.SVMX_ExpressionParsing(Prod,TypeMap,TConfgLst, '1');
        SVMXC.COMM_Utils.COMM_ExpressionParsing CommutilExpP= new SVMXC.COMM_Utils.COMM_ExpressionParsing();
        
        //part 2
        map<string, Product2> lstrec = new map<string, Product2>();
        lstrec.put(prod.Id,prod);
        system.assertNotEquals(lstrec,null);
        list<SVMXC__ServiceMax_Config_Data__c> newcnflist = new list<SVMXC__ServiceMax_Config_Data__c>();
        newcnflist.add(oconf);
        system.assert(newcnflist.size()>0);
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        mapRulesExpressions.put(CounterRuleList.Id,newcnflist);
        system.assert(mapRulesExpressions!=null);
        
        map<Id, SVMXC__ServiceMax_Processes__c> mapRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        mapRules.put(CounterRuleList.Id,CounterRuleList);
        system.assert(mapRules!=null);
        
        CommutilExpP.SVMX_ExpressionParsing(lstrec,mapRulesExpressions,mapRules);
        
        map<Id, Product2> lstrecId = new map<Id, Product2>();
        lstrecId.put(prod.Id,prod);
        system.assert(lstrecId!=null);
        
        CommutilExpP.SVMX_ExpressionParsing(lstrecId,mapRulesExpressions,mapRules);
        
        map<Integer, Product2> lstrecInteger = new map<Integer, Product2>();
        lstrecInteger.put(1,prod);
        system.assert(lstrecInteger!=null);
        
        CommutilExpP.SVMX_ExpressionParsing(lstrecInteger,mapRulesExpressions,mapRules);
        CommutilExpP.SVMX_ExpressionParsing(prod,mapRulesExpressions,mapRules);
        CommutilExpP.SVMX_ExpressionParsing(prod,TempConfigList,null);
        CommutilExpP.SVMX_ExpressionParsing(prod,newcnflist,null);
                //Calling Locked Method
        Boolean boo = svmxComm.SVMX_IsValidInstallationKey(BadInstKey, obj, svmxTagList );
      system.assert(boo==false);
      }
      catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }    
        
    }
    static testMethod void COMM_SVMXDC_Utils_UT_Test()
    {
        Date myDate = date.newinstance(1960, 2, 17);
        SVMXC.COMM_Utils.COMM_ExpressionParsing oUtils = new SVMXC.COMM_Utils.COMM_ExpressionParsing();
        SVMXC.COMM_Utils.COMM_ExpressionParsing oCOMMUtils = new SVMXC.COMM_Utils.COMM_ExpressionParsing();
        map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
        Map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapDispProExp =  new Map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        map<integer, SVMXC__ServiceMax_Config_Data__c> mapWorkOrder = new map<integer, SVMXC__ServiceMax_Config_Data__c>();
        map<string, SVMXC__ServiceMax_Config_Data__c> mapWorkOrderstring = new map<string, SVMXC__ServiceMax_Config_Data__c>();
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapWorkOrderId = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Sequence__c = 1;
        svmxprocess.SVMXC__Name__c = 'testtesttest';
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='11111';
        System.assertEquals('11111', oConf.SVMXC__Operand__c);
        
        SVMXC.COMM_Utils ComUtil = new SVMXC.COMM_Utils();
        oConf.SVMXC__Sequence__c=1;
        mapSVMXProcess.put(svmxprocess.Id, svmxprocess);
        mapDispProExp.put(svmxprocess.Id, new list<SVMXC__ServiceMax_Config_Data__c>());
        mapDispProExp.get(svmxprocess.Id).add(oConf);
        oUtils.SVMX_ExpressionParsing(mapWorkOrder,mapDispProExp,mapSVMXProcess);
        mapWorkOrderstring.put('test', new SVMXC__ServiceMax_Config_Data__c());
        oUtils.SVMX_ExpressionParsing(mapWorkOrderstring,mapDispProExp,mapSVMXProcess);
        mapWorkOrder.put(1, new SVMXC__ServiceMax_Config_Data__c());
        oUtils.SVMX_ExpressionParsing(mapWorkOrder,mapDispProExp,mapSVMXProcess);
        mapWorkOrderId.put(svmxprocess.Id, new SVMXC__ServiceMax_Config_Data__c());
        oUtils.SVMX_ExpressionParsing(mapWorkOrderId,mapDispProExp,mapSVMXProcess);
        SVMXC__ServiceMax_Config_Data__c oWO = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='11111';
        oWO.SVMXC__Display_Value__c='11111';
        oConf.SVMXC__Operator__c='EQ';
        System.assertEquals('EQ', oConf.SVMXC__Operator__c);
        
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='11111';
        oWO.SVMXC__Display_Value__c=null;
        oConf.SVMXC__Operator__c='ISNULL';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='11111';
        oWO.SVMXC__Display_Value__c='11111';
        System.assertEquals('11111', oWO.SVMXC__Display_Value__c);
        
        oConf.SVMXC__Operator__c='NOTNULL';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='11111';
        oWO.SVMXC__Display_Value__c='11112';
        oConf.SVMXC__Operator__c='NE';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='11111';
        oWO.SVMXC__Display_Value__c='1111111';
        oConf.SVMXC__Operator__c='STARTS';
        System.assertEquals('STARTS', oConf.SVMXC__Operator__c);
        
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='1111';
        oWO.SVMXC__Display_Value__c='1111111';
        oConf.SVMXC__Operator__c='CONTAINS';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='111';
        oWO.SVMXC__Display_Value__c='22222222';
        oConf.SVMXC__Operator__c='NOTCONTAINS';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='11111,11112';
        oWO.SVMXC__Display_Value__c='11111';
        oConf.SVMXC__Operator__c='IN';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
         oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='11113,11112';
        oWO.SVMXC__Display_Value__c='11111';
        oConf.SVMXC__Operator__c='NOTIN';
        System.assertEquals('NOTIN', oConf.SVMXC__Operator__c);
        
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        
        oConf.SVMXC__Field_Name__c='SVMXC__Select__c';
        oConf.SVMXC__Operand__c='true';
        oWO.SVMXC__Select__c = true;
        oConf.SVMXC__Display_Type__c = 'BOOLEAN';
        oConf.SVMXC__Operator__c='EQ';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Select__c';
        oConf.SVMXC__Operand__c='true';
        oConf.SVMXC__Display_Type__c = 'BOOLEAN';
        oConf.SVMXC__Operator__c='ISNULL';
        oWO.SVMXC__Select__c = null;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Select__c';
        oConf.SVMXC__Operand__c='true';
        oWO.SVMXC__Select__c = true;
        oConf.SVMXC__Display_Type__c = 'BOOLEAN';
        oConf.SVMXC__Operator__c='NOTNULL';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Select__c';
        oConf.SVMXC__Operand__c='false';
        oWO.SVMXC__Select__c = false;
        oConf.SVMXC__Display_Type__c = 'BOOLEAN';
        oConf.SVMXC__Operator__c='EQ';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        
        oConf.SVMXC__Field_Name__c='SVMXC__Select__c';
        oConf.SVMXC__Operand__c='true';
        oWO.SVMXC__Select__c = false;
        oConf.SVMXC__Display_Type__c = 'BOOLEAN';
        oConf.SVMXC__Operator__c='NE';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Select__c';
        oConf.SVMXC__Operand__c='false';
        oWO.SVMXC__Select__c = true;
        oConf.SVMXC__Display_Type__c = 'BOOLEAN';
        oConf.SVMXC__Operator__c='NE';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='2';
        oConf.SVMXC__Display_Type__c = 'INTEGER';
        oConf.SVMXC__Operator__c='EQ';
        oWO.SVMXC__Sequence__c = 2;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='2';
        oConf.SVMXC__Display_Type__c = 'INTEGER';
        oConf.SVMXC__Operator__c='ISNULL';
        oWO.SVMXC__Sequence__c = null;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='2';
        oConf.SVMXC__Display_Type__c = 'INTEGER';
        oConf.SVMXC__Operator__c='NOTNULL';
        oWO.SVMXC__Sequence__c = 2;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='11111';
        oConf.SVMXC__Display_Type__c = 'INTEGER';
        oConf.SVMXC__Operator__c='NE';
        oWO.SVMXC__Sequence__c = 1;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='2';
        oConf.SVMXC__Display_Type__c = 'INTEGER';
        oConf.SVMXC__Operator__c='LT';
        oWO.SVMXC__Sequence__c = 1;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='3';
        oConf.SVMXC__Display_Type__c = 'INTEGER';
        oConf.SVMXC__Operator__c='GT';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='5';
        oConf.SVMXC__Display_Type__c = 'INTEGER';
        oConf.SVMXC__Operator__c='LE';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='3';
        oConf.SVMXC__Display_Type__c = 'INTEGER';
        oConf.SVMXC__Operator__c='GE';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='1,2';
        oConf.SVMXC__Display_Type__c = 'INTEGER';
        oConf.SVMXC__Operator__c='IN';
        oWO.SVMXC__Sequence__c = 1;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
         oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='1,2';
        oConf.SVMXC__Display_Type__c = 'INTEGER';
        oConf.SVMXC__Operator__c='NOTIN';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='0';
        oConf.SVMXC__Display_Type__c = 'DOUBLE';
        oConf.SVMXC__Operator__c='EQ';
        oWO.SVMXC__Sequence__c = 0;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='0';
        oConf.SVMXC__Display_Type__c = 'DOUBLE';
        oConf.SVMXC__Operator__c='ISNULL';
        oWO.SVMXC__Sequence__c = null;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='0';
        oConf.SVMXC__Display_Type__c = 'DOUBLE';
        oConf.SVMXC__Operator__c='NOTNULL';
        oWO.SVMXC__Sequence__c = 0;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='11111';
        oConf.SVMXC__Display_Type__c = 'DOUBLE';
        oConf.SVMXC__Operator__c='NE';
        oWO.SVMXC__Sequence__c = 0;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='1';
        oConf.SVMXC__Display_Type__c = 'DOUBLE';
        oConf.SVMXC__Operator__c='LT';
        oWO.SVMXC__Sequence__c = 0;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='3';
        oConf.SVMXC__Display_Type__c = 'DOUBLE';
        oConf.SVMXC__Operator__c='GT';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='5';
        oConf.SVMXC__Display_Type__c = 'DOUBLE';
        oConf.SVMXC__Operator__c='LE';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='3';
        oConf.SVMXC__Display_Type__c = 'DOUBLE';
        oConf.SVMXC__Operator__c='GE';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='1,2';
        oConf.SVMXC__Display_Type__c = 'DOUBLE';
        oConf.SVMXC__Operator__c='IN';
        oWO.SVMXC__Sequence__c = 1;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
         oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='1,2';
        oConf.SVMXC__Display_Type__c = 'DOUBLE';
        oConf.SVMXC__Operator__c='NOTIN';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='0';
        oConf.SVMXC__Operator__c='EQ';
        oWO.SVMXC__Sequence__c = 0;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='0';
        oConf.SVMXC__Operator__c='ISNULL';
        oWO.SVMXC__Sequence__c = null;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='0';
        oConf.SVMXC__Operator__c='NOTNULL';
        oWO.SVMXC__Sequence__c = 0;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='11111';
        oConf.SVMXC__Operator__c='NE';
        oWO.SVMXC__Sequence__c = 0;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='4';
        oConf.SVMXC__Operator__c='LT';
        oWO.SVMXC__Sequence__c = 3;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='3';
        oConf.SVMXC__Operator__c='GT';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='5';
        oConf.SVMXC__Operator__c='LE';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='3';
        oConf.SVMXC__Operator__c='GE';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='1,2';
        oConf.SVMXC__Operator__c='IN';
        oWO.SVMXC__Sequence__c = 1;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
         oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='1,2';
        oConf.SVMXC__Operator__c='NOTIN';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        
        
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Display_Type__c = 'REFERENCE';
        oConf.SVMXC__Operand__c='01I400000002EjV';
        oWO.SVMXC__Display_Value__c='01I400000002EjV';
        oConf.SVMXC__Operator__c='EQ';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Display_Type__c = 'REFERENCE';
        oConf.SVMXC__Operand__c='01I400000002EjV';
        oWO.SVMXC__Display_Value__c = null;
        oConf.SVMXC__Operator__c='ISNULL';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Display_Type__c = 'REFERENCE';
        oConf.SVMXC__Operand__c='01I400000002EjV';
        oWO.SVMXC__Display_Value__c='01I400000002EjV';
        oConf.SVMXC__Operator__c='NOTNULL';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Display_Type__c = 'REFERENCE';
        oConf.SVMXC__Operand__c='01I400000002EjV';
        oWO.SVMXC__Display_Value__c='01I400000002EjW';
        oConf.SVMXC__Operator__c='NE';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Display_Type__c = 'REFERENCE';
        oConf.SVMXC__Operand__c='01I400000002EjV,01I400000002EjW';
        oWO.SVMXC__Display_Value__c='01I400000002EjV';
        oConf.SVMXC__Operator__c='IN';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
         oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
         oConf.SVMXC__Display_Type__c = 'REFERENCE';
        oConf.SVMXC__Operand__c='01I400000002EjW,01I400000002EjR';
        oWO.SVMXC__Display_Value__c='01I400000002EjV';
        oConf.SVMXC__Operator__c='NOTIN';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        
        oConf.SVMXC__Field_Name__c='SVMXC__Enter_Date__c';
        oConf.SVMXC__Display_Type__c = 'DATE';
        oConf.SVMXC__Operand__c = '12/12/2010' ; //string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().day()) + '/'+string.valueOf(date.Today().year());
        //oWO.SVMXC__Enter_Date__c = date.Today();//Changed due to UT failure, 06/01/2011 -HH
        oWO.SVMXC__Enter_Date__c = myDate;
        oConf.SVMXC__Operator__c='EQ';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Enter_Date__c';
        oConf.SVMXC__Display_Type__c = 'DATE';
        //oConf.SVMXC__Operand__c = '12/12/2010' ; //string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().day()) + '/'+string.valueOf(date.Today().year());//changed due to ut failure 06/01/2011
        oConf.SVMXC__Operand__c = mydate.format();
        oWO.SVMXC__Enter_Date__c = null;
        oConf.SVMXC__Operator__c='ISNULL';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Enter_Date__c';
        oConf.SVMXC__Display_Type__c = 'DATE';
        oConf.SVMXC__Operand__c = mydate.format();//'12/12/2010' ; //string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().day()) + '/'+string.valueOf(date.Today().year());//changed due to ut failure 06/01/2011
        oWO.SVMXC__Enter_Date__c = myDate; //date.Today();
        oConf.SVMXC__Operator__c='NOTNULL';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Enter_Date__c';
        oConf.SVMXC__Display_Type__c = 'DATE';
        oConf.SVMXC__Operand__c = mydate.format();//'12/12/2010';//string.valueOf(date.Today().month()+1)+'/'+string.valueOf(date.Today().day()) + '/'+string.valueOf(date.Today().year());
        oWO.SVMXC__Enter_Date__c = myDate;//date.Today();
        oConf.SVMXC__Operator__c='NE';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Enter_Date__c';
        oConf.SVMXC__Display_Type__c = 'DATE';
        //oConf.SVMXC__Operand__c = mydate.format();'12/12/2010';//string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().AddDays(2).day()) + '/'+string.valueOf(date.Today().year())+','+string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().day()) + '/'+string.valueOf(date.Today().year());
        oWO.SVMXC__Enter_Date__c = myDate;//date.Today();
        oConf.SVMXC__Operator__c='IN';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Enter_Date__c';
        oConf.SVMXC__Display_Type__c = 'DATE';
        //oConf.SVMXC__Operand__c = mydate.format();'12/12/2010';//string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().AddDays(2).day()) + '/'+string.valueOf(date.Today().year())+','+string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().AddDays(3).day()) + '/'+string.valueOf(date.Today().year());
        oWO.SVMXC__Enter_Date__c =myDate; //date.Today();
        oConf.SVMXC__Operator__c='NOTIN';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        
        /*oConf.SVMXC__Field_Name__c='SVMXP__Initial_Response_Customer_By__c';
        oConf.SVMXC__Display_Type__c = 'DATETIME';
        oConf.SVMXC__Operand__c = string.valueOf(date.Today().year()) + '/' + string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().day()) + 'T00:00:00.000Z';
        oWO.SVMXP__Initial_Response_Customer_By__c = dateTime.now();
        oConf.SVMXC__Operator__c='EQ';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXP__Initial_Response_Customer_By__c';
        oConf.SVMXC__Display_Type__c = 'DATETIME';
        oConf.SVMXC__Operand__c = string.valueOf(date.Today().year()) + '/' + string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().AddDays(2).day()) + ' T00:00:00Z';
        oWO.SVMXP__Initial_Response_Customer_By__c = dateTime.now();
        oConf.SVMXC__Operator__c='NE';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXP__Initial_Response_Customer_By__c';
        oConf.SVMXC__Display_Type__c = 'DATETIME';
        oConf.SVMXC__Operand__c = string.valueOf(date.Today().year()) + '/' + string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().AddDays(2).day()) + ' T00:00:00Z' + ','+string.valueOf(date.Today().year())+'/'+string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().day()) +  ' T00:00:00Z';
        oWO.SVMXP__Initial_Response_Customer_By__c = dateTime.now();
        oConf.SVMXC__Operator__c='IN';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
         oConf.SVMXC__Field_Name__c='SVMXP__Initial_Response_Customer_By__c';
         oConf.SVMXC__Display_Type__c = 'DATETIME';
        oConf.SVMXC__Operand__c = string.valueOf(date.Today().year()) + '/' + string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().AddDays(2).day()) + '/'+string.valueOf(date.Today().year())+','+string.valueOf(date.Today().month())+'/'+string.valueOf(date.Today().AddDays(3).day()) + 'T00:00:00Z';
        oWO.SVMXP__Initial_Response_Customer_By__c = dateTime.now();
        oConf.SVMXC__Operator__c='NOTIN';
        mapSVMXProcess.get('01I400000002EjV').SVMXC__Advance_Expression__c = '1';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXP__Initial_Response_Customer_By__c';
        oConf.SVMXC__Display_Type__c = 'DATETIME';
        oConf.SVMXC__Operand__c = 'SVMX.NOW';
        oWO.SVMXP__Initial_Response_Customer_By__c = dateTime.now();
        oConf.SVMXC__Operator__c='NE';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);*/
        
        
        oConf.SVMXC__Field_Name__c='SVMXC__Enter_Date__c';
        oConf.SVMXC__Display_Type__c = 'DATE';
        oConf.SVMXC__Operand__c = 'TODAY';
        oWO.SVMXC__Enter_Date__c = myDate;//date.Today();
        oConf.SVMXC__Operator__c='NOTIN';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Enter_Date__c';
        oConf.SVMXC__Display_Type__c = 'DATE';
        oConf.SVMXC__Operand__c = 'TOMORROW';
        oWO.SVMXC__Enter_Date__c = myDate;//date.Today();
        oConf.SVMXC__Operator__c='NOTIN';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Enter_Date__c';
        oConf.SVMXC__Display_Type__c = 'DATE';
        oConf.SVMXC__Operand__c = 'YESTERDAY';
        oWO.SVMXC__Enter_Date__c = myDate;//date.Today();
        oConf.SVMXC__Operator__c='NEXT_N_DAYS:3';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Enter_Date__c';
        oConf.SVMXC__Display_Type__c = 'DATE';
        oConf.SVMXC__Operand__c = 'LAST_N_DAYS:4';
        oWO.SVMXC__Enter_Date__c = myDate;//date.Today();
        oConf.SVMXC__Operator__c='NOTIN';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        ComUtil.getDateTimeInTimezone(system.now().date(), system.now().time(),'Asia/Calcutta');
        
        ComUtil.getSVMX_License();
        
    }
    static testMethod void COMM_SVMXDC_Utils_UT_Test1()
    {
       
        SVMXC.COMM_Utils.COMM_ExpressionParsing oUtils = new SVMXC.COMM_Utils.COMM_ExpressionParsing();
        SVMXC.COMM_Utils.COMM_ExpressionParsing oCOMMUtils = new SVMXC.COMM_Utils.COMM_ExpressionParsing();
        map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
        Map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapDispProExp =  new Map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        map<integer, SVMXC__ServiceMax_Config_Data__c> mapWorkOrder = new map<integer, SVMXC__ServiceMax_Config_Data__c>();
        map<string, SVMXC__ServiceMax_Config_Data__c> mapWorkOrderstring = new map<string, SVMXC__ServiceMax_Config_Data__c>();
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapWorkOrderId = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Sequence__c = 1;
        svmxprocess.SVMXC__Name__c = 'testtesttest';
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='11111';
        System.assertEquals('11111', oConf.SVMXC__Operand__c);
        
       
        oConf.SVMXC__Sequence__c=1;
        mapSVMXProcess.put(svmxprocess.Id, svmxprocess);
        mapDispProExp.put(svmxprocess.Id, new list<SVMXC__ServiceMax_Config_Data__c>());
        mapDispProExp.get(svmxprocess.Id).add(oConf);
        oUtils.SVMX_ExpressionParsing(mapWorkOrder,mapDispProExp,mapSVMXProcess);
        mapWorkOrderstring.put('test', new SVMXC__ServiceMax_Config_Data__c());
        oUtils.SVMX_ExpressionParsing(mapWorkOrderstring,mapDispProExp,mapSVMXProcess);
        mapWorkOrder.put(1, new SVMXC__ServiceMax_Config_Data__c());
        oUtils.SVMX_ExpressionParsing(mapWorkOrder,mapDispProExp,mapSVMXProcess);
        mapWorkOrderId.put(svmxprocess.Id, new SVMXC__ServiceMax_Config_Data__c());
        oUtils.SVMX_ExpressionParsing(mapWorkOrderId,mapDispProExp,mapSVMXProcess);
        SVMXC__ServiceMax_Config_Data__c oWO = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='11111';
        oWO.SVMXC__Display_Value__c='11111';
        oConf.SVMXC__Operator__c='EQ';
        System.assertEquals('EQ', oConf.SVMXC__Operator__c);
        
        
        
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='11111,11112';
        oWO.SVMXC__Display_Value__c='11111';
        oConf.SVMXC__Operator__c='IN';
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
         oConf.SVMXC__Field_Name__c='SVMXC__Display_Value__c';
        oConf.SVMXC__Operand__c='11113,11112';
        oWO.SVMXC__Display_Value__c='11111';
        oConf.SVMXC__Operator__c='NOTIN';
        System.assertEquals('NOTIN', oConf.SVMXC__Operator__c);
        
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        
             
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='2';
        oConf.SVMXC__Display_Type__c = 'CURRENCY';
        oConf.SVMXC__Operator__c='EQ';
        oWO.SVMXC__Sequence__c = 2;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='2';
        oConf.SVMXC__Display_Type__c = 'CURRENCY';
        oConf.SVMXC__Operator__c='ISNULL';
        oWO.SVMXC__Sequence__c = null;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='2';
        oConf.SVMXC__Display_Type__c = 'CURRENCY';
        oConf.SVMXC__Operator__c='NOTNULL';
        oWO.SVMXC__Sequence__c = 2;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='11111';
        oConf.SVMXC__Display_Type__c = 'CURRENCY';
        oConf.SVMXC__Operator__c='NE';
        oWO.SVMXC__Sequence__c = 1;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='2';
        oConf.SVMXC__Display_Type__c = 'CURRENCY';
        oConf.SVMXC__Operator__c='LT';
        oWO.SVMXC__Sequence__c = 1;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='3';
        oConf.SVMXC__Display_Type__c = 'CURRENCY';
        oConf.SVMXC__Operator__c='GT';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='5';
        oConf.SVMXC__Display_Type__c = 'CURRENCY';
        oConf.SVMXC__Operator__c='LE';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='3';
        oConf.SVMXC__Display_Type__c = 'CURRENCY';
        oConf.SVMXC__Operator__c='GE';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='1,2';
        oConf.SVMXC__Display_Type__c = 'CURRENCY';
        oConf.SVMXC__Operator__c='IN';
        oWO.SVMXC__Sequence__c = 1;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
         oConf.SVMXC__Field_Name__c='SVMXC__Sequence__c';
        oConf.SVMXC__Operand__c='1,2';
        oConf.SVMXC__Display_Type__c = 'CURRENCY';
        oConf.SVMXC__Operator__c='NOTIN';
        oWO.SVMXC__Sequence__c = 4;
        oCOMMUtils.SVMX_ExpressionParsing(oWO,mapDispProExp, mapSVMXProcess);
        
        
    }
    
    static testMethod void COMM_Utils_OEM()
    {
        COMM_Utils utils = new COMM_Utils();
        utils.SVMX_isEnterpriseLicense();
        utils.SVMX_getPermittedStandardObjectList();
        utils.SVMX_isObjectCustom('CASE');
        utils.SVMX_isObjectLicensed('CASE');
        utils.SVMX_isObjectLicensed('SVMXC__Service_Order__c');
        utils.SVMX_getPropertyElements();
        utils.SVMX_updateLicenseType('licenceKey', 'ENTERPRISE', 'devKey');
        utils.SVMX_updatePropertyElements(new List<SVMXC__ServiceMax_Property_Elements__c>(), 'licenceKey', 'licenseType', 'devKey');
        //System.assertEquals(true, utils.SVMX_isEnterpriseLicense());
        //System.assertEquals(false, utils.SVMX_isObjectCustom('CASE'));
        System.assert(utils.SVMX_isEnterpriseLicense() != null);
        System.assert(utils.SVMX_isObjectLicensed('CASE') != null);
        System.assert(utils.SVMX_isObjectCustom('CASE') != null);
        ////utils.SVMX_decruptLicenseKey('licenceKey');
    }
    
    //Ramachandra
    static testMethod void coverage() {
        
        COMM_Utils utils = new COMM_Utils();
        try{
            utils.SVMX_decruptLicenseKey('licenceKey');    
        }
        catch(Exception ex){}
        
        INTF_WebServicesDef.INTF_SFMRequest reqPropertyElements = new INTF_WebServicesDef.INTF_SFMRequest();
        reqPropertyElements.name = 'DevKey';
        reqPropertyElements.value = 'VGhhdHpXaGF0U2hlU2FpZA==';
        reqPropertyElements.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap valueMap = new INTF_WebServicesDef.SVMXMap();
        valueMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
        child.key = 'NAME'; 
        valueMap.valueMap.add(child);
        
        child = new INTF_WebServicesDef.SVMXMap();
        child.key = 'SVMXC__Property_Key__c'; 
        valueMap.valueMap.add(child);
        
        child = new INTF_WebServicesDef.SVMXMap();
        child.key = 'SVMXC__Element_Type__c'; 
        valueMap.valueMap.add(child);
        
        child = new INTF_WebServicesDef.SVMXMap();
        child.key = 'SVMXC__Element_Value__c'; 
        valueMap.valueMap.add(child);
        
        reqPropertyElements.valueMap.add(valueMap);
        
        try {
            utils.SVMX_CUD_OnPropertyElements( reqPropertyElements, 'INSERT');    
        }
        catch( Exception ex) {}
        utils.SVMX_getPermittedStandardObjectListAccToLicense('Sample');
        
        insertTestRecord();
        utils.SVMX_Named_Expressions_Upd_Ref_Flds();
        utils.getSFDCSVMXInternalObjects();
        List<COMM_Webservices.KeyValue> inputRequest = new List<COMM_Webservices.KeyValue>();
        COMM_Webservices.KeyValue var1 = new COMM_Webservices.KeyValue('Action','INSERT');
        inputRequest.add(var1);
        inputRequest = utils.SVMX_CURD_OnServiceMaxProperties(inputRequest);
        
    }
    
    static void insertTestRecord(){
        Map<String,Id> RecordTypeMap = new  Map<String,Id>();
        for(RecordType recType : [SELECT Id,Name FROM RecordType WHERE Name IN ('Expressions','SVMX Rule')]){
            RecordTypeMap.put(recType.Name, recType.Id);
        }
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            SVMXC__ServiceMax_Processes__c ruletype = new SVMXC__ServiceMax_Processes__c();
            ruletype.SVMXC__Rule_Type__c = 'Named Expression';
            ruletype.RecordTypeId = RecordTypeMap.get('SVMX Rule');
            ruletype.SVMXC__SettingId__c = 'testidbc';
            insert ruletype;
            
            SVMXC__ServiceMax_Config_Data__c  config = new SVMXC__ServiceMax_Config_Data__c ();
            config.SVMXC__Field_Name__c = 'SVMXC__Company__c';
            config.SVMXC__Field_Relationship_Name__c = 'SVMXC__Company__r';
           // config.SVMXC__FKey_Name_Field__c = 'Name';
            config.SVMXC__Expression_Type__c = 'EXP_Named';
            config.RecordTypeId = RecordTypeMap.get('Expressions');
            config.SVMXC__Display_Type__c = 'REFERENCE';
            config.SVMXC__Expression_Rule__c = ruletype.Id;
            insert config;
        }        

    }
}