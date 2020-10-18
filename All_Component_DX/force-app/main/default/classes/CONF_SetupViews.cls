public with sharing class CONF_SetupViews
{
    //Global Variable Decleration..
    String strViewId = '';
    String strMode = '';
    String strExpRTypeId = '';
    String strProRTypeId = '';
    String strErrorMsg = '';
    public boolean isError = false;
    public boolean isErMsgBlk = false;
    public boolean disableSourceObj = false;

    transient map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    map<String, Schema.SObjectType> mapAllobjDesc  = new map<String, Schema.SObjectType>();  

    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();  


    public SVMXC__ServiceMax_Processes__c objSVMXPrcss = new SVMXC__ServiceMax_Processes__c();
    public List<SVMXC__ServiceMax_Config_Data__c> lstCfgDta = new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> lstCfgDtatoDelCrtria = new List<SVMXC__ServiceMax_Config_Data__c>();
    public  List<SVMXC__ServiceMax_Config_Data__c> getLstCfgDta() {return lstCfgDta;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstCfgDta2 = new List<SVMXC__ServiceMax_Config_Data__c>();
    //public List<SVMXC__ServiceMax_Config_Data__c> getLstCfgDta2() {return lstCfgDta2;}
    List<SVMXC__ServiceMax_Processes__c> lstPrcssObj = new List<SVMXC__ServiceMax_Processes__c>();

    list<RecordType> lstRecordType = new list<RecordType>();
    public SVMXC__ServiceMax_Processes__c getObjSVMXPrcss() {return objSVMXPrcss;}
    public void setObjSVMXPrcss(SVMXC__ServiceMax_Processes__c obj) {objSVMXPrcss = obj;}
    public Map<String, String> mapFildNmReLNm = new Map<String, String>();
    public List<selectOption> ownerType = new List<selectOption>();
    public List<selectOption> getOwnerType() {return ownerType;}
    public List<selectOption> FildSelectLst = new List<selectOption>();
    public List<SelectOption> getFildSelectLst(){return FildSelectLst;}
    public List<selectOption> OperatorsSelectLst = new List<selectOption>();
    public List<SelectOption> getOperatorsSelectLst(){return OperatorsSelectLst;}
    public List<selectOption> lstAllObj = new List<selectOption>();
    public List<selectOption> getLstAllObj() {return lstAllObj;}
    public void setLstAllObj(List<selectOption> lstObj) {lstAllObj = lstObj;}
    //public transient list <Schema.PicklistEntry> transientViewForPicklist;
    transient list <Schema.PicklistEntry> ViewForPicklist = new list <Schema.PicklistEntry>();

    map<String,String> mapLabelValueOfViewFor = new map<String,String>();
    public List<selectOption> lstViewFor = new List<selectOption>();
    public List<selectOption> getlstViewFor() {return lstViewFor;}
    public void setlstViewFor(List<selectOption> lstObj) {lstViewFor = lstObj;}
    transient map<String,String> mapQueryStringParameters = new map<String,String>();
    //------ variables for choose list
    
    Map<String, String> mapFildSelect = new Map<String, String>();
    Map<String, String> mapFildIN = new Map<String, String>();
    Map<String, String> mapFildOut = new Map<String, String>();
    
    public  List<SVMXC__ServiceMax_Config_Data__c> lstSelctFilds = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    public List<String> strFildIN = new List<String>();
    public List<String> getStrFildIN() {return strFildIN;}
    public void setStrFildIN(List<String> strLst) {strFildIN = strLst;}
    
    public List<String> strFildOut = new List<String>();
    public List<String> getStrFildOut() {return strFildOut;}
    public void setStrFildOut(List<String> strLst) {strFildOut = strLst;}
    
    public List<selectOption> slctOptnIN = new List<selectOption>();
    public List<selectOption> getslctOptnIN() {return slctOptnIN;}
    public void setslctOptnIN(List<selectOption> lstObj) {slctOptnIN = lstObj;}
    
    public List<selectOption> slctOptnOut = new List<selectOption>();
    public List<selectOption> getslctOptnOut() {return slctOptnOut;}
    public void setslctOptnOut(List<selectOption> lstObj) {slctOptnOut = lstObj;}
    
    //---------------------------------
    
    public boolean isStandrd{get;set;}
    public Integer selectedObjSerial{get; set;}
    
    //Getter Setter Methods
    public boolean getisErMsgBlk(){return isErMsgBlk;}
    public void setisErMsgBlk(){this.isErMsgBlk = isErMsgBlk;}
    public boolean getdisableSourceObj(){return disableSourceObj;}
    public void setdisableSourceObj(){this.disableSourceObj = disableSourceObj;}
     
    
   
    public CONF_SetupViews()
    {
        
        lstAllObj.add(new SelectOption(system.label.COMM002_TAG005,system.label.COMM002_TAG005));
        gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            Schema.DescribeSObjectResult result = s.getDescribe();
            mapAllobjDesc.put(result.getName(),s);
            if(result.getName() == 'SVMXC__Service_Order__c' || result.getName() == 'SVMXC__Site__c' || result.getName() == 'Account')
              lstAllObj.add(new SelectOption(result.getName(),result.getLabel()));
          //result.clear();
        }
        gd.clear();
        FildSelectLst.clear();
        FildSelectLst.add(new SelectOption('SVMX.None',getTAG017()));

        //Query For the RecordType 
        lstRecordType = [select Id, Name From RecordType where SobjectType= 'SVMXC__ServiceMax_Processes__c' OR SobjectType= 'SVMXC__ServiceMax_Config_Data__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstRecordType.size() > 0)
        {
          for(RecordType rt : lstRecordType)
          {
            if(rt.Name == 'View Definition')
              strProRTypeId = rt.id;
            else if(rt.Name == 'Expressions')  
              strExpRTypeId = rt.id;
          }
        }
        //lstRecordType.clear();
        objSVMXPrcss.RecordTypeId = strProRTypeId;
        objSVMXPrcss.SVMXC__Rule_Type__c = 'Custom View';
        
        mapQueryStringParameters = ApexPages.currentPage().getParameters();
        system.debug('mapQueryStringParameters'+mapQueryStringParameters);
        if(mapQueryStringParameters.containskey('SVMX_ViewId'))
          strViewId = mapQueryStringParameters.get('SVMX_ViewId');
        if(mapQueryStringParameters.containskey('SVMX_Mode'))
          strMode = mapQueryStringParameters.get('SVMX_Mode');  
        //Construct Picklist values 

        ViewForPicklist = SVMXC__ServiceMax_Processes__c.SVMXC__View_For__c.getDescribe().getPicklistValues();
        if(ViewForPicklist.size() > 0)
        {
            for(Integer i = 0;i<ViewForPicklist.size();i++)
            {
                if(ViewForPicklist[i].isActive())
                    mapLabelValueOfViewFor.put(ViewForPicklist[i].getLabel(),ViewForPicklist[i].getValue());
            }

        }
        
        list<Schema.PicklistEntry> pickListVal = SVMXC__ServiceMax_Processes__c.SVMXC__Ownership_Type__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pickVal : pickListVal){
            ownerType.add(new SelectOption(pickVal.getValue() , pickVal.getLabel()));
         }
        OperatorsSelectLst.clear();
        OperatorsSelectLst.add(new SelectOption('SVMX.None',getTAG017()));
        OperatorsSelectLst.add(new SelectOption('eq',getTAG018()));
        OperatorsSelectLst.add(new SelectOption('ne',getTAG019()));
        OperatorsSelectLst.add(new SelectOption('gt',getTAG020()));
        OperatorsSelectLst.add(new SelectOption('ge',getTAG021()));
        OperatorsSelectLst.add(new SelectOption('lt',getTAG022()));
        OperatorsSelectLst.add(new SelectOption('le',getTAG023()));
        OperatorsSelectLst.add(new SelectOption('starts',getTAG024()));
        OperatorsSelectLst.add(new SelectOption('contains',getTAG025()));
        OperatorsSelectLst.add(new SelectOption('notcontain',getTAG026()));
        OperatorsSelectLst.add(new SelectOption('in',getTAG027()));
        OperatorsSelectLst.add(new SelectOption('notin',getTAG028()));
        OperatorsSelectLst.add(new SelectOption('isnull',getTAG029()));
        OperatorsSelectLst.add(new SelectOption('isnotnull',getTAG030()));
        if(strViewId != null && strViewId.length() > 0)
        {
            disableSourceObj = true;
            getQuery();
        }   
        if(objSVMXPrcss.Id != null)
        {
            if(strMode == 'Clone' )
            {
                objSVMXPrcss.SVMXC__IsStandard__c = false;
            }
            isStandrd = objSVMXPrcss.SVMXC__IsStandard__c;
        }
        else
        {
            isStandrd = false;
        }
        setDefWOFld();
        makeViewForPickList();
        if(lstCfgDta.size() == 0 )
          addExpRow();
          
        
    }
    public void makeViewForPickList()
    {
        lstViewFor.clear();
        System.debug('objSVMXPrcss : '+objSVMXPrcss);
        System.debug('objSVMXPrcss.SVMXC__Source_Object_Name__c : '+objSVMXPrcss.SVMXC__Source_Object_Name__c);











        if(mapLabelValueOfViewFor.size() > 0)
        {
            if(objSVMXPrcss.SVMXC__Source_Object_Name__c == 'Account' ||objSVMXPrcss.SVMXC__Source_Object_Name__c == 'SVMXC__Site__c')
            {
                for(String str : mapLabelValueOfViewFor.keyset())
                {
                    if( str == 'Map')
                    {
                        lstViewFor.add(new SelectOption(str,mapLabelValueOfViewFor.get(str)));
                    }
                }
            }
            else
            {
                for(String str : mapLabelValueOfViewFor.keyset())
                {
                    lstViewFor.add(new SelectOption(str,mapLabelValueOfViewFor.get(str)));
                }
            }
        }
    }
    public void againLoad()
    {
        getQuery();
        if(objSVMXPrcss.Id != null)
        {
            if(strMode == 'Clone' )
            {
                objSVMXPrcss.SVMXC__IsStandard__c = false;
            }
            isStandrd = objSVMXPrcss.SVMXC__IsStandard__c;
        }
        else
        {
            isStandrd = false;
            objSVMXPrcss.RecordTypeId = strProRTypeId;
            objSVMXPrcss.SVMXC__Rule_Type__c = 'Custom View';
        }
        
        setDefWOFld();
        if(lstCfgDta.size() == 0 )
            addExpRow();
    }
    
    public void changeOfObj()
    {
       disableSourceObj = true;
       lstCfgDta.clear();
       objSVMXPrcss.SVMXC__Parent_Object_Criteria__c = null;
       objSVMXPrcss.SVMXC__Advance_Expression__c = null;
       makeViewForPickList();
       getFiledFromSelctdObj();
       setDefWOFld();
       addExpRow();      
    }
    
    public void getFiledFromSelctdObj()
    {
        map<string, boolean> lstStdObjAccToLicense = new map<string, boolean>();
        COMM_Utils comUtil = new COMM_Utils();
        lstStdObjAccToLicense = comUtil.SVMX_getPermittedStandardObjectList();
        
        if((objSVMXPrcss.SVMXC__Source_Object_Name__c != null && objSVMXPrcss.SVMXC__Source_Object_Name__c.length() > 0) || objSVMXPrcss.SVMXC__Source_Object_Name__c != system.label.COMM002_TAG005)
        {
            FildSelectLst.clear();
            mapFildSelect.clear();
            slctOptnOut.clear();
            slctOptnIN.clear();
            mapFildNmReLNm.clear();
            FildSelectLst.add(new SelectOption('SVMX.None',getTAG017()));
            map<String,Schema.sObjectField> mapFields = new map<String,Schema.sObjectField>(); 










            if(objSVMXPrcss.SVMXC__Source_Object_Name__c != null || objSVMXPrcss.SVMXC__Source_Object_Name__c != 'None') {
                if(mapAllObjDesc.values().size() == 0){
                    for(Schema.SObjectType s : Schema.getGlobalDescribe().values())
                    {
                        Schema.DescribeSObjectResult result = s.getDescribe();
                        mapAllobjDesc.put(result.getName(),s);
                        if(result.getName() == 'SVMXC__Service_Order__c' || result.getName() == 'SVMXC__Site__c' || result.getName() == 'Account')
                          lstAllObj.add(new SelectOption(result.getName(),result.getLabel()));
                      //result.clear();
                    }
                }
                mapFields = mapAllObjDesc.get(objSVMXPrcss.SVMXC__Source_Object_Name__c).getDescribe().fields.getMap();
            }
            mapAllObjDesc.clear();
            if(mapFields.size() > 0)
            {
                for(String str : mapFields.keyset())
                { 
                    schema.Describefieldresult f = mapFields.get(str).getDescribe();
                    if(f.getType() == Schema.DisplayType.Reference)
                    {
                        if(!comUtil.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                        {
                            if(!lstStdObjAccToLicense.containsKey(String.valueof(f.getReferenceTo()[0])))
                            {
                                continue;
                            }
                        }
                    }
                    FildSelectLst.add(new SelectOption(f.getName(), f.getLabel()));
                    mapFildSelect.put(f.getName(), f.getLabel());
                    if(f.getType()  == Schema.DisplayType.REFERENCE)
                        mapFildNmReLNm.put(f.getName(), f.getRelationshipName());
                }
            }       
            FildSelectLst = sortingSelectOption(FildSelectLst);
            slctOptnOut.addall(FildSelectLst);
        }
    }
    
    public void setDefWOFld()
    {






        
        if(mapFildSelect.size() > 0)
        {
          for(String srtFld : mapFildSelect.keySet())
          {
              if(mapFildSelect.containskey(srtFld))
                mapFildOut.put(srtFld , mapFildSelect.get(srtFld));
          }
        }    
        
        lstSelctFilds.clear();
        if(lstCfgDta2.size() == 0)
        {
            mapFildIN.put('Name', mapFildSelect.get('Name'));
            mapFildOut.remove('Name');
            createCfgDtaFrFilDLst('Name', lstSelctFilds.size()+1);
            
        }
        else
        {
            for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstCfgDta2)
            {
                mapFildOut.remove(objCfgDta.SVMXC__Field_Name__c);
                if(mapFildSelect.containskey(objCfgDta.SVMXC__Field_Name__c))
                  mapFildIN.put(objCfgDta.SVMXC__Field_Name__c, mapFildSelect.get(objCfgDta.SVMXC__Field_Name__c));
                createCfgDtaFrFilDLst(objCfgDta.SVMXC__Field_Name__c, lstSelctFilds.size()+1);
            }
        }
        
        slctOptnIN.clear();
        for(SVMXC__ServiceMax_Config_Data__c objCgfDta : lstSelctFilds)
        {
            if(mapFildSelect.containskey(objCgfDta.SVMXC__Field_Name__c))
              slctOptnIN.add(new SelectOption(objCgfDta.SVMXC__Field_Name__c , mapFildSelect.get(objCgfDta.SVMXC__Field_Name__c)));
        }
        
        slctOptnOut.clear();
        for(String getNm : mapFildOut.keySet())
        {
            if(mapFildSelect.containskey(getNm))
              slctOptnOut.add(new SelectOption(getNm , mapFildSelect.get(getNm)));
        }
        
        if(slctOptnOut.size() > 0)
        slctOptnOut = sortingSelectOption(slctOptnOut);
    }
    
    
    
    public void getQuery()
    {
      System.debug('id of save process : '+strViewId);
      lstPrcssObj.clear();
        lstPrcssObj = [ Select Id, SVMXC__Source_Object_Name__c, SVMXC__Ownership_Type__c, SVMXC__Select__c, SVMXC__Rule_Type__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__View_For__c , SVMXC__Parent_Object_Criteria__c, SVMXC__Advance_Expression__c, SVMXC__IsStandard__c, SVMXC__Description__c, LastModifiedDate From SVMXC__ServiceMax_Processes__c where Id =: strViewId and RecordTypeId =: strProRTypeId and SVMXC__Rule_Type__c = : 'Custom View'  ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        System.debug('size of list of process get by query : '+lstPrcssObj.size());

        if(lstPrcssObj.size() > 0)
        {
            objSVMXPrcss = lstPrcssObj[0];
        
            if(lstPrcssObj != null && lstPrcssObj[0].Id != null)
            {
                lstCfgDta.clear();
                lstCfgDta = [Select Id, SVMXC__Expression_Rule__c, SVMXC__Expression_Type__c, SVMXC__Field_Name__c, SVMXC__Sequence__c, SVMXC__Display_Type__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Operator__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: strExpRTypeId and  SVMXC__Expression_Rule__c =: lstPrcssObj[0].Id and SVMXC__Expression_Type__c =: 'SRCH_Object_Prefilter_Criteria' ORDER BY SVMXC__Sequence__c ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                lstCfgDtatoDelCrtria.clear();
                for(SVMXC__ServiceMax_Config_Data__c objcfgdta : lstCfgDta)
                {
                    lstCfgDtatoDelCrtria.add(objcfgdta);
                }
                
                lstCfgDta2.clear();
                lstCfgDta2 = [Select Id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Display_Value__c, SVMXC__Sequence__c, SVMXC__Expression_Type__c, SVMXC__Display_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name=: 'Expressions' and  SVMXC__Expression_Rule__c =: lstPrcssObj[0].Id and SVMXC__Expression_Type__c =: 'SRCH_Object_Fields' ORDER BY SVMXC__Sequence__c ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                for(SVMXC__ServiceMax_Config_Data__c objcfgdta : lstCfgDta2)
                {
                    lstCfgDtatoDelCrtria.add(objcfgdta);
                }
                
                System.debug('List of config data get from the query : '+lstCfgDtatoDelCrtria.size());
            }
            getFiledFromSelctdObj();
        }
        
    }

    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO : sortList) 
        {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }
    
    public void addExpRow()
    {
        SVMXC__ServiceMax_Config_Data__c objExp = new SVMXC__ServiceMax_Config_Data__c();
        objExp.SVMXC__Field_Name__c = 'SVMX.None';
        objExp.SVMXC__Operator__c = 'SVMX.None';
        if(lstCfgDta.size() > 0)
            objExp.SVMXC__Sequence__c = lstCfgDta[lstCfgDta.size()-1].SVMXC__Sequence__c + 1;
        else
            objExp.SVMXC__Sequence__c = 1;
        lstCfgDta.add(objExp);
    }
    
    public void delExpRow()
    {
        
        List<SVMXC__ServiceMax_Config_Data__c> lstTempCfgDta = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstTempCfgDta = lstCfgDta.clone();
        lstCfgDta.clear();
        boolean isSelefind = false;
        for(SVMXC__ServiceMax_Config_Data__c objCfgDta: lstTempCfgDta)
        {
            if(objCfgDta.Sequence__c ==  selectedObjSerial)
            {
                isSelefind = true;
                continue;
            }
            if(isSelefind)
            {
                objCfgDta.Sequence__c = objCfgDta.Sequence__c - 1;
            }
            lstCfgDta.add(objCfgDta);
        }
        lstTempCfgDta.clear();
    }
    
   
    
    
    
    public boolean submitExp(SVMXC__ServiceMax_Processes__c ProcessObj, List<SVMXC__ServiceMax_Config_Data__c> ExpConfigDataLst)
    {
        SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(ProcessObj,ExpConfigDataLst);
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
        LstSFM_Exp.add(oSFM_Exp);
        SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
        SFM_WrapperDef.SFM_Response Save_Response = new SFM_WrapperDef.SFM_Response();
        SFM_ValidateExpression ValidateExp = new SFM_ValidateExpression();
        Save_Response = ValidateExp.SFM_validateExpression(oRequest);
        strErrorMsg = Save_Response.message;

        if( Save_Response.success != null && Boolean.valueOf(Save_Response.success))
            return true;
        else
            return false;
    }
    
    /* public string getInstallKey()
    {
        try
        {
            return EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15) )); ////+ '~' + String.valueOf(date.Today())
        }
        catch(exception ex)
        {
            //AddException(ex.getMessage());
        }
        return '';
    } */
    
    public void save()
    {
        isErMsgBlk = false;
        boolean isExprsstrue = true;
        String AdvExprss = '';
        boolean isValidPrssId;
        List<SVMXC__ServiceMax_Config_Data__c> lstCfgDtaCritraToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstCfgDtaCritraToSave2 = new List<SVMXC__ServiceMax_Config_Data__c>();
        //List<SVMXC__ServiceMax_Config_Data__c> lstCfgDtaRefFldToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c objSVMXPrcssToSave = new SVMXC__ServiceMax_Processes__c();
        lstCfgDtaCritraToSave2 = lstSelctFilds.deepClone();

        if(strMode == 'Clone' )
        {
            objSVMXPrcssToSave = objSVMXPrcss.clone(false,true,false,false);
            lstCfgDtatoDelCrtria.clear();

        }
        else
        {
            objSVMXPrcssToSave = objSVMXPrcss;
        }
        //---- creating list of Expressions ---------
            for(SVMXC__ServiceMax_Config_Data__c objExp : lstCfgDta)
            {
                if(objExp.SVMXC__Field_Name__c != 'SVMX.None' && objExp.SVMXC__Field_Name__c != 'None' && objExp.SVMXC__Operator__c != 'SVMX.None' && objExp.SVMXC__Operator__c != 'None' )
                {
                    SVMXC__ServiceMax_Config_Data__c objCfgDtaTemp = new SVMXC__ServiceMax_Config_Data__c();
                    objCfgDtaTemp.SVMXC__Field_Name__c = objExp.SVMXC__Field_Name__c;
                    objCfgDtaTemp.SVMXC__Operator__c = objExp.SVMXC__Operator__c;
                    objCfgDtaTemp.SVMXC__Operand__c = objExp.SVMXC__Operand__c;
                    objCfgDtaTemp.SVMXC__Object_Name2__c = objSVMXPrcss.SVMXC__Source_Object_Name__c;//'SVMXC__Service_Order__c';
                    objCfgDtaTemp.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
                    objCfgDtaTemp.SVMXC__Sequence__c = objExp.SVMXC__Sequence__c;
                    objCfgDtaTemp.RecordTypeId = strExpRTypeId;
                    
                    lstCfgDtaCritraToSave.add(objCfgDtaTemp);
                }
            }
            
            /* for(String srtFildKey : mapFildIN.KeySet())
            {
                SVMXC__ServiceMax_Config_Data__c objCfgDtaTemp = new SVMXC__ServiceMax_Config_Data__c();
                objCfgDtaTemp.RecordTypeId = strExpRTypeId;
                objCfgDtaTemp.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c' ; //mapRefFild.get(objWrapr.strRefObj).getDescribe().getName();
                objCfgDtaTemp.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
                objCfgDtaTemp.SVMXC__Field_Name__c = srtFildKey;
                objCfgDtaTemp.SVMXC__Lookup_Field_API_Name__c = mapFildNmReLNm.get(srtFildKey);

                lstCfgDtaCritraToSave2.add(objCfgDtaTemp);
            } */

           
            if(lstCfgDtaCritraToSave != null && lstCfgDtaCritraToSave.size() > 0)
            {
                isExprsstrue = submitExp(objSVMXPrcssToSave, lstCfgDtaCritraToSave);
                //The below code is to setting all the data required for getCriteria method of SFM_ValidateExpression
                SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(objSVMXPrcssToSave,lstCfgDtaCritraToSave);
                List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                LstSFM_Exp.add(oSFM_Exp);
                SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                SFM_WrapperDef.SFM_Response Save_Response = new SFM_WrapperDef.SFM_Response();
                SFM_ValidateExpression ValidateExp = new SFM_ValidateExpression();
                Save_Response = ValidateExp.SFM_validateExpression(oRequest);
                AdvExprss = ValidateExp.getCriteria(objSVMXPrcss.SVMXC__Source_Object_Name__c, objSVMXPrcssToSave.SVMXC__Advance_Expression__c, lstCfgDtaCritraToSave );
            }
            
            List<SVMXC__ServiceMax_Processes__c> SVMXPrcss ;
            if(objSVMXPrcss.Id != null && strMode != 'Clone')
            {
                SVMXPrcss = [select id from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: objSVMXPrcss.SVMXC__ProcessID__c and id !=: objSVMXPrcss.Id ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            else
            {
                SVMXPrcss = [select id from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: objSVMXPrcss.SVMXC__ProcessID__c ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            
            if(SVMXPrcss.size() > 0 )
                isValidPrssId = false;
            else
                isValidPrssId = true;
            
            
            
            if(objSVMXPrcssToSave.SVMXC__Name__c != null && objSVMXPrcssToSave.SVMXC__Name__c != '' && objSVMXPrcssToSave.SVMXC__ProcessID__c != null && objSVMXPrcssToSave.SVMXC__ProcessID__c != '')
            {
                if(objSVMXPrcssToSave.SVMXC__ProcessID__c.length() > 8 )
                {
                    if(isValidPrssId == true)
                    {
                        if(isExprsstrue != true )
                        {
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + strErrorMsg ));
                            isError = true;
                        }
                        else
                        {
                                try
                                {
                                    objSVMXPrcssToSave.SVMXC__Parent_Object_Criteria__c = AdvExprss;
                                    system.debug('objSVMXPrcssToSave'+objSVMXPrcssToSave);
                                    //CRUD
                                    if (!securityUtils.verifyFieldAccess(objSVMXPrcssToSave, COMM_SecurityUtils.Access.Upsertable))
                                        {
                                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                                        }           
                                    else
                                        {
                                            upsert objSVMXPrcssToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                        }
                                    //Upsert objSVMXPrcssToSave;
                                    
                                    for(SVMXC__ServiceMax_Config_Data__c objExp : lstCfgDtaCritraToSave)
                                    {
                                        objExp.SVMXC__Expression_Rule__c = objSVMXPrcssToSave.Id;
                                    }
                                    for(SVMXC__ServiceMax_Config_Data__c objExp : lstCfgDtaCritraToSave2)
                                    {
                                        objExp.SVMXC__Expression_Rule__c = objSVMXPrcssToSave.Id;
                                    }
                                    
                                    if(lstCfgDtatoDelCrtria != null && lstCfgDtatoDelCrtria.size() > 0)
                                        Delete lstCfgDtatoDelCrtria; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                                    if(lstCfgDtaCritraToSave != null && lstCfgDtaCritraToSave.size() > 0){
                                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstCfgDtaCritraToSave, COMM_SecurityUtils.Access.Createable)){
                                            insert lstCfgDtaCritraToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                        }
                                        else{
                                            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                                            isError = true;
                                            return;
                                        }
                                    }
                                        
                                        
                                    if(lstCfgDtaCritraToSave2 != null && lstCfgDtaCritraToSave2.size() > 0)
                                    {
                                        APL_Utils objAplUtil = new APL_Utils();
                                        List<SVMXC__ServiceMax_Config_Data__c> lstsavecfgdt = objAplUtil.PopulateInfoForReferenceFields(lstCfgDtaCritraToSave2);
                                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstsavecfgdt, COMM_SecurityUtils.Access.Createable)){
                                            Insert lstsavecfgdt; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                        }
                                        else{
                                            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                                            isError = true;
                                            return;
                                        }
                                        
                                        String strQery = '';
                                        for(SVMXC__ServiceMax_Config_Data__c objTempCgfDta : lstsavecfgdt)
                                        {
                                            String strTemp;
                                            if(objTempCgfDta.SVMXC__Display_Type__c != 'REFERENCE')
                                            {
                                                if(objTempCgfDta.SVMXC__Object_Name2__c == objSVMXPrcss.SVMXC__Source_Object_Name__c)
                                                {
                                                    strTemp = objTempCgfDta.SVMXC__Field_Name__c;
                                                }
                                                else
                                                {
                                                    strTemp = objTempCgfDta.SVMXC__Lookup_Field_API_Name__c+'.'+objTempCgfDta.SVMXC__Field_Name__c;
                                                }
                                            }
                                            else
                                            {
                                                if(objTempCgfDta.SVMXC__Object_Name2__c == objSVMXPrcss.SVMXC__Source_Object_Name__c)
                                                {
                                                    strTemp = objTempCgfDta.SVMXC__Field_Relationship_Name__c+'.'+objTempCgfDta.SVMXC__FKey_Name_Field__c;
                                                }
                                                else
                                                {
                                                    strTemp = objTempCgfDta.SVMXC__Lookup_Field_API_Name__c+'.'+objTempCgfDta.SVMXC__Field_Relationship_Name__c+'.'+objTempCgfDta.SVMXC__FKey_Name_Field__c;
                                                }
                                            }
                                            
                                            if(strQery != '')
                                            {
                                                strQery = strQery+','+strTemp;
                                            }
                                            else
                                            {
                                                strQery = strTemp;
                                            }
                                        }
                                        objSVMXPrcssToSave.SVMXC__Values__c = strQery;
                                        system.debug('objSVMXPrcssToSave'+objSVMXPrcssToSave);
                                        //CRUD
                                        if (!securityUtils.verifyFieldAccess(objSVMXPrcssToSave, COMM_SecurityUtils.Access.Upsertable))
                                            {
                                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                                            }           
                                        else
                                            {
                                                upsert objSVMXPrcssToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                            }
                                        //Upsert objSVMXPrcssToSave;
                                    }
                                    
                                    
                                    
                                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.CONFIRM, '' + getTAG036() ));
                                    
                                    System.debug('mode of view after save : '+strMode);
                                    if(strMode == 'Clone' || strMode == '' || strMode == null)
                                    {
                                        strViewId = objSVMXPrcssToSave.Id;
                                        strMode = '';
                                    }
                                    System.debug('Id of process after save : '+strViewId);
                                    isError = false;
                                    
                                }
                                catch(Exception ex)
                                {
                                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + ex.getmessage()));
                                    isError = true;
                                }

                        }
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG039()));
                        isError = true;
                    }
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG039() ));
                    isError = true;
                }

            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG040() ));
                isError = true;
            }
    }
    
    public void quickSave()
    {
        save();
        if(isError != true)
        {
            againLoad();
        }
        
    }
    
    public pageReference saveNClose()
    {
        save();
        if(isError != true)
        {
            PageReference pageRef = new PageReference('/apex/CONF_ManageViews');
            pageRef.setRedirect(true);
            return pageRef; 
        }
        return null;
    }
    
    public pageReference Cancel()
    {
        PageReference pageRef = new PageReference('/apex/CONF_ManageViews');
        pageRef.setRedirect(true);
        return pageRef; 
    }
    
    public pageReference saveNAssign()
    {
        save();
        if(isError != true)
        {
            PageReference pageRef = new PageReference('/apex/CONF_ManageViewPermission');
            pageRef.getParameters().put('SVMX_PrcssId', strViewId);
            pageRef.getParameters().put('SVMX_RetURL', '/apex/CONF_SetupViews?SVMX_ViewId='+strViewId );
            pageRef.setRedirect(true);
            return pageRef; 
        }
        return null;
    }
    
    public pageReference assign()
    {
            PageReference pageRef = new PageReference('/apex/CONF_ManageViewPermission');
            pageRef.getParameters().put('SVMX_PrcssId', strViewId);
            pageRef.getParameters().put('SVMX_RetURL', '/apex/CONF_SetupViews?SVMX_ViewId='+strViewId );
            pageRef.setRedirect(true);
            return pageRef; 

    }
    
    
    
    public void moveInWOFild()
    {



       system.debug('lstSelctFilds'+lstSelctFilds); 




        if(strFildOut.size() > 0)
        {
          for(String srtFld : strFildOut)
          {
              mapFildOut.remove(srtFld);
              if(mapFildSelect.containskey(srtFld))
                mapFildIN.put(srtFld, mapFildSelect.get(srtFld));
              createCfgDtaFrFilDLst(srtFld, lstSelctFilds.size()+1);
          }
        }   
        slctOptnIN.clear();

        

        system.debug('mapFildSelect'+mapFildSelect);
        if(lstSelctFilds.size() > 0)
        {
          for(SVMXC__ServiceMax_Config_Data__c objCgfDta : lstSelctFilds)
          {
              if(mapFildSelect.containskey(objCgfDta.SVMXC__Field_Name__c))
                slctOptnIN.add(new SelectOption(objCgfDta.SVMXC__Field_Name__c , mapFildSelect.get(objCgfDta.SVMXC__Field_Name__c)));
          }
        }    
        slctOptnOut.clear();
        if(mapFildOut.size() > 0)
        {
          for(String getNm : mapFildOut.keySet())
          {
              if(mapFildSelect.containskey(getNm))
                slctOptnOut.add(new SelectOption(getNm , mapFildSelect.get(getNm)));
          }
          slctOptnOut = sortingSelectOption(slctOptnOut);
        }    








        

    }
    
    
    public void moveOutWOFild()
    {



        isErMsgBlk = true;
        boolean isName = false;




        for(String srtFld : strFildIN)
        {
            if(srtFld == 'Name')
                isName = true;
        }
        if(isName != true)
        {
            for(String srtFld : strFildIN)
            {
                mapFildIN.remove(srtFld);
                if(mapFildSelect.containskey(srtFld))
                  mapFildOut.put(srtFld , mapFildSelect.get(srtFld));
                
                List<SVMXC__ServiceMax_Config_Data__c> lstTmp = new List<SVMXC__ServiceMax_Config_Data__c>();
                lstTmp = lstSelctFilds.deepClone();
                lstSelctFilds.clear();
                Integer i =1 ;
                for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstTmp)
                {
                    if(objCfgDta.SVMXC__Field_Name__c != srtFld)
                    {
                        objCfgDta.SVMXC__Sequence__c = i;
                        i++;
                        lstSelctFilds.add(objCfgDta);
                    }
                }
                lstTmp.clear();
            }
            slctOptnIN.clear();
            for(SVMXC__ServiceMax_Config_Data__c objCgfDta : lstSelctFilds)
            {
                if(mapFildSelect.containskey(objCgfDta.SVMXC__Field_Name__c))
                  slctOptnIN.add(new SelectOption(objCgfDta.SVMXC__Field_Name__c , mapFildSelect.get(objCgfDta.SVMXC__Field_Name__c)));
            }
            
            slctOptnOut.clear();
            for(String getNm : mapFildOut.keySet())
            {
                if(mapFildSelect.containskey(getNm))
                  slctOptnOut.add(new SelectOption(getNm , mapFildSelect.get(getNm)));
            }
            slctOptnOut = sortingSelectOption(slctOptnOut);



        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG045()+' : '+mapFildIN.get('Name')));
        }
    }
  public void Up()
    {
        isErMsgBlk = true;
        boolean isName = false;
        for(String srtFld : strFildIN)
        {
            if(srtFld == 'Name')
                isName = true;
        }
        if(isName != true)
        {
            
            Integer SrlNo = 2;
            for(String fldNm : strFildIN)
            {
                List<SVMXC__ServiceMax_Config_Data__c> lstTmp = new List<SVMXC__ServiceMax_Config_Data__c>();
                lstTmp = lstSelctFilds.deepClone();
                Integer intSect;
                for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstTmp)
                {
                    if(objCfgDta.SVMXC__Field_Name__c == fldNm)
                    {
                        intSect = objCfgDta.SVMXC__Sequence__c.intValue();
                    }
                }
                
                if(intSect != SrlNo)
                {
                    if(intSect > SrlNo)
                    intSect--;
                    lstSelctFilds.clear();
                    for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstTmp)
                    {
                        if(objCfgDta.SVMXC__Field_Name__c != fldNm)
                        {
                            if(intSect == objCfgDta.SVMXC__Sequence__c.intValue())
                            {
                                createCfgDtaFrFilDLst(fldNm , lstSelctFilds.size()+1);
                            }
                            createCfgDtaFrFilDLst(objCfgDta.SVMXC__Field_Name__c , lstSelctFilds.size()+1);
                        }
                    }
                }
                SrlNo++;
            }
            slctOptnIN.clear();
            for(SVMXC__ServiceMax_Config_Data__c objCgfDta : lstSelctFilds)
            {
                if(mapFildSelect.containskey(objCgfDta.SVMXC__Field_Name__c))
                  slctOptnIN.add(new SelectOption(objCgfDta.SVMXC__Field_Name__c , mapFildSelect.get(objCgfDta.SVMXC__Field_Name__c)));
            }
        }
        else
        {



            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG045()+' : '+mapFildIN.get('Name')));
        }
    }
    public void Down()
    {
        isErMsgBlk = true;
        boolean isName = false;
        for(String srtFld : strFildIN)
        {
            if(srtFld == 'Name')
                isName = true;
        }
        if(isName != true)
        {
            List<String> lstTmpSrt = new List<String>();
            for(integer i = strFildIN.size()-1 ; i >= 0 ; i--)
            {
                lstTmpSrt.add(strFildIN[i]);
            }
            
            
            Integer SrlNo = lstSelctFilds.size();
            for(String fldNm : lstTmpSrt)
            {
                List<SVMXC__ServiceMax_Config_Data__c> lstTmp = new List<SVMXC__ServiceMax_Config_Data__c>();
                lstTmp = lstSelctFilds.deepClone();
                Integer intSect;
                for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstTmp)
                {
                    if(objCfgDta.SVMXC__Field_Name__c == fldNm)
                    {
                        intSect = objCfgDta.SVMXC__Sequence__c.intValue();
                    }
                }
                
                if(intSect != SrlNo)
                {
                    if(intSect < SrlNo)
                    intSect++;
                    lstSelctFilds.clear();
                    for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstTmp)
                    {
                        if(objCfgDta.SVMXC__Field_Name__c != fldNm)
                        {
                            createCfgDtaFrFilDLst(objCfgDta.SVMXC__Field_Name__c , lstSelctFilds.size()+1);
                            if(intSect == objCfgDta.SVMXC__Sequence__c.intValue())
                            {
                                createCfgDtaFrFilDLst(fldNm , lstSelctFilds.size()+1);
                            }
                            
                        }
                    }
                }
                SrlNo--;
            }
            slctOptnIN.clear();
            for(SVMXC__ServiceMax_Config_Data__c objCgfDta : lstSelctFilds)
            {
                if(mapFildSelect.containskey(objCgfDta.SVMXC__Field_Name__c))
                  slctOptnIN.add(new SelectOption(objCgfDta.SVMXC__Field_Name__c , mapFildSelect.get(objCgfDta.SVMXC__Field_Name__c)));
            }
        }
        else
        {



            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG045()+' : '+mapFildIN.get('Name')));
        }
            
    }
    public void Top()
    {
        isErMsgBlk = true;
        boolean isName = false;
        for(String srtFld : strFildIN)
        {
            if(srtFld == 'Name')
                isName = true;
        }
        if(isName != true)
        {
            if(strFildIN.size() != 0)
            {
                List<SVMXC__ServiceMax_Config_Data__c> lstTmp = new List<SVMXC__ServiceMax_Config_Data__c>();
                lstTmp = lstSelctFilds.deepClone();
                lstSelctFilds.clear();
                createCfgDtaFrFilDLst('Name' , lstSelctFilds.size()+1);
                for(String fldNm : strFildIN)
                {
                    createCfgDtaFrFilDLst(fldNm , lstSelctFilds.size()+1);
                }
                for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstTmp)
                {
                    if(objCfgDta.SVMXC__Field_Name__c != 'Name')
                    {
                        boolean isHere = true;
                        for(String fldNm : strFildIN)
                            if(fldNm == objCfgDta.SVMXC__Field_Name__c)
                                isHere = false;
                        if(isHere)
                            createCfgDtaFrFilDLst(objCfgDta.SVMXC__Field_Name__c , lstSelctFilds.size()+1);
                    }
                }
                
                slctOptnIN.clear();
                for(SVMXC__ServiceMax_Config_Data__c objCgfDta : lstSelctFilds)
                {
                    if(mapFildSelect.containskey(objCgfDta.SVMXC__Field_Name__c))
                      slctOptnIN.add(new SelectOption(objCgfDta.SVMXC__Field_Name__c , mapFildSelect.get(objCgfDta.SVMXC__Field_Name__c)));
                }
            }
        }
        else
        {



            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG045()+' : '+mapFildIN.get('Name')));
        }
    }
    public void Bottom()
    {
        isErMsgBlk = true;
        boolean isName = false;
        for(String srtFld : strFildIN)
        {
            if(srtFld == 'Name')
                isName = true;
        }
        if(isName != true)
        {

            if(strFildIN.size() != 0)
            {
                List<SVMXC__ServiceMax_Config_Data__c> lstTmp = new List<SVMXC__ServiceMax_Config_Data__c>();
                lstTmp = lstSelctFilds.deepClone();
                lstSelctFilds.clear();
                
                for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstTmp)
                {
                    boolean isHere = true;
                    for(String fldNm : strFildIN)
                        if(fldNm == objCfgDta.SVMXC__Field_Name__c)
                            isHere = false;
                    if(isHere)
                        createCfgDtaFrFilDLst(objCfgDta.SVMXC__Field_Name__c , lstSelctFilds.size()+1);
                }
                for(String fldNm : strFildIN)
                {
                    createCfgDtaFrFilDLst(fldNm , lstSelctFilds.size()+1);
                }
                
                slctOptnIN.clear();
                for(SVMXC__ServiceMax_Config_Data__c objCgfDta : lstSelctFilds)
                {
                    if(mapFildSelect.containskey(objCgfDta.SVMXC__Field_Name__c))
                      slctOptnIN.add(new SelectOption(objCgfDta.SVMXC__Field_Name__c , mapFildSelect.get(objCgfDta.SVMXC__Field_Name__c)));
                }
            }
        }
        else
        {



            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG045()+' : '+mapFildIN.get('Name')));
        }
    }
    
    public void createCfgDtaFrFilDLst(String srtFildKey, Integer serial)
    {
        SVMXC__ServiceMax_Config_Data__c objCfgDtaTemp = new SVMXC__ServiceMax_Config_Data__c();
        objCfgDtaTemp.RecordTypeId = strExpRTypeId;
        objCfgDtaTemp.SVMXC__Object_Name2__c = objSVMXPrcss.SVMXC__Source_Object_Name__c;
        objCfgDtaTemp.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        objCfgDtaTemp.SVMXC__Field_Name__c = srtFildKey;
        if(mapFildNmReLNm.containskey(srtFildKey))
          objCfgDtaTemp.SVMXC__Lookup_Field_API_Name__c = mapFildNmReLNm.get(srtFildKey);
        objCfgDtaTemp.SVMXC__Sequence__c = serial;
        
        lstSelctFilds.add(objCfgDtaTemp);
    }






    

    //custom labels
    public String getHLPURL() {return System.label.CONF033_HLPURL1;}
    public String getTAG001() {return System.label.CONF033_TAG008;}//'Configure Custom View'
    public String getTAG002() {return System.label.COMM001_TAG064;}//'Help'
    public String getTAG003() {return System.label.COMM001_TAG053;}//'Quick Save'
    public String getTAG004() {return System.label.COMM001_TAG054;}//'Save & Close'
    public String getTAG005() {return System.label.CONF033_TAG009;}//'Save & Assign'
    public String getTAG006() {return System.label.COMM001_TAG040;}//'Cancel'
    public String getTAG007() {return System.label.CONF033_TAG005;}//'View Name'
    public String getTAG008() {return System.label.CONF033_TAG004;}//'View Id'
    public String getTAG009() {return System.label.COMM001_TAG017;}//'Description'
    public String getTAG010() {return System.label.CONF033_TAG010;}//'View Object'
    public String getTAG011() {return System.label.CONF033_TAG011;}//'Filter By Owner'
    public String getTAG012() {return System.label.CONF033_TAG012;}//'Optional: Using the expression builder below, define filter criteria to apply on Work Order records'
    public String getTAG013() {return System.label.COMM002_TAG024;}//'Advanced Expression'
    public String getTAG014() {return System.label.COMM002_TAG027;}//'Field'
    public String getTAG015() {return System.label.COMM002_TAG028;}//'Operator'
    public String getTAG016() {return System.label.COMM002_TAG029;}//'Value'
    public String getTAG017() {return System.label.COMM002_TAG005;}//'None'
    
    public String getTAG018() {return System.label.COMM002_TAG006;}//'Equals'
    public String getTAG019() {return System.label.COMM002_TAG007;}//'Not Equal'
    public String getTAG020() {return System.label.COMM002_TAG008;}//'Greater Than'
    public String getTAG021() {return System.label.COMM002_TAG009;}//'Greater or Equal To'
    public String getTAG022() {return System.label.COMM002_TAG010;}//'Less Than'
    public String getTAG023() {return System.label.COMM002_TAG011;}//'Less or Equal To'
    public String getTAG024() {return System.label.COMM002_TAG012;}//'Starts With'
    public String getTAG025() {return System.label.COMM002_TAG013;}//'Contains'
    public String getTAG026() {return System.label.COMM002_TAG014;}//'Does Not Contain'
    public String getTAG027() {return System.label.COMM002_TAG015;}//'Includes'
    public String getTAG028() {return System.label.COMM002_TAG016;}//'Excludes'
    public String getTAG029() {return System.label.COMM002_TAG022;}//'Is Null'
    public String getTAG030() {return System.label.COMM002_TAG023;}//'Is Not Null'
    
    
    
    public String getTAG031() {return System.label.COMM001_TAG041;}//'Processing...'
    public String getTAG032() {return System.label.CONF033_TAG013;}//'Choose one or more fields to be displayed in the result'
   // public String getTAG033() {return System.label.CONF033_TAG014;}//'Object'
    //public String getTAG034() {return System.label.CONF033_TAG015;}//'Object Type'
    public String getTAG036() {return System.label.COMM001_TAG058;}//'Record(s) Save Sucessfully'
    public String getTAG037() {return System.label.CONF033_TAG024;}//'Assign'
    public String getTAG039() {return System.label.CONF033_TAG016;}//'View Id should be unique'
    public String getTAG040() {return System.label.COMM001_TAG059;}//'Please enter values for all the mandatory fields'
    public String getTAG041() {return System.label.CONF033_TAG006;}//'View For'
    
    public String getTAG042() {return System.label.COMM001_TAG036;}//'Add'
    public String getTAG043() {return System.label.COMM001_TAG037;}//'Remove'
    public String getTAG044() {return System.label.COMM002_TAG027;}//'Field Name'
    public String getTAG046() {return System.label.COMM001_TAG060;}//Top
    public String getTAG047() {return System.label.COMM001_TAG061;}//UP
    public String getTAG048() {return System.label.COMM001_TAG062;}//Down
    public String getTAG049() {return System.label.COMM001_TAG063;}//Bottom
    public String getTAG045() {return System.label.CONF033_TAG027;}//'Work Order Number should not be removed or reordered'
    
}