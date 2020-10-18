global class SFM_WrapperDef
{
    
    //Constructor
    global SFM_WrapperDef()    
    {
        
    }

    //Start  for BAC-2362/040053
    public String intfRecId{get;set;}
    public String intfRecordId{get;set;}
    public String sfwOutputTemplate{get;set;}
    public PageReference INTF_GetSFWHTML_WS(){ 
        System.debug('intfRecId '+intfRecId);
        intfRecordId = SVMXC.INTF_WebServicesDef.INTF_GetSFWHTML_WS(intfRecId, '');
        sfwOutputTemplate = JSON.serialize(SVMXC.INTF_WebServicesDef.INTF_GetSFWOutputTemplate_WS(intfRecId));
        //System.debug('sfwOutputTemplate '+sfwOutputTemplate);
        return null;
    }
    //End for BAC-2362/040053

    //----Start----Added this getter method for the story BAC-4835
    public Boolean isWizardVisible{
        get{
            Boolean wizardVisibleStatus = true;
            
            String strSettingValue = '';
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            Map<String, Map<String, String>> mapSubmoduleSettings = commSettings.SVMX_getSettingList(new List<String>{'SFW001'});
            if(mapSubmoduleSettings != null && mapSubmoduleSettings.size() > 0 && mapSubmoduleSettings.containsKey('SFW001')){
                Map<String, String> mapSetting = mapSubmoduleSettings.get('SFW001');
                if(mapSetting != null && mapSetting.containsKey('SET003') && !String.isBlank(mapSetting.get('SET003'))){
                    strSettingValue = mapSetting.get('SET003').trim();
                }
            }
            System.debug('strSettingValue_Wiz: '+strSettingValue);
            
            if(!String.isBlank(strSettingValue)){
                String strUiTheme = UserInfo.getUiTheme();
                System.debug('strUiTheme_Wiz: '+strUiTheme);
                if((strUiTheme.equalsIgnoreCase('Theme4t') && strSettingValue.containsIgnoreCase('Salesforce1')) || ((strUiTheme.equalsIgnoreCase('Theme4d') || strUiTheme.equalsIgnoreCase('Theme4u')) && strSettingValue.containsIgnoreCase('Lightning'))){
                    wizardVisibleStatus = false;
                }
                System.debug('wizardVisibleStatus_Wiz: '+wizardVisibleStatus);
            }
            return wizardVisibleStatus;
        }
    }
    //----End----BAC-4835
    
        global class SFM_Request_IntegrityCheck
    {
        webservice String processId {get;set;}
        webservice List<SFM_WrapperDef.SFM_Request_ObjectFields> objects {get;set;}
    }
    
    global class SFM_Request_ObjectFields 
    {
        webservice String relatedTo {get;set;} // e.g: Mapping/Expression
        webservice String relatedReference {get;set;} // e.g: MAP001, etc
        webservice String objectAPI {get;set;}
        webservice List<SFM_WrapperDef.SFM_Request_FieldProperties> fields {get;set;}
    }
    
    global class SFM_Request_FieldProperties
    {
        webservice String fieldAPI {get;set;}
        webservice String fieldType {get;set;}
        webservice Integer fieldLength {get;set;}
        webservice String referenceTo {get;set;}
        webservice String relationshipName {get;set;}
        webservice boolean isCascadeDelete {get;set;}
        
        public SFM_Request_FieldProperties(String fieldAPI, String fieldType, Integer fieldLength, String referenceTo, String relationshipName, boolean isCascadeDelete)
        {
            this.fieldAPI = fieldAPI;
            this.fieldType = fieldType;
            this.fieldLength = fieldLength;
            this.referenceTo = referenceTo;
            this.relationshipName = relationshipName;
            this.isCascadeDelete = isCascadeDelete;
        }
        public SFM_Request_FieldProperties()
        {
            
        }
    }
    
    //Wrapper class for key value 
    global class SFM_StringMap
    {
        webservice String key {get;set;}
        webservice String value{get;set;}
        webservice String value1{get;set;}
        webservice String fieldsToNull{get;set;}
                
        global SFM_StringMap(String k,String v) 
        {
            key = k;
            value = v;
        }
        
        global SFM_StringMap(){
            
        }
        global SFM_StringMap(String key,String value,String value1){
            this.key = key;
            this.value = value;
            this.value1 = value1;
        }
    }
    global class SFM_StringFieldMap
    {
        webservice String key {get;set;}
        webservice String value{get;set;}
        webservice String ftype{get;set;}
        webservice String fieldsToNull{get;set;}
        webservice List<SFM_StringMap> picklistLabelValue{get;set;}//added for dynamic checklist response
        
    global SFM_StringFieldMap(String k,String v,String s) 
        {
            key = k;
            value = v;
            ftype = s;
        }
        
        global SFM_StringFieldMap(){
            
        }
    }
    global class SFM_StringListMap
    {
        webservice String key {get;set;}
        webservice List<String> valueList = new List<String>();
        webservice String fieldsToNull{get;set;}
        
        global SFM_StringListMap(String key,List<String> valueList)
        {
            this.key = key;
            this.valueList = valueList;
        }
        global SFM_StringListMap()
        {
            
        }
        
        global List<String> getvalueList(){return valueList;}
        global void setvalueList(List<String> s ){valueList = s;}
    }
    global class SFM_MapStringMap
    {
        webservice String key {get;set;}
        webservice List<SFM_StringMap> valueMap = new List<SFM_StringMap>();
        webservice String fieldsToNull{get;set;}
        
        global SFM_MapStringMap(String key,List<SFM_StringMap> valueMap)
        {
            this.key = key;
            this.valueMap = valueMap;
        }
        global SFM_MapStringMap()
        {
            
        }
        
        global List<SFM_StringMap> getvalueList(){return valueMap;}
        global void setvalueMap(List<SFM_StringMap> s ){valueMap = s;}
    }
    global class SVMXMessage {
        
        webservice String message {get;set;}
        webservice String details  {get;set;}
        webservice String key  {get;set;}
        
        global SVMXMessage(String message,String details){
            this.message = message;
            this.details = details;
        }
        global SVMXMessage(String message,String details,String key){
            this.message = message;
            this.details = details;
            this.key = key;
        }
        global SVMXMessage(){}
    }
    
    //Wrapper class of bubble with field value and its bubble class 
    global class SFM_BubbleWrapper
    {
        webservice SFM_StringMap fieldvalue = new SFM_StringMap();
        webservice List<SFM_StringMap> bubbleinfo = new List<SFM_StringMap>();
        webservice String fieldapiname {get;set;}
        webservice SFM_Response response {get;set;}
        global SFM_BubbleWrapper()
        {
            response = new SFM_Response();
              
        }
        //Adding one more constructor for avoiding auto-initializing of response variable
        //which is cause a performance degradation during JsrGetPageData call for the story BAC-4410
    //BAC-5357
        global SFM_BubbleWrapper(String fieldapiname) {
            this.fieldapiname = fieldapiname;
        }
    }
    //Wrapper class of bubble with field value and its bubble class 
    global class SFM_DetailBubbleWrapper
    {
        webservice Sobject sobjectinfo;
        webservice String sourceRecordId{get;set;} // hold the source record id for the target record.
        webservice List<SFM_BubbleWrapper> bubbleinfolist = new List<SFM_BubbleWrapper>(); 
        global SFM_DetailBubbleWrapper(){}
    }
    
    global class PMaxException extends Exception {}
    
    //Wrapper class of SFM_Request
    global class SFM_Request
    {
        webservice  string userId {get;set;}
        webservice  String groupId {get;set;}
        webservice  String profileId {get;set;}
        webservice  String fieldsToNull {get;set;}
        webservice  String clientType {get;set;}
        webservice  List<SFM_StringMap> stringMap = new List<SFM_StringMap>(); 
        webservice  List<SFM_StringListMap> stringListMap = new List<SFM_StringListMap>();
        webservice  SFM_LookupRequest lookupRequest{get;set;}
        webservice SFM_DocTemplate docTemplate {get;set;}
        webservice SFM_BizRuleInfo bizRuleInfo = new SFM_BizRuleInfo(); //Biz rule 
        webservice SFM_QuestionValidationRuleInfo QuestionValidationRuleInfo = new SFM_QuestionValidationRuleInfo(); //Biz rule 
        
        webservice List<SFM_QuestionBank> lstQuestionBank = new List<SFM_QuestionBank>();
        webservice List<SFM_FieldUpdateRuleInfo> fieldUpdateRuleInfoList = new List<SFM_FieldUpdateRuleInfo>();
        webservice  SFM_MapStringMap MapStringMap = new SFM_MapStringMap();
        //Aptest
        webservice  list<SFM_MapStringMap> lstMapStringMap = new list<SFM_MapStringMap>();
        global SFM_Request(String userId,String groupId,String profileId,List<SFM_StringMap> stringMap)
        {
            this.userId = userId;
            this.groupId = groupId;
            this.profileId = profileId;
            this.stringMap = stringMap;
        }
        
        global SFM_Request()
        {
            
        }
        global List<SFM_StringMap> getstringMap(){return stringMap;}
        global void setstringMap(List<SFM_StringMap> s){stringMap = s ;}
        global List<SFM_StringListMap> getstringListMap(){return stringListMap;}
        global void setstringListMap(List<SFM_StringListMap> s){stringListMap = s ;}
        global SFM_BizRuleInfo getbizRuleInfo(){return this.bizRuleInfo;}
        global void setbizRuleInfo(SFM_BizRuleInfo bizRuleInfo){this.bizRuleInfo = bizRuleInfo;}
        global SFM_MapStringMap getMapStringMap(){return MapStringMap;}
        global void setMapStringMap(SFM_MapStringMap s){MapStringMap = s ;}
        global SFM_QuestionValidationRuleInfo getQuestionValidationRuleInfo(){return this.QuestionValidationRuleInfo;}
        global void setQuestionValidationRuleInfo(SFM_QuestionValidationRuleInfo QuestionValidationRuleInfo){this.QuestionValidationRuleInfo = QuestionValidationRuleInfo;}
        
        global List<SFM_FieldUpdateRuleInfo> getFieldUpdateRuleInfoList() { 
            return this.fieldUpdateRuleInfoList; 
        }
        global void setFieldUpdateRuleInfoList(List<SFM_FieldUpdateRuleInfo> fieldUpdateRuleInfoList) { 
            this.fieldUpdateRuleInfoList = fieldUpdateRuleInfoList;
            
        
        }
        
        global List<SFM_MapStringMap> getlstMapStringMap(){return lstMapStringMap;}
        global void setlstMapStringMap(List<SFM_MapStringMap> s){lstMapStringMap = s ;}
    }
    
    //Wrapper class of SFM_Response
    global class SFM_Response 
    {
        webservice Boolean success {get;set;}
        webservice String message {get;set;}
        webservice String messageType {get;set;}
        webservice String tagId {get;set;}
        webservice String eventType {get;set;}
        webservice List<SFM_StringMap> stringMap = new List<SFM_StringMap>();
        webservice List<SFM_StringFieldMap> stringFieldMap = new List<SFM_StringFieldMap>();
        webservice List<SVMX_Debug.SMAX_Debug> logMsg;
        webservice List<String> resultIds = new List<String>();
        webservice  List<SFM_StringListMap> StringLstMap = new List<SFM_StringListMap>();
        webservice  List<SFM_MapStringMap> MapStringMap = new List<SFM_MapStringMap>();
        webservice list<Sobject> records = new list<Sobject>();
        webservice SFM_DocTemplate docTemplate {get;set;}
        webservice SVMXMessage msgDetails {get;set;}
        webservice list<SVMXMessage> messages = new list<SVMXMessage>();
        webservice list<SFM_StringSobjectMap> sobjectMap = new list<SFM_StringSobjectMap>();
        webservice list<FieldSetWithSorting> lstFieldSetWithSorting = new list<FieldSetWithSorting>();
        webservice List<SFM_BizRuleInfo> lstBizRuleInfo = new List<SFM_BizRuleInfo>();//Biz Rules
        //webservice List<SFM_QuestionValidationRuleInfo> lstChecklistValidationRuleInfo = new List<SFM_QuestionValidationRuleInfo>();
        webservice SFM_QuestionValidationRuleInfo QuestionValidationRuleInfo = new SFM_QuestionValidationRuleInfo();
        webservice List<SFM_FieldUpdateRuleInfo> fieldUpdateRuleInfoList = new List<SFM_FieldUpdateRuleInfo>();
        public ProfileData profileData{get;set;}   
        webservice List<SFM_QuestionBank> lstQuestionBank = new List<SFM_QuestionBank>();
        webservice List<SFM_ChecklistInfo> lstChecklistInfo = new List<SFM_ChecklistInfo>();
        webservice List<SFM_SelectedChecklistProcess> lstChecklistBusinessProcessInfo {get;set;}
        webservice ExceptionInformation objExceptionInformation {set; get;} //Added for the story BAC-3839 for sending exception information
        webservice List<ExceptionForDetailRecord> lstNewDetailRecordIds {set; get;} //Added for the story BAC-4027 for sending newly inserted detail record id
        webservice String callType {get;set;} //Added for the story BAC-4027 for sending call type and valid value will be "save for linked sfm"
        
        global SFM_Response(Boolean success,String message,String tagId,List<SFM_StringMap> stringMap,List<SVMX_Debug.SMAX_Debug> logMsg,List<String> resultIds)//List<SFM_StringFieldMap> stringFieldMap commented by amar
        {
            this.success = success;
            this.message = message;
            this.tagId = tagId;
            this.stringMap = stringMap;
            this.logMsg = logMsg;
            this.resultIds=resultIds;
             
            //this.stringFieldMap=stringFieldMap;
        }
        global SFM_Response() 
        {
             
        }
        global List<SFM_StringMap> getstringMap(){return stringMap;}
        global void setstringMap(List<SFM_StringMap> s){stringMap = s ;}
        global List<SFM_StringFieldMap> getstringFieldMap(){return stringFieldMap;}
        global void setstringFieldMap(List<SFM_StringFieldMap> s){stringFieldMap = s ;}
        global List<SFM_StringListMap> getStringLstMap(){return StringLstMap;}
        global void setStringLstMap(List<SFM_StringListMap> s){StringLstMap = s ;}
        global List<SFM_MapStringMap> getMapStringMap(){return MapStringMap;}
        global void setMapStringMap(List<SFM_MapStringMap> s){MapStringMap = s ;}
        global List<SFM_StringSobjectMap> getsobjectMap(){return sobjectMap;}
        global void setsobjectMap(List<SFM_StringSobjectMap> s){sobjectMap = s ;}
        global list<FieldSetWithSorting> getlstFieldSetWithSorting(){return lstFieldSetWithSorting;}
        global void setlstFieldSetWithSorting(list<FieldSetWithSorting> lstFieldSetWithSorting){this.lstFieldSetWithSorting = lstFieldSetWithSorting;}
        global List<SFM_BizRuleInfo> getlstBizRuleInfo(){return this.lstBizRuleInfo;}
        global void setlstBizRuleInfo(List<SFM_BizRuleInfo> lstBizRuleInfo){this.lstBizRuleInfo = lstBizRuleInfo;}
        
        global SFM_QuestionValidationRuleInfo getQuestionValidationRuleInfo(){return this.QuestionValidationRuleInfo;}
        global void setQuestionValidationRuleInfo(SFM_QuestionValidationRuleInfo QuestionValidationRuleInfo){this.QuestionValidationRuleInfo = QuestionValidationRuleInfo;}
        global List<SFM_QuestionBank> getlstQuestionBank(){return this.lstQuestionBank;}
        global void setlstQuestionBank(List<SFM_QuestionBank> lstQuestionBank){this.lstQuestionBank = lstQuestionBank;}
        global List<SFM_ChecklistInfo> getlstChecklistInfo(){return this.lstChecklistInfo;}
        global void setlstChecklistInfo(List<SFM_ChecklistInfo> lstChecklistInfo){this.lstChecklistInfo = lstChecklistInfo;}
        
        global List<SFM_FieldUpdateRuleInfo> getFieldUpdateRuleInfoList() { 
            return this.fieldUpdateRuleInfoList; 
        }
        global void setFieldUpdateRuleInfoList(List<SFM_FieldUpdateRuleInfo> fieldUpdateRuleInfoList) { 
            this.fieldUpdateRuleInfoList = fieldUpdateRuleInfoList;
        }
    }

    //Added by Nidhi as part of lazy loading BAC-4680
    public class SFM_ResponseV2{
        public String message;
        public Boolean success;
    }
    
    //-----Start-------Added for the story BAC-3839 for sending exception information
    global class ExceptionInformation{
        webservice Record headerRecord {get;set;}
        webservice List<ExceptionForDetailRecord> detailRecord {get;set;}
    }
    global class ExceptionForDetailRecord{
        webservice String aliasId {get;set;}
        webservice List<Record> recordList {get;set;}
    }
    global class Record{
        webservice String recordId {get;set;}
        webservice String fieldApiName {get;set;}
        webservice String rowIndex {get;set;}
        webservice String errorMessage {get;set;}
    }
    //-----End-------Added for the story BAC-3839 for sending exception information
    
    global class SFM_Request_ProcessNode
    {
        webservice SFM_Request request{get;set;}
        webservice String fieldsToNull{get;set;}
        webservice List<SVMXC__ServiceMax_Processes__c> processNodes = new List<SVMXC__ServiceMax_Processes__c>();
        global SFM_Request_ProcessNode(List<SVMXC__ServiceMax_Processes__c> processNodes)//,String uid,String gid,String pid,List<SFM_StringMap> strmap
        {
            //super();//uid,gid,pid,strmap
            this.processNodes = processNodes;
            request = new SFM_Request();
        }
        global List<SVMXC__ServiceMax_Processes__c> getprocessNodes(){return processNodes;}
        global void setprocessNodes(List<SVMXC__ServiceMax_Processes__c> s){processNodes = s;}
    }
    global class SFM_Response_ProcessNode
    {
        webservice SFM_Response response{get;set;}
        webservice List<SVMXC__ServiceMax_Processes__c> processNodes = new List<SVMXC__ServiceMax_Processes__c>();
        global SFM_Response_ProcessNode(List<SVMXC__ServiceMax_Processes__c> processNodes)//,Boolean s,String msg,String tid,List<SFM_StringMap> strmap
        {
            //super();//s,msg,tid,strmap
            this.processNodes = processNodes;
            response = new SFM_Response();
        }
        global List<SVMXC__ServiceMax_Processes__c> getprocessNodes(){return processNodes;}
        global void setprocessNodes(List<SVMXC__ServiceMax_Processes__c> s){processNodes = s;}
    }

    global class SFM_Request_ProcessNodeInfo
    {
        webservice SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        webservice List<SFM_ProcessNodeDetail> processNodeSourceObject = new List<SFM_ProcessNodeDetail>();
        webservice List<SFM_ProcessNodeDetail> processNodeTargetObject = new List<SFM_ProcessNodeDetail>();
        webservice list<SVMXC__SFM_Event__c> sfmEvents = new list<SVMXC__SFM_Event__c>();
        webservice SFM_Request request{get;set;}
        webservice String fieldsToNull{get;set;}
        webservice List<SFM_SelectedChecklistProcess> lstSelectedChecklistProcess = new List<SFM_SelectedChecklistProcess>();//added for checklist in output doc feature for receiving process details
        
        global SVMXC__ServiceMax_Processes__c getprocessNodes(){return processNodes;}
        global void setprocessNodes(SVMXC__ServiceMax_Processes__c s){processNodes = s;}
        global List<SFM_ProcessNodeDetail> getprocessprocessNodeSourceObject() {return processNodeSourceObject;}
        global void setprocessNodeSourceObject(List<SFM_ProcessNodeDetail> s) { processNodeSourceObject = s;}
        global List<SFM_ProcessNodeDetail> getprocessNodeTargetObject() {return processNodeTargetObject;}
        global void setprocessNodeTargetObject(List<SFM_ProcessNodeDetail> s) { processNodeTargetObject = s;}
        global list<SVMXC__SFM_Event__c> getSFMEvents(){return sfmEvents;}
        global void setSFMEvents(list<SVMXC__SFM_Event__c> sfmEvents){this.sfmEvents = sfmEvents;}
        
        global SFM_Request_ProcessNodeInfo(SVMXC__ServiceMax_Processes__c processNodes,List<SFM_ProcessNodeDetail> processNodeSourceObject, List<SFM_ProcessNodeDetail> processNodeTargetObject)//,Boolean s,String msg,String tid,List<SFM_StringMap> strmap
        {
            request = new SFM_Request();
            this.processNodes = processNodes;
            this.processNodeSourceObject = processNodeSourceObject;
            this.processNodeTargetObject = processNodeTargetObject;
        }
        
        global SFM_Request_ProcessNodeInfo(SVMXC__ServiceMax_Processes__c processNodes,List<SFM_ProcessNodeDetail> processNodeSourceObject, List<SFM_ProcessNodeDetail> processNodeTargetObject,list<SVMXC__SFM_Event__c> sfmEvents)
        {
            request = new SFM_Request();
            this.processNodes = processNodes;
            this.processNodeSourceObject = processNodeSourceObject;
            this.processNodeTargetObject = processNodeTargetObject;
            this.sfmEvents = sfmEvents;
        }
        global SFM_Request_ProcessNodeInfo()
        {
            
        }
        
       
    }
        
    global class SFM_Response_ProcessNodeInfo
    {
        webservice SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        webservice List<SFM_ProcessNodeDetail> processNodeSourceObject = new List<SFM_ProcessNodeDetail>();
        webservice List<SFM_ProcessNodeDetail> processNodeTargetObject = new List<SFM_ProcessNodeDetail>();
        webservice list<SVMXC__SFM_Event__c> sfmEvents = new list<SVMXC__SFM_Event__c>();
        webservice SFM_Response response{get;set;}
        webservice List<SFM_SelectedChecklistProcess> lstSelectedChecklistProcess = new List<SFM_SelectedChecklistProcess>();//added for checklist in output doc feature for sending process details
        
        global SVMXC__ServiceMax_Processes__c getprocessNodes(){return processNodes;}
        global void setprocessNodes(SVMXC__ServiceMax_Processes__c s){processNodes = s;}
        global List<SFM_ProcessNodeDetail> getprocessprocessNodeSourceObject() {return processNodeSourceObject;}
        global void setprocessNodeSourceObject(List<SFM_ProcessNodeDetail> s) { processNodeSourceObject = s;}
        global List<SFM_ProcessNodeDetail> getprocessNodeTargetObject() {return processNodeTargetObject;}
        global void setprocessNodeTargetObject(List<SFM_ProcessNodeDetail> s) { processNodeTargetObject = s;}
        global list<SVMXC__SFM_Event__c> getSFMEvents(){return sfmEvents;}
        global void setSFMEvents(list<SVMXC__SFM_Event__c> sfmEvents){this.sfmEvents = sfmEvents;}
        
        global SFM_Response_ProcessNodeInfo(SVMXC__ServiceMax_Processes__c processNodes,List<SFM_ProcessNodeDetail> processNodeSourceObject, List<SFM_ProcessNodeDetail> processNodeTargetObject)//,Boolean s,String msg,String tid,List<SFM_StringMap> strmap
        {
            response = new SFM_Response();
            this.processNodes = processNodes;
            this.processNodeSourceObject = processNodeSourceObject;
            this.processNodeTargetObject = processNodeTargetObject;
        }
        global SFM_Response_ProcessNodeInfo()
        {
            
        }
    }
    
    //added for checklist in output doc feature for sending and receiving process details
    global class SFM_SelectedChecklistProcess{
        webservice String selectedChecklistVersion;
        webservice String selectedChecklistId;
        webservice SVMXC__ServiceMax_Processes__c checklistProcessRecord = new SVMXC__ServiceMax_Processes__c();
        webservice SVMXC__ServiceMax_Processes__c checklistCriteriaProcess = new SVMXC__ServiceMax_Processes__c();
        webservice List<SVMXC__ServiceMax_Config_Data__c> lstExpressionRecord = new List<SVMXC__ServiceMax_Config_Data__c>();
        webservice List<String> expressionsToDelete {get;set;}
        
        global String getselectedChecklistVersion(){return selectedChecklistVersion;}
        global void setselectedChecklistVersion(String s){selectedChecklistVersion = s;}
        global SVMXC__ServiceMax_Processes__c getchecklistProcessRecord(){return checklistProcessRecord;}
        global void setchecklistProcessRecord(SVMXC__ServiceMax_Processes__c s){checklistProcessRecord = s;}
        global SVMXC__ServiceMax_Processes__c getchecklistCriteriaProcess(){return checklistCriteriaProcess;}
        global void setchecklistCriteriaProcess(SVMXC__ServiceMax_Processes__c s){checklistCriteriaProcess = s;}
        global List<SVMXC__ServiceMax_Config_Data__c> getlstExpressionRecord(){return lstExpressionRecord;}
        global void setlstExpressionRecord(List<SVMXC__ServiceMax_Config_Data__c> s){lstExpressionRecord = s;}
        
        global SFM_SelectedChecklistProcess(){}
        global SFM_SelectedChecklistProcess(SVMXC__ServiceMax_Processes__c checklistProcessRecord, SVMXC__ServiceMax_Processes__c checklistCriteriaProcess, List<SVMXC__ServiceMax_Config_Data__c> lstExpressionRecord){
            this.checklistProcessRecord =  checklistProcessRecord;
            this.checklistCriteriaProcess = checklistCriteriaProcess;
            this.lstExpressionRecord = lstExpressionRecord;
        }
    }
    
    global class SFM_ProcessNodeDetail
    {
        webservice SVMXC__ServiceMax_Processes__c processNodeObejct = new SVMXC__ServiceMax_Processes__c();
        webservice List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        webservice List<SVMXC__ServiceMax_Processes__c> processBizRules = new List<SVMXC__ServiceMax_Processes__c>();//Process Business Rules
        webservice List<SVMXC__ServiceMax_Processes__c> linkedProcesses = new List<SVMXC__ServiceMax_Processes__c>();//Linked Process
        webservice String fieldsToNull{get;set;}
        global SVMXC__ServiceMax_Processes__c getprocessNodeObejct() {return processNodeObejct;}
        global void setprocessNodeObejct(SVMXC__ServiceMax_Processes__c s) { processNodeObejct = s;}
        global List<SVMXC__ServiceMax_Config_Data__c> getprocessSourceUpdates(){return processSourceUpdates;}
        global void setprocessSourceUpdates(List<SVMXC__ServiceMax_Config_Data__c> s){processSourceUpdates = s;}
        global List<SVMXC__ServiceMax_Processes__c> getprocessBizRules(){return processBizRules;}
        global void setprocessBizRules(List<SVMXC__ServiceMax_Processes__c> proBizRules){this.processBizRules = proBizRules;}
        global List<SVMXC__ServiceMax_Processes__c> getlinkedProcesses(){return linkedProcesses;}
        global void setlinkedProcesses(List<SVMXC__ServiceMax_Processes__c> linkedProcesses){this.linkedProcesses = linkedProcesses;}
        
        global SFM_ProcessNodeDetail(SVMXC__ServiceMax_Processes__c processNodeObejct,List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates)//,Boolean s,String msg,String tid,List<SFM_StringMap> strmap
        {
            this.processNodeObejct = processNodeObejct;
            this.processSourceUpdates = processSourceUpdates;
        }
        global SFM_ProcessNodeDetail()
        {
            
        }
    }
    
    global class SFM_Expression
    {
        webservice SVMXC__ServiceMax_Processes__c namedExpression = new SVMXC__ServiceMax_Processes__c();
        webservice List<SVMXC__ServiceMax_Config_Data__c> expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        webservice String fieldsToNull{get;set;}
        global SVMXC__ServiceMax_Processes__c getnamedExpression() {return namedExpression;}
        global void setnamedExpression(SVMXC__ServiceMax_Processes__c s) { namedExpression = s;} 
        global List<SVMXC__ServiceMax_Config_Data__c> getexpressionDetails(){return expressionDetails;}
        global void setexpressionDetails(List<SVMXC__ServiceMax_Config_Data__c> s){expressionDetails = s;}
        
        global SFM_Expression(SVMXC__ServiceMax_Processes__c namedExpression,List<SVMXC__ServiceMax_Config_Data__c> expressionDetails)
        {
            this.namedExpression = namedExpression;
            this.expressionDetails = expressionDetails;
        }
        global SFM_Expression(){}
    }
    
    global class SFM_Request_Expression
    {
        webservice List<SFM_Expression> expressions = new List<SFM_Expression>();
        webservice SFM_Request request{get;set;}
        webservice String fieldsToNull{get;set;}
        global List<SFM_Expression> getexpressions(){return expressions;}
        global void setexpressions(List<SFM_Expression> s){ expressions = s;}
        
        global SFM_Request_Expression(List<SFM_Expression> expressions)//,String uid,String gid,String pid,List<SFM_StringMap> strmap
        {
            //super();//uid,gid,pid,strmap
            request = new SFM_Request();
            this.expressions = expressions;
        }
    }
    global class SFM_Response_Expression
    {
        webservice List<SFM_Expression> expressions = new List<SFM_Expression>();
        
        global List<SFM_Expression> getexpressions(){return expressions;}
        global void setexpressions(List<SFM_Expression> s){ expressions = s;}
        webservice SFM_Response response{get;set;}
        global SFM_Response_Expression(List<SFM_Expression> expressions)//,Boolean s,String msg,String tid,List<SFM_StringMap> strmap
        {
            //super();//s,msg,tid,strmap
            response = new SFM_Response();
            this.expressions = expressions;
        }
        global SFM_Response_Expression(){}
    }
    global class SFM_FieldMapping{
        webservice SVMXC__ServiceMax_Config_Data__c fieldMapRecord = new SVMXC__ServiceMax_Config_Data__c();
        webservice List<SFM_StringMap> sourceFields = new List<SFM_StringMap>();
        webservice List<SFM_StringMap> sourceFieldsConstant = new List<SFM_StringMap>();
        global List<SFM_StringMap> sourceFieldsConstant(){return sourceFieldsConstant;}
        global void sourceFieldsConstant(List<SFM_StringMap> s){sourceFieldsConstant = s;}
        webservice  String fieldsToNull {get;set;}
        global SFM_FieldMapping(){
            
        }
        global SFM_FieldMapping(SVMXC__ServiceMax_Config_Data__c fieldMap, List<SFM_StringMap> sfields){
            this.fieldMapRecord = fieldMap;
            this.sourceFields = sfields;
            
        }
    }
    global class SFM_ObjectMap
    {
        webservice SVMXC__ServiceMax_Processes__c objectMap = new SVMXC__ServiceMax_Processes__c();
        webservice List<SFM_FieldMapping> fields = new List<SFM_FieldMapping>();
        webservice  String fieldsToNull {get;set;}
        global SVMXC__ServiceMax_Processes__c getobjectMap(){return objectMap;}
        global void setobjectMap(SVMXC__ServiceMax_Processes__c s){ objectMap = s;}
        global List<SFM_FieldMapping> fields(){return fields;}
        global void fields(List<SFM_FieldMapping> s){fields = s;}
        global SFM_ObjectMap(){
            
        }
        
        global SFM_ObjectMap(SVMXC__ServiceMax_Processes__c objectMap,List<SFM_FieldMapping> fields)
        {
            this.objectMap = objectMap;
            this.fields = fields;
            
        }
    }
    global class SFM_ObjectMapInfo{
        webservice String mapId{get;set;}
        webservice SFM_ObjectMap objectMap;
        
        global SFM_ObjectMapInfo(String mapId, SFM_ObjectMap objectMap){
            this.mapId = mapId;
            this.objectMap = objectMap; 
        }
    }
    global class SFM_Request_ObjectMap
    {
        webservice List<SFM_ObjectMap> objects = new List<SFM_ObjectMap>();
        webservice  String fieldsToNull {get;set;}
        global List<SFM_ObjectMap> getobjects(){return objects;}
        global void setobjects(List<SFM_ObjectMap> s){objects = s;}
        webservice SFM_Request request{get;set;}
        global SFM_Request_ObjectMap(List<SFM_ObjectMap> objects)//,String uid,String gid,String pid,List<SFM_StringMap> strmap
        {
            //super();//uid,gid,pid,strmap
            request = new SFM_Request();
            this.objects = objects;
        }
        global SFM_Request_ObjectMap(){}
    }
    global class SFM_Response_ObjectMap
    {
        webservice List<SFM_ObjectMap> objects = new List<SFM_ObjectMap>();
        webservice SFM_Response response{get;set;}
        global List<SFM_ObjectMap> getobjects(){return objects;}
        global void setobjects(List<SFM_ObjectMap> s){objects = s;}
        
        global SFM_Response_ObjectMap()
        {
        }
        
        global SFM_Response_ObjectMap(List<SFM_ObjectMap> objects)//,Boolean s,String msg,String tid,List<SFM_StringMap> strmap
        {
            //super();//s,msg,tid,strmap
            response = new SFM_Response();
            this.objects = objects;
        }
    }
    global class SFM_Request_PageList
    {
        webservice List<SVMXC__Page_Layout__c> PageList = new List<SVMXC__Page_Layout__c>();
        webservice SFM_Request request{get;set;}
        webservice String fieldsToNull{get;set;}
        global List<SVMXC__Page_Layout__c> getPageList(){return PageList;}
        global void setPageList(List<SVMXC__Page_Layout__c> pl){PageList = pl;}
        global SFM_Request_PageList(List<SVMXC__Page_Layout__c> PageList)
        {
            request = new SFM_Request();
            this.PageList = PageList;
            
        }
        global SFM_Request_PageList()
        {
            request = new SFM_Request();
        }
    }
    global class SFM_Response_PageList
    {
        webservice List<SVMXC__Page_Layout__c> PageList = new List<SVMXC__Page_Layout__c>();
        webservice SFM_Response response{get;set;}
        
        global List<SVMXC__Page_Layout__c> getPageList(){return PageList;}
        global void setPageList(List<SVMXC__Page_Layout__c> pl){PageList = pl;}
        
        global SFM_Response_PageList(List<SVMXC__Page_Layout__c> PageList)
        {
            response = new SFM_Response();
            this.PageList = PageList;
            
        }
        global SFM_Response_PageList()
        {
            
        }
    }
    
    global class SFM_UIButton
    {
        webservice SVMXC__Page_Layout_Detail__c buttonDetail = new SVMXC__Page_Layout_Detail__c();
        webservice List<SVMXC__SFM_Event__c> buttonEvents = new List<SVMXC__SFM_Event__c>();
        webservice String fieldsToNull{get;set;}
        global SFM_UIButton(SVMXC__Page_Layout_Detail__c buttonDetail,List<SVMXC__SFM_Event__c> buttonEvents)
        {
            this.buttonDetail = buttonDetail;
            this.buttonEvents = buttonEvents;
        }
        global SFM_UIButton()
        {
            
        }
        
    }
    global class SFM_UIField
    {
        
        webservice SVMXC__Page_Layout_Detail__c fieldDetail = new SVMXC__Page_Layout_Detail__c();
        webservice List<SVMXC__SFM_Event__c> fieldEvents = new List<SVMXC__SFM_Event__c>();
        webservice String fieldsToNull{get;set;}
        webservice SFM_BubbleWrapper bubbleinfo = new SFM_BubbleWrapper();
        global SFM_UIField(SVMXC__Page_Layout_Detail__c fieldDetail,List<SVMXC__SFM_Event__c> fieldEvents,SFM_BubbleWrapper bubbleinfo)//,SFM_Response_NamedSearchInfo namesearchinfo
        {
            this.fieldDetail = fieldDetail;
            this.fieldEvents = fieldEvents;
            this.bubbleinfo = bubbleinfo;
        }
        global SFM_UIField()
        {
            
        }
    }

    global class SFM_Exit_Criteria{
        
            
            
        webservice string questionBankId {get;set;} 
        webservice string questionId {get;set;} 
        webservice string checklistId {get;set;} 
        webservice string sourceSectionId {get;set;} 
        webservice string targetSectionId {get;set;} 
        webservice string sequenceNo {get;set;}       
        webservice String enableExitCriteria{get;set;}
        webservice SVMXC__ServiceMax_Processes__c SectionExitCriteria = new SVMXC__ServiceMax_Processes__c();
        webservice List<SVMXC__ServiceMax_Config_Data__c> lstSectionExitCriteriaDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        global SVMXC__ServiceMax_Processes__c getSectionExitCriteria(){return SectionExitCriteria;}
        global void setSectionExitCriteria(SVMXC__ServiceMax_Processes__c SectionExitCriteria){this.SectionExitCriteria = SectionExitCriteria;} 
        global List<SVMXC__ServiceMax_Config_Data__c> getlstSectionExitCriteriaDetails(){return lstSectionExitCriteriaDetails;}
        global void setlstSectionExitCriteriaDetails(List<SVMXC__ServiceMax_Config_Data__c> lstSectionExitCriteriaDetails){this.lstSectionExitCriteriaDetails = lstSectionExitCriteriaDetails;}
        
        global SFM_Exit_Criteria(){}
        global SFM_Exit_Criteria(SVMXC__ServiceMax_Processes__c SectionExitCriteria, List<SVMXC__ServiceMax_Config_Data__c> lstSectionExitCriteriaDetails)
        {
            this.SectionExitCriteria = SectionExitCriteria;
            this.lstSectionExitCriteriaDetails = lstSectionExitCriteriaDetails;
        }

        
    }

    global class SFM_UISection
    {
        
        webservice SVMXC__Page_Layout_Detail__c sectionDetail = new SVMXC__Page_Layout_Detail__c();
        webservice List<SFM_UIField> fields = new List<SFM_UIField>();
        webservice String fieldsToNull{get;set;}

        webservice String entryCriteriaId{get;set;}
        webservice String enableEntryCriteria{get;set;}

        
        webservice List<SFM_Exit_Criteria> lstSectionExitCriteria = new  List<SFM_Exit_Criteria>();

        
        global SVMXC__Page_Layout_Detail__c getsectionDetail(){return sectionDetail;}
        global void setsectionDetail(SVMXC__Page_Layout_Detail__c s){sectionDetail = s;}
        global List<SFM_UIField> getfields(){return fields;}
        global void setfields(List<SFM_UIField> s){fields = s;}
        
        global List<SFM_Exit_Criteria> getlstSectionExitCriteria(){return lstSectionExitCriteria;}
        global void setlstSectionExitCriteria(List<SFM_Exit_Criteria> s){lstSectionExitCriteria = s;}
        
        global SFM_UISection(SVMXC__Page_Layout_Detail__c sectionDetail,List<SFM_UIField> fields)//
        {
            this.sectionDetail = sectionDetail;
            this.fields = fields;
        }
        global SFM_UISection(SVMXC__Page_Layout_Detail__c sectionDetail,List<SFM_UIField> fields,List<SFM_Exit_Criteria> lstSectionExitCriteria)//
        {
            this.sectionDetail = sectionDetail;
            this.fields = fields;
            this.lstSectionExitCriteria = lstSectionExitCriteria;
        }
        global SFM_UISection()
        {
            
        }
    }
    global class SFM_PageHeader
    {
        webservice SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        webservice List<SFM_UISection> sections = new List<SFM_UISection>();
        webservice List<SFM_UIButton> buttons = new List<SFM_UIButton>();
        webservice List<SVMXC__SFM_Event__c> pageEvents = new List<SVMXC__SFM_Event__c>();
        webservice Sobject hdrData {get;set;}
        webservice String sourceRecordId{get;set;} // hold the source record id for the target record.
        webservice String hdrLayoutId {get;set;}
        webservice String fieldsToNull{get;set;}
        webservice Boolean enableAttachment = false;
        webservice list<SFM_StringMap> mappedLiterals = new list<SFM_StringMap>(); // Added for BAC-4677
        webservice list<SFM_StringMap> fieldMappedLiterals = new list<SFM_StringMap>(); // Added by Nidhi for BAC-4963 
        global SFM_PageHeader(SVMXC__Page_Layout__c headerLayout,List<SFM_UISection> sections,List<SFM_UIButton> buttons,List<SVMXC__SFM_Event__c> pageEvents)
        {
            this.headerLayout = headerLayout;
            this.sections = sections;
            this.buttons = buttons;
            this.pageEvents = pageEvents;
        }
        global SFM_PageHeader()
        {
            
        }
        
    }
    global class linkedProcessDetail{
        webservice Integer sequence {get;set;}
        webservice String title{get;set;}
        webservice String processId {get;set;}
        //Added new variable : BAC-5162
        webservice String linkedProcessURL{get;set;}
        global linkedProcessDetail(Integer sequence,String title,String processId){
            this.sequence = sequence;
            this.title = title;
            this.processId = processId;
        }
        global linkedProcessDetail(){}
    }   
    global class SFM_PageDetail
    {
        webservice SVMXC__Page_Layout__c DetailLayout = new SVMXC__Page_Layout__c();
        webservice Integer noOfColumns = 2;
        webservice List<SFM_UIField> fields = new List<SFM_UIField>();
        webservice List<SFM_UIButton> buttons = new List<SFM_UIButton>();
        webservice List<SVMXC__SFM_Event__c> events = new List<SVMXC__SFM_Event__c>();
        webservice list<linkedProcessDetail> linkedProcesses = new list<linkedProcessDetail>();
        webservice List<SFM_DetailBubbleWrapper> bubbleinfolist = new List<SFM_DetailBubbleWrapper>(); 
        webservice String dtlLayoutId {get;set;}
        webservice String fieldsToNull{get;set;}
        webservice Sobject recordTemplate;
        webservice list<SFM_StringMap> mappedValues = new list<SFM_StringMap>();
        webservice list<SFM_StringMap> mappedLiterals = new list<SFM_StringMap>();
        webservice list<SFM_StringMap> fieldMappedLiterals = new list<SFM_StringMap>(); // Added By Nidhi for BAC-4963 
        
        global SFM_PageDetail(SVMXC__Page_Layout__c DetailLayout,List<SFM_UIField> fields,List<SFM_UIButton> buttons,List<SFM_DetailBubbleWrapper> bubbleinfolist)
        {
            this.DetailLayout = DetailLayout;
            this.fields = fields;
            this.buttons = buttons;
            this.bubbleinfolist = bubbleinfolist;
        }
        global SFM_PageDetail()
        {
            
        }
    }
    global class SFM_PageUI 
    {
        webservice String processTitle {get;set;}
        webservice list<SFM_StringMap> recordTypeList = new list<SFM_StringMap>();
        webservice SFM_PageHeader header = new SFM_PageHeader();
        webservice List<SFM_PageDetail> details = new List<SFM_PageDetail>();
        webservice String fieldsToNull{get;set;}
        webservice list<SFM_LookupDefinition> lookupDefinitions = new list<SFM_LookupDefinition>();
        webservice list<SFM_ProcessBusinessRule> businessRules = new list<SFM_ProcessBusinessRule>(); //Process Biz Rule Wrapper
        webservice list<SFM_ObjectMapInfo> lstObjectMapInfo = new list<SFM_ObjectMapInfo>();// MeteData for form fill
        global SFM_PageUI(SFM_PageHeader header,List<SFM_PageDetail> details)
        {
            this.header = header;
            this.details = details;
        }
        global SFM_PageUI()
        {
            
        }
    }
     //Added for BAC-5211
    global class SFM_PageLookupResponse 
    {
        webservice list<SFM_LookupDefinition> data{get;set;} 
        webservice SFM_Response response{get;set;}
        global SFM_PageLookupResponse(){
            response = new SFM_Response();
            data = new list<SFM_LookupDefinition>();
        }
    }
    //Added for BAC-5211   
    global class SFM_Request_PageUI
    {
        webservice SFM_PageUI page = new SFM_PageUI();
        webservice SFM_Request request{get;set;}
        webservice String fieldsToNull{get;set;}
        //Aptest
        webservice String ProcessId{get;set;}
        webservice String ProcessType{get;set;}
        webservice SVMXC__ServiceMax_Processes__c processNode = new SVMXC__ServiceMax_Processes__c();
        global SFM_Request_PageUI(SFM_PageUI page,SVMXC__ServiceMax_Processes__c processNode,SFM_Request pmax)//String uid,String gid,String pid,List<SFM_StringMap> strmap
        {
            request = new SFM_Request();
            this.page = page;
            this.processNode = processNode;
        }
        global SFM_Request_PageUI()
        {
            request = new SFM_Request();
        }
        
    }
    global class SFM_Response_PageUI
    {
        webservice SFM_PageUI page = new SFM_PageUI();
        webservice SFM_Response response{get;set;}
        webservice String fieldsToNull{get;set;}
        
        global SFM_Response_PageUI(SFM_PageUI page)//,Boolean s,String msg,String tid,List<SFM_StringMap> strmap
        {
            response = new SFM_Response();
            this.page = page;
        }
        global SFM_Response_PageUI(){}
       
        
    }
    global class SFM_Object
    {
        webservice SFM_StringMap parentObject;
        webservice List<SFM_StringMap> childObjects = new List<SFM_StringMap>(); 
        webservice String fieldsToNull{get;set;}
        
        global SFM_Object(SFM_StringMap parentObject,List<SFM_StringMap> childObjects)
        {
            this.parentObject = parentObject;
            this.childObjects = childObjects;
        }
    }
    global class SFM_Response_GlobalObjects
    {
        webservice List<SFM_Object> globalObjects = new List<SFM_Object>();
        webservice SFM_Response response{get;set;}
        
        global SFM_Response_GlobalObjects(List<SFM_Object> globalObjects)
        {
            response = new SFM_Response();
            this.globalObjects = globalObjects;
        }
    }
    global class SFM_Request_GlobalObjects
    {
        webservice List<SFM_Object> globalObjects = new List<SFM_Object>();
        webservice String fieldsToNull{get;set;}
        webservice SFM_Request request{get;set;}
        global SFM_Request_GlobalObjects(List<SFM_Object> globalObjects)
        {
            request = new SFM_Request();
            this.globalObjects = globalObjects;
        }
    }
    
    global class SFM_NamedSearchDetail
    {
        webservice SVMXC__ServiceMax_Processes__c searchObject = new SVMXC__ServiceMax_Processes__c();
        webservice List<SVMXC__ServiceMax_Config_Data__c> displayFields = new List<SVMXC__ServiceMax_Config_Data__c>();
        webservice List<SVMXC__ServiceMax_Config_Data__c> searchFields = new List<SVMXC__ServiceMax_Config_Data__c>();
        webservice String fieldsToNull{get;set;}
        global SFM_NamedSearchDetail(SVMXC__ServiceMax_Processes__c searchObject,List<SVMXC__ServiceMax_Config_Data__c> searchFields,List<SVMXC__ServiceMax_Config_Data__c> displayFields)
        {
            this.searchObject = searchObject;
            this.displayFields = displayFields;
            this.searchFields = searchFields;
        }
    }
    global class SFM_NamedSearch
    {
        webservice SVMXC__ServiceMax_Processes__c namedSearch = new SVMXC__ServiceMax_Processes__c();
        webservice List<SFM_NamedSearchDetail> namedSearchDetails   = new List<SFM_NamedSearchDetail>();
        webservice String fieldsToNull{get;set;}
        global SFM_NamedSearch(SVMXC__ServiceMax_Processes__c namedSearch,List<SFM_NamedSearchDetail> namedSearchDetails)
        {
            this.namedSearch = namedSearch;
            this.namedSearchDetails = namedSearchDetails;
        }
        global SFM_NamedSearch()
        {
            
        }
    }
    
    global class SFM_Request_NamedSearch
    {
        webservice List<SVMXC__ServiceMax_Processes__c> namedSearch{get; set;}
        webservice SFM_Request request{get;set;}
        webservice String fieldsToNull{get;set;}
        global SFM_Request_NamedSearch(List<SVMXC__ServiceMax_Processes__c> namedSearch)//,String uid,String gid,String pid,List<SFM_StringMap> strmap
        {
            request = new SFM_Request();
            this.namedSearch = namedSearch;
        }
    }
    global class SFM_Response_NamedSearch
    {
        webservice List<SVMXC__ServiceMax_Processes__c> namedSearch{get; set;}
        webservice SFM_Response response{get;set;}
        global SFM_Response_NamedSearch(List<SVMXC__ServiceMax_Processes__c> namedSearch)//,Boolean s,String msg,String tid,List<SFM_StringMap> strmap
        {
            response = new SFM_Response();
            this.namedSearch = namedSearch;
        }
    }
    
    global class SFM_Request_NamedSearchInfo{
        webservice List<SFM_NamedSearchInfo> namedSearch{get; set;}
        webservice SFM_Request request{get;set;}
        webservice String fieldsToNull{get;set;}
        global SFM_Request_NamedSearchInfo(List<SFM_NamedSearchInfo> namedSearch){
            this.namedSearch = namedSearch;
        }
    }
    
    global class SFM_Response_NamedSearchInfo
    {
        webservice List<SFM_NamedSearchInfo> namedSearch{get; set;}
        webservice SFM_Response response{get;set;}
        
        global SFM_Response_NamedSearchInfo(List<SFM_NamedSearchInfo> namedSearch)
        {
            this.namedSearch = namedSearch;
            response=new SFM_Response();
        }
        
        global SFM_Response_NamedSearchInfo()
        {
            response=new SFM_Response();
        }
    }
    
    global class SFM_NamedSearchInfo
    {
        webservice SVMXC__ServiceMax_Processes__c namedSearchHdr{get; set;}
        webservice List<SFM_NamedSearchInfoDetail> namedSearchDetails{get; set;}
        webservice List<SFM_NamedSearchInfoDetail> advNamedSearchDetails{get; set;}// New member for advanced filter.
        webservice String fieldsToNull{get;set;}
        global SFM_NamedSearchInfo(SVMXC__ServiceMax_Processes__c namedSearchHdr, List<SFM_NamedSearchInfoDetail> namedSearchDetails)
        {
            this.namedSearchHdr = namedSearchHdr;
            this.namedSearchDetails = namedSearchDetails;
        }
        global SFM_NamedSearchInfo(){}
    }
    
    global class SFM_NamedSearchInfoDetail{
        webservice String uniqueId {get;set;}
        webservice SVMXC__ServiceMax_Processes__c objectDetails{get; set;}
        webservice List<SVMXC__ServiceMax_Config_Data__c> fields{get; set;}
        webservice List<SVMXC__ServiceMax_Config_Data__c> expressionFields {get; set;}
        webservice String fieldsToNull{get;set;}
        global SFM_NamedSearchInfoDetail(SVMXC__ServiceMax_Processes__c objectDetails, List<SVMXC__ServiceMax_Config_Data__c> fields)
        {
            this.objectDetails = objectDetails;
            this.fields = fields;
        }
        global SFM_NamedSearchInfoDetail()
        {
            objectDetails = new SVMXC__ServiceMax_Processes__c();
            fields = new list<SVMXC__ServiceMax_Config_Data__c>();
            expressionFields = new list<SVMXC__ServiceMax_Config_Data__c>();
        }
    }
    
    global class SFM_SearchResult
    {
        webservice String objectApiName;    
        webservice List<SObject> records = new List<SObject>();
        webservice String fieldsToNull{get;set;}
        global SFM_SearchResult(String objectApiName,List<SObject> records)
        {
            this.objectApiName = objectApiName;
            this.records = records;
        }
    }
    global class SFM_Response_Search
    {
        webservice List<SFM_SearchResult>   searchResult = new List<SFM_SearchResult>();
        
        global SFM_Response_Search(List<SFM_SearchResult>   searchResult)
        {
            this.searchResult = searchResult;
        }
    }
    
    global class SFM_Response_RecordTypes
    {
        webservice List<SObject> records = new List<SObject>();
        webservice SFM_Response response{get;set;}
        global SFM_Response_RecordTypes(List<SObject> records)
        {
            response=new SFM_Response();
            this.records = records;
        }
    }


    global class SFM_Response_ObjectFields{
        webservice List<FieldProperties> fields{get;set;}
        webservice SFM_Response response{get;set;}
        global SFM_Response_ObjectFields(){
            this.response = new SFM_Response();
        }
    }
    

    global class FieldProperties{
        webservice String key{get;set;}
        webservice String value{get;set;}
        webservice List<SFM_StringMap> properties{get;set;}
        webservice String fieldsToNull{get;set;}
        global FieldProperties(String key){
            this.key = Key;
        }
        
        global FieldProperties(String key, String value, List<SFM_StringMap> properties){
            this.key = Key;
            this.value = value;
            this.properties = properties;
        }
        
        global FieldProperties(String key, String value){
            this.key = Key;
            this.value = value;
        }
    }
    
    global class SFM_Response_ObjectMapLIst{
        webservice List<SVMXC__ServiceMax_Processes__c> objectMapping{get; set;}
        webservice SFM_Response response{get;set;}
        global SFM_Response_ObjectMapLIst(){
            
        }
        global SFM_Response_ObjectMapLIst(List<SVMXC__ServiceMax_Processes__c> objectMapping){
            response = new SFM_Response();
            this.objectMapping = objectMapping;
        }
    }
    global class SFM_LookUpConfigData
    {
        webservice SFM_Response_NamedSearchInfo namesearchinfo{get; set;}
        webservice SFM_Response response{get;set;}
        webservice List<bubble_wp> data{get; set;}
        global SFM_LookUpConfigData()
        {
            response = new SFM_Response();
              
        }
        
        
    }
    global class bubble_wp{
        webservice List<SFM_StringFieldMap> FieldMap{get;set;}
        global bubble_wp(List<SFM_StringFieldMap> FieldMap)
        {
            this.FieldMap = FieldMap;
        }
        
        
    }
    global class SFM_ToolbarGroup
    {
        webservice SVMXC__ServiceMax_Processes__c section {get; set;}
        webservice List<SVMXC__ServiceMax_Processes__c> actions {get; set;}
        
        global SFM_ToolbarGroup()
        {
            
        }
    }
    global class SFM_Response_Toolbar
    {
        webservice List<SFM_ToolbarGroup> toolbargroupLst = new List<SFM_ToolbarGroup>();
        webservice String fieldsToNull{get;set;}
        global SFM_Response_Toolbar(){}
        global SFM_Response_Toolbar(List<SFM_ToolbarGroup> toolbargroupLst){
            this.toolbargroupLst = toolbargroupLst;
        }
        global List<SFM_ToolbarGroup> gettoolbargroupLst(){return toolbargroupLst;}
        global void settoolbargroupLst(List<SFM_ToolbarGroup> toolbargroupLst){this.toolbargroupLst = toolbargroupLst;}
        
    }
    
    global class SFM_Response_ObjectToolbarActions
    { 
        webservice List<SFM_Response_Toolbar> toolbarGroupActions {get;set;}
        webservice String fieldsToNull{get;set;}
        global SFM_Response_ObjectToolbarActions(){}
    }
    global class SFM_Record
    {
        webservice String fieldsToNull{get;set;}
        webservice String sourceRecordId{get;set;}  
        webservice List<SFM_StringMap> targetRecordAsKeyValue = new List<SFM_StringMap>(); 
        webservice String targetRecordId{get;set;}
        webservice Sobject sobjectinfo {get;set;}
        webservice Sobject sObjectRecord {get;set;}
        webservice String rowIndex {get;set;} //Added for the story BAC-3839 for capturing row index of the record from the client
        
        global SFM_Record(){}
        
        global List<SFM_StringMap> gettargetRecordAsKeyValue(){return targetRecordAsKeyValue;}
        global void settargetRecordAsKeyValue(List<SFM_StringMap> targetRecordAsKeyValue){this.targetRecordAsKeyValue = targetRecordAsKeyValue;}
    }
    
    global class SFM_TargetRecordObject
    {
        webservice String objName{get;set;}
        webservice String aliasName {get;set;}
        webservice String parentColumnName{get;set;}
        webservice List<String> deleteRecID = new List<String>();
        webservice String pageLayoutId {get;set;}
        webservice List<SFM_Record> records = new List<SFM_Record>();
        webservice String fieldsToNull{get;set;}
        
        global SFM_TargetRecordObject(){}
        
        global List<SFM_Record> getrecords(){return records;}
        global void setrecords(List<SFM_Record> records){this.records = records;}
        global List<String> getdeleteRecID(){return deleteRecID;}
        global void setdeleteRecID(List<String> deleteRecID){this.deleteRecID = deleteRecID;}
    }
    
    global class SFM_TargetRecord
    {
        webservice list<SFM_StringMap> stringMap = new list<SFM_StringMap>();
        webservice String fieldsToNull{get;set;}
        webservice String sfmProcessId {get;set;}
        webservice String eventType {get;set;}
        webservice SFM_TargetRecordObject headerRecord = new SFM_TargetRecordObject();
        webservice List<SFM_TargetRecordObject> detailRecords = new List<SFM_TargetRecordObject>();
        webservice String callType {get;set;} //Added for the story BAC-4027 for sending call type and valid value will be "save for linked sfm"
        
        global  SFM_TargetRecord(){}
        
        global SFM_TargetRecordObject getheaderRecord(){return headerRecord;}
        global void setheaderRecord(SFM_TargetRecordObject headerRecord){this.headerRecord = headerRecord;} 
        global List<SFM_TargetRecordObject> getdetailRecords(){return detailRecords;}
        global void setdetailRecords(List<SFM_TargetRecordObject> detailRecords){this.detailRecords = detailRecords;}
        //defect fix : 046599 
        webservice List<ChecklistInfo> checklistInfo {get;set;}
    }
   //defect fix : 046599 
    global class ChecklistInfo 
    {
        webservice list<SFM_StringMap> possibleValues = new list<SFM_StringMap>();
        webservice String questionId {get;set;}
        webservice String questionType {get;set;}
        
    }
    global class SFM_PageDataSet
    {
        webservice String sourceRecordID {get;set;}
        webservice list<SFM_BubbleWrapper> bubbleInfo; 
        webservice Sobject sobjectinfo {get;set;}
        webservice list<Sobject> lstSobjectinfo {get;set;}
        webservice SFM_Response response{get;set;}
        webservice list<String> mappedFieldsForHeader; //Added as part of Story BAC-3257
        webservice String rowIndex {get;set;} //Added for the story BAC-4534
        global SFM_PageDataSet()
        {
            response = new SFM_Response();
       
        }
        //Added belwo constructor as part of story BAC- 5357, It's public as nature beacuse we are not exposing outside(Internal use only)
        //Also in patch org we can not add new global constructor
        public SFM_PageDataSet(String sourceRecordID,Sobject sobjectinfo,String rowIndex )
        {
            this.sourceRecordID = sourceRecordID;
            this.sobjectinfo = sobjectinfo;
            this.rowIndex = rowIndex;
        }
        global list<SFM_BubbleWrapper> getbubbleInfo(){return bubbleInfo;}
        global void setbubbleInfo(list<SFM_BubbleWrapper> bubbleInfo){this.bubbleInfo = bubbleInfo;}
        global list<Sobject> getlstSobjectinfo(){return lstSobjectinfo;}
        global void setlstSobjectinfo(list<Sobject> lstSobjectinfo){this.lstSobjectinfo = lstSobjectinfo;}
        
    }
    global class SFM_DetailDataSet
    {
        webservice String aliasName {get;set;}
        //Added by Nidhi as part of Lazy Loading BAC-4680
        webservice String offsetValue {get;set;}
        webservice Boolean isAllRecordsLoaded {get;set;}
        webservice String objectApiName {get;set;}
        webservice String fieldList {get;set;}
        webservice String whereClause {get;set;}
        webservice String orderByFields {get;set;}
        //Added by Nidhi Ends here
        webservice list<SFM_PageDataSet> pageDataSet;
        
        global SFM_DetailDataSet(){}
        global list<SFM_PageDataSet> getpageDataSet(){return pageDataSet;}
        global void setpageDataSet(list<SFM_PageDataSet> pageDataSet){this.pageDataSet =  pageDataSet;}
    }
    
    //Added by Nidhi as part of Lazy Loading BAC-4680
    global class SFM_DetailDataSetInRequest
    {
        global String aliasName;
        global String offsetValue;
        global Boolean isAllRecordsLoaded;
        global String objectApiName;
        global String fieldList;
        global String whereClause;
        global String orderByFields;
        
        global SFM_DetailDataSetInRequest(){}
    }
    
    global class SFM_PageData
    {
        webservice String eventType {get;set;}
        webservice SFM_PageDataSet pageDataSet;
        webservice Boolean isAllTabDataLoaded {get;set;}//Added by Nidhi as part of Lazy Loading BAC-4680
        webservice List<SFM_StringMap> bubbleInfoCollections = new List<SFM_StringMap>();//Added by Nidhi as part of Lazy Loading BAC-4680
        webservice list<SFM_DetailDataSet> detailDataSet;
        webservice list<SFM_StringMap> svmxConstants = new list<SFM_StringMap>(); 
        webservice SFM_Response response{get;set;}
        webservice String fieldsToNull{get;set;}
        webservice List<SFM_StringListMap> fieldsQueriedPerObject{get;set;} //Added for the story BAC-4264
        
        global SFM_PageData()
        {
            response = new SFM_Response(); 
        }
        
        global SFM_PageDataSet getpageDataSet(){return pageDataSet;}
        global void setpageDataSet(SFM_PageDataSet pageDataSet){this.pageDataSet = pageDataSet;}
        
        global list<SFM_DetailDataSet> getdetailDataset(){return detailDataSet;}
        global void setdetailDataset(list<SFM_DetailDataSet> detailDataSet){this.detailDataSet = detailDataSet;}
        
    }
    
    //Added by Nidhi as part of Lazy Loading BAC-4680, Response of JsrGetPageDataV2
    public class SFM_PageDataV2
    {
        public Boolean isAllTabDataLoaded;
        public SFM_PageDataSet pageDataSet;
        public list<SFM_DetailDataSet> detailDataSet;
        public List<SFM_StringMap> bubbleInfoCollections = new List<SFM_StringMap>();
        public SFM_ResponseV2 response;
    }
    
    global class SFM_LookupDefinition 
    {
        webservice String key{get;set;}
        webservice String objectName {get;set;}
        webservice String LastModifiedDate {get;set;} //Added for BAC-5211
        webservice SFM_LookupDefinitionDetail lookupDefDetail = new SFM_LookupDefinitionDetail();
        webservice list<SFM_AdvCrieteriaDefinition> advFilters  = new list<SFM_AdvCrieteriaDefinition>();
        global SFM_LookupDefinition(){}
        global SFM_LookupDefinition(SVMXC__ServiceMax_Processes__c objProcess,list<SVMXC__ServiceMax_Config_Data__c> lstConfigData)
        {
            if(objProcess.SVMXC__Module__c != null)
            {
                key = objProcess.SVMXC__Module__c;
                objectName = objProcess.SVMXC__Module__r.SVMXC__Source_Object_Name__c;
                LastModifiedDate = String.valueOf(objProcess.LastModifiedDate); //Added for BAC-5211
            }   
            else if(objProcess.SVMXC__Source_Object_Name__c != null)
            {
                key = objProcess.SVMXC__Source_Object_Name__c;
                objectName = objProcess.SVMXC__Source_Object_Name__c;
                LastModifiedDate = String.valueOf(objProcess.LastModifiedDate); //Added for BAC-5211
            }   
                    
            lookupDefDetail = new SFM_LookupDefinitionDetail(objProcess,lstConfigData);
        }
        global SFM_LookupDefinition(SVMXC__ServiceMax_Processes__c objProcess,list<SVMXC__ServiceMax_Config_Data__c> lstConfigData, map<SVMXC__ServiceMax_Processes__c, list<SVMXC__ServiceMax_Config_Data__c>> mapAdvFilter)
        {
            if(objProcess.SVMXC__Module__c != null)
            {
                key = objProcess.SVMXC__Module__c;
                objectName = objProcess.SVMXC__Module__r.SVMXC__Source_Object_Name__c;
                LastModifiedDate = String.valueOf(objProcess.LastModifiedDate); //Added for BAC-5211
            }   
            else if(objProcess.SVMXC__Source_Object_Name__c != null)
            {
                key = objProcess.SVMXC__Source_Object_Name__c;
                objectName = objProcess.SVMXC__Source_Object_Name__c;
                LastModifiedDate = String.valueOf(objProcess.LastModifiedDate); //Added for BAC-5211
            }   
                    
            lookupDefDetail = new SFM_LookupDefinitionDetail(objProcess,lstConfigData);
            for(SVMXC__ServiceMax_Processes__c pro : mapAdvFilter.keyset()){
                advFilters.add(new SFM_AdvCrieteriaDefinition(pro,mapAdvFilter.get(pro)));
            }
        }
        
    }
    
    global class SFM_LookupDefinitionDetail
    {
        webservice list<SFM_FieldDefinition> displayFields  = new list<SFM_FieldDefinition>();
        webservice list<SFM_FieldDefinition> searchFields  = new list<SFM_FieldDefinition>();
        webservice list<SFM_FieldDefinition> bubbleFields  = new list<SFM_FieldDefinition>();
        webservice list<SFM_FieldDefinition> formFillFields  = new list<SFM_FieldDefinition>();
        webservice String preFilterCriteria {get;set;}
        webservice String queryColumns {get;set;}
        webservice Double numberOfRecs {get;set;}
        webservice String defaultLookupColumn{get;set;}
       
        global SFM_LookupDefinitionDetail(){}
        global SFM_LookupDefinitionDetail(SVMXC__ServiceMax_Processes__c objProcess, list<SVMXC__ServiceMax_Config_Data__c> lstConfigData)
        {
            queryColumns = 'Id';
            set<String> setFields = new set<String>();
            setFields.add('Id');
            for(SVMXC__ServiceMax_Config_Data__c ConfigData : lstConfigData)
            {
                if(ConfigData.SVMXC__Search_Object_Field_Type__c == 'Result'){
                    displayFields.add(new SFM_FieldDefinition(ConfigData));
                }
                else if(ConfigData.SVMXC__Search_Object_Field_Type__c == 'Search'){
                    searchFields.add(new SFM_FieldDefinition(ConfigData));
                }
                else if(ConfigData.SVMXC__Search_Object_Field_Type__c == 'Bubble'){
                    bubbleFields.add(new SFM_FieldDefinition(ConfigData));
                }
                //Build Query columns (Only for SRCH_Object_Fields)
                if(ConfigData.SVMXC__Expression_Type__c == 'SRCH_Object_Fields'){
                    if(ConfigData.SVMXC__Display_Type__c != null && ConfigData.SVMXC__Display_Type__c.equalsIgnoreCase('REFERENCE'))
                    {
                        if(!setFields.contains(ConfigData.SVMXC__Field_Relationship_Name__c+'.'+ConfigData.SVMXC__FKey_Name_Field__c) && !setFields.contains(ConfigData.SVMXC__Field_Name__c)){
                            queryColumns += ','+ConfigData.SVMXC__Field_Relationship_Name__c+'.'+ConfigData.SVMXC__FKey_Name_Field__c+','+ConfigData.SVMXC__Field_Name__c;
                            setFields.add(ConfigData.SVMXC__Field_Name__c);
                            setFields.add(ConfigData.SVMXC__Field_Relationship_Name__c+'.'+ConfigData.SVMXC__FKey_Name_Field__c);   
                        }       
                    }
                    else
                    {
                        if(!setFields.contains(ConfigData.SVMXC__Field_Name__c)){
                            queryColumns += ','+ConfigData.SVMXC__Field_Name__c;
                            setFields.add(ConfigData.SVMXC__Field_Name__c);
                        }       
                    }
                }        
            }
            preFilterCriteria = objProcess.SVMXC__Parent_Object_Criteria__c;
            numberOfRecs = objProcess.SVMXC__Module__r.SVMXC__Number_of_Lookup_Records__c;
            if(objProcess.SVMXC__Module__r.SVMXC__Default_Lookup_Column__c != null){
                defaultLookupColumn = objProcess.SVMXC__Module__r.SVMXC__Default_Lookup_Column__c;
                if(!setFields.contains(objProcess.SVMXC__Module__r.SVMXC__Default_Lookup_Column__c)){
                    queryColumns += ','+objProcess.SVMXC__Module__r.SVMXC__Default_Lookup_Column__c;
                    setFields.contains(objProcess.SVMXC__Module__r.SVMXC__Default_Lookup_Column__c);    
                }
            }   
            
            
        } 
        
        global list<SFM_FieldDefinition> getdisplayFields(){return displayFields;}
        global void setdisplayFields(list<SFM_FieldDefinition> displayFields){this.displayFields = displayFields;}
        
        global list<SFM_FieldDefinition> getsearchFields(){return searchFields;}
        global void setsearchFields(list<SFM_FieldDefinition> searchFields){this.searchFields = searchFields;}
        
        global list<SFM_FieldDefinition> getbubbleFields(){return bubbleFields;}
        global void setbubbleFields(list<SFM_FieldDefinition> bubbleFields){this.bubbleFields = bubbleFields;}
    }
    
    
    global class SFM_FieldDefinition
    {
        webservice String apiName {get;set;}
        webservice String dataType {get;set;}
        webservice String refObjectName {get;set;}
        webservice String refObjectNameField {get;set;} 
        webservice String fieldRelationshipName{get;set;}
        webservice decimal sequence {get;set;}
        webservice String operandType {get;set;}
        global SFM_FieldDefinition(){}
        global SFM_FieldDefinition(SVMXC__ServiceMax_Config_Data__c ConfigData)
        {
            apiName = ConfigData.SVMXC__Field_Name__c;
            dataType = ConfigData.SVMXC__Display_Type__c; 
            refObjectName = ConfigData.SVMXC__Object_Name__c; 
            refObjectNameField = ConfigData.SVMXC__FKey_Name_Field__c; 
            fieldRelationshipName = ConfigData.SVMXC__Field_Relationship_Name__c; 
            sequence = ConfigData.SVMXC__Sequence__c;
            operandType = ConfigData.SVMXC__Parameter_Type__c;
            
        }
    }
    global class SFM_AdvCrieteriaDefinition{
        webservice String key{get;set;}
        webservice String filterName{get;set;}
        webservice String filterObject{get;set;}
        webservice String filterCriteria{get;set;}
        webservice String lookupField{get;set;}
        webservice Boolean allowOverride{get;set;}
        webservice Boolean defaultOn{get;set;}
        webservice list<SFM_FieldDefinition> filterCriteriaFields = new list<SFM_FieldDefinition>();    
        global SFM_AdvCrieteriaDefinition(SVMXC__ServiceMax_Processes__c objProcess,list<SVMXC__ServiceMax_Config_Data__c> lstConfigData){
            this.key = objProcess.id;
            this.filterName = objProcess.SVMXC__Name__c;
            this.filterObject = objProcess.SVMXC__Source_Object_Name__c;
            this.filterCriteria = objProcess.SVMXC__Parent_Object_Criteria__c;
            this.lookupField = objProcess.SVMXC__Field_Name__c;
            this.allowOverride = objProcess.SVMXC__Allow_Override__c;
            this.defaultOn = objProcess.SVMXC__Default_On__c;
            
            if(lstConfigData.size() > 0){
                for(SVMXC__ServiceMax_Config_Data__c configData : lstConfigData){
                    filterCriteriaFields.add(new SFM_FieldDefinition(configData));
                }
            }
        }
        
    }
    global class SFM_LookupRequest{
        
        webservice  SFM_LookupDefinition lookupDef{get;set;}
        webservice  String contextMatchField {get;set;}
        webservice  String contextValue  {get;set;}
        webservice  String operator {get;set;}
        webservice  String Keyword {get;set;}
        
        global SFM_LookupRequest(){}
    }
    global class SFM_DocTemplate{
        webservice SVMXC__Doc_Template__c templateRecord {get;set;}
        webservice list<SVMXC__Doc_Template_Details__c> templateDetails = new list<SVMXC__Doc_Template_Details__c>(); 
        webservice Attachment contentRecord {get;set;} 
        webservice String contentBody {get;set;}
        webservice ContentVersion contentVersionRecord {get;set;}//Added for Salesforce file---BAC-4074
        
        
        global SFM_DocTemplate(SVMXC__Doc_Template__c templateRecord, list<SVMXC__Doc_Template_Details__c> templateDetails, Attachment contentRecord, String contentBody){
            
            this.templateRecord = templateRecord;
            this.templateDetails = templateDetails;
            this.contentRecord = contentRecord;
            this.contentBody = contentBody;
        }
        //Below code for Salesforce file-BAC-4074
        global SFM_DocTemplate(SVMXC__Doc_Template__c templateRecord, ContentVersion contentRecord, list<SVMXC__Doc_Template_Details__c> templateDetails,  String contentBody){
            
            this.templateRecord = templateRecord;
            this.templateDetails = templateDetails;
            this.contentVersionRecord = contentRecord;
            this.contentBody = contentBody;
        }
        //End-------BAC-4074
        global SFM_DocTemplate(){}
    }
    
    global class SFM_StringSobjectMap{
        webservice String key {get;set;}
        webservice String value {get;set;}
        webservice list<Sobject> records = new list<Sobject>();
        
        global SFM_StringSobjectMap(){}
        
        global SFM_StringSobjectMap(String key, list<Sobject> records){
            this.key = key;
            this.records = records;
        }
        
        global SFM_StringSobjectMap(String key, String value, list<Sobject> records){
            this.key = key;
            this.value = value;
            this.records = records;
        }
    }
    //Field set Wrapper
    global class FieldsetDefinition{
    
        webservice String objectAPIName{get;set;}
        webservice list<FieldSetInfo> fieldsetInfo = new list<FieldSetInfo>();
        
        global FieldsetDefinition(String objectAPIName, list<FieldSetInfo> fieldsetInfo){
            this.objectAPIName = objectAPIName;
            this.fieldsetInfo = fieldsetInfo;
        }
    }
    global class FieldSetInfo{
        webservice String fieldSetAPIName {get;set;}    
        webservice String fieldSetLabel {get;set;}
        webservice String fieldSetDescription {get;set;} //Optional, introduced for Designer 2.0
        
        global FieldSetInfo(String fieldSetAPIName, String fieldSetLabel){
            this.fieldSetAPIName = fieldSetAPIName;
            this.fieldSetLabel = fieldSetLabel;
        }
    }
    global class SortingRec{
        webservice String fieldAPIName{get;set;}
        webservice String sortingOrder{get;set;}
        webservice String queryField{get;set;}
        webservice String dataType{get;set;}
        webservice String RefereceFieldObjectName{get;set;}
        webservice String fieldRelationshipName{get;set;}
        webservice String nameField{get;set;}
        
        global SortingRec(String fieldAPIName,String sortingOrder,String queryField,String dataType,String RefereceFieldObjectName,String fieldRelationshipName,String nameField){
            this.fieldAPIName = fieldAPIName;
            this.sortingOrder = sortingOrder;
            this.queryField = queryField;
            this.dataType = dataType;
            this.RefereceFieldObjectName = RefereceFieldObjectName;
            this.fieldRelationshipName = fieldRelationshipName;
            this.nameField = nameField;
            
        }
        global SortingRec(){}
    }
    
    global class FieldSetWithSorting {
        webservice list<String> lstFieldSetAPIName = new list<String>();
        webservice list<SortingRec> lstSortingRec = new list<SortingRec>();
        webservice String strObjectName;
        webservice ID fieldMapId;
        webservice ID valueMapId;
        webservice ID pageLayoutId; 
        
        
        global FieldSetWithSorting(list<String> lstFieldSetAPIName,list<SortingRec> lstSortingRec,String strObjectName,ID fieldMapId,ID valueMapId,ID pageLayoutId){
            this.lstFieldSetAPIName = lstFieldSetAPIName;
            this.lstSortingRec = lstSortingRec;
            this.strObjectName = strObjectName;
            this.fieldMapId = fieldMapId;
            this.valueMapId = valueMapId;
            this.pageLayoutId = pageLayoutId;
        }
        global FieldSetWithSorting(){}
    }
    
    //Wrapper: Business Rule Info
    global class SFM_BizRuleInfo
    {
        webservice SVMXC__ServiceMax_Processes__c bizRule = new SVMXC__ServiceMax_Processes__c();
        webservice List<SVMXC__ServiceMax_Config_Data__c> bizRuleDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        global SVMXC__ServiceMax_Processes__c getbizRule(){return bizRule;}
        global void setbizRule(SVMXC__ServiceMax_Processes__c bizRule){this.bizRule = bizRule;} 
        global List<SVMXC__ServiceMax_Config_Data__c> getbizRuleDetails(){return bizRuleDetails;}
        global void setbizRuleDetails(List<SVMXC__ServiceMax_Config_Data__c> bizRuleDetails){this.bizRuleDetails = bizRuleDetails;}
        
        global SFM_BizRuleInfo(){}
        global SFM_BizRuleInfo(SVMXC__ServiceMax_Processes__c bizRule, List<SVMXC__ServiceMax_Config_Data__c> bizRuleDetails)
        {
            this.bizRule = bizRule;
            this.bizRuleDetails = bizRuleDetails;
        }
    }
    
    //Wrapper: Process Business Rule
    global class SFM_ProcessBusinessRule
    {
        webservice Integer sequence {get; set;}
        webservice String message {get; set;}
        webservice String aliasName {get; set;}
        webservice SFM_BizRuleInfo ruleInfo = new SFM_BizRuleInfo();
        global SFM_BizRuleInfo getruleInfo(){return this.ruleInfo;}
        global void setruleInfo(SFM_BizRuleInfo ruleInfo){this.ruleInfo = ruleInfo;}
        
        global SFM_ProcessBusinessRule(){}
        global SFM_ProcessBusinessRule(Integer sequence, String message, String aliasName, SFM_BizRuleInfo ruleInfo)
        {
            this.sequence = sequence;
            this.message = message;
            this.aliasName = aliasName;
            this.ruleInfo = ruleInfo;
        }
    }
    
    //Wrapper: Field Update Rule Info
    global class SFM_FieldUpdateRuleInfo
    {
        webservice SVMXC__ServiceMax_Processes__c fieldUpdateRule = new SVMXC__ServiceMax_Processes__c();
        webservice List<SVMXC__ServiceMax_Config_Data__c> fieldUpdateRuleDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        global SVMXC__ServiceMax_Processes__c getFieldUpdateRule() { 
            return fieldUpdateRule; 
        }
        
        global void setFieldUpdateRule( SVMXC__ServiceMax_Processes__c fieldUpdateRule ) {
            this.fieldUpdateRule = fieldUpdateRule;
        } 
        
        global List<SVMXC__ServiceMax_Config_Data__c> getFieldUpdateRuleDetails() {
            return fieldUpdateRuleDetails;
        }
        
        global void setFieldUpdateRuleDetails( List<SVMXC__ServiceMax_Config_Data__c> fieldUpdateRuleDetails ) { 
            this.fieldUpdateRuleDetails = fieldUpdateRuleDetails;
        }
        
        global SFM_FieldUpdateRuleInfo(){}        
    }
    
    public abstract class ProfileDetails
    {
       
        public String name; //required; this is the web service name
        public String reqtype; //required; the web service request type  SOQL, ExecutionTime
        public String description; //optional; this can be any additional information specific to the request type
        public ProfileDetails(){}
        public ProfileDetails(String name,String reqtype,String description){
            this.name=name; //name of the webservice
            this.reqtype=reqtype;
            this.description=description;
        }
     
     }
     public class ExecutionTimeProfileDetail extends ProfileDetails 
     {
       
        public  Datetime    begintime;
        public  Datetime    endtime;
        public ExecutionTimeProfileDetail(){}
        public ExecutionTimeProfileDetail(Datetime begintime,Datetime endtime,String description){
            this.begintime=begintime; 
                this.endtime=endtime;  
                this.description=description;
                
        }
     }
     
    public class ProfileData{   
        public List<ExecutionTimeProfileDetail> details;     
        public ProfileData(List<ExecutionTimeProfileDetail> details){
            this.details = details; 
        }
    }
    
    global class SFM_DefaultResponseJSON{
        webservice List<String> listOfDefaultValues;
        webservice String literalValue{get; set;}

        global void setlistOfDefaultValues(List<String> listOfDefaultValues){    this.listOfDefaultValues = listOfDefaultValues;   }
        global List<String> getlistOfDefaultValues(){ return listOfDefaultValues;    }

        global void setliteralValue(String literalValue){    this.literalValue = literalValue;   }
        global String getliteralValue(){ return literalValue;    }

        global SFM_DefaultResponseJSON(){
        }

        global SFM_DefaultResponseJSON(List<String> listOfDefaultValues, String literalValue){
            this.listOfDefaultValues = listOfDefaultValues;
            this.literalValue = literalValue;
        }
    }
    
    //Wrapper class for Question Information with Response options
    global class SFM_QuestionBank{
        webservice SVMXC__Question_Bank__c question = new SVMXC__Question_Bank__c();
        webservice SFM_QuestionValidationRuleInfo QuestionValidationRuleInfo = new SFM_QuestionValidationRuleInfo();
        webservice List<SVMXC__QB_Response_Options__c> questionBankResponseOptions = new List<SVMXC__QB_Response_Options__c>();
        webservice SVMXC__QB_Response_Set__c questionResponseSet = new SVMXC__QB_Response_Set__c();
        webservice List<String> tagsList = new List<String>();
        webservice SVMXC__SM_Default_Checklist_Response__c defaultChecklistResponse = new SVMXC__SM_Default_Checklist_Response__c();
        webservice SFM_DefaultResponseJSON defaultResponseJSON;

        global void setquestion(SVMXC__Question_Bank__c question){    this.question = question;   }
        global SVMXC__Question_Bank__c getquestion(){ return question;    }
        
        //Apurva
        global void setQuestionValidationRuleInfo(SFM_QuestionValidationRuleInfo QuestionValidationRuleInfo){    this.QuestionValidationRuleInfo = QuestionValidationRuleInfo;   }
        global SFM_QuestionValidationRuleInfo getQuestionValidationRuleInfo(){ return QuestionValidationRuleInfo;    }
        
        
        global void setquestionBankResponseOptions(List<SVMXC__QB_Response_Options__c> questionBankResponseOptions){  this.questionBankResponseOptions = questionBankResponseOptions; }
        global List<SVMXC__QB_Response_Options__c> getquestionBankResponseOptions(){  return questionBankResponseOptions; }
        
        global void setquestionResponseSet(SVMXC__QB_Response_Set__c questionResponseSet){    this.questionResponseSet = questionResponseSet;   }
        global SVMXC__QB_Response_Set__c getquestionResponseSet(){ return questionResponseSet;    }
        
        //Apurva
        
        global void setdefaultChecklistResponse(SVMXC__SM_Default_Checklist_Response__c defaultChecklistResponse){    this.defaultChecklistResponse = defaultChecklistResponse;   }
        global SVMXC__SM_Default_Checklist_Response__c getdefaultChecklistResponse(){ return defaultChecklistResponse;    }

        global void setdefaultResponseJSON(SFM_DefaultResponseJSON defaultResponseJSON){    this.defaultResponseJSON = defaultResponseJSON;   }
        global SFM_DefaultResponseJSON getdefaultResponseJSON(){ return defaultResponseJSON;    }
        
        /*global void settagsList( List<String> tagsList){    this.tagsList = tagsList;   }
        global List<String> gettagsList(){ return tagsList;    }        */
        
        //Constructor
        global SFM_QuestionBank(){}
        global SFM_QuestionBank(SVMXC__Question_Bank__c question, List<SVMXC__QB_Response_Options__c> questionBankResponseOptions){
            this.question = question;
            this.questionBankResponseOptions = questionBankResponseOptions;
        }
        global SFM_QuestionBank(SVMXC__Question_Bank__c question, List<SVMXC__QB_Response_Options__c> questionBankResponseOptions, SVMXC__QB_Response_Set__c questionResponseSet){
            this.question = question;
            this.questionBankResponseOptions = questionBankResponseOptions;
            this.questionResponseSet = questionResponseSet;
        }
        //added for Question Tags 
        global SFM_QuestionBank(SVMXC__Question_Bank__c question, List<SVMXC__QB_Response_Options__c> questionBankResponseOptions, SVMXC__QB_Response_Set__c questionResponseSet, List<String> tagsLists){
            this.question = question;
            this.questionBankResponseOptions = questionBankResponseOptions;
            this.questionResponseSet = questionResponseSet;
            this.tagsList = tagsLists; 
        } 
        //added for Checklist Validation rule
        global SFM_QuestionBank(SVMXC__Question_Bank__c question, List<SVMXC__QB_Response_Options__c> questionBankResponseOptions, SVMXC__QB_Response_Set__c questionResponseSet, List<String> tagsLists,SFM_QuestionValidationRuleInfo QuestionValidationRuleInfo){
            this.question = question;
            this.questionBankResponseOptions = questionBankResponseOptions;
            this.questionResponseSet = questionResponseSet;
            this.tagsList = tagsLists; 
            this.QuestionValidationRuleInfo = QuestionValidationRuleInfo; 
        }
        //added for default response
        global SFM_QuestionBank(SVMXC__Question_Bank__c question, List<SVMXC__QB_Response_Options__c> questionBankResponseOptions, SVMXC__QB_Response_Set__c questionResponseSet, List<String> tagsLists,SFM_QuestionValidationRuleInfo QuestionValidationRuleInfo, SVMXC__SM_Default_Checklist_Response__c defaultChecklistResponse, SFM_DefaultResponseJSON defaultResponseJSON){
            this.question = question;
            this.questionBankResponseOptions = questionBankResponseOptions;
            this.questionResponseSet = questionResponseSet;
            this.tagsList = tagsLists; 
            this.QuestionValidationRuleInfo = QuestionValidationRuleInfo;
            this.defaultChecklistResponse = defaultChecklistResponse;
            this.defaultResponseJSON = defaultResponseJSON;
        }
    }
    
    //Wrapper class for Question information
    global class SFM_Question{
        webservice String questionID{set; get;}
        webservice String question{set; get;}
        webservice String description{set; get;}
        webservice String responseType{set; get;}
        webservice Boolean active{set; get;}
        webservice Boolean descriptionRequired{set; get;}
        webservice Boolean ShowInSmartDoc{set; get;}
        webservice Double precision{set; get;}
        webservice Double scale{set; get;}
        webservice Double length{set; get;}
        webservice Boolean captureComments{set; get;}
        webservice String questionJSON{set; get;}
        webservice String shortname{set; get;}
        webservice String helpURL{set; get;}
        
        //Constructor
        global SFM_Question(){
            this.active = true;
        }
    }
    
    //Wrapper class for Question Response Option information
    global class SFM_QuestionResponse{
        webservice String questionID{set; get;}
        webservice String response{set; get;}
        webservice Boolean active{set; get;}
        webservice Double sequence{set; get;}
        webservice String masterResponse{set; get;} //Added for the story BAC-3446 for sending master response values
        
        //Constructor
        global SFM_QuestionResponse(){
            this.active = true;
        }
    }
    
    //Wrapper class for Question Info contains Question and their Response Option
    global class SFM_QuestionInfo{
        webservice SFM_Question question = new SFM_Question();
        webservice List<SFM_QuestionResponse> questionResponses = new List<SFM_QuestionResponse>();
        //by Jaysukh added for default checklist response
        webservice SVMXC__SM_Default_Checklist_Response__c defaultChecklistRes=new SVMXC__SM_Default_Checklist_Response__c();       
        global void setquestion(SFM_Question question){    this.question = question;   }
        global SFM_Question getquestion(){ return question;    }
        global void setquestionResponses(List<SFM_QuestionResponse> questionResponses){  this.questionResponses = questionResponses; }
        global List<SFM_QuestionResponse> getquestionResponses(){  return questionResponses; }
        
        //Constructor
        global SFM_QuestionInfo(){}
        global SFM_QuestionInfo(SFM_Question question, List<SFM_QuestionResponse> questionResponses){
            this.question = question;
            this.questionResponses = questionResponses;
        }
        //added for checklist default response
        global SFM_QuestionInfo(SFM_Question question, List<SFM_QuestionResponse> questionResponses,SVMXC__SM_Default_Checklist_Response__c defaultChecklistRes){
            this.question = question;
            this.questionResponses = questionResponses;
            this.defaultChecklistRes = defaultChecklistRes;
        }
        
    }
    
    //Wrapper class of SFM_CKLS_Response
    global class SFM_ChecklistInfo
    {
        webservice String recordId {get;set;}
        webservice String processId {get;set;}
        webservice String sfProcessId {get;set;}
        webservice String processName {get;set;}
        webservice String status {get;set;}
        webservice String targetId {get;set;}
        webservice String description {get;set;}
        webservice Datetime completionDate {get;set;}
        //webservice String completedBy {get;set;}
        
        global SFM_ChecklistInfo(String recordId,String processId,String processName,String status, String targetId, String description, Datetime completionDate)
        {
            this.recordId = recordId;            
            this.processId = processId;
            this.processName = processName;
            this.status = status;
            this.targetId = targetId;
            this.description = description;
            this.completionDate = completionDate;
        }
        global SFM_ChecklistInfo(String recordId,String processId,String processName,String status, String targetId, String description, Datetime completionDate, String sfProcessId)
        {
            this.recordId = recordId;            
            this.processId = processId;
            this.sfProcessId = sfProcessId;
            this.processName = processName;
            this.status = status;
            this.targetId = targetId;
            this.description = description;
            this.completionDate = completionDate;
        }
        
        global SFM_ChecklistInfo() 
        {
             
        }
        
        global SFM_ChecklistInfo(String recordId,String processId,String processName,String status) 
        {
             
        }
    }
    //Wrapper: Checklist Validation Rule Info
    global class SFM_QuestionValidationRuleInfo
    {
        webservice string questionBankId {get;set;} 
        webservice string questionId {get;set;} 
        webservice string checklistId {get;set;} 
        webservice SVMXC__ServiceMax_Processes__c QuestionValidationRule = new SVMXC__ServiceMax_Processes__c();
        webservice List<SVMXC__ServiceMax_Config_Data__c> lstQuestionValidationRuleDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        global SVMXC__ServiceMax_Processes__c getQuestionValidationRule(){return QuestionValidationRule;}
        global void setQuestionValidationRule(SVMXC__ServiceMax_Processes__c QuestionValidationRule){this.QuestionValidationRule = QuestionValidationRule;} 
        global List<SVMXC__ServiceMax_Config_Data__c> getlstQuestionValidationRuleDetails(){return lstQuestionValidationRuleDetails;}
        global void setlstQuestionValidationRuleDetails(List<SVMXC__ServiceMax_Config_Data__c> lstQuestionValidationRuleDetails){this.lstQuestionValidationRuleDetails = lstQuestionValidationRuleDetails;}
        
        global SFM_QuestionValidationRuleInfo(){}
        global SFM_QuestionValidationRuleInfo(SVMXC__ServiceMax_Processes__c QuestionValidationRule, List<SVMXC__ServiceMax_Config_Data__c> lstQuestionValidationRuleDetails)
        {
            this.QuestionValidationRule = QuestionValidationRule;
            this.lstQuestionValidationRuleDetails = lstQuestionValidationRuleDetails;
        }
    }
    
    //BAC-5787 Wrapper: Formula - Field Update Rule
    global class FormulaObjectField {
        public List<FLDS> FLDS;
        public String OBJ;
    }

    global class FLDS {
        public String name;
    }
}