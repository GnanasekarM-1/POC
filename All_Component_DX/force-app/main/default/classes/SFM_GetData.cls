/* Security Scanned */
public with sharing class SFM_GetData 
{
    //Global Variables
    public map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    public Integer batchsize = SFMDeliveryServiceImpl.detailRecBatchSize;//Added by nidhi as part of lazy loading BAC-4680
    public map<String,map<String, Schema.SObjectField>> mapAllFieldDescribe = new map<String,map<String, Schema.SObjectField>>();
    public static map<String, Schema.SObjectType> allObjMap  = new map<String, Schema.SObjectType>(); //Added for the story BAC-4410
    SVMXC.SFM_parseProcess parseProcess = new SVMXC.SFM_parseProcess();
    SVMXC.SFM_Utils SFMUtils = new SVMXC.SFM_Utils(); 
    public List<String> mappedFieldsForHeader = new List<String>(); //Added as part of Story BAC-3257
    public Map<Id, Set<String>> mapFieldMapIdListOfFields = new Map<Id, Set<String>>(); //Added for the defect fix BAC-3884
    Map<String,Set<String>> mapObjectNameWithDVFields = new Map<String,Set<String>>(); //Added for the story BAC-3885
    Map<String,Set<String>> mapObjectNameFieldListSet = new Map<String,Set<String>>(); //Added for defect fix BAC-4032
    public static SVMXC__ServiceMax_Processes__c targetManagerProcess; //Added for the story BAC-4410
    public static List<SVMXC__ServiceMax_Processes__c> processNodeObjectsList; //Added for the story BAC-4410
    public static Map<String,String> mapDetailTabIdFieldList = new Map<String,String>();//Added by Nidhi as part of Lazy Loading BAC-4680
    public static map<String,String> mapAliasNameWhereClause = new map<String,String>();//Added by Nidhi as part of Lazy Loading BAC-4680
    public static Boolean isDateTimeConversionRequired = true;
    public Map<String,Set<String>> mapObjectNameFieldListForFormFill = new Map<String,Set<String>>();
    public Map<String,set<String>> mapObjectAPINameWithFields = new Map<String,set<String>>();
    //Constructor
    public SFM_GetData()
    {
        //Commented for the story BAC-4410 to avoid global describe for all objects and do describe of objects used in the SFM 
        /*gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            Schema.DescribeSObjectResult result = s.getDescribe();
            allObjMap.put(result.getName(),s);
        } */
    }
    public SVMXC.SFM_WrapperDef.SFM_PageData SFM_getData(SFM_WrapperDef.SFM_Request_PageUI PmaxReqPageUI)
    {
        Set<String> setObjectsUsedInSFM = new Set<String>(); //Added for the story BAC-4410 to collect objects used in the SFM
        map<String,map<String,Sobject>> mapAliasNameSourceRecIdTargetObject = new map<String,map<String,Sobject>>();
        String targetManager = '';
        String processNodeObj = '';
        /* Commented for BAC-4366
        List<RecordType> recordTypes = new List<RecordType>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        recordTypes = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        if(recordTypes.size() > 0 )
        {
            for(RecordType r : recordTypes)
            {
                if(r.Name == 'Target Manager')
                {
                    targetManager = r.id;
                }
                if(r.Name == 'Process Node Objects')
                {
                    processNodeObj = r.id;
                }
            }
        }
        */
        //Added for BAC-4366
        List<String> lstRecordTypeName = new List<String>();
        lstRecordTypeName.add('Target_Manager');
        lstRecordTypeName.add('Process_Node_Objects');
        Map<String,Id> mapRecordTypeDetails = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Processes__c',lstRecordTypeName);
        targetManager = mapRecordTypeDetails.get('Target_Manager');
        processNodeObj = mapRecordTypeDetails.get('Process_Node_Objects');
        
        //System.debug('targetManager '+targetManager +' processNodeObj '+processNodeObj);
        //End BAC-4366
        String pageId = '';
        String RecId = '';
        String processId = '';
        String TargetObjName = '';
        String SourceObjName = '';
        String NameField = '';
        String targetRecId = '';
        set<String> setSourceObjectName = new set<String>();
        set<String> detailLayoutIds = new set<String>();
        map<String,String> mapObjNameField = new map<String,String>();
        map<String,String> mapAliasNameObjectName = new map<String,String>();
        SVMXC.SFM_WrapperDef.SFM_Response SFMResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC.SFM_WrapperDef.SFM_PageData pageData = new SVMXC.SFM_WrapperDef.SFM_PageData();
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> ResponseStringMapList = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        map<String,String> SourceObjectParentColumnMap = new map<String,String>();
        map<String,String> ChildObjSourceTargetMap = new map<String,String>();
        SVMXC__ServiceMax_Processes__c sfmProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c Process = new SVMXC__ServiceMax_Processes__c();
        SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        list<SVMXC__Page_Layout__c> detalLayoutList = new list<SVMXC__Page_Layout__c>();
        list<SVMXC__Page_Layout_Detail__c> headerFieldList = new list<SVMXC__Page_Layout_Detail__c>();
        list<SVMXC__Page_Layout_Detail__c> DetailFieldList = new list<SVMXC__Page_Layout_Detail__c>();
        map<String,SVMXC__Page_Layout_Detail__c> headerFieldMap = new map<String,SVMXC__Page_Layout_Detail__c>();
        map<String,list<SVMXC__Page_Layout_Detail__c>> detailFieldMap = new map<String,list<SVMXC__Page_Layout_Detail__c>>();
        list<SVMXC__ServiceMax_Processes__c> ProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        map<String,List<Sobject>> targetRecMap = new map<String,List<Sobject>>(); 
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_PageDataSet headerDataSet = new SVMXC.SFM_WrapperDef.SFM_PageDataSet();//Targetobject for header object
        list<SVMXC.SFM_WrapperDef.SFM_StringListMap> ResponseStringListMap = new list<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        stringMap = PmaxReqPageUI.request.StringMap;
        system.debug(LoggingLevel.WARN,'stringMap'+stringMap);
        if(stringMap.size() > 0)
        {
           for(Integer i = 0; i<stringMap.size(); i++)
            {
                if(stringMap[i].key != null && stringMap[i].key.toUppercase() == 'PAGEID' && stringMap[i].value != null && stringMap[i].value.length() > 0)
                {
                    pageId = stringMap[i].value;
                }
                if(stringMap[i].key != null && stringMap[i].key.toUppercase() == 'RECORDID' && stringMap[i].value != null && stringMap[i].value.length() > 0)
                {
                    RecId = stringMap[i].value;
                }
                if(stringMap[i].key != null && stringMap[i].key.toUppercase() == 'PROCESSID' && stringMap[i].value != null && stringMap[i].value.length() > 0)
                {
                    processId = stringMap[i].value;
                }
                //Added for the story BAC-2280
                if(stringMap[i].key != null && stringMap[i].key.toUppercase() == 'TARGETID' && stringMap[i].value != null && stringMap[i].value.length() > 0)
                {
                    targetRecId = stringMap[i].value;
                }
                
                if(stringMap[i].key != null && stringMap[i].key.toUppercase() == 'DATETIMECONVERSIONREQUIRED' && stringMap[i].value == 'false')
                {
                    isDateTimeConversionRequired = false;
                }
            }
        }    
        System.debug('isDateTimeConversionRequired: '+isDateTimeConversionRequired);
        system.debug('ProcessId'+ProcessId);
        system.debug('pageId'+pageId);
        system.debug('RecId'+RecId);
        if(ProcessId != null && ProcessId.length() > 0)
        {
            list<SVMXC__ServiceMax_Processes__c> ProList = new list<SVMXC__ServiceMax_Processes__c>();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //This is commented and added modified query below to fix the issue BAC-3588 where two records queried for process id
            //ProList = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c where RecordTypeId =: TargetManager and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)];
            
            //Commented this line and added below one to query only required fields for the story BAC-4410
            //ProList = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c where RecordTypeId =: TargetManager and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId)];
            
            ProList = [SELECT Id, SVMXC__Page_Layout__c, SVMXC__Purpose__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordTypeId =: TargetManager and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId)];
            system.debug('ProList'+ProList);
            if(ProList.size() == 1)
            {
                //Commented this line and added below one to for the story BAC-4410
                //Process = ProList[0];
                
                targetManagerProcess = Process = ProList[0];

                //Commented this line and added below one to query only required fields for the story BAC-4410
                //ProcessNodeObjects = [Select  SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c,SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__c,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From  SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: Process.id and RecordTypeId =: ProcessNodeObj];
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                ProcessNodeObjects = [SELECT Id, SVMXC__Parent_Object__r.SVMXC__Type__c, SVMXC__Parent_Object__r.SVMXC__Parent_Column_Name__c, SVMXC__Values__c, SVMXC__Module__r.SVMXC__Source_Object_Name__c, SVMXC__Module__r.SVMXC__Target_Object_Name__c, SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, SVMXC__Page_Layout__c, SVMXC__Parent_Column_Name__c, SVMXC__Final_Exception_Process__c, SVMXC__Type__c, SVMXC__Source_Object_Name__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Node_Source_Object_API__c, SVMXC__Target_Object_label__c FROM  SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process__c =: Process.id and RecordTypeId =: ProcessNodeObj];
            }
            
        }
        //first creare a response for the parent column name..
        if(ProcessNodeObjects.size() > 0)
        {
            processNodeObjectsList = ProcessNodeObjects; //Added for the story BAC-4410
            for(SVMXC__ServiceMax_Processes__c Pro : ProcessNodeObjects)
            {
                //----Start---Added for the story BAC-4410
                if(pro.SVMXC__Source_Object_Name__c != null){
                    setObjectsUsedInSFM.add(pro.SVMXC__Source_Object_Name__c);
                }
                //----End---Added for the story BAC-4410

                if(Pro.SVMXC__Type__c.touppercase() == 'TARGETCHILD')
                {
                    SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
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
                        setSourceObjectName.add(pro.SVMXC__Source_Object_Name__c);
                    }
                    if(pro.SVMXC__Page_Layout__c != null && pro.SVMXC__Source_Object_Name__c != null){
                        mapAliasNameObjectName.put(String.valueof(pro.SVMXC__Page_Layout__c).substring(0,15),pro.SVMXC__Source_Object_Name__c);
                    }
                }
                else if(Pro.SVMXC__Type__c.touppercase() == 'TARGET' && Pro.SVMXC__Source_Object_Name__c != null)
                {
                    TargetObjName = Pro.SVMXC__Source_Object_Name__c;
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

        //----Start---Added for the story BAC-4410
        System.debug('setObjectsUsedInSFM: '+setObjectsUsedInSFM);
        //Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String>(setObjectsUsedInSFM));
        Schema.DescribeSobjectResult[] results = COMM_Utils_DescribeCall.getInstance().getObjectDescribe(new List<String>(setObjectsUsedInSFM));
        for(Schema.DescribeSobjectResult ojbSObjectResult: results){
            allObjMap.put(ojbSObjectResult.getName(), ojbSObjectResult.getSobjectType());
        }
        //----End---Added for the story BAC-4410

       /* if(setSourceObjectName.size() > 0 && (Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD')){
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
        }*/
        
        //Response for the Source Update Record               
        if(Process != null && Process.SVMXC__Purpose__c != null)
        {
            if(Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD' || Process.SVMXC__Purpose__c.touppercase() == 'CHECKLIST')
            {
                if(TargetObjName != null && TargetObjName.length() > 0 && RecId != null && RecId.length() > 0)
                {
                    SVMXC.SFM_WrapperDef.SFM_StringListMap strlstmap = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
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
                        List<Sobject> Sobj = Database.Query(Query);
                        system.debug('DetailSourceRec'+Sobj);
                        if(Sobj.size() > 0)
                        {
                            SVMXC.SFM_WrapperDef.SFM_StringListMap strlstmap = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
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
         
         //Query the process and get the header layout 
        if(ProcessId != null && ProcessId.length() > 0){
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //This is commented and added modified query below to fix the issue BAC-3588 where two records queried for process id
            //sfmProcess = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c where RecordTypeId =: TargetManager and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)];
            
            //sfmProcess = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c where RecordTypeId =: TargetManager and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId)];
            sfmProcess = Process; //Added for the story BAC-4410 and commented above query line to avoid query again
        }
        if(sfmProcess != null && sfmProcess.SVMXC__Page_Layout__c != null){
             //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //headerLayout = [Select SVMXC__Type__c,SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c, SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c where id =: sfmProcess.SVMXC__Page_Layout__c and SVMXC__Type__c = 'Header'];  
            //Commented above query and added below query for the story BAC-4410 to avoid querying extra fields which are not used
            headerLayout = [SELECT Id, SVMXC__Object_Name__c FROM SVMXC__Page_Layout__c WHERE Id =: sfmProcess.SVMXC__Page_Layout__c AND SVMXC__Type__c = 'Header'];  
        }

        if(headerLayout != null && headerLayout.id != null)
        {
            if(userinfo.isMultiCurrencyOrganization()){
                //Commented below query and added new one for the story BAC-4410 to avoid querying extra fields which are not used
                //HeaderFieldList = [Select SystemModstamp, SVMXC__Field_Mapping__c, SVMXC__Title__c, SVMXC__Context_Source_Object__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Override_Related_Lookup__c, SVMXC__No_Of_Columns__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c ,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__IsStandard__c, SVMXC__Installation_Key__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: headerLayout.id and SVMXC__Detail_Type__c = 'Field'];

                //Added SVMXC__Field_Mapping__c in the query for the defect fix BAC-3884
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        HeaderFieldList = [SELECT Id, SVMXC__Field_API_Name__c, SVMXC__DataType__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Related_Object_Name__c, SVMXC__Field_Mapping__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Page_Layout__c =: headerLayout.id and SVMXC__Detail_Type__c = 'Field'];
            }
            else {
                //Commented below query and added new one for the story BAC-4410 to avoid querying extra fields which are not used
                //HeaderFieldList = [Select SystemModstamp, SVMXC__Field_Mapping__c, SVMXC__Title__c, SVMXC__Context_Source_Object__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Override_Related_Lookup__c, SVMXC__No_Of_Columns__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c ,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__IsStandard__c, SVMXC__Installation_Key__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: headerLayout.id and SVMXC__Detail_Type__c = 'Field' and SVMXC__Field_API_Name__c != 'CurrencyIsoCode']; 

                //Added SVMXC__Field_Mapping__c in the query for the defect fix BAC-3884
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        HeaderFieldList = [SELECT Id, SVMXC__Field_API_Name__c, SVMXC__DataType__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Related_Object_Name__c, SVMXC__Field_Mapping__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Page_Layout__c =: headerLayout.id and SVMXC__Detail_Type__c = 'Field' and SVMXC__Field_API_Name__c != 'CurrencyIsoCode'];
            }
                
        }
        /*if(HeaderFieldList.size() > 0 && (Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD')){
            for(SVMXC__Page_Layout_Detail__c PLD : HeaderFieldList){
                if(PLD.SVMXC__Field_API_Name__c.touppercase() == 'WHATID' && mapObjNameField.containskey(SourceObjName)){
                    PLD.SVMXC__Related_Object_Name__c = SourceObjName;
                    PLD.SVMXC__Related_Object_Name_Field__c = mapObjNameField.get(SourceObjName);
                }
            }
        } */  
        //Get the Detail Layouts 
        if(headerLayout != null && headerLayout.id != null){
            //Commented below query and added new one for the story BAC-4410 to avoid querying extra fields which are not used
            //detalLayoutList = [Select SVMXC__Type__c,SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c, SVMXC__Action_On_Zero_Lines__c,SVMXC__Name__c, SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c =: headerLayout.id and SVMXC__Type__c = 'Detail'];
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        detalLayoutList = [SELECT Id FROM SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c =: headerLayout.id and SVMXC__Type__c = 'Detail'];
        }

        if(detalLayoutList.size() > 0)
        {
            for(SVMXC__Page_Layout__c PLD : detalLayoutList)
            {
                if(PLD.id != null)
                {
                    detailLayoutIds.add(PLD.id);
                    detailFieldMap.put(PLD.id,new list<SVMXC__Page_Layout_Detail__c>());
                }  
            }
        }
        //Get the field list of detail layouts 
        if(detailLayoutIds.size() > 0 )
        {
            if(userinfo.isMultiCurrencyOrganization()){
                //Commented below query and added new one for the story BAC-4410 to avoid querying extra fields which are not used
                //DetailFieldList = [Select SystemModstamp, SVMXC__Field_Mapping__c, SVMXC__Context_Source_Object__c, SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Override_Related_Lookup__c, SVMXC__No_Of_Columns__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c ,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__IsStandard__c, SVMXC__Installation_Key__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN : detailLayoutIds and SVMXC__Detail_Type__c = 'Field'];

                //Added SVMXC__Field_Mapping__c in the query for the defect fix BAC-3884
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        DetailFieldList = [SELECT Id, SVMXC__Page_Layout__c, SVMXC__DataType__c, SVMXC__Field_API_Name__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c, SVMXC__Field_Mapping__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Page_Layout__c IN : detailLayoutIds AND SVMXC__Detail_Type__c = 'Field'];
            }
            else{
                //Commented below query and added new one for the story BAC-4410 to avoid querying extra fields which are not used
                //DetailFieldList = [Select SystemModstamp, SVMXC__Field_Mapping__c, SVMXC__Context_Source_Object__c, SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Override_Related_Lookup__c, SVMXC__No_Of_Columns__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c ,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__IsStandard__c, SVMXC__Installation_Key__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN : detailLayoutIds and SVMXC__Detail_Type__c = 'Field' and SVMXC__Field_API_Name__c != 'CurrencyIsoCode'];   

                //Added SVMXC__Field_Mapping__c in the query for the defect fix BAC-3884
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        DetailFieldList = [SELECT Id, SVMXC__Page_Layout__c, SVMXC__DataType__c, SVMXC__Field_API_Name__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c, SVMXC__Field_Mapping__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Page_Layout__c IN : detailLayoutIds AND SVMXC__Detail_Type__c = 'Field' and SVMXC__Field_API_Name__c != 'CurrencyIsoCode'];
            }
        }
        //Create the map of detail layout id-detail layout field list.
        if(DetailFieldList.size() > 0)
        {
            for(SVMXC__Page_Layout_Detail__c PLD : DetailFieldList)
            {
                if(PLD.SVMXC__Page_Layout__c != null && detailFieldMap.containskey(PLD.SVMXC__Page_Layout__c))
                    detailFieldMap.get(PLD.SVMXC__Page_Layout__c).add(PLD);
            }
        }  
        system.debug('detailFieldMap'+detailFieldMap);
        /*if(Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD'){
            for(String str : detailFieldMap.keyset()){
                String key = str.substring(0,15);
                list<SVMXC__Page_Layout_Detail__c> lstField = detailFieldMap.get(str);
                for(SVMXC__Page_Layout_Detail__c PLD : lstField){
                    if(PLD.SVMXC__Field_API_Name__c.touppercase() == 'WHATID'){
                        if(mapAliasNameObjectName.containskey(key)){
                            String strObjName = mapAliasNameObjectName.get(key);
                            if(mapObjNameField.containskey(strObjName)){
                                PLD.SVMXC__Related_Object_Name__c = strObjName;
                                PLD.SVMXC__Related_Object_Name_Field__c = mapObjNameField.get(strObjName);
                            }
                        }   
                    }
                }
            }
        } */
        //create map of header layout field's API name - header layout field record.
        if(HeaderFieldList.size() > 0)
        {
            for(SVMXC__Page_Layout_Detail__c PLD : HeaderFieldList)
            {
                if(PLD.SVMXC__Field_API_Name__c != null)
                    headerFieldMap.put(PLD.SVMXC__Field_API_Name__c,PLD);
            }
        }
        system.debug('headerFieldMap'+headerFieldMap);
         
        //Get the data 
        if(ProcessId != null && ProcessId.length() > 0 && RecId != null && RecId.length() > 0)//if SourceToTarget/Edit
        {
          targetRecMap = parseProcess.getSFM_ParseProcess2(processId,RecId,allObjMap,null,null,null,stringMap);
          mappedFieldsForHeader = parseProcess.mappedFieldsForHeader; //Added as part of Story BAC-3257
          mapAliasNameSourceRecIdTargetObject = parseProcess.mapAliasNameSourceRecIdTargetObject;
          mapAllFieldDescribe = parseProcess.mapAllFieldDescribe;
          mapFieldMapIdListOfFields = parseProcess.mapFieldMapIdListOfFields; //Added for the defect fix BAC-3884
          mapObjectNameWithDVFields = parseProcess.mapObjectNameWithDVFields; //Added for the story BAC-3885
          mapObjectNameFieldListSet = parseProcess.mapObjectNameFieldListSet; //Added for defect fix BAC-4032
          mapObjectNameFieldListForFormFill = parseProcess.mapObjectNameFieldListForFormFill;
          mapObjectAPINameWithFields = parseProcess.mapObjectAPINameWithFields;
        } 
        else if(ProcessId != null && ProcessId.length() > 0) //if Standalone Create
        {
            targetRecMap = parseProcess.getSFM_ParseProcess2(processId,null,allObjMap,null,null,null,stringMap);
            mapAllFieldDescribe = parseProcess.mapAllFieldDescribe;
            mappedFieldsForHeader = parseProcess.mappedFieldsForHeader;
            mapAliasNameSourceRecIdTargetObject = parseProcess.mapAliasNameSourceRecIdTargetObject;
            mapFieldMapIdListOfFields = parseProcess.mapFieldMapIdListOfFields;
            mapObjectNameWithDVFields = parseProcess.mapObjectNameWithDVFields;
            mapObjectNameFieldListSet = parseProcess.mapObjectNameFieldListSet;
            mapObjectNameFieldListForFormFill = parseProcess.mapObjectNameFieldListForFormFill;
            mapObjectAPINameWithFields = parseProcess.mapObjectAPINameWithFields;
        }
        system.debug('targetRecMap'+targetRecMap);
        system.debug('mapAliasNameSourceRecIdTargetObject'+mapAliasNameSourceRecIdTargetObject);
        
        //Now get the header record and create the SFM Taget 
        list<Sobject> headerSobjList = new list<Sobject>();
        if(headerLayout != null && headerLayout.SVMXC__Object_Name__c != null && targetRecMap.size() > 0 && targetRecMap.containskey(headerLayout.SVMXC__Object_Name__c))
        {
            headerSobjList = targetRecMap.get(headerLayout.SVMXC__Object_Name__c);
            //headerTargetObj.objectName = headerLayout.SVMXC__Object_Name__c;
        }
        else if(mapAliasNameSourceRecIdTargetObject.size() > 0 && headerLayout != null && headerLayout.SVMXC__Object_Name__c != null && mapAliasNameSourceRecIdTargetObject.containskey(headerLayout.SVMXC__Object_Name__c) && (Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL' || Process.SVMXC__Purpose__c.touppercase() == 'CHECKLIST'))
        {
            map<String,Sobject> mapSourceRecIdTargetRecord = new map<String,Sobject>();
            mapSourceRecIdTargetRecord = mapAliasNameSourceRecIdTargetObject.get(HeaderLayout.SVMXC__Object_Name__c);
            if(mapSourceRecIdTargetRecord.size() > 0)
            {
                for(String str : mapSourceRecIdTargetRecord.keyset())
                {
                    if(Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL')
                        headerDataSet.sourceRecordId  = str;
                    headerSobjList.add(mapSourceRecIdTargetRecord.get(str));
                }
            }
        }
        system.debug('headerSobjList'+headerSobjList);
        if(headerSobjList.size() > 0)
        {
            map<String,Schema.SObjectField> mapHeaderObjFieldDesc = new map<String,Schema.SObjectField>();
            if(mapAllFieldDescribe.containskey(TargetObjName))
                mapHeaderObjFieldDesc = mapAllFieldDescribe.get(TargetObjName);
            else{
                if(allObjMap.get(TargetObjName) != null){
                    Map<String, Schema.SObjectField> FieldMap = allObjMap.get(TargetObjName).getDescribe().fields.getMap();
                    Map<String, Schema.SObjectField> TempFieldMap = new Map<String, Schema.SObjectField>();
                    if(FieldMap.size() > 0)
                    {
                        for(String s1 : FieldMap.keyset())
                        {
                            TempFieldMap.put(FieldMap.get(s1).getDescribe().getName(),FieldMap.get(s1));
                        }
                        if(TempFieldMap.size() > 0)
                            mapAllFieldDescribe.put(TargetObjName,TempFieldMap);
                        
                        mapHeaderObjFieldDesc = mapAllFieldDescribe.get(TargetObjName);
                    }
                }
            }
            
            if(Process.SVMXC__Purpose__c.touppercase() == 'CHECKLIST')
            {
                List<Id> contentDocumentLinkIds = new List<Id>(); //Added for salesforce file
                Map<Id,ContentDocumentLink> mapCDLIdwithCDL = new Map<Id,ContentDocumentLink>(); //Added for salesforce file
                Map<Id,Id> mapCVwithCDLids = new Map<Id,Id>(); //Added for salesforce file
                list<Sobject> lstsobj = new list<Sobject>();
                lstsobj.addAll(headerSobjList);
                headerDataSet.lstSobjectInfo = lstsobj;
                
                //----Added for sending checklist attachment records------//
                if(targetRecId != null && targetRecId.length() > 0){
                    List<Sobject> lstChecklistAttachment = [SELECT Id, SVMXC__SM_Checklist__c, SVMXC__SM_Question__c, SVMXC__SM_Internal_Question_ID__c, SVMXC__SM_Attachment_ID__c, SVMXC__SM_Attachment_Name__c, SVMXC__SM_File_Type__c, SVMXC__SM_File_Size__c, SVMXC__SM_ContentDocumentLink_ID__c FROM SVMXC__SM_Checklist_Attachment__c WHERE SVMXC__SM_Checklist__c =: targetRecId];
                    
                    //Added for Salesforce file ---BAC-4042
                    for(Sobject sobj:lstChecklistAttachment){
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
                    for(Sobject sobj:lstChecklistAttachment){
                        SVMXC__SM_Checklist_Attachment__c checklistAttachmentObj = (SVMXC__SM_Checklist_Attachment__c)sobj;
                        if(mapCVwithCDLids.size()>0)
                        sobj.put('SVMXC__SM_ContentDocumentLink_ID__c',mapCVwithCDLids.get(checklistAttachmentObj.SVMXC__SM_ContentDocumentLink_ID__c));
                    }
                    //End----Salesforce file---- BAC-4042
                    
                    SFMResponse.records = lstChecklistAttachment;
                    System.debug('lstChecklistAttachment: '+lstChecklistAttachment);
                }
                //----Added for sending checklist attachment records------//
            }
            else
            {
                Sobject sobj = headerSobjList[0];
                headerDataSet.sobjectInfo = sobj;
                
                //Added as part of Story BAC-3257
                headerDataSet.mappedFieldsForHeader = mappedFieldsForHeader;
            }
            if(Process.SVMXC__Purpose__c.touppercase() == 'CHECKLIST')
                headerDataSet.sourceRecordId = RecId;
            list<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper> bubbleWrapList = new list<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper>();
            
            if(headerFieldMap.size() > 0)
            {
                Set<String> setAllFieldsUsedInBubbleInfo = new Set<String>(); //Added for the defect fix BAC-3884
                Sobject sobj = headerSobjList[0];
                for(String s : headerFieldMap.keyset())
                {
                    //Added for not adding duplicate field in the bubbleinfo object - for the defect 043715
                    System.debug('mapObjectNameAndListOfDupFields: '+COMM_Utils_V2.mapObjectNameAndListOfDupFields);
                  if(COMM_Utils_V2.mapObjectNameAndListOfDupFields != null && COMM_Utils_V2.mapObjectNameAndListOfDupFields.size() > 0 && COMM_Utils_V2.mapObjectNameAndListOfDupFields.containsKey(headerLayout.SVMXC__Object_Name__c) && COMM_Utils_V2.mapObjectNameAndListOfDupFields.get(headerLayout.SVMXC__Object_Name__c).contains(s)){
                    continue;
                  }
                  
                    if(HeaderFieldMap.get(s).SVMXC__DataType__c != null && HeaderFieldMap.get(s).SVMXC__DataType__c.touppercase() == 'REFERENCE')
                    {
                        String DefaultValue = String.valueof(sobj.get(s));
                        if(DefaultValue != null){
                            SVMXC.SFM_WrapperDef.SFM_BubbleWrapper bubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper(null); //Added null for calling parameter constructor for the story BAC-4410
                            bubbleWrapper.fieldapiname = s;
                            bubbleWrapper.response = null; //Added for fixing defect 043843 and for story BAC-4410
                            
                            map<String,string> valuemap = new map<String,string>(); 
                            if(HeaderFieldMap.get(s).SVMXC__Named_Search__c != null && HeaderFieldMap.get(s).SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != null && HeaderFieldMap.get(s).SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != HeaderFieldMap.get(s).SVMXC__Related_Object_Name_Field__c)
                            {
                                String FieldName = HeaderFieldMap.get(s).SVMXC__Related_Object_Name_Field__c + ','+ HeaderFieldMap.get(s).SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c;
                                valuemap = SFMUtils.GetRelationshipData(new set<String>{DefaultValue},HeaderFieldMap.get(s).SVMXC__Related_Object_Name__c,FieldName);
                            }
                            else
                            {
                                valuemap = SFMUtils.GetRelationshipData(new set<String>{DefaultValue},HeaderFieldMap.get(s).SVMXC__Related_Object_Name__c,HeaderFieldMap.get(s).SVMXC__Related_Object_Name_Field__c);
                            }  
                            //system.debug('Called REFERENCE'+value);
                            SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                            strmap.key = DefaultValue;
                            if(valuemap != null && valuemap.containskey(DefaultValue))
                                strmap.value = valuemap.get(DefaultValue);
                            bubbleWrapper.fieldvalue = strmap;
                            bubbleWrapList.add(bubbleWrapper);
                        }
                        
                        //-----Start----Added for the defect fix BAC-3884
                        /*if(HeaderFieldMap.get(s).SVMXC__Field_Mapping__c != null && mapFieldMapIdListOfFields.size() > 0 && mapFieldMapIdListOfFields.containsKey(HeaderFieldMap.get(s).SVMXC__Field_Mapping__c)){
                            Set<String> setOfFields = mapFieldMapIdListOfFields.get(HeaderFieldMap.get(s).SVMXC__Field_Mapping__c);
                            for(String strField : setOfFields){
                                if(!setAllFieldsUsedInBubbleInfo.contains(strField)){
                                    String fieldValue = String.valueof(sobj.get(strField));
                                    if(String.isEmpty(fieldValue) && !HeaderFieldMap.containsKey(strField)){
                                        SVMXC.SFM_WrapperDef.SFM_BubbleWrapper objBubbleWrapper = createBubbleInfoObject(strField, fieldValue, fieldValue);
                                        bubbleWrapList.add(objBubbleWrapper);
                                    }
                                }
                                setAllFieldsUsedInBubbleInfo.add(strField);
                            }
                        }*/
                        //-----End------Added for the defect fix BAC-3884
                    } else if(isDateTimeConversionRequired && HeaderFieldMap.get(s).SVMXC__DataType__c.touppercase() == 'DATETIME' && sobj.get(s) != null) {
                        Schema.Describefieldresult f;
                        if(mapHeaderObjFieldDesc.containskey(s) && mapHeaderObjFieldDesc.get(s) != null)
                            f = mapHeaderObjFieldDesc.get(s).getDescribe();
                        
                        if(f != null && (f.isCalculated() || !f.isCustom()) && f.getType() == schema.Displaytype.DateTime){
                            SVMXC.SFM_WrapperDef.SFM_BubbleWrapper bubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper(null);
                            bubbleWrapper.fieldapiname = s;
                            bubbleWrapper.response = null;

                            String dat1 = String.valueof(datetime.valueof(sobj.get(s))); 
                            String dat2;
                            if((datetime.valueof(sobj.get(s))) != null)
                                dat2 = (datetime.valueof(sobj.get(s))).format('yyyy-MM-dd HH:mm:ss');
                            SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(dat1, dat2);
                            BubbleWrapper.fieldvalue = strmap;
                            bubbleWrapList.add(bubbleWrapper);
                        }
                    }
                }
                //---Start--Added for defect fix BAC-4032
                /*Set<String> setAllFieldUsedByFieldSet = new Set<String>();
                if(mapObjectNameFieldListSet.size() > 0 && mapObjectNameFieldListSet.containsKey(headerLayout.SVMXC__Object_Name__c)){
                    for(String strField : mapObjectNameFieldListSet.get(headerLayout.SVMXC__Object_Name__c)){

                        //Added for not adding duplicate field in the bubbleinfo object - for the defect 043715
                        if(COMM_Utils_V2.mapObjectNameAndListOfDupFields != null && COMM_Utils_V2.mapObjectNameAndListOfDupFields.size() > 0 && COMM_Utils_V2.mapObjectNameAndListOfDupFields.containsKey(headerLayout.SVMXC__Object_Name__c) && COMM_Utils_V2.mapObjectNameAndListOfDupFields.get(headerLayout.SVMXC__Object_Name__c).contains(strField)){
                            continue;
                        }

                        if(!setAllFieldsUsedInBubbleInfo.contains(strField)){
                            String fieldValue = String.valueof(sobj.get(strField));
                            if(String.isEmpty(fieldValue) && !HeaderFieldMap.containsKey(strField)){
                                SVMXC.SFM_WrapperDef.SFM_BubbleWrapper objBubbleWrapper = createBubbleInfoObject(strField, fieldValue, fieldValue);
                                bubbleWrapList.add(objBubbleWrapper);
                            }
                        }
                        setAllFieldUsedByFieldSet.add(strField);
                    }
                }*/
                //---End--Added for defect fix BAC-4032

                if(mapObjectNameWithDVFields.size() > 0 && mapObjectNameWithDVFields.containsKey(headerLayout.SVMXC__Object_Name__c)){
                    Set<String> fieldSets = mapObjectNameWithDVFields.get(headerLayout.SVMXC__Object_Name__c);
                    if(!parseProcess.mapObjectNameVsListOfFields.containsKey(headerLayout.SVMXC__Object_Name__c)){
                        parseProcess.mapObjectNameVsListOfFields.put(headerLayout.SVMXC__Object_Name__c, new Set<String>());
                    }
                    parseProcess.mapObjectNameVsListOfFields.get(headerLayout.SVMXC__Object_Name__c).addAll(fieldSets);
                }
                
                if(mapObjectNameFieldListSet.size() > 0 && mapObjectNameFieldListSet.containsKey(headerLayout.SVMXC__Object_Name__c)){
                    Set<String> fieldSets = mapObjectNameFieldListSet.get(headerLayout.SVMXC__Object_Name__c);
                    if(!parseProcess.mapObjectNameVsListOfFields.containsKey(headerLayout.SVMXC__Object_Name__c)){
                        parseProcess.mapObjectNameVsListOfFields.put(headerLayout.SVMXC__Object_Name__c, new Set<String>());
                    }
                    parseProcess.mapObjectNameVsListOfFields.get(headerLayout.SVMXC__Object_Name__c).addAll(fieldSets);
                }
                
                if(mapObjectNameFieldListForFormFill.size() > 0 && mapObjectNameFieldListForFormFill.containsKey(headerLayout.SVMXC__Object_Name__c)){
                    Set<String> fieldSets = mapObjectNameFieldListForFormFill.get(headerLayout.SVMXC__Object_Name__c);
                    if(!parseProcess.mapObjectNameVsListOfFields.containsKey(headerLayout.SVMXC__Object_Name__c)){
                        parseProcess.mapObjectNameVsListOfFields.put(headerLayout.SVMXC__Object_Name__c, new Set<String>());
                    }
                    parseProcess.mapObjectNameVsListOfFields.get(headerLayout.SVMXC__Object_Name__c).addAll(fieldSets);
                }
                
                if(mapObjectAPINameWithFields.size() > 0 && mapObjectAPINameWithFields.containsKey(headerLayout.SVMXC__Object_Name__c)){
                    Set<String> fieldSets = mapObjectAPINameWithFields.get(headerLayout.SVMXC__Object_Name__c);
                    if(!parseProcess.mapObjectNameVsListOfFields.containsKey(headerLayout.SVMXC__Object_Name__c)){
                        parseProcess.mapObjectNameVsListOfFields.put(headerLayout.SVMXC__Object_Name__c, new Set<String>());
                    }
                    parseProcess.mapObjectNameVsListOfFields.get(headerLayout.SVMXC__Object_Name__c).addAll(fieldSets);
                }
                //------Start------Added for the story BAC-3885
                /*if(mapObjectNameWithDVFields.size() > 0 && String.isNotBlank(headerLayout.SVMXC__Object_Name__c) && mapObjectNameWithDVFields.containsKey(headerLayout.SVMXC__Object_Name__c)){
                    Set<String> setOfFieldUsedInDVR = mapObjectNameWithDVFields.get(headerLayout.SVMXC__Object_Name__c);
                    for(String strField : setOfFieldUsedInDVR){

                        //Added for not adding duplicate field in the bubbleinfo object - for the defect 043715
                        if(COMM_Utils_V2.mapObjectNameAndListOfDupFields != null && COMM_Utils_V2.mapObjectNameAndListOfDupFields.size() > 0 && COMM_Utils_V2.mapObjectNameAndListOfDupFields.containsKey(headerLayout.SVMXC__Object_Name__c) && COMM_Utils_V2.mapObjectNameAndListOfDupFields.get(headerLayout.SVMXC__Object_Name__c).contains(strField)){
                            continue;
                        }

                        if(!setAllFieldsUsedInBubbleInfo.contains(strField) && !setAllFieldUsedByFieldSet.contains(strField)){
                            String fieldValue = String.valueof(sobj.get(strField));
                            if(String.isEmpty(fieldValue) && !HeaderFieldMap.containsKey(strField)){
                                SVMXC.SFM_WrapperDef.SFM_BubbleWrapper objBubbleWrapper = createBubbleInfoObject(strField, fieldValue, fieldValue);
                                bubbleWrapList.add(objBubbleWrapper);
                            }
                        }
                    }
                }*/
                //------End--------Added for the story BAC-3885
            }
            headerDataSet.bubbleInfo = bubbleWrapList;
        }
        
        //create a Page Data Set for Detail records 
        list<SVMXC.SFM_WrapperDef.SFM_DetailDataSet> detailDataSetList = new list<SVMXC.SFM_WrapperDef.SFM_DetailDataSet>();
        //Added by Nidhi as part of Lazy Loading BAC-4680
        Boolean isAllTabRecLoaded = true;
        //IF STANDALONE EDIT
        if(batchsize>0 && Process.SVMXC__Purpose__c.touppercase() == 'STANDALONE EDIT'){
            String mapObjectNameWithDVFieldsJSON = JSON.serialize(mapObjectNameWithDVFields);
            String mapObjectNameAndListOfDupFieldsJSON = JSON.serialize(COMM_Utils_V2.mapObjectNameAndListOfDupFields);
            String mapObjectNameFieldListSetJSON = JSON.serialize(mapObjectNameFieldListSet);
            String mapFieldMapIdListOfFieldsJSON = JSON.serialize(mapFieldMapIdListOfFields);

            pageData.bubbleInfoCollections.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('mapObjectNameWithDVFields',mapObjectNameWithDVFieldsJSON));
            pageData.bubbleInfoCollections.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('mapObjectNameAndListOfDupFields',mapObjectNameAndListOfDupFieldsJSON));
            pageData.bubbleInfoCollections.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('mapObjectNameFieldListSet',mapObjectNameFieldListSetJSON));
            pageData.bubbleInfoCollections.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('mapFieldMapIdListOfFields',mapFieldMapIdListOfFieldsJSON));
        }
        //Added by Nidhi as part of Lazy Loading BAC-4680
        
        if(detailFieldMap.size() > 0)
        {
            //describe fields here only and use it later. This is for defect 039760 fix
            Map<String, Map<String, Schema.Describefieldresult>> mapObjectFieldAndFieldDesc = new Map<String, Map<String, Schema.Describefieldresult>>();

            for(String s : detailFieldMap.keyset())
            {
                map<String,Sobject> mapSourceRecIdTargetObj = new map<String,Sobject>();
                list<Sobject> detailRecords = new list<Sobject>();
                list<String> lstSourceRecId = new list<String>();
                SVMXC.SFM_WrapperDef.SFM_DetailDataSet detailDataSet = new SVMXC.SFM_WrapperDef.SFM_DetailDataSet();
                list<SVMXC.SFM_WrapperDef.SFM_PageDataSet> pageDataSetList= new list<SVMXC.SFM_WrapperDef.SFM_PageDataSet>();
                detailDataSet.aliasName = s;
                //first get the record for the detail layout 
                if(mapAliasNameSourceRecIdTargetObject.containskey(s.substring(0,15)) && (Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL'))
                {
                    mapSourceRecIdTargetObj = mapAliasNameSourceRecIdTargetObject.get(s.substring(0,15));
                    system.debug('mapSourceRecIdTargetObj'+mapSourceRecIdTargetObj);
                    if(mapSourceRecIdTargetObj.size() > 0)
                    {
                        for(String str : mapSourceRecIdTargetObj.keyset())
                        {
                            detailRecords.add(mapSourceRecIdTargetObj.get(str));
                            lstSourceRecId.add(str);
                        }
                    }
                system.debug('detailRecords'+detailRecords);
                }
                else if(targetRecMap.containskey(s.substring(0,15)))
                    detailRecords = targetRecMap.get(s.substring(0,15));
                //get the all field list for that perticuler layout.
                list<SVMXC__Page_Layout_Detail__c> detailFields = new list<SVMXC__Page_Layout_Detail__c>();
                detailFields = detailFieldMap.get(s);
                system.debug('detailFields'+detailFields);
                //first calculate the ID-Name pair in bulck mode
                map<String,String> IdNameMap = new map<String,String>();
                
                if(detailRecords.size() > 0 && detailFields.size() > 0)
                {
                    map<String,String> FieldObjMap = new map<String,String>();
                    map<String,String> FieldNameFieldMap = new map<String,String>(); 
                    map<String,String> FieldLookUpColumnMap = new map<String,String>(); 
                    for(integer a = 0;a<detailFields.size();a++)
                    {
                        if(detailFields[a].SVMXC__DataType__c != null && detailFields[a].SVMXC__DataType__c.touppercase() == 'REFERENCE' && detailFields[a].SVMXC__Field_API_Name__c != null && detailFields[a].SVMXC__Related_Object_Name__c != null && detailFields[a].SVMXC__Related_Object_Name_Field__c != null)
                        {  
                            FieldObjMap.put(detailFields[a].SVMXC__Field_API_Name__c,detailFields[a].SVMXC__Related_Object_Name__c);
                            FieldNameFieldMap.put(detailFields[a].SVMXC__Field_API_Name__c,detailFields[a].SVMXC__Related_Object_Name_Field__c);
                            if(detailFields[a].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != null && detailFields[a].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != detailFields[a].SVMXC__Related_Object_Name_Field__c)
                                FieldLookUpColumnMap.put(detailFields[a].SVMXC__Field_API_Name__c,detailFields[a].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c);
                        }  
                    }
                    system.debug('FieldLookUpColumnMap'+FieldLookUpColumnMap); 
                    if(FieldObjMap.size() > 0 && FieldNameFieldMap.size() > 0)
                    {
                        for(String fld : FieldObjMap.keyset())
                        {
                            set<String> ids = new set<String>();
                            for(Integer b = 0;b<detailRecords.size();b++)
                            {
                                if(detailRecords[b].get(fld) != null)
                                    ids.add(String.valueof(detailRecords[b].get(fld)));
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
                    system.debug('IdNameMap'+IdNameMap); 
                }
                if(detailRecords.size() > 0)
                {
                    String strObjectNameForDetail = ''; 
                    if(detailFields.size() > 0){
                        strObjectNameForDetail = detailFields[0].SVMXC__Page_Layout__r.SVMXC__Object_Name__c;
                    }
                    
                    if(mapObjectNameWithDVFields.size() > 0 && mapObjectNameWithDVFields.containsKey(strObjectNameForDetail)){
                Set<String> fieldSets = mapObjectNameWithDVFields.get(strObjectNameForDetail);
                if(!parseProcess.mapObjectNameVsListOfFields.containsKey(strObjectNameForDetail)){
                    parseProcess.mapObjectNameVsListOfFields.put(strObjectNameForDetail, new Set<String>());
                }
                parseProcess.mapObjectNameVsListOfFields.get(strObjectNameForDetail).addAll(fieldSets);
            }
                    
            if(mapObjectNameFieldListSet.size() > 0 && mapObjectNameFieldListSet.containsKey(strObjectNameForDetail)){
                Set<String> fieldSets = mapObjectNameFieldListSet.get(strObjectNameForDetail);
                if(!parseProcess.mapObjectNameVsListOfFields.containsKey(strObjectNameForDetail)){
                    parseProcess.mapObjectNameVsListOfFields.put(strObjectNameForDetail, new Set<String>());
                }
                parseProcess.mapObjectNameVsListOfFields.get(strObjectNameForDetail).addAll(fieldSets);
            }
                    
            if(mapObjectNameFieldListForFormFill.size() > 0 && mapObjectNameFieldListForFormFill.containsKey(strObjectNameForDetail)){
                Set<String> fieldSets = mapObjectNameFieldListForFormFill.get(strObjectNameForDetail);
                if(!parseProcess.mapObjectNameVsListOfFields.containsKey(strObjectNameForDetail)){
                    parseProcess.mapObjectNameVsListOfFields.put(strObjectNameForDetail, new Set<String>());
                }
                parseProcess.mapObjectNameVsListOfFields.get(strObjectNameForDetail).addAll(fieldSets);
            }
                    
                    if(mapObjectAPINameWithFields.size() > 0 && mapObjectAPINameWithFields.containsKey(strObjectNameForDetail)){
                        Set<String> fieldSets = mapObjectAPINameWithFields.get(strObjectNameForDetail);
                        if(!parseProcess.mapObjectNameVsListOfFields.containsKey(strObjectNameForDetail)){
                            parseProcess.mapObjectNameVsListOfFields.put(strObjectNameForDetail, new Set<String>());
                        }
                        parseProcess.mapObjectNameVsListOfFields.get(strObjectNameForDetail).addAll(fieldSets);
                    }
                    
                    //String strObjectNameForDetail; 
                    if(isDateTimeConversionRequired && detailFields.size() > 0){
                        for(Integer j=0; j<detailFields.size(); j++){
                            if(detailFields[j].SVMXC__DataType__c.touppercase() == 'DATETIME'){
                                Schema.Describefieldresult fieldDescribe;
                                String strObjectName = detailFields[j].SVMXC__Page_Layout__r.SVMXC__Object_Name__c;
                                String strFieldAPI = detailFields[j].SVMXC__Field_API_Name__c;

                                if(mapAllFieldDescribe.containskey(strObjectName)){
                                    if(!mapObjectFieldAndFieldDesc.containskey(strObjectName)){
                                        mapObjectFieldAndFieldDesc.put(strObjectName, new Map<String, Schema.Describefieldresult>());
                                    }

                                    Map<String,Schema.SObjectField> mapDetailObjFieldDesc = mapAllFieldDescribe.get(strObjectName);
                                    if(mapDetailObjFieldDesc.containskey(strFieldAPI) && !mapObjectFieldAndFieldDesc.get(strObjectName).containskey(strFieldAPI)){
                                        fieldDescribe = mapDetailObjFieldDesc.get(strFieldAPI).getDescribe();
                                        mapObjectFieldAndFieldDesc.get(strObjectName).put(strFieldAPI, fieldDescribe);
                                    }
                                }
                            }
                        }
                    }
                    

                    //

                    for(Integer i = 0;i<detailRecords.size();i++)
                    {
                        Sobject sobj = detailRecords[i];
                        SVMXC.SFM_WrapperDef.SFM_PageDataSet pageDataSet = new SVMXC.SFM_WrapperDef.SFM_PageDataSet();
                        pageDataSet.response = null; //Added for fixing defect 043843 and story BAC-4410
                        if(lstSourceRecId.size() > 0)
                            pageDataSet.sourceRecordId = lstSourceRecId[i];
                        pageDataSet.sobjectInfo = sobj;
                        list<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper> bubbleWrapList = new list<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper>();
                        if(detailFields.size() > 0)
                        {
                            for(Integer j = 0;j<detailFields.size();j++)
                            {
                                //Added for not adding duplicate field in the bubbleinfo object - for the defect 043715
                                if(COMM_Utils_V2.mapObjectNameAndListOfDupFields != null && COMM_Utils_V2.mapObjectNameAndListOfDupFields.size() > 0 && COMM_Utils_V2.mapObjectNameAndListOfDupFields.containsKey(strObjectNameForDetail) && COMM_Utils_V2.mapObjectNameAndListOfDupFields.get(strObjectNameForDetail).contains(detailFields[j].SVMXC__Field_API_Name__c)){
                                    continue;
                                }
                                
                                if(detailFields[j].SVMXC__Related_Object_Name__c != null && detailFields[j].SVMXC__DataType__c.touppercase() == 'REFERENCE')
                                {
                                    if(detailRecords[i].get(detailFields[j].SVMXC__Field_API_Name__c)!=null){
                                        SVMXC.SFM_WrapperDef.SFM_BubbleWrapper bubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper(null); //Added null for calling parameter constructor for the story BAC-4410
                                        bubbleWrapper.response = null; //Added for fixing defect 043843 and story BAC-4410
                                        bubbleWrapper.fieldapiname = detailFields[j].SVMXC__Field_API_Name__c;
                                        String DefaultValue = String.valueof(detailRecords[i].get(detailFields[j].SVMXC__Field_API_Name__c));
                                        
                                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                                        strmap.key = DefaultValue;
                                        if(IdNameMap.containskey(DefaultValue))
                                            strmap.value = IdNameMap.get(DefaultValue);
                                        bubbleWrapper.fieldvalue = strmap;
                                        bubbleWrapList.add(bubbleWrapper);
                                    }
                                } else if(isDateTimeConversionRequired && detailFields[j].SVMXC__DataType__c.touppercase() == 'DATETIME' && detailRecords[i].get(detailFields[j].SVMXC__Field_API_Name__c) != null) {
                                    Schema.Describefieldresult f = (mapObjectFieldAndFieldDesc.get(detailFields[j].SVMXC__Page_Layout__r.SVMXC__Object_Name__c)).get(detailFields[j].SVMXC__Field_API_Name__c);
                                    if(f != null && (f.isCalculated() || !f.isCustom()) && f.getType() == schema.Displaytype.DateTime){
                                        SVMXC.SFM_WrapperDef.SFM_BubbleWrapper bubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper(null);
                                        bubbleWrapper.response = null;
                                        bubbleWrapper.fieldapiname = detailFields[j].SVMXC__Field_API_Name__c;

                                        String dat1 = String.valueof(datetime.valueof(detailRecords[i].get(detailFields[j].SVMXC__Field_API_Name__c))); 
                                        String dat2 = (datetime.valueof(detailRecords[i].get(detailFields[j].SVMXC__Field_API_Name__c))).format('yyyy-MM-dd HH:mm:ss');
                                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(dat1, dat2);
                                        BubbleWrapper.fieldvalue = strmap;
                                        bubbleWrapList.add(bubbleWrapper);
                                    }                               
                                }
                            }
                            pageDataSet.bubbleInfo = bubbleWrapList;
                        }
                        pageDataSetList.add(pageDataSet);
                    }   
                }
                detailDataSet.pageDataSet = pageDataSetList;
                //Added by Nidhi as part of Lazy Loading BAC-4680
                if(Process.SVMXC__Purpose__c.touppercase() != 'STANDALONE EDIT'){
                    detailDataSet.isAllRecordsLoaded = true;
                }
                else if(batchsize==0 || (batchsize>0 && (pageDataSetList.size()==0 || pageDataSetList.size()< batchsize))){
                    detailDataSet.isAllRecordsLoaded = true;
                }else{
                    detailDataSet.isAllRecordsLoaded = false;
                    isAllTabRecLoaded = false;
                     
                    if(batchsize>0){//Lazy Loading is implemented only if Setting SFM002_SET005 is greater than 0
                        detailDataSet.offsetValue = String.valueOf(batchsize);
                        if(detailFieldMap.get(s).size()!=0 && detailFieldMap.get(s)[0].SVMXC__Page_Layout__c!=null){
                            detailDataSet.objectApiName = detailFieldMap.get(s)[0].SVMXC__Page_Layout__r.SVMXC__Object_Name__c;
                        }                       
                        if(mapDetailTabIdFieldList.containsKey(s.substring(0,15)) && !String.isBlank(mapDetailTabIdFieldList.get(s.substring(0,15)))){
                            detailDataSet.fieldList = mapDetailTabIdFieldList.get(s.substring(0,15));   
                        }else{
                            detailDataSet.fieldList = 'AllFields';
                        }
                        if(mapAliasNameWhereClause.containsKey(s.substring(0,15))){
                            detailDataSet.whereClause = mapAliasNameWhereClause.get(s.substring(0,15));   
                        }
                        if(SFM_ParseProcess.mapSortingFields.containsKey(s.substring(0,15))){
                            detailDataSet.orderByFields = SFM_ParseProcess.mapSortingFields.get(s.substring(0,15));   
                        }
                    }
                
                }                   
                //Added by Nidhi ends here
                detailDataSetList.add(detailDataSet);
            }
        }
        headerDataSet.response = null; //Added for fixing defect 043843 and for story BAC-4410
        //------Start------Added for the story BAC-4264
        if(parseProcess.mapObjectNameVsListOfFields != null && parseProcess.mapObjectNameVsListOfFields.size() > 0){
            List<SVMXC.SFM_WrapperDef.SFM_StringListMap> fieldsQueriedPerObject = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
            for(String strObject: parseProcess.mapObjectNameVsListOfFields.keyset()){
                SVMXC.SFM_WrapperDef.SFM_StringListMap objSFM_StringListMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
                objSFM_StringListMap.key = strObject;
                objSFM_StringListMap.valueList = new List<String>(parseProcess.mapObjectNameVsListOfFields.get(strObject));
                fieldsQueriedPerObject.add(objSFM_StringListMap);
            }
            pageData.fieldsQueriedPerObject = fieldsQueriedPerObject;
        }
        //------End--------Added for the story BAC-4264
        pageData.pageDataSet = headerDataSet;
        pageData.detailDataSet = detailDataSetList;
        pageData.response = SFMResponse;
        pageData.isAllTabDataLoaded = isAllTabRecLoaded;//Added by Nidhi as part of Lazy Loading BAC-4680
        system.debug('SFMResponse'+SFMResponse);
        
        //Send Servicemax Constants
        SVMXC.SVMX_Constant_Utils constantUtils = new SVMXC.SVMX_Constant_Utils(); 
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap1 = new SVMXC.SFM_WrapperDef.SFM_StringMap('SVMX.USERTRUNK', constantUtils.getSVMXUserTrunkId());
        lstStringMap.add(stringMap1);
        pageData.svmxConstants = lstStringMap;
        system.debug('headerDataSet'+headerDataSet);
        system.debug('detailDataSetList'+detailDataSetList);
        system.debug('pageData.response'+pageData.response);
        return pageData;
    }

    //Added by Nidhi as part of Lazy Loading BAC-4680
    public SVMXC.SFM_WrapperDef.SFM_PageDataV2 SFM_getDataV2(SFMDeliveryServiceImpl.PageDataRequestV2 request){       
        Map<String,List<String>> mapObjectNameWithDVFieldsV2 = new Map<String,List<String>>();
        Map<String,List<String>> mapObjectNameAndListOfDupFieldsV2 = new Map<String,List<String>>();
        Map<String,List<String>> mapObjectNameFieldListSetV2 = new Map<String,List<String>>();
        Map<String,List<String>> mapFieldMapIdListOfFieldsV2 = new Map<String,List<String>>();
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> bubbleInfoCollectionsList = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        String headerRecordId = request.recordId;
        if(request != null && request.bubbleInfoCollections != null){
            bubbleInfoCollectionsList.addAll(request.bubbleInfoCollections);
        }
        
        //Get the bubble info related maps from the request
        for(SVMXC.SFM_WrapperDef.SFM_StringMap item : bubbleInfoCollectionsList){         
            Map<String, Object> initialStringMap = (Map<String, Object>)JSON.deserializeUntyped(item.value);
            for(String str : initialStringMap.keySet()){
                List<Object> objList =(List<Object>)initialStringMap.get(str);
                for(Object obj : objList){
                    String valueString = (String)obj;
                    if(item.key=='mapObjectNameWithDVFields'){
                        if(!mapObjectNameWithDVFieldsV2.containskey(str)){
                            mapObjectNameWithDVFieldsV2.put(str,new List<String>());
                        }
                        mapObjectNameWithDVFieldsV2.get(str).add(valueString);
                    }else if(item.key=='mapObjectNameAndListOfDupFields'){
                        if(!mapObjectNameAndListOfDupFieldsV2.containskey(str)){
                            mapObjectNameAndListOfDupFieldsV2.put(str,new List<String>());
                        }
                        mapObjectNameAndListOfDupFieldsV2.get(str).add(valueString);
                    }else if(item.key=='mapObjectNameFieldListSet'){
                        if(!mapObjectNameFieldListSetV2.containskey(str)){
                            mapObjectNameFieldListSetV2.put(str,new List<String>());
                        }
                        mapObjectNameFieldListSetV2.get(str).add(valueString);
                    }else{
                        if(!mapFieldMapIdListOfFieldsV2.containskey(str)){
                            mapFieldMapIdListOfFieldsV2.put(str,new List<String>());
                        }
                        mapFieldMapIdListOfFieldsV2.get(str).add(valueString);
                    }
                }                                                           
            }
        }
        
        Map<String,List<sobject>> detailTabData = new Map<String,List<sobject>>();
        Map<String,SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest> mapAliasNameRequest = new Map<String,SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest>();
        List<String> listSobjectApiNames = new List<String>();//This holds all the Sobject Api Names in detailDataSet of the request,used for describing fields.

        for(SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest detailTab : request.detailDataSet){
            if(!detailTab.isAllRecordsLoaded){
                if(!String.isBlank(detailTab.objectApiName)){
                    listSobjectApiNames.add(detailTab.objectApiName);
                }
            }
        }
        //Describe all the fields for Sobjects in the request, this is used while forming bubble Info for each detail record.       
        map<String,map<String, Schema.SObjectField>> mapAllFieldDescribe = new map<String,map<String, Schema.SObjectField>>();
        Schema.DescribeSobjectResult[] objDesc = Schema.describeSObjects(listSobjectApiNames);              
        for(Schema.DescribeSobjectResult res : objDesc) {
            Map<String, Schema.SObjectField> fieldsDescribeMap = res.fields.getMap();
            mapAllFieldDescribe.put(res.getName(),fieldsDescribeMap);
        }
        
        if(request.detailDataSet != null){//Query detail records for all tabs           
            for(SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest detailTab : request.detailDataSet){               
                mapAliasNameRequest.put(detailTab.aliasName,detailTab); 
            }
        }
        
        //Query Page LAyout Details for all the tabs.
        system.debug('==mapAliasNameRequest=='+mapAliasNameRequest);
        List<SVMXC__Page_Layout_Detail__c> DetailFieldList = new List<SVMXC__Page_Layout_Detail__c>();
        Map<String,list<SVMXC__Page_Layout_Detail__c>> detailFieldMap = new Map<String,List<SVMXC__Page_Layout_Detail__c>>();
        DetailFieldList = [SELECT Id, SVMXC__Page_Layout__c, SVMXC__DataType__c, SVMXC__Field_API_Name__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c, SVMXC__Field_Mapping__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Page_Layout__c IN : mapAliasNameRequest.keyset() AND SVMXC__Detail_Type__c = 'Field' and SVMXC__Field_API_Name__c != 'CurrencyIsoCode'];//Try session cache for this
        for(SVMXC__Page_Layout_Detail__c detail: DetailFieldList){
            if(!detailFieldMap.containskey(String.valueOf(detail.SVMXC__Page_Layout__c))){
                detailFieldMap.put(String.valueOf(detail.SVMXC__Page_Layout__c),new List<SVMXC__Page_Layout_Detail__c>());
            }
            detailFieldMap.get(String.valueOf(detail.SVMXC__Page_Layout__c)).add(detail);
        }
        
        if(request.detailDataSet != null){//Query detail records for all tabs           
            for(SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest detailTab : request.detailDataSet){        
                List<Sobject> sObjectList = new List<Sobject>();
                List<String> listOfFields = new List<String>();
                String queryString = '';
                String strFieldList = detailTab.fieldList;
                String ObjectName = detailTab.objectApiName;
                String whereClause = detailTab.whereClause;
                String strOrderByClause = detailTab.orderByFields;
                String offsetValue = detailTab.offsetValue;
                //This is to get the name field for each tab and apply default sort with name field if no sortung is applied by user
                String nameField = '';
                if(mapAllFieldDescribe.containsKey(ObjectName) && mapAllFieldDescribe.get(ObjectName)!=null)
                {
                    map<String, Schema.SObjectField> FieldMap = mapAllFieldDescribe.get(ObjectName);
                    for(String item : FieldMap.keyset())
                    {
                        Schema.DescribeFieldResult dfr = FieldMap.get(item).getDescribe();
                        if(dfr.isNameField()){
                            nameField = dfr.getName();
                            break;
                        }
                    }
                }
                if(String.isBlank(nameField)){
                    nameField = 'Id';
                }
                if(String.isblank(strOrderByClause)){
                    strOrderByClause = nameField;
                }
                if(!detailTab.isAllRecordsLoaded){
                    queryString = 'Select '+strFieldList+' From '+ObjectName;
                    if(!String.isblank(whereClause)){
                        queryString +=' Where '+whereClause;
                    }
                    if(!String.isblank(strOrderByClause)){
                        queryString +=' Order By '+strOrderByClause;
                    }
                    
                    queryString +=' Limit '+String.valueOf(batchsize);
                    if(!String.isblank(offsetValue)){
                        queryString +=' OFFSET  '+offsetValue;
                    }
                    system.debug('queryString=='+queryString);
                    if(!String.isBlank(strFieldList) && strFieldList!='AllFields'){
                        listOfFields = strFieldList.split(',');
                        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( ObjectName,listOfFields,COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }                       
                        sObjectList = Database.query(queryString);                      
                    }else if(strFieldList=='AllFields'){
                        if(!mapAllFieldDescribe.isEmpty() && mapAllFieldDescribe.containsKey(ObjectName) && mapAllFieldDescribe.get(ObjectName)!=null){
                            listOfFields.addAll(mapAllFieldDescribe.get(ObjectName).keySet());
                        }                    
                        sObjectList = getMergeResultSet(listOfFields,ObjectName,whereClause,strOrderByClause,offsetValue);
                    }
                }
                if(!detailTabData.containsKey(detailTab.aliasName)){
                    detailTabData.put(detailTab.aliasName,new List<sobject>());
                }
                detailTabData.get(detailTab.aliasName).addAll(sObjectList);             
            }
                
        }

        //Form the JSON Response for detail data set
        list<SVMXC.SFM_WrapperDef.SFM_DetailDataSet> detailDataSetList = new list<SVMXC.SFM_WrapperDef.SFM_DetailDataSet>();
        Boolean checkAllTabDataLoaded=true;
        for(String s : detailTabData.keySet()){
            SVMXC.SFM_WrapperDef.SFM_DetailDataSet detailDataSet = new SVMXC.SFM_WrapperDef.SFM_DetailDataSet();
            list<SVMXC.SFM_WrapperDef.SFM_PageDataSet> pageDataSetList= new list<SVMXC.SFM_WrapperDef.SFM_PageDataSet>();
            detailDataSet.aliasName = s;            
            list<Sobject> detailRecords = new list<Sobject>();
            if(detailTabData.get(s)!=null && detailTabData.get(s).size()>0){
                detailRecords.addAll(detailTabData.get(s));
            }
            if(detailTabData.get(s).size()==0 || detailTabData.get(s).size()< batchsize){
                detailDataSet.isAllRecordsLoaded = true;
            }else{
                detailDataSet.isAllRecordsLoaded = false;
                checkAllTabDataLoaded = false;
            }
            String strObjectNameForDetail='';//Stores Object Api Name for detail records list
            if(mapAliasNameRequest.get(s) != null && !mapAliasNameRequest.get(s).isAllRecordsLoaded){
                Integer offsetForNextData = 0;
                if(!String.isBlank(mapAliasNameRequest.get(s).offsetValue)){
                    offsetForNextData = Integer.valueOf(mapAliasNameRequest.get(s).offsetValue)+ batchsize;
                } 
                detailDataSet.offsetValue = String.valueOf(offsetForNextData);
                detailDataSet.objectApiName = mapAliasNameRequest.get(s).objectApiName;
                detailDataSet.fieldList = mapAliasNameRequest.get(s).fieldList;
                detailDataSet.whereClause = mapAliasNameRequest.get(s).whereClause;
                detailDataSet.orderByFields = mapAliasNameRequest.get(s).orderByFields;
                strObjectNameForDetail = mapAliasNameRequest.get(s).objectApiName;
            }
            List<String> setPageFieldApiName = new List<String>();//Stores list of all the fields queried for this detail record
            if(!String.isBlank(mapAliasNameRequest.get(s).fieldList)){
                setPageFieldApiName = mapAliasNameRequest.get(s).fieldList.split(',');
            }
            
            list<SVMXC__Page_Layout_Detail__c> detailFields = new list<SVMXC__Page_Layout_Detail__c>();//List of Page Layout Detail for each tab
            if(detailFieldMap.containsKey(s) && detailFieldMap.get(s) != null){
                detailFields = detailFieldMap.get(s);
            }
            
            
            //Form IdNAmMAp used in forming bubbleInfo
            map<String,String> IdNameMap = new map<String,String>();//this holds map of id,name of reference fields in the detail records
            
            if(detailRecords.size() > 0 && detailFields.size() > 0)
            {
                map<String,String> FieldObjMap = new map<String,String>();
                map<String,String> FieldNameFieldMap = new map<String,String>(); 
                map<String,String> FieldLookUpColumnMap = new map<String,String>(); 
                for(integer a = 0;a<detailFields.size();a++)
                {                       
                    if(detailFields[a].SVMXC__DataType__c != null && detailFields[a].SVMXC__DataType__c.touppercase() == 'REFERENCE' && detailFields[a].SVMXC__Field_API_Name__c != null && detailFields[a].SVMXC__Related_Object_Name__c != null && detailFields[a].SVMXC__Related_Object_Name_Field__c != null)
                    {  
                        FieldObjMap.put(detailFields[a].SVMXC__Field_API_Name__c,detailFields[a].SVMXC__Related_Object_Name__c);
                        FieldNameFieldMap.put(detailFields[a].SVMXC__Field_API_Name__c,detailFields[a].SVMXC__Related_Object_Name_Field__c);
                        if(detailFields[a].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != null && detailFields[a].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != detailFields[a].SVMXC__Related_Object_Name_Field__c)
                            FieldLookUpColumnMap.put(detailFields[a].SVMXC__Field_API_Name__c,detailFields[a].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c);
                    }  
                }
                system.debug('FieldLookUpColumnMap'+FieldLookUpColumnMap); 
                if(FieldObjMap.size() > 0 && FieldNameFieldMap.size() > 0)
                {
                    for(String fld : FieldObjMap.keyset())
                    {
                        set<String> ids = new set<String>();
                        for(Integer b = 0;b<detailRecords.size();b++)
                        {
                            if(detailRecords[b].get(fld) != null)
                                ids.add(String.valueof(detailRecords[b].get(fld)));
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
                system.debug('IdNameMap'+IdNameMap); 
            }
            for(Integer i=0;i<detailRecords.size();i++){
                SVMXC.SFM_WrapperDef.SFM_PageDataSet pageDataSet = new SVMXC.SFM_WrapperDef.SFM_PageDataSet();
                Sobject sobj = detailRecords[i];//data for Sobject info
                //Populate the Bubble Info
                list<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper> bubbleWrapList = new list<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper>();
                Set<String> setAllFieldsUsedInBubbleInfo = new Set<String>();
                for(Integer j = 0;j<detailFields.size();j++)
                {
                    //Added for not adding duplicate field in the bubbleinfo object - for the defect 043715
                    if(mapObjectNameAndListOfDupFieldsV2 != null && mapObjectNameAndListOfDupFieldsV2.size() > 0 && mapObjectNameAndListOfDupFieldsV2.containsKey(strObjectNameForDetail) && mapObjectNameAndListOfDupFieldsV2.get(strObjectNameForDetail).contains(detailFields[j].SVMXC__Field_API_Name__c)){
                        continue;
                    }
                    
                    SVMXC.SFM_WrapperDef.SFM_BubbleWrapper bubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper(null); 
                    bubbleWrapper.response = null;
                    bubbleWrapper.fieldapiname = detailFields[j].SVMXC__Field_API_Name__c;
                    String DefaultValue = String.valueof(detailRecords[i].get(detailFields[j].SVMXC__Field_API_Name__c));
                    
                    Schema.Describefieldresult f = null;
                    if(!(mapAllFieldDescribe.get(strObjectNameForDetail)).isEmpty() && (mapAllFieldDescribe.get(strObjectNameForDetail)).containsKey(detailFields[j].SVMXC__Field_API_Name__c)){
                        f = (mapAllFieldDescribe.get(strObjectNameForDetail)).get(detailFields[j].SVMXC__Field_API_Name__c).getDescribe();
                    }
                                        
                    if(detailFields[j].SVMXC__DataType__c.touppercase() == 'DATETIME' && f != null && f.isCalculated() && 
                    f.getType() == schema.Displaytype.DateTime) {
                        String dat1 = String.valueof(datetime.valueof(detailRecords[i].get(detailFields[j].SVMXC__Field_API_Name__c))); 
                        String dat2;
                        if(detailRecords[i].get(detailFields[j].SVMXC__Field_API_Name__c) != null)
                            dat2 = (datetime.valueof(detailRecords[i].get(detailFields[j].SVMXC__Field_API_Name__c))).format('yyyy-MM-dd HH:mm:ss');
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(dat1, dat2);
                        bubbleWrapper.fieldvalue = strmap;                                    
                    }else if(detailFields[j].SVMXC__Related_Object_Name__c != null && detailFields[j].SVMXC__DataType__c.touppercase() == 'REFERENCE')
                    {
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        strmap.key = DefaultValue;
                        if(IdNameMap.containskey(DefaultValue))
                            strmap.value = IdNameMap.get(DefaultValue);
                        bubbleWrapper.fieldvalue = strmap;
                    }
                    else if(f.isAccessible()) //BAC-4486/043861
                    {
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(DefaultValue,DefaultValue);
                        bubbleWrapper.fieldvalue = strmap;
                    } //BAC-4486/043861
                    
                    bubbleWrapList.add(bubbleWrapper);
                    
                    //-----Start----Added for the defect fix BAC-3884
                    /*if(detailFields[j].SVMXC__Field_Mapping__c != null && mapFieldMapIdListOfFieldsV2.size() > 0 && mapFieldMapIdListOfFieldsV2.containsKey(detailFields[j].SVMXC__Field_Mapping__c)){
                        List<String> setOfFields = mapFieldMapIdListOfFieldsV2.get(detailFields[j].SVMXC__Field_Mapping__c);
                        for(String strField : setOfFields){
                            if(!setAllFieldsUsedInBubbleInfo.contains(strField)){
                                String fieldValue = String.valueof(sobj.get(strField));
                                if(String.isEmpty(fieldValue) && !setPageFieldApiName.contains(strField)){
                                    SVMXC.SFM_WrapperDef.SFM_BubbleWrapper objBubbleWrapper = createBubbleInfoObject(strField, fieldValue, fieldValue);
                                    bubbleWrapList.add(objBubbleWrapper);
                                }
                            }
                            setAllFieldsUsedInBubbleInfo.add(strField);
                        }
                    }*/
                    //-----End------Added for the defect fix BAC-3884
                    
                    pageDataSet.bubbleInfo = bubbleWrapList;
                }               
                /*
                Set<String> setAllFieldUsedByFieldSet = new Set<String>();
                if(mapObjectNameFieldListSetV2.size() > 0 && String.isNotBlank(strObjectNameForDetail) && mapObjectNameFieldListSetV2.containsKey(strObjectNameForDetail)){
                    for(String strField : mapObjectNameFieldListSetV2.get(strObjectNameForDetail)){

                        //Added for not adding duplicate field in the bubbleinfo object - for the defect 043715
                        if(mapObjectNameAndListOfDupFieldsV2 != null && mapObjectNameAndListOfDupFieldsV2.size() > 0 && mapObjectNameAndListOfDupFieldsV2.containsKey(strObjectNameForDetail) && mapObjectNameAndListOfDupFieldsV2.get(strObjectNameForDetail).contains(strField)){
                            continue;
                        }

                        if(!setAllFieldsUsedInBubbleInfo.contains(strField)){
                            String fieldValue = String.valueof(sobj.get(strField));
                            if(String.isEmpty(fieldValue) && !setPageFieldApiName.contains(strField)){
                                SVMXC.SFM_WrapperDef.SFM_BubbleWrapper objBubbleWrapper = createBubbleInfoObject(strField, fieldValue, fieldValue);
                                if(pageDataSet.bubbleInfo != null){
                                    pageDataSet.bubbleInfo.add(objBubbleWrapper);
                                }
                            }
                        }
                        setAllFieldUsedByFieldSet.add(strField);
                    }
                }
                if(mapObjectNameWithDVFields.size() > 0 && String.isNotBlank(strObjectNameForDetail) && mapObjectNameWithDVFields.containsKey(strObjectNameForDetail)){
                    Set<String> setOfFieldUsedInDVR = mapObjectNameWithDVFields.get(strObjectNameForDetail);
                    for(String strField : setOfFieldUsedInDVR){

                        //Added for not adding duplicate field in the bubbleinfo object - for the defect 043715
                        if(mapObjectNameAndListOfDupFieldsV2 != null && mapObjectNameAndListOfDupFieldsV2.size() > 0 && mapObjectNameAndListOfDupFieldsV2.containsKey(strObjectNameForDetail) && mapObjectNameAndListOfDupFieldsV2.get(strObjectNameForDetail).contains(strField)){
                            continue;
                        }

                        if(!setAllFieldsUsedInBubbleInfo.contains(strField) && !setAllFieldUsedByFieldSet.contains(strField)){
                            String fieldValue = String.valueof(sobj.get(strField));
                            if(String.isEmpty(fieldValue) && !setPageFieldApiName.contains(strField)){
                                SVMXC.SFM_WrapperDef.SFM_BubbleWrapper objBubbleWrapper = createBubbleInfoObject(strField, fieldValue, fieldValue);
                                if(pageDataSet.bubbleInfo != null){
                                    pageDataSet.bubbleInfo.add(objBubbleWrapper);
                                }
                            }
                        }
                    }
                }*/
                pageDataSet.sobjectInfo = sobj;             
                pageDataSetList.add(pageDataSet);
            }
            
            detailDataSet.pageDataSet = pageDataSetList;
            detailDataSetList.add(detailDataSet);
        }       
        
        SVMXC.SFM_WrapperDef.SFM_PageDataV2 pageData = new SVMXC.SFM_WrapperDef.SFM_PageDataV2();
        if(checkAllTabDataLoaded){
            pageData.isAllTabDataLoaded=true;
        }else{
            pageData.isAllTabDataLoaded=false;
        }
        pageData.detailDataSet = detailDataSetList;
        pageData.bubbleInfoCollections = bubbleInfoCollectionsList;
        return pageData;
    }
    
    //Added by Nidhi as part of Lazy Loading BAC-4680
    public list<Sobject> getMergeResultSet(List<String> allFieldList, String ObjectName,String whereClause,String strOrderByClause, String offsetValue) {
        SVMXC.COMM_Utils_V2 commutils = new SVMXC.COMM_Utils_V2();
        list<Sobject> SobjectList = new list<Sobject>();
        Map<Id,Sobject> mapIdRecord1 = new Map<Id,Sobject>();
        Map<Id,Sobject> mapIdRecord2 = new Map<Id,Sobject>();
        //List<String> lstFieldList = new List<String>();//first half of the field list
        List<String> secondFieldList = new List<String>();//second half of the field list
        
        
        Integer listHalfSize = 0;
        if(allFieldList.size() > 0){
            listHalfSize = allFieldList.size()/2;
        }        
        
        for(Integer i=0; i<listHalfSize; i++){
            secondFieldList.add(allFieldList[i]);
            allFieldList.remove(i);
        }
        allFieldList = commutils.checkDuplicateFields(allFieldList, ObjectName); //Added for the defect 043715
        secondFieldList = commutils.checkDuplicateFields(secondFieldList, ObjectName); //Added for the defect 043715
        
        String firstFieldString = commutils.SVMX_getFieldNamesFromList(allFieldList);
        String secondFieldString = commutils.SVMX_getFieldNamesFromList(secondFieldList);
        String Query1 = 'select ' +firstFieldString+ ' from ' + ObjectName;
        String Query2 = 'select ' +secondFieldString+ ' from ' + ObjectName;
        
        if(!String.isBlank(whereClause)){
            Query1 += ' Where '+whereClause;
            Query2 += ' Where '+whereClause;
        }
        
        if(!String.isBlank(strOrderByClause)){
            Query1 += ' Order by '+strOrderByClause;
            Query2 += ' Order by '+strOrderByClause;
        }
        
        if(!String.isBlank(String.valueOf(batchsize))){
            Query1 += ' Limit '+String.valueOf(batchsize);
            Query2 += ' Limit '+String.valueOf(batchsize);
        }
        
        if(!String.isBlank(offsetValue)){
            Query1 += ' OFFSET '+offsetValue;
            Query2 += ' OFFSET '+offsetValue;
        }
        System.debug('Query1: '+Query1);
        System.debug('Query2: '+Query2);
        
        if(allFieldList.size() > 0){
            mapIdRecord1 = new Map<Id,Sobject>(Database.query(Query1));
            System.debug('FirstMapRecord: '+mapIdRecord1);
        }
        
        if(secondFieldList.size() > 0){
            mapIdRecord2 = new Map<Id,Sobject>(Database.query(Query2));
            System.debug('SecondMapRecord: '+mapIdRecord2);
        }

        for(Id idd: mapIdRecord1.keyset()){
            Map<String,Object> mapFieldAndValueOfRecord1 = new Map<String,object>(mapIdRecord1.get(idd).getPopulatedFieldsAsMap());
            
            if(mapIdRecord2.containsKey(idd) && mapIdRecord2.get(idd) != null){
                Map<String,Object> mapFieldAndValueOfRecord2 = new Map<String,object>(mapIdRecord2.get(idd).getPopulatedFieldsAsMap());
                for(String key : mapFieldAndValueOfRecord2.keyset()){
                    mapFieldAndValueOfRecord1.put(key, mapFieldAndValueOfRecord2.get(key));
                }                
            }            
            type stype= type.forName(ObjectName);
            Sobject resultSobject = (Sobject)JSON.deserialize(JSON.serialize(mapFieldAndValueOfRecord1), stype);
            SobjectList.add(resultSobject);
            System.debug('ResultSobject: '+resultSobject);
        }
        
        System.debug('FullSobjectList: '+SobjectList);
        return SobjectList;
    }
    
    //Method to return BubbleInfo class object
    SVMXC.SFM_WrapperDef.SFM_BubbleWrapper createBubbleInfoObject(String fieldApiName, String key, String value){
        SVMXC.SFM_WrapperDef.SFM_BubbleWrapper objBubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper(null); //Added null for calling parameter constructor for the story BAC-4410
        objBubbleWrapper.response = null; //Added for fixing defect 043843 and for story BAC-4410
        objBubbleWrapper.fieldapiname = fieldApiName;
        objBubbleWrapper.fieldvalue.key = key;
        objBubbleWrapper.fieldvalue.value = value;
        return objBubbleWrapper;
    }
}