public with sharing class CONF_SetupiPadClient
{
    public Map<String,String> mapfieldType = new Map<String,String>();
    public Map<String,String> mapfldApiLabel = new Map<String,String>();
    public Map<String,String> mapfldApiName = new Map<String,String>();
    public Map<String,String> mapIPADSettingValues = new Map<String,String>();
    public Map<String,SVMXC__ServiceMax_Config_Data__c> mapIPADSettingValueIds = new Map<String,SVMXC__ServiceMax_Config_Data__c>();
    public List<SelectOption> WorkOrderFields{get;set;}
    public List<SelectOption> WorkOrderUpdatableFields{get;set;}
    public List<SVMXC__ServiceMax_Config_Data__c> ActiveGloProInfo = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Processes__c> SettingInfo = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> SettingsValueInfo = new List<SVMXC__ServiceMax_Config_Data__c>();
    public Map<String,Schema.SObjectType> refFldNameMap = new Map<String,Schema.SObjectType>();
    public boolean error = false;
    public set<string> setlst = new set<string>(); 
            
//-------------------------------------------------- Getter Setter Methods ------------------------------------------
    /*public string viewField1{get;set;}
    public string viewField2{get;set;}
    public string viewField3{get;set;}
    public string viewField4{get;set;}
    public string viewField5{get;set;}
    public string viewField6{get;set;}
    public string viewField7{get;set;}
    public string viewField8{get;set;}
    public string viewField9{get;set;}
    public string viewField10{get;set;} 
    public string chkBox1{get;set;} 
    public string chkBox2{get;set;} 
    public string chkBox3{get;set;}
    public string chkBox4{get;set;}
    public string updateField1{get;set;}
    public string updateField2{get;set;}
    public string updateField3{get;set;}
    public string updateField4{get;set;}
    public string updateField5{get;set;}
    public string updateField6{get;set;}
    public string updateField7{get;set;}
    public string updateField8{get;set;}
    public string updateField9{get;set;}
    public string updateField10{get;set;}*/
    public string textField1{get;set;}
    public string addType{get;set;}
    public string chkBox5{get;set;}
    public string chkBox6{get;set;}
    public string chkBox7{get;set;}
    public string chkBox8{get;set;}
    public string chkBox9{get;set;}
    public string chkBox10{get;set;}
    public string chkBox11{get;set;}
    public string chkBox12{get;set;}
    public string viewField11{get;set;}
    public string viewField12{get;set;}
    public string viewField13{get;set;}
    public string viewField14{get;set;}
    public string viewField15{get;set;}
    public string viewField16{get;set;}
    public string viewField17{get;set;}
    public string viewField18{get;set;}
    public string viewField19{get;set;}
    public string viewField20{get;set;}
    
//----------------- Constructor Definition ---------------------------------------  
    public CONF_SetupiPadClient()
    {
        //SettingInfo = [SELECT Id, SVMXC__SUBMODULEID__C FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__SUBMODULEID__C IN ('IPAD001','IPAD002','IPAD003','IPAD004') ];
        SettingInfo = [SELECT Id, SVMXC__SUBMODULEID__C FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__SUBMODULEID__C IN ('IPAD004') ];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ActiveGloProInfo = [Select Id, SVMXC__Profile_Name__c, SVMXC__Active__c,SVMXC__IsDefault__c  From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Configuration Profile' and SVMXC__Configuration_Type__c = 'Global' and SVMXC__Active__C = true];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        //system.debug('ABC'+SettingInfo);
        //system.debug('XYZ'+ActiveGloProInfo);
        for(SVMXC__ServiceMax_Processes__c proces : SettingInfo)
        {
            setlst.add(proces.id);
        }
        
    //-------------------------------------------- Retriving Setting Values -------------------------------------------------------
        SettingsValueInfo = [SELECT Id, SVMXC__SETTING_CONFIGURATION_PROFILE__C, SVMXC__SETTING_ID__C, SVMXC__INTERNAL_VALUE__C, 
                                SVMXC__DISPLAY_VALUE__C, SVMXC__ACTIVE__C, SVMXC__ISDEFAULT__C, SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c 
                                FROM SVMXC__SERVICEMAX_CONFIG_DATA__C WHERE SVMXC__SETTING_CONFIGURATION_PROFILE__C =: ActiveGloProInfo[0].Id and SVMXC__SETTING_ID__C IN: setlst];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        //system.debug('asdf'+SettingsValueInfo);
        
        for(integer i =0;i<SettingsValueInfo.size();i++)
        {
           // system.debug('Setting Id: ' + SettingsValueInfo[i].SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c + ' Display Value: ' + SettingsValueInfo[i].SVMXC__DISPLAY_VALUE__C);
            mapIPADSettingValues.put(SettingsValueInfo[i].SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c,SettingsValueInfo[i].SVMXC__DISPLAY_VALUE__C);
            mapIPADSettingValueIds.put(SettingsValueInfo[i].SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c,SettingsValueInfo[i]);
        }
        
        WorkOrderFields = new List<SelectOption>();
        WorkOrderUpdatableFields = new List<SelectOption>();
        WorkOrderFields.add(new SelectOption(getTAG063(),getTAG063()));
        WorkOrderUpdatableFields.add(new SelectOption(getTAG063(),getTAG063()));
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        Map<String,String> mapObjApiLabel = new Map<String,String>();
        objfieldMap = SVMXC__Service_Order__c.SObjectType.getDescribe().fields.getMap();
        
        map<string, boolean> lstStdObjAccToLicense = new map<string, boolean>();
        COMM_Utils comUtil = new COMM_Utils();
        lstStdObjAccToLicense = comUtil.SVMX_getPermittedStandardObjectList();
        
    //-------------------------------------------- Retriving fields and Updatable fields of Work Order ------------------------------------------
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe(); 
            mapfieldType.put(f.getName(),f.getType().name());
            mapfldApiLabel.put(f.getLabel(),f.getName());
            mapfldApiName.put(f.getName(),f.getLabel());   
            //system.debug('TYPE '+ f.getType().name());
            if(f.getType().name().ToUpperCase() != 'TEXTAREA')
            { // && f.getType().name().ToUpperCase() != 'HTML'
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
                WorkOrderFields.add(new SelectOption(f.getName(),f.getLabel()));
            }else if(f.getType().name().ToUpperCase() == 'TEXTAREA' && !f.isHtmlFormatted())
            {
                WorkOrderFields.add(new SelectOption(f.getName(),f.getLabel()));
            }
            //Naveen 29:Mar:11 : IssueNo: 001986, added Order Status into the validation
            if(f.getType().name().ToUpperCase() != 'REFERENCE' && f.getName() != 'SVMXC__Order_Status__c' && f.getType().name().ToUpperCase() != 'TEXTAREA' && f.getType().name().ToUpperCase() != 'MULTIPICKLIST' && f.isUpdateable() == true){
                WorkOrderUpdatableFields.add(new SelectOption(f.getName(),f.getLabel()));
            }else if(f.getType().name().ToUpperCase() != 'REFERENCE' && f.getName() != 'SVMXC__Order_Status__c' && f.getType().name().ToUpperCase() == 'TEXTAREA' && !f.isHtmlFormatted() && f.getType().name().ToUpperCase() != 'MULTIPICKLIST' && f.isUpdateable() == true){
                WorkOrderUpdatableFields.add(new SelectOption(f.getName(),f.getLabel()));
            }
            if(f.getType().name() == 'REFERENCE')
            refFldNameMap.put(f.getName(),f.getReferenceTo()[0]);
            //system.debug('refFldNameMap'+refFldNameMap);
        }
        
    //-------------------------------------------- Sorting the fields to appear in picklist ------------------------------------------------
        WorkOrderFields = sortingSelectOption(WorkOrderFields);
        WorkOrderUpdatableFields = sortingSelectOption(WorkOrderUpdatableFields);
        
    //------------------------------------------- Getting the setting values to appear in the VF Page --------------------------------------------
        IPADSettingValues1(mapIPADSettingValues);
        /*IPADSettingValues2(mapIPADSettingValues);
        IPADSettingValues3(mapIPADSettingValues);
        IPADSettingValues4(mapIPADSettingValues);*/
    }
 
//------------------------------------------- Method to define the PickList values of the Address Type --------------------------------------- 
    public List<SelectOption> getAddressType()
    {
        List<SelectOption> addTypeLst = new List<SelectOption>();
        addTypeLst.add(new SelectOption(getTAG063(),getTAG063()));
        addTypeLst.add(new SelectOption(getTAG059(),getTAG059()));
        addTypeLst.add(new SelectOption(getTAG060(),getTAG060()));
        addTypeLst.add(new SelectOption(getTAG061(),getTAG061()));
        addTypeLst.add(new SelectOption(getTAG062(),getTAG062()));
        return addTypeLst;
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
    
//--------------------------------------------- Method for getting the latest Setting Values --------------------------------------------------------------
    public Map<String,String>  mapforSettingValues(set<string> setlst){
        List<SVMXC__ServiceMax_Config_Data__c> SettingsValueInfo = [SELECT Id, SVMXC__SETTING_CONFIGURATION_PROFILE__C, SVMXC__SETTING_ID__C, SVMXC__INTERNAL_VALUE__C, 
                                SVMXC__DISPLAY_VALUE__C, SVMXC__ACTIVE__C, SVMXC__ISDEFAULT__C, SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c 
                                FROM SVMXC__SERVICEMAX_CONFIG_DATA__C WHERE SVMXC__SETTING_CONFIGURATION_PROFILE__C =: ActiveGloProInfo[0].Id and SVMXC__SETTING_ID__C IN: setlst];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        mapIPADSettingValues.clear();
        for(integer i =0;i<SettingsValueInfo.size();i++)
        {
           // system.debug('Setting Id: ' + SettingsValueInfo[i].SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c + ' Display Value: ' + SettingsValueInfo[i].SVMXC__DISPLAY_VALUE__C);
            mapIPADSettingValues.put(SettingsValueInfo[i].SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c,SettingsValueInfo[i].SVMXC__DISPLAY_VALUE__C);
        }
        return mapIPADSettingValues;
    }

//------------------------------------ Method to retrieve the setting values of Submodule IPAD004 --------------------------------------------------------
    /*public void IPADSettingValues4(Map<String,String> mapIPADSettingValues)
    {
        textField1 = mapIPADSettingValues.get('IPAD004_SET001');
        addType = mapIPADSettingValues.get('IPAD004_SET002');
        chkBox5 = mapIPADSettingValues.get('IPAD004_SET003');
        chkBox6 = mapIPADSettingValues.get('IPAD004_SET004');
        chkBox7 = mapIPADSettingValues.get('IPAD004_SET005');
        chkBox8 = mapIPADSettingValues.get('IPAD004_SET006');
        chkBox9 = mapIPADSettingValues.get('IPAD004_SET007');
        chkBox10 = mapIPADSettingValues.get('IPAD004_SET008');
        chkBox11 = mapIPADSettingValues.get('IPAD004_SET009');
        chkBox12 = mapIPADSettingValues.get('IPAD004_SET010');
        viewField11 = mapIPADSettingValues.get('IPAD004_SET011');
        viewField12 = mapIPADSettingValues.get('IPAD004_SET012');
        viewField13 = mapIPADSettingValues.get('IPAD004_SET013');
        viewField14 = mapIPADSettingValues.get('IPAD004_SET014');
        viewField15 = mapIPADSettingValues.get('IPAD004_SET015');
        viewField16 = mapIPADSettingValues.get('IPAD004_SET016');
        viewField17 = mapIPADSettingValues.get('IPAD004_SET017');
        viewField18 = mapIPADSettingValues.get('IPAD004_SET018');
        viewField19 = mapIPADSettingValues.get('IPAD004_SET019');
        viewField20 = mapIPADSettingValues.get('IPAD004_SET020');
    }*/
    

//------------------------------------ Method to retrieve the setting values of Submodule IPAD001 --------------------------------------------------------
    public void IPADSettingValues1(Map<String,String> mapIPADSettingValues)
    {
        /*viewField1 = mapIPADSettingValues.get('IPAD001_SET002');
        viewField2 = mapIPADSettingValues.get('IPAD001_SET003');
        viewField3 = mapIPADSettingValues.get('IPAD001_SET004');
        viewField4 = mapIPADSettingValues.get('IPAD001_SET005');
        viewField5 = mapIPADSettingValues.get('IPAD001_SET006');
        viewField6 = mapIPADSettingValues.get('IPAD001_SET007');
        viewField7 = mapIPADSettingValues.get('IPAD001_SET008');
        viewField8 = mapIPADSettingValues.get('IPAD001_SET009');
        viewField9 = mapIPADSettingValues.get('IPAD001_SET010');
        viewField10 = mapIPADSettingValues.get('IPAD001_SET011');
        chkBox1 = mapIPADSettingValues.get('IPAD001_SET001');
        chkBox2 = mapIPADSettingValues.get('IPAD002_SET001');
        chkBox3 = mapIPADSettingValues.get('IPAD002_SET002');
        chkBox4 = mapIPADSettingValues.get('IPAD002_SET003');
        updateField1 = mapIPADSettingValues.get('IPAD003_SET001');
        updateField2 = mapIPADSettingValues.get('IPAD003_SET002');
        updateField3 = mapIPADSettingValues.get('IPAD003_SET003');
        updateField4 = mapIPADSettingValues.get('IPAD003_SET004');
        updateField5 = mapIPADSettingValues.get('IPAD003_SET005');
        updateField6 = mapIPADSettingValues.get('IPAD003_SET006');
        updateField7 = mapIPADSettingValues.get('IPAD003_SET007');
        updateField8 = mapIPADSettingValues.get('IPAD003_SET008');
        updateField9 = mapIPADSettingValues.get('IPAD003_SET009');
        updateField10 = mapIPADSettingValues.get('IPAD003_SET010');*/
        textField1 = mapIPADSettingValues.get('IPAD004_SET001');
        addType = mapIPADSettingValues.get('IPAD004_SET002');
        chkBox5 = mapIPADSettingValues.get('IPAD004_SET003');
        chkBox6 = mapIPADSettingValues.get('IPAD004_SET004');
        chkBox7 = mapIPADSettingValues.get('IPAD004_SET005');
        chkBox8 = mapIPADSettingValues.get('IPAD004_SET006');
        chkBox9 = mapIPADSettingValues.get('IPAD004_SET007');
        chkBox10 = mapIPADSettingValues.get('IPAD004_SET008');
        chkBox11 = mapIPADSettingValues.get('IPAD004_SET009');
        chkBox12 = mapIPADSettingValues.get('IPAD004_SET010');
        viewField11 = mapIPADSettingValues.get('IPAD004_SET011');
        viewField12 = mapIPADSettingValues.get('IPAD004_SET012');
        viewField13 = mapIPADSettingValues.get('IPAD004_SET013');
        viewField14 = mapIPADSettingValues.get('IPAD004_SET014');
        viewField15 = mapIPADSettingValues.get('IPAD004_SET015');
        viewField16 = mapIPADSettingValues.get('IPAD004_SET016');
        viewField17 = mapIPADSettingValues.get('IPAD004_SET017');
        viewField18 = mapIPADSettingValues.get('IPAD004_SET018');
        viewField19 = mapIPADSettingValues.get('IPAD004_SET019');
        viewField20 = mapIPADSettingValues.get('IPAD004_SET020');
    }
/*   
//------------------------------------ Method to retrieve the setting values of Submodule IPAD002 --------------------------------------------------------
    public void IPADSettingValues2(Map<String,String> mapIPADSettingValues)
    {
        chkBox2 = mapIPADSettingValues.get('IPAD002_SET001');
        chkBox3 = mapIPADSettingValues.get('IPAD002_SET002');
        chkBox4 = mapIPADSettingValues.get('IPAD002_SET003');
    }
    
//------------------------------------ Method to retrieve the setting values of Submodule IPAD003 --------------------------------------------------------
    public void IPADSettingValues3(Map<String,String> mapIPADSettingValues)
    {
        updateField1 = mapIPADSettingValues.get('IPAD003_SET001');
        updateField2 = mapIPADSettingValues.get('IPAD003_SET002');
        updateField3 = mapIPADSettingValues.get('IPAD003_SET003');
        updateField4 = mapIPADSettingValues.get('IPAD003_SET004');
        updateField5 = mapIPADSettingValues.get('IPAD003_SET005');
        updateField6 = mapIPADSettingValues.get('IPAD003_SET006');
        updateField7 = mapIPADSettingValues.get('IPAD003_SET007');
        updateField8 = mapIPADSettingValues.get('IPAD003_SET008');
        updateField9 = mapIPADSettingValues.get('IPAD003_SET009');
        updateField10 = mapIPADSettingValues.get('IPAD003_SET010');
    }
  */  


    public void save_All()
    {
        try{
            /*if(chkBox3.toLowerCase()  == 'false' && chkBox4.toLowerCase() == 'false')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Atleast one of "Calculate Labor Price" or "User Can Change Labor Price" should be selected'));
                return;
            }*/
            boolean isValid = true;
            if(chkBox8.toLowerCase() == 'false' && chkBox12.toLowerCase() == 'true')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please check "Show Parts" in order to display Discount%.'));
                isValid = false;
            }
            //Naveen 29:Mar:11 : IssueNo: 001984, added the below validation            
            if(chkBox11.toLowerCase() == 'true' && chkBox8.toLowerCase() == 'false' && chkBox9.toLowerCase() == 'false')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please check "Show Parts" or "Show Labor" in order to show Unit Price'));
                isValid = false;
            }
            if(!isValid)
            {
                return;
            }
            boolean save_Error;
            /*save_Error = save_WOView();
            if(save_Error == true)    
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG056()));
                return;
            }   
            save_TimeMaterial();
            
            save_Error = save_WOUpdate();           
            if(save_Error == true)    
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG056()));
                return;
            }*/
            save_Error = save_ServiceReport();
            if(save_Error == false)    
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,getTAG057()));
                return;
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG056()));
                return;
            }
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
  
//------------------------------------ Method to save the setting values of Submodule IPAD001 --------------------------------------------------------

    /*public boolean save_WOView()
    {
        List<string> viewLst = new List<string>();
        List<string> internalLst = new List<string>();
        List<SVMXC__ServiceMax_Config_Data__c> updateConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        boolean error_Generated = true;
        
        addConfigDataLst(updateConfigData,'IPAD001_SET002',viewField1);
        addConfigDataLst(updateConfigData,'IPAD001_SET003',viewField2);
        addConfigDataLst(updateConfigData,'IPAD001_SET004',viewField3);
        addConfigDataLst(updateConfigData,'IPAD001_SET005',viewField4);
        addConfigDataLst(updateConfigData,'IPAD001_SET006',viewField5);
        addConfigDataLst(updateConfigData,'IPAD001_SET007',viewField6);
        addConfigDataLst(updateConfigData,'IPAD001_SET008',viewField7);
        addConfigDataLst(updateConfigData,'IPAD001_SET009',viewField8);
        addConfigDataLst(updateConfigData,'IPAD001_SET010',viewField9);
        addConfigDataLst(updateConfigData,'IPAD001_SET011',viewField10);
        addConfigDataLst(updateConfigData,'IPAD001_SET001',chkBox1);
        
        error = validateMethod(updateConfigData,viewLst,internalLst,0);
        
        //-------------------------------------- Insuring settings to be added starting from the top only --------------------------------- 
        viewLstSaveToUpdateConfigData(updateConfigData,viewLst,internalLst,0);
        
        //------------------------------------- Now saving the settings if no error occurs ---------------------------------------------
        error_Generated = SaveSettings(updateConfigData,error);
        if(error_Generated == true)
            return true;
        else
            return false;
    }*/
    
//------------------------------------ Method to save to the setting values of Submodule IPAD002 --------------------------------------------------------
    /*public void save_TimeMaterial()
    {
        try{
            List<SVMXC__ServiceMax_Config_Data__c> updateConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
            //Naveen 29:Mar:11 : IssueNo: 001984, added the below validation
            /*if(chkBox3.toLowerCase()  == 'false' && chkBox4.toLowerCase() == 'false')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Atleast one of "Calculate Labor Price" or "User Can Change Labor Price" should be selected'));
                return false;
            }* /
            addConfigDataLst(updateConfigData,'IPAD002_SET001',chkBox2);
            addConfigDataLst(updateConfigData,'IPAD002_SET002',chkBox3);
            addConfigDataLst(updateConfigData,'IPAD002_SET003',chkBox4);
            
            //---------------------------------------- Saving the settings --------------------------------------------------
            update updateConfigData;
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }*/
    
//------------------------------------ Method to save to the setting values of Submodule IPAD003 --------------------------------------------------------
    /*public boolean save_WOUpdate()
    {
        List<string> viewLst = new List<string>();          
        List<string> internalLst = new List<string>();
        List<SVMXC__ServiceMax_Config_Data__c> updateConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        boolean error_Generated = true;
        
        addConfigDataLst(updateConfigData,'IPAD003_SET001',updateField1);
        addConfigDataLst(updateConfigData,'IPAD003_SET002',updateField2);
        addConfigDataLst(updateConfigData,'IPAD003_SET003',updateField3);
        addConfigDataLst(updateConfigData,'IPAD003_SET004',updateField4);
        addConfigDataLst(updateConfigData,'IPAD003_SET005',updateField5);
        addConfigDataLst(updateConfigData,'IPAD003_SET006',updateField6);
        addConfigDataLst(updateConfigData,'IPAD003_SET007',updateField7);
        addConfigDataLst(updateConfigData,'IPAD003_SET008',updateField8);
        addConfigDataLst(updateConfigData,'IPAD003_SET009',updateField9);
        addConfigDataLst(updateConfigData,'IPAD003_SET010',updateField10);
        
        error = validateMethod(updateConfigData,viewLst,internalLst,0);
        //-------------------------------------- Insuring settings to be added starting from the top only --------------------------------- 
        viewLstSaveToUpdateConfigData(updateConfigData,viewLst,internalLst,0);
        
        //------------------------------------- Now saving the settings if no error occurs ---------------------------------------------
        error_Generated = SaveSettings(updateConfigData,error);
        if(error_Generated == true)
            return true;
        else
            return false;
    }*/
    
//------------------------------------ Method to save to the setting values of Submodule IPAD004 --------------------------------------------------------
    public boolean save_ServiceReport()
    {
        List<string> viewLst = new List<string>();          
        List<string> internalLst = new List<string>();
        List<SVMXC__ServiceMax_Config_Data__c> updateConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        boolean error_Generated = true;
        
        //Naveen 29:Mar:11 : IssueNo: 001984, added the below validation
       /* boolean isValid = true;
        if(chkBox8.toLowerCase() == 'false' && chkBox12.toLowerCase() == 'true')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please check "Show Parts" in order to display Discount%.'));
            isValid = false;
        }
        //Naveen 29:Mar:11 : IssueNo: 001984, added the below validation            
        if(chkBox11.toLowerCase() == 'true' && chkBox8.toLowerCase() == 'false' && chkBox9.toLowerCase() == 'false')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please check "Show Parts" or "Show Labor" in order to show Unit Price'));
            isValid = false;
        }
        if(!isValid)
        {
            return false;
        }
        */
        addConfigDataLst(updateConfigData,'IPAD004_SET001',textField1);
        addConfigDataLst(updateConfigData,'IPAD004_SET002',addType);
        addConfigDataLst(updateConfigData,'IPAD004_SET003',chkBox5);
        addConfigDataLst(updateConfigData,'IPAD004_SET004',chkBox6);
        addConfigDataLst(updateConfigData,'IPAD004_SET005',chkBox7);
        addConfigDataLst(updateConfigData,'IPAD004_SET006',chkBox8);
        addConfigDataLst(updateConfigData,'IPAD004_SET007',chkBox9);
        addConfigDataLst(updateConfigData,'IPAD004_SET008',chkBox10);
        addConfigDataLst(updateConfigData,'IPAD004_SET009',chkBox11);
        addConfigDataLst(updateConfigData,'IPAD004_SET010',chkBox12);
        addConfigDataLst(updateConfigData,'IPAD004_SET011',viewField11);
        addConfigDataLst(updateConfigData,'IPAD004_SET012',viewField12);
        addConfigDataLst(updateConfigData,'IPAD004_SET013',viewField13);
        addConfigDataLst(updateConfigData,'IPAD004_SET014',viewField14);
        addConfigDataLst(updateConfigData,'IPAD004_SET015',viewField15);
        addConfigDataLst(updateConfigData,'IPAD004_SET016',viewField16);
        addConfigDataLst(updateConfigData,'IPAD004_SET017',viewField17);
        addConfigDataLst(updateConfigData,'IPAD004_SET018',viewField18);
        addConfigDataLst(updateConfigData,'IPAD004_SET019',viewField19);
        addConfigDataLst(updateConfigData,'IPAD004_SET020',viewField20);
        
        error = validateMethod(updateConfigData,viewLst,internalLst,10);
        
        //-------------------------------------- Insuring settings to be added starting from the top only --------------------------------- 
        viewLstSaveToUpdateConfigData(updateConfigData,viewLst,internalLst,10);
        
        //------------------------------------- Now saving the settings if no error occurs ---------------------------------------------
        error_Generated = SaveSettings(updateConfigData,error);
        if(error_Generated == true)
            return true;
        else
            return false;
    }
   
//------------------------------------ Method for adding field values to the ConfigData List -----------------------------------------------------------
    public void addConfigDataLst(List<SVMXC__ServiceMax_Config_Data__c> updateConfigData, string settingId, string viewFieldValue)
    {
        SVMXC__ServiceMax_Config_Data__c configData = mapIPADSettingValueIds.get(settingId);
        if(viewFieldValue == '--None--')
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

//------------------------------------------------------------ Saving the settings --------------------------------------------------------------------
    public boolean SaveSettings(List<SVMXC__ServiceMax_Config_Data__c> updateConfigData, boolean error)
    {
        if(error == false){
            update updateConfigData;    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            return false;
        }
        else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG056()));
                return true;
            }
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
//------------------------------------ Method to reset the setting values of Submodule IPAD001 --------------------------------------------------------
    public void reset_WOView()
    {
        Map<String,String>  mapIPADSettingValuesIPAD001 = mapforSettingValues(setlst);
        IPADSettingValues1(mapIPADSettingValuesIPAD001);
    }
 /*   
//------------------------------------ Method to reset the setting values of Submodule IPAD002 --------------------------------------------------------
    public void reset_TimeMaterial()
    {
        Map<String,String>  mapIPADSettingValuesIPAD002 = mapforSettingValues(setlst);
        IPADSettingValues2(mapIPADSettingValuesIPAD002);
    }
    
//------------------------------------ Method to reset the setting values of Submodule IPAD003 --------------------------------------------------------
    public void reset_WOUpdate()
    {
        Map<String,String>  mapIPADSettingValuesIPAD003 = mapforSettingValues(setlst);
        IPADSettingValues3(mapIPADSettingValuesIPAD003);
    }
   
//------------------------------------ Method to reset the setting values of Submodule IPAD004 --------------------------------------------------------
    public void reset_ServiceReport()
    {
        Map<String,String>  mapIPADSettingValuesIPAD004 = mapforSettingValues(setlst);
        IPADSettingValues1(mapIPADSettingValuesIPAD004);
    }
    */ 
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
//------------------------------------ TAGS --------------------------------------------------------
    //public String getTAG001() {return system.label.CONF015_TAG001;}//Show SLA Clock
    //public String getTAG002() {return system.label.CONF015_TAG002;}//View Field1
    //public String getTAG003() {return system.label.CONF015_TAG003;}//View Field2
    //public String getTAG004() {return system.label.CONF015_TAG004;}//View Field3
    //public String getTAG005() {return system.label.CONF015_TAG005;}//View Field4
    //public String getTAG006() {return system.label.CONF015_TAG006;}//View Field5
    //public String getTAG007() {return system.label.CONF015_TAG007;}//View Field6
    //public String getTAG008() {return system.label.CONF015_TAG008;}//View Field7
    //public String getTAG009() {return system.label.CONF015_TAG009;}//View Field8
    //public String getTAG010() {return system.label.CONF015_TAG010;}//View Field9
    //public String getTAG011() {return system.label.CONF015_TAG011;}//View Field10
    //public String getTAG012() {return system.label.CONF015_TAG012;}//Work Order View
    public String getTAG013() {return system.label.CONF015_TAG013;}//Reset
    public String getTAG014() {return system.label.CONF015_TAG014;}//Save
    public String getTAG015() {return system.label.CONF015_TAG015;}//Cancel
    //public String getTAG016() {return system.label.CONF015_TAG020;}//User Can Change Parts Price
    //public String getTAG017() {return system.label.CONF015_TAG021;}//Calculate Labour Price
    //public String getTAG018() {return system.label.CONF015_TAG022;}//User Can Change Labour Price
    //public String getTAG019() {return system.label.CONF015_TAG023;}//Time & Material
    //public String getTAG020() {return system.label.CONF015_TAG024;}//Update Field1
    //public String getTAG021() {return system.label.CONF015_TAG025;}//Update Field2
    //public String getTAG022() {return system.label.CONF015_TAG026;}//Update Field3
    //public String getTAG023() {return system.label.CONF015_TAG027;}//Update Field4
    //public String getTAG024() {return system.label.CONF015_TAG028;}//Update Field5
    //public String getTAG025() {return system.label.CONF015_TAG029;}//Update Field6
    //public String getTAG026() {return system.label.CONF015_TAG030;}//Update Field7
    //public String getTAG027() {return system.label.CONF015_TAG031;}//Update Field8
    //public String getTAG028() {return system.label.CONF015_TAG032;}//Update Field9
    //public String getTAG029() {return system.label.CONF015_TAG033;}//Update Field10
    //public String getTAG030() {return system.label.CONF015_TAG034;}//Work Order Update
    //public String getTAG031() {return system.label.CONF015_TAG035;}//Choose Additional Fields To Be Updated From iPad
    public String getTAG032() {return system.label.CONF015_TAG036;}//Report Title
    public String getTAG033() {return system.label.CONF015_TAG037;}//Show Parts
    public String getTAG034() {return system.label.CONF015_TAG038;}//Address Type
    public String getTAG035() {return system.label.CONF015_TAG039;}//Show Labour
    public String getTAG036() {return system.label.CONF015_TAG040;}//Show Contact Phone
    public String getTAG037() {return system.label.CONF015_TAG041;}//Show Expenses
    public String getTAG038() {return system.label.CONF015_TAG042;}//Show Problem Description
    public String getTAG039() {return system.label.CONF015_TAG043;}//Show Line Price
    public String getTAG040() {return system.label.CONF015_TAG044;}//Show Work Performed
    public String getTAG041() {return system.label.CONF015_TAG045;}//Show Discount%
    public String getTAG043() {return system.label.CONF015_TAG046;}//View Field1
    public String getTAG044() {return system.label.CONF015_TAG047;}//
    public String getTAG045() {return system.label.CONF015_TAG048;}//
    public String getTAG046() {return system.label.CONF015_TAG049;}//
    public String getTAG047() {return system.label.CONF015_TAG050;}//
    public String getTAG048() {return system.label.CONF015_TAG051;}//
    public String getTAG049() {return system.label.CONF015_TAG052;}//
    public String getTAG050() {return system.label.CONF015_TAG053;}//
    public String getTAG051() {return system.label.CONF015_TAG054;}//
    public String getTAG052() {return system.label.CONF015_TAG055;}//
    public String getTAG053() {return system.label.CONF015_TAG056;}//Service Report
    public String getTAG054() {return system.label.CONF015_TAG057;}//REPORT HEADER
    public String getTAG055() {return system.label.CONF015_TAG058;}//REPORT LINES
    public String getTAG058() {return system.label.CONF015_TAG059;}//Select Additional Fields To Be Displayed in the Report
    public String getTAG056() {return system.label.CONF015_TAG016;}//Please Select one field only once
    public String getTAG057() {return system.label.CONF015_TAG017;}//Saved Successfully
    public String getTAG059() {return system.label.CONF015_TAG060;}//                                                                               
    public String getTAG060() {return system.label.CONF015_TAG061;}//
    public String getTAG061() {return system.label.CONF015_TAG062;}//
    public String getTAG062() {return system.label.CONF015_TAG063;}//                                                                               
    public String getTAG063() {return system.label.CONF015_TAG064;}//--None--
    public String getTAG064() {return system.label.CONF015_TAG018;}//Processing...
    public String getTAG065() {return system.label.CONF015_TAG019;}//IPAD Help
    public String getTAG042() {return system.label.CONF015_TAG065;}//Please check "Show Parts" or "Show Labor" in order to show Unit Price
    public String getTAG066() {return system.label.CONF015_TAG066;}//Please check "Show Parts" in order to display Discount%
    public String getTAG067() {return system.label.CONF015_TAG067;}//At least one of "Calculate Labor Price" or "User Can Change Labor Price" should be selected
    public String getTAGHLPURL() {return system.label.CONF015_HLPURL;}//http://userdocs.servicemax.com:8080/ServiceMaxHelp/Winter11/en_us/svmx_redirector.htm?uid=
    public String getTAG068() {return 'Allow Signature Capture and Upload';}// system.label.CONF015_TAG063
}