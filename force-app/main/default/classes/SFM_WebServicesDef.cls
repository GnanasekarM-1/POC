global with sharing class SFM_WebServicesDef 
{
    SVMXC.SFM_WrapperDef pmaxwrapp = new SVMXC.SFM_WrapperDef();
    public SFM_WebServicesDef(){
        
    }
    public class SVMXException extends Exception {}
    
    //Webservice Method to perform AutoEntitlement on Work Order Added by Nidhi BAC-5144
    webservice static SVMXC.SFM_WrapperDef.SFM_PageData updateWoAfterSave(SFM_WrapperDef.SFM_TargetRecord request) 
    {
        WORD_AutoEntitlement  performEntitlement = new WORD_AutoEntitlement();
        return performEntitlement.updateWoAfterSave(request);
    }
    
    //Webservice method to get only data..
    webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_GetData_WS(SFM_WrapperDef.SFM_Request_PageUI PmaxReqPageUI)
    {
        try
        {
            SVMXC.SFM_GetData getdata = new SVMXC.SFM_GetData();
            return getdata.SFM_getData(PmaxReqPageUI);
        }
        catch(Exception ex)
        {
            throw new SFM_WrapperDef.PMaxException(ex); 
        }   
    }
    //Webservice method to return the pagedata....
    webservice static SFM_WrapperDef.SFM_PageData SFM_buildPageData_WS(SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
        SVMXC.SFM_BuildPageData buildpagedata = new SVMXC.SFM_BuildPageData();
        return buildpagedata.SFM_buildPageData(sfmtargetrec);
    }
    
    //Webservice Method for getting the PageLayout....
    Webservice static SFM_WrapperDef.SFM_Response_PageUI SFM_getPageLayout_WS(SFM_WrapperDef.SFM_Request_PageUI PmaxReqPageUI)
    {
        system.debug('amar'+system.now());
        try
        {
            SVMXC.SFM_getPageLayout pagelayout = new SVMXC.SFM_getPageLayout();  
            return pagelayout.SFM_GetPageLayout(PmaxReqPageUI);
        }   
        catch(Exception ex)
        {
            throw new SFM_WrapperDef.PMaxException(ex); 
        }
    }
    //Webservice Method to save the PageLayout....
    webservice static SFM_WrapperDef.SFM_Response SFM_SavePageLayout_WS(SFM_WrapperDef.SFM_Request_PageUI PmaxReqPageUI)
    {
        try
        { 
            SVMXC.SFM_savePageLayout pagelayout = new SVMXC.SFM_savePageLayout();
            return pagelayout.SFM_SavePageLayout(PmaxReqPageUI);
        }
        catch(Exception ex)
        {
            throw new SFM_WrapperDef.PMaxException(ex); 
        }       
    }
    //Recreate Pagelayout
    webservice static SFM_WrapperDef.SFM_Response SFM_RecreatePageLayout_WS(SFM_WrapperDef.SFM_Request_PageUI PmaxReqPageUI)
    {
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();       
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new  SVMXC.SFM_WrapperDef.SFM_StringMap();
        SVMXC.SFM_deletePageLayout deletepagelayout = new SVMXC.SFM_deletePageLayout();
        SVMXC.SFM_savePageLayout pagelayout = new SVMXC.SFM_savePageLayout();
        SFM_WrapperDef.SFM_Request Prequest = PmaxReqPageUI.request;
        
        stringMap.key='RECREATE';
        stringMap.value='true';
        Prequest.stringMap.add(stringMap);
        Savepoint sp;
        
        system.debug('Processing SFM_RecreatePageLayout_WS request.'+ PmaxReqPageUI);
        
        try
        {
            sp = Database.setSavepoint(); 
            
            if(deletepagelayout.SFM_DeletePageLayout(Prequest).success != true) {
                throw new SVMXException(system.label.SFM001_TAG145);
            } else {
                response = pagelayout.SFM_SavePageLayout(PmaxReqPageUI);    
            }
            system.debug('Processing SFM_RecreatePageLayout_WS request complete.');
        }
        catch(SVMXException ex){
            Database.rollback(sp);
            response.success = false;
            response.message = ex.getmessage();
        }
        catch(exception ex){
            Database.rollback(sp);
            response.success = false;
            response.message = 'Record Not Recreated' + ex.getmessage() ;
        }       
        return response;
    }
    //Webservice Method to delete the PageLayouts....
    webservice static SFM_WrapperDef.SFM_Response SFM_deletePageLayout_WS(SFM_WrapperDef.SFM_Request Prequest)
    {
        SVMXC.SFM_deletePageLayout deletepagelayout = new SVMXC.SFM_deletePageLayout();
        return deletepagelayout.SFM_DeletePageLayout(Prequest);
    }
    
    //webservice Method will return all Pagelayouts..
    webservice static SFM_WrapperDef.SFM_Response_PageList SFM_getPageLayoutList_WS(SFM_WrapperDef.SFM_Request_PageList PmaxReqPageLst)
    {
         try{
         SVMXC.SFM_getListOfPageLayout lstpagelayout = new SVMXC.SFM_getListOfPageLayout();
         return lstpagelayout.getListOfPageLayout(PmaxReqPageLst);
         
         }catch (Exception ex){
            throw new SFM_WrapperDef.PMaxException(ex.getMessage());
        }
    }
    
    
    //Webservice Method to save Section Entry Criteria ..
    webservice static SFM_WrapperDef.SFM_Response SFM_SaveSectionEntryCriteria_WS(SVMXC.SFM_WrapperDef.SFM_Request request) 
    {
        SVMXC.SFM_savePageLayout  pagelayout = new SVMXC.SFM_savePageLayout();
        return pagelayout.SFM_SaveSectionEntryCriteria(request);
    }
    webservice static SFM_WrapperDef.SFM_Response SFM_GetSectionEntryCriteriaRuleIds_WS(SFM_WrapperDef.SFM_Request request)
    {
        SFM_GetPageLayout objSectionEntryCriteriaRule = new SFM_GetPageLayout();
        return objSectionEntryCriteriaRule .SFM_GetSectionEntryCriteriaRuleIds(request);
    }
    
    webservice static SFM_WrapperDef.SFM_Response SFM_GetSectionEntryCriteriaRuleInfo_WS(SFM_WrapperDef.SFM_Request request)
    {
        SFM_GetPageLayout objSectionEntryCriteriaRule = new SFM_GetPageLayout();
        return objSectionEntryCriteriaRule.SFM_GetSectionEntryCriteriaRuleInfo(request);
    }
    
    //Webservice to get all  Section exit Criteria associated with the given SFM Process ..
     webservice static SFM_WrapperDef.SFM_Response SFM_GetSectionExitCriteriaRuleInfo_WS(SFM_WrapperDef.SFM_Request request)
    {
        SFM_GetPageLayout objSectionExitCriteriaRule = new SFM_GetPageLayout();
        return objSectionExitCriteriaRule.SFM_GetSectionExitCriteriaRuleInfo(request);
    }  
    
       //Webservice Method to save Section Info Criteria ..
    webservice static SFM_WrapperDef.SFM_Response_PageUI SFM_SaveSectionInfo_WS(SFM_WrapperDef.SFM_Request_PageUI PmaxReqPageUI)
    {
        
            SVMXC.SFM_savePageLayout pagelayout = new SVMXC.SFM_savePageLayout();
            return pagelayout.SFM_SaveSectionInfo(PmaxReqPageUI);
        
    }
    
    //Webservice Method to get the List of processes....
    Webservice static SFM_WrapperDef.SFM_Response_ProcessNode SFM_getListOfProcesses_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        try{
            SVMXC.SFM_getListOfProcesses getlistofprocesses = new SVMXC.SFM_getListOfProcesses();
            return getlistofprocesses.GetAllProcesses(prequest);
        }catch (Exception ex){
            throw new SFM_WrapperDef.PMaxException(ex.getMessage());
        }
    }
    
    //Webservice Method to get the Count() of processes using the page layout....
    Webservice static SFM_WrapperDef.SFM_Response SFM_getCountOfProcesses_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        try{
            SVMXC.SFM_GetListOfProcesses countOfProcesses = new SVMXC.SFM_GetListOfProcesses();
            return countOfProcesses.getCountOfProcesses(prequest);
        }catch (Exception ex){
            throw new SFM_WrapperDef.PMaxException(ex.getMessage());
        }
    }
    
    
        //Webservice Method to get the List of processes....
    Webservice static SFM_WrapperDef.SFM_Response_ProcessNodeInfo SFM_getProcessInfo_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        try{
            SVMXC.SFM_getProcessInfo getprocesses = new SVMXC.SFM_getProcessInfo();
            return getprocesses.getProcessInfo(prequest);
        }catch (Exception ex){
            throw new SFM_WrapperDef.PMaxException(ex);
        }
    }
    //Webservice Method to activate the process..
   /* Webservice static SFM_WrapperDef.SFM_Response SFM_activateProcess_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        try{ 
            SVMXC.SFM_activateProcess activateprocess = new SVMXC.SFM_activateProcess();
            return activateprocess.ActivateProcesses(prequest);
        }catch (Exception ex){
            throw new SFM_WrapperDef.PMaxException(ex);
        }
    }*/
    //Webservice Method to Save the process..
    Webservice static SFM_WrapperDef.SFM_Response SFM_saveProcess_WS(SFM_WrapperDef.SFM_Request_ProcessNodeInfo prequest)
    {
        try{
            SVMXC.SFM_saveProcess saveProcess = new SVMXC.SFM_saveProcess();
            return saveProcess.saveProcess(prequest);
        }catch (Exception ex){
            throw new SFM_WrapperDef.PMaxException(ex);
        }
    }
    //Webservice Method to delete the Processes.....
    Webservice static SFM_WrapperDef.SFM_Response SFM_deleteProcesses_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        try{
            SVMXC.SFM_deleteProcesses deleteprocess = new SVMXC.SFM_deleteProcesses();
            return deleteprocess.DeleteProcesses(prequest);
        }catch (Exception ex){
            throw new SFM_WrapperDef.PMaxException(ex);
        }
    }

    //Webservice Method to Clone the process..
    Webservice static SFM_WrapperDef.SFM_Response SFM_cloneProcess_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        try{
            SVMXC.SFM_cloneProcess cloneProcess = new SVMXC.SFM_cloneProcess();
            return cloneProcess.cloneProcess(prequest);
        }catch (Exception ex){
            throw new SFM_WrapperDef.PMaxException(ex);
        }
    }
    Webservice static SFM_WrapperDef.SFM_Response_Expression SFM_getNamedExpressionList_WS(SFM_WrapperDef.SFM_Request ExpReq)
    {
        SVMXC.SFM_getNamedExpressionList Expression = new SVMXC.SFM_getNamedExpressionList();
        return Expression.SFM_getNamedExpressionList(ExpReq);
    }
    //Added for BAC-4329
    Webservice static SFM_WrapperDef.SFM_Response SFM_getCustomActionList_WS(SFM_WrapperDef.SFM_Request reqCustomAction)
    {
        SVMXC.SFM_getNamedExpressionList cActionExpression = new SVMXC.SFM_getNamedExpressionList();
        return cActionExpression.SFM_getCustomActionList(reqCustomAction);
    } 
    //Webservice Method to save the list of expression....
    Webservice static SFM_WrapperDef.SFM_Response SFM_saveExpression_WS(SFM_WrapperDef.SFM_Request_Expression ExpReq)
    {
        SVMXC.SFM_saveExpression oSaveExp = new SVMXC.SFM_saveExpression();
        return oSaveExp.SFM_saveExpression(ExpReq);
    }
    Webservice static SFM_WrapperDef.SFM_Response SFM_saveAsExpression_WS(SFM_WrapperDef.SFM_Request_Expression ExpReq)
    {
        SVMXC.SFM_saveAsExpression oSaveExp = new SVMXC.SFM_saveAsExpression();
        return oSaveExp.SFM_saveAsExpression(ExpReq);
    }
    
    //Webservice Method to delete the list of expression....
    Webservice static SFM_WrapperDef.SFM_Response SFM_deleteExpression_WS(SFM_WrapperDef.SFM_Request ExpReq)
    {
        SVMXC.SFM_deleteExpression oDelExp=new SVMXC.SFM_deleteExpression();
        return oDelExp.SFM_deleteExpression(ExpReq);
    }
    
    //webservice method will return parent object list...
    Webservice static SFM_WrapperDef.SFM_Response SFM_getParentObjectList_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_getGlobalObjectList obj  = new SVMXC.SFM_getGlobalObjectList(); 
        return obj.GetParetnObjects(prequest);
    }
    //webservice method will return Child object list...
    Webservice static SFM_WrapperDef.SFM_Response SFM_getChildObjectList_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_getGlobalObjectList obj  = new SVMXC.SFM_getGlobalObjectList();
        return obj.GetChildObjects(prequest);
    }
    //Webservice Method to get all object mapping list....
    Webservice static SFM_WrapperDef.SFM_Response_ObjectMapLIst SFM_getAllObjectMapping_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_getObjectMapping getObjMapping = new SVMXC.SFM_getObjectMapping();
        return getObjMapping.SFM_getAllObjectMap(prequest);
    }
    
    //Webservice Method to get the field mapping with suggestions....
    Webservice static SFM_WrapperDef.SFM_Response_ObjectMap SFM_getObjectMapping_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_getObjectMapping getFieldMapping = new SVMXC.SFM_getObjectMapping();
        return getFieldMapping.getDefaultFieldmapping(prequest);
    }
    //Webservice Method to save all object map....
    Webservice static SFM_WrapperDef.SFM_Response SFM_saveObjectMapping_WS(SFM_WrapperDef.SFM_Request_ObjectMap ObjReq)
    {
        
        SVMXC.SFM_saveObjectMapping oSaveObj = new SVMXC.SFM_saveObjectMapping();
        return oSaveObj.SFM_saveObjectMapping(ObjReq);
    }
    //Webservice Method to save all object map....
    Webservice static SFM_WrapperDef.SFM_Response SFM_saveAsObjectMapping_WS(SFM_WrapperDef.SFM_Request ObjReq)
    {
        //SVMXC.SFM_saveAsObjectMapping oCloneObj = new SVMXC.SFM_saveAsObjectMapping();
        //return oCloneObj.saveAsObjectMappingInfo(ObjReq);
        return null;
    }
     Webservice static SFM_WrapperDef.SFM_Response SFM_saveAsObjectMapping2_WS(SFM_WrapperDef.SFM_Request_ObjectMap ObjReq)
    {
        SVMXC.SFM_saveAsObjectMapping oCloneObj = new SVMXC.SFM_saveAsObjectMapping();
        return oCloneObj.saveAsObjectMappingInfo(ObjReq);
    }
    Webservice static SFM_WrapperDef.SFM_Response SFM_deleteObjectMapping_WS(SFM_WrapperDef.SFM_Request ObjReq)
    { 
        SVMXC.SFM_deleteObjectMapping oSaveObj = new SVMXC.SFM_deleteObjectMapping();
        return oSaveObj.SFM_deleteObjectMapping(ObjReq);
    }

    
    Webservice static SFM_WrapperDef.SFM_Response_ObjectFields SFM_getObjectFieldList_WS(SFM_WrapperDef.SFM_Request ObjReq)
    {
        SVMXC.SFM_getObjectFieldList fieldMap = new SVMXC.SFM_getObjectFieldList();
        return fieldMap.getObjectFieldList(ObjReq);
    }
    
    //Webservice Method to get Operators....
    Webservice static SFM_WrapperDef.SFM_Response SFM_GetOperators_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_getOperators getoperators = new SVMXC.SFM_getOperators();
        return getoperators.SFM_GetOperatorsList(prequest);
    }
    // Webservices call for Named Search
    Webservice static SFM_WrapperDef.SFM_Response_NamedSearch SFM_getAllNamedSearch_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_getAllNamedSearch getallnamedsearch = new SVMXC.SFM_getAllNamedSearch();
        return getallnamedsearch.getAllNamedSearch(prequest);
    }
    
    Webservice static SFM_WrapperDef.SFM_Response_NamedSearchInfo SFM_getNamedSearchInfo_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_getNamedSearchInfo getnamedsearch = new SVMXC.SFM_getNamedSearchInfo();
        return getnamedsearch.getNamedSearchInfo(prequest);
    }
    Webservice static SFM_WrapperDef.SFM_Response SFM_saveNamedSearch_WS(SFM_WrapperDef.SFM_Request_NamedSearchInfo request)
    {
        SVMXC.SFM_saveNamedSearch oSaveObj = new SVMXC.SFM_saveNamedSearch();
        return oSaveObj.saveNamedSearch(request);
    }
    Webservice static SFM_WrapperDef.SFM_Response SFM_deleteNamedSearch_WS(SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_deleteNamedSearch odelObj = new SVMXC.SFM_deleteNamedSearch();
        return odelObj.deleteNamedSearch(request);
    }
    /*Webservice static SFM_WrapperDef.SFM_Response SFM_activateNamedSearch_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_activateNamedSearch activateNS = new SVMXC.SFM_activateNamedSearch();
        return activateNS.ActivateNamedSearch(prequest);
        
    }*/
    Webservice static SFM_WrapperDef.SFM_LookUpConfigData SFM_getLookUpConfigWithData_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_getLookUpConfigWithData GetLkD = new SVMXC.SFM_getLookUpConfigWithData();
        return GetLkD.getLookUpConfigWithData(prequest);
        
        
    }
    /*Webservice static SFM_WrapperDef.SFM_Response SFM_deactivateNamedSearch_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_deactivateNamedSearch deactivateNS = new SVMXC.SFM_deactivateNamedSearch();
        return deactivateNS.DeActivateNamedSearch(prequest);
        
    }*/
    Webservice static SFM_WrapperDef.SFM_Response SFM_saveAsNamedSearch_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_saveAsNamedSearch cloneNS = new SVMXC.SFM_saveAsNamedSearch();
        return cloneNS.cloneNamedSearchInfo(prequest);
        
    }
    
    //Webservice to Save TargetData....
    Webservice static SVMXC.SFM_WrapperDef.SFM_Response SFM_SaveTargetRecords_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
        system.debug(Logginglevel.INFO+'sfmtargetrec'+sfmtargetrec);
        SVMXC.SFM_saveTargetRecords SaveTarget = new SVMXC.SFM_saveTargetRecords();  
        return SaveTarget.SaveTargetRecords(sfmtargetrec);
    }
    Webservice static List<SVMXC.SFM_WrapperDef.SFM_PageDataSet> SFM_AddRecords_WS(SVMXC.SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_addRecords AddRecords = new SVMXC.SFM_addRecords();
        return AddRecords.getSFM_AddRecords(prequest);
    }
    //webservice to get all the recordtypes for an object or recordid
    Webservice static SVMXC.SFM_WrapperDef.SFM_Response_RecordTypes SFM_getRecordTypes_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_getRecordTypes getRT = new SVMXC.SFM_getRecordTypes(); 
        return getRT.getRecordTypes(prequest);
    }
    WebService static List<COMM_TagWebServices.TagsMap> SFM_Retrieve_Display_Tags_WS(String UserId,String SubModule)
    {
        list<COMM_TagWebServices.TagsMap> TagListValueM = new List<COMM_TagWebServices.TagsMap>();
        TagListValueM = COMM_TagWebServices.TagdataforSubmodule(SubModule);
        return TagListValueM;
    }
    //webservice to get the Bubble info
    webservice static  SVMXC.SFM_WrapperDef.SFM_BubbleWrapper SFM_GetdBubbleInfo_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_BuildBubbleInfo bubble = new SVMXC.SFM_BuildBubbleInfo();
        return bubble.getbubbleinfo(prequest);
    } 
   
   webservice static  SVMXC.SFM_WrapperDef.SFM_Response_ObjectMap SFM_getOnlyObjectMapping_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_GetObjectMapping objMap = new SVMXC.SFM_GetObjectMapping();
        return objMap.getOnlyObjectMapping(prequest);
    }
    
    webservice static SFM_WrapperDef.SFM_Response SFM_SchemaValidation_WS(SFM_WrapperDef.SFM_Request_IntegrityCheck prequest)
    {
        SVMXC.SFM_SchemaValidation validate = new SVMXC.SFM_SchemaValidation();
        return validate.doValidation(prequest);
    }
    
    webservice static SFM_WrapperDef.SFM_Request_IntegrityCheck SFM_getAllSourceUpdates_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_SchemaValidation sourceUpdates = new SVMXC.SFM_SchemaValidation();
        return sourceUpdates.getAllSourceUpdates(prequest);
    }
    
    webservice static List<SFM_WrapperDef.SFM_Response_NamedSearchInfo> SFM_getAllNamedSearchInfo_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_SchemaValidation namedSearch = new SVMXC.SFM_SchemaValidation();
        return namedSearch.getAllNamedSearchInfo(prequest);
    }
    
    Webservice static SFM_WrapperDef.SFM_Response SFM_DeployExpression_WS(SFM_WrapperDef.SFM_Request_Expression prequest)
    {
        SVMXC.SFM_DeployExpression deloyExpression = new SVMXC.SFM_DeployExpression();
        return deloyExpression.SFM_DeployExpression(prequest);
    }
    
    Webservice static SFM_WrapperDef.SFM_Response SFM_DeployMapping_WS(SFM_WrapperDef.SFM_Request_ObjectMap prequest)
    {
        SVMXC.SFM_DeployMapping deloyExpression = new SVMXC.SFM_DeployMapping();
        return deloyExpression.SFM_DeployMapping(prequest);
    }
    
    Webservice static SFM_WrapperDef.SFM_Response SFM_DeployNamedSearch_WS(SFM_WrapperDef.SFM_Request_NamedSearchInfo prequest)
    {
        SVMXC.SFM_DeployNamedSearch deloyExpression = new SVMXC.SFM_DeployNamedSearch();
        return deloyExpression.SFM_DeployNamedSearch(prequest);
    }
    
    Webservice static SFM_WrapperDef.SFM_Response SFM_DeployPage_WS(SFM_WrapperDef.SFM_Request_PageUI prequest)
    {
        SVMXC.SFM_DeployPage deloyPage = new SVMXC.SFM_DeployPage();
        return deloyPage.SFM_DeployPage(prequest);
    }
    
    Webservice static SFM_WrapperDef.SFM_Response SFM_DeployServiceFlow_WS(SFM_WrapperDef.SFM_Request_ProcessNodeInfo prequest)
    {
        SVMXC.SFM_DeployServiceFlow deloyProcess = new SVMXC.SFM_DeployServiceFlow();
        return deloyProcess.SFM_DeployProcess(prequest);
    }
    
    Webservice static List<COMM_Webservices.KeyValue> SVMX_GetSvmxVersion(List<COMM_Webservices.KeyValue> prequest)
    {
        return SVMXC.COMM_Webservices.SVMX_GetSvmxVersion(prequest);
    }
    //Webservice method to clone page without commiting to database
    Webservice static SVMXC.SFM_WrapperDef.SFM_Response_ProcessNodeInfo SFM_cloneProcessInMemory_WS(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_WrapperDef.SFM_StringMap StringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        StringMap.key = 'INMEMORY';
        request.stringMap.add(StringMap);
        SVMXC.SFM_cloneProcess cloneProcess = new SVMXC.SFM_cloneProcess();
        cloneProcess.cloneProcess(request);
        return cloneProcess.ProcessNodeInfo;
    }
    Webservice static SVMXC.SFM_WrapperDef.SFM_Response_PageUI SFM_clonePageInMemory_WS(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_ClonePageLayout clonePage = new SVMXC.SFM_ClonePageLayout();
        return clonePage.clonePageLayout(request);
    }
    //Webservices for SFM Output Doc Designer.
    Webservice static SVMXC.SFM_WrapperDef.SFM_Response SFM_GetDocTemplateInfo_WS(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        return docTemp.SFM_GetDocTemplateInfo(request);
    }
    Webservice static SVMXC.SFM_WrapperDef.SFM_Response SFM_GetListOfDocTemplates_WS(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        return docTemp.SFM_GetListOfDocTemplates(request);
    }
    Webservice static SVMXC.SFM_WrapperDef.SFM_Response SFM_DeleteDocTemplate_WS(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        return docTemp.SFM_DeleteDocTemplate(request);
    }
    Webservice static SVMXC.SFM_WrapperDef.SFM_Response SFM_SaveDocTemplate_WS(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        return docTemp.SFM_SaveDocTemplate(request);
    }
    Webservice static SVMXC.SFM_WrapperDef.SFM_Response SFM_CloneDocTemplate_WS(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        response = docTemp.SFM_GetDocTemplateInfo(request);
        
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        stringMap.key = 'SAVETYPE';
        stringMap.value = 'INMEMORYCLONE';
        request.stringMap.add(stringMap);
        request.docTemplate = response.docTemplate;
        
        return docTemp.SFM_SaveDocTemplate(request);
         
    }
    Webservice static SVMXC.SFM_WrapperDef.SFM_Response SFM_GetFunctions_WS(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        return docTemp.SFM_GetFunctions(request);
    }
    Webservice static SVMXC.SFM_WrapperDef.SFM_Response SFM_GetDefaultOPDOCTemplate_WS(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        return docTemp.SFM_GetDefaultOPDOCTemplate(request);
    }
    //Field set 
    webservice static list<SVMXC.SFM_WrapperDef.FieldsetDefinition> SFM_getFieldSetDefinition_WS(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_FieldSetUtils fieldSetUtils = new SVMXC.SFM_FieldSetUtils();
        return fieldSetUtils.SFM_getFieldSetDefinition(request);
    }
    webservice static SVMXC.SFM_WrapperDef.SFM_Response SFM_GetAvailableSortinhFields_WS(SVMXC.SFM_WrapperDef.SFM_Request request){
        set<String> setObject = new set<String>();
        for(Integer i = 0;i<request.stringMap.size();i++){
            setObject.add(request.stringMap[i].value);
        } 
        SVMXC.SFM_GetObjectFieldList getField = new SVMXC.SFM_GetObjectFieldList();
        return getField.getSortableFields(setObject);
    } 
    
    webservice static SFM_WrapperDef.SFM_Response SFM_GetBizRuleIds_WS(SFM_WrapperDef.SFM_Request request)
    {
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        return objBizRuleUtils.SFM_GetBizRuleIds(request);
    }
    
    webservice static SFM_WrapperDef.SFM_Response SFM_GetBizRuleInfo_WS(SFM_WrapperDef.SFM_Request request)
    {
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        return objBizRuleUtils.SFM_GetBizRuleInfo(request);
    }
    
    webservice static SFM_WrapperDef.SFM_Response SFM_SaveBizRule_WS(SFM_WrapperDef.SFM_Request request)
    {
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        return objBizRuleUtils.SFM_SaveBizRules(request);
    }
    
    webservice static SFM_WrapperDef.SFM_Response SFM_DeleteBizRule_WS(SFM_WrapperDef.SFM_Request request)
    {
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        return objBizRuleUtils.SFM_DeleteBizRules(request);
    }
    
    webservice static SFM_WrapperDef.SFM_Response SFM_GetBizRuleProcesses_WS(SFM_WrapperDef.SFM_Request request)
    {
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        return objBizRuleUtils.SFM_GetBizRuleProcesses(request);
    }
    
    webservice static SFM_WrapperDef.SFM_Response SFM_GetFieldUpdateRuleIds(SFM_WrapperDef.SFM_Request request)
    {
        SFM_FieldUpdateRuleUtils sfmFieldUpdateRule = new SFM_FieldUpdateRuleUtils();
        return sfmFieldUpdateRule.SFM_GetFieldUpdateRuleIds(request);
    }
    
    webservice static SFM_WrapperDef.SFM_Response SFM_GetFieldUpdateRuleInfo(SFM_WrapperDef.SFM_Request request)
    {
        SFM_FieldUpdateRuleUtils sfmFieldUpdateRule = new SFM_FieldUpdateRuleUtils();
        return sfmFieldUpdateRule.SFM_GetFieldUpdateRuleInfo(request);
    }
    
    webservice static SFM_WrapperDef.SFM_Response SFM_SaveFieldUpdateRules(SFM_WrapperDef.SFM_Request request)
    {
        SFM_FieldUpdateRuleUtils sfmFieldUpdateRule = new SFM_FieldUpdateRuleUtils();
        return sfmFieldUpdateRule.SFM_SaveFieldUpdateRules(request);
    }
    
    Webservice static SFM_WrapperDef.SFM_Response SFM_GetExpressionOperators_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_GetOperators objGetOperatorUtil = new SVMXC.SFM_GetOperators();
        return objGetOperatorUtil.SFM_GetExpressionOperators(prequest);
    }
    
    Webservice static SFM_WrapperDef.SFM_Response SFM_GetConstants_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_GetOperators objGetOperatorUtil = new SVMXC.SFM_GetOperators();
        return objGetOperatorUtil.SFM_GetConstants(prequest);
    }
    
    //Webservice to get available Multi-Source Process.
    Webservice static SFM_WrapperDef.SFM_Response SFM_GetAvailableMultiSourceProcesses_WS(SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_GetAvailableMultiSourceProcesses  objGetMultiSourceProcess = new SVMXC.SFM_GetAvailableMultiSourceProcesses ();
        return objGetMultiSourceProcess.getAvailableMultiSourceProcesses(request);
    }
    
    //added for Smart Object
    //Webservice Method to get the describe of object....
    Webservice static List<SmartObject.DescribeSmartObjectResult> SFM_DescribeSmartObject_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        try{
            SmartObject.SmartObjectType objSmartObjectType = new SmartObject.SmartObjectType();
            String strObjectName;
            List<SmartObject.DescribeSmartObjectResult> lstDescribeSmartObjectResult = new List<SmartObject.DescribeSmartObjectResult>();
            List<SFM_WrapperDef.SFM_StringMap> StringMaplst = new List<SFM_WrapperDef.SFM_StringMap>();
            if(prequest.stringMap != null){
                StringMaplst = prequest.stringMap;
                for(Integer i = 0;i<StringMaplst.size();i++){
                    strObjectName = StringMaplst[i].key;
                    lstDescribeSmartObjectResult.add(objSmartObjectType.getDescribe(strObjectName));
                }
            }
            System.debug('objDescribeSmartObjectResult_WS : '+lstDescribeSmartObjectResult);
            return lstDescribeSmartObjectResult;
        }catch (Exception ex){
            throw new SFM_WrapperDef.PMaxException(ex.getMessage());
        }
    }
    //Webservice to get available API configuration
    Webservice static SFM_WrapperDef.SFM_Response SFM_GetAPIConfiguration_WS(SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_GetAPIConfiguration  objGetAPIConfiguration = new SVMXC.SFM_GetAPIConfiguration ();
        return objGetAPIConfiguration.getAPIConfiguration(request);
    }
    
    //Webservice to get list of All Question
    Webservice static SFM_WrapperDef.SFM_Response SFM_GetListOfQuestion_WS(SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_QuestionBankUtils  objQuestionBankUtils = new SVMXC.SFM_QuestionBankUtils();
        return objQuestionBankUtils.SFM_GetListOfQuestion(request);
    }
    
    //Webservice to get QuestionInfo of list of questions OR single question
    Webservice static SFM_WrapperDef.SFM_Response SFM_GetQuestionInfo_WS(SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_QuestionBankUtils  objQuestionBankUtils = new SVMXC.SFM_QuestionBankUtils();
        return objQuestionBankUtils.SFM_GetQuestionInfo(request);
    }
    
    //Webservice to delete question which are not associated with any process
    Webservice static SFM_WrapperDef.SFM_Response SFM_DeleteQuestion_WS(SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_QuestionBankUtils  objQuestionBankUtils = new SVMXC.SFM_QuestionBankUtils();
        return objQuestionBankUtils.SFM_DeleteQuestion(request);
    }
    
    //Webservice to Save OR SaveAs question and question response
    Webservice static SFM_WrapperDef.SFM_Response SFM_SaveQuestionInfo_WS(SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_QuestionBankUtils  objQuestionBankUtils = new SVMXC.SFM_QuestionBankUtils();
        return objQuestionBankUtils.SFM_SaveQuestionInfo(request);
    }
    
    //Webservice to get list of ResponseSet
    Webservice static SFM_WrapperDef.SFM_Response SFM_GetListOfResponseSet_WS(SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_QuestionBankUtils  objQuestionBankUtils = new SVMXC.SFM_QuestionBankUtils();
        return objQuestionBankUtils.SFM_GetListOfResponseSet(request);
    }

    
    Webservice static SFM_WrapperDef.SFM_Response SFM_GetQuestionDetailsOfProcess(SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_QuestionBankUtils objQuestionBankUtils = new SVMXC.SFM_QuestionBankUtils();
        return objQuestionBankUtils.SFM_GetQuestionDetailsOfProcess(request);
    }    
    
   Webservice static SFM_WrapperDef.SFM_Response SFM_SaveChecklist_QuestionInfo_WS(SFM_WrapperDef.SFM_Request request) 
    {
        SVMXC.SFM_QuestionBankUtils questionBankUtils = new SVMXC.SFM_QuestionBankUtils();
        return questionBankUtils.SFM_SaveChecklist_QuestionInfo(request);          
    }
    Webservice static SFM_WrapperDef.SFM_Response SFM_GetListOfChecklist_WS(SFM_WrapperDef.SFM_Request request) 
    {
        SVMXC.SFM_CheckListUtils checklistUtils = new SVMXC.SFM_CheckListUtils();
        return checklistUtils.SFM_GetListOfChecklist(request);          
    }
    
    //Webservice to navigating back to the source record on click of some button.
    webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_NavigateBackToSourceRecord_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord request){
        String strRecordId = '';
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap =  request.stringMap;
        if(lstStringMap != null && lstStringMap.size() > 0){
            for(Integer i =0;i<lstStringMap.size();i++){
                if(!lstStringMap[i].key.equals(null) && lstStringMap[i].key.equals('SVMX_recordId') && lstStringMap[i].value != null)
                    strRecordId = lstStringMap[i].value;
            }
        }
        SVMXC.SFM_WrapperDef.SFM_PageData objPageDataResponse = new SVMXC.SFM_WrapperDef.SFM_PageData();
        objPageDataResponse.response.success = true;        
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('NAVIGATE_TO',strRecordId));
        objPageDataResponse.response.stringMap = stringMap;
        return objPageDataResponse;
    }
    
/*Added 27-Mar-2017:Checklist:ST-57:Sourabh
  Description:webservice method to return exit criteria operators for all valid data types
*/
    Webservice static SFM_WrapperDef.SFM_Response SFM_GetChecklistExitOperators_WS(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_GetOperators objGetOperatorUtil = new SVMXC.SFM_GetOperators();
        return objGetOperatorUtil.SFM_GetChecklistExitOperators(prequest);
    }
}