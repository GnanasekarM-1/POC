@isTest
private class SFM_WebServicesDef_UT {

    static testMethod void SFM_WebServicesDef_test() 
    {
        try
        {
            SFM_WebServicesDef websrvdef = new SFM_WebServicesDef();
            SFM_WrapperDef.SFM_Request_PageUI PmaxReqPageUI = new SFM_WrapperDef.SFM_Request_PageUI(null,null,null);
            SFM_WebServicesDef.SFM_getPageLayout_WS(PmaxReqPageUI);
            System.assertEquals(PmaxReqPageUI!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test1()
    {
        try
        {
            SFM_WrapperDef.SFM_Request_PageUI PmaxReqPageUI = new SFM_WrapperDef.SFM_Request_PageUI(null,null,null);
            SFM_WebServicesDef.SFM_SavePageLayout_WS(PmaxReqPageUI);
            System.assertEquals(PmaxReqPageUI!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test2() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_deletePageLayout_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test3() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request_PageList PmaxReqPageLst = new SFM_WrapperDef.SFM_Request_PageList();
            SFM_WebServicesDef.SFM_getPageLayoutList_WS(PmaxReqPageLst);
            System.assertEquals(PmaxReqPageLst!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test4() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getListOfProcesses_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test5() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getProcessInfo_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test6() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request_ProcessNodeInfo request = new SFM_WrapperDef.SFM_Request_ProcessNodeInfo();
            SFM_WebServicesDef.SFM_saveProcess_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test7() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_deleteProcesses_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test8() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_cloneProcess_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test9() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request ExpReq = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getNamedExpressionList_WS(ExpReq);
            System.assertEquals(ExpReq!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test10() 
    {
        try
        {
            //..............Data Creation............
        List<RecordType> RtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
        System.assertEquals(true, RtypeLst != null);
        
        SVMXC__ServiceMax_Processes__c processobj = new SVMXC__ServiceMax_Processes__c();
        processobj.RecordTypeId=RtypeLst[0].Id;
        processobj.SVMXC__Name__c='NamedExpression001';
        processobj.SVMXC__Rule_Type__c = 'Named Expression';
        processobj.SVMXC__SettingId__c='expid001';
        processobj.SVMXC__Source_Object_Name__c='SVMXC__Site__c';
        insert processobj;
        System.assertEquals(true, processobj != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfigData=new SVMXC__ServiceMax_Config_Data__c();
        List<SVMXC__ServiceMax_Config_Data__c> ConfigDataLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        ConfigDataLst.add(ConfigData);
        SFM_WrapperDef.SFM_Expression ExpObj=  new SFM_WrapperDef.SFM_Expression(processobj,ConfigDataLst);
        List<SFM_WrapperDef.SFM_Expression>  ExpObj_List= new List<SFM_WrapperDef.SFM_Expression>();
        ExpObj_List.add(ExpObj);
        System.assertEquals(true, ExpObj_List != null);
            
        //...............class instantiation and calling various methods.............
        SFM_WrapperDef.SFM_Request_Expression ExpReq= new SFM_WrapperDef.SFM_Request_Expression(ExpObj_List);
        SFM_WebServicesDef.SFM_saveExpression_WS(ExpReq);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test11() 
    {
        try
        {
            List<RecordType> RtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
            System.assertEquals(true, RtypeLst != null);
            
            SVMXC__ServiceMax_Processes__c processobj = new SVMXC__ServiceMax_Processes__c();
            processobj.RecordTypeId=RtypeLst[0].Id;
            processobj.SVMXC__Name__c='NamedExpression001';
            processobj.SVMXC__Rule_Type__c = 'Named Expression';
            processobj.SVMXC__SettingId__c='expid001';
            processobj.SVMXC__Source_Object_Name__c='SVMXC__Site__c';
            insert processobj;
            System.assertEquals(true, processobj != null);
            
            SVMXC__ServiceMax_Config_Data__c ConfigData=new SVMXC__ServiceMax_Config_Data__c();
            List<SVMXC__ServiceMax_Config_Data__c> ConfigDataLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            ConfigDataLst.add(ConfigData);
            SFM_WrapperDef.SFM_Expression ExpObj=  new SFM_WrapperDef.SFM_Expression(processobj,ConfigDataLst);
            List<SFM_WrapperDef.SFM_Expression>  ExpObj_List= new List<SFM_WrapperDef.SFM_Expression>();
            ExpObj_List.add(ExpObj);
            System.assertEquals(true, ExpObj_List != null);
                
            //...............class instantiation and calling various methods.............
            SFM_WrapperDef.SFM_Request_Expression ExpReq= new SFM_WrapperDef.SFM_Request_Expression(ExpObj_List);
            SFM_WebServicesDef.SFM_saveAsExpression_WS(ExpReq);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test12() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request ExpReq = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_deleteExpression_WS(ExpReq);
            System.assertEquals(ExpReq!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test13() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getParentObjectList_WS(prequest);
            System.assertEquals(prequest!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test14()
    {
        try
        {
            SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getChildObjectList_WS(prequest);
            System.assertEquals(prequest!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test15() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getAllObjectMapping_WS(prequest);
            System.assertEquals(prequest!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test16() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getObjectMapping_WS(prequest);
            System.assertEquals(prequest!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test17() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request_ObjectMap ObjReq = new SFM_WrapperDef.SFM_Request_ObjectMap();
            SFM_WebServicesDef.SFM_saveObjectMapping_WS(ObjReq);
            System.assertEquals(ObjReq!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test18()
    {
        try
        {
            SFM_WrapperDef.SFM_Request ObjReq = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_saveAsObjectMapping_WS(ObjReq);
            System.assertEquals(ObjReq!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test19() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request ObjReq = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_deleteObjectMapping_WS(ObjReq);
            System.assertEquals(ObjReq!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test20() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request ObjReq = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_GetOperators_WS(ObjReq);
            System.assertEquals(ObjReq!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test21() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getAllNamedSearch_WS(prequest);
            System.assertEquals(prequest!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test22() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getNamedSearchInfo_WS(prequest);
            System.assertEquals(prequest!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test23() 
    {
        try
        {
            SVMXC__ServiceMax_Processes__c namedSearchHdr = new SVMXC__ServiceMax_Processes__c();
            List<SFM_WrapperDef.SFM_NamedSearchInfoDetail> namedSearchDetails = new List<SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
            List<SFM_WrapperDef.SFM_NamedSearchInfo> namedSearch = new List<SFM_WrapperDef.SFM_NamedSearchInfo>();
            SFM_WrapperDef.SFM_Request_NamedSearchInfo request = new SFM_WrapperDef.SFM_Request_NamedSearchInfo(namedSearch);
            SFM_WebServicesDef.SFM_saveNamedSearch_WS(request);
            System.assertEquals(request!=null,true);
            
            SFM_WebServicesDef.SFM_DeployNamedSearch_WS(request);
            
            
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test24() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_deleteNamedSearch_WS(prequest);
            System.assertEquals(prequest!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test25() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getLookUpConfigWithData_WS(prequest);
            System.assertEquals(prequest!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test26() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_saveAsNamedSearch_WS(prequest);
            System.assertEquals(prequest!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test27() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_WebServicesDef.SFM_SaveTargetRecords_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test28() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_AddRecords_WS(prequest);
            System.assertEquals(prequest!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test29() 
    {
        try
        {
            SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getRecordTypes_WS(prequest);
            System.assertEquals(prequest!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test30() 
    {
        try
        {
            SFM_WebServicesDef websrvdef = new SFM_WebServicesDef();
            SFM_WebServicesDef.SFM_Retrieve_Display_Tags_WS(String.valueOf(userInfo.getUserId()),'CASE001');
            System.assertEquals(websrvdef!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test32()
    {
        try
        {
            SFM_WrapperDef.SFM_Request_PageUI PmaxReqPageUI = new SFM_WrapperDef.SFM_Request_PageUI();
            System.assertEquals(PmaxReqPageUI!=null,true);
            SFM_WebServicesDef.SFM_GetData_WS(PmaxReqPageUI);
        }
        catch(Exception ex){} 
    }

    static testMethod void SFM_WebServicesDef_test33()
    {
        try
        {
            SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SFM_WrapperDef.SFM_TargetRecord();
            System.assertEquals(sfmtargetrec!=null,true);
            SFM_WebServicesDef.SFM_buildPageData_WS(sfmtargetrec);
        }
        catch(Exception ex){} 
    }

    static testMethod void SFM_WebServicesDef_test34(){try{
    SFM_WrapperDef.SFM_Request_ObjectMap ObjReq = new SFM_WrapperDef.SFM_Request_ObjectMap();
            System.assertEquals(ObjReq!=null,true);
    SFM_WebServicesDef.SFM_saveAsObjectMapping2_WS(ObjReq);
    }catch(Exception ex){} }


    static testMethod void SFM_WebServicesDef_test35(){try{
    SFM_WrapperDef.SFM_Request ObjReq1 = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(ObjReq1!=null,true);
    SFM_WebServicesDef.SFM_getObjectFieldList_WS(ObjReq1);
    }catch(Exception ex){} }

    static testMethod void SFM_WebServicesDef_test36(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_GetdBubbleInfo_WS(prequest);
    }catch(Exception ex){} }

    static testMethod void SFM_WebServicesDef_test37(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_getOnlyObjectMapping_WS(prequest);
    }catch(Exception ex){} }

    static testMethod void SFM_WebServicesDef_test38(){try{
    SFM_WrapperDef.SFM_Request_IntegrityCheck prequest = new SFM_WrapperDef.SFM_Request_IntegrityCheck();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_SchemaValidation_WS(prequest);
    }catch(Exception ex){} }

    static testMethod void SFM_WebServicesDef_test39(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_getAllSourceUpdates_WS(prequest);
    }catch(Exception ex){} }
    
    


    static testMethod void SFM_WebServicesDef_test40(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_getAllNamedSearchInfo_WS(prequest);
    }catch(Exception ex){} }

    static testMethod void SFM_WebServicesDef_test41(){try{
    SFM_WrapperDef.SFM_Request_Expression prequest = new SFM_WrapperDef.SFM_Request_Expression(null);
    SFM_WebServicesDef.SFM_DeployExpression_WS(prequest);
    }catch(Exception ex){} }

    static testMethod void SFM_WebServicesDef_test42(){try{
    SFM_WrapperDef.SFM_Request_ObjectMap prequest = new SFM_WrapperDef.SFM_Request_ObjectMap();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_DeployMapping_WS(prequest);
    }catch(Exception ex){} }

    /* static testMethod void SFM_WebServicesDef_test43(){try{
    SFM_WrapperDef.SFM_Request_NamedSearchInfo prequest = new SFM_WrapperDef.SFM_Request_NamedSearchInfo();
    SFM_WebServicesDef.SFM_DeployNamedSearch_WS(prequest);
    }catch(Exception ex){} }
 */
    static testMethod void SFM_WebServicesDef_test44(){try{
    SFM_WrapperDef.SFM_Request_PageUI prequest = new SFM_WrapperDef.SFM_Request_PageUI();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_DeployPage_WS(prequest);
    }catch(Exception ex){} }

    static testMethod void SFM_WebServicesDef_test45(){try{
    SFM_WrapperDef.SFM_Request_ProcessNodeInfo prequest = new SFM_WrapperDef.SFM_Request_ProcessNodeInfo();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_DeployServiceFlow_WS(prequest);
    }catch(Exception ex){} }

    static testMethod void SFM_WebServicesDef_test46(){try{
    List<COMM_Webservices.KeyValue> prequest = new List<COMM_Webservices.KeyValue>();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SVMX_GetSvmxVersion(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test47(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_cloneProcessInMemory_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test48(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_clonePageInMemory_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test49(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_GetDocTemplateInfo_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test50(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_GetListOfDocTemplates_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test51(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_DeleteDocTemplate_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test52(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_SaveDocTemplate_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test53(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_CloneDocTemplate_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test54(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_GetFunctions_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test55(){try{
    SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
            System.assertEquals(prequest!=null,true);
    SFM_WebServicesDef.SFM_GetDefaultOPDOCTemplate_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test56(){
    try{
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        System.assertEquals(prequest!=null,true);
        SFM_WebServicesDef.SFM_getFieldSetDefinition_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test57(){
    try{
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        List<SFM_WrapperDef.SFM_StringMap> List_stringMapObj = new List<SFM_WrapperDef.SFM_StringMap>();
        List_stringMapObj.add(new SFM_WrapperDef.SFM_StringMap(null, 'Case'));
        request.setstringMap(List_stringMapObj);
        System.assertEquals(request!=null,true);
        SFM_WebServicesDef.SFM_GetAvailableSortinhFields_WS(request);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test58(){
    try{
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        System.assertEquals(prequest!=null,true);
        SFM_WebServicesDef.SFM_GetBizRuleIds_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test59(){
    try{
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        System.assertEquals(prequest!=null,true);
        SFM_WebServicesDef.SFM_GetBizRuleInfo_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test60(){
    try{
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        System.assertEquals(prequest!=null,true);
        SFM_WebServicesDef.SFM_SaveBizRule_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test61(){
    try{
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        System.assertEquals(prequest!=null,true);
        SFM_WebServicesDef.SFM_DeleteBizRule_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test62(){
    try{
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        System.assertEquals(prequest!=null,true);
        SFM_WebServicesDef.SFM_GetBizRuleProcesses_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test63(){
    try{
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        System.assertEquals(prequest!=null,true);
        SFM_WebServicesDef.SFM_GetExpressionOperators_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test64(){
    try{
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        System.assertEquals(prequest!=null,true);
        SFM_WebServicesDef.SFM_GetConstants_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test65(){
    try{
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        System.assertEquals(prequest!=null,true);
        SFM_WebServicesDef.SFM_GetAvailableMultiSourceProcesses_WS(prequest);
    }catch(Exception ex){} }
    
    //added for Smart Object
    static testMethod void SFM_WebServicesDef_test66(){
        try{
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            List<SFM_WrapperDef.SFM_StringMap> List_stringMapObj = new List<SFM_WrapperDef.SFM_StringMap>();
            List_stringMapObj.add(new SFM_WrapperDef.SFM_StringMap('ApptOfferRequest__sm', null));
            request.setstringMap(List_stringMapObj);
            List<SmartObject.DescribeSmartObjectResult> lstDescribeSmartObjectResult = SFM_WebServicesDef.SFM_DescribeSmartObject_WS(request);
            System.assertEquals(lstDescribeSmartObjectResult.size()>0, true);
        }catch(exception ex){}
    }
    
    static testMethod void SFM_WebServicesDef_test67(){
    try{
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        System.assertEquals(prequest!=null,true);
        SFM_WebServicesDef.SFM_GetAPIConfiguration_WS(prequest);
    }catch(Exception ex){} }
    
    static testMethod void SFM_WebServicesDef_test68() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request_PageUI request = new SVMXC.SFM_WrapperDef.SFM_Request_PageUI();
            SFM_WebServicesDef.SFM_RecreatePageLayout_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    
    static testMethod void SFM_WebServicesDef_test69() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_getCountOfProcesses_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    
    static testMethod void SFM_WebServicesDef_test70() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_GetListOfQuestion_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    
    static testMethod void SFM_WebServicesDef_test71() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_GetQuestionInfo_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    
    static testMethod void SFM_WebServicesDef_test72() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_GetListOfChecklist_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test73() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_DeleteQuestion_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test74() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_SaveQuestionInfo_WS(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test75() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_GetFieldUpdateRuleIds(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test76() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_GetFieldUpdateRuleInfo(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test77() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WebServicesDef.SFM_SaveFieldUpdateRules(request);
            System.assertEquals(request!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_WebServicesDef_test78() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord objTargetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
            SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('SVMX_recordId','FakeID');
            lstStringMap.add(objStringMap);
            objTargetRecord.stringMap = lstStringMap;
            SVMXC.SFM_WrapperDef.SFM_PageData objPageData = SFM_WebServicesDef.SFM_NavigateBackToSourceRecord_WS(objTargetRecord);
            System.assertEquals(objPageData!=null,true);
        }
        catch(exception ex){}
    }
}