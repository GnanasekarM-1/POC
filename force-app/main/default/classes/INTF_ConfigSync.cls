public with sharing class INTF_ConfigSync {
    public I18N_TranslationDelivery translationObj;
    public set<string> setProcessTMIds = new set<string>();
    public set<string> setMapIds = new set<string>();
    public set<string> setExpressionIds = new set<string>();
    //public set<string> setNamedSearchIds = new set<string>();
    public set<string> setChklstWizardObjs = new set<string>();
    public set<string> setProcessfromWizardSteps = new set<string>();
    //public set<string> setProcessCustomActionIds = new set<string>();
    public set<string> setDocTemplateIds = new set<string>();
    public set<string> setPageLayoutIds = new set<string>();
    public set<string> setOfProcessToExclude = new set<string>();
    public set<String> setPageLayoutsNotAccessible = new set<String>();
    public set<String> setDocTemplateNotAccessible = new set<String>();
    public set<string> nonAccessibleObjs = new set<string>();
    //public set<string> setQuestionIds = new set<string>();
    public APFT_Schema.Filters filterstoExclude;
    public string strDevice;
    public Integer response_size = 0, callbackQueryLimit = 0, responseSizeLimit = 2200000;
    public Boolean isChecklist = false;
    public Boolean isBatch = false;
    public String strLastIdClause = '', strExpLastIdClause = '', strExpDetailsLastIdClause = '', strPNOLastIdClause = '', strTMLastIdClause ='', strCSDLastIdClause = '', strLinkedProLastIdClause = '';
    public String strExpLastId = '', strExpDetailsLastId = '', strPNOLastId ='', strTMLastId = '', strCSDLastId = '', strLPLastId = '';
    public map<String, String> mapClientDetails = new map<String, String>();
    public ProductIQConfiguration.Profile productIQProfile = NULL;
    public Boolean isProductIQEnabled = false;
    string callBackContext = NULL;
    public Boolean isTargetedSyncEnabled = false;
    
    public void INTF_OneCallMetaSync(){}
    
    public INTF_WebServicesDef.INTF_SFMResponse OneCallMetaSync(INTF_WebServicesDef.INTF_SFMRequest req){
        
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('OneCallMetaSync');
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        res.eventName = req.eventName;
        res.eventType = req.eventType;
        res.success = true;
        res.values = new list<string>();
        res.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        boolean isCallBack = false;
        string sfdcProfileId = userinfo.getProfileId();
        string svmxGrpProfileId;
        
        try{
            if(req.valueMap != null)
            {
                for(INTF_WebServicesDef.SVMXMap firstVM : req.valueMap)
                {
                    if(firstVM.key == 'CALL_BACK')
                    {
                        isCallBack = boolean.valueOf(firstVM.value);
                        for(INTF_WebServicesDef.SVMXMap callBackVM : firstVM.valueMap)
                        {
                            if(callBackVM.key == 'CALL_BACK_CONTEXT')
                            {
                                callBackContext = callBackVM.value;
                                if(callBackVM.values != null && callBackVM.values.size() > 0)
                                    strLastIdClause = ' AND ID > \'' + callBackVM.values[0] + '\'';
                            }else if(callBackVM.key == 'EXPRESSION_LASTID'){
                                callBackContext = callBackVM.value;
                                if(callBackVM.values != null && callBackVM.values.size() > 0 && callBackVM.values[0] != NULL && callBackVM.values[0] != ''){
                                    strExpLastId = callBackVM.values[0];
                                    strExpLastIdClause = ' AND ID > \'' + callBackVM.values[0] + '\'';
                                }
                            }else if(callBackVM.key == 'EXPRESSION_DETAILS_LASTID'){
                                callBackContext = callBackVM.value;
                                if(callBackVM.values != null && callBackVM.values.size() > 0 && callBackVM.values[0] != NULL && callBackVM.values[0] != ''){
                                    strExpDetailsLastId = callBackVM.values[0];
                                    strExpDetailsLastIdClause = ' AND ID > \'' + callBackVM.values[0] + '\'';
                                }
                            }
                            /*else if(callBackVM.key == 'LINKED_PROCESS_LASTID'){
                                callBackContext = callBackVM.value;
                                if(callBackVM.values != null && callBackVM.values.size() > 0 && callBackVM.values[0] != NULL && callBackVM.values[0] != ''){
                                    strLPLastId = callBackVM.values[0];
                                    strLinkedProLastIdClause = ' AND ID > \'' + callBackVM.values[0] + '\'';
                                }
                            }else if(callBackVM.key == 'PROCESS_PNO_LASTID'){
                                callBackContext = callBackVM.value;
                                if(callBackVM.values != null && callBackVM.values.size() > 0 && callBackVM.values[0] != NULL && callBackVM.values[0] != ''){
                                    strPNOLastId = callBackVM.values[0];
                                    strPNOLastIdClause = ' AND ID > \'' + callBackVM.values[0] + '\'';
                                }
                            }else if(callBackVM.key == 'PROCESS_TM_LASTID'){
                                callBackContext = callBackVM.value;
                                if(callBackVM.values != null && callBackVM.values.size() > 0 && callBackVM.values[0] != NULL && callBackVM.values[0] != ''){
                                    strTMLastId = callBackVM.values[0];
                                    strTMLastIdClause = ' AND ID > \'' + callBackVM.values[0] + '\'';
                                }
                            }else if(callBackVM.key == 'PROCESS_CSD_LASTID'){
                                callBackContext = callBackVM.value;
                                if(callBackVM.values != null && callBackVM.values.size() > 0 && callBackVM.values[0] != NULL && callBackVM.values[0] != ''){
                                    strCSDLastId = callBackVM.values[0];
                                    strCSDLastIdClause = ' AND ID > \'' + callBackVM.values[0] + '\'';
                                }
                            }*/
                            else if(callBackVM.key == 'QUERY_LIMIT'){
                                callbackQueryLimit = Integer.ValueOF(callBackVM.value);
                            }
                            
                        }
                    }else if(firstVM.key == 'TARGETED_SYNC_ENABLED'){
                            isTargetedSyncEnabled = Boolean.valueOF(firstVM.value);
                    }
                }
            }
            
            system.debug(LoggingLevel.WARN, '***strPNOLastId = '+strPNOLastId +' ; strTMLastId = '+strTMLastId +' ; strCSDLastId = '+strCSDLastId);
            
            mapClientDetails = getClientData(req);
            
            if(!isCallBack)
            {
                svmxGrpProfileId = getSVMXGrpProfileId(sfdcProfileId);
                if(svmxGrpProfileId == null || svmxGrpProfileId.length() == 0){
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                    return returnResponseWithMsg(false, 'ERROR', getNoSVMXGrpProfileError(), res);
                }
                    
                INTF_TxnCache.put('GROUP_PROFILE_ID', svmxGrpProfileId, 'string');
                system.debug(loggingLevel.WARN, 'User-ServiceMax Group Profile: ' + svmxGrpProfileId);
                
                string str = getDeviceName(req);
                if(str != null && str.length() > 0)
                {
                    if(str.contains('iPhone'))
                        strDevice = 'iPhone';
                    else
                        strDevice = str;
                }
                    
                INTF_TxnCache.put('DEVICE_NAME', strDevice, 'string');
                nonAccessibleObjs = getNonAccessibleObjList(sfdcProfileId);
                INTF_TxnCache.put('NON_ACCESSIBLE_OBJECTS', nonAccessibleObjs, 'set<string>');
                filterstoExclude = getApplicationFilters(strDevice);
                executeMetaSync(1, res, svmxGrpProfileId, req.value);
            }
            else
            {
                system.debug(LoggingLevel.WARN, 'req = ' + req);
                INTF_TxnCache.restore(mapClientDetails, req.value);
                svmxGrpProfileId = (string)INTF_TxnCache.get('GROUP_PROFILE_ID', 'string');
                if(svmxGrpProfileId == NULL || svmxGrpProfileId == ''){
                    svmxGrpProfileId = getSVMXGrpProfileId(userinfo.getProfileId());
                }
                nonAccessibleObjs = (set<string>)INTF_TxnCache.get('NON_ACCESSIBLE_OBJECTS', 'set<string>');
                strDevice = (string)INTF_TxnCache.get('DEVICE_NAME', 'string');
                filterstoExclude = getApplicationFilters(strDevice);
                
                if(callBackContext == null || callBackContext.length() == 0){
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                    return executeMetaSync(1, res, svmxGrpProfileId, req.value);
                }
                else{
                    if(callBackContext == '2'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(2, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '3'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(3, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '4'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(4, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '5'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(5, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '6'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(6, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '7'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(7, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '8'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(8, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '9'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(9, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '10'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(10, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '11'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(11, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '12'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(12, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '13'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(13, res, svmxGrpProfileId, req.value);
                    }
                    else if(callBackContext == '14'){
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
                        return executeMetaSync(14, res, svmxGrpProfileId, req.value);
                    }
                    
                }
            }
        }catch(Exception ex){
            INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
            return returnResponseWithException(ex, res);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'OneCallMetaSync');
        return res;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse executeMetaSync(integer executeFrom, INTF_WebServicesDef.INTF_SFMResponse res, string svmxGrpProfileId, string syncReqId){
        
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('executeMetaSync');
        if(executeFrom <= 1)
        {
            system.debug(loggingLevel.WARN, 'Executing from ' + executeFrom);
            try{
                addMobileConfigMetaToResponse(res, svmxGrpProfileId);
                addSFMWizardMetaToResponse(res, svmxGrpProfileId);
            }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 2)
        {
            try{
                if(isLimitReach(res, '2'))
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                system.debug(loggingLevel.WARN, 'Executing from ' + executeFrom);
                setExpressionIds = (set<string>)INTF_TxnCache.get('SET_EXPRESSION_ID', 'set<string>');
                
                INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Related_Object_Name__c from SVMXC__Page_Layout_Detail__c where SVMXC__DataType__c = \'reference\' AND SVMXC__Related_Object_Name__c IN: nonAccessibleObjs');
                for(SVMXC__Page_Layout_Detail__c pgDtl: [Select SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Related_Object_Name__c from SVMXC__Page_Layout_Detail__c where SVMXC__DataType__c = 'reference' AND SVMXC__Related_Object_Name__c IN: nonAccessibleObjs])
                {
                    setPageLayoutsNotAccessible.add(pgDtl.SVMXC__Page_Layout__c);
                    if(pgDtl.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c != null)
                        setPageLayoutsNotAccessible.add(pgDtl.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c);
                }
                
                INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Doc_Template__c from SVMXC__Doc_Template_Details__c where SVMXC__Object_Name__c IN: nonAccessibleObjs');
                for(SVMXC__Doc_Template_Details__c docTemplateDtl: [Select SVMXC__Doc_Template__c from SVMXC__Doc_Template_Details__c where SVMXC__Object_Name__c IN: nonAccessibleObjs])
                    setDocTemplateNotAccessible.add(docTemplateDtl.SVMXC__Doc_Template__c);
                
                INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: \'Service Flow Access\' AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Dispatch_Process__c != null');
                List<SVMXC__ServiceMax_Config_Data__c> lstProcessAccess = [Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: 'Service Flow Access' AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Dispatch_Process__c != null];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                system.debug(loggingLevel.WARN, 'Service Flow Access: ' + lstProcessAccess + ' :: ' + lstProcessAccess.size());
                
                setOfProcessToExclude = getLstProcessesToExclude(lstProcessAccess, svmxGrpProfileId);
                system.debug(loggingLevel.WARN, 'Process to exclude: ' + setOfProcessToExclude + ' :: ' + setOfProcessToExclude.size());
                INTF_TxnCache.put('SET_PROCESS_EXCLUDE', setOfProcessToExclude, 'set<string>');
                INTF_TxnCache.put('SET_NON_ACCESSIBLE_PAGELAYOUT', setPageLayoutsNotAccessible, 'set<string>');
                INTF_TxnCache.put('SET_NON_ACCESSIBLE_DOCTEMPLATE', setDocTemplateNotAccessible, 'set<string>');
            }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 3)
        {
            try{
                if(isLimitReach(res, '3'))
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                
                system.debug(loggingLevel.WARN, 'Executing from ' + executeFrom + '; isBatch =  ' + isBatch + '; strLastIdClause = ' + strLastIdClause);
                addLinkedProcessToResponse(res, svmxGrpProfileId);
                system.debug(loggingLevel.WARN, 'isBatch =  ' + isBatch);
                if(isBatch)
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 4)
        {
                
                try{
                if(isLimitReach(res, '4'))
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                
                system.debug(loggingLevel.WARN, 'Executing from ' + executeFrom + '; isBatch =  ' + isBatch + '; strLastIdClause = ' + strLastIdClause);
                if(productIQProfile == NULL){
                    setPIQProfile(svmxGrpProfileId); //get the ProductIQ settings
                }
                addPNOMetaToResponse(res, svmxGrpProfileId);
                system.debug(loggingLevel.WARN, 'isBatch =  ' + isBatch);
                if(isBatch)
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 5)
        {
                
                try{
                if(isLimitReach(res, '5'))
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                
                system.debug(loggingLevel.WARN, 'Executing from ' + executeFrom + '; isBatch =  ' + isBatch + '; strLastIdClause = ' + strLastIdClause);
                addTargetManagerToResponse(res, svmxGrpProfileId);
                system.debug(loggingLevel.WARN, 'isBatch =  ' + isBatch);
                if(isBatch)
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
            }catch(Exception ex){
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 6)
        {
                
                try{
                if(isLimitReach(res, '6'))
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                
                system.debug(loggingLevel.WARN, 'Executing from ' + executeFrom + '; isBatch =  ' + isBatch + '; strLastIdClause = ' + strLastIdClause);
                addChecklistSmartDocToResponse(res, svmxGrpProfileId);
                system.debug(loggingLevel.WARN, 'isBatch =  ' + isBatch);
                if(isBatch)
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 7)
        {
            try{
                if(isLimitReach(res, '7'))
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                system.debug(loggingLevel.WARN, 'Executing from ' + executeFrom);
                setProcessTMIds = (set<string>)INTF_TxnCache.get('SET_PROCESS_TM', 'set<string>');
                setExpressionIds = (set<string>)INTF_TxnCache.get('SET_EXPRESSION_ID', 'set<string>');
                
                addBusRuleMetaToResponse(res, setProcessTMIds, setExpressionIds, svmxGrpProfileId);
                if(isBatch)
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                
            }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 8)
        {
            try{
                if(isLimitReach(res, '8'))
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                
                system.debug(loggingLevel.WARN, 'Executing from ' + executeFrom);
                
                setExpressionIds = (set<string>)INTF_TxnCache.get('SET_EXPRESSION_ID', 'set<string>');
                addExpsMetaToResponse(res, setExpressionIds,svmxGrpProfileId);
                if(isBatch)
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                INTF_TxnCache.remove('SET_EXPRESSION_ID', 'set<string>');
            }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 9)
        {
            try{
                if(isLimitReach(res, '9'))
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                system.debug(loggingLevel.WARN, 'Executing from ' + executeFrom + '; isBatch =  ' + isBatch);
                setPageLayoutIds = (set<string>)INTF_TxnCache.get('SET_PAGELAYOUT_ID', 'set<string>');
                addQuestionMetaToResponse(res, setPageLayoutIds, svmxGrpProfileId);
                system.debug(loggingLevel.WARN, 'isBatch =  ' + isBatch);
                if(isBatch)
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
            }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 10){
            try{
                if(isLimitReach(res, '10')){
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                system.debug(logginglevel.WARN, 'Executing from '+executeFrom);
                
                set<string> setQuestionIds = new set<string>();
                setQuestionIds = (set<string>)INTF_TxnCache.get('SET_QUESTION_ID', 'set<string>');
                addQuesDefaultResponseToResponse(res, setQuestionIds, svmxGrpProfileId );
                if(isBatch)
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                
                INTF_TxnCache.remove('SET_QUESTION_ID', 'set<string>');
                
            }catch(Exception Ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 11)
        {
            try{
                
                if(executeFrom != 11){    //If the executeFrom came from previous context, stop execution and return result so that it calls back to context 11 with fresh set of sfdc resources
                    addCallBackContext(res,'11', new List<String>());
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                    }
                
                    system.debug(loggingLevel.WARN, 'Executing from ' + executeFrom);
                    if(productIQProfile == NULL){
                    setPIQProfile(svmxGrpProfileId); //get the ProductIQ settings
                }
                addSFMSearchMetaToResponse(res, svmxGrpProfileId, nonAccessibleObjs);
            }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 12)
        {
            try{
                if(executeFrom != 12){    //If the executeFrom came from previous context, stop execution and return result so that it calls back to context 12 with fresh set of sfdc resources
                    addCallBackContext(res,'12', new List<String>());
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                
                setMapIds = (set<string>)INTF_TxnCache.get('SET_MAP_ID', 'set<string>');
                setPageLayoutIds = (set<string>)INTF_TxnCache.get('SET_PAGELAYOUT_ID', 'set<string>');
                set<string> setNamedSearchIds = new set<string>();
                
                if(setPageLayoutIds != null && setPageLayoutIds.size() > 0)
                {
                    INTF_DataSync.logSOQL(intMethodCount, 'select id from SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c IN: setPageLayoutIds');
                    for(SVMXC__Page_Layout__c pgLayout: [select id from SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c IN: setPageLayoutIds])
                        setPageLayoutIds.add(pgLayout.Id);
                    
                    INTF_DataSync.logSOQL(intMethodCount, 'select SVMXC__Named_Search__c, SVMXC__Field_Mapping__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN: setPageLayoutIds AND (SVMXC__Field_Mapping__c != null OR (SVMXC__Detail_Type__c = \'Field\' AND SVMXC__DataType__c = \'reference\'))');
                    for(SVMXC__Page_Layout_Detail__c lstPglayoutDtl : [select SVMXC__Named_Search__c, SVMXC__Field_Mapping__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN: setPageLayoutIds AND (SVMXC__Field_Mapping__c != null OR (SVMXC__Detail_Type__c = 'Field' AND SVMXC__DataType__c = 'reference'))])
                    {
                        if(lstPglayoutDtl.SVMXC__Named_Search__c != null)
                            setNamedSearchIds.add(lstPglayoutDtl.SVMXC__Named_Search__c);
                        if(lstPglayoutDtl.SVMXC__Field_Mapping__c != null)//Form Fill
                            setMapIds.add(lstPglayoutDtl.SVMXC__Field_Mapping__c);
                    }
                }  
                
                //Object Mappings
                addMapsMetaToResponse(res, setMapIds);
                
                //Named Searchs
                addNamedSearchMetaToResponse(res, setNamedSearchIds);
                
                INTF_TxnCache.remove('SET_MAP_ID', 'set<string>');
                
            }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        if(executeFrom <= 13)
        {
            try{
                if(isLimitReach(res, '13'))
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                
                setDocTemplateIds = (set<string>)INTF_TxnCache.get('SET_DOC_TEMPLATE_ID', 'set<string>');
                
                //Document Templates
                if(setDocTemplateIds != null && setDocTemplateIds.size() > 0)
                    addDocTemplateMetaToResponse(res, setDocTemplateIds);
                
                if(isBatch)
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                INTF_TxnCache.remove('SET_DOC_TEMPLATE_ID', 'set<string>');
                
            }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        
        if(executeFrom <= 14)
        {
            try{
                if(isLimitReach(res, '14'))
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                }
                
                setProcessTMIds = (set<string>)INTF_TxnCache.get('SET_PROCESS_TM', 'set<string>');

                if(setProcessTMIds != null && setProcessTMIds.size() > 0)
                    addSourceUpdateMetaToResponse(res, setProcessTMIds);
                
                if(isBatch)
                {
                    INTF_TxnCache.save(mapClientDetails, syncReqId);
                    INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                    return res;
                } 

                INTF_TxnCache.remove('SFM_TRANSLATION_OBJ', 'I18N_TranslationDelivery');
                INTF_TxnCache.remove('SET_PROCESS_TM', 'set<string>');
                
            }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
                return returnResponseWithException(ex, res);
            }
        }
        
        INTF_TxnCache.save(mapClientDetails, syncReqId);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'executeMetaSync');
        return res;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse returnResponseWithException(Exception ex, INTF_WebServicesDef.INTF_SFMResponse res){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('returnResponseWithException');
        SmaxException customException = new SmaxException(null, ex);
        res.errors.add(customException.getDetailedErrorMsg());
        res.success = false;
        res.messageType = 'ERROR';
        system.debug(loggingLevel.WARN, 'In returnResponseWithException, res.errors =  ' + res.errors);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'returnResponseWithException');
        return res;
    }
    
    public void addBusRuleMetaToResponse(INTF_WebServicesDef.INTF_SFMResponse res, set<string> setProcessTMIds, set<string> setExpressionIds, string svmxGrpProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addBusRuleMetaToResponse');
        
        Integer intLimit = 1000;
        Integer intProcessBizRuleLimit = 500 ;
        Integer intLimitPercent = getSET011(svmxGrpProfileId);
            
        intLimit = calculateLimit(intLimitPercent);
        if(intLimit <= 0){
            intLimit = 2;
        }
        
        intProcessBizRuleLimit = intLimit/2 ;
        
        if(callbackQueryLimit != 0 ){
                intProcessBizRuleLimit = callbackQueryLimit;   //In case there was a limit sent in the call back, use that to query records to reduce heap size
        }
        
        if( callBackContext != NULL && callBackContext != '7' && strLastIdClause != ''){
                strLastIdClause = '';
        }
        system.debug(LoggingLevel.WARN, ' Query record limit = '+intProcessBizRuleLimit);
        
        string soqlProcessPBR = prepareQuery(getFields_Process_PBR());
            
            soqlProcessPBR += ' from SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'Process Business Rule\' AND SVMXC__Process1__c IN: setProcessTMIds AND ( (SVMXC__Rule_Type__c !=\'Checklist_Section_Entry_Criteria\' AND SVMXC__Rule_Type__c !=\'Checklist_Section_Exit_Criteria\') OR ( (SVMXC__Rule_Type__c =\'Checklist_Section_Entry_Criteria\' Or SVMXC__Rule_Type__c =\'Checklist_Section_Exit_Criteria\') And SVMXC__Active__c=true)) ';
            soqlProcessPBR += strLastIdClause + ' Order By ID Limit '+intProcessBizRuleLimit;  //Including LastID clause and limit
            
            system.debug(loggingLevel.WARN, 'Query Prepared for Process-Process Business Rules: ' + soqlProcessPBR);
            INTF_DataSync.logSOQL(intMethodCount, soqlProcessPBR);
            
            system.debug(loggingLevel.WARN, 'setProcessTMIds = ' + setProcessTMIds);
            
            List<SVMXC__ServiceMax_Processes__c> lstProcessBusinessRules = database.query(soqlProcessPBR);
            system.debug(loggingLevel.WARN, 'Process-Process Business Rules Queried: ' + lstProcessBusinessRules.size() + ' :: ' + lstProcessBusinessRules);
            
            //Check heap size and add callback
            if(checkHeapLimit(intLimitPercent)){
                system.debug(LoggingLevel.WARN, 'Apex Limit exceeded in context '+ callBackContext);
                if(callBackContext == '7'){   //Check if it is the current context
                    addCallBackContextForLimit(res,'7', new List<String>(), String.valueOf(intProcessBizRuleLimit/2) ); //Send the query limit number to be used in the next batch
                }else{
                    addCallBackContextForLimit(res,'7', new List<String>(), NULL);  //So that next batch will start from '4' with new set of governor limits
                }
                isBatch = true;
                return; 
             }else if( intProcessBizRuleLimit-lstProcessBusinessRules.size() <= 0 ){  
                addCallBackContextForLimit(res, '7', new List<String>{lstProcessBusinessRules[lstProcessBusinessRules.size()-1].Id}, NULL);
                isBatch = true;
            }
            
            translationObj = (I18N_TranslationDelivery)INTF_TxnCache.get('SFM_TRANSLATION_OBJ', 'I18N_TranslationDelivery');
            system.debug(loggingLevel.WARN, 'After Translation Process-Process Business Rules Queried: ' + lstProcessBusinessRules);
            
            //Defect 37575 - If not found in Request_Cache, query it again
            if(translationObj == NULL){
                List<SVMXC__ServiceMax_Processes__c> lstTMProcesses = [select SVMXC__Tag_Keys__c from SVMXC__ServiceMax_Processes__c where Id IN : setProcessTMIds];
                List<String> lstAllTags = new List<String>();
                for(SVMXC__ServiceMax_Processes__c tmProcess: lstTMProcesses){
                    if(tmProcess.SVMXC__Tag_Keys__c != NULL && tmProcess.SVMXC__Tag_Keys__c.length() > 0)
                        lstAllTags.addAll(tmProcess.SVMXC__Tag_Keys__c.split(';'));
                }
                system.debug(LoggingLevel.WARN, 'lstAllTags size = '+lstAllTags.size());
                translationObj = new I18N_TranslationDelivery(lstAllTags, UserInfo.getLanguage(), true);
                
                loggingForLimits('addBusRuleMetaToResponse', 'before');
                lstTMProcesses.clear();  //Clear heap 
                loggingForLimits('addBusRuleMetaToResponse', 'after');
            }
            if(translationObj != NULL){
                lstProcessBusinessRules = translationObj.SVMX_GetProcessTranslation(lstProcessBusinessRules);
            }
            
            //Check response size before adding to the response
            if((response_size + json.serialize(lstProcessBusinessRules).Length()) > responseSizeLimit && callBackContext != '7'){
                isBatch = TRUE;
                addCallBackContext(res,'7', NULL);  
                return;
            }
            addToResponse(res, lstProcessBusinessRules, 'SFM_PROCESS_BUSINESS_RULE');
            
            set<string> setBusinessRuleIds = new set<string>();
            for(SVMXC__ServiceMax_Processes__c PBR: lstProcessBusinessRules)
                if(PBR.SVMXC__Process3__c != null)
                    setBusinessRuleIds.add(PBR.SVMXC__Process3__c);
            
             loggingForLimits('lstProcessBusinessRules', 'before');
             lstProcessBusinessRules.clear();  //Clear heap 
             loggingForLimits('lstProcessBusinessRules', 'after');
                    
            if(setBusinessRuleIds != null && setBusinessRuleIds.size() > 0)
            {
                setExpressionIds.addAll(setBusinessRuleIds);
                string soqlProcessBR = prepareQuery(getFields_Process_Exp());
                soqlProcessBR += ' from SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'Business Rule\' AND ID IN: setBusinessRuleIds';
                system.debug(loggingLevel.WARN, 'Query Prepared for Process-Business Rules: ' + soqlProcessBR);
                INTF_DataSync.logSOQL(intMethodCount, soqlProcessBR);
                List<SVMXC__ServiceMax_Processes__c> lstBusinessRules = database.query(soqlProcessBR);
                system.debug(loggingLevel.WARN, 'Process-Business Rules Queried: ' + lstBusinessRules + ' :: ' + lstBusinessRules.size());
                
                lstBusinessRules = translationObj.SVMX_GetProcessTranslation(lstBusinessRules);
                
                //Check response size before adding to the response
                if((response_size + json.serialize(lstBusinessRules).Length()) > responseSizeLimit && callBackContext != '7'){
                    isBatch = TRUE;
                    addCallBackContext(res,'7', NULL);  
                    return;
                }
                addToResponse(res, lstBusinessRules, 'SFM_BUSINESS_RULE');
                
                loggingForLimits('lstBusinessRules', 'before');
                lstBusinessRules.clear();  //Clear heap 
                loggingForLimits('lstBusinessRules', 'after');
            }
       
        INTF_TxnCache.put('SET_EXPRESSION_ID', setExpressionIds, 'set<string>');
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addBusRuleMetaToResponse');
    }
    
    public integer getSET011(String svmxGrpProfileId){
        Integer intLimitPercent = (integer)INTF_TxnCache.get('LIMIT_QUERY', 'integer');  //retrieve from Cache
        /*if(intLimitPercent == NULL){
            for(SVMXC__ServiceMax_Config_Data__c cnf: getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET011'}, svmxGrpProfileId))
                intLimitPercent = Integer.valueOf(cnf.SVMXC__Internal_Value__c);
                
            if(intLimitPercent == NULL){ //Suppose there is no setting and limit is still NULL
                    intLimitPercent = 70;
            }    
            INTF_TxnCache.put('LIMIT_QUERY', intLimitPercent, 'integer');  //put it in cache       
        }*/
        
        if(intLimitPercent == NULL){
                List<SVMXC__ServiceMax_Config_Data__c> lstSettings = getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET025'}, svmxGrpProfileId); //Get the config sync setting
                if(lstSettings != NULL && lstSettings.size() > 0){
                    for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings){
                        intLimitPercent = Integer.valueOf(cnf.SVMXC__Internal_Value__c);
                        system.debug(LoggingLevel.WARN, 'IPAD018_SET025 = '+intLimitPercent);
                    }
                }else{  //IF config sync setting not found, consider SET011
                    for(SVMXC__ServiceMax_Config_Data__c cnf: getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET011'}, svmxGrpProfileId))
                        intLimitPercent = Integer.valueOf(cnf.SVMXC__Internal_Value__c);
                        system.debug(LoggingLevel.WARN, 'IPAD018_SET011 = '+intLimitPercent);
                }
                
                if(intLimitPercent == NULL){ //Suppose there is no setting and limit is still NULL, default it to 70
                    intLimitPercent = 70;
            }    
            INTF_TxnCache.put('LIMIT_QUERY', intLimitPercent, 'integer');  //put it in cache  
            }
        return intLimitPercent;
    }
    
    public integer calculateLimit(integer intLimitPercent){
        Integer intLimit = 1000;
        List<Integer> lstIntPercent = new List<Integer>();
        Integer intCPULimit = intLimitPercent * Limits.getLimitCpuTime()/100;
        Integer intHeapLimit = intLimitPercent * Limits.getLimitHeapSize()/100;
        Integer intQueryLimit = intLimitPercent * Limits.getLimitQueries()/100;
        Integer intQueryRowLimit = intLimitPercent * Limits.getLimitQueryRows()/100;
        
        system.debug(LoggingLevel.WARN, 'Max CPU Limit = ' + intCPULimit + '; Max Heap Limit = ' + intHeapLimit + '; Max Query Limit = ' + intQueryLimit + '; Max Query Row used = ' + intQueryRowLimit);
        system.debug(LoggingLevel.WARN, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries() + '; Rows Queried = ' + Limits.getQueryRows());
        
        integer intLimitCPUPercent = (intLimitPercent * (intCPULimit - Limits.getCpuTime()))/intCPULimit;
        integer intLimitHeapPercent = (intLimitPercent * (intHeapLimit - Limits.getHeapSize()))/intHeapLimit;
        integer intLimitQueriesPercent = (intLimitPercent * (intQueryLimit - Limits.getQueries()))/intQueryLimit;
        integer intLimitQueryRowPercent = (intLimitPercent * (intQueryRowLimit - Limits.getQueryRows()))/intQueryRowLimit;        
        lstIntPercent.add(intLimitCPUPercent);
        lstIntPercent.add(intLimitQueriesPercent);
        lstIntPercent.add(intLimitHeapPercent);
        lstIntPercent.add(intLimitQueryRowPercent);
        
        lstIntPercent.sort();
        intLimit = (lstIntPercent[0] * (intQueryRowLimit - Limits.getQueryRows()))/100;
        
        system.debug(LoggingLevel.WARN, 'lstIntPercent = ' + lstIntPercent + '; intLimit = ' + intLimit);
        
        return intLimit;
    }
    
    public void addTargetManagerToResponse(INTF_WebServicesDef.INTF_SFMResponse res, String svmxGrpProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addTargetManagerToResponse');
        
        Integer intLimitPercent = getSET011(svmxGrpProfileId);
        Integer intLimit = 1000;
        intLimit = calculateLimit(intLimitPercent);
        
        Set<String> setProcessTMIds = (set<string>)INTF_TxnCache.get('SET_PROCESS_TM', 'set<string>');
        
        if( callBackContext != NULL && callBackContext != '5' && strLastIdClause != ''){
                strLastIdClause = '';
        }
        
        string soqlProcessTM = prepareQuery(getFields_Process_TM());
        soqlProcessTM += ' from SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Target Manager\' AND ID IN: setProcessTMIds AND SVMXC__Dispatch_Process_Status__c = \'Complete\'';
        soqlProcessTM += strLastIdClause + ' Order By Id limit ' + intLimit;  //PIQ Process id not required as it will be cached
        
        system.debug(loggingLevel.WARN, 'Query Prepared for Process-Target Manager: ' + soqlProcessTM);
        INTF_DataSync.logSOQL(intMethodCount, soqlProcessTM);
        List<SVMXC__ServiceMax_Processes__c> lstProcessTM = database.query(soqlProcessTM);
        system.debug(loggingLevel.WARN, 'Process-Target Manager Queried: ' + lstProcessTM.size() + ' :: ' + lstProcessTM);
            
            //update limit
        if(lstProcessTM != NULL){
            intLimit -= lstProcessTM.size();
        }   
        system.debug(LoggingLevel.WARN, ' TM limit remaining = '+intLimit);
        
        /************************************For Translation*******************************************/
        if(lstProcessTM != null && lstProcessTM.size() > 0)
        {
                List<String> lstAllTags = new List<String>();
            for(SVMXC__ServiceMax_Processes__c SFMProcess : lstProcessTM)
                if(SFMProcess.SVMXC__Tag_Keys__c != NULL && SFMProcess.SVMXC__Tag_Keys__c.length() > 0)
                    lstAllTags.addAll(SFMProcess.SVMXC__Tag_Keys__c.split(';'));
        
            system.debug(loggingLevel.WARN, 'Trnslation Keys: ' + lstAllTags);
            translationObj = new I18N_TranslationDelivery(lstAllTags, UserInfo.getLanguage(), true);
            lstProcessTM = translationObj.SVMX_GetProcessTranslation(lstProcessTM);
            system.debug(loggingLevel.WARN, 'After Translation Process-Target Manager Queried: ' + lstProcessTM);
        }
        /****************************************************************************************************************/
            
            INTF_TxnCache.put('SFM_TRANSLATION_OBJ', translationObj, 'I18N_TranslationDelivery');
            
        for(SVMXC__ServiceMax_Processes__c processTM: lstProcessTM)
        {
            if(processTM.SVMXC__Doc_Template__c != null)
                setDocTemplateIds.add(processTM.SVMXC__Doc_Template__c);
            if(processTM.SVMXC__Page_Layout__c != null)
                setPageLayoutIds.add(processTM.SVMXC__Page_Layout__c);
        }
        
        system.debug(loggingLevel.WARN, 'setDocTemplateIds: ' + setDocTemplateIds.size());
        Set<String> setCachedDocTemplateIds = (set<string>)INTF_TxnCache.get('SET_DOC_TEMPLATE_ID', 'set<string>');
        if(setCachedDocTemplateIds != null && setCachedDocTemplateIds.size() > 0)
            setDocTemplateIds.addAll(setCachedDocTemplateIds);
        INTF_TxnCache.put('SET_DOC_TEMPLATE_ID', setDocTemplateIds, 'set<string>');
        system.debug(loggingLevel.WARN, 'setDocTemplateIds: ' + setDocTemplateIds.size());
        
        system.debug(loggingLevel.WARN, 'setPageLayoutIds: ' + setPageLayoutIds.size());
        Set<String> setCachedPageLayoutIds = (set<string>)INTF_TxnCache.get('SET_PAGELAYOUT_ID', 'set<string>');
        if(setCachedPageLayoutIds != null && setCachedPageLayoutIds.size() > 0)
            setPageLayoutIds.addAll(setCachedPageLayoutIds);
        INTF_TxnCache.put('SET_PAGELAYOUT_ID', setPageLayoutIds, 'set<string>');
        system.debug(loggingLevel.WARN, 'setPageLayoutIds: ' + setPageLayoutIds.size());
        
        //Check response size before adding to the response
        if((response_size + json.serialize(lstProcessTM).Length()) > responseSizeLimit && callBackContext != '5'){
            isBatch = TRUE;
            addCallBackContext(res,'5', NULL);  
            return;
        }
        addToResponse(res, lstProcessTM, 'SFM_TARGET_MANAGER');
            
        if(intLimit <= 0){
            isBatch = TRUE;
            addCallBackContext(res,'5', new List<String>{lstProcessTM[lstProcessTM.size() - 1].Id});  //CHANGE CONTEXT
        }
        
        //Clear Heap
        loggingForLimits('lstProcessTM', 'before');
        lstProcessTM.clear();
        loggingForLimits('lstProcessTM', 'after');
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addTargetManagerToResponse');
    }
    
    public void addLinkedProcessToResponse(INTF_WebServicesDef.INTF_SFMResponse res, String svmxGrpProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addLinkedProcessToResponse');
        
        Integer intLimitPercent = getSET011(svmxGrpProfileId);
        Integer intLimit = 1000;
        intLimit = calculateLimit(intLimitPercent);
        
        if( callBackContext != NULL && callBackContext != '3' && strLastIdClause != ''){
                strLastIdClause = '';
        }
        
        setProcessfromWizardSteps = (set<string>)INTF_TxnCache.get('SET_PROCESS_FROM_WIZARD_STEP', 'set<string>');
        
        string soqlProcessLinked = prepareQuery(getFields_Process_Linked());
        soqlProcessLinked += ' from SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Linked Process\'';        
        soqlProcessLinked += strLastIdClause + ' Order By Id limit ' + intLimit;
        
        system.debug(loggingLevel.WARN, 'Query Prepared for Process-Linked Processes: ' + soqlProcessLinked);
        
        INTF_DataSync.logSOQL(intMethodCount, soqlProcessLinked);
        List<SVMXC__ServiceMax_Processes__c> lstProcessLinked = database.query(soqlProcessLinked);
        system.debug(loggingLevel.WARN, 'Process-Linked Queried: ' + lstProcessLinked.size() + ' :: ' + lstProcessLinked);
        if(lstProcessLinked != NULL){
            intLimit -= lstProcessLinked.size();
        }
        system.debug(loggingLevel.WARN,'LP remaining is :'+intLimit);
        
        system.debug(loggingLevel.WARN, 'setProcessfromWizardSteps = ' + setProcessfromWizardSteps);
        for(SVMXC__ServiceMax_Processes__c lnkdPro: lstProcessLinked)
        {
            setProcessfromWizardSteps.add(lnkdPro.SVMXC__Process1__c);
            setProcessfromWizardSteps.add(lnkdPro.SVMXC__Process2__c);
            setProcessfromWizardSteps.add(lnkdPro.SVMXC__Process3__c);
        }
        INTF_TxnCache.put('SET_PROCESS_FROM_WIZARD_STEP', setProcessfromWizardSteps, 'set<string>');
        
        //Check response size before adding to the response
        if((response_size + json.serialize(lstProcessLinked).Length()) > responseSizeLimit && callBackContext != '3'){
            isBatch = TRUE;
            addCallBackContext(res,'3', NULL);  
            return;
        }
        addToResponse(res, lstProcessLinked, 'LINKED_SFM_PROCESS');
        
        if(intLimit <= 0){
            isBatch = TRUE;
            addCallBackContext(res,'3', new List<String>{lstProcessLinked[lstProcessLinked.size() - 1].Id});  
        }
            
            //Clear Heap
        loggingForLimits('lstProcessLinked', 'before');
        lstProcessLinked.clear();
        loggingForLimits('lstProcessLinked', 'after');
            
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addLinkedProcessToResponse');
    }
    
    public void addChecklistSmartDocToResponse(INTF_WebServicesDef.INTF_SFMResponse res, String svmxGrpProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addChecklistSmartDocToResponse');
        
        Integer intLimitPercent = getSET011(svmxGrpProfileId);
        Integer intLimit = 1000;
        intLimit = calculateLimit(intLimitPercent);
        
        Set<String> setProcessTMIds = (set<string>)INTF_TxnCache.get('SET_PROCESS_TM', 'set<string>');
        
        if( callBackContext != NULL && callBackContext != '6' && strLastIdClause != ''){
                strLastIdClause = '';
        }
        string soqlProcessCSD = prepareQuery(getFields_Process_CSD());
        soqlProcessCSD += ' from SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Checklist Smart Doc\' AND SVMXC__Process1__c IN: setProcessTMIds ';
        soqlProcessCSD += strLastIdClause + ' Order By Id limit ' + intLimit;
        
        system.debug(loggingLevel.WARN, 'Query Prepared for Process-Checklist Smart Doc: ' + soqlProcessCSD);
        
        INTF_DataSync.logSOQL(intMethodCount, soqlProcessCSD);
        List<SVMXC__ServiceMax_Processes__c> lstProcessCSD = database.query(soqlProcessCSD);
        system.debug(loggingLevel.WARN, 'Process-Checklist Smart Doc Queried: ' + lstProcessCSD.size() + ' :: ' + lstProcessCSD);
        
        //Check response size before adding to the response
        if((response_size + json.serialize(lstProcessCSD).Length()) > responseSizeLimit && callBackContext != '6'){
            isBatch = TRUE;
            addCallBackContext(res,'6', NULL);  
            return;
        }
        
        addToResponse(res, lstProcessCSD, 'CHECKLIST_SMART_DOC');
        //update limit
        if(intLimit != NULL){
            intLimit -= lstProcessCSD.size();
        }
        system.debug(LoggingLevel.WARN, ' CSD limit remaining = '+intLimit);
        
        if(intLimit <= 0){
                isBatch = TRUE;
                addCallBackContext(res,'6', new List<String>{lstProcessCSD[lstProcessCSD.size() - 1].Id});  //CHANGE CONTEXT
            }
            
            //Clear Heap
        loggingForLimits('addChecklistSmartDocToResponse', 'before');
        lstProcessCSD.clear();
        loggingForLimits('addChecklistSmartDocToResponse', 'after');
            
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addChecklistSmartDocToResponse');
    }   
    
    public void addPNOMetaToResponse(INTF_WebServicesDef.INTF_SFMResponse res, String svmxGrpProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addPNOMetaToResponse');
        
        Integer intLimitPercent = getSET011(svmxGrpProfileId);
        Integer intLimit = 1000;
        intLimit = calculateLimit(intLimitPercent);
        
        setProcessfromWizardSteps = (set<string>)INTF_TxnCache.get('SET_PROCESS_FROM_WIZARD_STEP', 'set<string>');
        isChecklist = (Boolean)INTF_TxnCache.get('CHECKLIST_FEATURE', 'Boolean');
        setChklstWizardObjs = (set<string>)INTF_TxnCache.get('SET_CHECKLIST_WIZARD_OBJ', 'set<string>');
        setExpressionIds = (set<string>)INTF_TxnCache.get('SET_EXPRESSION_ID', 'set<string>');
        setOfProcessToExclude = (set<string>)INTF_TxnCache.get('SET_PROCESS_EXCLUDE', 'set<string>');
        setPageLayoutsNotAccessible = (set<string>)INTF_TxnCache.get('SET_NON_ACCESSIBLE_PAGELAYOUT', 'set<string>');
        setDocTemplateNotAccessible = (set<string>)INTF_TxnCache.get('SET_NON_ACCESSIBLE_DOCTEMPLATE', 'set<string>');
            
        system.debug(loggingLevel.WARN, 'Checklist Feature ' + isChecklist + '; setProcessfromWizardSteps' + setProcessfromWizardSteps + '; setChklstWizardObjs = ' + setChklstWizardObjs);        
        set<String> allowedProcessPurpose = new set<String>{'VIEW RECORD','STANDALONE CREATE'};
        set<String> setChecklistProPurpose = new set<String>();
        set<String> setAssgndChklstProcess = new set<String>();
        if(isChecklist)
        {
            setChecklistProPurpose.add('CHECKLIST');
            setChklstWizardObjs.add('SVMXC__Checklist__c');
            INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: \'Service Flow Access\' AND SVMXC__Access_Configuration_Profile__c = :svmxGrpProfileId AND SVMXC__Dispatch_Process__c != null AND SVMXC__Dispatch_Process__r.SVMXC__Purpose__c IN :setChecklistProPurpose');
            for(SVMXC__ServiceMax_Config_Data__c eachAccessRec : [Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: 'Service Flow Access' AND SVMXC__Access_Configuration_Profile__c = :svmxGrpProfileId AND SVMXC__Dispatch_Process__c != null AND SVMXC__Dispatch_Process__r.SVMXC__Purpose__c IN :setChecklistProPurpose])
                setAssgndChklstProcess.add(eachAccessRec.SVMXC__Dispatch_Process__c);
        }
        system.debug(loggingLevel.WARN,' setChklstWizardObjs = ' + setChklstWizardObjs);
        set<string> setSFMProToFilter = new set<string>();
            set<String> allProcessPurpose = new set<String>{'STANDALONE EDIT','SOURCE TO TARGET ALL','SOURCE TO TARGET CHILD','OUTPUT DOCUMENT'};
            set<string> setPNOToExclude = new set<string>();
            if(nonAccessibleObjs != null && nonAccessibleObjs.size() > 0){
                string soqlProcessPNOToExclude = 'select id, SVMXC__Process__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Process Node Objects\' AND (SVMXC__Source_Object_Name__c IN: nonAccessibleObjs OR (SVMXC__Process__r.SVMXC__Purpose__c = \'OUTPUT DOCUMENT\' AND SVMXC__Process__r.SVMXC__Doc_Template__c = null) OR (SVMXC__Process__r.SVMXC__Purpose__c != \'OUTPUT DOCUMENT\' AND SVMXC__Process__r.SVMXC__Page_Layout__c = null))';
            INTF_DataSync.logSOQL(intMethodCount, soqlProcessPNOToExclude);
            for(SVMXC__ServiceMax_Processes__c pro: database.query(soqlProcessPNOToExclude)){
                if(pro.SVMXC__Process__c != null)
                    setPNOToExclude.add(pro.SVMXC__Process__c);
            }
        }
            
            string soqlProcessPNO = prepareQuery(getFields_Process_PNO());
            soqlProcessPNO += ' from SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Process Node Objects\' AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = \'Complete\' ';
            
            if(nonAccessibleObjs != null && nonAccessibleObjs.size() > 0){
                soqlProcessPNO += ' AND (SVMXC__Process__c NOT IN: setPNOToExclude)';
        }
            
            if(setOfProcessToExclude != null && setOfProcessToExclude.size() > 0 && setProcessfromWizardSteps != null && setProcessfromWizardSteps.size() > 0)
            soqlProcessPNO += ' AND ((((SVMXC__Process__r.SVMXC__Purpose__c IN: allProcessPurpose AND SVMXC__Process__c IN: setProcessfromWizardSteps) OR (SVMXC__Process__r.SVMXC__Purpose__c IN: allowedProcessPurpose AND SVMXC__Process__c NOT IN: setOfProcessToExclude) OR (SVMXC__Process__r.SVMXC__Purpose__c IN: allProcessPurpose AND SVMXC__Type__c = \'TARGET\' AND SVMXC__Source_Object_Name__c = \'Event\'))';
        else if(setOfProcessToExclude != null && setOfProcessToExclude.size() > 0 && (setProcessfromWizardSteps == null || setProcessfromWizardSteps.size() == 0))
            soqlProcessPNO += ' AND (((SVMXC__Process__r.SVMXC__Purpose__c IN: allProcessPurpose OR (SVMXC__Process__r.SVMXC__Purpose__c IN: allowedProcessPurpose AND SVMXC__Process__c NOT IN: setOfProcessToExclude))';
        else if(setProcessfromWizardSteps != null && setProcessfromWizardSteps.size() > 0 && (setOfProcessToExclude == null || setOfProcessToExclude.size() == 0))
            soqlProcessPNO += ' AND (((SVMXC__Process__r.SVMXC__Purpose__c IN: allowedProcessPurpose OR (SVMXC__Process__r.SVMXC__Purpose__c IN: allProcessPurpose AND SVMXC__Process__c IN: setProcessfromWizardSteps))';
        else
            soqlProcessPNO += ' AND (((SVMXC__Process__r.SVMXC__Purpose__c IN: allProcessPurpose OR SVMXC__Process__r.SVMXC__Purpose__c IN: allowedProcessPurpose)';
        if(setPageLayoutsNotAccessible != null && setPageLayoutsNotAccessible.size() > 0)
            soqlProcessPNO += ' AND (SVMXC__Process__r.SVMXC__Page_Layout__c NOT IN: setPageLayoutsNotAccessible)';
        if(setDocTemplateNotAccessible != null && setDocTemplateNotAccessible.size() > 0)
            soqlProcessPNO += ' AND (SVMXC__Process__r.SVMXC__Doc_Template__c = null OR SVMXC__Process__r.SVMXC__Doc_Template__c NOT IN: setDocTemplateNotAccessible)';
        if(filterstoExclude != null && filterstoExclude.sfms != null && filterstoExclude.sfms.size() > 0)
        {
            setSFMProToFilter.addAll(filterstoExclude.sfms);
            soqlProcessPNO += ' AND (SVMXC__Process__r.SVMXC__ProcessID__c NOT IN: setSFMProToFilter)';
        }
        soqlProcessPNO += ')';
        if(isChecklist)
            soqlProcessPNO += ' OR (SVMXC__Process__c IN:setAssgndChklstProcess AND SVMXC__Process__r.SVMXC__Purpose__c IN:setChecklistProPurpose)';
        
        //Download View processes for IB and location for PIQ
        Set<string> setPIQProcessIds = getProductIQProcesses();
        system.debug(LoggingLevel.WARN,'PIQ processes = '+setPIQProcessIds +'*** setPageLayoutsNotAccessible = '+setPageLayoutsNotAccessible);
        if(setPIQProcessIds != NULL && setPIQProcessIds.size() > 0){
            soqlProcessPNO += ' OR ((SVMXC__Process__c IN: setPIQProcessIds OR SVMXC__Process__r.SVMXC__ProcessID__c IN: setPIQProcessIds)';
            if(setPageLayoutsNotAccessible != NULL && setPageLayoutsNotAccessible.size() > 0){
                soqlProcessPNO += ' AND SVMXC__Process__r.SVMXC__Page_Layout__c NOT IN: setPageLayoutsNotAccessible';
            }
            soqlProcessPNO += ' ) ';
        }
        
        soqlProcessPNO += ')';
        
        if( callBackContext != NULL && callBackContext != '4' && strLastIdClause != ''){
                strLastIdClause = '';
        }
        soqlProcessPNO += strLastIdClause + ' Order By Id limit ' + intLimit;
        
            INTF_DataSync.logSOQL(intMethodCount, soqlProcessPNO);
        List<SVMXC__ServiceMax_Processes__c> lstProcessNodeObjects = database.query(soqlProcessPNO);
        system.debug(loggingLevel.WARN, 'Process Node Objects Queried: ' + lstProcessNodeObjects.size() + ' :: ' + lstProcessNodeObjects);
        //update limit
        if(lstProcessNodeObjects != NULL){
            intLimit -= lstProcessNodeObjects.size();
        }
        system.debug(LoggingLevel.WARN, ' PNO limit remaining = '+intLimit);
    
        //Retrive all other IDs from PNO
        set<string> setTMForPNOTarget = new set<string>();
        set<string> setTMToRemove = new set<string>();
        set<string> setChklstProcToremove = new set<string>();
        setTMToRemove.addAll(setProcessTMIds);
        system.debug(LoggingLevel.WARN, ' setMapIds = '+setMapIds);
    
            for(SVMXC__ServiceMax_Processes__c PNO: lstProcessNodeObjects){
                if(PNO.SVMXC__Type__c != NULL && (PNO.SVMXC__Type__c == 'TARGET' || PNO.SVMXC__Type__c == 'TARGETCHILD')){
                    if(PNO.SVMXC__Type__c == 'TARGET')
                    setProcessTMIds.add(PNO.SVMXC__Process__c); 
                if(PNO.SVMXC__Page_Layout__c != null || PNO.SVMXC__Doc_Template_Details__c != null)
                    setTMForPNOTarget.add(PNO.SVMXC__Process__c);
                if(PNO.SVMXC__Module__c != NULL)
                    setMapIds.add(PNO.SVMXC__Module__c);
                if(PNO.SVMXC__Final_Exception_Process__c != NULL)
                    setMapIds.add(PNO.SVMXC__Final_Exception_Process__c);
                if(PNO.SVMXC__Submodule__c != NULL)
                    setExpressionIds.add(PNO.SVMXC__Submodule__c);    
            }
            if(PNO.SVMXC__Type__c != null && PNO.SVMXC__Type__c == 'SOURCE' && setChecklistProPurpose.contains(PNO.SVMXC__Process__r.SVMXC__Purpose__c) && !setChklstWizardObjs.contains(PNO.SVMXC__Source_Object_Name__c))
                setChklstProcToremove.add(PNO.SVMXC__Process__c);
            }   
            
            if(setChklstProcToremove != null && setChklstProcToremove.size() > 0)
            setProcessTMIds.removeAll(setChklstProcToremove);   
            
            setTMToRemove.removeAll(setTMForPNOTarget);
        if(setTMToRemove != null && setTMToRemove.size() > 0)
            setProcessTMIds.removeAll(setTMToRemove);
        
        system.debug(loggingLevel.WARN, 'setProcessTMIds: ' + setProcessTMIds.size());
        Set<String> setProcessCachedTMIds = (set<string>)INTF_TxnCache.get('SET_PROCESS_TM', 'set<string>');
        if(setProcessCachedTMIds != null && setProcessCachedTMIds.size() > 0)
            setProcessTMIds.addAll(setProcessCachedTMIds);
        INTF_TxnCache.put('SET_PROCESS_TM', setProcessTMIds, 'set<string>');
        system.debug(loggingLevel.WARN, 'setProcessTMIds: ' + setProcessTMIds.size() + '; isBatch = ' + isBatch);    
            
        //Check response size before adding to the response
        if((response_size + json.serialize(lstProcessNodeObjects).Length()) > responseSizeLimit && callBackContext != '4'){
            isBatch = TRUE;
            addCallBackContext(res,'4', NULL);  
            return;
        }    
        addToResponse(res, lstProcessNodeObjects, 'SFM_PROCESS_NODE_OBJECT'); 
        
        INTF_TxnCache.put('SET_EXPRESSION_ID', setExpressionIds, 'set<string>');
        INTF_TxnCache.put('SET_MAP_ID', setMapIds, 'set<string>');
        
        
        if(intLimit <= 0){
            isBatch = TRUE;
            addCallBackContext(res,'4', new List<String>{lstProcessNodeObjects[lstProcessNodeObjects.size() - 1].Id});  //CHANGE CONTEXT
        }
            
            if(!isBatch)
        {
            system.debug(loggingLevel.WARN, 'In removing');
            INTF_TxnCache.remove('SET_PROCESS_EXCLUDE', 'set<string>');
            INTF_TxnCache.remove('SET_NON_ACCESSIBLE_PAGELAYOUT', 'set<string>');
            INTF_TxnCache.remove('SET_NON_ACCESSIBLE_DOCTEMPLATE', 'set<string>');
            INTF_TxnCache.remove('SET_PROCESS_FROM_WIZARD_STEP', 'set<string>');
            INTF_TxnCache.remove('SET_CHECKLIST_WIZARD_OBJ', 'set<string>');
        }
        
        //Clear Heap
        loggingForLimits('lstProcessNodeObjects', 'before');
        lstProcessNodeObjects.clear();
        loggingForLimits('lstProcessNodeObjects', 'after');
            
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addPNOMetaToResponse');
         
    } 
    
    public void addSFMWizardMetaToResponse(INTF_WebServicesDef.INTF_SFMResponse res, string svmxGrpProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addSFMWizardMetaToResponse');
        set<string> setOfWizardToExclude = new set<string>();
        set<string> setWizardProIdtoFilter = new set<string>();
        set<string> setSFMProIdtoFilter = new set<string>();
        set<string> setCustomActProIdtoFilter = new set<string>();
        set<string> setProcessCustomActionIds = new set<string>();
       
        INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: \'Wizard Access\' AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Dispatch_Process__c != null');
        List<SVMXC__ServiceMax_Config_Data__c> lstWizardAccess = [Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: 'Wizard Access' AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Dispatch_Process__c != null];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug(loggingLevel.WARN, 'Wizard Access: ' + lstWizardAccess + ' :: ' + lstWizardAccess.size());
        
        setOfWizardToExclude = getLstProcessesToExclude(lstWizardAccess, svmxGrpProfileId);
        system.debug(loggingLevel.WARN, 'Wizard to exclude: ' + setOfWizardToExclude + ' :: ' + setOfWizardToExclude.size());
        
        string soqlProcessWizards = prepareQuery(getFields_Process_Wizards());
        soqlProcessWizards += ' from SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Wizard\' AND SVMXC__Active__c = true';
        if(setOfWizardToExclude != null && setOfWizardToExclude.size() > 0)
            soqlProcessWizards += ' AND ID NOT IN: setOfWizardToExclude';
        if(nonAccessibleObjs != null && nonAccessibleObjs.size() > 0) 
            soqlProcessWizards += ' AND SVMXC__Source_Object_Name__c NOT IN: nonAccessibleObjs';
        if(filterstoExclude != null && filterstoExclude.wizards != null && filterstoExclude.wizards.size() > 0)
        {
            setWizardProIdtoFilter.addAll(filterstoExclude.wizards);
            soqlProcessWizards += ' AND SVMXC__ProcessID__c NOT IN: setWizardProIdtoFilter';
        }
        
        system.debug(loggingLevel.WARN, 'Query Prepared for Process Wizards: ' + soqlProcessWizards);
        INTF_DataSync.logSOQL(intMethodCount, soqlProcessWizards);
        List<SVMXC__ServiceMax_Processes__c> lstWizards = database.query(soqlProcessWizards);
        system.debug(loggingLevel.WARN, 'Process Wizards Queried: ' + lstWizards + ' :: ' + lstWizards.size());
        
        /************************************For Translation*******************************************/
        List<String> lstAllTags = new List<String>();
        for(SVMXC__ServiceMax_Processes__c SFMProcess : lstWizards)
            if(SFMProcess.SVMXC__Tag_Keys__c != NULL && SFMProcess.SVMXC__Tag_Keys__c.length() > 0)
                lstAllTags.addAll(SFMProcess.SVMXC__Tag_Keys__c.split(';'));  
        
        system.debug(loggingLevel.WARN, 'Trnslation Keys: ' + lstAllTags);
        I18N_TranslationDelivery translationObjW = new I18N_TranslationDelivery(lstAllTags, UserInfo.getLanguage(), true);
        lstWizards = translationObjW.SVMX_GetProcessTranslation(lstWizards);
        system.debug(loggingLevel.WARN, 'After Translation Process Wizards Queried: ' + lstWizards);
        /****************************************************************************************************************/
        INTF_TxnCache.put('WIZARD_TRANSLATION_OBJ', translationObjW, 'I18N_TranslationDelivery');
        
        /*********************************/
        for(SVMXC__ServiceMax_Processes__c eachWizard : lstWizards)
        {
            if(eachWizard.SVMXC__Submodule__c != null)
                setExpressionIds.add(eachWizard.SVMXC__Submodule__c);
        }
        /*********************************/
        addToResponse(res, lstWizards, 'SFM_WIZARD');
        
        string soqlProcessWizardSteps = prepareQuery(getFields_Process_WizardSteps());
        
        system.debug(loggingLevel.WARN, 'device type: ' + strDevice);
        soqlProcessWizardSteps += ' from SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Wizard Step\' AND SVMXC__Module__c != null AND (((SVMXC__Action_Type__c = \'SFM\' OR SVMXC__Action_Type__c = \'OUTPUT_DOCUMENT\') AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = \'Complete\') OR (SVMXC__Action_Type__c = \'OTHERS\' AND SVMXC__Process__c != null AND (SVMXC__Process__r.SVMXC__Custom_Action_Type__c = \'Web-Service\' OR SVMXC__Process__r.SVMXC__Custom_Action_Type__c = \'URL\' OR SVMXC__Process__r.SVMXC__Custom_Action_Type__c = \'App-to-App\')) OR (SVMXC__Action_Type__c = \'CHECKLIST\'))';
            
        if(lstWizards != null && lstWizards.size() > 0)
            soqlProcessWizardSteps += ' AND SVMXC__Module__c IN: lstWizards';
        
        system.debug(loggingLevel.WARN, 'Filters to be applied: ' + filterstoExclude);
        
        if(filterstoExclude != null && filterstoExclude.sfms != null && filterstoExclude.sfms.size() > 0)
        {
            setSFMProIdtoFilter.addAll(filterstoExclude.sfms);
            soqlProcessWizardSteps += ' AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN: setSFMProIdtoFilter';
        }
            
        if(filterstoExclude != null && filterstoExclude.sfactions != null && filterstoExclude.sfactions.size() > 0)
        {
            setCustomActProIdtoFilter.addAll(filterstoExclude.sfactions);
            soqlProcessWizardSteps += ' AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN: setCustomActProIdtoFilter';
        }
        
        system.debug(loggingLevel.WARN, 'Query Prepared for Wizard Steps: ' + soqlProcessWizardSteps);
        INTF_DataSync.logSOQL(intMethodCount, soqlProcessWizardSteps);
        List<SVMXC__ServiceMax_Processes__c> lstProcessWizardSteps = database.query(soqlProcessWizardSteps);
        system.debug(loggingLevel.WARN, 'Process Wizard Steps Queried: ' + lstProcessWizardSteps + ' :: ' + lstProcessWizardSteps.size());
        
        lstProcessWizardSteps = translationObjW.SVMX_GetProcessTranslation(lstProcessWizardSteps);
        system.debug(loggingLevel.WARN, 'After Translation Process Wizard Steps Queried: ' + lstProcessWizardSteps);
        
        addToResponse(res, lstProcessWizardSteps, 'SFM_WIZARD_STEP');
        
        for(SVMXC__ServiceMax_Processes__c WS : lstProcessWizardSteps)
        {
            if((WS.SVMXC__Action_Type__c == 'SFM' || WS.SVMXC__Action_Type__c == 'OUTPUT_DOCUMENT') && WS.SVMXC__Process__c != null){
                setProcessfromWizardSteps.add(WS.SVMXC__Process__c);
                if(WS.SVMXC__Process__r.SVMXC__Enable_Sub_Process__c && WS.SVMXC__Process__r.SVMXC__Process2__c != NULL){
                            system.debug(loggingLevel.WARN,'***** Sub process = '+WS.SVMXC__Process__r.SVMXC__Process2__c);
                        setProcessfromWizardSteps.add(WS.SVMXC__Process__r.SVMXC__Process2__c);
                 }
            }else if(WS.SVMXC__Action_Type__c == 'OTHERS' && WS.SVMXC__Process__c != null)
                setProcessCustomActionIds.add(WS.SVMXC__Process__c);
            else if(WS.SVMXC__Action_Type__c == 'CHECKLIST' && (WS.SVMXC__Process__c == null || WS.SVMXC__Process__c == '') && WS.SVMXC__Module__r.SVMXC__Source_Object_Name__c != null)
                setChklstWizardObjs.add(WS.SVMXC__Module__r.SVMXC__Source_Object_Name__c);    
            if(WS.SVMXC__Submodule__c != null && WS.SVMXC__Submodule__c != null)
                setExpressionIds.add(WS.SVMXC__Submodule__c);
        }
        
        string soqlConfigWizardLayout = prepareQuery(getFields_Config_WizardLayout());
        soqlConfigWizardLayout += ' from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = \'Wizard Layout\'';
        if(lstWizards != null && lstWizards.size() > 0)
            soqlConfigWizardLayout += ' AND SVMXC__Dispatch_Process__c IN: lstWizards';
        
        system.debug(loggingLevel.WARN, 'Query Prepared for Wizard Layouts: ' + soqlConfigWizardLayout);
        INTF_DataSync.logSOQL(intMethodCount, soqlConfigWizardLayout);
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigWizardLayouts = database.query(soqlConfigWizardLayout);
        system.debug(loggingLevel.WARN, 'Config-Wizard Layouts Queried: ' + lstConfigWizardLayouts + ' :: ' + lstConfigWizardLayouts.size());
        
        addToResponse(res, lstConfigWizardLayouts, 'SFM_WIZARD_LAYOUT');
        
        if(setProcessCustomActionIds != null && setProcessCustomActionIds.size() > 0)
        {
            string soqlProcessCustomActions = prepareQuery(getFields_Process_CustomActions());
            soqlProcessCustomActions += ' from SVMXC__ServiceMax_Processes__c where ID IN: setProcessCustomActionIds';
            
            if(filterstoExclude != null && filterstoExclude.sfactions != null && filterstoExclude.sfactions.size() > 0)
            {
                setCustomActProIdtoFilter.addAll(filterstoExclude.sfactions);
                soqlProcessCustomActions += ' AND SVMXC__ProcessID__c NOT IN: setCustomActProIdtoFilter';
            }
            
            system.debug(loggingLevel.WARN, 'Query Prepared for Custom Actions: ' + soqlProcessCustomActions);
            INTF_DataSync.logSOQL(intMethodCount, soqlProcessCustomActions);
            List<SVMXC__ServiceMax_Processes__c> lstProcessCustomActions = database.query(soqlProcessCustomActions);
            system.debug(loggingLevel.WARN, 'Process-Custom Actions Queried: ' + lstProcessCustomActions + ' :: ' + lstProcessCustomActions.size());
            
            addToResponse(res, lstProcessCustomActions, 'SFM_WIZARD_CUSTOM_ACTIONS');
            
            //Custom Actions-Parameters
            string strCustomActnParams = prepareQuery(getFldsCustomActionsParams());
            strCustomActnParams += ' from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN: setProcessCustomActionIds';
            
            system.debug(loggingLevel.WARN, 'Query Prepared for Custom Actions Parameters: ' + strCustomActnParams);
            INTF_DataSync.logSOQL(intMethodCount, strCustomActnParams);
            List<SVMXC__ServiceMax_Config_Data__c> lstCustomActnParams = database.query(strCustomActnParams);
            system.debug(loggingLevel.WARN, 'Process-Custom Actions Queried: ' + lstCustomActnParams + ' :: ' + lstCustomActnParams.size());
            
            addToResponse(res, lstCustomActnParams, 'SFM_WIZARD_CUSTOM_ACTIONS_PARAMS');
            
            loggingForLimits('addSFMWizardMetaToResponse', 'before');
            lstCustomActnParams.clear();
            lstProcessCustomActions.clear();
            loggingForLimits('addSFMWizardMetaToResponse', 'after');
        }
        
        if(lstProcessWizardSteps != null && lstProcessWizardSteps.size() > 0 && strDevice != 'iPhone')
        {
            string soqlSFMEvents = prepareQuery(getFields_SFMEvent());
            soqlSFMEvents += ' from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c IN : lstProcessWizardSteps';
            
            system.debug(loggingLevel.WARN, 'Query Prepared for SFM Events: ' + soqlSFMEvents);
            INTF_DataSync.logSOQL(intMethodCount, soqlSFMEvents);
            List<SVMXC__SFM_Event__c> lstSFMEvents = database.query(soqlSFMEvents);
            system.debug(loggingLevel.WARN, 'SFM Events Queried: ' + lstSFMEvents + ' :: ' + lstSFMEvents.size());
            
            addToResponse(res, lstSFMEvents, 'SFM_EVENT');
            lstSFMEvents.clear();
        }
        INTF_TxnCache.put('SET_PROCESS_FROM_WIZARD_STEP', setProcessfromWizardSteps, 'set<string>');
        INTF_TxnCache.put('SET_EXPRESSION_ID', setExpressionIds, 'set<string>');
        INTF_TxnCache.put('SET_CHECKLIST_WIZARD_OBJ', setChklstWizardObjs, 'set<string>');
        
        loggingForLimits('addSFMWizardMetaToResponse', 'before');
        lstWizards.clear();  //Clear heap 
        lstProcessWizardSteps.clear();  //Clear heap 
        lstConfigWizardLayouts.clear();  //Clear heap 
        loggingForLimits('addSFMWizardMetaToResponse', 'after');
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addSFMWizardMetaToResponse');
    }
    
    public void addCallBackContext(INTF_WebServicesDef.INTF_SFMResponse res, string callBackContext, List<String> lstLastId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addCallBackContext');
        system.debug(LoggingLevel.WARN, 'In AddCallBackContext : callBackContext = '+callBackContext +' ; lstLastId = '+lstLastId);
        INTF_WebServicesDef.SVMXMap callBackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK','TRUE');
        callBackVM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT',callBackContext, lstLastId));
        res.valueMap.add(callBackVM);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addCallBackContext');
    }
    
    public void addCallBackContextForLimit(INTF_WebServicesDef.INTF_SFMResponse res, string callBackContext, List<String> lstLastId, String queryLimit){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addCallBackContextForLimit');
        system.debug(LoggingLevel.WARN, 'In addCallBackContextForLimit = '+callBackContext +' ; lstLastId = '+lstLastId);
        INTF_WebServicesDef.SVMXMap callBackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK','TRUE');
        callBackVM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT',callBackContext, lstLastId));
        if(queryLimit != NULL)
                callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('QUERY_LIMIT',queryLimit));
        res.valueMap.add(callBackVM);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addCallBackContext');
    }
    
    public void addCallBackContextForExpressions(INTF_WebServicesDef.INTF_SFMResponse res, string callBackContext, List<String> lstExpLastId, List<String> lstExpDetailsLastId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addCallBackContextForExpressions');
        INTF_WebServicesDef.SVMXMap callBackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK','TRUE');
        callBackVM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT',callBackContext,null));
        callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('EXPRESSION_LASTID',callBackContext, lstExpLastId));
        callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('EXPRESSION_DETAILS_LASTID',callBackContext, lstExpDetailsLastId));
        res.valueMap.add(callBackVM);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addCallBackContextForExpressions');
    }
    /*public void addCallBackContextForSFMMeta(INTF_WebServicesDef.INTF_SFMResponse res, string callBackContext, List<string> lstLPLastId, List<string> lstPNOLastId, List<string> lstTMLastId, List<string> lstCSDLastId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addCallBackContextForSFMMeta');
        INTF_WebServicesDef.SVMXMap callBackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK','TRUE');
        callBackVM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
         
        callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT',callBackContext,null));
                  
        system.debug(LoggingLevel.WARN, ' lstPNOLastId = '+lstPNOLastId + '; lstTMLastId = '+lstTMLastId+'; lstCSDLastId = '+lstCSDLastId+'; lstLPLastId = '+ lstLPLastId);          
        callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('LINKED_PROCESS_LASTID',callBackContext, lstLPLastId));
        callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('PROCESS_PNO_LASTID',callBackContext, lstPNOLastId));
        callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('PROCESS_TM_LASTID',callBackContext, lstTMLastId));
        callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('PROCESS_CSD_LASTID',callBackContext, lstCSDLastId));
        res.valueMap.add(callBackVM);
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addCallBackContextForSFMMeta');
    }*/
    
    public boolean isLimitReach(INTF_WebServicesDef.INTF_SFMResponse res, string callBackContext){
        
        if(checkLimit(70)){
            system.debug(LoggingLevel.WARN, 'Limit has been reached');
            addCallBackContext(res,callBackContext, new List<String>());
            return true;    
        }
        else
            return false;
    }
    
    public boolean checkLimit(integer intLimitPercent){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('checkLimit');
        
        string svmxGrpProfileId = (string)INTF_TxnCache.get('GROUP_PROFILE_ID', 'string');
        if(svmxGrpProfileId == NULL || svmxGrpProfileId == ''){
            svmxGrpProfileId = getSVMXGrpProfileId(userinfo.getProfileId());
        }
        
        intLimitPercent = getSET011(svmxGrpProfileId);
        
        if(intLimitPercent <= 0)
            intLimitPercent = 70;
            
        system.debug(loggingLevel.WARN, 'SET011 = ' + intLimitPercent);
        integer limit_Heap = intLimitPercent * Limits.getLimitHeapSize()/100;
        integer limit_Queries = intLimitPercent * Limits.getLimitQueries()/100;
        integer limit_QueryRows = intLimitPercent * Limits.getLimitQueryRows()/100;
        integer limit_CPUTime = intLimitPercent * Limits.getLimitCpuTime()/100;
        system.debug(LoggingLevel.WARN, 'CPU Limit = ' + limit_CPUTime + '; Heap Limit = ' + limit_Heap + '; Query Limit = ' + limit_Queries);
        system.debug(LoggingLevel.WARN, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries());
        
        INTF_DataSync.logMethodEndTS(intMethodCount,'checkLimit');
        if(Limits.getHeapSize() >= limit_Heap || Limits.getQueries() >= limit_Queries || Limits.getQueryRows() >= limit_QueryRows || Limits.getCpuTime() >= limit_CPUTime || response_size > responseSizeLimit)
                return true;
        return false;
    }
    
    public boolean checkHeapLimit(integer intLimitPercent){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('checkHeapLimit');
        
        string svmxGrpProfileId = (string)INTF_TxnCache.get('GROUP_PROFILE_ID', 'string');
        if(svmxGrpProfileId == NULL || svmxGrpProfileId == ''){
            svmxGrpProfileId = getSVMXGrpProfileId(userinfo.getProfileId());
        }
        
        intLimitPercent = getSET011(svmxGrpProfileId);
        
        if(intLimitPercent <= 0)
            intLimitPercent = 70;
            
        system.debug(loggingLevel.WARN, 'SET011 = ' + intLimitPercent);
        integer limit_Heap = intLimitPercent * Limits.getLimitHeapSize()/100;
        integer limit_Queries = intLimitPercent * Limits.getLimitQueries()/100;
        integer limit_CPUTime = intLimitPercent * Limits.getLimitCpuTime()/100;
        system.debug(LoggingLevel.WARN, 'CPU Limit = ' + limit_CPUTime + '; Heap Limit = ' + limit_Heap + '; Query Limit = ' + limit_Queries);
        system.debug(LoggingLevel.WARN, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries());
        
        INTF_DataSync.logMethodEndTS(intMethodCount,'checkHeapLimit');
        if(Limits.getHeapSize() >= limit_Heap || Limits.getQueries() >= limit_Queries || Limits.getCpuTime() >= limit_CPUTime || response_size > responseSizeLimit)
                return true;
        return false;
    }
    
    public string getSVMXGrpProfileId(string sfdcProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getSVMXGrpProfileId');
        if(sfdcProfileId == null)
            sfdcProfileId = userinfo.getProfileId();
            
        INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c=\'Configuration Acces\' AND SVMXC__Profile__c =: sfdcProfileId AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c=\'Configuration Profile\' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c = \'Group\' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Active__c = true');
        List<SVMXC__ServiceMax_Config_Data__c> profileAccessLst = [SELECT Id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Configuration Access' AND SVMXC__Profile__c =: sfdcProfileId AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c='Configuration Profile' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Group' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Active__c = true];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug(loggingLevel.WARN, 'Configuration Access: ' + profileAccessLst + ' :: ' + profileAccessLst.size());
        
        if(profileAccessLst == null || profileAccessLst.size() == 0 || profileAccessLst.size() > 1)
        {
            INTF_DataSync.logMethodEndTS(intMethodCount, 'getSVMXGrpProfileId');
            return null;
        }
        /*if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', 'SVMXC__Access_Configuration_Profile__c', COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        else
        {*/
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getSVMXGrpProfileId');                
        return profileAccessLst[0].SVMXC__Access_Configuration_Profile__c;
        //}
    }
        
    public set<string> getNonAccessibleObjList(string sfdcProfileId){
        
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getNonAccessibleObjList');
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        allObjs = Schema.getGlobalDescribe();
        for(String objName : allObjs.keySet())
        {
            try
            {
                if(!allObjs.get(objName).getDescribe().isAccessible())
                    nonAccessibleObjs.add(allObjs.get(objName).getDescribe().getName());
                
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception for Object Name = ' + objName + ': ' + ex.getMessage());
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getNonAccessibleObjList');
        return nonAccessibleObjs;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getFSATags(INTF_WebServicesDef.INTF_SFMRequest req){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFSATags');
        
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        set<string> setModuleIds = new set<string>{'FSA','EVER', 'OFFL'};
        COMM_TagsDefinition tagDefinition = new COMM_TagsDefinition();
        INTF_WebServicesDef.SVMXMap fsaTagMap = new INTF_WebServicesDef.SVMXMap('FSA','');
        INTF_WebServicesDef.SVMXMap resultTagMap = new INTF_WebServicesDef.SVMXMap('LMAPI','');
        
        for(string subModule : setModuleIds){
            if(subModule == 'OFFL'){
                resultTagMap.valueMap.addAll(tagDefinition.fsaTagvalueCalc(subModule, true));
            }else{
                fsaTagMap.valueMap.addAll(tagDefinition.fsaTagvalueCalc(subModule, false));
            }
        }
        response.valueMap.add(fsaTagMap);
        response.valueMap.add(resultTagMap);
        
        response.eventName = req.eventName;
        response.eventType = req.eventType;
        response.success = true;
        INTF_DataSync.logMethodEndTS(intMethodCount,'getFSATags');
        return response;
    }
    
    public APFT_Schema.Filters getApplicationFilters(string strDevice){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getApplicationFilters');
        filterstoExclude = (APFT_Schema.Filters)INTF_TxnCache.get('APPLICATION_FILTERS', 'APFT_Schema.Filters');
        system.debug(loggingLevel.WARN, 'Filter to Exclude Object: ' + filterstoExclude);
        if(filterstoExclude == null){
            if(strDevice == null){
                strDevice = (string)INTF_TxnCache.get('DEVICE_NAME', 'string');
            }
            
            string strDeviceNameInFilter;
            if(strDevice == 'MFL')
                strDeviceNameInFilter = 'APPPRO006';
            else if(strDevice == 'iPad')
                strDeviceNameInFilter = 'APPPRO002';
            else if(strDevice == 'iPhone')
                strDeviceNameInFilter = 'APPPRO003';
            else if(strDevice == 'Android')
                strDeviceNameInFilter = 'APPPRO004';
            else if(strDevice == 'Android Tablet')
                strDeviceNameInFilter = 'APPPRO005';
            else
                strDeviceNameInFilter = 'APPPRO006';
            
            filterstoExclude = APFT_Utilities.getInstance().getDeviceFilters(strDeviceNameInFilter);
            INTF_TxnCache.put('APPLICATION_FILTERS', filterstoExclude, 'APFT_Schema.Filters');
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'getApplicationFilters');
        return filterstoExclude;
    }
    
    public void addMobileConfigMetaToResponse(INTF_WebServicesDef.INTF_SFMResponse res, string svmxGrpProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addMobileConfigMetaToResponse');
        system.debug(LoggingLevel.WARN,'Device type : '+strDevice);
        
        String strMobConfQuery = 'select SVMXC__Display_Type__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =: svmxGrpProfileId AND SVMXC__Display_Type__c != \'Download Criteria\' AND SVMXC__Display_Type__c != \'Advanced Download Criteria\' ';
        
        String strDevConfId = getDeviceMobileConfig(svmxGrpProfileId, strDevice);
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        system.debug(LoggingLevel.WARN,'Query formed = '+strMobConfQuery);
        INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
        List<SVMXC__ServiceMax_Config_Data__c> lstMobileConfig = Database.query(strMobConfQuery);
        system.debug(LoggingLevel.WARN,'lstMobileConfig = '+lstMobileConfig.size());
        
        addToResponse(res, lstMobileConfig, 'MOBILE_CONFIG');
        
        for(SVMXC__ServiceMax_Config_Data__c eachConf : lstMobileConfig)
        {
            if(eachConf.SVMXC__Display_Type__c == 'Enable Checklist' && eachConf.SVMXC__Internal_Value__c != null && eachConf.SVMXC__Internal_Value__c != '')
                isChecklist = Boolean.valueOf(eachConf.SVMXC__Internal_Value__c);
        }
        
        loggingForLimits('lstMobileConfig', 'before');
        lstMobileConfig.clear();  //Clear heap 
        loggingForLimits('lstMobileConfig', 'after');
        
        system.debug(LoggingLevel.WARN, 'Checklist feature = ' + isChecklist);
        INTF_TxnCache.put('CHECKLIST_FEATURE', isChecklist, 'Boolean');
        set<string> settingSubmoduleIds = new set<string>{'WORD005', 'GLOB001', 'PRODIQ002'};
        set<string> settingIds = new set<string>{'DCON001_SET052','INVT002_SET001'};
        set<string> settingModuleIds = new set<string>{'IPAD', 'SLAT'};
        
        List<SVMXC__ServiceMax_Config_Data__c> lstMobileDeviceSettings = getSettings(settingModuleIds, settingSubmoduleIds, settingIds, svmxGrpProfileId);
        //Filter it for Targeted sync
        if(!isTargetedSyncEnabled){
            for(SVMXC__ServiceMax_Config_Data__c eachSet : lstMobileDeviceSettings){
                    if(eachSet.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET019'){
                        if(eachSet.SVMXC__Internal_Value__c == 'Full Sync' || eachSet.SVMXC__Internal_Value__c == 'Smart Sync'){
                            eachSet.SVMXC__Internal_Value__c = 'True';
                        }else if( eachSet.SVMXC__Internal_Value__c == 'None'){
                            eachSet.SVMXC__Internal_Value__c = 'False';
                        }
                        break;
                    }
            }
        }
        addToResponse(res, lstMobileDeviceSettings, 'MOBILE_DEVICE_SETTINGS');
        
        loggingForLimits('lstMobileDeviceSettings', 'before');
        lstMobileDeviceSettings.clear();  //Clear heap 
        loggingForLimits('lstMobileDeviceSettings', 'after');
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addMobileConfigMetaToResponse');
    }
    
    public List<SVMXC__ServiceMax_Config_Data__c> getSettings(set<string> settingModuleIds, set<string> settingSubmoduleIds, set<string> settingIds, string svmxGrpProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getSettings');
        string soqlMobileDeviceSettings = 'select SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c=\'Setting Value\'';
        if(settingModuleIds != null && settingModuleIds.size() > 0)
        {
            soqlMobileDeviceSettings += ' AND (';
            integer i=0;
            for(string str: settingModuleIds)
            {
                if(i == 0)
                    soqlMobileDeviceSettings += 'SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c LIKE \'%' + str + '%\'';
                else
                    soqlMobileDeviceSettings += ' OR SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c LIKE \'%' + str + '%\'';
                i++;
            }
            if(settingSubmoduleIds != null && settingSubmoduleIds.size() > 0)
                soqlMobileDeviceSettings += ' OR SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c IN: settingSubmoduleIds';
            if(settingIds != null && settingIds.size() > 0)
                soqlMobileDeviceSettings += ' OR SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c IN: settingIds';
        }
        else if(settingSubmoduleIds != null && settingSubmoduleIds.size() > 0)
        {
            soqlMobileDeviceSettings += ' AND (SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c IN: settingSubmoduleIds';
            if(settingIds != null && settingIds.size() > 0)
                soqlMobileDeviceSettings += ' OR SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c IN: settingIds';
        }
        else if(settingIds != null && settingIds.size() > 0)
            soqlMobileDeviceSettings += ' AND (SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c IN: settingIds';
        
        if(svmxGrpProfileId != null && svmxGrpProfileId.length() > 0)
            soqlMobileDeviceSettings += ') AND (SVMXC__Setting_Configuration_Profile__c =: svmxGrpProfileId OR SVMXC__Setting_ID__r.SVMXC__Search_Order__c = \'Global\') AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true';
        else
            soqlMobileDeviceSettings += ') AND SVMXC__Setting_ID__r.SVMXC__Search_Order__c = \'Global\' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true';
        
        system.debug(loggingLevel.WARN, 'Query Prepared for Settings: ' + soqlMobileDeviceSettings);
        INTF_DataSync.logSOQL(intMethodCount , soqlMobileDeviceSettings);
        List<SVMXC__ServiceMax_Config_Data__c> lstSettings = database.query(soqlMobileDeviceSettings);
        system.debug(loggingLevel.WARN, 'Settings Queried: ' + lstSettings + ' :: ' + lstSettings.size());
        INTF_DataSync.logMethodEndTS(intMethodCount,'getSettings');
        return lstSettings;
    }
    
    public void addSourceUpdateMetaToResponse(INTF_WebServicesDef.INTF_SFMResponse res, set<string> setProcessTMIds){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addSourceUpdateMetaToResponse');
        
        string soqlConfigSourceUpdate = prepareQuery(getFields_Config_SourceUpdate());
        soqlConfigSourceUpdate += ' from SVMXC__ServiceMax_Config_Data__c where Recordtype.Name=\'Field Mapping\' AND SVMXC__Configuration_Type__c = \'Source Update\' AND SVMXC__Dispatch_Process__c IN: setProcessTMIds';
        system.debug(loggingLevel.WARN, 'Query Prepared for Config Source Updates: ' + soqlConfigSourceUpdate);
        INTF_DataSync.logSOQL(intMethodCount, soqlConfigSourceUpdate);
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigSourceUpdates = database.query(soqlConfigSourceUpdate);
        system.debug(loggingLevel.WARN, 'Config Source Updates Queried: ' + lstConfigSourceUpdates + ' :: ' + lstConfigSourceUpdates.size());
        //Check response size before adding to the response
        if((response_size + json.serialize(lstConfigSourceUpdates).Length()) > responseSizeLimit && callBackContext != '14'){
            isBatch = TRUE;
            addCallBackContext(res,'14', NULL);  
            return;
        }
        addToResponse(res, lstConfigSourceUpdates, 'SOURCE_UPDATE');
        
        loggingForLimits('addSourceUpdateMetaToResponse', 'before');
        lstConfigSourceUpdates.clear();  //Clear heap 
        loggingForLimits('addSourceUpdateMetaToResponse', 'after');
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addSourceUpdateMetaToResponse');
    }
    
    public void addDocTemplateMetaToResponse(INTF_WebServicesDef.INTF_SFMResponse res, set<String> setDocTemplateIds){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addDocTemplateMetaToResponse');
        
        string soqlDocTemplate = prepareQuery(getFields_Doc_Template());
        soqlDocTemplate += ' from SVMXC__Doc_Template__c where id IN: setDocTemplateIds';
        system.debug(loggingLevel.WARN, 'Query Prepared for Doc Templates: ' + soqlDocTemplate);
        INTF_DataSync.logSOQL(intMethodCount, soqlDocTemplate);
        List<SVMXC__Doc_Template__c> lstDocTemplates = database.query(soqlDocTemplate);
        system.debug(loggingLevel.WARN, 'Doc Templates Queried: ' + lstDocTemplates + ' :: ' + lstDocTemplates.size());
        //Check response size before adding to the response
        if((response_size + json.serialize(lstDocTemplates).Length()) > responseSizeLimit && callBackContext != '13'){
            isBatch = TRUE;
            addCallBackContext(res,'13', NULL);
            return;  
        }
        addToResponse(res, lstDocTemplates, 'DOC_TEMPLATE');
        
        string soqlDocTemplateDtls = prepareQuery(getFields_Doc_TemplateDtl());
        soqlDocTemplateDtls += ' from SVMXC__Doc_Template_Details__c where SVMXC__Doc_Template__c IN: setDocTemplateIds';
        system.debug(loggingLevel.WARN, 'Query Prepared for Doc Template Details: ' + soqlDocTemplateDtls);
        INTF_DataSync.logSOQL(intMethodCount, soqlDocTemplateDtls);
        List<SVMXC__Doc_Template_Details__c> lstDocTemplateDtls = database.query(soqlDocTemplateDtls);
        system.debug(loggingLevel.WARN, 'Doc Template Details Queried: ' + lstDocTemplateDtls + ' :: ' + lstDocTemplateDtls.size());
        if((response_size + json.serialize(lstDocTemplateDtls).Length()) > responseSizeLimit && callBackContext != '13'){
            isBatch = TRUE;
            addCallBackContext(res,'13', NULL);  
            return;
        }
        addToResponse(res, lstDocTemplateDtls, 'DOC_TEMPLATE_DETAIL');
        
        string soqlAttachments = prepareQuery(getFields_Attachment());
        soqlAttachments += ' from Attachment where ParentId IN: setDocTemplateIds';
        system.debug(loggingLevel.WARN, 'Query Prepared for Attachments: ' + soqlAttachments);
        INTF_DataSync.logSOQL(intMethodCount, soqlAttachments);
        List<Attachment> lstAttachments = database.query(soqlAttachments);
        system.debug(loggingLevel.WARN, 'Attachments Queried: ' + lstAttachments + ' :: ' + lstAttachments.size());
        if((response_size + json.serialize(lstAttachments).Length()) > responseSizeLimit && callBackContext != '13'){
            isBatch = TRUE;
            addCallBackContext(res,'13', NULL);
            return;  
        }
        addToResponse(res, lstAttachments, 'ATTACHMENTS');
        
        if(COMM_FileHandlerUtilities.checkFileSetting()){
            //Send Doc template that are stored as files only if GBL037 is TRUE
            String soqlDocLink = prepareQuery(getFields_ContentDocumentLink());
            soqlDocLink += ' from ContentDocumentLink where LinkedEntityID IN: setDocTemplateIds';
            system.debug(loggingLevel.WARN, 'Query Prepared for ContentDocumentLink: ' + soqlDocLink);
            INTF_DataSync.logSOQL(intMethodCount, soqlDocLink);
            List<ContentDocumentLink> lstLinks = database.query(soqlDocLink);
            system.debug(loggingLevel.WARN, 'ContentDocumentLink Queried: ' + lstLinks.size());
            if((response_size + json.serialize(lstLinks).Length()) > responseSizeLimit && callBackContext != '13'){
                isBatch = TRUE;
                addCallBackContext(res,'13', NULL);  
                return;
            }
            addToResponse(res, lstLinks, 'TEMPLATE_FILES');
            lstLinks.clear(); //clear the list after adding to response
        }
        
        loggingForLimits('addDocTemplateMetaToResponse', 'before');
        lstDocTemplates.clear();  //Clear heap 
        lstDocTemplateDtls.clear();   
        lstAttachments.clear(); 
        loggingForLimits('addDocTemplateMetaToResponse', 'after');
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addDocTemplateMetaToResponse');
    }
    
    public void addMapsMetaToResponse(INTF_WebServicesDef.INTF_SFMResponse res, set<string> setProcessIds){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addMapsMetaToResponse');
        
        if(setProcessIds ==  null || setProcessIds.size() == 0)
            return;
        
        string soqlMapProcess = prepareQuery(getFields_Process_Map());
        soqlMapProcess += ' from SVMXC__ServiceMax_Processes__c where ID IN: setProcessIds';
        system.debug(loggingLevel.WARN, 'Query Prepared for Maps: ' + soqlMapProcess);
        INTF_DataSync.logSOQL(intMethodCount, soqlMapProcess);
        List<SVMXC__ServiceMax_Processes__c> lstMaps = database.query(soqlMapProcess);
        system.debug(loggingLevel.WARN, 'Maps Queried: ' + lstMaps + ' :: ' + lstMaps.size());
        addToResponse(res, lstMaps, 'OBJECT_MAPPING');
        
        string soqlMapConfig = prepareQuery(getFields_Config_Map());
        soqlMapConfig += ' from SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c IN :setProcessIds and Recordtype.Name=\'Field Mapping\'';
        system.debug(loggingLevel.WARN, 'Query Prepared for Map Details: ' + soqlMapConfig);
        INTF_DataSync.logSOQL(intMethodCount, soqlMapConfig);
        List<SVMXC__ServiceMax_Config_Data__c> lstMapDetails = database.query(soqlMapConfig);
        system.debug(loggingLevel.WARN, 'Map Details Queried: ' + lstMapDetails + ' :: ' + lstMapDetails.size());
        
        addToResponse(res, lstMapDetails, 'OBJECT_MAPPING_DETAILS');
        
        loggingForLimits('addMapsMetaToResponse', 'before');
        lstMaps.clear();  //Clear heap 
        lstMapDetails.clear();  //Clear heap 
        loggingForLimits('addMapsMetaToResponse', 'after');
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addMapsMetaToResponse');
    }
   
    public void addExpsMetaToResponse(INTF_WebServicesDef.INTF_SFMResponse res, set<string> setProcessIds, string svmxGrpProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addExpsMetaToResponse');
       
        Set<String> setQueriedExpIds = new Set<String>(); 
        
        Integer intLimit = 1000;
        Integer intLimitPercent = getSET011(svmxGrpProfileId);
            
        intLimit = calculateLimit(intLimitPercent);
        if(intLimit <= 0){
            intLimit = 1;
        }
        system.debug(LoggingLevel.WARN, ' *** intLimit = '+intLimit);
        
        if(setProcessIds ==  null || setProcessIds.size() == 0)
            return;
        
        //Check if there is no callback for expression detail - it's the first call - start from parent expression
        if(strExpDetailsLastId == ''){
            string soqlExps = prepareQuery(getFields_Process_Exp());
            soqlExps += ' from SVMXC__ServiceMax_Processes__c where ID IN: setProcessIds';
    
            //Including LastId clause for callback
            soqlExps += strExpLastIdClause + ' Order BY ID LIMIT '+intLimit;
            
            system.debug(loggingLevel.WARN, 'Query Prepared for Exps: ' + soqlExps);
            INTF_DataSync.logSOQL(intMethodCount, soqlExps);
            List<SVMXC__ServiceMax_Processes__c> lstExps = database.query(soqlExps);
            
            //delete this variable: setQueriedExpIds
            
            system.debug(loggingLevel.WARN, 'Exps Queried: ' + lstExps + ' :: ' + lstExps.size());
        
            if(lstExps != NULL && lstExps.size() > 0){
                translationObj = (I18N_TranslationDelivery)INTF_TxnCache.get('SFM_TRANSLATION_OBJ', 'I18N_TranslationDelivery');
            
                Set<String> setCachedProcessTMIds = (set<string>)INTF_TxnCache.get('SET_PROCESS_TM', 'set<string>');
                system.debug(loggingLevel.WARN, '***setCachedProcessTMIds = '+setCachedProcessTMIds+'++++TranslationObject = '+translationObj);
                if(translationObj == NULL){  //Defect 037575 - If not found in Request_Cache, query it again
                    List<SVMXC__ServiceMax_Processes__c> lstTMProcesses = [select SVMXC__Tag_Keys__c from SVMXC__ServiceMax_Processes__c where Id IN : setCachedProcessTMIds]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    List<String> lstAllTags = new List<String>();
                    for(SVMXC__ServiceMax_Processes__c tmProcess: lstTMProcesses){
                        if(tmProcess.SVMXC__Tag_Keys__c != NULL && tmProcess.SVMXC__Tag_Keys__c.length() > 0)
                            lstAllTags.addall(tmProcess.SVMXC__Tag_Keys__c.split(';'));
                    }
                    translationObj = new I18N_TranslationDelivery(lstAllTags, UserInfo.getLanguage(), true);
                    loggingForLimits('lstTMProcesses', 'before');
                    lstTMProcesses.clear();  //Clear heap 
                    loggingForLimits('lstTMProcesses', 'after');
                }
                
                I18N_TranslationDelivery translationObjWizard = (I18N_TranslationDelivery)INTF_TxnCache.get('WIZARD_TRANSLATION_OBJ', 'I18N_TranslationDelivery');
                if(translationObjWizard == NULL){ //Defect 037575 - If not found in Request_Cache, query it again
                    List<SVMXC__ServiceMax_Processes__c> lstWizardSteps = [Select id,SVMXC__Module__r.SVMXC__Tag_Keys__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c IN: setCachedProcessTMIds]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    List<String> lstAllTags = new List<String>();
                    if(lstWizardSteps != NULL && !lstWizardSteps.isEmpty()){
                        for(SVMXC__ServiceMax_Processes__c wizStep: lstWizardSteps){
                            if(wizStep.SVMXC__Module__r.SVMXC__Tag_Keys__c != NULL && wizStep.SVMXC__Module__r.SVMXC__Tag_Keys__c.length() > 0)
                                lstAllTags.addAll(wizStep.SVMXC__Module__r.SVMXC__Tag_Keys__c.split(';'));
                        }
                    }
                    translationObjWizard = new I18N_TranslationDelivery(lstAllTags, UserInfo.getLanguage(), true);
                    loggingForLimits('ddExpsMetaToResponse - translated related tags queried - Wizard Steps', 'before');
                    lstWizardSteps.clear();  //Clear heap 
                    loggingForLimits('ddExpsMetaToResponse - translated related tags queried - Wizard Steps', 'after');
                }
                
                if(translationObj != NULL && translationObjWizard != NULL){
                    translationObj.mapSVMXTranslations.putall(translationObjWizard.mapSVMXTranslations);
                }
                
                system.debug(loggingLevel.WARN, 'Translation Object Wizard: ' + translationObjWizard);
                system.debug(loggingLevel.WARN, 'Translation Object: ' + translationObj);
                
                if(translationObj != null){
                    lstExps = translationObj.SVMX_GetProcessTranslation(lstExps);
                }
            }
            //Check response size before adding to the response
            if((response_size + json.serialize(lstExps).Length()) > responseSizeLimit && callBackContext != '8'){
                isBatch = TRUE;
                addCallBackContext(res,'8', NULL);
                return;  
            }
            addToResponse(res, lstExps, 'SFM_EXPRESSION'); //If it is a callback for exp detail, we do not send the expressions again; only if its not a callback we send it.
            
            //get remaining limit
            if(lstExps != NULL ){
                    intLimit = intLimit - lstExps.size();
            }
            
            if(intLimit <= 0){
                //limit has been hit while querying parent expressions --> set Expression last id
                addCallBackContextForExpressions(res, '8', new List<String>{lstExps[lstExps.size() - 1].Id}, NULL);
                isBatch = true;
            }else{
                //There is more limit remaining - query the expression details
                string soqlExpConfig = prepareQuery(getFields_Config_Exp());
                soqlExpConfig += ' from SVMXC__ServiceMax_Config_Data__c where (Recordtype.Name=\'Expressions\' OR Recordtype.Name = \'Field Updates\') AND (SVMXC__Expression_Type__c = \'EXP_Named\'  OR SVMXC__Expression_Type__c = \'Business_Rule\' OR SVMXC__Expression_Type__c = \'Field_Update_Rule\') And SVMXC__Expression_Rule__c IN :setProcessIds';
    
                //Including LastId clause for callback
                soqlExpConfig += strExpDetailsLastIdClause + ' Order BY ID LIMIT '+intLimit;
                
                system.debug(loggingLevel.WARN, 'Query Prepared for Exp Details: ' + soqlExpConfig);
                INTF_DataSync.logSOQL(intMethodCount, soqlExpConfig);
                List<SVMXC__ServiceMax_Config_Data__c> lstExpDetails = database.query(soqlExpConfig);
                system.debug(loggingLevel.WARN, 'Exp Details Queried: ' + lstExpDetails + ' :: ' + lstExpDetails.size());
                
                //Check response size before adding to the response
                if((response_size + json.serialize(lstExpDetails).Length()) > responseSizeLimit && callBackContext != '8'){
                    isBatch = TRUE;
                    addCallBackContext(res,'8', NULL); 
                    return;   
                }
                addToResponse(res, lstExpDetails, 'SFM_EXPRESSION_DETAILS');  //add the expression details in the response
        
                if(lstExpDetails != NULL){
                    intLimit = intLimit - lstExpDetails.size();
                }
                
                if(intLimit <= 0){
                    //there are more expressions to be processed - reset BusRule LastId and set Exp Last Id
                    addCallBackContextForExpressions(res, '8', NULL, new List<String>{lstExpDetails[lstExpDetails.size() - 1].Id});
                    isBatch = true;
                }
            }
            loggingForLimits('addExpsMetaToResponse - lstExps', 'before');
            lstExps.clear();
            loggingForLimits('addExpsMetaToResponse - lstExps', 'after');
        }else{
            //Callback was for Expression details - query them
            string soqlExpConfig = prepareQuery(getFields_Config_Exp());
            soqlExpConfig += ' from SVMXC__ServiceMax_Config_Data__c where (Recordtype.Name=\'Expressions\' OR Recordtype.Name = \'Field Updates\') AND (SVMXC__Expression_Type__c = \'EXP_Named\'  OR SVMXC__Expression_Type__c = \'Business_Rule\' OR SVMXC__Expression_Type__c = \'Field_Update_Rule\') And SVMXC__Expression_Rule__c IN :setProcessIds';

            //Including LastId clause for callback
            soqlExpConfig += strExpDetailsLastIdClause + ' Order BY ID LIMIT '+intLimit;
            
            system.debug(loggingLevel.WARN, 'Query Prepared for Exp Details: ' + soqlExpConfig);
            INTF_DataSync.logSOQL(intMethodCount, soqlExpConfig);
            List<SVMXC__ServiceMax_Config_Data__c> lstExpDetails = database.query(soqlExpConfig);
            system.debug(loggingLevel.WARN, 'Exp Details Queried: ' + lstExpDetails + ' :: ' + lstExpDetails.size());
                
            addToResponse(res, lstExpDetails, 'SFM_EXPRESSION_DETAILS');  //add the expression details in the response 
            
            if(lstExpDetails != NULL){
                intLimit = intLimit - lstExpDetails.size();
            }
            
            if(intLimit <= 0){
                //there are more expressions to be processed - reset BusRule LastId and set Exp Last Id
                addCallBackContextForExpressions(res, '8', NULL, new List<String>{lstExpDetails[lstExpDetails.size() - 1].Id});
                isBatch = true;
            }   
            
            loggingForLimits('lstExpDetails', 'before');
            lstExpDetails.clear();  //Clear heap 
            loggingForLimits('lstExpDetails', 'after');   
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addExpsMetaToResponse');
    } 
    
    public void addNamedSearchMetaToResponse(INTF_WebServicesDef.INTF_SFMResponse res, set<string> setProcessIds){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addNamedSearchMetaToResponse');
        
        if(setProcessIds ==  null || setProcessIds.size() == 0)
            return;
        
        string soqlLookupConfig = prepareQuery(getFields_Process_LookupConfig());
        soqlLookupConfig += ' from SVMXC__ServiceMax_Processes__c where  Recordtype.Name=\'Named Search\' AND SVMXC__Rule_Type__c = \'SRCH_LOOKUP_CONFIG\' AND ID IN: setProcessIds';
        system.debug(loggingLevel.WARN, 'Query Prepared for Named Search Lookup Config: ' + soqlLookupConfig);
        INTF_DataSync.logSOQL(intMethodCount, soqlLookupConfig);
        List<SVMXC__ServiceMax_Processes__c> lstLookupConfig = database.query(soqlLookupConfig);
        system.debug(loggingLevel.WARN, 'Named Search Lookup Config Queried: ' + lstLookupConfig + ' :: ' + lstLookupConfig.size());
        addToResponse(res, lstLookupConfig, 'NAMED_SEARCH');
        
        string soqlSearchObject = prepareQuery(getFields_Process_SearchObjectCriteria());
        soqlSearchObject += ' from SVMXC__ServiceMax_Processes__c where  Recordtype.Name=\'Named Search\' AND (SVMXC__Rule_Type__c = \'SRCH_OBJECT\' OR SVMXC__Rule_Type__c = \'SRCH_CRITERIA\') AND SVMXC__Module__c IN: setProcessIds';
        system.debug(loggingLevel.WARN, 'Query Prepared for Named Search-Search Object: ' + soqlSearchObject);
        INTF_DataSync.logSOQL(intMethodCount, soqlSearchObject);
        List<SVMXC__ServiceMax_Processes__c> lstSearchObject = database.query(soqlSearchObject);
        system.debug(loggingLevel.WARN, 'Named Search-Search Object Queried: ' + lstSearchObject + ' :: ' + lstSearchObject.size());
        addToResponse(res, lstSearchObject, 'SEARCH_OBJECT');
    
        string soqlLookupConfigDetail = prepareQuery(getFields_Config_LookupConfig());
        soqlLookupConfigDetail += ' from SVMXC__ServiceMax_Config_Data__c where Recordtype.Name = \'Expressions\' AND ((SVMXC__Expression_Type__c = \'SRCH_Object_Fields\' AND SVMXC__Search_Object_Field_Type__c != \'Bubble\') OR (SVMXC__Expression_Type__c =  \'LKUP_Prefilter_Criteria\') OR (SVMXC__Expression_Type__c = \'LKUP_Criteria\')) AND SVMXC__Expression_Rule__c IN : lstSearchObject';
        system.debug(loggingLevel.WARN, 'Query Prepared for Named Search-Detail: ' + soqlLookupConfigDetail);
        INTF_DataSync.logSOQL(intMethodCount, soqlLookupConfigDetail);
        List<SVMXC__ServiceMax_Config_Data__c> lstSearchObjectDtl = database.query(soqlLookupConfigDetail);
        system.debug(loggingLevel.WARN, 'Named Search-Detail Queried: ' + lstSearchObjectDtl + ' :: ' + lstSearchObjectDtl.size());
        for(SVMXC__ServiceMax_Config_Data__c sOD: lstSearchObjectDtl)
            sOD.SVMXC__Internal_Value__c = sOD.SVMXC__Expression_Rule__r.SVMXC__Module__c;
        addToResponse(res, lstSearchObjectDtl, 'SEARCH_OBJECT_DETAIL');
        
        loggingForLimits('addNamedSearchMetaToResponse', 'before');
        lstLookupConfig.clear();  //Clear heap
        lstSearchObject.clear();  //Clear heap 
        lstSearchObjectDtl.clear();  //Clear heap  
        loggingForLimits('addNamedSearchMetaToResponse', 'after');
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addNamedSearchMetaToResponse');
    }
    
    public void addQuestionMetaToResponse(INTF_WebServicesDef.INTF_SFMResponse res, set<string> setPageLayoutIds, String svmxGrpProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addQuestionMetaToResponse');
        if(setPageLayoutIds != null && setPageLayoutIds.size() > 0)
        {
            set<string> setQuestionIds = new set<string>();
            set<string> setResponseSetIds = new set<string>();
            
            Integer intLimit = 1000;
            Integer intProcessBizRuleLimit = 500 ;
            Integer intLimitPercent = getSET011(svmxGrpProfileId);
                
            intLimit = calculateLimit(intLimitPercent);
            system.debug(LoggingLevel.WARN, ' intLimit = ' + intLimit);
            if(intLimit <= 0)
                intLimit = 3;
            
            intLimit = intLimit/3;
            
            if(callbackQueryLimit != 0){
                intLimit = callbackQueryLimit;
            } 
            
            system.debug(loggingLevel.WARN, 'In Questions Meta: intLimit is ' + intLimit);
            system.debug(loggingLevel.WARN, 'In Questions Meta: pageLayoutIds are ' + setPageLayoutIds);
            
            if( callBackContext != NULL && callBackContext != '9' && strLastIdClause != ''){
                    strLastIdClause = '';
            }
            system.debug(loggingLevel.DEBUG, 'After Changes : strLastIdClause ' + strLastIdClause + '; callBackContext = '+callBackContext);
            
            INTF_DataSync.logSOQL(intMethodCount, 'select SVMXC__Question__c, SVMXC__Question__r.SVMXC__Response_Set__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN: setPageLayoutIds AND SVMXC__DataType__c = \'reference\' AND SVMXC__Detail_Type__c = \'Question\' ' + strLastIdClause + ' Order By ID Limit :intLimit');
            List<SVMXC__Page_Layout_Detail__c> lstPglayoutDtl = Database.query('select SVMXC__Question__c, SVMXC__Question__r.SVMXC__Response_Set__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN: setPageLayoutIds AND SVMXC__DataType__c = \'reference\' AND SVMXC__Detail_Type__c = \'Question\' ' + strLastIdClause + ' Order By ID Limit :intLimit');
                    
            //Check heap size and add callback
            if(checkHeapLimit(intLimitPercent)){
                system.debug(LoggingLevel.WARN, 'Apex Limit exceeded in context '+ callBackContext);
                if(callBackContext == '9'){   //Check if it is the current context
                    addCallBackContextForLimit(res,'9', new List<String>(), String.valueOf(intLimit/2) ); //Send the query limit number to be used in the next batch
                }else{
                    addCallBackContextForLimit(res,'9', new List<String>(), NULL);  //So that next batch will start from '9' with new set of governor limits
                }
                isBatch = true;
                return; 
             }else if( intLimit-lstPglayoutDtl.size() <= 0 ){  
                addCallBackContextForLimit(res, '9', new List<String>{lstPglayoutDtl[lstPglayoutDtl.size()-1].Id}, NULL);
                isBatch = true;
            }
                    
            for(SVMXC__Page_Layout_Detail__c eachPglayoutDtl : lstPglayoutDtl)
            {
                if(eachPglayoutDtl.SVMXC__Question__c != null)
                    setQuestionIds.add(eachPglayoutDtl.SVMXC__Question__c);
                if(eachPglayoutDtl.SVMXC__Question__r.SVMXC__Response_Set__c != null)
                    setResponseSetIds.add(eachPglayoutDtl.SVMXC__Question__r.SVMXC__Response_Set__c);
            }
            
            translationObj = (I18N_TranslationDelivery)INTF_TxnCache.get('SFM_TRANSLATION_OBJ', 'I18N_TranslationDelivery');
            
            system.debug(LoggingLevel.WARN, 'Number of Page layouts queried = ' + lstPglayoutDtl.size());
            system.debug(LoggingLevel.WARN, 'Number of QuestionIds = ' + setQuestionIds.size());
            
            loggingForLimits('addQuestionMetaToResponse - lstPglayoutDtl', 'before');
            lstPglayoutDtl.clear();  //Clear heap
            loggingForLimits('addQuestionMetaToResponse - lstPglayoutDtl', 'after');
            
            if(setQuestionIds != null && setQuestionIds.size() > 0)
            {
                string soqlQstns = prepareQuery(getFields_Questions());
                soqlQstns += ' from SVMXC__Question_Bank__c where ID IN: setQuestionIds';
                system.debug(loggingLevel.WARN, 'Query Prepared for Questions: ' + soqlQstns);
                INTF_DataSync.logSOQL(intMethodCount, soqlQstns);
                List<SVMXC__Question_Bank__c> lstQuestions = database.query(soqlQstns);
                system.debug(loggingLevel.WARN, 'Questions Queried: ' + lstQuestions.size() + ' :: ' + lstQuestions);
                
                //Caching the question Id Set
                Set<String> setCachedQuestionIds = (set<string>)INTF_TxnCache.get('SET_QUESTION_ID', 'set<string>');
                if(setCachedQuestionIds != NULL && setCachedQuestionIds.size() > 0){
                        setQuestionIds.addAll(setCachedQuestionIds);
                }
                system.debug(LoggingLevel.WARN,'Number of questions cached after = '+setQuestionIds.size());
                INTF_TxnCache.put('SET_QUESTION_ID', setQuestionIds, 'set<string>');
                
                //Defect 37575 - If not found in Request_Cache, query it again
                if(translationObj == NULL){
                    Set<String> setCachedProcessTMIds = (set<string>)INTF_TxnCache.get('SET_PROCESS_TM', 'set<string>');
                    List<SVMXC__ServiceMax_Processes__c> lstTMProcesses = [select SVMXC__Tag_Keys__c from SVMXC__ServiceMax_Processes__c where Id IN : setCachedProcessTMIds];
                    List<String> lstAllTags = new List<String>();
                    for(SVMXC__ServiceMax_Processes__c tmProcess: lstTMProcesses){
                        if(tmProcess.SVMXC__Tag_Keys__c != NULL && tmProcess.SVMXC__Tag_Keys__c.length() > 0)
                            lstAllTags.addAll(tmProcess.SVMXC__Tag_Keys__c.split(';'));
                    }
                    translationObj = new I18N_TranslationDelivery(lstAllTags, UserInfo.getLanguage(), true);
                    
                    loggingForLimits('addQuestionMetaToResponse', 'before');
                    lstTMProcesses.clear();  //Clear heap 
                    loggingForLimits('addQuestionMetaToResponse', 'after');
                }
                    
                if(translationObj != null){
                    lstQuestions = translationObj.SVMX_GetQuestionTranslation(lstQuestions);
                }
                //Check response size before adding to the response
                if((response_size + json.serialize(lstQuestions).Length()) > responseSizeLimit && callBackContext != '9'){
                    isBatch = TRUE;
                    addCallBackContext(res,'9', NULL); 
                    return;   
                }
                addToResponse(res, lstQuestions, 'QUESTION_BANK');
                
                loggingForLimits('addQuestionMetaToResponse', 'before');
                lstQuestions.clear();  //Clear heap
                loggingForLimits('addQuestionMetaToResponse', 'after');
                
            }
                
            system.debug(loggingLevel.WARN, 'Number of ResponseSetIds = ' + setResponseSetIds.size());
            if(setResponseSetIds != null && setResponseSetIds.size() > 0)
            {
                string soqlResponseSets = prepareQuery(getFields_ResponseSet());
                soqlResponseSets += ' from SVMXC__QB_Response_Set__c where ID IN :setResponseSetIds';
                system.debug(loggingLevel.WARN, 'Query Prepared for Response Set: ' + soqlResponseSets);
                INTF_DataSync.logSOQL(intMethodCount, soqlResponseSets);
                List<SVMXC__QB_Response_Set__c> lstMasterResponseSets = database.query(soqlResponseSets);
                system.debug(loggingLevel.WARN, 'Response Set Queried: ' + lstMasterResponseSets.size() + ' :: ' + lstMasterResponseSets);
                //adding the default values to the response
                
                if((response_size + json.serialize(lstMasterResponseSets).Length()) > responseSizeLimit && callBackContext != '9'){
                    isBatch = TRUE;
                    addCallBackContext(res,'9', NULL); 
                    return;   
                }
                addToResponse(res, lstMasterResponseSets, 'QB_RESPONSE_SET_MASTER');
                
                List<SVMXC__QB_Response_Set__c> lstResponseSets = lstMasterResponseSets.clone();
                if(translationObj != null){
                    lstResponseSets = translationObj.SVMX_GetQuestionResponseSetTranslation(lstResponseSets);
                    system.debug(loggingLevel.WARN, 'After Translation Response Set Queried: ' + lstResponseSets);
                }
                if((response_size + json.serialize(lstResponseSets).Length()) > responseSizeLimit && callBackContext != '9'){
                    isBatch = TRUE;
                    addCallBackContext(res,'9', NULL);
                    return;    
                }
                addToResponse(res, lstResponseSets, 'QB_RESPONSE_SET');
                
                loggingForLimits('addQuestionMetaToResponse', 'before');
                lstMasterResponseSets.clear(); 
                lstResponseSets.clear();  
                loggingForLimits('addQuestionMetaToResponse', 'after');
                
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addQuestionMetaToResponse');
    }
    
    public void addSFMSearchMetaToResponse(INTF_WebServicesDef.INTF_SFMResponse res, string svmxGrpProfileId, set<string> nonAccessibleObjs){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addSFMSearchMetaToResponse');
        
        set<string> setSFMSearchProcessIds = new set<string>();
        set<string> setOfSFMSearchToExclude = new set<string>(); 
        INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: \'Search Access\' AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Dispatch_Process__c != null');
        List<SVMXC__ServiceMax_Config_Data__c> lstSFMSearchAccess = [Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: 'Search Access' AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Dispatch_Process__c != null];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug(loggingLevel.WARN, 'SFM Search Access: ' + lstSFMSearchAccess + ' :: ' + lstSFMSearchAccess.size());
        
        setOfSFMSearchToExclude = getLstProcessesToExclude(lstSFMSearchAccess, svmxGrpProfileId);
        system.debug(loggingLevel.WARN, 'Before PIQ Setup SFM Search to exclude: ' + setOfSFMSearchToExclude + ' :: ' + setOfSFMSearchToExclude.size());
        
        //Set<String> setOfSearchNames = getProductIQSFMSearch(svmxGrpProfileId);
        Set<String> setOfSearchIds=getProductIQSFMSearch();
        
        system.debug(loggingLevel.WARN,'SFM Search from ProductIQ:'+setOfSearchIds);
        if(!setOfSearchIds.isEmpty())
        {
            INTF_DataSync.logSOQL(intMethodCount, 'Select Id From SVMXC__ServiceMax_Processes__c Where (Id in:setOfSearchIds OR SVMXC__ProcessID__c in:setOfSearchIds) AND Recordtype.Name =\'Named Search\' AND SVMXC__Rule_Type__c = \'SRCH_NAMED_SEARCH\'');
            List<SVMXC__ServiceMax_Processes__c> listOfProcess = [Select Id From SVMXC__ServiceMax_Processes__c Where (Id in:setOfSearchIds OR SVMXC__ProcessID__c in:setOfSearchIds) AND Recordtype.Name ='Named Search' AND SVMXC__Rule_Type__c ='SRCH_NAMED_SEARCH'];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            System.debug('What is the result '+listOfProcess);
            for(SVMXC__ServiceMax_Processes__c sfmProcess:listOfProcess)
            {
                if(setOfSFMSearchToExclude.contains(sfmProcess.Id))
                {
                    setOfSFMSearchToExclude.remove(sfmProcess.Id);
                }
            }
        }
        system.debug(loggingLevel.WARN, 'After PIQ Setup SFM Search to exclude: ' + setOfSFMSearchToExclude + ' :: ' + setOfSFMSearchToExclude.size());        
        string soqlSFMSearchObjProcess = prepareQuery(getFields_SFMSearch_ProcessObject());
        soqlSFMSearchObjProcess += ' from SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'Named Search\' AND SVMXC__Rule_Type__c = \'SRCH_OBJECT\'';
        if(setOfSFMSearchToExclude != null && setOfSFMSearchToExclude.size() > 0)
            soqlSFMSearchObjProcess += ' AND SVMXC__Module__c NOT IN: setOfSFMSearchToExclude';
        if(nonAccessibleObjs != null && nonAccessibleObjs.size() > 0)
            soqlSFMSearchObjProcess += ' AND SVMXC__Target_Object_Name__c NOT IN: nonAccessibleObjs';
        
        system.debug(loggingLevel.WARN, 'Query Prepared for SFM Search Objects: ' + soqlSFMSearchObjProcess);
        INTF_DataSync.logSOQL(intMethodCount, soqlSFMSearchObjProcess);
        List<SVMXC__ServiceMax_Processes__c> lstSFMSearchProcessObj = database.query(soqlSFMSearchObjProcess);
        system.debug(loggingLevel.WARN, 'SFM Search Objects Queried: ' + lstSFMSearchProcessObj + ' :: ' + lstSFMSearchProcessObj.size());
        
        if(lstSFMSearchProcessObj != null && lstSFMSearchProcessObj.size() > 0)
        {
            //addToResponse(res, lstSFMSearchProcessObj, 'SFM_SEARCH_PROCESS_OBJECTS');
            for(SVMXC__ServiceMax_Processes__c sfmProObj: lstSFMSearchProcessObj)
                setSFMSearchProcessIds.add(sfmProObj.SVMXC__Module__c);
            
            string soqlSFMSearchProcess = prepareQuery(getFields_SFMSearch_Process());
            soqlSFMSearchProcess += ' from SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'Named Search\' AND SVMXC__Rule_Type__c = \'SRCH_NAMED_SEARCH\'';
            if(setSFMSearchProcessIds != null && setSFMSearchProcessIds.size() > 0)
                soqlSFMSearchProcess += ' AND ID IN: setSFMSearchProcessIds';
            
            system.debug(loggingLevel.WARN, 'Query Prepared for SFM Search Process: ' + soqlSFMSearchProcess);
            INTF_DataSync.logSOQL(intMethodCount, soqlSFMSearchProcess);
            List<SVMXC__ServiceMax_Processes__c> lstSFMSearchProcess = database.query(soqlSFMSearchProcess);
            system.debug(loggingLevel.WARN, 'SFM Search Process Queried: ' + lstSFMSearchProcess + ' :: ' + lstSFMSearchProcess.size());
            
            List<String> lstAllTags = new List<String>();
            for(SVMXC__ServiceMax_Processes__c SFMProcess : lstSFMSearchProcess)
                if(SFMProcess.SVMXC__Tag_Keys__c != NULL && SFMProcess.SVMXC__Tag_Keys__c.length() > 0)
                    lstAllTags.addAll(SFMProcess.SVMXC__Tag_Keys__c.split(';'));
            
            system.debug(loggingLevel.WARN, 'Trnslation Keys: ' + lstAllTags);
            translationObj = new I18N_TranslationDelivery(lstAllTags, UserInfo.getLanguage(), true);
            lstSFMSearchProcess = translationObj.SVMX_GetProcessTranslation(lstSFMSearchProcess);
            
            addToResponse(res, lstSFMSearchProcess, 'SFM_SEARCH_PROCESS');
            
            //translation related changes for Search Object:-
            lstSFMSearchProcessObj = translationObj.SVMX_GetProcessTranslation(lstSFMSearchProcessObj);
            addToResponse(res, lstSFMSearchProcessObj, 'SFM_SEARCH_PROCESS_OBJECTS');
            
            string soqlSFMSearchDetail = prepareQuery(getFields_Config_SFMSearch());
            soqlSFMSearchDetail += ' from SVMXC__ServiceMax_Config_Data__c where Recordtype.Name=\'Expressions\' AND SVMXC__Search_Object_Field_Type__c != \'Bubble\' AND (SVMXC__Expression_Type__c = \'SRCH_Object_Fields\' OR SVMXC__Expression_Type__c = \'SRCH_Object_Prefilter_Criteria\')';
            if(setSFMSearchProcessIds != null && setSFMSearchProcessIds.size() > 0)
                soqlSFMSearchDetail += ' AND SVMXC__Expression_Rule__r.SVMXC__Module__c IN: setSFMSearchProcessIds';
            
            system.debug(loggingLevel.WARN, 'Query Prepared for SFM Search Details: ' + soqlSFMSearchDetail);
            INTF_DataSync.logSOQL(intMethodCount, soqlSFMSearchDetail);
            List<SVMXC__ServiceMax_Config_Data__c> lstSFMSearchDetails = database.query(soqlSFMSearchDetail);
            system.debug(loggingLevel.WARN, 'SFM Search Details Queried: ' + lstSFMSearchDetails + ' :: ' + lstSFMSearchDetails.size());
            addToResponse(res, lstSFMSearchDetails, 'SFM_SEARCH_DETAILS');
            
            loggingForLimits('addSFMSearchMetaToResponse', 'before');
            lstSFMSearchProcessObj.clear();  //Clear heap
            lstSFMSearchProcess.clear();  //Clear heap
            lstSFMSearchDetails.clear();  //Clear heap
            loggingForLimits('addSFMSearchMetaToResponse', 'after');
                
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addSFMSearchMetaToResponse');
    } 
    public void addQuesDefaultResponseToResponse(INTF_WebServicesDef.INTF_SFMResponse res, set<string> setQuestionIds, String svmxGrpProfileId ){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addQuesDefaultResponseToResponse');
        
        if(setQuestionIds != null && setQuestionIds.size() > 0){
            
            Integer intLimit = 1000;
            Integer intLimitPercent = getSET011(svmxGrpProfileId);
                intLimit = calculateLimit(intLimitPercent);
            
            if(intLimit <= 0){
                intLimit = 1;
            }
            
            if(callbackQueryLimit != 0){
                    intLimit = callbackQueryLimit;
            }
            
            string soqlDefResponse = prepareQuery(getFields_Default_Response());
            soqlDefResponse += ' from SVMXC__SM_Default_Checklist_Response__c where SVMXC__SM_Question__c IN: setQuestionIds';
            
            //Including last Id clause for callback
            if( callBackContext != NULL && callBackContext != '10' && strLastIdClause != ''){  //If callback wasn't in the same context, do not use the last Id for this context
                    strLastIdClause = '';
            }
            soqlDefResponse += strLastIdClause + ' Order By Id LIMIT '+intLimit;
            
            system.debug(loggingLevel.WARN, 'Query Prepared for Checklist Default Response: ' + soqlDefResponse);
            INTF_DataSync.logSOQL(intMethodCount, soqlDefResponse);
            List<SVMXC__SM_Default_Checklist_Response__c> lstDefaultChecklistRes = database.query(soqlDefResponse);
            
            system.debug(LoggingLevel.WARN, 'Checklist default response set is = '+lstDefaultChecklistRes);
            
            //Check heap size and add callback
            if(checkHeapLimit(intLimitPercent)){
                system.debug(LoggingLevel.WARN, 'Apex Limit exceeded in context '+ callBackContext);
                if(callBackContext == '10'){   //Check if it is the current context
                    addCallBackContextForLimit(res,'10', new List<String>(), String.valueOf(intLimit/2) ); //Send the query limit number to be used in the next batch
                }else{
                    addCallBackContextForLimit(res,'10', new List<String>(), NULL);  //So that next batch will start from '11' with new set of governor limits
                }
                isBatch = true;
                return; 
             }else if( intLimit-lstDefaultChecklistRes.size() <= 0 ){  
                addCallBackContextForLimit(res, '10', new List<String>{lstDefaultChecklistRes[lstDefaultChecklistRes.size()-1].Id}, NULL);
                isBatch = true;
            }
             
            //Translate the default answers list
            translationObj = (I18N_TranslationDelivery)INTF_TxnCache.get('SFM_TRANSLATION_OBJ', 'I18N_TranslationDelivery');
            
            if(translationObj == NULL){
                Set<String> setCachedProcessTMIds = (set<string>)INTF_TxnCache.get('SET_PROCESS_TM', 'set<string>');
                
                List<SVMXC__ServiceMax_Processes__c> lstTMProcesses = [select SVMXC__Tag_Keys__c from SVMXC__ServiceMax_Processes__c where Id IN : setCachedProcessTMIds];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<String> lstAllTags = new List<String>();
                for(SVMXC__ServiceMax_Processes__c tmProcess: lstTMProcesses){
                    if(tmProcess.SVMXC__Tag_Keys__c != NULL && tmProcess.SVMXC__Tag_Keys__c.length() > 0)
                        lstAllTags.addAll(tmProcess.SVMXC__Tag_Keys__c.split(';'));
                }
                translationObj = new I18N_TranslationDelivery(lstAllTags, UserInfo.getLanguage(), true);
                
                loggingForLimits('lstTMProcesses', 'before');
                lstTMProcesses.clear();  //Clear heap
                loggingForLimits('lstTMProcesses', 'after');
            }
                
            if(translationObj != null){
                lstDefaultChecklistRes = translationObj.SVMX_GetQuestionDefaultAnswerTranslation(lstDefaultChecklistRes);
            }
            //Check response size before adding to the response
            if((response_size + json.serialize(lstDefaultChecklistRes).Length()) > responseSizeLimit && callBackContext != '10'){
                    isBatch = TRUE;
                addCallBackContext(res,'10', NULL); 
                return;   
            }    
            addToResponse(res, lstDefaultChecklistRes, 'CHECKLIST_DEFAULT_RESPONSE'); //Add the queried record to response
                
            loggingForLimits('lstDefaultChecklistRes', 'before');
            lstDefaultChecklistRes.clear();  //Clear heap
            loggingForLimits('lstDefaultChecklistRes', 'after');
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addQuesDefaultResponseToResponse');
    }
    
    public void loggingForLimits(String methodName, String beforeOrAfter ){
            system.debug(loggingLevel.WARN, 'Heap size '+ beforeOrAfter + ' ' + methodName + ' = ' + Limits.getHeapSize());
    }
    
    public set<string> getLstProcessesToExclude(List<SVMXC__ServiceMax_Config_Data__c> lstSObjects, string svmxGrpProfileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getLstProcessesToExclude');
        set<string> setOfProcessToInclude = new set<string>();
        set<string> setOfProcessToExclude = new set<string>();
        
        for(SVMXC__ServiceMax_Config_Data__c access: lstSObjects)
        {
            if(svmxGrpProfileId == access.SVMXC__Access_Configuration_Profile__c)
                setOfProcessToInclude.add(access.SVMXC__Dispatch_Process__c);
            else
                setOfProcessToExclude.add(access.SVMXC__Dispatch_Process__c);
        }
        setOfProcessToExclude.removeAll(setOfProcessToInclude);
        system.debug(loggingLevel.WARN, 'Process to include: ' + setOfProcessToInclude + ' :: ' + setOfProcessToInclude.size());
        system.debug(loggingLevel.WARN, 'Process to exclude: ' + setOfProcessToExclude + ' :: ' + setOfProcessToExclude.size());
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getLstProcessesToExclude');
        return setOfProcessToExclude;
    }
    
    public void addToResponse(INTF_WebServicesDef.INTF_SFMResponse res, List<SObject> lstSObjects, string key){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addToResponse');
        if(lstSObjects == null || lstSObjects.size() == 0)
            return;
        INTF_WebServicesDef.SVMXMap objVM = new INTF_WebServicesDef.SVMXMap();
        objVM.key = key;
        objVM.value = JSON.serialize(lstSObjects);
        if(key == 'MOBILE_DEVICE_SETTINGS'){
                objVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('FILE_SUPPORTED', 'True'));  //new key for FSA to identify files_supported server version

                //Send API key based on device type
                system.debug(LoggingLevel.DEBUG,'Device type is : '+strDevice);
                String settingKey = '';
                if(strDevice == 'IPAD'){
                    settingKey = 'MAPS_API_KEY_FSA_IOS';
                }else if(strDevice == 'MFL' || strDevice == 'Windows'){
                    settingKey = 'MAPS_API_KEY_FSA_WINDOWS';
                }else if(strDevice == 'ANDROID TABLET'){
                    settingKey = 'MAPS_API_KEY_FSA_ANDROID';
                }
                SVMXC__ServiceMax_Properties__c csAPI = SVMXC__ServiceMax_Properties__c.getValues(settingKey);
                if(csAPI != NULL && csAPI.SVMXC__Value__c != NULL){
                    objVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('API_KEY_FSA', String.valueof(csAPI.SVMXC__Value__c)));
                }
        }
        res.valueMap.add(objVM);
        response_size += objVM.value.length();
        system.debug(LoggingLevel.WARN, 'Response size after '+ key +' = ' +response_size);
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addToResponse');
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse returnResponseWithMsg(boolean success, string msgType, string msg, INTF_WebServicesDef.INTF_SFMResponse res){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('returnResponseWithMsg');
        res.success = success;
        res.messageType = msgType;
        res.message = msg;
        INTF_DataSync.logMethodEndTS(intMethodCount, 'returnResponseWithMsg');
        return res;
    }
    
    public string prepareQuery(set<string> setFields){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('prepareQuery');
        if(setFields == null || setFields.size() == 0)
            return 'select id';
        string soqlPrepared;
        for(string fld: setFields)
        {
            if(fld != null && fld.length() > 0)
            {
                if(soqlPrepared == null || soqlPrepared.length() == 0)
                    soqlPrepared = 'select ' + fld;
                else
                    soqlPrepared += ', ' + fld;
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'prepareQuery');
        return soqlPrepared;
    }
    
    public set<string> getFields_Default_Response(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Default_Response');
        set<string> flds = new set<string>{'Id',
            'Name',
            'SVMXC__SM_Default_Response__c',
            'SVMXC__SM_Is_literal_Used__c',
            'SVMXC__SM_Question__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Default_Response');
        return flds;
    }
    
    public set<String> getFields_Process_CSD(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_CSD');
        set<string> flds = new set<string>{'Id',
            'Name',
            'SVMXC__Process1__c',
            'SVMXC__Process2__c',
            'SVMXC__SM_Checklist_Version__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_CSD');
        return flds;
    }
    
    public set<string> getFields_Process_Wizards(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_Wizards');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Name__c',
            'SVMXC__Description__c',
            'SVMXC__Active__c',
            'SVMXC__Submodule__c',
            'SVMXC__Source_Object_Name__c',
            'SVMXC__Parent_Error_Msg__c',
            'SVMXC__Child_Error_Msg__c',
            'SVMXC__Confirmation_Message__c',
            'SVMXC__Module__c',
            'SVMXC__Tag_Keys__c',
            'SVMXC__ProcessID__c'};
            //'SVMXC__Record_Type_Name__c',
            //'SVMXC__Rule_Type__c',
            //'SVMXC__Module__r.SVMXC__ProcessID__c'
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_Wizards');
        return flds;
    }
    
    public set<string> getFields_Process_WizardSteps(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_WizardSteps');
        set<string> flds = new set<string>{'Id',
        'SVMXC__Module__c',
        'SVMXC__Submodule__c',
        'SVMXC__Name__c',
        'SVMXC__Description__c',
        'SVMXC__Sequence__c',
        'SVMXC__Process__c',
        'SVMXC__Expertise_Match_Enabled__c',
        'SVMXC__Action_Type__c',
        'SVMXC__Parent_Error_Msg__c',
        'SVMXC__Child_Error_Msg__c',
        'SVMXC__Confirmation_Message__c',
        'SVMXC__ProcessID__c',
        'SVMXC__Module__r.SVMXC__ProcessID__c',
        //'SVMXC__Tag_Keys__c',
        'SVMXC__Record_Type_Name__c',
        //'SVMXC__Rule_Type__c',
        'SVMXC__Module__r.SVMXC__Source_Object_Name__c',
        'SVMXC__Mode_Of_Execution__c',
        'SVMXC__Process__r.SVMXC__Process2__c',   //Included to support Multisource SFM
        'SVMXC__Process__r.SVMXC__Enable_Sub_Process__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_WizardSteps');
        return flds;
    }
    
    public set<string> getFields_Process_TM(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_TM');
        set<string> flds = new set<string>{'Id',
            'SVMXC__ProcessID__c',
            'SVMXC__Doc_Template__c',
            'SVMXC__Purpose__c',
            'SVMXC__Name__c',
            'SVMXC__Page_Layout__c',
            'SVMXC__Description__c',
            'SVMXC__Parent_Error_Msg__c',
            'SVMXC__Child_Error_Msg__c',
            'SVMXC__Confirmation_Message__c',
            'SVMXC__Tag_Keys__c',
            'SVMXC__Module__c',
            'SVMXC__Record_Type_Name__c',
            //'SVMXC__Rule_Type__c',
            //'SVMXC__Module__r.SVMXC__ProcessID__c',
            'SVMXC__SM_Include_Skipped_Sections__c',
            'SVMXC__SM_Run_Targeted_Sync__c',
            'SVMXC__SM_Enable_Version_Control__c',
            'SVMXC__Enable_Sub_Process__c',
            'SVMXC__Sub_Process_Source_Field__c',
            'SVMXC__Process2__c',
            'SVMXC__SM_Exclude_Unanswered_Questions__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_TM');
        return flds;
    }
    
    public set<string> getFields_Process_PNO(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_PNO');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Process__c',
            'SVMXC__Type__c',
            'SVMXC__Page_Layout__c',
            'SVMXC__Source_Object_Name__c',
            'SVMXC__Target_Object_label__c',
            'SVMXC__Submodule__c',
            'SVMXC__Module__c',
            'SVMXC__Final_Exception_Process__c',
            'SVMXC__Sequence__c',
            'SVMXC__Node_Parent_API__c',
            'SVMXC__Node_Source_Object_API__c',
            'SVMXC__Node_Parent__c',
            'SVMXC__Parent_Object__c',
            'SVMXC__Parent_Column_Name__c',
            'SVMXC__Values__c',
            'SVMXC__Doc_Template_Details__c',
            'SVMXC__Enable_Attachment__c',
            //'SVMXC__Name__c',
            //'SVMXC__Description__c',
            //'SVMXC__Parent_Error_Msg__c',
            //'SVMXC__Child_Error_Msg__c',
            //'SVMXC__Confirmation_Message__c',
            //'SVMXC__Tag_Keys__c',
            //'SVMXC__ProcessID__c',
            //'SVMXC__Record_Type_Name__c',
            //'SVMXC__Rule_Type__c',
            //'SVMXC__Module__r.SVMXC__ProcessID__c',
            'SVMXC__Process__r.SVMXC__Purpose__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_PNO');
        return flds;
    }
    
    public set<string> getFields_Process_PBR(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_PBR');
        set<string> flds = new set<string>{'Id',
            'Name',
            'SVMXC__Process1__c',
            'SVMXC__Process2__c',
            'SVMXC__Process3__c',
            'SVMXC__Description__c',
            'SVMXC__Parent_Error_Msg__c',
            'SVMXC__Sequence__c',
            'SVMXC__Source_Object_Name__c',
            'SVMXC__Name__c',
            'SVMXC__Child_Error_Msg__c',
            'SVMXC__Confirmation_Message__c',
            'SVMXC__Module__c',
            //'SVMXC__ProcessID__c',
            //'SVMXC__Record_Type_Name__c',
            'SVMXC__Rule_Type__c',
            'SVMXC__SM_Section__c',
            //'SVMXC__Active__c',
            'SVMXC__SM_Target_Section__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_PBR');
        return flds;
    }
    
    public set<string> getFields_Process_Linked(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_Linked');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Process1__c',
            'SVMXC__Process2__c',
            'SVMXC__Process3__c',
            'SVMXC__Sequence__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_Linked');
        return flds;
    }
    
    public set<string> getFields_Process_CustomActions(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_CustomActions');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Name__c',
            'SVMXC__Description__c',
            //'SVMXC__ProcessID__c',
            'SVMXC__Custom_Action_Type__c',
            'SVMXC__Service_Class_Name__c',
            'SVMXC__Service_Method_Name__c',
            'SVMXC__Target_URL__c',
            'SVMXC__Sequence__c',
            'SVMXC__SM_Schema_Name__c',
            'SVMXC__SM_Path__c',
            'SVMXC__SM_Include_Object_Data_Set__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_CustomActions');
        return flds;
    }
    
    public set<string> getFldsCustomActionsParams(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFldsCustomActionsParams');
        set<string> flds = new set<string>{'Id',
            'Name',
            'SVMXC__Action_Type__c',
            'SVMXC__Dispatch_Process__c',
            'SVMXC__Parameter_Name__c',
            'SVMXC__Parameter_Type__c',
            'SVMXC__Object_Name2__c',
            'SVMXC__Lookup_Field_API_Name__c',
            'SVMXC__Parameter_Value__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFldsCustomActionsParams');
        return flds;
    }
    
    public set<string> getFields_SFMSearch_ProcessObject(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_SFMSearch_ProcessObject');
        set<string> flds = new set<string>{'Id',
            'SVMXC__ProcessID__c',
            'SVMXC__Target_Object_Name__c',
            'SVMXC__Module__c',
            'SVMXC__Advance_Expression__c',
            'SVMXC__Parent_Object_Criteria__c',
            'SVMXC__Sequence__c',
            'SVMXC__Name__c',
            'SVMXC__Description__c',
            'SVMXC__Parent_Error_Msg__c',
            'SVMXC__Child_Error_Msg__c',
            'SVMXC__Confirmation_Message__c',
            'SVMXC__Tag_Keys__c',
            'SVMXC__Record_Type_Name__c',
            'SVMXC__Rule_Type__c',
            'SVMXC__Module__r.SVMXC__ProcessID__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_SFMSearch_ProcessObject');
        return flds;
    }
    
    public set<string> getFields_SFMSearch_Process(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_SFMSearch_Process');
        set<string> flds = new set<string>{'Id',
            'Name',
            'SVMXC__Rule_Type__c',
            'SVMXC__ProcessID__c',
            'SVMXC__Name__c',
            'SVMXC__Description__c',
            'SVMXC__Number_of_Lookup_Records__c',
            'SVMXC__IsStandard__c',
            'SVMXC__Active__c',
            'SVMXC__IsDefault__c',
            'SVMXC__Parent_Error_Msg__c',
            'SVMXC__Child_Error_Msg__c',
            'SVMXC__Confirmation_Message__c',
            'SVMXC__Tag_Keys__c',
            'SVMXC__Module__c',
            'SVMXC__Record_Type_Name__c',
            'SVMXC__Module__r.SVMXC__ProcessID__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_SFMSearch_Process');
        return flds;
    }
    
    public set<string> getFields_Process_Map(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_Map');
        set<string> flds = new set<string>{'Id',
            'SVMXC__MapID__c',
            'SVMXC__Source_Object_Name__c',
            'SVMXC__Target_Object_Name__c'};
            //'SVMXC__Name__c',
            //'SVMXC__Description__c',
            //'SVMXC__Parent_Error_Msg__c',
            //'SVMXC__Child_Error_Msg__c',
            //'SVMXC__Confirmation_Message__c',
            //'SVMXC__Tag_Keys__c',
            //'SVMXC__Module__c',
            //'SVMXC__ProcessID__c',
            //'SVMXC__Record_Type_Name__c',
            //'SVMXC__Rule_Type__c',
            //'SVMXC__Module__r.SVMXC__ProcessID__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_Map');
        return flds;
    }
    
    public set<string> getFields_Process_Exp(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_Exp');
        set<string> flds = new set<string>{'Id',
            'Name',
            'SVMXC__ProcessID__c',
            'SVMXC__Source_Object_Name__c',
            'SVMXC__Advance_Expression__c',
            'SVMXC__Message_Type__c',
            'SVMXC__Values__c',
            'SVMXC__Sequence__c',
            'SVMXC__Name__c',
            'SVMXC__Description__c',
            'SVMXC__Parent_Error_Msg__c',
            'SVMXC__Child_Error_Msg__c',
            'SVMXC__Confirmation_Message__c',
            //'SVMXC__Tag_Keys__c',
            'SVMXC__Module__c',
            'SVMXC__Rule_Type__c',
            //'SVMXC__Record_Type_Name__c',
            //'SVMXC__Module__r.SVMXC__ProcessID__c',
            'SVMXC__Question_Bank__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_Exp');
        return flds;
    }
    
    public set<string> getFields_Questions(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Questions');
        set<string> flds = new set<string>{'Id',
            'Name',
            'SVMXC__Question__c',
            'SVMXC__QuestionID__c',
            'SVMXC__Response_Type__c',
            'SVMXC__Scale__c',
            'SVMXC__Length__c',
            'SVMXC__Precision__c',
            'SVMXC__Response_Set__c',
            'SVMXC__Help_URL__c',
            'SVMXC__SM_Show_In_Smart_Doc__c',
            'SVMXC__SM_Description_Required__c'
            };
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Questions');
        return flds;
    }
    
    public set<string> getFields_ResponseSet(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_ResponseSet');
        set<string> flds = new set<string>{'Id',
            'Name',
            'SVMXC__Response_Set_Values__c'
            };
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_ResponseSet');
        return flds;
    }
    
    public set<string> getFields_Process_LookupConfig(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_LookupConfig');
        set<string> flds = new set<string>{'Id',
            'SVMXC__ProcessID__c',
            'SVMXC__Name__c',
            'SVMXC__IsStandard__c',
            'SVMXC__Rule_Type__c',
            'SVMXC__IsDefault__c',
            'SVMXC__Number_of_Lookup_Records__c',
            'SVMXC__Default_Lookup_Column__c',
            'SVMXC__Source_Object_Name__c',
            'SVMXC__Sequence__c',
            'SVMXC__Process__c'};
            //'SVMXC__Description__c',
            //'SVMXC__Parent_Error_Msg__c',
            //'SVMXC__Child_Error_Msg__c',
            //'SVMXC__Confirmation_Message__c',
            //'SVMXC__Tag_Keys__c',
            //'SVMXC__Module__c',
            //'SVMXC__Record_Type_Name__c',
            //'SVMXC__Module__r.SVMXC__ProcessID__c'
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_LookupConfig');
        return flds;
    }
    
    public set<string> getFields_Process_SearchObjectCriteria(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Process_SearchObjectCriteria');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Name__c',
            'SVMXC__Default_On__c',
            'SVMXC__Rule_Type__c',
            'SVMXC__Field_Name__c',
            'SVMXC__Allow_Override__c',
            'SVMXC__Advance_Expression__c',
            'SVMXC__Parent_Object_Criteria__c',
            'SVMXC__Source_Object_Name__c',
            'SVMXC__Sequence__c',
            'SVMXC__Module__c',
            'SVMXC__Description__c'};
            //'SVMXC__Parent_Error_Msg__c',
            //'SVMXC__Child_Error_Msg__c',
            //'SVMXC__Confirmation_Message__c',
            //'SVMXC__Tag_Keys__c',
            //'SVMXC__ProcessID__c',
            //'SVMXC__Record_Type_Name__c',
            //'SVMXC__Module__r.SVMXC__ProcessID__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Process_SearchObjectCriteria');
        return flds;
    }
    
    public set<string> getFields_Config_LookupConfig(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Config_LookupConfig');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Internal_Value__c',
            'SVMXC__Field_Name__c',
            'SVMXC__Search_Object_Field_Type__c',
            'SVMXC__Sequence__c',
            'SVMXC__Field_Relationship_Name__c',
            'SVMXC__Display_Type__c',
            'SVMXC__Expression_Type__c',
            'SVMXC__Parameter_Type__c',
            'SVMXC__Operator__c',
            'SVMXC__Operand__c',
            'SVMXC__Object_Name__c',
            'SVMXC__FKey_Name_Field__c',
            'SVMXC__Expression_Rule__c',
            'SVMXC__Expression_Rule__r.SVMXC__Module__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Config_LookupConfig');
        return flds;
    }
    
    public set<string> getFields_Config_Map(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Config_Map');
        set<string> flds = new set<string>{'Id',
            'SVMXC__MapID__c',
            'SVMXC__Source_Field_Name__c',
            'SVMXC__Target_Field_Name__c',
            'SVMXC__Preference_2__c',
            'SVMXC__Preference_3__c',
            'SVMXC__Display_Value__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Config_Map');
        return flds;
    }
    
    public set<string> getFields_Config_Exp(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Config_Exp');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Expression_Rule__c',
            'SVMXC__Field_Name__c',
            'SVMXC__Operator__c',
            'SVMXC__Operand__c',
            'SVMXC__Display_Type__c',
            'SVMXC__Sequence__c',
            'SVMXC__Parameter_Type__c',
            'SVMXC__Expression_Type__c',
            'SVMXC__Formula__c',
            'SVMXC__Action_Type__c',
            'SVMXC__Description__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Config_Exp');
        return flds;
    }
    
    public set<string> getFields_Config_SFMSearch(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Config_SFMSearch');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Search_Object_Field_Type__c',
            'SVMXC__Expression_Rule__c',
            'SVMXC__Object_Name__c',
            'SVMXC__Object_Name2__c',
            'SVMXC__Field_Name__c',
            'SVMXC__Sequence__c',
            'SVMXC__Display_Type__c',
            'SVMXC__Lookup_Field_API_Name__c',
            'SVMXC__Field_Relationship_Name__c',
            'SVMXC__Sort_Order__c',
            'SVMXC__Display_Type__c',
            'SVMXC__Expression_Type__c',
            'SVMXC__Operator__c',
            'SVMXC__Operand__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Config_SFMSearch');
        return flds;
    }
    
    public set<string> getFields_Config_WizardLayout(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Config_WizardLayout');
        set<string> flds = new set<string>{'Id',
            //'SVMXC__Object_Name__c',
            //'SVMXC__Button_Size__c',
            'SVMXC__Dispatch_Process__c',
            'SVMXC__Wizard_Layout_Column__c',
            'SVMXC__Wizard_Layout_Row__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Config_WizardLayout');
        return flds;
    }
    
    public set<string> getFields_SFMEvent(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_SFMEvent');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Sequence__c',
            'SVMXC__ServiceMax_Process__c',
            'SVMXC__Target_Call__c',
            'SVMXC__Event_Call_Type__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_SFMEvent');
        return flds;
    }
    
    public set<string> getFields_Config_SourceUpdate(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Config_SourceUpdate');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Setting_ID__c',
            'SVMXC__Action__c',
            'SVMXC__Display_Value__c',
            'SVMXC__Configuration_Type__c',
            'SVMXC__Target_Field_Name__c',
            'SVMXC__Source_Field_Name__c',
            'SVMXC__SM_Question__c',
            'SVMXC__Dispatch_Process__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Config_SourceUpdate');
        return flds;
    }
    
    public set<string> getFields_Doc_Template(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Doc_Template');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Name__c',
            'SVMXC__Template_Id__c',
            'SVMXC__Media_Resources__c',
            'SVMXC__IsStandard__c',
            'SVMXC__Detail_Object_Count__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Doc_Template');
        return flds;
    }
    
    public set<string> getFields_Doc_TemplateDtl(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Doc_TemplateDtl');
        set<string> flds = new set<string>{'Id',
            'SVMXC__Doc_Template__c',
            'SVMXC__Doc_Template_Detail_Unique_Id__c',
            'SVMXC__Alias__c',
            'SVMXC__Doc_Template_Detail_Id__c',
            'SVMXC__Fields__c',
            'SVMXC__Header_Reference_Field__c',
            'SVMXC__Object_Name__c',
            'SVMXC__SOQL__c',
            'SVMXC__Type__c'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Doc_TemplateDtl');
        return flds;
    }
    
    public set<string> getFields_Attachment(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_Attachment');
        set<string> flds = new set<string>{'Id',
            'Name',
            'ParentId'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_Attachment');
        return flds;
    }
    
    public set<string> getFields_ContentDocumentLink(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getFields_ContentDocumentLink');
        set<string> flds = new set<string>{'Id',
            'LinkedEntityId',
            'ContentDocumentId',
            'ContentDocument.LatestPublishedVersionId',
            'ContentDocument.LatestPublishedVersion.Title'};
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getFields_ContentDocumentLink');
        return flds;
    }
    
    public string getNoSVMXGrpProfileError(){return  system.label.IPAD015_TAG011;}
    
    public String getDeviceName(INTF_WebServicesDef.INTF_SFMRequest request)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getDeviceName');
        String strDeviceName;
        if(request.clientInfo != null && request.clientInfo.size() > 0)
        {
            for(INTF_WebServicesDef.SVMXClient clientInform : request.clientInfo)
            {
                if(clientInform.clientType != null)
                {
                    strDeviceName = clientInform.clientType;
                    break;
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getDeviceName');
        return strDeviceName;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getObjectDef(INTF_WebServicesDef.INTF_SFMRequest req){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getObjectDef');
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        res.eventName = req.eventName;
        res.eventType = req.eventType;
        res.success = true;
        res.values = new list<string>();
        res.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap objDefVM = new INTF_WebServicesDef.SVMXMap('OBJECT_DEFINITION','');
        objDefVM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        //INTF_TxnCache.restore(req.value);
        mapClientDetails = getClientData(req);
        INTF_TxnCache.restore(mapClientDetails, req.value);
        Set<String> setObjNames = new Set<String>(req.values);
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Map<String, Set<String>> mapObjToPicklistFields = new Map<String, Set<String>>();
        
        string svmxGrpProfileId = (string)INTF_TxnCache.get('GROUP_PROFILE_ID', 'string');
        if(svmxGrpProfileId == NULL || svmxGrpProfileId == ''){
            svmxGrpProfileId = getSVMXGrpProfileId(userinfo.getProfileId());
        }
        Map<String, String> mapAllObjs = (Map<String, String>)INTF_TxnCache.get('MAP_OBJECT_DEF', 'Map<String, String>');
        if(mapAllObjs == null || mapAllObjs.size() == 0){
            mapAllObjs = new Map<String, String>();
            for(String obj : allObjs.keyset()){
                if(obj.contains('__c')){
                    Schema.DescribeSObjectResult objDesc = allObjs.get(obj).getDescribe();
                    mapAllObjs.put(objDesc.getName(), obj);
                }   
            }
            INTF_TxnCache.put('MAP_OBJECT_DEF', mapAllObjs, 'Map<String, String>');
        }
        
        mapObjToPicklistFields = (Map<String, Set<String>>)INTF_TxnCache.get('MAP_OBJECT_PICKLIST', 'Map<String, Set<String>>');
        if(mapObjToPicklistFields == null || mapObjToPicklistFields.size() == 0){
            mapObjToPicklistFields = new Map<String, Set<String>>();
            setPageLayoutIds = (set<string>)INTF_TxnCache.get('SET_PAGELAYOUT_ID', 'set<string>');
            if(setPageLayoutIds != null && setPageLayoutIds.size() > 0){
                INTF_DataSync.logSOQL(intMethodCount , 'SELECT SVMXC__Field_API_Name__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c FROM SVMXC__Page_Layout_Detail__c WHERE (SVMXC__DataType__c = \'picklist\' OR SVMXC__DataType__c = \'multipicklist\') AND SVMXC__Page_Layout__c IN: setPageLayoutIds');
                for(SVMXC__Page_Layout_Detail__c pglayoutDtl : [SELECT SVMXC__Field_API_Name__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c FROM SVMXC__Page_Layout_Detail__c WHERE (SVMXC__DataType__c = 'picklist' OR SVMXC__DataType__c = 'multipicklist') AND SVMXC__Page_Layout__c IN: setPageLayoutIds]){
                    if(mapObjToPicklistFields == null || mapObjToPicklistFields.size() == 0 || mapObjToPicklistFields.get(pglayoutDtl.SVMXC__Page_Layout__r.SVMXC__Object_Name__c) == null || !mapObjToPicklistFields.containsKey(pglayoutDtl.SVMXC__Page_Layout__r.SVMXC__Object_Name__c))
                        mapObjToPicklistFields.put(pglayoutDtl.SVMXC__Page_Layout__r.SVMXC__Object_Name__c,  new Set<String>{pglayoutDtl.SVMXC__Field_API_Name__c});
                    else
                        mapObjToPicklistFields.get(pglayoutDtl.SVMXC__Page_Layout__r.SVMXC__Object_Name__c).add(pglayoutDtl.SVMXC__Field_API_Name__c);
                }
            }
            INTF_TxnCache.put('MAP_OBJECT_PICKLIST', mapObjToPicklistFields, 'Map<String, Set<String>>');
        }
        
        boolean setiPad018_set008 = (boolean)INTF_TxnCache.get('IPAD018_SET008', 'boolean');
        if(setiPad018_set008 == null){
            List<SVMXC__ServiceMax_Config_Data__c> lstSettings = getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET008'}, svmxGrpProfileId);
            if(lstSettings != null && lstSettings.size() > 0){
                for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings)
                    setiPad018_set008 = boolean.valueOf(cnf.SVMXC__Internal_Value__c);
            }
            else
                setiPad018_set008 = false;
            INTF_TxnCache.put('IPAD018_SET008', setiPad018_set008, 'boolean');
        }
        
        for(String strObj : setObjNames){
            system.debug(LoggingLevel.WARN, 'Object Name for Describe = ' + strObj);
            if(checkLimit(70))
                break;
            
            INTF_WebServicesDef.SVMXMap objPickListDescribe = new INTF_WebServicesDef.SVMXMap();
            try{
                if(mapObjToPicklistFields != null && mapObjToPicklistFields.size() > 0 && mapObjToPicklistFields.containsKey(strObj) && mapObjToPicklistFields.get(strObj) != null && mapObjToPicklistFields.get(strObj).size() > 0)
                    objPickListDescribe = getObjDefWithPicklist(mapObjToPicklistFields.get(strObj), setiPad018_set008, strObj, mapAllObjs, allObjs);
                else
                    objPickListDescribe = getObjDefWithPicklist(null, setiPad018_set008, strObj, mapAllObjs, allObjs);
                objDefVM.valueMap.add(objPickListDescribe);
                setObjNames.remove(strObj);
            }catch(Exception ex){
                INTF_DataSync.logMethodEndTS(intMethodCount,'getObjectDef');
                return returnResponseWithException(ex, res);
            }
        }
        res.valueMap.add(objDefVM);
        INTF_DataSync.logMethodEndTS(intMethodCount,'getObjectDef');
        return res;
    }
    
    public INTF_WebServicesDef.SVMXMap getObjDefWithPicklist(set<string> setPicklistFlds, boolean setiPad018_set008, string strObj, Map<String, String> mapAllObjs, Map<String, Schema.SObjectType> allObjs){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getObjDefWithPicklist');
        SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
        Set<String> setSystemObjs = new Set<String>{'user', 'event', 'task', 'attachment', 'businesshours'};
        INTF_WebServicesDef.SVMXMap resObjDescribe = new INTF_WebServicesDef.SVMXMap();
        resObjDescribe.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        resObjDescribe.key = 'OBJECT';
        resObjDescribe.value = strObj;
        strObj = utils.getOriginalAPIName(strObj, mapAllObjs);
        system.debug(LoggingLevel.WARN, 'strObj = ' + strObj);
        if(strObj != null && allObjs.get(strObj) != null){
            INTF_WebServicesDef.SVMXMap objectProp = new INTF_WebServicesDef.SVMXMap('OBJECTPROPERTY', '');
            INTF_WebServicesDef.SVMXMap fieldProp = new INTF_WebServicesDef.SVMXMap('FIELDPROPERTY', '');
            List<INTF_WebServicesDef.SVMXMap> lstFields = new List<INTF_WebServicesDef.SVMXMap>();
            List<INTF_WebServicesDef.SVMXMap> lstObjectProperties = new List<INTF_WebServicesDef.SVMXMap>();
            
            Schema.SObjectType selectedObject = allObjs.get(strObj);
            Schema.DescribeSObjectResult objDescribe = selectedObject.getDescribe();
            
            if(setSystemObjs.contains(strObj.toLowerCase()) && !objDescribe.isAccessible()){
                system.debug(LoggingLevel.WARN, 'strObj ' + strObj + ' is not accessible');
                if(strObj == 'user'){
                    INTF_DataSync.logMethodEndTS(intMethodCount,'getObjDefWithPicklist');
                    return getUserObjDescribe();
                }else if(strObj == 'event'){
                    INTF_DataSync.logMethodEndTS(intMethodCount,'getObjDefWithPicklist');
                    return getEventObjDescribe();
                }else if(strObj == 'task'){
                    INTF_DataSync.logMethodEndTS(intMethodCount,'getObjDefWithPicklist');
                    return getTaskObjDescribe();
                }else if(strObj == 'attachment'){
                    INTF_DataSync.logMethodEndTS(intMethodCount,'getObjDefWithPicklist');
                    return getAttachmentObjDescribe();
                }else if(strObj == 'businesshours'){
                    INTF_DataSync.logMethodEndTS(intMethodCount,'getObjDefWithPicklist');
                    return getBusinessHoursObjDescribe();  
                }      
            }
            else{
            system.debug(LoggingLevel.WARN,'Accessible - strObj = '+strObj);
            Map<String,Schema.SObjectField> fieldMapping = objDescribe.fields.getMap();
        
            for(Schema.SObjectField fieldMap: fieldMapping.values()){
                Schema.DescribeFieldResult fieldDescribe = fieldMap.getDescribe();
                
                if(setiPad018_set008 && !fieldDescribe.isAccessible())
                    continue;
                
                List<INTF_WebServicesDef.SVMXMap> lstFieldProperties = new List<INTF_WebServicesDef.SVMXMap>();
                if(fieldDescribe.getType() == Schema.DisplayType.Reference){
                    List<Schema.sObjectType> P = fieldDescribe.getReferenceTo();
                    system.debug(LoggingLevel.WARN, 'Reference to = ' + P + '; Field Describe = ' + fieldDescribe);
                    if((strObj.toUpperCase() == 'USER') && fieldDescribe.getName().toUpperCase() == 'PROFILEID')
                        lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO', 'Profile'));
                    else if(P != null && P.size() > 0){
                        if(P.size() == 2)
                            lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO', String.valueOf(P[1])));
                        else
                            lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO', String.valueOf(P[0])));
                    }
                    lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME', fieldDescribe.getRelationshipName()));
                }else if(fieldDescribe.getType() == Schema.DisplayType.Double || fieldDescribe.getType() == Schema.DisplayType.Currency || fieldDescribe.getType() == Schema.DisplayType.Percent){
                    lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('PRECISION', string.valueOf(fieldDescribe.getPrecision())));
                    lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('SCALE', string.valueOf(fieldDescribe.getScale())));
                }
                INTF_WebServicesDef.SVMXMap eachField = new INTF_WebServicesDef.SVMXMap('FIELD', fieldDescribe.getName());
                lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('LABEL', String.valueOf(fieldDescribe.getLabel())));
                lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('TYPE', String.valueOf(fieldDescribe.getType())));
                lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE', String.valueOf(fieldDescribe.isCreateable())));
                lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE', String.valueOf(fieldDescribe.isUpdateable())));
                lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('LENGTH', String.valueOf(fieldDescribe.getlength())));
                if((selectedObject == Account.SObjectType && fieldDescribe.getName() == 'Name') || (selectedObject != Account.SObjectType &&fieldDescribe.isNameField()))
                    lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD', 'TRUE'));
                else
                    lstFieldProperties.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD', 'FALSE'));
                //picklist start
                if(setPicklistFlds != null && setPicklistFlds.size() > 0 && setPicklistFlds.contains(fieldDescribe.getName()))
                {
                    INTF_WebServicesDef.SVMXMap picklistVM = new INTF_WebServicesDef.SVMXMap('PICKLIST_INFO','');
                    picklistVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('DEPENDENTPICKLIST', String.valueOf(fieldDescribe.isDependentPicklist())));
                    List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                    for(Schema.PicklistEntry eachEntry : picklistEntries)
                    {
                        INTF_WebServicesDef.SVMXMap eachPickEntry = new INTF_WebServicesDef.SVMXMap();
                        eachPickEntry.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                        if(eachEntry.isActive())
                        {
                            if(eachEntry.getLabel() != NULL)
                            {
                                eachPickEntry.valueMap.add(new INTF_WebServicesDef.SVMXMap('PICKLISTVALUE', eachEntry.getValue()));
                                eachPickEntry.valueMap.add(new INTF_WebServicesDef.SVMXMap('PICKLISTLABEL', eachEntry.getLabel()));
                                if(eachEntry.isDefaultValue())
                                    eachPickEntry.valueMap.add(new INTF_WebServicesDef.SVMXMap('DEFAULTPICKLISTVALUE', eachEntry.getValue()));
                            }   
                        }
                        picklistVM.valueMap.add(eachPickEntry);
                    }
                    if(fieldDescribe.getType() == Schema.DisplayType.MultiPicklist)
                        picklistVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ISMULTIPICKLIST', 'TRUE'));
                    else
                        picklistVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ISMULTIPICKLIST', 'FALSE'));
                    
                    lstFieldProperties.add(picklistVM);
                }
                //picklist end
                eachField.valueMap = lstFieldProperties;
                lstFields.add(eachField);
            }
            fieldProp.valueMap = lstFields;
            INTF_WebServicesDef.SVMXMap recordTypeProp = new INTF_WebServicesDef.SVMXMap('RECORDTYPE', '');
            List<INTF_WebServicesDef.SVMXMap> availableRecordTypeProp = new List<INTF_WebServicesDef.SVMXMap>();
            for(Schema.RecordTypeInfo recordType: objDescribe.getRecordTypeInfos())
            {
                if(recordType.isAvailable())
                    availableRecordTypeProp.add(new INTF_WebServicesDef.SVMXMap(recordType.getRecordTypeId(), recordType.getName()));
            }
            recordTypeProp.valueMap = availableRecordTypeProp;
            
            INTF_WebServicesDef.SVMXMap coreObjectProp = new INTF_WebServicesDef.SVMXMap('OBJECTDEFINITION', '');
            List<INTF_WebServicesDef.SVMXMap> availablecoreObjectProp = new List<INTF_WebServicesDef.SVMXMap>();
            availablecoreObjectProp.add(new INTF_WebServicesDef.SVMXMap('KEYPREFIX', objDescribe.getKeyPrefix()));
            availablecoreObjectProp.add(new INTF_WebServicesDef.SVMXMap('LABEL', objDescribe.getLabel()));
            availablecoreObjectProp.add(new INTF_WebServicesDef.SVMXMap('PLURALLABEL', objDescribe.getLabelPlural()));
            availablecoreObjectProp.add(new INTF_WebServicesDef.SVMXMap('QUERYABLE', objDescribe.isQueryable()?'true':'false'));
            
            List<schema.Childrelationship> ChildObj = objDescribe.getChildRelationships();
            if(ChildObj.size() > 0)
            {
                List<INTF_WebServicesDef.SVMXMap> coreChilds = new List<INTF_WebServicesDef.SVMXMap>();
                for(schema.Childrelationship CR:ChildObj)
                {
                    String strChildObjectName = CR.getChildSObject().getDescribe().getName();
                    if(CR.isCascadeDelete() == true)
                    {
                        Schema.sObjectField field = CR.getField();
                        coreChilds.add(new INTF_WebServicesDef.SVMXMap(strChildObjectName, field.getDescribe().getName()));
                    }
                }
                if(coreChilds != NULL && coreChilds.size() > 0)
                {
                    INTF_WebServicesDef.SVMXMap lstChilds = new INTF_WebServicesDef.SVMXMap('MASTERDETAILS', null);
                    lstChilds.valueMap = coreChilds;
                    availablecoreObjectProp.add(lstChilds);
                }
            }
            coreObjectProp.valueMap = availablecoreObjectProp;
            objectProp.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            objectProp.valueMap.add(coreObjectProp);
            objectProp.valueMap.add(recordTypeProp);
            
            lstObjectProperties.add(objectProp);
            lstObjectProperties.add(fieldProp);
            
            resObjDescribe.valueMap = lstObjectProperties;
            }
        }
        else{
            resObjDescribe.valueMap.add(new INTF_WebServicesDef.SVMXMap('ERROR', 'Original API Name of object is null or object not found in global describe; check if object exists and is deployed'));
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'getObjDefWithPicklist');
        return resObjDescribe;
    }
    
    public INTF_WebServicesDef.SVMXMap getAttachmentObjDescribe(){
    
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getAttachmentObjDescribe');
        
        INTF_WebServicesDef.SVMXMap valMap = new INTF_WebServicesDef.SVMXMap('OBJECT','Attachment');
        valMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
    
        //ObjectProperty
        INTF_WebServicesDef.SVMXMap ObjValMap = new INTF_WebServicesDef.SVMXMap('OBJECTPROPERTY','');
        ObjValMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        //Object property Object Definition
        INTF_WebServicesDef.SVMXMap objPropObjDef = new INTF_WebServicesDef.SVMXMap('OBJECTDEFINITION','');
        objPropObjDef.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('KEYPREFIX','00P'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Attachment'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('PLURALLABEL','Attachments'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('QUERYABLE','true'));
        
        //Object property Recordtype
        INTF_WebServicesDef.SVMXMap objPropRecType = new INTF_WebServicesDef.SVMXMap('RECORDTYPE','');
        objPropRecType.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        ObjValMap.valueMap.add(objPropObjDef);
        ObjValMap.valueMap.add(objPropRecType);
        
        valMap.valueMap.add(ObjValMap);  //Add Object Property
        
        //FieldProperty
        INTF_WebServicesDef.SVMXMap fieldValMap = new INTF_WebServicesDef.SVMXMap('FIELDPROPERTY','');
        fieldValMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        // 15 valuemaps per fieldProperty - 6 valueMaps per field - 
        INTF_WebServicesDef.SVMXMap fieldVM1 = new INTF_WebServicesDef.SVMXMap('FIELD','Id');
        fieldVM1.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Attachment ID'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','ID'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM2 = new INTF_WebServicesDef.SVMXMap('FIELD','IsDeleted');
        fieldVM2.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Deleted'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM3 = new INTF_WebServicesDef.SVMXMap('FIELD','ParentId');
        fieldVM3.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','Account'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','Parent'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Parent ID'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        INTF_WebServicesDef.SVMXMap fieldVM4 = new INTF_WebServicesDef.SVMXMap('FIELD','Name');
        fieldVM4.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','File Name'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','255'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','TRUE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM5 = new INTF_WebServicesDef.SVMXMap('FIELD','IsPrivate');
        fieldVM5.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Private'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        INTF_WebServicesDef.SVMXMap fieldVM6 = new INTF_WebServicesDef.SVMXMap('FIELD','ContentType');
        fieldVM6.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Content Type'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','120'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM7 = new INTF_WebServicesDef.SVMXMap('FIELD','BodyLength');
        fieldVM7.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Body Length'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','INTEGER'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM8 = new INTF_WebServicesDef.SVMXMap('FIELD','Body');
        fieldVM8.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Body'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BASE64'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        INTF_WebServicesDef.SVMXMap fieldVM9 = new INTF_WebServicesDef.SVMXMap('FIELD','OwnerId');
        fieldVM9.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','User'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','Owner'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Owner ID'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM15 = new INTF_WebServicesDef.SVMXMap('FIELD','Description');
        fieldVM15.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Description'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TEXTAREA'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','500'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM1);
        fieldValMap.valueMap.add(fieldVM2);
        fieldValMap.valueMap.add(fieldVM3);
        fieldValMap.valueMap.add(fieldVM4);
        fieldValMap.valueMap.add(fieldVM5);
        fieldValMap.valueMap.add(fieldVM6);
        fieldValMap.valueMap.add(fieldVM7);
        fieldValMap.valueMap.add(fieldVM8);
        fieldValMap.valueMap.add(fieldVM9);
        
        fieldValMap.valueMap.addAll(getCommonFieldsDefinition());
        fieldValMap.valueMap.add(fieldVM15);
        
        valMap.valueMap.add(fieldValMap); //Add Field Property
        
        INTF_DataSync.logMethodEndTS(intMethodCount,'getAttachmentObjDescribe');
        
        return valMap;
        
    }
    
    public INTF_WebServicesDef.SVMXMap getEventObjDescribe(){
    
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getEventObjDescribe');
        
        INTF_WebServicesDef.SVMXMap valMap = new INTF_WebServicesDef.SVMXMap('OBJECT','Event');
        valMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
    
        //ObjectProperty
        INTF_WebServicesDef.SVMXMap ObjValMap = new INTF_WebServicesDef.SVMXMap('OBJECTPROPERTY','');
        ObjValMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        //Object property Object Definition
        INTF_WebServicesDef.SVMXMap objPropObjDef = new INTF_WebServicesDef.SVMXMap('OBJECTDEFINITION','');
        objPropObjDef.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('KEYPREFIX','00U'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Event'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('PLURALLABEL','Events'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('QUERYABLE','true'));
        //objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('MASTERDETAILS',null));
    
        //Master detail property Object Definition
        INTF_WebServicesDef.SVMXMap masterdetailprop = new INTF_WebServicesDef.SVMXMap('MASTERDETAILS','');
        masterdetailprop.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('AttachedContentDocument','LinkedEntityId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('Attachment','ParentId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('CombinedAttachment','ParentId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink','LinkedEntityId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('EntitySubscription','ParentId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('FeedItem','ParentId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('EventFeed','ParentId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('EventTag','ItemId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('TopicAssignment','EntityId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('EventRelation','EventId'));
            
        objPropObjDef.valueMap.add(masterdetailprop);
        
        //Object property Recordtype
        INTF_WebServicesDef.SVMXMap objPropRecType = new INTF_WebServicesDef.SVMXMap('RECORDTYPE','');
        objPropRecType.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        ObjValMap.valueMap.add(objPropObjDef);
        ObjValMap.valueMap.add(objPropRecType);
        
        valMap.valueMap.add(ObjValMap);
    
        //FieldProperty
        INTF_WebServicesDef.SVMXMap fieldValMap = new INTF_WebServicesDef.SVMXMap('FIELDPROPERTY','');
        fieldValMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
    
        // 49 valuemaps per fieldProperty - 6 valueMaps per field - 
    
        fieldValMap.valueMap.addAll(listOfCommonMaps());
        INTF_WebServicesDef.SVMXMap fieldVM5 = new INTF_WebServicesDef.SVMXMap('FIELD','Location');
        fieldVM5.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Location'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','255'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM5);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM6 = new INTF_WebServicesDef.SVMXMap('FIELD','IsAllDayEvent');
        fieldVM6.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','All-Day Event'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM6);
    
        INTF_WebServicesDef.SVMXMap fieldVM7 = new INTF_WebServicesDef.SVMXMap('FIELD','ActivityDateTime');
        fieldVM7.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Due Date Time'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM7);
    
        INTF_WebServicesDef.SVMXMap fieldVM9 = new INTF_WebServicesDef.SVMXMap('FIELD','DurationInMinutes');
        fieldVM9.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Duration'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','INTEGER'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM9);
    
        INTF_WebServicesDef.SVMXMap fieldVM10 = new INTF_WebServicesDef.SVMXMap('FIELD','StartDateTime');
        fieldVM10.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Start Date Time'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM10);
    
        INTF_WebServicesDef.SVMXMap fieldVM11 = new INTF_WebServicesDef.SVMXMap('FIELD','EndDateTime');
        fieldVM11.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','End Date Time'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM11);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM16 = new INTF_WebServicesDef.SVMXMap('FIELD','IsPrivate');
        fieldVM16.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Private'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM16);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM17 = new INTF_WebServicesDef.SVMXMap('FIELD','ShowAs');
        fieldVM17.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Show Time As'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM17);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM19 = new INTF_WebServicesDef.SVMXMap('FIELD','IsChild');
        fieldVM19.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Is Child'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM19);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM20 = new INTF_WebServicesDef.SVMXMap('FIELD','GroupEventType');
        fieldVM20.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Group Event Type'));
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM20);
    
        INTF_WebServicesDef.SVMXMap fieldVM21 = new INTF_WebServicesDef.SVMXMap('FIELD','IsGroupEvent');
        fieldVM21.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Is Group Event'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM21);
    
        
        INTF_WebServicesDef.SVMXMap fieldVM31 = new INTF_WebServicesDef.SVMXMap('FIELD','RecurrenceStartDateTime');
        fieldVM31.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Recurrence Start'));
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM31);
        
        valMap.valueMap.add(fieldValMap);
        
        INTF_DataSync.logMethodEndTS(intMethodCount,'getEventObjDescribe');
        return valMap; 
        
    }
    
    public INTF_WebServicesDef.SVMXMap getTaskObjDescribe(){
        

        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getTaskObjDescribe');
        
        INTF_WebServicesDef.SVMXMap valMap = new INTF_WebServicesDef.SVMXMap('OBJECT','Task');
        valMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
    
        //ObjectProperty
        INTF_WebServicesDef.SVMXMap ObjValMap = new INTF_WebServicesDef.SVMXMap('OBJECTPROPERTY','');
        ObjValMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        //Object property Object Definition
        INTF_WebServicesDef.SVMXMap objPropObjDef = new INTF_WebServicesDef.SVMXMap('OBJECTDEFINITION','');
        objPropObjDef.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('KEYPREFIX','00T'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Task'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('PLURALLABEL','Tasks'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('QUERYABLE','true'));
        //objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('MASTERDETAILS',null));
    
        //Master detail property Object Definition
        INTF_WebServicesDef.SVMXMap masterdetailprop = new INTF_WebServicesDef.SVMXMap('MASTERDETAILS','');
        masterdetailprop.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('AttachedContentDocument','LinkedEntityId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('Attachment','ParentId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('CombinedAttachment','ParentId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink','LinkedEntityId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('EntitySubscription','ParentId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('FeedItem','ParentId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('TaskFeed','ParentId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('TaskTag','ItemId'));
        masterdetailprop.valueMap.add(new INTF_WebServicesDef.SVMXMap('TopicAssignment','EntityId'));
            
        objPropObjDef.valueMap.add(masterdetailprop);
        
        //Object property Recordtype
        INTF_WebServicesDef.SVMXMap objPropRecType = new INTF_WebServicesDef.SVMXMap('RECORDTYPE','');
        objPropRecType.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        ObjValMap.valueMap.add(objPropObjDef);
        ObjValMap.valueMap.add(objPropRecType);
        
        valMap.valueMap.add(ObjValMap);
    
        //FieldProperty
        INTF_WebServicesDef.SVMXMap fieldValMap = new INTF_WebServicesDef.SVMXMap('FIELDPROPERTY','');
        fieldValMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
    
        // 49 valuemaps per fieldProperty - 6 valueMaps per field - 
    
        fieldValMap.valueMap.addAll(listOfCommonMaps());
        INTF_WebServicesDef.SVMXMap fieldVM6 = new INTF_WebServicesDef.SVMXMap('FIELD','Status');
        fieldVM6.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Status'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM6);
    
        INTF_WebServicesDef.SVMXMap fieldVM7 = new INTF_WebServicesDef.SVMXMap('FIELD','Priority');
        fieldVM7.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Priority'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM7);
    
        INTF_WebServicesDef.SVMXMap fieldVM13 = new INTF_WebServicesDef.SVMXMap('FIELD','IsClosed');
        fieldVM13.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Closed'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM13);
    
        INTF_WebServicesDef.SVMXMap fieldVM21 = new INTF_WebServicesDef.SVMXMap('FIELD','CallDurationInSeconds');
        fieldVM21.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Call Duration'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','INTEGER'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM21);
    
        INTF_WebServicesDef.SVMXMap fieldVM22 = new INTF_WebServicesDef.SVMXMap('FIELD','CallType');
        fieldVM22.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Call Type'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM22);
    
        INTF_WebServicesDef.SVMXMap fieldVM23 = new INTF_WebServicesDef.SVMXMap('FIELD','CallDisposition');
        fieldVM23.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Call Result'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','255'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM23);
    
        INTF_WebServicesDef.SVMXMap fieldVM24 = new INTF_WebServicesDef.SVMXMap('FIELD','CallObject');
        fieldVM24.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Call Object Identifier'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','255'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM24);
    
        INTF_WebServicesDef.SVMXMap fieldVM29 = new INTF_WebServicesDef.SVMXMap('FIELD','RecurrenceStartDateOnly');
        fieldVM29.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Start Date'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATE'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.valueMap.add(fieldVM29);
    
        valMap.valueMap.add(fieldValMap);
        
        INTF_DataSync.logMethodEndTS(intMethodCount,'getTaskObjDescribe'); 
        return valMap;
    }
    
    public INTF_WebServicesDef.SVMXMap getUserObjDescribe(){
    
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getUserObjDescribe');
        
        INTF_WebServicesDef.SVMXMap valMap = new INTF_WebServicesDef.SVMXMap('OBJECT','User');
        valMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        //ObjectProperty
        INTF_WebServicesDef.SVMXMap ObjValMap = new INTF_WebServicesDef.SVMXMap('OBJECTPROPERTY','');
        ObjValMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        //Object property Object Definition
        INTF_WebServicesDef.SVMXMap objPropObjDef = new INTF_WebServicesDef.SVMXMap('OBJECTDEFINITION','');
        objPropObjDef.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('KEYPREFIX','005'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','User'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('PLURALLABEL','Users'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('QUERYABLE','true'));
        
        INTF_WebServicesDef.SVMXMap objPropMasterDetails = new INTF_WebServicesDef.SVMXMap('MASTERDETAILS',null);
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('AccountShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('ApexLog','LogUserId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('AttachedContentDocument','LinkedEntityId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('CampaignShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('CaseShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('CaseTeamMember','MemberId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('CaseTeamTemplateMember','MemberId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('ChatterConversationMember','MemberId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('ClientBrowser','UsersId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('CollaborationGroupMember','MemberId'));
        
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('CollaborationGroupMemberRequest','RequesterId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('CollaborationInvitation','CreatedById'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('CollaborationInvitation','SharedEntityId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('CombinedAttachment','ParentId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContactShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink','LinkedEntityId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('DatacloudOwnedEntity','UserId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('DatacloudPurchaseUsage','UserId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('EntitySubscription','CreatedById'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('EntitySubscription','ParentId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('EntitySubscription','SubscriberId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('EventRelation','RelationId'));
        
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('FeedComment','CreatedById'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('FeedComment','InsertedById'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('FeedItem','CreatedById'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('FeedItem','ParentId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('FeedLike','CreatedById'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('FeedLike','InsertedById'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('ForecastShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('GroupMember','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('InstalledMobileApp','UserId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('LeadShare','UserOrGroupId'));
        
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('LoginHistory','UserId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('LoginIp','UsersId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('OpportunityShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('PermissionSetAssignment','AssigneeId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('PermissionSetLicenseAssign','AssigneeId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('ProcessInstanceStep','ActorId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('ProcessInstanceStep','OriginalActorId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('ProcessInstanceWorkitem','OriginalActorId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('StreamingChannelShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('UserFeed','ParentId'));
        
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('UserPreference','UserId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('UserShare','UserId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('UserShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('Vote','CreatedById'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('WorkCoachingShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('WorkFeedbackQuestionSetShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('WorkFeedbackQuestionShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('WorkFeedbackRequestShare','UserOrGroupId'));
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('WorkFeedbackShare','UserOrGroupId')); 
        objPropMasterDetails.valueMap.add(new INTF_WebServicesDef.SVMXMap('WorkPerformanceCycleShare','UserOrGroupId'));
        
        objPropObjDef.valueMap.add(objPropMasterDetails);
        
        //Object property Recordtype
        INTF_WebServicesDef.SVMXMap objPropRecType = new INTF_WebServicesDef.SVMXMap('RECORDTYPE','');
        objPropRecType.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        ObjValMap.valueMap.add(objPropObjDef);
        ObjValMap.valueMap.add(objPropRecType);
        
        valMap.valueMap.add(ObjValMap);  //Add Object Property
        
        /************* field property**************/
        
        INTF_WebServicesDef.SVMXMap fieldValMap = new INTF_WebServicesDef.SVMXMap('FIELDPROPERTY','');
        fieldValMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        //129 Fields
        
        INTF_WebServicesDef.SVMXMap fieldVM1 = new INTF_WebServicesDef.SVMXMap('FIELD','Id');
        fieldVM1.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','User ID'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','ID'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM2 = new INTF_WebServicesDef.SVMXMap('FIELD','Username');
        fieldVM2.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Username'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM3 = new INTF_WebServicesDef.SVMXMap('FIELD','LastName');
        fieldVM3.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Last Name'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM4 = new INTF_WebServicesDef.SVMXMap('FIELD','FirstName');
        fieldVM4.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','First Name'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM5 = new INTF_WebServicesDef.SVMXMap('FIELD','Name');
        fieldVM5.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Full Name'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','121'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','TRUE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM6 = new INTF_WebServicesDef.SVMXMap('FIELD','CompanyName');
        fieldVM6.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Company Name'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM7 = new INTF_WebServicesDef.SVMXMap('FIELD','Division');
        fieldVM7.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Division'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM8 = new INTF_WebServicesDef.SVMXMap('FIELD','Department');
        fieldVM8.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Department'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM9 = new INTF_WebServicesDef.SVMXMap('FIELD','Title');
        fieldVM9.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Title'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM10 = new INTF_WebServicesDef.SVMXMap('FIELD','Street');
        fieldVM10.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Street'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TEXTAREA'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','255'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM11 = new INTF_WebServicesDef.SVMXMap('FIELD','City');
        fieldVM11.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','City'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM12 = new INTF_WebServicesDef.SVMXMap('FIELD','State');
        fieldVM12.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','State/Province'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM13 = new INTF_WebServicesDef.SVMXMap('FIELD','PostalCode');
        fieldVM13.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Zip/Postal Code'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','20'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM14 = new INTF_WebServicesDef.SVMXMap('FIELD','Country');
        fieldVM14.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Country'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM15 = new INTF_WebServicesDef.SVMXMap('FIELD','Latitude');
        fieldVM15.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRECISION','18'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCALE','15'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Latitude'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DOUBLE'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM16 = new INTF_WebServicesDef.SVMXMap('FIELD','Longitude');
        fieldVM16.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRECISION','18'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCALE','15'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Longitude'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DOUBLE'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM17 = new INTF_WebServicesDef.SVMXMap('FIELD','Email');
        fieldVM17.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Email'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','EMAIL'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','128'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM18 = new INTF_WebServicesDef.SVMXMap('FIELD','EmailPreferencesAutoBcc');
        fieldVM18.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','AutoBcc'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM19 = new INTF_WebServicesDef.SVMXMap('FIELD','EmailPreferencesAutoBccStayInTouch');
        fieldVM19.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','AutoBccStayInTouch'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM20 = new INTF_WebServicesDef.SVMXMap('FIELD','EmailPreferencesStayInTouchReminder');
        fieldVM20.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','StayInTouchReminder'));
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM20.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM21 = new INTF_WebServicesDef.SVMXMap('FIELD','SenderEmail');
        fieldVM21.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Email Sender Address'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','EMAIL'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM21.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM22 = new INTF_WebServicesDef.SVMXMap('FIELD','SenderName');
        fieldVM22.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Email Sender Name'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM23 = new INTF_WebServicesDef.SVMXMap('FIELD','Signature');
        fieldVM23.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Email Signature'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','1333'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM24 = new INTF_WebServicesDef.SVMXMap('FIELD','StayInTouchSubject');
        fieldVM24.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Stay-in-Touch Email Subject'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM25 = new INTF_WebServicesDef.SVMXMap('FIELD','StayInTouchSignature');
        fieldVM25.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Stay-in-Touch Email Signature'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','512'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM26 = new INTF_WebServicesDef.SVMXMap('FIELD','StayInTouchNote');
        fieldVM26.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Stay-in-Touch Email Note'));
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','512'));
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM27 = new INTF_WebServicesDef.SVMXMap('FIELD','Phone');
        fieldVM27.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Phone'));
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PHONE'));
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM28 = new INTF_WebServicesDef.SVMXMap('FIELD','Fax');
        fieldVM28.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Fax'));
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PHONE'));
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM29 = new INTF_WebServicesDef.SVMXMap('FIELD','MobilePhone');
        fieldVM29.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Cell'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PHONE'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM30 = new INTF_WebServicesDef.SVMXMap('FIELD','Alias');
        fieldVM30.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Alias'));
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','8'));
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM31 = new INTF_WebServicesDef.SVMXMap('FIELD','CommunityNickname');
        fieldVM31.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Nickname'));
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM31.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM32 = new INTF_WebServicesDef.SVMXMap('FIELD','IsActive');
        fieldVM32.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Active'));
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM33 = new INTF_WebServicesDef.SVMXMap('FIELD','TimeZoneSidKey');
        fieldVM33.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Time Zone'));
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM34 = new INTF_WebServicesDef.SVMXMap('FIELD','UserRoleId');
        fieldVM34.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','UserRole'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','UserRole'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Role ID'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM35 = new INTF_WebServicesDef.SVMXMap('FIELD','LocaleSidKey');
        fieldVM35.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Locale'));
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM36 = new INTF_WebServicesDef.SVMXMap('FIELD','ReceivesInfoEmails');
        fieldVM36.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Info Emails'));
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM37 = new INTF_WebServicesDef.SVMXMap('FIELD','ReceivesAdminInfoEmails');
        fieldVM37.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Admin Info Emails'));
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM38 = new INTF_WebServicesDef.SVMXMap('FIELD','EmailEncodingKey');
        fieldVM38.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Email Encoding'));
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM39 = new INTF_WebServicesDef.SVMXMap('FIELD','ProfileId');
        fieldVM39.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','Profile'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','Profile'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Profile ID'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM40 = new INTF_WebServicesDef.SVMXMap('FIELD','UserType');
        fieldVM40.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','User Type'));
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM41 = new INTF_WebServicesDef.SVMXMap('FIELD','LanguageLocaleKey');
        fieldVM41.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Language'));
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM42 = new INTF_WebServicesDef.SVMXMap('FIELD','EmployeeNumber');
        fieldVM42.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Employee Number'));
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','20'));
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM43 = new INTF_WebServicesDef.SVMXMap('FIELD','DelegatedApproverId');
        fieldVM43.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','User'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME',null));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Delegated Approver ID'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM44 = new INTF_WebServicesDef.SVMXMap('FIELD','ManagerId');
        fieldVM44.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','User'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','Manager'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Manager ID'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM45 = new INTF_WebServicesDef.SVMXMap('FIELD','LastLoginDate');
        fieldVM45.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Last Login'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM46 = new INTF_WebServicesDef.SVMXMap('FIELD','LastPasswordChangeDate');
        fieldVM46.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Last Password Change or Reset'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM52 = new INTF_WebServicesDef.SVMXMap('FIELD','OfflineTrialExpirationDate');
        fieldVM52.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Offline Edition Trial Expiration Date'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE')); 
        
        INTF_WebServicesDef.SVMXMap fieldVM53 = new INTF_WebServicesDef.SVMXMap('FIELD','OfflinePdaTrialExpirationDate');
        fieldVM53.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Sales Anywhere Trial Expiration Date'));
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE')); 
        
        INTF_WebServicesDef.SVMXMap fieldVM54 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsMarketingUser');
        fieldVM54.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM54.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Marketing User'));
        fieldVM54.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM54.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM54.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM54.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM54.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE')); 
        
        INTF_WebServicesDef.SVMXMap fieldVM55 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsOfflineUser');
        fieldVM55.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM55.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Offline User'));
        fieldVM55.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM55.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM55.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM55.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM55.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE')); 
        
        INTF_WebServicesDef.SVMXMap fieldVM56 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsCallCenterAutoLogin');
        fieldVM56.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM56.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Auto-login To Call Center'));
        fieldVM56.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM56.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM56.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM56.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM56.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE')); 
        
        INTF_WebServicesDef.SVMXMap fieldVM57 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsMobileUser');
        fieldVM57.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM57.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Apex Mobile User'));
        fieldVM57.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM57.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM57.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM57.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM57.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE')); 
        
        INTF_WebServicesDef.SVMXMap fieldVM58 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsSFContentUser');
        fieldVM58.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM58.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Salesforce CRM Content User'));
        fieldVM58.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM58.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM58.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM58.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM58.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE')); 
        
        INTF_WebServicesDef.SVMXMap fieldVM59 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsKnowledgeUser');
        fieldVM59.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM59.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Knowledge User'));
        fieldVM59.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM59.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM59.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM59.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM59.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE')); 
        
        INTF_WebServicesDef.SVMXMap fieldVM60 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsInteractionUser');
        fieldVM60.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM60.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Force.com Flow User'));
        fieldVM60.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM60.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM60.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM60.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM60.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE')); 
        
        INTF_WebServicesDef.SVMXMap fieldVM61 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsSupportUser');
        fieldVM61.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM61.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Service Cloud User'));
        fieldVM61.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM61.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM61.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM61.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM61.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE')); 
        
        INTF_WebServicesDef.SVMXMap fieldVM130 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsJigsawProspectingUser');
        fieldVM130.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM130.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Data.com User'));
        fieldVM130.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM130.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM130.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM130.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM130.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM62 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsSiteforceContributorUser');
        fieldVM62.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM62.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Site.com Contributor User'));
        fieldVM62.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM62.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM62.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM62.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM62.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE')); 
        
        INTF_WebServicesDef.SVMXMap fieldVM63 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsSiteforcePublisherUser');
        fieldVM63.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM63.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Site.com Publisher User'));
        fieldVM63.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM63.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM63.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM63.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM63.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM64 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsChatterAnswersUser');
        fieldVM64.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM64.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Chatter Answers User'));
        fieldVM64.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM64.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM64.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM64.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM64.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM135 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPermissionsWorkDotComUserFeature');
        fieldVM135.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM135.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Work.com User'));
        fieldVM135.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM135.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM135.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM135.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM135.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM65 = new INTF_WebServicesDef.SVMXMap('FIELD','ForecastEnabled');
        fieldVM65.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM65.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Allow Forecasting'));
        fieldVM65.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM65.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM65.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM65.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM65.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM66 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesActivityRemindersPopup');
        fieldVM66.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM66.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ActivityRemindersPopup'));
        fieldVM66.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM66.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM66.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM66.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM66.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM67 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesEventRemindersCheckboxDefault');
        fieldVM67.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM67.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','EventRemindersCheckboxDefault'));
        fieldVM67.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM67.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM67.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM67.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM67.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM68 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesTaskRemindersCheckboxDefault');
        fieldVM68.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM68.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','TaskRemindersCheckboxDefault'));
        fieldVM68.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM68.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM68.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM68.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM68.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM69 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesReminderSoundOff');
        fieldVM69.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM69.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ReminderSoundOff'));
        fieldVM69.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM69.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM69.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM69.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM69.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM70 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableAllFeedsEmail');
        fieldVM70.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM70.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableAllFeedsEmail'));
        fieldVM70.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM70.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM70.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM70.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM70.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM71 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableFollowersEmail');
        fieldVM71.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM71.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableFollowersEmail'));
        fieldVM71.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM71.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM71.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM71.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM71.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM72 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableProfilePostEmail');
        fieldVM72.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM72.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableProfilePostEmail'));
        fieldVM72.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM72.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM72.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM72.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM72.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM73 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableChangeCommentEmail');
        fieldVM73.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM73.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableChangeCommentEmail'));
        fieldVM73.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM73.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM73.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM73.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM73.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM74 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableLaterCommentEmail');
        fieldVM74.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM74.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableLaterCommentEmail'));
        fieldVM74.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM74.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM74.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM74.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM74.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM75 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisProfPostCommentEmail');
        fieldVM75.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM75.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisProfPostCommentEmail'));
        fieldVM75.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM75.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM75.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM75.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM75.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM76 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesContentNoEmail');
        fieldVM76.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM76.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ContentNoEmail'));
        fieldVM76.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM76.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM76.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM76.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM76.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM77 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesContentEmailAsAndWhen');
        fieldVM77.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM77.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ContentEmailAsAndWhen'));
        fieldVM77.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM77.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM77.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM77.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM77.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM78 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesApexPagesDeveloperMode');
        fieldVM78.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM78.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ApexPagesDeveloperMode'));
        fieldVM78.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM78.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM78.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM78.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM78.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM79 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesHideCSNGetChatterMobileTask');
        fieldVM79.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM79.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','HideCSNGetChatterMobileTask'));
        fieldVM79.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM79.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM79.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM79.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM79.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM80 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableMentionsPostEmail');
        fieldVM80.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM80.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableMentionsPostEmail'));
        fieldVM80.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM80.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM80.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM80.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM80.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM81 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisMentionsCommentEmail');
        fieldVM81.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM81.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisMentionsCommentEmail'));
        fieldVM81.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM81.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM81.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM81.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM81.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM82 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesHideCSNDesktopTask');
        fieldVM82.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM82.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','HideCSNDesktopTask'));
        fieldVM82.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM82.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM82.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM82.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM82.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM83 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesHideChatterOnboardingSplash');
        fieldVM83.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM83.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','HideChatterOnboardingSplash'));
        fieldVM83.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM83.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM83.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM83.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM83.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM84 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesHideSecondChatterOnboardingSplash');
        fieldVM84.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM84.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','HideSecondChatterOnboardingSplash'));
        fieldVM84.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM84.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM84.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM84.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM84.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM85 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisCommentAfterLikeEmail');
        fieldVM85.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM85.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisCommentAfterLikeEmail'));
        fieldVM85.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM85.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM85.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM85.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM85.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM86 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableLikeEmail');
        fieldVM86.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM86.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableLikeEmail'));
        fieldVM86.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM86.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM86.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM86.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM86.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM87 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesSortFeedByComment');
        fieldVM87.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM87.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','SortFeedByComment'));
        fieldVM87.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM87.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM87.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM87.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM87.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM88 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableMessageEmail');
        fieldVM88.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM88.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableMessageEmail'));
        fieldVM88.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM88.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM88.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM88.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM88.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM89 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesOptOutOfTouch');
        fieldVM89.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM89.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','OptOutOfTouch'));
        fieldVM89.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM89.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM89.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM89.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM89.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM131 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesJigsawListUser');
        fieldVM131.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM131.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','JigsawListUser'));
        fieldVM131.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM131.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM131.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM131.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM131.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM90 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableBookmarkEmail');
        fieldVM90.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM90.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableBookmarkEmail'));
        fieldVM90.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM90.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM90.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM90.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM90.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM91 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableSharePostEmail');
        fieldVM91.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM91.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableSharePostEmail'));
        fieldVM91.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM91.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM91.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM91.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM91.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM92 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesEnableAutoSubForFeeds');
        fieldVM92.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM92.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','EnableAutoSubForFeeds'));
        fieldVM92.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM92.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM92.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM92.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM92.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM93 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableFileShareNotificationsForApi');
        fieldVM93.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM93.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableFileShareNotificationsForApi'));
        fieldVM93.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM93.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM93.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM93.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM93.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM94 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowTitleToExternalUsers');
        fieldVM94.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM94.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowTitleToExternalUsers'));
        fieldVM94.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM94.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM94.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM94.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM94.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM95 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowManagerToExternalUsers');
        fieldVM95.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM95.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowManagerToExternalUsers'));
        fieldVM95.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM95.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM95.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM95.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM95.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM96 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowEmailToExternalUsers');
        fieldVM96.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM96.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowEmailToExternalUsers'));
        fieldVM96.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM96.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM96.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM96.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM96.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM97 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowWorkPhoneToExternalUsers');
        fieldVM97.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM97.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowWorkPhoneToExternalUsers'));
        fieldVM97.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM97.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM97.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM97.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM97.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM98 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowMobilePhoneToExternalUsers');
        fieldVM98.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM98.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowMobilePhoneToExternalUsers'));
        fieldVM98.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM98.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM98.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM98.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM98.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM99 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowFaxToExternalUsers');
        fieldVM99.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM99.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowFaxToExternalUsers'));
        fieldVM99.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM99.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM99.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM99.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM99.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM100 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowStreetAddressToExternalUsers');
        fieldVM100.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM100.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowStreetAddressToExternalUsers'));
        fieldVM100.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM100.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM100.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM100.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM100.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM101 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowCityToExternalUsers');
        fieldVM101.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM101.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowCityToExternalUsers'));
        fieldVM101.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM101.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM101.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM101.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM101.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM102 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowStateToExternalUsers');
        fieldVM102.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM102.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowStateToExternalUsers'));
        fieldVM102.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM102.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM102.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM102.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM102.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM103 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowPostalCodeToExternalUsers');
        fieldVM103.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM103.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowPostalCodeToExternalUsers'));
        fieldVM103.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM103.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM103.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM103.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM103.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM104 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowCountryToExternalUsers');
        fieldVM104.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM104.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowCountryToExternalUsers'));
        fieldVM104.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM104.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM104.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM104.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM104.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM105 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowProfilePicToGuestUsers');
        fieldVM105.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM105.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowProfilePicToGuestUsers'));
        fieldVM105.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM105.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM105.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM105.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM105.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM106 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowTitleToGuestUsers');
        fieldVM106.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM106.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowTitleToGuestUsers'));
        fieldVM106.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM106.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM106.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM106.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM106.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM107 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowCityToGuestUsers');
        fieldVM107.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM107.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowCityToGuestUsers'));
        fieldVM107.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM107.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM107.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM107.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM107.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM108 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowStateToGuestUsers');
        fieldVM108.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM108.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowStateToGuestUsers'));
        fieldVM108.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM108.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM108.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM108.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM108.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM109 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowPostalCodeToGuestUsers');
        fieldVM109.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM109.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowPostalCodeToGuestUsers'));
        fieldVM109.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM109.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM109.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM109.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM109.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM110 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesShowCountryToGuestUsers');
        fieldVM110.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM110.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ShowCountryToGuestUsers'));
        fieldVM110.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM110.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM110.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM110.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM110.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM132 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableFeedbackEmail');
        fieldVM132.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM132.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableFeedbackEmail'));
        fieldVM132.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM132.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM132.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM132.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM132.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM133 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesDisableWorkEmail');
        fieldVM133.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM133.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','DisableWorkEmail'));
        fieldVM133.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM133.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM133.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM133.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM133.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM111 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesHideS1BrowserUI');
        fieldVM111.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM111.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','HideS1BrowserUI'));
        fieldVM111.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM111.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM111.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM111.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM111.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM112 = new INTF_WebServicesDef.SVMXMap('FIELD','UserPreferencesLightningExperiencePreferred');
        fieldVM112.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM112.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','LightningExperiencePreferred'));
        fieldVM112.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM112.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM112.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM112.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM112.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM113 = new INTF_WebServicesDef.SVMXMap('FIELD','ContactId');
        fieldVM113.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM113.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','Contact'));
        fieldVM113.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','Contact'));
        fieldVM113.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Contact ID'));
        fieldVM113.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM113.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM113.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM113.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM113.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM114 = new INTF_WebServicesDef.SVMXMap('FIELD','AccountId');
        fieldVM114.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM114.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','Account'));
        fieldVM114.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME',null));
        fieldVM114.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Account ID'));
        fieldVM114.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM114.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM114.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM114.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM114.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM115 = new INTF_WebServicesDef.SVMXMap('FIELD','CallCenterId');
        fieldVM115.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM115.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','CallCenter'));
        fieldVM115.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME',null));
        fieldVM115.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Call Center ID'));
        fieldVM115.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM115.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM115.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM115.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM115.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM116 = new INTF_WebServicesDef.SVMXMap('FIELD','Extension');
        fieldVM116.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM116.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Extension'));
        fieldVM116.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PHONE'));
        fieldVM116.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM116.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM116.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM116.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM117 = new INTF_WebServicesDef.SVMXMap('FIELD','FederationIdentifier');
        fieldVM117.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM117.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','SAML Federation ID'));
        fieldVM117.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM117.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM117.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM117.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','512'));
        fieldVM117.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM118 = new INTF_WebServicesDef.SVMXMap('FIELD','AboutMe');
        fieldVM118.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM118.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','About Me'));
        fieldVM118.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TEXTAREA'));
        fieldVM118.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM118.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM118.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','1000'));
        fieldVM118.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM119 = new INTF_WebServicesDef.SVMXMap('FIELD','FullPhotoUrl');
        fieldVM119.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM119.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Url for full-sized Photo'));
        fieldVM119.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','URL'));
        fieldVM119.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM119.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM119.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','1024'));
        fieldVM119.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM120 = new INTF_WebServicesDef.SVMXMap('FIELD','SmallPhotoUrl');
        fieldVM120.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM120.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Photo'));
        fieldVM120.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','URL'));
        fieldVM120.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM120.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM120.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','1024'));
        fieldVM120.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM121 = new INTF_WebServicesDef.SVMXMap('FIELD','DigestFrequency');
        fieldVM121.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM121.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Chatter Email Highlights Frequency'));
        fieldVM121.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM121.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM121.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM121.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM121.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM122 = new INTF_WebServicesDef.SVMXMap('FIELD','DefaultGroupNotificationFrequency');
        fieldVM122.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM122.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Default Notification Frequency when Joining Groups'));
        fieldVM122.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM122.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM122.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM122.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM122.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM134 = new INTF_WebServicesDef.SVMXMap('FIELD','JigsawImportLimitOverride');
        fieldVM134.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM134.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Data.com Monthly Addition Limit'));
        fieldVM134.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','INTEGER'));
        fieldVM134.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM134.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM134.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM134.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM123 = new INTF_WebServicesDef.SVMXMap('FIELD','LastViewedDate');
        fieldVM123.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM123.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Last Viewed Date'));
        fieldVM123.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM123.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM123.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM123.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM123.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM124 = new INTF_WebServicesDef.SVMXMap('FIELD','LastReferencedDate');
        fieldVM124.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM124.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Last Referenced Date'));
        fieldVM124.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM124.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM124.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM124.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM124.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM125 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Dispatch_Console_Settings__c');
        fieldVM125.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM125.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Dispatch Console Settings'));
        fieldVM125.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TEXTAREA'));
        fieldVM125.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM125.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM125.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','32000'));
        fieldVM125.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM126 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__FaceTime_ID__c');
        fieldVM126.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM126.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','FaceTime ID'));
        fieldVM126.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM126.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM126.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM126.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','100'));
        fieldVM126.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM127 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Is_Super_Dispatcher__c');
        fieldVM127.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM127.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Is Super Dispatcher?'));
        fieldVM127.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM127.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM127.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM127.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM127.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM128 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Select__c');
        fieldVM128.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM128.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Select'));
        fieldVM128.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM128.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM128.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM128.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM128.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM129 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__ServiceMax_User__c');
        fieldVM129.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM129.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','ServiceMax User?'));
        fieldVM129.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM129.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM129.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM129.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM129.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        if(UserInfo.isMultiCurrencyOrganization()){
            INTF_WebServicesDef.SVMXMap fieldVM136 = new INTF_WebServicesDef.SVMXMap('FIELD','DefaultCurrencyIsoCode');
            fieldVM136.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
            
            fieldVM136.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Default Currency ISO Code'));
            fieldVM136.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
            fieldVM136.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
            fieldVM136.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
            fieldVM136.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','3'));
            fieldVM136.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
            
            INTF_WebServicesDef.SVMXMap fieldVM137 = new INTF_WebServicesDef.SVMXMap('FIELD','CurrencyIsoCode');
            fieldVM137.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
            
            fieldVM137.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Currency ISO Code'));
            fieldVM137.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
            fieldVM137.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
            fieldVM137.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
            fieldVM137.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','3'));
            fieldVM137.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
            
            fieldValMap.valueMap.add(fieldVM136);
            fieldValMap.valueMap.add(fieldVM137);
            
        }
        
        fieldValMap.valueMap.add(fieldVM1);
        fieldValMap.valueMap.add(fieldVM2);
        fieldValMap.valueMap.add(fieldVM3);
        fieldValMap.valueMap.add(fieldVM4);
        fieldValMap.valueMap.add(fieldVM5);
        fieldValMap.valueMap.add(fieldVM6);
        fieldValMap.valueMap.add(fieldVM7);
        fieldValMap.valueMap.add(fieldVM8);
        fieldValMap.valueMap.add(fieldVM9);
        fieldValMap.valueMap.add(fieldVM10);
        fieldValMap.valueMap.add(fieldVM11);
        fieldValMap.valueMap.add(fieldVM12);
        fieldValMap.valueMap.add(fieldVM13);
        fieldValMap.valueMap.add(fieldVM14);
        fieldValMap.valueMap.add(fieldVM15);
        fieldValMap.valueMap.add(fieldVM16);
        fieldValMap.valueMap.add(fieldVM17);
        fieldValMap.valueMap.add(fieldVM18);
        fieldValMap.valueMap.add(fieldVM19);
        fieldValMap.valueMap.add(fieldVM20);
        fieldValMap.valueMap.add(fieldVM21);
        fieldValMap.valueMap.add(fieldVM22);
        fieldValMap.valueMap.add(fieldVM23);
        fieldValMap.valueMap.add(fieldVM24);
        fieldValMap.valueMap.add(fieldVM25);
        fieldValMap.valueMap.add(fieldVM26);
        fieldValMap.valueMap.add(fieldVM27);
        fieldValMap.valueMap.add(fieldVM28);
        fieldValMap.valueMap.add(fieldVM29);
        fieldValMap.valueMap.add(fieldVM30);
        fieldValMap.valueMap.add(fieldVM31);
        fieldValMap.valueMap.add(fieldVM32);
        fieldValMap.valueMap.add(fieldVM33);
        fieldValMap.valueMap.add(fieldVM34);
        fieldValMap.valueMap.add(fieldVM35);
        fieldValMap.valueMap.add(fieldVM36);
        fieldValMap.valueMap.add(fieldVM37);
        fieldValMap.valueMap.add(fieldVM38);
        fieldValMap.valueMap.add(fieldVM39);
        fieldValMap.valueMap.add(fieldVM40);
        fieldValMap.valueMap.add(fieldVM41);
        fieldValMap.valueMap.add(fieldVM42);
        fieldValMap.valueMap.add(fieldVM43);
        fieldValMap.valueMap.add(fieldVM44);
        fieldValMap.valueMap.add(fieldVM45);
        fieldValMap.valueMap.add(fieldVM46);
        
        fieldValMap.valueMap.addAll(getCommonFieldsDefinition()); //Commom fields for all 4 objects
        
        fieldValMap.valueMap.add(fieldVM52);
        fieldValMap.valueMap.add(fieldVM53);
        fieldValMap.valueMap.add(fieldVM54);
        fieldValMap.valueMap.add(fieldVM55);
        fieldValMap.valueMap.add(fieldVM56);
        fieldValMap.valueMap.add(fieldVM57);
        fieldValMap.valueMap.add(fieldVM58);
        fieldValMap.valueMap.add(fieldVM59);
        fieldValMap.valueMap.add(fieldVM60);
        fieldValMap.valueMap.add(fieldVM61);
        fieldValMap.valueMap.add(fieldVM130);
        fieldValMap.valueMap.add(fieldVM62);
        fieldValMap.valueMap.add(fieldVM63);
        fieldValMap.valueMap.add(fieldVM64);
        fieldValMap.valueMap.add(fieldVM65);
        fieldValMap.valueMap.add(fieldVM66);
        fieldValMap.valueMap.add(fieldVM67);
        fieldValMap.valueMap.add(fieldVM68);
        fieldValMap.valueMap.add(fieldVM69);
        fieldValMap.valueMap.add(fieldVM70);
        fieldValMap.valueMap.add(fieldVM71);
        fieldValMap.valueMap.add(fieldVM72);
        fieldValMap.valueMap.add(fieldVM73);
        fieldValMap.valueMap.add(fieldVM74);
        fieldValMap.valueMap.add(fieldVM75);
        fieldValMap.valueMap.add(fieldVM76);
        fieldValMap.valueMap.add(fieldVM77);
        fieldValMap.valueMap.add(fieldVM78);
        fieldValMap.valueMap.add(fieldVM79);
        fieldValMap.valueMap.add(fieldVM80);
        fieldValMap.valueMap.add(fieldVM81);
        fieldValMap.valueMap.add(fieldVM82);
        fieldValMap.valueMap.add(fieldVM83);
        fieldValMap.valueMap.add(fieldVM84);
        fieldValMap.valueMap.add(fieldVM85);
        fieldValMap.valueMap.add(fieldVM86);
        fieldValMap.valueMap.add(fieldVM87);
        fieldValMap.valueMap.add(fieldVM88);
        fieldValMap.valueMap.add(fieldVM89);
        fieldValMap.valueMap.add(fieldVM131);
        fieldValMap.valueMap.add(fieldVM90);
        fieldValMap.valueMap.add(fieldVM91);
        fieldValMap.valueMap.add(fieldVM92);
        fieldValMap.valueMap.add(fieldVM93);
        fieldValMap.valueMap.add(fieldVM94);
        fieldValMap.valueMap.add(fieldVM95);
        fieldValMap.valueMap.add(fieldVM96);
        fieldValMap.valueMap.add(fieldVM97);
        fieldValMap.valueMap.add(fieldVM98);
        fieldValMap.valueMap.add(fieldVM99);
        fieldValMap.valueMap.add(fieldVM100);
        fieldValMap.valueMap.add(fieldVM101);
        fieldValMap.valueMap.add(fieldVM102);
        fieldValMap.valueMap.add(fieldVM103);
        fieldValMap.valueMap.add(fieldVM104);
        fieldValMap.valueMap.add(fieldVM105);
        fieldValMap.valueMap.add(fieldVM106);
        fieldValMap.valueMap.add(fieldVM107);
        fieldValMap.valueMap.add(fieldVM108);
        fieldValMap.valueMap.add(fieldVM109);
        fieldValMap.valueMap.add(fieldVM110);
        fieldValMap.valueMap.add(fieldVM132);
        fieldValMap.valueMap.add(fieldVM133);
        fieldValMap.valueMap.add(fieldVM111);
        fieldValMap.valueMap.add(fieldVM112);
        fieldValMap.valueMap.add(fieldVM113);
        fieldValMap.valueMap.add(fieldVM114);
        fieldValMap.valueMap.add(fieldVM115);
        fieldValMap.valueMap.add(fieldVM116);
        fieldValMap.valueMap.add(fieldVM117);
        fieldValMap.valueMap.add(fieldVM118);
        fieldValMap.valueMap.add(fieldVM119);
        fieldValMap.valueMap.add(fieldVM120);
        fieldValMap.valueMap.add(fieldVM121);
        fieldValMap.valueMap.add(fieldVM122);
        fieldValMap.valueMap.add(fieldVM123);
        fieldValMap.valueMap.add(fieldVM124);
        fieldValMap.valueMap.add(fieldVM125);
        fieldValMap.valueMap.add(fieldVM126);
        fieldValMap.valueMap.add(fieldVM127);
        fieldValMap.valueMap.add(fieldVM128);
        fieldValMap.valueMap.add(fieldVM129);
        fieldValMap.valueMap.add(fieldVM135);
        fieldValMap.valueMap.add(fieldVM134);
        
        valMap.valueMap.add(fieldValMap); //Add Field Property
    
        INTF_DataSync.logMethodEndTS(intMethodCount,'getUserObjDescribe');
        
        return valMap;
    }
    
    public INTF_WebServicesDef.SVMXMap getBusinessHoursObjDescribe(){
    
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getBusinessHoursObjDescribe');
        
        INTF_WebServicesDef.SVMXMap valMap = new INTF_WebServicesDef.SVMXMap('OBJECT','businesshours');
        valMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
    
        //ObjectProperty
        INTF_WebServicesDef.SVMXMap ObjValMap = new INTF_WebServicesDef.SVMXMap('OBJECTPROPERTY','');
        ObjValMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        //Object property Object Definition
        INTF_WebServicesDef.SVMXMap objPropObjDef = new INTF_WebServicesDef.SVMXMap('OBJECTDEFINITION','');
        objPropObjDef.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('KEYPREFIX','01m'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Business Hours'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('PLURALLABEL','Business Hours'));
        objPropObjDef.valueMap.add(new INTF_WebServicesDef.SVMXMap('QUERYABLE','true'));
        
        //Object property Recordtype
        INTF_WebServicesDef.SVMXMap objPropRecType = new INTF_WebServicesDef.SVMXMap('RECORDTYPE','');
        objPropRecType.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        ObjValMap.valueMap.add(objPropObjDef);
        ObjValMap.valueMap.add(objPropRecType);
        
        valMap.valueMap.add(ObjValMap);  //Add Object Property
        
        //FieldProperty
        INTF_WebServicesDef.SVMXMap fieldValMap = new INTF_WebServicesDef.SVMXMap('FIELDPROPERTY','');
        fieldValMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        // 15 valuemaps per fieldProperty - 6 valueMaps per field - 
        INTF_WebServicesDef.SVMXMap fieldVM1 = new INTF_WebServicesDef.SVMXMap('FIELD','Id');
        fieldVM1.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Business Hours ID'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','ID'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM2 = new INTF_WebServicesDef.SVMXMap('FIELD','Name');
        fieldVM2.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Business Hours Name'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','STRING'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','80'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','TRUE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM3 = new INTF_WebServicesDef.SVMXMap('FIELD','IsActive');
        fieldVM3.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Active'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        INTF_WebServicesDef.SVMXMap fieldVM4 = new INTF_WebServicesDef.SVMXMap('FIELD','IsDefault');
        fieldVM4.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Default Business Hours'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        INTF_WebServicesDef.SVMXMap fieldVM5 = new INTF_WebServicesDef.SVMXMap('FIELD','SundayStartTime');
        fieldVM5.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Sunday Start'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        INTF_WebServicesDef.SVMXMap fieldVM6 = new INTF_WebServicesDef.SVMXMap('FIELD','SundayEndTime');
        fieldVM6.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Sunday End'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM6.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));

        INTF_WebServicesDef.SVMXMap fieldVM7 = new INTF_WebServicesDef.SVMXMap('FIELD','MondayStartTime');
        fieldVM7.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Monday Start'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM7.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        INTF_WebServicesDef.SVMXMap fieldVM8 = new INTF_WebServicesDef.SVMXMap('FIELD','MondayEndTime');
        fieldVM8.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Monday End'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));

        INTF_WebServicesDef.SVMXMap fieldVM9 = new INTF_WebServicesDef.SVMXMap('FIELD','TuesdayStartTime');
        fieldVM9.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Tuesday Start'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM9.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        INTF_WebServicesDef.SVMXMap fieldVM10 = new INTF_WebServicesDef.SVMXMap('FIELD','TuesdayEndTime');
        fieldVM10.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Tuesday End'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM10.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));

        INTF_WebServicesDef.SVMXMap fieldVM11 = new INTF_WebServicesDef.SVMXMap('FIELD','WednesdayStartTime');
        fieldVM11.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Wednesday Start'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM11.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        INTF_WebServicesDef.SVMXMap fieldVM12 = new INTF_WebServicesDef.SVMXMap('FIELD','WednesdayEndTime');
        fieldVM12.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Wednesday End'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));

        INTF_WebServicesDef.SVMXMap fieldVM13 = new INTF_WebServicesDef.SVMXMap('FIELD','ThursdayStartTime');
        fieldVM13.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Thursday Start'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        INTF_WebServicesDef.SVMXMap fieldVM14 = new INTF_WebServicesDef.SVMXMap('FIELD','ThursdayEndTime');
        fieldVM14.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Thursday End'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));

        INTF_WebServicesDef.SVMXMap fieldVM15 = new INTF_WebServicesDef.SVMXMap('FIELD','FridayStartTime');
        fieldVM15.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Friday Start'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        INTF_WebServicesDef.SVMXMap fieldVM16 = new INTF_WebServicesDef.SVMXMap('FIELD','FridayEndTime');
        fieldVM16.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Friday End'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM16.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));

        INTF_WebServicesDef.SVMXMap fieldVM17 = new INTF_WebServicesDef.SVMXMap('FIELD','SaturdayStartTime');
        fieldVM17.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Saturday Start'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM17.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        INTF_WebServicesDef.SVMXMap fieldVM18 = new INTF_WebServicesDef.SVMXMap('FIELD','SaturdayEndTime');
        fieldVM18.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Saturday End'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TIME'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));

        INTF_WebServicesDef.SVMXMap fieldVM19 = new INTF_WebServicesDef.SVMXMap('FIELD','TimeZoneSidKey');
        fieldVM19.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Time Zone'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM19.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
            
        fieldValMap.valueMap.add(fieldVM1);
        fieldValMap.valueMap.add(fieldVM2);
        fieldValMap.valueMap.add(fieldVM3);
        fieldValMap.valueMap.add(fieldVM4);
        fieldValMap.valueMap.add(fieldVM5);
        fieldValMap.valueMap.add(fieldVM6);
        fieldValMap.valueMap.add(fieldVM7);
        fieldValMap.valueMap.add(fieldVM8);
        fieldValMap.valueMap.add(fieldVM9);
        fieldValMap.valueMap.add(fieldVM10);
        fieldValMap.valueMap.add(fieldVM11);
        fieldValMap.valueMap.add(fieldVM12);
        fieldValMap.valueMap.add(fieldVM13);
        fieldValMap.valueMap.add(fieldVM14);
        fieldValMap.valueMap.add(fieldVM15);
        fieldValMap.valueMap.add(fieldVM16);
        fieldValMap.valueMap.add(fieldVM17);
        fieldValMap.valueMap.add(fieldVM18); 
        fieldValMap.valueMap.add(fieldVM19);        

        fieldValMap.valueMap.addAll(getCommonFieldsDefinition());
        
        valMap.valueMap.add(fieldValMap); //Add Field Property
        
        INTF_DataSync.logMethodEndTS(intMethodCount,'getBusinessHoursObjDescribe');
        
        return valMap;
    }
    
    public List<SVMXC.INTF_WebServicesDef.SVMXMap> getCommonFieldsDefinition(){
    
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getCommonFieldsDefinition');
        
        List<INTF_WebServicesDef.SVMXMap> fieldsDefinitionVM = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap fieldVM1 = new INTF_WebServicesDef.SVMXMap('FIELD','CreatedDate');
        fieldVM1.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Created Date'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        fieldsDefinitionVM.add(fieldVM1);
        
        INTF_WebServicesDef.SVMXMap fieldVM2 = new INTF_WebServicesDef.SVMXMap('FIELD','CreatedById');
        fieldVM2.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','User'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','CreatedBy'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Created By ID'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));  
        
        fieldsDefinitionVM.add(fieldVM2);
        
        INTF_WebServicesDef.SVMXMap fieldVM3 = new INTF_WebServicesDef.SVMXMap('FIELD','LastModifiedDate');
        fieldVM3.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Last Modified Date'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
        
        fieldsDefinitionVM.add(fieldVM3);
        
        INTF_WebServicesDef.SVMXMap fieldVM4 = new INTF_WebServicesDef.SVMXMap('FIELD','LastModifiedById');
        fieldVM4.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','User'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','LastModifiedBy'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Last Modified By ID'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));   
        
        fieldsDefinitionVM.add(fieldVM4);
        
        INTF_WebServicesDef.SVMXMap fieldVM5 = new INTF_WebServicesDef.SVMXMap('FIELD','SystemModstamp');
        fieldVM5.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','System Modstamp'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM5.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));    
        
        fieldsDefinitionVM.add(fieldVM5);
        
        INTF_DataSync.logMethodEndTS(intMethodCount,'getCommonFieldsDefinition');
        
        return fieldsDefinitionVM;
    }
    
    public List<SVMXC.INTF_WebServicesDef.SVMXMap> listOfCommonMaps(){
    
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('listOfCommonMaps');
    
        List<INTF_WebServicesDef.SVMXMap> fieldValMap = new List<INTF_WebServicesDef.SVMXMap>();
        // 49 valuemaps per fieldProperty - 6 valueMaps per field - 
        INTF_WebServicesDef.SVMXMap fieldVM1 = new INTF_WebServicesDef.SVMXMap('FIELD','Id');
        fieldVM1.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Activity ID'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','ID'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM1.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM1);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM2 = new INTF_WebServicesDef.SVMXMap('FIELD','WhoId');
        fieldVM2.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','Lead'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','Who'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Name ID'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM2.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM2);
    
        INTF_WebServicesDef.SVMXMap fieldVM3 = new INTF_WebServicesDef.SVMXMap('FIELD','WhatId');
        fieldVM3.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','Account'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','What'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Related To ID'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM3.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM3);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM4 = new INTF_WebServicesDef.SVMXMap('FIELD','Subject');
        fieldVM4.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Subject'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','COMBOBOX'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','255'));
        fieldVM4.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','TRUE'));
    
        fieldValMap.add(fieldVM4);
    
        INTF_WebServicesDef.SVMXMap fieldVM8 = new INTF_WebServicesDef.SVMXMap('FIELD','ActivityDate');
        fieldVM8.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Due Date Only'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATE'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM8.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM8);
    
        INTF_WebServicesDef.SVMXMap fieldVM12 = new INTF_WebServicesDef.SVMXMap('FIELD','Description');
        fieldVM12.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Description'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','TEXTAREA'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','32000'));
        fieldVM12.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM12);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM13 = new INTF_WebServicesDef.SVMXMap('FIELD','AccountId');
        fieldVM13.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','Account'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','Account'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Account ID'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM13.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM13);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM14 = new INTF_WebServicesDef.SVMXMap('FIELD','OwnerId');
        fieldVM14.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','User'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','Owner'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Assigned To ID'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM14.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM14);
    
        INTF_WebServicesDef.SVMXMap fieldVM15 = new INTF_WebServicesDef.SVMXMap('FIELD','Type');
        fieldVM15.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Type'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM15.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM15);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM18 = new INTF_WebServicesDef.SVMXMap('FIELD','IsDeleted');
        fieldVM18.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Deleted'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM18.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM18);
    
        INTF_WebServicesDef.SVMXMap fieldVM22 = new INTF_WebServicesDef.SVMXMap('FIELD','CreatedDate');
        fieldVM22.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Created Date'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM22.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM22);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM23 = new INTF_WebServicesDef.SVMXMap('FIELD','CreatedById');
        fieldVM23.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','User'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','CreatedBy'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Created By ID'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM23.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM23);
    
        INTF_WebServicesDef.SVMXMap fieldVM24 = new INTF_WebServicesDef.SVMXMap('FIELD','LastModifiedDate');
        fieldVM24.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Last Modified Date'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM24.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM24);
    
        INTF_WebServicesDef.SVMXMap fieldVM25 = new INTF_WebServicesDef.SVMXMap('FIELD','LastModifiedById');
        fieldVM25.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','User'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME','LastModifiedBy'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Last Modified By ID'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM25.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM25);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM26 = new INTF_WebServicesDef.SVMXMap('FIELD','SystemModstamp');
        fieldVM26.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','System Modstamp'));
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM26.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM26);
    
        INTF_WebServicesDef.SVMXMap fieldVM27 = new INTF_WebServicesDef.SVMXMap('FIELD','IsArchived');
        fieldVM27.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Archived'));
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM27.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM27);
    
        INTF_WebServicesDef.SVMXMap fieldVM28 = new INTF_WebServicesDef.SVMXMap('FIELD','IsVisibleInSelfService');
        fieldVM28.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Public'));
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM28.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM28);
    
        INTF_WebServicesDef.SVMXMap fieldVM29 = new INTF_WebServicesDef.SVMXMap('FIELD','RecurrenceActivityId');
        fieldVM29.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO','Event'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME',''));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','REFERENCE'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Recurrence Activity ID'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','false'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','18'));
        fieldVM29.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM29);
    
        INTF_WebServicesDef.SVMXMap fieldVM30 = new INTF_WebServicesDef.SVMXMap('FIELD','IsRecurrence');
        fieldVM30.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Create Recurring Series of Events'));
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','false'));
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM30.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM30);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM32 = new INTF_WebServicesDef.SVMXMap('FIELD','RecurrenceEndDateOnly');
        fieldVM32.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','End Date'));
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATE'));
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM32.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM32);
    
        INTF_WebServicesDef.SVMXMap fieldVM33 = new INTF_WebServicesDef.SVMXMap('FIELD','RecurrenceTimeZoneSidKey');
        fieldVM33.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Recurrence Time Zone'));
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM33.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM33);
    
        INTF_WebServicesDef.SVMXMap fieldVM34 = new INTF_WebServicesDef.SVMXMap('FIELD','RecurrenceType');
        fieldVM34.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Recurrence Type'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM34.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM34);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM35 = new INTF_WebServicesDef.SVMXMap('FIELD','RecurrenceInterval');
        fieldVM35.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Recurrence Interval'));
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','INTEGER'));
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM35.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM35);
    
        INTF_WebServicesDef.SVMXMap fieldVM36 = new INTF_WebServicesDef.SVMXMap('FIELD','RecurrenceDayOfWeekMask');
        fieldVM36.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Recurrence Day of Week Mask'));
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','INTEGER'));
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM36.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM36);
    
        INTF_WebServicesDef.SVMXMap fieldVM37 = new INTF_WebServicesDef.SVMXMap('FIELD','RecurrenceDayOfMonth');
        fieldVM37.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Recurrence Day of Month'));
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','INTEGER'));
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM37.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM37);
    
        INTF_WebServicesDef.SVMXMap fieldVM38 = new INTF_WebServicesDef.SVMXMap('FIELD','RecurrenceInstance');
        fieldVM38.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Recurrence Instance'));
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM38.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM38);
    
        INTF_WebServicesDef.SVMXMap fieldVM39 = new INTF_WebServicesDef.SVMXMap('FIELD','RecurrenceMonthOfYear');
        fieldVM39.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Recurrence Month of Year'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','40'));
        fieldVM39.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM39);
    
        INTF_WebServicesDef.SVMXMap fieldVM40 = new INTF_WebServicesDef.SVMXMap('FIELD','ReminderDateTime');
        fieldVM40.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Reminder Date/Time'));
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM40.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM40);
    
        INTF_WebServicesDef.SVMXMap fieldVM41 = new INTF_WebServicesDef.SVMXMap('FIELD','IsReminderSet');
        fieldVM41.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Reminder Set'));
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','BOOLEAN'));
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM41.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM41);
    
        INTF_WebServicesDef.SVMXMap fieldVM42 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__End_Time__c');
        fieldVM42.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','End Time'));
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM42.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM42);
    
        INTF_WebServicesDef.SVMXMap fieldVM43 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Driving_Time__c');
        fieldVM43.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRECISION','8'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCALE','0'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DOUBLE'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Travel Time to Workorder Location (Mins)'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM43.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM43);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM44 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Driving_Time_Home__c');
        fieldVM44.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRECISION','8'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCALE','0'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DOUBLE'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Travel Time Back to Home Base (Mins)'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM44.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM44);
    
        INTF_WebServicesDef.SVMXMap fieldVM45 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Overhead_Time_Before__c');
        fieldVM45.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRECISION','8'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCALE','0'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DOUBLE'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Overhead Time at Start of the Job (Mins)'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM45.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM45);
    
        INTF_WebServicesDef.SVMXMap fieldVM46 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Overhead_Time_After__c');
        fieldVM46.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRECISION','8'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCALE','0'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DOUBLE'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Overhead Time at End of the Job (Mins)'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM46.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM46);
    
        INTF_WebServicesDef.SVMXMap fieldVM47 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Service_Duration__c');
        fieldVM47.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM47.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRECISION','18'));
        fieldVM47.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCALE','0'));
        fieldVM47.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DOUBLE'));
        fieldVM47.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Service Time (in Seconds)'));
        fieldVM47.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM47.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM47.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM47.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM47);
    
        INTF_WebServicesDef.SVMXMap fieldVM48 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Break_Time_Total__c');
        fieldVM48.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM48.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRECISION','8'));
        fieldVM48.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCALE','0'));
        fieldVM48.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DOUBLE'));
        fieldVM48.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Total Break Time (Mins)'));
        fieldVM48.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM48.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM48.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM48.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM48);
    
        INTF_WebServicesDef.SVMXMap fieldVM49 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Event_Type__c');
        fieldVM49.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM49.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Event Type'));
        fieldVM49.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','PICKLIST'));
        fieldVM49.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM49.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM49.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','255'));
        fieldVM49.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM49);
    
    
        INTF_WebServicesDef.SVMXMap fieldVM50 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__SM_Optimizer_Message_Creation_Date_Time__c');
        fieldVM50.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM50.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Optimizer Message Creation Date Time'));
        fieldVM50.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM50.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM50.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM50.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM50.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM50);
    
        INTF_WebServicesDef.SVMXMap fieldVM51 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Idle_Time__c');
        fieldVM51.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM51.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRECISION','8'));
        fieldVM51.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCALE','0'));
        fieldVM51.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DOUBLE'));
        fieldVM51.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Idle Time(OBSOLETE: DO NOT USE)'));
        fieldVM51.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM51.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM51.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM51.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM51);
    
        INTF_WebServicesDef.SVMXMap fieldVM52 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__SM_Idle_Time__c');
        fieldVM52.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRECISION','8'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCALE','0'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DOUBLE'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Idle Time for the Job (Mins)'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM52.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM52);
    
        INTF_WebServicesDef.SVMXMap fieldVM53 = new INTF_WebServicesDef.SVMXMap('FIELD','SVMXC__Start_Time__c');
        fieldVM53.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
    
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('LABEL','Start Time'));
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('TYPE','DATETIME'));
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE','true'));
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE','true'));
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('LENGTH','0'));
        fieldVM53.valueMap.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD','FALSE'));
    
        fieldValMap.add(fieldVM53);
        
        INTF_DataSync.logMethodEndTS(intMethodCount,'listOfCommonMaps');
        
        return fieldValMap;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getPageLayouts(INTF_WebServicesDef.INTF_SFMRequest req)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getPageLayouts');        
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_MobileGetPageLayout getPageLayout = new INTF_MobileGetPageLayout();
        set<string> lstPageIds = new set<string>();
        lstPageIds.addAll(req.values);
        res.eventName = req.eventName;
        res.eventType = req.eventType;
        res.success = true;
        res.pageUI = new list<INTF_WebServicesDef.INTF_Response_PageUI>();
        
        list<INTF_WebServicesDef.INTF_Response_PageUI> lstPgUI = getPageLayout.INTF_GetPageLayout(lstPageIds, req.value);
        if(lstPgUI != null)
            res.pageUI.addAll(lstPgUI);
        
        if(INTF_MobileGetPageLayout.batchedPageLayouts != null && INTF_MobileGetPageLayout.batchedPageLayouts.size() > 0)
        {   
            res.values = new list<string>();
            res.values.addAll(INTF_MobileGetPageLayout.batchedPageLayouts);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getPageLayouts');
        return res;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getRecordType(INTF_WebServicesDef.INTF_SFMRequest req)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getRecordType');
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id, Name, SobjectType FROM RecordType WHERE Id IN : req.values');
        List<RecordType> lstRecordTypes = [SELECT Id, Name, SobjectType FROM RecordType WHERE Id IN : req.values];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        res.valueMap.add(new INTF_WebServicesDef.SVMXMap('', JSON.serialize(lstRecordTypes)));
        system.debug('lstRecordTypes = ' + lstRecordTypes.size() + '; Records = ' + lstRecordTypes);
        
        res.eventName = req.eventName;
        res.eventType = req.eventType;
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getRecordType');
        return res;
    }
    
    public map<String, String> getClientData(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getClientData');
        if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
        {
            for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
            {
                for(String strInfo : clientInform.clientInfo)
                {
                    system.debug(LoggingLevel.WARN, 'strInfo = ' + strInfo);
                    if(strInfo != null && strInfo.length() > 0)
                    {
                        if(strInfo.split(':',2).size() == 2)
                            mapClientDetails.put(strInfo.split(':',2)[0], (strInfo.split(':',2)[1]).trim());
                    }
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getClientData');
        return mapClientDetails;
    }
    
    public void setPIQProfile(String profileId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getPIQProfile');
        List<SVMXC__ServiceMax_Config_Data__c> listOfConfigData = getSettings(new Set<String>(),new Set<String>(),new set<String>{'PRODIQ002_SET001'},profileId);
        
        if(listOfConfigData!=NULL && listOfConfigData.size()>0)
        {
            isProductIQEnabled = Boolean.valueOf(listOfConfigData[0].SVMXC__Internal_Value__c);
        }
        if(isProductIQEnabled)
        {
            INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Contents__c From SVMXC__ProductIQProfile__c Where SVMXC__ServiceMax_Profile__c=:profileId');        
            List<SVMXC__ProductIQProfile__c> listOfpIQProfile = [Select Id, SVMXC__Contents__c From SVMXC__ProductIQProfile__c Where SVMXC__ServiceMax_Profile__c=:profileId];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(!listOfpIQProfile.isEmpty())
            {
                //ProductIQConfiguration.Profile prof =(ProductIQConfiguration.Profile)JSON.deserialize(listOfpIQProfile[0].SVMXC__Contents__c,ProductIQConfiguration.Profile.class);
                productIQProfile = (ProductIQConfiguration.Profile)JSON.deserialize(listOfpIQProfile[0].SVMXC__Contents__c,ProductIQConfiguration.Profile.class);
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getPIQProfile');
    }
    
    public Set<String> getProductIQSFMSearch(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getProductIQSFMSearch');
        Set<String> setOfSearchIds = new Set<String>();
        if(productIQProfile !=NULL && productIQProfile.search !=NULL && !productIQProfile.search.isEmpty())
        {
            for(ProductIQConfiguration.SearchObject newObject:productIQProfile.search)
            {
                if(newObject.searches !=NULL && !newObject.searches.isEmpty())
                {
                    for(ProductIQConfiguration.Search newSearch:newObject.searches)
                    {
                        setOfSearchIds.add(newSearch.sfdcId);
                        setOfSearchIds.add(newSearch.searchName);
                    }
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getProductIQSFMSearch');
        return setOfSearchIds;
    }
   
    public Set<string> getProductIQProcesses(){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getProductIQProcesses');
        Set<String> setOfProcessIds = new Set<String>();
        
        String strClause = '';
        String strSoql = 'Select Id from SVMXC__ServiceMax_Processes__c where SVMXC__Purpose__c = \'STANDALONE EDIT\' AND Recordtype.Name=\'Target Manager\' ';
        
        if(isProductIQEnabled && productIQProfile != NULL){
            if(productIQProfile.locationEditProces != NULL && productIQProfile.locationEditProces.size() > 0 && productIQProfile.locationEditProces[0] != NULL && ((productIQProfile.locationEditProces[0].sfdcId != NULL && productIQProfile.locationEditProces[0].sfdcId != '') || (productIQProfile.locationEditProces[0].processId != NULL && productIQProfile.locationEditProces[0].processId != ''))){
                setOfProcessIds.add(productIQProfile.locationEditProces[0].sfdcId); //There is just one process per Location
                setOfProcessIds.add(productIQProfile.locationEditProces[0].processId); 
            }else{
                strClause += ' (SVMXC__Page_Layout__r.SVMXC__Object_Name__c = \'SVMXC__Site__c\' AND SVMXC__ProcessID__c = \'View_And_Edit_Location\') ';
            }
            
            if(productIQProfile.ibEditProces != NULL && productIQProfile.ibEditProces.size() > 0 && productIQProfile.ibEditProces[0] != NULL && ((productIQProfile.ibEditProces[0].sfdcId != NULL && productIQProfile.ibEditProces[0].sfdcId != '') || (productIQProfile.ibEditProces[0].processId != NULL && productIQProfile.ibEditProces[0].processId != ''))){
                setOfProcessIds.add(productIQProfile.ibEditProces[0].sfdcId); //One process per IB
                setOfProcessIds.add(productIQProfile.ibEditProces[0].processId);
            }else{
                if(strClause != ''){
                    strClause += ' OR '; 
                }   
                strClause += ' (SVMXC__Page_Layout__r.SVMXC__Object_Name__c = \'SVMXC__Installed_Product__c\' AND SVMXC__ProcessID__c = \'View_And_Edit_Installed_Product\') ';
            }
            system.debug(LoggingLevel.WARN, 'PIQ default process where Clause = '+strClause);
            
        }else if(isProductIQEnabled && productIQProfile == NULL){
            //No productIQ Profile available but PIQ enabled - get the default processes for both IB and location
            strClause += ' (SVMXC__Page_Layout__r.SVMXC__Object_Name__c = \'SVMXC__Site__c\' AND SVMXC__ProcessID__c = \'View_And_Edit_Location\') OR (SVMXC__Page_Layout__r.SVMXC__Object_Name__c = \'SVMXC__Installed_Product__c\' AND SVMXC__ProcessID__c = \'View_And_Edit_Installed_Product\') ';
        }
        
        if(strClause != ''){
            strSoql += ' AND ( '+strClause+' ) LIMIT 2';
                
            system.debug(LoggingLevel.WARN, 'PIQ default process query = '+strSoql);
            INTF_DataSync.logSOQL(intMethodCount, strSoql);
            List<SVMXC__ServiceMax_Processes__c> lstDefaultProcess = Database.query(strSoql);
                
            if(lstDefaultProcess != NULL && !lstDefaultProcess.isEmpty()){
                for(SVMXC__ServiceMax_Processes__c eachProc : lstDefaultProcess){
                    setOfProcessIds.add(eachProc.ID);
                }
            }
        }
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getProductIQProcesses');
        return setOfProcessIds;
    }
    //Getting Mobile Inventory configuration for the Technician's Group Profile and sending to the response.
    public INTF_WebServicesDef.INTF_SFMResponse getMobileInventoryConfig(INTF_WebServicesDef.INTF_SFMRequest req,String svmxGrpProfileId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getProductIQProcesses');    
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        response.eventName=req.eventName;
        response.eventType=req.eventType;
        //Querying the Mobile Inventory Configuration for Technician's Group Profile.        
        INTF_DataSync.logSOQL(intMethodCount, 'Select Id,SVMXC__SM_Content__c From SVMXC__SM_Spare_Parts_Config__c Where SVMXC__SM_ServiceMax_Profile__c=:svmxGrpProfileId Limit 1');
        List<SVMXC__SM_Inventory_Config__c> newConfig = [Select Id,SVMXC__SM_Content__c From SVMXC__SM_Inventory_Config__c Where SVMXC__SM_ServiceMax_Profile__c=:svmxGrpProfileId Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA      
        String content = '';
        if(newConfig !=NULL && !newConfig.isEmpty() && newConfig[0].SVMXC__SM_Content__c !=NULL)
        {
            content = newConfig[0].SVMXC__SM_Content__c;
        }
        //Adding to the response.        
        INTF_WebServicesDef.SVMXMap mobileConfigMap = new INTF_WebServicesDef.SVMXMap();
        mobileConfigMap.key='MOBILE_INVENTORY';
        mobileConfigMap.value=content;    
        mobileConfigMap.values = new List<String>();
        mobileConfigMap.values.add('Product2');
        mobileConfigMap.values.add('SVMXC__Product_Stock__c');
        mobileConfigMap.values.add('SVMXC__Product_Serial__c');   
        response.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        response.valueMap.add(mobileConfigMap);                                    
        return response;
    } 
    
    //Query the device_Mobile_Config
    public String getDeviceMobileConfig(string svmxProfileId, String deviceType){
        
        string strDeviceConfId = '';
        if(deviceType != NULL && deviceType != ''){
            if(deviceType == 'MFL'){   //MFL will be considered as Windows
                deviceType = 'Windows';
            }
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA    
            List<SVMXC__SM_Device_Mobile_Config__c> lstDeviceSetting = [select Id, SVMXC__SM_Device_Type__c, SVMXC__SM_IsDefault__c from SVMXC__SM_Device_Mobile_Config__c
                                where SVMXC__SM_Access_Configuration_Profile__c =: svmxProfileId AND ( SVMXC__SM_Device_Type__c INCLUDES (:deviceType) 
                                OR (SVMXC__SM_IsDefault__c =: TRUE) ) ];
                                
            for(SVMXC__SM_Device_Mobile_Config__c devSet : lstDeviceSetting){
            
                system.debug(LoggingLevel.WARN, ' Device types are : '+devSet.SVMXC__SM_Device_Type__c);
            
                if(devSet.SVMXC__SM_Device_Type__c.containsIgnoreCase(devicetype)){
                    strDeviceConfId = devSet.Id;   //found the matching record 
                    break;
                }else if(devSet.SVMXC__SM_IsDefault__c){
                    strDeviceConfId = devSet.Id;
                }
            }
        }
        system.debug(LoggingLevel.WARN,' Device config record ID : '+strDeviceConfId);
        return strDeviceConfId;                            
    }

}