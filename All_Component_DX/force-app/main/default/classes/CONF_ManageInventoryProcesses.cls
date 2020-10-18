public with sharing class CONF_ManageInventoryProcesses
{
    public boolean IsEnterpriseLicense = false;
    Boolean isCaseObjAvailable = true;
    public Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();
    SVMXC.COMM_Utils Utils = new SVMXC.COMM_Utils();
    public List<SelectOption>  FldListOpt = new List<SelectOption>(); 
    public void RetriveRefFld()
    {
        UpdateExpressionFields(RelatedCloserExpressions, integer.valueOf(selectedIndex), schema.Displaytype.DOUBLE);
    }
    public void UpdateExpressionFields(COMM_SVMXC_Search_Expressions oExpressions, integer iIndex, schema.Displaytype DT)
    {
        ClearSelOptList(oExpressions.lstExpressions[iIndex-1].FieldsList);
        RetriveUpdateableField(oExpressions.lstExpressions[iIndex-1].ObjectName , oExpressions.lstExpressions[iIndex-1].FieldsList, null, null, DT);
    }
    
    public transient List<SelectOption> ReferenceField = new  List<SelectOption>();
    public List<SelectOption> getReferenceField()
    {
        ReferenceField = new  List<SelectOption>();
        ReferenceField.add(new selectOption('SVMX.NONE', TU.getTAG062()));
        if(objSVMXPro.Is_Multiline_Transaction)
        {
           if(IsValidStringNotNone(objSVMXPro.Child_Object_Name))
               RetriveField2(objSVMXPro.Child_Object_Name, ReferenceField, null, null, schema.Displaytype.REFERENCE);
        }
        else
        {
            if(IsValidStringNotNone(objSVMXPro.Parent_Object_Name))
                RetriveField2(objSVMXPro.Parent_Object_Name, ReferenceField, null, null, schema.Displaytype.REFERENCE); 
        }
        return ReferenceField;
    }
    public List<SelectOption> getLstStockbleLocation()
    {
        return TU.getLstStockbleLocation();
    }
     
     public String SelStockbleLocation = '';
     public String getSelStockbleLocation()
     {
        return TU.getSelStockbleLocation(objSVMXPro);
     }
     public void setSelStockbleLocation(String s)
     {
        SelStockbleLocation = s;
        objSVMXPro = TU.setSelStockbleLocation(SelStockbleLocation, objSVMXPro);
     }
     
     public string SelHdrObj = '';
     public string SelLineObj = '';
        
     public string graytab = 'Nograyscrean';
        public string getgraytab() { if (isSearch || isdateSearch) return 'grayscrean'; else return 'Nograyscrean';}
        public void setgraytab(string str) {this.graytab= str;}
    
    public Boolean Displayvalue = false;
    public Boolean getDisplayvalue(){return Displayvalue;}
    //Jaysukh : Commented below code for Story BAC-3216
    /*
    public Boolean renderedValue = true;
    public Boolean getrenderedValue(){return renderedValue;}
    */
    public string pID = System.currentPageReference().getParameters().get('pid');
    public string cID = System.currentPageReference().getParameters().get('cid');
    SVMXC__ServiceMax_Processes__c SVMXPro = new SVMXC__ServiceMax_Processes__c(); 
    SVMXC__ServiceMax_Processes__c extSVMXPro = new SVMXC__ServiceMax_Processes__c();
    
    public SVMXC.COMM_Inventory_Classes.InventoryProcess objSVMXPro = new SVMXC.COMM_Inventory_Classes.InventoryProcess();
        public SVMXC.COMM_Inventory_Classes.InventoryProcess getobjSVMXPro() {return this.objSVMXPro;}
        public void setobjSVMXPro(SVMXC.COMM_Inventory_Classes.InventoryProcess sP){this.objSVMXPro = sP;}
    /*commented public variable for defect: 6999
    List<SelectOption> lstHdrObjOpt = new List<SelectOption>();
    public Map<String,String>  lineObjApiLable = new Map<String,String>();
    public Map<String,String>  LineObjApiLocalName = new Map<String,String>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstHdrCloCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstChildCloCriteria = new List<SVMXC__ServiceMax_Config_Data__c>(); 
    public Map<String, Schema.SObjectType> allobjs = new Map<String, Schema.SObjectType>();
    public List<string> st = new list<string>();
    public List<SVMXC__ServiceMax_Processes__c> lstModule = new list<SVMXC__ServiceMax_Processes__c>();
    Map<String, SVMXC__ServiceMax_Config_Data__c> SettingObjectList;
    public List<RecordType> allRecType = new List<RecordType>();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('CONF010');
    public SVMXC.COMM_Utils_ManageModules CommUtilManageModules = new SVMXC.COMM_Utils_ManageModules();
    public SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    public SVMXC.COMM_Utils_ManageTags commUtilPL = new SVMXC.COMM_Utils_ManageTags();
    public Map<string, SVMXC__ServiceMax_Tags__c> mapPLTags = new map<string, SVMXC__ServiceMax_Tags__c>();
    SVMXC.COMM_Inventory_Classes.InventoryProcessResult oInventoryProcessResult;
    variable commented complete */
   // Commented for Defect: 3515 - Rajat 
  /*  public List<SelectOption> getlstHdrObjOpt() 
    { 
        List<SelectOption> lstHdrObjOpt = new List<SelectOption>();//this line is added for defect: 6999
        lstHdrObjOpt.addAll(TU.sortingSelectOption(mapHdrObjOpt.values(), true));
        
        return lstHdrObjOpt;
    }*/
    
    // Here we are accessing the Wrapper class (FieldListWrapper) of class (CONF_SetupAction) to handle more than 1000 objects in a single list. 
    //--------- Start Added for the Defect : BAC-3515 - Rajat --------- 
  public CONF_SetupAction.FieldListWrapper lstHdrObjOpt{
        get{
            if(lstHdrObjOpt==null){
                  lstHdrObjOpt=new CONF_SetupAction.FieldListWrapper();
                  List<SelectOption> lstHdrObjOpt1 = new List<SelectOption>(); 
                  lstHdrObjOpt1=TU.sortingSelectOption(mapHdrObjOpt.values(), true);
                  for(Integer i=0;i<lstHdrObjOpt1.size();i++){
                        lstHdrObjOpt.add(lstHdrObjOpt1[i]);
                  }
            }
            return lstHdrObjOpt;
        }
        set;
    }
    public Boolean getIsSecondListHasItemObject(){
        Integer sizeOfList = lstHdrObjOpt.get1stList().size();
        if(sizeOfList > 0)
            return true;
        else
            return false;
    }
    //--------- End---------

    List<SelectOption> lstLineObjOpt = new List<SelectOption>();
    public List<SelectOption> getlstLineObjOpt()
    {
        //lstLineObjOpt = new List<SelectOption>();
        //lstLineObjOpt.addAll(TU.sortingSelectOption(mapLineObjOpt.values(), true));
        return lstLineObjOpt;
    }

    public string getlblHdrObj(){return lblHdrObj;}
    public void setlblHdrObj(string str) {this.lblHdrObj = str;}
    public string getlblLineObj(){return lblLineObj;}
    public void setlblLineObj(string str) {this.lblLineObj = str;}

    public Map<String, SelectOption>  mapHdrObjOpt = new Map<String, SelectOption>();
    public Map<String, SelectOption>  mapLineObjOpt = new Map<String, SelectOption>();
    public Map<String,String>  HeaderObjApiLocalName = new Map<String,String>();
    public Map<String,String>  HdrObjApiLable = new Map<String,String>();
   
    

    public Map<String,Schema.Displaytype>  LineObjfldDispType = new Map<String,Schema.Displaytype>();

    
    public COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
        public COMM_SVMXC_Search_Expressions getHdrExpressions() {return HdrExpressions;}
    public COMM_SVMXC_Search_Expressions LineExpressions  = new COMM_SVMXC_Search_Expressions(2);
        public COMM_SVMXC_Search_Expressions getLineExpressions() {return LineExpressions;}
        
    public COMM_SVMXC_Search_Expressions HdrCloserExpressions = new COMM_SVMXC_Search_Expressions(2,false,false,false,false,true,'eq', '');
        public COMM_SVMXC_Search_Expressions getHdrCloserExpressions() {return HdrCloserExpressions;}
    public COMM_SVMXC_Search_Expressions LineCloserExpressions = new COMM_SVMXC_Search_Expressions(2,false,false,false,false,true,'eq', '');
        public COMM_SVMXC_Search_Expressions getLineCloserExpressions() {return LineCloserExpressions;}
    public COMM_SVMXC_Search_Expressions RelatedCloserExpressions  = new COMM_SVMXC_Search_Expressions(2,true,false,false,false,false,'','');
        public COMM_SVMXC_Search_Expressions getRelatedCloserExpressions() {return RelatedCloserExpressions;}
    
    public String lblHdrObjAPIName;
    public String lblLineObjAPIName;
    public String lblHdrObj;
    public String lblLineObj;
    public boolean isEditMode = false;
        public boolean getisEditMode() {return this.isEditMode;}
    public boolean isCloneMode = false;
        public boolean getisCloneMode() {return this.isCloneMode;}
    public boolean isNewMode = false;
        public boolean getisNewMode() {return this.isNewMode;}
        
    public List<selectoption> Hdrfldlist = new List<selectoption>();  //list of fields values
        //public List<selectoption> getHdrFldlist() {return TU.sortingSelectOption(Hdrfldlist, true);}
   
   // Implementation for List of serial number field
    public transient List<selectoption> LongTextFields = new List<selectoption>();  //list of fields values
        public List<selectoption> getLongTextFields() 
        {
            try
            {
                LongTextFields = new List<selectoption>();
                if (!objSVMXPro.Is_Multiline_Transaction && IsValidStringNotNone(objSVMXPro.Parent_Object_Name)) 
                        RetriveField(objSVMXPro.Parent_Object_Name, LongTextFields, null, null, schema.Displaytype.TextArea); 
                else if (IsValidStringNotNone(objSVMXPro.Child_Object_Name)) 
                        RetriveField(objSVMXPro.Child_Object_Name , LongTextFields, null, null, schema.Displaytype.TextArea); 
                if (LongTextFields.size() == 0)
                    LongTextFields.add(new SelectOption('SVMX.NONE',TU.getTAG062()));
                else if(LongTextFields.size() != 1 )
                    LongTextFields.add(0, new SelectOption('SVMX.NONE',TU.getTAG062()));
                return LongTextFields;
            }
            catch(exception ex)
            {
                AddException(ex.getMessage());
            }
            return null;
        }
        
    
    public transient List<selectoption> Qtyfldlist = new List<selectoption>();  //list of fields values
        public List<selectoption> getQtyFldlist() 
        {
            try
            {
                Qtyfldlist = new List<selectoption>();
                if (!objSVMXPro.Is_Multiline_Transaction && IsValidStringNotNone(objSVMXPro.Parent_Object_Name)) 
                        RetriveField(objSVMXPro.Parent_Object_Name, Qtyfldlist, null, null, schema.Displaytype.DOUBLE); 
                else if (IsValidStringNotNone(objSVMXPro.Child_Object_Name)) 
                        RetriveField(objSVMXPro.Child_Object_Name , Qtyfldlist, null, null, schema.Displaytype.DOUBLE); 
                if (Qtyfldlist.size() == 0)
                    Qtyfldlist.add(new SelectOption('SVMX.NONE',TU.getTAG062()));
                else if(Qtyfldlist.size() != 1 )
                    Qtyfldlist.add(0, new SelectOption('SVMX.NONE',TU.getTAG062()));
                return Qtyfldlist;
            }
            catch(exception ex)
            {
                AddException(ex.getMessage());
            }
            return null;
        }
        public transient List<selectoption> ProReffldlist = new List<selectoption>();  //list of fields values
        public List<selectoption> getProRefFldlist() 
        {
            try
            {
                ProReffldlist = new List<selectoption>();
                if (!objSVMXPro.Is_Multiline_Transaction && IsValidStringNotNone(objSVMXPro.Parent_Object_Name)) 
                        RetriveField(objSVMXPro.Parent_Object_Name, ProReffldlist, null, null, schema.Displaytype.REFERENCE , 'Product2'); 
                else if (IsValidStringNotNone(objSVMXPro.Child_Object_Name)) 
                        RetriveField(objSVMXPro.Child_Object_Name , ProReffldlist, null, null , schema.Displaytype.REFERENCE, 'Product2'); 
                if (ProReffldlist.size() == 0)
                    ProReffldlist.add(new SelectOption('SVMX.NONE',TU.getTAG062()));
                else if(ProReffldlist.size() != 1)
                    ProReffldlist.add(0, new SelectOption('SVMX.NONE',TU.getTAG062()));
                return ProReffldlist;
            }
            catch(exception ex)
            {
                AddException(ex.getMessage());
            }
            return null;
        }
        public transient List<selectoption> HdrReffldlist = new List<selectoption>();  //list of fields values
        public List<selectoption> getHdrReffldlist() 
        {
            try
            {
                HdrReffldlist = new List<selectoption>();
                if (IsValidStringNotNone(objSVMXPro.Child_Object_Name)) 
                        RetriveField(objSVMXPro.Child_Object_Name , HdrReffldlist, null, null , schema.Displaytype.REFERENCE, objSVMXPro.Parent_Object_Name);
                if (HdrReffldlist.size() == 0)
                    HdrReffldlist.add(new SelectOption('SVMX.NONE',TU.getTAG062()));
                else if(HdrReffldlist.size() != 1)
                    HdrReffldlist.add(0, new SelectOption('SVMX.NONE',TU.getTAG062()));
                return HdrReffldlist;
            }
            catch(exception ex)
            {
                AddException(ex.getMessage());
            }
            return null;
        }
    public transient List<selectoption> fldSourceLoc = new List<selectoption>();  //list of fields values
        public List<selectoption> getfldSourceLoc()
        {
            try
            {
                fldSourceLoc = new List<selectoption>();
                if (objSVMXPro.Is_Source_Location_From_Header && IsValidStringNotNone(objSVMXPro.Parent_Object_Name)) 
                    RetriveField(objSVMXPro.Parent_Object_Name, fldSourceLoc, null, null, schema.Displaytype.REFERENCE , 'SVMXC__Site__c'); 
                else if(IsValidStringNotNone(objSVMXPro.Child_Object_Name)) 
                    RetriveField(objSVMXPro.Child_Object_Name , fldSourceLoc, null, null, schema.Displaytype.REFERENCE , 'SVMXC__Site__c'); 
                if (fldSourceLoc.size() == 0)
                    fldSourceLoc.add(new SelectOption('SVMX.NONE',TU.getTAG062()));
                else if(fldSourceLoc.size() != 1 )
                    fldSourceLoc.add(0, new SelectOption('SVMX.NONE',TU.getTAG062()));
                return fldSourceLoc;
            }
            catch(exception ex)
            {
                AddException(ex.getMessage());
            }
            return null;
        }
    public transient List<selectoption> fldTargetLoc = new List<selectoption>();  //list of fields values
        public List<selectoption> getfldTargetLoc() 
        {
            try
            {
                fldTargetLoc = new List<selectoption>();
                if (objSVMXPro.Is_Target_Location_From_Header && IsValidStringNotNone(objSVMXPro.Parent_Object_Name)) 
                    RetriveField(objSVMXPro.Parent_Object_Name, fldTargetLoc, null, null, schema.Displaytype.REFERENCE , 'SVMXC__Site__c'); 
                else if (IsValidStringNotNone(objSVMXPro.Child_Object_Name)) 
                    RetriveField(objSVMXPro.Child_Object_Name , fldTargetLoc, null, null, schema.Displaytype.REFERENCE , 'SVMXC__Site__c'); 
                if (fldTargetLoc.size() == 0)
                    fldTargetLoc.add(new SelectOption('SVMX.NONE',TU.getTAG062()));
                else if(fldTargetLoc.size() != 1 )
                    fldTargetLoc.add(0, new SelectOption('SVMX.NONE',TU.getTAG062()));
                return fldTargetLoc;
            }
            catch(exception ex)
            {
                AddException(ex.getMessage());
            }
            return null;
        }
    public List<selectoption> lstChildRecordType = new List<selectoption>();  //list of fields values
        public List<selectoption> getlstChildRecordType() 
        {
            lstChildRecordType = TU.getlstChildRecordType(lstChildRecordType, RTypeMap, objSVMXPro);
            return lstChildRecordType;
        }
     public boolean getIsChildRecordTypeRequired()
     {
        return TU.getIsChildRecordTypeRequired(RTypeMap, objSVMXPro);
     }
    public List<selectoption> Linefldlist = new List<selectoption>();
        /*public List<selectoption> getLineFldlist() 
        {
            try
            {
                return TU.sortingSelectOption(Linefldlist, true);
            }
            catch(exception ex)
            {
                AddException(ex.getMessage());
            }
            return null;
        }*/
    public transient List<SelectOption> lstProductFields = new List<SelectOption>(); //list of line object values
        public List<SelectOption> getlstProductFields()
        {
            lstProductFields = new List<SelectOption>(); 
            if(objSVMXPro.Is_Multiline_Transaction) 
                lstProductFields.addAll(Linefldlist); 
            else 
                lstProductFields.addAll(Hdrfldlist);
            return lstProductFields;
        } 
    public List<SelectOption> lstActionOnQty = new List<SelectOption>();
        public List<SelectOption> getlstActionOnQty(){return this.lstActionOnQty;}
    public List<SelectOption> lstStatus = new List<SelectOption>();
        public List<SelectOption> getlstStatus(){return this.lstStatus;}
    public List<SelectOption> lstProduct2Fields = new List<SelectOption>();
        public List<SelectOption> getlstProduct2Fields(){return this.lstProduct2Fields;}
    public transient List<SelectOption> lstHdrStockHistoryFields = new List<SelectOption>();
        public List<SelectOption> getlstHdrStockHistoryFields()
        {
            try
            {
                if(isInventoryEnabled)
                {
                    lstHdrStockHistoryFields = new List<SelectOption>();
                    if (IsValidStringNotNone(objSVMXPro.Parent_Object_Name)) 
                        RetriveField('SVMXC__Stock_History__c', lstHdrStockHistoryFields, null, null, schema.Displaytype.REFERENCE ,objSVMXPro.Parent_Object_Name); 
                    if (lstHdrStockHistoryFields.size() == 0)
                        lstHdrStockHistoryFields.add(new SelectOption('SVMX.NONE',TU.getTAG062()));
                    else if(lstHdrStockHistoryFields.size() != 1 )
                        lstHdrStockHistoryFields.add(0,new SelectOption('SVMX.NONE',TU.getTAG062()));
                    return lstHdrStockHistoryFields;
                }
            }
            catch(exception ex)
            {
                AddException(ex.getMessage());
            }
            return null;
        }
     public transient List<SelectOption> lstLineStockHistoryFields = new List<SelectOption>();
        public List<SelectOption> getlstLineStockHistoryFields()
        {
            try
            {
                if(isInventoryEnabled)
                {
                    lstLineStockHistoryFields = new List<SelectOption>();
                    if (objSVMXPro.Is_Multiline_Transaction && IsValidStringNotNone(objSVMXPro.Child_Object_Name)) 
                        RetriveField( 'SVMXC__Stock_History__c', lstLineStockHistoryFields, null, null , schema.Displaytype.REFERENCE, objSVMXPro.Child_Object_Name);   
                    if (lstLineStockHistoryFields.size() == 0)
                        lstLineStockHistoryFields.add(new SelectOption('SVMX.NONE',TU.getTAG062()));
                    else if(lstLineStockHistoryFields.size() != 1 )
                        lstLineStockHistoryFields.add(0,new SelectOption('SVMX.NONE',TU.getTAG062()));
                    return lstLineStockHistoryFields;
                }
            }
            catch(exception ex)
            {
                AddException(ex.getMessage());
            }
            return null;
        }
    public List<SVMXC__ServiceMax_Config_Data__c> lstLinecriteria = new List<SVMXC__ServiceMax_Config_Data__c>();

    public List<SVMXC__ServiceMax_Config_Data__c> lstHdrcriteria = new List<SVMXC__ServiceMax_Config_Data__c>();  //list of criteria value
        
    public integer getintHdrCriSize (){ return this.lstHdrcriteria.size();}
    public integer getintlineCriSize (){ return this.lstLinecriteria.size();}
    
    public string strHdrAdvOption;
        public string getstrHdrAdvOption(){return this.strHdrAdvOption;}
        public void setstrHdrAdvOption(string str) {this.strHdrAdvOption = str;}
    public string strLineAdvOption;
        public string getstrLineAdvOption(){return this.strLineAdvOption;}
        public void setstrLineAdvOption(string str) {this.strLineAdvOption = str;}
        
    public string strLineErrorMsg;
        public string getstrLineErrorMsg(){return this.strLineErrorMsg;}
        public void setstrLineErrorMsg(string str) {this.strLineErrorMsg = str;}
    public string strHdrErrorMsg;
        public string getstrHdrErrorMsg(){return this.strHdrErrorMsg;}
        public void setstrHdrErrorMsg(string str) {this.strHdrErrorMsg = str;}
        
    public string SelectedIndex;
        public string getSelectedIndex (){return this.SelectedIndex;}
        public void setSelectedIndex (string str){this.SelectedIndex = str;}
   
    boolean isInventoryEnabled = false;
        public boolean getisInventoryEnabled(){return isInventoryEnabled;}
    boolean isSeedDataComplate = true;
        public boolean getisSeedDataComplate(){return isSeedDataComplate;}
        
    public Boolean getDisableValue(){return disableValue;}    

      
        
   //Global variable declatration

   Boolean disableValue =false;


  
   
   map<string, selectOption> mapModule = new map<string, selectOption>();
    //Constractor call

   
   public  map<String,map<string, SelectOption>> RTypeMap = new map<String,map<string, SelectOption>>();
    static string ExpressionFields = 'id, SVMXC__Object_Name__c, RecordTypeID, SVMXC__Lookup_Field_API_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Inventory_Process__c, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c';
    static string ProcessFields = 'id, Name, SVMXC__Parent_Error_Msg__c,SVMXC__Child_Error_Msg__c,SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ModuleId__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Submodule__c, SVMXC__IsStandard__c, SVMXC__Name__c, SVMXC__Child_Object_Criteria__c, SVMXC__Parent_Object_Criteria__c';
    Schema.SObjectType SObjTypeProcuctStock;
    Set<String> RECTYPEOBJS = new Set<String>();//newly added to deal with view state defect 02/03/2011
    public CONF_ManageInventoryProcesses()
    {
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, Schema.SObjectType> allobjs = new Map<String, Schema.SObjectType>();//this is added for defect: 6999
        Map<String, SVMXC__ServiceMax_Config_Data__c> SettingObjectList;//this is added for defect: 6999
        List<SVMXC__ServiceMax_Processes__c> lstModule = new list<SVMXC__ServiceMax_Processes__c>();//this is added for defect: 6999
        // To Hide/Show SET040, SET041
        map<String, String> mapSettings = commSettings.SVMX_getSettingList('SFM001');
        
        //Defect fix OEM : 013931 Anchal 
        //Check if the customer is Titanium customer or not
        isCaseObjAvailable = Utils.SVMX_isObjectLicensed('Case');
        
        //Jaysukh : Commented below code for Story BAC-3216
        /*
        if(mapSettings.containsKey('SET004') && mapSettings.get('SET004') != null)
            renderedValue = Boolean.valueof(mapSettings.get('SET004')); 
        */  
        try
        {//*/
            
             //Added by amar on 19/Aug/10 Due to OEM Exercises
            IsEnterpriseLicense = utils.SVMX_isEnterpriseLicense();
            if(!IsEnterpriseLicense)
            {
                 PermitedStndObjMap = utils.SVMX_getPermittedStandardObjectList();
            }
            system.debug('PermitedStndObjMap'+PermitedStndObjMap);
            Map<String, Schema.SObjectType> tempallObjs = Schema.getGlobalDescribe();
            for(Schema.SObjectType lON : tempallObjs.values()) //Loop List of all Objects and describe each
            {
                Schema.DescribeSObjectResult D = lON.getDescribe();
                allObjs.put(D.getName(), lON);
            }
            
            /*SObjTypeProcuctStock = allObjs.get('SVMXC__Product_Stock__c');
            if(SObjTypeProcuctStock == null)
                SObjTypeProcuctStock = allObjs.get('Product_Stock__c');
            if(SObjTypeProcuctStock != null)*/
            isInventoryEnabled = true;
            RECTYPEOBJS.add('SVMXC__ServiceMax_Processes__c');
            RECTYPEOBJS.add('SVMXC__ServiceMax_Config_Data__c');
            QueryRecTypes();
            /*allRecType = database.query('Select SystemModstamp,SobjectType,NamespacePrefix,Name,LastModifiedDate,LastModifiedById,IsActive,Id,DeveloperName, Description,CreatedDate,CreatedById,BusinessProcessId From RecordType');
            for(RecordType rt: allRecType)
            {
                if(RTypeMap.containsKey(rt.SobjectType))
                    RTypeMap.get(rt.SobjectType).put(rt.Name, new selectOption(rt.id, rt.Name));
                else
                {
                    map<string, SelectOption> mapTempRType = new map<string, SelectOption>();
                    mapTempRType.put(rt.Name, new selectOption(rt.id, rt.Name));
                    RTypeMap.put(rt.SobjectType,mapTempRType);
                }
            }*/ //commented to deal with view state issue



            ClearSelOptMap(mapHdrObjOpt);
            ClearSelOptMap(mapLineObjOpt);
            
            ClearSelOptList(lstLineObjOpt);
            ClearSelOptList(Hdrfldlist);
            ClearSelOptList(Linefldlist);
            ClearSelOptList(lstProduct2Fields);
            
            RetriveField('Product2', lstProduct2Fields, null, null);
            
            HdrExpressions.DefaultField = TU.getTAG062();
            HdrExpressions.DefaultOperator = TU.getTAG062();
            HdrExpressions.DefaultListValue = TU.getTAG062();
            HdrExpressions.ExpressionType = 'CRITERIA';
            HdrExpressions.ExpressionName = TU.getTAG161();
            
            LineExpressions.DefaultField = TU.getTAG062();
            LineExpressions.DefaultOperator = TU.getTAG062();
            LineExpressions.DefaultListValue = TU.getTAG062();
            LineExpressions.ExpressionType = 'CRITERIA';
            LineExpressions.ExpressionName = TU.getTAG162();
            
            HdrCloserExpressions.DefaultField = TU.getTAG062();
            HdrCloserExpressions.DefaultOperator = TU.getTAG062();
            HdrCloserExpressions.DefaultListValue = TU.getTAG062();
            HdrCloserExpressions.ExpressionType = 'UPDATES';
            HdrCloserExpressions.ExpressionName = TU.getTAG163();
            
            LineCloserExpressions.DefaultField = TU.getTAG062();
            LineCloserExpressions.DefaultOperator = TU.getTAG062();
            LineCloserExpressions.DefaultListValue = TU.getTAG062();
            LineCloserExpressions.ExpressionType = 'UPDATES';
            LineCloserExpressions.ExpressionName = TU.getTAG164();
            
            RelatedCloserExpressions.setDefaultField(TU.getTAG062());
            RelatedCloserExpressions.DefaultOperator = TU.getTAG062();
            RelatedCloserExpressions.DefaultListValue = TU.getTAG062();
            RelatedCloserExpressions.ExpressionType = 'UPDATES';
            RelatedCloserExpressions.ExpressionName = TU.getTAG165();
            
            List<SVMXC__ServiceMax_Property_Elements__c> lstSVMXPropElement = new List<SVMXC__ServiceMax_Property_Elements__c>();
            set<String> setSVMXPropElement = new set<String>();
            lstSVMXPropElement = [Select SVMXC__Element_Value__c from SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c ='ALLOWED INVENTORY HEADER' ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__ServiceMax_Property_Elements__c objPE : lstSVMXPropElement)
            setSVMXPropElement.add(objPE.SVMXC__Element_Value__c);
            for(Schema.SObjectType lON : allObjs.values()) //Loop List of all Objects and describe each
            {
                Schema.DescribeSObjectResult D = lON.getDescribe();
                if((D.isAccessible() == true && D.isCreateable() == true && D.isCustom() == true) || setSVMXPropElement.contains(D.getName()))
                {
                    //HdrObjApiLable.put(D.getName(),D.getLabel());did it for defect: 6999
                    //HeaderObjApiLocalName.put(D.getName(),D.getLocalName()); did it for defect: 6999
                    mapHdrObjOpt.put(D.getName(), new SelectOption(D.getName(),D.getLabel()));
                }
            }
            //Retrive list of SVMX-Modules
            lstmodule = database.query('Select Id, Name, SVMXC__ModuleID__c, SVMXC__SubmoduleID__c, SVMXC__Name__c, SVMXC__Module__r.Id, SVMXC__Module__r.SVMXC__ModuleID__c, SVMXC__Module__r.SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where RecordType.Name =\'Module\'');
            mapModule.put('', new selectOption('SVMX.NONE', TU.getTAG062()));
            if(lstmodule.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c oModule :lstmodule)
                {
                    mapModule.put(oModule.Id, new SelectOption(oModule.Id, oModule.SVMXC__Name__c));
                }
            }
            if(IsValidString(pID))
            {
                isEditMode = true;
                list<SVMXC__ServiceMax_Processes__c> tempSVMXPro = new list<SVMXC__ServiceMax_Processes__c>();
                tempSVMXPro = database.query('select ' + ProcessFields + ' from SVMXC__ServiceMax_Processes__c where id = :pID');
                if(tempSVMXPro != null && tempSVMXPro.size() > 0)
                {
                    SVMXPro = tempSVMXPro[0];
                    SettingObjectList = commSettings.SVMX_getSettingObjectList(SVMXPro.SVMXC__Submodule__r.SVMXC__SubmoduleID__c);
                    //svmxPLTagList = commUtilPL.SVMX_getTagRecordList(SVMXPro.SVMXC__Submodule__r.SVMXC__SubmoduleID__c); //Commented by Amar Jun18-10
                
                    objSVMXPro = new SVMXC.COMM_Inventory_Classes.InventoryProcess(SVMXPro, SettingObjectList, false);
                    disableValue = objSVMXPro.IsStandard;
                 
                    if(objSVMXPro != null && IsValidStringNotNone(objSVMXPro.Parent_Object_Name))
                    {
                        OnHdrObjSelect(); 
                        if(IsValidStringNotNone(objSVMXPro.Child_Object_Name) && objSVMXPro.Is_Multiline_Transaction)
                            getfieldnames();
                        else if(objSVMXPro.Is_Multiline_Transaction)
                             ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR , TU.getTAG093()));
                        list<SVMXC__ServiceMax_Config_Data__c> lst = database.query('select ' + ExpressionFields + ' from SVMXC__ServiceMax_Config_Data__c where SVMXC__Inventory_Process__c = :pID');
                 
                        HdrExpressions.AdvanceOption = objSVMXPro.Parent_Advanced_Option;
                        LineExpressions.AdvanceOption = objSVMXPro.Child_Advanced_Option;
                            
                        if(lst != null && lst.size() > 0)
                        {
                            for(SVMXC__ServiceMax_Config_Data__c o :lst)
                            {
                                if(o.SVMXC__Expression_Type__c == 'INV_Header_Entry_Criteria')
                                    HdrExpressions.setExpressions(o);
                                if(o.SVMXC__Expression_Type__c == 'INV_Line_Entry_Criteria')
                                    LineExpressions.setExpressions(o);
                                if(o.SVMXC__Expression_Type__c == 'INV_Header_Closure_Action')
                                {
                                    HdrCloserExpressions.setExpressions(o);
                                    //system.debug('amar'+HdrCloserExpressions.setExpressions(o));
                                }
                                if(o.SVMXC__Expression_Type__c == 'INV_Line_Closure_Action')
                                    LineCloserExpressions.setExpressions(o);
                                if(o.SVMXC__Expression_Type__c == 'INV_Related_Update_Action')
                                    RelatedCloserExpressions.setExpressions(o);
                            }
                        } 
                        
                    }
                    else
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR ,TU.getTAG093()));
                }
                else
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR ,+TU.getTAG093()));
            }
            else if(IsValidString(cID))
            {
                isCloneMode = true;
                extSVMXPro = database.query('select ' + ProcessFields + ' from SVMXC__ServiceMax_Processes__c where id = :cID');
                SettingObjectList = commSettings.SVMX_getSettingObjectList(extSVMXPro.SVMXC__Submodule__r.SVMXC__SubmoduleID__c);
                //svmxPLTagList = commUtilPL.SVMX_getTagRecordList(extSVMXPro.SVMXC__Submodule__r.SVMXC__SubmoduleID__c); //Commented by Amar jun18-10
                SVMXPro  = extSVMXPro.clone(false,true);
                SVMXPro.SVMXC__Submodule__c = null;
                objSVMXPro = new SVMXC.COMM_Inventory_Classes.InventoryProcess(SVMXPro, SettingObjectList, false);
                objSVMXPro.Submodule = '';
                objSVMXPro.IsStandard = false;
                disableValue = false;
               
                //objSVMXPro.Inventory_Submodule = null;
                OnHdrObjSelect(); 
                if(objSVMXPro.Is_Multiline_Transaction)
                    getfieldnames();
                list<SVMXC__ServiceMax_Config_Data__c> lst = database.query('select '+ ExpressionFields +' from SVMXC__ServiceMax_Config_Data__c where SVMXC__Inventory_Process__c = :cID');
                HdrExpressions.AdvanceOption = objSVMXPro.Parent_Advanced_Option;
                LineExpressions.AdvanceOption = objSVMXPro.Child_Advanced_Option;
                if(lst != null && lst.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c o :lst)
                    {
                        if(o.SVMXC__Expression_Type__c == 'INV_Header_Entry_Criteria')
                            HdrExpressions.setExpressions(o.clone(false,true));
                        if(o.SVMXC__Expression_Type__c == 'INV_Line_Entry_Criteria')
                            LineExpressions.setExpressions(o.clone(false,true));
                        if(o.SVMXC__Expression_Type__c == 'INV_Header_Closure_Action')
                            HdrCloserExpressions.setExpressions(o.clone(false,true));
                        if(o.SVMXC__Expression_Type__c == 'INV_Line_Closure_Action')
                            LineCloserExpressions.setExpressions(o.clone(false,true));
                        if(o.SVMXC__Expression_Type__c == 'INV_Related_Update_Action')
                            RelatedCloserExpressions.setExpressions(o.clone(false,true));
                    }
                } 
            }
            else
            {
                isNewMode = true;
                list<SVMXC__ServiceMax_Processes__c> lstSVMXPro = database.query('select ' + ProcessFields + ' from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = \'PORD007\'');
                
                if(lstSVMXPro != null && lstSVMXPro.size() > 0)
                    extSVMXPro = lstSVMXPro[0];
                else
                {
                    AddFieldValue(null, TU.getTAG151());
                    isSeedDataComplate = false;
                }
                system.debug(extSVMXPro.SVMXC__Submodule__r.SVMXC__SubmoduleID__c);
                SettingObjectList = commSettings.SVMX_getSettingObjectList(extSVMXPro.SVMXC__Submodule__r.SVMXC__SubmoduleID__c);
                //svmxPLTagList = commUtilPL.SVMX_getTagRecordList(extSVMXPro.SVMXC__Submodule__r.SVMXC__SubmoduleID__c); //commented by Amar Jun18-10
                /*
                for(SVMXC__ServiceMax_Tags__c oSVMXTag :svmxPLTagList.values())
                {
                    oSVMXTag.SVMXC__Tag_Text__c = '';
                } */
                objSVMXPro = new SVMXC.COMM_Inventory_Classes.InventoryProcess(SVMXPro, SettingObjectList, true);
                objSVMXPro.Is_Source_Location_From_Header = true;
                objSVMXPro.Is_Target_Location_From_Header = true; 
                
            }
            filllstActionOnQty();
            getStatusPickList();
            for(integer iTemp = 1; iTemp <= RelatedCloserExpressions.lstExpressions.size(); iTemp++ )
            {
                UpdateExpressionFields(RelatedCloserExpressions, iTemp, Schema.Displaytype.DOUBLE);
            }
            //HdrExpressions.ErrorMessage = getPLTAG001();
            //LineExpressions.ErrorMessage = getPLTAG002();
            //getPLTAG003();
            if(objSVMXPro.Maintain_Serial_History || objSVMXPro.Maintain_Stock_History)
                MaintainHistory = true;
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR , ex.getMessage()));
        }//*/
    }
    
    
    public void QueryRecTypes(){
        List<RecordType> allRecType = new List<RecordType>();//this is added for defect: 6999
        allRecType = database.query('Select SobjectType,Name,Id From RecordType where SobjectType IN:RECTYPEOBJS');
        RTypeMap = new map<String,map<string, SelectOption>>();
        for(RecordType rt: allRecType)
        {
            if(RTypeMap.containsKey(rt.SobjectType))
                RTypeMap.get(rt.SobjectType).put(rt.Name, new selectOption(rt.id, rt.Name));
            else
            {
                map<string, SelectOption> mapTempRType = new map<string, SelectOption>();
                mapTempRType.put(rt.Name, new selectOption(rt.id, rt.Name));
                RTypeMap.put(rt.SobjectType,mapTempRType);
            }
        }
        
    }
    
    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }
    public boolean isValidStringNotNONE(String str)
    {
        if (str != 'SVMX.NONE' && str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }
    
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2)  //,list<sobject> ObjList
    {
        RetriveField(ObjName, lst, m, m2, null);
    }
    
    //method add for view state error, this method is added for defect: 6999
    public Schema.SObjectType getCustmSObjectType(String objectName)
    {
        SVMXC.SFM_Utils utils1 = new SVMXC.SFM_Utils();
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        objectName = utils1.getOriginalAPIName(objectName, allObjs);
        return allObjs.get(objectName);
    }
    
    public void RetriveField2(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT)  //,list<sobject> ObjList
    {
        try
        {
            if(!mMapFieldList.containsKey(ObjName))
            {
                Schema.SObjectType objT = getCustmSObjectType(objName) ;//this is added for defect: 6999
                //Schema.SObjectType objT = allObjs.get(objName) ;
                if(objT != null)
                {
                    objfieldMap = objT.getDescribe().fields.getMap();
                    mMapFieldList.put(ObjName, objfieldMap);
                }   
            }
            else
                objfieldMap = mMapFieldList.get(objName);
            for (String fieldKey : objfieldMap.keySet()) 
            {
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(DT != null && DT == f.getType() && f.isAccessible())
                {
                    if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                    {
                        Schema.SObjectType sobjRefTo = f.getReferenceTo()[0];
                        Schema.DescribeSObjectResult dsobjresRefTo = sobjRefTo.getDescribe();
                        lst.add(new SelectOption(dsobjresRefTo.getName() + '~' + f.getName(),dsobjresRefTo.getLabel() + '.' + f.getLabel()));
                        if(m != null)
                            m.put(f.getName(), f.getType());
                        if(m2 != null)
                            m2.put(f.getName(),f.getLabel());
                    }
                    if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])) == false)
                    {
                        if((PermitedStndObjMap.containsKey(String.valueof(f.getReferenceTo()[0])) || IsEnterpriseLicense))
                        {
                            Schema.SObjectType sobjRefTo = f.getReferenceTo()[0];
                            Schema.DescribeSObjectResult dsobjresRefTo = sobjRefTo.getDescribe();
                            lst.add(new SelectOption(dsobjresRefTo.getName() + '~' + f.getName(),dsobjresRefTo.getLabel() + '.' + f.getLabel()));
                            if(m != null)
                                m.put(f.getName(), f.getType());
                            if(m2 != null)
                                m2.put(f.getName(),f.getLabel());
                        }   
                    }       
                }
            }
            TU.sortingSelectOption(lst, true);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }   
    public void RetriveUpdateableField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2)  //,list<sobject> ObjList
    {
        try
        {
            if(!mMapFieldList.containsKey(ObjName))
            {
                Schema.SObjectType objT = getCustmSObjectType(objName) ;//this is added for defect: 6999
                //Schema.SObjectType objT = allObjs.get(objName) ;
                if(objT != null)
                {
                    objfieldMap = objT.getDescribe().fields.getMap();
                    mMapFieldList.put(ObjName, objfieldMap);
                }   
            }
            else
                objfieldMap = mMapFieldList.get(objName);
            for (String fieldKey : objfieldMap.keySet()) 
            {
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                /*if(f.isUpdateable())
                    lst.add(new SelectOption(f.getName(),f.getLabel()));
                
                if(m != null)
                    m.put(f.getName(), f.getType());
                if(m2 != null)
                    m2.put(f.getName(),f.getLabel());*/   
                if(f.getType() == schema.Displaytype.REFERENCE)  
                {
                    if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                    {
                        if(f.isUpdateable())
                            lst.add(new SelectOption(f.getName(),f.getLabel()));
                        if(m != null)
                            m.put(f.getName(), f.getType());
                        if(m2 != null)
                            m2.put(f.getName(),f.getLabel());   
                    }
                    if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])) == false)
                    {
                        if((PermitedStndObjMap.containsKey(String.valueof(f.getReferenceTo()[0])) || IsEnterpriseLicense))
                        {
                            if(f.isUpdateable())
                                lst.add(new SelectOption(f.getName(),f.getLabel()));
                            if(m != null)
                                m.put(f.getName(), f.getType());
                            if(m2 != null)
                                m2.put(f.getName(),f.getLabel()); 
                        }
                    }       
                }   
                if(f.getType() != schema.Displaytype.REFERENCE)
                {
                    if(f.isUpdateable())
                        lst.add(new SelectOption(f.getName(),f.getLabel()));
                    if(m != null)
                        m.put(f.getName(), f.getType());
                    if(m2 != null)
                        m2.put(f.getName(),f.getLabel()); 
                }   
            }        
            TU.sortingSelectOption(lst, true);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    } 
    public void RetriveUpdateableField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT)  //,list<sobject> ObjList
    {
        try
        {
            if(!mMapFieldList.containsKey(ObjName))
            {
                Schema.SObjectType objT = getCustmSObjectType(objName) ;//this is added for defect: 6999
                //Schema.SObjectType objT = allObjs.get(objName) ;
                if(objT != null)
                {
                    objfieldMap = objT.getDescribe().fields.getMap();
                    mMapFieldList.put(ObjName, objfieldMap);
                }   
            }
            else
                objfieldMap = mMapFieldList.get(objName);
            for (String fieldKey : objfieldMap.keySet()) 
            {
                /*Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(DT != null && DT == f.getType() && f.isUpdateable())
                    lst.add(new SelectOption(f.getName(),f.getLabel()));
                if(DT == null && f.isUpdateable())
                    lst.add(new SelectOption(f.getName(),f.getLabel()));
                
                if(m != null)
                    m.put(f.getName(), f.getType());
                if(m2 != null)
                    m2.put(f.getName(),f.getLabel());*/   
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(f.getType() == schema.Displaytype.REFERENCE)  
                {
                    if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                    {
                        if(DT != null && DT == f.getType()&& f.isUpdateable())
                            lst.add(new SelectOption(f.getName(),f.getLabel()));
                        if(DT == null && f.isUpdateable())
                            lst.add(new SelectOption(f.getName(),f.getLabel()));
                        if(m != null)
                            m.put(f.getName(), f.getType());
                        if(m2 != null)
                            m2.put(f.getName(),f.getLabel());   
                    }
                    if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])) == false)
                    {
                        if((PermitedStndObjMap.containsKey(String.valueof(f.getReferenceTo()[0])) || IsEnterpriseLicense))
                        {
                            if(DT != null && DT == f.getType() && f.isUpdateable())
                                lst.add(new SelectOption(f.getName(),f.getLabel()));
                            if(DT == null && f.isUpdateable())
                                lst.add(new SelectOption(f.getName(),f.getLabel()));
                            if(m != null)
                                m.put(f.getName(), f.getType());
                            if(m2 != null)
                                m2.put(f.getName(),f.getLabel()); 
                        }
                    }       
                }   
                if(f.getType() != schema.Displaytype.REFERENCE)
                {
                    if(DT != null && DT == f.getType() && f.isUpdateable())
                        lst.add(new SelectOption(f.getName(),f.getLabel()));
                    if(DT == null && f.isUpdateable())
                        lst.add(new SelectOption(f.getName(),f.getLabel()));
                    if(m != null)
                        m.put(f.getName(), f.getType());
                    if(m2 != null)
                        m2.put(f.getName(),f.getLabel()); 
                }   
            }    
            TU.sortingSelectOption(lst, true);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    } 
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT)  //,list<sobject> ObjList
    {
        try
        {
            if(!mMapFieldList.containsKey(ObjName))
            {
                Schema.SObjectType objT = getCustmSObjectType(objName) ;//this is added for defect: 6999
                //Schema.SObjectType objT = allObjs.get(objName) ;
                if(objT != null)
                {
                    objfieldMap = objT.getDescribe().fields.getMap();
                    mMapFieldList.put(ObjName, objfieldMap);
                }   
            }
            else
                objfieldMap = mMapFieldList.get(objName);
            for (String fieldKey : objfieldMap.keySet()) 
            {
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(f.getType() == schema.Displaytype.REFERENCE)  
                {
                    if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                    {
                        if(!isCaseObjAvailable){
                            if(f.getName() != 'SVMXC__Case_Line__c'){
                                if(DT != null && DT == f.getType())
                                    lst.add(new SelectOption(f.getName(),f.getLabel()));
                                if(DT == null)
                                    lst.add(new SelectOption(f.getName(),f.getLabel()));
                                if(m != null)
                                    m.put(f.getName(), f.getType());
                                if(m2 != null)
                                    m2.put(f.getName(),f.getLabel());
                            }
                        }
                        else{
                            if(DT != null && DT == f.getType())
                                lst.add(new SelectOption(f.getName(),f.getLabel()));
                            if(DT == null)
                                lst.add(new SelectOption(f.getName(),f.getLabel()));
                            if(m != null)
                                m.put(f.getName(), f.getType());
                            if(m2 != null)
                                m2.put(f.getName(),f.getLabel());   
                        }
                    }
                    if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])) == false)
                    {
                        if((PermitedStndObjMap.containsKey(String.valueof(f.getReferenceTo()[0])) || IsEnterpriseLicense))
                        {
                            if(DT != null && DT == f.getType())
                                lst.add(new SelectOption(f.getName(),f.getLabel()));
                            if(DT == null)
                                lst.add(new SelectOption(f.getName(),f.getLabel()));
                            if(m != null)
                                m.put(f.getName(), f.getType());
                            if(m2 != null)
                                m2.put(f.getName(),f.getLabel()); 
                        }
                    }       
                }   
                if(f.getType() != schema.Displaytype.REFERENCE)
                {
                    if(DT != null && DT == f.getType())
                        lst.add(new SelectOption(f.getName(),f.getLabel()));
                    if(DT == null)
                        lst.add(new SelectOption(f.getName(),f.getLabel()));
                    if(m != null)
                        m.put(f.getName(), f.getType());
                    if(m2 != null)
                        m2.put(f.getName(),f.getLabel()); 
                }   
            }
            TU.sortingSelectOption(lst, true);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }     
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT, string LCObjName)  //,list<sobject> ObjList
    {
        try
        {
            if(!mMapFieldList.containsKey(ObjName))
            {
                Schema.SObjectType objT = getCustmSObjectType(objName) ;//this is added for defect: 6999
                //Schema.SObjectType objT = allObjs.get(objName) ;
                if(objT != null)
                {
                    objfieldMap = objT.getDescribe().fields.getMap();
                    mMapFieldList.put(ObjName, objfieldMap);
                }   
            }
            else
                objfieldMap = mMapFieldList.get(objName);
            for (String fieldKey : objfieldMap.keySet()) 
            {
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                 
                if(schema.Displaytype.REFERENCE == f.getType() && string.valueOf(f.getReferenceTo()[0]) == LCObjName && f.isAccessible())
                {
                    if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                    {
                        lst.add(new SelectOption(f.getName(), f.getLabel()));
                    }
                    if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])) == false)
                    {
                        if((PermitedStndObjMap.containsKey(String.valueof(f.getReferenceTo()[0])) || IsEnterpriseLicense))
                        {
                            lst.add(new SelectOption(f.getName(), f.getLabel()));
                        }
                    }       
                }
                if(m != null)
                    m.put(f.getName(), f.getType());
                if(m2 != null)
                    m2.put(f.getName(),f.getLabel());   
            }
            TU.sortingSelectOption(lst, true);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    } 
    public void ClearSelOptMap ( map<string,SelectOption> m)
    {
        m.clear();
        m.put('', new SelectOption('SVMX.NONE',TU.getTAG062()));
    }          
    public void ClearSelOptList(List<SelectOption> lst)
    {
        lst.clear();
        lst.add(new SelectOption('SVMX.NONE',TU.getTAG062()));
    }
    public PageReference LocSource()
    {
        return null;
    }
    public void getChildObjects()
    {
        try
        {
            List<schema.Childrelationship> ChildObj = new List<schema.Childrelationship>();
            Set<String> ChildRECTYPEOBJS = new Set<String>();// newly added to deal with view state issue 
            ClearSelOptList(lstLineObjOpt);
            if(IsValidStringNotNone(objSVMXPro.Parent_Object_Name))
                ChildObj  = (getCustmSObjectType(objSVMXPro.Parent_Object_Name)).getDescribe().getChildRelationships();//this is added for defect: 6999
                //ChildObj  = (allObjs.get(objSVMXPro.Parent_Object_Name)).getDescribe().getChildRelationships();
            system.debug('ChildObj'+ChildObj);  
            for(Schema.ChildRelationship CR :ChildObj)
            {
                Schema.DescribeSObjectResult D = CR.getChildSObject().getDescribe(); 
                if(utils.SVMX_isObjectCustom(D.getName()) || (PermitedStndObjMap.containsKey(D.getName()) || IsEnterpriseLicense))//Added by amar due to OEM Exercises(1/sep/10)
                {
                    //lineObjApiLable.put(D.getName(),D.getLabel());//this is added for defect: 6999
                    //LineObjApiLocalName.put(D.getName(),D.getLocalName()); //this is added for defect: 6999
                    lstLineObjOpt.add(new SelectOption(D.getName(),D.getLabel()));//Builing select Options for line object
                    mapLineObjOpt.put(D.getName(), new SelectOption(D.getName(),D.getLabel()));
                    ChildRECTYPEOBJS.add(D.getName());
                }    
            }
            lstLineObjOpt = TU.sortingSelectOption(lstLineObjOpt, true);
            if(ChildObj != null && ChildObj.size() > 0 )
            {
              RECTYPEOBJS.addAll(ChildRECTYPEOBJS);
              QueryRecTypes();
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void filllstActionOnQty()
    {
        if(isInventoryEnabled)
        {
            lstActionOnQty.add(new SelectOption('SVMX.NONE',TU.getTAG062()));
            lstActionOnQty.add(new SelectOption('Increase',TU.getTAG117()));
            lstActionOnQty.add(new SelectOption('Decrease',TU.getTAG118()));
            lstActionOnQty.add(new SelectOption('Set',TU.getTAG119()));
        }
    }

    public void getStatusPickList()
    {
        try
        {
            /*
            //this is added for defect: 6999
            //Schema.Describesobjectresult SObjRes ;
            
            
            Map<String,Schema.SObjectField> objfieldMap;
            if(!mapFieldApiName.ContainsKey('SVMXC__Product_Stock__c'))
            {
                mapFieldApiName.put('SVMXC__Product_Stock__c', new Map<String,Schema.SObjectField>());
                Map<String,Schema.SObjectField> objfieldMap2 = schema.Sobjecttype.SVMXC__Product_Stock__c.fields.getMap();
                for(string str :objfieldMap2.KeySet())
                {
                    Schema.SObjectField f = objfieldMap2.get(str); 
                    Schema.DescribeFieldResult fr = f.getDescribe();
                    mapFieldApiName.get('SVMXC__Product_Stock__c').put(fr.getName(), f);
                }
            } */
            //newly added for defect: 6999
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            Map<String,Schema.SObjectField> objfieldMap2 = schema.Sobjecttype.SVMXC__Product_Stock__c.fields.getMap();
            for(string str :objfieldMap2.KeySet())
            {
                Schema.SObjectField f = objfieldMap2.get(str); 
                Schema.DescribeFieldResult fr = f.getDescribe();
                if(fr.getName() == 'SVMXC__Status__c')
                    objfieldMap.put('SVMXC__Status__c', f);
            }
            //end
            
            //objfieldMap = mapFieldApiName.get('SVMXC__Product_Stock__c');//this is added for defect: 6999
            if(objfieldMap.containsKey('SVMXC__Status__c'))
            {
                List <Schema.PicklistEntry> lstPicklistValues = objfieldMap.get('SVMXC__Status__c').getDescribe().getPicklistValues();
                boolean isDefaultValueAvailable = false;
                for(Schema.PicklistEntry p: lstPicklistValues )
                {
                    if(p.isActive())
                    {
                        if(p.isDefaultValue())
                        {
                            lstStatus.add(0, new SelectOption(p.getValue(), p.getLabel()));
                            isDefaultValueAvailable = true;
                        }
                        else    
                            lstStatus.add(new SelectOption(p.getValue(), p.getLabel()));
                        if(!isDefaultValueAvailable)
                        {
                            if(lstStatus != null && lstStatus.size() > 0 && lstStatus[0].getValue() != '' && lstStatus[0].getValue() != 'SVMX.NONE')
                                lstStatus.add(0, new SelectOption('SVMX.NONE', TU.getTAG062()));
                            else if(lstStatus != null && lstStatus.size() == 0)
                                lstStatus.add(new SelectOption('SVMX.NONE', TU.getTAG062()));
                        }
                    }
                }
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
   //----------------------------------Action Method to get the LineObjects OnChange of HeaderObjects----------------------------------
    public pageReference EnableBarcode()
    {
      return null;  
    }
    public pageReference OnEnable_Inventory_Action()
    {
        return null;
    }
    public pageReference OnSelectStockHistory()
    {
        try
        {
            if(!MaintainHistory)
            {
                Levalofhistorytrack = '';
                objSVMXPro.Stock_History_Header_API_Name = '';
                objSVMXPro.Stock_History_Line_API_Name = '';
                objSVMXPro.Maintain_Serial_History =false;
                objSVMXPro.Maintain_Stock_History = false;
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
    }
    public pagereference QtyUpdate()
    {
        return null;
    }
    public pageReference OnSelectChild()
    {
        try
        {
            if(objSVMXPro.Is_Multiline_Transaction && IsValidStringNotNone(objSVMXPro.Parent_Object_Name))
                getChildObjects();
            else
                ClearSelOptList(lstLineObjOpt);
            if(!objSVMXPro.Is_Multiline_Transaction)
            {
                objSVMXPro.Is_Source_Location_From_Header = true;
                objSVMXPro.Is_Target_Location_From_Header = true;
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
    }
    public PageReference OnHdrObjSelect() 
    {
        try
        {
            System.debug(logginglevel.warn,'In OnHdrObjSelect try');
        
            ClearSelOptList(Hdrfldlist);
            RetriveField(objSVMXPro.Parent_Object_Name, Hdrfldlist, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
            ClearSelOptList(HdrCloserExpressions.FieldsList);
            RetriveUpdateableField(objSVMXPro.Parent_Object_Name,  HdrCloserExpressions.FieldsList, HdrCloserExpressions.mapFieldDispType, HdrCloserExpressions.FieldApiLable);
            HdrExpressions.FieldsList = Hdrfldlist; 
            HdrExpressions.objfieldMap = mMapFieldList.get(objSVMXPro.Parent_Object_Name);
            HdrCloserExpressions.objfieldMap = mMapFieldList.get(objSVMXPro.Parent_Object_Name);
            if(IsValidStringNotNone(objSVMXPro.Parent_Object_Name))
            {
                SelHdrObj = mapHdrObjOpt.get(objSVMXPro.Parent_Object_Name).getlabel();
                RECTYPEOBJS.clear();
                RECTYPEOBJS.add(objSVMXPro.Parent_Object_Name);
                RECTYPEOBJS.add('SVMXC__ServiceMax_Processes__c');
                RECTYPEOBJS.add('SVMXC__ServiceMax_Config_Data__c');
                QueryRecTypes();
            }
            if(objSVMXPro.Is_Multiline_Transaction)
                getChildObjects();
                System.debug(logginglevel.warn,'HdrCloserExpressions.FieldsList' +HdrCloserExpressions.FieldsList);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
            System.debug(logginglevel.warn,'In OnHdrObjSelect catch');
        }
        return null;
    }
  
  // ---------------------------------Action Method to get the field names from Header & Line Object-----------------------------------------  

    public PageReference getfieldnames() 
    {
        try
        {
            if(isValidStringNotNone(objSVMXPro.Child_Object_Name))
            {   
            ClearSelOptList(Linefldlist);
            RetriveField(objSVMXPro.Child_Object_Name, Linefldlist, LineExpressions.mapFieldDispType, LineExpressions.FieldApiLable);
            ClearSelOptList(LineCloserExpressions.FieldsList);
            RetriveUpdateableField(objSVMXPro.Child_Object_Name, LineCloserExpressions.FieldsList, LineCloserExpressions.mapFieldDispType, LineCloserExpressions.FieldApiLable);
            LineExpressions.FieldsList = Linefldlist;
            LineCloserExpressions.objfieldMap = mMapFieldList.get(objSVMXPro.Child_Object_Name);
            RetriveField(objSVMXPro.Parent_Object_Name, LineExpressions.FieldsList, null, null, schema.Displaytype.REFERENCE , 'Product2');
            if(IsValidStringNotNone(objSVMXPro.Child_Object_Name) && mapLineObjOpt.ContainsKey(objSVMXPro.Child_Object_Name))
                SelLineObj = mapLineObjOpt.get(objSVMXPro.Child_Object_Name).getlabel();
            }
            else 
            {
                ClearSelOptList(HdrReffldlist);
                ClearSelOptList(Linefldlist);
                ClearSelOptList(LineExpressions.FieldsList);
                ClearSelOptList(LineCloserExpressions.FieldsList);
                ClearSelOptList(lstChildRecordType);
                
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
    }
    public void HdrADDRow(){ try{HdrExpressions.addCriteriaExpression(1);}catch(exception ex){AddException(ex.getMessage());}}
    public void HdrDeleteRow(){ try{HdrExpressions.removeCriteriaExpression(integer.valueOf(SelectedIndex));}catch(exception ex){AddException(ex.getMessage());}}
    public void LineADDRow(){ try{LineExpressions.addCriteriaExpression(1);}catch(exception ex){AddException(ex.getMessage());}}
    public void LineDeleteRow(){ try{LineExpressions.removeCriteriaExpression(integer.valueOf(SelectedIndex));}catch(exception ex){AddException(ex.getMessage());}}
    public void HdrCloserADDRow(){ try{HdrCloserExpressions.addCriteriaExpression(1);}catch(exception ex){AddException(ex.getMessage());}}
    public void HdrCloserDeleteRow(){ try{HdrCloserExpressions.removeCriteriaExpression(integer.valueOf(SelectedIndex));}catch(exception ex){AddException(ex.getMessage());}}
    public void LineCloserADDRow(){ try{LineCloserExpressions.addCriteriaExpression(1);}catch(exception ex){AddException(ex.getMessage());}}
    public void LineCloserDeleteRow(){ try{LineCloserExpressions.removeCriteriaExpression(integer.valueOf(SelectedIndex));}catch(exception ex){AddException(ex.getMessage());}}
    public void RelatedCloserADDRow(){ try{RelatedCloserExpressions.addCriteriaExpression(1);}catch(exception ex){AddException(ex.getMessage());}}
    public void RelatedCloserDeleteRow(){ try{RelatedCloserExpressions.removeCriteriaExpression(integer.valueOf(SelectedIndex));}catch(exception ex){AddException(ex.getMessage());}}
    
   
    COMM_SVMXC_SearchRecords SR = new COMM_SVMXC_SearchRecords();
        public COMM_SVMXC_SearchRecords getSR (){return this.SR;}
    public void HdrFind()
    {
        try
        {
            find(HdrExpressions);
            isSearch = true;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void HdrFindDate()
    {
        try
        {
            find(HdrExpressions);
            isDateSearch = true;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    public void Do_Search(){ try{SR.Do_Search();}catch(exception ex){AddException(ex.getMessage());}}
    public void Do_Select()
    {
        try
        {
            string s = SR.getDate();
            if(s != null )
            {
                ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand = s; 
                isDateSearch = false;
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    } 
    COMM_SVMXC_Search_Expressions ExpressionsTemp;
    public void Do_CancelSearch(){ isDateSearch = false; isSearch = false;} 
    public string SelectedID;
        public string getSelectedID() {return this.SelectedID;}
        public void setSelectedID(string str) {this.SelectedID = str;}
    public string SelectedLabel;
        public string getSelectedLabel() {return this.SelectedLabel;}
        public void setSelectedLabel(string str) {this.SelectedLabel = str;}        
        
    public Boolean isSearch = false;
        public boolean getisSearch(){return this.isSearch;}
     public Boolean isDateSearch = false;
        public boolean getisDateSearch(){return this.isDateSearch;}
    public void OnselectRecord()
    {
        try
        {
            string selectedID = SR.getselectedId();
            if(selectedID != null && selectedID.length() > 0)
            {
                ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand = SR.getselectedLabel();
                //ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].OperandID = SR.getSelectedID();
                isSearch = false;
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void OnselectCurrentUser()
    {
        try
        {
            ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand = 'Current User';
            //ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].OperandID = 'SVMX.CurrentUser';
            isSearch = false;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void OnselectRecordOwner()
    {
        try
        {
            ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand = 'Record Owner';
            //ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].OperandID = 'SVMX.Owner';
            isSearch = false;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void OnHdrEntryCriFieldSelect()
    {
        try
        {
            HdrExpressions.objfieldMap = mMapFieldList.get(objSVMXPro.Parent_Object_Name); 
            HdrExpressions.OnChangeField(integer.valueOf(SelectedIndex), true);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void OnLineEntryCriFieldSelect()
    { 
        try
        {
            LineExpressions.objfieldMap = mMapFieldList.get(objSVMXPro.Child_Object_Name); 
            LineExpressions.OnChangeField(integer.valueOf(SelectedIndex), true);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    public void OnHdrCloserEntryCriFieldSelect()
    { 
        try
        {
            HdrCloserExpressions.objfieldMap = mMapFieldList.get(objSVMXPro.Parent_Object_Name); 
            HdrCloserExpressions.OnChangeField(integer.valueOf(SelectedIndex), true);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void OnLineCloserEntryCriFieldSelect()
    { 
        try
        {
            LineCloserExpressions.objfieldMap = mMapFieldList.get(objSVMXPro.Child_Object_Name); 
            LineCloserExpressions.OnChangeField(integer.valueOf(SelectedIndex), true);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void Linefind()
    {
        try
        {
            find(LineExpressions);
            isSearch = true;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void LinefindDate()
    {
        try
        {
            find(LineExpressions);
            isDateSearch = true;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void HdrCloserfind()
    {
        try
        {
            find(HdrCloserExpressions);
            isSearch = true;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void HdrCloserfindDate()
    {
        try
        {
            find(HdrCloserExpressions);
            isDateSearch = true;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void LineCloserfind()
    {
        try
        {
            find(LineCloserExpressions);
            isSearch = true;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void LineCloserfindDate()
    {
        try
        {
            find(LineCloserExpressions);
            isDateSearch = true;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void find(COMM_SVMXC_Search_Expressions Expressions)
    {
        try
        {
            ExpressionsTemp = Expressions;
            SR = new  COMM_SVMXC_SearchRecords(Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].ObjectName, Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand, Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].ObjectNameField, Expressions.ExpressionType );
            SR.allobjs.clear();//this is added for defect: 6999
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    public Boolean CheckAllLines=false;    
    public Boolean getCheckAllLines() {return CheckAllLines;}
    public void setCheckAllLines(Boolean b){CheckAllLines = b;}
 
    
   // public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('CONF010');
            
    //Tags & Settings

    
    //public SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
   // public SVMXC.COMM_Utils_ManageTags commUtilPL = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList  = commUtil.SVMX_getTagList('CONF010');
    public Map<String, SVMXC__ServiceMax_Tags__c> svmxPLTagList = new Map<String, SVMXC__ServiceMax_Tags__c>();
    
    public COMM_SVMXC_Utils3 TU = new COMM_SVMXC_Utils3('CONF010');
        public COMM_SVMXC_Utils3 getTU(){return this.TU;}
    public String getTAG072() {return TU.tagTextMap.containsKey('TAG072')?TU.tagTextMap.get('TAG072')+ ' '+ SelHdrObj  : '';} 
    public String getTAG073() {return TU.tagTextMap.containsKey('TAG072')?TU.tagTextMap.get('TAG072')+ ' '+ SelLineObj : '';}
    public List<SelectOption> getBooleanOptions() 
    {
        try
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('true',TU.getTAG120()));
            options.add(new SelectOption('false',TU.getTAG121()));
            return options;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
    }
    public List<SelectOption> getListofUniqunes()
    {
        try
        {
            if(isInventoryEnabled)
            {
                List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption('SVMX.NONE', TU.getTAG122()));
                options.add(new SelectOption('Soft', TU.getTAG123()));
                options.add(new SelectOption('Strict', TU.getTAG124()));
                return options;
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
     }
     
     public List<SelectOption> getLocationtoConsider()
     {
        try
        {
            if(isInventoryEnabled)
            {
                List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption('SVMX.NONE',TU.getTAG062()));
                options.add(new SelectOption('One', TU.getTAG125()));
                options.add(new SelectOption('Two', TU.getTAG126()));
                return options;
            }
            return null;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
    }
     public pageReference SVMX_OnNoofLocationSelect()
     {
        try
        {
            if(objSVMXPro.Number_of_locations == 'SVMX.NONE' || objSVMXPro.Number_of_locations == null || objSVMXPro.Number_of_locations == '' || objSVMXPro.Number_of_locations.length() == 0)
            {
                objSVMXPro.Source_Location_API_Name = '';
                objSVMXPro.Source_Status = '';
                objSVMXPro.Source_Action = '';
                
                objSVMXPro.Target_Location_API_Name = '';
                objSVMXPro.Target_Status = '';
                objSVMXPro.Target_Action = '';
                
                objSVMXPro.Is_Target_Location_Stockable = false;
                objSVMXPro.Is_Source_Location_Stockable = false;
                
                objSVMXPro.Maintain_Stock_History = false;
                objSVMXPro.Maintain_Serial_History = false;
                MaintainHistory = false;
                objSVMXPro.Stock_History_Header_API_Name = '';
                objSVMXPro.Stock_History_Line_API_Name = '';
            }
            else if(objSVMXPro.Number_of_locations == 'One')
            {
                objSVMXPro.Target_Location_API_Name = '';
                objSVMXPro.Target_Status = '';
                objSVMXPro.Target_Action = '';
                objSVMXPro.Is_Target_Location_Stockable = false;
            }
            else if(objSVMXPro.Number_of_locations == 'Two')
            {
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
     }
     boolean MaintainHistory = false;
     public boolean getMaintainHistory(){return this.MaintainHistory;}
     public void setMaintainHistory(boolean b){this.MaintainHistory = b;}
     
     public List<SelectOption> getlstLevalofhistorytrack()
     {
        try
        {
            if(isInventoryEnabled)
            {
                List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption('SVMX.NONE', TU.getTAG062()));
                options.add(new SelectOption('Stock History Only', TU.getTAG127()));
                options.add(new SelectOption('Serial History Only', TU.getTAG128()));
                options.add(new SelectOption('Stock & Serial History',TU.getTAG129()));
                return options;
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
     }
     
     public String Levalofhistorytrack;
     public String getLevalofhistorytrack()
     {
        try
        {
            if(!objSVMXPro.Maintain_Serial_History && objSVMXPro.Maintain_Stock_History)
                Levalofhistorytrack = 'Stock History Only';
            if(objSVMXPro.Maintain_Serial_History && !objSVMXPro.Maintain_Stock_History)
                Levalofhistorytrack = 'Serial History Only';
            if(objSVMXPro.Maintain_Serial_History && objSVMXPro.Maintain_Stock_History)
                Levalofhistorytrack = 'Stock & Serial History';
            if(!objSVMXPro.Maintain_Serial_History && !objSVMXPro.Maintain_Stock_History)
                Levalofhistorytrack = 'SVMX.NONE';
            return Levalofhistorytrack;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
    }
    public void setLevalofhistorytrack(string str)
    {
        try
        {
            if(MaintainHistory && str != null && str == 'Stock History Only')
            {
                objSVMXPro.Maintain_Serial_History = false;
                objSVMXPro.Maintain_Stock_History = true;
            }
            else if(MaintainHistory && str != null && str == 'Serial History Only')
            {
                objSVMXPro.Maintain_Stock_History = false;
                objSVMXPro.Maintain_Serial_History = true;
            }
            else if(MaintainHistory && str != null && str == 'Stock & Serial History')
            {
                objSVMXPro.Maintain_Stock_History = true;
                objSVMXPro.Maintain_Serial_History = true;
            }
            else
            {
                objSVMXPro.Maintain_Stock_History = false;
                objSVMXPro.Maintain_Serial_History = false;
            }
            this.Levalofhistorytrack = str;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
     }
   

    public void updateTags(string tagName, string tagText)
    {
        Map<string, SVMXC__ServiceMax_Tags__c> mapPLTags = new map<string, SVMXC__ServiceMax_Tags__c>();//added this line for defect :6999
        try
        {
            if(mapPLTags.containsKey(tagName))
            {
                if(isCloneMode || isNewMode)
                    mapPLTags.put(tagName, mapPLTags.get(tagName).Clone(false,true)); 
                mapPLTags.get(tagName).SVMXC__Tag_Text__c = tagText;
                mapPLTags.get(tagName).SVMXC__Submodule__c = SVMXPro.SVMXC__Submodule__c;
                mapPLTags.get(tagName).SVMXC__Installation_Key__c = getInstallKey();
            }
            else
            {
                SVMXC__ServiceMax_Tags__c SMTag = new SVMXC__ServiceMax_Tags__c();
                SMTag.Name = tagName;
                SMTag.SVMXC__Language__c = 'Master';
                SMTag.SVMXC__Submodule__c = SVMXPro.SVMXC__Submodule__c;
                SMTag.SVMXC__Installation_Key__c = getInstallKey();
                svmxPLTagList.put(tagName, SMTag);
                SMTag.SVMXC__Tag_Text__c = tagText;
                mapPLTags.put(tagName, SMTag);
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    /*
    public String getPLTAG001(){try{if(svmxPLTagList != null && svmxPLTagList.containsKey('TAG001')) mapPLTags.put('TAG001', svmxPLTagList.get('TAG001')); return svmxPLTagList.containsKey('TAG001')?svmxPLTagList.get('TAG001').SVMXC__Tag_Text__c : '';}catch(exception ex){AddException(ex.getMessage());return null;}}
    public void setPLTAG001(string str){try{updateTags('TAG001',str);}catch(exception ex){AddException(ex.getMessage());}}
    public String getPLTAG002(){try{if(svmxPLTagList != null && svmxPLTagList.containsKey('TAG002')) mapPLTags.put('TAG002', svmxPLTagList.get('TAG002')); return svmxPLTagList.containsKey('TAG002')?svmxPLTagList.get('TAG002').SVMXC__Tag_Text__c : '';}catch(exception ex){AddException(ex.getMessage());return null;}}
    public void setPLTAG002(string str){try{updateTags('TAG002',str);}catch(exception ex){AddException(ex.getMessage());}}
    public String getPLTAG003(){try{if(svmxPLTagList != null && svmxPLTagList.containsKey('TAG003')) mapPLTags.put('TAG003', svmxPLTagList.get('TAG003')); return svmxPLTagList.containsKey('TAG003')?svmxPLTagList.get('TAG003').SVMXC__Tag_Text__c : '';}catch(exception ex){AddException(ex.getMessage());return null;}}
    public void setPLTAG003(string str){try{updateTags('TAG003',str);}catch(exception ex){AddException(ex.getMessage());}}
    */
      //------------------------------Sorting fuctoin --------------------------------------------
    
    public map <string, Map<String,Schema.SObjectField>> mMapFieldList = new map<string, Map<String,Schema.SObjectField>> ();
    Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        
    public string getRelationShip(string ObjName, string FieldName)
    {
        try
        {
            if(!mMapFieldList.containsKey(ObjName))
            {
                Schema.SObjectType objT = getCustmSObjectType(objName) ;//added this for defect : 6999
                //Schema.SObjectType objT = allObjs.get(objName) ;
                if(objT != Null)
                {
                    objfieldMap = objT.getDescribe().fields.getMap();
                    mMapFieldList.put(ObjName, objfieldMap);
                }   
            }
            else
                objfieldMap = mMapFieldList.get(objName);
            Schema.SObjectField fsObj = objfieldMap.get(FieldName);
            if(fsObj == null)
            {
                for(Schema.SObjectField fsObjtemp :objfieldMap.Values())
                {
                    Schema.DescribeFieldResult f = fsObjtemp.getDescribe();
                    if(f.getName() == FieldName)
                        return f.getRelationshipName();
                }
            }
            else
            {
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                return f.getRelationshipName();
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null; 
    }
    public string getReferenceTo(string ObjName, string FieldName)
    {
        try
        {
            if(!mMapFieldList.containsKey(ObjName))
            {
                Schema.SObjectType objT = getCustmSObjectType(objName) ;//added this for defect: 6999
                //Schema.SObjectType objT = allObjs.get(objName) ;
                if(objT != null)
                {
                    objfieldMap = objT.getDescribe().fields.getMap();
                    mMapFieldList.put(ObjName, objfieldMap);
                }   
            }
            else
                    objfieldMap = mMapFieldList.get(objName);
            if(FieldName != null)
            {
                Schema.SObjectField fsObj = objfieldMap.get(FieldName);
                if( fsObj != null )
                {
                    Schema.DescribeFieldResult f = fsObj.getDescribe();
                    return f.getReferenceTo()[0].getDescribe().getName();
                }
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
    }
    private string getInstallKey()
    {
        try
        {
            return EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15) )); ////+ '~' + String.valueOf(date.Today())
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return '';
    }
    //private string strSubModule = '' ; this is commented for defect: 6999
    //Button Events
    static boolean isError = false;

    
    public boolean ProcessObjSave()
    {
        SVMXC.COMM_Inventory_Classes.InventoryProcessResult oInventoryProcessResult;// this is newly added for defect: 6999
        SVMXC.COMM_Utils_ManageModules CommUtilManageModules = new SVMXC.COMM_Utils_ManageModules();// this is newly added for defect: 6999
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                    
        try
        {
            isError = false;
            Displayvalue = true;
            Id Rtype;
            
            if(objSVMXPro.ProcessID != null){
                String processIdStr = String.escapeSingleQuotes(objSVMXPro.ProcessID);
                if(processIdStr.contains(' '))
                    AddFieldValue('', TU.getTAG158());
                if(processIdStr.length() > 30 || processIdStr.length() < 8)
                    AddFieldValue('', TU.getTAG159());
                if(AddFieldValue(processIdStr, TU.getTAG132()) && !isEditMode && (SVMXPro.Id == null || ((string)SVMXPro.Id).length() == 0))
                {
                    list<SVMXC__ServiceMax_Processes__c> lstTemp = database.query('select Id from SVMXC__ServiceMax_Processes__c where (recordType.Name = \'Inventory Process\' AND SVMXC__ProcessID__c = \''+ processIdStr +'\' ) OR (SVMXC__SubmoduleID__c = \''+ processIdStr +'\' AND recordType.Name = \'Submodule\' )');
                    if(lstTemp != null && lstTemp.size() > 0)
                    {
                        ApexPages.AddMessage(new ApexPages.Message (ApexPages.Severity.ERROR, TU.getTAG133()));
                        isError = true;
                    }
                }
            }

            IsValidOption(objSVMXPro.Module, TU.getTAG130());
            AddFieldValue(objSVMXPro.Name, TU.getTAG131());
            if(RTypeMap.ContainsKey('SVMXC__ServiceMax_Processes__c'))
            {
                if(RTypeMap.get('SVMXC__ServiceMax_Processes__c').ContainsKey('Inventory Process'))
                    Rtype = RTypeMap.get('SVMXC__ServiceMax_Processes__c').get('Inventory Process').getValue();
            }

            if(Rtype != null)
               SVMXPro.RecordTypeId = Rtype;
            else
                AddFieldValue(Rtype, TU.getTAG134()); 
            
            string headerClosure = HdrCloserExpressions.getCriteria(objSVMXPro.Parent_Object_Name);
            string lineClosure = LineCloserExpressions.getCriteria(objSVMXPro.Child_Object_Name);
            if(headerClosure == 'ERROR' || lineClosure == 'ERROR')
                isError = true;

            if(IsValidStringNotNone(objSVMXPro.Parent_Object_Name))
            {
                string headerCriteria = HdrExpressions.getCriteria(objSVMXPro.Parent_Object_Name);
                if(headerCriteria != 'ERROR')
                {
                    objSVMXPro.Parent_Object_Criteria = headerCriteria; 
                    objSVMXPro.Parent_Advanced_Option = HdrExpressions.AdvanceOption;
                }
                else
                    isError = true;
            }
            else
                IsValidOption(objSVMXPro.Parent_Object_Name, TU.getTAG082());

            if(objSVMXPro.Is_Multiline_Transaction)
            {
                if(IsValidStringNotNone(objSVMXPro.Child_Object_Name))
                {
                    string LineCriteria = LineExpressions.getCriteria(objSVMXPro.Child_Object_Name);
                    objSVMXPro.RelationShip_Name_to_Product = getRelationShip(objSVMXPro.Child_Object_Name, objSVMXPro.Product_Field_API_Name);
                    AddFieldValue(objSVMXPro.RelationShip_Name_to_Product, TU.getTAG084());
                    objSVMXPro.RelationShip_Name_to_Parent = getRelationShip(objSVMXPro.Child_Object_Name, objSVMXPro.Lookup_Field_to_Parent);
                    AddFieldValue(objSVMXPro.RelationShip_Name_to_Parent, TU.getTAG084());
            
                    if(LineCriteria != 'ERROR')
                    {
                        objSVMXPro.Child_Object_Criteria = LineCriteria;
                        objSVMXPro.Child_Advanced_Option = LineExpressions.AdvanceOption;
                    }
                    else
                        isError = true;
                }
                else
                    IsValidOption(objSVMXPro.Child_Object_Name, TU.getTAG083());

                IsValidOption(objSVMXPro.Lookup_Field_to_Parent, TU.getTAG135());
                if(lstChildRecordType != null && lstChildRecordType.size() > 0 )
                {
                    if(lstChildRecordType.size() == 1 & lstChildRecordType[0].getValue() != null && lstChildRecordType[0].getValue() != '' && lstChildRecordType[0].getValue() != 'SVMX.NONE' && lstChildRecordType[0].getValue().length() > 0)
                        IsValidOption(objSVMXPro.Child_Object_RecordType, TU.getTAG136());
                    else if(lstChildRecordType.size() > 1 )
                        IsValidOption(objSVMXPro.Child_Object_RecordType, TU.getTAG136());
                }
            }
            else
            {
                objSVMXPro.RelationShip_Name_to_Product = getRelationShip(objSVMXPro.Parent_Object_Name, objSVMXPro.Product_Field_API_Name);
                AddFieldValue(objSVMXPro.RelationShip_Name_to_Product, TU.getTAG084());
            }

            IsValidOption(objSVMXPro.Product_Field_API_Name, TU.getTAG137());
            IsValidOption(objSVMXPro.Related_Product_Field, TU.getTAG138());
            IsValidOption(objSVMXPro.Original_Qty_API_Name, TU.getTAG140());
            if (objSVMXPro.Is_User_Enter_Qty)
                IsValidOption(objSVMXPro.Actual_Qty_API_Name, TU.getTAG139());
            System.debug('');
            if(isInventoryEnabled && objSVMXPro.Number_of_locations != null && objSVMXPro.Number_of_locations != 'SVMX.NONE' && objSVMXPro.Number_of_locations.length() > 0)
            {
                Boolean CheckSource = false;
                if(objSVMXPro.Number_of_locations.ToUpperCase() == 'ONE' || objSVMXPro.Number_of_locations.ToUpperCase() == 'TWO')
                {
                    IsValidOption(objSVMXPro.Source_Location_API_Name, TU.getTAG141());
                    IsValidOption(objSVMXPro.Source_Status, TU.getTAG142());
                    IsValidOption(objSVMXPro.Source_Action, TU.getTAG143());
                    if(!objSVMXPro.Is_Source_Location_From_Header)
                        objSVMXPro.RelationShip_to_Source_Location = getRelationShip(objSVMXPro.Child_Object_Name, objSVMXPro.Source_Location_API_Name);
                    else
                        objSVMXPro.RelationShip_to_Source_Location = getRelationShip(objSVMXPro.Parent_Object_Name, objSVMXPro.Source_Location_API_Name);
                    AddFieldValue(objSVMXPro.RelationShip_to_Source_Location, TU.getTAG084());
                    IsValidOption(SelStockbleLocation, TU.getTAG144());
                    if(MaintainHistory)
                    {
                        IsValidOption(Levalofhistorytrack, TU.getTAG145());
                        IsValidOption(objSVMXPro.Stock_History_Header_API_Name, TU.getTAG146());
                        if(objSVMXPro.Is_Multiline_Transaction)
                            IsValidOption(objSVMXPro.Stock_History_Line_API_Name, TU.getTAG147());
                    }
                    
                    if(objSVMXPro.Number_of_locations.ToUpperCase() == 'TWO')
                        CheckSource = true;
                }
                if(CheckSource)
                {
                    IsValidOption(objSVMXPro.Target_Location_API_Name , TU.getTAG148());
                    IsValidOption(objSVMXPro.Target_Status, TU.getTAG149());
                    IsValidOption(objSVMXPro.Target_Action, TU.getTAG150());
                    if(!objSVMXPro.Is_Target_Location_From_Header)
                        objSVMXPro.RelationShip_to_Target_Location = getRelationShip(objSVMXPro.Child_Object_Name, objSVMXPro.Target_Location_API_Name);
                    else
                        objSVMXPro.RelationShip_to_Target_Location = getRelationShip(objSVMXPro.Parent_Object_Name, objSVMXPro.Target_Location_API_Name);
                    AddFieldValue(objSVMXPro.RelationShip_to_Target_Location, TU.getTAG084());
                } 
            }

            if(isValidString(objSVMXPro.Email_For_Negative_Stock_Alert))
            {
                if(!pattern.matches('^[a-zA-Z][\\w\\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\\w\\.-]*[a-zA-Z0-9]\\.[a-zA-Z][a-zA-Z\\.]*[a-zA-Z]$',objSVMXPro.Email_For_Negative_Stock_Alert))
                    AddFieldValue(null, TU.getTAG160());
            }
            if(!isError && (isNewMode || isCloneMode) && (objSVMXPro.Submodule == null || ((String)objSVMXPro.Submodule).length() == 0))
            {
                SVMXC__ServiceMax_Processes__c subModule = CommUtilManageModules.SVMX_cloneSubModule(extSVMXPro.SVMXC__Submodule__r.SVMXC__SubmoduleID__c, objSVMXPro.ProcessID, '', objSVMXPro.ModuleID, objSVMXPro.Module);
                if(subModule != null)
                    objSVMXPro.Submodule = subModule.Id;
            }
           if (!isError && objSVMXPro != null && isValidString(objSVMXPro.Submodule))
            {
                oInventoryProcessResult = objSVMXPro.SVMX_getInventoryProcess();
                if (oInventoryProcessResult.SVMXProcess != null)
                {
                    if(isEditMode && SVMXPro.SVMXC__IsStandard__c)
                        oInventoryProcessResult.SVMXProcess.SVMXC__Installation_Key__c = getInstallKey();
                    //upsert oInventoryProcessResult.SVMXProcess;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(oInventoryProcessResult.SVMXProcess, COMM_SecurityUtils.Access.Upsertable)){
                        upsert oInventoryProcessResult.SVMXProcess;
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return false;
                    }
                }
                if(isNewMode || isCloneMode){
                      Map<String, SVMXC__ServiceMax_Config_Data__c> SettingObjectList = commSettings.SVMX_getSettingObjectList(extSVMXPro.SVMXC__Submodule__r.SVMXC__SubmoduleID__c);
                      Map<String, SVMXC__ServiceMax_Config_Data__c> SettingObjectList2 = commSettings.SVMX_cloneSettingValues( extSVMXPro.SVMXC__Submodule__c, objSVMXPro.Submodule, extSVMXPro.SVMXC__Submodule__r.SVMXC__SubmoduleID__c, objSVMXPro.SubmoduleID, oInventoryProcessResult.mapSetting, getInstallKey());
                        
                }
                else if(isEditMode){
                    //upsert oInventoryProcessResult.mapSetting.values();
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(oInventoryProcessResult.mapSetting.values(), COMM_SecurityUtils.Access.Upsertable)){
                        upsert oInventoryProcessResult.mapSetting.values();
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return false;
                    }
                }
                return true;
            }
            else 
                return false;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }//*/
        return false;
    }
    public boolean AddFieldValue(String strFieldValue, String strErrorMessage)
    {
        if(!isValidString(strFieldValue))
        {
            if(isValidString(strErrorMessage))
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, strErrorMessage));
            else
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''));
            isError = true;
            return false;
        }
        return true;
    }
    public boolean IsValidOption(String strFieldValue, String strErrorMessage)
    {
        if(!isValidStringNotNONE(strFieldValue))
        {
            if(isValidString(strErrorMessage))
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, strErrorMessage));
            else
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''));
            isError = true;
            return false;
        }
        return true;
    }
    public void AddException(String strErrorMessage)
    {
        if(isValidString(strErrorMessage))
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, strErrorMessage));
        else
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''));
    }
    
    public boolean PLTagSave()
    {
       /* commented by Amar jun18-10
        try
        {
            setPLTAG001(HdrExpressions.ErrorMessage);
            setPLTAG002(LineExpressions.ErrorMessage);
            setPLTAG003(oInventoryProcessResult.SVMXProcess.SVMXC__Name__c);
            if(mapPLTags.values().size() > 0)
                 upsert mapPLTags.values();
            return true;
        }
        catch(exception ex)
        {
            ApexPages.addMessages(ex);
            return false;
        }
        */
        return true; //Always return true as Tags are not supported in PCP
    }
   
    public boolean ConfigDataSave()
    {
        try
        {
            string Rtype = '';
            if(RTypeMap.ContainsKey('SVMXC__ServiceMax_Config_Data__c'))
            {
                if(RTypeMap.get('SVMXC__ServiceMax_Config_Data__c').ContainsKey('Expressions'))
                    Rtype = RTypeMap.get('SVMXC__ServiceMax_Config_Data__c').get('Expressions').getValue();
            }
            map<string, string> mapProperties = new map<string, string>();
            mapProperties.put('RecordTypeID', Rtype);
            mapProperties.put('SVMXC__Expression_Type__c', 'INV_Header_Entry_Criteria');
            mapProperties.put('SVMXC__Inventory_Process__c', SVMXPro.Id);
            HdrExpressions.getExpressions(mapProperties);
            mapProperties.put('SVMXC__Expression_Type__c', 'INV_Header_Closure_Action');
            HdrCloserExpressions.getExpressions(mapProperties);
            mapProperties.put('SVMXC__Expression_Type__c', 'INV_Related_Update_Action');
            RelatedCloserExpressions.getExpressions(mapProperties);
            if(objSVMXPro.Is_Multiline_Transaction)
            {
                mapProperties.put('SVMXC__Expression_Type__c', 'INV_Line_Entry_Criteria');
                LineExpressions.getExpressions(mapProperties);
                mapProperties.put('SVMXC__Expression_Type__c', 'INV_Line_Closure_Action');
                LineCloserExpressions.getExpressions(mapProperties);
            }
            return true;
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getmessage()));
            return false;   
        }
    }
   
    public pageReference SVMX_doQuickSave()
    {
        Savepoint sp = Database.setSavepoint();
        try
        {
            boolean isProcessSaved = false;
            isProcessSaved = ProcessObjSave();
            System.debug('save sucess ProcessObjSave : '+isProcessSaved);
            boolean isTagsSaved = false;
            if(isProcessSaved)
            {
                isTagsSaved = PLTagSave();
                System.debug('save sucess PLTagSave : '+isTagsSaved);
            }
            boolean isCongfigDataSaved = false;
            if(isTagsSaved) 
            {
                isCongfigDataSaved = ConfigDataSave();
                System.debug('save sucess ConfigDataSave : '+isCongfigDataSaved);
            }   
            if(isCongfigDataSaved && SVMXPro.id != null)
            {
                //BAC-4012 : To support translation invetory process
                CONF_ManageTranslations conf_manageTranslations = new CONF_ManageTranslations();
                conf_manageTranslations.generateMasterTag(SVMXPro.id);
                
                Pagereference pageref = new pagereference('/apex/SVMXC__CONF_ManageInventoryProcesses?Pid='+SVMXPro.id+'&tab='+selectedTab);  
                pageref.setRedirect(true);
                return pageref;//*/
            }

           else
                database.rollBack(sp);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
            database.rollBack(sp);
        }
        return null;
    }

    public pageReference SVMX_doSave()
    {
        Savepoint sp = Database.setSavepoint();
        try
        {
            boolean isProcessSaved = false;
            isProcessSaved = ProcessObjSave();
            boolean isTagsSaved = false;
            if(isProcessSaved)
                isTagsSaved = PLTagSave();
            boolean isCongfigDataSaved = false;
            if(isTagsSaved) 
                isCongfigDataSaved = ConfigDataSave();
            if(isCongfigDataSaved && SVMXPro.id != null)
            {
                //BAC-4012 : To support translation invetory process
                if(SVMXPro.id != null)
                {
                    CONF_ManageTranslations conf_manageTranslations = new CONF_ManageTranslations();
                    conf_manageTranslations.generateMasterTag(SVMXPro.id);
                }
                Pagereference pageref = new pagereference('/apex/SVMXC__CONF_InventoryProcesses');  
                pageref.setRedirect(true);
                return pageref;
            }
            else
                database.rollBack(sp);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
            database.rollBack(sp);
        }
        return null;     
        
    }   
    public pageReference SVMX_doCancel()
    {
        try
        {
            Pagereference pageref = new pagereference('/apex/SVMXC__CONF_InventoryProcesses');  
            pageref.setRedirect(true);
            return pageref;//*/
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
        return null;
    }   
    public pageReference SVMX_GoHome(){return null;}
    public pageReference SVMX_ProcessInformation(){selectedTab = TU.getTAG012();return null;}
    public pageReference SVMX_EntryCriteria(){selectedTab = TU.getTAG013();return null;}
    public pageReference SVMX_UserInputs(){selectedTab = TU.getTAG014();return null;}
    public pageReference SVMX_StockUpdates()
    {
        if(isInventoryEnabled)
            selectedTab = TU.getTAG016();
        else if(selectedTab == TU.getTAG014())
            selectedTab = TU.getTAG108();
        else if(selectedTab == TU.getTAG108())
            selectedTab = TU.getTAG014();
        return null;
    }
    public pageReference SVMX_RelatedTranscation(){selectedTab = TU.getTAG108();return null;}
    public pageReference SVMX_ClosureActions(){selectedTab = TU.getTAG015();return null;}
    public List<SelectOption> getModule()
    {
        return TU.sortingSelectOption(mapModule.values(), true);
    }
    public string selectedTab = System.currentPageReference().getParameters().get('tab');
        public string getselectedTab() {return this.selectedTab;}
        public void setselectedTab(string str) 
        {
            this.selectedTab = TU.setselectedTab(str);
        }
}