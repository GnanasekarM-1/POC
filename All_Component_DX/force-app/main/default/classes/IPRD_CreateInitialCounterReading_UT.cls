@isTest
Private class IPRD_CreateInitialCounterReading_UT{
    static void createTestData(){
        //Query Record Types
        List<RecordType> lstRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'SVMXC__Counter_Details__c' OR SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        String strRuleRecordType;
        String strDefinitionRecordType;
        String strExpressionsRecordType;
        String strCounterReadingType;
        for(RecordType RT : lstRecordType){
            if(RT.Name == 'SVMX Rule')
                strRuleRecordType = RT.id;
            else if(RT.Name == 'Definition')
                strDefinitionRecordType = RT.id;
            else if(RT.Name == 'Expressions')
                strExpressionsRecordType = RT.id;
            else if(RT.Name == 'Reading')
                strCounterReadingType = RT.id;
        }
        
        //Creating Product
        Product2 objProduct = new Product2();
        objProduct.Name = 'TestProduct';
        objProduct.IsActive = true;
        objProduct.SVMXC__Product_Line__c = 'Accessory';
        objProduct.Family = 'Charger';
        insert objProduct;
        
        //Creating Installed Product
        SVMXC__Installed_Product__c objInstalledProduct = new SVMXC__Installed_Product__c();
        objInstalledProduct.Name = 'TestInstalledProduct';
        objInstalledProduct.SVMXC__Product__c = objProduct.id;
        objInstalledProduct.SVMXC__Serial_Lot_Number__c = 'Serial12345';
        objInstalledProduct.SVMXC__Status__c = 'Installed';
        insert objInstalledProduct;
        
        //Creating Counter Rules
        SVMXC__ServiceMax_Processes__c objCounterRule = new SVMXC__ServiceMax_Processes__c();
        objCounterRule.RecordTypeId = strRuleRecordType;
        objCounterRule.SVMXC__Name__c = 'TestRuleDef';
        objCounterRule.SVMXC__Select__c=true;
        objCounterRule.SVMXC__Rule_Type__c='Counters';
        objCounterRule.SVMXC__Sequence__c = 1;
        insert objCounterRule;
        system.assert(objCounterRule.SVMXC__Name__c!=null);
        
        //Creating Counter Expression
        SVMXC__ServiceMax_Config_Data__c objConfigDataExp = new SVMXC__ServiceMax_Config_Data__c();
        objConfigDataExp.RecordTypeId = strExpressionsRecordType;
        objConfigDataExp.SVMXC__Sequence__c = 1;
        objConfigDataExp.SVMXC__Field_Name__c='IsActive';
        objConfigDataExp.SVMXC__Display_Type__c = 'BOOLEAN';
        objConfigDataExp.SVMXC__Expression_Type__c='IPRD_Counters';
        objConfigDataExp.SVMXC__Expression_Rule__c = objCounterRule.Id;
        objConfigDataExp.SVMXC__Operator__c = 'eq';
        objConfigDataExp.SVMXC__Operand__c='true';
        insert objConfigDataExp;
        system.assert(objConfigDataExp.SVMXC__Expression_Type__c == 'IPRD_Counters');
        
        //Creating Counter Definition
        SVMXC__Counter_Details__c objCounterDefinition = new SVMXC__Counter_Details__c();
        objCounterDefinition.RecordTypeID = strDefinitionRecordType;
        objCounterDefinition.SVMXC__Counter_Rule__c = objCounterRule.Id;
        objCounterDefinition.SVMXC__Counter_Name__c = 'Test11';
        objCounterDefinition.SVMXC__Counter_Type__c = 'Increasing';
        objCounterDefinition.SVMXC__Active__c = true;
        objCounterDefinition.SVMXC__Grows_Reduces_By__c=1;
        objCounterDefinition.SVMXC__Min_Value__c = 50;
        objCounterDefinition.SVMXC__Max_Value__c = 100;
        insert objCounterDefinition;
        system.assert(objCounterDefinition.RecordTypeId!=null);
        
        SVMXC__Counter_Details__c objCounterDefinition2 = new SVMXC__Counter_Details__c();
        objCounterDefinition2.RecordTypeID = strDefinitionRecordType;
        objCounterDefinition2.SVMXC__Counter_Rule__c = objCounterRule.Id;
        objCounterDefinition2.SVMXC__Counter_Name__c = 'Test1122';
        objCounterDefinition2.SVMXC__Counter_Type__c = 'Increasing';
        objCounterDefinition2.SVMXC__Active__c = true;
        objCounterDefinition2.SVMXC__Grows_Reduces_By__c=1;
        objCounterDefinition2.SVMXC__Min_Value__c = 50;
        objCounterDefinition2.SVMXC__Max_Value__c = 100;
        insert objCounterDefinition2;
        system.assert(objCounterDefinition2.RecordTypeId!=null);
        
        SVMXC__Counter_Details__c objCounterDefinition3 = new SVMXC__Counter_Details__c();
        objCounterDefinition3.RecordTypeID = strDefinitionRecordType;
        objCounterDefinition3.SVMXC__Counter_Rule__c = objCounterRule.Id;
        objCounterDefinition3.SVMXC__Counter_Name__c = 'Test1133';
        objCounterDefinition3.SVMXC__Counter_Type__c = 'Decreasing';
        objCounterDefinition3.SVMXC__Active__c = true;
        objCounterDefinition3.SVMXC__Grows_Reduces_By__c=1;
        objCounterDefinition3.SVMXC__Min_Value__c = 50;
        objCounterDefinition3.SVMXC__Max_Value__c = 100;
        insert objCounterDefinition3;
        system.assert(objCounterDefinition3.RecordTypeId!=null);
        
        //Creating Counter Reading
        SVMXC__Counter_Details__c objCounterReading = new SVMXC__Counter_Details__c();
        objCounterReading.RecordTypeID = strCounterReadingType;
        objCounterReading.SVMXC__Counter_Rule__c = objCounterRule.Id;
        objCounterReading.SVMXC__Counter_Definition__c = objCounterDefinition2.id;
        objCounterReading.SVMXC__Counter_Name__c = 'Test1122';
        objCounterReading.SVMXC__Counter_Type__c = 'Increasing';
        objCounterReading.SVMXC__Active__c = true;
        objCounterReading.SVMXC__Grows_Reduces_By__c=1;
        objCounterReading.SVMXC__Min_Value__c = 50;
        objCounterReading.SVMXC__Max_Value__c = 100;
        objCounterReading.SVMXC__Installed_Product__c = objInstalledProduct.id;
        objCounterReading.SVMXC__Product__c = objProduct.id;
        objCounterReading.SVMXC__Counter_Reading__c = 60;
        insert objCounterReading;
        system.assert(objCounterReading.RecordTypeId!=null);
    }
    static testMethod void CallServiceWithNoIBs(){
        List<String> lstIBId = new List<String>();        
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        SVMXC.SFM_WrapperDef.SFM_StringListMap objSFM_StringListMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
        objSFM_StringListMap.key = 'RecordIds';
        objSFM_StringListMap.valueList = lstIBId;
        request.stringListMap.add(objSFM_StringListMap);
        
        IPRD_CreateInitialCounterReading objCreateCounterReadings = new IPRD_CreateInitialCounterReading();
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = objCreateCounterReadings.executeService(request);
        System.assert(objResponse.success == true);
        System.assert(objResponse.StringLstMap.size()==0);
    }
    static testMethod void CallServiceWithIB(){
        createTestData();
        List<String> lstIBId = new List<String>();
        List<SVMXC__Installed_Product__c> lstIBs = [SELECT Id FROM SVMXC__Installed_Product__c WHERE Name = 'TestInstalledProduct'];
        lstIBId.add(lstIBs[0].id);
        
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        SVMXC.SFM_WrapperDef.SFM_StringListMap objSFM_StringListMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
        objSFM_StringListMap.key = 'RecordIds';
        objSFM_StringListMap.valueList = lstIBId;
        request.stringListMap.add(objSFM_StringListMap);
        
        IPRD_CreateInitialCounterReading objCreateCounterReadings = new IPRD_CreateInitialCounterReading();
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = objCreateCounterReadings.executeService(request);
        System.assert(objResponse.success == true);
        System.assert(objResponse.StringLstMap.size()>0);
        
        List<SVMXC__Counter_Details__c> lstCounterReading = new List<SVMXC__Counter_Details__c>();
        String strRecordType='Reading';
        lstCounterReading = Database.Query('SELECT Id,SVMXC__Counter_Name__c, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__c,SVMXC__Counter_Reading__c,SVMXC__Counter_Type__c,SVMXC__Grows_Reduces_By__c,SVMXC__Min_Value__c,SVMXC__Max_Value__c,SVMXC__Active__c,SVMXC__Select__c,SVMXC__Counter_Rule__c,SVMXC__Counter_Rule__r.Name FROM SVMXC__Counter_Details__c WHERE SVMXC__Installed_Product__c IN: lstIBId and RecordType.Name=:strRecordType');
        Set<String> setReadingIDsByQuery = new Set<String>();
        for(SVMXC__Counter_Details__c obj: lstCounterReading)
            setReadingIDsByQuery.add(obj.id);
        
        SVMXC.SFM_WrapperDef.SFM_StringListMap tempObject = objResponse.StringLstMap[0];
        System.assert(tempObject.key == lstIBId[0]);
        System.assert(tempObject.valueList.size()>0);
        
        Set<String> setReadingIDs = new Set<String>();
        setReadingIDs.addAll(tempObject.valueList);
        System.assert(setReadingIDsByQuery.containsAll(setReadingIDs) == true);
    }
}