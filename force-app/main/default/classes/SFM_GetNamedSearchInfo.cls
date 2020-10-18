/* Security Scanned */
public with sharing class SFM_GetNamedSearchInfo 
{
    public SFM_getNamedSearchInfo(){}
    public SVMXC.SFM_WrapperDef.SFM_Response_NamedSearchInfo getNamedSearchInfo(SVMXC.SFM_WrapperDef.SFM_Request prequest)
    {
        String strNamedSearchRecId;
        SVMXC.SFM_WrapperDef.SFM_Response_NamedSearchInfo objRespNamedSearch = new SVMXC.SFM_WrapperDef.SFM_Response_NamedSearchInfo();
        list<string> lstLookupConfigType = new list<string>{'Search', 'Result', 'Bubble'};
        list<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfo> lstNamedSearchInfo = new list<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfo>();
        list<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail> lstNameSearchInfoDetail = new list<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        list<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail> lstAdvNameSearchInfoDetail = new list<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        list<SVMXC__ServiceMax_Processes__c> lstNamedSearch = new list<SVMXC__ServiceMax_Processes__c>(); 
        map<Id, List<SVMXC__ServiceMax_Config_Data__c>> mapSearchObjectFields = new map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id, List<SVMXC__ServiceMax_Config_Data__c>> mapSearchObjectPreFilterCriteria = new map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id, List<SVMXC__ServiceMax_Config_Data__c>> mapSearchCriPreFilterCri = new map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();
        
        
        try
        {
            for(SVMXC.SFM_WrapperDef.SFM_StringMap strMap : prequest.stringMap)
            {
                if(strMap.key != NULL && strMap.key.toUpperCase() == 'RECORDID')
                    strNamedSearchRecId = strMap.value;
            }
            system.debug('strNamedSearchRecId'+strNamedSearchRecId);
            if(strNamedSearchRecId != NULL && strNamedSearchRecId.length() > 0)
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstNamedSearch = [SELECT Id, SVMXC__Default_Lookup_Column__c, Name, SVMXC__Name__c, SVMXC__Source_Object_Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__IsStandard__c, SVMXC__IsDefault__C, SVMXC__Active__c, SVMXC__Number_of_Lookup_Records__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Named Search' AND Id =: strNamedSearchRecId];
            system.debug('lstNamedSearch'+lstNamedSearch);
            if(lstNamedSearch.size() == 0)
            {
                objRespNamedSearch.response.success = false;
                objRespNamedSearch.response.message = system.label.SFM002_TAG057;
                return objRespNamedSearch;
            }
            else if(lstNamedSearch.size() == 1)
            {
                //Query Header Objects 
                map<Id, SVMXC__ServiceMax_Processes__c> mapNameSearchHeader = new map<Id, SVMXC__ServiceMax_Processes__c>();
                set<Id> setSearchObjectIds = new set<Id>();
                set<Id> setSearchCriteriaIds = new set<Id>();
                mapNameSearchHeader.putall([SELECT Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Default_On__c, SVMXC__Field_Name__c, SVMXC__Allow_Override__c, SVMXC__Advance_Expression__c, SVMXC__Rule_Type__c, SVMXC__Parent_Object_Criteria__c, Name, SVMXC__Source_Object_Name__c, SVMXC__Process__c, SVMXC__Sequence__c,SVMXC__Module__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Named Search' AND SVMXC__Module__c =: strNamedSearchRecId AND (SVMXC__Rule_Type__c = 'SRCH_OBJECT' OR SVMXC__Rule_Type__c = 'SRCH_CRITERIA')]);
                system.debug('mapNameSearchHeader'+mapNameSearchHeader.size()+mapNameSearchHeader);
                if(mapNameSearchHeader.size() > 0){
                    for(Id i : mapNameSearchHeader.keyset()){
                         if(mapNameSearchHeader.get(i).SVMXC__Rule_Type__c == 'SRCH_OBJECT')
                            setSearchObjectIds.add(i);
                         else if(mapNameSearchHeader.get(i).SVMXC__Rule_Type__c == 'SRCH_CRITERIA')
                            setSearchCriteriaIds.add(i);
                    }
                }
                system.debug(LoggingLevel.WARN,'setSearchObjectIds'+setSearchObjectIds);
                system.debug(LoggingLevel.WARN,'setSearchCriteriaIds'+setSearchCriteriaIds);
                if(setSearchObjectIds.size() > 0){
                    //Query Search, Buuble, Result Fields 
                    for(SVMXC__ServiceMax_Config_Data__c NamedSrchObjDetail : [SELECT SVMXC__Display_Type__c, SVMXC__Parameter_Type__c, SVMXC__Search_Object_Field_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c, SVMXC__Expression_Rule__c, SVMXC__Object_Name__c, Id, SVMXC__Sequence__c From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name = 'Expressions' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' AND SVMXC__Search_Object_Field_Type__c IN : lstLookupConfigType AND SVMXC__Expression_Rule__c IN: setSearchObjectIds])
                    {
                        if(!mapSearchObjectFields.containsKey(NamedSrchObjDetail.SVMXC__Expression_Rule__c))
                            mapSearchObjectFields.put(NamedSrchObjDetail.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                        mapSearchObjectFields.get(NamedSrchObjDetail.SVMXC__Expression_Rule__c).add(NamedSrchObjDetail);
                    }
                    //Query Serch Object's Filter Criteria. (To return expressions in correct sequence, added ORDER BY clause.)
                    for(SVMXC__ServiceMax_Config_Data__c NamedSrchObjPreFltrCrit : [select Id, SVMXC__Display_Type__c, SVMXC__Parameter_Type__c, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Rule__c From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name = 'Expressions' AND SVMXC__Expression_Type__c =  'LKUP_Prefilter_Criteria' AND SVMXC__Expression_Rule__c IN: setSearchObjectIds ORDER BY SVMXC__Sequence__c])
                    {
                        if(!mapSearchObjectPreFilterCriteria.containsKey(NamedSrchObjPreFltrCrit.SVMXC__Expression_Rule__c))
                            mapSearchObjectPreFilterCriteria.put(NamedSrchObjPreFltrCrit.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                        mapSearchObjectPreFilterCriteria.get(NamedSrchObjPreFltrCrit.SVMXC__Expression_Rule__c).add(NamedSrchObjPreFltrCrit);
                    }
                }
                if(setSearchCriteriaIds.size() > 0){    
                    //Query Search criteria's Filter criteria. (To return expressions in correct sequence, added ORDER BY clause.)
                    for(SVMXC__ServiceMax_Config_Data__c NamedSrchCritObjPreFltrCrit : [select Id, SVMXC__Display_Type__c, SVMXC__Parameter_Type__c, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Rule__c From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name = 'Expressions' AND SVMXC__Expression_Type__c =  'LKUP_Criteria' AND SVMXC__Expression_Rule__c IN: setSearchCriteriaIds ORDER BY SVMXC__Sequence__c])
                    {
                        if(!mapSearchCriPreFilterCri.containsKey(NamedSrchCritObjPreFltrCrit.SVMXC__Expression_Rule__c))
                            mapSearchCriPreFilterCri.put(NamedSrchCritObjPreFltrCrit.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                        mapSearchCriPreFilterCri.get(NamedSrchCritObjPreFltrCrit.SVMXC__Expression_Rule__c).add(NamedSrchCritObjPreFltrCrit);
                    }
                }
                system.debug(LoggingLevel.WARN,'mapSearchObjectFields'+mapSearchObjectFields);
                system.debug(LoggingLevel.WARN,'mapSearchObjectPreFilterCriteria'+mapSearchObjectPreFilterCriteria);
                system.debug(LoggingLevel.WARN,'mapSearchCriPreFilterCri'+mapSearchCriPreFilterCri);
                if(setSearchObjectIds.size() >0){
                    for(Id i : setSearchObjectIds){
                        SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail objNamedSrchCritObjInfoDetail = new SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail();
                        if(mapNameSearchHeader.containskey(i))
                            objNamedSrchCritObjInfoDetail.objectDetails =  mapNameSearchHeader.get(i);
                        if(mapSearchObjectFields.containskey(i))
                            objNamedSrchCritObjInfoDetail.fields  = mapSearchObjectFields.get(i);
                        if(mapSearchObjectPreFilterCriteria.containskey(i))
                            objNamedSrchCritObjInfoDetail.expressionFields = mapSearchObjectPreFilterCriteria.get(i); 
                        lstNameSearchInfoDetail.add(objNamedSrchCritObjInfoDetail); 
                    }   
                }
                if(setSearchCriteriaIds.size() >0){
                    for(Id i : setSearchCriteriaIds){
                        SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail objNamedSrchCritObjInfoDetail = new SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail();
                        if(mapNameSearchHeader.containskey(i))
                            objNamedSrchCritObjInfoDetail.objectDetails =  mapNameSearchHeader.get(i);
                        if(mapSearchCriPreFilterCri.containskey(i))
                            objNamedSrchCritObjInfoDetail.expressionFields = mapSearchCriPreFilterCri.get(i); 
                        lstAdvNameSearchInfoDetail.add(objNamedSrchCritObjInfoDetail);  
                    }   
                }
                SVMXC.SFM_WrapperDef.SFM_NamedSearchInfo objNameSearchInfo = new SVMXC.SFM_WrapperDef.SFM_NamedSearchInfo();
                objNameSearchInfo.namedSearchHdr = lstNamedSearch[0];
                objNameSearchInfo.namedSearchDetails = lstNameSearchInfoDetail;
                objNameSearchInfo.advNamedSearchDetails = lstAdvNameSearchInfoDetail;
                lstNamedSearchInfo.add(objNameSearchInfo);
                system.debug(LoggingLevel.WARN,'lstNamedSearchInfo'+lstNamedSearchInfo);
            }   
        }
        catch(exception ex)
        {
            objRespNamedSearch.response.success = false;
            objRespNamedSearch.response.message = ex.getMessage();
            return objRespNamedSearch;
        }
        objRespNamedSearch.response.success = true;
        objRespNamedSearch.namedSearch = lstNamedSearchInfo;
        system.debug('objRespNamedSearch'+objRespNamedSearch);
        return objRespNamedSearch;
    }

    /**
     * This method is used to fetch lookupConfig detail for the given
     * record Id 
     * @param lookupConfigId Id of the lookupConfig record.
     * @Return Custom wrapper object of type SFM_WrapperDef2.SFM2_LookupConfig
     */
    public SFM_WrapperDef2.SFM2_LookupConfig getLookupConfig_v2(String lookupConfigId){
        
        SFM_WrapperDef2.SFM2_LookupConfig lookupConfigWrapper;
        if(lookupConfigId != null){

            /*
                FLS check before querying the records
            */
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__Name__c', 'SVMXC__Default_Lookup_Column__c', 'SVMXC__Number_of_Lookup_Records__c', 'SVMXC__IsDefault__c', 'SVMXC__ProcessID__c', 'SVMXC__Source_Object_Name__c', 'SVMXC__Description__c', 'SVMXC__IsStandard__c', 'CreatedDate', 'CreatedById',
                              'CreatedBy.Name', 'LastModifiedDate', 'LastModifiedById', 'LastModifiedBy.Name', 'SVMXC__Field_Name__c', 'SVMXC__Sequence__c', 'SVMXC__Advance_Expression__c', 'SVMXC__Rule_Type__c', 'SVMXC__Parent_Object_Criteria__c', 'SVMXC__Allow_Override__c', 'SVMXC__Default_On__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Config_Data__c', new List<String>{'Id', 'Name', 'SVMXC__Sequence__c', 'SVMXC__Source_Field_Name__c', 'SVMXC__Action_Type__c', 'SVMXC__Target_Field_Name__c', 'SVMXC__Preference_2__c', 'SVMXC__Preference_3__c', 'SVMXC__Display_Value__c', 'SVMXC__Configuration_Type__c', 'SVMXC__Object_Name2__c', 
                    'SVMXC__Operator__c', 'SVMXC__Operand__c', 'SVMXC__Parameter_Type__c', 'SVMXC__Field_Name__c', 'SVMXC__Batch_Size__c', 'SVMXC__Expression_Rule__c', 'SVMXC__Expression_Type__c', 'SVMXC__Search_Object_Field_Type__c', 'SVMXC__Display_Type__c', 'SVMXC__SM_Related_Info__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            List<SVMXC__ServiceMax_Processes__c> lookupConfigRecordList = [SELECT Id, SVMXC__Name__c, SVMXC__Default_Lookup_Column__c, SVMXC__Number_of_Lookup_Records__c, SVMXC__IsDefault__c, SVMXC__ProcessID__c, SVMXC__Source_Object_Name__c, SVMXC__Description__c, SVMXC__IsStandard__c, CreatedDate, CreatedById, 
                              CreatedBy.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, (SELECT Id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Field_Name__c, SVMXC__Sequence__c, SVMXC__Advance_Expression__c, 
                              SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Allow_Override__c, SVMXC__Default_On__c FROM SVMXC__ServiceMax_Processes2__r WHERE SVMXC__Rule_Type__c IN ('SRCH_OBJECT', 'SRCH_CRITERIA')) FROM SVMXC__ServiceMax_Processes__c WHERE Id =: lookupConfigId];
            
            
            /*
                Check if the record exists and then process the queried record.
            */
            if(!lookupConfigRecordList.isEmpty() && lookupConfigRecordList.size() == 1){
                Set<Id> ruleIds = new Set<Id>();                                                    
                SVMXC__ServiceMax_Processes__c lookupConfigRecord = lookupConfigRecordList[0];
                lookupConfigWrapper = new SFM_WrapperDef2.SFM2_LookupConfig();
                SFM_WrapperDef2.SFM2_EntityDetail configDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
                configDetail.entityId = lookupConfigRecord.Id;
                configDetail.isStandard = lookupConfigRecord.SVMXC__IsStandard__c;
                configDetail.entityName = lookupConfigRecord.SVMXC__Name__c;
                configDetail.entityDescription = lookupConfigRecord.SVMXC__Description__c;
                configDetail.lastModifiedDate = String.valueOf(lookupConfigRecord.LastModifiedDate);
                configDetail.createdDate = String.valueOf(lookupConfigRecord.CreatedDate);
                configDetail.createdBy = lookupConfigRecord.CreatedBy.Name;
                configDetail.lastModifiedBy = lookupConfigRecord.LastModifiedBy.Name;
                lookupConfigWrapper.configDetail = configDetail;
                lookupConfigWrapper.lookupObject = lookupConfigRecord.SVMXC__Source_Object_Name__c;
                lookupConfigWrapper.defaultColumn = lookupConfigRecord.SVMXC__Default_Lookup_Column__c;
                lookupConfigWrapper.isDefault = lookupConfigRecord.SVMXC__IsDefault__c;
                lookupConfigWrapper.lkpRecords = lookupConfigRecord.SVMXC__Number_of_Lookup_Records__c != null ? Integer.valueOf(lookupConfigRecord.SVMXC__Number_of_Lookup_Records__c) : null;
                //List<SFM_WrapperDef2.SFM2_Rule> advancedFilterList = new List<SFM_WrapperDef2.SFM2_Rule>();

                Integer filterSequence = 0;
                for(SVMXC__ServiceMax_Processes__c subConfigRecord: lookupConfigRecord.ServiceMax_Processes2__r){
                    ruleIds.add(subConfigRecord.Id);
                    SFM_WrapperDef2.SFM2_Rule lookupFilterWrapper = new SFM_WrapperDef2.SFM2_Rule();
                    SFM_WrapperDef2.SFM2_EntityDetail ruleDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
                    ruleDetail.entityId = subConfigRecord.Id;
                    ruleDetail.entityName = subConfigRecord.SVMXC__Name__c;
                    ruleDetail.entityDescription = subConfigRecord.SVMXC__Description__c;
                    lookupFilterWrapper.ruleDetail = ruleDetail;
                    lookupFilterWrapper.sourceObject = subConfigRecord.SVMXC__Source_Object_Name__c;
                    lookupFilterWrapper.sequence = subConfigRecord.SVMXC__Sequence__c != null ? Integer.valueOf(subConfigRecord.SVMXC__Sequence__c) : null;
                    lookupFilterWrapper.targetNodeId = subConfigRecord.SVMXC__Field_Name__c;
                    lookupFilterWrapper.allowOverride = subConfigRecord.SVMXC__Allow_Override__c;
                    lookupFilterWrapper.defaultOn = subConfigRecord.SVMXC__Default_On__c;
                    lookupFilterWrapper.advanceExpression = subConfigRecord.SVMXC__Advance_Expression__c;

                    if(subConfigRecord.SVMXC__Rule_Type__c.equals('SRCH_OBJECT')){

                        lookupConfigWrapper.lookupFilter = lookupFilterWrapper;
                    }

                    if(subConfigRecord.SVMXC__Rule_Type__c.equals('SRCH_CRITERIA')){
                        lookupFilterWrapper.sequence = filterSequence++;
                        lookupConfigWrapper.advancedFilters.add(lookupFilterWrapper);
                    }
                }

                Map<Id, List<SVMXC__ServiceMax_Config_Data__c>> expressionsMap = new Map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();

                for(SVMXC__ServiceMax_Config_Data__c expressionDetail : [SELECT Id, Name, SVMXC__Sequence__c, SVMXC__Source_Field_Name__c, SVMXC__Action_Type__c, SVMXC__Target_Field_Name__c, SVMXC__Preference_2__c, SVMXC__Preference_3__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c, SVMXC__Object_Name2__c, SVMXC__Description__c,
                    SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Parameter_Type__c, SVMXC__Field_Name__c, SVMXC__Batch_Size__c, SVMXC__Expression_Rule__c, SVMXC__Expression_Type__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Display_Type__c, SVMXC__SM_Related_Info__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__c IN: ruleIds Order By SVMXC__Sequence__c ASC ]){

                    List<SVMXC__ServiceMax_Config_Data__c> tempList = new List<SVMXC__ServiceMax_Config_Data__c>();
                    if(expressionsMap.containsKey(expressionDetail.SVMXC__Expression_Rule__c)){
                        tempList = expressionsMap.get(expressionDetail.SVMXC__Expression_Rule__c);
                    }

                    tempList.add(expressionDetail);
                    expressionsMap.put(expressionDetail.SVMXC__Expression_Rule__c, tempList);
                }

                if(!expressionsMap.isEmpty()){
                    if(lookupConfigWrapper.lookupFilter != null && expressionsMap.containsKey(lookupConfigWrapper.lookupFilter.ruleDetail.entityId)){
                        lookupConfigWrapper.lookupFilter.expressionsList = new SFM_SaveAsExpression().expressionListWrapper(expressionsMap.get(lookupConfigWrapper.lookupFilter.ruleDetail.entityId), SFM_DesignerUtils.entity_lkpConfig, false);
                    }


                    for(SFM_WrapperDef2.SFM2_Rule filterRule : lookupConfigWrapper.advancedFilters){
                        
                        if(expressionsMap.containsKey(filterRule.ruleDetail.entityId)){
                            filterRule.expressionsList = new SFM_SaveAsExpression().expressionListWrapper(expressionsMap.get(filterRule.ruleDetail.entityId), SFM_DesignerUtils.entity_lkpConfig, false);
                        }
                    }
                }
            }
        }

        return lookupConfigWrapper;
    }
}