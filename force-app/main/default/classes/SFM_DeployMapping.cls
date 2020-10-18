/* Security Scanned */
public with sharing class SFM_DeployMapping {

    Boolean isSucess = TRUE;
    String mappingRecId;
    String mappingDetailRecId;
    SVMX_Debug log = new SVMX_Debug();
    SFM_Utils utils = new SFM_Utils();
    
    List<SFM_WrapperDef.SFM_StringMap> sourceTargetMappingId = new List<SFM_WrapperDef.SFM_StringMap>();

    public SFM_DeployMapping()
    {
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Object Mapping');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
        Map<String, Id> mapRecType_Map = new Map<String, Id>();
        mapRecType_Map = utils.getRecordTypes(recTypeNames);
        mappingRecId = mapRecType_Map.get('SVMXC__ServiceMax_Processes__c~Object Mapping');  
        mappingDetailRecId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Field Mapping'); 
    }
    
    public SFM_WrapperDef.SFM_Response SFM_DeployMapping(SFM_WrapperDef.SFM_Request_ObjectMap request)
    {
        SFM_WrapperDef.SFM_Response oResponse=new SFM_WrapperDef.SFM_Response();
        Map<String, SVMXC__ServiceMax_Processes__c> mapMappingHeader = new Map<String, SVMXC__ServiceMax_Processes__c>();
        Map<String, list<SVMXC__ServiceMax_Config_Data__c>> mapMappingDetails = new Map<String, list<SVMXC__ServiceMax_Config_Data__c>>();
        Set<String> requestedMappingName = new Set<String>();
        Set<String> existingMappingName = new Set<String>();
        List<String> createdMappingName = new List<String>();
        Map<String,String> mapRequest = new Map<String,String>();
        mapRequest = utils.getStringMap(request.request.stringMap);
        
        //log.login('SFM_DeployMapping', 'SFM_DeployMapping\n');
        Savepoint sp = Database.setSavepoint();//Setting up save point
        try
        {
            for(SFM_WrapperDef.SFM_ObjectMap mappinginfo: request.objects)
            {
                SVMXC__ServiceMax_Processes__c mappingHeader = mappinginfo.objectMap;
                mappingHeader.RecordTypeId = mappingRecId;
                requestedMappingName.add(mappingHeader.SVMXC__MapID__c);
                mapMappingHeader.put(mappingHeader.SVMXC__MapID__c, mappingHeader);
                
                // Build field property
                list<SVMXC__ServiceMax_Config_Data__c> fieldMappingDetails = new list<SVMXC__ServiceMax_Config_Data__c>();
                if(mappinginfo.fields != NULL)
                {
                  for(SFM_WrapperDef.SFM_FieldMapping fieldMap: mappinginfo.fields)
                  {
                      fieldMappingDetails.add(fieldMap.fieldMapRecord);
                  }
                }
                mapMappingDetails.put(mappingHeader.SVMXC__MapID__c, fieldMappingDetails);
            }
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__ServiceMax_Processes__c> availableMappingHeader = new List<SVMXC__ServiceMax_Processes__c>();
            availableMappingHeader = [SELECT Id, Name, SVMXC__IsStandard__c, SVMXC__Name__c, SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c From SVMXC__ServiceMax_Processes__c where SVMXC__MapID__c IN :requestedMappingName];
            
            // Data already available, check for object definition and push only expression details
            for(SVMXC__ServiceMax_Processes__c mappingHeader: availableMappingHeader)
            {
        String sourceMappingId = mapMappingHeader.get(mappingHeader.SVMXC__MapID__c).SVMXC__Node_Parent_API__c;
        sourceTargetMappingId.add(new SFM_WrapperDef.SFM_StringMap(sourceMappingId, mappingHeader.Id));
                existingMappingName.add(mappingHeader.SVMXC__MapID__c);
                
                // If this is standard mapping donot insert the records but set up the Id in response
        if(mappingHeader.SVMXC__IsStandard__c == true)
        {
                    log.setlog('INFO', system.label.CONF019_TAG035 + ' ' + mappingHeader.SVMXC__MapID__c);
          log.setlog('FINE', system.label.CONF019_TAG056);
          // Skip processing mapping
          continue;
        }
        else
                    log.setlog('INFO', system.label.CONF019_TAG036 + ' ' + mappingHeader.SVMXC__MapID__c);
        
                // Check whether both named expressions are associate with same definitions
                if(mappingHeader.SVMXC__Source_Object_Name__c == mapMappingHeader.get(mappingHeader.SVMXC__MapID__c).SVMXC__Source_Object_Name__c && mappingHeader.SVMXC__Target_Object_Name__c == mapMappingHeader.get(mappingHeader.SVMXC__MapID__c).SVMXC__Target_Object_Name__c)
                {
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    List<SVMXC__ServiceMax_Config_Data__c> lstExistingMappingDetails = [Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c = :mappingHeader.Id and Recordtype.Name='Field Mapping'];
                    if(lstExistingMappingDetails.size()>0)
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        delete lstExistingMappingDetails;
                    SFM_DeployMappingDetails(mappingHeader.Id, mapMappingDetails.get(mappingHeader.SVMXC__MapID__c));
                }
                else
                {
                    isSucess = FALSE;
                    log.setlog('ERROR', system.label.CONF019_TAG037 + mappingHeader.SVMXC__MapID__c);
                    if(mappingHeader.SVMXC__Source_Object_Name__c != mapMappingHeader.get(mappingHeader.SVMXC__MapID__c).SVMXC__Source_Object_Name__c)
                    {
                      log.setlog('ERROR', system.label.CONF019_TAG032 + ' ' + mapMappingHeader.get(mappingHeader.SVMXC__MapID__c).SVMXC__Source_Object_Name__c);
                      log.setlog('ERROR', system.label.CONF019_TAG033 + ' ' + mappingHeader.SVMXC__Source_Object_Name__c);
                    }
                    else
                    {
                      log.setlog('ERROR', system.label.CONF019_TAG032 + ' ' + mapMappingHeader.get(mappingHeader.SVMXC__MapID__c).SVMXC__Target_Object_Name__c);
                      log.setlog('ERROR', system.label.CONF019_TAG033 + ' ' + mappingHeader.SVMXC__Target_Object_Name__c);
                    }
                }
            }
            
            // If data not available in org create both header and expression details
            for(String mappingUniqueId: mapMappingHeader.keySet())
            {
                if(!existingMappingName.contains(mappingUniqueId))
                {
                    createdMappingName.add(mappingUniqueId);
                    log.setlog('INFO', system.label.CONF019_TAG038 + mappingUniqueId);
                    SFM_DeployMapping(mapMappingHeader.get(mappingUniqueId), mapMappingDetails.get(mappingUniqueId));
                }
            }
        }
        catch (DmlException ex)
        {
            log.setlog('ERROR', ex.getDmlMessage(0));
            //log.setlog('ERROR', 'When fails rollback data donot commit');
            Database.rollback(sp);
            isSucess = false;
            oResponse.message = ex.getDmlMessage(0);
        }
        catch (Exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            //log.setlog('ERROR', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            isSucess = false;
            oResponse.message = ex.getmessage();
        }
        
        //log.logout();
        // Setup collective data
        List<String> requestedMappings = new List<String>();
        List<String> existingMappings = new List<String>();
        requestedMappings.addAll(requestedMappingName);
        existingMappings.addAll(existingMappingName);
        oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('REQUEST', requestedMappings));
        oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('DEPLOYED_EXISTING', existingMappings));
        oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('DEPLOYED', createdMappingName));
        oResponse.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('SOURCETARGETMAPPINGIDS', sourceTargetMappingId));
        oResponse.resultIds.add(mapRequest.get('PROCESSID'));
        oResponse.logMsg = log.getlog();
        oResponse.success = isSucess;
        return oResponse;   
    }
    
    void SFM_DeployMapping(SVMXC__ServiceMax_Processes__c mappingHeader, list<SVMXC__ServiceMax_Config_Data__c> mappingDetails)
    {
        String sourceMappingId = mappingHeader.SVMXC__Node_Parent_API__c;
        mappingHeader.RecordTypeId = mappingRecId;
        mappingHeader.SVMXC__Rule_Type__c = 'Named Expression';
        mappingHeader.SVMXC__Node_Parent_API__c = '';
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        insert mappingHeader;
        sourceTargetMappingId.add(new SFM_WrapperDef.SFM_StringMap(sourceMappingId, mappingHeader.Id));
        SFM_DeployMappingDetails(mappingHeader.Id, mappingDetails);
    }
    
    void SFM_DeployMappingDetails(Id mappingId, list<SVMXC__ServiceMax_Config_Data__c> mappingDetails)
    {
        for(SVMXC__ServiceMax_Config_Data__c mappingDetail : mappingDetails)
        {
            mappingDetail.RecordTypeId = mappingDetailRecId;
            mappingDetail.SVMXC__MapID__c = mappingId;
        }
        system.debug('naveen' + mappingDetails);
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        insert mappingDetails;
        system.debug('vasu' + mappingDetails);
    }
    
}