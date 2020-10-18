public with sharing class INTF_GetPageLayout 
{
//Internal Wrapper class
    public class SFMException extends Exception {}
    public Integer Linelimit = 200;
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
    map<Id,SVMXC__ServiceMax_Processes__c> SFMProcessMap = new map<Id,SVMXC__ServiceMax_Processes__c>();
    SVMXC.INTF_parseProcess parseProcess = new SVMXC.INTF_parseProcess();
    SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils(); 
    SVMXC.SFM_Utils SFMUtils = new SVMXC.SFM_Utils(); 
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
    public map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    public map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>(); 
    public map<String,String> PageIdMapId = new map<String,String>();
    public map<String,String> PrifixMap = new map<String,String>();
    map<String, String> AllSubModuleSettings = new map<String, String>();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    //Constructor 
    public INTF_getPageLayout()
    {
        gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            Schema.DescribeSObjectResult result = s.getDescribe();
            allobjmap.put(result.getName(),s);
            PrifixMap.put(result.getKeyPrefix(),result.getName());
        } 
        SFMProcessMap.putall([select id,SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c != null]);
        system.debug('SFMProcessMap '+SFMProcessMap ); 
        /*AllSubModuleSettings = settings.SVMX_getSettingList('SFM002');
        if(AllSubModuleSettings.containskey('SET001'))
            Linelimit = Integer.valueof(AllSubModuleSettings.get('SET001'));*/
    }
    public INTF_WebServicesDef.INTF_Response_PageUI INTF_GetPageLayout(INTF_WebServicesDef.INTF_Request_PageUI PmaxReqPageUI)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('INTF_GetPageLayout');
        I18N_TranslationDelivery translationObj;
        map<String,map<String,Schema.SObjectField>> AllFieldDescribe = new map<String,map<String,Schema.SObjectField>>();
        map<String,Schema.SObjectField> mapHeaderTargetField = new map<String,Schema.SObjectField>();
        map<String,String> mapAliasNameObjName = new map<String,String>();
        String TargetManager = '';
        String ProcessNodeObj = '';
        List<RecordType> RecordTypes = new List<RecordType>();
        INTF_DataSync.logSOQL(intMethodCount, 'Select Name, Id From RecordType where SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND (Name = \'Target Manager\' OR Name = \'Process Node Objects\')');
        RecordTypes = [Select Name, Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND (Name = 'Target Manager' OR Name = 'Process Node Objects')];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
        }
        SVMXC.INTF_WebServicesDef.INTF_Response_PageUI PageResponseUI = new SVMXC.INTF_WebServicesDef.INTF_Response_PageUI();
        SVMXC.INTF_WebServicesDef.INTF_Response SFMResponse = new SVMXC.INTF_WebServicesDef.INTF_Response();
        //Naveen: This is inroduced for the fields that are going to create now to avoid the WSDL Import to the IPad
        SVMXC.INTF_WebServicesDef.INTF_StringMap addFieldsIntroduced = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        SFMResponse.MapStringMap = new List<INTF_WebServicesDef.INTF_MapStringMap>();
        SFMResponse.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        List<String> codeSnippetIds = new List<String>();
        /*End*/                                            
        SVMX_Debug  log = new SVMX_Debug();
        list<SVMXC__ServiceMax_Processes__c> ProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        map<String,List<Sobject>> TargetRecMap = new map<String,List<Sobject>>(); 
        map<String, Schema.SObjectField> Fieldmap = new map<String, Schema.SObjectField>();
        List<String> HdrFieldLst = new List<String>(); 
        /*string userId = PmaxReqPageUI.request.userId;
        string groupId = PmaxReqPageUI.request.groupId;
        string profileId = PmaxReqPageUI.request.profileId;*/ 
        String pageId = '';
        String RecId = '';
        string ProcessId = '';
        string strClientType = '';
        String HdrObjectName = '';
        String NameField = '';
        String NameFieldLabel = '';
        String ProcessTitle = '';
        String TargetObjName = '';
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> ResponseStringMapList = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringListMap> ResponseStringListMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringListMap>(); 
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
        Map<String,List<SVMXC__SFM_Event__c>> FLdEventMap = new Map<String,List<SVMXC__SFM_Event__c>>();
        Map<String,List<SVMXC__SFM_Event__c>> BtnEventMap = new Map<String,List<SVMXC__SFM_Event__c>>();
        map<String,String> SourceObjectParentColumnMap = new map<String,String>();
        map<String,String> ChildObjSourceTargetMap = new map<String,String>();
        List<SVMXC.INTF_WebServicesDef.INTF_UISection> Sections = new List<SVMXC.INTF_WebServicesDef.INTF_UISection>();
        List<SVMXC.INTF_WebServicesDef.INTF_UIButton> Buttons = new List<SVMXC.INTF_WebServicesDef.INTF_UIButton>();
        
        SVMXC.INTF_WebServicesDef.INTF_PageUI  pageui = new SVMXC.INTF_WebServicesDef.INTF_PageUI();
        Boolean isCalculateSLA;
        log.login('SFM_PageLayout', 'SFM_GetPageLayout');
        system.debug('StringMap'+StringMap);
        if(StringMap.size() > 0)
        {
            //log.setlog('LOOPING-Start', 'To set ProcessId and pageId values based on the key');
            for(Integer i = 0; i<StringMap.size(); i++)
            {
                if(StringMap[i].key != null && StringMap[i].key.toUppercase() == 'PAGEID' && StringMap[i].value != null && StringMap[i].value.length() > 0)
                {
                    pageId = StringMap[i].value;
                }
                if(StringMap[i].key != null && StringMap[i].key.toUppercase() == 'RECORDID' && StringMap[i].value != null && StringMap[i].value.length() > 0)
                {
                    RecId = StringMap[i].value;
                }
                if(StringMap[i].key != null && StringMap[i].key.toUppercase() == 'PROCESSID' && StringMap[i].value != null && StringMap[i].value.length() > 0)
                {
                    ProcessId = StringMap[i].value;
                } 
                if(StringMap[i].key != null && StringMap[i].key.toUppercase() == 'CLIENT_TYPE' && StringMap[i].value != null && StringMap[i].value.length() > 0)
                {
                    strClientType = StringMap[i].value;
                } 
            }
            //log.setlog('LOOPING-End', 'To set ProcessId and pageId values based on the key');
        }
        //Get The Process and Process Node Objects
        if(ProcessId != null && ProcessId.length() > 0)
        {
           list<SVMXC__ServiceMax_Processes__c> ProList = new list<SVMXC__ServiceMax_Processes__c>(); 
           INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Tag_Keys__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Type__c, SVMXC__Target_Record_Type__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c where RecordTypeId =: TargetManager and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)');
           ProList = [Select SVMXC__Tag_Keys__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Type__c, SVMXC__Target_Record_Type__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c where RecordTypeId =: TargetManager and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
           if(ProList.size() > 0)
           {
                Process = ProList[0];
                
                if(Process.SVMXC__Tag_Keys__c != NULL && Process.SVMXC__Tag_Keys__c.length() > 0)
                    translationObj = new I18N_TranslationDelivery(Process.SVMXC__Tag_Keys__c, UserInfo.getLanguage());
                    
                if(Process != null && Process.SVMXC__Dispatch_Process_Status__c != null && Process.SVMXC__Dispatch_Process_Status__c.touppercase() != 'COMPLETE')
                {
                    SFMResponse.success = false;
                    SFMResponse.message = system.Label.SFM002_TAG056;
                    PageResponseUI.response = SFMResponse;
                    system.debug('PageResponseUI'+PageResponseUI);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'INTF_GetPageLayout');
                    return PageResponseUI;
                }
                INTF_DataSync.logSOQL(intMethodCount, 'Select  SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c,SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__c,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From  SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: Process.id and RecordTypeId =: ProcessNodeObj');
                ProcessNodeObjects = [Select  SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c,SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__c,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From  SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: Process.id and RecordTypeId =: ProcessNodeObj];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(Process.SVMXC__Purpose__c.touppercase() == 'STANDALONE EDIT')
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    strmap.key = 'PROCESSTYPE';
                    strmap.value = 'EDIT';
                    SFMResponse.stringMap.add(strmap);
                }
                else if(Process.SVMXC__Purpose__c.touppercase() == 'VIEW RECORD')
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    strmap.key = 'PROCESSTYPE';
                    strmap.value = 'VIEWRECORD';
                    SFMResponse.stringMap.add(strmap);
                }
                else if(Process.SVMXC__Purpose__c.touppercase() == 'STANDALONE CREATE')
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    strmap.key = 'PROCESSTYPE';
                    strmap.value = 'STANDALONECREATE';
                    SFMResponse.stringMap.add(strmap);
                }
                else if(Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL')
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    strmap.key = 'PROCESSTYPE';
                    strmap.value = 'SOURCETOTARGET';
                    SFMResponse.stringMap.add(strmap);
                }
                else if(Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD')
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    strmap.key = 'PROCESSTYPE';
                    strmap.value = 'SOURCETOTARGETONLYCHILDROWS';
                    SFMResponse.stringMap.add(strmap);
                }
           }
           else
           {
            // If there is no process for the request than we send failure
                SFMResponse.success = false;
                SFMResponse.message = system.Label.SFM002_TAG001;
                PageResponseUI.response = SFMResponse;
                system.debug('PageResponseUI'+PageResponseUI);
                INTF_DataSync.logMethodEndTS(intMethodCount, 'INTF_GetPageLayout');
                return PageResponseUI;
           }    
        }
        //first creare a response for the parent column name..
        if(ProcessNodeObjects.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c Pro : ProcessNodeObjects)
            {
                if(Pro.SVMXC__Type__c.touppercase() == 'TARGETCHILD')
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    if(Pro.SVMXC__Parent_Column_Name__c != null && Pro.SVMXC__Page_Layout__c != null)//here we have changed the apporoch of alias now we will pass the pagelayot id coresponding process node object
                    {
                        strmap.key = Pro.SVMXC__Page_Layout__c;
                        strmap.value = Pro.SVMXC__Parent_Column_Name__c;
                        ResponseStringMapList.add(strmap);
                    }
                    if(pro.SVMXC__Node_Source_Object_API__c != null && pro.SVMXC__Source_Object_Name__c != null && ChildObjSourceTargetMap.containskey(pro.SVMXC__Node_Source_Object_API__c) == false)
                    {
                      ChildObjSourceTargetMap.put(pro.SVMXC__Node_Source_Object_API__c,pro.SVMXC__Source_Object_Name__c);
                    }
                    if(Pro.SVMXC__Page_Layout__c != null && pro.SVMXC__Source_Object_Name__c != null)
                        mapAliasNameObjName.put(string.valueof(Pro.SVMXC__Page_Layout__c).substring(0,15),pro.SVMXC__Source_Object_Name__c);
                }
                if(Pro.SVMXC__Type__c.touppercase() == 'SOURCECHILD')
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmap1 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
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
                }
                if(Pro.SVMXC__Type__c.touppercase() == 'TARGET' && Pro.SVMXC__Source_Object_Name__c != null)
                {
                    TargetObjName = Pro.SVMXC__Source_Object_Name__c;
                }
            }
            SFMResponse.stringMap.addall(ResponseStringMapList);
        }
        system.debug('mapAliasNameObjName'+mapAliasNameObjName);
        system.debug('ResponseStringMapList'+ResponseStringMapList);
        system.debug('SourceObjectParentColumnMap'+SourceObjectParentColumnMap);
        system.debug('ChildObjSourceTargetMap'+ChildObjSourceTargetMap);
        //Response for the Source Update Record
        if(Process != null && Process.SVMXC__Purpose__c != null)
        {
            if(Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD')
            {
              if(TargetObjName != null && TargetObjName.length() > 0 && RecId != null && RecId.length() > 0)
              {
                  SVMXC.INTF_WebServicesDef.INTF_StringListMap strlstmap = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
                  strlstmap.key = TargetObjName;
                  strlstmap.valueList.add(RecId);
                  ResponseStringListMap.add(strlstmap);
              }   
              if(SourceObjectParentColumnMap.size() > 0 && RecId != null && RecId.length() > 0)
              {
                  for(String s : SourceObjectParentColumnMap.keyset())
                  {
                      String Query = 'Select id from '+s+' Where '+SourceObjectParentColumnMap.get(s)+ '= \''+RecId+'\'' ;
                      system.debug('Query'+Query);
                      INTF_DataSync.logSOQL(intMethodCount, Query);
                      List<Sobject> Sobj = Database.Query(Query);
                      system.debug('Sobj'+Sobj);
                      if(Sobj.size() > 0)
                      {
                          SVMXC.INTF_WebServicesDef.INTF_StringListMap strlstmap = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
                          if(ChildObjSourceTargetMap.containskey(s))
                            strlstmap.key = ChildObjSourceTargetMap.get(s);
                          for(Integer j = 0;j<Sobj.size();j++)
                          {
                              if(Sobj[j].get('Id') != null)
                                  strlstmap.valueList.add(String.valueof(Sobj[j].get('Id')));
                          }
                          ResponseStringListMap.add(strlstmap);   
                      }   
                  }
              }
              system.debug('ResponseStringListMap'+ResponseStringListMap);
              SFMResponse.StringLstMap.addall(ResponseStringListMap); 
            }    
        }
        checkQueryLimit();
        //Parse the process and get the Header & Detail Records....
        if(ProcessId != null && ProcessId.length() > 0)//&& RecId != null && RecId.length() > 0
        {
            // Get the Header & Detail Records Map Follwing method will apply  Expression & Mapping and return the map of Qulified Header Detail reocrds.
            TargetRecMap = parseProcess.getINTF_ParseProcess(ProcessId,RecId,allobjmap);//
            system.debug('TargetRecMap'+TargetRecMap);
            map<String,Schema.SObjectField> fldmap = new map<String,Schema.SObjectField>();
            if(RecId != null && RecId.length() > 0 && PrifixMap.containskey(RecId.substring(0,3)))
                fldmap = allobjmap.get(PrifixMap.get(RecId.substring(0,3))).getDescribe().fields.getMap(); 
            if(fldmap.size() > 0)
            {
                for(String s : fldmap.keyset())
                {
                    if((allobjmap.get(PrifixMap.get(RecId.substring(0,3))) == Account.SObjectType && fldmap.get(s).getdescribe().getName() == 'Name') || (allobjmap.get(PrifixMap.get(RecId.substring(0,3))) != Account.SObjectType && fldmap.get(s).getdescribe().isNameField()))
                        {
                        NameField = fldmap.get(s).getdescribe().getName();
                        NameFieldLabel = fldmap.get(s).getdescribe().getlabel();
                    }   
                }
            }
            if(TargetObjName != null && allobjmap.containskey(TargetObjName))
            {
                map<String,Schema.SObjectField> mapHeaderTargetFieldTemp = new map<String,Schema.SObjectField>();
                mapHeaderTargetFieldTemp = allobjmap.get(TargetObjName).getDescribe().fields.getMap();
                if(mapHeaderTargetFieldTemp.size() > 0)
                {
                    for(String s:mapHeaderTargetFieldTemp.keyset())
                    {
                        mapHeaderTargetField.put(mapHeaderTargetFieldTemp.get(s).getDescribe().getName(),mapHeaderTargetFieldTemp.get(s));
                    }
                }
                if(mapHeaderTargetField.size() > 0 && !AllFieldDescribe.containskey(TargetObjName))
                    AllFieldDescribe.put(TargetObjName,mapHeaderTargetField);
            }
        }   
        if(Process != null && Process.SVMXC__Page_Layout__c != null)
            pageId = Process.SVMXC__Page_Layout__c;
            
        system.debug(LoggingLevel.WARN, 'pageId  = ' + pageId);
        if(pageId != null && pageId.length() > 0)
        {
            INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Tag_Keys__c From SVMXC__ServiceMax_Processes__c where SVMXC__Page_Layout__c =: pageId AND SVMXC__Page_Layout__c != NULL Limit 1');
            SVMXC__ServiceMax_Processes__c SFMProc = [Select SVMXC__Tag_Keys__c From SVMXC__ServiceMax_Processes__c where SVMXC__Page_Layout__c =: pageId AND SVMXC__Page_Layout__c != NULL Limit 1];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(SFMProc != NULL && SFMProc.SVMXC__Tag_Keys__c != NULL && SFMProc.SVMXC__Tag_Keys__c.length() > 0)
                translationObj = new I18N_TranslationDelivery(SFMProc.SVMXC__Tag_Keys__c, UserInfo.getLanguage());
                
            //Get the HeaderpageLayout 
            //log.setlog('QUERY_TEXT','Retrieving the pagelayout for the pageid');
            INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Enable_Service_Report_View__c, SVMXC__Enable_Service_Report_Generation__c, SVMXC__Enable_Troubleshooting__c, SVMXC__Type__c,SVMXC__Sequence__c,SVMXC__Prompt_For_New_Event__c,SVMXC__Enable_Attachments__c,SVMXC__Enable_Chatter__c,SVMXC__Show_Account_History__c,SVMXC__Show_All_Sections_By_Default__c,SVMXC__Show_Product_History__c,'+
             'SVMXC__Hide_Save__c,SVMXC__Hide_Quick_Save__c,SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c,'+ 
             'SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c, SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate,'+ 
             'LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById SVMXC__SM_Title_Bar__c, SVMXC__SM_Summary_Title__c, SVMXC__SM_Include_Summary__c, SVMXC__SM_Include_Time_and_Place__c,'+
             'SVMXC__SM_Include_Contact__c, SVMXC__SM_Include_Field1__c, SVMXC__SM_Include_Field2__c, SVMXC__SM_Include_Field3__c'+
             'From SVMXC__Page_Layout__c where id =: pageId OR Name =: pageId OR SVMXC__Page_Layout_ID__c =: pageId');
            HeaderLayout = [Select SVMXC__Enable_Service_Report_View__c, SVMXC__Enable_Service_Report_Generation__c, SVMXC__Enable_Troubleshooting__c, SVMXC__Type__c,SVMXC__Sequence__c,SVMXC__Prompt_For_New_Event__c,SVMXC__Enable_Attachments__c,SVMXC__Enable_Chatter__c,SVMXC__Show_Account_History__c,SVMXC__Show_All_Sections_By_Default__c,SVMXC__Show_Product_History__c,
             SVMXC__Hide_Save__c,SVMXC__Hide_Quick_Save__c,SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, 
             SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c, SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate, 
             LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById, SVMXC__SM_Title_Bar__c, SVMXC__SM_Summary_Title__c, SVMXC__SM_Include_Summary__c, SVMXC__SM_Include_Time_and_Place__c,
             SVMXC__SM_Include_Contact__c, SVMXC__SM_Include_Field1__c, SVMXC__SM_Include_Field2__c, SVMXC__SM_Include_Field3__c 
             From SVMXC__Page_Layout__c where id =: pageId OR Name =: pageId OR SVMXC__Page_Layout_ID__c =: pageId];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(translationObj != null)
                HeaderLayout = translationObj.SVMX_GetPageLayoutTranslation(HeaderLayout);
                
            system.debug('HeaderLayout'+HeaderLayout);
            /*Naveen: Added for IPad purpose as they need to avoid the importing of the WSDL for the metadata changes */
            List<SVMXC.INTF_WebServicesDef.INTF_StringMap> mapAdditionalFields = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            addFieldsIntroduced.key = 'HideSave';
            addFieldsIntroduced.value = String.valueOf(HeaderLayout.SVMXC__Hide_Save__c);
            mapAdditionalFields.add(addFieldsIntroduced);
            addFieldsIntroduced = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
            addFieldsIntroduced.key = 'HideQuickSave';
            addFieldsIntroduced.value = String.valueOf(HeaderLayout.SVMXC__Hide_Quick_Save__c);
            mapAdditionalFields.add(addFieldsIntroduced);
            SFMResponse.MapStringMap.add(new SVMXC.INTF_WebServicesDef.INTF_MapStringMap('HeaderFields',mapAdditionalFields));
            /*Naveen: Added for IPad purpose */
        }
        //Get the Header Data For the page..
        system.debug('TargetRecMap'+TargetRecMap);
        if(TargetRecMap.size() > 0 && HeaderLayout.SVMXC__Object_Name__c != null  && TargetRecMap.containskey(HeaderLayout.SVMXC__Object_Name__c))
        {
            HdrRecords = TargetRecMap.get(HeaderLayout.SVMXC__Object_Name__c);
            if(HeaderLayout.SVMXC__Object_Name__c == 'SVMXC__Service_Order__c' || HeaderLayout.SVMXC__Object_Name__c == 'Service_Order__c')
            {
            isCalculateSLA = true;
            }
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
                        INTF_DataSync.logSOQL(intMethodCount, 'select id,SVMXC__Parent_Error_Msg__c from SVMXC__ServiceMax_Processes__c where id =: ExpId');
                        SVMXC__ServiceMax_Processes__c exp = [select id,SVMXC__Parent_Error_Msg__c from SVMXC__ServiceMax_Processes__c where id =: ExpId];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        if(exp != null && exp.SVMXC__Parent_Error_Msg__c != null)
                        {
                            system.debug('asdf12');
                            SFMResponse.success = false;
                            SFMResponse.message = exp.SVMXC__Parent_Error_Msg__c; 
                        }
                        else
                        {   
                            SFMResponse.success = false;
                            //SFMResponse.message = 'Header Expresssion is not qualified';
                            system.debug('asdf'+'Header Expresssion is not qualified');
                            SFMResponse.message = system.Label.SFM001_TAG158;
                        }
                    }
                }            
                PageResponseUI.response = SFMResponse;
                system.debug('PageResponseUI'+PageResponseUI);
                INTF_DataSync.logMethodEndTS(intMethodCount, 'INTF_GetPageLayout');
                return PageResponseUI;
            }    
        }           
        checkQueryLimit();
        system.debug('HdrRecords'+HdrRecords);
        //set the process Title 
        if(Process != null && Process.SVMXC__Name__c != null)
        ProcessTitle =  Process.SVMXC__Name__c;
        if(NameFieldLabel != null && NameFieldLabel.length() > 0 && NameField != null && NameField.length() > 0 && RecId != null && PrifixMap.Containskey(RecId.substring(0,3))) 
        {
            String Query = 'Select '+NameField+ ' From ' +PrifixMap.get(RecId.substring(0,3))+' Where Id = \''+RecId+'\''; 
            system.debug('Query'+Query);
            INTF_DataSync.logSOQL(intMethodCount, Query);
            Sobject Sobj = Database.query(Query);
            if(Sobj != null)
                ProcessTitle += ' (' +NameFieldLabel+ ': ' + String.valueof(Sobj.get(NameField)) + ')';
        }
        pageui.processTitle = ProcessTitle;
        system.debug('ProcessTitle'+ProcessTitle);
        //Get the Event for Header Layout
        if(HeaderLayout.id != null)
        {
            //log.setlog('QUERY_TEXT', 'Retrieving the pageevents for the pagelayout');
            INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout__c =: HeaderLayout.id');
            HdrPageEvents = [Select SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout__c =: HeaderLayout.id];
            if(HdrPageEvents != NULL && HdrPageEvents.size() > 0)
            {
                for(SVMXC__SFM_Event__c event: HdrPageEvents)
                {
                    if(event.SVMXC__Target_Call__c != NULL && event.SVMXC__Target_Call__c.contains('__'))
                        event.SVMXC__Target_Call__c = event.SVMXC__Target_Call__c.replace('__', '/');
                    
                    if(event.SVMXC__Code_Snippet__c != NULL ){
                        codeSnippetIds.add(event.SVMXC__Code_Snippet__c);
                    }    
                }
            }
        }   
        //Get the Fileds,Sections,Buttons for HeaderPageLayout..
        if(HeaderLayout.id != null)
        {
            //log.setlog('QUERY_TEXT', 'Retrieving the detailed pagelayou for the header pagelayout');
            INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Show_In_iPad__c, SVMXC__Show_In_Web__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Title__c, SVMXC__IsStandard__c,SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c,SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id,SVMXC__No_of_columns__c, SVMXC__Use_For_SLA_Clock__c, SVMXC__Field_Mapping__c, SVMXC__Context_Source_Object__c, SVMXC__Question__c,SVMXC__SM_Description__c,SVMXC__SM_Help_URL__c,SVMXC__SM_Checklist_Source_Field_API_Name__c  From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: HeaderLayout.id');
            HdrDetail = [Select SVMXC__Show_In_iPad__c, SVMXC__Show_In_Web__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Title__c, SVMXC__IsStandard__c,SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c,SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id,SVMXC__No_of_columns__c, SVMXC__Use_For_SLA_Clock__c, SVMXC__Field_Mapping__c, SVMXC__Context_Source_Object__c, SVMXC__Question__c,SVMXC__SM_Description__c,SVMXC__SM_Help_URL__c,SVMXC__SM_Checklist_Source_Field_API_Name__c  From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: HeaderLayout.id];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('HdrDetail'+HdrDetail.size()+HdrDetail);
        }
        if(HdrDetail.size() > 0)
        {
            if(translationObj != null)
                HdrDetail = translationObj.SVMX_GetPageLayoutDetailTranslation(HdrDetail);
            
            //log.setlog('LOOPING-Start', 'To set headerdetails id');
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
            //log.setlog('QUERY_TEXT', 'Retrieving the Page Events for the detailed pagelayout');
            INTF_DataSync.logSOQL(intMethodCount,'Select SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : HdrDetailIds');
            HdrFldBtnEvents = [Select SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : HdrDetailIds];
            if(HdrFldBtnEvents != NULL && HdrFldBtnEvents.size() > 0)
            {
                for(SVMXC__SFM_Event__c event: HdrFldBtnEvents)
                {
                    if(event.SVMXC__Target_Call__c != NULL && event.SVMXC__Target_Call__c.contains('__'))
                        event.SVMXC__Target_Call__c = event.SVMXC__Target_Call__c.replace('__', '/');
                        
                    if(event.SVMXC__Code_Snippet__c != NULL ){
                        codeSnippetIds.add(event.SVMXC__Code_Snippet__c);
                    }    
                }
            }
        }
        system.debug('HdrFldBtnEvents'+HdrFldBtnEvents);
        //Make a Differnt List for Button & Field Events
        if(HdrDetail.size() > 0 && HdrFldBtnEvents.size() > 0)
        {
            for(Integer i = 0; i < HdrDetail.size(); i++)
            {
                for(Integer j = 0; j < HdrFldBtnEvents.size(); j++)
                {
                    if(HdrDetail[i].id == HdrFldBtnEvents[j].SVMXC__Page_Layout_Detail__c)
                    {
                        if(HdrDetail[i].SVMXC__Detail_Type__c == 'Button')
                        {
                            ButtonEvents.add(HdrFldBtnEvents[j]);
                        }
                        if(HdrDetail[i].SVMXC__Detail_Type__c == 'Field')
                        {
                            FieldEvents.add(HdrFldBtnEvents[j]);
                        }
                    }
                }
            }
        }
        //Make a Differnt List for Button,Field & Section 
        if(HdrDetail.size() > 0)
        {
            for(SVMXC__Page_Layout_Detail__c PLD : HdrDetail)
            {
                if(PLD.SVMXC__Detail_Type__c == 'Field' || PLD.SVMXC__Detail_Type__c == 'Question')
                    fieldLst.add(PLD);
                if(PLD.SVMXC__Detail_Type__c == 'Section')
                    SectionLst.add(PLD);
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
            system.debug('fieldLst'+fieldLst);
        }
        //Get the Field Event Map
        if(fieldLst.size() > 0)
        {
            for(Integer i = 0; i < fieldLst.size(); i++)
            {
                List<SVMXC__SFM_Event__c> templst = new List<SVMXC__SFM_Event__c>();
                for(Integer j = 0; j < FieldEvents.size(); j++)
                {
                    if(FieldEvents[j].SVMXC__Page_Layout_Detail__c == fieldLst[i].id)
                    {
                        templst.add(FieldEvents[j]);
                    }
                }
                FLdEventMap.put(fieldLst[i].id,templst);
            }
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
        checkQueryLimit();
        //Make the SFM_UIField & SFM_UISection...
        system.debug('SectionLst'+SectionLst);
        system.debug('fieldLst'+fieldLst);
        if(SectionLst.size() > 0)
        {
            //log.setlog('LOOPING-Start', 'Outer Loop for Layouts SectionList to add lookupconfig and fields');
            for(Integer i = 0;i< SectionLst.size();i++)
            {
                SVMXC.INTF_WebServicesDef.INTF_UISection  SectionUI = new SVMXC.INTF_WebServicesDef.INTF_UISection();
                SectionUI.sectionDetail = SectionLst[i];
                List<SVMXC.INTF_WebServicesDef.INTF_UIField> HdrFields = new List<SVMXC.INTF_WebServicesDef.INTF_UIField>();
                if(fieldLst.size() > 0)
                {
                //log.setlog('LOOPING-Start', 'Inner Loop for Layouts SectionList to add lookupconfig and fields');
                    for(Integer j = 0; j < fieldLst.size();j++)
                    {
                        if(SectionLst[i].id == fieldLst[j].SVMXC__Section__c) 
                        {
                            //system.debug('Enterd in..');
                            SVMXC.INTF_WebServicesDef.INTF_UIField FieldUI = new SVMXC.INTF_WebServicesDef.INTF_UIField();
                            FieldUI.fieldDetail = fieldLst[j];
                            SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper BubbleWrapper = new SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper();
                            if(HdrRecords.size() > 0)
                            {
                                if(isCalculateSLA == true)
                                {
                                    SVMXC.COMM_Utils_DateCalculation  DatCal = new SVMXC.COMM_Utils_DateCalculation();
                                    List<INTF_WebServicesDef.INTF_StringMap> slaTimer = new List<INTF_WebServicesDef.INTF_StringMap>();
                                    if(HdrRecords[0].get('SVMXC__Restoration_Customer_By__c') != NULL)
                                    {
                                        String calculatedTime;
                                        Long Ldiff = 0;
                                        Long Lnow = System.now().gettime();
                                        Datetime dtmRestoration = DateTime.valueOf(HdrRecords[0].get('SVMXC__Restoration_Customer_By__c'));
                                        Long Lrest = dtmRestoration.getTime();
                                        Ldiff = Lrest - Lnow; 
                                        if(Ldiff > 0)
                                        {
                                            calculatedTime = DatCal.getCountDown(Ldiff);
                                            INTF_WebServicesDef.INTF_StringMap restorationTimer = new INTF_WebServicesDef.INTF_StringMap('RESTORATIONTIME', calculatedTime);
                                            slaTimer.add(restorationTimer);
                                        }
                                    }
                                    if(HdrRecords[0].get('SVMXC__Resolution_Customer_By__c') != NULL)
                                    {
                                        String calculatedTime;
                                        Long Ldiff = 0;
                                        Long Lnow = System.now().gettime();
                                        Datetime dtmResolution = DateTime.valueOf(HdrRecords[0].get('SVMXC__Resolution_Customer_By__c'));
                                        Long Lrest = dtmResolution.getTime();
                                        Ldiff = Lrest - Lnow; 
                                        if(Ldiff > 0)
                                        {
                                            calculatedTime = DatCal.getCountDown(Ldiff);
                                            INTF_WebServicesDef.INTF_StringMap resolutionTimer = new INTF_WebServicesDef.INTF_StringMap('RESOLUTIONTIME', calculatedTime);
                                            slaTimer.add(resolutionTimer);
                                        }
                                    }
                                    if(slaTimer != NULL && slaTimer.size() > 0)
                                    {
                                        INTF_WebServicesDef.INTF_MapStringMap responseSLAmap = new INTF_WebServicesDef.INTF_MapStringMap('SLATIMER', slaTimer);
                                        SFMResponse.MapStringMap.add(responseSLAmap);
                                    }
                                }
                                //system.debug('HdrRecords are there');
                                String DefaultValue = '';
                                if(fieldLst[j].SVMXC__Field_API_Name__c != null)
                                {
                                    DefaultValue = String.valueof(HdrRecords[0].get(fieldLst[j].SVMXC__Field_API_Name__c));
                                    BubbleWrapper.fieldapiname = fieldLst[j].SVMXC__Field_API_Name__c;
                                    //system.debug('DefaultValue'+fieldLst[j].SVMXC__Field_API_Name__c+','+DefaultValue);
                                    //Bala : For the Datatime field  iPad Require datetime in GMT
                                    if(fieldLst[j].SVMXC__DataType__c != null && fieldLst[j].SVMXC__DataType__c.touppercase() == 'DATETIME' && DefaultValue != null && DefaultValue.length() > 0)
                                    {
                                        String dateGMT = DateTime.valueOf(HdrRecords[0].get(fieldLst[j].SVMXC__Field_API_Name__c)).formatGmt('yyyy-MM-dd HH:mm:ss');
                                        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap(dateGMT, dateGMT);
                                        BubbleWrapper.fieldvalue = strmap;
                                    }
                                    else if(fieldLst[j].SVMXC__Related_Object_Name__c != null && fieldLst[j].SVMXC__DataType__c.touppercase() == 'REFERENCE' && DefaultValue != null && DefaultValue.length() > 0)
                                    {
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
                                        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                                        strmap.key = key;
                                        system.debug('valuemap'+valuemap);
                                        if(key != null && valuemap.containskey(key))
                                            strmap.value = valuemap.get(key);
                                        BubbleWrapper.fieldvalue = strmap;
                                        //Now start making the bubbleinfo for the Reference fields...
                                    }
                                    else 
                                    {
                                        BubbleWrapper.fieldvalue.key = DefaultValue; 
                                        BubbleWrapper.fieldvalue.value = DefaultValue;
                                    }     
                                }   
                            }
                            system.debug('BubbleWrapper'+BubbleWrapper);
                            if(BubbleWrapper.fieldapiname != NULL)
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
        //Get The SFW and SFM Process Action for ipad.
        system.debug('RecId'+RecId);
        system.debug('TargetObjName'+TargetObjName);
        system.debug('Process'+Process.SVMXC__Purpose__c);
        if(RecId != null && RecId.length() > 0 && TargetObjName != null && TargetObjName.length() > 0 && Process!= null && Process.SVMXC__Purpose__c.touppercase() == 'VIEW RECORD')
        {
            system.debug('Entered to get');
            SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
            list<SVMXC.SFM_WrapperDef.SFM_StringMap> inputKeyValues = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
            SVMXC.SFM_WrapperDef.SFM_StringMap StrngMap1 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
            SVMXC.SFM_WrapperDef.SFM_StringMap StrngMap2 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
            StrngMap1.key = 'RECORDID';
            StrngMap1.value = RecId;
            StrngMap2.key = 'OBJECTNAME';
            StrngMap2.value = TargetObjName;
            inputKeyValues.add(StrngMap1);
            inputKeyValues.add(StrngMap2);
            request.stringMap = inputKeyValues;
            list<SVMXC.SFM_WrapperDef.SFM_StringListMap> stringListmp = new list<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
            list<String> ActnTypeStrngLst = new list<String>();
            ActnTypeStrngLst.add('SFM');
            stringListmp.add(new SVMXC.SFM_WrapperDef.SFM_StringListMap('ACTIONTYPE', ActnTypeStrngLst));
            request.stringListMap = stringListmp;
            SVMXC.INTF_GetServiceFlowWizard SFW = new SVMXC.INTF_GetServiceFlowWizard();
            system.debug('amar'+SFW.getSFWWrapper(request));
            SVMXC.INTF_WebServicesDef.INTF_Response_SFWInfo SFWInfo = new SVMXC.INTF_WebServicesDef.INTF_Response_SFWInfo();
            SFWInfo = SFW.getSFWWrapper(request);
            map<String,list<SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo>> colRowMap = new map<String,list<SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo>>();
            map<Integer,list<SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo>> tempSeqMap = new map<Integer,list<SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo>>();
            if(SFWInfo != null)
            {
                list<SVMXC.INTF_WebServicesDef.SFM_SFWInfo> SFWInfoList = new list<SVMXC.INTF_WebServicesDef.SFM_SFWInfo>();
                SFWInfoList = SFWInfo.SFWs;
                if(SFWInfoList.size() > 0)
                {
                    for(Integer i = 0;i<SFWInfoList.size();i++)
                    {
                        String key = SFWInfoList[i].col + ',' +SFWInfoList[i].row;
                        if(SFWInfoList[i].col != NULL && SFWInfoList[i].row != NULL)
                        {
                            colRowMap.put(key,SFWInfoList[i].actions);
                        }
                    }
                }
                Integer rowCount = 0;
                if(colRowMap.size() > 0)
                {
                    system.debug('colRowMap'+colRowMap);
                    for(String s:colRowMap.keyset())
                    {
                        List<String> s1 = s.split(',');
                        system.debug('colRowMap2'+s1);
                        if(rowCount <  Integer.valueof(s1[1]))
                            rowCount = Integer.valueof(s1[1]);
                    }
                }
                system.debug('rowCount'+rowCount);
                system.debug('colRowMap'+colRowMap.size()+colRowMap);
                if(colRowMap.size() > 0)
                {
                    Integer seq = 0;
                    for(Integer i = 1;i<=2;i++)
                    {
                        for(Integer j = 1;j<=rowCount;j++)
                        {
                            String s1 = i+','+j;
                            system.debug('watchit:'+s1);
                            if(colRowMap.containskey(s1))
                            {
                                seq = seq+1;
                                if(!tempSeqMap.containskey(seq))
                                    tempSeqMap.put(seq,colRowMap.get(s1));
                            }
                        }
                    }
                }       
                system.debug('tempSeqMap'+tempSeqMap);
                map<Integer,list<SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo>> seqMap = new map<Integer,list<SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo>>();
                if(tempSeqMap.size() > 0)
                {
                    Integer i = 1;
                    for(Integer a : tempSeqMap.keyset())
                    {
                        if(tempSeqMap.get(a).size() > 0)
                        {
                            seqMap.put(i,tempSeqMap.get(a));
                            i = i+1;
                        }
                    }
                }
                system.debug('seqMap'+seqMap);
                if(seqMap.size() > 0)
                {
                    set<String> uniqButtons = new set<String>();
                    for(Integer i : seqMap.keyset())
                    {
                        list<SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo> actionList = new list<SVMXC.INTF_WebServicesDef.SFM_SFWActionsInfo>();
                        actionList = seqMap.get(i);
                        if(actionList.size() > 0)
                        {
                            for(Integer j = 0;j<actionList.size();j++)
                            {
                                if(actionList[j].actionDef.SVMXC__Action_Type__c.touppercase() == 'SFM' && uniqButtons.contains(actionList[j].actionDef.SVMXC__Process__c) == false)
                                {
                                    uniqButtons.add(actionList[j].actionDef.SVMXC__Process__c);
                                    SVMXC__Page_Layout_Detail__c buttonDetail = new SVMXC__Page_Layout_Detail__c();
                                    SVMXC.INTF_WebServicesDef.INTF_UIButton  ButtonUI = new SVMXC.INTF_WebServicesDef.INTF_UIButton();
                                    buttonDetail.SVMXC__Title__c = actionList[j].actionDef.SVMXC__Name__c;
                                    buttonDetail.SVMXC__Sequence__c = actionList[j].actionDef.SVMXC__Sequence__c.round();
                                    list<SVMXC__SFM_Event__c> eventList = new list<SVMXC__SFM_Event__c>();
                                    SVMXC__SFM_Event__c event = new SVMXC__SFM_Event__c();
                                    if(SFMProcessMap.containskey(actionList[j].actionDef.SVMXC__Process__c))
                                        event.SVMXC__Target_Call__c = SFMProcessMap.get(actionList[j].actionDef.SVMXC__Process__c).SVMXC__ProcessID__c;
                                    event.SVMXC__Event_Type__c = 'Button Click';
                                    event.SVMXC__Event_Call_Type__c = 'TDM - IPAD ONLY';
                                    eventList.add(event);
                                    ButtonUI.buttonDetail = buttonDetail;   
                                    ButtonUI.buttonEvents = eventList;
                                    ButtonUI.sequence = i;
                                    ButtonUI.enable = actionList[j].Enabled;
                                    Buttons.add(ButtonUI); 
                                }
                            }
                        }
                    }
                }   
            }
        }
        checkQueryLimit();
        system.debug('Buttons'+Buttons);
        //Now process the reguler button    
        if(ButtondLst.size() > 0)
        {
            //log.setlog('LOOPING-Start', 'Loop for ButtonsList to add to ButtonUI');
            for(Integer i = 0;i<ButtondLst.size();i++)
            {
                //log.setlog('LOOPING', 'Loop for ButtonsList to add to ButtonUI for'+ButtondLst[i].id);
                List<SVMXC__SFM_Event__c> ButtonEvents1 = new List<SVMXC__SFM_Event__c>();
                SVMXC.INTF_WebServicesDef.INTF_UIButton  ButtonUI = new SVMXC.INTF_WebServicesDef.INTF_UIButton(ButtondLst[i],ButtonEvents1);
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
        SVMXC.INTF_WebServicesDef.INTF_PageHeader PageHeader = new SVMXC.INTF_WebServicesDef.INTF_PageHeader(HeaderLayout,Sections,Buttons,HdrPageEvents);
        /*if(HdrRecords != null && HdrRecords.size() > 0)
            PageHeader.hdrData = HdrRecords[0];*///Ipad is no longer using this member
        if(HeaderLayout != null && HeaderLayout.id != null)
            PageHeader.hdrLayoutId  =  HeaderLayout.id;  
        //Make the all Field data for the Header record
        if(mapHeaderTargetField.size() > 0)
        {
            list<SVMXC.INTF_WebServicesDef.INTF_UIField> fields = new list<SVMXC.INTF_WebServicesDef.INTF_UIField>();
            for(String s : mapHeaderTargetField.keyset())
            {
                String defaultValue = '';
                defaultValue = String.valueof(HdrRecords[0].get(s));
                if(defaultValue != null && defaultValue.length() > 0)
                {
                    SVMXC.INTF_WebServicesDef.INTF_UIField field = new SVMXC.INTF_WebServicesDef.INTF_UIField();
                    SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper bubbleInfo = new SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper();
                    bubbleInfo.fieldapiname = s;
                    bubbleInfo.fieldvalue.key = defaultValue;
                    bubbleInfo.fieldvalue.value = defaultValue;
                    field.bubbleinfo = bubbleInfo;
                    fields.add(field);
                }
            }
            if(fields.size() > 0)
                PageHeader.allfields = fields;
            
        }
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
            if(translationObj != null)
            {
                INTF_DataSync.logSOQL(intMethodCount, 'Select SystemModstamp, SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c,  SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c  where SVMXC__Header_Page_Layout__c =: HeaderLayout.id and SVMXC__Type__c = \'Detail\'');
                RelatedLayoutMap.putall(translationObj.SVMX_GetPageLayoutTranslation([Select SystemModstamp, SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c,  SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c  where SVMXC__Header_Page_Layout__c =: HeaderLayout.id and SVMXC__Type__c = 'Detail']));
            }
            else
            {
                INTF_DataSync.logSOQL(intMethodCount, 'Select SystemModstamp, SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c,  SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c  where SVMXC__Header_Page_Layout__c =: HeaderLayout.id and SVMXC__Type__c = \'Detail\'');
                RelatedLayoutMap.putall([Select SystemModstamp, SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c,  SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c  where SVMXC__Header_Page_Layout__c =: HeaderLayout.id and SVMXC__Type__c = 'Detail']);
            }
        }
        system.debug('RelatedLayoutMap'+RelatedLayoutMap.size()+RelatedLayoutMap);
        if(RelatedLayoutMap.size() > 0)
        {
            //log.setlog('LOOPING-Start', 'Looping through the RelatedLayoutMap to set the relatedlist ids');
            for(String s :RelatedLayoutMap.keyset())
            {
                //log.setlog('LOOPING', 'Looping through the RelatedLayoutMap to set the relatedlist ids for'+s);
                RelatedLayoutLst.add(RelatedLayoutMap.get(s));
                RelatedLayoutID.add(s);
                //Create the all field describe 
                if(mapAliasNameObjName.containskey(s.substring(0,15)))
                {
                    system.debug('asdfgh');
                    if(allobjmap.containskey(mapAliasNameObjName.get(s.substring(0,15))))
                    {
                        system.debug('asdfgh11');
                        map<String,Schema.SObjectField> mapTempField1 = new map<String,Schema.SObjectField>();
                        map<String,Schema.SObjectField> mapTempField = new map<String,Schema.SObjectField>();
                        mapTempField1 = allobjmap.get(mapAliasNameObjName.get(s.substring(0,15))).getDescribe().fields.getMap();
                        for(String str : mapTempField1.keyset())
                        {
                            mapTempField.put(mapTempField1.get(str).getDescribe().getName(),mapTempField1.get(str));
                        }
                        if(mapTempField.size() > 0 && !AllFieldDescribe.containskey(mapAliasNameObjName.get(s.substring(0,15))))
                            AllFieldDescribe.put(mapAliasNameObjName.get(s.substring(0,15)),mapTempField);
                    }
                }
            }
            //log.setlog('LOOPING-End', 'Getting the Related layout');
        }
        checkQueryLimit();
        system.debug('AllFieldDescribe'+AllFieldDescribe);
        //Get the Detail PageEvent
        Map<String,List<SVMXC__SFM_Event__c>> RelatedLayoutEventMap = new  Map<String,List<SVMXC__SFM_Event__c>>();
        List<SVMXC__SFM_Event__c> RelatedLayoutEventlst = new List<SVMXC__SFM_Event__c>(); 
        if(RelatedLayoutID.size() > 0)
        {
            INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout__c IN : RelatedLayoutID');
            RelatedLayoutEventlst.addall([Select SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout__c IN : RelatedLayoutID]);
            if(RelatedLayoutEventlst != NULL && RelatedLayoutEventlst.size() > 0)
            {
                for(SVMXC__SFM_Event__c event: RelatedLayoutEventlst)
                {
                    if(event.SVMXC__Target_Call__c != NULL && event.SVMXC__Target_Call__c.contains('__'))
                        event.SVMXC__Target_Call__c = event.SVMXC__Target_Call__c.replace('__', '/');
                        
                    if(event.SVMXC__Code_Snippet__c != NULL ){
                        codeSnippetIds.add(event.SVMXC__Code_Snippet__c);
                    }    
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
        checkQueryLimit();
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
            if(translationObj!= null)
            {
                INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Show_In_iPad__c, SVMXC__Show_In_Web__c, SVMXC__Related_Object_Name_Field__c, SVMXC__IsStandard__c,SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id ,SVMXC__No_of_columns__c, SVMXC__Use_For_SLA_Clock__c, SVMXC__Field_Mapping__c,SVMXC__Override_Related_Lookup__c,SVMXC__Context_Source_Object__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN : RelatedLayoutID');
                AllRelatedfldsbtnsMap.putall(translationObj.SVMX_GetPageLayoutDetailTranslation([Select SVMXC__Show_In_iPad__c, SVMXC__Show_In_Web__c, SVMXC__Related_Object_Name_Field__c, SVMXC__IsStandard__c,SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id ,SVMXC__No_of_columns__c, SVMXC__Use_For_SLA_Clock__c, SVMXC__Field_Mapping__c,SVMXC__Override_Related_Lookup__c,SVMXC__Context_Source_Object__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN : RelatedLayoutID]));
            }
            else
            {
                INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Show_In_iPad__c, SVMXC__Show_In_Web__c, SVMXC__Related_Object_Name_Field__c, SVMXC__IsStandard__c,SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id ,SVMXC__No_of_columns__c, SVMXC__Use_For_SLA_Clock__c, SVMXC__Field_Mapping__c,SVMXC__Override_Related_Lookup__c,SVMXC__Context_Source_Object__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN : RelatedLayoutID');
                AllRelatedfldsbtnsMap.putall([Select SVMXC__Show_In_iPad__c, SVMXC__Show_In_Web__c, SVMXC__Related_Object_Name_Field__c, SVMXC__IsStandard__c,SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id ,SVMXC__No_of_columns__c, SVMXC__Use_For_SLA_Clock__c, SVMXC__Field_Mapping__c,SVMXC__Override_Related_Lookup__c,SVMXC__Context_Source_Object__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN : RelatedLayoutID]);
            }
        }
        system.debug('AllRelatedfldsbtnsMap'+AllRelatedfldsbtnsMap);
        if(AllRelatedfldsbtnsMap.size() > 0)
        {
            AllRelatedfldsbtns.addall(AllRelatedfldsbtnsMap.values());
        }
        if(AllRelatedfldsbtns.size() > 0)
        {
            //log.setlog('LOOPING-Start', 'Looping through the Relatedfields to categorize the field types and the button types');
            for(Integer i = 0; i < AllRelatedfldsbtns.size(); i++)
            {
                //log.setlog('LOOPING-Start', 'Looping through the Relatedfields to categorize the field types and the button types for '+ AllRelatedfldsbtns[i]);
                if(AllRelatedfldsbtns[i].SVMXC__Detail_Type__c == 'Field')
                {
                    RelatedFieldsMap.put(AllRelatedfldsbtns[i].id,AllRelatedfldsbtns[i]);
                    RelatedFieldLst.add(AllRelatedfldsbtns[i]);
                    RelatedFldId.add(AllRelatedfldsbtns[i].id);
                }
                if(AllRelatedfldsbtns[i].SVMXC__Detail_Type__c == 'Button')
                {
                    RelatedButtonsMap.put(AllRelatedfldsbtns[i].id,AllRelatedfldsbtns[i]);
                    RelatedButtonLst.add(AllRelatedfldsbtns[i]);
                    RelatedBtnId.add(AllRelatedfldsbtns[i].id);
                }
            }
            //log.setlog('LOOPING-End', 'Looping through the Relatedfields to categorize the field types and the button types');
        }
        //Get the Events for Related Button...
        Map<Id,List<SVMXC__SFM_Event__c>>  RelatedBtnEventMap = new  Map<Id,List<SVMXC__SFM_Event__c>>();
        List<SVMXC__SFM_Event__c> RelatedBtnEventlst = new List<SVMXC__SFM_Event__c>();
        //log.setlog('QUERY-TEXT', 'Getting all the events from the pagelayout for the related ones');
        INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : RelatedBtnId');
        RelatedBtnEventlst.addall([Select SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : RelatedBtnId]);
        if(RelatedBtnEventlst != NULL && RelatedBtnEventlst.size() > 0)
        {
            for(SVMXC__SFM_Event__c event: RelatedBtnEventlst)
            {
                if(event.SVMXC__Target_Call__c != NULL && event.SVMXC__Target_Call__c.contains('__'))
                    event.SVMXC__Target_Call__c = event.SVMXC__Target_Call__c.replace('__', '/');
                    
                if(event.SVMXC__Code_Snippet__c != NULL ){
                    codeSnippetIds.add(event.SVMXC__Code_Snippet__c);
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
        Map<String,List<SVMXC.INTF_WebServicesDef.INTF_UIButton>> RelatedBtnUIMap = new Map<String,List<SVMXC.INTF_WebServicesDef.INTF_UIButton>>();
        //log.setlog('LOOPING-Start', 'looping through RelatedButtonsMap to build RelatedBtnUI');
        for(string s1: RelatedLayoutMap.keyset())
        {
            //Create the SFM_ButtonUI wrapper for Related Layout..
            List<SVMXC.INTF_WebServicesDef.INTF_UIButton> RelatedBtnUI = new List<SVMXC.INTF_WebServicesDef.INTF_UIButton>();
            for(String s : RelatedButtonsMap.keySet())
            {
                SVMXC__Page_Layout__c PL = new SVMXC__Page_Layout__c();
                PL = RelatedLayoutMap.get(s1);
                SVMXC__Page_Layout_Detail__c PLD = new SVMXC__Page_Layout_Detail__c();
                PLD = RelatedButtonsMap.get(s);
                if(PLD.SVMXC__Page_Layout__c == PL.id)
                {
                    //log.setlog('LOOPING', 'looping through RelatedButtonsMap to build RelatedBtnUI for '+s);
                    SVMXC.INTF_WebServicesDef.INTF_UIButton ButtonUI = new SVMXC.INTF_WebServicesDef.INTF_UIButton(new SVMXC__Page_Layout_Detail__c(),new List<SVMXC__SFM_Event__c>());
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
        INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : RelatedFldId');
        RelatedfldEventLst.addall([Select SVMXC__Code_Snippet__c, SVMXC__URL_Window_Type__c, SVMXC__Target_Call__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail__c, SVMXC__IsStandard__c, SVMXC__Event_Type__c, SVMXC__Event_Id__c, SVMXC__Event_Call_Type__c, OwnerId, Name, Id,CreatedDate, CreatedById From SVMXC__SFM_Event__c  where SVMXC__Page_Layout_Detail__c IN : RelatedFldId]);
        if(RelatedfldEventLst != NULL && RelatedfldEventLst.size() > 0)
        {
            for(SVMXC__SFM_Event__c event: RelatedfldEventLst)
            {
                if(event.SVMXC__Target_Call__c != NULL && event.SVMXC__Target_Call__c.contains('__'))
                    event.SVMXC__Target_Call__c = event.SVMXC__Target_Call__c.replace('__', '/');
                    
                if(event.SVMXC__Code_Snippet__c != NULL ){
                    codeSnippetIds.add(event.SVMXC__Code_Snippet__c);
                }    
            }
        }
        
        checkQueryLimit();
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
        Map<String,List<SVMXC.INTF_WebServicesDef.INTF_UIField>> RelatedfldUIMap = new Map<String,List<SVMXC.INTF_WebServicesDef.INTF_UIField>>();
        //log.setlog('LOOPING-Start', 'Looping through the list of relatedfieldsmap to add to FieldUI');
        for(String s1: RelatedLayoutMap.keyset())
        {
            ////Create the SFM_FieldUI wrapper for Related Layout..
            List<SVMXC.INTF_WebServicesDef.INTF_UIField> RelatedfldUI = new List<SVMXC.INTF_WebServicesDef.INTF_UIField>();
            for(String s : RelatedFieldsMap.keyset())
            {
                SVMXC__Page_Layout__c PL = new SVMXC__Page_Layout__c();
                PL = RelatedLayoutMap.get(s1);
                SVMXC__Page_Layout_Detail__c PLD = new SVMXC__Page_Layout_Detail__c();
                PLD = RelatedFieldsMap.get(s);
                if(PLD.SVMXC__Page_Layout__c == PL.id)
                {
                    SVMXC.INTF_WebServicesDef.INTF_UIField FieldUI = new SVMXC.INTF_WebServicesDef.INTF_UIField();//new SVMXC__Page_Layout_Detail__c(),new List<SVMXC__SFM_Event__c>()
                    FieldUI.fieldDetail = RelatedFieldsMap.get(s);
                    FieldUI.bubbleinfo = NULL;
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
                        system.debug('entered to make wrapper');
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
        //system.debug('DetailFieldMap'+DetailFieldMap);
        //Create the list for SFM_PageDetail class..
        List<SVMXC.INTF_WebServicesDef.INTF_PageDetail> SFM_PageDetailLst = new List<SVMXC.INTF_WebServicesDef.INTF_PageDetail>(); 
        if(RelatedLayoutMap.size() > 0)
        {
            //log.setlog('LOOPING-Start', 'Looping through the list of RelatedLayoutMap to add to Pagedetail');
            for(String s : RelatedLayoutMap.keyset())
            {
                //log.setlog('LOOPING', 'Looping through the list of RelatedLayoutMap to add to Pagedetail'+s);   
                //get the field describe for the detail
                SVMXC.INTF_WebServicesDef.INTF_PageDetail SFM_PageDetail = new SVMXC.INTF_WebServicesDef.INTF_PageDetail();
                SFM_PageDetail.DetailLayout = RelatedLayoutMap.get(s);
                SFM_PageDetail.dtlLayoutId = s;
                //system.debug('amarDetailLayout'+SFM_PageDetail.DetailLayout);
                //get the Event for Detail layout
                if(RelatedLayoutEventMap.containskey(s))
                    SFM_PageDetail.events = RelatedLayoutEventMap.get(s);
                ////put the List<SFM_DetailBubbleWrapper> member in the SFM_PageDetail 
                List<SVMXC.INTF_WebServicesDef.INTF_DetailBubbleWrapper> DetailBubbleWrapperList = new List<SVMXC.INTF_WebServicesDef.INTF_DetailBubbleWrapper>();
                if(DetailSobjectRecsMap.size() > 0 && RelatedLayoutMap.get(s).Id != null && DetailFieldMap.size() > 0)
                {
                    system.debug('Entered in Detail..');
                    list<Sobject> SobjectLst = new list<Sobject>();
                    String Rid = s.substring(0,15);
                    if(DetailSobjectRecsMap.containskey(Rid))
                        SobjectLst = DetailSobjectRecsMap.get(Rid);
                    system.debug('TEST LOG: SobjectLst ' + SobjectLst);
                   //Calculate the Reference field's Name-id pair in bulk mode
                   map<String,String> IdNameMap = new map<String,String>(); 
                   if(SobjectLst.size() > 0)
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
                                for(Integer b = 0;b<SobjectLst.size();b++)
                                {
                                    if(SobjectLst[b].get(fld) != null)
                                        ids.add(String.valueof(SobjectLst[b].get(fld)));
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
                   list<wrapper> fldlst = new list<wrapper>();
                   if(DetailFieldMap.containskey(RelatedLayoutMap.get(s).Id))//RelatedLayoutMap.get(s).SVMXC__Object_Name__c
                        fldlst = DetailFieldMap.get(RelatedLayoutMap.get(s).Id);//RelatedLayoutMap.get(s).SVMXC__Object_Name__c
                   set<String> deatailsFields = new set<String>();
                   if(fldlst.size() > 0)
                   {
                        for(Integer a = 0; a<fldlst.size();a++)
                        {
                            if(fldlst[a].FieldApiName != null)
                                deatailsFields.add(fldlst[a].FieldApiName);
                        }
                   }                
                   if(SobjectLst.size() > 0)
                   {
                        for(Integer i = 0;i<SobjectLst.size();i++)
                        {
                            SVMXC.INTF_WebServicesDef.INTF_DetailBubbleWrapper DetailBubbleWrapper = new SVMXC.INTF_WebServicesDef.INTF_DetailBubbleWrapper();
                            list<SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper> BubbleWrapperLst = new list<SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper>();
                            if(fldlst.size() > 0)
                            {
                                for(Integer j = 0;j<fldlst.size();j++)
                                {
                                    if(fldlst[j].FieldApiName == NULL)
                                        continue;
                                    SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper BubbleWrapper = new SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper();
                                    BubbleWrapper.fieldapiname = fldlst[j].FieldApiName;
                                    //system.debug('asdfgh'+BubbleWrapper.fieldapiname);
                                    //system.debug('FieldApiName'+fldlst[j].FieldApiName);
                                    //system.debug('FieldApiName'+SobjectLst[i].get(fldlst[j].FieldApiName)+fldlst[j].RelatedObjName+fldlst[j].RelatedObjFieldName);
                                    String DefaultValue = '';
                                    
                                    if(fldlst[j].FieldApiName != null)
                                        DefaultValue = String.valueof(SobjectLst[i].get(fldlst[j].FieldApiName)); 
                                    if(fldlst[j].RelatedObjName != null && fldlst[j].DataType != null && fldlst[j].DataType.touppercase() == 'REFERENCE')
                                    {
                                        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                                        strmap.key = DefaultValue;
                                        if(IdNameMap.containskey(DefaultValue))
                                            strmap.value = IdNameMap.get(DefaultValue);
                                        BubbleWrapper.fieldvalue = strmap;
                                    }
                                    //Bala : For the Datatime field  iPad Require datetime in GMT
                                    else if(fldlst[j].DataType != null && fldlst[j].DataType.touppercase() == 'DATETIME' && DefaultValue != null && DefaultValue.length() > 0)
                                    {
                                        String dateGMT = DateTime.valueOf(SobjectLst[i].get(fldlst[j].FieldApiName)).formatGmt('yyyy-MM-dd HH:mm:ss');
                                        //String dat1 = DateTime.valueOfGmt(DateTime.valueOf(HdrRecords[0].get(fieldLst[j].SVMXC__Field_API_Name__c).format('yyyy-MM-dd hh:mm:ss'));
                                        system.debug('TEST LOG dateGMT22: ' + fldlst[j].FieldApiName + '->' + dateGMT);
                                        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap(dateGMT, dateGMT);
                                        BubbleWrapper.fieldvalue = strmap;
                                    }
                                    else
                                    {
                                        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap(DefaultValue,DefaultValue);
                                        BubbleWrapper.fieldvalue = strmap;  
                                    }
                                    BubbleWrapperLst.add(BubbleWrapper);
                                }
                                system.debug('amarentered'+RelatedLayoutMap.get(s).SVMXC__Object_Name__c+AllFieldDescribe.containskey(RelatedLayoutMap.get(s).SVMXC__Object_Name__c));
                                if(RelatedLayoutMap.get(s).SVMXC__Object_Name__c != null && AllFieldDescribe.containskey(RelatedLayoutMap.get(s).SVMXC__Object_Name__c))
                                {
                                    system.debug('amarentered');
                                    map<String,Schema.SObjectField> mapTempField = new map<String,Schema.SObjectField>();
                                    mapTempField = AllFieldDescribe.get(RelatedLayoutMap.get(s).SVMXC__Object_Name__c);
                                    system.debug('mapTempField'+mapTempField);
                                    if(mapTempField.size() > 0)
                                    {
                                        for(String str : mapTempField.keyset())
                                        {
                                            if(!deatailsFields.contains(str))
                                            {
                                                system.debug('amarentered11');
                                                String DefaultValue = '';
                                                DefaultValue = String.valueof(SobjectLst[i].get(str)); 
                                                if(DefaultValue != null && DefaultValue.length() > 0)
                                                {
                                                    SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper BubbleWrapper = new SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper();
                                                    BubbleWrapper.fieldapiname = str;
                                                    BubbleWrapper.fieldvalue.key = DefaultValue; 
                                                    BubbleWrapper.fieldvalue.value = DefaultValue;
                                                    BubbleWrapperLst.add(BubbleWrapper);
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                system.debug('BubbleWrapperLst'+BubbleWrapperLst);
                                DetailBubbleWrapper.bubbleinfolist = BubbleWrapperLst;
                            }
                            //DetailBubbleWrapper.sobjectinfo = SobjectLst[i]; //No longer used by iPad
                            DetailBubbleWrapperList.add(DetailBubbleWrapper);
                        }
                        system.debug('DetailBubbleWrapperList'+DetailBubbleWrapperList);
                    }
                }
                SFM_PageDetail.bubbleinfolist = DetailBubbleWrapperList;                
                if(RelatedfldUIMap.containsKey(s) && RelatedfldUIMap.get(s) != null)    
                {
                    SFM_PageDetail.fields = RelatedfldUIMap.get(s);
                    system.debug('amarfields'+SFM_PageDetail.fields);
                }       
                if(RelatedBtnUIMap.containskey(s) && RelatedBtnUIMap.get(s) != null)
                {
                    SFM_PageDetail.buttons =  RelatedBtnUIMap.get(s);
                    system.debug('amarbuttons'+SFM_PageDetail.buttons);
                }   
                SFM_PageDetailLst.add(SFM_PageDetail);
                system.debug('SFM_PageDetailLst'+SFM_PageDetailLst);    
            }
            //log.setlog('LOOPING-End', 'Looping through the list of relatedfieldsmap to add to Pagedetail');
        }
        
        system.debug('Last'+SFM_PageDetailLst.size()+SFM_PageDetailLst);    
        pageui.header = PageHeader;
        pageui.details = SFM_PageDetailLst;
        
        if(codeSnippetIds.size() > 0){
            SFMResponse.valueMap.add(new INTF_WebServicesDef.SVMXMap('CODE_SNIPPET_IDS','',codeSnippetIds));
        }
        SFMResponse.success = true;
        PageResponseUI.page = pageui;
        PageResponseUI.response = SFMResponse;
        system.debug('PageResponseUI'+PageResponseUI);
        system.debug('amar'+system.now());
        system.debug('amar'+system.now().millisecond());
        INTF_DataSync.logMethodEndTS(intMethodCount, 'INTF_GetPageLayout');
        return PageResponseUI;
    }

    private void checkQueryLimit()
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('checkQueryLimit');
        if(Limits.getQueries() < (Limits.getLimitQueries() - 10))
        {
            // We are under control
        }
        else
        {
            INTF_DataSync.logMethodEndTS(intMethodCount, 'checkQueryLimit');
            throw new SFMException('Almost reached SOQL query limits.');
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'checkQueryLimit');
    }
}