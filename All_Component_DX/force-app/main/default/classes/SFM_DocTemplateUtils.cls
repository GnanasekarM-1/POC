/**
 * @description : This class implements the core methods of SFM Output Doc .
 
 * @author      Amar Joshi
 * @date        11.10.2012 
 * !!! Note :  
 */
//Code Added for Salesforce file V0.6
public with sharing class SFM_DocTemplateUtils {

    //This method accepts Template Id and returns Template information.
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetDocTemplateInfo(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        String strTemplateId = '';
        if(request != null && request.stringMap != null && request.stringMap.size() > 0){
            for(Integer i =0;i<request.stringMap.size();i++){
                if(request.stringMap[i].key.equals('TEMPLATEID')){
                    strTemplateId = request.stringMap[i].value;
                }
            }
        }
        system.debug('strTemplateId'+strTemplateId);
        if(strTemplateId != null && strTemplateId.length() > 0){
            
            SVMXC__Doc_Template__c objDocTemplate = [select Id, Name, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Template_Id__c from SVMXC__Doc_Template__c where Id =: strTemplateId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            list<SVMXC__Doc_Template_Details__c> lstDocTemplateDetails = [Select Id, Name, SVMXC__Doc_Template__c, SVMXC__Object_Name__c, SVMXC__Doc_Template_Detail_Id__c, SVMXC__Alias__c  from SVMXC__Doc_Template_Details__c where SVMXC__Doc_Template__c =: strTemplateId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            list<Attachment> lstAttachment = [select Body,BodyLength,ContentType,CreatedDate,Description,Id,IsPrivate,LastModifiedDate,Name,OwnerId,ParentId FROM Attachment where ParentId =: strTemplateId and Name like 'SFM_Doc_Template%']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            //Added for Salesforce file ---BAC-4074
            ContentVersion cvDetails = new ContentVersion();
            ContentDocumentLink cdlink = new ContentDocumentLink();
            if(lstAttachment.size() == 0){
                List<Id> listOfParentIds = new List<Id>();
                List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
                listOfParentIds.add(Id.valueOf(strTemplateId));
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
            // End Salesforce file ---BAC-4074
            
            if(lstAttachment.size() > 0)
                response.docTemplate = new SVMXC.SFM_WrapperDef.SFM_DocTemplate(objDocTemplate,lstDocTemplateDetails,lstAttachment[0],lstAttachment[0].Body.toString());
            else if(cvDetails != null && cvDetails.id != null && cvDetails.VersionData != null)
                //Added for Salesforce file ---BAC-4074
                response.docTemplate = new SVMXC.SFM_WrapperDef.SFM_DocTemplate(objDocTemplate,cvDetails,lstDocTemplateDetails,cvDetails.VersionData.toString());
            else
                response.docTemplate = new SVMXC.SFM_WrapperDef.SFM_DocTemplate(objDocTemplate,lstDocTemplateDetails,null,null);
        }
        
        system.debug('docTemplate'+response.docTemplate);
        response.success = true;
        return response;
    }
    
    //This method accepts object API Name and return list of appliable doc templates to that object 
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetListOfDocTemplates(SVMXC.SFM_WrapperDef.SFM_Request request){
        
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        String strHeaderObjName = '';
        list<String> lstDetailObjName = new List<String>();
        list<String> lstAllObj = new List<String>();
         
        if(request != null && request.stringListMap != null && request.stringListMap.size() > 0){
            for(Integer i=0;i<request.stringListMap.size();i++)
            {
                if(request.stringListMap[i].key.equals('TARGET') && request.stringListMap[i].valueList != null){
                    strHeaderObjName = request.stringListMap[i].valueList[0];
                    lstAllObj.add(request.stringListMap[i].valueList[0]);
                }
                else if(request.stringListMap[i].key.equals('TARGETCHILD') && request.stringListMap[i].valueList != null){
                    lstDetailObjName = request.stringListMap[i].valueList;
                    lstAllObj.addall(lstDetailObjName);
                }
            }
        }
        system.debug('strHeaderObjName'+strHeaderObjName);
        system.debug('lstDetailObjName'+lstDetailObjName.size()+lstDetailObjName);
            
        if(strHeaderObjName != null && strHeaderObjName.length() > 0){
            list<SVMXC__Doc_Template_Details__c> lstDocTemplateDetails = null;
            map<Id,list<String>> mapDocTempIdlstDetailObj = new map<Id,list<String>>();
            map<Id,SVMXC__Doc_Template__c> mapDocTemplate = new map<Id,SVMXC__Doc_Template__c>();
            set<Id> setDocTempId = new set<Id>();
            
            
            lstDocTemplateDetails = [Select Id, Name, SVMXC__Doc_Template__c, SVMXC__Doc_Template__r.Id, SVMXC__Object_Name__c, SVMXC__Doc_Template_Detail_Id__c, SVMXC__Alias__c from SVMXC__Doc_Template_Details__c where SVMXC__Doc_Template__r.SVMXC__Detail_Object_Count__c =: lstDetailObjName.size()]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('lstDocTemplateDetails'+lstDocTemplateDetails);
            if(lstDocTemplateDetails.size() > 0){
                for(SVMXC__Doc_Template_Details__c DTD : lstDocTemplateDetails){
                    setDocTempId.add(DTD.SVMXC__Doc_Template__r.Id);
                }
            }
            if(setDocTempId.size() > 0){
                
                mapDocTemplate.putall([select Id, Name, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Template_Id__c from SVMXC__Doc_Template__c where Id =: setDocTempId]); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstDocTemplateDetails.clear();
                lstDocTemplateDetails = [Select Id, Name, SVMXC__Doc_Template__c, SVMXC__Doc_Template__r.Id, SVMXC__Object_Name__c, SVMXC__Doc_Template_Detail_Id__c, SVMXC__Alias__c from SVMXC__Doc_Template_Details__c where SVMXC__Doc_Template__c IN : setDocTempId and SVMXC__Object_Name__c != null and (SVMXC__Type__c = 'Header_Object' OR SVMXC__Type__c = 'Detail_Object')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
            }
            if(lstDocTemplateDetails.size() > 0){
                for(SVMXC__Doc_Template_Details__c docTempDetail : lstDocTemplateDetails){
                    if(mapDocTempIdlstDetailObj.containskey(docTempDetail.SVMXC__Doc_Template__c)){
                        mapDocTempIdlstDetailObj.get(docTempDetail.SVMXC__Doc_Template__c).add(docTempDetail.SVMXC__Object_Name__c);
                    }
                    else{
                        mapDocTempIdlstDetailObj.put(docTempDetail.SVMXC__Doc_Template__c,new list<String>());
                        mapDocTempIdlstDetailObj.get(docTempDetail.SVMXC__Doc_Template__c).add(docTempDetail.SVMXC__Object_Name__c);
                    }
                }
            }
            system.debug('mapDocTempIdlstDetailObj'+mapDocTempIdlstDetailObj);
            if(mapDocTempIdlstDetailObj.size() > 0){
                
                if(lstDetailObjName.size() == 0){
                    system.debug('Entered in header');
                    for(String str : mapDocTempIdlstDetailObj.keyset()){
                        if(mapDocTempIdlstDetailObj.get(str).size() == 1 && mapDocTempIdlstDetailObj.get(str)[0] == strHeaderObjName && mapDocTemplate.containskey(str)){
                            response.records.add(mapDocTemplate.get(str));
                        }   
                    }
                }
                else{
                    system.debug('Entered in Detail');
                    if(mapDocTempIdlstDetailObj.size() > 0){
                        for(String str : mapDocTempIdlstDetailObj.keyset()){
                            list<String> lstObject = new list<String>();
                            lstObject = mapDocTempIdlstDetailObj.get(str);
                            if(lstAllObj.size() == lstObject.size() && mapDocTemplate.containskey(str)){
                                lstObject.sort();
                                lstAllObj.sort();
                                Boolean isValid = true;
                                for(Integer i = 0;i<lstAllObj.size();i++){
                                    if(lstAllObj[i] != lstObject[i])
                                        isValid = false;
                                }
                                if(isValid)
                                    response.records.add(mapDocTemplate.get(str));
                            }
                        }
                    }
                }    
            }     
        }
        system.debug('Response Rec: '+response.records);    
        return response;
    }

    //This method accepts Doc Template SFDC Id and delete those Doc Template Records
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_DeleteDocTemplate(SVMXC.SFM_WrapperDef.SFM_Request request){
        
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        response.success = true;
        savepoint sp;
        sp = Database.setSavepoint();
        String strTemplateId = '';
        String strProcessId = ''; 
        if(request != null && request.stringMap != null && request.stringMap.size() > 0){
            for(Integer i=0;i<request.stringMap.size();i++)
            {
                if(request.stringMap[i].key.equals('TEMPLATEID') && request.stringMap[i].value != null){
                    strTemplateId = request.stringMap[i].value;
                }
                else if(request.stringMap[i].key.equals('PROCESSID') && request.stringMap[i].value != null){
                    strProcessId = request.stringMap[i].value;
                }
            }
        }
        if(strTemplateId != null && strTemplateId.length() > 0 && strProcessId != null && strProcessId.length() > 0){
            list<SVMXC__Doc_Template__c> lstDocTemplate = [select Id from SVMXC__Doc_Template__c where Id =: strTemplateId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstDocTemplate.size() > 0){
                
                list<SVMXC__ServiceMax_Processes__c> lstProcess = [select Id From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Target Manager' and SVMXC__Doc_Template__c =: lstDocTemplate[0].id and Id != : strProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstProcess.size() == 0){
                    
                    list<Attachment> lstAttachment = [Select Id from Attachment where ParentId =: lstDocTemplate[0].id and Name like 'SFM_Doc_Template%']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(lstAttachment.size() > 0){
                        try{
                            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'Attachment' ) ) {
                                
                                delete lstAttachment; //SDL-SVMX-DELETE-FLS-ENFORCED
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                        }
                        catch(DmlException ex){
                            Database.rollback(sp);
                            response.success = false;
                            response.message = ex.getDmlMessage(0);
                            return response;
                        }   
                    }
                    
                    //Added for Salesforce file ---BAC-4074
                    try{
                        List<Id> listOfParentIds = new List<Id>();
                        List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
                        listOfParentIds.add(lstDocTemplate[0].id);
                        if(listOfParentIds.size() > 0)
                            lstCDL = COMM_FileHandlerUtilities.getAllContentDocumentsLinks(null, listOfParentIds);
                        if(lstCDL.size()>0){
                            ContentDocument cdId = new ContentDocument();
                            cdId.id = lstCDL[0].ContentDocumentId;
                            System.debug('ContentDocument that going to be delete '+cdId);
                            //delete the old salesforce file
                            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'ContentDocument' ) ) {
                                delete cdId; //SDL-SVMX-DELETE-FLS-ENFORCED
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                        }
                        
                    }catch(Exception ex){
                        Database.rollback(sp);
                        response.success = false;
                        response.message = ex.getMessage();
                        return response;
                    }
                    //End --BAC-4074
                    
                    try{    
                        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Doc_Template__c' ) ) {
                            
                            delete lstDocTemplate; //SDL-SVMX-DELETE-FLS-ENFORCED
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    }
                    catch(DmlException ex){
                        Database.rollback(sp);
                        response.success = false;
                        response.message = ex.getDmlMessage(0);
                        return response;
                    }   
                }
                else {
                    response.success = false;
                    response.message = system.label.SFM001_TAG304;//'Cannot delete this template. This template is already used in process.'
                    return response;
                }   
            }
        }
        else if(strTemplateId != null && strTemplateId.length() > 0 && (strProcessId == null || strProcessId.length() == 0)){
            
            list<SVMXC__ServiceMax_Processes__c> lstProcess = [select Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Target Manager' and SVMXC__Doc_Template__c =: strTemplateId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstProcess.size() > 0){
                    response.success = false;
                    response.message = system.label.SFM001_TAG304;//'Cannot delete this template. This template is already used in process.'
                    return response;
            }
            else
            {
                
                list<SVMXC__Doc_Template__c> lstDocTemplate = [select Id from SVMXC__Doc_Template__c where Id =: strTemplateId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstDocTemplate.size() > 0){
                    
                    list<Attachment> lstAttachment = [Select Id from Attachment where ParentId =: lstDocTemplate[0].id and Name like 'SFM_Doc_Template%']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(lstAttachment.size() > 0){
                        try{
                            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'Attachment' ) ) {
                                delete lstAttachment; //SDL-SVMX-DELETE-FLS-ENFORCED
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                        }
                        catch(DmlException ex){
                            Database.rollback(sp);
                            response.success = false;
                            response.message = ex.getDmlMessage(0);
                            return response;
                        }   
                    }
                    
                    //Added for Salesforce file ---BAC-4074
                    try{
                        List<Id> listOfParentIds = new List<Id>();
                        List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
                        listOfParentIds.add(lstDocTemplate[0].id);
                        if(listOfParentIds.size() > 0)
                            lstCDL = COMM_FileHandlerUtilities.getAllContentDocumentsLinks(null, listOfParentIds);
                        if(lstCDL.size()>0){
                            ContentDocument cdId = new ContentDocument();
                            cdId.id = lstCDL[0].ContentDocumentId;
                            System.debug('ContentDocument that going to be delete '+cdId);
                            //delete the old salesforce file
                            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'ContentDocument' ) ) {
                                delete cdId; //SDL-SVMX-DELETE-FLS-ENFORCED
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                            
                        }
                    }catch(Exception ex){
                        Database.rollback(sp);
                        response.success = false;
                        response.message = ex.getMessage();
                        return response;
                    }
                    //End ---BAC-4074
                    
                    try{    
                        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Doc_Template__c' ) ) {
                            delete lstDocTemplate; //SDL-SVMX-DELETE-FLS-ENFORCED
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    }
                    catch(DmlException ex){
                        Database.rollback(sp);
                        response.success = false;
                        response.message = ex.getDmlMessage(0);
                        return response;
                    }   
                }
            }
        }    
        return response;
    }
    
    //To Do
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_SaveDocTemplate(SVMXC.SFM_WrapperDef.SFM_Request request){
        system.debug('request'+request);
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC.SFM_WrapperDef.SFM_DocTemplate docTemplate = new SVMXC.SFM_WrapperDef.SFM_DocTemplate(); 
        savepoint sp;
        sp = Database.setSavepoint();
        response.success = true;
        String strSaveType = 'SAVE';
        String strProcessId = '';
        SVMXC__Doc_Template__c objDocTemplate;
        list<SVMXC__Doc_Template_Details__c> lstDocTemplate = new list<SVMXC__Doc_Template_Details__c>();
        Attachment objAttachment = new Attachment();
        ContentVersion cvObj = new ContentVersion();
        if(request != null && request.stringMap != null && request.stringMap.size() > 0){
            for(Integer i=0;i<request.stringMap.size();i++)
            {
                if(request.stringMap[i].key.equals('SAVETYPE') && request.stringMap[i].value != null){
                    strSaveType = request.stringMap[i].value;
                }
                else if(request.stringMap[i].key.equals('PROCESSIDFORCLONE') && request.stringMap[i].value != null){
                    strProcessId = request.stringMap[i].value;
                }
            }
        }
        system.debug('request'+request);
        system.debug('docTemplate'+request.docTemplate);
        system.debug('strSaveType'+strSaveType);
        system.debug('strProcessId'+strProcessId);
        if(request != null && request.docTemplate != null){
            if(strSaveType.equals('INMEMORYCLONE') && strProcessId.length() > 0){
                system.debug('Entered..');
                docTemplate = cloneDocTemplate(request.docTemplate,strProcessId);
                response.docTemplate = docTemplate;
                return response;
            }
            else if(strSaveType.equals('SAVEAS')){
                docTemplate = cloneDocTemplate(request.docTemplate,strProcessId);
            }
            else if(strSaveType.equals('SAVE')){
                docTemplate = request.docTemplate;
            }
            if(docTemplate.templateRecord != null){
                objDocTemplate = docTemplate.templateRecord;
            }   
            if(docTemplate.templateDetails != null && docTemplate.templateDetails.size() > 0){
                lstDocTemplate.addall(docTemplate.templateDetails);
            }   
            if(docTemplate.contentRecord != null){
                objAttachment = docTemplate.contentRecord;
            }
            //Added for Salesforce file ---BAC-4074
            if(docTemplate.contentVersionRecord != null){
                cvObj = docTemplate.contentVersionRecord;
            }
            //Duplicate Template ID Check.
            list<SVMXC__Doc_Template__c> lstDuplicate = new list<SVMXC__Doc_Template__c>();
            if(objDocTemplate != null && objDocTemplate.id != null){
                
                lstDuplicate = [select Id,SVMXC__Template_Id__c from SVMXC__Doc_Template__c where Id !=: objDocTemplate.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            else{
                
                lstDuplicate = [select Id,SVMXC__Template_Id__c from SVMXC__Doc_Template__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            for(SVMXC__Doc_Template__c dp :lstDuplicate){
                if(objDocTemplate.SVMXC__Template_Id__c == dp.SVMXC__Template_Id__c){
                    response.success = false;
                    response.message = system.label.SFM001_TAG305;//'The template ID you have entered already exists. Please enter a unique ID.'
                    return response;
                }
            }
            //Upsert Doc Template.
            try{
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objDocTemplate, COMM_SecurityUtils.Access.Updateable ) ) {
                            
                  upsert objDocTemplate; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                } else {
                  Database.rollback(sp);
                  response.success = false;
                  response.message = System.Label.COMM001_TAG142;
                  return response;
                }
            }
            catch(DmlException ex){
                Database.rollback(sp);
                response.success = false;
                response.message = ex.getDmlMessage(0);
                return response;
            }   
            //Process DocTemplate Details and Upsert. 
            for(SVMXC__Doc_Template_Details__c docTD : lstDocTemplate){
                if(docTD.id == null){
                    docTD.SVMXC__Doc_Template__c = objDocTemplate.id;
                }
            }
            try{
                //upsert lstDocTemplate;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstDocTemplate, COMM_SecurityUtils.Access.Upsertable ) ) {
            
          upsert lstDocTemplate; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
        } else {
          Database.rollback(sp);
          response.success = false;
          response.message = System.Label.COMM001_TAG142;
          return response;
        }
            }
            catch(DmlException ex){
                Database.rollback(sp);
                response.success = false;
                for (Integer i = 0; i < ex.getNumDml(); i++) 
                {
                    response.message = ex.getDmlMessage(i);
                    return response;
                }
            } 
            //Added for Salesforce file ---BAC-4074
            Boolean salesforceFileGlobalValue = COMM_FileHandlerUtilities.checkFileSetting();
            Id contentVersionId;
            if(salesforceFileGlobalValue){
                
                //To delete existing attachment BAC-4074
                if(objAttachment != null && objAttachment.id != null){
                    list<Attachment> lstAttachment = new List<Attachment>();
                    Attachment attachment = new Attachment();
                    attachment.id = objAttachment.id;
                    lstAttachment.add(attachment);
                    if(lstAttachment.size() > 0){
                        try{
                            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'Attachment' ) ) {
                                delete lstAttachment;
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                        }
                        catch(DmlException ex){
                            Database.rollback(sp);
                            response.success = false;
                            response.message = ex.getDmlMessage(0);
                            return response;
                        }   
                    }
                    
                }
                try{
                    if(cvObj.id != null){
                        contentVersionId = cvObj.id;
                        List<ContentVersion> listCvDetails = new List<ContentVersion>();
                        //Create ContentVersion instances
                        listCvDetails.add(COMM_FileHandlerUtilities.createContentVersionInstance(cvObj.id,'SFM_Doc_Template.html',docTemplate.contentBody,null));
                        if(listCvDetails.size()>0){
                            List<Id> lstUpdatedIds = COMM_FileHandlerUtilities.updateContentVersion(listCvDetails);
                            if(lstUpdatedIds.size() == 0){
                                throw new COMM_SecurityUtils.SecurityAccessException( 'ContentVersion unable to update.' );
                            }
                        }
                    }else{
                        //Create ContentVersion instances and insert that
                        contentVersionId = COMM_FileHandlerUtilities.insertOneContentVersion(COMM_FileHandlerUtilities.createContentVersionInstance(null,'SFM_Doc_Template.html',docTemplate.contentBody,null));
                        if(contentVersionId == null){
                            throw new COMM_SecurityUtils.SecurityAccessException( 'ContentVersion unable to create.' );
                        }
                        System.debug('contentVersionId '+contentVersionId);
                        List<Id> listContentVersionIds = new List<Id>();
                        List<ContentDocumentLink> cdlInstance = new List<ContentDocumentLink>();
                        listContentVersionIds.add(contentVersionId);
                        //Get all the ContentDocument ids with ContentVersion ids
                        Map<Id,Id> mapCVandCDids = COMM_FileHandlerUtilities.getContentDocumentsId(listContentVersionIds);
                        for(Id cdId: mapCVandCDids.values()){
                            // Create instances of ContentDocumentLink
                            cdlInstance.add(COMM_FileHandlerUtilities.createContentDocumentLink(objDocTemplate.id,cdId));
                           
                            
                        }
                        
                        //
                        // Insert ContentDocumentLink details
                        List<Id> cdlId = COMM_FileHandlerUtilities.insertContentDocumentLink(cdlInstance);
                        System.debug('cdlId '+cdlId);
                        if(cdlId == null  || cdlId.size() == 0){
                            throw new COMM_SecurityUtils.SecurityAccessException( 'ContentDocumentLink unable to Create.' );
                        }
                        
                        
                        //
                    }
                    
                }
                catch(Exception ex){
                    Database.rollback(sp);
                    response.success = false;
                    response.message = ex.getMessage();
                    return response;
                } 
            }else{
                //End Salesforce file --BAC-4074
            //Process Attachment and Upsert.
            system.debug('objAttachment'+objAttachment);
            objAttachment.Name = 'SFM_Doc_Template.html'; 
            if(objAttachment.ParentId == null)
                objAttachment.ParentId = objDocTemplate.id;
            objAttachment.Body = Blob.valueof(docTemplate.contentBody);
            try{
                //upsert objAttachment;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objAttachment, COMM_SecurityUtils.Access.Upsertable ) ) {
            
          upsert objAttachment; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
        } else {
          Database.rollback(sp);
          response.success = false;
          response.message = System.Label.COMM001_TAG142;
          return response;
        }
            }
            catch(DmlException ex){
                Database.rollback(sp);
                response.success = false;
                response.message = ex.getDmlMessage(0);
                return response;
            }  
                
        }
            
            //Build successful response if everything is save successfully.
            list<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
            if(objDocTemplate.id != null){
                SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('HEADER',objDocTemplate.id);
                lstStringMap.add(stringMap);
            }
            if(lstDocTemplate.size() > 0){
                for(SVMXC__Doc_Template_Details__c detail :lstDocTemplate){
                    SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap(detail.SVMXC__Doc_Template_Detail_Id__c,detail.id);
                    lstStringMap.add(stringMap);
                }
            }
            if(objAttachment.Id != null){
                SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('ATTACHMENT',objAttachment.id);
                lstStringMap.add(stringMap);
            }
            //Added for ContentVersion id response -BAC-4074
            if(contentVersionId != null){
                SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('CONTENTVERSION',contentVersionId);
                lstStringMap.add(stringMap);
            }
            //End --BAC-4074
            if(lstStringMap.size() > 0)
                response.stringMap = lstStringMap;
        }     
        return response;
    }
    //This method will clone doc Template..
    public SVMXC.SFM_WrapperDef.SFM_DocTemplate cloneDocTemplate(SVMXC.SFM_WrapperDef.SFM_DocTemplate docTemplate,String strProcessId){
        map<Id,String> mapTemplateDetailIdTargetObjectLabel = new map<Id,String>();
        if(strProcessId != null && strProcessId.length() > 0){
            
            list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObj = [select Id,SVMXC__Doc_Template_Details__c,SVMXC__Target_Object_label__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: strProcessId and RecordType.Name = 'Process Node Objects' and SVMXC__Page_Layout__c != null and SVMXC__Target_Object_label__c != null]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstProcessNodeObj.size() > 0){
                for(SVMXC__ServiceMax_Processes__c pro : lstProcessNodeObj){
                    if(pro.SVMXC__Doc_Template_Details__c != null && pro.SVMXC__Target_Object_label__c != null){
                        mapTemplateDetailIdTargetObjectLabel.put(pro.SVMXC__Doc_Template_Details__c,pro.SVMXC__Target_Object_label__c);
                    }
                }
            }
        }
        SVMXC.SFM_WrapperDef.SFM_DocTemplate clonedDocTemplate = new SVMXC.SFM_WrapperDef.SFM_DocTemplate();
        if(docTemplate.templateRecord != null){
            clonedDocTemplate.templateRecord = docTemplate.templateRecord.clone(false,true);
            clonedDocTemplate.templateRecord.SVMXC__IsStandard__c = false;
        }   
        if(docTemplate.templateDetails != null && docTemplate.templateDetails.size() > 0){
            Integer i = 0,l = docTemplate.templateDetails.size();
            for(i = 0;i<l;i++){
                Id TemplateDetailId  = docTemplate.templateDetails[i].id;
                SVMXC__Doc_Template_Details__c objDocTemplateDetail = docTemplate.templateDetails[i].clone(false,true);
                objDocTemplateDetail.SVMXC__IsStandard__c = false;
                if(mapTemplateDetailIdTargetObjectLabel.containskey(TemplateDetailId)){
                    objDocTemplateDetail.SVMXC__Doc_Template_Detail_Id__c = mapTemplateDetailIdTargetObjectLabel.get(TemplateDetailId);
                }
                clonedDocTemplate.templateDetails.add(objDocTemplateDetail);
            }
        }
        if(docTemplate.contentRecord != null) 
            clonedDocTemplate.contentRecord = docTemplate.contentRecord.clone(false,true);
        if(docTemplate.contentBody != null) 
            clonedDocTemplate.contentBody = docTemplate.contentBody;
        return clonedDocTemplate;
    }
    //This method will return list of macro.
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetFunctions(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        list<SVMXC.SFM_WrapperDef.SFM_StringSobjectMap> lstSobjectMap = new list<SVMXC.SFM_WrapperDef.SFM_StringSobjectMap>();
        map<String,list<SVMXC__Function_Definition__c>> mapMacroData = new map<String,list<SVMXC__Function_Definition__c>>();
              
        list<SVMXC__Function_Definition__c> lstMacroDef = [select Id, SVMXC__IsActive__c, SVMXC__IsStandard__c, Name,OwnerId,SVMXC__Description__c,SVMXC__Example__c,SVMXC__Macro_Id__c,SVMXC__Macro_Name__c,SVMXC__Syntax__c,toLabel(SVMXC__Type__c) FROM SVMXC__Function_Definition__c where
                                                             SVMXC__IsActive__c = true AND (SVMXC__SM_Entity_Type__c INCLUDES ('OPDOC') OR SVMXC__SM_Entity_Type__c = null) order by SVMXC__IsStandard__c desc]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstMacroDef.size() > 0){
            for(SVMXC__Function_Definition__c md : lstMacroDef){
                if(mapMacroData.containskey(md.SVMXC__Type__c)){
                    mapMacroData.get(md.SVMXC__Type__c).add(md);
                }
                else{
                    mapMacroData.put(md.SVMXC__Type__c,new list<SVMXC__Function_Definition__c>());
                    mapMacroData.get(md.SVMXC__Type__c).add(md);
                }       
            }
            if(mapMacroData.size() > 0){
                for(String str : mapMacroData.keyset()){
                    SVMXC.SFM_WrapperDef.SFM_StringSobjectMap sobjectMap = new SVMXC.SFM_WrapperDef.SFM_StringSobjectMap();
                    sobjectMap.key = str;
                    sobjectMap.records = mapMacroData.get(str);
                    lstSobjectMap.add(sobjectMap);
                }
            }
            
        }
        list<Document> lstDocument = new list<Document>();
        
        lstDocument = [SELECT AuthorId,BodyLength,ContentType,CreatedById,CreatedDate,Description,DeveloperName,FolderId,Id,IsBodySearchable,IsDeleted,IsInternalUseOnly,IsPublic,Keywords,LastModifiedById,LastModifiedDate,Name,NamespacePrefix,SystemModstamp,Type,Url FROM Document where (ContentType = 'Image/png' OR  ContentType = 'Image/jpeg' OR ContentType = 'Image/gif')and Keywords like '%SFM_Output_Document%']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstDocument.size() > 0){
            SVMXC.SFM_WrapperDef.SFM_StringSobjectMap sobjectMap = new SVMXC.SFM_WrapperDef.SFM_StringSobjectMap();
            sobjectMap.key = 'IMAGE';
            sobjectMap.records = lstDocument;
            lstSobjectMap.add(sobjectMap);
        }
        response.sobjectMap = lstSobjectMap;
        system.debug('response'+response);
        return response;
    }
    //This method will return default text for new templeate
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetDefaultOPDOCTemplate(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        
        list<StaticResource> lstNewTemplate = [SELECT Body FROM StaticResource where name = 'Default_Output_Doc_Template' limit 1];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstNewTemplate.size() > 0){
            String strDefaultText = lstNewTemplate[0].Body.toString();
            list<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
            SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
            stringMap.key = 'DEFAULTTEXT';
            stringMap.value = strDefaultText;
            lstStringMap.add(stringMap);
            response.stringMap = lstStringMap;
        }
        return response;
    }

    public List<SFM_WrapperDef2.SFM2_ListViewDetails> SFM_GetListOfDocTemplates_V2(List<SFM_WrapperDef2.SFM2_ObjectInfo> templateObjects){
        List<SVMXC__Doc_Template__c> templateRecordsList = new List<SVMXC__Doc_Template__c>() ;
        List<SFM_WrapperDef2.SFM2_ListViewDetails> listViewDetails = new List<SFM_WrapperDef2.SFM2_ListViewDetails>();
        Set<Id> templateIds = new Set<Id>();
        String parentObject;
        String parentObjectAlias;
        Map<String,String> objectAliasMap = new Map<String,String>();
        
        for(SFM_WrapperDef2.SFM2_ObjectInfo templateObjectInfo : templateObjects){
            if (templateObjectInfo.objectType.equalsIgnoreCase('HEADER')){
                parentObject = templateObjectInfo.apiName;
                parentObjectAlias = templateObjectInfo.objectAlias;
            } else {
                if(templateObjectInfo.objectAlias != null){
                    objectAliasMap.put(templateObjectInfo.objectAlias.replace(' ', '_'), templateObjectInfo.apiName);
                }
            }   
        }
        
        List<String> tempObjectsList;
        Set<Id> qualifiedTemplateIds = new Set<Id>();

        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Doc_Template__c', new List<String>{'Id', 'SVMXC__Detail_Object_Count__c', 'SVMXC__IsStandard__c', 'SVMXC__Media_Resources__c', 'SVMXC__Name__c', 'SVMXC__Template_Id__c', 'LastModifiedDate', 'CreatedDate', 'CreatedBy.Name', 'LastModifiedBy.Name'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }  

        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Doc_Template_Details__c', new List<String>{'Id', 'SVMXC__Object_Name__c', 'SVMXC__Doc_Template__c', 'SVMXC__Type__c', 'SVMXC__Alias__c'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        for(SVMXC__Doc_Template_Details__c templateDetail : [SELECT Id, SVMXC__Object_Name__c, SVMXC__Doc_Template__c FROM SVMXC__Doc_Template_Details__c WHERE SVMXC__Object_Name__c =: parentObject AND SVMXC__Type__c = 'Header_Object' AND SVMXC__Alias__c =: parentObjectAlias]){
            if(templateDetail.SVMXC__Doc_Template__c != null){
                templateIds.add(templateDetail.SVMXC__Doc_Template__c);
            }
        }
        for(SVMXC__Doc_Template__c templateRecord : [SELECT Id, SVMXC__IsStandard__c, SVMXC__Name__c, SVMXC__Template_Id__c, LastModifiedDate, CreatedDate, CreatedBy.Name, LastModifiedBy.Name,
                                                     (SELECT Id, SVMXC__Object_Name__c, SVMXC__Alias__c FROM SVMXC__Doc_Template_Details__r WHERE SVMXC__Type__c = 'Detail_Object') 
                                                     FROM SVMXC__Doc_Template__c WHERE Id IN: templateIds AND SVMXC__Detail_Object_Count__c =: objectAliasMap.size()]){

            
            tempObjectsList = new List<String>();
            tempObjectsList.addAll(objectAliasMap.values());

            boolean hasAll = true;

            if( objectAliasMap.size() != templateRecord.SVMXC__Doc_Template_Details__r.size()){ 
                hasAll = false;
                continue;
            }

            for(SVMXC__Doc_Template_Details__c templateDetailRecord : templateRecord.SVMXC__Doc_Template_Details__r){
                
                if(!objectAliasMap.keySet().contains(templateDetailRecord.SVMXC__Alias__c)){ //sectionRecord.SVMXC__Object_Name__c
                    hasAll = false;
                    continue;
                }else{
                    Integer i = tempObjectsList.indexOf(templateDetailRecord.SVMXC__Object_Name__c);
                    
                    if(i != -1)
                       tempObjectsList.remove(i); 
                }
            }

            if(tempObjectsList.isEmpty() && hasAll){
                templateRecordsList.add(templateRecord);
                qualifiedTemplateIds.add(templateRecord.Id);
            }
        }

        if(!templateRecordsList.isEmpty()){
            
            Set<Id> dependentProcessIds = SFM_GetEntityDependencies.entityDependencyCheck(qualifiedTemplateIds, SFM_DesignerUtils.entity_template);
            for(SVMXC__Doc_Template__c templateRecord : templateRecordsList){
                SFM_WrapperDef2.SFM2_ListViewDetails listItem = new SFM_WrapperDef2.SFM2_ListViewDetails();

                SFM_WrapperDef2.SFM2_EntityDetail entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
                
                entityDetail.entityId = templateRecord.Id;
                entityDetail.isStandard = templateRecord.SVMXC__IsStandard__c;
                //entityDetail.entityDescription = templateRecord.SVMXC__SM_Description__c;
                entityDetail.entityName = templateRecord.SVMXC__Name__c;
                entityDetail.lastModifiedDate = String.valueOfGmt(templateRecord.LastModifiedDate);
                entityDetail.createdDate = String.valueOfGmt(templateRecord.CreatedDate);
                entityDetail.createdBy = templateRecord.CreatedBy.Name;
                entityDetail.lastModifiedBy = templateRecord.LastModifiedBy.Name;
                listItem.entityDetail = entityDetail;
                if(dependentProcessIds.contains(templateRecord.Id)){
                    listItem.dependencyExist = true;
                }
                listViewDetails.add(listItem);
            }
        }

        return listViewDetails;              
    }

    public SFM_WrapperDef2.SFM2_DocTemplate cloneDocTemplate_V2(List<String> entityIds){
        SFM_WrapperDef2.SFM2_DocTemplate templateInfo;
        
        if(entityIds.size() == 1){


            List<SVMXC__Doc_Template__c> templateRecordsList = queryTemplateRecords(entityIds); 
            
            if(!templateRecordsList.isEmpty()){
                Id entityId = entityIds[0];
                templateInfo = templateValueWrapper(templateRecordsList[0]);
                Set<Id> dependentProcessIds = SFM_GetEntityDependencies.entityDependencyCheck(new Set<Id>{entityId}, SFM_DesignerUtils.entity_template);
                templateInfo.dependencyExist = dependentProcessIds.contains(entityId) ? true: false;
            
            }else{
                System.debug( System.LoggingLevel.ERROR, 'Requested entity does not exist. Template Id=' + entityIds[0]);
                throw new SFM_DesignerUtils.ServicemaxNestedException( 'Record does not exists for requested id.');
            }

        }

        return templateInfo;                           
    }

    public void saveDocTemplate_V2(SFM_WrapperDef2.SFM2_DocTemplate templateInfo, COMM_AuditTrail.AuditData auditData){
        if( templateInfo != null && templateInfo.entityDetail != null ){
            Set<Id> templateDetailIds = new Set<Id>();
            SVMXC__Doc_Template__c docTemplateHeader = new SVMXC__Doc_Template__c ();
            SFM_WrapperDef2.SFM2_EntityDetail entityDetail = templateInfo.entityDetail;

            if(SFM_DesignerUtils.isEntityNameAlreadyUsed(entityDetail.entityName, SFM_DesignerUtils.entity_template, entityDetail.entityId)){
                System.debug( System.LoggingLevel.ERROR, 'Duplicate Name already exists');
                throw new SFM_DesignerUtils.ServicemaxNestedException( System.Label.SFM001_TAG685);
            }
            String action = entityDetail.entityId == null ? System.Label.AUDIT001_TAG034 + entityDetail.entityName : System.Label.AUDIT001_TAG035 + entityDetail.entityName;
            String actionType = entityDetail.entityId == null ? System.Label.AUDIT001_TAG009 : System.Label.AUDIT001_TAG010;
            
            if(entityDetail.entityId != null){
                docTemplateHeader.Id = entityDetail.entityId;
            }else{
                docTemplateHeader.SVMXC__Template_Id__c = SFM_DesignerUtils.generateUniqueId('TEM');
            }

            docTemplateHeader.SVMXC__Name__c = entityDetail.entityName;
            docTemplateHeader.SVMXC__Media_Resources__c = templateInfo.resources;
            docTemplateHeader.SVMXC__SM_Description__c = entityDetail.entityDescription;

            Savepoint sp = Database.setSavepoint();

            try {
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(docTemplateHeader, COMM_SecurityUtils.Access.Upsertable)){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                }

                upsert docTemplateHeader;
                entityDetail.entityId = docTemplateHeader.Id;
                Attachment templateAttachmentRecord = new Attachment(ParentId = docTemplateHeader.Id);

                if(templateInfo.templateDetails != null && !templateInfo.templateDetails.isEmpty()){
                    List<SVMXC__Doc_Template_Details__c> docTemplateDetailList = new List<SVMXC__Doc_Template_Details__c>();
                    Map<String, SFM_WrapperDef2.SFM2_DocTemplateDetail> templateDetailMap = new Map<String, SFM_WrapperDef2.SFM2_DocTemplateDetail>();

                    for(SFM_WrapperDef2.SFM2_DocTemplateDetail templateDetail : templateInfo.templateDetails){
                        SVMXC__Doc_Template_Details__c templateDetailRecord = new SVMXC__Doc_Template_Details__c(SVMXC__Doc_Template__c = docTemplateHeader.Id);
                        if(templateDetail.recordId != null){
                            templateDetailRecord.Id = templateDetail.recordId;
                        }
                        templateDetailRecord.SVMXC__Type__c = templateDetail.objectType;
                        templateDetailRecord.SVMXC__Object_Name__c = templateDetail.objectAPIName;
                        templateDetailRecord.SVMXC__Doc_Template_Detail_Id__c = templateDetail.templateDetailId;
                        templateDetailRecord.SVMXC__Alias__c = templateDetail.templateAlias;
                        templateDetailRecord.SVMXC__Fields__c = templateDetail.metaData;
                        templateDetailRecord.SVMXC__SOQL__c = templateDetail.soqlData;
                        templateDetailRecord.SVMXC__Header_Reference_Field__c = templateDetail.referenceField;
                        templateDetailMap.put(templateDetailRecord.SVMXC__Alias__c, templateDetail);
                        docTemplateDetailList.add(templateDetailRecord);
                    }

                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(docTemplateDetailList, COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                    } 
                    
                    upsert docTemplateDetailList;

                    for(SVMXC__Doc_Template_Details__c templateDetailRecord : docTemplateDetailList){
                        
                        if(templateDetailRecord.SVMXC__Alias__c != null && templateDetailMap.containsKey(templateDetailRecord.SVMXC__Alias__c)){
                            SFM_WrapperDef2.SFM2_DocTemplateDetail templateDetail = templateDetailMap.get(templateDetailRecord.SVMXC__Alias__c);
                            templateDetail.recordId = templateDetailRecord.Id;
                        }

                        templateDetailIds.add(templateDetailRecord.Id);
                    }
                }

                if(templateInfo.templateContent != null){
                    Boolean filesEnabled = COMM_FileHandlerUtilities.checkFileSetting();
                    if(templateInfo.contentType == null){
                        templateInfo.contentType = filesEnabled ? 'File': 'Attachment';
                    }
                    if(filesEnabled){
                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('ContentDocument', new List<String>{'Id', 'LatestPublishedVersionId'}, COMM_SecurityUtils.Access.Accessible)){
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('ContentDocumentLink', new List<String>{'Id', 'ContentDocumentId'}, COMM_SecurityUtils.Access.Accessible)){
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        List<ContentVersion> contentVersionList  = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: templateInfo.templateContentId];
                        ContentVersion conVer = new ContentVersion();
                        conVer.Title = 'SFM_Doc_Template.html';
                        if (!contentVersionList.isEmpty()) {
                            conVer.Id = templateInfo.templateContentId;
                            conVer.VersionData = Blob.valueof(templateInfo.templateContent);
                            upsert conVer;
                        } else {
                            conVer.VersionData = Blob.valueof(templateInfo.templateContent);
                        conVer.PathOnClient = 'SFM_Doc_Template.html';
                        conVer.IsMajorVersion = false;
                        if(templateInfo.contentType == 'File'){
                            if(templateInfo.templateContentId != null){
                                conVer.Id = templateInfo.templateContentId;
                            }
                        }else if(templateInfo.contentType == 'Attachment'){
                            templateInfo.templateContentId = null;
                        }
                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(conVer, COMM_SecurityUtils.Access.Upsertable)){
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                        }
                        upsert conVer;
                        if(templateInfo.templateContentId == null){
                            List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =: conVer.Id];
                            if(!contentDocumentList.isEmpty()){
                                ContentDocument conDoc = contentDocumentList[0];
                                ContentDocumentLink conDocLink = new ContentDocumentLink(ContentDocumentId = conDoc.Id);
                                conDocLink.LinkedEntityId = entityDetail.entityId;
                                conDocLink.ShareType = 'I';
                                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(conDocLink, COMM_SecurityUtils.Access.Upsertable)){
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                                }
                                insert conDocLink;
                            }
                        }
                        }
                        List<Attachment> attachmentList = [SELECT Id, Body FROM Attachment WHERE ParentId =:entityDetail.entityId AND Name LIKE 'SFM_Doc_Template%'];
                        if(!attachmentList.isEmpty()){
                            if(!COMM_SecurityUtils.getInstance().isDeletableObject('Attachment')){
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                            delete attachmentList;
                        }
                        templateInfo.templateContentId = conVer.Id;
                    }else{
                        // Attachment templateAttachmentRecord = new Attachment(ParentId = docTemplateHeader.Id);
                        if(templateInfo.contentType == 'Attachment' && templateInfo.templateContentId != null) {
                       templateAttachmentRecord.Id = templateInfo.templateContentId;
                    }
                    templateAttachmentRecord.Name = 'SFM_Doc_Template.html';
                    templateAttachmentRecord.Body = Blob.valueof(templateInfo.templateContent);
                    
                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(templateAttachmentRecord, COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                    }

                    upsert templateAttachmentRecord;
                        List<ContentDocument> contentDocumentList = new List<ContentDocument>();
                        for (ContentVersion contentVersion : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: templateInfo.templateContentId]) {
                            contentDocumentList.add(new ContentDocument( Id = contentVersion.ContentDocumentId ));
                        }
                        if (!contentDocumentList.isEmpty()) {
                            if(!COMM_SecurityUtils.getInstance().isDeletableObject('ContentDocument')) {
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                            delete contentDocumentList;
                        }
                    templateInfo.templateContentId = templateAttachmentRecord.Id;
                }
                }

                // Create audit trail for document template creation and deletion.
                COMM_AuditTrail.AuditTrailInfo auditTrailInfo = new COMM_AuditTrail.AuditTrailInfo();
                auditTrailInfo.entityName = System.Label.AUDIT001_TAG014;
                auditTrailInfo.application = System.Label.AUDIT001_TAG002;
                auditTrailInfo.actionType = actionType;
                auditTrailInfo.action = action;
                auditTrailInfo.internalId = docTemplateHeader.Id;
                COMM_AuditTrail.getInstance().logAudit(auditTrailInfo, auditData);
                deleteRecords(docTemplateHeader.Id, templateDetailIds, templateAttachmentRecord.Id, templateInfo.templateContentId);

                Set<Id> dependentProcessIds = SFM_GetEntityDependencies.entityDependencyCheck(new Set<Id>{docTemplateHeader.Id}, SFM_DesignerUtils.entity_template);
                templateInfo.dependencyExist = dependentProcessIds.contains(docTemplateHeader.Id) ? true: false;

            }catch(DmlException ex){
                System.debug(System.LoggingLevel.Error, 'DML Exception Occurred!!! Method: saveDocTemplate_V2' + ex.getMessage());
                Database.rollback(sp);
                throw ex;
            }catch(exception ex){
                System.debug('Exception Occurred!!! Method: saveDocTemplate_V2' + ex.getStackTraceString());
                Database.rollback(sp);
                throw ex;
            }finally{
                System.debug( System.LoggingLevel.DEBUG, 'saveDocTemplate_V2() - exit; return value ' + templateInfo);
            }

        }        
    }

    public List<SVMXC__Doc_Template__c> queryTemplateRecords(List<String> entityIds){
        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Doc_Template__c', new List<String>{'Id', 'SVMXC__Name__c', 'SVMXC__Detail_Object_Count__c', 'SVMXC__IsStandard__c', 'SVMXC__Template_Id__c', 'SVMXC__Media_Resources__c','SVMXC__SM_Description__c'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Doc_Template_Details__c', new List<String>{'Id', 'SVMXC__Alias__c', 'SVMXC__Doc_Template__c', 'SVMXC__Doc_Template_Detail_Id__c', 'SVMXC__Doc_Template_Detail_Unique_Id__c',
            'SVMXC__Fields__c', 'SVMXC__Header_Reference_Field__c', 'SVMXC__IsStandard__c', 'SVMXC__Object_Name__c', 'SVMXC__SOQL__c', 'SVMXC__Type__c'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('Attachment', new List<String>{'Body', 'BodyLength', 'ContentType', 'CreatedDate', 'Description', 'Id', 'IsPrivate', 'LastModifiedDate', 'Name', 'OwnerId', 'ParentId'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('ContentDocumentLink', new List<String>{'Id', 'ContentDocument.LatestPublishedVersionId', 'ContentDocument.LatestPublishedVersion.VersionData','ContentDocument.LatestPublishedVersion.Title'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        return [SELECT Id, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Media_Resources__c, SVMXC__Template_Id__c, SVMXC__SM_Description__c, (SELECT Id, SVMXC__Alias__c, SVMXC__Fields__c, 
                SVMXC__Header_Reference_Field__c, SVMXC__IsStandard__c, SVMXC__Object_Name__c, SVMXC__SOQL__c, SVMXC__Type__c, SVMXC__Doc_Template_Detail_Id__c FROM SVMXC__Doc_Template_Details__r) 
                FROM SVMXC__Doc_Template__c WHERE Id IN: entityIds]; 

    }

    SFM_WrapperDef2.SFM2_DocTemplate templateValueWrapper(SVMXC__Doc_Template__c templateRecord){
        SFM_WrapperDef2.SFM2_DocTemplate templateWrapper = new SFM_WrapperDef2.SFM2_DocTemplate();
        SFM_WrapperDef2.SFM2_EntityDetail entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
        entityDetail.entityId = templateRecord.Id;
        entityDetail.isStandard = templateRecord.SVMXC__IsStandard__c;
        entityDetail.entityDescription = templateRecord.SVMXC__SM_Description__c;
        entityDetail.entityName = templateRecord.SVMXC__Name__c;
        templateWrapper.entityDetail = entityDetail; 
        templateWrapper.resources =  templateRecord.SVMXC__Media_Resources__c;
        templateWrapper.templateDetails = templateDetailWrapper(templateRecord.SVMXC__Doc_Template_Details__r);
        
        List<Attachment> attachmentList = [SELECT Id, Body FROM Attachment WHERE ParentId =:templateRecord.Id AND Name LIKE 'SFM_Doc_Template%'];
        if(!attachmentList.isEmpty()){
            Attachment attachmentRecord = attachmentList[0];
            templateWrapper.templateContent = attachmentRecord.Body.toString();
            templateWrapper.templateContentId = attachmentRecord.Id;
            templateWrapper.contentType = 'Attachment';
        }else{
            List<ContentDocumentLink> contentDocumentList = [SELECT Id, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.VersionData FROM
                                                             ContentDocumentLink WHERE LinkedEntityId =: templateRecord.Id AND ContentDocument.LatestPublishedVersion.Title LIKE 'SFM_Doc_Template%'];
            if(!contentDocumentList.isEmpty()){
                ContentDocumentLink cdLink = contentDocumentList[0];
                if(cdlink.ContentDocument.LatestPublishedVersionId != null){
                    templateWrapper.templateContent = cdlink.ContentDocument.LatestPublishedVersion.VersionData.toString();
                    templateWrapper.templateContentId = cdlink.ContentDocument.LatestPublishedVersionId;
                    templateWrapper.contentType = 'File';
                }
            }
        }
        return templateWrapper;
    } 

    List<SFM_WrapperDef2.SFM2_DocTemplateDetail> templateDetailWrapper(List<SVMXC__Doc_Template_Details__c> docTemplateDetails){
        List<SFM_WrapperDef2.SFM2_DocTemplateDetail> templateDetailsWrapperList = new List<SFM_WrapperDef2.SFM2_DocTemplateDetail>();
        for(SVMXC__Doc_Template_Details__c templateDetailRecord : docTemplateDetails){
            SFM_WrapperDef2.SFM2_DocTemplateDetail templateDetailWrapper = new SFM_WrapperDef2.SFM2_DocTemplateDetail();
            templateDetailWrapper.recordId = templateDetailRecord.Id;
            templateDetailWrapper.objectType = templateDetailRecord.SVMXC__Type__c;
            templateDetailWrapper.objectAPIName = templateDetailRecord.SVMXC__Object_Name__c;
            templateDetailWrapper.templateDetailId = templateDetailRecord.SVMXC__Doc_Template_Detail_Id__c;
            templateDetailWrapper.templateAlias = templateDetailRecord.SVMXC__Alias__c;
            templateDetailWrapper.metaData = templateDetailRecord.SVMXC__Fields__c;
            templateDetailWrapper.soqlData = templateDetailRecord.SVMXC__SOQL__C;
            templateDetailWrapper.referenceField = templateDetailRecord.SVMXC__Header_Reference_Field__c;
            templateDetailsWrapperList.add(templateDetailWrapper);
        }
        return templateDetailsWrapperList;
    }

    void deleteRecords(Id templateId, Set<Id> templateDetailIds, String attachmentId, String templateContentId) {

        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__Doc_Template_Details__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if (!COMM_SecurityUtils.getInstance().isDeletableObject('Attachment')) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        if (!COMM_SecurityUtils.getInstance().isDeletableObject('ContentDocument')) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        List<SVMXC__Doc_Template_Details__c> templateDetailDelList = [SELECT Id FROM SVMXC__Doc_Template_Details__c WHERE SVMXC__Doc_Template__c =: templateId AND Id NOT IN: templateDetailIds];
        if(!templateDetailDelList.isEmpty()){
            delete templateDetailDelList;
        }

        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId =: templateId AND Id !=: attachmentId];
        if(!attachmentList.isEmpty()){
            delete attachmentList;
        }
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: templateContentId];
        if (!contentVersionList.isEmpty()) {
            List<ContentDocumentLink> contentDocLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: templateId AND ContentDocumentId !=: contentVersionList[0].ContentDocumentId];
            if (!contentDocLinkList.isEmpty()) {
                ContentDocument contentDocument = new ContentDocument();
                contentDocument.id = contentDocLinkList[0].ContentDocumentId;
                delete contentDocument;
            }
        }
    }
}