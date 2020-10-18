//Version V.2.4
//Base Org Code
global with sharing class OPDOC_DeliveryImpl {
    
    
    public String TARGETMANAGER_RECORDTYPE = 'TARGET MANAGER';
    //constructor code goes here
    public OPDOC_DeliveryImpl(){
    
    }
        
    public Object getTemplate(GetTemplateRequest gtr){  
        
        String processId = gtr.ProcessId;
        
        List<SObject> processRec = getProcessNodeInfo(processId);
        
        //now get the attachment content.
        if(processRec == null || processRec.size() == 0){
            //TODO: Error Label goes here
            return '';
        }
        String docTemplateId = String.valueOf(processRec[0].get('SVMXC__Doc_Template__c'));
        List<Attachment> docs = [SELECT Id, Name, Body FROM Attachment WHERE ParentId =: docTemplateId];
        //Added for Salesforce file --BAC-2197
        ContentVersion cvDetails = new ContentVersion();
        ContentDocumentLink cdlink = new ContentDocumentLink();
        if(docs.size() == 0){
            List<Id> listOfParentIds = new List<Id>();
            List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
            listOfParentIds.add(Id.valueOf(docTemplateId));
            if(listOfParentIds.size() > 0)
                lstCDL = COMM_FileHandlerUtilities.getAllContentDocumentsLinks(null, listOfParentIds);
            System.debug('lstCDL '+lstCDL);
            if(lstCDL.size() > 0){
                cdlink = COMM_FileHandlerUtilities.getContentDocumentLinkDetails(String.valueOf(lstCDL[0].id));
                if(cdlink != null && cdlink.ContentDocument.LatestPublishedVersionId !=null){
                        cvDetails.id = cdlink.ContentDocument.LatestPublishedVersionId;
                        cvDetails.VersionData = cdlink.ContentDocument.LatestPublishedVersion.VersionData;
                }
            }
        }
        // End Salesforce file --BAC-2197
        if(!isListHasElements(docs) && cvDetails == null) {
            //TODO: Error Label goes here
            return '';
        }
        String content = '';
        if(docs.size() > 0){
            content = docs[0].Body.toString();
        }
        //Added for Salesforce file --BAC-2197
        if(cvDetails != null && cvDetails.VersionData != null){
            content = cvDetails.VersionData.toString();
        }
        // End Salesforce file --BAC-2197
        System.debug('content in getTemplate: '+content);
        return new GetTemplateResponse(content);
        //return JSON.serialize(new SFMOutputDocDeliveryImpl.GetTemplateResponse('<div data=\'$MODIFY($D.wo.number)\'>Hello World!</div><div data=\'$MODIFY($D.wo.name)\'>Name!</div>'));
    }
    
    private List<SObject> getProcessNodeInfo(String processId) {
        //BAC-5654 added SVMXC__SM_Exclude_Unanswered_Questions__c field in below query
        //BAC-5655 added SVMXC__SM_Display_File_Name__c,SVMXC__Export_Configuration__c
        List<SObject> procRec = [Select Id, SVMXC__Doc_Template__c,SVMXC__SM_Include_Skipped_Sections__c,SVMXC__SM_Exclude_Unanswered_Questions__c,SVMXC__SM_Display_File_Name__c,SVMXC__Export_Configuration__c from SVMXC__ServiceMax_Processes__c 
                                                            where SVMXC__ProcessID__c =: processId and RecordType.Name =: TARGETMANAGER_RECORDTYPE];
        return procRec;
    }
    
    private boolean isListHasElements(List<Object> lst){
        
        if(lst != null && lst.size() > 0){
            return true;
        }
        return false;       
    }
        
    //Used to store processed document
    public Object submitDocument(SubmitDocumentRequest dor) {    
            
        String document = dor.Document;
        System.debug('before Parsing: ' + document);
        List<String> processedDocument = parseForStyle(document);
        System.debug('after Parsing: ' + processedDocument.get(1));
        String styleTag = processedDocument.get(0);
        /*if(styleTag != null && styleTag.length() > 0){
            //styleTag = String.escapeSingleQuotes(styleTag);
        }*/
        //System.debug('Style: ' + processedDocument.get(0));
        if(styleTag == null){
            styleTag = '';
        }
        System.debug('Style Undefined: ' + styleTag);
        document = '<html><head><style type=\"text/css\">' + styleTag + '</style>' + 
            +' <style>body {font-family: Arial Unicode MS;}</style></head>' + processedDocument.get(1) + '</html>';
        SVMXC__ServiceMax_List__c proceDoc = new SVMXC__ServiceMax_List__c();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        insert proceDoc;
        
        Attachment attach = new Attachment();
        Blob myBlob = Blob.valueof(document);
        attach.Body = myBlob;
        attach.Name = 'OutputDoc.html';
        attach.IsPrivate = false;
        attach.ParentId = proceDoc.id;
        attach.ContentType = 'text/plain; charset=UTF-8'; 
        //insert attach;
        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( attach, COMM_SecurityUtils.Access.Createable ) ) {
            insert attach;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
        SubmitDocumentResponse response = new SubmitDocumentResponse(proceDoc.id);
        return response; 
    }
     
    //Used to store processed document in salesforce file --BAC-2197
    public Object submitDocumentforFile(SubmitDocumentRequest dor) {    
        //System.debug('SubmitDocumentRequest '+dor);
        String document = dor.Document;
        System.debug('before Parsing: ' + document);
        List<String> processedDocument = parseForStyle(document);
        System.debug('after Parsing: ' + processedDocument.get(1));
        String styleTag = processedDocument.get(0);
        /*if(styleTag != null && styleTag.length() > 0){
        //styleTag = String.escapeSingleQuotes(styleTag);
        }*/
        //System.debug('Style: ' + processedDocument.get(0));
        if(styleTag == null){
            styleTag = '';
        }
        System.debug('Style Undefined: ' + styleTag);
        document = '<html><head><style type=\"text/css\">' + styleTag + '</style>' + 
            +' <style>body {font-family: Arial Unicode MS;}</style></head>' + processedDocument.get(1) + '</html>';
        SVMXC__ServiceMax_List__c proceDoc = new SVMXC__ServiceMax_List__c();
        insert proceDoc;
        //Create ContentVersion instances and insert that
        Id contentVersionId = COMM_FileHandlerUtilities.insertOneContentVersion(COMM_FileHandlerUtilities.createContentVersionInstance(null,'OutputDoc.html',document,null));
        System.debug('contentVersionId '+contentVersionId);
        List<Id> listContentVersionIds = new List<Id>();
        ContentDocumentLink cdlInstance = new ContentDocumentLink();
        listContentVersionIds.add(contentVersionId);
        //Get all the ContentDocument ids with ContentVersion ids
        Map<Id,Id> mapCVandCDids = COMM_FileHandlerUtilities.getContentDocumentsId(listContentVersionIds);
        if(mapCVandCDids != null && mapCVandCDids.size()> 0){
        for(Id cdId: mapCVandCDids.values()){
            // Create instances of ContentDocumentLink
            cdlInstance = COMM_FileHandlerUtilities.createContentDocumentLink(proceDoc.id,cdId);
        }
        // Insert ContentDocumentLink details
        Id cdlId = COMM_FileHandlerUtilities.insertOneContentDocumentLink(cdlInstance);
        System.debug('cdlId '+cdlId);
        }
        SubmitDocumentResponse response = new SubmitDocumentResponse(proceDoc.id);
        return response; 
    }
    
    private List<String> parseForStyle(String document){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('parseForStyle');
        String style = '';
        List<String> ret = new List<String>();
        
        if(document != null){
            try{
                integer startIndex = document.indexOf('<style'), contentStartIndex = 0;
                if(startIndex != -1){
                    contentStartIndex = document.indexOf('>', startIndex) + 1;
                }
                
                integer endIndex = document.indexOf('</style>'), contentEndIndex = 0;
                if(endIndex != -1){
                    contentEndIndex = endIndex;
                }
                
                if(startIndex != -1 && endIndex != -1){
                    endIndex = endIndex + 8;
                    style = document.substring(contentStartIndex, contentEndIndex);
                    document = document.substring(0, startIndex) + document.substring(endIndex, document.length());
                
                    System.debug(' *** ' + style + ' *** ' + document);
                    System.debug(' *** ' + contentStartIndex + ' *** ' + contentEndIndex);
                }
            }catch(Exception e){}
        }
        
        ret.add(style);
        ret.add(document);
        INTF_DataSync.logMethodEndTS(intMethodCount,'parseForStyle');
        return ret;
    }
    
    //Used to create PDF and add it as a attachment
    public Object createPDF(CreatePDFRequest cpr) {
        
        CreatePDFResponse response = new CreatePDFResponse();
        try{
            String docId = cpr.DocumentId;
            String recId = cpr.RecordId;
            String procId = cpr.ProcessId;
            String attachmentId = null;
            List<Attachment> docs = 
                [SELECT Id, Name, parentId FROM Attachment WHERE ParentId =: docId];
            List<SVMXC__ServiceMax_List__c> objLstRecord = [select Id from SVMXC__ServiceMax_List__c where Id =: docId];

            String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            System.debug(loggingLevel.INFO, 'baseURL : ' + baseURL);
            String serverInstance = getServerLoc();
            String possibleDomain = baseURL.substringBetween('https://','svmxc.'+ serverInstance + '.visual.force.com');
            System.debug('possibleDomain : ' + possibleDomain);
            String strPrefix = 'c.'+ serverInstance +'.content.force.com';
            if(possibleDomain != null && possibleDomain != ''){
                strPrefix = possibleDomain + strPrefix; 
            }
            strPrefix = 'https://'+ strPrefix;
            System.debug(strPrefix);            
            
           // String strPrefix = 'https://c.'+ getServerLoc() +'.content.force.com';
            String sitePrefix = Site.getPathPrefix();
            String domain = Site.getDomain();
            if(domain != null && domain.length() > 0){
                strPrefix = 'https://' + Site.getDomain();
            }
            if( sitePrefix != null && sitePrefix.length() > 0){
                strPrefix += sitePrefix;
            }
            System.debug('strPrefixxxx : '+strPrefix);
            if(docs != null && docs.size() > 0)
            {
                //Commented because of critical update from Salesforce- BAC-4039
                //PageReference pageRef = new PageReference(strPrefix + '/servlet/servlet.FileDownload?file=' + docs[0].id);
                PageReference pageRef = new PageReference('/servlet/servlet.FileDownload?file=' + docs[0].id);
                
                Datetime objNow = Datetime.now();
                String reqFormat = '' + objNow.year() + fmtNumByAppendingZero(objNow.month()) + fmtNumByAppendingZero(objNow.day()) + fmtNumByAppendingZero(objNow.hour()) + fmtNumByAppendingZero(objNow.minute()) + fmtNumByAppendingZero(objNow.second()); //<year><month><day><24 hour time with seconds>                  
                String strRecordName = procId + '_' +  recId + '_' + reqFormat;              
                //Blob pdf = pageRef.getContentAsPDF();
                //BAC-6180 Display File Name
                String filename = (strRecordName != null && strRecordName.length() > 0 ? strRecordName : 'Outputdoc') + '.pdf';
                if(String.isNotEmpty(cpr.DisplayFileName)){
                    filename = cpr.DisplayFileName + '.pdf';
                }
                //Added below condition as Salesforce is not supporting getContentAsPdf in Test class
                Blob pdf = !Test.isRunningTest() ? pageRef.getContentAsPdf() : Blob.valueOf('Test content');                 
                Attachment attach = new Attachment();
                attach.Body = pdf;
                attach.Name = filename;
                attach.IsPrivate = false;
                attach.ParentId = recId;
                //insert attach;
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( attach, COMM_SecurityUtils.Access.Createable ) ) {
                    insert attach;
                } else {
                    response.Status = false;
                    response.Message = System.Label.COMM001_TAG142;
                    return response;
                }
                                
                //delete the list attachment
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'Attachment' ) ) {  
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete docs[0];
                } else {
                    response.Status = false;
                    response.Message = System.Label.COMM001_TAG142;                    
                    return response;
                }
                
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_List__c' ) ) {  
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete objLstRecord;
                } else {
                    response.Status = false;
                    response.Message = System.Label.COMM001_TAG142;                    
                    return response;
                }
                
                response.PDFAttachmentId = attach.Id;
                pageRef.setRedirect(true);                
            }            
        } 
        catch(Exception ex){
            
            response.Status = false;
            response.Message = ex.getMessage();
        }       
        return response;
    }
    
    //Used to create PDF and add it as a Salesforce file--BAC-2197
    public Object createPDFForFile(CreatePDFRequest cpr) {
        System.debug('CreatePDFRequest '+cpr);
        CreatePDFResponse response = new CreatePDFResponse();
        try{
            //response.PDFAttachmentId = cpr.DocumentId;
            String docId = cpr.DocumentId;
            String recId = cpr.RecordId;
            String procId = cpr.ProcessId;
            String attachmentId = null;
            Id cdIdtoBeupdate;
            Boolean isOpdocVersionEnabled = false;
            List<Id> listOfParentIds = new List<Id>();
            
            //Check the Versioning is enables or not for the process --BAC-4029
            String TARGETMANAGER_RECORDTYPE = 'TARGET MANAGER';
            List<SVMXC__ServiceMax_Processes__c> lstProcNodeRecs = new List<SVMXC__ServiceMax_Processes__c>(); 
            if(!String.isBlank(procId))
                lstProcNodeRecs = [Select Id,SVMXC__SM_Enable_Version_Control__c  from SVMXC__ServiceMax_Processes__c 
                                   where SVMXC__ProcessID__c =: procId and RecordType.Name =: TARGETMANAGER_RECORDTYPE limit 1];
            //End --BAC-4029
            List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
            listOfParentIds.add(Id.valueOf(docId));
            
            if(listOfParentIds.size() > 0)
                lstCDL = COMM_FileHandlerUtilities.getAllContentDocumentsLinks(null, listOfParentIds);
            
            List<SVMXC__ServiceMax_List__c>  objLstRecord = [select Id from SVMXC__ServiceMax_List__c where Id =: docId];
            
            System.debug('lstCDL '+lstCDL);
            if(lstCDL != null && lstCDL.size() > 0)
            {
                //Commented because of critical update from Salesforce- BAC-4039
                //PageReference pageRef = new PageReference(strPrefix + '/sfc/servlet.shepherd/version/download/' + lstCDL[0].ContentDocument.LatestPublishedVersionId);
                PageReference pageRef = new PageReference('/sfc/servlet.shepherd/version/download/' + lstCDL[0].ContentDocument.LatestPublishedVersionId);
                Datetime objNow = Datetime.now();
                String reqFormat = '' + objNow.year() + fmtNumByAppendingZero(objNow.month()) + fmtNumByAppendingZero(objNow.day()) + fmtNumByAppendingZero(objNow.hour()) + fmtNumByAppendingZero(objNow.minute()) + fmtNumByAppendingZero(objNow.second()); //<year><month><day><24 hour time with seconds>                  
                String strRecordName = procId + '_' +  recId + '_' + reqFormat;              
                //Added below condition as Salesforce is not supporting getContentAsPdf in Test class
                Blob pdfData = !Test.isRunningTest() ? pageRef.getContentAsPdf() : Blob.valueOf('Test content');
                String filename = (strRecordName != null && strRecordName.length() > 0 ? strRecordName : 'Outputdoc') + '.pdf';
                //BAC-6180 Display File Name
                if(String.isNotEmpty(cpr.DisplayFileName)){
                    filename = cpr.DisplayFileName + '.pdf';
                }
                
                //Added for ---BAC-4029
                if(lstProcNodeRecs != null && lstProcNodeRecs.size() > 0){
                    isOpdocVersionEnabled = lstProcNodeRecs[0].SVMXC__SM_Enable_Version_Control__c;
                }
                if(isOpdocVersionEnabled){
                    List<String> fieldSet = new List<String>();
                    fieldSet.add('ContentDocumentId');
                    String whereClause = 'ContentDocument.LatestPublishedVersion.SVMXC__SM_Process_ID__c= \'' + procId+recId + '\' and LinkedEntityId = \'' + recId + '\' order by ContentDocument.LatestPublishedVersion.CreatedDate DESC';
                    List<ContentDocumentLink> lstCVDetails = COMM_FileHandlerUtilities.getContentVersionsfromContentDocumentLink(fieldSet, whereClause);
                    System.debug('lstCVDetails '+lstCVDetails);
                    if(lstCVDetails != null && lstCVDetails.size() > 0){
                        cdIdtoBeupdate = lstCVDetails[0].ContentDocumentId;
                    }
                }
                //End ----BAC-4029
                ContentVersion cv = new ContentVersion();
                cv.VersionData = pdfData;
                cv.Title = fileName;
                cv.PathOnClient = filename;
                cv.isMajorVersion = false;
                if(cdIdtoBeupdate != null)
                    cv.ContentDocumentId = cdIdtoBeupdate;
                if(!String.isBlank(procId) && !String.isBlank(recId))//Added processId with record id to get the unique id --BAC-4143
                    cv.SVMXC__SM_Process_ID__c= procId+recId;
                
                //Create ContentVersion instances and insert that
                Id contentVersionId = COMM_FileHandlerUtilities.insertOneContentVersion(cv);
                
                System.debug('contentVersionId for PDF '+contentVersionId);
                List<Id> listContentVersionIds = new List<Id>();
                List<ContentDocumentLink> cdlInstance = new List<ContentDocumentLink>();
                listContentVersionIds.add(contentVersionId);
                //Get all the ContentDocument ids with ContentVersion ids
                Map<Id,Id> mapCVandCDids = COMM_FileHandlerUtilities.getContentDocumentsId(listContentVersionIds);
                
                if(mapCVandCDids != null && mapCVandCDids.size() > 0){
                    for(Id cdId: mapCVandCDids.values()){
                        // Create instances of ContentDocumentLink
                        if(recId != null){
                            cdlInstance.add(COMM_FileHandlerUtilities.createContentDocumentLink(Id.valueOf(recId),cdId));
                            
                        }
                    }
                }
                // Insert ContentDocumentLink details
                List<Id> cdlId = COMM_FileHandlerUtilities.insertContentDocumentLink(cdlInstance);
                System.debug('Inserted ContentDocumentLink '+cdlId);
                //delete the old salesforce file
                List<Id> listCDIdsTobedelete = new List<Id>();
                listCDIdsTobedelete.add(lstCDL[0].ContentDocumentId);
                COMM_FileHandlerUtilities.deleteContentDocument(listCDIdsTobedelete);
                
                delete objLstRecord;
                response.PDFAttachmentId = contentVersionId;
                pageRef.setRedirect(true);                
            }            
        } 
        catch(Exception ex){
            response.Status = false;
            response.Message = ex.getMessage();
        }        
        return response;
    }
    
    private string fmtNumByAppendingZero(integer num){
        String returnNumber = String.valueOf(num);
        if(num < 10 && returnNumber.length() == 1){
            returnNumber = 0 + returnNumber;
        }
        return returnNumber;
    }
    
    private string getServerLoc(){
       /* String fullFileURL = URL.getSalesforceBaseUrl().getHost();
        return  fullFileURL.substringBetween('.','.'); */
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getServerLoc');
        INTF_DataSync.logSOQL(intMethodCount, 'SELECT InstanceName FROM Organization limit 1');
        String serverInstance = [SELECT InstanceName FROM Organization limit 1].InstanceName;
        serverInstance = serverInstance != null ? serverInstance.toLowerCase() : '';
        INTF_DataSync.logMethodEndTS(intMethodCount,'getServerLoc');
        return serverInstance; 
    }
    
    private string getServerLocForOffline(){
        String fullFileURL = URL.getSalesforceBaseUrl().getHost();
        Integer indexOfDot = fullFileURL.indexOf('.');
        return fullFileURL.substring(0,indexOfDot);
    }
    
    public String ReplaceHTMLImagesSrc(String htmlContent, Map<String, String> signatureNameIds){
      Integer intMethodCount = INTF_DataSync.logMethodStartTS('ReplaceHTMLImagesSrc');
        //for formatting sake, now replace curly braces with svmx identifiers, 
        //here using svmx-open-brace in place of '{' and svmx-close-brace in place of '}'
        htmlContent = htmlContent.replace('{','svmx-open-brace');
        htmlContent = htmlContent.replace('}','svmx-close-brace');
        ParsedHTML parsedHTML = parseHTMLForImages(htmlContent);
        String content = parsedHTML.content;
        Map<integer, String> imageNames = parsedHTML.imageNames;
        integer length = imageNames.keySet().size();
        if(length > 0){
            Map<String, String> mapDocRecs = QueryDocumentObject(imageNames.values());
            System.debug('Image Document Records: ' + mapDocRecs);
            System.debug('Image names in template: ' + imageNames.values());
            
            List<String> finalImageList = new List<String>();
            integer index = 0;string currValue = null;
            string localImageName = null;
            while(index < length){
                localImageName = imageNames.get(index);
                if(mapDocRecs.containsKey(localImageName)){
                    currValue = mapDocRecs.get(localImageName);                 
                }
                else if(signatureNameIds.containsKey(localImageName))
                {
                    currValue = signatureNameIds.get(localImageName);
                    
                    system.debug('Current Signature Value: ' + currValue);
                    List<string> lstSigIds = currValue.split('=');
                    if(lstSigIds != null && lstSigIds.size() == 2)
                    {
                        system.debug('Signature Id Used: ' + lstSigIds[1]);
                        SVMXC.INTF_DataUtilityServices.lstSignatureIds.add(lstSigIds[1]);
                    }
                }
                else{
                    currValue = '';
                }
                finalImageList.add('\'' + currValue + '\'');
                index++;
            }
            //System.debug('Parsed Content: ' + content);
            //System.debug('Images List: ' + finalImageList);
            //String.Format will not handle the quote gracefully, replace all the quote with svmx-handle-quote
            String temp = content.replace('\'','svmx-handle-quote'); 
            temp = String.Format(temp ,finalImageList);
            content = temp.replace('svmx-handle-quote', '\'');      
        }
        //now replace the identifiers to curly brackets
        System.Debug('Content: ' + content);
        content = content.replace('svmx-open-brace', '{');
        content = content.replace('svmx-close-brace', '}');
        System.Debug('Final Content: ' + content);
        INTF_DataSync.logMethodEndTS( intMethodCount, 'ReplaceHTMLImagesSrc');
        return content;
    }
    
    private Map<String,String> QueryDocumentObject(List<String> uniqueNames){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('QueryDocumentObject');
        INTF_DataSync.logSOQL(intMethodCount, 'select Id, DeveloperName from Document where DeveloperName In: uniqueNames');
        List<Document> lstDocs = [select Id, DeveloperName from Document where DeveloperName In: uniqueNames];
        Map<String, String> mapDocRecs = new Map<String, String>();
        for(Document curr : lstDocs){
            mapDocRecs.put(curr.DeveloperName, '/servlet/servlet.FileDownload?file=' + curr.Id);
        }
        INTF_DataSync.logMethodEndTS( intMethodCount, 'QueryDocumentObject');
        return mapDocRecs;
    }
    
     private ParsedHTML parseHTMLForImages(String htmlContent){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('parseHTMLForImages');
        String localHTMLContent = htmlContent, imgExpression, parsedContent = '', imageName, imgContent = '', imgSeperator = '';
        integer startIndex, endIndex, dataIndex, srcIndex, uniqueIndex = 0;
        integer startImageNameIndex, endImageNameIndex;
        Map<integer, String> imageNames = new Map<integer, String>();
        while(true){
            startIndex = localHTMLContent.indexOfIgnoreCase('<img');            
            if(startIndex != -1){
                endIndex = localHTMLContent.indexOf('>', startIndex);
                parsedContent = parsedContent + localHTMLContent.substring(0, startIndex + 4);
                imgContent = localHTMLContent.substring(startIndex + 4, endIndex + 1);
                dataIndex = localHTMLContent.indexOfIgnoreCase('svmx-data', startIndex);
                srcIndex = localHTMLContent.indexOfIgnoreCase('src', startIndex);
                System.debug('endIndex: ' + endIndex + ' ,dataIndex: ' + dataIndex);
                if(dataIndex != -1 && endIndex > dataIndex){
                    //now try to get image name
                    startImageNameIndex = dataIndex + 11;
                    imgSeperator = localHTMLContent.substring(startImageNameIndex-1, startImageNameIndex);
                    System.debug('Image Seperator: ' + imgSeperator);
                    if(imgSeperator == '\"' || imgSeperator == '\''){
                        endImageNameIndex = localHTMLContent.indexOf(imgSeperator, startImageNameIndex);
                        imageName = localHTMLContent.substring(dataIndex + 11, endImageNameIndex);
                        imageNames.put(uniqueIndex, imageName);
                        parsedContent = parsedContent + ' src={'+ uniqueIndex +'} ';
                        imgContent = imgContent.replace('src','src1');
                        uniqueIndex++;
                    }                    
                }
                parsedContent = parsedContent + imgContent;
                localHTMLContent = localHTMLContent.length() > (endIndex + 1)? localHTMLContent.substring(endIndex + 1) : '';
                
            }
            else{
                break;
            }           
        }
        parsedContent = parsedContent + localHTMLContent;
        INTF_DataSync.logMethodEndTS(intMethodCount,'parseHTMLForImages');
        return new ParsedHTML(parsedContent, imageNames);
    }
    
    private class ParsedHTML{
        public string content;
        public Map<Integer, String> imageNames = null;
        ParsedHTML(String content, Map<Integer, String> imageNames){
            this.content = content;
            this.imageNames = imageNames;
        }
    }
    /*
    private string getRecordName(String recId){
        
        String parentName;
        String strNamedField;
        String strObjName;
        if(recId != null && recId != '')
        {
            String ObjectKeyPrefix =  recId.subString(0, 3);
            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            for(String Obj : allObjs.keySet())
            {
                Schema.DescribeSObjectResult R = allObjs.get(Obj).getDescribe();
                if(R.getKeyPrefix() != null && R.getKeyPrefix().equals(ObjectKeyPrefix))
                {
                    strObjName = R.getName();
                    for(String fld : R.fields.getMap().keySet())
                    {
                        if(R.fields.getMap().get(fld).getDescribe().isNameField())
                        {
                            strNamedField = R.fields.getMap().get(fld).getDescribe().getName();
                            break;
                        }
                    }
                    break;
                }
            }
            
            if(strNamedField != null && strNamedField.length() > 0 && strObjName!= null && strObjName.length() > 0)
            {
                String SOQLStr = 'select '+ strNamedField + ' from ' + strObjName + ' where ' + 'id =\'' + recId + '\'';
                sObject ObjRec = database.query(SOQLStr);
                if(((String)ObjRec.get(strNamedField)) != null && ((String)ObjRec.get(strNamedField)).length() > 0)
                    parentName = (String)ObjRec.get(strNamedField);
            }
        }
        return parentName;
                
    }*/
    //executes the query
    public Object submitQuery(SubmitQueryRequest sqr)  {        
        
        SubmitQueryResponse sqRes = new SubmitQueryResponse();
        try{
            List<SObject> recs = Database.query(sqr.Query);
            sqRes.Result = recs;         
        }
        catch(Exception ex){
            sqRes.Status = false;
            sqRes.Message = ex.getMessage();
        }
        return sqRes;      
    }
    
    public Object getDocumentData(GetDocumentDataRequest ddr) {
        OPDOC_GetData getData = new OPDOC_GetData();
        //returns OPDOC_DeliveryImpl.GetDocumentDataResponse as response
        return getData.getDocumentData(ddr);            
    }
    
    public Object getDocumentMetadata(GetDocumentMetadataRequest dmr) {
        
        String processId = dmr.ProcessId;
        GetDocumentMetadataResponse response = null;
        try{
            if(processId == null || processId.length() == 0)
            {
                //TODO: Label goes here
                return '';
            }
            //get the process record ID
            List<SObject> procRec = getProcessNodeInfo(processId);
            
            if(procRec == null || procRec.size() == 0){
                //TODO: Error Label goes here
                return '';
            }
            String docID = String.valueOf(procRec[0].get('SVMXC__Doc_Template__c'));
            if(docID == null || docID.length() == 0){
                //TODO: Error Label goes here
                return '';
            }
            List<SVMXC__Doc_Template__c> templateRec = [Select Id, SVMXC__Media_Resources__c from SVMXC__Doc_Template__c where Id = : docID];
            
            //now get the media resources and assign the result to the same field.
            templateRec[0].SVMXC__Media_Resources__c = getDocumentImagesForStyle(templateRec[0].SVMXC__Media_Resources__c);
        
            List<SObject> metaRecords = [Select Id, SVMXC__Fields__c, SVMXC__Object_Name__c,SVMXC__Alias__c, SVMXC__Type__c from SVMXC__Doc_Template_Details__c 
                                                            where SVMXC__Doc_Template__c =: docID];
            response = new GetDocumentMetadataResponse(metaRecords);
            response.TemplateRecord = templateRec;
            //By Jaysukh 28 June 2017 added for include specific checklist include
            response.outputDocConfigurationObject = getOutputDocConfiguration(procRec);  
            
        }
        catch(exception ex){
            throw ex;
        }       
        return response;
    }
    
    //added for include specific checklist 
    private OutputDocConfiguration getOutputDocConfiguration(List<SObject> procRec1)
    {

        List<SVMXC__ServiceMax_Processes__c> listSmartDocProcess = [Select Id,SVMXC__SM_Checklist_Version__c,SVMXC__Process2__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Process1__c=:procRec1[0].id and RecordType.Name='Checklist Smart Doc'];
        
        List<Id> listChecklistProcessid = new List<Id>();
        for(SVMXC__ServiceMax_Processes__c smratcDoc : listSmartDocProcess)
        {
           listChecklistProcessid.add(smratcDoc.SVMXC__Process2__c);
        }
         //List of Process Business rule
        System.debug('listChecklistProcessid '+listChecklistProcessid);
         
        List<SVMXC__ServiceMax_Processes__c> listofProcessBusinessrule = [Select Id,SVMXC__SM_Checklist_Version__c,SVMXC__Process2__c,SVMXC__Process3__c from  SVMXC__ServiceMax_Processes__c where (SVMXC__Process2__c IN : listChecklistProcessid and RecordType.Name = 'Process Business Rule' AND SVMXC__Process1__c =: procRec1[0].id)];
          
        Map<Id,Id> chIdwithBrId = new Map<Id,Id>();
        for(SVMXC__ServiceMax_Processes__c itrprocBizzrule : listofProcessBusinessrule)
        {
                
                chIdwithBrId.put(itrprocBizzrule.SVMXC__Process2__c,itrprocBizzrule.SVMXC__Process3__c);
                        
        }
        System.debug('chIdwithBrId '+chIdwithBrId);
        System.debug('chIdwithBrId.values() '+chIdwithBrId.values());
        
        Map<ID,SVMXC__ServiceMax_Processes__c> brIDwithBRObjcet = new Map<ID,SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> listbizzrule=[Select Id, SVMXC__Source_Object_Name__c, SVMXC__Question_Bank__c, SVMXC__Rule_Type__c from SVMXC__ServiceMax_Processes__c where (Id IN:chIdwithBrId.values() and RecordType.Name='Business Rule')];
        System.debug('listbizzrule'+listbizzrule);
        for(SVMXC__ServiceMax_Processes__c itrbizzrule:listbizzrule)
          {
            brIDwithBRObjcet.put(itrbizzrule.id,itrbizzrule);
          }
        System.debug('brIDwithBRObjcet'+brIDwithBRObjcet);
         
        List<SVMXC__ServiceMax_Config_Data__c> listConfigData = [Select Id,SVMXC__Sequence__c,SVMXC__Field_Name__c,SVMXC__Expression_Rule__c,SVMXC__Display_Type__c,SVMXC__Parameter_Type__c,SVMXC__Operand__c,SVMXC__Operator__c, SVMXC__Action_Type__c, SVMXC__Expression_Type__c from SVMXC__ServiceMax_Config_Data__c where (RecordType.Name='Expressions' and  SVMXC__Expression_Rule__c IN : brIDwithBRObjcet.keySet())];
         
        Map<Id,List<SVMXC__ServiceMax_Config_Data__c>> brWithConfigData = new Map<Id,List<SVMXC__ServiceMax_Config_Data__c>>();
        for(SVMXC__ServiceMax_Config_Data__c itrlistConfig : listConfigData)
        {
            if(brWithConfigData.containskey(itrlistConfig.SVMXC__Expression_Rule__c))
            {
                List<SVMXC__ServiceMax_Config_Data__c> listData = brWithConfigData.get(itrlistConfig.SVMXC__Expression_Rule__c);
                listData.add(itrlistConfig);
                brWithConfigData.put(itrlistConfig.SVMXC__Expression_Rule__c,listData);
                
            }else
            {
                brWithConfigData.put(itrlistConfig.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>{itrlistConfig});
                System.debug(itrlistConfig);
            }
            
            System.debug('br'+brWithConfigData);
        }
              
                        
        OutputDocConfiguration docConfig = new OutputDocConfiguration();
        docConfig.processOutputDoc = (SVMXC__ServiceMax_Processes__c )procRec1[0];
            
        List<SelectedChecklistProcess> listOfSelectProc = new List<SelectedChecklistProcess>();
        for(id chids:listChecklistProcessid)
        {
            Id busineesruleId=chIdwithBrId.get(chids);
            SelectedChecklistProcess selectedProc = new SelectedChecklistProcess();
            selectedProc.checklistProcessSFId=chids;
            
            SFM_BizRuleInfo objBizRule = new SFM_BizRuleInfo();
            objBizRule.bizRule = brIDwithBRObjcet.get(busineesruleId);
            objBizRule.bizRuleDetails=brWithConfigData.get(busineesruleId);

            SFM_ProcessBusinessRule objProcessBusinessRule = new SFM_ProcessBusinessRule();
            objProcessBusinessRule.ruleInfo = objBizRule;

            selectedProc.businessRules = objProcessBusinessRule;
            
            listOfSelectProc.add(selectedProc);
        }
        docConfig.lstSelectedChecklistProcess = listOfSelectProc;
        return docConfig;
    }
    //test
    public Object doTargetUpdates(TargetUpdatesRequest tur) {
        System.debug( 'Request: ' + tur);
        if(tur.ProcessId != NULL &&  tur.RecordId != NULL)
            new SFM_SaveTargetRecords().DoHeaderTargetObjectUpdate(tur.ProcessId, tur.RecordId);
        return '';            
    }
    
    private String getDocumentImagesForStyle(String imageNames){
        
        List<SObject> response = new List<SObject>();
        //if the string is empty or null send back the empty list
        if(imageNames != null && imageNames != '' && imageNames.length() > 0){
            //split the string
            List<String> lstStr = imageNames.split(',');
            //query the document object for the images
            response = [SELECT Id, DeveloperName FROM Document where DeveloperName In: (lstStr)];
            //send the images list
        }
        return JSON.serialize(response);        
    }
    
    public Object getObjectDescription(ObjectDescriptionRequest odr) { 
                       
        return new SVMXDescribeObjectUtils().getDescribe(odr.objectName); 
    }   
    
    public Object getUserInfo() {
        
        String userName = UserInfo.getLastName() + (UserInfo.getFirstName() != null ? ' ' + UserInfo.getFirstName() : '');
        GetUserInfoResponse response = new GetUserInfoResponse(UserInfo.getUserId() , 
        userName , 
        UserInfo.getLocale());
        response.setTimezoneOffset(new SVMXC.SVMX_Constant_Utils().getUserTimezoneOffset());
        response.setToday(getToday());
        response.setTomorrow(getTomorrow());
        response.setYesterday(getYesterday());
        response.setNow(getNow()); 
        response.setAddress(getAddress());
        response.setDateFormat(getDateFormat(response.UserId));
        response.UserLanguage = UserInfo.getLanguage(); //Added for the story BAC-5383
        return response;        
    }
    
    private String getDateFormat(String userId){
         return SVMXC.DCON_Configuration_WS.DCON_GetLocalDate_WS(userId);  
    }
    
    public String getAddress(){
        
        String address = '';
        try{
        ORGANIZATION org = [SELECT Street, City, State, Country, PostalCode FROM ORGANIZATION];
        //String address = org.STREET + '\n' + org.City + '\n' + org.State + '\n' + org.Country + '\n' + org.PostalCode;
        
        address = (isHavingSize(org.STREET) ? org.STREET + '\n' : '' ) + 
                  (isHavingSize(org.City) ? org.City + '\n' : '' ) +
                  (isHavingSize(org.State) ? org.State + '\n' : '' ) +
                  (isHavingSize(org.Country) ? org.Country + '\n' : '' ) + 
                  (isHavingSize(org.PostalCode) ? org.PostalCode + '\n' : '' ) ;
        }
        catch(Exception ex){
            //ORGANIZATION cannot be accessed with out view all data        
        }
        return address;
    }
    
    private boolean isHavingSize(String str){
        if(str != null && str.length() > 0){
            return true;
        }
        return false;
    }
    
    private String getToday() {
        
        return system.today().format();
    }
    
    private String getTomorrow() {
        
        return (system.today() + 1).format();
    }
    
    private String getYesterday() {
        
        return (system.today() - 1).format();
    }
    
    private String getNow() {
        
        return system.now().format();
    }
    
    public virtual class AbstractResponse{
        
        public Boolean Status = true;
        public String Message = '';
        public AbstractResponse(){
            
        }       
    }
       
    public class GetUserInfoResponse {
        public String UserId;
        public String UserName;
        public String UserTimeZone;
        public String Today;
        public String Tomorrow;
        public String Yesterday;
        public String Now;
        public String Address;
        public String DateFormat;
        public String TimezoneOffset;
        public String UserLanguage; //Added for the story BAC-5383
        
        public GetUserInfoResponse(String userId, String userName, String userTimeZone) {
            this.UserId = userId;
            this.UserName = userName;
            this.UserTimeZone = userTimeZone;
        }
        
        public void setTimezoneOffset(String TimezoneOffset) {
            this.TimezoneOffset = TimezoneOffset;
        }
        
        public void setToday(String today) {
            this.Today = today;
        }
        
        public void setTomorrow(String tomorrow) {
            this.Tomorrow = tomorrow;
        }
        
        public void setYesterday(String yesterday) {
            this.Yesterday = yesterday;
        }
        
        public void setNow(String now) {
            this.Now = now;
        }
        
        public void setAddress(String address) {
            this.Address = address;
        }
        
        public void setDateFormat(String dateFormat){
            this.DateFormat = dateFormat;
        }
    }
  
    public class GetTemplateRequest {
        public String ProcessId;
    }
    
    public class GetTemplateResponse {
        public String Template;
        
        public GetTemplateResponse(String template){
            this.Template = template;
        }
    }
            
    public class SubmitDocumentRequest {
        public String Document;
    }
    
    public class SubmitDocumentResponse extends AbstractResponse{
        public String DocumentId;
        
        public SubmitDocumentResponse(String docId){
            this.DocumentId = docId;
        }
    }
         
    public class CreatePDFRequest {
        public String DocumentId;
        public String RecordId;
        public String ProcessId;
        public String DisplayFileName;//Added for BAC-6180
    }
    
    public class CreatePDFResponse extends AbstractResponse{
        public String PDFAttachmentId;
        
        public CreatePDFResponse(){
            
        }
    }
    
    public class TargetUpdatesRequest {
        public String ProcessId;
        public String RecordId;
    }
    
    public class SubmitQueryRequest {
        public String Query;
    }
    
    public class SubmitQueryResponse extends AbstractResponse{
        public List<SObject> Result;
        
        public SubmitQueryResponse(List<SObject> result){
            this.Result = result;
        }
        public SubmitQueryResponse(){
            
        }
    }
    
    public class GetDocumentDataRequest {
        public String RecordId;
        public String ProcessId;
    }
    
    public class GetDocumentDataResponse extends AbstractResponse{
        
        public List<DocumentData> DocumentData = new List<DocumentData>(); 
        
        public GetDocumentDataResponse(List<DocumentData> documentData){
            this.DocumentData = documentData;
        }
        
        public GetDocumentDataResponse(){
            
        }
    }
    
    public class DocumentData {
        
        public String Key;
        public List<SObject> Records;
        public List<RelatedRecordData> relatedRecords;
        public List<ValueWrapperMap> SpecialFields;
        public DocumentData(String key , List<SObject> records, List<ValueWrapperMap> specialFlds){
            this.Key = key;
            this.Records = records;
            this.SpecialFields = specialFlds;
        }
        public DocumentData(String key , List<SObject> records, List<ValueWrapperMap> specialFlds, List<RelatedRecordData> relatedRecords){
            this.Key = key;
            this.Records = records;
            this.SpecialFields = specialFlds;
            this.relatedRecords = relatedRecords;
        }        
    }
    
    public class RelatedRecordData{
        public String headerRecordId;
        public List<Sobject> records;
        public RelatedRecordData(String headerRecordId, List<Sobject> records){
            this.headerRecordId = headerRecordId;
            this.records = records;
        }
    }
    
    public class ValueWrapperMap {
        
        public String Key;
        public List<ValueWrapper> Value;
        public ValueWrapperMap(String key, List<ValueWrapper> value){
            this.Key = key;
            this.Value = value;
        }
    }
    
    public class ValueWrapper {
        
        public String Key;
        public String Value;
        public String Info;
        public ValueWrapper(String key, String value, String info){
            this.Key = key;
            this.Value = value; 
            this.Info = info;
        }
    }
    
    public class GetDocumentMetadataRequest {
        public String ProcessId;
    }
    
    public class GetDocumentMetadataResponse {
        public List<SObject> AllObjectInfo;
        public List<SObject> TemplateRecord;
       
        public OutputDocConfiguration outputDocConfigurationObject;
        public GetDocumentMetadataResponse(List<SObject> allObjectInfo){
            this.AllObjectInfo = allObjectInfo;
        }
        
        public GetDocumentMetadataResponse(){
        }
    }
    //added for include specific checklist 
    public class OutputDocConfiguration
    {
        public SVMXC__ServiceMax_Processes__c processOutputDoc;
        public List<SelectedChecklistProcess> lstSelectedChecklistProcess;
    }
    //added for include specific checklist 
    public class SelectedChecklistProcess{
        String checklistProcessSFId;
        SFM_ProcessBusinessRule businessRules = new SFM_ProcessBusinessRule();
    }
    public class SFM_ProcessBusinessRule
    {
        SFM_BizRuleInfo ruleInfo = new SFM_BizRuleInfo();
    }
    public class SFM_BizRuleInfo
    {
        SVMXC__ServiceMax_Processes__c bizRule = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c> bizRuleDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
    }
    
    public class ObjectDescriptionRequest {
        public String objectName;
    }
        
    public class MetadataWrapper{
        
        public String OBJ, FN, ROBJ, TYP, RLN, RFN, ROBJ2, RTYP, RLN2, RFN2;
        
        public MetadataWrapper(String obj, String fn, String robj, String typ, 
                                String rln, String rfn, String robj2, String rtyp, String rln2, String rfn2){
            
            OBJ = obj;
            FN = fn;        
            ROBJ = robj;
            TYP = typ;      
            RLN = rln;
            RFN = rfn;
            ROBJ2 = robj2;
            RTYP = rtyp;
            RLN2 = rln2;
            RFN2 = rfn2;
            
        }
        
        public MetadataWrapper(){
        
        }
        
        public List<MetadataWrapper> convertMetadataJson(String jsonMetadata){
            
            List<MetadataWrapper> lstMetadata = new List<MetadataWrapper>();
            if(jsonMetadata == null || jsonMetadata.length() == 0) return lstMetadata;          
            JSONParser parser = JSON.createParser(jsonMetadata);
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        
                            MetadataWrapper currMetadata = (MetadataWrapper) parser.readValueAs(MetadataWrapper.class);
                            parser.skipChildren();
                            lstMetadata.add(currMetadata);
                        }
                    }
                }
            }
            return lstMetadata;     
        }
        
    }
    
    /*Methods to deal for Offline PDF Generation*/
    //Two calls will be made for PDF Generation
    //One is to parse and attach to the same record
     public void offlineSubmitDocuments(List<String> htmlAttachmentIds, List<String> signatureIds){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('offlineSubmitDocuments');
        System.debug('Server Location: ' + getServerLoc());
        Map<String, String> mapAttachementIdBody = new Map<String, String>();
        Map<String, String> mapSignatureIdName = new Map<String, String>();
        Map<String, Attachment> mapHTMLAttachments = new Map<String, Attachment>();
        INTF_DataSync.logSOQL(intMethodCount , 'Select Id, Body, Name from Attachment where Id In: htmlAttachmentIds');
        List<Attachment> lstHTMLAttachments = [Select Id, Body, Name from Attachment where Id In: htmlAttachmentIds];
        for(Attachment currAttach : lstHTMLAttachments){
            mapAttachementIdBody.put(currAttach.Id, currAttach.Body.toString());
            mapHTMLAttachments.put(currAttach.Id, currAttach);          
        }
        
        INTF_DataSync.logSOQL(intMethodCount , 'Select Id, Name from Attachment where Id In: signatureIds');
        List<Attachment> lstSignatureAttachments = [Select Id, Name from Attachment where Id In: signatureIds];
        for(Attachment currAttach : lstSignatureAttachments){
            mapSignatureIdName.put(currAttach.Name, '/servlet/servlet.FileDownload?file=' + currAttach.Id);
        }
        
        // call the parsing utility
        String document = null;
        Attachment attachment = null;
        for(String recId : mapAttachementIdBody.keySet()){
            document = mapAttachementIdBody.get(recId);
            attachment = mapHTMLAttachments.get(recId);
            System.debug('before Parsing: ' + document);
            List<String> processedDocument = parseForStyle(document);
            System.debug('after Parsing: ' + processedDocument.get(1));
            String styleTag = processedDocument.get(0);         
            document = ReplaceHTMLImagesSrc(processedDocument.get(1), mapSignatureIdName);
            document = '<html><head><style type=\"text/css\">' + styleTag + '</style>' + 
                +' <style>body {font-family: Arial Unicode MS;}</style></head>' + document + '</html>';
            
            attachment.Body = Blob.valueof(document);            
        }
        
        update mapHTMLAttachments.values();
        INTF_DataSync.logMethodEndTS(intMethodCount, 'offlineSubmitDocuments');
    }
    
    //Second is to Load the attachment and generate the PDF.
    public void offlineCreatePDF(List<String> htmlAttachmentIds, List<String> signatureIds){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('offlineCreatePDF');
        System.debug('All HTML Attachments: ' + htmlAttachmentIds);
        System.debug('All Signature Attachments: ' + signatureIds);
        
        INTF_DataSync.logSOQL(intMethodCount , 'Select Id, Body, Name, ContentType, ParentId from Attachment where Id In: htmlAttachmentIds');
        Map<Id, Attachment> mapHTMLAttachments = new Map<Id, Attachment>([Select Id, Body, Name, ContentType, ParentId from Attachment where Id In: htmlAttachmentIds]);
        INTF_DataSync.logSOQL(intMethodCount ,'select Id from Attachment where Id In: signatureIds');
        List<Attachment> lstSignAttachements = [select Id from Attachment where Id In: signatureIds];
        PageReference pageRef = null;Blob pdf  = null;
        for(String currRecId : mapHTMLAttachments.keySet()){
            //pageRef = new PageReference('https://c.'+ getServerLocForOffline() +'.content.force.com/servlet/servlet.FileDownload?file=' + mapHTMLAttachments.get(currRecId).Id);
            pageRef = new PageReference('/servlet/servlet.FileDownload?file=' + mapHTMLAttachments.get(currRecId).Id);                
             
            System.debug('Content Before PDF: ' + mapHTMLAttachments.get(currRecId).Body.toString());
            pdf = pageRef.getContentAsPDF();
            mapHTMLAttachments.get(currRecId).Body = pdf;
            mapHTMLAttachments.get(currRecId).ContentType = 'application/pdf';
            mapHTMLAttachments.get(currRecId).Name = getPDFName(mapHTMLAttachments.get(currRecId).Name);
            
            INTF_DataUtilityServices.lstSignatureIds.add(currRecId);                       
        }
        update mapHTMLAttachments.values(); 
        
        delete lstSignAttachements;
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'offlineCreatePDF');
    }
    
    private String getPDFName(String htmlName){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getPDFName');
        String pdfName = '';
        if(htmlName.indexOf('.html') > 0){
            pdfName = htmlName.substring(0, htmlName.indexOf('.html')) + '.pdf';
        }
        else
            pdfName = htmlName + '.pdf';
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getPDFName');
        return pdfName;
    }
    
    
    /*End*/
    
}