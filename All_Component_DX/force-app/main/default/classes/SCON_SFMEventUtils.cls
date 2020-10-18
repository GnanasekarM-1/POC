/* Security Scanned */
public with sharing class SCON_SFMEventUtils
{
    public SVMXC.INTF_BuildSobjectFromKeyValue clsBuildSobjfromKeyValue = new SVMXC.INTF_BuildSobjectFromKeyValue();
    public SCON_SFMEventUtils(){}

    // Method to Actiave Service Contract.
    public SVMXC.INTF_WebServicesDef.INTF_PageData activateContract(SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqSCON)
    {
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        lstStringMap =  reqSCON.stringMap;
        system.debug(LoggingLevel.WARN, 'Service Contract request:'+reqSCON);
        SVMXC.INTF_WebServicesDef.INTF_PageData wrpObjPageDataResp = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        Boolean isNextStepURL = false;
        String strNextStepURL = '';
        savepoint sp;
        try
        {
            sp = Database.setSavepoint();
            wrpObjPageDataResp.response.success = true;
            SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject wrpObjHdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
            if(lstStringMap != null && lstStringMap.size() > 0){
                String strRecordId = '';
                String strNextStepId = '';
                for(Integer i =0;i<lstStringMap.size();i++){
                    if(lstStringMap[i].key.equals('SVMX_recordId') && lstStringMap[i].value != null)
                        strRecordId = lstStringMap[i].value;
                    else if(lstStringMap[i].key.equals('SVMX_NxtStepID') && lstStringMap[i].value != null){
                        strNextStepId = lstStringMap[i].value;
                    }   
                }
                if(strRecordId != '' && strNextStepId != ''){
                    SVMXC.ServiceFlowWizard_Utils sfwUtils = new SVMXC.ServiceFlowWizard_Utils();
                    strNextStepURL = sfwUtils.SVMX_GetNextStepURL(strRecordId,strNextStepId);
                    if(strNextStepURL != '' )
                        isNextStepURL = true;
                }
            }   
            
            if(reqSCON.headerRecord != null)
                wrpObjHdrTargetRecordObject = reqSCON.headerRecord;

            List<SVMXC.INTF_WebServicesDef.INTF_Record> lstwrapObjHeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
            List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstwrpObjHdrTargetRecordAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            String strHeaderObjName = '';
            if(wrpObjHdrTargetRecordObject.objName != null && wrpObjHdrTargetRecordObject.objName.length() > 0)
                strHeaderObjName = wrpObjHdrTargetRecordObject.objName; 
            if(wrpObjHdrTargetRecordObject.records != null && wrpObjHdrTargetRecordObject.records.size() > 0)
                lstwrapObjHeaderRecord = wrpObjHdrTargetRecordObject.records;

            string strTargetRecordId = null;
            if(lstwrapObjHeaderRecord.size() > 0)
            {
                if(lstwrapObjHeaderRecord[0].targetRecordId != null && lstwrapObjHeaderRecord[0].targetRecordId.length() > 0)
                    strTargetRecordId = lstwrapObjHeaderRecord[0].targetRecordId;
                if(lstwrapObjHeaderRecord[0].targetRecordAsKeyValue != null && lstwrapObjHeaderRecord[0].targetRecordAsKeyValue.size() > 0 && strHeaderObjName.length() > 0)
                    lstwrpObjHdrTargetRecordAsKeyValue = lstwrapObjHeaderRecord[0].targetRecordAsKeyValue;
            }

            // Building list of SCON with action UPDATE, INSERT.
            list<Sobject> lstSCON = new list<Sobject>();
            Map<String,Sobject> mapAction_SCON =  clsBuildSobjfromKeyValue.BuildSobjectFromKeyValue(lstwrpObjHdrTargetRecordAsKeyValue,strHeaderObjName,null,null);

            lstSCON = mapAction_SCON.values();
            if(lstSCON != null && lstSCON.size() == 1)
            {
                if(Date.valueOf(lstSCON[0].get('SVMXC__End_Date__c')) < system.today())
                {
                    wrpObjPageDataResp.response.success = false;
                    wrpObjPageDataResp.response.message = system.label.SCON001_TAG009;
                    return wrpObjPageDataResp;
                }
                lstSCON[0].put('SVMXC__Active__c',true);
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                update lstSCON;
            }

            Boolean isCreatePMPlanOnActivation = true;
            Map<String, String> mapSCON1SettingList = new Map<String, String>();
            mapSCON1SettingList = (new COMM_Utils_ManageSettings()).SVMX_getSettingList('SCON001');
            if(mapSCON1SettingList != NULL && mapSCON1SettingList.get('SET007') != NULL)
                isCreatePMPlanOnActivation = Boolean.valueOf(mapSCON1SettingList.get('SET007'));
            
            //Create PM Plan for all the PM Offering records associated with Serviec Contract by using future invocation
            if(isCreatePMPlanOnActivation == true && strTargetRecordId != NULL && strTargetRecordId.length() > 0)
            {
                Integer MaxRecords = 4;
                Integer MaxFutureCallCount = 10;
                String strEmailId = '';
                String strProcessID = '';
                
                if(mapSCON1SettingList != NULL && mapSCON1SettingList.get('SET008') != NULL)
                    MaxFutureCallCount = Integer.valueOf(mapSCON1SettingList.get('SET008'));
                
                if(mapSCON1SettingList != NULL && mapSCON1SettingList.get('SET009') != NULL)
                    MaxRecords = Integer.valueOf(mapSCON1SettingList.get('SET009'));
                
                if(mapSCON1SettingList != NULL && mapSCON1SettingList.get('SET005') != NULL)
                    strEmailId = String.valueOf(mapSCON1SettingList.get('SET005'));
                
                if(mapSCON1SettingList != NULL && mapSCON1SettingList.get('SET006') != NULL)
                    strProcessID = String.valueOf(mapSCON1SettingList.get('SET006'));
                
                system.debug(LoggingLevel.WARN, 'Setting Values - MaxFutureCallCount: ' + MaxFutureCallCount + '; MaxRecords: ' + MaxRecords + '; strEmailId: ' + strEmailId + '; strProcessID: ' + strProcessID);
                    
                list<SVMXC__PM_Offering__c> lstPMOffer = new list<SVMXC__PM_Offering__c>();
                lstPMOffer = [Select SVMXC__Service_Contract__c, SVMXC__Service_Contract__r.Name, SVMXC__PM_Plan_Template__c, Id From SVMXC__PM_Offering__c where SVMXC__Service_Contract__c =: strTargetRecordId];
                
                if(lstPMOffer.size() > 0 && lstPMOffer.size() <= MaxFutureCallCount)
                {
                    for(SVMXC__PM_Offering__c objPMOffer : lstPMOffer)
                        generatePMPlanFromPMOffer(new List<String>{objPMOffer.Id}, objPMOffer.SVMXC__Service_Contract__r.Name, strEmailId, strProcessID);
                }
                else if(lstPMOffer.size() > 0 && lstPMOffer.size() > MaxFutureCallCount)
                {
                    String strContractName = lstPMOffer[0].SVMXC__Service_Contract__r.Name;
                    Map<Integer, List<String>> mapFutureCallPMOfferID = new Map<Integer, List<String>>();
                    Map<Id, SVMXC__PM_Offering__c> mapPMOfferTemp = new Map<Id, SVMXC__PM_Offering__c>();
                    mapPMOfferTemp.putAll(lstPMOffer);
                    
                    for(Integer i=0; i<MaxFutureCallCount; i++)
                    {
                        for(Id PMOfferID : mapPMOfferTemp.keySet())
                        {
                            mapPMOfferTemp.remove(PMOfferID);
                            if(!mapFutureCallPMOfferID.containsKey(i))
                                mapFutureCallPMOfferID.put(i, new List<String>());
                            mapFutureCallPMOfferID.get(i).add(PMOfferID);
                            if(mapFutureCallPMOfferID.get(i).size() == MaxRecords) 
                                break;
                        }
                    }
                    if(mapFutureCallPMOfferID != NULL && mapFutureCallPMOfferID.size() > 0)
                    {
                        for(Integer FutureCount : mapFutureCallPMOfferID.keySet())
                        {
                            if(MaxFutureCallCount >= FutureCount && mapFutureCallPMOfferID.get(FutureCount) != NULL && mapFutureCallPMOfferID.get(FutureCount).size() > 0)
                                generatePMPlanFromPMOffer(mapFutureCallPMOfferID.get(FutureCount), strContractName, strEmailId, strProcessID);
                        }
                    }
                }
            }
            wrpObjPageDataResp.response.message = system.label.COMM001_TAG058;
            list<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            if(isNextStepURL)
                stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO',strNextStepURL));
            else
                stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO',lstSCON[0].Id));
            wrpObjPageDataResp.response.stringMap = stringMap;
            return wrpObjPageDataResp;
        }
        catch(exception ex)
        {
            Database.rollback(sp);
            system.debug(LoggingLevel.WARN, 'ERROR'+ex.getMessage());
            wrpObjPageDataResp.response.success = false;
            wrpObjPageDataResp.response.message = ex.getmessage();
            return wrpObjPageDataResp;
        }
    }
    
    @Future
    public static void generatePMPlanFromPMOffer(List<String> lstPMOfferingIDs, String strContractName, String strEmailId, String strSFMProcessId)
    {
        if(lstPMOfferingIDs != NULL && lstPMOfferingIDs.size() > 0)
        {
            String EmailId = '';
            string strProcessID = 'CR_PM_FromPMOffering';
            Set<String> setPMPlanIDs = new Set<String>();
            Map<String, SVMXC__PM_Offering__c> mapPMOfferings = new Map<String, SVMXC__PM_Offering__c>();
            if(strEmailId != NULL && strEmailId.length()> 0)
                EmailId = strEmailId;
            
            if(strSFMProcessId != NULL && strSFMProcessId.length() > 0)
                strProcessID = strSFMProcessId;
            
            String strNotificationMsg = getTAG001() + '\n\n' + getTAG002() + '\n' + getTAG003() + ': ' + strContractName;
            strNotificationMsg += '\n' + getTAG005() + ': ' + lstPMOfferingIDs.size();
            
            try
            {
                String strPMPlanCreationDetails = '\n' + getTAG011();
                mapPMOfferings.putAll([Select Name, SVMXC__PM_Plan_Template__r.Name, Id From SVMXC__PM_Offering__c where Id IN: lstPMOfferingIDs]);
                
                for(String PMOfferID : lstPMOfferingIDs)
                {
                    if(mapPMOfferings.containsKey(PMOfferID) && mapPMOfferings.get(PMOfferID) != NULL)
                        strPMPlanCreationDetails += '\n' + getTAG012() + ' ' + mapPMOfferings.get(PMOfferID).Name;
                    SVMXC.INTF_WebServicesDef.INTF_Request objINTF_Req = new SVMXC.INTF_WebServicesDef.INTF_Request();
                    objINTF_Req.StringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                    if(PMOfferID != null && PMOfferID.length() > 0)
                        objINTF_Req.StringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('RECORDID', PMOfferID));
                    if(strProcessID != null && strProcessID.length() > 0)
                        objINTF_Req.StringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('TDMID', strProcessID));
                    
                    //Execute Background SFM Process
                    SVMXC.INTF_SFMEngine RunEngine = new SVMXC.INTF_SFMEngine();
                    SVMXC.INTF_WebServicesDef.INTF_Response objINTF_Response = new SVMXC.INTF_WebServicesDef.INTF_Response();
                    objINTF_Response = RunEngine.SVMX_ExecuteEngine(objINTF_Req);
                    system.debug(LoggingLevel.WARN, 'Background Engine Response: '+ objINTF_Response);
                    if(objINTF_Response.success && objINTF_Response.message == 'SUCCESS')
                    {
                        for(SVMXC.INTF_WebServicesDef.INTF_StringMap currStrMap : objINTF_Response.stringMap)
                        {
                            if(currStrMap.key == 'HEADERTARGETRECID' && currStrMap.value != NULL)
                            {
                                setPMPlanIDs.add(currStrMap.value);
                                if(mapPMOfferings.get(PMOfferID) != NULL && mapPMOfferings.get(PMOfferID).SVMXC__PM_Plan_Template__c != NULL && mapPMOfferings.get(PMOfferID).SVMXC__PM_Plan_Template__r.Name != NULL)
                                    strPMPlanCreationDetails += ' - ' + getTAG013() + ' ' + mapPMOfferings.get(PMOfferID).SVMXC__PM_Plan_Template__r.Name;
                                else
                                    strPMPlanCreationDetails += ' - ' + getTAG013() + ' ' + currStrMap.value;
                                break;
                            }
                        }   
                    }
                }
                system.debug(LoggingLevel.WARN, 'Number of SOQL queries: '+ Limits.getQueries() +' of '+ Limits.getLimitQueries());
                if(setPMPlanIDs != NULL && setPMPlanIDs.size() > 0)
                {
                    try
                    {
                        List<String> lstPMPlanIds = new List<String>();
                        lstPMPlanIds.addAll(setPMPlanIDs);
                        for(String strPMPlanId : lstPMPlanIds)
                        {
                            SVMXC.INTF_WebservicesDef.INTF_Request req = new SVMXC.INTF_WebservicesDef.INTF_Request();
                            req.stringListMap = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
                            req.stringListMap.add(new SVMXC.INTF_WebservicesDef.INTF_StringListMap('Mode', new List<String>{'SC'}));
                            req.stringListMap.add(new SVMXC.INTF_WebservicesDef.INTF_StringListMap('PM Plan', new List<String>{strPMPlanId}));
                            SVMXC.INTF_WebServicesDef.INTF_Response objINTF_Resp =  new PREV_PMPlanUtils ().PREV_CalculatePMPlanDetails(req);
                            system.debug(LoggingLevel.WARN, 'Number of SOQL queries: '+ Limits.getQueries() +' of '+ Limits.getLimitQueries());
                        }
                        
                        //Send Notification
                        strNotificationMsg += '\n' + getTAG006() + ': ' + lstPMPlanIds.size();
                        strNotificationMsg += strPMPlanCreationDetails;
                        strNotificationMsg += '\n\n' + getTAG010() + ': ' + getTAG008();
                        if(EmailId != NULL && EmailId.length() > 0)
                            emailStatusInfo(strNotificationMsg, EmailId);
                    }
                    catch(Exception ex)
                    {
                        //Error Notification
                        system.debug(LoggingLevel.WARN, 'Message - ' + ex.getMessage());
                        strNotificationMsg += '\n' + 'Message: ' + ex.getMessage();
                        strNotificationMsg += '\n\n' + getTAG010() + ': ' + getTAG009();
                        if(EmailId == NULL || EmailId == '')
                            EmailId = [Select Email from User where Id =: UserInfo.getUserId()].Email;
                        emailStatusInfo(strNotificationMsg, EmailId);
                    }
                }
            }
            catch(Exception ex)
            {
                //Error Notification
                system.debug(LoggingLevel.WARN, 'Message - ' + ex.getMessage());
                strNotificationMsg += '\n' + 'Message: ' + ex.getMessage();
                strNotificationMsg += '\n\n' + getTAG010() + ': ' + getTAG009();
                if(EmailId == NULL || EmailId == '')
                    EmailId = [Select Email from User where Id =: UserInfo.getUserId()].Email;
                emailStatusInfo(strNotificationMsg, EmailId);
            }
        }
    }
    
    // Method to send success or failure notification
    public static void emailStatusInfo(String strNotificationMsg , String EmailId)
    {
        if(EmailId != NULL && EmailId.length() > 0 && !Test.isRunningTest() )
        {
            Messaging.SingleEmailMessage objSingleEmailMsg = new Messaging.SingleEmailMessage();
            objSingleEmailMsg.setToAddresses(new String[] {EmailId});
            objSingleEmailMsg.setSubject(getTAG007() + ': ' + getTAG004());
            objSingleEmailMsg.setBccSender(false);
            objSingleEmailMsg.setUseSignature(false);
            objSingleEmailMsg.setPlainTextBody(strNotificationMsg);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objSingleEmailMsg });
        }
    }
    
    public static String getTAG001(){return system.label.COMM001_TAG093;}
    public static String getTAG002(){return system.label.SCON001_TAG023;}
    public static String getTAG003(){return system.label.SCON001_TAG024;}
    public static String getTAG004(){return system.label.SCON001_TAG022;}
    public static String getTAG005(){return system.label.SCON001_TAG025;}
    public static String getTAG006(){return system.label.SCON001_TAG026;}
    public static String getTAG007(){return system.label.COMM001_TAG090;}
    public static String getTAG008(){return system.label.COMM001_TAG096;}
    public static String getTAG009(){return system.label.COMM001_TAG097;}
    public static String getTAG010(){return system.label.COMM001_TAG091;}
    public static String getTAG011(){return system.label.SCON001_TAG027;}
    public static String getTAG012(){return system.label.SCON001_TAG028;}
    public static String getTAG013(){return system.label.SCON001_TAG029;}
    
    // Method to Renew Service Contract.
    public SVMXC.INTF_WebServicesDef.INTF_PageData renewContract(SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqSCON)
    {
        system.debug(LoggingLevel.WARN, 'Request Contains: '+ reqSCON);
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMapReq = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        lstStringMapReq =  reqSCON.stringMap;
        Boolean isNextStepURL = false;
        String strNextStepURL = '';
        SVMXC.INTF_WebServicesDef.INTF_PageData wrpObjPageDataResp = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        savepoint sp;
        try
        {
            sp = Database.setSavepoint();
            wrpObjPageDataResp.response.success = true;
            SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject wrpObjHdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
            if(lstStringMapReq != null && lstStringMapReq.size() > 0){
                String strRecordId = '';
                String strNextStepId = '';
                for(Integer i =0;i<lstStringMapReq.size();i++){
                    if(lstStringMapReq[i].key.equals('SVMX_recordId') && lstStringMapReq[i].value != null)
                        strRecordId = lstStringMapReq[i].value;
                    else if(lstStringMapReq[i].key.equals('SVMX_NxtStepID') && lstStringMapReq[i].value != null){
                        strNextStepId = lstStringMapReq[i].value;
                    }   
                }
                if(strRecordId != '' && strNextStepId != ''){
                    SVMXC.ServiceFlowWizard_Utils sfwUtils = new SVMXC.ServiceFlowWizard_Utils();
                    strNextStepURL = sfwUtils.SVMX_GetNextStepURL(strRecordId,strNextStepId);
                    if(strNextStepURL != '' )
                        isNextStepURL = true;
                }
            }   
            if(reqSCON.headerRecord != null)
                wrpObjHdrTargetRecordObject = reqSCON.headerRecord;
            String strHeaderObjName = null;
            if(wrpObjHdrTargetRecordObject.objName != null && wrpObjHdrTargetRecordObject.objName.length() > 0)
                strHeaderObjName = wrpObjHdrTargetRecordObject.objName; 

            List<SVMXC.INTF_WebServicesDef.INTF_Record> lstwrapObjHeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
            if(wrpObjHdrTargetRecordObject.records != null && wrpObjHdrTargetRecordObject.records.size() > 0)
                lstwrapObjHeaderRecord = wrpObjHdrTargetRecordObject.records;
            string strSourceSCONId = '';

            List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstwrpObjHdrTargetRecordAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            if(lstwrapObjHeaderRecord != null && lstwrapObjHeaderRecord.size() > 0)
            {
                if(lstwrapObjHeaderRecord[0].sourceRecordId != null && lstwrapObjHeaderRecord[0].sourceRecordId.length() > 0)
                    strSourceSCONId = lstwrapObjHeaderRecord[0].sourceRecordId;
                if(lstwrapObjHeaderRecord[0].targetRecordAsKeyValue != null && lstwrapObjHeaderRecord[0].targetRecordAsKeyValue.size() > 0)
                    lstwrpObjHdrTargetRecordAsKeyValue = lstwrapObjHeaderRecord[0].targetRecordAsKeyValue;
            }

            // Check if SCON has been renewed already, than return with error message.
            if(strSourceSCONId.length() > 0 )
            {
                integer intSCONCount = [SELECT Count() FROM SVMXC__Service_Contract__c WHERE SVMXC__Renewed_From__c = :strSourceSCONId];
                if(intSCONCount > 0)
                {
                    wrpObjPageDataResp.response.success = false;
                    wrpObjPageDataResp.response.message = system.label.SCON002_TAG011;
                    return wrpObjPageDataResp;
                }
            }

            // Building list of SCON with action UPDATE, INSERT.
            Map<String,Sobject> mapAction_SCONObj = new Map<String,Sobject>();
            mapAction_SCONObj = clsBuildSobjfromKeyValue.BuildSobjectFromKeyValue(lstwrpObjHdrTargetRecordAsKeyValue,strHeaderObjName,null,null);
            SVMXC__Service_Contract__c objServiceContract = new SVMXC__Service_Contract__c();

            if(strSourceSCONId != null && strSourceSCONId.length() > 0)
            objServiceContract = [select SVMXC__Renewal_Notes__c, SVMXC__Renewed_From__c, SVMXC__Renewal_Date__c, SVMXC__Renewal_Number__c, SVMXC__Activation_Notes__c, SVMXC__End_Date__c, SVMXC__Start_Date__c, SVMXC__Active__c, Name from SVMXC__Service_Contract__c where id=:strSourceSCONId];

            Sobject objNewSCON = new SVMXC__Service_Contract__c();
            if(mapAction_SCONObj != null && mapAction_SCONObj.size() == 1)
                objNewSCON = mapAction_SCONObj.values()[0];

            // Service Contract Renewal validation
            if(objNewSCON.get('Name') == null)
            {
                wrpObjPageDataResp.response.success = false;
                wrpObjPageDataResp.response.message = system.label.SCON002_TAG013;
                return wrpObjPageDataResp;
            }
            else if(objNewSCON.get('SVMXC__Start_Date__c') == null)
            {
                wrpObjPageDataResp.response.success = false;
                wrpObjPageDataResp.response.message = system.label.SCON002_TAG015;
                return wrpObjPageDataResp;
            }
            else if(objNewSCON.get('SVMXC__End_Date__c') == null)
            {
                wrpObjPageDataResp.response.success = false;
                wrpObjPageDataResp.response.message = system.label.SCON002_TAG014;
                return wrpObjPageDataResp;
            }
            else if(Date.valueOf(objNewSCON.get('SVMXC__Start_Date__c')) > Date.valueOf(objNewSCON.get('SVMXC__End_Date__c')) || Date.valueOf(objNewSCON.get('SVMXC__End_Date__c')) < system.today())
            {
                wrpObjPageDataResp.response.success = false;
                wrpObjPageDataResp.response.message = system.label.SCON002_TAG017;
                return wrpObjPageDataResp;
            }

            if(objServiceContract != null && strSourceSCONId != null)
            {
                //Now Create the INTF_Request and run the INTF_Tansactin Engine..
                SVMXC.INTF_WebServicesDef.INTF_Request objINTF_Req = new SVMXC.INTF_WebServicesDef.INTF_Request();
                list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();

                string strRecordID = strSourceSCONId;
                string strProcessID = null;
                Map<String, String> mapSVMXSettingList = (new COMM_Utils_ManageSettings()).SVMX_getSettingList('SCON002');
                if(mapSVMXSettingList != null && mapSVMXSettingList.get('SET007') != null)
                    strProcessID = mapSVMXSettingList.get('SET007');
                else
                    strProcessID = 'SCON_CR_SC_Renewal2';

                system.debug(LoggingLevel.WARN, 'Setting value: '+ strProcessID +'; Service Contract ' + objServiceContract +'; strSourceSCONId :' + strSourceSCONId);

                if(strRecordID != null && strRecordID.length() > 0)
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmap1 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    strmap1.key = 'RECORDID';
                    strmap1.value = strRecordID;
                    lstStringMap.add(strmap1);
                }
                if(strProcessID != null && strProcessID.length() > 0)
                {   
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmap2 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    strmap2.key = 'TDMID';
                    strmap2.value = strProcessID;
                    lstStringMap.add(strmap2);
                }
                objINTF_Req.StringMap = lstStringMap;
                SVMXC.INTF_SFMEngine RunEngine = new SVMXC.INTF_SFMEngine();
                SVMXC.INTF_WebServicesDef.INTF_Response objINTF_Response = new SVMXC.INTF_WebServicesDef.INTF_Response();
                objINTF_Response = RunEngine.SVMX_ExecuteEngine(objINTF_Req);

                system.debug(LoggingLevel.WARN, 'Engine Response: '+ objINTF_Response);

                if(!objINTF_Response.success && objINTF_Response.message != 'SUCCESS')
                {
                    Database.rollback(sp);
                    wrpObjPageDataResp.response.success = false;
                    wrpObjPageDataResp.response.message = objINTF_Response.message;
                    return wrpObjPageDataResp;
                }
                else if(objINTF_Response.success && objINTF_Response.message == 'SUCCESS')
                {
                    string strHeaderRecId = null;
                    for(SVMXC.INTF_WebServicesDef.INTF_StringMap currStrMap : objINTF_Response.stringMap)
                    {
                        if(currStrMap.key == 'HEADERTARGETRECID')
                        {
                            strHeaderRecId = currStrMap.value;
                            break;
                        }
                    }   
                    if(strHeaderRecId != null && strHeaderRecId.length() > 0)
                    {
                        SVMXC__Service_Contract__c objNewServiceContract = [select SVMXC__Renewal_Notes__c, SVMXC__Renewed_From__c, SVMXC__Renewal_Date__c, SVMXC__Renewal_Number__c, SVMXC__Activation_Notes__c, SVMXC__End_Date__c, SVMXC__Start_Date__c, SVMXC__Active__c, Name, SVMXC__Weeks_To_Renewal__c, SVMXC__Company__c from SVMXC__Service_Contract__c where id=:strHeaderRecId];
                        if(objNewServiceContract != null)
                        {
                            objNewServiceContract.Name = string.valueOf(objNewSCON.get('Name'));
                            objNewServiceContract.SVMXC__Start_Date__c = date.valueOf(objNewSCON.get('SVMXC__Start_Date__c'));
                            objNewServiceContract.SVMXC__End_Date__c = date.valueOf(objNewSCON.get('SVMXC__End_Date__c'));
                            objNewServiceContract.SVMXC__Renewal_Notes__c = string.valueOf(objNewSCON.get('SVMXC__Renewal_Notes__c'));
                            if(objServiceContract.SVMXC__Renewal_Number__c != null)
                                objNewServiceContract.SVMXC__Renewal_Number__c = objServiceContract.SVMXC__Renewal_Number__c + 1;
                            else
                                objNewServiceContract.SVMXC__Renewal_Number__c = 1;
                            objNewServiceContract.SVMXC__Active__c = false;
                            objNewServiceContract.SVMXC__Renewal_Date__c = system.today();
                            objNewServiceContract.SVMXC__Renewed_From__c = objServiceContract.Id;
                            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objNewServiceContract, COMM_SecurityUtils.Access.Updateable ) ) {
                                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                                update objNewServiceContract;
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                        }
                        else
                        {
                            wrpObjPageDataResp.response.success = false;
                            wrpObjPageDataResp.response.message = objINTF_Response.message;
                            return wrpObjPageDataResp;
                        }
                    }

                    wrpObjPageDataResp.response.message = system.label.COMM001_TAG058;
                    list<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                    if(isNextStepURL){
                        stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO',strNextStepURL));
                    }
                    else{
                        if(strHeaderRecId != null)
                            stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO',strHeaderRecId));
                    }       
                    wrpObjPageDataResp.response.stringMap = stringMap;
                    return wrpObjPageDataResp;
                }
            }
            return wrpObjPageDataResp;
        }
        catch(exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Error : '+ex.getMessage());
            Database.rollback(sp);
            wrpObjPageDataResp.response.success = false;
            wrpObjPageDataResp.response.message = ex.getmessage();
            return wrpObjPageDataResp;
        }
    }

    // Method to Cancel Service Contract.
    public SVMXC.INTF_WebServicesDef.INTF_PageData cancelContract(SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqSCON)
    {
        SVMXC.INTF_WebServicesDef.INTF_PageData wrpObjPageDataResp = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        savepoint sp;
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMapReq = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        lstStringMapReq =  reqSCON.stringMap;
        Boolean isNextStepURL = false;
        String strNextStepURL = '';
        try
        {
            sp = Database.setSavepoint();
            wrpObjPageDataResp.response.success = true;
            SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject wrpObjHdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
            
            if(lstStringMapReq != null && lstStringMapReq.size() > 0){
                String strRecordId = '';
                String strNextStepId = '';
                for(Integer i =0;i<lstStringMapReq.size();i++){
                    if(lstStringMapReq[i].key.equals('SVMX_recordId') && lstStringMapReq[i].value != null)
                        strRecordId = lstStringMapReq[i].value;
                    else if(lstStringMapReq[i].key.equals('SVMX_NxtStepID') && lstStringMapReq[i].value != null){
                        strNextStepId = lstStringMapReq[i].value;
                    }   
                }
                if(strRecordId != '' && strNextStepId != ''){
                    SVMXC.ServiceFlowWizard_Utils sfwUtils = new SVMXC.ServiceFlowWizard_Utils();
                    strNextStepURL = sfwUtils.SVMX_GetNextStepURL(strRecordId,strNextStepId);
                    if(strNextStepURL != '' )
                        isNextStepURL = true;
                }
            }
            if(reqSCON.headerRecord != null)
                wrpObjHdrTargetRecordObject = reqSCON.headerRecord;
            String strHeaderObjName = null;
            if(wrpObjHdrTargetRecordObject.objName != null && wrpObjHdrTargetRecordObject.objName.length() > 0)
                strHeaderObjName = wrpObjHdrTargetRecordObject.objName;

            List<SVMXC.INTF_WebServicesDef.INTF_Record> lstwrapObjHeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
            List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstwrpObjHdrTargetRecordAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            if(wrpObjHdrTargetRecordObject.records != null && wrpObjHdrTargetRecordObject.records.size() > 0)
                lstwrapObjHeaderRecord = wrpObjHdrTargetRecordObject.records;

            string strSCONId = null;
            if(lstwrapObjHeaderRecord != null && lstwrapObjHeaderRecord.size() > 0)
            {
                if(lstwrapObjHeaderRecord[0].targetRecordId != null && lstwrapObjHeaderRecord[0].targetRecordId.length() > 0)
                    strSCONId = lstwrapObjHeaderRecord[0].targetRecordId;
                if(lstwrapObjHeaderRecord[0].targetRecordAsKeyValue != null && lstwrapObjHeaderRecord[0].targetRecordAsKeyValue.size() > 0 && strHeaderObjName != null && strHeaderObjName.length() > 0)
                    lstwrpObjHdrTargetRecordAsKeyValue = lstwrapObjHeaderRecord[0].targetRecordAsKeyValue;
            }

            //Validation
            if(strSCONId != null && strSCONId.length() > 0)
            {   
                Map<String, String> mapSVMXSettingList = (new COMM_Utils_ManageSettings()).SVMX_getSettingList('SCON003');
                integer EntHistOpenCount = [Select count() From SVMXC__Entitlement_History__c WHERE SVMXC__Inactive_Date__c = NULL AND SVMXC__Service_Contract__c = :strSCONId AND ((SVMXC__Case__c != NULL AND SVMXC__Case__r.IsClosed = false) OR (SVMXC__Service_Order__c != NULL AND SVMXC__Service_Order__r.SVMXC__Order_Status__c = 'Open'))];
                integer EntHistAllCount = [Select count() From SVMXC__Entitlement_History__c WHERE SVMXC__Inactive_Date__c = NULL AND SVMXC__Service_Contract__c = :strSCONId];
                
                SVMXC__Service_Contract__c SContHeader = new SVMXC__Service_Contract__c();
                SContHeader = [Select SVMXC__End_Date__c from SVMXC__Service_Contract__c where Id =: strSCONId ];
                
                //Check if the contract has already been expired
                if(SContHeader.SVMXC__End_Date__c < System.today()) 
                {     
                    // Check if cancellation of Cancelled SCON is allowed.
                    if(mapSVMXSettingList != null && mapSVMXSettingList.get('SET003') != null && mapSVMXSettingList.get('SET003').toUpperCase() == 'DISALLOW')
                    {
                        wrpObjPageDataResp.response.success = false;
                        wrpObjPageDataResp.response.message = system.label.SCON003_TAG009;
                        return wrpObjPageDataResp;
                    }
                }
                else if(EntHistOpenCount > 0)
                {
                    if (mapSVMXSettingList.get('SET002') != null && mapSVMXSettingList.get('SET002').toUpperCase() == 'DISALLOW')
                    {
                        wrpObjPageDataResp.response.success = false;
                        wrpObjPageDataResp.response.message = system.label.SCON003_TAG011;
                        return wrpObjPageDataResp;
                    }
                    else if(mapSVMXSettingList.get('SET002') != null && (mapSVMXSettingList.get('SET002').toUpperCase() == 'WARN' || mapSVMXSettingList.get('SET002').toUpperCase() == 'ALLOW'))
                    {
                        if(EntHistAllCount > 0 && mapSVMXSettingList.get('SET001') != null && mapSVMXSettingList.get('SET001').toUpperCase() == 'DISALLOW')
                        {
                            wrpObjPageDataResp.response.success = false;
                            wrpObjPageDataResp.response.message = system.label.SCON003_TAG010;
                            return wrpObjPageDataResp;
                        }
                    }
                }
                else if(EntHistAllCount > 0)
                {
                    if(mapSVMXSettingList.get('SET001') != null && mapSVMXSettingList.get('SET001').toUpperCase() == 'DISALLOW')
                    {
                        wrpObjPageDataResp.response.success = false;
                        wrpObjPageDataResp.response.message = system.label.SCON003_TAG010;
                        return wrpObjPageDataResp;
                    }
                }
                
                Set<ID> setPMPlanIDs = new Set<ID>();
                list<SVMXC__PM_Plan__c> lstActivePMPlan = new list<SVMXC__PM_Plan__c>();
                for(SVMXC__PM_Plan__c objPMPlan : [Select SVMXC__Status__c, SVMXC__Service_Contract__c, Id From SVMXC__PM_Plan__c where SVMXC__Service_Contract__c =: strSCONID])
                {
                    setPMPlanIDs.add(objPMPlan.Id);
                    if(objPMPlan.SVMXC__Status__c == 'Active')
                        lstActivePMPlan.add(objPMPlan);
                }
                
                //Cancel all the active PM Plan based on Setting SET004
                if(lstActivePMPlan != null && lstActivePMPlan.size() > 0)
                {
                    if(mapSVMXSettingList.get('SET004') != NULL && mapSVMXSettingList.get('SET004').toUpperCase() == 'ALLOW')
                    {
                        SVMXC.INTF_WebServicesDef.INTF_SFMRequest objSFMRequest = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
                        objSFMRequest.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
                        objSFMRequest.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('SCONID', strSCONId));
                        SVMXC.INTF_WebServicesDef.INTF_SFMResponse objSFMResp =  new PREV_PMPlanUtils().PREV_CancelPMForContract(objSFMRequest);
                        if(!objSFMResp.success)
                        {
                            Database.rollback(sp);
                            wrpObjPageDataResp.response.success = false;
                            wrpObjPageDataResp.response.message = objSFMResp.message;
                            return wrpObjPageDataResp;
                        }
                    }
                    else
                    {
                        Database.rollback(sp);
                        wrpObjPageDataResp.response.success = false;
                        wrpObjPageDataResp.response.message = system.label.SCON003_TAG016;
                        return wrpObjPageDataResp;
                    }
                }

                //Get all the open Work Order
                list<SVMXC__Service_Order__c> lstWorkOrder = new list<SVMXC__Service_Order__c>();
                lstWorkOrder = [Select SVMXC__Order_Status__c From SVMXC__Service_Order__c where SVMXC__Order_Status__c = 'Open' AND SVMXC__PM_Plan__c IN: setPMPlanIDs AND SVMXC__Is_PM_Work_Order__c = true];
                
                //Cancel all the open Work Order created by PM Plan's based on Setting SET005
                if(lstWorkOrder != null && lstWorkOrder.size() > 0)
                {
                    if(mapSVMXSettingList.get('SET005') != NULL && mapSVMXSettingList.get('SET005').toUpperCase() == 'ALLOW')
                    {
                        for(SVMXC__Service_Order__c objWorkOrd : lstWorkOrder)
                        {
                            objWorkOrd.SVMXC__Order_Status__c = 'Canceled';
                        }
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstWorkOrder, COMM_SecurityUtils.Access.Updateable ) ) {
                            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                            update lstWorkOrder;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }                        
                    }
                    else
                    {
                        Database.rollback(sp);
                        wrpObjPageDataResp.response.success = false;
                        wrpObjPageDataResp.response.message = system.label.SCON003_TAG017;
                        return wrpObjPageDataResp;
                    }
                }           

                // Building list of SCON with action UPDATE, INSERT.
                Map<String,Sobject> mapAction_SCON =  clsBuildSobjfromKeyValue.BuildSobjectFromKeyValue(lstwrpObjHdrTargetRecordAsKeyValue,strHeaderObjName,null,null);
                if(mapAction_SCON != null && mapAction_SCON.size() == 1)
                {
                    // Perform Service Contract cancelation field updates.
                    list<Sobject> lstServiceContract = new list<Sobject>();
                    lstServiceContract = mapAction_SCON.values();
                    if(lstServiceContract != null && lstServiceContract.size() == 1)
                    {
                        lstServiceContract[0].put('SVMXC__Active__c', false);
                        lstServiceContract[0].put('SVMXC__Canceled_By__c', UserInfo.getUserId());
                        lstServiceContract[0].put('SVMXC__Canceled_On__c', System.now());
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        update lstServiceContract;
                    }
                }   
            }
            
            wrpObjPageDataResp.response.message = system.label.COMM001_TAG058;
            list<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            if(isNextStepURL)
                stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO', strNextStepURL));
            else
                stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO', strSCONId));
            wrpObjPageDataResp.response.stringMap = stringMap;
            return wrpObjPageDataResp;
        }
        catch(exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Error : '+ex.getMessage());
            Database.rollback(sp);
            wrpObjPageDataResp.response.success = false;
            wrpObjPageDataResp.response.message = ex.getmessage();
            return wrpObjPageDataResp;
        }
    }
}