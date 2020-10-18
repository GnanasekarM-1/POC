public with sharing class CONF_SetupDCFieldUpdates
{
    public Map<String,String> mapfieldType = new Map<String,String>();
    public Map<String,String> mapfldApiLabel = new Map<String,String>();
    public Map<String,String> mapfldApiName = new Map<String,String>();
    public Map<String,String> mapSettingValues = new Map<String,String>();
    public Map<String,SVMXC__ServiceMax_Config_Data__c> mapSettingValueIds = new Map<String,SVMXC__ServiceMax_Config_Data__c>();
    public List<SelectOption> WorkOrderUpdatableFields{get;set;}
    public List<SelectOption> eventFields = new List<SelectOption>();
    public List<SelectOption> SVMXEventFields = new List<SelectOption>();
    public List<SVMXC__ServiceMax_Config_Data__c> ActiveGloProInfo = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Processes__c> SettingInfo = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> SettingsValueInfo = new List<SVMXC__ServiceMax_Config_Data__c>();
    public Map<String,Schema.SObjectType> refFldNameMap = new Map<String,Schema.SObjectType>();
    public boolean error = false;
    public set<string> setlst = new set<string>(); 
    public string prefix = getPrefix();
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    
    public string updateField1{get;set;}
    public string updateField2{get;set;}
    public string updateField3{get;set;}
    public string updateField4{get;set;}
    public string updateField5{get;set;}
    public string updateField6{get;set;}
    public string updateField7{get;set;}
    public string updateField8{get;set;}
    public string updateField9{get;set;}
    public string updateField10{get;set;}
    
    public CONF_SetupDCFieldUpdates()
    {
        SettingInfo = [SELECT Id, SVMXC__SUBMODULEID__C FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__SUBMODULEID__C IN ('DCON001') ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ActiveGloProInfo = [Select Id, SVMXC__Profile_Name__c, SVMXC__Active__c,SVMXC__IsDefault__c  From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Configuration Profile' and SVMXC__Configuration_Type__c = 'Global' and SVMXC__Active__C = true]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Processes__c proces : SettingInfo)
        {
            setlst.add(proces.id);
        }
        
    //-------------------------------------------- Retriving Setting Values -------------------------------------------------------
        SettingsValueInfo = [SELECT Id, SVMXC__SETTING_CONFIGURATION_PROFILE__C, SVMXC__SETTING_ID__C, SVMXC__INTERNAL_VALUE__C, //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                SVMXC__DISPLAY_VALUE__C, SVMXC__ACTIVE__C, SVMXC__ISDEFAULT__C, SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c 
                                FROM SVMXC__SERVICEMAX_CONFIG_DATA__C WHERE SVMXC__SETTING_CONFIGURATION_PROFILE__C =: ActiveGloProInfo[0].Id and SVMXC__SETTING_ID__C IN: setlst];
        
        for(integer i =0;i<SettingsValueInfo.size();i++)
        {
            mapSettingValues.put(SettingsValueInfo[i].SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c,SettingsValueInfo[i].SVMXC__DISPLAY_VALUE__C);
            mapSettingValueIds.put(SettingsValueInfo[i].SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c,SettingsValueInfo[i]);
        }
        
        WorkOrderUpdatableFields = new List<SelectOption>();
        WorkOrderUpdatableFields.add(new SelectOption(getTAG001(),getTAG001()));
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        objfieldMap = SVMXC__Service_Order__c.SObjectType.getDescribe().fields.getMap();
        
    //-------------------------------------------- Retriving fields and Updatable fields of Work Order ------------------------------------------
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe(); 
            mapfieldType.put(f.getName(),f.getType().name());
            mapfldApiLabel.put(f.getLabel(),f.getName());
            mapfldApiName.put(f.getName(),f.getLabel());   
            
            if(f.getType().name().ToUpperCase() != 'REFERENCE' && f.getType().name().ToUpperCase() != 'TEXTAREA' && f.getType().name().ToUpperCase() != 'MULTIPICKLIST' && f.isUpdateable() == true && f.getType().name().ToUpperCase() != 'FORMULA'){
                WorkOrderUpdatableFields.add(new SelectOption(f.getName(),f.getLabel()));
            }else if(f.getType().name().ToUpperCase() != 'REFERENCE' && f.getType().name().ToUpperCase() == 'TEXTAREA' && !f.isHtmlFormatted() && f.getType().name().ToUpperCase() != 'MULTIPICKLIST' && f.isUpdateable() == true && f.getType().name().ToUpperCase() != 'FORMULA'){
                WorkOrderUpdatableFields.add(new SelectOption(f.getName(),f.getLabel()));
            }
            if(f.getType().name() == 'REFERENCE')
            refFldNameMap.put(f.getName(),f.getReferenceTo()[0]);
        }
        
    //-------------------------------------------- Sorting the fields to appear in picklist ------------------------------------------------
        WorkOrderUpdatableFields = sortingSelectOption(WorkOrderUpdatableFields);
        
    //-------------------------------------------- Retriving fields and Updatable fields of Event ------------------------------------------
        Map<String, Schema.SObjectField> mapEventFieldDef = new Map<String, Schema.SObjectField>();
        mapEventFieldDef = Event.SObjectType.getDescribe().fields.getMap();

        Map<String, Schema.SObjectField> mapSVMXEventFieldDef = new Map<String, Schema.SObjectField>();
        mapSVMXEventFieldDef = SVMX_Event__c.SObjectType.getDescribe().fields.getMap();

        for (String eventField : mapEventFieldDef.keySet()) 
        {
            Schema.SObjectField fieldDetail = mapSVMXEventFieldDef.get(eventField);
            if(fieldDetail != null)
            {
                Schema.DescribeFieldResult f1 = fieldDetail.getDescribe();
                
                Schema.SObjectField fsObj = mapEventFieldDef.get(eventField);
                Schema.DescribeFieldResult f = fsObj.getDescribe(); 
                
                if(f.isCustom() && f.isUpdateable() &&  f.getType().name().ToUpperCase() != 'REFERENCE' && (f.getType().name().ToUpperCase() != 'TEXTAREA' || !f.isHtmlFormatted()) && f.getType().name().ToUpperCase() != 'MULTIPICKLIST')
                {
                    if(f.getName() != f1.getName() || f.getType().name() != f1.getType().name())
                        continue;

                    if(f.getType().name().ToUpperCase() == 'STRING' || f.getType().name().ToUpperCase() == 'TEXTAREA')
                    {
                        if(f.getByteLength() == f1.getByteLength())
                            SVMXEventFields.add(new SelectOption(prefix + f.getName(), prefix + f.getLabel()));
                    }

                    else if(f.getType().name().ToUpperCase() == 'DOUBLE')
                    {
                        if(f.getPrecision() == f1.getPrecision())
                            SVMXEventFields.add(new SelectOption(prefix + f.getName(), prefix + f.getLabel()));
                    }

                    else if(f.getType().name().ToUpperCase() == 'PICKLIST')
                    {
                        List<Schema.PicklistEntry> lst1 = f.getPicklistValues();
                        List<Schema.PicklistEntry> lst2 = f1.getPicklistValues();
                        if(lst1.size() == lst2.size())
                        {
                            List<string> lstStr1 = new List<string>();
                            List<string> lstStr2 = new List<string>();
                            for(Schema.PicklistEntry s : lst1)
                                lstStr1.add(string.valueOf(s));
                            for(Schema.PicklistEntry s : lst2)
                                lstStr2.add(string.valueOf(s));
                            lstStr1.sort();
                            lstStr2.sort();
                            boolean flag = true;
                            for(integer i = 0; i < lstStr1.size(); i++)
                            {
                                if(lstStr1[i] != lstStr2[i])
                                {
                                    flag = false;
                                    break;
                                }
                            }
                            if(flag == true)
                                SVMXEventFields.add(new SelectOption(prefix + f.getName(), prefix + f.getLabel()));
                        }
                    }
                    else
                        SVMXEventFields.add(new SelectOption(prefix + f.getName(), prefix + f.getLabel()));
                }
            }
        }

        SVMXEventFields = sortingSelectOption(SVMXEventFields);

        for(integer i = 0; i < SVMXEventFields.size(); i++)
        {
            WorkOrderUpdatableFields.add(new SelectOption(SVMXEventFields[i].getValue(), SVMXEventFields[i].getLabel()));
        }
        
    //------------------------------------------- Getting the setting values to appear in the VF Page --------------------------------------------
        SettingValues(mapSettingValues);
        
    }

//------------------------------------------- Method to sort the Fields --------------------------------------------------------------
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
    
    public void SettingValues(Map<String,String> mapSettingValues)
    {
        updateField1 = mapSettingValues.get('DCON001_SET038');
        updateField2 = mapSettingValues.get('DCON001_SET039');
        updateField3 = mapSettingValues.get('DCON001_SET040');
        updateField4 = mapSettingValues.get('DCON001_SET041');
        updateField5 = mapSettingValues.get('DCON001_SET042');
        updateField6 = mapSettingValues.get('DCON001_SET043');
        updateField7 = mapSettingValues.get('DCON001_SET044');
        updateField8 = mapSettingValues.get('DCON001_SET045');
        updateField9 = mapSettingValues.get('DCON001_SET046');
        updateField10 = mapSettingValues.get('DCON001_SET047');
    }
    
    public void save()
    {
        try{
            boolean save_Error;
            
            save_Error = save_Settings();
            if(save_Error == false)    
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,getTAG017()));
                return;
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG018()));
                return;
            }
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }

//------------------------------------ Method to save to the setting values of Submodule IPAD004 --------------------------------------------------------
    public boolean save_Settings()
    {
        List<string> viewLst = new List<string>();          
        List<string> internalLst = new List<string>();
        List<SVMXC__ServiceMax_Config_Data__c> updateConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        boolean error_Generated = true;
        
        addConfigDataLst(updateConfigData,'DCON001_SET038',updateField1);
        addConfigDataLst(updateConfigData,'DCON001_SET039',updateField2);
        addConfigDataLst(updateConfigData,'DCON001_SET040',updateField3);
        addConfigDataLst(updateConfigData,'DCON001_SET041',updateField4);
        addConfigDataLst(updateConfigData,'DCON001_SET042',updateField5);
        addConfigDataLst(updateConfigData,'DCON001_SET043',updateField6);
        addConfigDataLst(updateConfigData,'DCON001_SET044',updateField7);
        addConfigDataLst(updateConfigData,'DCON001_SET045',updateField8);
        addConfigDataLst(updateConfigData,'DCON001_SET046',updateField9);
        addConfigDataLst(updateConfigData,'DCON001_SET047',updateField10);
        
        error = validateMethod(updateConfigData,viewLst,internalLst,0);
        
        //-------------------------------------- Insuring settings to be added starting from the top only --------------------------------- 
        viewLstSaveToUpdateConfigData(updateConfigData,viewLst,internalLst,0);
        
        //------------------------------------- Now saving the settings if no error occurs ---------------------------------------------
        error_Generated = SaveSettings(updateConfigData,error);
        if(error_Generated == true)
            return true;
        else
            return false;
    }

//----------------------------------------------------------- Method for Validation -------------------------------------------------------------------
    public boolean validateMethod(List<SVMXC__ServiceMax_Config_Data__c> updateConfigData, List<string> viewLst, List<string> internalLst,integer settingNo)
    {
        for(integer i = settingNo; i < (settingNo+10); i++){
            for(integer j= i+1; j < (settingNo+10); j++){
                if(updateConfigData[i].SVMXC__Display_Value__c != ''){
                    if(updateConfigData[i].SVMXC__Display_Value__c == updateConfigData[j].SVMXC__Display_Value__c){
                        return true;
                    }
                }
            }
            if(updateConfigData[i].SVMXC__Display_Value__c != '')
            {
                viewLst.add(updateConfigData[i].SVMXC__Display_Value__c);
                internalLst.add(updateConfigData[i].SVMXC__Internal_Value__c);
            }
        }
        return false;
    }
    
//---------------------------------- Method for Insuring settings to be added starting from the top only ---------------------------------------------
    public void viewLstSaveToUpdateConfigData(List<SVMXC__ServiceMax_Config_Data__c> updateConfigData, List<string> viewLst, List<string> internalLst, integer settingNo)
    {
        for(integer i = settingNo; i < (settingNo+10); i++){
            if(i < (viewLst.size()+settingNo))
            {
                updateConfigData[i].SVMXC__Display_Value__c = viewLst[i-settingNo];
                updateConfigData[i].SVMXC__Internal_Value__c = internalLst[i-settingNo];
            }
            else
            {
                updateConfigData[i].SVMXC__Display_Value__c = '';
                updateConfigData[i].SVMXC__Internal_Value__c = '';
            }
        }
    } 
    
//------------------------------------------------------------ Saving the settings --------------------------------------------------------------------
    public boolean SaveSettings(List<SVMXC__ServiceMax_Config_Data__c> updateConfigData, boolean error)
    {
        if(error == false){
            if(updateConfigData != null && updateConfigData.size() > 0) 
                {
                    if (!securityUtils.verifyFieldAccess(updateConfigData, COMM_SecurityUtils.Access.Updateable))
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            update updateConfigData; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                }
            return false;
        }
        else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG018()));
                return true;
            }
    }
    
//------------------------------------ Method for adding field values to the ConfigData List -----------------------------------------------------------
    public void addConfigDataLst(List<SVMXC__ServiceMax_Config_Data__c> updateConfigData, string settingId, string viewFieldValue)
    {
        SVMXC__ServiceMax_Config_Data__c configData = mapSettingValueIds.get(settingId);
        if(viewFieldValue == getTAG001())
            viewFieldValue = '';
        configData.SVMXC__Display_Value__c = viewFieldValue;
        string strFieldName = viewFieldValue;
        if(refFldNameMap.containsKey(strFieldName)){
            if(strFieldName.toLowerCase() == 'ownerid')
            {
                strFieldName = 'Owner.Name';
            }else if(strFieldName.toLowerCase() == 'createdbyid')
            {
                strFieldName = 'CreatedBy.Name';
            }else if(strFieldName.toLowerCase() == 'lastmodifiedbyid')
            {
                strFieldName = 'LastModifiedBy.Name';
            }else
            {
                Schema.SObjectType sobj = refFldNameMap.get(strFieldName);
                if(sobj == Account.SObjectType)
                    strFieldName = strFieldName.replace('__c','__r') + '.Name';
                else
                {
                    Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
                    objfieldMap = sobj.getDescribe().fields.getMap();
                    for(string fieldKey : objfieldMap.keySet()){
                        Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                        Schema.DescribeFieldResult f = fsObj.getDescribe(); 
                        if(f.isNameField()){
                            string FieldName = f.getName();
                            strFieldName = strFieldName.replace('__c','__r') + '.' + FieldName;
                            break;
                        }
                    }
                }
            }
        }
        configData.SVMXC__Internal_Value__c = strFieldName;
        
        updateConfigData.add(configData);
    }

//------------------------------------ Method to reset the setting values of Submodule IPAD001 --------------------------------------------------------
    public void reset()
    {
        Map<String,String>  mapSettingValuesDCON001 = mapforSettingValues(setlst);
        SettingValues(mapSettingValuesDCON001);
    }
    
//--------------------------------------------- Method for getting the latest Setting Values --------------------------------------------------------------
    public Map<String,String>  mapforSettingValues(set<string> setlst){
        List<SVMXC__ServiceMax_Config_Data__c> SettingsValueInfo = [SELECT Id, SVMXC__SETTING_CONFIGURATION_PROFILE__C, SVMXC__SETTING_ID__C, SVMXC__INTERNAL_VALUE__C, //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                SVMXC__DISPLAY_VALUE__C, SVMXC__ACTIVE__C, SVMXC__ISDEFAULT__C, SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c 
                                FROM SVMXC__SERVICEMAX_CONFIG_DATA__C WHERE SVMXC__SETTING_CONFIGURATION_PROFILE__C =: ActiveGloProInfo[0].Id and SVMXC__SETTING_ID__C IN: setlst];
        mapSettingValues.clear();
        for(integer i =0;i<SettingsValueInfo.size();i++)
        {
           // system.debug('Setting Id: ' + SettingsValueInfo[i].SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c + ' Display Value: ' + SettingsValueInfo[i].SVMXC__DISPLAY_VALUE__C);
            mapSettingValues.put(SettingsValueInfo[i].SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c,SettingsValueInfo[i].SVMXC__DISPLAY_VALUE__C);
        }
        return mapSettingValues;
    }

//------------------------------------ Method to Cancel the Changes made in the form --------------------------------------------------------
      
    public Pagereference cancel()
    {
        try
        {
            //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
            String url='';
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                url = '/lightning/n/SVMXC__ServiceMax_Setup';
            }else{
                url ='/apex/SVMXC__CONF_SetupHome';
            }
            Pagereference pageref = new pagereference(url);  
            pageref.setRedirect(true);
            return pageref;
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return null;
    }
    
    public String getTAG001() {return system.label.CONF021_TAG001;}//--None-- 
    public String getTAG002() {return system.label.CONF021_TAG002;}//'Choose Work Order fields to be updated from Dispatch Console'
    public String getTAG003() {return system.label.CONF021_TAG003;}//Reset  
    public String getTAG004() {return system.label.CONF021_TAG004;}//Save  
    public String getTAG005() {return system.label.CONF021_TAG005;}//Back To Setup Home  
    public String getTAG006() {return system.label.CONF021_TAG006;}//Processing...   
    public String getTAG007() {return system.label.CONF021_TAG007;}//Update Field1  
    public String getTAG008() {return system.label.CONF021_TAG008;}//Update Field2  
    public String getTAG009() {return system.label.CONF021_TAG009;}//Update Field3  
    public String getTAG010() {return system.label.CONF021_TAG010;}//Update Field4  
    public String getTAG011() {return system.label.CONF021_TAG011;}//Update Field5  
    public String getTAG012() {return system.label.CONF021_TAG012;}//Update Field6  
    public String getTAG013() {return system.label.CONF021_TAG013;}//Update Field7  
    public String getTAG014() {return system.label.CONF021_TAG014;}//Update Field8  
    public String getTAG015() {return system.label.CONF021_TAG015;}//Update Field9  
    public String getTAG016() {return system.label.CONF021_TAG016;}//Update Field10  
    public String getTAG017() {return system.label.CONF021_TAG017;}//Saved successfully  
    public String getTAG018() {return system.label.CONF021_TAG018;}//Please select one field only once  
    public String getTAG019() {return system.label.CONF021_TAG019;}//DC Work Order Field Updates Help  
    public String getHLPURL() {return system.label.CONF021_HLPURL;}//http://http://userdocs.servicemax.com:8080/ServiceMaxHelp/Summer11/en_us/svmx_redirector.htm?uid=  
    public String getPrefix() {return system.label.CONF021_TAG020 + '.';}//Event  
}