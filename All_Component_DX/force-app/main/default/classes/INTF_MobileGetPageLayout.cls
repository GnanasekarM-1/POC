public with sharing class INTF_MobileGetPageLayout
{
    public integer response_size;
    public static set<string> batchedPageLayouts;
    public map<id, set<id>> mapHdrToRelLayouts = new map<id, set<id>>();
    public map<id, list<SVMXC__SFM_Event__c>> mapDtlEvents = new map<id, list<SVMXC__SFM_Event__c>>();
    public map<id, list<SVMXC__SFM_Event__c>> mapHdrEvents = new map<id, list<SVMXC__SFM_Event__c>>();
    public map<id, list<SVMXC__Page_Layout_Detail__c>> mapPgDtlLayouts = new map<id, list<SVMXC__Page_Layout_Detail__c>>();
    public map<id, SVMXC__Page_Layout__c> mapHdrLayouts = new map<id, SVMXC__Page_Layout__c>();
    public map<id, SVMXC__Page_Layout__c> mapRelLayouts = new map<id, SVMXC__Page_Layout__c>();
	public set<string> setPgDtls = new set<string>();
	public I18N_TranslationDelivery translationObj;
	public map<string, string> mapPgIdToTagKeys = new map<string, string>();
    
    public INTF_WebServicesDef.INTF_Response_PageUI INTF_GetPageLayout(id pageId)
    {
        SVMXC__Page_Layout__c hdrLayout = new SVMXC__Page_Layout__c(); 
        list<SVMXC__SFM_Event__c> lstHdrEvents = new list<SVMXC__SFM_Event__c>();
        
        if(mapPgIdToTagKeys != null && mapPgIdToTagKeys.size() > 0 && mapPgIdToTagKeys.containsKey(pageId))
        	translationObj = new I18N_TranslationDelivery(mapPgIdToTagKeys.get(string.valueOf(pageId)), UserInfo.getLanguage());
        
        if(mapHdrLayouts != null && mapHdrLayouts.size() > 0 && mapHdrLayouts.containsKey(pageId))
        {
            hdrLayout = mapHdrLayouts.get(pageId);
            
            if(translationObj != null)
            	hdrLayout = translationObj.SVMX_GetPageLayoutTranslation(hdrLayout);
        }
        
        if(mapHdrEvents != null && mapHdrEvents.size() > 0 && mapHdrEvents.containsKey(pageId))
            lstHdrEvents = mapHdrEvents.get(pageId);
        
        system.debug(loggingLevel.WARN, 'Header Page Layout: ' + hdrLayout);
        system.debug(loggingLevel.WARN, 'List of Header Events: ' + ' :List: ' + lstHdrEvents);
        
        if(hdrLayout == null)
            return null;
        
        INTF_WebServicesDef.INTF_Response_PageUI resPageUI = new INTF_WebServicesDef.INTF_Response_PageUI();
        INTF_WebServicesDef.INTF_PageUI  pageUI = new INTF_WebServicesDef.INTF_PageUI();
        INTF_WebServicesDef.INTF_Response resINTF = new INTF_WebServicesDef.INTF_Response();
        resINTF.MapStringMap = new list<INTF_WebServicesDef.INTF_MapStringMap>();
        list<SVMXC.INTF_WebServicesDef.INTF_UISection> sectionsUI = new list<SVMXC.INTF_WebServicesDef.INTF_UISection>();
        list<SVMXC.INTF_WebServicesDef.INTF_UIButton> buttonsUI = new list<SVMXC.INTF_WebServicesDef.INTF_UIButton>();
        map<string, List<SVMXC__Page_Layout_Detail__c>> mapSecToFlds = new map<string, List<SVMXC__Page_Layout_Detail__c>>();
        list<SVMXC__Page_Layout_Detail__c> lstSections = new list<SVMXC__Page_Layout_Detail__c>();
        
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> mapHrdFlds = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        mapHrdFlds.add(new INTF_WebServicesDef.INTF_StringMap('HideSave', string.valueOf(hdrLayout.SVMXC__Hide_Save__c)));
        mapHrdFlds.add(new INTF_WebServicesDef.INTF_StringMap('HideQuickSave', string.valueOf(hdrLayout.SVMXC__Hide_Quick_Save__c)));
        resINTF.MapStringMap.add(new INTF_WebServicesDef.INTF_MapStringMap('HeaderFields', mapHrdFlds));
        
        map<string, list<SVMXC__SFM_Event__c>> mapPDToEvents = new map<string, list<SVMXC__SFM_Event__c>>();
        
        if(mapDtlEvents != null && mapDtlEvents.containsKey(pageId))
            mapPDToEvents = getMapPageLayoutDtlToEvents(mapDtlEvents.get(pageId));
            
        if(mapPDToEvents != null)
            system.debug(loggingLevel.WARN, 'Map of Page Detail to Events Size: ' + mapPDToEvents.size() + ' :Map: ' + mapPDToEvents);
        
        List<SVMXC__Page_Layout_Detail__c> lstHdrDtlLayouts = mapPgDtlLayouts.get(pageId);
        system.debug(loggingLevel.WARN, 'lstHdrDtlLayouts: ' + lstHdrDtlLayouts);
        if(translationObj != null && lstHdrDtlLayouts != null)
        	lstHdrDtlLayouts = translationObj.SVMX_GetPageLayoutDetailTranslation(lstHdrDtlLayouts);
        
        if(lstHdrDtlLayouts != null && lstHdrDtlLayouts.size() > 0)
        {
	        for(SVMXC__Page_Layout_Detail__c PDtl: lstHdrDtlLayouts)
	        {
	            if(PDtl.SVMXC__Detail_Type__c == 'Field')
	            {
	                if(mapSecToFlds == null || mapSecToFlds.size() == 0 || !mapSecToFlds.containsKey(PDtl.SVMXC__Section__c) || mapSecToFlds.get(PDtl.SVMXC__Section__c) == null)
	                    mapSecToFlds.put(PDtl.SVMXC__Section__c, new list<SVMXC__Page_Layout_Detail__c>{PDtl});
	                else
	                    mapSecToFlds.get(PDtl.SVMXC__Section__c).add(PDtl);
	            }
	            if(PDtl.SVMXC__Detail_Type__c == 'Section')
	                lstSections.add(PDtl);
	            if(PDtl.SVMXC__Detail_Type__c == 'Button' && PDtl.SVMXC__Show_In_iPad__c)
	            {
	            	system.debug(loggingLevel.WARN, 'Button Id: ' + PDtl.Id + ' :Button Events: ' + mapPDToEvents.get(PDtl.Id));
	            	
	                SVMXC.INTF_WebServicesDef.INTF_UIButton  buttonUI = new SVMXC.INTF_WebServicesDef.INTF_UIButton(PDtl,mapPDToEvents.get(PDtl.Id));
	                buttonsUI.add(buttonUI);
	            }
	        }
        }
        system.debug(loggingLevel.WARN, 'Button UI Size: ' + buttonsUI.size() + ' :Map: ' + buttonsUI);
        
        sectionsUI = prepareSeactionUI(lstSections, mapSecToFlds, mapPDToEvents);
        system.debug(loggingLevel.WARN, 'Section UI Size: ' + sectionsUI.size() + ' :Map: ' + sectionsUI);
        
        SVMXC.INTF_WebServicesDef.INTF_PageHeader pageHeader = new SVMXC.INTF_WebServicesDef.INTF_PageHeader(hdrLayout, sectionsUI, buttonsUI, lstHdrEvents);
        pageHeader.hdrLayoutId = hdrLayout.Id;
        list<SVMXC.INTF_WebServicesDef.INTF_PageDetail> pageDetailLst = new list<SVMXC.INTF_WebServicesDef.INTF_PageDetail>();
        pageUI.header = pageHeader;
        pageUI.details = pageDetailLst;
        
        if(mapHdrToRelLayouts != null && mapHdrToRelLayouts.size() > 0 && mapHdrToRelLayouts.containsKey(pageId) && mapHdrToRelLayouts.get(pageId) != null)
        {
            set<id> setRelLayoutIds = mapHdrToRelLayouts.get(pageId);
            for(id relLayoutId : setRelLayoutIds)
            {
                SVMXC.INTF_WebServicesDef.INTF_PageDetail relPageDtl = getRelatedLayoutPageDtl(relLayoutId);
                if(relPageDtl != null)
                    pageDetailLst.add(relPageDtl);
            }
        }
        
        system.debug(loggingLevel.WARN, 'Page UI: ' + pageUI);
        
        resPageUI.page = pageUI;
        resPageUI.response = resINTF;
        return resPageUI;
    }
    
    public list<SVMXC.INTF_WebServicesDef.INTF_UISection> prepareSeactionUI(list<SVMXC__Page_Layout_Detail__c> lstSections, map<string, List<SVMXC__Page_Layout_Detail__c>> mapSecToFlds, map<string, list<SVMXC__SFM_Event__c>> mapPDToEvents)
    {
        list<SVMXC.INTF_WebServicesDef.INTF_UISection> sectionsUI = new list<SVMXC.INTF_WebServicesDef.INTF_UISection>();
        
        for(SVMXC__Page_Layout_Detail__c sectionPDtl: lstSections)
        {
            List<SVMXC.INTF_WebServicesDef.INTF_UIField> hdrFields = new List<SVMXC.INTF_WebServicesDef.INTF_UIField>();
            
            system.debug(loggingLevel.WARN, 'Section Detail Id: ' + sectionPDtl.Id + mapSecToFlds.get(sectionPDtl.Id));
            
            if(mapSecToFlds.get(sectionPDtl.Id) != null)
            {
	            for(SVMXC__Page_Layout_Detail__c fldPDtl : mapSecToFlds.get(sectionPDtl.Id))
	            {
	                SVMXC.INTF_WebServicesDef.INTF_UIField fieldUI = new SVMXC.INTF_WebServicesDef.INTF_UIField(fldPDtl, mapPDToEvents.get(fldPDtl.Id), null);
	                hdrFields.add(fieldUI);
	            }
            }
            SVMXC.INTF_WebServicesDef.INTF_UISection  SectionUI = new SVMXC.INTF_WebServicesDef.INTF_UISection(sectionPDtl, hdrFields);
            sectionsUI.add(SectionUI);
        }
        
        return sectionsUI;
    }
    
    public SVMXC.INTF_WebServicesDef.INTF_PageDetail getRelatedLayoutPageDtl(Id relLayoutId)
    {
        List<SVMXC.INTF_WebServicesDef.INTF_UIButton> relatedBtnUI = new List<SVMXC.INTF_WebServicesDef.INTF_UIButton>();
        List<SVMXC.INTF_WebServicesDef.INTF_UIField> relatedfldUI = new List<SVMXC.INTF_WebServicesDef.INTF_UIField>();
        SVMXC.INTF_WebServicesDef.INTF_PageDetail relPageDtl = new SVMXC.INTF_WebServicesDef.INTF_PageDetail();
        SVMXC__Page_Layout__c relLayout = mapRelLayouts.get(relLayoutId);
        
        if(translationObj != null)
        	relLayout = translationObj.SVMX_GetPageLayoutTranslation(relLayout);
        	
        relPageDtl.DetailLayout = relLayout;
        relPageDtl.dtlLayoutId = relLayoutId;
        relPageDtl.buttons = relatedBtnUI;
        relPageDtl.fields = relatedfldUI;
        
        system.debug(loggingLevel.WARN, 'Related Layout Header Events: ' + mapHdrEvents + ' :: ' + mapHdrEvents.containsKey(relLayoutId));
        
        if(mapHdrEvents != null && mapHdrEvents.containsKey(relLayoutId))
            relPageDtl.events = mapHdrEvents.get(relLayoutId);
        
        system.debug(loggingLevel.WARN, 'Related Layout Header Events Added: ' + relPageDtl.events + ' :: ' + relPageDtl.events.size());
        
        map<string, list<SVMXC__SFM_Event__c>> mapPDToEvents = new map<string, list<SVMXC__SFM_Event__c>>();
        
        if(mapDtlEvents != null && mapDtlEvents.size() > 0 && mapDtlEvents.containsKey(relLayoutId))
            mapPDToEvents = getMapPageLayoutDtlToEvents(mapDtlEvents.get(relLayoutId));
        
        system.debug(loggingLevel.WARN, 'Related Layout Detail Id: ' + relLayoutId + ' :: ' + mapPgDtlLayouts.get(relLayoutId));
        
        if(mapPgDtlLayouts.get(relLayoutId) != null)
        {
        	List<SVMXC__Page_Layout_Detail__c> lstRelatedDtlLayouts = mapPgDtlLayouts.get(relLayoutId);
        	if(translationObj != null)
        		lstRelatedDtlLayouts = translationObj.SVMX_GetPageLayoutDetailTranslation(lstRelatedDtlLayouts);
	        
	        for(SVMXC__Page_Layout_Detail__c PDtl: lstRelatedDtlLayouts)
	        {
	            if(PDtl.SVMXC__Detail_Type__c == 'Field')
	            {
	                SVMXC.INTF_WebServicesDef.INTF_UIField fieldUI = new SVMXC.INTF_WebServicesDef.INTF_UIField();
	                fieldUI.fieldDetail = PDtl;
	                if(mapPDToEvents != null && mapPDToEvents.size() > 0 && mapPDToEvents.containsKey(PDtl.Id))
	                fieldUI.fieldEvents = mapPDToEvents.get(PDtl.Id);
	                relatedfldUI.add(fieldUI);
	            }
	            else if(PDtl.SVMXC__Detail_Type__c == 'Button' && PDtl.SVMXC__Show_In_iPad__c)
	            {
	            	system.debug(loggingLevel.WARN, 'Related Button Id: ' + PDtl.Id + ' :Related Button Events: ' + mapPDToEvents.get(PDtl.Id));
	            	
	                SVMXC.INTF_WebServicesDef.INTF_UIButton buttonUI = new SVMXC.INTF_WebServicesDef.INTF_UIButton(PDtl, mapPDToEvents.get(PDtl.Id));
	                relatedBtnUI.add(buttonUI);
	            }
	        }
        }
        
        return relPageDtl;
    }
    
    public list<INTF_WebServicesDef.INTF_Response_PageUI> INTF_GetPageLayout(set<string> lstPageIds, string syncReqId)
    {
        if(lstPageIds == null || lstPageIds.size() == 0)
            return null;
        
        list<INTF_WebServicesDef.INTF_Response_PageUI> lstPageUI = new list<INTF_WebServicesDef.INTF_Response_PageUI>();
        /*INTF_TxnCache.restore(syncReqId);
        mapHdrLayouts = (map<id, SVMXC__Page_Layout__c>)INTF_TxnCache.get('MAP_PAGELAYOUT', 'map<id, SVMXC__Page_Layout__c>');
        mapPgDtlLayouts = (map<id, list<SVMXC__Page_Layout_Detail__c>>)INTF_TxnCache.get('MAP_PAGELAYOUT_DETAIL', 'map<id, list<SVMXC__Page_Layout_Detail__c>>');
        mapHdrEvents = (map<id, list<SVMXC__SFM_Event__c>>)INTF_TxnCache.get('MAP_PAGELAYOUT_EVENT', 'map<id, list<SVMXC__SFM_Event__c>>');
        mapDtlEvents = (map<id, list<SVMXC__SFM_Event__c>>)INTF_TxnCache.get('MAP_PAGELAYOUT_DETAIL_EVENT', 'map<id, list<SVMXC__SFM_Event__c>>');
        mapHdrToRelLayouts = (map<id, set<id>>)INTF_TxnCache.get('MAP_PAGELAYOUT_RELATED_LAYOUT', 'map<id, set<id>>');*/
        
        response_size = 0;
        
        
        if(mapHdrLayouts == null || mapHdrLayouts.size() == 0)
        {
            mapHdrLayouts = new map<id, SVMXC__Page_Layout__c>();
            mapHdrLayouts.putAll([select SVMXC__Enable_Service_Report_View__c, SVMXC__Enable_Service_Report_Generation__c, SVMXC__Enable_Troubleshooting__c, SVMXC__Type__c,SVMXC__Sequence__c,SVMXC__Prompt_For_New_Event__c,SVMXC__Enable_Attachments__c,SVMXC__Enable_Chatter__c,SVMXC__Show_Account_History__c,SVMXC__Show_All_Sections_By_Default__c,SVMXC__Show_Product_History__c, SVMXC__Hide_Save__c,SVMXC__Hide_Quick_Save__c,SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c, SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, Name, Id From SVMXC__Page_Layout__c where id IN: lstPageIds OR Name IN: lstPageIds OR SVMXC__Page_Layout_ID__c IN: lstPageIds]);
            
            system.debug(loggingLevel.WARN, 'Map of Header Layout Size: ' + mapHdrLayouts.size() + ' :Map: ' + mapHdrLayouts);
            
            set<id> setHrdLayoutIds = new set<id>();
            setHrdLayoutIds.addAll(mapHdrLayouts.keyset());
            
            mapRelLayouts = new map<id, SVMXC__Page_Layout__c>();
            mapRelLayouts.putAll([Select SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c,  SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, Name, Id From SVMXC__Page_Layout__c  where SVMXC__Header_Page_Layout__c IN: mapHdrLayouts.keyset() and SVMXC__Type__c = 'Detail']);
            
            mapHdrToRelLayouts = new map<id, set<id>>();
            
            if(mapRelLayouts != null && mapRelLayouts.size() > 0)
            {
                system.debug(loggingLevel.WARN, 'Map of Related Page Layout Size: ' + mapRelLayouts.size() + ' :Map: ' + mapRelLayouts);
                setHrdLayoutIds.addAll(mapRelLayouts.keyset());
                
                for(id relLayout : mapRelLayouts.keyset())
                {
                    Id layoutId = mapRelLayouts.get(relLayout).SVMXC__Header_Page_Layout__c;
                    if(mapHdrToRelLayouts.size() == 0 || !mapHdrToRelLayouts.containsKey(layoutId) || mapHdrToRelLayouts.get(layoutId) == null)
                        mapHdrToRelLayouts.put(layoutId, new set<id>{relLayout});
                    else
                        mapHdrToRelLayouts.get(layoutId).add(relLayout);
                }
            }
            
            mapHdrEvents = getMapPageLayoutToEvents(setHrdLayoutIds);
            
            if(mapHdrEvents != null)
                system.debug(loggingLevel.WARN, 'Map of Header Events Size: ' + mapHdrEvents.size() + ' :Map: ' + mapHdrEvents);
            
            mapPgDtlLayouts = getMapPageLayoutToPageLayoutDetails(setHrdLayoutIds);
            
            system.debug(loggingLevel.WARN, 'set of Header Page Details Size: ' + setPgDtls.size() + ' :List: ' + setPgDtls);
            
            if(mapPgDtlLayouts != null)
            {
                system.debug(loggingLevel.WARN, 'Map of Header Page Details Size: ' + mapPgDtlLayouts.size() + ' :Map: ' + mapPgDtlLayouts);
                
                for(Id strId: mapPgDtlLayouts.keyset()){
                	setPgDtls.add(string.valueOf(strId));
                }
            }
            
            mapDtlEvents = getMapPageLayoutToEventsFromPageLayoutDtls(setPgDtls);
            
            if(mapDtlEvents != null)
                system.debug(loggingLevel.WARN, 'Map of Header Page Detail Events Size: ' + mapDtlEvents.size() + ' :Map: ' + mapDtlEvents);
        }
        
        if(mapHdrLayouts != null && mapHdrLayouts.size() > 0)
        {
            if(mapPgIdToTagKeys == null || mapPgIdToTagKeys.size() == 0)
            	mapPgIdToTagKeys = new map<string, string>();
            for(SVMXC__ServiceMax_Processes__c pro : [Select SVMXC__Tag_Keys__c,SVMXC__Page_Layout__c From SVMXC__ServiceMax_Processes__c where SVMXC__Page_Layout__c IN: mapHdrLayouts.keyset() AND SVMXC__Page_Layout__c != NULL])
				mapPgIdToTagKeys.put(pro.SVMXC__Page_Layout__c, pro.SVMXC__Tag_Keys__c);
				
            for(ID pageId : mapHdrLayouts.keyset())
            {
                if(checkLimit(70))
                    break;
                
                INTF_WebServicesDef.INTF_Response_PageUI pgUI = INTF_GetPageLayout(pageId);
                if(pgUI != null)
                    lstPageUI.add(pgUI);
                
                if(mapHdrLayouts != null && mapHdrLayouts.containsKey(pageId))
                    mapHdrLayouts.remove(pageId);
                if(mapPgDtlLayouts != null && mapPgDtlLayouts.containsKey(pageId))
                    mapPgDtlLayouts.remove(pageId);
                if(mapHdrEvents != null && mapHdrEvents.containsKey(pageId))
                    mapHdrEvents.remove(pageId);
                if(mapDtlEvents != null && mapDtlEvents.containsKey(pageId))
                    mapDtlEvents.remove(pageId);
                if(mapPgIdToTagKeys != null && mapPgIdToTagKeys.containsKey(pageId))
                	mapPgIdToTagKeys.remove(pageId);
                
                if(mapHdrToRelLayouts != null && mapHdrToRelLayouts.containsKey(pageId))
                {
                    set<Id> setRelLayout = mapHdrToRelLayouts.get(pageId);
                    if(setRelLayout!= null && setRelLayout.size() > 0)
                    {
                        for(Id idToRemove : setRelLayout)
                        {
                            if(mapRelLayouts != null && mapRelLayouts.containsKey(idToRemove))
                                mapRelLayouts.remove(idToRemove);
                            if(mapPgDtlLayouts != null && mapPgDtlLayouts.containsKey(idToRemove))
                                mapPgDtlLayouts.remove(idToRemove);
                            if(mapHdrEvents != null && mapHdrEvents.containsKey(idToRemove))
                                mapHdrEvents.remove(idToRemove);
                            if(mapDtlEvents != null && mapDtlEvents.containsKey(idToRemove))
                                mapDtlEvents.remove(idToRemove);
                        }
                    }
                    mapHdrToRelLayouts.remove(pageId);
                }
            }
        }
        
        if(mapHdrLayouts != null && mapHdrLayouts.size() > 0)
        {
            /*INTF_TxnCache.put('MAP_PAGELAYOUT', mapHdrLayouts, 'map<id, SVMXC__Page_Layout__c>');
            INTF_TxnCache.put('MAP_PAGELAYOUT_DETAIL', mapPgDtlLayouts, 'map<id, list<SVMXC__Page_Layout_Detail__c>>');
            INTF_TxnCache.put('MAP_PAGELAYOUT_EVENT', mapHdrEvents, 'map<id, list<SVMXC__SFM_Event__c>>');
            INTF_TxnCache.put('MAP_PAGELAYOUT_DETAIL_EVENT', mapDtlEvents, 'map<id, list<SVMXC__SFM_Event__c>>');
            INTF_TxnCache.put('MAP_PAGELAYOUT_RELATED_LAYOUT', mapHdrToRelLayouts, 'map<id, set<id>>');
            INTF_TxnCache.save(syncReqId);*/
            
            INTF_MobileGetPageLayout.batchedPageLayouts = new set<string>();
            for(id remianingPageId : mapHdrLayouts.keyset())
                INTF_MobileGetPageLayout.batchedPageLayouts.add(string.valueOf(remianingPageId));
        }
        
        return lstPageUI;
    }
    
    public map<id, list<SVMXC__SFM_Event__c>> getMapPageLayoutToEvents(set<id> setLayoutIds)
    {
        if(setLayoutIds == null || setLayoutIds.size() == 0)
            return null;
            
        map<id, list<SVMXC__SFM_Event__c>> mapHdrEvents = new map<id, list<SVMXC__SFM_Event__c>>();
        
        for(SVMXC__SFM_Event__c hdrEvent : [Select SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, Name, Id From SVMXC__SFM_Event__c  where SVMXC__Page_Layout__c IN: setLayoutIds OR SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c IN: setLayoutIds])
        {
            if(hdrEvent.SVMXC__Target_Call__c != NULL && hdrEvent.SVMXC__Target_Call__c.contains('__'))
                hdrEvent.SVMXC__Target_Call__c = hdrEvent.SVMXC__Target_Call__c.replace('__', '/');
            
            if(mapHdrEvents.size() == 0 || !mapHdrEvents.containsKey(hdrEvent.SVMXC__Page_Layout__c) || mapHdrEvents.get(hdrEvent.SVMXC__Page_Layout__c) == null)
                mapHdrEvents.put(hdrEvent.SVMXC__Page_Layout__c, new list<SVMXC__SFM_Event__c>{hdrEvent});
            else
                mapHdrEvents.get(hdrEvent.SVMXC__Page_Layout__c).add(hdrEvent);
        }
        
        return mapHdrEvents;
    }
    
    public map<string, list<SVMXC__SFM_Event__c>> getMapPageLayoutDtlToEvents(list<SVMXC__SFM_Event__c> lstDtlEvents)
    {
        map<string, list<SVMXC__SFM_Event__c>> mapPDToEvents = new map<string, list<SVMXC__SFM_Event__c>>();
        
        for(SVMXC__SFM_Event__c dtlEvent: lstDtlEvents)
        {
            if(mapPDToEvents.size() == 0 || !mapPDToEvents.containsKey(dtlEvent.SVMXC__Page_Layout_Detail__c) || mapPDToEvents.get(dtlEvent.SVMXC__Page_Layout_Detail__c) == null)
                mapPDToEvents.put(dtlEvent.SVMXC__Page_Layout_Detail__c, new list<SVMXC__SFM_Event__c>{dtlEvent});
            else
                mapPDToEvents.get(dtlEvent.SVMXC__Page_Layout_Detail__c).add(dtlEvent);
        }
        
        return mapPDToEvents;
    }
    
    public map<id, list<SVMXC__SFM_Event__c>> getMapPageLayoutToEventsFromPageLayoutDtls(set<string> setDtlLayoutIds)
    {
    	system.debug(loggingLevel.WARN, 'Page Detail Event: ' + setDtlLayoutIds.size() + ' :Page Layout: ' + setDtlLayoutIds);
    	
        if(setDtlLayoutIds == null || setDtlLayoutIds.size() == 0)
            return null;
            
        map<id, list<SVMXC__SFM_Event__c>> mapDtlEvents = new map<id, list<SVMXC__SFM_Event__c>>();
    
        for(SVMXC__SFM_Event__c dtlEvent : [Select SVMXC__Page_Layout_Detail__r.SVMXC__Page_Layout__c, SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, Name, Id From SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : setDtlLayoutIds OR SVMXC__Page_Layout__c IN: setDtlLayoutIds])
        {
        	system.debug(loggingLevel.WARN, 'Page Detail Event: ' + dtlEvent.Id + ' :Page Layout: ' + dtlEvent.SVMXC__Page_Layout__c);
        	
            if(dtlEvent.SVMXC__Target_Call__c != NULL && dtlEvent.SVMXC__Target_Call__c.contains('__'))
                dtlEvent.SVMXC__Target_Call__c = dtlEvent.SVMXC__Target_Call__c.replace('__', '/');
            
            if(dtlEvent.SVMXC__Page_Layout__c != null)
            {
            	if(mapDtlEvents.size() == 0 || !mapDtlEvents.containsKey(dtlEvent.SVMXC__Page_Layout__c) || mapDtlEvents.get(dtlEvent.SVMXC__Page_Layout__c) == null)
            		mapDtlEvents.put(dtlEvent.SVMXC__Page_Layout__c, new list<SVMXC__SFM_Event__c>{dtlEvent});
            	else
            		mapDtlEvents.get(dtlEvent.SVMXC__Page_Layout__c).add(dtlEvent);
            }
            
            if(dtlEvent.SVMXC__Page_Layout_Detail__r.SVMXC__Page_Layout__c != null)
            {
	            if(mapDtlEvents.size() == 0 || !mapDtlEvents.containsKey(dtlEvent.SVMXC__Page_Layout_Detail__r.SVMXC__Page_Layout__c) || mapDtlEvents.get(dtlEvent.SVMXC__Page_Layout_Detail__r.SVMXC__Page_Layout__c) == null)
	                mapDtlEvents.put(dtlEvent.SVMXC__Page_Layout_Detail__r.SVMXC__Page_Layout__c, new list<SVMXC__SFM_Event__c>{dtlEvent});
	            else
	                mapDtlEvents.get(dtlEvent.SVMXC__Page_Layout_Detail__r.SVMXC__Page_Layout__c).add(dtlEvent);
            }
        }
        
        return mapDtlEvents;
    }
    
    public map<id, list<SVMXC__Page_Layout_Detail__c>> getMapPageLayoutToPageLayoutDetails(set<id> setPageLayoutIds)
    {
        if(setPageLayoutIds == null || setPageLayoutIds.size() == 0)
            return null;
            
        setPgDtls = new set<string>();
        map<id, list<SVMXC__Page_Layout_Detail__c>> mapPgDtlLayouts = new map<id, list<SVMXC__Page_Layout_Detail__c>>();
    
        for(SVMXC__Page_Layout_Detail__c pgDtl : [Select SVMXC__Show_In_iPad__c, SVMXC__Show_In_Web__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c,SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c,   SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id,SVMXC__No_of_columns__c, SVMXC__Use_For_SLA_Clock__c, SVMXC__Field_Mapping__c, SVMXC__Context_Source_Object__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN: setPageLayoutIds])
        {
            setPgDtls.add(pgDtl.Id);
            
            if(mapPgDtlLayouts.size() == 0 || !mapPgDtlLayouts.containsKey(pgDtl.SVMXC__Page_Layout__c) || mapPgDtlLayouts.get(pgDtl.SVMXC__Page_Layout__c) == null)
                mapPgDtlLayouts.put(pgDtl.SVMXC__Page_Layout__c, new list<SVMXC__Page_Layout_Detail__c>{pgDtl});
            else
                mapPgDtlLayouts.get(pgDtl.SVMXC__Page_Layout__c).add(pgDtl);
        }
        
        return mapPgDtlLayouts;
    }
    
    public boolean checkLimit(integer percent)
    {
        integer limit_Heap = percent * Limits.getLimitHeapSize()/100;
        integer limit_Queries = percent * Limits.getLimitQueries()/100;
        integer limit_QueryRows = percent * Limits.getLimitQueryRows()/100;
        integer limit_CPUTime = percent * Limits.getLimitCpuTime()/100;
        
        if(Limits.getHeapSize() >= limit_Heap || Limits.getQueries() >= limit_Queries || Limits.getQueryRows() >= limit_QueryRows || Limits.getCpuTime() >= limit_CPUTime || response_size > 3000000)
            return true;
        return false;
    }
}