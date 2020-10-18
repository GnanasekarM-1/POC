/* Security Scanned */
public with sharing class SFM_GetPageLayout 
{
    //Internal Wrapper class
    public I18N_TranslationDelivery objTranslnUtil;
    public class SFMException extends Exception {}
    public Integer Linelimit = 200;
    Map<Id, List<SVMXC__SFM_Event__c>> elementEventsMap; //To get the events mapped to each field element of a Section/Detail
    public class Wrapper
    {
        public String FieldApiName {get;set;}
        public String DataType {get;set;}
        public String LookupConfigID {get;set;}
        public String RelatedObjName {get;set;}
        public String RelatedObjFieldName {get;set;}
        public String DefaultLookupColumn {get;set;}
        public Wrapper(){}
    }
   
    SVMXC.SFM_WrapperDef pmaxwrapp = new SVMXC.SFM_WrapperDef();
    SVMXC.SFM_ParseProcess parseProcess = new SVMXC.SFM_ParseProcess();
    SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils(); 
    SVMXC.SFM_Utils SFMUtils = new SVMXC.SFM_Utils(); 
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
    public map<String,String> mapObjNameField = new map<String,String>();
    public map<Id,String> mapAliasNameObjectName = new map<Id,String>();
    public map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    public map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    public map<String, Schema.SObjectType> allobjmapLowerCase  = new map<String, Schema.SObjectType>(); 
    public map<String,map<String, Schema.SObjectField>> mapAllFieldDescribe = new map<String,map<String, Schema.SObjectField>>();
    public map<String,String> PageIdMapId = new map<String,String>();
    public map<String,String> PrifixMap = new map<String,String>();
    map<String, String> AllSubModuleSettings = new map<String, String>();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    Boolean enableAttachment = false;
    //BAC-5162
     Boolean isHTMLview = false;
    //Constructor 
    public SFM_getPageLayout()
    {
        gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            Schema.DescribeSObjectResult result = s.getDescribe();
            allobjmap.put(result.getName(),s);
            allobjmapLowerCase.put(result.getName().toLowercase(),s);
            PrifixMap.put(result.getKeyPrefix(),result.getName());
        } 
        /*AllSubModuleSettings = settings.SVMX_getSettingList('SFM002');
        if(AllSubModuleSettings.containskey('SET001'))
            Linelimit = Integer.valueof(AllSubModuleSettings.get('SET001'));*/
            //BAC-5162 start
            String settingValue = settings.SVMX_getGlobalSettingList('SFM001_SET006');
            if(settingValue!='' && settingValue!=null & settingValue.equalsIgnoreCase('HTML'))
            {
              isHTMLview = true;
            }
            //End BAC-5162
    }
   
    public SFM_WrapperDef.SFM_Response_PageUI SFM_GetPageLayout(SFM_WrapperDef.SFM_Request_PageUI PmaxReqPageUI)
    {
        map<String,map<String,Sobject>> mapAliasNameSourceRecIdTargetObject = new map<String,map<String,Sobject>>();
        /* #optiChange THIS class  String TargetManager = '';
        String ProcessNodeObj = '';
        Map<String,Id> mapRecordTypeDetails = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Processes__c',new List<String> {'Target_Manager','Process_Node_Objects'});
        TargetManager = mapRecordTypeDetails.get('Target_Manager');
        ProcessNodeObj = mapRecordTypeDetails.get('Process_Node_Objects');*/
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        /* #optiChange THIS class is not being executed in BSFM
         *         List<RecordType> RecordTypes = new List<RecordType>(); 
         * RecordTypes = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        if(RecordTypes.size() > 0 )
        {
            for(RecordType r : RecordTypes)
            {
                if(r.Name == 'Target Manager')
                {
                    TargetManager = r.id;
                }
                if(r.Name == 'Process Node Objects')
                {
                    ProcessNodeObj = r.id;
                }
            }
        }*/
        SVMXC.SFM_WrapperDef.SFM_PageHeader PageHeader = new SVMXC.SFM_WrapperDef.SFM_PageHeader();
        SVMXC.SFM_WrapperDef.SFM_Response_PageUI  PageResponseUI = new SVMXC.SFM_WrapperDef.SFM_Response_PageUI();
        SVMXC.SFM_WrapperDef.SFM_Response SFMResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMX_Debug  log = new SVMX_Debug();
        list<SVMXC__ServiceMax_Processes__c> ProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        map<String,List<Sobject>> TargetRecMap = new map<String,List<Sobject>>(); 
        map<String, Schema.SObjectField> Fieldmap = new map<String, Schema.SObjectField>();
        List<String> HdrFieldLst = new List<String>(); 
        set<String> setObjectForRecordType = new set<String>();
        /*string userId = PmaxReqPageUI.request.userId;
        string groupId = PmaxReqPageUI.request.groupId;
        string profileId = PmaxReqPageUI.request.profileId;*/ 
        String pageId = '';
        String RecId = '';
        string ProcessId = '';
        String strClientType = '';
        String strRequestType = 'ALL';
        String HdrObjectName = '';
        String NameField = '';
        String NameFieldLabel = '';
        String ProcessTitle = '';
        String TargetObjName = '';
        String SourceObjName = '';
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> StringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> ResponseStringMapList = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        list<SVMXC.SFM_WrapperDef.SFM_StringListMap> ResponseStringListMap = new list<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        List<SVMXC.SFM_WrapperDef.SFM_ProcessBusinessRule> lstProBizRuleWrap = new List<SVMXC.SFM_WrapperDef.SFM_ProcessBusinessRule>();
        StringMap = PmaxReqPageUI.request.StringMap;
        SVMXC__ServiceMax_Processes__c Process = new SVMXC__ServiceMax_Processes__c();
        SVMXC__Page_Layout__c HeaderLayout = new SVMXC__Page_Layout__c();
        List<SVMXC__Page_Layout_Detail__c> HdrDetail = new List<SVMXC__Page_Layout_Detail__c>();
        List<SVMXC__Page_Layout_Detail__c> SectionLst = new List<SVMXC__Page_Layout_Detail__c>();
        List<SVMXC__Page_Layout_Detail__c> fieldLst = new List<SVMXC__Page_Layout_Detail__c>();
        List<SVMXC__Page_Layout_Detail__c> ButtondLst = new List<SVMXC__Page_Layout_Detail__c>();
        List<SVMXC__SFM_Event__c> HdrPageEvents = new List<SVMXC__SFM_Event__c> ();
        List<SVMXC__SFM_Event__c> HdrFldBtnEvents = new List<SVMXC__SFM_Event__c> ();
        List<SVMXC__SFM_Event__c> ButtonEvents = new List<SVMXC__SFM_Event__c> ();
        List<SVMXC__SFM_Event__c> FieldEvents = new List<SVMXC__SFM_Event__c> ();
        List<Sobject> HdrRecords = new List<Sobject>();
        set<Id> HdrDetailIds = new set<Id>();
        set<Id> LookupConfigId = new set<id>();
        set<String> setSourceObjectName = new set<String>();
        Map<String,List<SVMXC__SFM_Event__c>> FLdEventMap = new Map<String,List<SVMXC__SFM_Event__c>>();
        Map<String,List<SVMXC__SFM_Event__c>> BtnEventMap = new Map<String,List<SVMXC__SFM_Event__c>>();
        map<String,String> SourceObjectParentColumnMap = new map<String,String>();
        map<String,String> ChildObjSourceTargetMap = new map<String,String>();
        List<SVMXC.SFM_WrapperDef.SFM_UISection> Sections = new List<SVMXC.SFM_WrapperDef.SFM_UISection>();
        List<SVMXC.SFM_WrapperDef.SFM_UIButton> Buttons = new List<SVMXC.SFM_WrapperDef.SFM_UIButton>();
        map<String,String> mapObjectNameLookupConfigId = new map<String,String>();
        set<String> setLookupConfigId = new set<String>();
        set<String> setTCProcessNodeObjId = new set<String>();
        map<String,String> mapAliasNameProcessNodeObjId = new map<String,String>();
        map<String,String> mapObjectNameFieldName = new map<String,String>();
        map<String,String> mapPageLayoutIdAliasName = new map<String,String>();
        map<String,list<SVMXC__ServiceMax_Processes__c>> mapNodeIdLinkedProcesses = new map<String,list<SVMXC__ServiceMax_Processes__c>>();
        SVMXC.SFM_WrapperDef.SFM_PageUI  pageui = new SVMXC.SFM_WrapperDef.SFM_PageUI();
        set<Id> setFromFillId = new set<Id>();
        
        /////////////Added by Manish to support checklist type of process
        Set<String> setQuestionIds = new Set<String>();
        Map<String, SVMXC.SFM_WrapperDef.SFM_QuestionInfo> mapQuesIdQuesInfoObject = new Map<String, SVMXC.SFM_WrapperDef.SFM_QuestionInfo>();
        ////////////
        log.login('SFM_PageLayout', 'SFM_GetPageLayout');
        //try
        //{
            if(StringMap.size() > 0)
            {
                //log.setlog('LOOPING-Start', 'To set ProcessId and pageId values based on the key');
                for(Integer i = 0; i<StringMap.size(); i++)
                {
                    if(StringMap[i].key != null && StringMap[i].key.toUppercase() == 'PAGEID' && StringMap[i].value != null && StringMap[i].value.length() > 0)
                    {
                        pageId = StringMap[i].value;
                    }
                    else if(StringMap[i].key != null && StringMap[i].key.toUppercase() == 'RECORDID' && StringMap[i].value != null && StringMap[i].value.length() > 0)
                    {
                        RecId = StringMap[i].value;
                    }
                    else if(StringMap[i].key != null && StringMap[i].key.toUppercase() == 'PROCESSID' && StringMap[i].value != null && StringMap[i].value.length() > 0)
                    {
                        ProcessId = StringMap[i].value;
                    }
                    else if(StringMap[i].key != null && StringMap[i].key.toUppercase() == 'CLIENT_TYPE' && StringMap[i].value != null && StringMap[i].value.length() > 0)
                    {
                        strClientType = StringMap[i].value;
                    }
                    else if(StringMap[i].key != null && StringMap[i].key.toUppercase() == 'REQUEST_TYPE' && StringMap[i].value != null && StringMap[i].value.length() > 0)
                    {
                        strRequestType = StringMap[i].value;
                    }  
                    
                }
                system.debug('ProcessId'+ProcessId);
                system.debug('pageId'+pageId);
                system.debug('RecId'+RecId);
                //log.setlog('LOOPING-End', 'To set ProcessId and pageId values based on the key');
            }
            //Get The Process and Process Node Objects
            if(ProcessId != null && ProcessId.length() > 0)
            {
               list<SVMXC__ServiceMax_Processes__c> ProList = new list<SVMXC__ServiceMax_Processes__c>();
               //BAC-6133 added  SVMXC__SM_Disable_Realtime_Validation__c
               //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
               ProList = [Select SVMXC__Type__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Child_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Tag_Keys__c, SVMXC__Target_Record_Type__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById, SVMXC__SM_Disable_Realtime_Validation__c From SVMXC__ServiceMax_Processes__c where RecordType.DeveloperName = 'Target_Manager' and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)];
               system.debug('ProList'+ProList);
               if(ProList.size() > 0)
               {
                   Process = ProList[0];
                   
                    /* Start - Logic to translate SFM Target Manager (ServiceMax Process) record  */
                    if(Process.SVMXC__Tag_Keys__c != NULL && Process.SVMXC__Tag_Keys__c.length() > 0)
                    {
                        objTranslnUtil = new I18N_TranslationDelivery(Process.SVMXC__Tag_Keys__c, UserInfo.getLanguage());
                        Process = objTranslnUtil.SVMX_GetProcessTranslation(Process);   
                    }
                    /* End */
                    
                   if(Process != null && Process.SVMXC__Page_Layout__c != null)
                        pageId = Process.SVMXC__Page_Layout__c;
                   if(Process != null && Process.SVMXC__Dispatch_Process_Status__c != null && Process.SVMXC__Dispatch_Process_Status__c.touppercase() != 'COMPLETE')
                   {
                        SFMResponse.success = false;
                        SFMResponse.message = system.Label.SFM002_TAG056;
                        PageResponseUI.response = SFMResponse;
                        system.debug('PageResponseUI'+PageResponseUI);
                        return PageResponseUI;
                   }
                   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                   ProcessNodeObjects = [Select  SVMXC__Enable_Attachment__c, SVMXC__Process__r.SVMXC__Purpose__c, SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c,SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__c,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById,SVMXC__Values__c From  SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: Process.id and RecordType.DeveloperName = 'Process_Node_Objects'];
                   if(Process.SVMXC__Purpose__c.touppercase() == 'STANDALONE EDIT')
                   {
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        strmap.key = 'PROCESSTYPE';
                        strmap.value = 'EDIT';
                        SFMResponse.stringMap.add(strmap);
                    }
                    else if(Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL')
                    {
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        strmap.key = 'PROCESSTYPE';
                        strmap.value = 'SOURCETOTARGET';
                        SFMResponse.stringMap.add(strmap);
                    }
                    else if(Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD')
                    {
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        strmap.key = 'PROCESSTYPE';
                        strmap.value = 'SOURCETOTARGETONLYCHILDROWS';
                        SFMResponse.stringMap.add(strmap);
                    }
                    else if(Process.SVMXC__Purpose__c.touppercase() == 'STANDALONE CREATE')
                    {
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        strmap.key = 'PROCESSTYPE';
                        strmap.value = 'STANDALONE CREATE';
                        SFMResponse.stringMap.add(strmap);
                    }
                    else if(Process.SVMXC__Purpose__c.touppercase() == 'VIEW RECORD')
                    {
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        strmap.key = 'PROCESSTYPE';
                        strmap.value = 'VIEW RECORD';
                        SFMResponse.stringMap.add(strmap);
                    }
                    else if(Process.SVMXC__Purpose__c.touppercase() == 'CHECKLIST')//Added by Manish to support checklist type of process
                    {
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        strmap.key = 'PROCESSTYPE';
                        strmap.value = 'CHECKLIST';
                        SFMResponse.stringMap.add(strmap);
                    }
                   
                    //BAC-6133 Enable Real-Time Validation value
                    if(Process.SVMXC__SM_Disable_Realtime_Validation__c != null){
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        strmap.key = 'ENABLEREALTIMEVALIDATION';
                        strmap.value = Process.SVMXC__SM_Disable_Realtime_Validation__c == true ? 'FALSE' : 'TRUE';
                        SFMResponse.stringMap.add(strmap);
                    }
               }
               else
               {
                    SFMResponse.success = false;
                    SFMResponse.message = system.Label.SFM002_TAG001;
                    PageResponseUI.response = SFMResponse;
                    system.debug('PageResponseUI'+PageResponseUI);
                    return PageResponseUI;
               }    
            }
            //first creare a response for the parent column name..
            map<String,SVMXC__ServiceMax_Processes__c> mapPagelayoutIdProcessNodeObject = new map<String,SVMXC__ServiceMax_Processes__c>(); 
            if(ProcessNodeObjects.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c Pro : ProcessNodeObjects)
                {
                    if(Pro.SVMXC__Source_Object_Name__c != null)
                        setObjectForRecordType.add(Pro.SVMXC__Source_Object_Name__c);
                    if(Pro.SVMXC__Type__c.touppercase() == 'TARGETCHILD')
                    {
                        setTCProcessNodeObjId.add(Pro.id);
                        if(Pro.SVMXC__Page_Layout__c != null){
                            mapPagelayoutIdProcessNodeObject.put(Pro.SVMXC__Page_Layout__c,Pro);
                            mapAliasNameProcessNodeObjId.put(Pro.SVMXC__Page_Layout__c,Pro.id);
                            mapPageLayoutIdAliasName.put(Pro.SVMXC__Page_Layout__c,Pro.SVMXC__Target_Object_label__c);
                        }    
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        if(Pro.SVMXC__Parent_Column_Name__c != null && Pro.SVMXC__Page_Layout__c != null)//here we have changed the apporoch of alias now we will pass the pagelayot id coresponding process node object
                        {
                            strmap.key = Pro.SVMXC__Page_Layout__c;
                            strmap.value = Pro.SVMXC__Parent_Column_Name__c;
                            strmap.value1 = Pro.SVMXC__Values__c;
                            ResponseStringMapList.add(strmap);
                        }
                        if(pro.SVMXC__Node_Source_Object_API__c != null && pro.SVMXC__Source_Object_Name__c != null && ChildObjSourceTargetMap.containskey(pro.SVMXC__Node_Source_Object_API__c) == false)
                        {
                          ChildObjSourceTargetMap.put(pro.SVMXC__Node_Source_Object_API__c,pro.SVMXC__Source_Object_Name__c);
                        }

                    }
                    else if(Pro.SVMXC__Type__c.touppercase() == 'SOURCECHILD')
                    {
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap1 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        if(Pro.SVMXC__Parent_Column_Name__c != null && Pro.SVMXC__Target_Object_label__c != null)
                        {
                            strmap1.key = Pro.SVMXC__Target_Object_label__c;
                            strmap1.value = Pro.SVMXC__Parent_Column_Name__c;
                            ResponseStringMapList.add(strmap1);
                        }
                        if(Pro.SVMXC__Source_Object_Name__c != null && Pro.SVMXC__Parent_Column_Name__c != null && SourceObjectParentColumnMap.containskey(Pro.SVMXC__Source_Object_Name__c) == false)
                        {
                            SourceObjectParentColumnMap.put(Pro.SVMXC__Source_Object_Name__c,Pro.SVMXC__Parent_Column_Name__c);
                        }
                        if(Pro.SVMXC__Source_Object_Name__c != null){
                            setSourceObjectName.add(Pro.SVMXC__Source_Object_Name__c);
                        }
                        if(pro.SVMXC__Page_Layout__c != null && pro.SVMXC__Source_Object_Name__c != null){
                            mapAliasNameObjectName.put(pro.SVMXC__Page_Layout__c,pro.SVMXC__Source_Object_Name__c);
                        } 
                    }
                    else if(Pro.SVMXC__Type__c.touppercase() == 'TARGET' && Pro.SVMXC__Source_Object_Name__c != null)
                    {
                        TargetObjName = Pro.SVMXC__Source_Object_Name__c;
                        enableAttachment = Pro.SVMXC__Enable_Attachment__c;
                        mapPageLayoutIdAliasName.put(Process.SVMXC__Page_Layout__c,Pro.SVMXC__Target_Object_label__c);
                        mapPagelayoutIdProcessNodeObject.put(Process.SVMXC__Page_Layout__c,Pro); //Added for BAC-4677
                    }
                    else if(Pro.SVMXC__Type__c.touppercase() == 'SOURCE' && Pro.SVMXC__Source_Object_Name__c != null){
                        SourceObjName = Pro.SVMXC__Source_Object_Name__c;
                        setSourceObjectName.add(Pro.SVMXC__Source_Object_Name__c);
                    }
                }
                SFMResponse.stringMap.addall(ResponseStringMapList);
            }
            system.debug('ResponseStringMapList'+ResponseStringMapList);
            system.debug('SourceObjectParentColumnMap'+SourceObjectParentColumnMap);
            system.debug('ChildObjSourceTargetMap'+ChildObjSourceTargetMap);
            system.debug('mapAliasNameObjectName'+mapAliasNameObjectName);
            system.debug('mapAliasNameProcessNodeObjId'+mapAliasNameProcessNodeObjId);
            system.debug('mapPageLayoutIdAliasName'+mapPageLayoutIdAliasName);
            // populat record type list 
            /* if(setObjectForRecordType.size() > 0){
                List <String> recordTypeName = new List <String> ();
                for(integer recordTypeId=0; recordTypeId < setObjectForRecordType.size(); recordTypeId++){
                    List <String> objectRecordName = COMM_Utils_V2.getObjectAvailRecordType(new list<string>(setObjectForRecordType)[recordTypeId]); 
                    if(!objectRecordName.isEmpty())//Defect 042254 : excluding the object which doesn't have record type
                    {
                        recordTypeName.addAll(objectRecordName);
                    }
                          
                }
                list<RecordType> lstRecordTypes = [Select SobjectType, Name, Id, DeveloperName From RecordType where SobjectType IN : setObjectForRecordType and Name IN :recordTypeName];
                for(RecordType rt : lstRecordTypes){
                    SVMXC.SFM_WrapperDef.SFM_StringMap recTypeStrMap = new SVMXC.SFM_WrapperDef.SFM_StringMap(rt.Id,rt.Name,rt.SobjectType);
                    pageui.recordTypeList.add(recTypeStrMap);
                }
            }*/
            //populat record type list
            //Defect 42506: Re-written above code to use RecordType Id instead of Name
            if(setObjectForRecordType.size() > 0){
                List <ID> recordTypeIdLst = new List <ID> ();
                for(integer recordTypeId=0; recordTypeId < setObjectForRecordType.size(); recordTypeId++){
                    List <ID> objectRecordTypeID = COMM_Utils_V2.getObjectAvailRecordType(new list<string>(setObjectForRecordType)[recordTypeId]); 
                    if(!objectRecordTypeID.isEmpty())//Defect 042254 : excluding the object which doesn't have record type
                    {
                        recordTypeIdLst.addAll(objectRecordTypeID);
                    }
                          
                }
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                list<RecordType> lstRecordTypes = [Select SobjectType, toLabel(Name), Id, DeveloperName From RecordType where SobjectType IN : setObjectForRecordType and ID IN :recordTypeIdLst];
                for(RecordType rt : lstRecordTypes){
                    SVMXC.SFM_WrapperDef.SFM_StringMap recTypeStrMap = new SVMXC.SFM_WrapperDef.SFM_StringMap(rt.Id,rt.Name,rt.SobjectType);
                    pageui.recordTypeList.add(recTypeStrMap);
                }
            }
            system.debug(LoggingLevel.WARN,'recordTypeList'+pageui.recordTypeList);
            
            system.debug(LoggingLevel.WARN,'strRequestType'+strRequestType);
            
            //Business Rule meta info.
            if(strRequestType != NULL && strRequestType.length() > 0 && strRequestType == 'META')
            {
                if(Process.Id != NULL && String.valueOf(Process.Id).length() > 0)
                    lstProBizRuleWrap = new SFM_BizRuleUtils().bizRuleMetaInfo(Process.Id);
                  system.debug(LoggingLevel.WARN,'lstProBizRuleWrap:  '+lstProBizRuleWrap);  
                //Query Linked Processes
                list<SVMXC__ServiceMax_Processes__c> lstLinkedProcesses = new list<SVMXC__ServiceMax_Processes__c>();
                //Added extra columnsin query to support translations
                lstLinkedProcesses = [Select Id, Name, SVMXC__Process1__c, SVMXC__Process1__r.SVMXC__ProcessID__c, SVMXC__Process2__c, SVMXC__Process3__c, SVMXC__Process3__r.SVMXC__ProcessID__c, SVMXC__Process3__r.SVMXC__Purpose__c, SVMXC__Sequence__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Parent_Error_Msg__c, SVMXC__Child_Error_Msg__c, SVMXC__Confirmation_Message__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Linked Process' and SVMXC__Process1__c =: Process.id and SVMXC__Process2__c IN : setTCProcessNodeObjId and SVMXC__Process3__c != null and SVMXC__Name__c != null]; // added  SVMXC__Process3__r.SVMXC__Purpose__c #defectFix BAC-6015
                if(lstLinkedProcesses.size() > 0){
                    
                    /* Start - Logic to translate SFM Linked SFM Title */
                    String TranslationKeys = '';
                    for(SVMXC__ServiceMax_Processes__c pro : lstLinkedProcesses){
                        if(pro.SVMXC__Name__c != NULL && pro.SVMXC__Name__c.length() > 0)
                            TranslationKeys += pro.SVMXC__Name__c.replaceAll(' ', '_');
                    }
                    if(TranslationKeys != NULL && TranslationKeys.length() > 0 && objTranslnUtil != NULL)
                        lstLinkedProcesses = objTranslnUtil.SVMX_GetProcessTranslation(lstLinkedProcesses);
                    else if(TranslationKeys != NULL && TranslationKeys.length() > 0)
                        lstLinkedProcesses = new I18N_TranslationDelivery(TranslationKeys, UserInfo.getLanguage()).SVMX_GetProcessTranslation(lstLinkedProcesses);
                    /* End */
                    for(SVMXC__ServiceMax_Processes__c pro : lstLinkedProcesses){
                        if(mapNodeIdLinkedProcesses.containskey(pro.SVMXC__Process2__c)){
                            mapNodeIdLinkedProcesses.get(pro.SVMXC__Process2__c).add(pro);
                        }else{
                            mapNodeIdLinkedProcesses.put(pro.SVMXC__Process2__c, new list<SVMXC__ServiceMax_Processes__c>());
                            mapNodeIdLinkedProcesses.get(pro.SVMXC__Process2__c).add(pro);
                        }
                    }
                }
                system.debug('mapNodeIdLinkedProcesses'+mapNodeIdLinkedProcesses);  
            }
            
            
            /*if(setSourceObjectName.size() > 0 && (Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD')){
                for(String str : setSourceObjectName){
                    if(allobjmap.containskey(str) && ! mapObjNameField.containskey(str)){
                        if(str != 'Account'){
                            map<String,Schema.SObjectField> mapFields = new map<String,Schema.SObjectField>();
                            mapFields = allobjmap.get(str).getDescribe().fields.getMap();
                            if(mapFields.size() > 0){
                                for(String s : mapFields.keyset()){
                                    if((mapFields.get(s).getdescribe().isNameField())){
                                        NameField = mapFields.get(s).getdescribe().getName();
                                        break;
                                    }   
                                }
                                mapObjNameField.put(str,NameField);
                            }
                        }    
                        else{
                            mapObjNameField.put('Account','Name');
                        }
                    }       
                }
            }
            system.debug('mapObjNameField'+mapObjNameField);  */       
            //Parse the process and get the Header & Detail Records....(for SourceToTarget and EDIT process) 
            if(strRequestType != null && strRequestType.length() > 0 && strRequestType == 'ALL')
            {
                if(ProcessId != null && ProcessId.length() > 0 && RecId != null && RecId.length() > 0)
                {
                    TargetRecMap = parseProcess.getSFM_ParseProcess(ProcessId,RecId,allobjmap,null);//
                    mapAliasNameSourceRecIdTargetObject = parseProcess.mapAliasNameSourceRecIdTargetObject;
                    mapAllFieldDescribe = parseProcess.mapAllFieldDescribe;
                    system.debug('TargetRecMap'+TargetRecMap);
                    system.debug('mapAliasNameSourceRecIdTargetObject: '+mapAliasNameSourceRecIdTargetObject.size()+' '+mapAliasNameSourceRecIdTargetObject);
                }
                else if (ProcessId != null && ProcessId.length() > 0)//For Standalone CREATE Process
                {
                    TargetRecMap = parseProcess.getSFM_ParseProcess(ProcessId,null,allobjmap,null);
                    mapAllFieldDescribe = parseProcess.mapAllFieldDescribe;
                    system.debug('TargetRecMap'+TargetRecMap); 
                }    
                
            }
            if(RecId != null && RecId.length() > 0)
            {
                // Get the Header & Detail Records Map Follwing method will apply  Expression & Mapping and return the map of Qulified Header Detail reocrds.
                String Rid = RecId.substring(0,3);
                map<String,Schema.SObjectField> fldmap = new map<String,Schema.SObjectField>();
                if(PrifixMap.containskey(Rid))
                    fldmap = allobjmap.get(PrifixMap.get(Rid)).getDescribe().fields.getMap();
                if(fldmap.size() > 0)
                {
                    for(String s : fldmap.keyset())
                    {
                        if((allobjmap.get(PrifixMap.get(Rid)) == Account.SObjectType && fldmap.get(s).getdescribe().getName() == 'Name')||(allobjmap.get(PrifixMap.get(Rid)) != Account.SObjectType && fldmap.get(s).getdescribe().isNameField()))
                        {
                            NameField = fldmap.get(s).getdescribe().getName();
                            NameFieldLabel = fldmap.get(s).getdescribe().getlabel();
                        }   
                    }
                }
                   
            }
            //set the process Title 
            if(Process != null && Process.SVMXC__Name__c != null)
                ProcessTitle =  Process.SVMXC__Name__c;
            if(NameFieldLabel != null && NameFieldLabel.length() > 0 && NameField != null && NameField.length() > 0 && RecId != null && RecId.length() > 0 && PrifixMap.Containskey(RecId.substring(0,3))) 
            {
                String Query = 'Select '+NameField+ ' From ' +PrifixMap.get(RecId.substring(0,3))+' Where Id = \''+RecId+'\''; 
                system.debug('Query'+Query);
                Sobject Sobj = Database.query(Query);
                if(Sobj != null)
                    ProcessTitle += ' (' +NameFieldLabel+ ': ' + String.valueof(Sobj.get(NameField)) + ')';
            }
            pageui.processTitle = ProcessTitle;
            if(pageId != null && pageId.length() > 0)
            {
                //Get the HeaderpageLayout 
                //log.setlog('QUERY_TEXT', 'Retrieving the pagelayout for the pageid');
                //Added SVMXC__No_Of_Columns__c field in the SOQL for the task BAC-4798
                HeaderLayout = [Select SVMXC__No_Of_Columns__c, SVMXC__Type__c,SVMXC__Sequence__c,SVMXC__Prompt_For_New_Event__c,SVMXC__Enable_Attachments__c,SVMXC__Enable_Chatter__c,SVMXC__Show_Account_History__c,SVMXC__Show_All_Sections_By_Default__c,SVMXC__Show_Product_History__c,
                                SVMXC__Hide_Save__c,SVMXC__Hide_Quick_Save__c,SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Enable_Service_Report_View__c, SVMXC__Enable_Troubleshooting__c, SVMXC__Enable_Service_Report_Generation__c, 
                                SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c, SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate, 
                                LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById, SVMXC__SM_Include_Contact__c, SVMXC__SM_Include_Field1__c, SVMXC__SM_Include_Field2__c, SVMXC__SM_Include_Field3__c, SVMXC__SM_Include_Summary__c, SVMXC__SM_Include_Time_and_Place__c, SVMXC__SM_Summary_Title__c, SVMXC__SM_Title_Bar__c From SVMXC__Page_Layout__c where id =: pageId OR Name =: pageId OR SVMXC__Page_Layout_ID__c =: pageId]; 
                /* HeaderLayout = [Select SVMXC__Type__c,SVMXC__Sequence__c,SVMXC__Prompt_For_New_Event__c,SVMXC__Enable_Attachments__c,SVMXC__Enable_Chatter__c,SVMXC__Show_Account_History__c,SVMXC__Show_All_Sections_By_Default__c,SVMXC__Show_Product_History__c,
                                SVMXC__Hide_Save__c,SVMXC__Hide_Quick_Save__c,SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Enable_Service_Report_View__c, SVMXC__Enable_Troubleshooting__c, SVMXC__Enable_Service_Report_Generation__c, 
                                SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c, SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate, 
                                LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c where id =: pageId OR Name =: pageId OR SVMXC__Page_Layout_ID__c =: pageId];
                */
                system.debug('HeaderLayout'+HeaderLayout);
                
                /* Start - Logic to translate SFM Header Page Layout Fields  */
                if(HeaderLayout != NULL && objTranslnUtil != NULL)
                    HeaderLayout = objTranslnUtil.SVMX_GetPageLayoutTranslation(HeaderLayout);  
                /* End */
                
                if(mapPageLayoutIdAliasName.containskey(HeaderLayout.id))
                    HeaderLayout.SVMXC__Page_Layout_ID__c = mapPageLayoutIdAliasName.get(HeaderLayout.id);
            }
            //Get the Header Data For the page..
            if(mapAliasNameSourceRecIdTargetObject.size() > 0  && HeaderLayout.SVMXC__Object_Name__c  != null && mapAliasNameSourceRecIdTargetObject.containskey(HeaderLayout.SVMXC__Object_Name__c) && (Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL'))
            {
                map<String,Sobject> mapSourceRecIdTargetRecord = new map<String,Sobject>();
                mapSourceRecIdTargetRecord = mapAliasNameSourceRecIdTargetObject.get(HeaderLayout.SVMXC__Object_Name__c);
                if(mapSourceRecIdTargetRecord.size() > 0)
                {
                    for(String str : mapSourceRecIdTargetRecord.keyset())
                    {
                        if(Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL')
                            PageHeader.sourceRecordId  = str;
                        HdrRecords.add(mapSourceRecIdTargetRecord.get(str));
                    }
                }
            }
            else if(TargetRecMap.size() > 0 && HeaderLayout.SVMXC__Object_Name__c != null  && TargetRecMap.containskey(HeaderLayout.SVMXC__Object_Name__c))
            {
                HdrRecords = TargetRecMap.get(HeaderLayout.SVMXC__Object_Name__c);
            }    
            else
            {
                if(RecId != null && RecId.length() > 0)
                {
                    String ExpId = '';
                    if(ProcessNodeObjects.size() > 0)
                    {
                        for(SVMXC__ServiceMax_Processes__c Pro : ProcessNodeObjects)
                        {
                            if(Pro.SVMXC__Type__c.touppercase() == 'TARGET')
                            {
                                if(Pro.SVMXC__Submodule__c != null)
                                    ExpId = Pro.SVMXC__Submodule__c;
                            }
                        }
                        if(ExpId != null && ExpId.length() > 0)
                        {
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            SVMXC__ServiceMax_Processes__c exp = [select id,SVMXC__Parent_Error_Msg__c from SVMXC__ServiceMax_Processes__c where id =: ExpId];
                            if(exp != null && exp.SVMXC__Parent_Error_Msg__c != null)
                            {
                                SFMResponse.success = false;
                                SFMResponse.message = exp.SVMXC__Parent_Error_Msg__c; 
                            }
                            else
                            {   
                                SFMResponse.success = false;
                                //SFMResponse.message = 'Header Expresssion is not qualified';
                                SFMResponse.message = system.Label.SFM001_TAG158;
                            }
                        }
                    }            
                    PageResponseUI.response = SFMResponse;
                    system.debug('PageResponseUI'+PageResponseUI);
                    return PageResponseUI;
                }    
            }           
            
            system.debug('HdrRecords'+HdrRecords);
            
            //Get the Event for Header Layout
            if(HeaderLayout.id != null)
            {
                //log.setlog('QUERY_TEXT', 'Retrieving the pageevents for the pagelayout');
                //Added SVMXC__Code_Snippet__r.SVMXC__SM_Snippet_Version__c in the SOQL for the task BAC-4806
                HdrPageEvents = [Select SVMXC__Code_Snippet__c, SVMXC__Code_Snippet__r.SVMXC__SM_Snippet_Version__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout__c =: HeaderLayout.id];
                if(HdrPageEvents.size() > 0){
                  for(SVMXC__SFM_Event__c evt : HdrPageEvents){
                    if(evt.SVMXC__Event_Call_Type__c == null){
                      evt.SVMXC__Event_Call_Type__c = 'WEBSERVICE';
                    }
                  }
                }
            }   
            //Get the Fileds,Sections,Buttons for HeaderPageLayout..
            if(HeaderLayout.id != null)
            {
                //log.setlog('QUERY_TEXT', 'Retrieving the detailed pagelayou for the header pagelayout');
                if(Userinfo.isMultiCurrencyOrganization())
                {  
                    //Field 'SVMXC__SM_Checklist_Source_Field_API_Name__c' added in query for default checklist response
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    HdrDetail = [Select SVMXC__Field_Mapping__c, SVMXC__Show_In_iPad__c, SVMXC__Width__c, SVMXC__Section__r.SVMXC__No_Of_Columns__c, SVMXC__Show_In_Web__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Context_Source_Object__c, SVMXC__Title__c, SVMXC__IsStandard__c,SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c,SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c,   SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id,SVMXC__No_of_columns__c, SVMXC__Enable_Chatter__c, SVMXC__Control_Type__c, SVMXC__Maximum_Value__c, SVMXC__Minimum_Value__c, SVMXC__Use_For_SLA_Clock__c, SVMXC__Question__c, SVMXC__QuestionInfoJSON__c, SVMXC__SM_Description__c, SVMXC__SM_Help_URL__c,SVMXC__SM_Checklist_Source_Field_API_Name__c, (SELECT Id, SVMXC__Active__c, SVMXC__Process3__c, SVMXC__Rule_Type__c, SVMXC__SM_Section__c,SVMXC__SM_Target_Section__c,SVMXC__SM_Target_Section__r.SVMXC__Sequence__c, SVMXC__Question_Bank__c,SVMXC__Sequence__c FROM ServiceMax_Processes__r ) From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: HeaderLayout.id];
                }
                else
                {  
                    //Field 'SVMXC__SM_Checklist_Source_Field_API_Name__c' added in query for default checklist response
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    HdrDetail = [Select SVMXC__Field_Mapping__c, SVMXC__Show_In_iPad__c, SVMXC__Width__c, SVMXC__Section__r.SVMXC__No_Of_Columns__c, SVMXC__Show_In_Web__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Context_Source_Object__c, SVMXC__Title__c, SVMXC__IsStandard__c,SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c,SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c,   SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id,SVMXC__No_of_columns__c, SVMXC__Enable_Chatter__c, SVMXC__Control_Type__c, SVMXC__Maximum_Value__c, SVMXC__Minimum_Value__c, SVMXC__Use_For_SLA_Clock__c, SVMXC__Question__c, SVMXC__QuestionInfoJSON__c, SVMXC__SM_Description__c, SVMXC__SM_Help_URL__c,SVMXC__SM_Checklist_Source_Field_API_Name__c, (SELECT Id, SVMXC__Active__c, SVMXC__Process3__c, SVMXC__Rule_Type__c, SVMXC__SM_Section__c,SVMXC__SM_Target_Section__c,SVMXC__SM_Target_Section__r.SVMXC__Sequence__c,SVMXC__Question_Bank__c, SVMXC__Sequence__c FROM ServiceMax_Processes__r ) From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: HeaderLayout.id and SVMXC__Field_API_Name__c != 'CurrencyIsoCode'];
                }   
                system.debug('HdrDetail'+HdrDetail.size()+HdrDetail);
            }
            if(HdrDetail.size() > 0)
            {
                //log.setlog('LOOPING-Start', 'To set headerdetails id');
                /* Start - Logic to translate SFM Header Page Layout (Header Title & Header Section Title)  */
                if(HdrDetail != NULL && objTranslnUtil != NULL)
                    HdrDetail = objTranslnUtil.SVMX_GetPageLayoutDetailTranslation(HdrDetail);  
                /* End */
                
                for(Integer i = 0; i < HdrDetail.size(); i++)
                {
                    //log.setlog('LOOPING', 'To set headerdetails id for ' + HdrDetail[i].id);
                    HdrDetailIds.add(HdrDetail[i].id);
                }   
                //log.setlog('LOOPING-End', 'To set headerdetails id');
            }
            system.debug('HdrDetailIds'+HdrDetailIds);
            ////Get the Event for field & Button for header Layout  
            if(HdrDetailIds.size() > 0)
            {
                //Added SVMXC__ServiceMax_Custom_Action__c to SOQL for BAC-4329
                //log.setlog('QUERY_TEXT', 'Retrieving the Page Events for the detailed pagelayout');
                //Added SVMXC__Code_Snippet__r.SVMXC__SM_Snippet_Version__c in the SOQL for the task BAC-4806
                HdrFldBtnEvents = [Select SVMXC__Code_Snippet__c, SVMXC__Code_Snippet__r.SVMXC__SM_Snippet_Version__c, SVMXC__ServiceMax_Custom_Action__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : HdrDetailIds];
                if(HdrFldBtnEvents.size() > 0){
                  for(SVMXC__SFM_Event__c evt : HdrFldBtnEvents){
                    if(evt.SVMXC__Event_Call_Type__c == null){
                      evt.SVMXC__Event_Call_Type__c = 'WEBSERVICE';
                    }
                  }
                }
            }
            system.debug('HdrFldBtnEvents'+HdrFldBtnEvents);
           
            //Make a Differnt List for Button & Field Events
            if(HdrDetail.size() > 0 && HdrFldBtnEvents.size() > 0)
            {
                //log.setlog('LOOPING-Start', 'Outer loop for headerdetail layout to set buttonevents and fieldevents');
                for(Integer i = 0; i < HdrDetail.size(); i++)
                {
                    //log.setlog('LOOPING', 'Outer loop for headerdetail layout to set buttonevents and fieldevents for ' + HdrDetail[i]);
                    //log.setlog('LOOPING-Start', 'Inner loop for headerfield event to set buttonevents and fieldevents');
                    for(Integer j = 0; j < HdrFldBtnEvents.size(); j++)
                    {
                        //log.setlog('LOOPING', 'Inner loop for headerfield event to set buttonevents and fieldevents for ' + HdrFldBtnEvents[j]);
                        if(HdrDetail[i].id == HdrFldBtnEvents[j].SVMXC__Page_Layout_Detail__c)
                        {
                            if(HdrDetail[i].SVMXC__Detail_Type__c == 'Button')
                            {
                                ButtonEvents.add(HdrFldBtnEvents[j]);
                            }
                            if(HdrDetail[i].SVMXC__Detail_Type__c == 'Field' || HdrDetail[i].SVMXC__Detail_Type__c == 'Question')
                            {
                                FieldEvents.add(HdrFldBtnEvents[j]);
                            }
                        }
                    }
                    //log.setlog('LOOPING-End', 'Inner loop for headerfield event to set buttonevents and fieldevents');
                }
                //log.setlog('LOOPING-End', 'Outer loop for headerdetail layout to set buttonevents and fieldevents');
            }
            //Make a Differnt List for Button,Field & Section 
            set<String> setObject = new set<String>();
            if(HdrDetail.size() > 0)
            {
                //log.setlog('LOOPING-Start', 'Loop for headerdetail layout to set fields,sections,buttons');
                for(SVMXC__Page_Layout_Detail__c PLD : HdrDetail)
                {
                    //log.setlog('LOOPING', 'Loop for headerdetail layout to set fields,sections,buttons for ' + PLD);
                    if(PLD.SVMXC__Detail_Type__c == 'Field' || PLD.SVMXC__Detail_Type__c == 'Question')
                    {
                        if((strClientType == '' || strClientType != 'DESIGNER') && PLD.SVMXC__DataType__c.equalsIgnoreCase('reference') && PLD.SVMXC__Named_Search__c == null && PLD.SVMXC__Related_Object_Name__c != null){
                            setObject.add(PLD.SVMXC__Related_Object_Name__c);
                        }
                        else if (PLD.SVMXC__DataType__c.equalsIgnoreCase('reference') && PLD.SVMXC__Named_Search__c != null)
                            setLookupConfigId.add(PLD.SVMXC__Named_Search__c);
                        if( !PLD.SVMXC__DataType__c.equalsIgnoreCase('textarea') && PLD.SVMXC__Section__r.SVMXC__No_Of_Columns__c == 1){
                          PLD.SVMXC__Width__c = 50;
                        }
                        /*if((Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD') && PLD.SVMXC__Field_API_Name__c.touppercase() == 'WHATID'){
                            if(mapObjNameField.containskey(SourceObjName)){
                                PLD.SVMXC__Related_Object_Name__c = SourceObjName;
                                PLD.SVMXC__Related_Object_Name_Field__c = mapObjNameField.get(SourceObjName);
                            }
                        }*/
                        /////////////Added by Manish to support checklist type of process
                        if(PLD.SVMXC__Detail_Type__c == 'Question' && PLD.SVMXC__Question__c != null)
                            setQuestionIds.add(PLD.SVMXC__Question__c);
                        /////////////
                        fieldLst.add(PLD); 
                        if(PLD.SVMXC__Field_Mapping__c != null)
                            setFromFillId.add(PLD.SVMXC__Field_Mapping__c);   
                    }
                    if(PLD.SVMXC__Detail_Type__c == 'Section')
                    {
                        SectionLst.add(PLD);
                    }
                    if(PLD.SVMXC__Detail_Type__c == 'Button')
                    {
                        //Check whether show all buttons or not. If Designer show all. If Delivery show web. By default is Ipad so show only for iPad.
                        if(strClientType != null && strClientType.length() > 0 && strClientType == 'DESIGNER')
                            ButtondLst.add(PLD);
                        else if(strClientType != null && strClientType.length() > 0 && strClientType == 'WEB' && PLD.SVMXC__Show_In_Web__c) 
                            ButtondLst.add(PLD);
                        else if((strClientType == '' || strClientType == null) && PLD.SVMXC__Show_In_iPad__c)   
                            ButtondLst.add(PLD);
                    }
                }
                //log.setlog('LOOPING-End', 'Loop for headerdetail layout to set fields,sections,buttons');
                system.debug('fieldLst'+fieldLst);
            }
            //Get Mapping Fields For Header Form Fill.
            /*list<SVMXC__ServiceMax_Config_Data__c> lstMappingRecords = [select Id, SVMXC__MapID__c, SVMXC__Source_Field_Name__c, SVMXC__Preference_2__c, SVMXC__Preference_3__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c =: setFromFillId and RecordType.Name = 'Field Mapping'];
            map<Id,set<String>> mapMapIdFields = new map<String,set<String>>();
            map<Id,String> mapMapIdQueryField = new map<String,set<String>>();
            for(SVMXC__ServiceMax_Config_Data__c cg : lstMappingRecords){
                if(!mapMapIdFields.containskey(cg.SVMXC__MapID__c))
                    mapMapIdFields.put(cg.SVMXC__MapID__c,new set<String>());
                if(cg.SVMXC__Source_Field_Name__c != null)
                    mapMapIdFields.get(cg.SVMXC__MapID__c).add(cg.SVMXC__Source_Field_Name__c);
                if(cg.SVMXC__Preference_2__c != null)
                    mapMapIdFields.get(cg.SVMXC__MapID__c).add(cg.SVMXC__Preference_2__c);
                if(cg.SVMXC__Preference_3__c != null)
                    mapMapIdFields.get(cg.SVMXC__MapID__c).add(cg.SVMXC__Preference_3__c);          
            }
            system.debug('mapMapIdFields'+mapMapIdFields);*/
            //get lookup config defination for defalt object
            list<SVMXC__ServiceMax_Processes__c> lstdefaultLookupConfig;
            if(setObject.size() > 0)
            {
                system.debug('setObject'+setObject + '; Size = '+ setObject.size());
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstdefaultLookupConfig = [select Id, SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Named Search' and SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG' and SVMXC__IsDefault__c = true and SVMXC__Source_Object_Name__c IN : setObject];
                for(SVMXC__ServiceMax_Processes__c pro : lstdefaultLookupConfig){
                    if(setObject.contains(pro.SVMXC__Source_Object_Name__c) && ! mapObjectNameLookupConfigId.containskey(pro.SVMXC__Source_Object_Name__c)){
                        setObject.remove(pro.SVMXC__Source_Object_Name__c);
                        setLookupConfigId.add(pro.id);
                        mapObjectNameLookupConfigId.put(pro.SVMXC__Source_Object_Name__c,pro.id);
                    }
                }
            }
            //Get the Field Event Map
            if(fieldLst.size() > 0)
            {
                //log.setlog('LOOPING-Start', 'Outer Loop for fieldlist to set fieldevents');
                for(Integer i = 0; i < fieldLst.size(); i++)
                {
                    //log.setlog('LOOPING', 'Outer Loop for fieldlist to set fieldevents for ' + fieldLst[i].id);
                    List<SVMXC__SFM_Event__c> templst = new List<SVMXC__SFM_Event__c>();
                    //log.setlog('LOOPING-Start', 'Inner Loop for fieldlist to set fieldevents');
                    for(Integer j = 0; j < FieldEvents.size(); j++)
                    {
                
                        if(FieldEvents[j].SVMXC__Page_Layout_Detail__c == fieldLst[i].id)
                        {
                            templst.add(FieldEvents[j]);
                        }
                    }
                    //log.setlog('LOOPING-End', 'Inner Loop for fieldlist to set fieldevents');
                    FLdEventMap.put(fieldLst[i].id,templst);
                }
                //log.setlog('LOOPING-End', 'Outer Loop for fieldlist to set fieldevents');
            }   
            //Get the Button Event Map
            if(ButtondLst.size() > 0)
            {
                //log.setlog('LOOPING-Start', 'Outer Loop for ButtonList to set Buttonevents');
                for(Integer i = 0; i < ButtondLst.size(); i++)
                {
                    //log.setlog('LOOPING-Start', 'Outer Loop for ButtonList to set Buttonevents for ');
                    List<SVMXC__SFM_Event__c> templst = new List<SVMXC__SFM_Event__c>();
                    if(ButtonEvents.size() > 0)
                    {
                        //log.setlog('LOOPING-Start', 'Inner Loop for ButtonList to set Buttonevents' +ButtondLst[i].id);
                        for(Integer j = 0; j < ButtonEvents.size(); j++)
                        {
                            if(ButtonEvents[j].SVMXC__Page_Layout_Detail__c == ButtondLst[i].id)
                            {
                                templst.add(ButtonEvents[j]);
                            }
                        }
                        //log.setlog('LOOPING-End', 'Inner Loop for ButtonList to set Buttonevents');
                    }   
                    BtnEventMap.put(ButtondLst[i].id,templst);
                }
                //log.setlog('LOOPING-End', 'Outer Loop for ButtonList to set Buttonevents');
            }   
            //Make the SFM_UIField & SFM_UISection...
            system.debug('SectionLst'+SectionLst);
            system.debug('fieldLst'+fieldLst);
            
            ///////////////Added by Manish to support checklist type of process
            if(setQuestionIds != null && setQuestionIds.size() > 0){
                Map<String, List<SVMXC.SFM_WrapperDef.SFM_QuestionResponse>> mapQueIdAndResponseLst = new Map<String, List<SVMXC.SFM_WrapperDef.SFM_QuestionResponse>>();
                Set<String> setResponseSetId = new Set<String>();
                Map<String, String> mapSetIdVsValues = new Map<String, String>();
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<SVMXC__Question_Bank__c> lstQBank = [SELECT Id, SVMXC__QuestionID__c, SVMXC__Question__c, SVMXC__Response_Type__c, SVMXC__Precision__c, SVMXC__Scale__c, SVMXC__Length__c, SVMXC__QuestionJSON__c, SVMXC__Short_Name__c, SVMXC__Help_URL__c, SVMXC__Response_Set__c, SVMXC__Response_Set__r.SVMXC__Response_Set_Values__c,SVMXC__SM_Description_Required__c,SVMXC__SM_Show_In_Smart_Doc__c FROM SVMXC__Question_Bank__c WHERE Id IN : setQuestionIds];
                
                //Added by Jaysukh for default checklist response
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<SVMXC__SM_Default_Checklist_Response__c> lstCheckDefRes=[SELECT ID,SVMXC__SM_Default_Response__c,SVMXC__SM_Is_literal_Used__c,SVMXC__SM_Question__c from SVMXC__SM_Default_Checklist_Response__c where SVMXC__SM_Question__c IN : setQuestionIds];
                
                ////Added by Jaysukh for All default answer supported question(27 July 2017)
                List<string> typeOfQuestion = new List<string>{'Checkbox','Text','Picklist','Radio Button','Multi-select Picklist'};
                //added by Jaysukh for support translations for checklist default answer
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<SVMXC__SM_Default_Checklist_Response__c> lstAllSupportedTypesCheckDefRes = [SELECT ID,SVMXC__SM_Default_Response__c,SVMXC__SM_Is_literal_Used__c,SVMXC__SM_Question__c from SVMXC__SM_Default_Checklist_Response__c where SVMXC__SM_Question__r.SVMXC__Response_Type__c IN:typeOfQuestion and SVMXC__SM_Question__c IN : setQuestionIds ];
                Set<SVMXC__SM_Default_Checklist_Response__c> updatedDCRSet =  new Set<SVMXC__SM_Default_Checklist_Response__c>();
                updatedDCRSet.addAll(lstCheckDefRes);
                updatedDCRSet.removeAll(lstAllSupportedTypesCheckDefRes);
                if(lstAllSupportedTypesCheckDefRes !=null && objTranslnUtil != null)
                {
                   lstAllSupportedTypesCheckDefRes = objTranslnUtil.SVMX_GetQuestionDefaultAnswerTranslation(lstALlSupportedTypesCheckDefRes);
                }      
                updatedDCRSet.addAll(lstAllSupportedTypesCheckDefRes);
                List<SVMXC__SM_Default_Checklist_Response__c> lstDCR = new List<SVMXC__SM_Default_Checklist_Response__c>();
                lstDCR.addAll(updatedDCRSet);
                
                
                
                Map<Id,SVMXC__SM_Default_Checklist_Response__c> mapQueIdToDCRRecord = new Map<Id,SVMXC__SM_Default_Checklist_Response__c>();
                for(SVMXC__SM_Default_Checklist_Response__c dcRecord : lstDCR)
                {
                    mapQueIdToDCRRecord.put(dcRecord.SVMXC__SM_Question__c,dcRecord);
                }

                for(SVMXC__Question_Bank__c objQue: lstQBank){
                    if(objQue.SVMXC__Response_Set__c != null)
                        setResponseSetId.add(objQue.SVMXC__Response_Set__c);
                }
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<SVMXC__QB_Response_Set__c> lstResponseSet = [SELECT Id, SVMXC__Response_Set_Values__c FROM SVMXC__QB_Response_Set__c WHERE Id IN: setResponseSetId];
                
                //----Start----Added for the story BAC-3446 for sending master response values
                Map<String, String> mapMasterSetIdVsValues = new Map<String, String>();
                for(SVMXC__QB_Response_Set__c objRS: lstResponseSet)
                    mapMasterSetIdVsValues.put(objRS.Id, objRS.SVMXC__Response_Set_Values__c);
                //----End----Added for the story BAC-3446 for sending master response values
                
                /* Start - Logic to translate Response Set */
                if(lstResponseSet != NULL && objTranslnUtil != NULL)
                    lstResponseSet = objTranslnUtil.SVMX_GetQuestionResponseSetTranslation(lstResponseSet);  
                /* End */
                
                /* Start - Logic to translate Question Text */
                if(lstQBank != NULL && objTranslnUtil != NULL)
                    lstQBank = objTranslnUtil.SVMX_GetQuestionTranslation(lstQBank);  
                /* End */
                
                for(SVMXC__QB_Response_Set__c objRS: lstResponseSet)
                    mapSetIdVsValues.put(objRS.Id, objRS.SVMXC__Response_Set_Values__c);
                
                Set<String> tempQueID = new Set<String>();
                for(SVMXC__Question_Bank__c objQuesBank : lstQBank){
                    if(objQuesBank.SVMXC__Response_Set__c != null && objQuesBank.SVMXC__Response_Set__r.SVMXC__Response_Set_Values__c != ''){
                        mapQueIdAndResponseLst.put(objQuesBank.Id, new List<SVMXC.SFM_WrapperDef.SFM_QuestionResponse>());
                        List<String> lstResponseValues = new List<String>();
                        //Added for the story BAC-3446. Exit criteria was not working because client didn't have master value of the response. Now we are sending master value also to the client. Now for this to work client also needs a change.
                        List<String> lstMasterResponseValues = new List<String>();
                        if(mapSetIdVsValues != null && mapSetIdVsValues.size() > 0 && mapSetIdVsValues.containsKey(objQuesBank.SVMXC__Response_Set__c)){
                            lstResponseValues = mapSetIdVsValues.get(objQuesBank.SVMXC__Response_Set__c).split(';');
                            lstMasterResponseValues = mapMasterSetIdVsValues.get(objQuesBank.SVMXC__Response_Set__c).split(';');//Added for the story BAC-3446
                        }
                        Integer intSeq = 1;
                        //for(String strValue : lstResponseValues){//Commented for the story BAC-3446
                        for(Integer i=0; i<lstResponseValues.size(); i++){//Added for the story BAC-3446
                            SVMXC.SFM_WrapperDef.SFM_QuestionResponse objQuestionResponse = new SVMXC.SFM_WrapperDef.SFM_QuestionResponse();
                            objQuestionResponse.questionID = objQuesBank.Id;
                            //objQuestionResponse.response = strValue;//Commented for the story BAC-3446
                            objQuestionResponse.response = lstResponseValues[i];//Added for the story BAC-3446
                            objQuestionResponse.masterResponse = lstMasterResponseValues[i];//Added for the story BAC-3446
                            objQuestionResponse.sequence = intSeq;
                            mapQueIdAndResponseLst.get(objQuesBank.Id).add(objQuestionResponse);
                            intSeq++;
                        }
                    }
                    else if(objQuesBank.SVMXC__Response_Set__c == null && (objQuesBank.SVMXC__Response_Type__c == 'Checkbox' || objQuesBank.SVMXC__Response_Type__c == 'Picklist' || objQuesBank.SVMXC__Response_Type__c == 'Multi-select Picklist' || objQuesBank.SVMXC__Response_Type__c == 'Radio Button')){
                        tempQueID.add(objQuesBank.id);
                    }
                }
                
                if(tempQueID != null && tempQueID.size() > 0){
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    List<SVMXC__QB_Response_Options__c> lstQBResponse = [SELECT Id, SVMXC__Question_Bank__c, SVMXC__Response__c, SVMXC__Sequence__c FROM SVMXC__QB_Response_Options__c WHERE SVMXC__Question_Bank__c IN : tempQueID];
                    
                    // Start - Logic to translate Question Response Text
                    if(lstQBResponse != NULL && objTranslnUtil != NULL)
                        lstQBResponse = objTranslnUtil.SVMX_GetQuestionResponseTranslation(lstQBResponse);  
                    // End
                    
                    for(SVMXC__QB_Response_Options__c objQBRes : lstQBResponse){
                        if(!mapQueIdAndResponseLst.containsKey(objQBRes.SVMXC__Question_Bank__c))
                            mapQueIdAndResponseLst.put(objQBRes.SVMXC__Question_Bank__c, new List<SVMXC.SFM_WrapperDef.SFM_QuestionResponse>());
                        SVMXC.SFM_WrapperDef.SFM_QuestionResponse objQuestionResponse = new SVMXC.SFM_WrapperDef.SFM_QuestionResponse();
                        objQuestionResponse.questionID = objQBRes.SVMXC__Question_Bank__c;
                        objQuestionResponse.response = objQBRes.SVMXC__Response__c;
                        objQuestionResponse.sequence = objQBRes.SVMXC__Sequence__c;
                        mapQueIdAndResponseLst.get(objQBRes.SVMXC__Question_Bank__c).add(objQuestionResponse);
                    }
                }
                
                for(SVMXC__Question_Bank__c objQB : lstQBank){
                    SVMXC.SFM_WrapperDef.SFM_Question objQuestion = new SVMXC.SFM_WrapperDef.SFM_Question();
                    //added for checklist deafult response
                    SVMXC__SM_Default_Checklist_Response__c dcrObject;
                    dcrObject = mapQueIdToDCRRecord.containsKey(objQB.id) ? mapQueIdToDCRRecord.get(objQB.id) : null;
                    
                    objQuestion.questionID = objQB.SVMXC__QuestionID__c;
                    objQuestion.question = objQB.SVMXC__Question__c;
                    objQuestion.responseType = objQB.SVMXC__Response_Type__c;
                    objQuestion.precision = objQB.SVMXC__Precision__c;
                    objQuestion.scale = objQB.SVMXC__Scale__c;
                    objQuestion.length = objQB.SVMXC__Length__c;
                    objQuestion.questionJSON = objQB.SVMXC__QuestionJSON__c;
                    objQuestion.shortname = objQB.SVMXC__Short_Name__c;
                    objQuestion.helpURL = objQB.SVMXC__Help_URL__c;
                    objQuestion.ShowInSmartDoc = objQB.SVMXC__SM_Show_In_Smart_Doc__c;
                    objQuestion.descriptionRequired = objQB.SVMXC__SM_Description_Required__c;
                    if(!mapQueIdAndResponseLst.containsKey(objQB.id)){
                        List<SVMXC.SFM_WrapperDef.SFM_QuestionResponse> lstTemp = new List<SVMXC.SFM_WrapperDef.SFM_QuestionResponse>();
                        SVMXC.SFM_WrapperDef.SFM_QuestionResponse objQuestionResponse = new SVMXC.SFM_WrapperDef.SFM_QuestionResponse();
                        objQuestionResponse.questionID = objQB.SVMXC__QuestionID__c;
                        objQuestionResponse.response = '';
                        objQuestionResponse.active = true;
                        objQuestionResponse.sequence = 1;
                        lstTemp.add(objQuestionResponse);
                        //mapQuesIdQuesInfoObject.put(objQB.id, new SVMXC.SFM_WrapperDef.SFM_QuestionInfo(objQuestion, lstTemp));
                         mapQuesIdQuesInfoObject.put(objQB.id,new SVMXC.SFM_WrapperDef.SFM_QuestionInfo(objQuestion, lstTemp,dcrObject));
                    }
                    else if(mapQueIdAndResponseLst.get(objQB.id) != null)
                        //mapQuesIdQuesInfoObject.put(objQB.id, new SVMXC.SFM_WrapperDef.SFM_QuestionInfo(objQuestion, mapQueIdAndResponseLst.get(objQB.id)));
                        mapQuesIdQuesInfoObject.put(objQB.id, new SVMXC.SFM_WrapperDef.SFM_QuestionInfo(objQuestion, mapQueIdAndResponseLst.get(objQB.id),dcrObject));
                }
            }/////////////Added by Manish to support checklist type of process
            
            if(SectionLst.size() > 0)
            {
                //Get Field Describe of Header Object 
                map<String,Schema.SObjectField> mapHeaderObjFieldDesc = new map<String,Schema.SObjectField>();
                if(mapAllFieldDescribe.containskey(TargetObjName))
                    mapHeaderObjFieldDesc = mapAllFieldDescribe.get(TargetObjName);
                //log.setlog('LOOPING-Start', 'Outer Loop for Layouts SectionList to add lookupconfig and fields');
                for(Integer i = 0;i< SectionLst.size();i++)
                {
                    SVMXC.SFM_WrapperDef.SFM_UISection  SectionUI = new SVMXC.SFM_WrapperDef.SFM_UISection();
                    SectionUI.sectionDetail = SectionLst[i];
                    List<SVMXC.SFM_WrapperDef.SFM_UIField> HdrFields = new List<SVMXC.SFM_WrapperDef.SFM_UIField>();
                    //log.setlog('LOOPING-Start', 'Inner Loop for Layouts SectionList to add lookupconfig and fields');
                    if(fieldLst.size() > 0)
                    {
                        for(Integer j = 0; j < fieldLst.size();j++)
                        {
                            if(SectionLst[i].id == fieldLst[j].SVMXC__Section__c) 
                            {
                                //system.debug('Enterd in..');
                                SVMXC.SFM_WrapperDef.SFM_UIField FieldUI = new SVMXC.SFM_WrapperDef.SFM_UIField();
                                if(fieldLst[j].SVMXC__DataType__c.equalsIgnoreCase('reference') && fieldLst[j].SVMXC__Named_Search__c == null && fieldLst[j].SVMXC__Related_Object_Name__c != null)
                                {
                                    if(mapObjectNameLookupConfigId.containskey(fieldLst[j].SVMXC__Related_Object_Name__c))
                                        fieldLst[j].SVMXC__Named_Search__c = mapObjectNameLookupConfigId.get(fieldLst[j].SVMXC__Related_Object_Name__c);
                                    else 
                                        mapObjectNameFieldName.put(fieldLst[j].SVMXC__Related_Object_Name__c,fieldLst[j].SVMXC__Related_Object_Name_Field__c);    
                                }                            
                                FieldUI.fieldDetail = fieldLst[j];
                                
                                //////////////Added by Manish to support checklist type of process
                                if(fieldLst[j].SVMXC__Detail_Type__c == 'Question' && fieldLst[j].SVMXC__Question__c != null && mapQuesIdQuesInfoObject != null && mapQuesIdQuesInfoObject.size()>0 && mapQuesIdQuesInfoObject.ContainsKey(fieldLst[j].SVMXC__Question__c)){
                                    FieldUI.fieldDetail.SVMXC__QuestionInfoJSON__c = JSON.serialize(mapQuesIdQuesInfoObject.get(fieldLst[j].SVMXC__Question__c));
                                }/////////////Added by Manish to support checklist type of process
                                
                                SVMXC.SFM_WrapperDef.SFM_BubbleWrapper BubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper();
                                if(HdrRecords.size() > 0)
                                {
                                    //system.debug('HdrRecords are there');
                                    String DefaultValue = '';
                                    if(fieldLst[j].SVMXC__Field_API_Name__c != null)
                                    {
                                        DefaultValue = String.valueof(HdrRecords[0].get(fieldLst[j].SVMXC__Field_API_Name__c));
                                        BubbleWrapper.fieldapiname = fieldLst[j].SVMXC__Field_API_Name__c;
                                        //Convert Audit DateTime fields into user Time Zone   
                                        /*if(fieldLst[j].SVMXC__Field_API_Name__c != null && fieldLst[j].SVMXC__DataType__c != null && fieldLst[j].SVMXC__DataType__c.touppercase() == 'DATETIME'  && mapHeaderObjFieldDesc.containskey(fieldLst[j].SVMXC__Field_API_Name__c) && DefaultValue != null && DefaultValue.length() > 0)
                                        {
                                            Schema.Describefieldresult f = mapHeaderObjFieldDesc.get(fieldLst[j].SVMXC__Field_API_Name__c).getDescribe();
                                            if( !f.isCreateable() && !f.isUpdateable())
                                            {
                                                String dat1 = String.valueof(datetime.valueof(HdrRecords[0].get(fieldLst[j].SVMXC__Field_API_Name__c)));
                                                //(datetime.valueof(HdrRecords[0].get(fieldLst[j].SVMXC__Field_API_Name__c))).format('yyyy-MM-dd hh:mm:ss');
                                                //HdrRecords[0].put(fieldLst[j].SVMXC__Field_API_Name__c,datetime.valueofgmt(dat1));
                                                //system.debug('Field Name : '+fieldLst[j].SVMXC__Field_API_Name__c +' ' +dat1+ ' '+datetime.valueofgmt(dat1));
                                                SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(dat1,dat1);
                                                BubbleWrapper.fieldvalue = strmap;
                                            }   
                                        }*/
                                        if(fieldLst[j].SVMXC__Related_Object_Name__c != null && fieldLst[j].SVMXC__DataType__c.touppercase() == 'REFERENCE' && DefaultValue != null && DefaultValue.length() > 0)
                                        {
                                            //system.debug('Called REFERENCE');
                                            //system.debug('Called REFERENCE'+fieldLst[j].SVMXC__Related_Object_Name__c+fieldLst[j].SVMXC__Related_Object_Name_Field__c);
                                            String key = DefaultValue;
                                            map<String,string> valuemap = new map<String,string>(); 
                                            if(fieldLst[j].SVMXC__Named_Search__c != null && fieldLst[j].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != null && fieldLst[j].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != fieldLst[j].SVMXC__Related_Object_Name_Field__c)
                                            {
                                                String FieldName = fieldLst[j].SVMXC__Related_Object_Name_Field__c + ','+ fieldLst[j].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c;
                                                valuemap = SFMUtils.GetRelationshipData(new set<String>{DefaultValue},fieldLst[j].SVMXC__Related_Object_Name__c,FieldName);
                                            }
                                            else
                                            {
                                                valuemap = SFMUtils.GetRelationshipData(new set<String>{DefaultValue},fieldLst[j].SVMXC__Related_Object_Name__c,fieldLst[j].SVMXC__Related_Object_Name_Field__c);
                                            }   
                                            //system.debug('Called REFERENCE'+value);
                                            SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                                            strmap.key = key;
                                            if(valuemap.containskey(key))
                                                strmap.value = valuemap.get(key);
                                            BubbleWrapper.fieldvalue = strmap;
                                            //Now start making the bubbleinfo for the Reference fields...
                                           /* if(fieldLst[j].SVMXC__Named_Search__c != null &&  fieldLst[j].SVMXC__Related_Object_Name__c != null)
                                                BubbleWrapper.bubbleinfo = SFMUtils.getBubbleinfo(DefaultValue,fieldLst[j].SVMXC__Named_Search__c,fieldLst[j].SVMXC__Related_Object_Name__c);
                                            else if(fieldLst[j].SVMXC__Named_Search__c == null && fieldLst[j].SVMXC__Related_Object_Name__c != null)    
                                                BubbleWrapper.bubbleinfo = SFMUtils.getBubbleinfo(DefaultValue,null,fieldLst[j].SVMXC__Related_Object_Name__c);*/ 
                                        }
                                        else 
                                        {
                                            BubbleWrapper.fieldvalue.key = DefaultValue; 
                                            BubbleWrapper.fieldvalue.value = DefaultValue;
                                        }     
                                    }   
                                }
                                system.debug('BubbleWrapper'+BubbleWrapper);
                                FieldUI.bubbleinfo = BubbleWrapper;
                                //add Field Events if Exsists 
                                if(FLdEventMap.containskey(fieldLst[j].id) && FLdEventMap.get(fieldLst[j].id) != null)
                                {
                                    FieldUI.fieldEvents = FLdEventMap.get(fieldLst[j].id);
                                }
                                HdrFields.add(FieldUI);
                                SectionUI.fields = HdrFields;
                            }
                        }
                    }
                    //log.setlog('LOOPING-End', 'Inner Loop for Layouts SectionList to add lookupconfig and fields');
                    Sections.add(SectionUI);
                }
                system.debug('Sections'+Sections);
                //log.setlog('LOOPING-End', 'Outer Loop for Layouts SectionList to add lookupconfig and fields');
            }   
            //Make the SFM_UIButton.... 
            if(ButtondLst.size() > 0)
            {
                //log.setlog('LOOPING-Start', 'Loop for ButtonsList to add to ButtonUI');
                for(Integer i = 0;i<ButtondLst.size();i++)
                {
                    //log.setlog('LOOPING', 'Loop for ButtonsList to add to ButtonUI for'+ButtondLst[i].id);
                    List<SVMXC__SFM_Event__c> ButtonEvents1 = new List<SVMXC__SFM_Event__c>();
                    SVMXC.SFM_WrapperDef.SFM_UIButton  ButtonUI = new SVMXC.SFM_WrapperDef.SFM_UIButton(ButtondLst[i],ButtonEvents1);
                    //Add Button Event if Exsists
                    if(BtnEventMap.containskey(ButtondLst[i].id) && BtnEventMap.get(ButtondLst[i].id) != null)
                    {
                        ButtonUI.buttonEvents = BtnEventMap.get(ButtondLst[i].id); 
                    }
                    Buttons.add(ButtonUI);      
                }
                //log.setlog('LOOPING-End', 'Loop for ButtonsList to add to ButtonUI');
            }   
            //Make the SFM_HeaderLayout....
            PageHeader.enableAttachment = enableAttachment;
            PageHeader.headerLayout = HeaderLayout;
            PageHeader.sections = Sections;
            PageHeader.buttons = Buttons;
            PageHeader.pageEvents = HdrPageEvents;
            if(HdrRecords != null && HdrRecords.size() > 0)
                PageHeader.hdrData = HdrRecords[0];
            if(HeaderLayout != null && HeaderLayout.id != null)
                PageHeader.hdrLayoutId  =  HeaderLayout.id;  
            //system.debug('HdrRecords'+HdrRecords[0]);
            system.debug('PageHeader'+PageHeader);
            //Start Processing for PageDetail 
            List<SVMXC__Page_Layout__c> RelatedLayoutLst = new List<SVMXC__Page_Layout__c>();
            Map<Id,SVMXC__Page_Layout__c> RelatedLayoutMap = new Map<Id,SVMXC__Page_Layout__c>();
            set<id> RelatedLayoutID = new set<ID>();
            //Get the Related Layout 
            if(HeaderLayout.id != null)
            {
                //log.setlog('QUERY_TEXT', 'Getting the Related layout');
                /* Start - Logic to translate SFM Header Page Layout for Detail's */
                if(objTranslnUtil != NULL) //Added SVMXC__No_Of_Columns__c field in the SOQL for the task BAC-4798
                    RelatedLayoutMap.putall(objTranslnUtil.SVMX_GetPageLayoutTranslation([Select SVMXC__No_Of_Columns__c, SystemModstamp, SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c,  SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c  where SVMXC__Header_Page_Layout__c =: HeaderLayout.id and SVMXC__Type__c = 'Detail']));
                /* End */
                else //Added SVMXC__No_Of_Columns__c field in the SOQL for the task BAC-4798
                    RelatedLayoutMap.putall([Select SVMXC__No_Of_Columns__c, SystemModstamp, SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c,  SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c  where SVMXC__Header_Page_Layout__c =: HeaderLayout.id and SVMXC__Type__c = 'Detail']);
            }
            system.debug('RelatedLayoutMap'+RelatedLayoutMap.size()+RelatedLayoutMap);
            if(RelatedLayoutMap.size() > 0)
            {
                //log.setlog('LOOPING-Start', 'Looping through the RelatedLayoutMap to set the relatedlist ids');
                for(String s :RelatedLayoutMap.keyset())
                {
                    //log.setlog('LOOPING', 'Looping through the RelatedLayoutMap to set the relatedlist ids for'+s);
                    if(mapPageLayoutIdAliasName.containskey(s))
                        RelatedLayoutMap.get(s).SVMXC__Page_Layout_ID__c = mapPageLayoutIdAliasName.get(s);
                    RelatedLayoutLst.add(RelatedLayoutMap.get(s));
                    RelatedLayoutID.add(s);
                }
                //log.setlog('LOOPING-End', 'Getting the Related layout');
            }
            //Get the Detail PageEvent
            Map<String,List<SVMXC__SFM_Event__c>> RelatedLayoutEventMap = new  Map<String,List<SVMXC__SFM_Event__c>>();
            List<SVMXC__SFM_Event__c> RelatedLayoutEventlst = new List<SVMXC__SFM_Event__c>(); 
            //Added SVMXC__ServiceMax_Custom_Action__c to SOQL for BAC-4329
        if(RelatedLayoutID.size() > 0) //Added SVMXC__Code_Snippet__r.SVMXC__SM_Snippet_Version__c in the SOQL for the task BAC-4806
                RelatedLayoutEventlst.addall([Select SVMXC__Code_Snippet__c, SVMXC__Code_Snippet__r.SVMXC__SM_Snippet_Version__c, SVMXC__ServiceMax_Custom_Action__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout__c IN : RelatedLayoutID]);
            if(RelatedLayoutEventlst.size() > 0){
              for(SVMXC__SFM_Event__c evt : RelatedLayoutEventlst){
                if(evt.SVMXC__Event_Call_Type__c == null){
                  evt.SVMXC__Event_Call_Type__c = 'WEBSERVICE';
                }
                }
            }
            if(RelatedLayoutLst.size() > 0 && RelatedLayoutEventlst.size() > 0)
            {
                for(Integer i = 0;i<RelatedLayoutLst.size();i++)
                {
                     List<SVMXC__SFM_Event__c> templst = new List<SVMXC__SFM_Event__c>();
                     for(Integer j = 0;j<RelatedLayoutEventlst.size();j++)
                     {
                        if(RelatedLayoutLst[i].id == RelatedLayoutEventlst[j].SVMXC__Page_Layout__c)
                        {
                            templst.add(RelatedLayoutEventlst[j]);
                        }
                        RelatedLayoutEventMap.put(RelatedLayoutLst[i].id,templst);
                     }
                }
            }
            system.debug('RelatedLayoutEventMap'+RelatedLayoutEventMap);
            //Get the sobject Data for the detail layout 
            map<String,List<Sobject>> DetailSobjectRecsMap = new map<String,List<Sobject>>(); 
            if(RelatedLayoutLst.size() > 0 && TargetRecMap.size() > 0)
            {
                for(Integer i = 0;i<RelatedLayoutLst.size();i++)
                {
                    if(RelatedLayoutLst[i].id != null )
                    {
                        String s = String.valueof(RelatedLayoutLst[i].id);
                        s = s.substring(0,15);
                        if(TargetRecMap.containskey(s))
                            DetailSobjectRecsMap.put(s,TargetRecMap.get(s));
                    }
                }
            }
            system.debug('DetailSobjectRecsMap'+DetailSobjectRecsMap);
            //Get the Buttons & Fields for Related Layout & Extended layout(means the SVMXC__Page_Layout_Detail__c object's data)....
            map<string,SVMXC__Page_Layout_Detail__c> AllRelatedfldsbtnsMap = new map<string,SVMXC__Page_Layout_Detail__c> ();
            List<SVMXC__Page_Layout_Detail__c>  AllRelatedfldsbtns = new List<SVMXC__Page_Layout_Detail__c>();
            Map<Id,SVMXC__Page_Layout_Detail__c> RelatedButtonsMap = new Map<Id,SVMXC__Page_Layout_Detail__c>();
            Map<Id,SVMXC__Page_Layout_Detail__c> RelatedFieldsMap = new Map<Id,SVMXC__Page_Layout_Detail__c>();
            List<SVMXC__Page_Layout_Detail__c> RelatedFieldLst = new List<SVMXC__Page_Layout_Detail__c>();
            List<SVMXC__Page_Layout_Detail__c> RelatedButtonLst = new List<SVMXC__Page_Layout_Detail__c>();
            set<ID> RelatedFldId = new set<ID>(); 
            set<ID> RelatedBtnId = new set<ID>();
            if(RelatedLayoutID.size() > 0)
            {
                //log.setlog('QUERY_TEXT', 'Getting the PageLayoutDetail for the Related');
                if(Userinfo.isMultiCurrencyOrganization())
                    AllRelatedfldsbtnsMap.putall([Select SVMXC__Field_Mapping__c, SVMXC__Show_In_iPad__c, SVMXC__Show_In_Web__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Context_Source_Object__c, SVMXC__IsStandard__c,SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id ,SVMXC__No_of_columns__c, SVMXC__Enable_Chatter__c, SVMXC__Control_Type__c, SVMXC__Maximum_Value__c, SVMXC__Minimum_Value__c, SVMXC__Use_For_SLA_Clock__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN : RelatedLayoutID]);
                else    
                    AllRelatedfldsbtnsMap.putall([Select SVMXC__Field_Mapping__c, SVMXC__Show_In_iPad__c, SVMXC__Show_In_Web__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Context_Source_Object__c, SVMXC__IsStandard__c,SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id ,SVMXC__No_of_columns__c, SVMXC__Enable_Chatter__c, SVMXC__Control_Type__c, SVMXC__Maximum_Value__c, SVMXC__Minimum_Value__c, SVMXC__Use_For_SLA_Clock__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN : RelatedLayoutID and SVMXC__Field_API_Name__c != 'CurrencyIsoCode']);
            }
            system.debug('AllRelatedfldsbtnsMap'+AllRelatedfldsbtnsMap);
            if(AllRelatedfldsbtnsMap.size() > 0)
            {
                AllRelatedfldsbtns.addall(AllRelatedfldsbtnsMap.values());
            }
            if(AllRelatedfldsbtns.size() > 0)
            {
                //log.setlog('LOOPING-Start', 'Looping through the Relatedfields to categorize the field types and the button types');
                setObject.clear();
                for(Integer i = 0; i < AllRelatedfldsbtns.size(); i++)
                {
                    //log.setlog('LOOPING-Start', 'Looping through the Relatedfields to categorize the field types and the button types for '+ AllRelatedfldsbtns[i]);
                    if(AllRelatedfldsbtns[i].SVMXC__Detail_Type__c == 'Field')
                    {
                       if((strClientType == '' || strClientType != 'DESIGNER') && AllRelatedfldsbtns[i].SVMXC__DataType__c.equalsIgnoreCase('reference') && AllRelatedfldsbtns[i].SVMXC__Named_Search__c == null && AllRelatedfldsbtns[i].SVMXC__Related_Object_Name__c != null){
                            setObject.add(AllRelatedfldsbtns[i].SVMXC__Related_Object_Name__c);
                        }
                        else if (AllRelatedfldsbtns[i].SVMXC__DataType__c.equalsIgnoreCase('reference') && AllRelatedfldsbtns[i].SVMXC__Named_Search__c != null)
                            setLookupConfigId.add(AllRelatedfldsbtns[i].SVMXC__Named_Search__c);
                       /*if((Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD') && AllRelatedfldsbtns[i].SVMXC__Field_API_Name__c.touppercase() == 'WHATID'){
                            if(mapAliasNameObjectName.containskey(AllRelatedfldsbtns[i].SVMXC__Page_Layout__c)){
                                String strObjName = mapAliasNameObjectName.get(AllRelatedfldsbtns[i].SVMXC__Page_Layout__c);
                                if(mapObjNameField.containskey(strObjName)){
                                    AllRelatedfldsbtns[i].SVMXC__Related_Object_Name__c = strObjName;
                                    AllRelatedfldsbtns[i].SVMXC__Related_Object_Name_Field__c = mapObjNameField.get(strObjName);
                                } 
                            }   
                        }*/
                        RelatedFieldsMap.put(AllRelatedfldsbtns[i].id,AllRelatedfldsbtns[i]);
                        RelatedFieldLst.add(AllRelatedfldsbtns[i]);
                        RelatedFldId.add(AllRelatedfldsbtns[i].id);
                        if(AllRelatedfldsbtns[i].SVMXC__Field_Mapping__c != null)
                            setFromFillId.add(AllRelatedfldsbtns[i].SVMXC__Field_Mapping__c);
                    }
                    if(AllRelatedfldsbtns[i].SVMXC__Detail_Type__c == 'Button')
                    {
                        RelatedButtonsMap.put(AllRelatedfldsbtns[i].id,AllRelatedfldsbtns[i]);
                        RelatedButtonLst.add(AllRelatedfldsbtns[i]);
                        RelatedBtnId.add(AllRelatedfldsbtns[i].id);
                    }
                }
            } 
            system.debug('RelatedFieldsMap'+RelatedFieldsMap);
            //Get Default lookup config for details 
            if(setObject.size() > 0)
            {
                system.debug('setObject'+setObject + '; Size = '+ setObject.size());
                lstdefaultLookupConfig = new list<SVMXC__ServiceMax_Processes__c>();
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstdefaultLookupConfig = [select Id, SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Named Search' and SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG' and SVMXC__IsDefault__c = true and SVMXC__Source_Object_Name__c IN : setObject];
                for(SVMXC__ServiceMax_Processes__c pro : lstdefaultLookupConfig){
                    if(setObject.contains(pro.SVMXC__Source_Object_Name__c) && ! mapObjectNameLookupConfigId.containskey(pro.SVMXC__Source_Object_Name__c)){
                        setObject.remove(pro.SVMXC__Source_Object_Name__c);
                        setLookupConfigId.add(pro.id);
                        mapObjectNameLookupConfigId.put(pro.SVMXC__Source_Object_Name__c,pro.id);
                    }
                }
            }
            
            //Get the Events for Related Button...
            Map<Id,List<SVMXC__SFM_Event__c>>  RelatedBtnEventMap = new  Map<Id,List<SVMXC__SFM_Event__c>>();
            List<SVMXC__SFM_Event__c> RelatedBtnEventlst = new List<SVMXC__SFM_Event__c>();
            //log.setlog('QUERY-TEXT', 'Getting all the events from the pagelayout for the related ones'); 
            //Added SVMXC__ServiceMax_Custom_Action__c to SOQL for BAC-4329
            //Added SVMXC__Code_Snippet__r.SVMXC__SM_Snippet_Version__c in the SOQL for the task BAC-4806
            RelatedBtnEventlst.addall([Select SVMXC__Code_Snippet__c, SVMXC__Code_Snippet__r.SVMXC__SM_Snippet_Version__c, SVMXC__ServiceMax_Custom_Action__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : RelatedBtnId]);
            if(RelatedBtnEventlst.size() > 0){
              for(SVMXC__SFM_Event__c evt : RelatedLayoutEventlst){
                if(evt.SVMXC__Event_Call_Type__c == null){
                  evt.SVMXC__Event_Call_Type__c = 'WEBSERVICE';
                }
                }
            }
            if(RelatedButtonLst.size() > 0)
            {
                //log.setlog('LOOPING-Start', 'Outer Loop for looping through RelatedButtonList to added to pagedetail');
                for(Integer i = 0; i < RelatedButtonLst.size(); i++)
                {
                    //log.setlog('LOOPING', 'Outer Loop for looping through RelatedButtonList to added to pagedetail for'+RelatedButtonLst[i].id);
                    List<SVMXC__SFM_Event__c> templst = new List<SVMXC__SFM_Event__c>();
                    if(RelatedBtnEventlst.size() > 0)
                    {
                        //log.setlog('LOOPING-Start', 'Inner Loop for looping through RelatedButtonEventList  to add to templst');
                        for(Integer j = 0; j < RelatedBtnEventlst.size(); j++)
                        {
                            if(RelatedBtnEventlst[j].SVMXC__Page_Layout_Detail__c == RelatedButtonLst[i].id)
                            {
                                templst.add(RelatedBtnEventlst[j]);
                            }
                        }
                        //log.setlog('LOOPING-End', 'Inner Loop for looping through RelatedButtonEventList to add to templst');
                    }   
                    RelatedBtnEventMap.put(RelatedButtonLst[i].id,templst);
                }
                //log.setlog('LOOPING-End', 'Outer Loop for looping through RelatedButtonList to added to pagedetail');
            }
            //map of Related button id(SVMXC__Page_Layout_Detail__c) and List<SFM_ButtonUI> for PAMX_PageDetail...
            Map<String,List<SVMXC.SFM_WrapperDef.SFM_UIButton>> RelatedBtnUIMap = new Map<String,List<SVMXC.SFM_WrapperDef.SFM_UIButton>>();
            //log.setlog('LOOPING-Start', 'looping through RelatedButtonsMap to build RelatedBtnUI');
            for(string s1: RelatedLayoutMap.keyset())
            {
                //Create the SFM_ButtonUI wrapper for Related Layout..
                List<SVMXC.SFM_WrapperDef.SFM_UIButton> RelatedBtnUI = new List<SVMXC.SFM_WrapperDef.SFM_UIButton>();
                for(String s : RelatedButtonsMap.keySet())
                {
                    SVMXC__Page_Layout__c PL = new SVMXC__Page_Layout__c();
                    PL = RelatedLayoutMap.get(s1);
                    SVMXC__Page_Layout_Detail__c PLD = new SVMXC__Page_Layout_Detail__c();
                    PLD = RelatedButtonsMap.get(s);
                    if(PLD.SVMXC__Page_Layout__c == PL.id)
                    {
                        //log.setlog('LOOPING', 'looping through RelatedButtonsMap to build RelatedBtnUI for '+s);
                        SVMXC.SFM_WrapperDef.SFM_UIButton ButtonUI = new SVMXC.SFM_WrapperDef.SFM_UIButton(new SVMXC__Page_Layout_Detail__c(),new List<SVMXC__SFM_Event__c>());
                        ButtonUI.buttonDetail = RelatedButtonsMap.get(s);
                        if(RelatedBtnEventMap.containsKey(s) && RelatedBtnEventMap.get(s) != null)
                        {
                            ButtonUI.buttonEvents = RelatedBtnEventMap.get(s);
                        }
                        RelatedBtnUI.add(ButtonUI);
                    }   
                }
                SVMXC__Page_Layout__c PL1 = new SVMXC__Page_Layout__c();
                PL1 = RelatedLayoutMap.get(s1); 
                RelatedBtnUIMap.put(PL1.id,RelatedBtnUI);
            }   
            system.debug('RelatedBtnUIMap'+RelatedBtnUIMap);
            //log.setlog('LOOPING-End', 'looping through RelatedButtonsMap to build RelatedBtnUI');
            //get the event for Related fields..
            Map<Id,List<SVMXC__SFM_Event__c>>  RelatedfldEventMap = new  Map<Id,List<SVMXC__SFM_Event__c>>();
            list<SVMXC__SFM_Event__c> RelatedfldEventLst = new List<SVMXC__SFM_Event__c>();
            //log.setlog('QUERY-TEXT', 'Getting the events for the related fields');
            //Added SVMXC__ServiceMax_Custom_Action__c to SOQL for BAC-4329
            //Added SVMXC__Code_Snippet__r.SVMXC__SM_Snippet_Version__c in the SOQL for the task BAC-4806
            RelatedfldEventLst.addall([Select SVMXC__Code_Snippet__c, SVMXC__Code_Snippet__r.SVMXC__SM_Snippet_Version__c, SVMXC__ServiceMax_Custom_Action__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : RelatedFldId]);
            if(RelatedfldEventLst.size() > 0){
              for(SVMXC__SFM_Event__c evt : RelatedfldEventLst){
                if(evt.SVMXC__Event_Call_Type__c == null){
                  evt.SVMXC__Event_Call_Type__c = 'WEBSERVICE';
                }
                }
            }
            if(RelatedFieldLst.size() > 0)
            {
                //log.setlog('LOOPING-Start', 'Outer Loop for looping through the list of related fields');
                for(integer i = 0; i < RelatedFieldLst.size();i++)
                {
                    //log.setlog('LOOPING', 'Outer Loop for looping through the list of related fields for'+RelatedFieldLst[i].id);
                    List<SVMXC__SFM_Event__c> templst = new List<SVMXC__SFM_Event__c>();
                    if(RelatedfldEventLst.size() > 0)
                    {
                        //log.setlog('LOOPING-Start', 'Inner Loop for looping through the Eventlist of related fields');
                        for(Integer j = 0; j < RelatedfldEventLst.size(); j++)
                        {
                            if(RelatedfldEventLst[j].SVMXC__Page_Layout_Detail__c == RelatedFieldLst[i].id)
                            {
                                templst.add(RelatedfldEventLst[j]);
                            }
                        }
                        //log.setlog('LOOPING-End', 'Inner Loop for looping through the Eventlist of related fields');
                    }
                    RelatedfldEventMap.put(RelatedFieldLst[i].id,templst);
                }
                //log.setlog('LOOPING-End', 'Outer Loop for looping through the list of related fields');
            }
            //map of Related button id(SVMXC__Page_Layout_Detail__c) and List<SFM_UIField> for SFM_pageDetail
            Map<String,List<SVMXC.SFM_WrapperDef.SFM_UIField>> RelatedfldUIMap = new Map<String,List<SVMXC.SFM_WrapperDef.SFM_UIField>>();
            //log.setlog('LOOPING-Start', 'Looping through the list of relatedfieldsmap to add to FieldUI');
            for(String s1: RelatedLayoutMap.keyset())
            {
                ////Create the SFM_FieldUI wrapper for Related Layout..
                List<SVMXC.SFM_WrapperDef.SFM_UIField> RelatedfldUI = new List<SVMXC.SFM_WrapperDef.SFM_UIField>();
                for(String s : RelatedFieldsMap.keyset())
                {
                    SVMXC__Page_Layout__c PL = new SVMXC__Page_Layout__c();
                    PL = RelatedLayoutMap.get(s1);
                    SVMXC__Page_Layout_Detail__c PLD = new SVMXC__Page_Layout_Detail__c();
                    PLD = RelatedFieldsMap.get(s);
                    if(PLD.SVMXC__Page_Layout__c == PL.id)
                    {
                        SVMXC.SFM_WrapperDef.SFM_UIField FieldUI = new SVMXC.SFM_WrapperDef.SFM_UIField();//new SVMXC__Page_Layout_Detail__c(),new List<SVMXC__SFM_Event__c>()
                        if(PLD.SVMXC__DataType__c.equalsIgnoreCase('reference') && PLD.SVMXC__Named_Search__c == null && PLD.SVMXC__Related_Object_Name__c != null)
                        {
                            if(mapObjectNameLookupConfigId.containskey(PLD.SVMXC__Related_Object_Name__c))
                                PLD.SVMXC__Named_Search__c = mapObjectNameLookupConfigId.get(PLD.SVMXC__Related_Object_Name__c);
                            else 
                                mapObjectNameFieldName.put(PLD.SVMXC__Related_Object_Name__c,PLD.SVMXC__Related_Object_Name_Field__c);    
                        } 
                        FieldUI.fieldDetail = PLD;
                        if(RelatedfldEventMap.containsKey(s) && RelatedfldEventMap.get(s) != null)
                        {
                            FieldUI.fieldEvents = RelatedfldEventMap.get(s);
                        }
                        RelatedfldUI.add(FieldUI);
                    }   
                }
                SVMXC__Page_Layout__c PL1 = new SVMXC__Page_Layout__c();
                PL1 = RelatedLayoutMap.get(s1); 
                RelatedfldUIMap.put(PL1.id,RelatedfldUI);
            }
            system.debug('RelatedfldUIMap'+RelatedfldUIMap);    
            
            //log.setlog('LOOPING-End', 'Looping through the list of relatedfieldsmap to add to FieldUI');
            //create a map<DetailObject,List<Fields> so it can be use to create bubble info...
            Map<String,List<Wrapper>> DetailFieldMap = new Map<String,List<Wrapper>>(); 
            if(RelatedLayoutMap.size() > 0 && AllRelatedfldsbtnsMap.size() > 0)
            {
                for(String s:RelatedLayoutMap.keyset())
                {
                    List<Wrapper> fldlst = new List<Wrapper>();
                    for(String s1:AllRelatedfldsbtnsMap.keyset())
                    {
                        if(RelatedLayoutMap.get(s)!=null && AllRelatedfldsbtnsMap.get(s1)!=null && AllRelatedfldsbtnsMap.get(s1).SVMXC__Detail_Type__c != null && RelatedLayoutMap.get(s).id == AllRelatedfldsbtnsMap.get(s1).SVMXC__Page_Layout__c && AllRelatedfldsbtnsMap.get(s1).SVMXC__Detail_Type__c.touppercase() == 'FIELD')
                        {
                            Wrapper tempwrapper = new Wrapper();
                            if(AllRelatedfldsbtnsMap.get(s1).SVMXC__Field_API_Name__c!= null)
                                tempwrapper.FieldApiName = AllRelatedfldsbtnsMap.get(s1).SVMXC__Field_API_Name__c; 
                            if(AllRelatedfldsbtnsMap.get(s1).SVMXC__DataType__c!= null)
                                tempwrapper.DataType = AllRelatedfldsbtnsMap.get(s1).SVMXC__DataType__c;
                            if(AllRelatedfldsbtnsMap.get(s1).SVMXC__Named_Search__c != null)
                                tempwrapper.LookupConfigID = AllRelatedfldsbtnsMap.get(s1).SVMXC__Named_Search__c;
                            if(AllRelatedfldsbtnsMap.get(s1).SVMXC__Named_Search__c != null && AllRelatedfldsbtnsMap.get(s1).SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != null)        
                                tempwrapper.DefaultLookupColumn = AllRelatedfldsbtnsMap.get(s1).SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c;
                            if(AllRelatedfldsbtnsMap.get(s1).SVMXC__Related_Object_Name__c!= null)
                                tempwrapper.RelatedObjName = AllRelatedfldsbtnsMap.get(s1).SVMXC__Related_Object_Name__c;
                            if(AllRelatedfldsbtnsMap.get(s1).SVMXC__Related_Object_Name_Field__c != null)
                                tempwrapper.RelatedObjFieldName = AllRelatedfldsbtnsMap.get(s1).SVMXC__Related_Object_Name_Field__c;  
                            fldlst.add(tempwrapper);
                            
                        }
                    }
                    DetailFieldMap.put(RelatedLayoutMap.get(s).Id,fldlst);//RelatedLayoutMap.get(s).SVMXC__Object_Name__c
                }
            }
            system.debug('DetailFieldMap'+DetailFieldMap);
            //Call Add Record Templete 
            map<String,SVMXC.SFM_AddRecordTemplate.RecordTemplate> mapRecordTemplate = new map<String,SVMXC.SFM_AddRecordTemplate.RecordTemplate>();
            if(strRequestType == 'META'){
                SVMXC.SFM_AddRecordTemplate Inst = new SVMXC.SFM_AddRecordTemplate(); 
                mapRecordTemplate = Inst.getRecordTemplate(mapPagelayoutIdProcessNodeObject,allobjmap);
            }   
           if(mapRecordTemplate.size() > 0){ // Added for BAC-4677
                PageHeader.mappedLiterals = mapRecordTemplate.get(Process.SVMXC__Page_Layout__c).mappedLiterals;
                PageHeader.fieldMappedLiterals = mapRecordTemplate.get(Process.SVMXC__Page_Layout__c).fieldMappedLiterals;//Added by Nidhi as part of BAC-4963
            }
            //Create the list for SFM_PageDetail class..
            List<SVMXC.SFM_WrapperDef.SFM_PageDetail> SFM_PageDetailLst = new List<SVMXC.SFM_WrapperDef.SFM_PageDetail>(); 
            if(RelatedLayoutMap.size() > 0)
            {
                //Start: BAC-5162
                String lunDesignerURI = '';
                if(isHTMLview)
                 {
                    lunDesignerURI =  System.URL.getSalesforceBaseUrl().toExternalForm() +'/apex/SFM_Designer#/transaction-editor/';  
                 }else
                 {
                    lunDesignerURI = System.URL.getSalesforceBaseUrl().toExternalForm() +'/apex/SFM_TDM_Designer?isChecklistDisabled=true&processID=';
                 }
                 //End : BAC-5162
                //log.setlog('LOOPING-Start', 'Looping through the list of RelatedLayoutMap to add to Pagedetail');
                for(String s : RelatedLayoutMap.keyset())
                {
                    //log.setlog('LOOPING', 'Looping through the list of RelatedLayoutMap to add to Pagedetail'+s);   
                    //get the field describe for the detail
                    SVMXC.SFM_WrapperDef.SFM_PageDetail SFM_PageDetail = new SVMXC.SFM_WrapperDef.SFM_PageDetail();
                    SFM_PageDetail.DetailLayout = RelatedLayoutMap.get(s);
                    SFM_PageDetail.dtlLayoutId = s;
                    
                    //Associate Linked Processes
                    if(strRequestType != NULL && strRequestType.length() > 0 && strRequestType == 'META' && mapAliasNameProcessNodeObjId.containskey(s) && mapNodeIdLinkedProcesses.containskey(mapAliasNameProcessNodeObjId.get(s))){
                        for(SVMXC__ServiceMax_Processes__c pro : mapNodeIdLinkedProcesses.get(mapAliasNameProcessNodeObjId.get(s))){
                            //Start BAC-5162
                            String url='';
                            if(isHTMLview)
                            {
                              url = lunDesignerURI + (pro.SVMXC__Process3__r.SVMXC__Purpose__c).replaceAll(' ','_')+'/'+pro.SVMXC__Process3__c;
                            }else
                            {
                              url = lunDesignerURI + pro.SVMXC__Process3__c;
                            }
                            //END : BAC-5162
                           //SFM_PageDetail.linkedProcesses.Add(new SVMXC.SFM_WrapperDef.linkedProcessDetail(pro.SVMXC__Sequence__c.intValue(),pro.SVMXC__Name__c,pro.SVMXC__Process3__r.SVMXC__ProcessID__c));
                           SFM_WrapperDef.linkedProcessDetail detailobj = new SVMXC.SFM_WrapperDef.linkedProcessDetail(pro.SVMXC__Sequence__c.intValue(),pro.SVMXC__Name__c,pro.SVMXC__Process3__r.SVMXC__ProcessID__c);
                           //BAC-5162
                           detailobj.linkedProcessURL = url;
                           SFM_PageDetail.linkedProcesses.Add(detailobj);  
                        
                        }
                    }
                    system.debug('DetailLayout'+SFM_PageDetail.DetailLayout);
                    system.debug('LinkedProcesses'+SFM_PageDetail.linkedProcesses);
                    //get the Event for Detail layout
                    if(RelatedLayoutEventMap.containskey(s))
                        SFM_PageDetail.events = RelatedLayoutEventMap.get(s);
                    ////put the List<SFM_DetailBubbleWrapper> member in the SFM_PageDetail 
                    List<SVMXC.SFM_WrapperDef.SFM_DetailBubbleWrapper> DetailBubbleWrapperList = new List<SVMXC.SFM_WrapperDef.SFM_DetailBubbleWrapper>();
                    if((DetailSobjectRecsMap.size() > 0 || mapAliasNameSourceRecIdTargetObject.size() > 0) && (RelatedLayoutMap.get(s).Id != null && DetailFieldMap.size() > 0))
                    {
                        list<Sobject> lstSobject = new list<Sobject>();
                        list<String> lstSourceRecId = new list<String>();
                        map<String,Sobject> mapSourceRecIdTargetObj = new map<String,Sobject>(); 
                        String Rid = s.substring(0,15);
                        if(mapAliasNameSourceRecIdTargetObject.containskey(Rid) && (Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL'))
                        {
                            mapSourceRecIdTargetObj = mapAliasNameSourceRecIdTargetObject.get(Rid);
                            if(mapSourceRecIdTargetObj.size() > 0)
                            {
                                for(String str:mapSourceRecIdTargetObj.keyset())
                                {
                                    lstSobject.add(mapSourceRecIdTargetObj.get(str));
                                    lstSourceRecId.add(str);
                                }
                            }
                        }   
                        else if(DetailSobjectRecsMap.containskey(Rid))
                        {
                            lstSobject = DetailSobjectRecsMap.get(Rid);
                        } 
                        //Calculate the Reference field's Name-id pair in bulk mode
                        map<String,String> IdNameMap = new map<String,String>(); 
                        if(lstSobject.size() > 0)
                        {
                            List<wrapper> Tempfldlst = new List<wrapper>();
                            if(DetailFieldMap.containskey(RelatedLayoutMap.get(s).Id))
                                Tempfldlst = DetailFieldMap.get(RelatedLayoutMap.get(s).Id);
                            map<String,String> FieldObjMap = new map<String,String>();
                            map<String,String> FieldNameFieldMap = new map<String,String>(); 
                            map<String,String> FieldLookUpColumnMap = new map<String,String>(); 
                            if(Tempfldlst.size() > 0)
                            {
                                for(integer a = 0;a<Tempfldlst.size();a++)
                                {
                                    if(Tempfldlst[a].DataType != null && Tempfldlst[a].DataType.touppercase() == 'REFERENCE' && Tempfldlst[a].FieldApiName != null && Tempfldlst[a].RelatedObjName != null && Tempfldlst[a].RelatedObjFieldName != null)
                                    {   
                                        FieldObjMap.put(Tempfldlst[a].FieldApiName,Tempfldlst[a].RelatedObjName);
                                        FieldNameFieldMap.put(Tempfldlst[a].FieldApiName,Tempfldlst[a].RelatedObjFieldName);
                                        if(Tempfldlst[a].DefaultLookupColumn != null && Tempfldlst[a].DefaultLookupColumn != Tempfldlst[a].RelatedObjFieldName)
                                            FieldLookUpColumnMap.put(Tempfldlst[a].FieldApiName,Tempfldlst[a].DefaultLookupColumn);
                                    }   
                                }
                            }
                            system.debug('FieldLookUpColumnMap'+FieldLookUpColumnMap); 
                            if(FieldObjMap.size() > 0 && FieldNameFieldMap.size() > 0)
                            {
                                for(String fld : FieldObjMap.keyset())
                                {
                                    set<String> ids = new set<String>();
                                    for(Integer b = 0;b<lstSobject.size();b++)
                                    {
                                        if(lstSobject[b].get(fld) != null)
                                            ids.add(String.valueof(lstSobject[b].get(fld)));
                                    }
                                    if(ids.size() > 0 && FieldNameFieldMap.containskey(fld))
                                    {
                                        map<String,String> TempMap = new map<String,String>();
                                        if(FieldLookUpColumnMap.containskey(fld))
                                        {
                                            String FieldName = FieldNameFieldMap.get(fld) + ',' + FieldLookUpColumnMap.get(fld);
                                            TempMap = SFMUtils.GetRelationshipData(ids,FieldObjMap.get(fld),FieldName);
                                        }
                                        else
                                        {
                                            TempMap = SFMUtils.GetRelationshipData(ids,FieldObjMap.get(fld),FieldNameFieldMap.get(fld));
                                        }   
                                        if(TempMap.size() > 0)
                                            IdNameMap.putall(TempMap);
                                    }
                                }
                            }   
                       }
                       system.debug('IdNameMap'+IdNameMap);
                       if(lstSobject.size() > 0)
                       {
                            for(Integer i = 0;i<lstSobject.size();i++)
                            {
                                Sobject objTarget = lstSobject[i];
                                SVMXC.SFM_WrapperDef.SFM_DetailBubbleWrapper DetailBubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_DetailBubbleWrapper();
                                if(lstSourceRecId.size() > 0)
                                    DetailBubbleWrapper.sourceRecordId = lstSourceRecId[i];
                                List<wrapper> fldlst = new List<wrapper>();
                                if(DetailFieldMap.containskey(RelatedLayoutMap.get(s).Id))//RelatedLayoutMap.get(s).SVMXC__Object_Name__c
                                    fldlst = DetailFieldMap.get(RelatedLayoutMap.get(s).Id);//RelatedLayoutMap.get(s).SVMXC__Object_Name__c
                                if(fldlst.size() > 0)
                                {
                                    List<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper> BubbleWrapperLst = new List<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper>();
                                    for(Integer j = 0;j<fldlst.size();j++)
                                    {
                                        SVMXC.SFM_WrapperDef.SFM_BubbleWrapper BubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper();
                                        BubbleWrapper.fieldapiname = fldlst[j].FieldApiName;
                                        //system.debug('asdfgh'+BubbleWrapper.fieldapiname);
                                        //system.debug('FieldApiName'+fldlst[j].FieldApiName);
                                        //system.debug('FieldApiName'+objTarget.get(fldlst[j].FieldApiName)+fldlst[j].RelatedObjName+fldlst[j].RelatedObjFieldName);
                                        String DefaultValue = '';
                                        if(fldlst[j].FieldApiName != null)
                                            DefaultValue = String.valueof(objTarget.get(fldlst[j].FieldApiName)); 
                                        if(fldlst[j].RelatedObjName != null && fldlst[j].DataType.touppercase() == 'REFERENCE')
                                        {
                                            SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                                            strmap.key = DefaultValue;
                                            if(IdNameMap.containskey(DefaultValue))
                                                strmap.value = IdNameMap.get(DefaultValue);
                                            BubbleWrapper.fieldvalue = strmap;
                                           /* if(fldlst[j].LookupConfigID != null)
                                                BubbleWrapper.bubbleinfo = SFMUtils.getBubbleinfo(DefaultValue,fldlst[j].LookupConfigID,fldlst[j].RelatedObjName);
                                            else    
                                                BubbleWrapper.bubbleinfo = SFMUtils.getBubbleinfo(DefaultValue,Null,fldlst[j].RelatedObjName);*/
                                        }
                                        else
                                        {
                                            SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(DefaultValue,DefaultValue);
                                            BubbleWrapper.fieldvalue = strmap;  
                                        }
                                        BubbleWrapperLst.add(BubbleWrapper);
                                    }
                                    system.debug('BubbleWrapperLst'+BubbleWrapperLst);
                                    DetailBubbleWrapper.bubbleinfolist = BubbleWrapperLst;
                                }
                                DetailBubbleWrapper.sobjectinfo = objTarget;
                                DetailBubbleWrapperList.add(DetailBubbleWrapper);
                            }
                            system.debug('DetailBubbleWrapperList'+DetailBubbleWrapperList);
                        }
                    }
                    SFM_PageDetail.bubbleinfolist = DetailBubbleWrapperList;                
                    if(RelatedfldUIMap.containsKey(s) && RelatedfldUIMap.get(s) != null)    
                    {
                        SFM_PageDetail.fields = RelatedfldUIMap.get(s);
                    }       
                    if(RelatedBtnUIMap.containskey(s) && RelatedBtnUIMap.get(s) != null)
                    {
                        SFM_PageDetail.buttons =  RelatedBtnUIMap.get(s);
                    }
                    if(strRequestType == 'META' && mapRecordTemplate.containskey(s)) {  
                        SFM_PageDetail.recordTemplate = mapRecordTemplate.get(s).recordTemplate;
                        SFM_PageDetail.mappedValues = mapRecordTemplate.get(s).mappedValues;
                        SFM_PageDetail.mappedLiterals = mapRecordTemplate.get(s).mappedLiterals;
                        SFM_PageDetail.fieldMappedLiterals = mapRecordTemplate.get(s).fieldMappedLiterals;//Added by Nidhi as part of BAC-4963
                    }    
                    SFM_PageDetailLst.add(SFM_PageDetail);
                }
                system.debug(LoggingLevel.WARN,'SFM_PageDetailLst'+SFM_PageDetailLst);
                //log.setlog('LOOPING-End', 'Looping through the list of relatedfieldsmap to add to Pagedetail');
            }
            //Build Meta for LookupConfig 
            if(strRequestType == 'META'){
                SVMXC.SFM_GetLookupConfigDefinition objLookup = new SVMXC.SFM_GetLookupConfigDefinition();
                SVMXC.SFM_WrapperDef.SFM_Request reqForLookup = new SVMXC.SFM_WrapperDef.SFM_Request();
                SVMXC.SFM_WrapperDef.SFM_StringListMap stringLstMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
                stringLstMap.key = 'LOOKCONFIGID';
                stringLstMap.valueList.addall(setLookupConfigId); 
                reqForLookup.stringListMap.add(stringLstMap);
                pageui.lookupDefinitions = objLookup.getLookupConfigDefinition(reqForLookup);
                system.debug('mapObjectNameFieldName'+mapObjectNameFieldName);
                if(mapObjectNameFieldName.size () > 0){
                    for(String str : mapObjectNameFieldName.keyset())
                    {
                        list<SVMXC__ServiceMax_Config_Data__c> lstConfiData = new list<SVMXC__ServiceMax_Config_Data__c>();
                        SVMXC__ServiceMax_Processes__c objProcess = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = str);
                        SVMXC__ServiceMax_Config_Data__c objSearch = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Search_Object_Field_Type__c='Search', SVMXC__Field_Name__c = mapObjectNameFieldName.get(str), SVMXC__Display_Type__c = 'string', SVMXC__Sequence__c = 1,SVMXC__Expression_Type__c = 'SRCH_Object_Fields');
                        SVMXC__ServiceMax_Config_Data__c objBubble = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Search_Object_Field_Type__c='Bubble', SVMXC__Field_Name__c = mapObjectNameFieldName.get(str), SVMXC__Display_Type__c = 'string', SVMXC__Sequence__c = 1,SVMXC__Expression_Type__c = 'SRCH_Object_Fields');
                        SVMXC__ServiceMax_Config_Data__c objDisplay = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Search_Object_Field_Type__c='Result', SVMXC__Field_Name__c = mapObjectNameFieldName.get(str), SVMXC__Display_Type__c = 'string', SVMXC__Sequence__c = 1,SVMXC__Expression_Type__c = 'SRCH_Object_Fields');
                        lstConfiData.add(objSearch);
                        lstConfiData.add(objBubble);
                        lstConfiData.add(objDisplay);
                        pageui.lookupDefinitions.add( new SVMXC.SFM_WrapperDef.SFM_LookupDefinition(objProcess,lstConfiData));
                    }
                } 
                if(setFromFillId.size() > 0){
                    system.debug('setFromFillId'+setFromFillId);
                    SVMXC.SFM_ApplyMapping formFill = new SVMXC.SFM_ApplyMapping();
                    pageui.lstObjectMapInfo = formFill.SFM_CreateMetaDataForFormFill(setFromFillId);
                }
                
                if(lstProBizRuleWrap != NULL && lstProBizRuleWrap.size() > 0)
                    pageui.businessRules = lstProBizRuleWrap;
            } 
            system.debug(LoggingLevel.WARN, 'Biz Rule Meta Info: ' + pageui.businessRules);
            system.debug('LookupDefination: '+pageui.lookupDefinitions);
            system.debug('lstObjectMapInfo: '+pageui.lstObjectMapInfo);
            system.debug('Last'+SFM_PageDetailLst.size()+SFM_PageDetailLst);
            
            pageui.header = PageHeader;
            pageui.details = SFM_PageDetailLst;
            SFMResponse.success = true;
            PageResponseUI.page = pageui;
            PageResponseUI.response = SFMResponse;
            system.debug('No of Queries executed'+limits.getQueries());
            system.debug(LoggingLevel.WARN, 'Response: '+PageResponseUI);
            return PageResponseUI; 
        //}
        //catch (Exception ex)
        //{
            //log.setlog('ERROR', ex.getmessage());
            //log.setlog('ROLLBACK', 'When fails rollback data donot commit');
           
           // SFMResponse.success = false;
           // SFMResponse.message = ex.getmessage();
            //throw new SFMException(ex.getmessage());
        //}
        
    }
    
    /**
    * This method returns SectionEntryCriteria Rule Ids
    * @param SVMXC.SFM_WrapperDef.SFM_Request(OBJECTAPINAME: <Object API Name>)
    * @return SVMXC.SFM_WrapperDef.SFM_Response(SectionEntryCriteria Rule Ids)
    */
    
    /*
    * This method returns SectionEntryCriteria rule ids
    * @param SVMXC.SFM_WrapperDef.SFM_Request(OBJECTAPINAME: <Object API name>)
    * @return SVMXC.SFM_WrapperDef.SFM_Response(SectionEntryCriteria rule ids associated with the given Object )
    */
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetSectionEntryCriteriaRuleIds(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        List<String> lstObjectName = new List<String>();
        List<SVMXC__ServiceMax_Processes__c> lstSectionEntryCriteriaRules = new List<SVMXC__ServiceMax_Processes__c>(); 
        Map<String, SVMXC__ServiceMax_Processes__c> mapSectionEntryCriteriaRules = new Map<String, SVMXC__ServiceMax_Processes__c>();
        SVMXC.SFM_WrapperDef.SFM_Response objSectionEntryCriteriaRuleResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        objSectionEntryCriteriaRuleResp.resultIds = new List<String>();
        objSectionEntryCriteriaRuleResp.success = true;
        
        try
        {
            for(SVMXC.SFM_WrapperDef.SFM_StringListMap strLstMap : request.stringListMap)
            {
                if(strLstMap.key != NULL && strLstMap.key.toUpperCase() == 'OBJECTAPINAME' && strLstMap.valueList != NULL)
                {
                    for(String value : strLstMap.valueList)
                        lstObjectName.add(String.escapeSingleQuotes(value));
                }
            }
            if(lstObjectName != NULL && lstObjectName.size() > 0)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstSectionEntryCriteriaRules = Database.query('Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Source_Object_Name__c IN: lstObjectName AND SVMXC__Source_Object_Name__c != NULL AND Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c = \'Checklist_Section_Entry_Criteria\'');
            else
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstSectionEntryCriteriaRules = Database.query('Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Source_Object_Name__c != NULL AND Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c = \'Checklist_Section_Entry_Criteria\'');

            if(lstSectionEntryCriteriaRules != NULL && lstSectionEntryCriteriaRules.size() > 0)
                mapSectionEntryCriteriaRules.putAll(lstSectionEntryCriteriaRules);
            if(mapSectionEntryCriteriaRules != NULL && mapSectionEntryCriteriaRules.size() > 0)
                objSectionEntryCriteriaRuleResp.resultIds.addAll(mapSectionEntryCriteriaRules.keySet());
        }
        catch(exception ex)
        {
            objSectionEntryCriteriaRuleResp.success = false;
            objSectionEntryCriteriaRuleResp.message = ex.getMessage();
            System.debug(LoggingLevel.Warn, 'Exception: ' + ex.getMessage());
        }
        System.debug(LoggingLevel.WARN, 'Response: ' + objSectionEntryCriteriaRuleResp);
        return objSectionEntryCriteriaRuleResp;
    }
    
    /*
    * This method returns SectionEntryCriteria rule with expressions
    * @param SVMXC.SFM_WrapperDef.SFM_Request(BUSINESSRULEIDS: <SectionEntryCriteria rule Ids>)
    * @return SVMXC.SFM_WrapperDef.SFM_Response(SectionEntryCriteria rule with expressions)
    */
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetSectionEntryCriteriaRuleInfo(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        List<String> lstSectionEntryCriteriaRuleIds = new List<String>();
        Map<String, List<SVMXC__ServiceMax_Config_Data__c>> mapSectionEntryCriteriaRuleIdExplst = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
        SVMXC.SFM_WrapperDef.SFM_Response objSectionEntryCriteriaRuleResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        objSectionEntryCriteriaRuleResp.lstBizRuleInfo = new List<SVMXC.SFM_WrapperDef.SFM_BizRuleInfo>();
        objSectionEntryCriteriaRuleResp.success = true;
        
        try
        {
            for(SVMXC.SFM_WrapperDef.SFM_StringListMap strLstMap : request.stringListMap)
            {
                if(strLstMap.key != NULL && strLstMap.key.toUpperCase() == 'BUSINESSRULEIDS' && strLstMap.valueList != NULL)
                {
                    for(String value : strLstMap.valueList)
                        lstSectionEntryCriteriaRuleIds.add(String.escapeSingleQuotes(value));
                }
            }
            if(lstSectionEntryCriteriaRuleIds.size() > 0)
            {
                //Added ORDER BY clause to display sequence correctly in designer.
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(SVMXC__ServiceMax_Config_Data__c SectionEntryCriteriaRuleExpr : Database.query('Select Id, SVMXC__Description__c, SVMXC__Parameter_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Object_Name__c, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Internal_Value__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN: lstSectionEntryCriteriaRuleIds AND SVMXC__Expression_Type__c = \'Business_Rule\' ORDER BY SVMXC__Sequence__c'))
                {
                    if(!mapSectionEntryCriteriaRuleIdExplst.containsKey(SectionEntryCriteriaRuleExpr.SVMXC__Expression_Rule__c))
                        mapSectionEntryCriteriaRuleIdExplst.put(SectionEntryCriteriaRuleExpr.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                    mapSectionEntryCriteriaRuleIdExplst.get(SectionEntryCriteriaRuleExpr.SVMXC__Expression_Rule__c).add(SectionEntryCriteriaRuleExpr);
                }
                for(SVMXC__ServiceMax_Processes__c SectionEntryCriteriaRule : Database.query('Select SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__IsStandard__c, SVMXC__Description__c, SVMXC__Message_Type__c, SVMXC__Source_Object_Name__c, SVMXC__Advance_Expression__c, SVMXC__Parent_Error_Msg__c, Id From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c =\'Checklist_Section_Entry_Criteria\' AND Id IN: lstSectionEntryCriteriaRuleIds'))
                {
                    if(mapSectionEntryCriteriaRuleIdExplst.containsKey(SectionEntryCriteriaRule.Id) && mapSectionEntryCriteriaRuleIdExplst.get(SectionEntryCriteriaRule.Id) != NULL)
                        objSectionEntryCriteriaRuleResp.lstBizRuleInfo.add(new SVMXC.SFM_WrapperDef.SFM_BizRuleInfo(SectionEntryCriteriaRule, mapSectionEntryCriteriaRuleIdExplst.get(SectionEntryCriteriaRule.Id)));
                }
            }
        }
        catch(exception ex)
        {
            objSectionEntryCriteriaRuleResp.success = false;
            objSectionEntryCriteriaRuleResp.message = ex.getMessage();
            System.debug(LoggingLevel.Warn, 'Exception: ' + ex.getMessage());
        }
        System.debug(LoggingLevel.WARN, 'Response: ' + objSectionEntryCriteriaRuleResp);
        return objSectionEntryCriteriaRuleResp;
    }
  
   /*
    * This method returns SectionExitCriteria rule with expressions
    * @param SVMXC.SFM_WrapperDef.SFM_Request(PROCESSID: <SFM Process Ids>)
    * @return SVMXC.SFM_WrapperDef.SFM_Response(SectionExitCriteria rule with expressions)
    */
  
  public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetSectionExitCriteriaRuleInfo(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        List<String> lstProcessIds = new List<String>();
        List<String> lstSectionExitCriteriaRuleIds = new List<String>();
        List<SVMXC__ServiceMax_Processes__c> lstProBizRules = new List<SVMXC__ServiceMax_Processes__c>();
        Map<String, List<SVMXC__ServiceMax_Config_Data__c>> mapSectionEntryCriteriaRuleIdExplst = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
        SVMXC.SFM_WrapperDef.SFM_Response objSectionEntryCriteriaRuleResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        objSectionEntryCriteriaRuleResp.lstBizRuleInfo = new List<SVMXC.SFM_WrapperDef.SFM_BizRuleInfo>();
        objSectionEntryCriteriaRuleResp.success = true;
        
        try
        {
            for(SVMXC.SFM_WrapperDef.SFM_StringListMap strLstMap : request.stringListMap)
            {
                if(strLstMap.key != NULL && strLstMap.key.toUpperCase() == 'PROCESSID' && strLstMap.valueList != NULL)
                {
                    for(String value : strLstMap.valueList)
                        lstProcessIds.add(String.escapeSingleQuotes(value));
                }
            }
            if(lstProcessIds.size() > 0)
            {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstProBizRules = Database.query('Select Id,  SVMXC__Process3__c, SVMXC__Parent_Error_Msg__c, SVMXC__Sequence__c,SVMXC__SM_Section__c,SVMXC__SM_Target_Section__c, SVMXC__Rule_Type__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Process1__c in: lstProcessIds AND Recordtype.Name = \'Process Business Rule\' AND SVMXC__Rule_Type__c=\'Checklist_Section_Exit_Criteria\'   ORDER By SVMXC__Sequence__c');
                 System.debug(logginglevel.warn,'lstProBizRules: '+lstProBizRules);
                for(SVMXC__ServiceMax_Processes__c obj:lstProBizRules)
                    lstSectionExitCriteriaRuleIds.add(obj.SVMXC__Process3__c);
                System.debug(logginglevel.warn,'lstSectionExitCriteriaRuleIds: '+lstSectionExitCriteriaRuleIds);
                //Added ORDER BY clause to display sequence correctly in designer.
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(SVMXC__ServiceMax_Config_Data__c SectionEntryCriteriaRuleExpr : Database.query('Select Id,  SVMXC__Parameter_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Object_Name__c, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Internal_Value__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN: lstSectionExitCriteriaRuleIds AND SVMXC__Expression_Type__c = \'Business_Rule\' ORDER BY SVMXC__Sequence__c'))
                {
                    if(!mapSectionEntryCriteriaRuleIdExplst.containsKey(SectionEntryCriteriaRuleExpr.SVMXC__Expression_Rule__c))
                        mapSectionEntryCriteriaRuleIdExplst.put(SectionEntryCriteriaRuleExpr.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                    mapSectionEntryCriteriaRuleIdExplst.get(SectionEntryCriteriaRuleExpr.SVMXC__Expression_Rule__c).add(SectionEntryCriteriaRuleExpr);
                }
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(SVMXC__ServiceMax_Processes__c SectionEntryCriteriaRule : Database.query('Select  SVMXC__Source_Object_Name__c, SVMXC__Rule_Type__c,SVMXC__Question_Bank__c, Id,(Select SVMXC__SM_Section__c,SVMXC__SM_Section__r.SVMXC__Sequence__c,SVMXC__SM_Target_Section__c,SVMXC__SM_Target_Section__r.SVMXC__Sequence__c, SVMXC__Sequence__c from  SVMXC__ServiceMax_Processes6__r) From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c =\'Checklist_Section_Exit_Criteria\' AND Id IN: lstSectionExitCriteriaRuleIds'))
                {
                    
                    System.debug(logginglevel.warn,'SectionEntryCriteriaRule: '+SectionEntryCriteriaRule);
                    if(mapSectionEntryCriteriaRuleIdExplst.containsKey(SectionEntryCriteriaRule.Id) && mapSectionEntryCriteriaRuleIdExplst.get(SectionEntryCriteriaRule.Id) != NULL)
                        objSectionEntryCriteriaRuleResp.lstBizRuleInfo.add(new SVMXC.SFM_WrapperDef.SFM_BizRuleInfo(SectionEntryCriteriaRule, mapSectionEntryCriteriaRuleIdExplst.get(SectionEntryCriteriaRule.Id)));
                }
            }
        }
        catch(exception ex)
        {
            objSectionEntryCriteriaRuleResp.success = false;
            objSectionEntryCriteriaRuleResp.message = ex.getMessage();
            System.debug(LoggingLevel.Warn, 'Exception: ' + ex.getMessage());
        }
        System.debug(LoggingLevel.WARN, 'Response: ' + objSectionEntryCriteriaRuleResp);
        return objSectionEntryCriteriaRuleResp;
    }


    public SFM_WrapperDef2.SFM2_Layout clonePageLayout(List<String> entityIds, boolean isClone){
        SFM_WrapperDef2.SFM2_Layout layoutInfo;
        
        if(entityIds.size() == 1){


            List<SVMXC__Page_Layout__c> layoutRecordsList = queryLayoutRecords(entityIds); 
            
            if(!layoutRecordsList.isEmpty()){
                layoutInfo = layoutValueWrapper(layoutRecordsList[0], isClone);
                Id entityId = entityIds[0];
                if(!isClone){
                Set<Id> dependentProcessIds = SFM_GetEntityDependencies.entityDependencyCheck(new Set<Id>{entityId}, SFM_DesignerUtils.entity_layout);
                layoutInfo.dependencyExist = dependentProcessIds.contains(entityId) ? true: false;
                }
            
            }else{
                System.debug( System.LoggingLevel.ERROR, 'Requested entity does not exist. Layout Id=' + entityIds[0]);
                throw new SFM_DesignerUtils.ServicemaxNestedException( 'Record does not exists for requested id.');
            }


        }

        return layoutInfo;
    }

    public List<SVMXC__Page_Layout__c> queryLayoutRecords(List<String> entityIds){
        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Page_Layout__c', new List<String>{'Id', 'SVMXC__Name__c', 'SVMXC__Help_URL__c', 'SVMXC__Type__c', 'SVMXC__SM_Description__c', 'SVMXC__Object_Name__c', 'SVMXC__Page_Help__c', 'SVMXC__Hide_Quick_Save__c', 'SVMXC__Hide_Save__c', 'SVMXC__IsStandard__c', 'SVMXC__Show_All_Sections_By_Default__c',
                                                               'SVMXC__Header_Page_Layout__c','SVMXC__Header_Reference_Field__c', 'SVMXC__Action_On_Zero_Lines__c', 'SVMXC__Allow_New_Lines__c', 'SVMXC__Allow_Delete_Lines__c', 'SVMXC__Multi_Add_Search_Field__c', 'SVMXC__Multi_Add_Search_Object__c', 'SVMXC__Sequence__c','SVMXC__No_Of_Columns__c'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Page_Layout_Detail__c', new List<String>{'Id', 'SVMXC__Question__c', 'SVMXC__Detail_Type__c', 'SVMXC__Field_API_Name__c', 'SVMXC__DataType__c', 'SVMXC__No_Of_Columns__c', 'SVMXC__Section__c', 'SVMXC__Display_Column__c', 'SVMXC__SM_Help_URL__c', 'SVMXC__SM_Description__c',
                              'SVMXC__Display_Row__c', 'SVMXC__Sequence__c', 'SVMXC__Title__c', 'SVMXC__Required__c', 'SVMXC__Readonly__c', 'SVMXC__Show_In_Web__c', 'SVMXC__Show_In_iPad__c', 'SVMXC__Related_Object_Name__c', 'SVMXC__Related_Object_Name_Field__c', 'SVMXC__Named_Search__c', 'SVMXC__Override_Related_Lookup__c', 'SVMXC__Lookup_Context__c', 'SVMXC__Lookup_Query_Field__c', 'SVMXC__Field_Mapping__c', 'SVMXC__Context_Source_Object__c'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SFM_Event__c', new List<String>{'Id', 'SVMXC__Event_Call_Type__c', 'SVMXC__Event_Type__c', 'SVMXC__URL_Window_Type__c', 'SVMXC__Target_Call__c', 'SVMXC__Code_Snippet__c', 'SVMXC__Code_Snippet__r.Name', 'SVMXC__ServiceMax_Custom_Action__c'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__Process3__c', 'SVMXC__SM_Section__c', 'SVMXC__Rule_Type__c', 'SVMXC__Sequence__c'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }        
        return [SELECT Id, SVMXC__Name__c, SVMXC__Help_URL__c, SVMXC__Type__c, SVMXC__SM_Description__c, SVMXC__Object_Name__c, SVMXC__Page_Help__c, SVMXC__Hide_Quick_Save__c, SVMXC__Hide_Save__c, SVMXC__IsStandard__c, SVMXC__Show_All_Sections_By_Default__c,
                              SVMXC__Show_Account_History__c, SVMXC__Show_Product_History__c, SVMXC__Enable_Troubleshooting__c, SVMXC__Enable_Service_Report_Generation__c, SVMXC__Enable_Service_Report_View__c, SVMXC__SM_Title_Bar__c, SVMXC__SM_Include_Summary__c,
                              SVMXC__SM_Summary_Title__c, SVMXC__SM_Include_Time_and_Place__c, SVMXC__SM_Include_Contact__c, SVMXC__SM_Include_Field1__c, SVMXC__SM_Include_Field2__c, SVMXC__SM_Include_Field3__c,  
                              (SELECT Id, SVMXC__Event_Call_Type__c, SVMXC__Event_Type__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Code_Snippet__c, SVMXC__Code_Snippet__r.Name, SVMXC__ServiceMax_Custom_Action__c
                              FROM SVMXC__SFM_Event__r), (SELECT Id, SVMXC__Name__c, SVMXC__Object_Name__c,  SVMXC__Type__c, SVMXC__Header_Page_Layout__c, SVMXC__Header_Reference_Field__c, SVMXC__Page_Layout_ID__c,
                              SVMXC__Action_On_Zero_Lines__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Sequence__c, SVMXC__No_Of_Columns__c FROM SVMXC__Page_Layouts__r ORDER BY SVMXC__Sequence__c ASC) 
                              FROM SVMXC__Page_Layout__c WHERE SVMXC__Type__c = 'HEADER' AND Id IN: entityIds]; 

    }

    public SFM_WrapperDef2.SFM2_Layout layoutValueWrapper(SVMXC__Page_Layout__c pageLayoutRecord, boolean isClone){
        SFM_WrapperDef2.SFM2_Layout layout = new SFM_WrapperDef2.SFM2_Layout();
        SFM_WrapperDef2.SFM2_EntityDetail entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
        if(!isClone){
        entityDetail.entityId = pageLayoutRecord.Id;
        }
        entityDetail.isStandard = pageLayoutRecord.SVMXC__IsStandard__c;
        entityDetail.entityDescription = pageLayoutRecord.SVMXC__SM_Description__c;
        entityDetail.entityName = pageLayoutRecord.SVMXC__Name__c;
        entityDetail.entitySubType = pageLayoutRecord.SVMXC__Type__c;
        layout.layoutDetail = entityDetail;
        layout.objectAPIName = pageLayoutRecord.SVMXC__Object_Name__c;
        layout.pageHelp = pageLayoutRecord.SVMXC__Page_Help__c;
        layout.helpUrl = pageLayoutRecord.SVMXC__Help_URL__c;
        layout.hideSave = pageLayoutRecord.SVMXC__Hide_Save__c;
        layout.hideQuickSave = pageLayoutRecord.SVMXC__Hide_Quick_Save__c;
        layout.showAllSections = pageLayoutRecord.SVMXC__Show_All_Sections_By_Default__c;
        layout.showAccountHistory = pageLayoutRecord.SVMXC__Show_Account_History__c;
        layout.showProductHistory = pageLayoutRecord.SVMXC__Show_Product_History__c;
        layout.enableTroubleShooting = pageLayoutRecord.SVMXC__Enable_Troubleshooting__c;
        layout.enableServiceReportView = pageLayoutRecord.SVMXC__Enable_Service_Report_View__c;
        layout.enableServiceReportGeneration = pageLayoutRecord.SVMXC__Enable_Service_Report_Generation__c;
        layout.titleBar = pageLayoutRecord.SVMXC__SM_Title_Bar__c != '--None--' ? pageLayoutRecord.SVMXC__SM_Title_Bar__c: null ;
        layout.includeSummary = pageLayoutRecord.SVMXC__SM_Include_Summary__c;
        layout.summaryTitle = pageLayoutRecord.SVMXC__SM_Summary_Title__c;
        layout.includeEventTimePlace = pageLayoutRecord.SVMXC__SM_Include_Time_and_Place__c;
        layout.includeContact = pageLayoutRecord.SVMXC__SM_Include_Contact__c;
        layout.includeField1 = pageLayoutRecord.SVMXC__SM_Include_Field1__c;
        layout.includeField2 =pageLayoutRecord.SVMXC__SM_Include_Field2__c;
        layout.includeField3 =pageLayoutRecord.SVMXC__SM_Include_Field3__c;
        layout.sectionDetails = childLayoutValueWrapper(pageLayoutRecord.Id, pageLayoutRecord.SVMXC__Page_Layouts__r, isClone);
        layout.events = eventWrapper(pageLayoutRecord.SVMXC__SFM_Event__r, isClone);
        return layout;
    }

    public List<SFM_WrapperDef2.SFM2_Event> eventWrapper(List<SVMXC__SFM_Event__c> eventsList, boolean isClone){
        
        List<SFM_WrapperDef2.SFM2_Event> eventWrapperList = new List<SFM_WrapperDef2.SFM2_Event>(); 
        for(SVMXC__SFM_Event__c eventRecord : eventsList){
            SFM_WrapperDef2.SFM2_Event event = new SFM_WrapperDef2.SFM2_Event();
            if(!isClone){
            event.eventId = eventRecord.Id;
            }
            event.eventType = eventRecord.SVMXC__Event_Type__c;
            event.eventCallType = eventRecord.SVMXC__Event_Call_Type__c;
            event.urlWindowType = eventRecord.SVMXC__URL_Window_Type__c;
            if(eventRecord.SVMXC__Event_Call_Type__c.equalsIgnoreCase('JAVASCRIPT')){
                 event.eventActionId = eventRecord.SVMXC__Code_Snippet__c;
            }else if(eventRecord.SVMXC__Event_Call_Type__c.equalsIgnoreCase('SFM CUSTOM ACTION')){
                event.eventActionId = eventRecord.SVMXC__ServiceMax_Custom_Action__c;
            }else if(eventRecord.SVMXC__Event_Call_Type__c.equalsIgnoreCase('WEBSERVICE') || eventRecord.SVMXC__Event_Call_Type__c.equalsIgnoreCase('URL')){
                event.eventActionId = eventRecord.SVMXC__Target_Call__c;
            }

            eventWrapperList.add(event);
        }

        return eventWrapperList;
    }

    public List<SFM_WrapperDef2.SFM2_LayoutSection> childLayoutValueWrapper(Id pageLayoutId, List<SVMXC__Page_Layout__c> layoutChildDetails, boolean isClone){
        
        Set<Id> detailLayoutIds = new Set<Id>();
        Set<Id> buttonIds = new Set<Id>();
        Set<Id> sectionIds = new Set<Id>();
        Map<Id, List<SVMXC__Page_Layout_Detail__c>> layoutElementsSectionMap = new Map<Id, List<SVMXC__Page_Layout_Detail__c>>();
        Map<Id, SFM_WrapperDef2.SFM2_LayoutSection> sectionWrapperMap = new Map<Id,SFM_WrapperDef2.SFM2_LayoutSection>();
        Map<String, String> sectionEntryCriteriaMap;
        Map<String, List<SFM_WrapperDef2.SFM2_Rule>> sectionExitCriteriaMap;
        /*
            For Page Sections
        */
        for(SVMXC__Page_Layout_Detail__c pageLayoutSectionRecord :  [SELECT Id, SVMXC__Detail_Type__c, SVMXC__Field_API_Name__c, SVMXC__DataType__c, SVMXC__No_Of_Columns__c, SVMXC__Section__c, SVMXC__Display_Column__c, SVMXC__SM_Help_URL__c,
                                                                        SVMXC__Display_Row__c, SVMXC__Sequence__c, SVMXC__Title__c, SVMXC__SM_Description__c, SVMXC__Required__c, SVMXC__Readonly__c, SVMXC__Show_In_Web__c, SVMXC__Show_In_iPad__c,
                                                                        SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Named_Search__c, SVMXC__Override_Related_Lookup__c, SVMXC__Lookup_Context__c, SVMXC__SM_Checklist_Source_Field_API_Name__c,
                                                                        SVMXC__Question__c, SVMXC__Lookup_Query_Field__c, SVMXC__Field_Mapping__c, SVMXC__Context_Source_Object__c, SVMXC__Use_For_SLA_Clock__c FROM SVMXC__Page_Layout_Detail__c
                                                                        WHERE SVMXC__Page_Layout__c =: pageLayoutId ORDER BY SVMXC__Sequence__c ASC ]){

            if(pageLayoutSectionRecord.SVMXC__Detail_Type__c == 'Section' || pageLayoutSectionRecord.SVMXC__Detail_Type__c == 'Button'){
                SFM_WrapperDef2.SFM2_LayoutSection layoutSection = new SFM_WrapperDef2.SFM2_LayoutSection();
                if(!isClone){
                layoutSection.sectionId = pageLayoutSectionRecord.Id;
                }
                layoutSection.sectionType = pageLayoutSectionRecord.SVMXC__Detail_Type__c;
                layoutSection.sequence = pageLayoutSectionRecord.SVMXC__Sequence__c != null ? Integer.valueOf(pageLayoutSectionRecord.SVMXC__Sequence__c): null;
                layoutSection.columns = pageLayoutSectionRecord.SVMXC__No_Of_Columns__c != null ? Integer.valueOf(pageLayoutSectionRecord.SVMXC__No_Of_Columns__c): null;
                layoutSection.title = pageLayoutSectionRecord.SVMXC__Title__c;
                layoutSection.description = pageLayoutSectionRecord.SVMXC__SM_Description__c;
                layoutSection.helpUrl = pageLayoutSectionRecord.SVMXC__SM_Help_URL__c;
                layoutSection.showinWeb = pageLayoutSectionRecord.SVMXC__Show_In_Web__c;
                layoutSection.showinIpad = pageLayoutSectionRecord.SVMXC__Show_In_iPad__c;
                layoutSection.useForSLA = pageLayoutSectionRecord.SVMXC__Use_For_SLA_Clock__c;
                sectionWrapperMap.put(pageLayoutSectionRecord.Id, layoutSection);

                if(pageLayoutSectionRecord.SVMXC__Detail_Type__c == 'Button'){
                    buttonIds.add(pageLayoutSectionRecord.Id);
                } else {
                    sectionIds.add(pageLayoutSectionRecord.Id);
                }
                //layoutElementsSectionMap.put(pageLayoutSectionRecord.Id, new List<SVMXC__Page_Layout_Detail__c>());

            }else if(pageLayoutSectionRecord.SVMXC__Detail_Type__c == 'Field' || pageLayoutSectionRecord.SVMXC__Detail_Type__c == 'Question'){
                
                List<SVMXC__Page_Layout_Detail__c> tempList = new List<SVMXC__Page_Layout_Detail__c>();
                if(layoutElementsSectionMap.containsKey(pageLayoutSectionRecord.SVMXC__Section__c)){
                    tempList = layoutElementsSectionMap.get(pageLayoutSectionRecord.SVMXC__Section__c);
                }

                //elementIds.add(pageLayoutSectionRecord.Id);
                tempList.add(pageLayoutSectionRecord);
                layoutElementsSectionMap.put(pageLayoutSectionRecord.SVMXC__Section__c, tempList);
            }
        }


        /*
            For Child Detail Layouts
        */
        for(SVMXC__Page_Layout__c pageLayoutRecord : layoutChildDetails){
            SFM_WrapperDef2.SFM2_LayoutSection childlayoutWrapper = new SFM_WrapperDef2.SFM2_LayoutSection();
            if(!isClone){
            childlayoutWrapper.sectionId = pageLayoutRecord.Id;
            }
            childlayoutWrapper.sectionType = pageLayoutRecord.SVMXC__Type__c;
            childlayoutWrapper.childAPIName = pageLayoutRecord.SVMXC__Object_Name__c;
            childlayoutWrapper.allowZeroLines = pageLayoutRecord.SVMXC__Action_On_Zero_Lines__c;
            childlayoutWrapper.allowNew = pageLayoutRecord.SVMXC__Allow_New_Lines__c;
            childlayoutWrapper.allowDelete = pageLayoutRecord.SVMXC__Allow_Delete_Lines__c;
            childlayoutWrapper.multiAddField = pageLayoutRecord.SVMXC__Multi_Add_Search_Field__c;
            childlayoutWrapper.multiAddObject = pageLayoutRecord.SVMXC__Multi_Add_Search_Object__c;
            childlayoutWrapper.headerReferenceField = pageLayoutRecord.SVMXC__Header_Reference_Field__c;   
            childlayoutWrapper.sequence = Integer.valueOf(pageLayoutRecord.SVMXC__Sequence__c);
            childlayoutWrapper.columns = Integer.valueOf(pageLayoutRecord.SVMXC__No_Of_Columns__c);
            childlayoutWrapper.title = pageLayoutRecord.SVMXC__Name__c;
            childlayoutWrapper.objectAlias = pageLayoutRecord.SVMXC__Page_Layout_ID__c;
            sectionWrapperMap.put(pageLayoutRecord.Id, childlayoutWrapper);
            detailLayoutIds.add(pageLayoutRecord.Id);
        }


        if(!detailLayoutIds.isEmpty()){
        for(SVMXC__Page_Layout__c childLayout : [SELECT Id, (SELECT Id, SVMXC__Event_Call_Type__c, SVMXC__Event_Type__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Code_Snippet__c, SVMXC__Code_Snippet__r.Name, 
                              SVMXC__ServiceMax_Custom_Action__c FROM SVMXC__SFM_Event__r) FROM SVMXC__Page_Layout__c WHERE Id IN: detailLayoutIds]){

            //layoutElementsSectionMap.put(childLayout.Id, childLayout.SVMXC__Page_Layout_Details__r);
            
            if(sectionWrapperMap.containsKey(childLayout.Id)){
                SFM_WrapperDef2.SFM2_LayoutSection childlayoutWrapper = sectionWrapperMap.get(childLayout.Id);
                
                if(!childLayout.SVMXC__SFM_Event__r.isEmpty()){
                        childlayoutWrapper.events = eventWrapper(childLayout.SVMXC__SFM_Event__r, isClone);
                    }
                }
            }
        }

        elementEventsMap = new Map<Id, List<SVMXC__SFM_Event__c>>();
        
        for(SVMXC__SFM_Event__c eventRecord : [SELECT Id, SVMXC__Event_Call_Type__c, SVMXC__Page_Layout_Detail__c, SVMXC__Event_Type__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Code_Snippet__c, SVMXC__Code_Snippet__r.Name, SVMXC__ServiceMax_Custom_Action__c 
                              FROM SVMXC__SFM_Event__c WHERE SVMXC__Page_Layout_Detail__r.SVMXC__Section__c IN : sectionIds OR SVMXC__Page_Layout_Detail__r.SVMXC__Page_Layout__c IN: detailLayoutIds OR SVMXC__Page_Layout_Detail__c IN: buttonIds]){

            List<SVMXC__SFM_Event__c> tempList = new List<SVMXC__SFM_Event__c>();
            
            if(elementEventsMap.containsKey(eventRecord.SVMXC__Page_Layout_Detail__c)){
                tempList = elementEventsMap.get(eventRecord.SVMXC__Page_Layout_Detail__c);
            }

            tempList.add(eventRecord);
            elementEventsMap.put(eventRecord.SVMXC__Page_Layout_Detail__c, tempList);

            if(sectionWrapperMap.containsKey(eventRecord.SVMXC__Page_Layout_Detail__c)){
                SFM_WrapperDef2.SFM2_LayoutSection buttonlayoutWrapper = sectionWrapperMap.get(eventRecord.SVMXC__Page_Layout_Detail__c);
                buttonlayoutWrapper.events = eventWrapper(new List<SVMXC__SFM_Event__c>{eventRecord}, isClone);
            }

        }

        /*
            To prevent 'Aggregate query has too many rows for direct assignment, use FOR loop limit exception' additional query is being used
        */
        if(!detailLayoutIds.isEmpty()){
            for(SVMXC__Page_Layout_Detail__c pageDetailRecord : [SELECT Id, SVMXC__Detail_Type__c, SVMXC__Field_API_Name__c, SVMXC__DataType__c, SVMXC__No_Of_Columns__c, SVMXC__Section__c, SVMXC__Page_Layout__c,
                                                                    SVMXC__Question__c, SVMXC__Display_Column__c, SVMXC__Display_Row__c, SVMXC__Sequence__c, SVMXC__Title__c, SVMXC__Required__c, SVMXC__Readonly__c,
                                                                SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Named_Search__c, SVMXC__Override_Related_Lookup__c, SVMXC__SM_Checklist_Source_Field_API_Name__c,
                                                               SVMXC__Lookup_Context__c, SVMXC__Lookup_Query_Field__c, SVMXC__Field_Mapping__c, SVMXC__Context_Source_Object__c FROM SVMXC__Page_Layout_Detail__c 
                                                               WHERE SVMXC__Page_Layout__c IN: detailLayoutIds]){

                List<SVMXC__Page_Layout_Detail__c> tempList = new List<SVMXC__Page_Layout_Detail__c>();
                if(layoutElementsSectionMap.containsKey(pageDetailRecord.SVMXC__Page_Layout__c)){
                    tempList = layoutElementsSectionMap.get(pageDetailRecord.SVMXC__Page_Layout__c);
                }
                tempList.add(pageDetailRecord);
                layoutElementsSectionMap.put(pageDetailRecord.SVMXC__Page_Layout__c, tempList);
            }
        }

        if(!sectionIds.isEmpty()){
            Map<String, SVMXC__ServiceMax_Processes__c> sectionCriteriaMap = new Map<String, SVMXC__ServiceMax_Processes__c>();
            sectionEntryCriteriaMap = new Map<String, String>();
            for(SVMXC__ServiceMax_Processes__c criteriaJunctionRecord : [SELECT Id, SVMXC__Process3__c, SVMXC__SM_Section__c, SVMXC__Rule_Type__c, SVMXC__SM_Target_Section__c, SVMXC__SM_Target_Section__r.SVMXC__Sequence__c, SVMXC__Sequence__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__SM_Section__c IN: sectionIds
                                                                            AND RecordType.Name = 'Process Business Rule' AND SVMXC__Rule_Type__c IN ('Checklist_Section_Entry_Criteria', 'Checklist_Section_Exit_Criteria') AND SVMXC__SM_Section__c != null]){

                if(criteriaJunctionRecord.SVMXC__Process3__c != null){
                    if(criteriaJunctionRecord.SVMXC__Rule_Type__c.equalsIgnoreCase('Checklist_Section_Entry_Criteria')){
                        sectionEntryCriteriaMap.put(criteriaJunctionRecord.SVMXC__SM_Section__c, criteriaJunctionRecord.SVMXC__Process3__c);
                    }else{
                        sectionCriteriaMap.put(criteriaJunctionRecord.SVMXC__Process3__c, criteriaJunctionRecord);
                    }
                }
            } 
            
            if(!sectionCriteriaMap.keySet().isEmpty()){
                sectionExitCriteriaMap = new Map<String, List<SFM_WrapperDef2.SFM2_Rule>>();
                SFM_SaveAsExpression buildSFMRuleClass = new SFM_SaveAsExpression();
                List<String> ruleIds = new List<String>(sectionCriteriaMap.keySet());
                for(SVMXC__ServiceMax_Processes__c businessRuleRec : new SFM_GetNamedExpressionList().queryRuleRecords(null, ruleIds, true, SFM_DesignerUtils.entity_sectionCriteria)){
                    if(sectionCriteriaMap.containsKey(businessRuleRec.Id)){
                        SVMXC__ServiceMax_Processes__c junctionRecord = sectionCriteriaMap.get(businessRuleRec.Id);
                        String sectionId = junctionRecord.SVMXC__SM_Section__c;
            			if(sectionWrapperMap.containsKey(sectionId)){
               			 	SFM_WrapperDef2.SFM2_LayoutSection layoutSection = sectionWrapperMap.get(sectionId);
                            SFM_WrapperDef2.SFM2_Rule ruleDef;
                            List<SFM_WrapperDef2.SFM2_Rule> tempList;
                            ruleDef = buildSFMRuleClass.buildSFM2Rule(businessRuleRec, SFM_DesignerUtils.entity_sectionCriteria, isClone);
                            tempList = new List<SFM_WrapperDef2.SFM2_Rule>();
                            ruleDef.sequence = junctionRecord.SVMXC__Sequence__c != null ?  Integer.valueOf(junctionRecord.SVMXC__Sequence__c) : 1;
                            ruleDef.targetSequence = junctionRecord.SVMXC__SM_Target_Section__r.SVMXC__Sequence__c != null ? Integer.valueOf(junctionRecord.SVMXC__SM_Target_Section__r.SVMXC__Sequence__c) : null;
                            if(sectionExitCriteriaMap.containsKey(sectionId)){
                                tempList = sectionExitCriteriaMap.get(sectionId);
                            }
                            tempList.add(ruleDef);
                            sectionExitCriteriaMap.put(sectionId, tempList);
                        }
                    }
                } 
            }                       
        }
        for(String sectionId : sectionWrapperMap.keySet()){
            SFM_WrapperDef2.SFM2_LayoutSection layoutSection = sectionWrapperMap.get(sectionId);
            if(layoutElementsSectionMap.containsKey(sectionId)){
                layoutSection.layoutElements = layoutElementWrapper(layoutElementsSectionMap.get(sectionId), isClone);
            }
            if(sectionEntryCriteriaMap != null && sectionEntryCriteriaMap.containsKey(sectionId)){
                layoutSection.entryCriteriaId = sectionEntryCriteriaMap.get(sectionId);
        }        
        
            if(sectionExitCriteriaMap != null && sectionExitCriteriaMap.containsKey(sectionId)){
                layoutSection.exitCriteria = sectionExitCriteriaMap.get(sectionId);
            }            
        }

        return sectionWrapperMap.values();
        
    }

    public List<SFM_WrapperDef2.SFM2_LayoutElement> layoutElementWrapper(List<SVMXC__Page_Layout_Detail__c> pageLayoutDetails, boolean isClone){

        List<SFM_WrapperDef2.SFM2_LayoutElement> layoutElementsList = new List<SFM_WrapperDef2.SFM2_LayoutElement>();
        for(SVMXC__Page_Layout_Detail__c pageDetailRecord : pageLayoutDetails){
            SFM_WrapperDef2.SFM2_LayoutElement layoutElement = new SFM_WrapperDef2.SFM2_LayoutElement();
            if(!isClone){
            layoutElement.eltId = pageDetailRecord.Id;
            }
            layoutElement.eltType = pageDetailRecord.SVMXC__Detail_Type__c;
            layoutElement.aPIName = pageDetailRecord.SVMXC__Field_API_Name__c;
            layoutElement.dataType = pageDetailRecord.SVMXC__DataType__c != null ? pageDetailRecord.SVMXC__DataType__c.toUpperCase() : null;
            layoutElement.sequence = Integer.valueOf(pageDetailRecord.SVMXC__Sequence__c);
            layoutElement.row = Integer.valueOf(pageDetailRecord.SVMXC__Display_Row__c);
            layoutElement.column = Integer.valueOf(pageDetailRecord.SVMXC__Display_Column__c);
            layoutElement.noOfColumn = Integer.valueOf(pageDetailRecord.SVMXC__No_Of_Columns__c);
            layoutElement.title = pageDetailRecord.SVMXC__Title__c;
            layoutElement.required = pageDetailRecord.SVMXC__Required__c;
            layoutElement.readOnly = pageDetailRecord.SVMXC__Readonly__c;
            layoutElement.referenceTo = pageDetailRecord.SVMXC__Related_Object_Name__c;
            layoutElement.referenceNameField = pageDetailRecord.SVMXC__Related_Object_Name_Field__c;
            layoutElement.lkpupConfig = pageDetailRecord.SVMXC__Named_Search__c;
            layoutElement.overrideContext = pageDetailRecord.SVMXC__Override_Related_Lookup__c;
            layoutElement.lkpContext = pageDetailRecord.SVMXC__Lookup_Context__c;
            layoutElement.lkpMatchField = pageDetailRecord.SVMXC__Lookup_Query_Field__c;
            layoutElement.lkpFormFill = pageDetailRecord.SVMXC__Field_Mapping__c;
            layoutElement.lkpContextSrc = pageDetailRecord.SVMXC__Context_Source_Object__c;
            layoutElement.questionId = pageDetailRecord.SVMXC__Question__c;
            layoutElement.checklistSourceField = pageDetailRecord.SVMXC__SM_Checklist_Source_Field_API_Name__c;
            if(elementEventsMap != null && elementEventsMap.containsKey(pageDetailRecord.Id)){
                layoutElement.events = eventWrapper(elementEventsMap.get(pageDetailRecord.Id), isClone);
            }

            layoutElementsList.add(layoutElement);
        }
        return layoutElementsList;
    }
}