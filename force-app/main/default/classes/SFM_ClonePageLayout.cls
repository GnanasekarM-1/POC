/* Security Scanned */
public with sharing class SFM_ClonePageLayout 
{
    
    
    public SVMXC.SFM_WrapperDef.SFM_Response_PageUI clonePageLayout(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        String strProcessId = '';
        if(request != null && request.stringMap != null && request.stringMap.size() >0){
            for(integer i = 0;i<request.stringMap.size();i++){
                if(request.stringMap[i].key.equals('PROCESSIDFORCLONE'))
                    strProcessId = request.stringMap[i].value;
            }
        }
        map<Id,String> mapPagelayouIdAliasName = new map<Id,String>();
        if(strProcessId != null && strProcessId.length() > 0){
        
            list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObj = [select Id,SVMXC__Page_Layout__c,SVMXC__Target_Object_label__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: strProcessId and RecordType.Name = 'Process Node Objects' and SVMXC__Page_Layout__c != null and SVMXC__Target_Object_label__c != null]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstProcessNodeObj.size() > 0){
                for(SVMXC__ServiceMax_Processes__c pro : lstProcessNodeObj){
                    if(pro.SVMXC__Page_Layout__c != null && pro.SVMXC__Target_Object_label__c != null){
                        mapPagelayouIdAliasName.put(pro.SVMXC__Page_Layout__c,pro.SVMXC__Target_Object_label__c);
                    }
                }
            }
        }
        system.debug('mapPagelayouIdAliasName'+mapPagelayouIdAliasName);    
        SVMXC.SFM_WrapperDef.SFM_Request_PageUI pageRequest = new SVMXC.SFM_WrapperDef.SFM_Request_PageUI();
        SVMXC.SFM_WrapperDef.SFM_Response_PageUI pageResponse = new SVMXC.SFM_WrapperDef.SFM_Response_PageUI();
        SVMXC.SFM_WrapperDef.SFM_PageUI page = new SVMXC.SFM_WrapperDef.SFM_PageUI();
        pageRequest.request = request;
        SVMXC.SFM_GetPageLayout callpage = new SVMXC.SFM_GetPageLayout();
        pageResponse = callpage.SFM_GetPageLayout(pageRequest);
        page = pageResponse.page;
        //Get Header Page layout detail and clone it first.
        page.header.headerLayout = page.header.headerLayout.clone(false,true);
        page.header.headerLayout.SVMXC__IsStandard__c = false;
        list<SVMXC__SFM_Event__c> pageEvents = new list<SVMXC__SFM_Event__c>();
        list<SVMXC.SFM_WrapperDef.SFM_UISection> sections = new list<SVMXC.SFM_WrapperDef.SFM_UISection>();
        list<SVMXC.SFM_WrapperDef.SFM_UIButton> buttons = new list<SVMXC.SFM_WrapperDef.SFM_UIButton>();
        //Get Section, Button, Page Events
        sections = page.header.sections;
        buttons = page.header.buttons;
        pageEvents = page.header.pageEvents;
        //Clone Page Events and assign them.
        if(pageEvents.size() > 0){
            page.header.pageEvents = cloneEvents(pageEvents);
        }
        //Clone Sections and assign them.
        if(sections.size() > 0)
        {
            list<SVMXC.SFM_WrapperDef.SFM_UISection> clonedSections = new list<SVMXC.SFM_WrapperDef.SFM_UISection>();
            for(Integer i = 0;i<sections.size();i++)
            {
                sections[i].sectionDetail = sections[i].sectionDetail.clone(false,true); 
                sections[i].sectionDetail.SVMXC__IsStandard__c = false;
                if(sections[i].fields.size() > 0)
                    sections[i].fields = cloneFields(sections[i].fields);
                clonedSections.add(sections[i]);
            }
            page.header.sections = clonedSections;
        }
        //Clone buttons and assign them.
        if(buttons.size() > 0)
            page.header.buttons = cloneButtons(buttons);
        
        //Now do for page layout details(Tabs).
        list<SVMXC.SFM_WrapperDef.SFM_PageDetail> pageDetails = new list<SVMXC.SFM_WrapperDef.SFM_PageDetail>();
        pageDetails = page.details;
        if(pageDetails.size() > 0)
        {
            list<SVMXC.SFM_WrapperDef.SFM_PageDetail> clonedPageDetails = new list<SVMXC.SFM_WrapperDef.SFM_PageDetail>();
            for(Integer i = 0;i<pageDetails.size();i++)
            {
                Id pageLayouId = pageDetails[i].DetailLayout.id;
                pageDetails[i].DetailLayout = pageDetails[i].DetailLayout.clone(false,true); 
                pageDetails[i].DetailLayout.SVMXC__IsStandard__c = false;
                if(mapPagelayouIdAliasName.containskey(pageLayouId))
                    pageDetails[i].DetailLayout.SVMXC__Page_Layout_ID__c = mapPagelayouIdAliasName.get(pageLayouId);
                if(pageDetails[i].buttons.size() > 0)
                    pageDetails[i].buttons = cloneButtons(pageDetails[i].buttons);
                if(pageDetails[i].fields.size() > 0)
                    pageDetails[i].fields = cloneFields(pageDetails[i].fields);
                if(pageDetails[i].events.size() > 0){
                    pageDetails[i].events = cloneEvents(pageDetails[i].events);
                }   
                clonedPageDetails.add(pageDetails[i]);
            }
            page.details = clonedPageDetails;
        }
        pageResponse.page = page;
        return pageResponse;
    }
    
    public list<SVMXC.SFM_WrapperDef.SFM_UIButton> cloneButtons(list<SVMXC.SFM_WrapperDef.SFM_UIButton> lstButton)
    {
        list<SVMXC.SFM_WrapperDef.SFM_UIButton> lstClonedButtons = new list<SVMXC.SFM_WrapperDef.SFM_UIButton>();
        for(integer i = 0;i<lstButton.size();i++)
        {
            lstButton[i].buttonDetail = lstButton[i].buttonDetail.clone(false,true);
            lstButton[i].buttonDetail.SVMXC__IsStandard__c = false;
            if(lstButton[i].buttonEvents.size() > 0){
                lstButton[i].buttonEvents = cloneEvents(lstButton[i].buttonEvents);
            }
            lstClonedButtons.add(lstButton[i]); 
        }
        return lstClonedButtons;
    }
    public list<SVMXC.SFM_WrapperDef.SFM_UIField> cloneFields(list<SVMXC.SFM_WrapperDef.SFM_UIField> lstfield)
    {
        list<SVMXC.SFM_WrapperDef.SFM_UIField> lstClonedfleds = new list<SVMXC.SFM_WrapperDef.SFM_UIField>();
        for(Integer j = 0;j<lstfield.size();j++)
        {
            lstfield[j].fieldDetail = lstfield[j].fieldDetail.clone(false,true); 
            lstfield[j].fieldDetail.SVMXC__IsStandard__c = false;
            if(lstfield[j].fieldEvents.size() > 0){
                lstfield[j].fieldEvents = cloneEvents(lstfield[j].fieldEvents);
            }
            lstClonedfleds.add(lstfield[j]);
        }
        return lstClonedfleds;
    }
    
    public list<SVMXC__SFM_Event__c> cloneEvents(list<SVMXC__SFM_Event__c> events){
        list<SVMXC__SFM_Event__c> clonedEvents = new list<SVMXC__SFM_Event__c>();
        for(SVMXC__SFM_Event__c evt : events){
            SVMXC__SFM_Event__c clonedEvent = new SVMXC__SFM_Event__c();
            clonedEvent = evt.clone(false,true);
            clonedEvent.SVMXC__IsStandard__c = false;
            clonedEvents.add(clonedEvent);
        }
        return clonedEvents;
    }
}