public with sharing class SFT_Utility {
    public SFT_Utility(){}
  /*
  //INTF_PopulateKeyValueFromsObject clsPopulateKeyValue = new INTF_PopulateKeyValueFromsObject();
  SVMX_Constants clsConstant = new SVMX_Constants();

  public class objectAccess
  {
      public set<String> transactionalObjects{get; set;}
      public set<String> lookupObjects{get; set;}
      public Map<String, set<String>> mapObjectProcess{get; set;}
    public Map<String, set<String>> mapProcessObject{get; set;}
    public Map<String, set<String>> mapLookupObjectProcess{get; set;}
    public Map<String, String> mapProcessPurpose{get; set;}
  }
  
  // For the given profiles, get all the allowed processes
  public Map<Id, SVMXC__ServiceMax_Processes__c> getSFMTransactions(String profileId)
  {
    INTF_GetServiceFlowAccess flowAccess = new INTF_GetServiceFlowAccess();
    Map<Id, SVMXC__ServiceMax_Processes__c> mapAllowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
    mapAllowedProcess = flowAccess.INTF_getAllAllowedProcessed(profileId);
    return mapAllowedProcess;
  }
  
  // Get all transactional and lookup objects for the requested processes
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
    List<INTF_WebServicesDef.SVMXMap> picklistDefinitions = new List<INTF_WebServicesDef.SVMXMap>();
    INTF_GetObjectDefinition clsObjectDef = new INTF_GetObjectDefinition();
    set<String> processedObjects = new set<String>();
    for(String objectName: objects)
    {
      clsObjectDef.objectName = objectName;
      try
      {
        INTF_WebServicesDef.SVMXMap objPicklistDef = clsObjectDef.INTF_GetPicklistDefinition();
        picklistDefinitions.add(objPicklistDef);
        processedObjects.add(objectName);
      }
      catch(exception ex)
      {
        break;
      }
    }
    List<String> unprocessedObjects = new List<String>();
    for(String objectName: objects)
    {
      if(!processedObjects.contains(objectName))
        unprocessedObjects.add(objectName);
    }
    response.valueMap = picklistDefinitions;
    response.values = unprocessedObjects;
    return response;
  }
  
  // Get all transactional and lookup object definitions for the given processes
  public Map<String, INTF_WebServicesDef.SVMXMap> getServiceFlowObjectDef(Map<Id, SVMXC__ServiceMax_Processes__c> processes)
  {
    Map<String, INTF_WebServicesDef.SVMXMap> mapObjDefinitions = new Map<String, INTF_WebServicesDef.SVMXMap>();
    INTF_GetObjectDefinition clsObjectDef = new INTF_GetObjectDefinition();
    set<String> objectName = new set<String>();
    
    // Getting allowed objects
    objectAccess objAccess = new objectAccess();
    objAccess = getSFMTxObjects(processes);
    
    if(objAccess.transactionalObjects != NULL && objAccess.transactionalObjects.size() > 0)
      objectName.addAll(objAccess.transactionalObjects);
    if(objAccess.lookupObjects != NULL && objAccess.lookupObjects.size() > 0)
      objectName.addAll(objAccess.lookupObjects);
    
    if(objectName != NULL)
    {
      for(String objName: objectName)
      {
        // Set object name and get the object definition
        clsObjectDef.objectName = objName;
        INTF_WebServicesDef.SVMXMap objDef = clsObjectDef.INTF_GetObjectDefinition();
        if(objDef != NULL)
        {
          mapObjDefinitions.put(objDef.value, objDef);
        }
      }
    }
    return mapObjDefinitions;
  }
  
  // For the given object, this method gets data considering record type
  public List<INTF_WebServicesDef.SVMXMap> getServiceFlowObjData(Map<Id, SVMXC__ServiceMax_Processes__c> processes)
  {
    List<INTF_WebServicesDef.SVMXMap> response = new List<INTF_WebServicesDef.SVMXMap>();
    set<Id> setProcessIds = new set<Id>();
    set<Id> setPageLayoutIds = new set<Id>();
    
    if(processes != NULL && processes.size() > 0)
    {
      for(SVMXC__ServiceMax_Processes__c proc: processes.values())
      {
        setProcessIds.add(proc.Id);
        setPageLayoutIds.add(proc.SVMXC__Page_Layout__c);
      }
      // Get process data wich includes process, process node object, expressions, mapping
      INTF_WebServicesDef.SVMXMap processInfo = new INTF_WebServicesDef.SVMXMap();
      processInfo = getServiceFlowProcesses(setProcessIds);
      INTF_WebServicesDef.SVMXMap wrpProcess = new INTF_WebServicesDef.SVMXMap();
      wrpProcess.key = 'PROCESS';
      wrpProcess.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
      wrpProcess.valueMap.add(processInfo);
      response.add(wrpProcess);
      // Get page data which includes page layout, page layout details, named search
      INTF_WebServicesDef.SVMXMap wrpPage = new INTF_WebServicesDef.SVMXMap();
      wrpPage = getServiceFlowPageLayouts(setPageLayoutIds);
      wrpPage.key = 'PAGE';
      response.add(wrpPage);
    }
    return response;
  }
  
  // To get page layouts for the given processes
  
  public INTF_WebServicesDef.SVMXMap getServiceFlowPageLayouts(set<Id> setPageLayoutIds)
  {
    INTF_WebServicesDef.SVMXMap response = new INTF_WebServicesDef.SVMXMap();
    List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
    List<SVMXC__Page_Layout__c> lstAvailablePageHeaders = new List<SVMXC__Page_Layout__c>();
    List<SVMXC__Page_Layout__c> lstProcessPage = new List<SVMXC__Page_Layout__c>();
    List<SVMXC__SFM_Event__c> lstPageDetailEvents = new List<SVMXC__SFM_Event__c>();
    List<SVMXC__Page_Layout_Detail__c> lstPageLayoutDetails = new List<SVMXC__Page_Layout_Detail__c>();
    set<Id> setNamedSearchIds = new set<Id>();
    
    lstAvailablePageHeaders = [Select SVMXC__Type__c,SVMXC__Sequence__c,SVMXC__Prompt_For_New_Event__c,SVMXC__Enable_Attachments__c,SVMXC__Enable_Chatter__c,SVMXC__Show_Account_History__c,SVMXC__Show_All_Sections_By_Default__c,SVMXC__Show_Product_History__c,
                   SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Enable_Service_Report_View__c, SVMXC__Enable_Troubleshooting__c, SVMXC__Enable_Service_Report_Generation__c, 
                   SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c, SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, Name, Id From SVMXC__Page_Layout__c where Id IN :setPageLayoutIds];
    // Adding page layouts to response
    if(lstAvailablePageHeaders != NULL && lstAvailablePageHeaders.size() > 0)
    {
      lstProcessPage.addAll(lstAvailablePageHeaders);
      // Adding page layout details to wrapper
      List<SVMXC__Page_Layout_Detail__c> lstExistingPageLayoutDetails = [Select SVMXC__Related_Object_Name_Field__c, SVMXC__Title__c, SVMXC__IsStandard__c,SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c,SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c,   SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id,SVMXC__No_of_columns__c, SVMXC__Enable_Chatter__c, SVMXC__Control_Type__c, SVMXC__Maximum_Value__c, SVMXC__Minimum_Value__c, SVMXC__Use_For_SLA_Clock__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN :setPageLayoutIds];
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
        }
        // Page level events and field level events
        List<SVMXC__SFM_Event__c> lstExistingPageDetailEvents = [Select SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, Name, Id from SVMXC__SFM_Event__c where SVMXC__Page_Layout__c IN : setPageLayoutIds OR SVMXC__Page_Layout_Detail__c IN : setPageDetailId];
        lstPageDetailEvents.addAll(lstExistingPageDetailEvents);
      }
      // Page layout relatedlist details
      List<SVMXC__Page_Layout__c> lstExistingPageLayoutrelatedList = [Select SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c,  SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, Name, Id From SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c IN :setPageLayoutIds];
      if(lstExistingPageLayoutrelatedList.size()>0)
      {
        lstProcessPage.addAll(lstExistingPageLayoutrelatedList);
        set<Id> pageDetailId = new set<Id>();
        for(SVMXC__Page_Layout__c detailPage: lstExistingPageLayoutrelatedList)
        {
          pageDetailId.add(detailPage.Id);
        }
        List<SVMXC__Page_Layout_Detail__c> lstExistingPageLayoutDetailsDetails = [Select SVMXC__Related_Object_Name_Field__c, SVMXC__IsStandard__c,SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id ,SVMXC__No_of_columns__c, SVMXC__Enable_Chatter__c, SVMXC__Control_Type__c, SVMXC__Maximum_Value__c, SVMXC__Minimum_Value__c, SVMXC__Use_For_SLA_Clock__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN :pageDetailId];
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
          }
          List<SVMXC__SFM_Event__c> lstExistingPageDetailEvents = [Select SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, Name, Id from SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : detailPageDetailId];
          lstPageDetailEvents.addAll(lstExistingPageDetailEvents);
        }
      }
*************/      
      /*  
      INTF_WebServicesDef.SVMXMap wrpProcessPage = new INTF_WebServicesDef.SVMXMap();
      wrpProcessPage.key = 'SVMXC__Page_Layout__c';
      wrpProcessPage.data = lstProcessPage;
      lstResponse.add(wrpProcessPage);
      
      INTF_WebServicesDef.SVMXMap wrpPageDetails = new INTF_WebServicesDef.SVMXMap();
      wrpPageDetails.key = 'SVMXC__Page_Layout_Detail__c';
      wrpPageDetails.data = lstPageLayoutDetails;
      lstResponse.add(wrpPageDetails);
      
      if(lstPageDetailEvents != NULL && lstPageDetailEvents.size() > 0)
      {
        INTF_WebServicesDef.SVMXMap wrpProcessEvents = new INTF_WebServicesDef.SVMXMap();
        wrpProcessEvents.key = 'SVMXC__SFM_Event__c';
        wrpProcessEvents.data = lstPageDetailEvents;
        lstResponse.add(wrpProcessEvents);
      } */
/********      
      if(setNamedSearchIds.size() > 0)
      {
        INTF_WebServicesDef.SVMXMap wrpNamedSearch = new INTF_WebServicesDef.SVMXMap();
        wrpNamedSearch = getServiceFlowNamedSearch(setNamedSearchIds);
        wrpNamedSearch.key = 'NAMEDSEARCH';
        lstResponse.add(wrpNamedSearch);
      }
      response.valueMap = lstResponse;
    }
    return response;
  }*/
  
  /*
  // To get mapping for the given processes
  public List<INTF_WebServicesDef.SVMXMap> getServiceFlowObjectMapping(set<Id> setMapIds)
  {
    List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
    List<SVMXC__ServiceMax_Processes__c> availableMappingHeader = new List<SVMXC__ServiceMax_Processes__c>();
    availableMappingHeader = [SELECT SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c, SVMXC__Description__c, Name, Id,SVMXC__Name__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Id IN :setMapIds];
      
      if(availableMappingHeader != NULL && availableMappingHeader.size() > 0)
      {
        INTF_WebServicesDef.SVMXMap wrpProcessMapping = new INTF_WebServicesDef.SVMXMap();
      wrpProcessMapping.key = 'SFObject_mapping';
      //wrpProcessMapping.data = availableMappingHeader;
      wrpProcessMapping.valueMap = getKeyValueForData(clsConstant.getObjectMappingHeaderDefinition(), availableMappingHeader);
      lstResponse.add(wrpProcessMapping);
      
      List<SVMXC__ServiceMax_Config_Data__c> lstExistingMappingDetails = [Select SVMXC__MapID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c,   SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, Name, Id, SVMXC__Preference_2__c, SVMXC__Preference_3__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c IN :setMapIds and Recordtype.Name='Field Mapping'];
          if(lstExistingMappingDetails != NULL && lstExistingMappingDetails.size() > 0)
          {
            INTF_WebServicesDef.SVMXMap wrpProcessMappingDetails = new INTF_WebServicesDef.SVMXMap();
        wrpProcessMappingDetails.key = 'SFObject_mapping_component';
        //wrpProcessMappingDetails.data = lstExistingMappingDetails;
        wrpProcessMappingDetails.valueMap = getKeyValueForData(clsConstant.getObjectMappingDetailDefinition(), lstExistingMappingDetails);
        lstResponse.add(wrpProcessMappingDetails);
          }
      }
      return lstResponse;
  }
  */
  /*
  // To get expressions for the given processes
  public List<INTF_WebServicesDef.SVMXMap> getServiceFlowExpressions(set<Id> setExpressionIds)
  {
    List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
    List<SVMXC__ServiceMax_Processes__c> availableNamedExpressions = new List<SVMXC__ServiceMax_Processes__c>();
    availableNamedExpressions = [Select Id, SVMXC__IsStandard__c, SVMXC__Source_Object_Name__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Values__c, SVMXC__Sequence__c, SVMXC__Advance_Expression__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id IN :setExpressionIds];
    
    for(SVMXC__ServiceMax_Processes__c expression: availableNamedExpressions)
    {
      if(expression.SVMXC__Advance_Expression__c == NULL || expression.SVMXC__Advance_Expression__c == '')
        expression.SVMXC__Advance_Expression__c = '1';
    }
      if(availableNamedExpressions != NULL && availableNamedExpressions.size() > 0)
      {
    INTF_WebServicesDef.SVMXMap wrpProcessExpressions = new INTF_WebServicesDef.SVMXMap();
        wrpProcessExpressions.key = 'SFExpression';
        //wrpProcessExpressions.data = availableNamedExpressions;
        wrpProcessExpressions.valueMap = getKeyValueForData(clsConstant.getObjectExpressionHeaderDefinition(), availableNamedExpressions);
        lstResponse.add(wrpProcessExpressions);
      
      List<SVMXC__ServiceMax_Config_Data__c> lstExistingExpressionDetails = [Select Id, SVMXC__Internal_Value__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__Expression_Rule__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Type__c From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Expressions' AND SVMXC__Expression_Type__c = 'EXP_Named' And SVMXC__Expression_Rule__c IN :setExpressionIds];
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
  */
  /*
  // To get named search for the given processes
  public INTF_WebServicesDef.SVMXMap getServiceFlowNamedSearch(set<Id> setNamedSearchIds)
  {
    INTF_WebServicesDef.SVMXMap response = new INTF_WebServicesDef.SVMXMap();
    List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
    List<SVMXC__ServiceMax_Processes__c> availableNamedSearchObjectHeader = new List<SVMXC__ServiceMax_Processes__c>();
    availableNamedSearchObjectHeader = [SELECT Id, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Source_Object_Name__c, SVMXC__Rule_Type__c, SVMXC__Sequence__c, SVMXC__Process__c, SVMXC__IsStandard__c, SVMXC__IsDefault__c, SVMXC__Number_of_Lookup_Records__c, SVMXC__Default_Lookup_Column__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND (SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG') AND (Id IN :setNamedSearchIds)];
    //availableNamedSearchObjectHeader = [SELECT Id, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Source_Object_Name__c, SVMXC__Rule_Type__c, SVMXC__Sequence__c, SVMXC__Process__c, SVMXC__IsStandard__c, SVMXC__IsDefault__c, SVMXC__Number_of_Lookup_Records__c, SVMXC__Default_Lookup_Column__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND (SVMXC__Rule_Type__c = 'SRCH_OBJECT' or SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG') AND (SVMXC__Module__c IN :setNamedSearchIds or Id IN :setNamedSearchIds)];
  
      if(availableNamedSearchObjectHeader != NULL && availableNamedSearchObjectHeader.size() > 0)
      {
        INTF_WebServicesDef.SVMXMap wrpProcessNamedSearch = new INTF_WebServicesDef.SVMXMap();
      wrpProcessNamedSearch.key = 'SFNAMEDSEARCH';
      wrpProcessNamedSearch.valueMap = getKeyValueForData(clsConstant.getNamedSearchHeaderDefinition(), availableNamedSearchObjectHeader);
      lstResponse.add(wrpProcessNamedSearch);
      
      List<SVMXC__ServiceMax_Config_Data__c> lstExistingNamedSearchDetails = [Select Id, SVMXC__Internal_Value__c, SVMXC__Expression_Rule__c, SVMXC__Field_Name__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Sequence__c, SVMXC__Field_Relationship_Name__c, SVMXC__Display_Type__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__r.SVMXC__Module__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__r.SVMXC__Module__c IN : setNamedSearchIds and Recordtype.Name = 'Expressions' and SVMXC__Search_Object_Field_Type__c != 'Bubble'];
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
  */
  /*
  // To get process and process node definition for the given processes
  public INTF_WebServicesDef.SVMXMap getServiceFlowProcesses(set<Id> setProcessIds)
  {
    INTF_WebServicesDef.SVMXMap response = new INTF_WebServicesDef.SVMXMap();
    List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
    
    set<Id> setMapIds = new set<Id>();
    set<Id> setExpressionIds = new set<Id>();
    
    // Get all process header definition
    List<SVMXC__ServiceMax_Processes__c> availableprocessHeader = new List<SVMXC__ServiceMax_Processes__c>();
      availableprocessHeader = [Select Id, Name, SVMXC__Purpose__c, SVMXC__Page_Layout__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, 
                      SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Node_Source_Object_API__c, 
                      SVMXC__IsStandard__c,SVMXC__IsStandalone__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Target Manager' AND Id IN :setProcessIds];

      // Get all process node object definition
      if(availableprocessHeader != NULL && availableprocessHeader.size() > 0)
      {
      List<SVMXC__ServiceMax_Processes__c> processNodeObject = [Select Name,SVMXC__Parent_Object__c,SVMXC__MapID__c,SVMXC__Purpose__c, SVMXC__Parent_Column_Name__c, SVMXC__Node_Parent_API__c, SVMXC__ProcessID__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Page_Layout__c,
                        SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Node_Source_Object_API__c,
                        SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c,SVMXC__Final_Exception_Process__c,LastModifiedBy.Name, CreatedBy.Name 
                        From SVMXC__ServiceMax_Processes__c 
                        where Recordtype.Name='Process Node Objects' And SVMXC__Process__c IN :setProcessIds];
      
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
      
      // To get source updates for process
      list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdate = [Select SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c,   SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, Name, Id, SVMXC__Preference_2__c, SVMXC__Preference_3__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN :setProcessIds and Recordtype.Name='Field Mapping'];
          
          if(lstSourceUpdate != NULL && lstSourceUpdate.size() > 0)
          {
                INTF_WebServicesDef.SVMXMap wrpSourceUpdate = new INTF_WebServicesDef.SVMXMap();
                wrpSourceUpdate.key = 'SVMXC__ServiceMax_Config_Data__c';
                wrpSourceUpdate.data = lstSourceUpdate;
                lstResponse.add(wrpSourceUpdate);
          }
          if(setMapIds != NULL && setMapIds.size() > 0)
          {
            //INTF_WebServicesDef.SVMXMap wrpMapping = new INTF_WebServicesDef.SVMXMap();
        //wrpMapping.key = 'OBJECTMAPPING';
        //wrpMapping.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        //wrpMapping.valueMap.add(getServiceFlowObjectMapping(setMapIds));
        lstResponse.addAll(getServiceFlowObjectMapping(setMapIds));
          }
          if(setExpressionIds != NULL && setExpressionIds.size() > 0)
          {
            //INTF_WebServicesDef.SVMXMap wrpMapping = new INTF_WebServicesDef.SVMXMap();
        //wrpMapping.key = 'EXPRESSIONS';
        //wrpMapping.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        //wrpMapping.valueMap.add(getServiceFlowExpressions(setExpressionIds));
        lstResponse.addAll(getServiceFlowExpressions(setExpressionIds));
          }
      }
      response.valueMap = lstResponse;
      return response;     
  }
  */
  /*
  // To get the SFW data for the SFM Actions
  public List<INTF_WebServicesDef.SVMXMap> getServiceFlowWizards(Map<Id, SVMXC__ServiceMax_Processes__c> processes)
  {
    set<ID> setProcessIds = new set<ID>();
    set<ID> setSFWIds = new set<ID>();
    set<ID> setExpressionIds = new set<ID>();
    Id currentExpression = null;
    List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
    try
    {
      setSFWIds = processes.keySet();
      System.debug('setProcessIds' + setProcessIds);
      // get the steps for the Wizard steps for the available SFM Transactions
      List<SVMXC__ServiceMax_Processes__c> lstWizardsSteps = new List<SVMXC__ServiceMax_Processes__c> ();
      lstWizardsSteps = [Select Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Action_Type__c, SVMXC__Action_URL__c, SVMXC__Module__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__ProcessID__c, SVMXC__Sequence__c, SVMXC__IsStandard__c, SVMXC__Active__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Wizard Step' and SVMXC__Module__c In :setSFWIds and SVMXC__Action_Type__c = 'SFM'];    
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
      lstAvailableWizards = [Select Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Module__c,SVMXC__Submodule__c, SVMXC__ProcessID__c, SVMXC__Object_Key_Prefix__c, SVMXC__Dispatch_Process_Status__c, SVMXC__IsStandard__c, SVMXC__Active__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Wizard' and ID In :setSFWIds];
      if(lstAvailableWizards.size() > 0)
      {
        for(SVMXC__ServiceMax_Processes__c objCurrWizard : lstAvailableWizards)
        {
          currentExpression = objCurrWizard.SVMXC__Submodule__c;
          if(currentExpression != null)
          {        
            setExpressionIds.add(currentExpression);
          }        
        }
      }
      // Get the Expressions data
      if(setExpressionIds != NULL && setExpressionIds.size() > 0)
          {
            //INTF_WebServicesDef.SVMXMap wrpMapping = new INTF_WebServicesDef.SVMXMap();
        //wrpMapping.key = 'EXPRESSIONS';
        //wrpMapping.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        //wrpMapping.valueMap.add(getServiceFlowExpressions(setExpressionIds));
        lstResponse.addAll(getServiceFlowExpressions(setExpressionIds));
          }
      
      //Building the response for the ServiceMax Processes
      INTF_WebServicesDef.SVMXMap wrpProcessWizard = new INTF_WebServicesDef.SVMXMap();
      wrpProcessWizard.key = 'SFW_wizard';
      wrpProcessWizard.valueMap = getKeyValueForData(clsConstant.getSFWWizard(), lstAvailableWizards);
      lstResponse.add(wrpProcessWizard);
      INTF_WebServicesDef.SVMXMap wrpProcessWizardSteps = new INTF_WebServicesDef.SVMXMap();
      wrpProcessWizardSteps.key = 'SFW_wizard_steps';
      wrpProcessWizardSteps.valueMap = getKeyValueForData(clsConstant.getSFWWizardActions(), lstWizardsSteps);
      lstResponse.add(wrpProcessWizardSteps);
      
      return lstResponse;
      
    }catch(Exception ex)
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
  */
  /*
  // Returns the SFM process for the requested type validating all profile access configured
    public Map<Id, SVMXC__ServiceMax_Processes__c> getAllowedSFW(String profileId)
    {
      Map<Id, SVMXC__ServiceMax_Processes__c> response = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> profileAccessLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        set<Id> availableProfiles = new set<Id>();
        set<Id> allowedSFW = new set<Id>();
        if(profileId == NULL)
          profileAccessLst = [SELECT Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where recordType.Name = 'Configuration Access' AND SVMXC__Profile__c = :UserInfo.getProfileId()];
        else
      profileAccessLst = [SELECT Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where recordType.Name = 'Configuration Access' AND SVMXC__Profile__c = :UserInfo.getProfileId() AND SVMXC__Access_Configuration_Profile__r.SVMXC__Access_Configuration_Profile__c =: profileId];
        
        for(SVMXC__ServiceMax_Config_Data__c profAccess: profileAccessLst)
        {
          availableProfiles.add(profAccess.SVMXC__Access_Configuration_Profile__c);
        }
        
        profileAccessLst = [SELECT Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where recordType.Name = 'Wizard Access' AND SVMXC__Access_Configuration_Profile__c IN :availableProfiles];
        for(SVMXC__ServiceMax_Config_Data__c profAccess: profileAccessLst)
        {
          allowedSFW.add(profAccess.SVMXC__Dispatch_Process__c);
        }
        response.putAll([Select Id, SVMXC__Select__c, SVMXC__Dispatch_Process_Status__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Submodule__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = 'Wizard' and Id IN :allowedSFW ]);
        return response;
    }
    */
     static testMethod void SFT_Utility_Test()
    {
        SFT_Utility SFTUtilObj = new SFT_Utility();
        //SFTUtilObj.getSFMTransactions('');
    }
}