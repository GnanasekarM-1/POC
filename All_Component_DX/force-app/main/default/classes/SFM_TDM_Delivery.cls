/* Security Scanned */
public with sharing class SFM_TDM_Delivery 
{
    public  Boolean isExpressionQualified; //#optiChange
    //-------------------NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    //---------------------------------
    public class SVMXException extends Exception {}
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    SVMXC.SFM_parseExpression ExpParssig = new SVMXC.SFM_parseExpression();
    
    public String partnerServerURL= 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/';
    public String strAPIVersion = '19';
    // public Map<String, String> mapGlobalSettings = commSettings.SVMX_getSettingList('GLOB001'); 
    // public Map<String, String> mapSFMDeliverySettings = commSettings.SVMX_getSettingList('SFM002');
    List<String> lstSettingIds = new List<String>{'GLOB001_GBL017', 'SFM002_SET002', 'SFM002_SET00101'};
    Map<String,String> mapAllSettings = commSettings.SVMX_getGlobalSettingList(lstSettingIds);
    
    public map<String,String> PrifixMap = new map<String,String>();
    public SVMXC__ServiceMax_Processes__c Process = new SVMXC__ServiceMax_Processes__c();
    public String RecordID = '';
    public String PageID =  '';
    public String ProcessID = '';
    public String returnURL= '';
    public String TargetManager = '';
    public String ProcessNodeObj = '';
    public String executionMode = '';
    public String processTitle = '';
    public String nameField = '';
    public String nameFieldLabel = '';
    public String hdrTargetRecId = '';
    public Boolean IsError = false;
    public Boolean IsProcessExsists = true;
    public Boolean IsIdExsists = true;
    public Boolean IsDuplicateProcess = false;
    public Boolean isSFMProcess = false;
    public Boolean mode = false;
    public Boolean HdrMsg = false;
    public String ErrorMsg = '';    
    public String duplicateProcessMsg = system.Label.SFM002_TAG091;
    public String defaultSearchOperator = 'CONTAINS';
    String GMapAPI;
    String clientId;
    String nxtStepID = '';
    public Map<String, String> PageHeaderMap  = new Map<String, String>();
    public String strBaseURL {set; get;} //Added for the story BAC-3586
    public SFM_TDM_Delivery ()
    {
        strBaseURL = System.URL.getSalesforceBaseURL().toExternalForm(); //Added for the story BAC-3586
        /*if(mapSFMDeliverySettings.containsKey('SET002') && mapSFMDeliverySettings.get('SET002') != null)
            strAPIVersion = mapSFMDeliverySettings.get('SET002');*/
        if(mapAllSettings.containsKey('SFM002_SET002') && mapAllSettings.get('SFM002_SET002') != null)
            strAPIVersion = mapAllSettings.get('SFM002_SET002');
        partnerServerURL += strAPIVersion+'/'+Userinfo.getOrganizationId();
        /*if(mapGlobalSettings.containskey('GBL017'))
            defaultSearchOperator = mapGlobalSettings.get('GBL017').touppercase();*/
        if(mapAllSettings.containskey('GLOB001_GBL017'))
            defaultSearchOperator = mapAllSettings.get('GLOB001_GBL017').touppercase();
        List<RecordType> RecordTypes = new List<RecordType>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
       
        PageHeaderMap = ApexPages.currentPage().getParameters();
        
        if(PageHeaderMap.size()>0)
        {
            if(PageHeaderMap.containskey('SVMX_recordId'))
                RecordID =  getParameterValue(PageHeaderMap.get('SVMX_recordId'));   
            if(PageHeaderMap.containskey('SVMX_pageID'))
                PageID =  getParameterValue(PageHeaderMap.get('SVMX_pageID')); 
            if(PageHeaderMap.containskey('SVMX_ProcessId'))
                ProcessID=  getParameterValue(PageHeaderMap.get('SVMX_ProcessId'));  
            if(PageHeaderMap.containskey('SVMX_retURL'))
                returnURL=  getParameterValue(PageHeaderMap.get('SVMX_retURL'));  
            if(PageHeaderMap.containskey('SVMX_Execution_Mode'))
                executionMode = getParameterValue(PageHeaderMap.get('SVMX_Execution_Mode'));  
            if(PageHeaderMap.containskey('SVMX_NxtStepID'))
                nxtStepID =  getParameterValue(PageHeaderMap.get('SVMX_NxtStepID'));
            if(PageHeaderMap.containskey('SVMX_SearchOperator'))
                defaultSearchOperator =  getParameterValue(PageHeaderMap.get('SVMX_SearchOperator'));    
        }
        
        
        isExpressionQualified = ExpressionQulification(); // #optiChange
        System.debug('isExpressionQualified##'+isExpressionQualified);
        
        if(! isExpressionQualified)
            return;
        //Get the Process Title first
        getFieldNameAndLabel(RecordID);
        if(ProcessID != null && ProcessID.length() > 0)
        {
            list<SVMXC__ServiceMax_Processes__c> ProList = new list<SVMXC__ServiceMax_Processes__c>(); 
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            ProList = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c where RecordType.DeveloperName = 'Target_Manager' and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)];
            system.debug('ProList'+ProList);
            if(ProList.size() > 0)
            {
                Process = ProList[0];
                strProcessType = Process.SVMXC__Purpose__c;
                if(Process != null && Process.SVMXC__Name__c != null)
                    processTitle =  Process.SVMXC__Name__c;
                if(Process != null && Process.SVMXC__Purpose__c.touppercase() != 'STANDALONE CREATE' && nameFieldLabel != null && nameFieldLabel.length() > 0 && nameField != null && nameField.length() > 0 && RecordID != null && RecordID.length() > 0 && PrifixMap.Containskey(RecordID.substring(0,3))) 
                {
                    String Query = 'Select '+NameField+ ' From ' +PrifixMap.get(String.escapeSingleQuotes(RecordID).substring(0,3))+' Where Id = \''+String.escapeSingleQuotes(RecordID)+'\''; 
                    system.debug('Query'+Query);
                    Sobject Sobj = Database.query(Query);
                    if(Sobj != null)
                        processTitle += ' (' +nameFieldLabel+ ': ' + String.valueof(Sobj.get(nameField)) + ')';
                }
            }
        }
    }
    public String getMySessionId() {return UserInfo.getSessionId();}
    public String getRecordID() {return RecordID;}
    public String getProcessID() {return ProcessID;}
    public String getnxtStepID() {return nxtStepID;}
    public String getPageID() {return PageID;}
    public String getreturnURL() {return returnURL;}
    public String getHeight() {return '1000px';}
    public Boolean getIsIdExsists(){return IsIdExsists;}
    public Boolean getIsProcessExsists(){return IsProcessExsists;}
    public Boolean getIsError(){return IsError;}
    public String getErrorMsg(){return ErrorMsg;}
    public String getProcessErrMsg(){return system.Label.SFM002_TAG001;}
    public String getIdErrMsg(){return system.Label.SFM002_TAG046;}
    public Boolean getIsDuplicateProcess(){return IsDuplicateProcess;}
    public String getduplicateProcessMsg(){return duplicateProcessMsg+' '+ProcessID;}
    //public String getLineLimit(){return Linelimit;}
    public String getloadingTag(){return system.label.SFM002_TAG051;}
    public Boolean getisSFMProcess(){return isSFMProcess;}
    public String getProTypeErr(){return system.Label.SFM002_TAG054;}
    public String getProcessTitle(){return processTitle;}
    public String getdefaultSearchOperator(){return defaultSearchOperator;}
    public Boolean getHdrMsg(){return HdrMsg;}
    public String getpartnerServerURL(){ system.debug('partnerServerURL'+partnerServerURL);return partnerServerURL;}
    public COMM_SVMXC_Utils2 objCls = new COMM_SVMXC_Utils2();
    
    public boolean getMode() 
    {
        if(executionMode.toUpperCase() == 'SVMXAUTO')
            mode = true;
        system.debug('mode'+mode);
        return mode;
    }
    public PageReference DoCancel()
    {
        String strNextURL = objCls.GetCommunityPrefix('/'+RecordID);
        pageReference PageRef = new pageReference(strNextURL);
        PageRef.setRedirect(true);
        system.debug('Called'+PageRef);
        return PageRef;
    }
    public Boolean ExpressionQulification()
    {
        try
        {
            if(String.isNotBlank(ProcessId))//&& RecordID != null && RecordID.length() > 0 //#optiChange
            {
                
                list<SVMXC__ServiceMax_Processes__c> ProList = new list<SVMXC__ServiceMax_Processes__c>(); 
                SVMXC__ServiceMax_Processes__c Process = new SVMXC__ServiceMax_Processes__c();
                list<SVMXC__ServiceMax_Processes__c> ProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
                String HdrExpression = '';
                String HeaderObject = '';
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                ProList = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c where RecordType.DeveloperName = 'Target_Manager' and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)];
                system.debug(LoggingLevel.WARN,'ProList'+ProList);
                if(ProList.size() > 1){
                    IsDuplicateProcess = true;
                    return false;
                }
                else if(ProList.size() == 1)
                {
                    Process = ProList[0];
                    if(Process.SVMXC__Purpose__c.touppercase() == 'STANDALONE CREATE' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL' || Process.SVMXC__Purpose__c.touppercase() == 'STANDALONE EDIT' || Process.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD'){
                        isSFMProcess = true;
                    }else
                        return false;
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    ProcessNodeObjects = [Select  SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c,SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__c,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From  SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: Process.id and RecordType.DeveloperName = 'Process_Node_Objects'];
                   // if(ProcessNodeObjects.size() > 0 ) // #optiChange
                 //   { 
                        for(SVMXC__ServiceMax_Processes__c Pro : ProcessNodeObjects)
                        {
                                
                            if(Pro.SVMXC__Type__c.touppercase() == 'TARGET' && Pro.SVMXC__Submodule__c != null)
                                    HdrExpression = Pro.SVMXC__Submodule__c;  
                            if(Process.SVMXC__Purpose__c == 'STANDALONE EDIT')
                            {
                                if(Pro.SVMXC__Type__c.touppercase() == 'TARGET')
                                    HeaderObject = Pro.SVMXC__Source_Object_Name__c;
                            }
                            else
                            {
                                if(Pro.SVMXC__Type__c.touppercase() == 'SOURCE')
                                    HeaderObject = Pro.SVMXC__Source_Object_Name__c;
                            }                       
                        }
                  //  } // #optiChange
                    system.debug(LoggingLevel.WARN,'HdrExpression'+HdrExpression);
                    system.debug(LoggingLevel.WARN,'HeaderObject'+HeaderObject);
                    if(String.isNotBlank(HeaderObject) && String.isNotBlank(HdrExpression))
                    {
                        //first get the Error message if exsists
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        SVMXC__ServiceMax_Processes__c exp = [select id,SVMXC__Parent_Error_Msg__c from SVMXC__ServiceMax_Processes__c where id =: HdrExpression];
                        if(exp != null && exp.SVMXC__Parent_Error_Msg__c != null)
                        {
                            ErrorMsg = exp.SVMXC__Parent_Error_Msg__c;
                        }
                        else
                        {
                            ErrorMsg = system.Label.SFM001_TAG158;
                        }
                        system.debug(LoggingLevel.WARN,'Enter in Header Expression Qualification..');
                        list<Sobject> HeaderSobjList = new list<Sobject>();
                        String strQuery = 'Select Id From '+HeaderObject+' Where Id =: RecordID';
                        HeaderSobjList = database.query(strQuery);
                        system.debug(LoggingLevel.WARN,'HeaderSobjList'+HeaderSobjList);
                        SVMXC__ServiceMax_Processes__c Expression = new SVMXC__ServiceMax_Processes__c();
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        Expression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :HdrExpression];
                        if(HeaderSobjList.size() > 0 && Expression != null && Expression.SVMXC__Source_Object_Name__c != null && Expression.SVMXC__Parent_Object_Criteria__c != null) 
                        {
                            list<Sobject> SobjList = new list<Sobject>();
                            SobjList = ExpParssig.SFM_ParseExpression1(HeaderSobjList,null,Expression.SVMXC__Source_Object_Name__c,Expression.SVMXC__Parent_Object_Criteria__c,'Id');
                            system.debug(LoggingLevel.WARN,'SobjList'+SobjList); 
                            if(SobjList.size() == 0){
                                IsError = true; 
                              return false;    
                            }                           
                        }
                    }
                
                }
                else
                {
                  IsProcessExsists = false;
                  return false;
                }
            }
        }
        catch (DmlException ex)
        {
            throw new SVMXException(ex.getDmlMessage(0));
            return false;
        }
        catch (Exception ex)
        {
            throw new SVMXException(ex.getmessage());
            return false;
        }    
        system.debug(LoggingLevel.WARN,'isSFMProcess'+isSFMProcess);
        system.debug(LoggingLevel.WARN,'IsDuplicateProcess'+IsDuplicateProcess);
        return true;
        
    }
   
    private void getFieldNameAndLabel(String recordId){
        if(recordId.startsWith('001')){
            nameField = 'Name';
            nameFieldLabel = Account.AccountNumber.getDescribe().getlabel();
            return;
        }
        
        Id myId = Id.valueOf(recordId);
        String sObjName = myId.getSObjectType().getDescribe().getName();        
        FieldDefinition fd = [SELECT MasterLabel, QualifiedApiName
                              FROM FieldDefinition
                              WHERE EntityDefinition.QualifiedApiName =: sObjName
                              AND IsNameField = TRUE LIMIT 1];
        nameField = fd.QualifiedApiName;
        nameFieldLabel = fd.MasterLabel;
        
    }
    
    public  String getParameterValue(String parameterValue){        
        if(parameterValue != null && parameterValue.length() > 0){
            parameterValue = String.escapeSingleQuotes(parameterValue);
        }
        return parameterValue;
    }
    
    // New Code for Split
    public SFM_WrapperDef.SFM_TargetRecord targetRecord; //#optiChangeNew
    //Sourceupdatesplit
    public String strProcessType = '';
    public static boolean isBackgroundSfmInSplitMode = false;
    public static boolean isHdrSourceUpdate = false;
    public static sourceUpdateDef headerSourceUpdateProperties;
    public sourceUpdateDef sourceUpdateProperties;
    public boolean isHeaderSourceUpdate = false;
    public String nextStepActionURL;
    public String errorMessage = '';
    public Map<String, Map<String, String>> AllsvmxSettingList = new Map<String, Map<String, String>>();

    public class sourceUpdateDef{
        public String SFMId{get; set;}
        public Sobject TargetSobject{get; set;}
        public String SourceUpdateRecId{get; set;}
        public String ObjName{get; set;}
        public map<String,map<String,Schema.SObjectField>> AllFieldDescribe{get; set;}

        public sourceUpdateDef(String SFMId, Sobject TargetSobject, String SourceUpdateRecId, String ObjName, map<String,map<String,Schema.SObjectField>> AllFieldDescribe){
            this.SFMId = SFMId;
            this.TargetSobject = TargetSobject;
            this.SourceUpdateRecId = SourceUpdateRecId;
            this.ObjName = ObjName;
            this.AllFieldDescribe = AllFieldDescribe;
        }
    }

    public void getTargetRecord()
    {
        if(Process != null && Process.SVMXC__Dispatch_Process_Status__c != null && Process.SVMXC__Dispatch_Process_Status__c.touppercase() != 'COMPLETE')
        {
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,system.Label.SFM002_TAG056));
            //return null;//#newChange
            return;
        }
        System.debug(LoggingLevel.WARN,'system goes here 1 : ExpressionQulification() '+isExpressionQualified);
        
        if(!isExpressionQualified){
            HdrMsg = true;
            return;
            //return null;//#newChange
        }
        
        
        System.debug(LoggingLevel.WARN,'system goes here 2 : executionMode.toUpperCase() '+executionMode.toUpperCase());
        System.debug('executionMode##'+executionMode);
        if(executionMode.toUpperCase() == 'SVMXAUTO')
        {   
          
            //Now Create the INTF_Request and run the INTF_Tansactin Engine..
            SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
            SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
            list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            if(String.isNotBlank(RecordID)) // #optiChange
            {
                SVMXC.INTF_WebServicesDef.INTF_StringMap strmap1 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                strmap1.key = 'RECORDID';
                strmap1.value = RecordID;
                lstStringMap.add(strmap1);
            } 
            if(String.isNotBlank(ProcessID)) // #optiChange
            {   
                SVMXC.INTF_WebServicesDef.INTF_StringMap strmap2 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                strmap2.key = 'TDMID';
                strmap2.value = ProcessID;
                lstStringMap.add(strmap2);
            }
            request.StringMap = lstStringMap;
            system.debug(LoggingLevel.WARN,'request'+request);
            SVMXC.INTF_SFMEngine RunEngine = new SVMXC.INTF_SFMEngine(); //#optiChange
            
            //#Moving from SFM_ParseProcess as its good to set this variable from the Background SFM code
            SFMDeliveryServiceImpl.setIsQueryOptimizerEnabled(); //#newChangeOptiBGSFM

            this.targetRecord = INTF_SFMEngine.getTargetRecord(request);
            return;
           // return this.targetRecord; //#newChange due to apex action method should return void or pagereferecnce
            
            
        }
        //return null;//#newChange
        
    }
    
    public void saveTargetRecord(){
        if(mapAllSettings != null && mapAllSettings.containsKey('SFM002_SET00101') && mapAllSettings.get('SFM002_SET00101') != null && strProcessType.equalsIgnoreCase('SOURCE TO TARGET ALL')){ 
            isBackgroundSfmInSplitMode = Boolean.valueOf(mapAllSettings.get('SFM002_SET00101'));
        }
        System.debug(Logginglevel.INFO,'SFM_TDM_Delivery.isBackgroundSfmInSplitMode: '+isBackgroundSfmInSplitMode);
        SVMXC.INTF_SFMEngine RunEngine = new SVMXC.INTF_SFMEngine(); 
        SFM_WrapperDef.SFM_TargetRecord request = targetRecord;
        SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
        response = RunEngine.saveTargetRecord(request); 
        system.debug(LoggingLevel.WARN,'response'+response);
        if(response != null && response.success == true)
        {
            //Sourceupdatesplit
            if(SFM_TDM_Delivery.isHdrSourceUpdate && SFM_TDM_Delivery.headerSourceUpdateProperties != null && !String.isBlank(SFM_TDM_Delivery.headerSourceUpdateProperties.SFMId)){
                //Header source update exist for this process
                this.isHeaderSourceUpdate = true;
                this.sourceUpdateProperties = SFM_TDM_Delivery.headerSourceUpdateProperties;
                if (SVMX_Constants.AllsvmxSettingList != null && !SVMX_Constants.AllsvmxSettingList.isEmpty()) {
                    this.AllsvmxSettingList = SVMX_Constants.AllsvmxSettingList;
                }
            }

            list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstRspnsStringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            lstRspnsStringMap = response.StringMap;
            if(lstRspnsStringMap.size() > 0)
            {
                for(Integer i = 0;i<lstRspnsStringMap.size();i++)
                {
                    if(lstRspnsStringMap[i].key.touppercase() == 'HEADERTARGETRECID')
                        hdrTargetRecId = lstRspnsStringMap[i].value;
                }
            }
            System.debug('nxtStepID##'+nxtStepID+'##RecordID'+RecordID);
            if(!String.isBlank(nxtStepID) &&  !String.isBlank(RecordID)) // #optiChange
            {
                SVMXC.INTF_WebServicesDef.INTF_SFMResponse responseForURL = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
                SVMXC.INTF_WebServicesDef.INTF_SFMRequest requestForURL = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
                list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
                SVMXC.INTF_WebServicesDef.SVMXMap mapProcessId = new SVMXC.INTF_WebServicesDef.SVMXMap();
                SVMXC.INTF_WebServicesDef.SVMXMap mapRecordId = new SVMXC.INTF_WebServicesDef.SVMXMap();
                mapProcessId.key = 'SVMX_processId';
                mapProcessId.value = nxtStepID; 
                mapRecordId.key = 'SVMX_recordId';
                mapRecordId.value = RecordID;
                lstSVMXMap.add(mapProcessId);
                lstSVMXMap.add(mapRecordId);
                requestForURL.valueMap = lstSVMXMap;
                System.debug('responseForURL: '+responseForURL);
                responseForURL = SVMXC.INTF_WebServicesDef.INTF_GetNextStepURL_WS(requestForURL);
                
                if(responseForURL != null && responseForURL.success)
                {
                    String url = responseForURL.message;
                    if(url != null && url.length() > 3 && url.substring(0,3) == '../')
                        url = url.substring(2);
                    url = objCls.GetCommunityPrefix(url);
                    system.debug(LoggingLevel.WARN,'url'+url);
                    nextStepActionURL = url;
                    /*
                    pageReference PageRef = new pageReference(url);
                    PageRef.setRedirect(true);
                    return PageRef;*/
                } 
            }
            else
            { 
                String strNextURL = objCls.GetCommunityPrefix('/'+hdrTargetRecId);
                System.debug('strNextURL: '+strNextURL);
                nextStepActionURL = strNextURL;
                /*pageReference PageRef = new pageReference(strNextURL);
                PageRef.setRedirect(true);
                return PageRef; */
            }    
        }
        else if(response != null && response.success == false)
        {
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,response.message));
            errorMessage = response.message;
            //return null;
        }
        //return null;
    }

    public void doHeaderSourceObjectUpdate(){
        system.debug('SFM_TDM_Delivery.sourceUpdateProperties: ' + sourceUpdateProperties);
        SVMXC.SFM_WrapperDef.SFM_Response hdrSrcUpdRes = new SVMXC.SFM_WrapperDef.SFM_Response();
        SFM_SaveTargetRecords clsSourceUpdate = new SFM_SaveTargetRecords();
        hdrSrcUpdRes = clsSourceUpdate.DoHeaderSourceObjectUpdate(sourceUpdateProperties.SFMId,sourceUpdateProperties.TargetSobject,sourceUpdateProperties.SourceUpdateRecId,sourceUpdateProperties.ObjName,null,sourceUpdateProperties.AllFieldDescribe);
        if(! hdrSrcUpdRes.success){
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,hdrSrcUpdRes.message));
            errorMessage = hdrSrcUpdRes.message;
        }
    }

    public pageReference postSaveAction(){
        //If error occured on save
        if(HdrMsg)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, errorMessage));
            return null;
        }
        if(isHeaderSourceUpdate){
            if (this.AllsvmxSettingList != null && !this.AllsvmxSettingList.isEmpty()) {
                SVMX_Constants.AllsvmxSettingList = this.AllsvmxSettingList;
            }
            doHeaderSourceObjectUpdate();
        }
        //If error occured on source update
        if(HdrMsg)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, errorMessage));
            return null;
        }
        else{
            pageReference PageRef = new pageReference(nextStepActionURL);
            PageRef.setRedirect(true);
            return PageRef;
        }
    }
}