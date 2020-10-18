public with sharing class CONF_PushNotifications
{
    public SVMXC__ServiceMax_Config_Data__c selectedNotification {get;set;}
    
    public List<selectOption> lstOfSFMObjects {get;set;}
    public List<selectOption> lstAlertTypes {get;set;}
    public List<selectOption> lstFilters {get;set;}
    public List<selectOption> lstOfSchedule {get;set;}
    public List<selectOption> lstOfNotifyStyle {get;set;}
    public List<SelectOption> lstOfFields {get;set;}
    public List<selectOption> lstOfOperators {get;set;}
    public List<selectOption> lstOfAvailableRecipients {get;set;}
    public List<selectOption> lstOfSelectedRecipients {get;set;}
    public List<selectOption> fldLst {get;set;}
    
    public List<String> selectedAvailableRecipients {get;set;}
    public List<String> selectedRecipients {get;set;}
    public set<String> existingRecipients {get;set;}
    
    public String selectedObject{get;set;}
    public String selectedAlertType{get;set;}
    public String selectedFilter{get;set;}
    public String addRecipientsEmailIds{get;set;}
    public String emailSubject{get;set;}
    public String emailText{get;set;}
    public String selectedSchedule{get;set;}
    public String selectedStyle{get;set;}
    public String notificationName{get;set;}
    public boolean isActive{get;set;}
    public string mode{get;set;}
    public string delIndex{get;set;}
    public string selectedFieldForText{get;set;}
    
    public boolean isObjSelected {get;set;}
    public boolean isPgMsg {get;set;}
    public boolean isShowExp {get;set;}
    public boolean isEditFilter {get;set;}
    public boolean displayFldLstPopup {get;set;}
    
    public Integer ExpDetailSize = 0;
    public String selectedConfig{get;set;}
    public boolean showExpression{get;set;}
    Set<String> setAccessibleObjs = new Set<String>();
    public Set<String> setSFMObjects = new Set<String>();
    
    public List<selectOption> ListOfConfiguredNotifications = new List<selectOption>();
    public List<SelectOption> getListOfConfiguredNotifications(){return ListOfConfiguredNotifications;}
    
    public Map<String, String> mapObjAPINameToLabel = new Map<String, String>();
    public Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    public SFM_WrapperDef.SFM_Expression ExpToShow = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpToShow(){return this.ExpToShow;}
    
    public Integer getExpDetailSize(){ return ExpDetailSize;}
    
    //RecordType RTMobileConfig = new RecordType();
    
    public CONF_PushNotifications()
    {
        getDefaultValues();
        system.debug(LoggingLevel.WARN, 'selectedAlertType = ' + selectedAlertType);
        string notificationId = ApexPages.currentPage().getParameters().get('SVMX_RecordId');
        if(notificationId == null)
            mode = 'new';
        else
        {
            mode = 'edit';
            selectedNotification = [select id, SVMXC__Dispatch_Process__c, SVMXC__Object_Name__c, SVMXC__Display_Type__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__Internal_Value__c, SVMXC__Parameter_Name__c, SVMXC__Parameter_Value__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Display_Value__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c from SVMXC__ServiceMax_Config_Data__c where Id =: notificationId];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(selectedNotification == null)
            {
                mode = 'new';
                selectedNotification = new SVMXC__ServiceMax_Config_Data__c();
            }
            else
            {
                selectedObject = selectedNotification.SVMXC__Object_Name__c;
                selectedAlertType = selectedNotification.SVMXC__Display_Value__c;
                selectedFilter = selectedNotification.SVMXC__Dispatch_Process__c;
                addRecipientsEmailIds = selectedNotification.SVMXC__Profile__c;
                emailSubject = selectedNotification.SVMXC__Internal_Value__c;
                emailText = selectedNotification.SVMXC__Description__c;
                selectedSchedule = selectedNotification.SVMXC__Parameter_Name__c;
                selectedStyle = selectedNotification.SVMXC__Parameter_Value__c;
                notificationName = selectedNotification.SVMXC__Profile_Name__c;
                isActive = selectedNotification.SVMXC__Active__c;
                String strFields = selectedNotification.SVMXC__Lookup_Field_API_Name__c;
                system.debug(LoggingLevel.WARN, 'strFields = ' + strFields);
                if(strFields != null && strFields != '')
                {
                    existingRecipients.addAll(strFields.split(','));
                }
                system.debug(LoggingLevel.WARN, 'existingRecipients = ' + existingRecipients + '; selectedObject = ' + selectedObject);
                isObjSelected = true;
                prepareListOfFilters(selectedObject);
                prepareRecipientsList(selectedObject);
                editFilter();
            }
        }
        
        map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        for(String objName : allObjs.keyset())
        {
            try
            {
                Schema.DescribeSObjectResult objDesc = allObjs.get(objName).getDescribe();
                setAccessibleObjs.add(objDesc.getName().toLowerCase());
                mapObjAPINameToLabel.put(objDesc.getName(), objDesc.getLabel());
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception = ' + ex.getMessage());
            }
        }
        setSFMObjects = getSFMObjects(INTF_getAllAllowedProcessed());
        getlstOfSFMObjects();
    }
    
    public void onSelectObject()
    {
        existingRecipients = new set<string>();
        selectedRecipients = new List<string>();
        selectedAvailableRecipients = new List<string>();
        lstOfAvailableRecipients = new List<selectOption>();
        lstOfSelectedRecipients = new List<selectOption>();
        system.debug(LoggingLevel.WARN, 'selectedObject = ' + selectedObject + '; mode = ' + mode);
        if(mode == 'edit' && selectedObject != null && selectedObject.length() > 0 && selectedObject != '--None--')
        {
            isObjSelected = true;
            emailText = '';
            emailSubject = '';
            selectedStyle = '';
            selectedSchedule = '';
            selectedAlertType = '';
            addRecipientsEmailIds = '';
            prepareListOfFilters(selectedObject);
            ExpToShow = new SFM_WrapperDef.SFM_Expression();
            prepareRecipientsList(selectedObject);
        }
        else if(mode == 'edit' && (selectedObject == null || selectedObject.length() == 0 || selectedObject == '--None--'))
        {
            isObjSelected = false;
            emailText = '';
            emailSubject = '';
            selectedStyle = '';
            selectedSchedule = '';
            selectedAlertType = '';
            addRecipientsEmailIds = '';
            selectedFilter = '--None--';
            ExpToShow = new SFM_WrapperDef.SFM_Expression();
        }
        else
        {
            system.debug(LoggingLevel.WARN, 'selectedObject = ' + selectedObject);
            if(selectedObject == null || selectedObject.length() == 0 || selectedObject == '--None--')
            {
                fldLst = new List<selectOption>();
                isObjSelected = false;
                return;
            }
            
            isObjSelected = true;
            prepareListOfFilters(selectedObject);
            prepareRecipientsList(selectedObject);
        }
    }
    
    public void prepareRecipientsList(string selectedObject)
    {
        system.debug(LoggingLevel.WARN, 'selectedObject = ' + selectedObject);
        fldLst = new List<selectOption>();
        map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult objDesc = allObjs.get(selectedObject).getDescribe();
        Map<String,Schema.SObjectField> fieldMapping = objDesc.fields.getMap();
        COMM_Utils comUtil = new COMM_Utils();
        map<string, boolean> lstStdObjAccToLicense = comUtil.SVMX_getPermittedStandardObjectList();
        
        for(string fld: fieldMapping.keyset())
        {
            Schema.DescribeFieldResult f = fieldMapping.get(fld).getDescribe();
            if(f.getType() == Schema.DisplayType.Reference)
            {
                if(!comUtil.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                {
                    if(!lstStdObjAccToLicense.containsKey(String.valueof(f.getReferenceTo()[0])))
                    {
                        continue;
                    }
                }
                if(f.getReferenceTo()[0] == SVMXC__Service_Group_Members__c.SObjectType || f.getReferenceTo()[0] == User.SObjectType)
                {
                    if(existingRecipients.contains(f.getName()))
                        lstOfSelectedRecipients.add(new SelectOption(f.getName(), f.getLabel()));
                    else
                        lstOfAvailableRecipients.add(new SelectOption(f.getName(), f.getLabel()));
                }
                fldLst.add(new SelectOption(f.getName(), f.getLabel()));
            }
            fldLst.add(new SelectOption(f.getName(), f.getLabel()));
        }
        
        lstOfSelectedRecipients = sortSelectOption(lstOfSelectedRecipients);
        lstOfAvailableRecipients = sortSelectOption(lstOfAvailableRecipients);
        fldLst = sortSelectOption(fldLst);
        system.debug(LoggingLevel.WARN, 'fldLst = ' + fldLst);
    }
    
    public void prepareListOfFilters(string selectedObject)
    {
        system.debug(LoggingLevel.WARN, 'selectedObject = ' + selectedObject);
        lstFilters = new List<selectOption>();
        lstFilters.add(new SelectOption('--None--', getTAG019()));
        
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME', selectedObject);
        lstStringMap.add(stringMap1);
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        response = namedExpLst.SFM_getAllObjectNamedExpressionList(request);
        
        for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
            if(tempstringMap.key != null && tempstringMap.key.length() > 0)
                lstFilters.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
        
        lstFilters = sortSelectOption(lstFilters);
        system.debug(LoggingLevel.WARN, 'lstFilters = ' + lstFilters);
    }
    
    public void onChangeFilter()
    {
        isShowExp = false;
        system.debug(LoggingLevel.WARN, 'selectedFilter = ' + selectedFilter);
        if(selectedFilter == null || selectedFilter == '' || selectedFilter == '--None--')
        {
            isEditFilter = false;
            isShowExp = false;
            selectedFilter = null;
            ExpToShow = new SFM_WrapperDef.SFM_Expression();
            system.debug(LoggingLevel.WARN, 'isEditFilter = ' + isEditFilter + '; isShowExp = ' + isShowExp + ';selectedFilter = ' + selectedFilter + ';ExpToShow' + ExpToShow);
            return;
        }
        isEditFilter = true;
        editFilter();
        system.debug(LoggingLevel.WARN, 'isEditFilter = ' + isEditFilter + '; isShowExp = ' + isShowExp + ';selectedFilter = ' + selectedFilter);
    }
    
    public void addFilter()
    {
        isShowExp = true;
        selectedFilter = null;
        ExpToShow = new SFM_WrapperDef.SFM_Expression();
        COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
        system.debug(LoggingLevel.WARN, 'HdrExpressions = ' + HdrExpressions);
        lstOfFields.clear();
        lstOfFields.add(new SelectOption('SVMX.NONE',getTAG019()));
        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
        DispMethods.RetriveField(selectedObject, lstOfFields, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        HdrADDRow(); 
    }
    
    public void editFilter()
    {
        if(selectedFilter != null && selectedFilter != '--None--' && selectedFilter != '' && selectedFilter.length() != 0)
        {
            isShowExp = true;
            SFM_WrapperDef.SFM_Response_Expression responseExp = new SFM_WrapperDef.SFM_Response_Expression();
            
            COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
            lstOfFields.clear();
            lstOfFields.add(new SelectOption('SVMX.None',getTAG019()));
            WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
            DispMethods.RetriveField(selectedObject, lstOfFields, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
            
            responseExp = retrieveExpDetails(selectedFilter);
            ExpToShow = new SFM_WrapperDef.SFM_Expression();
            if(responseExp.expressions.size() > 0)
            {
                ExpToShow = responseExp.expressions[0];
                ExpDetailSize = ExpToShow.expressionDetails.size();
                Map_SequenceNumRec.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpToShow.expressionDetails)
                    Map_SequenceNumRec.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
            }
        }
    }
    
    public void selectRecipients()
    {
        List<selectOption> tempOption = new List<selectOption>();
        set<string> setMoved = new set<string>();
        
        if(selectedAvailableRecipients != null && selectedAvailableRecipients.size() > 0)
        {
            for(SelectOption availableOptions: lstOfAvailableRecipients)
            {
                boolean isSet = false;
                for(string str : selectedAvailableRecipients)
                {
                    if(availableOptions.getValue() == str)
                    {
                        isSet = true;
                        lstOfSelectedRecipients.add(availableOptions);
                        break;
                    }
                }
                if(isSet == false)
                {
                    tempOption.add(availableOptions);
                }
            }
            
            lstOfAvailableRecipients = tempOption;
        }
        lstOfAvailableRecipients = sortSelectOption(lstOfAvailableRecipients);
        lstOfSelectedRecipients = sortSelectOption(lstOfSelectedRecipients);
    }
    
    public void unSelectRecipients()
    {
        List<selectOption> tempOption = new List<selectOption>();
        set<string> setMoved = new set<string>();
        
        if(selectedRecipients != null && selectedRecipients.size() > 0)
        {
            for(SelectOption availableOptions: lstOfSelectedRecipients)
            {
                boolean isSet = false;
                for(string str : selectedRecipients)
                {
                    if(availableOptions.getValue() == str)
                    {
                        isSet = true;
                        lstOfAvailableRecipients.add(availableOptions);
                        break;
                    }
                }
                if(isSet == false)
                {
                    tempOption.add(availableOptions);
                }
            }
            
            lstOfSelectedRecipients = tempOption;
        }
        lstOfAvailableRecipients = sortSelectOption(lstOfAvailableRecipients);
        lstOfSelectedRecipients = sortSelectOption(lstOfSelectedRecipients);
    }
    
    //----------------------------------------- Method to retrieve Expression Details ---------------------------------------------
    public SFM_WrapperDef.SFM_Response_Expression retrieveExpDetails(string expId)
    {
        SFM_WrapperDef.SFM_Response_Expression responseExp = new SFM_WrapperDef.SFM_Response_Expression();
        SFM_WrapperDef.SFM_StringMap stringMap3 = new SFM_WrapperDef.SFM_StringMap('EXPRESSIONID',expId);
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(stringMap3);
        SFM_WrapperDef.SFM_Request request2 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        responseExp = namedExpLst.SFM_getNamedExpressionList(request2);
        return responseExp;
    }
    
    public void getDefaultValues()
    {
        selectedNotification = new SVMXC__ServiceMax_Config_Data__c();
        lstOfSFMObjects = new List<selectOption>();
        lstAlertTypes = new List<selectOption>();
        lstFilters = new List<selectOption>();
        lstOfSchedule = new List<selectOption>();
        lstOfNotifyStyle = new List<selectOption>();
        lstOfFields = new List<selectOption>();
        lstOfOperators = new List<selectOption>();
        lstOfAvailableRecipients = new List<selectOption>();
        lstOfSelectedRecipients = new List<selectOption>();
        selectedAvailableRecipients = new List<string>();
        selectedRecipients = new List<string>();
        existingRecipients = new set<string>();
        fldLst = new List<selectOption>();
        
        showExpression = false;
        isObjSelected = false;
        isShowExp = false;
        isEditFilter = false;
        displayFldLstPopup = false;
        
        lstOfOperators.add(new SelectOption('--None--',getTAG019()));
        lstOfOperators.add(new SelectOption('eq',getTAG031()));
        lstOfOperators.add(new SelectOption('ne',getTAG032()));
        lstOfOperators.add(new SelectOption('gt',getTAG033()));
        lstOfOperators.add(new SelectOption('ge',getTAG034()));
        lstOfOperators.add(new SelectOption('lt',getTAG035()));
        lstOfOperators.add(new SelectOption('le',getTAG036()));
        lstOfOperators.add(new SelectOption('starts',getTAG037()));
        lstOfOperators.add(new SelectOption('contains',getTAG038()));
        lstOfOperators.add(new SelectOption('notcontain',getTAG039()));
        lstOfOperators.add(new SelectOption('in',getTAG040()));
        lstOfOperators.add(new SelectOption('notin',getTAG041()));
        lstOfOperators.add(new SelectOption('isnull',getTAG042()));
        lstOfOperators.add(new SelectOption('isnotnull',getTAG043()));
        
        lstOfSchedule.add(new SelectOption('Immediately',getTAG064()));
        lstOfSchedule.add(new SelectOption('Business hours', getTAG063()));
        //lstOfSchedule.add(new SelectOption('Specify a time','Specify a time'));
        
        lstOfNotifyStyle.add(new SelectOption('Banner', 'Banner'));
        lstOfNotifyStyle.add(new SelectOption('Alert', 'Alert'));
        
        lstAlertTypes.add(new SelectOption('1', getTAG008()));
        lstAlertTypes.add(new SelectOption('2', getTAG009()));
        lstAlertTypes.add(new SelectOption('3', getTAG010()));
        selectedAlertType = '1';
    }

    public Map<Id, SVMXC__ServiceMax_Processes__c> INTF_getAllAllowedProcessed()
    {
        Map<Id, SVMXC__ServiceMax_Processes__c> mapAllowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        
        List<String> listProcess = new List<String>{'VIEW RECORD', 'STANDALONE CREATE', 'STANDALONE EDIT', 'SOURCE TO TARGET ALL', 'SOURCE TO TARGET CHILD', 'OUTPUT DOCUMENT'};
        for(String eachProcessType : listProcess)
        {
            mapAllowedProcess.putAll(getProfileBasedProcesses(eachProcessType));
        }  
        return mapAllowedProcess;
    }
    
    public map<Id, SVMXC__ServiceMax_Processes__c> getProfileBasedProcesses(String strPurpose)
    {
        Map<Id, SVMXC__ServiceMax_Processes__c> mapIdProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> allowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Id usrSVMXProfileId = (new SYNC_Utility()).getGroupProfileId(null, false);
        system.debug(LoggingLevel.Warn,  'Process Type: ' + strPurpose);
        String strSOQL = 'Select Id, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__Page_Layout__c, SVMXC__Doc_Template__c FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= \'Target Manager\' AND SVMXC__Purpose__c = :strPurpose AND SVMXC__Dispatch_Process_Status__c = \'Complete\'';
    
        if(strPurpose == 'OUTPUT DOCUMENT')
        {
            strSOQL += ' AND SVMXC__Doc_Template__c != null';
        }
        else
        {
            strSOQL += ' AND SVMXC__Page_Layout__c != null';
        }
        
        strSOQL += ' order by Name';
        
        system.debug(loggingLevel.WARN, 'SOQL For SFM Processes: ' + strSOQL);
    
        mapIdProcess.putAll((List<SVMXC__ServiceMax_Processes__c>)database.query(strSOQL));
    
        if(mapIdProcess != null && mapIdProcess.size() > 0)
        {
            set<Id> setProcessIdsToRemove = new set<Id>();
            set<Id> setProcessIdsWithTargetPNO = new set<Id>();
        
            for(SVMXC__ServiceMax_Processes__c processNodeObjs : [Select Id, SVMXC__Type__c, SVMXC__Doc_Template_Details__c, SVMXC__Page_Layout__c, SVMXC__Source_Object_Name__c, SVMXC__Process__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Process Node Objects' And SVMXC__Process__c IN :mapIdProcess.keySet()])
            {
                if(!setAccessibleObjs.contains(processNodeObjs.SVMXC__Source_Object_Name__c.toLowerCase()))
                {
                    if(mapIdProcess.containsKey(processNodeObjs.SVMXC__Process__c))
                    {
                        mapIdProcess.remove(processNodeObjs.SVMXC__Process__c);
                        system.debug(LoggingLevel.WARN, 'Removed Process is ' + processNodeObjs.SVMXC__Process__c);
                    }
                }
                
                if(processNodeObjs.SVMXC__Type__c == 'TARGET' || processNodeObjs.SVMXC__Type__c == 'TARGETCHILD')
                {
                    if(processNodeObjs.SVMXC__Type__c == 'TARGET')
                        setProcessIdsWithTargetPNO.add(processNodeObjs.SVMXC__Process__c);
                    
                    //system.debug(loggingLevel.WARN, '==Process with Target Page layout/Doc template: ' + process + ' ==: ' + processNodeObjs.SVMXC__Page_Layout__c + ' ==: ' + process.SVMXC__Doc_Template_Details__c);
                    
                    if(processNodeObjs.SVMXC__Type__c == 'TARGETCHILD')
                        if(processNodeObjs.SVMXC__Page_Layout__c == null && processNodeObjs.SVMXC__Doc_Template_Details__c == null)
                            setProcessIdsToRemove.add(processNodeObjs.SVMXC__Process__c);
                }
            }
        
            system.debug(loggingLevel.WARN, '==Process with Target: ' + setProcessIdsWithTargetPNO);
            system.debug(loggingLevel.WARN, '==Process to Remove without removing non target: ' + setProcessIdsToRemove);
            
            for(ID processID : mapIdProcess.keyset())
            {
                if(!setProcessIdsWithTargetPNO.contains(processID))
                    setProcessIdsToRemove.add(processID);
            }
            
            system.debug(loggingLevel.WARN, '==Process from Map: ' + mapIdProcess.keyset());
            system.debug(loggingLevel.WARN, '==Process to Remove: ' + setProcessIdsToRemove);
        
            if(setProcessIdsToRemove != null && setProcessIdsToRemove.size() > 0)
                for(ID processIdToRemove: setProcessIdsToRemove)
                    mapIdProcess.remove(processIdToRemove);
        
            system.debug(loggingLevel.WARN, '==Process from Map after removing: ' + mapIdProcess.keyset());
            
            //create map of PageLayoutIds and List of SFM Process Ids
            Map<Id, List<Id>> mapPageIdProcessId = new Map<Id, List<Id>>();
            for(SVMXC__ServiceMax_Processes__c SFMprocess : mapIdProcess.values())
            {
                if(!mapPageIdProcessId.containsKey(SFMprocess.SVMXC__Page_Layout__c))
                {
                    List<Id> lstIds = new List<Id>();
                    lstIds.add(SFMprocess.Id);
                    mapPageIdProcessId.put(SFMprocess.SVMXC__Page_Layout__c,lstIds);
                }   
                else
                {
                    mapPageIdProcessId.get(SFMprocess.SVMXC__Page_Layout__c).add(SFMprocess.Id);
                }
            }   
        
            for(SVMXC__Page_Layout_Detail__c pageLayoutDetail : [Select Id, SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Related_Object_Name__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN (Select Id from SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c in :mapPageIdProcessId.keySet() OR Id in :mapPageIdProcessId.keySet()) AND SVMXC__DataType__c = 'reference'])
            { 
                if(pageLayoutDetail.SVMXC__Related_Object_Name__c != null && pageLayoutDetail.SVMXC__Related_Object_Name__c != '')
                {
                    if(!setAccessibleObjs.contains(pageLayoutDetail.SVMXC__Related_Object_Name__c.toLowerCase()))
                    {
                        if(mapPageIdProcessId.containsKey(pageLayoutDetail.SVMXC__Page_Layout__c))
                        {
                            for(Id sfmProID : mapPageIdProcessId.get(pageLayoutDetail.SVMXC__Page_Layout__c))
                            {
                                mapIdProcess.remove(sfmProID);
                                    system.debug(LoggingLevel.WARN, 'Removed Process is ' + sfmProID + ', Page Layout Id is ' + pageLayoutDetail.SVMXC__Page_Layout__c);
                            }
                        }
                        else if(pageLayoutDetail.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c != null && mapPageIdProcessId.containsKey(pageLayoutDetail.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c))
                        {
                            for(Id sfmProID : mapPageIdProcessId.get(pageLayoutDetail.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c))
                            {
                                mapIdProcess.remove(sfmProID);
                                system.debug(LoggingLevel.WARN, 'Removed Process is ' + sfmProID + ', Header Page Layout Id is ' + pageLayoutDetail.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c);
                            }
                        }
                    }
                }
            }   
        }
        
        // If there are processes available after excluding those related to inaccessible objects, check how many of these are available to the logged in user's SVMX Group Profile
        if(mapIdProcess != null && mapIdProcess.size() > 0)
        {
            Set<Id> setAllAccessProcessId = new Set<Id>();
            setAllAccessProcessId.addAll(mapIdProcess.keyset());
            List<SVMXC__ServiceMax_Config_Data__c> lstProcessAccess = new List<SVMXC__ServiceMax_Config_Data__c>();
            lstProcessAccess = [Select Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = 'Service Flow Access' AND SVMXC__Dispatch_Process__c In: setAllAccessProcessId];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
            if(usrSVMXProfileId != null)
            {
                set<Id> setProcessId = new set<Id>();
                set<Id> setProcessIdWithAccess = new set<Id>();
                for (SVMXC__ServiceMax_Config_Data__c ConfigObj : lstProcessAccess)
                {
                    if(ConfigObj.SVMXC__Access_Configuration_Profile__c != null)
                    {
                        if(usrSVMXProfileId == ConfigObj.SVMXC__Access_Configuration_Profile__c)
                            setProcessId.add(ConfigObj.SVMXC__Dispatch_Process__c);
                        else
                            setProcessIdWithAccess.add(ConfigObj.SVMXC__Dispatch_Process__c);
                    }
                }
                setAllAccessProcessId.removeAll(setProcessIdWithAccess);
                setAllAccessProcessId.addAll(setProcessId);
            }
            for(Id CurrentId : setAllAccessProcessId)
                allowedProcess.put(CurrentId, mapIdProcess.get(CurrentId));
        
            system.debug(LoggingLevel.WARN, 'ALLOWED PROCESS: ' + strPurpose + ':' + allowedProcess.size() + allowedProcess);
        }
        return allowedProcess;
    }

    public Set<String> getSFMObjects(Map<Id, SVMXC__ServiceMax_Processes__c> mapProcess)
    {
        set<string> setPgLayoutIds = new set<string>();
        List<SVMXC__Page_Layout_Detail__c> lstPageLayoutDetail = new List<SVMXC__Page_Layout_Detail__c>();
        List<SVMXC__ServiceMax_Processes__c> lstProcessNodeObjects = [Select Id, SVMXC__Page_Layout__c, SVMXC__Source_Object_Name__c, SVMXC__Process__c, SVMXC__Process__r.SVMXC__Page_Layout__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Process Node Objects' AND SVMXC__Process__c IN :mapProcess.keySet()];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    
        for(SVMXC__ServiceMax_Processes__c processDetail: lstProcessNodeObjects)
        {
            setSFMObjects.add(processDetail.SVMXC__Source_Object_Name__c);
            
            if(processDetail.SVMXC__Page_Layout__c != null)
            {
                setPgLayoutIds.add(processDetail.SVMXC__Page_Layout__c);
            }
            if(processDetail.SVMXC__Process__r.SVMXC__Page_Layout__c != null)
            {
                setPgLayoutIds.add(processDetail.SVMXC__Process__r.SVMXC__Page_Layout__c);
            }
        }
        lstPageLayoutDetail = [Select Id, SVMXC__Page_Layout__c, SVMXC__Related_Object_Name__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN :setPgLayoutIds AND SVMXC__DataType__c = 'reference'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        for(SVMXC__Page_Layout_Detail__c pageDetail: lstPageLayoutDetail)
        {
            if(pageDetail.SVMXC__Related_Object_Name__c != null)
                setSFMObjects.add(pageDetail.SVMXC__Related_Object_Name__c);
        }
        return setSFMObjects;
    }

    public List<SelectOption> getlstOfSFMObjects()
    {
        Set<String> setUnwantedObjs = new Set<String>{'RecordType', 'Task', 'PartnerNetworkConnection'};//, 'Event'
        setSFMObjects.removeAll(setUnwantedObjs);
        
        lstOfSFMObjects.add(new selectOption('--None--', '--None--'));
        
        for(String eachObj : setSFMObjects)
        {
            if(mapObjAPINameToLabel.containsKey(eachObj))
            {
                if(eachObj == 'Event' || eachObj == 'SVMXC__Service_Order__c' || eachObj =='SVMXC__SVMX_Event__c')
                    lstOfSFMObjects.add(new selectOption(eachObj, mapObjAPINameToLabel.get(eachObj)));  
            }   
        }
        lstOfSFMObjects = sortSelectOption(lstOfSFMObjects);
        return lstOfSFMObjects;
    }
    
    public boolean saveExpression()
    {
        boolean isValid = true;
        system.debug(LoggingLevel.WARN, 'Inside Save Expression');
        if(ExpToShow.namedExpression != null && ExpToShow.namedExpression.SVMXC__Name__c != null && (ExpToShow.namedExpression.SVMXC__Name__c).length() > 0 &&  ExpToShow.namedExpression.SVMXC__ProcessID__c != null && (ExpToShow.namedExpression.SVMXC__ProcessID__c).length() >= 8)
        {
            SFM_WrapperDef.SFM_Response SFMExprResponse = new SFM_WrapperDef.SFM_Response();
            try
            {
                ExpToShow.namedExpression.SVMXC__SettingId__c = ExpToShow.namedExpression.SVMXC__ProcessID__c;
                ExpToShow.namedExpression.SVMXC__Source_Object_Name__c = selectedObject;
                List<SVMXC__ServiceMax_Config_Data__c> lstExpressionDetailsToSave = new List<SVMXC__ServiceMax_Config_Data__c>(); 
                for(SVMXC__ServiceMax_Config_Data__c eachExpressionRec :ExpToShow.expressionDetails)
                {
                    if((eachExpressionRec.SVMXC__Operator__c == null || eachExpressionRec.SVMXC__Operator__c == '--None--') && (eachExpressionRec.SVMXC__Operand__c == null || eachExpressionRec.SVMXC__Operand__c == '') && eachExpressionRec.SVMXC__Field_Name__c == 'None')
                        continue;
                    else
                        lstExpressionDetailsToSave.add(eachExpressionRec);
                }
                
                ExpToShow.expressionDetails.clear();
                
                if(lstExpressionDetailsToSave.size()>0)
                    ExpToShow.expressionDetails.addAll(lstExpressionDetailsToSave);
                    
                ExpDetailSize = ExpToShow.expressionDetails.size();
                if(ExpDetailSize >0)
                {
                    SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(ExpToShow.namedExpression,ExpToShow.expressionDetails);
                    List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                    LstSFM_Exp.add(oSFM_Exp);
                    
                    SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                    SVMXC.SFM_saveExpression saveExp = new SVMXC.SFM_saveExpression();
                    SFMExprResponse = saveExp.SFM_saveExpression(oRequest);
                    if(SFMExprResponse != null && SFMExprResponse.success != null)
                    {
                        if(boolean.valueOf(SFMExprResponse.success))
                        {
                            if(SFMExprResponse.resultIds != null && SFMExprResponse.resultIds.size() > 0)
                            {
                                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.CONFIRM, '' + getTAG030()));
                                prepareListOfFilters(selectedObject);
                                selectedFilter = SFMExprResponse.resultIds[0];
                            }
                        }
                        else
                        {
                            isValid = false;
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + SFMExprResponse.message ));
                        }
                    }
                }
                else
                {
                    isValid = false;
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG046()));
                }
                
            }
            catch(Exception ex)
            {
                isValid = false;
                if( SFMExprResponse != null && SFMExprResponse.message != null && SFMExprResponse.success == false )
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''+SFMExprResponse.message + ': ' + ex.getmessage()));
            }
        }
        else
        {
            if( ExpToShow.namedExpression == null || ExpToShow.namedExpression.SVMXC__Name__c == null || ExpToShow.namedExpression.SVMXC__Name__c == '' || (ExpToShow.namedExpression.SVMXC__Name__c).length() == 0 )
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG047()));
                isValid = false;
            }
            
            if( ExpToShow.namedExpression == null || ExpToShow.namedExpression.SVMXC__ProcessID__c == null || ExpToShow.namedExpression.SVMXC__ProcessID__c == '' || (ExpToShow.namedExpression.SVMXC__ProcessID__c).length() < 8 )
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG048()));
                isValid = false;
            }
        }
        
        return isValid;
    }
    
    //--------------------------------------Methods to add row of Expression details-------------------------------------------------------
    public void HdrADDRow()
    {
        isPgMsg = false;
        try
        {
            
            RecordType RTExpressionsDetail = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Expressions' Limit 1];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = RTExpressionsDetail.Id, SVMXC__Sequence__c = Integer.valueOf( ExpToShow.expressionDetails.size() + 1 ) );
            Map_SequenceNumRec.put( Math.Round(Integer.valueOf( ExpToShow.expressionDetails.size() + 1 )), NewExpDetailRec );
            ExpToShow.expressionDetails.add( NewExpDetailRec );
            if(ExpToShow.expressionDetails != null)
                ExpDetailSize = ExpToShow.expressionDetails.size();
            else
                ExpDetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    public void AddException(String strErrorMessage)
    {
        if(strErrorMessage != null && strErrorMessage != '' && strErrorMessage.length() > 0)
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, strErrorMessage));
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, ''));
    }
    
    //--------------------------------------Methods to delete row of Expression details-------------------------------------------------------
    public void HdrDeleteRow()
    {
        isPgMsg = false;
        try
        {
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            
            for( integer i=0; i < ExpToShow.expressionDetails.size(); i++ )
            {
                if( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && (i + 1) != integer.valueOf(delIndex) )
                    TempMap_SequenceNumRec.put( i + 1 - SeqNumToSubtract, ExpToShow.expressionDetails[i] );
                else if ( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && ( (i + 1) == integer.valueOf(delIndex)) )  
                    SeqNumToSubtract = 1;
            }
            Map_SequenceNumRec.clear();
            if( TempMap_SequenceNumRec != null )
                Map_SequenceNumRec.putAll(TempMap_SequenceNumRec);
            
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :Map_SequenceNumRec.keyset())
            {
                SequenceCounter++;
                if( Map_SequenceNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = Map_SequenceNumRec.get(SequenceNumber);
                    TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                    Temp_ExpDetailsLst.add(TempDetailExprObj);
                }
            }
            ExpToShow.expressionDetails.clear();
            ExpToShow.expressionDetails.addAll(Temp_ExpDetailsLst);
            if(ExpToShow.expressionDetails != null)
                ExpDetailSize = ExpToShow.expressionDetails.size();
            else
                ExpDetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    public List<SelectOption> sortSelectOption(List<SelectOption> lstSelectOption)
    {
        List<SelectOption> sortedList = new List<SelectOption>();
        Map<String,List<SelectOption>> mapStringToOptions = new Map<String,List<SelectOption>>();
        for(SelectOption eachOption : lstSelectOption)
        {
            mapStringToOptions.put(eachOption.getLabel(), new List<SelectOption>()); 
            mapStringToOptions.get(eachOption.getLabel()).add(eachOption);
        }
        List<String> keys = new List<String>(mapStringToOptions.keySet());
        keys.sort();
        for(String key:keys)
        {
            sortedList.addAll(mapStringToOptions.get(key)); 
        }
        return sortedList;
    }
    
    public void showFldLstToSelectFld()
    {
        displayFldLstPopup = true;
        
    }
    
    public void onSelectFldInPopup()
    {
        if(selectedFieldForText != null && selectedFieldForText != '' && selectedFieldForText.length() > 0)
        {
            displayFldLstPopup = false;
            emailText += ' [$' + selectedFieldForText + ']';
            selectedFieldForText = '';
        }
    }
    
    
    public void quickSave()
    {
        isPgMsg = true;
        system.debug(LoggingLevel.WARN, 'quickSave()::Exp to Show -'+ExpToShow);
        system.debug(LoggingLevel.WARN, 'quickSave()::ExpToShow.namedExpression.SVMXC__IsStandard__c -'+ExpToShow.namedExpression.SVMXC__IsStandard__c);
        system.debug(LoggingLevel.WARN, 'quickSave()::selectedFilter '+selectedFilter);
        if(isValidData())
        {
            boolean isValidExp = true;
            //if(ExpToShow != null && ExpToShow.namedExpression != null && ExpToShow.namedExpression.SVMXC__IsStandard__c != true && selectedFilter != null && selectedFilter != '--None--' && selectedFilter != '' && selectedFilter.length() != 0)
            if(ExpToShow != null && ExpToShow.namedExpression != null && ExpToShow.namedExpression.SVMXC__IsStandard__c != true && selectedFilter != null && selectedFilter != '' && selectedFilter.length() != 0)
            {
                if(!saveExpression())
                    isValidExp = false;
            }
            
            if(isValidExp)
            {
                save();
            }
        }
    }
    
    public pageReference saveAndClose()
    {
        isPgMsg = true;
        system.debug(LoggingLevel.WARN, 'saveAndClose()::Exp to Show -'+ExpToShow);
        if(isValidData())
        {
            boolean isValidExp = true;
            //if(ExpToShow != null && ExpToShow.namedExpression != null && ExpToShow.namedExpression.SVMXC__IsStandard__c != true && selectedFilter != null && selectedFilter != '--None--' && selectedFilter != '' && selectedFilter.length() != 0)
            if(ExpToShow != null && ExpToShow.namedExpression != null && ExpToShow.namedExpression.SVMXC__IsStandard__c != true && selectedFilter != null && selectedFilter != '' && selectedFilter.length() != 0)
            {
                if(!saveExpression())
                    isValidExp = false;
            }
            
            if(isValidExp)
            {
                if(save())
                {
                    pageReference pageref1 = Page.CONF_ManagePushNotifications;
                    return pageref1;
                }
            }
        }
        return null;
    }
    
    public boolean save()
    {
        selectedNotification.SVMXC__Object_Name__c = selectedObject;
        selectedNotification.SVMXC__Display_Value__c = selectedAlertType;
        if(selectedFilter != null && selectedFilter != '' && selectedFilter != '--None--')
            selectedNotification.SVMXC__Dispatch_Process__c = selectedFilter;
        else
            selectedNotification.SVMXC__Dispatch_Process__c = null;
        selectedNotification.SVMXC__Profile__c = addRecipientsEmailIds;
        selectedNotification.SVMXC__Internal_Value__c = emailSubject;
        selectedNotification.SVMXC__Description__c = emailText;
        selectedNotification.SVMXC__Parameter_Name__c = selectedSchedule;
        selectedNotification.SVMXC__Parameter_Value__c = selectedStyle;
        selectedNotification.SVMXC__Profile_Name__c = notificationName;
        selectedNotification.SVMXC__Active__c = isActive;
        selectedNotification.SVMXC__Display_Type__c = 'Push Notification';
        selectedNotification.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Mobile Configuration' Limit 1][0].Id;
        String strFields = '';
        for(SelectOption eachField : lstOfSelectedRecipients)
        {
            if(strFields != '')
                strFields += ',';
             strFields += eachField.getValue();   
        }
        selectedNotification.SVMXC__Lookup_Field_API_Name__c = strFields;
        Database.SaveResult dbSaveResult;
        system.debug(LoggingLevel.WARN, 'CONF_PushNotification:: selectedNotification -'+selectedNotification);
        if(selectedNotification != null && mode == 'new')
        {
            if(selectedNotification.Id != null){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(new List<SObject>{selectedNotification}, COMM_SecurityUtils.Access.Updateable)){
                dbSaveResult = Database.update(selectedNotification);
                }else{
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                    return false;
                }
            }else{
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(new List<SObject>{selectedNotification}, COMM_SecurityUtils.Access.Createable)){
                    dbSaveResult = Database.insert(selectedNotification);
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                    return false;
                }
            }
        }else if(selectedNotification != null && mode == 'edit')
        {
           if(COMM_SecurityUtils.getInstance().verifyFieldAccess(new List<SObject>{selectedNotification}, COMM_SecurityUtils.Access.Updateable)){
                dbSaveResult = Database.update(selectedNotification);
            }else{
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                    return false;
                }
        }
        
        if(dbSaveResult.isSuccess())
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.CONFIRM, '' + getTAG056()));
        }else
        {
            if(dbSaveResult.getErrors() != null && dbSaveResult.getErrors().size() > 0)
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, getTAG057() + ' - ' + dbSaveResult.getErrors()[0].getMessage()));
            else
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, getTAG057()));
            return false;    
        }
        return true; 
    }
    
    public boolean isValidData()
    {
        boolean isValid = true;
        if(notificationName == null || notificationName == '' || notificationName.length() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, getTAG053()));
            isValid = false;
        }
        if(selectedObject == null || selectedObject == '' || selectedObject.length() == 0 || selectedObject == '--None--')
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, getTAG054()));
            isValid = false;
        }
        if(selectedAlertType == null || selectedAlertType == '' || selectedAlertType.length() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, getTAG055()));
            isValid = false;
            system.debug(LoggingLevel.WARN, 'selectedAlertType -'+selectedAlertType);
        }
        return isValid;
    }
    
    public pageReference cancel()
    {
        pageReference pageref1 = Page.CONF_ManagePushNotifications;
        return pageref1;
    }
    
    public void hideFldListPopUp()
    {
        displayFldLstPopup = false;
    }
    
    public String getTAG001() {return system.label.CONF040_TAG019;}//Mobile Alerts
    public String getTAG002() {return system.label.COMM001_TAG054;}//'Save & Close'
    public String getTAG003() {return system.label.COMM001_TAG053;}//'Quick Save'
    public String getTAG004() {return system.label.COMM001_TAG040;}  // 'Cancel'
    public String getTAG005() {return system.label.CONF040_TAG005;}//'Push Notification Name'
    public String getTAG006() {return system.label.CONF040_TAG020;}//Alerts Status
    public String getTAG007() {return system.label.CONF040_TAG007;}//Type of Alert
    public String getTAG008() {return system.label.CONF040_TAG008;}//New - Send alert when a new item is created
    public String getTAG009() {return system.label.CONF040_TAG009;}//Changed - Send alert when an existing item is changed
    public String getTAG010() {return system.label.CONF040_TAG010;}//New or Changed - Send alert when an item is created or changed
    public String getTAG011() {return system.label.CONF040_TAG021;}//Filters
    public String getTAG012() {return system.label.CONF040_TAG011;}//Add filters to limit alerts to items that meet specific criteria. Skip this section to send alerts to every item selected above.
    public String getTAG013() {return system.label.COMM001_TAG036;}//'Add'
    public String getTAG014() {return system.label.COMM001_TAG048 + '  /  ';}//'Edit'
    public String getTAG015() {return system.label.COMM002_TAG025;}//'Expression Name'
    public String getTAG016() {return system.label.COMM002_TAG026;}//'Expression Id'
    public String getTAG017() {return system.label.CONF040_TAG012;}//Message Details
    public String getTAG018() {return system.label.CONF040_TAG004;}//Recipients
    public String getTAG019() {return system.label.COMM002_TAG005;}//'--None--'
    public String getTAG020() {return system.label.CONF040_TAG013;}//Subject
    public String getTAG021() {return system.label.CONF040_TAG014;}//Text
    public String getTAG022() {return system.label.CONF040_TAG015;}//Delivery Schedule
    public String getTAG023() {return system.label.CONF040_TAG016;}//Notification Style
    public String getTAG024() {return system.label.CONF040_TAG022;}//Insert Fields
    public String getTAG025() {return system.label.COMM001_TAG041;}//'Processing...'
    public String getTAG027() {return system.label.COMM002_TAG027;}//'Field Name'
    public String getTAG028() {return system.label.COMM002_TAG028;}//'Operator'
    public String getTAG029() {return system.label.COMM002_TAG029;}//'Value'
    public String getTAG030() {return system.label.COMM002_TAG030;}//'Expression saved successfully.'
    public String getTAG031() {return system.label.COMM002_TAG006;}//'Equals'
    public String getTAG032() {return system.label.COMM002_TAG007;}//'Not Equal'
    public String getTAG033() {return system.label.COMM002_TAG008;}//'Greater Than'
    public String getTAG034() {return system.label.COMM002_TAG009;}//'Greater or Equal To'
    public String getTAG035() {return system.label.COMM002_TAG010;}//'Less Than'
    public String getTAG036() {return system.label.COMM002_TAG011;}//'Less or Equal To'
    public String getTAG037() {return system.label.COMM002_TAG012;}//'Starts With'
    public String getTAG038() {return system.label.COMM002_TAG013;}//'Contains'
    public String getTAG039() {return system.label.COMM002_TAG014;}//'Does Not Contain'
    public String getTAG040() {return system.label.COMM002_TAG015;}//'Includes'
    public String getTAG041() {return system.label.COMM002_TAG016;}//'Excludes'
    public String getTAG042() {return system.label.COMM002_TAG022;}//'Is Null'
    public String getTAG043() {return system.label.COMM002_TAG023;}//'Is Not Null'
    public String getTAG045() {return system.label.COMM002_TAG024;}//'Advance Expression'
    public String getTAG046() {return system.label.COMM002_TAG004;}//'Invalid Expression'
    public String getTAG047() {return system.label.COMM002_TAG034;}//'Please enter Expression Name'
    public String getTAG048() {return system.label.COMM002_TAG035;}//'Expression ID must be unique and at least 8 characters long'
    public String getTAG049() {return system.label.COMM002_TAG032;}//'Add Row'
    public String getTAG050() {return system.label.COMM002_TAG033;}//'Delete Row'
    public String getTAG051() {return system.label.CONF040_TAG023;}//Data saved successfully.
    public String getTAG052() {return system.label.COMM001_TAG052;}//'Record(s) deleted successfully'
    
    public String getTAG053() {return system.label.CONF040_TAG024;}//Please provide a Push Notification Name.
    public String getTAG054() {return system.label.CONF040_TAG025;}//Please select an Object.
    public String getTAG055() {return system.label.CONF040_TAG026;}//Please select an alert type.
    public String getTAG056() {return system.label.CONF040_TAG027;}//Notification saved successfully.
    public String getTAG057() {return system.label.CONF040_TAG028;}//Error while saving the notification
    public String getTAG058() {return system.label.CONF040_TAG029;}//Error while deleting the notification
    public String getTAG059() {return system.label.CONF040_TAG030;}//Push notification deleted successfully.
    public String getTAG060() {return system.label.CONF040_TAG031;}//additional email recipients, separated by commas
    public String getTAG061() {return system.label.CONF040_TAG036;}//Available Recipients
    public String getTAG062() {return system.label.CONF040_TAG037;}//Selected Recipients
    public String getTAG071() {return System.Label.CONF006_TAG071;} //Add
    public String getTAG072() {return System.Label.CONF006_TAG072;} //Remove
    
     public String getTAG063() {return system.label.CONF040_TAG038;}//Business hours
    public String getTAG064() {return system.label.CONF040_TAG039;}//Immediately
}