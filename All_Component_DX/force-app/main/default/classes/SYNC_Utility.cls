public with sharing class SYNC_Utility
{
    SVMX_Constants clsConstant = new SVMX_Constants();
    I18N_TranslationDelivery translationObj;
    
    public class objectAccess
    {
        public set<String> transactionalObjects{get; set;}
        public set<String> lookupObjects{get; set;}
        public Map<String, set<String>> mapObjectProcess{get; set;}
        public Map<String, set<String>> mapProcessObject{get; set;}
        public Map<String, set<String>> mapLookupObjectProcess{get; set;}
        public Map<String, String> mapProcessPurpose{get; set;}
    }
    
    //For the given profiles, get all the allowed processes
    public Map<Id, SVMXC__ServiceMax_Processes__c> getSFMTransactions(String profileId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getSFMTransactions');
        INTF_GetServiceFlowAccess flowAccess = new INTF_GetServiceFlowAccess();
        Map<Id, SVMXC__ServiceMax_Processes__c> mapAllowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        mapAllowedProcess = flowAccess.INTF_getAllAllowedProcessed(profileId);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getSFMTransactions');
        return mapAllowedProcess;
    }
  
    //Get all transactional and lookup objects for the requested processes
    public objectAccess getSFMTxObjects(Map<Id, SVMXC__ServiceMax_Processes__c> processes)
    {
        objectAccess response = new objectAccess();
        INTF_GetServiceFlowAccess flowAccess = new INTF_GetServiceFlowAccess();
        flowAccess.INTF_GetProcessObjects(processes);
        if(flowAccess.transactionalObjects != NULL)
            response.transactionalObjects = flowAccess.transactionalObjects;
        if(flowAccess.lookupObjects != NULL)
            response.lookupObjects = flowAccess.lookupObjects;
        if(flowAccess.mapObjectProcess != NULL)
            response.mapObjectProcess = flowAccess.mapObjectProcess;
        if(flowAccess.mapProcessObject != NULL)
            response.mapProcessObject = flowAccess.mapProcessObject;
        if(flowAccess.mapLookupObjectProcess != NULL)
            response.mapLookupObjectProcess = flowAccess.mapLookupObjectProcess;
        if(flowAccess.mapProcessPurpose != NULL)
            response.mapProcessPurpose = flowAccess.mapProcessPurpose;
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getPicklistDefinitions(List<String> objects)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        Map<String, String> mapMessage = new Map<String, String>();
        try
        {
            Integer intLimitPercent = 70;
            List<String> lstSettingId = new list<String>{'SET011'};
            INTF_DataUtilityServices objDataUtil = new INTF_DataUtilityServices();
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            Map<String, String> mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
            
            if(mapSettingsForIPAD018 != null && mapSettingsForIPAD018.size() > 0 && mapSettingsForIPAD018.containskey('SET011') && mapSettingsForIPAD018.get('SET011') != null)
                intLimitPercent = integer.valueOf(mapSettingsForIPAD018.get('SET011'));
            else
                intLimitPercent = 70;
                
            List<INTF_WebServicesDef.SVMXMap> picklistDefinitions = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_GetObjectDefinition clsObjectDef = new INTF_GetObjectDefinition();
            set<String> processedObjects = new set<String>();
            Map<String, Set<String>> mapObjToPicklistFields = new Map<String, Set<String>>();
            List<SVMXC__Page_Layout_Detail__c> lstPageLayoutDetails = [SELECT SVMXC__Field_API_Name__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c FROM SVMXC__Page_Layout_Detail__c WHERE (SVMXC__DataType__c = 'picklist' OR SVMXC__DataType__c = 'multipicklist') AND SVMXC__Page_Layout__r.SVMXC__Object_Name__c IN:objects];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
            for(SVMXC__Page_Layout_Detail__c detail :lstPageLayoutDetails)
            {
                if(mapObjToPicklistFields.containsKey(detail.SVMXC__Page_Layout__r.SVMXC__Object_Name__c))
                    mapObjToPicklistFields.get(detail.SVMXC__Page_Layout__r.SVMXC__Object_Name__c).add(detail.SVMXC__Field_API_Name__c);
                else
                    mapObjToPicklistFields.put(detail.SVMXC__Page_Layout__r.SVMXC__Object_Name__c, new Set<String>{detail.SVMXC__Field_API_Name__c});
            }
            for(String objectName: objects)
            {
                clsObjectDef.objectName = objectName;
                if(mapObjToPicklistFields.containsKey(objectName))
                {
                    if(!objDataUtil.isLimitReached(intLimitPercent))
                    {
                        INTF_WebServicesDef.SVMXMap objPicklistDef = clsObjectDef.INTF_GetPicklistDefinition(mapObjToPicklistFields.get(objectName));
                        picklistDefinitions.add(objPicklistDef);
                        processedObjects.add(objectName);
                    }
                    else
                    {
                        break;
                    }
                    /*try
                    {
                        INTF_WebServicesDef.SVMXMap objPicklistDef = clsObjectDef.INTF_GetPicklistDefinition(mapObjToPicklistFields.get(objectName));
                        picklistDefinitions.add(objPicklistDef);
                        processedObjects.add(objectName);
                    }
                    catch(exception e)
                    {
                        //mapMessage.put('Picklist Describe', 'Reached maximum limit of Picklist describes');
                        //SmaxException customException = new SmaxException(mapMessage, e);
                        //response.errors.add(customException.getDetailedErrorMsg(e));
                        break;
                    }*/
                }
                else
                {
                    processedObjects.add(objectName);
                }
            }
            List<String> unprocessedObjects = new List<String>();
            Integer cnt = 0;
            for(String objectName: objects)
            {
                if(!processedObjects.contains(objectName) && (processedObjects.size() > 0 || cnt > 0))
                    unprocessedObjects.add(objectName);
                cnt++;
            }
            response.valueMap = picklistDefinitions;
            response.values = unprocessedObjects;
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(mapMessage, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        return response;
    }
    
    //Get all transactional and lookup object definitions for the given processes
    public Map<String, INTF_WebServicesDef.SVMXMap> getServiceFlowObjectDef(Map<Id, SVMXC__ServiceMax_Processes__c> processes)
    {
        Map<String, INTF_WebServicesDef.SVMXMap> mapObjDefinitions = new Map<String, INTF_WebServicesDef.SVMXMap>();
        set<String> objectName = new set<String>();
        // Getting allowed objects
        objectAccess objAccess = new objectAccess();
        objAccess = getSFMTxObjects(processes);    
        if(objAccess.transactionalObjects != NULL && objAccess.transactionalObjects.size() > 0)
            objectName.addAll(objAccess.transactionalObjects);
        if(objAccess.lookupObjects != NULL && objAccess.lookupObjects.size() > 0)
            objectName.addAll(objAccess.lookupObjects);
        if(objectName != null && objectName.size() > 0)
        {
            mapObjDefinitions = getObjectDefinition(objectName);
        }
        return mapObjDefinitions;
    }
  
    public Map<String, INTF_WebServicesDef.SVMXMap> getObjectDefinition(Set<String> objectNames)
    {
        Map<String, INTF_WebServicesDef.SVMXMap> mapObjDef = new Map<String, INTF_WebServicesDef.SVMXMap>();
        Integer intLimitPercent = 70;
        set<String> setErrorObjectNames = new set<String>();
        List<String> lstSettingId = new list<String>{'SET011'};
        INTF_DataUtilityServices objDataUtil = new INTF_DataUtilityServices();
        INTF_GetObjectDefinition clsObjectDef = new INTF_GetObjectDefinition();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
        if(mapSettingsForIPAD018 != null && mapSettingsForIPAD018.size() > 0 && mapSettingsForIPAD018.containskey('SET011') && mapSettingsForIPAD018.get('SET011') != null)
            intLimitPercent = integer.valueOf(mapSettingsForIPAD018.get('SET011'));
        else
            intLimitPercent = 70;
                    
        if(objectNames != NULL && objectNames.size() > 0)
        {
            for(String objName: objectNames)
            {
                //if(Limits.getCpuTime() < 7000)
                if(!objDataUtil.isLimitReached(intLimitPercent))
                {
                    try
                    {
                        clsObjectDef.objectName = objName;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDef.INTF_GetObjectDefinition();
                        if(objDef.key != NULL && objDef.key == 'OBJECT' && objDef.value != null && objDef.value.length() > 0)
                        {
                            mapObjDef.put(objName, objDef);
                        }
                        else
                        {
                            system.debug(LoggingLevel.WARN, 'Error when trying to describe object ' + objName);
                            setErrorObjectNames.add(objName);
                        }
                    }
                    catch(Exception e)
                    {
                        system.debug(LoggingLevel.WARN, 'Got exception when trying to describe object ' + objName + ': ' + e.getMessage());
                        setErrorObjectNames.add(objName);
                        //break;
                    }
                }
                else
                {
                    break;
                }
            }
        }
        for(String objName: objectNames)
        {
            if(!mapObjDef.containsKey(objName) && !setErrorObjectNames.contains(objName))
            {
                mapObjDef.put(objName, null);//put unprocessed object names
            }
        }
        system.debug(LoggingLevel.WARN, 'mapObjDef== '+ mapObjDef);
        return mapObjDef;
    }
    
    public Set<String> getSFMObjects(Map<Id, SVMXC__ServiceMax_Processes__c> processes)
    {
        set<String> setObjectNames = new set<String>();
        objectAccess objAccess = new objectAccess();
        objAccess = getSFMTxObjects(processes);
            
        if(objAccess.transactionalObjects != NULL && objAccess.transactionalObjects.size() > 0)
            setObjectNames.addAll(objAccess.transactionalObjects);
            
        if(objAccess.lookupObjects != NULL && objAccess.lookupObjects.size() > 0)
            setObjectNames.addAll(objAccess.lookupObjects);
            
        return setObjectNames;
    }
    
    //For the given object, this method gets data considering record type
    public List<INTF_WebServicesDef.SVMXMap> getServiceFlowObjData(Map<Id, SVMXC__ServiceMax_Processes__c> processes)
    {
        List<INTF_WebServicesDef.SVMXMap> response = new List<INTF_WebServicesDef.SVMXMap>();
        set<Id> setProcessIds = new set<Id>();
        set<Id> setPageLayoutIds = new set<Id>();
        set<Id> setDocTempIds = new set<Id>();
        
        if(processes != NULL && processes.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c proc: processes.values())
            {
                setProcessIds.add(proc.Id);
                setPageLayoutIds.add(proc.SVMXC__Page_Layout__c);
                if(proc.SVMXC__Doc_Template__c != null)
                    setDocTempIds.add(proc.SVMXC__Doc_Template__c);
            }
            //Get process data wich includes process, process node object, expressions, mapping
            INTF_WebServicesDef.SVMXMap processInfo = new INTF_WebServicesDef.SVMXMap();
            processInfo = getServiceFlowProcesses(setProcessIds);
            INTF_WebServicesDef.SVMXMap wrpProcess = new INTF_WebServicesDef.SVMXMap();
            wrpProcess.key = 'PROCESS';
            wrpProcess.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            wrpProcess.valueMap.add(processInfo);
            response.add(wrpProcess);
            //Get page data which includes page layout, page layout details, named search
            INTF_WebServicesDef.SVMXMap wrpPage = new INTF_WebServicesDef.SVMXMap();
            wrpPage = getServiceFlowPageLayouts(setPageLayoutIds);
            wrpPage.key = 'PAGE';
            response.add(wrpPage);
            
            //Document Templates
            if(setDocTempIds != null && setDocTempIds.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap wrpDocTemp = new INTF_WebServicesDef.SVMXMap();
                wrpDocTemp = getServiceFlowDocTemplates(setDocTempIds);
                wrpDocTemp.key = 'DOC_TEMPLATE';
                response.add(wrpDocTemp);
                 
                /*INTF_WebServicesDef.SVMXMap wrpResources = new INTF_WebServicesDef.SVMXMap();
                set<string> setOpDocResources = new set<string>();
                setOpDocResources = clsConstant.getOpDocResourcesSet();
                if(setOpDocResources != null && setOpDocResources.size() > 0)
                {
                    wrpResources = getOpDocResources(setOpDocResources);
                    wrpResources.key = 'STATIC_RESOURCE';
                    response.add(wrpResources);
                }*/
            }
              
            //Get Linked Processes
            INTF_WebServicesDef.SVMXMap wrpLinkedPro = new INTF_WebServicesDef.SVMXMap();
            wrpLinkedPro = getLinkedProcesses(setProcessIds);
            wrpLinkedPro.key = 'LINKED_PROCESS';
            response.add(wrpLinkedPro);
        }
        return response;
    }
    
    //Method to get the Linked Processes
    public INTF_WebServicesDef.SVMXMap getLinkedProcesses(set<Id> setProcessIds)
    {
        INTF_WebServicesDef.SVMXMap linkedPro = new INTF_WebServicesDef.SVMXMap();
        List<INTF_WebServicesDef.SVMXMap> lstPro = new List<INTF_WebServicesDef.SVMXMap>();
        
        if(setProcessIds == null || setProcessIds.size() == 0)
            return linkedPro;
        
        //Querying the Process Node Objects
        List<SVMXC__ServiceMax_Processes__c> lstLinkedPro = [Select SVMXC__Process1__c, Id, SVMXC__Process2__c, SVMXC__Process3__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Linked Process' And SVMXC__Process1__c IN :setProcessIds];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(lstLinkedPro == null || lstLinkedPro.size() == 0)
            return linkedPro;
        
        //Building the response for the ServiceMax Linked SFM Processes
        INTF_WebServicesDef.SVMXMap wrpProcessHeader = new INTF_WebServicesDef.SVMXMap();
        wrpProcessHeader.key = 'LINKED_SFMProcess';
        wrpProcessHeader.valueMap = getKeyValueForData(clsConstant.getLinkedProHdrDef(), lstLinkedPro);
        lstPro.add(wrpProcessHeader);
        
        //linkedPro.valueMap = lstPro;
        INTF_WebServicesDef.SVMXMap firstVM = new INTF_WebServicesDef.SVMXMap();
        firstVM.valueMap = lstPro;
        
        linkedPro.valueMap.add(firstVM);
        return linkedPro;
    }
    
    public INTF_WebServicesDef.SVMXMap getServiceFlowDocTemplates(set<Id> setDocTempIds)
    {
        INTF_WebServicesDef.SVMXMap response = new INTF_WebServicesDef.SVMXMap();
        List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
        List<SVMXC__Doc_Template__c> lstDocTemp = new List<SVMXC__Doc_Template__c>(); 
        List<SVMXC__Doc_Template_Details__c> lstDocTempDtls = new List<SVMXC__Doc_Template_Details__c>();
        List<Attachment> lstAttachs = new List<Attachment>();
        
        lstDocTemp = [select id, SVMXC__Template_Id__c, SVMXC__Name__c, SVMXC__Media_Resources__c, SVMXC__Detail_Object_Count__c, SVMXC__IsStandard__c from SVMXC__Doc_Template__c where id IN: setDocTempIds];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(lstDocTemp != null && lstDocTemp.size() > 0)
        {
            INTF_WebServicesDef.SVMXMap docTemplate = new INTF_WebServicesDef.SVMXMap();
            docTemplate.key = 'DOC_TEMPLATE';
            docTemplate.valueMap = getKeyValueForData(clsConstant.getSFMDocTemplateDef(), lstDocTemp);
            lstResponse.add(docTemplate);  
            
            lstDocTempDtls = [select id, SVMXC__Alias__c, SVMXC__Doc_Template__c, SVMXC__Doc_Template_Detail_Id__c, SVMXC__Doc_Template_Detail_Unique_Id__c, SVMXC__Fields__c, SVMXC__Header_Reference_Field__c, SVMXC__Object_Name__c, SVMXC__SOQL__c, SVMXC__Type__c from SVMXC__Doc_Template_Details__c where SVMXC__Doc_Template__c IN: setDocTempIds];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstDocTempDtls != null && lstDocTempDtls.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap docTemplateDtl = new INTF_WebServicesDef.SVMXMap();
                docTemplateDtl.key = 'DOC_TEMPLATE_DETAILS';
                docTemplateDtl.valueMap = getKeyValueForData(clsConstant.getSFMDocTemplateDtlDef(), lstDocTempDtls);
                lstResponse.add(docTemplateDtl);
            }
            
            lstAttachs = [select id, Name, ParentId from Attachment where ParentId IN: setDocTempIds]; 
            if(lstDocTempDtls != null && lstDocTempDtls.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap docTemplateAttach = new INTF_WebServicesDef.SVMXMap();
                docTemplateAttach.key = 'ATTACHMENTS';
                docTemplateAttach.valueMap = getKeyValueForData(clsConstant.getAttachmentDef(), lstAttachs);
                lstResponse.add(docTemplateAttach);
            }
        }
        
        INTF_WebServicesDef.SVMXMap firstVM = new INTF_WebServicesDef.SVMXMap();
        firstVM.valueMap = lstResponse;
        
        response.valueMap.add(firstVM);
        return response;
    }
      
    //To get page layouts for the given processes
    public INTF_WebServicesDef.SVMXMap getServiceFlowPageLayouts(set<Id> setPageLayoutIds)
    {
        INTF_WebServicesDef.SVMXMap response = new INTF_WebServicesDef.SVMXMap();
        List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
        List<SVMXC__Page_Layout__c> lstAvailablePageHeaders = new List<SVMXC__Page_Layout__c>();
        List<SVMXC__Page_Layout__c> lstProcessPage = new List<SVMXC__Page_Layout__c>();
        List<SVMXC__SFM_Event__c> lstPageDetailEvents = new List<SVMXC__SFM_Event__c>();
        List<SVMXC__Page_Layout_Detail__c> lstPageLayoutDetails = new List<SVMXC__Page_Layout_Detail__c>();
        set<Id> setNamedSearchIds = new set<Id>();
        set<Id> setFormFillIds = new set<Id>();
        
        lstAvailablePageHeaders = [Select SVMXC__Type__c,SVMXC__Sequence__c,SVMXC__Prompt_For_New_Event__c,SVMXC__Enable_Attachments__c,SVMXC__Enable_Chatter__c,SVMXC__Show_Account_History__c,SVMXC__Show_All_Sections_By_Default__c,SVMXC__Show_Product_History__c,
                   SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Enable_Service_Report_View__c, SVMXC__Enable_Troubleshooting__c, SVMXC__Enable_Service_Report_Generation__c, 
                   SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c, SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, Name, Id From SVMXC__Page_Layout__c where Id IN :setPageLayoutIds];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        // Adding page layouts to response
        if(lstAvailablePageHeaders != NULL && lstAvailablePageHeaders.size() > 0)
        {
            lstProcessPage.addAll(lstAvailablePageHeaders);
            //Adding page layout details to wrapper
            List<SVMXC__Page_Layout_Detail__c> lstExistingPageLayoutDetails = [Select SVMXC__Field_Mapping__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Title__c, SVMXC__IsStandard__c,SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c,SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c,   SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id,SVMXC__No_of_columns__c, SVMXC__Enable_Chatter__c, SVMXC__Control_Type__c, SVMXC__Maximum_Value__c, SVMXC__Minimum_Value__c, SVMXC__Use_For_SLA_Clock__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN :setPageLayoutIds];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstExistingPageLayoutDetails.size()>0)
            {
                lstPageLayoutDetails.addAll(lstExistingPageLayoutDetails);
                set<Id> setPageDetailId = new set<Id>();
                for(SVMXC__Page_Layout_Detail__c detail: lstExistingPageLayoutDetails)
                {
                    setPageDetailId.add(detail.Id);
                    if(detail.SVMXC__Detail_Type__c != NULL && detail.SVMXC__DataType__c != NULL && detail.SVMXC__Detail_Type__c.toUppercase() == 'FIELD' && detail.SVMXC__DataType__c.toUppercase() == 'REFERENCE' && detail.SVMXC__Named_Search__c != NULL)
                    {
                        setNamedSearchIds.add(detail.SVMXC__Named_Search__c);
                    }
                    if(detail.SVMXC__Field_Mapping__c != null)
                        setFormFillIds.add(detail.SVMXC__Field_Mapping__c);
                }
                //Page level events and field level events
                List<SVMXC__SFM_Event__c> lstExistingPageDetailEvents = [Select SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, Name, Id from SVMXC__SFM_Event__c where SVMXC__Page_Layout__c IN : setPageLayoutIds OR SVMXC__Page_Layout_Detail__c IN : setPageDetailId];
                lstPageDetailEvents.addAll(lstExistingPageDetailEvents);
            }
            //Page layout relatedlist details
            List<SVMXC__Page_Layout__c> lstExistingPageLayoutrelatedList = [Select SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c,  SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, Name, Id From SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c IN :setPageLayoutIds];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstExistingPageLayoutrelatedList.size()>0)
            {
                lstProcessPage.addAll(lstExistingPageLayoutrelatedList);
                set<Id> pageDetailId = new set<Id>();
                for(SVMXC__Page_Layout__c detailPage: lstExistingPageLayoutrelatedList)
                {
                    pageDetailId.add(detailPage.Id);
                }
                List<SVMXC__Page_Layout_Detail__c> lstExistingPageLayoutDetailsDetails = [Select SVMXC__Field_Mapping__c, SVMXC__Related_Object_Name_Field__c, SVMXC__IsStandard__c,SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id ,SVMXC__No_of_columns__c, SVMXC__Enable_Chatter__c, SVMXC__Control_Type__c, SVMXC__Maximum_Value__c, SVMXC__Minimum_Value__c, SVMXC__Use_For_SLA_Clock__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN :pageDetailId];       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA 
                if(lstExistingPageLayoutDetailsDetails.size()>0)
                {
                    lstPageLayoutDetails.addAll(lstExistingPageLayoutDetailsDetails);
                    set<Id> detailPageDetailId = new set<Id>();
                    for(SVMXC__Page_Layout_Detail__c detailPage: lstExistingPageLayoutDetailsDetails)
                    {
                        detailPageDetailId.add(detailPage.Id);
                        if(detailPage.SVMXC__Detail_Type__c != NULL && detailPage.SVMXC__DataType__c != NULL && detailPage.SVMXC__Detail_Type__c.toUppercase() == 'FIELD' && detailPage.SVMXC__DataType__c.toUppercase() == 'REFERENCE' && detailPage.SVMXC__Named_Search__c != NULL)
                        {
                            setNamedSearchIds.add(detailPage.SVMXC__Named_Search__c);
                        }
                        if(detailPage.SVMXC__Field_Mapping__c != null)
                            setFormFillIds.add(detailPage.SVMXC__Field_Mapping__c);
                    }
                    List<SVMXC__SFM_Event__c> lstExistingPageDetailEvents = [Select SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, Name, Id from SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : detailPageDetailId];
                    lstPageDetailEvents.addAll(lstExistingPageDetailEvents);
                }
            }
            
            if(setNamedSearchIds.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap wrpNamedSearch = new INTF_WebServicesDef.SVMXMap();
                wrpNamedSearch = getServiceFlowNamedSearch(setNamedSearchIds);
                wrpNamedSearch.key = 'NAMEDSEARCH';
                lstResponse.add(wrpNamedSearch);
            }
            
            if(setFormFillIds != null && setFormFillIds.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap wrpFormFill = new INTF_WebServicesDef.SVMXMap();
                wrpFormFill.key = 'FORMFILL';
                wrpFormFill.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                wrpFormFill.valueMap = getServiceFlowObjectMapping(setFormFillIds);
                lstResponse.add(wrpFormFill);
            }
            response.valueMap = lstResponse;
        }
        return response;
    }
    
    //To get mapping for the given processes
    public List<INTF_WebServicesDef.SVMXMap> getServiceFlowObjectMapping(set<Id> setMapIds)
    {
        List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
        List<SVMXC__ServiceMax_Processes__c> availableMappingHeader = new List<SVMXC__ServiceMax_Processes__c>();
        availableMappingHeader = [SELECT SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c, SVMXC__Description__c, Name, Id,SVMXC__Name__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Id IN :setMapIds];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        set<Id> setPageLayoutIDs = new Set<ID>();
        for(SVMXC__Page_Layout_Detail__c pageDetail : [SELECT Id, SVMXC__DataType__c, SVMXC__Field_API_Name__c, SVMXC__Page_Layout__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__DataType__c = 'reference' AND SVMXC__Field_API_Name__c = 'WhatId' AND SVMXC__Page_Layout__c != NULL AND  (SVMXC__Page_Layout__c IN : [SELECT Id FROM SVMXC__Page_Layout__c] OR SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c IN: [SELECT Id FROM SVMXC__Page_Layout__c])])   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        {
            setPageLayoutIDs.add(pageDetail.SVMXC__Page_Layout__c);
        }
        
        if(availableMappingHeader != NULL && availableMappingHeader.size() > 0)
        {
            INTF_WebServicesDef.SVMXMap wrpProcessMapping = new INTF_WebServicesDef.SVMXMap();
            wrpProcessMapping.key = 'SFObject_mapping';
            wrpProcessMapping.valueMap = getKeyValueForData(clsConstant.getObjectMappingHeaderDefinition(), availableMappingHeader);
            lstResponse.add(wrpProcessMapping);
            List<SVMXC__ServiceMax_Config_Data__c> lstExistingMappingDetails = [Select SVMXC__MapID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c,   SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, Name, Id, SVMXC__Preference_2__c, SVMXC__Preference_3__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c IN :setMapIds and Recordtype.Name='Field Mapping'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(lstExistingMappingDetails != NULL && lstExistingMappingDetails.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap wrpProcessMappingDetails = new INTF_WebServicesDef.SVMXMap();
                wrpProcessMappingDetails.key = 'SFObject_mapping_component';
                wrpProcessMappingDetails.valueMap = getKeyValueForData(clsConstant.getObjectMappingDetailDefinition(), lstExistingMappingDetails);
                for(SVMXC__ServiceMax_Processes__c processNodeObject : [Select Id, Name, SVMXC__Parent_Object__c, SVMXC__MapID__c, SVMXC__Parent_Column_Name__c, SVMXC__ProcessID__c, SVMXC__Type__c, SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Module__c, SVMXC__Sequence__c, SVMXC__Process__c, SVMXC__Process__r.SVMXC__Page_Layout__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Process Node Objects' And SVMXC__Process__r.SVMXC__Page_Layout__c IN :setPageLayoutIDs AND (SVMXC__Type__c = 'TARGET' OR SVMXC__Type__c = 'TARGETCHILD')])
                {
                    INTF_WebServicesDef.SVMXMap whatidFieldMapping = new INTF_WebServicesDef.SVMXMap();
                    whatidFieldMapping.valueMap.add(new INTF_WebServicesDef.SVMXMap('target_field_name', 'WhatId'));
                    whatidFieldMapping.valueMap.add(new INTF_WebServicesDef.SVMXMap('source_field_name', 'Id'));
                    whatidFieldMapping.valueMap.add(new INTF_WebServicesDef.SVMXMap('object_mapping_id', processNodeObject.SVMXC__Module__c));
                    wrpProcessMappingDetails.valueMap.add(whatidFieldMapping);
                }
                lstResponse.add(wrpProcessMappingDetails);
            }
        }
        return lstResponse;
    }
    
    //To get expressions for the given processes
    public List<INTF_WebServicesDef.SVMXMap> getServiceFlowExpressions(set<Id> setExpressionIds)
    {
        List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
        List<SVMXC__ServiceMax_Processes__c> availableNamedExpressions = new List<SVMXC__ServiceMax_Processes__c>();
        availableNamedExpressions = [Select SVMXC__Description__c, SVMXC__Tag_Keys__c, SVMXC__Confirmation_Message__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Child_Error_Msg__c, Id, SVMXC__IsStandard__c, SVMXC__Source_Object_Name__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Values__c, SVMXC__Sequence__c, SVMXC__Advance_Expression__c, SVMXC__Parent_Error_Msg__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id IN :setExpressionIds];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        availableNamedExpressions = translationObj.SVMX_GetProcessTranslation(availableNamedExpressions);
        
        if(availableNamedExpressions != NULL && availableNamedExpressions.size() > 0)
        {
            INTF_WebServicesDef.SVMXMap wrpProcessExpressions = new INTF_WebServicesDef.SVMXMap();
            wrpProcessExpressions.key = 'SFExpression';
            //wrpProcessExpressions.data = availableNamedExpressions;
            wrpProcessExpressions.valueMap = getKeyValueForData(clsConstant.getObjectExpressionHeaderDefinition(), availableNamedExpressions);
            lstResponse.add(wrpProcessExpressions);
            
            List<SVMXC__ServiceMax_Config_Data__c> lstExistingExpressionDetails = [Select Id, SVMXC__Internal_Value__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__Expression_Rule__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Type__c, SVMXC__Parameter_Type__c, SVMXC__Formula__c, SVMXC__Action_Type__c, SVMXC__Description__c From SVMXC__ServiceMax_Config_Data__c where (Recordtype.Name='Expressions' OR Recordtype.Name = 'Field Updates') AND (SVMXC__Expression_Type__c = 'EXP_Named'  OR SVMXC__Expression_Type__c = 'Business_Rule' OR SVMXC__Expression_Type__c = 'Field_Update_Rule') And SVMXC__Expression_Rule__c IN :setExpressionIds];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstExistingExpressionDetails != NULL && lstExistingExpressionDetails.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap wrpProcessExpressionDetails = new INTF_WebServicesDef.SVMXMap();
                wrpProcessExpressionDetails.key = 'SFExpression_component';
                //wrpProcessExpressionDetails.data = lstExistingExpressionDetails;
                wrpProcessExpressionDetails.valueMap = getKeyValueForData(clsConstant.getObjectExpressionDetailDefinition(), lstExistingExpressionDetails);
                lstResponse.add(wrpProcessExpressionDetails);
            }
        }
        return lstResponse;
    }
  
    //To get named search for the given processes
    public INTF_WebServicesDef.SVMXMap getServiceFlowNamedSearch(set<Id> setNamedSearchIds)
    {
        INTF_WebServicesDef.SVMXMap response = new INTF_WebServicesDef.SVMXMap();
        List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
        List<SVMXC__ServiceMax_Processes__c> availableNamedSearchObjectHeader = new List<SVMXC__ServiceMax_Processes__c>();
        //Added for Adv Lookup Config...
        Map<Id, SVMXC__ServiceMax_Processes__c> advLkpObjCri = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        
        availableNamedSearchObjectHeader = [SELECT Id, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Source_Object_Name__c, SVMXC__Rule_Type__c, SVMXC__Sequence__c, SVMXC__Process__c, SVMXC__IsStandard__c, SVMXC__IsDefault__c, SVMXC__Number_of_Lookup_Records__c, SVMXC__Default_Lookup_Column__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND (SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG') AND (Id IN :setNamedSearchIds)];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(availableNamedSearchObjectHeader != NULL && availableNamedSearchObjectHeader.size() > 0)
        {
            INTF_WebServicesDef.SVMXMap wrpProcessNamedSearch = new INTF_WebServicesDef.SVMXMap();
            wrpProcessNamedSearch.key = 'SFNAMEDSEARCH';
            wrpProcessNamedSearch.valueMap = getKeyValueForData(clsConstant.getNamedSearchHeaderDefinition(), availableNamedSearchObjectHeader);
            lstResponse.add(wrpProcessNamedSearch);
            
            //Added for Adv Lookup Config...
            advLkpObjCri.putAll([SELECT Id, SVMXC__Name__c, SVMXC__Default_On__c, SVMXC__Field_Name__c, SVMXC__Allow_Override__c, SVMXC__Advance_Expression__c, SVMXC__Rule_Type__c, SVMXC__Parent_Object_Criteria__c, Name, SVMXC__Source_Object_Name__c, SVMXC__Process__c, SVMXC__Sequence__c,SVMXC__Module__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Named Search' AND SVMXC__Module__c =: setNamedSearchIds AND (SVMXC__Rule_Type__c = 'SRCH_OBJECT' OR SVMXC__Rule_Type__c = 'SRCH_CRITERIA')]);
            
            INTF_WebServicesDef.SVMXMap wrpSrchObjCri = new INTF_WebServicesDef.SVMXMap();
            wrpSrchObjCri.key = 'SFNAMEDSEARCH_CRITERIA';
            wrpSrchObjCri.valueMap = getKeyValueForData(clsConstant.getNamedSearchObjCriDef(), advLkpObjCri.values());
            lstResponse.add(wrpSrchObjCri);
            
            List<SVMXC__ServiceMax_Config_Data__c> lstExistingNamedSearchDetails = [Select Id, SVMXC__Parameter_Type__c, SVMXC__Internal_Value__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Rule__c, SVMXC__Field_Name__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Sequence__c, SVMXC__Field_Relationship_Name__c, SVMXC__Display_Type__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__r.SVMXC__Module__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN : advLkpObjCri.keyset() AND Recordtype.Name = 'Expressions' AND ((SVMXC__Expression_Type__c = 'SRCH_Object_Fields' AND SVMXC__Search_Object_Field_Type__c != 'Bubble') OR (SVMXC__Expression_Type__c =  'LKUP_Prefilter_Criteria') OR (SVMXC__Expression_Type__c =  'LKUP_Criteria'))];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //Replaced the older query to get Configurational data to the new one mentioned above...
            //List<SVMXC__ServiceMax_Config_Data__c> lstExistingNamedSearchDetails = [Select Id, SVMXC__Internal_Value__c, SVMXC__Expression_Rule__c, SVMXC__Field_Name__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Sequence__c, SVMXC__Field_Relationship_Name__c, SVMXC__Display_Type__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__r.SVMXC__Module__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__r.SVMXC__Module__c IN : setNamedSearchIds and Recordtype.Name = 'Expressions' and SVMXC__Search_Object_Field_Type__c != 'Bubble'];
            for(SVMXC__ServiceMax_Config_Data__c namedSearch: lstExistingNamedSearchDetails)
            {
                namedSearch.SVMXC__Internal_Value__c = namedSearch.SVMXC__Expression_Rule__r.SVMXC__Module__c;
            }
            if(lstExistingNamedSearchDetails != NULL && lstExistingNamedSearchDetails.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap wrpProcessNamedSearchDetails = new INTF_WebServicesDef.SVMXMap();
                wrpProcessNamedSearchDetails.key = 'SFNAMEDSEARCH_COMPONENT';
                wrpProcessNamedSearchDetails.valueMap = getKeyValueForData(clsConstant.getNamedSearchDetailDefinition(), lstExistingNamedSearchDetails);
                lstResponse.add(wrpProcessNamedSearchDetails);
            }
        }
        response.valueMap = lstResponse;
        return response;
    }
  
    //To get process and process node definition for the given processes
    public INTF_WebServicesDef.SVMXMap getServiceFlowProcesses(set<Id> setProcessIds)
    {
        INTF_WebServicesDef.SVMXMap response = new INTF_WebServicesDef.SVMXMap();
        List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
        set<Id> setMapIds = new set<Id>();
        set<Id> setExpressionIds = new set<Id>();
        Set<Id> setBusinessRuleIds = new Set<Id>();
        List<SVMXC__ServiceMax_Processes__c> lstProcessBusinessRule = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> lstBusinessRules = new List<SVMXC__ServiceMax_Processes__c>();
        
        //Get all process header definition
        List<SVMXC__ServiceMax_Processes__c> availableprocessHeader = new List<SVMXC__ServiceMax_Processes__c>();
        availableprocessHeader = [Select Id, Name, SVMXC__Doc_Template__c, SVMXC__Purpose__c, SVMXC__Page_Layout__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, 
        SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Node_Source_Object_API__c, 
        SVMXC__IsStandard__c,SVMXC__IsStandalone__c, SVMXC__Tag_Keys__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Target Manager' AND Id IN :setProcessIds];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        //Get all process node object definition
        if(availableprocessHeader != NULL && availableprocessHeader.size() > 0)
        {
            /************************************For Translation*******************************************/
            String strTransKeys = '';
            for(SVMXC__ServiceMax_Processes__c SFMProcess : availableprocessHeader)
                if(SFMProcess.SVMXC__Tag_Keys__c != NULL && SFMProcess.SVMXC__Tag_Keys__c.length() > 0)
                    strTransKeys  += SFMProcess.SVMXC__Tag_Keys__c;
            
            
            translationObj = new I18N_TranslationDelivery(strTransKeys, UserInfo.getLanguage());
            availableprocessHeader = translationObj.SVMX_GetProcessTranslation(availableprocessHeader);
            /****************************************************************************************************************/
            system.debug(loggingLevel.WARN, 'Trnslated processes: ' + availableprocessHeader);
            
            List<SVMXC__ServiceMax_Processes__c> processNodeObject = [Select Name, SVMXC__Doc_Template_Details__c, SVMXC__Values__c, SVMXC__Parent_Object__c, SVMXC__MapID__c, SVMXC__Purpose__c, SVMXC__Parent_Column_Name__c, SVMXC__Node_Parent_API__c, SVMXC__ProcessID__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Page_Layout__c,
            SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Sequence__c, SVMXC__Process__c, SVMXC__Process__r.SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,
            SVMXC__Target_Object_label__c, SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__Final_Exception_Process__c, SVMXC__Enable_Attachment__c, LastModifiedBy.Name, CreatedBy.Name 
            From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Process Node Objects' And SVMXC__Process__c IN :setProcessIds];
            for(SVMXC__ServiceMax_Processes__c processBusinessRule : translationObj.SVMX_GetProcessTranslation([Select Id, Name, SVMXC__Tag_Keys__c, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__Process3__c, SVMXC__Description__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Sequence__c, SVMXC__Source_Object_Name__c, SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Process Business Rule' And SVMXC__Process1__c IN :setProcessIds]))   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            {
                lstProcessBusinessRule.add(processBusinessRule);
                setBusinessRuleIds.add(processBusinessRule.SVMXC__Process3__c);
            }
            lstBusinessRules = translationObj.SVMX_GetProcessTranslation([Select Id, Name, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Tag_Keys__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Advance_Expression__c, SVMXC__Message_Type__c, SVMXC__Name__c, SVMXC__Rule_Type__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Business Rule' And ID IN :setBusinessRuleIds]);
            
            for(SVMXC__ServiceMax_Config_Data__c expressionRec : [SELECT Id, Name, SVMXC__Expression_Rule__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__c IN : setBusinessRuleIds])
            {
                setExpressionIds.add(expressionRec.SVMXC__Expression_Rule__c);
            }
            for(SVMXC__ServiceMax_Processes__c processNode: processNodeObject)
            {
                if(processNode.SVMXC__Type__c != NULL && (processNode.SVMXC__Type__c == 'TARGET' || processNode.SVMXC__Type__c == 'TARGETCHILD'))
                {
                    if(processNode.SVMXC__Module__c != NULL)
                        setMapIds.add(processNode.SVMXC__Module__c);
                    if(processNode.SVMXC__Final_Exception_Process__c != NULL)
                        setMapIds.add(processNode.SVMXC__Final_Exception_Process__c);
                    if(processNode.SVMXC__Submodule__c != NULL)
                        setExpressionIds.add(processNode.SVMXC__Submodule__c);
                }
            }
      
            //Building the response for the ServiceMax Processes
            INTF_WebServicesDef.SVMXMap wrpProcessHeader = new INTF_WebServicesDef.SVMXMap();
            wrpProcessHeader.key = 'SFMProcess';
            wrpProcessHeader.valueMap = getKeyValueForData(clsConstant.getProcessHeaderDefinition(), availableprocessHeader);
            lstResponse.add(wrpProcessHeader);
            INTF_WebServicesDef.SVMXMap wrpProcessNodeObject = new INTF_WebServicesDef.SVMXMap();
            wrpProcessNodeObject.key = 'SFProcess_component';
            wrpProcessNodeObject.valueMap = getKeyValueForData(clsConstant.getProcessDetailDefinition(), processNodeObject);
            lstResponse.add(wrpProcessNodeObject);
            
            INTF_WebServicesDef.SVMXMap wrpProcessBussRule = new INTF_WebServicesDef.SVMXMap();
            wrpProcessBussRule.key = 'Process_Business_Rule';
            wrpProcessBussRule.valueMap = getKeyValueForData(clsConstant.getProcessBusinessRules(), lstProcessBusinessRule);
            lstResponse.add(wrpProcessBussRule);
            
            INTF_WebServicesDef.SVMXMap wrpBussRule = new INTF_WebServicesDef.SVMXMap();
            wrpBussRule.key = 'Business_Rule';
            wrpBussRule.valueMap = getKeyValueForData(clsConstant.getBusinessRules(), lstBusinessRules);
            lstResponse.add(wrpBussRule);
      
            //To get source updates for process
            //list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdate = [Select SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c,   SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, Name, Id, SVMXC__Preference_2__c, SVMXC__Preference_3__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN :setProcessIds and Recordtype.Name='Field Mapping'];
            list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdate = [Select Id, SVMXC__Setting_ID__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c, SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Dispatch_Process__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN :setProcessIds and Recordtype.Name='Field Mapping' AND SVMXC__Configuration_Type__c = 'Source Update'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
          
            if(lstSourceUpdate != NULL && lstSourceUpdate.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap wrpSourceUpdate = new INTF_WebServicesDef.SVMXMap();
                /*wrpSourceUpdate.key = 'SVMXC__ServiceMax_Config_Data__c';
                wrpSourceUpdate.data = lstSourceUpdate;*/
                wrpSourceUpdate.key = 'SOURCE_UPDATE';
                wrpSourceUpdate.valueMap = getKeyValueForData(clsConstant.getSourceUpdate(), lstSourceUpdate);
                lstResponse.add(wrpSourceUpdate);
            }
            if(setMapIds != NULL && setMapIds.size() > 0)
            {
                lstResponse.addAll(getServiceFlowObjectMapping(setMapIds));
            }
            if(setExpressionIds != NULL && setExpressionIds.size() > 0)
            {
                lstResponse.addAll(getServiceFlowExpressions(setExpressionIds));
            }
        }
        response.valueMap = lstResponse;
        return response;     
    }
    
    //To get the SFW data for the SFM Actions
    public List<INTF_WebServicesDef.SVMXMap> getServiceFlowWizards(Map<Id, SVMXC__ServiceMax_Processes__c> processes, String strIPadVersion)
    {
        set<ID> setProcessIds = new set<ID>();
        set<ID> setSFWIds = new set<ID>();
        set<ID> setExpressionIds = new set<ID>();
        Id currentExpression = null;
        List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
        
        set<string> setSfmToFilter = new set<string>();
        set<string> setCusActToFilter = new set<string>();
        
        if(INTF_ServiceEventUtility.filterstoExclude != null)
        {
            if(INTF_ServiceEventUtility.filterstoExclude.sfms != null && INTF_ServiceEventUtility.filterstoExclude.sfms.size() > 0)
            {
                setSfmToFilter.addAll(INTF_ServiceEventUtility.filterstoExclude.sfms);
            }
            if(INTF_ServiceEventUtility.filterstoExclude.sfactions != null && INTF_ServiceEventUtility.filterstoExclude.sfactions.size() > 0)
            {
                setCusActToFilter.addAll(INTF_ServiceEventUtility.filterstoExclude.sfactions);
            }
        }
        
        try
        {
            setSFWIds = processes.keySet();
            System.debug(LoggingLevel.WARN, 'setProcessIds' + setSFWIds);
            // get the steps for the Wizard steps for the available SFM Transactions
            List<SVMXC__ServiceMax_Processes__c> lstWizardsSteps = new List<SVMXC__ServiceMax_Processes__c> ();
            List<SVMXC__ServiceMax_Processes__c> lstCustomActionIDs = new List<SVMXC__ServiceMax_Processes__c> ();
            List<SVMXC__ServiceMax_Config_Data__c> lstWizardLayout = new List<SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> lstCustomActionParams = new List<SVMXC__ServiceMax_Config_Data__c>();
            Set<ID> IDs = new Set<ID>();
            
            //Filter Wizard Step based on Application Filters for SFM
            string strSOQLWizardStepSFM = 'Select Id, SVMXC__Record_Type_Name__c, SVMXC__Rule_Type__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Tag_Keys__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Action_Type__c, SVMXC__Action_URL__c, SVMXC__Module__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__ProcessID__c, SVMXC__Sequence__c, SVMXC__IsStandard__c, SVMXC__Active__c, SVMXC__Expertise_Match_Enabled__c, SVMXC__Service_Namespace__c, SVMXC__Service_Class_Name__c, SVMXC__Service_Method_Name__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Wizard Step\' and SVMXC__Module__c In :setSFWIds and SVMXC__Action_Type__c = \'SFM\'';// OR SVMXC__Action_Type__c = 'OUTPUT_DOCUMENT'
            if(setSfmToFilter.size() > 0)
                strSOQLWizardStepSFM += ' AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN: setSfmToFilter';
                
            lstWizardsSteps = database.query(strSOQLWizardStepSFM);
            lstWizardLayout = [select id, SVMXC__Object_Name__c, SVMXC__Button_Size__c, SVMXC__Dispatch_Process__c, SVMXC__Wizard_Layout_Column__c, SVMXC__Wizard_Layout_Row__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN : setSFWIds AND SVMXC__RecordType_Name__c = 'Wizard Layout'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__SFM_Event__c> lstSFMEventsSyncOvrde = [Select Id, Name, SVMXC__Sequence__c, SVMXC__ServiceMax_Process__c, SVMXC__Target_Call__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Call_Type__c  from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c IN : lstWizardsSteps];

            if(strIPadVersion != null && strIPadVersion.length() > 0)
            {
                //Filter Wizard Step based on Application Filters for Custom Actions
                string strSOQLWizStepCusAct = 'Select Id, SVMXC__Record_Type_Name__c, SVMXC__Rule_Type__c, SVMXC__Child_Error_Msg__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__ProcessID__c, SVMXC__Parent_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Tag_Keys__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Action_Type__c, SVMXC__Action_URL__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__Sequence__c, SVMXC__IsStandard__c, SVMXC__Active__c, SVMXC__Expertise_Match_Enabled__c, SVMXC__Service_Namespace__c, SVMXC__Service_Class_Name__c, SVMXC__Service_Method_Name__c, SVMXC__Target_URL__c, SVMXC__Custom_Action_Type__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Wizard Step\' and SVMXC__Module__c In :setSFWIds and SVMXC__Action_Type__c = \'OTHERS\' AND (SVMXC__Process__r.SVMXC__Custom_Action_Type__c = \'Web-Service\' OR SVMXC__Process__r.SVMXC__Custom_Action_Type__c = \'URL\')';
                if(setCusActToFilter.size() > 0)
                    strSOQLWizStepCusAct += ' AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN: setCusActToFilter';
                    
                lstCustomActionIDs.addAll((List<SVMXC__ServiceMax_Processes__c>)database.query(strSOQLWizStepCusAct));
                for(SVMXC__ServiceMax_Processes__c pro : lstCustomActionIDs)
                {
                    IDs.add(pro.SVMXC__Process__c);
                }
                lstWizardsSteps.addAll(lstCustomActionIDs);
                lstCustomActionIDs.addAll([Select Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Action_Type__c, SVMXC__Action_URL__c, SVMXC__Module__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__ProcessID__c, SVMXC__Sequence__c, SVMXC__IsStandard__c, SVMXC__Active__c, SVMXC__Expertise_Match_Enabled__c, SVMXC__Service_Namespace__c, SVMXC__Service_Class_Name__c, SVMXC__Service_Method_Name__c, SVMXC__Target_URL__c, SVMXC__Custom_Action_Type__c From SVMXC__ServiceMax_Processes__c where ID in :IDs]);
                for(SVMXC__ServiceMax_Processes__c objCustAction: lstCustomActionIDs)
                {
                    if(objCustAction.SVMXC__Service_Namespace__c != NULL && objCustAction.SVMXC__Service_Namespace__c.length() > 0)
                        objCustAction.SVMXC__Service_Class_Name__c = objCustAction.SVMXC__Service_Namespace__c + '/' + objCustAction.SVMXC__Service_Class_Name__c;
                }
                //Custom Action Params
                lstCustomActionParams = [Select Id, Name, SVMXC__Action_Type__c, SVMXC__Dispatch_Process__c, SVMXC__Parameter_Name__c, SVMXC__Parameter_Type__c, SVMXC__Parameter_Value__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN: IDs];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                //For Output Documents
                system.debug(logginglevel.WARN, '===Version=: ' + strIPadVersion);
                if(strIPadVersion.contains('.'))
                {
                    INTF_ServiceEventUtility eventUtil = new INTF_ServiceEventUtility();
                    boolean validVersion_OpDoc = eventUtil.isVersionCorrect(strIPadVersion, '12');
                    system.debug(logginglevel.WARN, '===Version checked=: ' + validVersion_OpDoc );
                    if(validVersion_OpDoc == true)
                    {
                        string strSOQLWizStepOpDoc = 'Select Id, SVMXC__Record_Type_Name__c, SVMXC__Rule_Type__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__ProcessID__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Tag_Keys__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Action_Type__c, SVMXC__Action_URL__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__Sequence__c, SVMXC__IsStandard__c, SVMXC__Active__c, SVMXC__Expertise_Match_Enabled__c, SVMXC__Service_Namespace__c, SVMXC__Service_Class_Name__c, SVMXC__Service_Method_Name__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Wizard Step\' and SVMXC__Module__c In :setSFWIds and SVMXC__Action_Type__c = \'OUTPUT_DOCUMENT\'';
                        if(setSfmToFilter.size() > 0)
                            strSOQLWizStepOpDoc += ' AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN: setSfmToFilter';
                        lstWizardsSteps.addAll((List<SVMXC__ServiceMax_Processes__c>)database.query(strSOQLWizStepOpDoc));
                        system.debug(logginglevel.WARN, '===WS=: ' + lstWizardsSteps);
                    }
                }
            }    
            if(lstWizardsSteps.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c objCurrStep : lstWizardsSteps)
                {
                    currentExpression = objCurrStep.SVMXC__Submodule__c;
                    if(currentExpression != null)
                    {        
                        setExpressionIds.add(currentExpression);
                    }
                }      
            }
            // get the steps for the Wizard for the available Steps
            List<SVMXC__ServiceMax_Processes__c> lstAvailableWizards = new List<SVMXC__ServiceMax_Processes__c>();
            lstAvailableWizards = [Select Id, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Rule_Type__c, SVMXC__Tag_Keys__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Submodule__c, SVMXC__ProcessID__c, SVMXC__Object_Key_Prefix__c, SVMXC__Dispatch_Process_Status__c, SVMXC__IsStandard__c, SVMXC__Active__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Wizard' and ID In :setSFWIds];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstAvailableWizards.size() > 0)
            {
                String strTransKeys = '';
                for(SVMXC__ServiceMax_Processes__c objCurrWizard : lstAvailableWizards)
                {
                    currentExpression = objCurrWizard.SVMXC__Submodule__c;
                    if(currentExpression != null)
                    {        
                        setExpressionIds.add(currentExpression);
                    }
                    /***************************For Translation****************************************************/
                    if(objCurrWizard.SVMXC__Tag_Keys__c != NULL && objCurrWizard.SVMXC__Tag_Keys__c.length() > 0)
                        strTransKeys  += objCurrWizard.SVMXC__Tag_Keys__c;
                }
                /***************************For Translation****************************************************/
                translationObj = new I18N_TranslationDelivery(strTransKeys, UserInfo.getLanguage());
                lstAvailableWizards = translationObj.SVMX_GetProcessTranslation(lstAvailableWizards);
            }
            // Get the Expressions data
            if(setExpressionIds != NULL && setExpressionIds.size() > 0)
            {
                lstResponse.addAll(getServiceFlowExpressions(setExpressionIds));
            }
            
            /***************************For Translation****************************************************/
            if(lstAvailableWizards != NULL && lstAvailableWizards.size() > 0)
            {
                if(lstWizardsSteps != null && lstWizardsSteps.size() > 0)
                    lstWizardsSteps = translationObj.SVMX_GetProcessTranslation(lstWizardsSteps);
            }
            /***************************For Translation****************************************************/
            
            //Building the response for the ServiceMax Processes
            INTF_WebServicesDef.SVMXMap wrpProcessWizard = new INTF_WebServicesDef.SVMXMap();
            wrpProcessWizard.key = 'SFW_wizard';
            wrpProcessWizard.valueMap = getKeyValueForData(clsConstant.getSFWWizard(), lstAvailableWizards);
            lstResponse.add(wrpProcessWizard);
            INTF_WebServicesDef.SVMXMap wrpProcessWizardSteps = new INTF_WebServicesDef.SVMXMap();
            wrpProcessWizardSteps.key = 'SFW_wizard_steps';
            wrpProcessWizardSteps.valueMap = getKeyValueForData(clsConstant.getSFWWizardActions(), lstWizardsSteps);
            lstResponse.add(wrpProcessWizardSteps);  
            
            INTF_WebServicesDef.SVMXMap wrpSFWLayout = new INTF_WebServicesDef.SVMXMap();
            wrpSFWLayout.key = 'SFM_wizard_layout';
            wrpSFWLayout.valueMap = getKeyValueForData(clsConstant.getSFMWizardLayout(), lstWizardLayout);
            lstResponse.add(wrpSFWLayout); 
            
            INTF_WebServicesDef.SVMXMap wrpProcessWizardActions = new INTF_WebServicesDef.SVMXMap();
            wrpProcessWizardActions.key = 'SFW_Custom_Actions';
            wrpProcessWizardActions.valueMap = getKeyValueForData(clsConstant.getSFWWizardCustomActions(), lstCustomActionIDs);
            lstResponse.add(wrpProcessWizardActions);
            
            INTF_WebServicesDef.SVMXMap wrpCustomActionParams = new INTF_WebServicesDef.SVMXMap();
            wrpCustomActionParams.key = 'SFW_Custom_Action_Params';
            wrpCustomActionParams.valueMap = getKeyValueForData(clsConstant.getSFWWizardCustomActionParams(), lstCustomActionParams);
            lstResponse.add(wrpCustomActionParams);
            
            INTF_WebServicesDef.SVMXMap wrpProcessSync = new INTF_WebServicesDef.SVMXMap();
            wrpProcessSync.key = 'SFW_Sync_Override';
            wrpProcessSync.valueMap = getKeyValueForData(clsConstant.getSFWWizardSyncOverride(), lstSFMEventsSyncOvrde);
            lstResponse.add(wrpProcessSync);
            return lstResponse;
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
    
    public List<INTF_WebServicesDef.SVMXMap> getKeyValueForData(Map<String, String> objectDef, List<Sobject> data)
    {
        List<INTF_WebServicesDef.SVMXMap> response = new List<INTF_WebServicesDef.SVMXMap>();
        for(Sobject record: data)
        {
            INTF_WebServicesDef.SVMXMap actualRecord = new INTF_WebServicesDef.SVMXMap();
            List<INTF_WebServicesDef.SVMXMap> values = new List<INTF_WebServicesDef.SVMXMap>();
            for(String fieldName: objectDef.keySet())
            {
                if(record.get(fieldName) != NULL)
                    values.add(new INTF_WebServicesDef.SVMXMap(objectDef.get(fieldName), String.valueOf(record.get(fieldName))));
            }
            actualRecord.valueMap = values;
            response.add(actualRecord);
        }
        return response;
    }
    
    //Returns the SFM process for the requested type validating all profile access configured
    public Map<Id, SVMXC__ServiceMax_Processes__c> getAllowedSFW(String profileId)
    {
        Map<Id, SVMXC__ServiceMax_Processes__c> response = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        set<Id> availableProfiles = new set<Id>();
        set<Id> allowedSFW = new set<Id>();
        set<Id> assignedSFW = new set<Id>();

        Id grpProfileId;
        grpProfileId = getGroupProfileId(null, false);
        if(grpProfileId != null)
            availableProfiles.add(grpProfileId);
        for(SVMXC__ServiceMax_Config_Data__c profAccess : [SELECT Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where recordType.Name = 'Wizard Access'])
        {
            if(availableProfiles.contains(profAccess.SVMXC__Access_Configuration_Profile__c))
                allowedSFW.add(profAccess.SVMXC__Dispatch_Process__c);
            else
                assignedSFW.add(profAccess.SVMXC__Dispatch_Process__c);
        }
        assignedSFW.removeall(allowedSFW);
        
        set<String> wizardsToExclude = new set<String>();
        if(INTF_ServiceEventUtility.filterstoExclude != null && INTF_ServiceEventUtility.filterstoExclude.wizards != null && INTF_ServiceEventUtility.filterstoExclude.wizards.size() > 0)
            wizardsToExclude.addAll(INTF_ServiceEventUtility.filterstoExclude.wizards);
        
        string strSOQLWizards = 'Select Id, SVMXC__Select__c, SVMXC__Dispatch_Process_Status__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Submodule__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = \'Wizard\' and SVMXC__Active__c = true and Id NOT IN :assignedSFW';
        if(wizardsToExclude.size() > 0)
            strSOQLWizards += ' AND SVMXC__ProcessID__c NOT IN: wizardsToExclude';
        
        system.debug(LoggingLevel.WARN, 'Filters for SFW: ' + INTF_ServiceEventUtility.filterstoExclude);
        
        system.debug(LoggingLevel.WARN, 'ALLOWED SFW: ' + allowedSFW);
        response.putAll((List<SVMXC__ServiceMax_Processes__c>)database.query(strSOQLWizards));
        return response;
    }
    
    public Id getGroupProfileId(Id groupProfileId, Boolean returnDefaultProfile)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getGroupProfileId');
        // groupProfileId will be non-NULL when this function is invoked by Mobile Configuration page
        if(groupProfileId != NULL){
            INTF_DataSync.logMethodEndTS(intMethodCount , 'getGroupProfileId');
            return groupProfileId;
        }
        // If groupProfileId is NULL - this will be the case when this function is invoked by iPad Sync code
        list<SVMXC__ServiceMax_Config_Data__c> profileAccessLst = new list<SVMXC__ServiceMax_Config_Data__c>();

        // Get the Salesforce Profile Id of the logged in user, and get associated SVMX Group Profile if any & Active
        Id profileId = UserInfo.getProfileId();
        INTF_DataSync.logSOQL(intMethodCount , 'SELECT Id, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Configuration Access\' AND SVMXC__Profile__c = :profileId AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c = \'Configuration Profile\' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Active__c = True' );
        profileAccessLst = [SELECT Id, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Configuration Access' AND SVMXC__Profile__c = :profileId AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Active__c = True];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug(LoggingLevel.WARN, 'User Profile: ' + profileId + '; Associated Group Profile: ' + profileAccessLst);

        if(profileAccessLst != NULL && profileAccessLst.size() == 1)
        {
            INTF_DataSync.logMethodEndTS(intMethodCount,'getGroupProfileId');
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', 'SVMXC__Access_Configuration_Profile__c', COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }  
            else
            {          
                return profileAccessLst[0].SVMXC__Access_Configuration_Profile__c;
            }
        }
        // If the logged in user's Salesforce Profile is not associated with any SVMX Group Profile (possible) OR
        // if it is associated with >1 SVMX Group Profile (unlikely), get the Default Group Profile
        else if(returnDefaultProfile)
        {
            INTF_DataSync.logSOQL(intMethodCount ,'SELECT Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = \'Configuration Profile\' AND SVMXC__Configuration_Type__c = \'Group\' AND SVMXC__IsDefault__c = True');
            profileAccessLst = [SELECT Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = True];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug(LoggingLevel.WARN, 'Default Group Profile: ' + profileAccessLst);
            if(profileAccessLst != null && profileAccessLst.size() == 1)
            {
                INTF_DataSync.logMethodEndTS(intMethodCount, 'getGroupProfileId');
                return profileAccessLst[0].Id;
            }
            else{
                INTF_DataSync.logMethodEndTS(intMethodCount, 'getGroupProfileId');
                return null;
            }
        }
        else{
            INTF_DataSync.logMethodEndTS(intMethodCount, 'getGroupProfileId');
            return null;
        }
    }
    
    public Map<String, String> getDownloadCriteriaForAnyObject(Set<String> setObjNames, Id grpProfileId, DateTime dtLastSyncTime, Set<String> setIsModifiedFlag, String strDevConfId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getDownloadCriteriaForAnyObject');
        String strCurrTechLocId = '';
        Map<String, String> mapObjToCriteria = new Map<String, String>();
        
        INTF_DataSync.logSOQL(intMethodCount , 'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true AND SVMXC__Inventory_Location__c != null AND SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1');
        for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true AND SVMXC__Inventory_Location__c != null AND SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
        {
            strCurrTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
        }
        String strMobConfQuery  = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Ownership_Type__c, LastModifiedDate, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c = \'Download Criteria\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId AND SVMXC__Object_Name__c IN: setObjNames';
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        system.debug(LoggingLevel.WARN,'Query formed for getDownloadCriteriaForAnyObject = '+strMobConfQuery);
        
        INTF_DataSync.logSOQL(intMethodCount , strMobConfQuery);
        for(SVMXC__ServiceMax_Config_Data__c eachDCRec: Database.Query(strMobConfQuery))
        {
            String strCriteria = '';
            system.debug(LoggingLevel.WARN, 'eachDCRec = ' + eachDCRec);
            
            if(eachDCRec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null)
                strCriteria = ' ( ' + eachDCRec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ' ) ';
            
            if(eachDCrec.SVMXC__Ownership_Type__c == 'My Records')
            {
                if(strCriteria != '')
                    strCriteria += ' and ';
                /*else
                    strCriteria += ' WHERE ';*/
                strCriteria += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';
            }
            
            if(dtLastSyncTime != null && (eachDCRec.LastModifiedDate > dtLastSyncTime || eachDCRec.SVMXC__Dispatch_Process__r.LastModifiedDate > dtLastSyncTime))
                setIsModifiedFlag.add('true');
            
            strCriteria = strCriteria.replace('SVMX.CURRENTUSERID', UserInfo.getUserId());    
            strCriteria = strCriteria.replace('SVMX.CURRENTUSER', String.escapeSingleQuotes(UserInfo.getName()));
            strCriteria = strCriteria.replace('SVMX.USERTRUNK', strCurrTechLocId);
            system.debug(LoggingLevel.WARN, 'Object Name = ' + eachDCRec.SVMXC__Object_Name__c + '; Criteria = ' + strCriteria);
            mapObjToCriteria.put(eachDCRec.SVMXC__Object_Name__c, strCriteria);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'getDownloadCriteriaForAnyObject');
        return mapObjToCriteria;
    }
    
    public Map<String, String> getAdvDownloadCriteriaForAnyObject(Set<String> setObjNames, Id grpProfileId, Set<String> setWhatIds, DateTime dtLastSyncTime, Set<String> setIsModifiedFlag, String strDevConfId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getAdvDownloadCriteriaForAnyObject');
        Map<String, String> mapObjToCriteria = new Map<String, String>();
        List<SVMXC__ServiceMax_Config_Data__c> lstAdvMobConfigForGrpProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
        //Get Device Specific Mobile Config
        String strMobConfQuery  = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Display_Type__c, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Object_Name__c IN: setObjNames and SVMXC__Display_Type__c = \'Advanced Download Criteria\' AND RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId ';
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        system.debug(LoggingLevel.WARN,'Query formed for getAdvDownloadCriteriaForAnyObject = '+strMobConfQuery);
        
        INTF_DataSync.logSOQL(intMethodCount , strMobConfQuery );
        //lstAdvMobConfigForGrpProfile = [select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Display_Type__c, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Object_Name__c IN: setObjNames and SVMXC__Display_Type__c = 'Advanced Download Criteria' AND RecordType.Name = 'Mobile Configuration' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId ];
        lstAdvMobConfigForGrpProfile = Database.Query(strMobConfQuery);
        
        if(setWhatIds != null && setWhatIds.size() > 0)
        {
            for(SVMXC__ServiceMax_Config_Data__c eachDCrec : lstAdvMobConfigForGrpProfile)
            {
                if(dtLastSyncTime != null && (eachDCrec.LastModifiedDate > dtLastSyncTime || eachDCrec.SVMXC__Dispatch_Process__r.LastModifiedDate > dtLastSyncTime))
                    setIsModifiedFlag.add('true');
                        
                INTF_WebServicesDef.SVMXMap responseEachDCObject = new INTF_WebServicesDef.SVMXMap();
                responseEachDCObject.key = eachDCrec.SVMXC__Object_Name__c;
                if(eachDCrec.SVMXC__Object_Name__c != null && eachDCrec.SVMXC__Display_Type__c == 'Advanced Download Criteria')
                {
                    String strCriteria = '';
                    if(eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0)
                    {
                        strCriteria = '((' + eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                        system.debug(LoggingLevel.WARN, 'Saved Criteria = ' + eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c);
                        INTF_DataSync.logSOQL(intMethodCount , 'select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Expressions\' AND SVMXC__Expression_Rule__c =: eachDCRec.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC');
                        for(SVMXC__ServiceMax_Config_Data__c eachDCExpr : [select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Rule__c =: eachDCRec.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC])
                        {
                            String strObjNameAndField = '';
                            if(((eachDCExpr.SVMXC__Display_Type__c == 'REFERENCE' || eachDCExpr.SVMXC__Display_Type__c == 'ID') && eachDCExpr.SVMXC__Object_Name2__c != null))
                            {
                                String strReferenceFieldIds = '';
                                strObjNameAndField += '\':' + eachDCExpr.SVMXC__Object_Name2__c + '\',\'' + eachDCExpr.SVMXC__Source_Field_Name__c + '\'';
                                INTF_DataSync.logSOQL(intMethodCount ,'Select ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id IN :setWhatIds');
                                for(sobject sObj : Database.query('Select ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id IN :setWhatIds'))
                                {
                                    system.debug(LoggingLevel.WARN, 'Source Field Value = ' + sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c));
                                    if(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c) != null)
                                    {
                                        if(strReferenceFieldIds != '')
                                            strReferenceFieldIds += ',';
                                        strReferenceFieldIds += '\'' + String.valueOf(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c)) + '\'';
                                    }     
                                }
                                if(strReferenceFieldIds == '')
                                    strReferenceFieldIds = '\'DummyListOfIds1\'';  
                                strCriteria = strCriteria.replace(strObjNameAndField, strReferenceFieldIds);
                            }
                            else
                            {
                                //criteria exists in variable strCriteria.
                            }
                        }
                    }
                    else
                    {
                        strCriteria = '';
                    }
                    if(eachDCrec.SVMXC__Ownership_Type__c == 'My Records')
                    {
                        if(strCriteria != '')
                            strCriteria = ' ( '+strCriteria+' ) and ';
                        else
                            strCriteria += '(';
                        strCriteria += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';  
                        
                    }
                    
                    strCriteria += ')';
                    system.debug(LoggingLevel.WARN, 'Each Object = ' + eachDCrec.SVMXC__Object_Name__c + '; Criteria = ' + strCriteria);
                    mapObjToCriteria.put(eachDCrec.SVMXC__Object_Name__c, strCriteria);
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'getAdvDownloadCriteriaForAnyObject');
        return mapObjToCriteria;
    }
    
    public Set<String> getEventRelatedWOIDs(Id idGrpProfile, DateTime dtLastSyncTime, Set<String> setIsModifiedFlag, Set<String> setMdfdWhatIds, String strDevConfId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getEventRelatedWOIDs');
        Datetime dtToDate, dtFromDate, dtMovingDate;
        Datetime currentTime = Datetime.now();
        String strUserId = UserInfo.getUserId();
        Set<String> setWhatIds = new Set<String>();
        String strTimeClause = '', strMovingDateClause1 = '', strMovingDateClause2 = '';
        
        if(idGrpProfile != null)
        {
            //Get Device Specific Mobile Config
            String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            system.debug(LoggingLevel.WARN,'Query formed for getEventRelatedWOIDs = '+strMobConfQuery);
        
            INTF_DataSync.logSOQL(intMethodCount , strMobConfQuery );
            
            for(SVMXC__ServiceMax_Config_Data__c objConfigData : Database.Query(strMobConfQuery))
            {
                Integer intValue = 10;
                if(objConfigData.SVMXC__Display_Type__c == 'Synchronization To Remove Events')
                {
                    if(objConfigData.SVMXC__Internal_value__c != null && objConfigData.SVMXC__Internal_value__c.length() > 0)
                    {
                        intValue = Integer.valueOf(objConfigData.SVMXC__Internal_value__c);
                        if(intValue < 1)
                            intValue = 10;
                    }   
                    dtFromDate = currentTime - (intValue + 1);
                }   
                else if(objConfigData.SVMXC__Display_Type__c == 'Synchronization To Get Events')
                {
                    if(objConfigData.SVMXC__Internal_value__c != null && objConfigData.SVMXC__Internal_value__c.length() > 0)
                    {
                        intValue = Integer.valueOf(objConfigData.SVMXC__Internal_value__c);
                        if(intValue < 1)
                            intValue = 10;
                    }   
                    dtToDate = currentTime + intValue + 1;
                    if(dtLastSyncTime != null)
                        dtMovingDate = dtLastSyncTime + intValue + 1;
                }
                if(dtLastSyncTime != null && objConfigData.LastModifiedDate > dtLastSyncTime)
                    setIsModifiedFlag.add('true');
            }
                    
            if(dtLastSyncTime != null && !setIsModifiedFlag.contains('true'))
            {
                INTF_DataSync.logSOQL(intMethodCount ,'Select What.Id from Event where ((StartDateTime >= :dtMovingDate AND StartDateTime <= :dtToDate) OR (EndDateTime >= :dtMovingDate AND EndDateTime <= :dtToDate) OR (((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) AND LastModifiedDate >= :dtLastSyncTime)) AND OwnerId = :strUserId AND WhatId != null');
                for(Event evt :Database.query('Select What.Id from Event where ((StartDateTime >= :dtMovingDate AND StartDateTime <= :dtToDate) OR (EndDateTime >= :dtMovingDate AND EndDateTime <= :dtToDate) OR (((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) AND LastModifiedDate >= :dtLastSyncTime)) AND OwnerId = :strUserId AND WhatId != null'))
                    setMdfdWhatIds.add(evt.What.Id);
                    
                INTF_DataSync.logSOQL(intMethodCount , 'Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate) OR (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) AND LastModifiedDate >= :dtLastSyncTime)) AND SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId AND SVMXC__WhatId__c != null');
                for(SVMXC__SVMX_Event__c evt :Database.query('Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate) OR (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) AND LastModifiedDate >= :dtLastSyncTime)) AND SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId AND SVMXC__WhatId__c != null'))
                    setMdfdWhatIds.add(evt.SVMXC__WhatId__c);
            }
            INTF_DataSync.logSOQL(intMethodCount , 'Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) AND OwnerId = :strUserId AND WhatId != null');
            for(Event evt :Database.query('Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) AND OwnerId = :strUserId AND WhatId != null'))
                setWhatIds.add(evt.What.Id);
            
            INTF_DataSync.logSOQL(intMethodCount , 'Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null');
            for(SVMXC__SVMX_Event__c evt :Database.query('Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null'))
                setWhatIds.add(evt.SVMXC__WhatId__c);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'getEventRelatedWOIDs');
        return setWhatIds;
    }
}