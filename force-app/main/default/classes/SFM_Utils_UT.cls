@isTest
private class SFM_Utils_UT{
  
  private static map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    private static map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    
    private SFM_Utils_UT()
    {
        gd = COMM_Utils_DescribeCall.getInstance().getGlobalDescribeCall();
        for(Schema.SObjectType s : gd.values())
        {
            Schema.DescribeSObjectResult result = s.getDescribe();
            allobjmap.put(result.getName(),s);
        } 
    }  
    
    static testMethod void SFM_Utils_test1()
     {
        SFM_Utils utils = new SFM_Utils();
         Account lstAccObj = new Account();
        lstAccObj.Name = 'ABC Inc1';
        insert lstAccObj;
        set<String> accIds = new set<String>();
        accIds.add(lstAccObj.Id);
        utils.GetRelationshipData(accIds, 'Account', 'ID');
     }
    static testMethod void SFM_Utils_test(){
        //*****Variable declaration and data creation*****
        
        SVMXC__ServiceMax_Property_Elements__c prop_Elements = new SVMXC__ServiceMax_Property_Elements__c();
        prop_Elements.Name = 'Test';
        prop_Elements.SVMXC__Property_Key__c = 'STRING';
        prop_Elements.SVMXC__Element_Type__c='Search Object';
        prop_Elements.SVMXC__Element_Value__c='Event';
        insert prop_Elements;
        System.assertEquals(true, prop_Elements != null);
        
        SFM_WrapperDef.SFM_StringMap stringMap = new SFM_WrapperDef.SFM_StringMap('ACTIVATE','true');
        List<SFM_WrapperDef.SFM_StringMap> list_stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        list_stringMap.add(stringMap);
        String strng = 'object~recordType';
        
        List<String> list_string = new List<String>();
        System.assertEquals(true, list_string != null);
        
        list_string.add(strng);
        List<String> empty_lst = new List<String>();
        String empty_string;
        String isCreateable = 'isCreateable';
        String isUpdateable = 'isUpdateable';
        String isAccessible = 'isAccessible';
        String isCustom = 'isCustom';
        String isFilterable = 'isFilterable';
        
        //*****DescribeFieldResult*****
        Schema.DescribeFieldResult acc = Account.Industry.getDescribe();
        Schema.Displaytype disType = acc.getType();
        
        SVMXC__Service_Group__c serv_grp = new SVMXC__Service_Group__c();
        Schema.DescribeFieldResult picklst = Case.Priority.getDescribe();
        Schema.DescribeFieldResult boole = Case.IsEscalated.getDescribe();
        Schema.DescribeFieldResult dte = Case.SVMXC__BW_Date__c.getDescribe();
        Schema.DescribeFieldResult dteTime = Contact.LastCURequestDate.getDescribe();
        Schema.DescribeFieldResult inte = Case.CaseNumber.getDescribe();
        Schema.DescribeFieldResult textArea = SVMXC__Site__c.SVMXC__Street__c.getDescribe();
        Schema.DescribeFieldResult phon = SVMXC__Site__c.SVMXC__Site_Phone__c.getDescribe();
        Schema.DescribeFieldResult curr = Product2.SVMXC__Product_Cost__c.getDescribe();
        Schema.DescribeFieldResult text = SVMXC__Site__c.SVMXC__Inventory_Account__c.getDescribe();
        Schema.DescribeFieldResult url = Contact.Email.getDescribe();
        Schema.DescribeFieldResult email = Contact.Email.getDescribe();
        
        set<string> mySetString = new Set<String>{'SVMXC__Service_Group__c'};
        
        
        System.debug('*****'+dteTime.getType());
        
        //*****Creating Map for getting Map<String, Schema.SObjectType>*****
        
        Map<String, Schema.SObjectType> mapStrSchema = new Map<String, Schema.SObjectType>();
        mapStrSchema.put('SVMXC__Installed_Product__c',SVMXC__Installed_Product__c.getSobjectType());
        
        //*****Instance of class*****
        
        SFM_Utils utils = new SFM_Utils();
        
        //Calling various methods 
        
        utils.makeFieldProperty('SVMXC__Preferred_Technician__c','Preferred Technician',disType,'Technician/Equipment','Account',true,true,true);
        utils.makeFieldProperty('SVMXC__Preferred_Technician__c','Preferred Technician',disType,'Technician/Equipment','Account',false,false,false);
        
        utils.getRestrictedListMap('string');
        
        set<String> blackList = utils.getBlackList('string');
        
        utils.getAvailableValues(picklst);
        utils.getAvailableValues(boole);
        utils.getAvailableValues(dte);
        utils.getAvailableValues(dteTime);
        System.debug('*****utils'+utils.getAvailableValues(dteTime));
        
        utils.getStringMap(list_stringMap);
        
        utils.WhiteList();
        System.assertEquals(true, utils.WhiteList() != null);
        
        utils.checksize(6,7);
        utils.checksize(8,7);
        System.assertEquals(true, utils.checksize(6,7) != null);
        System.assertEquals(true, utils.checksize(8,7) != null);
        
        utils.getRecordTypes(list_string);
        
        utils.checkFieldAccessPermission(picklst,empty_lst);
        utils.checkFieldAccessPermission(picklst,list_string);
        utils.checkFieldAccessPermission(picklst,empty_string);
        utils.checkFieldAccessPermission(picklst,isCreateable);
        utils.checkFieldAccessPermission(picklst,isUpdateable);
        utils.checkFieldAccessPermission(picklst,isAccessible);
        utils.checkFieldAccessPermission(picklst,isCustom);
        utils.checkFieldAccessPermission(picklst,isFilterable);
        
        utils.checkAllowedProperties(picklst,picklst);
        utils.checkAllowedProperties(dte,dteTime);
        utils.checkAllowedProperties(inte,curr);
        utils.checkAllowedProperties(curr,inte);
        utils.checkAllowedProperties(picklst,phon);
        
        utils.checkAllowedProperties(text,picklst);
        utils.checkAllowedProperties(text,phon);
        utils.checkAllowedProperties(text,url);
        utils.checkAllowedProperties(text,email);
        
        utils.checkAllowedProperties(textArea,text);
        utils.checkAllowedProperties(textArea,picklst);
        utils.checkAllowedProperties(textArea,url);
        utils.checkAllowedProperties(textArea,phon);
        utils.checkAllowedProperties(textArea,email);
        
        utils.checkAllowedProperties(phon,text);
        utils.checkAllowedProperties(email,text);
        System.assertEquals(true, utils.checkAllowedProperties(phon,text) != null);
        System.assertEquals(true, utils.checkAllowedProperties(email,text) != null);
        
        utils.checkAllowedProperties(url,text);
        utils.checkAllowedProperties(url,email);
        System.assertEquals(true, utils.checkAllowedProperties(url,text) != null);
        System.assertEquals(true, utils.checkAllowedProperties(url,email) != null);
        
        Schema.DisplayType targetType = picklst.getType();
        System.debug('*****targetType'+targetType);
        
        utils.getOriginalAPIName('SVMXC__Installed_Product__c',mapStrSchema);
        utils.getOriginalAPIName(mySetString,mapStrSchema);
        utils.getOriginalAPIName('Object',mapStrSchema);

        utils.getAllowedFields('SVMXC__Installed_Product__c',list_string,mySetString,mySetString,mapStrSchema);
        String objectName = 'SVMXC__Installed_Product__c';
        //utils.checkReferenceValidation(picklst,mySetString,mySetString);
        
        Schema.DescribeSObjectResult givenObject = (mapStrSchema.get(objectName)).getDescribe();
        //String fieldAPI = picklst.getReferenceTo()[0].getDescribe().getName();
        //System.debug('*****Fieldname'+fieldAPI);
    
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        allObjs = COMM_Utils_DescribeCall.getInstance().getGlobalDescribeCall();
        Schema.SObjectType selectedObject;
        
        if(allObjs.get('SVMXCX1__Service_Order__c') != NULL)
            selectedObject = allObjs.get('SVMXCX1__Service_Order__c');
        else
            selectedObject = allObjs.get('SVMXC__Service_Order__c');
        Map<String,Schema.SObjectField> fieldMapping = selectedObject.getDescribe().fields.getMap();
        system.debug('TEST LOGww' + fieldMapping);
        for(Schema.SObjectField fieldMap: fieldMapping.values()){
            Schema.DescribeFieldResult field = fieldMap.getDescribe();
            if(field.getReferenceTo()!=NULL && field.getReferenceTo().size()>0)
            {
            utils.checkReferenceValidation(field, blackList, blackList);
            break;
            }
        }
        utils.makeFieldProperty('fieldAPI', 'fieldLabel',Schema.DisplayType.Reference,'fieldRelatedTo', 'fieldRelationshipname', true, true, true);
        
        Account lstAccObj = new Account();
        lstAccObj.Name = 'ABC Inc';
        insert lstAccObj;
        set<String> accIds = new set<String>();
        accIds.add(lstAccObj.Id);
        utils.GetRelationshipData(accIds, 'Account', 'Name');
        
        utils.getBubbleinfo('DefaultValue','LookupConfigId','RelatedObjName');
        
        Map<String, String> setObject = new Map<String, String>();
        setObject.put('Account', 'Name');
        utils.getReferenceLabels(setObject, accIds);
        //Data Create for the Utils methods
        Product2 pro = new Product2();
        pro.Name = 'Servicemax';
        insert pro; 
        //----------------------Creating List of StringMap for Header Target Record---------------------------
        List<SFM_WrapperDef.SFM_StringMap> ListOfStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap Stringmapcls1 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Discount__c','20');
        SFM_WrapperDef.SFM_StringMap Stringmapcls2 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Discount_Type__c','Amount');
        SFM_WrapperDef.SFM_StringMap Stringmapcls3 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Total_Line_Price2__c','1000');
        SFM_WrapperDef.SFM_StringMap Stringmapcls4 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Quote_Amount2__c','1000');
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        ListOfStringMap.add(Stringmapcls4);
        
        //----------------------Creating List of StringMap for Detail Target Record(For Update)----------------------------
        List<SFM_WrapperDef.SFM_StringMap> ListOfStringMap1 = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap Stringmapcls5 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Discount_Type__c','Amount');
        SFM_WrapperDef.SFM_StringMap Stringmapcls6 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Discount__c','10');
        SFM_WrapperDef.SFM_StringMap Stringmapcls7 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Quantity2__c','10');
        SFM_WrapperDef.SFM_StringMap Stringmapcls8 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Unit_Price2__c','101');
        SFM_WrapperDef.SFM_StringMap Stringmapcls9 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Product__c',String.valueof(pro.id));
        ListOfStringMap1.add(Stringmapcls5);
        ListOfStringMap1.add(Stringmapcls6);
        ListOfStringMap1.add(Stringmapcls7);
        ListOfStringMap1.add(Stringmapcls8);
        ListOfStringMap1.add(Stringmapcls9);
        
        /*List<SFM_WrapperDef.SFM_StringMap> ListOfStringMap2 = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap Stringmapcls8 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Quote__c',String.valueof(WOrder.Id));
        SFM_WrapperDef.SFM_StringMap Stringmapcls9 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Activity_Type__c','Installation');
        SFM_WrapperDef.SFM_StringMap Stringmapcls10 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Cost_Category__c','Straight');
        ListOfStringMap2.add(Stringmapcls8);
        ListOfStringMap2.add(Stringmapcls9);
        ListOfStringMap2.add(Stringmapcls10);*/
        
        
        
        //-----------------------------Creating List of SFM_Record for Header TargetRecObj----------------------------
        List<SFM_WrapperDef.SFM_Record> SfmRecList1 = new List<SFM_WrapperDef.SFM_Record>();
        SFM_WrapperDef.SFM_Record SfmRec1 = new SFM_WrapperDef.SFM_Record();
        SfmRec1.targetRecordAsKeyValue = ListOfStringMap;
        SfmRecList1.add(SfmRec1);
        
        //-------------------------Creating List of SFM_Record for DtlTargetRecordObject(for update)-------------------------
        List<SFM_WrapperDef.SFM_Record> SfmRecList2 = new List<SFM_WrapperDef.SFM_Record>();
        SFM_WrapperDef.SFM_Record SfmRec2 = new SFM_WrapperDef.SFM_Record();
        SfmRec2.sourceRecordId = '';
        SfmRec2.targetRecordAsKeyValue = ListOfStringMap1;
        SfmRecList2.add(SfmRec2);
        
        /*//-------------------------Creating List of SFM_Record for DtlTargetRecordObject(for insert)-------------------------
        SFM_WrapperDef.SFM_Record SfmRec3 = new SFM_WrapperDef.SFM_Record();
        SfmRec3.sourceRecordId = '';
        SfmRec3.targetRecordAsKeyValue = ListOfStringMap2;
        SfmRecList2.add(SfmRec3);*/
        
        //-------------------------------Creating Header Target Record Object-------------------------------------
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject TargetRecObj = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        TargetRecObj.objName = 'SVMXC__Quote__c';
        TargetRecObj.records =  SfmRecList1;
        
        //---------------------------Creating List of Detail Target Record-------------------------------------
        List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject TargetRecObj1 = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        TargetRecObj1.objName = 'SVMXC__Quote_Line__c';
        TargetRecObj1.aliasName = 'WorkDetailLine';
        TargetRecObj1.parentColumnName = 'SVMXC__Quote__c';
        TargetRecObj1.records =  SfmRecList2;
        DtlTargetRecordObject.add(TargetRecObj1);
        
        
        //---------------------------------Creating Target Record Object---------------------------------------
        SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        sfmtargetrec.headerRecord = TargetRecObj;
        sfmtargetrec.detailRecords = DtlTargetRecordObject;
        
        Sobject headerSobject = utils.SFM_Page_GetHeaderRecord(sfmtargetrec, allobjmap);
        map<String,list<Sobject>> detailRecordMap = utils.SFM_Page_GetDetailRecords(sfmtargetrec, allobjmap);
        utils.SFM_Page_BuildResponse(sfmtargetrec, headerSobject, detailRecordMap);
    }
    
    static testMethod void coverBuildSFMTargetRecord()
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
            SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
            map<String,map<String,Sobject>> mapAliasNameMapSourceRecordIdTargetRecord = new map<String,map<String,Sobject>>();
            //For Header Record
            map<String,Sobject> mapSorceRecordIdTargetRecordForHeader = new map<String,Sobject> ();
            mapSorceRecordIdTargetRecordForHeader.put(Quote.id,new SVMXC__Quote__c());
            //For Line
            map<String,Sobject> mapSorceRecordIdTargetRecordForLine = new map<String,Sobject> ();
            mapSorceRecordIdTargetRecordForLine.put(QLine.id,new SVMXC__Quote_Line__c());
            //Add in main map
            mapAliasNameMapSourceRecordIdTargetRecord.put('SVMXC__Quote__c',mapSorceRecordIdTargetRecordForHeader);
            mapAliasNameMapSourceRecordIdTargetRecord.put(String.valueof(PageDetail.id).substring(0,15),mapSorceRecordIdTargetRecordForLine);
            utils.buildSFMTargetRecord(SourceToTargetAll.id,mapAliasNameMapSourceRecordIdTargetRecord);
            
            mapSorceRecordIdTargetRecordForHeader.get(Quote.id).put('NOSOURCEID',new SVMXC__Quote__c());
            mapAliasNameMapSourceRecordIdTargetRecord.put('SVMXC__Quote__c',mapSorceRecordIdTargetRecordForHeader);
            utils.buildSFMTargetRecord(SourceToTargetAll.id,mapAliasNameMapSourceRecordIdTargetRecord);
        }
        catch(Exception ex)
        {
            system.debug('Exception: '+ex.getMessage());
        }
        Test.stopTest();
    }
    static testMethod void coverBuildSFMTargetRecord1()
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
        
        list<SVMXC__Quote__c> lstQuote = new list<SVMXC__Quote__c>();
        list<SVMXC__Quote_Line__c> lstQLine = new list<SVMXC__Quote_Line__c>();
        
        SVMXC__Quote__c Quote = new SVMXC__Quote__c();
        Quote.SVMXC__Discount__c  = 10;
        Quote.SVMXC__Discount_Type__c = 'amount';
        Quote.SVMXC__Valid_Until__c = system.today() + 15;
        insert Quote;
        lstQuote.add(Quote);
        SVMXC__Quote_Line__c QLine = new SVMXC__Quote_Line__c();
        QLine.SVMXC__Quote__c = Quote.id;
        QLine.SVMXC__Discount__c  = 10;
        QLine.SVMXC__Discount_Type__c = 'amount';
        insert QLine;
        lstQLine.add(QLine);
        SVMXC__Quote_Line__c QLine1 = new SVMXC__Quote_Line__c();
        QLine1.SVMXC__Quote__c = Quote.id;
        QLine1.SVMXC__Discount__c  = 10;
        QLine1.SVMXC__Discount_Type__c = 'amount';
        insert QLine1;
        lstQLine.add(QLine1);
        
        Test.startTest();
        try
        {
            SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
            map<String,list<Sobject>> mapAliasNameTargetRecord = new map<String,list<Sobject>>();
            
            //For Header Record
            mapAliasNameTargetRecord.put('SVMXC__Quote__c',lstQuote);
            //For Line recrod
            mapAliasNameTargetRecord.put(String.valueof(PageDetail.id).substring(0,15),lstQLine);
            
            utils.buildSFMTargetRecord1(SourceToTargetAll.id,mapAliasNameTargetRecord);
        }
        catch(Exception ex)
        {
            system.debug('Exception: '+ex.getMessage());
        }
        Test.stopTest();
    }
}