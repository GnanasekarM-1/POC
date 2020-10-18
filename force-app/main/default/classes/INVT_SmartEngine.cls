/* Security Scanned */
public with sharing class INVT_SmartEngine 
{
    //-------------------NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    //---------------------------------
    
    //Wrapper to support more than 1000 Stocked Serials in VF Page.
    public class INVTWrapper
    {
        public List<String> FromLocationlst = new List<String>();
        public List<String> getFromLocationlst(){return this.FromLocationlst;}
        public void setFromLocationlst(List<String> FromLocationlst){this.FromLocationlst = FromLocationlst;}
        public List<SelectOption> FromLocationSOlst = new List<SelectOption>();
        public List<SelectOption> getFromLocationSOlst(){return this.FromLocationSOlst;}
        public INVTWrapper(List<SelectOption> FromLocationSOlst, List<String> FromLocationlst)
        {
            this.FromLocationSOlst = FromLocationSOlst;
            this.FromLocationlst = FromLocationlst;
        }
    }
    public list<INVTWrapper> INVTWraplst = new list<INVTWrapper>();
    public list<INVTWrapper> getINVTWraplst(){return this.INVTWraplst;}
    
    public Boolean btnisdisabled = false; 
    public Boolean getbtnisdisabled(){return btnisdisabled;}
    public Boolean DuplicateSerialWarned = false;
    public Boolean getDuplicateSerialWarned(){return DuplicateSerialWarned;}
    public void setDuplicateSerialWarned(Boolean DuplicateSerialWarned){this.DuplicateSerialWarned = DuplicateSerialWarned;}
    public String hdrId = System.currentPageReference().getParameters().get('hdrId');
    public String SMId = System.currentPageReference().getParameters().get('SMId');
    public String LineId = System.currentPageReference().getParameters().get('LineId');
    String idStrLocation;
    public Boolean serSelectionMess = false;
        public Boolean getSerSelectionMess(){return serSelectionMess;}
    public Boolean disableUsrToEnterQty;
        public Boolean getdisableUsrToEnterQty(){return this.disableUsrToEnterQty;}
    public String notifyUser = null;
    public boolean IsbarCodeScanning = false;
        public boolean getIsbarCodeScanning(){return this.IsbarCodeScanning;}
        public void setIsbarCodeScanning(boolean b){this.IsbarCodeScanning = b;}
    public List<Product2> prodRecs = new List<Product2>();
    public Map<string, Product2> mapValidProdRecs = new Map<string, Product2>();
    public map<string, Product2> mapValidSerializedProdcts = new map<string, Product2>();
    public List<String> locIdAr = new List<String>();
    map<string, string> mFromLocation = new map<string, string>();
    map<string, string> mToLocation = new map<string, string>();
    public Boolean showSerialSel;
    public Boolean disableSerialSel;
    public Integer totalValidProdCount = 0;
    public Integer indexOfSelectedXLine = 0;
    boolean isInventoryEnabled = false;
        public boolean getisInventoryEnabled(){return isInventoryEnabled;}
    boolean isLocationInvolved = false;
        public boolean getisLocationInvolved(){return isLocationInvolved;}
    
    //BAC-4227 : Added below selection setting variable 
    boolean isSerialSelectionEnabled = false;
    public boolean getisSerialSelectionEnabled(){return isSerialSelectionEnabled;}
    
    public Map<String, WraperSObject> mapOfProdSoPSID = new Map<String, WraperSObject>();
    public Map<String, WraperSObject> mapOfProdTaPSID = new Map<String, WraperSObject>();
    public Map<String, WraperSObject> mapOfProdSourceDecreasedPSID = new Map<String, WraperSObject>();
    public Map<String, Map<string, WraperSObject>> mapRecFrmSerial = new Map<String,Map<string, WraperSObject>>();
    public Map<String, Map<string, WraperSObject>> mapRecToSerial = new Map<String,Map<string, WraperSObject>>();
    public map<string, set<string>> mapTargetProductSerial = new map<string, set<string>>();
    public list<SVMXC__ServiceMax_Config_Data__c> lstCloserActions,lstHdrCloserActions,lstLineCloserActions,lstRelatedCloserActions;
    public List<SVMXC__ServiceMax_Config_Data__c> invProcessSteps = new List<SVMXC__ServiceMax_Config_Data__c>();
    public SVMXC__ServiceMax_Processes__c oInvProcess = new SVMXC__ServiceMax_Processes__c();
    public COMM_Inventory_Classes.InventoryProcess iPro;
    public COMM_Inventory_Classes.InventoryProcess getinvProcess (){return iPro;}
    public void setinvProcess (COMM_Inventory_Classes.InventoryProcess p){this.iPro = p;}
    public String xHdrName ='';
    public String getxHdrName(){return this.xHdrName;}
    public void setxHdrName(String s){this.xHdrName =s;}
    public List<String> fromSerial = new List<String>();
    public List<String> getfromSerial(){return this.fromSerial;}
        public void setfromSerial(String[] s)
        {
            if(s != null && s.size() > 0)
            {
                if(s[0].toUpperCase() == 'SVMX.NONE')
                    s.remove(0);
            }
            this.fromSerial =s;
        } 
    public List<SelectOption> frmOptions = new List<SelectOption>();
    public List<SelectOption> getfrmOptions() {if(frmOptions.size() == 0) frmOptions.add(new SelectOption('SVMX.NONE',TU.getTAG010()));oCommUtils.sortingSelectOption(frmOptions, true); return frmOptions;}
    public String snString ;
    public String getsnString(){ return this.snString;}
    public void setsnString(String s){this.snString = s;}
    public List<String> toSerial = new List<String>();
        public List<String> gettoSerial(){return this.toSerial;}
        public void settoSerial(String[] s)
        { 
            if(s != null && s.size() > 0)
            {
                if(s[0].toUpperCase() == 'SVMX.NONE')
                    s.remove(0);
            }
            this.toSerial =s;
        } 
    COMM_SVMXC_Utils3 oCommUtils = new COMM_SVMXC_Utils3();
    public List<SelectOption> toOptions = new List<SelectOption>();
    public map<string, SelectOption> maptoOptions = new map<string, SelectOption>();
    public List<SelectOption> gettoOptions() {if(toOptions.size() == 0) toOptions.add(new SelectOption('SVMX.NONE',TU.getTAG010())); oCommUtils.sortingSelectOption(toOptions, true); return toOptions;}
    public String enteredSn ='';
    public String getenteredSn(){ return this.enteredSn;}
    public void setenteredSn(String s){ this.enteredSn =s;} 
    public Integer quickAddCount =0;
    public Integer getquickAddCount(){return this.quickAddCount;}
    public void setquickAddCount(Integer s){ this.quickAddCount =s;} 
    List<sObject> xRecsVar; //Added for BAC-4362
    transient public List<SObject> xRecs; //Added for BAC-4338
    public sObject hdrRec;
    public string hdrName='';
    list<sObject> lstHdr;
    public list<sObject> getlstHdr(){return this.lstHdr;}
    public string gethdrName(){return this.hdrName;}
    public List<INVT_LineRecords> xLines = new List<INVT_LineRecords>();
    public list<INVT_LineRecords>getxLines() {return this.xValidLines;}
    public List<INVT_LineRecords> xValidLines = new List<INVT_LineRecords>();
    public INVT_LineRecords selectedXLine = new INVT_LineRecords();
    public INVT_LineRecords getselectedXLine(){return this.selectedXLine;}
    public void setselectedXLine (INVT_LineRecords s) {this.selectedXLine = s;}
    public Boolean getshowSerialSel(){return this.showSerialSel;}
    public Boolean getdisableSerialSel(){ return this.disableSerialSel;}
    map<string, map<string, list<WraperSObject>>> mapProdSerInDB = new map<string, map<string, list<WraperSObject>>> ();
    public Boolean getdisableNxt()
    {
        if(indexOfSelectedXLine >= totalValidProdCount -1) return true;
        else return false;
    } 
    public Boolean getdisablePrev()
    { 
        if(indexOfSelectedXLine == 0) return true;
        else return false;
    }
    public map<String,map<string, string>> RTypeMap = new map<String,map<string, string>>();
    
    public string LineLable = '';
        public string getLineLable(){return this.LineLable;}
    public string LineNameField = '';
    public string ProductLable = '';
        public string getProductLable(){return this.ProductLable;}
    public string OrignalQuantityLable = '';
        public string getOrignalQuantityLable(){return this.OrignalQuantityLable;}
    public string ActualQuantityProductLable = '';
        public string getActualQuantityProductLable(){return this.ActualQuantityProductLable;}
    
    public COMM_SVMXC_Utils3 TU = new COMM_SVMXC_Utils3(true);
        public COMM_SVMXC_Utils3 getTagsUtils(){return this.TU;} 
    public String getPLTAG001(){return oInvProcess.SVMXC__Parent_Error_Msg__c;}
    public String getPLTAG002() {return oInvProcess.SVMXC__Child_Error_Msg__c;}
    public String getPLTAG003() {return oInvProcess.SVMXC__Name__c;}
    public string UpdateCriteria( string strCriteria)
    {
        if(strCriteria.contains('SVMX.CurrentUser'))
            strCriteria = strCriteria.replace('SVMX.CurrentUser',UserInfo.getUserId());
        return strCriteria;
    }
    Schema.SObjectType STProductStock, STProductSerial,STStockHistory;
    public Map<String, SVMXC__ServiceMax_Config_Data__c> SettingObjectList;
    boolean IsSubmitEnabled = true;
    Boolean isProcessComplate = true;
    public boolean getGBL002()
    {
        if(SettingObjectList.get('GBL002') != null && SettingObjectList.get('GBL002').SVMXC__Internal_Value__c.ToUpperCase() == 'TRUE')
            return true;
        return false;
    }
    public String getGBL004()
    {
        if(SettingObjectList != null && SettingObjectList.get('GBL004') != null && SettingObjectList.get('GBL004').SVMXC__Internal_Value__c != null && SettingObjectList.get('GBL004').SVMXC__Internal_Value__c.length() > 0)
            return SVMX_getCommaSepratedStr(SettingObjectList.get('GBL004').SVMXC__Internal_Value__c.split(','));
        return '';
    }
    
    public boolean getGBL003()
    {
        if(SettingObjectList != null && SettingObjectList.get('GBL003') != null && SettingObjectList.get('GBL003').SVMXC__Internal_Value__c.ToUpperCase() == 'TRUE')
            return true;
        return false;
    }
    public boolean getIsSubmitEnabled(){return this.IsSubmitEnabled;}
    public boolean IsValidxLines = true;
    public boolean getIsValidxLines(){return this.IsValidxLines;}
    String soqlHeader = '';
    String soqlLine = '';
    boolean isValidLine = true;
    sobject sobjFL, sobjTL;
    public Map<String, list<string>> mapSerialSuffix = new Map<String, list<string>>();
    public map<string, list<string>> mapslnoSuffSource = new map<string, list<string>>();
    public map<string, list<string>> mapslnoSuffTarget = new map<string, list<string>>();
    
    public set<Id> setSelectedPSId = new set<Id>();
    //Id setSelectedPSId;
    
    public set<Id> getSourceProductStockIdsForAllLines(String SourceStatus, set<String> setProductId, set<String> setSourceLocation){
        
        Map<Id,SVMXC__Product_Stock__c> mapSourceProductStock = new Map<Id,SVMXC__Product_Stock__c>();
        Set<Id> setId = new Set<Id>();
        
        if(isValidString(SourceStatus)) {
            
            mapSourceProductStock.putAll([Select Id, SVMXC__Product__c, SVMXC__Location__c, SVMXC__Status__c, SVMXC__Quantity2__c FROM SVMXC__Product_Stock__c where SVMXC__Status__c =: SourceStatus  And SVMXC__Product__c IN : setProductId And SVMXC__Location__c IN : setSourceLocation order BY SVMXC__Quantity2__c DESC]);
            // Defect 014477 Fix
            /*Map<String,SVMXC__Product_Stock__c> uniqueRecordsMap = new Map<String,SVMXC__Product_Stock__c>();
            for( SVMXC__Product_Stock__c productStock : mapSourceProductStock.values() ) {
                
                String key = productStock.SVMXC__Product__c + '_' + productStock.SVMXC__Location__c + '_' + productStock.SVMXC__Status__c;
                if( !uniqueRecordsMap.containsKey(key) || uniqueRecordsMap.get(key).SVMXC__Quantity2__c < productStock.SVMXC__Quantity2__c ) {
                    uniqueRecordsMap.put(key, productStock);
                }
            }
            mapSourceProductStock.clear();
            mapSourceProductStock.putAll(uniqueRecordsMap.values());*/
            // Defect 014477 Fix end.
        } else {
            mapSourceProductStock.putAll([Select Id from SVMXC__Product_Stock__c where SVMXC__Status__c = 'DECREASED'  And SVMXC__Product__c IN : setProductId And SVMXC__Location__c IN : setSourceLocation order BY SVMXC__Quantity2__c DESC]);
        }
        system.debug('mapSourceProductStock'+mapSourceProductStock);
        if(mapSourceProductStock.size() > 0){
            setId.addAll(mapSourceProductStock.keyset());
        }
        system.debug('setId'+setId);
        return setId;
    }
    
    // BAC-428: Enhancement request for Tyco
    private Boolean respectActiveProductSerial = false;
    
    public INVT_SmartEngine() 
    {
        try
        {
            List<String> lstSubmoduleId = new List<String>();    
            lstSubmoduleId.add('INVT001');
            Map<String, Map<String,String>> settingsMap = new SVMXC.COMM_Utils_ManageSettings().SVMX_getSettingList(lstSubmoduleId);
            
            if( settingsMap != null && settingsMap.containskey('INVT001') ) {
                
                Map<String, String> inventory001SettingsMap = settingsMap.get('INVT001');
                if(inventory001SettingsMap != null && inventory001SettingsMap.containskey('SET002') && inventory001SettingsMap.get('SET002') != null ) {
                    respectActiveProductSerial = Boolean.valueof( inventory001SettingsMap.get('SET002') );
                }
            }            
            
            Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
            if(isValidString(hdrId) && isValidString(SMId)) 
            {
                //tagPLTextMap = comTagUtils.SVMX_getTagList('INVT001');
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                list<SVMXC__ServiceMax_Processes__c> lstInvProcess = [Select ID, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Confirmation_Message__c, SVMXC__Tag_Keys__c, Name, SVMXC__Parent_Error_Msg__c,SVMXC__Child_Error_Msg__c,SVMXC__Module__c, SVMXC__ProcessID__c, SVMXC__Module__r.SVMXC__ModuleId__c, SVMXC__Name__c, SVMXC__Submodule__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Child_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = :SMId];
                if(lstInvProcess != null && lstInvProcess.size() > 0)
                {
                    oInvProcess = lstInvProcess[0];
                    /* Start - Logic to translate Inventory Process  */
                    if(oInvProcess.SVMXC__Tag_Keys__c != NULL && oInvProcess.SVMXC__Tag_Keys__c.length() > 0)
                        oInvProcess = (new I18N_TranslationDelivery(oInvProcess.SVMXC__Tag_Keys__c, UserInfo.getLanguage())).SVMX_GetProcessTranslation(oInvProcess);
                    /* End */
                }
                
                SettingObjectList = (new SVMXC.COMM_Utils_ManageSettings()).SVMX_getSettingObjectList(oInvProcess.SVMXC__Submodule__r.SVMXC__SubmoduleID__c);
                iPro = new COMM_Inventory_Classes.InventoryProcess(oInvProcess, SettingObjectList, false);
    
                //Fixed : START : BAC-4227 
                isSerialSelectionEnabled = iPro.Enable_Serial_Selection ;
                //Fixed : END : BAC-4227 
                
                String fieldNames;
                String soqlWhrCla;
                Map<String, Schema.SObjectType> tempallObjs = Schema.getGlobalDescribe();
                for(Schema.SObjectType lON : tempallObjs.values())
                {
                    Schema.DescribeSObjectResult D = lON.getDescribe();
                    allObjs.put(D.getName(), lON);
                }
                        
                STProductStock = schema.Sobjecttype.SVMXC__Product_Stock__c.getSobjectType();
                STProductSerial = schema.Sobjecttype.SVMXC__Product_Serial__c.getSobjectType();
                STStockHistory = schema.Sobjecttype.SVMXC__Stock_History__c.getSobjectType();
                
                for(RecordType rt: [Select SobjectType, Name, Id From RecordType])
                {
                    if(!RTypeMap.containsKey(rt.SobjectType))
                        RTypeMap.put(rt.SobjectType,new map<string, string>());
                    RTypeMap.get(rt.SobjectType).put(rt.Name, rt.id);
                }
                if(STProductStock != null)
                    isInventoryEnabled = true;
                isLocationInvolved = isValidString(iPro.Number_of_locations);
                if(iPro != null && oInvProcess.Id != null && ((string)oInvProcess.Id).length() > 0)
                {
                    if(iPro.Is_User_Enter_Qty) 
                        disableUsrToEnterQty = true;
                    else
                        disableUsrToEnterQty = false;
                    xHdrName = '';
            
                    fieldNames = '';
                    string linefieldNames;
                    String hdrFields;
                    boolean HeaderFound = false;
                     
                    hdrFields = oCommUtils.getFieldString(allObjs.get(iPro.Parent_Object_Name));
                    /************Duplicate Check*****************************/
                      // This is the utlity class for duplicate check
                    SVMXC.COMM_Utils_v2 commutilsdup = new SVMXC.COMM_Utils_v2();
                    if(!String.isBlank(hdrFields)){
                    List<String> lstFieldList = hdrFields.split(',');
                    lstFieldList = commutilsdup.checkDuplicateFields(lstFieldList, iPro.Parent_Object_Name);
                     hdrFields = commutilsdup.SVMX_getFieldNamesFromList(lstFieldList);
                 }   
                    /********************************************************/
                    
                    linefieldNames = oCommUtils.getFieldString(allObjs.get(iPro.Child_Object_Name));
                     /*******************duplicate Check*********************/
                     if(!String.isBlank(linefieldNames)){
                       List<String> lstFieldList1 = linefieldNames.split(',');
                       lstFieldList1 = commutilsdup.checkDuplicateFields(lstFieldList1, iPro.Child_Object_Name);
                      linefieldNames = commutilsdup.SVMX_getFieldNamesFromList(lstFieldList1);
                 }   
                    /******************************************/
         
                    if(isValidString(iPro.Related_Product_Field) && isValidString(iPro.RelationShip_Name_to_Product))
                        fieldNames = fieldNames + ', ' + iPro.RelationShip_Name_to_Product+'.'+iPro.Related_Product_Field;
                    else 
                        isProcessComplate = false;
                    if(isInventoryEnabled)
                    { 
                        fieldNames = fieldNames + ', ' + iPro.RelationShip_Name_to_Product+'.'+'SVMXC__Stockable__c';
                        fieldNames = fieldNames + ', ' + iPro.RelationShip_Name_to_Product+'.'+'SVMXC__Enable_Serialized_Tracking__c';
                    }
                    if(iPro.Is_Multiline_Transaction)
                    {
                        if(isValidString( iPro.Child_Object_Name ))
                            linefieldNames += fieldNames;
                        else
                            isProcessComplate = false;
                    }
                    else if(!iPro.Is_Multiline_Transaction)
                    {
                        if(isValidString(iPro.Parent_Object_Name))
                            hdrFields += fieldNames;
                        else
                            isProcessComplate = false;
                    }
                    else
                        isProcessComplate = false;
                    if(isInventoryEnabled && isLocationInvolved)
                    {   
                        if(isInventoryEnabled && iPro.Is_Source_Location_From_Header)
                        {
                            if(isValidString(iPro.RelationShip_to_Source_Location))
                            {
                                hdrFields = hdrFields + ', ' + iPro.RelationShip_to_Source_Location +'.SVMXC__Stocking_Location__c';
                                hdrFields = hdrFields + ', ' + iPro.RelationShip_to_Source_Location +'.Name';
                            }
                            else
                                isProcessComplate = false;
                        }
                        else if(isInventoryEnabled && iPro.Is_Multiline_Transaction)
                        {
                            if(isValidString(iPro.RelationShip_to_Source_Location))
                            {
                                linefieldNames = linefieldNames + ', ' + iPro.RelationShip_to_Source_Location +'.SVMXC__Stocking_Location__c';
                                linefieldNames = linefieldNames + ', ' + iPro.RelationShip_to_Source_Location +'.Name';
                            }
                            else
                                isProcessComplate = false;
                        }
                        else 
                            isProcessComplate = false;
                
                        if(iPro.Number_of_locations.ToUpperCase() == 'TWO' && (iPro.RelationShip_to_Source_Location != iPro.RelationShip_to_Target_Location ))
                        {
                            if(isInventoryEnabled && iPro.Is_Target_Location_From_Header && iPro.Number_of_locations != null && iPro.Number_of_locations.ToUpperCase() == 'TWO')
                            {
                                if(isValidString(iPro.RelationShip_to_Target_Location))
                                {
                                    hdrFields = hdrFields + ', ' + iPro.RelationShip_to_Target_Location +'.SVMXC__Stocking_Location__c';
                                    hdrFields = hdrFields + ', ' + iPro.RelationShip_to_Target_Location +'.Name';
                                }
                                else
                                    isProcessComplate = false;
                            }
                            else if(isInventoryEnabled && iPro.Is_Multiline_Transaction && iPro.Number_of_locations != null && iPro.Number_of_locations.ToUpperCase() == 'TWO')
                            {
                                if(isValidString(iPro.RelationShip_to_Target_Location))
                                {
                                    linefieldNames = linefieldNames + ', ' + iPro.RelationShip_to_Target_Location +'.SVMXC__Stocking_Location__c';
                                    linefieldNames = linefieldNames + ', ' + iPro.RelationShip_to_Target_Location +'.Name';
                                }
                                else
                                    isProcessComplate = false;
                            }
                            else 
                                isProcessComplate = false;
                        }
                    } 
                            
                    soqlLine = 'SELECT ' + linefieldNames + ' FROM ' ;
                    soqlHeader = 'SELECT ' + hdrFields + ' FROM ' ;
    
                    if(isValidString(iPro.Parent_Object_Name))
                        soqlHeader = soqlHeader + iPro.Parent_Object_Name + ' where Id=:hdrId ';
                    else
                        isProcessComplate = false;
                    if(iPro.Is_Multiline_Transaction)
                    {
                        if(isValidString(iPro.Child_Object_Name) && isValidString(iPro.Lookup_Field_to_Parent))
                            soqlLine = soqlLine + iPro.Child_Object_Name + ' where ' + iPro.Lookup_Field_to_Parent + '=:hdrId ';
                        else
                            isProcessComplate = false;
                
                        if(isValidString(iPro.Child_Object_RecordType))
                            soqlLine = soqlLine + ' AND RecordType.Name ' + '=\''+ iPro.Child_Object_RecordType +'\' ';
                    }
                    if (isValidString(iPro.Parent_Object_Criteria))
                        soqlHeader = soqlHeader + ' AND (' + UpdateCriteria(iPro.Parent_Object_Criteria) +')';
                    if (isValidString(iPro.Child_Object_Criteria))
                        soqlLine = soqlLine + ' AND (' + UpdateCriteria(iPro.Child_Object_Criteria) + ')';
         
                    Schema.Sobjecttype STLine;
                    Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
                    if(iPro.Is_Multiline_Transaction)
                    {
                        if(oCommUtils.mapObjectFieldmap.containsKey(iPro.Child_Object_Name))    
                            objfieldMap = oCommUtils.mapObjectFieldmap.get(iPro.Child_Object_Name);
                        STLine = allObjs.get(iPro.Child_Object_Name);
                    }
                    else
                    {
                        if(oCommUtils.mapObjectFieldmap.containsKey(iPro.Parent_Object_Name))   
                            objfieldMap = oCommUtils.mapObjectFieldmap.get(iPro.Parent_Object_Name);
                        STLine = allObjs.get(iPro.Parent_Object_Name);
                    }
                    if(STLine != null)
                    {
                        if(objfieldMap == null || objfieldMap.size() == 0)
                            objfieldMap = STLine.getDescribe().fields.getMap();
                        try
                        {
                            for(Schema.SObjectField fsObj2 :objfieldMap.values())
                            {
                                Schema.DescribeFieldResult f;
                                f = fsObj2.getDescribe();
                                if(isValidString(iPro.Product_Field_API_Name) && f.getName() == iPro.Product_Field_API_Name)
                                    ProductLable = f.getLabel();
                                if(isValidString(iPro.Actual_Qty_API_Name) && f.getName() == iPro.Actual_Qty_API_Name)
                                    ActualQuantityProductLable = f.getLabel();
                                if(isValidString(iPro.Original_Qty_API_Name) && f.getName() == iPro.Original_Qty_API_Name)
                                    OrignalQuantityLable = f.getLabel();
                               if((STLine == Account.SObjectType && f.getName() == 'Name') || (STLine != Account.SObjectType && f.isNameField()))
                                {
                                    LineNameField = f.getName();
                                    LineLable = f.getLabel();
                                }
                            }
                        }
                        catch(exception ex) {
                            
                            System.debug( LoggingLevel.ERROR, ex.getMessage());
                            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
                        }
                    }
    
                    if(isProcessComplate)
                    {
                        try
                        {//*/
                            lstHdr = Database.query(soqlHeader);
                            if(lstHdr != null && lstHdr.size() > 0)
                            {
                                hdrRec = lstHdr[0];
                                if(hdrRec != null && hdrRec.get('id') != null && ((string)hdrRec.get('id')).length() > 0 )
                                {
                                    HeaderFound = true;
                                    try
                                    {
                                        if(oCommUtils.mapObjectNameField.containsKey(iPro.Parent_Object_Name))
                                            hdrName = (string)hdrRec.get(oCommUtils.mapObjectNameField.get(iPro.Parent_Object_Name));
                                        else
                                             hdrName = (string)hdrRec.get('Name');
                                    } catch(exception ex){
                                        System.debug( LoggingLevel.ERROR, ex.getMessage());
                                        System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
                                    }
                                    
                                }
                                else
                                    addexp(getPLTAG001(), false);
                            }
                            else
                                addexp(getPLTAG001(), false);
                        }catch(exception ex){ 
                            addexp( ex.getMessage(), false);btnisdisabled = false;
                            System.debug( LoggingLevel.ERROR, ex.getMessage());
                            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
                        }//*/
                    
                        if(iPro.Is_Multiline_Transaction && hdrRec != null && hdrRec.get('id') != null && ((string)hdrRec.get('id')).length() > 0) 
                        {
                            try
                            {//*/
                                if(LineId != null && LineId.length() > 0)
                                    xRecs = Database.query(soqlLine + ' AND Id = :LineId ');
                                else
                                    xRecs = Database.query(soqlLine);
                                if(xRecs == null || xRecs.size() == 0 )
                                    addexp(getPLTAG002(), false);
                            }
                            catch(exception ex)
                            {
                                addexp(ex.getMessage(), false);
                                btnisdisabled = false;
                                System.debug( LoggingLevel.ERROR, ex.getMessage());
                                System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
                            }//*/
                        }
                    } 
    
                    if(hdrRec != null && hdrRec.get('id') != null && ((string)hdrRec.get('id')).length() > 0 )
                    {
                        if(isInventoryEnabled && isLocationInvolved)
                        {
                            if(iPro.Is_Source_Location_From_Header)
                            {
                                if(isValidString(iPro.RelationShip_to_Source_Location))
                                {
                                    sobjFL = hdrRec.getSObject(iPro.RelationShip_to_Source_Location);
                                    if(sobjFL != null)
                                    {
                                        if (iPro.Is_Source_Location_Stockable && (sobjFL.get('SVMXC__Stocking_Location__c') == null || ( sobjFL.get('SVMXC__Stocking_Location__c') != null && !((Boolean)sobjFL.get('SVMXC__Stocking_Location__c')))))
                                        {
                                            lstError.add(TU.getTAG033() + ' '+ hdrName);
                                            isValidLine = false;
                                        }
                                    }
                                    else if(iPro.Is_Source_Location_Stockable)
                                    {
                                        lstError.add(TU.getTAG033()+ ' '+ hdrName);
                                        isValidLine = false;
                                    }
                                }
                                else 
                                    isProcessComplate = false;
                            }
                            if(iPro.Number_of_locations.ToUpperCase() == 'TWO' )
                            {
                                if(iPro.Is_Target_Location_From_Header != null && iPro.Is_Target_Location_From_Header)
                                {
                                    if( isValidString(iPro.RelationShip_to_Target_Location))
                                    {
                                        sobjTL = hdrRec.getSObject(iPro.RelationShip_to_Target_Location);
                                        if(sobjTL != null)
                                        {
                                            if ( iPro.Is_Target_Location_Stockable && (sobjTL.get('SVMXC__Stocking_Location__c') == null || ( sobjTL.get('SVMXC__Stocking_Location__c') != null&& !((Boolean)sobjTL.get('SVMXC__Stocking_Location__c')))))
                                            {
                                                lstError.add(TU.getTAG035()+ ' '+ hdrName);
                                                isValidLine = false;
                                            }
                                        }
                                        else if(iPro.Is_Target_Location_Stockable)
                                        {
                                            lstError.add(TU.getTAG035()+ ' '+ hdrName);
                                            isValidLine = false;
                                        }
                                    }
                                    else 
                                        isProcessComplate = false;
                                }
                            }
                        }
                     
                        if(!iPro.Is_Multiline_Transaction)
                        {
                            if(isValidString(iPro.RelationShip_Name_to_Product))
                            {
                                sobject sobj = hdrRec.getSObject(iPro.RelationShip_Name_to_Product);
                                if(sobj != null )
                                {
                                    prodRecs.add((Product2)sobj);
                                    /*if(getGBL003() && isInventoryEnabled && !((Boolean)sobj.get('SVMXC__Stockable__c')) && isLocationInvolved)
                                    {
                                        lstError.add(TU.getTAG037() + ' '+ hdrName);
                                        isValidLine = false;
                                    }*/
                                }
                                else
                                {
                                    lstError.add(TU.getTAG051() + ' ' + hdrName);
                                    isValidLine = false;
                                }
                            }
                            else
                                isProcessComplate = false;
                        }
                    }
                    sObject FromLocation;
                    sObject ToLocation;
                    Boolean locDetailsFound = false;
                    if(!iPro.Is_Multiline_Transaction)
                        xRecs = lstHdr;
                    if(isProcessComplate)
                    {
                        if(xRecs != null && xRecs.size() > 0 )
                        {
                            for(SObject xRec: xRecs)
                            {
                                Object fLoID;
                                Object tLoID;
                                Object fLoName;
                                Object tLoName;
                                Object fStatus;
                                Object tStatus;
                                isValidLine = true;
                                
                                INVT_LineRecords temLineRec = new INVT_LineRecords();
                                if(isInventoryEnabled && isLocationInvolved && (!((iPro.Number_of_locations.ToUpperCase() == 'TWO' && isValidString(iPro.Target_Location_API_Name)) || iPro.Number_of_locations.ToUpperCase() != 'TWO' ) || !isValidString(iPro.Source_Location_API_Name)))
                                    isProcessComplate = false;
                                if(isValidString(iPro.Product_Field_API_Name)
                                    && (!iPro.Is_User_Enter_Qty || isValidString(iPro.Actual_Qty_API_Name))
                                    && isValidString(iPro.Original_Qty_API_Name)
                                    )
                                {
                                    sObject prod = xRec.getSObject(iPro.RelationShip_Name_to_Product);
                                    Object pname;
                                     boolean bEnableSerialSelection = false;
                                    if(prod != null)
                                    {
                                        pname = prod.get(iPro.Related_Product_Field);
                                        if(prod.get('SVMXC__Enable_Serialized_Tracking__c') != null )
                                            bEnableSerialSelection = (boolean)prod.get('SVMXC__Enable_Serialized_Tracking__c');
                                    }
                                    Object pid = xRec.get(iPro.Product_Field_API_Name);
                                    Object sQ = xRec.get(iPro.Original_Qty_API_Name);
                                    Object rLi = xRec.Id;
                                    Object aQ;
                                    Object lName;
                                    if(isValidString(LineNameField))
                                        lName = xRec.get(LineNameField);
                                    if(iPro.Is_User_Enter_Qty)
                                        aQ = xRec.get(iPro.Actual_Qty_API_Name);
                                    if(isInventoryEnabled && isLocationInvolved)
                                    {
                                        if(!iPro.Is_Source_Location_From_Header && iPro.Is_Multiline_Transaction)
                                        {
                                            if(isValidString(iPro.RelationShip_to_Source_Location))
                                            {
                                                sobject sobj = xRec.getSObject(iPro.RelationShip_to_Source_Location);
                                                if(sobj != null)
                                                {
                                                    fLoName = sobj.get('Name');
                                                    if((Boolean)sobj.get('SVMXC__Stocking_Location__c'))
                                                        fLoID = sobj.Id;
                                                    fStatus = iPro.Source_Status;
                                                    if (iPro.Is_Source_Location_Stockable && !((Boolean)sobj.get('SVMXC__Stocking_Location__c')))
                                                    {
                                                        lstError.add(TU.getTAG034() + ' ' + (lName != null?lName:'') + ' ' +(pname != null?('('+pname+')'):''));
                                                        isValidLine = false;
                                                    }
                                                    else
                                                    {
                                                        String key = pid + '_' + fLoID + '_' + fStatus;
                                                        if(!mFromLocation.containsKey(key) && xRec.get(iPro.Source_Location_API_Name) != null)
                                                            mFromLocation.put(key, ((string)xRec.get(iPro.Source_Location_API_Name)));
                                                    }
                                                }
                                                else if(iPro.Is_Source_Location_Stockable)
                                                {
                                                    lstError.add(TU.getTAG034()+ ' ' + (lName != null?lName:'') + ' ' +(pname != null?('('+pname+')'):''));
                                                    isValidLine = false;
                                                }
                                            }
                                            else
                                                isProcessComplate = false;
                                        }
                                        else
                                        {
                                            if(sobjFL != null)
                                            {
                                                if (iPro.Is_Source_Location_Stockable && (sobjFL.get('SVMXC__Stocking_Location__c') == null || ( sobjFL.get('SVMXC__Stocking_Location__c') != null && !((Boolean)sobjFL.get('SVMXC__Stocking_Location__c')))))
                                                    isValidLine = false;
                                                fLoName = sobjFL.get('Name');
                                                if((Boolean)sobjFL.get('SVMXC__Stocking_Location__c'))
                                                {
                                                    fLoID = sobjFL.Id;
                                                    String key = pid + '_' + fLoID + '_' + iPro.Source_Status;
                                                    if(!mFromLocation.containsKey(key) && hdrRec.get(iPro.Source_Location_API_Name) != null)
                                                        mFromLocation.put( key,((string)hdrRec.get(iPro.Source_Location_API_Name)));
                                                }
                                            }
                                            else if(iPro.Is_Source_Location_Stockable)
                                                isValidLine = false;
                                        }
                                        if(iPro.Number_of_locations.ToUpperCase() == 'TWO')
                                        {
                                            if(!iPro.Is_Target_Location_From_Header && iPro.Is_Multiline_Transaction )
                                            {
                                                if(isValidString(iPro.RelationShip_to_Target_Location))
                                                {
                                                    sobject sobj = xRec.getSObject(iPro.RelationShip_to_Target_Location);
                                                    if(sobj != null)
                                                    {
                                                        tLoName = sobj.get('Name');
                                                        if((Boolean)sobj.get('SVMXC__Stocking_Location__c'))
                                                            tLoId = sobj.ID;
                                                        tStatus = iPro.Target_Status;
                                                        if (iPro.Is_Target_Location_Stockable && !((Boolean)sobj.get('SVMXC__Stocking_Location__c')))
                                                        {
                                                            lstError.add(TU.getTAG036()+ ' ' + (lName != null?lName:'') + ' ' +(pname != null?('('+pname+')'):''));
                                                            isValidLine = false;
                                                        }
                                                        else
                                                        {
                                                            String key = pid + '_' + tLoId + '_' + tStatus;
                                                            if(!mToLocation.containsKey(key) && xRec.get(iPro.Target_Location_API_Name) != null)
                                                                mToLocation.put(key, ((string)xRec.get(iPro.Target_Location_API_Name)));
                                                        }
                                                    }
                                                    else if(iPro.Is_Target_Location_Stockable)
                                                    {
                                                        lstError.add(TU.getTAG036()+ ' ' + (lName != null?lName:'') + ' ' +(pname != null?('('+pname+')'):''));
                                                        isValidLine = false;
                                                    }
                                                }
                                            }
                                            else 
                                            {
                                                if(sobjTL != null)
                                                {
                                                    if ( iPro.Is_Target_Location_Stockable && (sobjTL.get('SVMXC__Stocking_Location__c') == null || ( sobjTL.get('SVMXC__Stocking_Location__c') != null&& !((Boolean)sobjTL.get('SVMXC__Stocking_Location__c')))))
                                                        isValidLine = false;
                                                    tLoName = sobjTL.get('Name');
                                                    if((Boolean)sobjTL.get('SVMXC__Stocking_Location__c'))
                                                    {
                                                        tLoId = sobjTL.ID;
                                                        String key = pid + '_' + tLoId + '_' + iPro.Target_Status;
                                                        if(!mToLocation.containsKey(key) && hdrRec.get(iPro.Target_Location_API_Name) != null)
                                                            mToLocation.put(key, ((string)hdrRec.get(iPro.Target_Location_API_Name)));
                                                    }
                                                }
                                                else if(iPro.Is_Target_Location_Stockable)
                                                    isValidLine = false;
                                            }
                                        }
                                    }
                                    if(iPro.Is_Multiline_Transaction )
                                    {
                                        if( isValidString(iPro.RelationShip_Name_to_Product))
                                        {
                                            sobject sobj = xRec.getSObject(iPro.RelationShip_Name_to_Product);
                                            if(sobj != null)
                                            {
                                                prodRecs.add((Product2)sobj);
                                                if(isInventoryEnabled)
                                                {
                                                    /*if(getGBL003() && isLocationInvolved && !((Boolean)sobj.get('SVMXC__Stockable__c' )))
                                                    {
                                                        lstError.add(TU.getTAG037() + ' ' + (lName != null?lName:''));
                                                        isValidLine = false;
                                                    }*/
                                                }
                                            }
                                            else
                                            {
                                                lstError.add(TU.getTAG051()+ ' ' + (lName != null?lName:''));
                                                isValidLine = false;
                                            }
                                        }
                                        else
                                            isProcessComplate = false;
                                    }
                                    if(isValidLine)
                                        xLines.add(temLineRec.Assign(xRec,false,pname,pid,sQ,sQ,false,rLi,fLoID,tLoID,fLoName,tLoName,bEnableSerialSelection,lName));
                                }
                                else
                                    isProcessComplate = false;
                            }
                            //Added to initialize this xRecsVar sobject BAC-4362
                            xRecsVar = xRecs;
                            xRecsVar.clear();
                            //Added to initialize this xRecsVar sobject BAC-4362
                        }
                        if(xLines == null || xLines.size() == 0)
                        {
                            addErrorPage(Apexpages.Severity.ERROR);
                            IsSubmitEnabled = false;
                            IsValidxLines = false;
                        }
                        else
                            addErrorPage(Apexpages.Severity.WARNING);
                    }
                    if(isProcessComplate)
                    {
                        buildValidProdRecs();
                        buildValidProdSerializedRecs();
                        buildxValidLines();
            
                        if(mapValidProdRecs.size() >0) 
                        {
                            if(mapValidSerializedProdcts.size() >0)
                                showSerialSel = true;
                        }
                        indexOfSelectedXLine = 0;
                        totalValidProdCount = xValidLines.size();
                        if(isInventoryEnabled && isLocationInvolved)
                            drawSerialSelectionBlock();
                            
                        if(frmOptions != NULL && frmOptions.size() > 0)
                            fillINVTWrapperlst(frmOptions);
                    }
                    else
                        addexp(TU.getTAG038(), false);
                }
                else
                    addexp(TU.getTAG039(), false);
            }
            else
                addexp(TU.getTAG038(), false);
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
    }

    //Method to populate INVTWrapper list
    public void fillINVTWrapperlst(List<SelectOption> fromLocSOlst)
    {
        INVTWraplst.clear();
        if(fromLocSOlst != NULL && fromLocSOlst.size() > 0) {
            
            List<SelectOption> options = new List<SelectOption>();
            oCommUtils.sortingSelectOption(fromLocSOlst, true);
            if(fromLocSOlst.size() > 1000)
            {
                for(SelectOption SO : fromLocSOlst)
                {
                    options.add(SO);
                    if(options.size() == 1000)
                    {
                        List<SelectOption> lstSO = new List<SelectOption>();
                        lstSO.addAll(options);
                        INVTWraplst.add(new INVTWrapper(lstSO, new List<string>()));
                        options.clear();
                    }
                }
                if(options.size() > 0)
                    INVTWraplst.add(new INVTWrapper(options, new List<string>()));
            }
            else
            {
                List<SelectOption> lstSO = new List<SelectOption>();
                lstSO.addAll(fromLocSOlst);
                INVTWraplst.add(new INVTWrapper(lstSO, new List<string>()));
            }
            fromLocSOlst.clear();
        }
    }
    
    public boolean isValidString(String str)
    {
        if(str != null && str.length() > 0)
            return true;
        else
            return false;
    }
    public pageReference Do_SelectBarCodeScanning()
    {
        return null;
    }
    public pageReference Do_SelectLine()
    {
        try
        {
            boolean RecFound = false;
            integer j = 0;
            integer i = 0;
            for(INVT_LineRecords LR :xLines)
            {
                if(LR.selected)
                {
                    if(!(LR.recLineId == selectedXLine.recLineId))
                    {   
                        indexOfSelectedXLine = i;
                        drawSerialSelectionBlock();
                        RecFound = true;
                    }
                    RecFound = true;
                }
                if(LR.recLineId == selectedXLine.recLineId)
                    j = i;
                i++;
            }
            if(!RecFound)
            {
                if(xLines != null && xLines.size() > 0)
                    xLines[j].selected = true;
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING, TU.getTAG041())) ;
                serSelectionMess = false;
            }
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return null;
    }
    public Boolean SVMX_doUpdateRelatedLines()
    {
        try
        {
            for(SVMXC__ServiceMax_Config_Data__c cD :lstRelatedCloserActions)
            {
                string strIds = '';
                for(INVT_LineRecords LR :xValidLines)
                {
                    if(strIds.length() > 0 && LR.LineObject.get(cD.SVMXC__Lookup_Field_API_Name__c) != null && ((string)LR.LineObject.get(cD.SVMXC__Lookup_Field_API_Name__c)).length() > 0)
                        strIds += ', ';
                    strIds += LR.LineObject.get(cD.SVMXC__Lookup_Field_API_Name__c) != null? '\''+ (String)LR.LineObject.get(cD.SVMXC__Lookup_Field_API_Name__c) + '\'' : '' ;
                }
                if(strIds.length() > 0)
                {
                    list<sObject> lstsObj = database.query('select id, ' + cD.SVMXC__Field_Name__c + ' from '+ cD.SVMXC__Object_Name__c + ' where id IN ('+ strIds + ')');
                    if(lstsObj != null)
                    {
                        for(sObject o :lstsObj)
                        {
                            for(INVT_LineRecords LR :xValidLines)
                            {
                                if(o.get('Id') == LR.LineObject.get(cD.SVMXC__Lookup_Field_API_Name__c) )
                                {
                                    if(cD.SVMXC__Operator__c != null && cD.SVMXC__Operator__c.ToUpperCase() == 'SET')
                                        o.put(cD.SVMXC__Field_Name__c, LR.trQty);
                                    else if(cD.SVMXC__Operator__c != null && cD.SVMXC__Operator__c.ToUpperCase() == 'INCREASE')
                                        o.put(cD.SVMXC__Field_Name__c, (o.get(cD.SVMXC__Field_Name__c) != null ? (double)o.get(cD.SVMXC__Field_Name__c) : 0) + LR.trQty);
                                    else if(cD.SVMXC__Operator__c != null && cD.SVMXC__Operator__c.ToUpperCase() == 'DECREASE')
                                        o.put(cD.SVMXC__Field_Name__c, (o.get(cD.SVMXC__Field_Name__c) != null ? (double)o.get(cD.SVMXC__Field_Name__c) : 0) - LR.trQty);
                                    break;
                                }
                            }
                        }
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstsObj, COMM_SecurityUtils.Access.Upsertable)){
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert lstsObj;
                        }
                        else{
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        } 
                        
                    }
                }
            }
            return true;
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), false);
            btnisdisabled = false;
            
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
            
            return false;            
        }
    }
    boolean isUpdateSuccess = true;
    COMM_SVMXC_Utils3 CommSVMXIUtils = new COMM_SVMXC_Utils3();
    public Boolean SVMX_doUpdateXLines()
    {
        try
        {
            //Replaced XRecs to xRecsVar- BAC-4362
            list<WraperSObject> lstCloneLine = new list<WraperSObject>();
            Boolean anyLineOpen = false;
            xRecsVar.clear(); //BAC-4362
            boolean isAllLineZero = true;
            for(INVT_LineRecords xVL : xValidLines)
            {
                if((xVL.trQty > 0) || (xVL.trQty == 0 && (xVL.closeLine || iPro.Source_Action == 'Set' || iPro.Target_Action == 'Set')))
                {
                    isAllLineZero = false;
                    String lnAction = '';
                    if ((xVL.exQty - xVL.trQty) <= 0 || xVL.closeLine )
                        lnAction = 'Close';
                    else if ((xVL.exQty - xVL.trQty) > 0 && !xVL.closeLine)
                    {
                        lnAction = 'Clone';
                        anyLineOpen = true;
                    }
                    system.debug('asdfipro'+lnAction );
                    if(lnAction == 'Clone') 
                    {
                        system.debug('asdfipro'+iPro.Original_Qty_API_Name);
                        SObject cloneXRec = xVL.LineObject.clone(false,true);
                        system.debug('asdfipro'+iPro.Original_Qty_API_Name);
                        cloneXRec.put(iPro.Original_Qty_API_Name,(xVL.exQty - xVL.trQty));
                        if(iPro.Is_User_Enter_Qty)
                            cloneXRec.put(iPro.Actual_Qty_API_Name,null);
                        lstCloneLine.add(new WraperSObject(cloneXRec));// 
                        lnAction = 'Close';
                    }
                    if(lnAction == 'Close')
                    {
                        if(lstLineCloserActions != null && lstLineCloserActions.size() > 0)
                        {
                            for(SVMXC__ServiceMax_Config_Data__c cD : lstLineCloserActions)
                            {
                                COMM_SVMXC_Utils3.WraperSObject oWraperSObject;
                                oWraperSObject = CommSVMXIUtils.updateSObject(xVL.LineObject, cD.SVMXC__Field_Name__c, cD.SVMXC__Display_Type__c, cD.SVMXC__Operand__c,cD.SVMXC__Object_Name__c );
                                if(oWraperSObject != null && oWraperSObject.sObj != null)
                                {
                                    xVL.LineObject = oWraperSObject.sObj;
                                    isUpdateSuccess = oWraperSObject.IsSuccess;
                                } 
                                else
                                    isUpdateSuccess = false;
                            }
                        }
                    }
                    if(iPro.Is_User_Enter_Qty)
                        xVL.LineObject.put(iPro.Actual_Qty_API_Name,xVL.trQty);
                    xRecsVar.add(xVL.LineObject);
                }
            }
            if(isAllLineZero)
            {
                addexp(TU.getTAG058(), true);
                return false;
            }
            else
            {
                for(WraperSObject WO: lstCloneLine)
                {   xRecsVar.add(WO.sObj);}
                if(isUpdateSuccess)
                {
                    System.debug( 'xRecsVar: ' + xRecsVar );
                    //Added for the defect 039676 fix
                    List<Integer> lstOfIndex = new List<Integer>();
                    for(Integer i=0; i<xRecsVar.size(); i++){
                        if(mapPSidAndPSRec != null && mapPSidAndPSRec.size() > 0 && mapPSidAndPSRec.containskey((String)xRecsVar[i].get('Id'))){
                            if(mapPSidAndPSRec.get((String)xRecsVar[i].get('Id')).sObj.get(iPro.Original_Qty_API_Name) != xRecsVar[i].get(iPro.Original_Qty_API_Name)){
                                lstOfIndex.add(i);
                            }
                        }
                    }
                    lstOfIndex.sort();
                    for(Integer i=lstOfIndex.size()-1; i >= 0; i--){
                        xRecsVar.remove(lstOfIndex[i]);
                    }
                    System.debug('xRecsVar after records removed: ' + xRecsVar);
                    //
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(xRecsVar, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert xRecsVar;
                    }
                    else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                    
                    if(!anyLineOpen && lstHdrCloserActions != null && lstHdrCloserActions.size() > 0)
                        return SVMX_doUpdateXHeader();
                    else
                        return true;
                }
            }
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), false);
            btnisdisabled = false;
            
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
            
            return false;
        }
        try
        {
            if(lstHdrCloserActions != null && lstHdrCloserActions.size() > 0)
                return SVMX_doUpdateXHeader();
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
            return false;
        }
        return false;
    }
    public Boolean SVMX_doUpdateXHeader()
    {
        try
        {
            //Replaced XRecs to xRecsVar- BAC-4362
            if(iPro.Is_Multiline_Transaction)
            {
                xRecsVar = null;
                xRecsVar = Database.query(soqlLine);
            }
            else if(xRecsVar != null && xRecsVar.size() > 0)
                hdrRec = xRecsVar[0];
            if((!iPro.Is_Multiline_Transaction || xRecsVar == null || xRecsVar.size() == 0) && lstHdrCloserActions != null && lstHdrCloserActions.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c cD : lstHdrCloserActions)
                {
                    COMM_SVMXC_Utils3.WraperSObject oWraperSObject;
                    oWraperSObject = CommSVMXIUtils.updateSObject(hdrRec, cD.SVMXC__Field_Name__c, cD.SVMXC__Display_Type__c, cD.SVMXC__Operand__c, cD.SVMXC__Object_Name__c);
                    if(oWraperSObject != null && oWraperSObject.sObj != null)
                    {
                        hdrRec = oWraperSObject.sObj;
                        isUpdateSuccess = oWraperSObject.IsSuccess;
                    } 
                    else
                        isUpdateSuccess = false;
                }
                if(isUpdateSuccess)
                {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(hdrRec, COMM_SecurityUtils.Access.Upsertable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                upsert hdrRec;
                }
                else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
                    
                    return true;
                }
            }
            else
                return true;
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), false);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return false;
    }

    public Boolean SVMX_doSerialSave()
    {
        try
        {

            if(lstConcreteSerialNumbers != null)
                lstConcreteSerialNumbers.Clear();
            string RTypeSerialHistory = getRcordType('SVMXC__Stock_History__c','Serial History');
            List<WraperSObject> listSerialSave = new List<WraperSObject>();
            map<string, WraperSObject> mapSerialHistory = new map<string, WraperSObject>();
            if(STProductStock != null)
            {
                for(INVT_LineRecords xVL : xValidLines)
                {
                    if(mapValidProdRecs.containsKey((String)xVL.prodId) && xVL.isEnableSerialSelection)
                    {
                        Product2 pR = mapValidProdRecs.get((String)xVL.prodId);
                        if( xVL.trQty > 0)
                        {
                            SObject tarPSID = STProductStock.newSObject();
                            String key = xVL.prodId + '_' + xVL.getFromLocationID() + '_' + iPro.Source_Status;
                            if(iPro != null && iPro.Number_of_locations.ToUpperCase() == 'ONE')
                            {                                
                                if (iPro.Source_Action == 'Set' || iPro.Source_Action == 'Increase')
                                {   
                                    if(mapOfProdSoPSID.containskey(key) && mapOfProdSoPSID.get(key) != null)
                                        tarPSID = mapOfProdSoPSID.get(key).sObj;
                                }
                                else
                                {
                                    String targetkey = xVL.prodId + '_' + xVL.getToLocationID() + '_' + iPro.Source_Status;
                                    if(mapOfProdTaPSID.containskey(targetkey) && mapOfProdTaPSID.get(targetkey) != null)
                                        tarPSID = mapOfProdTaPSID.get(targetkey).sObj;
                                }
                            }
                            if(iPro != null && iPro.Number_of_locations.ToUpperCase() == 'TWO')
                            {
                                if(xVL.ToLocationID != null && ((String)xVL.ToLocationID).length() > 0)
                                {
                                    String targetkey = xVL.prodId + '_' + xVL.getToLocationID() + '_' + iPro.Source_Status;
                                    if(mapOfProdTaPSID.containsKey(targetkey) && mapOfProdTaPSID.get(targetkey) != null)
                                        tarPSID = mapOfProdTaPSID.get(targetkey).sObj;
                                }
                                else
                                {                                    
                                    if(mapOfProdSourceDecreasedPSID.containskey(key) &&  mapOfProdSourceDecreasedPSID.get(key) != null) 
                                        tarPSID = mapOfProdSourceDecreasedPSID.get(key).sObj;
                                }
                            }
                            map<string,WraperSObject> toSNList = new map<string,WraperSObject>();
                            if(mapRecToSerial.containskey(((string)xVL.recLineId)) && mapRecToSerial.get(((string)xVL.recLineId)) != null )
                                toSNList = mapRecToSerial.get(((string)xVL.recLineId));
                            for(WraperSObject toSN : toSNList.values())
                            {
                               if(STStockHistory != null && iPro != null && iPro.Maintain_Serial_History && !((String)toSN.SObj.get('SVMXC__Product_Stock__c') == tarPSID.Id))
                                {
                                    SObject SerialHistory = STStockHistory.newSObject();
                                    SerialHistory.put('RecordTypeId', RTypeSerialHistory);
                                    SerialHistory.put('SVMXC__Transaction_Type__c',oInvProcess.SVMXC__Name__c);
                                    SerialHistory.put('SVMXC__Inventory_Process__c', oInvProcess.Id);
                                    SerialHistory.put('SVMXC__From_Product_Stock__c', (String)toSN.SObj.get('SVMXC__Product_Stock__c'));
                                    SerialHistory.put('SVMXC__To_Product_Stock__c', tarPSID.Id);
                                    SerialHistory.put('SVMXC__Date_Changed__c', datetime.now());
                                    SerialHistory.put('SVMXC__Changed_By__c', UserInfo.getUserId());
                                    if(!iPro.Is_Multiline_Transaction && IsValidString(iPro.Stock_History_Header_API_Name))
                                        SerialHistory.put(iPro.Stock_History_Header_API_Name, hdrId);
                                    if(iPro.Is_Multiline_Transaction && IsValidString(iPro.Stock_History_Line_API_Name))
                                        SerialHistory.put(iPro.Stock_History_Line_API_Name, xVL.recLineId);
                                    mapSerialHistory.put((String)toSN.SObj.get('Name'), new WraperSObject(SerialHistory));
                                }
                                
                                toSN.SObj.put('SVMXC__Product_Stock__c', tarPSID.Id);
                                toSN.SObj.put('SVMXC__Product__c', ((string)xVL.prodId));
                                toSN.SObj.put('SVMXC__Active__c', true);
                                
                                lstConcreteSerialNumbers.add(toSN.SObj);
                            }
                        }
                    }
                }
                if(iPro != null && iPro.Number_of_locations.ToUpperCase() == 'ONE' && iPro.Source_Action == 'Set')
                {
                    System.debug('In the block');
                    for(string str :mapRecFrmSerial.keyset())
                    {
                        for(WraperSObject frmSN : mapRecFrmSerial.get(str).values())
                        {
                            if(STStockHistory != null && iPro.Maintain_Serial_History)
                            {
                                
                                SObject SerialHistory = STStockHistory.newSObject();
                                SerialHistory.put('RecordTypeId', RTypeSerialHistory);
                                SerialHistory.put('SVMXC__Transaction_Type__c',oInvProcess.SVMXC__Name__c);
                                SerialHistory.put('SVMXC__Inventory_Process__c', oInvProcess.Id);
                                SerialHistory.put('SVMXC__From_Product_Stock__c', (String)frmSN.sObj.get('SVMXC__Product_Stock__c'));
                                SerialHistory.put('SVMXC__To_Product_Stock__c', mapOfProdTaPSID.get(str).sObj.id);
                                SerialHistory.put('SVMXC__Date_Changed__c', datetime.now());
                                SerialHistory.put('SVMXC__Changed_By__c',UserInfo.getUserId());
                                if(!iPro.Is_Multiline_Transaction && IsValidString(iPro.Stock_History_Header_API_Name))
                                    SerialHistory.put(iPro.Stock_History_Header_API_Name, hdrId);
                                if(iPro.Is_Multiline_Transaction && IsValidString(iPro.Stock_History_Line_API_Name))
                                {
                                    for(INVT_LineRecords xVL : xValidLines)
                                    {
                                        String pId = str.split('_')[0];
                                        if(pId == xVL.prodId)
                                        {
                                            SerialHistory.put(iPro.Stock_History_Line_API_Name, xVL.recLineId);
                                            break;
                                        }
                                    }
                                }
                                if(iPro.Maintain_Serial_History)
                                    mapSerialHistory.put((String)frmSN.sObj.get('Name'), new WraperSObject(SerialHistory));
                            }
                            if(mapOfProdTaPSID.containskey(str) && mapOfProdTaPSID.get(str) != null && mapOfProdTaPSID.get(str).sObj != null)
                            {
                                frmSN.sObj.put('SVMXC__Product_Stock__c', mapOfProdTaPSID.get(str).sObj.id);
                                lstConcreteSerialNumbers.add(frmSN.SObj);
                            }
                        }
                    }
                }
                if(lstConcreteSerialNumbers != null)
                {
                    for(sobject sobj:lstConcreteSerialNumbers)
                    {
                        string tempname;
                        tempname=(string)sobj.get('Name');
                        if(tempname.contains('^'))
                        {
                            tempname=tempname.substring(0,tempname.indexOf('^'));
                            sobj.put('Name',tempname);
                        }
                    
                    } 
                }               
                
                if(lstConcreteSerialNumbers != null && lstConcreteSerialNumbers.size() >0) 
                {
                    System.debug('Inside doSerialSave() lstConcreteSerilaNumbers :' + lstConcreteSerialNumbers);
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConcreteSerialNumbers, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstConcreteSerialNumbers;
                    }
                    else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                    
                    
                    List<SObject> tmplstConcreteSerialNumbers = lstConcreteSerialNumbers.clone();
                    System.debug('Inside doSerialSave() mapSerialHistory' + mapSerialHistory);
                    
                    //following for loop is to iterate over the serial history map when the From location is nonstocking and To Location is stocking
                    for(String name : mapSerialHistory.keySet())
                    {
                        System.debug('Inside doSerialSave() mapSerialHistory record name :' + Name);
                        
                        if(name.indexOf('^')!= -1) {
                            for(integer i = 0; i < tmplstConcreteSerialNumbers.size(); i++) {
                                //Serial History record name is mapped with the name of the concrete serial numers, then update the product serial in To location       
                                if(name.substring(0,name.indexOf('^')).equals(tmplstConcreteSerialNumbers[i].get('Name')))
                                    mapSerialHistory.get((String)tmplstConcreteSerialNumbers[i].get('Name')+ name.substring(name.indexOf('^'))).SObj.put('SVMXC__Product_Serial__c', tmplstConcreteSerialNumbers[i].Id);
                                    System.debug('Inside doSerialSave() Serial record ID is :' + tmplstConcreteSerialNumbers[i].Id);
                                    tmplstConcreteSerialNumbers.remove(i);
                                    break;
                            }           
                        }                     
                     }
                     tmplstConcreteSerialNumbers.clear();
                     
                     for(SObject PS: lstConcreteSerialNumbers)
                     {
                         if(mapSerialHistory.containsKey((String)PS.get('Name')))
                            mapSerialHistory.get((String)PS.get('Name')).SObj.put('SVMXC__Product_Serial__c', PS.Id);
                         System.debug('Inside doSerialSave() existing implementation');    
                     }                     
                }
                if(mapSerialHistory.size() > 0)
                {
                    list<SObject> lstConcreteSerialHistory = database.Query('select Id from SVMXC__Stock_History__c limit 0');
                    for(WraperSObject WO :mapSerialHistory.values())
                    {
                        lstConcreteSerialHistory.add(WO.SObj);
                    }
                    if(lstConcreteSerialHistory.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConcreteSerialHistory, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstConcreteSerialHistory;
                    }
                    else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                    }
                        
                }
            }
            return true;
        }
        catch (Exception ex)
        { 
            addexp(ex.getmessage(), false);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
            return false;
        }

    }
    
    List<SObject> TargetStock;
    List<SObject> SourceStock;
    List<SObject> SourceStockDecreased;
    List<SObject> newTargetStock;
    List<SObject> newSourceStock;
    List<SObject> newSourceStockDecreased;
    public boolean getisSourcelocationExists()
    {
        if(iPro.Is_Source_Location_From_Header)
        {
            if(sobjFL != null)
                return true;
        }
        else if(IsValidString(iPro.RelationShip_to_Source_Location) && selectedXLine.LineObject.getSObject(iPro.RelationShip_to_Source_Location) != null)
            return true;
        return false;
    }
    double adjusetedQty = 0;
    public boolean getisTargetlocationExists()
    {
        if(iPro.Is_Target_Location_From_Header)
        {
            if(sobjTL != null)
                return true;
        }
        else if( iPro.Number_of_locations.ToUpperCase() == 'TWO' && IsValidString(iPro.RelationShip_to_Target_Location) && selectedXLine.LineObject.getSObject(iPro.RelationShip_to_Target_Location) != null)
            return true;
        return false;
    } 
    map<string,map<string,map<string,WraperSObject>>> mapAllStock = new map<string,map<string,map<string,WraperSObject>>>();
    boolean IsStockChecked = false;
    
    public void CheckStock()
    {
        try
        {
            set<string> setNewSourceStock = new set<String>();
            set<string> setNewSourceStockDecreased = new set<String>();
            set<string> setNewTargetStock = new set<String>();
            if(iPro.Number_of_locations != null && iPro.Number_of_locations != '' && STProductStock != null )
            {
                string strProductID = '';
                set<Id> setProductID =new set<Id>();
                if(newSourceStock != null)
                    newSourceStock.Clear();
                if(newSourceStockDecreased != null)
                    newSourceStockDecreased.Clear();
                if(newTargetStock != null)
                    newTargetStock.Clear();
                if(SourceStock != null)
                    SourceStock.Clear();
                if(TargetStock != null)
                    TargetStock.Clear();
                for(INVT_LineRecords xVL : xValidLines)
                {
                    if (strProductID .length()>0)
                        strProductID+= ',';
                    strProductID+= '\'' + ((string)xVL.prodId) + '\'';
                    if(!setProductID.Contains(((string)xVL.prodId)))
                        setProductID.add(((string)xVL.prodId));
                }
                string idSouLocation = SVMX_getCommaSepratedStr(mFromLocation.values());
                string idTarLocation = SVMX_getCommaSepratedStr(mToLocation.values());
                
                string strstockFields = 'LastModifiedDate , SVMXC__Quantity2__c, SVMXC__Location__r.SVMXC__Email__c, SVMXC__Location__c, SVMXC__Location__r.name, SVMXC__Status__c, SVMXC__Product__c, Id';
                map<String,SVMXC__Product_Stock__c> mapSourceStock = new map<String,SVMXC__Product_Stock__c>(); 
                if(isValidString(strstockFields) && isValidString(strProductID) && isValidString(idSouLocation))
                {
                    if(isValidString(iPro.Source_Status)) {
                        if( setSelectedPSId != null && !setSelectedPSId.isEmpty() ) {
                            SourceStock = Database.query('Select '+strstockFields+' From SVMXC__Product_Stock__c where SVMXC__Status__c IN (\'' + iPro.Source_Status + '\') And SVMXC__Product__c IN ( ' + strProductID + ') And SVMXC__Location__c IN (' + idSouLocation + ') And Id IN :setSelectedPSId order BY SVMXC__Quantity2__c DESC');
                        } else {
                            SourceStock = Database.query('Select '+strstockFields+' From SVMXC__Product_Stock__c where SVMXC__Status__c IN (\'' + iPro.Source_Status + '\') And SVMXC__Product__c IN ( ' + strProductID + ') And SVMXC__Location__c IN (' + idSouLocation + ')');
                        }
                    } else {
                        if( setSelectedPSId != null && !setSelectedPSId.isEmpty() ) {
                            SourceStock = Database.query('Select '+strstockFields+' From SVMXC__Product_Stock__c where SVMXC__Status__c IN (\'DECREASED\') And SVMXC__Product__c IN ( ' + strProductID + ') And SVMXC__Location__c IN (' + idSouLocation + ') And Id IN :setSelectedPSId order BY SVMXC__Quantity2__c DESC');
                        } else {
                            SourceStock = Database.query('Select '+strstockFields+' From SVMXC__Product_Stock__c where SVMXC__Status__c IN (\'DECREASED\') And SVMXC__Product__c IN ( ' + strProductID + ') And SVMXC__Location__c IN (' + idSouLocation + ')');
                            
                        }
                    }
                    SourceStockDecreased = Database.query('Select '+strstockFields+' From SVMXC__Product_Stock__c where SVMXC__Status__c IN (\'DECREASED\') And SVMXC__Product__c IN ( ' + strProductID + ') And SVMXC__Location__c IN (' + idSouLocation + ')');
                }
                
                if(SourceStock == null)
                    SourceStock = Database.query('Select id,LastModifiedDate From SVMXC__Product_Stock__c limit 0');
                    
                for(Sobject s : SourceStock){
                    String key = s.get('SVMXC__Product__c') + '_' + s.get('SVMXC__Location__c') + '_' + iPro.Source_Status;
                    mapSourceStock.put(key,(SVMXC__Product_Stock__c)s);
                }
                /*
                for(String str : mapOfProdSoPSID.keyset()) {                    
                    if(mapSourceStock.containskey(str) && Datetime.valueof(mapOfProdSoPSID.get(str).sObj.get('LastModifiedDate')).getTime() != Datetime.valueof(mapSourceStock.get(str).LastModifiedDate).getTime()){
                        addexp(system.label.INVT001_TAG074,false);
                    }   
                }   
                */
                if(isValidString(strstockFields) && isValidString(idTarLocation) && isValidString(strProductID))
                {
                    if(isValidString(iPro.Target_Status))
                        TargetStock = Database.query('Select '+strstockFields+' From SVMXC__Product_Stock__c where SVMXC__Status__c IN (\'' + iPro.Target_Status + '\') And SVMXC__Product__c IN ( ' + strProductID + ') And SVMXC__Location__c IN (' + idTarLocation + ')');
                }
                if(iPro.Number_of_locations.ToUpperCase() == 'ONE' && iPro.Source_Action.ToUpperCase() == 'SET' && isValidString(strstockFields) && isValidString(idSouLocation) && isValidString(strProductID))
                    TargetStock = Database.query('Select '+strstockFields+' From SVMXC__Product_Stock__c where SVMXC__Status__c IN (\'ADJUSTED\') And SVMXC__Product__c IN ( ' + strProductID + ') And SVMXC__Location__c IN (' + idSouLocation + ')');
                if(TargetStock == null)
                    TargetStock = Database.query('Select id,LastModifiedDate From SVMXC__Product_Stock__c limit 0');
                
                System.debug( LoggingLevel.DEBUG, 'TargetStock: ' + TargetStock );
                System.debug( 'xValidLines: ' + xValidLines );
                System.debug('SourceStock:' + SourceStock );
                for(INVT_LineRecords xVL :xValidLines)
                { 
                    string prodId = (String)xVL.prodId;
                    string FromLocation = (String)xVL.FromLocationId;
                    string ToLocation = (String)xVL.ToLocationId;
                    if(SourceStock != null && xVL.trQty != null && ((xVL.trQty > 0) || (xVL.trQty == 0 && (iPro.Source_Action == 'Set' || iPro.Target_Action == 'Set'))))
                    {
                        Boolean sourceFound = false;
                        for(SObject sPS :SourceStock)
                        {
                            if(prodId == (Id)sPS.get('SVMXC__Product__c') && xVL.FromLocationId == (Id)sPS.get('SVMXC__Location__c') && iPro.Source_Status == (String)sPS.get('SVMXC__Status__c'))
                            {
                                sourceFound = true;
                                break;
                            }
                        }
                           
                        if(!sourceFound)
                        {
                            if(newSourceStock == null)
                                newSourceStock = database.query('Select LastModifiedDate, SVMXC__Quantity2__c, SVMXC__Location__r.SVMXC__Email__c, SVMXC__Location__c, SVMXC__Location__r.name, SVMXC__Status__c, SVMXC__Product__c, Id From SVMXC__Product_Stock__c limit 0');
                            if(isValidString(FromLocation) && isValidString(prodId) && isValidString(iPro.Source_Status) && !setNewSourceStock.contains(prodId+FromLocation+iPro.Source_Status))
                            {
                                sObject sObjPS = STProductStock.newSObject();
                                sObjPS.put('SVMXC__Quantity2__c', 0);
                                sObjPS.put('SVMXC__ActualQtyBeforeUpdate__c', sObjPS.get('SVMXC__Quantity2__c') );
                                sObjPS.put('SVMXC__Product__c', prodId);
                                sObjPS.put('SVMXC__Location__c', FromLocation);
                                sObjPS.put('SVMXC__Status__c', iPro.Source_Status);
                                newSourceStock.add(sObjPS);
                                setNewSourceStock.add(prodId+FromLocation+iPro.Source_Status);
                            }
                        }
                    }
                    if(SourceStockDecreased != null && xVL.trQty != null && (xVL.trQty > 0 || (xVL.trQty == 0 && (iPro.Source_Action == 'Set' || iPro.Target_Action == 'Set'))))
                    {
                        Boolean sourceDecreasedFound = false;
                        for(SObject sPS :SourceStockDecreased)
                        {
                            if(prodId == (Id)sPS.get('SVMXC__Product__c') && xVL.FromLocationId == (Id)sPS.get('SVMXC__Location__c') && (String)sPS.get('SVMXC__Status__c') == 'DECREASED')
                            {
                                sourceDecreasedFound = true;
                                break;
                            }
                        }
                        if(!sourceDecreasedFound)
                        {
                            if(newSourceStockDecreased == null)
                                newSourceStockDecreased = database.query('Select LastModifiedDate, SVMXC__Quantity2__c, SVMXC__Location__r.SVMXC__Email__c, SVMXC__Location__c, SVMXC__Location__r.name, SVMXC__Status__c, SVMXC__Product__c, Id From SVMXC__Product_Stock__c limit 0');
                            
                            if(isValidString(FromLocation) && isValidString(prodId) && !setNewSourceStockDecreased.contains(prodId+FromLocation+'DECREASED'))
                            {
                                sObject sObjPS = STProductStock.newSObject();
                                sObjPS.put('SVMXC__Quantity2__c', 0);
                                sObjPS.put('SVMXC__ActualQtyBeforeUpdate__c', sObjPS.get('SVMXC__Quantity2__c') );
                                sObjPS.put('SVMXC__Product__c', prodId);
                                sObjPS.put('SVMXC__Location__c', FromLocation);
                                sObjPS.put('SVMXC__Status__c', 'DECREASED');
                                newSourceStockDecreased.add(sObjPS);
                                setNewSourceStockDecreased.add(prodId+FromLocation+'DECREASED');
                            }
                        }
                    }
                    
                    if(TargetStock != null && xVL.trQty != null && (xVL.trQty > 0 || (xVL.trQty == 0 && (iPro.Source_Action == 'Set' || iPro.Target_Action == 'Set'))))
                    {
                        Boolean targetFound = false;
                        for(SObject sPS :TargetStock)
                        {
                            if(prodId == (Id)sPS.get('SVMXC__Product__c') && xVL.ToLocationId == (Id)sPS.get('SVMXC__Location__c') && iPro.Target_Status == (String)sPS.get('SVMXC__Status__c'))
                            {
                                targetFound = true;
                                break;
                            }
                            if(xVL.ToLocationId == null || ((String)xVL.ToLocationId).length() == 0)
                            {
                                if(prodId == (Id)sPS.get('SVMXC__Product__c') && xVL.ToLocationId == (Id)sPS.get('SVMXC__Location__c') && 'DECREASED' == ((String)sPS.get('SVMXC__Status__c')).ToUpperCase())
                                {
                                    targetFound = true;
                                    break;
                                }
                            }
                            if(iPro.Number_of_locations.ToUpperCase() == 'ONE' && iPro.Source_Action.ToUpperCase() == 'SET')
                            {
                                if(prodId == (Id)sPS.get('SVMXC__Product__c') && xVL.FromLocationId == (Id)sPS.get('SVMXC__Location__c') && ((String)sPS.get('SVMXC__Status__c')).ToUpperCase() == 'ADJUSTED')
                                {
                                    targetFound = true;
                                    break;
                                }
                            }
                        }
                        /*Method Moved to SVMXI_Utils 4*/
                        if(!targetFound)
                        {
                            if(newTargetStock == null)
                                newTargetStock = database.query('Select LastModifiedDate, SVMXC__Quantity2__c, SVMXC__Location__r.SVMXC__Email__c, SVMXC__Location__c, SVMXC__Location__r.name, SVMXC__Status__c, SVMXC__Product__c, Id From SVMXC__Product_Stock__c limit 0');
                            sObject sObjPS = STProductStock.newSObject();
                            sObjPS.put('SVMXC__Quantity2__c', 0);
                            sObjPS.put('SVMXC__ActualQtyBeforeUpdate__c', 0);
                            sObjPS.put('SVMXC__Product__c', prodId);
                            if(isValidString(iPro.Target_Status) && isValidString(prodId))
                            {
                                if(IsValidString(ToLocation) && !setNewTargetStock.contains(prodId+FromLocation+iPro.Target_Status))
                                {
                                    sObjPS.put('SVMXC__Status__c', iPro.Target_Status);
                                    sObjPS.put('SVMXC__Location__c', ToLocation);
                                    newTargetStock.add(sObjPS);
                                    System.debug('Adding new target stock: ' + sObjPS );
                                    setNewTargetStock.add(prodId+FromLocation+iPro.Target_Status);
                                }
                            }
                            if(iPro.Number_of_locations.ToUpperCase() == 'ONE' && iPro.Source_Action.ToUpperCase() == 'SET')
                            {
                                sObjPS.put('SVMXC__Status__c', 'ADJUSTED');
                                sObjPS.put('SVMXC__Location__c', FromLocation);
                                if(isValidString(FromLocation) && isValidString(prodId) && !setNewTargetStock.contains(prodId+FromLocation+'ADJUSTED'))
                                {
                                    newTargetStock.add(sObjPS);
                                    System.debug('Adding new target stock: ' + sObjPS );
                                    setNewTargetStock.add(prodId+FromLocation+'ADJUSTED');
                                }
                            }
                        }
                    }
                }
                
                system.debug('newSourceStock: '+newSourceStock);
                system.debug('newSourceStockDecreased: '+newSourceStockDecreased);
                system.debug('newTargetStock: '+newTargetStock);
                system.debug('mapOfProdSoPSID: '+mapOfProdSoPSID);
                
                if(newSourceStock != null && newSourceStock.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(newSourceStock, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert newSourceStock;
                    }
                    else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                }
                    
                if(newSourceStockDecreased != null && newSourceStockDecreased.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(newSourceStockDecreased, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert newSourceStockDecreased;
                    }
                    else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                }
                    
                if(newTargetStock != null && newTargetStock.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(newTargetStock, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert newTargetStock;
                    }
                    else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                }
                    
                
                if(SourceStock != null && SourceStock.size() > 0)
                {
                    for(SObject sPS :SourceStock )
                    {
                       String key = sPS.get('SVMXC__Product__c') + '_' + sPS.get('SVMXC__Location__c') + '_' + iPro.Source_Status;
                       mapOfProdSoPSID.put(key, new WraperSObject(sPS));
                    }
                }
                if(newSourceStock != null && newSourceStock.size() > 0)
                {
                    for(SObject sPS :newSourceStock )
                    {
                        String key = sPS.get('SVMXC__Product__c') + '_' + sPS.get('SVMXC__Location__c') + '_' + iPro.Source_Status;
                        mapOfProdSoPSID.put(key, new WraperSObject(sPS));
                    }
                }
                if(SourceStockDecreased != null && SourceStockDecreased.size() > 0)
                {
                    for(SObject sPS :SourceStockDecreased )
                    {
                        String key = sPS.get('SVMXC__Product__c') + '_' + sPS.get('SVMXC__Location__c') + '_' + iPro.Source_Status;
                        mapOfProdSourceDecreasedPSID.put(key, new WraperSObject(sPS));
                    }
                }
                if(newSourceStockDecreased != null && newSourceStockDecreased.size() > 0)
                {
                    for(SObject sPS :newSourceStockDecreased ) 
                    {
                        String key = sPS.get('SVMXC__Product__c') + '_' + sPS.get('SVMXC__Location__c') + '_' + iPro.Source_Status;
                        mapOfProdSourceDecreasedPSID.put(key, new WraperSObject(sPS));
                    }
                }
                if(TargetStock != null && TargetStock.size() > 0)
                {
                    for(SObject tPS :TargetStock)
                    {
                        String key = tPS.get('SVMXC__Product__c') + '_' + tPS.get('SVMXC__Location__c') + '_' + iPro.Source_Status;
                        mapOfProdTaPSID.put(key, new WraperSObject(tPS));
                    }
                }
                if(newTargetStock != null && newTargetStock.size() > 0)
                {
                    for(SObject tPS :newTargetStock)
                    {
                        String key = tPS.get('SVMXC__Product__c') + '_' + tPS.get('SVMXC__Location__c') + '_' + iPro.Source_Status;
                        mapOfProdTaPSID.put(key, new WraperSObject(tPS));
                    }
                }
                system.debug('mapOfProdSoPSID'+mapOfProdSoPSID);
                system.debug('mapOfProdSourceDecreasedPSID'+mapOfProdSourceDecreasedPSID);
                system.debug('mapOfProdTaPSID'+mapOfProdTaPSID);
            }
        }
        catch (Exception e)
        { 
            addexp(e.getmessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, e.getMessage());
            System.debug( LoggingLevel.ERROR, e.getStackTraceString());
        }
    }
    
    //For defect 039676 handling 
    Map<String, WraperSObject> mapPSidAndPSRec = new Map<String, WraperSObject>();
    public Boolean SVMX_doStockUpdate()
    {
        try
        {//*/
            if(iPro.Number_of_locations != null && iPro.Number_of_locations != '' && STProductStock != null )
            {
                string RTypeStockHistory = getRcordType('SVMXC__Stock_History__c','Stock History');
                List<SObject> listStkHistRecs = database.query('select Id from SVMXC__Stock_History__c limit 0');
                map<string, list<INVT_LineRecords>> mapMailList = new map<string, list<INVT_LineRecords>>();
                if(iPro.Email_For_Negative_Stock_Alert != null && iPro.Email_For_Negative_Stock_Alert.length() > 0)
                    mapMailList.put(iPro.Email_For_Negative_Stock_Alert, new list<INVT_LineRecords>());
                for(INVT_LineRecords xVL : xValidLines)
                {
                    String pid =((string)xVL.prodId);
                    String recLid = ((string)xVL.recLineId);
                    boolean IsProductStockable = false;
                    if(xVL.trQty > 0 || (xVL.trQty == 0 && (iPro.Source_Action == 'Set' || iPro.Target_Action == 'Set')))
                    {
                        if(!iPro.Is_Multiline_Transaction && isValidString(iPro.RelationShip_Name_to_Product))
                        {
                            sobject sobj = hdrRec.getSObject(iPro.RelationShip_Name_to_Product);
                            if(sobj != null && (Boolean)sobj.get('SVMXC__Stockable__c'))
                                IsProductStockable = true;
                        }
                        else if(isValidString(iPro.RelationShip_Name_to_Product))
                        {
                            sobject sobj = xVL.LineObject.getSObject(iPro.RelationShip_Name_to_Product);
                            if(sobj != null && (Boolean)sobj.get('SVMXC__Stockable__c'))
                                IsProductStockable = true;
                        }
                        if(IsProductStockable)
                        {   
                            boolean bSourcelocationStockable = false;
                            if(iPro.Is_Source_Location_From_Header)
                            {
                                if(sobjFL != null)
                                    bSourcelocationStockable = (Boolean)sobjFL.get('SVMXC__Stocking_Location__c');
                            }
                            else
                            {
                                if( IsValidString(iPro.RelationShip_to_Source_Location) && xVL.LineObject.getSObject(iPro.RelationShip_to_Source_Location) != null)
                                    bSourcelocationStockable = (Boolean)(xVL.LineObject.getSObject(iPro.RelationShip_to_Source_Location).get('SVMXC__Stocking_Location__c'));
                            }
                            SObject souPSID;
                            String key = xVL.prodId + '_' + xVL.getFromLocationID() + '_' + iPro.Source_Status;
                            if(bSourcelocationStockable && mapOfProdSoPSID.ContainsKey(key) )
                            {                                
                                if(mapOfProdSoPSID.ContainsKey(key))
                                    souPSID = mapOfProdSoPSID.get(key).sObj;
                                if (souPSID.get('SVMXC__Quantity2__c') == null )                              
                                    souPSID.put('SVMXC__Quantity2__c', 0);
                                try {
                                    souPSID.get('SVMXC__ActualQtyBeforeUpdate__c');
                                }
                                catch(Exception ex ) {
                                    souPSID.put('SVMXC__ActualQtyBeforeUpdate__c',0);
                                }
                                if(souPSID.get('SVMXC__ActualQtyBeforeUpdate__c') != null && Integer.valueof(souPSID.get('SVMXC__ActualQtyBeforeUpdate__c')) == 0)
                                    souPSID.put('SVMXC__ActualQtyBeforeUpdate__c', souPSID.get('SVMXC__Quantity2__c') );
                                Double newQs = 0;
                                Boolean negQs =false;
                                if (iPro.Source_Action == 'Decrease') 
                                {
                                    
                                    if(xVL.isEnableSerialSelection && (((Double)souPSID.get('SVMXC__Quantity2__c') - xVL.trQty) >= 0))
                                    {
                                        if(mapRecFrmSerial.containsKey( key ) )
                                        {
                                            //newQs = mapRecFrmSerial.get(key).size();
                                            newQs = (Double)souPSID.get('SVMXC__Quantity2__c') - xVL.trQty;
                                            //newQs = ( (Double) souPSID.get('SVMXC__Quantity2__c') ) - mapRecFrmSerial.get( key ).size();
                                        }
                                    }
                                    else if((!xVL.isEnableSerialSelection) && (((Double)souPSID.get('SVMXC__Quantity2__c') - xVL.trQty) >= 0))
                                    {
                                        newQs = (Double)souPSID.get('SVMXC__Quantity2__c') - xVL.trQty;                                     
                                    }
                                    
                                    else if(!getGBL002())
                                    {
                                        addexp(TU.getTAG057(), true);
                                        return false;
                                    }
                                    else
                                    {
                                        xVL.isNegativeStoctAtSource = true;
                                        if(mapValidProdRecs.containsKey(pid) && mapMailList.ContainsKey(iPro.Email_For_Negative_Stock_Alert))
                                            mapMailList.get(iPro.Email_For_Negative_Stock_Alert).add(xVL);
                                        sObject o = souPSID.getSObject('SVMXC__Location__r');
                                        if(mapValidProdRecs.containsKey(pid) && iPro.Is_Email_Sent_To_Location_Owner && o != null && o.get('SVMXC__Email__c') != null && ((string)o.get('SVMXC__Email__c')).length() > 0)
                                        {
                                            if(!mapMailList.ContainsKey((string)o.get('SVMXC__Email__c')))
                                                mapMailList.put((string)o.get('SVMXC__Email__c'), new list<INVT_LineRecords>());
                                            mapMailList.get((string)o.get('SVMXC__Email__c')).add(xVL);
                                        } 
                                        negQs = true;
                                        newQs = 0;
                                    }
                                }
                                if (iPro.Source_Action == 'Increase') 
                                    newQs = ((double)souPSID.get('SVMXC__Quantity2__c') + xVL.trQty);
                                if (iPro.Source_Action == 'Set')
                                {
                                    adjusetedQty = (double)souPSID.get('SVMXC__Quantity2__c') - xVL.trQty; 
                                    newQs = xVL.trQty;
                                }
                                if(souPSID != null && iPro.Maintain_Stock_History && STStockHistory != null && IsValidString((string)xVL.fromLocationID))
                                {
                                    SObject histRec = STStockHistory.newSObject();
                                    histRec.put('RecordTypeId', RTypeStockHistory);
                                    histRec.put('SVMXC__Transaction_Type__c',oInvProcess.SVMXC__Name__c);
                                    histRec.put('SVMXC__Inventory_Process__c', oInvProcess.Id);
                                    histRec.put('SVMXC__Transaction_Quantity2__c', xVL.trQty);
                                    histRec.put('SVMXC__Quantity_before_change2__c', souPSID.get('SVMXC__Quantity2__c'));
                                    histRec.put('SVMXC__Quantity_after_change2__c', newQs);
                                    histRec.put('SVMXC__Product__c', pid);
                                    histRec.put('SVMXC__Product_Stock__c', souPSID.Id);
                                    histRec.put('SVMXC__Notified_User__c', notifyUser);
                                    histRec.put('SVMXC__Negative_Stock__c', negQs);
                                    histRec.put('SVMXC__Location__c', ((string)xVL.FromLocationID));
                                    histRec.put('SVMXC__Date_Changed__c', datetime.now());
                                    histRec.put('SVMXC__Changed_By__c', UserInfo.getUserId());
                                    histRec.put('SVMXC__Change_Type__c', iPro.Source_Action);
                                    histRec.put('SVMXC__Status__c', iPro.Source_Status);
                                    
                                    histRec.put(iPro.Stock_History_Header_API_Name, hdrId);
                                    if(iPro.Is_Multiline_Transaction) 
                                        histRec.put(iPro.Stock_History_Line_API_Name, recLid);
                                    listStkHistRecs.add(histRec);
                                }
                                //souPSID.put('SVMXC__ActualQtyBeforeUpdate__c', souPSID.get('SVMXC__Quantity2__c') );
                                souPSID.put('SVMXC__Quantity2__c', newQs);                                
                                mapOfProdSoPSID.put(key,new WraperSObject(souPSID));
                            }
                            boolean bTargetlocationStockable = false;
                            SObject tarPSID;
                            Boolean isDecresedStock = false;
                            key = xVL.prodId + '_' + xVL.getToLocationID() + '_' + iPro.Source_Status;
                            if(iPro.Is_Target_Location_From_Header)
                            {
                                if(sobjTL != null)
                                    bTargetlocationStockable = (Boolean)sobjTL.get('SVMXC__Stocking_Location__c');
                                else
                                    isDecresedStock = true;
                            }
                            else
                            {
                                if( iPro.Number_of_locations != null && iPro.Number_of_locations.ToUpperCase() == 'TWO' && xVL.LineObject.getSObject(iPro.RelationShip_to_Target_Location) != null)
                                    bTargetlocationStockable = (Boolean)(xVL.LineObject.getSObject(iPro.RelationShip_to_Target_Location).get('SVMXC__Stocking_Location__c'));
                                else
                                    isDecresedStock = true;
                            }
                            if(bTargetlocationStockable && !isDecresedStock)
                            {
                                if(mapOfProdTaPSID.ContainsKey(key))
                                    tarPSID = mapOfProdTaPSID.get(key).sObj;
                            }
                            else if(iPro.Number_of_locations != null && iPro.Number_of_locations.ToUpperCase() == 'TWO')
                            {
                                isDecresedStock = true;
                                String sourcekey = xVL.prodId + '_' + xVL.getFromLocationID() + '_' + iPro.Source_Status;
                                if( mapOfProdSourceDecreasedPSID.ContainsKey(sourcekey) )
                                    tarPSID = mapOfProdSourceDecreasedPSID.get(sourcekey).sObj;
                            }
                            if(tarPSID != null)
                            {
                               system.debug('Entered here!!');
                                if (tarPSID.get('SVMXC__Quantity2__c') == null )
                                    tarPSID.put('SVMXC__Quantity2__c', 0);
                                
                                try {
                                    tarPSID.get('SVMXC__ActualQtyBeforeUpdate__c');
                                }
                                catch(Exception ex ) {
                                    //tarPSID.put('SVMXC__ActualQtyBeforeUpdate__c',0);
                                    tarPSID.put('SVMXC__ActualQtyBeforeUpdate__c', tarPSID.get('SVMXC__Quantity2__c') );
                                }
                                /*if(tarPSID.get('SVMXC__ActualQtyBeforeUpdate__c') != null && Integer.valueof(tarPSID.get('SVMXC__ActualQtyBeforeUpdate__c')) == 0)
                                    tarPSID.put('SVMXC__ActualQtyBeforeUpdate__c', tarPSID.get('SVMXC__Quantity2__c') );
                                */
                                Double newQt;
                                Boolean negQt = false;
                                if(iPro.Number_of_locations != null && iPro.Number_of_locations.ToUpperCase() == 'ONE')
                                {                                                                 
                                   if(iPro.Source_Action == 'Set' && adjusetedQty > 0)                                  
                                        newQt = (double)tarPSID.get('SVMXC__Quantity2__c');
                                }
                                else
                                {
                                    if (iPro.Target_Action == 'Decrease') 
                                    {
                                        if(((double)tarPSID.get('SVMXC__Quantity2__c') - xVL.trQty) >= 0)
                                            newQt = ((double)tarPSID.get('SVMXC__Quantity2__c') - xVL.trQty);
                                        else if(!getGBL002())
                                        {
                                            addexp(TU.getTAG057(), true);
                                            return false;
                                        }
                                        else
                                        {
                                            xVL.isNegativeStoctAtSource = false;
                                            if(mapValidProdRecs.containsKey(pid) && mapMailList.ContainsKey(iPro.Email_For_Negative_Stock_Alert))
                                                mapMailList.get(iPro.Email_For_Negative_Stock_Alert).add(xVL);
                                            sObject o = tarPSID.getSObject('SVMXC__Location__r');
                                            if(mapValidProdRecs.containsKey(pid) && iPro.Is_Email_Sent_To_Location_Owner && o != null && o.get('SVMXC__Email__c') != null && ((string)o.get('SVMXC__Email__c')).length() > 0)
                                            {
                                                if(!mapMailList.ContainsKey((string)o.get('SVMXC__Email__c')))
                                                    mapMailList.put((string)o.get('SVMXC__Email__c'), new list<INVT_LineRecords>());
                                                mapMailList.get((string)o.get('SVMXC__Email__c')).add(xVL);
                                            } 
                                            negQt = true;
                                            newQt = 0;
                                        }
                                    }
                                        
                                    if (iPro.Target_Action == 'Increase') 
                                        newQt = ((double)tarPSID.get('SVMXC__Quantity2__c') + xVL.trQty);
                                    if (iPro.Target_Action == 'Set') 
                                        newQt = (xVL.trQty);
                                }
                                if(tarPSID != null && iPro.Maintain_Stock_History && STStockHistory != null && IsValidString((string)xVL.ToLocationId) && IsValidString(iPro.Target_Status))
                                {
                                    SObject histRec = STStockHistory.newSObject();
                                    histRec.put('RecordTypeId', RTypeStockHistory);
                                    histRec.put('SVMXC__Transaction_Type__c',oInvProcess.SVMXC__Name__c);
                                    histRec.put('SVMXC__Inventory_Process__c', oInvProcess.Id);
                                    histRec.put('SVMXC__Transaction_Quantity2__c', xVL.trQty);
                                    histRec.put('SVMXC__Quantity_before_change2__c', tarPSID.get('SVMXC__Quantity2__c'));
                                    if(newQt != null)
                                        histRec.put('SVMXC__Quantity_after_change2__c', newQt);
                                    histRec.put('SVMXC__Product__c', pid);
                                    histRec.put('SVMXC__Product_Stock__c', tarPSID.Id);
                                    histRec.put('SVMXC__Notified_User__c', notifyUser);
                                    histRec.put('SVMXC__Negative_Stock__c', negQt);
                                    histRec.put('SVMXC__Location__c', ((string)xVL.ToLocationID));
                                    histRec.put('SVMXC__Date_Changed__c', datetime.now());
                                    histRec.put('SVMXC__Changed_By__c', UserInfo.getUserId());
                                    histRec.put('SVMXC__Change_Type__c', iPro.Target_Action);
                                    histRec.put('SVMXC__Status__c', iPro.Target_Status);
                                    
                                    histRec.put(iPro.Stock_History_Header_API_Name, hdrId);
                                    if(iPro.Is_Multiline_Transaction)
                                        histRec.put(iPro.Stock_History_Line_API_Name, recLid);
                                    listStkHistRecs.add(histRec);
                                } 
                                
                                //tarPSID.put('SVMXC__ActualQtyBeforeUpdate__c', tarPSID.get('SVMXC__Quantity2__c') );
                                
                                if(newQt != null)
                                    tarPSID.put('SVMXC__Quantity2__c', newQt);
                                if(xVL.ToLocationID != null)
                                    tarPSID.put('SVMXC__Location__c', ((string)xVL.ToLocationID));
                                if(!isDecresedStock)
                                    mapOfProdTaPSID.put(key,new WraperSObject(tarPSID));
                                else {
                                    String sourcekey = xVL.prodId + '_' + xVL.getFromLocationID() + '_' + iPro.Source_Status;
                                    mapOfProdSourceDecreasedPSID.put(sourcekey,new WraperSObject(tarPSID));
                                }                                    
                            }
                        }
                    }
                }
                if(mapOfProdTaPSID != null && iPro.Number_of_locations != null && iPro.Number_of_locations.ToUpperCase() == 'ONE' && iPro.Source_Action == 'Set')
                {
                    for(string str :mapOfProdTaPSID.keySet())
                    {
                        if(mapOfProdTaPSID != null && mapOfProdTaPSID.get(str) != null && mapRecFrmSerial != null && mapRecFrmSerial.get(str) != null)
                        {
                            mapOfProdTaPSID.get(str).sObj.put('SVMXC__Quantity2__c', (double)mapOfProdTaPSID.get(str).sObj.get('SVMXC__Quantity2__c') + mapRecFrmSerial.get(str).size());
                            for(SObject H :listStkHistRecs)
                            {
                                if((string)h.get('SVMXC__Product_Stock__c') == mapOfProdTaPSID.get(str).sObj.Id)
                                {
                                    h.put('SVMXC__Quantity_after_change2__c', (double)mapOfProdTaPSID.get(str).sObj.get('SVMXC__Quantity2__c'));
                                    h.put('SVMXC__Quantity_before_change2__c', (double)mapOfProdTaPSID.get(str).sObj.get('SVMXC__Quantity2__c') - (mapRecFrmSerial.get(str) != null?mapRecFrmSerial.get(str).size():0));
                                    
                                }
                            }
                        }
                    }
                }
                    
                SourceStock.Clear();
                if(mapOfProdSoPSID.size() >0) 
                {
                    for(WraperSObject WO :mapOfProdSoPSID.Values())
                    {
                        SourceStock.add(WO.sObj);
                    }
                }
                if(mapOfProdTaPSID.size() >0)
                {
                    for(WraperSObject WO :mapOfProdTaPSID.Values())
                    {
                        SourceStock.add(WO.sObj);
                    }
                }
                if(mapOfProdSourceDecreasedPSID.size() >0)
                {
                    for(WraperSObject WO :mapOfProdSourceDecreasedPSID.Values())
                    {
                        SourceStock.add(WO.sObj);
                    }
                } 
                if(SourceStock != null && SourceStock.size() >0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(SourceStock, COMM_SecurityUtils.Access.Upsertable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                upsert SourceStock;
                }
                else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
                    

                    //Creating a map of Id and Product Stock record for fixing defect 039676
                    for(SObject obj : SourceStock){
                        mapPSidAndPSRec.put((String)obj.get('Id'),new WraperSObject(obj));
                    }
                    System.debug('mapPSidAndPSRec: '+mapPSidAndPSRec);
                }
                System.debug('MM: listStkHistRecs '+listStkHistRecs);
                if(listStkHistRecs != null && listStkHistRecs.size() >0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listStkHistRecs, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert listStkHistRecs;
                    }
                    else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                } 
                    
        
                list<Messaging.SingleEmailMessage> lstmails = new list<Messaging.SingleEmailMessage>();
                try
                {
                    if(mapMailList.size() > 0)
                    {
                        boolean isEmailInvolved = false;
                        for(string Email :mapMailList.KeySet())
                        {
                            list<INVT_LineRecords> lstLineRecords = mapMailList.get(Email);
                            string strEmailBody ='';
                            strEmailBody = TU.getTAG021();
                            for(INVT_LineRecords LR :lstLineRecords)
                            {
                                isEmailInvolved = true;
                                strEmailBody += '\n\n' + TU.getTAG022() + oInvProcess.SVMXC__Name__c;
                                if(oCommUtils.mapObjectNameField.containsKey(iPro.Parent_Object_Name))
                                    strEmailBody += '\n' + TU.getTAG023() + hdrRec.get(oCommUtils.mapObjectNameField.get(iPro.Parent_Object_Name));
                                if(oCommUtils.mapObjectNameField.containsKey(iPro.Child_Object_Name))
                                    strEmailBody += '\n' + TU.getTAG032() + LR.LineObject.get(oCommUtils.mapObjectNameField.get(iPro.Child_Object_Name));   
                                strEmailBody += '\n' + TU.getTAG024() + LR.prodName;
                                strEmailBody += '\n' + TU.getTAG025() + LR.FromLocationName;
                                        SObject pS;
                                String key = LR.prodId + '_' + LR.getFromLocationID() + '_' + iPro.Source_Status;
                                if(LR.isNegativeStoctAtSource != null && LR.isNegativeStoctAtSource && mapOfProdSoPSID.containsKey(key) && mapOfProdSoPSID.get(key) != null)
                                    pS = mapOfProdSoPSID.get(key).sObj; 
                                key = LR.prodId + '_' + LR.getToLocationID() + '_' + iPro.Source_Status;
                                if(LR.isNegativeStoctAtSource != null && !LR.isNegativeStoctAtSource && mapOfProdTaPSID.containsKey(key) && mapOfProdTaPSID.get(key) != null)
                                    pS = mapOfProdTaPSID.get(key).sObj;
                                if(pS != null)
                                {
                                    strEmailBody += '\n' + TU.getTAG026() + pS.get('SVMXC__Status__c');
                                    strEmailBody += '\n' + TU.getTAG027() + pS.get('SVMXC__Quantity2__c');
                                    strEmailBody += '\n' + TU.getTAG028() + LR.trQty;
                                    strEmailBody += '\n' + TU.getTAG029() + ((double)pS.get('SVMXC__Quantity2__c') - LR.trQty);
                                }
                                strEmailBody += '\n' + TU.getTAG030() + UserInfo.getName();
                                strEmailBody += '\n' + TU.getTAG031() + DateTime.now();
                            }
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if(isValidString(Email))
                            {
                                String[] toAddresses = new String[] {Email};
                                mail.setToAddresses(toAddresses);
                                mail.setSubject(TU.getTAG020());
                                mail.setPlainTextBody(strEmailBody);
                                lstmails.add(mail);
                            }
                        }
                        if(isEmailInvolved && lstmails != null && lstmails.size() > 0)
                            Messaging.sendEmail(lstmails);
                    }
                }
                catch (Exception e){
                    System.debug( LoggingLevel.ERROR, e.getMessage());
                    System.debug( LoggingLevel.ERROR, e.getStackTraceString());
                }
            }
            return true;
        }   
        catch (Exception e)
        { 
            addexp(e.getmessage(), false);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, e.getMessage());
            System.debug( LoggingLevel.ERROR, e.getStackTraceString());
            return false;
        }
    }
    public Boolean validateSerialNumbers()
    {
        try
        {
            boolean IsQtyCorrect = true;
            string ErrorLineName ='';
            boolean IsQtyWrong = true;
            string WrongLineName ='';
            for(INVT_LineRecords xVL : xValidLines)
            {
                String key = xVL.prodId + '_' + xVL.getFromLocationID() + '_' + iPro.Source_Status;                
                if((double)xVL.trQty >= 0)
                {
                    if(mapValidSerializedProdcts.containsKey((String) xVL.prodId) && xVL.trQty > 0)
                    {
                        if(!mapRecToSerial.containsKey(((string)xVL.recLineId)) || xVL.trQty != mapRecToSerial.get(((string)xVL.recLineId)).size())
                        {
                            if(ErrorLineName.length() > 0)
                                ErrorLineName += ', ';
                            ErrorLineName += ((string)xVL.LineName) + ' (' + ((string)xVL.prodName) + ')';
                            IsQtyCorrect = false;
                        }
                    }
                }
                else
                {
                    if(WrongLineName.length() > 0)
                        WrongLineName += ', ';
                    WrongLineName += ((string)xVL.LineName) + ' (' + ((string)xVL.prodName) + ')';
                    IsQtyWrong = false;
                }
            }
            if(!IsQtyCorrect)
                addexp(TU.getTAG042() + ' ' + ErrorLineName, true);
            if(!IsQtyWrong)
                addexp(TU.getTAG055() + ' ' + WrongLineName, true);
            if(!IsQtyCorrect || !IsQtyWrong)
                return false;
            return true;
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return false;
    } 

public void SVMX_populateSerialList() 
    { 
        try
        { 
            
            fromSerial.clear();
            toSerial.clear();
            Double exQtyValue;
            isDuplicateSerialInAdd2 = false;
            String pid =((string)selectedXLine.prodId);
            String key = selectedXLine.prodId + '_' + selectedXLine.getFromLocationID() + '_' + iPro.Source_Status;
            list<INVT_LineRecords> Linerecords= getxLines();
            for(INVT_LineRecords LinerecordsLoop: Linerecords)
            {
                if(LinerecordsLoop.selected)
                    exQtyValue=LinerecordsLoop.trQty;
            }
            String recLid = ((string)selectedXLine.recLineId);
            
            map<string, WraperSObject> toSerialNumbers = new map<string, WraperSObject>();
            toOptions.clear();        
            list<string> lstSNToRemove = new list<string>();
            list<string> lstSNToRemoveext = new list<string>();
           
          
            if(mapRecToSerial != null && mapRecToSerial.get(recLid) != null)
            {
                toSerialNumbers = mapRecToSerial.get(recLid);
            }
            system.debug('toSerialNumbers'+toSerialNumbers);
            system.debug('mapRecToSerial'+mapRecToSerial);
            
                for(string slno : toSerialNumbers.keyset())
                {   
                    if(toSerialNumbers.containsKey(slno) && toSerialNumbers.get(slno) != null && toSerialNumbers.get(slno).SObj.get('Id')== null)
                    {
                            toOptions.add(new SelectOption(slno,slno.substring(0,slno.indexof('^'))));
                    }
                    else 
                    {
                           toOptions.add(new SelectOption(slno,slno.substring(0,slno.indexof('^'))));
                    }
                }
           
            system.debug('toOptions'+toOptions);
            
            SVMX_RemoveSerials(lstSNToRemoveext);
            map<string, WraperSObject> frmSerialNumbers = new map<string, WraperSObject>();
            frmOptions.clear();
            if(mapRecFrmSerial.ContainsKey(key)) 
                frmSerialNumbers = mapRecFrmSerial.get(key);
            if(frmSerialNumbers.size() >0)
            {
                for(string slno : frmSerialNumbers.keyset())
                {
                    frmOptions.add(new SelectOption(slno,slno.substring(0,slno.indexof('^'))));
                }
            }
            
            fillINVTWrapperlst(frmOptions);
            
            if(isDuplicateSerialInAdd2)
                addexp(TU.getTAG045() + ': ' + getDuplicateSerials(), true);
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
    }
    
    public Boolean checkSerialNumber(String stToCheck)
    {
        if(maptoOptions.containsKey(stToCheck))
            return false;
        return true;
    }
    map<string, string> mapSerialNumbers = new map<string, string>();
    //map<string, string> mapSerialNumberswithduplicate = new map<string, string>();
    List<SObject> lstConcreteSerialNumbers;
    List<SObject> selPSIDLst;

    public void buildFromSerialNumber()
    {
        list<String> lstSerial= new list<String>();
        string strLastSerial;       
        string strlastsubstring;
        integer intIndex;
        integer val;
        string tempstr;
        try
        {
            String key = selectedXLine.prodId + '_' + selectedXLine.getFromLocationID() + '_' + iPro.Source_Status;
            string sourceLocId = mFromLocation.get(key);            
            if(showSerialSel == true)
            {
                String pid =((string)selectedXLine.prodId);
                map<string, WraperSObject> frmSerialNumbers= new map<string, WraperSObject>();
                if(mapRecFrmSerial.containsKey(key))
                    frmSerialNumbers = mapRecFrmSerial.get(key);
                if(iPro != null && iPro.Number_of_locations != null && iPro.Number_of_locations != '' && frmSerialNumbers== null || frmSerialNumbers.size() == 0 && STProductStock != null) 
                {
                    SObject selPSID = STProductStock.newSObject();                  
                    if(mapOfProdSoPSID.get(key) != null)
                        selPSID = mapOfProdSoPSID.get(key).SObj;
                    if(selPSID.Id == null)
                    { 
                        String soqlPS;
                        if( setSelectedPSId != null && !setSelectedPSId.isEmpty() ) {
                            soqlPS = 'Select LastModifiedDate, SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Id From SVMXC__Product_Stock__c where Id IN :setSelectedPSId And SVMXC__Status__c =\'' + iPro.Source_Status + '\' And SVMXC__Product__c =\'' + pid + '\' And SVMXC__Location__c =\'' + sourceLocId + '\' order by SVMXC__Quantity2__c DESC';
                        } else {
                            soqlPS = 'Select LastModifiedDate, SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Id From SVMXC__Product_Stock__c where SVMXC__Status__c =\'' + iPro.Source_Status + '\' And SVMXC__Product__c =\'' + pid + '\' And SVMXC__Location__c =\'' + sourceLocId + '\' order by SVMXC__Quantity2__c DESC';
                        }
                        
                        if(isValidString(pid)&& isValidString(sourceLocId)) {
                            
                            System.debug('soqlPS: ' + soqlPS );
                            selPSIDLst = Database.query(soqlPS);
                        }
                        if(selPSIDLst != null && selPSIDLst.size() > 0 && selPSIDLst[0] != null)
                            selPSID = selPSIDLst[0];
                        else
                        {
                            selPSID.put('SVMXC__Quantity2__c', 0);
                            selPSID.put('SVMXC__Product__c', pid);
                            selPSID.put('SVMXC__Location__c', sourceLocId);
                            selPSID.put('SVMXC__Status__c', iPro.Source_Status);
                        }                        
                    }
                    
                    //setSelectedPSId = selPSID.Id;
                    
                    if(isValidString(pid) && isValidString(sourceLocId) && isValidString(iPro.Source_Status))
                        mapOfProdSoPSID.put(key,new WraperSObject(selPSID));
                    if(selPSID.Id != null)
                    {
                        map<string, WraperSObject> serialNumbers = new map<string, WraperSObject>();
                        map<string, WraperSObject> serialNumberswithDuplicate = new map<string, WraperSObject>();
                        if(!mapRecFrmSerial.containsKey(key))
                        {
                            if(isValidString(selPSID.Id) && isValidString(pid)) {
                                if( respectActiveProductSerial ) {
                                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                    lstConcreteSerialNumbers = Database.query('Select SVMXC__Product__c, SVMXC__Product_Stock__c, SVMXC__Active__c, Name, Id From SVMXC__Product_Serial__c where SVMXC__Active__c = true AND SVMXC__Product_Stock__c =\''+ selPSID.Id + '\' And SVMXC__Product__c =\''+ pid + '\'');
                                } else {
                                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                    lstConcreteSerialNumbers = Database.query('Select SVMXC__Product__c, SVMXC__Product_Stock__c, SVMXC__Active__c, Name, Id From SVMXC__Product_Serial__c where SVMXC__Product_Stock__c =\''+ selPSID.Id + '\' And SVMXC__Product__c =\''+ pid + '\'');    
                                }
                            }
                                
                            if(lstConcreteSerialNumbers != null && lstConcreteSerialNumbers.size() >0)
                            {
                               
                                for(SObject SN :lstConcreteSerialNumbers)
                                {
                                    serialNumbers.put((String)SN.get('Name'), new WraperSObject(SN));
                                    mapSerialNumbers.put((String)SN.get('Name'), (String)SN.get('SVMXC__Product_Stock__c'));
                                    list<String> tempset= new list<String>();
                                    string slno=(String)SN.get('Name');
                                   
                                    list<string> lstsuff= new list<string>();
                                    SObject tempSObject;
                                    string namesl;
                                    if(mapSerialSuffix != null && mapSerialSuffix.containsKey((String)SN.get('Name')))
                                    {
                                        
                                        lstsuff=mapSerialSuffix.get((String)SN.get('Name'));
                                        lstsuff.add(String.valueOf(lstsuff.size()+1));
                                        mapSerialSuffix.put((String)SN.get('Name'),lstsuff);
                                      
                                        namesl=(String)SN.get('Name')+'^'+String.valueOf(lstsuff.size());
                                      
                                        serialNumberswithDuplicate.put(namesl, new WraperSObject(sn));
                                        //mapSerialNumberswithduplicate.put(namesl, (String)SN.get('SVMXC__Product_Stock__c'));
                                    }
                                    else
                                    {
                                        lstsuff.add('1');
                                        mapSerialSuffix.put((String)SN.get('Name'),lstsuff);
                                      
                                        namesl=(String)SN.get('Name')+'^'+'1';
                                    
                                        serialNumberswithDuplicate.put(namesl,new WraperSObject(sn));
                                        //mapSerialNumberswithduplicate.put(namesl, (String)SN.get('SVMXC__Product_Stock__c'));
                                    }
                                }
                            } 
                            System.Debug('mapRecFrmSerial'+mapRecFrmSerial);                            
                            mapRecFrmSerial.put(key,serialNumberswithDuplicate);
                        }
                    }
                    else {
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        lstConcreteSerialNumbers = [Select Id From SVMXC__Product_Serial__c where SVMXC__Active__c = true LIMIT 0];
                    }
                        
                }
                
                System.Debug('mapSerialSuffix'+mapSerialSuffix);
                System.Debug('mapRecFrmSerial'+mapRecFrmSerial);
                  system.debug('mapSerialNumbers'+mapSerialNumbers);
                SVMX_populateSerialList();
            }
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
    }
    public void drawSerialSelectionBlock()
    {
        if(xValidLines != null && xValidLines.size() > 0)
        {
            for(INVT_LineRecords xVL : xValidLines)
            {
                xVL.selected = false;
            }
            selectedXLine = xValidLines[indexOfSelectedXLine];
            xValidLines[indexOfSelectedXLine].selected = true;
            String key = selectedXLine.prodId + '_' + selectedXLine.getFromLocationID() + '_' + iPro.Source_Status;            
            if(mapValidSerializedProdcts.containskey( (String) selectedXLine.prodId ) )
            {
                disableSerialSel= false;
                showSerialSel = true;
                buildFromSerialNumber();
            }
            else 
            {
                disableSerialSel = true;
                showSerialSel = false;
            }
        }
    }
    public void buildxValidLines()
    {
        system.debug(LoggingLevel.Warn, 'Size of xLines: ' + xLines.size() + '; Lines: ' + xLines);
        set<String> setProductId = new set<String>();
        set<String> setSourceLocationId = new set<String>();
        for(INVT_LineRecords xL : xLines)
        {
            if(mapValidProdRecs.containsKey((String)xL.prodId))
            xValidLines.add(xL);
            //Get Product Id and Source Location Id to get Source Product Stock
            if(xL.prodId != null){
                setProductId.add(String.valueOf(xL.prodId));
            } 
            if(xL.FromLocationId != null){
                setSourceLocationId.add(String.valueof(xL.FromLocationId));
            }
        }
        // get the Source Product Stock Ids 
        setSelectedPSId = getSourceProductStockIdsForAllLines(iPro.Source_Status,setProductId,setSourceLocationId);
        system.debug(LoggingLevel.Warn, 'Size of xValidLines: ' + xValidLines.size() + '; Lines: ' + xValidLines);
        system.debug(LoggingLevel.Warn, 'buildFromSerialNumber: ' + setSelectedPSId);
    }
    public void buildValidProdRecs()
    {
        for(Product2 pR: prodRecs)
        {
            mapValidProdRecs.put(pR.ID,pR);
        }
    }
    public void buildValidProdSerializedRecs()
    {
        for(Product2 pR: prodRecs)
        {
            if(!isInventoryEnabled || ( pR.get('SVMXC__Enable_Serialized_Tracking__c') != null && (Boolean)pR.get('SVMXC__Enable_Serialized_Tracking__c') && pR.get('SVMXC__Stockable__c') != null && (Boolean)pR.get('SVMXC__Stockable__c')))
                mapValidSerializedProdcts.put(pR.Id, pR);
        }
    }
    public String SVMX_getCommaSepratedStr(List<String> strAr) 
    {
        String retStr = '';
        if(strAr != null)
        {
            for (String str : strAr) 
            {
                if (retStr.length()>0)
                    retStr += ',';
                retStr += '\'' + str + '\'';
            }
        }
        return retStr;
    }
    public String SVMX_getCommaSepratedStr(set<String> strAr) 
    {
        list<string> lststr = new list<string>();
        if(strAr != null)
            lststr.addall(strAr);
        return SVMX_getCommaSepratedStr(lststr);
    }

    public PageReference SVMX_DoCancel() 
    {
        try
        {
            if(iPro != null)            
                soqlHeader = 'SELECT Id FROM ' + iPro.Parent_Object_Name + ' where Id=:hdrId ';
            lstHdr = Database.query(soqlHeader);
            if(lstHdr != null && lstHdr.size() > 0)
            {   
                System.debug(LoggingLevel.INFO, 'lstHdr Record Id : ' + lstHdr);
                String hdrRecId = lstHdr[0].Id;
                PageReference pg = new PageReference('/' + hdrRecId);
                pg.setRedirect(true);
                return pg;
            }
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return null;
    } 
    public PageReference SVMX_moveToNextXLine()
    {
        try
        {
            if(indexOfSelectedXLine < totalValidProdCount -1)
                indexOfSelectedXLine++;
            drawSerialSelectionBlock();
            enteredSn = '';
            quickAddCount = 0;
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return null;
    }
    public PageReference SVMX_moveToPrevXLine()
    {
        try
        {
            if(indexOfSelectedXLine > 0)
                indexOfSelectedXLine--;
            drawSerialSelectionBlock();
            enteredSn = '';
            quickAddCount = 0;
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return null;
    }

    public PageReference SVMX_moveSerialNumberToTargetList()
    {
        try
        {
            DuplicateSerialWarned = false;
            serSelectionMess = false;
            if(toOptions.size() == 1 && toOptions[0].getValue().toUpperCase() == '')
            {
                toOptions.clear();
               // maptoOptions.clear();
            }
            if(snString != null && snString.length() > 0)
                addSerialFrmTextAreaToTarget();
                
            System.Debug(LoggingLevel.WARN, 'Wrapper List: ' + INVTWraplst);
            if(INVTWraplst != NULL && INVTWraplst.size() > 0)
            {
                fromSerial.clear();
                for(INVTWrapper objWrap : INVTWraplst)
                {
                    if(objWrap.FromLocationlst != NULL && objWrap.FromLocationlst.size() > 0)
                        fromSerial.addAll(objWrap.FromLocationlst);
                    objWrap.FromLocationSOlst.clear(); 
                }
            }
            
            if(fromSerial != null && fromSerial.size() > 0)
                SVMX_moveSerialFrmSourceToTarget();
            SVMX_populateSerialList();
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return null;
    }
    public void SVMX_AddSerialToProductMap(list<string> lst)
    {
        for(string str :lst)
        {   SVMX_AddSerialToProductMap(str);}
    }
    public boolean SVMX_AddSerialToProductMap(string str)
    {
        string ProId = (string)selectedXLine.prodId;
        String key = selectedXLine.prodId + '_' + selectedXLine.getFromLocationID() + '_' + iPro.Source_Status;
        if(!mapProductSerial.containsKey(key))
            mapProductSerial.put(key, new set<string>());
        if(!mapProductSerial.get(key).Contains(str))
            mapProductSerial.get(key).add(str);
        else
            return false;
        return true;
    }
    public void SVMX_removeSerialFromProductMap(list<string> lst)
    {
        for(string str :lst)
        {   SVMX_removeSerialFromProductMap(str);}
    }
    public void SVMX_removeSerialFromProductMap(string str)
    {
        string ProId = (string)selectedXLine.prodId;
        String key = selectedXLine.prodId + '_' + selectedXLine.getFromLocationID() + '_' + iPro.Source_Status;
        if(mapProductSerial.containsKey(key ))
        {
            if(mapProductSerial.get(key ).contains(str))
                mapProductSerial.get(key ).remove(str);
        }
    }
    public void SVMX_moveSerialFrmSourceToTarget()
    {
        SVMC_AddSerials(fromSerial);
    }
    public PageReference SVMX_removeSerialFrmTarget()
    {
        try
        {
            DuplicateSerialWarned = false;
            serSelectionMess = false;
            SVMX_RemoveSerials(toSerial);
            SVMX_removeSerialFromProductMap(toSerial);
            SVMX_populateSerialList();
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return null;
    }


    public PageReference SVMX_addSerialNumberToTargetList()
    {
        try
        {
            serSelectionMess = false;
            DuplicateSerialWarned = false;
            if(enteredSn != null && enteredSn.length() > 0)
            {
                isDuplicateSerialInAdd = false;
                setDuplicateSerials.Clear();
                SVMC_AddSerials(enteredSn);
               
                if(isDuplicateSerialInAdd && iPro != null && iPro.Enforce_Uniqueness_In_Serial_Selection != null && iPro.Enforce_Uniqueness_In_Serial_Selection.ToUpperCase()== 'STRICT')
                    addexp(TU.getTAG040() + ': ' + getDuplicateSerials(), true);
            
                SVMX_populateSerialList();
                enteredSn = '';
                quickAddCount = 0;
            }
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return null;
    }


    
    public void SVMC_AddSerials(list<string> lstSerialNo)
    {
        isDuplicateSerialInAdd = false;
        setDuplicateSerials.Clear();
        if(lstSerialNo != null && lstSerialNo.size() > 0)
        {
            for(String SerialNo : lstSerialNo)
            {   
                SVMC_AddSerials(SerialNo);
            }
            if(iPro != null && iPro.Enforce_Uniqueness_In_Serial_Selection != null && iPro.Enforce_Uniqueness_In_Serial_Selection.ToUpperCase()== 'STRICT')
            {
                if(isDuplicateSerialInAdd)
                    addexp(TU.getTAG040() + ': ' + getDuplicateSerials(), true);
            }
            if(iPro != null && iPro.Enforce_Uniqueness_In_Serial_Selection != null && iPro.Enforce_Uniqueness_In_Serial_Selection.ToUpperCase()== 'STRICT')
            {
            if(isDuplicateSerialInAdd2)
                addexp(TU.getTAG045() + ': ' + getDuplicateSerials(), true);
            }
        }
    }
    boolean isDuplicateSerialInAdd = false;
    boolean isDuplicateSerialInAdd2 = false;
    public string getDuplicateSerials()
    {
        string S = '';
        for(string str :setDuplicateSerials)
        {
            if(IsValidString(S))
                S += ', ' +str;
            else
                S = str;
        }
        return S;
    }
    set<string> setDuplicateSerials = new set<string>(); 

    
    public void SVMC_AddSerials(string SerialNo)
    {
       
        map<string,list<string>> maptempslno=new map<string,list<string>>();
      
        system.debug('STProductSerial'+STProductSerial);
        SerialNo=SerialNo.trim();
        if(SerialNo != null && SerialNo.length() > 0 && STProductSerial != null)
        {
            System.debug('SerialNoSVMC_AddSerials 1'+SerialNo);
            serSelectionMess = false;
            isDuplicateSerialInAdd2 = false;          
            system.debug('serSelectionMess'+serSelectionMess);
            map<string, WraperSObject> frmSNListext = new map<string, WraperSObject>();
                map<string, WraperSObject> toSNListext =new map<string, WraperSObject>();
            String key = selectedXLine.prodId + '_' + selectedXLine.getFromLocationID() + '_' + iPro.Source_Status;
            
                if(mapRecFrmSerial != null && mapRecFrmSerial.containsKey(key) )
                    frmSNListext = mapRecFrmSerial.get(key);
                if(mapRecToSerial != null && mapRecToSerial.containsKey(((string)selectedXLine.recLineId)))
                    toSNListext = mapRecToSerial.get(((string)selectedXLine.recLineId));           
        
                            
                list<string> tmpst=new list<string>();
                         setOfStringToCheck.clear();     
                SObject newToSN = STProductSerial.newSObject();
                setOfStringToCheck.add(SerialNo);
               if(mapslnosuffTarget != null && mapslnosuffTarget.containskey(SerialNo) )
                {
                    tmpst=mapslnosuffTarget.get(SerialNo);
                    tmpst.add(string.valueof(tmpst.size()+1));
                    mapslnosuffTarget.put(SerialNo,tmpst);
                    if(!SerialNo.contains('^'))
                    SerialNo=SerialNo+'^'+(tmpst.size());                    

                    
                }
                else
                {
                    if(!SerialNo.contains('^'))
                    {
                    tmpst.add(string.valueof(tmpst.size()+1));
                    mapslnosuffTarget.put(SerialNo,tmpst);
                    if(!SerialNo.contains('^'))
                    SerialNo=SerialNo+'^'+(tmpst.size());   
                    
                    }                       
                }
                SVMX_AddSerialToProductMap(SerialNo);
                  newToSN.put('Name',SerialNo);
                if(frmSNListext != null && frmSNListext.containsKey(SerialNo) && frmSNListext.get(SerialNo) != null)
                {
                    newToSN = frmSNListext.get(SerialNo).sObj;
                    frmSNListext.remove(SerialNo);
                    system.debug('SerialNofrmSNList'+SerialNo);
                    
                }
                if(toSNListext != null && (!toSNListext.containskey(SerialNo)))
                 toSNListext.put(SerialNo, new WraperSObject(newToSN));               
                 system.debug('toSNListext'+toSNListext);
                 set<string> setSerialno = new set<string>();
               for(String serialnum:toSNListext.keyset())
                {
                    string tempname;                
                    if(serialnum.Contains('^'))
                    {
                    tempname=serialnum.substring(0,serialnum.indexOf('^'));               
                    }
                    
                     system.debug('tempname'+tempname);
                    if(setSerialno.contains(tempname))
                    {
                    system.debug('Requiredblock');
                     isDuplicateSerialInAdd = true;
                     serSelectionMess = true;
                     setDuplicateSerials.add(tempname);
                    }
                     else
                    setSerialno.add(tempname);
                }
            if( mapRecFrmSerial.containsKey(key) ) {
                mapRecFrmSerial.get(key).putAll(frmSNListext);
            } else {
                mapRecFrmSerial.put(key, frmSNListext);
            }
            
            mapRecToSerial.put(((string)selectedXLine.recLineId), toSNListext);
            system.debug('mapRecToSerial'+mapRecToSerial);
            
        }
    }      
    public void SVMX_RemoveSerials(list<string> lstSerialNo)
    {
        if(lstSerialNo != null && lstSerialNo.size() > 0)
        {
            for(String SerialNo : lstSerialNo)
            {   SVMX_RemoveSerials(SerialNo);} 
        }
    }

    public void SVMX_RemoveSerials(string SerialNo)
    {
       system.debug('SVMX_RemoveSerialsSerialNo'+SerialNo);
            if(SerialNo != null && SerialNo.length() > 0)
            {
                map<string, WraperSObject> frmSNList = new map<string, WraperSObject>();
                map<string, WraperSObject> toSNList =new map<string, WraperSObject>();
                String key = selectedXLine.prodId + '_' + selectedXLine.getFromLocationID() + '_' + iPro.Source_Status;
                if(mapRecFrmSerial != null && mapRecFrmSerial.containsKey(key))
                    frmSNList =mapRecFrmSerial.get(key);
                    system.debug('mapRecFrmSerial'+mapRecFrmSerial);
                    system.debug('frmSNList'+frmSNList);
                if(mapRecToSerial != null && mapRecToSerial.containsKey(((string)selectedXLine.recLineId)))
                    toSNList =mapRecToSerial.get(((string)selectedXLine.recLineId));
                    system.debug('mapRecToSerial'+mapRecToSerial);
                    system.debug('toSNList'+toSNList);
                if(toSNList != null && toSNList.containsKey(SerialNo))
                {
                    if(toSNList.containskey(SerialNo) && toSNList.get(SerialNo) != null && toSNList.get(SerialNo).sObj != null && toSNList.get(SerialNo).sObj.Id != null)
                        frmSNList.put(SerialNo, toSNList.get(SerialNo));
                    toSNList.remove(SerialNo);
                }
                if(setOfStringToCheck.contains(SerialNo))
                    setOfStringToCheck.remove(SerialNo);
                SVMX_removeSerialFromProductMap(SerialNo);
                if(mapTargetProductSerial.containsKey(((string)selectedXLine.prodId)))
                {
                    if(mapTargetProductSerial.get(((string)selectedXLine.prodId)).contains(SerialNo))
                        mapTargetProductSerial.get(((string)selectedXLine.prodId)).remove(SerialNo);
                }
                if(mapRecFrmSerial.containsKey(key) ) {
                    mapRecFrmSerial.get(key).putAll(frmSNList);
                } else {
                    mapRecFrmSerial.put(key, frmSNList);
                }
                
                mapRecToSerial.put(((string)selectedXLine.recLineId), toSNList);
            }
      
        system.debug('mapRecToSerialfinal'+mapRecToSerial);
        system.debug('mapRecFrmSerialfinal'+mapRecFrmSerial);
    }
    
    public void addSerialFrmTextAreaToTarget()
    {
        try
        {
            if(snString.length() > 0)
            { 
                SVMC_AddSerials(snString.split('\n',-2));
                snString = '';
            }
        }catch (Exception e){   addexp(e.getmessage(), true);btnisdisabled = false;}
    }
    set<String> setOfStringToCheck = new set<String>() ;
    map<string, set<String>> mapProductSerial =new map<string, set<String>>();

    public PageReference SVMX_quickAddSerialNumberToTargetList()
    {
        try
        {
            DuplicateSerialWarned = false;
            serSelectionMess = false;
            Integer iSerialIndex = 1 ;
            String strSerialSufix ='';
            Double exQtyValue;
            String Txt='';
            list<INVT_LineRecords> Linerecords= getxLines();
            for(INVT_LineRecords LinerecordsLoop: Linerecords)
            {
                if(LinerecordsLoop.selected)
                {
                    exQtyValue=LinerecordsLoop.trQty;
                }
            }
            Integer iNewCount = quickAddCount;
         
            if (mapRecToSerial.containsKey(((string)selectedXLine.recLineId)))
                iNewCount += mapRecToSerial.get(((string)selectedXLine.recLineId)).size();
            if(exQtyValue >= iNewCount )
            {
                if(toOptions.size() == 1 && toOptions[0].getValue() == '')
                {
                    toOptions.clear();
                }
                if((quickAddCount + toOptions.size()) > 1000)
                {
                    serSelectionMess =true ;
                    addexp(TU.getTAG056(), true);
                    return null;
                }
                enteredSn = enteredSn.replace('-','-~');
                Integer ZeroIndex = 0;
                for( integer i=0; i<enteredSn.length(); i++)
                {
                    try
                    {
                        iSerialIndex = integer.valueOf(enteredSn.substring(enteredSn.length()-i-1));
                        Txt =''+enteredSn.substring(enteredSn.length()-i-1);
                                ZeroIndex = Txt.length();
                    }
                    catch(exception ex)
                    {
                        strSerialSufix = enteredSn.substring(0,enteredSn.length()-i);
                        iSerialIndex= math.abs(iSerialIndex);
                        System.debug( LoggingLevel.ERROR, ex.getMessage());
                        System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
                        break;
                    }
                }
                enteredSn = enteredSn.replace('-~','-');
                List<String> serialListFromQuickAdd=new List<String>();
                for( integer i=0; i < quickAddCount; i++)
                {
                    String tempsufix='';
                    for(Integer j=0; j < (ZeroIndex - String.ValueOf(iSerialIndex + i).length());j++)
                    {
                        tempsufix=tempsufix+'0';
                    }
                    serialListFromQuickAdd.add(strSerialSufix.replace('-~','-')+ tempsufix + String.ValueOf(iSerialIndex + i));
                }
                if(serialListFromQuickAdd.size()>0)
                    SVMC_AddSerials(serialListFromQuickAdd);
                SVMX_populateSerialList();
                enteredSn = '';
                quickAddCount = 0;
            }
            else 
            {
                serSelectionMess =true ;
                addexp(TU.getTAG044(), true);
            }
        }
        catch(exception ex)
        {
            addexp(ex.getMessage(), true);
            btnisdisabled = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return null;
    }

    public PageReference SVMX_DoSubmit()
    {
        //Replaced XRecs to xRecsVar- BAC-4362
        Savepoint sp2;
        try
        {
            system.debug('DuplicateSerialWarned: ' + DuplicateSerialWarned);
            isError = false;
            isSerialError = false;
            isSerialWarning = false;

            setDuplicateSerials.Clear();
            mapProdSerInDB.clear();
            setOfStringToCheck.clear();

            sp2 = Database.setSavepoint();
            
            // What are we doing here?
            if(isInventoryEnabled && iPro.Number_of_locations != null && iPro.Number_of_locations != '' && STProductStock != null)
                CheckStock();
            
            Boolean serialSave = false;
            Boolean updateXLines = false;
            Boolean updateHeader = false;
            Boolean updateRelated = false;
            string excessLines = '';
            string partialLines = '';
            
            if(selPSIDLst != null && selPSIDLst.size() > 0)
                selPSIDLst.clear();
            map<string, WraperSObject> mapSlNoSObjStkSer = new map<string, WraperSObject>();

            // Check for lines having excess quantity / partial quantity, if these are not allowed as per the inventory process definition
            for(INVT_LineRecords xVL : xValidLines)
            {
                if(!iPro.Allow_Excess_Quantity && (xVL.exQty < xVL.trQty))
                {   
                    if(excessLines.length() > 0)
                        excessLines += ', ';
                    excessLines += ((string)xVL.LineName) + ' (' + ((string)xVL.prodName) + ')';
                    addexp(TU.getTAG048() + ' ' + excessLines, true);
                }
                if(!iPro.Allow_Partial_Quantity && (xVL.exQty > xVL.trQty))
                {
                    if(partialLines.length() > 0)
                        partialLines += ', ';
                    partialLines += ((string)xVL.LineName) + ' (' + ((string)xVL.prodName) + ')';
                    addexp(TU.getTAG049() + ' ' + partialLines, true);
                }
            }
                
            if(isInventoryEnabled)
            {
                if(iPro != null && iPro.Enforce_Uniqueness_In_Serial_Selection != null && (iPro.Enforce_Uniqueness_In_Serial_Selection == 'STRICT' || iPro.Enforce_Uniqueness_In_Serial_Selection == 'SOFT' ))
                {
                    // Do the duplicate check for the serial numbers entered in the screen only, not against db values
                    if(iPro.Source_Action != null && iPro.Source_Action == 'SET')
                    {
                        system.debug(LoggingLevel.Warn, 'Doing duplicate serial check for Inventory transactions with SET action for Stock Update');
                        system.debug(LoggingLevel.Warn, 'Lines size: ' + xValidLines.size() + '; Lines: ' + xValidLines);
                        for(INVT_LineRecords xVL : xValidLines)
                        {
                            String strProdId = (string)xVL.recLineId;
                            if(mapRecToSerial != null)
                            {
                                mapSlNoSObjStkSer = mapRecToSerial.get(strProdId);
                                system.debug(LoggingLevel.Warn, 'mapRecToSerial: ' + mapRecToSerial);
                            }
                            set<string> setSerialno = new set<string>();
                            if(mapSlNoSObjStkSer != null && mapSlNoSObjStkSer.size() > 0)
                            {
                                for(String serialnum : mapSlNoSObjStkSer.keyset())
                                {
                                    string tempname;                
                                    if(serialnum.Contains('^'))
                                        tempname = serialnum.substring(0, serialnum.indexOf('^'));               
                                    
                                    if(setSerialno.contains(tempname))
                                    {
                                        if(iPro.Enforce_Uniqueness_In_Serial_Selection.ToUpperCase() == 'STRICT' )
                                        {  
                                            serialError();  
                                            setDuplicateSerials.add(tempname);          
                                        }
                                        else if(iPro.Enforce_Uniqueness_In_Serial_Selection.ToUpperCase() == 'SOFT' && !DuplicateSerialWarned)
                                        {       
                                            serialWarning();
                                            setDuplicateSerials.add(tempname);
                                        }
                                    }
                                    else
                                        setSerialno.add(tempname);
                                }
                            }    
                        }
                    }
                    // Do duplicate check for serial numbers against values entered in screen and values existing in db
                    else
                    {
                        list<string> lstProId = new list<string>();
                        map<string, set<string>> mapProdUniqSerNoSet = new map<string, set<string>>();
                        // Do duplicate check for each product against values entered in screen for that product
                        for(INVT_LineRecords xVL : xValidLines)
                        {
                            String strLineId =(string)xVL.recLineId;
                            String strProdId =(string)xVL.prodId;
                            String key = xVL.prodId + '_' + xVL.getFromLocationID() + '_' + iPro.Source_Status;
                            if(mapRecToSerial != null)
                                mapSlNoSObjStkSer = mapRecToSerial.get(strLineId);
                            if(mapSlNoSObjStkSer != null)
                            {
                                mapProdUniqSerNoSet.put(key, new set<string>());
                                for(string strSerNo : mapSlNoSObjStkSer.keyset())
                                {
                                    WraperSObject wrpStkSer = mapSlNoSObjStkSer.get(strSerNo);
                                    string strSlNo;
                                    if(wrpStkSer != null)
                                        strSlNo = (String)wrpStkSer.SObj.get('Name');
                                    if(strSlNo.contains('^'))
                                        strSlNo = strSlNo.substring(0,strSlNo.indexOf('^'));
                                    if(mapProdUniqSerNoSet.containskey(key)  && mapProdUniqSerNoSet.get(key).contains(strSlNo))
                                    {
                                        setDuplicateSerials.add(strSlNo);
                                        if(iPro.Enforce_Uniqueness_In_Serial_Selection == 'STRICT' )
                                            serialError();
                                        else if(iPro.Enforce_Uniqueness_In_Serial_Selection.ToUpperCase() == 'SOFT' && !DuplicateSerialWarned )
                                            serialWarning();
                                    }
                                    else
                                    {
                                        mapProdUniqSerNoSet.get(key).add(strSlNo);                            
                                        setOfStringToCheck.add(strSlNo);
                                    }
                                }
                            }
                            lstProId.add((string)xVL.prodId);
                        }
                            
                        // Retrieve stocked serial records from db for the products and serials of all the lines
                        list<SObject> lstStockSerialInDB;
                        if(setOfStringToCheck.size() >0 && mapProductSerial.keyset().size() > 0 && !DuplicateSerialWarned)
                        {
                            string strSerNoEntered = SVMX_getCommaSepratedStr(setOfStringToCheck);
                            string strProductSerial = SVMX_getCommaSepratedStr(lstProId);
                            if( respectActiveProductSerial ) {
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                lstStockSerialInDB = database.query('Select SVMXC__Product__c, Name, SVMXC__Product_Stock__c, Id From SVMXC__Product_Serial__c where SVMXC__Active__c = true AND Name IN (' + strSerNoEntered + ') AND SVMXC__Product__c IN (' + strProductSerial + ') AND SVMXC__Product_Stock__r.SVMXC__Status__c IN (' + getGBL004() +')');
                            } else {
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                lstStockSerialInDB = database.query('Select SVMXC__Product__c, Name, SVMXC__Product_Stock__c, Id From SVMXC__Product_Serial__c where Name IN (' + strSerNoEntered + ') AND SVMXC__Product__c IN (' + strProductSerial + ') AND SVMXC__Product_Stock__r.SVMXC__Status__c IN (' + getGBL004() +')');    
                            }
                            
                        }
                        system.debug('lstStockSerialInDB - source and target: ' + lstStockSerialInDB);
                        system.debug('mapSlNoProdStkId - source: ' + mapSerialNumbers);
                        
                        // Do duplicate check for each product against values retrieved from db for that product
                        if(lstStockSerialInDB != null && lstStockSerialInDB.size() > 0)
                        {
                            for(SObject stkSer: lstStockSerialInDB)
                            {
                                String key = (String) stkSer.get('SVMXC__Product__c');
                                if(!mapProdSerInDB.containsKey( key ) )
                                {
                                    map<string, list<WraperSObject>> mapSlNoWrapObj = new map<string, list<WraperSObject>>();
                                    mapProdSerInDB.put(key, mapSlNoWrapObj);       
                                }
                                if(!(mapProdSerInDB.get(key).containskey((String)stkSer.get('Name'))))
                                    mapProdSerInDB.get(key).put((String)stkSer.get('Name'), new list<WraperSObject>{new WraperSObject(stkSer)});
                                else
                                    mapProdSerInDB.get(key).get((String)stkSer.get('Name')).add(new WraperSObject(stkSer));
                            }
                            system.debug('mapProdSerInDB: ' + mapProdSerInDB);
                            
                            for(string key : mapProductSerial.keyset()) // For each product 
                            {
                                String prodId = key.split('_')[0];
                                if(mapProdSerInDB.containsKey(prodId)) // If Stocked Serials are in DB for this product
                                {
                                    // Get the Stocked Serials retrieved from DB for this product
                                    map<string, list<WraperSObject>> mapSlNoWrapList = mapProdSerInDB.get(prodId);
                                    for(string strSerial : mapProdUniqSerNoSet.get(key)) // For each unique serial no. entered
                                    {
                                        if(mapSlNoWrapList.containsKey(strSerial)) // If the serial no. is in DB
                                        {       
                                            if(mapSerialNumbers.containsKey(strSerial)) // If the serial no. is in source
                                            {
                                                for(WraperSObject wrpStkSer : mapSlNoWrapList.get(strSerial))
                                                {
                                                    if(wrpStkSer != null && mapSerialNumbers.get(strSerial) != wrpStkSer.sObj.get('SVMXC__Product_Stock__c')) // Consider as duplicate only if serial no. in DB is not that of the source
                                                    {
                                                        setDuplicateSerials.add(strSerial);
                                                        if(iPro.Enforce_Uniqueness_In_Serial_Selection == 'STRICT' )
                                                            serialError();
                                                        else if(iPro.Enforce_Uniqueness_In_Serial_Selection == 'SOFT' && !DuplicateSerialWarned )
                                                            serialWarning();
                                                    }
                                                }
                                            }
                                            else // If serial no. is not in source, but in db, consider as duplicate
                                            {
                                                setDuplicateSerials.add(strSerial);
                                                if(iPro.Enforce_Uniqueness_In_Serial_Selection == 'STRICT' )
                                                    serialError();
                                                else if(iPro.Enforce_Uniqueness_In_Serial_Selection == 'SOFT' && !DuplicateSerialWarned )
                                                    serialWarning();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
               
                if(isSerialError)
                {
                    addexp(TU.getTAG045() + ': ' + getDuplicateSerials(), true);
                    system.debug('isSerialError is true');
                    return null;
                }
                else if(isSerialWarning)
                {
                    DuplicateSerialWarned = true;
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING, TU.getTAG052()+ ': ' + getDuplicateSerials()));
                    return null;
                }

                Boolean snChk = true;
                Boolean stkUpd = false;
                if(iPro != null && iPro.Enable_Serial_Selection)
                    snChk = validateSerialNumbers();
                if(iPro != null && snChk) 
                    stkUpd = SVMX_doStockUpdate();
                if(!stkUpd)
                {
                    if(!isErrorAdded)
                        addexp(TU.getTAG043(), true);
                    database.rollBack(sp2);
                    return null;
                }
                if((iPro != null && iPro.Enable_Serial_Selection) && stkUpd) 
                    serialSave = SVMX_doSerialSave();
            }
            lstHdrCloserActions = new list<SVMXC__ServiceMax_Config_Data__c>();
            lstLineCloserActions = new list<SVMXC__ServiceMax_Config_Data__c>();
            lstRelatedCloserActions = new list<SVMXC__ServiceMax_Config_Data__c>();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstCloserActions = database.query( 'select id, SVMXC__Display_Type__c, SVMXC__Operator__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Object_Name__c, SVMXC__Expression_Type__c, SVMXC__Field_Name__c, SVMXC__Operand__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Expressions\' AND SVMXC__Inventory_Process__c = \'' + oInvProcess.Id +'\'');
            for(SVMXC__ServiceMax_Config_Data__c cD : lstCloserActions)
            {
                if(cD.SVMXC__Expression_Type__c == 'INV_Header_Closure_Action')
                    lstHdrCloserActions.add(cD);
                else if(cD.SVMXC__Expression_Type__c == 'INV_Line_Closure_Action')
                    lstLineCloserActions.add(cD);
                else if(cD.SVMXC__Expression_Type__c == 'INV_Related_Update_Action')
                    lstRelatedCloserActions.add(cD);
            }
            if(!isError)
            {
                if((iPro != null && (!iPro.Enable_Serial_Selection)) || ((iPro != null && iPro.Enable_Serial_Selection) && serialSave)) 
                    updateXLines = SVMX_doUpdateXLines();
                if(updateXLines)
                    updateRelated = SVMX_doUpdateRelatedLines();
                if(!updateRelated)
                {
                    if(!isError)
                        addexp(TU.getTAG043(), true);
                    database.rollBack(sp2);
                    return null;
                }
                PageReference pg;
                if(isValidString(LineId))
                    pg = new PageReference('/' + xRecsVar[0].Id);
                else
                    pg = new PageReference('/' + hdrRec.Id);
                pg.setRedirect(true);
                btnisdisabled = true;
                return pg;
            }
            else
            {
                database.rollBack(sp2);
            }
        }
        catch(exception ex)
        {
            addexp(TU.getTAG043(), true);
            btnisdisabled = false;
            database.rollBack(sp2);
            System.debug( LoggingLevel.ERROR, ex.getMessage());
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return null;
    }
    
    Boolean isError = false;
    private void addexp(string str, Boolean bIsSubmitEnabled)
    {
        isErrorAdded = true;
        IsSubmitEnabled = bIsSubmitEnabled;
        isError = true;
        if(str != null)
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, str));
        else
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ''));
    }
    list<string> lstError = new list<string>();
    public string getRcordType(string strObjectName, String strRecordTypeName)
    {
        string Rtype;
        if(RTypeMap.ContainsKey(strObjectName))
        {
            if(RTypeMap.get(strObjectName).ContainsKey(strRecordTypeName))
                Rtype = RTypeMap.get(strObjectName).get(strRecordTypeName);
        }
        return Rtype;
    }
    private void addErrorPage(ApexPages.Severity Sev)
    {
        if(lstError.size() > 0 && sev == ApexPages.Severity.ERROR)
            ApexPages.AddMessage(new ApexPages.Message(Sev, TU.getTAG046()));
        else if(lstError.size() > 0 && sev == ApexPages.Severity.WARNING)
            ApexPages.AddMessage(new ApexPages.Message(Sev, TU.getTAG047()));
        for(string str :lstError)
        {
            if(str != null)
                ApexPages.AddMessage(new ApexPages.Message(Sev, str));
            else
                ApexPages.AddMessage(new ApexPages.Message(Sev, ''));
        }
    }
    
    boolean isErrorAdded = false;
    boolean isSerialError = false;
    public void serialError()
    {
        isSerialError = true;
        isErrorAdded = true;
        serSelectionMess = true;
    }
    boolean isSerialWarning = false;
    public void serialWarning()
    {
        isSerialWarning = true;
        isErrorAdded = true;
        serSelectionMess = true;
    }
    public class WraperSObject
    {
        public SObject sObj;
        public WraperSObject(SObject o){sObj = o;}
    } 
}