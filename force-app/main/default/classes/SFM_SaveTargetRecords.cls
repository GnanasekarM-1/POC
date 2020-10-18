/* Security Scanned */
public with sharing class SFM_SaveTargetRecords
{
    //public static String className = 'SFM_SaveTargetRecords';
    //public List<RecordType> RecordTypeList = new List<RecordType>(); //Commented for BAC-4366
   // public String FldMapRTypeID = ''; //#optiChange
   // public String PNodeObjRTypeID = ''; //#optiChange
    public map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>(); 
    public map<String,Schema.SObjectType> Allobj = new map<String,Schema.SObjectType>();
    SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils(); 
    SVMXC.SVMXMessageUtils MessageUtils = new SVMXC.SVMXMessageUtils();  
    SVMXC.SFM_buildSobjectFromKeyValue sobjectfromkevalue = new SVMXC.SFM_buildSobjectFromKeyValue();
    SVMXC.SFM_buildSobject BuildSobject = new SVMXC.SFM_buildSobject(); 
    static final String CHECKLIST_QUICK_SAVE = 'quick save checklist'; 
    static final String CHECKLIST_SAVE = 'save checklist'; 
    static final String SAVE_CHECKLIST_ATTACHMENT = 'save checklist attachment';
    static final String SAVE_FOR_LINKED_SFM = 'save for linked sfm'; //Added for the story BAC-4027
    public static boolean fromSFMSave = false;//Added by Nidhi BAC-5144
    public static final Integer MAX_CHUNK_SIZE = 10; //#chunkWork #Defect 047622
    public static final Integer MAX_RECORDS_IN_CHUNK = 200; //#chunkWork #Defect 047622
    static final String SESSION_MGMT = 'SFM002_SET00100';//custom setting to disable session management feature
    
    public SFM_saveTargetRecords()
    {       
        // gd = Schema.getGlobalDescribe(); //#optiChange
        /* Commented for BAC-4366
        RecordTypeList = [Select Name, Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(RecordTypeList.size() > 0)
        {
            for(RecordType r : RecordTypeList) 
            {
                if(r.Name == 'Field Mapping') 
                {
                    FldMapRTypeID = r.id;
                }
                if(r.Name == 'Process Node Objects') 
                {
                    PNodeObjRTypeID = r.id;
                }
            }
        }
        */
        //Added for BAC-4366
        // FldMapRTypeID = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c','Field_Mapping'); // #optiChange
        //PNodeObjRTypeID = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Processes__c','Process_Node_Objects'); // #optiChange
        //FldMapRTypeID = COMM_RecordTypeUtilities.getObjectRecordTypeId(gd.get('SVMXC__ServiceMax_Config_Data__c'), 'Field_Mapping');
        //PNodeObjRTypeID = COMM_RecordTypeUtilities.getObjectRecordTypeId(gd.get('SVMXC__ServiceMax_Processes__c'), 'Process_Node_Objects');
       // System.debug('FldMapRTypeID '+FldMapRTypeID +' PNodeObjRTypeID '+PNodeObjRTypeID);
        //End BAC-4366
        /* #optiChange if(gd.size() > 0)
        {
            for(String s : gd.keyset())
            { 
                Allobj.put(gd.get(s).getDescribe().getName(),gd.get(s));
            }
        }*/
       

    }
 
    //Fixed defect 046599 
    Map<String,Map<String,String>> mapChecklistQuestionAnswer = new Map<String,Map<String,String>>(); 
    public SVMXC.SFM_WrapperDef.SFM_Response SaveTargetRecords(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
        if(sfmtargetrec.eventType != null && sfmtargetrec.eventType == 'save'){
            fromSFMSave = true;
        }
        map<String,SVMXC.SFM_WrapperDef.FieldSetWithSorting> mapAliasNameFieldSetWrapper =  new map<String,SVMXC.SFM_WrapperDef.FieldSetWithSorting>();
        SVMXC.SFM_WrapperDef.SFM_Response SFMResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        SFMResponse.success = true;
        SFMResponse.eventType = sfmtargetrec.eventType;
        SFMResponse.callType = sfmtargetrec.callType; //Added for the story BAC-4027
        map<String,map<String,Schema.SObjectField>> AllFieldDescribe = new map<String,map<String,Schema.SObjectField>>();
        DCON_Utils dcUtils = new DCON_Utils();
        /* Commented for BAC-4366
        String UserId = Userinfo.getUserId();
        User UserDetail = [SELECT TimeZoneSidKey from User where Id =: UserId];
        String timeZone = UserDetail.TimeZoneSidKey;*/
        String timeZone = UserInfo.getTimeZone().getID(); // Added for BAC-4366
        Set<String> setHeaderFields = new Set<String>();
        Set<String> setDetailFields = new Set<String>();
        System.debug('timeZone: '+timeZone);
        
        //creating save point
        Savepoint sp;
        sp = Database.setSavepoint();

        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>(); 
        map<String,list<Sobject>> HeaderlstSobjMap = new map<String,list<Sobject>>();
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC.SFM_WrapperDef.SFM_TargetRecord SFMTargerRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        if(sfmtargetrec != null) 
            SFMTargerRecord = sfmtargetrec;
        system.debug(Logginglevel.INFO,'SFMTargerRecord: '+SFMTargerRecord);

        //first member of the SFM_TargetRecord Class
        String SFMID = '';
        String processId = '';

        //Second member of the SFM_TargetRecord Class
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject HdrTargetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();

        //Third member of the SFM_TargetRecord Class
        List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();
        
        //Get the Process Id
        if(SFMTargerRecord.sfmProcessId != null){
            SFMID = SFMTargerRecord.sfmProcessId;
        }

        if(SFMID != null && SFMID.length() > 0){
            
            SFMProcess = [Select  Name, SVMXC__Page_Layout__c, SVMXC__Purpose__c, SVMXC__Enable_Sub_Process__c,SVMXC__Sub_Process_Source_Field__c, SVMXC__Process2__c, Id From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Target Manager' and (SVMXC__ProcessID__c =: SFMID OR Id =: SFMID)]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
            
        if(SFMProcess != null && SFMProcess.id != null){
            processId = SFMProcess.id;
            
            //Get Process Node Objects
            
            list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObject = [Select SVMXC__Default_Value__c, SVMXC__Values__c, SVMXC__Module__r.SVMXC__Source_Object_Name__c, SVMXC__Module__r.SVMXC__Target_Object_Name__c, SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, Name,SVMXC__ProcessID__c,SVMXC__Page_Layout__c,SVMXC__Parent_Column_Name__c,SVMXC__Final_Exception_Process__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Node_Source_Object_API__c,SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c  From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: processId and RecordType.Name  = 'Process Node Objects']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            System.debug(Logginglevel.INFO,'lstProcessNodeObject: '+lstProcessNodeObject);

            if(lstProcessNodeObject.size() > 0){
                for(SVMXC__ServiceMax_Processes__c PND : lstProcessNodeObject){
                    if(PND.SVMXC__Type__c.touppercase() == 'TARGET'){
                         if(PND.SVMXC__Values__c != null){
                            SVMXC.SFM_WrapperDef.FieldSetWithSorting fieldsetwithsorting = 
                            (SVMXC.SFM_WrapperDef.FieldSetWithSorting) deserializeRequestTo(PND.SVMXC__Values__c, SVMXC.SFM_WrapperDef.FieldSetWithSorting.class);
                            if(fieldsetwithsorting.lstFieldSetAPIName != null && fieldsetwithsorting.lstFieldSetAPIName.size() > 0){
                                fieldsetwithsorting.strObjectName = PND.SVMXC__Source_Object_Name__c;
                                fieldsetwithsorting.fieldMapId = PND.SVMXC__Module__c;
                                fieldsetwithsorting.valueMapId = PND.SVMXC__Final_Exception_Process__c;
                                fieldsetwithsorting.pageLayoutId = SFMProcess.SVMXC__Page_Layout__c;
                                mapAliasNameFieldSetWrapper.put(PND.SVMXC__Source_Object_Name__c,fieldsetwithsorting);
                            }   
                        }    
                    }
                    else if(PND.SVMXC__Type__c.touppercase() == 'TARGETCHILD'){
                        if(PND.SVMXC__Values__c != null){
                            SVMXC.SFM_WrapperDef.FieldSetWithSorting fieldsetwithsorting = 
                            (SVMXC.SFM_WrapperDef.FieldSetWithSorting) deserializeRequestTo(PND.SVMXC__Values__c, SVMXC.SFM_WrapperDef.FieldSetWithSorting.class);
                            if(fieldsetwithsorting.lstFieldSetAPIName != null && fieldsetwithsorting.lstFieldSetAPIName.size() > 0){
                                fieldsetwithsorting.strObjectName = PND.SVMXC__Source_Object_Name__c;
                                fieldsetwithsorting.fieldMapId = PND.SVMXC__Module__c;
                                fieldsetwithsorting.valueMapId = PND.SVMXC__Final_Exception_Process__c;
                                fieldsetwithsorting.pageLayoutId = PND.SVMXC__Page_Layout__c;
                                mapAliasNameFieldSetWrapper.put(PND.SVMXC__Page_Layout__c,fieldsetwithsorting);
                            }   
                        }
                    }
                }
            }
        }
        map<String,set<String>> mapObjectAPINameWithFields = new map<String,set<String>>();
        if(mapAliasNameFieldSetWrapper.size() > 0){
            SVMXC.SFM_FieldSetUtils fieldSetUtils = new SVMXC.SFM_FieldSetUtils();
            mapObjectAPINameWithFields = fieldSetUtils.SFM_buildFieldListFromFieldSet(mapAliasNameFieldSetWrapper,Allobj);
        }
        System.debug(LoggingLevel.WARN,'mapObjectAPINameWithFields: '+mapObjectAPINameWithFields); 

        //get the Header Record...
        if(SFMTargerRecord.headerRecord != null){
            HdrTargetRecordObject = SFMTargerRecord.headerRecord;
        }

        //get the details records....
        if(SFMTargerRecord.detailRecords != null && SFMTargerRecord.detailRecords.size() > 0){
            DtlTargetRecordObject = SFMTargerRecord.detailRecords;
        }
        System.debug(Logginglevel.INFO,'SFMTargerRecord.detailRecords: '+SFMTargerRecord.detailRecords);   
        System.debug(Logginglevel.INFO,'DtlTargetRecordObject size: '+DtlTargetRecordObject.size()+' - records: '+DtlTargetRecordObject);

        //first process the Header of the SFM_TargetRecordObject
        String HeaderObjName = '';//for the first member of SFM_TargetRecordObject
        List<SVMXC.SFM_WrapperDef.SFM_Record> HeaderRecord = new List<SVMXC.SFM_WrapperDef.SFM_Record>();//for the third member of SFM_TargetRecordObject
        
        //get the Header Object Name
        if(HdrTargetRecordObject.objName != null){
            HeaderObjName = HdrTargetRecordObject.objName;
        }
        System.debug(Logginglevel.INFO,'HeaderObjName: '+HeaderObjName);    
        
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.records.size() > 0){
            HeaderRecord = HdrTargetRecordObject.records;
        }
        System.debug(Logginglevel.INFO,'HeaderRecord: '+HeaderRecord);     
        
        String HdrSourceUpdateRecId = '';
        Sobject HdrSObject;
        list<Sobject> lstHdrSObject = new list<Sobject>();
        
        //First do the Field describe and put it in all describe
        map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
        map<String, Schema.SObjectField> HeaderFieldMap = new map<String, Schema.SObjectField>();
        
        //if(Allobj.containskey(HeaderObjName) && AllFieldDescribe.containskey(HeaderObjName) == false){ #optiChange
        if(/*COMM_Utils_DescribeCall.getObjectFieldDetails(HeaderObjName) != NULL && */ !AllFieldDescribe.containskey(HeaderObjName)){
            //FieldMap = Allobj.get(HeaderObjName).getDescribe().fields.getMap(); // #optiChange
             FieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(HeaderObjName); // #optiChange
        }
        
        if(FieldMap != NULL && !FieldMap.isEmpty()) // #optiChange
        {
            for(String s : FieldMap.keyset())
            {
                HeaderFieldMap.put(FieldMap.get(s).getDescribe().getName(),FieldMap.get(s));
            }
            if(HeaderFieldMap.size() > 0)
            {
                AllFieldDescribe.put(HeaderObjName,HeaderFieldMap);
            }
        }

        //---------Added for saving Checklist Attachment records------------//
        System.debug('Event type: '+sfmtargetrec.eventType);
        if(sfmtargetrec.eventType != null && sfmtargetrec.eventType.equalsIgnoreCase(SAVE_CHECKLIST_ATTACHMENT)){
            try{
                List<Sobject> lstChecklistAttachment = new List<Sobject>();
                if(HeaderRecord.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0){
                    for(Integer i=0; i<HeaderRecord.size(); i++){
                        Map<String,Sobject> checklistlstSobjMap = new Map<String,Sobject>();
                        if(HeaderRecord[i].targetRecordAsKeyValue != null && HeaderRecord[i].targetRecordAsKeyValue.size() > 0){
                            checklistlstSobjMap = sobjectfromkevalue.BuildSobjectFromGivenKeyValue(HeaderRecord[i].targetRecordAsKeyValue,HeaderObjName,null,null,true,null);
                            lstChecklistAttachment.add(checklistlstSobjMap.values());
                        }
                    }
                }
                System.debug('lstChecklistAttachment: '+lstChecklistAttachment);
                //Code Added for salesforce file---BAC-4042
                Map<Id,Id> mapChecklistCVIds = new Map<Id,Id>();
                Map<Id,Id> mapCVwithCDLids = new Map<Id,Id>();
                List<Id> listContentVersionIds = new List<Id>();
                List<ContentDocumentLink> cdlInstance = new List<ContentDocumentLink>();
                Map<Id,ContentDocumentLink> mapCDLIdwithCDL = new Map<Id,ContentDocumentLink>();
                for(Sobject sobj: lstChecklistAttachment){
                    SVMXC__SM_Checklist_Attachment__c checklistAttachmentObj = (SVMXC__SM_Checklist_Attachment__c)sobj;
                    if(checklistAttachmentObj.SVMXC__SM_ContentDocumentLink_ID__c != null){
                    mapChecklistCVIds.put(checklistAttachmentObj.SVMXC__SM_ContentDocumentLink_ID__c,checklistAttachmentObj.SVMXC__SM_Checklist__c);
                    listContentVersionIds.add(checklistAttachmentObj.SVMXC__SM_ContentDocumentLink_ID__c);
                    }
                }
                if(mapChecklistCVIds.size() > 0){
                //get all the ContentVersion ids with related contentDocument ids
                Map<Id,Id> mapContentVersionWIthDocumentIds = COMM_FileHandlerUtilities.getContentDocumentsId(listContentVersionIds);
                    for(Id cvId: mapChecklistCVIds.keyset()){
                        //Create ContentDocumentLink instance
                        cdlInstance.add(COMM_FileHandlerUtilities.createContentDocumentLink(mapChecklistCVIds.get(cvId),mapContentVersionWIthDocumentIds.get(cvId)));
                    }
                    //Insert all the ContentDocumentLink instances
                    Database.SaveResult[] insertedCdl = COMM_FileHandlerUtilities.insertContentDocumentLinks(cdlInstance);
                    System.debug('insertedCdl '+insertedCdl);
                    List<Id> contentDocumentLinkIds = new List<Id>();
                    for (Database.SaveResult sr : insertedCdl) {
                        //Get only successfully inserted record ids
                        if (sr.isSuccess()) {
                        contentDocumentLinkIds.add(sr.getId());
                        }
                    }
                    if(contentDocumentLinkIds.size() > 0)
                    ////Get all the ContentDocumentLink with all the ContentDocument and ContentVersion ids 
                    mapCDLIdwithCDL = COMM_FileHandlerUtilities.getContentDocumentsLinks(contentDocumentLinkIds);
                    for(ContentDocumentLink cdl: mapCDLIdwithCDL.values()){
                        mapCVwithCDLids.put(cdl.ContentDocument.LatestPublishedVersionId, cdl.id);
                    }
                    for(Sobject sobj:lstChecklistAttachment){
                        SVMXC__SM_Checklist_Attachment__c checklistAttachmentObj = (SVMXC__SM_Checklist_Attachment__c)sobj;
                        if(mapCVwithCDLids.size()>0 && mapCVwithCDLids.containsKey(checklistAttachmentObj.SVMXC__SM_ContentDocumentLink_ID__c))
                        sobj.put('SVMXC__SM_ContentDocumentLink_ID__c',mapCVwithCDLids.get(checklistAttachmentObj.SVMXC__SM_ContentDocumentLink_ID__c));
                    }
                }
                System.debug('After salesforce file operation '+lstChecklistAttachment);
                //End ---BAC-4042
                //saving checklist attachment records
                if(lstChecklistAttachment.size() > 0){
                    Schema.SObjectType sObjectType = SVMXC__SM_Checklist_Attachment__c.getSObjectType();
                    if (sObjectType != null){
                        String listType = 'List<' + sObjectType + '>';
                        List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
                        castRecords.addAll(lstChecklistAttachment);
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(castRecords, COMM_SecurityUtils.Access.Upsertable)){
                            upsert castRecords; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else{
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        
                        SFMResponse.records = castRecords;
                    }
                }
                //deleting checklist attachment and Salesforce attachment records
                if(HdrTargetRecordObject.deleteRecID != null && HdrTargetRecordObject.deleteRecID.size() > 0){
                    List<String> checklistAttachIds = HdrTargetRecordObject.deleteRecID;
                    List<String> lstAttachmentId = new List<String>();
                    List<Id> lstCDLIds = new List<Id>();
                    List<SVMXC__SM_Checklist_Attachment__c> lstCheckAttach = [SELECT Id, SVMXC__SM_Attachment_ID__c, SVMXC__SM_ContentDocumentLink_ID__c FROM SVMXC__SM_Checklist_Attachment__c WHERE Id IN: checklistAttachIds];
                    for(SVMXC__SM_Checklist_Attachment__c objCheckAtt: lstCheckAttach){
                        if(objCheckAtt.SVMXC__SM_Attachment_ID__c != null)
                        lstAttachmentId.add(objCheckAtt.SVMXC__SM_Attachment_ID__c);
                        if(objCheckAtt.SVMXC__SM_ContentDocumentLink_ID__c != null)
                        lstCDLIds.add(Id.valueOf(objCheckAtt.SVMXC__SM_ContentDocumentLink_ID__c));
                    }
                    //For Salesforce file
                    if(lstCDLIds.size()>0){
                        List<Id> listContentDocumentIds = new List<Id>();
                        //Get the ContentDocumentLink with related COntentDocuments and ContentVersions
                        for(ContentDocumentLink cdl: COMM_FileHandlerUtilities.getContentDocumentsLinks(lstCDLIds).values()){
                            listContentDocumentIds.add(cdl.ContentDocumentId);
                        }
                        //Delete the ContentDocument
                        if(listContentDocumentIds.size()>0)
                        COMM_FileHandlerUtilities.deleteContentDocument(listContentDocumentIds);
                    }
                    List<Attachment> lstAttachment = [SELECT Id FROM Attachment WHERE Id IN: lstAttachmentId];
                    if(lstAttachment.size() > 0){
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        delete lstAttachment;
                    }
                    if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SM_Checklist_Attachment__c' ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    if(lstCheckAttach.size() > 0){
                        //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete lstCheckAttach;
                    }
                }
            }
            catch(exception ex){
                Database.rollback(sp);
                System.debug('Exception in '+SAVE_CHECKLIST_ATTACHMENT+' : '+ex.getStackTraceString());
                SFMResponse.success = false;
                SFMResponse.message = ex.getMessage();
                System.debug('Exception in Save Checklist Attachment: '+SFMResponse);
                fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                return SFMResponse; 
            }
            System.debug('Response Save Checklist Attachment: '+SFMResponse);
            System.debug('Number of SOQL issued: '+Limits.getQueries());
            fromSFMSave = false;//Added by Nidhi as part of BAC-5144
            return SFMResponse;
        }
        //---------Added for saving Checklist Attachment records------------//
            
        //-------START---checklist MetaJason changes---------//
        if(sfmtargetrec.eventType != null && (sfmtargetrec.eventType.equalsIgnoreCase(CHECKLIST_QUICK_SAVE) || sfmtargetrec.eventType.equalsIgnoreCase(CHECKLIST_SAVE))){
            //Fixed defect 046599 
            if(sfmtargetrec.checklistInfo != null)
            {
                for(SFM_WrapperDef.ChecklistInfo checklistInfo : sfmtargetrec.checklistInfo )
                {
                    if(checklistInfo.questionType == 'picklist' && !mapChecklistQuestionAnswer.containsKey(checklistInfo.questionId))
                    {
                        mapChecklistQuestionAnswer.put(checklistInfo.questionId, new Map<String,String>());
                        for(SFM_WrapperDef.SFM_StringMap keyValue: checklistInfo.possibleValues)
                        {
                            mapChecklistQuestionAnswer.get(checklistInfo.questionId).put(keyValue.value,keyValue.key);
                        }
                    }
                }
            }
            System.debug('mapChecklistQuestionAnswer: '+ mapChecklistQuestionAnswer);
            if(HeaderRecord.size() > 0)
            {
                for(integer j=0;j<HeaderRecord.size();j++)
                { 
                    map<String,Sobject> tempHeaderlstSobjMap = new map<String,Sobject>();
                    
                    if(HeaderRecord[j].sourceRecordId != null)
                    {
                        HdrSourceUpdateRecId = HeaderRecord[j].sourceRecordId;
                    }

                    if(HeaderRecord[j].targetRecordAsKeyValue != null && HeaderRecord[j].targetRecordAsKeyValue.size() > 0)
                    {
                        if(HeaderObjName != null && HeaderObjName.length() > 0)
                        {
                            if(mapObjectAPINameWithFields.size() > 0 && mapObjectAPINameWithFields.containskey(HeaderObjName))
                            {
                                tempHeaderlstSobjMap = sobjectfromkevalue.BuildSobjectFromGivenKeyValue(HeaderRecord[j].targetRecordAsKeyValue,HeaderObjName,null,null,true,mapObjectAPINameWithFields.get(HeaderObjName));
                                for(string s:tempHeaderlstSobjMap.keyset())
                                {
                                    if(HeaderlstSobjMap.containskey(s) && HeaderlstSobjMap.get(s)!= null)
                                        HeaderlstSobjMap.get(s).add(tempHeaderlstSobjMap.get(s));
                                    else
                                    {
                                        list<sobject> lstSobj = new list<sobject>();
                                        lstSobj.add(tempHeaderlstSobjMap.get(s));
                                        HeaderlstSobjMap.put(s,lstSobj);
                                    }
                                }
                            }
                            else    
                            {
                                tempHeaderlstSobjMap = sobjectfromkevalue.BuildSobjectFromGivenKeyValue(HeaderRecord[j].targetRecordAsKeyValue,HeaderObjName,null,null,true,null);
                                for(string s:tempHeaderlstSobjMap.keyset())
                                {
                                    if(HeaderlstSobjMap.containskey(s) && HeaderlstSobjMap.get(s)!= null)
                                        HeaderlstSobjMap.get(s).add(tempHeaderlstSobjMap.get(s));
                                    else
                                    {
                                        list<sobject> lstSobj = new list<sobject>();
                                        lstSobj.add(tempHeaderlstSobjMap.get(s));
                                        HeaderlstSobjMap.put(s,lstSobj);
                                    }
                                }
                            }
                        }   
                        if(!(setHeaderFields.size()>0))
                        {
                            Integer i = 0,l= HeaderRecord[0].targetRecordAsKeyValue.size();
                            for(i = 0;i<l;i++){
                                setHeaderFields.add(HeaderRecord[0].targetRecordAsKeyValue[i].key);
                            }    
                        }          
                    }
                }
            }
            System.debug(Logginglevel.INFO,'HeaderlstSobjMap: '+HeaderlstSobjMap);
            System.debug(Logginglevel.INFO,'HeaderSobjMap: '+HeaderSobjMap);
            System.debug(Logginglevel.INFO,'setHeaderFields: '+setHeaderFields);

            if(HeaderlstSobjMap.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
            {
                for(string str:HeaderlstSobjMap.keyset())
                    lstHdrSObject = HeaderlstSobjMap.get(str);

                map<String, Schema.SObjectField> LocalFldMap = new map<String, Schema.SObjectField>();
                if(AllFieldDescribe.containskey(HeaderObjName))
                    LocalFldMap = AllFieldDescribe.get(HeaderObjName);
                if(LocalFldMap.size() > 0 && setHeaderFields.size() > 0)
                {
                    for(sobject HdrSObj : lstHdrSObject)
                    {
                        for(String s : setHeaderFields)
                        {
                            if(LocalFldMap.containskey(s)){
                                Schema.DescribeFieldResult f = LocalFldMap.get(s).getDescribe();
                                if(f.isAccessible()  && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime)//&& f.isCreateable()
                                {
                                    if(HdrSObj.get(s) != null)
                                    {
                                        Datetime dt = dcUtils.getDateTimeInTimezone(DateTime.valueof(HdrSObj.get(s)).dateGmt(), DateTime.valueof(HdrSObj.get(s)).timeGmt(), timeZone);
                                        HdrSObj.put(s,dt);
                                    }
                                }
                            }    
                        }
                    }
                }
            }
            system.debug(Logginglevel.INFO,'lstHdrSObject: '+lstHdrSObject.size()+'  '+lstHdrSObject);
            list<SVMXC__Checklist__c> lstChklist = new list<SVMXC__Checklist__c>();
            for(Sobject obj: lstHdrSObject)
            {
                SVMXC__Checklist__c chckObj = (SVMXC__Checklist__c)obj;
                lstChklist.add(chckObj);
                if(chckObj.SVMXC__SM_Sequence__c == null ||(chckObj.SVMXC__SM_Sequence__c != null && chckObj.SVMXC__SM_Sequence__c == 1))
                    HdrSObject = obj;
            }
            System.debug(Logginglevel.INFO,'HdrSObject: '+HdrSObject);
            
            if(lstChklist != null)
            {
                try{
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstChklist, COMM_SecurityUtils.Access.Upsertable)) {
                        
                        upsert lstChklist; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                    }
                    
                    lstHdrSObject.clear();
                    for(SVMXC__Checklist__c obj: lstChklist)
                        lstHdrSObject.add((Sobject)obj);
                }
                catch(exception ex)
                {
                    Database.rollback(sp);
                    system.debug('exception'+ex.getStackTraceString());
                    SFMResponse.success = false;
                    SFMResponse.message = '';
                    SVMXC.SFM_WrapperDef.SVMXMessage SVMXmessage = new SVMXC.SFM_WrapperDef.SVMXMessage();
                    SVMXmessage = MessageUtils.buildExceptionMessage(ex,null,'Process: '+SFMID);
                    
                    system.debug('SVMXmessage'+SVMXmessage);
                    SFMResponse.message += SVMXmessage.message;
                    SFMResponse.msgDetails = SVMXmessage;
                    fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                    return SFMResponse;
                }
            }    
            //Do Header Source Update...
            System.debug(Logginglevel.INFO,'processId: '+processId);
            System.debug(Logginglevel.INFO,'lstHdrSObject: '+lstHdrSObject.size()+' : '+lstHdrSObject);
            System.debug(Logginglevel.INFO,'HdrSourceUpdateRecId: '+HdrSourceUpdateRecId);
            System.debug(Logginglevel.INFO,'HeaderObjName: '+HeaderObjName);
              
            if(processId != null && processId.length() > 0 && HdrSobject != null && HdrSourceUpdateRecId != null && HdrSourceUpdateRecId.length() > 0 && HeaderObjName != null && HeaderObjName.length() > 0){
                if(sfmtargetrec.eventType == null || (sfmtargetrec.eventType != null && !sfmtargetrec.eventType.equalsIgnoreCase(CHECKLIST_QUICK_SAVE))){  //Defect 020564: To prevent Source object update on Checklist Quicksave                
                    SVMXC.SFM_WrapperDef.SFM_Response hdrSrcUpdRes = new SVMXC.SFM_WrapperDef.SFM_Response();
                    hdrSrcUpdRes = DoHeaderSourceObjectUpdate(processId,HdrSobject,HdrSourceUpdateRecId,HeaderObjName,null,AllFieldDescribe);
                    if(!hdrSrcUpdRes.success){
                        Database.rollback(sp);
                        SFMResponse.success = false;
                        SFMResponse.eventType = sfmtargetrec.eventType;
                        SFMResponse.message = hdrSrcUpdRes.message;
                        SFMResponse.msgDetails = hdrSrcUpdRes.msgDetails;
                        fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                        return SFMResponse;
                    }
                }           
            }
            // Before returning always populate header reocrd Id so that client can redirect it.
            System.debug(Logginglevel.INFO,'Returning SFMResponse: '+SFMResponse);
            System.debug('lstHdrSObject: '+lstHdrSObject);
            SFMResponse.resultIds.clear();
            for(sobject HdrSObj:lstHdrSObject){
                if(HdrSObj != null && HdrSObj.get('Id') != null){
                    SFMResponse.resultIds.add(String.valueof(HdrSObj.get('Id')));
                }
            }
            System.debug('SFMResponse'+SFMResponse);
        }
        //-------END---checklist MetaJason changes---------// 
        else{
            if(HeaderRecord.size() > 0)
            {
                if(HeaderRecord[0].sourceRecordId != null){
                    HdrSourceUpdateRecId = HeaderRecord[0].sourceRecordId;
                }

                /* Commented as part of BAC-3056 code optimization
                if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0)
                {
                    if(HeaderObjName != null && HeaderObjName.length() > 0){
                        if(mapObjectAPINameWithFields.size() > 0 && mapObjectAPINameWithFields.containskey(HeaderObjName))
                            HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromGivenKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null,true,mapObjectAPINameWithFields.get(HeaderObjName));
                        else    
                            HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromGivenKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null,true,null);
                    }           
                    Integer i = 0,l= HeaderRecord[0].targetRecordAsKeyValue.size();
                    for(i = 0;i<l;i++){
                        setHeaderFields.add(HeaderRecord[0].targetRecordAsKeyValue[i].key);
                    }           
                }
                else if(HeaderRecord[0].sobjectinfo != null)
                {
                    HeaderSobjMap.put('1',HeaderRecord[0].sobjectinfo);
                }
                */

                //----------Start------------Added as part of code optimization BAC-3056----------//
                if(HeaderRecord[0].sObjectRecord != null)
                {
                    //get fields and value as map from sobject
                    Map<String, Object> fieldsToValue = HeaderRecord[0].sObjectRecord.getPopulatedFieldsAsMap();
                    //Below changes done for Philips : To enable / disable session management feature
                    Boolean isSessionMgmtDisabled = false;
                    try{
                        String sessionMgmtSetting = new SVMXC.COMM_Utils_ManageSettings().getGlobalSettingValue(SESSION_MGMT);
                        if(String.isNotBlank(sessionMgmtSetting))
                        {
                            isSessionMgmtDisabled = Boolean.valueOf(sessionMgmtSetting);
                        }
                    }catch(Exception e)
                    {
                        System.debug(LoggingLevel.Error,e.getStackTraceString());
                    }
                    System.debug(LoggingLevel.DEBUG, 'isSessionMgmtDisabled: '+ isSessionMgmtDisabled);
                    if(!isSessionMgmtDisabled){
                        //Added for BAC-4682/SFD-1246
                        Boolean isConflictResolved = true;
                        if(sfmtargetrec.stringMap != null && sfmtargetrec.stringMap.size() >0 && sfmtargetrec.stringMap[0].key != null && sfmtargetrec.stringMap[0].value != null && sfmtargetrec.stringMap[0].key == 'isConflictResolved' && sfmtargetrec.stringMap[0].value=='true'){
                            isConflictResolved = false;
                        }
                        
                        if(isConflictResolved && HeaderRecord[0].sObjectRecord.Id !=null){//TODO
                            System.debug('HeaderRecord[0].sObjectRecord '+fieldsToValue.get('LastModifiedDate'));
                            Sobject SobjectList = Database.query('select Id, LastModifiedDate, LastModifiedById, LastModifiedBy.Name from ' + HeaderObjName + ' where Id = \''+HeaderRecord[0].sObjectRecord.Id+'\'');
                            if(SobjectList != null && fieldsToValue.get('LastModifiedDate') != null && fieldsToValue.get('LastModifiedDate') != SobjectList.get('LastModifiedDate')){
                                User userDetails = (User)SobjectList.getSObject('LastModifiedBy');
                                //System.debug('userDetails '+userDetails+' UserInfo.getUserId() '+UserInfo.getUserId());
                                if(UserInfo.getUserId() != userDetails.Id){
                                    Database.rollback(sp);
                                    SFMResponse.success = false;
                                    SFMResponse.message = System.Label.SFM002_TAG262+' '+userDetails.Name;
                                    SFMResponse.messageType = 'LMDConflict';
                                    fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                                    return SFMResponse;
                                }
                            }
                        }
                    }
                    //Added for BAC-4682/SFD-1246
                    if(fieldsToValue != null && fieldsToValue.size() > 0){
                        if(HeaderObjName != null && HeaderObjName.length() > 0){
                            if(mapObjectAPINameWithFields.size() > 0 && mapObjectAPINameWithFields.containskey(HeaderObjName)){
                                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromGivenSobjectForHeader(fieldsToValue, HeaderObjName, mapObjectAPINameWithFields.get(HeaderObjName));
                            }
                            else{
                                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromGivenSobjectForHeader(fieldsToValue, HeaderObjName, null);
                            }
                        }
                        setHeaderFields.addAll(fieldsToValue.keySet());
                    }     
                }
                else if(HeaderRecord[0].sobjectinfo != null)
                {
                    HeaderSobjMap.put('1',HeaderRecord[0].sobjectinfo);
                }
                //----------End------------Added as part of code optimization BAC-3056----------//
            }
            System.debug(Logginglevel.INFO,'HeaderSobjMap'+HeaderSobjMap);
            System.debug(Logginglevel.INFO,'setHeaderFields'+setHeaderFields);

            if(HeaderSobjMap.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0 )
            {
                HdrSObject = HeaderSobjMap.values();
                map<String, Schema.SObjectField> LocalFldMap = new map<String, Schema.SObjectField>();
                if(AllFieldDescribe.containskey(HeaderObjName)){
                    LocalFldMap = AllFieldDescribe.get(HeaderObjName);
                }
                if(LocalFldMap.size() > 0 && setHeaderFields.size() > 0)
                {
                    for(String s : setHeaderFields)
                    {
                        if(LocalFldMap.containskey(s)){
                            Schema.DescribeFieldResult f = LocalFldMap.get(s).getDescribe();
                            if(f.isAccessible()  && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime)//&& f.isCreateable()
                            {
                                if(HdrSObject.get(s) != null)
                                {
                                    System.debug(Logginglevel.INFO,'Datetime Before timezone conversion'+HdrSObject.get(s));
                                    Datetime dt = dcUtils.getDateTimeInTimezone(DateTime.valueof(HdrSObject.get(s)).dateGmt(), DateTime.valueof(HdrSObject.get(s)).timeGmt(), timeZone);
                                    HdrSObject.put(s,dt);
                                    system.debug(Logginglevel.INFO,'Datetime After timezone conversion'+dt);
                                }
                            }
                        }    
                    }
                }
            }
            System.debug(Logginglevel.INFO,'HdrSObject: '+HdrSObject);
            if(HdrSObject != null)
            {
                try{
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    upsert HdrSObject;
                }
                //------Start------Added for the story BAC-3839
                catch(System.DMLException dmlExp){
                    //setting field list which causing issues in DML operation
                    SVMXC.SFM_WrapperDef.Record objRecord = new SVMXC.SFM_WrapperDef.Record();
                    if(dmlExp.getDmlFieldNames(0).size() > 0)
                        objRecord.fieldApiName = dmlExp.getDmlFieldNames(0)[0];
                    objRecord.errorMessage = dmlExp.getDmlMessage(0);

                    SVMXC.SFM_WrapperDef.ExceptionInformation objExceptionInformation = new SVMXC.SFM_WrapperDef.ExceptionInformation();
                    objExceptionInformation.headerRecord = objRecord;
                    SFMResponse.objExceptionInformation = objExceptionInformation;

                    Database.rollback(sp);
                    SFMResponse.success = false;
                    SFMResponse.message = '';
                    SVMXC.SFM_WrapperDef.SVMXMessage SVMXmessage = new SVMXC.SFM_WrapperDef.SVMXMessage();
                    SVMXmessage = MessageUtils.buildExceptionMessage(dmlExp,null,'Process: '+SFMID);
                    system.debug('SVMXmessage'+SVMXmessage);
                    SFMResponse.message += SVMXmessage.message;
                    SFMResponse.msgDetails = SVMXmessage;
                    fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                    return SFMResponse;
                }
                //------End------Added for the story BAC-3839
                catch(exception ex)
                {
                    Database.rollback(sp);
                    SFMResponse.success = false;
                    SFMResponse.message = '';
                    SVMXC.SFM_WrapperDef.SVMXMessage SVMXmessage = new SVMXC.SFM_WrapperDef.SVMXMessage();
                    SVMXmessage = MessageUtils.buildExceptionMessage(ex,null,'Process: '+SFMID);
                    system.debug('SVMXmessage'+SVMXmessage);
                    SFMResponse.message += SVMXmessage.message;
                    SFMResponse.msgDetails = SVMXmessage;
                    fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                    return SFMResponse;
                }
            }
            //Do Header Source Update...
            System.debug(Logginglevel.INFO,'processId: '+processId);
            System.debug(Logginglevel.INFO,'HdrSobject: '+HdrSobject);
            System.debug(Logginglevel.INFO,'HdrSourceUpdateRecId: '+HdrSourceUpdateRecId);
            System.debug(Logginglevel.INFO,'HeaderObjName: '+HeaderObjName);
            if(processId != null && processId.length() > 0 && HdrSobject != null && HdrSourceUpdateRecId != null && HdrSourceUpdateRecId.length() > 0 && HeaderObjName != null && HeaderObjName.length() > 0){
                if(sfmtargetrec.eventType == null || (sfmtargetrec.eventType != null && !sfmtargetrec.eventType.equalsIgnoreCase(CHECKLIST_QUICK_SAVE))){  //Defect 020564: To prevent Source object update on Checklist Quicksave                
                    
                    if(SFM_TDM_Delivery.isBackgroundSfmInSplitMode){
                        SFM_TDM_Delivery.isHdrSourceUpdate = true;
                        SFM_TDM_Delivery.headerSourceUpdateProperties = new SFM_TDM_Delivery.sourceUpdateDef(processId, HdrSobject, HdrSourceUpdateRecId, HeaderObjName, AllFieldDescribe);
                    }
                    else{
                        SVMXC.SFM_WrapperDef.SFM_Response hdrSrcUpdRes = new SVMXC.SFM_WrapperDef.SFM_Response();
                        hdrSrcUpdRes = DoHeaderSourceObjectUpdate(processId,HdrSobject,HdrSourceUpdateRecId,HeaderObjName,null,AllFieldDescribe);
                        if(! hdrSrcUpdRes.success){
                            Database.rollback(sp);
                            SFMResponse.success = false;
                            SFMResponse.eventType = sfmtargetrec.eventType;
                            SFMResponse.message = hdrSrcUpdRes.message;
                            SFMResponse.msgDetails = hdrSrcUpdRes.msgDetails;
                            fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                            return SFMResponse;
                        }
                    }
                }           
            }
            System.debug(Logginglevel.INFO,'SFM_TDM_Delivery.isBackgroundSfmInSplitMode: '+SFM_TDM_Delivery.isBackgroundSfmInSplitMode);
            System.debug(Logginglevel.INFO,'FM_TDM_Delivery.headerSourceUpdateProperties: '+SFM_TDM_Delivery.headerSourceUpdateProperties);
            
            //now process the detail Reocrds..
            List<SVMXC.SFM_SaveTargetRecords.DetailSourceUpdateWrap> lstDtlSrcUpdateWrap = new List<SVMXC.SFM_SaveTargetRecords.DetailSourceUpdateWrap>();
            list<Sobject> DetailRecordsForUpdate = new list<Sobject>();
            list<Sobject> DetailRecordsForInsert = new list<Sobject>();
            Map<Integer,List<SVMXC.SFM_WrapperDef.SFM_Record>> TargetRecMap = new Map<Integer,List<SVMXC.SFM_WrapperDef.SFM_Record>>(); 
            map<Integer,String> DetailObjName = new map<Integer,String>();
            map<Integer,String> AliasNameMap = new map<Integer,String>(); 
            map<Integer,String> ParentColumnNameMap = new map<Integer,String>();
            map<Integer,List<String>> DeleteRecordIdMap = new map<Integer,List<String>>();
            if(DtlTargetRecordObject.size() > 0)
            {
                for(Integer i = 0;i<DtlTargetRecordObject.size();i++)
                {
                    if(DtlTargetRecordObject[i].records != null && DtlTargetRecordObject[i].records.size() > 0 )
                        TargetRecMap.put(i,DtlTargetRecordObject[i].records);
                    if(DtlTargetRecordObject[i].objName != null && DtlTargetRecordObject[i].objName.length() > 0)
                        DetailObjName.put(i,DtlTargetRecordObject[i].objName);
                    if(DtlTargetRecordObject[i].aliasName != null && DtlTargetRecordObject[i].aliasName.length() > 0)
                        AliasNameMap.put(i,DtlTargetRecordObject[i].aliasName);  
                    if(DtlTargetRecordObject[i].parentColumnName != null && DtlTargetRecordObject[i].parentColumnName.length() > 0)
                        ParentColumnNameMap.put(i,DtlTargetRecordObject[i].parentColumnName);
                    if(DtlTargetRecordObject[i].deleteRecID != null && DtlTargetRecordObject[i].deleteRecID.size() > 0)
                        DeleteRecordIdMap.put(i,DtlTargetRecordObject[i].deleteRecID);//recordIds to be delete          
                }
            }
            System.debug('TargetRecMap: '+TargetRecMap);
            System.debug('DetailObjName: '+DetailObjName);
            System.debug('AliasNameMap: '+AliasNameMap);
            System.debug('ParentColumnNameMap: '+ParentColumnNameMap);
            System.debug('DeleteRecordIdMap: '+DeleteRecordIdMap);

            //----Start-----Added for the story BAC-3839
            Map<Integer, String> mapRecIndexAliasIdForInsert = new Map<Integer, String>();
            Map<Integer, String> mapRecIndexAliasIdForUpdate = new Map<Integer, String>();
            Map<String, String> mapAliasIdRecIndexVsLocalId = new Map<String, String>();
            Integer totalChunksForInsert = 0; // #chunkWork
            Integer totalChunksForUpdate = 0; // #chunkWork
            Map<String, list<sobject>> objectNameRecordsInsertMap = new Map<String, list<sObject>> (); // #chunkWork
            Map<String, list<sobject>> objectNameRecordsUpdateMap = new Map<String, list<sObject>> (); // #chunkWork

            //----End-----Added for the story BAC-3839
            if(TargetRecMap.size() > 0)
            {
                for(Integer i : TargetRecMap.keyset())
                {
                    List<SVMXC.SFM_WrapperDef.SFM_Record> SfmReocrdlst = new List<SVMXC.SFM_WrapperDef.SFM_Record>(); 
                    SVMXC__ServiceMax_Processes__c DetailNodeObject = new  SVMXC__ServiceMax_Processes__c();
                    list<SVMXC__ServiceMax_Config_Data__c> DetailSourceUpdates = new list<SVMXC__ServiceMax_Config_Data__c>();
                    set<String> DetailSourceUpdateIds = new set<String>();
                    String ObjectName = '';
                    String AliasName = '';
                    String ParentColumnName = '';
                    if(TargetRecMap.containskey(i)){
                        SfmReocrdlst = TargetRecMap.get(i);
                    }
                    if(DetailObjName.containskey(i)){
                        ObjectName = DetailObjName.get(i);
                    }
                    if(AliasNameMap.containskey(i)){
                        AliasName = AliasNameMap.get(i);
                    }
                    if(ParentColumnNameMap.containskey(i)){
                        ParentColumnName = ParentColumnNameMap.get(i);
                    }
                    
                    Map<String,Schema.SObjectField> DetailFieldMap = new Map<String,Schema.SObjectField>(); 
                  //  if(ObjectName != null && ObjectName.length() > 0 && Allobj.containskey(ObjectName) && AllFieldDescribe.containskey(ObjectName)== false) //#optiChange
                    if(String.isNotBlank(ObjectName) &&  !AllFieldDescribe.containskey(ObjectName))
                    {
                        Map<String,Schema.SObjectField> DFieldMap = new Map<String,Schema.SObjectField>();
                        DFieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(ObjectName);
                        if(DFieldMap != NULL && !DFieldMap.isEmpty())
                        {
                            for(String s : DFieldMap.keyset())
                            {
                                DetailFieldMap.put(DFieldMap.get(s).getDescribe().getname(),DFieldMap.get(s));
                            }
                            AllFieldDescribe.put(ObjectName,DetailFieldMap);
                        }
                    }
                    System.debug('AllFieldDescribe: '+AllFieldDescribe);
                    System.debug('SfmReocrdlst size: '+SfmReocrdlst.size()+'- records: '+SfmReocrdlst);

                    if(SfmReocrdlst.size() > 0)
                    {
                        //Commented as part of BAC-3056 code optimization
                        /*for(Integer x = 0;x<SfmReocrdlst[0].targetRecordAsKeyValue.size();x++){
                            setDetailFields.add(SfmReocrdlst[0].targetRecordAsKeyValue[x].key);
                        }
                        System.debug('setDetailFields: '+setDetailFields.size()+setDetailFields);*/

                        /*Commented as part of defect fixing 042831
                        //Added as part of code optimization BAC-3056
                        if(SfmReocrdlst[0].sObjectRecord != null){
                            Sobject sObjectRecordTemp = SfmReocrdlst[0].sObjectRecord;
                            Map<String, Object> fieldsToValueChildRec = sObjectRecordTemp.getPopulatedFieldsAsMap();
                            if(fieldsToValueChildRec != null && fieldsToValueChildRec.size() > 0){
                                setDetailFields.addAll(fieldsToValueChildRec.keyset());
                            }
                        }
                        System.debug('setDetailFields size: '+setDetailFields.size()+'- fields:'+setDetailFields);
                        */

                        //Build the Detail Sobject from key-value 
                        map<String,list<Sobject>> DetailSobjMap = new map<String,list<Sobject>>();
                        if(SfmReocrdlst.size() > 0 && ObjectName != null && ObjectName.length() > 0 && ParentColumnName != null && ParentColumnName.length() > 0 && HdrSObject != null && HdrSObject.get('Id') != null)
                        {
                            //Commented as part of BAC-3056 code optimization
                            //DetailSobjMap = sobjectfromkevalue.BuildSobjectFromGivenKeyValue2(SfmReocrdlst,ObjectName,ParentColumnName,String.valueof(HdrSObject.get('Id')),AllFieldDescribe,true,null);//AllFieldDescribe

                            //------Start------Added for the story BAC-3839
                            for(Integer recIndex = 0; recIndex < SfmReocrdlst.size(); recIndex++){
                                if(SfmReocrdlst[recIndex].targetRecordId == null && SfmReocrdlst[recIndex].sObjectRecord != null && SfmReocrdlst[recIndex].rowIndex != null){
                                    mapAliasIdRecIndexVsLocalId.put(AliasName+'~'+mapAliasIdRecIndexVsLocalId.size(), SfmReocrdlst[recIndex].rowIndex);
                                }
                            }
                            System.debug('mapAliasIdRecIndexVsLocalId: '+mapAliasIdRecIndexVsLocalId);
                            //------End------Added for the story BAC-3839

                            //Added as part of code optimization BAC-3056
                            DetailSobjMap = sobjectfromkevalue.BuildSobjectFromGivenSobjectForDetail(SfmReocrdlst, ObjectName, ParentColumnName, String.valueof(HdrSObject.get('Id')),AllFieldDescribe);//AllFieldDescribe

                            //Added for the defect fix 042831
                            if(sobjectfromkevalue.setAllFieldsUsedInSobject.size() > 0){
                                setDetailFields.clear();
                                setDetailFields.addAll(sobjectfromkevalue.setAllFieldsUsedInSobject);
                            }
                        }   
                        System.debug('DetailSobjMap: '+DetailSobjMap);

                        Map<String,Sobject> SourceRecIdTargetObjMap = new Map<String,Sobject>();
                        if(DetailSobjMap.size() > 0)
                        {
                            for(String s : DetailSobjMap.keyset())
                            {
                                if(s.touppercase() == 'INSERT')
                                {
                                    doDateTimeConversionAndCurrencyHandling(HdrSObject, DetailSobjMap.get(s), ObjectName, setDetailFields, timeZone, AllFieldDescribe, true, dcUtils);
                                    DetailRecordsForInsert.addall(DetailSobjMap.get(s));
                                    totalChunksForInsert += getChunckCount(DetailSobjMap.get(s).size()); // #chunkWork Defect 047622
                                    objectNameRecordsInsertMap.put(ObjectName, DetailSobjMap.get(s)); // #chunkWork Defect 047622
                                    
                                    //------Start------Added for the story BAC-3839
                                    for(Sobject obj: DetailSobjMap.get(s)){
                                        mapRecIndexAliasIdForInsert.put(mapRecIndexAliasIdForInsert.size(), AliasName+'~'+mapRecIndexAliasIdForInsert.size());
                                    }
                                    System.debug('mapRecIndexAliasIdForInsert: '+mapRecIndexAliasIdForInsert);
                                    //------End------Added for the story BAC-3839
                                }
                                else if(s.touppercase() == 'UPDATE')
                                {
                                    doDateTimeConversionAndCurrencyHandling(HdrSObject, DetailSobjMap.get(s), ObjectName, setDetailFields, timeZone, AllFieldDescribe, false, dcUtils);
                                    DetailRecordsForUpdate.addall(DetailSobjMap.get(s));
                                    totalChunksForUpdate += getChunckCount(DetailSobjMap.get(s).size());
                                    objectNameRecordsUpdateMap.put(ObjectName, DetailSobjMap.get(s));

                                    //------Start------Added for the story BAC-3839
                                    for(Sobject obj: DetailSobjMap.get(s)){
                                        mapRecIndexAliasIdForUpdate.put(mapRecIndexAliasIdForUpdate.size(), AliasName);
                                    }
                                    System.debug('mapRecIndexAliasIdForUpdate: '+mapRecIndexAliasIdForUpdate);
                                    //------End------Added for the story BAC-3839
                                }
                                else
                                {
                                    list<Sobject> lstSobject = new list<Sobject>();
                                    lstSobject = DetailSobjMap.get(s);
                                    SourceRecIdTargetObjMap.put(s,lstSobject[0]);
                                }
                                DetailSobjMap.remove(s); //#chunkWork Defect 047622, we can clear this map since no longer used ahead
                            }
                        }
                        System.debug('DetailRecordsForInsert: '+DetailRecordsForInsert);
                        System.debug('DetailRecordsForUpdate: '+DetailRecordsForUpdate);
                        System.debug('SourceRecIdTargetObjMap: '+SourceRecIdTargetObjMap); 
                        
                        //Update list to perform source update for details
                        lstDtlSrcUpdateWrap.add(new DetailSourceUpdateWrap(processId, SourceRecIdTargetObjMap, ObjectName, AliasName, 
                        AllFieldDescribe));
                    }
                }
            }   
            System.debug(LoggingLevel.WARN, 'Detail records to be inserted: ' + DetailRecordsForInsert);
            System.debug(LoggingLevel.WARN, 'Detail records to be updated: ' + DetailRecordsForUpdate);

            //------Start------Added for the story BAC-3839
            System.debug('mapAliasIdRecIndexVsLocalId: '+mapAliasIdRecIndexVsLocalId);
            System.debug('mapRecIndexAliasIdForInsert: '+mapRecIndexAliasIdForInsert);
            System.debug('mapRecIndexAliasIdForUpdate: '+mapRecIndexAliasIdForUpdate);
            String strOperationType = '';
            //------End------Added for the story BAC-3839
            
            try
            {
                if(DetailRecordsForInsert != NULL && DetailRecordsForInsert.size() > 0){
                    strOperationType = 'INSERT'; //Added for the story BAC-3839
                    
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( DetailRecordsForInsert, COMM_SecurityUtils.Access.Createable ) ) {
                        // #chunkWork Starts Defect 047622
                        //insert DetailRecordsForInsert; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED //#chunkWork Commented Code
                        if(totalChunksForInsert <= MAX_CHUNK_SIZE){
                            insert DetailRecordsForInsert; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else{
                            System.debug('More than 10 chunks found, inserting records object wise');
                            for(String objName : objectNameRecordsInsertMap.keySet()){
                                insert objectNameRecordsInsertMap.get(objName);
                                objectNameRecordsInsertMap.remove(objName);
                            }
                        }
                        // #chunkWork ends Defect 047622
                        
                        //-------Start---------Added for the story BAC-4027
                        if(sfmtargetrec.callType != null && sfmtargetrec.callType.equalsIgnoreCase(SAVE_FOR_LINKED_SFM)){
                            List<SVMXC.SFM_WrapperDef.ExceptionForDetailRecord> lstDetRec = new List<SVMXC.SFM_WrapperDef.ExceptionForDetailRecord>();
                            Map<String, List<SVMXC.SFM_WrapperDef.Record>> mapAliasIdListOfRec = new Map<String, List<SVMXC.SFM_WrapperDef.Record>>();
                            for(Integer i = 0 ; i < DetailRecordsForInsert.size() ; i++){
                                String strRecordId = DetailRecordsForInsert[i].Id;
                                String strRowIndex;
                                String strAliasId;
                            
                                if(mapRecIndexAliasIdForInsert.containsKey(i)){
                                    String strUniqueAliasId = mapRecIndexAliasIdForInsert.get(i);
                                    if(mapAliasIdRecIndexVsLocalId.containsKey(strUniqueAliasId)){
                                        strRowIndex = mapAliasIdRecIndexVsLocalId.get(strUniqueAliasId);
                                        strAliasId =  strUniqueAliasId.split('~')[0];
                                    }
                                }
                                
                                //Creating Record class object by populating rowIndex and recordId
                                SVMXC.SFM_WrapperDef.Record objRecord = new SVMXC.SFM_WrapperDef.Record();
                                objRecord.rowIndex = strRowIndex;
                                objRecord.recordId = strRecordId;
            
                                //creating a map of alias id and corresponding record list having issues
                                if(!mapAliasIdListOfRec.containsKey(strAliasId)){
                                    mapAliasIdListOfRec.put(strAliasId, new List<SVMXC.SFM_WrapperDef.Record>());
                                }
                                mapAliasIdListOfRec.get(strAliasId).add(objRecord);
                            }
                            if(mapAliasIdListOfRec.size() > 0){
                                for(String objAliasId : mapAliasIdListOfRec.keyset()){
                                    SVMXC.SFM_WrapperDef.ExceptionForDetailRecord objDetRec = new SVMXC.SFM_WrapperDef.ExceptionForDetailRecord();
                                    objDetRec.aliasId = objAliasId;
                                    objDetRec.recordList = mapAliasIdListOfRec.get(objAliasId);
                                    lstDetRec.add(objDetRec);
                                }
                            }
                            System.debug('lstDetRec: '+lstDetRec);
                            SFMResponse.lstNewDetailRecordIds = lstDetRec;
                        }
                        //-------End-----------Added for the story BAC-4027
                    } 
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                }
                if(DetailRecordsForUpdate != NULL && DetailRecordsForUpdate.size() > 0){
                    strOperationType = 'UPDATE'; //Added for the story BAC-3839
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( DetailRecordsForUpdate, COMM_SecurityUtils.Access.Updateable ) ) {
                        // #chunkWork Starts Defect 047622
                        //update DetailRecordsForUpdate; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        if(totalChunksForUpdate <= MAX_CHUNK_SIZE){
                            update DetailRecordsForUpdate; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else{
                            System.debug('More than 10 chunks found, updating records object wise');
                            for(String objName : objectNameRecordsUpdateMap.keySet()){
                                update objectNameRecordsUpdateMap.get(objName);
                                objectNameRecordsUpdateMap.remove(objName);
                            }
                        }
                        // #chunkWork ends Defect 047622
                    } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
            }
            //------Start------Added for the story BAC-3839
            catch(System.DMLException dmlExp){
                Map<String, List<SVMXC.SFM_WrapperDef.Record>> mapAliasIdListOfRec = new Map<String, List<SVMXC.SFM_WrapperDef.Record>>();
                List<SVMXC.SFM_WrapperDef.ExceptionForDetailRecord> lstExcpDetRec = new List<SVMXC.SFM_WrapperDef.ExceptionForDetailRecord>();
                System.debug('Count of rows having issues: '+dmlExp.getNumDml());
                for (Integer i = 0; i < dmlExp.getNumDml(); i++) {
                    String fieldAPIName;
                    if(dmlExp.getDmlFieldNames(i).size() > 0)
                        fieldAPIName = dmlExp.getDmlFieldNames(i)[0];
                    String strRecordId = dmlExp.getDmlId(i);
                    String strErrorMessage = dmlExp.getDmlMessage(i);
                    String strRowIndex;
                    String strAliasId;

                    //Based on operation type collecting alias Id and Row index
                    if(strOperationType.equalsIgnoreCase('INSERT')){
                        if(mapRecIndexAliasIdForInsert.containsKey(dmlExp.getDmlIndex(i))){
                            String strUniqueAliasId = mapRecIndexAliasIdForInsert.get(dmlExp.getDmlIndex(i));
                            if(mapAliasIdRecIndexVsLocalId.containsKey(strUniqueAliasId)){
                                strRowIndex = mapAliasIdRecIndexVsLocalId.get(strUniqueAliasId);
                                strAliasId =  strUniqueAliasId.split('~')[0];
                            }
                        }
                    }
                    else if(strOperationType.equalsIgnoreCase('UPDATE')){
                        if(mapRecIndexAliasIdForUpdate.containsKey(dmlExp.getDmlIndex(i))){
                            strAliasId = mapRecIndexAliasIdForUpdate.get(dmlExp.getDmlIndex(i));
                        }
                    }

                    //Creating Record class object by populating either rowIndex Or recordId based on operation Type
                    SVMXC.SFM_WrapperDef.Record objRecord = new SVMXC.SFM_WrapperDef.Record();
                    objRecord.fieldApiName = fieldAPIName;
                    objRecord.errorMessage = strErrorMessage;
                    if(strOperationType.equalsIgnoreCase('INSERT')){
                        objRecord.rowIndex = strRowIndex;
                    }
                    else if(strOperationType.equalsIgnoreCase('UPDATE')){
                        objRecord.recordId = strRecordId;
                    }

                    //creating a map of alias id and corresponding record list having issues
                    if(!mapAliasIdListOfRec.containsKey(strAliasId)){
                        mapAliasIdListOfRec.put(strAliasId, new List<SVMXC.SFM_WrapperDef.Record>());
                    }
                    mapAliasIdListOfRec.get(strAliasId).add(objRecord);
                }
                System.debug('mapAliasIdListOfRec: '+mapAliasIdListOfRec);
                if(mapAliasIdListOfRec.size() > 0){
                    for(String objAliasId : mapAliasIdListOfRec.keyset()){
                        SVMXC.SFM_WrapperDef.ExceptionForDetailRecord objExcpDetRec = new SVMXC.SFM_WrapperDef.ExceptionForDetailRecord();
                        objExcpDetRec.aliasId = objAliasId;
                        objExcpDetRec.recordList = mapAliasIdListOfRec.get(objAliasId);
                        lstExcpDetRec.add(objExcpDetRec);
                    }
                }
                System.debug('lstExcpDetRec: '+lstExcpDetRec);
                if(lstExcpDetRec.size() > 0){
                    SVMXC.SFM_WrapperDef.ExceptionInformation objExceptionInformation = new SVMXC.SFM_WrapperDef.ExceptionInformation();
                    objExceptionInformation.detailRecord = lstExcpDetRec;
                    SFMResponse.objExceptionInformation = objExceptionInformation;
                }
                Database.rollback(sp);
                SFMResponse.success = false;
                SFMResponse.message = '';
                SVMXC.SFM_WrapperDef.SVMXMessage SVMXmessage = new SVMXC.SFM_WrapperDef.SVMXMessage();
                SVMXmessage = MessageUtils.buildExceptionMessage(dmlExp,null,'Process: '+SFMID);
                system.debug('SVMXmessage'+SVMXmessage);
                SFMResponse.message += SVMXmessage.message;
                SFMResponse.msgDetails = SVMXmessage;
                fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                return SFMResponse;
            }
            //------End------Added for the story BAC-3839
            catch(Exception ex)
            {
                Database.rollback(sp);
                SFMResponse.success = false;
                SFMResponse.message = '';
                SVMXC.SFM_WrapperDef.SVMXMessage SVMXmessage = new SVMXC.SFM_WrapperDef.SVMXMessage();
                SVMXmessage = MessageUtils.buildExceptionMessage(ex,null,'Process: '+SFMID);
                system.debug('SVMXmessage'+SVMXmessage);
                SFMResponse.message += SVMXmessage.message;
                SFMResponse.msgDetails = SVMXmessage;
                fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                return SFMResponse;
            }
        
            System.debug(LoggingLevel.WARN, 'Detail source update records map: ' + lstDtlSrcUpdateWrap);
            //Start Processing the Detail source update
            for(DetailSourceUpdateWrap dtlSrcUpdateWrap: lstDtlSrcUpdateWrap){
                SVMXC.SFM_WrapperDef.SFM_Response dtlSrcUpdRes = new SVMXC.SFM_WrapperDef.SFM_Response();
                dtlSrcUpdRes = DoDetailsSourceObjectUpdate(dtlSrcUpdateWrap.processId, dtlSrcUpdateWrap.SourceRecIdTargetObjMap, 
                dtlSrcUpdateWrap.ObjectName, dtlSrcUpdateWrap.AliasName, dtlSrcUpdateWrap.AllFieldDescribe);
                if(!dtlSrcUpdRes.success){
                    Database.rollback(sp);
                    SFMResponse.success = false;
                    SFMResponse.eventType = sfmtargetrec.eventType;
                    SFMResponse.message = dtlSrcUpdRes.message;
                    SFMResponse.msgDetails = dtlSrcUpdRes.msgDetails;
                    fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                    return SFMResponse;
                }
            }
                
            //Delete operation..
            if(DeleteRecordIdMap.size() > 0)
            {
                for(Integer i : DeleteRecordIdMap.keyset())
                {
                    String ObjectName = '';
                    List<String> DelIds = new List<String>();
                    List<Sobject> DeleteRecordsForDelete = new List<Sobject>(); 
                    if(DeleteRecordIdMap.containskey(i))
                        DelIds = DeleteRecordIdMap.get(i);
                    if(DetailObjName.containskey(i))
                        ObjectName = DetailObjName.get(i);
                    String DelRecId = '';
                    if(DelIds.size() > 0)
                    {
                        for(Integer a = 0;a<DelIds.size();a++)
                        {
                            if(DelRecId.length() > 0)
                                DelRecId += ',';
                            DelRecId  += '\'' + DelIds[a] + '\'';
                        }
                    }
                    if(DelRecId != null && DelRecId.length() > 0 && ObjectName != null && ObjectName.length() > 0)   
                    {
                        String Query = 'Select Id From ' + ObjectName + ' Where Id IN (' + DelRecId+')';
                        System.debug('Query: '+Query);
                        DeleteRecordsForDelete = Database.Query(Query);
                    }
                    System.debug('DeleteRecordsForDelete size: '+DeleteRecordsForDelete.size()+'- records: '+DeleteRecordsForDelete);
                    if(DeleteRecordsForDelete.size() > 0)
                    {
                        try{
                            
                            if( !COMM_SecurityUtils.getInstance().isDeletableObject( ObjectName ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                            delete DeleteRecordsForDelete; //SDL-SVMX-FLS-ENFORCED-META-DATA
                        }
                        catch(Exception ex)
                        {
                            Database.rollback(sp);
                            SFMResponse.success = false;
                            SFMResponse.message = '';
                            SVMXC.SFM_WrapperDef.SVMXMessage SVMXmessage = new SVMXC.SFM_WrapperDef.SVMXMessage();
                            SVMXmessage = MessageUtils.buildExceptionMessage(ex,null,'Process: '+SFMID);
                            system.debug('SVMXmessage'+SVMXmessage);
                            SFMResponse.message += SVMXmessage.message;
                            SFMResponse.msgDetails = SVMXmessage;
                            fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                            return SFMResponse;
                        }   
                    }
                }
            }

            // Implementation for SFM Triggers. If SFM Trigger fails due to any reason, always return.
            if(processId != null && HdrSObject != null && HdrSObject.Id != null){
                //Query SFM Events of type SFM Trigger
                list<SVMXC__SFM_Event__c> lstSFMEvent = new list<SVMXC__SFM_Event__c>();
                lstSFMEvent = [select Id, SVMXC__Sequence__c, SVMXC__Namespace__c, SVMXC__Class__c, SVMXC__ServiceMax_Process__c, SVMXC__ServiceMax_Custom_Action__c, SVMXC__ServiceMax_Custom_Action__r.SVMXC__ProcessID__c, SVMXC__Event_Call_Type__c, SVMXC__Event_Type__c from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c =: processId and SVMXC__Event_Call_Type__c = 'SFM TRIGGER' order by SVMXC__Sequence__c];
                if(!lstSFMEvent.isEmpty()){
                    SFMResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
                    for(SVMXC__SFM_Event__c objSFMEvent : lstSFMEvent){
                        SFMResponse = CallSFMTrigger(objSFMEvent,HdrSObject.Id);
                        if(SFMResponse != null && !SFMResponse.success){
                            fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                            return SFMResponse;
                        }
                    }       
                }
            }

            // Implementation for Sub process
            if(SFMProcess != null && SFMProcess.SVMXC__Enable_Sub_Process__c && SFMProcess.SVMXC__Process2__c != null && SFMProcess.SVMXC__Sub_Process_Source_Field__c != null && HdrSObject.get(SFMProcess.SVMXC__Sub_Process_Source_Field__c) != null){
                //------Start--------Added for the defect 044816 and 044438 fix
                if(HdrSObject != null && HdrSObject.get('Id') != null){
                    System.debug('HdrSObject_Old: '+HdrSObject);
                    String strObjectName = HdrSObject.getSObjectType().getDescribe().getName();
                    String strRecId = (String)HdrSObject.get('Id');
                    Set<String> setOfFields = HdrSObject.getPopulatedFieldsAsMap().keyset();
                    setOfFields = setOfFields.clone();
                    setOfFields.add('OwnerId');
                    COMM_Utils_V2 commutils = new COMM_Utils_V2();
                    setOfFields = commutils.checkDuplicateFields(setOfFields, strObjectName);
                    String queryFields = commutils.SVMX_getFieldNamesFromList(new List<String>(setOfFields));
                    String strQuery = 'SELECT '+queryFields+ ' FROM '+strObjectName+ ' WHERE Id = \''+strRecId+ '\'';
                    HdrSObject = Database.query(strQuery);
                    System.debug('HdrSObject_New: '+HdrSObject);
                }
                //------End----------Added for the defect 044816 and 044438 fix
                
                SFMResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
                SVMXC.SFM_WrapperDef.SFM_Response responseOfSubProcess = new SVMXC.SFM_WrapperDef.SFM_Response();
                String strNextProcessId = SFMProcess.SVMXC__Process2__c;
                String strNextSourceRecordId = String.valueof(HdrSObject.get(SFMProcess.SVMXC__Sub_Process_Source_Field__c));
                SVMXC.SFM_CreateSubProcess subprocess = new SVMXC.SFM_CreateSubProcess();
                responseOfSubProcess = subprocess.createSubProcess(strNextProcessId,strNextSourceRecordId,Allobj,HdrSObject);
                System.debug(Logginglevel.INFO,'responseOfSubProcess: '+responseOfSubProcess);
                if(responseOfSubProcess.success){
                    SFMResponse.success = true;
                    SFMResponse.eventType = sfmtargetrec.eventType;
                    SFMResponse.message = System.Label.SFM002_TAG020;//'Saved Succefully';
                }
                else{
                    Database.rollback(sp);
                    SFMResponse.success = false;
                    SFMResponse.eventType = sfmtargetrec.eventType;
                    SFMResponse.message = responseOfSubProcess.message;
                    SFMResponse.msgDetails = responseOfSubProcess.msgDetails;
                    fromSFMSave = false;//Added by Nidhi as part of BAC-5144
                    return SFMResponse;
                }
            } 
            // Before returning always populate header reocrd Id so that client can redirect it.
            System.debug(Logginglevel.INFO,'Returning SFMResponse: '+SFMResponse);
            system.debug('HdrSObject: '+HdrSObject);
            if(HdrSObject  != null && HdrSObject.get('Id') != null){
                SFMResponse.resultIds.clear();
                SFMResponse.resultIds.add(String.valueof(HdrSObject.get('Id')));
            }
        }
        System.debug('SFMResponse: '+SFMResponse);
        fromSFMSave = false;//Added by Nidhi as part of BAC-5144
        return SFMResponse;
    }
         
    public SVMXC.SFM_WrapperDef.SFM_Response DoHeaderSourceObjectUpdate(String SFMId,Sobject TargetSobject,String SourceUpdateRecId,String ObjName,String AliasName,map<String,map<String,Schema.SObjectField>> AllFieldDescribe)
    {
        SVMXC.SFM_WrapperDef.SFM_Response SFMResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        SFMResponse.success = true;
        system.debug('Entered for Sourceupdate');
        system.debug('SFMId'+SFMId);
        system.debug('TargetSobject'+TargetSobject);
        system.debug('SourceUpdateRecId'+SourceUpdateRecId);
        system.debug('ObjName'+ObjName);
        system.debug('AliasName'+AliasName);
        system.debug('AllFieldDescribe'+AllFieldDescribe);
        map<String,Schema.SObjectField> LocalFieldMap = new Map<String,Schema.SObjectField>();
        map<String, Schema.SObjectField> SourceFieldMap = new map<String, Schema.SObjectField>();
        SVMXC__ServiceMax_Processes__c ProcessNodeObject = new  SVMXC__ServiceMax_Processes__c();
        list<SVMXC__ServiceMax_Config_Data__c> SourceUpdatesFields = new list<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__Question_Bank__c> lstQuestionRecords = new List<SVMXC__Question_Bank__c>(); //Added for the story BAC-3675
        Sobject SourceUpdateRec;
        String SourceObjectName = '';
        String TargetObjectName = '';
        Set<String> setQuestionIds = new Set<String>(); //Added for the story BAC-3675
        if(AllFieldDescribe.containskey(ObjName))
            LocalFieldMap = AllFieldDescribe.get(ObjName);
        //Start Processing for the Header source update.
        //first get the process node object from the sfm process 
        //if(SFMId != null && PNodeObjRTypeID != null && PNodeObjRTypeID.length() > 0) // #optiChange
        if(SFMId != null) 
        {
            
            if(ObjName != null && AliasName == null)
                
                ProcessNodeObject = [select id,SVMXC__Process__r.SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where RecordType.DeveloperName = 'Process_Node_Objects' and SVMXC__Process__c =: SFMId and SVMXC__Source_Object_Name__c =: ObjName and SVMXC__Type__c = 'TARGET']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(ObjName != null && AliasName != null)
                
                ProcessNodeObject = [select id,SVMXC__Process__r.SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where RecordType.DeveloperName = 'Process_Node_Objects' and SVMXC__Process__c =: SFMId and SVMXC__Page_Layout__c =: AliasName and SVMXC__Type__c = 'TARGETCHILD'];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('ProcessNodeObject'+ProcessNodeObject);
        }   
        //second Query the Source update defination & Source update Data from sfmid for the header object...
        if(ProcessNodeObject != null && ProcessNodeObject.id != null)
            
            SourceUpdatesFields = [select id,Name,SVMXC__Source_Field_Name__c,SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c,SVMXC__Setting_ID__r.SVMXC__Node_Source_Object_API__c,SVMXC__Target_Field_Name__c,SVMXC__Action__c,SVMXC__Display_Value__c,SVMXC__Display_Type__c, SVMXC__SM_Question__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_ID__c =: ProcessNodeObject.id and RecordType.DeveloperName = 'Field_Mapping' and SVMXC__Configuration_Type__c = 'Source Update']; //Modified for the story BAC-3675 to query SVMXC__SM_Question__c field also //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('SourceUpdatesFields'+SourceUpdatesFields);
        if(SourceUpdatesFields.size() > 0)
        {
            String strFields = '';
            for(Integer i = 0;i<SourceUpdatesFields.size();i++){
                if(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c != null){
                    if(strFields != '' && strFields.length() > 0)
                        strFields += ','+SourceUpdatesFields[i].SVMXC__Source_Field_Name__c;
                    else
                        strFields += SourceUpdatesFields[i].SVMXC__Source_Field_Name__c;
                }
                //Added for the story BAC-3675 to collect question ids
                if(SourceUpdatesFields[i].SVMXC__SM_Question__c != null){
                    setQuestionIds.add(SourceUpdatesFields[i].SVMXC__SM_Question__c);
                }
            }
            SourceObjectName = SourceUpdatesFields[0].SVMXC__Setting_ID__r.SVMXC__Node_Source_Object_API__c;
            TargetObjectName = SourceUpdatesFields[0].SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c;
            system.debug('SourceObjectName'+SourceObjectName);
            system.debug('TargetObjectName'+TargetObjectName);
           // if(SourceObjectName != null && SourceObjectName.length() > 0 && SourceUpdateRecId != null && SourceUpdateRecId.length() > 0)// #optiChange
                if(String.isNotBlank(SourceObjectName) && String.isNotBlank(SourceUpdateRecId)) {// #optiChange
               // if(Allobj.containskey(SourceObjectName) && AllFieldDescribe.containskey(SourceObjectName) == false) #optiChange
                if(!AllFieldDescribe.containskey(SourceObjectName)) // optiChange
                {
                    map<String, Schema.SObjectField> LFieldMap = new map<String, Schema.SObjectField>();
                    //LFieldMap = Allobj.get(SourceObjectName).getDescribe().fields.getMap(); //#optiChange
                    LFieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(SourceObjectName); //#optiChange
                    if(LFieldMap != NULL && !LFieldMap.isEmpty()) //#optiChange
                    {
                        for(String s : LFieldMap.keyset())
                        {
                            SourceFieldMap.put(LFieldMap.get(s).getDescribe().getName(),LFieldMap.get(s));
                        }
                    }
                    AllFieldDescribe.put(SourceObjectName,SourceFieldMap);
                }
                /*
                else if(Allobj.containskey(SourceObjectName) && AllFieldDescribe.containskey(SourceObjectName)) // #optiChange
                {
                    SourceFieldMap = AllFieldDescribe.get(SourceObjectName);
                }
                */
                else if(COMM_Utils_DescribeCall.getObjectFieldDetails(SourceObjectName) != NULL && AllFieldDescribe.containskey(SourceObjectName))
                {
                    SourceFieldMap = AllFieldDescribe.get(SourceObjectName); // #optiChange and #optiChances AllFieldDescribe
                }
                
                list<Sobject> SobjList = new list<Sobject>(); 
                //SobjList = BuildSobject.getSFM_BuildSobject(SourceUpdateRecId,SourceObjectName,null,null);
                String strQuery = 'Select '+strFields+' From '+SourceObjectName+' where Id =: SourceUpdateRecId';
                system.debug('strQuery'+strQuery);
                SobjList = database.query(strQuery); 
                system.debug('SobjList'+SobjList);  
                if(SobjList.size() > 0)
                    SourceUpdateRec = SobjList[0];
                system.debug('SourceUpdateRec'+SourceUpdateRec);    
            }
            //Added for the story BAC-3675 to query Question bank records wich are configured in the Source Object Update
            if(setQuestionIds.size() > 0){
                
                lstQuestionRecords = [SELECT Id, SVMXC__QuestionID__c, SVMXC__Response_Type__c FROM SVMXC__Question_Bank__c WHERE Id IN: setQuestionIds]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
        }
        try
        {
            //Added for the story BAC-3675 to send list of question record for checklist SFM which has question configured for source object update, otherwise call old method for other type of SFMs
            if(lstQuestionRecords.size() > 0){
                DoHeaderSourceObjectUpdate(new CreateSourceUpdateRequest(TargetSobject, SourceUpdateRec, SourceUpdatesFields, SourceFieldMap, lstQuestionRecords));
            }
            else{
                DoHeaderSourceObjectUpdate(new CreateSourceUpdateRequest(TargetSobject, SourceUpdateRec, SourceUpdatesFields, SourceFieldMap));
            }
        }
        catch(exception ex)
        {
            system.debug(LoggingLevel.Warn, 'Exception: ' + ex.getMessage());
            system.debug(LoggingLevel.Warn, 'Stack: ' + ex.getStackTraceString());
            SFMResponse.success = false;
            SFMResponse.message = '';
            SVMXC.SFM_WrapperDef.SVMXMessage SVMXmessage = new SVMXC.SFM_WrapperDef.SVMXMessage();
            SVMXmessage = MessageUtils.buildExceptionMessage(ex,NULL,'Process: '+ProcessNodeObject.SVMXC__Process__r.SVMXC__ProcessID__c);
            system.debug('SVMXmessage'+SVMXmessage);
            SFMResponse.message += SVMXmessage.message;
            SFMResponse.msgDetails = SVMXmessage;
        }
        return SFMResponse;
    }
    
    //Method to perform header source update. This method has core implementation.
    public SVMXC.SFM_WrapperDef.SFM_Response DoHeaderTargetObjectUpdate(String SFMProcId, String TargetUpdateRecId)
    {
        SVMXC.SFM_WrapperDef.SFM_Response SFMResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        SFMResponse.success = true;
        Sobject TargetObj;
        String strSOQLFields = '';
        Map<String, Schema.SObjectType> AllObjDescribe = new Map<String, Schema.SObjectType>();
        Map<String, Schema.SObjectField> AllFieldDescribe = new Map<String, Schema.SObjectField>();
        
        for(Schema.SObjectType s : Schema.getGlobalDescribe().values())
        {
            Schema.DescribeSObjectResult objDesc = s.getDescribe();
            AllObjDescribe.put(objDesc.getName(), s);
        }
        
        List<SVMXC__ServiceMax_Config_Data__c> lstTargetUpdateRecs = new List<SVMXC__ServiceMax_Config_Data__c> ();
        // BAC- 3977 Added SVMXC__SM_Question__c field in query. 
        
        lstTargetUpdateRecs = [Select SVMXC__Action__c, SVMXC__Target_Field_Name__c, SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Display_Value__c, SVMXC__SM_Question__c From SVMXC__ServiceMax_Config_Data__c Where SVMXC__Dispatch_Process__r.SVMXC__ProcessId__c =: SFMProcId AND SVMXC__Dispatch_Process__c != NULL AND RecordType.Name = 'Field Mapping' AND SVMXC__Source_Field_Name__c != NULL AND SVMXC__Configuration_Type__c = 'Source Update']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(lstTargetUpdateRecs != NULL && lstTargetUpdateRecs.size() > 0)
        {
            String strTargetObjectName = lstTargetUpdateRecs[0].SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c;
            for(SVMXC__ServiceMax_Config_Data__c TarUpdate : lstTargetUpdateRecs)
            {
                if(strSOQLFields != NULL && strSOQLFields.length() > 0)
                    strSOQLFields += ', ';
                strSOQLFields += TarUpdate.SVMXC__Source_Field_Name__c;
            }
            
            if(strTargetObjectName != NULL && strTargetObjectName.length() > 0 && TargetUpdateRecId != NULL && TargetUpdateRecId.length() > 0)
            {
                if(AllObjDescribe.containskey(strTargetObjectName) && AllObjDescribe.get(strTargetObjectName) != NULL)
                {
                    Map<String, Schema.SObjectField> FieldMap = AllObjDescribe.get(strTargetObjectName).getDescribe().fields.getMap();
                    if(FieldMap != NULL && FieldMap.size() > 0)
                    {
                        for(String s : FieldMap.keyset())
                            AllFieldDescribe.put(FieldMap.get(s).getDescribe().getName(), FieldMap.get(s));
                    }
                }
                
                String strSOQL = '';
                if(strSOQLFields != NULL && strSOQLFields.length() > 0)
                    strSOQL = 'Select ' + strSOQLFields + ' From ' + strTargetObjectName + ' Where Id =: TargetUpdateRecId';
                
                system.debug(LoggingLevel.Warn, 'Query Fields: ' + strSOQL);
                
                List<Sobject> SobjList = new List<Sobject>();
                if(strSOQL != NULL && strSOQL.length() > 0)
                    SobjList = Database.query(strSOQL); 
                
                if(SobjList != NULL && SobjList.size() > 0)
                    TargetObj = SobjList[0];
            }
        }
        
        try
        {   
            system.debug(LoggingLevel.Warn, 'Request Params 1: ' + TargetObj);
            system.debug(LoggingLevel.Warn, 'Request Params 2: ' + lstTargetUpdateRecs);
            system.debug(LoggingLevel.Warn, 'Request Params 3: ' + AllFieldDescribe);
            DoHeaderSourceObjectUpdate(new CreateSourceUpdateRequest(TargetObj, TargetObj, lstTargetUpdateRecs, AllFieldDescribe));
        }
        catch(exception ex)
        {
            SFMResponse.success = false;
            SFMResponse.message = ex.getMessage();
            system.debug(LoggingLevel.Warn, 'Exception: ' + ex.getMessage());
        }
        return SFMResponse;
    }
    
    //Method to perform header source update. This method has core implementation.
    public SVMXC.SFM_WrapperDef.SFM_Response DoHeaderSourceObjectUpdate(CreateSourceUpdateRequest reqSrcUpdate)
    {
        SVMXC.SFM_WrapperDef.SFM_Response SFMResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        SFMResponse.success = true;

        //----Start----Added for the story BAC-3675 for deserializing the answers JSON.
        Map<String, SVMXC__Question_Bank__c> mapRecIDVsQuesRec = new Map<String, SVMXC__Question_Bank__c>();
        Map<String, String> mapQueUniqueIdVsAnswer = new Map<String, String>();
        if(reqSrcUpdate != null && reqSrcUpdate.lstQuestionRecords != null && reqSrcUpdate.lstQuestionRecords.size() > 0){
            //Creating a map of Question Record Id and Question record
            for(SVMXC__Question_Bank__c obj: reqSrcUpdate.lstQuestionRecords){
                mapRecIDVsQuesRec.put(obj.id, obj);
            }

            //Deserializing the ansered checklist JSON and creating a map of questionID and answer
            if(reqSrcUpdate.TargetSobject != null && String.isNotBlank((String)reqSrcUpdate.TargetSobject.get('SVMXC__ChecklistJSON__c'))) {
                Map<String, Object> mapQueIdVsAnswersFromJSON =(Map<String, Object>)JSON.deserializeUntyped((String)reqSrcUpdate.TargetSobject.get('SVMXC__ChecklistJSON__c'));

                //Creating map of Question Id and Answer
                for(String strobj : mapQueIdVsAnswersFromJSON.keyset()){
                    Object objAns =  mapQueIdVsAnswersFromJSON.get(strobj);
                    //For single answer
                    if(objAns instanceof String){
                        mapQueUniqueIdVsAnswer.put(strobj, (String)objAns);
                    }
                    else if(objAns instanceof Long){
                        mapQueUniqueIdVsAnswer.put(strobj, (Long)objAns+'');
                    }
                    else if(objAns instanceof Double){
                        mapQueUniqueIdVsAnswer.put(strobj, (Double)objAns+'');
                    }
                }
                //Fixed defect 046599 
                for(String questionId : mapChecklistQuestionAnswer.keySet())
                {
                    if(mapQueUniqueIdVsAnswer.containsKey(questionId))
                    {
                        String translatedAnswer = mapQueUniqueIdVsAnswer.get(questionId);
                        Map<String,String> answers = mapChecklistQuestionAnswer.get(questionId);
                        if(answers.containsKey(translatedAnswer))
                        {
                            mapQueUniqueIdVsAnswer.put(questionId,answers.get(translatedAnswer));  
                        }
                    }
                }
            }
        }
        //----End----Added for the story BAC-3675 for deserializing the answers JSON.
        
        if(reqSrcUpdate != NULL && reqSrcUpdate.SourceUpdatesFields != NULL && reqSrcUpdate.SourceUpdatesFields.size() > 0 && reqSrcUpdate.SourceUpdateRec != NULL && reqSrcUpdate.TargetSobject != NULL && reqSrcUpdate.SourceFieldMap.size() > 0)
        {
            for(Integer i = 0; i<reqSrcUpdate.SourceUpdatesFields.size(); i++)
            {
                if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c != NULL )
                {
                    if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'SET' )
                    {
                        //Chanages for defect 040238 isCreateable() to isUpdateable() start
                        //Added one more condition SVMXC__SM_Question__c == null for the story BAC-3675
                        if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c != NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c == null)
                        {
                            System.debug('SourceFieldName: '+reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c+' - '+reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c);
                            Schema.DescribeFieldResult f = reqSrcUpdate.SourceFieldMap.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c).getDescribe();
                            
                            //Added update permission check here and removed from the every line of data type check for fixing defect BAC-3750
                            if(f.isUpdateable()){
                                if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency))
                                {
                                    if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c != NULL )
                                    {
                                        //BAC-5089 handle SVMX.SETNULL values
                                        if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c == 'SVMX.SETNULL'){
                                            reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, null);
                                        }
                                        else{
                                            reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(double.valueOf(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c)));
                                        }
                                    }   
                                }
                                else if(f.getType() == schema.Displaytype.Integer)//if field type is Integer 
                                {
                                    if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c!= NULL)
                                    {
                                        //BAC-5089 handle SVMX.SETNULL values
                                        if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c == 'SVMX.SETNULL'){
                                            reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, null);
                                        }
                                        else{
                                            reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Integer.valueof(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                        }
                                    }   
                                }
                                else if(f.getType() == schema.Displaytype.Boolean)//if field type is Boolean 
                                {
                                    if(Boolean.valueof(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c)!= NULL)
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Boolean.valueof(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                    }   
                                }
                                else if(f.getType() == schema.Displaytype.DateTime)//if field type is DateTime 
                                {
                                    if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                    {
                                        datetime dt = datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0));
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,dt);
                                    }   
                                    else if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                    {
                                        datetime dt = datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0));
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,dt);
                                    }       
                                    else if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                    {
                                        datetime dt = datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0));
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,dt);
                                    }
                                    else if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.now());
                                    }
                                    else if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'SVMX.SETNULL')
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, null);
                                    }
                                    else
                                    {
                                        system.debug(LoggingLevel.Warn, 'Date time:' + reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c + ', value: ' + datetime.valueof(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c)); 
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, datetime.valueof(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                    }
                                }
                                else if(f.getType() == schema.Displaytype.Date)//if field type is Date 
                                {
                                    if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, system.today());
                                    }   
                                    else if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, system.today() - 1);
                                    }       
                                    else if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, system.today() + 1);
                                    }
                                    else if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'SVMX.SETNULL')
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, null);
                                    }
                                    else
                                    {
                                        system.debug(LoggingLevel.Warn, 'Date :' + reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c + ', value: ' + date.valueof(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c)); 
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, date.valueof(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                    }
                                }
                                else if(f.getType() == schema.Displaytype.MultiPicklist)//if field type is MultiPicklist 
                                {
                                    if(String.valueof(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c) != NULL)
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,String.valueof(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                    }
                                }
                                else //else field type is REFERENCE, String
                                {
                                    if((String)reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c != NULL) 
                                    {
                                        //BAC-5089 handle SVMX.SETNULL values
                                        system.debug(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                        if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c == 'SVMX.SETNULL'){
                                            system.debug('Entered SVMX.SETNULL');
                                            reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, null);
                                        }
                                        else{
                                            reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(String)reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                        }
                                    }
                                }
                            }
                        }    
                        //Chnages for defect 040238 isCreateable() to isUpdateable() end
                        
                        //if Target field API Name is not NULL and value is NULL.
                        //Added one more condition SVMXC__SM_Question__c == null for the story BAC-3675
                        if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c == NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c == null)
                        {
                            System.debug('SourceFieldName: '+reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c);
                            
                            //Desctibe the field to check differen attributes of fields..
                            Schema.DescribeFieldResult f = reqSrcUpdate.SourceFieldMap.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c).getDescribe();
                            
                            //Added update permission check here and removed from the every line of data type check for fixing defect BAC-3750
                            if(f.isUpdateable()){
                                if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency))//if Field Type is Double,persent,currency 
                                {
                                    if(double.valueOf(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != NULL )
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(double.valueOf(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))));
                                    }
                                }
                                else if(f.getType() == schema.Displaytype.Integer)//if field type is Integer
                                {
                                    if(Integer.valueof(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))!= NULL)
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Integer.valueof(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                    } 
                                }
                                else if(f.getType() == schema.Displaytype.Boolean)//if field type is Boolean
                                {
                                    if(reqSrcUpdate.SourceUpdatesFields[i] != null && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != null &&  reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != null && Boolean.valueof(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))!= NULL)
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Boolean.valueof(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                    }
                                }
                                else if(f.getType() == schema.Displaytype.DateTime)//if field type is DateTime
                                {
                                    if(DateTime.valueOf(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != NULL)
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,DateTime.valueOf(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                    }
                                }
                                else if(f.getType() == schema.Displaytype.Date)//if field type is Date
                                {
                                    //Removed "Date.valueOf()" function for fixing defect BAC-3813
                                    //if(Date.valueOf(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != NULL)
                                    if(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != NULL)
                                    {
                                        //This line is added for fixing defect BAC-3813. First store the value for the field and then convert it.
                                        String strDateValue = String.valueOf(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Date.valueOf(strDateValue));
                                        //reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Date.valueOf(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                    }
                                }
                                else if(f.getType() == schema.Displaytype.MultiPicklist)//if field type is MultiPicklist
                                {
                                    if(String.valueof(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != NULL)
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,String.valueof(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                    }
                                }
                                else //else field type is REFERENCE,String 
                                {
                                    if((String)reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != NULL)
                                    {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(String)reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                    }
                                }
                            }
                        }

                        //----Start------Added for the story BAC-3675 for doing Source object update for configured question in checklist SFM
                        if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c == null && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c != null && reqSrcUpdate.lstQuestionRecords != null && reqSrcUpdate.lstQuestionRecords.size() > 0){

                            //Describe the field to check different attributes of fields
                            Schema.DescribeFieldResult dFR = reqSrcUpdate.SourceFieldMap.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c).getDescribe();

                            if(dFR.isUpdateable()){
                                String strAnswerType = '';
                                String strInternalQueId = '';
                                if(mapRecIDVsQuesRec.containskey(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c)){
                                    SVMXC__Question_Bank__c objQue = mapRecIDVsQuesRec.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c);
                                    strAnswerType = objQue.SVMXC__Response_Type__c;
                                    strInternalQueId = objQue.SVMXC__QuestionID__c;
                                }

                                if(String.isNotBlank(strInternalQueId) && mapQueUniqueIdVsAnswer.containsKey(strInternalQueId) && String.isNotBlank(mapQueUniqueIdVsAnswer.get(strInternalQueId))){

                                    //if field Type is Double,percent,currency
                                    if((dFR.getType() == Schema.DisplayType.Double  || dFR.getType() == Schema.DisplayType.Percent || dFR.getType() == Schema.DisplayType.Currency) && strAnswerType.equalsIgnoreCase('Number')){
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, double.valueOf(mapQueUniqueIdVsAnswer.get(strInternalQueId)));
                                    }
                                    //if field Type is Integer
                                    else if(dFR.getType() == Schema.DisplayType.Integer && strAnswerType.equalsIgnoreCase('Number')){
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, Integer.valueOf(mapQueUniqueIdVsAnswer.get(strInternalQueId)));
                                    }
                                    //if field Type is Picklist
                                    else if(dFR.getType() == Schema.DisplayType.Picklist && (strAnswerType.equalsIgnoreCase('Picklist')|| strAnswerType.equalsIgnoreCase('Radio Button'))) {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, String.valueOf(mapQueUniqueIdVsAnswer.get(strInternalQueId)));
                                    }
                                    //if field Type is Date
                                    else if(dFR.getType() == Schema.DisplayType.Date && strAnswerType.equalsIgnoreCase('Date')){
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, Date.valueOf(mapQueUniqueIdVsAnswer.get(strInternalQueId)));
                                    }
                                    //if field Type is DateTime
                                    else if(dFR.getType() == Schema.DisplayType.DateTime && strAnswerType.equalsIgnoreCase('DateTime')){
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, DateTime.valueOfGmt(mapQueUniqueIdVsAnswer.get(strInternalQueId)));
                                    }
                                    //if field Type is Email, URL
                                    else if((dFR.getType() == Schema.DisplayType.Email || dFR.getType() == Schema.DisplayType.URL) && strAnswerType.equalsIgnoreCase('Text')){
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, String.valueOf(mapQueUniqueIdVsAnswer.get(strInternalQueId)));
                                    }
                                    //if field Type is String, TextArea
                                    else if((dFR.getType() == Schema.DisplayType.String || dFR.getType() == Schema.DisplayType.TextArea) && (strAnswerType.equalsIgnoreCase('Text') || strAnswerType.equalsIgnoreCase('Picklist') || strAnswerType.equalsIgnoreCase('Radio Button'))) {
                                        reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, String.valueOf(mapQueUniqueIdVsAnswer.get(strInternalQueId)));
                                    }
                                }
                            }
                        }
                        //----End------Added for the story BAC-3675 for doing Source object update for configured question in checklist SFM
                    }
                    
                    //Check for Increase Operator
                    if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'INCREASE' )
                    {
                        //Describe the field to check different attributes of fields
                        Schema.DescribeFieldResult dFR = reqSrcUpdate.SourceFieldMap.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c).getDescribe();

                        //Added condition field is updatable or not as part of story BAC-3675
                        if(dFR.isUpdateable()) {
                            //if Source field is not NULL and value is NULL..
                            //Added one more condition SVMXC__SM_Question__c == null as part of this story BAC-3675
                            if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c == NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c == null)
                            {
                                Double SourceRec = (Double)(reqSrcUpdate.SourceUpdateRec.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                Double TargetRec = (Double)(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                Double val = 0;
                                
                                if(SourceRec != NULL && TargetRec != NULL)
                                    val = SourceRec + TargetRec;
                                else if(TargetRec == NULL && SourceRec != NULL)
                                    val = SourceRec;
                                else if(SourceRec == NULL && TargetRec != NULL)
                                    val = TargetRec;
                                reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                            }
                            
                            //Added one more condition SVMXC__SM_Question__c == null as part of this story BAC-3675
                            if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c != NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c == null)
                            {   
                                Double SourceRec = (Double)(reqSrcUpdate.SourceUpdateRec.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                Double DisplayValue = Double.valueof(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                Double val = 0;
                                if(SourceRec != NULL && DisplayValue != NULL)
                                    val = SourceRec + DisplayValue;
                                else if(SourceRec == NULL && DisplayValue != NULL)
                                    val = DisplayValue;
                                
                                reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                            }

                            //-------Start--------Added for the story BAC-3675 for source object update 
                            if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c == null && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c != null) {

                                String strAnswerType = '';
                                String strInternalQueId = '';
                                if(mapRecIDVsQuesRec.containskey(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c)){
                                    SVMXC__Question_Bank__c objQue = mapRecIDVsQuesRec.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c);
                                    strAnswerType = objQue.SVMXC__Response_Type__c;
                                    strInternalQueId = objQue.SVMXC__QuestionID__c;
                                }

                                if(String.isNotBlank(strInternalQueId) && mapQueUniqueIdVsAnswer.containsKey(strInternalQueId) && String.isNotBlank(mapQueUniqueIdVsAnswer.get(strInternalQueId)) && strAnswerType.equalsIgnoreCase('Number')) {
                                    
                                    Double sourceRec = (Double)(reqSrcUpdate.SourceUpdateRec.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                    Double displayValue = Double.valueof(mapQueUniqueIdVsAnswer.get(strInternalQueId));
                                    Double val = 0;
                                    if(sourceRec != null && displayValue != null)
                                        val = sourceRec + displayValue;
                                    else if(sourceRec == null && displayValue != null)
                                        val = displayValue;
                                    reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, val);
                                }
                            }
                            //-------End--------Added for the story BAC-3675 for source object update 
                        }
                    }
                    
                    //Check for Decrease Operator
                    if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'DECREASE' )
                    {
                        //Describe the field to check different attributes of fields
                        Schema.DescribeFieldResult dFR = reqSrcUpdate.SourceFieldMap.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c).getDescribe();

                        //Added condition field is updatable or not as part of story BAC-3675
                        if(dFR.isUpdateable()) {
                            //if Source field is not NULL and value is NULL..
                            //Added one more condition SVMXC__SM_Question__c == null as part of this story BAC-3675
                            if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c == NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c == null)
                            {   
                                Double SourceRec = (Double)(reqSrcUpdate.SourceUpdateRec.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                Double TargetRec = (Double)(reqSrcUpdate.TargetSobject.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                Double val = 0;
                                if(SourceRec != NULL && TargetRec !=NULL)
                                    val = SourceRec - TargetRec;
                                else if(SourceRec == NULL && TargetRec != NULL)
                                    val = val - TargetRec;
                                reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                            }
                            
                            //if Source field is NULL and value is not NULL..
                            //Added one more condition SVMXC__SM_Question__c == null as part of this story BAC-3675
                            if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c != NULL && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c == null)
                            {
                                Double SourceRec = (Double)(reqSrcUpdate.SourceUpdateRec.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                Double DisplayValue = Double.valueof(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                Double val = 0;
                                if(SourceRec != NULL && DisplayValue != NULL)
                                    val = SourceRec - DisplayValue;
                                else if(SourceRec == NULL && DisplayValue != NULL)
                                    val = val - DisplayValue;
                                reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                            }

                            //-------Start--------Added for the story BAC-3675 for source object update 
                            if(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Display_Value__c == null && reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c != null) {

                                String strAnswerType = '';
                                String strInternalQueId = '';
                                if(mapRecIDVsQuesRec.containskey(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c)){
                                    SVMXC__Question_Bank__c objQue = mapRecIDVsQuesRec.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__SM_Question__c);
                                    strAnswerType = objQue.SVMXC__Response_Type__c;
                                    strInternalQueId = objQue.SVMXC__QuestionID__c;
                                }

                                if(String.isNotBlank(strInternalQueId) && mapQueUniqueIdVsAnswer.containsKey(strInternalQueId) && String.isNotBlank(mapQueUniqueIdVsAnswer.get(strInternalQueId)) && strAnswerType.equalsIgnoreCase('Number')) {
                                    
                                    Double sourceRec = (Double)(reqSrcUpdate.SourceUpdateRec.get(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                    Double displayValue = Double.valueof(mapQueUniqueIdVsAnswer.get(strInternalQueId));
                                    Double val = 0;
                                    if(sourceRec != null && displayValue != null)
                                        val = sourceRec - displayValue;
                                    else if(sourceRec == null && displayValue != null)
                                        val = val - displayValue;
                                    reqSrcUpdate.SourceUpdateRec.put(reqSrcUpdate.SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, val);
                                }
                            }
                            //-------End--------Added for the story BAC-3675 for source object update 
                        }
                    }
                }
            }
            system.debug(LoggingLevel.Warn, 'Rec after Update: ' + reqSrcUpdate.SourceUpdateRec);
            update reqSrcUpdate.SourceUpdateRec;
        }
        return SFMResponse;
    }
    
    public SVMXC.SFM_WrapperDef.SFM_Response DoDetailsSourceObjectUpdate(String SFMId,map<String,Sobject> SourceRecIdTargetObjMap,String ObjName,String AliasName,map<String,map<String,Schema.SObjectField>> AllFieldDescribe)
    {
        SVMXC.SFM_WrapperDef.SFM_Response SFMResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        SFMResponse.success = true;
        Set<String> SourceUpdateRecIds = new Set<String>();
        if(SourceRecIdTargetObjMap.size() > 0)
        {
            for(String s: SourceRecIdTargetObjMap.keyset())
            {
                SourceUpdateRecIds.add(s);
            }
        }
        map<String,Sobject> SourceRecIdSourceObjMap = new map<String,Sobject>();
        list<Sobject> SobjList = new list<Sobject>();
        system.debug('Entered for Sourceupdate');
        system.debug('SFMId'+SFMId);
        system.debug('SourceUpdateRecIds'+SourceUpdateRecIds);
        system.debug('ObjName'+ObjName);
        system.debug('AliasName'+AliasName);
        system.debug('AllFieldDescribe'+AllFieldDescribe);
        map<String,Schema.SObjectField> LocalFieldMap = new Map<String,Schema.SObjectField>();
        map<String, Schema.SObjectField> SourceFieldMap = new map<String, Schema.SObjectField>();
        SVMXC__ServiceMax_Processes__c ProcessNodeObject = new  SVMXC__ServiceMax_Processes__c();
        list<SVMXC__ServiceMax_Config_Data__c> SourceUpdatesFields = new list<SVMXC__ServiceMax_Config_Data__c>();
        String SourceObjectName = '';
        String TargetObjectName = '';
        if(AllFieldDescribe.containskey(ObjName))
            LocalFieldMap = AllFieldDescribe.get(ObjName);
        //Start Processing for the Header source update.
        //first get the process node object from the sfm process 
       // if(SFMId != null && PNodeObjRTypeID != null && PNodeObjRTypeID.length() > 0) //#optiChange
        if(SFMId != null)
        {
            
            if(ObjName != null && AliasName == null)
                
                ProcessNodeObject = [select id,SVMXC__Process__r.SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where RecordType.DeveloperName = 'Process_Node_Objects' and SVMXC__Process__c =: SFMId and SVMXC__Source_Object_Name__c =: ObjName and SVMXC__Type__c = 'TARGET']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(ObjName != null && AliasName != null)
                
                ProcessNodeObject = [select id,SVMXC__Process__r.SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where RecordType.DeveloperName = 'Process_Node_Objects' and SVMXC__Process__c =: SFMId and SVMXC__Page_Layout__c =: AliasName and SVMXC__Type__c = 'TARGETCHILD'];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('ProcessNodeObject'+ProcessNodeObject);
        }   
        //second Query the Source update defination & Source update Data from sfmid for the header object...
        if(ProcessNodeObject != null && ProcessNodeObject.id != null)
            
            SourceUpdatesFields = [Select id,Name,SVMXC__Source_Field_Name__c,SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c,SVMXC__Setting_ID__r.SVMXC__Node_Source_Object_API__c,SVMXC__Target_Field_Name__c,SVMXC__Action__c,SVMXC__Display_Value__c,SVMXC__Display_Type__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_ID__c =: ProcessNodeObject.id and RecordType.DeveloperName = 'Field_Mapping' and SVMXC__Configuration_Type__c = 'Source Update']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('SourceUpdatesFields'+SourceUpdatesFields);
        if(SourceUpdatesFields.size() > 0)
        {
            String strFields = '';
            for(Integer i = 0;i<SourceUpdatesFields.size();i++){
                if(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c != null){
                    if(strFields != '' && strFields.length() > 0)
                        strFields += ','+SourceUpdatesFields[i].SVMXC__Source_Field_Name__c;
                    else
                        strFields += SourceUpdatesFields[i].SVMXC__Source_Field_Name__c;
                }           
            }
            SourceObjectName = SourceUpdatesFields[0].SVMXC__Setting_ID__r.SVMXC__Node_Source_Object_API__c;
            TargetObjectName = SourceUpdatesFields[0].SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c;
            system.debug('SourceObjectName'+SourceObjectName);
            system.debug('TargetObjectName'+TargetObjectName);
            if(String.isNotBlank(SourceObjectName) && SourceUpdateRecIds != NULL && !SourceUpdateRecIds.isEmpty()) // #optiChange
            {
                //if(Allobj.containskey(SourceObjectName) && AllFieldDescribe.containskey(SourceObjectName) == false) #optiChange
                if(!AllFieldDescribe.containskey(SourceObjectName)) //#optiChange
                {
                    map<String, Schema.SObjectField> LFieldMap = new map<String, Schema.SObjectField>();
                    map<String, Schema.SObjectField> LSourceFieldMap = new map<String, Schema.SObjectField>();
                   // LFieldMap = Allobj.get(SourceObjectName).getDescribe().fields.getMap(); //#optiChange
                    LFieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(SourceObjectName);//#optiChange
                    if(LFieldMap != NULL && !LFieldMap.isEmpty())
                    {
                        for(String s : LFieldMap.keyset())
                        {
                            LSourceFieldMap.put(LFieldMap.get(s).getDescribe().getName(),LFieldMap.get(s));
                        }
                    }
                    AllFieldDescribe.put(SourceObjectName,LSourceFieldMap);
                    LSourceFieldMap = AllFieldDescribe.get(SourceObjectName);
                    //SobjList = BuildSobject.getSFM_BuildSobject2(SourceUpdateRecIds,SourceObjectName,null,AllFieldDescribe);
                }
                /*else if(Allobj.containskey(SourceObjectName) && AllFieldDescribe.containskey(SourceObjectName))
                {
                    SobjList = BuildSobject.getSFM_BuildSobject2(SourceUpdateRecIds,SourceObjectName,null,AllFieldDescribe);
                }*/
                String strQuery = 'Select '+strFields+' From '+SourceObjectName+' where Id IN : SourceUpdateRecIds';
                system.debug('strQuery'+strQuery);
                SobjList = database.query(strQuery);
                SourceFieldMap = AllFieldDescribe.get(SourceObjectName);
                system.debug('SobjList'+SobjList);  
                system.debug('SourceFieldMap'+SourceFieldMap); 
            }   
        }
        if(SobjList.size() > 0 && SourceRecIdTargetObjMap.size() > 0)
        {
            for(Integer i = 0;i<SobjList.size();i++)
            {
                if(SobjList[i].get('Id') != null && SourceRecIdTargetObjMap.containskey(String.valueof(SobjList[i].get('Id')))) 
                    SourceRecIdSourceObjMap.put(String.valueof(SobjList[i].get('Id')),SobjList[i]);
            }
        }
        system.debug('SourceRecIdSourceObjMap'+SourceRecIdSourceObjMap);  
        list<Sobject> UpdateRecords = new list<Sobject> ();
        if(SourceUpdatesFields.size() > 0 && SourceRecIdSourceObjMap.size() > 0 && SourceRecIdTargetObjMap.size() > 0 && LocalFieldMap.size() > 0)
        {
            
            for(String s: SourceRecIdTargetObjMap.keyset())
            {
            
                Sobject SourceUpdateRec;
                Sobject TargetSobject = SourceRecIdTargetObjMap.get(s); 
                if(SourceRecIdSourceObjMap.containskey(s))
                    SourceUpdateRec = SourceRecIdSourceObjMap.get(s);
                system.debug('SourceTarget'+SourceUpdateRec+TargetSobject); 
                if(SourceUpdateRec != null && TargetSobject != null)    
                {
                    for(Integer i = 0;i<SourceUpdatesFields.size();i++)
                    {
                        if(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c != null && SourceFieldMap.containskey(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c))
                        {
                            //Check for Set
                            if(SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'SET' )//EQ
                            {
                                system.debug('Entered for set');  
                                //if Target field API Name is null and value is not null..
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && SourceUpdatesFields[i].SVMXC__Display_Value__c != null)
                                {
                                   //Desctibe the field to check differen attributes of fields..
                                    Schema.DescribeFieldResult f = SourceFieldMap.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c).getDescribe();
                                    if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                                    {
                                        if(SourceUpdatesFields[i].SVMXC__Display_Value__c != null )
                                        {
                                            //BAC-5089 handle SVMX.SETNULL values
                                            if(SourceUpdatesFields[i].SVMXC__Display_Value__c == 'SVMX.SETNULL'){
                                                SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, null);
                                            }
                                            else{
                                                SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(double.valueOf(SourceUpdatesFields[i].SVMXC__Display_Value__c)));
                                            }
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Integer && f.isCreateable())//if field type is Integer
                                    {
                                        if(SourceUpdatesFields[i].SVMXC__Display_Value__c != null)
                                        {
                                            //BAC-5089 handle SVMX.SETNULL values
                                            if(SourceUpdatesFields[i].SVMXC__Display_Value__c == 'SVMX.SETNULL'){
                                                SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, null);
                                            }
                                            else{
                                                SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Integer.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                            }
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Boolean && f.isCreateable())//if field type is Boolean
                                    {
                                        if(Boolean.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c)!= null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Boolean.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.DateTime && f.isCreateable())//if field type is DateTime
                                    {
                                        system.debug('displayval'+SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                        if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                        {
                                            datetime dt = datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0));
                                            system.debug('Enterd for Today'+dt);
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,dt);
                                        }   
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                        {
                                            datetime dt = datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0));
                                            system.debug('Enterd for YESTERDAY'+dt);
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,dt);
                                        }       
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                        {
                                            datetime dt = datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0));
                                            system.debug('Enterd for TOMORROW'+dt);
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,dt);
                                        }
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                        {
                                            system.debug('Enterd for NOW');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.now());
                                        }
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'SVMX.SETNULL')//BAC-5089 handle SVMX.SETNULL values
                                        {
                                            system.debug('Enterd for SVMX.SETNULL');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, null);
                                        }
                                        else
                                        {           
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,DateTime.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                        }
                                                
                                    }
                                    else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                                    {
                                        system.debug('displayval'+SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                        if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                        {
                                            system.debug('Enterd for Today');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today());
                                        }   
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                        {
                                            system.debug('Enterd for YESTERDAY');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today() - 1);
                                        }       
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                        {
                                            system.debug('Enterd for TOMORROW');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today() + 1);
                                        }
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'SVMX.SETNULL')//BAC-5089 handle SVMX.SETNULL values
                                        {
                                            system.debug('Enterd for SVMX.SETNULL');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, null);
                                        }
                                        else
                                        {           
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Date.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                        }
                                    }
                                    else if(f.getType() == schema.Displaytype.MultiPicklist && f.isCreateable())//if field type is MultiPicklist
                                    {
                                        if(String.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c) != null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,String.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                        }
                                    }
                                    else //else field type is REFERENCE,String 
                                    {
                                        if((String)SourceUpdatesFields[i].SVMXC__Display_Value__c != null && f.isCreateable())
                                        {
                                            //BAC-5089 handle SVMX.SETNULL values
                                            if(SourceUpdatesFields[i].SVMXC__Display_Value__c == 'SVMX.SETNULL'){
                                                SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c, null);
                                            }
                                            else{
                                                SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(String)SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                            }
                                        }
                                    }
                                }    
                                //if Target field API Name is not null and value is null..   
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != null && SourceUpdatesFields[i].SVMXC__Display_Value__c == null)
                                {
                                    system.debug('targerfldname'+SourceUpdatesFields[i].SVMXC__Target_Field_Name__c);
                                    system.debug('diaplayval'+SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                    //Desctibe the field to check differen attributes of fields..
                                    Schema.DescribeFieldResult f = SourceFieldMap.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c).getDescribe();
                                    if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isUpdateable())//if Field Type is Double,persent,currency 
                                    {
                                        if(double.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null )
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(double.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Integer && f.isUpdateable())//if field type is Integer
                                    {
                                        if(Integer.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))!= null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Integer.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Boolean && f.isUpdateable())//if field type is Boolean
                                    {
                                        if(Boolean.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))!= null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Boolean.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.DateTime && f.isUpdateable())//if field type is DateTime
                                    {
                                        system.debug('targetfldname'+TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                        if(DateTime.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,DateTime.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Date && f.isUpdateable())//if field type is Date
                                    {
                                        system.debug('asdf'+TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                        if(Date.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Date.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                        }
                                    }
                                    else if(f.getType() == schema.Displaytype.MultiPicklist && f.isUpdateable())//if field type is MultiPicklist
                                    {
                                        if(String.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,String.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                        }
                                    }
                                    else //else field type is REFERENCE,String 
                                    {
                                        if((String)TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != null && f.isUpdateable())
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(String)TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                        }
                                    }
                                }
                            }//set over
                            //Check for Increase
                            if(SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'INCREASE' )
                            {
                                system.debug('Enter in Increase');
                                //if Source field is not null and value is null..
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != null && SourceUpdatesFields[i].SVMXC__Display_Value__c == null)
                                {   
                                    //if(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != null && SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null)
                                   //{
                                        Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                        Double TargetRec = (Double)(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                        system.debug('SourceRec'+SourceRec);
                                        system.debug('TargetRec'+TargetRec);
                                        Double val = 0;
                                        //if both are not null add them
                                        if(SourceRec != null && TargetRec != null)
                                        {
                                            val = SourceRec + TargetRec;
                                        }   
                                        //if target is null then consider target as zero and add the source as it is    
                                        else if(TargetRec == null && SourceRec != null)
                                        {
                                            val = SourceRec;
                                        }
                                        else if(SourceRec == null && TargetRec != null)
                                        {
                                            val = TargetRec;
                                        }
                                        system.debug('val'+val);
                                        SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                                   // }
                                }
                                //if Source field is null and value is not null..
                                system.debug('targetfldname'+SourceUpdatesFields[i].SVMXC__Target_Field_Name__c);
                                system.debug('diaplayval'+SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                system.debug('sourcefldname'+SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && SourceUpdatesFields[i].SVMXC__Display_Value__c != null )//&& SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null
                                {   
                                    Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                    Double DisplayValue = Double.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                    system.debug('SourceRec'+SourceRec);
                                    system.debug('DisplayValue'+DisplayValue);
                                    Double val = 0;
                                    //if both are not null
                                    if(SourceRec != null && DisplayValue != null)
                                    { 
                                        val = SourceRec + DisplayValue;
                                    }
                                    else if(SourceRec == null && DisplayValue != null)
                                    {
                                        val = DisplayValue;
                                    }   
                                    system.debug('val'+val);
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                                }       
                            }//increase over
                            //Check for Decrease
                            if(SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'DECREASE' )
                            {
                                system.debug('Enter in decrease');
                                //if Source field is not null and value is null..
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != null && SourceUpdatesFields[i].SVMXC__Display_Value__c == null)
                                {   
                                    //if(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != null && SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null)
                                    //{
                                        Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                        Double TargetRec = (Double)(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                        system.debug('SourceRec'+SourceRec);
                                        system.debug('TargetRec'+TargetRec);
                                        Double val = 0;
                                        if(SourceRec != null && TargetRec !=null)
                                        { 
                                            val = SourceRec - TargetRec;
                                        }
                                        else if(SourceRec == null && TargetRec != null)
                                        {
                                            val = val-TargetRec;
                                        }
                                        system.debug('indra'+val);
                                        SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                                    //}
                                }
                                //if Source field is null and value is not null..
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && SourceUpdatesFields[i].SVMXC__Display_Value__c != null )//&& SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null
                                {   
                                    Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                    Double DisplayValue = Double.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                    system.debug('SourceRec'+SourceRec);
                                    system.debug('DisplayValue'+DisplayValue);
                                    Double val = 0;
                                    if(SourceRec != null && DisplayValue != null)
                                    {   
                                        val = SourceRec - DisplayValue;
                                    }
                                    else if(SourceRec == null && DisplayValue != null)
                                    {
                                        val = val-DisplayValue;
                                    }
                                    system.debug('val'+val);
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                                }   
                            }//decrease over
                        }       
                    }
                }    
                system.debug('SourceUpdateRec'+SourceUpdateRec);
                UpdateRecords.add(SourceUpdateRec);
            }
            system.debug('UpdateRecords'+UpdateRecords);
            try{
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                update UpdateRecords;
            }
            catch(Exception ex)
            {
                SFMResponse.success = false;
                SFMResponse.message = '';
                SVMXC.SFM_WrapperDef.SVMXMessage SVMXmessage = new SVMXC.SFM_WrapperDef.SVMXMessage();
                SVMXmessage = MessageUtils.buildExceptionMessage(ex,null,'Process: '+ProcessNodeObject.SVMXC__Process__r.SVMXC__ProcessID__c);
                system.debug('SVMXmessage'+SVMXmessage);
                SFMResponse.message += SVMXmessage.message;
                SFMResponse.msgDetails = SVMXmessage;
            } 
        }
        return SFMResponse;
    }
    static Object deserializeRequestTo(String requestStr, System.Type apexType){
        
        if(requestStr != null && requestStr != ''){
            return JSON.deserialize(requestStr, apexType);
        }
        return null;
    }   
    
    public class CreateSourceUpdateRequest{
        public Sobject TargetSobject;
        public Sobject SourceUpdateRec;
        public List<SVMXC__ServiceMax_Config_Data__c> SourceUpdatesFields = new List<SVMXC__ServiceMax_Config_Data__c>();
        public Map<String,Schema.SObjectField> SourceFieldMap = new Map<String,Schema.SObjectField>();
        //Added for the story BAC-3675 for sending configured list of question for source object update
        public List<SVMXC__Question_Bank__c> lstQuestionRecords = new List<SVMXC__Question_Bank__c>();
        
        public CreateSourceUpdateRequest(Sobject TargetSobject, Sobject SourceUpdateRec, List<SVMXC__ServiceMax_Config_Data__c> SourceUpdatesFields, Map<String,Schema.SObjectField> SourceFieldMap){
            this.TargetSobject = TargetSobject;
            this.SourceUpdateRec = SourceUpdateRec;
            this.SourceUpdatesFields = SourceUpdatesFields;
            this.SourceFieldMap = SourceFieldMap;
        }
        //Added for the story BAC-3675 for sending configured list of question for source object update
        public CreateSourceUpdateRequest(Sobject TargetSobject, Sobject SourceUpdateRec, List<SVMXC__ServiceMax_Config_Data__c> SourceUpdatesFields, Map<String,Schema.SObjectField> SourceFieldMap, List<SVMXC__Question_Bank__c> lstQuestionRecords){
            this.TargetSobject = TargetSobject;
            this.SourceUpdateRec = SourceUpdateRec;
            this.SourceUpdatesFields = SourceUpdatesFields;
            this.SourceFieldMap = SourceFieldMap;
            this.lstQuestionRecords = lstQuestionRecords;
        }
    }
    
     /*** Code to perform source update for details ***/
    public class DetailSourceUpdateWrap{
        public String processId;
        public Map<String,Sobject> sourceRecIdTargetObjMap = new Map<String,Sobject>();
        public Map<String,list<Sobject>> sourceRecIdlstTargetObjMap = new Map<String,list<Sobject>>();
        public String objectName;
        public String aliasName;
        public Map<String,map<String,Schema.SObjectField>> allFieldDescribe = new Map<String,map<String,Schema.SObjectField>>();
        
        public DetailSourceUpdateWrap(String processId, Map<String,Sobject> sourceRecIdTargetObjMap, 
        String objectName, String aliasName, Map<String,map<String,Schema.SObjectField>> allFieldDescribe){
            this.processId = processId;
            this.sourceRecIdTargetObjMap = sourceRecIdTargetObjMap;
            this.objectName = objectName;
            this.aliasName = aliasName;
            this.allFieldDescribe = allFieldDescribe;
        }
        public DetailSourceUpdateWrap(String processId, Map<String,Sobject> sourceRecIdTargetObjMap, Map<String,list<Sobject>> sourceRecIdlstTargetObjMap,
        String objectName, String aliasName, Map<String,map<String,Schema.SObjectField>> allFieldDescribe){
            this.processId = processId;
            this.sourceRecIdTargetObjMap = sourceRecIdTargetObjMap;
            this.sourceRecIdlstTargetObjMap = sourceRecIdlstTargetObjMap;
            this.objectName = objectName;
            this.aliasName = aliasName;
            this.allFieldDescribe = allFieldDescribe;
        }
    }
    
    private void doDateTimeConversionAndCurrencyHandling(Sobject HdrSObject, List<Sobject> lstSObjects, String ObjAPIName, Set<String> setDetailFields, String timeZone, Map<String,map<String,Schema.SObjectField>> allFieldDescribe, Boolean isCurrencyHandlingRequired, DCON_Utils dcUtils){
        
        system.debug(LoggingLevel.WARN, 'HdrSObject: ' + HdrSObject);
        system.debug(LoggingLevel.WARN, 'lstSObjects: ' + lstSObjects);
        system.debug(LoggingLevel.WARN, 'ObjAPIName: ' + ObjAPIName);
        system.debug(LoggingLevel.WARN, 'setDetailFields: ' + setDetailFields);
        system.debug(LoggingLevel.WARN, 'isCurrencyHandlingRequired: ' + isCurrencyHandlingRequired);
        
        if(lstSObjects != null && lstSObjects.size() > 0){
            if(AllFieldDescribe.containskey(ObjAPIName)){
                map<String, Schema.SObjectField> DtlFieldMap = new map<String, Schema.SObjectField>();
                DtlFieldMap = AllFieldDescribe.get(ObjAPIName);
                if(DtlFieldMap.size() > 0 && setDetailFields.size() > 0){
                    for(String s : setDetailFields){
                        if(DtlFieldMap.containskey(s)){
                            Schema.DescribeFieldResult f = DtlFieldMap.get(s).getDescribe();
                            if(f.isAccessible() && f.getType() == schema.Displaytype.DateTime){
                                for(Integer j = 0;j<lstSObjects.size();j++){
                                    //Commented this line and added below additional condition for fixing defect 043657
                                    //if(lstSObjects[j].get(s) != null){
                                    if(lstSObjects[j].getPopulatedFieldsAsMap().containsKey(s) && lstSObjects[j].get(s) != null){
                                        Datetime dt = dcUtils.getDateTimeInTimezone(DateTime.valueof(lstSObjects[j].get(s)).dateGmt(), DateTime.valueof(lstSObjects[j].get(s)).timeGmt(), timeZone);
                                        lstSObjects[j].put(s,dt);
                                    }
                                }
                            }
                        }        
                    }
                }
                //special handling for currencyISOCode field in detail record.
                if(isCurrencyHandlingRequired){
                    for(Integer j = 0;j<lstSObjects.size();j++){
                        if(Userinfo.isMultiCurrencyOrganization() && DtlFieldMap.containskey('CurrencyIsoCode')){
                            if(lstSObjects[j].get('CurrencyIsoCode') == null && HdrSObject.get('CurrencyIsoCode') != null){
                                lstSObjects[j].put('CurrencyIsoCode', HdrSObject.get('CurrencyIsoCode'));
                            }
                        }
                    }
                }
            }
        }
    }
    public SVMXC.SFM_WrapperDef.SFM_Response CallSFMTrigger(SVMXC__SFM_Event__c objSFMEvent, String strHeaderRecordId){
        SVMXC.SFM_WrapperDef.SFM_Request request;
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response(); 
        response.success = true;
        try{
            String strClassName = objSFMEvent.SVMXC__Namespace__c+'.'+objSFMEvent.SVMXC__Class__c;
            String strProcessId = objSFMEvent.SVMXC__ServiceMax_Custom_Action__r.SVMXC__ProcessID__c;
            request = new SVMXC.SFM_WrapperDef.SFM_Request();
            response = new SVMXC.SFM_WrapperDef.SFM_Response();
            SVMXC.SFM_WrapperDef.SFM_StringMap headerRecordIdStringMap  = new SVMXC.SFM_WrapperDef.SFM_StringMap('SVMX_HearderId',strHeaderRecordId);
            SVMXC.SFM_WrapperDef.SFM_StringMap processIdStringMap  = new SVMXC.SFM_WrapperDef.SFM_StringMap('SVMX_InventoryProcessId',strProcessId);
            request.stringMap.add(headerRecordIdStringMap);
            request.stringMap.add(processIdStringMap);
            
            SFM_TriggerBaseInterface instanceTriggerBase = SFM_TriggerBaseManager.getInstance().createSFMTrigger(strClassName);
            response = new SVMXC.SFM_WrapperDef.SFM_Response();
            response = instanceTriggerBase.executeSFMTrigger(request);
            if(response.messages != null && !response.messages.isEmpty()){
                if(response.message == null)
                    response.message = '';
                for(SVMXC.SFM_WrapperDef.SVMXMessage svmxMessages : response.messages){
                    if(response.message != '' ) {
                        response.message += ',';
                    }
                    response.message +=  svmxMessages.message;
                }
            }
            else {
                if(response.message == null || response.message == '')
                    response.message = system.Label.SFM002_TAG020;
            }
        }
        catch(exception ex){
            response.success = false;
            response.message = ex.getMessage();
        }
        return response;
    }   
    
    /* This method is used to calculate chunks */
    @testvisible
    private Integer getChunckCount(Integer recordCount){ // #chunkWork
        return (recordCount / MAX_RECORDS_IN_CHUNK) + (Math.mod(recordCount, MAX_RECORDS_IN_CHUNK) > 0 ? 1 : 0);
    }
    
}