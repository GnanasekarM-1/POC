global with sharing class COMM_Utils_ManageSettings
{
    global SVMXC__ServiceMax_Processes__c SVMX_cloneSubModuleSettings(String existSubModuleId, String newSubModuleId, String installKey, String newModuleId, String newModuleSFDCId)
    {
        // Moved to ManageModules Class
        return null;
    }
    map<string, string> mapExtSettingDefSettingID = new map<string, string>();
    global Map<String, SVMXC__ServiceMax_Processes__c> SVMX_cloneSettingDef(Id extSubModuleSFDCId, Id newSubModuleSFDCId, String installKey)
    {
        Map<String, SVMXC__ServiceMax_Processes__c> setDefList = new Map<String, SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> extSetRecs = new List<SVMXC__ServiceMax_Processes__c>();
        
        extSetRecs = [SELECT SVMXC__Settings_Name__c, SVMXC__Description__c, SVMXC__Values__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE recordType.Name = 'Settings' AND SVMXC__Submodule__c = :extSubModuleSFDCId ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(extSetRecs != null)
        {
            for(SVMXC__ServiceMax_Processes__c oexSVMXProcess :extSetRecs)
            {
                SVMXC__ServiceMax_Processes__c onwSVMXProcess = oexSVMXProcess.clone(false, true);
                onwSVMXProcess.SVMXC__Submodule__c = newSubModuleSFDCId;
                onwSVMXProcess.SVMXC__Installation_Key__c = installKey;
                mapExtSettingDefSettingID.put(oexSVMXProcess.Id, oexSVMXProcess.SVMXC__SettingID__c);
                setDefList.put(oexSVMXProcess.SVMXC__SettingID__c, onwSVMXProcess); 
            }
            //insert setDefList.values(); //commented for the security scanner issue fixes
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(setDefList.values(), COMM_SecurityUtils.Access.Createable)){
                insert setDefList.values();
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            return setDefList;
        }
        else
            return null;
    }
    
    global Map<String, SVMXC__ServiceMax_Processes__c> SVMX_getSettingDef(String subModuleId, String setting)
    {
        Map<String, SVMXC__ServiceMax_Processes__c> setDefList = new Map<String, SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> allSetRecs = new List<SVMXC__ServiceMax_Processes__c>();
        allSetRecs = [SELECT SVMXC__Values__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Submodule__r.SVMXC__SubmoduleID__c = :subModuleId AND SVMXC__Active__c = true And SVMXC__SettingID__c =: setting AND recordType.Name = 'Settings']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(allSetRecs == null)
            return setDefList; //Error
        else
            setDefList.put(setting,allSetRecs[0]);
                
        return setDefList;
    }
    
    // method called by platform cache.
    public Map<String, String> getSettingList(String subModuleId) {
        
        System.debug( LoggingLevel.DEBUG, 'COMM_Utils_ManageSettings::getSettingList() - enter; subModuleId = ' + subModuleId );
        
        Map<String, String> settingList; 
        
        try {
            
            //List<SVMXC__ServiceMax_Processes__c> settingRecords = [SELECT SVMXC__Values__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE   (SVMXC__Submodule__c != Null AND SVMXC__Active__c = true AND recordType.Name = 'Settings' AND (SVMXC__Submodule__r.SVMXC__SubmoduleID__c = :subModuleId Or SVMXC__Submodule__r.SVMXC__SubmoduleID__c =: 'GLOB001') ) ];
            //settingList = SVMX_GetSettingValueMap(settingRecords);
            
            Map<string, Map<String, String>> mapSetting = SVMX_getSettingList(new List<String>{subModuleId});
             
            if( mapSetting.containsKey(subModuleId) ) {
                if( mapSetting.containsKey('GLOB001') ) {
                    mapSetting.get(subModuleId).putAll(mapSetting.get('GLOB001'));
                }   
            }
            else {
                mapSetting.put(subModuleId, new Map<string, string>());
                mapSetting.get(subModuleId).putAll(mapSetting.get('GLOB001'));
            }
            settingList = mapSetting.get(subModuleId);
        }
        
        catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'COMM_Utils_ManageSettings::getSettingList() : Failed to retrieve setting valuse for subModuleId= ' + subModuleId );
            ApexPages.addMessage( new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage() ) );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'COMM_Utils_ManageSettings::getSettingList() - exit;settingList size() = ' + settingList.size() );
        }

        return settingList; 
    }
    
    global Map<String, String> SVMX_getSettingList2(String subModuleId, String setting)
    {
        //return COMM_CreateServerCache.getInstance().getGroupSettingValues(subModuleId, setting);
        
        Map<String, String> setList = new Map<String, String>();
        List<SVMXC__ServiceMax_Processes__c> allSetRecs = new List<SVMXC__ServiceMax_Processes__c>();
        allSetRecs = [SELECT SVMXC__Values__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Submodule__r.SVMXC__SubmoduleID__c = :subModuleId AND SVMXC__Active__c = true And SVMXC__SettingID__c =: setting And recordType.Name = 'Settings']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        if(allSetRecs == null)
            return setList; //Error
                
        setList = SVMX_GetSettingValueMap(allSetRecs);
        return setList;
    }
    
    global Map<String, String> SVMX_getSettingList2(String subModuleId, List<String> settingList)
    {
        
        //return COMM_CreateServerCache.getInstance().getGroupSettingValues(subModuleId, settingList);
        
        Map<String, String> setList = new Map<String, String>();
        List<SVMXC__ServiceMax_Processes__c> allSetRecs = new List<SVMXC__ServiceMax_Processes__c>();
        allSetRecs = [SELECT SVMXC__Values__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Submodule__r.SVMXC__SubmoduleID__c = :subModuleId AND SVMXC__Active__c = true And SVMXC__SettingID__c in: settingList And recordType.Name = 'Settings']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        if(allSetRecs == null)
            return setList; //Error
                
        setList = SVMX_GetSettingValueMap(allSetRecs);
        return setList;
    }
    
    global Map<String, String> SVMX_getSettingList2(String subModuleId)
    {
        System.debug( LoggingLevel.DEBUG, 'COMM_Utils_ManageSettings::SVMX_getSettingList2() - enter;subModuleId = ' + subModuleId );
        
        /*Map<String, String> settingList;
        
        try {
            settingList = COMM_CreateServerCache.getInstance().getGroupSettingValues(subModuleId);            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'COMM_Utils_ManageSettings::SVMX_getSettingList2() - exit;settingList size() = ' + settingList.size() );
        }
        
        return settingList;*/
        
        List<SVMXC__ServiceMax_Processes__c> allSetRecs = new List<SVMXC__ServiceMax_Processes__c>();
            
        Map<String, String> setList = new Map<String, String>(); // The Result List
        try
        {
            List<String> settingList = new List<String>();
            allSetRecs = [SELECT SVMXC__Values__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE   (SVMXC__Submodule__c != Null AND SVMXC__Active__c = true AND recordType.Name = 'Settings' AND (SVMXC__Submodule__r.SVMXC__SubmoduleID__c = :subModuleId Or SVMXC__Submodule__r.SVMXC__SubmoduleID__c =: 'GLOB001') ) ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(allSetRecs == null)
                return setList; //Error
        
            setList = SVMX_GetSettingValueMap(allSetRecs);
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));  return null;
        }

        return   setList;
    }
    
    global List<SVMXC__ServiceMax_Config_Data__c> SVMX_getFieldMapping(String objMapId)
    {
        List<SVMXC__ServiceMax_Config_Data__c> retFldMappings = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        retFldMappings = [SELECT SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__MapID__r.SVMXC__MapID__c, SVMXC__MapID__c, SVMXC__Active__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__r.SVMXC__MapID__c =:objMapId And SVMXC__Active__c = true AND recordType.Name = 'Field Mapping' AND SVMXC__Source_Field_Name__c != Null]; //Added this clause to avoide conflicts with SFM Mappings - Feb-01-2011 //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                
        return retFldMappings;
    }
    
    class SettingWrapper {
        public string propertyKey;
        public string status;
        public string orgId;
                
        public SettingWrapper(){}
    }
    
    global List<SVMXC__ServiceMax_Config_Data__c> SVMX_getInventoryProcessSteps(String jsonReqString)
    {
        //Method not supported: Removed contents : GM : 23 Nov 09
        
        SettingWrapper wrapper = (SettingWrapper) JSON.deserialize(jsonReqString, COMM_Utils_ManageSettings.SettingWrapper.class );        
        updateTriggerSetting(wrapper.propertyKey, wrapper.status, wrapper.orgId);
            
        return null;
    }
    
    global Map<String, SVMXC__ServiceMax_Config_Data__c> SVMX_cloneSettingValues(Id extSubModuleSFDCId, Id newSubModuleSFDCId, String extSubModuleId, String newSubModuleId, map<string, SVMXC__ServiceMax_Config_Data__c> mapSettingValues, String installKey)
    {
        list<SVMXC__ServiceMax_Config_Data__c> lstsetting = new list<SVMXC__ServiceMax_Config_Data__c>();
        Map<String, list<SVMXC__ServiceMax_Config_Data__c>> newSetlist = new Map<String, list<SVMXC__ServiceMax_Config_Data__c>>();
        Map<String, SVMXC__ServiceMax_Processes__c> mapSettingDef = SVMX_cloneSettingDef(extSubModuleSFDCId, newSubModuleSFDCId, installKey);
        
        if(gbllstAllSetValueRecs != null)
        {
            for(SVMXC__ServiceMax_Config_Data__c SVMXConfigData :gbllstAllSetValueRecs)
            {
                if(mapExtSettingDefSettingID.ContainsKey(SVMXConfigData.SVMXC__Setting_ID__c) && mapSettingValues.containsKey(mapExtSettingDefSettingID.get(SVMXConfigData.SVMXC__Setting_ID__c)) && mapSettingDef.containsKey(mapExtSettingDefSettingID.get(SVMXConfigData.SVMXC__Setting_ID__c)))
                {
                    SVMXC__ServiceMax_Config_Data__c newSVMXConfigData = new SVMXC__ServiceMax_Config_Data__c();
                    newSVMXConfigData = SVMXConfigData.clone(false, true);
                    
                    newSVMXConfigData.SVMXC__Setting_ID__c = mapSettingDef.get(mapExtSettingDefSettingID.get(SVMXConfigData.SVMXC__Setting_ID__c)).Id;
                    newSVMXConfigData.SVMXC__Internal_Value__c = mapSettingValues.get(mapExtSettingDefSettingID.get(SVMXConfigData.SVMXC__Setting_ID__c)).SVMXC__Internal_Value__c;
                    newSVMXConfigData.SVMXC__Display_Value__c = mapSettingValues.get(mapExtSettingDefSettingID.get(SVMXConfigData.SVMXC__Setting_ID__c)).SVMXC__Internal_Value__c;
                    if(!newSetlist.containskey(SVMXConfigData.SVMXC__SettingID__c))
                        newSetlist.put(SVMXConfigData.SVMXC__SettingID__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                    newSetlist.get(SVMXConfigData.SVMXC__SettingID__c).add(newSVMXConfigData);
                }
            }
            if(newSetlist != null && newSetlist.size() > 0)
            {
                for(list<SVMXC__ServiceMax_Config_Data__c> l :newSetlist.values())
                {
                    lstsetting.addAll(l);   
                }
            }
            if(lstsetting != null && lstsetting.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstsetting, COMM_SecurityUtils.Access.Upsertable )){
                    upsert lstsetting; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
            }
            return null;
        }
        else
            return null;
    }

    private static Map<String, SVMXC__ServiceMax_Config_Data__c> SVMX_mapSettingsList = new Map<String, SVMXC__ServiceMax_Config_Data__c>(); // The Result List
    
    global Map<String, SVMXC__ServiceMax_Config_Data__c> SVMX_getSettingObjectList(String subModuleId)
    {
        SVMX_getSettingList2(subModuleId);
        return   SVMX_mapSettingsList;  
    }
    
    Private List<SVMXC__ServiceMax_Config_Data__c> gbllstAllSetValueRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
    public Map<String, String> SVMX_GetSettingValueMap(List<SVMXC__ServiceMax_Processes__c> allSetRecs)
    {
        //system.debug('SVMX_GetSettingValueMap() - allSetRecs: ' + allSetRecs);
        List<SVMXC__ServiceMax_Config_Data__c> allConfigRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> allSetValueRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> allConfigProfileRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> allConfigAccessRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
            
        Map<String, String> setList = new Map<String, String>(); // The Result List
        
        if(allSetRecs == null)
            return setList; //Error
        
        List<String> setIdList = new List<String>();
        for(SVMXC__ServiceMax_Processes__c setR : allSetRecs){ //Loop and create one comma seprated string for all ids
            setIdList.add(setR.Id); 
        }
        String settingIds = SVMX_getCommaSepratedStr(setIdList);
        
        String SOQLHeader2 = '';

        String fieldNames = 'SVMXC__User__c, SVMXC__Target_Field_Name__c, SVMXC__Stock_Status__c, SVMXC__Stock_History_Line_Lookup_Field__c, SVMXC__Stock_History_Header_Lookup_Field__c, SVMXC__Source_Field_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c, SVMXC__Setting_ID__r.SVMXC__Installation_Key__c, SVMXC__Setting_ID__r.SVMXC__Search_Order__c, SVMXC__Setting_ID__r.SVMXC__Submodule__c, SVMXC__Setting_ID__r.SVMXC__Setting_Type__c, SVMXC__Setting_ID__r.SVMXC__Default_Value__c, SVMXC__Setting_ID__r.SVMXC__Values__c, SVMXC__Setting_ID__r.SVMXC__IsPrivate__c, SVMXC__Setting_ID__r.SVMXC__Data_Type__c, SVMXC__Setting_ID__r.SVMXC__Settings_Name__c, SVMXC__Setting_ID__r.SVMXC__SettingID__c, SVMXC__Setting_ID__r.SVMXC__Select__c, SVMXC__Setting_ID__r.SVMXC__Record_Type_Name__c, SVMXC__Setting_ID__r.SVMXC__Target_Record_Type__c, SVMXC__Setting_ID__r.SVMXC__Target_Object_Name__c, SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c, SVMXC__Setting_ID__r.SVMXC__MapID__c, SVMXC__Setting_ID__r.SVMXC__Active__c, SVMXC__Setting_ID__r.SVMXC__ProcessID__c, SVMXC__Setting_ID__r.SVMXC__Module__c, SVMXC__Setting_ID__r.SVMXC__SubmoduleID__c, SVMXC__Setting_ID__r.SVMXC__IsStandard__c, SVMXC__Setting_ID__r.SVMXC__Description__c, SVMXC__Setting_ID__r.SVMXC__Name__c, SVMXC__Setting_ID__r.SVMXC__ModuleID__c, SVMXC__Setting_ID__r.SystemModstamp, SVMXC__Setting_ID__r.LastModifiedById, SVMXC__Setting_ID__r.LastModifiedDate, SVMXC__Setting_ID__r.CreatedById, SVMXC__Setting_ID__r.CreatedDate, SVMXC__Setting_ID__r.RecordTypeId, SVMXC__Setting_ID__r.Name, SVMXC__Setting_ID__r.IsDeleted, SVMXC__Setting_ID__r.OwnerId, SVMXC__Setting_ID__r.Id, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Object_Name__c, SVMXC__MapID__c, SVMXC__Location_Type__c, SVMXC__Location_Field_Name__c, SVMXC__Location_Field_From__c, SVMXC__IsDefault__c, SVMXC__Inventory_Process__c, SVMXC__Internal_Value__c, SVMXC__Installation_Key__c, SVMXC__Enter_Date__c, SVMXC__Display_Value__c, SVMXC__Display_Map_ID__c, SVMXC__Description__c, SVMXC__Configuration_Type__c, SVMXC__Config_Profile_Name__c, SVMXC__Active__c, SVMXC__Action__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, Name, Id ';
            
        SOQLHeader2 = ' Select ' + fieldNames + ' FROM SVMXC__ServiceMax_Config_Data__c where ';
        SOQLHeader2 = SOQLHeader2 + ' ( (SVMXC__RecordType_Name__c=\'Setting Value\') And (SVMXC__Setting_ID__r.Id in (' + settingIds + ') ))'; 
        SOQLHeader2 = SOQLHeader2 + ' Or ( SVMXC__RecordType_Name__c=\'Configuration Profile\' )'; 
        SOQLHeader2 = SOQLHeader2 + ' Or ( SVMXC__RecordType_Name__c=\'Configuration Access\' )'; 
        //system.debug('SOQLHeader2:' + SOQLHeader2);
        allConfigRecs = Database.query(SOQLHeader2);
        
        if(allConfigRecs.size() ==0  ||  allConfigRecs == null)
            return setList; //Error
                
        //3. Create list of records for each SVMX_Config_Data record type
        for(SVMXC__ServiceMax_Config_Data__c cfDat : allConfigRecs)
        {
            if(cfDat.SVMXC__RecordType_Name__c == 'Setting Value')
            {
                allSetValueRecs.add(cfDat);
                gbllstallSetValueRecs.add(cfDat);
            }
            if(cfDat.SVMXC__RecordType_Name__c == 'Configuration Profile')
                allConfigProfileRecs.add(cfDat);
            if(cfDat.SVMXC__RecordType_Name__c == 'Configuration Access')
                allConfigAccessRecs.add(cfDat);
        }
        
        //4. Get Global config name/profiles from SVMX_Config_Data
            //-> Record type = Configuration Profile
            //-> Active = true
            //-> Config type = Global
            //-> ERROR if not found
        List<SVMXC__ServiceMax_Config_Data__c> globalConfProfiles = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c confPro : allConfigProfileRecs) {
            if(confPro.SVMXC__Configuration_Type__c == 'Global' && confPro.SVMXC__Active__c  == true) 
                globalConfProfiles.add(confPro);    
        }   
        if(globalConfProfiles == null)
            return setList; //Error
        
        //5. Get additional Config names from SVMX_Config_Data
            //-> Record type = Configuration Access
            //-> User = current user OR Profile = current user's profile
            //-> NOT AN ERROR if not found
        List<SVMXC__ServiceMax_Config_Data__c> usrConfProfiles = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> grpConfProfiles = new List<SVMXC__ServiceMax_Config_Data__c>();
        String usrId = UserInfo.getUserId();
        String usrProfile =  UserInfo.getProfileId();
        for(SVMXC__ServiceMax_Config_Data__c confAcc : allConfigAccessRecs)
        {
            if( (confAcc.SVMXC__User__c == usrId  ) )////&& ( confAcc.SVMXC__Active__c  == true) 
            {
                // Found the Matching Access Record for USER,
                // Now get the corresponding profile rec and push to the USER Profile List
                //-> Loop allConfigProfileRecs and find matching 
                for(SVMXC__ServiceMax_Config_Data__c confPro : allConfigProfileRecs)
                {
                    if(confAcc.SVMXC__Access_Configuration_Profile__c == confPro.Id) 
                        usrConfProfiles.add(confPro);
                } 
            }
            if( (confAcc.SVMXC__Profile__c == usrProfile)  )////&& ( confAcc.SVMXC__Active__c  == true)
            {
                // Found the Matching Access Record,
                // Now get the corresponding profile rec and push to the Group Profile List
                //-> Loop allConfigProfileRecs and find matching 
                for(SVMXC__ServiceMax_Config_Data__c confPro2 : allConfigProfileRecs)
                {
                    if(confAcc.SVMXC__Access_Configuration_Profile__c == confPro2.Id) 
                        grpConfProfiles.add(confPro2); 
                }                 
            }
        }
            
        //System.debug('Size of allConfigAccessRecs: ' + allConfigAccessRecs.size() + '; allConfigAccessRecs: ' + allConfigAccessRecs); 
        //System.debug('User Id: ' + usrId + '; usrConfProfiles: ' + usrConfProfiles); 
        //System.debug('User Profile: ' + usrProfile + '; grpConfProfiles: ' + grpConfProfiles); 
        //6. Loop through setting list and configData List and populat MAP
        for(SVMXC__ServiceMax_Processes__c set1 : allSetRecs)
        {
            List<String> sOrd = new List<String>() ;
            String SearchOrder = '';
            SearchOrder = set1.SVMXC__Search_Order__c;
            if(SearchOrder != null) 
            {
                sOrd = SearchOrder.split(',', 3);
                // sOrd.add(set1.SVMXC__Search_Order_1__c);
                // sOrd.add(set1.SVMXC__Search_Order_2__c);
                // sOrd.add(set1.SVMXC__Search_Order_3__c);
                // Loop all Setting-Values / atleast One setting value should be available
                List<SVMXC__ServiceMax_Config_Data__c> possibleSet1Values = new List<SVMXC__ServiceMax_Config_Data__c>(); 
                for(SVMXC__ServiceMax_Config_Data__c set1Val :allSetValueRecs)
                {
                    if(set1.Id == set1Val.SVMXC__Setting_ID__c) // IMPORTANT: In SVMX_Config_Data we use Setting_ID not SettingID
                        possibleSet1Values.add(set1Val);    
                }
                // system.debug('grpConfProfiles: ' + grpConfProfiles + '; possibleSet1Values: ' + possibleSet1Values);
                Boolean reachedGlobal = false;
                Boolean valFound = false;
                for(String s : sOrd)
                { //Loop SearchOrder List
                    s = s.trim();
                    if(s.toUpperCase() == 'USER' && valFound == false && reachedGlobal == false)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c possVal1 :possibleSet1Values)
                        {
                            for(SVMXC__ServiceMax_Config_Data__c uPro :usrConfProfiles)
                            { //Confirm the setting value has the right USR profile /Loop User Profiles 
                                if(uPro.Id == possVal1.SVMXC__Setting_Configuration_Profile__c )
                                { //One of the User profile should have Setting-Value for Setting Id : set1.Id
                                    //Matching SetVal found, take the Value and add in ResultMap
                                    setList.put(set1.SVMXC__SettingID__c,possVal1.SVMXC__Internal_Value__c);
                                    valFound = true;
                                    SVMX_mapSettingsList.put(set1.SVMXC__SettingID__c, possVal1);
                                }
                            }
                        }
                    }
                    
                    if(s.toUpperCase() == 'GROUP' && valFound == false && reachedGlobal == false)
                    {
                        //Loop all Setting-Values / One of the setting value should have groupProfile 
                        for(SVMXC__ServiceMax_Config_Data__c possVal2 :possibleSet1Values)
                        {
                            for(SVMXC__ServiceMax_Config_Data__c grPro :grpConfProfiles)
                            { //Confirm the setting value has the right USR profile /Loop User Profiles 
                                if(grPro.Id == possVal2.SVMXC__Setting_Configuration_Profile__c )
                                { //One of the User profile should have Setting-Value for Setting Id : set1.Id
                                    //Matching SetVal found, take the Value and add in ResultMap
                                    setList.put(set1.SVMXC__SettingID__c,possVal2.SVMXC__Internal_Value__c);
                                    valFound = true;
                                    SVMX_mapSettingsList.put(set1.SVMXC__SettingID__c, possVal2);
                                }
                            }
                        }
                    }
                    if(s.toUpperCase() == 'GLOBAL' && valFound == false && reachedGlobal == false)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c possVal3 :possibleSet1Values)
                        {
                            for(SVMXC__ServiceMax_Config_Data__c glPro :globalConfProfiles)
                            { //Confirm the setting value has the right USR profile /Loop User Profiles 
                                if(glPro.Id == possVal3.SVMXC__Setting_Configuration_Profile__c )
                                { //One of the User profile should have Setting-Value for Setting Id : set1.Id
                                    //Matching SetVal found, take the Value and add in ResultMap
                                    setList.put(set1.SVMXC__SettingID__c,possVal3.SVMXC__Internal_Value__c);
                                    valFound = true;
                                    reachedGlobal = true;
                                    SVMX_mapSettingsList.put(set1.SVMXC__SettingID__c, possVal3);
                                }
                            }
                        }
                    }
                }
            }
        }
            
        //7. return resullts map    
        //system.debug('SVMX_GetSettingValueMap() return value - setList: ' + setList);
        return setList;
    }
    
    //Build comma separated str for sending ids as string in query within 'IN' clause
    public String SVMX_getCommaSepratedStr(List<String> strAr)
    {
        String retStr = '';
        for (String str : strAr)
        {
            if (retStr.length()>0)
            {
                retStr += ',';
            }
            retStr += '\'' + str + '\'';
        }       
        return retStr;
    }

    public Map<String, String> getGlobalSettingList() {
        
        System.debug( LoggingLevel.DEBUG, 'getGlobalSettingList - enter' );
        
        Map<String, String> mapResult = new Map<String, String>();
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Config_Data__c oCD :lstSettingValues) {
            
            if( oCD.SVMXC__Internal_Value__c != null ) {
                mapResult.put(oCD.SVMXC__Setting_Unique_ID__c, oCD.SVMXC__Internal_Value__c);
            } else {
                mapResult.put(oCD.SVMXC__Setting_Unique_ID__c, '');
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'getGlobalSettingList - exit' );
        
        return mapResult;
    }
    
    public String getGlobalSettingValue( String strSettingId ) {
        
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();

        lstSettingValues = [SELECT SVMXC__Internal_Value__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c = :strSettingId
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            limit 1
                            ];
                                
        if(lstSettingValues != null && lstSettingValues.size() > 0)
            return lstSettingValues[0].SVMXC__Internal_Value__c;
        else 
            return '';
    }
    
    global Map<String, String> SVMX_getGlobalSettingList()
    {
        return COMM_CreateServerCache.getInstance().getAllGlobalSettingValues();
        
        /*Map<String, String> mapResult = new Map<String, String>();
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Config_Data__c oCD :lstSettingValues)
        {
            if(oCD.SVMXC__Setting_Unique_ID__c != null && oCD.SVMXC__Internal_Value__c != null)
                mapResult.put(oCD.SVMXC__Setting_Unique_ID__c, oCD.SVMXC__Internal_Value__c);
        }
        return mapResult;*/
    }

    global String SVMX_getGlobalSettingList(string strSettingId)
    {
        final String value = COMM_CreateServerCache.getInstance().getGlobalSettingValue(strSettingId);
        return value != null? value : '';
        
        /*List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();

        //----Start-----Added for the story BAC-4410 and below code is commented to avoid recursive calling of method for permission check
        /*Commented this code to fix defect 045626 to avoid permission check for configuration object
        if(!Schema.sObjectType.SVMXC__ServiceMax_Config_Data__c.fields.SVMXC__Internal_Value__c.isAccessible()) {   
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            return null;
        }*/
        //----End------Added for the story BAC-4410 and below code is commented to avoid recursive calling of method for permission check

        /*
        List<String> queryFields = new List<String> {'SVMXC__Internal_Value__c','SVMXC__Setting_Unique_ID__c'};
        
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {   
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            return null;
        }*/

        /*lstSettingValues = [SELECT SVMXC__Internal_Value__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c = :strSettingId
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            limit 1
                            ];
                                
        if(lstSettingValues != null && lstSettingValues.size() > 0 )
            return lstSettingValues[0].SVMXC__Internal_Value__c;
        else 
            return '';*/
    }

    public Map<String,String> getGlobalSettingList(List<String> lstSettingId ) {
        
        Map<String, String> mapResult = new Map<String, String>();
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value' AND SVMXC__Setting_Unique_ID__c IN :lstSettingId AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Config_Data__c oCD :lstSettingValues)
        {
            if(oCD.SVMXC__Setting_Unique_ID__c != null && oCD.SVMXC__Internal_Value__c != null)
                mapResult.put(oCD.SVMXC__Setting_Unique_ID__c, oCD.SVMXC__Internal_Value__c);
        }
        return mapResult;
    }
    
    global Map<String, String> SVMX_getGlobalSettingList(list<string> lstSettingId)
    {
        return COMM_CreateServerCache.getInstance().getGlobalSettingValues(lstSettingId);
        
        /*Map<String, String> mapResult = new Map<String, String>();
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value' AND SVMXC__Setting_Unique_ID__c IN :lstSettingId AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Config_Data__c oCD :lstSettingValues)
        {
            if(oCD.SVMXC__Setting_Unique_ID__c != null && oCD.SVMXC__Internal_Value__c != null)
                mapResult.put(oCD.SVMXC__Setting_Unique_ID__c, oCD.SVMXC__Internal_Value__c);
        }
        return mapResult;*/
    }

    global Map<String, String> SVMX_getSettingList(string strSubModuleID)
    {
        return COMM_CreateServerCache.getInstance().getGroupSettingValues(strSubModuleID);
        
        /*list<String> lstSubModuleId = new list<String>();
        lstSubModuleId.add(strSubModuleID);
        map<string, Map<String, String>> mapSetting = new map<string, Map<String, String>>();
        mapSetting = SVMX_getSettingList(lstSubModuleId);
        if(mapSetting.containsKey(strSubModuleID))
        {
            if(mapSetting.containsKey('GLOB001'))
                mapSetting.get(strSubModuleID).putAll(mapSetting.get('GLOB001'));
        }
        else
        {
            mapSetting.put(strSubModuleID, new map<string, string>());
            mapSetting.get(strSubModuleID).putAll(mapSetting.get('GLOB001'));
        }
        return mapSetting.get(strSubModuleID);*/
    }

    global map<string, Map<String, String>> SVMX_getSettingList(list<string> lstSubModuleId)
    {
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllConfigRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllSetValueRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllConfigProfileRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllConfigAccessRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        map<Id, map<string, SVMXC__ServiceMax_Config_Data__c>> mapProfileSettingValueRecs = new map<Id, map<string, SVMXC__ServiceMax_Config_Data__c>>();
        
        map<string, SVMXC__ServiceMax_Config_Data__c> mapUserSetting = new map<string, SVMXC__ServiceMax_Config_Data__c>();
        map<string, SVMXC__ServiceMax_Config_Data__c> mapGroupSetting = new map<string, SVMXC__ServiceMax_Config_Data__c>();
        map<string, SVMXC__ServiceMax_Config_Data__c> mapGlobleSetting = new map<string, SVMXC__ServiceMax_Config_Data__c>();
        map<string, Map<String, String>> mapSetting = new map<string, Map<String, String>>();
        
        map<Id, SVMXC__ServiceMax_Processes__c> mapSettingDefinitions = new map<Id, SVMXC__ServiceMax_Processes__c>();
            
        Map<String, String> setList = new Map<String, String>();
        
        String SOQLHeader2 ='';
        Id usrId = UserInfo.getUserId();
        Id usrProfile =  UserInfo.getProfileId();       
        Id IdGlobleProfile;
        Id IdGroupProfile;
        Id IdUserProfile;
        String fieldNames = 'SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__User__c, SVMXC__Setting_ID__r.SVMXC__Search_Order__c, SVMXC__Setting_ID__r.SVMXC__Submodule__c, SVMXC__Setting_ID__r.SVMXC__Setting_Type__c, SVMXC__Setting_ID__r.SVMXC__SettingID__c, SVMXC__Setting_ID__r.SVMXC__Active__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Internal_Value__c, SVMXC__Configuration_Type__c, SVMXC__Active__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, Id';
        SOQLHeader2 = ' Select ' + fieldNames + ' FROM SVMXC__ServiceMax_Config_Data__c where ';
        SOQLHeader2 = SOQLHeader2 + ' (SVMXC__RecordType_Name__c=\'Setting Value\' And SVMXC__Setting_ID__r.SVMXC__Active__c = true AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true AND (SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c IN :lstSubModuleId OR SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c =\'GLOB001\'))'; 
        SOQLHeader2 = SOQLHeader2 + ' Or ( SVMXC__RecordType_Name__c=\'Configuration Profile\' AND SVMXC__Configuration_Type__c = \'Global\' AND SVMXC__Active__c = true)'; 
        SOQLHeader2 = SOQLHeader2 + ' Or ( SVMXC__RecordType_Name__c=\'Configuration Access\' AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c=\'Configuration Profile\' AND (SVMXC__Profile__c = \'' + usrProfile + '\' Or SVMXC__User__c = \'' + usrId + '\'))'; 
        mapAllConfigRecs.putAll((list<SVMXC__ServiceMax_Config_Data__c>)Database.query(SOQLHeader2));
        system.debug('Query Fired: COMM_Utils_ManageSettings::SVMX_getSettingList: '+SOQLHeader2);
        if(mapAllConfigRecs.size() ==0  ||  mapAllConfigRecs == null)
            return mapSetting;
        for(SVMXC__ServiceMax_Config_Data__c cfDat : mapAllConfigRecs.values()) 
        {
            if(cfDat.SVMXC__RecordType_Name__c == 'Setting Value')
            {
                SVMXC__ServiceMax_Processes__c oSettingDef = (SVMXC__ServiceMax_Processes__c)cfDat.getSObject('SVMXC__Setting_ID__r');
                if(oSettingDef != null && oSettingDef.Id != null)
                    mapSettingDefinitions.put(oSettingDef.Id, oSettingDef);
                    
                if(!mapProfileSettingValueRecs.containsKey(cfDat.SVMXC__Setting_Configuration_Profile__c))
                    mapProfileSettingValueRecs.put(cfDat.SVMXC__Setting_Configuration_Profile__c, new map<string, SVMXC__ServiceMax_Config_Data__c>());
                mapProfileSettingValueRecs.get(cfDat.SVMXC__Setting_Configuration_Profile__c).put(oSettingDef.Id, cfDat);
                mapAllSetValueRecs.put(cfDat.Id, cfDat);
                gbllstallSetValueRecs.add(cfDat);
            }
            if(cfDat.SVMXC__RecordType_Name__c == 'Configuration Profile')
            {
                if(cfDat.SVMXC__Configuration_Type__c == 'Global' && cfDat.SVMXC__Active__c  == true)
                    IdGlobleProfile = cfDat.Id;
                mapAllConfigProfileRecs.put(cfDat.Id, cfDat);
            }
            if(cfDat.SVMXC__RecordType_Name__c == 'Configuration Access')
            {
                if(cfDat.SVMXC__Profile__c != null && cfDat.SVMXC__Profile__c == usrProfile) 
                    IdGroupProfile = cfDat.SVMXC__Access_Configuration_Profile__c;
        
                if(cfDat.SVMXC__User__c != null && cfDat.SVMXC__User__c == usrId)
                    IdUserProfile = cfDat.SVMXC__Access_Configuration_Profile__c;
                mapAllConfigAccessRecs.put(cfDat.Id, cfDat);
            }
        }
      
        mapUserSetting = mapProfileSettingValueRecs.get(IdUserProfile);
        mapGroupSetting = mapProfileSettingValueRecs.get(IdGroupProfile);
        mapGlobleSetting = mapProfileSettingValueRecs.get(IdGlobleProfile);
        System.debug('SVMX_getSettingList(lstSubModuleId) - mapUserSetting: ' + mapUserSetting);
        System.debug('SVMX_getSettingList(lstSubModuleId) - mapGroupSetting: ' + mapGroupSetting);
        System.debug('SVMX_getSettingList(lstSubModuleId) - mapGlobleSetting: ' + mapGlobleSetting);
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapGlobalConfProfiles = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c confPro : mapAllConfigProfileRecs.values()) 
        {
            if(confPro.SVMXC__Configuration_Type__c == 'Global' && confPro.SVMXC__Active__c  == true) 
                mapGlobalConfProfiles.put(confPro.Id, confPro);
        }   
        if(mapGlobalConfProfiles == null)
            return mapSetting;
        for(SVMXC__ServiceMax_Processes__c oSettingDef :mapSettingDefinitions.values())
        {
            if(oSettingDef.SVMXC__Search_Order__c != null)
            {
                List<String> sOrd = oSettingDef.SVMXC__Search_Order__c.split(',', 3);
                string strSubModuleID = oSettingDef.SVMXC__Submodule__r.SVMXC__SubmoduleID__c;
                if(sOrd != null)
                {
                    for(String s : sOrd)
                    {
                        s = s.trim();
                        if(oSettingDef.Id != null)
                        {
                            //System.debug('Search Order: ' + s + '; Setting Def Rec Id: ' + oSettingDef.Id + '; Setting ID: ' + oSettingDef.SVMXC__SettingID__c + '; Global setting value: ' + mapGlobleSetting.get(oSettingDef.Id).SVMXC__Internal_Value__c);
                            if(s.toUpperCase() == 'USER' && mapUserSetting!=NULL && mapUserSetting.containsKey(oSettingDef.Id) && mapUserSetting.get(oSettingDef.Id) != null )
                            {
                                UpdateListMap(mapSetting, strSubModuleID, oSettingDef.SVMXC__SettingID__c, mapUserSetting.get(oSettingDef.Id).SVMXC__Internal_Value__c);
                                break;
                            }
                            else if((s.toUpperCase() == 'USER' || s.toUpperCase() == 'GROUP') && mapGroupSetting!=NULL && mapGroupSetting.containsKey(oSettingDef.Id) && mapGroupSetting.get(oSettingDef.Id) != null)
                            {
                                UpdateListMap(mapSetting, strSubModuleID, oSettingDef.SVMXC__SettingID__c, mapGroupSetting.get(oSettingDef.Id).SVMXC__Internal_Value__c);
                                break;
                            }                         
                            else if((s.toUpperCase() == 'USER' || s.toUpperCase() == 'GROUP' || s.toUpperCase() == 'GLOBAL') && mapGlobleSetting!=NULL && mapGlobleSetting.containsKey(oSettingDef.Id) && mapGlobleSetting.get(oSettingDef.Id) != null)
                            {
                                UpdateListMap(mapSetting, strSubModuleID, oSettingDef.SVMXC__SettingID__c, mapGlobleSetting.get(oSettingDef.Id).SVMXC__Internal_Value__c);
                                break;
                            }
                        }
                    }
                }
                System.debug('SVMX_getSettingList(lstSubModuleId) - mapSetting: ' + mapSetting );
            }
        }
        return mapSetting;
    }

    private void UpdateListMap(map<string, Map<String, String>> mapSettings, string strSubModuleID, string strSettinfId, String strSettingValue)
    {
        if(!mapSettings.containsKey(strSubModuleID))
            mapSettings.put(strSubModuleID, new map<string, string>());
        mapSettings.get(strSubModuleID).put(strSettinfId, strSettingValue);
    }

    global Map<String, String> SVMX_getSettingList(string strSubModuleID, string strSettingID)
    {
        list<string> lstSettingID = new list<string>{strSettingID};
        return SVMX_getSettingList(strSubModuleID, lstSettingID);
    }

    /* Original Code Commented and same method is optimized and available below
    global Map<String, String> SVMX_getSettingList(string strSubModuleID, list<String> lstSettingID)
    {
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllConfigRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllSetValueRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllConfigProfileRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllConfigAccessRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        map<Id, map<string, SVMXC__ServiceMax_Config_Data__c>> mapProfileSettingValueRecs = new map<Id, map<string, SVMXC__ServiceMax_Config_Data__c>>();
        
        map<string, SVMXC__ServiceMax_Config_Data__c> mapUserSetting = new map<string, SVMXC__ServiceMax_Config_Data__c>();
        map<string, SVMXC__ServiceMax_Config_Data__c> mapGroupSetting = new map<string, SVMXC__ServiceMax_Config_Data__c>();
        map<string, SVMXC__ServiceMax_Config_Data__c> mapGlobleSetting = new map<string, SVMXC__ServiceMax_Config_Data__c>();
        Map<String, String> mapSetting = new Map<String, String>();
        
        map<Id, SVMXC__ServiceMax_Processes__c> mapSettingDefinitions = new map<Id, SVMXC__ServiceMax_Processes__c>();
            
        Map<String, String> setList = new Map<String, String>();
        
        String SOQLHeader2 ='';
        Id usrId = UserInfo.getUserId();
        Id usrProfile =  UserInfo.getProfileId();       
        Id IdGlobleProfile;
        Id IdGroupProfile;
        Id IdUserProfile;
        String fieldNames = 'SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__User__c, SVMXC__Target_Field_Name__c, SVMXC__Stock_Status__c, SVMXC__Stock_History_Line_Lookup_Field__c, SVMXC__Stock_History_Header_Lookup_Field__c, SVMXC__Source_Field_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c, SVMXC__Setting_ID__r.SVMXC__Installation_Key__c, SVMXC__Setting_ID__r.SVMXC__Search_Order__c, SVMXC__Setting_ID__r.SVMXC__Submodule__c, SVMXC__Setting_ID__r.SVMXC__Setting_Type__c, SVMXC__Setting_ID__r.SVMXC__Default_Value__c, SVMXC__Setting_ID__r.SVMXC__Values__c, SVMXC__Setting_ID__r.SVMXC__IsPrivate__c, SVMXC__Setting_ID__r.SVMXC__Data_Type__c, SVMXC__Setting_ID__r.SVMXC__Settings_Name__c, SVMXC__Setting_ID__r.SVMXC__SettingID__c, SVMXC__Setting_ID__r.SVMXC__Select__c, SVMXC__Setting_ID__r.SVMXC__Record_Type_Name__c, SVMXC__Setting_ID__r.SVMXC__Target_Record_Type__c, SVMXC__Setting_ID__r.SVMXC__Target_Object_Name__c, SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c, SVMXC__Setting_ID__r.SVMXC__MapID__c, SVMXC__Setting_ID__r.SVMXC__Active__c, SVMXC__Setting_ID__r.SVMXC__ProcessID__c, SVMXC__Setting_ID__r.SVMXC__Module__c, SVMXC__Setting_ID__r.SVMXC__SubmoduleID__c, SVMXC__Setting_ID__r.SVMXC__IsStandard__c, SVMXC__Setting_ID__r.SVMXC__Description__c, SVMXC__Setting_ID__r.SVMXC__Name__c, SVMXC__Setting_ID__r.SVMXC__ModuleID__c, SVMXC__Setting_ID__r.SystemModstamp, SVMXC__Setting_ID__r.LastModifiedById, SVMXC__Setting_ID__r.LastModifiedDate, SVMXC__Setting_ID__r.CreatedById, SVMXC__Setting_ID__r.CreatedDate, SVMXC__Setting_ID__r.RecordTypeId,SVMXC__Setting_ID__r.Name, SVMXC__Setting_ID__r.IsDeleted, SVMXC__Setting_ID__r.OwnerId, SVMXC__Setting_ID__r.Id, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Object_Name__c, SVMXC__MapID__c, SVMXC__Location_Type__c, SVMXC__Location_Field_Name__c, SVMXC__Location_Field_From__c, SVMXC__IsDefault__c, SVMXC__Inventory_Process__c, SVMXC__Internal_Value__c, SVMXC__Installation_Key__c, SVMXC__Enter_Date__c, SVMXC__Display_Value__c, SVMXC__Display_Map_ID__c, SVMXC__Description__c, SVMXC__Configuration_Type__c, SVMXC__Config_Profile_Name__c, SVMXC__Active__c, SVMXC__Action__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, Name, Id ';
        SOQLHeader2 = ' Select ' + fieldNames + ' FROM SVMXC__ServiceMax_Config_Data__c where ';
        SOQLHeader2 = SOQLHeader2 + ' (SVMXC__RecordType_Name__c=\'Setting Value\' And SVMXC__Setting_ID__r.SVMXC__Active__c = true AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true AND SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c = :strSubModuleID AND SVMXC__Setting_ID__r.SVMXC__SettingID__c IN :lstSettingID)'; 
        SOQLHeader2 = SOQLHeader2 + ' Or ( SVMXC__RecordType_Name__c=\'Configuration Profile\' AND SVMXC__Configuration_Type__c = \'Global\' AND SVMXC__Active__c = true)'; 
        SOQLHeader2 = SOQLHeader2 + ' Or ( SVMXC__RecordType_Name__c=\'Configuration Access\' AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c=\'Configuration Profile\' AND (SVMXC__Profile__c = \'' + usrProfile + '\' Or SVMXC__User__c = \'' + usrId + '\'))'; 
        mapAllConfigRecs.putAll((list<SVMXC__ServiceMax_Config_Data__c>)Database.query(SOQLHeader2));
        if(mapAllConfigRecs.size() ==0  ||  mapAllConfigRecs == null)
            return mapSetting;
        for(SVMXC__ServiceMax_Config_Data__c cfDat : mapAllConfigRecs.values()) 
        {
            if(cfDat.SVMXC__RecordType_Name__c == 'Setting Value')
            {
                SVMXC__ServiceMax_Processes__c oSettingDef = (SVMXC__ServiceMax_Processes__c)cfDat.getSObject('SVMXC__Setting_ID__r');
                if(oSettingDef != null && oSettingDef.Id != null)
                    mapSettingDefinitions.put(oSettingDef.Id, oSettingDef);
                    
                if(!mapProfileSettingValueRecs.containsKey(cfDat.SVMXC__Setting_Configuration_Profile__c))
                    mapProfileSettingValueRecs.put(cfDat.SVMXC__Setting_Configuration_Profile__c, new map<string, SVMXC__ServiceMax_Config_Data__c>());
                mapProfileSettingValueRecs.get(cfDat.SVMXC__Setting_Configuration_Profile__c).put(oSettingDef.Id, cfDat);
                
                mapAllSetValueRecs.put(cfDat.Id, cfDat);
                gbllstallSetValueRecs.add(cfDat);
            }
            if(cfDat.SVMXC__RecordType_Name__c == 'Configuration Profile')
            {
                if(cfDat.SVMXC__Configuration_Type__c == 'Global' && cfDat.SVMXC__Active__c  == true)
                    IdGlobleProfile = cfDat.Id;
                mapAllConfigProfileRecs.put(cfDat.Id, cfDat);
            }
            if(cfDat.SVMXC__RecordType_Name__c == 'Configuration Access')
            {
                if(cfDat.SVMXC__Profile__c != null && cfDat.SVMXC__Profile__c == usrProfile) 
                    IdGroupProfile = cfDat.SVMXC__Access_Configuration_Profile__c;
        
                if(cfDat.SVMXC__User__c != null && cfDat.SVMXC__User__c == usrId)
                    IdUserProfile = cfDat.SVMXC__Access_Configuration_Profile__c;
                mapAllConfigAccessRecs.put(cfDat.Id, cfDat);
            }
        }
        mapUserSetting = mapProfileSettingValueRecs.get(IdUserProfile);
        mapGroupSetting = mapProfileSettingValueRecs.get(IdGroupProfile);
        mapGlobleSetting = mapProfileSettingValueRecs.get(IdGlobleProfile);
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapGlobalConfProfiles = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c confPro : mapAllConfigProfileRecs.values()) 
        {
            if(confPro.SVMXC__Configuration_Type__c == 'Global' && confPro.SVMXC__Active__c  == true) 
                mapGlobalConfProfiles.put(confPro.Id, confPro);
        }   
        if(mapGlobalConfProfiles == null)
            return mapSetting;
        for(SVMXC__ServiceMax_Processes__c oSettingDef :mapSettingDefinitions.values())
        {
            if(oSettingDef.SVMXC__Search_Order__c != null)
            {
                List<String> sOrd = oSettingDef.SVMXC__Search_Order__c.split(',', 3);
                //string strSubModuleID = oSettingDef.SVMXC__Submodule__r.SVMXC__SubmoduleID__c;
                if(sOrd != null)
                {
                    for(String s : sOrd)
                    {
                        s = s.trim();
                        if(s.toUpperCase() == 'USER' && mapUserSetting!=NULL && mapUserSetting.containsKey(oSettingDef.Id) && mapUserSetting.get(oSettingDef.Id) != null)
                        {
                            mapSetting.put(oSettingDef.SVMXC__SettingID__c, mapUserSetting.get(oSettingDef.Id).SVMXC__Internal_Value__c);
                            break;
                        }
                        else if((s.toUpperCase() == 'USER'|| s.toUpperCase() == 'GROUP') && mapGroupSetting!=NULL && mapGroupSetting.containsKey(oSettingDef.Id) && mapGroupSetting.get(oSettingDef.Id) != null)
                        {
                            mapSetting.put(oSettingDef.SVMXC__SettingID__c, mapGroupSetting.get(oSettingDef.Id).SVMXC__Internal_Value__c);
                            break;
                        }
                        else if((s.toUpperCase() == 'USER'|| s.toUpperCase() == 'GROUP' || s.toUpperCase() == 'GLOBAL') && mapGlobleSetting!=NULL && mapGlobleSetting.containsKey(oSettingDef.Id) && mapGlobleSetting.get(oSettingDef.Id) != null)
                        {
                            mapSetting.put(oSettingDef.SVMXC__SettingID__c, mapGlobleSetting.get(oSettingDef.Id).SVMXC__Internal_Value__c);
                            break;
                        }
                    }
                } 
            }
        }
        return mapSetting;
    }
    */
    
    //Optimized method
    global Map<String, String> SVMX_getSettingList(string strSubModuleID, list<String> lstSettingID)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('SVMX_getSettingList');
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllConfigRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        //Not used to get values only used to put the values in the map
        //map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllSetValueRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        //map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllConfigAccessRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        
        //map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllConfigProfileRecs = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        //replaced position for the declaration of the map
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapGlobalConfProfiles = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        
        map<Id, map<string, SVMXC__ServiceMax_Config_Data__c>> mapProfileSettingValueRecs = new map<Id, map<string, SVMXC__ServiceMax_Config_Data__c>>();
        
        //map<string, SVMXC__ServiceMax_Config_Data__c> mapUserSetting = new map<string, SVMXC__ServiceMax_Config_Data__c>();
        map<string, SVMXC__ServiceMax_Config_Data__c> mapGroupSetting = new map<string, SVMXC__ServiceMax_Config_Data__c>();
        map<string, SVMXC__ServiceMax_Config_Data__c> mapGlobleSetting = new map<string, SVMXC__ServiceMax_Config_Data__c>();
        Map<String, String> mapSetting = new Map<String, String>();
        
        map<Id, SVMXC__ServiceMax_Processes__c> mapSettingDefinitions = new map<Id, SVMXC__ServiceMax_Processes__c>();
            
        Map<String, String> setList = new Map<String, String>();
        
        String SOQLHeader2 ='';
        Id usrId = UserInfo.getUserId();
        Id usrProfile =  UserInfo.getProfileId();       
        Id IdGlobleProfile;
        Id IdGroupProfile;
        //Id IdUserProfile;
        //String fieldNames = 'SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__User__c, SVMXC__Target_Field_Name__c, SVMXC__Stock_Status__c, SVMXC__Stock_History_Line_Lookup_Field__c, SVMXC__Stock_History_Header_Lookup_Field__c, SVMXC__Source_Field_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c, SVMXC__Setting_ID__r.SVMXC__Installation_Key__c, SVMXC__Setting_ID__r.SVMXC__Search_Order__c, SVMXC__Setting_ID__r.SVMXC__Submodule__c, SVMXC__Setting_ID__r.SVMXC__Setting_Type__c, SVMXC__Setting_ID__r.SVMXC__Default_Value__c, SVMXC__Setting_ID__r.SVMXC__Values__c, SVMXC__Setting_ID__r.SVMXC__IsPrivate__c, SVMXC__Setting_ID__r.SVMXC__Data_Type__c, SVMXC__Setting_ID__r.SVMXC__Settings_Name__c, SVMXC__Setting_ID__r.SVMXC__SettingID__c, SVMXC__Setting_ID__r.SVMXC__Select__c, SVMXC__Setting_ID__r.SVMXC__Record_Type_Name__c, SVMXC__Setting_ID__r.SVMXC__Target_Record_Type__c, SVMXC__Setting_ID__r.SVMXC__Target_Object_Name__c, SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c, SVMXC__Setting_ID__r.SVMXC__MapID__c, SVMXC__Setting_ID__r.SVMXC__Active__c, SVMXC__Setting_ID__r.SVMXC__ProcessID__c, SVMXC__Setting_ID__r.SVMXC__Module__c, SVMXC__Setting_ID__r.SVMXC__SubmoduleID__c, SVMXC__Setting_ID__r.SVMXC__IsStandard__c, SVMXC__Setting_ID__r.SVMXC__Description__c, SVMXC__Setting_ID__r.SVMXC__Name__c, SVMXC__Setting_ID__r.SVMXC__ModuleID__c, SVMXC__Setting_ID__r.SystemModstamp, SVMXC__Setting_ID__r.LastModifiedById, SVMXC__Setting_ID__r.LastModifiedDate, SVMXC__Setting_ID__r.CreatedById, SVMXC__Setting_ID__r.CreatedDate, SVMXC__Setting_ID__r.RecordTypeId,SVMXC__Setting_ID__r.Name, SVMXC__Setting_ID__r.IsDeleted, SVMXC__Setting_ID__r.OwnerId, SVMXC__Setting_ID__r.Id, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Object_Name__c, SVMXC__MapID__c, SVMXC__Location_Type__c, SVMXC__Location_Field_Name__c, SVMXC__Location_Field_From__c, SVMXC__IsDefault__c, SVMXC__Inventory_Process__c, SVMXC__Internal_Value__c, SVMXC__Installation_Key__c, SVMXC__Enter_Date__c, SVMXC__Display_Value__c, SVMXC__Display_Map_ID__c, SVMXC__Description__c, SVMXC__Configuration_Type__c, SVMXC__Config_Profile_Name__c, SVMXC__Active__c, SVMXC__Action__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, Name, Id ';
        String fieldNames = 'Id,SVMXC__Setting_ID__c,SVMXC__RecordType_Name__c,SVMXC__Setting_Configuration_Profile__c,SVMXC__Configuration_Type__c,SVMXC__Active__c,SVMXC__Profile__c,SVMXC__Access_Configuration_Profile__c,SVMXC__User__c,SVMXC__Internal_Value__c,SVMXC__Setting_ID__r.SVMXC__Search_Order__c,SVMXC__Setting_ID__r.Id,SVMXC__Setting_ID__r.SVMXC__SettingID__c';
        SOQLHeader2 = ' Select ' + fieldNames + ' FROM SVMXC__ServiceMax_Config_Data__c where ';
        SOQLHeader2 = SOQLHeader2 + ' (SVMXC__RecordType_Name__c=\'Setting Value\' And SVMXC__Setting_ID__r.SVMXC__Active__c = true AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true AND SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c = :strSubModuleID AND SVMXC__Setting_ID__r.SVMXC__SettingID__c IN :lstSettingID)'; 
        SOQLHeader2 = SOQLHeader2 + ' Or ( SVMXC__RecordType_Name__c=\'Configuration Profile\' AND SVMXC__Configuration_Type__c = \'Global\' AND SVMXC__Active__c = true)'; 
        //SOQLHeader2 = SOQLHeader2 + ' Or ( SVMXC__RecordType_Name__c=\'Configuration Access\' AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c=\'Configuration Profile\' AND (SVMXC__Profile__c = \'' + usrProfile + '\' Or SVMXC__User__c = \'' + usrId + '\'))';
        SOQLHeader2 = SOQLHeader2 + ' Or ( SVMXC__RecordType_Name__c=\'Configuration Access\' AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c=\'Configuration Profile\' AND SVMXC__Profile__c = \'' + usrProfile + '\')'; 
        INTF_DataSync.logSOQL(intMethodCount,SOQLHeader2);
        mapAllConfigRecs.putAll((list<SVMXC__ServiceMax_Config_Data__c>)Database.query(SOQLHeader2));
        if(mapAllConfigRecs.size() ==0  ||  mapAllConfigRecs == null){
            INTF_DataSync.logMethodEndTS(intMethodCount,'SVMX_getSettingList');
            return mapSetting;
        }
        for(SVMXC__ServiceMax_Config_Data__c cfDat : mapAllConfigRecs.values()) 
        {
            if(cfDat.SVMXC__RecordType_Name__c == 'Setting Value')
            {
                SVMXC__ServiceMax_Processes__c oSettingDef = (SVMXC__ServiceMax_Processes__c)cfDat.getSObject('SVMXC__Setting_ID__r');
                if(oSettingDef != null && oSettingDef.Id != null)
                    mapSettingDefinitions.put(oSettingDef.Id, oSettingDef);
                    
                if(!mapProfileSettingValueRecs.containsKey(cfDat.SVMXC__Setting_Configuration_Profile__c))
                    mapProfileSettingValueRecs.put(cfDat.SVMXC__Setting_Configuration_Profile__c, new map<string, SVMXC__ServiceMax_Config_Data__c>());
                mapProfileSettingValueRecs.get(cfDat.SVMXC__Setting_Configuration_Profile__c).put(oSettingDef.Id, cfDat);
                
                //Not used to get values only used to put the values in the map
                //mapAllSetValueRecs.put(cfDat.Id, cfDat);
                
                gbllstallSetValueRecs.add(cfDat);
            }
            if(cfDat.SVMXC__RecordType_Name__c == 'Configuration Profile')
            {
                if(cfDat.SVMXC__Configuration_Type__c == 'Global' && cfDat.SVMXC__Active__c  == true)
                {
                    IdGlobleProfile = cfDat.Id;
                    //Added here to remove one extra loop
                    mapGlobalConfProfiles.put(cfDat.Id, cfDat);
                }
                //mapAllConfigProfileRecs.put(cfDat.Id, cfDat);
            }
            if(cfDat.SVMXC__RecordType_Name__c == 'Configuration Access')
            {
                if(cfDat.SVMXC__Profile__c != null && cfDat.SVMXC__Profile__c == usrProfile) 
                    IdGroupProfile = cfDat.SVMXC__Access_Configuration_Profile__c;
                /*
                if(cfDat.SVMXC__User__c != null && cfDat.SVMXC__User__c == usrId)
                    IdUserProfile = cfDat.SVMXC__Access_Configuration_Profile__c;
                */
                
                //mapAllConfigAccessRecs.put(cfDat.Id, cfDat);
            }
        }
        
        //re-arranged position to save extra execution if the map is null
        if(mapGlobalConfProfiles == null){
            INTF_DataSync.logMethodEndTS(intMethodCount,'SVMX_getSettingList');
            return mapSetting;
        }
            
        //mapUserSetting = mapProfileSettingValueRecs.get(IdUserProfile);
        mapGroupSetting = mapProfileSettingValueRecs.get(IdGroupProfile);
        mapGlobleSetting = mapProfileSettingValueRecs.get(IdGlobleProfile);
        
        /* Commented this loop to save time as the functionality is added in the above loop
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapGlobalConfProfiles = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c confPro : mapAllConfigProfileRecs.values()) 
        {
            if(confPro.SVMXC__Configuration_Type__c == 'Global' && confPro.SVMXC__Active__c  == true) 
                mapGlobalConfProfiles.put(confPro.Id, confPro);
        } 
                
        
        if(mapGlobalConfProfiles == null)
            return mapSetting;
        */
        
        for(SVMXC__ServiceMax_Processes__c oSettingDef :mapSettingDefinitions.values())
        {
            if(oSettingDef.SVMXC__Search_Order__c != null)
            {
                List<String> sOrd = oSettingDef.SVMXC__Search_Order__c.split(',', 3);
                //string strSubModuleID = oSettingDef.SVMXC__Submodule__r.SVMXC__SubmoduleID__c;
                if(sOrd != null)
                {
                    for(String s : sOrd)
                    {
                        s = s.trim();
                        /*if(s.toUpperCase() == 'USER' && mapUserSetting!=NULL && mapUserSetting.containsKey(oSettingDef.Id) && mapUserSetting.get(oSettingDef.Id) != null)
                        {
                            mapSetting.put(oSettingDef.SVMXC__SettingID__c, mapUserSetting.get(oSettingDef.Id).SVMXC__Internal_Value__c);
                            break;
                        }
                        else if((s.toUpperCase() == 'USER'|| s.toUpperCase() == 'GROUP') && mapGroupSetting!=NULL && mapGroupSetting.containsKey(oSettingDef.Id) && mapGroupSetting.get(oSettingDef.Id) != null)
                        */
                        if(s.toUpperCase() == 'GROUP' && mapGroupSetting != NULL && mapGroupSetting.containsKey(oSettingDef.Id) && mapGroupSetting.get(oSettingDef.Id) != null)
                        {
                            mapSetting.put(oSettingDef.SVMXC__SettingID__c, mapGroupSetting.get(oSettingDef.Id).SVMXC__Internal_Value__c);
                            break;
                        }
                        //else if((s.toUpperCase() == 'USER'|| s.toUpperCase() == 'GROUP' || s.toUpperCase() == 'GLOBAL') && mapGlobleSetting!=NULL && mapGlobleSetting.containsKey(oSettingDef.Id) && mapGlobleSetting.get(oSettingDef.Id) != null)
                        else if(mapGlobleSetting !=NULL && mapGlobleSetting.containsKey(oSettingDef.Id) && mapGlobleSetting.get(oSettingDef.Id) != null)
                        {
                            mapSetting.put(oSettingDef.SVMXC__SettingID__c, mapGlobleSetting.get(oSettingDef.Id).SVMXC__Internal_Value__c);
                            break;
                        }
                    }
                } 
            }
        }
        INTF_DataSync.logMethodEndTS( intMethodCount ,'SVMX_getSettingList');
        return mapSetting;
    }
    
    //16th October 2012 :- this method gets the User, Group or Global settings for IPAD module.
    //The reason to create this new method is that during GET_MOBILE_SETTINGS call of ipad the only settings received were of Service Report submodule
    //because a map containing settingID (like SET001, SET002) as key and its corresponding value was sent instead of sending the 
    //Unique Id like IPAD018_SET001.
    //To support previous versions of ipad and also send all the settings we have introduced a new method with one extra parameter.
    //With this parameter as true the settings will be received with the unique id and with false only Settings of service report will be sent. 
    public Map<String, String> SVMX_GetSettingValueMap(List<SVMXC__ServiceMax_Processes__c> allSetRecs, Boolean useUniqueId)
    {
        List<SVMXC__ServiceMax_Config_Data__c> allConfigRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> allSetValueRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> allConfigProfileRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> allConfigAccessRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        Map<String, String> mapSettIdValue = new Map<String, String>(); // The Result List
        SVMXC__ServiceMax_Config_Data__c globalConfProfile;
        String usrProfile =  UserInfo.getProfileId();
        if(allSetRecs == null)
            return mapSettIdValue;
        
        List<ID> lstSettingIds = new List<ID>();
        for(SVMXC__ServiceMax_Processes__c setR : allSetRecs)
        {
            lstSettingIds.add(setR.Id); 
        }
        
        String strQuery ='';
            
        strQuery = ' Select Id, SVMXC__User__c, SVMXC__Setting_Unique_ID__c, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Internal_Value__c, SVMXC__Configuration_Type__c, SVMXC__Access_Configuration_Profile__c  FROM SVMXC__ServiceMax_Config_Data__c where ';
        strQuery = strQuery + ' ( (SVMXC__RecordType_Name__c=\'Setting Value\') And (SVMXC__Setting_ID__r.Id in : lstSettingIds ))'; 
        strQuery = strQuery + ' Or ( SVMXC__RecordType_Name__c=\'Configuration Profile\' and SVMXC__Active__c = true )'; 
        strQuery = strQuery + ' Or ( SVMXC__RecordType_Name__c=\'Configuration Access\' and SVMXC__Profile__c = : usrProfile and SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c in (\'GROUP\', \'USER\')) '; 
        allConfigRecs = Database.query(strQuery);   
        
        if(allConfigRecs.size() ==0  ||  allConfigRecs == null)
            return mapSettIdValue;
            
        //3. Create list of records for each SVMX_Config_Data record type
        for(SVMXC__ServiceMax_Config_Data__c cfDat : allConfigRecs)
        {
            if(cfDat.SVMXC__RecordType_Name__c == 'Setting Value')
            {
                allSetValueRecs.add(cfDat);
            }
            if(cfDat.SVMXC__RecordType_Name__c == 'Configuration Profile')
            {
                if(cfDat.SVMXC__Configuration_Type__c == 'Global')
                    globalConfProfile = cfDat;
                else
                    allConfigProfileRecs.add(cfDat);
            }
            if(cfDat.SVMXC__RecordType_Name__c == 'Configuration Access')
                allConfigAccessRecs.add(cfDat);
        }
        
        if(globalConfProfile == null)
            return mapSettIdValue; //Error
    
        //5. Get additional Config names from SVMX_Config_Data
        //-> Record type = Configuration Access, User = current user OR Profile = current user's profile
        SVMXC__ServiceMax_Config_Data__c usrConfProfile = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c grpConfProfile;
        String usrId = UserInfo.getUserId();
        
        for(SVMXC__ServiceMax_Config_Data__c confAcc : allConfigAccessRecs)
        {
            if((confAcc.SVMXC__User__c == usrId  ))
            {
                // Found the Matching Access Record for USER,
                //Now get the corresponding profile rec and push to the USER Profile List
                //-> Loop allConfigProfileRecs and find matching 
                for(SVMXC__ServiceMax_Config_Data__c confPro : allConfigProfileRecs)
                {
                    if(confAcc.SVMXC__Access_Configuration_Profile__c == confPro.Id)
                    {
                        usrConfProfile = confPro;
                        break;
                    }   
                } 
            }
            if((confAcc.SVMXC__Profile__c == usrProfile))
            {
                // Found the Matching Access Record,
                //Now get the corresponding profile rec and push to the Group Profile List
                //-> Loop allConfigProfileRecs and find matching 
                for(SVMXC__ServiceMax_Config_Data__c confPro2 : allConfigProfileRecs)
                {
                    if(confAcc.SVMXC__Access_Configuration_Profile__c == confPro2.Id)
                    {
                        grpConfProfile = confPro2;
                        break;
                    }   
                }                 
            }
        }
        
        Map<String, List<SVMXC__ServiceMax_Config_Data__c>> mapSettPossibleValues = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
        for(SVMXC__ServiceMax_Config_Data__c set1Val :allSetValueRecs)
        {
            if(!mapSettPossibleValues.containsKey(set1Val.SVMXC__Setting_ID__c))
            {
                List<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
                lstConfigData.add(set1Val);
                mapSettPossibleValues.put(set1Val.SVMXC__Setting_ID__c, lstConfigData);
            }   
            else
                mapSettPossibleValues.get(set1Val.SVMXC__Setting_ID__c).add(set1Val);
        }
                
        //6. Loop through setting list and configData List and populate MAP
        for(SVMXC__ServiceMax_Processes__c set1 : allSetRecs)
        {
            List<String> sOrd = new List<String>() ;
            String SearchOrder = '';
            SearchOrder = set1.SVMXC__Search_Order__c;
            if(SearchOrder != null) 
            {
                sOrd = SearchOrder.split(',', 3);
                Boolean reachedGlobal = false;
                Boolean valFound = false;
                for(String s : sOrd)
                {
                    s= s.trim();
                    if(s.toUpperCase() == 'USER' && valFound == false && reachedGlobal == false)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c possVal1 :mapSettPossibleValues.get(set1.Id))
                        {
                            //Confirm the setting value has the right USR profile /Loop User Profiles 
                            if(usrConfProfile.Id == possVal1.SVMXC__Setting_Configuration_Profile__c )
                            {
                                //One of the User profile should have Setting-Value for Setting Id : set1.Id
                                //Matching SetVal found, take the Value and add in ResultMap
                                if(useUniqueId)
                                {
                                    system.debug(LoggingLevel.WARN, 'Setting ID: ' + set1.SVMXC__Setting_Unique_ID__c + '; User Setting Value: + ' + possVal1.SVMXC__Internal_Value__c);
                                    mapSettIdValue.put(set1.SVMXC__Setting_Unique_ID__c,possVal1.SVMXC__Internal_Value__c);
                                }   
                                else
                                {
                                    system.debug(LoggingLevel.WARN, 'Setting ID: ' + set1.SVMXC__SettingID__c + '; User Setting Value: + ' + possVal1.SVMXC__Internal_Value__c);
                                    mapSettIdValue.put(set1.SVMXC__SettingID__c,possVal1.SVMXC__Internal_Value__c);
                                }
                                valFound = true;
                                break;
                            }
                        }
                    }
                        
                    if(s.toUpperCase() == 'GROUP' && valFound == false && reachedGlobal == false)
                    {
                        //Loop all Setting-Values / One of the setting value should have groupProfile 
                        for(SVMXC__ServiceMax_Config_Data__c possVal2 :mapSettPossibleValues.get(set1.Id))
                        {
                            //Confirm the setting value has the right USR profile /Loop User Profiles 
                            if(grpConfProfile.Id == possVal2.SVMXC__Setting_Configuration_Profile__c )
                            { 
                                //One of the Group profile should have Setting-Value for Setting Id : set1.Id
                                //Matching SetVal found, take the Value and add in ResultMap
                                if(useUniqueId)
                                {
                                    system.debug(LoggingLevel.WARN, 'Setting ID: ' + set1.SVMXC__Setting_Unique_ID__c + '; Group Setting Value: + ' + possVal2.SVMXC__Internal_Value__c);
                                    mapSettIdValue.put(set1.SVMXC__Setting_Unique_ID__c,possVal2.SVMXC__Internal_Value__c);
                                }   
                                else
                                {
                                    system.debug(LoggingLevel.WARN, 'Setting ID: ' + set1.SVMXC__SettingID__c + '; Group Setting Value: + ' + possVal2.SVMXC__Internal_Value__c);
                                    mapSettIdValue.put(set1.SVMXC__SettingID__c,possVal2.SVMXC__Internal_Value__c);
                                }
                                valFound = true;
                                break;
                            }
                        }
                    }
                    if(s.toUpperCase() == 'GLOBAL' && valFound == false && reachedGlobal == false)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c possVal3 :mapSettPossibleValues.get(set1.Id))
                        {
                            //Confirm the setting value has the right USR profile /Loop User Profiles 
                            if(globalConfProfile.Id == possVal3.SVMXC__Setting_Configuration_Profile__c )
                            { 
                                //One of the Global profile should have Setting-Value for Setting Id : set1.Id
                                //Matching SetVal found, take the Value and add in ResultMap
                                if(useUniqueId)
                                {
                                    system.debug(LoggingLevel.WARN, 'Setting ID: ' + set1.SVMXC__Setting_Unique_ID__c + '; Global Setting Value: + ' + possVal3.SVMXC__Internal_Value__c);
                                    mapSettIdValue.put(set1.SVMXC__Setting_Unique_ID__c,possVal3.SVMXC__Internal_Value__c);
                                }
                                else
                                {
                                    system.debug(LoggingLevel.WARN, 'Setting ID: ' + set1.SVMXC__SettingID__c + '; Global Setting Value: + ' + possVal3.SVMXC__Internal_Value__c);
                                    mapSettIdValue.put(set1.SVMXC__SettingID__c,possVal3.SVMXC__Internal_Value__c);
                                }
                                valFound = true;
                                reachedGlobal = true;
                                break;
                            }
                        }
                    }
                }
            }
        }
        return mapSettIdValue;
    }
    
    static final string STATUS_DISABLED ='DISABLED';
    static final string STATUS_ENABLED ='ENABLED';
    
    /*updated:18Jan2017-Defect 038657
      -additionally check for setting name along with trigger name to enable/disable trigger logic execution
    */
    public static boolean isTriggerEnabled(String triggerName, String triggerSettingName) 
        { 
          Boolean returnFlag = true;
          try
          {
            /*if(SVMXC__ServiceMax_Property_Elements__c.getInstance(triggerSettingName)!=null)
               {
                 if(SVMXC__ServiceMax_Property_Elements__c.getInstance(triggerSettingName).SVMXC__Element_Value__c == STATUS_DISABLED)
                     returnFlag = false;
               }
            else
              {
                List<SVMXC__ServiceMax_Property_Elements__c> sprop = [select id,SVMXC__Element_Value__c from SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c = :triggerName] ;
                if(sprop!=null && sprop.size()>0 && sprop[0].SVMXC__Element_Value__c == STATUS_DISABLED)
                   returnFlag = false;  
              }*/
             //Changed this implementation for the defect 039752 fix 
            SVMXC__ServiceMax_Property_Elements__c objPropEle = SVMXC__ServiceMax_Property_Elements__c.getInstance(triggerSettingName);
            System.debug('objPropEle: '+objPropEle);
            if(objPropEle != null){
                if(objPropEle.SVMXC__Property_Key__c == 'SVMXC_CASE_Trigger1' && objPropEle.SVMXC__Element_Value__c == STATUS_DISABLED){
                    returnFlag = false; 
                }
                else if(objPropEle.SVMXC__Property_Key__c != 'SVMXC_CASE_Trigger1'){
                    List<SVMXC__ServiceMax_Property_Elements__c> sprop = [select id,SVMXC__Element_Value__c from SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c = :triggerName] ; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(sprop!=null && sprop.size()>0 && sprop[0].SVMXC__Element_Value__c == STATUS_DISABLED)
                        returnFlag = false; 
                }
            }
          }
          catch (Exception e)
          {
              System.debug('Exception In API isTriggerEnabled() : ' + e.getMessage());
          }
         return returnFlag;
        }
    
    public static boolean updateTriggerSetting(String triggerName, String status, String orgId) {
        SVMXC__ServiceMax_Property_Elements__c svmxPropEle;
        boolean updateStatusFlag = false;
        try {
            string organizationId = UserInfo.getOrganizationId();
            organizationId = organizationId.substring(0, organizationId.length()-3);
            
            if(triggerName != null && status != null &&  organizationId == orgId && (status.equalsIgnoreCase(STATUS_DISABLED) || status.equalsIgnoreCase(STATUS_ENABLED) )) {
                try {
                    svmxPropEle = [SELECT Id,NAME,SVMXC__Property_Key__c,SVMXC__Element_Value__c from SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c = :triggerName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
                catch(QueryException qe ) {
                    System.debug('Exception In API updateTriggerSetting() : ' + qe.getMessage());
                }
                if(svmxPropEle != null) {
                    svmxPropEle.SVMXC__Element_Value__c = status.toUpperCase();                    
                    updateStatusFlag = true;
                } else {
                    svmxPropEle = new SVMXC__ServiceMax_Property_Elements__c();
                    svmxPropEle.Name = 'PELE528';
                    svmxPropEle.SVMXC__Element_Type__c = 'Packaged Trigger';
                    svmxPropEle.SVMXC__Property_Key__c = 'SVMXC_CASE_Trigger1';
                    svmxPropEle.SVMXC__Element_Value__c = 'ENABLED';
                    updateStatusFlag = true;
                    System.debug('Property Element is created.');
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( svmxPropEle, COMM_SecurityUtils.Access.Upsertable) ) {
                    upsert svmxPropEle; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
        } catch(Exception e) {
            System.debug('Exception In API updateTriggerSetting() : ' + e.getMessage());
        }    
        System.debug('Is '+ triggerName + ' Setting value updated successfully : ' + updateStatusFlag );
        return updateStatusFlag;
    }
    
public static map<string, string> SVMX_getDCSetting(List <String> lstSubModules)
{
    List<SVMXC__ServiceMax_Processes__c> allSetRecsglobal = new List<SVMXC__ServiceMax_Processes__c>();
    //list<string> lstSubModules1 = new list<string>{'DCON001','DCON005','OMAX003','SLAT003','DCON006'};

    id RcdTypeSetting = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Processes__c', 'Settings');
    // system.debug('access '+RcdTypeSetting);

    //Query process object based on submoduleids to fetch setting ids.
    allSetRecsglobal = [SELECT SVMXC__Values__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE ( SVMXC__Active__c = true AND recordTypeid= : RcdTypeSetting AND (SVMXC__Submodule__r.SVMXC__SubmoduleID__c = :lstSubModules))];

// Get the  setting ids  in the list
    List<ID> lstSettingIds = new List<ID>();
    for(SVMXC__ServiceMax_Processes__c setR : allSetRecsglobal)
    {
        lstSettingIds.add(setR.Id);
    }

    // system.debug('testing - > '+lstSettingIds);

    id RcdTypeConfProf = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Profile');
    // system.debug('RcdTypeConfProf '+RcdTypeConfProf);

    id RcdTypeConfAcc = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Access');
// system.debug('access acc '+RcdTypeConfAcc);
    Id usrProfile =  UserInfo.getProfileId();
// Setting for global settings

    List<SVMXC__ServiceMax_Config_Data__c> GlobalSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> GroupSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> SVMXProfile = new List<SVMXC__ServiceMax_Config_Data__c>();

    Id Globalprofile;
    Id Groupprofile;
    SVMXProfile = [select id,SVMXC__Profile_Name__c, SVMXC__RecordType_Name__c,SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where (recordtypeid = : RcdTypeConfAcc and SVMXC__Active__c = true and SVMXC__Profile__c =:usrProfile and SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile') OR (recordtypeid = : RcdTypeConfProf and SVMXC__Configuration_Type__c = 'Global' and SVMXC__Active__c = true )];


    for (SVMXC__ServiceMax_Config_Data__c config :SVMXProfile )
    {
        if (config.SVMXC__RecordType_Name__c == 'Configuration Profile')
        {
            Globalprofile = config.id;

        }
        if (config.SVMXC__RecordType_Name__c == 'Configuration Access')
        {
            Groupprofile = config.SVMXC__Access_Configuration_Profile__c;

        }

    }
    id RcdTypeSetVal = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Setting_Value');
// system.debug('RcdTypeSetVal '+RcdTypeSetVal);

    GlobalSettingValues = [select id, SVMXC__Setting_ID__r.SVMXC__SettingID__c,SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c,SVMXC__Display_Value__c, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c where recordtypeid = : RcdTypeSetVal and SVMXC__Setting_Configuration_Profile__c = : Globalprofile and SVMXC__Setting_ID__r.Id in : lstSettingIds];


    GroupSettingValues = [select id, SVMXC__Setting_ID__r.SVMXC__SettingID__c,SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c,SVMXC__Display_Value__c, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c where recordtypeid = : RcdTypeSetVal and SVMXC__Setting_Configuration_Profile__c = : Groupprofile and SVMXC__Setting_ID__r.Id in : lstSettingIds];


// system.debug('Global Values - > '+GlobalSettingValues.size());
    // system.debug('Global Values - > '+GlobalSettingValues);


    // system.debug('Group Values - > '+GroupSettingValues.size());
    // system.debug('Group Values - > '+GroupSettingValues);
    map<Id, SVMXC__ServiceMax_Config_Data__c> mapAllConfigRecs1 = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
    map<string, string> mapAllconfigset = new map<string, string>();

    for (SVMXC__ServiceMax_Config_Data__c configgl :GlobalSettingValues )
    {
        //mapAllconfigset.put(configgl.SVMXC__Setting_ID__r.SVMXC__SettingID__c, configgl.SVMXC__Internal_Value__c);
        mapAllconfigset.put(configgl.SVMXC__Setting_Unique_ID__c, configgl.SVMXC__Internal_Value__c);

        // if (configgl.SVMXC__Setting_ID__r.SVMXC__SettingID__c=='SET007')
        // {
        //  system.debug('SET007 unique ->GGG ' + configgl.SVMXC__Internal_Value__c);
        //  system.debug('SET007 ->GGG  ' + configgl.SVMXC__Setting_Unique_ID__c);
        //  system.debug('SET007 ->GGG '+ configgl.SVMXC__Display_Value__c);
        // }
    }

// system.debug('testing 000 > '+mapAllconfigset.size());
// system.debug('testing 000 > '+mapAllconfigset);

    for (SVMXC__ServiceMax_Config_Data__c configgl :GroupSettingValues )
    {
        // system.debug('configgl -> ' + configgl.SVMXC__Setting_ID__r.SVMXC__SettingID__c);
        // mapAllconfigset.put(configgl.SVMXC__Setting_ID__r.SVMXC__SettingID__c, configgl.SVMXC__Internal_Value__c);
        mapAllconfigset.put(configgl.SVMXC__Setting_Unique_ID__c, configgl.SVMXC__Internal_Value__c);
        // if (configgl.SVMXC__Setting_ID__r.SVMXC__SettingID__c=='SET007')
        // {
        //  system.debug('SET007 unique -> ' + configgl.SVMXC__Internal_Value__c);
        //  system.debug('SET007 -> ' + configgl.SVMXC__Setting_Unique_ID__c);
        //  system.debug('SET007 -> '+ configgl.SVMXC__Display_Value__c);
        // }
    }
    return mapAllconfigset;

}

public static Map<String, String> SVMX_getuniqueSettingValue(String subModuleId, String settingVal)
{
    Map<String, String> setList = new Map<String, String>();
    String ModSettingid = subModuleId + '_' +settingVal;
    // system.debug('ModSettingid -> '+ModSettingid);
    List<SVMXC__ServiceMax_Config_Data__c> SVMXGlobalProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> SVMXGroupProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
    id Accrcdtype = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Profile');
    // system.debug('access '+Accrcdtype);

    id AccrcdtypeAcc = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Access');
    // system.debug('access acc '+AccrcdtypeAcc);

    // Find SVMX global Profile.
    SVMXGlobalProfile = [select id, SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c where recordtypeid = : Accrcdtype and SVMXC__Configuration_Type__c = 'Global' and SVMXC__Active__c = true ];

    // Find Svmx Group Profile.
    Id usrProfile =  UserInfo.getProfileId();
    SVMXGroupProfile = [select id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where recordtypeid = : AccrcdtypeAcc and SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c='Configuration Profile' and SVMXC__Active__c = true and SVMXC__Profile__c =:usrProfile];

    // system.debug('Global Profile - > '+SVMXGlobalProfile[0].id);
    // system.debug('Group Profile - > '+SVMXGroupProfile[0].SVMXC__Access_Configuration_Profile__c);

    // Get the setting values .

    List<SVMXC__ServiceMax_Config_Data__c> GlobalSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> GroupSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
    id AccrcdtypeSettingval = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Setting_Value');
    // system.debug('access acc '+AccrcdtypeAcc);

// First Find the Group setting values .
    if(SVMXGroupProfile.size() > 0){
        GroupSettingValues = [select id, SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c,
                              SVMXC__Display_Value__c, SVMXC__Setting_ID__c, 
                              SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, 
                              SVMXC__Access_Configuration_Profile__c FROM 
                              SVMXC__ServiceMax_Config_Data__c where 
                              recordtypeid = : AccrcdtypeSettingval and 
                              SVMXC__Setting_Configuration_Profile__c = : SVMXGroupProfile[0].SVMXC__Access_Configuration_Profile__c 
                              and SVMXC__Setting_Unique_ID__c =:ModSettingid];
    }
    // system.debug('GroupSettingValues -> '+GroupSettingValues);
    GlobalSettingValues = [select id, SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c,SVMXC__Display_Value__c, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c where recordtypeid = : AccrcdtypeSettingval and SVMXC__Setting_Configuration_Profile__c = : SVMXGlobalProfile[0].id and SVMXC__Setting_Unique_ID__c =:ModSettingid];
    // system.debug('GlobalSettingValues -> '+GlobalSettingValues);

    if (GroupSettingValues.size()> 0 && GroupSettingValues != null)
    {
        setList.put(ModSettingid,GroupSettingValues[0].SVMXC__Internal_Value__c);
    }
    else
    {
        setList.put(ModSettingid,GlobalSettingValues[0].SVMXC__Internal_Value__c);
    }

    return setList;
}

public static Map<String, String> SVMX_getuniqueSettingValueRange(String subModuleId, String settingVal1,String settingVal2,String profileId)
{
    Map<String, String> setList = new Map<String, String>();
    String Fstindex = settingVal1.substring(3);
    String Lastindex = settingVal2.substring(3);
    integer startnum = Integer.valueof(Fstindex.trim());
    integer Endnum = Integer.valueof(Lastindex.trim());

    list <String> uSettiinglst = new list <String>();

    for (Integer i=startnum; i<=Endnum; i++)
    {
        String sInteger = String.valueOf(i);
        if(sInteger.length()==1)
        { sInteger = '00' + sInteger;}
        if(sInteger.length()==2)
        { sInteger = '0' + sInteger;}
        String temp= 'DCON001'+ '_' + 'SET' + sInteger;
        uSettiinglst.add(temp);
    }
    // system.debug('finally -> '+uSettiinglst);

    /* PROCESS AND FIND THE GLOBAL AND GROUP LIST */
    List<SVMXC__ServiceMax_Config_Data__c> SVMXGlobalProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> SVMXGroupProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
    id Accrcdtype = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Profile');
    // system.debug('access '+Accrcdtype);

    id AccrcdtypeAcc = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Access');
    system.debug('access acc: '+AccrcdtypeAcc);

    // Find SVMX global Profile.
    SVMXGlobalProfile = [select id, SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c where recordtypeid = : Accrcdtype and SVMXC__Configuration_Type__c = 'Global' and SVMXC__Active__c = true ];

    Id usrProfile;
    if(profileId == null)
        usrProfile =  UserInfo.getProfileId();
    else
        usrProfile = Id.valueOf(profileId);
    System.debug('profile passed: '+profileId);
    system.debug('usrProfile: '+usrProfile);
        
    // Find Svmx Group Profile.
    SVMXGroupProfile = [select id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where recordtypeid = : AccrcdtypeAcc and SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c='Configuration Profile' and SVMXC__Active__c = true and SVMXC__Profile__c =:usrProfile];

    // system.debug('Global Profile - > '+SVMXGlobalProfile[0].id);
    // system.debug('Group Profile - > '+SVMXGroupProfile[0].SVMXC__Access_Configuration_Profile__c);

    // Get the setting values .

    List<SVMXC__ServiceMax_Config_Data__c> GlobalSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> GroupSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
    id AccrcdtypeSettingval = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Setting_Value');
    // system.debug('access acc '+AccrcdtypeAcc);

// First Find the Group setting values .
    if(SVMXGroupProfile.size() > 0) {
        GroupSettingValues = [select id, SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c,
                              SVMXC__Display_Value__c, SVMXC__Setting_ID__c, 
                              SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, 
                              SVMXC__Access_Configuration_Profile__c FROM 
                              SVMXC__ServiceMax_Config_Data__c where 
                              recordtypeid = : AccrcdtypeSettingval and 
                              SVMXC__Setting_Configuration_Profile__c = : SVMXGroupProfile[0].SVMXC__Access_Configuration_Profile__c 
                              and SVMXC__Setting_Unique_ID__c =:uSettiinglst];
    }
    // system.debug('GroupSettingValues -> '+GroupSettingValues);
    GlobalSettingValues = [select id, SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c,SVMXC__Display_Value__c, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c where recordtypeid = : AccrcdtypeSettingval and SVMXC__Setting_Configuration_Profile__c = : SVMXGlobalProfile[0].id and SVMXC__Setting_Unique_ID__c =:uSettiinglst];
    // system.debug('GlobalSettingValues -> '+GlobalSettingValues);

    Map<String,String> MapGrpsetting = new Map<String,String>();
    Map<String,String> MapGlobalsetting = new Map<String,String>();
    
    for(SVMXC__ServiceMax_Config_Data__c GlobVal :GlobalSettingValues)
    {
        MapGlobalsetting.put(GlobVal.SVMXC__Setting_Unique_ID__c,GlobVal.SVMXC__Internal_Value__c);
    }

    for(SVMXC__ServiceMax_Config_Data__c GrpVal :GroupSettingValues)
    {
        MapGrpsetting.put(GrpVal.SVMXC__Setting_Unique_ID__c,GrpVal.SVMXC__Internal_Value__c);
    }

    // system.debug('MapGrpsetting -> '+MapGrpsetting);
    // system.debug('MapGlobalsetting  -> '+MapGlobalsetting);

    for (String setval : uSettiinglst)
    {
        if(MapGrpsetting.get(setval)!=null)
        {
            setList.put(setval,MapGrpsetting.get(setval));

        }
        else
        {
            if(MapGlobalsetting.get(setval)!=null)
            {
                setList.put(setval,MapGlobalsetting.get(setval));
            }
        }
    }
    return setList;
    }

    public static Map<String, String> SVMX_getSettingValueForList(List<String> modSettingids)
    {
        Map<String, String> setList = new Map<String, String>();
        List<SVMXC__ServiceMax_Config_Data__c> SVMXGlobalProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> SVMXGroupProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
        id Accrcdtype = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Profile');
        // system.debug('access '+Accrcdtype);

        id AccrcdtypeAcc = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Access');
        // system.debug('access acc '+AccrcdtypeAcc);

        // Find SVMX global Profile.
        SVMXGlobalProfile = [select id, SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c where recordtypeid = : Accrcdtype and SVMXC__Configuration_Type__c = 'Global' and SVMXC__Active__c = true ];

        // Find Svmx Group Profile.
        Id usrProfile =  UserInfo.getProfileId();
        SVMXGroupProfile = [select id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where recordtypeid = : AccrcdtypeAcc and SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c='Configuration Profile' and SVMXC__Active__c = true and SVMXC__Profile__c =:usrProfile];

        // system.debug('Global Profile - > '+SVMXGlobalProfile[0].id);
        // system.debug('Group Profile - > '+SVMXGroupProfile[0].SVMXC__Access_Configuration_Profile__c);

        // Get the setting values .

        List<SVMXC__ServiceMax_Config_Data__c> GlobalSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> GroupSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        id AccrcdtypeSettingval = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Setting_Value');
        // system.debug('access acc '+AccrcdtypeAcc);

    // First Find the Group setting values .
        if(SVMXGroupProfile.size() > 0) {
            GroupSettingValues = [select id, SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c,
                                  SVMXC__Display_Value__c, SVMXC__Setting_ID__c, 
                                  SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, 
                                  SVMXC__Access_Configuration_Profile__c FROM 
                                  SVMXC__ServiceMax_Config_Data__c where 
                                  recordtypeid = : AccrcdtypeSettingval and 
                                  SVMXC__Setting_Configuration_Profile__c = : SVMXGroupProfile[0].SVMXC__Access_Configuration_Profile__c 
                                  and SVMXC__Setting_Unique_ID__c In :modSettingids];
        }

        // system.debug('GroupSettingValues -> '+GroupSettingValues);
        GlobalSettingValues = [select id, SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c,SVMXC__Display_Value__c, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c where recordtypeid = : AccrcdtypeSettingval and SVMXC__Setting_Configuration_Profile__c = : SVMXGlobalProfile[0].id and SVMXC__Setting_Unique_ID__c In :modSettingids];
        // system.debug('GlobalSettingValues -> '+GlobalSettingValues);

        for(SVMXC__ServiceMax_Config_Data__c gblSetting : GlobalSettingValues) {
            if(gblSetting.SVMXC__Internal_Value__c != null)
                setList.put(gblSetting.SVMXC__Setting_Unique_ID__c,gblSetting.SVMXC__Internal_Value__c);
        }

        for(SVMXC__ServiceMax_Config_Data__c grpSetting : GroupSettingValues) {
            if(grpSetting.SVMXC__Internal_Value__c != null)
                setList.put(grpSetting.SVMXC__Setting_Unique_ID__c,grpSetting.SVMXC__Internal_Value__c);
        }

        return setList;
    }
}