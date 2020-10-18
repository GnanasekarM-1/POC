public with sharing class I18N_TranslationDelivery 
{
    public Map<String, String> mapSVMXTranslations = new Map<String, String>();
    public Set<String> setTranslableProcessFields = new Set<String>();
    public Set<String> setTranslablePageLayoutFields = new Set<String>();
    public Set<String> setTranslablePageLayoutDetailFields = new Set<String>();
    public Set<String> setTranslableQuestionFields = new Set<String>();
    public Set<String> setTranslableQuestionResponseFields = new Set<String>();
    public Set<String> setTranslableQuestionResponseSetFields = new Set<String>();
    public Set<String> setTranslableQuestionDefaultAnswerFields = new Set<String>();
   
    public I18N_TranslationDelivery()
    {
        //Blank Constructor
    }
    
    
    /* Constructor - Get all the translatable fields value into the map */
    public I18N_TranslationDelivery(String ProcessTranslationKeys, String strLanguage)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('I18N_TranslationDelivery');      
        setTranslableProcessFields.add('SVMXC__Name__c');
        setTranslableProcessFields.add('SVMXC__Description__c');
        setTranslableProcessFields.add('SVMXC__Parent_Error_Msg__c');
        setTranslableProcessFields.add('SVMXC__Child_Error_Msg__c');
        setTranslableProcessFields.add('SVMXC__Confirmation_Message__c');
        setTranslablePageLayoutFields.add('SVMXC__Name__c');
        setTranslablePageLayoutFields.add('SVMXC__Page_Help__c');
        setTranslablePageLayoutDetailFields.add('SVMXC__Title__c');
        setTranslableQuestionFields.add('SVMXC__Question__c');
        setTranslableQuestionResponseFields.add('SVMXC__Response__c');
        setTranslableQuestionResponseSetFields.add('SVMXC__Response_Set_Values__c');
        setTranslableQuestionDefaultAnswerFields.add('SVMXC__SM_Default_Response__c');
        
        if(ProcessTranslationKeys != NULL && ProcessTranslationKeys.length() > 0)
        {
            List<SVMXC__ServiceMax_Tags__c> lstSVMXTag = new List<SVMXC__ServiceMax_Tags__c>();
            INTF_DataSync.logSOQL(intMethodCount, 'Select Name, SVMXC__Tag_Value__c, SVMXC__Tag_Key__c, SVMXC__Tag_Text__c From SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN: ProcessTranslationKeys.split(\';\') AND SVMXC__Tag_Key__c != NULL AND SVMXC__Language__c =: strLanguage');                                                
            lstSVMXTag = [Select Name, SVMXC__Tag_Value__c, SVMXC__Tag_Key__c, SVMXC__Tag_Text__c From SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN: ProcessTranslationKeys.split(';') AND SVMXC__Tag_Key__c != NULL AND SVMXC__Language__c =: strLanguage]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__ServiceMax_Tags__c SVMXTag : lstSVMXTag){
                mapSVMXTranslations.put(SVMXTag.SVMXC__Tag_Key__c, SVMXTag.SVMXC__Tag_Value__c);
            }
            
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'I18N_TranslationDelivery');          
    }
    
    /* Constructor - Get all the translatable fields value into the map - For Mobile Clients */
    public I18N_TranslationDelivery(List<String> processTranslationKeys, String strLanguage, boolean isMobile) //Passing the list of tag keys as parameter
    {
        if(isMobile){
            Integer intMethodCount = INTF_DataSync.logMethodStartTS('I18N_TranslationDelivery');      
            setTranslableProcessFields.add('SVMXC__Name__c');
            setTranslableProcessFields.add('SVMXC__Description__c');
            setTranslableProcessFields.add('SVMXC__Parent_Error_Msg__c');
            setTranslableProcessFields.add('SVMXC__Child_Error_Msg__c');
            setTranslableProcessFields.add('SVMXC__Confirmation_Message__c');
            setTranslablePageLayoutFields.add('SVMXC__Name__c');
            setTranslablePageLayoutFields.add('SVMXC__Page_Help__c');
            setTranslablePageLayoutDetailFields.add('SVMXC__Title__c');
            setTranslableQuestionFields.add('SVMXC__Question__c');
            setTranslableQuestionResponseFields.add('SVMXC__Response__c');
            setTranslableQuestionResponseSetFields.add('SVMXC__Response_Set_Values__c');
            setTranslableQuestionDefaultAnswerFields.add('SVMXC__SM_Default_Response__c');
            
            
            if(processTranslationKeys != NULL && processTranslationKeys.size() > 0)
                {
                    INTF_DataSync.logSOQL(intMethodCount, 'Select Name, SVMXC__Tag_Value__c, SVMXC__Tag_Key__c, SVMXC__Tag_Text__c From SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c != NULL AND SVMXC__Tag_Key__c IN: processTranslationKeys AND SVMXC__Language__c =: strLanguage');
                List<SVMXC__ServiceMax_Tags__c> lstSVMXTag = [Select Name, SVMXC__Tag_Value__c, SVMXC__Tag_Key__c, SVMXC__Tag_Text__c From SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c != NULL AND SVMXC__Tag_Key__c IN: processTranslationKeys AND SVMXC__Language__c =: strLanguage]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(SVMXC__ServiceMax_Tags__c SVMXTag : lstSVMXTag){
                    mapSVMXTranslations.put(SVMXTag.SVMXC__Tag_Key__c, SVMXTag.SVMXC__Tag_Value__c);
                }
            }
            INTF_DataSync.logMethodEndTS(intMethodCount, 'I18N_TranslationDelivery');   
        }       
    }
    
    //New Constructor added for supporting translation for the list of checklist process at delivery time
    public I18N_TranslationDelivery(List<String> lstProcessTranslationKeys, String strLanguage)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('I18N_TranslationDelivery');    
        setTranslableProcessFields.add('SVMXC__Name__c');
        setTranslableProcessFields.add('SVMXC__Description__c');
        setTranslableProcessFields.add('SVMXC__Parent_Error_Msg__c');
        setTranslableProcessFields.add('SVMXC__Child_Error_Msg__c');
        setTranslableProcessFields.add('SVMXC__Confirmation_Message__c');
        setTranslablePageLayoutFields.add('SVMXC__Name__c');
        setTranslablePageLayoutFields.add('SVMXC__Page_Help__c');
        setTranslablePageLayoutDetailFields.add('SVMXC__Title__c');
        setTranslableQuestionFields.add('SVMXC__Question__c');
        setTranslableQuestionResponseFields.add('SVMXC__Response__c');
        setTranslableQuestionResponseSetFields.add('SVMXC__Response_Set_Values__c');
        setTranslableQuestionDefaultAnswerFields.add('SVMXC__SM_Default_Response__c');       
       
        Set<String> setTagKeys = new Set<String>();
        for(String strTagKey : lstProcessTranslationKeys){
            setTagKeys.addAll(strTagKey.split(';'));
        }
        if(setTagKeys != NULL && setTagKeys.size() > 0)
        {
            List<SVMXC__ServiceMax_Tags__c> lstSVMXTag = new List<SVMXC__ServiceMax_Tags__c>();
            INTF_DataSync.logSOQL(intMethodCount, 'Select Name, SVMXC__Tag_Value__c, SVMXC__Tag_Key__c, SVMXC__Tag_Text__c From SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN: setTagKeys AND SVMXC__Tag_Key__c != NULL AND SVMXC__Language__c =: strLanguage');                                    
            lstSVMXTag = [Select Name, SVMXC__Tag_Value__c, SVMXC__Tag_Key__c, SVMXC__Tag_Text__c From SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN: setTagKeys AND SVMXC__Tag_Key__c != NULL AND SVMXC__Language__c =: strLanguage]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__ServiceMax_Tags__c SVMXTag : lstSVMXTag){
                mapSVMXTranslations.put(SVMXTag.SVMXC__Tag_Key__c, SVMXTag.SVMXC__Tag_Value__c);
            }
        }
        setTagKeys.clear();
        INTF_DataSync.logMethodEndTS(intMethodCount, 'I18N_TranslationDelivery');           
    }
    
    
    
  //added by Jaysukh for support translations for checklist default answer
    public List<SVMXC__SM_Default_Checklist_Response__c> SVMX_GetQuestionDefaultAnswerTranslation(List<SVMXC__SM_Default_Checklist_Response__c> listQBDefaultresponse)
    {
        try
        {
            for(SVMXC__SM_Default_Checklist_Response__c objQuestionDefChecklistResponse : listQBDefaultresponse)
            {
                objQuestionDefChecklistResponse = SVMX_GetQuestionDefaultAnswerTranslation(objQuestionDefChecklistResponse);
            }
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.WARN, 'Exception: ' + ex.getMessage());
        }
        return listQBDefaultresponse;
    }
  //added by Jaysukh for support translations for checklist default answer
    public SVMXC__SM_Default_Checklist_Response__c SVMX_GetQuestionDefaultAnswerTranslation(SVMXC__SM_Default_Checklist_Response__c objQuestionDefaultResp){
        for(String FieldName : setTranslableQuestionDefaultAnswerFields)
        {
            System.debug(LoggingLevel.WARN, 'FieldName: ' + FieldName);
            String strUniqueKey = '';
            List<String> lststrDefaultResValues =new List<String>();
            List<String> lstsetTranslatedValue = new List<String>();
            if(objQuestionDefaultResp.get(FieldName) != NULL)
            {
                System.debug(LoggingLevel.WARN, 'objQuestionDefaultResp.get(FieldName): ' + objQuestionDefaultResp.get(FieldName));
                String strTranslatedValue = '';
                String replacelstDefRespValue = '';
                String lstDefRespValue  = (String) objQuestionDefaultResp.get(FieldName);
                SFM_WrapperDef.SFM_DefaultResponseJSON obj = (SFM_WrapperDef.SFM_DefaultResponseJSON)JSON.deserialize(lstDefRespValue, SFM_WrapperDef.SFM_DefaultResponseJSON.class);
                if(obj.listOfDefaultValues !=null && obj.listOfDefaultValues.size() > 0)
                {
                  
                  //Added by Jaysukh for suporting translation all default responset type of question 
                   lststrDefaultResValues = obj.listOfDefaultValues;
                   for(integer i=0;i<lststrDefaultResValues.size();i++)
                   {
                     strUniqueKey=(lststrDefaultResValues[i].replaceAll(' ', '_')).toUpperCase();
                     if(mapSVMXTranslations.containsKey(strUniqueKey) && mapSVMXTranslations.get(strUniqueKey) != NULL && mapSVMXTranslations.get(strUniqueKey).length() > 0)
                     {
                         strTranslatedValue= mapSVMXTranslations.get(strUniqueKey);
                         lstDefRespValue = lstDefRespValue.replace(obj.listOfDefaultValues[i], strTranslatedValue);
                         
                         
                         // objQuestionDefaultResp.put(FieldName,replacelstDefRespValue);
                       }
                       
                   }
                   objQuestionDefaultResp.put(FieldName,lstDefRespValue);
                   
                     //strUniqueKey = (obj.listOfDefaultValues[0]).replaceAll(' ', '_');
                     //strUniqueKey = strUniqueKey.toUpperCase();
                     
                     //if(mapSVMXTranslations.containsKey(strUniqueKey) && mapSVMXTranslations.get(strUniqueKey) != NULL && mapSVMXTranslations.get(strUniqueKey).length() > 0){
                       //strTranslatedValue = mapSVMXTranslations.get(strUniqueKey);
                     //  replacelstDefRespValue = lstDefRespValue.replace(obj.listOfDefaultValues[0], strTranslatedValue);
                       // objQuestionDefaultResp.put(FieldName,replacelstDefRespValue);
                     //}
                }   
            }
        }
        
        return objQuestionDefaultResp;
    }
    
    /* Get all the translatable value for ServiceMax Process object's fields into the map */
    public List<SVMXC__ServiceMax_Processes__c> SVMX_GetProcessTranslation(List<SVMXC__ServiceMax_Processes__c> lstProcessData)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('SVMX_GetProcessTranslation');
        try
        {
            for(SVMXC__ServiceMax_Processes__c objProcessData : lstProcessData)
                objProcessData = SVMX_GetProcessTranslation(objProcessData);
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.WARN, 'Exception: ' + ex.getMessage());
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'SVMX_GetProcessTranslation');
        return lstProcessData;
    }
    
    
    /* Get all the translatable value for Page Layout object's fields into the map */
    public List<SVMXC__Page_Layout__c> SVMX_GetPageLayoutTranslation(List<SVMXC__Page_Layout__c> lstPageLayoutData)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('SVMX_GetPageLayoutTranslation');                
        try
        {
            for(SVMXC__Page_Layout__c objPageLayoutData : lstPageLayoutData)
                objPageLayoutData = SVMX_GetPageLayoutTranslation(objPageLayoutData);
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.WARN, 'Exception: ' + ex.getMessage());
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'SVMX_GetPageLayoutTranslation');                
        return lstPageLayoutData;
    }
    
    
    /* Get all the translatable value for Page Layout Detail object's fields into the map */
    public List<SVMXC__Page_Layout_Detail__c> SVMX_GetPageLayoutDetailTranslation(List<SVMXC__Page_Layout_Detail__c> lstPageLayoutDetail)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('SVMX_GetPageLayoutDetailTranslation');        
        try
        {
            for(SVMXC__Page_Layout_Detail__c objPageLayoutDetail : lstPageLayoutDetail)
                objPageLayoutDetail = SVMX_GetPageLayoutDetailTranslation(objPageLayoutDetail);
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.WARN, 'Exception: ' + ex.getMessage());
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'SVMX_GetPageLayoutDetailTranslation');        
        return lstPageLayoutDetail;
    }
    
    /* Get all the translatable value for Question object's fields into the map */
    public List<SVMXC__Question_Bank__c> SVMX_GetQuestionTranslation(List<SVMXC__Question_Bank__c> lstQuestion)
    {
        try
        {
            for(SVMXC__Question_Bank__c objQuestion : lstQuestion)
                objQuestion = SVMX_GetQuestionTranslation(objQuestion);
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.WARN, 'Exception: ' + ex.getMessage());
        }
        return lstQuestion;
    }
    
    /* Get all the translatable value for Question Response object's fields into the map */
    public List<SVMXC__QB_Response_Options__c> SVMX_GetQuestionResponseTranslation(List<SVMXC__QB_Response_Options__c> lstQuestionResponse)
    {
        try
        {
            for(SVMXC__QB_Response_Options__c objQuestionResponse : lstQuestionResponse)
                objQuestionResponse = SVMX_GetQuestionResponseTranslation(objQuestionResponse);
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.WARN, 'Exception: ' + ex.getMessage());
        }
        return lstQuestionResponse;
    }
    
    /* Get all the translatable value for Question Response seet object's fields into the map */
    public List<SVMXC__QB_Response_Set__c> SVMX_GetQuestionResponseSetTranslation(List<SVMXC__QB_Response_Set__c> lstQuestionResponseSet)
    {
        try
        {
            for(SVMXC__QB_Response_Set__c objQuestionResponseSet : lstQuestionResponseSet)
                objQuestionResponseSet = SVMX_GetQuestionResponseSetTranslation(objQuestionResponseSet);
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.WARN, 'Exception: ' + ex.getMessage());
        }
        return lstQuestionResponseSet;
    }
    
    /* Get all the translatable value for ServiceMax Process object's fields into the map */
    public SVMXC__ServiceMax_Processes__c SVMX_GetProcessTranslation(SVMXC__ServiceMax_Processes__c objProcessData)
    {
        for(String FieldName : setTranslableProcessFields)
        {
            String strUniqueKey = '';
            if(objProcessData.get(FieldName) != NULL)
            {
                if(FieldName == 'SVMXC__Description__c')
                {
                    strUniqueKey = GenerateCompositeKey(objProcessData) + '_DESC';
                    strUniqueKey = strUniqueKey.toUpperCase();
                    if(mapSVMXTranslations.containsKey(strUniqueKey) && mapSVMXTranslations.get(strUniqueKey) != NULL && mapSVMXTranslations.get(strUniqueKey).length() > 0)
                        objProcessData.put(FieldName, mapSVMXTranslations.get(strUniqueKey));
                }
                else
                {
                    strUniqueKey = String.valueOf(objProcessData.get(FieldName)).replaceAll(' ', '_');
                    strUniqueKey = strUniqueKey.toUpperCase();
                    if(mapSVMXTranslations.containsKey(strUniqueKey) && mapSVMXTranslations.get(strUniqueKey) != NULL && mapSVMXTranslations.get(strUniqueKey).length() > 0)
                        objProcessData.put(FieldName, mapSVMXTranslations.get(strUniqueKey));
                }
            }
        }
        return objProcessData;
    }
    
   
    /* Get all the translatable value for Page Layout object's fields into the map */
    public SVMXC__Page_Layout__c SVMX_GetPageLayoutTranslation(SVMXC__Page_Layout__c objPageLayoutData)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('SVMX_GetPageLayoutTranslation');         
        for(String FieldName : setTranslablePageLayoutFields)
        {
            String strUniqueKey = '';
            if(objPageLayoutData.get(FieldName) != NULL)
            {
                if(FieldName == 'SVMXC__Page_Help__c')
                    strUniqueKey = String.valueOf(objPageLayoutData.SVMXC__Page_Layout_ID__c) + '_PAGEHELP';
                else
                    strUniqueKey = String.valueOf(objPageLayoutData.get(FieldName)).replaceAll(' ', '_');
                
                strUniqueKey = strUniqueKey.toUpperCase();
                if(mapSVMXTranslations.containsKey(strUniqueKey) && mapSVMXTranslations.get(strUniqueKey) != NULL && mapSVMXTranslations.get(strUniqueKey).length() > 0)
                    objPageLayoutData.put(FieldName, mapSVMXTranslations.get(strUniqueKey));
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'SVMX_GetPageLayoutTranslation');        
        return objPageLayoutData;
    }
    
    
    /* Get all the translatable value for Page Layout Detail object's fields into the map */
    public SVMXC__Page_Layout_Detail__c SVMX_GetPageLayoutDetailTranslation(SVMXC__Page_Layout_Detail__c objPageLayoutDetail)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('SVMX_GetPageLayoutDetailTranslation');        
        for(String FieldName : setTranslablePageLayoutDetailFields)
        {
            System.debug(LoggingLevel.WARN, 'FieldName: ' + FieldName);
            String strUniqueKey = '';
            if(objPageLayoutDetail.get(FieldName) != NULL)
            {
                System.debug(LoggingLevel.WARN, 'objPageLayoutDetail.get(FieldName): ' + objPageLayoutDetail.get(FieldName));
                strUniqueKey = String.valueOf(objPageLayoutDetail.get(FieldName)).replaceAll(' ', '_');
                strUniqueKey = strUniqueKey.toUpperCase();
                if(mapSVMXTranslations.containsKey(strUniqueKey) && mapSVMXTranslations.get(strUniqueKey) != NULL && mapSVMXTranslations.get(strUniqueKey).length() > 0)
                    objPageLayoutDetail.put(FieldName, mapSVMXTranslations.get(strUniqueKey));
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'SVMX_GetPageLayoutDetailTranslation');        
        return objPageLayoutDetail;
    }
    
    /* Get all the translatable value for Question object's fields into the map */
    public SVMXC__Question_Bank__c SVMX_GetQuestionTranslation(SVMXC__Question_Bank__c objQuestion)
    {
        for(String FieldName : setTranslableQuestionFields)
        {
            System.debug(LoggingLevel.WARN, 'FieldName: ' + FieldName);
            String strUniqueKey = '';
            if(objQuestion.get(FieldName) != NULL)
            {
                System.debug(LoggingLevel.WARN, 'objQuestion.get(FieldName): ' + objQuestion.get(FieldName));
                strUniqueKey = String.valueOf(objQuestion.get(FieldName)).replaceAll(' ', '_');
                strUniqueKey = strUniqueKey.toUpperCase();
                if(mapSVMXTranslations.containsKey(strUniqueKey) && mapSVMXTranslations.get(strUniqueKey) != NULL && mapSVMXTranslations.get(strUniqueKey).length() > 0){
                    objQuestion.put(FieldName, mapSVMXTranslations.get(strUniqueKey));
                } 
            }
        }
        return objQuestion;
    }
    
    /* Get all the translatable value for Question Response object's fields into the map */
    public SVMXC__QB_Response_Options__c SVMX_GetQuestionResponseTranslation(SVMXC__QB_Response_Options__c objQuestionResponse)
    {
        for(String FieldName : setTranslableQuestionResponseFields)
        {
            System.debug(LoggingLevel.WARN, 'FieldName: ' + FieldName);
            String strUniqueKey = '';
            if(objQuestionResponse.get(FieldName) != NULL)
            {
                System.debug(LoggingLevel.WARN, 'objQuestionResponse.get(FieldName): ' + objQuestionResponse.get(FieldName));
                strUniqueKey = String.valueOf(objQuestionResponse.get(FieldName)).replaceAll(' ', '_');
                strUniqueKey = strUniqueKey.toUpperCase();
                if(mapSVMXTranslations.containsKey(strUniqueKey) && mapSVMXTranslations.get(strUniqueKey) != NULL && mapSVMXTranslations.get(strUniqueKey).length() > 0)
                    objQuestionResponse.put(FieldName, mapSVMXTranslations.get(strUniqueKey));
            }
        }
        return objQuestionResponse;
    }
    
    /* Get all the translatable value for Question Response Set object's fields into the map */
    public SVMXC__QB_Response_Set__c SVMX_GetQuestionResponseSetTranslation(SVMXC__QB_Response_Set__c objQuestionRespSet)
    {
        for(String FieldName : setTranslableQuestionResponseSetFields)
        {
            System.debug(LoggingLevel.WARN, 'FieldName: ' + FieldName);
            String strUniqueKey = '';
            if(objQuestionRespSet.get(FieldName) != NULL){
                System.debug(LoggingLevel.WARN, 'objQuestionRespSet.get(FieldName): ' + objQuestionRespSet.get(FieldName));
                String strTranslatedValue = '';
                List<String> lstRespValue = new List<String>();
                lstRespValue = String.valueOf(objQuestionRespSet.get(FieldName)).split(';');
                for(String strValue : lstRespValue){
                    strUniqueKey = strValue.replaceAll(' ', '_');
                    strUniqueKey = strUniqueKey.toUpperCase();
                    if(mapSVMXTranslations.containsKey(strUniqueKey) && mapSVMXTranslations.get(strUniqueKey) != NULL && mapSVMXTranslations.get(strUniqueKey).length() > 0)
                        strTranslatedValue += mapSVMXTranslations.get(strUniqueKey) + ';';
                    else
                        strTranslatedValue += strValue + ';';
                }
                if(strTranslatedValue != null && strTranslatedValue.length() > 0)
                    objQuestionRespSet.put(FieldName, strTranslatedValue);
            }
        }
        return objQuestionRespSet;
    }
    
    private String GenerateCompositeKey(SVMXC__ServiceMax_Processes__c SVMXObj)
    {
        String strCompositeKey = NULL;
        if(SVMXObj.SVMXC__Module__c != NULL && SVMXObj.SVMXC__Module__r.SVMXC__ProcessID__c != NULL && SVMXObj.SVMXC__ProcessID__c != NULL && ((SVMXObj.SVMXC__Record_Type_Name__c == 'Named Search' && SVMXObj.SVMXC__Rule_Type__c == 'SRCH_OBJECT') || SVMXObj.SVMXC__Record_Type_Name__c == 'Wizard Step'))
            strCompositeKey = SVMXObj.SVMXC__Module__r.SVMXC__ProcessID__c + '_' + SVMXObj.SVMXC__ProcessID__c;
        else
            strCompositeKey = SVMXObj.SVMXC__ProcessID__c;
        
        if(strCompositeKey != NULL && strCompositeKey.length() > 0)
            strCompositeKey = strCompositeKey.replaceAll(' ', '_');
        
        return strCompositeKey;
    }
    
    /* Method to update Process Id field for Searchable Objects (SFM Search) and Wizard Steps (SFM Wizards) to support translation */
    public void I18N_WizardStepsSearchObjsProcessIdUpdateRule()
    {
        try
        {
            List<SVMXC__ServiceMax_Processes__c> lstWizardStepsSearchObjs = new List<SVMXC__ServiceMax_Processes__c>();
            for(SVMXC__ServiceMax_Processes__c WizardStepsSearchObjs : [Select Name, SVMXC__ProcessID__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Record_Type_Name__c = 'Wizard Step' OR (SVMXC__Record_Type_Name__c = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_OBJECT') ORDER BY SVMXC__ProcessID__c ASC NULLS FIRST])
            {
                if(WizardStepsSearchObjs.SVMXC__ProcessID__c == NULL)
                {
                    WizardStepsSearchObjs.SVMXC__ProcessID__c = WizardStepsSearchObjs.Name;
                    lstWizardStepsSearchObjs.add(WizardStepsSearchObjs);
                }
                else
                    break;
            }
            
            System.debug(LoggingLevel.Warn, 'Updatable Records: ' + lstWizardStepsSearchObjs);
            if(lstWizardStepsSearchObjs != NULL && lstWizardStepsSearchObjs.size() > 0)
                update lstWizardStepsSearchObjs; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.Warn, 'Exception: ' + ex.getMessage());
        }
    }
}