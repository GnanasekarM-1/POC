/* Security Scanned */
public with sharing class SFM_TransposeChecklistData implements SVMXC.SFM_ScheduledBatchInterface {
    
    //Wrapper classes for deserializing Checklist Meta JSON
    public class SFM_Response_PageUI{
        SFM_PageUI page = new SFM_PageUI();
    }
    public class SFM_PageUI{
        String processTitle;
        SFM_PageHeader header = new SFM_PageHeader();
    }
    public class SFM_PageHeader{
        List<SFM_UISection> sections = new List<SFM_UISection>();
    }
    public class SFM_UISection{
        List<SFM_UIField> fields = new List<SFM_UIField>();
    }
    public class SFM_UIField{
        SVMXC__Page_Layout_Detail__c fieldDetail = new SVMXC__Page_Layout_Detail__c();
    }
    
    private final String RECORD_IDS = 'RECORDIDS';
    private Integer countOfExistingChecklistRecords = 0;
    public SVMXC.SFM_WrapperDef.SFM_Response executeService(SVMXC.SFM_WrapperDef.SFM_Request sfmObjRequest){
        System.debug(LoggingLevel.DEBUG, 'In SFM_TransposeChecklistData:executeService()' + sfmObjRequest);
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        objResponse.StringLstMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        objResponse.success = true;
        objResponse.message = 'Success';
        
        SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('ServiceType','ChecklistReporting');
        objResponse.stringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>{objStringMap};
        Boolean isValid = true;
        String strInValidReason = '';
        
        try{
            if(sfmObjRequest != null && sfmObjRequest.stringListMap != null && sfmObjRequest.stringListMap.size()>0){
                SVMXC.SFM_WrapperDef.SFM_StringListMap objStringListMap = sfmObjRequest.stringListMap[0];            
                if(objStringListMap != null && objStringListMap.key != null && objStringListMap.key.equalsIgnoreCase(RECORD_IDS) && objStringListMap.valueList != null){
                   if(objStringListMap.valueList.size() > 0){
                      System.debug(LoggingLevel.DEBUG, 'Qualified Checklist Record Ids: ' + objStringListMap.valueList);
                      transposeChecklistData(objStringListMap.valueList, objResponse);
                   }
                   else{
                       isValid = false;
                       strInValidReason = 'No checklist record ids';
                   }
                }
                else{
                    isValid = false;
                    strInValidReason = 'Either StringListMap is null Or Key (or valueList) is null';
                }
            }
            else{
                isValid = false;
                strInValidReason = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            objResponse.messageType = ex.getStackTraceString();
            System.debug(LoggingLevel.ERROR, 'Exception thrown in executeService for SFM_TransposeChecklistData : ' + ex.getMessage()+'----'+ex.getStackTraceString());
        }
        
        if(!isValid){
            objResponse.success = false;
            objResponse.message = strInValidReason;
        }
        
        objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('AlreadyProcessedChecklistRecord',countOfExistingChecklistRecords+'');
        objResponse.stringMap.add(objStringMap);
        System.debug(LoggingLevel.DEBUG, 'SFM_Response : ' + objResponse);
        return objResponse;
    }

    private void transposeChecklistData(List<String> lstChecklistIds, SVMXC.SFM_WrapperDef.SFM_Response objResponse){
        List<SVMXC__SM_Checklist_Result__c> lstChecklistResult = new List<SVMXC__SM_Checklist_Result__c>();
        //List<SVMXC__Checklist__c> lstChecklistRecordsWithoutGroupId = new List<SVMXC__Checklist__c> ();
        Map<String, String> mapOfChecklistIdVsTargetFieldApiName = new Map<String, String>();
        
        
        //Collecting Checklist ids from the records by Querying existing checklist result records
        Set<String> setChecklistId = new Set<String>();
        for(SVMXC__SM_Checklist_Result__c objCR : [SELECT SVMXC__SM_Checklist__c FROM SVMXC__SM_Checklist_Result__c WHERE SVMXC__SM_Checklist__c IN: lstChecklistIds]){
            setChecklistId.add(objCR.SVMXC__SM_Checklist__c);
        }
        System.debug(LoggingLevel.DEBUG, 'ExistingChecklistIds size: ' + setChecklistId.size());
        countOfExistingChecklistRecords = setChecklistId.size();
        
        //Creating new list of checklist ids by removing already inserted checklist record ids
        List<String> modifiedChecklistIds = new List<String>();
        for(String Cid : lstChecklistIds){
            if(!setChecklistId.contains(Cid))
                modifiedChecklistIds.add(Cid);
        }
        setChecklistId.clear();
        System.debug(LoggingLevel.DEBUG, 'modifiedChecklistIds size: ' + modifiedChecklistIds.size());
        List<SVMXC__Checklist__c> lstChecklistRecordsTemp = new List<SVMXC__Checklist__c> ();
        lstChecklistRecordsTemp = [ SELECT Id,SVMXC__SM_Checklist_Group_Id__c FROM SVMXC__Checklist__c where id IN: modifiedChecklistIds AND SVMXC__What_Id__c != null ];
        modifiedChecklistIds.clear();
        List<decimal> lstgroupId = new List<decimal>();
        for(SVMXC__Checklist__c obj:lstChecklistRecordsTemp)
        {
            if(obj.SVMXC__SM_Checklist_Group_Id__c != null)
                lstgroupId.add(obj.SVMXC__SM_Checklist_Group_Id__c);
            else
                modifiedChecklistIds.add(obj.id);
        }
        List<SVMXC__Checklist__c> lstChecklistRecordsWithGroupId = new List<SVMXC__Checklist__c> ();
        List<SVMXC__Checklist__c> lstChecklistRecordsWithoutGroupId = new List<SVMXC__Checklist__c> ();
        List<SVMXC__Checklist__c> lstChecklistRecords = new List<SVMXC__Checklist__c> ();
        
        //Querying checklist records based on modified checklist Ids
        if(lstgroupId != null && lstgroupId.size()>0)
        {
            lstChecklistRecordsWithGroupId = [SELECT Id, SVMXC__ChecklistJSON__c, SVMXC__ChecklistMetaJSON__c, SVMXC__What_Id__c, SVMXC__SM_Checklist_Group_Id__c,SVMXC__SM_Sequence__c, SVMXC__Completed_By__c FROM SVMXC__Checklist__c WHERE SVMXC__SM_Checklist_Group_Id__c IN: lstgroupId AND SVMXC__What_Id__c != null];
            System.debug(LoggingLevel.DEBUG, 'lstChecklistRecordsWithGroupId size: ' + lstChecklistRecordsWithGroupId.size());
        }
        if(modifiedChecklistIds != null && modifiedChecklistIds.size()>0)
        {
            lstChecklistRecordsWithoutGroupId = [SELECT Id, SVMXC__ChecklistJSON__c, SVMXC__ChecklistMetaJSON__c, SVMXC__What_Id__c, SVMXC__SM_Checklist_Group_Id__c,SVMXC__SM_Sequence__c, SVMXC__Completed_By__c FROM SVMXC__Checklist__c WHERE Id IN: modifiedChecklistIds AND SVMXC__What_Id__c != null];
            System.debug(LoggingLevel.DEBUG, 'lstChecklistRecords size: ' + lstChecklistRecordsWithoutGroupId.size());
        }
        lstChecklistRecords.clear();
        lstChecklistRecords.addAll(lstChecklistRecordsWithGroupId);
        lstChecklistRecords.addAll(lstChecklistRecordsWithoutGroupId);
        
        //Describing SobjectResult for Checklist Result Object and creating map of Object API name and Field API name for lookup fields only
        Schema.DescribeSObjectResult[] objDescSobjectRes = Schema.describeSObjects(new String[]{'SVMXC__SM_Checklist_Result__c'});
        Map<String, String> mapOfObjectNameVsFieldApiName = new Map<String, String>();
        for(Schema.DescribeSObjectResult objDSOR : objDescSobjectRes){
            Map<String, Schema.SObjectField> fieldMap = objDSOR.fields.getMap();
            for(String key : fieldMap.keyset()){
                Schema.DescribeFieldResult objDescFieldResult = fieldMap.get(key).getDescribe();
                if(String.valueOf(objDescFieldResult.getType()).equals('REFERENCE')){
                    mapOfObjectNameVsFieldApiName.put(objDescFieldResult.getReferenceTo()[0].getDescribe().getName(), objDescFieldResult.getName());
                }
            }
        }
        
        //Iterating through all the checklist records and creating a map of checklist Id and respective TargetFieldAPI name
        Map<String, String> mapObjectKeyVsObjectName = new Map<String, String>();
        Map<decimal, map<integer,SVMXC__Checklist__c>> mapGroupIdChecklist = new Map<decimal,  map<integer,SVMXC__Checklist__c>>();
        List<Id> listOfAllChecklistIds = new List<Id>(); //Added for Defect-047376
        Set<String> setAllChecklistId = new Set<String>(); //Added for Defect-047376
        for(SVMXC__Checklist__c objChecklist : lstChecklistRecords){
            listOfAllChecklistIds.add(objChecklist.Id); //Added for Defect-047376
            Id sourceRecrodId = objChecklist.SVMXC__What_Id__c;
            String strObjectKeyPrefix = objChecklist.SVMXC__What_Id__c.substring(0, 3);
            String sObjName = '';
            
            //Will describe object only if it is not already described by checking key prefix in map
            if(!mapObjectKeyVsObjectName.containsKey(strObjectKeyPrefix)){
                sObjName = sourceRecrodId.getSObjectType().getDescribe().getName();
                mapObjectKeyVsObjectName.put(strObjectKeyPrefix, sObjName);
            }
            sObjName = mapObjectKeyVsObjectName.get(strObjectKeyPrefix);
            if(mapOfObjectNameVsFieldApiName.containsKey(sObjName)){
                mapOfChecklistIdVsTargetFieldApiName.put(objChecklist.Id, mapOfObjectNameVsFieldApiName.get(sObjName));
            }
            if(objChecklist.SVMXC__SM_Checklist_Group_Id__c != null )
            {
                if(mapGroupIdChecklist != null && mapGroupIdChecklist.containsKey(objChecklist.SVMXC__SM_Checklist_Group_Id__c))
                {
                    map<integer,SVMXC__Checklist__c> mapseqChck = new map<integer,SVMXC__Checklist__c>();
                    mapseqChck = mapGroupIdChecklist.get(objChecklist.SVMXC__SM_Checklist_Group_Id__c);
                    integer sequenceno = (integer)objChecklist.SVMXC__SM_Sequence__c;
                    mapseqChck.put(sequenceno,objChecklist);
                    mapGroupIdChecklist.put(objChecklist.SVMXC__SM_Checklist_Group_Id__c, mapseqChck);
                    
                }
                else
                {
                    map<integer,SVMXC__Checklist__c> mapseqChck = new map<integer,SVMXC__Checklist__c>();
                    integer sequenceno = (integer)objChecklist.SVMXC__SM_Sequence__c;
                    mapseqChck.put(sequenceno,objChecklist);
                    mapGroupIdChecklist.put(objChecklist.SVMXC__SM_Checklist_Group_Id__c, mapseqChck);
                }
            }
            else
                lstChecklistRecordsWithoutGroupId.add(objChecklist);
        }
        //Added for Defect-047376
        for(SVMXC__SM_Checklist_Result__c objCR : [SELECT SVMXC__SM_Checklist__c FROM SVMXC__SM_Checklist_Result__c WHERE SVMXC__SM_Checklist__c IN: listOfAllChecklistIds]){
            setAllChecklistId.add(objCR.SVMXC__SM_Checklist__c);
        }
        //End for Defect-047376
        //Iterating through all the checklist records for creating checklist result records
        Map<String, List<String>> mapQueIdVsListOfAnswers = new Map<String, List<String>>();
        Map<String, Object> mapQueIdVsAnswersFromJSON = new Map<String, Object>();
        
        if(lstChecklistRecordsWithoutGroupId != null && lstChecklistRecordsWithoutGroupId.size()>0){
        for(SVMXC__Checklist__c objChecklist : lstChecklistRecordsWithoutGroupId){
            mapQueIdVsListOfAnswers.clear();
            mapQueIdVsAnswersFromJSON.clear();
            SFM_Response_PageUI objResponsePageUI = null;
            
            //Deserializing the ansered checklist JSON and creating a map of questionID and list of answers
            try{
                if(objChecklist.SVMXC__ChecklistJSON__c != null && objChecklist.SVMXC__ChecklistJSON__c != ''){
                    mapQueIdVsAnswersFromJSON =(Map<String, Object>)JSON.deserializeUntyped(objChecklist.SVMXC__ChecklistJSON__c);
                }
                else{
                    System.debug(LoggingLevel.DEBUG, 'Null OR blank ChecklistJSON for checklist Id: ' + objChecklist.id);
                    continue;
                }
            }
            catch(Exception ex){
                System.debug(LoggingLevel.DEBUG, 'Exception message: ' + ex.getMessage());
                System.debug(LoggingLevel.DEBUG, 'Exception in deserializing SVMXC__ChecklistJSON__c for checklist Id: ' + objChecklist.id);
                continue;
            }
            
            //Creating map of Question Id and List of Answers
            for(String strobj : mapQueIdVsAnswersFromJSON.keyset()){
                Object objAns =  mapQueIdVsAnswersFromJSON.get(strobj);
                //For single answer
                if(objAns instanceof String){
                    mapQueIdVsListOfAnswers.put(strobj, new List<String>{(String)objAns});
                }
                //For multiple answers
                else if(objAns instanceof List<Object>){
                    mapQueIdVsListOfAnswers.put(strobj, new List<String>());
                    List<Object> lstAnswer = (List<Object>)objAns;
                    for(Object obj : lstAnswer){
                        mapQueIdVsListOfAnswers.get(strobj).add((String)obj);
                    }
                }
                else if(objAns instanceof Long){
                    mapQueIdVsListOfAnswers.put(strobj, new List<String>{(Long)objAns+''});
                }
                else if(objAns instanceof Double){
                    mapQueIdVsListOfAnswers.put(strobj, new List<String>{(Double)objAns+''});
                }
            }
            
            //Deserializing the Checklist MetaJSON
            try{
                if(objChecklist.SVMXC__ChecklistMetaJSON__c != null && objChecklist.SVMXC__ChecklistMetaJSON__c != ''){
                    objResponsePageUI = (SFM_Response_PageUI) JSON.deserialize(objChecklist.SVMXC__ChecklistMetaJSON__c, SFM_Response_PageUI.class);
                }
                else{
                    System.debug(LoggingLevel.DEBUG, 'Null OR blank ChecklistMetaJSON for checklist Id: ' + objChecklist.id);
                    continue;
                }
            }
            catch(Exception ex){
                System.debug(LoggingLevel.DEBUG, 'Exception message: ' + ex.getMessage());
                System.debug(LoggingLevel.DEBUG, 'Exception in deserializing SVMXC__ChecklistMetaJSON__c for checklist Id: ' + objChecklist.id);
                continue;
            }
            System.debug(LoggingLevel.DEBUG, 'objResponsePageUI: ' + objResponsePageUI);
            System.debug(LoggingLevel.DEBUG, 'mapQueIdVsListOfAnswers : ' + mapQueIdVsListOfAnswers);
            
            if(objResponsePageUI != null && mapQueIdVsListOfAnswers.size()>0){
                //Collecting Checlist name
                String ChecklistTitle = objResponsePageUI.page.processTitle;
                
                //Collecting sections details in the list from the meta JSON
                List<SFM_UISection> lstSections = objResponsePageUI.page.header.sections;
                
                //Iterating through all the sections creted for the process
                for(SFM_UISection objUI_Section : lstSections){
                    
                    //Collecting list of SFM_UIField for every section from meta JSON
                    List<SFM_UIField> lstUIFieldOfQuestion = objUI_Section.fields;
                    
                    //Iterating through all the SFM_UIField instance(Represent one question)
                    for(SFM_UIField objUIField : lstUIFieldOfQuestion){
                        SVMXC__Page_Layout_Detail__c objPLDetail = objUIField.fieldDetail;
                        if(objPLDetail.SVMXC__Detail_Type__c == 'Question' && objPLDetail.SVMXC__QuestionInfoJSON__c != null){
                            
                            //Deserializing SFM_QuestionInfo record from the meta JSON
                            String strQuestionText = '';
                            String strQuestionID = '';
                            try{
                                SVMXC.SFM_WrapperDef.SFM_QuestionInfo objQuestionInfo = (SVMXC.SFM_WrapperDef.SFM_QuestionInfo) JSON.deserialize(objPLDetail.SVMXC__QuestionInfoJSON__c, SVMXC.SFM_WrapperDef.SFM_QuestionInfo.class);
                                strQuestionText = objQuestionInfo.question.question;
                                strQuestionID = objQuestionInfo.question.questionID;
                            }
                            catch(Exception ex){
                                //This is added as part of defect 37127 fix. This will handle the checklist metajson which was submitted by FSA client where we are having string value for the double field of the wrapper class of the question. Here will parse the question json and get the value for the question and questionID
                                if(ex.getTypeName().equalsIgnoreCase('System.JSONException') && ex.getMessage().startsWithIgnoreCase('empty String')){
                                    try{
                                        System.debug(LoggingLevel.DEBUG, 'Handling of deserialize');
                                        JSONParser parser = JSON.createParser(objPLDetail.SVMXC__QuestionInfoJSON__c);
                                        while (parser.nextToken() != null) {
                                            if(parser.getCurrentToken() == JSONToken.START_OBJECT && parser.getCurrentName() != null && parser.getCurrentName().equalsIgnoreCase('question')){
                                                while (parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_OBJECT) {
                                                    if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() != null && parser.getCurrentName().equalsIgnoreCase('question')){
                                                        parser.nextToken();
                                                        strQuestionText = parser.getText();
                                                    }
                                                    else if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() != null && parser.getCurrentName().equalsIgnoreCase('questionID')){
                                                        parser.nextToken();
                                                        strQuestionID = parser.getText();
                                                    }
                                                }
                                                break;
                                            }
                                        }
                                    }
                                    catch(Exception excep){
                                        System.debug(LoggingLevel.DEBUG, 'Exception message: ' + excep.getMessage());
                                        System.debug('Stack trace: ' + excep.getStackTraceString());
                                        System.debug(LoggingLevel.DEBUG, 'Exception in parsing SVMXC__QuestionInfoJSON__c for checklist Id: ' + objChecklist.id+' and PageLayout id: '+objPLDetail.id);
                                        continue;
                                    }
                                }
                                else{
                                    System.debug(LoggingLevel.DEBUG, 'Exception message: ' + ex.getMessage());
                                    System.debug('Stack trace: ' + ex.getStackTraceString());
                                    System.debug(LoggingLevel.DEBUG, 'Exception in deserializing SVMXC__QuestionInfoJSON__c for checklist Id: ' + objChecklist.id+' and PageLayout id: '+objPLDetail.id);
                                    continue;
                                }
                            }
                            SVMXC__SM_Checklist_Result__c objChecklistResult = new SVMXC__SM_Checklist_Result__c();
                            objChecklistResult.SVMXC__SM_Checklist__c = objChecklist.Id;
                            objChecklistResult.SVMXC__SM_Checklist_Name__c = ChecklistTitle;
                            objChecklistResult.SVMXC__SM_Question_Number__c = strQuestionID;
                            objChecklistResult.SVMXC__SM_Question__c = strQuestionText;
                            objChecklistResult.SVMXC__SM_Completed_By__c = objChecklist.SVMXC__Completed_By__c;
                            
                            if(mapOfChecklistIdVsTargetFieldApiName.containsKey(objChecklist.Id)){
                                objChecklistResult.put(mapOfChecklistIdVsTargetFieldApiName.get(objChecklist.Id), objChecklist.SVMXC__What_Id__c);
                            }
                            
                            //If there are multiple answers for the one question so we are storing all the answers in the SVMXC__SM_Answer__c field by using separator ';' semi colon
                            if(mapQueIdVsListOfAnswers.containsKey(strQuestionID)){
                                List<String> lstOfAns = mapQueIdVsListOfAnswers.get(strQuestionID);
                                String strAnsVal = '';
                                for(String ans : lstOfAns){
                                    if(strAnsVal.length()>0){
                                        strAnsVal = strAnsVal + ';' + ans;
                                    }
                                    else{
                                        strAnsVal = ans;
                                    }
                                }
                                //This is added as part of defect 37127 fix.
                                objChecklistResult.SVMXC__SM_Complete_Answer__c = strAnsVal;
                                if(strAnsVal.length() > 255){
                                    strAnsVal = strAnsVal.substring(0, 252) + '...';
                                }
                                objChecklistResult.SVMXC__SM_Answer__c = strAnsVal;
                            }
                            else{
                                objChecklistResult.SVMXC__SM_Answer__c = '';
                                objChecklistResult.SVMXC__SM_Complete_Answer__c = '';
                            }
                            //adding checklist result record to the list
                            lstChecklistResult.add(objChecklistResult);
                        }
                    }
                }
            }
        }
        }
        //--------------------------- Apurva ---------------------------
        System.debug(LoggingLevel.DEBUG, 'mapGroupIdChecklist'+mapGroupIdChecklist );
        if(mapGroupIdChecklist != null && mapGroupIdChecklist.size()>0){
            System.debug(LoggingLevel.DEBUG, 'Entered mapGroupIdChecklist block' );
    for(decimal groupId:mapGroupIdChecklist.keyset()){
        map<integer,SVMXC__Checklist__c> mapseqChck = new map<integer,SVMXC__Checklist__c>();
        mapseqChck = mapGroupIdChecklist.get(groupId);
        string metaJason ='';
        string jason ='';
        SVMXC__Checklist__c objChecklist = new SVMXC__Checklist__c ();
        if(mapseqChck !=null && mapseqChck.size()>0 ){
            if(mapseqChck.containsKey(1)){
            jason =  mapseqChck.get(1).SVMXC__ChecklistJSON__c;
            objChecklist = mapseqChck.get(1);
            }
        if (!setAllChecklistId.isEmpty() && setAllChecklistId.contains(objChecklist.id)) { //Added for Defect-047376
            continue;
        }
        for(integer i =1;i<=mapseqChck.size();i++)
        {
            
            metaJason = metaJason+ mapseqChck.get(i).SVMXC__ChecklistMetaJSON__c;
            
        }
        System.debug(LoggingLevel.DEBUG, 'groupId: '+groupId );
        System.debug(LoggingLevel.DEBUG, 'objChecklist: '+objChecklist );
        System.debug(LoggingLevel.DEBUG, 'metaJason '+metaJason.length() );
        System.debug(LoggingLevel.DEBUG, 'jason '+jason.length() );
//for(SVMXC__Checklist__c objChecklist : lstChecklistRecords)
//{
            mapQueIdVsListOfAnswers.clear();
            mapQueIdVsAnswersFromJSON.clear();
            SFM_Response_PageUI objResponsePageUI = null;
            
            //Deserializing the ansered checklist JSON and creating a map of questionID and list of answers
            try{
                if(jason != null && jason != ''){
                    mapQueIdVsAnswersFromJSON =(Map<String, Object>)JSON.deserializeUntyped(jason);
                }
                else{
                    System.debug(LoggingLevel.DEBUG, 'Null OR blank ChecklistJSON for checklist Id: ' + objChecklist.id);
                    continue;
                }
            }
            catch(Exception ex){
                System.debug(LoggingLevel.DEBUG, 'Exception message: ' + ex.getMessage());
                System.debug(LoggingLevel.DEBUG, 'Exception in deserializing SVMXC__ChecklistJSON__c for checklist Id: ' + objChecklist.id);
                continue;
            }
            
            //Creating map of Question Id and List of Answers
            for(String strobj : mapQueIdVsAnswersFromJSON.keyset()){
                Object objAns =  mapQueIdVsAnswersFromJSON.get(strobj);
                //For single answer
                if(objAns instanceof String){
                    mapQueIdVsListOfAnswers.put(strobj, new List<String>{(String)objAns});
                }
                //For multiple answers
                else if(objAns instanceof List<Object>){
                    mapQueIdVsListOfAnswers.put(strobj, new List<String>());
                    List<Object> lstAnswer = (List<Object>)objAns;
                    for(Object obj : lstAnswer){
                        mapQueIdVsListOfAnswers.get(strobj).add((String)obj);
                    }
                }
                else if(objAns instanceof Long){
                    mapQueIdVsListOfAnswers.put(strobj, new List<String>{(Long)objAns+''});
                }
                else if(objAns instanceof Double){
                    mapQueIdVsListOfAnswers.put(strobj, new List<String>{(Double)objAns+''});
                }
            }
            
            //Deserializing the Checklist MetaJSON
            try{
                if(metaJason != null && metaJason != ''){
                    objResponsePageUI = (SFM_Response_PageUI) JSON.deserialize(metaJason, SFM_Response_PageUI.class);
                }
                else{
                    System.debug(LoggingLevel.DEBUG, 'Null OR blank ChecklistMetaJSON for checklist Id: ' + objChecklist.id);
                    continue;
                }
            }
            catch(Exception ex){
                System.debug(LoggingLevel.DEBUG, 'Exception message: ' + ex.getMessage());
                System.debug(LoggingLevel.DEBUG, 'Exception in deserializing SVMXC__ChecklistMetaJSON__c for checklist Id: ' + objChecklist.id);
                continue;
            }
            System.debug(LoggingLevel.DEBUG, 'objResponsePageUI: ' + objResponsePageUI);
            System.debug(LoggingLevel.DEBUG, 'mapQueIdVsListOfAnswers : ' + mapQueIdVsListOfAnswers);
            
            if(objResponsePageUI != null && mapQueIdVsListOfAnswers.size()>0){
                //Collecting Checlist name
                String ChecklistTitle = objResponsePageUI.page.processTitle;
                
                //Collecting sections details in the list from the meta JSON
                List<SFM_UISection> lstSections = objResponsePageUI.page.header.sections;
                
                //Iterating through all the sections creted for the process
                for(SFM_UISection objUI_Section : lstSections){
                    
                    //Collecting list of SFM_UIField for every section from meta JSON
                    List<SFM_UIField> lstUIFieldOfQuestion = objUI_Section.fields;
                    
                    //Iterating through all the SFM_UIField instance(Represent one question)
                    for(SFM_UIField objUIField : lstUIFieldOfQuestion){
                        SVMXC__Page_Layout_Detail__c objPLDetail = objUIField.fieldDetail;
                        if(objPLDetail.SVMXC__Detail_Type__c == 'Question' && objPLDetail.SVMXC__QuestionInfoJSON__c != null){
                            
                            //Deserializing SFM_QuestionInfo record from the meta JSON
                            String strQuestionText = '';
                            String strQuestionID = '';
                            try{
                                SVMXC.SFM_WrapperDef.SFM_QuestionInfo objQuestionInfo = (SVMXC.SFM_WrapperDef.SFM_QuestionInfo) JSON.deserialize(objPLDetail.SVMXC__QuestionInfoJSON__c, SVMXC.SFM_WrapperDef.SFM_QuestionInfo.class);
                                strQuestionText = objQuestionInfo.question.question;
                                strQuestionID = objQuestionInfo.question.questionID;
                            }
                            catch(Exception ex){
                                //This is added as part of defect 37127 fix. This will handle the checklist metajson which was submitted by FSA client where we are having string value for the double field of the wrapper class of the question. Here will parse the question json and get the value for the question and questionID
                                if(ex.getTypeName().equalsIgnoreCase('System.JSONException') && ex.getMessage().startsWithIgnoreCase('empty String')){
                                    try{
                                        System.debug(LoggingLevel.DEBUG, 'Handling of deserialize');
                                        JSONParser parser = JSON.createParser(objPLDetail.SVMXC__QuestionInfoJSON__c);
                                        while (parser.nextToken() != null) {
                                            if(parser.getCurrentToken() == JSONToken.START_OBJECT && parser.getCurrentName() != null && parser.getCurrentName().equalsIgnoreCase('question')){
                                                while (parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_OBJECT) {
                                                    if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() != null && parser.getCurrentName().equalsIgnoreCase('question')){
                                                        parser.nextToken();
                                                        strQuestionText = parser.getText();
                                                    }
                                                    else if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() != null && parser.getCurrentName().equalsIgnoreCase('questionID')){
                                                        parser.nextToken();
                                                        strQuestionID = parser.getText();
                                                    }
                                                }
                                                break;
                                            }
                                        }
                                    }
                                    catch(Exception excep){
                                        System.debug(LoggingLevel.DEBUG, 'Exception message: ' + excep.getMessage());
                                        System.debug('Stack trace: ' + excep.getStackTraceString());
                                        System.debug(LoggingLevel.DEBUG, 'Exception in parsing SVMXC__QuestionInfoJSON__c for checklist Id: ' + objChecklist.id+' and PageLayout id: '+objPLDetail.id);
                                        continue;
                                    }
                                }
                                else{
                                    System.debug(LoggingLevel.DEBUG, 'Exception message: ' + ex.getMessage());
                                    System.debug('Stack trace: ' + ex.getStackTraceString());
                                    System.debug(LoggingLevel.DEBUG, 'Exception in deserializing SVMXC__QuestionInfoJSON__c for checklist Id: ' + objChecklist.id+' and PageLayout id: '+objPLDetail.id);
                                    continue;
                                }
                            }
                            SVMXC__SM_Checklist_Result__c objChecklistResult = new SVMXC__SM_Checklist_Result__c();
                            objChecklistResult.SVMXC__SM_Checklist__c = objChecklist.Id;
                            objChecklistResult.SVMXC__SM_Checklist_Name__c = ChecklistTitle;
                            objChecklistResult.SVMXC__SM_Question_Number__c = strQuestionID;
                            objChecklistResult.SVMXC__SM_Question__c = strQuestionText;
                            objChecklistResult.SVMXC__SM_Completed_By__c = objChecklist.SVMXC__Completed_By__c;
                            
                            if(mapOfChecklistIdVsTargetFieldApiName.containsKey(objChecklist.Id)){
                                objChecklistResult.put(mapOfChecklistIdVsTargetFieldApiName.get(objChecklist.Id), objChecklist.SVMXC__What_Id__c);
                            }
                            
                            //If there are multiple answers for the one question so we are storing all the answers in the SVMXC__SM_Answer__c field by using separator ';' semi colon
                            if(mapQueIdVsListOfAnswers.containsKey(strQuestionID)){
                                List<String> lstOfAns = mapQueIdVsListOfAnswers.get(strQuestionID);
                                String strAnsVal = '';
                                for(String ans : lstOfAns){
                                    if(strAnsVal.length()>0){
                                        strAnsVal = strAnsVal + ';' + ans;
                                    }
                                    else{
                                        strAnsVal = ans;
                                    }
                                }
                                objChecklistResult.SVMXC__SM_Complete_Answer__c = strAnsVal;
                                if(strAnsVal.length() > 255){
                                    strAnsVal = strAnsVal.substring(0, 252) + '...';
                                }
                                objChecklistResult.SVMXC__SM_Answer__c = strAnsVal;
                            }
                            else{
                                objChecklistResult.SVMXC__SM_Answer__c = '';
                                objChecklistResult.SVMXC__SM_Complete_Answer__c = '';
                            }
                            //adding checklist result record to the list
                            lstChecklistResult.add(objChecklistResult);
                        }
                    }
                }
            }
        //}
    }
}
        }
        //--------------------------- Apurva ---------------------------
        
        System.debug(LoggingLevel.DEBUG, 'Final lstChecklistResult : ' + lstChecklistResult);
        if(lstChecklistResult != null && lstChecklistResult.size() > 0){
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            insert lstChecklistResult;
            Map<String, List<String>> mapChecklistIdVsListOfChecklistResultId = new Map<String, List<String>>();
            for(SVMXC__SM_Checklist_Result__c objCD : lstChecklistResult){
                if(!mapChecklistIdVsListOfChecklistResultId.containsKey(objCD.SVMXC__SM_Checklist__c))
                    mapChecklistIdVsListOfChecklistResultId.put(objCD.SVMXC__SM_Checklist__c, new List<String>());
                mapChecklistIdVsListOfChecklistResultId.get(objCD.SVMXC__SM_Checklist__c).add(objCD.id);
            }
            for(String key : mapChecklistIdVsListOfChecklistResultId.keyset()){
                SVMXC.SFM_WrapperDef.SFM_StringListMap tempObject = new SVMXC.SFM_WrapperDef.SFM_StringListMap(key, mapChecklistIdVsListOfChecklistResultId.get(key));
                objResponse.StringLstMap.add(tempObject);
            }
        }
    }
}