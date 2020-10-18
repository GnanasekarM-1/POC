@isTest (SeeAllData=true)
private class OPDOC_DeliveryImpl_UT {

    static OPDOC_DeliveryImpl docDelivary = new OPDOC_DeliveryImpl();
    static SVMXC__ServiceMax_Processes__c processNode;
    static SVMXC__Doc_Template__c docTemplate;
    static SVMXC__Doc_Template_Details__c docTemplateDetailHeader;
    static SVMXC__Doc_Template_Details__c docTemplateDetailChild;
    static SVMXC__ServiceMax_Processes__c processNodeTarget;
    static SVMXC__ServiceMax_Processes__c processNodeTargetChild;
    static SVMXC__Service_Order__c wo;
    static String document;
    static String attachmentId;
  //test
  static SVMXC__ServiceMax_Processes__c chtargetproc;
  static SVMXC__ServiceMax_Processes__c chtargetproc1;
  static SVMXC__ServiceMax_Processes__c chtargetproc2;
  static SVMXC__ServiceMax_Processes__c chtargetproc3;
    static SVMXC__ServiceMax_Processes__c chtargetproc4;
  
  static SVMXC__ServiceMax_Processes__c procbizzrule1;
  static SVMXC__ServiceMax_Processes__c bizzrule;
   
  //test
    static testMethod void deliveryImpl_Test()
    {   
        prepareTestData();
        
        Map<String, String> mapSignatureNameIds = new Map<String, String>();
        mapSignatureNameIds.put('ServiceMaxLogo', '01570000000UAFS');
        String str = 'abcededdadfasdsfasd {<img svmx-data=\"ServiceMaxLogo\" src=\"\">}';
        
        wo = new SVMXC__Service_Order__c();
        insert wo;
        //test
    prepareTestData1();
    //test
        Attachment attach = new Attachment();
        Blob myBlob = Blob.valueof(str);
        attach.Body = myBlob;
        attach.Name = 'OutputDoc';
        attach.IsPrivate = false;
        attach.ParentId = wo.Id;
        insert attach;
        List<String> lstAttIds = new List<String>();
        lstAttIds.add(attach.Id);

        //--Start----Added for the story BAC-3057
        SVMXC__SM_Application_Feature__c objAF = new SVMXC__SM_Application_Feature__c();
        objAF.SVMXC__SM_Feature_Name__c = 'SFM_DESIGNER';
        objAF.SVMXC__SM_Feature_Description__c = 'TEST';
        insert objAF;

        SVMXC__SM_Feature_Permission__c objFP = new SVMXC__SM_Feature_Permission__c();
        objFP.SVMXC__SM_Application_Feature__c = objAF.id;
        objFP.SVMXC__SM_User__c = UserInfo.getUserId();
        insert objFP;
        //--End----Added for the story BAC-3057
        
        Test.startTest();
        try{
        
        docDelivary.offlineSubmitDocuments(lstAttIds, new List<String>());
        docDelivary.offlineCreatePDF(lstAttIds, new List<String>());
        }catch(Exception E) {
        }
        ApexPages.currentPage().getParameters().put('SVMX_recordID', wo.Id);
        ApexPages.currentPage().getParameters().put('SVMX_ProcessID', 'OPDOC001');
        OPDOC_DeliveryImpl.MetadataWrapper objwrapper = new OPDOC_DeliveryImpl.MetadataWrapper('', '', '', '', '', '', '', '', '','');
        
        
        //OPDOC_DeliveryImpl.ReplaceHTMLImagesSrc(str, mapSignatureNameIds);
        OPDOC_Delivery objOPDOCDelivery = new OPDOC_Delivery();
        //objOPDOCDelivery.getIsQualified();
        //objOPDOCDelivery.getErrorMessage();
        //objOPDOCDelivery.getObjectLabel();
        //objOPDOCDelivery.getNameFieldValue();
        //objOPDOCDelivery.getTabStyleLogoURL();
        //objOPDOCDelivery.IsQualified = true;
        //objOPDOCDelivery.getSettings();
        //objOPDOCDelivery.getSfmDeliverySettings();
        //objOPDOCDelivery.getIsLaunchDesignerEnabled(); //Added for the story BAC-3057
        //objOPDOCDelivery.getUrlForLaunchDesigner(); //Added for the story BAC-3057
        try{
            OPDOC_Delivery.JsrDescribeObject('{\"objectName\":\"Account\"}');
        }
        catch(Exception e){}
        
        try{
            OPDOC_Delivery.JsrTargetUpdates('test');
        }
        catch(Exception e){}
        
        try{
            OPDOC_Delivery.JsrGetConfigInfo('{\"processId\" : \"OPDOC001\",\"recordId\" : \"'+ wo.Id +'\"}');
        }
        catch(Exception e){}
        
        OPDOC_Delivery.JsrGetTemplate('{\"ProcessId\" : \"OPDOC001\"}');
        //Coverage for Get template method
        OPDOC_DeliveryImpl.GetTemplateRequest gtr = new OPDOC_DeliveryImpl.GetTemplateRequest();
        gtr.ProcessId = 'OPDOC001';
        OPDOC_DeliveryImpl.GetTemplateResponse gtRes = (OPDOC_DeliveryImpl.GetTemplateResponse)docDelivary.getTemplate(gtr);
        System.assert(gtRes.Template != null && gtRes.Template.length() > 0);
        
        //Coverage for submitDocument
        OPDOC_Delivery.JsrSubmitDocument('{\"Document\" : \"<div data=\'$D.wo.SVMXC__City__c\'>Bangalore</div>\"}');
        OPDOC_DeliveryImpl.SubmitDocumentRequest sdr = new OPDOC_DeliveryImpl.SubmitDocumentRequest();
        sdr.Document = '<div data=\'$D.wo.SVMXC__City__c\'>Bangalore</div> ';
        OPDOC_DeliveryImpl.SubmitDocumentResponse sdRes = (OPDOC_DeliveryImpl.SubmitDocumentResponse)docDelivary.submitDocument(sdr);
        System.assert(sdRes.DocumentId != null && sdRes.DocumentId.length() > 0);
        
        //Coverage for Get Metadata
        OPDOC_Delivery.JsrGetDocumentMetadata('{\"ProcessId\" : \"OPDOC001\"}');
        OPDOC_DeliveryImpl.GetDocumentMetadataRequest dmr = new OPDOC_DeliveryImpl.GetDocumentMetadataRequest();
        dmr.ProcessId = 'OPDOC001';
        OPDOC_DeliveryImpl.GetDocumentMetadataResponse dmRes = (OPDOC_DeliveryImpl.GetDocumentMetadataResponse)docDelivary.getDocumentMetadata(dmr);
        System.assert(dmRes.AllObjectInfo != null);
        
        //Coverage for Get Data
        OPDOC_Delivery.JsrGetDocumentData('{\"ProcessId\" : \"OPDOC001\",\"RecordId\" : \"'+ wo.Id +'\"}');
        OPDOC_DeliveryImpl.GetDocumentDataRequest ddr = new OPDOC_DeliveryImpl.GetDocumentDataRequest();
        ddr.ProcessId = 'OPDOC001';
        ddr.RecordId = wo.Id;
        OPDOC_DeliveryImpl.GetDocumentDataResponse ddRes = (OPDOC_DeliveryImpl.GetDocumentDataResponse)docDelivary.getDocumentData(ddr);
        System.assert(ddRes.DocumentData != null);
        
        //Coverage for Get UserInfo
        OPDOC_Delivery.JsrGetUserInfo('');
        OPDOC_DeliveryImpl.GetUserInfoResponse uiRes = (OPDOC_DeliveryImpl.GetUserInfoResponse)docDelivary.getUserInfo();
        System.assert(uiRes != null);
        
        //Coverage for Submit Query
        OPDOC_Delivery.JsrSubmitQuery('{\"Query\" : \"Select Id from SVMXC__ServiceMax_Processes__c\"}');
        OPDOC_DeliveryImpl.SubmitQueryRequest sqr = new OPDOC_DeliveryImpl.SubmitQueryRequest();
        sqr.Query = 'Select Id from SVMXC__Service_Order__c';
        OPDOC_DeliveryImpl.SubmitQueryResponse sqRes = (OPDOC_DeliveryImpl.SubmitQueryResponse)docDelivary.submitQuery(sqr);
        System.assert(sqRes != null);
        
        //Coverage for createPDF
        OPDOC_Delivery.JsrCreatePDF('{\"DocumentId\" : \"'+ sdRes.DocumentId +'\",\"RecordId\" : \"'+ wo.Id +'\"}');
        OPDOC_DeliveryImpl.CreatePDFRequest cpr = new OPDOC_DeliveryImpl.CreatePDFRequest();
        cpr.DocumentId = sdRes.DocumentId;
        OPDOC_DeliveryImpl.CreatePDFResponse cpRes = (OPDOC_DeliveryImpl.CreatePDFResponse)docDelivary.createPDF(cpr);
        Test.stopTest();
    }
    
    static testMethod void deliveryImpl_Test_forSalesforceFile()
    {   
        prepareTestData();
        
        Map<String, String> mapSignatureNameIds = new Map<String, String>();
        mapSignatureNameIds.put('ServiceMaxLogo', '01570000000UAFS');
        String str = 'abcededdadfasdsfasd {<img svmx-data=\"ServiceMaxLogo\" src=\"\">}';
        
        wo = new SVMXC__Service_Order__c();
        insert wo;
        //test
        prepareTestData1();
        //test
        Attachment attach = new Attachment();
        Blob myBlob = Blob.valueof(str);
        attach.Body = myBlob;
        attach.Name = 'OutputDoc';
        attach.IsPrivate = false;
        attach.ParentId = wo.Id;
        insert attach;
        List<String> lstAttIds = new List<String>();
        lstAttIds.add(attach.Id);
        
        
        //--Start----Added for the story BAC-3057
        SVMXC__SM_Application_Feature__c objAF = new SVMXC__SM_Application_Feature__c();
        objAF.SVMXC__SM_Feature_Name__c = 'SFM_DESIGNER';
        objAF.SVMXC__SM_Feature_Description__c = 'TEST';
        insert objAF;

        SVMXC__SM_Feature_Permission__c objFP = new SVMXC__SM_Feature_Permission__c();
        objFP.SVMXC__SM_Application_Feature__c = objAF.id;
        objFP.SVMXC__SM_User__c = UserInfo.getUserId();
        insert objFP;
        //--End----Added for the story BAC-3057
        
        Test.startTest();
        try{
        
        docDelivary.offlineSubmitDocuments(lstAttIds, new List<String>());
        docDelivary.offlineCreatePDF(lstAttIds, new List<String>());
        }catch(Exception E) {
        }
        ApexPages.currentPage().getParameters().put('SVMX_recordID', wo.Id);
        ApexPages.currentPage().getParameters().put('SVMX_ProcessID', 'OPDOC001');
        OPDOC_DeliveryImpl.MetadataWrapper objwrapper = new OPDOC_DeliveryImpl.MetadataWrapper('', '', '', '', '', '', '', '', '','');
        
        
        //OPDOC_DeliveryImpl.ReplaceHTMLImagesSrc(str, mapSignatureNameIds);
        OPDOC_Delivery objOPDOCDelivery = new OPDOC_Delivery();
        //objOPDOCDelivery.getIsQualified();
        //objOPDOCDelivery.getErrorMessage();
        //objOPDOCDelivery.getObjectLabel();
        //objOPDOCDelivery.getNameFieldValue();
        //objOPDOCDelivery.getTabStyleLogoURL();
        //objOPDOCDelivery.IsQualified = true;
        //objOPDOCDelivery.getSettings();
        //objOPDOCDelivery.getSfmDeliverySettings();
        //objOPDOCDelivery.getIsLaunchDesignerEnabled(); //Added for the story BAC-3057
        //objOPDOCDelivery.getUrlForLaunchDesigner(); //Added for the story BAC-3057
        try{
            OPDOC_Delivery.JsrDescribeObject('test');
        }
        catch(Exception e){}
        
        try{
            OPDOC_Delivery.JsrTargetUpdates('test');
        }
        catch(Exception e){}
        
        
        COMM_FileHandlerUtilities.fileSettingForTestClass = true;
        //Added for File
        
        
        
        Test.stopTest();
        
        //Coverage for submitDocument for file
        OPDOC_Delivery.JsrSubmitDocument('{\"Document\" : \"<div data=\'$D.wo.SVMXC__City__c\'>Bangalore</div>\"}');
        OPDOC_DeliveryImpl.SubmitDocumentRequest sdrFile = new OPDOC_DeliveryImpl.SubmitDocumentRequest();
        sdrFile.Document = '<div data=\'$D.wo.SVMXC__City__c\'>Bangalore</div> ';
        OPDOC_DeliveryImpl.SubmitDocumentResponse sdResFile = (OPDOC_DeliveryImpl.SubmitDocumentResponse)docDelivary.submitDocument(sdrFile);
        System.assert(sdResFile.DocumentId != null && sdResFile.DocumentId.length() > 0);
        
        Id oneCVId = COMM_FileHandlerUtilities.insertOneContentVersion(COMM_FileHandlerUtilities.createContentVersionInstance(null,'OutputDoc','OutputDoc',null));
         List<Id> listContentVersionIds = new List<Id>();
         listContentVersionIds.add(oneCVId);
        ContentDocumentLink cdlSingleInstance =  new ContentDocumentLink();
        Map<Id,Id> mapCVIds = COMM_FileHandlerUtilities.getContentDocumentsId(listContentVersionIds);
        cdlSingleInstance = COMM_FileHandlerUtilities.createContentDocumentLink(sdResFile.DocumentId,mapCVIds.get(oneCVId));
        Id cdlId = COMM_FileHandlerUtilities.insertOneContentDocumentLink(cdlSingleInstance);
        
        //Coverage for createPDF
        OPDOC_Delivery.JsrCreatePDF('{\"DocumentId\" : \"'+ sdResFile.DocumentId +'\",\"RecordId\" : \"'+ wo.Id +'\"}');
        OPDOC_DeliveryImpl.CreatePDFRequest cprFile = new OPDOC_DeliveryImpl.CreatePDFRequest();
        cprFile.DocumentId = sdResFile.DocumentId;
        OPDOC_DeliveryImpl.CreatePDFResponse cpResFile = (OPDOC_DeliveryImpl.CreatePDFResponse)docDelivary.createPDF(cprFile);
        
        
    }
    static testmethod void headerRecordValidation(){
        
        /*PageReference pageRef = Page.OPDOC_Delivery;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('SVMX_recordID',wo.Id); 
        ApexPages.currentPage().getParameters().put('SVMX_ProcessID','OPDOC001');       
        OPDOC_Delivery objDelivery = new OPDOC_Delivery();*/
        
    }
    
    static testmethod void documentGenerator(){
        
        PageReference pageRef = Page.OPDOC_Generator;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('document-id',attachmentId);
        
        OPDOC_Generator gen = new OPDOC_Generator();
        /*
        gen.getInnerHTML();
        gen.getPageRule();
        gen.getTopLeftRule();
        gen.getTopCenterRule();
        gen.getTopRightRule();
        gen.getBottomLeftRule();
        gen.getBottomCenterRule();
        gen.getBottomRightRule();
        gen.getCssReference();
        */
    }
    
    static testmethod void documentViewer(){
        
        PageReference pageRef = Page.OPDOC_DocumentViewer;
        Test.setCurrentPage(pageRef);        
        wo = new SVMXC__Service_Order__c();
        insert wo;
        pageRef.getParameters().put('SVMX_RecId',wo.Id);         
        pageRef.getParameters().put('SVMX_AttID',attachmentId);
        OPDOC_DocumentViewer vie = new OPDOC_DocumentViewer();
        vie.getDocumentURL();
        vie.deleteAttachment();
        vie.getTAG001();
        vie.getTAG002();
    }
    static testmethod void documentViewerforFile(){
        
        PageReference pageRef = Page.OPDOC_DocumentViewer;
        Test.setCurrentPage(pageRef);        
        wo = new SVMXC__Service_Order__c();
        insert wo;
        Id oneCVId = COMM_FileHandlerUtilities.insertOneContentVersion(COMM_FileHandlerUtilities.createContentVersionInstance(null,'Test File','Test Data',null));
        pageRef.getParameters().put('SVMX_RecId',wo.Id);         
        pageRef.getParameters().put('SVMX_AttID',oneCVId);
        OPDOC_DocumentViewer vie = new OPDOC_DocumentViewer();
        vie.getDocumentURL();
        vie.deleteAttachment();
        vie.getTAG001();
        vie.getTAG002();
        vie.getTAG003();
        vie.getTAG004();
    }
    static void prepareTestData(){
        //Get the recordtypes
         List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
         String targetManager, processNodeObj;
         for(RecordType r : lstRecType){
            if(r.Name == 'Target Manager')
                targetManager = r.id;
            if(r.Name == 'Process Node Objects')    
                processNodeObj = r.id;
         }
        //Create Doc Template
        docTemplate = new SVMXC__Doc_Template__c();
        docTemplate.SVMXC__Template_Id__c = 'DOCTEMP001';
        insert docTemplate;
        
        //Create Doc Template Details
        docTemplateDetailHeader = new SVMXC__Doc_Template_Details__c();
        docTemplateDetailHeader.SVMXC__Doc_Template__c = docTemplate.Id;
        docTemplateDetailHeader.SVMXC__Type__c = 'Header';
        docTemplateDetailHeader.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        docTemplateDetailHeader.SVMXC__Alias__c = 'wo';
        docTemplateDetailHeader.SVMXC__Fields__c = '{\"Metadata\":[' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__City__c\",\"TYP\" : \"Text\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Configuration_After__c\",\"TYP\" : \"LongTextArea\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Country__c\",\"TYP\" : \"Picklist\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Is_Entitlement_Performed__c\",\"TYP\" : \"Checkbox\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Latitude__c\",\"TYP\" : \"Number\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Case__c\",\"TYP\" : \"Reference\",\"RLN\" : \"SVMXC__Case__r\",\"ROBJ\" : \"Case\",\"RFN\" : \"CaseNumber\",\"RTYP\" : \"Text\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Case__c\",\"TYP\" : \"Reference\",\"RLN\" : \"SVMXC__Case__r\",\"ROBJ\" : \"Case\",\"RFN\" : \"AccountId\",\"RTYP\" : \"Reference\",\"RLN2\" : \"Account\",\"ROBJ2\" : \"Account\",\"RFN2\" : \"CreatedDate\",\"RTYP2\" : \"Text\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Case__c\",\"TYP\" : \"Reference\",\"RLN\" : \"SVMXC__Case__r\",\"ROBJ\" : \"Case\",\"RFN\" : \"SVMXC__SLA_Terms__c\",\"RTYP\" : \"Reference\",\"RLN2\" : \"SVMXC__SLA_Terms__r\",\"ROBJ2\" : \"SVMXC__Service_Level__c\",\"RFN2\" : \"SVMXC__Active__c\",\"RTYP2\" : \"Checkbox\"}' +
            ']}';
        docTemplateDetailHeader.SVMXC__SOQL__c = 'SVMXC__City__c,SVMXC__Configuration_After__c,SVMXC__Country__c,SVMXC__Is_Entitlement_Performed__c,SVMXC__Latitude__c,SVMXC__Case__r.CaseNumber,SVMXC__Case__r.Account.CreatedDate,SVMXC__Case__r.SVMXC__SLA_Terms__r.SVMXC__Active__c';
        docTemplateDetailHeader.SVMXC__Header_Reference_Field__c = 'Id';
        insert docTemplateDetailHeader;

        docTemplateDetailChild = new SVMXC__Doc_Template_Details__c(
            SVMXC__Doc_Template__c = docTemplate.Id,   
            SVMXC__Type__c = 'Detail_Object', 
            SVMXC__Object_Name__c = 'SVMXC__Checklist__c',   
            SVMXC__Doc_Template_Detail_Id__c = 'Checklist (Work Order)',
            SVMXC__Alias__c = 'Checklist__Work_Order_', 
            SVMXC__Fields__c = '{"Metadata":[{"FN":"SVMXC__ChecklistProcessID__c","RLN":"SVMXC__ChecklistProcessID__r","RTYP":"string","ROBJ":"SVMXC__ServiceMax_Processes__c","TYP":"reference","OBJ":"SVMXC__Checklist__c","RFN":"SVMXC__Name__c"},{"FN":"SVMXC__Completed_By__c","RLN":"SVMXC__Completed_By__r","RTYP":"string","ROBJ":"User","TYP":"reference","OBJ":"SVMXC__Checklist__c","RFN":"Name"},{"TYP":"datetime","FN":"SVMXC__Completed_On__c","OBJ":"SVMXC__Checklist__c"},{"TYP":"picklist","FN":"SVMXC__Status__c","OBJ":"SVMXC__Checklist__c"}]}', 
            SVMXC__SOQL__c = 'SVMXC__ChecklistProcessID__r.SVMXC__Name__c, SVMXC__Completed_By__r.Name, SVMXC__Completed_On__c, SVMXC__Status__c',
            SVMXC__Header_Reference_Field__c = 'SVMXC__Work_Order__c'
        );
        insert docTemplateDetailChild;
        
        //Create 
        processNode = new SVMXC__ServiceMax_Processes__c();
        processNode.RecordTypeId = targetManager;
        processNode.SVMXC__ProcessID__c = 'OPDOC001';
        processNode.SVMXC__Doc_Template__c = docTemplate.Id;
        processNode.SVMXC__Purpose__c = 'OUTPUT DOCUMENT';
        insert processNode;
        
        //Create Process Node Object Target
        processNodeTarget = new SVMXC__ServiceMax_Processes__c();
        processNodeTarget.RecordTypeId = processNodeObj;      
        processNodeTarget.SVMXC__ProcessID__c = 'PROCNODE001';
        processNodeTarget.SVMXC__Process__c = processNode.Id;
        processNodeTarget.SVMXC__Doc_Template_Details__c = docTemplateDetailHeader.Id;
        processNodeTarget.SVMXC__Type__c = 'TARGET';
        insert processNodeTarget;

        //Create Process Node Object Target child
        processNodeTargetChild = new SVMXC__ServiceMax_Processes__c();
        processNodeTargetChild.RecordTypeId = processNodeObj;      
        processNodeTargetChild.SVMXC__ProcessID__c = 'PROCNODE001';
        processNodeTargetChild.SVMXC__Process__c = processNode.Id;
        processNodeTargetChild.SVMXC__Doc_Template_Details__c = docTemplateDetailChild.Id;
        processNodeTargetChild.SVMXC__Type__c = 'TARGETCHILD';
        insert processNodeTargetChild;
        
        document = '<div data=\'$D.wo.SVMXC__City__c\'>City</div> ' +
            '<div data=\'$D.wo.SVMXC__Configuration_After__c\'>SVMXC__Configuration_After__c</div>' +
            '<div data=\'$D.wo.SVMXC__Country__c\'>SVMXC__Country__c</div>' +
            '<div data=\'$D.wo.SVMXC__Is_Entitlement_Performed__c\'>SVMXC__Is_Entitlement_Performed__c</div>' +
            '<div data=\'$D.wo.SVMXC__Latitude__c\'>SVMXC__Latitude__c</div>' +
            '<div data=\'$D.wo.SVMXC__Case__c.CaseNumber\'>SVMXC__Case__c</div>' +
            '<div data=\'$D.wo.SVMXC__Case__c.AccountId.CreatedDate\'>SVMXC__Case__c.Account.CreatedDate</div>' +
            '<div data=\'$D.wo.SVMXC__Case__c.SVMXC__SLA_Terms__c.SVMXC__Active__c\'>SVMXC__Case__c.SVMXC__SLA_Terms__c.SVMXC__Active__c</div>';
        
        Attachment attach = new Attachment();
        Blob myBlob = Blob.valueof(document);
        attach.Body = myBlob;
        attach.Name = 'OutputDoc';
        attach.IsPrivate = false;
        attach.ParentId = docTemplate.Id;
        insert attach;
        
        wo = new SVMXC__Service_Order__c();
        insert wo;
        
        SVMXC__ServiceMax_List__c proceDoc = new SVMXC__ServiceMax_List__c();
        insert proceDoc;
        
        attach = new Attachment();
        myBlob = Blob.valueof('HI this for test class');
        attach.Body = myBlob;
        attach.Name = 'OutputDoc1';
        attach.IsPrivate = false;
        attach.ParentId = proceDoc.id;
        insert attach;
        
        attachmentId = attach.Id;
        
    }
    static void prepareTestData1(){
    
    List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        String targetManager, processNodeObj , smartdoc , processBizzrule , bizzrulestr;
        for(RecordType r : lstRecType){
            if(r.Name == 'Target Manager')
                targetManager = r.id;
            if(r.Name == 'Process Node Objects')    
                processNodeObj = r.id;
      if(r.Name == 'Checklist Smart Doc')  
        smartdoc = r.id;
      if (r.Name == 'Process Business Rule')
        processBizzrule = r.id;
      if (r.Name == 'Business Rule')
        bizzrulestr = r.id;
         }
     List<RecordType> lstRecTypeConfigObj = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Expressions'];
     
    chtargetproc = new SVMXC__ServiceMax_Processes__c();
    chtargetproc.RecordTypeId = targetManager;
    chtargetproc.SVMXC__Purpose__c = 'CHECKLIST';
    chtargetproc.SVMXC__ProcessID__c = 'CHECLISTNAME';
    insert chtargetproc;
    
    chtargetproc1 = new SVMXC__ServiceMax_Processes__c();
    chtargetproc1.RecordTypeId = targetManager;
    chtargetproc1.SVMXC__Purpose__c = 'CHECKLIST';
    chtargetproc1.SVMXC__ProcessID__c = 'CHECLISTNAME';
    insert chtargetproc1;
    
    chtargetproc2 = new SVMXC__ServiceMax_Processes__c();
    chtargetproc2.RecordTypeId = targetManager;
    chtargetproc2.SVMXC__Purpose__c = 'CHECKLIST';
    chtargetproc2.SVMXC__ProcessID__c = 'CHECLISTNAME1';
    insert chtargetproc2;
    
    chtargetproc3 = new SVMXC__ServiceMax_Processes__c();
    chtargetproc3.RecordTypeId = targetManager;
    chtargetproc3.SVMXC__Purpose__c = 'CHECKLIST';
    chtargetproc3.SVMXC__ProcessID__c = 'CHECLISTNAME3';
    insert chtargetproc3;

        chtargetproc4 = new SVMXC__ServiceMax_Processes__c();
        chtargetproc4.RecordTypeId = targetManager;
        chtargetproc4.SVMXC__Purpose__c = 'CHECKLIST';
        chtargetproc4.SVMXC__ProcessID__c = 'CHECLISTNAME4';
        insert chtargetproc4;
    
        List<SVMXC__Checklist__c> lstChecklist = new List<SVMXC__Checklist__c>();
    SVMXC__Checklist__c checkListObj = new SVMXC__Checklist__c();
    checkListObj.SVMXC__What_Id__c =wo.id;
    checkListObj.SVMXC__Work_Order__c = wo.id;
    checkListObj.SVMXC__ChecklistProcessID__c= chtargetproc.id;
        lstChecklist.add(checkListObj);

        SVMXC__Checklist__c checkListObj_G = new SVMXC__Checklist__c();
        checkListObj_G.SVMXC__What_Id__c =wo.id;
        checkListObj_G.SVMXC__Work_Order__c = wo.id;
        checkListObj_G.SVMXC__ChecklistProcessID__c= chtargetproc.id;
        checkListObj_G.SVMXC__SM_Checklist_Group_Id__c = 1499786264679.0;
        checkListObj_G.SVMXC__SM_Sequence__c = 1;
        lstChecklist.add(checkListObj_G);
    
    SVMXC__Checklist__c checkListObj1 = new SVMXC__Checklist__c();
    checkListObj1.SVMXC__What_Id__c = wo.id;
    checkListObj1.SVMXC__Work_Order__c = wo.id;
    checkListObj1.SVMXC__ChecklistProcessID__c = chtargetproc1.id;
    lstChecklist.add(checkListObj1);
    
    SVMXC__Checklist__c checkListObj2 = new SVMXC__Checklist__c();
    checkListObj2.SVMXC__What_Id__c = wo.id;
    checkListObj2.SVMXC__Work_Order__c = wo.id;
    checkListObj2.SVMXC__ChecklistProcessID__c = chtargetproc2.id;
        checkListObj2.SVMXC__SM_Checklist_Group_Id__c = 1499786264671.0;
        checkListObj2.SVMXC__SM_Sequence__c = 1;
    lstChecklist.add(checkListObj2);

        SVMXC__Checklist__c checkListObj21 = new SVMXC__Checklist__c();
        checkListObj21.SVMXC__What_Id__c = wo.id;
        checkListObj21.SVMXC__Work_Order__c = wo.id;
        checkListObj21.SVMXC__ChecklistProcessID__c = chtargetproc2.id;
        lstChecklist.add(checkListObj21);
    
    SVMXC__Checklist__c checkListObj3 = new SVMXC__Checklist__c();
    checkListObj3.SVMXC__What_Id__c = wo.id;
    checkListObj3.SVMXC__Work_Order__c = wo.id;
    checkListObj3.SVMXC__ChecklistProcessID__c = chtargetproc3.id;
    lstChecklist.add(checkListObj3);

        SVMXC__Checklist__c checkListObj31 = new SVMXC__Checklist__c();
        checkListObj31.SVMXC__What_Id__c = wo.id;
        checkListObj31.SVMXC__Work_Order__c = wo.id;
        checkListObj31.SVMXC__ChecklistProcessID__c = chtargetproc3.id;
        checkListObj31.SVMXC__SM_Checklist_Group_Id__c = 1499786264675.0;
        checkListObj31.SVMXC__SM_Sequence__c = 1;
        lstChecklist.add(checkListObj31);

        insert lstChecklist;

        //Creating checklist attachment record
        SVMXC__SM_Checklist_Attachment__c objCheckAtt = new SVMXC__SM_Checklist_Attachment__c();
        objCheckAtt.SVMXC__SM_Checklist__c = lstChecklist[0].id;
        insert objCheckAtt;
    
        List<SVMXC__ServiceMax_Processes__c> lstSmartDocProcess = new List<SVMXC__ServiceMax_Processes__c>();
    SVMXC__ServiceMax_Processes__c processForSmartDoc = new SVMXC__ServiceMax_Processes__c();
    processForSmartDoc.SVMXC__Process2__c=chtargetproc.id;
    processForSmartDoc.SVMXC__SM_Checklist_Version__c = 'All Versions';
    processForSmartDoc.SVMXC__Process1__c = processNode.id;
    processForSmartDoc.RecordTypeId = smartdoc;
        lstSmartDocProcess.add(processForSmartDoc);
    
    SVMXC__ServiceMax_Processes__c processForSmartDoc1 = new SVMXC__ServiceMax_Processes__c();
    processForSmartDoc1.SVMXC__Process2__c = chtargetproc2.id;
    processForSmartDoc1.SVMXC__SM_Checklist_Version__c = 'Last Version';
    processForSmartDoc1.SVMXC__Process1__c = processNode.id;
    processForSmartDoc1.RecordTypeId = smartdoc;
    lstSmartDocProcess.add(processForSmartDoc1);
    
    SVMXC__ServiceMax_Processes__c processForSmartDoc2 = new SVMXC__ServiceMax_Processes__c();
    processForSmartDoc2.SVMXC__Process2__c = chtargetproc3.id;
    processForSmartDoc2.SVMXC__SM_Checklist_Version__c = 'First Version';
    processForSmartDoc2.SVMXC__Process1__c = processNode.id;
    processForSmartDoc2.RecordTypeId = smartdoc;
    lstSmartDocProcess.add(processForSmartDoc2);

        SVMXC__ServiceMax_Processes__c processForSmartDoc3 = new SVMXC__ServiceMax_Processes__c();
        processForSmartDoc3.SVMXC__Process2__c = chtargetproc4.id;
        processForSmartDoc3.SVMXC__SM_Checklist_Version__c = 'All Versions';
        processForSmartDoc3.SVMXC__Process1__c = processNode.id;
        processForSmartDoc3.RecordTypeId = smartdoc;
        lstSmartDocProcess.add(processForSmartDoc3);

        insert lstSmartDocProcess;
    
    // test cover for Delivery
    
    bizzrule = new SVMXC__ServiceMax_Processes__c();
    bizzrule.RecordTypeId = bizzrulestr;
    insert bizzrule;
    
    
    procbizzrule1 = new SVMXC__ServiceMax_Processes__c();
    procbizzrule1.RecordTypeId = processBizzrule;  
    procbizzrule1.SVMXC__Process1__c = processNode.id;
    procbizzrule1.SVMXC__Rule_Type__c = 'Checklist Criteria in Output Doc';
    procbizzrule1.SVMXC__Process2__c = chtargetproc.id;
    procbizzrule1.SVMXC__Process3__c = bizzrule.id;
    insert procbizzrule1;
    
    
    
    SVMXC__ServiceMax_Config_Data__c listConfig = new SVMXC__ServiceMax_Config_Data__c();
    listConfig.SVMXC__Expression_Rule__c = bizzrule.id;
    listConfig.RecordTypeId = lstRecTypeConfigObj[0].id;
    insert listConfig;
        
        SVMXC__ServiceMax_Config_Data__c listConfig1 = new SVMXC__ServiceMax_Config_Data__c();
    listConfig1.SVMXC__Expression_Rule__c = bizzrule.id;
    listConfig1.RecordTypeId = lstRecTypeConfigObj[0].id;
    insert listConfig1;
    
        //
        OPDOC_DeliveryImpl.SubmitQueryResponse objSubmitQueryResponse = new OPDOC_DeliveryImpl.SubmitQueryResponse(new List<Sobject>());
        
        OPDOC_DeliveryImpl.ValueWrapper objValueWrapper = new OPDOC_DeliveryImpl.ValueWrapper('test','test','test');
        
        OPDOC_DeliveryImpl.ValueWrapperMap objValueWrapperMap = new OPDOC_DeliveryImpl.ValueWrapperMap('test', new List<OPDOC_DeliveryImpl.ValueWrapper>{objValueWrapper});

        OPDOC_DeliveryImpl.DocumentData objDocumentData = new OPDOC_DeliveryImpl.DocumentData('test', new List<Sobject>(), new List<OPDOC_DeliveryImpl.ValueWrapperMap>{objValueWrapperMap});
        
        OPDOC_DeliveryImpl.GetDocumentDataResponse objGetDocumentDataResponse = new OPDOC_DeliveryImpl.GetDocumentDataResponse(new List<OPDOC_DeliveryImpl.DocumentData>{objDocumentData});

        OPDOC_DeliveryImpl.GetDocumentMetadataResponse objGetDocumentMetadataResponse = new OPDOC_DeliveryImpl.GetDocumentMetadataResponse();

        OPDOC_DeliveryImpl.RelatedRecordData objRelatedRecordData = new OPDOC_DeliveryImpl.RelatedRecordData('test', new List<Sobject>());
  }
}