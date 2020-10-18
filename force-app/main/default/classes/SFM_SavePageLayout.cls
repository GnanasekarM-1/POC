/* Security Scanned */
public with sharing class SFM_SavePageLayout 
{
    SVMXC.SFM_WrapperDef pmaxwrapp = new SVMXC.SFM_WrapperDef();
    public map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>(); 
    public map<String,Schema.SObjectType> Allobj = new map<String,Schema.SObjectType>();  
    public SFM_SavePageLayout()
    {
        gd = Schema.getGlobalDescribe();
        if(gd.size() > 0)
        {
            for(String s : gd.keyset())
            {
                Allobj.put(gd.get(s).getDescribe().getName(),gd.get(s));
            }
        }
    }
    
    public SFM_WrapperDef.SFM_Response SFM_savePageLayout(SFM_WrapperDef.SFM_Request_PageUI PmaxReqPageUI)
    {
        system.debug('PmaxReqPageUI: '+ PmaxReqPageUI);
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        savepoint sp;
        try
        {
            sp = Database.setSavepoint();
            List<SFM_WrapperDef.SFM_StringMap> StringMap = new List<SFM_WrapperDef.SFM_StringMap>();
            if(PmaxReqPageUI != null && PmaxReqPageUI.request != null && PmaxReqPageUI.request.stringMap != null && PmaxReqPageUI.request.stringMap.size() > 0)  
                StringMap = PmaxReqPageUI.request.stringMap;
            system.debug('StringMap'+StringMap);
            String ProcessId = '';
            String ProcessType = '';
            String pageId = '';
            String SaveType = '';
            String headerObject = '';
            if(StringMap.size() > 0)
            {
                for(Integer i = 0;i<StringMap.size();i++)
                {
                    if(StringMap[i].key.touppercase()=='SAVETYPE')
                    {
                        SaveType = StringMap[i].value.touppercase();
                    }
                }
            }
            system.debug('SaveType'+SaveType);
            List<SVMXC__SFM_Event__c> SaveAllHdrEvents = new List<SVMXC__SFM_Event__c>();
            //Member variable of SFM_PageUI
            SVMXC.SFM_WrapperDef.SFM_PageUI PageUI = new SVMXC.SFM_WrapperDef.SFM_PageUI();
            SVMXC__ServiceMax_Processes__c ProcessNode = new SVMXC__ServiceMax_Processes__c();
            //get the SFM_PageUI
            if(PmaxReqPageUI.ProcessId != null)             
                ProcessId = PmaxReqPageUI.ProcessId;
            
            
             if(PmaxReqPageUI.ProcessType != null)              
                ProcessType = PmaxReqPageUI.ProcessType;
            
            
            if(PmaxReqPageUI.page != null)
                PageUI = PmaxReqPageUI.page;
            ProcessNode = PmaxReqPageUI.processNode; //process node needs to be inserted(pending)
            SVMXC.SFM_WrapperDef.SFM_PageHeader PageHeader = new SVMXC.SFM_WrapperDef.SFM_PageHeader();
            if(PageUI.header != null)
                PageHeader = PageUI.header;//PageHeader Member
            system.debug('PageHeader'+PageHeader);    
            List<SVMXC.SFM_WrapperDef.SFM_PageDetail> PageDetails = new List<SVMXC.SFM_WrapperDef.SFM_PageDetail>();
            if(PageUI.details != null)
                PageDetails = PageUI.details;
            system.debug('PageDetails'+PageDetails.size()+PageDetails); 
            //Header is only one so process PageHeader and get the member
            //Member variable of the SFM_PageHeader
            SVMXC__Page_Layout__c WrapperheaderLayout = new SVMXC__Page_Layout__c();
            SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
            List<SVMXC.SFM_WrapperDef.SFM_UISection> UISectionLst = new List<SVMXC.SFM_WrapperDef.SFM_UISection>();
            List<SVMXC.SFM_WrapperDef.SFM_UIButton> UIButtonLst = new List<SVMXC.SFM_WrapperDef.SFM_UIButton>();
            List<SVMXC__SFM_Event__c> pageEvents = new List<SVMXC__SFM_Event__c>();
            if(PageHeader.headerLayout != null)
                WrapperheaderLayout = PageHeader.headerLayout; 
            system.debug('WrapperheaderLayout'+WrapperheaderLayout);       
            if(PageHeader.sections != null)
                UISectionLst = PageHeader.sections;
            if(PageHeader.buttons != null)
                UIButtonLst =  PageHeader.buttons;
            if(PageHeader.pageEvents != null)
                PageEvents = PageHeader.pageEvents;
            //insert the Header page Layout..
            String HeaderId = '';
            if(WrapperheaderLayout != null)
            {   
                
                headerObject = WrapperheaderLayout.SVMXC__Object_Name__c;
                WrapperheaderLayout.SVMXC__Type__c = 'Header';
                if(WrapperheaderLayout.SVMXC__Help_URL__c == null || WrapperheaderLayout.SVMXC__Help_URL__c.length() == 0)
                    WrapperheaderLayout.SVMXC__Help_URL__c = System.label.SFM002_HLPURL; 
                if(SaveType == 'SAVEAS')
                {
                    HeaderLayout = WrapperheaderLayout.clone(false,true);
                    HeaderLayout.SVMXC__IsStandard__c = false;
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    List<SVMXC__Page_Layout__c> Pagelist = [select id,SVMXC__Page_Layout_ID__c,SVMXC__Type__c from SVMXC__Page_Layout__c where SVMXC__Type__c = 'Header'];
                    if(Pagelist.size() > 0 )
                    {
                        for(SVMXC__Page_Layout__c p: Pagelist)
                        {
                            if(p.SVMXC__Page_Layout_ID__c == HeaderLayout.SVMXC__Page_Layout_ID__c)
                            {
                                response.success = false;
                                response.message = system.label.SFM001_TAG094;
                                return response;
                            }
                        }
                    }
                     //HeaderLayout.SVMXC__Page_Layout_ID__c = HeaderLayout.SVMXC__Page_Layout_ID__c+ ' ' +system.now();
                    //HeaderLayout.SVMXC__Name__c = HeaderLayout.SVMXC__Name__c + ' '+system.now();
                }
                if(SaveType == 'SAVE')
                {
                    //Its Edit mode
                    if(WrapperheaderLayout.id != null)
                    {
                        system.debug('Entered in save');
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        List<SVMXC__Page_Layout__c> Pagelist = [select id,SVMXC__Page_Layout_ID__c,SVMXC__Type__c from SVMXC__Page_Layout__c where SVMXC__Type__c = 'Header' and id !=: WrapperheaderLayout.id];
                        if(Pagelist.size() > 0 )
                        {
                            for(SVMXC__Page_Layout__c p: Pagelist)
                            {
                                if(p.SVMXC__Page_Layout_ID__c == WrapperheaderLayout.SVMXC__Page_Layout_ID__c)
                                {
                                    system.debug('check is happend for edit');
                                    response.success = false;
                                    response.message = system.label.SFM001_TAG094;
                                    return response;
                                }
                            }
                        }
                    }
                    //Its new mode..
                    else
                    {
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        List<SVMXC__Page_Layout__c> Pagelist = [select id,SVMXC__Page_Layout_ID__c,SVMXC__Type__c from SVMXC__Page_Layout__c where SVMXC__Type__c = 'Header'];
                        if(Pagelist.size() > 0 )
                        {
                            for(SVMXC__Page_Layout__c p: Pagelist)
                            {
                                if(p.SVMXC__Page_Layout_ID__c == WrapperheaderLayout.SVMXC__Page_Layout_ID__c)
                                {
                                    system.debug('check is happend for new');
                                    response.success = false;
                                    response.message = system.label.SFM001_TAG094;
                                    return response;
                                }
                            }
                        }
                    }   
                    HeaderLayout = WrapperheaderLayout; 
                }
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                upsert HeaderLayout;
                if(HeaderLayout.id != null)
                    HeaderId = HeaderLayout.id; 
            }
            system.debug('HeaderId'+HeaderId);
            if(HeaderId != null && HeaderId.length() > 0)
            {
                SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
                List<String> valueList = new List<String>();
                valueList.add(HeaderId);
                String key = 'RECORDID';
                SFM_WrapperDef.SFM_StringListMap stringListMap = new SFM_WrapperDef.SFM_StringListMap(key,valueList);
                List<SFM_WrapperDef.SFM_StringListMap> lst = new List<SFM_WrapperDef.SFM_StringListMap> ();
                lst.add(stringListMap);
                SFM_WrapperDef.SFM_StringListMap stringListMap1 = new SFM_WrapperDef.SFM_StringListMap('PARTIALDELETE',null);
                lst.add(stringListMap1);
                request.stringListMap = lst;
                SFM_DeletePageLayout DeleteLayout = new  SFM_DeletePageLayout();
                system.debug('request'+request);
                DeleteLayout.SFM_DeletePageLayout(request);
            }
            //get all the page events in the master list of events...
            if(PageEvents.size() > 0)
            {
                for(SVMXC__SFM_Event__c PE: PageEvents)
                {
                    PE.SVMXC__Page_Layout__c = HeaderLayout.id;
                    SaveAllHdrEvents.add(PE); 
                }
            }
            
            //Break the UISectionLst to PAMX_UISection Class and get the members of the class
            Map<Integer,List<SVMXC.SFM_WrapperDef.SFM_UIField>> UIfieldMap = new Map<Integer,List<SVMXC.SFM_WrapperDef.SFM_UIField>>();
            Map<Integer,SVMXC__Page_Layout_Detail__c> SectionMap = new Map<Integer,SVMXC__Page_Layout_Detail__c>();
            
            /** Create page sections for Header page layout **/
            if(UISectionLst != null && UISectionLst.size() > 0)
                createPageLayoutSections(String.valueOf(HeaderLayout.id), UISectionLst, SectionMap, UIfieldMap);
            
            //make a map of section's id and List<SFM_UIField> wrapper class
            Map<Integer,String> SectionIDMap = new Map<Integer,String>();//for SectionId/Number map
            Map<Integer,String> mapSectionID = new Map<Integer,String>();//for SectionId/Number map
            for(Integer i : UIfieldMap.keyset())
            {
                if(SectionMap.containskey(i) && SectionMap.get(i) != null)
                    SectionIDMap.put(i, SectionMap.get(i).id);
            }
            System.debug(LoggingLevel.Warn, 'UISectionLst: ' + UISectionLst);
            System.debug(LoggingLevel.Warn, 'SectionIDMap: ' + SectionIDMap);
            System.debug(LoggingLevel.Warn, 'PROCESSType: ' + PROCESSType);
            if(ProcessType != null && ProcessType!=''&& ProcessType.toUpperCase() == 'CHECKLIST')
            {
                //Aptest SFM_MapStringMap
                SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request ();
                List<SVMXC.SFM_WrapperDef.SFM_MapStringMap> lstMapStrMap = new List<SVMXC.SFM_WrapperDef.SFM_MapStringMap>();
                
                
                //For Checklist process this contains exit criteria ids which has to be deleted
                
                
                System.debug(LoggingLevel.Warn, 'PROCESSType: ' + PROCESSType);
                
                //------------------------------------Entry Criteria -------------------------------//
                for(integer i=0;i<UISectionLst.size();i++)
                {
                    
                    System.debug(LoggingLevel.Warn, 'UISectionLst[i].entryCriteriaId: ' + UISectionLst[i].entryCriteriaId);
                    System.debug(LoggingLevel.Warn, 'PROCESSID: ' + PROCESSID);
                    System.debug(LoggingLevel.Warn, 'SectionMap.get(i): ' + SectionMap.get(i).id);
                    System.debug(LoggingLevel.Warn, 'UISectionLst[i].EnableEntryCriteria: ' + UISectionLst[i].EnableEntryCriteria);
                    if(UISectionLst[i].entryCriteriaId != null && UISectionLst[i].entryCriteriaId != '' && PROCESSID != null && PROCESSID != '' && SectionMap.containskey(i) && SectionMap.get(i) != null && SectionMap.get(i).id != null)
                    {
                        SVMXC.SFM_WrapperDef.SFM_MapStringMap MapStrMap = new SVMXC.SFM_WrapperDef.SFM_MapStringMap();
                        MapStrMap.key = 'ENTRY CRITERIA';
                            
                        SVMXC.SFM_WrapperDef.SFM_StringMap processmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();               
                        processmap.key = 'PROCESSID';
                        processmap.value = PROCESSID;
                        
                        SVMXC.SFM_WrapperDef.SFM_StringMap sectionIdValmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();              
                        sectionIdValmap.key = 'SECTIONID';
                        sectionIdValmap.value = SectionMap.get(i).id;
                        
                        SVMXC.SFM_WrapperDef.SFM_StringMap EntryCriteriamap = new SVMXC.SFM_WrapperDef.SFM_StringMap();             
                        EntryCriteriamap.key = 'EntryCriteriaID';
                        EntryCriteriamap.value = UISectionLst[i].entryCriteriaId;
                        
                        SVMXC.SFM_WrapperDef.SFM_StringMap EnableEntryCriteriamap = new SVMXC.SFM_WrapperDef.SFM_StringMap();               
                        EnableEntryCriteriamap.key = 'EnableEntryCriteria';
                        if(UISectionLst[i].EnableEntryCriteria != null && UISectionLst[i].EnableEntryCriteria != '')
                            EnableEntryCriteriamap.value = UISectionLst[i].EnableEntryCriteria;
                        else
                            EnableEntryCriteriamap.value = 'false';
                        MapStrMap.valuemap.add(processmap);
                        MapStrMap.valuemap.add(EntryCriteriamap);
                        MapStrMap.valuemap.add(EnableEntryCriteriamap);
                        MapStrMap.valuemap.add(sectionIdValmap);
                        request.lstMapStringMap.add(MapStrMap);
                    }
                    SFM_SaveSectionEntryCriteria(request);
                    
                    //-------------------------------Entry Criteria End-------------------------------//
                    //-------------------------------Exit Criteria Start -----------------------------//
                    // Populating corresponding section Id in place of Sequence(which is sent from the client)
                    System.debug(LoggingLevel.Warn, 'UISectionLst[i].lstSectionExitCriteria: ' + UISectionLst[i].lstSectionExitCriteria);
                    if(UISectionLst[i] != null && UISectionLst[i].lstSectionExitCriteria != null )
                    {
                        for(SVMXC.SFM_WrapperDef.SFM_Exit_Criteria objSection:UISectionLst[i].lstSectionExitCriteria)
                        {
                             System.debug(LoggingLevel.Warn, 'objSection: ' + objSection);
                             System.debug(LoggingLevel.Warn, 'objSection.checklistId: ' + objSection.checklistId);
                             
                             System.debug(LoggingLevel.Warn, 'objSection.TargetSectionId: ' + objSection.TargetSectionId  +'  '+SectionMap.get((Integer.valueOf(String.escapeSingleQuotes(objSection.TargetSectionId)) )-1).id);
                             
            
                             System.debug(LoggingLevel.Warn, 'objSection.SourceSectionId: ' + objSection.SourceSectionId+'  '+SectionMap.get((Integer.valueOf(String.escapeSingleQuotes(objSection.SourceSectionId))) -1).id);
                             
                            
                            if(objSection.TargetSectionId != NULL && SectionMap.containskey(((Integer.valueOf(String.escapeSingleQuotes(objSection.TargetSectionId)) )-1)) && SectionMap.get((Integer.valueOf(String.escapeSingleQuotes(objSection.TargetSectionId)) )-1) != null)
                                objSection.TargetSectionId = SectionMap.get((Integer.valueOf(String.escapeSingleQuotes(objSection.TargetSectionId)) )-1).id;
                            
                            if(objSection.SourceSectionId != NULL && SectionMap.containskey(Integer.valueOf(String.escapeSingleQuotes(objSection.SourceSectionId))-1) && SectionMap.get(Integer.valueOf(String.escapeSingleQuotes(objSection.SourceSectionId))-1) != null)
                                objSection.SourceSectionId = SectionMap.get(Integer.valueOf(String.escapeSingleQuotes(objSection.SourceSectionId))-1).id;
                            
                        }
                    }
                }
                
                // Calling method to save Exit criteria
                SFM_SaveSectionExitCriteria(PmaxReqPageUI);
            }
            //---------------------Exit Criteria End-------------------------------//
            //aptest ---------------------------------------------//
            // Break the SFM_UIField wrapper calss..
            Map<String,List<SVMXC__SFM_Event__c>> HdrEventMap = new Map<String,List<SVMXC__SFM_Event__c>>(); 
            if(UIfieldMap.size() > 0)
            {
                for(Integer i : UIfieldMap.keyset())
                {
                    Map<Integer,SVMXC__Page_Layout_Detail__c> HdrFldmap = new Map<Integer,SVMXC__Page_Layout_Detail__c>();
                    List<SVMXC.SFM_WrapperDef.SFM_UIField> TempUIFieldLst = new List<SVMXC.SFM_WrapperDef.SFM_UIField>();
                    String SectionId = '';
                    if(UIfieldMap.containskey(i) && UIfieldMap.get(i) != null)
                        TempUIFieldLst = UIfieldMap.get(i);
                    if(SectionIDMap.containskey(i) && SectionIDMap.get(i) != null)
                        SectionId = SectionIDMap.get(i);
                    if(TempUIFieldLst.size() > 0)
                    {
                        for(Integer j = 0;j<TempUIFieldLst.size();j++)
                        {
                            SVMXC__Page_Layout_Detail__c Tempfld = new SVMXC__Page_Layout_Detail__c();
                            system.debug('fieldDetail'+TempUIFieldLst[j].fieldDetail);
                            if(TempUIFieldLst[j].fieldDetail != null)
                            {
                                Tempfld = TempUIFieldLst[j].fieldDetail;
                                if(SectionId != null && SectionId.length() > 0)
                                    Tempfld.SVMXC__Section__c = SectionId;
                                //Tempfld.SVMXC__Detail_Type__c = 'Field';
                                Tempfld.SVMXC__Page_Layout__c = HeaderLayout.id;
                                if(Tempfld.SVMXC__Related_Object_Name__c != null && (Tempfld.SVMXC__Related_Object_Name__c == 'Group,User' || Tempfld.SVMXC__Related_Object_Name__c == 'User,Group'))
                                    Tempfld.SVMXC__Related_Object_Name__c = 'User';
                                HdrFldmap.put(j,Tempfld);
                            }
                        }   
                        system.debug('HdrFldmap'+HdrFldmap + Allobj);
                        List<SVMXC__Page_Layout_Detail__c> HdrSaveFldLst = new List<SVMXC__Page_Layout_Detail__c>();
                        if(HdrFldmap.size() > 0)
                        {
                            HdrSaveFldLst = HdrFldmap.values();
                            if(HdrSaveFldLst.size() > 0)
                            {
                                for(Integer a = 0;a<HdrSaveFldLst.size();a++)
                                {
                                    // Bala 10-6-11: Added HdrSaveFldLst[a].SVMXC__DataType__c != null and 
                                    if(HdrSaveFldLst[a].SVMXC__Related_Object_Name__c != null && HdrSaveFldLst[a].SVMXC__DataType__c != null && HdrSaveFldLst[a].SVMXC__DataType__c.touppercase() == 'REFERENCE' && Allobj.containskey(HdrSaveFldLst[a].SVMXC__Related_Object_Name__c))
                                    {
                                        if(Allobj.get(HdrSaveFldLst[a].SVMXC__Related_Object_Name__c) == Account.SObjectType)
                                            HdrSaveFldLst[a].SVMXC__Related_Object_Name_Field__c = 'Name';
                                        else
                                        {
                                            Map<String, Schema.SObjectField> fieldmap =  Allobj.get(HdrSaveFldLst[a].SVMXC__Related_Object_Name__c).getDescribe().fields.getmap();
                                            if(fieldmap.size() > 0)
                                            {
                                                for(String s: fieldmap.keyset())
                                                {
                                                    if(fieldmap.get(s).getdescribe().isNameField())
                                                    {
                                                        HdrSaveFldLst[a].SVMXC__Related_Object_Name_Field__c = fieldmap.get(s).getdescribe().getName();
                                                        break;
                                                    }   
                                                }
                                            }  
                                        }                                           
                                    }
                                }
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                insert HdrSaveFldLst; //insert Fields
                            }
                            system.debug('HdrSaveFldLst'+HdrSaveFldLst);
                        }
                        for(Integer k = 0;k<TempUIFieldLst.size();k++)
                        {
                            if(TempUIFieldLst[k].fieldEvents != null)
                                HdrEventMap.put(HdrSaveFldLst[k].id,TempUIFieldLst[k].fieldEvents);
                        }   
                    }   
                }
            }
            for(String j : HdrEventMap.keyset())
            {
                List<SVMXC__SFM_Event__c> TempEvent = new List<SVMXC__SFM_Event__c>();
                if(HdrEventMap.containskey(j) && HdrEventMap.get(j) != null)
                    TempEvent = HdrEventMap.get(j);
                if(TempEvent.size() > 0)
                {
                    for(SVMXC__SFM_Event__c PE: TempEvent)
                    {
                        PE.SVMXC__Page_Layout_Detail__c = j;
                        SaveAllHdrEvents.add(PE);
                    }
                }
            }
            system.debug('SaveAllHdrEvents'+SaveAllHdrEvents);
            //Break the UIButtonLst
            Map<Integer,SVMXC__Page_Layout_Detail__c> HdrButtonMap = new Map<Integer,SVMXC__Page_Layout_Detail__c>();
            Map<Integer,List<SVMXC__SFM_Event__c>> HdrBtnEventMap = new Map<Integer,List<SVMXC__SFM_Event__c>>();
            if(UIButtonLst.size() > 0)
            {
                
                for(integer i = 0;i<UIButtonLst.size();i++)
                {
                    SVMXC__Page_Layout_Detail__c TempBtn = new SVMXC__Page_Layout_Detail__c();
                    if(UIButtonLst[i].buttonDetail != null)
                    {
                        TempBtn = UIButtonLst[i].buttonDetail;
                        TempBtn.SVMXC__Detail_Type__c = 'Button';
                        TempBtn.SVMXC__Page_Layout__c =  HeaderLayout.id;
                        HdrButtonMap.put(i,TempBtn);
                        if(UIButtonLst[i].buttonEvents != null)
                            HdrBtnEventMap.put(i,UIButtonLst[i].buttonEvents);
                    }   
                }
            }   
            List<SVMXC__Page_Layout_Detail__c> SaveHdrBtns = new List<SVMXC__Page_Layout_Detail__c>();
            if(HdrButtonMap.size() > 0)
            {
                SaveHdrBtns = HdrButtonMap.values();
                if(SaveHdrBtns.size() > 0)
                {
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    insert SaveHdrBtns;
                }
            }
            if(HdrButtonMap.size() > 0 && HdrBtnEventMap.size() > 0)
            {
                for(Integer i : HdrButtonMap.keyset())
                {
                    for(Integer j : HdrBtnEventMap.keyset())
                    {
                        if(i == j)
                        {
                            List<SVMXC__SFM_Event__c> TempEvent = new List<SVMXC__SFM_Event__c>();
                            if(HdrBtnEventMap.containskey(j) && HdrBtnEventMap.get(j) != null)
                                TempEvent = HdrBtnEventMap.get(j);
                            if(TempEvent.size() > 0)
                            {
                                for(SVMXC__SFM_Event__c PE: TempEvent)
                                {
                                    PE.SVMXC__Page_Layout_Detail__c = SaveHdrBtns[i].id;
                                    SaveAllHdrEvents.add(PE);
                                }
                            }
                        }
                    }
                }
            }
            if(SaveAllHdrEvents.size() > 0)
            {
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SaveAllHdrEvents, COMM_SecurityUtils.Access.Createable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            insert SaveAllHdrEvents;//insert All header Events
            } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            //insert All Header Events...
            }
           //Strat Processing the Page Details....
            List<SVMXC__Page_Layout__c> WrapperAllDetailLayouts = new List<SVMXC__Page_Layout__c>();
            List<SVMXC__Page_Layout__c> AllDetailLayouts = new List<SVMXC__Page_Layout__c>();
            List<SVMXC__SFM_Event__c> SaveAllDetailEvents = new List<SVMXC__SFM_Event__c>();
            Map<Integer,List<SVMXC.SFM_WrapperDef.SFM_UIField>> DetailUIFieldsMap = new Map<Integer,List<SVMXC.SFM_WrapperDef.SFM_UIField>>();
            Map<Integer,List<SVMXC.SFM_WrapperDef.SFM_UIButton>> DetailUIBtnsMap = new Map<Integer,List<SVMXC.SFM_WrapperDef.SFM_UIButton>>();
            map<Integer,list<SVMXC__SFM_Event__c>> mapDetailLayouEvent = new map<Integer,list<SVMXC__SFM_Event__c>>();
            if(PageDetails .size() > 0)
            {
                map<String,String> childObjAPINameRFldAPIName = new map<String,String>();
                //Get the Child objects of parent object and then Referenece field to parent object
                if(headerObject != null && headerObject.length() > 0 && Allobj.containskey(headerObject))
                {
                    list<schema.Childrelationship> ChildObj = new List<schema.Childrelationship>();
                    ChildObj = Allobj.get(headerObject).getDescribe().getChildRelationships();
                    if(ChildObj.size() > 0)
                    {
                        for(Schema.ChildRelationship CR :ChildObj)
                        {
                            if(CR.isCascadeDelete())
                            {
                                String objAPIName = String.valueof(CR.getChildSObject());
                                String fldAPIName = String.valueof(CR.getField());
                                childObjAPINameRFldAPIName.put(objAPIName,fldAPIName);
                            }
                        }
                    }
                }
                system.debug('childObjAPINameRFldAPIName: '+childObjAPINameRFldAPIName);                
                for(Integer i =0;i<PageDetails.size();i++)
                {
                    SVMXC__Page_Layout__c templayout = new SVMXC__Page_Layout__c();
                    List<SVMXC.SFM_WrapperDef.SFM_UIField> TempUIFld  = new List<SVMXC.SFM_WrapperDef.SFM_UIField>();
                    List<SVMXC.SFM_WrapperDef.SFM_UIButton> TempUIBtn  = new List<SVMXC.SFM_WrapperDef.SFM_UIButton>();
                    if(PageDetails[i].DetailLayout != null)
                    {
                        templayout = PageDetails[i].DetailLayout;
                        if(childObjAPINameRFldAPIName.containskey(templayout.SVMXC__Object_Name__c))
                            templayout.SVMXC__Header_Reference_Field__c = childObjAPINameRFldAPIName.get(templayout.SVMXC__Object_Name__c);
                        templayout.SVMXC__Header_Page_Layout__c = HeaderLayout.id;
                        templayout.SVMXC__Type__c = 'Detail';
                        templayout.SVMXC__Page_Detail_UniqueId__c = null; //to maintain seed uniqnees we will not use this field while creating new detail object record.
                        //get the header Refercen field.
                        WrapperAllDetailLayouts.add(templayout);
                    }
                    if(PageDetails[i].fields != null)
                    {   
                        TempUIFld = PageDetails[i].fields;
                        DetailUIFieldsMap.put(i,TempUIFld);
                    }
                    if(PageDetails[i].buttons != null)
                    {   
                        TempUIBtn = PageDetails[i].buttons;
                        DetailUIBtnsMap.put(i,TempUIBtn);
                    }
                    if(PageDetails[i].events != null && PageDetails[i].events.size() > 0){
                        mapDetailLayouEvent.put(i,PageDetails[i].events);
                    }   
                }
            }
            system.debug('WrapperAllDetailLayouts'+WrapperAllDetailLayouts.size()+WrapperAllDetailLayouts);
            system.debug('DetailUIFieldsMap'+DetailUIFieldsMap.size()+DetailUIFieldsMap);
            system.debug('DetailUIBtnsMap'+DetailUIBtnsMap.size()+DetailUIBtnsMap);
            if(WrapperAllDetailLayouts.size() > 0)
            {
                if(SaveType == 'SAVEAS')
                {
                    system.debug('Entered in Saveas');
                    for(Integer i = 0;i<WrapperAllDetailLayouts.size();i++)
                    {
                        WrapperAllDetailLayouts[i].SVMXC__IsStandard__c = false;
                        AllDetailLayouts.add(WrapperAllDetailLayouts[i].clone(false,true));
                    }   
                }
                if(SaveType == 'SAVE')
                {
                    system.debug('Entered in Save');
                    AllDetailLayouts.addall(WrapperAllDetailLayouts); 
                }
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                upsert AllDetailLayouts;
            }
            system.debug('AllDetailLayouts'+AllDetailLayouts.size()+AllDetailLayouts);
            Map<Integer,SVMXC__Page_Layout_Detail__c> DetailFldmap = new Map<Integer,SVMXC__Page_Layout_Detail__c>();
            Map<String,List<SVMXC__SFM_Event__c>> DetailEventMap = new Map<String,List<SVMXC__SFM_Event__c>>();
            if(DetailUIFieldsMap.size()>0) 
            {
                for(Integer i : DetailUIFieldsMap.keyset())
                {
                    system.debug('bla'+i+' '+AllDetailLayouts[i].id);
                    String DetailID = AllDetailLayouts[i].id;
                    system.debug('DetailID'+DetailID);
                    List<SVMXC.SFM_WrapperDef.SFM_UIField> TempUIFld  = new List<SVMXC.SFM_WrapperDef.SFM_UIField>();
                    if(DetailUIFieldsMap.containskey(i) && DetailUIFieldsMap.get(i) != null)
                        TempUIFld = DetailUIFieldsMap.get(i);
                    system.debug('TempUIFld'+TempUIFld);    
                    DetailFldmap = new Map<Integer,SVMXC__Page_Layout_Detail__c>();
                    if(TempUIFld.size() > 0)
                    {
                       for(Integer k =0;k<TempUIFld.size();k++)
                       {
                            SVMXC__Page_Layout_Detail__c Tempfld = new SVMXC__Page_Layout_Detail__c();
                            if(TempUIFld[k].fieldDetail != null)
                            {
                                Tempfld = TempUIFld[k].fieldDetail;
                                Tempfld.SVMXC__Page_Layout__c = DetailID;
                                Tempfld.SVMXC__Detail_Type__c = 'Field';
                                if(Tempfld.SVMXC__Related_Object_Name__c != null && (Tempfld.SVMXC__Related_Object_Name__c == 'Group,User' || Tempfld.SVMXC__Related_Object_Name__c == 'User,Group'))
                                    Tempfld.SVMXC__Related_Object_Name__c = 'User';
                                DetailFldmap.put(k,Tempfld);
                                
                            }    
                        }
                    }
                    system.debug('DetailFldmap'+DetailFldmap.size()+DetailFldmap);   
                    List<SVMXC__Page_Layout_Detail__c> DetailSaveFldLst = new List<SVMXC__Page_Layout_Detail__c>();
                    if(DetailFldmap.size() > 0)
                    {
                        DetailSaveFldLst = DetailFldmap.values();
                        if(DetailSaveFldLst.size() > 0)
                        {
                            for(Integer a = 0;a<DetailSaveFldLst.size();a++)
                            {
                                if(DetailSaveFldLst[a].SVMXC__Related_Object_Name__c != null && DetailSaveFldLst[a].SVMXC__DataType__c.touppercase() == 'REFERENCE' && Allobj.containskey(DetailSaveFldLst[a].SVMXC__Related_Object_Name__c))
                                {
                                    if(Allobj.get(DetailSaveFldLst[a].SVMXC__Related_Object_Name__c) == Account.SObjectType)
                                        DetailSaveFldLst[a].SVMXC__Related_Object_Name_Field__c = 'Name';
                                    else
                                    {
                                        Map<String, Schema.SObjectField> fieldmap =  Allobj.get(DetailSaveFldLst[a].SVMXC__Related_Object_Name__c).getDescribe().fields.getmap();
                                        if(fieldmap.size() > 0)
                                        {
                                            for(String s: fieldmap.keyset())
                                            {
                                                if(fieldmap.get(s).getdescribe().isNameField())
                                                {
                                                    DetailSaveFldLst[a].SVMXC__Related_Object_Name_Field__c = fieldmap.get(s).getdescribe().getName();
                                                    break;
                                                }   
                                            }
                                        }    
                                    }                                   
                                }
                            }
                            system.debug('DetailSaveFldLst'+DetailSaveFldLst);
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            insert DetailSaveFldLst;//insert the Detail fields 
                        }
                    }
                    for(Integer j =0;j<TempUIFld.size();j++)
                    {
                        if(TempUIFld[j].fieldEvents != null)
                            DetailEventMap.put(DetailSaveFldLst[j].id,TempUIFld[j].fieldEvents);
                    }       
                }
            }           
            if(DetailEventMap.size() > 0)
            {
                for(String i : DetailEventMap.keyset())
                {
                    List<SVMXC__SFM_Event__c> TempEvent = new List<SVMXC__SFM_Event__c>();
                    if(DetailEventMap.containskey(i) && DetailEventMap.get(i) != null)
                        TempEvent = DetailEventMap.get(i);
                    if(TempEvent.size() > 0)
                    {
                        for(SVMXC__SFM_Event__c PE: TempEvent)
                        {
                            PE.SVMXC__Page_Layout_Detail__c = i;
                            SaveAllDetailEvents.add(PE);
                        }
                    }
                }
            }
            Map<Integer,SVMXC__Page_Layout_Detail__c> DetailButtonMap = new Map<Integer,SVMXC__Page_Layout_Detail__c>();
            Map<String,List<SVMXC__SFM_Event__c>> DetailBtnEventMap = new Map<String,List<SVMXC__SFM_Event__c>>();
            if(DetailUIBtnsMap.size() > 0)
            {
                for(Integer i : DetailUIBtnsMap.keyset())
                {
                    String DetailID = AllDetailLayouts[i].id;
                    List<SVMXC.SFM_WrapperDef.SFM_UIButton> TempUIBtn  = new List<SVMXC.SFM_WrapperDef.SFM_UIButton>();
                    if(DetailUIBtnsMap.containskey(i) && DetailUIBtnsMap.get(i) != null)
                        TempUIBtn = DetailUIBtnsMap.get(i);
                    if(TempUIBtn.size() > 0)
                    {
                        for(Integer j = 0;j<TempUIBtn.size();j++)
                        {
                            SVMXC__Page_Layout_Detail__c TempBtn = new SVMXC__Page_Layout_Detail__c();
                            if(TempUIBtn[j].buttonDetail != null)
                            {
                                TempBtn = TempUIBtn[j].buttonDetail;
                                TempBtn.SVMXC__Page_Layout__c = DetailID;
                                TempBtn.SVMXC__Detail_Type__c = 'Button';
                                DetailButtonMap.put(j,TempBtn);
                            }
                        }
                        List<SVMXC__Page_Layout_Detail__c> SaveDetailBtns = new List<SVMXC__Page_Layout_Detail__c>();
                        if(DetailButtonMap.size() > 0)
                        {
                            SaveDetailBtns = DetailButtonMap.values();
                            if(SaveDetailBtns.size() > 0)
                            {
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                insert SaveDetailBtns;//insert the Buttons  for Datail layout
                            }
                        }
                        for(Integer k = 0;k<TempUIBtn.size();k++)
                        {
                            if(TempUIBtn[k].buttonEvents != null)
                                DetailBtnEventMap.put(SaveDetailBtns[k].id,TempUIBtn[k].buttonEvents);
                        }       
                    }
                }
            }           
            if(DetailBtnEventMap.size() > 0)
            {
                for(String i: DetailBtnEventMap.keyset())
                {
                    List<SVMXC__SFM_Event__c> TempEvent = new List<SVMXC__SFM_Event__c>();
                    if(DetailBtnEventMap.containskey(i) && DetailBtnEventMap.get(i) != null)
                        TempEvent = DetailBtnEventMap.get(i);
                    if(TempEvent.size() > 0)
                    {
                        for(SVMXC__SFM_Event__c PE: TempEvent)
                        {
                            PE.SVMXC__Page_Layout_Detail__c = i;
                            SaveAllDetailEvents.add(PE);
                        }
                    }
                }
            }
            for(Integer i : mapDetailLayouEvent.keyset()){
                list<SVMXC__SFM_Event__c> lstEvent = new list<SVMXC__SFM_Event__c>();
                lstEvent = mapDetailLayouEvent.get(i);
                if(lstEvent.size() > 0){
                    for(SVMXC__SFM_Event__c evt : lstEvent){
                        evt.SVMXC__Page_Layout__c = AllDetailLayouts[i].id;
                        SaveAllDetailEvents.add(evt);
                    }
                }
            }
            if(SaveAllDetailEvents.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SaveAllDetailEvents, COMM_SecurityUtils.Access.Createable ) ) {
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    insert SaveAllDetailEvents;
                } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
            }
            response.success = true;
            //response.message = 'Saved Successfully';
            //response.message = system.Label.SFM001_TAG184;
            List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMapList = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
            if(HeaderLayout.id != null)
            {
                SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                strmap.key = 'HEADER';
                strmap.value = string.valueof(HeaderLayout.id);
                if(strmap != null)
                    stringMapList.add(strmap);
            }
            if(AllDetailLayouts.size() > 0)
            {
                for(SVMXC__Page_Layout__c PL:AllDetailLayouts)
                {
                    SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                    if(PL.SVMXC__Page_Layout_ID__c != null)
                        strmap.key = PL.SVMXC__Page_Layout_ID__c;
                    if(PL.id != null)   
                        strmap.value = PL.id;
                    if(strmap != null)  
                        stringMapList.add(strmap);
                }
            }
            if(stringMapList.size() > 0)
                response.stringMap = stringMapList; 
        }
        catch(Exception ex)
        {
            System.debug(logginglevel.warn,'Exception: '+ex);
            System.debug(logginglevel.warn,'StackTrace: '+ex.getStackTraceString());
            Database.rollback(sp);
            response.success = false;
            //response.message = 'Record Not Saved' + ex.getmessage() ;
            //response.message = system.Label.SFM001_TAG185 + ex.getmessage() ;
        }   
        return response;
    }
    
    /** Method to create Header Sections **/
    private void createPageLayoutSections(String HeaderLayoutId, List<SVMXC.SFM_WrapperDef.SFM_UISection> UISectionLst,
        Map<Integer, SVMXC__Page_Layout_Detail__c> SectionMap, Map<Integer, List<SVMXC.SFM_WrapperDef.SFM_UIField>> UIfieldMap){
            
        if(UISectionLst.size() > 0){
            for(Integer i = 0; i < UISectionLst.size(); i++){
                if(UISectionLst[i].sectionDetail != null)
                    SectionMap.put(i, UISectionLst[i].sectionDetail);
                
                if(UISectionLst[i].fields != null)
                    UIfieldMap.put(i, UISectionLst[i].fields);
            }
        }
        System.debug(LoggingLevel.Warn, 'Sections: ' + SectionMap);
        System.debug(LoggingLevel.Warn, 'Fields: ' + UIfieldMap);
        
        if(SectionMap.size() > 0){
            for(Integer i : SectionMap.keySet()){
                if(SectionMap.containskey(i) && SectionMap.get(i) != null){
                    SectionMap.get(i).SVMXC__Page_Layout__c = HeaderLayoutId;
                    SectionMap.get(i).SVMXC__Detail_Type__c = 'Section';
                }
            }
        }
        System.debug(LoggingLevel.Warn, 'Updated sections list: ' + SectionMap);
        if(SectionMap.size() > 0)
            insert SectionMap.values();
    }

   /*
    * This method save Entry Criteria for section
    * @param SVMXC.SFM_WrapperDef.SFM_Request request
    * @return VMXDEV.SFM_WrapperDef.SFM_Response_PageUI(Sucess/failure)
    */
    
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_SaveSectionEntryCriteria(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        System.debug(LoggingLevel.INFO, 'request String ' + request);
        
        SVMXC.SFM_WrapperDef.SFM_Response bizRuleResp = new SVMXC.SFM_WrapperDef.SFM_Response();
       
        List<String> lstSectionId = new List<String>();
       
        String ProcessBizRuleId;
        String SFMProcessId ='';
        String sectionId ='';
        String entryCriteriaId ='';
        boolean enableEntryCriteria= false;
        savepoint sp;
         /* commented for defect 044891/BAC-4485
        for(RecordType RType : Database.query('Select Id, Name From RecordType Where (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'Process Business Rule\')'))
        {
           
            if(RType.Name == 'Process Business Rule')
                ProcessBizRuleId = RType.id;
        }*/
        //Added for defect 044891/BAC-4485
        ProcessBizRuleId = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Processes__c', 'Process_Business_Rule');
        //End for defect 044891/BAC-4485
        //SVMXC.SFM_WrapperDef.SFM_Response SFMResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        list<SVMXC__ServiceMax_Processes__c> lstProcessBizRule = new list<SVMXC__ServiceMax_Processes__c>();
        
        try
        {
            
            sp = Database.setSavepoint();
            if(request != null && request.lstMapStringMap != null)
            {
                for(SVMXC.SFM_WrapperDef.SFM_MapStringMap MapStrMap : request.lstMapStringMap)
                {
                    
                    system.debug('Inside 1st loop ');
                    for(SVMXC.SFM_WrapperDef.SFM_StringMap stringMap : MapStrMap.valuemap)
                    {
                        
                        system.debug('Inside 2nd loop ');
                        if(stringMap.key != null && stringMap.key.toUpperCase() == 'PROCESSID' && stringMap.value != null)
                        {
                            SFMProcessId = stringMap.value;
                        }
                        if(stringMap.key != null && stringMap.key.toUpperCase() == 'SECTIONID' && stringMap.value != null)
                        {
                            sectionId = stringMap.value;
                            lstSectionId.add(stringMap.value);
                        }
                        if(stringMap.key != null && stringMap.key.toUpperCase() == 'EntryCriteriaID' && stringMap.value != null)
                        {
                            entryCriteriaId = stringMap.value;
                        }
                        
                        if(stringMap.key != null && stringMap.key.toUpperCase() == 'EnableEntryCriteria' && stringMap.value != null)
                        {
                            enableEntryCriteria = boolean.valueOf(stringMap.value);
                        }
                    }
                        
                        SVMXC__ServiceMax_Processes__c ProcessBizRule = new SVMXC__ServiceMax_Processes__c();
                        if(SFMProcessId != null && SFMProcessId != '' &&  entryCriteriaId != null && entryCriteriaId != '' &&  sectionId != null && sectionId != '')
                        {
                            system.debug('ProcessBizRule: '+ProcessBizRule);
                            ProcessBizRule.RecordTypeId = ProcessBizRuleId;
                            ProcessBizRule.SVMXC__Rule_Type__c = 'Checklist_Section_Entry_Criteria';
                            ProcessBizRule.SVMXC__Process1__c = SFMProcessId;
                           
                            ProcessBizRule.SVMXC__Process3__c = entryCriteriaId;
                            ProcessBizRule.SVMXC__SM_Section__c = sectionId;              
                            ProcessBizRule.SVMXC__Active__c = enableEntryCriteria;  
                            lstProcessBizRule.add(ProcessBizRule);                          
                        }
                    
                }
            }
            System.debug(LoggingLevel.INFO, 'lstProcessBizRule ' + lstProcessBizRule.size()+'  '+lstProcessBizRule);
            if(SFMProcessId != null && SFMProcessId !='')
            {
                list<SVMXC__ServiceMax_Processes__c> lstDleteProcessBizRule = new list<SVMXC__ServiceMax_Processes__c>();
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstDleteProcessBizRule = [Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Process1__c = :SFMProcessId AND Recordtype.Name = 'Process Business Rule' AND SVMXC__Rule_Type__c = 'Checklist_Section_Entry_Criteria'];
                
                if(lstDleteProcessBizRule != null && lstDleteProcessBizRule.size()>0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    delete lstDleteProcessBizRule;
                System.debug(LoggingLevel.INFO, 'lstDleteProcessBizRule ' + lstDleteProcessBizRule.size()+'  '+lstDleteProcessBizRule);
            }
            System.debug(LoggingLevel.INFO, 'lstProcessBizRule ' + lstProcessBizRule.size()+'  '+lstProcessBizRule);
            if(lstProcessBizRule != null && lstProcessBizRule.size()>0)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                insert lstProcessBizRule;
                        System.debug(LoggingLevel.INFO, 'lstProcessBizRule ' + lstProcessBizRule.size()+'  '+lstProcessBizRule);
            bizRuleResp.success = true;
            bizRuleResp.message = System.Label.COMM001_TAG058;//Record(s) saved successfully
        }
        
        catch (Exception ex)
        {
            Database.rollback(sp);
            bizRuleResp.success = false;
            bizRuleResp.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFM_SaveSectionEntryCriteria method Stack Trace: ' + ex.getStackTraceString());
            System.debug(LoggingLevel.WARN, 'Exception in SFM_SaveSectionEntryCriteria method : ' + ex.getMessage());
        }
        return bizRuleResp;
    }
     /*
    * This method save Title,Description and Help URL for section
    * @param SFM_WrapperDef.SFM_Request_PageUI
    * @return VMXDEV.SFM_WrapperDef.SFM_Response_PageUI(Sucess/failure)
    */
    
    public SVMXC.SFM_WrapperDef.SFM_Response_PageUI SFM_SaveSectionInfo(SFM_WrapperDef.SFM_Request_PageUI request)
    {

        SVMXC__Page_Layout_Detail__c objSection = new SVMXC__Page_Layout_Detail__c();
        list<SVMXC__Page_Layout_Detail__c> lstSection = new list<SVMXC__Page_Layout_Detail__c>();
        list<SVMXC.SFM_WrapperDef.SFM_UISection>  SectionUI = new list<SVMXC.SFM_WrapperDef.SFM_UISection>();
        list<SVMXC.SFM_WrapperDef.SFM_UISection>  RespSectionUI = new list<SVMXC.SFM_WrapperDef.SFM_UISection>();
        SVMXC.SFM_WrapperDef.SFM_Response_PageUI  PageResponseUI = new SVMXC.SFM_WrapperDef.SFM_Response_PageUI();
        SVMXC.SFM_WrapperDef.SFM_Response SFMResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        savepoint sp;
        try
        {
            System.debug('request: '+request);
            sp = Database.setSavepoint();
            if(request != null &&  request.page != null && request.page.header != null && request.page.header.sections != null)
                SectionUI = request.page.header.sections;
            for(SVMXC.SFM_WrapperDef.SFM_UISection obj:SectionUI)
            {
                System.debug('obj: '+obj);
                if (obj.sectionDetail != null )
                
                    objSection = obj.sectionDetail;
                    objSection.SVMXC__Detail_Type__c ='Section';
                
                if (objSection != null )
                    lstSection.add(objSection);
            }
            System.debug('lstSection: '+lstSection);
            if (lstSection != null && lstSection.size()>0)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                upsert lstSection;
            for(SVMXC__Page_Layout_Detail__c obj:lstSection)
            {
                SVMXC.SFM_WrapperDef.SFM_UISection  objSectionUI = new SVMXC.SFM_WrapperDef.SFM_UISection();
                objSectionUI.sectionDetail = obj;   
                RespSectionUI.add(objSectionUI);                
            }
            
            PageResponseUI.page.header.sections = RespSectionUI ;
            SFMResponse.success = true;
            SFMResponse.message = System.Label.COMM001_TAG058;//Record(s) saved successfully
           
            
        }
        catch(DMLException ex)
        {
            Database.rollback(sp);
            SFMResponse.success = false;
            SFMResponse.message = String.valueOf(ex.getDmlType(0));
            
            System.debug(LoggingLevel.WARN, 'DMLException in SFM_SaveQuestionInfo method : ' + ex.getDmlMessage(0));            
        }
        catch (Exception ex)
        {
            Database.rollback(sp);
            SFMResponse.success = false;
            SFMResponse.message = ex.getMessage();
            
            System.debug(LoggingLevel.WARN, 'Exception in SFM_SaveQuestionInfo method Stack Trace: ' + ex.getStackTraceString());
            System.debug(LoggingLevel.WARN, 'Exception in SFM_SaveQuestionInfo method : ' + ex.getMessage());
            
        }
        PageResponseUI.response = SFMResponse;
        return PageResponseUI;
    }
    
     /*
    * This method save Exit criteria for section
    * @param SFM_WrapperDef.SFM_Request_PageUI
    * @return SVMXC.SFM_WrapperDef.SFM_Response(Sucess/failure)
    */
     public SVMXC.SFM_WrapperDef.SFM_Response SFM_SaveSectionExitCriteria(SFM_WrapperDef.SFM_Request_PageUI SectionExitCriteriaRequest)
    {
        System.debug(LoggingLevel.Warn, 'SFM_SaveSectionExitCriteria called: ' );
        System.debug(LoggingLevel.WARN, 'Request: ' + SectionExitCriteriaRequest);
                
        list<String> lstsourceSectionId = new list<String> ();
        list<String> lstExitCriteriaId = new list<String> ();
        
        list<String> lstsectionExitCriteriaid = new list<String>();
       
        String ExpressionRTypeId = '';
        String ProcessBizRuleId = '';
        String bizRuleRecId = '';
        String respMassage = '';
        String SectionExitCriteriaid = '';
        Boolean respSuccess = true;
        Savepoint sp;
        
        SVMXC__ServiceMax_Processes__c SectionExitCriteria = new SVMXC__ServiceMax_Processes__c();
      
        list<SVMXC__ServiceMax_Processes__c> lstProcessBizRule = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Processes__c> lstSectionExitCriteria = new list<SVMXC__ServiceMax_Processes__c>();
        
       
        List<SVMXC__ServiceMax_Config_Data__c> SectionExitCriteriaRuleExpr = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC.SFM_WrapperDef.SFM_Response SectionExitCriteriaRuleResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        
         List<SVMXC.SFM_WrapperDef.SFM_UISection> UISectionLst = new List<SVMXC.SFM_WrapperDef.SFM_UISection>();
         
         //Getting section details
         if(SectionExitCriteriaRequest != null && SectionExitCriteriaRequest.page!= null && SectionExitCriteriaRequest.page.header != null && SectionExitCriteriaRequest.page.header.sections != null)
            UISectionLst = SectionExitCriteriaRequest.page.header.sections;
        try
        {
            sp = Database.setSavepoint();
            //Record Types
            /* Commented for defect 044891/BAC-4485
            for(RecordType RType : Database.query('Select Id, Name From RecordType Where (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'Business Rule\') OR (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'Process Business Rule\')OR (SobjectType = \'SVMXC__ServiceMax_Config_Data__c\' AND Name = \'Expressions\')'))
            {
                if(RType.Name == 'Expressions')
                    ExpressionRTypeId = RType.id; 
                else if(RType.Name == 'Process Business Rule')
                    ProcessBizRuleId = RType.id;
                else if(RType.Name == 'Business Rule')
                    bizRuleRecId = RType.id;
            }*/
           //Added for defect 044891/BAC-4485
            List<String> lstRecordTypeName =  new List<String>();
            lstRecordTypeName.add('Process_Business_Rule');
            lstRecordTypeName.add('Business_Rule');
            Map<String,Id> mapRecordTypeNameId = new Map<String,Id>();
            mapRecordTypeNameId = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Processes__c',lstRecordTypeName);
            if(mapRecordTypeNameId.size() > 0){
               if(mapRecordTypeNameId.get('Process_Business_Rule') != null)
                    ProcessBizRuleId = mapRecordTypeNameId.get('Process_Business_Rule');
                if(mapRecordTypeNameId.get('Business_Rule') != null)
                    bizRuleRecId = mapRecordTypeNameId.get('Business_Rule');
            }
            ExpressionRTypeId = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Expressions');
            //End for defect 044891/BAC-4485
            SVMXC.SFM_WrapperDef.SFM_Response objValidationResp = new SVMXC.SFM_WrapperDef.SFM_Response();
            
            
            // Looping through each section to get corresponding Exit criteria
            for(integer i =0;i<UISectionLst.size();i++)
            {
                if(UISectionLst[i].lstSectionExitCriteria != null && UISectionLst[i].lstSectionExitCriteria.size()>0)
                {
                    for(SVMXC.SFM_WrapperDef.SFM_Exit_Criteria objSection:UISectionLst[i].lstSectionExitCriteria)
                    {                       
                        System.debug(logginglevel.warn,'objValidationResp: '+objValidationResp.success);
                       
                        //Exit criteria Biz Rule                           
                        if(objSection.SectionExitCriteria != NULL && objSection.SectionExitCriteria.id != NULL)
                            SectionExitCriteriaid = String.escapeSingleQuotes(objSection.SectionExitCriteria.id);
                        
                         System.debug(LoggingLevel.WARN, 'SectionExitCriteriaid : ' + SectionExitCriteriaid);
                         
                         lstExitCriteriaId.add(SectionExitCriteriaid);
                        
                        
                           
                        SectionExitCriteria = objSection.SectionExitCriteria;
                        SectionExitCriteria.RecordTypeId = bizRuleRecId;
                        if(objSection.questionBankId != NULL)
                            SectionExitCriteria.SVMXC__Question_Bank__c = objSection.questionBankId;
                        
                        SectionExitCriteria.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
                        lstSectionExitCriteria.add(SectionExitCriteria);
                         
                        
                    }
                            
                }
            }
            System.debug(logginglevel.warn,'lstSectionExitCriteria before upsert: '+lstSectionExitCriteria);
            //upserting Exit criteria biz rules
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            upsert lstSectionExitCriteria;
            
            System.debug(logginglevel.warn,'lstSectionExitCriteria After upsert: '+lstSectionExitCriteria);
            
            integer index = 0;
            
            //Looping through all the section to get expressions and Source and Target section details to create Process Biz rule (Junction object)
            for(integer i =0;i<UISectionLst.size();i++)
            {
                if(UISectionLst[i].lstSectionExitCriteria != null && UISectionLst[i].lstSectionExitCriteria.size()>0)
                {
                    for(SVMXC.SFM_WrapperDef.SFM_Exit_Criteria objSection:UISectionLst[i].lstSectionExitCriteria)
                    {
                        //Config Data
                        for(SVMXC__ServiceMax_Config_Data__c expressDetail : objSection.lstSectionExitCriteriaDetails)
                        {
                            expressDetail.RecordTypeId = ExpressionRTypeId;
                            expressDetail.SVMXC__Expression_Type__c = 'Business_Rule';
                            
                            if(objSection.questionId  != NULL )
                            expressDetail.SVMXC__Field_Name__c = String.escapeSingleQuotes(objSection.questionId);
                            
                            expressDetail.SVMXC__Expression_Rule__c = lstSectionExitCriteria.get(index).Id;
                            if(expressDetail.SVMXC__Parameter_Type__c != NULL && expressDetail.SVMXC__Parameter_Type__c.length() > 0)
                                expressDetail.SVMXC__Parameter_Type__c = String.valueOf(expressDetail.SVMXC__Parameter_Type__c).toUpperCase();
                           // else
                            //    expressDetail.SVMXC__Parameter_Type__c = 'Value';
                            
                            if(expressDetail.SVMXC__Display_Type__c != NULL && expressDetail.SVMXC__Display_Type__c.length() > 0)
                                expressDetail.SVMXC__Display_Type__c = String.valueOf(expressDetail.SVMXC__Display_Type__c).toUpperCase();
                            
                            if(expressDetail.SVMXC__Display_Type__c =='NUMBER')
                                expressDetail.SVMXC__Display_Type__c = 'DOUBLE';
                            SectionExitCriteriaRuleExpr.add(expressDetail);
                            
                        }
                        
                        
                        //Craeting Process Business Rule, Junction object having SFM process , Exit criteria biz rule Source and Target section details
                        SVMXC__ServiceMax_Processes__c ProcessBizRule = new SVMXC__ServiceMax_Processes__c();
                                                 
                        
                   
                        ProcessBizRule.RecordTypeId = ProcessBizRuleId;
                        ProcessBizRule.SVMXC__Rule_Type__c = 'Checklist_Section_Exit_Criteria';
                        ProcessBizRule.SVMXC__Process3__c = lstSectionExitCriteria.get(index).Id;
                        
                        /* if(objSection.checklistId != NULL)
                            ChecklistId = String.escapeSingleQuotes(objSection.checklistId); */
                        System.debug(LoggingLevel.WARN, 'objSection.checklistId : ' + objSection.checklistId);        
                        if(objSection.checklistId != NULL)
                            ProcessBizRule.SVMXC__Process1__c = String.escapeSingleQuotes(objSection.checklistId);
                            
                        if(objSection.TargetSectionId != NULL)
                             ProcessBizRule.SVMXC__SM_Target_Section__c = String.escapeSingleQuotes(objSection.TargetSectionId);                       
                               
                        if(objSection.SourceSectionId != NULL )
                        {
                            ProcessBizRule.SVMXC__SM_Section__c = String.escapeSingleQuotes(objSection.SourceSectionId);
                            lstsourceSectionId.add(objSection.SourceSectionId);
                        }
                        
                        if(objSection.sequenceNo != NULL )
                            ProcessBizRule.SVMXC__Sequence__c = integer.valueOf(String.escapeSingleQuotes(objSection.sequenceNo));
                        
                        if(objSection.enableExitCriteria != NULL )
                            ProcessBizRule.SVMXC__Active__c = boolean.valueOf(String.escapeSingleQuotes(objSection.enableExitCriteria));
                        
                        lstProcessBizRule.add(ProcessBizRule);
                        index = index+1;
                    }
                }
            }
            
            
            //For Checklist process this contains exit criteria ids which has to be deleted
            List<SFM_WrapperDef.SFM_StringListMap> stringListMap = new List<SFM_WrapperDef.SFM_StringListMap>();
                if(SectionExitCriteriaRequest != null && SectionExitCriteriaRequest.request != null && SectionExitCriteriaRequest.request.stringListMap != null && SectionExitCriteriaRequest.request.stringListMap.size() > 0)  
                    stringListMap = SectionExitCriteriaRequest.request.stringListMap;
                 
                list<string> lstExitCriteriaIdDel = new list<string>();
                if(stringListMap != null && stringListMap.size() >0)
                {
                    for(SFM_WrapperDef.SFM_StringListMap obj:stringListMap)
                    {
                        if(obj != null && obj.key != null && obj.key.touppercase()=='EXITCRITERIADEL' && obj.valueList != null && obj.valueList.size()>0)
                            lstExitCriteriaIdDel.addAll(obj.valueList);
                    }
                    lstExitCriteriaId.addAll(lstExitCriteriaIdDel);
                }
                System.debug(LoggingLevel.Warn, 'lstExitCriteriaIdDel: ' + lstExitCriteriaIdDel);
            //Checking if there are existing expression for the given Rule, if so deleting all
            list<SVMXC__ServiceMax_Processes__c> lstProcDel = new list<SVMXC__ServiceMax_Processes__c>();
            
            if((lstsourceSectionId != NULL && lstsourceSectionId.size() > 0) ||(lstExitCriteriaIdDel != null && lstExitCriteriaIdDel.size()>0))
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstProcDel = [select id From SVMXC__ServiceMax_Processes__c Where (Recordtype.Name = 'Business Rule' and id in:lstExitCriteriaIdDel)] ;
            
            System.debug(logginglevel.warn,'lstProcDel:'+lstProcDel);
            
            if(lstProcDel != null && lstProcDel.size()>0)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                delete lstProcDel;
            
            if(lstsourceSectionId != NULL && lstsourceSectionId.size() > 0)
                delete Database.query('Select Id From SVMXC__ServiceMax_Config_Data__c Where Recordtype.Name = \'Expressions\' AND SVMXC__Expression_Rule__c =: lstExitCriteriaId AND SVMXC__Expression_Rule__c != NULL');
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            insert lstProcessBizRule;
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            insert SectionExitCriteriaRuleExpr;
            
            System.debug(logginglevel.warn,'lstProcessBizRule: '+lstProcessBizRule);
            System.debug(logginglevel.warn,'SectionExitCriteriaRuleExpr: '+SectionExitCriteriaRuleExpr);
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            respSuccess = false;
            respMassage = ex.getDmlMessage(0);
            System.debug(logginglevel.warn,'Exception: '+ex);
            System.debug(logginglevel.warn,'StackTrace: '+ex.getStackTraceString());
            
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            respSuccess = false;
            respMassage = ex.getmessage();
            System.debug(logginglevel.warn,'Exception: '+ex);
            System.debug(logginglevel.warn,'StackTrace: '+ex.getStackTraceString());
        }
         //Returning whether the transaction was sucessful or not
        SectionExitCriteriaRuleResponse.success = respSuccess;
        SectionExitCriteriaRuleResponse.message = respMassage;
        
        System.debug(LoggingLevel.WARN, 'Response: ' + SectionExitCriteriaRuleResponse);
        return SectionExitCriteriaRuleResponse;
    }
    
    public void savePageLayout_v2(SFM_WrapperDef2.SFM2_Layout pageLayoutInfo, COMM_AuditTrail.AuditData auditData){


        if(pageLayoutInfo != null && pageLayoutInfo.layoutDetail != null){
            boolean isChecklist = pageLayoutInfo.isChecklist != null ? pageLayoutInfo.isChecklist: false;
            List<SVMXC__SFM_Event__c> events_List;
            Map<String, List<SVMXC__SFM_Event__c>> eventsMap = new Map<String, List<SVMXC__SFM_Event__c>>();
            SVMXC__Page_Layout__c layoutRecord = new SVMXC__Page_Layout__c();
            SFM_WrapperDef2.SFM2_EntityDetail entityDetail = pageLayoutInfo.layoutDetail;
            

            if(entityDetail.entityId != null){
                layoutRecord.Id = entityDetail.entityId;
            }else{
                layoutRecord.SVMXC__Page_Layout_ID__c = SFM_DesignerUtils.generateUniqueId('PAG');
                if(isChecklist){
                    layoutRecord.SVMXC__Name__c = layoutRecord.SVMXC__Page_Layout_ID__c;
                }
            }

            if(!isChecklist && SFM_DesignerUtils.isEntityNameAlreadyUsed(entityDetail.entityName, SFM_DesignerUtils.entity_layout, entityDetail.entityId)){
                System.debug( System.LoggingLevel.ERROR, 'Duplicate Name already exists');
                throw new SFM_DesignerUtils.ServicemaxNestedException( System.Label.SFM001_TAG685 );
            }
            layoutRecord.SVMXC__IsStandard__c = entityDetail.isStandard;
            layoutRecord.SVMXC__SM_Description__c = entityDetail.entityDescription;
            layoutRecord.SVMXC__Name__c = entityDetail.entityName;
            layoutRecord.SVMXC__Type__c = entityDetail.entitySubType;
            layoutRecord.SVMXC__Object_Name__c = pageLayoutInfo.objectAPIName;
            layoutRecord.SVMXC__Page_Help__c = pageLayoutInfo.pageHelp;
            layoutRecord.SVMXC__Help_URL__c = pageLayoutInfo.helpUrl;
            layoutRecord.SVMXC__Hide_Save__c = pageLayoutInfo.hideSave;
            layoutRecord.SVMXC__Hide_Quick_Save__c = pageLayoutInfo.hideQuickSave;
            layoutRecord.SVMXC__Show_All_Sections_By_Default__c = pageLayoutInfo.showAllSections;
            layoutRecord.SVMXC__Show_Account_History__c = pageLayoutInfo.showAccountHistory != null ? pageLayoutInfo.showAccountHistory: false;
            layoutRecord.SVMXC__Show_Product_History__c = pageLayoutInfo.showProductHistory != null ? pageLayoutInfo.showProductHistory: false;
            layoutRecord.SVMXC__Enable_Troubleshooting__c = pageLayoutInfo.enableTroubleShooting != null ? pageLayoutInfo.enableTroubleShooting: false;
            layoutRecord.SVMXC__Enable_Service_Report_View__c = pageLayoutInfo.enableServiceReportView != null ? pageLayoutInfo.enableServiceReportView: false;
            layoutRecord.SVMXC__Enable_Service_Report_Generation__c = pageLayoutInfo.enableServiceReportGeneration != null ? pageLayoutInfo.enableServiceReportGeneration: false;
            layoutRecord.SVMXC__SM_Title_Bar__c = pageLayoutInfo.titleBar;
            layoutRecord.SVMXC__SM_Include_Summary__c = pageLayoutInfo.includeSummary != null ? pageLayoutInfo.includeSummary: false;
            layoutRecord.SVMXC__SM_Summary_Title__c = pageLayoutInfo.summaryTitle;
            layoutRecord.SVMXC__SM_Include_Time_and_Place__c = pageLayoutInfo.includeEventTimePlace != null ? pageLayoutInfo.includeEventTimePlace: false;
            layoutRecord.SVMXC__SM_Include_Contact__c = pageLayoutInfo.includeContact != null ? pageLayoutInfo.includeContact: false;
            layoutRecord.SVMXC__SM_Include_Field1__c = pageLayoutInfo.includeField1;
            layoutRecord.SVMXC__SM_Include_Field2__c = pageLayoutInfo.includeField2;
            layoutRecord.SVMXC__SM_Include_Field3__c = pageLayoutInfo.includeField3;

            Savepoint sp = Database.setSavepoint();
            try{
                Set<Id> eventIds = new Set<Id>();
                Set<Id> elementIds = new Set<Id>();
                Set<Id> sectionIds = new Set<Id>();
                Set<Id> detailIds = new Set<Id>();
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(layoutRecord, COMM_SecurityUtils.Access.Upsertable)){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                } 

                upsert layoutRecord;
                
                // Create audit trail for SFM page layout creation or update.
                COMM_AuditTrail.AuditTrailInfo auditTrailInfo = new COMM_AuditTrail.AuditTrailInfo();
                auditTrailInfo.entityName = System.Label.AUDIT001_TAG015;
                auditTrailInfo.application = System.Label.AUDIT001_TAG008;
                auditTrailInfo.actionType = entityDetail.entityId == null ? System.Label.AUDIT001_TAG009 : System.Label.AUDIT001_TAG010;
                auditTrailInfo.action = entityDetail.entityId == null ? System.Label.AUDIT001_TAG052 + entityDetail.entityName : System.Label.AUDIT001_TAG053 + entityDetail.entityName;
                auditTrailInfo.internalId = layoutRecord.Id;
                COMM_AuditTrail.getInstance().logAudit(auditTrailInfo, auditData);
                entityDetail.entityId = layoutRecord.Id;
                Map<String, SVMXC__ServiceMax_Processes__c> processJunctionRecordMap = new Map<String, SVMXC__ServiceMax_Processes__c>();
                if(pageLayoutInfo.processId != null){
                    processJunctionRecordMap = new Map<String, SVMXC__ServiceMax_Processes__c>();

                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__Process1__c', 'SVMXC__Process3__c', 'SVMXC__SM_Section__c', 'SVMXC__Rule_Type__c', 'SVMXC__Sequence__c'}, COMM_SecurityUtils.Access.Accessible)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                    for(SVMXC__ServiceMax_Processes__c processRec : [SELECT Id, SVMXC__Rule_Type__c, SVMXC__SM_Section__c, SVMXC__Process3__c, SVMXC__Process1__c FROM SVMXC__ServiceMax_Processes__c WHERE 
                                                                       SVMXC__Process1__c =: pageLayoutInfo.processId AND RecordType.Name = 'Process Business Rule' AND SVMXC__Rule_Type__c IN ('Checklist_Section_Entry_Criteria', 'Checklist_Section_Exit_Criteria', 'Checklist_QB')]){
                        if(processRec.SVMXC__Rule_Type__c != 'Checklist_QB'){
                            processJunctionRecordMap.put(processRec.SVMXC__Rule_Type__c + processRec.SVMXC__SM_Section__c + processRec.SVMXC__Process3__c, processRec);                                                    
                        } else {
                            processJunctionRecordMap.put(processRec.SVMXC__Rule_Type__c + processRec.SVMXC__Process3__c, processRec);                                                    
                        }
                    }
                }
                /*
                    Page Events
                */
                events_List = mapEventFields(pageLayoutInfo.events, layoutRecord.Id, null);
                
                if(events_List != null){
                    eventsMap.put(layoutRecord.Id, events_List);
                }

                if(pageLayoutInfo.sectionDetails != null){
                    Map<String, SFM_WrapperDef2.SFM2_LayoutSection> sectionMap = new Map<String, SFM_WrapperDef2.SFM2_LayoutSection>();
                    List<SVMXC__Page_Layout_Detail__c> pageLayoutSectionList = new List<SVMXC__Page_Layout_Detail__c>();
                    List<SVMXC__Page_Layout__c> pageLayoutDetailList = new List<SVMXC__Page_Layout__c>();
                    Decimal buttonSequence = 0;
                    Decimal sequenceKey;
                    for(SFM_WrapperDef2.SFM2_LayoutSection sectionInfo : pageLayoutInfo.sectionDetails){

                        if(sectionInfo.sectionType.equals('Section') || sectionInfo.sectionType.equals('Button')){
                            SVMXC__Page_Layout_Detail__c layoutSection = new SVMXC__Page_Layout_Detail__c(SVMXC__Page_Layout__c = layoutRecord.Id);
                            if(sectionInfo.sectionId != null){
                                layoutSection.Id = sectionInfo.sectionId;
                            }

                            layoutSection.SVMXC__Detail_Type__c = sectionInfo.sectionType;
                            layoutSection.SVMXC__Sequence__c = sectionInfo.sequence;
                            layoutSection.SVMXC__No_Of_Columns__c = sectionInfo.columns;
                            layoutSection.SVMXC__Title__c = sectionInfo.title;
                            layoutSection.SVMXC__SM_Help_URL__c = sectionInfo.helpUrl;
                            layoutSection.SVMXC__SM_Description__c = sectionInfo.description;
                            layoutSection.SVMXC__Show_In_Web__c = sectionInfo.showinWeb;
                            layoutSection.SVMXC__Show_In_iPad__c = sectionInfo.showinIpad;
                            layoutSection.SVMXC__Use_For_SLA_Clock__c = sectionInfo.useForSLA != null ? sectionInfo.useForSLA : false;
                            sequenceKey = sectionInfo.sectionType.equals('Button') ? buttonSequence++ : layoutSection.SVMXC__Sequence__c; 
                            sectionMap.put( sectionInfo.sectionType.toUpperCase() + sequenceKey, sectionInfo);

                            pageLayoutSectionList.add(layoutSection);

                        }else if(sectionInfo.sectionType.equals('Detail')){
                            SVMXC__Page_Layout__c layoutDetail = new SVMXC__Page_Layout__c();
                            if(sectionInfo.sectionId != null){
                                layoutDetail.Id = sectionInfo.sectionId;
                            }
                            layoutDetail.SVMXC__Page_Layout_ID__c = sectionInfo.objectAlias;
                            layoutDetail.SVMXC__Type__c = sectionInfo.sectionType;
                            layoutDetail.SVMXC__Object_Name__c = sectionInfo.childAPIName;
                            layoutDetail.SVMXC__Action_On_Zero_Lines__c = sectionInfo.allowZeroLines;
                            layoutDetail.SVMXC__Allow_New_Lines__c = sectionInfo.allowNew;
                            layoutDetail.SVMXC__Allow_Delete_Lines__c = sectionInfo.allowDelete;
                            layoutDetail.SVMXC__Multi_Add_Search_Field__c = sectionInfo.multiAddField;
                            layoutDetail.SVMXC__Multi_Add_Search_Object__c = sectionInfo.multiAddObject;
                            layoutDetail.SVMXC__Header_Reference_Field__c = sectionInfo.headerReferenceField;
                            layoutDetail.SVMXC__Sequence__c = sectionInfo.sequence;
                            layoutDetail.SVMXC__No_Of_Columns__c = sectionInfo.columns;
                            layoutDetail.SVMXC__Name__c = sectionInfo.title;
                            layoutDetail.SVMXC__Header_Page_Layout__c = layoutRecord.Id;

                            sectionMap.put('DETAIL' + layoutDetail.SVMXC__Sequence__c, sectionInfo);
                            pageLayoutDetailList.add(layoutDetail);
                        }
                    }

                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(pageLayoutSectionList, COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                    } 

                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(pageLayoutDetailList, COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                    } 

                    upsert pageLayoutSectionList;

                    upsert pageLayoutDetailList;

                    List<SVMXC__Page_Layout_Detail__c> elementList = new List<SVMXC__Page_Layout_Detail__c>(); 
                    Map<String, SVMXC__ServiceMax_Processes__c> sectionBusinessRuleHeaderMap = new Map<String, SVMXC__ServiceMax_Processes__c>();
                    Map<String, SFM_WrapperDef2.SFM2_LayoutElement> elementWrapperMap = new  Map<String, SFM_WrapperDef2.SFM2_LayoutElement>();
                    List<SVMXC__ServiceMax_Processes__c> ruleJunctionRecordList = new List<SVMXC__ServiceMax_Processes__c>(); 
                    Set<Id> processJunctionIds = new Set<Id>();                    
                    String mapKey;
                    buttonSequence = 0;
                    for(SVMXC__Page_Layout_Detail__c layoutSectionRec : pageLayoutSectionList){

                        sequenceKey = layoutSectionRec.SVMXC__Detail_Type__c.equals('Button') ? buttonSequence++ : layoutSectionRec.SVMXC__Sequence__c; 
                        String sectionElementKey = layoutSectionRec.SVMXC__Detail_Type__c.toUpperCase() + sequenceKey;
                        if(sectionMap.containsKey(sectionElementKey)){
                            
                            SFM_WrapperDef2.SFM2_LayoutSection layoutSectionWrapRec = sectionMap.get(sectionElementKey);
                            
                            layoutSectionWrapRec.sectionId = layoutSectionRec.Id;
                            sectionIds.add(layoutSectionRec.Id);
                            
                            if(layoutSectionWrapRec.layoutElements != null){
                                
                                for(SFM_WrapperDef2.SFM2_LayoutElement layoutElement : layoutSectionWrapRec.layoutElements){
                                    SVMXC__Page_Layout_Detail__c elementRecord = mapElementFields(layoutElement, new SVMXC__Page_Layout_Detail__c(SVMXC__Section__c = layoutSectionRec.Id, SVMXC__Page_Layout__c = layoutRecord.Id));
                                    elementList.add(elementRecord);
                                    if(pageLayoutInfo.processId != null && layoutElement.questionRuleId != null){
                                        String junctionKey = 'Checklist_QB' + layoutElement.questionRuleId;
                                        if(processJunctionRecordMap.containsKey(junctionKey)){
                                            processJunctionIds.add(processJunctionRecordMap.get(junctionKey).Id);
                                            if( layoutElement.questionRuleMessage != null  ) {
                                                processJunctionRecordMap.get(junctionKey).SVMXC__Parent_Error_Msg__c = layoutElement.questionRuleMessage;
                                            	ruleJunctionRecordList.add(processJunctionRecordMap.get(junctionKey));
                                            }
                                        }else{
                                            SVMXC__ServiceMax_Processes__c processJunctionRecord = new SVMXC__ServiceMax_Processes__c();
                                            processJunctionRecord.SVMXC__Rule_Type__c = 'Checklist_QB';
                                            processJunctionRecord.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Process Business Rule');
                                            processJunctionRecord.SVMXC__Process1__c = pageLayoutInfo.processId;
                                            processJunctionRecord.SVMXC__Process3__c = layoutElement.questionRuleId;
                                            processJunctionRecord.SVMXC__Parent_Error_Msg__c = layoutElement.questionRuleMessage;
                                            ruleJunctionRecordList.add(processJunctionRecord);
                                        }                                            
                                    }
                                    elementWrapperMap.put(elementRecord.SVMXC__Section__c + '-' + elementRecord.SVMXC__Sequence__c, layoutElement);

                                }
                            }

                            if(layoutSectionWrapRec.exitCriteria != null){
                                for(SFM_WrapperDef2.SFM2_Rule sfm_Rule : layoutSectionWrapRec.exitCriteria){
                                    SVMXC__ServiceMax_Processes__c processRecord = mapRuleHeader(sfm_Rule);
                                    processRecord.SVMXC__Rule_Type__c = 'Checklist_Section_Exit_Criteria';
                                    processRecord.SVMXC__Question_Bank__c = sfm_Rule.questionId;
                                    mapKey = layoutSectionWrapRec.sectionId + '_' + sfm_Rule.sequence;
                                    sectionBusinessRuleHeaderMap.put(mapKey, processRecord);
                                }                                
                            }
                            events_List = mapEventFields(layoutSectionWrapRec.events, null, layoutSectionRec.Id);
                            
                            if(events_List != null){
                                eventsMap.put(layoutSectionRec.Id, events_List);
                            }

                        }
                    }

                    for(SVMXC__Page_Layout__c layoutDetailRec : pageLayoutDetailList){

                        if(sectionMap.containsKey('DETAIL' + layoutDetailRec.SVMXC__Sequence__c)){

                            SFM_WrapperDef2.SFM2_LayoutSection layoutSectionWrapRec = sectionMap.get('DETAIL' + layoutDetailRec.SVMXC__Sequence__c);

                            layoutSectionWrapRec.sectionId = layoutDetailRec.Id;
                            detailIds.add(layoutDetailRec.Id);

                            if(layoutSectionWrapRec.layoutElements != null){
                                
                                for(SFM_WrapperDef2.SFM2_LayoutElement layoutElement : layoutSectionWrapRec.layoutElements){
                                    SVMXC__Page_Layout_Detail__c elementRecord = mapElementFields(layoutElement, new SVMXC__Page_Layout_Detail__c(SVMXC__Page_Layout__c = layoutDetailRec.Id));
                                    elementList.add(elementRecord);
                                    elementWrapperMap.put(elementRecord.SVMXC__Page_Layout__c + '-' + elementRecord.SVMXC__Sequence__c, layoutElement);

                                }
                            }

                            events_List = mapEventFields(layoutSectionWrapRec.events, layoutDetailRec.Id, null);
                            
                            if(events_List != null){
                                eventsMap.put(layoutDetailRec.Id, events_List);
                            }
                        }

                    }

                    if(!elementList.isEmpty()){
                        
                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(elementList, COMM_SecurityUtils.Access.Upsertable)){
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                        } 
                    
                        upsert elementList;

                        for(SVMXC__Page_Layout_Detail__c elementRecord : elementList){
                            
                            SFM_WrapperDef2.SFM2_LayoutElement layoutElement;
                            if(elementRecord.SVMXC__Section__c != null && elementWrapperMap.containsKey(elementRecord.SVMXC__Section__c + '-' + elementRecord.SVMXC__Sequence__c)){
                               layoutElement = elementWrapperMap.get(elementRecord.SVMXC__Section__c + '-' + elementRecord.SVMXC__Sequence__c);
                            }else if(elementRecord.SVMXC__Page_Layout__c != null && elementWrapperMap.containsKey(elementRecord.SVMXC__Page_Layout__c + '-' + elementRecord.SVMXC__Sequence__c)){
                               layoutElement = elementWrapperMap.get(elementRecord.SVMXC__Page_Layout__c + '-' + elementRecord.SVMXC__Sequence__c);
                            }

                            if(layoutElement != null){
                                layoutElement.eltId = elementRecord.Id;
                                elementIds.add(elementRecord.Id);
                                events_List = mapEventFields(layoutElement.events, null,  elementRecord.Id);
                                
                                if(events_List != null){
                                    eventsMap.put(elementRecord.Id, events_List);
                                }
                               
                            }
                        }
                    }

                    if(!eventsMap.isEmpty()){
                        events_List = new List<SVMXC__SFM_Event__c>();
                        for(String sourceId : eventsMap.keySet()){
                            events_List.addAll(eventsMap.get(sourceId));
                        }

                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(events_List, COMM_SecurityUtils.Access.Upsertable)){
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                        }

                        upsert events_List;

                        List<SVMXC__SFM_Event__c> tempEventList;

                        if(eventsMap.containsKey(layoutRecord.Id)){
                            tempEventList = eventsMap.get(layoutRecord.Id);
                            pageLayoutInfo.events = eventWrapper(tempEventList, eventIds);                        
                        }
                        for(SFM_WrapperDef2.SFM2_LayoutElement layoutElement : elementWrapperMap.values()){
                            if(eventsMap.containsKey(layoutElement.eltId)){
                                tempEventList = eventsMap.get(layoutElement.eltId);
                                layoutElement.events = eventWrapper(tempEventList, eventIds);
                            }
                        }
                    }
                    if(!sectionBusinessRuleHeaderMap.isEmpty()){
                        List<SVMXC__ServiceMax_Processes__c> businessRulesList = new List<SVMXC__ServiceMax_Processes__c>(); 
                        businessRulesList.addAll(sectionBusinessRuleHeaderMap.values());
                        if(!businessRulesList.isEmpty()){
                        
                            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(businessRulesList, COMM_SecurityUtils.Access.Upsertable)){
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                            }

                            upsert businessRulesList;
                        }
                    }

                    Map<String, List<SVMXC__ServiceMax_Config_Data__c>> ruleConfigMap =  new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
                    List<SFM_WrapperDef2.SFM2_Rule> criteriaRuleWrapperList = new List<SFM_WrapperDef2.SFM2_Rule>();
                    List<SVMXC__ServiceMax_Config_Data__c> configList;
                    Set<Id> expressionRowIds = new Set<Id>(); 
                    Set<Id> expressionHeaderIds = new Set<Id>();
                        for(SFM_WrapperDef2.SFM2_LayoutSection layoutSection : sectionMap.values()){
                            
                            if(eventsMap.containsKey(layoutSection.sectionId)){
                            List<SVMXC__SFM_Event__c> tempEventList = eventsMap.get(layoutSection.sectionId);
                                layoutSection.events = eventWrapper(tempEventList, eventIds);                        
                        }
                        if(pageLayoutInfo.processId != null){
                            if(layoutSection.entryCriteriaId != null){
                                String junctionKey = 'Checklist_Section_Entry_Criteria' + layoutSection.sectionId + layoutSection.entryCriteriaId;
                                SVMXC__ServiceMax_Processes__c processJunctionRecord = new SVMXC__ServiceMax_Processes__c();
                                        if(processJunctionRecordMap.containskey(junctionKey)){
                                    processJunctionRecord.Id = processJunctionRecordMap.get(junctionKey).Id;
                                } 
                                            processJunctionRecord.SVMXC__Rule_Type__c = 'Checklist_Section_Entry_Criteria';
                                            processJunctionRecord.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Process Business Rule');
                                            processJunctionRecord.SVMXC__Process1__c = pageLayoutInfo.processId;
                                    processJunctionRecord.SVMXC__Process3__c = layoutSection.entryCriteriaId;
                                            processJunctionRecord.SVMXC__SM_Section__c = layoutSection.sectionId;
                                processJunctionRecord.SVMXC__Active__c = true;
                                            ruleJunctionRecordList.add(processJunctionRecord);
                            }

                            if(layoutSection.exitCriteria != null){
                                for(SFM_WrapperDef2.SFM2_Rule sfm_Rule : layoutSection.exitCriteria){
                                    mapKey = layoutSection.sectionId + '_' + sfm_Rule.sequence;
                                    if(sectionBusinessRuleHeaderMap.containskey(mapKey)){
                                        SVMXC__ServiceMax_Processes__c processRecord = sectionBusinessRuleHeaderMap.get(mapKey);
                                        sfm_Rule.ruleDetail.entityId = processRecord.Id;
                                        criteriaRuleWrapperList.add(sfm_Rule);
                                        String junctionKey = 'Checklist_Section_Exit_Criteria' + layoutSection.sectionId + processRecord.Id;
                                        SVMXC__ServiceMax_Processes__c processJunctionRecord = new SVMXC__ServiceMax_Processes__c();
                                        if(processJunctionRecordMap.containskey(junctionKey)){
                                            processJunctionRecord.Id = processJunctionRecordMap.get(junctionKey).Id;
                        }   
                                        processJunctionRecord.SVMXC__Rule_Type__c = 'Checklist_Section_Exit_Criteria';
                                        processJunctionRecord.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Process Business Rule');
                                        processJunctionRecord.SVMXC__Process1__c = pageLayoutInfo.processId;
                                        processJunctionRecord.SVMXC__Process3__c = processRecord.Id;
                                        processJunctionRecord.SVMXC__SM_Section__c = layoutSection.sectionId;
                                        processJunctionRecord.SVMXC__Sequence__c = sfm_Rule.sequence;
                                        processJunctionRecord.SVMXC__Active__c = true;
                                        if(sfm_Rule.targetSequence != null){
                                            String targetSectionKey = layoutSection.sectionType.toUpperCase() + sfm_Rule.targetSequence;
                                            if(sectionMap.containsKey(targetSectionKey)){
                                                processJunctionRecord.SVMXC__SM_Target_Section__c = sectionMap.get(targetSectionKey).sectionId;
                                            }
                                        }
                                        ruleJunctionRecordList.add(processJunctionRecord);
                                        if(sfm_Rule.expressionsList != null){
                                            configList = new List<SVMXC__ServiceMax_Config_Data__c>();
                                            for(SFM_WrapperDef2.SFM2_RuleExpression ruleExpression : sfm_Rule.expressionsList){
                                                SVMXC__ServiceMax_Config_Data__c configData = mapRuleDetail(ruleExpression);
                                                configData.SVMXC__Expression_Rule__c = processRecord.Id;
                                                configList.add(configData);
                                            }
                                        }
                                        ruleConfigMap.put(processRecord.Id, configList);
                                    }
                                }    
                            } 
                        }                   
                        

                    }

                    if(!ruleConfigMap.isEmpty()){
                        configList = new List<SVMXC__ServiceMax_Config_Data__c>();
                        for(String ruleKey : ruleConfigMap.keySet()){
                            configList.addAll(ruleConfigMap.get(ruleKey));
                        }
                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(configList, COMM_SecurityUtils.Access.Upsertable)){
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                        }
                        upsert configList;
                        SFM_SaveAsExpression buildSFMRuleClass = new SFM_SaveAsExpression();
                        for(SFM_WrapperDef2.SFM2_Rule sfm_Rule : criteriaRuleWrapperList){
                            if(ruleConfigMap.containskey(sfm_Rule.ruleDetail.entityId)){
                                expressionHeaderIds.add(sfm_Rule.ruleDetail.entityId);
                                for(SVMXC__ServiceMax_Config_Data__c configRec : ruleConfigMap.get(sfm_Rule.ruleDetail.entityId)){
                                    SFM_WrapperDef2.SFM2_RuleExpression ruleExpressionWrap = buildSFMRuleClass.buildSFM2RuleExpression(configRec, SFM_DesignerUtils.entity_sectionCriteria, false);
                                    expressionRowIds.add(configRec.Id);
                                } 
                               sfm_Rule.expressionsList = buildSFMRuleClass.expressionListWrapper(ruleConfigMap.get(sfm_Rule.ruleDetail.entityId), SFM_DesignerUtils.entity_sectionCriteria, false);
                            }
                        }
                    }

                    if(!ruleJunctionRecordList.isEmpty()){
                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(ruleJunctionRecordList, COMM_SecurityUtils.Access.Createable)){
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                            }

                        upsert ruleJunctionRecordList;
                        for(SVMXC__ServiceMax_Processes__c junctionRec : ruleJunctionRecordList){
                            processJunctionIds.add(junctionRec.Id);
                        }
                    }

                    if(pageLayoutInfo.processId != null){
                        deleteCriteriaRecords(processJunctionIds, expressionHeaderIds, expressionRowIds, pageLayoutInfo.processId);
                    }

                }

                deleteRecords(eventIds, elementIds, detailIds, sectionIds, layoutRecord.Id);

            }catch(DmlException ex){
                System.debug(System.LoggingLevel.Error, 'DML Exception Occurred!!! Method: savePageLayout_v2' + ex.getMessage());
                Database.rollback(sp);
                throw ex;
            }catch(exception ex){
                System.debug('Exception Occurred!!! Method: savePageLayout_v2' + ex.getStackTraceString());
                Database.rollback(sp);
                throw ex;
            }finally{
                System.debug( System.LoggingLevel.DEBUG, 'savePageLayout_v2() - exit; return value ' + pageLayoutInfo);
            }  

       }

       // return pageLayoutInfo;

    }

    void deleteRecords(Set<Id> eventIds, Set<Id> elementIds, Set<Id> detailIds, Set<Id> sectionIds, Id layoutId){


        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SFM_Event__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__Page_Layout_Detail__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__Page_Layout__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        List<SVMXC__SFM_Event__c> eventDeleteList = [SELECT Id FROM SVMXC__SFM_Event__c WHERE (SVMXC__Page_Layout__c IN: detailIds OR SVMXC__Page_Layout__c =: layoutId OR SVMXC__Page_Layout_Detail__c IN: elementIds) AND Id NOT IN: eventIds];

        if(!eventDeleteList.isEmpty()){
            delete eventDeleteList;
        }

        List<SVMXC__Page_Layout_Detail__c> eltDeleteList = [SELECT Id FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Detail_Type__c  IN ('Field', 'Question') AND (((SVMXC__Section__c IN: sectionIds OR SVMXC__Page_Layout__c IN: detailIds) AND Id NOT IN: elementIds)
                                                              OR (SVMXC__Section__c NOT IN: sectionIds AND SVMXC__Page_Layout__c =: layoutId))];
        
        if(!eltDeleteList.isEmpty()){
            delete eltDeleteList;
        }

        List<SVMXC__Page_Layout__c> detailDeleteList = [SELECT Id FROM SVMXC__Page_Layout__c WHERE SVMXC__Header_Page_Layout__c =: layoutId AND Id NOT IN: detailIds];
        
        if(!detailDeleteList.isEmpty()){
            delete detailDeleteList;
        }

        List<SVMXC__Page_Layout_Detail__c> sectionDeleteList = [SELECT Id FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Detail_Type__c IN ('Section', 'Button')  AND SVMXC__Page_Layout__c =: layoutId AND Id NOT IN: sectionIds];
        
        if(!sectionDeleteList.isEmpty()){
            delete sectionDeleteList;
        }
    }

    void deleteCriteriaRecords(Set<Id> processJunctionIds, Set<Id> expressionHeaderIds, Set<Id> expressionRowIds, String processId){
        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }     

        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }   
        List<SVMXC__ServiceMax_Processes__c> processBusinessRuleDeleteList = [SELECT Id, SVMXC__Process3__c, SVMXC__Rule_Type__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process1__c =: processId AND RecordType.Name = 'Process Business Rule' 
                                                                                AND SVMXC__Rule_Type__c IN ('Checklist_Section_Entry_Criteria', 'Checklist_Section_Exit_Criteria', 'Checklist_QB') AND ID NOT IN: processJunctionIds];
        List<SVMXC__ServiceMax_Config_Data__c> configDeleteList = new List<SVMXC__ServiceMax_Config_Data__c>();
        Set<Id> businessRuleIds = new Set<Id>();
        for(SVMXC__ServiceMax_Processes__c processRec : processBusinessRuleDeleteList){
            if(processRec.SVMXC__Process3__c != null && processRec.SVMXC__Rule_Type__c == 'Checklist_Section_Exit_Criteria')
                businessRuleIds.add(processRec.SVMXC__Process3__c);
        }
        for(SVMXC__ServiceMax_Processes__c processRec : [SELECT Id, (SELECT Id FROM SVMXC__ServiceMax_Config_Data2__r) FROM SVMXC__ServiceMax_Processes__c WHERE Id IN: businessRuleIds]){
            processBusinessRuleDeleteList.add(processRec);
            configDeleteList.add(processRec.SVMXC__ServiceMax_Config_Data2__r);
        }
        configDeleteList.addAll([SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__c IN: expressionHeaderIds AND ID NOT IN: expressionRowIds]);
        if(!configDeleteList.isEmpty()){
            delete configDeleteList;
        }
        if(!processBusinessRuleDeleteList.isEmpty()){
            delete processBusinessRuleDeleteList;
        }
    }
    List<SVMXC__SFM_Event__c> mapEventFields(List<SFM_WrapperDef2.SFM2_Event> eventWrapperList, String pageLayoutId, String detailId){
        List<SVMXC__SFM_Event__c> eventsList;
        if(eventWrapperList != null){
            eventsList = new List<SVMXC__SFM_Event__c>();
            for(SFM_WrapperDef2.SFM2_Event eventWrapperRec : eventWrapperList){
                SVMXC__SFM_Event__c eventRecord = new SVMXC__SFM_Event__c();
                
                if(eventWrapperRec.eventId != null){
                    eventRecord.Id = eventWrapperRec.eventId;
                }

                eventRecord.SVMXC__Page_Layout__c = pageLayoutId;
                eventRecord.SVMXC__Page_Layout_Detail__c = detailId;
                eventRecord.SVMXC__Event_Type__c = eventWrapperRec.eventType;
                eventRecord.SVMXC__Event_Call_Type__c = eventWrapperRec.eventCallType;
                eventRecord.SVMXC__URL_Window_Type__c = eventWrapperRec.urlWindowType;
                
                if(eventRecord.SVMXC__Event_Call_Type__c.equals('JAVASCRIPT')){
                    eventRecord.SVMXC__Code_Snippet__c = eventWrapperRec.eventActionId ;
                }else if(eventRecord.SVMXC__Event_Call_Type__c.equalsIgnoreCase('SFM CUSTOM ACTION')){
                    eventRecord.SVMXC__ServiceMax_Custom_Action__c = eventWrapperRec.eventActionId;
                }else if(eventRecord.SVMXC__Event_Call_Type__c.equals('WEBSERVICE') || eventRecord.SVMXC__Event_Call_Type__c.equals('URL')){
                    eventRecord.SVMXC__Target_Call__c = eventWrapperRec.eventActionId;
                }

                eventsList.add(eventRecord);

            }
        }

        return eventsList;  

    }

  
 
    public List<SFM_WrapperDef2.SFM2_Event> eventWrapper(List<SVMXC__SFM_Event__c> eventsList, Set<Id> eventIds){
        
        List<SFM_WrapperDef2.SFM2_Event> eventWrapperList = new List<SFM_WrapperDef2.SFM2_Event>(); 
        for(SVMXC__SFM_Event__c eventRecord : eventsList){
            SFM_WrapperDef2.SFM2_Event event = new SFM_WrapperDef2.SFM2_Event();
            eventIds.add(eventRecord.Id);
            event.eventId = eventRecord.Id;
            event.eventType = eventRecord.SVMXC__Event_Type__c;
            event.eventCallType = eventRecord.SVMXC__Event_Call_Type__c;
            
            if(eventRecord.SVMXC__Event_Call_Type__c == 'JAVASCRIPT'){
                 event.eventActionId = eventRecord.SVMXC__Code_Snippet__c;
            }else if(eventRecord.SVMXC__Event_Call_Type__c == 'WEBSERVICE'){
                event.eventActionId = eventRecord.SVMXC__Target_Call__c;
            }

            eventWrapperList.add(event);
        }

        return eventWrapperList;
    }



    SVMXC__Page_Layout_Detail__c mapElementFields(SFM_WrapperDef2.SFM2_LayoutElement layoutElement, SVMXC__Page_Layout_Detail__c elementRecord){
        
        if(elementRecord == null)
            elementRecord = new SVMXC__Page_Layout_Detail__c();
        
        if( String.isNotEmpty( layoutElement.eltId ) ) {
            elementRecord.Id = layoutElement.eltId;
        }

        elementRecord.SVMXC__Detail_Type__c = layoutElement.eltType;
        elementRecord.SVMXC__Field_API_Name__c = layoutElement.aPIName;
        elementRecord.SVMXC__DataType__c = layoutElement.dataType != null ? layoutElement.dataType.toLowerCase(): null;
        elementRecord.SVMXC__Related_Object_Name__c = layoutElement.referenceTo;
        elementRecord.SVMXC__Related_Object_Name_Field__c = layoutElement.referenceNameField;
        elementRecord.SVMXC__Sequence__c = layoutElement.sequence;
        elementRecord.SVMXC__Display_Row__c = layoutElement.row;
        elementRecord.SVMXC__Display_Column__c = layoutElement.column;
        elementRecord.SVMXC__No_Of_Columns__c = layoutElement.noOfColumn;
        elementRecord.SVMXC__Title__c = layoutElement.title;
        elementRecord.SVMXC__Required__c = layoutElement.required;
        elementRecord.SVMXC__Readonly__c = layoutElement.readOnly;
        elementRecord.SVMXC__Named_Search__c = layoutElement.lkpupConfig;
        elementRecord.SVMXC__Override_Related_Lookup__c =  layoutElement.overrideContext;
        elementRecord.SVMXC__Lookup_Context__c = layoutElement.lkpContext;
        elementRecord.SVMXC__Lookup_Query_Field__c =  layoutElement.lkpMatchField;
        elementRecord.SVMXC__Field_Mapping__c = layoutElement.lkpFormFill;
        elementRecord.SVMXC__Context_Source_Object__c = layoutElement.lkpContextSrc;
        elementRecord.SVMXC__Question__c = layoutElement.questionId;
        elementRecord.SVMXC__SM_Checklist_Source_Field_API_Name__c = layoutElement.checklistSourceField;

        return elementRecord;
    }  
    SVMXC__ServiceMax_Processes__c mapRuleHeader( SFM_WrapperDef2.SFM2_Rule sfm_Rule ){
        if(sfm_Rule.ruleDetail != null){
            SVMXC__ServiceMax_Processes__c processRecord = new SVMXC__ServiceMax_Processes__c();
            SFM_WrapperDef2.SFM2_EntityDetail ruleDetail = sfm_Rule.ruleDetail;
            if(ruleDetail.entityId != null ) {
                processRecord.Id = ruleDetail.entityId;
            } else {
                processRecord.SVMXC__ProcessID__c = SFM_DesignerUtils.generateUniqueId('DVR');
            }
            processRecord.SVMXC__Name__c = ruleDetail.entityName;
            processRecord.SVMXC__Source_Object_Name__c = sfm_Rule.sourceObject;
            processRecord.SVMXC__Advance_Expression__c = sfm_Rule.advanceExpression;
            processRecord.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Business Rule');
            return processRecord;
        }
        return null;
    }
    SVMXC__ServiceMax_Config_Data__c mapRuleDetail(SFM_WrapperDef2.SFM2_RuleExpression ruleExpression){
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        if(ruleExpression.expressionId != null){
          configData.Id = ruleExpression.expressionId;
        }
        configData.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Expressions');
        configData.SVMXC__Parameter_Type__c = ruleExpression.parameterType;
        configData.SVMXC__Field_Name__c = ruleExpression.sourceField;
        configData.SVMXC__Display_Type__c = ruleExpression.sourceFldDtaType;
        configData.SVMXC__Expression_Type__c = 'Business_Rule';
        configData.SVMXC__Sequence__c = ruleExpression.sequence;
        configData.SVMXC__Operator__c = ruleExpression.operator; 
        configData.SVMXC__Operand__c = ruleExpression.value; 
        return configData;
    }
}