@isTest
private class SFM_GetLookUpConfigWithData_UT
{
    static testMethod void SFM_getLookUpConfigWithDataUnitTest()
    {
        /*...........Data Creation...........*/
        //------------------------------------------Creating Record Type-----------------------------------------
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        String rid;
        
        SFM_Utils utils = new SFM_Utils();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
        Map<String, Id> mapRecType_Map = new Map<String, Id>();
        mapRecType_Map = utils.getRecordTypes(recTypeNames);
        
        SVMXC__ServiceMax_Processes__c namedSearchHdr;
        System.assertEquals(true, rts != null);
        for(RecordType rt:rts)
        {
            if(rt.name == 'Named Search')
                {
                  namedSearchHdr=new SVMXC__ServiceMax_Processes__c(RecordTypeId=rt.Id,SVMXC__Name__c='TestLookUpConfig',SVMXC__Description__c='TestLookUpConfig',SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c',SVMXC__IsStandard__c=true,SVMXC__Rule_Type__c='LOOKUPCONFIG',SVMXC__ProcessID__c='PROCESS11',SVMXC__SettingId__c = 'PROCESS11',SVMXC__MapID__c='PROCESS11');
                  rid=rt.Id;
                }
        }
        insert namedSearchHdr;
        System.assertEquals(true, namedSearchHdr != null);
        
        Account acc1 = new Account(Name= 'Test account');
        insert acc1;
        
        SVMXC__Service_Order__c namedSearchHdr1 = new SVMXC__Service_Order__c(SVMXC__Company__c = acc1.Id,SVMXC__Order_Status__c='Open', SVMXC__Order_Type__c = 'Depot Repair', SVMXC__Priority__c = 'High');
        insert namedSearchHdr1;
        System.assertEquals(true, namedSearchHdr1 != null);
        
        //------------------------------------Creating Process Object---------------------------------
        SVMXC__ServiceMax_Processes__c objectDetails = new SVMXC__ServiceMax_Processes__c();
        objectDetails.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objectDetails.SVMXC__ProcessID__c='PROCESS11';
        objectDetails.SVMXC__SettingId__c = 'PROCESS11';
        objectDetails.SVMXC__MapID__c='PROCESS11';
        objectDetails.SVMXC__Name__c = 'PROCESS22';
        objectDetails.SVMXC__Module__c = namedSearchHdr.Id;
        objectDetails.RecordTypeId=rid;
        objectDetails.SVMXC__Rule_Type__c='SRCH_OBJECT';
        objectDetails.SVMXC__Process__c = namedSearchHdr.Id;
        upsert objectDetails;
        System.assertEquals(true, objectDetails != null);
        
        //-----------------------------------------Creating List of Config Data------------------------------------------------
        List<SVMXC__ServiceMax_Config_Data__c> fields = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Config_Data__c obj7=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=1,SVMXC__Search_Object_Field_Type__c='Result',SVMXC__Field_Name__c='SVMXC__Priority__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'));
        
        SVMXC__ServiceMax_Config_Data__c obj8=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=2,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__Order_Type__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'));
        
        //SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=4,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__How_Fixed__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        
        SVMXC__ServiceMax_Config_Data__c obj9=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=3,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c='PICKLIST',SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions')); 
        
        SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=4,SVMXC__Search_Object_Field_Type__c='Result',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c=NULL,SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'));
       
       SVMXC__ServiceMax_Config_Data__c obj11=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=5,SVMXC__Search_Object_Field_Type__c='Result',SVMXC__Field_Name__c='SVMXC__Company__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c='REFERENCE',SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'), SVMXC__Field_Relationship_Name__c = 'SVMXC__Company__r', SVMXC__FKey_Name_Field__c = 'Name', SVMXC__Object_Name__c='Account');
       
       SVMXC__ServiceMax_Config_Data__c obj12=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=6,SVMXC__Search_Object_Field_Type__c='BUBBLE',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c=NULL,SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'));
       
       SVMXC__ServiceMax_Config_Data__c obj13=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=7,SVMXC__Search_Object_Field_Type__c='BUBBLE',SVMXC__Field_Name__c='SVMXC__Company__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c='REFERENCE',SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'),SVMXC__Field_Relationship_Name__c = 'SVMXC__Company__r', SVMXC__FKey_Name_Field__c = 'Name', SVMXC__Object_Name__c='Account'); 
      
        
        fields.add(obj10);
        fields.add(obj11);
        fields.add(obj13);
        fields.add(obj7);
        fields.add(obj8);
        fields.add(obj9);
        fields.add(obj12);
        
        upsert fields;
        
        System.assertEquals(true, fields != null);
        
        //-----------------------------------------Creating Object of NamedSearchInfoDetails------------------------------------
        List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail> namedSearchDetails = new List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        SFM_WrapperDef.SFM_NamedSearchInfoDetail processNodeSourceObject1 = new SFM_WrapperDef.SFM_NamedSearchInfoDetail(objectDetails,fields);
        namedSearchDetails.add(processNodeSourceObject1);
        
        //----------------------------------------Creating NameSearch Info-----------------------------------
        List<SFM_WrapperDef.SFM_NamedSearchInfo> NSI1=new List<SFM_WrapperDef.SFM_NamedSearchInfo>();
        SFM_WrapperDef.SFM_NamedSearchInfo oSFM_Exp1=new SFM_WrapperDef.SFM_NamedSearchInfo(namedSearchHdr,namedSearchDetails);
        NSI1.add(oSFM_Exp1);
        
        //-----------------------------------------Creating List of String Map-----------------------------------------------
        List<SFM_WrapperDef.SFM_StringMap> ListOfStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap Stringmapcls1 = new SFM_WrapperDef.SFM_StringMap('RECORDID',namedSearchHdr.Id);
        SFM_WrapperDef.SFM_StringMap Stringmapcls2 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__Service_Order__c');
        SFM_WrapperDef.SFM_StringMap Stringmapcls3 = new SFM_WrapperDef.SFM_StringMap('KEYWORD','WO');
        SFM_WrapperDef.SFM_StringMap Stringmapcls4 = new SFM_WrapperDef.SFM_StringMap('DEFAULTCOLUMN','Name');
        SFM_WrapperDef.SFM_StringMap Stringmapcls5 = new SFM_WrapperDef.SFM_StringMap('NOOFRECORDS','20');
        //SFM_WrapperDef.SFM_StringMap Stringmapcls6 = new SFM_WrapperDef.SFM_StringMap('CONTEXTVALUE',null); 
        SFM_WrapperDef.SFM_StringMap Stringmapcls7 = new SFM_WrapperDef.SFM_StringMap('FIELDNAME',null);
        SFM_WrapperDef.SFM_StringMap Stringmapcls8 = new SFM_WrapperDef.SFM_StringMap('INFOTYPE','Bubble'); 
        SFM_WrapperDef.SFM_StringMap Stringmapcls9 = new SFM_WrapperDef.SFM_StringMap('SEARCHRECORD',namedSearchHdr1.Id);
        SFM_WrapperDef.SFM_StringMap Stringmapcls10 = new SFM_WrapperDef.SFM_StringMap('RELATEDOBJECTNAME','');
        SFM_WrapperDef.SFM_StringMap Stringmapcls11 = new SFM_WrapperDef.SFM_StringMap('CONTEXTVALUE','Rep');
        SFM_WrapperDef.SFM_StringMap Stringmapcls12 = new SFM_WrapperDef.SFM_StringMap('SEARCHOPERATOR','contains');
        SFM_WrapperDef.SFM_StringMap Stringmapcls13 = new SFM_WrapperDef.SFM_StringMap('SEARCHOPERATOR','sw');
        SFM_WrapperDef.SFM_StringMap Stringmapcls14 = new SFM_WrapperDef.SFM_StringMap('SEARCHOPERATOR','ew');
        
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        ListOfStringMap.add(Stringmapcls4);
        ListOfStringMap.add(Stringmapcls5);
       /*  ListOfStringMap.add(Stringmapcls6); */
        ListOfStringMap.add(Stringmapcls7);
        ListOfStringMap.add(Stringmapcls8);
        ListOfStringMap.add(Stringmapcls9);
        ListOfStringMap.add(Stringmapcls10);
        ListOfStringMap.add(Stringmapcls11);
        
        ListOfStringMap.add(Stringmapcls12);
        ListOfStringMap.add(Stringmapcls13);
        ListOfStringMap.add(Stringmapcls14);
        
        /*...........Class Instance...........*/        
        SFM_getLookUpConfigWithData lookUpConfig = new SFM_getLookUpConfigWithData();
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        request.setstringMap(ListOfStringMap);
        
        /*...........Method Call...........*/
        lookUpConfig.getLookUpConfigWithData(request);
        
        
        /*Insert null values*/

        SFM_WrapperDef.SFM_StringMap Stringmapcls16 = new SFM_WrapperDef.SFM_StringMap('KEYWORD',null);
        SFM_WrapperDef.SFM_StringMap Stringmapcls17 = new SFM_WrapperDef.SFM_StringMap('DEFAULTCOLUMN',null);
        SFM_WrapperDef.SFM_StringMap Stringmapcls18 = new SFM_WrapperDef.SFM_StringMap('INFOTYPE',null); 
        SFM_WrapperDef.SFM_StringMap Stringmapcls19 = new SFM_WrapperDef.SFM_StringMap('CONTEXTVALUE',null); 
        SFM_WrapperDef.SFM_StringMap Stringmapcls20 = new SFM_WrapperDef.SFM_StringMap('SEARCHOPERATOR','eq');
        //SFM_WrapperDef.SFM_StringMap Stringmapcls21 = new SFM_WrapperDef.SFM_StringMap('NOOFRECORDS',null);
        
        
        ListOfStringMap.add(Stringmapcls16);
        ListOfStringMap.add(Stringmapcls17);
        ListOfStringMap.add(Stringmapcls18);
        ListOfStringMap.add(Stringmapcls19);
        ListOfStringMap.add(Stringmapcls20);
        //ListOfStringMap.add(Stringmapcls21);
    
        request.setstringMap(ListOfStringMap);
        lookUpConfig.getLookUpConfigWithData(request);
        
        SFM_WrapperDef.SFM_StringMap Stringmapcls22 = new SFM_WrapperDef.SFM_StringMap('KEYWORD','WO');
        SFM_WrapperDef.SFM_StringMap Stringmapcls23 = new SFM_WrapperDef.SFM_StringMap('INFOTYPE',null); 
        SFM_WrapperDef.SFM_StringMap Stringmapcls24 = new SFM_WrapperDef.SFM_StringMap('SEARCHOPERATOR','contains');
        SFM_WrapperDef.SFM_StringMap Stringmapcls25 = new SFM_WrapperDef.SFM_StringMap('CONTEXTVALUE','Rep');
        ListOfStringMap.add(Stringmapcls22);
        ListOfStringMap.add(Stringmapcls23);
        ListOfStringMap.add(Stringmapcls24);
        ListOfStringMap.add(Stringmapcls25);
        request.setstringMap(ListOfStringMap);
        lookUpConfig.getLookUpConfigWithData(request);
        
        
        SFM_WrapperDef.SFM_StringMap Stringmapcls31 = new SFM_WrapperDef.SFM_StringMap('KEYWORD','WO');
        SFM_WrapperDef.SFM_StringMap Stringmapcls32 = new SFM_WrapperDef.SFM_StringMap('INFOTYPE',null); 
        SFM_WrapperDef.SFM_StringMap Stringmapcls33 = new SFM_WrapperDef.SFM_StringMap('SEARCHOPERATOR','sw');
        SFM_WrapperDef.SFM_StringMap Stringmapcls34 = new SFM_WrapperDef.SFM_StringMap('CONTEXTVALUE',null);
        ListOfStringMap.add(Stringmapcls31);
        ListOfStringMap.add(Stringmapcls32);
        ListOfStringMap.add(Stringmapcls33);
        ListOfStringMap.add(Stringmapcls34);
        request.setstringMap(ListOfStringMap);
        lookUpConfig.getLookUpConfigWithData(request);
        
        SFM_WrapperDef.SFM_StringMap Stringmapcls41 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Order__c');
        SFM_WrapperDef.SFM_StringMap Stringmapcls42 = new SFM_WrapperDef.SFM_StringMap('INFOTYPE','Bubble'); 
        ListOfStringMap.add(Stringmapcls41);
        ListOfStringMap.add(Stringmapcls42);
        request.setstringMap(ListOfStringMap);
        lookUpConfig.getLookUpConfigWithData(request);
        
        SFM_WrapperDef.SFM_StringMap Stringmapcls43 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Order__c');
        SFM_WrapperDef.SFM_StringMap Stringmapcls44 = new SFM_WrapperDef.SFM_StringMap('INFOTYPE','Result'); 
        ListOfStringMap.add(Stringmapcls43);
        ListOfStringMap.add(Stringmapcls44);
        request.setstringMap(ListOfStringMap);
        lookUpConfig.getLookUpConfigWithData(request);
        
    }
static testMethod void SFM_getLookUpConfigWithDataUnitTest2()
    {
        /*...........Data Creation...........*/
        //------------------------------------------Creating Record Type-----------------------------------------
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        String rid;
        
        SFM_Utils utils = new SFM_Utils();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
        Map<String, Id> mapRecType_Map = new Map<String, Id>();
        mapRecType_Map = utils.getRecordTypes(recTypeNames);
        
        SVMXC__ServiceMax_Processes__c namedSearchHdr;
        System.assertEquals(true, rts != null);
        for(RecordType rt:rts)
        {
            if(rt.name == 'Named Search')
                {
                  namedSearchHdr=new SVMXC__ServiceMax_Processes__c(RecordTypeId=rt.Id,SVMXC__Name__c='TestLookUpConfig',SVMXC__Description__c='TestLookUpConfig',SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c',SVMXC__IsStandard__c=true,SVMXC__Rule_Type__c='LOOKUPCONFIG',SVMXC__ProcessID__c='PROCESS11',SVMXC__SettingId__c = 'PROCESS11',SVMXC__MapID__c='PROCESS11');
                  rid=rt.Id;
                }
        }
        insert namedSearchHdr;
        System.assertEquals(true, namedSearchHdr != null);
        
        Account acc1 = new Account(Name= 'Test account');
        insert acc1;
        
        SVMXC__Service_Order__c namedSearchHdr1 = new SVMXC__Service_Order__c(SVMXC__Company__c = acc1.Id,SVMXC__Order_Status__c='Open', SVMXC__Order_Type__c = 'Depot Repair', SVMXC__Priority__c = 'High');
        insert namedSearchHdr1;
        System.assertEquals(true, namedSearchHdr1 != null);
        
        //------------------------------------Creating Process Object---------------------------------
        SVMXC__ServiceMax_Processes__c objectDetails = new SVMXC__ServiceMax_Processes__c();
        objectDetails.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objectDetails.SVMXC__ProcessID__c='PROCESS11';
        objectDetails.SVMXC__SettingId__c = 'PROCESS11';
        objectDetails.SVMXC__MapID__c='PROCESS11';
        objectDetails.SVMXC__Name__c = 'PROCESS22';
        objectDetails.SVMXC__Module__c = namedSearchHdr.Id;
        objectDetails.RecordTypeId=rid;
        objectDetails.SVMXC__Rule_Type__c='SRCH_OBJECT';
        objectDetails.SVMXC__Process__c = namedSearchHdr.Id;
        upsert objectDetails;
        System.assertEquals(true, objectDetails != null);
        
        //-----------------------------------------Creating List of Config Data------------------------------------------------
        List<SVMXC__ServiceMax_Config_Data__c> fields = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c obj7=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=1,SVMXC__Search_Object_Field_Type__c='Result',SVMXC__Field_Name__c='SVMXC__Priority__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'));
        
        SVMXC__ServiceMax_Config_Data__c obj8=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=2,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__Order_Type__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'));
        
        //SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=4,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__How_Fixed__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        
        SVMXC__ServiceMax_Config_Data__c obj9=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=3,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c='PICKLIST',SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'));
        
        SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=4,SVMXC__Search_Object_Field_Type__c='Result',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c=NULL,SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'));
        
        SVMXC__ServiceMax_Config_Data__c obj11=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=5,SVMXC__Search_Object_Field_Type__c='Result',SVMXC__Field_Name__c='SVMXC__Company__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c='REFERENCE',SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'), SVMXC__Field_Relationship_Name__c = 'SVMXC__Company__r', SVMXC__FKey_Name_Field__c = 'Name', SVMXC__Object_Name__c='Account');
        
        SVMXC__ServiceMax_Config_Data__c obj12=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=6,SVMXC__Search_Object_Field_Type__c='BUBBLE',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c='hh',SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'));
        
        fields.add(obj12); 
        fields.add(obj10);
        fields.add(obj7);
        fields.add(obj8);
        fields.add(obj9);
        upsert fields;
        
        System.assertEquals(true, fields != null);
        
        //-----------------------------------------Creating Object of NamedSearchInfoDetails------------------------------------
        List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail> namedSearchDetails = new List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        SFM_WrapperDef.SFM_NamedSearchInfoDetail processNodeSourceObject1 = new SFM_WrapperDef.SFM_NamedSearchInfoDetail(objectDetails,fields);
        namedSearchDetails.add(processNodeSourceObject1);
        
        //----------------------------------------Creating NameSearch Info-----------------------------------
        List<SFM_WrapperDef.SFM_NamedSearchInfo> NSI1=new List<SFM_WrapperDef.SFM_NamedSearchInfo>();
        SFM_WrapperDef.SFM_NamedSearchInfo oSFM_Exp1=new SFM_WrapperDef.SFM_NamedSearchInfo(namedSearchHdr,namedSearchDetails);
        NSI1.add(oSFM_Exp1);
        
        //-----------------------------------------Creating List of String Map-----------------------------------------------
        List<SFM_WrapperDef.SFM_StringMap> ListOfStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap Stringmapcls1 = new SFM_WrapperDef.SFM_StringMap('RECORDID',namedSearchHdr.Id);
        SFM_WrapperDef.SFM_StringMap Stringmapcls2 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__Service_Order__c');
        SFM_WrapperDef.SFM_StringMap Stringmapcls3 = new SFM_WrapperDef.SFM_StringMap('KEYWORD',null);
        SFM_WrapperDef.SFM_StringMap Stringmapcls4 = new SFM_WrapperDef.SFM_StringMap('DEFAULTCOLUMN',null);
        SFM_WrapperDef.SFM_StringMap Stringmapcls5 = new SFM_WrapperDef.SFM_StringMap('NOOFRECORDS',null);
        SFM_WrapperDef.SFM_StringMap Stringmapcls6 = new SFM_WrapperDef.SFM_StringMap('CONTEXTVALUE',null); 
        SFM_WrapperDef.SFM_StringMap Stringmapcls7 = new SFM_WrapperDef.SFM_StringMap('FIELDNAME',null);
        SFM_WrapperDef.SFM_StringMap Stringmapcls8 = new SFM_WrapperDef.SFM_StringMap('INFOTYPE',null); 
        SFM_WrapperDef.SFM_StringMap Stringmapcls9 = new SFM_WrapperDef.SFM_StringMap('SEARCHRECORD',null);
        SFM_WrapperDef.SFM_StringMap Stringmapcls10 = new SFM_WrapperDef.SFM_StringMap('RELATEDOBJECTNAME',null);
        SFM_WrapperDef.SFM_StringMap Stringmapcls11 = new SFM_WrapperDef.SFM_StringMap('CONTEXTVALUE','');
        
        SFM_WrapperDef.SFM_StringMap Stringmapcls12 = new SFM_WrapperDef.SFM_StringMap('SEARCHOPERATOR','eq');
        SFM_WrapperDef.SFM_StringMap Stringmapcls13 = new SFM_WrapperDef.SFM_StringMap('SEARCHOPERATOR','contains');
        SFM_WrapperDef.SFM_StringMap Stringmapcls14 = new SFM_WrapperDef.SFM_StringMap('SEARCHOPERATOR','sw');
        SFM_WrapperDef.SFM_StringMap Stringmapcls15 = new SFM_WrapperDef.SFM_StringMap('SEARCHOPERATOR','ew');
        
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        ListOfStringMap.add(Stringmapcls4);
        ListOfStringMap.add(Stringmapcls5);
        ListOfStringMap.add(Stringmapcls6);
        ListOfStringMap.add(Stringmapcls7);
        ListOfStringMap.add(Stringmapcls8);
        ListOfStringMap.add(Stringmapcls9);
        ListOfStringMap.add(Stringmapcls10);
        ListOfStringMap.add(Stringmapcls11);
        
        ListOfStringMap.add(Stringmapcls12);
        ListOfStringMap.add(Stringmapcls13);
        ListOfStringMap.add(Stringmapcls14);
        ListOfStringMap.add(Stringmapcls15);
        
        /*...........Class Instance...........*/        
        SFM_getLookUpConfigWithData lookUpConfig = new SFM_getLookUpConfigWithData();
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        request.setstringMap(ListOfStringMap);
        
        /*...........Method Call...........*/
        lookUpConfig.getLookUpConfigWithData(request);
    }
}