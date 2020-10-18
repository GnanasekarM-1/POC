global class INTF_WebServicesDef 
{
    // to get prefix of community
    Webservice static String COMM_GetCommunityPrefix()
    {
       COMM_SVMXC_Utils2 objClass = new COMM_SVMXC_Utils2();
       return objClass.GetCommunityPrefix();
    }
    // To get the installed package version for ServiceMax
    Webservice static List<COMM_Webservices.KeyValue> SVMX_GetSvmxVersion(List<COMM_Webservices.KeyValue> prequest)
    {
        return SVMXC.COMM_Webservices.SVMX_GetSvmxVersion(prequest);
    }
    
    //To get SFWHTML
    webService static String INTF_GetSFWHTML_WS(String recId, String keyVal)
    {
        SVMXC.INTF_GetServiceFlowWizard tbar = new SVMXC.INTF_GetServiceFlowWizard();
        return tbar.GetSFWHTML(recId,keyVal);
    }
    // created for outputdoc
    
    webService static INTF_Response INTF_GetSFWOutputTemplate_WS(String strRecId)
    {
        if(strRecId != null && strRecId.length() > 3)
        {
            string strKeyPrefix = strRecId.subString(0, 3);
            string strObjName = '';
            List<String> responceWS = new List<String>();
            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            for(String strObj : allObjs.keySet())
            {
                Schema.DescribeSObjectResult describeResult = allObjs.get(strObj).getDescribe();
                if(describeResult.getKeyPrefix() != null && describeResult.getKeyPrefix().equals(strKeyPrefix))
                {
                    strObjName = describeResult.getName();
                    break;
                }
            }
            if(strObjName != null && strObjName.length() > 0)
            {
                ServiceFlowWizard_Utils SFWUtils = new ServiceFlowWizard_Utils();
                Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_SfmOutputDocActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
                Map_SfmOutputDocActions = SFWUtils.SVMX_GetSFMOutputDocActions(strObjName);
                if(Map_SfmOutputDocActions != null && Map_SfmOutputDocActions.containsKey(strObjName))
                {
                    INTF_Response resObj =  new INTF_Response();
                    resObj.valueMap = new List<SVMXMap>();
                    for(SVMXC__ServiceMax_Processes__c lstPrcss : Map_SfmOutputDocActions.get(strObjName))
                    {
                        /*if(lstPrcss.SVMXC__Name__c != null && lstPrcss.SVMXC__Name__c.length() > 0)
                        {
                            lstPrcss.SVMXC__Name__c = lstPrcss.SVMXC__Name__c.replace('&', '&amp;');
                            lstPrcss.SVMXC__Name__c = lstPrcss.SVMXC__Name__c.replace('\'', '\\\'');
                            lstPrcss.SVMXC__Name__c = lstPrcss.SVMXC__Name__c.replace('<', '&lt;');
                            lstPrcss.SVMXC__Name__c = lstPrcss.SVMXC__Name__c.replace('>', '&gt;');
                            lstPrcss.SVMXC__Name__c = lstPrcss.SVMXC__Name__c.replace('"', '&quot;');
                        }
                        if(lstPrcss.SVMXC__ProcessID__c != null && lstPrcss.SVMXC__ProcessID__c.length() > 0)
                        {
                            lstPrcss.SVMXC__ProcessID__c = lstPrcss.SVMXC__ProcessID__c.replace('&', '&amp;');
                            lstPrcss.SVMXC__ProcessID__c = lstPrcss.SVMXC__ProcessID__c.replace('\'', '\\\'');
                            lstPrcss.SVMXC__ProcessID__c = lstPrcss.SVMXC__ProcessID__c.replace('<', '&lt;');
                            lstPrcss.SVMXC__ProcessID__c = lstPrcss.SVMXC__ProcessID__c.replace('>', '&gt;');
                            lstPrcss.SVMXC__ProcessID__c = lstPrcss.SVMXC__ProcessID__c.replace('"', '&quot;');
                        }*/
                        SVMXMap objSvmxMap = new SVMXMap();
                        objSvmxMap.record = lstPrcss;
                        resObj.valueMap.add(objSvmxMap);
                    }
                    return resObj;
                }
            }
        } 
        return null;
    }
    
    
    // To get SFW Wrapper
    // To get SFW Wrapper
    webService static INTF_Response_SFWInfo INTF_GetSFWWrapper_WS(SFM_WrapperDef.SFM_Request req)
    {
        SVMXC.INTF_GetServiceFlowWizard SFW = new SVMXC.INTF_GetServiceFlowWizard();
        return SFW.getSFWWrapper(req);
    }
    
    //Added By :- Naveen V (15-Dec-2011) -- To get URL for Next Wizard Step 
    webService static INTF_SFMResponse INTF_GetNextStepURL_WS(INTF_WebServicesDef.INTF_SFMRequest request)
    {
        INTF_SFMResponse response = new INTF_SFMResponse();
        String recId;
        String nxtWizardStepId;
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = request.valueMap;
        if(lstSVMXMap.size() > 0)
        {
            for(Integer i = 0;i<lstSVMXMap.size();i++)
            {
                if(lstSVMXMap[i].key.toUppercase() == 'SVMX_PROCESSID')
                    nxtWizardStepId = lstSVMXMap[i].value;
                if(lstSVMXMap[i].key.toUppercase() == 'SVMX_recordId')
                    recId = lstSVMXMap[i].value; 
            }
        }
        SVMXC.ServiceFlowWizard_Utils wizardUtilsObj = new SVMXC.ServiceFlowWizard_Utils();
        response.message = wizardUtilsObj.SVMX_GetNextStepURL(recId,nxtWizardStepId);
        System.debug('URL for next process in responce : '+response.message);
        response.success = true;
        return response;
    }
    
    //wrapper INTF_Response_SFWInfo
    global class INTF_Response_SFWInfo{
        webservice String ObjectName;
        webservice String RecordId;
        webservice List<SVMXC__ServiceMax_Processes__c> availableActions = new List<SVMXC__ServiceMax_Processes__c>();
        webservice List<SFM_SFWInfo> SFWs = new List<SFM_SFWInfo>();

        public INTF_Response_SFWInfo(){}
        public String getObjectName(){
            return ObjectName;
        }
        public void setObjectName(String ObjName){
            this.ObjectName = ObjName;
        }
    
        public String getRecordId(){
            return RecordId;
        }
        public void setRecordId(String RecId){
            this.RecordId = RecId;
        }
        
        public List<SVMXC__ServiceMax_Processes__c> getAvailableActions()
        {
            return availableActions;
        }
        
        public void setAvailableActions(List<SVMXC__ServiceMax_Processes__c> actnLst)
        {
            this.availableActions = actnLst;
        }
    
        public List<SFM_SFWInfo> getSFWs(){
            return SFWs;
        }
        public void setSFWs(List<SFM_SFWInfo> tlbarInfoLst){
            this.SFWs = tlbarInfoLst;
        }
    
        public INTF_Response_SFWInfo(String objName, Id RecId, List<SFM_SFWInfo> SFMTlbarInfoLst){
            this.ObjectName = objName;
            this.RecordId = RecId;
            this.SFWs = SFMTlbarInfoLst;
        }
    }
    global class SFM_SFWInfo {
        webservice SVMXC__ServiceMax_Processes__c SFWDef = new SVMXC__ServiceMax_Processes__c();
        webservice Integer row;
        webservice Integer col;
        webservice List<SFM_SFWActionsInfo> actions = new List<SFM_SFWActionsInfo>();
        
        public SFM_SFWInfo(){}
        public SVMXC__ServiceMax_Processes__c getSFWDef(){
            return SFWDef;
        }
        public void setSFWDef(SVMXC__ServiceMax_Processes__c SFWDefRec){
            this.SFWDef = SFWDefRec;
        }
        
        public Integer getrow(){
            return row;
        }
        public void setrow(Integer rowNum){
            this.row = rowNum;
        }
        
        public Integer getcol(){
            return col;
        }
        public void setcol(Integer columnNum){
            this.col = columnNum;
        }
        
        public List<SFM_SFWActionsInfo> getactions(){
            return actions;
        }
        public void setactions(List<SFM_SFWActionsInfo> SFWActnsInfoLst){
            this.actions = SFWActnsInfoLst;
        }
    
        public SFM_SFWInfo(SVMXC__ServiceMax_Processes__c tlbarDef , Integer rowNum , Integer colNum, List<SFM_SFWActionsInfo> SFMActnLst){
            this.SFWDef = tlbarDef;
            this.row = rowNum;
            this.col = colNum;
            this.actions = SFMActnLst;
        }
    }
    global class SFM_SFWActionsInfo {

        webservice SVMXC__ServiceMax_Processes__c actionDef = new SVMXC__ServiceMax_Processes__c();
        webservice Boolean Enabled;
        //new member introduce for laptop
        webservice SVMXC__ServiceMax_Processes__c customActionRecord = new SVMXC__ServiceMax_Processes__c();
        webservice List<INTF_StringMap> customActionParams = new List<INTF_StringMap>();
        
        public SFM_SFWActionsInfo(){}
        public SVMXC__ServiceMax_Processes__c getactionDef(){
            return actionDef;
        }
        public void setactionDef(SVMXC__ServiceMax_Processes__c ActnRec){
            this.actionDef = ActnRec;
        }
        public Boolean getEnabled(){
            return Enabled;
        }
        public void setEnabled(Boolean enabld){
            this.Enabled = enabld;
        }
    
        public SFM_SFWActionsInfo(SVMXC__ServiceMax_Processes__c ActnRec, Boolean enabld){
            this.actionDef = ActnRec;
            this.Enabled = enabld;
        }
        
        public SFM_SFWActionsInfo(SVMXC__ServiceMax_Processes__c ActnRec, Boolean enabld, SVMXC__ServiceMax_Processes__c custmActn, List<INTF_StringMap> lstActnctionParams)
        {
            this.actionDef = ActnRec;
            this.customActionRecord = custmActn;
            this.Enabled = enabld;
            this.customActionParams = lstActnctionParams;
        }
        
        public List<INTF_StringMap> getCustomActionParams(){return customActionParams;}
        public void setCustomActionParams(List<INTF_StringMap> s ){customActionParams = s;}
    }
    
    public class SVMXException extends Exception {}
    
    global class INTF_Event_WP{
        WebService String id{get; set;}
        WebService String startDateTime {get; set;}
        WebService String endDateTime {get; set;}
    }
    
    global class INTF_LookUpConfigData
    {
        webservice INTF_Response_NamedSearchInfo namesearchinfo{get; set;}
        webservice List<bubble_wp> data{get; set;}
        global INTF_LookUpConfigData()
        {
            
        }
    }
    global class bubble_wp
    {
        webservice List<INTF_StringFieldMap> FieldMap{get;set;}
        global bubble_wp(List<INTF_StringFieldMap> FieldMap)
        {
            this.FieldMap = FieldMap;
        }
    }
    global class INTF_Response_NamedSearchInfo
    {
        webservice List<INTF_NamedSearchInfo> namedSearch{get; set;}
        
        global INTF_Response_NamedSearchInfo(List<INTF_NamedSearchInfo> namedSearch)
        {
            this.namedSearch = namedSearch;
        }
        global INTF_Response_NamedSearchInfo(){}
    }
    
    global class INTF_NamedSearchInfo
    {
        webservice SVMXC__ServiceMax_Processes__c namedSearchHdr{get; set;}
        webservice List<INTF_NamedSearchInfoDetail> namedSearchDetails{get; set;}
        webservice String fieldsToNull{get;set;}
        global INTF_NamedSearchInfo(SVMXC__ServiceMax_Processes__c namedSearchHdr, List<INTF_NamedSearchInfoDetail> namedSearchDetails){
            this.namedSearchHdr = namedSearchHdr;
            this.namedSearchDetails = namedSearchDetails;
        }
    }
    global class INTF_NamedSearchInfoDetail
    {
        webservice SVMXC__ServiceMax_Processes__c objectDetails{get; set;}
        webservice List<SVMXC__ServiceMax_Config_Data__c> fields{get; set;}
        webservice String fieldsToNull{get;set;}
        global INTF_NamedSearchInfoDetail(SVMXC__ServiceMax_Processes__c objectDetails, List<SVMXC__ServiceMax_Config_Data__c> fields){
            this.objectDetails = objectDetails;
            this.fields = fields;
        }
    }
    global class INTF_MapStringMap
    {
        webservice String key {get;set;}
        webservice String id{get;set;}  // Neeraj(Apr:26th-2012): Added for SFM Search to return row id.
        webservice List<INTF_StringMap> valueMap = new List<INTF_StringMap>();
        webservice String fieldsToNull{get;set;}
        
        global INTF_MapStringMap(String key,List<INTF_StringMap> valueMap)
        {
            this.key = key;
            this.valueMap = valueMap;
        }
        global INTF_MapStringMap()
        {
            
        }
        
        global List<INTF_StringMap> getvalueList(){return valueMap;}
        global void setvalueMap(List<INTF_StringMap> s ){valueMap = s;}
    }
    global class INTF_StringFieldMap
    {
        webservice String key {get;set;}
        webservice String value{get;set;}
        webservice String ftype{get;set;}
        webservice String fieldsToNull{get;set;}
        
        global INTF_StringFieldMap(String k,String v,String s) 
        {
            key = k;
            value = v;
            ftype = s;
        }
        
        global INTF_StringFieldMap(){
            
        }
    }
    //Wrapper class of INTF_Response
    global class INTF_Response 
    {
        webservice Boolean success {get;set;}
        webservice String message {get;set;}
        webservice String messageType {get;set;}
        webservice String tagId {get;set;}
        webservice String eventType {get;set;}
        webservice List<INTF_StringMap> stringMap = new List<INTF_StringMap>();
        webservice List<INTF_StringFieldMap> stringFieldMap = new List<INTF_StringFieldMap>();
        webservice List<SVMX_Debug.SMAX_Debug> logMsg;
        webservice list<SVMXError> errors = new list<SVMXError>();
        webservice List<String> resultIds = new List<String>();
        webservice  List<INTF_StringListMap> StringLstMap = new List<INTF_StringListMap>();
        webservice  List<INTF_MapStringMap> MapStringMap = new List<INTF_MapStringMap>();
        webservice List<INTF_SearchInfo> lstSearchInfo {get;set;}  // Neeraj(Dec-20th): Added for Search Delivery.
        webservice  List<SVMXMap> valueMap{get;set;}
        
        global INTF_Response(List<SVMXMap> valueMap )
        {
         this.valueMap = valueMap;
        }
        
        global INTF_Response(Boolean success,String message,String tagId,List<INTF_StringMap> stringMap,List<SVMX_Debug.SMAX_Debug> logMsg,List<String> resultIds)//List<INTF_StringFieldMap> stringFieldMap commented by amar
        {
            this.success = success;
            this.message = message;
            this.tagId = tagId;
            this.stringMap = stringMap;
            this.logMsg = logMsg;
            this.resultIds=resultIds;
            //this.stringFieldMap=stringFieldMap;
        }
        global INTF_Response()
        {
        }
        global List<INTF_StringMap> getstringMap(){return stringMap;}
        global void setstringMap(List<INTF_StringMap> s){stringMap = s ;}
        global List<INTF_StringFieldMap> getstringFieldMap(){return stringFieldMap;}
        global void setstringFieldMap(List<INTF_StringFieldMap> s){stringFieldMap = s ;}
        global List<INTF_StringListMap> getStringLstMap(){return StringLstMap;}
        global void setStringLstMap(List<INTF_StringListMap> s){StringLstMap = s ;}
        global List<INTF_MapStringMap> getMapStringMap(){return MapStringMap;}
        global void setMapStringMap(List<INTF_MapStringMap> s){MapStringMap = s ;}
        global list<SVMXError> geterrors() {return errors;}
        global void seterrors(List<SVMXError> e){errors = e ;}
         
    }
    // Neeraj(Dec-20th): Wrapper Added for Search Delivery.
    global class INTF_SearchInfo
    {
        webservice SVMXC__ServiceMax_Processes__c searchDef{get; set;}
        webservice List<INTF_SearchInfoDetail> searchDetails{get; set;}
        webservice String fieldsToNull{get;set;}
        global INTF_SearchInfo(SVMXC__ServiceMax_Processes__c SearchDef, List<INTF_SearchInfoDetail> SearchDetails){
            this.searchDef = searchDef;
            this.SearchDetails = SearchDetails;
        }
    }
    // Neeraj (Dec-20th): Wrapper Added for Search Delivery.
    global class INTF_SearchInfoDetail
    {
        webservice SVMXC__ServiceMax_Processes__c objectDetails{get; set;}
        webservice List<SVMXC__ServiceMax_Config_Data__c> fields{get; set;}
        webservice String fieldsToNull{get;set;}
        webservice List<INTF_StringMap> fieldsLable{get; set;}
        webservice String objectLable{get;set;}
        global INTF_SearchInfoDetail(SVMXC__ServiceMax_Processes__c objectDetails, List<SVMXC__ServiceMax_Config_Data__c> fields, List<INTF_StringMap> fieldsLable)
        {
            this.objectDetails =objectDetails;
            this.fields = fields;
            this.fieldsLable = fieldsLable;
        }
        global INTF_SearchInfoDetail()
        {}
    }
    
    
    global class INTF_StringListMap
    {
        webservice String key {get;set;}
        webservice List<String> valueList = new List<String>();
        webservice String fieldsToNull{get;set;}
        webservice Sobject sobj {get;set;}
        global INTF_StringListMap(String key,List<String> valueList)
        {
            this.key = key;
            this.valueList = valueList;
        }
        global INTF_StringListMap()
        {
            
        }
        
        global List<String> getvalueList(){return valueList;}
        global void setvalueList(List<String> s ){valueList = s;}
    }
    //Wrapper class of INTF_Request
    global class INTF_Request
    {
        webservice  string userId {get;set;}
        webservice  String groupId {get;set;}
        webservice  String profileId {get;set;}
        webservice  String fieldsToNull {get;set;}
        webservice  List<String> recordIds = new List<String>(); 
        webservice  List<INTF_StringMap> stringMap = new List<INTF_StringMap>(); 
        webservice  List<INTF_StringListMap> stringListMap = new List<INTF_StringListMap>();
        webservice  List<SVMXMap> valueMap{get;set;}
        
        global INTF_Request(List<SVMXMap> valueMap )
        {
             this.valueMap = valueMap;
        }
        
        global INTF_Request(String userId,String groupId,String profileId,List<INTF_StringMap> stringMap)
        {
            this.userId = userId;
            this.groupId = groupId;
            this.profileId = profileId;
            this.stringMap = stringMap;
        }
        
        global INTF_Request()
        {
            
        }
        global List<INTF_StringMap> getstringMap(){return stringMap;}
        global void setstringMap(List<INTF_StringMap> s){stringMap = s ;}
        global List<INTF_StringListMap> getstringListMap(){return stringListMap;}
        global void setstringListMap(List<INTF_StringListMap> s){stringListMap = s ;}
    }  
    //Expression Wrapper
    global class INTF_Expression
    {
        webservice SVMXC__ServiceMax_Processes__c namedExpression = new SVMXC__ServiceMax_Processes__c();
        webservice List<SVMXC__ServiceMax_Config_Data__c> expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        webservice String fieldsToNull{get;set;}
        global SVMXC__ServiceMax_Processes__c getnamedExpression() {return namedExpression;}
        global void setnamedExpression(SVMXC__ServiceMax_Processes__c s) { namedExpression = s;} 
        global List<SVMXC__ServiceMax_Config_Data__c> getexpressionDetails(){return expressionDetails;}
        global void setexpressionDetails(List<SVMXC__ServiceMax_Config_Data__c> s){expressionDetails = s;}
        
        global INTF_Expression(SVMXC__ServiceMax_Processes__c namedExpression,List<SVMXC__ServiceMax_Config_Data__c> expressionDetails)
        {
            this.namedExpression = namedExpression;
            this.expressionDetails = expressionDetails;
        }
        global INTF_Expression(){}
    }
    
    global class INTF_Request_Expression
    {
        webservice List<INTF_Expression> expressions = new List<INTF_Expression>();
        webservice INTF_Request request{get;set;}
        webservice String fieldsToNull{get;set;}
        global List<INTF_Expression> getexpressions(){return expressions;}
        global void setexpressions(List<INTF_Expression> s){ expressions = s;}
        
        global INTF_Request_Expression(List<INTF_Expression> expressions)//,String uid,String gid,String pid,List<INTF_StringMap> strmap
        {
            //super();//uid,gid,pid,strmap
            request = new INTF_Request();
            this.expressions = expressions;
        }
    }
    global class INTF_Response_Expression
    {
        webservice List<INTF_Expression> expressions = new List<INTF_Expression>();
        
        global List<INTF_Expression> getexpressions(){return expressions;}
        global void setexpressions(List<INTF_Expression> s){ expressions = s;}
        webservice INTF_Response response{get;set;}
        global INTF_Response_Expression(List<INTF_Expression> expressions)//,Boolean s,String msg,String tid,List<INTF_StringMap> strmap
        {
            //super();//s,msg,tid,strmap
            response = new INTF_Response();
            this.expressions = expressions;
        }
        global INTF_Response_Expression(){}
    }
     
    global class INTF_BubbleWrapper
    {
        webservice INTF_StringMap fieldvalue = new INTF_StringMap();
        webservice List<INTF_StringMap> bubbleinfo = new List<INTF_StringMap>();
        webservice String fieldapiname {get;set;}
        global INTF_BubbleWrapper(){}
    }
    //Wrapper class of bubble with field value and its bubble class 
    global class INTF_DetailBubbleWrapper
    {
        webservice Sobject sobjectinfo;
        webservice List<INTF_BubbleWrapper> bubbleinfolist = new List<INTF_BubbleWrapper>(); 
        global INTF_DetailBubbleWrapper(){}
    }
    
    global class PMaxException extends Exception {}
    global class INTF_UIButton
    {
        webservice SVMXC__Page_Layout_Detail__c buttonDetail = new SVMXC__Page_Layout_Detail__c();
        webservice List<SVMXC__SFM_Event__c> buttonEvents = new List<SVMXC__SFM_Event__c>();
        webservice String fieldsToNull{get;set;}
        //for iPad
        webservice Integer sequence;
        webservice Boolean enable;
        global INTF_UIButton(SVMXC__Page_Layout_Detail__c buttonDetail,List<SVMXC__SFM_Event__c> buttonEvents)
        {
            this.buttonDetail = buttonDetail;
            this.buttonEvents = buttonEvents;
        }
        global INTF_UIButton()
        {
            
        }
        
    }
    global class INTF_UIField
    {
        
        webservice SVMXC__Page_Layout_Detail__c fieldDetail = new SVMXC__Page_Layout_Detail__c();
        webservice List<SVMXC__SFM_Event__c> fieldEvents = new List<SVMXC__SFM_Event__c>();
        webservice String fieldsToNull{get;set;}
        webservice INTF_BubbleWrapper bubbleinfo = new INTF_BubbleWrapper();
        global INTF_UIField(SVMXC__Page_Layout_Detail__c fieldDetail,List<SVMXC__SFM_Event__c> fieldEvents,INTF_BubbleWrapper bubbleinfo)//,INTF_Response_NamedSearchInfo namesearchinfo
        {
            this.fieldDetail = fieldDetail;
            this.fieldEvents = fieldEvents;
            this.bubbleinfo = bubbleinfo;
        }
        global INTF_UIField()
        {
            
        }
    }
    global class INTF_UISection
    {
        
        webservice SVMXC__Page_Layout_Detail__c sectionDetail = new SVMXC__Page_Layout_Detail__c();
        webservice List<INTF_UIField> fields = new List<INTF_UIField>();
        webservice String fieldsToNull{get;set;}
        
        global SVMXC__Page_Layout_Detail__c getsectionDetail(){return sectionDetail;}
        global void setsectionDetail(SVMXC__Page_Layout_Detail__c s){sectionDetail = s;}
        global List<INTF_UIField> getfields(){return fields;}
        global void setfields(List<INTF_UIField> s){fields = s;}
        
        global INTF_UISection(SVMXC__Page_Layout_Detail__c sectionDetail,List<INTF_UIField> fields)//
        {
            this.sectionDetail = sectionDetail;
            this.fields = fields;
        }
        global INTF_UISection()
        {
            
        }
    }
    global class INTF_PageHeader
    {
        webservice SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        webservice List<INTF_UISection> sections = new List<INTF_UISection>();
        webservice List<INTF_UIButton> buttons = new List<INTF_UIButton>();
        webservice List<SVMXC__SFM_Event__c> pageEvents = new List<SVMXC__SFM_Event__c>();
        webservice Sobject hdrData {get;set;}
        webservice String hdrLayoutId {get;set;}
        webservice String fieldsToNull{get;set;}
        webservice list<INTF_UIField> allfields = new list<INTF_UIField>();
        global INTF_PageHeader(SVMXC__Page_Layout__c headerLayout,List<INTF_UISection> sections,List<INTF_UIButton> buttons,List<SVMXC__SFM_Event__c> pageEvents)
        {
            this.headerLayout = headerLayout;
            this.sections = sections;
            this.buttons = buttons;
            this.pageEvents = pageEvents;
        }
        global INTF_PageHeader()
        {
            
        }
        
    }   
    global class INTF_PageDetail
    {
        webservice SVMXC__Page_Layout__c DetailLayout = new SVMXC__Page_Layout__c();
        webservice Integer noOfColumns = 2;
        webservice List<INTF_UIField> fields = new List<INTF_UIField>();
        webservice List<INTF_UIButton> buttons = new List<INTF_UIButton>();
        webservice List<SVMXC__SFM_Event__c> events = new List<SVMXC__SFM_Event__c>();
        webservice List<INTF_DetailBubbleWrapper> bubbleinfolist = new List<INTF_DetailBubbleWrapper>(); 
        webservice String dtlLayoutId {get;set;}
        webservice String fieldsToNull{get;set;}
        
        global INTF_PageDetail(SVMXC__Page_Layout__c DetailLayout,List<INTF_UIField> fields,List<INTF_UIButton> buttons,List<INTF_DetailBubbleWrapper> bubbleinfolist)
        {
            this.DetailLayout = DetailLayout;
            this.fields = fields;
            this.buttons = buttons;
            this.bubbleinfolist = bubbleinfolist;
        }
        global INTF_PageDetail()
        {
            
        }
    }
    global class INTF_PageUI 
    {
        webservice String processTitle {get;set;}
        webservice INTF_PageHeader header = new INTF_PageHeader();
        webservice List<INTF_PageDetail> details = new List<INTF_PageDetail>();
        webservice String fieldsToNull{get;set;}
        
        global INTF_PageUI(INTF_PageHeader header,List<INTF_PageDetail> details)
        {
            this.header = header;
            this.details = details;
        }
        global INTF_PageUI()
        {
            
        }
    }
    global class INTF_Request_PageUI
    {
        webservice INTF_PageUI page = new INTF_PageUI();
        webservice INTF_Request request{get;set;}
        webservice String fieldsToNull{get;set;}
        webservice SVMXC__ServiceMax_Processes__c processNode = new SVMXC__ServiceMax_Processes__c();
        global INTF_Request_PageUI(INTF_PageUI page,SVMXC__ServiceMax_Processes__c processNode,INTF_Request pmax)//String uid,String gid,String pid,List<INTF_StringMap> strmap
        {
            request = new INTF_Request();
            this.page = page;
            this.processNode = processNode;
        }
        global INTF_Request_PageUI()
        {
            request = new INTF_Request();
        }
        
    }
    global class INTF_Response_PageUI
    {
        webservice INTF_PageUI page = new INTF_PageUI();
        webservice INTF_Response response{get;set;}
        webservice String fieldsToNull{get;set;}
        
        global INTF_Response_PageUI(INTF_PageUI page)//,Boolean s,String msg,String tid,List<INTF_StringMap> strmap
        {
            response = new INTF_Response();
            this.page = page;
        }
        global INTF_Response_PageUI(){}
        
    }
     //Wrapper class of INTF_Request_For_Events
    global class INTF_Request_For_Events
    {
        webservice  String fieldsToNull {get;set;}
        webservice  List<INTF_StringMap> eventReqInfo {get;set;}
                
        global INTF_Request_For_Events(List<INTF_StringMap> eventReqInfo)
        {
            eventReqInfo = eventReqInfo;            
        }       
        global INTF_Request_For_Events()
        {
            
        }
    }
    //End of class INTF_Request_For_Events
   
     //Wrapper class of INTF_Request_For_Tags*/
    global class INTF_Request_For_Tags
    {
        webservice  String fieldsToNull {get;set;}
        webservice  List<INTF_StringMap> tagReqInfo {get;set;}
                
        global INTF_Request_For_Tags(List<INTF_StringMap> tagsReqInfo)
        {
            tagReqInfo = tagsReqInfo;           
        }       
        global INTF_Request_For_Tags()
        {
            
        }       
    }
    //End of class INTF_Request_For_Tags*/
    
    //Wrapper class of INTF_Request_For_Tasks*/
    global class INTF_Request_For_Tasks
    {
        webservice  String fieldsToNull {get;set;}
        webservice  List<INTF_StringMap> taskReqInfo {get;set;}
                
        global INTF_Request_For_Tasks(List<INTF_StringMap> taskReqInfo)
        {
            taskReqInfo = taskReqInfo;            
        }       
        global INTF_Request_For_Tasks()
        {
            
        }       
    }
    //End of class INTF_Request_For_Tasks*/
       
    //Wrapper class of INTF_Response_For_Tasks*/
    global class INTF_Response_For_Tasks
    {
        webservice  String fieldsToNull {get;set;}
        webservice  List<INTF_Task> taskInfo {get;set;}       
        webservice  List<INTF_StringMap> responseInfo {get;set;}
                
        global INTF_Response_For_Tasks(List<INTF_Task> taskInfo)
        {
            this.taskInfo = taskInfo;         
        }       
        global INTF_Response_For_Tasks()
        {
            
        }       
    }
    //End of class INTF_Response_For_Tasks*/
    
    //Wrapper class of INTF_Response_For_Tags*/
    global class INTF_Response_For_Tags
    {
        webservice  String fieldsToNull {get;set;}
        webservice  List<INTF_StringMap> tagInfo {get;set;}     
        webservice  List<INTF_StringMap> responseInfo {get;set;}
                
        global INTF_Response_For_Tags(List<INTF_StringMap> tagsResInfo)
        {
            tagInfo = tagsResInfo;          
        }       
        global INTF_Response_For_Tags()
        {
            
        }       
    }
    //End of class INTF_Response_For_Tags*/
    
    //Wrapper class of INTF_Response_For_Events*/
    global class INTF_Response_For_Events
    {
        webservice  String fieldsToNull {get;set;}
        webservice  List<INTF_Event> eventInfo {get;set;}  
        webservice  List<INTF_StringMap> responseInfo {get;set;}
                
        global INTF_Response_For_Events(List<INTF_Event> eventInfo)
        {
            this.eventInfo = eventInfo;         
        }       
        global INTF_Response_For_Events()
        {
            
        }       
    }
    //End of class INTF_Response_For_Events*/
    
    //Wrapper class of INTF_Response_For_Get_View_Layouts*/
    global class INTF_Response_For_Get_StandaloneCreate_Layouts
    {
        webservice  String fieldsToNull {get;set;}
        webservice  List<SVMXC__ServiceMax_Processes__c> layoutsInfo {get;set;}       
        webservice  List<INTF_StringMap> responseInfo {get;set;}
                
        global INTF_Response_For_Get_StandaloneCreate_Layouts(List<SVMXC__ServiceMax_Processes__c> layoutsInfo)
        {
            this.layoutsInfo = layoutsInfo;         
        }       
        global INTF_Response_For_Get_StandaloneCreate_Layouts()
        {
            
        }       
    }
    //End of class INTF_Response_For_Get_View_Layouts*/
    
    //Wrapper class of INTF_Response_For_Get_StandaloneCreate_Layouts*/
    global class INTF_Response_For_Get_View_Layouts
    {
        webservice  String fieldsToNull {get;set;}
        webservice  List<INTF_Response_For_Get_Object_Layouts> layoutsInfo {get;set;}       
        webservice  List<INTF_StringMap> responseInfo {get;set;}
                
        global INTF_Response_For_Get_View_Layouts(List<INTF_Response_For_Get_Object_Layouts> layoutInfo)
        {
            this.layoutsInfo = layoutInfo;         
        }       
        global INTF_Response_For_Get_View_Layouts()
        {
            
        }       
    }
    global class INTF_Response_For_Get_Object_Layouts
    {
        webservice  String fieldsToNull {get;set;}
        webservice  String objectName {get;set;}
        webservice  List<SVMXC__ServiceMax_Processes__c> layoutsInfo {get;set;}       
        webservice  List<INTF_StringMap> responseInfo {get;set;}
                
        global INTF_Response_For_Get_Object_Layouts(String objectName, List<SVMXC__ServiceMax_Processes__c> layoutsInfo)
        {
            this.objectName = objectName;
            this.layoutsInfo = layoutsInfo;         
        }       
        global INTF_Response_For_Get_Object_Layouts()
        {
            
        }       
    }
    //End of class INTF_Response_For_Get_StandaloneCreate_Layouts*/
           
    //Wrapper class for Event*/
    global class INTF_Event
    {
        webservice String fieldsToNull {get;set;}
        webservice Event eventInfo {get;set;}
        webservice List<INTF_StringMap> locationInfo {get;set;}
        webservice List<INTF_StringMap> eventDisplay {get;set;}
        global INTF_Event() 
        {}      
    }
    //End of class INTF_Event*/
    
    //Wrapper class for Task*/
    global class INTF_Task
    {
        webservice String fieldsToNull {get;set;}
        webservice Task taskInfo {get;set;}
        webservice List<INTF_StringMap> taskDisplay {get;set;}
        global INTF_Task() 
        {}      
    }
    //End of class INTF_Task*/
    
    //Wrapper class to store the key value pairs*/ 
    global class INTF_StringMap
    {
        webservice String key {get;set;}
        webservice String value {get;set;}
        webservice String value1{get;set;}
        webservice String sortValue{get;set;}  // Neeraj(Jan:20th-2012): Added for SFM Search to perform sort.
        webservice String type{get;set;}  // Neeraj(Apr:26th-2012): Added for SFM Search to return datatype.
        webservice String fieldsToNull {get;set;}
        
        global INTF_StringMap(String strKey,String strValue) 
        {
            this.key = strKey;
            this.value = strValue;
        }   
        global INTF_StringMap()
        {}  
    }
    //End of class SFM_StringMap*/
    
    
    //WebService and Wrappers for the Get history methods*/
    
    //Wrapper class of INTF_Request_For_Product_History*/
    global class INTF_Request_For_History
    {
        webservice  String fieldsToNull {get;set;}
        webservice  List<INTF_StringMap> historyReqInfo {get;set;}
                
        global INTF_Request_For_History(List<INTF_StringMap> historyReqInfo)
        {
            historyReqInfo = historyReqInfo;            
        }       
        global INTF_Request_For_History()
        {
            
        }       
    }
    //End of class INTF_Request_For_Product_History*/
    
    //Wrapper class of INTF_Response_For_Product_History*/
    global class INTF_Response_For_History
    {
        webservice  String fieldsToNull {get;set;}
        webservice  List<SVMXC__Service_Order__c> historyInfo {get;set;}       
        webservice  List<INTF_StringMap> responseInfo {get;set;}
                
        global INTF_Response_For_History(List<SVMXC__Service_Order__c> historyInfo)
        {
            this.historyInfo = historyInfo;         
        }       
        global INTF_Response_For_History()
        {
            
        }       
    }
    //End of class INTF_Response_For_Product_History*/
    
    // WebService to get the Product histoy data*/
    Webservice static INTF_Response_For_History INTF_Get_Product_History_WS(INTF_Request_For_History prodHistoryRequest)
    {
        SVMXC.INTF_Get_WorkOrder_History objGetHistory = new SVMXC.INTF_Get_WorkOrder_History();
        try
        {   
            return objGetHistory.INTF_Get_Product_History(prodHistoryRequest) ;
        }
        catch(Exception ex)
        {
            throw ex;
        }      
    }
    // End of the WebService to get the Product histoy data*/
    
    // WebService to get the Account histoy data*/
    Webservice static INTF_Response_For_History INTF_Get_Account_History_WS(INTF_Request_For_History accHistoryRequest)
    {
        SVMXC.INTF_Get_WorkOrder_History objGetHistory = new SVMXC.INTF_Get_WorkOrder_History();
        try
        {   
            return objGetHistory.INTF_Get_Account_History(accHistoryRequest) ;
        }
        catch(Exception ex)
        {
            throw ex;
        }      
    }
    // End of the WebService to get the Account histoy data*/   
    //End of methods for the get history*/
    
    // Webservice and wrappers to get the HomePageLayout */
    
    //Wrapper class of INTF_Response_For_Home_Page_Layout*/
    global class INTF_Response_For_Home_Page_Layout
    {
        webservice  String fieldsToNull {get;set;} 
        webservice  List<INTF_StringMap> layoutInfo {get;set;}          
        webservice  List<INTF_StringMap> responseInfo {get;set;}
                
        global INTF_Response_For_Home_Page_Layout()
        {   
        }     
    }
    //End of class INTF_Response_For_Home_Page_Layout//
    
    // Wrapper definition for Save Target Data
    global class INTF_Record
    {
        webservice String fieldsToNull{get;set;}
        webservice String sourceRecordId{get;set;}  
        webservice List<INTF_StringMap> targetRecordAsKeyValue = new List<INTF_StringMap>(); 
        webservice String targetRecordId{get;set;}
        webservice String rowIndex {get;set;} //Added for the defect BAC-4534
        
        global INTF_Record(){}
        
        global List<INTF_StringMap> gettargetRecordAsKeyValue(){return targetRecordAsKeyValue;}
        global void settargetRecordAsKeyValue(List<INTF_StringMap> targetRecordAsKeyValue){this.targetRecordAsKeyValue = targetRecordAsKeyValue;}
    }
    
    global class INTF_TargetRecordObject
    {
        webservice String objName{get;set;}
        webservice String aliasName {get;set;}
        webservice String parentColumnName{get;set;}
        webservice List<String> deleteRecID = new List<String>();
        webservice String pageLayoutId {get;set;}
        webservice List<INTF_Record> records = new List<INTF_Record>();
        webservice String fieldsToNull{get;set;}
        
        global INTF_TargetRecordObject(){}
        
        global List<INTF_Record> getrecords(){return records;}
        global void setrecords(List<INTF_Record> records){this.records = records;}
        global List<String> getdeleteRecID(){return deleteRecID;}
        global void setdeleteRecID(List<String> deleteRecID){this.deleteRecID = deleteRecID;}
    }
    
    global class INTF_TargetRecord
    {
        webservice list<INTF_StringMap> stringMap = new list<INTF_StringMap>();
        webservice String fieldsToNull{get;set;}
        webservice String sfmProcessId {get;set;}
        webservice String eventType {get;set;}
        webservice INTF_TargetRecordObject headerRecord = new INTF_TargetRecordObject();
        webservice List<INTF_TargetRecordObject> detailRecords = new List<INTF_TargetRecordObject>();
        
        global  INTF_TargetRecord(){}
        
        global INTF_TargetRecordObject getheaderRecord(){return headerRecord;}
        global void setheaderRecord(INTF_TargetRecordObject headerRecord){this.headerRecord = headerRecord;} 
        global List<INTF_TargetRecordObject> getdetailRecords(){return detailRecords;}
        global void setdetailRecords(List<INTF_TargetRecordObject> detailRecords){this.detailRecords = detailRecords;}
    }
    
    //Webservice to Save TargetData....
    Webservice static INTF_Response INTF_SaveTargetRecords_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_saveTargetRecords SaveTarget = new SVMXC.INTF_saveTargetRecords();
        INTF_Response response = SaveTarget.SaveTargetRecords(request);
        return response;
    }
    //Webservice to Save TargetData....
    Webservice static INTF_Response SFM_SaveTargetRecords_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_saveTargetRecords SaveTarget = new SVMXC.INTF_saveTargetRecords();
        INTF_Response response = SaveTarget.SaveTargetRecords(request);
        return response;
    }
    
     // WebService to Save Events
    Webservice static String INTF_Update_Events_WS(List<INTF_Event_WP> request)
    {
        String StatusMessage;
        Savepoint sp = Database.setSavepoint();
        try
        {
            system.debug('mapEvents : '+ request);
            set<Id> requestedEvents = new set<Id>();
            DateTime startTime, endTime;
            for(INTF_Event_WP events: request)
            {
                startTime = DateTime.valueOfGmt(events.startDateTime);
                endTime = DateTime.valueOfGmt(events.endDateTime);
                requestedEvents.add(events.Id);
            }
            if(startTime != NULL && endTime != NULL && requestedEvents != NULL && requestedEvents.size() > 0)
            {
                Map<Id, Event> mapEvents = new Map<Id, Event>();
                List<Event> updatedEvents = new List<Event>();
                mapEvents.putAll([Select Id, ActivityDate, ActivityDateTime, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location from Event where Id IN :requestedEvents]);
                for(INTF_Event_WP events: request)
                {
                    Event objEvent = mapEvents.get(events.Id);
                    objEvent.ActivityDateTime = DateTime.valueOfGmt(events.startDateTime);
                    objEvent.ActivityDate = objEvent.ActivityDateTime.date();
                    objEvent.StartDateTime = objEvent.ActivityDateTime;
                    objEvent.EndDateTime = DateTime.valueOfGmt(events.endDateTime);
                    objEvent.DurationInMinutes = Integer.valueof((objEvent.EndDateTime.getTime() - objEvent.ActivityDateTime.getTime()) / 60000);
                    updatedEvents.add(objEvent);
                }
                system.debug('Event Details: ' + updatedEvents);
                if(updatedEvents.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(updatedEvents , COMM_SecurityUtils.Access.Updateable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update updatedEvents;
                    }
                }
            }
            StatusMessage = 'SUCCESS';
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getMessage());
        }
        return StatusMessage;
    }
    
    Webservice static List<INTF_PageDataSet> INTF_AddRecords_WS(INTF_Request prequest)
    {
        SVMXC.INTF_addRecords AddRecords = new SVMXC.INTF_addRecords();
        return AddRecords.getINTF_AddRecords(prequest);
    }
    
    //------------------------------ Service definitions ---------------------------------------------//
    global class INTF_PageDataSet
    {
        webservice String sourceRecordID {get;set;}
        webservice list<INTF_BubbleWrapper> bubbleInfo; 
        webservice Sobject sobjectinfo {get;set;}
        webservice List<INTF_StringMap> objectInfoMap {get;set;}
        webservice List<INTF_StringMap> defaultObjectValue {get;set;}
        webservice String rowIndex {get;set;} //Added for the defect BAC-4534
        global INTF_PageDataSet(){}
        
        global list<INTF_BubbleWrapper> getbubbleInfo(){return bubbleInfo;}
        global void setbubbleInfo(list<INTF_BubbleWrapper> bubbleInfo){this.bubbleInfo = bubbleInfo;}
        
    }
    global class INTF_DetailDataSet
    {
        webservice String aliasName {get;set;}
        webservice list<INTF_PageDataSet> pageDataSet;
        
        global INTF_DetailDataSet(){}
        global list<INTF_PageDataSet> getpageDataSet(){return pageDataSet;}
        global void setpageDataSet(list<INTF_PageDataSet> pageDataSet){this.pageDataSet =  pageDataSet;}
    }
    
    global class INTF_PageData
    {
        webservice String eventType {get;set;}
        webservice INTF_PageDataSet pageDataSet;
        webservice list<INTF_DetailDataSet> detailDataSet;
        webservice INTF_Response response{get;set;}
        webservice List<String> resultIds = new List<String>();
        webservice String fieldsToNull{get;set;}
        
        global INTF_PageData()
        {
            response = new INTF_Response();
        }
        
        global INTF_PageDataSet getpageDataSet(){return pageDataSet;}
        global void setpageDataSet(INTF_PageDataSet pageDataSet){this.pageDataSet = pageDataSet;}
        
        global list<INTF_DetailDataSet> getdetailDataset(){return detailDataSet;}
        global void setdetailDataset(list<INTF_DetailDataSet> detailDataSet){this.detailDataSet = detailDataSet;}
        
    }

    global class FieldProperties
    {
        webservice String key{get;set;}
        webservice String value{get;set;}
        webservice List<INTF_StringMap> properties{get;set;}
        webservice String fieldsToNull{get;set;}
        global FieldProperties(String key)
        {
            this.key = Key;
        }
        
        global FieldProperties(String key, String value, List<INTF_StringMap> properties)
        {
            this.key = Key;
            this.value = value;
            this.properties = properties;
        }
    }
    
    /* WebService to Get View layouts for the interface*/
    Webservice static INTF_Response_For_Get_View_Layouts INTF_Get_View_Layouts_WS()
    {
        try
        {   
            return (new SVMXC.INTF_Get_ServiceFlowList()).INTF_Get_View_Layouts() ;
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
    
    /* WebService to Get View layouts for the interface*/
    Webservice static INTF_Response_For_Get_StandaloneCreate_Layouts INTF_Get_StandaloneCreate_Layouts()
    {
        try
        {
            return (new SVMXC.INTF_Get_ServiceFlowList()).INTF_Get_StandaloneCreate_Layouts() ;
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
    /* Webservice Method to get the PageLayout....*/
    Webservice static INTF_Response_PageUI INTF_getPageLayout_WS(INTF_Request_PageUI PmaxReqPageUI)
    {
        try
        {
            SVMXC.INTF_GetPageLayout pagelayout = new SVMXC.INTF_GetPageLayout();
            return pagelayout.INTF_GetPageLayout(PmaxReqPageUI);
        }   
        catch(Exception ex)
        {
            throw new PMaxException(ex); 
        }
    }
    /* End of webservice get Page*/
    
    /* Webservice Method to save the PageLayout....*/
    webservice static INTF_Response INTF_SavePageLayout_WS(INTF_Request_PageUI PmaxReqPageUI)
    {
        try
        { 
            SVMXC.INTF_savePageLayout pagelayout = new SVMXC.INTF_savePageLayout();
            return pagelayout.INTF_SavePageLayout(PmaxReqPageUI);
        }
        catch(Exception ex)
        {
            throw new SFM_WrapperDef.PMaxException(ex); 
        }       
    }
    /* End of the WebService save the page*/
    
        
    /* WebService to Get Tags for the interface*/
    Webservice static INTF_Response_For_Tags INTF_Get_Tags_WS(INTF_Request_For_Tags tagsReq)
    {
        try
        {
            List<INTF_StringMap> lstReqForTags = tagsReq.tagReqInfo;
            List<INTF_StringMap> lstTags;
            INTF_Response_For_Tags objTagResponse = new INTF_Response_For_Tags();
            objTagResponse.responseInfo = new List<INTF_StringMap>();
            if(lstReqForTags != null && lstReqForTags.size() > 0)
            {
                COMM_TagsDefinition tagDefination = new COMM_TagsDefinition();
                lstTags = tagDefination.TagvalueCalc(lstReqForTags[0].value,Boolean.valueOf(lstReqForTags[1].value));
            }else
            {
                objTagResponse.responseInfo.add(new INTF_StringMap('FAULT','Please specfiy the valid request to get the Tags informations.'));
            }
            objTagResponse.tagInfo = lstTags;
            return objTagResponse;
        }catch(Exception ex)
        {
            throw ex;
        }
    }
    /* End of the WebService Get Tags for interface*/
    
    Webservice static INTF_Response INTF_Get_WorkOrderMapView_WS(INTF_Request request)
    {
        INTF_Response response = new INTF_Response();
        if(request.stringMap != NULL && request.stringMap.size() > 0)
        {
            list<Id> lstWorkorderIds = new list<Id>();
            for(INTF_StringMap strMap: request.stringMap)
            {
                if(strMap.key == 'WORKORDERID')
                    lstWorkorderIds.add(strMap.value);
            }
            if(lstWorkorderIds != NULL && lstWorkorderIds.size() > 0)
            {
                list<SVMXC__Service_Order__c> lstWorkOrder = new List<SVMXC__Service_Order__c>();
                lstWorkOrder = [Select Id, Name, SVMXC__Work_Performed__c, SVMXC__Order_Type__c, SVMXC__Contact__r.Name, SVMXC__Contact__r.Phone, SVMXC__Contact__r.Email, SVMXC__Problem_Description__c from SVMXC__Service_Order__c where Id IN : lstWorkorderIds];
                List<INTF_MapStringMap> lstWorkOrderWrapper = new List<INTF_MapStringMap>();
                for(SVMXC__Service_Order__c objWO: lstWorkOrder)
                {
                    INTF_MapStringMap wrpWO = new INTF_MapStringMap();
                    List<INTF_StringMap> valueMap = new List<INTF_StringMap>();
                    valueMap.add(new INTF_StringMap('Name', objWO.Name));
                    valueMap.add(new INTF_StringMap('SVMXC__Problem_Description__c', objWO.SVMXC__Problem_Description__c));
                    valueMap.add(new INTF_StringMap('SVMXC__Work_Performed__c', objWO.SVMXC__Work_Performed__c));
                    valueMap.add(new INTF_StringMap('SVMXC__Order_Type__c', objWO.SVMXC__Order_Type__c));
                    if(objWO.SVMXC__Contact__c != NULL)
                    {
                        valueMap.add(new INTF_StringMap('SVMXC__Contact__c', objWO.SVMXC__Contact__c));
                        valueMap.add(new INTF_StringMap('SVMXC__Contact__r.Name', objWO.SVMXC__Contact__r.Name));
                        valueMap.add(new INTF_StringMap('SVMXC__Contact__r.Phone', objWO.SVMXC__Contact__r.Phone));
                        valueMap.add(new INTF_StringMap('SVMXC__Contact__r.Email', objWO.SVMXC__Contact__r.Email));
                    }
                    wrpWO.key = objWO.Id;
                    wrpWO.valueMap = valueMap;
                    lstWorkOrderWrapper.add(wrpWO);
                }
                response.MapStringMap = lstWorkOrderWrapper;
            }
        }
        return response;
    }
    /* WebService to Get Events for the interface*/
    Webservice static INTF_Response_For_Events INTF_Get_Events_WS(INTF_Request_For_Events iPadReqEvent)
    {
        try
        {   
            return (new SVMXC.INTF_Get_Events()).INTF_Get_Events(iPadReqEvent) ;
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
    /* End of the WebService Get Events for interface*/
    
    /* WebService to Get Events for the interface*/
    Webservice static INTF_Response_For_Tasks INTF_Get_Tasks_WS(INTF_Request_For_Tasks iPadReqTask)
    {
        try
        {
            return (new SVMXC.INTF_Get_Tasks()).INTF_Get_Tasks(iPadReqTask) ;
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
    /* End of the WebService Get Events for interface*/
    

    
    /* WebService to get the lookup config data*/
    Webservice static INTF_LookUpConfigData INTF_getLookUpConfigWithData_WS(INTF_Request prequest)
    {
        SVMXC.INTF_getLookUpConfigWithData getLookupData = new SVMXC.INTF_getLookUpConfigWithData();
        return getLookupData.getLookUpConfigWithData(prequest);        
    }
    //------------------------------ Service definitions ---------------------------------------------//
    //webservice to convert sfmtarget to page data..
    webservice static INTF_PageData INTF_BuildPageData_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        return buildpagedata.INTF_buildPageData(request);
    }
    
       //webservice mathod which will caluculate TO Address With Source object WorkOrder
    webservice static INTF_PageData INTF_PORD_SelToAddressWO_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_PORDAddress Address = new SVMXC.INTF_PORDAddress();
        return Address.getSelToAddressWO(request);
    }
    //webservice mathod which will caluculate FROM Address With Source object WorkOrder
    webservice static INTF_PageData INTF_PORD_SelFromAddressWO_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_PORDAddress Address = new SVMXC.INTF_PORDAddress();
        return Address.getSelFromAddressWO(request);
    }
    //webservice mathod which will caluculate TO Address With Source object Case
    webservice static INTF_PageData INTF_PORD_SelToAddressCASE_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_PORDAddress Address = new SVMXC.INTF_PORDAddress();
        return Address.getSelToAddressCase(request);
    }
    //webservice mathod which will caluculate FROM Address With Source object Case
    webservice static INTF_PageData INTF_PORD_SelFromAddressCASE_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_PORDAddress Address = new SVMXC.INTF_PORDAddress();
        return Address.getSelFromAddressCase(request);
    }
    //webservice mathod which will caluculate TO Location
    webservice static INTF_PageData INTF_PORD_PopulateToLocation_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_PORDAddress Address = new SVMXC.INTF_PORDAddress();
        return Address.getPopulateToLocation(request); 
    }
    //webservice mathod which will caluculate From Location 
    webservice static INTF_PageData INTF_PORD_PopulateFromLocation_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_PORDAddress Address = new SVMXC.INTF_PORDAddress();
        return Address.getPopulateFromLocation(request);
    }
    //web service method which will calculate TO Location for RMA
    webservice static INTF_PageData INTF_PORD_PopulateToLocationRMA_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_PORDAddress Address = new SVMXC.INTF_PORDAddress();
        return Address.getPopulateToLocation_RMA(request);
    }
 
    //web service method which will calculate From Location for Shipment
    webservice static INTF_PageData INTF_PORD_PopulateFromLocationShipment_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_PORDAddress Address = new SVMXC.INTF_PORDAddress();
        return Address.getPopulateFromLocation_Shipment(request);
    }     
    //Webservice method for GetPrice for Parts Order Lines
    webservice static INTF_PageData INTF_PORD_GetPrice_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_getPrice getprice = new SVMXC.INTF_getPrice();
        return getprice.INTF_PORD_GetPrice(request);
    }
    //Webservice method for GetPrice for Parts Request Lines
    webservice static INTF_PageData INTF_PREQ_GetPrice_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_getPrice getprice = new SVMXC.INTF_getPrice();
        return getprice.INTF_PREQ_GetPrice(request);
    }
    //Webservice method for GetPrice for Work Detail's Request
    webservice static INTF_PageData INTF_WORD_REQ_GetPrice_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_getPrice getprice = new SVMXC.INTF_getPrice();
        return getprice.INTF_WORD_REQ_GetPrice(request);
    }
    //Webservice method for GetPrice for Work Detail's Usage
    webservice static INTF_PageData INTF_WORD_USG_GetPrice_WS(INTF_TargetRecord request)
    {
        system.debug('INTF_WORD_USG_GetPrice_WS' + request);
        SVMXC.INTF_getPrice getprice = new SVMXC.INTF_getPrice();
        return getprice.INTF_WORD_USG_GetPrice(request);
    }
    //Webservice method for GetPrice for Work Detail's Estimate
    webservice static INTF_PageData INTF_WORD_EST_GetPrice_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_getPrice getprice = new SVMXC.INTF_getPrice();
        return getprice.INTF_WORD_EST_GetPrice(request);
    }
    //Webservice method for GetPrice for Stock Transfer lines
    webservice static INTF_PageData INTF_SXFR_GetPrice_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_getPrice getprice = new SVMXC.INTF_getPrice();
        return getprice.INTF_SXFR_GetPrice(request);
    }
    
    //Webservice method for Tiered Pricing added by Nidhi as part of BAC_5389
    webservice static INTF_PageData getTieredPricing(INTF_TargetRecord request)
    {
        INTF_WebServicesDef.INTF_PageData PageData = new INTF_WebServicesDef.INTF_PageData();
        //Call SVMX_TieredPriceEngine
        return PageData;
    }
    //Webservice method for Tiered Pricing added by Nidhi as part of BAC_5389
    webservice static INTF_PageData saveTieredPricing(INTF_TargetRecord request)
    {
        INTF_WebServicesDef.INTF_PageData PageData = new INTF_WebServicesDef.INTF_PageData();
        //Save the Tier Usages records
        return PageData;
    }
    //Webservice method for Tiered Pricing added by Nidhi as part of BAC_5389
    webservice static INTF_PageData CreateContractWithTieredPricing(INTF_TargetRecord request)
    {
        INTF_WebServicesDef.INTF_PageData PageData = new INTF_WebServicesDef.INTF_PageData();
        //Migrate tiered pricing details from service plan to service contract.
        return PageData;
    }
    
    //Webservice method to populate Name field from Serial number for IB
    webservice static INTF_PageData INTF_IB_PopulateName_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_IB_PopulateName PN = new SVMXC.INTF_IB_PopulateName();
        return PN.populateName(request);
    }
    //Webservice method to set field  SVMXC__Is_Billable__c true for Process Create Usage for workorder
    webservice static INTF_PageData INTF_WO_SetIsBillable_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_WO_SetIsBillable SIB = new SVMXC.INTF_WO_SetIsBillable();
        return SIB.setIsBillable(request);
    }
    //Webservice method for Quote calculation (Field Events)
    webservice static INTF_PageData INTF_Quote_Calc_WS(INTF_TargetRecord request)
    {
        SVMXC.INTF_Quote_Calc QuoteCal = new SVMXC.INTF_Quote_Calc();
        return QuoteCal.QuoteCalculation(request); 
    }
  
    // iPad Bundle 2
    global class INTF_SFMRequest
    {
        webservice List<SVMXClient> clientInfo{get;set;}
        webservice String eventType{get;set;}
        webservice String eventName{get;set;}
        webservice String userId{get;set;}
        webservice String groupId{get;set;}
        webservice String profileId{get;set;}
        webservice String name{get;set;}
        webservice String value{get;set;}
        webservice List<String> values{get;set;}
        webservice List<SVMXMap> valueMap{get;set;}
        webservice List<SVMXError> errors{get;set;}
        webservice APL_Order aplOrder {get;set;}
    }
    
    global class INTF_SFMResponse
    {
        webservice Boolean success{get;set;}
        webservice String message{get;set;}
        webservice String messageType{get;set;}
        webservice String eventType{get;set;}
        webservice String eventName{get;set;}
        webservice String value{get;set;}
        webservice List<String> values{get;set;}
        webservice List<SVMXMap> valueMap{get;set;}
        webservice List<SVMXError> errors {get;set;}
        webservice APL_Order aplOrder {get;set;}
        webservice List<INTF_Response_PageUI> pageUI{get;set;}
        
        global INTF_SFMResponse()
        {
            values = new list<String>();
            valueMap = new list<SVMXMap>();
            errors = new list<SVMXError>(); 
        }
        
        global String serialize()
        {
            return JSON.serialize(this);
        }
    }
    
    global class SVMXMap
    {
        webservice String key{get;set;}
        webservice String value{get;set;}
        webservice list<String> values {get;set;}
        webservice List<SVMXMap> valueMap{get;set;}
        webservice List<sObject> data{get;set;}
        webservice sObject record{get;set;}
        webservice List<INTF_SFMRequest> lstInternal_Request{get;set;}
        webservice List<INTF_SFMResponse> lstInternal_Response{get;set;}
        global SVMXMap()
        {
            values = new list<String>();
            valueMap = new list<SVMXMap>();
        }
        global SVMXMap(String key, String value)
        {
            this.key = key;
            this.value = value;
            values = new list<String>();
            valueMap = new list<SVMXMap>();
        }
        global SVMXMap(String key, String value, List<String> values)
        {
            this.key = key;
            this.value = value;
            this.values = new List<String>();
            this.values = values;
            valueMap = new list<SVMXMap>();
        }
    }
    
    global class SVMXClient
    {
        webservice String clientType{get;set;}
        webservice List<String> clientInfo{get;set;}
    }
    
    global class SVMXError
    {
        webservice String uniqueId{get;set;}
        webservice String errorId{get;set;}
        webservice String errorTitle{get;set;}
        webservice String errorMsg{get;set;}
        webservice String errorType{get;set;}
        webservice String correctiveAction{get;set;}
    }
    //Advance Parts Logistic..
    //Wrapper Classes
    global class APL_SerialCollection
    {
        webservice String uniqueId{get;set;}
        webservice String serialNumber{get;set;}
        webservice String reconciliationAction{get;set;}
        webservice Integer availableCount{get;set;}
        webservice Integer allocatedCount{get;set;}
        webservice Boolean isExpected{get;set;}
        webservice Boolean isReceived{get;set;}
        webservice Boolean isPicked{get;set;}
        webservice Boolean isShipped{get;set;}
        webservice String stockSerialId{get;set;}
        webservice String productId{get;set;}
        webservice String locationName{get;set;}
        webservice Boolean isProductReplacement{get;set;}
       
        global APL_SerialCollection(){}
        global APL_SerialCollection(String serialNumber, Boolean isExpected, Boolean isReceived, Boolean isPicked){
        this.serialNumber = serialNumber;
        this.isExpected = isExpected;
        this.isReceived = isReceived;
        this.isPicked = isPicked;
        }
    }
    
    global class APL_OrderLineCollection
    {
        webservice list<APL_SerialCollection> serialNumbers = new list<APL_SerialCollection>();
        webservice SVMXC__RMA_Shipment_Line__c orderLineRecord = new SVMXC__RMA_Shipment_Line__c();
        webservice String uniqueIdForClient{get;set;}
        webservice String clonedFromId{get;set;}
        webservice String sourceLocationPSID{get;set;} 
        webservice String targetLocationPSID{get;set;}
        webservice String reconciliationAction{get;set;}
        webservice Boolean isProductStockable {get;set;}
        webservice Boolean isEnableSerializedTracking{get;set;}
        webservice SVMXC__Product_Serial__c serialNumberRecord = new SVMXC__Product_Serial__c();
        global APL_OrderLineCollection(){}
        global APL_OrderLineCollection(SVMXC__RMA_Shipment_Line__c orderLineRecord, list<APL_SerialCollection> serialNumbers){
            this.orderLineRecord = orderLineRecord;
            this.serialNumbers = serialNumbers;         
        }
    }
    
    global class APL_Order
    {
        webservice SVMXC__RMA_Shipment_Order__c orderHdrRecord = new SVMXC__RMA_Shipment_Order__c();
        webservice list<APL_OrderLineCollection> orderLines = new list<APL_OrderLineCollection>();
        webservice SVMXC__ServiceMax_Processes__c svmxProcess = new SVMXC__ServiceMax_Processes__c();
        webservice list<SVMXC__ServiceMax_Config_Data__c> configData = new list<SVMXC__ServiceMax_Config_Data__c>();
        webservice String processType{get;set;}
        global APL_Order(){}
    }
    
    //Webservice Methods...
    //This webservice method will return the APL_Order.
    webservice static INTF_SFMResponse INTF_APL_GetOrder_WS(INTF_SFMRequest request)
    {
        system.debug('Start: '+system.now()+request.valueMap);
        INTF_SFMResponse response = new INTF_SFMResponse();
        try
        {
            String strProcessType;
            list<SVMXMap> lstSVMXMap = new list<SVMXMap>();
            lstSVMXMap = request.valueMap;
            if(lstSVMXMap.size() > 0)
            {
                for(Integer i = 0;i<lstSVMXMap.size();i++)
                {
                    if(lstSVMXMap[i].key.touppercase() == 'SVMX_PROCESSTYPE')
                        strProcessType = lstSVMXMap[i].value;       
                }
            }
            if(strProcessType == 'FULFILLMENTPROCESS')
            {
                APL_FulfillmentConsole getOrderDetails = new APL_FulfillmentConsole();
                response = getOrderDetails.getAPLFulfillmentOrder(request);
            }
            else if(strProcessType == 'PROCESSRECEIPT' || strProcessType == 'DELIVERYONRECEIPT' || strProcessType == 'PICKNMOVE' || strProcessType == 'SHIPCONFIRM')
            {
                APL_OrderUtils getOrderDetails = new APL_OrderUtils();
                response = getOrderDetails.getAPLOrder(request);
            }
            system.debug('End: '+system.now());
            return response;
        }
        catch(exception ex)
        {
            response.success = false;
            response.message = ex.getMessage();
            system.debug('End: '+system.now());
            return response;
        }  
         
    }
    //This Webservce method will split the APL Lines 
    webservice static SVMXC.INTF_WebServicesDef.INTF_SFMResponse APL_PreSaveUpdates_WS(INTF_SFMRequest request)
    {
       // APL_OrderUtils PreSaveUpdates = new APL_OrderUtils();
        //return PreSaveUpdates.APL_PreSaveUpdates(request);
        return null;
    }
    //This webservice method will save APL_Order.
    webservice static INTF_SFMResponse INTF_APL_SaveOrder_WS(INTF_SFMRequest request)
    {
        system.debug('request' + request);
        APL_OrderUtils saveOrder = new APL_OrderUtils();
        return saveOrder.SaveAPLOrder(request);
        //return null;
    }
    //This webservice method will return available Stocked Serials for given Product,Location
    webservice static INTF_SFMResponse INTF_APL_GetAvailableStockSerial_WS(INTF_SFMRequest request)
    {
        APL_Utils utils = new APL_Utils();
        return utils.getAvailableStockSerial(request);
    }
    //This webservice method will create Internal/External RMAs for ShipConfirm
    webservice static INTF_SFMResponse INTF_APL_CreateInternalExternalRMA_WS(INTF_SFMRequest request)
    {
        APL_Utils utils = new APL_Utils();
        return utils.CreateInternalExternalRMA(request);
    }
    //PartsOrderClosure
    webservice static INTF_SFMResponse INTF_APL_PartsOrderClosure_WS(INTF_SFMRequest request)
    {
        APL_Utils utils = new APL_Utils();
        return utils.PartsOrderClosure(request);
    }
   /*Initiate Return Calls*/
    webservice static INTF_SFMResponse INTF_APL_GetIntiateReturnProc_WS(INTF_SFMRequest reqForInitateReturnChk)
    {
        APL_InitiateReturn objInitiateReturn = new APL_InitiateReturn();        
        return objInitiateReturn.APL_GetIntiateReturnProc(reqForInitateReturnChk); 
    }
    webservice static INTF_SFMResponse INTF_APL_PerformEntitlement_WS(INTF_SFMRequest reqForInitateReturnChk)
    {
        APL_InitiateReturn objInitiateReturn = new APL_InitiateReturn();        
        return objInitiateReturn.APL_PerformEntitlementCheck(reqForInitateReturnChk); 
    }
    
    //This service is no longer exist, logic to get all case details has been moved in INTF_APL_GetCaseInfo_WS service.
    webservice static INTF_SFMResponse INTF_APL_GetAccountAndProductInfo_WS(INTF_SFMRequest reqToGetAccProInfo)
    {
        APL_RoutingEngine objAccProInfo = new APL_RoutingEngine();        
        return objAccProInfo.APL_GetAccountAndProductInfo(reqToGetAccProInfo);
    }
    
    //Service get the Accounts, Products, Case and Case Line details.
    webservice static INTF_SFMResponse INTF_APL_GetCaseInfo_WS(INTF_SFMRequest reqToGetAccProInfo)
    {
        APL_RoutingEngine objAccProInfo = new APL_RoutingEngine();        
        return objAccProInfo.APL_GetCaseInfo(reqToGetAccProInfo);
    }
    
    //Service get the Route Calculation related to the Case and Case Line
    webservice static INTF_SFMResponse INTF_APL_GetRouteInfo_WS(INTF_SFMRequest reqToGetRouteInfo)
    {
        APL_RoutingEngine objAccProInfo = new APL_RoutingEngine();        
        return objAccProInfo.APL_GetRouteInfo(reqToGetRouteInfo); 
    }
    //Service get the Route Calculation related to the Case and Case Line
    webservice static INTF_SFMResponse INTF_APL_CreateRouteForCase_WS(INTF_SFMRequest reqToCrRouteInfo)
    {
        APL_RoutingEngine objAccProInfo = new APL_RoutingEngine();        
        return objAccProInfo.APL_UpdateRouteCardAndCaseLine(reqToCrRouteInfo); 
    }    
     //Service get the Locations and there CaseLines
    webservice static INTF_SFMResponse INTF_APL_CalculateRMAForCase_WS(INTF_SFMRequest reqToGetLocInfo)
    {
        APL_RMAUtils objRMAInfo = new APL_RMAUtils(); 
        return objRMAInfo.APL_CalculateRMAFromCase(reqToGetLocInfo); 
    }
     //Service to generate the RMA and RMA lines
    webservice static INTF_SFMResponse INTF_APL_GenerateRMAforCase_WS(INTF_SFMRequest reqToCreateRMA)
    {
        APL_RMAUtils objRMAInfo = new APL_RMAUtils();
        return objRMAInfo.APL_GenerateRMADoc(reqToCreateRMA); 
    }
     //Service to DO Source Updates for case and case line
    webservice static INTF_SFMResponse INTF_APL_DoReturnSourceUpdates_WS(INTF_SFMRequest reqToSourceUpdatesForRet)
    {
        APL_InitiateReturn objSouUpdateInfo = new APL_InitiateReturn();        
        return objSouUpdateInfo.DoReturnSourceUpdates(reqToSourceUpdatesForRet); 
    }
    
    //Service to Do CUD Property Elements(Create,Update,Delete)
    webservice static INTF_SFMResponse INTF_CUD_OnPropertyElements_WS(INTF_SFMRequest reqForPropertyElements,String action)
    {
       COMM_Utils cuForCUDPropetyElements = new COMM_Utils();
       return cuForCUDPropetyElements.SVMX_CUD_OnPropertyElements(reqForPropertyElements, action); 
    }
    
    webservice static INTF_SFMResponse INTF_APL_Do_Forward_Shipment_WS(INTF_SFMRequest reqForFWShipment)
    { 
        INTF_WebServicesDef.INTF_SFMResponse objRespRouteResult = new INTF_WebServicesDef.INTF_SFMResponse();
        try
        {
            String strLocation = null;
            objRespRouteResult.success = true;
            for(INTF_WebServicesDef.SVMXMap objTemp : reqForFWShipment.valueMap)
            {
                if(objTemp.key == 'Location')
                {
                    strLocation = objTemp.value;
                    break;
                }
            }
            String strFSPRecId = [Select Id, Name from RecordType where Name = 'Forward Shipment Process' AND SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1].Id;   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__ServiceMax_Processes__c> lstAllScheduleFrFwdShpProc = [Select id from SVMXC__ServiceMax_Processes__c where SVMXC__Location__c =: strLocation and RecordTypeId=:strFSPRecId limit 1];
            if(lstAllScheduleFrFwdShpProc != null && lstAllScheduleFrFwdShpProc.size() > 0)
            {   
                //APL_ForwardShipmentEngine.processForwardShipmentFor(strLocation,lstAllScheduleFrFwdShpProc[0].id);
                List<SVMXC__ServiceMax_Config_Data__c> lstAllScheduleConfDataFrFwdShpProc = new List<SVMXC__ServiceMax_Config_Data__c>();
                lstAllScheduleConfDataFrFwdShpProc = [Select id, SVMXC__Run_At__c, SVMXC__Schedule_Days__c, SVMXC__Dispatch_Process__c,SVMXC__Dispatch_Process__r.SVMXC__Location__c, SVMXC__Dispatch_Process__r.SVMXC__Module__c,SVMXC__Dispatch_Process__r.SVMXC__Node_Parent__c, SVMXC__Dispatch_Process__r.SVMXC__Start_Date__c, SVMXC__Dispatch_Process__r.SVMXC__End_Date__c, SVMXC__Dispatch_Process__r.SVMXC__Email_On_Success__c, SVMXC__Dispatch_Process__r.SVMXC__Email_On_Error__c, SVMXC__Dispatch_Process__r.SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Schedule' and SVMXC__Dispatch_Process__c != null and SVMXC__Dispatch_Process__r.SVMXC__Location__c =: strLocation];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                integer intCount = 0;
                //Get all the process that need to run now
                for(SVMXC__ServiceMax_Config_Data__c currentSch : lstAllScheduleConfDataFrFwdShpProc)
                {
                    if(strLocation != null)
                    {
                      if(intCount > 9) // now schedule for the remaining locations
                      {
                        //send the error email from the setting that there are more than 10 locations that are configured
                        break;
                      }              
                      SVMXC.APL_ForwardShipmentEngine.processForwardShipmentFor(strLocation,currentSch.id);        
                      intCount++;
                    }          
                }
            }else
            {
                 objRespRouteResult.success = false;
                objRespRouteResult.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', system.label.APL004_TAG010 + strLocation));
            }           
        }catch(Exception ex)
        {
            objRespRouteResult.success = false;
            objRespRouteResult.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ex.getMessage()));
        }
        return objRespRouteResult;
    }
    /*End of Inititate Return Calls */
    
    
    /*** search delivery Calls start ****/
    //Neeraj(Dec-20th): Calls for search definition
    webservice static INTF_Response SFM_GetSearchInfo_WS(INTF_SFMRequest Req)
    {

        SFM_SearchUtils SearchUtilsObj = new SFM_SearchUtils();
        return SearchUtilsObj.INTF_getSearchInfo(Req);
    }
    //Neeraj(Dec-20th): Calls for search data
    webservice static INTF_Response SFM_GetSearchResult_WS(INTF_SFMRequest Req)
    {
        SFM_SearchUtils SearchUtilsObj = new SFM_SearchUtils();
        return SearchUtilsObj.INTF_getSearchInfoWithData(Req);
        
    }  
    
    /*****End of search delivery Calls *****/
    webservice static INTF_SFMResponse INTF_APL_PerformEntitlement_On_PD(INTF_SFMRequest reqForEnti)
    {
        APL_Entitlement objEntiOnPB = new APL_Entitlement();        
        return objEntiOnPB.APL_PerformEntitlement_PD(reqForEnti); 
    }
    
    // Metadata Synchronization – Web Service Implementation
    webservice static INTF_SFMResponse INTF_MetaSync_WS(INTF_SFMRequest request)
    {
        INTF_SFMResponse response = new INTF_SFMResponse(); 
        INTF_DataSync objInstance;   
        try
        {  
            string svmxGrpProfileId = (new INTF_ConfigSync()).getSVMXGrpProfileId(null);        
            INTF_DataSync.getLogSettings(svmxGrpProfileId, request);
            objInstance = INTF_DataSync.getInstance();
            objInstance.ct = 'ms';
            objInstance.srid = request.value;
            datetime dt = system.now();
            system.debug(loggingLevel.WARN, 'Event Name: ' + request.eventName + ' :: ' + request.eventType);
        
            //Sync Logging Performance
            INTF_SyncLogCapture.initiateLogging(request);
        
            if(request.eventName == 'ONE_CALL_SYNC' && request.eventType == 'META_SYNC'){
                INTF_DataSync.logEventStartTS('ONE_CALL_SYNC-META_SYNC');
                INTF_ConfigSync onceCallMetaSync = new INTF_ConfigSync();
                response = onceCallMetaSync.OneCallMetaSync(request);
                INTF_DataSync.updateMethodList();
                INTF_DataSync.logEventEndTS('ONE_CALL_SYNC-META_SYNC');
            }
            else if(request.eventName == 'OBJECT_DEFINITION' && request.eventType == 'META_SYNC'){
                INTF_DataSync.logEventStartTS('OBJECT_DEFINITION');   
                INTF_ConfigSync onceCallMetaSync = new INTF_ConfigSync();               
                response = onceCallMetaSync.getObjectDef(request);
                INTF_DataSync.updateMethodList();
                INTF_DataSync.logEventEndTS('OBJECT_DEFINITION');
            }
            else if(request.eventName == 'SFM_PAGEDATA' && request.eventType == 'META_SYNC'){
                INTF_DataSync.logEventStartTS('SFM_PAGEDATA');
                INTF_ConfigSync onceCallMetaSync = new INTF_ConfigSync();
                response = onceCallMetaSync.getPageLayouts(request);
                INTF_DataSync.updateMethodList();
                INTF_DataSync.logEventEndTS('SFM_PAGEDATA');
            }
            else if(request.eventName == 'RECORD_TYPE' && request.eventType == 'META_SYNC'){
                INTF_DataSync.logEventStartTS('RECORD_TYPE');                
                INTF_ConfigSync onceCallMetaSync = new INTF_ConfigSync();
                response = onceCallMetaSync.getRecordType(request);  
                INTF_DataSync.updateMethodList();             
                INTF_DataSync.logEventEndTS('RECORD_TYPE');
            }
            else if(request.eventName == 'FSA_TAGS' && request.eventType == 'META_SYNC'){
                INTF_DataSync.logEventStartTS('FSA_TAGS');   
                INTF_ConfigSync onceCallMetaSync = new INTF_ConfigSync();
                response = onceCallMetaSync.getFsaTags(request);
                INTF_DataSync.updateMethodList();
                INTF_DataSync.logEventEndTS('FSA_TAGS'); 
            }
            else if(request.eventName == 'MOBILE_INVENTORY_CONFIG' && request.eventType == 'META_SYNC'){        
                INTF_DataSync.logEventStartTS('MOBILE_INVENTORY_CONFIG');           
                INTF_ConfigSync onceCallMetaSync = new INTF_ConfigSync();       
                response = onceCallMetaSync.getMobileInventoryConfig(request,svmxGrpProfileId);     
                INTF_DataSync.updateMethodList();       
                INTF_DataSync.logEventEndTS('MOBILE_INVENTORY_CONFIG');         
            }             
            else
            {
                system.debug(LoggingLevel.WARN, ' From WebservicesDef class Community ID is '+Network.getNetworkId());
                INTF_DataSync.logEventStartTS(request.eventName);
                response = (new INTF_ServiceEventUtility()).eventController(request);
                INTF_DataSync.updateMethodList();
                INTF_DataSync.logEventEndTS(request.eventName);
            }
            
            system.debug(loggingLevel.WARN, 'Total time Taken: ' + (system.now().gettime() - dt.getTime()));
            
            INTF_SyncLogCapture.finishLogging(true);
        }
        catch(exception ex)
        {
            system.debug(loggingLevel.WARN, 'Exception is ' + ex.getMessage());
            INTF_SyncLogCapture.finishLogging(false);
            response.success = false;
            response.message = ex.getMessage();
        }
        if(INTF_DataSync.performanceLogsEnabled){
            objInstance = INTF_DataSync.getInstance();
            INTF_DataSync.updateEventList();
            system.debug(LoggingLevel.WARN, '************* Json structure is '+Json.serialize(objInstance, true));
            system.debug(LoggingLevel.WARN, '**** Size of JSON = '+Json.serialize(objInstance, true).length() + '; Heap Size before NULL = '  + Limits.getHeapSize());
            if(objInstance.events != NULL && objInstance.events.size() > 0){ 
                INTF_DataSync.sendLogsToAWS(Json.serialize(objInstance, true), INTF_DataSync.endpointUrl);
            }
            objInstance.events.clear();
            objInstance = NULL;
            system.debug(LoggingLevel.WARN, 'Heap Size AFTER = '  + Limits.getHeapSize());
        }
        return INTF_SyncLogCapture.updateResponseWithLoggingInfo(response);
    }
    
    // Metadata Synchronization – Web Service Implementation
    webservice static INTF_SFMResponse INTF_DataSync_WS(INTF_SFMRequest request)
    {

        dateTime startTime = system.now();
        system.debug(loggingLevel.WARN, '==Start Time for Event Name: ' + request.eventName + ' :Is: ' + system.now() + ' ==Request No.=== ' + request.userId);
        
        if(request.eventName == 'MASTER_SYNC_LOG' && request.eventType == 'SYNC')
            return INTF_SyncLogCapture.createMaster(request);
        
        if(request.eventName == 'SYNC_TIME_LOG' && request.eventType == 'SYNC')
            return INTF_SyncLogCapture.updateSyncTimeLogs(request);
        
        INTF_SFMResponse response = new INTF_SFMResponse();
        
        if(request.eventName != null && request.eventType != null)
            system.debug(LoggingLevel.WARN, 'Event Name = ' + request.eventName + '; Event Type = ' + request.eventType);
            
        if(request.eventName == 'MOBILE_CLIENT_LOGS' && request.eventType == 'SYNC')
        {
            response = (new INTF_ServiceEventUtility()).saveClientLogs(request);
        }
        else
        {   
            boolean isSharingEnabled = false;
            String svmxGrpProfileId;
            try
            {
                svmxGrpProfileId = (new INTF_ConfigSync()).getSVMXGrpProfileId(null);
            }
            catch(Exception ex)
            {
                system.debug(loggingLevel.WARN, 'Exception is ' + ex.getMessage());
                INTF_SyncLogCapture.finishLogging(false);
                response.success = false;
                response.message = ex.getMessage();            
            }
            //Performance Logs
            INTF_DataSync.getLogSettings(svmxGrpProfileId, request);
            INTF_DataSync objInstance = INTF_DataSync.getInstance();
            objInstance.ct = 'ds';
            objInstance.srid = request.value;
            
            List<SVMXC__ServiceMax_Config_Data__c> lst = (new INTF_ConfigSync()).getSettings(null,null,new set<string>{'IPAD018_SET014'},svmxGrpProfileId);
            if(lst != null && lst.size() != 0 && lst.size() == 1)
                isSharingEnabled = boolean.valueOf(lst[0].SVMXC__Internal_Value__c);
        
            system.debug(loggingLevel.WARN, '=Setting Value: ' + isSharingEnabled + 'Group Profile = ' + svmxGrpProfileId);
            if(isSharingEnabled)
            {
                response = (new INTF_DataSync()).dataSync(request, svmxGrpProfileId);
            }
            else
            {
                    
                if(request.eventName == 'TARGETED_SYNC' && request.eventType == 'SYNC')
                {
                    response = (new SFMTransactionSync()).targetedSync(request);
                }
                else if(request.eventName == 'EVENT_RECORDS' && request.eventType == 'PURGING')
                {
                  response = (new INTF_DataUtilityServices()).purgeEvents(request); 
                }
                else if(request.eventName == 'PURGE_RECORDS' && request.eventType == 'PURGING')
                {
                    response = (new INTF_DataUtilityServices()).getRecordsForPurging(request, svmxGrpProfileId); 
                }
                else if(request.eventName == 'TECH_LOCATION_UPDATE' && request.eventType == 'SYNC')
                {
                    response = (new INTF_DataUtilityServices()).updateTechLocation(request); 
                }
                else if(request.eventName == 'LOCATION_HISTORY' && request.eventType == 'SYNC')
                {
                    response = (new INTF_DataUtilityServices()).updateTechLocHistory(request); 
                }
                else if(request.eventName == 'DATA_ON_DEMAND' && request.eventType == 'GET_DATA')
                { 
                    response = (new INTF_DataUtilityServices()).downloadOnDemand(request, svmxGrpProfileId); 
                }
                else if(request.eventName == 'PUSH_NOTIFICATION' && request.eventType == 'GET_DATA')
                { 
                    response = (new INTF_DataUtilityServices()).getPushNotificationData(request); 
                }
                else 
                {
                    //Sync Logging Performance
                    if(!((request.eventName == 'GENERATE_PDF' || request.eventName == 'SUBMIT_DOCUMENT' || request.eventName == 'SUBMIT_DOCUMENT_FILES' || request.eventName == 'GENERATE_PDF_FILES' || request.eventName == 'SYNC_PRODUCTIQ_DATA') && request.eventType == 'SYNC'))
                        INTF_SyncLogCapture.initiateLogging(request);
                    try
                    {
                        if(request.eventName == 'ONE_CALL_SYNC' && request.eventType == 'SYNC')
                        {
                            INTF_DataSync.logEventStartTS('ONE_CALL_SYNC');
                            response = (new INTF_TxnCache()).oneCallSync(request);
                            INTF_DataSync.updateMethodList();
                            INTF_DataSync.logEventEndTS('ONE_CALL_SYNC');
                        }
                        else if(request.eventName == 'EVENT_SYNC' && request.eventType == 'SYNC')
                        {
                            INTF_DataSync.logEventStartTS('EVENT_SYNC');
                            response = (new INTF_DataUtilityServices()).RequestDataFromBase(request);
                            INTF_DataSync.updateMethodList();
                            INTF_DataSync.logEventEndTS('EVENT_SYNC');
                        }
                        else if(request.eventName == 'PUT_INSERT' && request.eventType == 'SYNC')
                        {
                          response = (new INTF_DataUtilityServices()).InsertClientDataIntoBase(request);
                        }
                        else if(request.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                        {
                            INTF_DataSync.logEventStartTS('DOWNLOAD_CREITERIA_SYNC');
                            response = (new INTF_TxnCache()).getDownloadCriteriaRecords(request);
                            INTF_DataSync.updateMethodList();
                            INTF_DataSync.logEventEndTS('DOWNLOAD_CREITERIA_SYNC');
                        }
                        else if(request.eventName == 'GET_INSERT_DOWNLOAD_CRITERIA' || request.eventName == 'GET_UPDATE_DOWNLOAD_CRITERIA' || request.eventName == 'GET_DELETE_DOWNLOAD_CRITERIA')
                        {
                            response = (new INTF_DataUtilityServices()).RequestForCriteriaRecords(request);
                        }
                        else if(request.eventName == 'PUT_UPDATE' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_DataUtilityServices()).UpdateClientDataIntoBase(request);
                        }
                        else if(request.eventName == 'PUT_DELETE' && request.eventType == 'SYNC')
                        {
                          response = (new INTF_DataUtilityServices()).SendClientDeletesToBase(request);
                        }
                        else if(request.eventName == 'TX_FETCH' && request.eventType == 'SYNC')
                        {
                            INTF_DataSync.logEventStartTS('TX_FETCH');
                            try
                            {
                                response = (new INTF_DataUtilityServices()).getRecordsForIds(request);
                            }
                            catch(Exception ex)
                            {
                                INTF_DataSync.updateMethodList();
                                INTF_DataSync.logEventEndTS('TX_FETCH');
                                INTF_SyncLogCapture.finishLogging(false);
                                response.success = false;
                                response.message = ex.getMessage();
                                throw ex;
                            }
                            INTF_DataSync.updateMethodList();
                            INTF_DataSync.logEventEndTS('TX_FETCH');
                        }
                        else if(request.eventName == 'GET_INSERT' || request.eventName == 'GET_UPDATE' || request.eventName == 'GET_DELETE')
                        {
                            response = (new INTF_DataUtilityServices()).RequestIncrementaldataFromBase(request);
                        }
                        else if(request.eventName == 'CLEAN_UP' || request.eventName == 'CLEAN_UP_SELECT')
                        {
                          response = (new INTF_DataUtilityServices()).RequestIdCleanUp(request); 
                        }
                        else if(request.eventName == 'SFM_SEARCH' && request.eventType == 'SEARCH_RESULTS')
                        {
                            response = (new INTF_DataUtilityServices()).getSearchResults(request); 
                        }
                        else if(request.eventName == 'PRICE_CALC_DATA' && request.eventType == 'SYNC')
                        {
                            INTF_DataSync.logEventStartTS('PRICE_CALC_DATA');                            
                            response = (new INTF_DataUtilityServices()).getPricingDefinitions(request); 
                            INTF_DataSync.updateMethodList();
                            INTF_DataSync.logEventEndTS('PRICE_CALC_DATA'); 
                        }
                        else if(request.eventName == 'DATA_ON_DEMAND' && request.eventType == 'GET_PRICE_INFO')
                        { 
                            response = (new INTF_DataUtilityServices()).getWOPriceInfo(request, svmxGrpProfileId); 
                        }
                        else if(request.eventName == 'USER_TRUNK' && request.eventType == 'SYNC')
                        { 
                            response = (new INTF_DataUtilityServices()).getTechnicianLocation(request); 
                        }
                        else if(request.eventName == 'ADV_DOWNLOAD_CRITERIA' && request.eventType == 'SYNC')
                        { 
                            INTF_DataSync.logEventStartTS('ADV_DOWNLOAD_CRITERIA');
                            response = (new INTF_DataUtilityServices()).getAdvanceDownloadCriteriaRecIds(request); 
                            INTF_DataSync.updateMethodList();
                            INTF_DataSync.logEventEndTS('ADV_DOWNLOAD_CRITERIA'); 
                        }
                        else if(request.eventName == 'SUBMIT_DOCUMENT' && request.eventType == 'SYNC')
                        {
                            INTF_DataSync.logEventStartTS('SUBMIT_DOCUMENT');
                            response = (new INTF_DataUtilityServices()).submitDocument(request);
                            INTF_DataSync.updateMethodList();
                            INTF_DataSync.logEventEndTS('SUBMIT_DOCUMENT');
                        }
                        else if(request.eventName == 'GENERATE_PDF' && request.eventType == 'SYNC')
                        {
                            INTF_DataSync.logEventStartTS('GENERATE_PDF');
                            response = (new INTF_DataUtilityServices()).generatePdf(request);
                            INTF_DataSync.updateMethodList();
                            INTF_DataSync.logEventEndTS('GENERATE_PDF');
                        }
                        else if(request.eventName == 'TX_FETCH_OPTIMZED' && request.eventType == 'SYNC')
                        {
                            INTF_TxnCache.restore(request.value);
                            response = (new INTF_TxnCache()).getRecordsForIds(request);
                        }
                        else if(request.eventName == 'SYNC_DOWNLOAD_CRITERIA' && request.eventType == 'SYNC')
                        {
                            INTF_DataSync.logEventStartTS('SYNC_DOWNLOAD_CRITERIA');
                            response = (new INTF_DataUtilityServices()).getDownloadCriteriaRecordIds(request);
                            INTF_DataSync.updateMethodList();
                            INTF_DataSync.logEventEndTS('SYNC_DOWNLOAD_CRITERIA');
                        }
                        else if(request.eventName == 'SYNC_PRODUCTIQ_DATA' && request.eventType == 'SYNC')
                        {
                            INTF_DataSync.logEventStartTS('SYNC_PRODUCTIQ_DATA');
                            response = (new INTF_TxnCache()).getProductIQData(request, svmxGrpProfileId);
                            INTF_DataSync.updateMethodList();
                            INTF_DataSync.logEventEndTS('SYNC_PRODUCTIQ_DATA');
                        }
                        else if(request.eventName == 'SYNC_PRODUCTIQ_PRODUCT_ATTR' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_TxnCache()).getProductAttributesTemplates(request, svmxGrpProfileId);
                        }
                        else if(request.eventName == 'SYNC_PRODUCTIQ_IB_ATTR' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_TxnCache()).getIBAttrTemplHistory(request, svmxGrpProfileId);
                        }
                        else if(request.eventName == 'GET_DELETE_PRODUCTIQ_DATA' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_TxnCache()).getDeletedProductIQData(request, svmxGrpProfileId);
                        }
                        else if(request.eventName == 'GET_PIQ_PICKLIST_DEFINITION' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_TxnCache()).getDeltaPicklistDef(request, svmxGrpProfileId);
                        }
                        else if(request.eventName == 'SYNC_CHECKLIST_DATA' && request.eventType == 'SYNC')
                        {
                            INTF_DataSync.logEventStartTS('SYNC_CHECKLIST_DATA');
                            response = (new INTF_TxnCache()).getChecklistData(request, svmxGrpProfileId);
                            INTF_DataSync.updateMethodList();
                            INTF_DataSync.logEventEndTS('SYNC_CHECKLIST_DATA');
                        }
                        else if(request.eventName == 'SYNC_PIQ_ATTACHMENTS' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_TxnCache()).getAttachments(request, svmxGrpProfileId);
                        }
                        else if(request.eventName == 'SYNC_PRODUCT_TEMPLATES' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_TxnCache()).getPIQAttributesTemplates(request, svmxGrpProfileId);
                        }
                        else if(request.eventName == 'TRUNK_STOCK' && request.eventType == 'SYNC')
                        {
                            INTF_DataSync.logEventStartTS('TRUNK_STOCK');                         
                            response = (new INTF_TxnCache()).getTrunkStock(request, svmxGrpProfileId);
                            INTF_DataSync.updateMethodList();                            
                            INTF_DataSync.logEventEndTS('TRUNK_STOCK');   
                        }
                        else if(request.eventName == 'CATALOG_SEARCH' && request.eventType == 'SYNC')
                        {                        
                            response = (new INTF_TxnCache()).getProducts(request);
                        }                          
                        else if(request.eventName == 'LOCATE_PART' && request.eventType == 'SYNC')
                        {               
                            response = (new INVT_Inventory_Utils()).locatePart(request,svmxGrpProfileId);
                        }
                        else if(request.eventName == 'TECHNICIAN_SEARCH' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_TxnCache()).getTechnician(request);
                        } 
                        else if(request.eventName == 'STOCK_TRANSFER' && request.eventType == 'SYNC')
                        {
                            response = (new INVT_Inventory_Utils()).getStockTransferWrapper(request,svmxGrpProfileId);
                        }
                        else if(request.eventName == 'SYNC_SALESFORCE_FILES' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_SFDCFilesUtilityServices()).createSalesforceFiles(request);
                        }
                        else if(request.eventName == 'DOWNLOAD_EVENT_FILES' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_SFDCFilesUtilityServices()).getEventRelatedFiles(request, svmxGrpProfileId);
                        }
                        else if(request.eventName == 'SYNC_PIQ_FILES' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_SFDCFilesUtilityServices()).getProductIQFiles(request, svmxGrpProfileId);
                        }
                        else if(request.eventName == 'SUBMIT_DOCUMENT_FILES' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_SFDCFilesUtilityServices()).submitDocumentForFiles(request);
                        }
                        else if(request.eventName == 'GENERATE_PDF_FILES' && request.eventType == 'SYNC')
                        {
                            response = (new INTF_SFDCFilesUtilityServices()).generatePdfForFiles(request, svmxGrpProfileId);
                        }
                        if(!((request.eventName == 'GENERATE_PDF' || request.eventName == 'SUBMIT_DOCUMENT' || request.eventName == 'SUBMIT_DOCUMENT_FILES' || request.eventName == 'GENERATE_PDF_FILES' || request.eventName == 'SYNC_PRODUCTIQ_DATA') && request.eventType == 'SYNC'))
                            INTF_SyncLogCapture.finishLogging(true);
                    }
                    catch(exception ex)
                    {
                        system.debug(loggingLevel.WARN, 'Exception is ' + ex);
                        if(!((request.eventName == 'GENERATE_PDF' || request.eventName == 'SUBMIT_DOCUMENT' || request.eventName == 'SUBMIT_DOCUMENT_FILES' || request.eventName == 'GENERATE_PDF_FILES' || request.eventName == 'SYNC_PRODUCTIQ_DATA') && request.eventType == 'SYNC'))
                            INTF_SyncLogCapture.finishLogging(false);
                        response.success = false;
                        response.message = ex.getMessage();
                    }
                }
            }
            if(INTF_DataSync.performanceLogsEnabled){
                objInstance = INTF_DataSync.getInstance();
                INTF_DataSync.updateEventList();
                system.debug(LoggingLevel.WARN, '************* Json structure is '+Json.serialize(objInstance, true));
                system.debug(LoggingLevel.WARN, '**** Size of JSON = '+Json.serialize(objInstance, true).length() + '; Heap Size before NULL = '  + Limits.getHeapSize());
                if(objInstance.events != NULL && objInstance.events.size() > 0){ 
                    INTF_DataSync.sendLogsToAWS(Json.serialize(objInstance, true), INTF_DataSync.endpointUrl);
                }
                objInstance.events.clear();
                objInstance = NULL;
                system.debug(LoggingLevel.WARN, 'Heap Size AFTER = '  + Limits.getHeapSize());
            }
        }
        
        system.debug(loggingLevel.WARN, '==End Time for Event Name: ' + request.eventName + ' :Is: ' + system.now() + ' :time Taken: ' + (system.now().getTime() - startTime.getTime()) + ' ==Request No.=== ' + request.userId);
        
        if((request.eventName == 'GENERATE_PDF' || request.eventName == 'SUBMIT_DOCUMENT' || request.eventName == 'SUBMIT_DOCUMENT_FILES' || request.eventName == 'GENERATE_PDF_FILES' || request.eventName == 'SYNC_PRODUCTIQ_DATA') && request.eventType == 'SYNC')
            return response;
        else    
            return INTF_SyncLogCapture.updateResponseWithLoggingInfo(response);
    }
    
    webservice static SFM_WrapperDef.SFM_Response lookupSearchResults(SFM_WrapperDef.SFM_Request request)
    {
        system.debug(loggingLevel.WARN, 'Request for lookupSearchResults is ' + request);
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        response = (new SFM_ExecuteLookup()).executeLookup(request);
        system.debug(loggingLevel.WARN, 'Response for lookupSearchResults is ' + response);
        return response;
    }
    
    webservice static INTF_Response SVMX_RetrieveSettings_WS(INTF_Request request)
    {
        String strSubmoduleId = '';
        map<String,String> mapSettings = new map<String,String>();
        INTF_Response response = new INTF_Response();
        if(request != null && request.stringMap != null && request.stringMap.size() > 0)
        {
            for(Integer i = 0;i<request.stringMap.size();i++)
            {
                if(request.stringMap[i].key.touppercase() == 'SUBMODULEID')
                    strSubmoduleId = request.stringMap[i].value;
            }
            if(strSubmoduleId != null && strSubmoduleId.length() > 0)
            {
                SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                mapSettings = commSettings.SVMX_getSettingList(strSubmoduleId);
                if(mapSettings.size() > 0)
                {
                    list<INTF_StringMap> lstStringMap = new list<INTF_StringMap>();
                    for(String str:mapSettings.keyset())
                    {
                        INTF_StringMap stringMap = new INTF_StringMap();
                        stringMap.key = str;
                        stringMap.value = mapSettings.get(str);
                        system.debug('stringMap'+stringMap);
                        lstStringMap.add(stringMap);
                    }
                    if(lstStringMap.size() > 0)
                    {
                        response.success = true;
                        response.stringMap = lstStringMap;
                    }
                    else
                    {
                        response.success = false;
                        
                    }
                }
            }
        }
        return response; 
    }
    
    webservice static INTF_Response INTF_getViewDefinition_WS(INTF_Request request)
    {
       SVMXC.INTF_CustomViewUtils dcMap = new SVMXC.INTF_CustomViewUtils();
       return dcMap.getViewDefinition(request);
    }
    
    webservice static INTF_Response INTF_getViewData_WS(INTF_Request request)
    {
        SVMXC.INTF_CustomViewUtils dcMap = new SVMXC.INTF_CustomViewUtils();
        return dcMap.getViewData(request); 
    }
    
    webservice static INTF_WebServicesDef.INTF_Response SCON_Get_CodeSnippet_SFMEvent_WS(INTF_Request req)
    {
        List<INTF_StringMap> objEventReq = req.stringMap;
        String strEventId = '';
        for(INTF_StringMap objCurrMap : objEventReq)
        {
            if(objCurrMap.key == 'EventId')
            {
                strEventId = objCurrMap.value;
                break;
            }
        }
        system.debug('req :' + req);
        INTF_Response objResponse = new INTF_Response();    
        String strCodeSnippet = null;
        String idCodeSnippet = null;
        list<SVMXC__SFM_Event__c> lstSelectedEvent = [Select Id, SVMXC__Code_Snippet__c,SVMXC__Code_Snippet__r.SVMXC__Data__c from SVMXC__SFM_Event__c where Id =: strEventId];
        if(lstSelectedEvent != NULL && lstSelectedEvent.size() > 0)
        {
            SVMXC__SFM_Event__c objSelectedEvent = lstSelectedEvent[0];
            idCodeSnippet = objSelectedEvent.SVMXC__Code_Snippet__c;
            List<SVMXC__Code_Snippet_Manifest__c> lstRelatedCodeSnippet = [Select Id, SVMXC__Referenced_Code_Snippet__c,SVMXC__Referenced_Code_Snippet__r.SVMXC__Data__c from SVMXC__Code_Snippet_Manifest__c where SVMXC__Code_Snippet__c =: idCodeSnippet];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            strCodeSnippet = '(function(){ ' + '\n' + objSelectedEvent.SVMXC__Code_Snippet__r.SVMXC__Data__c;
            if( lstRelatedCodeSnippet != null && lstRelatedCodeSnippet.size() > 0)
            {
                String strReferencedCodeSnippet = null;
                for(SVMXC__Code_Snippet_Manifest__c objCurrManifest : lstRelatedCodeSnippet)
                {
                    strReferencedCodeSnippet = objCurrManifest.SVMXC__Referenced_Code_Snippet__r.SVMXC__Data__c;
                    if(strReferencedCodeSnippet != null && strReferencedCodeSnippet.length() > 0)
                    {
                        strCodeSnippet = strCodeSnippet + '\n' + strReferencedCodeSnippet;
                    }
                }
            }
            strCodeSnippet = strCodeSnippet + '\n' + '})();' ;
            
            system.debug('objSelectedEvent :' + objSelectedEvent);
            objResponse.setstringMap(new List<INTF_StringMap>());
            objResponse.getstringMap().add(new INTF_StringMap('EventId',strEventId));
            objResponse.getstringMap().add(new INTF_StringMap('EventData',strCodeSnippet));
        }
        return objResponse;     
    }
    
    webservice static INTF_WebServicesDef.INTF_Response Get_CodeSnippet_SFMEvent_WS(INTF_Request req)
    {
        List<INTF_StringMap> objEventReq = req.stringMap;
        String strEventId = '';
        for(INTF_StringMap objCurrMap : objEventReq)
        {
            if(objCurrMap.key == 'EventId')
            {
                strEventId = objCurrMap.value;
                break;
            }
        }
        INTF_Response objResponse = new INTF_Response();    
        String strCodeSnippet = null;
        String idCodeSnippet = null;
        SVMXC__SFM_Event__c objSelectedEvent = [Select Id, SVMXC__Code_Snippet__c,SVMXC__Code_Snippet__r.SVMXC__Data__c from SVMXC__SFM_Event__c where Id =: strEventId];
        idCodeSnippet = objSelectedEvent.SVMXC__Code_Snippet__c;
        List<SVMXC__Code_Snippet_Manifest__c> lstRelatedCodeSnippet = [Select Id, SVMXC__Referenced_Code_Snippet__c,SVMXC__Referenced_Code_Snippet__r.SVMXC__Data__c from SVMXC__Code_Snippet_Manifest__c where SVMXC__Code_Snippet__c =: idCodeSnippet];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        strCodeSnippet = '(function(){ ' + '\n' + objSelectedEvent.SVMXC__Code_Snippet__r.SVMXC__Data__c;
        if( lstRelatedCodeSnippet != null && lstRelatedCodeSnippet.size() > 0)
        {
            String strReferencedCodeSnippet = null;
            for(SVMXC__Code_Snippet_Manifest__c objCurrManifest : lstRelatedCodeSnippet)
            {
                strReferencedCodeSnippet = objCurrManifest.SVMXC__Referenced_Code_Snippet__r.SVMXC__Data__c;
                if(strReferencedCodeSnippet != null && strReferencedCodeSnippet.length() > 0)
                {
                    strCodeSnippet = strCodeSnippet + '\n' + strReferencedCodeSnippet;
                }
            }
        }
        strCodeSnippet = strCodeSnippet + '\n' + '})();' ;
        
        system.debug('objSelectedEvent :' + objSelectedEvent);
        objResponse.setstringMap(new List<INTF_StringMap>());
        objResponse.getstringMap().add(new INTF_StringMap('EventId',strEventId));
        objResponse.getstringMap().add(new INTF_StringMap('EventData',strCodeSnippet));
        return objResponse;     
    }
    
    webservice static INTF_WebServicesDef.INTF_Response Get_CodeSnippets_WS(INTF_Request request)
    {
        INTF_Response objResponse = new INTF_Response();
        List<INTF_StringMap> lstCodeSnippetsOptions = new List<INTF_StringMap>();
        list<SVMXC__Code_Snippet__c> lstCodeSnippets = [Select SVMXC__SnippetId__c, SVMXC__Name__c from SVMXC__Code_Snippet__c where SVMXC__Name__c != NULL order by SVMXC__SnippetId__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__Code_Snippet__c snippet: lstCodeSnippets)
        {
            lstCodeSnippetsOptions.add(new INTF_StringMap(snippet.Id, snippet.SVMXC__SnippetId__c + ': ' + snippet.SVMXC__Name__c));
        }
        objResponse.stringMap = lstCodeSnippetsOptions;
        return objResponse;
    }
    
    webservice static INTF_WebServicesDef.INTF_Response PCAL_GetPricingDefinition_WS(INTF_Request request)
    {
        PCAL_getPrice clsPriceCalc = new PCAL_getPrice();
        return clsPriceCalc.getPricingDefinitions(request);
    }
    
    webservice static INTF_WebServicesDef.INTF_Response PCAL_GetCasePricingDefinition_WS(INTF_Request request)
    {
        PCAL_getPrice_Case clsPriceCalc = new PCAL_getPrice_Case();
        return clsPriceCalc.getPricingDefinitions(request);
    }
    
    //Added by Naveen V on 20-June-2012 for Generating Invoice for Work Order
    webservice static INTF_Response PINV_GenerateWOInvoiceDoc_WS(INTF_Request req)
    {
        return (new SVMXC.PINV_WOInvoiceUtils()).PINV_GenerateInvoiceDoc(req);
    }
    
    //Added by Soumyaranjan on 5th Dec 2019 for processing Timesheet records created by technician's -BAC-5143
    webservice static INTF_Response processTechinicianTimeDetails(INTF_Request req)
    {
        return (new SVMXC.TMST_TimesheetEngineAPI()).processTimesheetHeaderData(req);
    }
    
    //Added by Naveen V on 20-June-2012 for Generating Invoice for Service Contract
    webservice static INTF_Response PINV_GenerateSCInvoiceDoc_WS(INTF_Request req)
    {
      return (new SVMXC.PINV_SCInvoiceUtils()).PINV_GenerateSCInvoiceDoc(req);
    }
    
    //Neeraj(20-June-2012): Webservice Method for SCON Activation.
    webservice static INTF_PageData INTF_ActivateContract(INTF_TargetRecord request)
    {
       return (new SVMXC.SCON_SFMEventUtils()).activateContract(request);
    }
    //Neeraj(20-June-2012): Webservice Method for SCON Renewal.
    webservice static INTF_PageData INTF_RenewContract (INTF_TargetRecord request)
    {
        return (new SVMXC.SCON_SFMEventUtils()).renewContract(request);
    }
    
    //Neeraj(20-June-2012): Webservice Method for SCON Cancellation.
    webservice static INTF_PageData INTF_CancelContract (INTF_TargetRecord request)
    {
        return (new SVMXC.SCON_SFMEventUtils()).cancelContract(request);
    }
    
    //Sharad(10-July-2012): Webservice Method for auto entitlement Work Order.
    webservice static INTF_Response INTF_EVER_WorkOrder_WS (INTF_Request request)
    {
        WORD_AutoEntitlement objWOEntitlment = new WORD_AutoEntitlement();
        return objWOEntitlment.SVMX_DoEntitlement(request);
    }
    
    //Sharad(10-July-2012): Webservice Method for auto entitlement Case.
    webservice static INTF_Response INTF_EVER_Case_WS (INTF_Request request)
    {
        CASE_AutoEntitlement objCaseEntitlment = new CASE_AutoEntitlement();
        return objCaseEntitlment.SVMX_DoEntitlement(request);
    }
    
    //Neeraj(20-June-2012): Webservice Method for SCON Cancellation.
    webservice static INTF_PageData PINV_CancelInvoice_WS(INTF_TargetRecord request)
    {
        //return (new SVMXC.PINV_Utils()).PINV_CancelInvoice(request);
        return (new SVMXC.PINV_Utils()).PINV_CancelInvoice(request);
    }
    /*
    //Bala(07-Sep-2012): Webservice Method for performing MTTS Rule
    webservice static INTF_Response WORD_CalculateMTTSRule_WS(INTF_Request request)
    {
        (new SVMXC.OMAX_PreCalculation()).performMTTSCalculation(request.valueMap[0].data, NULL, NULL, NULL);
        return null;
    }*/
    
    //Neeraj(10-Sep-2012): Webservice Method for PM Plan Cancellation.
    webservice static INTF_PageData INTF_CancelPMPlan_WS(INTF_TargetRecord request)
    {
        return (new SVMXC.PREV_PMPlanUtils()).PREV_CancelPMPlan(request);
    }
    
     webservice static INTF_PageData INTF_UpdateConsumedLocation_WORD_WS(INTF_TargetRecord request)
    { INTF_UpdateConsumedLocation_WORD obj = new INTF_UpdateConsumedLocation_WORD();
        return obj.setConsumedFrmLoc(request);
    }       
    
    
    /*
     *Type : Webservice Method
     *Used : Professional Support/Customers
     *Desc : Web Service on SFDC that to get QTL values and skills required for work order
     */
    webservice static INTF_WebServicesDef.INTF_Response OMAX_BuildQualifiedTechnicians_WS(INTF_WebServicesDef.INTF_Request request)
    {
        INTF_WebServicesDef.INTF_Response response = new INTF_WebServicesDef.INTF_Response();
        SMAX_OptiMax_EngineUtils clsOMAXUtils = new SMAX_OptiMax_EngineUtils();
        response = clsOMAXUtils.OMAX_BuildQualifiedTechnicians_WS(request);
        return response;
    }
    //---------------------------------------------These Webservices are no more in use--------------------------------------------------------------
    webservice static INTF_WebServicesDef.INTF_Response INTF_CalculatePMPlanDetails_SCON_WS(INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.INTF_WebServicesDef.INTF_Response());
    }
    webservice static INTF_WebServicesDef.INTF_Response INTF_ActivatePMPlan_PREV_WS(INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.INTF_WebServicesDef.INTF_Response());
    }
    webservice static INTF_Response INTF_CalculatePMPlanDetails_ACCT_WS(INTF_TargetRecord request)
    {
        return (new SVMXC.INTF_WebServicesDef.INTF_Response());
    }
    webservice static INTF_Response INTF_CalculatePMPlanDetails_IPRD_WS(INTF_TargetRecord request)
    {
        return (new SVMXC.INTF_WebServicesDef.INTF_Response());
    }
    webservice static INTF_Response INTF_CalculatePMPlanDetails_LOC_WS(INTF_TargetRecord request)
    {
        return (new SVMXC.INTF_WebServicesDef.INTF_Response());
    }   
    //------------------------------------------------------------------------------------------------------------------------------------------------ 


    webservice static INTF_PageData INTF_SCON_Validate_Allowed_Units(INTF_TargetRecord request)
    {
        INTF_PageData pageData =  new INTF_PageData();
        String unlimited_Value = '0';
        Map<String, String> settingValueMap = new COMM_Utils_ManageSettings().SVMX_getSettingList2('EVER005','SET029');
        
        if(settingValueMap != null && settingValueMap.containsKey('SET029')){
            unlimited_Value = settingValueMap.get('SET029');
        }

        if(unlimited_Value != '0'){
            List<INTF_TargetRecordObject> detailObjRecords = request.detailRecords;
            
            if(detailObjRecords != null && !detailObjRecords.isEmpty()){

                for(INTF_TargetRecordObject detailObjRecord: detailObjRecords){

                    if(detailObjRecord.objName != null && detailObjRecord.objName == 'SVMXC__Service_Contract_Services__c'){
                        List<INTF_Record> objRecords = detailObjRecord.records;
                        
                        if(objRecords != null && !objRecords.isEmpty()){
                            for(INTF_Record rec : objRecords){
                                List<INTF_StringMap> fieldValueMap = rec.targetRecordAsKeyValue;
                                for(INTF_StringMap valueMap : fieldValueMap){
                                    
                                    if(valueMap.key == 'SVMXC__Included_Units__c' && valueMap.value == NULL){
                                        INTF_Response response = new INTF_Response();
                                        response.success = false;
                                        response.message = System.Label.COMM001_TAG144; //'Allowed Units field under Included Services cannot be left blank';
                                        pageData.response = response;
                                        return pageData;
                                    }
                                }
                            }

                        }

                    }
                }
            }
        }
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        return buildpagedata.INTF_buildPageData(request);
    }    
}