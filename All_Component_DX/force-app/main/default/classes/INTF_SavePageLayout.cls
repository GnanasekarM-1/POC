public with sharing class INTF_SavePageLayout 
{
    SVMXC.INTF_WebServicesDef pmaxwrapp = new SVMXC.INTF_WebServicesDef();
    public map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>(); 
    public map<String,Schema.SObjectType> Allobj = new map<String,Schema.SObjectType>();  
    public INTF_SavePageLayout()
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
    
    public INTF_WebServicesDef.INTF_Response INTF_savePageLayout(INTF_WebServicesDef.INTF_Request_PageUI PmaxReqPageUI)
    {
        SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
        savepoint sp;
        try
        {
            sp = Database.setSavepoint();
            List<INTF_WebServicesDef.INTF_StringMap> StringMap = new List<INTF_WebServicesDef.INTF_StringMap>();
            if(PmaxReqPageUI != null && PmaxReqPageUI.request != null && PmaxReqPageUI.request.stringMap != null && PmaxReqPageUI.request.stringMap.size() > 0)  
                StringMap = PmaxReqPageUI.request.stringMap;
            system.debug('StringMap'+StringMap);
            String ProcessId = '';
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
            SVMXC.INTF_WebServicesDef.INTF_PageUI PageUI = new SVMXC.INTF_WebServicesDef.INTF_PageUI();
            SVMXC__ServiceMax_Processes__c ProcessNode = new SVMXC__ServiceMax_Processes__c();
            //get the SFM_PageUI
            if(PmaxReqPageUI.page != null)
                PageUI = PmaxReqPageUI.page;
            ProcessNode = PmaxReqPageUI.processNode; //process node needs to be inserted(pending)
            SVMXC.INTF_WebServicesDef.INTF_PageHeader PageHeader = new SVMXC.INTF_WebServicesDef.INTF_PageHeader();
            if(PageUI.header != null)
                PageHeader = PageUI.header;//PageHeader Member
            system.debug('PageHeader'+PageHeader);    
            List<SVMXC.INTF_WebServicesDef.INTF_PageDetail> PageDetails = new List<SVMXC.INTF_WebServicesDef.INTF_PageDetail>();
            if(PageUI.details != null)
                PageDetails = PageUI.details;
            system.debug('PageDetails'+PageDetails.size()+PageDetails); 
            //Header is only one so process PageHeader and get the member
            //Member variable of the SFM_PageHeader
            SVMXC__Page_Layout__c WrapperheaderLayout = new SVMXC__Page_Layout__c();
            SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
            List<SVMXC.INTF_WebServicesDef.INTF_UISection> UISectionLst = new List<SVMXC.INTF_WebServicesDef.INTF_UISection>();
            List<SVMXC.INTF_WebServicesDef.INTF_UIButton> UIButtonLst = new List<SVMXC.INTF_WebServicesDef.INTF_UIButton>();
            List<SVMXC__SFM_Event__c> pageEvents = new List<SVMXC__SFM_Event__c>();
            if(PageHeader.headerLayout != null)
                WrapperheaderLayout = PageHeader.headerLayout; 
            system.debug('HeaderLayout'+HeaderLayout);       
            if(PageHeader.sections != null)
                UISectionLst = PageHeader.sections;
            if(PageHeader.buttons != null)
                UIButtonLst =  PageHeader.buttons;
            if(PageHeader.pageEvents != null)
                PageEvents = PageHeader.pageEvents;
            //insert the Header page Layout..
            String HeaderId = '';
            if(HeaderLayout != null)
            {   
                
                headerObject = WrapperheaderLayout.SVMXC__Object_Name__c;
                WrapperheaderLayout.SVMXC__Type__c = 'Header';
                if(WrapperheaderLayout.SVMXC__Help_URL__c == null || WrapperheaderLayout.SVMXC__Help_URL__c.length() == 0)
                    WrapperheaderLayout.SVMXC__Help_URL__c = System.label.SFM002_HLPURL; 
                if(SaveType == 'SAVEAS')
                {
                    HeaderLayout = WrapperheaderLayout.clone(false,true);
                    HeaderLayout.SVMXC__IsStandard__c = false;
                    List<SVMXC__Page_Layout__c> Pagelist = [select id,SVMXC__Page_Layout_ID__c,SVMXC__Type__c from SVMXC__Page_Layout__c where SVMXC__Type__c = 'Header'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
                    if(WrapperheaderLayout.id != null)
                    {
                        List<SVMXC__Page_Layout__c> Pagelist = [select id,SVMXC__Page_Layout_ID__c,SVMXC__Type__c from SVMXC__Page_Layout__c where SVMXC__Type__c = 'Header' and id !=: WrapperheaderLayout.id];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        if(Pagelist.size() > 0 )
                        {
                            for(SVMXC__Page_Layout__c p: Pagelist)
                            {
                                if(p.SVMXC__Page_Layout_ID__c == WrapperheaderLayout.SVMXC__Page_Layout_ID__c)
                                {
                                    response.success = false;
                                    response.message = system.label.SFM001_TAG094;
                                    return response;
                                }
                            }
                        }
                    }   
                    HeaderLayout = WrapperheaderLayout; 
                }
                upsert HeaderLayout;
                if(HeaderLayout.id != null)
                    HeaderId = HeaderLayout.id; 
            }
            system.debug('HeaderId'+HeaderId);
            if(HeaderId != null && HeaderId.length() > 0)
            {
                SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
                List<String> valueList = new List<String>();
                valueList.add(HeaderId);
                String key = 'RECORDID';
                INTF_WebServicesDef.INTF_StringListMap stringListMap = new INTF_WebServicesDef.INTF_StringListMap(key,valueList);
                List<INTF_WebServicesDef.INTF_StringListMap> lst = new List<INTF_WebServicesDef.INTF_StringListMap> ();
                lst.add(stringListMap);
                INTF_WebServicesDef.INTF_StringListMap stringListMap1 = new INTF_WebServicesDef.INTF_StringListMap('PARTIALDELETE',null);
                lst.add(stringListMap1);
                request.stringListMap = lst;
                INTF_DeletePageLayout DeleteLayout = new  INTF_DeletePageLayout();
                system.debug('request'+request);
                DeleteLayout.INTF_DeletePageLayout(request);
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
            Map<Integer,List<SVMXC.INTF_WebServicesDef.INTF_UIField>> UIfieldMap = new Map<Integer,List<SVMXC.INTF_WebServicesDef.INTF_UIField>>();
            Map<Integer,SVMXC__Page_Layout_Detail__c> SectionMap = new Map<Integer,SVMXC__Page_Layout_Detail__c>();
            Map<String,List<SVMXC.INTF_WebServicesDef.INTF_UIField>> SectionIdFieldMap = new Map<String,List<SVMXC.INTF_WebServicesDef.INTF_UIField>>();
            if(UISectionLst.size() > 0)
            {
                for(Integer i = 0; i < UISectionLst.size(); i++)
                {
                    SVMXC.INTF_WebServicesDef.INTF_UISection UISection = new SVMXC.INTF_WebServicesDef.INTF_UISection();//To take one section at a time
                    UISection = UISectionLst[i];//One Class of SFM_UISection
                    if(UISection.sectionDetail != null)
                    {
                        SectionMap.put(i,UISection.sectionDetail);//Map of Interger/SectionDetail
                    }   
                    if(UISection.fields != null)
                    {   
                        UIfieldMap.put(i,UISection.fields);//Map of Interger/List of SFM_UIField class
                    }   
                }
            }
            system.debug('UIfieldMap'+UIfieldMap);
            system.debug('SectionMap'+SectionMap);  
            List<SVMXC__Page_Layout_Detail__c> SaveSectionLst = new List<SVMXC__Page_Layout_Detail__c>();
            if(SectionMap.size() > 0)
            {
                for(Integer i : SectionMap.keySet())
                {
                    SVMXC__Page_Layout_Detail__c PLD = new SVMXC__Page_Layout_Detail__c();
                    if(SectionMap.containskey(i) && SectionMap.get(i) != null)
                    {
                        PLD = SectionMap.get(i);
                        PLD.SVMXC__Page_Layout__c = HeaderLayout.id;
                        PLD.SVMXC__Detail_Type__c = 'Section';
                        SaveSectionLst.add(PLD);
                    }   
                }
            }
            system.debug('SaveSectionLst'+SaveSectionLst);
            //insert the sections of header layout..
            if(SaveSectionLst.size() > 0)
            {   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                insert SaveSectionLst;//insert Header Sections  
            }
            //make a map of section's id and List<SFM_UIField> wrapper class
            Map<Integer,String> SectionIDMap = new Map<Integer,String>();//for SectionId/Number map
            for(Integer i :UIfieldMap.keyset())
            {
                for(Integer j :SectionMap.keyset())
                {
                    if(i == j)
                    {
                        if(UIfieldMap.containskey(i) && UIfieldMap.get(i) != null)
                            SectionIdFieldMap.put(SaveSectionLst[i].id,UIfieldMap.get(i));
                        SectionIDMap.put(i,SaveSectionLst[i].id);
                    }
                }
            }
            system.debug('SectionIdFieldMap'+SectionIdFieldMap);
            system.debug('SectionIDMap'+SectionIDMap);
            // Break the SFM_UIField wrapper calss..
            
            Map<String,List<SVMXC__SFM_Event__c>> HdrEventMap = new Map<String,List<SVMXC__SFM_Event__c>>(); 
            if(UIfieldMap.size() > 0)
            {
                for(Integer i : UIfieldMap.keyset())
                {
                    Map<Integer,SVMXC__Page_Layout_Detail__c> HdrFldmap = new Map<Integer,SVMXC__Page_Layout_Detail__c>();
                    List<SVMXC.INTF_WebServicesDef.INTF_UIField> TempUIFieldLst = new List<SVMXC.INTF_WebServicesDef.INTF_UIField>();
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
                                Tempfld.SVMXC__Detail_Type__c = 'Field';
                                Tempfld.SVMXC__Page_Layout__c = HeaderLayout.id;
                                if(Tempfld.SVMXC__Related_Object_Name__c != null && (Tempfld.SVMXC__Related_Object_Name__c == 'Group,User' || Tempfld.SVMXC__Related_Object_Name__c == 'User,Group'))
                                    Tempfld.SVMXC__Related_Object_Name__c = 'User';
                                HdrFldmap.put(j,Tempfld);
                            }
                        }   
                        system.debug('HdrFldmap'+HdrFldmap);
                        List<SVMXC__Page_Layout_Detail__c> HdrSaveFldLst = new List<SVMXC__Page_Layout_Detail__c>();
                        if(HdrFldmap.size() > 0)
                        {
                            HdrSaveFldLst = HdrFldmap.values();
                            if(HdrSaveFldLst.size() > 0)
                            {
                                for(Integer a = 0;a<HdrSaveFldLst.size();a++)
                                {
                                    if(HdrSaveFldLst[a].SVMXC__Related_Object_Name__c != null && HdrSaveFldLst[a].SVMXC__DataType__c.touppercase() == 'REFERENCE' && Allobj.containskey(HdrSaveFldLst[a].SVMXC__Related_Object_Name__c))
                                    {
                                        if(Allobj.get(HdrSaveFldLst[a].SVMXC__Related_Object_Name__c) == Account.SObjectType)
                                            HdrSaveFldLst[a].SVMXC__Related_Object_Name_Field__c ='Name';
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
                                insert HdrSaveFldLst; //insert Fields     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
                    insert SaveHdrBtns;   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
            //insert All Header Events...
            if(SaveAllHdrEvents.size() > 0)
            {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(SaveAllHdrEvents, COMM_SecurityUtils.Access.Createable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    insert SaveAllHdrEvents; //insert All header Events
                }
            }
            //Strat Processing the Page Details....
            List<SVMXC__Page_Layout__c> WrapperAllDetailLayouts = new List<SVMXC__Page_Layout__c>();
            List<SVMXC__Page_Layout__c> AllDetailLayouts = new List<SVMXC__Page_Layout__c>();
            List<SVMXC__SFM_Event__c> SaveAllDetailEvents = new List<SVMXC__SFM_Event__c>();
            Map<Integer,List<SVMXC.INTF_WebServicesDef.INTF_UIField>> DetailUIFieldsMap = new Map<Integer,List<SVMXC.INTF_WebServicesDef.INTF_UIField>>();
            Map<Integer,List<SVMXC.INTF_WebServicesDef.INTF_UIButton>> DetailUIBtnsMap = new Map<Integer,List<SVMXC.INTF_WebServicesDef.INTF_UIButton>>();
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
                    List<SVMXC.INTF_WebServicesDef.INTF_UIField> TempUIFld  = new List<SVMXC.INTF_WebServicesDef.INTF_UIField>();
                    List<SVMXC.INTF_WebServicesDef.INTF_UIButton> TempUIBtn  = new List<SVMXC.INTF_WebServicesDef.INTF_UIButton>();
                    if(PageDetails[i].DetailLayout != null)
                    {
                        templayout = PageDetails[i].DetailLayout;
                        templayout.SVMXC__Header_Page_Layout__c = HeaderLayout.id;
                        templayout.SVMXC__Type__c = 'Detail';
                        templayout.SVMXC__Page_Detail_UniqueId__c = null; //to maintain seed uniqnees we will not use this field while creating new detail object record.
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
                upsert AllDetailLayouts;   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            system.debug('AllDetailLayouts'+AllDetailLayouts.size()+AllDetailLayouts);
            Map<Integer,SVMXC__Page_Layout_Detail__c> DetailFldmap = new Map<Integer,SVMXC__Page_Layout_Detail__c>();
            Map<String,List<SVMXC__SFM_Event__c>> DetailEventMap = new Map<String,List<SVMXC__SFM_Event__c>>();
            if(DetailUIFieldsMap.size()>0) 
            {
                for(Integer i : DetailUIFieldsMap.keyset())
                {
                    system.debug('amar'+i+' '+AllDetailLayouts[i].id);
                    String DetailID = AllDetailLayouts[i].id;
                    system.debug('DetailID'+DetailID);
                    List<SVMXC.INTF_WebServicesDef.INTF_UIField> TempUIFld  = new List<SVMXC.INTF_WebServicesDef.INTF_UIField>();
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
                                        DetailSaveFldLst[a].SVMXC__Related_Object_Name_Field__c ='Name';
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
                            insert DetailSaveFldLst;//insert the Detail fields      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
                    List<SVMXC.INTF_WebServicesDef.INTF_UIButton> TempUIBtn  = new List<SVMXC.INTF_WebServicesDef.INTF_UIButton>();
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
                                insert SaveDetailBtns;//insert the Buttons  for Datail layout   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
            
            if(SaveAllDetailEvents.size() > 0)
            {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(SaveAllDetailEvents, COMM_SecurityUtils.Access.Createable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    insert SaveAllDetailEvents;
                }
            }
            response.success = true;
            //response.message = 'Saved Successfully';
            //response.message = system.Label.SFM001_TAG184;
            List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringMapList = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            if(HeaderLayout.id != null)
            {
                SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                strmap.key = 'HEADER';
                strmap.value = string.valueof(HeaderLayout.id);
                if(strmap != null)
                    stringMapList.add(strmap);
            }
            if(AllDetailLayouts.size() > 0)
            {
                for(SVMXC__Page_Layout__c PL:AllDetailLayouts)
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
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
            Database.rollback(sp);
            response.success = false;
            //response.message = 'Record Not Saved' + ex.getmessage() ;
            //response.message = system.Label.SFM001_TAG185 + ex.getmessage() ;
        }   
        return response;
    }
}