/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
/**
 * The class implements methods required to retrieve and save question bank, 
 * response set details.
 *
 *
 * @author Sachin
 * @version 20.1
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                15 Dec 2019     Created.
 * SFMDZ-2041   Ramachandra Mohan       06 Jan 2020     Implemented new method to save response set.
 * SFMDZ-2035   Ramachandra Mohan       08 Jan 2020     Implemented methods to save question information.
 *****************************************************************************************************/
/* Security Scanned */
public with sharing class SFM_QuestionBankUtils{
    //Constructor
    public SFM_QuestionBankUtils(){}
    
    //This method returns all the Question Salesforce IDs with Question Name AND  List of SFM_QuestionBank
    //Request requires key as 'AllQUESTION'
    //Response will be SFM_Response with list of SFM_StringMap(Sid, questionText) AND List<SFM_QuestionBank>
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetListOfQuestion(SVMXC.SFM_WrapperDef.SFM_Request request){
        System.debug(LoggingLevel.WARN, 'Request in SFM_GetListOfQuestion method : ' + request);
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        objResponse.stringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        objResponse.stringFieldMap = new List<SVMXC.SFM_WrapperDef.SFM_StringFieldMap>();
        objResponse.success = true;
        try{
            if(request != null && request.stringMap != null){
                for(SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap : request.stringMap){
                    if(objStringMap.key != null && objStringMap.key.toUpperCase() == 'AllQUESTION'){
                        for(SVMXC__Question_Bank__c objQuestion : [SELECT Id, SVMXC__Question__c, SVMXC__Response_Type__c, LastModifiedDate FROM SVMXC__Question_Bank__c]){
                            objResponse.stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap(objQuestion.id, objQuestion.SVMXC__Question__c));
                            objResponse.lstQuestionBank.add(new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQuestion, null));
                        }
                        Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get('SVMXC__Question_Bank__c').getDescribe().fields.getMap();
                        for(String fieldName: mapFields.keyset()){
                            Schema.DescribeFieldResult fieldDesc = mapFields.get(fieldName).getDescribe();
                            objResponse.stringFieldMap.add(new SVMXC.SFM_WrapperDef.SFM_StringFieldMap(fieldDesc.getName(), fieldDesc.getLabel(), String.valueOf(fieldDesc.getType())));
                        }
                    }
                }
            }
            else{
                System.debug(LoggingLevel.WARN, 'Invalid Request for SFM_GetListOfQuestion method');
                objResponse.success = false;
                return objResponse;
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFM_GetListOfQuestion method: ' + ex.getMessage());
        }
        System.debug(LoggingLevel.WARN, 'Response of SFM_GetListOfQuestion method: ' + objResponse);
        return objResponse;
    }
    
    //This method will return all the Questions with the QBResponse options
    //Request requires single record OR list of (key as "RECORDID" and value as "SalesforceId")
    //Response will be SFM_Response in that we will return list of SFM_QuestionBank
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetQuestionInfo(SVMXC.SFM_WrapperDef.SFM_Request request){    
        System.debug(LoggingLevel.WARN, 'Request in SFM_GetQuestionInfo method : ' + request);
       
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
       
        objResponse.lstQuestionBank = new List<SVMXC.SFM_WrapperDef.SFM_QuestionBank>();
        objResponse.StringLstMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        objResponse.success = true;
        List<String> lstQuestionId = new List<String>();
        Map<String, List<SVMXC__QB_Response_Options__c>> mapQueIdAndResponseLst = new Map<String, List<SVMXC__QB_Response_Options__c>>();
        Map<String, SVMXC__QB_Response_Set__c> mapQueIDVsResponseSet = new Map<String, SVMXC__QB_Response_Set__c>();
        Map<String, SVMXC__Question_Bank__c> mapQueIDVsQuestion = new Map<String, SVMXC__Question_Bank__c>();
        Map<String,List<String>> questionTagsMap = new Map<String,List<String>>();
        Savepoint objSavePoint;
        
        //Apurva
         
        map<id,SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo> mapquestionIdCheckValRule = new map<id,SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo> ();
        try
        {        
             //Setting Save Point
            objSavePoint = Database.setSavepoint();
            if(request != null && request.stringListMap != null){
                for(SVMXC.SFM_WrapperDef.SFM_StringListMap stringMap : request.stringListMap){
                    if(stringMap.key != null && stringMap.key.toUpperCase() == 'RECORDID' && stringMap.valueList != null){
                        for(String strID : stringMap.valueList)
                        {
                            lstQuestionId.add(String.escapeSingleQuotes(strID));
                            System.debug(LoggingLevel.WARN, 'strID : ' + strID);
                        }
                    }
                }
                
                 System.debug(LoggingLevel.WARN, 'lstQuestionId : ' + lstQuestionId);
                 System.debug(LoggingLevel.WARN, 'lstQuestionId.size() : ' + lstQuestionId.size());
                if(lstQuestionId.size() > 0){
                    Set<String> setExistingResponseSetId = new Set<String>();
                    Map<String, SVMXC__QB_Response_Set__c> mapExistingResponseSetId = new Map<String, SVMXC__QB_Response_Set__c>();
                    Set<String> setQueId = new Set<String>();
                    List<SVMXC__Question_Bank__c> lstQuesBank = new List<SVMXC__Question_Bank__c>();
                    Map<String, SVMXC__SM_Default_Checklist_Response__c> mapQueIdVsDCRObject = new Map<String, SVMXC__SM_Default_Checklist_Response__c>();
                    Map<String, SVMXC.SFM_WrapperDef.SFM_DefaultResponseJSON> mapQueIdVsDRJSONObject = new Map<String, SVMXC.SFM_WrapperDef.SFM_DefaultResponseJSON>();
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstQuesBank = [SELECT Id, SVMXC__QuestionID__c, SVMXC__Question__c, SVMXC__Response_Type__c, SVMXC__Precision__c, SVMXC__Scale__c, SVMXC__Length__c, SVMXC__Short_Name__c, SVMXC__Response_Set__c, SVMXC__Help_URL__c,SVMXC__SM_Description_Required__c,SVMXC__SM_Show_In_Smart_Doc__c FROM SVMXC__Question_Bank__c WHERE Id IN : lstQuestionId];

                    //Fetching default response checklist records
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    List<SVMXC__SM_Default_Checklist_Response__c> lstDefaultCheckRespnse = [SELECT Id, SVMXC__SM_Question__c, SVMXC__SM_Default_Response__c, SVMXC__SM_Is_literal_Used__c FROM SVMXC__SM_Default_Checklist_Response__c WHERE SVMXC__SM_Question__c IN : lstQuestionId];
                    System.debug(LoggingLevel.WARN, 'lstDefaultCheckRespnse : ' + lstDefaultCheckRespnse);
                    for(SVMXC__SM_Default_Checklist_Response__c objDCR : lstDefaultCheckRespnse){
                        //creating map of question id and DCR object
                        mapQueIdVsDCRObject.put(objDCR.SVMXC__SM_Question__c, objDCR);

                        //creating map of question id and Default Response object after deserializing JSON
                        if(objDCR.SVMXC__SM_Default_Response__c != null){
                            SVMXC.SFM_WrapperDef.SFM_DefaultResponseJSON objDRjson = (SVMXC.SFM_WrapperDef.SFM_DefaultResponseJSON)JSON.deserialize(objDCR.SVMXC__SM_Default_Response__c, SVMXC.SFM_WrapperDef.SFM_DefaultResponseJSON.class);
                            mapQueIdVsDRJSONObject.put(objDCR.SVMXC__SM_Question__c, objDRjson);
                        }
                    }
                    System.debug(LoggingLevel.WARN, 'mapQueIdVsDCRObject : ' + mapQueIdVsDCRObject);
                    System.debug(LoggingLevel.WARN, 'mapQueIdVsDRJSONObject : ' + mapQueIdVsDRJSONObject);
                    
                    for(SVMXC__Question_Bank__c objQB : lstQuesBank){
                        if(objQB.SVMXC__Response_Type__c == 'Checkbox' || objQB.SVMXC__Response_Type__c == 'Picklist' || objQB.SVMXC__Response_Type__c == 'Multi-select Picklist' || objQB.SVMXC__Response_Type__c == 'Radio Button'){
                            if(objQB.SVMXC__Response_Set__c == null)
                                setQueId.add(objQB.id);
                            else
                                setExistingResponseSetId.add(objQB.SVMXC__Response_Set__c);
                        }
                    }
                    
                    if(setExistingResponseSetId != null && setExistingResponseSetId.size() > 0){
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        for(SVMXC__QB_Response_Set__c objRespSet : [SELECT Id, Name, SVMXC__Response_Set_Values__c FROM SVMXC__QB_Response_Set__c WHERE Id IN: setExistingResponseSetId])
                            mapExistingResponseSetId.put(objRespSet.id, objRespSet);
                    }
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(SVMXC__QB_Response_Options__c objQBRes : [SELECT Id, SVMXC__Question_Bank__c, SVMXC__Response__c, SVMXC__Sequence__c FROM SVMXC__QB_Response_Options__c WHERE SVMXC__Question_Bank__c IN : lstQuestionId]){
                        if(!mapQueIdAndResponseLst.containsKey(objQBRes.SVMXC__Question_Bank__c))
                            mapQueIdAndResponseLst.put(objQBRes.SVMXC__Question_Bank__c, new List<SVMXC__QB_Response_Options__c>());
                        mapQueIdAndResponseLst.get(objQBRes.SVMXC__Question_Bank__c).add(objQBRes);
                    }

                    /*
                     * To get all the Tag     
                    */
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(SVMXC__SM_Tag_Element__c tagElement : [SELECT Id,SVMXC__SM_Target_Object__c,SVMXC__SM_Tag_Definition__r.Name FROM SVMXC__SM_Tag_Element__c WHERE SVMXC__SM_Target_Object__c IN : lstQuestionId]){
                        List<String> tagSet = new List<String>();
                        if(questionTagsMap.containsKey(tagElement.SVMXC__SM_Target_Object__c))
                            tagSet = questionTagsMap.get(tagElement.SVMXC__SM_Target_Object__c); 
                        tagSet.add(tagElement.SVMXC__SM_Tag_Definition__r.Name);  
                        questionTagsMap.put(tagElement.SVMXC__SM_Target_Object__c,tagSet);  
                    }

//Apurva
                    
                    String ChecklistId = NULL;
                    SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo QuestionValidationRuleInfo = request.QuestionValidationRuleInfo;
                    if(QuestionValidationRuleInfo!= null && QuestionValidationRuleInfo.checklistId != null)
                    ChecklistId = String.escapeSingleQuotes(QuestionValidationRuleInfo.checklistId);
                
                    map<id,id> mapValidQuestionIdValidationRuleId = new map<id,id>();
                    //map<id,id> mapQuestionIdProcBizRule_ChecklistId = new map<id,id>();
                    //map<id,id> mapQuestionIdProcBizRuleId = new map<id,id>();
                    list<SVMXC__ServiceMax_Processes__c> lstProcBizRule = new list<SVMXC__ServiceMax_Processes__c>();
                    list<SVMXC__ServiceMax_Processes__c> lstProcBizRule_Checklist = new list<SVMXC__ServiceMax_Processes__c>();
                    map<id,SVMXC__ServiceMax_Processes__c> mapValidationRuleIdNValidation ;
                    
                    
                    list<string> lstValId = new list<string>();
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstProcBizRule = [Select Id, SVMXC__Process1__c, SVMXC__Question_Bank__c From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = 'QB Validation' AND SVMXC__Question_Bank__c IN: lstQuestionId]; 
                    for(SVMXC__ServiceMax_Processes__c obj :lstProcBizRule)
                    {
                        if(obj.SVMXC__Process1__c != null)
                            lstValId.add(obj.SVMXC__Process1__c);                      
                         
                        mapValidQuestionIdValidationRuleId.put(obj.SVMXC__Question_Bank__c, obj.SVMXC__Process1__c);
                    }
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    mapValidationRuleIdNValidation = new map<id,SVMXC__ServiceMax_Processes__c>([Select id,SVMXC__Name__c, SVMXC__ProcessID__c,  SVMXC__Description__c, SVMXC__Question_Bank__c,  SVMXC__Advance_Expression__c, SVMXC__Parent_Error_Msg__c, SVMXC__Process1__c, SVMXC__Message_Type__c From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = 'Business Rule' and Id IN: lstValId]);
                    /* Retrieving all the expressions for the corresponding validation rule */
                    if(lstValId != null && lstValId.size()>0)
                    {
                        map<id, list<SVMXC__ServiceMax_Config_Data__c>> mapChckValidnRuleIdExplst = new map<id, list<SVMXC__ServiceMax_Config_Data__c>>();
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        for(SVMXC__ServiceMax_Config_Data__c ChecklistValidationRuleExpr : [Select Id, SVMXC__Description__c, SVMXC__Parameter_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Object_Name__c, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Internal_Value__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN: lstValId ORDER BY SVMXC__Sequence__c])
                        {
                            if(ChecklistValidationRuleExpr != null && !mapChckValidnRuleIdExplst.containsKey(ChecklistValidationRuleExpr.SVMXC__Expression_Rule__c))
                                mapChckValidnRuleIdExplst.put(ChecklistValidationRuleExpr.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                            mapChckValidnRuleIdExplst.get(ChecklistValidationRuleExpr.SVMXC__Expression_Rule__c).add(ChecklistValidationRuleExpr);
                        }
                        for(string valid: mapValidationRuleIdNValidation.keyset())
                        {  
                            SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo  objCheckValRule  = new SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo();
                            if(mapChckValidnRuleIdExplst.containsKey(valid) && mapChckValidnRuleIdExplst.get(valid) != NULL)
                            {
                                objCheckValRule = new SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo(mapValidationRuleIdNValidation.get(valid),mapChckValidnRuleIdExplst.get(valid)); 
                                mapquestionIdCheckValRule.put(valid,objCheckValRule);
                            }
                        }
                    }
                    
                    if(setQueId != null && setQueId.size() > 0 && mapQueIdAndResponseLst != null && mapQueIdAndResponseLst.size() > 0){
                        //Creating a unique response set name
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        List<SVMXC__QB_Response_Set__c> lstResponseSetId = [SELECT Id, Name FROM SVMXC__QB_Response_Set__c WHERE (Name LIKE 'Response-Set-%') ORDER BY Name DESC NULLS LAST];
                        Integer intNewNumber = 1;
                        if(lstResponseSetId != null && lstResponseSetId.size() > 0){
                            Integer intNumberPart = Integer.valueOf(lstResponseSetId[0].Name.substring(13));
                            intNewNumber = intNumberPart + 1;
                        }
                        for(String queId : mapQueIdAndResponseLst.keyset()){
                            if(setQueId.contains(queId)){
                                String strResponseValue = '';
                                List<SVMXC__QB_Response_Options__c> lstTemp = mapQueIdAndResponseLst.get(queId);
                                for(SVMXC__QB_Response_Options__c objResOpt : lstTemp)
                                    strResponseValue += objResOpt.SVMXC__Response__c + ';';
                                
                                SVMXC__QB_Response_Set__c objResSet = new SVMXC__QB_Response_Set__c();
                                objResSet.Name = 'Response-Set-'+intNewNumber;
                                objResSet.SVMXC__Response_Set_Values__c = strResponseValue;
                                mapQueIDVsResponseSet.put(queId, objResSet);
                                intNewNumber++;
                            }
                        }
                        if(mapQueIDVsResponseSet != null && mapQueIDVsResponseSet.size() > 0){
                            insert mapQueIDVsResponseSet.values();
                            
                            for(SVMXC__Question_Bank__c objQB : lstQuesBank){
                                if(mapQueIDVsResponseSet.containsKey(objQB.id)){
                                    objQB.SVMXC__Response_Set__c = mapQueIDVsResponseSet.get(objQB.id).id;
                                    mapQueIDVsQuestion.put(objQB.id, objQB);
                                }
                            }
                        }                       
                        if(mapQueIDVsQuestion != null && mapQueIDVsQuestion.size() > 0)
                            update mapQueIDVsQuestion.values();

                        System.debug(LoggingLevel.WARN, 'questionTagsMap : ' + questionTagsMap) ; 
                        for(SVMXC__Question_Bank__c objQB : lstQuesBank){
                            List<String> tempTagsList = questionTagsMap.containsKey(objQB.Id)?questionTagsMap.get(objQB.Id):new List<String>();
                            //Apurva
                            //Adding Validation info associated to each question
                            string validationRuleId = null;
                            
                            if(mapValidQuestionIdValidationRuleId != null && mapValidQuestionIdValidationRuleId.containskey(objQB.Id))
                                validationRuleId = mapValidQuestionIdValidationRuleId.get(objQB.Id);
                            system.debug('validationRuleId: '+validationRuleId);
                            
                            system.debug('objQB.Id: '+objQB.Id);
                            SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo  objCheckValRule = new SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo();
                            if(validationRuleId != null &&  mapquestionIdCheckValRule != null)
                                objCheckValRule = mapquestionIdCheckValRule.containsKey(validationRuleId)?mapquestionIdCheckValRule.get(validationRuleId):objCheckValRule;
                              if(mapquestionIdCheckValRule.containsKey(validationRuleId))
                            system.debug('objCheckValRule: '+objCheckValRule);

                            //--------Adding Deafult checklist response info to each question--------
                            SVMXC__SM_Default_Checklist_Response__c objDCResponse;
                            SVMXC.SFM_WrapperDef.SFM_DefaultResponseJSON objDResponseJSON;
                            if(mapQueIdVsDCRObject.size() > 0 && mapQueIdVsDCRObject.containskey(objQB.id)){
                                objDCResponse = mapQueIdVsDCRObject.get(objQB.id);
                            }
                            if(mapQueIdVsDRJSONObject.size() > 0 && mapQueIdVsDRJSONObject.containskey(objQB.id)){
                                objDResponseJSON = mapQueIdVsDRJSONObject.get(objQB.id);
                            }
                            //--------Adding Deafult checklist response info to each question--------
                           
                            if( mapQueIDVsResponseSet != null && !mapQueIDVsResponseSet.containsKey(objQB.id) && objQB.SVMXC__Response_Set__c == null){
                                objResponse.lstQuestionBank.add(new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQB, null, null, tempTagsList,objCheckValRule, objDCResponse, objDResponseJSON));
                            }
                            else if(mapQueIDVsResponseSet != null &&  !mapQueIDVsResponseSet.containsKey(objQB.id) && objQB.SVMXC__Response_Set__c != null && mapExistingResponseSetId != null && mapExistingResponseSetId.containsKey(objQB.SVMXC__Response_Set__c)){
                                objResponse.lstQuestionBank.add(new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQB, mapQueIdAndResponseLst.get(objQB.Id), mapExistingResponseSetId.get(objQB.SVMXC__Response_Set__c),tempTagsList,objCheckValRule, objDCResponse, objDResponseJSON));
                            }
                            else if(mapQueIDVsResponseSet != null &&  mapQueIDVsResponseSet.containsKey(objQB.id) && mapQueIDVsResponseSet.get(objQB.id) != null && mapQueIDVsQuestion != null && mapQueIDVsQuestion.containsKey(objQB.id)){
                                objResponse.lstQuestionBank.add(new SVMXC.SFM_WrapperDef.SFM_QuestionBank(mapQueIDVsQuestion.get(objQB.id), mapQueIdAndResponseLst.get(objQB.Id), mapQueIDVsResponseSet.get(objQB.id),tempTagsList,objCheckValRule, objDCResponse, objDResponseJSON));
                            }
                        
                        }
                    }
                    else{
                        Set<String> setResponseSet = new Set<String>();
                        for(SVMXC__Question_Bank__c objQB : lstQuesBank){
                            setResponseSet.add(objQB.SVMXC__Response_Set__c);
                        }
                        Map<Id, SVMXC__QB_Response_Set__c> mapIdVsRespSet = new Map<Id, SVMXC__QB_Response_Set__c>();
                        for(SVMXC__QB_Response_Set__c objResSett : [SELECT Id, Name, SVMXC__Response_Set_Values__c FROM SVMXC__QB_Response_Set__c WHERE Id IN: setResponseSet])
                            mapIdVsRespSet.put(objResSett.id, objResSett);
                        System.debug(LoggingLevel.WARN, 'questionTagsMap : ' + questionTagsMap) ; 
                        for(SVMXC__Question_Bank__c objQB : lstQuesBank){

                            //--------Adding Deafult checklist response info to each question--------
                            SVMXC__SM_Default_Checklist_Response__c objDCResponse;
                            SVMXC.SFM_WrapperDef.SFM_DefaultResponseJSON objDResponseJSON;
                            if(mapQueIdVsDCRObject.size() > 0 && mapQueIdVsDCRObject.containskey(objQB.id)){
                                objDCResponse = mapQueIdVsDCRObject.get(objQB.id);
                            }
                            if(mapQueIdVsDRJSONObject.size() > 0 && mapQueIdVsDRJSONObject.containskey(objQB.id)){
                                objDResponseJSON = mapQueIdVsDRJSONObject.get(objQB.id);
                            }
                            //--------Adding Deafult checklist response info to each question--------

                            List<String> tempTagsList = questionTagsMap.containsKey(objQB.Id)?questionTagsMap.get(objQB.Id):new List<String>();  
                            //Apurva
                            //Adding Validation info associated to each question
                            string validationRuleId = null;
                            
                            if(mapValidQuestionIdValidationRuleId != null && mapValidQuestionIdValidationRuleId.containskey(objQB.Id))
                                validationRuleId = mapValidQuestionIdValidationRuleId.get(objQB.Id);
                        system.debug('validationRuleId: '+validationRuleId);
                            system.debug('objQB.Id: '+objQB.Id);
                            
                            SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo  objCheckValRule = new SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo();
                            if( validationRuleId != null && mapquestionIdCheckValRule != null)
                                objCheckValRule = mapquestionIdCheckValRule.containsKey(validationRuleId)?mapquestionIdCheckValRule.get(validationRuleId):objCheckValRule;    

                            
                           if((mapquestionIdCheckValRule != null) && mapquestionIdCheckValRule.containsKey(validationRuleId))
                           system.debug('objCheckValRule: '+objCheckValRule);
                           // system.debug('objCheckValRule: '+objCheckValRule);
                            
                            if( mapIdVsRespSet != null && !mapIdVsRespSet.containsKey(objQB.SVMXC__Response_Set__c))
                            {
                                objResponse.lstQuestionBank.add(new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQB, null, null,tempTagsList,objCheckValRule, objDCResponse, objDResponseJSON));
                                system.debug('Added here1: '+objResponse);
                            }
                            else if(mapIdVsRespSet != null && mapIdVsRespSet.get(objQB.SVMXC__Response_Set__c) != null)
                            {
                                objResponse.lstQuestionBank.add(new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQB, mapQueIdAndResponseLst.get(objQB.Id), mapIdVsRespSet.get(objQB.SVMXC__Response_Set__c),tempTagsList,objCheckValRule, objDCResponse, objDResponseJSON));
                                system.debug('Added here2: '+objResponse);
                                
                            }
                        }
                        for(SFM_WrapperDef.SFM_QuestionBank obj :objResponse.lstQuestionBank)
                                system.debug('objResponse.lstQuestionBank: '+obj);
                    }
                }
            }
        }
        catch(Exception ex){
            Database.rollback(objSavePoint);
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFM_GetQuestionInfo method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'Exception in SFM_GetQuestionInfo method: ' + ex.getStackTraceString());
        }
        System.debug(LoggingLevel.WARN, 'Response of SFM_GetQuestionInfo method: ' + objResponse);
        return objResponse;
    }
    
    //This method will delete Question Info with Response options only those that are not associated with any SFM process
    //Request requires StringMap to be populated with Salesforce RECORDID
    //Response will return Success with message OR Failure with message having list of SFM process which are using this question
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_DeleteQuestion(SVMXC.SFM_WrapperDef.SFM_Request request){
        System.debug(LoggingLevel.WARN, 'Request in SFM_DeleteQuestion method : ' + request);
        String strRecordId = '';
        List<SVMXC__Page_Layout_Detail__c> lstPageLayoutDetail = new List<SVMXC__Page_Layout_Detail__c>();
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        Savepoint objSavePoint;
        try{
            //Setting save point
            objSavePoint = Database.setSavepoint();
            if(request != null && request.stringMap != null){
                for(SVMXC.SFM_WrapperDef.SFM_StringMap stringMap : request.stringMap){
                    if(stringMap.key != null && stringMap.key.toUpperCase() == 'RECORDID' && stringMap.value != null)
                        strRecordId = String.escapeSingleQuotes(stringMap.value);
                }
                if(strRecordId != null && strRecordId != ''){
                    //Querying page layout detail record which has given question salesforce id
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstPageLayoutDetail = [SELECT SVMXC__Page_Layout__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Detail_Type__c = 'Question' AND SVMXC__Question__c =: strRecordId];
                    if(lstPageLayoutDetail != null && lstPageLayoutDetail.size() > 0){
                        Set<String> setPageLayoutID = new Set<String>();
                        for(SVMXC__Page_Layout_Detail__c obj : lstPageLayoutDetail)
                            setPageLayoutID.add(obj.SVMXC__Page_Layout__c);
                        
                        //Querying Process record which has setPageLayoutID ids.
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        List<SVMXC__ServiceMax_Processes__c> lstProcess = [SELECT SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Target Manager' AND SVMXC__Purpose__c = 'CHECKLIST' AND SVMXC__Page_Layout__c IN : setPageLayoutID];
                        
                        //Creating a list of Process name which using given question
                        List<String> lstAssociatedProcessName = new List<String>();
                        for(SVMXC__ServiceMax_Processes__c objPro : lstProcess)
                            lstAssociatedProcessName.add(objPro.SVMXC__Name__c);
                        if(lstAssociatedProcessName != null && lstAssociatedProcessName.size()>0)
                            lstAssociatedProcessName.sort();
                        objResponse.success = false;
                        objResponse.message = System.Label.CONF041_TAG041;//This question cannot be deleted because it is in use by the following checklists:
                        objResponse.resultIds = lstAssociatedProcessName;
                    }
                    else{
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        List<SVMXC__QB_Response_Options__c> lstResponseOpt = [SELECT Id FROM SVMXC__QB_Response_Options__c WHERE SVMXC__Question_Bank__c =: strRecordId];
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        List<SVMXC__Question_Bank__c> lstQuestionBank = [SELECT Id FROM SVMXC__Question_Bank__c WHERE Id =: strRecordId];
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        List<SVMXC__SM_Tag_Element__c> lstQuestionTags = [SELECT Id,SVMXC__SM_Tag_Definition__c FROM SVMXC__SM_Tag_Element__c WHERE SVMXC__SM_Target_Object__c =: strRecordId];
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        List<SVMXC__SM_Default_Checklist_Response__c> lstDCResponse = [SELECT Id FROM SVMXC__SM_Default_Checklist_Response__c WHERE SVMXC__SM_Question__c =: strRecordId];
                        List<SVMXC__SM_Tag_Definition__c> delLstTagDefinition;
                        Set<Id> tagDefinitionIds = new Set<Id>();
                        for(SVMXC__SM_Tag_Element__c elementRec : lstQuestionTags){
                            tagDefinitionIds.add(elementRec.SVMXC__SM_Tag_Definition__c);
                        }

                        if(lstResponseOpt != null && lstResponseOpt.size() > 0){
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            delete lstResponseOpt;
                        }
                        if(!lstDCResponse.isEmpty()){
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            delete lstDCResponse;
                        }
                        if(lstQuestionBank != null && lstQuestionBank.size() > 0){
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            delete lstQuestionBank;
                        }
                        if(!lstQuestionTags.isEmpty()){
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            delete lstQuestionTags;
                        }
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        List<SVMXC__SM_Tag_Definition__c> lstTagDefinitions = [SELECT Id,(SELECT Id from SVMXC__SM_Tag_Elements__r) from SVMXC__SM_Tag_Definition__c WHERE Id IN : tagDefinitionIds];                        
                        if(!lstTagDefinitions.isEmpty()){    
                            delLstTagDefinition = new List<SVMXC__SM_Tag_Definition__c>();
                            for(SVMXC__SM_Tag_Definition__c tagDef : lstTagDefinitions){
                                if(tagDef.SVMXC__SM_Tag_Elements__r.isEmpty())
                                    delLstTagDefinition.add(tagDef);
                            }
                        }  

                        if(delLstTagDefinition != null && !delLstTagDefinition.isEmpty())
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA                           
                            delete delLstTagDefinition;
                        objResponse.success = true;
                        objResponse.resultIds = new List<String>{strRecordId};
                        objResponse.message = System.Label.COMM001_TAG052;//Record(s) deleted successfully
                    }
                }
            }
            else{
                objResponse.success = false;
                objResponse.message = System.Label.CONF041_TAG042;//Invalid Request
            }
        }
        catch(Exception ex){
            Database.rollback(objSavePoint);
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFM_DeleteQuestion method : ' + ex.getMessage());
        }
        System.debug(LoggingLevel.WARN, 'Response of SFM_DeleteQuestion method : ' + objResponse);
        return objResponse;
    }
    
    //This method will save Question Info with Response set
    //Request requires objQuestionBank to be populated with Question and Response Set
    //Response will return Success/Failure, message and list of Question Bank
    /*public SVMXC.SFM_WrapperDef.SFM_Response SFM_SaveQuestionInfo(SVMXC.SFM_WrapperDef.SFM_Request request){
        System.debug(LoggingLevel.WARN, 'Request in SFM_SaveQuestionInfo method : ' + request);
        String strResponseMessage = '';
        Boolean responseSuccess = true;
        Savepoint objSavePoint;
        String actualQueId = 'QB000001';
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c(); 
        SVMXC__QB_Response_Set__c objQuestionResponseSet = new SVMXC__QB_Response_Set__c();
        List<SVMXC.SFM_WrapperDef.SFM_QuestionBank> lstQBWrap = new List<SVMXC.SFM_WrapperDef.SFM_QuestionBank>();
        SVMXC.SFM_WrapperDef.SFM_Response objQBResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC.SFM_WrapperDef.SFM_Response respChecklistValidation = new SVMXC.SFM_WrapperDef.SFM_Response();
        try{
            objSavePoint = Database.setSavepoint();
             System.debug(LoggingLevel.WARN, 'request.lstQuestionBank : ' + request.lstQuestionBank);
            if(request != null && request.lstQuestionBank != null && request.lstQuestionBank.size() > 0){
                SVMXC.SFM_WrapperDef.SFM_QuestionBank objQB = request.lstQuestionBank[0];
                System.debug(LoggingLevel.WARN, 'objQB : ' + objQB);
                System.debug(LoggingLevel.WARN, 'objQB.question : ' + objQB.question);
                if(objQB != null && objQB.question != null){
                    objQuestionBank = objQB.question;
                    System.debug(LoggingLevel.WARN, 'objQuestionBank : ' + objQuestionBank);
                    if(objQB.questionResponseSet != null)
                        objQuestionResponseSet = objQB.questionResponseSet;

                    //Creating question id
                    string str='SELECT SVMXC__QuestionID__c FROM SVMXC__Question_Bank__c WHERE NOT( (SVMXC__QuestionID__c LIKE '+'\'QB-%\') OR(SVMXC__QuestionID__c LIke '+ '\'QB'+'\\'+'_%\''+')) ORDER BY SVMXC__QuestionID__c DESC NULLS LAST';
                    //List<SVMXC__Question_Bank__c> lstQueID = [SELECT SVMXC__QuestionID__c FROM SVMXC__Question_Bank__c WHERE (NOT SVMXC__QuestionID__c LIKE 'QB-%')AND (NOT SVMXC__QuestionID__c LIKE 'QB\_%') ORDER BY SVMXC__QuestionID__c DESC NULLS LAST];
                    List<SVMXC__Question_Bank__c> lstQueID = database.query(str);
                     System.debug(LoggingLevel.WARN, 'lstQueID : ' + lstQueID);
                    if(lstQueID != null && lstQueID.size() > 0){
                         System.debug(LoggingLevel.WARN,'SVMXC__QuestionID__c.substring(2) : '+lstQueID[0].SVMXC__QuestionID__c.substring(2));
                        Integer intNumberPart = Integer.valueOf(lstQueID[0].SVMXC__QuestionID__c.substring(2));
                        Integer intNewNumber = intNumberPart + 1;
                        Integer noLength = String.valueOf(intNewNumber).length();
                        String strTemp = '';
                        for(Integer i = noLength; i<=5; i++)
                            strTemp += '0';
                        actualQueId = 'QB' + strTemp + intNewNumber;
                        System.debug(LoggingLevel.WARN, 'actualQueId : ' + actualQueId);
                       
                    }
                    System.debug(LoggingLevel.WARN, 'actualQueId : ' + actualQueId);
                    if(objQuestionBank != null ){
                        if(objQuestionResponseSet != null && (objQuestionBank.SVMXC__Response_Type__c == 'Checkbox' || objQuestionBank.SVMXC__Response_Type__c == 'Picklist' || objQuestionBank.SVMXC__Response_Type__c == 'Multi-select Picklist' || objQuestionBank.SVMXC__Response_Type__c == 'Radio Button')){
                            
                            //--------Handling Duplicate Response set--------
                            if(objQuestionResponseSet.Name != null && objQuestionResponseSet.Name != ''){
                                List<SVMXC__QB_Response_Set__c> lstResponseSetTemp = [SELECT Id FROM SVMXC__QB_Response_Set__c WHERE Name =: objQuestionResponseSet.Name];
                                if(lstResponseSetTemp != null && lstResponseSetTemp.size() > 0){
                                    if(objQuestionResponseSet.id == null || (lstResponseSetTemp.size() == 1 && objQuestionResponseSet.id != null && objQuestionResponseSet.id != lstResponseSetTemp[0].id)){
                                        objQBResp.success = false;
                                        objQBResp.message = System.Label.CONF041_TAG043;//Please enter unique Response Set name.
                                        objQBResp.messageType = 'DUPLICATE_RESPONSE_SET';
                                        objQBResp.lstQuestionBank = null;
                                        System.debug(LoggingLevel.WARN, 'Response of SFM_SaveQuestionInfo method : ' + objQBResp);
                                        return objQBResp;
                                    }
                                }
                            }
                            //--------Handling Duplicate Response set--------
                            
                            upsert objQuestionResponseSet;
                            if(objQuestionResponseSet != null && objQuestionResponseSet.id != null)
                                objQuestionBank.SVMXC__Response_Set__c = objQuestionResponseSet.id;
                        }
                        else{
                            objQuestionBank.SVMXC__Response_Set__c = null;
                        }
                        if(objQuestionBank.SVMXC__QuestionID__c == null || objQuestionBank.SVMXC__QuestionID__c == '')
                            objQuestionBank.SVMXC__QuestionID__c = actualQueId;
                        
                        System.debug(LoggingLevel.WARN,'QuestionOBJ : '+objQuestionBank);
                        upsert objQuestionBank;
             
                        if(objQB.tagsList != null ){
                            Map<String,Id> tagsNameMap = new Map<String,Id>();    
                            Set<String> tagElementSet = new Set<String>();
                            Set<String> tagDeleteSet = new Set<String>();
                            List<SVMXC__SM_Tag_Element__c> tagElementsList = new List<SVMXC__SM_Tag_Element__c>();
                            List<SVMXC__SM_Tag_Definition__c> tagDefList = new List<SVMXC__SM_Tag_Definition__c>();  
                            List<SVMXC__SM_Tag_Element__c> tagDelList = new List<SVMXC__SM_Tag_Element__c>();                               
                            Set<String> currentTagsList = new Set<String>();

                            if(!objQB.tagsList.isEmpty()){
                                System.debug(LoggingLevel.INFO, 'TagsList : ' + objQB.tagsList);
                                for(String tagValue : objQB.tagsList){
                                    tagValue = tagValue.trim();                                    
                                    if(!String.isBlank(tagValue)){
                                       currentTagsList.add(tagValue); 
                                    }
                                }
                                for(SVMXC__SM_Tag_Definition__c tagDef : [SELECT Id,Name FROM SVMXC__SM_Tag_Definition__c WHERE Name IN : currentTagsList]){
                                    tagsNameMap.put(tagDef.Name,tagDef.Id);
                                }
                            }

                            if(objQuestionBank.Id != null){
                                
                                for(SVMXC__SM_Tag_Element__c tagElement : [SELECT Id,SVMXC__SM_Tag_Definition__r.Name FROM SVMXC__SM_Tag_Element__c WHERE SVMXC__SM_Target_Object__c =: objQuestionBank.Id]){
                                    if(currentTagsList.contains(tagElement.SVMXC__SM_Tag_Definition__r.Name))
                                        tagElementSet.add(tagElement.SVMXC__SM_Tag_Definition__r.Name);
                                    else{ 
                                        tagDelList.add(tagElement);    
                                        tagDeleteSet.add(tagElement.SVMXC__SM_Tag_Definition__r.Name);
                                    }    
                                }

                                for(String tagName : currentTagsList){
                                    if(tagsNameMap.containsKey(tagName)){
                                        if(!tagElementSet.contains(tagName)){
                                            SVMXC__SM_Tag_Element__c tagElement = new SVMXC__SM_Tag_Element__c();
                                            //tagElement.Name = tagName;
                                            tagElement.SVMXC__SM_Tag_Definition__c = tagsNameMap.get(tagName);
                                            tagElement.SVMXC__SM_Target_Object__c = objQuestionBank.Id;
                                            tagElementsList.add(tagElement);
                                        }
                                    }else{
                                        SVMXC__SM_Tag_Definition__c tagDef = new SVMXC__SM_Tag_Definition__c(Name = tagName);
                                        tagDefList.add(tagDef);
                                    } 
                                }                                
                            }
                            if(!tagDefList.isEmpty()){
                                insert tagDefList;
                                for(SVMXC__SM_Tag_Definition__c tagDefnRec : tagDefList){
                                    SVMXC__SM_Tag_Element__c tagElement = new SVMXC__SM_Tag_Element__c();
                                    //tagElement.Name = tagDefnRec.Name;
                                    tagElement.SVMXC__SM_Tag_Definition__c = tagDefnRec.Id;
                                    tagElement.SVMXC__SM_Target_Object__c = objQuestionBank.Id;
                                    tagElementsList.add(tagElement);
                                }
                            }

                            if(!tagElementsList.isEmpty())
                                insert tagElementsList; 
                            if(!tagDelList.isEmpty()){
                                delete tagDelList;
                                tagDefList.clear();
                                for(SVMXC__SM_Tag_Definition__c tagDefnRec : [SELECT Id,(SELECT Id from SVMXC__SM_Tag_Elements__r) from SVMXC__SM_Tag_Definition__c WHERE Name IN : tagDeleteSet]){
                                    if(tagDefnRec.SVMXC__SM_Tag_Elements__r.isEmpty())
                                       tagDefList.add(tagDefnRec);
                                } 
                                if(!tagDefList.isEmpty())
                                    delete tagDefList;
                            }  
                        }                         
  
                    System.debug(LoggingLevel.WARN,'request.QuestionValidationRuleInfo : '+request.QuestionValidationRuleInfo);
                        
                        
                        
                        responseSuccess = true;
                        strResponseMessage = System.Label.COMM001_TAG058;//Record(s) saved successfully
System.debug(LoggingLevel.WARN,'request.QuestionValidationRuleInfo : '+request.QuestionValidationRuleInfo);
                        if(request.QuestionValidationRuleInfo != null)
                        {
                            //request.QuestionValidationRuleInfo.QuestionValidationRule.SVMXC__Question_Bank__c = objQuestionBank.Id;
                            request.QuestionValidationRuleInfo.questionBankId = objQuestionBank.Id;
                            request.QuestionValidationRuleInfo.questionId = objQuestionBank.SVMXC__QuestionID__c;
                            
                            respChecklistValidation = SFM_SaveQuestionValidationRules(request);
                            if(respChecklistValidation.success == false )
                            {
                                responseSuccess = false;
                                strResponseMessage = respChecklistValidation.message;
                                Database.rollback(objSavePoint);
                            }
                            else if(objQuestionBank != null)
                            {
                                if(respChecklistValidation != null && respChecklistValidation.QuestionValidationRuleInfo != null )                          
                                    lstQBWrap.add(new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQuestionBank, null, objQuestionResponseSet,null, respChecklistValidation.QuestionValidationRuleInfo));                             
                                    
                            }
                        }
                        else if(objQuestionBank != null) 
                            lstQBWrap.add(new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQuestionBank, null, objQuestionResponseSet));
                         
                    }
                }
            }
            else{
                responseSuccess = false;
                strResponseMessage = System.Label.CONF041_TAG042;//Invalid Request
            }
            
        }
        catch(DMLException ex){
            Database.rollback(objSavePoint);
            responseSuccess = false;
            strResponseMessage = String.valueOf(ex.getDmlType(0));
            System.debug(LoggingLevel.WARN, 'DMLException in SFM_SaveQuestionInfo method : ' + ex.getDmlMessage(0));            
        }
        catch(Exception ex){
            Database.rollback(objSavePoint);
            responseSuccess = false;
            strResponseMessage = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFM_SaveQuestionInfo method Stack Trace: ' + ex.getStackTraceString());
            System.debug(LoggingLevel.WARN, 'Exception in SFM_SaveQuestionInfo method : ' + ex.getMessage());
        }
        objQBResp.success = responseSuccess;
        objQBResp.message = strResponseMessage;
        objQBResp.lstQuestionBank = lstQBWrap;
        
        System.debug(LoggingLevel.WARN, 'Response of SFM_SaveQuestionInfo method : ' + objQBResp);
        return objQBResp;
    } */

    public SVMXC.SFM_WrapperDef.SFM_Response SFM_SaveQuestionInfo(SVMXC.SFM_WrapperDef.SFM_Request request){
        System.debug(LoggingLevel.WARN, 'Request in SFM_SaveQuestionInfo method : ' + request);
        String strResponseMessage = '';
        Boolean responseSuccess = true;
        Savepoint objSavePoint;
        boolean isExitCriteriaAssociated;
        String actualQueId = 'QB000001';
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c(); 
        SVMXC__QB_Response_Set__c objQuestionResponseSet = new SVMXC__QB_Response_Set__c();
        List<SVMXC.SFM_WrapperDef.SFM_QuestionBank> lstQBWrap = new List<SVMXC.SFM_WrapperDef.SFM_QuestionBank>();
        SVMXC.SFM_WrapperDef.SFM_Response objQBResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC.SFM_WrapperDef.SFM_Response respChecklistValidation = new SVMXC.SFM_WrapperDef.SFM_Response();
        List<String> lstAssociatedProcessName = new List<String>();
        String strClientType = request.clientType;
        try{
            objSavePoint = Database.setSavepoint();
            System.debug(LoggingLevel.WARN, 'request.lstQuestionBank : ' + request.lstQuestionBank);
            System.debug(LoggingLevel.WARN, 'request.clientType : ' + request.clientType);
            
            if(request != null && request.lstQuestionBank != null && request.lstQuestionBank.size() > 0){
                SVMXC.SFM_WrapperDef.SFM_QuestionBank objQB = request.lstQuestionBank[0];
                System.debug(LoggingLevel.WARN, 'objQB : ' + objQB);
                System.debug(LoggingLevel.WARN, 'objQB.question : ' + objQB.question);
                if(objQB != null && objQB.question != null){
                    objQuestionBank = objQB.question;
                    System.debug(LoggingLevel.WARN, 'objQuestionBank : ' + objQuestionBank);
                    if(objQB.questionResponseSet != null)
                        objQuestionResponseSet = objQB.questionResponseSet;

                    //Creating question id
                    string str='SELECT SVMXC__QuestionID__c FROM SVMXC__Question_Bank__c WHERE NOT( (SVMXC__QuestionID__c LIKE '+'\'QB-%\') OR(SVMXC__QuestionID__c LIke '+ '\'QB'+'\\'+'_%\''+')) ORDER BY CreatedDate DESC NULLS LAST';


                    //List<SVMXC__Question_Bank__c> lstQueID = [SELECT SVMXC__QuestionID__c FROM SVMXC__Question_Bank__c WHERE (NOT SVMXC__QuestionID__c LIKE 'QB-%')AND (NOT SVMXC__QuestionID__c LIKE 'QB\_%') ORDER BY SVMXC__QuestionID__c DESC NULLS LAST];
                    
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    List<SVMXC__Question_Bank__c> lstQueID = database.query(str);
                     System.debug(LoggingLevel.WARN, 'lstQueID : ' + lstQueID);
                     
                    if(lstQueID != null && lstQueID.size() > 0){
                        Integer subStringIndex = 2;
                        String lastQuestionId = lstQueID[0].SVMXC__QuestionID__c;
                        if( lastQuestionId.length() == ( 'QB000001'.length() + UserInfo.getOrganizationId().length() ) ) {
                            //subStringIndex = UserInfo.getOrganizationId().length() + subStringIndex;
                            lastQuestionId = lastQuestionId.left(lastQuestionId.length() - UserInfo.getOrganizationId().length());
                        }
                        System.debug(LoggingLevel.WARN,'SVMXC__QuestionID__c.substring() : '+lastQuestionId.substring(subStringIndex));
                        Integer intNumberPart = Integer.valueOf(lastQuestionId.substring(subStringIndex));
                        Integer intNewNumber = intNumberPart + 1;
                        Integer noLength = String.valueOf(intNewNumber).length();
                        String strTemp = '';
                        for(Integer i = noLength; i<=5; i++)
                            strTemp += '0';
                        actualQueId = 'QB' + strTemp + intNewNumber + UserInfo.getOrganizationId();
                        System.debug(LoggingLevel.WARN, 'actualQueId : ' + actualQueId);
                       
                    }
                    
                    
                    System.debug(LoggingLevel.WARN, 'actualQueId : ' + actualQueId);
                    if(objQuestionBank != null ){
                        lstAssociatedProcessName.clear();
                        //Checking whether there are any exit criteria associated with the current Response set / question being modified
                        if(objQuestionBank.id != null )
                        {
                            list<SVMXC__Question_Bank__c> lstQst = new list<SVMXC__Question_Bank__c>();
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            lstQst = [SELECT id,SVMXC__Response_Set__c,SVMXC__Response_Set__r.SVMXC__Response_Set_Values__c,SVMXC__Response_Type__c FROM SVMXC__Question_Bank__c WHERE id = : objQuestionBank.id ];
                            
                            //This is for exit criteria check
                            if((lstQst[0].SVMXC__Response_Type__c != objQuestionBank.SVMXC__Response_Type__c ) || lstQst[0].SVMXC__Response_Set__c != objQuestionBank.SVMXC__Response_Set__c ||(lstQst[0].SVMXC__Response_Set__r.SVMXC__Response_Set_Values__c != objQuestionResponseSet.SVMXC__Response_Set_Values__c) )
                            {
                                isExitCriteriaAssociated = true;
                                list<SVMXC__ServiceMax_Processes__c> lstSectionExitCriteria = new list<SVMXC__ServiceMax_Processes__c>();
                                
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                lstSectionExitCriteria =[Select  id, (Select SVMXC__Process1__r.SVMXC__Name__c from  SVMXC__ServiceMax_Processes6__r) From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = 'Business Rule' AND SVMXC__Rule_Type__c ='Checklist_Section_Exit_Criteria' AND SVMXC__Question_Bank__c =: objQuestionBank.id];
                                
                                
                                
                                // lstPageLayoutDetail = [SELECT SVMXC__Page_Layout__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Detail_Type__c = 'Question' AND SVMXC__Question__c =: objQuestionBank.id]; 
                                if(lstSectionExitCriteria != null && lstSectionExitCriteria.size() > 0)
                                {
                                    
                                     //Creating a list of Process name which using given question
                                    set<String> setAssociatedProcessName = new set<String>();
                                    
                                    for(SVMXC__ServiceMax_Processes__c obj : lstSectionExitCriteria)
                                    {
                                        for(SVMXC__ServiceMax_Processes__c objPro : obj.SVMXC__ServiceMax_Processes6__r)
                                        {
                                            if(objPro.SVMXC__Process1__r.SVMXC__Name__c != null && objPro.SVMXC__Process1__r.SVMXC__Name__c != '')
                                                setAssociatedProcessName.add(objPro.SVMXC__Process1__r.SVMXC__Name__c);
                                        }
                                    }
                                    lstAssociatedProcessName.AddAll(setAssociatedProcessName);
                                    if(lstAssociatedProcessName != null && lstAssociatedProcessName.size()>0){
                                        lstAssociatedProcessName.sort();
                                        //---Start----Moved this code inside the list size if condition for fixing defect BAC-3859
                                        objQBResp.success = false;
                                        if(lstQst[0].SVMXC__Response_Type__c != objQuestionBank.SVMXC__Response_Type__c ){
                                            if(!String.isBlank(strClientType) && strClientType.equalsIgnoreCase('Designer'))
                                                objQBResp.message = System.Label.SFM001_TAG603;//Cannot modify the question as it is being used in exit criteria of a Checklist SFM process.
                                            else
                                                objQBResp.message = System.Label.CONF041_TAG045;//Cannot modify or delete this question as it is being used as Exit criteria in the following Checklist processes. Please deference the question from Exit criteria to modify or delete the question.
                                         }
                                        else if((lstQst[0].SVMXC__Response_Set__c != objQuestionBank.SVMXC__Response_Set__c) ||(lstQst[0].SVMXC__Response_Set__r.SVMXC__Response_Set_Values__c != objQuestionResponseSet.SVMXC__Response_Set_Values__c)){
                                            if(!String.isBlank(strClientType) && strClientType.equalsIgnoreCase('Designer'))
                                                objQBResp.message = System.Label.SFM001_TAG603;//Cannot modify the question as it is being used in exit criteria of a Checklist SFM process.
                                            else
                                                objQBResp.message = System.Label.CONF041_TAG045;//Cannot modify or delete this question as it is being used as Exit criteria in the following Checklist processes. Please deference the question from Exit criteria to modify or delete the question.
                                        }
                                       
                                        objQBResp.resultIds = lstAssociatedProcessName;
                                        system.debug('lstAssociatedProcessName:'+lstAssociatedProcessName.size()+'  '+lstAssociatedProcessName);
                                        return objQBResp; 
                                        //---End----Moved this code inside the list size if condition for fixing defect BAC-3859
                                    }
                                }
                            }

                            //------Start---Added for the story BAC-3733 to give message and block user from changing answer type if that question used in the source object update of any process
                            if((lstQst.size() == 1 && lstQst[0].SVMXC__Response_Type__c != objQuestionBank.SVMXC__Response_Type__c )){

                                //Checking accessibility of fields
                                List<String> queryFields = new List<String> {'SVMXC__Dispatch_Process__r.SVMXC__Name__c', 'SVMXC__Configuration_Type__c', 'SVMXC__SM_Question__c'};
                                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible)){
                                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                                }

                                //Querying source update record based on question id
                                //This condition "SVMXC__Dispatch_Process__c != null" is added for fixing defect BAC-3859
                                //SDL-SVMX-READ-FLS-ENFORCED
                                List<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateRecord = [Select Id, SVMXC__Dispatch_Process__r.SVMXC__Name__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__SM_Question__c =: objQuestionBank.id AND Recordtype.Name = 'Field Mapping' AND SVMXC__Configuration_Type__c = 'Source Update' AND SVMXC__Dispatch_Process__c != null ORDER BY SVMXC__Dispatch_Process__r.SVMXC__Name__c];

                                if(lstSourceUpdateRecord.size() > 0){
                                    //Creating a list of Process name which using given question as Source Object Update
                                    Set<String> setAssociatedProcessName = new Set<String>();
                                    for(SVMXC__ServiceMax_Config_Data__c obj: lstSourceUpdateRecord){
                                        if(String.isNotEmpty(obj.SVMXC__Dispatch_Process__r.SVMXC__Name__c))
                                            setAssociatedProcessName.add(obj.SVMXC__Dispatch_Process__r.SVMXC__Name__c);
                                    }
                                    lstAssociatedProcessName.addAll(setAssociatedProcessName);
                                    
                                    //This condition is added for fixing defect BAC-3859
                                    if(lstAssociatedProcessName.size() > 0){
                                        //setting message based on client type
                                        if(String.isNotEmpty(strClientType) && strClientType.equalsIgnoreCase('Designer')){
                                            objQBResp.message = System.Label.SFM001_TAG616;//Cannot modify the question as it is being used in "Source Object Update" of a Checklist process.
                                        }
                                        else{
                                            objQBResp.message = System.Label.CONF041_TAG055;//Cannot modify or delete this question as it is being used as "Source Object Update" in the following Checklist processes. Please dereference the question from these processes.
                                        }
                                        objQBResp.success = false;
                                        objQBResp.resultIds = lstAssociatedProcessName;
                                        System.debug('lstAssociatedProcessName: '+lstAssociatedProcessName.size()+'  '+lstAssociatedProcessName);
                                        return objQBResp;
                                    }
                                }
                            }
                            //---------End---------Added for the story BAC-3733 to give message and block user from changing answer type if that question used in the source object update of any process
                        } 
                        if(objQuestionResponseSet != null && (objQuestionBank.SVMXC__Response_Type__c == 'Checkbox' || objQuestionBank.SVMXC__Response_Type__c == 'Picklist' || objQuestionBank.SVMXC__Response_Type__c == 'Multi-select Picklist' || objQuestionBank.SVMXC__Response_Type__c == 'Radio Button')){
                            
                            
                            
                            //--------Handling Duplicate Response set--------
                            if(objQuestionResponseSet.Name != null && objQuestionResponseSet.Name != ''){
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                List<SVMXC__QB_Response_Set__c> lstResponseSetTemp = [SELECT Id FROM SVMXC__QB_Response_Set__c WHERE Name =: objQuestionResponseSet.Name];
                                if(lstResponseSetTemp != null && lstResponseSetTemp.size() > 0){
                                    if(objQuestionResponseSet.id == null || (lstResponseSetTemp.size() == 1 && objQuestionResponseSet.id != null && objQuestionResponseSet.id != lstResponseSetTemp[0].id)){
                                        objQBResp.success = false;
                                        objQBResp.message = System.Label.CONF041_TAG043;//Please enter unique Response Set name.
                                        objQBResp.messageType = 'DUPLICATE_RESPONSE_SET';
                                        objQBResp.lstQuestionBank = null;
                                        System.debug(LoggingLevel.WARN, 'Response of SFM_SaveQuestionInfo method : ' + objQBResp);
                                        return objQBResp;
                                    }
                                }
                            }
                            //--------Handling Duplicate Response set--------
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            upsert objQuestionResponseSet;
                            if(objQuestionResponseSet != null && objQuestionResponseSet.id != null)
                                objQuestionBank.SVMXC__Response_Set__c = objQuestionResponseSet.id;
                        }
                        else{
                            objQuestionBank.SVMXC__Response_Set__c = null;
                        }
                        if(objQuestionBank.SVMXC__QuestionID__c == null || objQuestionBank.SVMXC__QuestionID__c == '')
                            objQuestionBank.SVMXC__QuestionID__c = actualQueId;
                        
                        System.debug(LoggingLevel.WARN,'QuestionOBJ : '+objQuestionBank);
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        upsert objQuestionBank;

                        //--------Default Response-----Start------//
                        
                        SVMXC__SM_Default_Checklist_Response__c defaultChecklistResponseObj;
                        System.debug('defaultChecklistResponse: '+objQB.defaultChecklistResponse);
                        System.debug('defaultResponseJSON: '+objQB.defaultResponseJSON);
                        
                        //delete Default Checklist Object record. This is done as part of defect BAC-2928 fix. Here we are deleting record first then again recreating records
                        List<SVMXC__SM_Default_Checklist_Response__c> lstDCR = [SELECT ID FROM SVMXC__SM_Default_Checklist_Response__c WHERE SVMXC__SM_Question__c =: objQuestionBank.Id];
                        if(lstDCR != null && lstDCR.size() > 0){
                            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Default_Checklist_Response__c')){
                                //SDL-SVMX-DELETE-FLS-ENFORCED
                                delete lstDCR;
                            }else{
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                        }
                        
                        if(objQB.defaultChecklistResponse != null){
                            if(objQB.defaultResponseJSON != null && ((objQB.defaultResponseJSON.listOfDefaultValues != null && objQB.defaultResponseJSON.listOfDefaultValues.size() > 0) || objQB.defaultResponseJSON.literalValue != null)){
                                defaultChecklistResponseObj = objQB.defaultChecklistResponse;
                                defaultChecklistResponseObj.SVMXC__SM_Question__c = objQuestionBank.id;
                                defaultChecklistResponseObj.SVMXC__SM_Default_Response__c = JSON.serialize(objQB.defaultResponseJSON);
                                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(defaultChecklistResponseObj, COMM_SecurityUtils.Access.Createable)){
                                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                                    insert defaultChecklistResponseObj;
                                }else{
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                                }
                            }
                        }

                        //--------Default Response-------End----//
             
                        if(objQB.tagsList != null ){
                            Map<String,Id> tagsNameMap = new Map<String,Id>();    
                            Set<String> tagElementSet = new Set<String>();
                            Set<String> tagDeleteSet = new Set<String>();
                            List<SVMXC__SM_Tag_Element__c> tagElementsList = new List<SVMXC__SM_Tag_Element__c>();
                            List<SVMXC__SM_Tag_Definition__c> tagDefList = new List<SVMXC__SM_Tag_Definition__c>();  
                            List<SVMXC__SM_Tag_Element__c> tagDelList = new List<SVMXC__SM_Tag_Element__c>();                               
                            Set<String> currentTagsList = new Set<String>();

                            if(!objQB.tagsList.isEmpty()){
                                System.debug(LoggingLevel.INFO, 'TagsList : ' + objQB.tagsList);
                                for(String tagValue : objQB.tagsList){
                                    tagValue = tagValue.trim();                                    
                                    if(!String.isBlank(tagValue)){
                                       currentTagsList.add(tagValue); 
                                    }
                                }
                                for(SVMXC__SM_Tag_Definition__c tagDef : [SELECT Id,Name FROM SVMXC__SM_Tag_Definition__c WHERE Name IN : currentTagsList]){
                                    tagsNameMap.put(tagDef.Name,tagDef.Id);
                                }
                            }

                            if(objQuestionBank.Id != null){
                                
                                for(SVMXC__SM_Tag_Element__c tagElement : [SELECT Id,SVMXC__SM_Tag_Definition__r.Name FROM SVMXC__SM_Tag_Element__c WHERE SVMXC__SM_Target_Object__c =: objQuestionBank.Id]){
                                    if(currentTagsList.contains(tagElement.SVMXC__SM_Tag_Definition__r.Name))
                                        tagElementSet.add(tagElement.SVMXC__SM_Tag_Definition__r.Name);
                                    else{ 
                                        tagDelList.add(tagElement);    
                                        tagDeleteSet.add(tagElement.SVMXC__SM_Tag_Definition__r.Name);
                                    }    
                                }

                                for(String tagName : currentTagsList){
                                    if(tagsNameMap.containsKey(tagName)){
                                        if(!tagElementSet.contains(tagName)){
                                            SVMXC__SM_Tag_Element__c tagElement = new SVMXC__SM_Tag_Element__c();
                                            //tagElement.Name = tagName;
                                            tagElement.SVMXC__SM_Tag_Definition__c = tagsNameMap.get(tagName);
                                            tagElement.SVMXC__SM_Target_Object__c = objQuestionBank.Id;
                                            tagElementsList.add(tagElement);
                                        }
                                    }else{
                                        SVMXC__SM_Tag_Definition__c tagDef = new SVMXC__SM_Tag_Definition__c(Name = tagName);
                                        tagDefList.add(tagDef);
                                    } 
                                }                                
                            }
                            if(!tagDefList.isEmpty()){
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                insert tagDefList;
                                for(SVMXC__SM_Tag_Definition__c tagDefnRec : tagDefList){
                                    SVMXC__SM_Tag_Element__c tagElement = new SVMXC__SM_Tag_Element__c();
                                    //tagElement.Name = tagDefnRec.Name;
                                    tagElement.SVMXC__SM_Tag_Definition__c = tagDefnRec.Id;
                                    tagElement.SVMXC__SM_Target_Object__c = objQuestionBank.Id;
                                    tagElementsList.add(tagElement);
                                }
                            }

                            if(!tagElementsList.isEmpty())
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                insert tagElementsList; 
                            if(!tagDelList.isEmpty()){
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                delete tagDelList;
                                tagDefList.clear();
                                for(SVMXC__SM_Tag_Definition__c tagDefnRec : [SELECT Id,(SELECT Id from SVMXC__SM_Tag_Elements__r) from SVMXC__SM_Tag_Definition__c WHERE Name IN : tagDeleteSet]){
                                        //Added for defect BAC-3296 fix 
                                        Integer count = 0;
                                        for (SVMXC__SM_Tag_Element__c obj : tagDefnRec.SVMXC__SM_Tag_Elements__r) {
                                        count++;
                                    }
                                    if(count == 0){
                                            tagDefList.add(tagDefnRec);
                                    }
                                    //Commented for fixing defect BAC-3296
                                    //if(tagDefnRec.SVMXC__SM_Tag_Elements__r.isEmpty())
                                       //tagDefList.add(tagDefnRec);
                                } 
                                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Tag_Definition__c')){
                                    //SDL-SVMX-DELETE-FLS-ENFORCED
                                    delete tagDefList;
                                }else{
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                                }
                                //if(!tagDefList.isEmpty())
                                    //delete tagDefList;
                            }  
                        }                         
  
                        System.debug(LoggingLevel.WARN,'request.QuestionValidationRuleInfo : '+request.QuestionValidationRuleInfo);
                        
                        responseSuccess = true;
                        strResponseMessage = System.Label.COMM001_TAG058;//Record(s) saved successfully
                        System.debug(LoggingLevel.WARN,'request.QuestionValidationRuleInfo : '+request.QuestionValidationRuleInfo);
                        if(request.QuestionValidationRuleInfo != null)
                        {
                            //request.QuestionValidationRuleInfo.QuestionValidationRule.SVMXC__Question_Bank__c = objQuestionBank.Id;
                            request.QuestionValidationRuleInfo.questionBankId = objQuestionBank.Id;
                            request.QuestionValidationRuleInfo.questionId = objQuestionBank.SVMXC__QuestionID__c;
                            
                            respChecklistValidation = SFM_SaveQuestionValidationRules(request);
                            if(respChecklistValidation.success == false )
                            {
                                responseSuccess = false;
                                strResponseMessage = respChecklistValidation.message;
                                Database.rollback(objSavePoint);
                            }
                            else if(objQuestionBank != null)
                            {
                                if(respChecklistValidation != null && respChecklistValidation.QuestionValidationRuleInfo != null )                          
                                    lstQBWrap.add(new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQuestionBank, null, objQuestionResponseSet,null, respChecklistValidation.QuestionValidationRuleInfo, defaultChecklistResponseObj, objQB.defaultResponseJSON));                             
                                    
                            }
                        }
                        else if(objQuestionBank != null) 
                            lstQBWrap.add(new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQuestionBank, null, objQuestionResponseSet, null, null, defaultChecklistResponseObj, objQB.defaultResponseJSON));
                    }
                }
            }
            else{
                responseSuccess = false;
                strResponseMessage = System.Label.CONF041_TAG042;//Invalid Request
            }
            
        }
        catch(DMLException ex){
            Database.rollback(objSavePoint);
            responseSuccess = false;
            strResponseMessage = String.valueOf(ex.getDmlType(0));
            System.debug(LoggingLevel.WARN, 'DMLException in SFM_SaveQuestionInfo method : ' + ex.getDmlMessage(0));            
        }
        catch(Exception ex){
            Database.rollback(objSavePoint);
            responseSuccess = false;
            strResponseMessage = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFM_SaveQuestionInfo method Stack Trace: ' + ex.getStackTraceString());
            System.debug(LoggingLevel.WARN, 'Exception in SFM_SaveQuestionInfo method : ' + ex.getMessage());
        }
        objQBResp.success = responseSuccess;
        objQBResp.message = strResponseMessage;
        objQBResp.lstQuestionBank = lstQBWrap;
        
        System.debug(LoggingLevel.WARN, 'Response of SFM_SaveQuestionInfo method : ' + objQBResp);
        return objQBResp;
    }
    
    //This method returns all the Response set available in the org
    //Request requires nothing at this moment
    //Response will be SFM_Response with list of SFM_StringMap(Sid, ResponseSetText)
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetListOfResponseSet(SVMXC.SFM_WrapperDef.SFM_Request request){
        System.debug(LoggingLevel.WARN, 'Request in SFM_GetListOfResponseSet method : ' + request);
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        objResponse.stringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        objResponse.success = true;
        try{
            List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__QB_Response_Set__c> lstResponseSet = [SELECT Id, Name, SVMXC__Response_Set_Values__c FROM SVMXC__QB_Response_Set__c];
            for(SVMXC__QB_Response_Set__c objRSet : lstResponseSet){
                lstStringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap(objRSet.id, objRSet.Name, objRSet.SVMXC__Response_Set_Values__c));
            }
            objResponse.stringMap = lstStringMap;
            List<String> tagSet = new List<String>();
            for(SVMXC__SM_Tag_Definition__c tagDefn : [SELECT Id,Name FROM SVMXC__SM_Tag_Definition__c]){
                tagSet.add(tagDefn.Name);
            }
            SVMXC.SFM_WrapperDef.SFM_StringListMap tagMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
            tagMap.key = 'ALLTAGS'; 
            tagMap.valueList = tagSet;
            objResponse.StringLstMap.add(tagMap);
        }

        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFM_GetListOfResponseSet method: ' + ex.getMessage());
        }
        System.debug(LoggingLevel.WARN, 'Response of SFM_GetListOfResponseSet method: ' + objResponse);
        return objResponse;
    }

//This method will save Validation info for each Question
    //Request requires objQuestionBank id  and corresponding validation rule info(SFM_QuestionValidationRuleInfo)
    //Response will return Success/Failure, message and list of Question Bank
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_SaveQuestionValidationRules(SVMXC.SFM_WrapperDef.SFM_Request ChecklistRuleRequest)
    {
        System.debug(LoggingLevel.WARN, 'Request: ' + ChecklistRuleRequest);
        String QuestionId = NULL;
        String questionNum = NULL;
        String ChecklistId = NULL;
        String qBValRuleId = NULL;
        //String ObjName;
        String UniqueProcessId;
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String ProcessBizRuleId;
        String bizRuleRecId;
        String respMassage = '';
        Boolean respSuccess = true;
        Savepoint sp;
        
        SVMXC__ServiceMax_Processes__c QuestionValidationRule;
        SVMXC__ServiceMax_Processes__c ProcessBizRule = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c> lstChecklistValidationRuleExpr = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo objChecklistValidationsRuleInfoWrap = new SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo();
        SVMXC.SFM_WrapperDef.SFM_Response objChecklistRuleResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC.SFM_WrapperDef.SFM_Response objValidationResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        
        try
        {
            sp = Database.setSavepoint();
             SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo QuestionValidationRuleInfo = ChecklistRuleRequest.QuestionValidationRuleInfo;
            System.debug(LoggingLevel.WARN, 'QuestionValidationRuleInfo.lstQuestionValidationRuleDetails : ' + QuestionValidationRuleInfo.lstQuestionValidationRuleDetails);
            //When the Data validation rule  assosiated with question is removed, delete the biz rule ,Config Data  Process Business Ruleand  QB Validation assosiated with that
            if( QuestionValidationRuleInfo.QuestionValidationRule != null && QuestionValidationRuleInfo.QuestionValidationRule.id != null && (QuestionValidationRuleInfo.lstQuestionValidationRuleDetails == NULL || QuestionValidationRuleInfo.lstQuestionValidationRuleDetails != NULL  && QuestionValidationRuleInfo.lstQuestionValidationRuleDetails.size() <= 0))
            {   
                qBValRuleId = QuestionValidationRuleInfo.QuestionValidationRule.id;
                System.debug(LoggingLevel.WARN, 'qBValRuleId: ' + qBValRuleId);
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<SVMXC__ServiceMax_Processes__c> lstQBval = [Select Id From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = 'QB Validation' AND SVMXC__Process1__c =:  qBValRuleId]; 
                System.debug(LoggingLevel.WARN, 'lstQBval: ' + lstQBval);
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<SVMXC__ServiceMax_Processes__c> lstProcBizRule = [select id From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = 'Process Business Rule' and SVMXC__Process3__c =:qBValRuleId] ;
                
                    System.debug(LoggingLevel.WARN, 'lstProcBizRule: ' + lstProcBizRule);

                if(lstQBval != null && lstQBval.size()>0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    delete lstQBval;
                
                if(lstProcBizRule != null && lstProcBizRule.size()>0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    delete lstProcBizRule;
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA               
                list<SVMXC__ServiceMax_Config_Data__c> lstConf = [Select Id From SVMXC__ServiceMax_Config_Data__c Where Recordtype.Name = 'Expressions' AND SVMXC__Expression_Rule__c =: qBValRuleId ];
                //delete Database.query('Select Id From SVMXC__ServiceMax_Config_Data__c Where Recordtype.Name = \'Expressions\' AND SVMXC__Expression_Rule__c =: qBValRuleId AND SVMXC__Expression_Rule__c != NULL');
                System.debug(LoggingLevel.WARN, 'lstConf: ' + lstConf);
                if(lstConf != null && lstConf.size()>0)
                delete lstConf;
                delete QuestionValidationRuleInfo.QuestionValidationRule;
                
                
            }
            else
            {
            //Retrieving record type
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(RecordType RType : Database.query('Select Id, Name From RecordType Where (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'Business Rule\') OR (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'QB Validation\') OR (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'Process Business Rule\')OR (SobjectType = \'SVMXC__ServiceMax_Config_Data__c\' AND Name = \'Expressions\')'))
            {
                if(RType.Name == 'QB Validation')
                    RuleRecordTypeId = RType.id;
                else if(RType.Name == 'Expressions')
                    ExpressionRTypeId = RType.id; 
                else if(RType.Name == 'Process Business Rule')
                    ProcessBizRuleId = RType.id;
                else if(RType.Name == 'Business Rule')
                    bizRuleRecId = RType.id;
            }
            //Validating whether the given expressions
            objValidationResp = ValidateQuestionValRules(ChecklistRuleRequest);
            System.debug(LoggingLevel.WARN, 'validation response : ' + objValidationResp.success);
            
            
            //Proceeding to save if the expressions are valid
            if(objValidationResp != NULL && objValidationResp.success == true)
            {
                //SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo QuestionValidationRuleInfo = ChecklistRuleRequest.QuestionValidationRuleInfo;
                
                if(QuestionValidationRuleInfo != NULL && QuestionValidationRuleInfo.QuestionValidationRule != NULL)
                {
                    if(QuestionValidationRuleInfo.questionBankId != NULL)
                        QuestionId = String.escapeSingleQuotes(QuestionValidationRuleInfo.questionBankId); 
                    if(QuestionValidationRuleInfo.questionId != NULL)
                        questionNum = String.escapeSingleQuotes(QuestionValidationRuleInfo.questionId);
                    if(QuestionValidationRuleInfo.checklistId != NULL)
                        ChecklistId = String.escapeSingleQuotes(QuestionValidationRuleInfo.checklistId);
                    if(QuestionValidationRuleInfo.QuestionValidationRule != NULL && QuestionValidationRuleInfo.QuestionValidationRule.id != NULL)
                        qBValRuleId = String.escapeSingleQuotes(QuestionValidationRuleInfo.QuestionValidationRule.id);
                    
                   
                    System.debug(LoggingLevel.WARN, 'qBValRuleId : ' + qBValRuleId);
                    QuestionValidationRule = QuestionValidationRuleInfo.QuestionValidationRule;
                    QuestionValidationRule.RecordTypeId = bizRuleRecId;
                        if(QuestionValidationRule.SVMXC__Message_Type__c == null || QuestionValidationRule.SVMXC__Message_Type__c =='')
                    QuestionValidationRule.SVMXC__Message_Type__c = 'Error';
                    QuestionValidationRule.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
                    UniqueProcessId = QuestionValidationRule.SVMXC__ProcessID__c;
                    
                    if(QuestionValidationRuleInfo.lstQuestionValidationRuleDetails != NULL && QuestionValidationRuleInfo.lstQuestionValidationRuleDetails.size() > 0)
                        lstChecklistValidationRuleExpr.addAll(QuestionValidationRuleInfo.lstQuestionValidationRuleDetails);
                }
                if(QuestionValidationRule != NULL)
                {
                    //If it is a new Validation rule Checking if any Validation rule already exists with the given process id. If so return error message else proceed to save
                    //List<SVMXC__ServiceMax_Processes__c> lstDuplicateChecklistRule = Database.query('Select Id From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = \'QB Validation\' AND SVMXC__ProcessID__c =: UniqueProcessId AND SVMXC__ProcessID__c != NULL AND Id !=: qBValRuleId');
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    List<SVMXC__ServiceMax_Processes__c> lstDuplicateChecklistRule = Database.query('Select Id From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = \'Business Rule\' AND SVMXC__ProcessID__c =: UniqueProcessId AND SVMXC__ProcessID__c != NULL AND Id !=: qBValRuleId');
                    
                    System.debug(LoggingLevel.WARN, 'lstDuplicateChecklistRule : ' + lstDuplicateChecklistRule);
                    System.debug(LoggingLevel.WARN, 'qBValRuleId : ' + qBValRuleId);
                   //Apurva
                   list<SVMXC__ServiceMax_Processes__c > lstProcBizRule = new list<SVMXC__ServiceMax_Processes__c > ();
                   //Apurva - SS-1528
                   if(qBValRuleId != null && QuestionValidationRule.SVMXC__Parent_Error_Msg__c != null && QuestionValidationRule.SVMXC__Parent_Error_Msg__c!= '')
                   {
                       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                       lstProcBizRule = [select SVMXC__Parent_Error_Msg__c From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = 'Process Business Rule' and SVMXC__Process3__c =:qBValRuleId] ;
                        if(lstProcBizRule != null && lstProcBizRule.size()>0)
                        {
                            for(SVMXC__ServiceMax_Processes__c obj:lstProcBizRule)
                                obj.SVMXC__Parent_Error_Msg__c = QuestionValidationRule.SVMXC__Parent_Error_Msg__c;
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            update lstProcBizRule;
                        
                        }
                   }
                    //
                    if(lstDuplicateChecklistRule != NULL && lstDuplicateChecklistRule.size() > 0)
                    {
                        respSuccess = false;
                        respMassage = System.Label.SFM001_TAG347;
                    }
                    else
                    {
                        
                        System.debug(LoggingLevel.WARN, 'QuestionValidationRule : ' + QuestionValidationRule);
                        //Saving ServiceMax Process having Validation rule name, Question id and other details
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        upsert QuestionValidationRule;
                        
                        for(SVMXC__ServiceMax_Config_Data__c expressDetail : lstChecklistValidationRuleExpr)
                        {
                            expressDetail.RecordTypeId = ExpressionRTypeId;
                            expressDetail.SVMXC__Expression_Type__c = 'Business_Rule';
                            expressDetail.SVMXC__Field_Name__c = questionNum;
                            //expressDetail.SVMXC__Source_Field_Name__c = questionNum;
                            expressDetail.SVMXC__Expression_Rule__c = QuestionValidationRule.Id;
                            if(expressDetail.SVMXC__Display_Type__c != NULL && expressDetail.SVMXC__Display_Type__c.length() > 0)
                                expressDetail.SVMXC__Display_Type__c = String.valueOf(expressDetail.SVMXC__Display_Type__c).toUpperCase();
                        }
                        //Checking if there are existing expression for the given Rule, if so deleting all
                        if(qBValRuleId != NULL && qBValRuleId.length() > 0)
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            delete Database.query('Select Id From SVMXC__ServiceMax_Config_Data__c Where Recordtype.Name = \'Expressions\' AND SVMXC__Expression_Rule__c =: qBValRuleId AND SVMXC__Expression_Rule__c != NULL');
                        
                        //Saving all expressions for the given Rule
                        if(lstChecklistValidationRuleExpr != NULL && lstChecklistValidationRuleExpr.size() > 0)
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            upsert lstChecklistValidationRuleExpr;
                        
                        List<SVMXC__ServiceMax_Processes__c> lstBizRule =  new List<SVMXC__ServiceMax_Processes__c>();
                         System.debug(LoggingLevel.WARN, 'ChecklistId : ' + ChecklistId);
                        if(ChecklistId != null)
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            lstBizRule = [Select Id From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = 'QB Validation' AND SVMXC__Process1__c =:  QuestionValidationRule.Id AND SVMXC__Question_Bank__c =:QuestionValidationRuleInfo.questionBankId ]; 
                        else
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            lstBizRule = [Select Id From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = 'QB Validation' AND SVMXC__Process1__c =:  QuestionValidationRule.Id AND SVMXC__Question_Bank__c =:QuestionValidationRuleInfo.questionBankId ];
                        if(lstBizRule != null && lstBizRule.size()>0)
                            ProcessBizRule = lstBizRule[0];
                        ProcessBizRule.RecordTypeId = RuleRecordTypeId;
                        ProcessBizRule.SVMXC__Question_Bank__c = QuestionValidationRuleInfo.questionBankId;
                        ProcessBizRule.SVMXC__Process1__c = QuestionValidationRule.Id;
                      
                        //if(ChecklistId != null)
                        //      ProcessBizRule.SVMXC__Process1__c = ChecklistId;
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        upsert ProcessBizRule;
                        system.debug('ProcessBizRule.id: '+ProcessBizRule.id);
                        if(QuestionValidationRule != NULL && lstChecklistValidationRuleExpr != NULL && lstChecklistValidationRuleExpr.size() > 0)
                            objChecklistValidationsRuleInfoWrap = new SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo(QuestionValidationRule, lstChecklistValidationRuleExpr);
                       
                        respSuccess = true;
                        respMassage = System.Label.SFM001_TAG349;
                    }
                }
            }
            else
            {
                respSuccess = false;
                respMassage = System.Label.SFM001_TAG350;
                System.debug(LoggingLevel.WARN, 'validation response : Failed');
            }
        }
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            respSuccess = false;
            respMassage = ex.getDmlMessage(0);
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            respSuccess = false;
            respMassage = ex.getmessage();
        }
         //Returning whether the transaction was sucessful or not
        objChecklistRuleResponse.success = respSuccess;
        objChecklistRuleResponse.message = respMassage;
        if(QuestionValidationRule != NULL && QuestionValidationRule.Id != NULL)
            objChecklistRuleResponse.resultIds.add(QuestionValidationRule.Id);
        //If successfull returning the validation rule created
        //objChecklistRuleResponse.lstChecklistValidationRuleInfo = lstChecklistValidationsRuleInfoWrap;
        objChecklistRuleResponse.QuestionValidationRuleInfo = objChecklistValidationsRuleInfoWrap;
        System.debug(LoggingLevel.WARN, 'Response: ' + objChecklistRuleResponse);
        return objChecklistRuleResponse;
    }
    
    public SVMXC.SFM_WrapperDef.SFM_Response ValidateQuestionValRules(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_WrapperDef.SFM_Response objValidationResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC__ServiceMax_Processes__c QuestionValidationRule = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c> lstQuestionValidationRuleDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstchecklistRuleDetailsClone = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(request != NULL && request.QuestionValidationRuleInfo != NULL && request.QuestionValidationRuleInfo.QuestionValidationRule != NULL && request.QuestionValidationRuleInfo.lstQuestionValidationRuleDetails != NULL)
        {
            QuestionValidationRule = request.QuestionValidationRuleInfo.QuestionValidationRule;
            QuestionValidationRule.SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c';
            lstQuestionValidationRuleDetails = request.QuestionValidationRuleInfo.lstQuestionValidationRuleDetails;
            for(SVMXC__ServiceMax_Config_Data__c ChecklistRuleExp : lstQuestionValidationRuleDetails)
            {
               
                String strOperandDataType = '';
                SVMXC__ServiceMax_Config_Data__c ChecklistValidRuleExpClone = ChecklistRuleExp.clone(false, true);
                if(ChecklistValidRuleExpClone.SVMXC__Display_Type__c == 'DATETIME'){
                  ChecklistValidRuleExpClone.SVMXC__Field_Name__c = 'SVMXC__Completed_Date_Time__c';
                }
                else if(ChecklistValidRuleExpClone.SVMXC__Display_Type__c == 'DATE'){
                  ChecklistValidRuleExpClone.SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c';
                }
                else if(ChecklistValidRuleExpClone.SVMXC__Display_Type__c == 'DOUBLE'){
                  ChecklistValidRuleExpClone.SVMXC__Field_Name__c = 'SVMXC__Scheduling_Retry_Count__c';
                }
                
                lstchecklistRuleDetailsClone.add(ChecklistValidRuleExpClone);
            }
            
            System.debug(LoggingLevel.WARN, 'QuestionValidationRule: ' + QuestionValidationRule);
            System.debug(LoggingLevel.WARN, 'lstchecklistRuleDetailsClone: ' + lstchecklistRuleDetailsClone);
            List<SVMXC.SFM_WrapperDef.SFM_Expression> Exprs = new List<SVMXC.SFM_WrapperDef.SFM_Expression>();
            Exprs.add(new SVMXC.SFM_WrapperDef.SFM_Expression(QuestionValidationRule, lstchecklistRuleDetailsClone));
            SVMXC.SFM_WrapperDef.SFM_Request_Expression objChecklistValidRuleExprs = new SVMXC.SFM_WrapperDef.SFM_Request_Expression(Exprs);
            objValidationResp = new SVMXC.SFM_validateExpression().SFM_validateExpression(objChecklistValidRuleExprs);
            QuestionValidationRule.SVMXC__Source_Object_Name__c ='';
        }
        else
            objValidationResp.success = false;
        
        System.debug(LoggingLevel.WARN, 'Response: ' + objValidationResp);
        return objValidationResp;
    }
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_SaveChecklist_QuestionInfo(SVMXC.SFM_WrapperDef.SFM_Request ChecklistQuestionRequest)
    {
        System.debug(LoggingLevel.WARN, 'Request: ' + ChecklistQuestionRequest);
        String ProcessBizRuleId;
        map<string,string> mapQuestionValidnRule = new map<string,string>();
        map<string,SVMXC__ServiceMax_Processes__c> mapValIdValRule = new map<string,SVMXC__ServiceMax_Processes__c>();
        String ChecklistId;
        String respMassage = '';
        Boolean respSuccess = true;
        Savepoint sp;
        SFM_WrapperDef.SFM_MapStringMap mapchecklist_QuestionInfo = new SFM_WrapperDef.SFM_MapStringMap();
        //list<SFM_WrapperDef.SFM_MapStringMap> lstmapchecklist_QuestionInfo = new list<SFM_WrapperDef.SFM_MapStringMap> ();
        SVMXC.SFM_WrapperDef.SFM_Response objChecklistQuestionResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        try
        {
            sp = Database.setSavepoint();
            //lstmapchecklist_QuestionInfo = ChecklistQuestionRequest.MapStringMap;
            mapchecklist_QuestionInfo = ChecklistQuestionRequest.MapStringMap;
            if(mapchecklist_QuestionInfo != null && mapchecklist_QuestionInfo.key != null )
                ChecklistId = mapchecklist_QuestionInfo.key;
            
            List<SFM_WrapperDef.SFM_StringMap> valueMapQuestionValidnRule = new List<SFM_WrapperDef.SFM_StringMap>();
            valueMapQuestionValidnRule = mapchecklist_QuestionInfo.valueMap;
            System.debug(LoggingLevel.WARN, 'valueMapQuestionValidnRule: ' + valueMapQuestionValidnRule.size()+'  '+valueMapQuestionValidnRule);
            for(SFM_WrapperDef.SFM_StringMap strmap:valueMapQuestionValidnRule)
            {
                if(strmap != null && strmap.key != null && strmap.value != null && strmap.key != '' && strmap.value != '')
                    mapQuestionValidnRule.put(strmap.key,strmap.value);
            }
            list<SVMXC__ServiceMax_Processes__c> lstExistingProcBizRule= new list<SVMXC__ServiceMax_Processes__c> ();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstExistingProcBizRule = [Select Id, SVMXC__Process3__c,SVMXC__Process1__c, SVMXC__Question_Bank__c From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = 'Process Business Rule' AND  SVMXC__Process1__c =: ChecklistId];
            
            for(SVMXC__ServiceMax_Processes__c obj: lstExistingProcBizRule)
            {
                if(obj.SVMXC__Process3__c != null)
                    mapValIdValRule.put(obj.SVMXC__Process3__c, obj);
            }
            
            if(!mapQuestionValidnRule.isEmpty() && mapQuestionValidnRule.size()>0)
            {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(RecordType RType : Database.query('Select Id, Name From RecordType Where (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'Process Business Rule\')'))
                {
                   
                    if(RType.Name == 'Process Business Rule')
                        ProcessBizRuleId = RType.id;
                }
                list<SVMXC__ServiceMax_Processes__c> lstProcessBizRule = new list<SVMXC__ServiceMax_Processes__c>();
                for(string questId:mapQuestionValidnRule.keySet())
                {
                    SVMXC__ServiceMax_Processes__c ProcessBizRule = new SVMXC__ServiceMax_Processes__c();
                    if(mapQuestionValidnRule.Containskey(questId) && mapValIdValRule.containskey(mapQuestionValidnRule.get(questId)) && mapValIdValRule.get(mapQuestionValidnRule.get(questId)) != null)
                        ProcessBizRule = mapValIdValRule.get(mapQuestionValidnRule.get(questId));
                    system.debug('ProcessBizRule: '+ProcessBizRule);
                    ProcessBizRule.RecordTypeId = ProcessBizRuleId;
                    ProcessBizRule.SVMXC__Rule_Type__c = 'Checklist_QB';

                   // if(questId != null)
                    //    ProcessBizRule.SVMXC__Question_Bank__c = questId;

                    if(mapQuestionValidnRule.containsKey(questId) && mapQuestionValidnRule.get(questId) != null)
                        ProcessBizRule.SVMXC__Process3__c = mapQuestionValidnRule.get(questId);
                    if(ProcessBizRule.SVMXC__Process3__c != null )
                    {
                        list<SVMXC__ServiceMax_Processes__c> lstBizRule = new list<SVMXC__ServiceMax_Processes__c>();
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        lstBizRule = [select SVMXC__Parent_Error_Msg__c From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = 'Business Rule' and Id =: ProcessBizRule.SVMXC__Process3__c] ;
                        if(lstBizRule != null && lstBizRule.size()>0 && lstBizRule[0].SVMXC__Parent_Error_Msg__c != null && lstBizRule[0].SVMXC__Parent_Error_Msg__c != '')
                            ProcessBizRule.SVMXC__Parent_Error_Msg__c = lstBizRule[0].SVMXC__Parent_Error_Msg__c;
                    }
                    if(ChecklistId != null)
                        ProcessBizRule.SVMXC__Process1__c = ChecklistId;
                    
                    lstProcessBizRule.add(ProcessBizRule);
                }
                if(lstProcessBizRule != null && lstProcessBizRule.size()>0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    upsert lstProcessBizRule;
                for(SVMXC__ServiceMax_Processes__c obj:lstProcessBizRule)
                    system.debug('obj.id : '+obj.id);
                    system.debug('lstProcessBizRule : '+lstProcessBizRule);
                respSuccess = true;
                respMassage = System.Label.SFM001_TAG349;
            }
            
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            respSuccess = false;
            respMassage = ex.getDmlMessage(0);
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            respSuccess = false;
            respMassage = ex.getmessage();
        }
        
        objChecklistQuestionResponse.success = respSuccess;
        objChecklistQuestionResponse.message = respMassage;
       
        return objChecklistQuestionResponse;
    }

    /*
        Story : BAC-2288
        Description : Designer service for checklist Opdoc, to get all the question Ids for the checklist process 
                      which is required for applying business rules based on question 
    */
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetQuestionDetailsOfProcess(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_WrapperDef.SFM_Response responseData = new SVMXC.SFM_WrapperDef.SFM_Response();
        try{
            if(request != null && request.stringListMap != null && !request.stringListMap.isEmpty()){
                SVMXC.SFM_WrapperDef.SFM_StringListMap processList = request.stringListMap[0];

                if(processList.valueList != null && !processList.valueList.isEmpty()){

                   
                    Set<String> layoutIds = new Set<String>(processList.valueList);
                    Map<String, List<String>> layoutQuestionIdsMap = new Map<String, List<String>>();
                    
                    List<String> queryFields = new List<String> {'SVMXC__Question__c','SVMXC__Page_Layout__c'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Page_Layout_Detail__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }

                    for(SVMXC__Page_Layout_Detail__c pageDetailRec : [SELECT Id, SVMXC__Question__c, SVMXC__Page_Layout__c FROM SVMXC__Page_Layout_Detail__c WHERE 
                                                                        SVMXC__Page_Layout__c IN : layoutIds AND SVMXC__Detail_Type__c = 'Question']){
                        
                        if(pageDetailRec.SVMXC__Question__c != null){
                            List<String> tempIds = new List<String>();
                            if(layoutQuestionIdsMap.containsKey(pageDetailRec.SVMXC__Page_Layout__c)){
                                tempIds = layoutQuestionIdsMap.get(pageDetailRec.SVMXC__Page_Layout__c);
                            }

                            tempIds.add(pageDetailRec.SVMXC__Question__c);
                            layoutQuestionIdsMap.put(pageDetailRec.SVMXC__Page_Layout__c, tempIds);
                        }

                    }

                    if(!layoutQuestionIdsMap.isEmpty()){
                        
                        List<SVMXC.SFM_WrapperDef.SFM_StringListMap> layoutQuestionIdsMapList = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
                        for(String layoutKey : layoutQuestionIdsMap.keySet()){
                            SVMXC.SFM_WrapperDef.SFM_StringListMap layoutQuestionIdMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap(layoutKey,layoutQuestionIdsMap.get(layoutKey));
                            layoutQuestionIdsMapList.add(layoutQuestionIdMap);
                        }

                        
                        responseData.StringLstMap = layoutQuestionIdsMapList;
                        responseData.success = true;
                        return responseData;
                    }
                }
            }
        }catch(exception ex){
            responseData.success = false;
            responseData.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFM_GetQuestionDetailsOfProcess method Stack Trace: ' + ex.getStackTraceString());
            System.debug(LoggingLevel.WARN, 'Exception in SFM_GetQuestionDetailsOfProcess method : ' + ex.getMessage());           
        }

        return responseData;
    } 
    
    public SFM_WrapperDef2.SFM2_QuestionsResponses getChecklistQuestions(List<String> entityIds){
        SFM_WrapperDef2.SFM2_QuestionsResponses checklistQuestionResponses;
        try{
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id','SVMXC__Page_Layout__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Page_Layout_Detail__c', new List<String>{'Id','SVMXC__Question__c','SVMXC__Page_Layout__c','SVMXC__Question__r.SVMXC__Response_Type__c','SVMXC__Question__r.SVMXC__QuestionID__c',
                                                                    'SVMXC__Question__r.SVMXC__Response_Set__c', 'SVMXC__Question__r.SVMXC__Question__c', 'SVMXC__Detail_Type__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__QB_Response_Set__c', new List<String>{'Id','Name','SVMXC__Response_Set_Values__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<SVMXC__ServiceMax_Processes__c> processList = [SELECT Id, SVMXC__Page_Layout__c FROM SVMXC__ServiceMax_Processes__c WHERE Id IN: entityIds];
            if(processList.size() == 1){
                Set<Id> responseSetIds = new Set<Id>();
                SVMXC__ServiceMax_Processes__c processRecord = processList[0];
                List<SFM_WrapperDef2.SFM2_QuestionMeta> questionMetaList = new List<SFM_WrapperDef2.SFM2_QuestionMeta>();
                List<SFM_WrapperDef2.SFM2_ResponseOptionMeta> responseMetaList = new List<SFM_WrapperDef2.SFM2_ResponseOptionMeta>();
                for(SVMXC__Page_Layout_Detail__c questionRecord : [SELECT Id, SVMXC__Question__c, SVMXC__Page_Layout__c, SVMXC__Question__r.SVMXC__Response_Type__c, SVMXC__Question__r.SVMXC__Response_Set__c, SVMXC__Question__r.SVMXC__Question__c,
                                                        SVMXC__Question__r.SVMXC__QuestionID__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Detail_Type__c = 'Question' AND SVMXC__Page_Layout__c =: processRecord.SVMXC__Page_Layout__c]){
                    SFM_WrapperDef2.SFM2_QuestionMeta questionMetaRecord = new SFM_WrapperDef2.SFM2_QuestionMeta();
                    questionMetaRecord.questionId = questionRecord.SVMXC__Question__c;
                    questionMetaRecord.questionExtId = questionRecord.SVMXC__Question__r.SVMXC__QuestionID__c;
                    questionMetaRecord.question = questionRecord.SVMXC__Question__r.SVMXC__Question__c;
                    questionMetaRecord.qType = questionRecord.SVMXC__Question__r.SVMXC__Response_Type__c;
                    questionMetaRecord.responseId = questionRecord.SVMXC__Question__r.SVMXC__Response_Set__c;
                    if(questionRecord.SVMXC__Question__r.SVMXC__Response_Set__c != null){
                        responseSetIds.add(questionRecord.SVMXC__Question__r.SVMXC__Response_Set__c );
                    }
                    questionMetaList.add(questionMetaRecord);
                }
                for(SVMXC__QB_Response_Set__c responseSet : [SELECT Id, Name, SVMXC__Response_Set_Values__c FROM SVMXC__QB_Response_Set__c WHERE Id IN: responseSetIds]){
                    SFM_WrapperDef2.SFM2_ResponseOptionMeta responseMetaRecord = new SFM_WrapperDef2.SFM2_ResponseOptionMeta();
                    responseMetaRecord.responseId = responseSet.Id;
                    responseMetaRecord.values = responseSet.SVMXC__Response_Set_Values__c != null ? responseSet.SVMXC__Response_Set_Values__c.split(';') : null;
                    responseMetaList.add(responseMetaRecord);
                }
                checklistQuestionResponses = new SFM_WrapperDef2.SFM2_QuestionsResponses();
                checklistQuestionResponses.checklistId = processRecord.Id;
                checklistQuestionResponses.questions = questionMetaList;
                checklistQuestionResponses.responses = responseMetaList;
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, ' getChecklistQuestions - Exception ' + ex.getMessage());
            throw ex;
        }
        return checklistQuestionResponses;
    }
    public List<SFM_WrapperDef2.SFM2_QuestionMeta> getListOfQuestions(){
        Map<String, SFM_WrapperDef2.SFM2_QuestionMeta> questionMetaMap = new Map<String, SFM_WrapperDef2.SFM2_QuestionMeta>();
        Map<String, String> questionDvrIdMap = new Map<String, String>();
        try{
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id','SVMXC__Process1__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Question_Bank__c', new List<String>{'Id', 'SVMXC__Response_Type__c', 'SVMXC__Response_Set__c', 'SVMXC__Question__c', 'SVMXC__QuestionID__c',
                                                            'CreatedBy.Name', 'LastModifiedDate'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            for(SVMXC__Question_Bank__c questionRecord : [SELECT Id, SVMXC__Response_Type__c, SVMXC__Response_Set__c, SVMXC__Question__c, SVMXC__QuestionID__c, SVMXC__Help_URL__c,
                                                            CreatedBy.Name, LastModifiedDate, SVMXC__SM_Description_Required__c, SVMXC__SM_Show_In_Smart_Doc__c, (SELECT Id, SVMXC__Process1__c FROM SVMXC__ServiceMax_Processes__r WHERE RecordType.Name = 'QB Validation'),
                                                            (SELECT Id, SVMXC__SM_Default_Response__c, SVMXC__SM_Is_literal_Used__c, SVMXC__SM_Question__c FROM SVMXC__Default_Checklist_Responses__r) FROM SVMXC__Question_Bank__c]){
            SFM_WrapperDef2.SFM2_QuestionMeta questionMetaRecord = new SFM_WrapperDef2.SFM2_QuestionMeta();
            questionMetaRecord.questionId = questionRecord.Id;
            questionMetaRecord.questionExtId = questionRecord.SVMXC__QuestionID__c;
            questionMetaRecord.question = questionRecord.SVMXC__Question__c;
                questionMetaRecord.descriptionRequired = questionRecord.SVMXC__SM_Description_Required__c;
                questionMetaRecord.showInSmartDoc = questionRecord.SVMXC__SM_Show_In_Smart_Doc__c;
            questionMetaRecord.qType = questionRecord.SVMXC__Response_Type__c;
            questionMetaRecord.responseId = questionRecord.SVMXC__Response_Set__c;
            questionMetaRecord.createdBy = questionRecord.CreatedBy.Name;
                questionMetaRecord.helpUrl = questionRecord.SVMXC__Help_URL__c;  
            questionMetaRecord.lastModifiedDate = String.valueOfGmt(questionRecord.LastModifiedDate);
                questionMetaMap.put(questionRecord.Id, questionMetaRecord);
                if(!questionRecord.ServiceMax_Processes__r.isEmpty()){
                    List<SVMXC__ServiceMax_Processes__c> junctionRecordList = questionRecord.ServiceMax_Processes__r;
                    if(junctionRecordList[0].SVMXC__Process1__c != null){
                        questionDvrIdMap.put(junctionRecordList[0].SVMXC__Process1__c, questionRecord.Id);
                    }
                }
                if(questionRecord.SVMXC__Default_Checklist_Responses__r.size() == 1){
                    List<SVMXC__SM_Default_Checklist_Response__c> defaultQuestionResponse = questionRecord.SVMXC__Default_Checklist_Responses__r;
                    if(defaultQuestionResponse[0].SVMXC__SM_Default_Response__c != null){
                        DefaultResponseSetWrapper defaultResponseSetValue = (DefaultResponseSetWrapper)JSON.deserialize(defaultQuestionResponse[0].SVMXC__SM_Default_Response__c, DefaultResponseSetWrapper.class);
                        questionMetaRecord.defaultValues = defaultResponseSetValue.listOfDefaultValues;
                        questionMetaRecord.defaultLiteralValue = defaultResponseSetValue.literalValue;
                        questionMetaRecord.defaultResponseId = defaultQuestionResponse[0].Id;
                    }
                }
            }
            if(!questionMetaMap.keySet().isEmpty()){
                Map<String, List<String>> entityIdTagsMap = SFM_DesignerUtils.getSVMXTags(new List<String>(questionMetaMap.keySet()));
                for(String questionId : entityIdTagsMap.keySet()){
                    if(questionMetaMap.containsKey(questionId)){
                        questionMetaMap.get(questionId).tagsList = entityIdTagsMap.get(questionId);
                    }
                }
            }
            if(!questionDvrIdMap.keySet().isEmpty()){
                SFM_SaveAsExpression buildSFMRuleClass = new SFM_SaveAsExpression();
                for(SVMXC__ServiceMax_Processes__c businessRuleRec : new SFM_GetNamedExpressionList().queryRuleRecords(null, new List<String>(questionDvrIdMap.keySet()), true, SFM_DesignerUtils.entity_businessrule)){
                    if(questionDvrIdMap.containsKey(businessRuleRec.Id)){
                        String questionId = questionDvrIdMap.get(businessRuleRec.Id);
                        if(questionMetaMap.containsKey(questionId)){
                            questionMetaMap.get(questionId).sfmRule = buildSFMRuleClass.buildSFM2Rule(businessRuleRec, SFM_DesignerUtils.entity_businessrule, false);
                        }                    
                    }
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, ' getListOfQuestions - Exception ' + ex.getMessage());
            throw ex;
        }
        return questionMetaMap.values();
    }
    public List<SFM_WrapperDef2.SFM2_ResponseOptionMeta> getListOfResponseSet(){
        List<SFM_WrapperDef2.SFM2_ResponseOptionMeta> responseMetaList = new List<SFM_WrapperDef2.SFM2_ResponseOptionMeta>();
        try{
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__QB_Response_Set__c', new List<String>{'Id','Name','SVMXC__Response_Set_Values__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }  
        for(SVMXC__QB_Response_Set__c responseSet : [SELECT Id, Name, SVMXC__Response_Set_Values__c FROM SVMXC__QB_Response_Set__c]){
            SFM_WrapperDef2.SFM2_ResponseOptionMeta responseMetaRecord = new SFM_WrapperDef2.SFM2_ResponseOptionMeta();
            responseMetaRecord.responseId = responseSet.Id;
                responseMetaRecord.name = responseSet.Name;
            responseMetaRecord.values = responseSet.SVMXC__Response_Set_Values__c != null ? responseSet.SVMXC__Response_Set_Values__c.split(';') : null;
            responseMetaList.add(responseMetaRecord);
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, ' getListOfResponseSet - Exception ' + ex.getMessage());
            throw ex;
        }
        return responseMetaList;
    }
    /**
     * This method is used to save single response set to the Salesforce Org.
     * 
     * @param responseSet ResponseSet details to be saved.
     * 
     * @return Returns instance of SFM_WrapperDef2.SFM2_Response with saved responseSet information.
     */
    public SVMXC.SFM_WrapperDef2.SFM2_Response saveResponseSet( final SFM_WrapperDef2.SFM2_ResponseOptionMeta responseSet ) {
        System.debug( LoggingLevel.DEBUG, 'saveResponseSet() - enter');
        final SVMXC.SFM_WrapperDef2.SFM2_Response response = new SVMXC.SFM_WrapperDef2.SFM2_Response();
        response.success = true;
        try {
            // Verify request argument for valid responseSet.
            if( responseSet != null && responseSet.values != null && !responseSet.values.isEmpty() && String.isNotEmpty( responseSet.name ) ) {
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__QB_Response_Set__c', new List<String>{'SVMXC__Response_Set_Values__c'}, COMM_SecurityUtils.Access.Upsertable)){
                    System.debug( LoggingLevel.ERROR, 'saveResponseSet() : Field level access verification failed for field SVMXC__Response_Set_Values__c' );
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                // Retrieve responseSet for given responseSet Id 
                // or responseSet name to verify duplicate responseSet.
                final List<SVMXC__QB_Response_Set__c> responseSetRecordList = [SELECT Id FROM SVMXC__QB_Response_Set__c WHERE Name = :responseSet.name OR Id = :responseSet.responseId];
                // Update existing responseSet or create new responseSet.
                if( ( String.isEmpty( responseSet.responseId ) && responseSetRecordList.isEmpty() ) 
                   || ( String.isNotEmpty( responseSet.responseId ) && responseSetRecordList.size() == 1 ) ) {
                    // Create semicolon seperated string from list of strings.
                    final String responseSetValues = String.join(responseSet.values, ';') + ';';
                    final SVMXC__QB_Response_Set__c responseSetRecord = ( !responseSetRecordList.isEmpty() ) ? responseSetRecordList[0] : new SVMXC__QB_Response_Set__c();
                    responseSetRecord.Name = responseSet.name;
                    responseSetRecord.SVMXC__Response_Set_Values__c = responseSetValues;
                    upsert responseSetRecord;
                    responseSet.responseId = responseSetRecord.Id;
                    //set saved responseSet to response object.
                    response.data = responseSet;
                    System.debug( LoggingLevel.INFO, 'saveResponseSet() : ResponseSet saved successfully');
                } else if( ( String.isEmpty( responseSet.responseId ) && !responseSetRecordList.isEmpty() ) || responseSetRecordList.size() > 1 ) {
                    // Duplicate responseSet name validation.
                    response.success = false;
                    response.message = System.Label.SFM001_TAG685;
                    System.debug( LoggingLevel.ERROR, 'saveResponseSet() : Response Set already exists with name = ' + responseSet.name );
                } else if( String.isNotEmpty( responseSet.responseId ) && responseSetRecordList.isEmpty() ) {
                    // Invalid responseSet Id validation.
                    response.success = false;
                    response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
                    System.debug( LoggingLevel.ERROR, 'saveResponseSet() : Response Set not exists for given responseId. responseId= ' + responseSet.responseId );
                }
            } else {
                // Invalid request validation
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
                System.debug( LoggingLevel.ERROR, 'saveResponseSet() : Invalid argument responseSet. responseSet=' + responseSet );
            }
        }
        catch( QueryException e ) {
            response.success = false;
            response.message = System.Label.SFM002_TAG015; // An unexpected internal error occurred. Please report this to your ServiceMax administrator.
            System.debug( LoggingLevel.ERROR, 'saveResponseSet() : Failed to execute query. Error= ' + e.getStackTraceString() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'saveResponseSet() : Failed to save Response Set. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveResponseSet() - exit; success= ' + response.success );
        }
        return response;
    }
    /**
     * This method is used to save single question information along with the 
     * associated response id to the Salesforce Org.
     * 
     * @param questionInfo question information to be saved.
     * 
     * @return Returns instance of SFM_WrapperDef2.SFM2_Response with saved question information.
     */
    public SVMXC.SFM_WrapperDef2.SFM2_Response saveQuestionInfo( final SFM_WrapperDef2.SFM2_QuestionMeta questionInfo ) {
        System.debug( LoggingLevel.DEBUG, 'saveQuestionInfo() - enter');
        final SVMXC.SFM_WrapperDef2.SFM2_Response response = new SVMXC.SFM_WrapperDef2.SFM2_Response();
        response.success = true;
        Savepoint sPoint = Database.setSavepoint();
        try {
            // Validate question information in the request.
            if( validateQuestionInfo( questionInfo ) ) {
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Question_Bank__c', new List<String>{'SVMXC__Question__c', 'SVMXC__Response_Type__c', 'SVMXC__QuestionID__c'}, COMM_SecurityUtils.Access.Upsertable)){
                    System.debug( LoggingLevel.ERROR, 'saveQuestionInfo() : Field level access verification failed for SVMXC__Question_Bank__c fields' );
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                SVMXC__Question_Bank__c questionBankRecord = new SVMXC__Question_Bank__c();
                if( String.isNotEmpty(questionInfo.questionId) ) {
                    questionBankRecord.Id = questionInfo.questionId;
                }
                if( String.isNotEmpty(questionInfo.responseId) ) {
                    questionBankRecord.SVMXC__Response_Set__c = questionInfo.responseId;
                }
                questionBankRecord.SVMXC__Help_URL__c = questionInfo.helpUrl;
                questionBankRecord.SVMXC__Question__c = questionInfo.question;
                questionBankRecord.SVMXC__Response_Type__c = questionInfo.qType;
                questionBankRecord.SVMXC__SM_Description_Required__c = questionInfo.descriptionRequired != null ? questionInfo.descriptionRequired : false;
                questionBankRecord.SVMXC__SM_Show_In_Smart_Doc__c = questionInfo.showInSmartDoc != null ? questionInfo.showInSmartDoc : false;
                // Generate new external question bank ID for new questions.
                if(String.isEmpty(questionInfo.questionExtId)){
                    questionInfo.questionExtId = generateQuestionId() + UserInfo.getOrganizationId();
                    
                    if( questionInfo.sfmRule != null && questionInfo.sfmRule.expressionsList != null ) {
                        for(SFM_WrapperDef2.SFM2_RuleExpression expressionDetail : questionInfo.sfmRule.expressionsList){
                            expressionDetail.sourceField = questionInfo.questionExtId;
                        }
                    }
                }
                questionBankRecord.SVMXC__QuestionID__c = questionInfo.questionExtId;
                upsert questionBankRecord;
                System.debug(LoggingLevel.INFO, 'saveQuestionInfo() : Upserted Question Bank record.');
                // Create question validation rule and junction object if not exists. 
                if( questionInfo.sfmRule != null && questionInfo.sfmRule.ruleDetail != null ) {
                    if(questionInfo.sfmRule.ruleDetail.entityName == null){
                        questionInfo.sfmRule.ruleDetail.entityName = SFM_DesignerUtils.generateUniqueId('DVR');
                    }
                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'SVMXC__Question_Bank__c', 'SVMXC__Process1__c'}, COMM_SecurityUtils.Access.Accessible)){
                        System.debug( LoggingLevel.ERROR, 'saveQuestionInfo() : Field level access verification failed for SVMXC__ServiceMax_Processes__c fields' );
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    System.debug(LoggingLevel.DEBUG, 'saveQuestionInfo() : Saving question rule....');
                    // Create or update question validationn rule.
                    SFM_WrapperDef2.SFM2_Rule sfmRule = questionInfo.sfmRule = new SFM_SaveExpression().saveRule(questionInfo.sfmRule, SFM_DesignerUtils.entity_businessrule, true, null);
                    System.debug(LoggingLevel.INFO, 'saveQuestionInfo() : Question rule saved successfully');
                    SVMXC__ServiceMax_Processes__c qbValidationRecord = new SVMXC__ServiceMax_Processes__c();
                    RecordType qbRecordType = [Select Id, Name From RecordType Where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'QB Validation'];
                    // Create question junction object only if its new question.
                    if( String.isNotEmpty(questionInfo.questionId) ) {
                        List<SVMXC__ServiceMax_Processes__c> junctionRecordList = [SELECT id, SVMXC__Process1__c FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = 'QB Validation' AND SVMXC__Question_Bank__c = :questionInfo.questionId ];
                        if( !junctionRecordList.isEmpty() ) {
                            qbValidationRecord.id = junctionRecordList[0].id;
                        }
                    }
                    qbValidationRecord.RecordTypeId = qbRecordType.Id;
                    qbValidationRecord.SVMXC__Question_Bank__c = questionBankRecord.id;
                    qbValidationRecord.SVMXC__Process1__c = questionInfo.sfmRule.ruleDetail.entityId;
                    upsert qbValidationRecord;
                    System.debug( LoggingLevel.INFO, 'saveQuestionInfo() : Created question junction object with newly created validation rule.');
                } else if( String.isNotEmpty( questionInfo.questionId ) ) {
                    // Delete junction object between question bank and validation rule if any in update scenario.
                    List<SVMXC__ServiceMax_Processes__c> junctionRecordList = [SELECT id, SVMXC__Process1__c FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = 'QB Validation' AND SVMXC__Question_Bank__c = :questionInfo.questionId ];
                    if(  !junctionRecordList.isEmpty() ) {
                        if( !COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c') ) {
                            System.debug( LoggingLevel.ERROR, 'saveQuestionInfo() : Field level access verification failed for SVMXC__ServiceMax_Processes__c object' );
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        // Delete rule created for this question.
                        List<SVMXC__ServiceMax_Processes__c> ruleList = [SELECT id FROM SVMXC__ServiceMax_Processes__c WHERE Id = :junctionRecordList[0].SVMXC__Process1__c ];
                        if( !ruleList.isEmpty() ) {
                            // Delete rule details
                            List<SVMXC__ServiceMax_Config_Data__c> ruleDetails = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__c = :ruleList[0].Id ]; 
                            delete ruleDetails;
                            junctionRecordList.addAll(ruleList);
                        }
                        delete junctionRecordList;
                    }
                }
                if(questionInfo.defaultValues != null || questionInfo.defaultLiteralValue != null){
                SFM_QuestionBankUtils.DefaultResponseSetWrapper defaultResponseWrapper = new SFM_QuestionBankUtils.DefaultResponseSetWrapper();
                defaultResponseWrapper.listOfDefaultValues = questionInfo.defaultValues;
                defaultResponseWrapper.literalValue = questionInfo.defaultLiteralValue;
                String serializedDefaultValues = JSON.serialize(defaultResponseWrapper);
                SVMXC__SM_Default_Checklist_Response__c defaultChecklistResponse = new SVMXC__SM_Default_Checklist_Response__c();
                defaultChecklistResponse.SVMXC__SM_Default_Response__c = serializedDefaultValues;
                defaultChecklistResponse.SVMXC__SM_Question__c = questionBankRecord.Id;
                if(defaultResponseWrapper.literalValue != null){
                    defaultChecklistResponse.SVMXC__SM_Is_literal_Used__c = true;
                }
                if(questionInfo.defaultResponseId != null){
                    defaultChecklistResponse.Id = questionInfo.defaultResponseId;
                }
                upsert defaultChecklistResponse;
                    questionInfo.defaultResponseId = defaultChecklistResponse.Id;
                } else if(questionInfo.defaultResponseId != null){
                    List<SVMXC__SM_Default_Checklist_Response__c> defaultResponseDeleteList = [SELECT Id FROM SVMXC__SM_Default_Checklist_Response__c WHERE Id =: questionInfo.defaultResponseId];
                    if(!defaultResponseDeleteList.isEmpty()){
                        delete defaultResponseDeleteList;
                    }
                }
                // Update question bank id to response object.
                questionInfo.questionId = questionBankRecord.id;
                
                // Update question tags
                SFM_DesignerUtils.manageSVMXTags( questionInfo.tagsList, questionInfo.questionId);
                //set upserted question information to response data.
                response.data = questionInfo;
                System.debug( LoggingLevel.INFO, 'saveQuestionInfo() : Question information saved successfully');
            } else {
                // Invalid request validation
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
                System.debug( LoggingLevel.ERROR, 'saveQuestionInfo() : Invalid argument responseSet. questionInfo=' + questionInfo );
            }
        }
        catch( QueryException e ) {
            Database.rollback( sPoint );
            response.success = false;
            response.message = System.Label.SFM002_TAG015; // An unexpected internal error occurred. Please report this to your ServiceMax administrator.
            System.debug( LoggingLevel.ERROR, 'saveQuestionInfo() : Failed to execute query. Error= ' + e.getStackTraceString() );
            throw e;
        }
        catch( Exception e ) {
            Database.rollback( sPoint );
            System.debug( LoggingLevel.ERROR, 'saveQuestionInfo() : Failed to save Question information. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveQuestionInfo() - exit; success= ' + response.success );
        }
        return response;
    }
    /**
     * This method is used to validate question information requested to save or update.
     */
    @TestVisible private boolean validateQuestionInfo( final SFM_WrapperDef2.SFM2_QuestionMeta questionInfo ) {
        System.debug( LoggingLevel.DEBUG, 'validateQuestionInfo() - enter' );
        Boolean isValid = true;
        try {
            // Verify questionInfo, question type and question in the request.
            if( questionInfo != null && String.isNotEmpty( questionInfo.qType ) && String.isNotEmpty(questionInfo.question) ) {
                // The responseSet ID should not be empty for question types checkbox, 
                // picklist, multi-select and radio button.
                if( String.isEmpty( questionInfo.responseId ) && (questionInfo.qType.equalsIgnoreCase('Checkbox') || questionInfo.qType == 'Picklist' || questionInfo.qType == 'Multi-select Picklist' || questionInfo.qType == 'Radio Button') ) {
                    isValid = false;
                    System.debug( LoggingLevel.ERROR, 'validateQuestionInfo() : Invalid responseSet ID for requested question type.');
                }
                // In update scenario, request must have question external ID.
                if( String.isNotEmpty(questionInfo.questionId) && String.isEmpty(questionInfo.questionExtId ) ) {
                    isValid = false;
                    System.debug( LoggingLevel.ERROR, 'validateQuestionInfo() : Invalid external question ID');
                }
            } else {
                isValid = false;
                System.debug( LoggingLevel.ERROR, 'validateQuestionInfo() : Invalid questionInfo/questionType/question.');
            }
        }
        catch(Exception e) {
            isValid = false;
            System.debug( LoggingLevel.ERROR, 'validateQuestionInfo() : Failed to validate Question information. Error= ' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateQuestionInfo() - exit; isValid=' + isValid );
        }
        return isValid;
    }
    /**
     * This method is used to generate unique question bank ID in sequence.
     */
    @TestVisible private String generateQuestionId() {
        System.debug( LoggingLevel.DEBUG, 'generateQuestionId() - enter' );
        String questionId = 'QB000001';
        try {
            // Retrieve last created question bank ID.
            List<SVMXC__Question_Bank__c> questionBankRecord = [SELECT SVMXC__QuestionID__c FROM SVMXC__Question_Bank__c WHERE NOT( (SVMXC__QuestionID__c LIKE 'QB-%') OR (SVMXC__QuestionID__c LIKE 'QB\\_%') OR SVMXC__QuestionID__c = null ) ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
            if( questionBankRecord != null && questionBankRecord.size() > 0 ) {
                String lastQuestionId = questionBankRecord[0].SVMXC__QuestionID__c;
                Integer subStringIndex = 2;
                if( lastQuestionId.length() == ( questionId.length() + UserInfo.getOrganizationId().length() ) ) {
                    //subStringIndex = UserInfo.getOrganizationId().length() + subStringIndex;
                    lastQuestionId = lastQuestionId.left(lastQuestionId.length() - UserInfo.getOrganizationId().length());
                }
                questionId = 'QB';
                Integer newNumber = Integer.valueOf( lastQuestionId.substring(subStringIndex) ) + 1;
                Integer noLength = String.valueOf(newNumber).length();
                for(Integer i = noLength; i < 6; i++ ) {
                    questionId += '0';
                }
                questionId += newNumber;
                System.debug(LoggingLevel.INFO ,'generateQuestionId() : Generated question ID ' + questionId );
            }
        }
        catch( QueryException e ) {
            System.debug( LoggingLevel.ERROR, 'generateQuestionId() : Failed to retrieve question back records. Error= ' + e.getStackTraceString() );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'generateQuestionId() : Failed to generate questionId. Error= ' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'generateQuestionId() - exit; questionId= ' + questionId );
        }
        return questionId;
    }
    public class DefaultResponseSetWrapper{
        public List<String> listOfDefaultValues; 
        public String literalValue;
        public DefaultResponseSetWrapper(){
        }
    }
}