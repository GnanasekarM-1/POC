public with sharing class INTF_GetServiceFlowWizard 
{
    // We don't have to load setting GBL021, as we are always using VF page in HTML5 - SVMXC__ServiceMaxConsole
    // Load settings to load Checklist. If set to True, then only record is to be loaded. 

    Boolean checklistSettingEnabled = false; // For Checklist 
    //Fixed defect 043293 
    public static boolean isWizardExpression = false;
    String strPageName = 'SVMXC__SFM_TDM_Delivery'; 
    
    
    // Record Id from where the call is made
    Id recordId;

    // The record from querying by adding all the fields from expression
    Sobject record;

    // Object Name; will be used in multiple queries
    String recordObjectName;

    // Get the set of Named Expressions
    Set<Id> setNamedExpressionIds = new Set<Id>();


    // Map of Other action and ID
    public Map<Id, SVMXC__ServiceMax_Processes__c> mapOtherActionRecords = new Map<Id, SVMXC__ServiceMax_Processes__c>();
    
    // Map Wizard Record and ID
    public Map<Id, SVMXC__ServiceMax_Processes__c> mapWizardRecords = new Map<Id, SVMXC__ServiceMax_Processes__c>(); // Map of SFWId, SFWRecord: 
    
    
    // Map Wizard and List of Wizard STeps
    public Map<Id, List<SVMXC__ServiceMax_Processes__c>>   mapWizardIdStepsList = new Map<Id, List<SVMXC__ServiceMax_Processes__c>>();  // Map of SFWId, List of SFWAction 
    
    // Map Custom Action Id and Paramas
    public Map<Id, List<SVMXC__ServiceMax_Config_Data__c>> mapOtherActionIdsParamsList = new  Map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();  // Map of OtherActionId and it's Parameters
    

    public Set<Id> setQualifiedWizardIds = new Set<Id>();
    

    public Map<Id, Boolean>  mapExprIdIsMatched = new Map<Id, Boolean>(); // Map of SFWId, SFWRecord: 
    //public Map<Id, String>   mapOtherActionIdURL = new Map<Id, String>(); // Map of OtherActionId and it's Url: 
    //public Map<String, Schema.SObjectField> mapOfAllFields = new Map<String, Schema.SObjectField>(); // Holds Fields collection for the record's object 
    public List<SVMXC__ServiceMax_Processes__c> lstNamedExpDefintion = new List<SVMXC__ServiceMax_Processes__c>(); 
    public map<Id, SVMXC__ServiceMax_Processes__c> mapNamedExpDefinition = new map<Id, SVMXC__ServiceMax_Processes__c>();
   // public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> Map_HeaderExpDetail = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public Set<String> setActionTypeValues = new Set<String>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstWizardLayouts = new List<SVMXC__ServiceMax_Config_Data__c>();
        
    public String fieldString = '';

    public Boolean isJwtEnabled = false; //Added for the task BAC-5229
    public Boolean isSFMLightning = false; //Added for the task 
    public Boolean isCorsEnabled = false; //Added for the task
    public Boolean isStatisticsEnabled = false; //Added for the task
    public String appInstanceName = '';
    public Boolean isOldInventoryUIEnabled = false; //Added for story BAC-5963
    
    // Util to load setting
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Boolean isLegacyDeliveryEnabled = false; //Added for the task BAC-6188
    

    /* Method is used to load settings and to be used across. 
    */
    public INTF_GetServiceFlowWizard(){
        appInstanceName = SFMDeliveryController.getInstanceName();
        Map<String,Map<String,String>> mapAllSubmoduleSettings = commSettings.SVMX_getSettingList(new List<String>{'SFM002','COMM004', 'GLOB001','INVT001'});
        
        //Map<String, String> svmxSettingListGLOB = commSettings.SVMX_getSettingList('GLOB001');
        
        Map<String, String> svmxSettingListGLOB = new Map<String, String>();
        if(mapAllSubmoduleSettings != null){
            svmxSettingListGLOB = mapAllSubmoduleSettings.get('GLOB001');

            if(svmxSettingListGLOB != null){
                if(svmxSettingListGLOB.containsKey('GBL021') && svmxSettingListGLOB.get('GBL021') != null ){
                    String pageNameSetting = svmxSettingListGLOB.get('GBL021');
                    if(pageNameSetting.equalsIgnoreCase('HTML5') )
                        strPageName = 'SVMXC__ServiceMaxConsole';
                }

                if(svmxSettingListGLOB.containsKey('GBL029') && Boolean.valueOf(svmxSettingListGLOB.get('GBL029')) == true){
                    checklistSettingEnabled = true;    
                }
                
                //Added for the task BAC-5229
                if((svmxSettingListGLOB.containsKey('GBL039') && svmxSettingListGLOB.get('GBL039') != null && Boolean.valueOf(svmxSettingListGLOB.get('GBL039')) == true) && Site.getSiteId() != null){
                    isJwtEnabled = true;
                }
                
                //Added for the task
                if(svmxSettingListGLOB.containsKey('GBL043') && svmxSettingListGLOB.get('GBL043') != null && Boolean.valueOf(svmxSettingListGLOB.get('GBL043')) == true){
                    isCorsEnabled = true;
                }
            }

            //Added for the task
            Map<String,String> mapSettings = mapAllSubmoduleSettings.get('SFM002');
            if(mapSettings != null && mapSettings.containsKey('SET004') && mapSettings.get('SET004') != null && mapSettings.get('SET004').equalsIgnoreCase('Lightning')){
                isSFMLightning = true;
            }
            
            //Added for the task BAC-6188
            if(mapSettings != null && mapSettings.containsKey('SET007') && mapSettings.get('SET007') != null){
                isLegacyDeliveryEnabled = Boolean.valueOf(mapSettings.get('SET007'));
            }

            //Added for the task
            mapSettings = mapAllSubmoduleSettings.get('COMM004');
            if(mapSettings != null && mapSettings.containsKey('SET001') && mapSettings.get('SET001') != null && mapSettings.get('SET001').equalsIgnoreCase('Allow')){
                isStatisticsEnabled = true;
            }
            //Added for the story  BAC-5963
            mapSettings = mapAllSubmoduleSettings.get('INVT001');
            if(mapSettings != null && mapSettings.containsKey('SET003') && mapSettings.get('SET003') != null && Boolean.valueOf(mapSettings.get('SET003')) == true){
                isOldInventoryUIEnabled = true;
            }
        }
    }

    // Return the HTML to display all the applicable wizards for the given recId
    // This is used by SFM Search and Classic
    public String GetSFWHTML(String recId, String keyVal)
    {
        SVMXC_Generate_SFW_Utils(recId, keyVal);
        return  SVMX_Generate_SFW_HTML(recId, 'wizload');
    }

    // Overwritten method and can be called directly by Lightning. 
    public String SVMXC_Generate_SFW_Utils( String recId, String keyVal ) {
        return SVMXC_Generate_SFW_Utils( recId, keyVal, APFT_Constants.APPLICATION_PROFILE_ID_ONLINE );
    }

    // Method called from Lightning component
    public SFM_Wizard_LightningController.RecordWizard getLightningSFW(String recId, String keyVal){
        SVMXC_Generate_SFW_Utils( recId, keyVal, APFT_Constants.APPLICATION_PROFILE_ID_ONLINE );
        return getSFWLightningWrapper(recId);
    }

    
    // for laptop
    public Set<String> lstIdsForOtherAction = new Set<String>();
    public Map<String, SVMXC__ServiceMax_Processes__c> MapOtherAction = new Map<String, SVMXC__ServiceMax_Processes__c>();
    public Map<String, List<SVMXC.INTF_WebServicesDef.INTF_StringMap>> MapStrngActnParam = new Map<String, List<SVMXC.INTF_WebServicesDef.INTF_StringMap>>();
    
    Set<String> setFieldAPINames = new Set<String>();
    
    
    
    // Prepare all the data for all the SFW's applicable to the recId passed
    /*
        1) Get all Active wizards and only the ones which have wizard step associated with it associated to the object. 
        2) Apply Application filter
        3) Perform translation.
        4) Get Current User and it's associated Servicemax profile. Filter the list of Wizards which are accessible by this profile

        ======================================================================================================

        1) Get list of Expressions from Wizard and Wizard steps.
        2) Get List of ACtions and action param. It can be retrieved in single query

    */
    public String SVMXC_Generate_SFW_Utils(String recId, String keyVal, String deviceType )
    {
        
        if(!String.isBlank(recId))
            recordId = Id.valueOf(recId.trim());
        else
            return '';
        //Defect Fix 043237
        String recordObjectNameforWizard = recordId.getSObjectType().getDescribe().getName();
        // Get object Keyprefix
        String ObjectKeyPrefix = String.valueOf(recordId).subString(0, 3);
        
        // This is used only for translation
        List<SVMXC__ServiceMax_Processes__c> lstWizards = new List<SVMXC__ServiceMax_Processes__c>();

        Map<Id, SVMXC__ServiceMax_Processes__c> mapWizardStepRecords = new Map<Id, SVMXC__ServiceMax_Processes__c>();   // Map of SFWActionId, SFWActionRecord: 
    

        // Get User's ServiceMax Group Configuration ProfileId
        String userSVMXProfileId;
        Id userSfProfileId = UserInfo.getProfileId();
        for (SVMXC__ServiceMax_Config_Data__c groupProfile : [Select Id, SVMXC__Access_Configuration_Profile__c, RecordType.Name, RecordTypeId 
                                                                    From SVMXC__ServiceMax_Config_Data__c 
                                                                        WHERE RecordType.Name = 'Configuration Access' 
                                                                            AND SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Group' 
                                                                            AND SVMXC__Profile__c =: userSfProfileId]){
                //  Assign User Servicemax profile
                userSVMXProfileId = groupProfile.SVMXC__Access_Configuration_Profile__c;
                break;
        }  

        System.debug( LoggingLevel.DEBUG, 'userSVMXProfileId - ' + userSVMXProfileId );
        

        // Populate the action picklist. It will be empty if called from online SFW Delivery S-Control. 
        // It will be populated if the request is from iPad App
        if(setActionTypeValues == null || setActionTypeValues.size() == 0)
        {
            setActionTypeValues.add('INVENTORY');
            setActionTypeValues.add('OTHERS');
            setActionTypeValues.add('SFM');
            setActionTypeValues.add('RECEIPT');
            setActionTypeValues.add('DELIVERY');
            setActionTypeValues.add('SHIP');
            setActionTypeValues.add('PICK_MOVE');
            setActionTypeValues.add('INITIATE_RETURN');
            setActionTypeValues.add('FULFILLMENT');
            setActionTypeValues.add('OUTPUT_DOCUMENT');
            
            //Display Checklist wizard step only if the checklist setting is enabled
            if(checklistSettingEnabled)  
               setActionTypeValues.add('CHECKLIST');
        }

        System.debug( LoggingLevel.DEBUG, 'List of SFM types to load - ' + setActionTypeValues );

        // Get List of Wizards and it's access permissions
        // Get List of Wizard Steps as well
        List<SVMXC__ServiceMax_Processes__c> lstWizardSteps = new List<SVMXC__ServiceMax_Processes__c>();
        //Defect Fix 043237: Added Source Object Name condition in Query
        for(SVMXC__ServiceMax_Processes__c wizard: [Select Id, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, 
                        SVMXC__Rule_Type__c, Name, SVMXC__Parent_Error_Msg__c,  SVMXC__Child_Error_Msg__c, 
                            SVMXC__Confirmation_Message__c, SVMXC__Tag_Keys__c, SVMXC__Source_Object_Name__c, 
                                SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Submodule__c, SVMXC__Description__c, 
                                    SVMXC__Active__c, SVMXC__Object_key_prefix__c,SVMXC__Mode_Of_Execution__c, 
                                        SVMXC__IsGlobal__c, SVMXC__Handover__c,
                                        (SELECT SVMXC__Access_Configuration_Profile__c, 
                                                            SVMXC__Access_Configuration_Profile__r.Id,
                                                                SVMXC__Dispatch_Process__c 
                                                                    FROM  SVMXC__ServiceMax_Config_Data__r  
                                                                        WHERE RecordType.Name = 'Wizard Access'),
                                        (Select Id, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Rule_Type__c, Name, SVMXC__Parent_Error_Msg__c,  SVMXC__Child_Error_Msg__c, SVMXC__Tag_Keys__c, SVMXC__Process__c, 
                                            SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c,  SVMXC__Action_Type__c, SVMXC__Select_Template_At_Runtime__c, SVMXC__Action_URL__c, SVMXC__Sequence__c, SVMXC__Submodule__c, SVMXC__IsStandard__c,       
                                                SVMXC__Process__r.SVMXC__Name__c, SVMXC__Process__r.SVMXC__Window_Height__c, SVMXC__Process__r.SVMXC__Window_Width__c, SVMXC__Process__r.SVMXC__Description__c, SVMXC__Process__r.SVMXC__Source_Object_Name__c, SVMXC__Process__r.SVMXC__Active__c, SVMXC__Process__r.SVMXC__Target_Type__c,
                                                SVMXC__Process__r.SVMXC__Target_URL__c, SVMXC__Process__r.SVMXC__IsStandard__c, SVMXC__Process__r.SVMXC__Show_Scrollbars__c, SVMXC__Process__r.SVMXC__Open_As_Full_Window__c, SVMXC__Process__r.SVMXC__Custom_Action_Type__c,
                                                SVMXC__Process__r.SVMXC__ProcessId__c, SVMXC__Mode_Of_Execution__c, SVMXC__Handover__c, SVMXC__Process1__c, SVMXC__Enable_Confirmation_Dialog__c, SVMXC__Confirmation_Message__c 
                                                    FROM SVMXC__ServiceMax_Processes2__r 
                                                    WHERE RecordType.Name = 'Wizard Step' AND SVMXC__Action_Type__c In :setActionTypeValues Order By SVMXC__Sequence__c)
                        FROM SVMXC__ServiceMax_Processes__c 
                        WHERE RecordType.Name = 'Wizard' 
                        AND SVMXC__Object_key_prefix__c =:ObjectKeyPrefix AND SVMXC__Source_Object_Name__c =: recordObjectNameforWizard AND SVMXC__Active__c = true]) {

            if(ObjectKeyPrefix.equals(wizard.SVMXC__Object_key_prefix__c)){
                recordObjectName = wizard.SVMXC__Source_Object_Name__c;
            }
                

            // If user ID is not blank, then only update the Map of wizards
            /*if(!String.isBlank(usrSVMXProfileId)){
                for(SVMXC__ServiceMax_Config_Data__c wizardAccess: wizard.SVMXC__ServiceMax_Config_Data__r){
                    if(userSVMXProfileId.equalsIgnoreCase(String.valueOf(wizardAccess.SVMXC__Access_Configuration_Profile__c))){
                        mapWizardRecords.put(wizard.Id, wizard);
                        if(wizard.SVMXC__Submodule__c != null ){
                            setNamedExpressionIds.add(wizard.SVMXC__Submodule__c);      
                        }
                        // Populate steps only for User qualified wizards
                        lstWizardSteps = wizard.ServiceMax_Processes2__r;

                        // Only qualified wizards should be translated
                        lstWizards.add(wizard);
                    }
                }    
            }*/

            List <SVMXC__ServiceMax_Config_Data__c> lstWizardAccess = wizard.SVMXC__ServiceMax_Config_Data__r; 
            List<SVMXC__ServiceMax_Processes__c> wizardStepsForWizard = new  List<SVMXC__ServiceMax_Processes__c>(); 

            wizardStepsForWizard = wizard.SVMXC__ServiceMax_Processes2__r; 

            if(wizardStepsForWizard != null && wizardStepsForWizard.size() > 0){
                // BAC-3695 - Anchal Updated if condition to check if the logged-in User is associated to any servicemax profile or not
                if(lstWizardAccess != null && lstWizardAccess.size () > 0 && String.isNotBlank(userSVMXProfileId)){
                    for(SVMXC__ServiceMax_Config_Data__c wizardAccess: wizard.SVMXC__ServiceMax_Config_Data__r){
                        if(userSVMXProfileId.equalsIgnoreCase(String.valueOf(wizardAccess.SVMXC__Access_Configuration_Profile__c))){
                            mapWizardRecords.put(wizard.Id, wizard);
                            
                            // Get all Wizard List
                            lstWizardSteps.addALL(wizardStepsForWizard);

                            // Only qualified wizards should be translated
                            lstWizards.add(wizard);

                            // Get the NamedExpressions as well
                            if(wizard.SVMXC__Submodule__c != null ){
                                setNamedExpressionIds.add(wizard.SVMXC__Submodule__c);      
                            }
                        }
                    }    
                }
                else{
                    mapWizardRecords.put(wizard.Id, wizard);

                    // Get all Wizard List
                    lstWizardSteps.addALL(wizardStepsForWizard);

                    // Only qualified wizards should be translated
                    lstWizards.add(wizard);

                    // Get the NamedExpressions as well
                    if(wizard.SVMXC__Submodule__c != null ){
                        setNamedExpressionIds.add(wizard.SVMXC__Submodule__c);      
                    }
                }    
            }
        }

        System.debug( LoggingLevel.DEBUG, 'List of Wizards - ' + lstWizards );
        System.debug( LoggingLevel.DEBUG, 'List of Wizard Steps - ' + lstWizardSteps );
        System.debug( LoggingLevel.DEBUG, 'Map of Wizard - ' + mapWizardRecords.size() );

        // Apply the Application filters
        APFT_Utilities.getInstance().applyApplicationFilters( lstWizards, deviceType );
        
        
        I18N_TranslationDelivery objTranslnUtil;
        String TranslationKeys = '';

        Set <Id> setAppFilteredWizardIds = new Set <Id>();

        
        if(lstWizards != null && lstWizards.size() > 0 ){
            
            /* Start - Logic to translate SFM Wizard Definition  */
            String strTranslationKeys = '';
            for(SVMXC__ServiceMax_Processes__c WizardRec : lstWizards)
            {
                if(WizardRec.SVMXC__Tag_Keys__c != NULL && WizardRec.SVMXC__Tag_Keys__c.length() > 0)
                    strTranslationKeys += WizardRec.SVMXC__Tag_Keys__c;

                setAppFilteredWizardIds.add(WizardRec.id);
            }
            objTranslnUtil = new I18N_TranslationDelivery(strTranslationKeys, UserInfo.getLanguage());
            lstWizards = objTranslnUtil.SVMX_GetProcessTranslation(lstWizards);
            /* End */
        }
      
        // Application filter applied for Wizard steps and is then translated. 
        APFT_Utilities.getInstance().applyApplicationFilters( lstWizardSteps, deviceType );
        
        /* Start - Logic to translate SFM Wizard Steps */
        if(lstWizardSteps != NULL && lstWizardSteps.size() > 0 && objTranslnUtil != NULL)
            lstWizardSteps = objTranslnUtil.SVMX_GetProcessTranslation(lstWizardSteps);
        /* End  */
        
        System.debug( LoggingLevel.DEBUG, 'Translation Performed - ' );

        for (SVMXC__ServiceMax_Processes__c qr : lstWizardSteps) {
            
            if(setAppFilteredWizardIds.contains(qr.SVMXC__Module__c)){
                mapWizardStepRecords.put(qr.Id, qr);
            
                List<SVMXC__ServiceMax_Processes__c> lstTempWizardSteps = new List<SVMXC__ServiceMax_Processes__c>();
                
                if(mapWizardIdStepsList.containsKey(qr.SVMXC__Module__c)) 
                    lstTempWizardSteps = mapWizardIdStepsList.get(qr.SVMXC__Module__c);
                lstTempWizardSteps.add(qr);

                mapWizardIdStepsList.put(qr.SVMXC__Module__c, lstTempWizardSteps);

                if(qr.SVMXC__Action_Type__c == 'OTHERS')
                {
                    lstIdsForOtherAction.add(qr.SVMXC__Process__c);
                }

                if(qr.SVMXC__Submodule__c != null)
                    setNamedExpressionIds.add(qr.SVMXC__Submodule__c);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'Expressions  - ' + setNamedExpressionIds.size() );

        
        System.debug('lstIdsForOtherAction:'+lstIdsForOtherAction);
        
        // Build the map of Other Action Ids and Records(i.e. Action Definition records) for the action ids identified above
        List<SVMXC__ServiceMax_Processes__c> lstOtherActions = new List<SVMXC__ServiceMax_Processes__c>();
        for (SVMXC__ServiceMax_Processes__c otherActions : [Select  SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Window_Height__c, SVMXC__Window_Width__c, SVMXC__Description__c, 
                                                                SVMXC__Source_Object_Name__c, SVMXC__Active__c, SVMXC__Target_Type__c, SVMXC__Target_URL__c, SVMXC__IsStandard__c, SVMXC__Show_Scrollbars__c, 
                                                                    SVMXC__Open_As_Full_Window__c,SVMXC__Mode_Of_Execution__c,SVMXC__Handover__c, SVMXC__Custom_action_Type__c, SVMXC__Enable_Confirmation_Dialog__c, SVMXC__Confirmation_Message__c,
                                                                    (Select Id, SVMXC__Object_Name__c, SVMXC__Parameter_Name__c, SVMXC__Parameter_Type__c, SVMXC__Parameter_Value__c, SVMXC__Expression_Rule__c, 
                                                                        SVMXC__Dispatch_Process__c, SVMXC__Lookup_Field_API_Name__c 
                                                                        From SVMXC__ServiceMax_Config_Data__r 
                                                                        WHERE RecordType.Name = 'SF Action Parameter' )
                                                            FROM SVMXC__ServiceMax_Processes__c 
                                                            WHERE Id =: lstIdsForOtherAction]){

            mapOtherActionRecords.put(otherActions.id, otherActions);
            List<SVMXC__ServiceMax_Config_Data__c> tempLstOfParameters = new List<SVMXC__ServiceMax_Config_Data__c>();
            tempLstOfParameters = otherActions.SVMXC__ServiceMax_Config_Data__r;
            mapOtherActionIdsParamsList.put(otherActions.id, tempLstOfParameters);

            Map<String, Schema.SObjectField> fieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(recordObjectName); //#defectFix

                                                                
            for (SVMXC__ServiceMax_Config_Data__c actionParam : tempLstOfParameters){
                if(actionParam.SVMXC__Parameter_Type__c.equalsIgnoreCase('FIELD NAME')){   
                    if(actionParam.SVMXC__Parameter_Value__c != null && fieldMap.containsKey(actionParam.SVMXC__Parameter_Value__c))  //#defectFix
                        setFieldAPINames.add((actionParam.SVMXC__Parameter_Value__c).ToUpperCase());
                }
                else if(actionParam.SVMXC__Parameter_Type__c.equalsIgnoreCase('FIELD SOURCE') && actionParam.SVMXC__Lookup_Field_API_Name__c != null && actionParam.SVMXC__Parameter_Value__c != null && fieldMap.containsKey(actionParam.SVMXC__Lookup_Field_API_Name__c)){ //#defectFix
                    setFieldAPINames.add((actionParam.SVMXC__Lookup_Field_API_Name__c +'.'+ actionParam.SVMXC__Parameter_Value__c).ToUpperCase());
                }
            }
            System.debug('setFieldAPINames: '+setFieldAPINames);
            System.debug('otherActions id : '+otherActions.id);
        }
        
        System.debug( LoggingLevel.DEBUG, 'Other Actions  - ' + mapOtherActionRecords.size() );
        System.debug( LoggingLevel.DEBUG, 'Other Actions Parameters - ' + mapOtherActionIdsParamsList.size() );
        System.debug( LoggingLevel.DEBUG, 'Field API names - ' + setFieldAPINames );

                        
        // Data for named expression has been retrieved in the steps above. Use that to get named expression details
        SVMX_getNamedExpressionDetails();
        
        // Build a comma separated list of all the fields used in either action parameter or in named expression details
        fieldString = ' ';
        
        for (String field : setFieldAPINames)
        {
            if(!String.isBlank(fieldString))
                fieldString += ', ' + field;
            else
                fieldString += field;
        }
        
        System.debug( LoggingLevel.DEBUG, 'Field List String - ' + fieldString );
        System.debug('recordObjectName :'+recordObjectName );
        System.debug('recordId:'+recordId);
        if(!String.isBlank(fieldString))
        {
            System.debug('query -- ' + 'Select ' + fieldString + ' from ' + recordObjectName + ' Where Id =: recordId');
            record = database.query('Select ' + fieldString + ' from ' + recordObjectName + ' Where Id =: recordId');
            
        }
        
        System.debug( LoggingLevel.DEBUG, 'Record - ' + record );

        
        // Parse Named Expression for SFW and Actions
        if(setNamedExpressionIds != null && setNamedExpressionIds.size() > 0)
            mapExprIdIsMatched = SVMX_ParseNamedExpressions(record, mapExprIdIsMatched); 


       

        // Get the list of wizard layouts
        lstWizardLayouts = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstWizardLayouts = [Select Id, SVMXC__Dispatch_Process__c, SVMXC__Object_Name__c, SVMXC__Wizard_Layout_Row__c, SVMXC__Wizard_Layout_Column__c, 
                        SVMXC__Button_size__c From SVMXC__ServiceMax_Config_Data__c 
                        Where SVMXC__Object_Name__c = : recordObjectName
                        And RecordType.Name = 'Wizard Layout' 
                        Order By SVMXC__Wizard_Layout_Column__c ASC, SVMXC__Wizard_Layout_Row__c ASC];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        system.debug(LoggingLevel.DEBUG, ' List of wizard layouts: ' + lstWizardLayouts);

        // Add WIzard IDs to set 
        setQualifiedWizardIds.addALL(mapWizardIdStepsList.keySet());
        return null;
    }

    public SVMXC.COMM_Utils_V2.COMM_ExpressionParsing oExpressionParsing = new SVMXC.COMM_Utils_V2.COMM_ExpressionParsing();
    // It is used to get the Expression rows.
    List<SVMXC__ServiceMax_Config_Data__c> lstExpressionRows = new list<SVMXC__ServiceMax_Config_Data__c>();
        
    
    // Get the details of all the named expressions related to the SF Wizard & Wizard steps identified for the record id
    public void SVMX_getNamedExpressionDetails()
    {
        // Get the definition for all the relevant named expressions
        String strExpDefQuery = 'Select Id, Name, SVMXC__Sequence__c, SVMXC__Source_Object_Name__c, SVMXC__Name__c, SVMXC__SettingId__c, SVMXC__Description__c, SVMXC__Advance_Expression__c, SVMXC__Parent_Object_Criteria__c';
            strExpDefQuery += ' From SVMXC__ServiceMax_Processes__c ';
            strExpDefQuery += ' Where Recordtype.Name=\'SVMX Rule\' AND SVMXC__Rule_Type__c = \'Named Expression\' AND Id IN :setNamedExpressionIds';
        lstNamedExpDefintion = database.query(strExpDefQuery);
        mapNamedExpDefinition.putAll(lstNamedExpDefintion);
        
        
        // Get the expression rows for all the above named expressions
        String strExpRowQuery ='Select SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__RecordType_Name__c,SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Inventory_Process__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, Name, Id, SVMXC__Field_Relationship_Name__c, SVMXC__FKey_Name_Field__c ';
            strExpRowQuery += ' From SVMXC__ServiceMax_Config_Data__c ';
            strExpRowQuery += ' where Recordtype.Name = \'Expressions\' AND SVMXC__Expression_Type__c = \'EXP_Named\' And SVMXC__Expression_Rule__c IN :setNamedExpressionIds';
        lstExpressionRows = database.query(strExpRowQuery);
        //system.debug('17. Definition records of the relevant named expressions: ' + mapNamedExpDefinition);

        
        // Add the API Names of the fields used in the named expression rows to the set of field API Names
        for(SVMXC__ServiceMax_Config_Data__c ExpDetailRec :lstExpressionRows)
        {
            if(ExpDetailRec.SVMXC__Field_Name__c != null )
                setFieldAPINames.add((ExpDetailRec.SVMXC__Field_Name__c).ToUpperCase());
            
            if(ExpDetailRec.SVMXC__Display_Type__c == 'REFERENCE' )
                 setFieldAPINames.add((ExpDetailRec.SVMXC__Field_Relationship_Name__c + '.' + ExpDetailRec.SVMXC__FKey_Name_Field__c).ToUpperCase());
        }
    }

    // Using inline parsing to avoid 101 error



    public Map<Id, Boolean> SVMX_ParseNamedExpressions(SObject sRecord, Map<Id, Boolean> parseResultMap)
    {   
        Map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEntRuleExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();

        for(SVMXC__ServiceMax_Config_Data__c oExp :lstExpressionRows){
            if(!mapEntRuleExpression.containsKey(oExp.SVMXC__Expression_Rule__c))
                mapEntRuleExpression.put(oExp.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
            mapEntRuleExpression.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
        }
        
         //Fixed defect 043293 : below varibale using in class COMM_Utils_V2  and method SVMX_ExpressionParsing to check expression is wizard load expression
        isWizardExpression = true;
        
        for(SVMXC__ServiceMax_Processes__c NamedExprRec: lstNamedExpDefintion)
        {
            boolean NamedExpressionQualified = false;
            try
            {
                /*if(NamedExprRec.Id != null && mapNamedExpDefinition.get(NamedExprRec.Id) != null )
                {
                    String strWhereClause = mapNamedExpDefinition.get(NamedExprRec.Id).SVMXC__Parent_Object_Criteria__c;
                    List<SObject> RecordList = database.query('Select ' + fieldString +' from '+ recordObjectName + ' Where Id =: recordId And ( ' + strWhereClause + ' ) ' );
                    if(RecordList != null && RecordList.size() > 0 )
                        NamedExpressionQualified = true;
                }*/
                
                /* * BAC-3605 - Instead of querying records, we will be using existing Expression parsing utility to 
                 *   qualify the records. 
                 * */
                
                system.debug(NamedExprRec.Id);
                NamedExpressionQualified = new COMM_Utils_V2.COMM_ExpressionParsing().SVMX_ExpressionParsing(record, mapEntRuleExpression.get(NamedExprRec.Id), NamedExprRec.SVMXC__Advance_Expression__c);
                   
            }
            catch(Exception ex){}
            
            parseResultMap.put(NamedExprRec.Id, NamedExpressionQualified);
        }
       //defect 043293
        isWizardExpression = false;
        return parseResultMap;
    } 

    // Build the HTML based on the data prepared by SVMXC_Generate_SFW_Utils
    public String SVMX_Generate_SFW_HTML(String recId, String callSource)
    {
        
        Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('SFW001');
        String SFWStr = '';  
        String buttonClass = '';
        Integer rowNumber = 1;
        Integer colNumber = 1;
        String strColor = '#000000';
        String strColorInactive = '#000000';
        if(svmxSettingList.containsKey('SET001') && svmxSettingList.get('SET001') != null )
        {
            strColor = svmxSettingList.get('SET001');
            strColor = strColor.replace('&', '&amp;');
            strColor = strColor.replace('\'', '\\\'');
            strColor = strColor.replace('<', '&lt;');
            strColor = strColor.replace('>', '&gt;');
            strColor = strColor.replace('"', '&quot;');
        }
        
        if(svmxSettingList.containsKey('SET002') && svmxSettingList.get('SET002') != null )
        {
            strColorInactive = svmxSettingList.get('SET002');
            strColorInactive = strColorInactive.replace('&', '&amp;');
            strColorInactive = strColorInactive.replace('\'', '\\\'');
            strColorInactive = strColorInactive.replace('<', '&lt;');
            strColorInactive = strColorInactive.replace('>', '&gt;');
            strColorInactive = strColorInactive.replace('"', '&quot;');
        }
        
        Map<String, String> SFWGroupHTML = new Map<String, String>();
        List<Integer> lstColOneQualifiedWizardRows = new List<Integer>();
        List<Integer> lstColTwoQualifiedWizardRows = new List<Integer>();

        if(lstWizardLayouts != null && lstWizardLayouts.size() > 0 )
        {
            if(lstWizardLayouts[0].SVMXC__Button_size__c == 'Small')
                buttonClass = 'smallbtn';
            else if(lstWizardLayouts[0].SVMXC__Button_size__c == 'Medium')
                buttonClass = 'mediumbtn';
            else
                buttonClass = 'largebtn';
        }

        // Building TD blocks for each qualified SFW with Actions, and populate this info in a map of position & TD block HTML string, i.e. <Row:Col, html for wizard>
        for (SVMXC__ServiceMax_Config_Data__c qr : lstWizardLayouts)
        {
            SFWStr =''; 
            
            if(setQualifiedWizardIds.contains(qr.SVMXC__Dispatch_Process__c) )
            {
                SVMXC__ServiceMax_Processes__c SFWRec = mapWizardRecords.get(qr.SVMXC__Dispatch_Process__c);
                // BAC-4055 Security Fix for XSS volubility 
                String sfwName = SVMX_SpecialCharParsing(SFWRec.SVMXC__Name__c);
                // If Show Criteria is not available for the SFW or if it is available & matches, then include the SFW
                if((SFWRec.SVMXC__Submodule__c == null) || (mapExprIdIsMatched.containsKey(SFWRec.SVMXC__Submodule__c) &&  mapExprIdIsMatched.get(SFWRec.SVMXC__Submodule__c)))
                {
                    // Build the title section for the wizard
                    if(SFWRec.SVMXC__Description__c != NULL)
                        SFWStr += '   <td class="td1" title="' + SVMX_SpecialCharParsing(SFWRec.SVMXC__Description__c) + '">';
                    else
                      SFWStr += '   <td class="td1" title="' + SVMX_SpecialCharParsing(SFWRec.SVMXC__Name__c) + '">';

                    SFWStr += '     <table id="tab1c" width="100%">';
                    if(qr.SVMXC__Button_size__c == 'Small')
                        SFWStr += '         <caption class="cap_small">' + sfwName+ '</caption>'; // BAC-4055 Security Fix for XSS volubility 
                    else if(qr.SVMXC__Button_size__c == 'Medium')
                        SFWStr += '         <caption class="cap_medium">' + sfwName + '</caption>';// BAC-4055 Security Fix for XSS volubility 
                    else if(qr.SVMXC__Button_size__c == 'Large')
                        SFWStr += '         <caption class="cap_large">' +sfwName + '</caption>';// BAC-4055 Security Fix for XSS volubility 
                    else
                        SFWStr += '         <caption class="cap_medium">' + sfwName + '</caption>';// BAC-4055 Security Fix for XSS volubility 
                    SFWStr += '     </table>';
                    SFWStr += '     <table id="tab"' + rowNumber + colNumber + '>';
                    SFWStr += '         <tr class="odd">';

                    // Get all the wizard steps, i.e., actions for the current SFW
                    List<SVMXC__ServiceMax_Processes__c> SFWActions = new List<SVMXC__ServiceMax_Processes__c>();
                    if(mapWizardIdStepsList.containsKey(qr.SVMXC__Dispatch_Process__c))
                    {
                        SFWActions = mapWizardIdStepsList.get(qr.SVMXC__Dispatch_Process__c);
                        for(SVMXC__ServiceMax_Processes__c action : SFWActions)
                        {
                            String modeofexecution='';
                            String winType = ''; 
                            String winWidth = '600'; 
                            String winHeight = '500'; 
                            String winScroll = 'no';
                            String fullscreen = 'no';
                            String processid = '';
                            String strWizardStepDesc = SVMX_SpecialCharParsing(action.SVMXC__Description__c != NULL ? action.SVMXC__Description__c : action.SVMXC__Name__c);
                            
                            // If Action Criteria is not available for the Wizard Step or if it is available & matches, then include the Action button as enabled
                            if((action.SVMXC__Submodule__c == null) || (mapExprIdIsMatched.containsKey(action.SVMXC__Submodule__c) &&  mapExprIdIsMatched.get(action.SVMXC__Submodule__c)) )
                            {
                                processid =action.id;
                                System.debug('processid : '+processid);
                                System.debug('action.SVMXC__Action_Type__c : '+action.SVMXC__Action_Type__c);
                                System.debug('action.SVMXC__Action_Type__c.toUpperCase() : '+action.SVMXC__Action_Type__c.toUpperCase());
                                System.debug('action.SVMXC__Select_Template_At_Runtime__c : '+action.SVMXC__Select_Template_At_Runtime__c);
                                System.debug('action.SVMXC__Mode_Of_Execution__c: '+ action.SVMXC__Mode_Of_Execution__c);
                                if (action.SVMXC__Action_Type__c != null && action.SVMXC__Action_Type__c.toUpperCase() == 'OUTPUT_DOCUMENT' && action.SVMXC__Select_Template_At_Runtime__c)
                                {
                                    // Defect 26111 Fix
                                    SFWStr += '<td><input type="button" class="svmxbtn ' + buttonClass + ' enabledbtn" title=" ' + strWizardStepDesc + '" value="' + SVMX_SpecialCharParsing(action.SVMXC__Name__c)  + '" onclick="SVMX_LaunchThis(\'/apex/SVMXC__OPDOC_TemplateSelection?SVMX_processId=' + recordId+'\',\'\',\'\',\'\',\'\',\'\')"  style="color:'+strColor+'">';
                                    //SFWStr += '<td><input type="button" class="svmxbtn ' + buttonClass + ' enabledbtn" title=" ' + strWizardStepDesc + '" value="' + action.SVMXC__Name__c + '" onclick="SVMX_LaunchThis(\'/apex/SVMXC__OPDOC_TemplateSelection?SVMX_processId=\' + recordId,\'\',\'\',\'\',\'\',\'\')"  style="color:'+strColor+'">';  
                                    //SFWStr += '<td><input type="button" class="svmxbtn ' + buttonClass + ' enabledbtn" title=" ' + strWizardStepDesc + '" value="' + action.SVMXC__Name__c + '" onclick="SVMX_LaunchRunTimeOutPutDoc(\''+String.escapeSingleQuotes(getTag001())+'\',\''+String.escapeSingleQuotes(getTag002())+'\',\''+String.escapeSingleQuotes(getTag003())+'\',\''+String.escapeSingleQuotes(getTag004())+'\')"  style="color:'+strColor+'">';  
                                }
                                else
                                {                               
                                    if(action.SVMXC__Action_Type__c != null && action.SVMXC__Action_Type__c.toUpperCase() == 'OTHERS' &&  action.SVMXC__Process__c != null && mapOtherActionRecords != null && mapOtherActionRecords.containsKey(action.SVMXC__Process__c) && mapOtherActionRecords.get(action.SVMXC__Process__c) != null)
                                    {
                                        SVMXC__ServiceMax_Processes__c otherActDef = mapOtherActionRecords.get(action.SVMXC__Process__c);
                                        if(otherActDef != null)
                                        {
                                            if(otherActDef.SVMXC__Target_Type__c != null)
                                                winType = otherActDef.SVMXC__Target_Type__c;
                                            if(otherActDef.SVMXC__Window_Width__c != null)
                                                winWidth = String.valueOf(otherActDef.SVMXC__Window_Width__c);
                                            if(otherActDef.SVMXC__Window_Height__c != null)
                                                winHeight = String.valueOf(otherActDef.SVMXC__Window_Height__c);
                                            if(otherActDef.SVMXC__Show_Scrollbars__c)
                                                winScroll = 'yes';
                                            if(otherActDef.SVMXC__Open_As_Full_Window__c)
                                                fullscreen = 'yes';


                                        }
                                    }
                                    String strMsg;
                                    boolean enableDialogBox = false;
                                    if(action.SVMXC__Confirmation_Message__c != null && action.SVMXC__Confirmation_Message__c.normalizeSpace().length() > 0)
                                    {
                                        enableDialogBox = true;
                                        strMsg = action.SVMXC__Confirmation_Message__c;
                                        strMsg = strMsg.replace('&', '&amp;');
                                        strMsg = strMsg.replace('\'', '\\\'');
                                        strMsg = strMsg.replace('<', '&lt;');
                                        strMsg = strMsg.replace('>', '&gt;');
                                        strMsg = strMsg.replace('"', '&quot;');
                                    }
                                    if(action.SVMXC__Mode_Of_Execution__c!=null)
                                    {
                                        modeofexecution=action.SVMXC__Mode_Of_Execution__c;
                                    }
                                    // BAC-4055 Security Fix for XSS volubility 
                                    SFWStr += '             <td><input type="button" class="svmxbtn ' + buttonClass + ' enabledbtn" title=" ' +  strWizardStepDesc + '" value="' + SVMX_SpecialCharParsing(action.SVMXC__Name__c) + '" onclick="SVMX_doConfirmAndNavigate(' + enableDialogBox +',\'' + strMsg +'\',\'' + SVMX_GenerateActionUrl(action, callSource) +'\', \''+winType+'\', \''+winWidth+'\' , \''+winHeight+'\', \''+winScroll+'\' , \''+fullscreen+'\' , \''+processid+'\', \''+modeofexecution+'\')" style="color:'+strColor+'" >';  
                                }
                                //SVMXC__Enable_Confirmation_Dialog__c, SVMXC__Confirmation_Message__c
                                    // Sharad, 23/May/2012: these change is for confirmation box when we click on proccess on wizard 
                            }
                            // Include the Action button as disabled
                            else
                                SFWStr += '             <td><input type="button" class="svmxbtn ' + buttonClass + ' disabledbtn" disabled="true" title=" ' + strWizardStepDesc + '" value="' + SVMX_SpecialCharParsing(action.SVMXC__Name__c) + '"  style="color:'+strColorInactive+'"   >';
                            SFWStr += '</input></td>';
                        }
                    }
                    SFWStr += '         </tr>';
                    SFWStr += '     </table>';
                    SFWStr += '   </td>';
                    String posIndex = '';

                    // Populate the map of position & TD block HTML string, i.e. <Row:Col, html for wizard>
                    if(qr.SVMXC__Wizard_Layout_Row__c != null && qr.SVMXC__Wizard_Layout_Column__c != null )
                    {
                        posIndex = String.valueOf(Math.Round(qr.SVMXC__Wizard_Layout_Row__c)) + ':' + String.valueOf(Math.Round(qr.SVMXC__Wizard_Layout_Column__c)) ;
                        SFWGroupHTML.put(posIndex, SFWStr);
                        if(Math.Round(qr.SVMXC__Wizard_Layout_Column__c) == 1 )
                            lstColOneQualifiedWizardRows.add(Math.Round(qr.SVMXC__Wizard_Layout_Row__c));
                        else if(Math.Round(qr.SVMXC__Wizard_Layout_Column__c) == 2 )
                            lstColTwoQualifiedWizardRows.add(Math.Round(qr.SVMXC__Wizard_Layout_Row__c));
                    }

                }
            }
        }
        if(lstColOneQualifiedWizardRows == null || (lstColOneQualifiedWizardRows != null && lstColOneQualifiedWizardRows.size() == 0))
        {
          lstColOneQualifiedWizardRows.addAll(lstColTwoQualifiedWizardRows);
          lstColTwoQualifiedWizardRows.clear();
          Map<String, String> TempSFWGroupHTML = new Map<String, String>();
          for(String PosIndex :SFWGroupHTML.keyset())
          {
            if(PosIndex.endswith(':2'))
              TempSFWGroupHTML.put(PosIndex.split(':')[0] + ':1',SFWGroupHTML.get(PosIndex));
            else
              TempSFWGroupHTML.put(PosIndex, SFWGroupHTML.get(PosIndex));
          }
          SFWGroupHTML.clear();
          SFWGroupHTML.putAll(TempSFWGroupHTML);
        }

        // Iterate and build the HTML for the entire wizard section, skipping not applicable items in each column
            SFWStr = '<table id="tbcontainer" width="100%">';
            Integer totalRowsToDraw = 0;
            if(lstColOneQualifiedWizardRows.size() > lstColTwoQualifiedWizardRows.size())
                totalRowsToDraw = lstColOneQualifiedWizardRows.size();
            else
                totalRowsToDraw = lstColTwoQualifiedWizardRows.size();
                
            for(Integer i = 0; i < totalRowsToDraw; i++)
            {
                SFWStr += ' <tr>';
                // Put the ith available wizard in column 1
                if(( i < lstColOneQualifiedWizardRows.size()) && (SFWGroupHTML.containsKey(String.valueOf(lstColOneQualifiedWizardRows[i]) + ':1')))
                    SFWStr += SFWGroupHTML.get(String.ValueOf(lstColOneQualifiedWizardRows[i]) + ':1');
                else
                    SFWStr += '<td></td>';
                // Put the ith available wizard in column 2
                if((i < lstColTwoQualifiedWizardRows.size()) && (SFWGroupHTML.containsKey(String.valueOf(lstColTwoQualifiedWizardRows[i]) + ':2')))
                    SFWStr += SFWGroupHTML.get(String.valueOf(lstColTwoQualifiedWizardRows[i]) + ':2');
                else 
                    SFWStr += '<td></td>';       
                SFWStr += ' </tr>';
            }
            SFWStr += '</table>';
        
        return SFWStr;
    }

    private String SVMX_SpecialCharParsing(String inputString)  
    {
        if(inputString != NULL && inputString.length() > 0)
        {
            inputString = inputString.replace('&', '&amp;');
            inputString = inputString.replace('\'', '&apos;');
            inputString = inputString.replace('<', '&lt;');
            inputString = inputString.replace('>', '&gt;');
            inputString = inputString.replace('"', '&quot;');
        }
        return inputString;
    }
    
    // Build the Action URL based on the action type
    public String SVMX_GenerateActionUrl(SVMXC__ServiceMax_Processes__c action, String source)
    {
       
        String actionUrl = '';
        if(action.SVMXC__Action_Type__c == null) return actionUrl;
        if (action.SVMXC__Action_Type__c.toUpperCase() == 'INVENTORY')
        {
            //Added check for story BAC-5963 : If setting is true UI shoud be old invetory otherwise a new react based invetory
            if(isOldInventoryUIEnabled)
            {
                actionUrl = '/apex/SVMXC__INVT_SmartEngine?hdrId=' + recordId + '&SMid=' + action.SVMXC__Process__r.SVMXC__ProcessId__c;       
            }else{
                actionUrl = '/apex/SVMXC__INVT_InventoryTransaction?hdrId=' + recordId + '&SMid=' + action.SVMXC__Process__r.SVMXC__ProcessId__c;  
            }
        }
        else if (action.SVMXC__Action_Type__c.toUpperCase() == 'SFM')
        {
            String strfinalPageName;
            if(action.SVMXC__Mode_Of_Execution__c == 'Background'){
                strfinalPageName = 'SVMXC__SFM_TDM_Delivery';
            }
            else{
                //BAC-6188 React Delivery Change
                strfinalPageName = strPageName;
                if(isLegacyDeliveryEnabled && isSFMLightning){
                    strfinalPageName = 'SVMXC__SFMDeliveryReactConsole';
                }
            }
            
            actionUrl = '/apex/'+strfinalPageName+'?SVMX_recordId=' + recordId + '&SVMX_action='+action.SVMXC__Action_Type__c.toUpperCase() +'&SVMX_processId=' + action.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
            
            //start-19th Dec 2011-Shashank
            if(action.SVMXC__Mode_Of_Execution__c == 'Background')
                actionUrl = actionUrl + '&SVMX_Execution_Mode=SVMXAUTO';
                    
            if(action.SVMXC__Handover__c == true)
                actionUrl = actionUrl + '&SVMX_NxtStepID=' + action.SVMXC__Process1__c; //+'&SVMX_retURL=/' + recordId;
            
            //Added for the task BAC-5229
            if(isJwtEnabled){
                actionUrl = actionUrl + '&SVMX_JWTEnabled=' + isJwtEnabled;
            }
            
            //Added for the task
            if(isCorsEnabled){
                actionUrl = actionUrl + '&SVMX_CORS_Enabled=' + isCorsEnabled;
            }
            
            //Added for the task
            if(isSFMLightning){
                actionUrl = actionUrl + '&SVMX_IsSFMLightning=' + isSFMLightning;
            }
            
            //Added for the task
            if(isStatisticsEnabled){
                actionUrl = actionUrl + '&SVMX_IsStatisticsEnabled=' + isStatisticsEnabled;
            }
            
            actionUrl = actionUrl + '&SVMX_AppInstanceName=' + appInstanceName;
            
        //end-19th Dec 2011-Shashank    
        }
        else if(action.SVMXC__Action_Type__c.toUpperCase() == 'CHECKLIST'){
            actionUrl = '/apex/'+strPageName+'?SVMX_recordId=' + recordId + '&SVMX_action='+action.SVMXC__Action_Type__c.toUpperCase() +'&SVMX_processId=' + action.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
        }
        else if (action.SVMXC__Action_Type__c.toUpperCase() == 'OTHERS' && action.SVMXC__Process__c != null)
        {   SVMXC__ServiceMax_Processes__c otherAction = new SVMXC__ServiceMax_Processes__c();
            if(source.equalsIgnoreCase('preview')){
                otherAction = [select id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Window_Height__c, SVMXC__Window_Width__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Active__c, SVMXC__Target_Type__c, SVMXC__Target_URL__c, SVMXC__IsStandard__c, SVMXC__Show_Scrollbars__c, SVMXC__Open_As_Full_Window__c, SVMXC__Custom_Action_Type__c from SVMXC__ServiceMax_Processes__c Where Id =: action.SVMXC__Process__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }else{
                otherAction = new SVMXC__ServiceMax_Processes__c(ID = action.SVMXC__Process__c);
                otherAction.SVMXC__Name__c = action.SVMXC__Process__r.SVMXC__Name__c;
                otherAction.SVMXC__ProcessID__c = action.SVMXC__Process__r.SVMXC__ProcessID__c;
                otherAction.SVMXC__Window_Height__c = action.SVMXC__Process__r.SVMXC__Window_Height__c;
                otherAction.SVMXC__Window_Width__c = action.SVMXC__Process__r.SVMXC__Window_Width__c;
                otherAction.SVMXC__Description__c = action.SVMXC__Process__r.SVMXC__Description__c;
                otherAction.SVMXC__Source_Object_Name__c = action.SVMXC__Process__r.SVMXC__Source_Object_Name__c;
                otherAction.SVMXC__Active__c = action.SVMXC__Process__r.SVMXC__Active__c;
                otherAction.SVMXC__Target_Type__c = action.SVMXC__Process__r.SVMXC__Target_Type__c;
                otherAction.SVMXC__Target_URL__c = action.SVMXC__Process__r.SVMXC__Target_URL__c;
                otherAction.SVMXC__IsStandard__c = action.SVMXC__Process__r.SVMXC__IsStandard__c;
                otherAction.SVMXC__Show_Scrollbars__c = action.SVMXC__Process__r.SVMXC__Show_Scrollbars__c;
                otherAction.SVMXC__Open_As_Full_Window__c = action.SVMXC__Process__r.SVMXC__Open_As_Full_Window__c;
                otherAction.SVMXC__Custom_Action_Type__c = action.SVMXC__Process__r.SVMXC__Custom_Action_Type__c;
            }
            system.debug('8. Action Process: ' + otherAction + ' and the Target URL is: ' + otherAction.SVMXC__Target_URL__c);
            if(otherAction != null)
            {
                String actUrl = '';
                
                
                String strActnType = otherAction.SVMXC__Custom_action_Type__c;
                if(strActnType == 'Web-Service')
                {
                    String encoded = EncodingUtil.urlEncode(action.SVMXC__Name__c, 'UTF-8');
                    // 14th March 2018, removed .. prefix from /apex.
                    actUrl += '/apex/SVMXC__SFM_ExecuteAPEX';
                    actUrl += '?SVMX_recordId='+ recordId;
                    actUrl += '&SVMX_title='+ encoded;
                    actUrl += '&SVMX_processId='+ otherAction.SVMXC__ProcessId__c;
                }
                else
                {
                    String fieldString1 = '';
                    String SOQLStr='';
                    actUrl += otherAction.SVMXC__Target_URL__c;

                    if(recordObjectName != null && recordObjectName.length() > 0 && recordId != null )
                    {
                        Set<String> setFieldAPINames = new Set<String>();
                        List<SVMXC__ServiceMax_Config_Data__c> lstActionParams = new List<SVMXC__ServiceMax_Config_Data__c>();
                        
                        //Added by Manish for defect 040668 fix
                        if(mapOtherActionIdsParamsList != null && mapOtherActionIdsParamsList.size()> 0 && mapOtherActionIdsParamsList.containsKey(otherAction.Id)){
                            lstActionParams = mapOtherActionIdsParamsList.get(otherAction.Id);
                        }
                        else{
                            lstActionParams = [Select Id, SVMXC__Object_Name__c, SVMXC__Parameter_Name__c, SVMXC__Parameter_Type__c, SVMXC__Parameter_Value__c, SVMXC__Expression_Rule__c, SVMXC__Dispatch_Process__c, SVMXC__Lookup_Field_API_Name__c From SVMXC__ServiceMax_Config_Data__c Where SVMXC__Dispatch_Process__c =: otherAction.Id AND RecordType.Name = 'SF Action Parameter' AND SVMXC__Dispatch_Process__c != null];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        }
                        
                        system.debug('9. Action Process Parameters List: ' + lstActionParams + ' and the size of the List is: ' + lstActionParams.size());

                        //Added by Manish for defect 040668 fix
                        //If record is present then use that otherwise query recrod and use it.
                        sObject rec;
                        if(record != null){
                            rec = record;
                            System.debug('Record Found: '+rec);
                        }
                        else{
                            if(lstActionParams != null && lstActionParams.size() > 0)
                            {
                                for(SVMXC__ServiceMax_Config_Data__c p : lstActionParams)
                                {
                                    if(p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD NAME')

                                    {   
                                        if(p.SVMXC__Parameter_Value__c != null )
                                            setFieldAPINames.add((p.SVMXC__Parameter_Value__c).ToUpperCase());
                                    }
                                    else if(p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD SOURCE' && p.SVMXC__Lookup_Field_API_Name__c != null && p.SVMXC__Parameter_Value__c != null){
                                        setFieldAPINames.add((p.SVMXC__Lookup_Field_API_Name__c +'.'+ p.SVMXC__Parameter_Value__c).ToUpperCase());
                                    }
                                }
                            }

                            if(setFieldAPINames != null && setFieldAPINames.size() > 0)
                            {

                                fieldString1 = '';
                                for (String field : setFieldAPINames)
                                {
                                    if(fieldString1 != '')
                                        fieldString1 += ', ' + field;
                                    else
                                        fieldString1 += field;
                                }
                            }

                            system.debug('10. Fields to be Queried: ' + fieldString1);
                            //sObject rec;


                            if(recordObjectName!= null && recordObjectName.length() > 0 && fieldString1 != '')
                            {

                                SOQLStr = 'select '+ fieldString1 + ' from ' + recordObjectName + ' where ' + 'id =\'' + recordId + '\'';
                                system.debug('11. Query String: ' + SOQLStr);
                                rec = database.query(SOQLStr);
                                system.debug('12. Record Queried: ' + rec);
                            }
                        }
                        
                        
                        if (lstActionParams != null)
                        {
                            Integer parameterCount = 0;
			    Map<String, Object> valueMap = rec.getPopulatedFieldsAsMap(); //#defectFix 
                            for (SVMXC__ServiceMax_Config_Data__c p : lstActionParams)
                            {
                                If (parameterCount == 0)
                                    actUrl += '?';
                                else
                                    actUrl += '&';
                                    
                                actUrl += p.SVMXC__Parameter_Name__c + '=';
                                if (p.SVMXC__Parameter_Type__c.toUpperCase() == 'VALUE')
                                    //actUrl += p.SVMXC__Parameter_Value__c;
                                    actUrl += EncodingUtil.urlEncode(p.SVMXC__Parameter_Value__c, 'UTF-8');
                                else if (p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD NAME'){
                                    if(valueMap.containsKey(p.SVMXC__Parameter_Value__c) && rec.get(p.SVMXC__Parameter_Value__c) != null){
                                        //actUrl += rec.get(p.SVMXC__Parameter_Value__c);
                                   	 actUrl += EncodingUtil.urlEncode(String.valueOf(rec.get(p.SVMXC__Parameter_Value__c)), 'UTF-8');
                                    }
                                }
                                else if(p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD SOURCE'){
                                    //Added by Sathish for story BAC-4914
                                    
                                    String lkpFieldValue = null;
                                    if(valueMap.containsKey(p.SVMXC__Lookup_Field_API_Name__c)){
                                        lkpFieldValue = String.valueOf(rec.getSObject(p.SVMXC__Lookup_Field_API_Name__c).get(p.SVMXC__Parameter_Value__c));
                                    }
                                    
                                    if(lkpFieldValue != null && lkpFieldValue != ''){
                                        actUrl += EncodingUtil.urlEncode(lkpFieldValue, 'UTF-8');
                                    }
                                    else{
                                        actUrl += EncodingUtil.urlEncode('', 'UTF-8');
                                    }
                                }    
                                parameterCount ++;
                            }
                            system.debug('13. URL created: ' + actUrl);
                        }
                    }
                    
                }
                actionUrl = actionUrl+actUrl;
            }
            else
                actionUrl = '/' + recordId;
            
            
            
            
            if(action.SVMXC__Handover__c == true && action.SVMXC__Process1__c != null)
                actionUrl = actionUrl + '&SVMX_NxtStepID=' + action.SVMXC__Process1__c;
            system.debug('URL: ' + actionUrl);
        }
                    
        else if(action.SVMXC__Action_Type__c.toUpperCase() == 'RECEIPT')
        {
            actionUrl = '/apex/SVMXC__APL_ProcessReceipts?SVMX_processId=' + action.SVMXC__Process__r.SVMXC__ProcessId__c + '&SVMX_recordID='+recordId + '&SVMX_retURL=/' + recordId;
            //start-19th Dec 2011-Shashank
            if(action.SVMXC__Handover__c == true)
                actionUrl = actionUrl + '&SVMX_NxtStepID=' + action.SVMXC__Process1__c;
            //end-19th Dec 2011-Shashank    
        }
        else if(action.SVMXC__Action_Type__c.toUpperCase() == 'DELIVERY')
        {
            actionUrl = '/apex/SVMXC__APL_DeliveryOnReceipt?SVMX_recordId=' + recordId + '&SVMX_processId=' + action.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
            //start-19th Dec 2011-Shashank
            if(action.SVMXC__Handover__c == true)
                actionUrl = actionUrl + '&SVMX_NxtStepID=' + action.SVMXC__Process1__c;
            //end-19th Dec 2011-Shashank
        }
        else if(action.SVMXC__Action_Type__c.toUpperCase() == 'SHIP')
        {
            actionUrl = '/apex/SVMXC__APL_ConfirmShipment?SVMX_recordId=' + recordId + '&SVMX_processId=' + action.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
            //start-19th Dec 2011-Shashank
            if(action.SVMXC__Handover__c == true)
                actionUrl = actionUrl + '&SVMX_NxtStepID=' + action.SVMXC__Process1__c;
            //end-19th Dec 2011-Shashank
        }
        else if(action.SVMXC__Action_Type__c.toUpperCase() == 'PICK_MOVE')
        {
            actionUrl = '/apex/SVMXC__APL_PickAndMove?SVMX_recordId=' + recordId + '&SVMX_processId=' + action.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
            //start-19th Dec 2011-Shashank
            if(action.SVMXC__Handover__c == true)
                actionUrl = actionUrl + '&SVMX_NxtStepID=' + action.SVMXC__Process1__c;
            //end-19th Dec 2011-Shashank
        }
        else if(action.SVMXC__Action_Type__c.toUpperCase() == 'INITIATE_RETURN')
        {
            actionUrl = '/apex/SVMXC__APL_InitiateReturn?SVMX_recordId=' + recordId + '&SVMX_processId=' + action.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
            //start-19th Dec 2011-Shashank
            if(action.SVMXC__Handover__c == true)
                actionUrl = actionUrl + '&SVMX_NxtStepID=' + action.SVMXC__Process1__c;
            //end-19th Dec 2011-Shashank
        }
        else if(action.SVMXC__Action_Type__c.toUpperCase() == 'FULFILLMENT')
        {
            actionUrl = '/apex/SVMXC__APL_FulfillmentConsole?SVMX_recordId=' + recordId + '&SVMX_processId=' + action.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
            //start-19th Dec 2011-Shashank
            if(action.SVMXC__Handover__c == true)
                actionUrl = actionUrl + '&SVMX_NxtStepID=' + action.SVMXC__Process1__c;
            //end-19th Dec 2011-Shashank
        }
        else if(action.SVMXC__Action_Type__c.toUpperCase() == 'OUTPUT_DOCUMENT')
        {
            // 14th March 2018, removed .. prefix from /apex.
            actionUrl = '/apex/SVMXC__OPDOC_Delivery?SVMX_recordId=' + recordId +'&SVMX_processId=' + action.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
        }


        COMM_SVMXC_Utils2 objCls = new COMM_SVMXC_Utils2();
        actionUrl = objCls.GetCommunityPrefix(actionUrl);
        // defect fixed 040403
        actionUrl = actionUrl.replace('+','%20');
        return actionUrl;   
    }

    // Return Wrapper class with data for Lightning
    public SFM_Wizard_LightningController.RecordWizard getSFWLightningWrapper(String recId){
        SFM_Wizard_LightningController.RecordWizard recWizard = new SFM_Wizard_LightningController.RecordWizard();
        
        Map<ID, List<SFM_Wizard_LightningController.WizardStep>> mapValidWizardIDStepList = new Map<ID, List<SFM_Wizard_LightningController.WizardStep>>();
        Map<ID, SVMXC__ServiceMax_Processes__c> mapValidWizIDRecord = new  Map<ID, SVMXC__ServiceMax_Processes__c>();

        Map<String, List<SFM_Wizard_LightningController.WizardStep>> sequenceSFW = new Map<String, List<SFM_Wizard_LightningController.WizardStep>>();
        Map <String, ID> mapWizSequenceID = new Map <String, ID>();
        List<Integer> lstColOneQualifiedWizardRows = new List<Integer>();
        List<Integer> lstColTwoQualifiedWizardRows = new List<Integer>();

        //-----Start-----Added for lightning container as part of task BAC-5219---------//
        Boolean isJwtEnabled = false;
        Boolean isSFMLightning = false;
        Boolean isCorsEnabled = false;
        Boolean isStatisticsEnabled = false;
        String appInstanceName = SFMDeliveryController.getInstanceName();
        
        COMM_Utils_ManageSettings objManageSettings = new COMM_Utils_ManageSettings();
        Map<String,Map<String,String>> mapAllSubmoduleSettings = objManageSettings.SVMX_getSettingList(new List<String>{'SFM002','COMM004', 'GLOB001'});
        
        Map<String, String> mapGlobalSettings = new Map<String, String>();

        if(mapAllSubmoduleSettings != null){
            mapGlobalSettings = mapAllSubmoduleSettings.get('GLOB001');
        }
        if((mapGlobalSettings != null && mapGlobalSettings.containsKey('GBL039') && mapGlobalSettings.get('GBL039') != null && Boolean.valueOf(mapGlobalSettings.get('GBL039')) == true) && Site.getSiteId() != null){
            isJwtEnabled = true;
        }
        if(mapGlobalSettings != null && mapGlobalSettings.containsKey('GBL043') && mapGlobalSettings.get('GBL043') != null && Boolean.valueOf(mapGlobalSettings.get('GBL043')) == true){
            isCorsEnabled = true;
        }
        
        Map<String,String> mapSettings = mapAllSubmoduleSettings.get('SFM002');
        if(mapSettings != null && mapSettings.containsKey('SET004') && mapSettings.get('SET004') != null && mapSettings.get('SET004').equalsIgnoreCase('Lightning')){
            isSFMLightning = true;
        }
        
        mapSettings = mapAllSubmoduleSettings.get('COMM004');
        if(mapSettings != null && mapSettings.containsKey('SET001') && mapSettings.get('SET001') != null && mapSettings.get('SET001').equalsIgnoreCase('Allow')){
            isStatisticsEnabled = true;
        }
        //-----End-----Added for lightning container as part of task BAC-5219-----------//
        
        for (SVMXC__ServiceMax_Config_Data__c qr : lstWizardLayouts){
            if(setQualifiedWizardIds.contains(qr.SVMXC__Dispatch_Process__c)){
                SVMXC__ServiceMax_Processes__c wizRec = mapWizardRecords.get(qr.SVMXC__Dispatch_Process__c);
                if((wizRec.SVMXC__Submodule__c == null) || (mapExprIdIsMatched.containsKey(wizRec.SVMXC__Submodule__c) &&  mapExprIdIsMatched.get(wizRec.SVMXC__Submodule__c))){

                    List<SFM_Wizard_LightningController.WizardStep> lstWizardStepWrapper = new List<SFM_Wizard_LightningController.WizardStep>();
                    
                    for(SVMXC__ServiceMax_Processes__c wizStepRec: mapWizardIdStepsList.get(wizRec.id)){
                        
                        SFM_Wizard_LightningController.WizardStep wizStep = new SFM_Wizard_LightningController.WizardStep();

                        wizStep.modeofexecution='';
                        wizStep.winType = ''; 
                        wizStep.winWidth = '600'; 
                        wizStep.winHeight = '500'; 
                        wizStep.winScroll = 'no';
                        wizStep.fullscreen = 'no';
                        wizStep.processid = '';
                        wizStep.selectTemplateAtRuntime = false;
                        wizStep.actionType = wizStepRec.SVMXC__Action_Type__c; 
                        
                        wizStep.isDisabled = wizStepRec.SVMXC__Submodule__c == null || (mapExprIdIsMatched.containsKey(wizStepRec.SVMXC__Submodule__c) &&  mapExprIdIsMatched.get(wizStepRec.SVMXC__Submodule__c)) ? false: true;
                        wizStep.name =  wizStepRec.SVMXC__Name__c;

                        //---------Start----------Added for lightning container as part of task BAC-5219------//
                        String strActionURL = SVMX_GenerateActionUrl(wizStepRec, 'wizload');
                        if(isJwtEnabled){
                            strActionURL = strActionURL + '&SVMX_JWTEnabled=' +isJwtEnabled;
                        }
                        if(isCorsEnabled){
                            strActionURL = strActionURL + '&SVMX_CORS_Enabled=' +isCorsEnabled;
                        }
                        if(isSFMLightning){
                            strActionURL = strActionURL + '&SVMX_IsSFMLightning=' +isSFMLightning;
                        }
                        //Added for the task
                        if(isStatisticsEnabled){
                            strActionURL = strActionURL + '&SVMX_IsStatisticsEnabled=' + isStatisticsEnabled;
                        }
                        strActionURL = strActionURL + '&SVMX_AppInstanceName=' + appInstanceName;
                        wizStep.actionURL = strActionURL;
                        //---------End-----------Added for lightning container as part of task BAC-5219------//
                        
                        //wizStep.actionURL = SVMX_GenerateActionUrl(wizStepRec, 'wizload');
                        wizStep.isConfirmationMessageEnabled = false;
                        if(String.isNotBlank(wizStepRec.SVMXC__Description__c))
                            wizStep.description =  wizStepRec.SVMXC__Description__c;
                        else
                            wizStep.description = wizStepRec.SVMXC__Name__c;
                        
                        if(!wizStep.isDisabled){
                            // Checking for confirmation message
                            if(wizStepRec.SVMXC__Confirmation_Message__c != null && wizStepRec.SVMXC__Confirmation_Message__c.normalizeSpace().length() > 0){
                                wizStep.isConfirmationMessageEnabled = true;
                                wizStep.confirmationMessage = wizStepRec.SVMXC__Confirmation_Message__c;
                            }

                            // Implementing logic for custom Actions
                            if(wizStepRec.SVMXC__Action_Type__c != null && wizStepRec.SVMXC__Action_Type__c.equalsIgnoreCase('others') &&  wizStepRec.SVMXC__Process__c != null && !mapOtherActionRecords.IsEmpty() && mapOtherActionRecords.containsKey(wizStepRec.SVMXC__Process__c) && mapOtherActionRecords.get(wizStepRec.SVMXC__Process__c) != null){
                                SVMXC__ServiceMax_Processes__c customActDef = mapOtherActionRecords.get(wizStepRec.SVMXC__Process__c);
                                if(customActDef != null)
                                {
                                    if(customActDef.SVMXC__Target_Type__c != null)
                                        wizStep.winType = customActDef.SVMXC__Target_Type__c;
                                    if(customActDef.SVMXC__Window_Width__c != null)
                                        wizStep.winWidth = String.valueOf(customActDef.SVMXC__Window_Width__c);
                                    if(customActDef.SVMXC__Window_Height__c != null)
                                        wizStep.winHeight = String.valueOf(customActDef.SVMXC__Window_Height__c);
                                    if(customActDef.SVMXC__Show_Scrollbars__c)
                                        wizStep.winScroll = 'yes';
                                    if(customActDef.SVMXC__Open_As_Full_Window__c)
                                        wizStep.fullscreen = 'yes';

                                }
                            }
                            
                            // Logic of selecting template at run time for output document
                            if (wizStepRec.SVMXC__Action_Type__c != null && wizStepRec.SVMXC__Action_Type__c.equalsIgnoreCase('OUTPUT_DOCUMENT') && wizStepRec.SVMXC__Select_Template_At_Runtime__c){
                                wizStep.selectTemplateAtRuntime = wizStepRec.SVMXC__Select_Template_At_Runtime__c; 
                            }
                        }
                        
                        lstWizardStepWrapper.add(wizStep) ;
                    }

                    String posIndex = '';
                    // Populate the map of position & TD block HTML string, i.e. <Row:Col, html for wizard>
                    if(qr.SVMXC__Wizard_Layout_Row__c != null && qr.SVMXC__Wizard_Layout_Column__c != null )
                    {
                        posIndex = String.valueOf(Math.Round(qr.SVMXC__Wizard_Layout_Row__c)) + ':' + String.valueOf(Math.Round(qr.SVMXC__Wizard_Layout_Column__c)) ;
                        mapWizSequenceID.put(posIndex, wizRec.id); 
                        if(Math.Round(qr.SVMXC__Wizard_Layout_Column__c) == 1 )
                            lstColOneQualifiedWizardRows.add(Math.Round(qr.SVMXC__Wizard_Layout_Row__c));
                        else if(Math.Round(qr.SVMXC__Wizard_Layout_Column__c) == 2 )
                            lstColTwoQualifiedWizardRows.add(Math.Round(qr.SVMXC__Wizard_Layout_Row__c));
                    }
                    
                    mapValidWizardIDStepList.put(wizRec.id, lstWizardStepWrapper); 
                    mapValidWizIDRecord.put(wizRec.id, wizRec);
                }
            }
        }
        
        Integer totalRowsToDraw = 0;
        if(lstColOneQualifiedWizardRows.size() > lstColTwoQualifiedWizardRows.size())
            totalRowsToDraw = lstColOneQualifiedWizardRows.size();
        else
            totalRowsToDraw = lstColTwoQualifiedWizardRows.size();

        Map<ID, SVMXC__ServiceMax_Processes__c> mapSequencedWizIDRecord = new  Map<ID, SVMXC__ServiceMax_Processes__c>();

        for(Integer i = 0; i < totalRowsToDraw; i++){
            // Put the ith available wizard in column 1
            if(( i < lstColOneQualifiedWizardRows.size()) && (mapWizSequenceID.containsKey(String.valueOf(lstColOneQualifiedWizardRows[i]) + ':1')))
                mapSequencedWizIDRecord.put(mapWizSequenceID.get(String.valueOf(lstColOneQualifiedWizardRows[i]) + ':1'), mapValidWizIDRecord.get(mapWizSequenceID.get(String.valueOf(lstColOneQualifiedWizardRows[i]) + ':1')));
            
            // Put the ith available wizard in column 2
            if((i < lstColTwoQualifiedWizardRows.size()) && (mapWizSequenceID.containsKey(String.valueOf(lstColTwoQualifiedWizardRows[i]) + ':2')))
                mapSequencedWizIDRecord.put(mapWizSequenceID.get(String.valueOf(lstColTwoQualifiedWizardRows[i]) + ':2'), mapValidWizIDRecord.get(mapWizSequenceID.get(String.valueOf(lstColTwoQualifiedWizardRows[i]) + ':2')));
            
        }
       
            

        recWizard.mapWizIdWizSteps = mapValidWizardIDStepList; 
        recWizard.mapWizIdRecord = mapSequencedWizIDRecord; 
        return recWizard;
    }



    // Return SFW info in a wrapper - used when SFW info is requested through WS, e.g. by iPad App
    public SVMXC.INTF_WebServicesDef.INTF_Response_SFWInfo getSFWWrapper(SFM_WrapperDef.SFM_Request prequest)
    {
        String rId;
        List<String> ActionTypeValueLst;
        List<SFM_WrapperDef.SFM_StringMap> inputKeyValues = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringListMap> inputKey_Valuelst = new List<SFM_WrapperDef.SFM_StringListMap>();

        // Get the record Id from input key value pairs
        inputKeyValues = prequest.stringMap;
        //system.debug('20. getSFWWrapper input key value pairs: ' + inputKeyValues);
        for(SFM_WrapperDef.SFM_StringMap req: inputKeyValues)
        {
            if(req.key.toUpperCase() == 'RECORDID')
                rId = req.value;
        }

        // Get the Action Type from input key value list pairs
        inputKey_Valuelst = prequest.stringListMap;
        //system.debug('21. getSFWWrapper input key value list pairs: ' + inputKey_Valuelst);
        for(SFM_WrapperDef.SFM_StringListMap req: inputKey_Valuelst)
        {
            if(req.key.toUpperCase() == 'ACTIONTYPE')
                ActionTypeValueLst = req.valueList;
        }
        setActionTypeValues.clear();
        if(ActionTypeValueLst != null )
            setActionTypeValues.addAll(ActionTypeValueLst);

        // Prepare all the data for all the SFW's applicable to the rId passed
        SVMXC_Generate_SFW_Utils(rId, null);
        
        // Set record id and object name - these are the first two members of the response object
        SVMXC.INTF_WebServicesDef.INTF_Response_SFWInfo SFWResponse = new SVMXC.INTF_WebServicesDef.INTF_Response_SFWInfo();
        SFWResponse.ObjectName = recordObjectName;
        SFWResponse.RecordId = recordId;
        
        //modify code for introduce new member for holding all output doc templates
        ServiceFlowWizard_Utils objSFWUtils = new ServiceFlowWizard_Utils();
        Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_SfmOutputDocActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        Map_SfmOutputDocActions = objSFWUtils.SVMX_GetSFMOutputDocActions(recordObjectName);
        if(Map_SfmOutputDocActions != null && Map_SfmOutputDocActions.containsKey(recordObjectName))
        {
            SFWResponse.availableActions = Map_SfmOutputDocActions.get(recordObjectName);
        }
        //calling funcation for resolve all other action parameters
        getResloveOtherActnParams();
        
        // Build a map of wizard ids and wizard layout records
        Map<Id, SVMXC__ServiceMax_Config_Data__c> Map_SFWId_LayoutRecord = new Map<Id, SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c SFWLayoutRecd: lstWizardLayouts)
        {
            Map_SFWId_LayoutRecord.put(SFWLayoutRecd.SVMXC__Dispatch_Process__c, SFWLayoutRecd);
        }

        // Loop through the qualified and matched wizards, and get their action details, position (row & column) of the wizard in the layout
        List<SVMXC.INTF_WebServicesDef.SFM_SFWInfo> SFWInfoLst = new List<SVMXC.INTF_WebServicesDef.SFM_SFWInfo>();
        SVMXC__ServiceMax_Processes__c objWizard;
        Id wizardCriteriaId;
        for (Id i : setQualifiedWizardIds)
        {
            objWizard = mapWizardRecords.get(i);
            if (objWizard == null) continue;
            wizardCriteriaId = objWizard.SVMXC__Submodule__c;
            if ( wizardCriteriaId == null || (mapExprIdIsMatched.containsKey(wizardCriteriaId) && mapExprIdIsMatched.get(wizardCriteriaId)) )
            {
                // Get the list of actions for the current wizard, and get the named expression match result for each action
                List<SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo> sfmSFWactnLst = new List<SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo>();
                if(mapWizardIdStepsList.get(i) != null )
                {
                    for(SVMXC__ServiceMax_Processes__c ActnRec : mapWizardIdStepsList.get(i))
                    {
                        if(ActnRec.SVMXC__Action_Type__c == 'OTHERS')
                        {
                            if(MapOtherAction.containsKey(ActnRec.SVMXC__Process__c) )
                            {
                                if(MapStrngActnParam.containsKey(ActnRec.SVMXC__Process__c))
                                {
                                    sfmSFWactnLst.add(new SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo(ActnRec, mapExprIdIsMatched.get(ActnRec.SVMXC__Submodule__c) , MapOtherAction.get(ActnRec.SVMXC__Process__c), MapStrngActnParam.get(ActnRec.SVMXC__Process__c)));
                                }
                                else
                                    sfmSFWactnLst.add(new SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo(ActnRec, mapExprIdIsMatched.get(ActnRec.SVMXC__Submodule__c) , MapOtherAction.get(ActnRec.SVMXC__Process__c), new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>()));
                            }
                        }
                        else
                            sfmSFWactnLst.add(new SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo(ActnRec, mapExprIdIsMatched.get(ActnRec.SVMXC__Submodule__c)));
                    }
                }
                SVMXC.INTF_WebServicesDef.SFM_SFWInfo wrapperrec = new SVMXC.INTF_WebServicesDef.SFM_SFWInfo();
                wrapperrec.actions.addAll(sfmSFWactnLst);
                // Get the row and column of the current wizard
                wrapperrec.SFWDef = objWizard;
                if(Map_SFWId_LayoutRecord.get(i) != null )
                {
                    if(Map_SFWId_LayoutRecord.get(i).SVMXC__Wizard_Layout_Row__c != null )
                        wrapperrec.row = (Map_SFWId_LayoutRecord.get(i).SVMXC__Wizard_Layout_Row__c).intValue();
                    if(Map_SFWId_LayoutRecord.get(i).SVMXC__Wizard_Layout_Column__c != null )
                        wrapperrec.col = (Map_SFWId_LayoutRecord.get(i).SVMXC__Wizard_Layout_Column__c).intValue();
                }
                SFWInfoLst.add(wrapperrec);
            }
        }

        // All the information retrieved above is set as the third member of response object
        SFWResponse.SFWs = SFWInfoLst;
        //system.debug('22. SFW Response info (wrapper): ' + SFWResponse);
        return SFWResponse;
    }

    public void getResloveOtherActnParams()
    {
        List<String> lstIdsCustActn = new List<String>();
        MapOtherAction.putAll([select id, SVMXC__Name__c, SVMXC__Service_Namespace__c, SVMXC__Service_Class_Name__c, SVMXC__Service_Method_Name__c,  SVMXC__Parent_Error_Msg__c, SVMXC__ProcessID__c, SVMXC__Window_Height__c, SVMXC__Window_Width__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c,  SVMXC__Active__c, SVMXC__Target_Type__c, SVMXC__Target_URL__c, SVMXC__IsStandard__c, SVMXC__Show_Scrollbars__c, SVMXC__Open_As_Full_Window__c, SVMXC__Custom_Action_Type__c from SVMXC__ServiceMax_Processes__c Where Id In : lstIdsForOtherAction AND RecordType.Name = 'SF Action']);
        
        if(MapOtherAction != null && MapOtherAction.size() > 0)
        {
            for(String objActn : MapOtherAction.keySet())
                lstIdsCustActn.add(objActn);
            
            Set<String> setFieldAPINames = new Set<String>();
            List<SVMXC__ServiceMax_Config_Data__c> lstActionParams = new List<SVMXC__ServiceMax_Config_Data__c>();
            lstActionParams = [Select Id, SVMXC__Object_Name__c, SVMXC__Parameter_Name__c, SVMXC__Parameter_Type__c, SVMXC__Parameter_Value__c, SVMXC__Expression_Rule__c, SVMXC__Dispatch_Process__c, SVMXC__Lookup_Field_API_Name__c From SVMXC__ServiceMax_Config_Data__c Where SVMXC__Dispatch_Process__c In : lstIdsCustActn AND RecordType.Name = 'SF Action Parameter' AND SVMXC__Dispatch_Process__c != null];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            system.debug('9. Action Process Parameters List: ' + lstActionParams + ' and the size of the List is: ' + lstActionParams.size());
            try
            {
                if(lstActionParams != null && lstActionParams.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c p : lstActionParams)
                    {
                        if(p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD NAME')

                        {   
                            if(p.SVMXC__Parameter_Value__c != null )
                                setFieldAPINames.add((p.SVMXC__Parameter_Value__c).ToUpperCase());
                        }
                        else if(p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD SOURCE' && p.SVMXC__Lookup_Field_API_Name__c != null && p.SVMXC__Parameter_Value__c != null){
                            setFieldAPINames.add((p.SVMXC__Lookup_Field_API_Name__c +'.'+ p.SVMXC__Parameter_Value__c).ToUpperCase());
                        }
                    }
                }
                String fieldString1 = '';
                if(setFieldAPINames != null && setFieldAPINames.size() > 0)
                {

                    fieldString1 = '';
                    for (String field : setFieldAPINames)
                    {
                        if(fieldString1 != '')
                            fieldString1 += ', ' + field;
                        else
                            fieldString1 += field;
                    }
                }
                
                system.debug('10. Fields to be Queried: ' + fieldString1);
                sObject rec;


                if(recordObjectName!= null && recordObjectName.length() > 0 && fieldString1 != '' && recordId != null)
                {

                    String SOQLStr = 'select '+ fieldString1 + ' from ' + recordObjectName + ' where ' + 'id =\'' + recordId + '\'';
                    system.debug('11. Query String: ' + SOQLStr);
                    rec = database.query(SOQLStr);
                    system.debug('12. Record Queried: ' + rec);
                }
                
                if (lstActionParams != null)
                {
                    for (SVMXC__ServiceMax_Config_Data__c p : lstActionParams)
                    {
                        SVMXC.INTF_WebServicesDef.INTF_StringMap objStrngMap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                        if (p.SVMXC__Parameter_Type__c.toUpperCase() == 'VALUE')
                            objStrngMap = new SVMXC.INTF_WebServicesDef.INTF_StringMap(p.SVMXC__Parameter_Name__c, p.SVMXC__Parameter_Value__c);
                        else if (p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD NAME' && rec.get(p.SVMXC__Parameter_Value__c) != null)
                            objStrngMap = new SVMXC.INTF_WebServicesDef.INTF_StringMap(p.SVMXC__Parameter_Name__c, String.valueOf(rec.get(p.SVMXC__Parameter_Value__c)));
                        else if(p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD SOURCE'){
                            //Added by Sathish for story BAC-4914
                            Map<String, Object> valueMap = rec.getPopulatedFieldsAsMap();
                            String lkpFieldValue = null;
                            if(valueMap.containsKey(p.SVMXC__Lookup_Field_API_Name__c)){
                                lkpFieldValue = String.valueOf(rec.getSObject(p.SVMXC__Lookup_Field_API_Name__c).get(p.SVMXC__Parameter_Value__c));
                            }
                            if(lkpFieldValue != null && lkpFieldValue != ''){
                                objStrngMap = new SVMXC.INTF_WebServicesDef.INTF_StringMap(p.SVMXC__Parameter_Name__c, lkpFieldValue);
                            }
                            else{
                                objStrngMap = new SVMXC.INTF_WebServicesDef.INTF_StringMap(p.SVMXC__Parameter_Name__c, '');
                            }
                        }    
                            
                        if(MapStrngActnParam.containsKey(p.SVMXC__Dispatch_Process__c))
                            MapStrngActnParam.get(p.SVMXC__Dispatch_Process__c).add(objStrngMap);
                        else
                        {
                            List<SVMXC.INTF_WebServicesDef.INTF_StringMap> newlstStringMap = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                            newlstStringMap.add(objStrngMap);
                            MapStrngActnParam.put(p.SVMXC__Dispatch_Process__c, newlstStringMap);
                        }
                    }
                }
            }
            catch(Exception ex)
            {
                
            }
        }
    }
     
    public String getTag001(){ return System.Label.CONF016_TAG113;}//'Select Template'
    public String getTag002(){ return System.Label.CONF016_TAG114;}//'Genrat Report'
    public String getTag003(){ return system.label.CONF016_TAG032 ;}//'Cancel'
    public String getTag004(){ return System.Label.CONF016_TAG115;}//'No Template is available for this Object'
}