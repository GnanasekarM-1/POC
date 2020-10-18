public with sharing class CONF_SetupReceivingProcess
{
    //------------------------------------------------ Variables declaration and getter setters -----------------------------------------------------
    //Receiving process obj
    public SVMXC__ServiceMax_Processes__c ReceivingProcessObj {get; set;}
    public SVMXC__ServiceMax_Processes__c ReceiptHeader_ExpressionsDef {get; set; }
    public SVMXC__ServiceMax_Processes__c ReceiptLine_ExpressionsDef{get; set; }
    public SVMXC__ServiceMax_Processes__c DeliveryHeader_ExpressionsDef {get; set; }
    public SVMXC__ServiceMax_Processes__c DeliveryLine_ExpressionsDef{get; set; }
    public List<SVMXC__ServiceMax_Processes__c> objectMappingPO_WO;
    public List<SVMXC__ServiceMax_Processes__c> objectMappingPOL_WOL;
    public SVMXC__ServiceMax_Config_Data__c SelectedDocument1{ get; set; }
    public SVMXC__ServiceMax_Config_Data__c SelectedDocument2{ get; set; }
    public SVMXC__ServiceMax_Config_Data__c SelectedDocument3{ get; set; }
    public SVMXC__ServiceMax_Config_Data__c SelectedDocumentLine1{ get; set; }
    public SVMXC__ServiceMax_Config_Data__c SelectedDocumentLine2{ get; set; }
    
    public List<SVMXC__ServiceMax_Config_Data__c> ReceiptHeader_ExpressionsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getReceiptHeader_ExpressionsLst(){return ReceiptHeader_ExpressionsLst;}
    public void setReceiptHeader_ExpressionsLst(List<SVMXC__ServiceMax_Config_Data__c> val){this.ReceiptHeader_ExpressionsLst = val;}
    public List<SVMXC__ServiceMax_Config_Data__c> ReceiptLine_ExpressionsLst{get; set; }
    public List<SVMXC__ServiceMax_Config_Data__c> ReceiptFieldUpdateRecsLst_Header{get; set; }
    public List<SVMXC__ServiceMax_Config_Data__c> ReceiptFieldUpdateRecsLst_Line{get; set; }
    public List<SVMXC__ServiceMax_Config_Data__c> DeliveryHeader_ExpressionsLst{get; set; }
    public List<SVMXC__ServiceMax_Config_Data__c> DeliveryLine_ExpressionsLst{get; set;}
    public List<SVMXC__ServiceMax_Config_Data__c> DeliveryFieldUpdateRecsLst_Header{get; set; }
    public List<SVMXC__ServiceMax_Config_Data__c> DeliveryFieldUpdateRecsLst_Line{get; set; }
    
    public SVMXC__SFM_Event__c event_EntitlementAttributes{get; set;}
    public SVMXC__SFM_Event__c EventAfterReceiptObj {get; set;}
    public SVMXC__SFM_Event__c EventAfterDeliveryObj {get; set;}
    public SVMXC__SFM_Event__c EventAfterClosureObj {get; set;}
    
    public string Mode;
    public String SelectedHeaderExpressionId {get; set;}
    public String SelectedLineExpressionId {get; set;}
    public String SlctdHdrExprId_Delivery{get; set;}
    public String SlctdLineExprId_Delivery{get; set;}
    public String DefaultDeliveryLoc{get; set;}
    
    public String HeaderId;
    public Integer deliveryRuleSelIndex { get; set; }
    
    public Boolean Tab2Hdr_New_Edit_ExpMode = false;
    public Boolean getTab2Hdr_New_Edit_ExpMode(){ return Tab2Hdr_New_Edit_ExpMode;}
    public Boolean Tab2Line_New_Edit_ExpMode = false;
    public Boolean getTab2Line_New_Edit_ExpMode(){ return Tab2Line_New_Edit_ExpMode;}
    public Boolean rendertab2hdrexpblk{get; set;}
    public Boolean rendertab2lineexpblk{get; set;}
    public Boolean tab2hdrexprlinkblk_Render = false; 
    public Boolean gettab2hdrexprlinkblk_Render(){ return tab2hdrexprlinkblk_Render; }
    public Boolean tab2lineexprlinkblk_Render = false;
    public Boolean gettab2lineexprlinkblk_Render(){ return tab2lineexprlinkblk_Render; }
    public Boolean Tab5Hdr_New_Edit_ExpMode = false;
    public Boolean getTab5Hdr_New_Edit_ExpMode(){ return Tab5Hdr_New_Edit_ExpMode;}
    public Boolean Tab5Line_New_Edit_ExpMode = false;
    public Boolean getTab5Line_New_Edit_ExpMode(){ return Tab5Line_New_Edit_ExpMode;}
    public Boolean rendertab5hdrexpblk{get; set;}
    public Boolean rendertab5lineexpblk{get; set;}
    public Boolean tab5hdrexprlinkblk_Render = false; 
    public Boolean gettab5hdrexprlinkblk_Render(){ return tab5hdrexprlinkblk_Render; }
    public Boolean tab5lineexprlinkblk_Render = false;
    public Boolean gettab5lineexprlinkblk_Render(){ return tab5lineexprlinkblk_Render; }
    public Boolean QuickSaveComplete;
    public Boolean rendertab8SpclObjectMappingData = false;
    public Boolean getrendertab8SpclObjectMappingData(){ return rendertab8SpclObjectMappingData; }
    public Boolean rendertab8ObjectMappingData = false;
    public Boolean getrendertab8ObjectMappingData(){ return rendertab8ObjectMappingData; }
    public Boolean DisableEntitleNWS{get; set;}
    
    //Utils
    public SFM_Utils ObjName_util = new SFM_Utils();
    public ServiceFlowWizard_Utils SFWUtils = new ServiceFlowWizard_Utils();
    
    //Generic Expression related
    public List<SelectOption> OperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getOperatorSelectLst(){ return OperatorSelectLst; }
    //Generic Source Object Update Related List
    public List<SelectOption> ObjUpdate_OperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getObjUpdate_OperatorSelectLst(){ return ObjUpdate_OperatorSelectLst; }
    //Select List of picklist values of Serial No. Source
    public List<SelectOption> lstProductFields = new List<SelectOption>();
    public List<SelectOption> getlstProductFields(){return lstProductFields;}
    public List<SelectOption> lstDocumentFields = new List<SelectOption>();
    public List<SelectOption> getlstDocumentFields(){return lstDocumentFields;}
    public List<SelectOption> lstDocumentLineFields = new List<SelectOption>();
    public List<SelectOption> getlstDocumentLineFields(){return lstDocumentLineFields;}
    public List<SelectOption> lstPOHeaderExpr;
    public List<SelectOption> getlstPOHeaderExpr(){return lstPOHeaderExpr;}
    public List<SelectOption> HeaderObjFieldNames;
    public List<SelectOption> getHeaderObjFieldNames(){ return HeaderObjFieldNames; }
    public List<SelectOption> lstPOLineExpr;
    public List<SelectOption> getlstPOLineExpr(){return lstPOLineExpr;}
    public List<SelectOption> detailObjFieldNames;
    public List<SelectOption> getdetailObjFieldNames(){ return detailObjFieldNames; }
    //Section 3 picklist 
    public List<SelectOption> unexpectedSN;
    public List<SelectOption> getunexpectedSN() { return unexpectedSN; }
    public List<SelectOption> unexpectedProduct;
    public List<SelectOption> getunexpectedProduct() { return unexpectedProduct; }
    public List<SelectOption> ExcessQty;
    public List<SelectOption> getExcessQty() { return ExcessQty; }
    /* public List<SelectOption> LessQty;
    public List<SelectOption> getLessQty() { return LessQty; } */
    public List<SelectOption> slctLst_objectMappingPO_WO;
    public List<SelectOption> getslctLst_objectMappingPO_WO(){ return slctLst_objectMappingPO_WO; }
    public List<SelectOption> slctLst_objectMappingPOL_WOL;
    public List<SelectOption> getslctLst_objectMappingPOL_WOL(){ return slctLst_objectMappingPOL_WOL; }
    public List<SelectOption> slctLst_objectMappingPOL_WO;
    public List<SelectOption> getslctLst_objectMappingPOL_WO(){ return slctLst_objectMappingPOL_WO; }
    public List<SelectOption> slctLst_PrecedenceOptns;
    public List<SelectOption> getslctLst_PrecedenceOptns(){ return slctLst_PrecedenceOptns; }
    
    //Select List of Product Reference Fields
    public MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
    public Map<String, SObjectField> mapPartsOrderFields;
    public Map<String, SObjectField> mapPartsOrderLineFields;
    public Map<Id,SVMXC__ServiceMax_Processes__c> mapHeaderExpressionRecs = new Map<Id,SVMXC__ServiceMax_Processes__c>();
    public Map<Id,SVMXC__ServiceMax_Processes__c> mapLineExpressionRecs = new Map<Id,SVMXC__ServiceMax_Processes__c>();
    public Map<Id,List<SVMXC__ServiceMax_Config_Data__c>> mapHeaderExpression_DetailsRecs = new Map<Id,List<SVMXC__ServiceMax_Config_Data__c>>();
    public Map<Id,List<SVMXC__ServiceMax_Config_Data__c>> mapLineExpression_DetailsRecs = new Map<Id,List<SVMXC__ServiceMax_Config_Data__c>>();
    public Map<String,String> mapApiName_RealName_ShipmentHdr = new Map<String,String>();
    public Map<String,String> mapApiName_RealName_ShipmentLine = new Map<String,String>();
    public MAP<String,Schema.Sobjectfield> mapPOLineAPINameSchemaSobjField = new MAP<String,Schema.Sobjectfield>();
    
    public Integer ReceiptHeader_HighestSequenceNum
    {
        get{return ReceiptHeader_ExpressionsLst.size();}
    } 
    public Integer ReceiptLine_HighestSequenceNum
    { 
        get{return ReceiptLine_ExpressionsLst.size();}
    }
    public Integer ReceiptHdrFldUpdt_HighestSequenceNum
    { 
        get{return ReceiptFieldUpdateRecsLst_Header.size();}
    } 
    public Integer ReceiptLineFldUpdt_HighestSequenceNum
    { 
        get{return ReceiptFieldUpdateRecsLst_Line.size();}
    }
    public Integer DeliveryHeader_HighestSequenceNum
    { 
        get{return DeliveryHeader_ExpressionsLst.size();}
    } 
    public Integer DeliveryLine_HighestSequenceNum
    { 
        get{return DeliveryLine_ExpressionsLst.size();}
    }
    public Integer DeliveryHdrFldUpdt_HighestSequenceNum
    {
        get{return DeliveryFieldUpdateRecsLst_Header.size();}
    } 
    public Integer DeliveryLineFldUpdt_HighestSequenceNum
    { 
        get{return DeliveryFieldUpdateRecsLst_Line.size();}
    }
    
    //All depots
    public RecordType RType_DeliveryRule;
    public RecordType RType_expressions;
    public List<RecordType> Rtype_Prod_Doc_Attributes = new List<RecordType>();
    
    
    //----------------------------------------------------- OnLoad / Constructor ---------------------------------------------------------
    public CONF_SetupReceivingProcess()
    {
        //----------------Determine mode of operation & HeaderId---------------------------
        HeaderId = System.currentPageReference().getParameters().get('SVMX_RecordId');
        String TempMode = System.currentPageReference().getParameters().get('SVMX_Mode');
        List<SVMXC__ServiceMax_Config_Data__c> TempQueryList = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(HeaderId == null || HeaderId == '')
            Mode = 'New';
        else if(HeaderId != null && HeaderId != '' && TempMode == null)
            Mode = 'Edit';
        else if(HeaderId != null && HeaderId != '' && TempMode == 'Clone')
            Mode = 'Clone';

        DisableEntitleNWS = true;
        
        //-----------------------------querying recordTypes------------------------------------
        RType_DeliveryRule = [Select Id, Name from RecordType WHERE SObjectType='SVMXC__ServiceMax_Processes__c' AND Name = 'SVMX Rule' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RType_expressions = [Select Id, Name from RecordType WHERE SObjectType='SVMXC__ServiceMax_Config_Data__c' AND Name = 'Expressions' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        //Operator Select List
        OperatorSelectLst.add(new SelectOption('SVMX.NONE',getTag056()));//'--None--'));
        OperatorSelectLst.add(new SelectOption('eq',getTag131()));//'Equals'));
        OperatorSelectLst.add(new SelectOption('ne',getTag132()));//'Not Equal'));
        OperatorSelectLst.add(new SelectOption('gt',getTag133()));//'Greater Than'));
        OperatorSelectLst.add(new SelectOption('ge',getTag134()));//'Greater or Equal To'));
        OperatorSelectLst.add(new SelectOption('lt',getTag135()));//'Less Than'));
        OperatorSelectLst.add(new SelectOption('le',getTag136()));//'Less or Equal To'));
        OperatorSelectLst.add(new SelectOption('starts',getTag137()));//'Starts With'));
        OperatorSelectLst.add(new SelectOption('contains',getTag138()));//'Contains'));
        OperatorSelectLst.add(new SelectOption('notcontain',getTag139()));//'Does Not Contain'));
        OperatorSelectLst.add(new SelectOption('in',getTag140()));//'Includes'));
        OperatorSelectLst.add(new SelectOption('notin',getTag141()));//'Excludes'));
        OperatorSelectLst.add(new SelectOption('isnull',getTag142()));//'Is Null'));
        OperatorSelectLst.add(new SelectOption('isnotnull',getTag143()));//'Is Not Null'));

        ObjUpdate_OperatorSelectLst.add(new SelectOption('Set',getTag144()));//'Set'));
        ObjUpdate_OperatorSelectLst.add(new SelectOption('Increase',getTag145()));//'Increase'));
        ObjUpdate_OperatorSelectLst.add(new SelectOption('Decrease',getTag146()));//'Decrease'));

        ReceivingProcessObj = new SVMXC__ServiceMax_Processes__c(SVMXC__IsStandard__c = false, SVMXC__APL_Action_On_Unexpected_SN__c = 'ADD', SVMXC__APL_Action_On_Unexpected_Product__c = 'ADD', SVMXC__APL_Action_On_Excess_Qty__c = 'ADD', SVMXC__APL_Create_Work_Order_On__c = 'NOT_APPLICABLE', SVMXC__APL_Group_Work_Order_By__c = 'ONE_PRODUCT', SVMXC__APL_Serial_Number_Source__c = 'LINE_TXT_SN'); //SVMXC__APL_Action_On_Less_Qty__c  = 'DO NOTHING', 
        
        ReceivingProcessObj.RecordTypeId = [Select Id, Name from RecordType where Name = 'Receiving Process' AND SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        
        Rtype_Prod_Doc_Attributes = [Select Id, Name from RecordType where Name = 'Field Mapping' AND SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        ReceivingProcessObj.Parent_Error_Msg__c = getTag127();
        ReceivingProcessObj.Child_Error_Msg__c = getTag128();
        ReceivingProcessObj.Parent_Error_Msg2__c = getTag129();
        ReceivingProcessObj.Child_Error_Msg2__c = getTag130();
        
        String APIName_Header = ObjName_util.getOriginalAPIName('SVMXC__RMA_Shipment_Order__c', allObjs);
        String APIName_Line = ObjName_util.getOriginalAPIName('SVMXC__RMA_Shipment_Line__c', allObjs);
        
        mapPartsOrderFields = allObjs.get(APIName_Header).getDescribe().fields.getMap();
        mapPartsOrderLineFields = allObjs.get(APIName_Line).getDescribe().fields.getMap();
        for(String FieldApiName :mapPartsOrderFields.keyset())
            mapApiName_RealName_ShipmentHdr.put(mapPartsOrderFields.get(FieldApiName).getDescribe().getName(),FieldApiName);
        
        for(String str :mapPartsOrderLineFields.keyset())
        {
            String strFieldAPIName = mapPartsOrderLineFields.get(str).getDescribe().getName();
            mapApiName_RealName_ShipmentLine.put(strFieldAPIName,str);
            mapPOLineAPINameSchemaSobjField.put(strFieldAPIName,mapPartsOrderLineFields.get(str));
        }    
            
        
        COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
        lstProductFields = new List<SelectOption>();
        List<SelectOption> TemplstSelectOptions = new List<SelectOption>();
        DispMethods.RetriveField('Product2', TemplstSelectOptions, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        lstProductFields.add(new SelectOption('ServiceMax_NONE',getTag056()));
        lstProductFields.addAll(TemplstSelectOptions);
        
        List<SelectOption> TemplstSelectOptions_Doc = new List<SelectOption>();
        List<SelectOption> TemplstSelectOptions_DocLine = new List<SelectOption>();
        lstDocumentFields = new List<SelectOption>();
        lstDocumentLineFields = new List<SelectOption>();
        HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
        DispMethods = new WORD_SetupDispatch_Methods();
        
        //doc fields
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Order__c', TemplstSelectOptions_Doc, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        lstDocumentFields.add(new SelectOption('ServiceMax_NONE',getTag056()));
        lstDocumentFields.addAll(TemplstSelectOptions_Doc);
        
        //doc line fields
        /*DispMethods.RetriveField('SVMXC__RMA_Shipment_Line__c', TemplstSelectOptions_DocLine, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        lstDocumentLineFields.add(new SelectOption('ServiceMax_NONE',getTag056()));
        lstDocumentLineFields.addAll(TemplstSelectOptions_DocLine);*/
        lstDocumentLineFields.add(new SelectOption('ServiceMax_NONE',getTag056()));
        if(mapPOLineAPINameSchemaSobjField.size() > 0)
        {
            for(String str:mapPOLineAPINameSchemaSobjField.keyset())
            {
                Schema.DescribeFieldResult f = mapPOLineAPINameSchemaSobjField.get(str).getDescribe();
                if(f.getType() == schema.Displaytype.REFERENCE)
                {
                    if(f.getReferenceTo()[0].getDescribe().getName() != 'Product2')
                        lstDocumentLineFields.add(new SelectOption(str,f.getLabel()));
                }
                else
                {
                    lstDocumentLineFields.add(new SelectOption(str,f.getLabel()));
                }
            }
        }
        
        SelectedDocument1 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_Prod_Doc_Attributes[0].Id, Configuration_Type__c = 'DOCUMENT_ATTRIBUTE', SVMXC__Sequence__c = 1);
        SelectedDocument2 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_Prod_Doc_Attributes[0].Id, Configuration_Type__c = 'DOCUMENT_ATTRIBUTE', SVMXC__Sequence__c = 2);
        SelectedDocument3 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_Prod_Doc_Attributes[0].Id, Configuration_Type__c = 'DOCUMENT_ATTRIBUTE', SVMXC__Sequence__c = 3);
        
        SelectedDocumentLine1 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_Prod_Doc_Attributes[0].Id, Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE', SVMXC__Sequence__c = 1);
        SelectedDocumentLine2 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_Prod_Doc_Attributes[0].Id, Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE', SVMXC__Sequence__c = 2);

        //Populate the Entitlement Attributes
        event_EntitlementAttributes = new SVMXC__SFM_Event__c();
        event_EntitlementAttributes.SVMXC__Event_Type__c = 'Before Entitlement';
        event_EntitlementAttributes.SVMXC__Event_Call_Type__c = 'WEBSERVICE';
        event_EntitlementAttributes.SVMXC__Namespace__c = '';
        event_EntitlementAttributes.SVMXC__Class__c = '';
        event_EntitlementAttributes.SVMXC__Method__c = '';
        event_EntitlementAttributes.SVMXC__Description__c = '';

        //Create the Header and detail list for expression block
        ReceiptHeader_ExpressionsDef = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RType_DeliveryRule.Id, SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c', SVMXC__Rule_Type__c = 'Named Expression', SVMXC__IsStandard__c = false);
        ReceiptHeader_ExpressionsLst = new List<SVMXC__ServiceMax_Config_Data__c>();

        ReceiptLine_ExpressionsDef = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RType_DeliveryRule.Id, SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c', SVMXC__Rule_Type__c = 'Named Expression', SVMXC__IsStandard__c = false);
        ReceiptLine_ExpressionsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        rendertab2hdrexpblk = false;
        rendertab2lineexpblk = false;
        
        HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
        DispMethods = new WORD_SetupDispatch_Methods();
        lstPOHeaderExpr = new List<SelectOption>();
        lstPOLineExpr = new List<SelectOption>();
        lstPOHeaderExpr.add(new SelectOption('ServiceMax_NONE',getTag056()));
        HeaderObjFieldNames = new List<SelectOption>();
        List<SelectOption> tempHdrObjectFlds = new List<SelectOption>();
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Order__c', tempHdrObjectFlds, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        HeaderObjFieldNames.add(new SelectOption('ServiceMax_NONE',getTag056()));
        HeaderObjFieldNames.addAll(tempHdrObjectFlds);
        
        //Line fields population
        detailObjFieldNames = new List<SelectOption>();
        List<SelectOption> tempChildObjectFlds = new List<SelectOption>();
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Line__c', tempChildObjectFlds, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        detailObjFieldNames.add(new SelectOption('ServiceMax_NONE',getTag056()));
        detailObjFieldNames.addAll(tempChildObjectFlds);
        //Tab 2 Section 1 Header Expression data
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap stringMapRec = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Order__c');
        lstStringMap.add(stringMapRec);

        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request('','','',lstStringMap);
        SFM_GetNamedExpressionList getExpCls = new SFM_GetNamedExpressionList();
        SFM_WrapperDef.SFM_Response_Expression ResEXP;
        ResEXP = getExpCls.SFM_getNamedExpressionList(request);
        
        lstPOHeaderExpr = new List<SelectOption>();
        lstPOHeaderExpr.add(new SelectOption('ServiceMax_NONE', getTag056()));

        if(ResEXP != null && ResEXP.expressions != null)
        {
            for(SFM_WrapperDef.SFM_Expression Sfm_Exp :ResEXP.expressions) //SFM_Response_Expression
            {
                //populate the header expression picklist
                lstPOHeaderExpr.add(new SelectOption(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression.SVMXC__Name__c ));
                mapHeaderExpressionRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression);
                mapHeaderExpression_DetailsRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.expressionDetails);
            }
        }

        stringMapRec = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Line__c');
        lstStringMap.clear();
        lstStringMap.add(stringMapRec);
        
        //Create the request
        request = new SFM_WrapperDef.SFM_Request('','','',lstStringMap);
        
        //Result
        ResEXP = getExpCls.SFM_getNamedExpressionList(request);
        
        lstPOLineExpr = new List<SelectOption>();
        lstPOLineExpr.add(new SelectOption('ServiceMax_NONE', getTag056()));
        
        if(ResEXP != null && ResEXP.expressions != null)
        {
            for(SFM_WrapperDef.SFM_Expression Sfm_Exp :ResEXP.expressions) //SFM_Response_Expression
            {
                //populate the header expression picklist
                lstPOLineExpr.add(new SelectOption(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression.SVMXC__Name__c ));
                mapLineExpressionRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression);
                mapLineExpression_DetailsRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.expressionDetails);
            }
        }
        
        unexpectedSN = new List<SelectOption>();
        unexpectedProduct = new List<SelectOption>();
        ExcessQty = new List<SelectOption>();

        unexpectedSN.add(new SelectOption('ADD', getTag108()));
        unexpectedSN.add(new SelectOption('NOT ALLOWED', getTag107()));

        unexpectedProduct.add(new SelectOption('ADD', getTag108()));
        unexpectedProduct.add(new SelectOption('NOT ALLOWED', getTag107()));

        ExcessQty.add(new SelectOption('ADD', getTag108()));
        ExcessQty.add(new SelectOption('NOT ALLOWED', getTag107()));

        //Create the Header and detail list for receipt mapping block
        ReceiptFieldUpdateRecsLst_Header = new List<SVMXC__ServiceMax_Config_Data__c>();
        ReceiptFieldUpdateRecsLst_Line = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        EventAfterReceiptObj = new SVMXC__SFM_Event__c(SVMXC__Event_Type__c = 'After Receipt',SVMXC__Event_Call_Type__c = 'WEBSERVICE', SVMXC__Namespace__c = '' ,SVMXC__Class__c = '', SVMXC__Method__c = '', SVMXC__Description__c = '');
        EventAfterDeliveryObj = new SVMXC__SFM_Event__c(SVMXC__Event_Type__c = 'After Delivery',SVMXC__Event_Call_Type__c = 'WEBSERVICE', SVMXC__Namespace__c = '' ,SVMXC__Class__c = '', SVMXC__Method__c = '', SVMXC__Description__c = '');
        EventAfterClosureObj = new SVMXC__SFM_Event__c(SVMXC__Event_Type__c = 'After Closure',SVMXC__Event_Call_Type__c = 'WEBSERVICE', SVMXC__Namespace__c = '' ,SVMXC__Class__c = '', SVMXC__Method__c = '', SVMXC__Description__c = '');

        DeliveryHeader_ExpressionsDef = new SVMXC__ServiceMax_Processes__c(SVMXC__IsStandard__c = false);
        DeliveryHeader_ExpressionsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        DeliveryLine_ExpressionsDef = new SVMXC__ServiceMax_Processes__c(SVMXC__IsStandard__c = false);
        DeliveryLine_ExpressionsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        rendertab5hdrexpblk = false;
        rendertab5lineexpblk = false;

        //Create the Header and detail list for Delivery mapping block
        DeliveryFieldUpdateRecsLst_Header = new List<SVMXC__ServiceMax_Config_Data__c>();
        DeliveryFieldUpdateRecsLst_Line = new List<SVMXC__ServiceMax_Config_Data__c>();

        //Tab 8
        //Header Object Map records
        objectMappingPO_WO = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPO_WO = [Select id, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c' order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        slctLst_objectMappingPO_WO = new List<Selectoption>();
        for(SVMXC__ServiceMax_Processes__c ObjMapRec :objectMappingPO_WO)
            slctLst_objectMappingPO_WO.add(new selectOption(ObjMapRec.Id, ObjMapRec.SVMXC__Name__c));

        //Detail Object Map records
        objectMappingPOL_WOL = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPOL_WOL = [Select id, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c' order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        List<SVMXC__ServiceMax_Processes__c> objectMappingPOL_WO = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPOL_WO = [Select id, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c' order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        slctLst_objectMappingPOL_WOL = new List<Selectoption>();
        for(SVMXC__ServiceMax_Processes__c ObjMapRec :objectMappingPOL_WOL)
            slctLst_objectMappingPOL_WOL.add(new selectOption(ObjMapRec.Id, ObjMapRec.SVMXC__Name__c));
        
        slctLst_objectMappingPOL_WO = new List<Selectoption>();
        for(SVMXC__ServiceMax_Processes__c ObjMapRec :objectMappingPOL_WO)
            slctLst_objectMappingPOL_WO.add(new selectOption(ObjMapRec.Id, ObjMapRec.SVMXC__Name__c));
        
        slctLst_PrecedenceOptns = new List<Selectoption>();
        slctLst_PrecedenceOptns.add(new SelectOption('APPLY_ORDER_FIRST',getTag151()));
        slctLst_PrecedenceOptns.add(new SelectOption('APPLY_LINE_FIRST',getTag152()));
        
        if(Mode == 'New')
        {
            ReceiptSourceUpdateAddLines_Header();
            ReceiptSourceUpdateAddLines_Line();
            DeliverySourceUpdateAddLines_Header();
            DeliverySourceUpdateAddLines_Line();
        }
        //Edit mode
        if(Mode == 'Edit')
        {
            ReceivingProcessObj = [Select Id, SVMXC__IsStandard__c, SVMXC__Resolve_Unexpected_SN_To_IB__c, SVMXC__APL_Perform_Entitlement__c , SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__APL_Scan_First__c, SVMXC__Node_Parent__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Final_Exception_Process__c, SVMXC__APL_Action_On_Unexpected_SN__c, SVMXC__APL_Action_On_Unexpected_Product__c, SVMXC__APL_Action_On_Excess_Qty__c, SVMXC__APL_Action_On_Less_Qty__c, SVMXC__Parent_Error_Msg__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Child_Error_Msg2__c, SVMXC__APL_Split_Lines__c, SVMXC__APL_Create_Work_Order_On__c, SVMXC__APL_Group_Work_Order_By__c, SVMXC__Parent_Object__c, SVMXC__Process__c, SVMXC__APL_Serial_Number_Source__c, SVMXC__APL_Create_WO_Preference__c from SVMXC__ServiceMax_Processes__c where Id = :HeaderId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(ReceivingProcessObj.SVMXC__Resolve_Unexpected_SN_To_IB__c == true)
                DisableEntitleNWS = false;
                
            if(ReceivingProcessObj.SVMXC__Node_Parent__c != null)
            {
                SelectedHeaderExpressionId = ReceivingProcessObj.SVMXC__Node_Parent__c;
                tab2hdrexprlinkblk_Render = true;
            }
            else
                SelectedHeaderExpressionId = 'ServiceMax_NONE';
            if(ReceivingProcessObj.SVMXC__Submodule__c != null)
            {
                SelectedLineExpressionId = ReceivingProcessObj.SVMXC__Submodule__c;
                tab2lineexprlinkblk_Render = true;
            }
            else
                SelectedLineExpressionId = 'ServiceMax_NONE';
            if(ReceivingProcessObj.SVMXC__Module__c != null)
            {
                SlctdHdrExprId_Delivery = ReceivingProcessObj.SVMXC__Module__c;
                tab5hdrexprlinkblk_Render = true;
            }
            else
                SlctdHdrExprId_Delivery = 'ServiceMax_NONE';
            if(ReceivingProcessObj.SVMXC__Final_Exception_Process__c != null)
            {
                SlctdLineExprId_Delivery = ReceivingProcessObj.SVMXC__Final_Exception_Process__c;
                tab5lineexprlinkblk_Render = true;
            }
            else
                SlctdLineExprId_Delivery = 'ServiceMax_NONE';
            
            if(HeaderId != null)
                TempQueryList = [Select Id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Field Mapping' AND SVMXC__Dispatch_Process__c = :HeaderId AND (SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_RECEIPT' OR SVMXC__Configuration_Type__c = 'LINE_UPD_ON_RECEIPT' OR SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_DELIVERY' OR SVMXC__Configuration_Type__c = 'LINE_UPD_ON_DELIVERY' OR SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE' OR SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE' OR SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            for(SVMXC__ServiceMax_Config_Data__c FieldMappingRec :TempQueryList)
            {
                if(FieldMappingRec.SVMXC__Configuration_Type__c == 'HEADER_UPD_ON_RECEIPT')
                    ReceiptFieldUpdateRecsLst_Header.add(FieldMappingRec);
                else if(FieldMappingRec.SVMXC__Configuration_Type__c == 'LINE_UPD_ON_RECEIPT')
                    ReceiptFieldUpdateRecsLst_Line.add(FieldMappingRec);
                else if(FieldMappingRec.SVMXC__Configuration_Type__c == 'HEADER_UPD_ON_DELIVERY')
                    DeliveryFieldUpdateRecsLst_Header.add(FieldMappingRec);
                else if(FieldMappingRec.SVMXC__Configuration_Type__c == 'LINE_UPD_ON_DELIVERY')
                    DeliveryFieldUpdateRecsLst_Line.add(FieldMappingRec);
                else if(FieldMappingRec.Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && FieldMappingRec.SVMXC__Sequence__c == 1)
                    SelectedDocument1 = FieldMappingRec;
                else if(FieldMappingRec.Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && FieldMappingRec.SVMXC__Sequence__c == 2)
                    SelectedDocument2 = FieldMappingRec;
                else if(FieldMappingRec.Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && FieldMappingRec.SVMXC__Sequence__c == 3)
                    SelectedDocument3 = FieldMappingRec;
                else if(FieldMappingRec.Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && FieldMappingRec.SVMXC__Sequence__c == 1)
                    SelectedDocumentLine1 = FieldMappingRec;
                else if(FieldMappingRec.Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && FieldMappingRec.SVMXC__Sequence__c == 2)
                    SelectedDocumentLine2 = FieldMappingRec;
            }
            
            List<SVMXC__SFM_Event__c> lstSFM_EventRec = new List<SVMXC__SFM_Event__c>();
            if(HeaderId != null)
                lstSFM_EventRec = [Select SVMXC__Sequence__c, SVMXC__Event_Type__c, SVMXC__Description__c, SVMXC__Event_Call_Type__c, SVMXC__Namespace__c, SVMXC__ServiceMax_Custom_Action__c, SVMXC__Class__c, SVMXC__Method__c, SVMXC__ServiceMax_Process__c from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c = :HeaderId AND (SVMXC__Event_Type__c = 'After Receipt' OR SVMXC__Event_Type__c = 'After Delivery' OR SVMXC__Event_Type__c = 'After Closure' OR SVMXC__Event_Type__c = 'Before Entitlement')]; // OR SVMXC__Event_Type__c = 'SFM Custom Action'
            for(SVMXC__SFM_Event__c EventRec :lstSFM_EventRec)
            {
                if(EventRec.SVMXC__Event_Type__c == 'Before Entitlement')
                    event_EntitlementAttributes = EventRec;
                else if(EventRec.SVMXC__Event_Type__c == 'After Receipt')
                    EventAfterReceiptObj = EventRec;
                else if(EventRec.SVMXC__Event_Type__c == 'After Delivery')
                    EventAfterDeliveryObj = EventRec;
                else if(EventRec.SVMXC__Event_Type__c == 'After Closure')
                     EventAfterClosureObj = EventRec;
            }
            
            rendersubsequentblock();
            /* if(ReceivingProcessObj.APL_Create_Work_Order_On__c == 'NOT_APPLICABLE')
                rendertab8ObjectMappingData = false;
            else
                rendertab8ObjectMappingData = true;
                
            if(ReceivingProcessObj.SVMXC__APL_Group_Work_Order_By__c == 'ONE_PRODUCT')
                rendertab8SpclObjectMappingData = true;
            else 
                rendertab8SpclObjectMappingData = false; */
        }
        else if(Mode == 'Clone')
        {
            SVMXC__ServiceMax_Processes__c tempReceivingProcessObj = [Select Id, SVMXC__APL_Perform_Entitlement__c , SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__APL_Scan_First__c, SVMXC__Node_Parent__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Final_Exception_Process__c, SVMXC__APL_Action_On_Unexpected_SN__c, SVMXC__APL_Action_On_Unexpected_Product__c, SVMXC__APL_Action_On_Excess_Qty__c, SVMXC__APL_Action_On_Less_Qty__c, SVMXC__Parent_Error_Msg__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Child_Error_Msg2__c, SVMXC__APL_Split_Lines__c, SVMXC__APL_Create_Work_Order_On__c, SVMXC__APL_Group_Work_Order_By__c, SVMXC__Parent_Object__c, SVMXC__Process__c, SVMXC__APL_Serial_Number_Source__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c where Id = :HeaderId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
            ReceivingProcessObj = tempReceivingProcessObj.clone(false, true);
            ReceivingProcessObj.SVMXC__IsStandard__c = false;
            
            if(ReceivingProcessObj.SVMXC__Resolve_Unexpected_SN_To_IB__c == true)
                DisableEntitleNWS = false;
            
            if(ReceivingProcessObj.SVMXC__Node_Parent__c != null)
                SelectedHeaderExpressionId = ReceivingProcessObj.SVMXC__Node_Parent__c;
            else
                SelectedHeaderExpressionId = 'ServiceMax_NONE';
            if(ReceivingProcessObj.SVMXC__Submodule__c != null)
                SelectedLineExpressionId = ReceivingProcessObj.SVMXC__Submodule__c;
            else
                SelectedLineExpressionId = 'ServiceMax_NONE';
            if(ReceivingProcessObj.SVMXC__Module__c != null)
                SlctdHdrExprId_Delivery = ReceivingProcessObj.SVMXC__Module__c;
            else
                SlctdHdrExprId_Delivery = 'ServiceMax_NONE';
            if(ReceivingProcessObj.SVMXC__Final_Exception_Process__c != null)
                SlctdLineExprId_Delivery = ReceivingProcessObj.SVMXC__Final_Exception_Process__c;
            else
                SlctdLineExprId_Delivery = 'ServiceMax_NONE';

            //Related product attribute, document attribute, Mapping records are cloned
            List<SVMXC__ServiceMax_Config_Data__c> clone_TempQueryList = new List<SVMXC__ServiceMax_Config_Data__c>();
            
            clone_TempQueryList = [Select Id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Field Mapping' AND SVMXC__Dispatch_Process__c = :HeaderId AND (SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_RECEIPT' OR SVMXC__Configuration_Type__c = 'LINE_UPD_ON_RECEIPT' OR SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_DELIVERY' OR SVMXC__Configuration_Type__c = 'LINE_UPD_ON_DELIVERY' OR SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE' OR SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE')]; //  OR SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE' //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            TempQueryList = clone_TempQueryList.deepclone(false,false,false);
            
            for(SVMXC__ServiceMax_Config_Data__c FieldMappingRec :TempQueryList)
            {
                if(FieldMappingRec.SVMXC__Configuration_Type__c == 'HEADER_UPD_ON_RECEIPT')
                    ReceiptFieldUpdateRecsLst_Header.add(FieldMappingRec);
                else if(FieldMappingRec.SVMXC__Configuration_Type__c == 'LINE_UPD_ON_RECEIPT')
                    ReceiptFieldUpdateRecsLst_Line.add(FieldMappingRec);
                else if(FieldMappingRec.SVMXC__Configuration_Type__c == 'HEADER_UPD_ON_DELIVERY')
                    DeliveryFieldUpdateRecsLst_Header.add(FieldMappingRec);
                else if(FieldMappingRec.SVMXC__Configuration_Type__c == 'LINE_UPD_ON_DELIVERY')
                    DeliveryFieldUpdateRecsLst_Line.add(FieldMappingRec);
                else if(FieldMappingRec.Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && FieldMappingRec.SVMXC__Sequence__c == 1)
                    SelectedDocument1 = FieldMappingRec;
                else if(FieldMappingRec.Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && FieldMappingRec.SVMXC__Sequence__c == 2)
                    SelectedDocument2 = FieldMappingRec;
                else if(FieldMappingRec.Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && FieldMappingRec.SVMXC__Sequence__c == 3)
                    SelectedDocument3 = FieldMappingRec;
                else if(FieldMappingRec.Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && FieldMappingRec.SVMXC__Sequence__c == 1)
                    SelectedDocumentLine1 = FieldMappingRec;
                else if(FieldMappingRec.Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && FieldMappingRec.SVMXC__Sequence__c == 2)
                    SelectedDocumentLine2 = FieldMappingRec;
            }
            
            //Related entitlement Event records, after receipt, before receipt, closure records are cloned here
            List<SVMXC__SFM_Event__c> lstSFM_EventRec = new List<SVMXC__SFM_Event__c>();
            List<SVMXC__SFM_Event__c> clone_lstSFM_EventRec = new List<SVMXC__SFM_Event__c>();
            
            clone_lstSFM_EventRec = [Select SVMXC__Sequence__c, SVMXC__Event_Type__c, SVMXC__Description__c, SVMXC__Event_Call_Type__c, SVMXC__Namespace__c, SVMXC__ServiceMax_Custom_Action__c, SVMXC__Class__c, SVMXC__Method__c, SVMXC__ServiceMax_Process__c from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c = :HeaderId AND (SVMXC__Event_Type__c = 'Before Entitlement' OR SVMXC__Event_Type__c = 'After Receipt' OR SVMXC__Event_Type__c = 'After Delivery' OR SVMXC__Event_Type__c = 'After Closure')]; //  OR SVMXC__Event_Type__c = 'SFM Custom Action'
            
            lstSFM_EventRec = clone_lstSFM_EventRec.deepclone(false,false,false);
            
            for(SVMXC__SFM_Event__c EventRec :lstSFM_EventRec)
            {
                if(EventRec.SVMXC__Event_Type__c == 'Before Entitlement')
                    event_EntitlementAttributes = EventRec;
                else if(EventRec.SVMXC__Event_Type__c == 'After Receipt')
                    EventAfterReceiptObj = EventRec;
                else if(EventRec.SVMXC__Event_Type__c == 'After Delivery')
                    EventAfterDeliveryObj = EventRec;
                else if(EventRec.SVMXC__Event_Type__c == 'After Closure')
                     EventAfterClosureObj = EventRec;
            }
            
            rendersubsequentblock();
            /* if(ReceivingProcessObj.SVMXC__APL_Create_Work_Order_On__c == 'NOT_APPLICABLE')
                rendertab8ObjectMappingData = false;
            else
                rendertab8ObjectMappingData = true;
                
            if(ReceivingProcessObj.SVMXC__APL_Group_Work_Order_By__c == 'ONE_PRODUCT')
                rendertab8SpclObjectMappingData = true;
            else 
                rendertab8SpclObjectMappingData = false; */
        }
    }
    
    public void preparingPickLists()
    {
        String APIName_Header = ObjName_util.getOriginalAPIName('SVMXC__RMA_Shipment_Order__c', allObjs);
        String APIName_Line = ObjName_util.getOriginalAPIName('SVMXC__RMA_Shipment_Line__c', allObjs);
        
        mapPartsOrderFields = allObjs.get(APIName_Header).getDescribe().fields.getMap();
        mapPartsOrderLineFields = allObjs.get(APIName_Line).getDescribe().fields.getMap();
        for(String FieldApiName :mapPartsOrderFields.keyset())
            mapApiName_RealName_ShipmentHdr.put(mapPartsOrderFields.get(FieldApiName).getDescribe().getName(),FieldApiName);
        
        for(String FieldApiName :mapPartsOrderLineFields.keyset())
            mapApiName_RealName_ShipmentLine.put(mapPartsOrderLineFields.get(FieldApiName).getDescribe().getName(),FieldApiName);
        
        COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
        lstProductFields = new List<SelectOption>();
        List<SelectOption> TemplstSelectOptions = new List<SelectOption>();
        DispMethods.RetriveField('Product2', TemplstSelectOptions, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        lstProductFields.add(new SelectOption('ServiceMax_NONE',getTag056()));
        lstProductFields.addAll(TemplstSelectOptions);
        
        List<SelectOption> TemplstSelectOptions_Doc = new List<SelectOption>();
        lstDocumentFields = new List<SelectOption>();
        HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
        DispMethods = new WORD_SetupDispatch_Methods();
        
        //doc fields
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Order__c', TemplstSelectOptions_Doc, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        lstDocumentFields.add(new SelectOption('ServiceMax_NONE',getTag056()));
        lstDocumentFields.addAll(TemplstSelectOptions_Doc);
        
        //doc line fields
        /*DispMethods = new WORD_SetupDispatch_Methods();
        List<SelectOption> TemplstSelectOptions_DocLine = new List<SelectOption>();
        lstDocumentLineFields = new List<SelectOption>();
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Line__c', TemplstSelectOptions_DocLine, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        lstDocumentLineFields.add(new SelectOption('ServiceMax_NONE',getTag056()));
        lstDocumentLineFields.addAll(TemplstSelectOptions_DocLine);*/
        
        HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
        DispMethods = new WORD_SetupDispatch_Methods();
        lstPOHeaderExpr = new List<SelectOption>();
        lstPOLineExpr = new List<SelectOption>();
        lstPOHeaderExpr.add(new SelectOption('ServiceMax_NONE',getTag056()));
        HeaderObjFieldNames = new List<SelectOption>();
        List<SelectOption> tempHdrObjectFlds = new List<SelectOption>();
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Order__c', tempHdrObjectFlds, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        HeaderObjFieldNames.add(new SelectOption('ServiceMax_NONE',getTag056()));
        HeaderObjFieldNames.addAll(tempHdrObjectFlds);
        
        //Line fields population
        detailObjFieldNames = new List<SelectOption>();
        List<SelectOption> tempChildObjectFlds = new List<SelectOption>();
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Line__c', tempChildObjectFlds, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        detailObjFieldNames.add(new SelectOption('ServiceMax_NONE',getTag056()));
        detailObjFieldNames.addAll(tempChildObjectFlds);
        //Tab 2 Section 1 Header Expression data
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap stringMapRec = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Order__c');
        lstStringMap.add(stringMapRec);

        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request('','','',lstStringMap);
        SFM_GetNamedExpressionList getExpCls = new SFM_GetNamedExpressionList();
        SFM_WrapperDef.SFM_Response_Expression ResEXP;
        ResEXP = getExpCls.SFM_getNamedExpressionList(request);
        
        lstPOHeaderExpr = new List<SelectOption>();
        lstPOHeaderExpr.add(new SelectOption('ServiceMax_NONE', getTag056()));

        if(ResEXP != null && ResEXP.expressions != null)
        {
            for(SFM_WrapperDef.SFM_Expression Sfm_Exp :ResEXP.expressions) //SFM_Response_Expression
            {
                //populate the header expression picklist
                lstPOHeaderExpr.add(new SelectOption(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression.SVMXC__Name__c ));
                mapHeaderExpressionRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression);
                mapHeaderExpression_DetailsRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.expressionDetails);
            }
        }

        stringMapRec = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Line__c');
        lstStringMap.clear();
        lstStringMap.add(stringMapRec);
        
        //Create the request
        request = new SFM_WrapperDef.SFM_Request('','','',lstStringMap);
        
        //Result
        ResEXP = getExpCls.SFM_getNamedExpressionList(request);
        
        lstPOLineExpr = new List<SelectOption>();
        lstPOLineExpr.add(new SelectOption('ServiceMax_NONE', getTag056()));
        
        if(ResEXP != null && ResEXP.expressions != null)
        {
            for(SFM_WrapperDef.SFM_Expression Sfm_Exp :ResEXP.expressions) //SFM_Response_Expression
            {
                //populate the header expression picklist
                lstPOLineExpr.add(new SelectOption(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression.SVMXC__Name__c ));
                mapLineExpressionRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression);
                mapLineExpression_DetailsRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.expressionDetails);
            }
        }
        
        //Header Object Map records
        objectMappingPO_WO = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPO_WO = [Select id, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c' order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        slctLst_objectMappingPO_WO = new List<Selectoption>();
        for(SVMXC__ServiceMax_Processes__c ObjMapRec :objectMappingPO_WO)
            slctLst_objectMappingPO_WO.add(new selectOption(ObjMapRec.Id, ObjMapRec.SVMXC__Name__c));

        //Detail Object Map records
        objectMappingPOL_WOL = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPOL_WOL = [Select id, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c' order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        List<SVMXC__ServiceMax_Processes__c> objectMappingPOL_WO = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPOL_WO = [Select id, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c' order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        slctLst_objectMappingPOL_WOL = new List<Selectoption>();
        for(SVMXC__ServiceMax_Processes__c ObjMapRec :objectMappingPOL_WOL)
            slctLst_objectMappingPOL_WOL.add(new selectOption(ObjMapRec.Id, ObjMapRec.SVMXC__Name__c));
        
        slctLst_objectMappingPOL_WO = new List<Selectoption>();
        for(SVMXC__ServiceMax_Processes__c ObjMapRec :objectMappingPOL_WO)
            slctLst_objectMappingPOL_WO.add(new selectOption(ObjMapRec.Id, ObjMapRec.SVMXC__Name__c));
    }
    
    public void onCheckIBResolve()
    {
        if(ReceivingProcessObj.SVMXC__Resolve_Unexpected_SN_To_IB__c == false)
            DisableEntitleNWS = true;
        else
            DisableEntitleNWS = false;
    }
    
    public pagereference tab2hdrexprenderlinkblk()
    {
        ReceiptHeader_ExpressionsLst = null;
        rendertab2hdrexpblk = false;
        //Receipt_HeaderRecExprObj = null;
        if(SelectedHeaderExpressionId == 'ServiceMax_NONE')
            tab2hdrexprlinkblk_Render = false;
        else
            tab2hdrexprlinkblk_Render = true;
        return null;
    }
    
    public pagereference tab2lineexprenderlinkblk()
    {
        ReceiptLine_ExpressionsLst = null;
        rendertab2lineexpblk = false;
        //Receipt_DetailRecExprObj = null;
        
        if(SelectedLineExpressionId == 'ServiceMax_NONE')
            tab2lineexprlinkblk_Render = false;
        else
            tab2lineexprlinkblk_Render = true;
        return null;
    }
    
    public pagereference RetrieveTab2HeaderExpr()
    {
        if(SelectedHeaderExpressionId == null || SelectedHeaderExpressionId.startswith('ServiceMax_NONE')) 
        {
            rendertab2hdrexpblk = false;
            return null;
        }
        ReceiptHeader_ExpressionsDef = mapHeaderExpressionRecs.get(SelectedHeaderExpressionId);
        if(ReceiptHeader_ExpressionsDef.SVMXC__IsStandard__c)
            Tab2Hdr_New_Edit_ExpMode = false;
        else
            Tab2Hdr_New_Edit_ExpMode = true;
        ReceiptHeader_ExpressionsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        ReceiptHeader_ExpressionsLst = mapHeaderExpression_DetailsRecs.get(SelectedHeaderExpressionId);
        rendertab2hdrexpblk = true;
        return null;
    }
    
    //create new expression
    public pagereference CreateNewExpression_tab2Hdr()
    {
        SelectedHeaderExpressionId = 'ServiceMax_NONE';
        tab2hdrexprlinkblk_Render = false;
        ReceiptHeader_ExpressionsDef = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RType_DeliveryRule.Id, SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c', SVMXC__Rule_Type__c = 'Named Expression', SVMXC__IsStandard__c = false);
        ReceiptHeader_ExpressionsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        ReceiptQualifyCriteriaAddLines();
        rendertab2hdrexpblk = true;
        Tab2Hdr_New_Edit_ExpMode = true;
        return null;
    }
    
    public pagereference populateReceiptExprLine()
    {
        if(SelectedLineExpressionId == null || SelectedLineExpressionId.startswith('ServiceMax_NONE')) 
        {
            rendertab2lineexpblk = false;
            return null;
        }
        ReceiptLine_ExpressionsDef = mapLineExpressionRecs.get(SelectedLineExpressionId);
        if(ReceiptLine_ExpressionsDef != null && ReceiptLine_ExpressionsDef.SVMXC__IsStandard__c)
            Tab2Line_New_Edit_ExpMode = false;
        else
            Tab2Line_New_Edit_ExpMode = true;
        ReceiptLine_ExpressionsLst = mapLineExpression_DetailsRecs.get(SelectedLineExpressionId);
        rendertab2lineexpblk = true;
        return null;
    }
    
    public pagereference CreateNewExpression_tab2Line()
    {
        SelectedLineExpressionId = 'ServiceMax_NONE';
        tab2lineexprlinkblk_Render = false;
        ReceiptLine_ExpressionsDef = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RType_DeliveryRule.Id, SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c', SVMXC__Rule_Type__c = 'Named Expression', SVMXC__IsStandard__c = false);
        ReceiptLine_ExpressionsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        ReceiptQualifyCriteriaAddLines_Line();
        rendertab2lineexpblk = true;
        Tab2Line_New_Edit_ExpMode = true;
        return null;
    }
    
    public pagereference ReceiptQualifyCriteriaAddLines()
    {
        ReceiptHeader_ExpressionsLst.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RType_expressions.Id, SVMXC__Sequence__c = ReceiptHeader_ExpressionsLst.size() + 1 ));
        return null;
    }
    
    public pagereference ReceiptQualifyCriteriaDelLines()
    {
        List<SVMXC__ServiceMax_Config_Data__c> tempListHeaderexprUpdates_Receipt = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(Integer i=0; i< ReceiptHeader_ExpressionsLst.size();i++)
        {
            if(deliveryRuleSelIndex != ReceiptHeader_ExpressionsLst[i].SVMXC__Sequence__c)
                tempListHeaderexprUpdates_Receipt.add(ReceiptHeader_ExpressionsLst[i]);
        }
        ReceiptHeader_ExpressionsLst.clear();
        ReceiptHeader_ExpressionsLst.addAll(tempListHeaderexprUpdates_Receipt);
        for(Integer i=0; i< ReceiptHeader_ExpressionsLst.size();i++)
            ReceiptHeader_ExpressionsLst[i].SVMXC__Sequence__c = i+1;
        return null;
    }
    
    public pagereference ReceiptQualifyCriteriaAddLines_Line()
    {
        ReceiptLine_ExpressionsLst.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RType_expressions.Id, SVMXC__Sequence__c = ReceiptLine_ExpressionsLst.size() + 1 ));
        return null;
    }
    
    public pagereference ReceiptQualifyCriteriaDelLines_Line()
    {
        List<SVMXC__ServiceMax_Config_Data__c> tempListLineexprUpdates_Receipt = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(Integer i=0; i< ReceiptLine_ExpressionsLst.size();i++)
        {
            if(deliveryRuleSelIndex != ReceiptLine_ExpressionsLst[i].SVMXC__Sequence__c)
                tempListLineexprUpdates_Receipt.add(ReceiptLine_ExpressionsLst[i]);
        }
        ReceiptLine_ExpressionsLst.clear();
        ReceiptLine_ExpressionsLst.addAll(tempListLineexprUpdates_Receipt);
        for(Integer i=0; i< ReceiptLine_ExpressionsLst.size();i++)
            ReceiptLine_ExpressionsLst[i].SVMXC__Sequence__c = i+1;
        return null;
    }
    
    public pagereference ReceiptSourceUpdateAddLines_Header()
    {
        ReceiptFieldUpdateRecsLst_Header.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_Prod_Doc_Attributes[0].Id, SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_RECEIPT', SVMXC__Sequence__c = ReceiptFieldUpdateRecsLst_Header.size() + 1 ));
        return null;
    }
    
    List<SVMXC__ServiceMax_Config_Data__c> ListHdrObjectUpdatesToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    public pagereference ReceiptSourceUpdateDelLines_Header()
    {
        List<SVMXC__ServiceMax_Config_Data__c> tempListHdrObjectUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(Integer i=0; i< ReceiptFieldUpdateRecsLst_Header.size();i++)
        {
            if(deliveryRuleSelIndex != ReceiptFieldUpdateRecsLst_Header[i].SVMXC__Sequence__c)
                tempListHdrObjectUpdates.add(ReceiptFieldUpdateRecsLst_Header[i]);
            else if(deliveryRuleSelIndex == ReceiptFieldUpdateRecsLst_Header[i].SVMXC__Sequence__c && ReceiptFieldUpdateRecsLst_Header[i].Id != null)
                ListHdrObjectUpdatesToDelete.add(ReceiptFieldUpdateRecsLst_Header[i]);                
        }
        ReceiptFieldUpdateRecsLst_Header.clear();
        ReceiptFieldUpdateRecsLst_Header.addAll(tempListHdrObjectUpdates);
        for(Integer i=0; i< ReceiptFieldUpdateRecsLst_Header.size();i++)
            ReceiptFieldUpdateRecsLst_Header[i].SVMXC__Sequence__c = i+1;
        return null;
    }
    
    public pagereference ReceiptSourceUpdateAddLines_Line()
    {
        ReceiptFieldUpdateRecsLst_Line.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_Prod_Doc_Attributes[0].Id, SVMXC__Configuration_Type__c = 'LINE_UPD_ON_RECEIPT', SVMXC__Sequence__c = ReceiptFieldUpdateRecsLst_Line.size() + 1 ));
        return null;
    }
    
    List<SVMXC__ServiceMax_Config_Data__c> tempListLineObjectUpdatesToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    public pagereference ReceiptSourceUpdateDelLines_Line()
    {
        List<SVMXC__ServiceMax_Config_Data__c> tempListLineObjectUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(Integer i=0; i< ReceiptFieldUpdateRecsLst_Line.size();i++)
        {
            if(deliveryRuleSelIndex != ReceiptFieldUpdateRecsLst_Line[i].SVMXC__Sequence__c)
                tempListLineObjectUpdates.add(ReceiptFieldUpdateRecsLst_Line[i]);
            else if(deliveryRuleSelIndex == ReceiptFieldUpdateRecsLst_Line[i].SVMXC__Sequence__c && ReceiptFieldUpdateRecsLst_Line[i].Id != null)
                tempListLineObjectUpdatesToDelete.add(ReceiptFieldUpdateRecsLst_Line[i]);
        }
        ReceiptFieldUpdateRecsLst_Line.clear();
        ReceiptFieldUpdateRecsLst_Line.addAll(tempListLineObjectUpdates);
        for(Integer i=0; i< ReceiptFieldUpdateRecsLst_Line.size();i++)
            ReceiptFieldUpdateRecsLst_Line[i].SVMXC__Sequence__c = i+1;
        return null;
    }
    
    public pagereference RetrieveTab5HeaderExpr()
    {
        if(SlctdHdrExprId_Delivery == null || SlctdHdrExprId_Delivery.startswith('ServiceMax_NONE'))
        {
            rendertab5hdrexpblk = false;
            return null;
        }
        DeliveryHeader_ExpressionsDef = mapHeaderExpressionRecs.get(SlctdHdrExprId_Delivery);
        if(DeliveryHeader_ExpressionsDef.SVMXC__IsStandard__c)
            Tab5Hdr_New_Edit_ExpMode = false;
        else
            Tab5Hdr_New_Edit_ExpMode = true;
        DeliveryHeader_ExpressionsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        DeliveryHeader_ExpressionsLst = mapHeaderExpression_DetailsRecs.get(SlctdHdrExprId_Delivery);
        rendertab5hdrexpblk = true;
        return null;
    }

    public pagereference tab5hdrexprenderlinkblk()
    {
        rendertab5hdrexpblk = false;
        DeliveryHeader_ExpressionsLst = null;
        //Delivery_HeaderRecExprObj = null;
        if(SlctdHdrExprId_Delivery == 'ServiceMax_NONE')
            tab5hdrexprlinkblk_Render = false;
        else
            tab5hdrexprlinkblk_Render = true;
        return null;
    }

    public pagereference tab5lineexprenderlinkblk()
    {
        //Delivery_DetailRecExprObj = null;
        DeliveryLine_ExpressionsLst = null;
        rendertab5lineexpblk = false;
        if(SlctdLineExprId_Delivery == 'ServiceMax_NONE')
            tab5lineexprlinkblk_Render = false;
        else
            tab5lineexprlinkblk_Render = true;
        return null;
    }

    public pagereference populateDeliveryExprLine()
    {
        if(SlctdLineExprId_Delivery == null || SlctdLineExprId_Delivery.startswith('ServiceMax_NONE'))
        {
            rendertab5lineexpblk = false;
            return null;
        }
        DeliveryLine_ExpressionsDef = mapLineExpressionRecs.get(SlctdLineExprId_Delivery);
        if(DeliveryHeader_ExpressionsDef.SVMXC__IsStandard__c)
            Tab5Line_New_Edit_ExpMode = false;
        else
            Tab5Line_New_Edit_ExpMode = true;
        DeliveryLine_ExpressionsLst = mapLineExpression_DetailsRecs.get(SlctdLineExprId_Delivery);
        rendertab5lineexpblk = true;
        return null;
    }

    public pagereference DeliveryQualifyCriteriaAddLines()
    {
        DeliveryHeader_ExpressionsLst.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RType_expressions.Id, SVMXC__Sequence__c = DeliveryHeader_ExpressionsLst.size() + 1 ));
        return null;
    }
    
    public pagereference DeliveryQualifyCriteriaDelLines()
    {
        List<SVMXC__ServiceMax_Config_Data__c> tempListHeaderexprUpdates_Delivery = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(Integer i=0; i< DeliveryHeader_ExpressionsLst.size();i++)
        {
            if(deliveryRuleSelIndex != DeliveryHeader_ExpressionsLst[i].SVMXC__Sequence__c)
                tempListHeaderexprUpdates_Delivery.add(DeliveryHeader_ExpressionsLst[i]);
        }
        DeliveryHeader_ExpressionsLst.clear();
        DeliveryHeader_ExpressionsLst.addAll(tempListHeaderexprUpdates_Delivery);
        for(Integer i=0; i< DeliveryHeader_ExpressionsLst.size();i++)
            DeliveryHeader_ExpressionsLst[i].SVMXC__Sequence__c = i+1;
        return null;
    }
    
    public pagereference DeliveryQualifyCriteriaAddLines_Line()
    {
        DeliveryLine_ExpressionsLst.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RType_expressions.Id, SVMXC__Sequence__c = DeliveryLine_ExpressionsLst.size() + 1 ));
        return null;
    }
    
    public pagereference DeliveryQualifyCriteriaDelLines_Line()
    {
        List<SVMXC__ServiceMax_Config_Data__c> tempListLineexprUpdates_Delivery = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(Integer i=0; i< DeliveryLine_ExpressionsLst.size();i++)
        {
            if(deliveryRuleSelIndex != DeliveryLine_ExpressionsLst[i].SVMXC__Sequence__c)
                tempListLineexprUpdates_Delivery.add(DeliveryLine_ExpressionsLst[i]);
        }
        DeliveryLine_ExpressionsLst.clear();
        DeliveryLine_ExpressionsLst.addAll(tempListLineexprUpdates_Delivery);
        for(Integer i=0; i< DeliveryLine_ExpressionsLst.size();i++)
            DeliveryLine_ExpressionsLst[i].SVMXC__Sequence__c = i+1;
        return null;
    }
    
    public pagereference CreateNewExpression_tab5Hdr()
    {
        SlctdHdrExprId_Delivery = 'ServiceMax_NONE';
        tab5hdrexprlinkblk_Render = false;
        DeliveryHeader_ExpressionsDef = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RType_DeliveryRule.Id, SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c', SVMXC__Rule_Type__c = 'Named Expression', SVMXC__IsStandard__c = false);
        DeliveryHeader_ExpressionsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        DeliveryQualifyCriteriaAddLines();
        rendertab5hdrexpblk = true;
        Tab5Hdr_New_Edit_ExpMode = true;
        return null;
    }

    public pagereference CreateNewExpression_tab5Line()
    {
        SlctdLineExprId_Delivery = 'ServiceMax_NONE';
        tab5lineexprlinkblk_Render = false;
        DeliveryLine_ExpressionsDef = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RType_DeliveryRule.Id, SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c', SVMXC__Rule_Type__c = 'Named Expression', SVMXC__IsStandard__c = false);
        DeliveryLine_ExpressionsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        DeliveryQualifyCriteriaAddLines_Line();
        rendertab5lineexpblk = true;
        Tab5Line_New_Edit_ExpMode = true;
        return null;
    }

    //header
    public pagereference DeliverySourceUpdateAddLines_Header()
    {
        DeliveryFieldUpdateRecsLst_Header.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_Prod_Doc_Attributes[0].Id, SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_DELIVERY', SVMXC__Sequence__c = DeliveryFieldUpdateRecsLst_Header.size() + 1 ));
        return null;
    }
    List<SVMXC__ServiceMax_Config_Data__c> tempListHdr1ObjectUpdatesToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    public pagereference DeliverySourceUpdateDelLines_Header()
    {
        List<SVMXC__ServiceMax_Config_Data__c> tempListHdr1ObjectUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(Integer i=0; i< DeliveryFieldUpdateRecsLst_Header.size();i++)
        {
            if(deliveryRuleSelIndex != DeliveryFieldUpdateRecsLst_Header[i].SVMXC__Sequence__c)
                tempListHdr1ObjectUpdates.add(DeliveryFieldUpdateRecsLst_Header[i]);
            else if(deliveryRuleSelIndex == DeliveryFieldUpdateRecsLst_Header[i].SVMXC__Sequence__c && DeliveryFieldUpdateRecsLst_Header[i].Id != null)
                tempListHdr1ObjectUpdatesToDelete.add(DeliveryFieldUpdateRecsLst_Header[i]);
        }
        DeliveryFieldUpdateRecsLst_Header.clear();
        DeliveryFieldUpdateRecsLst_Header.addAll(tempListHdr1ObjectUpdates);
        for(Integer i=0; i< DeliveryFieldUpdateRecsLst_Header.size();i++)
            DeliveryFieldUpdateRecsLst_Header[i].SVMXC__Sequence__c = i+1;
        return null;
    }
    
    //line
    public pagereference DeliverySourceUpdateAddLines_Line()
    {
        DeliveryFieldUpdateRecsLst_Line.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_Prod_Doc_Attributes[0].Id, SVMXC__Configuration_Type__c = 'LINE_UPD_ON_DELIVERY', SVMXC__Sequence__c = DeliveryFieldUpdateRecsLst_Line.size() + 1 ));
        return null;
    }
    List<SVMXC__ServiceMax_Config_Data__c> tempListLine1ObjectUpdatesToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    public pagereference DeliverySourceUpdateDelLines_Line()
    {
        List<SVMXC__ServiceMax_Config_Data__c> tempListLine1ObjectUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(Integer i=0; i< DeliveryFieldUpdateRecsLst_Line.size();i++)
        {
            if(deliveryRuleSelIndex != DeliveryFieldUpdateRecsLst_Line[i].SVMXC__Sequence__c)
                tempListLine1ObjectUpdates.add(DeliveryFieldUpdateRecsLst_Line[i]);
            else if(deliveryRuleSelIndex == DeliveryFieldUpdateRecsLst_Line[i].SVMXC__Sequence__c && DeliveryFieldUpdateRecsLst_Line[i].Id != null)
                tempListLine1ObjectUpdatesToDelete.add(DeliveryFieldUpdateRecsLst_Line[i]);
        }
        DeliveryFieldUpdateRecsLst_Line.clear();
        DeliveryFieldUpdateRecsLst_Line.addAll(tempListLine1ObjectUpdates);
        for(Integer i=0; i< DeliveryFieldUpdateRecsLst_Line.size();i++)
            DeliveryFieldUpdateRecsLst_Line[i].SVMXC__Sequence__c = i+1;
        return null;
    }

    public pagereference rendersubsequentblock()
    {
        if(ReceivingProcessObj.SVMXC__APL_Create_Work_Order_On__c != 'NOT_APPLICABLE')
        {
            rendertab8ObjectMappingData = true;
            rendersubsequentblock1();
        }
        else
        {
            rendertab8ObjectMappingData = false;
            rendertab8SpclObjectMappingData = false;
        }
        return null;
    }
    
    public pagereference rendersubsequentblock1()
    {
        if(ReceivingProcessObj.SVMXC__APL_Group_Work_Order_By__c == 'ONE_PRODUCT')
        {
            rendertab8SpclObjectMappingData = true;
        }
        else 
            rendertab8SpclObjectMappingData = false;
        return null;
    }
    
    //---------------------------------------------- Tab navigation Methods ----------------------------------------------------------------
    public String selectedTab = 'tab1';
    public String getselectedTab()
    {
        return selectedTab; 
    }
    public void setselectedTab(String seltab)
    {
        this.selectedTab = seltab;
    }
    public void NavigateToTab1(){ selectedTab = 'tab1'; } 
    public void NavigateToTab2(){ selectedTab = 'tab2'; }
    public void NavigateToTab3(){ selectedTab = 'tab3'; }
    public void NavigateToTab4(){ selectedTab = 'tab4'; }
    public void NavigateToTab5(){ selectedTab = 'tab5'; }
    public void NavigateToTab6(){ selectedTab = 'tab6'; }
    //public void NavigateToTab7(){ selectedTab = 'tab7'; }
    public void NavigateToTab8(){ selectedTab = 'tab8'; }
    
    public boolean CheckSameFieldExistance(List<SVMXC__ServiceMax_Config_Data__c> lstConfData)
    {
        Set<String> setOfFields = new Set<String>();
        boolean valid = true;
        for(SVMXC__ServiceMax_Config_Data__c configDataRec : lstConfData)
        {
            if(configDataRec.SVMXC__Target_Field_Name__c == 'ServiceMax_NONE' || configDataRec.SVMXC__Target_Field_Name__c == null) 
              continue;
            Boolean isFieldPresent = setOfFields.contains(configDataRec.SVMXC__Target_Field_Name__c);
            if(!isFieldPresent)
                setOfFields.add(configDataRec.SVMXC__Target_Field_Name__c);
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTag105(), ''));
                valid = false;
            }
        }
        return valid;
    }
    
    public pagereference SaveReceivingProcess()
    {
        Savepoint sp = Database.setSavepoint();
        QuickSaveComplete = false;
        try
        {
            //Validation
            if(ReceivingProcessObj.SVMXC__Name__c == null || ReceivingProcessObj.SVMXC__Name__c == '')
            {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTag100()));
                return null;
            }
            else if(ReceivingProcessObj.SVMXC__ProcessID__c == null || ReceivingProcessObj.SVMXC__ProcessID__c == '' || !(String.valueOf(ReceivingProcessObj.SVMXC__ProcessID__c).length() >= 8))
            {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTag101()));
                return null;
            }
            else if(ReceivingProcessObj.SVMXC__APL_Create_Work_Order_On__c != null && ReceivingProcessObj.SVMXC__APL_Create_Work_Order_On__c != 'NOT_APPLICABLE' && ReceivingProcessObj.SVMXC__APL_Group_Work_Order_By__c == null)
            {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTag122()));
                return null;
            }
            else if((ReceivingProcessObj.SVMXC__Parent_Error_Msg__c == null || ReceivingProcessObj.SVMXC__Parent_Error_Msg__c == '') && ((SelectedHeaderExpressionId != null && SelectedHeaderExpressionId != '' && SelectedHeaderExpressionId != 'ServiceMax_NONE') || ((SelectedHeaderExpressionId == null || SelectedHeaderExpressionId == 'ServiceMax_NONE') && rendertab2hdrexpblk)))
            {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTag117() + ' ' + getTag147()));
                return null;
            }
            else if((ReceivingProcessObj.SVMXC__Child_Error_Msg__c == null || ReceivingProcessObj.SVMXC__Child_Error_Msg__c == '') && (((SelectedLineExpressionId != null && SelectedLineExpressionId != '') && SelectedLineExpressionId != 'ServiceMax_NONE') || ((SelectedLineExpressionId == null || SelectedLineExpressionId == 'ServiceMax_NONE') && rendertab2lineexpblk)))
            {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTag118() + ' ' + getTag147()));
                return null;
            }
            else if((ReceivingProcessObj.SVMXC__Parent_Error_Msg2__c == null || ReceivingProcessObj.SVMXC__Parent_Error_Msg2__c == '') && (((SlctdHdrExprId_Delivery != null && SlctdHdrExprId_Delivery != '') && SlctdHdrExprId_Delivery != 'ServiceMax_NONE') || ((SlctdHdrExprId_Delivery == null || SlctdHdrExprId_Delivery == 'ServiceMax_NONE') && rendertab5hdrexpblk)))
            {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTag119() + ' ' + getTag147()));
                return null;
            }
            else if((ReceivingProcessObj.SVMXC__Child_Error_Msg2__c == null || ReceivingProcessObj.SVMXC__Child_Error_Msg2__c == '') && (((SlctdLineExprId_Delivery != null && SlctdLineExprId_Delivery != '') && SlctdLineExprId_Delivery != 'ServiceMax_NONE') || ((SlctdLineExprId_Delivery == null || SlctdLineExprId_Delivery == 'ServiceMax_NONE') && rendertab5lineexpblk)))
            {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTag120() + ' ' + getTag147()));
                return null;
            }
            else
            {
                //process id uniqueness check
                List<SVMXC__ServiceMax_Processes__c> lstProcessRecs_UniquenessCheck = new List<SVMXC__ServiceMax_Processes__c>();
                String tempProcessId = ReceivingProcessObj.SVMXC__ProcessID__c;  
                lstProcessRecs_UniquenessCheck = [Select Id from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = :tempProcessId AND RecordType.Name = 'Receiving Process']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstProcessRecs_UniquenessCheck != null && lstProcessRecs_UniquenessCheck.size() > 0)
                {
                    if((ReceivingProcessObj.get('Id') == null) || (lstProcessRecs_UniquenessCheck[0].Id  != ReceivingProcessObj.get('Id')))
                    {
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTag104()));
                        return null;
                    }
                }
            }
            APL_Utils aplutls = new APL_Utils();

            SVMXC.SFM_saveExpression SaveExpressionObj = new SVMXC.SFM_saveExpression();
            SFM_WrapperDef.SFM_Response saveResponse;
            Boolean isRollBack = false;
            List<SFM_WrapperDef.SFM_Expression> lstSFMExpression = new List<SFM_WrapperDef.SFM_Expression>();
        
            ReceiptHeader_ExpressionsDef.SVMXC__SettingId__c = ReceiptHeader_ExpressionsDef.SVMXC__ProcessID__c;
            ReceiptHeader_ExpressionsDef.SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c';
        
            ReceiptLine_ExpressionsDef.SVMXC__SettingId__c = ReceiptLine_ExpressionsDef.SVMXC__ProcessID__c;
            ReceiptLine_ExpressionsDef.SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c';
        
            DeliveryHeader_ExpressionsDef.SVMXC__SettingId__c = DeliveryHeader_ExpressionsDef.SVMXC__ProcessID__c;
            DeliveryHeader_ExpressionsDef.SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c';
        
            DeliveryLine_ExpressionsDef.SVMXC__SettingId__c = DeliveryLine_ExpressionsDef.SVMXC__ProcessID__c;
            DeliveryLine_ExpressionsDef.SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c';

            //Exp1
            String TempExpr1Id;
            if(rendertab2hdrexpblk && Tab2Hdr_New_Edit_ExpMode && ReceiptHeader_ExpressionsDef.SVMXC__IsStandard__c == false )
            {
                if(ReceiptHeader_ExpressionsDef.SVMXC__Name__c == null || ReceiptHeader_ExpressionsDef.SVMXC__Name__c == '')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag117()+' ' + getTag115(),''));
                    return null;
                }
                if(ReceiptHeader_ExpressionsDef.SVMXC__ProcessID__c == null || ReceiptHeader_ExpressionsDef.SVMXC__ProcessID__c == '' || (ReceiptHeader_ExpressionsDef.SVMXC__ProcessID__c != null && (ReceiptHeader_ExpressionsDef.SVMXC__ProcessID__c).length() < 8))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag117()+' '+ getTag116(),''));
                    return null;
                }
                if(ReceiptHeader_ExpressionsLst == null || (ReceiptHeader_ExpressionsLst != null && !(ReceiptHeader_ExpressionsLst.size() > 0)))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag117()+' '+ getTag121(),''));
                    return null;
                }
                for(SVMXC__ServiceMax_Config_Data__c exprRec: ReceiptHeader_ExpressionsLst)
                    exprRec.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
                aplutls.PopulateInfoForReferenceFields(ReceiptHeader_ExpressionsLst);
                lstSFMExpression.add(new SFM_WrapperDef.SFM_Expression(ReceiptHeader_ExpressionsDef, ReceiptHeader_ExpressionsLst));
                SFM_WrapperDef.SFM_Request_Expression expressionRequest = new SFM_WrapperDef.SFM_Request_Expression(lstSFMExpression);
                saveResponse = new SFM_WrapperDef.SFM_Response();
                saveResponse = SaveExpressionObj.SFM_saveExpression(expressionRequest);
                if(saveResponse == null || saveResponse.success == false) 
                {
                    if(saveResponse != null && saveResponse.message !=null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTag117()+' '+ saveResponse.message, ''));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTag117(), ''));
                    return null;
                }
                else
                {
                    SelectedHeaderExpressionId = saveResponse.resultIds[0];
                }
            }
            
            //Exp2
            String Tempexpr2Id;
            lstSFMExpression.clear();
            if(rendertab2lineexpblk && Tab2Line_New_Edit_ExpMode && ReceiptLine_ExpressionsDef.SVMXC__IsStandard__c == false)
            {
                if(ReceiptLine_ExpressionsDef.SVMXC__Name__c == null || ReceiptLine_ExpressionsDef.SVMXC__Name__c == '')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag118()+' ' + getTag115(),''));
                    return null;
                }
                if(ReceiptLine_ExpressionsDef.SVMXC__ProcessID__c == null || ReceiptLine_ExpressionsDef.SVMXC__ProcessID__c == '' || (ReceiptLine_ExpressionsDef.SVMXC__ProcessID__c != null && (ReceiptLine_ExpressionsDef.SVMXC__ProcessID__c).length() < 8))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag118()+' ' + getTag116(),''));
                    return null;
                }
                if(ReceiptLine_ExpressionsLst == null || (ReceiptLine_ExpressionsLst != null && !(ReceiptLine_ExpressionsLst.size() > 0)))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag118()+' ' + getTag121(),''));
                    return null;
                }
                for(SVMXC__ServiceMax_Config_Data__c exprRec: ReceiptLine_ExpressionsLst)
                  exprRec.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Line__c';
                aplutls.PopulateInfoForReferenceFields(ReceiptLine_ExpressionsLst);
                lstSFMExpression.add(new SFM_WrapperDef.SFM_Expression(ReceiptLine_ExpressionsDef, ReceiptLine_ExpressionsLst));
                SFM_WrapperDef.SFM_Request_Expression expressionRequest = new SFM_WrapperDef.SFM_Request_Expression(lstSFMExpression);
                saveResponse = new SFM_WrapperDef.SFM_Response();
                saveResponse = SaveExpressionObj.SFM_saveExpression(expressionRequest);
                if(saveResponse == null || saveResponse.success == false) 
                {
                    if(saveResponse != null && saveResponse.message !=null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTag118()+' ' + saveResponse.message, ''));
                    else
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error Occured: Receipt Line Expression', ''));
                    return null;
                }
                else
                {
                    SelectedLineExpressionId = saveResponse.resultIds[0];
                }
            }
            
            //Exp3
            String Tempexpr3Id;
            lstSFMExpression.clear();
            if(rendertab5hdrexpblk && Tab5Hdr_New_Edit_ExpMode && DeliveryHeader_ExpressionsDef.SVMXC__IsStandard__c == false)
            {
                if(DeliveryHeader_ExpressionsDef.SVMXC__Name__c == null || DeliveryHeader_ExpressionsDef.SVMXC__Name__c == '')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag119()+' ' + getTag115(),''));
                    return null;
                }
                if(DeliveryHeader_ExpressionsDef.SVMXC__ProcessID__c == null || DeliveryHeader_ExpressionsDef.SVMXC__ProcessID__c == '' || (DeliveryHeader_ExpressionsDef.SVMXC__ProcessID__c != null && (DeliveryHeader_ExpressionsDef.SVMXC__ProcessID__c).length() < 8) )
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag119()+' ' + getTag116(),''));
                    return null;
                }
                if(DeliveryHeader_ExpressionsLst == null || (DeliveryHeader_ExpressionsLst != null && !(DeliveryHeader_ExpressionsLst.size() > 0)))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag119()+' ' + getTag121(),''));
                    return null;
                }
                for(SVMXC__ServiceMax_Config_Data__c exprRec: DeliveryHeader_ExpressionsLst)
                  exprRec.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
                aplutls.PopulateInfoForReferenceFields(DeliveryHeader_ExpressionsLst);
                lstSFMExpression.add(new SFM_WrapperDef.SFM_Expression(DeliveryHeader_ExpressionsDef, DeliveryHeader_ExpressionsLst));
                SFM_WrapperDef.SFM_Request_Expression expressionRequest = new SFM_WrapperDef.SFM_Request_Expression(lstSFMExpression);
                saveResponse = new SFM_WrapperDef.SFM_Response();
                saveResponse = SaveExpressionObj.SFM_saveExpression(expressionRequest);
                if(saveResponse == null || saveResponse.success == false) 
                {
                    if(saveResponse != null && saveResponse.message !=null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTag119()+' ' + saveResponse.message, ''));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error Occured: Delivery Header Expression', ''));
                    return null;
                }
                else
                {
                    SlctdHdrExprId_Delivery = saveResponse.resultIds[0];
                }
            }
            
            //Exp4
            String Tempexpr4Id;
            lstSFMExpression.clear();
            if(rendertab5lineexpblk && Tab5Line_New_Edit_ExpMode && DeliveryLine_ExpressionsDef.SVMXC__IsStandard__c == false)
            {
                if(DeliveryLine_ExpressionsDef.SVMXC__Name__c == null || DeliveryLine_ExpressionsDef.SVMXC__Name__c == '')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag120()+' ' + getTag115(),''));
                    return null;
                }
                if(DeliveryLine_ExpressionsDef.SVMXC__ProcessID__c == null || DeliveryLine_ExpressionsDef.SVMXC__ProcessID__c == '' || (DeliveryLine_ExpressionsDef.SVMXC__ProcessID__c != null && (DeliveryLine_ExpressionsDef.SVMXC__ProcessID__c).length() < 8))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag120()+' ' + getTag116(),''));
                    return null;
                }
                if(DeliveryLine_ExpressionsLst == null || (DeliveryLine_ExpressionsLst != null && !(DeliveryLine_ExpressionsLst.size() > 0)))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag120()+' ' + getTag121(),''));
                    return null;
                }
                for(SVMXC__ServiceMax_Config_Data__c exprRec: DeliveryLine_ExpressionsLst)
                  exprRec.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Line__c';
                aplutls.PopulateInfoForReferenceFields(DeliveryLine_ExpressionsLst);
                lstSFMExpression.add(new SFM_WrapperDef.SFM_Expression(DeliveryLine_ExpressionsDef, DeliveryLine_ExpressionsLst));
                SFM_WrapperDef.SFM_Request_Expression expressionRequest = new SFM_WrapperDef.SFM_Request_Expression(lstSFMExpression);
                saveResponse = new SFM_WrapperDef.SFM_Response();
                saveResponse = SaveExpressionObj.SFM_saveExpression(expressionRequest);
                if(saveResponse == null || saveResponse.success == false) 
                {
                    if(saveResponse != null && saveResponse.message !=null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTag120()+' ' + saveResponse.message, ''));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error Occured: exp1', ''));
                    return null;
                }
                else
                {
                    SlctdLineExprId_Delivery = saveResponse.resultIds[0];
                }
            }
            
            //Recreate Expressions - Header picklist
            List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
            SFM_WrapperDef.SFM_StringMap stringMapRec = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Order__c');
            lstStringMap.add(stringMapRec);

            //Create the request
            SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request('','','',lstStringMap);

            //Result
            SFM_GetNamedExpressionList getExpCls = new SFM_GetNamedExpressionList();
            SFM_WrapperDef.SFM_Response_Expression ResEXP;
            ResEXP = getExpCls.SFM_getNamedExpressionList(request);

            lstPOHeaderExpr = new List<SelectOption>();
            lstPOHeaderExpr.add(new SelectOption('ServiceMax_NONE', getTag056()));
            mapHeaderExpressionRecs.clear();
            mapHeaderExpression_DetailsRecs.clear();
            if(ResEXP != null && ResEXP.expressions != null)
            {
                for(SFM_WrapperDef.SFM_Expression Sfm_Exp :ResEXP.expressions) //SFM_Response_Expression
                {
                    //populate the header expression picklist
                    lstPOHeaderExpr.add(new SelectOption(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression.SVMXC__Name__c ));
                    mapHeaderExpressionRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression);
                    mapHeaderExpression_DetailsRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.expressionDetails);
                }
            }
            //Recreate Expressions - Line picklist
            stringMapRec = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Line__c');
            lstStringMap.clear();
            lstStringMap.add(stringMapRec);
            
            //Create the request
            request = new SFM_WrapperDef.SFM_Request('','','',lstStringMap);
            
            //Result
            ResEXP = getExpCls.SFM_getNamedExpressionList(request);
            
            lstPOLineExpr = new List<SelectOption>();
            lstPOLineExpr.add(new SelectOption('ServiceMax_NONE', getTag056()));
            mapLineExpressionRecs.clear();
            mapLineExpression_DetailsRecs.clear();
            if(ResEXP != null && ResEXP.expressions != null)
            {
                for(SFM_WrapperDef.SFM_Expression Sfm_Exp :ResEXP.expressions) //SFM_Response_Expression
                {
                    //populate the header expression picklist
                    lstPOLineExpr.add(new SelectOption(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression.SVMXC__Name__c ));
                
                    mapLineExpressionRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression);
                    mapLineExpression_DetailsRecs.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.expressionDetails);
                }
            }
            
            //Save the Expression Ids
            if(SelectedHeaderExpressionId != null && !(SelectedHeaderExpressionId.startswith('ServiceMax_NONE')))
                ReceivingProcessObj.SVMXC__Node_Parent__c  = SelectedHeaderExpressionId;
            else
                ReceivingProcessObj.SVMXC__Node_Parent__c  = null;
            
            if(SelectedLineExpressionId != null && !(SelectedLineExpressionId.startswith('ServiceMax_NONE')))
                ReceivingProcessObj.SVMXC__Submodule__c  = SelectedLineExpressionId;
            else
                ReceivingProcessObj.SVMXC__Submodule__c  = null;
            
            if(SlctdHdrExprId_Delivery != null && !(SlctdHdrExprId_Delivery.startswith('ServiceMax_NONE')))
                ReceivingProcessObj.SVMXC__Module__c = SlctdHdrExprId_Delivery;
            else
                ReceivingProcessObj.SVMXC__Module__c = null;
            
            if(SlctdLineExprId_Delivery != null && !(SlctdLineExprId_Delivery.startswith('ServiceMax_NONE')))
                ReceivingProcessObj.SVMXC__Final_Exception_Process__c = SlctdLineExprId_Delivery;
            else
                ReceivingProcessObj.SVMXC__Final_Exception_Process__c = null;

            //Expression Related - ends here
            //field updates
            if(!CheckSameFieldExistance(ReceiptFieldUpdateRecsLst_Header)) return null;
            if(!CheckSameFieldExistance(ReceiptFieldUpdateRecsLst_Line)) return null;
            if(!CheckSameFieldExistance(DeliveryFieldUpdateRecsLst_Header)) return null;
            if(!CheckSameFieldExistance(DeliveryFieldUpdateRecsLst_Line)) return null;
            
            
            //receipt header object Updates
            List<SVMXC__ServiceMax_Config_Data__c> TempList = new List<SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> TempListToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SVMXC__ServiceMax_Config_Data__c configdataRec :ReceiptFieldUpdateRecsLst_Header)
            {
                if((configdataRec.SVMXC__Target_Field_Name__c == 'ServiceMax_NONE' || configdataRec.SVMXC__Target_Field_Name__c == null) && configdataRec.get('Id') != null)
                    TempListToDelete.add(configdataRec);
                else if(configdataRec.SVMXC__Target_Field_Name__c != null && !(configdataRec.SVMXC__Target_Field_Name__c == 'ServiceMax_NONE'))
                    TempList.add(configdataRec);
            }
            ReceiptFieldUpdateRecsLst_Header = TempList;
            for(Integer i=0; i< ReceiptFieldUpdateRecsLst_Header.size();i++)
                ReceiptFieldUpdateRecsLst_Header[i].SVMXC__Sequence__c = i+1;
            
            //receipt line object Updates
            List<SVMXC__ServiceMax_Config_Data__c> TempList1 = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SVMXC__ServiceMax_Config_Data__c configdataRec1 :ReceiptFieldUpdateRecsLst_Line)
            {
                if((configdataRec1.SVMXC__Target_Field_Name__c == 'ServiceMax_NONE' || configdataRec1.SVMXC__Target_Field_Name__c == null) && configdataRec1.get('Id') != null)
                    TempListToDelete.add(configdataRec1);
                else if(configdataRec1.SVMXC__Target_Field_Name__c != null && !(configdataRec1.SVMXC__Target_Field_Name__c == 'ServiceMax_NONE'))
                    TempList1.add(configdataRec1);
            }
        
            ReceiptFieldUpdateRecsLst_Line = TempList1;
            
            for(Integer i=0; i< ReceiptFieldUpdateRecsLst_Line.size();i++)
                ReceiptFieldUpdateRecsLst_Line[i].SVMXC__Sequence__c = i+1;

            //delivery header object Updates
            List<SVMXC__ServiceMax_Config_Data__c> TempList2 = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SVMXC__ServiceMax_Config_Data__c configdataRec2 :DeliveryFieldUpdateRecsLst_Header)
            {
                if((configdataRec2.SVMXC__Target_Field_Name__c == 'ServiceMax_NONE' || configdataRec2.SVMXC__Target_Field_Name__c == null) && configdataRec2.get('Id') != null)
                    TempListToDelete.add(configdataRec2);
                else if(configdataRec2.SVMXC__Target_Field_Name__c != null && !(configdataRec2.SVMXC__Target_Field_Name__c == 'ServiceMax_NONE'))
                    TempList2.add(configdataRec2);
            }
            DeliveryFieldUpdateRecsLst_Header = TempList2;

            for(Integer i=0; i< DeliveryFieldUpdateRecsLst_Header.size();i++)
                DeliveryFieldUpdateRecsLst_Header[i].SVMXC__Sequence__c = i+1;

            //delivery line object Updates
            List<SVMXC__ServiceMax_Config_Data__c> TempList3 = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SVMXC__ServiceMax_Config_Data__c configdataRec3 :DeliveryFieldUpdateRecsLst_Line)
            {
                if((configdataRec3.SVMXC__Target_Field_Name__c == 'ServiceMax_NONE' || configdataRec3.SVMXC__Target_Field_Name__c == null) && configdataRec3.get('Id') != null)
                    TempListToDelete.add(configdataRec3);
                else if(configdataRec3.SVMXC__Target_Field_Name__c != null && !(configdataRec3.SVMXC__Target_Field_Name__c == 'ServiceMax_NONE'))
                    TempList3.add(configdataRec3);
            }
            DeliveryFieldUpdateRecsLst_Line = TempList3;

            for(Integer i=0; i< DeliveryFieldUpdateRecsLst_Line.size();i++)
                DeliveryFieldUpdateRecsLst_Line[i].SVMXC__Sequence__c = i+1;

            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {                
                delete TempListToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                return null;
            }
            
            //Added By Neeraj
            if(ListHdrObjectUpdatesToDelete != null && ListHdrObjectUpdatesToDelete.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    
                    delete ListHdrObjectUpdatesToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                    ListHdrObjectUpdatesToDelete.clear();
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }   
            if(tempListLineObjectUpdatesToDelete != null && tempListLineObjectUpdatesToDelete.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    
                    delete tempListLineObjectUpdatesToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                    tempListLineObjectUpdatesToDelete.clear();
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }
            system.debug('Test00001:'+tempListHdr1ObjectUpdatesToDelete);
            if(tempListHdr1ObjectUpdatesToDelete != null && tempListHdr1ObjectUpdatesToDelete.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    
                    delete tempListHdr1ObjectUpdatesToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                    tempListHdr1ObjectUpdatesToDelete.clear();
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }
            system.debug('Test00001:'+tempListLine1ObjectUpdatesToDelete);
            if(tempListLine1ObjectUpdatesToDelete != null && tempListLine1ObjectUpdatesToDelete.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    
                    delete tempListLine1ObjectUpdatesToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                    tempListLine1ObjectUpdatesToDelete.clear();
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }   
            
            
            //Tab 8 Optional Block, set data and save
            if(!rendertab8ObjectMappingData)
            {
                ReceivingProcessObj.SVMXC__Parent_Object__c = null;
                ReceivingProcessObj.SVMXC__Process__c = null;
            }

            //upsert ReceivingProcessObj;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(ReceivingProcessObj, COMM_SecurityUtils.Access.Upsertable)){
                upsert ReceivingProcessObj; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        
            //Object Updates
            List<SVMXC__ServiceMax_Config_Data__c> lstObjectUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
            lstObjectUpdates.addAll(ReceiptFieldUpdateRecsLst_Header);
            lstObjectUpdates.addAll(ReceiptFieldUpdateRecsLst_Line);
            lstObjectUpdates.addAll(DeliveryFieldUpdateRecsLst_Header);
            lstObjectUpdates.addAll(DeliveryFieldUpdateRecsLst_Line);
        
            //Loop through ObjectMapping Records and set the receiving process Id;
            for(SVMXC__ServiceMax_Config_Data__c ObjectMappignRec: lstObjectUpdates)
                ObjectMappignRec.SVMXC__Dispatch_Process__c = ReceivingProcessObj.Id;
            List<SVMXC__ServiceMax_Config_Data__c> LstRelatedData = new List<SVMXC__ServiceMax_Config_Data__c>();
            LstRelatedData.addAll(lstObjectUpdates);
        
            //document attributes
            SelectedDocument1.SVMXC__Dispatch_Process__c = ReceivingProcessObj.Id;
            SelectedDocument2.SVMXC__Dispatch_Process__c = ReceivingProcessObj.Id;
            SelectedDocument3.SVMXC__Dispatch_Process__c = ReceivingProcessObj.Id;

            if(SelectedDocument1.SVMXC__Field_Name__c == 'ServiceMax_NONE' || SelectedDocument1.SVMXC__Field_Name__c == null)
                SelectedDocument1.SVMXC__Field_Name__c = null;
            else
            {
                Schema.SObjectField targetField = mapPartsOrderFields.get(mapApiName_RealName_ShipmentHdr.get(SelectedDocument1.SVMXC__Field_Name__c));
                if(targetField != null)
                {
                    Schema.DescribeFieldResult targetFieldDesc = targetField.getDescribe();
                    SelectedDocument1.SVMXC__Display_Type__c = String.valueOf(targetFieldDesc.getType());
                    if(SelectedDocument1.SVMXC__Display_Type__c == 'Reference')
                    {
                        SelectedDocument1.SVMXC__Field_Relationship_Name__c = targetFieldDesc.getRelationshipName();
                        SelectedDocument1.SVMXC__Object_Name__c = string.valueOf(targetFieldDesc.getReferenceTo()[0]);
                        if(targetFieldDesc.getReferenceTo()[0] == Account.SObjectType)
                            SelectedDocument1.SVMXC__FKey_Name_Field__c = 'Name';
                        else    
                        {   
                            Map<String,Schema.SObjectField> R = targetFieldDesc.getReferenceTo()[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                {
                                    SelectedDocument1.SVMXC__FKey_Name_Field__c = f1.getName();
                                    break;
                                }
                            }
                            }
                    }
                }
            }

            if(SelectedDocument2.SVMXC__Field_Name__c == 'ServiceMax_NONE' || SelectedDocument2.SVMXC__Field_Name__c == null)
                SelectedDocument2.SVMXC__Field_Name__c = null;
            else
            {
                Schema.SObjectField targetField = mapPartsOrderFields.get(mapApiName_RealName_ShipmentHdr.get(SelectedDocument2.SVMXC__Field_Name__c));
                if(targetField != null)
                {
                    Schema.DescribeFieldResult targetFieldDesc = targetField.getDescribe();
                    SelectedDocument2.SVMXC__Display_Type__c = String.valueOf(targetFieldDesc.getType());
                    if(SelectedDocument2.SVMXC__Display_Type__c == 'Reference')
                    {
                        SelectedDocument2.SVMXC__Field_Relationship_Name__c = targetFieldDesc.getRelationshipName();
                        SelectedDocument2.SVMXC__Object_Name__c = string.valueOf(targetFieldDesc.getReferenceTo()[0]);
                    if(targetFieldDesc.getReferenceTo()[0] == Account.SObjectType)
                            SelectedDocument2.SVMXC__FKey_Name_Field__c = 'Name';
                        else    
                        {
                            Map<String,Schema.SObjectField> R = targetFieldDesc.getReferenceTo()[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                {
                                    SelectedDocument2.SVMXC__FKey_Name_Field__c = f1.getName();
                                    break;
                                }
                            }
                        }
                    }
                }
            }

            if(SelectedDocument3.SVMXC__Field_Name__c == 'ServiceMax_NONE' || SelectedDocument3.SVMXC__Field_Name__c == null)
                SelectedDocument3.SVMXC__Field_Name__c = null;
            else
            {
                Schema.SObjectField targetField = mapPartsOrderFields.get(mapApiName_RealName_ShipmentHdr.get(SelectedDocument3.SVMXC__Field_Name__c));
                if(targetField != null)
                {
                    Schema.DescribeFieldResult targetFieldDesc = targetField.getDescribe();
                    SelectedDocument3.SVMXC__Display_Type__c = String.valueOf(targetFieldDesc.getType());
                    if(SelectedDocument3.SVMXC__Display_Type__c == 'Reference')
                    {
                        SelectedDocument3.SVMXC__Field_Relationship_Name__c = targetFieldDesc.getRelationshipName();
                        SelectedDocument3.SVMXC__Object_Name__c = string.valueOf(targetFieldDesc.getReferenceTo()[0]);
                        if(targetFieldDesc.getReferenceTo()[0] == Account.SObjectType)
                            SelectedDocument3.SVMXC__FKey_Name_Field__c = 'Name';
                        else    
                        {  
                            Map<String,Schema.SObjectField> R = targetFieldDesc.getReferenceTo()[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                {
                                    SelectedDocument3.SVMXC__FKey_Name_Field__c = f1.getName();
                                    break;
                                }
                            }
                        }
                    }
                }
            }

            //document Line attributes
            SelectedDocumentLine1.SVMXC__Dispatch_Process__c = ReceivingProcessObj.Id;
            SelectedDocumentLine2.SVMXC__Dispatch_Process__c = ReceivingProcessObj.Id;

            if(SelectedDocumentLine1.SVMXC__Field_Name__c == 'ServiceMax_NONE' || SelectedDocumentLine1.SVMXC__Field_Name__c == null)
                SelectedDocumentLine1.SVMXC__Field_Name__c = null;
            else
            {
                Schema.SObjectField targetField = mapPartsOrderLineFields.get(mapApiName_RealName_ShipmentLine.get(SelectedDocumentLine1.SVMXC__Field_Name__c));
                if(targetField != null)
                {
                    Schema.DescribeFieldResult targetFieldDesc = targetField.getDescribe();
                    SelectedDocumentLine1.SVMXC__Display_Type__c = String.valueOf(targetFieldDesc.getType());
                    if(SelectedDocumentLine1.SVMXC__Display_Type__c == 'Reference')
                    {
                        SelectedDocumentLine1.SVMXC__Field_Relationship_Name__c = targetFieldDesc.getRelationshipName();
                        SelectedDocumentLine1.SVMXC__Object_Name__c = string.valueOf(targetFieldDesc.getReferenceTo()[0]);
                    if(targetFieldDesc.getReferenceTo()[0] == Account.SObjectType)
                            SelectedDocumentLine1.SVMXC__FKey_Name_Field__c = 'Name';
                        else    
                        {  
                            Map<String,Schema.SObjectField> R = targetFieldDesc.getReferenceTo()[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                {
                                    SelectedDocumentLine1.SVMXC__FKey_Name_Field__c = f1.getName();
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            if(SelectedDocumentLine2.SVMXC__Field_Name__c == 'ServiceMax_NONE' || SelectedDocumentLine2.SVMXC__Field_Name__c == null)
                SelectedDocumentLine2.SVMXC__Field_Name__c = null;
            else
            {
                Schema.SObjectField targetField = mapPartsOrderLineFields.get(mapApiName_RealName_ShipmentLine.get(SelectedDocumentLine2.SVMXC__Field_Name__c));
                if(targetField != null)
                {
                    Schema.DescribeFieldResult targetFieldDesc = targetField.getDescribe();
                    SelectedDocumentLine2.SVMXC__Display_Type__c = String.valueOf(targetFieldDesc.getType());
                    if(SelectedDocumentLine2.SVMXC__Display_Type__c == 'Reference')
                    {
                        SelectedDocumentLine2.SVMXC__Field_Relationship_Name__c = targetFieldDesc.getRelationshipName();
                        SelectedDocumentLine2.SVMXC__Object_Name__c = string.valueOf(targetFieldDesc.getReferenceTo()[0]);
                        if(targetFieldDesc.getReferenceTo()[0] == Account.SObjectType)
                            SelectedDocumentLine2.SVMXC__FKey_Name_Field__c = 'Name';
                        else    
                        {   
                            Map<String,Schema.SObjectField> R = targetFieldDesc.getReferenceTo()[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                {
                                    SelectedDocumentLine2.SVMXC__FKey_Name_Field__c = f1.getName();
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            LstRelatedData.add(SelectedDocument1);
            LstRelatedData.add(SelectedDocument2);
            LstRelatedData.add(SelectedDocument3);

            LstRelatedData.add(SelectedDocumentLine1);
            LstRelatedData.add(SelectedDocumentLine2);

            upsert LstRelatedData; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__SFM_Event__c> LstRelatedEvents = new List<SVMXC__SFM_Event__c>();
            //event Attributes
            event_EntitlementAttributes.SVMXC__ServiceMax_Process__c = ReceivingProcessObj.Id;
            if((event_EntitlementAttributes.SVMXC__Namespace__c != null || event_EntitlementAttributes.SVMXC__Class__c != null || event_EntitlementAttributes.SVMXC__Method__c != null) && (event_EntitlementAttributes.SVMXC__Namespace__c != '' || event_EntitlementAttributes.SVMXC__Class__c != '' || event_EntitlementAttributes.SVMXC__Method__c != ''))
                LstRelatedEvents.add(event_EntitlementAttributes);
            else if(event_EntitlementAttributes.Id != null && event_EntitlementAttributes.SVMXC__ServiceMax_Process__c != null && event_EntitlementAttributes.SVMXC__Event_Type__c == 'Before Entitlement' && event_EntitlementAttributes.SVMXC__Event_Call_Type__c == 'WEBSERVICE')
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SFM_Event__c' ) ) {
                    
                    delete event_EntitlementAttributes; //SDL-SVMX-DELETE-FLS-ENFORCED
                    event_EntitlementAttributes.clear();
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }
    
            //Custom Events
            EventAfterReceiptObj.SVMXC__ServiceMax_Process__c = ReceivingProcessObj.Id;
            EventAfterDeliveryObj.SVMXC__ServiceMax_Process__c = ReceivingProcessObj.Id;
            EventAfterClosureObj.SVMXC__ServiceMax_Process__c = ReceivingProcessObj.Id;
            
            if((EventAfterReceiptObj.SVMXC__Namespace__c != null || EventAfterReceiptObj.SVMXC__Class__c != null || EventAfterReceiptObj.SVMXC__Method__c != null) && (EventAfterReceiptObj.SVMXC__Namespace__c != '' || EventAfterReceiptObj.SVMXC__Class__c != '' || EventAfterReceiptObj.SVMXC__Method__c != ''))
                LstRelatedEvents.add(EventAfterReceiptObj);
            else if(EventAfterReceiptObj.Id != null && EventAfterReceiptObj.SVMXC__ServiceMax_Process__c != null && EventAfterReceiptObj.SVMXC__Event_Type__c == 'After Receipt' && EventAfterReceiptObj.SVMXC__Event_Call_Type__c == 'WEBSERVICE')
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SFM_Event__c' ) ) {
                    
                    delete EventAfterReceiptObj; //SDL-SVMX-DELETE-FLS-ENFORCED
                    EventAfterReceiptObj.clear();
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }   
            
            if((EventAfterDeliveryObj.SVMXC__Namespace__c != null || EventAfterDeliveryObj.SVMXC__Class__c != null || EventAfterDeliveryObj.SVMXC__Method__c != null) && (EventAfterDeliveryObj.SVMXC__Namespace__c != '' || EventAfterDeliveryObj.SVMXC__Class__c != '' || EventAfterDeliveryObj.SVMXC__Method__c != ''))
                LstRelatedEvents.add(EventAfterDeliveryObj);
            else if(EventAfterDeliveryObj.Id != null && EventAfterDeliveryObj.SVMXC__ServiceMax_Process__c != null && EventAfterDeliveryObj.SVMXC__Event_Type__c == 'After Delivery' && EventAfterDeliveryObj.SVMXC__Event_Call_Type__c == 'WEBSERVICE')
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SFM_Event__c' ) ) {
                    
                    delete EventAfterDeliveryObj; //SDL-SVMX-DELETE-FLS-ENFORCED
                    EventAfterDeliveryObj.clear();
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }
            if((EventAfterClosureObj.SVMXC__Namespace__c != null || EventAfterClosureObj.SVMXC__Class__c != null || EventAfterClosureObj.SVMXC__Method__c != null) && (EventAfterClosureObj.SVMXC__Namespace__c != '' || EventAfterClosureObj.SVMXC__Class__c != '' || EventAfterClosureObj.SVMXC__Method__c != ''))
                LstRelatedEvents.add(EventAfterClosureObj);
            else if(EventAfterClosureObj.Id != null && EventAfterClosureObj.SVMXC__ServiceMax_Process__c != null && EventAfterClosureObj.SVMXC__Event_Type__c == 'After Closure' && EventAfterClosureObj.SVMXC__Event_Call_Type__c == 'WEBSERVICE')
            {   
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SFM_Event__c' ) ) {
                    
                    delete EventAfterClosureObj; //SDL-SVMX-DELETE-FLS-ENFORCED
                    EventAfterClosureObj.clear();
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }
            //Upsert
            //upsert LstRelatedEvents;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(LstRelatedEvents, COMM_SecurityUtils.Access.Upsertable)){
			    upsert LstRelatedEvents; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			} else {
			    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
			}
            preparingPickLists();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, getTag095(), ''));
            QuickSaveComplete = true;
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getmessage(), ''));
            Database.rollback(sp);
        }
        return null;
    }
    
    public pagereference cancel()
    {
        PageReference ReturnPage = new PageReference('/apex/CONF_ManageReceivingProcesses');
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    public pagereference SaveAndClose()
    {
        SaveReceivingProcess();
        if(!QuickSaveComplete) return null;
        PageReference ReturnPage = new PageReference('/apex/CONF_ManageReceivingProcesses');
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    //custom labels
    public String getTag001(){ return System.label.CONF023_TAG001;} // General Info
    public String getTag002(){ return System.label.CONF023_TAG002;} // Process Name
    public String getTag003(){ return System.label.CONF023_TAG003;} // Process ID
    public String getTag004(){ return System.label.CONF023_TAG004;} // Description
    //public String getTag005(){ return System.label.CONF023_TAG005;} // Product Information
    //public String getTag006(){ return System.label.CONF023_TAG006;} // Choose up to 2 Product fields to show in each line
    public String getTag007(){ return System.label.CONF023_TAG007;} // Standard Receiving Processes
    //public String getTag008(){ return System.label.CONF023_TAG008;} // Serial Number Source
    public String getTag009(){ return System.label.CONF023_TAG009;} // Line record has IB, consider Serial Number from IB
    public String getTag010(){ return System.label.CONF023_TAG010;} // From Line Record
    //public String getTag011(){ return System.label.CONF023_TAG011;} // Consider from stock - In Transit Stock
    public String getTag012(){ return System.label.CONF023_TAG012;} // Capture Interactively
    public String getTag013(){ return System.label.CONF023_TAG013;} // View
    public String getTag014(){ return System.label.CONF023_TAG014;} // Receiving Console Configuration
    //public String getTag015(){ return System.label.CONF023_TAG015;} // What to scan first
    public String getTag016(){ return System.label.CONF023_TAG016;} // Choose up to 3 fields to show from the RMA
    //public String getTag017(){ return System.label.CONF023_TAG017;} // Split line when line quantity is greater than one
    //public String getTag018(){ return System.label.CONF023_TAG018;} // Entitlement Options
    public String getTag019(){ return System.label.CONF023_TAG019;} // Perform entitlement check after receipt
    public String getTag020(){ return System.label.CONF023_TAG020;} // Invoke this web service before entitlement check
    public String getTag021(){ return System.label.CONF023_TAG021;} // Namespace prefix
    public String getTag022(){ return System.label.CONF023_TAG022;} // Web service class name
    public String getTag023(){ return System.label.CONF023_TAG023;} // Method name
    public String getTag024(){ return System.label.CONF023_TAG024;} // Receipt Qualification
    public String getTag025(){ return System.label.CONF023_TAG025;} // Using the expression-builder below, indicate how RMA record qualifies for this receiving process.
    public String getTag026(){ return System.label.CONF023_TAG026;} // Use an existing criteria from the list
    public String getTag027(){ return System.label.CONF023_TAG027;} // View/Edit
    public String getTag028(){ return System.label.CONF023_TAG028;} // Create New
    public String getTag029(){ return System.label.CONF023_TAG029;} // Expression Name
    public String getTag030(){ return System.label.CONF023_TAG030;} // Expression ID
    public String getTag031(){ return System.label.CONF023_TAG031;} // Field Name
    public String getTag032(){ return System.label.CONF023_TAG032;} // Operator
    public String getTag033(){ return System.label.CONF023_TAG033;} // Value
    public String getTag034(){ return System.label.CONF023_TAG034;} // Advanced Expression
    public String getTag035(){ return System.label.CONF023_TAG035;} // Error message to display if the RMA does not meet the above criteria
    public String getTag036(){ return System.label.CONF023_TAG036;} // Using the expression-builder below, indicate how RMA line records qualify for this receiving process.
    public String getTag037(){ return System.label.CONF023_TAG037;} // Action when unexpected serial number is received
    public String getTag038(){ return System.label.CONF023_TAG038;} // Action when unexpected product is received
    public String getTag039(){ return System.label.CONF023_TAG039;} // Action when excess quantity is received
    //public String getTag040(){ return System.label.CONF023_TAG040;} // Action when less than expected quantity is received
    public String getTag041(){ return System.label.CONF023_TAG041;} // In this section, configure the automatic field updates to the RMA record when all the lines are received
    public String getTag042(){ return System.label.CONF023_TAG042;} // In this section, configure the automatic field updates to the RMA lines when the line item is received
    public String getTag043(){ return System.label.CONF023_TAG043;} // Configure Custom Events
    public String getTag044(){ return System.label.CONF023_TAG044;} // After Receipt
    public String getTag045(){ return System.label.CONF023_TAG045;} // After Delivery
    public String getTag046(){ return System.label.CONF023_TAG046;} // After Closure
    //public String getTag047(){ return System.label.CONF023_TAG047;} // Custom Events on Receiving Screen
    //public String getTag048(){ return System.label.CONF023_TAG048;} // Custom Action - 1
    //public String getTag049(){ return System.label.CONF023_TAG049;} // Custom Action - 2
    //public String getTag050(){ return System.label.CONF023_TAG050;} // Custom Action - 3
    public String getTag051(){ return System.label.CONF023_TAG051;} // Using the expression-builder below, indicate how RMA qualifies for Delivery
    public String getTag052(){ return System.label.CONF023_TAG052;} // Using the expression-builder below, indicate how RMA lines qualify for Delivery
    public String getTag053(){ return System.label.CONF023_TAG053;} // In this section, configure the automatic field updates to the RMA record when all the lines are delivered
    public String getTag054(){ return System.label.CONF023_TAG054;} // In this section, configure the automatic field updates to the RMA lines when the line item is delivered
    public String getTag056(){ return System.label.CONF023_TAG056;} // None
    public String getTag068(){ return System.label.CONF023_TAG068;} // Description
    public String getTag069(){ return System.label.CONF023_TAG069;} // Edit
    public String getTag071(){ return System.label.CONF023_TAG071;} // Clone
    public String getTag073(){ return System.label.CONF023_TAG073;} // Configure Work Order Generation Rules
    public String getTag074(){ return System.label.CONF023_TAG074;} // Create Work Order
    public String getTag075(){ return System.label.CONF023_TAG075;} // On Receipt
    public String getTag076(){ return System.label.CONF023_TAG076;} // On Delivery
    public String getTag077(){ return System.label.CONF023_TAG077;} // Never
    //public String getTag078(){ return System.label.CONF023_TAG078;} // Create
    //public String getTag079(){ return System.label.CONF023_TAG079;} // One Work Order for all products
    //public String getTag080(){ return System.label.CONF023_TAG080;} // One Work Order for each product
    //public String getTag081(){ return System.label.CONF023_TAG081;} // One Work Order for each delivery location
    public String getTag082(){ return System.label.CONF023_TAG082;} // Use this field-map to create Work Orders
    public String getTag083(){ return System.label.CONF023_TAG083;} // Use this field-map to create Work Order Lines
    public String getTag084(){ return System.label.CONF023_TAG084;} // Updates on Receipt
    public String getTag085(){ return System.label.CONF023_TAG085;} // Events and Links
    public String getTag086(){ return System.label.CONF023_TAG086;} // Delivery Qualification
    public String getTag087(){ return System.label.CONF023_TAG087;} // Updates after delivery
    public String getTag089(){ return System.label.CONF023_TAG089;} // Config Work Order
    public String getTag090(){ return System.label.CONF023_TAG090;} // Quick Save
    public String getTag091(){ return System.label.CONF023_TAG091;} // Save and Close
    public String getTag092(){ return System.label.CONF023_TAG092;} // Processing...
    public String getTag094(){ return System.label.CONF023_TAG094;} // Cancel
    public String getTag095(){ return System.label.CONF023_TAG095;} // Receiving Process saved
    public String getTag096(){ return System.label.CONF023_TAG096;} // Setup Receiving Process
    public String getTag097(){ return System.label.CONF023_TAG097;} // Reconciliation Rules
    public String getTag098(){ return System.label.CONF023_TAG098;} // Delivery Rule saved
    public String getTag099(){ return System.label.CONF023_TAG099;} // Back To Setup Home
    public String getTag100(){ return System.label.CONF023_TAG100;} // Please enter a valid process name
    public String getTag101(){ return System.label.CONF023_TAG101;} // Process ID must be at least 8 characters long
    public String getTag102(){ return System.label.CONF023_TAG102;} // No depots available. Please setup inventory organization first before setting up delivery rules
    public String getTag103(){ return System.label.CONF023_TAG103;} // Please select a depot from the list
    public String getTag104(){ return System.label.CONF023_TAG104;} // Process ID must be unique.
    public String getTag105(){ return System.label.CONF023_TAG105;} // A field can be used only once in field update rules.
    public String getTag106(){ return System.label.CONF023_TAG106;} // Choose up to 2 fields to show from the RMA Line
    public String getTag107(){ return System.label.CONF023_TAG107;} // Not Allowed
    public String getTag108(){ return System.label.CONF023_TAG108;} // Add
    public String getTag109(){ return System.label.CONF023_TAG109;} // Replace
    public String getTag110(){ return System.label.CONF023_TAG110;} // Hold
    public String getTag111(){ return System.label.CONF023_TAG111;} // Do Nothing
    public String getTag112(){ return System.label.CONF023_TAG112;} // Product
    public String getTag113(){ return System.label.CONF023_TAG113;} // Serial Number
    public String getTag114(){ return System.label.CONF023_TAG114;} // Please choose a valid field from the list
    public String getTag115(){ return System.label.CONF023_TAG115;} // Please enter a valid expression name
    public String getTag116(){ return System.label.CONF023_TAG116;} // Expression ID must be unique and at least 8 characters long.
    public String getTag117(){ return System.label.CONF023_TAG117;} // Receipts Header: 
    public String getTag118(){ return System.label.CONF023_TAG118;} // Receipts Line: 
    public String getTag119(){ return System.label.CONF023_TAG119;} // Delivery Header: 
    public String getTag120(){ return System.label.CONF023_TAG120;} // Delivery Line: 
    public String getTag121(){ return System.label.CONF023_TAG121;} // Invalid expression.
    public String getTag122(){ return System.label.CONF023_TAG122;} // Select Work Order grouping criteria
    //public String getTag123(){ return System.label.CONF023_TAG123;} // Select Work Order creation criteria
    public String getTag126(){ return System.label.CONF023_TAG135;}//'Please select a valid Operator'
    public String getTag127(){ return System.label.CONF023_TAG156;}//This RMA does not match the criteria for receiving.
    public String getTag128(){ return System.label.CONF023_TAG157;}//No RMA lines match the criteria for receiving.
    public String getTag129(){ return System.label.CONF023_TAG158;}//This RMA does not match the criteria for delivery.
    public String getTag130(){ return System.label.CONF023_TAG159;}//No RMA lines match the criteria for delivery.
    public String getTag131(){ return System.label.COMM002_TAG006;} // Equals
    public String getTag132(){ return System.label.COMM002_TAG007;} // Not Equal
    public String getTag133(){ return System.label.COMM002_TAG008;} // Greater Than
    public String getTag134(){ return System.label.COMM002_TAG009;} // Greater or Equal To
    public String getTag135(){ return System.label.COMM002_TAG010;} // Less Than
    public String getTag136(){ return System.label.COMM002_TAG011;} // Less or Equal To
    public String getTag137(){ return System.label.COMM002_TAG012;} // Starts With
    public String getTag138(){ return System.label.COMM002_TAG013;} // Contains
    public String getTag139(){ return System.label.COMM002_TAG014;} // Does Not Contain
    public String getTag140(){ return System.label.COMM002_TAG015;} // Includes
    public String getTag141(){ return System.label.COMM002_TAG016;} // Excludes
    public String getTag142(){ return System.label.COMM002_TAG022;} // Is Null
    public String getTag143(){ return System.label.COMM002_TAG023;} // Is Not Null
    public String getTag144(){ return System.label.CONF023_TAG149;} // Set
    public String getTag145(){ return System.label.CONF023_TAG150;} // Increase
    public String getTag146(){ return System.label.CONF023_TAG151;} // Decrease
    public String getTag147(){ return System.label.CONF023_TAG155;}// Please Enter a valid error message.
    public String getTag149(){ return System.label.CONF023_TAG083;}// Object Mapping between RMA Line and Work Order. 
    public String getTag150(){ return System.label.CONF023_TAG152;}// What type takes precendence when creating Work Order. 
    public String getTag151(){ return System.label.CONF023_TAG153;}// Apply Order first 
    public String getTag152(){ return System.label.CONF023_TAG154;}// Apply Line first 
    public String getTag153(){ return System.label.CONF023_TAG135;} // Installed Product And Entitlement
    public String getTag154(){ return System.label.CONF023_TAG136;} // Resolve Unexpected Serial Number To Installed Product
    public String getTag155(){ return System.label.CONF023_TAG134;} // Perform Entitlement Check For Resolved Serial Numbers
    public String getTag156(){ return System.label.CONF023_TAG137;} // Optional Custom Web Service To Resolve Installed Product
    public String getTAG157() {return system.label.COMM002_TAG032;}//'Add Row'
    public String getTAG158() {return system.label.COMM002_TAG033;}//'Delete Row'
    public string getHLPURL() {return system.label.CONF023_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
    
}