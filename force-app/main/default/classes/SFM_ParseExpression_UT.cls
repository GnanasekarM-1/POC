@isTest
Private with sharing class  SFM_ParseExpression_UT
{
    static testMethod void SFM_ExpressionParsing_UT_Test()
    {   
        
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        System.assertEquals(true, lstRecType != null);
        String TargetManager = '';
        String NameSearch = '';
        String Fieldmapping = '';
        String ProcessNodeObj = '';
        for(RecordType r : lstRecType)
        {
            if(r.Name == 'Target Manager')
                TargetManager = r.id;
            if(r.Name == 'Named Search')    
                NameSearch = r.id;
            if(r.Name == 'Field Mapping')
                Fieldmapping = r.id;    
            if(r.Name == 'Process Node Objects')    
                ProcessNodeObj = r.id;
        }
        
        //....... DATA CREATION..........
        SVMXC__Service_Order__c WOdata= new SVMXC__Service_Order__c();
        WOdata.SVMXC__Priority__c='High';
        WOdata.SVMXC__Order_Type__c='Open';
        WOdata.SVMXC__Locked_By_DC__c = true;
        insert WOdata;
        System.assertEquals(true, WOdata != null);
        
        SVMXC__ServiceMax_Processes__c  process_obj= new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c>Config_Details = new List<SVMXC__ServiceMax_Config_Data__c>();
        process_obj.RecordTypeId = NameSearch;
        process_obj.SVMXC__ProcessID__c='PROCESS11';
        process_obj.SVMXC__SettingId__c = 'PROCESS11';
        process_obj.SVMXC__MapID__c='PROCESS11';
        process_obj.SVMXC__Name__c = 'PROCESS22';
        process_obj.SVMXC__Parent_Object_Criteria__c = 'SVMXC__Priority__c != \'\'';
        process_obj.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        insert process_obj;
        System.assertEquals(true, process_obj != null);
        
        List<SObject> lstRecs = new  List<SObject>();
        SVMXC__Service_Order__c obj = new SVMXC__Service_Order__c();
        obj.SVMXC__Priority__c = 'High';
        insert obj;
        lstRecs.add(obj);
        System.assertEquals(true, lstRecs != null);
        
        //......Instance of Class.....      
        SFM_parseExpression ExpParsingObj = new SFM_parseExpression();   
        SFM_WrapperDef.SFM_Expression  ExpInfo= new SFM_WrapperDef.SFM_Expression(process_obj,Config_Details);
        
        //.....Call Methods......
        ExpParsingObj.SFM_ParseExpression(lstRecs,ExpInfo);
        
        SFMDeliveryServiceImpl.setIsQueryOptimizerEnabled(true);
        ExpParsingObj.SFM_ParseExpression(lstRecs,ExpInfo);

        ExpParsingObj.SFM_GetRecordsAfterApplyingCriteria(WOdata.id, 'SVMXC__Service_Order__c', 'Id', 'SVMXC__Order_Type__c = \'Open\'', 'Id', 'SVMXC__Priority__c');
        ExpParsingObj.SFM_GetRecordsAfterApplyingCriteria(WOdata.id, 'SVMXC__Service_Order__c', null, 'SVMXC__Order_Type__c = \'Open\'', null, 'SVMXC__Priority__c');
    }
}