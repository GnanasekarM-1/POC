/* Security Scanned */
public with sharing class SFM_SearchUtils 
{
    /********* Web Service call to get search definition ********************/
    public INTF_WebServicesDef.INTF_Response INTF_getSearchInfo(INTF_WebServicesDef.INTF_SFMRequest request)
    {
        I18N_TranslationDelivery objTranslnUtil;
        String TranslationKeys = '';
        Id usrSVMXProfileId;
        Id usrSfProfileId = UserInfo.getProfileId();
        Map<String, Schema.SObjectField> LfieldsMap = new Map<String, Schema.SObjectField>(); 
        Map<String, Schema.SObjectType> allobjmap = new Map<String, Schema.SObjectType>();
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        allObjs = Schema.getGlobalDescribe();
        map<string, Map<String, string>> ObjNameFldsMap = new map<string, Map<String, string>>();
        for(Schema.SObjectType s : allObjs.values())
        {
            Schema.DescribeSObjectResult objDesc = s.getDescribe();
            allobjmap.put(objDesc.getName(),s);
        }
        
        List<SVMXC__ServiceMax_Config_Data__c> lstGroupProfiles = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        lstGroupProfiles = [Select Id, SVMXC__Access_Configuration_Profile__c, RecordType.Name, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Configuration Access' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Group' 
        And SVMXC__Profile__c =: usrSFProfileId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(lstGroupProfiles != null && lstGroupProfiles.size() > 0)
            usrSVMXProfileId = lstGroupProfiles[0].SVMXC__Access_Configuration_Profile__c;
        
        system.debug(LoggingLevel.WARN, 'Profile name:'+usrSVMXProfileId);
        
        
        //List<SVMXC__ServiceMax_Processes__c> LstSearchDefnRecords = [SELECT Id, Name, SVMXC__Name__c, SVMXC__Source_Object_Name__c,SVMXC__Description__c ,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__IsStandard__c,SVMXC__IsDefault__C,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH'];
        
        List<SVMXC__ServiceMax_Processes__c> LstSearchDefnRecords = [SELECT Id, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Parent_Error_Msg__c,  SVMXC__Child_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Tag_Keys__c, Name, SVMXC__Name__c, SVMXC__Source_Object_Name__c,SVMXC__Description__c ,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__IsStandard__c,SVMXC__IsDefault__C,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(LstSearchDefnRecords == null)
            return null;
        
        system.debug(LoggingLevel.WARN, 'List of Search Def.:'+LstSearchDefnRecords);
        
        /* Start - Logic to translate SFM Search Definition  */
        if(LstSearchDefnRecords != NULL && LstSearchDefnRecords.size() > 0){
            for(SVMXC__ServiceMax_Processes__c SearchDefn : LstSearchDefnRecords){
                if(SearchDefn.SVMXC__Tag_Keys__c != NULL && SearchDefn.SVMXC__Tag_Keys__c.length() > 0)
                    TranslationKeys  += SearchDefn.SVMXC__Tag_Keys__c;
            }
            objTranslnUtil = new I18N_TranslationDelivery(TranslationKeys, UserInfo.getLanguage());
            LstSearchDefnRecords = objTranslnUtil.SVMX_GetProcessTranslation(LstSearchDefnRecords); 
        }
        /* End */
        
        List<INTF_WebServicesDef.INTF_MapStringMap> LstMapStrMapObj = new List<INTF_WebServicesDef.INTF_MapStringMap>();
        for(SVMXC__ServiceMax_Processes__c CurrentProcessObj : LstSearchDefnRecords)
        {
             INTF_WebServicesDef.INTF_MapStringMap mapStrMapObj = new INTF_WebServicesDef.INTF_MapStringMap();
             List<INTF_WebServicesDef.INTF_StringMap> valueMap = new List<INTF_WebServicesDef.INTF_StringMap>();
             valueMap.add(new INTF_WebServicesDef.INTF_StringMap(CurrentProcessObj.Id,CurrentProcessObj.SVMXC__ProcessID__c));
             mapStrMapObj.valueMap = valueMap;
             LstMapStrMapObj.add(mapStrMapObj);
        }
        system.debug(LoggingLevel.WARN, 'Map of Search Id-Name:'+LstMapStrMapObj);
        
        Map<Id, SVMXC__ServiceMax_Processes__c> mapSearchDefnRecs = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Set<Id> setSearchDefnRecId = new Set<Id>();
        mapSearchDefnRecs.putAll(LstSearchDefnRecords);
        setSearchDefnRecId.addAll(mapSearchDefnRecs.keyset());
        List<SVMXC__ServiceMax_Config_Data__c> lstSearchAccessRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        lstSearchAccessRecs = [Select Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = 'Search Access' And SVMXC__Dispatch_Process__c In: setSearchDefnRecId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        //Shashank: Commented to work for SFM-Search Online.
        //setSearchDefnRecId.clear();
        
        if(usrSVMXProfileId != null)
        {
            set<Id> setTempSrchRecId = new set<Id>();
            set<Id> setSrchRecsWithAccess = new set<Id>();
            for (SVMXC__ServiceMax_Config_Data__c qr : lstSearchAccessRecs)
            {
                if(qr.SVMXC__Access_Configuration_Profile__c != null)
                {
                    if(usrSVMXProfileId == qr.SVMXC__Access_Configuration_Profile__c)
                        setTempSrchRecId.add(qr.SVMXC__Dispatch_Process__c);
                    else
                        setSrchRecsWithAccess.add(qr.SVMXC__Dispatch_Process__c);
                }
            }
            setSearchDefnRecId.removeAll(setSrchRecsWithAccess);
            setSearchDefnRecId.addAll(setTempSrchRecId);
        }
        
        Map<Id, SVMXC__ServiceMax_Processes__c> mapTempSearchDefnRecs = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        for(Id SearchDefnRecId :setSearchDefnRecId)
        {
            mapTempSearchDefnRecs.put(SearchDefnRecId,mapSearchDefnRecs.get(SearchDefnRecId));
        }
        mapSearchDefnRecs.clear();
        mapSearchDefnRecs.putAll(mapTempSearchDefnRecs);
        setSearchDefnRecId.clear();
        setSearchDefnRecId.addAll(mapSearchDefnRecs.keyset());
        mapTempSearchDefnRecs.clear();

        //Query for Search object Information
        Map< string, string> ApiNameLabelMap = new Map< string, string>();
        List<SVMXC__ServiceMax_Processes__c> lstSearchObjectRecs = new List<SVMXC__ServiceMax_Processes__c>();
        
        Map<Id,List<SVMXC__ServiceMax_Processes__c>> mapSearchDef_LstSearchObjs = new Map<Id,List<SVMXC__ServiceMax_Processes__c>>();
        Map<Id, SVMXC__ServiceMax_Processes__c> mapSearchObjectRec = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Set<Id> setSearchObjectRecId = new Set<Id>();
    
        //lstSearchObjectRecs = [Select Id, SVMXC__Target_Object_Name__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Advance_Expression__c, SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_OBJECT' AND SVMXC__Module__c IN :setSearchDefnRecId ORDER BY SVMXC__Sequence__c];
        
        lstSearchObjectRecs = [Select Id, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Rule_Type__c, Name, SVMXC__Parent_Error_Msg__c, SVMXC__Child_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Tag_Keys__c, SVMXC__Target_Object_Name__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Advance_Expression__c, SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_OBJECT' AND SVMXC__Module__c IN :setSearchDefnRecId ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        mapSearchObjectRec.putAll(lstSearchObjectRecs);
        setSearchObjectRecId.addAll(mapSearchObjectRec.keyset());
        Set<string> objectSet = new Set<string>();
        
        /* Start - Logic to translate SFM Search Definition's Objects (i.e. Searchable Objects) */
        if(lstSearchObjectRecs != NULL && lstSearchObjectRecs.size() > 0 && objTranslnUtil != NULL)
            lstSearchObjectRecs = objTranslnUtil.SVMX_GetProcessTranslation(lstSearchObjectRecs);
        /* End  */
        
        for(SVMXC__ServiceMax_Processes__c SearchObj : lstSearchObjectRecs)
        {
            String ObjectName = SearchObj.SVMXC__Target_Object_Name__c;
            if(!objectSet.contains(ObjectName))
            {
                objectSet.add(ObjectName);
                Schema.DescribeSObjectResult objDesc = allobjmap.get(ObjectName).getDescribe(); 
                LfieldsMap.clear();
                LfieldsMap = objDesc.fields.getMap();
                
                if(ObjNameFldsMap.containsKey(ObjectName))
                    ObjNameFldsMap.get(objDesc.getName()).put(objDesc.getName(), objDesc.getLabelPlural());
                else
                    ObjNameFldsMap.put(objDesc.getName(), new map<string, string>());
                
                for(String s : LfieldsMap.keyset())
                {
                    if(ObjNameFldsMap.containsKey(ObjectName))
                    {
                        ObjNameFldsMap.get(ObjectName).put(LfieldsMap.get(s).getDescribe().getName(), LfieldsMap.get(s).getDescribe().getLabel());
                    }
                    else
                    {
                        map<string, string> tempMap = new map<string, string>();
                        tempMap.put(LfieldsMap.get(s).getDescribe().getName(), LfieldsMap.get(s).getDescribe().getLabel());
                        ObjNameFldsMap.put(ObjectName,tempMap);
                    }
                }
                
            }   
            if(mapSearchDef_LstSearchObjs.containsKey(SearchObj.SVMXC__Module__c))
            {
                mapSearchDef_LstSearchObjs.get(SearchObj.SVMXC__Module__c).add(SearchObj);
            }
            else
            {
                List<SVMXC__ServiceMax_Processes__c> tempProcessObjLst = new List<SVMXC__ServiceMax_Processes__c>();
                tempProcessObjLst.add(SearchObj);
                mapSearchDef_LstSearchObjs.put(SearchObj.SVMXC__Module__c,tempProcessObjLst);
            }
           
        }
        
        system.debug(LoggingLevel.WARN, 'Map of Search Def Id and Searchable Object list: '+ mapSearchDef_LstSearchObjs);
        
        List<SVMXC__ServiceMax_Config_Data__c> lstDisplayInfoRecords = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        lstDisplayInfoRecords = [Select Id, SVMXC__Sequence__c, SVMXC__FKey_Name_Field__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Sort_Order__c, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c,  SVMXC__Object_Name__c, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Display_Value__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Relationship_Name__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c IN: setSearchObjectRecId and Recordtype.Name='Expressions' AND SVMXC__Search_Object_Field_Type__c = 'Result' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        Set<string> tempObjectSet = new Set<string>();
        for(SVMXC__ServiceMax_Config_Data__c SearchObjFldRec : lstDisplayInfoRecords)
        {   
            LfieldsMap.clear();
            String ObjectName = SearchObjFldRec.SVMXC__Object_Name2__c;
            if(!tempObjectSet.contains(ObjectName))
            {
                tempObjectSet.add(ObjectName);   
                Schema.DescribeSObjectResult objDesc = allobjmap.get(ObjectName).getDescribe(); 
                LfieldsMap = objDesc.fields.getMap();
                for(String s : LfieldsMap.keyset())
                {
                    if(ObjNameFldsMap.containsKey(SearchObjFldRec.SVMXC__Object_Name2__c))
                    {
                        ObjNameFldsMap.get(SearchObjFldRec.SVMXC__Object_Name2__c).put(LfieldsMap.get(s).getDescribe().getName(), LfieldsMap.get(s).getDescribe().getLabel());
                    }
                    else
                    {
                        map<string, string> tempMap = new map<string, string>();
                        tempMap.put(LfieldsMap.get(s).getDescribe().getName(), LfieldsMap.get(s).getDescribe().getLabel());
                        ObjNameFldsMap.put(SearchObjFldRec.SVMXC__Object_Name2__c,tempMap);
                    }
                }
            }
        }
        
        Map<Id,List<SVMXC__ServiceMax_Config_Data__c>> mapSearchObjId_LstSearchObjFldRec = new Map<Id,List<SVMXC__ServiceMax_Config_Data__c>>();
        for(SVMXC__ServiceMax_Config_Data__c SearchObjFldRec : lstDisplayInfoRecords)
        {
            List<SVMXC__ServiceMax_Config_Data__c> tempLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            if(mapSearchObjId_LstSearchObjFldRec.containsKey(SearchObjFldRec.SVMXC__Expression_Rule__c) && mapSearchObjId_LstSearchObjFldRec.get(SearchObjFldRec.SVMXC__Expression_Rule__c) != null)
                tempLst.addAll(mapSearchObjId_LstSearchObjFldRec.get(SearchObjFldRec.SVMXC__Expression_Rule__c));
            tempLst.add(SearchObjFldRec);
            mapSearchObjId_LstSearchObjFldRec.put(SearchObjFldRec.SVMXC__Expression_Rule__c, tempLst);
        }
        
        system.debug(LoggingLevel.WARN, 'Map of Searchable Object Id and Result Field: '+ mapSearchObjId_LstSearchObjFldRec);
        
        string searchOperator = null;
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> settingT0getOperator = new Map<String,String>();
        settingT0getOperator = commSettings.SVMX_getSettingList('GBL017');
        if(settingT0getOperator.containsKey('GBL017') && settingT0getOperator.get('GBL017')!= null)
            searchOperator = settingT0getOperator.get('GBL017');
        List<INTF_WebServicesDef.INTF_SearchInfoDetail> lstDetails;
        List<INTF_WebServicesDef.INTF_SearchInfo> lstInfo = new List<INTF_WebServicesDef.INTF_SearchInfo>();
        INTF_WebServicesDef.INTF_SearchInfo objHdr;
        
        for(Id tempId : mapSearchDef_LstSearchObjs.keySet())
        {
            lstDetails = new List<INTF_WebServicesDef.INTF_SearchInfoDetail>();
            List<INTF_WebServicesDef.INTF_StringMap> lstStrMap = new List<INTF_WebServicesDef.INTF_StringMap>();
            
            system.debug(LoggingLevel.WARN, 'For Search def Id: '+ tempId +'; Searchable Objects are: '+  mapSearchDef_LstSearchObjs.get(tempId));
            
            if(mapSearchDef_LstSearchObjs.containsKey(tempId) && mapSearchDef_LstSearchObjs.get(tempId) != NULL)
            {
                for(integer i=0; i < mapSearchDef_LstSearchObjs.get(tempId).size(); i++)
                {
                    
                    system.debug(LoggingLevel.WARN, 'For Searchable Object Id: '+ mapSearchDef_LstSearchObjs.get(tempId)[i].Id + '; Result fields are: '+  mapSearchObjId_LstSearchObjFldRec.get(mapSearchDef_LstSearchObjs.get(tempId)[i].Id));
                    
                    if(mapSearchObjId_LstSearchObjFldRec.containsKey(mapSearchDef_LstSearchObjs.get(tempId)[i].Id) &&  mapSearchObjId_LstSearchObjFldRec.get(mapSearchDef_LstSearchObjs.get(tempId)[i].Id) != NULL && mapSearchObjId_LstSearchObjFldRec.get(mapSearchDef_LstSearchObjs.get(tempId)[i].Id).size() > 0)
                    {
                        INTF_WebServicesDef.INTF_SearchInfoDetail TempObj = new INTF_WebServicesDef.INTF_SearchInfoDetail();
                        TempObj.objectDetails = mapSearchDef_LstSearchObjs.get(tempId)[i];
                        TempObj.fields = mapSearchObjId_LstSearchObjFldRec.get(mapSearchDef_LstSearchObjs.get(tempId)[i].Id);
                        INTF_WebServicesDef.INTF_StringMap strMap;
                        
                        for(integer k=0; k < TempObj.fields.size(); k++)
                        {
                            strMap = new INTF_WebServicesDef.INTF_StringMap();
                            strMap.key = mapSearchObjId_LstSearchObjFldRec.get(mapSearchDef_LstSearchObjs.get(tempId)[i].Id)[k].SVMXC__Field_Name__c;
                            strMap.value1 = mapSearchObjId_LstSearchObjFldRec.get(mapSearchDef_LstSearchObjs.get(tempId)[i].Id)[k].Id;
                            strMap.value = ObjNameFldsMap.get(mapSearchObjId_LstSearchObjFldRec.get(mapSearchDef_LstSearchObjs.get(tempId)[i].Id)[k].SVMXC__Object_Name2__c).get(mapSearchObjId_LstSearchObjFldRec.get(mapSearchDef_LstSearchObjs.get(tempId)[i].Id)[k].SVMXC__Field_Name__c);
                            lstStrMap.add(strMap);
                        }
                        
                        TempObj.fieldsLable = lstStrMap;
                        if(mapSearchDef_LstSearchObjs.get(tempId)[i].SVMXC__Name__c != null )
                            TempObj.objectLable = mapSearchDef_LstSearchObjs.get(tempId)[i].SVMXC__Name__c; 
                        else
                            TempObj.objectLable = ObjNameFldsMap.get(TempObj.objectDetails.SVMXC__Target_Object_Name__c).get(TempObj.objectDetails.SVMXC__Target_Object_Name__c); 
                        lstDetails.add(TempObj);
                    }
                }
                
                system.debug(LoggingLevel.WARN, 'list of detail records: '+ lstDetails );
                
                if(lstDetails != NULL && lstDetails.size() > 0)
                {
                    objHdr = new INTF_WebServicesDef.INTF_SearchInfo(mapSearchDefnRecs.get(tempId),lstDetails); 
                    lstInfo.add(objHdr);
                }
            }
        }
        
        INTF_WebServicesDef.INTF_Response objNSI = new INTF_WebServicesDef.INTF_Response();
        objNSI.lstSearchInfo = lstInfo;
        List<INTF_WebServicesDef.INTF_StringMap> strMapLst = new List<INTF_WebServicesDef.INTF_StringMap>();
        
        if(searchOperator != null)
            strMapLst.add(new INTF_WebServicesDef.INTF_StringMap('SEARCH_OPERATOR',searchOperator));
        else
            strMapLst.add(new INTF_WebServicesDef.INTF_StringMap('SEARCH_OPERATOR',String.valueOf('Contains')));
        
        objNSI.stringMap = strMapLst;
        objNSI.MapStringMap = LstMapStrMapObj;
        
        system.debug(LoggingLevel.WARN, 'Meta Response:'+objNSI);
        return objNSI;
    }
    
    /********* Web Service call to get all search data *********************/
    public INTF_WebServicesDef.INTF_Response INTF_getSearchInfoWithData(INTF_WebServicesDef.INTF_SFMRequest request)
    {
        system.debug(LoggingLevel.WARN, 'Request contains:'+request);
        INTF_WebServicesDef.INTF_Response SrchResult = new INTF_WebServicesDef.INTF_Response();
        string strSearchId = null;
        string strKeyWord = null;
        string strObjectId = null;
        set<String> DispFieldswithRef = new set<String>();
        List<String> OrdrFieldswithRef = new List<String>();
        set<String> SearchFieldswithRef = new set<String>();
        Map<String, String> mainDispfldnames = new Map<String, String>();
        String strLimit = '';
        String whereStr = '';
        String Query = '';
        String WhereClause = ' where ';
        integer NoOfRec = -1;
        List<sObject> Resultdata;
        string strPreFlterCriteria = null;
        string SearchOperator = null;
        string SVMXSearchId = null;
        String ObjectName = null;
        String strObjFieldName = null;
        
        for(INTF_WebServicesDef.SVMXMap objCurrentInfo : request.valueMap)
        {
            if(objCurrentInfo.key == 'SearchProcessId')
                strSearchId = objCurrentInfo.value;
            else if(objCurrentInfo.key == 'SVMXSearchProcessId')
                SVMXSearchId = objCurrentInfo.value;
            else if(objCurrentInfo.key == 'KeyWord')
                strKeyWord = objCurrentInfo.value;
            else if(objCurrentInfo.key == 'ObjectId')
                strObjectId = objCurrentInfo.value;
            else if(objCurrentInfo.key == 'RecordLimit')
                NoOfRec = integer.valueOf(objCurrentInfo.value);
            else if(objCurrentInfo.key == 'SEARCH_OPERATOR')
                SearchOperator = string.valueOf(objCurrentInfo.value);
        }
        if(NoOfRec != -1)
            strLimit = 'limit '+ NoOfRec;
        else
            strLimit = 'limit 20';
            
        try
        {
            if(strSearchId != null && strSearchId.length() > 0 )
            {
                SVMXC__ServiceMax_Processes__c ProcessSrchObj = new SVMXC__ServiceMax_Processes__c();
                
                ProcessSrchObj = [Select SVMXC__Target_Object_Name__c, SVMXC__Name_Field__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Module__c from SVMXC__ServiceMax_Processes__c where Id =: strObjectId AND Recordtype.Name = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_OBJECT' AND SVMXC__Module__c =: strSearchId ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                ObjectName = ProcessSrchObj.SVMXC__Target_Object_Name__c;
                strPreFlterCriteria = string.valueOf(ProcessSrchObj.SVMXC__Parent_Object_Criteria__c);
                strObjFieldName = string.valueOf(ProcessSrchObj.SVMXC__Name_Field__c);
                
                List<SVMXC__ServiceMax_Config_Data__c> lstRsltConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
                
                lstRsltConfigData = [Select Id,SVMXC__Search_Object_Field_Type__c,SVMXC__Is_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Object_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c,SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Display_Value__c,SVMXC__Field_Name__c,SVMXC__Field_Relationship_Name__c,SVMXC__FKey_Name_Field__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c =: strObjectId and Recordtype.Name='Expressions' AND SVMXC__Search_Object_Field_Type__c = 'Result' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                system.debug(LoggingLevel.WARN, 'Rslt List'+lstRsltConfigData);
                
                List<SVMXC__ServiceMax_Config_Data__c> lstSrchConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
                
                lstSrchConfigData = [Select Id,SVMXC__Search_Object_Field_Type__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Sequence__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Display_Value__c,SVMXC__Field_Name__c,SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c =: strObjectId and Recordtype.Name='Expressions' AND SVMXC__Search_Object_Field_Type__c = 'Search' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                system.debug(LoggingLevel.WARN, 'Srch List'+lstSrchConfigData);
                
                List<SVMXC__ServiceMax_Config_Data__c> lstOrderConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
                
                lstOrderConfigData = [Select Id,SVMXC__Search_Object_Field_Type__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Sequence__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Display_Value__c,SVMXC__Field_Name__c,SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c, SVMXC__Sort_Order__c, SVMXC__FKey_Name_Field__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c =: strObjectId and Recordtype.Name='Expressions' AND SVMXC__Search_Object_Field_Type__c = 'OrderBy' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    system.debug(LoggingLevel.WARN, 'Srch List'+lstOrderConfigData);
                
                if(lstOrderConfigData != null && lstOrderConfigData.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c ConfObj : lstOrderConfigData)
                    {
                        system.debug(LoggingLevel.WARN, 'seq : '+ConfObj.SVMXC__Sequence__c);
                        
                        String Order;
                        if(ConfObj.SVMXC__Sort_Order__c == 'Ascending')
                            Order = 'ASC';
                        else if(ConfObj.SVMXC__Sort_Order__c == 'Descending')
                            Order = 'DESC';
                        if(ConfObj.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='ORDERBY')
                        {
                            if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'MAIN OBJECT' && ConfObj.SVMXC__Lookup_Field_API_Name__c == null)
                            {
                                if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                {
                                    OrdrFieldswithRef.add(ConfObj.SVMXC__Field_Name__c+' '+Order);
                                    //mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c, ConfObj.SVMXC__Field_Name__c);
                                }
                                else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                {
                                    String disp = '';
                                    disp = ConfObj.SVMXC__Field_Relationship_Name__c+'.'+ConfObj.SVMXC__FKey_Name_Field__c;
                                    //mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c,disp);
                                    OrdrFieldswithRef.add(disp+' '+Order);
                                }
                            }
                            else if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'RELATED OBJECT' && ConfObj.SVMXC__Lookup_Field_API_Name__c != null)
                            {
                                if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                {
                                    String disp = '';
                                    disp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Name__c;
                                    OrdrFieldswithRef.add(disp+' '+Order);
                                    //mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c, disp);
                                }
                                else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                {
                                    String disp = '';
                                    disp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Relationship_Name__c+'.'+ConfObj.SVMXC__FKey_Name_Field__c;
                                    //mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c,disp);
                                    OrdrFieldswithRef.add(disp+' '+Order);
                                }
                            }
                        }
                        system.debug(LoggingLevel.WARN, 'seq : '+ConfObj.SVMXC__Sequence__c+' value : '+OrdrFieldswithRef);
                    }
                }
                system.debug(LoggingLevel.WARN, 'OrdrFieldswithRef : '+OrdrFieldswithRef);
                if(lstRsltConfigData != null && lstRsltConfigData.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c ConfObj : lstRsltConfigData)
                    {
                        if(ConfObj.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='RESULT')
                        {
                            if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'MAIN OBJECT' && ConfObj.SVMXC__Lookup_Field_API_Name__c == null)
                            {
                                if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                {
                                    String disp = '';
                                    // Defect 041092: Anchal - To get translated value of picklist we should use toLabel method.
                                    if(ConfObj.SVMXC__Display_Type__c.equalsIgnoreCase('PICKLIST')){
                                        disp = 'toLabel('+ConfObj.SVMXC__Field_Name__c + ')';
                                    }
                                    else{
                                        disp = ConfObj.SVMXC__Field_Name__c; 
                                    }
                                    DispFieldswithRef.add(disp);
                                    mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c, ConfObj.SVMXC__Field_Name__c);
                                }
                                else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                {
                                    String disp = '';
                                    disp = ConfObj.SVMXC__Field_Relationship_Name__c+'.'+ConfObj.SVMXC__FKey_Name_Field__c;
                                    mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c,disp);
                                    DispFieldswithRef.add(disp);
                                }
                            }
                            else if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'RELATED OBJECT' && ConfObj.SVMXC__Lookup_Field_API_Name__c != null)
                            {
                                if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                {
                                    String disp = '';
                                    // Defect 041092: Anchal - To get translated value of picklist we should use toLabel method.
                                    
                                    if(ConfObj.SVMXC__Display_Type__c.equalsIgnoreCase('PICKLIST')){
                                        disp = 'toLabel('+ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Name__c + ')';
                                    }
                                    else{
                                        disp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Name__c;
                                    }
                                    DispFieldswithRef.add(disp);
                                    mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c, ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Name__c);
                                }
                                else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                {
                                    String disp = '';
                                    disp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Relationship_Name__c+'.'+ConfObj.SVMXC__FKey_Name_Field__c;
                                    mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c,disp);
                                    DispFieldswithRef.add(disp);
                                }
                            }
                        }
                    }
                }
                if(lstSrchConfigData != null && lstSrchConfigData.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c ConfObj : lstSrchConfigData)
                    {
                        if(ConfObj.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='SEARCH')
                        {
                            if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'MAIN OBJECT' && ConfObj.SVMXC__Lookup_Field_API_Name__c == null)
                            {
                                if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                {
                                    SearchFieldswithRef.add(ConfObj.SVMXC__Field_Name__c);
                                }
                                else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                {
                                    String srchp = '';
                                    srchp = ConfObj.SVMXC__Field_Relationship_Name__c +'.'+ ConfObj.SVMXC__FKey_Name_Field__c;
                                    SearchFieldswithRef.add(srchp);
                                }
                            }
                            else if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'RELATED OBJECT'  && ConfObj.SVMXC__Lookup_Field_API_Name__c != null)
                            {
                                if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                {
                                    String srchp = '';
                                    srchp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Name__c;
                                    SearchFieldswithRef.add(srchp);
                                }
                                else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                {
                                    String srchp = '';
                                    srchp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Relationship_Name__c +'.'+ ConfObj.SVMXC__FKey_Name_Field__c;
                                    SearchFieldswithRef.add(srchp);
                                }
                            }
                        }
                    }
                }
                system.debug(LoggingLevel.WARN, 'Pre Filter Critera:'+strPreFlterCriteria);
                if(strPreFlterCriteria != null && strPreFlterCriteria.length() > 0)
                {
                    strPreFlterCriteria = strPreFlterCriteria.replace('SVMX.CURRENTUSER',  String.escapeSingleQuotes(UserInfo.getName()));
                    strPreFlterCriteria = strPreFlterCriteria.replace('SVMX.OWNER',  String.escapeSingleQuotes(UserInfo.getName()));
                    strPreFlterCriteria = strPreFlterCriteria.replace('SVMX.Now', 'today');
                    strPreFlterCriteria = strPreFlterCriteria.replace('SVMX.NOW', 'today');
                    strPreFlterCriteria = strPreFlterCriteria.replace('\'TODAY\'', 'today');
                    strPreFlterCriteria = strPreFlterCriteria.replace('\'Today\'', 'today');
                    strPreFlterCriteria = strPreFlterCriteria.replace('\'TOMORROW\'', 'tomorrow');
                    strPreFlterCriteria = strPreFlterCriteria.replace('\'Tomorrow\'', 'tomorrow');
                    strPreFlterCriteria = strPreFlterCriteria.replace('\'YESTERDAY\'', 'yesterday');
                    strPreFlterCriteria = strPreFlterCriteria.replace('\'Yesterday\'', 'yesterday');
                    
                    WhereClause += ' ( '+strPreFlterCriteria+' ) '+ ' AND ' ;
                }
                if(strKeyWord != null && strKeyWord != '' && strKeyWord.length() > 0)
                {   
                    if(SearchFieldswithRef != null && SearchFieldswithRef.size() > 0)
                    {
                        for(String sfield: SearchFieldswithRef)
                        {
                            if(sfield != '' || sfield != NULL)
                            {
                                if(whereStr != '')
                                    whereStr += ' OR ';
                              
                                if(SearchOperator == 'Exact Match')
                                {
                                    whereStr += sfield + '=' +'\''+string.escapeSingleQuotes(strKeyWord)+'\'';
                                }
                                else if(SearchOperator == 'Starts With')
                                {
                                    whereStr += sfield+' like\''+string.escapeSingleQuotes(strKeyWord)+ '%\'';
                                }
                                else if(SearchOperator == 'Contains')
                                {
                                    whereStr += sfield+' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                                }
                                else if(SearchOperator == 'Ends With')
                                {
                                    whereStr += sfield+' like \'%'+string.escapeSingleQuotes(strKeyWord)+'\'';
                                }
                                else
                                {
                                    whereStr += sfield+' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                                }
                            }   
                        }
                        WhereClause += ' ( '+whereStr+' ) ';
                    }
                    else if(strPreFlterCriteria != null && strPreFlterCriteria != '' && strPreFlterCriteria.length() != 0 )
                    {
                        if(strObjFieldName != NULL)
                        {
                            if(SearchOperator == 'Exact Match')
                                whereStr += strObjFieldName + '=' +'\''+string.escapeSingleQuotes(strKeyWord)+'\'';
                            else if(SearchOperator == 'Starts With')
                                whereStr += strObjFieldName +' like\''+string.escapeSingleQuotes(strKeyWord)+ '%\'';
                            else if(SearchOperator == 'Contains')
                                whereStr += strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                            else if(SearchOperator == 'Ends With')
                                whereStr += strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'\'';
                            else
                                whereStr += strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                            
                            WhereClause += ' ( '+whereStr+' ) ';
                        }
                        else
                            WhereClause =  'where ' + ' ('+strPreFlterCriteria+')';
                    }
                    else if(strPreFlterCriteria == null || strPreFlterCriteria == '' || strPreFlterCriteria.length() == 0 )
                    {
                        if(strObjFieldName != NULL)
                        {
                            if(SearchOperator == 'Exact Match')
                                whereStr = strObjFieldName  + '=' +'\''+string.escapeSingleQuotes(strKeyWord)+'\'';
                            else if(SearchOperator == 'Starts With')
                                whereStr = strObjFieldName +' like\''+string.escapeSingleQuotes(strKeyWord)+ '%\'';
                            else if(SearchOperator == 'Contains')
                                whereStr = strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                            else if(SearchOperator == 'Ends With')
                                whereStr = strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'\'';
                            else
                                whereStr = strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                            
                            WhereClause =  'where ' + ' ( ' + whereStr + ' ) ';
                        }
                        else
                            WhereClause = ' ';
                    }
                }
                else if((strKeyWord == null || strKeyWord == '' || strKeyWord.length() == 0 ) && (strPreFlterCriteria == null || strPreFlterCriteria == '' || strPreFlterCriteria.length() == 0 ))
                {
                    WhereClause = ' ';
                }
                else if ((strKeyWord == null || strKeyWord == '' || strKeyWord.length() == 0 ) && (strPreFlterCriteria != null && strPreFlterCriteria != '' && strPreFlterCriteria.length() != 0 ))
                {
                    WhereClause =  'where ' + ' ('+strPreFlterCriteria+')';
                }
                
                //added by manish for defect 10815
                if(ObjectName.equals('Event') || ObjectName.equals('Task')){
                    if((strKeyWord == null || strKeyWord == '' || strKeyWord.length() == 0 ) && (strPreFlterCriteria == null || strPreFlterCriteria == '' || strPreFlterCriteria.length() == 0 ))
                        WhereClause = 'where ' + 'IsRecurrence = false';
                    else if(!WhereClause.contains('IsRecurrence'))
                        WhereClause = WhereClause + ' AND (IsRecurrence = false)';
                }//added by manish
                
                if(DispFieldswithRef.size() != 0 && DispFieldswithRef.size() > 0 )
                {
                    if(!(DispFieldswithRef.contains('Id') || DispFieldswithRef.contains('ID') || DispFieldswithRef.contains('id') || DispFieldswithRef.contains('iD')))
                            DispFieldswithRef.add('Id');
                            
                    if(OrdrFieldswithRef.size() > 0){
                        //added by manish for defect 10810
                        if(ObjectName.equals('Event') && !(SVMX_getFieldNamesFromList(DispFieldswithRef).contains('IsAllDayEvent')))
                            Query = 'SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ',IsAllDayEvent' + ' FROM '+ ObjectName +' '+WhereClause +' Order By '+SVMX_getFieldOrderNamesFromList(OrdrFieldswithRef)+ ' '+strLimit;
                        else
                            Query = 'SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+  ' FROM '+ ObjectName +' '+WhereClause +' Order By '+SVMX_getFieldOrderNamesFromList(OrdrFieldswithRef)+ ' '+strLimit;
                    }
                    else{
                        //added by manish
                        if(ObjectName.equals('Event') && !(SVMX_getFieldNamesFromList(DispFieldswithRef).contains('IsAllDayEvent')))
                            Query = 'SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ',IsAllDayEvent' + ' FROM '+ ObjectName +' '+WhereClause + ' '+strLimit;
                        else                        
                            Query = 'SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+' FROM '+ ObjectName +' '+WhereClause + ' '+strLimit;
                    }
                    system.debug(LoggingLevel.WARN, 'Test Query:'+Query);
                    try
                    {   
                        Resultdata = database.query(Query);
                        system.debug('Query ---'+Query);
                        system.debug( 'Result -- Data: --'+Resultdata);
                    }
                    catch(exception ex)
                    {
                        system.debug(LoggingLevel.WARN, 'Error:'+ex.getMessage());
                        return null;
                    }
                }
                
                list<INTF_WebServicesDef.INTF_StringMap> strMapLst;
                list<INTF_WebServicesDef.INTF_MapStringMap> mapStrMaplst = new list<INTF_WebServicesDef.INTF_MapStringMap>();
                list<INTF_WebServicesDef.INTF_StringMap> strMapLstForOtherDetails = new list<INTF_WebServicesDef.INTF_StringMap>();
                strMapLstForOtherDetails.add(new INTF_WebServicesDef.INTF_StringMap('SEARCH_OBJECT_ID', strObjectId));
                strMapLstForOtherDetails.add(new INTF_WebServicesDef.INTF_StringMap('SEARCH_OBJECT_NAME', string.valueOf(ProcessSrchObj.SVMXC__Target_Object_Name__c)));
                strMapLstForOtherDetails.add(new INTF_WebServicesDef.INTF_StringMap('NO_OF_RECORDS', (Resultdata != null && Resultdata.size() > 0) ? string.valueOf(Resultdata.size()) : string.valueOf(-1)));
                
                if(Resultdata != null)
                {
                    for(sObject sobj: Resultdata)
                    {
                        INTF_WebServicesDef.INTF_MapStringMap mapStrMap = new INTF_WebServicesDef.INTF_MapStringMap();
                        if(mainDispfldnames.size() > 0)
                        {
                            strMapLst = new list<INTF_WebServicesDef.INTF_StringMap>();
                            for (SVMXC__ServiceMax_Config_Data__c ConfObj : lstRsltConfigData)
                            {
                                INTF_WebServicesDef.INTF_StringMap strMap = new INTF_WebServicesDef.INTF_StringMap(); 
                                strMap.value1 = 'NotApplicable';
                                string mapValue = '--';
                                try
                                {
                                    string strDTFld = null;
                                    if(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).contains('.'))
                                    {
                                        String objval = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]));
                                        if(objval == null)
                                            mapValue = '--';
                                        else
                                        {
                                            
                                            if(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1].contains('__r'))
                                            {
                                                
                                             //Changes done by Nidhi as part of defect BAC-4224
                                             //mapValue = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1].replace('__r', '__c')));
                                            
                                             mapValue = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[2]));
                                             strMap.value1 = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1].replace('__r', '__c')));
    
                                            }
                                            else
                                            {
                                                mapValue = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1]));
                                            }
                                            if(ConfObj.SVMXC__FKey_Name_Field__c != null && ConfObj.SVMXC__FKey_Name_Field__c != '' && strMap.value1 == 'NotApplicable')
                                            {
                                                strMap.value1 = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).Id); 
                                                strMap.sortValue = mapValue;
                                            }
                                            else if(ConfObj.SVMXC__Is_Name_Field__c && strMap.value1 == 'NotApplicable')
                                            {
                                                strMap.value1 = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).Id); 
                                            }
                                           
                                            if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'BOOLEAN')
                                            {
                                                mapValue = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1]));
                                                if(mapValue.toUpperCase() == 'TRUE')
                                                    strMap.sortValue = '1';
                                                else
                                                    strMap.sortValue = '0';
                                            }
                                            else if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'DATE')
                                            {
                                                strDTFld = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1]));
                                                if(strDTFld != null && strDTFld.length() > 0)
                                                {
                                                    mapValue = Date.valueOf(strDTFld).format();
                                                    strMap.sortValue = string.valueOf(Datetime.valueOf(strDTFld).getTime());
                                                }
                                            }
                                            else if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'DATETIME')
                                            {
                                                strDTFld = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1]));
                                                if(strDTFld != null && strDTFld.length() > 0)
                                                {
                                                    Datetime t = Datetime.valueOfGmt(strDTFld);
                                                    mapValue = t.format();
                                                    strMap.sortValue = string.valueOf(t.getTime());
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                       if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'BOOLEAN')
                                        {
                                            mapValue = String.valueOf(sobj.get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c)));
                                            if(mapValue.toUpperCase() == 'TRUE')
                                                strMap.sortValue = '1';
                                            else
                                                strMap.sortValue = '0';
                                        }
                                        else if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'DATE')
                                        {
                                            strDTFld = String.valueOf(sobj.get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c)));
                                            if(strDTFld != null && strDTFld.length() > 0)
                                            {
                                                mapValue = Date.valueOf(strDTFld).format();
                                                strMap.sortValue = string.valueOf(Datetime.valueOf(strDTFld).getTime());
                                            }
                                        }
                                        else if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'DATETIME')
                                        {
                                            strDTFld = String.valueOf(sobj.get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c)));
                                            if(strDTFld != null && strDTFld.length() > 0)
                                            {
                                                Datetime t = Datetime.valueOfGmt(strDTFld);
                                                mapValue = t.format();
                                                //added by manish for defect 10810
                                                if(ObjectName.equals('Event') && (String.valueOf(sobj.get('IsAllDayEvent')).equals('true'))){
                                                    if(String.valueOf(ConfObj.SVMXC__Field_Name__c).equals('StartDateTime') || String.valueOf(ConfObj.SVMXC__Field_Name__c).equals('EndDateTime')){
                                                        Date d = t.date();
                                                        mapValue = d.format() + ' ' + System.Label.SFM003_TAG010;
                                                    }
                                                }
                                                //added by manish
                                                strMap.sortValue = string.valueOf(t.getTime());
                                            }
                                        }
                                        else
                                        {
                                            mapValue = String.valueOf(sobj.get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c)));
                                            strMap.sortValue = mapValue;
                                        }
                                        
                                        if(ConfObj.SVMXC__Is_Name_Field__c)
                                        {
                                            strMap.value1 = String.valueOf(sobj.Id);
                                        }
                                    }
                                }
                                catch (Exception ex)
                                {
                                    system.debug(LoggingLevel.WARN, 'ERROR'+ ex.getmessage());
                                }
                                strMap.key = string.valueOf(ConfObj.SVMXC__Field_Name__c);
                                if(mapValue == null)
                                    mapValue = '--';
                                strMap.value = mapValue;
                                strMap.type = string.valueOf(ConfObj.SVMXC__Display_Type__c);
                                if(strMap.sortValue == null || strMap.sortValue == '')
                                    strMap.sortValue = strMap.value;
                                if(strMap.value1 == null || strMap.value1 == '')
                                    strMap.value1 = 'NotApplicable';
                                strMapLst.add(strMap);
                            }
                            mapStrMap.valueMap = strMapLst;
                            mapStrMap.key = 'RecordId'; // For row Id.
                            mapStrMap.id = String.valueOf(sobj.Id);
                            mapStrMaplst.add(mapStrMap);
                        }
                    }
                    SrchResult.stringMap = strMapLstForOtherDetails;
                    SrchResult.MapStringMap = mapStrMaplst;
                    system.debug(LoggingLevel.WARN, 'Response:'+SrchResult);
                }
                return SrchResult;
            }
        }
        catch (Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'ERROR'+ ex.getmessage());
        }
        return null;
    }
    
    //for iPad SFM Search
    public INTF_WebServicesDef.INTF_Response INTF_getSearchInfoExcludeGivenIDs(INTF_WebServicesDef.INTF_SFMRequest request)
    {
        system.debug(LoggingLevel.WARN, 'Request contains:'+request);
        INTF_WebServicesDef.INTF_Response SrchResult = new INTF_WebServicesDef.INTF_Response();
        string strSearchId = null;
        string strKeyWord = null;
        string strObjectId = null;
        Map<String, String> mainDispfldnames = new Map<String, String>();
        String strLimit = '';
        integer NoOfRec = -1;
        List<sObject> Resultdata;
        string strPreFlterCriteria = null;
        string SearchOperator = null;
        string SVMXSearchId = null;
        String strObjFieldName = null;
        //In this List we have ID's of each object 
        List<String> lstObjIds = new List<String>();
        
        String ObjectName = null;
        for(INTF_WebServicesDef.SVMXMap objCurrentInfo : request.valueMap)
        {
            if(objCurrentInfo.key == 'SearchProcessId')
                strSearchId = objCurrentInfo.value;
            else if(objCurrentInfo.key == 'SVMXSearchProcessId')
                SVMXSearchId = objCurrentInfo.value;
            else if(objCurrentInfo.key == 'KeyWord')
                strKeyWord = objCurrentInfo.value;
            else if(objCurrentInfo.key == 'ObjectId')
                lstObjIds.add(objCurrentInfo.value);
            else if(objCurrentInfo.key == 'RecordLimit')
                NoOfRec = integer.valueOf(objCurrentInfo.value);
            else if(objCurrentInfo.key == 'SEARCH_OPERATOR')
                SearchOperator = string.valueOf(objCurrentInfo.value);
        }
        
    if(NoOfRec != -1)
            strLimit = 'limit '+ NoOfRec;
        else
            strLimit = 'limit 100';
        
        if(NoOfRec > 400)
          strLimit = 'limit 400';
        
        system.debug(LoggingLevel.WARN, 'lstObjIds=='+lstObjIds + '; strLimit = ' + strLimit);
        for(String objId : lstObjIds)
        {
            String WhereClause = ' where ';
            String whereStr = '';
            String query = '';
            Set<String> SearchFieldswithRef = new Set<String>();
            Set<String> DispFieldswithRef = new Set<String>();
            Set<String> OrdrFieldswithRef = new Set<String>();
            try
            {
                if(strSearchId != null && strSearchId.length() > 0 )
                {
                    SVMXC__ServiceMax_Processes__c ProcessSrchObj = new SVMXC__ServiceMax_Processes__c();
                    
                    ProcessSrchObj = [Select SVMXC__Target_Object_Name__c,SVMXC__Parent_Object_Criteria__c, SVMXC__Name_Field__c, SVMXC__Module__c from SVMXC__ServiceMax_Processes__c where Id =: objId AND Recordtype.Name = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_OBJECT' AND SVMXC__Module__c =: strSearchId ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    ObjectName = ProcessSrchObj.SVMXC__Target_Object_Name__c;
                    strPreFlterCriteria = string.valueOf(ProcessSrchObj.SVMXC__Parent_Object_Criteria__c);
                    strObjFieldName = string.valueOf(ProcessSrchObj.SVMXC__Name_Field__c);
                    
                    List<SVMXC__ServiceMax_Config_Data__c> lstRsltConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
                    
                    lstRsltConfigData = [Select Id,SVMXC__Search_Object_Field_Type__c,SVMXC__Is_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Object_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__Sort_Order__c, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Display_Value__c,SVMXC__Field_Name__c,SVMXC__Field_Relationship_Name__c,SVMXC__FKey_Name_Field__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c =: objId and Recordtype.Name='Expressions' AND SVMXC__Search_Object_Field_Type__c = 'Result' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    system.debug(LoggingLevel.WARN, 'Rslt List'+lstRsltConfigData);
                    
                    List<SVMXC__ServiceMax_Config_Data__c> lstSrchConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
                    
                    lstSrchConfigData = [Select Id,SVMXC__Search_Object_Field_Type__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Sequence__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sort_Order__c, SVMXC__Object_Name2__c, SVMXC__Display_Value__c,SVMXC__Field_Name__c,SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c =: objId and Recordtype.Name='Expressions' AND SVMXC__Search_Object_Field_Type__c = 'Search' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    system.debug(LoggingLevel.WARN, 'Srch List'+lstSrchConfigData);
                    
                    List<SVMXC__ServiceMax_Config_Data__c> lstOrderConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
                    
                    lstOrderConfigData = [Select Id,SVMXC__Search_Object_Field_Type__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Sequence__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Display_Value__c,SVMXC__Field_Name__c,SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c, SVMXC__Sort_Order__c, SVMXC__FKey_Name_Field__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c =: objId and Recordtype.Name='Expressions' AND SVMXC__Search_Object_Field_Type__c = 'OrderBy' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    system.debug(LoggingLevel.WARN, 'Srch List'+lstOrderConfigData);
                    
                    if(lstOrderConfigData != null && lstOrderConfigData.size() > 0)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c ConfObj : lstOrderConfigData)
                        {
                            String Order;
                            if(ConfObj.SVMXC__Sort_Order__c == 'Ascending')
                                Order = 'ASC';
                            else if(ConfObj.SVMXC__Sort_Order__c == 'Descending')
                                Order = 'DESC';
                            if(ConfObj.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='ORDERBY')
                            {
                                if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'MAIN OBJECT' && ConfObj.SVMXC__Lookup_Field_API_Name__c == null)
                                {
                                    if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                    {
                                        OrdrFieldswithRef.add(ConfObj.SVMXC__Field_Name__c+' '+Order);
                                        //mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c, ConfObj.SVMXC__Field_Name__c);
                                    }
                                    else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                    {
                                        String disp = '';
                                        disp = ConfObj.SVMXC__Field_Relationship_Name__c+'.'+ConfObj.SVMXC__FKey_Name_Field__c;
                                        //mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c,disp);
                                        OrdrFieldswithRef.add(disp+' '+Order);
                                    }
                                }
                                else if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'RELATED OBJECT' && ConfObj.SVMXC__Lookup_Field_API_Name__c != null)
                                {
                                    if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                    {
                                        String disp = '';
                                        disp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Name__c;
                                        OrdrFieldswithRef.add(disp+' '+Order);
                                        //mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c, disp);
                                    }
                                    else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                    {
                                        String disp = '';
                                        disp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Relationship_Name__c+'.'+ConfObj.SVMXC__FKey_Name_Field__c;
                                        //mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c,disp);
                                        OrdrFieldswithRef.add(disp+' '+Order);
                                    }
                                }
                            }
                        }
                    }
                    
                    if(lstRsltConfigData != null && lstRsltConfigData.size() > 0)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c ConfObj : lstRsltConfigData)
                        {
                            if(ConfObj.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='RESULT')
                            {
                                if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'MAIN OBJECT' && ConfObj.SVMXC__Lookup_Field_API_Name__c == null)
                                {
                                    if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                    {
                                        DispFieldswithRef.add(ConfObj.SVMXC__Field_Name__c);
                                        mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c, ConfObj.SVMXC__Field_Name__c);
                                    }
                                    else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                    {
                                        String disp = '';
                                        disp = ConfObj.SVMXC__Field_Relationship_Name__c+'.'+ConfObj.SVMXC__FKey_Name_Field__c;
                                        mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c,disp);
                                        DispFieldswithRef.add(disp);
                                    }
                                }
                                else if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'RELATED OBJECT' && ConfObj.SVMXC__Lookup_Field_API_Name__c != null)
                                {
                                    if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                    {
                                        String disp = '';
                                        disp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Name__c;
                                        DispFieldswithRef.add(disp);
                                        mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c, disp);
                                    }
                                    else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                    {
                                        String disp = '';
                                        disp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Relationship_Name__c+'.'+ConfObj.SVMXC__FKey_Name_Field__c;
                                        mainDispfldnames.put(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c,disp);
                                        DispFieldswithRef.add(disp);
                                    }
                                }
                            }
                        }
                    }
                    if(lstSrchConfigData != null && lstSrchConfigData.size() > 0)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c ConfObj : lstSrchConfigData)
                        {
                            if(ConfObj.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='SEARCH')
                            {
                                if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'MAIN OBJECT' && ConfObj.SVMXC__Lookup_Field_API_Name__c == null)
                                {
                                    if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                    {
                                        SearchFieldswithRef.add(ConfObj.SVMXC__Field_Name__c);
                                    }
                                    else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                    {
                                        String srchp = '';
                                        srchp = ConfObj.SVMXC__Field_Relationship_Name__c +'.'+ ConfObj.SVMXC__FKey_Name_Field__c;
                                        SearchFieldswithRef.add(srchp);
                                    }
                                }
                                else if(ConfObj.SVMXC__Display_Value__c.toUpperCase() == 'RELATED OBJECT'  && ConfObj.SVMXC__Lookup_Field_API_Name__c != null)
                                {
                                    if(ConfObj.SVMXC__Display_Type__c.toUpperCase() != 'REFERENCE')
                                    {
                                        String srchp = '';
                                        srchp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Name__c;
                                        SearchFieldswithRef.add(srchp);
                                    }
                                    else if(ConfObj.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE')
                                    {
                                        String srchp = '';
                                        srchp = ConfObj.SVMXC__Lookup_Field_API_Name__c+'.'+ConfObj.SVMXC__Field_Relationship_Name__c +'.'+ ConfObj.SVMXC__FKey_Name_Field__c;
                                        SearchFieldswithRef.add(srchp);
                                    }
                                }
                            }
                        }
                    }
                    system.debug(LoggingLevel.WARN, 'Pre Filter Critera:'+strPreFlterCriteria);
                    if(strPreFlterCriteria != null && strPreFlterCriteria.length() > 0)
                    {
                        strPreFlterCriteria = strPreFlterCriteria.replace('SVMX.CURRENTUSER',  String.escapeSingleQuotes(UserInfo.getName()));
                        strPreFlterCriteria = strPreFlterCriteria.replace('SVMX.OWNER',  String.escapeSingleQuotes(UserInfo.getName()));
                        strPreFlterCriteria = strPreFlterCriteria.replace('SVMX.Now', 'today');
                        strPreFlterCriteria = strPreFlterCriteria.replace('SVMX.NOW', 'today');
                        strPreFlterCriteria = strPreFlterCriteria.replace('\'TODAY\'', 'today');
                        strPreFlterCriteria = strPreFlterCriteria.replace('\'Today\'', 'today');
                        strPreFlterCriteria = strPreFlterCriteria.replace('\'TOMORROW\'', 'tomorrow');
                        strPreFlterCriteria = strPreFlterCriteria.replace('\'Tomorrow\'', 'tomorrow');
                        strPreFlterCriteria = strPreFlterCriteria.replace('\'YESTERDAY\'', 'yesterday');
                        strPreFlterCriteria = strPreFlterCriteria.replace('\'Yesterday\'', 'yesterday');
                        WhereClause += ' ( '+strPreFlterCriteria+' ) '+ ' AND ' ;
                    }
                    if(strKeyWord != null && strKeyWord != '' && strKeyWord.length() > 0)
                    {
                        if(SearchFieldswithRef != null && SearchFieldswithRef.size() > 0)
                        {
                            for(String sfield: SearchFieldswithRef)
                            {
                                if(sfield != '' || sfield != NULL)
                                {
                                    if(whereStr != '')
                                        whereStr += ' OR ';
                                    
                                    if(SearchOperator == 'Exact Match')
                                    {
                                        whereStr += sfield + '=' +'\''+string.escapeSingleQuotes(strKeyWord)+'\'';
                                    }
                                    else if(SearchOperator == 'Starts With')
                                    {
                                        whereStr += sfield+' like\''+string.escapeSingleQuotes(strKeyWord)+ '%\'';
                                    }
                                    else if(SearchOperator == 'Contains')
                                    {
                                        whereStr += sfield+' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                                    }
                                    else if(SearchOperator == 'Ends With')
                                    {
                                        whereStr += sfield+' like \'%'+string.escapeSingleQuotes(strKeyWord)+'\'';
                                    }
                                    else
                                    {
                                        //Get the value from global settings....
                                        whereStr += sfield+' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                                    }
                                }   
                            }
                            WhereClause += ' ( '+whereStr+' ) '+ ' ';
                        }
                        else if(strPreFlterCriteria != null && strPreFlterCriteria != '' && strPreFlterCriteria.length() != 0 )
                        {
                            if(strObjFieldName != NULL)
                            {
                                if(SearchOperator == 'Exact Match')
                                    whereStr += strObjFieldName + '=' +'\''+string.escapeSingleQuotes(strKeyWord)+'\'';
                                else if(SearchOperator == 'Starts With')
                                    whereStr += strObjFieldName +' like\''+string.escapeSingleQuotes(strKeyWord)+ '%\'';
                                else if(SearchOperator == 'Contains')
                                    whereStr += strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                                else if(SearchOperator == 'Ends With')
                                    whereStr += strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'\'';
                                else
                                    whereStr += strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                                
                                WhereClause += ' ( '+whereStr+' ) '+ ' ';
                            }
                            else
                                WhereClause =  'where ' + ' ('+strPreFlterCriteria+')' + ' ';
                        }
                        else if(strPreFlterCriteria == null || strPreFlterCriteria == '' || strPreFlterCriteria.length() == 0 )
                        {
                            if(strObjFieldName != NULL)
                            {
                                if(SearchOperator == 'Exact Match')
                                    whereStr = strObjFieldName  + '=' +'\''+string.escapeSingleQuotes(strKeyWord)+'\'';
                                else if(SearchOperator == 'Starts With')
                                    whereStr = strObjFieldName +' like\''+string.escapeSingleQuotes(strKeyWord)+ '%\'';
                                else if(SearchOperator == 'Contains')
                                    whereStr = strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                                else if(SearchOperator == 'Ends With')
                                    whereStr = strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'\'';
                                else
                                    whereStr = strObjFieldName +' like \'%'+string.escapeSingleQuotes(strKeyWord)+'%\'';
                                
                                WhereClause =  'where ' + ' ( ' + whereStr + ' ) ' + ' ';
                            }
                            else
                                WhereClause = ' ';
                        }
                    }
                    else if((strKeyWord == null || strKeyWord == '' || strKeyWord.length() == 0 ) && (strPreFlterCriteria == null || strPreFlterCriteria == '' || strPreFlterCriteria.length() == 0 ))
                    {
                        WhereClause = ' ';
                    }
                    else if ((strKeyWord == null || strKeyWord == '' || strKeyWord.length() == 0 ) && (strPreFlterCriteria != null && strPreFlterCriteria != '' && strPreFlterCriteria.length() != 0 ))
                    {
                        WhereClause =  'where ' + ' ('+strPreFlterCriteria+')' + ' ';
                    }
                    
                    //added by manish for defect 10815
                    if(ObjectName.equals('Event') || ObjectName.equals('Task')){
                        if((strKeyWord == null || strKeyWord == '' || strKeyWord.length() == 0 ) && (strPreFlterCriteria == null || strPreFlterCriteria == '' || strPreFlterCriteria.length() == 0 ))
                            WhereClause = 'where ' + 'IsRecurrence = false';
                        else if(!WhereClause.contains('IsRecurrence'))
                            WhereClause = WhereClause + ' AND (IsRecurrence = false)';
                    }//added by manish
          
                    if(DispFieldswithRef.size() != 0 && DispFieldswithRef.size() > 0 )
                    {
                        if(!(DispFieldswithRef.contains('Id') || DispFieldswithRef.contains('ID') || DispFieldswithRef.contains('id') || DispFieldswithRef.contains('iD')))
                            DispFieldswithRef.add('Id');
                            
                        if(OrdrFieldswithRef.size() > 0){
                            //added by manish for defect 10810
                            if(ObjectName.equals('Event') && !(SVMX_getFieldNamesFromList(DispFieldswithRef).contains('IsAllDayEvent')))
                                query = 'SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ',IsAllDayEvent' +  ' FROM '+ ObjectName + ' ' + WhereClause +' Order By '+SVMX_getFieldNamesFromList(OrdrFieldswithRef)+' ' + strLimit;
                            else
                                query = 'SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)  + ' FROM '+ ObjectName + ' ' + WhereClause +' Order By '+SVMX_getFieldNamesFromList(OrdrFieldswithRef)+' ' + strLimit;
                        }
                        else{
                            //added by manish for defect 10810
                            if(ObjectName.equals('Event') && !(SVMX_getFieldNamesFromList(DispFieldswithRef).contains('IsAllDayEvent')))
                                query = 'SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ',IsAllDayEvent' +  ' FROM '+ ObjectName + ' ' + WhereClause +' ' + strLimit;
                            else
                                query = 'SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ' FROM '+ ObjectName + ' ' + WhereClause +' ' + strLimit;
                        }
                        system.debug(LoggingLevel.WARN, 'Test query:' + query);
                        try
                        { 
                            Resultdata = database.query(query);
                            system.debug(LoggingLevel.WARN, 'Query Result: ' + Resultdata);
                        }
                        catch(exception ex)
                        {
                            system.debug(LoggingLevel.WARN, 'Errror:' + ex.getMessage());
                            return null;
                        }
                    }
                    
                    list<INTF_WebServicesDef.INTF_StringMap> strMapLst;
                    list<INTF_WebServicesDef.INTF_MapStringMap> mapStrMaplst = new list<INTF_WebServicesDef.INTF_MapStringMap>();
                    list<INTF_WebServicesDef.INTF_StringMap> strMapLstForOtherDetails = new list<INTF_WebServicesDef.INTF_StringMap>();
                    strMapLstForOtherDetails.add(new INTF_WebServicesDef.INTF_StringMap('SEARCH_OBJECT_ID', objId));
                    strMapLstForOtherDetails.add(new INTF_WebServicesDef.INTF_StringMap('SEARCH_OBJECT_NAME', string.valueOf(ProcessSrchObj.SVMXC__Target_Object_Name__c)));
                    strMapLstForOtherDetails.add(new INTF_WebServicesDef.INTF_StringMap('NO_OF_RECORDS', (Resultdata != null && Resultdata.size() > 0) ? string.valueOf(Resultdata.size()) : string.valueOf(-1)));
                    
                    if(Resultdata != null)
                    {
                        for(sObject sobj: Resultdata)
                        {
                            INTF_WebServicesDef.INTF_MapStringMap mapStrMap = new INTF_WebServicesDef.INTF_MapStringMap();
                            if(mainDispfldnames.size() > 0)
                            {
                                strMapLst = new list<INTF_WebServicesDef.INTF_StringMap>(); 
                                for (SVMXC__ServiceMax_Config_Data__c ConfObj : lstRsltConfigData)
                                {
                                    INTF_WebServicesDef.INTF_StringMap strMap = new INTF_WebServicesDef.INTF_StringMap(); 
                                    strMap.value1 = 'NotApplicable';
                                    string mapValue = '--';
                                    try
                                    {
                                        string strDTFld = null;
                                        if(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).contains('.'))
                                        {
                                            String objval = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]));
                                            if(objval == null)
                                                mapValue = '--';
                                            else
                                            {
                                                if(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1].contains('__r'))
                                                {
                                                    mapValue = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1].replace('__r', '__c')));
                                                    strMap.value1 = mapValue;
                                                }
                                                else
                                                {
                                                    mapValue = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1]));
                                                }
                                                if(ConfObj.SVMXC__FKey_Name_Field__c != null && ConfObj.SVMXC__FKey_Name_Field__c != '' && strMap.value1 == 'NotApplicable')
                                                {
                                                    strMap.value1 = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).Id); 
                                                    strMap.sortValue = mapValue;
                                                }
                                                else if(ConfObj.SVMXC__Is_Name_Field__c && strMap.value1 == 'NotApplicable')
                                                {
                                                    strMap.value1 = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).Id); 
                                                }
                                               
                                                if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'BOOLEAN')
                                                {
                                                    mapValue = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1]));
                                                    if(mapValue.toUpperCase() == 'TRUE')
                                                        strMap.sortValue = '1';
                                                    else
                                                        strMap.sortValue = '0';
                                                }
                                                else if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'DATE')
                                                {
                                                    strDTFld = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1]));
                                                    if(strDTFld != null && strDTFld.length() > 0)
                                                    {
                                                        mapValue = Date.valueOf(strDTFld).format();
                                                        strMap.sortValue = string.valueOf(Datetime.valueOf(strDTFld).getTime());
                                                    }
                                                }
                                                else if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'DATETIME')
                                                {
                                                    strDTFld = String.valueOf(sobj.getSObject(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[0]).get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c).split('\\.')[1]));
                                                    if(strDTFld != null && strDTFld.length() > 0)
                                                    {
                                                        Datetime t = Datetime.valueOfGmt(strDTFld);
                                                        mapValue = t.format();
                                                        strMap.sortValue = string.valueOf(t.getTime());
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                           if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'BOOLEAN')
                                            {
                                                mapValue = String.valueOf(sobj.get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c)));
                                                if(mapValue.toUpperCase() == 'TRUE')
                                                    strMap.sortValue = '1';
                                                else
                                                    strMap.sortValue = '0';
                                            }
                                            else if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'DATE')
                                            {
                                                strDTFld = String.valueOf(sobj.get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c)));
                                                if(strDTFld != null && strDTFld.length() > 0)
                                                {
                                                    mapValue = String.valueOf(Date.valueOf(strDTFld));
                                                    strMap.sortValue = string.valueOf(Datetime.valueOf(strDTFld).getTime());
                                                }
                                            }
                                            else if(string.valueOf(ConfObj.SVMXC__Display_Type__c).toUpperCase() == 'DATETIME')
                                            {
                                                strDTFld = String.valueOf(sobj.get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c)));
                                                if(strDTFld != null && strDTFld.length() > 0)
                                                {
                                                    Datetime t = Datetime.valueOfGmt(strDTFld);
                                                    mapValue = strDTFld;//t.format();
                                                    //added by manish for defect 10810
                                                    if(ObjectName.equals('Event') && (String.valueOf(sobj.get('IsAllDayEvent')).equals('true'))){
                                                        if(String.valueOf(ConfObj.SVMXC__Field_Name__c).equals('StartDateTime') || String.valueOf(ConfObj.SVMXC__Field_Name__c).equals('EndDateTime')){
                                                            Date d = t.date();
                                                            mapValue = d.format() + ' ' + System.Label.SFM003_TAG010;
                                                        }
                                                    }
                                                    //added by manish
                                                    strMap.sortValue = string.valueOf(t.getTime());
                                                }
                                            }
                                            else
                                            {
                                                mapValue = String.valueOf(sobj.get(mainDispfldnames.get(ConfObj.Id+'_'+ConfObj.SVMXC__Field_Name__c)));
                                                strMap.sortValue = mapValue;
                                            }
                                            
                                            if(ConfObj.SVMXC__Is_Name_Field__c)
                                            {
                                                strMap.value1 = String.valueOf(sobj.Id);
                                            }
                                        }
                                    }
                                    catch (Exception ex)
                                    {
                                        system.debug(LoggingLevel.WARN, 'ERROR' + ex.getmessage());
                                    }
                                    strMap.key = string.valueOf(ConfObj.SVMXC__Field_Name__c);
                                    if(mapValue == null)
                                        mapValue = '--';
                                    strMap.value = mapValue;
                                    strMap.type = string.valueOf(ConfObj.SVMXC__Display_Type__c);
                                    if(strMap.sortValue == null || strMap.sortValue == '')
                                        strMap.sortValue = strMap.value;
                                    if(strMap.value1 == null || strMap.value1 == '')
                                        strMap.value1 = 'NotApplicable';
                                    strMapLst.add(strMap);
                                }
                                mapStrMap.valueMap = strMapLst;
                                mapStrMap.key = objId;
                                mapStrMap.id = String.valueOf(sobj.Id);
                                mapStrMaplst.add(mapStrMap);
                            }
                        }
                        SrchResult.stringMap.addAll(strMapLstForOtherDetails);
                        SrchResult.MapStringMap.addAll(mapStrMaplst);
                        system.debug(LoggingLevel.WARN, 'Test' + SrchResult);
                    }
                }
            }
            catch (Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'ERROR'+ ex.getmessage());
                return null;
            }
        }   
        return SrchResult;
    }
        
    public String SVMX_getFieldNamesFromList(set<String> fieldList)
    {
        String fieldNames = '';
        for (String field : fieldList) 
        {
            if (fieldNames.length()>0) 
            {
                fieldNames += ',';
            }
            fieldNames += field;
        }
       return fieldNames;
    }
    public String SVMX_getFieldOrderNamesFromList(List<String> fieldList)
    {
        String fieldNames = '';
        for (String field : fieldList) 
        {
            if (fieldNames.length()>0) 
            {
                fieldNames += ',';
            }
            fieldNames += field;
        }
       return fieldNames;
    }
}