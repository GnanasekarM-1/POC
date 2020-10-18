@isTest
private class INTF_GetLookUpConfigWithData_UT
{
    static testMethod void INTF_getLookUpConfigWithDataUnitTest()
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


        SVMXC__Service_Order__c namedSearchHdr1 = new SVMXC__Service_Order__c(SVMXC__Order_Status__c='Open');
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
        List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail> namedSearchDetails = new List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail>();
        INTF_WebServicesDef.INTF_NamedSearchInfoDetail processNodeSourceObject1 = new INTF_WebServicesDef.INTF_NamedSearchInfoDetail(objectDetails,fields);
        namedSearchDetails.add(processNodeSourceObject1);
        
        //----------------------------------------Creating NameSearch Info-----------------------------------
        List<INTF_WebServicesDef.INTF_NamedSearchInfo> NSI1=new List<INTF_WebServicesDef.INTF_NamedSearchInfo>();
        INTF_WebServicesDef.INTF_NamedSearchInfo oINTF_Exp1=new INTF_WebServicesDef.INTF_NamedSearchInfo(namedSearchHdr,namedSearchDetails);
        NSI1.add(oINTF_Exp1);
        
        //-----------------------------------------Creating List of String Map-----------------------------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls1 = new INTF_WebServicesDef.INTF_StringMap('RECORDID',namedSearchHdr.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls2 = new INTF_WebServicesDef.INTF_StringMap('OBJECTNAME','SVMXC__Service_Order__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls3 = new INTF_WebServicesDef.INTF_StringMap('KEYWORD','Replenishment');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls4 = new INTF_WebServicesDef.INTF_StringMap('DEFAULTCOLUMN','SVMXC__Failure_Location__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls5 = new INTF_WebServicesDef.INTF_StringMap('NOOFRECORDS','2');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls6 = new INTF_WebServicesDef.INTF_StringMap('CONTEXTVALUE',null); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls7 = new INTF_WebServicesDef.INTF_StringMap('FIELDNAME',null);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls8 = new INTF_WebServicesDef.INTF_StringMap('INFOTYPE','Bubble'); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls9 = new INTF_WebServicesDef.INTF_StringMap('SEARCHRECORD',namedSearchHdr1.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls10 = new INTF_WebServicesDef.INTF_StringMap('RELATEDOBJECTNAME','');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls11 = new INTF_WebServicesDef.INTF_StringMap('CONTEXTVALUE','Rep');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls12 = new INTF_WebServicesDef.INTF_StringMap('SEARCHOPERATOR','contains');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls13 = new INTF_WebServicesDef.INTF_StringMap('SEARCHOPERATOR','sw');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls14 = new INTF_WebServicesDef.INTF_StringMap('SEARCHOPERATOR','ew');




        ListOfStringMap.add(Stringmapcls6);
        ListOfStringMap.add(Stringmapcls7);
        ListOfStringMap.add(Stringmapcls8);
        ListOfStringMap.add(Stringmapcls9);
        ListOfStringMap.add(Stringmapcls10);
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        ListOfStringMap.add(Stringmapcls4);
        ListOfStringMap.add(Stringmapcls5);
        ListOfStringMap.add(Stringmapcls11);
        
        ListOfStringMap.add(Stringmapcls12);
        ListOfStringMap.add(Stringmapcls13);
        ListOfStringMap.add(Stringmapcls14);





        



        
        
        /*...........Class Instance...........*/        
        INTF_getLookUpConfigWithData lookUpConfig = new INTF_getLookUpConfigWithData();
        INTF_WebServicesDef.INTF_Request request = new INTF_WebServicesDef.INTF_Request();
        request.setstringMap(ListOfStringMap);
        
        /*...........Method Call...........*/
        lookUpConfig.getLookUpConfigWithData(request);
        
        INTF_WebServicesDef.INTF_StringMap Stringmapcls16 = new INTF_WebServicesDef.INTF_StringMap('KEYWORD',null);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls17 = new INTF_WebServicesDef.INTF_StringMap('DEFAULTCOLUMN',null);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls18 = new INTF_WebServicesDef.INTF_StringMap('INFOTYPE',null); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls19 = new INTF_WebServicesDef.INTF_StringMap('CONTEXTVALUE',null); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls20 = new INTF_WebServicesDef.INTF_StringMap('SEARCHOPERATOR','eq');
        //INTF_WebServicesDef.INTF_StringMap Stringmapcls21 = new INTF_WebServicesDef.INTF_StringMap('NOOFRECORDS',null);
        





















        

        ListOfStringMap.add(Stringmapcls16);











        ListOfStringMap.add(Stringmapcls17);
        ListOfStringMap.add(Stringmapcls18);
        ListOfStringMap.add(Stringmapcls19);
        ListOfStringMap.add(Stringmapcls20);
        //ListOfStringMap.add(Stringmapcls21);




    
        request.setstringMap(ListOfStringMap);
        lookUpConfig.getLookUpConfigWithData(request);












        
        INTF_WebServicesDef.INTF_StringMap Stringmapcls22 = new INTF_WebServicesDef.INTF_StringMap('KEYWORD','WO');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls23 = new INTF_WebServicesDef.INTF_StringMap('INFOTYPE',null); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls24 = new INTF_WebServicesDef.INTF_StringMap('SEARCHOPERATOR','contains');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls25 = new INTF_WebServicesDef.INTF_StringMap('CONTEXTVALUE','Rep');
        ListOfStringMap.add(Stringmapcls22);
        ListOfStringMap.add(Stringmapcls23);
        ListOfStringMap.add(Stringmapcls24);
        ListOfStringMap.add(Stringmapcls25);
        request.setstringMap(ListOfStringMap);
        lookUpConfig.getLookUpConfigWithData(request);














        




        
        INTF_WebServicesDef.INTF_StringMap Stringmapcls31 = new INTF_WebServicesDef.INTF_StringMap('KEYWORD','WO');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls32 = new INTF_WebServicesDef.INTF_StringMap('INFOTYPE',null); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls33 = new INTF_WebServicesDef.INTF_StringMap('SEARCHOPERATOR','sw');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls34 = new INTF_WebServicesDef.INTF_StringMap('CONTEXTVALUE',null);
        ListOfStringMap.add(Stringmapcls31);
        ListOfStringMap.add(Stringmapcls32);
        ListOfStringMap.add(Stringmapcls33);
        ListOfStringMap.add(Stringmapcls34);
        request.setstringMap(ListOfStringMap);
        lookUpConfig.getLookUpConfigWithData(request);




        
        INTF_WebServicesDef.INTF_StringMap Stringmapcls41 = new INTF_WebServicesDef.INTF_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Order__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls42 = new INTF_WebServicesDef.INTF_StringMap('INFOTYPE','Bubble'); 
        ListOfStringMap.add(Stringmapcls41);
        ListOfStringMap.add(Stringmapcls42);



        request.setstringMap(ListOfStringMap);
        lookUpConfig.getLookUpConfigWithData(request);
        
        INTF_WebServicesDef.INTF_StringMap Stringmapcls43 = new INTF_WebServicesDef.INTF_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Order__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls44 = new INTF_WebServicesDef.INTF_StringMap('INFOTYPE','Result'); 
        ListOfStringMap.add(Stringmapcls43);
        ListOfStringMap.add(Stringmapcls44);
        request.setstringMap(ListOfStringMap);

        lookUpConfig.getLookUpConfigWithData(request);

    }
    

    






    
    static testMethod void INTF_getLookUpConfigWithDataUnitTest1()
    {
        /*...........Data Creation...........*/
        //------------------------------------------Creating Record Type-----------------------------------------
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        String rid;
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
        SVMXC__Service_Order__c namedSearchHdr1 = new SVMXC__Service_Order__c(SVMXC__Order_Status__c='Open');
        insert namedSearchHdr1;
        System.assertEquals(true, namedSearchHdr1 != null);
        
        //-----------------------------------------Creating List of String Map-----------------------------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls1 = new INTF_WebServicesDef.INTF_StringMap('RECORDID',namedSearchHdr.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls2 = new INTF_WebServicesDef.INTF_StringMap('OBJECTNAME','SVMXC__Service_Order__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls3 = new INTF_WebServicesDef.INTF_StringMap('KEYWORD',null);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls4 = new INTF_WebServicesDef.INTF_StringMap('DEFAULTCOLUMN','SVMXC__Failure_Location__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls5 = new INTF_WebServicesDef.INTF_StringMap('NOOFRECORDS','2');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls6 = new INTF_WebServicesDef.INTF_StringMap('CONTEXTVALUE',null); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls7 = new INTF_WebServicesDef.INTF_StringMap('FIELDNAME',null);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls8 = new INTF_WebServicesDef.INTF_StringMap('INFOTYPE',null); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls9 = new INTF_WebServicesDef.INTF_StringMap('SEARCHRECORD',namedSearchHdr1.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls10 = new INTF_WebServicesDef.INTF_StringMap('RELATEDOBJECTNAME','');
        ListOfStringMap.add(Stringmapcls6);
        ListOfStringMap.add(Stringmapcls7);
        ListOfStringMap.add(Stringmapcls8);
        ListOfStringMap.add(Stringmapcls9);
        ListOfStringMap.add(Stringmapcls10);
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        ListOfStringMap.add(Stringmapcls4);
        ListOfStringMap.add(Stringmapcls5);
        


        //------------------------------------Creating Process Object---------------------------------
        SVMXC__ServiceMax_Processes__c objectDetails = new SVMXC__ServiceMax_Processes__c();
        objectDetails.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objectDetails.SVMXC__ProcessID__c='PROCESS11';
        objectDetails.SVMXC__SettingId__c = 'PROCESS11';
        objectDetails.SVMXC__MapID__c='PROCESS11';
        objectDetails.SVMXC__Name__c = 'PROCESS22';
        objectDetails.SVMXC__Module__c = namedSearchHdr.Id;
        objectDetails.RecordTypeId=rid;
        objectDetails.SVMXC__Process__c = namedSearchHdr.Id;
        upsert objectDetails;
        System.assertEquals(true, objectDetails != null);
                










        //-----------------------------------------Creating List of Config Data------------------------------------------------
        List<SVMXC__ServiceMax_Config_Data__c> fields = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c obj7=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=1,SVMXC__Search_Object_Field_Type__c='Result',SVMXC__Field_Name__c='SVMXC__Priority__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj8=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=2,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__Order_Type__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        //SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=4,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__How_Fixed__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj9=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=3,SVMXC__Search_Object_Field_Type__c='Bubble',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=3,SVMXC__Search_Object_Field_Type__c='Bubble',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c='');
        fields.add(obj10);
        fields.add(obj7);
        fields.add(obj8);
        fields.add(obj9);
        //fields.add(obj10);
        upsert fields;
        System.assertEquals(true, fields != null);
        
        //-----------------------------------------Creating Object of NamedSearchInfoDetails------------------------------------
        List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail> namedSearchDetails = new List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail>();
        INTF_WebServicesDef.INTF_NamedSearchInfoDetail processNodeSourceObject1 = new INTF_WebServicesDef.INTF_NamedSearchInfoDetail(objectDetails,fields);
        namedSearchDetails.add(processNodeSourceObject1);
        










        //----------------------------------------Creating NameSearch Info-----------------------------------
        List<INTF_WebServicesDef.INTF_NamedSearchInfo> NSI1=new List<INTF_WebServicesDef.INTF_NamedSearchInfo>();
        INTF_WebServicesDef.INTF_NamedSearchInfo oINTF_Exp1=new INTF_WebServicesDef.INTF_NamedSearchInfo(namedSearchHdr,namedSearchDetails);
        NSI1.add(oINTF_Exp1);
        




        /*...........Class Instance...........*/        
        INTF_getLookUpConfigWithData lookUpConfig = new INTF_getLookUpConfigWithData();
        INTF_WebServicesDef.INTF_Request request = new INTF_WebServicesDef.INTF_Request();
        request.setstringMap(ListOfStringMap);

        





        /*...........Method Call...........*/
        lookUpConfig.getLookUpConfigWithData(request);

    }
    static testMethod void INTF_getLookUpConfigWithDataUnitTest2()
    {
        /*...........Data Creation...........*/
        //------------------------------------------Creating Record Type-----------------------------------------
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        String rid;







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




        SVMXC__Service_Order__c namedSearchHdr1 = new SVMXC__Service_Order__c(SVMXC__Order_Status__c='Open');
        insert namedSearchHdr1;
        System.assertEquals(true, namedSearchHdr1 != null);
        
        //-----------------------------------------Creating List of String Map-----------------------------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls1 = new INTF_WebServicesDef.INTF_StringMap('RECORDID',namedSearchHdr.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls2 = new INTF_WebServicesDef.INTF_StringMap('OBJECTNAME','SVMXC__Service_Order__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls3 = new INTF_WebServicesDef.INTF_StringMap('KEYWORD','Replenishment');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls4 = new INTF_WebServicesDef.INTF_StringMap('DEFAULTCOLUMN','SVMXC__Failure_Location__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls5 = new INTF_WebServicesDef.INTF_StringMap('NOOFRECORDS','2');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls6 = new INTF_WebServicesDef.INTF_StringMap('CONTEXTVALUE','SVMXC__Company__c'); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls7 = new INTF_WebServicesDef.INTF_StringMap('FIELDNAME','AccountId');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls8 = new INTF_WebServicesDef.INTF_StringMap('INFOTYPE',null); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls9 = new INTF_WebServicesDef.INTF_StringMap('SEARCHRECORD',namedSearchHdr1.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls10 = new INTF_WebServicesDef.INTF_StringMap('RELATEDOBJECTNAME','');
        ListOfStringMap.add(Stringmapcls6);
        ListOfStringMap.add(Stringmapcls7);
        ListOfStringMap.add(Stringmapcls8);
        ListOfStringMap.add(Stringmapcls9);
        ListOfStringMap.add(Stringmapcls10);
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        ListOfStringMap.add(Stringmapcls4);
        ListOfStringMap.add(Stringmapcls5);
        
        //------------------------------------Creating Process Object---------------------------------
        SVMXC__ServiceMax_Processes__c objectDetails = new SVMXC__ServiceMax_Processes__c();
        objectDetails.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objectDetails.SVMXC__ProcessID__c='PROCESS11';
        objectDetails.SVMXC__SettingId__c = 'PROCESS11';
        objectDetails.SVMXC__MapID__c='PROCESS11';
        objectDetails.SVMXC__Name__c = 'PROCESS22';
        objectDetails.SVMXC__Module__c = namedSearchHdr.Id;
        objectDetails.RecordTypeId=rid;

        objectDetails.SVMXC__Process__c = namedSearchHdr.Id;
        upsert objectDetails;
        System.assertEquals(true, objectDetails != null);
                
        //-----------------------------------------Creating List of Config Data------------------------------------------------
        List<SVMXC__ServiceMax_Config_Data__c> fields = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c obj7=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=1,SVMXC__Search_Object_Field_Type__c='Result',SVMXC__Field_Name__c='SVMXC__Priority__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj8=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=2,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__Order_Type__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        //SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=4,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__How_Fixed__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj9=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=3,SVMXC__Search_Object_Field_Type__c='Bubble',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=3,SVMXC__Search_Object_Field_Type__c='Bubble',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c='');
        fields.add(obj10);
        fields.add(obj7);
        fields.add(obj8);
        fields.add(obj9);
        //fields.add(obj10);
        upsert fields;
        System.assertEquals(true, fields != null);
        

        //-----------------------------------------Creating Object of NamedSearchInfoDetails------------------------------------
        List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail> namedSearchDetails = new List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail>();
        INTF_WebServicesDef.INTF_NamedSearchInfoDetail processNodeSourceObject1 = new INTF_WebServicesDef.INTF_NamedSearchInfoDetail(objectDetails,fields);
        namedSearchDetails.add(processNodeSourceObject1);
        

        //----------------------------------------Creating NameSearch Info-----------------------------------
        List<INTF_WebServicesDef.INTF_NamedSearchInfo> NSI1=new List<INTF_WebServicesDef.INTF_NamedSearchInfo>();
        INTF_WebServicesDef.INTF_NamedSearchInfo oINTF_Exp1=new INTF_WebServicesDef.INTF_NamedSearchInfo(namedSearchHdr,namedSearchDetails);
        NSI1.add(oINTF_Exp1);
        

        /*...........Class Instance...........*/        
        INTF_getLookUpConfigWithData lookUpConfig = new INTF_getLookUpConfigWithData();
        INTF_WebServicesDef.INTF_Request request = new INTF_WebServicesDef.INTF_Request();
        request.setstringMap(ListOfStringMap);
        

        /*...........Method Call...........*/
        lookUpConfig.getLookUpConfigWithData(request);
    }
    static testMethod void INTF_getLookUpConfigWithDataUnitTest3()
    {
        /*...........Data Creation...........*/
        //------------------------------------------Creating Record Type-----------------------------------------
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        String rid;
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
        SVMXC__Service_Order__c namedSearchHdr1 = new SVMXC__Service_Order__c(SVMXC__Order_Status__c='Open');
        insert namedSearchHdr1;
        System.assertEquals(true, namedSearchHdr1 != null);
        

        //-----------------------------------------Creating List of String Map-----------------------------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls1 = new INTF_WebServicesDef.INTF_StringMap('RECORDID',null);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls2 = new INTF_WebServicesDef.INTF_StringMap('OBJECTNAME','SVMXC__Territory__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls3 = new INTF_WebServicesDef.INTF_StringMap('KEYWORD','Replenishment');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls4 = new INTF_WebServicesDef.INTF_StringMap('DEFAULTCOLUMN','SVMXC__Failure_Location__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls5 = new INTF_WebServicesDef.INTF_StringMap('NOOFRECORDS','2');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls6 = new INTF_WebServicesDef.INTF_StringMap('CONTEXTVALUE','SVMXC__Company__c'); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls7 = new INTF_WebServicesDef.INTF_StringMap('FIELDNAME','AccountId');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls8 = new INTF_WebServicesDef.INTF_StringMap('INFOTYPE',null); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls9 = new INTF_WebServicesDef.INTF_StringMap('SEARCHRECORD',namedSearchHdr1.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls10 = new INTF_WebServicesDef.INTF_StringMap('RELATEDOBJECTNAME','');
        ListOfStringMap.add(Stringmapcls6);
        ListOfStringMap.add(Stringmapcls7);
        ListOfStringMap.add(Stringmapcls8);
        ListOfStringMap.add(Stringmapcls9);
        ListOfStringMap.add(Stringmapcls10);
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        ListOfStringMap.add(Stringmapcls4);
        ListOfStringMap.add(Stringmapcls5);
        

        //------------------------------------Creating Process Object---------------------------------
        SVMXC__ServiceMax_Processes__c objectDetails = new SVMXC__ServiceMax_Processes__c();
        objectDetails.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objectDetails.SVMXC__ProcessID__c='PROCESS11';
        objectDetails.SVMXC__SettingId__c = 'PROCESS11';
        objectDetails.SVMXC__MapID__c='PROCESS11';
        objectDetails.SVMXC__Name__c = 'PROCESS22';
        objectDetails.SVMXC__Module__c = namedSearchHdr.Id;
        objectDetails.RecordTypeId=rid;
        objectDetails.SVMXC__Process__c = namedSearchHdr.Id;
        upsert objectDetails;
        System.assertEquals(true, objectDetails != null);
                

        //-----------------------------------------Creating List of Config Data------------------------------------------------
        List<SVMXC__ServiceMax_Config_Data__c> fields = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c obj7=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=1,SVMXC__Search_Object_Field_Type__c='Result',SVMXC__Field_Name__c='SVMXC__Priority__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj8=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=2,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__Order_Type__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        //SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=4,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__How_Fixed__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj9=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=3,SVMXC__Search_Object_Field_Type__c='Bubble',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=3,SVMXC__Search_Object_Field_Type__c='Bubble',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c='');
        fields.add(obj10);
        fields.add(obj7);
        fields.add(obj8);
        fields.add(obj9);
        //fields.add(obj10);
        upsert fields;

        System.assertEquals(true, fields != null);
        
        //-----------------------------------------Creating Object of NamedSearchInfoDetails------------------------------------
        List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail> namedSearchDetails = new List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail>();
        INTF_WebServicesDef.INTF_NamedSearchInfoDetail processNodeSourceObject1 = new INTF_WebServicesDef.INTF_NamedSearchInfoDetail(objectDetails,fields);
        namedSearchDetails.add(processNodeSourceObject1);
        
        //----------------------------------------Creating NameSearch Info-----------------------------------
        List<INTF_WebServicesDef.INTF_NamedSearchInfo> NSI1=new List<INTF_WebServicesDef.INTF_NamedSearchInfo>();
        INTF_WebServicesDef.INTF_NamedSearchInfo oINTF_Exp1=new INTF_WebServicesDef.INTF_NamedSearchInfo(namedSearchHdr,namedSearchDetails);
        NSI1.add(oINTF_Exp1);
        













        /*...........Class Instance...........*/        
        INTF_getLookUpConfigWithData lookUpConfig = new INTF_getLookUpConfigWithData();
        INTF_WebServicesDef.INTF_Request request = new INTF_WebServicesDef.INTF_Request();
        request.setstringMap(ListOfStringMap);
        




        /*...........Method Call...........*/
        lookUpConfig.getLookUpConfigWithData(request);
    }
    static testMethod void INTF_getLookUpConfigWithDataUnitTest4()
    {
        /*...........Data Creation...........*/
        //------------------------------------------Creating Record Type-----------------------------------------
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        String rid;
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
        SVMXC__Service_Order__c namedSearchHdr1 = new SVMXC__Service_Order__c(SVMXC__Order_Status__c='Open');
        insert namedSearchHdr1;
        System.assertEquals(true, namedSearchHdr1 != null);
        
        //-----------------------------------------Creating List of String Map-----------------------------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap = new List<INTF_WebServicesDef.INTF_StringMap>();




        INTF_WebServicesDef.INTF_StringMap Stringmapcls1 = new INTF_WebServicesDef.INTF_StringMap('RECORDID',null);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls2 = new INTF_WebServicesDef.INTF_StringMap('OBJECTNAME','SVMXC__Territory__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls3 = new INTF_WebServicesDef.INTF_StringMap('KEYWORD','Replenishment');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls4 = new INTF_WebServicesDef.INTF_StringMap('DEFAULTCOLUMN','SVMXC__Failure_Location__c');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls5 = new INTF_WebServicesDef.INTF_StringMap('NOOFRECORDS','2');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls6 = new INTF_WebServicesDef.INTF_StringMap('CONTEXTVALUE','SVMXC__Company__c'); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls7 = new INTF_WebServicesDef.INTF_StringMap('FIELDNAME','AccountId');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls8 = new INTF_WebServicesDef.INTF_StringMap('INFOTYPE',null); 
        INTF_WebServicesDef.INTF_StringMap Stringmapcls9 = new INTF_WebServicesDef.INTF_StringMap('SEARCHRECORD',namedSearchHdr1.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls10 = new INTF_WebServicesDef.INTF_StringMap('RELATEDOBJECTNAME','');
        ListOfStringMap.add(Stringmapcls6);
        ListOfStringMap.add(Stringmapcls7);
        ListOfStringMap.add(Stringmapcls8);
        ListOfStringMap.add(Stringmapcls9);
        ListOfStringMap.add(Stringmapcls10);
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        ListOfStringMap.add(Stringmapcls4);
        ListOfStringMap.add(Stringmapcls5);
        




        //------------------------------------Creating Process Object---------------------------------
        SVMXC__ServiceMax_Processes__c objectDetails = new SVMXC__ServiceMax_Processes__c();
        objectDetails.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objectDetails.SVMXC__ProcessID__c='PROCESS11';
        objectDetails.SVMXC__SettingId__c = 'PROCESS11';
        objectDetails.SVMXC__MapID__c='PROCESS11';
        objectDetails.SVMXC__Name__c = 'PROCESS22';
        objectDetails.SVMXC__Module__c = namedSearchHdr.Id;
        objectDetails.RecordTypeId=rid;
        objectDetails.SVMXC__Process__c = namedSearchHdr.Id;
        upsert objectDetails;
        System.assertEquals(true, objectDetails != null);
                
        //-----------------------------------------Creating List of Config Data------------------------------------------------
        List<SVMXC__ServiceMax_Config_Data__c> fields = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c obj7=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=1,SVMXC__Search_Object_Field_Type__c='Result',SVMXC__Field_Name__c='SVMXC__Priority__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj8=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=2,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__Order_Type__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        //SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=4,SVMXC__Search_Object_Field_Type__c='Search',SVMXC__Field_Name__c='SVMXC__How_Fixed__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj9=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=3,SVMXC__Search_Object_Field_Type__c='Bubble',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id);
        SVMXC__ServiceMax_Config_Data__c obj10=new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=3,SVMXC__Search_Object_Field_Type__c='Bubble',SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=objectDetails.Id,SVMXC__Display_Type__c='');
        fields.add(obj10);
        fields.add(obj7);
        fields.add(obj8);
        fields.add(obj9);
        //fields.add(obj10);
        upsert fields;
        System.assertEquals(true, fields != null);
        
        //-----------------------------------------Creating Object of NamedSearchInfoDetails------------------------------------
        List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail> namedSearchDetails = new List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail>();
        INTF_WebServicesDef.INTF_NamedSearchInfoDetail processNodeSourceObject1 = new INTF_WebServicesDef.INTF_NamedSearchInfoDetail(objectDetails,fields);
        namedSearchDetails.add(processNodeSourceObject1);
        
        //----------------------------------------Creating NameSearch Info-----------------------------------
        List<INTF_WebServicesDef.INTF_NamedSearchInfo> NSI1=new List<INTF_WebServicesDef.INTF_NamedSearchInfo>();
        INTF_WebServicesDef.INTF_NamedSearchInfo oINTF_Exp1=new INTF_WebServicesDef.INTF_NamedSearchInfo(namedSearchHdr,namedSearchDetails);
        NSI1.add(oINTF_Exp1);
        
        /*...........Class Instance...........*/        
        INTF_getLookUpConfigWithData lookUpConfig = new INTF_getLookUpConfigWithData();
        INTF_WebServicesDef.INTF_Request request = new INTF_WebServicesDef.INTF_Request();
        request.setstringMap(ListOfStringMap);
        
        /*...........Method Call...........*/
        
        lookUpConfig.getLookUpConfigWithData(request);
    }
}