/* Security Scanned */
public with sharing class SFM_DeployNamedSearch {
  Boolean isSucess = TRUE;
  String namedSearchRecId;
  String namedSearchDetailRecId;
  SVMX_Debug log = new SVMX_Debug();
  SFM_Utils utils = new SFM_Utils();
  List<SFM_WrapperDef.SFM_StringMap> sourceTargetNamedSearchId = new List<SFM_WrapperDef.SFM_StringMap>();

  public SFM_DeployNamedSearch()
  {
    List<String> recTypeNames = new List<String>();
    recTypeNames.add('SVMXC__ServiceMax_Processes__c~Named Search');
    recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
    Map<String, Id> mapRecType_Map = new Map<String, Id>();
    mapRecType_Map = utils.getRecordTypes(recTypeNames);
    namedSearchRecId = mapRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');  
    namedSearchDetailRecId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'); 
    }
    
  public SFM_WrapperDef.SFM_Response SFM_DeployNamedSearch(SFM_WrapperDef.SFM_Request_NamedSearchInfo request)
  {
    SFM_WrapperDef.SFM_Response oResponse=new SFM_WrapperDef.SFM_Response();
    Map<String, SVMXC__ServiceMax_Processes__c> namedSearchHeader = new Map<String, SVMXC__ServiceMax_Processes__c>();
    Map<String, SVMXC__ServiceMax_Processes__c> namedSearchHeaderObject = new Map<String, SVMXC__ServiceMax_Processes__c>();
    Map<String, list<SVMXC__ServiceMax_Config_Data__c>> namedSearchDetails = new Map<String, list<SVMXC__ServiceMax_Config_Data__c>>();
    Set<String> requestedNamedSearchName = new Set<String>();
    Set<String> existingNamedSearchName = new Set<String>();
    List<String> createdNamedSearchName = new List<String>();
    Map<String,String> mapRequest = new Map<String,String>();
        mapRequest = utils.getStringMap(request.request.stringMap);
        
        //log.login('SFM_DeployNamedSearch', 'SFM_DeployNamedSearch\n');
    Savepoint sp = Database.setSavepoint();//Setting up save point
    try
        {
      for(SFM_WrapperDef.SFM_NamedSearchInfo namedSearchinfo: request.namedSearch)
      {
        SVMXC__ServiceMax_Processes__c namedSearchHeaderDef = namedSearchinfo.namedSearchHdr;
        SVMXC__ServiceMax_Processes__c namedSearchHeaderObjectDef = new SVMXC__ServiceMax_Processes__c();
        
        namedSearchHeaderDef.RecordTypeId = namedSearchRecId;
        requestedNamedSearchName.add(namedSearchHeaderDef.SVMXC__ProcessID__c);
        namedSearchHeader.put(namedSearchHeaderDef.SVMXC__ProcessID__c, namedSearchHeaderDef);
        
        // Build field property
        list<SVMXC__ServiceMax_Config_Data__c> namedSearchProperties = new list<SVMXC__ServiceMax_Config_Data__c>();
        for(SFM_WrapperDef.SFM_NamedSearchInfoDetail details: namedSearchinfo.namedSearchDetails)
        {
          if(details.fields != NULL)
          {
            namedSearchHeaderObjectDef = details.objectDetails;
            namedSearchProperties.addAll(details.fields);
          }
        }
        
        namedSearchHeaderObject.put(namedSearchHeaderDef.SVMXC__ProcessID__c, namedSearchHeaderObjectDef);
        namedSearchDetails.put(namedSearchHeaderDef.SVMXC__ProcessID__c, namedSearchProperties);
      }
      List<SVMXC__ServiceMax_Processes__c> availableNamedSearchHeader = new List<SVMXC__ServiceMax_Processes__c>();
      availableNamedSearchHeader = [SELECT Id, Name, SVMXC__IsStandard__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Source_Object_Name__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG' AND SVMXC__ProcessID__c IN :requestedNamedSearchName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
      
      if(availableNamedSearchHeader.size() > 0)
      {
        Map<String, Id> mapAvailableNamedSearchId = new Map<String, Id>();
        Map<Id, Id> mapHeaderObjectId = new Map<Id, Id>();
        
        for(SVMXC__ServiceMax_Processes__c availableNamedSearchHeaderdata: availableNamedSearchHeader)
        {
          mapAvailableNamedSearchId.put(availableNamedSearchHeaderdata.SVMXC__ProcessID__c, availableNamedSearchHeaderdata.Id);
        }
        
        List<SVMXC__ServiceMax_Processes__c> availableNamedSearchObjectHeader = new List<SVMXC__ServiceMax_Processes__c>();
        availableNamedSearchObjectHeader = [SELECT Id, SVMXC__IsStandard__c, Name, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Module__c, SVMXC__Source_Object_Name__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__Rule_Type__c = 'SRCH_OBJECT' AND SVMXC__Module__c IN :mapAvailableNamedSearchId.values()]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Processes__c availableNamedSearchHeaderObjectdata: availableNamedSearchObjectHeader)
        {
          mapAvailableNamedSearchId.put(availableNamedSearchHeaderObjectdata.SVMXC__Module__c, availableNamedSearchHeaderObjectdata.Id);
        }
        
        // Data already available, check for object definition and push only expression details
        for(SVMXC__ServiceMax_Processes__c namedSearch: availableNamedSearchHeader)
        {
          String sourceNamedSearchId = namedSearchHeader.get(namedSearch.SVMXC__ProcessID__c).SVMXC__Node_Parent_API__c;
          sourceTargetNamedSearchId.add(new SFM_WrapperDef.SFM_StringMap(sourceNamedSearchId, namedSearch.Id));
          existingNamedSearchName.add(namedSearch.SVMXC__ProcessID__c);
          // If this is standard named search donot insert the records but set up the Id in response
          if(namedSearch.SVMXC__IsStandard__c == true)
          {
            log.setlog('INFO', system.label.CONF019_TAG039 + ' ' + namedSearch.SVMXC__ProcessID__c);
            log.setlog('FINE', system.label.CONF019_TAG055);
            // Skip processing the standard named search
            continue;
          }
          else
            log.setlog('INFO', system.label.CONF019_TAG040 + ' ' + namedSearch.SVMXC__ProcessID__c);
            
          // Check whether both named expressions are associate with same definitions
          if(namedSearch.SVMXC__Source_Object_Name__c == namedSearchHeader.get(namedSearch.SVMXC__ProcessID__c).SVMXC__Source_Object_Name__c)
          {
              
            List<SVMXC__ServiceMax_Config_Data__c> lstExistingNamedSearchDetails = [Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__r.SVMXC__Module__c = :namedSearch.Id and Recordtype.Name='Expressions'];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstExistingNamedSearchDetails.size()>0)
              delete lstExistingNamedSearchDetails;//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            SFM_DeployNamedSearchDetails(mapAvailableNamedSearchId.get(namedSearch.Id), namedSearchDetails.get(namedSearch.SVMXC__ProcessID__c));
          }
          else
          {
            isSucess = FALSE;
            log.setlog('ERROR', system.label.CONF019_TAG041 + ' ' + namedSearch.SVMXC__ProcessID__c);
            log.setlog('ERROR', system.label.CONF019_TAG032 + ' ' + namedSearchHeader.get(namedSearch.SVMXC__ProcessID__c).SVMXC__Source_Object_Name__c);
            log.setlog('ERROR', system.label.CONF019_TAG033 + ' ' + namedSearch.SVMXC__Source_Object_Name__c);
          }
        }
      }
      
      // If data not available in org create both header and expression details
      for(String namedSearchUniqueId: namedSearchHeader.keySet())
      {
        if(!existingNamedSearchName.contains(namedSearchUniqueId))
        {
          createdNamedSearchName.add(namedSearchUniqueId);
          log.setlog('INFO', system.label.CONF019_TAG042 + namedSearchUniqueId);
          SFM_DeployNamedSearch(namedSearchHeader.get(namedSearchUniqueId), namedSearchHeaderObject.get(namedSearchUniqueId), namedSearchDetails.get(namedSearchUniqueId));
        }
      }
        }
    catch (DmlException ex)
        {
          log.setlog('ERROR', ex.getDmlMessage(0));
            //log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);
            isSucess = false;
            oResponse.message = ex.getDmlMessage(0);
      }
        catch (Exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            //log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            isSucess = false;
            oResponse.message = ex.getmessage();
        }
        
        //log.logout();
        // Setup collective data
        List<String> requestedMappings = new List<String>();
        List<String> existingMappings = new List<String>();
        requestedMappings.addAll(requestedNamedSearchName);
        existingMappings.addAll(existingNamedSearchName);
    oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('REQUEST', requestedMappings));
    oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('DEPLOYED_EXISTING', existingMappings));
    oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('DEPLOYED', createdNamedSearchName));
    oResponse.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('SOURCETARGETNAMEDSEARCHIDS', sourceTargetNamedSearchId));
    oResponse.resultIds.add(mapRequest.get('PROCESSID'));
    oResponse.logMsg = log.getlog();
    oResponse.success = isSucess;
    return oResponse;   
  }
  
  void SFM_DeployNamedSearch(SVMXC__ServiceMax_Processes__c namedSearchHeader, SVMXC__ServiceMax_Processes__c namedSearchHeaderObject,list<SVMXC__ServiceMax_Config_Data__c> namedSearchDetails)
  {
    String sourceNamedSearchId = namedSearchHeader.SVMXC__Node_Parent_API__c;
    namedSearchHeader.RecordTypeId = namedSearchRecId;
    namedSearchHeader.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
    namedSearchHeader.SVMXC__Node_Parent_API__c = '';
    
    insert namedSearchHeader; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    sourceTargetNamedSearchId.add(new SFM_WrapperDef.SFM_StringMap(sourceNamedSearchId, namedSearchHeader.Id));
    
    namedSearchHeaderObject.SVMXC__Module__c = namedSearchHeader.Id;
    namedSearchHeaderObject.RecordTypeId = namedSearchRecId;
    namedSearchHeaderObject.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
    
    insert namedSearchHeaderObject;//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    
    SFM_DeployNamedSearchDetails(namedSearchHeaderObject.Id, namedSearchDetails);
  }
  
  void SFM_DeployNamedSearchDetails(Id namedSearchId, list<SVMXC__ServiceMax_Config_Data__c> namedSearchDetails)
  {
    for(SVMXC__ServiceMax_Config_Data__c namedSearchDetail : namedSearchDetails)
    {
      namedSearchDetail.RecordTypeId = namedSearchDetailRecId;
      namedSearchDetail.SVMXC__Expression_Rule__c = namedSearchId;
    }
    insert namedSearchDetails; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
  }
  
}