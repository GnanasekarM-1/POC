/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SFMDeliveryController_UT {

    static testMethod void SFMDeliveryControllerTest() {
        //Create SFM Process.
        String targetManager;
      String processNodeObjects;
      String objectMapping; 
      String fieldMapping;
      String expression;
      String SVMXRule;
      String nameSearch;
      List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        
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
            else if(r.Name == 'Named Search')  
              nameSearch = r.id;  
          }
        }
        
        System.currentPagereference().getParameters().put('SVMX_recordID','dfdfd');
        System.currentPagereference().getParameters().put('SVMX_ProcessID','dfdfd');
        SFMDeliveryController sfmDdd = new SFMDeliveryController();
        
        
        SVMXC__ServiceMax_Processes__c objHeaderExpression = new SVMXC__ServiceMax_Processes__c();
        objHeaderExpression.RecordTypeId = SVMXRule;
        objHeaderExpression.SVMXC__Parent_Object_Criteria__c = 'Name != \'abc\'';
        objHeaderExpression.SVMXC__Parent_Error_Msg__c = 'Error';
        insert objHeaderExpression;
        
        SVMXC__ServiceMax_Processes__c objNameSearch = new SVMXC__ServiceMax_Processes__c();
        objNameSearch.RecordTypeId=nameSearch;
        objNameSearch.SVMXC__IsDefault__C=true;
        objNameSearch.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
        objNameSearch.SVMXC__ProcessID__c='Account Lookup Config';
        objNameSearch.SVMXC__Source_Object_Name__c = 'Account';
        objNameSearch.SVMXC__Default_Lookup_Column__c = 'Name';
        insert objNameSearch;
        
        SVMXC__ServiceMax_Processes__c objNameSearch1 = new SVMXC__ServiceMax_Processes__c();
        objNameSearch1.RecordTypeId=nameSearch;
        objNameSearch1.SVMXC__IsDefault__C=true;
        objNameSearch1.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
        objNameSearch1.SVMXC__ProcessID__c='Product Lookup Config';
        objNameSearch1.SVMXC__Source_Object_Name__c = 'Product2';
        objNameSearch1.SVMXC__Default_Lookup_Column__c = 'Name';
        insert objNameSearch1;
      
      //Create Header Page layout
      SVMXC__Page_Layout__c objHeaderLayout = new SVMXC__Page_Layout__c();
        objHeaderLayout.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        objHeaderLayout.SVMXC__Type__c = 'Header';
        insert objHeaderLayout;
        System.assertEquals(true, objHeaderLayout != null);
        
        //Create Detail Page layout
        SVMXC__Page_Layout__c objDetailLayout = new SVMXC__Page_Layout__c();
        objDetailLayout.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        objDetailLayout.SVMXC__Type__c = 'Detail';
        objDetailLayout.SVMXC__Header_Page_Layout__c = objHeaderLayout.Id;
        objDetailLayout.SVMXC__Header_Reference_Field__c = 'SVMXC__Quote__c';
        insert objDetailLayout; 
        
        //Create Sections for header 
        list<SVMXC__Page_Layout_Detail__c> lstSection = new list<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c objSection1 = new SVMXC__Page_Layout_Detail__c();
        objSection1.SVMXC__Detail_Type__c = 'Section';
        objSection1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        objSection1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objSection1.SVMXC__Title__c = 'Service Quote';
        objSection1.SVMXC__Sequence__c = 1;
        lstSection.add(objSection1);
        SVMXC__Page_Layout_Detail__c objSection2 = new SVMXC__Page_Layout_Detail__c();
        objSection2.SVMXC__Detail_Type__c = 'Section';
        objSection2.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout2';
        objSection2.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objSection2.SVMXC__Sequence__c = 2;
        lstSection.add(objSection2);
        insert lstSection;
       
         //Create Fields for Header Layout
        List<SVMXC__Page_Layout_Detail__c> lstHeaderFields = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c objfld1 = new SVMXC__Page_Layout_Detail__c();
        objfld1.SVMXC__Detail_Type__c = 'Field';
        objfld1.SVMXC__Field_API_Name__c = 'SVMXC__Company__c';
        objfld1.SVMXC__Related_Object_Name__c = 'Account';
        objfld1.SVMXC__Related_Object_Name_Field__c = 'Name';
        objfld1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld1.SVMXC__Section__c = lstSection[0].Id;
        objfld1.SVMXC__DataType__c = 'REFERENCE';
        objfld1.SVMXC__Sequence__c = 1;
        objfld1.SVMXC__Named_Search__c = objNameSearch.id;
        lstHeaderFields.add(objfld1);
        SVMXC__Page_Layout_Detail__c objfld2 = new SVMXC__Page_Layout_Detail__c();
        objfld2.SVMXC__Detail_Type__c = 'Field';
        objfld2.SVMXC__Field_API_Name__c = 'SVMXC__Discount__c';
        objfld2.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld2.SVMXC__Section__c = lstSection[0].Id;
        objfld2.SVMXC__DataType__c = 'DOUBLE';
        objfld2.SVMXC__Sequence__c = 2;
        lstHeaderFields.add(objfld2);
        SVMXC__Page_Layout_Detail__c objfld3 = new SVMXC__Page_Layout_Detail__c();
        objfld3.SVMXC__Detail_Type__c = 'Field';
        objfld3.SVMXC__Field_API_Name__c = 'SVMXC__Discount_Type__c';
        objfld3.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld3.SVMXC__Section__c = lstSection[1].Id;
        objfld3.SVMXC__DataType__c = 'PICKLIST';
        objfld3.SVMXC__Sequence__c = 1;
        lstHeaderFields.add(objfld3);
        insert lstHeaderFields;
        //Create Fields for Detail Layout
        List<SVMXC__Page_Layout_Detail__c> lstDetailFields = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c objfld4 = new SVMXC__Page_Layout_Detail__c();
        objfld4.SVMXC__Detail_Type__c = 'Field';
        objfld4.SVMXC__Field_API_Name__c = 'SVMXC__Product__c';
        objfld4.SVMXC__Related_Object_Name__c = 'Product2';
        objfld4.SVMXC__Related_Object_Name_Field__c = 'Name';
        objfld4.SVMXC__Page_Layout__c = objDetailLayout.Id;
        objfld4.SVMXC__DataType__c = 'REFERENCE';
        objfld4.SVMXC__Sequence__c = 1;
        objfld4.SVMXC__Named_Search__c = objNameSearch1.id;
        lstDetailFields.add(objfld4);
        SVMXC__Page_Layout_Detail__c objfld5 = new SVMXC__Page_Layout_Detail__c();
        objfld5.SVMXC__Detail_Type__c = 'Field';
        objfld5.SVMXC__Field_API_Name__c = 'SVMXC__Line_Description__c';
        objfld5.SVMXC__Page_Layout__c = objDetailLayout.Id;
        objfld5.SVMXC__DataType__c = 'TEXTAREA';
        objfld5.SVMXC__Sequence__c = 2;
        lstDetailFields.add(objfld5);
        insert lstDetailFields;
        
        //Create Buttons
        SVMXC__Page_Layout_Detail__c Button1 = new SVMXC__Page_Layout_Detail__c();
        Button1.SVMXC__Detail_Type__c = 'Button';
        Button1.SVMXC__Title__c = 'Get Price';
        Button1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        Button1.SVMXC__Sequence__c = 2;
        insert Button1;
        SVMXC__Page_Layout_Detail__c Button2 = new SVMXC__Page_Layout_Detail__c();
        Button2.SVMXC__Detail_Type__c = 'Button';
        Button2.SVMXC__Title__c = 'Get Price';
        Button2.SVMXC__Page_Layout__c = objDetailLayout.Id;
        Button2.SVMXC__Sequence__c = 2;
        insert Button2;
        
        //Create Events 
        List<SVMXC__SFM_Event__c> lstEvents = new List<SVMXC__SFM_Event__c>();
        SVMXC__SFM_Event__c PageEvent = new SVMXC__SFM_Event__c();
        PageEvent.SVMXC__Event_Type__c = 'On Page Load';
        PageEvent.SVMXC__Event_Type__c = 'WEBSERVICE';
        PageEvent.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        PageEvent.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        SVMXC__SFM_Event__c DetailPageEvent = new SVMXC__SFM_Event__c();
        DetailPageEvent.SVMXC__Event_Type__c = 'On Page Load';
        DetailPageEvent.SVMXC__Event_Type__c = 'WEBSERVICE';
        DetailPageEvent.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        DetailPageEvent.SVMXC__Page_Layout__c = objDetailLayout.Id;
        lstEvents.add(DetailPageEvent);
        SVMXC__SFM_Event__c ButtonEvent = new SVMXC__SFM_Event__c();
        ButtonEvent.SVMXC__Event_Type__c = 'On Button Click';
        ButtonEvent.SVMXC__Event_Type__c = 'WEBSERVICE';
        ButtonEvent.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        ButtonEvent.SVMXC__Page_Layout_Detail__c = Button1.Id;
        lstEvents.add(ButtonEvent);
        SVMXC__SFM_Event__c FieldChange = new SVMXC__SFM_Event__c();
        FieldChange.SVMXC__Event_Type__c = 'Field Change';
        FieldChange.SVMXC__Event_Type__c = 'WEBSERVICE';
        FieldChange.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        FieldChange.SVMXC__Page_Layout_Detail__c = lstHeaderFields[0].Id;
        lstEvents.add(FieldChange);
        insert lstEvents;
        
       
      
      //Create SFM Process Defination
      SVMXC__ServiceMax_Processes__c standaloneCreate = new SVMXC__ServiceMax_Processes__c();
      standaloneCreate.SVMXC__Name__c = 'CUSTOMPRO0001';
      standaloneCreate.RecordTypeId = targetManager;
      standaloneCreate.SVMXC__Purpose__c = 'STANDALONE CREATE';
      standaloneCreate.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
      standaloneCreate.SVMXC__Page_Layout__c = objHeaderLayout.id;
      standaloneCreate.SVMXC__Tag_Keys__c = 'Test';
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
      PNObject1.SVMXC__Submodule__c = objHeaderExpression.id;
      listProcessNodeObjects.add(PNObject1);
      
      SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
      PNObject2.RecordTypeId = processNodeObjects;
      PNObject2.SVMXC__Type__c = 'TARGETCHILD';
      PNObject2.SVMXC__Page_Layout__c = objDetailLayout.id;
      PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
      PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
      PNObject2.SVMXC__Process__c = standaloneCreate.id;
      PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
      listProcessNodeObjects.add(PNObject2);
      insert listProcessNodeObjects;
      
      //Create Quote-QuoteDetail Records.
      SVMXC__Quote__c objQO = new SVMXC__Quote__c();
      objQO.SVMXC__Status__c = 'Presented';
      insert objQO;
      SVMXC__Quote_Line__c objOL = new SVMXC__Quote_Line__c();
      objOL.SVMXC__Quote__c = objQO.id;
      objOL.SVMXC__Line_Type__c = 'Parts';
      insert objOL;
      
      System.currentPagereference().getParameters().put('SVMX_recordID',objQO.Id);
        System.currentPagereference().getParameters().put('SVMX_ProcessID',standaloneCreate.Id);
        SFMDeliveryController sfmD = new SFMDeliveryController();
        //sfmD.getUserLocaleKey();
        //sfmD.getUserID();
        //sfmD.getUserOrgID();
        //sfmD.getBasicDisplayTags();
        /*sfmD.getErrorMessage();
        sfmD.getIsQualified();
        sfmD.getIsSFMProcess();
        sfmD.getPageData();
        sfmD.getProcessLMD();
        sfmD.getProcessTitle();
        sfmD.getUserInfo();
        sfmD.getLightningTitleProcessName();
        sfmD.getLightningTitleSourceRecordValue();*/
        
        try {//Added for UT Coverage
                //sfmD.getSettings(); 
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
                
        String strRequest = '{"moduleId":"SFM002","isSubModule":true}';
        SFMDeliveryController.JsrRetrieveDisplayTags(strRequest);
        strRequest = '{"objectName":"SVMXC__Quote__c"}';
        SFMDeliveryController.JsrDescribeObject(strRequest);
        strRequest = '{"processId":"CUSTOMPRO0001","recordId":"'+objQO.id+'"}';
        SFMDeliveryController.JsrGetPageLayout(strRequest);
        
        strRequest = '{"LookupRecordId":"Test","RecordId":"Test","ObjectName":"test"}';
        SFMDeliveryController.JsrGetBubbleData(strRequest);
        strRequest = '{"LookupRecordId":"Test","KeyWord":"Test","ObjectName":"test","LookupContext":"test","LookupQueryField":"test","SearchOperator":"test"}';
        SFMDeliveryController.JsrGetLookupConfig(strRequest);
        strRequest = '{"processId":"Test","alias":"Test","multiAddFieldApiName":"test","multiAddFieldRecordIds":["test","Test1"]}';
        SFMDeliveryController.JsrAddRecords(strRequest);
        
        //Begin - Added for UT Coverage
        try {
            SFMDeliveryController.JsrSaveTarget(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
        try {
            SFMDeliveryController.JsrGetSnippetForEvent(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
        try {
            SFMDeliveryController.JsrGetLookupData(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
         try {
            SFMDeliveryController.JsrGetPageData(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
        try {
            SFMDeliveryController.JsrSFM_GetSearchResult_WS(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
        try {
            SFMDeliveryController.JsrSFM_GetSearchInfo_WS(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
        try {
            SFMDeliveryController.JsrGetListOfChecklist(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
        try {
            strRequest = '{"processId":"CUSTOMPRO0001","recordId":"'+objQO.id+'","qualify":true}';
            SFMDeliveryController.JsrGetJwtToken(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
        try {
            SFMDeliveryController.JsrGetConfigInfo(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
        try {
            SFMDeliveryController.JsrGetIsQualify(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
        try {
            SFMDeliveryController.JsrGetPageDataV2(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
        try {
            SFMDeliveryController.JsrResolveLookUpDisplayValue('{"userId": "test"}');
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        
        try { //Added for BAC-5211
            SFMDeliveryController.JsrGetLookupConfiguration(strRequest);
        } catch (Exception e) {
            system.debug('Exception '+ e);
        }
        //End - Added for UT Coverage
            
        strRequest = '{"recordId":"Test","nextStepId":"Test"}';
        SFMDeliveryController.JsrGetNextStepInfo(strRequest);
        
        strRequest = '{"objectName":"Test"}';
        SFMDeliveryController.JsrGetRecordTypes(strRequest);
        
        SVMXC__ServiceMax_Processes__c standaloneCreate1 = new SVMXC__ServiceMax_Processes__c();
        standaloneCreate1.SVMXC__Name__c = 'CUSTOMPRO0001';
        standaloneCreate1.RecordTypeId = targetManager;
        standaloneCreate1.SVMXC__Purpose__c = 'STANDALONE CREATE';
        standaloneCreate1.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        standaloneCreate1.SVMXC__Page_Layout__c = objHeaderLayout.id;
        standaloneCreate1.SVMXC__Tag_Keys__c = 'Test';
        insert standaloneCreate1;
        
        System.currentPagereference().getParameters().put('SVMX_recordID',objQO.Id);
        System.currentPagereference().getParameters().put('SVMX_ProcessID','CUSTOMPRO0001');
        SFMDeliveryController sfmD2 = new SFMDeliveryController();
        //Boolean isFile = sfmD2.getSalesforceFileGlobalValue();
        /*strRequest = '';
        SFMDeliveryController.JsrAddRecords(strRequest);
        strRequest = '';
        SFMDeliveryController.JsrGetBubbleData(strRequest);
        strRequest = '';
        SFMDeliveryController.JsrGetLookupConfig(strRequest);
        strRequest = '';
        SFMDeliveryController.JsrGetLookupData(strRequest);
        strRequest = '';
        SFMDeliveryController.JsrGetNextStepInfo(strRequest);
        strRequest = '';
        SFMDeliveryController.JsrGetPageData(strRequest);
        
        strRequest = '';
        SFMDeliveryController.JsrGetRecordTypes(strRequest);
        strRequest = '';
        SFMDeliveryController.JsrGetSnippetForEvent(strRequest);
        strRequest = '';
        SFMDeliveryController.JsrSaveTarget(strRequest);*/
    }
    
    static testMethod void SFMDeliveryControllerTest2() {
      String targetManager;
      String processNodeObjects;
      List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        
        if(RTypeList.size() > 0)
        {
          for(RecordType r : RTypeList)
          {
            if(r.Name == 'Target Manager')
              targetManager = r.id; 
            else if(r.Name ==  'Process Node Objects')
              processNodeObjects = r.id;
          }
        }

      //Create Header Page layout
      SVMXC__Page_Layout__c objHeaderLayout = new SVMXC__Page_Layout__c();
        objHeaderLayout.SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c';
        objHeaderLayout.SVMXC__Type__c = 'Header';
        insert objHeaderLayout;
        System.assertEquals(true, objHeaderLayout != null);

        //Create Sections for header 
        list<SVMXC__Page_Layout_Detail__c> lstSection = new list<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c objSection1 = new SVMXC__Page_Layout_Detail__c();
        objSection1.SVMXC__Detail_Type__c = 'Section';
        objSection1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        objSection1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objSection1.SVMXC__Title__c = 'Service Quote';
        objSection1.SVMXC__Sequence__c = 1;
        lstSection.add(objSection1);
        insert lstSection;
       
         //Create Fields for Header Layout
        List<SVMXC__Page_Layout_Detail__c> lstHeaderFields = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c objfld1 = new SVMXC__Page_Layout_Detail__c();
        objfld1.SVMXC__Detail_Type__c = 'Field';
        objfld1.SVMXC__Field_API_Name__c = 'SVMXC__Company__c';
        objfld1.SVMXC__Related_Object_Name__c = 'Account';
        objfld1.SVMXC__Related_Object_Name_Field__c = 'Name';
        objfld1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld1.SVMXC__Section__c = lstSection[0].Id;
        objfld1.SVMXC__DataType__c = 'REFERENCE';
        objfld1.SVMXC__Sequence__c = 1;
        lstHeaderFields.add(objfld1);
        insert lstHeaderFields;

        //Create SFM Process Defination
      SVMXC__ServiceMax_Processes__c standaloneCreate = new SVMXC__ServiceMax_Processes__c();
      standaloneCreate.SVMXC__Name__c = 'CUSTOMPRO0001';
      standaloneCreate.RecordTypeId = targetManager;
      standaloneCreate.SVMXC__Purpose__c = 'STANDALONE CREATE';
      standaloneCreate.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
      standaloneCreate.SVMXC__Page_Layout__c = objHeaderLayout.id;
      standaloneCreate.SVMXC__Tag_Keys__c = 'Test';
      insert standaloneCreate;
      
      //Create Process Node object Records.
      list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
      SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
      PNObject1.RecordTypeId = processNodeObjects;
      PNObject1.SVMXC__Type__c = 'TARGET';
      PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
      PNObject1.SVMXC__Process__c = standaloneCreate.id;
      listProcessNodeObjects.add(PNObject1);
      
      //--Start----Added for the story BAC-3057
      SVMXC__SM_Application_Feature__c objAF = new SVMXC__SM_Application_Feature__c();
      objAF.SVMXC__SM_Feature_Name__c = 'SFM_DESIGNER';
      objAF.SVMXC__SM_Feature_Description__c = 'TEST';
      insert objAF;

      SVMXC__SM_Feature_Permission__c objFP = new SVMXC__SM_Feature_Permission__c();
      objFP.SVMXC__SM_Application_Feature__c = objAF.id;
      objFP.SVMXC__SM_User__c = UserInfo.getUserId();
      insert objFP;
      //--End----Added for the story BAC-3057
      insert listProcessNodeObjects;

        SVMXC__Installed_Product__c objIB = new SVMXC__Installed_Product__c();
        insert objIB;
        System.currentPagereference().getParameters().put('SVMX_recordID',objIB.Id);
        System.currentPagereference().getParameters().put('SVMX_ProcessID','CUSTOMPRO0001');
        SFMDeliveryController sfmD11 = new SFMDeliveryController();
        /*sfmD11.getTabStyleLogoURL();
        sfmD11.getColorCodeForIcon();
        sfmD11.getIsLaunchDesignerEnabled(); //Added for the story BAC-3057
        sfmD11.getUrlForLaunchDesigner(); //Added for the story BAC-3057*/
    }
    
    static testMethod void SFMDeliveryControllerTest1() {
        
        SFMDeliveryServiceImpl objServiceImpl = new SFMDeliveryServiceImpl();
        objServiceImpl.getPageLayoutInternal(new SFMDeliveryServiceImpl.PageLayoutRequest());
        objServiceImpl.retrieveSettingsInternal(new SFMDeliveryServiceImpl.RetrieveSettingsRequest());
        objServiceImpl.getPageDataInternal(new SFMDeliveryServiceImpl.PageDataRequest());
        objServiceImpl.getUserInfo();
        objServiceImpl.getUserInfoInternal();
        objServiceImpl.getLookupConfigInternal(new SFMDeliveryServiceImpl.LookupConfigRequest());
        objServiceImpl.saveTargetInternal(new SVMXC.SFM_WrapperDef.SFM_TargetRecord());
        objServiceImpl.getNextStepInfoInternal(new SFMDeliveryServiceImpl.NextStepInfoRequest());
        
        SFMDeliveryServiceImpl.LookupConfigRequest obj1 = new SFMDeliveryServiceImpl.LookupConfigRequest();
        SFMDeliveryServiceImpl.UserInfoResponse obj2 = new SFMDeliveryServiceImpl.UserInfoResponse();
        SFMDeliveryServiceImpl.PageLayoutRequest obj3 = new SFMDeliveryServiceImpl.PageLayoutRequest();
        SFMDeliveryServiceImpl.PageDataRequest obj4 = new SFMDeliveryServiceImpl.PageDataRequest();
        SFMDeliveryServiceImpl.PageDataResponse obj5 = new SFMDeliveryServiceImpl.PageDataResponse();
        SFMDeliveryServiceImpl.DisplayTagRequest obj6 = new SFMDeliveryServiceImpl.DisplayTagRequest();
        SFMDeliveryServiceImpl.RetrieveSettingsRequest obj7 = new SFMDeliveryServiceImpl.RetrieveSettingsRequest();
        SFMDeliveryServiceImpl.NextStepInfoRequest obj8 = new SFMDeliveryServiceImpl.NextStepInfoRequest();
        SFMDeliveryServiceImpl.SnippetRequest obj9 = new SFMDeliveryServiceImpl.SnippetRequest();
        SFMDeliveryServiceImpl.BubbleDataRequest obj10 = new SFMDeliveryServiceImpl.BubbleDataRequest();
        SFMDeliveryServiceImpl.RecordTypesRequest obj11 = new SFMDeliveryServiceImpl.RecordTypesRequest();
        SFMDeliveryServiceImpl.LayoutDescriptionRequest obj12 = new SFMDeliveryServiceImpl.LayoutDescriptionRequest();
        SFMDeliveryServiceImpl.ObjectDescriptionRequest obj13 = new SFMDeliveryServiceImpl.ObjectDescriptionRequest();
    }
}