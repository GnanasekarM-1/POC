public with sharing class OPDOC_GetData {

    public OPDOC_GetData(){
        //Constructor code goes here
    }
    public String PROCESSREC = 'PROCESSREC';
    public String PROCESSNODEOBJ = 'PROCESSNODEOBJ';
    public String DOCTEMPLATE = 'DOCTEMPLATE';
    public String DOCTEMPLATEDETAILS = 'DOCTEMPLATEDETAILS';
    public String TARGETMANAGER_RECORDTYPE = 'TARGET MANAGER';
    public String PROCESSNODEOBJECT_RECORDTYPE = 'PROCESS NODE OBJECTS';
    public  List<Id> includeChList1=null; 
    public Object getDocumentData(OPDOC_DeliveryImpl.GetDocumentDataRequest ddr){
        OPDOC_DeliveryImpl.GetDocumentDataResponse response =
                                new OPDOC_DeliveryImpl.GetDocumentDataResponse();

        String recordId = ddr.RecordId;
        String processId = ddr.ProcessId;
        Map<String, List<SObject>> processRelatedRecs = null;
        Map<String, String> detailExpression = new Map<String,String>();
        Map<String, String> sortExpression = new Map<String,String>();
        //used to store special fields after massaging for each record
        List<OPDOC_DeliveryImpl.ValueWrapperMap> specialFields = null;
        try{

            //now get the process related records
            System.debug('get document records for process : ' + processId);
            processRelatedRecs = getProcessRelatedRecords(processId);
            System.debug('end document record');
            //get the document data query fields

            //prepare the soql query
            //create map of detail id and expression
            List<SVMXC__ServiceMax_Processes__c> procNodeObjects = processRelatedRecs.get(PROCESSNODEOBJ);
            //detailExpression = getExpressions(procNodeObjects);
            getSortFieldsAndExpr(procNodeObjects,detailExpression,sortExpression);
			
            //BAC-6180 Display Name Field Values
            List<String> displayFields = new List<String>();
            String displayObject = null;
            List<SVMXC__ServiceMax_Processes__c> processObjects = processRelatedRecs.get(PROCESSREC);
            if(processObjects != null && processObjects.size() > 0){
                for(SVMXC__ServiceMax_Processes__c currNodeObj : processObjects){
                    if(currNodeObj.SVMXC__Export_Configuration__c != null){
                        List<SVMXC.SFM_WrapperDef.FormulaObjectField> objectFieldData = (List<SVMXC.SFM_WrapperDef.FormulaObjectField>) JSON.deserialize(currNodeObj.SVMXC__Export_Configuration__c, List<SVMXC.SFM_WrapperDef.FormulaObjectField>.class);
                        for(SVMXC.SFM_WrapperDef.FormulaObjectField data : objectFieldData){
                            if(String.isNotBlank(data.OBJ)){
                                system.debug('OBJ - '+data.OBJ);
                                displayObject = data.OBJ;
                                for(SVMXC.SFM_WrapperDef.FLDS field : data.FLDS){
                                    system.debug('FLDS - '+field.name);
                                    if(String.isNotBlank(field.name)){
                                        displayFields.add(field.name);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            List<SVMXC__Doc_Template_Details__c> docTempDetails = processRelatedRecs.get(DOCTEMPLATEDETAILS);
            if(docTempDetails == null || docTempDetails.size() == 0){
                //TODO: Add a error custom label here
            }

            //execute expression and validate record
            String strSOQLQuery = null;
            boolean isHeaderRecordExists = True;
            List<SObject> lstChecklistRecords = new List<SObject>();
            for(SVMXC__Doc_Template_Details__c currRec : docTempDetails){


                strSOQLQuery = buildSOQLQuery(recordId, currRec, detailExpression,sortExpression,processId,displayFields,displayObject);

                //INFO : as there will be less no of record executing the query in for loop
                //Requirement: Response should be map of alias and query SObject. alias will be there in Doc Template Details
                if(strSOQLQuery == null || strSOQLQuery.length() == 0) continue;
                List<SObject> records;
                List<OPDOC_DeliveryImpl.RelatedRecordData> lstRelatedRecordData = new List<OPDOC_DeliveryImpl.RelatedRecordData>();
                if(isHeaderRecordExists){
                    
                    records = Database.query(strSOQLQuery);

                    //----Added for sending checklist attachment records----//
                    if(currRec.SVMXC__Object_Name__c.equalsIgnoreCase('SVMXC__Checklist__c') && records != null && records.size() > 0){
                        Set<String> setChecklistIds = new Set<String>();
                        Map<String, List<SObject>> mapChecklistIDVsListOfCheckAttachRec = new Map<String, List<SObject>>();

                        List<String> queryFields = new List<String> {'SVMXC__SM_Checklist__c', 'SVMXC__SM_Question__c', 'SVMXC__SM_Internal_Question_ID__c', 'SVMXC__SM_Attachment_ID__c', 'SVMXC__SM_Attachment_Name__c', 'SVMXC__SM_File_Type__c', 'SVMXC__SM_File_Size__c', 'SVMXC__SM_ContentDocumentLink_ID__c'};
                        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_Checklist_Attachment__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        
                        //Collecting checklist records Ids
                        for(SObject objS : records){
                            setChecklistIds.add((String)objS.get('Id'));
                        }
                        System.debug('setChecklistIds : ' + setChecklistIds);

                        //Querying checklist attachment records
                        
                        List<SObject> lstChecklistAttachments = [SELECT Id, SVMXC__SM_Checklist__c, SVMXC__SM_Question__c, SVMXC__SM_Internal_Question_ID__c, SVMXC__SM_Attachment_ID__c, SVMXC__SM_ContentDocumentLink_ID__c, SVMXC__SM_Attachment_Name__c, SVMXC__SM_File_Type__c, SVMXC__SM_File_Size__c FROM SVMXC__SM_Checklist_Attachment__c WHERE SVMXC__SM_Checklist__c IN: setChecklistIds]; //SDL-SVMX-READ-FLS-ENFORCED
                        
                        //Added for Salesforce file ---BAC-2197
                        List<Id> contentDocumentLinkIds = new List<Id>(); //Added for salesforce file
                        Map<Id,ContentDocumentLink> mapCDLIdwithCDL = new Map<Id,ContentDocumentLink>(); //Added for salesforce file
                        Map<Id,Id> mapCVwithCDLids = new Map<Id,Id>(); //Added for salesforce file
                        for(Sobject sobj:lstChecklistAttachments){
                            SVMXC__SM_Checklist_Attachment__c checklistAttachmentObj = (SVMXC__SM_Checklist_Attachment__c)sobj;
                            if(checklistAttachmentObj.SVMXC__SM_ContentDocumentLink_ID__c != null)
                                contentDocumentLinkIds.add(checklistAttachmentObj.SVMXC__SM_ContentDocumentLink_ID__c);
                        }
                        //Get all the ContentDocumentLink with all the ContentDocument and ContentVersion ids
                        if(contentDocumentLinkIds.size() > 0)
                            mapCDLIdwithCDL = COMM_FileHandlerUtilities.getContentDocumentsLinks(contentDocumentLinkIds);
                        for(ContentDocumentLink cdl: mapCDLIdwithCDL.values()){
                            mapCVwithCDLids.put(cdl.id,cdl.ContentDocument.LatestPublishedVersionId);
                        }
                        for(Sobject sobj:lstChecklistAttachments){
                            SVMXC__SM_Checklist_Attachment__c checklistAttachmentObj = (SVMXC__SM_Checklist_Attachment__c)sobj;
                            if(mapCVwithCDLids.size()>0 && checklistAttachmentObj.SVMXC__SM_ContentDocumentLink_ID__c != null && mapCVwithCDLids.containsKey(checklistAttachmentObj.SVMXC__SM_ContentDocumentLink_ID__c))
                                sobj.put('SVMXC__SM_ContentDocumentLink_ID__c',mapCVwithCDLids.get(checklistAttachmentObj.SVMXC__SM_ContentDocumentLink_ID__c));
                        }
                        //End----Salesforce file --BAC-2197
                        //creating map of checklist Id and corresponding list of Checklist Attachment records
                        for(SObject objS : lstChecklistAttachments){
                            String strChecklistId = (String)objS.get('SVMXC__SM_Checklist__c');
                            if(!mapChecklistIDVsListOfCheckAttachRec.containsKey(strChecklistId)){
                                mapChecklistIDVsListOfCheckAttachRec.put(strChecklistId, new List<SObject>());
                            }
                            mapChecklistIDVsListOfCheckAttachRec.get(strChecklistId).add(objS);
                        }
                        System.debug('mapChecklistIDVsListOfCheckAttachRec : ' + mapChecklistIDVsListOfCheckAttachRec);
                        
                        //creating list of related records data
                        for(String strChecklistId : mapChecklistIDVsListOfCheckAttachRec.keyset()){
                            OPDOC_DeliveryImpl.RelatedRecordData objRelatedRecordData = new OPDOC_DeliveryImpl.RelatedRecordData(strChecklistId, mapChecklistIDVsListOfCheckAttachRec.get(strChecklistId));
                            lstRelatedRecordData.add(objRelatedRecordData);
                        }
                        System.debug('lstRelatedRecordData : ' + lstRelatedRecordData);
                    }
                    //----Added for sending checklist attachment records----//
                }
                System.debug('adding response for alias: ' + currRec.SVMXC__Alias__c);
                //update the datetime fields now

                specialFields = formatDateTimeFields(records, currRec.SVMXC__Fields__c);

                //if the template detail is header and no records queried then send the empty data with out querying for childs
                response.DocumentData.add(new OPDOC_DeliveryImpl.DocumentData(currRec.SVMXC__Alias__c, records, specialFields, lstRelatedRecordData));
                if(!validateList(records) && currRec.SVMXC__Type__c == 'Header_Object'){
                    isHeaderRecordExists = false;
                }
            }


        }
        catch(Exception ex){
            response.Status = false;
            response.Message = ex.getMessage();
            //throw ex;
        }
        //response back the sobjects
        return response;
    }

    private String buildSOQLQuery(String recordId, SVMXC__Doc_Template_Details__c details, Map<String, String> expressions, Map<String, String> sortExpression,String processId, List<String> displayNameFields, String displayObject){

        String query = null, fields = 'Id';
        String strObjectName = details.SVMXC__Object_Name__c;
        String strNameField = '';

        if(details.SVMXC__SOQL__c != null && details.SVMXC__SOQL__c.length() > 0){
            fields = fields + ', ' + details.SVMXC__SOQL__c.deleteWhitespace();//BAC-6180 added deleteWhitespace()
        }
        
        // SER-3858 Output document support for checklist.
        if( strObjectName == 'SVMXC__Checklist__c' ) {
            fields = fields + ',SVMXC__ChecklistProcessID__c,SVMXC__ChecklistJSON__c,SVMXC__ChecklistMetaJSON__c,SVMXC__SM_Checklist_Group_Id__c,SVMXC__SM_Sequence__c';
            //added for include specific checklist 
            includeChList1 = getSpecifiedIncludeSectionId(recordId,processId);
        }
        list<string> lstfields = new  list<string>();
        set<string> setfields = new  set<string>();
        lstfields = fields.split(',');
        setfields.addAll(lstfields);
        //BAC-6180 Display Name Field Values
        if(String.isNotBlank(displayObject) && displayObject.equals(strObjectName) && displayNameFields.size() > 0){
            setfields.addAll(displayNameFields);
        }
        lstfields.clear();
        lstfields.addAll(setfields);
        COMM_Utils_ManageSettings commUtils = new COMM_Utils_ManageSettings();
        fields ='';
        //fields = commUtils.SVMX_getCommaSepratedStr(lstfields);
        for(string str: lstfields)
        {
            if(fields != null && fields !='')
                fields = fields+ ', '+str+' ';
            else 
                fields= str+' ';
        
        }
        System.debug('fields : ' + fields);
        query = 'SELECT ' + fields + ' FROM ' + strObjectName + ' WHERE ' + details.SVMXC__Header_Reference_Field__c + ' IN(\'' + recordId + '\')';
        
        //added for include specified checklist
        //Checking junction object is present or not for the opdoc process. It is added for the defect BAC-2870 fix
        List<String> queryFields = new List<String> {'SVMXC__Process1__r.SVMXC__ProcessID__c'};
        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        //SDL-SVMX-READ-FLS-ENFORCED
        List<SVMXC__ServiceMax_Processes__c> listofChecklistSmartDoc = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Checklist Smart Doc' AND SVMXC__Process1__r.SVMXC__ProcessID__c = : processId];
        if(strObjectName.equalsIgnoreCase('SVMXC__Checklist__c') && listofChecklistSmartDoc.size() > 0 && includeChList1 != null)
        {
            query = query + 'and ID IN : includeChList1 ' ;
        }
        
        if(expressions.containsKey(details.Id)){

            query = query + ' AND (' +  expressions.get(details.Id) + ')';
        }

        if(sortExpression.containsKey(details.Id)){
            System.debug('Sort Expression: ' + sortExpression.get(details.Id));
            query = query + ' ORDER BY ' +  sortExpression.get(details.Id);
        }

        //query = query + ' ORDER BY '+ strNameField +' ASC';
        System.debug('SOQL query for Object : ' + strObjectName);
        System.debug('query : ' + query);
        return query;
    }
    //added this method for include specific checklist support
    private List<Id> getSpecifiedIncludeSectionId(String what_Id,String processId)
    {
        Map<Id,string> mapchecklistIdwithName = new Map<Id,string>();

        List<String> queryFields = new List<String> {'SVMXC__SM_Checklist_Group_Id__c', 'SVMXC__ChecklistProcessID__c', 'SVMXC__Completed_On__c', 'SVMXC__Completed_By__c', 'SVMXC__ChecklistProcessID__c'};
        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Checklist__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        List<SVMXC__Checklist__c> lstChecklistAll = [Select Id, SVMXC__SM_Checklist_Group_Id__c, SVMXC__ChecklistProcessID__r.SVMXC__ProcessID__c,SVMXC__Completed_On__c,SVMXC__Completed_By__c,SVMXC__ChecklistProcessID__c from SVMXC__Checklist__c where (SVMXC__What_Id__c = : what_Id ) ORDER BY LastModifiedDate DESC]; //SDL-SVMX-READ-FLS-ENFORCED

        Map<String,List<SVMXC__Checklist__c>> mapProcessIdWithChecklistList = new Map<String,List<SVMXC__Checklist__c>>();
        Map<Decimal, List<Id>> mapGroupIdWithListOfChecklistId = new Map<Decimal, List<Id>>();
        Set<Decimal> setGroupId = new Set<Decimal>();
        System.debug('lstChecklistAll : ' + lstChecklistAll);

        for(SVMXC__Checklist__c objChecklist : lstChecklistAll)
        {
            String str = objChecklist.SVMXC__ChecklistProcessID__r.SVMXC__ProcessID__c;
            mapchecklistIdwithName.put(objChecklist.SVMXC__ChecklistProcessID__c,str);
            
            if(objChecklist.SVMXC__SM_Checklist_Group_Id__c != null && !mapGroupIdWithListOfChecklistId.containsKey(objChecklist.SVMXC__SM_Checklist_Group_Id__c)){
                mapGroupIdWithListOfChecklistId.put(objChecklist.SVMXC__SM_Checklist_Group_Id__c, new List<String>());
            }
            if(objChecklist.SVMXC__SM_Checklist_Group_Id__c != null && mapGroupIdWithListOfChecklistId.containskey(objChecklist.SVMXC__SM_Checklist_Group_Id__c)){
                mapGroupIdWithListOfChecklistId.get(objChecklist.SVMXC__SM_Checklist_Group_Id__c).add(objChecklist.Id);
            }
            
            if(!mapProcessIdWithChecklistList.containskey(str)){
                mapProcessIdWithChecklistList.put(str,new List<SVMXC__Checklist__c>());
            }

            if(objChecklist.SVMXC__SM_Checklist_Group_Id__c == null){
                mapProcessIdWithChecklistList.get(str).add(objChecklist);
            }
            else if(!setGroupId.contains(objChecklist.SVMXC__SM_Checklist_Group_Id__c)){
                mapProcessIdWithChecklistList.get(str).add(objChecklist);
                setGroupId.add(objChecklist.SVMXC__SM_Checklist_Group_Id__c);
            }
        }  
        System.debug('mapGroupIdWithListOfChecklistId : ' + mapGroupIdWithListOfChecklistId);
        System.debug('mapProcessIdWithChecklistList : ' + mapProcessIdWithChecklistList);
        System.debug('mapchecklistIdwithName : ' + mapchecklistIdwithName);

        queryFields = new List<String> {'SVMXC__SM_Checklist_Version__c', 'SVMXC__Process1__c', 'SVMXC__Process2__c'};
        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        List<SVMXC__ServiceMax_Processes__c> listofSmartDoc = [Select Id,SVMXC__SM_Checklist_Version__c,SVMXC__Process1__c,SVMXC__Process2__c from SVMXC__ServiceMax_Processes__c where (SVMXC__Process2__c IN : mapchecklistIdwithName.keyset() and  (RecordType.Name = 'Checklist Smart Doc') and (SVMXC__Process1__r.SVMXC__ProcessID__c = : processId))]; //SDL-SVMX-READ-FLS-ENFORCED

        System.debug('listofSmartDoc : ' + listofSmartDoc);

        Map<String,string> mapcheclistwithversion = new Map<String,string>();
        for(SVMXC__ServiceMax_Processes__c lst12 : listofSmartDoc)
        {
            mapcheclistwithversion.put(mapchecklistIdwithName.get(lst12.SVMXC__Process2__c),lst12.SVMXC__SM_Checklist_Version__c);
        }
        System.debug('mapcheclistwithversion '+mapcheclistwithversion);
        List<id> includeChList = new List<id>();
        for(String strch : mapcheclistwithversion.keyset())
        {
            String chName = mapcheclistwithversion.get(strch);
            if(chName.equalsIgnoreCase('All Versions')){
                List<SVMXC__Checklist__c> lstChecklist = mapProcessIdWithChecklistList.get(strch);
                for(SVMXC__Checklist__c objChk: lstChecklist){
                    if(objChk.SVMXC__SM_Checklist_Group_Id__c == null){
                        includeChList.add(objChk.Id);
                    }
                    else if(mapGroupIdWithListOfChecklistId.containskey(objChk.SVMXC__SM_Checklist_Group_Id__c)){
                        includeChList.addAll(mapGroupIdWithListOfChecklistId.get(objChk.SVMXC__SM_Checklist_Group_Id__c));
                    }
                }
            }
            else if(chName.equalsIgnoreCase('First Version')){
                SVMXC__Checklist__c objChk = mapProcessIdWithChecklistList.get(strch)[mapProcessIdWithChecklistList.get(strch).size()-1];
                if(objChk.SVMXC__SM_Checklist_Group_Id__c == null){
                    includeChList.add(objChk.Id);
                }
                else if(mapGroupIdWithListOfChecklistId.containskey(objChk.SVMXC__SM_Checklist_Group_Id__c)){
                    includeChList.addAll(mapGroupIdWithListOfChecklistId.get(objChk.SVMXC__SM_Checklist_Group_Id__c));
                }
            }
            else if(chName.equalsIgnoreCase('Last Version')){
                SVMXC__Checklist__c objChk = mapProcessIdWithChecklistList.get(strch)[0];
                if(objChk.SVMXC__SM_Checklist_Group_Id__c == null){
                    includeChList.add(objChk.Id);
                }
                else if(mapGroupIdWithListOfChecklistId.containskey(objChk.SVMXC__SM_Checklist_Group_Id__c)){
                    includeChList.addAll(mapGroupIdWithListOfChecklistId.get(objChk.SVMXC__SM_Checklist_Group_Id__c));
                }
            }
        }
        System.debug('includeChList : '+includeChList);
        return includeChList;
    }
    private void getSortFieldsAndExpr(List<SVMXC__ServiceMax_Processes__c> procNodeObjects,Map<String,String> expressions,
                                                    Map<String,String> sortingExpressions){

        //Map<String, String> expressions = new Map<String, String>();
        String exprCriteria = null, sortCriteria = null;
        String nodeId = null;
        if(procNodeObjects != null && procNodeObjects.size() > 0){
            for(SVMXC__ServiceMax_Processes__c currNodeObj : procNodeObjects){
                exprCriteria = currNodeObj.SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c;
                sortCriteria = buildSortQuery(currNodeObj.SVMXC__Values__c);
                nodeId = currNodeObj.SVMXC__Doc_Template_Details__c;
                if(exprCriteria != null && exprCriteria.length() > 0 && nodeId != null && nodeId.length() > 0){
                    expressions.put(nodeId, exprCriteria);
                }
                if(sortCriteria != null && sortCriteria.length() > 0 && nodeId != null && nodeId.length() > 0){
                    sortingExpressions.put(nodeId, sortCriteria);
                }
            }
        }
    }

    private String buildSortQuery(String jsonSortingData){

        String queryString = '';
        if(jsonSortingData == null || jsonSortingData.length() == 0){
            return queryString;
        }

        SFM_WrapperDef.FieldSetWithSorting fldSet = (SFM_WrapperDef.FieldSetWithSorting)JSON.deserialize(jsonSortingData, SFM_WrapperDef.FieldSetWithSorting.class);
        List<SFM_WrapperDef.SortingRec> lstSortingRec = fldSet.lstSortingRec;
        if(lstSortingRec == null || lstSortingRec.size() == 0){
            return queryString;
        }

        for(SFM_WrapperDef.SortingRec currRec : lstSortingRec){

            if(currRec.queryfield != null && currRec.queryfield.length() > 0){
                if(queryString.length() > 0) queryString = queryString + ', ';
                queryString = queryString + currRec.queryfield + (currRec.sortingOrder != null ? ' ' + currRec.sortingOrder : ' ASC');
            }
        }

        return queryString;

    }

    private Map<String,List<SObject>> getProcessRelatedRecords(String procId) {

        Map<String, List<SObject>> mapProcRelatedRecs = new Map<String, List<SObject>>();

        //BAC-6180 added SVMXC__Export_Configuration__c
        //Process Record
        List<SVMXC__ServiceMax_Processes__c> lstProcRec =
                                [Select Id, SVMXC__Doc_Template__c, SVMXC__Export_Configuration__c from SVMXC__ServiceMax_Processes__c
                                                            where SVMXC__ProcessID__c =: procId and RecordType.Name =: TARGETMANAGER_RECORDTYPE]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        if(!validateList(lstProcRec)){
            return mapProcRelatedRecs;
        }
        System.debug('process record');
        mapProcRelatedRecs.put(PROCESSREC,lstProcRec);

        //Process Node Recs
        
        List<SVMXC__ServiceMax_Processes__c> lstProcNodeRecs =
                                [Select Id, SVMXC__Submodule__c, SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Doc_Template_Details__c,
                                                    SVMXC__Type__c,SVMXC__Values__c  from SVMXC__ServiceMax_Processes__c
                                                            where SVMXC__Process__r.SVMXC__ProcessID__c =: procId and RecordType.Name =: PROCESSNODEOBJECT_RECORDTYPE ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(validateList(lstProcNodeRecs)) {
            System.debug('process node records');
            mapProcRelatedRecs.put(PROCESSNODEOBJ,lstProcNodeRecs);
        }

        //Doc Template Recs
        String docTemplateId = lstProcRec[0].SVMXC__Doc_Template__c;
        if(docTemplateId == null || docTemplateId.length() == 0){
            return mapProcRelatedRecs;
        }
        
        List<SVMXC__Doc_Template__c> lstDocTemplate = [Select Id, SVMXC__Media_Resources__c from SVMXC__Doc_Template__c where Id =: docTemplateId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(!validateList(lstDocTemplate)){
            return mapProcRelatedRecs;
        }

        System.debug('document template record');
        mapProcRelatedRecs.put(DOCTEMPLATE, lstDocTemplate);

        // Doc Template Detail Recs
        
        List<SVMXC__Doc_Template_Details__c> lstDocTemplateDetials =
                            [Select Id, SVMXC__Alias__c, SVMXC__SOQL__c, SVMXC__Object_Name__c, SVMXC__Header_Reference_Field__c, SVMXC__Fields__c, SVMXC__Type__c from SVMXC__Doc_Template_Details__c
                                                            where SVMXC__Doc_Template__c =: docTemplateId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        if(!validateList(lstDocTemplateDetials)){
            return mapProcRelatedRecs;
        }
        System.debug('document template detail records');
        mapProcRelatedRecs.put(DOCTEMPLATEDETAILS, lstDocTemplateDetials);

        return mapProcRelatedRecs;
    }

    private Boolean validateList(List<SObject> lstRecs){
        if(lstRecs != null && lstRecs.size() > 0){
            return true;
        }
        return false;
    }

    //formats date time fields to yyyy-MM-dd HH:mm:ss
    private List<OPDOC_DeliveryImpl.ValueWrapperMap> formatDateTimeFields(List<SObject> recs, String jsonMetadata){

        //convert the json string to object
        List<OPDOC_DeliveryImpl.ValueWrapperMap> specialFlds = new List<OPDOC_DeliveryImpl.ValueWrapperMap>();
        OPDOC_DeliveryImpl.MetadataWrapper mw = new OPDOC_DeliveryImpl.MetadataWrapper();
        List<OPDOC_DeliveryImpl.ValueWrapper> recSpecialFldValues = null;
        Map<String, String> fieldNames = new Map<String, String>();
        List<OPDOC_DeliveryImpl.MetadataWrapper> lstDocumentFieldInfo = mw.convertMetadataJson(jsonMetadata);
        //get all the date time fields
        if(lstDocumentFieldInfo == null || lstDocumentFieldInfo.size() == 0
                                        || recs == null || recs.size() == 0){
            return specialFlds;
        }

        for(OPDOC_DeliveryImpl.MetadataWrapper currField : lstDocumentFieldInfo){

            if(currField.TYP != null && (currField.TYP == 'datetime' || currField.TYP == 'date')
                                        && currField.FN != null && currField.FN.length() > 0){
                fieldNames.put(currField.FN, currField.TYP);
            }
            else if(currField.TYP != null && currField.TYP == 'reference'
                                             && currField.RTYP != null && (currField.RTYP == 'datetime' || currField.RTYP == 'date')
                                             && currField.RLN != null && currField.RLN.length() > 0
                                             && currField.RFN != null && currField.RFN.length() > 0){
                fieldNames.put(currField.RLN + '.' + currField.RFN, currField.RTYP);
            }
        }
        //if any date time fields exists, loop through all the recs update the date time fields
        System.debug('Datetime fields: ' + fieldNames);
        if(fieldNames.size() == 0) return specialFlds;
        for(SObject currRec : recs){
            specialFlds.add(new OPDOC_DeliveryImpl.ValueWrapperMap(String.valueOf(currRec.get('Id')), formatDateTimeFields(fieldNames, currRec)));
        }       
        return specialFlds;
    }

    private List<OPDOC_DeliveryImpl.ValueWrapper> formatDateTimeFields(Map<String, String> fieldNames, SObject rec){

        List<OPDOC_DeliveryImpl.ValueWrapper> formattedFieldValues = new List<OPDOC_DeliveryImpl.ValueWrapper>();
        String OPDOCFieldName = null;
        for(String currFldName : fieldNames.keySet()){
            List<String> refFlds = currFldName.split('\\.');
            if(refFlds.size() == 2){
                OPDOCFieldName = currFldName.replaceAll('__r', '__c');
                SObject objInnerRec = rec.getSObject(refFlds[0]);
                if(objInnerRec != null && objInnerRec.get(refFlds[1]) != null){
                    //System.debug('Formatted values : ' + formatDateTime((Datetime)objInnerRec.get(refFlds[1])));
                    formattedFieldValues.add(new OPDOC_DeliveryImpl.ValueWrapper(OPDOCFieldName, formatDateTime((Datetime)objInnerRec.get(refFlds[1]), fieldNames.get(currFldName)), fieldNames.get(currFldName)));
                }
            }else if(rec.get(currFldName) != null){
                //System.debug('Formatted values : ' + formatDateTime((Datetime)rec.get(currFldName)));
                formattedFieldValues.add(new OPDOC_DeliveryImpl.ValueWrapper(currFldName, formatDateTime((Datetime)rec.get(currFldName), fieldNames.get(currFldName)), fieldNames.get(currFldName)));
            }
        }
        return formattedFieldValues;
    }

    private String formatDateTime(Datetime dt, String ftype){
        if(dt == null) return null;
        String formattedValue = '';
        if(ftype == 'date')
            formattedValue = String.valueOfGmt(dt);
        else
            formattedValue = String.valueOf(dt);
        return formattedValue;
    }

}