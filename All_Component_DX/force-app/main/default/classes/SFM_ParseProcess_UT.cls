@isTest(SeeAllData=true)
private with sharing class SFM_ParseProcess_UT 
{

    public static map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    public static map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    
    public SFM_ParseProcess_UT()
    {
        gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            Schema.DescribeSObjectResult result = s.getDescribe();
            allobjmap.put(result.getName(),s);
        } 
    }  
    static testMethod void getObjectRecordTypeId_test(){
        String recordTypeId = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Processes__c', 'Forward_Shipment_Process');
        System.assert(recordTypeId != NULL);
    } 

 static testMethod void getObjectRecordTypeId2_test(){ 
       SObjectType stype= schema.Sobjecttype.SVMXC__ServiceMax_Processes__c.getSobjectType(); 
       String recordTypeId = COMM_RecordTypeUtilities.getObjectRecordTypeId(stype, 'Forward_Shipment_Process');
       System.assert(recordTypeId != NULL);
    } 
    
    static testMethod void getObjectRecordTypeId3_test(){ 
        Map<String,Id> recordTypeMap = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Processes__c');
       System.assert(recordTypeMap.size() > 0);
    } 
    
    
   
    
    
    
    static testMethod void ForStandAloneCreate()
    {
        String targetManager;
        String processNodeObjects;
        String objectMapping; 
        String fieldMapping;
        String expression;
        String SVMXRule;
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
            for(RecordType r : RTypeList)
            {
                if(r.Name == 'Target Manager')
                    targetManager = r.id;
                else if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
                else if(r.Name == 'Object Mapping')
                    objectMapping = r.id;
                else if(r.Name == 'Field Mapping')
                    fieldMapping = r.id;
                else if(r.Name == 'Expressions')
                    expression = r.id;  
                else if(r.Name == 'SVMX Rule')
                    SVMXRule = r.Name;      
            }
        }
        //Create PageHeader
        SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
        PageHeader.SVMXC__Name__c = 'PAGE00001';
        PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        PageHeader.SVMXC__Type__c = 'Header';
        insert PageHeader;
        //Create PageDetail
        SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
        PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
        PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        PageDetail.SVMXC__Type__c = 'Detail';
        insert PageDetail;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c standaloneCreate = new SVMXC__ServiceMax_Processes__c();
        standaloneCreate.SVMXC__Name__c = 'CUSTOMPRO0001';
        standaloneCreate.RecordTypeId = targetManager;
        standaloneCreate.SVMXC__Purpose__c = 'STANDALONE CREATE';
        standaloneCreate.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        standaloneCreate.SVMXC__Page_Layout__c = PageHeader.id;
        insert standaloneCreate;
        
        //Create Mapping For Header Record
        SVMXC__ServiceMax_Processes__c valMapHdr = new SVMXC__ServiceMax_Processes__c();
        valMapHdr.SVMXC__MapID__c = 'VMAP000001';
        valMapHdr.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
        valMapHdr.RecordTypeId = objectMapping;
        insert valMapHdr;
        //Create Mapping For Detail Record
        SVMXC__ServiceMax_Processes__c valMapDetail = new SVMXC__ServiceMax_Processes__c();
        valMapDetail.SVMXC__MapID__c = 'VMAP000002';
        valMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
        valMapDetail.RecordTypeId = objectMapping;
        insert valMapDetail;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject1.SVMXC__Process__c = standaloneCreate.id;
        PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'TARGETCHILD';
        PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject2.SVMXC__Process__c = standaloneCreate.id;
        PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
        listProcessNodeObjects.add(PNObject2);
        insert listProcessNodeObjects;
        Test.startTest();
        try
        {
            SVMXC.SFM_ParseProcess obj = new SVMXC.SFM_ParseProcess ();
            obj.getSFM_ParseProcess(standaloneCreate.id,Null,allobjmap,null);
        }
        catch(Exception ex)
        {
            system.debug('Exception: '+ex.getMessage());
        }   
        Test.stopTest();
    }  
    static testMethod void ForSourceToTargetAll()
    {
        String targetManager;
        String processNodeObjects;
        String objectMapping; 
        String fieldMapping;
        String expression;
        String SVMXRule;
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
            for(RecordType r : RTypeList)
            {
                if(r.Name == 'Target Manager')
                    targetManager = r.id;
                else if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
                else if(r.Name == 'Object Mapping')
                    objectMapping = r.id;
                else if(r.Name == 'Field Mapping')
                    fieldMapping = r.id;
                else if(r.Name == 'Expressions')
                    expression = r.id;  
                else if(r.Name == 'SVMX Rule')
                    SVMXRule = r.id;        
            }
        }
        //Create PageHeader
        SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
        PageHeader.SVMXC__Name__c = 'PAGE00001';
        PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        PageHeader.SVMXC__Type__c = 'Header';
        insert PageHeader;
        //Create PageDetail
        SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
        PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
        PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        PageDetail.SVMXC__Type__c = 'Detail';
        insert PageDetail;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c SourceToTargetAll = new SVMXC__ServiceMax_Processes__c();
        SourceToTargetAll.SVMXC__Name__c = 'CUSTOMPRO0001';
        SourceToTargetAll.RecordTypeId = targetManager;
        SourceToTargetAll.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL';
        SourceToTargetAll.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        SourceToTargetAll.SVMXC__Page_Layout__c = PageHeader.id;
        insert SourceToTargetAll;
        
        //Create Mapping For Header Record
        SVMXC__ServiceMax_Processes__c valMapHdr = new SVMXC__ServiceMax_Processes__c();
        valMapHdr.SVMXC__MapID__c = 'VMAP000001';
        valMapHdr.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
        valMapHdr.RecordTypeId = objectMapping;
        insert valMapHdr;
        //Create Mapping For Detail Record
        SVMXC__ServiceMax_Processes__c valMapDetail = new SVMXC__ServiceMax_Processes__c();
        valMapDetail.SVMXC__MapID__c = 'VMAP000002';
        valMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
        valMapDetail.RecordTypeId = objectMapping;
        insert valMapDetail;
        
        //Create Expression Record
        SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
        ExpressionRec.RecordTypeId = SVMXRule;
        ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
        ExpressionRec.SVMXC__Name__c = 'EXpression111';
        ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
        insert ExpressionRec;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject1.SVMXC__Process__c = SourceToTargetAll.id;
        PNObject1.SVMXC__Submodule__c = ExpressionRec.id;
        PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
        PNObject1.SVMXC__Module__c = valMapHdr.id;
        PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote__c';
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'TARGETCHILD';
        PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject2.SVMXC__Process__c = SourceToTargetAll.id;
        PNObject2.SVMXC__Submodule__c = ExpressionRec.id;
        PNObject2.SVMXC__Module__c = valMapDetail.id;
        PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
        PNObject2.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote_Line__c';
        listProcessNodeObjects.add(PNObject2);
        
        SVMXC__ServiceMax_Processes__c PNObject3 = new SVMXC__ServiceMax_Processes__c();
        PNObject3.RecordTypeId = processNodeObjects;
        PNObject3.SVMXC__Type__c = 'SOURCE';
        PNObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject3.SVMXC__Process__c = SourceToTargetAll.id;
        PNObject3.SVMXC__Final_Exception_Process__c = valMapHdr.id;
        listProcessNodeObjects.add(PNObject3);
        
        SVMXC__ServiceMax_Processes__c PNObject4 = new SVMXC__ServiceMax_Processes__c();
        PNObject4.RecordTypeId = processNodeObjects;
        PNObject4.SVMXC__Type__c = 'SOURCECHILD';
        PNObject4.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject4.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject4.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject4.SVMXC__Process__c = SourceToTargetAll.id;
        PNObject4.SVMXC__Final_Exception_Process__c = valMapDetail.id;
        listProcessNodeObjects.add(PNObject4);
        insert listProcessNodeObjects;
        
        SVMXC__Quote__c Quote = new SVMXC__Quote__c();
        Quote.SVMXC__Discount__c  = 10;
        Quote.SVMXC__Discount_Type__c = 'amount';
        Quote.SVMXC__Valid_Until__c = system.today() + 15;
        insert Quote;
        SVMXC__Quote_Line__c QLine = new SVMXC__Quote_Line__c();
        QLine.SVMXC__Quote__c = Quote.id;
        QLine.SVMXC__Discount__c  = 10;
        QLine.SVMXC__Discount_Type__c = 'amount';
        insert QLine;
        Test.startTest();
        try
        {
            SVMXC.SFM_ParseProcess obj = new SVMXC.SFM_ParseProcess ();
            obj.getSFM_ParseProcess(SourceToTargetAll.id,Quote.id,allobjmap,null);

            SFMDeliveryServiceImpl.setIsQueryOptimizerEnabled(true);
            obj.getSFM_ParseProcess(SourceToTargetAll.id,Quote.id,allobjmap,null);
            
            PNObject2.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote__c';
            update PNObject2;
            obj.getSFM_ParseProcess(SourceToTargetAll.id,Quote.id,allobjmap,null);

            SFMDeliveryServiceImpl.setIsQueryOptimizerEnabled(false);
            obj.getSFM_ParseProcess(SourceToTargetAll.id,Quote.id,allobjmap,null);
        }
        catch(Exception ex)
        {
            system.debug('Exception: '+ex.getMessage());
        }
        Test.stopTest();
    }
    static testMethod void ForStandAloneEdit()
    {
        String targetManager;
        String processNodeObjects;
        String objectMapping; 
        String fieldMapping;
        String expression;
        String SVMXRule;
        String RuleRecordTypeId;
        String ProBizRuleRTypeId;
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
            for(RecordType r : RTypeList)
            {
                if(r.Name == 'Target Manager')
                    targetManager = r.id;
                else if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
                else if(r.Name == 'Object Mapping')
                    objectMapping = r.id;
                else if(r.Name == 'Field Mapping')
                    fieldMapping = r.id;
                else if(r.Name == 'Expressions')
                    expression = r.id;  
                else if(r.Name == 'SVMX Rule')
                    SVMXRule = r.id;    
                else if(r.Name == 'Business Rule')
                    RuleRecordTypeId = r.id; 
                else if(r.Name == 'Process Business Rule')
                    ProBizRuleRTypeId = r.id;    
            }
        }

        //Create PageHeader
        SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
        PageHeader.SVMXC__Name__c = 'PAGE00001';
        PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        PageHeader.SVMXC__Type__c = 'Header';
        insert PageHeader;
        //Create PageDetail
        SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
        PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
        PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        PageDetail.SVMXC__Type__c = 'Detail';
        insert PageDetail;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c StandAloneEdit = new SVMXC__ServiceMax_Processes__c();
        StandAloneEdit.SVMXC__Name__c = 'CUSTOMPRO0001';
        StandAloneEdit.RecordTypeId = targetManager;
        StandAloneEdit.SVMXC__Purpose__c = 'STANDALONE EDIT';
        StandAloneEdit.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        StandAloneEdit.SVMXC__Page_Layout__c = PageHeader.id;
        insert StandAloneEdit;
        
        //Create Mapping For Header Record
        SVMXC__ServiceMax_Processes__c valMapHdr = new SVMXC__ServiceMax_Processes__c();
        valMapHdr.SVMXC__MapID__c = 'VMAP000001';
        valMapHdr.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
        valMapHdr.RecordTypeId = objectMapping;
        insert valMapHdr;
        //Create Mapping For Detail Record
        SVMXC__ServiceMax_Processes__c valMapDetail = new SVMXC__ServiceMax_Processes__c();
        valMapDetail.SVMXC__MapID__c = 'VMAP000002';
        valMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
        valMapDetail.RecordTypeId = objectMapping;
        insert valMapDetail;
        
        //Create Expression Record
        SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
        ExpressionRec.RecordTypeId = SVMXRule;
        ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
        ExpressionRec.SVMXC__Name__c = 'EXpression111';
        ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
        insert ExpressionRec;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject1.SVMXC__Process__c = StandAloneEdit.id;
        PNObject1.SVMXC__Submodule__c = ExpressionRec.id;
        PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
        PNObject1.SVMXC__Module__c = valMapHdr.id;
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'TARGETCHILD';
        PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject2.SVMXC__Process__c = StandAloneEdit.id;
        PNObject2.SVMXC__Submodule__c = ExpressionRec.id;
        PNObject2.SVMXC__Module__c = valMapDetail.id;
        PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
        PNObject2.SVMXC__Values__c = '{"lstSortingRec":[{"sortingOrder":"ASC","dataType":"CURRENCY","fieldAPIName":"SVMXC__Line_Price2__c","queryField":"SVMXC__Line_Price2__c"}]}';
        listProcessNodeObjects.add(PNObject2);
        insert listProcessNodeObjects;
        
        SVMXC__Quote__c Quote = new SVMXC__Quote__c();
        Quote.SVMXC__Discount__c  = 10;
        Quote.SVMXC__Discount_Type__c = 'amount';
        Quote.SVMXC__Valid_Until__c = system.today() + 15;
        insert Quote;
        SVMXC__Quote_Line__c QLine = new SVMXC__Quote_Line__c();
        QLine.SVMXC__Quote__c = Quote.id;
        QLine.SVMXC__Discount__c  = 10;
        QLine.SVMXC__Discount_Type__c = 'amount';
        insert QLine;

        //Adding business rule
        SVMXC__ServiceMax_Processes__c BizRule1 = new SVMXC__ServiceMax_Processes__c();
        BizRule1.RecordTypeId = RuleRecordTypeId;
        BizRule1.SVMXC__Name__c = 'Test Biz Rule 001';
        BizRule1.SVMXC__ProcessID__c = 'My_Biz_Rule_001';
        BizRule1.SVMXC__Description__c = 'Test Biz Rule 001';
        BizRule1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        BizRule1.SVMXC__Advance_Expression__c = '1 AND 2';
        BizRule1.SVMXC__Parent_Error_Msg__c = 'test';
        BizRule1.SVMXC__Message_Type__c = 'Error';
        insert BizRule1;
        system.assert(BizRule1.SVMXC__ProcessID__c != NULL);
        system.assert(BizRule1.SVMXC__Source_Object_Name__c != NULL);
        
        List<SVMXC__ServiceMax_Config_Data__c> lstBizRuleExpr = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr11 = new SVMXC__ServiceMax_Config_Data__c();
        BizRuleExpr11.RecordTypeId = expression;
        BizRuleExpr11.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr11.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr11.SVMXC__Sequence__c = 1;
        BizRuleExpr11.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        BizRuleExpr11.SVMXC__Field_Name__c = 'SVMXC__Discount_Type__c';
        BizRuleExpr11.SVMXC__Operator__c = 'eq';
        BizRuleExpr11.SVMXC__Operand__c = 'SVMXC__Status__c';
        BizRuleExpr11.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        BizRuleExpr11.SVMXC__Display_Type__c = 'PICKLIST';
        BizRuleExpr11.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr11.SVMXC__FKey_Name_Field__c = NULL;
        lstBizRuleExpr.add(BizRuleExpr11);
        
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr12 = new SVMXC__ServiceMax_Config_Data__c();
        BizRuleExpr12.RecordTypeId = expression;
        BizRuleExpr12.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr12.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr12.SVMXC__Sequence__c = 2;
        BizRuleExpr12.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        BizRuleExpr12.SVMXC__Field_Name__c = 'SVMXC__Discount_Type__c';
        BizRuleExpr12.SVMXC__Operator__c = 'eq';
        BizRuleExpr12.SVMXC__Parameter_Type__c = 'Value';
        BizRuleExpr12.SVMXC__Operand__c = 'Amount';
        BizRuleExpr12.SVMXC__Display_Type__c = 'PICKLIST';
        BizRuleExpr12.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr12.SVMXC__FKey_Name_Field__c = NULL;
        lstBizRuleExpr.add(BizRuleExpr12);
        insert lstBizRuleExpr;

        //Process Biz Rule
        SVMXC__ServiceMax_Processes__c ProBizRule = new SVMXC__ServiceMax_Processes__c();
        ProBizRule.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule.SVMXC__Process1__c = StandAloneEdit.Id;
        ProBizRule.SVMXC__Process2__c = listProcessNodeObjects[0].Id;
        ProBizRule.SVMXC__Process3__c = BizRule1.Id;
        insert ProBizRule;

        Test.startTest();
        try
        {
            SVMXC.SFM_ParseProcess obj = new SVMXC.SFM_ParseProcess ();
            obj.getSFM_ParseProcess(StandAloneEdit.id,Quote.id,allobjmap,null);

            SFMDeliveryServiceImpl.setIsQueryOptimizerEnabled(true);
            obj.getSFM_ParseProcess(StandAloneEdit.id,Quote.id,allobjmap,null);
        }
        catch(Exception ex)
        {
            system.debug('Exception: '+ex.getMessage());
        }
        Test.stopTest();    
    }
    static testMethod void ForStandAloneView()
    {
        String targetManager;
        String processNodeObjects;
        String objectMapping; 
        String fieldMapping;
        String expression;
        String SVMXRule;
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
            for(RecordType r : RTypeList)
            {
                if(r.Name == 'Target Manager')
                    targetManager = r.id;
                else if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
                else if(r.Name == 'Object Mapping')
                    objectMapping = r.id;
                else if(r.Name == 'Field Mapping')
                    fieldMapping = r.id;
                else if(r.Name == 'Expressions')
                    expression = r.id;  
                else if(r.Name == 'SVMX Rule')
                    SVMXRule = r.id;        
            }
        }
        //Create PageHeader
        SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
        PageHeader.SVMXC__Name__c = 'PAGE00001';
        PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        PageHeader.SVMXC__Type__c = 'Header';
        insert PageHeader;
        //Create PageDetail
        SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
        PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
        PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        PageDetail.SVMXC__Type__c = 'Detail';
        insert PageDetail;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c StandAloneView = new SVMXC__ServiceMax_Processes__c();
        StandAloneView.SVMXC__Name__c = 'CUSTOMPRO0001';
        StandAloneView.RecordTypeId = targetManager;
        StandAloneView.SVMXC__Purpose__c = 'VIEW RECORD';
        StandAloneView.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        StandAloneView.SVMXC__Page_Layout__c = PageHeader.id;
        insert StandAloneView;
        
        //Create Expression Record
        SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
        ExpressionRec.RecordTypeId = SVMXRule;
        ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
        ExpressionRec.SVMXC__Name__c = 'EXpression111';
        ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
        insert ExpressionRec;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject1.SVMXC__Process__c = StandAloneView.id;
        PNObject1.SVMXC__Submodule__c = ExpressionRec.id;
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'TARGETCHILD';
        PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject2.SVMXC__Process__c = StandAloneView.id;
        PNObject2.SVMXC__Submodule__c = ExpressionRec.id;
        listProcessNodeObjects.add(PNObject2);
        insert listProcessNodeObjects;
        
        SVMXC__Quote__c Quote = new SVMXC__Quote__c();
        Quote.SVMXC__Discount__c  = 10;
        Quote.SVMXC__Discount_Type__c = 'amount';
        Quote.SVMXC__Valid_Until__c = system.today() + 15;
        insert Quote;
        SVMXC__Quote_Line__c QLine = new SVMXC__Quote_Line__c();
        QLine.SVMXC__Quote__c = Quote.id;
        QLine.SVMXC__Discount__c  = 10;
        QLine.SVMXC__Discount_Type__c = 'amount';
        insert QLine;
        Test.startTest();
        try
        {
            SVMXC.SFM_ParseProcess obj = new SVMXC.SFM_ParseProcess ();
            obj.getSFM_ParseProcess(StandAloneView.id,Quote.id,allobjmap,null);
        }
        catch(Exception ex)
        {
            system.debug('Exception: '+ex.getMessage());
        }
        Test.stopTest();    
    }
    static testMethod void ForSourceToTargetChild()
    {
        String targetManager;
        String processNodeObjects;
        String objectMapping; 
        String fieldMapping;
        String expression;
        String SVMXRule;
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
            for(RecordType r : RTypeList)
            {
                if(r.Name == 'Target Manager')
                    targetManager = r.id;
                else if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
                else if(r.Name == 'Object Mapping')
                    objectMapping = r.id;
                else if(r.Name == 'Field Mapping')
                    fieldMapping = r.id;
                else if(r.Name == 'Expressions')
                    expression = r.id;  
                else if(r.Name == 'SVMX Rule')
                    SVMXRule = r.id;        
            }
        }
        //Create PageHeader
        SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c(); 
        PageHeader.SVMXC__Name__c = 'PAGE00001';
        PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        PageHeader.SVMXC__Type__c = 'Header';
        insert PageHeader;
        //Create PageDetail
        SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
        PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
        PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        PageDetail.SVMXC__Type__c = 'Detail';
        insert PageDetail;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c SourceToTargetChild = new SVMXC__ServiceMax_Processes__c();
        SourceToTargetChild.SVMXC__Name__c = 'CUSTOMPRO0001';
        SourceToTargetChild.RecordTypeId = targetManager;
        SourceToTargetChild.SVMXC__Purpose__c = 'SOURCE TO TARGET CHILD';
        SourceToTargetChild.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        SourceToTargetChild.SVMXC__Page_Layout__c = PageHeader.id;
        insert SourceToTargetChild;
        
        //Create Mapping For Header Record
        SVMXC__ServiceMax_Processes__c valMapHdr = new SVMXC__ServiceMax_Processes__c();
        valMapHdr.SVMXC__MapID__c = 'VMAP000001';
        valMapHdr.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
        valMapHdr.RecordTypeId = objectMapping;
        insert valMapHdr;
        //Create Mapping For Detail Record
        SVMXC__ServiceMax_Processes__c valMapDetail = new SVMXC__ServiceMax_Processes__c();
        valMapDetail.SVMXC__MapID__c = 'VMAP000002';
        valMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
        valMapDetail.RecordTypeId = objectMapping;
        insert valMapDetail;
        
        //Create Expression Record
        SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
        ExpressionRec.RecordTypeId = SVMXRule;
        ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
        ExpressionRec.SVMXC__Name__c = 'EXpression111';
        ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
        insert ExpressionRec;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject1.SVMXC__Process__c = SourceToTargetChild.id;
        PNObject1.SVMXC__Submodule__c = ExpressionRec.id;
        PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
        PNObject1.SVMXC__Module__c = valMapHdr.id;
        PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote__c';
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'TARGETCHILD';
        PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject2.SVMXC__Process__c = SourceToTargetChild.id;
        PNObject2.SVMXC__Submodule__c = ExpressionRec.id;
        PNObject2.SVMXC__Module__c = valMapDetail.id;
        PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
        PNObject2.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote_Line__c';
        listProcessNodeObjects.add(PNObject2);
        
        SVMXC__ServiceMax_Processes__c PNObject3 = new SVMXC__ServiceMax_Processes__c();
        PNObject3.RecordTypeId = processNodeObjects;
        PNObject3.SVMXC__Type__c = 'SOURCE';
        PNObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject3.SVMXC__Process__c = SourceToTargetChild.id;
        PNObject3.SVMXC__Final_Exception_Process__c = valMapHdr.id;
        listProcessNodeObjects.add(PNObject3);
        
        SVMXC__ServiceMax_Processes__c PNObject4 = new SVMXC__ServiceMax_Processes__c();
        PNObject4.RecordTypeId = processNodeObjects;
        PNObject4.SVMXC__Type__c = 'SOURCECHILD';
        PNObject4.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject4.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject4.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject4.SVMXC__Process__c = SourceToTargetChild.id;
        PNObject4.SVMXC__Final_Exception_Process__c = valMapDetail.id;
        listProcessNodeObjects.add(PNObject4);
        insert listProcessNodeObjects;
        
        SVMXC__Quote__c Quote = new SVMXC__Quote__c();
        Quote.SVMXC__Discount__c  = 10;
        Quote.SVMXC__Discount_Type__c = 'amount';
        Quote.SVMXC__Valid_Until__c = system.today() + 15;
        insert Quote;
        SVMXC__Quote_Line__c QLine = new SVMXC__Quote_Line__c();
        QLine.SVMXC__Quote__c = Quote.id;
        QLine.SVMXC__Discount__c  = 10;
        QLine.SVMXC__Discount_Type__c = 'amount';
        insert QLine;
        Test.startTest();
        try
        {
            SVMXC.SFM_ParseProcess obj = new SVMXC.SFM_ParseProcess ();
            obj.getSFM_ParseProcess(SourceToTargetChild.id,Quote.id,allobjmap,null);

            SFMDeliveryServiceImpl.setIsQueryOptimizerEnabled(true);
            obj.getSFM_ParseProcess(SourceToTargetChild.id,Quote.id,allobjmap,null);
        }
        catch(Exception ex)
        {
            system.debug('Exception: '+ex.getMessage());
        }
        Test.stopTest();
        
    }
    static testMethod void ForChecklist(){
    	SVMXC__QB_Response_Set__c objQBResposeSet = new SVMXC__QB_Response_Set__c();
		objQBResposeSet.Name = 'Test response set';
		objQBResposeSet.SVMXC__Response_Set_Values__c = 'value1;value2;';
		insert objQBResposeSet;
		
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QUE001';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        objQuestionBank.SVMXC__Response_Set__c = objQBResposeSet.id;
        insert objQuestionBank;
        
        SVMXC__Question_Bank__c objQuestionBank1 = new SVMXC__Question_Bank__c();
        objQuestionBank1.SVMXC__QuestionID__c = 'QUE002';
        objQuestionBank1.SVMXC__Question__c = 'Test Question2';
        objQuestionBank1.SVMXC__Response_Type__c = 'Text';
        insert objQuestionBank1;
        
        String targetManager;
        String processNodeObjects;
        
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        
        if(RTypeList.size() > 0){
            for(RecordType r : RTypeList){
                if(r.Name == 'Target Manager')
                    targetManager = r.id; 
                else if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
            }
        }
        
        //Create Header Page layout
        SVMXC__Page_Layout__c objHeaderLayout = new SVMXC__Page_Layout__c();
        objHeaderLayout.SVMXC__Object_Name__c = 'SVMXC__Checklist__c';
        objHeaderLayout.SVMXC__Type__c = 'Header';
        insert objHeaderLayout;
        System.assertEquals(true, objHeaderLayout != null);
        
        //Create Sections for header
        SVMXC__Page_Layout_Detail__c objSection1 = new SVMXC__Page_Layout_Detail__c();
        objSection1.SVMXC__Detail_Type__c = 'Section';
        objSection1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        objSection1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objSection1.SVMXC__Title__c = 'Checklist Section Title';
        objSection1.SVMXC__Sequence__c = 1;
        insert objSection1;
       
        //Create Fields for Header Layout
        List<SVMXC__Page_Layout_Detail__c> lstHeaderFields = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c objfld1 = new SVMXC__Page_Layout_Detail__c();
        objfld1.SVMXC__Detail_Type__c = 'Question';
        objfld1.SVMXC__Question__c = objQuestionBank.id;
        objfld1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld1.SVMXC__Section__c = objSection1.Id;
        objfld1.SVMXC__DataType__c = 'reference';
        objfld1.SVMXC__Sequence__c = 1;
        insert objfld1;
        
        SVMXC__Page_Layout_Detail__c objfld2 = new SVMXC__Page_Layout_Detail__c();
        objfld2.SVMXC__Detail_Type__c = 'Question';
        objfld2.SVMXC__Question__c = objQuestionBank1.id;
        objfld2.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld2.SVMXC__Section__c = objSection1.Id;
        objfld2.SVMXC__DataType__c = 'reference';
        objfld2.SVMXC__Sequence__c = 2;
        insert objfld2;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c ChecklistProcess = new SVMXC__ServiceMax_Processes__c();
        ChecklistProcess.SVMXC__Name__c = 'TESTPROCESS001';
        ChecklistProcess.RecordTypeId = targetManager;
        ChecklistProcess.SVMXC__Purpose__c = 'CHECKLIST';
        ChecklistProcess.SVMXC__ProcessID__c = 'TESTPROCESS001';
        ChecklistProcess.SVMXC__Page_Layout__c = objHeaderLayout.id;
        insert ChecklistProcess;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
        PNObject1.SVMXC__Process__c = ChecklistProcess.id;        
        PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'SOURCE';
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        PNObject2.SVMXC__Process__c = ChecklistProcess.id;
        listProcessNodeObjects.add(PNObject2);
        insert listProcessNodeObjects;
        
        SVMXC__Quote__c Quote = new SVMXC__Quote__c();
        Quote.SVMXC__Discount__c  = 10;
        Quote.SVMXC__Discount_Type__c = 'amount';
        Quote.SVMXC__Valid_Until__c = system.today() + 15;
        insert Quote;
        
        SVMXC__Service_Order__c objWO  = new SVMXC__Service_Order__c();
        insert objWO;
        
        SVMXC__Checklist__c objChecklist = new SVMXC__Checklist__c();
        objChecklist.SVMXC__ChecklistJSON__c = '{"test":"value"}';
        objChecklist.SVMXC__ChecklistMetaJSON__c = '{"test":"value"}';
        objChecklist.SVMXC__ChecklistProcessID__c = ChecklistProcess.id;
        objChecklist.SVMXC__Completed_By__c = Userinfo.getUserId();
        objChecklist.SVMXC__Completed_On__c = System.Today();
        objChecklist.SVMXC__Status__c = 'Completed';
        objChecklist.SVMXC__What_Id__c = String.ValueOf(objWO.id);
        insert objChecklist;
        
        Test.startTest();
        try{
            SVMXC.SFM_ParseProcess obj = new SVMXC.SFM_ParseProcess ();
            obj.getSFM_ParseProcess(ChecklistProcess.id,objWO.id,allobjmap,null);
            
            PNObject2.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
            update PNObject2;
            obj.getSFM_ParseProcess(ChecklistProcess.id,objWO.id,allobjmap,null);
        }
        catch(Exception ex){
            system.debug('Exception: '+ex.getMessage());
        }
        Test.stopTest();
    }
    
    
    
}