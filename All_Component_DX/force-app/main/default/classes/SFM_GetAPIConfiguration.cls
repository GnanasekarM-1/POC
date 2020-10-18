public with sharing class SFM_GetAPIConfiguration {

    public SVMXC.SFM_WrapperDef.SFM_Response getAPIConfiguration(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        response.success = true;
        list<SVMXC.SFM_WrapperDef.SFM_StringSobjectMap> lstStringSobjectMap = new list<SVMXC.SFM_WrapperDef.SFM_StringSobjectMap>(); 
        if(request != null){
            try{
                String strHeaderObjectName = 'ALL';
                if(request.stringMap != null && !request.stringMap.isEmpty()){
                    for(Integer i = 0;i<request.stringMap.size();i++){
                        if(request.stringMap[i].key != null && request.stringMap[i].key.equals('HEADEROBJECTNAME') && request.stringMap[i].value != null)
                            strHeaderObjectName = request.stringMap[i].value;
                    }
                }   
                system.debug('strHeaderObjectName'+strHeaderObjectName); 
                ServiceFlowWizard_Utils utils = new ServiceFlowWizard_Utils();
                list<SVMXC__ServiceMax_Processes__c> lstInventoryProcesses  = new list<SVMXC__ServiceMax_Processes__c>(); 
                map<String,List<SVMXC__ServiceMax_Processes__c>> mapInventoryProcesses = new map<String,List<SVMXC__ServiceMax_Processes__c>>(); 
                mapInventoryProcesses = utils.SVMX_GetInventoryActions(strHeaderObjectName);
                system.debug('mapInventoryProcesses'+mapInventoryProcesses);
                for(String strKey : mapInventoryProcesses.keyset()){
                    lstInventoryProcesses.addAll(mapInventoryProcesses.get(strKey));
                } 
                system.debug('lstInventoryProcesses'+lstInventoryProcesses);
                if(lstInventoryProcesses.size() > 0){
                    // To Do : Change Inventory Process to custom label.
                    SVMXC.SFM_WrapperDef.SFM_StringSobjectMap stringSobjectMap = new SVMXC.SFM_WrapperDef.SFM_StringSobjectMap('Inventory Process',System.label.SFM001_TAG468,lstInventoryProcesses);
                    lstStringSobjectMap.add(stringSobjectMap); 
                }   
                if(lstStringSobjectMap.size() > 0){
                    response.setsobjectMap(lstStringSobjectMap);
                }
            }catch(exception ex){
                response.success = false;
                response.message = ex.getMessage();
            }   
        }
        else{
            response.success = false;
            response.message = 'Invalid input parameters';
        }
        system.debug('Output Response: '+response);
        return response;
    }
    
    public List<SFM_WrapperDef2.SFM2_Dependency> getAPIConfiguration_v2(String objAPIName){
        Map<String, SVMXC__ServiceMax_Processes__c> inventoryProcessIdMap = new Map<String, SVMXC__ServiceMax_Processes__c>();
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__Description__c', 'SVMXC__ProcessID__c', 'SVMXC__Name__c', 'Recordtype.Name'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        for(SVMXC__ServiceMax_Processes__c invProcessRecord : [SELECT Id, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE
                                                                 Recordtype.Name = 'Inventory Process']){
            if(invProcessRecord.SVMXC__ProcessID__c != null){
                inventoryProcessIdMap.put(invProcessRecord.SVMXC__ProcessID__c + '_SET025', invProcessRecord);
            }
        }
        Set<String> invProcessIds = inventoryProcessIdMap.keySet();
        if(!invProcessIds.isEmpty()){
            List<SFM_WrapperDef2.SFM2_EntityDetail> inventoryProcessList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Config_Data__c', new List<String>{'Id','SVMXC__Setting_Unique_ID__c', 'SVMXC__Internal_Value__c', 'SVMXC__Active__c', 'SVMXC__RecordType_Name__c',
                                                                    'SVMXC__Configuration_Type__c', 'RecordType.Name'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            for(SVMXC__ServiceMax_Config_Data__c configData : [SELECT SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name = 'Setting Value'
                                         AND SVMXC__Setting_Unique_ID__c IN :invProcessIds AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                                         AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' AND
                                         SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global' AND SVMXC__Internal_Value__c =: objAPIName]){
                if(inventoryProcessIdMap.containsKey(configData.SVMXC__Setting_Unique_ID__c)){
                    SVMXC__ServiceMax_Processes__c invProcessRecord = inventoryProcessIdMap.get(configData.SVMXC__Setting_Unique_ID__c);
                    SFM_WrapperDef2.SFM2_EntityDetail entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
					entityDetail.entityId = invProcessRecord.Id;
					entityDetail.entityName = invProcessRecord.SVMXC__Name__c;
					entityDetail.entityDescription = invProcessRecord.SVMXC__Description__c;
                    inventoryProcessList.add(entityDetail);
                }
            }
            if(!inventoryProcessList.isEmpty()){
                List<SFM_WrapperDef2.SFM2_Dependency> apiConfigurationList = new List<SFM_WrapperDef2.SFM2_Dependency>();
                SFM_WrapperDef2.SFM2_Dependency apiConfig = new SFM_WrapperDef2.SFM2_Dependency(null, objAPIName, inventoryProcessList);
                apiConfig.entityType = SFM_DesignerUtils.PROCESSTYPE_INVENTORY;
                apiConfigurationList.add(apiConfig);
                return apiConfigurationList;
			}
        }
        return null;
    }
}