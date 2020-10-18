@isTest
private class INTF_SFMEngine_UT 
{
     static testMethod void INTF_SFMEngine_Test()
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
        PageHeader.SVMXC__Type__c = 'Detail';
        insert PageDetail;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SFMProcess.SVMXC__Name__c = 'CUSTOMPRO0001';
        SFMProcess.RecordTypeId = targetManager;
        SFMProcess.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL';
        SFMProcess.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        SFMProcess.SVMXC__Page_Layout__c = PageHeader.id;
        insert SFMProcess;
        
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
        
        
        //Creating object mapping for detail 
    	SVMXC__ServiceMax_Processes__c objMapDetail = new SVMXC__ServiceMax_Processes__c();
    	objMapDetail.SVMXC__MapID__c = 'OBJMAPDETAIL001';
    	objMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
    	objMapDetail.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
    	objMapDetail.RecordTypeId = objectMapping;
    	insert objMapDetail;
    	
    	//Creating field mapping reocrds for detail 
    	list<SVMXC__ServiceMax_Config_Data__c> lstFieldMapping = new list<SVMXC__ServiceMax_Config_Data__c>();
    	SVMXC__ServiceMax_Config_Data__c fldmap1 = new SVMXC__ServiceMax_Config_Data__c();
    	fldmap1.RecordTypeId = fieldMapping;
    	fldmap1.SVMXC__Source_Field_Name__c = 'SVMXC__Discount__c';
    	fldmap1.SVMXC__Target_Field_Name__c = 'SVMXC__Discount__c';
    	fldmap1.SVMXC__Configuration_Type__c = 'Field Mapping';
    	fldmap1.SVMXC__MapID__c = objMapDetail.id;
    	lstFieldMapping.add(fldmap1);
    	SVMXC__ServiceMax_Config_Data__c fldmap2 = new SVMXC__ServiceMax_Config_Data__c();
    	fldmap2.RecordTypeId = fieldMapping;
    	fldmap2.SVMXC__Source_Field_Name__c = 'SVMXC__Discount_Type__c';
    	fldmap2.SVMXC__Target_Field_Name__c = 'SVMXC__Discount_Type__c';
    	fldmap2.SVMXC__Configuration_Type__c = 'Field Mapping';
    	fldmap2.SVMXC__MapID__c = objMapDetail.id;
    	lstFieldMapping.add(fldmap2);
        
        
        //Creating object mapping for header 
    	SVMXC__ServiceMax_Processes__c objMapHeader = new SVMXC__ServiceMax_Processes__c();
    	objMapHeader.SVMXC__MapID__c = 'OBJMAPHEADER001';
    	objMapHeader.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
    	objMapHeader.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
    	objMapHeader.RecordTypeId = objectMapping;
    	insert objMapHeader;
    	
    	//Creating field mapping reocrds for header 
    	SVMXC__ServiceMax_Config_Data__c fldmap11 = new SVMXC__ServiceMax_Config_Data__c();
    	fldmap11.RecordTypeId = fieldMapping;
    	fldmap11.SVMXC__Source_Field_Name__c = 'SVMXC__Discount__c';
    	fldmap11.SVMXC__Target_Field_Name__c = 'SVMXC__Discount__c';
    	fldmap11.SVMXC__Configuration_Type__c = 'Field Mapping';
    	fldmap11.SVMXC__MapID__c = objMapHeader.id;
    	lstFieldMapping.add(fldmap11);
    	SVMXC__ServiceMax_Config_Data__c fldmap12 = new SVMXC__ServiceMax_Config_Data__c();
    	fldmap12.RecordTypeId = fieldMapping;
    	fldmap12.SVMXC__Source_Field_Name__c = 'SVMXC__Discount_Type__c';
    	fldmap12.SVMXC__Target_Field_Name__c = 'SVMXC__Discount_Type__c';
    	fldmap12.SVMXC__Configuration_Type__c = 'Field Mapping';
    	fldmap12.SVMXC__MapID__c = objMapHeader.id;
    	lstFieldMapping.add(fldmap12);
    	insert lstFieldMapping;
        
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
        PNObject1.SVMXC__Process__c = SFMProcess.id;
        PNObject1.SVMXC__Submodule__c = ExpressionRec.id;
        PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
        PNObject1.SVMXC__Module__c = objMapHeader.id;
        PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote__c';
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'TARGETCHILD';
        PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject2.SVMXC__Process__c = SFMProcess.id;
        PNObject2.SVMXC__Submodule__c = ExpressionRec.id;
        PNObject2.SVMXC__Module__c = objMapDetail.id;
        PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
        PNObject2.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote_Line__c';
        listProcessNodeObjects.add(PNObject2);
        
        SVMXC__ServiceMax_Processes__c PNObject3 = new SVMXC__ServiceMax_Processes__c();
        PNObject3.RecordTypeId = processNodeObjects;
        PNObject3.SVMXC__Type__c = 'SOURCE';
        PNObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject3.SVMXC__Process__c = SFMProcess.id;
        PNObject3.SVMXC__Final_Exception_Process__c = valMapHdr.id;
        listProcessNodeObjects.add(PNObject3);
        
        SVMXC__ServiceMax_Processes__c PNObject4 = new SVMXC__ServiceMax_Processes__c();
        PNObject4.RecordTypeId = processNodeObjects;
        PNObject4.SVMXC__Type__c = 'SOURCECHILD';
        PNObject4.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject4.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject4.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject4.SVMXC__Process__c = SFMProcess.id;
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
        //Now Create the INTF_Request and run the INTF_Tansactin Engine..
        SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
       
        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap1 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        strmap1.key = 'RECORDID';
        strmap1.value = Quote.id;
        lstStringMap.add(strmap1);
            
        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap2 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        strmap2.key = 'TDMID';
        strmap2.value = SFMProcess.id;
        lstStringMap.add(strmap2);
        
        request.StringMap = lstStringMap;
        SVMXC.INTF_SFMEngine RunEngine = new SVMXC.INTF_SFMEngine();
        response = RunEngine.SVMX_ExecuteEngine(request);
        
        
        //For Standalone Create...
        //Create PageHeader
        SVMXC__Page_Layout__c PageHeader1 = new SVMXC__Page_Layout__c();
        PageHeader1.SVMXC__Name__c = 'PAGE00001';
        PageHeader1.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        PageHeader1.SVMXC__Type__c = 'Header';
        insert PageHeader1;
        //Create PageDetail
        SVMXC__Page_Layout__c PageDetail1 = new SVMXC__Page_Layout__c();
        PageDetail1.SVMXC__Header_Page_Layout__c = PageHeader1.id;
        PageDetail1.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        PageDetail1.SVMXC__Type__c = 'Detail';
        insert PageDetail1;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c standaloneCreate = new SVMXC__ServiceMax_Processes__c();
        standaloneCreate.SVMXC__Name__c = 'CUSTOMPRO0001';
        standaloneCreate.RecordTypeId = targetManager;
        standaloneCreate.SVMXC__Purpose__c = 'STANDALONE CREATE';
        standaloneCreate.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        standaloneCreate.SVMXC__Page_Layout__c = PageHeader1.id;
        insert standaloneCreate;
        
        //Create Mapping For Header Record
        SVMXC__ServiceMax_Processes__c valMapHdr1 = new SVMXC__ServiceMax_Processes__c();
        valMapHdr1.SVMXC__MapID__c = 'VMAP000001';
        valMapHdr1.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
        valMapHdr1.RecordTypeId = objectMapping;
        insert valMapHdr1;
        //Create Mapping For Detail Record
        SVMXC__ServiceMax_Processes__c valMapDetail1 = new SVMXC__ServiceMax_Processes__c();
        valMapDetail1.SVMXC__MapID__c = 'VMAP000002';
        valMapDetail1.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
        valMapDetail1.RecordTypeId = objectMapping;
        insert valMapDetail1;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects1 = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c CrePNObject1 = new SVMXC__ServiceMax_Processes__c();
        CrePNObject1.RecordTypeId = processNodeObjects;
        CrePNObject1.SVMXC__Type__c = 'TARGET';
        CrePNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        CrePNObject1.SVMXC__Process__c = standaloneCreate.id;
        CrePNObject1.SVMXC__Final_Exception_Process__c = valMapHdr1.id;
        listProcessNodeObjects1.add(CrePNObject1);
        
        SVMXC__ServiceMax_Processes__c CrePNObject2 = new SVMXC__ServiceMax_Processes__c();
        CrePNObject2.RecordTypeId = processNodeObjects;
        CrePNObject2.SVMXC__Type__c = 'TARGETCHILD';
        CrePNObject2.SVMXC__Page_Layout__c = PageDetail1.id;
        CrePNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        CrePNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        CrePNObject2.SVMXC__Process__c = standaloneCreate.id;
        CrePNObject2.SVMXC__Final_Exception_Process__c = valMapDetail1.id;
        listProcessNodeObjects1.add(CrePNObject2);
        insert listProcessNodeObjects1;
        
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap1 = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap3 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        strmap3.key = 'TDMID';
        strmap3.value = standaloneCreate.id;
        lstStringMap.add(strmap3);
        
        SVMXC.INTF_WebServicesDef.INTF_Request request1 = new SVMXC.INTF_WebServicesDef.INTF_Request();
        request1.StringMap = lstStringMap1;
        RunEngine.SVMX_ExecuteEngine(request1);
     }
    
}