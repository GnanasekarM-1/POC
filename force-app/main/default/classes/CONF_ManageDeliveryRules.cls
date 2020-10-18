public with sharing class CONF_ManageDeliveryRules
{
    /**************** Global veriables with getter sester ****************/
    public string recordId;
    public string retURL;
    public string retBtnTxt;
    public string SelIndex { get; set; }
    public String SelectedHub{ get; set; }
    public String DefaultDeliveryLoc{get; set;}
    public String strObjNameSelected{ get; set; }
    public String selectedRuleLineId{ get; set; }
    public Integer deliveryRuleSelIndex { get; set; }
    public String delRuleRecId = '';
    public Integer CurrentEditLine_SeqNo;
    public boolean IsdisableValue = false;
    public boolean renderOnlyRule{get; set;}
    public boolean renderForSelectedDepot{get; set;}
    public boolean disableNewEditDel{get; set;}
    public boolean IsNewRule{get; set;}
    public boolean DisplayRuleInfo = false;
    public boolean DisplayRuleLineInfo = false;
    public boolean getDisplayRuleInfo(){return DisplayRuleInfo;}
    public boolean getDisplayRuleLineInfo(){return DisplayRuleLineInfo;}
    public boolean getIsdisableValue(){return this.IsdisableValue;}
    
    public List<SelectOption> OperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getOperatorSelectLst(){ return OperatorSelectLst; }
    public List<SelectOption> slctLstSelect_Hub = new List<SelectOption>();//All Depots without delivery rules
    public List<SelectOption> getslctLstSelect_Hub(){ return slctLstSelect_Hub;}
    public List<SelectOption> AccProdSelectLst = new List<SelectOption>();
    public List<SelectOption> getAccProdSelectLst(){ return AccProdSelectLst;}
    public List<SelectOption> slctLstDelLocs = new List<SelectOption>();
    public List<SelectOption> getslctLstDelLocs(){ return slctLstDelLocs;}
    public List<SelectOption> slctLstDeliveryRuleFldNames = new List<SelectOption>();
    public List<SelectOption> getslctLstDeliveryRuleFldNames(){ return slctLstDeliveryRuleFldNames;}
    
    public List<SVMXC__ServiceMax_Processes__c> DeliveryRulesLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getDeliveryRulesLst(){ return DeliveryRulesLst; }
    public void setDeliveryRulesLst(List<SVMXC__ServiceMax_Processes__c> val){ this.DeliveryRulesLst = val; }
    public List<SVMXC__ServiceMax_Processes__c> DeliveryRuleLineRecsLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getDeliveryRuleLineRecsLst(){return DeliveryRuleLineRecsLst; }
    public SVMXC__ServiceMax_Processes__c DeliveryRuleRec {get; set;}
    public SVMXC__ServiceMax_Processes__c deliveryRuleLineRec { get; set; }
    
    public SFM_Utils ObjName_util = new SFM_Utils();
    
    public Set<Id> setLocationIds = new Set<Id>(); 
    //public Map<String, SObjectField> mapTargetObjFieldMap_Account;
    //public Map<String, SObjectField> mapTargetObjFieldMap_Product;
    public MAP<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
    public Map<String, Schema.SObjectField> fieldsDetailObj_tab7 = new Map<String,Schema.SObjectField>();
    public Map<Id, SVMXC__ServiceMax_Processes__c> mapIdDeliveryRuleLineRec = new Map<Id, SVMXC__ServiceMax_Processes__c>();
    //public Map<Id, String> mapLocIdName = new Map<Id,String>();
    public Map<String, List<SelectOption>> mapObjectNamelstFieldSlctOptn = new Map<String, List<SelectOption>>();
    public Map<String, List<SelectOption>> mapObjectNamelstFieldSlctOptnForEdit = new Map<String, List<SelectOption>>();
    public Map<String,Map<String,String>> mapObjName_mapFldsUpper_Orignal = new Map<String,Map<String,String>>();
    public Map<Integer, SVMXC__ServiceMax_Processes__c> mapSeq_DelRuleLineRec = new Map<Integer,SVMXC__ServiceMax_Processes__c>(); 
    public Map<Integer, List<ObjExpressionWrapper>> mapSeq_DelRuleLineExpressionRecs = new Map<Integer,List<ObjExpressionWrapper>>();

    public RecordType RType_HeaderDeliveryRule;
    public RecordType RType_DeliveryRule;
    public RecordType RType_FieldMapping;
    public RecordType RType_expressions;
    
    /*************** getter method to get highest seq number for delivery rule line ********************/
    public Integer DeliveryRuleLineshighestSequenceNumber { get { return DeliveryRuleLineRecsLst.size();} }
    public Integer DeliveryRuleExprhighestSequenceNumber{ get { return RuleLineWrapObjLst.size();} }
    
    public List<ObjExpressionWrapper> RuleLineWrapObjLst { get; set; }
    
    //---------------------------------------------------- Constructor/Onload -------------------------------------------------------------------------
    public CONF_ManageDeliveryRules()
    {
        //----------------------------------------------- query for record type --------------------------------------------------
        RType_DeliveryRule = [Select Id, Name from RecordType WHERE SObjectType='SVMXC__ServiceMax_Processes__c' AND Name = 'SVMX Rule' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RType_HeaderDeliveryRule = [Select Id, Name from RecordType WHERE SObjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'Delivery Rule' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RType_FieldMapping = [Select Id, Name from RecordType WHERE SObjectType='SVMXC__ServiceMax_Config_Data__c' AND Name = 'Field Mapping' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        //------------------------------------------------- Querying all the Delivery Rules ------------------------------------------------
        DeliveryRulesLst = [Select Id, SVMXC__Select__c, SVMXC__Sequence__c, LastModifiedBy.Name, SVMXC__Name__c, SVMXC__Description__c, SVMXC__APL_Allow_Partial_Delivery__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Location__r.Id, SVMXC__Type__c ,SVMXC__Default_Location__c , SVMXC__Default_Location__r.Name, SVMXC__Advance_Expression__c, SVMXC__IsStandard__c, LastModifiedDate  from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Delivery Rule' AND SVMXC__Location__c != NULL order by SVMXC__Location__r.Name]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    
    renderForSelectedDepot = false;
    disableNewEditDel = false;
    IsNewRule = false;
    
        renderOnlyRule = false;
        recordId = System.currentPageReference().getParameters().get('SVMX_RecordId');
        retURL = System.currentPageReference().getParameters().get('SVMX_RetURL');
        
        if(retURL == null || retURL.contains('CONF_SetupHome'))
            retBtnTxt = system.label.CONF023_TAG127;
        else
        {
            retBtnTxt = system.label.CONF026_TAG038;
            renderOnlyRule = true;
        }
    if(recordId != null && recordId != '' && recordId.length() > 0)
    {
      if(DeliveryRulesLst != null && DeliveryRulesLst.size() >0)
      {
        for(SVMXC__ServiceMax_Processes__c pro: DeliveryRulesLst)
        {
          if(pro.SVMXC__Location__r.Id == recordId)
          {
            delRuleRecId = pro.Id;
            DeliveryRuleRec = pro;
          }
        }
        if(delRuleRecId != null && delRuleRecId != '' && delRuleRecId.length()>0)
          editRule();
        else
        {
          CreateNewDeliveryRule();
        }
      }
      else
      {
        CreateNewDeliveryRule();
      }
    }
    
        //------------------ Operator list -----------------------------
        OperatorSelectLst.add(new SelectOption('SVMX.NONE',getTAG046()));
        OperatorSelectLst.add(new SelectOption('eq',getTag131()));
        OperatorSelectLst.add(new SelectOption('ne',getTag132()));
        OperatorSelectLst.add(new SelectOption('gt',getTag133()));
        OperatorSelectLst.add(new SelectOption('ge',getTag134()));
        OperatorSelectLst.add(new SelectOption('lt',getTag135()));
        OperatorSelectLst.add(new SelectOption('le',getTag136()));
        OperatorSelectLst.add(new SelectOption('starts',getTag137()));
        OperatorSelectLst.add(new SelectOption('contains',getTag138()));
        OperatorSelectLst.add(new SelectOption('notcontain',getTag139()));
        OperatorSelectLst.add(new SelectOption('in',getTag140()));
        OperatorSelectLst.add(new SelectOption('notin',getTag141()));
        OperatorSelectLst.add(new SelectOption('isnull',getTag142()));
        OperatorSelectLst.add(new SelectOption('isnotnull',getTag143()));
        
        RuleLineWrapObjLst = new List<ObjExpressionWrapper>();
        for(SVMXC__ServiceMax_Processes__c DeliveryRuleRec: DeliveryRulesLst)
            //mapLocIdName.put(DeliveryRuleRec.SVMXC__Location__c, DeliveryRuleRec.SVMXC__Location__r.Name);
      setLocationIds.add(DeliveryRuleRec.SVMXC__Location__c);
        
        //mapTargetObjFieldMap_Account = allObjs.get('Account').getDescribe().fields.getMap();
        //mapTargetObjFieldMap_Product = allObjs.get('Product2').getDescribe().fields.getMap();
        
        //-------------------- Object List ----------------------------
        AccProdSelectLst.add(new SelectOption('SVMX.NONE',getTAG046()));
        AccProdSelectLst.add(new SelectOption('Account',getTag016()));
        AccProdSelectLst.add(new SelectOption('Product2',getTag017()));
        
        //string accObjNameLabel = '';
        //string prodObjNameLabel = '';
        
        //----------------------------------- Account fields list ----------------------------------------
        
        
        
        List<SelectOption> AccSelectOption = new List<SelectOption>();
        AccSelectOption = getAllFields('Account');
        
        List<SelectOption> ProdSelectOption = new List<SelectOption>();
        ProdSelectOption = getAllFields('Product2');
        
        
        mapObjectNamelstFieldSlctOptn.put('Account', AccSelectOption);
        mapObjectNamelstFieldSlctOptn.put('Product2', ProdSelectOption);
        
        //Neeraj(April-17th-2012): Created duplicate map to save all the fields name in upper case. This is done because of handling defect no.:004201 without changing the script.
        for(system.SelectOption strCurrentField : AccSelectOption)
        {
            if(mapObjName_mapFldsUpper_Orignal.containsKey('Account'))
            {
                mapObjName_mapFldsUpper_Orignal.get('Account').put(strCurrentField.getValue().toUpperCase(),strCurrentField.getValue());
            }
            else
            {
                mapObjName_mapFldsUpper_Orignal.put('Account', new Map<string,string>());
                mapObjName_mapFldsUpper_Orignal.get('Account').put(strCurrentField.getValue().toUpperCase(),strCurrentField.getValue());
            }
            strCurrentField.setValue(strCurrentField.getValue().toUpperCase());
        }
        mapObjectNamelstFieldSlctOptnForEdit.put('Account', AccSelectOption);
        
        for(system.SelectOption strCurrentField : ProdSelectOption)
        {
            if(mapObjName_mapFldsUpper_Orignal.containsKey('Product2'))
                mapObjName_mapFldsUpper_Orignal.get('Product2').put(strCurrentField.getValue().toUpperCase(),strCurrentField.getValue());
            else
            {
                mapObjName_mapFldsUpper_Orignal.put('Product2', new Map<string,string>());
                mapObjName_mapFldsUpper_Orignal.get('Product2').put(strCurrentField.getValue().toUpperCase(),strCurrentField.getValue());
            }
            strCurrentField.setValue(strCurrentField.getValue().toUpperCase());
        }
        mapObjectNamelstFieldSlctOptnForEdit.put('Product2', ProdSelectOption);
        // The map created above, will be used to edit Rule Line details section.
        
        String ObjSelected_deliveryRuleExp = ObjName_util.getOriginalAPIName('Account', allObjs);
      /*   if( ObjSelected_deliveryRuleExp != null && allObjs.get(ObjSelected_deliveryRuleExp) != null )
        {
            fieldsDetailObj_tab7 = allObjs.get(ObjSelected_deliveryRuleExp).getDescribe().fields.getmap();
             List<SelectOption> AccSelectOption = new List<SelectOption>();
            AccSelectOption.add(new selectOption('SVMX.NONE',getTAG046())); 
            for(String FieldApiName :fieldsDetailObj_tab7.keyset())
            {
                Schema.DescribeFieldResult FieldDescribeResult = fieldsDetailObj_tab7.get(FieldApiName).getdescribe();
                if(FieldDescribeResult != null && FieldDescribeResult.isAccessible() && FieldDescribeResult.isCreateable() && FieldDescribeResult.isUpdateable())
                    AccSelectOption.add(new selectOption(FieldApiName, fieldsDetailObj_tab7.get(FieldApiName).getDescribe().getLabel()));
            }
            mapObjectNamelstFieldSlctOptn.put('Account', AccSelectOption);
        }
     */
        //----------------------------------- Product fields list ----------------------------------------
        ObjSelected_deliveryRuleExp = ObjName_util.getOriginalAPIName('Product2', allObjs);
        /* if( ObjSelected_deliveryRuleExp != null && allObjs.get(ObjSelected_deliveryRuleExp) != null )
        {
            fieldsDetailObj_tab7 = allObjs.get(ObjSelected_deliveryRuleExp).getDescribe().fields.getmap();
            List<SelectOption> ProdSelectOption = new List<SelectOption>();
            ProdSelectOption.add(new selectOption('SVMX.NONE',getTAG046()));
            for(String FieldApiName :fieldsDetailObj_tab7.keyset())
            {
                Schema.DescribeFieldResult FieldDescribeResult = fieldsDetailObj_tab7.get(FieldApiName).getdescribe();
                if(FieldDescribeResult != null && FieldDescribeResult.isAccessible() && FieldDescribeResult.isCreateable() && FieldDescribeResult.isUpdateable())
                    ProdSelectOption.add(new selectOption(FieldApiName, fieldsDetailObj_tab7.get(FieldApiName).getDescribe().getLabel()));
            }
            mapObjectNamelstFieldSlctOptn.put('Product2', ProdSelectOption);
        } */
    }
    
    //--- method for getting fields  -- without isFilter fields
    public List<SelectOption> getAllFields(string ObjName)
    {
        List<SelectOption> TempObjFields = new  List<SelectOption>();
        Map<String, Schema.SObjectType> allobjmap = new Map<String, Schema.SObjectType>();
        Map<String, Schema.SObjectField> LfieldsMap = new Map<String, Schema.SObjectField>(); 
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : allObjs.values())
        {
            allobjmap.put(s.getDescribe().getName(),s);
        }
        TempObjFields.add(new SelectOption('SVMX.NONE',getTAG046()));
        if(ObjName != null && ObjName.length() > 0 && ObjName != '--None--' && ObjName != 'SVMX.NONE')
        {
            Schema.DescribeSObjectResult objDesc = allobjmap.get(ObjName).getDescribe(); 
            LfieldsMap = objDesc.fields.getMap();
            for(String s : LfieldsMap.keyset())
            {
                if(LfieldsMap.get(s).getDescribe().isFilterable() )
                {
                    TempObjFields.add(new SelectOption(LfieldsMap.get(s).getDescribe().getName(),LfieldsMap.get(s).getDescribe().getLabel()));
                }
            }
            TempObjFields = sortingSelectOption(TempObjFields);
        }
        return TempObjFields;
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
    
    
    /*************** On change method for change in object in Object Name picklist in expression block ********************/
    public pagereference onchangeObjectName()
    {
        for(ObjExpressionWrapper WrapObj : RuleLineWrapObjLst)
        {
            if(WrapObj.ExpressionRec.SVMXC__Sequence__c == deliveryRuleSelIndex)
            {
                strObjNameSelected = WrapObj.ExpressionRec.SVMXC__Object_Name2__c;
                if( strObjNameSelected == null || strObjNameSelected.startswith('SVMX.NONE'))
                {
                    WrapObj.ObjectFields.clear();
                    return null;
                }
                else
                {
                    String ObjSelected_deliveryRuleExp = ObjName_util.getOriginalAPIName(strObjNameSelected, allObjs);
                    if( ObjSelected_deliveryRuleExp != null && allObjs.get(ObjSelected_deliveryRuleExp) != null )
                    {
                        WrapObj.ObjectFields = new List<SelectOption>();
                        if(mapObjectNamelstFieldSlctOptn.get(strObjNameSelected) != null)
                        {
                            WrapObj.ObjectFields.addAll(mapObjectNamelstFieldSlctOptn.get(strObjNameSelected));
                            break;
                        }
                    }
                }
            }
        }
        return null;
    }
    
    /*************** Method to populate Rule AND Hubs on Edit ********************/
    public pagereference populateRuleANDHubsOnEdit()
    {
        IsdisableValue = true;
        SVMXC__ServiceMax_Processes__c TempDeliveryRule = new SVMXC__ServiceMax_Processes__c();
        integer count = 0;
        for(SVMXC__ServiceMax_Processes__c DelRuleRec: DeliveryRulesLst)
        {
            if(DelRuleRec.SVMXC__Select__c)
            {
                count += 1;
                TempDeliveryRule = DelRuleRec;
            }
        }
        if(count != 1 || TempDeliveryRule == null || (TempDeliveryRule != null && TempDeliveryRule.get('Id') == null))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag010(),''));
            return null;
        }
        delRuleRecId = TempDeliveryRule.Id;
        DeliveryRuleRec = TempDeliveryRule;
    editRule();
    disableNewEditDel = false;
    DisplayRuleLineInfo = false;
    IsNewRule = false;
        return null;
    }
    
  public void Cancel_DeliveryRuleLine()
  {
    if(delRuleRecId != null && delRuleRecId != '')
    {
        DeliveryRuleLineRecsLst.clear();
        DeliveryRuleLineRecsLst = [Select Id, SVMXC__Sequence__c, SVMXC__Select__c , SVMXC__Name__c, SVMXC__Description__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Type__c, SVMXC__Advance_Expression__c, SVMXC__Default_Location__c, SVMXC__IsStandard__c  From SVMXC__ServiceMax_Processes__c  Where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Delivery Rule Line' AND SVMXC__Module__c = :delRuleRecId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    disableNewEditDel = false;
    DisplayRuleLineInfo = false;
    RuleLineWrapObjLst.clear();
    
    /* if(IsNewRule == false)
      populateRuleANDHubsOnEdit();
    else
    {
      disableNewEditDel = false;
      DisplayRuleLineInfo = false;
      DeliveryRuleLineRecsLst.clear();
      RuleLineWrapObjLst.clear();
    } */
  }
  
  public void editRule()
  {
        slctLstSelect_Hub = new List<SelectOption>();
        slctLstSelect_Hub.add(new SelectOption('SVMX.NONE',getTAG046()));        
        slctLstSelect_Hub.add(new SelectOption(DeliveryRuleRec.SVMXC__Location__c, DeliveryRuleRec.SVMXC__Location__r.Name));
        if(DeliveryRuleRec.Location__c != null)
          renderForSelectedDepot = true;
    
        if(delRuleRecId != null && delRuleRecId != '')
            DeliveryRuleLineRecsLst = [Select Id, SVMXC__Sequence__c, SVMXC__Select__c , SVMXC__Name__c, SVMXC__Description__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Type__c, SVMXC__Advance_Expression__c, SVMXC__Default_Location__c, SVMXC__IsStandard__c  From SVMXC__ServiceMax_Processes__c  Where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Delivery Rule Line' AND SVMXC__Module__c = :delRuleRecId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    
    mapSeq_DelRuleLineRec.clear();
        if(DeliveryRuleLineRecsLst != null && DeliveryRuleLineRecsLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c TempObj : DeliveryRuleLineRecsLst)
                mapSeq_DelRuleLineRec.put(Integer.valueOf(TempObj.SVMXC__Sequence__c), TempObj);
        }
        
        mapIdDeliveryRuleLineRec = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        mapIdDeliveryRuleLineRec.putAll(DeliveryRuleLineRecsLst);
        populateDeliveryLocations();
        DisplayRuleInfo = true;
        
        Set<Id> setdeliveryRuleLineRecId = new Set<Id>();
        if(mapIdDeliveryRuleLineRec == null)
            return;
    
        setdeliveryRuleLineRecId.addAll(mapIdDeliveryRuleLineRec.keyset());
        List<SVMXC__ServiceMax_Config_Data__c> ExpressionLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(setdeliveryRuleLineRecId != null)
        {
            ExpressionLst = [Select Id, SVMXC__Sequence__c, SVMXC__Object_Name__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Rule__c, SVMXC__Expression_Rule__r.SVMXC__Sequence__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN : setdeliveryRuleLineRecId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        for(SVMXC__ServiceMax_Config_Data__c ExpressionLineRec : ExpressionLst)
        {
            List<ObjExpressionWrapper> lstExprWrapperObj = new List<ObjExpressionWrapper>();
            if(mapSeq_DelRuleLineExpressionRecs.containsKey(Integer.valueOf(ExpressionLineRec.SVMXC__Expression_Rule__r.SVMXC__Sequence__c)))
                lstExprWrapperObj = mapSeq_DelRuleLineExpressionRecs.get(Integer.valueOf(ExpressionLineRec.SVMXC__Expression_Rule__r.SVMXC__Sequence__c));
            List<SelectOption> TempFieldLst = new List<SelectOption>();
            TempFieldLst = mapObjectNamelstFieldSlctOptn.get(ExpressionLineRec.SVMXC__Object_Name2__c);
            ObjExpressionWrapper TempObjectExprWrprObj = new ObjExpressionWrapper(ExpressionLineRec,TempFieldLst);
            lstExprWrapperObj.add(TempObjectExprWrprObj);
            mapSeq_DelRuleLineExpressionRecs.put(Integer.valueOf(ExpressionLineRec.SVMXC__Expression_Rule__r.SVMXC__Sequence__c), lstExprWrapperObj);
        }
  }
  
    /*************** Method to populate Default Delivery Locations ********************/
    public pagereference populateDeliveryLocations()
    {
        List<SVMXC__Site__c> lstDeliveryLocRecs = new List<SVMXC__Site__c>();
        if(DeliveryRuleRec == null) return null;
        SelectedHub = DeliveryRuleRec.SVMXC__Location__c;
        if(SelectedHub == null) return null;
        lstDeliveryLocRecs = [Select Id, Name, SVMXC__IsDefault_Delivery__c from SVMXC__Site__c where RecordType.Name = 'Depot Child' AND SVMXC__Parent__c = :SelectedHub AND SVMXC__IsDelivery_Location__c = true ORDER BY Name];
        slctLstDelLocs = new List<SelectOption>();
        for(SVMXC__Site__c ChildLocationRec: lstDeliveryLocRecs)
        {
            slctLstDelLocs.add(new SelectOption(ChildLocationRec.Id, ChildLocationRec.Name));
            if(ChildLocationRec.SVMXC__IsDefault_Delivery__c)
            {
                if(DeliveryRuleRec.get('Id') == null)
                {
                    DeliveryRuleRec.SVMXC__Default_Location__c = ChildLocationRec.Id;
                    DeliveryRuleRec.SVMXC__Name__c = ChildLocationRec.Name + ' Delivery Rule';
                }
            }
        }
        return null;
    }
    
    /*************** Method to edit Rule line ********************/
    public pagereference editRuleLine()
    {
        integer count = 0;
        string strDeliveryRuleId = null;
        for(SVMXC__ServiceMax_Processes__c DelRuleLineRec: DeliveryRuleLineRecsLst)
        {
            if(DelRuleLineRec.SVMXC__Select__c)
            {
                count += 1;
                deliveryRuleLineRec = DelRuleLineRec;
                strDeliveryRuleId = DelRuleLineRec.id;
            }
        }
        if(count != 1 || strDeliveryRuleId == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag010(),''));
            return null;
        }
        
        List<SVMXC__ServiceMax_Config_Data__c> TempExpressionLst;
        system.debug('Test123'+strDeliveryRuleId);
        if(strDeliveryRuleId != null && strDeliveryRuleId.length() > 0)
        {
            TempExpressionLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            TempExpressionLst = [Select Id, SVMXC__Sequence__c, SVMXC__Object_Name__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Rule__c, SVMXC__Expression_Rule__r.SVMXC__Sequence__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: strDeliveryRuleId ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            //ObjExpressionWrapper TempWrapObj;
            RuleLineWrapObjLst = new List<ObjExpressionWrapper>();
            for(SVMXC__ServiceMax_Config_Data__c TempExpObj : TempExpressionLst)
            {
                ObjExpressionWrapper TempWrapObj = new ObjExpressionWrapper();
                TempWrapObj.ExpressionRec = TempExpObj;
                //Neeraj(April-17th-2012): Converted the fields name in upper case. This is done because of handling defect no.:004201 without changing the script.
                if(TempWrapObj != null && TempWrapObj.ExpressionRec != null && TempWrapObj.ExpressionRec.SVMXC__Field_Name__c != null)
                    TempWrapObj.ExpressionRec.SVMXC__Field_Name__c = TempExpObj.SVMXC__Field_Name__c.toUpperCase();
                /*if(mapObjectNamelstFieldSlctOptn.get(string.valueOf(TempExpObj.SVMXC__Object_Name2__c)) != null)
                    TempWrapObj.ObjectFields.addAll(mapObjectNamelstFieldSlctOptn.get(string.valueOf(TempExpObj.SVMXC__Object_Name2__c)));*/
               
               if(mapObjectNamelstFieldSlctOptnForEdit.get(string.valueOf(TempExpObj.SVMXC__Object_Name2__c)) != null)
                    TempWrapObj.ObjectFields.addAll(mapObjectNamelstFieldSlctOptnForEdit.get(string.valueOf(TempExpObj.SVMXC__Object_Name2__c)));     
                RuleLineWrapObjLst.add(TempWrapObj);
            }
        }
    
       /*  if( CurrentEditLine_SeqNo != null &&  deliveryRuleLineRec != null)
        {
            mapSeq_DelRuleLineRec.put(CurrentEditLine_SeqNo, deliveryRuleLineRec);
            mapSeq_DelRuleLineExpressionRecs.put(CurrentEditLine_SeqNo, RuleLineWrapObjLst);
        }
        CurrentEditLine_SeqNo = Integer.valueOf(DeliveryRuleLineRec_local.SVMXC__Sequence__c);
        deliveryRuleLineRec = mapSeq_DelRuleLineRec.get(Integer.valueOf(DeliveryRuleLineRec_local.SVMXC__Sequence__c));
        if(mapSeq_DelRuleLineExpressionRecs.get(Integer.valueOf(DeliveryRuleLineRec_local.SVMXC__Sequence__c)) != null)
        {
            RuleLineWrapObjLst = new List<ObjExpressionWrapper>();
            RuleLineWrapObjLst.addAll(mapSeq_DelRuleLineExpressionRecs.get(Integer.valueOf(DeliveryRuleLineRec_local.SVMXC__Sequence__c)));
        } */
            
        if(RuleLineWrapObjLst == null || (RuleLineWrapObjLst != null && !(RuleLineWrapObjLst.size() > 0)))
            DeliveryRuleCriteriaAddLines();
        DisplayRuleLineInfo = true;
    disableNewEditDel = true;
        return null;
    }
      
    /*************** Method to Create new Rule ********************/
    public pagereference CreateNewDeliveryRule()
    {
        IsNewRule = true;
        disableNewEditDel = false;
        IsdisableValue = false;
        renderForSelectedDepot = false;
        DeliveryRuleRec = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RType_HeaderDeliveryRule.Id, SVMXC__IsStandard__c = false, SVMXC__Type__c = 'Manual');
        DeliveryRuleLineRecsLst = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__Site__c> AllQualifiedDepots = new List<SVMXC__Site__c>();
       
        DeliveryRulesLst.clear();
        DeliveryRulesLst = [Select Id, SVMXC__Select__c, SVMXC__Sequence__c, LastModifiedBy.Name, SVMXC__Name__c, SVMXC__Description__c, SVMXC__APL_Allow_Partial_Delivery__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Type__c ,SVMXC__Default_Location__c , SVMXC__Default_Location__r.Name, SVMXC__Advance_Expression__c, SVMXC__IsStandard__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Delivery Rule' AND SVMXC__Location__c != NULL]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        setLocationIds.clear();
        for(SVMXC__ServiceMax_Processes__c DeliveryRuleRec: DeliveryRulesLst)
            setLocationIds.add(DeliveryRuleRec.SVMXC__Location__c);
        
        AllQualifiedDepots = [Select Id, Name from SVMXC__Site__c where RecordType.Name = 'Depot' AND ID NOT IN :setLocationIds ORDER BY NAME];
        if(AllQualifiedDepots == null || AllQualifiedDepots.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag006() ,''));
            return null;
        }
         system.debug('All Depot:'+AllQualifiedDepots);
        slctLstSelect_Hub = new List<SelectOption>();
        //slctLstSelect_Hub.add(new SelectOption(‘SVMX.NONE’,getTAG046())) 
        /* BAC-3739 Error in the Reverse Logistics >> Setup Delivery Rule page.
        String value stored in Id type field, which leads to exception error */
        slctLstSelect_Hub.add(new SelectOption('',getTAG046()));
        for(SVMXC__Site__c DepotRec: AllQualifiedDepots)
            slctLstSelect_Hub.add(new SelectOption(DepotRec.Id, DepotRec.Name));
        system.debug('All available hub:'+slctLstSelect_Hub);
        if(recordId != null && recordId.length() != 0)
          DeliveryRuleRec.Location__c = recordId;
        onChangeSelectHub();
        populateDeliveryLocations();
        DisplayRuleInfo = true;
        DisplayRuleLineInfo = false;
        RuleLineWrapObjLst = new List<ObjExpressionWrapper>();
        if(recordId != null && recordId.length() != 0)
          populateDefLocs();
        return null;
    }
    
    public pagereference onChangeSelectHub()
    {
      Id SelectedHubId = DeliveryRuleRec.Location__c;
    system.debug('selected Hub Id: ' + SelectedHubId);
        List<SVMXC__Site__c> lstDeliveryLocRecs = new List<SVMXC__Site__c>();
        lstDeliveryLocRecs = [Select Id, Name from SVMXC__Site__c where RecordType.Name = 'Depot Child' AND SVMXC__Parent__c = :SelectedHubId ORDER BY Name];
        if(lstDeliveryLocRecs != null && lstDeliveryLocRecs.size() > 0 && lstDeliveryLocRecs[0].Id != null)
        {
            DeliveryRuleRec.SVMXC__Default_Location__c = lstDeliveryLocRecs[0].Id;
            populateDeliveryLocations();
        }
        slctLstDelLocs = new List<SelectOption>();
        for(SVMXC__Site__c ChildLocationRec: lstDeliveryLocRecs)
        {
            slctLstDelLocs.add(new SelectOption(ChildLocationRec.Id, ChildLocationRec.Name));
        }
        return null;
    }
    
    /*************** Method to save Delivery Rule ********************/
    public pagereference SaveDeliveryRule()
    {
        try
        {
            if(DeliveryRuleRec.SVMXC__Name__c == null || DeliveryRuleRec.SVMXC__Name__c == '')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag015(),''));
                return null;
            }
            
            string strLocName = string.valueOf(DeliveryRuleRec.SVMXC__Location__c);
            if(strLocName == 'SVMX.NONE')
                DeliveryRuleRec.SVMXC__Location__c = null;
            
            if(DeliveryRuleRec.SVMXC__Location__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag014(),''));
                return null;
            }
            if(CurrentEditLine_SeqNo != 0 && deliveryRuleLineRec != null)
            {
                if(deliveryRuleLineRec.SVMXC__Name__c == null || deliveryRuleLineRec.SVMXC__Name__c == '')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag013(),''));
                    return null;
                }
            }
            /****** If Delivery rule is valid than process... *****/
            
            if(DeleteCritConfigLst != null && DeleteCritConfigLst.size() > 0)
            {
                //delete DeleteCritConfigLst;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete DeleteCritConfigLst; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    return null;
                }
                DeleteCritConfigLst.clear();
            }
            
            DeliveryRuleRec.SVMXC__Select__c = false;
            //upsert DeliveryRuleRec;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(DeliveryRuleRec, COMM_SecurityUtils.Access.Upsertable)){
                upsert DeliveryRuleRec; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                return null;
            }
            system.debug('Test11:'+DeliveryRuleLineRecsLst);
            system.debug('Test11:'+deliveryRuleLineRec);
            integer  strRuleLineNo = -1;
            List<SVMXC__ServiceMax_Processes__c> TempRuleLineLst = new List<SVMXC__ServiceMax_Processes__c>();
            if(DeliveryRuleLineRecsLst != null && DeliveryRuleLineRecsLst.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c DelRulLineRec :DeliveryRuleLineRecsLst)
                {
                    if(DelRulLineRec.SVMXC__Select__c)
                    {
                        strRuleLineNo = integer.valueOf(DelRulLineRec.SVMXC__Sequence__c);
                        DelRulLineRec.SVMXC__Select__c = false;
                    }
                    DelRulLineRec.SVMXC__Module__c = DeliveryRuleRec.Id;
                    TempRuleLineLst.add(DelRulLineRec);
                }
                DeliveryRuleLineRecsLst.clear();
                DeliveryRuleLineRecsLst = TempRuleLineLst;
                //upsert DeliveryRuleLineRecsLst;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(DeliveryRuleLineRecsLst, COMM_SecurityUtils.Access.Upsertable)){
                    upsert DeliveryRuleLineRecsLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    return null;
                }
            }
                DeliveryRuleLineRecsLst.clear();
                DeliveryRuleLineRecsLst = [Select Id, SVMXC__Sequence__c, SVMXC__Select__c , SVMXC__Name__c, SVMXC__Description__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Type__c, SVMXC__Advance_Expression__c, SVMXC__Default_Location__c, SVMXC__IsStandard__c  From SVMXC__ServiceMax_Processes__c  Where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Delivery Rule Line' AND SVMXC__Module__c = :DeliveryRuleRec.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            string strRuleLineId = null;
            if(strRuleLineNo != -1)
            {
                strRuleLineId = [Select Id, SVMXC__Sequence__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c  Where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Delivery Rule Line' AND SVMXC__Module__c = :DeliveryRuleRec.Id AND SVMXC__Sequence__c =: strRuleLineNo].id;
            }
            List<SVMXC__ServiceMax_Config_Data__c> LstTempExpression = new List<SVMXC__ServiceMax_Config_Data__c>();
            if(RuleLineWrapObjLst != null && RuleLineWrapObjLst.size() > 0 && strRuleLineNo != -1 && strRuleLineId != null && strRuleLineId.length() > 0)
            {
                SVMXC__ServiceMax_Config_Data__c TempExpressionObj;
                ObjExpressionWrapper TempWrapObj;
                for(ObjExpressionWrapper WrapObj : RuleLineWrapObjLst)
                {
                    if(WrapObj.ExpressionRec.SVMXC__Object_Name2__c != null && WrapObj.ExpressionRec.SVMXC__Object_Name2__c != 'SVMX.NONE' && WrapObj.ExpressionRec.SVMXC__Field_Name__c != null && WrapObj.ExpressionRec.SVMXC__Field_Name__c != 'SVMX.NONE' && WrapObj.ExpressionRec.SVMXC__Operator__c != 'SVMX.NONE')
                    {
                        TempWrapObj = new ObjExpressionWrapper();
                        //Neeraj(April-17th-2012): Change the field name from upper case to original name to handle defect no. -004201.
                        if(mapObjName_mapFldsUpper_Orignal != null && mapObjName_mapFldsUpper_Orignal.containsKey(WrapObj.ExpressionRec.SVMXC__Object_Name2__c))
                        {
                            if((mapObjName_mapFldsUpper_Orignal.get(WrapObj.ExpressionRec.SVMXC__Object_Name2__c).containsKey(WrapObj.ExpressionRec.SVMXC__Field_Name__c)))
                                WrapObj.ExpressionRec.SVMXC__Field_Name__c = (mapObjName_mapFldsUpper_Orignal.get(WrapObj.ExpressionRec.SVMXC__Object_Name2__c)).get(WrapObj.ExpressionRec.SVMXC__Field_Name__c);
                        }
                        WrapObj.ExpressionRec.RecordTypeId = RType_FieldMapping.Id;
                        WrapObj.ExpressionRec.SVMXC__Expression_Rule__c = strRuleLineId;
                        WrapObj.ExpressionRec.SVMXC__Display_Type__c = '';
                        WrapObj.ExpressionRec.SVMXC__Field_Relationship_Name__c = '';
                        WrapObj.ExpressionRec.SVMXC__Object_Name__c = '';
                        WrapObj.ExpressionRec.SVMXC__FKey_Name_Field__c = '';
                        LstTempExpression.add(WrapObj.ExpressionRec);
                    }   
                }
                APL_Utils aplutls = new APL_Utils();
                LstTempExpression = fillingConfigData(LstTempExpression);
                if(LstTempExpression != null && LstTempExpression.size() > 0){
                    //upsert LstTempExpression;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(LstTempExpression, COMM_SecurityUtils.Access.Upsertable)){
                        upsert LstTempExpression; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
            }
            
            DeliveryRulesLst.clear();
            DeliveryRulesLst = [Select Id, SVMXC__Select__c, SVMXC__Sequence__c, LastModifiedBy.Name, SVMXC__Name__c, SVMXC__Description__c, SVMXC__APL_Allow_Partial_Delivery__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Type__c ,SVMXC__Default_Location__c , SVMXC__Default_Location__r.Name, SVMXC__Advance_Expression__c, SVMXC__IsStandard__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Delivery Rule' AND SVMXC__Location__c != NULL]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            setLocationIds.clear();
            for(SVMXC__ServiceMax_Processes__c DeliveryRuleRec: DeliveryRulesLst)
            {
                setLocationIds.add(DeliveryRuleRec.SVMXC__Location__c);
            }
            disableNewEditDel = false; // Added By Neeraj: To enable New button.
            DisplayRuleLineInfo = false; // Added By Neeraj: To disable the below section.
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
            return null;
        }
        //DisplayRuleInfo = false;
        //DisplayRuleLineInfo = false;
        IsNewRule = false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTag012(),''));
        return null;
    }
    
    //Added by Neeraj: Method to fill additional values in config data records.
    public list<SVMXC__ServiceMax_Config_Data__c> fillingConfigData(list<SVMXC__ServiceMax_Config_Data__c> confdataLst)
    {
        for(SVMXC__ServiceMax_Config_Data__c confdata : confdataLst)   
        {
            string ObjName = confdata.SVMXC__Object_Name2__c;
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            if(ObjName == 'Account')
                objfieldMap = Account.SObjectType.getDescribe().fields.getMap();
            if(ObjName == 'Product2')
                objfieldMap = Product2.SObjectType.getDescribe().fields.getMap();
            
            for (String fieldKey : objfieldMap.keySet()) 
            {
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(f.getName() == confdata.SVMXC__Field_Name__c)
                {
                    confdata.SVMXC__Display_Type__c = f.getType().name();
                    if(f.getType().name().ToUpperCase() == 'REFERENCE') 
                    {
                        confdata.SVMXC__Field_Relationship_Name__c = f.getRelationshipName();
                        List<Schema.sObjectType> schema1 = new List<Schema.sObjectType>();
                        schema1 = f.getReferenceTo();
                        confdata.SVMXC__Object_Name__c = string.valueOf(schema1[0]);
                        if(schema1[0] == Account.SObjectType)
                            confdata.SVMXC__FKey_Name_Field__c = 'Name';
                        else
                        {
                            Map<String,Schema.SObjectField> R = schema1[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                    confdata.SVMXC__FKey_Name_Field__c = f1.getName();
                                break;
                            }
                        }
                    }
                }
                
            }
        }
        return confdataLst;
    }
     
    
    
    public pagereference populateDefLocs()
    {
        IsdisableValue = true;
        List<SVMXC__Site__c> lstDeliveryLocRecs = new List<SVMXC__Site__c>();
        if(DeliveryRuleRec == null) return null;
        SelectedHub = DeliveryRuleRec.SVMXC__Location__c;
        if(SelectedHub == null) return null;
        
        lstDeliveryLocRecs = [Select Id, Name, SVMXC__IsDefault_Delivery__c from SVMXC__Site__c where RecordType.Name = 'Depot Child' AND SVMXC__Parent__c = :SelectedHub AND SVMXC__IsDelivery_Location__c = true ORDER BY Name];
        slctLstDelLocs = new List<SelectOption>();
        for(SVMXC__Site__c ChildLocationRec: lstDeliveryLocRecs)
        {
            slctLstDelLocs.add(new SelectOption(ChildLocationRec.Id, ChildLocationRec.Name));
            if(ChildLocationRec.SVMXC__IsDefault_Delivery__c)
            {
                if(DeliveryRuleRec.get('Id') == null)
                {
                    DeliveryRuleRec.SVMXC__Default_Location__c = ChildLocationRec.Id;
                    DeliveryRuleRec.SVMXC__Name__c = ChildLocationRec.Name + ' Delivery Rule';
                }
            }
        }
        renderForSelectedDepot = true;
        return null;
    }
    
    /************ Method to Cancel Delivery Rule **********************/
    public pagereference Cancel_DeliveryRule()
    {
        DisplayRuleInfo = false;
        DisplayRuleLineInfo = false;
        DeliveryRuleRec = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RType_HeaderDeliveryRule.Id, SVMXC__IsStandard__c = false);
        DeliveryRuleLineRecsLst = new List<SVMXC__ServiceMax_Processes__c>();
        RuleLineWrapObjLst = new List<ObjExpressionWrapper>();
        return null;
    }
    
    /************ Method to Delete Delivery Rule **********************/
    public pagereference DeleteDeliveryRule()
    {
        List<SVMXC__ServiceMax_Processes__c> DeliveryRuleRecsToDelete = new List<SVMXC__ServiceMax_Processes__c>();
        Set<Id> setDeliveryRuleIdsToDelete = new Set<Id>();
        List<SVMXC__ServiceMax_Processes__c> DeliveryRuleLineRecsToDelete = new List<SVMXC__ServiceMax_Processes__c>();
        Map<Id,SVMXC__ServiceMax_Processes__c> mapDelRuleLineRecs = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        Set<Id> setDeliveryRuleLineIdsToDelete = new Set<Id>();
        List<SVMXC__ServiceMax_Config_data__c> DeliveryRuleLineExprRecsToDelete = new List<SVMXC__ServiceMax_Config_data__c>();
        integer count = 0;
        try
        {
            for(SVMXC__ServiceMax_Processes__c DelRuleRec: DeliveryRulesLst)
            {
                if(DelRuleRec.SVMXC__Select__c)
                {
                  DeliveryRuleRecsToDelete.add(DelRuleRec);
                  setDeliveryRuleIdsToDelete.add(DelRuleRec.Id);
                }
            }
            if(DeliveryRuleRecsToDelete == null || (DeliveryRuleRecsToDelete != null && !(DeliveryRuleRecsToDelete.size() > 0)))
                return null;
        
            if(setDeliveryRuleIdsToDelete != null && setDeliveryRuleIdsToDelete.size() > 0)
                DeliveryRuleLineRecsLst = [Select Id From SVMXC__ServiceMax_Processes__c  Where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Delivery Rule Line' AND SVMXC__Module__c IN :setDeliveryRuleIdsToDelete]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
            if(DeliveryRuleLineRecsLst != null && DeliveryRuleLineRecsLst.size() >0)
            {
                mapDelRuleLineRecs.putAll(DeliveryRuleLineRecsLst);
                setDeliveryRuleLineIdsToDelete.addAll(mapDelRuleLineRecs.keyset());
            }
            if(setDeliveryRuleLineIdsToDelete != null && setDeliveryRuleLineIdsToDelete.size() >0)
            {
                DeliveryRuleLineExprRecsToDelete = [Select Id from SVMXC__ServiceMax_Config_data__c where RecordType.Name = 'expressions' and SVMXC__Expression_Rule__c IN :setDeliveryRuleLineIdsToDelete]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(DeliveryRuleLineExprRecsToDelete != null && DeliveryRuleLineExprRecsToDelete.size() >0){
                    //Delete DeliveryRuleLineExprRecsToDelete;
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                        delete DeliveryRuleLineExprRecsToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                DeliveryRuleLineExprRecsToDelete.clear();
            }
            if(DeliveryRuleLineRecsLst != null && DeliveryRuleLineRecsLst.size() > 0)
                DeliveryRuleRecsToDelete.addAll(DeliveryRuleLineRecsLst);
      
            //Delete DeliveryRuleRecsToDelete;
            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                delete DeliveryRuleRecsToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                return null;
            }
      
            DeliveryRuleLineRecsLst.clear();
            DeliveryRuleRecsToDelete.clear();
      
            DeliveryRulesLst = new List<SVMXC__ServiceMax_Processes__c>();
            DeliveryRulesLst = [Select Id, SVMXC__Select__c, LastModifiedDate, SVMXC__Sequence__c, LastModifiedBy.Name, SVMXC__Name__c, SVMXC__Description__c, SVMXC__APL_Allow_Partial_Delivery__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Type__c ,SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name, SVMXC__Advance_Expression__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Delivery Rule' AND SVMXC__Location__c != NULL]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, getTag009(),''));
            return null;
        }
            DisplayRuleInfo = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, getTag008(),''));
            return null;
            // Neeraj(March-5th-2012): Added below line to reload the same page again.
            //PageReference pageRef = new PageReference('/apex/SVMXC__CONF_ManageDeliveryRules?SVMX_retURL=/apex/SVMXC__CONF_SetupHome');
            //pageRef.setRedirect(true);
            //return pageRef;
        
            
            
        }
    
    
    /*************** Method to Add delivery rule line ********************/
    public pagereference DeliveryRuleAddLine()
    {
        if( CurrentEditLine_SeqNo != null &&  deliveryRuleLineRec != null)
            mapSeq_DelRuleLineRec.put(CurrentEditLine_SeqNo, deliveryRuleLineRec);
        SVMXC__ServiceMax_Processes__c newDeliveryRuleLineRec = new SVMXC__ServiceMax_Processes__c(SVMXC__Select__c = true, RecordTypeId=RType_DeliveryRule.Id, SVMXC__Rule_Type__c = 'Delivery Rule Line', SVMXC__Sequence__c = DeliveryRuleLineRecsLst.size() + 1, SVMXC__IsStandard__c = false);
        CurrentEditLine_SeqNo = Integer.valueOf(DeliveryRuleLineRecsLst.size() + 1);
        deliveryRuleLineRec = newDeliveryRuleLineRec;
        RuleLineWrapObjLst = new List<ObjExpressionWrapper>();
        DeliveryRuleCriteriaAddLines();
        for(SVMXC__ServiceMax_Processes__c DelRulLineRec: DeliveryRuleLineRecsLst)
        {
            if(DelRulLineRec.SVMXC__Select__c)
                DelRulLineRec.SVMXC__Select__c = false;
        }
              
        DeliveryRuleLineRecsLst.add(newDeliveryRuleLineRec);
        selectedRuleLineId = null;
        DisplayRuleLineInfo = true;
    disableNewEditDel = true;
        return null;
    }
    
     /*************** Method to add delivery rule line criteria  ********************/
    public pagereference DeliveryRuleCriteriaAddLines()
    {
       
        ObjExpressionWrapper ObjectExprWrprObj1;
        if(selectedRuleLineId != null && selectedRuleLineId != '')
            ObjectExprWrprObj1 = new ObjExpressionWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = RuleLineWrapObjLst.size() + 1, RecordTypeId = RType_FieldMapping.Id, SVMXC__Expression_Rule__c = selectedRuleLineId),new List<SelectOption>());
        else
            ObjectExprWrprObj1 = new ObjExpressionWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = RuleLineWrapObjLst.size() + 1, RecordTypeId = RType_FieldMapping.Id) ,new List<SelectOption>());
        RuleLineWrapObjLst.add(ObjectExprWrprObj1);
        return null;
    }
    
    /*************** Method to delete delivery rule line criteria  ********************/
    List<SVMXC__ServiceMax_Config_Data__c> DeleteCritConfigLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    public void DeliveryRuleCriteriaDelLines()
    {
        system.debug('Size of Exp List before Delete: ' + DeliveryRuleExprhighestSequenceNumber);
        for(Integer i=0; i< RuleLineWrapObjLst.size();i++)
        {   
            if(integer.valueOf(SelIndex) == RuleLineWrapObjLst[i].ExpressionRec.SVMXC__Sequence__c)
            {
                If(RuleLineWrapObjLst[i].ExpressionRec.Id != null)
                    DeleteCritConfigLst.add(RuleLineWrapObjLst[i].ExpressionRec);
                RuleLineWrapObjLst.remove(i);
                break;
            }
        }
        for(Integer i=0; i< RuleLineWrapObjLst.size();i++)
            RuleLineWrapObjLst[i].ExpressionRec.SVMXC__Sequence__c = i + 1;
        system.debug('Size of Exp List after Delete: ' + DeliveryRuleExprhighestSequenceNumber);
    }
    
    /*************** Method to delete delivery rule line ********************/
    public pagereference DeliveryRuleDelLine()
    {
        if(DeliveryRuleLineRecsLst != null && DeliveryRuleLineRecsLst.size() > 0)
        {
            DisplayRuleLineInfo = false;
            integer count = 0;
            integer IntVal;
            SVMXC__ServiceMax_Processes__c DeliveryRuleLineRec_local = new SVMXC__ServiceMax_Processes__c();
            for(Integer i=0; i< DeliveryRuleLineRecsLst.size();i++)
            {
                if(DeliveryRuleLineRecsLst[i].SVMXC__Select__c)
                {
                    count += 1;
                    IntVal = i;
                    DeliveryRuleLineRec_local = DeliveryRuleLineRecsLst[i];
                }
            }
            if(count != 1 || DeliveryRuleLineRec_local == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag010(),''));
                return null;
            }
            else
            {
                if(DeliveryRuleLineRecsLst[IntVal].Id != null){
                    //delete DeliveryRuleLineRecsLst[IntVal];
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                        delete DeliveryRuleLineRecsLst[IntVal];
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                DeliveryRuleLineRecsLst.remove(IntVal);
                IntVal = IntVal+1;
                for( integer i = 0; i < DeliveryRuleLineRecsLst.size(); i++ )
                    DeliveryRuleLineRecsLst[i].SVMXC__Sequence__c = i+1;
                disableNewEditDel = false;
            }
        }
        return null;
    }
    
    
    /*********** back To SetupHome method ******************/
    public pagereference backToSetupHome()
    {
        if(retBtnTxt == system.label.CONF023_TAG127)
        {
           //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
            String url='';
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                url = '/lightning/n/SVMXC__ServiceMax_Setup';
            }else{
                url ='/apex/CONF_SetupHome';
            }
            PageReference pr = new PageReference(url);
            pr.setredirect(true);
            return pr;
        }
        else
        {
          PageReference pr = new PageReference(retURL);
          pr.setredirect(true);
          return pr;
        }
    }
    
    /*********** Wrapper Class ******************/
    public class ObjExpressionWrapper
    {
        /********* All getter setter of wrapper class ***********/
        public SVMXC__ServiceMax_Config_Data__c ExpressionRec;
        public SVMXC__ServiceMax_Config_Data__c getExpressionRec(){return ExpressionRec;}
        public void setExpressionRec(SVMXC__ServiceMax_Config_Data__c Rec){this.ExpressionRec = Rec;}
        
        public List<SelectOption> ObjectFields = new List<SelectOption>();
        public List<SelectOption> getObjectFields(){return ObjectFields;}
        public void setObjectFields(List<SelectOption> SelOpt){this.ObjectFields = SelOpt;}
    
        /*********** Constructor ******************/
        public ObjExpressionWrapper(){}
        public ObjExpressionWrapper(SVMXC__ServiceMax_Config_Data__c ExprRec, List<SelectOption> ObjFields)
        {
            this.ExpressionRec = ExprRec;
            this.ObjectFields = ObjFields;
        }
    }
    
    /*********** getter setter methods ******************/
    public String getTag147(){ return System.label.CONF023_TAG055;} // Setup Delivery Rules
    public String getTag028(){ return System.label.CONF023_TAG131;} // New
    public String getTag027(){ return System.label.CONF023_TAG027;} // View/Edit
    public String getTag124(){ return System.label.CONF023_TAG132;} // Delete
    public String getTag093(){ return System.label.CONF023_TAG093;} // Save
    public String getTag149(){ return System.label.CONF023_TAG128;} // Select 
    public String getTag004(){ return System.label.CONF023_TAG058;} // Depot
    public String getTag059(){ return System.label.CONF023_TAG059;} // Rule Name
    public String getTag005(){ return System.label.CONF023_TAG129;} // Last Modified By
    public String getTag094(){ return System.label.CONF023_TAG094;} // Cancel
    public String getTag062(){ return System.label.CONF023_TAG062;} // Allow Partial Delivery
    public String getTag058(){ return System.label.CONF023_TAG058;} // Select Depot
    public String getTag063(){ return System.label.CONF023_TAG063;} // Default Delivery Location
    public String getTAG001(){return System.Label.CONF023_TAG061;} // Delivery Type
    public String getTAG002(){return System.Label.CONF023_TAG064;} // Manual
    public String getTAG003(){return System.Label.CONF023_TAG065;} // Automatic
    public String getTag066(){ return System.label.CONF023_TAG066;} // Delivery Rule Details
    public String getTag007(){ return System.label.CONF023_TAG069;} // Edit
    public String getTag067(){ return System.label.CONF023_TAG067;} // Rule Line
    public String getTag070(){return System.label.CONF023_TAG070;} // Deliver to Location
    
    public String getTag087(){ return System.label.CONF023_TAG087;} // Updates after delivery
    public String getTag089(){ return System.label.CONF023_TAG089;} // Config Work Order
    public String getTag092(){ return System.label.CONF023_TAG092;} // Processing...
    public String getTag055(){ return System.label.CONF023_TAG055;} // Show Delivery Rules
    public String getTag057(){ return System.label.CONF023_TAG057;} // Create New Delivery Rule
    public String getTag125(){ return System.label.CONF023_TAG099;} // Selected Delivery Rule Line's Criteria
    public String getTag072(){ return System.label.CONF023_TAG072;} // Object Name
    public String getTag031(){ return System.label.CONF023_TAG031;} // Field Name
    public String getTag032(){ return System.label.CONF023_TAG032;} // Operator
    public String getTag033(){ return System.label.CONF023_TAG033;} // Value
    public String getTag034(){ return System.label.CONF023_TAG034;} // Advanced Expression
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
    //public String getTag145(){ return 'Edit Delivery Rule';}
    //public String getTag146(){ return 'New Delivery Rule';}    
    public String getTAG046(){return System.Label.CONF022_TAG046;}
    public String getTag148(){ return System.label.CONF023_TAG067;}
    
    
    public String getTag171(){ return System.Label.CONF023_TAG133;}
    public String getTag006(){ return System.Label.CONF023_TAG102;}
    public String getTag008(){ return System.Label.CONF023_TAG138;} //'Selected Rules deleted Successfully'
    public String getTag009(){ return System.Label.CONF023_TAG139;} //'Internal Error Occurred. Please contact to your ServiceMax Administrator'
    public String getTag010(){ return System.Label.CONF023_TAG140;} //'Please select only one delivery rule line to perform the required operation'
    public String getTag011(){ return System.Label.CONF023_TAG141;} //'Sequence'
    public String getTag012(){ return System.Label.CONF023_TAG098;}
    public String getTag013(){ return System.Label.CONF023_TAG145;} //'Please enter valid rule line name'
    public String getTag014(){ return System.Label.CONF023_TAG146;} //'Please select location'
    public String getTag015(){ return System.Label.CONF023_TAG147;} //'Please enter valid rule name'
    public String getTag016(){ return System.Label.CONF023_TAG148;} //'Account'
    public String getTag017(){ return System.Label.CONF023_TAG112;}
    public String getTag144(){ return retBtnTxt;} // Back/Back To Setup Home
    public String getTAG150() {return system.label.COMM002_TAG032;}//'Add Row'
    public String getTAG151() {return system.label.COMM002_TAG033;}//'Delete Row'
    public string getHLPURL() {return system.label.CONF023_HLPURL1;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
    public String getTag020(){ return system.label.CONF023_TAG160;} //'Delivery Location'
}