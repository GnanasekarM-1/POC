/* Security Scanned */
public with sharing class SFM_SearchWidget
{
    public string selectedSearch = null;
    public string getselectedSearch(){return this.selectedSearch;}
    public void setselectedSearch(string str){this.selectedSearch = str;}
    public string keyWord = null;
    public string getkeyWord(){return this.keyWord;}
    public void setkeyWord(string str){this.keyWord = str;}
    list<SVMXC__ServiceMax_Processes__c> processSearchDefLst = new list<SVMXC__ServiceMax_Processes__c>();
    public List<SelectOption> SearchDefLst = new  List<SelectOption>();
    public List<SelectOption> getSearchDefLst(){return SearchDefLst;}
    public SFM_SearchWidget()
    {
        //processSearchDefLst = [SELECT Id, Name, SVMXC__Name__c, SVMXC__Source_Object_Name__c,SVMXC__Description__c ,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__IsStandard__c,SVMXC__IsDefault__C,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH'];
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        processSearchDefLst = [SELECT Id, Name, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Parent_Error_Msg__c, SVMXC__Child_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Name__c, SVMXC__Tag_Keys__c, SVMXC__Source_Object_Name__c,SVMXC__Description__c ,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__IsStandard__c,SVMXC__IsDefault__C,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH'];
        
        /* Start - Logic to translate SFM Search Definition  */
        if(processSearchDefLst != NULL && processSearchDefLst.size() > 0){
            String TranslationKeys = '';
            for(SVMXC__ServiceMax_Processes__c SearchDefn : processSearchDefLst){
                if(SearchDefn.SVMXC__Tag_Keys__c != NULL && SearchDefn.SVMXC__Tag_Keys__c.length() > 0)
                    TranslationKeys  += SearchDefn.SVMXC__Tag_Keys__c;
            }
            I18N_TranslationDelivery objTranslnUtil = new I18N_TranslationDelivery(TranslationKeys, UserInfo.getLanguage());
            processSearchDefLst = objTranslnUtil.SVMX_GetProcessTranslation(processSearchDefLst);
        }
        /* End */
        
        Id usrSVMXProfileId;
        Id usrSfProfileId = UserInfo.getProfileId();
        List<SVMXC__ServiceMax_Config_Data__c> lstGroupProfiles = new List<SVMXC__ServiceMax_Config_Data__c>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstGroupProfiles = [Select Id, SVMXC__Access_Configuration_Profile__c, RecordType.Name, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Configuration Access' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Group' 
        And SVMXC__Profile__c =: usrSFProfileId];
        
        if (lstGroupProfiles != null && lstGroupProfiles.size() > 0)
            usrSVMXProfileId = lstGroupProfiles[0].SVMXC__Access_Configuration_Profile__c;

        Map<Id, SVMXC__ServiceMax_Processes__c> mapSearchDefnRecs = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Set<Id> setSearchDefnRecId = new Set<Id>();
        mapSearchDefnRecs.putAll(processSearchDefLst);
        setSearchDefnRecId.addAll(mapSearchDefnRecs.keyset());
    
        List<SVMXC__ServiceMax_Config_Data__c> lstSearchAccessRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstSearchAccessRecs = [Select Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = 'Search Access' And SVMXC__Dispatch_Process__c In: setSearchDefnRecId];
        
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
            mapTempSearchDefnRecs.put(SearchDefnRecId, mapSearchDefnRecs.get(SearchDefnRecId));
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstSearchObjectRecs = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstRsltFldRecords = new list<SVMXC__ServiceMax_Config_Data__c>();
        map<Id,list<SVMXC__ServiceMax_Processes__c>> mapSearchDef_LstSearchObjs = new map<Id,list<SVMXC__ServiceMax_Processes__c>>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapSearchObjectRec = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id,list<SVMXC__ServiceMax_Config_Data__c>> mapSearchObjId_LstSearchObjFldRec = new map<Id,list<SVMXC__ServiceMax_Config_Data__c>>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstSearchObjectRecs = [Select SVMXC__Target_Object_Name__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Advance_Expression__c, SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_OBJECT' AND SVMXC__Module__c IN : mapTempSearchDefnRecs.keySet() ORDER BY SVMXC__Sequence__c];
        mapSearchObjectRec.putAll(lstSearchObjectRecs);
        
        for(SVMXC__ServiceMax_Processes__c SearchObj : lstSearchObjectRecs)
        {
            if(!mapSearchDef_LstSearchObjs.containsKey(SearchObj.SVMXC__Module__c))
                mapSearchDef_LstSearchObjs.put(SearchObj.SVMXC__Module__c, new list<SVMXC__ServiceMax_Processes__c>());
            mapSearchDef_LstSearchObjs.get(SearchObj.SVMXC__Module__c).add(SearchObj);
        }
        
        system.debug(LoggingLevel.WARN, 'map of Search Def Id and Searchable Object list: '+ mapSearchDef_LstSearchObjs);
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstRsltFldRecords = [Select SVMXC__Sequence__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c,  SVMXC__Field_Name__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c IN: mapSearchObjectRec.keyset() and Recordtype.Name='Expressions' AND SVMXC__Search_Object_Field_Type__c = 'Result' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' ORDER BY SVMXC__Sequence__c];
        
        for(SVMXC__ServiceMax_Config_Data__c SearchObjFldRec : lstRsltFldRecords)
        {
            list<SVMXC__ServiceMax_Config_Data__c> tempLst = new list<SVMXC__ServiceMax_Config_Data__c>();
            if(mapSearchObjId_LstSearchObjFldRec.containsKey(SearchObjFldRec.SVMXC__Expression_Rule__c) && mapSearchObjId_LstSearchObjFldRec.get(SearchObjFldRec.SVMXC__Expression_Rule__c) != null)
                tempLst.addAll(mapSearchObjId_LstSearchObjFldRec.get(SearchObjFldRec.SVMXC__Expression_Rule__c));
            tempLst.add(SearchObjFldRec);
            mapSearchObjId_LstSearchObjFldRec.put(SearchObjFldRec.SVMXC__Expression_Rule__c, tempLst);
        }
        
        system.debug(LoggingLevel.WARN, 'map of Searchable Object Id and Result Field: '+ mapSearchObjId_LstSearchObjFldRec);
        set<string> setSearchDefIds = new set<string>(); 
        for(Id tempId : mapSearchDef_LstSearchObjs.keySet())
        {
            system.debug(LoggingLevel.WARN, 'For Search def Id: '+ tempId +'; Searchable Objects are: '+  mapSearchDef_LstSearchObjs.get(tempId));
            if(mapSearchDef_LstSearchObjs.containsKey(tempId) && mapSearchDef_LstSearchObjs.get(tempId) != NULL)
            {
                for(integer i=0; i < mapSearchDef_LstSearchObjs.get(tempId).size(); i++)
                {
                    system.debug(LoggingLevel.WARN, 'For Searchable Object Id: '+ mapSearchDef_LstSearchObjs.get(tempId)[i].Id + '; Result fields are: '+  mapSearchObjId_LstSearchObjFldRec.get(mapSearchDef_LstSearchObjs.get(tempId)[i].Id));
                    
                    if(!setSearchDefIds.contains(string.valueOf(tempId)) && mapSearchObjId_LstSearchObjFldRec.containsKey(mapSearchDef_LstSearchObjs.get(tempId)[i].Id) &&  mapSearchObjId_LstSearchObjFldRec.get(mapSearchDef_LstSearchObjs.get(tempId)[i].Id) != NULL && mapSearchObjId_LstSearchObjFldRec.get(mapSearchDef_LstSearchObjs.get(tempId)[i].Id).size() > 0)
                    {
                        SearchDefLst.add(new SelectOption(string.valueOf(tempId), string.valueOf(mapTempSearchDefnRecs.get(tempId).SVMXC__Name__c)));
                        setSearchDefIds.add(string.valueOf(tempId));
                    }
                }
            }
        }
    }
    
    // Method to launch Search Delivery Screen on click of GO button.
    public PageReference launchSearchDelivery()
    {
        string searchName = null;
        if(selectedSearch != null && selectedSearch.length() > 0)
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
             searchName = [SELECT Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where Id =: selectedSearch AND Recordtype.Name = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH'].SVMXC__ProcessID__c;
        COMM_SVMXC_Utils2  objCls = new COMM_SVMXC_Utils2();
        String strUrl = objCls.GetCommunityPrefix('/apex/SVMXC__SFMSearchDelivery');
        PageReference pageRef = new PageReference(strUrl);//SVMXC__SFM_SearchUtils
        pageRef.setRedirect(true);
        if(searchName != null && searchName.length() > 0)
            pageRef.getParameters().put('SVMX_SearchName',searchName);
        pageRef.getParameters().put('SVMX_keyWord',keyWord);
        pageRef.getParameters().put('SVMX_SearchId',selectedSearch);
        
        //Load the setting for displaying the header.
        List<String> lstSubModules = new List<String>{'SFM003'};
        Map<String, Map<String, String>> AllsvmxSettingList = new Map<String, Map<String, String>>();
        AllsvmxSettingList = new SVMXC.COMM_Utils_ManageSettings().SVMX_getSettingList(lstSubModules);
        Map<String, String> svmxSettingMap = AllsvmxSettingList.get('SFM003');
        
        //Setting to run the fix for showing the header while rendering the delivery page.
        Boolean showHeader= false;            
        if(svmxSettingMap != null && svmxSettingMap.get('SET001') != NULL && svmxSettingMap.get('SET001').toUpperCase() == 'TRUE') {
            showHeader= Boolean.valueOf(svmxSettingMap.get('SET001'));
        }
        pageRef.getParameters().put('showHeader',String.valueOf(showHeader));
        
        return pageRef;
    }

}