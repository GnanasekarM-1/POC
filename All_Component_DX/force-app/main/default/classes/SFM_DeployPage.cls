/* Security Scanned */
public with sharing class SFM_DeployPage {
  Boolean isSucess = TRUE;
  SVMX_Debug log = new SVMX_Debug();
  SFM_Utils utils = new SFM_Utils();
  List<SFM_WrapperDef.SFM_StringMap> sourceTargetPageId = new List<SFM_WrapperDef.SFM_StringMap>();
  List<SFM_WrapperDef.SFM_StringMap> sourceTargetPagerelatedListId = new List<SFM_WrapperDef.SFM_StringMap>();
  
  public SFM_DeployPage()
  {
    }
    
  public SFM_WrapperDef.SFM_Response SFM_DeployPage(SFM_WrapperDef.SFM_Request_PageUI request)
  {
    SFM_WrapperDef.SFM_Response oResponse=new SFM_WrapperDef.SFM_Response();
    Map<String, SVMXC__Page_Layout__c> mapPageHeader = new Map<String, SVMXC__Page_Layout__c>();
    
    Set<String> requestedName = new Set<String>();
    Set<String> existingPageName = new Set<String>();
    List<String> createdPageName = new List<String>();
    Map<String,String> mapRequest = new Map<String,String>();
        mapRequest = utils.getStringMap(request.request.stringMap);
        
        // log.login('SFM_DeployPage', 'SFM_DeployPage\n');
    Savepoint sp = Database.setSavepoint();//Setting up save point
    try
        {
          Map<String, SVMXC__Page_Layout_Detail__c> mapSection = new Map<String, SVMXC__Page_Layout_Detail__c>();
          Map<String, list<SFM_WrapperDef.SFM_UIField>> mapSectionDetails = new Map<String, list<SFM_WrapperDef.SFM_UIField>>();
          Map<String, SVMXC__Page_Layout__c> mapRelatedList = new Map<String, SVMXC__Page_Layout__c>();
          Map<String, list<SFM_WrapperDef.SFM_UIField>> mapRelatedListDetails = new Map<String, list<SFM_WrapperDef.SFM_UIField>>();
          
          SFM_WrapperDef.SFM_PageUI pageDefinition = request.page;
          SFM_WrapperDef.SFM_PageHeader objPageHeaderDef = pageDefinition.header;
          SVMXC__Page_Layout__c objPageHeader = pageDefinition.header.headerLayout;
          List<SVMXC__SFM_Event__c> pageEvent = pageDefinition.header.pageEvents;
          requestedName.add(objPageHeader.SVMXC__Page_Layout_ID__c);
          // Populate all section definitions along with fields
      for(SFM_WrapperDef.SFM_UISection sectionDef: objPageHeaderDef.sections)
      {
        list<SFM_WrapperDef.SFM_UIField> lstFields = new list<SFM_WrapperDef.SFM_UIField>();
        if(sectionDef.fields != NULL)
        for(SFM_WrapperDef.SFM_UIField fieldDef: sectionDef.fields)
        {
          lstFields.add(fieldDef);
        }
        mapSection.put(String.valueOf(sectionDef.sectionDetail.SVMXC__Sequence__c), sectionDef.sectionDetail);
        mapSectionDetails.put(String.valueOf(sectionDef.sectionDetail.SVMXC__Sequence__c), lstFields);
      }
      
      // Populate the realted list definitions
      if(pageDefinition.details != NULL)
      for(SFM_WrapperDef.SFM_PageDetail relatedListDef: pageDefinition.details)
      {
        mapRelatedList.put(relatedListDef.DetailLayout.SVMXC__Page_Layout_ID__c, relatedListDef.DetailLayout);
        list<SFM_WrapperDef.SFM_UIField> lstFields = new list<SFM_WrapperDef.SFM_UIField>();
        if(relatedListDef.fields != NULL)
        {
          for(SFM_WrapperDef.SFM_UIField fieldDef: relatedListDef.fields)
          {
            lstFields.add(fieldDef);
          }
          mapRelatedListDetails.put(relatedListDef.DetailLayout.SVMXC__Page_Layout_ID__c, lstFields);
        }
      }
      
      List<SVMXC__Page_Layout__c> lstavailablePageHeader = new List<SVMXC__Page_Layout__c>();
      SVMXC__Page_Layout__c availablePageHeader = new SVMXC__Page_Layout__c();
      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
      lstavailablePageHeader = [SELECT Id, SVMXC__IsStandard__c, SVMXC__Page_Layout_ID__c,SVMXC__Type__c, SVMXC__Object_Name__c From SVMXC__Page_Layout__c where SVMXC__Page_Layout_ID__c = :objPageHeader.SVMXC__Page_Layout_ID__c limit 1];
      
      if(lstavailablePageHeader != NULL && lstavailablePageHeader.size() > 0)
        availablePageHeader = lstavailablePageHeader[0];
      if(availablePageHeader.SVMXC__Page_Layout_ID__c != NULL)
      {
        String sourcePageId = objPageHeader.SVMXC__Installation_Key__c;
        sourceTargetPageId.add(new SFM_WrapperDef.SFM_StringMap(sourcePageId, availablePageHeader.Id));
        // Data already available, check for object definition and push only expression details
        existingPageName.add(availablePageHeader.SVMXC__Page_Layout_ID__c);
        
        // If this is standard expression donot insert the records but set up the Id in response
        if(availablePageHeader.SVMXC__IsStandard__c == true)
        {
          log.setlog('INFO', system.label.CONF019_TAG043 + ' ' + availablePageHeader.SVMXC__Page_Layout_ID__c);
          getSourceTargetPagerelatedListId(availablePageHeader.Id);
          log.setlog('FINE', system.label.CONF019_TAG044);
          // Just skip processing
        }
        else
        {
          log.setlog('INFO', system.label.CONF019_TAG045 + ' ' + availablePageHeader.SVMXC__Page_Layout_ID__c);
          // Check whether both named expressions are associate with same definitions
          if(availablePageHeader.SVMXC__Object_Name__c == objPageHeader.SVMXC__Object_Name__c)
          {
            
            // Update the page header details
            if(objPageHeader.SVMXC__Allow_Delete_Lines__c != NULL)
              availablePageHeader.SVMXC__Allow_Delete_Lines__c = objPageHeader.SVMXC__Allow_Delete_Lines__c;
            if(objPageHeader.SVMXC__Allow_New_Lines__c != NULL)
              availablePageHeader.SVMXC__Allow_New_Lines__c = objPageHeader.SVMXC__Allow_New_Lines__c;
            if(objPageHeader.SVMXC__Enable_Attachments__c != NULL)
              availablePageHeader.SVMXC__Enable_Attachments__c = objPageHeader.SVMXC__Enable_Attachments__c;
            if(objPageHeader.SVMXC__Help_URL__c != NULL)
              availablePageHeader.SVMXC__Help_URL__c = objPageHeader.SVMXC__Help_URL__c;
            if(objPageHeader.SVMXC__Name__c != NULL)
              availablePageHeader.SVMXC__Name__c = objPageHeader.SVMXC__Name__c;
            if(objPageHeader.SVMXC__Object_Name__c != NULL)
              availablePageHeader.SVMXC__Object_Name__c = objPageHeader.SVMXC__Object_Name__c;
            if(objPageHeader.SVMXC__Page_Help__c != NULL)
              availablePageHeader.SVMXC__Page_Help__c = objPageHeader.SVMXC__Page_Help__c;
            if(objPageHeader.SVMXC__Prompt_For_New_Event__c != NULL)
              availablePageHeader.SVMXC__Prompt_For_New_Event__c = objPageHeader.SVMXC__Prompt_For_New_Event__c;
            if(objPageHeader.SVMXC__Show_Account_History__c != NULL)
              availablePageHeader.SVMXC__Show_Account_History__c = objPageHeader.SVMXC__Show_Account_History__c;
            if(objPageHeader.SVMXC__Show_All_Sections_By_Default__c != NULL)
              availablePageHeader.SVMXC__Show_All_Sections_By_Default__c = objPageHeader.SVMXC__Show_All_Sections_By_Default__c;
            if(objPageHeader.SVMXC__Show_Product_History__c != NULL)
              availablePageHeader.SVMXC__Show_Product_History__c = objPageHeader.SVMXC__Show_Product_History__c;
            if(objPageHeader.SVMXC__Type__c != NULL)
              availablePageHeader.SVMXC__Type__c = objPageHeader.SVMXC__Type__c;
            if(objPageHeader.SVMXC__Enable_Chatter__c != NULL)
              availablePageHeader.SVMXC__Enable_Chatter__c = objPageHeader.SVMXC__Enable_Chatter__c;

            //update availablePageHeader;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(availablePageHeader, COMM_SecurityUtils.Access.Updateable)){
              update availablePageHeader;
            }
            else{
              Database.rollback(sp);
              oResponse.success = false;
              oResponse.message = System.label.COMM001_TAG142;
              return oResponse;
            }
            
            // Delete page level events and field level events
            List<SVMXC__SFM_Event__c> lstExistingPageEvents = [Select Id from SVMXC__SFM_Event__c where SVMXC__Page_Layout__c = : availablePageHeader.Id];
      
            // Delete page details
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__Page_Layout_Detail__c> lstExistingPageLayoutDetails = [Select Id From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c = :availablePageHeader.Id];
            if(lstExistingPageLayoutDetails.size()>0)
            {
              set<Id> pageDetailId = new set<Id>();
              for(SVMXC__Page_Layout_Detail__c detail: lstExistingPageLayoutDetails)
              {
                pageDetailId.add(detail.Id);
              }
              List<SVMXC__SFM_Event__c> lstExistingPageDetailEvents = [Select Id from SVMXC__SFM_Event__c where SVMXC__Page_Layout_Detail__c IN : pageDetailId];
              lstExistingPageEvents.addAll(lstExistingPageDetailEvents);
              //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
              delete lstExistingPageLayoutDetails;
            }
            
            // Delete page layout relatedlist details
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__Page_Layout__c> lstExistingPageLayoutrelatedList = [Select Id From SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c = :availablePageHeader.Id];
            if(lstExistingPageLayoutrelatedList.size()>0)
            {
              set<Id> pageDetailId = new set<Id>();
              for(SVMXC__Page_Layout__c detailPage: lstExistingPageLayoutrelatedList)
              {
                pageDetailId.add(detailPage.Id);
              }
              List<SVMXC__Page_Layout_Detail__c> lstExistingPageLayoutDetailsDetails = [Select Id From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN :pageDetailId];
              if(lstExistingPageLayoutrelatedList.size()>0)
              {
                set<Id> detailPageDetailId = new set<Id>();
                for(SVMXC__Page_Layout_Detail__c detailPage: lstExistingPageLayoutDetailsDetails)
                {
                  detailPageDetailId.add(detailPage.Id);
                }
                List<SVMXC__SFM_Event__c> lstExistingPageDetailEvents = [Select Id from SVMXC__SFM_Event__c where SVMXC__Page_Layout_Detail__c IN : detailPageDetailId];
                lstExistingPageEvents.addAll(lstExistingPageDetailEvents);
              }
              //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
              delete lstExistingPageLayoutrelatedList;
            }
            // Delete events related to page
            if(lstExistingPageEvents != NULL && lstExistingPageEvents.size() > 0){
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SFM_Event__c' ) ) {  
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete lstExistingPageEvents;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
              
              
            SFM_DeployPageDetails(availablePageHeader.Id, pageEvent, mapSection, mapSectionDetails, mapRelatedList, mapRelatedListDetails, objPageHeaderDef.buttons);
          }
          else
          {
            isSucess = FALSE;
            log.setlog('ERROR', system.label.CONF019_TAG046 + ' ' + availablePageHeader.SVMXC__Page_Layout_ID__c);
            log.setlog('ERROR', system.label.CONF019_TAG032 + ' ' + objPageHeader.SVMXC__Object_Name__c);
            log.setlog('ERROR', system.label.CONF019_TAG033 + ' ' + availablePageHeader.SVMXC__Object_Name__c);
          }
        }
      }
      
      // If data not available in org create both header and expression details
      else
      {
        createdPageName.add(objPageHeader.SVMXC__Page_Layout_ID__c);
        log.setlog('INFO', system.label.CONF019_TAG047 + objPageHeader.SVMXC__Page_Layout_ID__c);
        SFM_DeployPage(objPageHeader, pageEvent, mapSection, mapSectionDetails, mapRelatedList, mapRelatedListDetails, objPageHeaderDef.buttons);
      }
        }
    catch (DmlException ex)
        {
          log.setlog('ERROR', ex.getDmlMessage(0));
            //log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);
            isSucess = false;
            oResponse.message = ex.getDmlMessage(0);
      }
        catch (Exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            //log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            isSucess = false;
            oResponse.message = ex.getmessage();
        }
        
        // log.logout();
        // Setup collective data
        List<String> requestedPage = new List<String>();
        List<String> existingPage = new List<String>();
        requestedPage.addAll(requestedName);
        existingPage.addAll(existingPageName);
    oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('REQUEST', requestedPage));
    oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('DEPLOYED_EXISTING', existingPage));
    oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('DEPLOYED', createdPageName));
    oResponse.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('SOURCETARGETPAGEIDS', sourceTargetPageId));
    oResponse.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('SOURCETARGETPAGERELATEDLISTIDS', sourceTargetPagerelatedListId));
    oResponse.resultIds.add(mapRequest.get('PROCESSID'));
    oResponse.logMsg = log.getlog();
    oResponse.success = isSucess;
    return oResponse;
  }
  
  void SFM_DeployPage(SVMXC__Page_Layout__c pageLayout, List<SVMXC__SFM_Event__c> pageEvents, Map<String, SVMXC__Page_Layout_Detail__c> mapSection, Map<String, list<SFM_WrapperDef.SFM_UIField>> mapSectionDetails, Map<String, SVMXC__Page_Layout__c> mapRelatedList, Map<String, list<SFM_WrapperDef.SFM_UIField>> mapPageRelatedListDetails, list<SFM_WrapperDef.SFM_UIButton> lstButtonDetails)
  {
    String sourcePageId = pageLayout.SVMXC__Installation_Key__c;
    pageLayout.SVMXC__Installation_Key__c = '';
    insert pageLayout;
    
    
    sourceTargetPageId.add(new SFM_WrapperDef.SFM_StringMap(sourcePageId, pageLayout.Id));
    SFM_DeployPageDetails(pageLayout.Id, pageEvents, mapSection, mapSectionDetails, mapRelatedList, mapPageRelatedListDetails, lstButtonDetails);
  }
  void SFM_DeployPageDetails(Id pageLayoutId, List<SVMXC__SFM_Event__c> pageEvents, Map<String, SVMXC__Page_Layout_Detail__c> mapSection, Map<String, list<SFM_WrapperDef.SFM_UIField>> mapSectionDetails, Map<String, SVMXC__Page_Layout__c> mapRelatedList, Map<String, list<SFM_WrapperDef.SFM_UIField>> mapPageRelatedListDetails,list<SFM_WrapperDef.SFM_UIButton> lstButtonDetails)
  {
    List<SVMXC__Page_Layout__c> relatedListDetails = new List<SVMXC__Page_Layout__c>();
    List<SVMXC__Page_Layout_Detail__c> sectionDetails = new List<SVMXC__Page_Layout_Detail__c>();
    List<SVMXC__Page_Layout_Detail__c> fieldDetails = new List<SVMXC__Page_Layout_Detail__c>();
    List<SVMXC__Page_Layout_Detail__c> buttonDetails = new List<SVMXC__Page_Layout_Detail__c>();
    List<SVMXC__SFM_Event__c> eventDetails = new List<SVMXC__SFM_Event__c>();
    
    // Insert page events
    pushPageEvents(pageLayoutId, pageEvents);
    
    // Create sections
    for(SVMXC__Page_Layout_Detail__c sectionDef: mapSection.values())
    {
      sectionDef.SVMXC__Page_Layout__c = pageLayoutId;
      mapSection.put(String.valueOf(sectionDef.SVMXC__Sequence__c), sectionDef);
      sectionDetails.add(sectionDef);
    }
    insert mapSection.values();
    
    // Create realated list header
    for(SVMXC__Page_Layout__c detailDef: mapRelatedList.values())
    {
      detailDef.SVMXC__Header_Page_Layout__c = pageLayoutId;
      mapRelatedList.put(detailDef.SVMXC__Page_Layout_ID__c, detailDef);
      relatedListDetails.add(detailDef);
    }
    insert mapRelatedList.values();
    
    for(SVMXC__Page_Layout__c detailDef: mapRelatedList.values())
    {
      sourceTargetPagerelatedListId.add(new SFM_WrapperDef.SFM_StringMap(detailDef.SVMXC__Page_Layout_ID__c, detailDef.Id));
    }
    // Create fields
    Map<String, List<SVMXC__SFM_Event__c>> mapSequenceFieldEvents = new Map<String, List<SVMXC__SFM_Event__c>>();
    for(String sectionDef: mapSectionDetails.keySet())
    {
      for(SFM_WrapperDef.SFM_UIField fieldDef : mapSectionDetails.get(sectionDef))
      {
        SVMXC__Page_Layout_Detail__c pageDetail = fieldDef.fieldDetail;
        // If field sequence exist, put events in that sequence
        if(fieldDef.fieldEvents != NULL && pageDetail.SVMXC__Sequence__c != NULL)
          mapSequenceFieldEvents.put(mapSection.get(sectionDef).Id + String.valueOf(pageDetail.SVMXC__Sequence__c), fieldDef.fieldEvents);
        
        pageDetail.SVMXC__Page_Layout__c = pageLayoutId;
        pageDetail.SVMXC__Section__c = mapSection.get(sectionDef).Id;
        fieldDetails.add(pageDetail);
      }
    }
    
    // Setting up buttons
    for(String relatedListDef: mapPageRelatedListDetails.keySet())
    {
      for(SFM_WrapperDef.SFM_UIField fieldDef : mapPageRelatedListDetails.get(relatedListDef))
      {
        SVMXC__Page_Layout_Detail__c pageDetail = fieldDef.fieldDetail;
        // If field sequence exist, put events in that sequence
        if(fieldDef.fieldEvents != NULL && pageDetail.SVMXC__Sequence__c != NULL)
          mapSequenceFieldEvents.put(mapRelatedList.get(relatedListDef).Id + String.valueOf(pageDetail.SVMXC__Sequence__c), fieldDef.fieldEvents);
        
        pageDetail.SVMXC__Page_Layout__c = mapRelatedList.get(relatedListDef).Id;
        fieldDetails.add(pageDetail);
      }
    }
    insert fieldDetails;
    
    // Find and push field level events
    if(mapSequenceFieldEvents != NULL)
    {
      List<SVMXC__SFM_Event__c> fieldEvents = new List<SVMXC__SFM_Event__c>();
      for(SVMXC__Page_Layout_Detail__c field: fieldDetails)
      {
        // If sections will be available only for fields under page layout, not with fields under detail layout
        if(field.SVMXC__Section__c != NULL)
        {
          if(mapSequenceFieldEvents.get(field.SVMXC__Section__c + String.valueOf(field.SVMXC__Sequence__c)) != NULL)
          {
            List<SVMXC__SFM_Event__c> events = mapSequenceFieldEvents.get(field.SVMXC__Section__c + String.valueOf(field.SVMXC__Sequence__c));
            for(SVMXC__SFM_Event__c event: events)
            {
              event.SVMXC__Page_Layout_Detail__c = field.Id;
              fieldEvents.add(event);
            }
          }
        }
        else
        {
          if(mapSequenceFieldEvents.get(field.SVMXC__Page_Layout__c + String.valueOf(field.SVMXC__Sequence__c)) != NULL)
          {
            List<SVMXC__SFM_Event__c> events = mapSequenceFieldEvents.get(field.SVMXC__Page_Layout__c + String.valueOf(field.SVMXC__Sequence__c));
            for(SVMXC__SFM_Event__c event: events)
            {
              event.SVMXC__Page_Layout_Detail__c = field.Id;
              fieldEvents.add(event);
            }
          }
        }
      }
      system.debug('fieldEvents' + fieldEvents);
      if( COMM_SecurityUtils.getInstance().verifyFieldAccess( fieldEvents, COMM_SecurityUtils.Access.Createable) ) {
             //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            insert fieldEvents;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
      
    }
    
    if(lstButtonDetails != NULL)
    {
      // create buttons and its actions
      for(SFM_WrapperDef.SFM_UIButton ButtonDef: lstButtonDetails)
      {
        ButtonDef.buttonDetail.SVMXC__Page_Layout__c = pageLayoutId;
        buttonDetails.add(ButtonDef.buttonDetail);
      }
      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
      insert buttonDetails;
      
      for(SFM_WrapperDef.SFM_UIButton ButtonDef: lstButtonDetails)
      {
        for(SVMXC__SFM_Event__c event: ButtonDef.buttonEvents)
        {
          event.SVMXC__Page_Layout_Detail__c = ButtonDef.buttonDetail.Id;
          eventDetails.add(event);
        }
      }
      if( COMM_SecurityUtils.getInstance().verifyFieldAccess( eventDetails, COMM_SecurityUtils.Access.Createable) ) {
             //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
             insert eventDetails;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
     
    }
  }
  
  void getSourceTargetPagerelatedListId(String pageId)
  {
    List<SVMXC__Page_Layout__c> relatedListDetails = new List<SVMXC__Page_Layout__c>();
    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    relatedListDetails = [SELECT Id, SVMXC__Page_Layout_ID__c from SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c = : pageId];
    for(SVMXC__Page_Layout__c detailDef: relatedListDetails)
    {
      sourceTargetPagerelatedListId.add(new SFM_WrapperDef.SFM_StringMap(detailDef.SVMXC__Page_Layout_ID__c, detailDef.Id));
    }
  }
  
  void pushPageEvents(String referenceId, List<SVMXC__SFM_Event__c> pageEvents)
  {
    if(pageEvents != NULL)
    {
      for(SVMXC__SFM_Event__c event: pageEvents)
      {
        event.SVMXC__Page_Layout__c = referenceId;
      }
      if( COMM_SecurityUtils.getInstance().verifyFieldAccess( pageEvents, COMM_SecurityUtils.Access.Createable) ) {
             //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
             insert pageEvents;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
      
    }
  }
  
}