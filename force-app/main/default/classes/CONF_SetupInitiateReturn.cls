public with sharing class CONF_SetupInitiateReturn
{
    //-------------------------------------- Variables and Getter-Setter Methods ------------------------------------------------------
    public boolean disabled{get;set;}
    public boolean Validate;
    public string selectedTab{get;set;}
    public string processName{get;set;}
    public string processID{get;set;}
    public string processDesc{get;set;}
    public string selectedCriteriaInitRet{get;set;}
    public boolean DisableEditLnkInitRet{get;set;}
    public string selectedCriteriaInitRetLine{get;set;}
    public boolean DisableEditLnkInitRetLine{get;set;}
    public boolean isPerformEntitle{get;set;}
    public boolean DisableEditLnkEntitle{get;set;}
    public string selectedCriteriaEntitle{get;set;}
    public boolean DisableEditLnkEntitleLine{get;set;}
    public string selectedCriteriaEntitleLine{get;set;}
    public boolean isRouteCalc{get;set;}
    public string selectedCriteriaRouteCalc{get;set;}
    public boolean DisableEditLnkRouteCalc{get;set;}
    public string selectedCriteriaRouteCalcLine{get;set;}
    public boolean DisableEditLnkRouteCalcLine{get;set;}
    public string selectedObjMapCase{get;set;}
    public string selectedObjMapCaseLine{get;set;}
    public string selectedLoc{get;set;}
    public string templateRMAOrder{get;set;}
    public string entitleNamespace{get;set;}
    public string entitleClass{get;set;}
    public string entitleMethod{get;set;}
    public string entitleWS{get;set;}
    public string routeCalcNamespace{get;set;}
    public string routeCalcClass{get;set;}
    public string routeCalcMethod{get;set;}
    public string routeCalcWS{get;set;}
    public string beforeRMAGenNamespace{get;set;}
    public string beforeRMAGenClass{get;set;}
    public string beforeRMAGenMethod{get;set;}
    public string beforeRMAGenWS{get;set;}
    public string afterRMAGenNamespace{get;set;}
    public string afterRMAGenClass{get;set;}
    public string afterRMAGenMethod{get;set;}
    public string afterRMAGenWS{get;set;}
    public boolean renderEntitle{get;set;}
    public boolean renderRouteCalc{get;set;}
    public string parentInitRetErrorMsg{get;set;}
    public string lineInitRetErrorMsg{get;set;}
    public string mode;
    public string recordId;
    public string delIndex;
    public string getdelIndex (){return this.delIndex;}
    public void setdelIndex (string str){this.delIndex = str;}
    
    APL_Utils APLUtilObj = new APL_Utils();
    
    public boolean renderInitRetExprBlock{get;set;}
    public boolean renderInitRetLineExprBlock{get;set;}
    public boolean renderEntitleExprBlock{get;set;}
    public boolean renderEntitleLineExprBlock{get;set;}
    public boolean renderRouteCalcExprBlock{get;set;}
    public boolean renderRouteCalcLineExprBlock{get;set;}
    
    public List<SelectOption> lstCriteriaInitRet = new List<SelectOption>();
    public List<SelectOption> getlstCriteriaInitRet(){return this.lstCriteriaInitRet;} 
    public void setlstCriteriaInitRet(List<SelectOption> lstField){this.lstCriteriaInitRet = lstField;}
    public List<SelectOption> lstCriteriaInitRetLine = new List<SelectOption>();
    public List<SelectOption> getlstCriteriaInitRetLine(){return this.lstCriteriaInitRetLine;} 
    public void setlstCriteriaInitRetLine(List<SelectOption> lstField){this.lstCriteriaInitRetLine = lstField;}
    public List<SelectOption> lstObjMapCase = new List<SelectOption>();
    public List<SelectOption> getlstObjMapCase(){return this.lstObjMapCase;} 
    public void setlstObjMapCase(List<SelectOption> lstField){this.lstObjMapCase = lstField;}
    public List<SelectOption> lstObjMapCaseLine = new List<SelectOption>();
    public List<SelectOption> getlstObjMapCaseLine(){return this.lstObjMapCaseLine;}
    public void setlstObjMapCaseLine(List<SelectOption> lstField){this.lstObjMapCaseLine = lstField;}
    public List<selectoption> Hdrfldlist=new List<selectoption>();
    public List<selectoption> getHdrfldlist() {return this.Hdrfldlist;}
    public List<selectoption> LinefldList = new List<selectoption>();
    public List<selectoption> getLinefldList() {return this.LinefldList;}
    public List<SelectOption> OperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getOperatorSelectLst(){return OperatorSelectLst;}
    public List<SelectOption> lstUpdateOperator = new List<SelectOption>();
    public List<SelectOption> getlstUpdateOperator(){return this.lstUpdateOperator;} 
    public void setlstUpdateOperator(List<SelectOption> lstField){this.lstUpdateOperator = lstField;}
    public List<SelectOption> lstLoc = new List<SelectOption>();
    public List<SelectOption> getlstLoc(){return this.lstLoc;} 
    public void setlstLoc(List<SelectOption> lstField){this.lstLoc = lstField;}
    public List<SelectOption> lstFldUpdCaseWhen = new List<SelectOption>();
    public List<SelectOption> getlstFldUpdCaseWhen(){return this.lstFldUpdCaseWhen;} 
    public void setlstFldUpdCaseWhen(List<SelectOption> lstField){this.lstFldUpdCaseWhen = lstField;}
    public List<SelectOption> lstFldUpdCaseLineWhen = new List<SelectOption>();
    public List<SelectOption> getlstFldUpdCaseLineWhen(){return this.lstFldUpdCaseLineWhen;} 
    public void setlstFldUpdCaseLineWhen(List<SelectOption> lstField){this.lstFldUpdCaseLineWhen = lstField;}
    
    public SFM_WrapperDef.SFM_Response_Expression responseExpParentInitRet = new SFM_WrapperDef.SFM_Response_Expression();
    public SFM_WrapperDef.SFM_Response_Expression responseExpLineInitRet = new SFM_WrapperDef.SFM_Response_Expression();
    public SFM_WrapperDef.SFM_Response_Expression responseExpParentEntitle = new SFM_WrapperDef.SFM_Response_Expression();
    public SFM_WrapperDef.SFM_Response_Expression responseExpLineEntitle = new SFM_WrapperDef.SFM_Response_Expression();
    public SFM_WrapperDef.SFM_Response_Expression responseExpParentRouteCalc = new SFM_WrapperDef.SFM_Response_Expression();
    public SFM_WrapperDef.SFM_Response_Expression responseExpLineRouteCalc = new SFM_WrapperDef.SFM_Response_Expression();
    
    public SFM_WrapperDef.SFM_Expression ExpParentInitRet = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpParentInitRet(){return this.ExpParentInitRet;}
    public void setExpParentInitRet(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpParentInitRet = sfmExp;}
    public SFM_WrapperDef.SFM_Expression ExpLineInitRet = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpLineInitRet(){return this.ExpLineInitRet;}
    public void setExpLineInitRet(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpLineInitRet = sfmExp;}
    public SFM_WrapperDef.SFM_Expression ExpParentEntitle = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpParentEntitle(){return this.ExpParentEntitle;}
    public void setExpParentEntitle(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpParentEntitle = sfmExp;}
    public SFM_WrapperDef.SFM_Expression ExpLineEntitle = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpLineEntitle(){return this.ExpLineEntitle;}
    public void setExpLineEntitle(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpLineEntitle = sfmExp;}
    public SFM_WrapperDef.SFM_Expression ExpParentRouteCalc = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpParentRouteCalc(){return this.ExpParentRouteCalc;}
    public void setExpParentRouteCalc(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpParentRouteCalc = sfmExp;}
    public SFM_WrapperDef.SFM_Expression ExpLineRouteCalc = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpLineRouteCalc(){return this.ExpLineRouteCalc;}
    public void setExpLineRouteCalc(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpLineRouteCalc = sfmExp;}
    public SFM_WrapperDef.SFM_Expression Exp = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExp(){return this.Exp;}
    public void setExp(SFM_WrapperDef.SFM_Expression Exp){this.Exp = Exp;}
    
    public String savedExpressionResultId;
    public String getsavedExpressionResultId() { return savedExpressionResultId;}
    public void setsavedExpressionResultId(String val){this.savedExpressionResultId = val;}
    
    public Integer DetailSize = 0;
    public Integer ParentInitRetExpDetailSize = 0;
    public Integer getParentInitRetExpDetailSize(){ return ParentInitRetExpDetailSize;}
    public Integer LineInitRetExpDetailSize = 0;
    public Integer getLineInitRetExpDetailSize(){ return LineInitRetExpDetailSize;}
    public Integer ParentEntitleExpDetailSize = 0;
    public Integer getParentEntitleExpDetailSize(){ return ParentEntitleExpDetailSize;}
    public Integer LineEntitleExpDetailSize = 0;
    public Integer getLineEntitleExpDetailSize(){ return LineEntitleExpDetailSize;}
    public Integer ParentRouteCalcExpDetailSize = 0;
    public Integer getParentRouteCalcExpDetailSize(){ return ParentRouteCalcExpDetailSize;}
    public Integer LineRouteCalcExpDetailSize = 0;
    public Integer getLineRouteCalcExpDetailSize(){ return LineRouteCalcExpDetailSize;}
    public Integer SrcUpdateHdrSize = 0;
    public Integer getSrcUpdateHdrSize(){ return SrcUpdateHdrSize;}
    public Integer srcUpdateLineSize = 0;
    public Integer getsrcUpdateLineSize(){ return srcUpdateLineSize;}
    
    public boolean isCreateNewParentInitRet;
    public boolean isCreateNewLineInitRet;
    public boolean isCreateNewParentRouteCalc;
    public boolean isCreateNewLineRouteCalc;
    public boolean isCreateNewParentEntitle;
    public boolean isCreateNewLineEntitle;
    public boolean isSavedOnce;
    
    public COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumRecParentInitRet = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumRecLineInitRet = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumRecParentEntitle = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumRecLineEntitle = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumRecParentRouteCalc = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumRecLineRouteCalc = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumSrcUpdateHdr = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumsrcUpdateLine = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    
    public SVMXC__ServiceMax_Processes__c InitRetProces = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getInitRetProces(){return this.InitRetProces;}
    public void setInitRetProces(SVMXC__ServiceMax_Processes__c proces){this.InitRetProces = proces;}
    
    public List<SVMXC__ServiceMax_Config_Data__c> lstSrcUpdate = new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> LstExp = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> srcUpdateHdr = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getsrcUpdateHdr(){return this.srcUpdateHdr;}
    public void setsrcUpdateHdr(List<SVMXC__ServiceMax_Config_Data__c> o){this.srcUpdateHdr = o;}
    public List<SVMXC__ServiceMax_Config_Data__c> srcUpdateLine = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getsrcUpdateLine(){return this.srcUpdateLine;}
    public void setsrcUpdateLine(List<SVMXC__ServiceMax_Config_Data__c> o){this.srcUpdateLine = o;}
    
    public List<SVMXC__SFM_Event__c> lstSFMEvent = new List<SVMXC__SFM_Event__c>();
    public List<SVMXC__SFM_Event__c> getlstSFMEvent(){return this.lstSFMEvent;}
    public void setlstSFMEvent(List<SVMXC__SFM_Event__c> o){this.lstSFMEvent = o;}
    
    RecordType ExpressionHeader_Rtype;
    RecordType ExpressionsDetail_Rtype;
    RecordType ExpressionsSrcUpdate_Rtype;
    RecordType ObjMap_Rtype;
    RecordType InitRetProcess_Rtype;
    
    public class SVMXException extends Exception {}
    
    //------------------------------------------------Constructor/OnLoad------------------------------------------------------------------
    public CONF_SetupInitiateReturn()
    {
        try
        {
            mode = System.currentPageReference().getParameters().get('SVMX_Mode');
            recordId = System.currentPageReference().getParameters().get('SVMX_RecordId');
            
            setDefaultValues();
            retrieveRecordTypes();
            preparingPicklists();
            
            if(mode != 'New' && recordId != null && recordId != '')
            {
            system.debug('mode: ' + mode);
                if(mode == 'View')
                    disabled = true;
                
                InitRetProces = [Select  SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Consider_Location_From__c, SVMXC__Consider_Location_From_Object__c, SVMXC__Node_Parent__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Final_Exception_Process__c, SVMXC__Parent_Object__c, SVMXC__Process__c, SVMXC__Parent_Error_Msg__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Child_Error_Msg2__c, SVMXC__APL_Perform_Entitlement__c, SVMXC__APL_Perform_Route_Calculations__c, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__APL_Print_RMA_Template__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where Id =: recordId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                if(InitRetProces != null)
                {
                    processName = InitRetProces.SVMXC__Name__c;
                    processID = InitRetProces.SVMXC__ProcessID__c;
                    processDesc = InitRetProces.SVMXC__Description__c;
                    parentInitRetErrorMsg = InitRetProces.SVMXC__Parent_Error_Msg__c;
                    lineInitRetErrorMsg = InitRetProces.SVMXC__Child_Error_Msg__c;
                    isPerformEntitle = InitRetProces.SVMXC__APL_Perform_Entitlement__c;
                    isRouteCalc = InitRetProces.SVMXC__APL_Perform_Route_Calculations__c;
                    templateRMAOrder = InitRetProces.SVMXC__APL_Print_RMA_Template__c;
                    selectedObjMapCase = InitRetProces.SVMXC__Process1__c;
                    selectedObjMapCaseLine = InitRetProces.SVMXC__Process2__c;
                    
                    string objName = InitRetProces.SVMXC__Consider_Location_From_Object__c;
                    string fldName = InitRetProces.SVMXC__Consider_Location_From__c;
                    selectedLoc = objName + ' : ' + fldName;
                    
                    if(InitRetProces.SVMXC__IsStandard__c == true && (InitRetProces.SVMXC__Parent_Error_Msg__c == null || InitRetProces.SVMXC__Parent_Error_Msg__c == getTAG076()))
                        parentInitRetErrorMsg = getTAG076();
                    if(InitRetProces.SVMXC__IsStandard__c == true && (InitRetProces.SVMXC__Child_Error_Msg__c == null || InitRetProces.SVMXC__Child_Error_Msg__c == getTAG077()))
                        lineInitRetErrorMsg = getTAG077();
                        
                    if(mode == 'Clone')
                        InitRetProces.SVMXC__IsStandard__c = false;
                    
                    if(InitRetProces.SVMXC__Node_Parent__c != null)
                    {
                        responseExpParentInitRet = retrieveExpDetails(InitRetProces.SVMXC__Node_Parent__c);
                        if(responseExpParentInitRet.expressions.size() > 0)
                        {
                            ExpParentInitRet = responseExpParentInitRet.expressions[0];
                            selectedCriteriaInitRet = ExpParentInitRet.namedExpression.Id;
                            Map_SeqNumRecParentInitRet.clear();
                            for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentInitRet.expressionDetails)
                                Map_SeqNumRecParentInitRet.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                            DisableEditLnkInitRet = false;
                            ParentInitRetExpDetailSize = ExpParentInitRet.expressionDetails.size();
                        }
                    }
                    if(InitRetProces.SVMXC__Submodule__c != null)
                    {
                        responseExpLineInitRet = retrieveExpDetails(InitRetProces.SVMXC__Submodule__c);
                        if(responseExpLineInitRet.expressions.size() > 0)
                        {
                            ExpLineInitRet = responseExpLineInitRet.expressions[0];
                            selectedCriteriaInitRetLine = ExpLineInitRet.namedExpression.Id;
                            Map_SeqNumRecLineInitRet.clear();
                            for(SVMXC__ServiceMax_Config_Data__c confData : ExpLineInitRet.expressionDetails)
                                Map_SeqNumRecLineInitRet.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                            DisableEditLnkInitRetLine = false;
                            LineInitRetExpDetailSize = ExpLineInitRet.expressionDetails.size();
                        }
                    }
                    if(InitRetProces.SVMXC__Module__c != null)
                    {
                        responseExpParentEntitle = retrieveExpDetails(InitRetProces.SVMXC__Module__c);
                        if(responseExpParentEntitle.expressions.size() > 0)
                        {
                            ExpParentEntitle = responseExpParentEntitle.expressions[0];
                            selectedCriteriaEntitle = ExpParentEntitle.namedExpression.Id;
                            Map_SeqNumRecParentEntitle.clear();
                            for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentEntitle.expressionDetails)
                                Map_SeqNumRecParentEntitle.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                            DisableEditLnkEntitle = false;
                            ParentEntitleExpDetailSize = ExpParentEntitle.expressionDetails.size();
                        }
                    }
                    if(InitRetProces.SVMXC__Final_Exception_Process__c != null)
                    {
                        responseExpLineEntitle = retrieveExpDetails(InitRetProces.SVMXC__Final_Exception_Process__c);
                        if(responseExpLineEntitle.expressions.size() > 0)
                        {
                            ExpLineEntitle = responseExpLineEntitle.expressions[0];
                            selectedCriteriaEntitleLine = ExpLineEntitle.namedExpression.Id;
                            Map_SeqNumRecLineEntitle.clear();
                            for(SVMXC__ServiceMax_Config_Data__c confData : ExpLineEntitle.expressionDetails)
                                Map_SeqNumRecLineEntitle.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                            DisableEditLnkEntitleLine = false;
                            LineEntitleExpDetailSize = ExpLineEntitle.expressionDetails.size();
                        }
                    }
                    if(InitRetProces.SVMXC__Parent_Object__c != null)
                    {
                        responseExpParentRouteCalc = retrieveExpDetails(InitRetProces.SVMXC__Parent_Object__c);
                        if(responseExpParentRouteCalc.expressions.size() > 0)
                        {
                            ExpParentRouteCalc = responseExpParentRouteCalc.expressions[0];
                            selectedCriteriaRouteCalc = ExpParentRouteCalc.namedExpression.Id;
                            Map_SeqNumRecParentRouteCalc.clear();
                            for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentRouteCalc.expressionDetails)
                                Map_SeqNumRecParentRouteCalc.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                            DisableEditLnkRouteCalc = false;
                            ParentRouteCalcExpDetailSize = ExpParentRouteCalc.expressionDetails.size();
                        }
                    }
                    if(InitRetProces.SVMXC__Process__c != null)
                    {
                        responseExpLineRouteCalc = retrieveExpDetails(InitRetProces.SVMXC__Process__c);
                        if(responseExpLineRouteCalc.expressions.size() > 0)
                        {
                            ExpLineRouteCalc = responseExpLineRouteCalc.expressions[0];
                            selectedCriteriaRouteCalcLine = ExpLineRouteCalc.namedExpression.Id;
                            Map_SeqNumRecLineRouteCalc.clear();
                            for(SVMXC__ServiceMax_Config_Data__c confData : ExpLineRouteCalc.expressionDetails)
                                Map_SeqNumRecLineRouteCalc.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                            DisableEditLnkRouteCalcLine = false;
                            LineRouteCalcExpDetailSize = ExpLineRouteCalc.expressionDetails.size();
                        }
                    }
                }
                queryingdata();
            }
            if(mode == 'New' || mode == 'Clone')
            {
                InitRetProces = new SVMXC__ServiceMax_Processes__c();
                List<SVMXC__ServiceMax_Config_Data__c> tempLstConf = new List<SVMXC__ServiceMax_Config_Data__c>();
                tempLstConf.addAll(srcUpdateHdr);
                srcUpdateHdr = new List<SVMXC__ServiceMax_Config_Data__c>();
                srcUpdateHdr.addAll(tempLstConf);
                tempLstConf.clear();
                tempLstConf.addAll(srcUpdateLine);
                srcUpdateLine = new List<SVMXC__ServiceMax_Config_Data__c>();
                srcUpdateLine.addAll(tempLstConf);
                lstSrcUpdate = new List<SVMXC__ServiceMax_Config_Data__c>();
            }
            
            Map_SeqNumSrcUpdateHdr.clear();
            for(SVMXC__ServiceMax_Config_Data__c configData : srcUpdateHdr)
                Map_SeqNumSrcUpdateHdr.put(integer.valueOf(configData.SVMXC__Sequence__c), configData);
            Map_SeqNumsrcUpdateLine.clear();
            for(SVMXC__ServiceMax_Config_Data__c configData : srcUpdateLine)
                Map_SeqNumsrcUpdateLine.put(integer.valueOf(configData.SVMXC__Sequence__c), configData);
            SrcUpdateHdrSize = srcUpdateHdr.size();
            srcUpdateLineSize = srcUpdateLine.size();
            if(srcUpdateHdr.size() == 0)
                srcUpdateHdrADDRow();
            if(srcUpdateLine.size() == 0)
                srcUpdateLineADDRow();
            
            if(isPerformEntitle == true)
                renderEntitle = true;
            else
            {
                selectedCriteriaEntitle = getTAG024();
                selectedCriteriaEntitleLine = getTAG024();
            }
            if(isRouteCalc == true)
                renderRouteCalc = true;
            else if(mode == 'Edit' || mode == 'Clone')
            {
                selectedCriteriaRouteCalc = getTAG024();
                selectedCriteriaRouteCalcLine = getTAG024();
            }
        }
        catch(exception ex)
        {
            disabled = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG078(),''));
        }
    }
    
    public void setDefaultValues()
    {
        DisableEditLnkInitRet = true;
        DisableEditLnkInitRetLine = true;
        DisableEditLnkEntitle = true;
        DisableEditLnkEntitleLine = true;
        DisableEditLnkRouteCalc = true;
        DisableEditLnkRouteCalcLine = true;
        isRouteCalc = true;
        isPerformEntitle = false;
        isCreateNewParentInitRet = false;
        isCreateNewLineInitRet = false;
        isCreateNewParentRouteCalc = false;
        isCreateNewLineRouteCalc = false;
        isCreateNewParentEntitle = false;
        isCreateNewLineEntitle = false;
        isSavedOnce = false;
        renderInitRetExprBlock = false;
        renderInitRetLineExprBlock = false;
        renderEntitleExprBlock = false;
        renderEntitleLineExprBlock = false;
        renderRouteCalcExprBlock = false;
        renderRouteCalcLineExprBlock = false;
        parentInitRetErrorMsg = getTAG076();
        lineInitRetErrorMsg = getTAG077();
        selectedCriteriaInitRet = getTAG024();
        selectedCriteriaInitRetLine = getTAG024();
        selectedCriteriaEntitle = getTAG024();
        selectedCriteriaEntitleLine = getTAG024();
        selectedCriteriaRouteCalc = getTAG024();
        selectedCriteriaRouteCalcLine = getTAG024();
    }
    
    //---------------------------------------- Method to prepare all the PickList -----------------------------------------
    public void preparingPicklists()
    {
    /*SFM_WrapperDef.SFM_Request SFMReq = new SFM_WrapperDef.SFM_Request();
        
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap strinmap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE', 'EXPRESSION');
        lstStringMap.add(strinmap1);
        SFM_WrapperDef.SFM_StringMap strinmap2 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME', 'SVMXC__Case_Line__c');
        lstStringMap.add(strinmap2);
        
        SFMReq.stringMap = lstStringMap;
        
        SFM_GetObjectFieldList newObjToGetFields = new SFM_GetObjectFieldList();
        SFM_WrapperDef.SFM_Response_ObjectFields responseObjFields = newObjToGetFields.getObjectFieldList(SFMReq);
        List<SFM_WrapperDef.fieldProperties> fieldProp = new List<SFM_WrapperDef.fieldProperties>();
      if(responseObjFields.response.success)
        {
          fieldProp = responseObjFields.fields;
      }
      
      LinefldList.clear();
        LinefldList.add(new SelectOption(getTAG024(),getTAG024()));
        
      for(SFM_WrapperDef.fieldProperties fp : fieldProp)
      {
        LinefldList.add(new SelectOption(fp.key, fp.value));
      }*/
        
        LinefldList.clear();
        LinefldList.add(new SelectOption(getTAG024(),getTAG024()));
        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
        DispMethods.RetriveField('SVMXC__Case_Line__c', LinefldList, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        LinefldList = sortingSelectOption(LinefldList);
        
        Hdrfldlist.clear();
        Hdrfldlist.add(new SelectOption(getTAG024(),getTAG024()));
        DispMethods.RetriveField('Case', Hdrfldlist, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        Hdrfldlist = sortingSelectOption(Hdrfldlist);
        List<selectoption> tempfldLst = new List<selectoption>();
        tempfldLst.addAll(Hdrfldlist);
        Hdrfldlist.clear();
        for(selectoption SO : tempfldLst)
        {
            if(SO.getLabel() == 'Email Address' || SO.getLabel() == 'Name' || SO.getLabel() == 'New Self-Service Comment' || SO.getLabel() == 'Self-Service commented')
                continue;
            Hdrfldlist.add(SO);
        }
        
        List<SVMXC__ServiceMax_Processes__c> ObjMapCaseLst = new List<SVMXC__ServiceMax_Processes__c>();
        string ObjMapRtypeId = ObjMap_Rtype.Id;
        ObjMapCaseLst = [Select  id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c,   SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Active__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where RecordTypeId =: ObjMapRtypeId AND SVMXC__Source_Object_Name__c = 'Case' AND SVMXC__Target_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstObjMapCase.add(new SelectOption(getTAG024(),getTAG024()));
        if(ObjMapCaseLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : ObjMapCaseLst)
                lstObjMapCase.add(new SelectOption(pro.Id, pro.SVMXC__Name__C));
        }
        lstObjMapCase = sortingSelectOption(lstObjMapCase);
         
        ObjMapCaseLst.clear();
        ObjMapCaseLst = [Select  id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c,   SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Active__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where RecordTypeId =: ObjMapRtypeId AND SVMXC__Source_Object_Name__c = 'SVMXC__Case_Line__c' AND SVMXC__Target_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstObjMapCaseLine.add(new SelectOption(getTAG024(),getTAG024()));
        if(ObjMapCaseLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : ObjMapCaseLst)
                lstObjMapCaseLine.add(new SelectOption(pro.Id, pro.SVMXC__Name__C));
        }
        lstObjMapCaseLine = sortingSelectOption(lstObjMapCaseLine);
         
        buildingExpLists();
        
        OperatorSelectLst.clear();
        OperatorSelectLst.add(new SelectOption('SVMX.NONE', getTAG024()));
        OperatorSelectLst.add(new SelectOption('eq', getTAG060()));
        OperatorSelectLst.add(new SelectOption('ne', getTAG061()));
        OperatorSelectLst.add(new SelectOption('gt', getTAG062()));
        OperatorSelectLst.add(new SelectOption('ge', getTAG063()));
        OperatorSelectLst.add(new SelectOption('lt', getTAG064()));
        OperatorSelectLst.add(new SelectOption('le', getTAG065()));
        OperatorSelectLst.add(new SelectOption('starts', getTAG066()));
        OperatorSelectLst.add(new SelectOption('contains', getTAG067()));
        OperatorSelectLst.add(new SelectOption('notcontain', getTAG068()));
        OperatorSelectLst.add(new SelectOption('in', getTAG069()));
        OperatorSelectLst.add(new SelectOption('notin', getTAG070()));
        OperatorSelectLst.add(new SelectOption('isnull', getTAG071()));
        OperatorSelectLst.add(new SelectOption('isnotnull', getTAG072()));
        
        lstUpdateOperator.clear();
        lstUpdateOperator.add(new SelectOption('Set', getTAG074()));
        //lstUpdateOperator.add(new SelectOption('Increase', getTAG075()));
        //lstUpdateOperator.add(new SelectOption('Decrease', getTAG076()));
        
        lstFldUpdCaseWhen.clear();
        lstFldUpdCaseWhen.add(new SelectOption('HEADER_UPD_ON_ENTITLEMENT', getTAG054()));
        lstFldUpdCaseWhen.add(new SelectOption('HEADER_UPD_ON_ROUTE_CALC', getTAG055()));
        lstFldUpdCaseWhen.add(new SelectOption('HEADER_UPD_ON_RMA_GENERATION', getTAG056()));
        
        lstFldUpdCaseLineWhen.clear();
        lstFldUpdCaseLineWhen.add(new SelectOption('LINE_UPD_ON_ENTITLEMENT', getTAG054()));
        lstFldUpdCaseLineWhen.add(new SelectOption('LINE_UPD_ON_ROUTE_CALC', getTAG055()));
        lstFldUpdCaseLineWhen.add(new SelectOption('LINE_UPD_ON_RMA_GENERATION', getTAG056()));
        
        lstLoc.clear();
        lstLoc.add(new SelectOption(getTAG024(),getTAG024()));
        List<Schema.sObjectType> schema1 = new List<Schema.sObjectType>();
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        Schema.DescribeSObjectResult R = Case.SObjectType.getDescribe();
        string objLabel = R.getLabel();
        objfieldMap = R.fields.getMap();
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe(); 
            
            if(f.getType().name().ToUpperCase() == 'REFERENCE') 
            {
                schema1 = f.getReferenceTo();
                for(Schema.sObjectType sObj: schema1)
                {
                    if(string.valueOf(sObj) == 'SVMXC__Site__c')
                    {
                        lstLoc.add(new SelectOption('Case'+ ' : ' + f.getName(), objLabel +' : '+ f.getLabel()));
                    }
                }
            }
        }
        schema1.clear();
        R = Account.SObjectType.getDescribe();
        objLabel = R.getLabel();
        objfieldMap = R.fields.getMap();
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe(); 
            
            if(f.getType().name().ToUpperCase() == 'REFERENCE') 
            {
                schema1 = f.getReferenceTo();
                for(Schema.sObjectType sObj: schema1)
                {
                    if(string.valueOf(sObj) == 'SVMXC__Site__c')
                    {
                        lstLoc.add(new SelectOption('Account'+ ' : ' + f.getName(), objLabel +' : '+ f.getLabel()));
                    }
                }
            }
        }
        schema1.clear();
        R = SVMXC__Case_Line__c.SObjectType.getDescribe();
        objLabel = R.getLabel();
        objfieldMap = R.fields.getMap();
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe(); 
            
            if(f.getType().name().ToUpperCase() == 'REFERENCE') 
            {
                schema1 = f.getReferenceTo();
                for(Schema.sObjectType sObj: schema1)
                {
                    if(string.valueOf(sObj) == 'SVMXC__Site__c')
                    {
                        lstLoc.add(new SelectOption('SVMXC__Case_Line__c'+ ' : ' + f.getName(), objLabel +' : '+ f.getLabel()));
                    }
                }
            }
        }
        lstLoc = sortingSelectOption(lstLoc);
    }
    
    public void buildingExpLists()
    {
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','Case');
        lstStringMap.add(stringMap1);
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        response = namedExpLst.SFM_getAllObjectNamedExpressionList(request);
        
        lstCriteriaInitRet.clear();
        lstCriteriaInitRet.add(new SelectOption(getTAG024(), getTAG024()));
        for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
            lstCriteriaInitRet.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
        lstCriteriaInitRet = sortingSelectOption(lstCriteriaInitRet);
        
        SFM_WrapperDef.SFM_StringMap stringMap2 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__Case_Line__c');
        lstStringMap.clear();
        lstStringMap.add(stringMap2);
        SFM_WrapperDef.SFM_Request request1 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        response = namedExpLst.SFM_getAllObjectNamedExpressionList(request1);
        
        lstCriteriaInitRetLine.clear();
        lstCriteriaInitRetLine.add(new SelectOption(getTAG024(), getTAG024()));
        for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
            lstCriteriaInitRetLine.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
        lstCriteriaInitRetLine = sortingSelectOption(lstCriteriaInitRetLine);
    }
    
    //------------------------------------- Method to sort the Options of the PickList --------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList) {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }
    
    //---------------------------------------- Method to query All the SFM Events and Config Data -----------------------------------------
    public void queryingdata()
    {
        /* if(mode == 'New')
        {
            srcUpdateHdr.clear();
            srcUpdateLine.clear();
        }
         */
        lstSFMEvent.clear();
        lstSrcUpdate.clear();
        if(recordId != null && recordId.length() > 0)
        {
            lstSFMEvent = [Select SVMXC__Event_Id__c, SVMXC__Sequence__c, SVMXC__ServiceMax_Process__c, SVMXC__Event_Type__c, SVMXC__Namespace__c, SVMXC__Class__c, SVMXC__Method__c, SVMXC__Description__c from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c =: recordId AND (SVMXC__Event_Type__c = 'Before Entitlement' OR SVMXC__Event_Type__c = 'Before Route Calculations' OR SVMXC__Event_Type__c = 'Before RMA Generation' OR SVMXC__Event_Type__c = 'After RMA Generation')];
        
            string recordTypeId = ExpressionsSrcUpdate_Rtype.Id;
            lstSrcUpdate = [Select SVMXC__Target_Field_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Operator__c , SVMXC__Operand__c, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Action__c, SVMXC__RecordType_Name__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: recordId and RecordTypeId =: recordTypeId and (SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_ENTITLEMENT' OR SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_ROUTE_CALC' OR SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_RMA_GENERATION' OR SVMXC__Configuration_Type__c = 'LINE_UPD_ON_ENTITLEMENT' OR SVMXC__Configuration_Type__c = 'LINE_UPD_ON_ROUTE_CALC' OR SVMXC__Configuration_Type__c = 'LINE_UPD_ON_RMA_GENERATION')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        
        if(lstSFMEvent != null && lstSFMEvent.size() > 0)
        {
            for(SVMXC__SFM_Event__c event : lstSFMEvent)
            {
                if(event.SVMXC__Event_Type__c == 'Before Entitlement')
                {
                    entitleNamespace = event.SVMXC__Namespace__c;
                    entitleClass = event.SVMXC__Class__c;
                    entitleMethod = event.SVMXC__Method__c;
                    entitleWS = event.SVMXC__Description__c;
                }
                else if(event.SVMXC__Event_Type__c == 'Before Route Calculations')
                {
                    routeCalcNamespace = event.SVMXC__Namespace__c;
                    routeCalcClass = event.SVMXC__Class__c;
                    routeCalcMethod = event.SVMXC__Method__c;
                    routeCalcWS = event.SVMXC__Description__c;
                }
                else if(event.SVMXC__Event_Type__c == 'Before RMA Generation')
                {
                    beforeRMAGenNamespace = event.SVMXC__Namespace__c;
                    beforeRMAGenClass = event.SVMXC__Class__c;
                    beforeRMAGenMethod = event.SVMXC__Method__c;
                    beforeRMAGenWS = event.SVMXC__Description__c;
                }
                else if(event.SVMXC__Event_Type__c == 'After RMA Generation')
                {
                    afterRMAGenNamespace = event.SVMXC__Namespace__c;
                    afterRMAGenClass = event.SVMXC__Class__c;
                    afterRMAGenMethod = event.SVMXC__Method__c;
                    afterRMAGenWS = event.SVMXC__Description__c;
                }
            }
        }
        
        srcUpdateHdr.clear();
        srcUpdateLine.clear();
        if(lstSrcUpdate != null && lstSrcUpdate.size() > 0)
        {
            for(SVMXC__ServiceMax_Config_Data__c configData : lstSrcUpdate)
            {
                if(configData.SVMXC__Configuration_Type__c == 'HEADER_UPD_ON_ENTITLEMENT' || configData.SVMXC__Configuration_Type__c == 'HEADER_UPD_ON_ROUTE_CALC' || configData.SVMXC__Configuration_Type__c == 'HEADER_UPD_ON_RMA_GENERATION')
                    srcUpdateHdr.add(configData);
                else if(configData.SVMXC__Configuration_Type__c == 'LINE_UPD_ON_ENTITLEMENT' || configData.SVMXC__Configuration_Type__c == 'LINE_UPD_ON_ROUTE_CALC' || configData.SVMXC__Configuration_Type__c == 'LINE_UPD_ON_RMA_GENERATION')
                    srcUpdateLine.add(configData);
            }
        }
        Map_SeqNumSrcUpdateHdr.clear();
        for(SVMXC__ServiceMax_Config_Data__c configData : srcUpdateHdr)
            Map_SeqNumSrcUpdateHdr.put(integer.valueOf(configData.SVMXC__Sequence__c), configData);
        Map_SeqNumsrcUpdateLine.clear();
        for(SVMXC__ServiceMax_Config_Data__c configData : srcUpdateLine)
            Map_SeqNumsrcUpdateLine.put(integer.valueOf(configData.SVMXC__Sequence__c), configData);
        SrcUpdateHdrSize = srcUpdateHdr.size();
        srcUpdateLineSize = srcUpdateLine.size();
        
        if(srcUpdateHdr.size() == 0)
            srcUpdateHdrADDRow();
        if(srcUpdateLine.size() == 0)
            srcUpdateLineADDRow();
    }
    
    //----------------------------------------- Method to retrieve Expression Details ---------------------------------------------
    public SFM_WrapperDef.SFM_Response_Expression retrieveExpDetails(string expId)
    {
        SFM_WrapperDef.SFM_Response_Expression responseExp = new SFM_WrapperDef.SFM_Response_Expression();
        SFM_WrapperDef.SFM_StringMap stringMap3 = new SFM_WrapperDef.SFM_StringMap('EXPRESSIONID',expId);
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(stringMap3);
        SFM_WrapperDef.SFM_Request request2 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        responseExp = namedExpLst.SFM_getNamedExpressionList(request2);
        
        return responseExp;
    }
    
    //---------------------------------------- Method to retrieve All the Record Types -----------------------------------------
    public void retrieveRecordTypes()
    {
        ExpressionHeader_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ExpressionsDetail_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ObjMap_Rtype = [select Id from RecordType where Name='Object Mapping'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        InitRetProcess_Rtype = [select Id from RecordType where Name='Initiate Return Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    
    public void onChngEntitle()
    {
        if(isPerformEntitle == true)
        {
            renderEntitle = true;
            if(mode != 'new')
            {
                if(InitRetProces.SVMXC__Module__c != null)
                {
                    responseExpParentEntitle = retrieveExpDetails(InitRetProces.SVMXC__Module__c);
                    if(responseExpParentEntitle.expressions.size() > 0)
                    {
                        ExpParentEntitle = responseExpParentEntitle.expressions[0];
                        selectedCriteriaEntitle = ExpParentEntitle.namedExpression.Id;
                        Map_SeqNumRecParentEntitle.clear();
                        for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentEntitle.expressionDetails)
                            Map_SeqNumRecParentEntitle.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                        DisableEditLnkEntitle = false;
                        ParentEntitleExpDetailSize = ExpParentEntitle.expressionDetails.size();
                    }
                }
                if(InitRetProces.SVMXC__Final_Exception_Process__c != null)
                {
                    responseExpLineEntitle = retrieveExpDetails(InitRetProces.SVMXC__Final_Exception_Process__c);
                    if(responseExpLineEntitle.expressions.size() > 0)
                    {
                        ExpLineEntitle = responseExpLineEntitle.expressions[0];
                        selectedCriteriaEntitleLine = ExpLineEntitle.namedExpression.Id;
                        Map_SeqNumRecLineEntitle.clear();
                        for(SVMXC__ServiceMax_Config_Data__c confData : ExpLineEntitle.expressionDetails)
                            Map_SeqNumRecLineEntitle.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                        DisableEditLnkEntitleLine = false;
                        LineEntitleExpDetailSize = ExpLineEntitle.expressionDetails.size();
                    }
                }
            }
        }
        else
            renderEntitle = false;
    }
    
    public void onChngRouteCalc()
    {
        if(isRouteCalc == true)
        {
            renderRouteCalc = true;
            if(mode != 'new')
            {
                if(InitRetProces.SVMXC__Parent_Object__c != null)
                {
                    responseExpParentRouteCalc = retrieveExpDetails(InitRetProces.SVMXC__Parent_Object__c);
                    if(responseExpParentRouteCalc.expressions.size() > 0)
                    {
                        ExpParentRouteCalc = responseExpParentRouteCalc.expressions[0];
                        selectedCriteriaRouteCalc = ExpParentRouteCalc.namedExpression.Id;
                        Map_SeqNumRecParentRouteCalc.clear();
                        for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentRouteCalc.expressionDetails)
                            Map_SeqNumRecParentRouteCalc.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                        DisableEditLnkRouteCalc = false;
                        ParentRouteCalcExpDetailSize = ExpParentRouteCalc.expressionDetails.size();
                    }
                }
                if(InitRetProces.SVMXC__Process__c != null)
                {
                    responseExpLineRouteCalc = retrieveExpDetails(InitRetProces.SVMXC__Process__c);
                    if(responseExpLineRouteCalc.expressions.size() > 0)
                    {
                        ExpLineRouteCalc = responseExpLineRouteCalc.expressions[0];
                        selectedCriteriaRouteCalcLine = ExpLineRouteCalc.namedExpression.Id;
                        Map_SeqNumRecLineRouteCalc.clear();
                        for(SVMXC__ServiceMax_Config_Data__c confData : ExpLineRouteCalc.expressionDetails)
                            Map_SeqNumRecLineRouteCalc.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                        DisableEditLnkRouteCalcLine = false;
                        LineRouteCalcExpDetailSize = ExpLineRouteCalc.expressionDetails.size();
                    }
                }
            }
        }
        else
            renderRouteCalc = false;
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Initiate Return Parent --------------------------------
    public void onChngInitRetParentExp()
    {
        isCreateNewParentInitRet = false;
        renderInitRetExprBlock = false;
        if(selectedCriteriaInitRet != getTAG024())
        {
            DisableEditLnkInitRet = false;
            responseExpParentInitRet = retrieveExpDetails(selectedCriteriaInitRet);
            if(responseExpParentInitRet.expressions.size() > 0)
            {
                ExpParentInitRet = responseExpParentInitRet.expressions[0];
                ParentInitRetExpDetailSize = ExpParentInitRet.expressionDetails.size();
                Map_SeqNumRecParentInitRet.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentInitRet.expressionDetails)
                {
                    Map_SeqNumRecParentInitRet.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkInitRet = true;
    }
    
    //----------------------------------------- View/Edit of Initiate Return Parent ---------------------------------------------
    public void EditCriteriaInitRetParentExp()
    {
        renderInitRetExprBlock = true;
    }
    
    //----------------------------------------- New Criteria of Initiate Return Parent ---------------------------------------------
    public void NewCriteriaInitRetParentExp()
    {
        isCreateNewParentInitRet = true;
        selectedCriteriaInitRet = getTAG024();
        DisableEditLnkInitRet = true;
        renderInitRetExprBlock = true;
        ExpParentInitRet = new SFM_WrapperDef.SFM_Expression();
        ExpParentInitRet.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'Case');
        ExpParentInitRet.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpParentInitRet.expressionDetails != null)
            ParentInitRetExpDetailSize = ExpParentInitRet.expressionDetails.size();
        else
            ParentInitRetExpDetailSize = 0;
        Exp = ExpParentInitRet;
        DetailSize = ParentInitRetExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecParentInitRet.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecParentInitRet);
        HdrADDRow();
        ParentInitRetExpDetailSize = DetailSize;
        Map_SeqNumRecParentInitRet.clear();
        Map_SeqNumRecParentInitRet.putAll(Map_SeqNumRec);
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Initiate Return Line --------------------------------
    public void onChngInitRetLineExp()
    {
        isCreateNewLineInitRet = false;
        renderInitRetLineExprBlock = false;
        if(selectedCriteriaInitRetLine != getTAG024())
        {
            DisableEditLnkInitRetLine = false;
            responseExpLineInitRet = retrieveExpDetails(selectedCriteriaInitRetLine);
            if(responseExpLineInitRet.expressions.size() > 0)
            {
                ExpLineInitRet = responseExpLineInitRet.expressions[0];
                LineInitRetExpDetailSize = ExpLineInitRet.expressionDetails.size();
                Map_SeqNumRecLineInitRet.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpLineInitRet.expressionDetails)
                {
                    Map_SeqNumRecLineInitRet.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkInitRetLine = true;
    }
    
    //----------------------------------------- View/Edit of Initiate Return Line ---------------------------------------------
    public void EditCriteriaInitRetLineExp()
    {
        renderInitRetLineExprBlock = true;
    }
    
    //----------------------------------------- New Criteria of Initiate Return Line ---------------------------------------------
    public void NewCriteriaInitRetLineExp()
    {
        isCreateNewLineInitRet = true;
        selectedCriteriaInitRetLine = getTAG024();
        DisableEditLnkInitRetLine = true;
        renderInitRetLineExprBlock = true;
        ExpLineInitRet = new SFM_WrapperDef.SFM_Expression();
        ExpLineInitRet.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'SVMXC__Case_Line__c');
        ExpLineInitRet.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpLineInitRet.expressionDetails != null)
            LineInitRetExpDetailSize = ExpLineInitRet.expressionDetails.size();
        else
            LineInitRetExpDetailSize = 0;
        Exp = ExpLineInitRet;
        DetailSize = LineInitRetExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecLineInitRet.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecLineInitRet);
        HdrADDRow();
        LineInitRetExpDetailSize = DetailSize;
        Map_SeqNumRecLineInitRet.clear();
        Map_SeqNumRecLineInitRet.putAll(Map_SeqNumRec);
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Entitlement --------------------------------
    public void onChngEntitleParentExp()
    {
        isCreateNewParentEntitle = false;
        renderEntitleExprBlock = false;
        if(selectedCriteriaEntitle != getTAG024())
        {
            DisableEditLnkEntitle = false;
            responseExpParentEntitle = retrieveExpDetails(selectedCriteriaEntitle);
            if(responseExpParentEntitle.expressions.size() > 0)
            {
                ExpParentEntitle = responseExpParentEntitle.expressions[0];
                ParentEntitleExpDetailSize = ExpParentEntitle.expressionDetails.size();
                Map_SeqNumRecParentEntitle.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentEntitle.expressionDetails)
                {
                    Map_SeqNumRecParentEntitle.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkEntitle = true;
    }
    
    //----------------------------------------- View/Edit of Entitlement ---------------------------------------------
    public void EditCriteriaEntitleParentExp()
    {
        renderEntitleExprBlock = true;
    }
    
    //----------------------------------------- New Criteria of Entitlement ---------------------------------------------
    public void NewCriteriaEntitleParentExp()
    {
        isCreateNewParentEntitle = true;
        selectedCriteriaEntitle = getTAG024();
        DisableEditLnkEntitle = true;
        renderEntitleExprBlock = true;
        ExpParentEntitle = new SFM_WrapperDef.SFM_Expression();
        ExpParentEntitle.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'Case');
        ExpParentEntitle.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpParentEntitle.expressionDetails != null)
            ParentEntitleExpDetailSize = ExpParentEntitle.expressionDetails.size();
        else
            ParentEntitleExpDetailSize = 0;
        Exp = ExpParentEntitle;
        DetailSize = ParentEntitleExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecParentEntitle.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecParentEntitle);
        HdrADDRow();
        ParentEntitleExpDetailSize = DetailSize;
        Map_SeqNumRecParentEntitle.clear();
        Map_SeqNumRecParentEntitle.putAll(Map_SeqNumRec);
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Entitlement Line --------------------------------
    public void onChngEntitleLineExp()
    {
        isCreateNewLineEntitle = false;
        renderEntitleLineExprBlock = false;
        if(selectedCriteriaEntitleLine != getTAG024())
        {
            DisableEditLnkEntitleLine = false;
            responseExpLineEntitle = retrieveExpDetails(selectedCriteriaEntitleLine);
            if(responseExpLineEntitle.expressions.size() > 0)
            {
                ExpLineEntitle = responseExpLineEntitle.expressions[0];
                LineEntitleExpDetailSize = ExpLineEntitle.expressionDetails.size();
                Map_SeqNumRecLineEntitle.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpLineEntitle.expressionDetails)
                {
                    Map_SeqNumRecLineEntitle.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkEntitleLine = true;
    }
    
    //----------------------------------------- View/Edit of Entitlement Line ---------------------------------------------
    public void EditCriteriaEntitleLineExp()
    {
        renderEntitleLineExprBlock = true;
    }
    
    //----------------------------------------- New Criteria of Entitlement Line ---------------------------------------------
    public void NewCriteriaEntitleLineExp()
    {
        isCreateNewLineEntitle = true;
        selectedCriteriaEntitleLine = getTAG024();
        DisableEditLnkEntitleLine = true;
        renderEntitleLineExprBlock = true;
        ExpLineEntitle = new SFM_WrapperDef.SFM_Expression();
        ExpLineEntitle.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'SVMXC__Case_Line__c');
        ExpLineEntitle.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpLineEntitle.expressionDetails != null)
            LineEntitleExpDetailSize = ExpLineEntitle.expressionDetails.size();
        else
            LineEntitleExpDetailSize = 0;
        Exp = ExpLineEntitle;
        DetailSize = LineEntitleExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecLineEntitle.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecLineEntitle);
        HdrADDRow();
        LineEntitleExpDetailSize = DetailSize;
        Map_SeqNumRecLineEntitle.clear();
        Map_SeqNumRecLineEntitle.putAll(Map_SeqNumRec);
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Route Calculations --------------------------------
    public void onChngRouteCalcParentExp()
    {
        isCreateNewParentRouteCalc = false;
        renderRouteCalcExprBlock = false;
        if(selectedCriteriaRouteCalc != getTAG024())
        {
            DisableEditLnkRouteCalc = false;
            responseExpParentRouteCalc = retrieveExpDetails(selectedCriteriaRouteCalc);
            if(responseExpParentRouteCalc.expressions.size() > 0)
            {
                ExpParentRouteCalc = responseExpParentRouteCalc.expressions[0];
                ParentRouteCalcExpDetailSize = ExpParentRouteCalc.expressionDetails.size();
                Map_SeqNumRecParentRouteCalc.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentRouteCalc.expressionDetails)
                {
                    Map_SeqNumRecParentRouteCalc.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkRouteCalc = true;
    }
    
    //----------------------------------------- View/Edit of Route Calculations ---------------------------------------------
    public void EditCriteriaRouteCalcParentExp()
    {
        renderRouteCalcExprBlock = true;
    }
    
    //----------------------------------------- New Criteria of Route Calculations ---------------------------------------------
    public void NewCriteriaRouteCalcParentExp()
    {
        isCreateNewParentRouteCalc = true;
        selectedCriteriaRouteCalc = getTAG024();
        DisableEditLnkRouteCalc = true;
        renderRouteCalcExprBlock = true;
        ExpParentRouteCalc = new SFM_WrapperDef.SFM_Expression();
        ExpParentRouteCalc.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'Case');
        ExpParentRouteCalc.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpParentRouteCalc.expressionDetails != null)
            ParentRouteCalcExpDetailSize = ExpParentRouteCalc.expressionDetails.size();
        else
            ParentRouteCalcExpDetailSize = 0;
        Exp = ExpParentRouteCalc;
        DetailSize = ParentRouteCalcExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecParentRouteCalc.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecParentRouteCalc);
        HdrADDRow();
        ParentRouteCalcExpDetailSize = DetailSize;
        Map_SeqNumRecParentRouteCalc.clear();
        Map_SeqNumRecParentRouteCalc.putAll(Map_SeqNumRec);
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Route Calculations --------------------------------
    public void onChngRouteCalcLineExp()
    {
        isCreateNewLineRouteCalc = false;
        renderRouteCalcLineExprBlock = false;
        if(selectedCriteriaRouteCalcLine != getTAG024())
        {
            DisableEditLnkRouteCalcLine = false;
            responseExpLineRouteCalc = retrieveExpDetails(selectedCriteriaRouteCalcLine);
            if(responseExpLineRouteCalc.expressions.size() > 0)
            {
                ExpLineRouteCalc = responseExpLineRouteCalc.expressions[0];
                LineRouteCalcExpDetailSize = ExpLineRouteCalc.expressionDetails.size();
                Map_SeqNumRecLineRouteCalc.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpLineRouteCalc.expressionDetails)
                {
                    Map_SeqNumRecLineRouteCalc.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkRouteCalcLine = true;
    }
    
    //----------------------------------------- View/Edit of Route Calculations ---------------------------------------------
    public void EditCriteriaRouteCalcLineExp()
    {
        renderRouteCalcLineExprBlock = true;
    }
    
    //----------------------------------------- New Criteria of Route Calculations ---------------------------------------------
    public void NewCriteriaRouteCalcLineExp()
    {
        isCreateNewLineRouteCalc = true;
        selectedCriteriaRouteCalcLine = getTAG024();
        DisableEditLnkRouteCalcLine = true;
        renderRouteCalcLineExprBlock = true;
        ExpLineRouteCalc = new SFM_WrapperDef.SFM_Expression();
        ExpLineRouteCalc.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'SVMXC__Case_Line__c');
        ExpLineRouteCalc.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpLineRouteCalc.expressionDetails != null)
            LineRouteCalcExpDetailSize = ExpLineRouteCalc.expressionDetails.size();
        else
            LineRouteCalcExpDetailSize = 0;
        Exp = ExpLineRouteCalc;
        DetailSize = LineRouteCalcExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecLineRouteCalc.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecLineRouteCalc);
        HdrADDRow();
        LineRouteCalcExpDetailSize = DetailSize;
        Map_SeqNumRecLineRouteCalc.clear();
        Map_SeqNumRecLineRouteCalc.putAll(Map_SeqNumRec);
    }
    
    //----------------------------------------- Delete Row in the Initiate Return ---------------------------------------------
    public PageReference HdrDeleteRowInitRet()
    {
        Exp = ExpParentInitRet;
        DetailSize = ParentInitRetExpDetailSize;
        Map_SeqNumRec.clear();
        Map_SeqNumRec.putAll(Map_SeqNumRecParentInitRet);
        HdrDeleteRow();
        Map_SeqNumRecParentInitRet.clear();
        Map_SeqNumRecParentInitRet.putAll(Map_SeqNumRec);
        ParentInitRetExpDetailSize = DetailSize;
        ExpParentInitRet = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Initiate Return ---------------------------------------------
    public PageReference HdrADDRowInitRet()
    {
        Exp = ExpParentInitRet;
        DetailSize = ParentInitRetExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecParentInitRet.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecParentInitRet);
        HdrADDRow();
        ParentInitRetExpDetailSize = DetailSize;
        Map_SeqNumRecParentInitRet.clear();
        Map_SeqNumRecParentInitRet.putAll(Map_SeqNumRec);
        ExpParentInitRet = Exp;
        return null;
    }
    
    //----------------------------------------- Delete Row in the Initiate Return Line ---------------------------------------------
    public PageReference HdrDeleteRowInitRetLine()
    {
        Exp = ExpLineInitRet;
        DetailSize = LineInitRetExpDetailSize;
        Map_SeqNumRec.clear();
        Map_SeqNumRec.putAll(Map_SeqNumRecLineInitRet);
        HdrDeleteRow();
        Map_SeqNumRecLineInitRet.clear();
        Map_SeqNumRecLineInitRet.putAll(Map_SeqNumRec);
        LineInitRetExpDetailSize = DetailSize;
        ExpLineInitRet = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Initiate Return Line ---------------------------------------------
    public PageReference HdrADDRowInitRetLine()
    {
        Exp = ExpLineInitRet;
        DetailSize = LineInitRetExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecLineInitRet.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecLineInitRet);
        HdrADDRow();
        LineInitRetExpDetailSize = DetailSize;
        Map_SeqNumRecLineInitRet.clear();
        Map_SeqNumRecLineInitRet.putAll(Map_SeqNumRec);
        ExpLineInitRet = Exp;
        return null;
    }
    
    //----------------------------------------- Delete Row in the Entitlement ---------------------------------------------
    public PageReference HdrDeleteRowEntitle()
    {
        Exp = ExpParentEntitle;
        DetailSize = ParentEntitleExpDetailSize;
        Map_SeqNumRec.clear();
        Map_SeqNumRec.putAll(Map_SeqNumRecParentEntitle);
        HdrDeleteRow();
        Map_SeqNumRecParentEntitle.clear();
        Map_SeqNumRecParentEntitle.putAll(Map_SeqNumRec);
        ParentEntitleExpDetailSize = DetailSize;
        ExpParentEntitle = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Entitlement ---------------------------------------------
    public PageReference HdrADDRowEntitle()
    {
        Exp = ExpParentEntitle;
        DetailSize = ParentEntitleExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecParentEntitle.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecParentEntitle);
        HdrADDRow();
        ParentEntitleExpDetailSize = DetailSize;
        Map_SeqNumRecParentEntitle.clear();
        Map_SeqNumRecParentEntitle.putAll(Map_SeqNumRec);
        ExpParentEntitle = Exp;
        return null;
    }
    
    //----------------------------------------- Delete Row in the Entitlement Line ---------------------------------------------
    public PageReference HdrDeleteRowEntitleLine()
    {
        Exp = ExpLineEntitle;
        DetailSize = LineEntitleExpDetailSize;
        Map_SeqNumRec.clear();
        Map_SeqNumRec.putAll(Map_SeqNumRecLineEntitle);
        HdrDeleteRow();
        Map_SeqNumRecLineEntitle.clear();
        Map_SeqNumRecLineEntitle.putAll(Map_SeqNumRec);
        LineEntitleExpDetailSize = DetailSize;
        ExpLineEntitle = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Entitlement Line ---------------------------------------------
    public PageReference HdrADDRowEntitleLine()
    {
        Exp = ExpLineEntitle;
        DetailSize = LineEntitleExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecLineEntitle.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecLineEntitle);
        HdrADDRow();
        LineEntitleExpDetailSize = DetailSize;
        Map_SeqNumRecLineEntitle.clear();
        Map_SeqNumRecLineEntitle.putAll(Map_SeqNumRec);
        ExpLineEntitle = Exp;
        return null;
    }
    
    //----------------------------------------- Delete Row in the Route Calculations ---------------------------------------------
    public PageReference HdrDeleteRowRouteCalc()
    {
        Exp = ExpParentRouteCalc;
        DetailSize = ParentRouteCalcExpDetailSize;
        Map_SeqNumRec.clear();
        Map_SeqNumRec.putAll(Map_SeqNumRecParentRouteCalc);
        HdrDeleteRow();
        Map_SeqNumRecParentRouteCalc.clear();
        Map_SeqNumRecParentRouteCalc.putAll(Map_SeqNumRec);
        ParentRouteCalcExpDetailSize = DetailSize;
        ExpParentRouteCalc = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Route Calculations ---------------------------------------------
    public PageReference HdrADDRowRouteCalc()
    {
        Exp = ExpParentRouteCalc;
        DetailSize = ParentRouteCalcExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecParentRouteCalc.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecParentRouteCalc);
        HdrADDRow();
        ParentRouteCalcExpDetailSize = DetailSize;
        Map_SeqNumRecParentRouteCalc.clear();
        Map_SeqNumRecParentRouteCalc.putAll(Map_SeqNumRec);
        ExpParentRouteCalc = Exp;
        return null;
    }
    
    //----------------------------------------- Delete Row in the Route Calculations ---------------------------------------------
    public PageReference HdrDeleteRowRouteCalcLine()
    {
        Exp = ExpLineRouteCalc;
        DetailSize = LineRouteCalcExpDetailSize;
        Map_SeqNumRec.clear();
        Map_SeqNumRec.putAll(Map_SeqNumRecLineRouteCalc);
        HdrDeleteRow();
        Map_SeqNumRecLineRouteCalc.clear();
        Map_SeqNumRecLineRouteCalc.putAll(Map_SeqNumRec);
        LineRouteCalcExpDetailSize = DetailSize;
        ExpLineRouteCalc = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Route Calculations ---------------------------------------------
    public PageReference HdrADDRowRouteCalcLine()
    {
        Exp = ExpLineRouteCalc;
        DetailSize = LineRouteCalcExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecLineRouteCalc.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecLineRouteCalc);
        HdrADDRow();
        LineRouteCalcExpDetailSize = DetailSize;
        Map_SeqNumRecLineRouteCalc.clear();
        Map_SeqNumRecLineRouteCalc.putAll(Map_SeqNumRec);
        ExpLineRouteCalc = Exp;
        return null;
    }
    
    //----------------------------------------- Delete Row in the Source Updates Header ---------------------------------------------
    public PageReference srcUpdateHdrDeleteRow()
    {
        LstExp = srcUpdateHdr;
        DetailSize = SrcUpdateHdrSize;
        Map_SeqNumRec.clear();
        Map_SeqNumRec.putAll(Map_SeqNumSrcUpdateHdr);
        SrcUpdateDeleteRow();
        Map_SeqNumSrcUpdateHdr.clear();
        Map_SeqNumSrcUpdateHdr.putAll(Map_SeqNumRec);
        SrcUpdateHdrSize = DetailSize;
        srcUpdateHdr = LstExp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Source Updates Header ---------------------------------------------
    public PageReference srcUpdateHdrADDRow()
    {
        LstExp = srcUpdateHdr;
        DetailSize = SrcUpdateHdrSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumSrcUpdateHdr.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumSrcUpdateHdr);
        SrcUpdateADDRow();
        SrcUpdateHdrSize = DetailSize;
        Map_SeqNumSrcUpdateHdr.clear();
        Map_SeqNumSrcUpdateHdr.putAll(Map_SeqNumRec);
        srcUpdateHdr = LstExp;
        return null;
    }
    
    //----------------------------------------- Delete Row in the Source Updates Lines ---------------------------------------------
    public PageReference srcUpdateLineDeleteRow()
    {
        LstExp = srcUpdateLine;
        DetailSize = srcUpdateLineSize;
        Map_SeqNumRec.clear();
        Map_SeqNumRec.putAll(Map_SeqNumsrcUpdateLine);
        SrcUpdateDeleteRow();
        Map_SeqNumsrcUpdateLine.clear();
        Map_SeqNumsrcUpdateLine.putAll(Map_SeqNumRec);
        srcUpdateLineSize = DetailSize;
        srcUpdateLine = LstExp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Source Updates Lines ---------------------------------------------
    public PageReference srcUpdateLineADDRow()
    {
        LstExp = srcUpdateLine;
        DetailSize = srcUpdateLineSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumsrcUpdateLine.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumsrcUpdateLine);
        SrcUpdateADDRow();
        srcUpdateLineSize = DetailSize;
        Map_SeqNumsrcUpdateLine.clear();
        Map_SeqNumsrcUpdateLine.putAll(Map_SeqNumRec);
        srcUpdateLine = LstExp;
        return null;
    }
    
    //--------------------------------------Methods to add row of Expression details-------------------------------------------------------
    public void HdrADDRow()
    {
        try
        {
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsDetail_Rtype.Id, SVMXC__Sequence__c = Integer.valueOf( Exp.expressionDetails.size() + 1 ) );
            Map_SeqNumRec.put( Math.Round(Integer.valueOf( Exp.expressionDetails.size() + 1 )), NewExpDetailRec );
            Exp.expressionDetails.add( NewExpDetailRec );
            if(Exp.expressionDetails != null)
                DetailSize = Exp.expressionDetails.size();
            else
                DetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    //--------------------------------------Methods to delete row of Expression details-------------------------------------------------------
    public void HdrDeleteRow()
    {
        try
        {
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SeqNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            
            for( integer i=0; i < Exp.expressionDetails.size(); i++ )
            {
                if( Map_SeqNumRec != null && Map_SeqNumRec.get(i + 1) != null && (i + 1) != integer.valueOf(DelIndex) )
                    TempMap_SeqNumRec.put( i + 1 - SeqNumToSubtract, Exp.expressionDetails[i] );
                else if ( Map_SeqNumRec != null && Map_SeqNumRec.get(i + 1) != null && ( (i + 1) == integer.valueOf(DelIndex)) )  
                    SeqNumToSubtract = 1;
            }
            Map_SeqNumRec.clear();
            if( TempMap_SeqNumRec != null )
                Map_SeqNumRec.putAll(TempMap_SeqNumRec);
            
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :Map_SeqNumRec.keyset())
            {
                SequenceCounter++;
                if( Map_SeqNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = Map_SeqNumRec.get(SequenceNumber);
                    TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                    Temp_ExpDetailsLst.add(TempDetailExprObj);
                }
            }
            Exp.expressionDetails.clear();
            Exp.expressionDetails.addAll(Temp_ExpDetailsLst);
            if(Exp.expressionDetails != null)
                DetailSize = Exp.expressionDetails.size();
            else
                DetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    //--------------------------------------Methods to add row of Source Update-------------------------------------------------------
    public void SrcUpdateADDRow()
    {
        try
        {
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsSrcUpdate_Rtype.Id, SVMXC__Sequence__c = Integer.valueOf( LstExp.size() + 1 ) );
            Map_SeqNumRec.put( Math.Round(Integer.valueOf( LstExp.size() + 1 )), NewExpDetailRec );
            LstExp.add( NewExpDetailRec );
            if(LstExp != null)
                DetailSize = LstExp.size();
            else
                DetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    //--------------------------------------Methods to delete row of Source Update-------------------------------------------------------
    public void SrcUpdateDeleteRow()
    {
        try
        {
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SeqNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            
            for( integer i=0; i < LstExp.size(); i++ )
            {
                if( Map_SeqNumRec != null && Map_SeqNumRec.get(i + 1) != null && (i + 1) != integer.valueOf(DelIndex) )
                    TempMap_SeqNumRec.put( i + 1 - SeqNumToSubtract, LstExp[i] );
                else if ( Map_SeqNumRec != null && Map_SeqNumRec.get(i + 1) != null && ( (i + 1) == integer.valueOf(DelIndex)) )  
                    SeqNumToSubtract = 1;
            }
            Map_SeqNumRec.clear();
            if( TempMap_SeqNumRec != null )
                Map_SeqNumRec.putAll(TempMap_SeqNumRec);
            
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :Map_SeqNumRec.keyset())
            {
                SequenceCounter++;
                if( Map_SeqNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = Map_SeqNumRec.get(SequenceNumber);
                    TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                    Temp_ExpDetailsLst.add(TempDetailExprObj);
                }
            }
            LstExp.clear();
            LstExp.addAll(Temp_ExpDetailsLst);
            if(LstExp != null)
                DetailSize = LstExp.size();
            else
                DetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    //------------------------------------------- Methods To Switch Between Tabs --------------------------------------------------------------   
    public void GeneralInfo()
    {
        selectedTab = 'TAB1';
    }
    public void EntitleConfig()
    {
        selectedTab = 'TAB2';
    }
    public void RouteCalcConfig()
    {
        selectedTab = 'TAB3';
    }
    public void RMAConfig()
    {
        selectedTab = 'TAB4';
    }
    public void srcUpdate()
    {
        selectedTab = 'TAB5';
    }
    
    //-----------------------------------------------Method to validate string --------------------------------------------------------
    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }

    //--------------------------------------------- Method to display exceptions ------------------------------------------------------
    public void AddException(String strErrorMessage)
    {
        if(isValidString(strErrorMessage))
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, strErrorMessage));
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, ''));
    }
    
    //------------------------------------------- Method To Save actually ------------------------------------------- 
    public void save()
    {
        validate = true;
        validation();
        if(Validate != false)
            saveExps();
        
        if(Validate != false)
        {
            buildingExpLists();
            if(isCreateNewParentInitRet == true)
                selectedCriteriaInitRet = ExpParentInitRet.namedExpression.Id;
            if(isCreateNewLineInitRet == true)
                selectedCriteriaInitRetLine = ExpLineInitRet.namedExpression.Id;
            if(isCreateNewParentEntitle == true)
                selectedCriteriaEntitle = ExpParentEntitle.namedExpression.Id;
            if(isCreateNewLineEntitle == true)
                selectedCriteriaEntitleLine = ExpLineEntitle.namedExpression.Id;
            if(isCreateNewParentRouteCalc == true)
                selectedCriteriaRouteCalc = ExpParentRouteCalc.namedExpression.Id;
            if(isCreateNewLineRouteCalc == true)
                selectedCriteriaRouteCalcLine = ExpLineRouteCalc.namedExpression.Id;
        
            InitRetProces.SVMXC__Name__c = processName;
            InitRetProces.RecordTypeId = InitRetProcess_Rtype.Id;
            InitRetProces.SVMXC__ProcessID__c = processID;
            InitRetProces.SVMXC__Description__c = processDesc;
            InitRetProces.SVMXC__APL_Perform_Entitlement__c = isPerformEntitle;
            InitRetProces.SVMXC__APL_Perform_Route_Calculations__c = isRouteCalc;
            InitRetProces.SVMXC__Parent_Error_Msg__c = parentInitRetErrorMsg;
            InitRetProces.SVMXC__Child_Error_Msg__c = lineInitRetErrorMsg;
            InitRetProces.SVMXC__APL_Print_RMA_Template__c = templateRMAOrder;
                
            if(isRouteCalc == true)
            {
                if(selectedCriteriaRouteCalc != getTAG024())
                    InitRetProces.SVMXC__Parent_Object__c = selectedCriteriaRouteCalc;
                else
                    InitRetProces.SVMXC__Parent_Object__c = null;
                if(selectedCriteriaRouteCalcLine != getTAG024())
                    InitRetProces.SVMXC__Process__c = selectedCriteriaRouteCalcLine;
                else
                    InitRetProces.SVMXC__Process__c = null;
            }
            
            List<string> lstObjFld = new List<string>();
            lstObjFld = selectedLoc.split(' : ');
            InitRetProces.SVMXC__Consider_Location_From_Object__c = lstObjFld[0];
            InitRetProces.SVMXC__Consider_Location_From__c = lstObjFld[1];
            if(selectedObjMapCase != getTAG024())
                InitRetProces.SVMXC__Process1__c = selectedObjMapCase;
            else
                InitRetProces.SVMXC__Process1__c = null;
            if(selectedObjMapCaseLine != getTAG024())
                InitRetProces.SVMXC__Process2__c = selectedObjMapCaseLine;
            else
                InitRetProces.SVMXC__Process2__c = null;
            if(selectedCriteriaInitRet != getTAG024())
                InitRetProces.SVMXC__Node_Parent__c = ExpParentInitRet.namedExpression.Id;
            else
                InitRetProces.SVMXC__Node_Parent__c = null;
            if(selectedCriteriaInitRetLine != getTAG024())
                InitRetProces.SVMXC__Submodule__c = ExpLineInitRet.namedExpression.Id;
            else
                InitRetProces.SVMXC__Submodule__c = null;
            if(selectedCriteriaEntitle != getTAG024())
                InitRetProces.SVMXC__Module__c = ExpParentEntitle.namedExpression.Id;
            else
                InitRetProces.SVMXC__Module__c = null;
            if(selectedCriteriaEntitleLine != getTAG024())
                InitRetProces.SVMXC__Final_Exception_Process__c = ExpLineEntitle.namedExpression.Id;
            else
                InitRetProces.SVMXC__Final_Exception_Process__c = null;
            
            //upsert InitRetProces;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(InitRetProces, COMM_SecurityUtils.Access.Upsertable)){
                upsert InitRetProces; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            
            if(lstSFMEvent != null || lstSFMEvent.size() > 0){
            	//delete lstSFMEvent;
            	if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SFM_Event__c' ) ) {                        
				    delete lstSFMEvent; //SDL-SVMX-DELETE-FLS-ENFORCED
				} else {
				    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
				}
            }
            
            List<SVMXC__SFM_Event__c> eventToSave = new List<SVMXC__SFM_Event__c>();
            if(isPerformEntitle == true)
            {
                SVMXC__SFM_Event__c event1 = new SVMXC__SFM_Event__c();
                if((entitleNamespace != null || entitleClass != null || entitleMethod != null) && (entitleNamespace != '' || entitleClass != '' || entitleMethod != ''))
                {
                    event1 = fillingSFMEvent(entitleNamespace,entitleClass,entitleMethod,entitleWS,'Before Entitlement');
                    eventToSave.add(event1);
                }
            }
            if(isRouteCalc == true)
            {
                SVMXC__SFM_Event__c event2 = new SVMXC__SFM_Event__c();
                if((routeCalcNamespace != null || routeCalcClass != null || routeCalcMethod != null) && (routeCalcNamespace != '' || routeCalcClass != '' || routeCalcMethod != ''))
                {
                    event2 = fillingSFMEvent(routeCalcNamespace,routeCalcClass,routeCalcMethod,routeCalcWS,'Before Route Calculations');
                    eventToSave.add(event2);
                }
            }
            SVMXC__SFM_Event__c event3 = new SVMXC__SFM_Event__c();
            if((beforeRMAGenNamespace != null || beforeRMAGenClass != null || beforeRMAGenMethod != null) && (beforeRMAGenNamespace != '' || beforeRMAGenClass != '' || beforeRMAGenMethod != ''))
            {
                event3 = fillingSFMEvent(beforeRMAGenNamespace,beforeRMAGenClass,beforeRMAGenMethod,beforeRMAGenWS,'Before RMA Generation');
                eventToSave.add(event3);
            }
            SVMXC__SFM_Event__c event4 = new SVMXC__SFM_Event__c();
            if((afterRMAGenNamespace != null || afterRMAGenClass != null || afterRMAGenMethod != null) && (afterRMAGenNamespace != '' || afterRMAGenClass != '' || afterRMAGenMethod != ''))
            {
                event4 = fillingSFMEvent(afterRMAGenNamespace,afterRMAGenClass,afterRMAGenMethod,afterRMAGenWS,'After RMA Generation');
                eventToSave.add(event4);
            }
            
            if(eventToSave.size() > 0){
                //insert eventToSave;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(eventToSave, COMM_SecurityUtils.Access.Createable)){
                    insert eventToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            
            if(lstSrcUpdate != null)
                delete lstSrcUpdate; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
            if(srcUpdateHdr != null && srcUpdateHdr.size()>0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configdata : srcUpdateHdr)
                {
                    if(configdata.SVMXC__Target_Field_Name__c != getTAG024())
                    {
                        SVMXC__ServiceMax_Config_Data__c newConfigdata = new SVMXC__ServiceMax_Config_Data__c();
                        newConfigdata = fillingConfigData(configdata);
                        lstConfigdataToSave.add(newConfigdata);
                    }
                }
            }
            if(srcUpdateLine != null && srcUpdateLine.size()>0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configdata : srcUpdateLine)
                {
                    if(configdata.SVMXC__Target_Field_Name__c != getTAG024())
                    {
                        SVMXC__ServiceMax_Config_Data__c newConfigdata = new SVMXC__ServiceMax_Config_Data__c();
                        newConfigdata = fillingConfigData(configdata);
                        lstConfigdataToSave.add(newConfigdata);
                    }
                }
            }
            //upsert lstConfigdataToSave;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfigdataToSave, COMM_SecurityUtils.Access.Upsertable)){
                upsert lstConfigdataToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            recordId = InitRetProces.Id;
            queryingdata();
            preparingPicklists();
        }
    }
    
    //---------------------------------------------- Method to fill the SFM Event fields before Saving -------------------------------------------------------
    public SVMXC__SFM_Event__c fillingSFMEvent(string namespace, string clas, string methd, string descr, string eventTyp)
    {
        SVMXC__SFM_Event__c newEvent = new SVMXC__SFM_Event__c();
        newEvent.SVMXC__ServiceMax_Process__c = InitRetProces.Id;
        newEvent.SVMXC__Event_Type__c = eventTyp;
        newEvent.SVMXC__Namespace__c = namespace;
        newEvent.SVMXC__Class__c = clas;
        newEvent.SVMXC__Method__c = methd;
        newEvent.SVMXC__Description__c = descr;
        return newEvent;
    }
    
    //---------------------------------------------- Method to fill the Config data fields before Saving -------------------------------------------------------
    public SVMXC__ServiceMax_Config_Data__c fillingConfigData(SVMXC__ServiceMax_Config_Data__c configdata)
    {
        SVMXC__ServiceMax_Config_Data__c newConfigData = new SVMXC__ServiceMax_Config_Data__c();
        newConfigData.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        newConfigdata.SVMXC__Dispatch_Process__c = InitRetProces.Id;
        if(configdata != null)
        {
            newConfigData.SVMXC__Configuration_Type__c = configdata.SVMXC__Configuration_Type__c;
            newConfigData.SVMXC__Sequence__c = configdata.SVMXC__Sequence__c;
            newConfigData.SVMXC__Target_Field_Name__c = configdata.SVMXC__Target_Field_Name__c;
            newConfigData.SVMXC__Action__c = configdata.SVMXC__Action__c;
            newConfigData.SVMXC__Display_Value__c = configdata.SVMXC__Display_Value__c;
        }
        return newConfigData;
    }
    
    //---------------------------------------------- Validation before Saving -------------------------------------------------------
    public void validation()
    {
        /*boolean b = fieldValidation(srcUpdatePickHdr);
        boolean b1 = fieldValidation(srcUpdatePickLine);
        boolean b2 = fieldValidation(srcUpdateShipHdr);
        boolean b3 = fieldValidation(srcUpdateShipLine);
        
        if(b == false || b1 == false || b2 == false || b3 == false)
            Validate = false;*/
        
        if(processName == null || processName == '')
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG058(),''));
        }
        if(processID == null || processID == '')
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG059(),''));
        }
        if(processID.length() < 8)
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG059(),''));
        }
        system.debug('Value of Location:'+selectedLoc);
    if(selectedLoc == getTAG024())
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG083(),''));
        }
        if((selectedCriteriaInitRet != getTAG024() || isCreateNewParentInitRet == true) && (parentInitRetErrorMsg == '' || parentInitRetErrorMsg == null))
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG075(),''));
        }
        if((selectedCriteriaInitRetLine != getTAG024() || isCreateNewLineInitRet == true) && (lineInitRetErrorMsg == '' || lineInitRetErrorMsg == null))
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG075(),''));
        }
        List<SVMXC__ServiceMax_Processes__c> LstToCheckId = new List<SVMXC__ServiceMax_Processes__c>();
        String UniqueProcessId = processID;
        if(( mode == 'Clone' || mode == 'New')  && isSavedOnce == false )
            LstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: UniqueProcessId AND RecordType.Name = \'Initiate Return Process\'');
        if( ( recordId != null && recordId != '' && mode == 'Edit' )  && isSavedOnce == false)
            LstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: UniqueProcessId AND RecordType.Name = \'Initiate Return Process\' AND Id !=: recordId');
        if( LstToCheckId != null && LstToCheckId.size() > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG059(), ''));
            Validate = false;
        }
    }
    
    //------------------------------------------- Method To Save All the Six Expressions ------------------------------------------- 
    public void saveExps()
    {
        if(ExpParentInitRet != null && ExpParentInitRet.namedExpression.SVMXC__IsStandard__c != true && (selectedCriteriaInitRet != getTAG024() || isCreateNewParentInitRet == true))
        {
            for(integer i=0; i < ExpParentInitRet.expressionDetails.size(); i++)
                ExpParentInitRet.expressionDetails[i].SVMXC__Object_Name2__c = 'Case';
            ExpParentInitRet.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpParentInitRet.expressionDetails);
            Exp = ExpParentInitRet;
            DetailSize = ParentInitRetExpDetailSize;
            submitExp();
        }
        if(ExpLineInitRet != null && ExpLineInitRet.namedExpression.SVMXC__IsStandard__c != true && (selectedCriteriaInitRetLine != getTAG024() || isCreateNewLineInitRet == true))
        {
            for(integer i=0; i < ExpLineInitRet.expressionDetails.size() ; i++)
                ExpLineInitRet.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__Case_Line__c';
            ExpLineInitRet.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpLineInitRet.expressionDetails);
            Exp = ExpLineInitRet;
            DetailSize = LineInitRetExpDetailSize;
            submitExp();
        }
        if(ExpParentEntitle != null && ExpParentEntitle.namedExpression.SVMXC__IsStandard__c != true && (selectedCriteriaEntitle != getTAG024() || isCreateNewParentEntitle == true) && isPerformEntitle == true)
        {
            for(integer i=0; i < ExpParentEntitle.expressionDetails.size() ; i++)
                ExpParentEntitle.expressionDetails[i].SVMXC__Object_Name2__c = 'Case';
            ExpParentEntitle.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpParentEntitle.expressionDetails);
            Exp = ExpParentEntitle;
            DetailSize = ParentEntitleExpDetailSize;
            submitExp();
        }
        if(ExpLineEntitle != null && ExpLineEntitle.namedExpression.SVMXC__IsStandard__c != true && (selectedCriteriaEntitleLine != getTAG024() || isCreateNewLineEntitle == true) && isPerformEntitle == true)
        {
            for(integer i=0; i < ExpLineEntitle.expressionDetails.size() ; i++)
                ExpLineEntitle.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__Case_Line__c';
            ExpLineEntitle.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpLineEntitle.expressionDetails);
            Exp = ExpLineEntitle;
            DetailSize = LineEntitleExpDetailSize;
            submitExp();
        }
        if(ExpParentRouteCalc != null && ExpParentRouteCalc.namedExpression.SVMXC__IsStandard__c != true && (selectedCriteriaRouteCalc != getTAG024() || isCreateNewParentRouteCalc == true) && isRouteCalc == true)
        {
            for(integer i=0; i < ExpParentRouteCalc.expressionDetails.size() ; i++)
                ExpParentRouteCalc.expressionDetails[i].SVMXC__Object_Name2__c = 'Case';
            ExpParentRouteCalc.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpParentRouteCalc.expressionDetails);
            Exp = ExpParentRouteCalc;
            DetailSize = ParentRouteCalcExpDetailSize;
            submitExp();
        }
        if(ExpLineRouteCalc != null && ExpLineRouteCalc.namedExpression.SVMXC__IsStandard__c != true && (selectedCriteriaRouteCalcLine != getTAG024() || isCreateNewLineRouteCalc == true) && isRouteCalc == true)
        {
            for(integer i=0; i < ExpLineRouteCalc.expressionDetails.size() ; i++)
                ExpLineRouteCalc.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__Case_Line__c';
            ExpLineRouteCalc.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpLineRouteCalc.expressionDetails);
            Exp = ExpLineRouteCalc;
            DetailSize = LineRouteCalcExpDetailSize;
            submitExp();
        }
    }
    
    //------------------------------------------------Method to save One Expression----------------------------------------------------------------------
    public void submitExp()
    {
        if(Exp.namedExpression != null && Exp.namedExpression.SVMXC__Name__c != null && (Exp.namedExpression.SVMXC__Name__c).length() > 0 &&  Exp.namedExpression.SVMXC__ProcessID__c != null && (Exp.namedExpression.SVMXC__ProcessID__c).length() > 0 )
        {
            SFM_WrapperDef.SFM_Response Save_Response = new SFM_WrapperDef.SFM_Response();
            try
            {
                Exp.namedExpression.SVMXC__SettingId__c = Exp.namedExpression.SVMXC__ProcessID__c;
                List<SVMXC__ServiceMax_Config_Data__c> ExpressionDetails2Save = new List<SVMXC__ServiceMax_Config_Data__c>(); 
                for(SVMXC__ServiceMax_Config_Data__c expressiondtlRec :Exp.expressionDetails)
                {
                    /* if( (expressiondtlRec.SVMXC__Operator__c == null || expressiondtlRec.SVMXC__Operator__c == 'SVMX.NONE') && (expressiondtlRec.SVMXC__Operand__c == null || expressiondtlRec.SVMXC__Operand__c == '') && expressiondtlRec.SVMXC__Field_Name__c == 'None' )
                        continue;
                    else
                        ExpressionDetails2Save.add(expressiondtlRec); */
          // Neeraj(March-5th-2012): Changed the condition to handle defect 002955.
          if(expressiondtlRec.SVMXC__Operator__c != null && expressiondtlRec.SVMXC__Operator__c != 'SVMX.NONE' && expressiondtlRec.SVMXC__Field_Name__c != 'None' && expressiondtlRec.SVMXC__Field_Name__c != 'SVMX.NONE')
            ExpressionDetails2Save.add(expressiondtlRec);
                }
                Exp.expressionDetails.clear();
                if(ExpressionDetails2Save.size()>0)
                    Exp.expressionDetails.addAll(ExpressionDetails2Save);
                DetailSize = Math.Round(Exp.expressionDetails.size());
                
                if(DetailSize >0)
                {
                    SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(Exp.namedExpression,Exp.expressionDetails);
                    List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                    LstSFM_Exp.add(oSFM_Exp);
                    SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                    SVMXC.SFM_saveExpression saveExp = new SVMXC.SFM_saveExpression();
                    Save_Response = saveExp.SFM_saveExpression(oRequest);
                    
                    if( Save_Response != null && Save_Response.success != null)
                    {
                        if(Boolean.valueOf(Save_Response.success))
                        {
                            if( Save_Response.resultIds != null && Save_Response.resultIds.size() > 0 )
                            {
                                savedExpressionResultId = Save_Response.resultIds[0];
                                setsavedExpressionResultId(Save_Response.resultIds[0]);
                            }
                        }
                        else
                        {
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + Save_Response.message ));
                            validate = false;
                            HdrADDRow(); //Method called to add row
                            HdrADDRow(); //Method called to add row
                        }
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG079()));
                        validate = false;
                    }
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG080()));
                    validate = false;
                    HdrADDRow(); //Method called to add row
                    HdrADDRow(); //Method called to add row
                }   
            }
            catch(Exception ex)
            {
                if( Save_Response != null && Save_Response.message != null && Save_Response.success == false )
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''+Save_Response.message + ': ' + ex.getmessage()));
                    validate = false;
                }
            }
        }
        else
        {
            if( Exp.namedExpression == null || Exp.namedExpression.SVMXC__Name__c == null || Exp.namedExpression.SVMXC__Name__c == '' || (Exp.namedExpression.SVMXC__Name__c).length() == 0 )
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG081()));
                validate = false;
            }
            if( Exp.namedExpression == null || Exp.namedExpression.SVMXC__ProcessID__c == null || Exp.namedExpression.SVMXC__ProcessID__c == '' || (Exp.namedExpression.SVMXC__ProcessID__c).length() == 0 )
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG082()));
                validate = false;
            }
        }
    }
    
    //------------------------------------------- Method To Quick Save ------------------------------------------- 
    public pageReference quickSave()
    {
        save();
        if(Validate != false)
        {
            isSavedOnce = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG073(),''));
        }
        return null;
    }
    
    //----------------------------------- Method To Save and Close ---------------------------------------------------
    public pageReference saveClose()
    {
        save();
        if(Validate != false)
        {
            isSavedOnce = true;
            pageReference pageref1 = Page.CONF_ManageInitiateReturnProcesses ;
            return pageref1;
        }
        return null;
    }
    
    //------------------------------------------- Method To Cancel --------------------------------------------------------------   
    public pageReference cancel()
    {
         pageReference pageref1 = Page.CONF_ManageInitiateReturnProcesses;
         return pageref1;
    }
    
    //--------------------------------------------- Getter for custom Labels ------------------------------------------------------
    public String getTAG001() {return system.label.CONF025_TAG019;}//Setup Return Process
    public String getTAG002() {return system.label.CONF025_TAG020;}//Quick Save
    public String getTAG003() {return system.label.CONF025_TAG021;}//Save and Close
    public String getTAG004() {return system.label.CONF025_TAG022;}//Cancel
    public String getTAG005() {return system.label.CONF025_TAG023;}//General Info
    public String getTAG006() {return system.label.CONF025_TAG024;}//Entitlement
    public String getTAG007() {return system.label.CONF025_TAG025;}//Source Updates
    public String getTAG008() {return system.label.CONF025_TAG026;}//Routing
    public String getTAG009() {return system.label.CONF025_TAG027;}//RMA Creation
    public String getTAG010() {return system.label.CONF025_TAG028;}//Links and Other Details
    public String getTAG011() {return system.label.CONF025_TAG011;}//Process Name
    public String getTAG012() {return system.label.CONF025_TAG010;}//Process Id
    public String getTAG013() {return system.label.CONF025_TAG012;}//Description
    public String getTAG014() {return system.label.CONF025_TAG029;}//Using the expression-builder below, indicate how Case qualifies for this return process
    public String getTAG015() {return system.label.CONF025_TAG016;}//Processing...
    public String getTAG016() {return system.label.CONF025_TAG030;}//Use an existing criteria from the list
    public String getTAG017() {return system.label.CONF025_TAG031;}//View/Edit
    public String getTAG018() {return system.label.CONF025_TAG032;}//Or Create a new criteria
    public String getTAG019() {return system.label.CONF025_TAG033;}//Expression Name
    public String getTAG020() {return system.label.CONF025_TAG034;}//Expression ID
    public String getTAG021() {return system.label.CONF025_TAG035;}//Field
    public String getTAG022() {return system.label.CONF025_TAG036;}//Operator
    public String getTAG023() {return system.label.CONF025_TAG037;}//Value
    public String getTAG024() {return system.label.CONF025_TAG038;}//--None--
    public String getTAG025() {return system.label.CONF025_TAG039;}//Advanced Expression
    public String getTAG026() {return system.label.CONF025_TAG040;}//Error message to display if the Case does not meet the above criteria
    public String getTAG027() {return system.label.CONF025_TAG041;}//Using the expression-builder below, indicate how Case Line records qualify for this Return process
    public String getTAG028() {return system.label.CONF025_TAG042;}//Perform Entitlement
    public String getTAG029() {return system.label.CONF025_TAG043;}//Using the expression-builder below, indicate how the Case qualifies for entitlement check.
    public String getTAG030() {return system.label.CONF025_TAG044;}//Using the expression-builder below, indicate how Case Line records qualify for entitlement check.
    public String getTAG031() {return system.label.CONF025_TAG045;}//In this section, configure the automatic field updates to Case after entitlement check is performed.
    public String getTAG032() {return system.label.CONF025_TAG046;}//Field Name
    public String getTAG033() {return system.label.CONF025_TAG047;}//In this section, configure the automatic field updates to Case lines after entitlement check is performed.
    public String getTAG034() {return system.label.CONF025_TAG048;}//Perform Route Calculation
    public String getTAG035() {return system.label.CONF025_TAG049;}//Using the expression-builder below, indicate how the Case qualifies for Route Calculation.
    public String getTAG036() {return system.label.CONF025_TAG050;}//Using the expression-builder below, indicate how case line records qualify for Route Calculations.
    public String getTAG037() {return system.label.CONF025_TAG051;}//In this section, configure the automatic field updates to Case after route calculation is performed.
    public String getTAG038() {return system.label.CONF025_TAG052;}//In this section, configure the automatic field updates to Case lines after route calculation is performed.
    public String getTAG039() {return system.label.CONF025_TAG053;}//Configure Custom Events
    public String getTAG040() {return system.label.CONF025_TAG054;}//Before Entitlement
    public String getTAG041() {return system.label.CONF025_TAG055;}//Before Route Calculations
    public String getTAG042() {return system.label.CONF025_TAG056;}//Before RMA Creation
    public String getTAG043() {return system.label.CONF025_TAG057;}//After RMA Creation
    public String getTAG044() {return system.label.CONF025_TAG058;}//Namespace Prefix
    public String getTAG045() {return system.label.CONF025_TAG059;}//Web service class name
    public String getTAG046() {return system.label.CONF025_TAG060;}//Method name
    public String getTAG047() {return system.label.CONF025_TAG061;}//Description
    public String getTAG048() {return system.label.CONF025_TAG062;}//Object Mapping to Create RMA(s)
    public String getTAG049() {return system.label.CONF025_TAG063;}//Use this field-map to create RMA from Case
    public String getTAG050() {return system.label.CONF025_TAG064;}//Use this field-map to create RMA Lines from Case Lines
    public String getTAG051() {return system.label.CONF025_TAG065;}//Other Details
    public String getTAG052() {return system.label.CONF025_TAG066;}//VisualForce page name to use for printing RMAs
    public String getTAG053() {return system.label.CONF025_TAG067;}//When
    public String getTAG054() {return system.label.CONF025_TAG068;}//After Entitlement
    public String getTAG055() {return system.label.CONF025_TAG069;}//After Route Calc
    public String getTAG056() {return system.label.CONF025_TAG070;}//After RMA Creation
    public String getTAG057() {return system.label.CONF025_TAG071;}//Consider Location from
    public String getTAG058() {return system.label.CONF025_TAG072;}//Please enter a valid process name
    public String getTAG059() {return system.label.CONF025_TAG073;}//Process ID must be unique and at least 8 characters long.
    public String getTAG060() {return system.label.COMM002_TAG006;}//Equals
    public String getTAG061() {return system.label.COMM002_TAG007;}//Not Equal
    public String getTAG062() {return system.label.COMM002_TAG008;}//Greater Than
    public String getTAG063() {return system.label.COMM002_TAG009;}//Greater or Equal To
    public String getTAG064() {return system.label.COMM002_TAG010;}//Less Than
    public String getTAG065() {return system.label.COMM002_TAG011;}//Less or Equal To
    public String getTAG066() {return system.label.COMM002_TAG012;}//Starts With
    public String getTAG067() {return system.label.COMM002_TAG013;}//Contains
    public String getTAG068() {return system.label.COMM002_TAG014;}//Does Not Contain
    public String getTAG069() {return system.label.COMM002_TAG015;}//Includes
    public String getTAG070() {return system.label.COMM002_TAG016;}//Excludes
    public String getTAG071() {return system.label.COMM002_TAG022;}//Is Null
    public String getTAG072() {return system.label.COMM002_TAG023;}//Is Not Null
    public String getTAG073() {return system.label.CONF025_TAG074;}//Process saved.
    public String getTAG074() {return system.label.COMM002_TAG017;}//Set
    public String getTAG075() {return system.label.CONF025_TAG080;}//'Please enter error message for the criterias does not satisfy.'
    public String getTAG076() {return system.label.CONF025_TAG081;}//'This Case does not match the criteria for return process.'
    public String getTAG077() {return system.label.CONF025_TAG082;}//'No Case lines match the criteria for return process.'
    public String getTAG078() {return system.label.CONF025_TAG083;} //'Unable to proceed. Required number of parameters not available in the URL or the given parameters are invalid. Please contact your ServiceMax administrator to resolve this.'
    public String getTAG079() {return system.label.CONF025_TAG075;}//An internal error occurred. Please try this operation later. If the problem persists, please contact ServiceMax support for assistance.
    public String getTAG080() {return system.label.CONF025_TAG076;}//Invalid expression
    public String getTAG081() {return system.label.CONF025_TAG077;}//Please enter a valid Expression Name.
    public String getTAG082() {return system.label.CONF025_TAG078;}//Expression ID should be atleast 8 characters long.
    public String getTAG083() {return system.label.CONF025_TAG079;}//Please select a valid location.
    //public String getTAG084() {return 'CASE';}//'system.label.CONF025_TAG020'
    //public String getTAG085() {return 'CASE LINE';}//system.label.CONF025_TAG020
    //public String getTAG086() {return 'ACCOUNT';}//system.label.CONF025_TAG020
    public String getTAG087() {return system.label.COMM002_TAG032;}//'Add Row'
    public String getTAG088() {return system.label.COMM002_TAG033;}//'Delete Row'
    public string getHLPURL() {return system.label.CONF025_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
}