/* Security Scanned */
public with sharing class SFM_GetLookupConfigDefinition 
{
    public list<SVMXC.SFM_WrapperDef.SFM_LookupDefinition> getLookupConfigDefinition(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        list<SVMXC.SFM_WrapperDef.SFM_LookupDefinition> lstLookupDefinition = new list<SVMXC.SFM_WrapperDef.SFM_LookupDefinition>();
        map<Id,SVMXC__ServiceMax_Processes__c> mapSearchObject = new map<Id,SVMXC__ServiceMax_Processes__c>();
        map<Id,SVMXC__ServiceMax_Processes__c> mapSearchCriteria = new map<Id,SVMXC__ServiceMax_Processes__c>(); 
        map<Id,list<SVMXC__ServiceMax_Processes__c>> mapLookupConfigIdLstHeaderRecords = new map<Id,list<SVMXC__ServiceMax_Processes__c>>();
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        set<String> setLookupConfigId = new set<String>();
        
        if(request != null && request.stringListMap != null){
            Integer i=0,l=request.stringListMap.size();
            for(i=0;i<l;i++){
                if(request.stringListMap[i].key == 'LOOKCONFIGID')
                    setLookupConfigId.addall(request.stringListMap[i].valueList);
            }
        }
        //Query Search Object
        //Added LastModifiedDate for BAC-5211
        mapSearchObject.putall([SELECT Id, SVMXC__Source_Object_Name__c, SVMXC__Rule_Type__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__Source_Object_Name__c, SVMXC__Module__r.SVMXC__Number_of_Lookup_Records__c, SVMXC__Module__r.SVMXC__Default_Lookup_Column__c, SVMXC__Parent_Object_Criteria__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__Module__c IN : setLookupConfigId and SVMXC__Rule_Type__c = 'SRCH_OBJECT']); 
        system.debug(LoggingLevel.WARN,'mapSearchObject'+mapSearchObject);
        //Query Search Criteria
        //Added LastModifiedDate for BAC-5211
        mapSearchCriteria.putall([SELECT Id, SVMXC__Default_On__c, SVMXC__Allow_Override__c, SVMXC__Field_Name__c, SVMXC__Source_Object_Name__c, SVMXC__Rule_Type__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__Parent_Object_Criteria__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__Module__c IN : setLookupConfigId and SVMXC__Rule_Type__c = 'SRCH_CRITERIA']);
        system.debug(LoggingLevel.WARN,'mapSearchCriteria'+mapSearchCriteria);
        if(mapSearchObject.size() > 0){
            for(ID i : mapSearchObject.keyset()){
                if(!mapLookupConfigIdLstHeaderRecords.containskey(mapSearchObject.get(i).SVMXC__Module__c))
                    mapLookupConfigIdLstHeaderRecords.put(mapSearchObject.get(i).SVMXC__Module__c,new list<SVMXC__ServiceMax_Processes__c>());
                mapLookupConfigIdLstHeaderRecords.get(mapSearchObject.get(i).SVMXC__Module__c).add(mapSearchObject.get(i)); 
            }
        }
        if(mapSearchCriteria.size() > 0){
            for(ID i : mapSearchCriteria.keyset()){
                if(!mapLookupConfigIdLstHeaderRecords.containskey(mapSearchCriteria.get(i).SVMXC__Module__c))
                    mapLookupConfigIdLstHeaderRecords.put(mapSearchCriteria.get(i).SVMXC__Module__c,new list<SVMXC__ServiceMax_Processes__c>());
                mapLookupConfigIdLstHeaderRecords.get(mapSearchCriteria.get(i).SVMXC__Module__c).add(mapSearchCriteria.get(i)); 
            }
        }
        system.debug(LoggingLevel.WARN,'mapLookupConfigIdLstHeaderRecords'+mapLookupConfigIdLstHeaderRecords);
        map<String,list<SVMXC__ServiceMax_Config_Data__c>>  mapLookupConfigIdlstConfigData = new map<String,list<SVMXC__ServiceMax_Config_Data__c>>();
        if(mapSearchObject.size() > 0 || mapSearchCriteria.size() > 0){
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstConfigData = [SELECT SVMXC__Sequence__c,SVMXC__Parameter_Type__c, SVMXC__Expression_Type__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Field_Name__c, SVMXC__Expression_Rule__c, Name, Id, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c,SVMXC__Display_Type__c,SVMXC__Field_Relationship_Name__c From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Expressions' AND  (SVMXC__Expression_Rule__c IN : mapSearchObject.keyset() OR SVMXC__Expression_Rule__c IN : mapSearchCriteria.keyset()) order by SVMXC__Sequence__c];
            if(lstConfigData.size() > 0){
                for(SVMXC__ServiceMax_Config_Data__c configData : lstConfigData){
                    if(mapLookupConfigIdlstConfigData.containskey(configData.SVMXC__Expression_Rule__c)){
                        mapLookupConfigIdlstConfigData.get(configData.SVMXC__Expression_Rule__c).add(configData);
                    }
                    else{
                        mapLookupConfigIdlstConfigData.put(configData.SVMXC__Expression_Rule__c,new list<SVMXC__ServiceMax_Config_Data__c>());
                        mapLookupConfigIdlstConfigData.get(configData.SVMXC__Expression_Rule__c).add(configData);
                    }
                }
            }
        }
        system.debug(LoggingLevel.WARN,'mapLookupConfigIdlstConfigData'+mapLookupConfigIdlstConfigData);    
        if(mapLookupConfigIdLstHeaderRecords.size() > 0){
            for(Id i : mapLookupConfigIdLstHeaderRecords.keyset()){
                SVMXC__ServiceMax_Processes__c objSearchObject = new SVMXC__ServiceMax_Processes__c();
                map<SVMXC__ServiceMax_Processes__c,list<SVMXC__ServiceMax_Config_Data__c>> mapAdvFilters = new map<SVMXC__ServiceMax_Processes__c,list<SVMXC__ServiceMax_Config_Data__c>>(); 
                map<String,SVMXC__ServiceMax_Processes__c> mapProcesses = new map<String,SVMXC__ServiceMax_Processes__c>();
                list<SVMXC__ServiceMax_Config_Data__c> LstPreFilterCriteria = new list<SVMXC__ServiceMax_Config_Data__c>();
                for(SVMXC__ServiceMax_Processes__c pro : mapLookupConfigIdLstHeaderRecords.get(i)){
                    if(pro.SVMXC__Rule_Type__c == 'SRCH_OBJECT'){
                        objSearchObject = pro;
                        if(mapLookupConfigIdlstConfigData.containskey(pro.id))
                            LstPreFilterCriteria = mapLookupConfigIdlstConfigData.get(pro.id);
                    }
                    else if(pro.SVMXC__Rule_Type__c == 'SRCH_CRITERIA'){
                        if(mapLookupConfigIdlstConfigData.containskey(pro.id)){
                            mapAdvFilters.put(pro,mapLookupConfigIdlstConfigData.get(pro.id));
                        }
                        else{
                            mapAdvFilters.put(pro,new list<SVMXC__ServiceMax_Config_Data__c>());
                        }
                    }
                }
                lstLookupDefinition.add(new SVMXC.SFM_WrapperDef.SFM_LookupDefinition(objSearchObject,LstPreFilterCriteria,mapAdvFilters));
            }
        }
        system.debug(LoggingLevel.WARN,'lstLookupDefinition'+lstLookupDefinition);
        return lstLookupDefinition;
    }
}