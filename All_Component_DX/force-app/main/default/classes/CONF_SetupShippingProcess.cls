public with sharing class CONF_SetupShippingProcess
{
    //-------------------------------------- Variables and Getter-Setter Methods ------------------------------------------------------
    public SVMXC__ServiceMax_Processes__c shpngProces = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getshpngProces(){return this.shpngProces;}
    public void setshpngProces(SVMXC__ServiceMax_Processes__c proces){this.shpngProces = proces;}
    public List<SVMXC__ServiceMax_Processes__c> actionsLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getactionsLst(){return this.actionsLst;}
    public void setactionsLst(List<SVMXC__ServiceMax_Processes__c> o){this.actionsLst = o;}
    public List<SVMXC__ServiceMax_Processes__c> ObjMapRMALst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getObjMapRMALst(){return this.ObjMapRMALst;}
    public void setObjMapRMALst(List<SVMXC__ServiceMax_Processes__c> o){this.ObjMapRMALst = o;}
    public List<SVMXC__ServiceMax_Processes__c> ObjMapRMALineLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getObjMapRMALineLst(){return this.ObjMapRMALineLst;}
    public void setObjMapRMALineLst(List<SVMXC__ServiceMax_Processes__c> o){this.ObjMapRMALineLst = o;}
    
    public List<SVMXC__SFM_Event__c> lstSFMEvent = new List<SVMXC__SFM_Event__c>();
    public List<SVMXC__SFM_Event__c> getlstSFMEvent(){return this.lstSFMEvent;}
    public void setlstSFMEvent(List<SVMXC__SFM_Event__c> o){this.lstSFMEvent = o;}
    
    public List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataForSrcUpdate = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> srcUpdatePickHdr = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getsrcUpdatePickHdr(){return this.srcUpdatePickHdr;}
    public void setsrcUpdatePickHdr(List<SVMXC__ServiceMax_Config_Data__c> o){this.srcUpdatePickHdr = o;}
    public List<SVMXC__ServiceMax_Config_Data__c> srcUpdateShipHdr = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getsrcUpdateShipHdr(){return this.srcUpdateShipHdr;}
    public void setsrcUpdateShipHdr(List<SVMXC__ServiceMax_Config_Data__c> o){this.srcUpdateShipHdr = o;}
    public List<SVMXC__ServiceMax_Config_Data__c> srcUpdatePickLine = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getsrcUpdatePickLine(){return this.srcUpdatePickLine;}
    public void setsrcUpdatePickLine(List<SVMXC__ServiceMax_Config_Data__c> o){this.srcUpdatePickLine = o;}
    public List<SVMXC__ServiceMax_Config_Data__c> srcUpdateShipLine = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getsrcUpdateShipLine(){return this.srcUpdateShipLine;}
    public void setsrcUpdateShipLine(List<SVMXC__ServiceMax_Config_Data__c> o){this.srcUpdateShipLine = o;}
    
    List<SVMXC__ServiceMax_Config_Data__c> LstExp = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    APL_Utils APLUtilObj = new APL_Utils();
    
    public string mode;
    public string processName{get;set;}
    public string processID{get;set;}
    public string processDesc{get;set;}
    //public string selectedProductAttribute1{get;set;}
    //public string selectedProductAttribute2{get;set;}
    /* public List<SelectOption> lstProductAttributes = new List<SelectOption>();
    public List<SelectOption> getlstProductAttributes(){return this.lstProductAttributes;} 
    public void setlstProductAttributes(List<SelectOption> lstField){this.lstProductAttributes = lstField;} */
    public List<SelectOption> lstUpdateOperator = new List<SelectOption>();
    public List<SelectOption> getlstUpdateOperator(){return this.lstUpdateOperator;} 
    public void setlstUpdateOperator(List<SelectOption> lstField){this.lstUpdateOperator = lstField;}
    //public string selectedSrlNoSrc{get;set;}
    //public string selectedProdSrl{get;set;}
    /* public List<SelectOption> lstProdSrl = new List<SelectOption>();
    public List<SelectOption> getlstProdSrl(){return this.lstProdSrl;} 
    public void setlstProdSrl(List<SelectOption> lstField){this.lstProdSrl = lstField;} */
    public string selectedFldShpmntDoc1{get;set;}
    public string selectedFldShpmntDoc2{get;set;}
    public string selectedFldShpmntDoc3{get;set;}
    public string selectedFldShpmntDocLine1{get;set;}
    public string selectedFldShpmntDocLine2{get;set;}
    public List<SelectOption> lstFldShpmntDoc = new List<SelectOption>();
    public List<SelectOption> getlstFldShpmntDoc(){return this.lstFldShpmntDoc;} 
    public void setlstFldShpmntDoc(List<SelectOption> lstField){this.lstFldShpmntDoc = lstField;}
    public List<SelectOption> lstFldShpmntDocLine = new List<SelectOption>();
    public List<SelectOption> getlstFldShpmntDocLine(){return this.lstFldShpmntDocLine;} 
    public void setlstFldShpmntDocLine(List<SelectOption> lstField){this.lstFldShpmntDocLine = lstField;}
    public string selectedCriteriaParentPick{get;set;}
    public List<SelectOption> lstCriteriaParentPick = new List<SelectOption>();
    public List<SelectOption> getlstCriteriaParentPick(){return this.lstCriteriaParentPick;} 
    public void setlstCriteriaParentPick(List<SelectOption> lstField){this.lstCriteriaParentPick = lstField;}
    public string parentCriteriaNamePick{get;set;}
    public string lineCriteriaNamePick{get;set;}
    public string parentCriteriaErrorPick{get;set;}
    public string lineCriteriaErrorPick{get;set;}
    public string selectedCriterialinePick{get;set;}
    
    
    public string selectedCriteriaProdStock{get;set;}
    
    public List<SelectOption> lstCriterialinePick = new List<SelectOption>();
    public List<SelectOption> getlstCriterialinePick(){return this.lstCriterialinePick;} 
    public void setlstCriterialinePick(List<SelectOption> lstField){this.lstCriterialinePick = lstField;}
    
    // Neeraj: Added list of Select option to support Product stock expression.
    public List<SelectOption> lstCriteriaProdStock = new List<SelectOption>();
    public List<SelectOption> getlstCriteriaProdStock(){return this.lstCriteriaProdStock;} 
    public void setlstCriteriaProdStock(List<SelectOption> lstField){this.lstCriteriaProdStock = lstField;}
    public List<selectoption> ProdStockFldList = new List<selectoption>();
    public List<selectoption> getProdStockFldList() {return this.ProdStockFldList;}
    
    public string selectedCriteriaParentShip{get;set;}
    public string parentCriteriaNamePack{get;set;}
    public string lineCriteriaNamePack{get;set;}
    public string parentCriteriaErrorShip{get;set;}
    public string lineCriteriaErrorShip{get;set;}
    public string selectedCriterialineShip{get;set;}
    //public boolean allowPartialShipment{get;set;}
    public boolean DisableEditLnkParentPick{get;set;}
    public boolean renderParentPickExprBlock{get;set;}
    public boolean DisableEditLnkLinePick{get;set;}
    public boolean renderLinePickExprBlock{get;set;}
    public boolean renderProdStkExprBlock{get;set;}
    public boolean DisableEditLnkProdStock{get;set;}
    
    public boolean DisableEditLnkParentShip{get;set;}
    public boolean renderParentShipExprBlock{get;set;}
    public boolean DisableEditLnkLineShip{get;set;}
    public boolean renderLineShipExprBlock{get;set;}
    
    public string nameSpacePick{get;set;}
    public string nameSpaceShip{get;set;}
    public string nameSpaceClosure{get;set;}
    public string classNamePick{get;set;}
    public string classNameShip{get;set;}
    public string classNameClosure{get;set;}
    public string methodNamePick{get;set;}
    public string methodNameShip{get;set;}
    public string methodNameClosure{get;set;}
    public string detailOfWSPick{get;set;}
    public string detailOfWSShip{get;set;}
    public string detailOfWSClosure{get;set;}
    /* public string selectedCustmActn1{get;set;}
    public string selectedCustmActn2{get;set;}
    public string selectedCustmActn3{get;set;} */
    public string selectedInternalRMAMap{get;set;}
    public string selectedInternalRMALineMap{get;set;}
    public string selectedSupplierRMAMap{get;set;}
    public string selectedSupplierRMALineMap{get;set;}
    //public string VFTempltPrintLabel{get;set;}
    //public string VFTempltShipmentNote{get;set;}
    /* public List<SelectOption> lstCustmActn = new List<SelectOption>();
    public List<SelectOption> getlstCustmActn(){return this.lstCustmActn;} 
    public void setlstCustmActn(List<SelectOption> lstField){this.lstCustmActn = lstField;} */
    public List<SelectOption> lstObjMapRMA = new List<SelectOption>();
    public List<SelectOption> getlstObjMapRMA(){return this.lstObjMapRMA;} 
    public void setlstObjMapRMA(List<SelectOption> lstField){this.lstObjMapRMA = lstField;}
    public List<SelectOption> lstObjMapRMALine = new List<SelectOption>();
    public List<SelectOption> getlstObjMapRMALine(){return this.lstObjMapRMALine;} 
    public void setlstObjMapRMALine(List<SelectOption> lstField){this.lstObjMapRMALine = lstField;}
    public string selectedTab{get;set;}
    public boolean disableLineRecord{get;set;}
    public boolean createInternalRMA{get;set;}
    public boolean createSupplierRMA{get;set;}
    public boolean disabled{get;set;}
    public List<SelectOption> OperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getOperatorSelectLst(){return OperatorSelectLst;}
    public boolean Validate;
    public boolean disableValue{get;set;}
    
    public List<selectoption> Hdrfldlist=new List<selectoption>();
    public List<selectoption> getHdrfldlist() {return this.Hdrfldlist;}
    
    public List<selectoption> LinefldList = new List<selectoption>();
    public List<selectoption> getLinefldList() {return this.LinefldList;}
    public string delIndex;
    public string getdelIndex (){return this.delIndex;}
    public void setdelIndex (string str){this.delIndex = str;}
    
    public SFM_WrapperDef.SFM_Response_Expression responseExpParentPick = new SFM_WrapperDef.SFM_Response_Expression();
    public SFM_WrapperDef.SFM_Response_Expression responseExpLinePick = new SFM_WrapperDef.SFM_Response_Expression();
    public SFM_WrapperDef.SFM_Response_Expression responseExpParentShip = new SFM_WrapperDef.SFM_Response_Expression();
    public SFM_WrapperDef.SFM_Response_Expression responseExpLineShip = new SFM_WrapperDef.SFM_Response_Expression();
    
    public SFM_WrapperDef.SFM_Response_Expression responseExpProdStock = new SFM_WrapperDef.SFM_Response_Expression();
    
    //Neeraj: Added to support Product stock.
    public SFM_WrapperDef.SFM_Expression ExpProdStock = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpProdStock(){return this.ExpProdStock;}
    public void setExpProdStock(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpProdStock = sfmExp;}
    
    public SFM_WrapperDef.SFM_Expression ExpParentPick = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpParentPick(){return this.ExpParentPick;}
    public void setExpParentPick(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpParentPick = sfmExp;}
    public SFM_WrapperDef.SFM_Expression ExpLinePick = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpLinePick(){return this.ExpLinePick;}
    public void setExpLinePick(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpLinePick = sfmExp;}
    public SFM_WrapperDef.SFM_Expression ExpParentShip = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpParentShip(){return this.ExpParentShip;}
    public void setExpParentShip(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpParentShip = sfmExp;}
    public SFM_WrapperDef.SFM_Expression ExpLineShip = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpLineShip(){return this.ExpLineShip;}
    public void setExpLineShip(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpLineShip = sfmExp;}
    public SFM_WrapperDef.SFM_Expression Exp = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExp(){return this.Exp;}
    public void setExp(SFM_WrapperDef.SFM_Expression Exp){this.Exp = Exp;}
    
    RecordType ExpressionHeader_Rtype;
    RecordType ExpressionsDetail_Rtype;
    RecordType ExpressionsSrcUpdate_Rtype;
    RecordType ObjMap_Rtype;
    RecordType ShippingProcess_Rtype;
    
    public Integer ProdStockExpSize = 0;
    public Integer getProdStockExpSize(){ return ProdStockExpSize;}
    
    public Integer DetailSize = 0;
    public Integer ParentPickExpDetailSize = 0;
    public Integer getParentPickExpDetailSize(){ return ParentPickExpDetailSize;}
    public Integer LinePickExpDetailSize = 0;
    public Integer getLinePickExpDetailSize(){ return LinePickExpDetailSize;}
    public Integer ParentShipExpDetailSize = 0;
    public Integer getParentShipExpDetailSize(){ return ParentShipExpDetailSize;}
    public Integer LineShipExpDetailSize = 0;
    public Integer getLineShipExpDetailSize(){ return LineShipExpDetailSize;}
    public Integer SrcUpdateParentPickExpSize = 0;
    public Integer getSrcUpdateParentPickExpSize(){ return SrcUpdateParentPickExpSize;}
    public Integer SrcUpdateLinePickExpSize = 0;
    public Integer getSrcUpdateLinePickExpSize(){ return SrcUpdateLinePickExpSize;}
    public Integer SrcUpdateParentShipExpSize = 0;
    public Integer getSrcUpdateParentShipExpSize(){ return SrcUpdateParentShipExpSize;}
    public Integer SrcUpdateLineShipExpSize = 0;
    public Integer getSrcUpdateLineShipExpSize(){ return SrcUpdateLineShipExpSize;}
    
    public COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    
    public String savedExpressionResultId;
    public String getsavedExpressionResultId() { return savedExpressionResultId;}
    public void setsavedExpressionResultId(String val){this.savedExpressionResultId = val;}
    
    public boolean isCreateNewParentPick;
    public boolean isCreateNewLinePick;
    public boolean isCreateNewParentShip;
    public boolean isCreateNewLineShip;
    public boolean isCreateNewProdStock;
    
    public boolean isSavedOnce;
    public string recordId;
    
    //------------------------------------------------Constructor/OnLoad------------------------------------------------------------------
    public CONF_SetupShippingProcess()
    {
        mode = System.currentPageReference().getParameters().get('SVMX_Mode');
        recordId = System.currentPageReference().getParameters().get('SVMX_RecordId');
        
        setDefaultValues();
        retrieveRecordTypes();
        preparingPicklists();
        
        if(mode != 'New' && recordId != null && recordId != '')
        {
            if(mode == 'View')
                disabled = true;
            
            queryingdata();
        }
        if(mode == 'New' || mode == 'Clone')
        {
            shpngProces = new SVMXC__ServiceMax_Processes__c();
            lstConfigdataForSrcUpdate = new List<SVMXC__ServiceMax_Config_Data__c>();
            if(mode == 'New')
            {
                srcUpdateADDRowParentPick();
                srcUpdateADDRowLinePick();
                srcUpdateADDRowParentShip();
                srcUpdateADDRowLineShip();
            }
        }
    }
    
    //-------------------------------- Method to set Default Values for different Variables ------------------------------------
    public void setDefaultValues()
    {
        disableLineRecord = false;
        DisableEditLnkParentPick = true;
        DisableEditLnkLinePick = true;
        renderParentPickExprBlock = false;
        renderLinePickExprBlock = false;
        DisableEditLnkParentShip = true;
        DisableEditLnkLineShip = true;
        DisableEditLnkProdStock = true;
        renderParentShipExprBlock = false;
        renderLineShipExprBlock = false;
        Validate = true;
        isCreateNewParentPick = false;
        isCreateNewLinePick = false;
        isCreateNewParentShip = false;
        isCreateNewLineShip = false;
        isCreateNewProdStock = false;
        disabled = false;
        isSavedOnce = false;
        parentCriteriaErrorPick = getTAG021();
        lineCriteriaErrorPick = getTAG022();
        parentCriteriaErrorShip = getTAG098();
        lineCriteriaErrorShip = getTAG099();
        selectedCriteriaParentPick = getTAG026();
        selectedCriterialinePick = getTAG026();
        selectedCriteriaParentShip = getTAG026();
        selectedCriterialineShip = getTAG026();
        selectedCriteriaProdStock = getTAG026();
    }
    
    //---------------------------------------- Method to retrieve All the Record Types -----------------------------------------
    public void retrieveRecordTypes()
    {
        ExpressionHeader_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ExpressionsDetail_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ObjMap_Rtype = [select Id from RecordType where Name='Object Mapping'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ShippingProcess_Rtype = [select Id from RecordType where Name='Shipping Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    
    //---------------------------------------- Method to query All the SFM Events and Config Data -----------------------------------------
    public void queryingdata()
    {
        srcUpdatePickHdr.clear();
        srcUpdateShipHdr.clear();
        srcUpdatePickLine.clear();
        srcUpdateShipLine.clear();
        if(recordId != null && recordId.length() >0)
            shpngProces = [Select  SVMXC__Name__c, SVMXC__Process__c, SVMXC__APL_Print_Label_Template__c, SVMXC__APL_Shipment_Note_Template__c, SVMXC__Parent_Object__c, SVMXC__ProcessID__c, SVMXC__Description__c,SVMXC__Process1__c, SVMXC__Process2__c,SVMXC__Process3__c, SVMXC__APL_Serial_Number_Source__c, SVMXC__APL_Scan_First__c, SVMXC__Source_Object_Name__c, SVMXC__Active__c, SVMXC__Node_Parent__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Final_Exception_Process__c, SVMXC__Parent_Error_Msg__c, SVMXC__APL_Split_Lines__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Child_Error_Msg2__c, SVMXC__APL_Allow_Partial_Shipment__c, SVMXC__APL_Create_Internal_RMA__c, SVMXC__APL_Create_Supplier_RMA__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where Id =: recordId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
        if(shpngProces != null)
        {
            processName = shpngProces.SVMXC__Name__c;
            processID = shpngProces.SVMXC__ProcessID__c;
            processDesc = shpngProces.SVMXC__Description__c;
            //selectedSrlNoSrc = shpngProces.SVMXC__APL_Serial_Number_Source__c;
            //selectedProdSrl = shpngProces.SVMXC__APL_Scan_First__c;
            parentCriteriaErrorPick = shpngProces.SVMXC__Parent_Error_Msg__c;
            lineCriteriaErrorPick = shpngProces.SVMXC__Child_Error_Msg__c;
            parentCriteriaErrorShip = shpngProces.SVMXC__Parent_Error_Msg2__c;
            lineCriteriaErrorShip = shpngProces.SVMXC__Child_Error_Msg2__c;
            //allowPartialShipment = shpngProces.SVMXC__APL_Allow_Partial_Shipment__c;
            createInternalRMA = shpngProces.SVMXC__APL_Create_Internal_RMA__c;
            createSupplierRMA = shpngProces.SVMXC__APL_Create_Supplier_RMA__c;
            selectedInternalRMAMap = shpngProces.SVMXC__Parent_Object__c;
            selectedInternalRMALineMap = shpngProces.SVMXC__Process__c;
            selectedSupplierRMAMap = shpngProces.SVMXC__Process1__c;
            selectedSupplierRMALineMap = shpngProces.SVMXC__Process2__c;
            //VFTempltPrintLabel = shpngProces.SVMXC__APL_Print_Label_Template__c;
            //VFTempltShipmentNote = shpngProces.SVMXC__APL_Shipment_Note_Template__c;
            
            if(shpngProces.SVMXC__IsStandard__c == true && (shpngProces.SVMXC__Parent_Error_Msg__c == null || shpngProces.SVMXC__Parent_Error_Msg__c == getTAG021()))
                parentCriteriaErrorPick = getTAG021();
            if(shpngProces.SVMXC__IsStandard__c == true && (shpngProces.SVMXC__Child_Error_Msg__c == null || shpngProces.SVMXC__Child_Error_Msg__c == getTAG022()))
                lineCriteriaErrorPick = getTAG022();
            if(shpngProces.SVMXC__IsStandard__c == true && (shpngProces.SVMXC__Parent_Error_Msg2__c == null || shpngProces.SVMXC__Parent_Error_Msg2__c == getTAG098()))
                parentCriteriaErrorShip = getTAG098();
            if(shpngProces.SVMXC__IsStandard__c == true && (shpngProces.SVMXC__Child_Error_Msg2__c == null || shpngProces.SVMXC__Child_Error_Msg2__c == getTAG099()))
                lineCriteriaErrorShip = getTAG099();
            
            if(mode == 'Clone')
                shpngProces.SVMXC__IsStandard__c = false;
                
            if(shpngProces.SVMXC__Node_Parent__c != null)
            {
                responseExpParentPick = retrieveExpDetails(shpngProces.SVMXC__Node_Parent__c);
                if(responseExpParentPick.expressions.size() > 0)
                {
                    ExpParentPick = responseExpParentPick.expressions[0];
                    selectedCriteriaParentPick = ExpParentPick.namedExpression.Id;
                    Map_SequenceNumRecParentPick.clear();
                    for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentPick.expressionDetails)
                        Map_SequenceNumRecParentPick.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                    DisableEditLnkParentPick = false;
                    ParentPickExpDetailSize = ExpParentPick.expressionDetails.size();
                }
            }
            system.debug('Shipping Process value:'+shpngProces.SVMXC__Process3__c);
            if(shpngProces.SVMXC__Process3__c != null)
            {
                responseExpProdStock = retrieveExpDetails(shpngProces.SVMXC__Process3__c);
                system.debug('Selected picklist value:'+responseExpProdStock);
                if(responseExpProdStock.expressions.size() > 0)
                {
                    ExpProdStock = responseExpProdStock.expressions[0];
                    selectedCriteriaProdStock = ExpProdStock.namedExpression.Id;
                    Map_SequenceNumRecParentPick.clear();
                    for(SVMXC__ServiceMax_Config_Data__c confData : ExpProdStock.expressionDetails)
                        Map_SequenceNumRecParentPick.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                    DisableEditLnkProdStock = false;
                    ProdStockExpSize = ExpProdStock.expressionDetails.size();
                }
            }
            
            if(shpngProces.SVMXC__Submodule__c != null)
            {
                responseExpLinePick = retrieveExpDetails(shpngProces.SVMXC__Submodule__c);
                if(responseExpLinePick.expressions.size() > 0)
                {
                    ExpLinePick = responseExpLinePick.expressions[0];
                    selectedCriteriaLinePick = ExpLinePick.namedExpression.Id;
                    Map_SequenceNumRecLinePick.clear();
                    for(SVMXC__ServiceMax_Config_Data__c confData : ExpLinePick.expressionDetails)
                        Map_SequenceNumRecLinePick.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                    DisableEditLnkLinePick = false;
                    LinePickExpDetailSize = ExpLinePick.expressionDetails.size();
                }
            }
            if(shpngProces.SVMXC__Module__c != null)
            {
                responseExpParentShip = retrieveExpDetails(shpngProces.SVMXC__Module__c);
                if(responseExpParentShip.expressions.size() > 0)
                {
                    ExpParentShip = responseExpParentShip.expressions[0];
                    selectedCriteriaParentShip = ExpParentShip.namedExpression.Id;
                    Map_SequenceNumRecParentShip.clear();
                    for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentShip.expressionDetails)
                        Map_SequenceNumRecParentShip.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                    DisableEditLnkParentShip = false;
                    ParentShipExpDetailSize = ExpParentShip.expressionDetails.size();
                }
            }
            if(shpngProces.SVMXC__Final_Exception_Process__c != null)
            {
                responseExpLineShip = retrieveExpDetails(shpngProces.SVMXC__Final_Exception_Process__c);
                if(responseExpLineShip.expressions.size() > 0)
                {
                    ExpLineShip = responseExpLineShip.expressions[0];
                    selectedCriteriaLineShip = ExpLineShip.namedExpression.Id;
                    Map_SequenceNumRecLineShip.clear();
                    for(SVMXC__ServiceMax_Config_Data__c confData : ExpLineShip.expressionDetails)
                        Map_SequenceNumRecLineShip.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                    DisableEditLnkLineShip = false;
                    LineShipExpDetailSize = ExpLineShip.expressionDetails.size();
                }
            }
            
            lstSFMEvent.clear();
            lstConfigdataForSrcUpdate.clear();
            if(recordId != null && recordId.length() >0)
            {
                lstSFMEvent = [Select SVMXC__Event_Id__c, SVMXC__Sequence__c, SVMXC__ServiceMax_Custom_Action__c, SVMXC__ServiceMax_Process__c, SVMXC__Event_Type__c, SVMXC__Namespace__c, SVMXC__Class__c, SVMXC__Method__c, SVMXC__Description__c, SVMXC__Event_Call_Type__c, SVMXC__URL_Window_Type__c from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c =: recordId AND (SVMXC__Event_Type__c = 'After Picking' OR SVMXC__Event_Type__c = 'After Shipment' OR SVMXC__Event_Type__c = 'After Closure' OR SVMXC__Event_Type__c = 'SFM Custom Action')];
                
                lstConfigdataForSrcUpdate = [Select SVMXC__Target_Field_Name__c, SVMXC__Operator__c , SVMXC__Operand__c, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Action__c, SVMXC__RecordType_Name__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: recordId and RecordTypeId =: ExpressionsSrcUpdate_Rtype.Id and (SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_PICKING' OR SVMXC__Configuration_Type__c = 'LINE_UPD_ON_PICKING' OR SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_SHIP' OR SVMXC__Configuration_Type__c = 'LINE_UPD_ON_SHIP' OR SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE' OR SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE' OR SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            
            if(lstSFMEvent != null && lstSFMEvent.size() > 0)
            {
                for(SVMXC__SFM_Event__c event : lstSFMEvent)
                {
                    if(event.SVMXC__Event_Type__c == 'After Picking')
                    {
                        nameSpacePick = event.SVMXC__Namespace__c;
                        classNamePick = event.SVMXC__Class__c;
                        methodNamePick = event.SVMXC__Method__c;
                        detailOfWSPick = event.SVMXC__Description__c;
                    }
                    else if(event.SVMXC__Event_Type__c == 'After Shipment')
                    {
                        nameSpaceShip = event.SVMXC__Namespace__c;
                        classNameShip = event.SVMXC__Class__c;
                        methodNameShip = event.SVMXC__Method__c;
                        detailOfWSShip = event.SVMXC__Description__c;
                    }
                    else if(event.SVMXC__Event_Type__c == 'After Closure')
                    {
                        nameSpaceClosure = event.SVMXC__Namespace__c;
                        classNameClosure = event.SVMXC__Class__c;
                        methodNameClosure = event.SVMXC__Method__c;
                        detailOfWSClosure = event.SVMXC__Description__c;
                    }
                    /* else if(event.SVMXC__Event_Type__c == 'SFM Custom Action' && event.SVMXC__Sequence__c == 1)
                        selectedCustmActn1 = event.SVMXC__ServiceMax_Custom_Action__c;
                    else if(event.SVMXC__Event_Type__c == 'SFM Custom Action' && event.SVMXC__Sequence__c == 2)
                        selectedCustmActn2 = event.SVMXC__ServiceMax_Custom_Action__c;
                    else if(event.SVMXC__Event_Type__c == 'SFM Custom Action' && event.SVMXC__Sequence__c == 3)
                        selectedCustmActn3 = event.SVMXC__ServiceMax_Custom_Action__c; */
                }
            }
            
            if(lstConfigdataForSrcUpdate != null && lstConfigdataForSrcUpdate.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configData : lstConfigdataForSrcUpdate)
                {
                    if(configData.SVMXC__Configuration_Type__c == 'HEADER_UPD_ON_PICKING')
                        srcUpdatePickHdr.add(configData);
                    else if(configData.SVMXC__Configuration_Type__c == 'LINE_UPD_ON_PICKING')
                        srcUpdatePickLine.add(configData);
                    else if(configData.SVMXC__Configuration_Type__c == 'HEADER_UPD_ON_SHIP')
                        srcUpdateShipHdr.add(configData);
                    else if(configData.SVMXC__Configuration_Type__c == 'LINE_UPD_ON_SHIP')
                        srcUpdateShipLine.add(configData);
                    
                    /* else if(configData.SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE' && configData.SVMXC__Sequence__c == 1)
                        selectedProductAttribute1 = configData.SVMXC__Field_Name__c;
                    else if(configData.SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE' && configData.SVMXC__Sequence__c == 2)
                        selectedProductAttribute2 = configData.SVMXC__Field_Name__c; */
                    
                    else if(configData.SVMXC__Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && configData.SVMXC__Sequence__c == 1)
                        selectedFldShpmntDoc1 = configData.SVMXC__Field_Name__c;
                    else if(configData.SVMXC__Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && configData.SVMXC__Sequence__c == 2)
                        selectedFldShpmntDoc2 = configData.SVMXC__Field_Name__c;
                    else if(configData.SVMXC__Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && configData.SVMXC__Sequence__c == 3)
                        selectedFldShpmntDoc3 = configData.SVMXC__Field_Name__c;
                    
                    else if(configData.SVMXC__Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && configData.SVMXC__Sequence__c == 1)
                        selectedFldShpmntDocLine1 = configData.SVMXC__Field_Name__c;
                    else if(configData.SVMXC__Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && configData.SVMXC__Sequence__c == 2)
                        selectedFldShpmntDocLine2 = configData.SVMXC__Field_Name__c;
                }
            }
        }
        SrcUpdateParentPickExpSize = srcUpdatePickHdr.size();
        SrcUpdateLinePickExpSize = srcUpdatePickLine.size();
        SrcUpdateParentShipExpSize = srcUpdateShipHdr.size();
        SrcUpdateLineShipExpSize = srcUpdateShipLine.size();
        
        Map_SequenceNumSrcUpdateParentPick.clear();
        for(SVMXC__ServiceMax_Config_Data__c configData : srcUpdatePickHdr)
            Map_SequenceNumSrcUpdateParentPick.put(integer.valueOf(configData.SVMXC__Sequence__c), configData);
        Map_SequenceNumSrcUpdateLinePick.clear();
        for(SVMXC__ServiceMax_Config_Data__c configData : srcUpdatePickLine)
            Map_SequenceNumSrcUpdateLinePick.put(integer.valueOf(configData.SVMXC__Sequence__c), configData);
        Map_SequenceNumSrcUpdateParentShip.clear();
        for(SVMXC__ServiceMax_Config_Data__c configData : srcUpdateShipHdr)
            Map_SequenceNumSrcUpdateParentShip.put(integer.valueOf(configData.SVMXC__Sequence__c), configData);
        Map_SequenceNumSrcUpdateLineShip.clear();
        for(SVMXC__ServiceMax_Config_Data__c configData : srcUpdateShipLine)
            Map_SequenceNumSrcUpdateLineShip.put(integer.valueOf(configData.SVMXC__Sequence__c), configData);
            
        if(SrcUpdateParentPickExpSize == 0 || SrcUpdateParentPickExpSize == null)
            srcUpdateADDRowParentPick();
        if(SrcUpdateLinePickExpSize == 0 || SrcUpdateLinePickExpSize == null)
            srcUpdateADDRowLinePick();
        if(SrcUpdateParentShipExpSize == 0 || SrcUpdateParentShipExpSize == null)
            srcUpdateADDRowParentShip();
        if(SrcUpdateLineShipExpSize == 0 || SrcUpdateLineShipExpSize == null)
            srcUpdateADDRowLineShip();
        
        if(mode == 'Clone')
        {
            List<SVMXC__ServiceMax_Config_Data__c> tempConfData = new List<SVMXC__ServiceMax_Config_Data__c>();
            tempConfData.addAll(srcUpdatePickHdr);
            srcUpdatePickHdr = new List<SVMXC__ServiceMax_Config_Data__c>();
            srcUpdatePickHdr.addAll(tempConfData);
            tempConfData.clear();
            tempConfData.addAll(srcUpdateShipHdr);
            srcUpdateShipHdr = new List<SVMXC__ServiceMax_Config_Data__c>();
            srcUpdateShipHdr.addAll(tempConfData);
            tempConfData.clear();
            tempConfData.addAll(srcUpdatePickLine);
            srcUpdatePickLine = new List<SVMXC__ServiceMax_Config_Data__c>();
            srcUpdatePickLine.addAll(tempConfData);
            tempConfData.clear();
            tempConfData.addAll(srcUpdateShipLine);
            srcUpdateShipLine = new List<SVMXC__ServiceMax_Config_Data__c>();
            srcUpdateShipLine.addAll(tempConfData);
        }
    }
    
    //---------------------------------------- Method to prepare all the PickList -----------------------------------------
    public void preparingPicklists()
    {
        
        LinefldList.clear();
        LinefldList.add(new SelectOption('None',getTAG026()));
        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Line__c', LinefldList, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        
        
        //Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.SVMXC__Product_Stock__c.fields.getMap();
        ProdStockFldList.add(new SelectOption(getTAG026(),getTAG026()));
        DispMethods.RetriveField('SVMXC__Product_Stock__c', ProdStockFldList, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        
        /*for(String s : fieldsMap.keyset())
        {
            Schema.DescribeFieldResult F = fieldsMap.get(s).getDescribe();
            if(F != null && F.isAccessible() && F.isCreateable() && F.isUpdateable())
                ProdStockFldList.add(new SelectOption(F.getName(),F.getLabel()));
        }
        ProdStockFldList = sortingSelectOption(ProdStockFldList); 
        */
        
        /* lstProdSrl.add(new SelectOption(getTAG058(),getTAG058()));
        lstProdSrl.add(new SelectOption(getTAG059(),getTAG059())); */
        
        
        
        Hdrfldlist.add(new SelectOption('None',getTAG026()));
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Order__c', Hdrfldlist, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        
        /*fieldsMap.clear();
        fieldsMap = Schema.SObjectType.SVMXC__RMA_Shipment_Order__c.fields.getMap();
        for(String s : fieldsMap.keyset())
        {
            Schema.DescribeFieldResult F = fieldsMap.get(s).getDescribe();
            if(F != null && F.isAccessible() && F.isCreateable() && F.isUpdateable())
            {
                lstFldShpmntDoc.add(new SelectOption(F.getName(),F.getLabel()));
            }
        }
        lstFldShpmntDoc = sortingSelectOption(lstFldShpmntDoc);
        */
        lstFldShpmntDoc.add(new SelectOption(getTAG026(),getTAG026()));
        lstFldShpmntDoc = sortingSelectOption(Hdrfldlist);
        
        lstFldShpmntDocLine.add(new SelectOption(getTAG026(),getTAG026()));
        //lstFldShpmntDocLine = sortingSelectOption(LinefldList);
        map<String, Schema.SObjectField> fieldsMap = new map<String, Schema.SObjectField>();
        fieldsMap = Schema.SObjectType.SVMXC__RMA_Shipment_Line__c.fields.getMap();
        for(String str : fieldsMap.keyset())
        {
            Schema.DescribeFieldResult f = fieldsMap.get(str).getDescribe();
            if(f.getType() == schema.Displaytype.REFERENCE)
            {
                if(f.getReferenceTo()[0].getDescribe().getName() != 'Product2')
                    lstFldShpmntDocLine.add(new SelectOption(f.getName(),f.getlabel()));
            }
            else
            {
                lstFldShpmntDocLine.add(new SelectOption(f.getName(),f.getlabel()));
            }
        }
        lstFldShpmntDocLine = sortingSelectOption(lstFldShpmntDocLine);
        
        
        
        /* Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_CustomActions_Others = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        ServiceFlowWizard_Utils SFWUtils = new ServiceFlowWizard_Utils();
        Map_CustomActions_Others = SFWUtils.SVMX_GetOtherActions('SVMXC__RMA_Shipment_Order__c');
        
        actionsLst = Map_CustomActions_Others.get('SVMXC__RMA_Shipment_Order__c');
        lstCustmActn.add(new SelectOption(getTAG026(),getTAG026()));
        if(actionsLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : actionsLst)
                lstCustmActn.add(new SelectOption(pro.Id, pro.SVMXC__Name__C));
        }
            
        lstCustmActn = sortingSelectOption(lstCustmActn); */
        
        string ObjMapRtypeId = ObjMap_Rtype.Id;
        
        ObjMapRMALst = [Select  id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c,   SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Active__c, SVMXC__APL_Create_Internal_RMA__c, SVMXC__APL_Create_Supplier_RMA__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where RecordTypeId =: ObjMapRtypeId AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c' AND SVMXC__Target_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstObjMapRMA.clear();
        lstObjMapRMA.add(new SelectOption(getTAG026(),getTAG026()));
        if(ObjMapRMALst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : ObjMapRMALst)
                lstObjMapRMA.add(new SelectOption(pro.Id, pro.SVMXC__Name__C));
        }
        ObjMapRMALineLst = [Select  id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c,   SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Active__c, SVMXC__APL_Create_Internal_RMA__c, SVMXC__APL_Create_Supplier_RMA__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where RecordTypeId =: ObjMapRtypeId AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c' AND SVMXC__Target_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstObjMapRMALine.clear();
        lstObjMapRMALine.add(new SelectOption(getTAG026(),getTAG026()));
        if(ObjMapRMALineLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : ObjMapRMALineLst)
                lstObjMapRMALine.add(new SelectOption(pro.Id, pro.SVMXC__Name__C));
        }
        
        buildingExpLists();
        
        OperatorSelectLst.clear();
        OperatorSelectLst.add(new SelectOption('SVMX.NONE', getTAG026()));
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
        lstUpdateOperator.add(new SelectOption('Increase', getTAG075()));
        lstUpdateOperator.add(new SelectOption('Decrease', getTAG076()));
    }
    
    //------------------------------------------ Building Expressions List -----------------------------------------------------
    public void buildingExpLists()
    {
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Order__c');
        lstStringMap.add(stringMap1);
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        response = namedExpLst.SFM_getAllObjectNamedExpressionList(request);
        
        lstCriteriaParentPick.clear();
        lstCriteriaParentPick.add(new SelectOption(getTAG026(), getTAG026()));
        for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
            lstCriteriaParentPick.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
        lstCriteriaParentPick = sortingSelectOption(lstCriteriaParentPick);
        
        SFM_WrapperDef.SFM_StringMap stringMap2 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Line__c');
        lstStringMap.clear();
        lstStringMap.add(stringMap2);
        SFM_WrapperDef.SFM_Request request1 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        response = namedExpLst.SFM_getAllObjectNamedExpressionList(request1);
        
        lstCriterialinePick.clear();
        lstCriterialinePick.add(new SelectOption(getTAG026(), getTAG026()));
        for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
            lstCriterialinePick.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
        lstCriterialinePick = sortingSelectOption(lstCriterialinePick);
        
        //Neeraj: Added to support expression for product stock...
        SFM_WrapperDef.SFM_StringMap stringMap3 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__Product_Stock__c');
        lstStringMap.clear();
        lstStringMap.add(stringMap3);
        SFM_WrapperDef.SFM_Request request2 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        response = namedExpLst.SFM_getAllObjectNamedExpressionList(request2);
        system.debug('Resp for Product Stock:'+response);
        lstCriteriaProdStock.clear();
        lstCriteriaProdStock.add(new SelectOption(getTAG026(), getTAG026()));
        for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
            lstCriteriaProdStock.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
        lstCriteriaProdStock = sortingSelectOption(lstCriteriaProdStock);
        
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Parent Pick --------------------------------
    public void onChngParentPickExp()
    {
        isCreateNewParentPick = false;
        renderParentPickExprBlock = false;
        if(selectedCriteriaParentPick != getTAG026())
        {
            DisableEditLnkParentPick = false;
            responseExpParentPick = retrieveExpDetails(selectedCriteriaParentPick);
            if(responseExpParentPick.expressions.size() > 0)
            {
                ExpParentPick = responseExpParentPick.expressions[0];
                ParentPickExpDetailSize = ExpParentPick.expressionDetails.size();
                Map_SequenceNumRecParentPick.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentPick.expressionDetails)
                {
                    Map_SequenceNumRecParentPick.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkParentPick = true;
    }
    
    //----------------------------------------- View/Edit of Parent Pick ---------------------------------------------
    public void EditCriteriaParentPick()
    {
        renderParentPickExprBlock = true;
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Line Pick -----------------------------------
    public void onChngLinePickExp()
    {
        isCreateNewLinePick = false;
        renderLinePickExprBlock = false;
        if(selectedCriteriaLinePick != getTAG026())
        {
            DisableEditLnkLinePick = false;
            responseExpLinePick = retrieveExpDetails(selectedCriteriaLinePick);
            if(responseExpLinePick.expressions.size() > 0)
            {
                ExpLinePick = responseExpLinePick.expressions[0];
                LinePickExpDetailSize = ExpLinePick.expressionDetails.size();
                Map_SequenceNumRecLinePick.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpLinePick.expressionDetails)
                {
                    Map_SequenceNumRecLinePick.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkLinePick = true;
    }
    
    //----------------------------------------- View/Edit of Line Pick ---------------------------------------------
    public void EditCriteriaLinePick()
    {
        renderLinePickExprBlock = true;
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Parent Ship --------------------------------
    public void onChngParentShipExp()
    {
        isCreateNewParentShip = false;
        renderParentShipExprBlock = false;
        if(selectedCriteriaParentShip != getTAG026())
        {
            DisableEditLnkParentShip = false;
            responseExpParentShip = retrieveExpDetails(selectedCriteriaParentShip);
            if(responseExpParentShip.expressions.size() > 0)
            {
                ExpParentShip = responseExpParentShip.expressions[0];
                ParentShipExpDetailSize = ExpParentShip.expressionDetails.size();
                Map_SequenceNumRecParentShip.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpParentShip.expressionDetails)
                {
                    Map_SequenceNumRecParentShip.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkParentShip = true;
    }
    
    //----------------------------------------- View/Edit of Parent Ship ---------------------------------------------
    public void EditCriteriaParentShip()
    {
        renderParentShipExprBlock = true;
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Line Ship -----------------------------------
    public void onChngLineShipExp()
    {
        isCreateNewLineShip = false;
        renderLineShipExprBlock = false;
        if(selectedCriteriaLineShip != getTAG026())
        {
            DisableEditLnkLineShip = false;
            responseExpLineShip = retrieveExpDetails(selectedCriteriaLineShip);
            if(responseExpLineShip.expressions.size() > 0)
            {
                ExpLineShip = responseExpLineShip.expressions[0];
                LineShipExpDetailSize = ExpLineShip.expressionDetails.size();
                Map_SequenceNumRecLineShip.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpLineShip.expressionDetails)
                {
                    Map_SequenceNumRecLineShip.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkLineShip = true;
    }
    
    //----------------------------------------- View/Edit of Line Ship ---------------------------------------------
    public void EditCriteriaLineShip()
    {
        renderLineShipExprBlock = true;
    }
    
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRecParentPick = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRecLinePick = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRecParentShip = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRecLineShip = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    
    //----------------------------------------- New of Parent Pick ---------------------------------------------
    public void NewCriteriaParentPick()
    {
        isCreateNewParentPick = true;
        selectedCriteriaParentPick = getTAG026();
        DisableEditLnkParentPick = true;
        renderParentPickExprBlock = true;
        ExpParentPick = new SFM_WrapperDef.SFM_Expression();
        ExpParentPick.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c');
        ExpParentPick.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpParentPick.expressionDetails != null)
            ParentPickExpDetailSize = ExpParentPick.expressionDetails.size();
        else
            ParentPickExpDetailSize = 0;
        Exp = ExpParentPick;
        DetailSize = ParentPickExpDetailSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecParentPick.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecParentPick);
        HdrADDRow();
        ParentPickExpDetailSize = DetailSize;
        Map_SequenceNumRecParentPick.clear();
        Map_SequenceNumRecParentPick.putAll(Map_SequenceNumRec);
    }
    
    //----------------------------------------- New of Line Pick ---------------------------------------------
    public void NewCriteriaLinePick()
    {
        isCreateNewLinePick = true;
        selectedCriteriaLinePick = getTAG026();
        DisableEditLnkLinePick = true;
        renderLinePickExprBlock = true;
        ExpLinePick = new SFM_WrapperDef.SFM_Expression();
        ExpLinePick.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c');
        ExpLinePick.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpLinePick.expressionDetails != null)
            LinePickExpDetailSize = ExpLinePick.expressionDetails.size();
        else
            LinePickExpDetailSize = 0;
        Exp = ExpLinePick;
        DetailSize = LinePickExpDetailSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecLinePick.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecLinePick);
        HdrADDRow();
        LinePickExpDetailSize = DetailSize;
        Map_SequenceNumRecLinePick.clear();
        Map_SequenceNumRecLinePick.putAll(Map_SequenceNumRec);
    }
    
    //----------------------------------------- New of Parent Ship ---------------------------------------------
    public void NewCriteriaParentShip()
    {
        isCreateNewParentShip = true;
        selectedCriteriaParentShip = getTAG026();
        DisableEditLnkParentShip = true;
        renderParentShipExprBlock = true;
        ExpParentShip = new SFM_WrapperDef.SFM_Expression();
        ExpParentShip.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c');
        ExpParentShip.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpParentShip.expressionDetails != null)
            ParentShipExpDetailSize = ExpParentShip.expressionDetails.size();
        else
            ParentShipExpDetailSize = 0;
        Exp = ExpParentShip;
        DetailSize = ParentShipExpDetailSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecParentShip.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecParentShip);
        HdrADDRow();
        ParentShipExpDetailSize = DetailSize;
        Map_SequenceNumRecParentShip.clear();
        Map_SequenceNumRecParentShip.putAll(Map_SequenceNumRec);
    }
    
    //----------------------------------------- Add New Criteria of Line Ship ---------------------------------------------
    public void NewCriteriaLineShip()
    {
        isCreateNewLineShip = true;
        selectedCriteriaLineShip = getTAG026();
        DisableEditLnkLineShip = true;
        renderLineShipExprBlock = true;
        ExpLineShip = new SFM_WrapperDef.SFM_Expression();
        ExpLineShip.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c');
        ExpLineShip.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpLineShip.expressionDetails != null)
            LineShipExpDetailSize = ExpLineShip.expressionDetails.size();
        else
            LineShipExpDetailSize = 0;
        Exp = ExpLineShip;
        DetailSize = LineShipExpDetailSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecLineShip.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecLineShip);
        HdrADDRow();
        LineShipExpDetailSize = DetailSize;
        Map_SequenceNumRecLineShip.clear();
        Map_SequenceNumRecLineShip.putAll(Map_SequenceNumRec);
    }
    
    public void EditCriteriaProdStock()
    {
        renderProdStkExprBlock = true;
    }
    
    public void onChngProdStockExp()
    {
        
        DisableEditLnkProdStock = false;
        renderProdStkExprBlock = false;
        if(selectedCriteriaProdStock != getTAG026())
        {
            DisableEditLnkProdStock = false;
            responseExpProdStock = retrieveExpDetails(selectedCriteriaProdStock);
            if(responseExpProdStock.expressions.size() > 0)
            {
                ExpProdStock = responseExpProdStock.expressions[0];
                ProdStockExpSize = ExpProdStock.expressionDetails.size();
                Map_SequenceNumRecLineShip.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpProdStock.expressionDetails)
                {
                    Map_SequenceNumRecLineShip.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkProdStock = true;
    }
    
    public void NewCriteriaProdStock()
    {
        selectedCriteriaProdStock = getTAG026();
        DisableEditLnkProdStock = true;
        isCreateNewProdStock = true;
        renderProdStkExprBlock = true;
        ExpProdStock = new SFM_WrapperDef.SFM_Expression();
        ExpProdStock.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'SVMXC__Product_Stock__c');
        ExpProdStock.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpProdStock.expressionDetails != null)
            ProdStockExpSize = ExpProdStock.expressionDetails.size();
        else
            ProdStockExpSize = 0;
        Exp = ExpProdStock;
        DetailSize = ProdStockExpSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecParentPick.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecParentPick);
        HdrADDRow();
        ProdStockExpSize = DetailSize;
        Map_SequenceNumRecParentPick.clear();
        Map_SequenceNumRecParentPick.putAll(Map_SequenceNumRec);
    }
    
    //----------------------------------------- Delete Row in the Product Stock Exp ---------------------------------------------
    public PageReference HdrDeleteRowProdStock()
    {
        Exp = ExpProdStock;
        DetailSize = ProdStockExpSize;
        Map_SequenceNumRec.clear();
        Map_SequenceNumRec.putAll(Map_SequenceNumRecLinePick);
        HdrDeleteRow();
        Map_SequenceNumRecLinePick.clear();
        Map_SequenceNumRecLinePick.putAll(Map_SequenceNumRec);
        ProdStockExpSize = DetailSize;
        ExpProdStock = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Product Stock Exp ---------------------------------------------
    public PageReference HdrADDRowProdStock()
    {
        Exp = ExpProdStock;
        DetailSize = ProdStockExpSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecLinePick.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecLinePick);
        HdrADDRow();
        ProdStockExpSize = DetailSize;
        Map_SequenceNumRecLinePick.clear();
        Map_SequenceNumRecLinePick.putAll(Map_SequenceNumRec);
        ExpProdStock = Exp;
        return null;
    }
    
    //----------------------------------------- Delete Row in the Parent Pick ---------------------------------------------
    public PageReference HdrDeleteRowParentPick()
    {
        system.debug('HdrDeleteRowParentPick method');
        Exp = ExpParentPick;
        DetailSize = ParentPickExpDetailSize;
        Map_SequenceNumRec.clear();
        Map_SequenceNumRec.putAll(Map_SequenceNumRecParentPick);
        HdrDeleteRow();
        Map_SequenceNumRecParentPick.clear();
        Map_SequenceNumRecParentPick.putAll(Map_SequenceNumRec);
        ParentPickExpDetailSize = DetailSize;
        ExpParentPick = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Parent Pick ---------------------------------------------
    public PageReference HdrADDRowParentPick()
    {
        Exp = ExpParentPick;
        DetailSize = ParentPickExpDetailSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecParentPick.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecParentPick);
        HdrADDRow();
        ParentPickExpDetailSize = DetailSize;
        Map_SequenceNumRecParentPick.clear();
        Map_SequenceNumRecParentPick.putAll(Map_SequenceNumRec);
        ExpParentPick = Exp;
        return null;
    }
    
    //----------------------------------------- Delete Row in the Line Pick ---------------------------------------------
    public PageReference HdrDeleteRowLinePick()
    {
        Exp = ExpLinePick;
        DetailSize = LinePickExpDetailSize;
        Map_SequenceNumRec.clear();
        Map_SequenceNumRec.putAll(Map_SequenceNumRecLinePick);
        HdrDeleteRow();
        Map_SequenceNumRecLinePick.clear();
        Map_SequenceNumRecLinePick.putAll(Map_SequenceNumRec);
        LinePickExpDetailSize = DetailSize;
        ExpLinePick = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Line Pick ---------------------------------------------
    public PageReference HdrADDRowLinePick()
    {
        Exp = ExpLinePick;
        DetailSize = LinePickExpDetailSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecLinePick.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecLinePick);
        HdrADDRow();
        LinePickExpDetailSize = DetailSize;
        Map_SequenceNumRecLinePick.clear();
        Map_SequenceNumRecLinePick.putAll(Map_SequenceNumRec);
        ExpLinePick = Exp;
        return null;
    }
    
    //----------------------------------------- Delete Row in the Parent Ship ---------------------------------------------
    public PageReference HdrDeleteRowParentShip()
    {
        Exp = ExpParentShip;
        DetailSize = ParentShipExpDetailSize;
        Map_SequenceNumRec.clear();
        Map_SequenceNumRec.putAll(Map_SequenceNumRecParentShip);
        HdrDeleteRow();
        Map_SequenceNumRecParentShip.clear();
        Map_SequenceNumRecParentShip.putAll(Map_SequenceNumRec);
        ParentShipExpDetailSize = DetailSize;
        ExpParentShip = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Parent Ship ---------------------------------------------
    public PageReference HdrADDRowParentShip()
    {
        Exp = ExpParentShip;
        DetailSize = ParentShipExpDetailSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecParentShip.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecParentShip);
        HdrADDRow();
        Map_SequenceNumRecParentShip.clear();
        Map_SequenceNumRecParentShip.putAll(Map_SequenceNumRec);
        ParentShipExpDetailSize = DetailSize;
        ExpParentShip = Exp;
        return null;
    }
    
    //----------------------------------------- Delete Row in the Line Ship ---------------------------------------------
    public PageReference HdrDeleteRowLineShip()
    {
        Exp = ExpLineShip;
        DetailSize = LineShipExpDetailSize;
        Map_SequenceNumRec.clear();
        Map_SequenceNumRec.putAll(Map_SequenceNumRecLineShip);
        HdrDeleteRow();
        Map_SequenceNumRecLineShip.clear();
        Map_SequenceNumRecLineShip.putAll(Map_SequenceNumRec);
        LineShipExpDetailSize = DetailSize;
        ExpLineShip = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Line Ship ---------------------------------------------
    public PageReference HdrADDRowLineShip()
    {
        Exp = ExpLineShip;
        DetailSize = LineShipExpDetailSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecLineShip.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecLineShip);
        HdrADDRow();
        Map_SequenceNumRecLineShip.clear();
        Map_SequenceNumRecLineShip.putAll(Map_SequenceNumRec);
        LineShipExpDetailSize = DetailSize;
        ExpLineShip = Exp;
        return null;
    }
    
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumSrcUpdateParentPick = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumSrcUpdateLinePick = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumSrcUpdateParentShip = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumSrcUpdateLineShip = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();

    //----------------------------------------- Methods to Add and Delete Row in Source Updates Lists ---------------------------------------------
    public PageReference srcUpdateDeleteRowParentPick()
    {
        system.debug('Entered: ' + DelIndex);
        LstExp = srcUpdatePickHdr;
        DetailSize = SrcUpdateParentPickExpSize;
        Map_SequenceNumRec.clear();
        Map_SequenceNumRec.putAll(Map_SequenceNumSrcUpdateParentPick);
        SrcUpdateDeleteRow();
        Map_SequenceNumSrcUpdateParentPick.clear();
        Map_SequenceNumSrcUpdateParentPick.putAll(Map_SequenceNumRec);
        SrcUpdateParentPickExpSize = DetailSize;
        srcUpdatePickHdr = LstExp;
        return null;
    }
    
    public PageReference srcUpdateADDRowParentPick()
    {
        LstExp = srcUpdatePickHdr;
        DetailSize = SrcUpdateParentPickExpSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumSrcUpdateParentPick.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumSrcUpdateParentPick);
        SrcUpdateADDRow();
        SrcUpdateParentPickExpSize = DetailSize;
        Map_SequenceNumSrcUpdateParentPick.clear();
        Map_SequenceNumSrcUpdateParentPick.putAll(Map_SequenceNumRec);
        srcUpdatePickHdr = LstExp;
        return null;
    }
    public PageReference srcUpdateDeleteRowLinePick()
    {
        LstExp = srcUpdatePickLine;
        DetailSize = SrcUpdateLinePickExpSize;
        Map_SequenceNumRec.clear();
        Map_SequenceNumRec.putAll(Map_SequenceNumSrcUpdateLinePick);
        SrcUpdateDeleteRow();
        Map_SequenceNumSrcUpdateLinePick.clear();
        Map_SequenceNumSrcUpdateLinePick.putAll(Map_SequenceNumRec);
        SrcUpdateLinePickExpSize = DetailSize;
        srcUpdatePickLine = LstExp;
        return null;
    }
    
    public PageReference srcUpdateADDRowLinePick()
    {
        LstExp = srcUpdatePickLine;
        DetailSize = SrcUpdateLinePickExpSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumSrcUpdateLinePick.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumSrcUpdateLinePick);
        SrcUpdateADDRow();
        SrcUpdateLinePickExpSize = DetailSize;
        Map_SequenceNumSrcUpdateLinePick.clear();
        Map_SequenceNumSrcUpdateLinePick.putAll(Map_SequenceNumRec);
        srcUpdatePickLine = LstExp;
        return null;
    }
    
    public PageReference srcUpdateDeleteRowParentShip()
    {
        LstExp = srcUpdateShipHdr;
        DetailSize = SrcUpdateParentShipExpSize;
        Map_SequenceNumRec.clear();
        Map_SequenceNumRec.putAll(Map_SequenceNumSrcUpdateParentShip);
        SrcUpdateDeleteRow();
        Map_SequenceNumSrcUpdateParentShip.clear();
        Map_SequenceNumSrcUpdateParentShip.putAll(Map_SequenceNumRec);
        SrcUpdateParentShipExpSize = DetailSize;
        srcUpdateShipHdr = LstExp;
        return null;
    }
    
    public PageReference srcUpdateADDRowParentShip()
    {
        LstExp = srcUpdateShipHdr;
        DetailSize = SrcUpdateParentShipExpSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumSrcUpdateParentShip.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumSrcUpdateParentShip);
        SrcUpdateADDRow();
        SrcUpdateParentShipExpSize = DetailSize;
        Map_SequenceNumSrcUpdateParentShip.clear();
        Map_SequenceNumSrcUpdateParentShip.putAll(Map_SequenceNumRec);
        srcUpdateShipHdr = LstExp;
        return null;
    }
    public PageReference srcUpdateDeleteRowLineShip()
    {
        LstExp = srcUpdateShipLine;
        DetailSize = SrcUpdateLineShipExpSize;
        Map_SequenceNumRec.clear();
        Map_SequenceNumRec.putAll(Map_SequenceNumSrcUpdateLineShip);
        SrcUpdateDeleteRow();
        Map_SequenceNumSrcUpdateLineShip.clear();
        Map_SequenceNumSrcUpdateLineShip.putAll(Map_SequenceNumRec);
        SrcUpdateLineShipExpSize = DetailSize;
        srcUpdateShipLine = LstExp;
        return null;
    }
    
    public PageReference srcUpdateADDRowLineShip()
    {
        LstExp = srcUpdateShipLine;
        DetailSize = SrcUpdateLineShipExpSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumSrcUpdateLineShip.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumSrcUpdateLineShip);
        SrcUpdateADDRow();
        SrcUpdateLineShipExpSize = DetailSize;
        Map_SequenceNumSrcUpdateLineShip.clear();
        Map_SequenceNumSrcUpdateLineShip.putAll(Map_SequenceNumRec);
        srcUpdateShipLine = LstExp;
        return null;
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
    
    //--------------------------------------Methods to add row of Expression details-------------------------------------------------------
    public void HdrADDRow()
    {
        try
        {
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsDetail_Rtype.Id, SVMXC__Sequence__c = Integer.valueOf( Exp.expressionDetails.size() + 1 ) );
            Map_SequenceNumRec.put( Math.Round(Integer.valueOf( Exp.expressionDetails.size() + 1 )), NewExpDetailRec );
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
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            system.debug('Expression='+Exp+'List of expression:'+Exp.expressionDetails);
            for( integer i=0; i < Exp.expressionDetails.size(); i++ )
            {
                if( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && (i + 1) != integer.valueOf(DelIndex) )
                    TempMap_SequenceNumRec.put( i + 1 - SeqNumToSubtract, Exp.expressionDetails[i] );
                else if ( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && ( (i + 1) == integer.valueOf(DelIndex)) )  
                    SeqNumToSubtract = 1;
            }
            Map_SequenceNumRec.clear();
            if( TempMap_SequenceNumRec != null )
                Map_SequenceNumRec.putAll(TempMap_SequenceNumRec);
            
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :Map_SequenceNumRec.keyset())
            {
                SequenceCounter++;
                if( Map_SequenceNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = Map_SequenceNumRec.get(SequenceNumber);
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
            system.debug('Adding A Row and size before addition is: ' + DetailSize);
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsSrcUpdate_Rtype.Id, SVMXC__Sequence__c = Integer.valueOf( LstExp.size() + 1 ) );
            Map_SequenceNumRec.put( Math.Round(Integer.valueOf( LstExp.size() + 1 )), NewExpDetailRec );
            LstExp.add( NewExpDetailRec );
            if(LstExp != null)
                DetailSize = LstExp.size();
            else
                DetailSize = 0;
                
            system.debug('Adding A Row and size after addition is: ' + DetailSize);
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
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            
            for( integer i=0; i < LstExp.size(); i++ )
            {
                if( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && (i + 1) != integer.valueOf(DelIndex) )
                    TempMap_SequenceNumRec.put( i + 1 - SeqNumToSubtract, LstExp[i] );
                else if ( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && ( (i + 1) == integer.valueOf(DelIndex)) )  
                    SeqNumToSubtract = 1;
            }
            Map_SequenceNumRec.clear();
            if( TempMap_SequenceNumRec != null )
                Map_SequenceNumRec.putAll(TempMap_SequenceNumRec);
            
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :Map_SequenceNumRec.keyset())
            {
                SequenceCounter++;
                if( Map_SequenceNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = Map_SequenceNumRec.get(SequenceNumber);
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
    public void QualPick()
    {
        selectedTab = 'TAB2';
    }
    public void SrcUpdtPick()
    {
        selectedTab = 'TAB3';
    }
    public void QualPack()
    {
        selectedTab = 'TAB4';
    }
    public void SrcUpdtPack()
    {
        selectedTab = 'TAB5';
    }
    public void CustmEventLink()
    {
        selectedTab = 'TAB6';
    }
    public void RMALines()
    {
        selectedTab = 'TAB7';
    }
    
    //------------------------------------------- Method To Cancel --------------------------------------------------------------   
    public pageReference cancel()
    {
         pageReference pageref1 = Page.CONF_ManageShippingProcesses;
         return pageref1;
    }
    
     //----------------------------------- Method To Save and Close ---------------------------------------------------
    public pageReference saveClose()
    {
        save();
        if(Validate != false)
        {
            isSavedOnce = true;
            pageReference pageref1 = Page.CONF_ManageShippingProcesses ;
            return pageref1;
        }
        return null;
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
            if(isCreateNewParentPick == true)
                selectedCriteriaParentPick = ExpParentPick.namedExpression.Id;
            if(isCreateNewLinePick == true)
                selectedCriterialinePick = ExpLinePick.namedExpression.Id;
            if(isCreateNewParentShip == true)
                selectedCriteriaParentShip = ExpParentShip.namedExpression.Id;
            if(isCreateNewLineShip == true)
                selectedCriterialineShip = ExpLineShip.namedExpression.Id;
             if(isCreateNewProdStock == true)
                selectedCriteriaProdStock = ExpProdStock.namedExpression.Id;
            
            shpngProces.SVMXC__Name__c = processName;
            shpngProces.RecordTypeId = ShippingProcess_Rtype.Id;
            shpngProces.SVMXC__ProcessID__c = processID;
            shpngProces.SVMXC__Description__c = processDesc;
            shpngProces.SVMXC__APL_Serial_Number_Source__c = 'LINE_TXT_SN';
            //shpngProces.SVMXC__APL_Scan_First__c = selectedProdSrl;
            shpngProces.SVMXC__Parent_Error_Msg__c = parentCriteriaErrorPick;
            shpngProces.SVMXC__Child_Error_Msg__c = lineCriteriaErrorPick;
            shpngProces.SVMXC__Parent_Error_Msg2__c = parentCriteriaErrorShip;
            shpngProces.SVMXC__Child_Error_Msg2__c = lineCriteriaErrorShip;
            //shpngProces.SVMXC__APL_Allow_Partial_Shipment__c = allowPartialShipment;
            shpngProces.SVMXC__APL_Create_Internal_RMA__c = createInternalRMA;
            shpngProces.SVMXC__APL_Create_Supplier_RMA__c = createSupplierRMA;
            //shpngProces.SVMXC__APL_Print_Label_Template__c = VFTempltPrintLabel;
            //shpngProces.SVMXC__APL_Shipment_Note_Template__c = VFTempltShipmentNote;
            
            if(selectedInternalRMAMap != getTAG026())
                shpngProces.SVMXC__Parent_Object__c = selectedInternalRMAMap;
            else
                shpngProces.SVMXC__Parent_Object__c = null;
            if(selectedInternalRMALineMap != getTAG026())
                shpngProces.SVMXC__Process__c = selectedInternalRMALineMap;
            else
                shpngProces.SVMXC__Process__c = null;
            if(selectedSupplierRMAMap != getTAG026())
                shpngProces.SVMXC__Process1__c = selectedSupplierRMAMap;
            else
                shpngProces.SVMXC__Process1__c = null;
            if(selectedSupplierRMALineMap != getTAG026())
                shpngProces.SVMXC__Process2__c = selectedSupplierRMALineMap;
            else
                shpngProces.SVMXC__Process2__c = null;
            if(selectedCriteriaParentPick != getTAG026())
                shpngProces.SVMXC__Node_Parent__c = ExpParentPick.namedExpression.Id;
            else
                shpngProces.SVMXC__Node_Parent__c = null;
            
            if(selectedCriteriaProdStock != getTAG026())
                shpngProces.SVMXC__Process3__c = ExpProdStock.namedExpression.Id;
            else
                shpngProces.SVMXC__Process3__c = null;
                
            if(selectedCriterialinePick != getTAG026())
                shpngProces.SVMXC__Submodule__c = ExpLinePick.namedExpression.Id;
            else
                shpngProces.SVMXC__Submodule__c = null;
            if(selectedCriteriaParentShip != getTAG026())
                shpngProces.SVMXC__Module__c = ExpParentShip.namedExpression.Id;
            else
                shpngProces.SVMXC__Module__c = null;
            if(selectedCriterialineShip != getTAG026())
                shpngProces.SVMXC__Final_Exception_Process__c = ExpLineShip.namedExpression.Id;
            else
                shpngProces.SVMXC__Final_Exception_Process__c = null;
            
            //upsert shpngProces;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(shpngProces, COMM_SecurityUtils.Access.Upsertable)){
                upsert shpngProces; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            if(lstSFMEvent != null || lstSFMEvent.size() > 0){
            	//delete lstSFMEvent;
            	if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SFM_Event__c' ) ) {                        
				    delete lstSFMEvent; //SDL-SVMX-DELETE-FLS-ENFORCED
				} else {
				    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
				}
            }
            
            List<SVMXC__SFM_Event__c> eventToSave = new List<SVMXC__SFM_Event__c>();
            SVMXC__SFM_Event__c event1 = new SVMXC__SFM_Event__c();
            if((nameSpacePick != null || classNamePick != null || methodNamePick != null) && (nameSpacePick != '' || classNamePick != '' || methodNamePick != ''))
            {
                event1 = fillingSFMEvent(nameSpacePick,classNamePick,methodNamePick,detailOfWSPick,'After Picking',null,0);
                eventToSave.add(event1);
            }
            
            SVMXC__SFM_Event__c event2 = new SVMXC__SFM_Event__c();
            if((nameSpaceShip != null || classNameShip != null || methodNameShip != null) && (nameSpaceShip != '' || classNameShip != '' || methodNameShip != ''))
            {
                event2 = fillingSFMEvent(nameSpaceShip,classNameShip,methodNameShip,detailOfWSShip,'After Shipment',null,0);
                eventToSave.add(event2);
            }
            
            SVMXC__SFM_Event__c event3 = new SVMXC__SFM_Event__c();
            if((nameSpaceClosure != null || classNameClosure != null || methodNameClosure != null) && (nameSpaceClosure != '' || classNameClosure != '' || methodNameClosure != ''))
            {
                event3 = fillingSFMEvent(nameSpaceClosure,classNameClosure,methodNameClosure,detailOfWSClosure,'After Closure',null,0);
                eventToSave.add(event3);
            }
            /* if(selectedCustmActn1 != getTAG026())
            {
                SVMXC__SFM_Event__c event4 = new SVMXC__SFM_Event__c();
                event4 = fillingSFMEvent(null,null,null,null,'SFM Custom Action',selectedCustmActn1,1);
                eventToSave.add(event4);
            }
            if(selectedCustmActn2 != getTAG026())
            {
                SVMXC__SFM_Event__c event5 = new SVMXC__SFM_Event__c();
                event5 = fillingSFMEvent(null,null,null,null,'SFM Custom Action',selectedCustmActn2,2);
                eventToSave.add(event5);
            }
            if(selectedCustmActn3 != getTAG026())
            {
                SVMXC__SFM_Event__c event6 = new SVMXC__SFM_Event__c();
                event6 = fillingSFMEvent(null,null,null,null,'SFM Custom Action',selectedCustmActn3,3);
                eventToSave.add(event6);
            } */
            
            if(eventToSave.size() >0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(eventToSave, COMM_SecurityUtils.Access.Createable)){
                    insert eventToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    //ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
                
            
            if(lstConfigdataForSrcUpdate != null)
                delete lstConfigdataForSrcUpdate; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
            /* if(selectedProductAttribute1 != getTAG026())
            {
                SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
                configData1 = fillingConfigData(null,'PRODUCT_ATTRIBUTE',1,selectedProductAttribute1);
                lstConfigdataToSave.add(configData1);
            } */
            /* if(selectedProductAttribute2 != getTAG026())
            {
                SVMXC__ServiceMax_Config_Data__c configData2 = new SVMXC__ServiceMax_Config_Data__c();
                configData2 = fillingConfigData(null,'PRODUCT_ATTRIBUTE',2,selectedProductAttribute2);
                lstConfigdataToSave.add(configData2);
            } */
            if(selectedFldShpmntDoc1 != getTAG026())
            {
                SVMXC__ServiceMax_Config_Data__c configData3 = new SVMXC__ServiceMax_Config_Data__c();
                configData3 = fillingConfigData(null,'DOCUMENT_ATTRIBUTE',1,selectedFldShpmntDoc1);
                lstConfigdataToSave.add(configData3);
            }
            if(selectedFldShpmntDoc2 != getTAG026())
            {
                SVMXC__ServiceMax_Config_Data__c configData4 = new SVMXC__ServiceMax_Config_Data__c();
                configData4 = fillingConfigData(null,'DOCUMENT_ATTRIBUTE',2,selectedFldShpmntDoc2);
                lstConfigdataToSave.add(configData4);
            }
            if(selectedFldShpmntDoc3 != getTAG026())
            {
                SVMXC__ServiceMax_Config_Data__c configData5 = new SVMXC__ServiceMax_Config_Data__c();
                configData5 = fillingConfigData(null,'DOCUMENT_ATTRIBUTE',3,selectedFldShpmntDoc3);
                lstConfigdataToSave.add(configData5);
            }
            if(selectedFldShpmntDocLine1 != getTAG026())
            {
                SVMXC__ServiceMax_Config_Data__c configData6 = new SVMXC__ServiceMax_Config_Data__c();
                configData6 = fillingConfigData(null,'DOCUMENT_LINE_ATTRIBUTE',1,selectedFldShpmntDocLine1);
                lstConfigdataToSave.add(configData6);
            }
            if(selectedFldShpmntDocLine2 != getTAG026())
            {
                SVMXC__ServiceMax_Config_Data__c configData7 = new SVMXC__ServiceMax_Config_Data__c();
                configData7 = fillingConfigData(null,'DOCUMENT_LINE_ATTRIBUTE',2,selectedFldShpmntDocLine2);
                lstConfigdataToSave.add(configData7);
            }
            
            system.debug('srcUpdatePickHdr before message: ' + srcUpdatePickHdr);
            if(srcUpdatePickHdr != null && srcUpdatePickHdr.size()>0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configdata : srcUpdatePickHdr)
                {
                    if(configdata.SVMXC__Target_Field_Name__c != 'None')
                    {
                        SVMXC__ServiceMax_Config_Data__c newConfigdata = new SVMXC__ServiceMax_Config_Data__c();
                        newConfigdata = fillingConfigData(configdata,'HEADER_UPD_ON_PICKING',0,null);
                        lstConfigdataToSave.add(newConfigdata);
                    }
                }
            }
            system.debug('srcUpdatePickLine before message: ' + srcUpdatePickLine);
            if(srcUpdatePickLine != null && srcUpdatePickLine.size()>0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configdata : srcUpdatePickLine)
                {
                    if(configdata.SVMXC__Target_Field_Name__c != 'None')
                    {
                        SVMXC__ServiceMax_Config_Data__c newConfigdata = new SVMXC__ServiceMax_Config_Data__c();
                        newConfigdata = fillingConfigData(configdata,'LINE_UPD_ON_PICKING',0,null);
                        lstConfigdataToSave.add(newConfigdata);
                    }
                }
            }
            if(srcUpdateShipHdr != null && srcUpdateShipHdr.size()>0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configdata : srcUpdateShipHdr)
                {
                    if(configdata.SVMXC__Target_Field_Name__c != 'None')
                    {
                        SVMXC__ServiceMax_Config_Data__c newConfigdata = new SVMXC__ServiceMax_Config_Data__c();
                        newConfigdata = fillingConfigData(configdata,'HEADER_UPD_ON_SHIP',0,null);
                        lstConfigdataToSave.add(newConfigdata);
                    }
                }
            }
            if(srcUpdateShipLine != null && srcUpdateShipLine.size()>0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configdata : srcUpdateShipLine)
                {
                    if(configdata.SVMXC__Target_Field_Name__c != 'None')
                    {
                        SVMXC__ServiceMax_Config_Data__c newConfigdata = new SVMXC__ServiceMax_Config_Data__c();
                        newConfigdata = fillingConfigData(configdata,'LINE_UPD_ON_SHIP',0,null);
                        lstConfigdataToSave.add(newConfigdata);
                    }
                }
            }
            system.debug('Config data before Save: ' + lstConfigdataToSave);
            
            //upsert lstConfigdataToSave;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfigdataToSave, COMM_SecurityUtils.Access.Upsertable)){
                upsert lstConfigdataToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            recordId = shpngProces.Id;
            queryingdata();
            preparingPicklists();
        }
    }
    
    //---------------------------------------------- Validation before Saving -------------------------------------------------------
    public void validation()
    {
        boolean b = fieldValidation(srcUpdatePickHdr);
        boolean b1 = fieldValidation(srcUpdatePickLine);
        boolean b2 = fieldValidation(srcUpdateShipHdr);
        boolean b3 = fieldValidation(srcUpdateShipLine);
        
        if(b == false || b1 == false || b2 == false || b3 == false)
            Validate = false;
        
        if(processName == null || processName == '')
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG085(),''));
        }
        if(processID == null || processID == '')
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG084(),''));
        }
        if(processID.length() < 8)
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG084(),''));
        }
        /*if(selectedSrlNoSrc == null || selectedSrlNoSrc == '')
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG083(),''));
        }*/
        if((selectedCriteriaParentPick != getTAG026() || isCreateNewParentPick == true) && (parentCriteriaErrorPick == '' || parentCriteriaErrorPick == null))
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
        }
        if((selectedCriterialinePick != getTAG026() || isCreateNewLinePick == true) && (lineCriteriaErrorPick == '' || lineCriteriaErrorPick == null))
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
        }
        
        if((selectedCriteriaParentShip != getTAG026() || isCreateNewParentShip == true) && (parentCriteriaErrorShip == null || parentCriteriaErrorShip == ''))
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
        }
        if((selectedCriterialineShip != getTAG026() || isCreateNewLineShip == true) && (lineCriteriaErrorShip == null || lineCriteriaErrorShip == ''))
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
        }
        
        List<SVMXC__ServiceMax_Processes__c> LstToCheckId = new List<SVMXC__ServiceMax_Processes__c>();
        String UniqueProcessId = processID;
        if(( mode == 'Clone' || mode == 'New')  && isSavedOnce == false )
            LstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: UniqueProcessId AND RecordType.Name = \'Shipping Process\'');
        if( ( recordId != null && recordId != '' && mode == 'Edit' )  && isSavedOnce == false)
            LstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: UniqueProcessId AND RecordType.Name = \'Shipping Process\' AND Id !=: recordId');
        if( LstToCheckId != null && LstToCheckId.size() > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG092(), ''));
            Validate = false;
        }
    }
    
    //---------------------------------------------- Method to validate the use of fields only once -------------------------------------------------------
    public boolean fieldValidation(List<SVMXC__ServiceMax_Config_Data__c> lstConfData)
    {
        MAP<string,string> mapToValidateFlds = new MAP<string,string>();
        boolean valid = true;
        for(SVMXC__ServiceMax_Config_Data__c confData : lstConfData)
        {
            string str = mapToValidateFlds.get(confData.SVMXC__Target_Field_Name__c);
            if(str == null)
                mapToValidateFlds.put(confData.SVMXC__Target_Field_Name__c,confData.SVMXC__Target_Field_Name__c);
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG097(), ''));
                valid = false;
            }
        }
        return valid;
    }
    
    //---------------------------------------------- Method to fill the Config data fields before Saving -------------------------------------------------------
    public SVMXC__ServiceMax_Config_Data__c fillingConfigData(SVMXC__ServiceMax_Config_Data__c configdata, string configType, integer sequence, string fieldName)
    {
        SVMXC__ServiceMax_Config_Data__c newConfigData = new SVMXC__ServiceMax_Config_Data__c();
        newConfigData.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        newConfigData.SVMXC__Configuration_Type__c = configType;
        newConfigdata.SVMXC__Dispatch_Process__c = shpngProces.Id;
        if(sequence != 0)
            newConfigData.SVMXC__Sequence__c = sequence;
        else
            newConfigData.SVMXC__Sequence__c = configdata.SVMXC__Sequence__c;
        if(fieldName != null)
            newConfigData.SVMXC__Field_Name__c = fieldName;
        
        if(configdata != null)
        {
            newConfigData.SVMXC__Target_Field_Name__c = configdata.SVMXC__Target_Field_Name__c;
            newConfigData.SVMXC__Action__c = configdata.SVMXC__Action__c;
            newConfigData.SVMXC__Display_Value__c = configdata.SVMXC__Display_Value__c;
        }
        if(configType == 'DOCUMENT_ATTRIBUTE')
        {
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            objfieldMap = SVMXC__RMA_Shipment_Order__c.SObjectType.getDescribe().fields.getMap();
            for (String fieldKey : objfieldMap.keySet()) 
            {
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(f.getName() == fieldName)
                {
                    newConfigData.SVMXC__Display_Type__c = f.getType().name();
                    if(f.getType().name().ToUpperCase() == 'REFERENCE') 
                    {
                        newConfigData.SVMXC__Field_Relationship_Name__c = f.getRelationshipName();
                        List<Schema.sObjectType> schema1 = new List<Schema.sObjectType>();
                        schema1 = f.getReferenceTo();
                        newConfigData.SVMXC__Object_Name__c = string.valueOf(schema1[0]);
                        if(schema1[0] == Account.SObjectType)
                            newConfigData.SVMXC__FKey_Name_Field__c = 'Name';
                        else


                        {
                            Map<String,Schema.SObjectField> R = schema1[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                    newConfigData.SVMXC__FKey_Name_Field__c = f1.getName();
                            }
                        }
                    }
                }
            }
        }
        else if(configType == 'DOCUMENT_LINE_ATTRIBUTE')
        {
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            objfieldMap = SVMXC__RMA_Shipment_Line__c.SObjectType.getDescribe().fields.getMap();
            for (String fieldKey : objfieldMap.keySet()) 
            {
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(f.getName() == fieldName)
                {
                    newConfigData.SVMXC__Display_Type__c = f.getType().name();
                    if(f.getType().name().ToUpperCase() == 'REFERENCE') 
                    {
                        newConfigData.SVMXC__Field_Relationship_Name__c = f.getRelationshipName();
                        List<Schema.sObjectType> schema1 = new List<Schema.sObjectType>();
                        schema1 = f.getReferenceTo();
                        newConfigData.SVMXC__Object_Name__c = string.valueOf(schema1[0]);
                        if(schema1[0] == Account.SObjectType)
                            newConfigData.SVMXC__FKey_Name_Field__c = 'Name';
                        else


                        {
                            Map<String,Schema.SObjectField> R = schema1[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                    newConfigData.SVMXC__FKey_Name_Field__c = f1.getName();
                            }
                        }
                    }
                }
            }
        }
        return newConfigData;
    }
    
    //---------------------------------------------- Method to fill the SFM Event fields before Saving -------------------------------------------------------
    public SVMXC__SFM_Event__c fillingSFMEvent(string namespace, string clas, string methd, string descr, string eventTyp, string CustmActn, integer sequence)
    {
        SVMXC__SFM_Event__c newEvent = new SVMXC__SFM_Event__c();
        newEvent.SVMXC__ServiceMax_Process__c = shpngProces.Id;
        newEvent.SVMXC__Event_Type__c = eventTyp;
        if(eventTyp == 'SFM Custom Action')
        {
            newEvent.SVMXC__Sequence__c = sequence;
            newEvent.SVMXC__ServiceMax_Custom_Action__c = CustmActn;
            return newEvent;
        }
        else
        {
            newEvent.SVMXC__Namespace__c = namespace;
            newEvent.SVMXC__Class__c = clas;
            newEvent.SVMXC__Method__c = methd;
            newEvent.SVMXC__Description__c = descr;
            return newEvent;
        }
    }
    
    //------------------------------------------- Method To Save All the four Expressions ------------------------------------------- 
    public void saveExps()
    {
        if(ExpParentPick != null && ExpParentPick.namedExpression.SVMXC__IsStandard__c != true && (selectedCriteriaParentPick != getTAG026() || isCreateNewParentPick == true))
        {
            for(integer i=0; i < ExpParentPick.expressionDetails.size() ; i++)
                ExpParentPick.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
            ExpParentPick.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpParentPick.expressionDetails);
            Exp = ExpParentPick;
            DetailSize = ParentPickExpDetailSize;
            system.debug('Before save parentPickSize: ' + ParentPickExpDetailSize + ' and Detail Size Is: ' + DetailSize);
            submitExp();
            system.debug('After save parentPickSize: ' + ParentPickExpDetailSize + ' and Detail Size Is: ' + DetailSize);
        }
        if(ExpLinePick != null && ExpLinePick.namedExpression.SVMXC__IsStandard__c != true && (selectedCriterialinePick != getTAG026() || isCreateNewLinePick == true))
        {
            for(integer i=0; i < ExpLinePick.expressionDetails.size() ; i++)
                ExpLinePick.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Line__c';
            ExpLinePick.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpLinePick.expressionDetails);
            Exp = ExpLinePick;
            DetailSize = LinePickExpDetailSize;
            submitExp();
        }
        if(ExpParentShip != null && ExpParentShip.namedExpression.SVMXC__IsStandard__c != true && (selectedCriteriaParentShip != getTAG026() || isCreateNewParentShip == true))
        {
            for(integer i=0; i < ExpParentShip.expressionDetails.size() ; i++)
                ExpParentShip.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
            ExpParentShip.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpParentShip.expressionDetails);
            Exp = ExpParentShip;
            DetailSize = ParentShipExpDetailSize;
            submitExp();
        }
        if(ExpLineShip != null && ExpLineShip.namedExpression.SVMXC__IsStandard__c != true && (selectedCriterialineShip != getTAG026() || isCreateNewLineShip == true))
        {
            for(integer i=0; i < ExpLineShip.expressionDetails.size() ; i++)
                ExpLineShip.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Line__c';
            ExpLineShip.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpLineShip.expressionDetails);
            Exp = ExpLineShip;
            DetailSize = LineShipExpDetailSize;
            submitExp();
        }
        if(ExpProdStock != null && ExpProdStock.namedExpression.SVMXC__IsStandard__c != true && (selectedCriteriaProdStock != getTAG026() || isCreateNewProdStock == true))
        {
            for(integer i=0; i < ExpProdStock.expressionDetails.size() ; i++)
                ExpProdStock.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__Product_Stock__c';
            ExpProdStock.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpProdStock.expressionDetails);
            Exp = ExpProdStock;
            DetailSize = LineShipExpDetailSize;
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
                List<SVMXC__ServiceMax_Config_Data__c> tempExpressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>(); 
                for(SVMXC__ServiceMax_Config_Data__c expressiondtlRec :Exp.expressionDetails)
                {
                    if( (expressiondtlRec.SVMXC__Operator__c == null || expressiondtlRec.SVMXC__Operator__c == 'SVMX.NONE') && (expressiondtlRec.SVMXC__Operand__c == null || expressiondtlRec.SVMXC__Operand__c == '') && expressiondtlRec.SVMXC__Field_Name__c == 'None' )
                    {
                        tempExpressionDetails.add(expressiondtlRec);
                    }
                    else
                    {
                        ExpressionDetails2Save.add(expressiondtlRec);
                        tempExpressionDetails.add(expressiondtlRec);
                    }
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
                            //Added by Neeraj(March-6th) to handle defect- 003164.
                            Exp.expressionDetails.clear();
                            if(tempExpressionDetails.size()>0)
                                Exp.expressionDetails.addAll(tempExpressionDetails);
                            
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + Save_Response.message ));
                            validate = false;
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
    
    //--------------------------------------------- Getter for custom Labels ------------------------------------------------------
    public String getTAG001() {return system.label.CONF024_TAG016;}//'Setup Shipping Process'
    public String getTAG002() {return system.label.CONF024_TAG017;}//'Quick Save'
    public String getTAG003() {return system.label.CONF024_TAG018;}//'Save and Close'
    public String getTAG004() {return system.label.CONF024_TAG019;}//'Cancel'
    public String getTAG005() {return system.label.CONF024_TAG020;}//'General Info'
    public String getTAG006() {return system.label.CONF024_TAG021;}//'Qualification for Pick & Move'
    public String getTAG007() {return system.label.CONF024_TAG022;}//'Updates on Pick & Move'
    public String getTAG008() {return system.label.CONF024_TAG023;}//'Qualification for Pack & Ship'
    public String getTAG009() {return system.label.CONF024_TAG024;}//'Updates on Pack & Ship'
    public String getTAG010() {return system.label.CONF024_TAG025;}//'Custom Events & Links'
    public String getTAG011() {return system.label.CONF024_TAG026;}//'RMA Rules'
    public String getTAG012() {return system.label.CONF024_TAG011;}//'Process Name'
    public String getTAG013() {return system.label.CONF024_TAG010;}//'Process ID'
    public String getTAG014() {return system.label.CONF024_TAG012;}//'Description'
    public String getTAG015() {return system.label.CONF024_TAG027;}//'Choose up to 2 Product fields to show in each line'
    public String getTAG016() {return system.label.CONF024_TAG098;}//'Please enter error message for the criterias does not satisfy.'
    public String getTAG017() {return system.label.CONF024_TAG028;}//'Serial Number Source'
    public String getTAG018() {return system.label.CONF024_TAG029;}//'From Line Record'
    public String getTAG019() {return system.label.CONF024_TAG030;}//'Consider from Stock'
    public String getTAG020() {return system.label.CONF024_TAG031;}//'Capture Interactively'
    public String getTAG021() {return system.label.CONF024_TAG094;}//'This RMA does not match the criteria for pick and move.'
    public String getTAG022() {return system.label.CONF024_TAG095;}//'No RMA lines match the criteria for pick and move.'
    public String getTAG023() {return system.label.CONF024_TAG033;}//'Shipment Console Configuration'
    public String getTAG024() {return system.label.CONF024_TAG034;}//'What to scan first'
    public String getTAG025() {return system.label.CONF024_TAG035;}//'Choose up to 3 fields to show from the Shipment Order'
    public String getTAG026() {return system.label.CONF024_TAG036;}//'--None--'
    public String getTAG027() {return system.label.CONF024_TAG037;}//'View/Edit'
    public String getTAG028() {return system.label.CONF024_TAG038;}//'Create New Criteria'
    public String getTAG029() {return system.label.CONF024_TAG039;}//'Using the expression-builder below, indicate how the Shipment Order qualifies to enter Pick and Move step'
    public String getTAG030() {return system.label.CONF024_TAG040;}//'Field'
    public String getTAG031() {return system.label.CONF024_TAG041;}//'Operator'
    public String getTAG032() {return system.label.CONF024_TAG042;}//'Value'
    public String getTAG033() {return system.label.CONF024_TAG043;}//'Advanced Expression'
    public String getTAG034() {return system.label.CONF024_TAG044;}//'Error message to display if the Shipment Order does not meet the above criteria'
    public String getTAG035() {return system.label.CONF024_TAG045;}//'Using the expression-builder below, indicate how Shipment line records qualify to enter Pick and Move step'
    public String getTAG036() {return system.label.CONF024_TAG046;}//'In this section, configure the automatic field updates to be performed in the Shipment record when all the lines have been picked'
    public String getTAG037() {return system.label.CONF024_TAG047;}//'In this section, configure the automatic field updates to be performed in the child record when line item is picked'
    public String getTAG038() {return system.label.CONF024_TAG048;}//'Using the expression-builder below, indicate how parent records qualify to enter Pack and Ship step'
    public String getTAG039() {return system.label.CONF024_TAG049;}//'Using the expression-builder below, indicate how line records qualify to enter Pack and Ship step'
    public String getTAG040() {return system.label.CONF024_TAG050;}//'Shipment Constraints'
    public String getTAG041() {return system.label.CONF024_TAG051;}//'Allow Partial Shipment'
    public String getTAG042() {return system.label.CONF024_TAG052;}//'In this section, configure the automatic field updates to be performed in the parent record when all the lines are Packed and Shipped'
    public String getTAG043() {return system.label.CONF024_TAG053;}//'In this section, configure the automatic field updates to be performed in the child record when line item is Packed and Shipped'
    public String getTAG044() {return system.label.CONF024_TAG054;}//'Configure Custom Events'
    public String getTAG045() {return system.label.CONF024_TAG055;}//'After Pick and Move'
    public String getTAG046() {return system.label.CONF024_TAG056;}//'After Shipment'
    public String getTAG047() {return system.label.CONF024_TAG057;}//'After Closure'
    public String getTAG048() {return system.label.CONF024_TAG058;}//'Custom Action - 1'
    public String getTAG049() {return system.label.CONF024_TAG059;}//'Custom Action - 2'
    public String getTAG050() {return system.label.CONF024_TAG060;}//'Custom Action - 3'
    public String getTAG051() {return system.label.CONF024_TAG061;}//'Configure Custom Links'
    public String getTAG052() {return system.label.CONF024_TAG062;}//'Configure Internal RMA Generation Rules'
    public String getTAG053() {return system.label.CONF024_TAG063;}//'Create Internal RMA on Ship Confirm'
    public String getTAG054() {return system.label.CONF024_TAG064;}//'Use this mapping definition to create RMA'
    public String getTAG055() {return system.label.CONF024_TAG065;}//'Use this mapping definition to create RMA Lines'
    public String getTAG056() {return system.label.CONF024_TAG066;}//'Configure Supplier RMA Generation Rules'
    public String getTAG057() {return system.label.CONF024_TAG067;}//'Create Supplier RMA on Ship Confirm'
    public String getTAG058() {return system.label.CONF024_TAG068;}//'Product'
    public String getTAG059() {return system.label.CONF024_TAG069;}//'Serial Number'
    public String getTAG060() {return system.label.COMM002_TAG006;}//'Equals'
    public String getTAG061() {return system.label.COMM002_TAG007;}//'Not Equal'
    public String getTAG062() {return system.label.COMM002_TAG008;}//'Greater Than'
    public String getTAG063() {return system.label.COMM002_TAG009;}//'Greater or Equal To'
    public String getTAG064() {return system.label.COMM002_TAG010;}//'Less Than'
    public String getTAG065() {return system.label.COMM002_TAG011;}//'Less or Equal To'
    public String getTAG066() {return system.label.COMM002_TAG012;}//'Starts With'
    public String getTAG067() {return system.label.COMM002_TAG013;}//'Contains'
    public String getTAG068() {return system.label.COMM002_TAG014;}//'Does Not Contain'
    public String getTAG069() {return system.label.COMM002_TAG015;}//'Includes'
    public String getTAG070() {return system.label.COMM002_TAG016;}//'Excludes'
    public String getTAG071() {return system.label.COMM002_TAG022;}//'Is Null'
    public String getTAG072() {return system.label.COMM002_TAG023;}//'Is Not Null'
    public String getTAG073() {return system.label.CONF024_TAG070;}//'Saved successfully'
    public String getTAG074() {return system.label.COMM002_TAG017;}//'Set'
    public String getTAG075() {return system.label.COMM002_TAG018;}//'Increase'
    public String getTAG076() {return system.label.COMM002_TAG019;}//'Decrease'
    public String getTAG077() {return system.label.CONF024_TAG071;}//'Processing...'
    public String getTAG078() {return system.label.CONF024_TAG072;}//'Select Criteria:'
    public String getTAG079() {return system.label.CONF024_TAG074;}//'Internal error occured, please try later.'
    public String getTAG080() {return system.label.CONF024_TAG075;}//'Please add some criteria also.'
    public String getTAG081() {return system.label.CONF024_TAG076;}//'Please enter a valid Expression Name.'
    public String getTAG082() {return system.label.CONF024_TAG077;}//'Expression Id should be atleast 8 characters long.'
    public String getTAG083() {return system.label.CONF024_TAG078;}//'Please select atleast one Serial Number Source.'
    public String getTAG084() {return system.label.CONF024_TAG079;}//'Process Id can not be left empty.Process Id must be atleast 8 characters long.'
    public String getTAG085() {return system.label.CONF024_TAG080;}//'Process Name can not be left empty.'
    public String getTAG086() {return system.label.CONF024_TAG081;}//'What to show from Document-Line, capture 2 fields here'
    public String getTAG087() {return system.label.CONF024_TAG082;}//'Configure Print Templates'
    public String getTAG088() {return system.label.CONF024_TAG083;}//'Launch this VF Template to generate and print Labels'
    public String getTAG089() {return system.label.CONF024_TAG084;}//'Launch this VF Template to generate and Shipment Notes'
    public String getTAG090() {return system.label.CONF024_TAG085;}//'Expression Name'
    public String getTAG091() {return system.label.CONF024_TAG086;}//'Unique Id'
    public String getTAG092() {return system.label.CONF024_TAG087;}//'Please enter Unique Process Id.'
    public String getTAG093() {return system.label.CONF024_TAG088;}//'Namespace'
    public String getTAG094() {return system.label.CONF024_TAG089;}//'Class'
    public String getTAG095() {return system.label.CONF024_TAG090;}//'Method'
    public String getTAG096() {return system.label.CONF024_TAG012;}//'Description'
    public String getTAG097() {return system.label.CONF024_TAG091;}//'One field can be used only once in the update criterias.'
    public String getTAG098() {return system.label.CONF024_TAG096;}//'This RMA does not match the criteria for pack and ship.'
    public String getTAG099() {return system.label.CONF024_TAG097;}//'No RMA lines match the criteria for pack and ship.'
    public String getTAG100() {return system.label.COMM002_TAG032;}//'Add Row'
    public String getTAG101() {return system.label.COMM002_TAG033;}//'Delete Row'
    public String getTAG102() {return system.label.CONF024_TAG099;}//'Using the expression-builder below, indicate how Product stock records qualify to enter Pick and Move step'
    public string getHLPURL() {return system.label.CONF024_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
}