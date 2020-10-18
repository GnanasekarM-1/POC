public with sharing class CONF_SetupFulfillmentProcess
{
    public String recordId;
    public String mode;
    public Boolean tab3Msg = false;
    public Boolean pageMsg = false;
    public boolean validate;
    public boolean doCheckFulfillmentRule = true;
    public boolean disabled{get;set;}
    public String selectedTab{get; set;}
    public String selectedDoc1{get; set;}
    public String selectedDoc2{get; set;}
    public String selectedDoc3{get; set;}
    public String selectedProd1{get; set;}
    public String selectedProd2{get; set;}
    public String selectedProdExpr{get; set;}
    public String selectedPOExpr{get; set;}
    public String selectedPOLineExpr{get; set;}
    public String selectedPOObjMap{get; set;}
    public String selectedPOLineObjMap{get; set;}
    public String SelectedRow{get; set;}
    public String SelectedParentDepot{get; set;}
    public boolean renderProdExpViewEdit{get;set;}
    public boolean renderProdExprBlock{get;set;}
    public boolean renderPOExpViewEdit{get;set;}
    public boolean renderPOExprBlock{get;set;}
    public boolean renderPOLineExpViewEdit{get;set;}
    public boolean renderPOLineExprBlock{get;set;}
    public boolean renderPathRuleDetails{get;set;}
    public boolean disableRuleSeqBtn{get;set;}
    public boolean disableRuleViewDelBtn{get;set;}
    public boolean IsNewPathRule = false;
    
    public List<SelectOption> OperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getOperatorSelectLst(){ return OperatorSelectLst; }
    public List<SelectOption> lstDocumentFields = new List<SelectOption>();
    public List<SelectOption> getlstDocumentFields(){return lstDocumentFields;}
    public List<SelectOption> lstDocumentLineFields = new List<SelectOption>();
    public List<SelectOption> getlstDocumentLineFields(){return lstDocumentLineFields;}
    public List<SelectOption> lstProductFields = new List<SelectOption>();
    public List<SelectOption> getlstProductFields(){return lstProductFields;}
    public List<SelectOption> lstProductExpr = new List<SelectOption>();
    public List<SelectOption> getlstProductExpr(){return lstProductExpr;}
    public List<SelectOption> lstPOExpr = new List<SelectOption>();
    public List<SelectOption> getlstPOExpr(){return lstPOExpr;}
    public List<SelectOption> lstPOLineExpr = new List<SelectOption>();
    public List<SelectOption> getlstPOLineExpr(){return lstPOLineExpr;}
    public List<SelectOption> lstPOObjMap = new List<SelectOption>();
    public List<SelectOption> getlstPOObjMap(){return lstPOObjMap;}
    public List<SelectOption> lstPOLineObjMap = new List<SelectOption>();
    public List<SelectOption> getlstPOLineObjMap(){return lstPOLineObjMap;}
    public List<SelectOption> lstFulfillmentLocs = new List<SelectOption>();
    public List<SelectOption> getlstFulfillmentLocs() { return lstFulfillmentLocs; }
    public List<SelectOption> lstParentDepots = new List<SelectOption>();
    public List<SelectOption> getlstParentDepots(){ return lstParentDepots;}
    public List<String> availableDepotsSelctd = new List<String>();
    public List<String> getavailableDepotsSelctd(){   return this.availableDepotsSelctd; }
    public void setavailableDepotsSelctd(List<String> availdepots){ this.availableDepotsSelctd = availdepots; }
    public List<String> selectedDepotsSelctd = new List<String>();
    public List<String> getselectedDepotsSelctd(){   return this.selectedDepotsSelctd; }  
    public void setselectedDepotsSelctd(List<String> selctddepots){ this.selectedDepotsSelctd = selctddepots; }
    public List<SelectOption> AvailableDepotOptns = new List<SelectOption>();
    public List<SelectOption> getAvailableDepotOptns() 
    {
        return AvailableDepotOptns;
    }
    public List<SelectOption> SelectedDepotsOptns = new List<SelectOption>();
    public List<SelectOption> getSelectedDepotsOptns()
    {
        return SelectedDepotsOptns;
    }
    
    public Map<Id, SVMXC__ServiceMax_Processes__c> mapProdExpRec = new Map<Id, SVMXC__ServiceMax_Processes__c>();
    public Map<Id, List<SVMXC__ServiceMax_Config_data__c>> mapProdExp_DetailRec = new Map<Id, List<SVMXC__ServiceMax_Config_data__c>>();
    public Map<Id, SVMXC__ServiceMax_Processes__c> mapPOExpRec = new Map<Id, SVMXC__ServiceMax_Processes__c>();
    public Map<Id, List<SVMXC__ServiceMax_Config_data__c>> mapPOExp_DetailRec = new Map<Id, List<SVMXC__ServiceMax_Config_data__c>>();
    public Map<Id, SVMXC__ServiceMax_Processes__c> mapPOLineExpRec = new Map<Id, SVMXC__ServiceMax_Processes__c>();
    public Map<Id, List<SVMXC__ServiceMax_Config_data__c>> mapPOLineExp_DetailRec = new Map<Id, List<SVMXC__ServiceMax_Config_data__c>>();
    
    public SVMXC__ServiceMax_Processes__c POExp = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getPOExp(){ return POExp; }
    public void setPOExp(SVMXC__ServiceMax_Processes__c hdrCriteriaRec){ this.POExp = hdrCriteriaRec; }
    public SVMXC__ServiceMax_Processes__c POLineExp = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getPOLineExp(){ return POLineExp; }
    public void setPOLineExp(SVMXC__ServiceMax_Processes__c hdrCriteriaRec){ this.POLineExp = hdrCriteriaRec; }
    public SVMXC__ServiceMax_Processes__c ProdExp = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getProdExp(){ return ProdExp; }
    public void setProdExp(SVMXC__ServiceMax_Processes__c hdrCriteriaRec){ this.ProdExp = hdrCriteriaRec; }
    
    public List<SVMXC__ServiceMax_Config_Data__c> LstPOCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getLstPOCriteria(){ return LstPOCriteria; }
    public void setLstPOCriteria(List<SVMXC__ServiceMax_Config_Data__c> lstCriteriaRecs){ this.LstPOCriteria = lstCriteriaRecs; }
    public List<SVMXC__ServiceMax_Config_Data__c> LstPOLineCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getLstPOLineCriteria(){ return LstPOLineCriteria; }
    public void setLstPOLineCriteria(List<SVMXC__ServiceMax_Config_Data__c> lstCriteriaRecs){ this.LstPOLineCriteria = lstCriteriaRecs; }
    public List<SVMXC__ServiceMax_Config_Data__c> LstProdCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getLstProdCriteria(){ return LstProdCriteria; }
    public void setLstProdCriteria(List<SVMXC__ServiceMax_Config_Data__c> lstCriteriaRecs){ this.LstProdCriteria = lstCriteriaRecs; }
    
    RecordType Rtype_expressions;
    RecordType Rtype_NamedExpression;
    RecordType Rtype_FulFillmentProcess;
    RecordType Rtype_Prod_Doc_Attributes;
    RecordType Rtype_FulFillmentLocation;
    
    public Map<Id,String> mapParentDepotId_Name = new Map<Id,String>();
    public Map<Id,String> mapChildDepotId_Name = new Map<Id,String>();//All DepotChild Recs
    public Map<Id, Map<Id,String>> mapParentDepotId_mapChildDepotIdName = new Map<Id, Map<Id,String>>();
    public Map<Id, List<SelectOption>> mapParentDepotId_slctlstChildDepots = new Map<Id, List<SelectOption>>();
    
    public SVMXC__ServiceMax_Processes__c FulfillmentProcess = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getFulfillmentProcess(){return FulfillmentProcess;}
    public void setFulfillmentProcess(SVMXC__ServiceMax_Processes__c pro){this.FulfillmentProcess = pro;}
    
    public List<SVMXC__ServiceMax_Processes__c> lstFulfillmentPathRules = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getlstFulfillmentPathRules(){return lstFulfillmentPathRules;}
    public void setlstFulfillmentPathRules(List<SVMXC__ServiceMax_Processes__c> lst){this.lstFulfillmentPathRules = lst;}
    public SVMXC__ServiceMax_Processes__c fulfillmentPathRule = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getfulfillmentPathRule(){return fulfillmentPathRule;}
    public void setfulfillmentPathRule(SVMXC__ServiceMax_Processes__c rul){this.fulfillmentPathRule = rul;}
    public List<SVMXC__ServiceMax_Processes__c> lstFulfillmentPathRulesClone = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstConfigDataPathRuleClone = new List<SVMXC__ServiceMax_Config_Data__c>();
    public Map<ID,integer> mapOldIDNewPro = new Map<ID,integer>();
    public Map<integer, SVMXC__ServiceMax_Processes__c> mapNewProSeqToPro = new Map<integer, SVMXC__ServiceMax_Processes__c>();
    
    public List<SVMXC__ServiceMax_Config_Data__c> lstConfigDataQueried = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstConfigDataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> LstConfigRecs_SelectedLocations = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstConfigData_ToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    public Integer POCriteriaSize
    {
        get{return LstPOCriteria.size();}
    }
    public Integer POLineCriteriaSize
    {
        get{return LstPOLineCriteria.size();}
    }
    public Integer ProdCriteriaSize
    {
        get{return LstProdCriteria.size();}
    }
    /*public Boolean gettab3Msg(){return tab3Msg;}
    public void settab3Msg(Boolean tab3Msg){this.tab3Msg = tab3Msg;}
    public Boolean getpageMsg(){return pageMsg;}
    public void setpageMsg(Boolean pageMsg){this.pageMsg = pageMsg;}*/
    public void OnLoadAction()
    {
        if( System.currentPageReference().getParameters().get('SVMX_RecordId') != null ) {
        	recordId = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('SVMX_RecordId'));    
        }
        
        if( System.currentPageReference().getParameters().get('SVMX_Mode') != null ) {
        	mode = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('SVMX_Mode'));    
        }
        
        queryingRecordTypes();
        preparingPickLists();
        setDefaultValues();
        
        if(recordId == null || recordId == '')
            mode = 'New';
        else if(recordId != null && recordId != '' && (mode == null || mode == ''))
            mode = 'Edit';
        else if(recordId != null && recordId != '' && mode == 'Clone')
            mode = 'Clone';
        
        if(mode != 'New' && recordId != null && recordId != '')
        {
            FulfillmentProcess = [Select Id, SVMXC__IsStandard__c, RecordTypeId, SVMXC__Parent_Error_Msg__c, SVMXC__Child_Error_Msg__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Submodule__c, SVMXC__Node_Parent__c, SVMXC__Final_Exception_Process__c from SVMXC__ServiceMax_Processes__c where Id =: recordId AND RecordTypeId =: Rtype_FulFillmentProcess.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(mode == 'Edit' && FulfillmentProcess.SVMXC__IsStandard__c == true)
                disabled = true;
            
            if(FulfillmentProcess.SVMXC__Module__c != null)
            {
                selectedPOExpr = FulfillmentProcess.SVMXC__Module__c;
                renderPOExpViewEdit = true;
            }
            if(FulfillmentProcess.SVMXC__Submodule__c != null)
            {
                selectedPOLineExpr = FulfillmentProcess.SVMXC__Submodule__c;
                renderPOLineExpViewEdit = true;
            }
            if(FulfillmentProcess.SVMXC__Node_Parent__c != null)
                selectedPOObjMap = FulfillmentProcess.SVMXC__Node_Parent__c;
            if(FulfillmentProcess.SVMXC__Final_Exception_Process__c != null)
                selectedPOLineObjMap = FulfillmentProcess.SVMXC__Final_Exception_Process__c;
            if(FulfillmentProcess.SVMXC__Parent_Error_Msg__c == null || FulfillmentProcess.SVMXC__Parent_Error_Msg__c.length() == 0)
                FulfillmentProcess.SVMXC__Parent_Error_Msg__c = getTAG080();
            if(FulfillmentProcess.SVMXC__Child_Error_Msg__c == null || FulfillmentProcess.SVMXC__Child_Error_Msg__c.length() == 0)
                FulfillmentProcess.SVMXC__Child_Error_Msg__c = getTAG081();
            
            queryConfDataProcess();
            
            if(lstConfigDataQueried != null && lstConfigDataQueried.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c tempData : lstConfigDataQueried)
                {
                    if(tempData.SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE' && tempData.SVMXC__Sequence__c == 1)
                        selectedProd1 = tempData.SVMXC__Field_Name__c;
                    else if(tempData.SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE' && tempData.SVMXC__Sequence__c == 2)
                        selectedProd2 = tempData.SVMXC__Field_Name__c;
                    else if(tempData.SVMXC__Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && tempData.SVMXC__Sequence__c == 1)
                        selectedDoc1 = tempData.SVMXC__Field_Name__c;
                    else if(tempData.SVMXC__Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && tempData.SVMXC__Sequence__c == 2)
                        selectedDoc2 = tempData.SVMXC__Field_Name__c;
                    else if(tempData.SVMXC__Configuration_Type__c == 'DOCUMENT_ATTRIBUTE' && tempData.SVMXC__Sequence__c == 3)
                        selectedDoc3 = tempData.SVMXC__Field_Name__c;
                }
            }
            
            lstFulfillmentPathRules.clear();
            lstFulfillmentPathRules = [Select Id, SVMXC__Name__c, RecordTypeId, SVMXC__ProcessID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Rule_Type__c, SVMXC__Parent_Column_Name__c, SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__IsDefault__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: FulfillmentProcess.Id AND SVMXC__Process__c!= null AND RecordType.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'FulFillment Path' Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstFulfillmentPathRules.size() < 2)
                disableRuleSeqBtn = true;
            if(lstFulfillmentPathRules.size() == 0) 
                disableRuleViewDelBtn = true;
        }
        if(mode == 'New')
        {
            FulfillmentProcess = new SVMXC__ServiceMax_Processes__c();
            FulfillmentProcess.SVMXC__Parent_Error_Msg__c = getTAG080();
            FulfillmentProcess.SVMXC__Child_Error_Msg__c = getTAG081();
        }
        
        if(mode == 'clone')
        {
            lstConfigDataQueried.clear();
            SVMXC__ServiceMax_Processes__c tempProcess = FulfillmentProcess;
            FulfillmentProcess = new SVMXC__ServiceMax_Processes__c();
            FulfillmentProcess.SVMXC__IsStandard__c = false;
            FulfillmentProcess.RecordTypeId = tempProcess.RecordTypeId;
            FulfillmentProcess.SVMXC__Parent_Error_Msg__c = tempProcess.SVMXC__Parent_Error_Msg__c;
            FulfillmentProcess.SVMXC__Child_Error_Msg__c = tempProcess.SVMXC__Child_Error_Msg__c;
            FulfillmentProcess.SVMXC__Name__c = tempProcess.SVMXC__Name__c;
            string ProcessID = tempProcess.SVMXC__ProcessID__c + ' ' + system.now();
            if(ProcessID.length() > 29 || ProcessID.length() == 29)
                ProcessID = ProcessID.substring(0, 28);
            FulfillmentProcess.SVMXC__ProcessID__c = ProcessID + ' ' + system.now();
            FulfillmentProcess.SVMXC__Description__c = tempProcess.SVMXC__Description__c;
            FulfillmentProcess.SVMXC__Module__c = tempProcess.SVMXC__Module__c;
            FulfillmentProcess.SVMXC__Submodule__c = tempProcess.SVMXC__Submodule__c;
            FulfillmentProcess.SVMXC__Node_Parent__c = tempProcess.SVMXC__Node_Parent__c;
            FulfillmentProcess.SVMXC__Final_Exception_Process__c = tempProcess.SVMXC__Final_Exception_Process__c;
            if(FulfillmentProcess != null){
				//upsert FulfillmentProcess;
				if(COMM_SecurityUtils.getInstance().verifyFieldAccess(FulfillmentProcess, COMM_SecurityUtils.Access.Upsertable)){
					upsert FulfillmentProcess; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
				}
				else{
					throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
				}
			}
            
            lstFulfillmentPathRulesClone.clear();
            lstConfigDataPathRuleClone.clear();
            List<ID> lstIDs = new List<ID>();
            if(lstFulfillmentPathRules != null && lstFulfillmentPathRules.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c tempPro : lstFulfillmentPathRules)
                {
                    SVMXC__ServiceMax_Processes__c newPro = new SVMXC__ServiceMax_Processes__c();
                    newPro.SVMXC__Name__c = tempPro.SVMXC__Name__c;
                    newPro.RecordTypeId = tempPro.RecordTypeId;
                    newPro.SVMXC__Sequence__c = tempPro.SVMXC__Sequence__c;
                    newPro.SVMXC__Rule_Type__c = tempPro.SVMXC__Rule_Type__c;
                    newPro.SVMXC__Parent_Column_Name__c = tempPro.SVMXC__Parent_Column_Name__c;
                    newPro.SVMXC__Default_Location__c = tempPro.SVMXC__Default_Location__c;
                    newPro.SVMXC__Submodule__c = tempPro.SVMXC__Submodule__c;
                    newPro.SVMXC__IsDefault__c = tempPro.SVMXC__IsDefault__c;
                    newPro.SVMXC__Process__c = FulfillmentProcess.Id;
                    lstFulfillmentPathRulesClone.add(newPro);
                    lstIDs.add(tempPro.Id);
                    mapOldIDNewPro.put(tempPro.Id, integer.valueOf(tempPro.SVMXC__Sequence__c));
                }
                
                if(lstFulfillmentPathRulesClone != null && lstFulfillmentPathRulesClone.size() > 0){
					//upsert lstFulfillmentPathRulesClone;
					if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstFulfillmentPathRulesClone, COMM_SecurityUtils.Access.Upsertable)){
						upsert lstFulfillmentPathRulesClone; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
					}
					else{
						throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
					}
				}
                lstFulfillmentPathRules.clear();
                lstFulfillmentPathRules.addAll(lstFulfillmentPathRulesClone);
                if(lstFulfillmentPathRules != null && lstFulfillmentPathRules.size() > 0)
                {
                    for(SVMXC__ServiceMax_Processes__c tempPro : lstFulfillmentPathRules)
                        mapNewProSeqToPro.put(integer.valueOf(tempPro.SVMXC__Sequence__c), tempPro);
                }
                
                List<SVMXC__ServiceMax_Config_Data__c> newLstConfigDataPathRuleClone = new List<SVMXC__ServiceMax_Config_Data__c>();
                lstConfigDataPathRuleClone.clear();
                lstConfigDataPathRuleClone = [Select Id, SVMXC__Sequence__c, RecordTypeId, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Dispatch_Process__c, SVMXC__IsDefault__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN: lstIDs AND RecordType.Name = 'Fulfillment Path' AND SVMXC__Location__c != NULL AND SVMXC__Dispatch_Process__c != null]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                if(lstConfigDataPathRuleClone != null && lstConfigDataPathRuleClone.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c tempconf : lstConfigDataPathRuleClone)
                    {
                        SVMXC__ServiceMax_Config_Data__c temp = new SVMXC__ServiceMax_Config_Data__c();
                        temp.RecordTypeId = tempconf.RecordTypeId;
                        temp.SVMXC__Sequence__c  = tempconf.SVMXC__Sequence__c;
                        temp.SVMXC__Location__c = tempconf.SVMXC__Location__c;
                        integer seq = integer.valueOf(mapOldIDNewPro.get(tempconf.SVMXC__Dispatch_Process__c));
                        SVMXC__ServiceMax_Processes__c tempProc = mapNewProSeqToPro.get(seq);
                        temp.SVMXC__Dispatch_Process__c = tempProc.Id;
                        temp.SVMXC__IsDefault__c = tempconf.SVMXC__IsDefault__c;
                        newLstConfigDataPathRuleClone.add(temp);
                    }
                }
                
                if(newLstConfigDataPathRuleClone != null && newLstConfigDataPathRuleClone.size() > 0){
					//upsert newLstConfigDataPathRuleClone;
					if(COMM_SecurityUtils.getInstance().verifyFieldAccess(newLstConfigDataPathRuleClone, COMM_SecurityUtils.Access.Upsertable)){
						upsert newLstConfigDataPathRuleClone; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
					}
					else{
						throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
					}
				}
            }
            mode = 'Edit';
        }
    }
    
    public CONF_SetupFulfillmentProcess()
    {
        
    }
    
    public void queryConfDataProcess()
    {
        lstConfigDataQueried.clear();
        lstConfigDataQueried = [select id, SVMXC__Dispatch_Process__c, SVMXC__Configuration_Type__c, SVMXC__Sequence__c, SVMXC__Field_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: FulfillmentProcess.Id AND SVMXC__Dispatch_Process__c != null AND RecordTypeId =:Rtype_Prod_Doc_Attributes.Id AND (SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE' OR SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    
    //--------------------------------------------- Querying all the record types needed ----------------------------------------------------------
    public void queryingRecordTypes()
    {
        Rtype_expressions = [select Id from RecordType where Name = 'Expressions' and SobjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Rtype_NamedExpression = [select Id from RecordType where Name = 'SVMX Rule' and SobjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Rtype_FulFillmentProcess = [select Id from RecordType where Name = 'Fulfillment Process' and SobjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Rtype_Prod_Doc_Attributes = [Select Id, Name from RecordType where Name = 'Field Mapping' AND SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Rtype_FulFillmentLocation = [Select Id, Name from RecordType where Name = 'Fulfillment Path' AND SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    
    //---------------------------------------------------- Preparing all the PickLists -------------------------------------------------------
    public void preparingPickLists()
    {
        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
        COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
        
        lstDocumentFields.clear();
        lstDocumentFields.add(new SelectOption('None',getTAG045()));
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Order__c', lstDocumentFields, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        
        lstDocumentLineFields.clear();
        lstDocumentLineFields.add(new SelectOption('None',getTAG045()));
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Line__c', lstDocumentLineFields, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        
        lstProductFields.clear();
        lstProductFields.add(new SelectOption('None',getTAG045()));
        DispMethods.RetriveField('Product2', lstProductFields, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        
        OperatorSelectLst.clear();
        OperatorSelectLst.add(new SelectOption('SVMX.NONE',getTAG045()));
        OperatorSelectLst.add(new SelectOption('eq',getTAG047()));
        OperatorSelectLst.add(new SelectOption('ne',getTAG048()));
        OperatorSelectLst.add(new SelectOption('gt',getTAG049()));
        OperatorSelectLst.add(new SelectOption('ge',getTAG050()));
        OperatorSelectLst.add(new SelectOption('lt',getTAG051()));
        OperatorSelectLst.add(new SelectOption('le',getTAG052()));
        OperatorSelectLst.add(new SelectOption('starts',getTAG053()));
        OperatorSelectLst.add(new SelectOption('contains',getTAG054()));
        OperatorSelectLst.add(new SelectOption('notcontain',getTAG055()));
        OperatorSelectLst.add(new SelectOption('in',getTAG056()));
        OperatorSelectLst.add(new SelectOption('notin',getTAG057()));
        OperatorSelectLst.add(new SelectOption('isnull',getTAG058()));
        OperatorSelectLst.add(new SelectOption('isnotnull',getTAG059()));
        
        lstPOObjMap.clear();
        lstPOObjMap.add(new SelectOption('None',getTAG045()));
        List<SVMXC__ServiceMax_Processes__c> objectMappingPO = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPO = [Select id, SVMXC__Name__c, SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c' order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(objectMappingPO != null && objectMappingPO.size()>0)
        {
            for(SVMXC__ServiceMax_Processes__c tempPro : objectMappingPO)
                lstPOObjMap.add(new selectOption(tempPro.Id, tempPro.SVMXC__Name__c));
        }
        
        lstPOLineObjMap.clear();
        lstPOLineObjMap.add(new SelectOption('None',getTAG045()));
        List<SVMXC__ServiceMax_Processes__c> objectMappingPOLine = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPOLine = [Select id, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c' order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(objectMappingPOLine != null && objectMappingPOLine.size()>0)
        {
            for(SVMXC__ServiceMax_Processes__c tempPro : objectMappingPOLine)
                lstPOLineObjMap.add(new selectOption(tempPro.Id, tempPro.SVMXC__Name__c));
        }
        
        List<SVMXC__Site__c> FulfillmentLocations = new List<SVMXC__Site__c>();
        FulfillmentLocations = [Select Id, Name, SVMXC__Parent__c, SVMXC__IsGood_Stock__c, SVMXC__Parent__r.Name from SVMXC__Site__c where RecordType.Name = 'Depot Child' AND SVMXC__Parent__c != NULL AND SVMXC__Parent__r.RecordType.Name = 'Depot' AND SVMXC__IsGood_Stock__c = true Order By Name];
        lstFulfillmentLocs.clear();
        lstFulfillmentLocs.add(new SelectOption('None',getTAG045()));
        lstParentDepots.clear();
        lstParentDepots.add(new SelectOption('All',getTAG063()));
        if(FulfillmentLocations != null && FulfillmentLocations.size()>0)
        {
            for(SVMXC__Site__c loc : FulfillmentLocations)
            {
                lstFulfillmentLocs.add(new SelectOption(loc.Id,loc.Name));
                lstParentDepots.add(new SelectOption(loc.SVMXC__Parent__c, loc.SVMXC__Parent__r.Name));
                mapParentDepotId_Name.put(loc.SVMXC__Parent__c, loc.SVMXC__Parent__r.Name);
                mapChildDepotId_Name.put(loc.Id,loc.Name);
                Map<Id,String> tempMapChildDepotIdName = new Map<Id,String>();
                if(mapParentDepotId_mapChildDepotIdName != null && mapParentDepotId_mapChildDepotIdName.containsKey(loc.SVMXC__Parent__c) && mapParentDepotId_mapChildDepotIdName.get(loc.SVMXC__Parent__c) != null)
                {
                    tempMapChildDepotIdName = mapParentDepotId_mapChildDepotIdName.get(loc.SVMXC__Parent__c);
                }
                tempMapChildDepotIdName.put(loc.Id,loc.Name);
                mapParentDepotId_mapChildDepotIdName.put(loc.SVMXC__Parent__c ,tempMapChildDepotIdName);
                List<SelectOption> templstSelectOption = new List<SelectOption>();
                if(mapParentDepotId_slctlstChildDepots != null && mapParentDepotId_slctlstChildDepots.containsKey(loc.SVMXC__Parent__c) && mapParentDepotId_slctlstChildDepots.get(loc.SVMXC__Parent__c) != null)
                {
                    templstSelectOption = mapParentDepotId_slctlstChildDepots.get(loc.SVMXC__Parent__c);
                }
                templstSelectOption.add(new SelectOption(loc.Id, loc.Name));
                mapParentDepotId_slctlstChildDepots.put(loc.SVMXC__Parent__c, templstSelectOption);
            }
        }
        
        lstFulfillmentLocs = sortingSelectOption(lstFulfillmentLocs);
        lstParentDepots = sortingSelectOption(lstParentDepots);
        AvailableDepotOptns.clear();
        for(SelectOption option: lstfulFillmentLocs)
        {
            if(option.getValue() != 'None')
                AvailableDepotOptns.add(option);
        }
        AvailableDepotOptns = sortingSelectOption(AvailableDepotOptns);
        queryExps();
    }
    
    //------------------------------ Querying all the Expressions needed and preparing PickLists for them ----------------------------------
    public void queryExps()
    {
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap stringMap = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','Product2');
        lstStringMap.add(stringMap);
        SFM_WrapperDef.SFM_Request request1 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_WrapperDef.SFM_Response_Expression response = new SFM_WrapperDef.SFM_Response_Expression();
        response = namedExpLst.SFM_getNamedExpressionList(request1);
        
        mapProdExpRec.clear();
        mapProdExp_DetailRec.clear();
        lstProductExpr.clear();
        lstProductExpr.add(new SelectOption('None',getTAG045()));
        if(response != null && response.expressions != null)
        {
            for(SFM_WrapperDef.SFM_Expression Sfm_Exp :response.expressions)
            {
                lstProductExpr.add(new SelectOption(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression.SVMXC__Name__c ));
                mapProdExpRec.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression);
                mapProdExp_DetailRec.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.expressionDetails);
            }
        }
        lstProductExpr = sortingSelectOption(lstProductExpr);
        
        lstStringMap.clear();
        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Order__c');
        lstStringMap.add(stringMap1);
        request1 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        response = new SFM_WrapperDef.SFM_Response_Expression();
        response = namedExpLst.SFM_getNamedExpressionList(request1);
        
        mapPOExpRec.clear();
        mapPOExp_DetailRec.clear();
        lstPOExpr.clear();
        lstPOExpr.add(new SelectOption('None',getTAG045()));
        if(response != null && response.expressions != null)
        {
            for(SFM_WrapperDef.SFM_Expression Sfm_Exp :response.expressions)
            {
                lstPOExpr.add(new SelectOption(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression.SVMXC__Name__c ));
                mapPOExpRec.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression);
                mapPOExp_DetailRec.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.expressionDetails);
            }
        }
        lstPOExpr = sortingSelectOption(lstPOExpr);
        
        lstStringMap.clear();
        SFM_WrapperDef.SFM_StringMap stringMap2 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__RMA_Shipment_Line__c');
        lstStringMap.add(stringMap2);
        request1 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        response = new SFM_WrapperDef.SFM_Response_Expression();
        response = namedExpLst.SFM_getNamedExpressionList(request1);
        
        mapPOLineExpRec.clear();
        mapPOLineExp_DetailRec.clear();
        lstPOLineExpr.clear();
        lstPOLineExpr.add(new SelectOption('None',getTAG045()));
        if(response != null && response.expressions != null)
        {
            for(SFM_WrapperDef.SFM_Expression Sfm_Exp :response.expressions)
            {
                lstPOLineExpr.add(new SelectOption(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression.SVMXC__Name__c ));
                mapPOLineExpRec.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.namedExpression);
                mapPOLineExp_DetailRec.put(Sfm_Exp.namedExpression.Id, Sfm_Exp.expressionDetails);
            }
        }
        lstPOLineExpr = sortingSelectOption(lstPOLineExpr);
    }
    
    //---------------------------------------------------- Setting all the Default values ---------------------------------------------
    public void setDefaultValues()
    {
        selectedTab = 'generalInfo';
        selectedDoc1 = 'None';
        selectedDoc2 = 'None';
        selectedDoc3 = 'None';
        selectedProd1 = 'None';
        selectedProd2 = 'None';
        selectedPOExpr = 'None';
        selectedPOLineExpr = 'None';
        renderPOExpViewEdit = false;
        renderPOExprBlock = false;
        renderPOLineExpViewEdit = false;
        renderPOLineExprBlock = false;
        disabled = false;
        selectedPOObjMap = 'None';
        selectedPOLineObjMap = 'None';
        renderPathRuleDetails = false;
        selectedProdExpr = 'None';
        renderProdExpViewEdit = false;
        renderProdExprBlock = false;
        SelectedParentDepot = 'All';
        disableRuleSeqBtn = false;
        disableRuleViewDelBtn = false;
    }
    
    //----------------------------------------- Sorting of the PickList Values ------------------------------------------
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
    
    //-------------------------------------- Method for on Change of PO Expression --------------------------------------------------------
    public void OnChangePOExpr()
    {
        if(selectedPOExpr != 'None')
            renderPOExpViewEdit = true;
        else
            renderPOExpViewEdit = false;
        renderPOExprBlock = false;
    }
    
    //-------------------------------------- Method to View/Edit of PO Expression --------------------------------------------------------
    public void ViewEditPOCriteria()
    {
        renderPOExprBlock = true;
        if(selectedPOExpr != 'None')
        {
            Id selectedHdrId = (Id)selectedPOExpr;
            if(mapPOExpRec.containsKey(selectedHdrId) && mapPOExp_DetailRec.containsKey(selectedHdrId))
            {
                POExp = mapPOExpRec.get(selectedHdrId);
                LstPOCriteria = mapPOExp_DetailRec.get(selectedHdrId);
            }
        }
    }
    
    //-------------------------------------- Method to create a new PO Expression --------------------------------------------------------
    public void CreateNewPOCriteria()
    {
        selectedPOExpr = 'None';
        renderPOExprBlock = true;
        renderPOExpViewEdit = false;
        POExp = new SVMXC__ServiceMax_Processes__c(RecordTypeId = Rtype_NamedExpression.Id, SVMXC__Rule_Type__c = 'Named Expression', SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c');
        LstPOCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
        POCriteria_AddRow();
    }
    
    //-------------------------------------- Method to delete Row in the Details of PO Criteria --------------------------------------------------------
    public void POCriteria_DelRow()
    {
        if((LstPOCriteria == null || (LstPOCriteria != null && !(LstPOCriteria.size() > 0))) && SelectedRow != null)
            return;
        Integer tempDeletedIndex = Integer.valueOf(SelectedRow) - 1;
        if(LstPOCriteria[tempDeletedIndex] != null && LstPOCriteria[tempDeletedIndex].get('Id') != null)
            lstConfigData_ToDelete.add(LstPOCriteria[tempDeletedIndex]);
        List<SVMXC__ServiceMax_Config_Data__c> lstTempConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c HeaderCriteriaRec: LstPOCriteria)
        {
            if(HeaderCriteriaRec.SVMXC__Sequence__c == Integer.valueOf(SelectedRow))
                continue;
            lstTempConfigData.add(HeaderCriteriaRec);
        }
        LstPOCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(lstTempConfigData != null && lstTempConfigData.size() > 0)
        {
            LstPOCriteria.addAll(lstTempConfigData);
            for(integer i=0; i< LstPOCriteria.size(); i++)
                LstPOCriteria[i].SVMXC__Sequence__c = i + 1;
        }
    }
    
    //-------------------------------------- Method to add Row in the Details of PO Criteria --------------------------------------------------------
    public void POCriteria_AddRow()
    {
        LstPOCriteria.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = LstPOCriteria.size() + 1, RecordTypeId = Rtype_expressions.Id));
    }
    
    //-------------------------------------- Method for on Change of PO-Line Expression --------------------------------------------------------
    public void OnChangePOLineExpr()
    {
        if(selectedPOLineExpr != 'None')
            renderPOLineExpViewEdit = true;
        else
            renderPOLineExpViewEdit = false;
        renderPOLineExprBlock = false;
    }
    
    //-------------------------------------- Method to View/Edit of PO-Line Expression --------------------------------------------------------
    public void ViewEditPOLineCriteria()
    {
        renderPOLineExprBlock = true;
        if(selectedPOLineExpr != 'None')
        {
            Id selectedHdrId = (Id)selectedPOLineExpr;
            if(mapPOLineExpRec.containsKey(selectedHdrId) && mapPOLineExp_DetailRec.containsKey(selectedHdrId))
            {
                POLineExp = mapPOLineExpRec.get(selectedHdrId);
                LstPOLineCriteria = mapPOLineExp_DetailRec.get(selectedHdrId);
            }
        }
    }
    
    //-------------------------------------- Method to create a new PO-Line Expression --------------------------------------------------------
    public void CreateNewPOLineCriteria()
    {
        selectedPOLineExpr = 'None';
        renderPOLineExprBlock = true;
        renderPOLineExpViewEdit = false;
        POLineExp = new SVMXC__ServiceMax_Processes__c(RecordTypeId = Rtype_NamedExpression.Id, SVMXC__Rule_Type__c = 'Named Expression', SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c');
        LstPOLineCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
        POLineCriteria_AddRow();
    }
    
    //-------------------------------------- Method to delete Row in the Details of PO Criteria --------------------------------------------------------
    public void POLineCriteria_DelRow()
    {
        if((LstPOLineCriteria == null || (LstPOLineCriteria != null && !(LstPOLineCriteria.size() > 0))) && SelectedRow != null)
            return;
        Integer tempDeletedIndex = Integer.valueOf(SelectedRow) - 1;
        if(LstPOLineCriteria[tempDeletedIndex] != null && LstPOLineCriteria[tempDeletedIndex].get('Id') != null)
            lstConfigData_ToDelete.add(LstPOLineCriteria[tempDeletedIndex]);
        List<SVMXC__ServiceMax_Config_Data__c> lstTempConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c HeaderCriteriaRec: LstPOLineCriteria)
        {
            if(HeaderCriteriaRec.SVMXC__Sequence__c == Integer.valueOf(SelectedRow))
                continue;
            lstTempConfigData.add(HeaderCriteriaRec);
        }
        LstPOLineCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(lstTempConfigData != null && lstTempConfigData.size() > 0)
        {
            LstPOLineCriteria.addAll(lstTempConfigData);
            for(integer i=0; i< LstPOLineCriteria.size(); i++)
                LstPOLineCriteria[i].SVMXC__Sequence__c = i + 1;
        }
    }
    
    //-------------------------------------- Method to add Row in the Details of PO Criteria --------------------------------------------------------
    public void POLineCriteria_AddRow()
    {
        LstPOLineCriteria.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = LstPOLineCriteria.size() + 1, RecordTypeId = Rtype_expressions.Id));
    }
    
    //--------------------------------------------------Methods to switch between Tabs ---------------------------------------------------------
    public void gotoGeneralInfoTab()
    {
        selectedTab = 'generalInfo';
    }
    public void gotoCriteriaMappingsTab()
    {
        selectedTab = 'criteriaMapping';
    } 
    public void gotoFulfillmentPathTab()
    {
        selectedTab = 'fulfillmentPath';
    }
    
    //-----------------------------------------Methods to Quick Save the Fulfillment Process ------------------------------------------------------
    public pagereference QuickSave()
    {
        validate = true;
        save();
        if(validate != false)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, getTAG064(), ''));
        }
        return null;
    }
    
    //------------------------------------------- Method to Save and close the Fulfillment Process --------------------------------------------
    public pagereference SaveNClose()
    {
        validate = true;
        save();
        if(validate == false) return null;
        PageReference ReturnPage = new PageReference('/apex/CONF_ManageFulfillmentProcesses');
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    //----------------------------------------------- Method to cancel the Fulfillment Process ------------------------------------------------
    public pagereference Cancel()
    {
        PageReference ReturnPage = new PageReference('/apex/CONF_ManageFulfillmentProcesses');
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    public void save()
    {
        validate = true;
        validation();
        if(validate == true)
            saveExp();
        
        if(validate == true)
        {
            if(selectedPOExpr != null && selectedPOExpr != 'None')
                FulfillmentProcess.SVMXC__Module__c = selectedPOExpr;
            else
                FulfillmentProcess.SVMXC__Module__c = null;
            if(selectedPOLineExpr != null && selectedPOLineExpr != 'None')
                FulfillmentProcess.SVMXC__Submodule__c = selectedPOLineExpr;
            else
                FulfillmentProcess.SVMXC__Submodule__c = null;
            if(selectedPOObjMap != null && selectedPOObjMap != 'None')
                FulfillmentProcess.SVMXC__Node_Parent__c = selectedPOObjMap;
            else
                FulfillmentProcess.SVMXC__Node_Parent__c = null;
            if(selectedPOLineObjMap != null && selectedPOLineObjMap != 'None')
                FulfillmentProcess.SVMXC__Final_Exception_Process__c = selectedPOLineObjMap;
            else
                FulfillmentProcess.SVMXC__Final_Exception_Process__c = null;
                
            FulfillmentProcess.RecordTypeId = Rtype_FulFillmentProcess.Id;
            //upsert FulfillmentProcess;
			if(COMM_SecurityUtils.getInstance().verifyFieldAccess(FulfillmentProcess, COMM_SecurityUtils.Access.Upsertable)){
				upsert FulfillmentProcess; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			}
			else{
				throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
			}
            
            if(lstConfigDataQueried != null && lstConfigDataQueried.size()>0)
                delete lstConfigDataQueried; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstConfigDataQueried.clear();
            if(lstConfigData_ToDelete != null && lstConfigData_ToDelete.size()>0)
                delete lstConfigData_ToDelete; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstConfigData_ToDelete.clear();
            
            lstConfigDataToSave.clear();
            if(selectedProd1 != null && selectedProd1 != 'None')
            {
                SVMXC__ServiceMax_Config_Data__c confData1 = new SVMXC__ServiceMax_Config_Data__c();
                confData1 = fillingConfData(selectedProd1, 'PRODUCT_ATTRIBUTE', 1);
                lstConfigDataToSave.add(confData1);
            }
            if(selectedProd2 != null && selectedProd2 != 'None')
            {
                SVMXC__ServiceMax_Config_Data__c confData2 = new SVMXC__ServiceMax_Config_Data__c();
                confData2 = fillingConfData(selectedProd2, 'PRODUCT_ATTRIBUTE', 2);
                system.debug('Config data Fields:'+confData2);
                lstConfigDataToSave.add(confData2);
            }
            if(selectedDoc1 != null && selectedDoc1 != 'None')
            {
                SVMXC__ServiceMax_Config_Data__c confData3 = new SVMXC__ServiceMax_Config_Data__c();
                confData3 = fillingConfData(selectedDoc1, 'DOCUMENT_ATTRIBUTE', 1);
                lstConfigDataToSave.add(confData3);
            }
            if(selectedDoc2 != null && selectedDoc2 != 'None')
            {
                SVMXC__ServiceMax_Config_Data__c confData4 = new SVMXC__ServiceMax_Config_Data__c();
                confData4 = fillingConfData(selectedDoc2, 'DOCUMENT_ATTRIBUTE', 2);
                lstConfigDataToSave.add(confData4);
            }
            if(selectedDoc3 != null && selectedDoc3 != 'None')
            {
                SVMXC__ServiceMax_Config_Data__c confData5 = new SVMXC__ServiceMax_Config_Data__c();
                confData5 = fillingConfData(selectedDoc3, 'DOCUMENT_ATTRIBUTE', 3);
                lstConfigDataToSave.add(confData5);
            }
            
            if(lstConfigDataToSave != null && lstConfigDataToSave.size() >0){
				//insert lstConfigDataToSave;
				if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfigDataToSave, COMM_SecurityUtils.Access.Createable)){
					insert lstConfigDataToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
				}
				else{
					throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
				}
			}
            queryConfDataProcess();
            preparingPickLists();
        }
    }
    
    public SVMXC__ServiceMax_Config_Data__c fillingConfData(string fieldName, string confType, integer seq)
    {
        SVMXC__ServiceMax_Config_Data__c tempConf = new SVMXC__ServiceMax_Config_Data__c();
        tempConf.SVMXC__Field_Name__c = fieldName;
        tempConf.SVMXC__Sequence__c = seq;
        tempConf.SVMXC__Dispatch_Process__c = FulfillmentProcess.Id;
        tempConf.RecordTypeId = Rtype_Prod_Doc_Attributes.Id;
        tempConf.SVMXC__Configuration_Type__c = confType;
        //Neeraj(March-12th): Added to save more information.
        if(confType == 'DOCUMENT_ATTRIBUTE')
        {
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            objfieldMap = SVMXC__RMA_Shipment_Order__c.SObjectType.getDescribe().fields.getMap();
            for (String fieldKey : objfieldMap.keySet()) 
            {
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(f.getName() == fieldName)
                {
                    tempConf.SVMXC__Display_Type__c = f.getType().name();
                    if(f.getType().name().ToUpperCase() == 'REFERENCE') 
                    {
                        tempConf.SVMXC__Field_Relationship_Name__c = f.getRelationshipName();
                        List<Schema.sObjectType> schema1 = new List<Schema.sObjectType>();
                        schema1 = f.getReferenceTo();
                        tempConf.SVMXC__Object_Name__c = string.valueOf(schema1[0]);
                        if(schema1[0] == Account.SObjectType)
                            tempConf.SVMXC__FKey_Name_Field__c = 'Name';
                        else
                        {   
                            Map<String,Schema.SObjectField> R = schema1[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                    tempConf.SVMXC__FKey_Name_Field__c = f1.getName();
                            }
                        }
                    }
                }
            }
        }
        else if(confType == 'PRODUCT_ATTRIBUTE')
        {
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            objfieldMap = Product2.SObjectType.getDescribe().fields.getMap();
            for (String fieldKey : objfieldMap.keySet()) 
            {
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(f.getName() == fieldName)
                {
                    tempConf.SVMXC__Display_Type__c = f.getType().name();
                    if(f.getType().name().ToUpperCase() == 'REFERENCE') 
                    {
                        tempConf.SVMXC__Field_Relationship_Name__c = f.getRelationshipName();
                        List<Schema.sObjectType> schema1 = new List<Schema.sObjectType>();
                        schema1 = f.getReferenceTo();
                        tempConf.SVMXC__Object_Name__c = string.valueOf(schema1[0]);
                        if(schema1[0] == Account.SObjectType)
                            tempConf.SVMXC__FKey_Name_Field__c = 'Name';
                        else
                        {   
                            Map<String,Schema.SObjectField> R = schema1[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                    tempConf.SVMXC__FKey_Name_Field__c = f1.getName();

                                break;
                            }
                        }
                    }
                }
            }
        }
        return tempConf;
    }
    
    public void validation()
    {
        if(FulfillmentProcess.Name__c == null || FulfillmentProcess.Name__c =='')
        {
            validate = false;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG071()));
        }
        if(FulfillmentProcess.ProcessID__c == null || FulfillmentProcess.ProcessID__c =='' || FulfillmentProcess.ProcessID__c.length() < 8)
        {
            validate = false;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG072()));
        }
        if(Mode != 'Clone')
        {
            List<SVMXC__ServiceMax_Processes__c> lstProcessRecs_UniquenessCheck = new List<SVMXC__ServiceMax_Processes__c>();
            String tempProcessId = FulfillmentProcess.SVMXC__ProcessID__c;
            lstProcessRecs_UniquenessCheck = [Select Id from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = :tempProcessId AND RecordType.Name = 'Fulfillment Process']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstProcessRecs_UniquenessCheck != null && lstProcessRecs_UniquenessCheck.size() > 0)
            {
                if((FulfillmentProcess.get('Id') == null) || (lstProcessRecs_UniquenessCheck[0].Id  != FulfillmentProcess.get('Id')))
                {
                    validate = false;
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG073()));
                }
            }
        }
        else
        {
            FulfillmentProcess.SVMXC__ProcessID__c = FulfillmentProcess.SVMXC__ProcessID__c + system.now();
        }
        if(selectedPOExpr != null && selectedPOExpr != 'None' && (FulfillmentProcess.SVMXC__Parent_Error_Msg__c == null || FulfillmentProcess.SVMXC__Parent_Error_Msg__c == ''))
        {
            validate = false;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG078()));
        }
        if(selectedPOLineExpr != null && selectedPOLineExpr != 'None' && (FulfillmentProcess.SVMXC__Child_Error_Msg__c == null || FulfillmentProcess.SVMXC__Child_Error_Msg__c == ''))
        {
            validate = false;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG079()));
        }
        if(doCheckFulfillmentRule && lstFulfillmentPathRules.size() == 0)
        {
            validate = false;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, system.label.CONF028_TAG077));
        }
    }
    
    public void saveExp()
    {
        if(renderPOExprBlock && POExp !=null && POExp.SVMXC__IsStandard__c == false)
        {
            if(POExp.SVMXC__Name__c == null || POExp.SVMXC__Name__c == '')
            {
                validate = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG074()));
            }
            if(POExp.SVMXC__ProcessID__c == null || POExp.SVMXC__ProcessID__c == '' || (POExp.SVMXC__ProcessID__c != null && (POExp.SVMXC__ProcessID__c.length() < 8)))
            {
                validate = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG075()));
            }
            if(LstPOCriteria == null || (LstPOCriteria != null && !(LstPOCriteria.size() > 0)))
            {
                validate = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG076()));
            }
            if(validate != false)
            {
                submitExp(POExp, LstPOCriteria);
                selectedPOExpr = POExp.Id;
            }
        }
        if(renderPOLineExprBlock && POLineExp!=null && POLineExp.SVMXC__IsStandard__c == false && validate != false)
        {
            if(POLineExp.SVMXC__Name__c == null || POLineExp.SVMXC__Name__c == '')
            {
                validate = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG074()));
            }
            if(POLineExp.SVMXC__ProcessID__c == null || POLineExp.SVMXC__ProcessID__c == '' || (POLineExp.SVMXC__ProcessID__c != null && (POLineExp.SVMXC__ProcessID__c.length() < 8)))
            {
                validate = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG075()));
            }
            if(LstPOLineCriteria == null || !(LstPOLineCriteria.size() > 0))
            {
                validate = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG076()));
            }
            if(validate != false)
            {
                submitExp(POLineExp, LstPOLineCriteria);
                selectedPOLineExpr = POLineExp.Id;
            }
        }
    }
    
    public void submitExp(SVMXC__ServiceMax_Processes__c Exp, List<SVMXC__Servicemax_Config_Data__c> LstCriteria)
    {
        List<SFM_WrapperDef.SFM_Expression> lstSFMExpression = new List<SFM_WrapperDef.SFM_Expression>();
        Exp.SVMXC__SettingId__c = Exp.SVMXC__ProcessId__c; 
        lstSFMExpression.add(new SFM_WrapperDef.SFM_Expression(Exp, LstCriteria));
        system.debug('Lst SFM Exprssions: ' + lstSFMExpression);
        SFM_WrapperDef.SFM_Request_Expression expressionRequest = new SFM_WrapperDef.SFM_Request_Expression(lstSFMExpression);
        system.debug('Request: ' + expressionRequest);
        SVMXC.SFM_saveExpression SaveExpressionObj = new SVMXC.SFM_saveExpression();
        SFM_WrapperDef.SFM_Response saveResponse = new SFM_WrapperDef.SFM_Response();
        saveResponse = SaveExpressionObj.SFM_saveExpression(expressionRequest);
        system.debug('Response: ' + saveResponse + ' and Response Success: ' + saveResponse.success);
        if(saveResponse == null || (saveResponse != null && saveResponse.success == false))
        {
            validate = false;
            if(saveResponse != null && saveResponse.message !=null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, saveResponse.message, ''));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG077(), ''));
            return;
        }
    }
    
    public void newPathRule()
    {
        fulfillmentPathRule = new SVMXC__ServiceMax_Processes__c();
        IsNewPathRule = true;
        renderPathRuleDetails = true;
        renderProdExprBlock = false;
        renderProdExpViewEdit = false;
        selectedProdExpr = 'None';
        SelectedParentDepot = 'All';
        SelectedDepotsOptns.clear();
        AvailableDepotOptns.clear();
        for(SelectOption option: lstfulFillmentLocs)
        {
            if(option.getValue() != 'None')
                AvailableDepotOptns.add(option);
        }
        AvailableDepotOptns = sortingSelectOption(AvailableDepotOptns);
        if(lstFulfillmentPathRules != null && lstFulfillmentPathRules.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c Pro : lstFulfillmentPathRules)
                Pro.SVMXC__Select__c = false;
        }
        fulfillmentPathRule.SVMXC__Sequence__c = lstFulfillmentPathRules.size()+1;
    }
    
    public pageReference editPathRule()
    {
        integer count = 0;
        IsNewPathRule = false;
        if(lstFulfillmentPathRules != null && lstFulfillmentPathRules.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c tempPro : lstFulfillmentPathRules)
            {
                if(tempPro.SVMXC__Select__c == true)
                {
                    fulfillmentPathRule = tempPro;
                    count++;
                }
            }
        }
        if(count > 1 || count == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG068(), ''));
            return null;
        }
        else
        {
            renderPathRuleDetails = true;
            if(fulfillmentPathRule.SVMXC__Submodule__c != null)
                selectedProdExpr = fulfillmentPathRule.SVMXC__Submodule__c;
            if(selectedProdExpr != null && selectedProdExpr != 'None')
                renderProdExpViewEdit = true;
            
            queryConfDataPathRule();
            SelectedDepotsOptns.clear();
            if(LstConfigRecs_SelectedLocations != null && LstConfigRecs_SelectedLocations.size() > 0)
            {
                Set<String> tempSlctOptns = new Set<String>();
                for(SVMXC__ServiceMax_Config_Data__c tempConf: LstConfigRecs_SelectedLocations)
                {
                    SelectedDepotsOptns.add(new SelectOption(tempConf.SVMXC__Location__c, tempConf.SVMXC__Location__r.Name));
                    tempSlctOptns.add(tempConf.SVMXC__Location__c);
                }
                List<SelectOption> tempSlctLst = new List<SelectOption>();
                for(SelectOption tempAvalSlctLst : AvailableDepotOptns)
                {
                    if(tempSlctOptns.contains(tempAvalSlctLst.getValue()))
                        continue;
                    tempSlctLst.add(new SelectOption(tempAvalSlctLst.getValue(), tempAvalSlctLst.getLabel()));
                }
                AvailableDepotOptns.clear();
                AvailableDepotOptns.addAll(tempSlctLst);
            }
        }
        return null;
    }
    
    public void queryConfDataPathRule()
    {
        LstConfigRecs_SelectedLocations.clear();
        LstConfigRecs_SelectedLocations = [Select Id, SVMXC__Sequence__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Dispatch_Process__c, SVMXC__IsDefault__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: fulfillmentPathRule.Id AND RecordType.Name = 'Fulfillment Path' AND SVMXC__Location__c != NULL AND SVMXC__Dispatch_Process__c != null Order By SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
            
    public pageReference deletePathRule()
    {
        ///tab3Msg = false;
        Integer count = 0;
        Boolean isDefaultRule = false;
        if(lstFulfillmentPathRules != null && lstFulfillmentPathRules.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c tempPro : lstFulfillmentPathRules)
            {
                if(tempPro.SVMXC__Select__c == true)
                {
                    fulfillmentPathRule = tempPro;
                    count++;
                }
                if(tempPro.SVMXC__Select__c  && tempPro.SVMXC__IsDefault__c)
                     isDefaultRule = true;
            }        
        }
        if(count > 1 || count == 0)
        {
            //tab3Msg = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG068(), ''));
            return null;
        }
        else if(isDefaultRule)
        {
            //tab3Msg = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.CONF028_TAG078, ''));
            return null;
            
        }
        else
        {
            LstConfigRecs_SelectedLocations.clear();
            LstConfigRecs_SelectedLocations = [Select Id, SVMXC__Sequence__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Dispatch_Process__c, SVMXC__IsDefault__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: fulfillmentPathRule.Id AND RecordType.Name = 'Fulfillment Path' AND SVMXC__Location__c != NULL AND SVMXC__Dispatch_Process__c != null Order By SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(LstConfigRecs_SelectedLocations != null && LstConfigRecs_SelectedLocations.size() > 0)
                delete LstConfigRecs_SelectedLocations; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            delete fulfillmentPathRule; //SDL-SVMX-DELETE-FLS-ENFORCED
            LstConfigRecs_SelectedLocations.clear();
            
            lstFulfillmentPathRules.clear();
            lstFulfillmentPathRules = [Select Id, SVMXC__Name__c, RecordTypeId, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Rule_Type__c, SVMXC__Parent_Column_Name__c, SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__IsDefault__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: FulfillmentProcess.Id AND SVMXC__Process__c!= null AND RecordType.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'FulFillment Path' order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            for(integer l = 1; l <= lstFulfillmentPathRules.size(); l++)
                lstFulfillmentPathRules[l-1].SVMXC__Sequence__c = l;
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstFulfillmentPathRules, COMM_SecurityUtils.Access.Updateable ) ) {
                lstFulfillmentPathRules[0].SVMXC__IsDefault__c = true;
                update lstFulfillmentPathRules; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }            
            
            if(lstFulfillmentPathRules.size() < 2)
                disableRuleSeqBtn = true;
            if(lstFulfillmentPathRules.size() == 0)
                disableRuleViewDelBtn = true;
        }
        IsNewPathRule = false;
        return null;
    }
    public PageReference SVMX_setDefaultSourcingRule()
    {
        list<SVMXC__ServiceMax_Processes__c> lstForUpdate = new list<SVMXC__ServiceMax_Processes__c>();
        //tab3Msg = false;
        if(lstFulfillmentPathRules.size() > 0)
        {
            Integer a = 0;
            for(integer i = 0;i<lstFulfillmentPathRules.size();i++)
            {
                if(lstFulfillmentPathRules[i].SVMXC__select__c)
                    a++;
                if(a == 2)
                    break;      
            }
            if(a > 1 || a == 0)
            {
                //tab3Msg = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG070(), ''));
                return null;
            }
            for(integer i = 0;i<lstFulfillmentPathRules.size();i++)
            {
                if(lstFulfillmentPathRules[i].SVMXC__select__c)
                {
                    lstFulfillmentPathRules[i].SVMXC__IsDefault__c =true;
                    lstFulfillmentPathRules[i].SVMXC__Select__c = false;
                    lstForUpdate.add(lstFulfillmentPathRules[i]);
                }
                else 
                {
                    lstFulfillmentPathRules[i].SVMXC__IsDefault__c =false;
                    lstForUpdate.add(lstFulfillmentPathRules[i]);
                }
            }
            if(lstForUpdate.size() > 0)
                update lstForUpdate; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        return null;
    }
    public void savePathRule()
    {
        doCheckFulfillmentRule = false;
        validate = true;
        save();
        if(validate == true)
            validatePathRule();
        if(validate == true)
            saveProdExp();
        
        if(validate == true)
        {
            if(selectedProdExpr != 'None' && selectedProdExpr != null)
                fulfillmentPathRule.SVMXC__Submodule__c = selectedProdExpr;
            else
                fulfillmentPathRule.SVMXC__Submodule__c = null;
            fulfillmentPathRule.SVMXC__Process__c = FulfillmentProcess.Id;
            /* if(fulfillmentPathRule.Id != null)
                fulfillmentPathRule.SVMXC__Sequence__c = lstFulfillmentPathRules.size() + 1; */
            fulfillmentPathRule.RecordTypeId = Rtype_NamedExpression.Id;
            fulfillmentPathRule.SVMXC__Rule_Type__c = 'FulFillment Path';
            system.debug('lstFulfillmentPathRules:'+lstFulfillmentPathRules.size());
            //upsert fulfillmentPathRule;
			if(COMM_SecurityUtils.getInstance().verifyFieldAccess(fulfillmentPathRule, COMM_SecurityUtils.Access.Upsertable)){
				upsert fulfillmentPathRule; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			}
			else{
				throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
			}
			
            system.debug('Fulfillment details:'+fulfillmentPathRule);
            if(fulfillmentPathRule.SVMXC__IsDefault__c == true)
            {
                lstFulfillmentPathRules.clear();
                lstFulfillmentPathRules = [Select Id, SVMXC__Name__c, RecordTypeId, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Rule_Type__c, SVMXC__Parent_Column_Name__c, SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__IsDefault__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: FulfillmentProcess.Id AND SVMXC__Process__c!= null AND RecordType.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'FulFillment Path' order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                if(lstFulfillmentPathRules != null && lstFulfillmentPathRules.size() > 0)
                {
                    for(SVMXC__ServiceMax_Processes__c Pro : lstFulfillmentPathRules)
                    {
                        if(Pro.Id == fulfillmentPathRule.Id)
                            continue;
                        Pro.SVMXC__IsDefault__c = false;
                    }
                }
            }
            
            if(lstFulfillmentPathRules != null && lstFulfillmentPathRules.size() > 0)
            {
                for(integer l = 1; l<= lstFulfillmentPathRules.size(); l++)
                {
                    //lstFulfillmentPathRules[l-1].SVMXC__Sequence__c = l;
                    lstFulfillmentPathRules[l-1].SVMXC__Select__c = false;
                }
            }
            
            // Defect BAC-2335 - Before performing security check, we shall check if list has value or not. 
            if(lstFulfillmentPathRules != null && lstFulfillmentPathRules.size() > 0){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstFulfillmentPathRules, COMM_SecurityUtils.Access.Updateable ) ) {
                    lstFulfillmentPathRules[0].SVMXC__IsDefault__c = true;
                    update lstFulfillmentPathRules; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            
            lstFulfillmentPathRules.clear();
            lstFulfillmentPathRules = [Select Id, SVMXC__Name__c, RecordTypeId, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Rule_Type__c, SVMXC__Parent_Column_Name__c, SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__IsDefault__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: FulfillmentProcess.Id AND SVMXC__Process__c!= null AND RecordType.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'FulFillment Path' order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
            if(lstFulfillmentPathRules.size() == 1)
            {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstFulfillmentPathRules, COMM_SecurityUtils.Access.Updateable ) ) {
                    lstFulfillmentPathRules[0].SVMXC__IsDefault__c = true;
                    update lstFulfillmentPathRules; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }   
            if(lstFulfillmentPathRules.size() < 2)
                disableRuleSeqBtn = true;
            if(lstFulfillmentPathRules.size() == 0)
                disableRuleViewDelBtn = true;
            
            if(LstConfigRecs_SelectedLocations != null && LstConfigRecs_SelectedLocations.size() > 0)
                delete LstConfigRecs_SelectedLocations; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            LstConfigRecs_SelectedLocations.clear();
                
            if(SelectedDepotsOptns != null && SelectedDepotsOptns.size() > 0)
            {
                for(integer l=1; l <= SelectedDepotsOptns.size(); l++)
                {
                    SVMXC__ServiceMax_Config_Data__c tempConf = new SVMXC__ServiceMax_Config_Data__c();
                    tempConf.SVMXC__Location__c = string.ValueOf(SelectedDepotsOptns[l-1].getvalue());
                    tempConf.SVMXC__Dispatch_Process__c = fulfillmentPathRule.Id;
                    tempConf.SVMXC__Sequence__c = l;
                    tempConf.RecordTypeId = Rtype_FulFillmentLocation.Id;
                    lstConfigDataToSave.add(tempConf);
                }
            }
            if(lstConfigDataToSave != null && lstConfigDataToSave.size() > 0){
				//upsert lstConfigDataToSave;
				if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfigDataToSave, COMM_SecurityUtils.Access.Upsertable)){
					upsert lstConfigDataToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
				}
				else{
					throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
				}
			}
            if(lstConfigData_ToDelete != null && lstConfigData_ToDelete.size() > 0)
                delete lstConfigData_ToDelete; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstConfigData_ToDelete.clear();
            queryConfDataPathRule();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, getTAG064(), ''));
            IsNewPathRule = false;
        }
    }
    
    public void validatePathRule()
    {
        if(fulfillmentPathRule.SVMXC__Name__c == null || fulfillmentPathRule.SVMXC__Name__c.length() == 0)
        {
            validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG069(), ''));
        }
        
        if(SelectedDepotsOptns == null || SelectedDepotsOptns.size() == 0)
        {
            validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG092(), ''));
        }
        
        List<SVMXC__ServiceMax_Processes__c> tempLst_UniquenessCheck = new List<SVMXC__ServiceMax_Processes__c>();
        String tempProName = fulfillmentPathRule.SVMXC__Name__c;
        if(IsNewPathRule)
            tempLst_UniquenessCheck = [Select Id, SVMXC__Name__c, RecordTypeId, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Rule_Type__c, SVMXC__Parent_Column_Name__c, SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__IsDefault__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: FulfillmentProcess.Id AND SVMXC__Process__c!= null AND RecordType.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'FulFillment Path' AND SVMXC__Name__c = :tempProName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        else
            tempLst_UniquenessCheck = [Select Id, SVMXC__Name__c, RecordTypeId, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Rule_Type__c, SVMXC__Parent_Column_Name__c, SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__IsDefault__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: FulfillmentProcess.Id AND SVMXC__Process__c!= null AND RecordType.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'FulFillment Path' AND SVMXC__Name__c = :tempProName AND id !=: fulfillmentPathRule.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
        if(tempLst_UniquenessCheck != null && tempLst_UniquenessCheck.size() > 0)
        {
            if((fulfillmentPathRule.get('Id') == null) || (tempLst_UniquenessCheck[0].Id  != fulfillmentPathRule.get('Id')))
            {
                validate = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG012()));
            }
        }
        
    }
    
    public void saveProdExp()
    {
        if(renderProdExprBlock && ProdExp != null && ProdExp.SVMXC__IsStandard__c == false)
        {
            if(ProdExp.SVMXC__Name__c == null || ProdExp.SVMXC__Name__c == '')
            {
                validate = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG074()));
            }
            if(ProdExp.SVMXC__ProcessID__c == null || ProdExp.SVMXC__ProcessID__c == '' || (ProdExp.SVMXC__ProcessID__c != null && (ProdExp.SVMXC__ProcessID__c).length() < 8))
            {
                validate = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG075()));
            }
            if(LstProdCriteria == null || (LstProdCriteria != null && !(LstProdCriteria.size() > 0)))
            {
                validate = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG076()));
            }
            if(validate != false)
            {
                submitExp(ProdExp, LstProdCriteria);
                selectedProdExpr = ProdExp.Id;
            }
        }
    }
    
    public void cancelPathRule()
    {
        renderPathRuleDetails = false;
    }
    
    //-------------------------------------- Method for on Change of Prod Expression --------------------------------------------------------
    public void OnChangeProdExpr()
    {
        if(selectedProdExpr != 'None')
            renderProdExpViewEdit = true;
        else
            renderProdExpViewEdit = false;
        renderProdExprBlock = false;
    }
    
    //-------------------------------------- Method to View/Edit of Prod Expression --------------------------------------------------------
    public void ViewEditProdCriteria()
    {
        renderProdExprBlock = true;
        if(selectedProdExpr != 'None')
        {
            Id selectedHdrId = (Id)selectedProdExpr;
            if(mapProdExpRec.containsKey(selectedHdrId) && mapProdExp_DetailRec.containsKey(selectedHdrId))
            {
                ProdExp = mapProdExpRec.get(selectedHdrId);
                LstProdCriteria = mapProdExp_DetailRec.get(selectedHdrId);
            }
        }
    }
    
    //-------------------------------------- Method to create a new Prod Expression --------------------------------------------------------
    public void CreateNewProdCriteria()
    {
        selectedProdExpr = 'None';
        renderProdExprBlock = true;
        renderProdExpViewEdit = false;
        ProdExp = new SVMXC__ServiceMax_Processes__c(RecordTypeId = Rtype_NamedExpression.Id, SVMXC__Rule_Type__c = 'Named Expression', SVMXC__Source_Object_Name__c = 'Product2');
        LstProdCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
        ProdCriteria_AddRow();
    }
    
    //-------------------------------------- Method to delete Row in the Details of Prod Criteria --------------------------------------------------------
    public void ProdCriteria_DelRow()
    {
        if((LstProdCriteria == null || (LstProdCriteria != null && !(LstProdCriteria.size() > 0))) && SelectedRow != null)
            return;
        Integer tempDeletedIndex = Integer.valueOf(SelectedRow) - 1;
        if(LstProdCriteria[tempDeletedIndex] != null && LstProdCriteria[tempDeletedIndex].get('Id') != null)
            lstConfigData_ToDelete.add(LstProdCriteria[tempDeletedIndex]);
        List<SVMXC__ServiceMax_Config_Data__c> lstTempConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c HeaderCriteriaRec: LstProdCriteria)
        {
            if(HeaderCriteriaRec.SVMXC__Sequence__c == Integer.valueOf(SelectedRow))
                continue;
            lstTempConfigData.add(HeaderCriteriaRec);
        }
        LstProdCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(lstTempConfigData != null && lstTempConfigData.size() > 0)
        {
            LstProdCriteria.addAll(lstTempConfigData);
            for(integer i=0; i< LstProdCriteria.size(); i++)
                LstProdCriteria[i].SVMXC__Sequence__c = i + 1;
        }
    }
    
    //-------------------------------------- Method to add Row in the Details of Prod Criteria --------------------------------------------------------
    public void ProdCriteria_AddRow()
    {
        LstProdCriteria.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = LstProdCriteria.size() + 1, RecordTypeId = Rtype_expressions.Id));
    }
    
    public void PopulateAvailableDepots()
    {
        AvailableDepotOptns.clear();
        Set<string> tempSetDepots = new Set<string>();
        for(SelectOption SlctdDepot :SelectedDepotsOptns)
            tempSetDepots.add(SlctdDepot.getValue());
        system.debug('Selected Depot:'+SelectedParentDepot+'::'+tempSetDepots);
        
        /* if(SelectedParentDepot != null && SelectedParentDepot != 'All' && mapParentDepotId_slctlstChildDepots != null && mapParentDepotId_slctlstChildDepots.containsKey(SelectedParentDepot) && mapParentDepotId_slctlstChildDepots.get(SelectedParentDepot) != null)
        {
            AvailableDepotOptns = mapParentDepotId_slctlstChildDepots.get(SelectedParentDepot);
            List<SelectOption> tempAvailDepotSelectOptns = new List<SelectOption>();
            for(SelectOption AvailableDepotOption : AvailableDepotOptns)
            {
                if(tempSetDepots.contains(AvailableDepotOption.getValue()))
                    continue;
                tempAvailDepotSelectOptns.add(new SelectOption(AvailableDepotOption.getValue(), AvailableDepotOption.getLabel()));
            }
            AvailableDepotOptns.clear();
            AvailableDepotOptns = tempAvailDepotSelectOptns;
        } */
        //Neeraj(March-15th): Commented the above code of if condition and now querying the list of Child Depot for the selected Depot
        if(SelectedParentDepot != null && SelectedParentDepot.length() > 0 && SelectedParentDepot != 'All')
        {
            List<SVMXC__Site__c> LstChildDepot = new List<SVMXC__Site__c>();
            LstChildDepot = [Select Id, Name, SVMXC__Parent__c, SVMXC__IsGood_Stock__c, SVMXC__Parent__r.Name from SVMXC__Site__c where RecordType.Name = 'Depot Child' AND SVMXC__Parent__c =: SelectedParentDepot AND SVMXC__Parent__r.RecordType.Name = 'Depot' AND SVMXC__IsGood_Stock__c = true Order By Name];
            AvailableDepotOptns.clear();
            for(SVMXC__Site__c Loc : LstChildDepot)
            {
                if(!tempSetDepots.contains(Loc.Id))
                    AvailableDepotOptns.add(new SelectOption(Loc.Id, Loc.Name));
            }   
        }
        else if(SelectedParentDepot != null && SelectedParentDepot == 'All')
        {
            AvailableDepotOptns.clear();
            for(SelectOption option: lstfulFillmentLocs)
            {
                if(option.getValue() != 'None' && tempSetDepots.contains(option.getValue()) == false)
                    AvailableDepotOptns.add(option);
            }
        }
    }
    
    public void Depots_MoveRight()
    {
        Set<String> setAvailableDepotsSlctd = new Set<String>();
        setAvailableDepotsSlctd.addAll(availableDepotsSelctd);

        //Addition to right
        for(String AvailDepotId :availableDepotsSelctd)
            SelectedDepotsOptns.add(new SelectOption(AvailDepotId, mapChildDepotId_Name.get(AvailDepotId)));
        //Removal from left
        List<SelectOption> tempOptnsList = new List<SelectOption>();
        for(integer i=0;i<AvailableDepotOptns.size();i++)
        {
            if(setAvailableDepotsSlctd.contains(AvailableDepotOptns[i].getValue()))
                continue;
            tempOptnsList.add(AvailableDepotOptns[i]);
        }
        AvailableDepotOptns.clear();
        if(tempOptnsList != null && tempOptnsList.size() > 0)
            AvailableDepotOptns.addAll(tempOptnsList);
    }
    
    public void Depots_MoveLeft()
    {
        Set<String> setSelectedDepotsSlctd = new Set<String>();
        setSelectedDepotsSlctd.addAll(selectedDepotsSelctd);

        //Addition to left
        for(String SelectedDepotId_Slctd :selectedDepotsSelctd)
            AvailableDepotOptns.add(new SelectOption(SelectedDepotId_Slctd, mapChildDepotId_Name.get(SelectedDepotId_Slctd)));
        //Removal from right
        List<SelectOption> tempOptnsList = new List<SelectOption>();
        for(integer i=0;i<SelectedDepotsOptns.size();i++)
        {
            if(setSelectedDepotsSlctd.contains(SelectedDepotsOptns[i].getValue()))
                continue;
            tempOptnsList.add(SelectedDepotsOptns[i]);
        }
        SelectedDepotsOptns.clear();
        if(tempOptnsList != null && tempOptnsList.size() > 0)
            SelectedDepotsOptns.addAll(tempOptnsList);
    }
    
    public void TopLoc()
    {
        if(SelectedDepotsOptns != null && SelectedDepotsOptns.size() > 1 && selectedDepotsSelctd != null && selectedDepotsSelctd.size() > 0)
        {
            List<SelectOption> tempLstSelctdDepotsOptnsTOP = new List<SelectOption>();
            List<SelectOption> tempLstSelctdDepotsOptns = new List<SelectOption>();
            Set<String> setSelectedDepotsSlctd = new Set<String>();
            setSelectedDepotsSlctd.addAll(selectedDepotsSelctd);
            for(SelectOption SlctdDepot :SelectedDepotsOptns)
            {
                if(setSelectedDepotsSlctd.contains(SlctdDepot.getValue()))
                    tempLstSelctdDepotsOptnsTOP.add(SlctdDepot);
                else
                    tempLstSelctdDepotsOptns.add(SlctdDepot);
            }
            if(tempLstSelctdDepotsOptns != null && tempLstSelctdDepotsOptns.size()>0)
                tempLstSelctdDepotsOptnsTOP.addAll(tempLstSelctdDepotsOptns);
            SelectedDepotsOptns.clear();
            SelectedDepotsOptns.addAll(tempLstSelctdDepotsOptnsTOP);
        }
    }
    
    public void UpLoc()
    {
        if(SelectedDepotsOptns != null && SelectedDepotsOptns.size() > 1 && selectedDepotsSelctd != null && selectedDepotsSelctd.size() > 0)
        {
            List<String> setAllSelectedDepotsOptns = new List<String>();
            for(SelectOption SlctdDepot :SelectedDepotsOptns)
                setAllSelectedDepotsOptns.add(SlctdDepot.getValue());
            Set<String> setSelectedDepotsSlctd = new Set<String>();
            setSelectedDepotsSlctd.addAll(selectedDepotsSelctd);
            for(integer l=0; l < SelectedDepotsOptns.size(); l++)
            {
                if(setSelectedDepotsSlctd.contains(setAllSelectedDepotsOptns[l]))
                {
                    if(l > 0)
                    {
                        selectOption tempoption = SelectedDepotsOptns[l-1];
                        SelectedDepotsOptns[l-1] = SelectedDepotsOptns[l];
                        SelectedDepotsOptns[l] = tempoption;
                    }
                }
            }
        }
    }
    
    public void DownLoc()
    {
        if(SelectedDepotsOptns != null && SelectedDepotsOptns.size() > 1 && selectedDepotsSelctd != null && selectedDepotsSelctd.size() > 0)
        {
            List<String> setAllSelectedDepotsOptns = new List<String>();
            for(SelectOption SlctdDepot :SelectedDepotsOptns)
                setAllSelectedDepotsOptns.add(SlctdDepot.getValue());
            Set<String> setSelectedDepotsSlctd = new Set<String>();
            setSelectedDepotsSlctd.addAll(selectedDepotsSelctd);
            for(integer l= (SelectedDepotsOptns.size()-1); l >= 0; l--)
            {
                if(setSelectedDepotsSlctd.contains(setAllSelectedDepotsOptns[l]))
                {
                    if(l < (SelectedDepotsOptns.size()-1))
                    {
                        selectOption tempoption = SelectedDepotsOptns[l+1];
                        SelectedDepotsOptns[l+1] = SelectedDepotsOptns[l];
                        SelectedDepotsOptns[l] = tempoption;
                    }
                }
            }
        }
    }
    
    public void BottomLoc()
    {
        if(SelectedDepotsOptns != null && SelectedDepotsOptns.size() > 1 && selectedDepotsSelctd != null && selectedDepotsSelctd.size() > 0)
        {
            List<SelectOption> tempLstSelctdDepotsOptnsTOP = new List<SelectOption>();
            List<SelectOption> tempLstSelctdDepotsOptns = new List<SelectOption>();
            Set<String> setSelectedDepotsSlctd = new Set<String>();
            setSelectedDepotsSlctd.addAll(selectedDepotsSelctd);
            for(SelectOption SlctdDepot :SelectedDepotsOptns)
            {
                if(setSelectedDepotsSlctd.contains(SlctdDepot.getValue()))
                    tempLstSelctdDepotsOptnsTOP.add(SlctdDepot);
                else
                    tempLstSelctdDepotsOptns.add(SlctdDepot);
            }
            if(tempLstSelctdDepotsOptnsTOP != null && tempLstSelctdDepotsOptnsTOP.size()>0)
                tempLstSelctdDepotsOptns.addAll(tempLstSelctdDepotsOptnsTOP);
            SelectedDepotsOptns.clear();
            SelectedDepotsOptns.addAll(tempLstSelctdDepotsOptns);
        }
    }
    
    //---------------------------------------------------------- Rule Sequence----------------------------------------------------------------
    public List<SVMXC__ServiceMax_Processes__c> TempRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SelectOption> Seqoptions = new List<SelectOption>();
    public Map<string,Integer> StrIntMap = new Map<string,Integer>();
    public string[] items = new String[]{};
    public string[] getitems(){return items;}
    public void setitems(string[] o){this.items=o;}
    public boolean renderSeqPopup = false;
    public integer IntSelIndex = 0;
    public boolean IsUpAction = false;
    public boolean IsDownAction = false;
    public boolean IsTopAction = false;
    public boolean IsBottomAction = false;
    public boolean getrenderSeqPopup(){return renderSeqPopup;}
    
    //--------------------------------------------------------- Rule Sequence Method ------------------------------------------------
    public void ruleSequence()
    {
        TempRuleLst.clear();
        TempRuleLst.addAll(lstFulfillmentPathRules);
        renderSeqPopup = true;
    }
    
    //--------------------------------------------- Method to display Rule list for sequence changes ------------------------------------------
    public List<SelectOption> getSeqoptions()
    { 
        Seqoptions = new List<SelectOption>();   
        if (TempRuleLst.Size() >0)
        {
            for(SVMXC__ServiceMax_Processes__c s:TempRuleLst)
            {                
                if (s.SVMXC__Name__c != null)
                Seqoptions.add(new SelectOption(s.Id,s.SVMXC__Name__c));
            }
        }  
        return Seqoptions; 
    }
    
    //-------------------------------------------------------------------- shuffle Method ------------------------------------------------
    public void shuffle(integer IntSelIndex, boolean isTop )
    {
        SVMXC__ServiceMax_Processes__c temp;
        if(isTop)
        {
          temp = TempRuleLst[IntSelIndex];
          for(integer j=IntSelIndex;j>0;j--)
          {
            TempRuleLst[j] = TempRuleLst[j-1];
          }
          TempRuleLst[0] = temp;
        }
        else 
        {
          temp = TempRuleLst[IntSelIndex];
          for(integer j=IntSelIndex;j<TempRuleLst.size()-1;j++)
          {
            TempRuleLst[j] = TempRuleLst[j+1];
          }
          TempRuleLst[TempRuleLst.size()-1] = temp;
        }
    }
    public void UP()
    { 
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempRuleLst.size();j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i]==TempRuleLst[0].Id)
                {
                    TempRuleLst[j] = TempRuleLst[j];
                    break;
                }
                else if(items[i]==TempRuleLst[j].Id)
                {
                    temp = TempRuleLst[j]; 
                    TempRuleLst[j] = TempRuleLst[j-1];
                    TempRuleLst[j-1]=temp;     
                    IntSelIndex = j;
                    IsUpAction = true;
                    IsDownAction=false;
                    IsTopAction=false;
                    IsBottomAction=false;
                    TempRuleLst[IntSelIndex-1].SVMXC__Sequence__c=IntSelIndex-1;
                    TempRuleLst[IntSelIndex].SVMXC__Sequence__c = IntSelIndex;
                }
            }
        }
    }
    public void Down()
    {  
        SVMXC__ServiceMax_Processes__c temp;
        for(integer i=0;i<items.size();i++)
        {
          StrIntMap.Put(items[i],i);
        }
        for(integer i=0;i<items.size();i++)
        {
            for(integer k=0;k<TempRuleLst.size()-1;k++)
            {
                if(items[i]==TempRuleLst[k].Id)
                {
                    temp = TempRuleLst[k];
                    TempRuleLst[k] = TempRuleLst[k+1];
                    TempRuleLst[k+1]=temp;
                    IntSelIndex = k;
                    IsUpAction = false;
                    IsDownAction=true;
                    IsTopAction=false;
                    IsBottomAction=false;
                    TempRuleLst[IntSelIndex+1].SVMXC__Sequence__c=IntSelIndex+1;
                    TempRuleLst[IntSelIndex].SVMXC__Sequence__c = IntSelIndex;
                    break;       
                }
            }
        } 
    }
    public void Top()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempRuleLst.size()-1;j>0;j--)
        {
            for(integer i=items.size()-1;i>=0;i--)
            {
                if(items[i] == TempRuleLst[j].Id)
                {
                    IntSelIndex = j;
                    IsUpAction = false;
                    IsDownAction=false;
                    IsTopAction=true;
                    IsBottomAction=false;
                    shuffle(IntSelIndex, true);     
                }
            }
        }  
    }
    public void Bottom()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempRuleLst.size()-1;j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i] == TempRuleLst[j].Id)
                {
                    IntSelIndex = j;
                    IsUpAction = false;
                    IsDownAction=false;
                    IsTopAction=false;
                    IsBottomAction=true;     
                    shuffle(IntSelIndex, false); 
                }
            }
        }  
    }
    //--------------------------------------------------------- Method to save Rule Sequences ---------------------------------------------------------
    public pagereference SVMX_SaveSequence()
    {
        SVMXC__ServiceMax_Processes__c temp;
        double t;
        if(IsUpAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            if(mode != 'Clone')
                update TempRuleLst; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(IsDownAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            if(mode != 'Clone')
                update TempRuleLst; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(IsTopAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            if(mode != 'Clone')
                update TempRuleLst; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(IsBottomAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            if(mode != 'Clone')
                update TempRuleLst; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        lstFulfillmentPathRules.clear();
        lstFulfillmentPathRules.addAll(TempRuleLst);
        renderSeqPopup = false;
        return null;  
    }
    
    public pagereference SVMX_PopupCancel()
    {
        renderSeqPopup = false;
        return null;
    }
    
    public string getHLPURL() {return system.label.CONF028_HLPURL;}
    public string getTAG001() {return system.label.CONF028_TAG017;} //'Setup Fulfillment Process'
    public string getTAG002() {return system.label.CONF028_TAG018;} //'Quick Save'
    public string getTAG003() {return system.label.CONF028_TAG019;} //'Save & Close'
    public string getTAG004() {return system.label.CONF028_TAG020;} //'cancel'
    public string getTAG005() {return system.label.CONF028_TAG021;} //'General Info'
    public string getTAG006() {return system.label.CONF028_TAG007;} //'Process Name'
    public string getTAG007() {return system.label.CONF028_TAG006;} //'Process Id'
    public string getTAG008() {return system.label.CONF028_TAG008;} //'Description'
    public string getTAG009() {return system.label.CONF028_TAG022;} //'Fulfillment UI Attributes'
    public string getTAG010() {return system.label.CONF028_TAG023;} //'What to show from Document, Capture 3 fields here'
    public string getTAG011() {return system.label.CONF028_TAG024;} //'Choose up to 2 product fields to show for each line'
    public string getTAG012() {return system.label.CONF028_TAG073;} //'Please enter a unique Path Rule Name'
    public string getTAG015() {return system.label.CONF028_TAG025;} //'Criteria and Mapping'
    public string getTAG016() {return system.label.CONF028_TAG026;} //'Use the expression-builder below, indicate how header records qualify to complete fulfillment'
    public string getTAG017() {return system.label.CONF028_TAG027;} //'Select criteria'
    public string getTAG018() {return system.label.CONF028_TAG028;} //'View/Edit'
    public string getTAG019() {return system.label.CONF028_TAG029;} //'Create New'
    public string getTAG020() {return system.label.CONF028_TAG030;} //'Expression Name'
    public string getTAG021() {return system.label.CONF028_TAG031;} //'Expression Id'
    public string getTAG022() {return system.label.CONF028_TAG032;} //'Rule Sequence'
    public string getTAG023() {return system.label.CONF028_TAG033;} //'Field Name'
    public string getTAG024() {return system.label.CONF028_TAG034;} //'Operator'
    public string getTAG025() {return system.label.CONF028_TAG035;} //'Value'
    public string getTAG026() {return system.label.CONF028_TAG036;} //'Advanced Expression'
    public string getTAG027() {return system.label.CONF028_TAG037;} //'Error Message to display if a record does not meet the above criteria'
    public string getTAG028() {return system.label.CONF028_TAG038;} //'Use the expression-builder below, indicate how line records qualify to complete fulfillment'
    public string getTAG029() {return system.label.CONF028_TAG039;} //'Configure Mapping to create Fulfillment order'
    public string getTAG030() {return system.label.CONF028_TAG040;} //'Use this mapping definition to create Fulfillment Order'
    public string getTAG031() {return system.label.CONF028_TAG041;} //'Use this mapping definition to create Fulfillment Order Lines'
    public string getTAG032() {return system.label.CONF028_TAG001;} //'Processing....'
    public string getTAG033() {return system.label.CONF028_TAG042;} //'Fulfillment Path'
    public string getTAG034() {return system.label.CONF028_TAG043;} //'Fulfillment Path Rules'
    public string getTAG035() {return system.label.CONF028_TAG010;} //'New'
    public string getTAG036() {return system.label.CONF028_TAG012;} //'Delete'
    public string getTAG037() {return system.label.CONF028_TAG044;} //'Sequence'
    public string getTAG038() {return system.label.CONF028_TAG005;} //'Select'
    public string getTAG039() {return system.label.CONF028_TAG045;} //'Rule Name'
    public string getTAG040() {return system.label.CONF028_TAG046;} //'Default Location'
    public string getTAG041() {return system.label.CONF028_TAG047;} //'Last modified on'
    public string getTAG042() {return system.label.CONF028_TAG048;} //'Default Rule'
    public string getTAG043() {return system.label.CONF028_TAG049;} //'Save'
    public string getTAG044() {return system.label.CONF028_TAG050;} //'Criteria to identify sourcing path'
    public string getTAG045() {return system.label.CONF028_TAG051;} //'--None--'
    public string getTAG047() {return system.label.COMM002_TAG006;} //'Equals'
    public string getTAG048() {return system.label.COMM002_TAG007;} //'Not Equal'
    public string getTAG049() {return system.label.COMM002_TAG008;} //'Greater Than'
    public string getTAG050() {return system.label.COMM002_TAG009;} //'Greater or Equal To'
    public string getTAG051() {return system.label.COMM002_TAG010;} //'Less Than'
    public string getTAG052() {return system.label.COMM002_TAG011;} //'Less or Equal To'
    public string getTAG053() {return system.label.COMM002_TAG012;} //'Starts With'
    public string getTAG054() {return system.label.COMM002_TAG013;} //'Contains'
    public string getTAG055() {return system.label.COMM002_TAG014;} //'Does Not Contain'
    public string getTAG056() {return system.label.COMM002_TAG015;} //'Includes'
    public string getTAG057() {return system.label.COMM002_TAG016;} //'Excludes'
    public string getTAG058() {return system.label.COMM002_TAG022;} //'Is Null'
    public string getTAG059() {return system.label.COMM002_TAG023;} //'Is Not Null'
    public string getTAG060() {return system.label.CONF028_TAG042;} //'Sourcing Path'
    public string getTAG061() {return system.label.CONF028_TAG048;} //'Default'
    public string getTAG062() {return system.label.CONF028_TAG053;} //'Fulfillment Path Rule'
    public string getTAG063() {return system.label.CONF028_TAG054;} //'--All--'
    public string getTAG064() {return system.label.CONF028_TAG055;} //'Process saved successfully'
    public string getTAG065() {return system.label.CONF028_TAG056;} //'Select Parent Depot'
    public string getTAG066() {return system.label.CONF028_TAG057;} //'Available Good Stock Location(s)'
    public string getTAG067() {return system.label.CONF028_TAG058;} //'Selected Location(s)'
    public string getTAG068() {return system.label.CONF028_TAG015;} //'Please select only one process to perform this operation'
    public string getTAG069() {return system.label.CONF028_TAG060;} //'Please enter a valid fulfillment Path Rule Name'
    public string getTAG070() {return system.label.CONF028_TAG061;} //'Please select one Default Fulfillment Path'
    public string getTAG071() {return system.label.CONF028_TAG062;} //'Please enter a valid Process Name'
    public string getTAG072() {return system.label.CONF028_TAG063;} //'Please enter a valid Process ID and length must be atleast 8 characters long'
    public string getTAG073() {return system.label.CONF028_TAG064;} //'Please enter a unique process id'
    public string getTAG074() {return system.label.CONF028_TAG065;} //'Please enter a valid Expression Name'
    public string getTAG075() {return system.label.CONF028_TAG066;} //'Please enter a valid Expression ID and must be atleast 8 character long'
    public string getTAG076() {return system.label.CONF028_TAG067;} //'Enter atleast one valid line in criteria'
    public string getTAG077() {return system.label.CONF028_TAG068;} //'Saving of expression failed. Please contact ServiceMax administrator'
    public string getTAG078() {return system.label.CONF028_TAG069;} //'Please Enter a error messsage if Parts Order does not meet the criteria defined'
    public string getTAG079() {return system.label.CONF028_TAG070;} //'Please Enter a error messsage if Parts Order Line does not meet the criteria defined'
    public string getTAG080() {return system.label.CONF028_TAG071;} //'This RMA/Order does not meet the Fulfillment criteria'
    public string getTAG081() {return system.label.CONF028_TAG072;} //'None of the lines in this RMA/Order meet the fulfillment criteria'
    public String getTAG082() {return system.label.COMM002_TAG032;}//'Add Row'
    public String getTAG083() {return system.label.COMM002_TAG033;}//'Delete Row'
    public String getTAG084() {return system.label.COMM001_TAG036;}//'Add'
    public String getTAG085() {return system.label.COMM001_TAG037;}//'Remove'
    public String getTAG086() {return system.label.COMM001_TAG060;}//'Top'
    public String getTAG087() {return system.label.COMM001_TAG061;}//'Up'
    public String getTAG088() {return system.label.COMM001_TAG062;}//'Down'
    public String getTAG089() {return system.label.COMM001_TAG063;}//'Bottom'
    public String getTAG090() {return system.label.COMM001_TAG064;}//'Help'
    public String getTAG091() {return system.label.CONF028_TAG074;}//'Error Message to display if no records meet the above criteria'
    public String getTAG092() {return system.label.CONF028_TAG075;}//'Please select atleast one location as Selected Location'
    
}