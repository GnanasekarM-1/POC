public with sharing class PINV_WOInvoiceUtils
{
    public map<string, string> mapWOIdToInvoiceId = new map<string, string>();
    public map<string, string> mapWOIdToInvoiceName = new map<string, string>();
    public map<string, string> mapCaseIdToInvoiceId = new map<string, string>();
    public string strLogger = '';
    public string strSummary = '';
    public List<SVMXC__Service_Order__c> lstWOs = new List<SVMXC__Service_Order__c>();
    public List<Case> lstCases = new List<Case>();
    public List<string> lstQualifiedWOIds = new List<string>();
    public List<string> lstQualifiedCaseIds = new List<string>();
    public List<SVMXC__Proforma_Invoice__c> lstInvoiceToGen = new List<SVMXC__Proforma_Invoice__c>(); 
    public integer count = 1;
    public map<string, List<SVMXC__Service_Order__c>> mapRulesAndLstWOs = new map<string, List<SVMXC__Service_Order__c>>();
    public map<string,SVMXC__Proforma_Invoice__c> mapWOIdToInvoice = new map<string,SVMXC__Proforma_Invoice__c>();
    public map<string,SVMXC__Proforma_Invoice__c> mapCaseIdToInvoice = new map<string,SVMXC__Proforma_Invoice__c>();
    public List<SVMXC__Proforma_Invoice_Detail__c> lstInvoiceDtlToGen = new List<SVMXC__Proforma_Invoice_Detail__c>();
    public map<string, SVMXC__Proforma_Invoice_Detail__c> mapWOIdToInvoiceDtl = new map<string, SVMXC__Proforma_Invoice_Detail__c>();
    public map<string, SVMXC__Proforma_Invoice_Detail__c> mapCaseIdToInvoiceDtl = new map<string, SVMXC__Proforma_Invoice_Detail__c>();
    public INTF_ApplyMapping objApplyRMAMapping = new INTF_ApplyMapping();
    public List<SVMXC__Proforma_Invoice_Line__c> lstInvoiceLinesToGen = new List<SVMXC__Proforma_Invoice_Line__c>();
    public List<SVMXC__Proforma_Invoice_Line__c> lstInvoiceLinesToGen_TimeTracker = new List<SVMXC__Proforma_Invoice_Line__c>();
    public map<string, SVMXC.INTF_WebservicesDef.SVMXMap> mapWOIdInvoiceObjects = new map<string, SVMXC.INTF_WebservicesDef.SVMXMap>();
    public Map<String, List<String>> mapWOIdVCaseIds = new Map<String, List<String>>();
    public map<string, SVMXC.INTF_WebservicesDef.SVMXMap> mapCaseIdToInvoiceObj = new map<string, SVMXC.INTF_WebservicesDef.SVMXMap>();
    
    //Method to generate Invoice from Work Order (used by Webservice)
    public SVMXC.INTF_WebservicesDef.INTF_Response PINV_GenerateInvoiceDoc(SVMXC.INTF_WebservicesDef.INTF_Request req)
    {
        if(req.valueMap != null && req.valueMap.size() > 0)
        {
            SVMXC.INTF_WebservicesDef.INTF_Request reqToSend = new SVMXC.INTF_WebservicesDef.INTF_Request();
            List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringListMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
            List<SVMXC.INTF_WebservicesDef.INTF_StringMap> lstStringMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringMap>();
            for(SVMXC.INTF_WebservicesDef.SVMXMap mp : req.valueMap)
            {
                if(mp.key == 'SVMX_RECORDID')
                {
                    SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
                    string WOID = mp.value;
                    //Id describe for checking object
                        Id objId = Id.valueOf(WOID);
                        Schema.SObjectType token = objId.getSObjectType();
                        Schema.DescribeSObjectResult dscRslt = token.getDescribe();
                        //String ObjecName = 
                        
                    //Id describe complete
                    strLstMap.valueList = new List<string>();
                    strLstMap.key = dscRslt.getName();
                    strLstMap.valueList.add(WOID);
                    lstStringListMapReq.add(strLstMap);
                }
                else if(mp.key == 'PROCESSID')
                {
                    SVMXC.INTF_WebservicesDef.INTF_StringMap strMap = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
                    strMap.key = 'ProcId';
                    strMap.value = mp.value;
                    lstStringMapReq.add(strMap);
                }
            }
            SVMXC.INTF_WebservicesDef.INTF_StringMap strMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
            strMap1.key = 'StepDetails';
            strMap1.value = 'All';
            lstStringMapReq.add(strMap1);
            
            reqToSend.stringListMap = lstStringListMapReq;
            reqToSend.stringMap = lstStringMapReq;
            System.debug(Logginglevel.WARN,'Request Send from WS: ' + reqToSend);
            return PINV_GenerateInvoiceDocs(reqToSend);
        }
        else
            return PINV_GenerateInvoiceDocs(req);
    }

    //Method to generate Invoice from Work Order
    public SVMXC.INTF_WebservicesDef.INTF_Response PINV_GenerateInvoiceDocs(SVMXC.INTF_WebservicesDef.INTF_Request req)
    {
        Savepoint sp = Database.setSavepoint();
        string strRunDate = string.valueOfgmt(system.now());
        SVMXC.INTF_WebservicesDef.INTF_Response res = new SVMXC.INTF_WebservicesDef.INTF_Response();
        SVMXC__ServiceMax_Processes__c WOBillingProcess = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringListMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        List<SVMXC.INTF_WebservicesDef.INTF_StringMap> lstStringMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringMap>();
        List<SVMXC.INTF_WebservicesDef.SVMXMap> lstInvoiceInfo = new List<SVMXC.INTF_WebservicesDef.SVMXMap>(); 
         
        
        
        map<String, Schema.SObjectType> schemaMap = new map<String, Schema.SObjectType>();
        
        map<String,String> mapInputValues = new map<string, string>();
        
        
        Map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
            schemaMap.put(s.getDescribe().getName(),s);

        string strAccountId = '';
        string strProcID = '';
        string strStepInfo = '';
        string strInvoiceMapId = '';
        string strDetailMapId = '';
        string strLineMapId = '';
        boolean isNonBillableLinesIncluded = false;
        boolean isCaptureLog = false;
        string strRule = '';
        string strRule1 = '';
        string strRule2 = '';
        string strExpId = '';
        string strNavigateTo = '';
        
        List<string> lstWOIds = new List<string>();
        
        System.debug(Logginglevel.WARN,'1. Request is: ' + req);
        lstStringListMapReq = req.stringListMap;
        lstStringMapReq = req.stringMap;

        
        string strRule1_Case = '';
        string strRule2_Case = '';
        string strExpId_Case = '';
        string strDetailMapId_Case = '';
        string strLineMapId_Case = '';
        string strScope = '';
        List<string> lstCaseIds = new List<string>();
        
        //Extracting the Request and assigning the useful values to the variables
        System.debug(Logginglevel.WARN,'lstStringListMapReq: ' + lstStringListMapReq);
        for(SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap: lstStringListMapReq)
        {
            if(strLstMap != null)
            {
                if(strLstMap.key == 'ACCOUNT')
                    strAccountId = strLstMap.valueList[0];
                else if(strLstMap.key == 'SVMXC__Service_Order__c')
                    lstWOIds.addAll(strLstMap.valueList);
                else if(strLstMap.key == 'Case')
                    lstCaseIds.addAll(strLstMap.valueList);
            }
        }
        System.debug(Logginglevel.WARN,'lstWOIds: ' + lstWOIds);
        for(SVMXC.INTF_WebservicesDef.INTF_StringMap strMap: lstStringMapReq)
        {
            if(strMap.key == 'PROCID')
                strProcID = strMap.value;
            else if(strMap.key == 'STEPDETAILS')
                strStepInfo = strMap.value;
        }
        
        System.debug(Logginglevel.WARN,'2. Extracted Account Id: ' + strAccountId + ' Process ID: ' + strProcID + ' Step Info is: ' + strStepInfo);

        res.success = true;

        if(strProcID != null && strProcID.length() > 0)
        {
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Process Details';
            RecordType WOBilProcess_Rtype = [select Id from RecordType where Name='Work Order Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            list<SVMXC__ServiceMax_Processes__c> lstWOProcess= new list<SVMXC__ServiceMax_Processes__c>();          
            lstWOProcess = [select id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Process1__c, SVMXC__Module__c, SVMXC__Node_Parent__c, SVMXC__Process__c, SVMXC__Primary_Consolidation_Rule__c, SVMXC__Secondary_Consolidation_Rule__c, SVMXC__Tertiary_Consolidation_Rule__c, SVMXC__Include_Product__c, SVMXC__Include_Parent__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Capture_Log__c, SVMXC__Submodule__c, SVMXC__Secondary_Consolidation_Rule_Case__c, SVMXC__Tertiary_Consolidation_Rule_Case__c, SVMXC__Include_Top_Level__c, SVMXC__Process2__c, SVMXC__Process3__c, SVMXC__Invoice_Scope__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = :strProcID and SVMXC__Active__c = true and RecordTypeId =: WOBilProcess_Rtype.Id limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Completed Process Retrieval';
           if(lstWOProcess.size()>0)
                WOBillingProcess = lstWOProcess.get(0);
            else
            {
                res.messageType = 'INFO';
                res.message = getTAG037();
                return res;
            }
            if(WOBillingProcess != null)
            {
                strSummary += getTAG009()+ getTAG001() + getTAG004() +  ' ' + WOBillingProcess.SVMXC__ProcessID__c;
                strInvoiceMapId = WOBillingProcess.SVMXC__Node_Parent__c;
                strDetailMapId = WOBillingProcess.SVMXC__Process__c;
                strLineMapId = WOBillingProcess.SVMXC__Process1__c;
                isNonBillableLinesIncluded = WOBillingProcess.SVMXC__Include_Product__c;
                strExpId = WOBillingProcess.SVMXC__Module__c;
                strRule = WOBillingProcess.SVMXC__Primary_Consolidation_Rule__c;
                strRule1 = WOBillingProcess.SVMXC__Secondary_Consolidation_Rule__c;
                strRule2 = WOBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c;
                isCaptureLog = WOBillingProcess.SVMXC__Capture_Log__c;
                
                strRule1_Case = WOBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c;
                strRule2_Case = WOBillingProcess.SVMXC__Tertiary_Consolidation_Rule_Case__c;
                strExpId_Case = WOBillingProcess.SVMXC__Submodule__c;
                strDetailMapId_Case = WOBillingProcess.SVMXC__Process2__c;
                strLineMapId_Case = WOBillingProcess.SVMXC__Process3__c;
                strScope = WOBillingProcess.SVMXC__Invoice_Scope__c;
                if(strScope == null || strScope.length() == 0)
                    strScope = 'Work Order';
                
                boolean isScopeWO = false;
                boolean isScopeCase = false;
                if(strScope.toUpperCase() == 'WORK ORDER')
                {
                    isScopeWO = true;
                }
                else if(strScope.toUpperCase() == 'CASE')
                {
                    isScopeCase = true;
                }
                else if(strScope.toUpperCase() == 'WORK ORDER AND CASE BOTH')
                {
                    isScopeWO = true;
                    isScopeCase = true;
                }
                
                if( !isScopeWO && (lstWOIds.size() > 0))    
                {
                    res.messageType = 'INFO';
                    res.message = 'Scope of this Invoice Process is not for Work Order';
                    return res;
                }
                
                if( !isScopeCase && (lstCaseIds.size() > 0) )
                {
                    res.messageType = 'INFO';
                    res.message = 'Scope of this Invoice Process is not for Case';
                    return res;
                }
                
                
                
                strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Scope of Process and it is: '+strScope;
                //For Step 1 - Calling the method to generate the Response for the user to manipulate the Invoices, Invoice Details and Lines before commiting to insert
                if(strStepInfo == 'STEP1')
                {
                    mapInputValues.put('SVMXC__Node_Parent__c', strInvoiceMapId);
                    mapInputValues.put('SVMXC__Process__c', strDetailMapId);
                    mapInputValues.put('SVMXC__Process1__c', strLineMapId);
                    mapInputValues.put('SVMXC__Process2__c', strDetailMapId_Case);
                    mapInputValues.put('SVMXC__Process3__c', strLineMapId_Case);
                    mapInputValues.put('SVMXC__Include_Product__c', string.valueOf(isNonBillableLinesIncluded));
                    mapInputValues.put('SVMXC__Primary_Consolidation_Rule__c', strRule);
                    mapInputValues.put('SVMXC__Secondary_Consolidation_Rule__c', strRule1);
                    mapInputValues.put('SVMXC__Tertiary_Consolidation_Rule__c', strRule2);
                    mapInputValues.put('SVMXC__Secondary_Consolidation_Rule_Case__c', strRule1_Case);
                    mapInputValues.put('SVMXC__Tertiary_Consolidation_Rule_Case__c', strRule2_Case);
                    mapInputValues.put('SVMXC__Module__c', strExpId);
                    mapInputValues.put('SVMXC__Submodule__c', strExpId_Case);
                    mapInputValues.put('isScopeWO', string.valueOf(isScopeWO));
                    mapInputValues.put('isScopeCase', string.valueOf(isScopeCase));
                    
                    res = GenerateInvoiceDocForStep1(lstWOIds, lstCaseIds, mapInputValues);
                }
                else if(strStepInfo == 'STEP2')
                {
                    //For Step 2 - Calling the method to generate the Invoices, Invoice Details and Lines after the manipulation done by the User
                    req.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('ProcessID', WOBillingProcess.Id));
                    res.valueMap = GenerateInvoiceDocForStep2(req.valueMap);
                    integer errorFound = 0;
                    for(SVMXC.INTF_WebservicesDef.SVMXMap tempMap : res.valueMap)
                    {
                        if(tempMap.key == 'ERROR')
                        {
                            strSummary += getTAG005() + ': ' + getTAG035();
                            strLogger += '\n Status' + ': ' + 'Failed' + 'Error Details' + ': ' + tempMap.value;
                            res.success = false;
                            errorFound++;
                        }
                        if(tempMap.key == 'SUMMARY')
                            strSummary = tempMap.value;
                        if(tempMap.key == 'LOG')
                            strLogger = tempMap.value;
                    }
                    
                    if(errorFound == 0)
                    {
                        strSummary += getTAG005() + ': ' + getTAG034();
                        strLogger += '\n Status' + ': ' + 'Success';
                    }
                    else if(errorFound > 0)
                    {
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Process Execution Ends';
                        if(isCaptureLog == true)
                            strSummary += '\n' + getTAG008();
                        
                        if(WOBillingProcess.SVMXC__Email_On_Error__c != null && WOBillingProcess.SVMXC__Email_On_Error__c.length()>0)
                            statusEmail(WOBillingProcess.SVMXC__Name__c, strSummary, strLogger, WOBillingProcess.SVMXC__Email_On_Error__c, isCaptureLog);
                        else
                        {
                            User u = [Select Email From User where id =: UserInfo.getUserId() limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            statusEmail(WOBillingProcess.SVMXC__Name__c, strSummary, strLogger, u.Email, isCaptureLog);
                        }
                    }
                    
                    strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Process Execution Ends';
                    if(isCaptureLog == true)
                        strSummary += '\n' + getTAG008();
                    
                    //Method called to send the Email notification for the Process
                    if(WOBillingProcess.SVMXC__Email_On_Success__c != null && WOBillingProcess.SVMXC__Email_On_Success__c.length() >0)
                        statusEmail(WOBillingProcess.SVMXC__Name__c, strSummary, strLogger, WOBillingProcess.SVMXC__Email_On_Success__c, isCaptureLog);
                }
                else if(strStepInfo == 'ALL')
                {
                    try
                    {
                        //code for only work order
                        lstInvoiceToGen.clear();
                        
                        SVMXC__Proforma_Invoice__c invoiceToGen = new SVMXC__Proforma_Invoice__c();
                        lstInvoiceToGen.add(invoiceToGen);
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Applying Value Map to create Invoice header';
                        
                        if(strInvoiceMapId != null && strInvoiceMapId.length() > 0)
                            lstInvoiceToGen = objApplyRMAMapping.getValueMapping(lstInvoiceToGen, strInvoiceMapId, schemaMap);
                        
                        if(isScopeWO)
                        {
                            string SOQLForWO = '';
                            string strWhereClauseWO = '';
                            if(strExpId != null && strExpId.length() > 0)
                            { 
                                List<SVMXC__ServiceMax_Processes__c> expProc = new List<SVMXC__ServiceMax_Processes__c>();
                                expProc = [Select Id, Name,SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id=:strExpId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                if(expProc != null && expProc.size() == 1)
                                    strWhereClauseWO = expProc[0].SVMXC__Parent_Object_Criteria__c;
                            }
                            if(strRule.toUpperCase() == 'ACCOUNT')
                            {
                                WOConsolidationAccount(lstWOIds, strRule1, strRule2, strWhereClauseWO, '');
                            }
                            else if(strRule.toUpperCase() == 'PER RECORD' || strRule.toUpperCase() == 'WORK ORDER')
                            {
                                 WOConsolidationPerRecord(lstWOIds, strWhereClauseWO, '');
                            }
                        }
                        if(isScopeCase)
                        {
                            string SOQLForCase = '';
                            string strWhereClauseCase = '';
                            if(strExpId_Case != null && strExpId_Case.length() > 0)
                            { 
                                List<SVMXC__ServiceMax_Processes__c> expProc = new List<SVMXC__ServiceMax_Processes__c>();
                                expProc = [Select Id, Name,SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id=:strExpId_Case]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                if(expProc != null && expProc.size() == 1)
                                    strWhereClauseCase = expProc[0].SVMXC__Parent_Object_Criteria__c;
                            }
                            if(strRule.toUpperCase() == 'ACCOUNT')
                            {
                                CaseConsolidationAccount(lstCaseIds, strRule1_Case, strRule2_Case, strWhereClauseCase, '');
                            }
                            else if(strRule.toUpperCase() == 'PER RECORD' || strRule.toUpperCase() == 'WORK ORDER')
                            {
                                CaseConsolidationPerRecord(lstCaseIds, strWhereClauseCase, '');
                            }
                        }
                        
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Completed consolidation; number of Invoice(s) to be generated' + ': ' + lstInvoiceToGen.size() + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Inserting Invoice Header(s)';

                        if(lstWOs.size() == 0 && lstCases.size() == 0)    
                        {
                            res.messageType = 'INFO';
                            res.message = 'There is no record qualifying for create Invoice';
                            return res;
                        }
                            
                        //Inserting the Invoices to be generated
                        if(lstInvoiceToGen != null && lstInvoiceToGen.size() > 0)
                        {
                            //insert lstInvoiceToGen;
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceToGen, COMM_SecurityUtils.Access.Createable)){
							    insert lstInvoiceToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
							}
							else{
							    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
							}
                            strNavigateTo = lstInvoiceToGen[0].Id;
                        }
                        
                        strSummary += getTAG007() + lstInvoiceToGen.size();
                        System.debug(Logginglevel.WARN,'6. Invoices Created are: ' + lstInvoiceToGen);
                        //Preapring a map of WO Id to Invoice Id to be used to generate Invoice Details
                        
                        if(isScopeWO)
                        {
                            genrateInvoiceDetailFrmWO(strDetailMapId, schemaMap);
                        }
                        if(isScopeCase)
                        {
                            genrateInvoiceDetailFrmCase(strDetailMapId_Case, schemaMap);
                            
                        }
                        if(isScopeWO)
                        {
                            genrateInvoiceLineFrmWODtl(strLineMapId, schemaMap, isNonBillableLinesIncluded);
                        }
                        if(isScopeCase)
                        {
                            genrateInvoiceLineFrmTimeTrckr(strLineMapId_Case, schemaMap);
                        }
                        
                        
                        System.debug(Logginglevel.WARN,'Map of WO ID and Invoice Id field: ' + mapWOIdToInvoiceId+', Map of Case ID and Invoice Id field: '+mapCaseIdToInvoiceId);
                        
                        
                           
                        //Inserting all the Invoice Detail Lines to be generated
                        /*if(lstInvoiceLinesToGen != null && lstInvoiceLinesToGen.size() > 0)
                            insert lstInvoiceLinesToGen;*/
                        
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Invoice Line(s) generated' + ': ' + lstInvoiceLinesToGen.size() + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Performing Source Updates';
                        
                        strLogger = srcUpdate(lstQualifiedWOIds, WOBillingProcess.Id, strLogger,'HEADER_UPD_ON_INVOICE' , false);
                        // case source update
                        strLogger = srcUpdate(lstQualifiedCaseIds, WOBillingProcess.Id, strLogger,'HEADER_UPD_ON_INVOICE_CASE' , true);
                        
                        System.debug(Logginglevel.WARN,'Source Updates are done.');
                        map<string, Decimal> mapPIToPrice = new map<string, Decimal>();
                        
                        for(SVMXC__Proforma_Invoice_Detail__c pID: lstInvoiceDtlToGen)
                        {
                            if(pID.SVMXC__Total_Amount__c != null)
                            {
                                if(mapPIToPrice.containsKey(pID.SVMXC__Proforma_Invoice__c))
                                    mapPIToPrice.put(pID.SVMXC__Proforma_Invoice__c, mapPIToPrice.get(pID.SVMXC__Proforma_Invoice__c)+ pID.SVMXC__Total_Amount__c);
                                else
                                    mapPIToPrice.put(pID.SVMXC__Proforma_Invoice__c, pID.SVMXC__Total_Amount__c);
                            }
                        }
                        
                        for(SVMXC__Proforma_Invoice__c pI: lstInvoiceToGen)
                        {
                            if(mapPIToPrice != null && mapPIToPrice.containsKey(pI.Id))
                                pI.SVMXC__Total_Invoice__c = mapPIToPrice.get(pI.Id);
                        }
                        
                        if(mapPIToPrice != null){
							//update lstInvoiceToGen;
							if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceToGen, COMM_SecurityUtils.Access.Updateable)){
								update lstInvoiceToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
							}
							else{
								Database.rollback(sp);
								res.success = false;
								res.message = System.label.COMM001_TAG142;
								return res;
							}
						}
                        
                        List<string> lstInvoiceIds = new List<string>();
                        for(SVMXC__Proforma_Invoice__c pI: lstInvoiceToGen)
                            lstInvoiceIds.add(pI.Id);
                        System.debug(Logginglevel.WARN,'9. List of Invoice Lines Created are: ' + lstInvoiceLinesToGen + ' and the size is: ' + lstInvoiceLinesToGen.size());
                        
                        List<SVMXC__Proforma_Invoice__c> lstUpdatedInvoices = [select Name from SVMXC__Proforma_Invoice__c where id IN: lstInvoiceIds];
                        
                        for(SVMXC__Proforma_Invoice__c pI: lstUpdatedInvoices)
                            mapWOIdToInvoiceName.put(pI.Id, pI.Name);
                        
                        if(lstWOs != null && lstWOs.size() > 0)
                        {
                            System.debug(Logginglevel.WARN,'Map of WO ID and Invoice Name field 2: ' + mapWOIdToInvoiceName);
                            for(SVMXC__Service_Order__c WO : lstWOs)
                            {
                                if(mapWOIdToInvoiceId.containsKey(WO.Id))
                                {
                                    WO.SVMXC__Invoice_Created__c = true;
                                    WO.SVMXC__Proforma_Invoice__c = mapWOIdToInvoiceId.get(WO.Id);
                                    if(mapWOIdToInvoiceName.containsKey(WO.SVMXC__Proforma_Invoice__c))
                                        WO.SVMXC__Invoice_Number__c = mapWOIdToInvoiceName.get(WO.SVMXC__Proforma_Invoice__c);
                                }
                            }
                            //update lstWOs;
							if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWOs, COMM_SecurityUtils.Access.Updateable)){
								update lstWOs; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
							}
							else{
								Database.rollback(sp);
								res.success = false;
								res.message = System.label.COMM001_TAG142;
								return res;
							}
                        }
                        if(lstCases != null && lstCases.size() > 0)
                        {
                            System.debug(Logginglevel.WARN,'Map of WO ID and Invoice Name field 2: ' + mapWOIdToInvoiceName);
                            for(Case ObjCase : lstCases)
                            {
                                if(mapCaseIdToInvoiceId.containsKey(ObjCase.Id))
                                {
                                    ObjCase.SVMXC__Is_Invoice_Created__c = true;
                                    ObjCase.SVMXC__Proforma_Invoice__c = mapCaseIdToInvoiceId.get(ObjCase.Id);
                                }
                            }
                            //update lstCases;
							if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstCases, COMM_SecurityUtils.Access.Updateable)){
								update lstCases; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
							}
							else{
								Database.rollback(sp);
								res.success = false;
								res.message = System.label.COMM001_TAG142;
								return res;
							}
                        }
                            
                        strSummary += getTAG005() + ': ' + getTAG034();
                        strLogger += '\n Status' + ': ' + 'Success' + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Process Execution Ends';
                        
                        if(isCaptureLog == true)
                            strSummary += '\n' + getTAG008();
                          
                        //Method called to send the Email notification for the Process
                        if(WOBillingProcess.SVMXC__Email_On_Success__c != null && WOBillingProcess.SVMXC__Email_On_Success__c.length() >0)
                            statusEmail(WOBillingProcess.SVMXC__Name__c, strSummary, strLogger, WOBillingProcess.SVMXC__Email_On_Success__c, isCaptureLog);
                    }
                    catch(Exception ex)
                    {
                        Database.rollback(sp);
                        
                        strSummary = getTAG009() + getTAG001() + getTAG004() + ' ' + WOBillingProcess.SVMXC__ProcessID__c + getTAG005() + ': ' + getTAG035();
                        strLogger += '\n Status' + ': ' + 'Failed' + '\n' + 'Error details' + ': ' + ex.getMessage() + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Process Execution Ends';
                        if(isCaptureLog == true)
                            strSummary += getTAG008();
                        
                        //Method called to send the Email notification for the Process
                        if(WOBillingProcess.SVMXC__Email_On_Error__c != null && WOBillingProcess.SVMXC__Email_On_Error__c.length()>0)
                            statusEmail(WOBillingProcess.SVMXC__Name__c, strSummary, strLogger, WOBillingProcess.SVMXC__Email_On_Error__c, isCaptureLog);
                        else
                        {
                            User u = [Select Email From User where id =: UserInfo.getUserId() limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            statusEmail(WOBillingProcess.SVMXC__Name__c, strSummary, strLogger, u.Email, isCaptureLog);
                        }
                        
                        res.success = false;
                        res.message = ex.getMessage();
                        return res;
                    }

                }
            }

        }
        if(strNavigateTo != null && strNavigateTo.length() > 0)
            res.stringMap.add(new SVMXC.INTF_WebservicesDef.INTF_StringMap('navigateTo', '/'+strNavigateTo));
        System.debug(Logginglevel.WARN,'Response generated is: ' + res);
        return res;
    }
    // method for generate invoice line from case
    public void genrateInvoiceLineFrmTimeTrckr(String strLineMapId_Case, map<String, Schema.SObjectType> schemaMap)
    {
        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Time Tracker(s)';
        //Querying the Time Tracker of Type
        List<SVMXC__Time_Tracker__c> lstTimeTracker = new List<SVMXC__Time_Tracker__c>();
        string CurField = '';
        if(UserInfo.isMultiCurrencyOrganization())
        CurField = 'CurrencyIsoCode, ';
        string strSOQLTimeTracker = 'select id, ' + CurField + 'SVMXC__Activity_Type__c, SVMXC__Is_Billable__c ,SVMXC__Applied_Rate_Type__c, SVMXC__Billable_Line_Price__c, SVMXC__Billable_Qty__c, SVMXC__Covered__c,  SVMXC__Line_Price__c, SVMXC__Line_Qty__c, SVMXC__Case__c from SVMXC__Time_Tracker__c where SVMXC__Case__c IN: lstQualifiedCaseIds';

        lstTimeTracker = database.query(strSOQLTimeTracker);

        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Time Tracker(s) retrieved' + ': ' + lstTimeTracker.size();

        System.debug(Logginglevel.WARN,'8. List of Time Tracker queried are: ' + lstTimeTracker + ' and the size is: ' + lstTimeTracker.size());
        map<string, SVMXC__Proforma_Invoice_Line__c> mapCaseActIdToInvoiceLine = new map<string, SVMXC__Proforma_Invoice_Line__c>();
        //Preapring the list of Invoice Detail Lines to be generated -- One Per WO Detail  
        for(SVMXC__Time_Tracker__c objTimeTracker : lstTimeTracker)
        {
            SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
            invoiceLine.SVMXC__Case__c = objTimeTracker.SVMXC__Case__c;
            invoiceLine.SVMXC__Proforma_Invoice_Detail__c = (mapCaseIdToInvoiceDtl.get(objTimeTracker.SVMXC__Case__c)).Id;
            invoiceLine.SVMXC__Time_Tracker__c = objTimeTracker.Id;
            invoiceLine.SVMXC__Proforma_Invoice__c = mapCaseIdToInvoice.get(objTimeTracker.SVMXC__Case__c).Id;
            invoiceLine.SVMXC__Billable_Quantity__c = objTimeTracker.SVMXC__Billable_Qty__c;
            invoiceLine.SVMXC__Applied_Rate_Type__c = objTimeTracker.SVMXC__Applied_Rate_Type__c;
            invoiceLine.SVMXC__Billable_Line_Price__c = objTimeTracker.SVMXC__Billable_Line_Price__c;
            invoiceLine.SVMXC__Is_Billable__c = objTimeTracker.SVMXC__Is_Billable__c;
            invoiceLine.SVMXC__Discount__c = objTimeTracker.SVMXC__Covered__c; 
            if(UserInfo.isMultiCurrencyOrganization())
                invoiceLine.put('CurrencyIsoCode', string.valueOf(mapCaseIdToInvoiceDtl.get(objTimeTracker.SVMXC__Case__c).get('CurrencyIsoCode')));
            
            lstInvoiceLinesToGen_TimeTracker.add(invoiceLine);
            mapCaseActIdToInvoiceLine.put(objTimeTracker.Id, invoiceLine);
        }

        //strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Creating Invoice Line(s)';

        //Applying Mapping and inserting the Invoice Details
        if(lstInvoiceLinesToGen_TimeTracker != null && lstInvoiceLinesToGen_TimeTracker.size() > 0)
        {
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Applying Field Mapping to create Invoice Lines';
            
            if(strLineMapId_Case != null && strLineMapId_Case.length()>0)
                lstInvoiceLinesToGen_TimeTracker = objApplyRMAMapping.getApplyMapping1(strLineMapId_Case, mapCaseActIdToInvoiceLine, false, schemaMap);
            
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Creating Invoice Line(s)';
            
            //insert lstInvoiceLinesToGen_TimeTracker;
			if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstInvoiceLinesToGen_TimeTracker, COMM_SecurityUtils.Access.Createable ) ) {
				insert lstInvoiceLinesToGen_TimeTracker; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			} else {
				throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
			}
            
            lstInvoiceLinesToGen.addAll(lstInvoiceLinesToGen_TimeTracker);
        }
    }   
    //method for generate invoice line from WO
    public void genrateInvoiceLineFrmWODtl(String strLineMapId, map<String, Schema.SObjectType> schemaMap, boolean isNonBillableLinesIncluded)
    {
        strLogger +=  '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Work Order Detail(s)';
        //Querying the WO Details of Type Usage/Consumption
        List<SVMXC__Service_Order_Line__c> lstWODtls = new List<SVMXC__Service_Order_Line__c>();
        string CurField = '';
        if(UserInfo.isMultiCurrencyOrganization())
        CurField = 'CurrencyIsoCode, ';
        string strSOQLWODtls = 'select id, ' + CurField + 'SVMXC__Is_Billable__c, SVMXC__Applied_Rate_Type__c, SVMXC__Total_Line_Price__c, SVMXC__Billable_Quantity__c, SVMXC__Billable_Line_Price__c, SVMXC__Line_Type__c, SVMXC__Serial_Number__c, SVMXC__Discount__c, SVMXC__Expense_Type__c, SVMXC__Product__c, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Service_Order__c, RecordType.Name from SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c IN: lstQualifiedWOIds and RecordType.Name = \'Usage/Consumption\'';
        if(isNonBillableLinesIncluded == false)
            strSOQLWODtls += ' AND SVMXC__Is_Billable__c = true';

        lstWODtls = database.query(strSOQLWODtls);

        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Work Order Detail(s) retrieved' + ': ' + lstWODtls.size();

        System.debug(Logginglevel.WARN,'8. List of Work Order Details queried are: ' + lstWODtls + ' and the size is: ' + lstWODtls.size());

        map<string, SVMXC__Proforma_Invoice_Line__c> mapWDIdToInvoiceLine = new map<string, SVMXC__Proforma_Invoice_Line__c>();
        //Preapring the list of Invoice Detail Lines to be generated -- One Per WO Detail  
        for(SVMXC__Service_Order_Line__c WODtl : lstWODtls)
        {
            SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
            invoiceLine.SVMXC__Work_Order__c = WODtl.SVMXC__Service_Order__c;
            invoiceLine.SVMXC__Proforma_Invoice_Detail__c = (mapWOIdToInvoiceDtl.get(WODtl.SVMXC__Service_Order__c)).Id;
            invoiceLine.SVMXC__Work_Details__c = WODtl.Id;
            invoiceLine.SVMXC__Proforma_Invoice__c = mapWOIdToInvoice.get(WODtl.SVMXC__Service_Order__c).Id;
            invoiceLine.SVMXC__Product__c = WODtl.SVMXC__Product__c;
            invoiceLine.SVMXC__Billable_Quantity__c = WODtl.SVMXC__Billable_Quantity__c;
            invoiceLine.SVMXC__Quantity__c = WODtl.SVMXC__Actual_Quantity2__c;
            invoiceLine.SVMXC__Line_Type__c = WODtl.SVMXC__Line_Type__c;
            invoiceLine.SVMXC__Is_Billable__c = WODtl.SVMXC__Is_Billable__c;
            invoiceLine.SVMXC__Applied_Rate_Type__c = WODtl.SVMXC__Applied_Rate_Type__c;
            invoiceLine.SVMXC__Price__c = WODtl.SVMXC__Actual_Price2__c;
            invoiceLine.SVMXC__Total_Line_Price__c = WODtl.SVMXC__Total_Line_Price__c;
            invoiceLine.SVMXC__Billable_Line_Price__c = WODtl.SVMXC__Billable_Line_Price__c;
            invoiceLine.SVMXC__Discount__c = WODtl.SVMXC__Discount__c; 
            invoiceLine.SVMXC__Expense_Type__c = WODtl.SVMXC__Expense_Type__c;
            if(UserInfo.isMultiCurrencyOrganization())
                invoiceLine.put('CurrencyIsoCode', string.valueOf(mapWOIdToInvoiceDtl.get(WODtl.SVMXC__Service_Order__c).get('CurrencyIsoCode')));
            
            lstInvoiceLinesToGen.add(invoiceLine);
            mapWDIdToInvoiceLine.put(WODtl.Id, invoiceLine);
        }

        //strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Creating Invoice Line(s)';

        //Applying Mapping and inserting the Invoice Details
        if(lstInvoiceLinesToGen != null && lstInvoiceLinesToGen.size() > 0)
        {
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Applying Field Mapping to create Invoice Lines';
            
            if(strLineMapId != null && strLineMapId.length()>0)
                lstInvoiceLinesToGen = objApplyRMAMapping.getApplyMapping1(strLineMapId, mapWDIdToInvoiceLine, false, schemaMap);
            
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Creating Invoice Line(s)';
            
            //insert lstInvoiceLinesToGen;
			if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstInvoiceLinesToGen, COMM_SecurityUtils.Access.Createable ) ) {
				insert lstInvoiceLinesToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			} else {
				throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
			}
        }

        List<SVMXC__Proforma_Invoice_Line__c> lstPILToInsert = new List<SVMXC__Proforma_Invoice_Line__c>();

        for(SVMXC__Service_Order__c WO : lstWOs)
        {
            if(WO.SVMXC__Travel_Unit__c != null && (WO.SVMXC__Travel_Unit__c ==  'Flat Rate' || WO.SVMXC__Travel_Unit__c ==  'Zone Based'))
            {
                SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                invoiceLine.SVMXC__Work_Order__c = WO.Id;
                invoiceLine.SVMXC__Proforma_Invoice_Detail__c = (mapWOIdToInvoiceDtl.get(WO.Id)).Id;
                invoiceLine.SVMXC__Proforma_Invoice__c = mapWOIdToInvoice.get(WO.Id).Id;
                invoiceLine.SVMXC__Line_Type__c = 'Travel';
                invoiceLine.SVMXC__Is_Billable__c = true;
                invoiceLine.SVMXC__Price__c = WO.SVMXC__Travel_Rate__c;
                invoiceLine.SVMXC__Total_Line_Price__c = WO.SVMXC__Travel_Rate__c;
                invoiceLine.SVMXC__Billable_Line_Price__c = WO.SVMXC__Travel_Rate__c;
                if(UserInfo.isMultiCurrencyOrganization())
                    invoiceLine.put('CurrencyIsoCode', string.valueOf(mapWOIdToInvoiceDtl.get(WO.Id).get('CurrencyIsoCode')));
                lstPILToInsert.add(invoiceLine);
            }
        }
        if(lstPILToInsert != null && lstPILToInsert.size() > 0)
        {
            //insert lstPILToInsert;
			if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstPILToInsert, COMM_SecurityUtils.Access.Createable ) ) {
				insert lstPILToInsert; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			} else {
				throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
			}
            lstInvoiceLinesToGen.addAll(lstPILToInsert);
        }
    }
    //method for genreate invoice detail from WO
    public void genrateInvoiceDetailFrmWO(String strDetailMapId, map<String, Schema.SObjectType> schemaMap)
    {
        mapWOIdToInvoiceId.clear();
        for(string str : mapWOIdToInvoice.keySet())
        {
            SVMXC__Proforma_Invoice__c invoicesGenerated = new SVMXC__Proforma_Invoice__c();
            invoicesGenerated = mapWOIdToInvoice.get(str);
            mapWOIdToInvoiceId.put(str, invoicesGenerated.Id);
        }
        
        //Preapring list of Invoice Details to be generated -- One Per Work Order
        
        for(SVMXC__Service_Order__c WO : lstWOs)
        {
            SVMXC__Proforma_Invoice_Detail__c invoiceDtl = new SVMXC__Proforma_Invoice_Detail__c();
            invoiceDtl.SVMXC__Work_Order__c = WO.Id;
            invoiceDtl.SVMXC__Proforma_Invoice__c = mapWOIdToInvoice.get(WO.Id).Id;
            invoiceDtl.SVMXC__Total_Amount__c = WO.SVMXC__Proforma_Invoice_Amount__c;
            if(UserInfo.isMultiCurrencyOrganization())
                invoiceDtl.put('CurrencyIsoCode', string.valueOf(WO.get('CurrencyIsoCode')));
            lstInvoiceDtlToGen.add(invoiceDtl);
            mapWOIdToInvoiceDtl.put(WO.Id, invoiceDtl);
        }
        System.debug(Logginglevel.WARN,'Map of WO ID and Invoice Detail: ' + mapWOIdToInvoiceDtl + ' WO Ids are: ' + lstQualifiedWOIds + ' : : WO : : ' + lstWOs);
        
        //Applying Mapping and inserting the Invoice Details
        if(lstInvoiceDtlToGen != null && lstInvoiceDtlToGen.size() > 0)
        {
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Applying Field Mapping to create Invoice Details';
            
            if(strDetailMapId != null && strDetailMapId.length()>0)
                lstInvoiceDtlToGen = objApplyRMAMapping.getApplyMapping1(strDetailMapId, mapWOIdToInvoiceDtl, false, schemaMap);
            
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Inserting Invoice Detail(s)';
            
            //insert lstInvoiceDtlToGen;
			if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstInvoiceDtlToGen, COMM_SecurityUtils.Access.Createable ) ) {
				insert lstInvoiceDtlToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			} else {
				throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
			}
        }

        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Invoice Detail(s) generated from Work Order' + ': ' + lstInvoiceDtlToGen.size();
    }
    //method for generate invoice detail from Case
    public void genrateInvoiceDetailFrmCase(String strDetailMapId_Case, map<String, Schema.SObjectType> schemaMap)
    {   
        List<SVMXC__Proforma_Invoice_Detail__c> lstInvoiceDtlToGen_Case = new List<SVMXC__Proforma_Invoice_Detail__c>();
        mapCaseIdToInvoiceId.clear();
        System.debug(Logginglevel.WARN,'mapCaseIdToInvoice: ' + mapCaseIdToInvoice);
        for(string str : mapCaseIdToInvoice.keySet())
        {
            SVMXC__Proforma_Invoice__c invoicesGenerated = new SVMXC__Proforma_Invoice__c();
            invoicesGenerated = mapCaseIdToInvoice.get(str);
            mapCaseIdToInvoiceId.put(str, invoicesGenerated.Id);
        }
        System.debug(Logginglevel.WARN,'mapCaseIdToInvoice: ' + mapCaseIdToInvoiceId);
        //Preapring list of Invoice Details to be generated -- One Per Work Order
        
        for(Case ObjCase : lstCases)
        {
            SVMXC__Proforma_Invoice_Detail__c invoiceDtl = new SVMXC__Proforma_Invoice_Detail__c();
            invoiceDtl.SVMXC__Case__c = ObjCase.Id;
            invoiceDtl.SVMXC__Proforma_Invoice__c = mapCaseIdToInvoice.get(ObjCase.Id).Id;
            invoiceDtl.SVMXC__Total_Amount__c = ObjCase.SVMXC__Proforma_Invoice_Amount__c;
            if(UserInfo.isMultiCurrencyOrganization())
                invoiceDtl.put('CurrencyIsoCode', string.valueOf(ObjCase.get('CurrencyIsoCode')));
            lstInvoiceDtlToGen_Case.add(invoiceDtl);
            mapCaseIdToInvoiceDtl.put(ObjCase.Id, invoiceDtl);
        }//mapCaseIdToInvoiceId
        System.debug(Logginglevel.WARN,'Map of Case ID and Invoice Detail: ' + mapCaseIdToInvoiceDtl + ' Case Ids are: ' + lstQualifiedCaseIds + ' : : WO : : ' + lstCases);
        
        //Applying Mapping and inserting the Invoice Details
        if(lstInvoiceDtlToGen_Case != null && lstInvoiceDtlToGen_Case.size() > 0)
        {
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Applying Field Mapping to create Invoice Details from Case';
            
            if(strDetailMapId_Case != null && strDetailMapId_Case.length()>0)
                lstInvoiceDtlToGen_Case = objApplyRMAMapping.getApplyMapping1(strDetailMapId_Case, mapCaseIdToInvoiceDtl, false, schemaMap);
            
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Inserting Invoice Detail(s)';
            
            //insert lstInvoiceDtlToGen_Case;
			if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstInvoiceDtlToGen_Case, COMM_SecurityUtils.Access.Createable ) ) {
				insert lstInvoiceDtlToGen_Case; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			} else {
				throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
			}
        }
        System.debug(Logginglevel.WARN,'list of generate invoice detail : ' +lstInvoiceDtlToGen_Case);
        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Invoice Detail(s) generated from Case' + ': ' + lstInvoiceDtlToGen_Case.size();
        lstInvoiceDtlToGen.addAll(lstInvoiceDtlToGen_Case);
    }
    //method for consolidation of case according to per record
    public void CaseConsolidationPerRecord(List<String> lstCaseIds, String strWhereClauseCase, string step)
    {
    //Consolidation of Case as per the Case -- One Invoice for One Case
        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Case(s)';
        
        string fieldToAdd = '';
        if(UserInfo.isMultiCurrencyOrganization())
            fieldToAdd += 'CurrencyIsoCode, ';
        string SOQLForCase = '';
        SOQLForCase = 'select id, SVMXC__Proforma_Invoice_Amount__c, AccountId, Account.Id , ' + fieldToAdd + 'Account.BillingStreet, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.BillingCity, SVMXC__Product__c, SVMXC__Is_Invoice_Created__c, SVMXC__Proforma_Invoice__c from Case where SVMXC__Is_Invoice_Created__c != true';
        
        if(lstCaseIds != null && lstCaseIds.size() > 0)
            SOQLForCase += ' AND id IN: lstCaseIds';
        
        if(strWhereClauseCase != null && strWhereClauseCase.length()>0)
            SOQLForCase += ' AND (' + strWhereClauseCase + ')'; 
        
        System.debug(Logginglevel.WARN,'4. Query string for WO is: ' + SOQLForCase);
        
        //Querying the Work Orders as per the qualification criteria defined with the Process
        lstCases.clear();
        lstQualifiedCaseIds.clear();
        
        lstCases = database.query(SOQLForCase);
        
         strSummary += getTAG038() + ' ' + lstCases.size();
        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Case(s) retrieved' + ': ' + lstCases.size();
        // + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Start Case Consolidation' + ': ' + strRule;
        /* if(lstCases == null || lstCases.size() == 0)
        {
            res.messageType = 'INFO';
            res.message = getTAG036();
            return res;
        } */
        System.debug(Logginglevel.WARN,'5. Case queried are: ' + lstCases);
        
        if(lstCases != null && lstCases.size() > 0)
        {
            //Preparing the list of Invoices to be generated as per the above calculations
            for(Case ObjCase : lstCases)
            {
                SVMXC__Proforma_Invoice__c newInvoiceToGen = null; 
                if(count > 1)
                {
                    newInvoiceToGen = new SVMXC__Proforma_Invoice__c();
                    newInvoiceToGen = lstInvoiceToGen[0].clone(false, false, false, false);
                    lstInvoiceToGen.add(newInvoiceToGen); 
                }
                else
                    newInvoiceToGen = lstInvoiceToGen[0];
                
                newInvoiceToGen.SVMXC__Type__c = 'Service';
                newInvoiceToGen.SVMXC__Status__c = 'Open';
                if(UserInfo.isMultiCurrencyOrganization())
                    newInvoiceToGen.put('CurrencyIsoCode', string.valueOf(ObjCase.get('CurrencyIsoCode')));
                newInvoiceToGen.SVMXC__Billing_City__c = ObjCase.Account.BillingCity;
                newInvoiceToGen.SVMXC__Billing_Country__c = ObjCase.Account.BillingCountry;
                newInvoiceToGen.SVMXC__Billing_Postal_Code__c = ObjCase.Account.BillingPostalCode;
                newInvoiceToGen.SVMXC__Billing_State__c = ObjCase.Account.BillingState;
                newInvoiceToGen.SVMXC__Billing_Street__c = ObjCase.Account.BillingStreet;
                newInvoiceToGen.SVMXC__Account__c = ObjCase.Account.Id;
                if(step.toUpperCase() == 'STEP1')
                {
                    SVMXC.INTF_WebservicesDef.SVMXMap objInvoiceObj = new SVMXC.INTF_WebservicesDef.SVMXMap();
                    objInvoiceObj.record = newInvoiceToGen;
                    mapCaseIdToInvoiceObj.put(objCase.Id, objInvoiceObj);
                }
                else
                    mapCaseIdToInvoice.put(ObjCase.Id, newInvoiceToGen);
                
                count++;
                lstQualifiedCaseIds.add(ObjCase.Id);
            }
        }
    }
    //method for consolidation of case according to Account
    public void CaseConsolidationAccount(List<String> lstCaseIds, String strRule1_Case, String strRule2_Case, String strWhereClauseCase, string step)
    {
    //Querying the Work Orders as per the qualification criteria defined with the Process
        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Case(s)';
        
        string fieldToAdd = '';
        if(strRule1_Case != null && strRule1_Case.length() > 0)
            fieldToAdd += strRule1_Case + ', ';
        if(strRule2_Case != null && strRule2_Case.length() > 0)
            fieldToAdd += strRule2_Case + ', ';
        if(UserInfo.isMultiCurrencyOrganization())
            fieldToAdd += 'CurrencyIsoCode, ';
        //SVMXC__Travel_Unit__c, SVMXC__Travel_Rate__c
        string SOQLForCase = '';
        SOQLForCase = 'select id, SVMXC__Proforma_Invoice_Amount__c,' + fieldToAdd + 'AccountId, Account.id, Account.BillingStreet, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.BillingCity, SVMXC__Product__c, SVMXC__Is_Invoice_Created__c, SVMXC__Proforma_Invoice__c from Case where SVMXC__Is_Invoice_Created__c != true AND AccountId != null';
        
        if(lstCaseIds != null && lstCaseIds.size() > 0)
            SOQLForCase += ' AND id IN: lstCaseIds';
        
        if(strWhereClauseCase != null && strWhereClauseCase.length()>0)
            SOQLForCase += ' and (' + strWhereClauseCase + ')'; 
        
        System.debug(Logginglevel.WARN,'4. Query string for Case is: ' + SOQLForCase);
        
        lstCases.clear();
        lstQualifiedCaseIds.clear();
        
        lstCases = database.query(SOQLForCase);
        
        strSummary +=  '\n '+getTAG038() + ' ' + lstCases.size();
        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Case(s) retrieved' + ': ' + lstCases.size() + '\n ' ;
        
        /* if(lstCases == null || lstCases.size() == 0)
        {
            res.messageType = 'INFO';
            res.message = getTAG036();
            return res;
        } */
        System.debug(Logginglevel.WARN,'5. Case queried are: ' + lstCases);
        
        //Preparing the Map to find the unique consolidations for the Work Orders to generate Invoices
        if(lstCases != null && lstCases.size() >0)
        {
            map<string, List<Case>> mapRulesAndLstCases = new map<string, List<Case>>();
              
            for(Case ObjCase : lstCases)
            {
                fieldToAdd = '';
                if(UserInfo.isMultiCurrencyOrganization())
                    fieldToAdd = ':' + ObjCase.get('CurrencyIsoCode');
                
                if(ObjCase.AccountId != null)
                {
                    if(strRule1_Case != null && strRule1_Case.length() > 0 && strRule2_Case != null && strRule2_Case.length() > 0)
                    {
                        if(!mapRulesAndLstCases.containsKey(ObjCase.get('AccountId')+':'+ ObjCase.get(strRule1_Case) + ':' + ObjCase.get(strRule2_Case) + fieldToAdd))
                            mapRulesAndLstCases.put(ObjCase.get('AccountId')+':'+ ObjCase.get(strRule1_Case) + ':' + ObjCase.get(strRule2_Case) + fieldToAdd, new List<Case>());
                        mapRulesAndLstCases.get(ObjCase.get('AccountId')+':'+ ObjCase.get(strRule1_Case) + ':' + ObjCase.get(strRule2_Case) + fieldToAdd).add(ObjCase);
                    }
                    else if(strRule1_Case != null && strRule1_Case.length() > 0 && (strRule2_Case == null || strRule2_Case.length() == 0))
                    {
                        if(!mapRulesAndLstCases.containsKey(ObjCase.get('AccountId')+':'+ ObjCase.get(strRule1_Case) + ':null' + fieldToAdd))
                            mapRulesAndLstCases.put(ObjCase.get('AccountId')+':'+ ObjCase.get(strRule1_Case) + ':null' + fieldToAdd, new List<Case>());
                        mapRulesAndLstCases.get(ObjCase.get('AccountId')+':'+ ObjCase.get(strRule1_Case) + ':null' + fieldToAdd).add(ObjCase);
                    }
                    else if(strRule2_Case != null && strRule2_Case.length() > 0 && (strRule1_Case == null || strRule1_Case.length() == 0))
                    {
                        if(!mapRulesAndLstCases.containsKey(ObjCase.get('AccountId')+':null:' + ObjCase.get(strRule2_Case) + fieldToAdd))
                            mapRulesAndLstCases.put(ObjCase.get('AccountId')+':null:' + ObjCase.get(strRule2_Case) + fieldToAdd, new List<Case>());
                        mapRulesAndLstCases.get(ObjCase.get('AccountId')+':null:' + ObjCase.get(strRule2_Case) + fieldToAdd).add(ObjCase);
                    }
                    else
                    {
                        if(!mapRulesAndLstCases.containsKey(ObjCase.get('AccountId')+':null:null' + fieldToAdd))
                            mapRulesAndLstCases.put(ObjCase.get('AccountId')+':null:null' + fieldToAdd, new List<Case>());
                        mapRulesAndLstCases.get(ObjCase.get('AccountId')+':null:null' + fieldToAdd).add(ObjCase);
                    }
                }
                lstQualifiedCaseIds.add(ObjCase.Id);
            }

            System.debug(Logginglevel.WARN,'6. Map Prepared after consolidation is: ' + mapRulesAndLstCases + ' and the size is: ' + mapRulesAndLstCases.size());
            
            //Preparing the list of Invoices to be generated as per the above calculations
            if(step.toUpperCase() == 'STEP1')
            {
                for(string strMapKey : mapRulesAndLstCases.keyset())
                {
                    if(!mapRulesAndLstWOs.containsKey(strMapKey))
                    {
                        SVMXC__Proforma_Invoice__c newInvoiceToGen = null; 
                        if(count > 1)
                        {
                            newInvoiceToGen = new SVMXC__Proforma_Invoice__c();
                            newInvoiceToGen = lstInvoiceToGen[0].clone(false, false, false, false);
                            lstInvoiceToGen.add(newInvoiceToGen); 
                        }
                        else
                            newInvoiceToGen = lstInvoiceToGen[0];
                            
                        newInvoiceToGen.SVMXC__Type__c = 'Service';
                        newInvoiceToGen.SVMXC__Status__c = 'Open';
                        List<Case> tempLstCase = new List<Case>();
                        tempLstCase = mapRulesAndLstCases.get(strMapKey);
                        SVMXC.INTF_WebservicesDef.SVMXMap objInvoiceObj = new SVMXC.INTF_WebservicesDef.SVMXMap();
                        objInvoiceObj.record = newInvoiceToGen;
                        
                        for(Case ObjCase : tempLstCase)
                        {
                            if(UserInfo.isMultiCurrencyOrganization())
                                newInvoiceToGen.put('CurrencyIsoCode', string.valueOf(ObjCase.get('CurrencyIsoCode')));
                            newInvoiceToGen.SVMXC__Billing_City__c = ObjCase.Account.BillingCity;
                            newInvoiceToGen.SVMXC__Billing_Country__c = ObjCase.Account.BillingCountry;
                            newInvoiceToGen.SVMXC__Billing_Postal_Code__c = ObjCase.Account.BillingPostalCode;
                            newInvoiceToGen.SVMXC__Billing_State__c = ObjCase.Account.BillingState;
                            newInvoiceToGen.SVMXC__Billing_Street__c = ObjCase.Account.BillingStreet;
                            newInvoiceToGen.SVMXC__Account__c = ObjCase.Account.Id;
                            mapCaseIdToInvoiceObj.put(ObjCase.Id, objInvoiceObj);
                        }
                        count++;
                    }
                    else
                    {   
                        List<Case> tempLstCase = new List<Case>();
                        tempLstCase = mapRulesAndLstCases.get(strMapKey);
                        List<SVMXC__Service_Order__c> lstWorders = new List<SVMXC__Service_Order__c>();
                        lstWorders = mapRulesAndLstWOs.get(strMapKey);
                        if(lstWorders != null && lstWorders.size() >0)
                        {
                            mapWOIdVCaseIds.put(lstWorders[0].Id, new List<String>());
                            for(Case objCase : tempLstCase)
                            {
                                mapWOIdVCaseIds.get(lstWorders[0].Id).add(objCase.Id);
                            }
                        }
                    }
                }
            }   
            else
            {
                for(string strMapKey : mapRulesAndLstCases.keyset())
                {
                    if(!mapRulesAndLstWOs.containsKey(strMapKey))
                    {
                        SVMXC__Proforma_Invoice__c newInvoiceToGen = null; 
                        if(count > 1)
                        {
                            newInvoiceToGen = new SVMXC__Proforma_Invoice__c();
                            newInvoiceToGen = lstInvoiceToGen[0].clone(false, false, false, false);
                            lstInvoiceToGen.add(newInvoiceToGen); 
                        }
                        else
                            newInvoiceToGen = lstInvoiceToGen[0];
                            
                        newInvoiceToGen.SVMXC__Type__c = 'Service';
                        newInvoiceToGen.SVMXC__Status__c = 'Open';
                        List<Case> tempLstCase = new List<Case>();
                        tempLstCase = mapRulesAndLstCases.get(strMapKey);
                        for(Case ObjCase : tempLstCase)
                        {
                            if(UserInfo.isMultiCurrencyOrganization())
                                newInvoiceToGen.put('CurrencyIsoCode', string.valueOf(ObjCase.get('CurrencyIsoCode')));
                            newInvoiceToGen.SVMXC__Billing_City__c = ObjCase.Account.BillingCity;
                            newInvoiceToGen.SVMXC__Billing_Country__c = ObjCase.Account.BillingCountry;
                            newInvoiceToGen.SVMXC__Billing_Postal_Code__c = ObjCase.Account.BillingPostalCode;
                            newInvoiceToGen.SVMXC__Billing_State__c = ObjCase.Account.BillingState;
                            newInvoiceToGen.SVMXC__Billing_Street__c = ObjCase.Account.BillingStreet;
                            newInvoiceToGen.SVMXC__Account__c = ObjCase.Account.Id;
                            mapCaseIdToInvoice.put(ObjCase.Id, newInvoiceToGen);
                        }
                        count++;
                    }
                    else
                    {   
                        List<SVMXC__Service_Order__c> lstWorders = new List<SVMXC__Service_Order__c>();
                        lstWorders = mapRulesAndLstWOs.get(strMapKey);
                        if(lstWorders != null && lstWorders.size() >0)
                        {
                            if(mapWOIdToInvoice.containsKey(lstWorders[0].Id))
                            {
                                SVMXC__Proforma_Invoice__c newInvoiceToGen = new SVMXC__Proforma_Invoice__c();
                                newInvoiceToGen = mapWOIdToInvoice.get(lstWorders[0].Id);
                                List<Case> tempLstCase = new List<Case>();
                                tempLstCase = mapRulesAndLstCases.get(strMapKey);
                                for(Case ObjCase : tempLstCase)
                                {
                                    mapCaseIdToInvoice.put(ObjCase.Id, newInvoiceToGen);
                                }
                            }
                        }
                    }
                }
            }
        }//Querying the Work Orders as per the qualification criteria defined with the Process
        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Case(s)';
        
    }
    //method for consolidation of WO according to Account
    public void WOConsolidationAccount(List<String> lstWOIds, String strRule1, String strRule2, String strWhereClauseWO, string step)
    {
    //Querying the Work Orders as per the qualification criteria defined with the Process
        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Work order(s)';

        string fieldToAdd = '';
        if(strRule1 != null && strRule1.length() > 0)
            fieldToAdd += strRule1 + ', ';
        if(strRule2 != null && strRule2.length() > 0)
            fieldToAdd += strRule2 + ', ';
        if(UserInfo.isMultiCurrencyOrganization())
            fieldToAdd += 'CurrencyIsoCode, ';
        String SOQLForWO;
        
        SOQLForWO = 'select id, SVMXC__Travel_Unit__c, SVMXC__Travel_Rate__c, ' + fieldToAdd + 'SVMXC__Company__c, SVMXC__Proforma_Invoice_Amount__c, SVMXC__Company__r.BillingStreet, SVMXC__Company__r.BillingState, SVMXC__Company__r.BillingPostalCode, SVMXC__Company__r.BillingCountry, SVMXC__Company__r.BillingCity, SVMXC__Invoice_Created__c, SVMXC__Invoice_Number__c from SVMXC__Service_Order__c where SVMXC__Invoice_Created__c != true AND SVMXC__Company__c != null';
        if(lstWOIds != null && lstWOIds.size() > 0)
            SOQLForWO += ' AND id IN: lstWOIds';
        
        if(strWhereClauseWO != null && strWhereClauseWO.length()>0)
            SOQLForWO += ' and (' + strWhereClauseWO + ')'; 
        
        System.debug(Logginglevel.WARN,'4. Query string for WO is: ' + SOQLForWO);
        
        lstWOs.clear();
        lstQualifiedWOIds.clear();
        
        lstWOs = database.query(SOQLForWO);
        strSummary +=  getTAG006() + ' ' + lstWOs.size();
        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Work Order(s) retrieved' + ': ' + lstWOs.size() + '\n ';
        
        /* if(lstWOs == null || lstWOs.size() == 0)
        {
            res.messageType = 'INFO';
            res.message = getTAG036();
            return res;
        } */
        System.debug(Logginglevel.WARN,'5. WO queried are: ' + lstWOs);
        
        //Preparing the Map to find the unique consolidations for the Work Orders to generate Invoices
        if(lstWOs != null && lstWOs.size() >0)
        {
            
              
            for(SVMXC__Service_Order__c WO : lstWOs)
            {
                fieldToAdd = '';
                if(UserInfo.isMultiCurrencyOrganization())
                    fieldToAdd = ':' + WO.get('CurrencyIsoCode');
                
                if(WO.SVMXC__Company__c != null)
                {
                    if(strRule1 != null && strRule1.length() > 0 && strRule2 != null && strRule2.length() > 0)
                    {
                        if(!mapRulesAndLstWOs.containsKey(WO.get('SVMXC__Company__c')+':'+ WO.get(strRule1) + ':' + WO.get(strRule2) + fieldToAdd))
                            mapRulesAndLstWOs.put(WO.get('SVMXC__Company__c')+':'+ WO.get(strRule1) + ':' + WO.get(strRule2) + fieldToAdd, new List<SVMXC__Service_Order__c>());
                        mapRulesAndLstWOs.get(WO.get('SVMXC__Company__c')+':'+ WO.get(strRule1) + ':' + WO.get(strRule2) + fieldToAdd).add(WO);
                    }
                    else if(strRule1 != null && strRule1.length() > 0 && (strRule2 == null || strRule2.length() == 0))
                    {
                        if(!mapRulesAndLstWOs.containsKey(WO.get('SVMXC__Company__c')+':'+ WO.get(strRule1) + ':null' + fieldToAdd))
                            mapRulesAndLstWOs.put(WO.get('SVMXC__Company__c')+':'+ WO.get(strRule1) + ':null' + fieldToAdd, new List<SVMXC__Service_Order__c>());
                        mapRulesAndLstWOs.get(WO.get('SVMXC__Company__c')+':'+ WO.get(strRule1) + ':null' + fieldToAdd).add(WO);
                    }
                    else if(strRule2 != null && strRule2.length() > 0 && (strRule1 == null || strRule1.length() == 0))
                    {
                        if(!mapRulesAndLstWOs.containsKey(WO.get('SVMXC__Company__c')+':null:' + WO.get(strRule2) + fieldToAdd))
                            mapRulesAndLstWOs.put(WO.get('SVMXC__Company__c')+':null:' + WO.get(strRule2) + fieldToAdd, new List<SVMXC__Service_Order__c>());
                        mapRulesAndLstWOs.get(WO.get('SVMXC__Company__c')+':null:' + WO.get(strRule2) + fieldToAdd).add(WO);
                    }
                    else
                    {
                        if(!mapRulesAndLstWOs.containsKey(WO.get('SVMXC__Company__c')+':null:null' + fieldToAdd))
                            mapRulesAndLstWOs.put(WO.get('SVMXC__Company__c')+':null:null' + fieldToAdd, new List<SVMXC__Service_Order__c>());
                        mapRulesAndLstWOs.get(WO.get('SVMXC__Company__c')+':null:null' + fieldToAdd).add(WO);
                    }
                }
                
                lstQualifiedWOIds.add(WO.Id);
            }
            
            System.debug(Logginglevel.WARN,'6. Map Prepared after consolidation is: ' + mapRulesAndLstWOs + ' and the size is: ' + mapRulesAndLstWOs.size());
            
            //Preparing the list of Invoices to be generated as per the above calculations
            for(string strMapKey : mapRulesAndLstWOs.keyset())
            {
                SVMXC__Proforma_Invoice__c newInvoiceToGen = null; 
                if(count > 1)
                {
                    newInvoiceToGen = new SVMXC__Proforma_Invoice__c();
                    newInvoiceToGen = lstInvoiceToGen[0].clone(false, false, false, false);
                    lstInvoiceToGen.add(newInvoiceToGen); 
                }
                else
                    newInvoiceToGen = lstInvoiceToGen[0];

                newInvoiceToGen.SVMXC__Type__c = 'Service';
                newInvoiceToGen.SVMXC__Status__c = 'Open';
                List<SVMXC__Service_Order__c> tempLstWO = new List<SVMXC__Service_Order__c>();
                tempLstWO = mapRulesAndLstWOs.get(strMapKey);
                for(SVMXC__Service_Order__c WO : tempLstWO)
                {
                    if(UserInfo.isMultiCurrencyOrganization())
                        newInvoiceToGen.put('CurrencyIsoCode', string.valueOf(WO.get('CurrencyIsoCode')));
                    newInvoiceToGen.SVMXC__Billing_City__c = WO.SVMXC__Company__r.BillingCity;
                    newInvoiceToGen.SVMXC__Billing_Country__c = WO.SVMXC__Company__r.BillingCountry;
                    newInvoiceToGen.SVMXC__Billing_Postal_Code__c = WO.SVMXC__Company__r.BillingPostalCode;
                    newInvoiceToGen.SVMXC__Billing_State__c = WO.SVMXC__Company__r.BillingState;
                    newInvoiceToGen.SVMXC__Billing_Street__c = WO.SVMXC__Company__r.BillingStreet;
                    newInvoiceToGen.SVMXC__Account__c = WO.SVMXC__Company__c;
                    if(step.toUpperCase() == 'STEP1')
                    {
                        SVMXC.INTF_WebservicesDef.SVMXMap objInvoiceObj = new SVMXC.INTF_WebservicesDef.SVMXMap();
                        objInvoiceObj.record = newInvoiceToGen;
                        mapWOIdInvoiceObjects.put(WO.Id, objInvoiceObj);
                    }
                    else
                        mapWOIdToInvoice.put(WO.Id, newInvoiceToGen);
                }
                count++;
            }
        
        }
    }
    //method for consolidation of WO according to per record
    public void WOConsolidationPerRecord(List<String> lstWOIds, String strWhereClauseWO, String step)
    {
    //Consolidation of Work Orders as per the Work Order -- One Invoice for One Work Order
        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Work order(s)';
        
        string fieldToAdd = '';
        if(UserInfo.isMultiCurrencyOrganization())
            fieldToAdd += 'CurrencyIsoCode, ';
        string SOQLForWO = '';
        SOQLForWO = 'select id, SVMXC__Company__c, SVMXC__Proforma_Invoice_Amount__c, SVMXC__Travel_Unit__c, SVMXC__Travel_Rate__c, ' + fieldToAdd + 'SVMXC__Company__r.BillingStreet, SVMXC__Company__r.BillingState, SVMXC__Company__r.BillingPostalCode, SVMXC__Company__r.BillingCountry, SVMXC__Company__r.BillingCity, SVMXC__Invoice_Created__c, SVMXC__Invoice_Number__c from SVMXC__Service_Order__c where SVMXC__Invoice_Created__c != true';
        if(lstWOIds != null && lstWOIds.size() > 0)
            SOQLForWO += ' AND id IN: lstWOIds';
        
        if(strWhereClauseWO != null && strWhereClauseWO.length()>0)
            SOQLForWO += ' AND (' + strWhereClauseWO + ')'; 
        
        System.debug(Logginglevel.WARN,'4. Query string for WO is: ' + SOQLForWO);
        
        //Querying the Work Orders as per the qualification criteria defined with the Process
        lstWOs.clear();
        lstQualifiedWOIds.clear();
        
        lstWOs = database.query(SOQLForWO);
        
        strSummary += getTAG006() + ' ' + lstWOs.size();
        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Work Order(s) retrieved' + ': ' + lstWOs.size();
        // + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Start Work Order Consolidation' + ': ' + strRule;
        /* if(lstWOs == null || lstWOs.size() == 0)
        {
            res.messageType = 'INFO';
            res.message = getTAG036();
            return res;
        } */
        System.debug(Logginglevel.WARN,'5. WO queried are: ' + lstWOs);
        
        if(lstWOs != null && lstWOs.size() > 0)
        {
            //Preparing the list of Invoices to be generated as per the above calculations
            for(SVMXC__Service_Order__c WO : lstWOs)
            {
                SVMXC__Proforma_Invoice__c newInvoiceToGen = null; 
                if(count > 1)
                {
                    newInvoiceToGen = new SVMXC__Proforma_Invoice__c();
                    newInvoiceToGen = lstInvoiceToGen[0].clone(false, false, false, false);
                    lstInvoiceToGen.add(newInvoiceToGen); 
                }
                else
                    newInvoiceToGen = lstInvoiceToGen[0];
                
                newInvoiceToGen.SVMXC__Type__c = 'Service';
                newInvoiceToGen.SVMXC__Status__c = 'Open';
                if(UserInfo.isMultiCurrencyOrganization())
                    newInvoiceToGen.put('CurrencyIsoCode', string.valueOf(WO.get('CurrencyIsoCode')));
                newInvoiceToGen.SVMXC__Billing_City__c = WO.SVMXC__Company__r.BillingCity;
                newInvoiceToGen.SVMXC__Billing_Country__c = WO.SVMXC__Company__r.BillingCountry;
                newInvoiceToGen.SVMXC__Billing_Postal_Code__c = WO.SVMXC__Company__r.BillingPostalCode;
                newInvoiceToGen.SVMXC__Billing_State__c = WO.SVMXC__Company__r.BillingState;
                newInvoiceToGen.SVMXC__Billing_Street__c = WO.SVMXC__Company__r.BillingStreet;
                newInvoiceToGen.SVMXC__Account__c = WO.SVMXC__Company__c;
                if(step.toUpperCase() == 'STEP1')
                {
                    SVMXC.INTF_WebservicesDef.SVMXMap objInvoiceObj = new SVMXC.INTF_WebservicesDef.SVMXMap();
                    objInvoiceObj.record = newInvoiceToGen;
                    mapWOIdInvoiceObjects.put(WO.Id, objInvoiceObj);
                }
                else
                    mapWOIdToInvoice.put(WO.Id, newInvoiceToGen);
                
                count++;
                lstQualifiedWOIds.add(WO.Id);
            }
        }
    }
    
    //Method to be called for the Step 1 as for doing the calculation of the Invoice, Invoice Details and Invoice Detail Lines 
    public SVMXC.INTF_WebservicesDef.INTF_Response GenerateInvoiceDocForStep1(List<string> lstWOIds, List<String> lstCaseIds, map<string, string> mapInputValues)
    {
        SVMXC.INTF_WebservicesDef.INTF_Response res = new SVMXC.INTF_WebservicesDef.INTF_Response();
        try
        {
            List<SVMXC.INTF_WebservicesDef.SVMXMap> lstSVMXMapRes = new List<SVMXC.INTF_WebservicesDef.SVMXMap>();
            //List<SVMXC__Service_Order__c> lstWOs = new List<SVMXC__Service_Order__c>();
            //List<Case> lstCases = new List<Case>();
            //List<SVMXC__Proforma_Invoice__c> lstInvoiceToGen = new List<SVMXC__Proforma_Invoice__c>();
            List<SVMXC__Proforma_Invoice_Detail__c> lstInvoiceDtlToGen = new List<SVMXC__Proforma_Invoice_Detail__c>();
            List<SVMXC__Proforma_Invoice_Line__c> lstInvoiceLinesToGen = new List<SVMXC__Proforma_Invoice_Line__c>();
            
            
            map<string, SVMXC.INTF_WebservicesDef.SVMXMap> mapInvoiceObjectDetails = new map<string, SVMXC.INTF_WebservicesDef.SVMXMap>();
            map<string, List<SVMXC__Proforma_Invoice_Line__c>> mapWOIdToLstInvoiceLines = new map<string, List<SVMXC__Proforma_Invoice_Line__c>>();
            map<string, List<SVMXC__Proforma_Invoice_Line__c>> mapCaseIdToLstInvoiceLines = new map<string, List<SVMXC__Proforma_Invoice_Line__c>>();
            
            INTF_ApplyMapping objApplyRMAMapping = new INTF_ApplyMapping();
            map<String, Schema.SObjectType> schemaMap = new map<String, Schema.SObjectType>();
            map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(Schema.SObjectType s : gd.values())
                schemaMap.put(s.getDescribe().getName(),s);
            
            if(mapInputValues != null && mapInputValues.size() > 0)
            {
                string strRule1 = string.valueOf(mapInputValues.get('SVMXC__Secondary_Consolidation_Rule__c'));
                string strRule2 = string.valueOf(mapInputValues.get('SVMXC__Tertiary_Consolidation_Rule__c'));
                string strInvoiceMapId = mapInputValues.get('SVMXC__Node_Parent__c');
                string strDetailMapId = mapInputValues.get('SVMXC__Process__c');
                string strLineMapId = mapInputValues.get('SVMXC__Process1__c');
                string strDetailMapId_Case = mapInputValues.get('SVMXC__Process2__c');
                string strLineMapId_Case = mapInputValues.get('SVMXC__Process3__c');
                string strExpId = mapInputValues.get('SVMXC__Module__c');
                boolean isNonBillableLinesIncluded = boolean.valueOf(mapInputValues.get('SVMXC__Include_Product__c'));
                string strWhereClause = '';
                //List<string> lstQualifiedWOIDs = new List<string>();
                //List<string> lstQualifiedCaseIDs = new List<string>();
                string SOQLForWO = '';
                string SOQLForCase = '';
                //new variables
                string strExpId_Case = mapInputValues.get('SVMXC__Submodule__c');
                string strRule1_Case = string.valueOf(mapInputValues.get('SVMXC__Secondary_Consolidation_Rule_Case__c'));
                string strRule2_Case = string.valueOf(mapInputValues.get('SVMXC__Tertiary_Consolidation_Rule_Case__c'));
                //string strDetailMapId
                //map<string, List<SVMXC__Service_Order__c>> mapRulesAndLstWOs = new map<string, List<SVMXC__Service_Order__c>>();
                
                
                boolean isScopeWO = boolean.valueOf(mapInputValues.get('isScopeWO'));
                boolean isScopeCase = boolean.valueOf(mapInputValues.get('isScopeCase'));
                
                //Preparing the list of Invoices to be generated as per the above calculations
                integer count = 1;
                SVMXC__Proforma_Invoice__c invoiceToGen = new SVMXC__Proforma_Invoice__c();
                lstInvoiceToGen.add(invoiceToGen);
                
                if(strInvoiceMapId != null && strInvoiceMapId.length() > 0)
                    lstInvoiceToGen = objApplyRMAMapping.getValueMapping(lstInvoiceToGen, strInvoiceMapId, schemaMap);
                
                if(isScopeWO)
                {
                    strWhereClause = '';
                    //Preparing the Where Clause for querying the Work Orders for which the Invoice is to generated
                    if(strExpId != null && strExpId.length() > 0)
                    {
                        List<SVMXC__ServiceMax_Processes__c> expProc = new List<SVMXC__ServiceMax_Processes__c>();
                        expProc = [Select Id, Name,SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id=:strExpId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        if(expProc != null && expProc.size() == 1)
                            strWhereClause = expProc[0].SVMXC__Parent_Object_Criteria__c;
                    }
                   
                    //Consolidation of Work Orders as per the Account -- One Invoice for One Account in list of Work Orders
                    if(string.valueOf(mapInputValues.get('SVMXC__Primary_Consolidation_Rule__c')) == 'ACCOUNT')
                    {
                       
                        WOConsolidationAccount(lstWOIds, strRule1, strRule2, strWhereClause, 'STEP1');
                    }
                    else if(string.valueOf(mapInputValues.get('SVMXC__Primary_Consolidation_Rule__c')) == 'WORK ORDER' || string.valueOf(mapInputValues.get('SVMXC__Primary_Consolidation_Rule__c')) == 'PER RECORD')
                    { 
                        WOConsolidationPerRecord(lstWOIds, strWhereClause, 'STEP1');
                    }
                    
                    //Preapring a map of WO Id to Invoice Id to be used to generate Invoice Details
                    map<string, SVMXC__Proforma_Invoice_Detail__c> mapWOIdToInvoiceDtl = new map<string, SVMXC__Proforma_Invoice_Detail__c>();
                    for(SVMXC__Service_Order__c WO : lstWOs)
                    {
                        SVMXC__Proforma_Invoice_Detail__c invoiceDtl = new SVMXC__Proforma_Invoice_Detail__c();
                        invoiceDtl.SVMXC__Work_Order__c = WO.Id;
                        invoiceDtl.SVMXC__Total_Amount__c = WO.SVMXC__Proforma_Invoice_Amount__c;
                        if(UserInfo.isMultiCurrencyOrganization())
                            invoiceDtl.put('CurrencyIsoCode', string.valueOf(WO.get('CurrencyIsoCode')));
                            
                        lstInvoiceDtlToGen.add(invoiceDtl);
                        mapWOIdToInvoiceDtl.put(WO.Id, invoiceDtl);
                        
                        //Preapring a SVMX_map for the Invoice Details calculaed to be generated
                        SVMXC.INTF_WebservicesDef.SVMXMap objInvoiceDtlObj = new SVMXC.INTF_WebservicesDef.SVMXMap();
                        objInvoiceDtlObj.record = invoiceDtl;
                        mapInvoiceObjectDetails.put(WO.Id, objInvoiceDtlObj);
                    }
                    
                    //Applying the Mapping for the Invoice Details
                    if(lstInvoiceDtlToGen != null && lstInvoiceDtlToGen.size() > 0 && strDetailMapId != null && strDetailMapId.length() > 0)
                        lstInvoiceDtlToGen = objApplyRMAMapping.getApplyMapping1(strDetailMapId, mapWOIdToInvoiceDtl, false, schemaMap);
                    
                    //Querying the WO Details of Type: Usage/Consumption for the qualified WOs
                    List<SVMXC__Service_Order_Line__c> lstWODtls = new List<SVMXC__Service_Order_Line__c>();
                    
                    string CurField = '';
                    if(UserInfo.isMultiCurrencyOrganization())
                        CurField = 'CurrencyIsoCode, ';
                    string strSOQLWODtls = 'select id, ' + CurField + 'SVMXC__Applied_Rate_Type__c, SVMXC__Is_Billable__c, SVMXC__Total_Line_Price__c, SVMXC__Billable_Quantity__c, SVMXC__Billable_Line_Price__c, SVMXC__Line_Type__c, SVMXC__Serial_Number__c, SVMXC__Discount__c, SVMXC__Expense_Type__c, SVMXC__Actual_Price2__c, SVMXC__Product__c, SVMXC__Actual_Quantity2__c, SVMXC__Service_Order__c from SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c IN: lstQualifiedWOIDs and RecordType.Name = \'Usage/Consumption\'';
                    if(isNonBillableLinesIncluded == false)
                        strSOQLWODtls += ' AND SVMXC__Is_Billable__c = true';
                    
                    lstWODtls = database.query(strSOQLWODtls);
                    Map<string, SVMXC__Proforma_Invoice_Line__c> mapWODtlIdVInvoiceLine = new Map<string, SVMXC__Proforma_Invoice_Line__c>();
                    for(SVMXC__Service_Order_Line__c WODtl : lstWODtls)
                    {
                        SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                        invoiceLine.SVMXC__Work_Order__c = WODtl.SVMXC__Service_Order__c;
                        invoiceLine.SVMXC__Work_Details__c = WODtl.Id;
                        invoiceLine.SVMXC__Product__c = WODtl.SVMXC__Product__c;
                        invoiceLine.SVMXC__Billable_Quantity__c = WODtl.SVMXC__Billable_Quantity__c;
                        invoiceLine.SVMXC__Quantity__c = WODtl.SVMXC__Actual_Quantity2__c;
                        invoiceLine.SVMXC__Line_Type__c = WODtl.SVMXC__Line_Type__c;
                        invoiceLine.SVMXC__Is_Billable__c = WODtl.SVMXC__Is_Billable__c;
                        invoiceLine.SVMXC__Applied_Rate_Type__c = WODtl.SVMXC__Applied_Rate_Type__c;
                        invoiceLine.SVMXC__Price__c = WODtl.SVMXC__Actual_Price2__c;
                        invoiceLine.SVMXC__Total_Line_Price__c = WODtl.SVMXC__Total_Line_Price__c;
                        invoiceLine.SVMXC__Billable_Line_Price__c = WODtl.SVMXC__Billable_Line_Price__c;
                        invoiceLine.SVMXC__Discount__c = WODtl.SVMXC__Discount__c; 
                        invoiceLine.SVMXC__Expense_Type__c = WODtl.SVMXC__Expense_Type__c;
                        if(UserInfo.isMultiCurrencyOrganization())
                            invoiceLine.put('CurrencyIsoCode', string.valueOf(mapWOIdToInvoiceDtl.get(WODtl.SVMXC__Service_Order__c).get('CurrencyIsoCode')));
                                
                        lstInvoiceLinesToGen.add(invoiceLine);
                        if(mapWOIdToLstInvoiceLines.containsKey(WODtl.SVMXC__Service_Order__c))
                            mapWOIdToLstInvoiceLines.get(WODtl.SVMXC__Service_Order__c).add(invoiceLine);
                        else
                        {
                            List<SVMXC__Proforma_Invoice_Line__c> tempLstInvoiceLines = new List<SVMXC__Proforma_Invoice_Line__c>();
                            tempLstInvoiceLines.add(invoiceLine);
                            mapWOIdToLstInvoiceLines.put(WODtl.SVMXC__Service_Order__c, tempLstInvoiceLines);
                        }
                        mapWODtlIdVInvoiceLine.put(WODtl.Id, invoiceLine);
                    }
                   
                    //Applying the Mapping for the Invoice Line
                    if(lstInvoiceLinesToGen != null && lstInvoiceLinesToGen.size() > 0 && strLineMapId != null && strLineMapId.length() > 0)
                        lstInvoiceLinesToGen = objApplyRMAMapping.getApplyMapping1(strLineMapId, mapWODtlIdVInvoiceLine, false, schemaMap);
                    
                    for(SVMXC__Service_Order__c WO : lstWOs)
                    {
                        if(WO.SVMXC__Travel_Unit__c != null && (WO.SVMXC__Travel_Unit__c ==  'Flat Rate' || WO.SVMXC__Travel_Unit__c ==  'Zone Based'))
                        {
                            SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                            invoiceLine.SVMXC__Work_Order__c = WO.Id;
                            invoiceLine.SVMXC__Line_Type__c = 'Travel';
                            invoiceLine.SVMXC__Is_Billable__c = true;
                            invoiceLine.SVMXC__Price__c = WO.SVMXC__Travel_Rate__c;
                            invoiceLine.SVMXC__Total_Line_Price__c = WO.SVMXC__Travel_Rate__c;
                            invoiceLine.SVMXC__Billable_Line_Price__c = WO.SVMXC__Travel_Rate__c;
                            if(UserInfo.isMultiCurrencyOrganization())
                                invoiceLine.put('CurrencyIsoCode', string.valueOf(mapWOIdToInvoiceDtl.get(WO.Id).get('CurrencyIsoCode')));
                            lstInvoiceLinesToGen.add(invoiceLine);
                            
                            if(mapWOIdToLstInvoiceLines.containsKey(WO.Id))
                                mapWOIdToLstInvoiceLines.get(WO.Id).add(invoiceLine);
                            else
                            {
                                List<SVMXC__Proforma_Invoice_Line__c> tempLstInvoiceLines = new List<SVMXC__Proforma_Invoice_Line__c>();
                                tempLstInvoiceLines.add(invoiceLine);
                                mapWOIdToLstInvoiceLines.put(WO.Id, tempLstInvoiceLines);
                            }
                        }
                    }
                }
                
                if(isScopeCase)
                {
                    strWhereClause = '';
                    //Preparing the Where Clause for querying the Case for which the Invoice is to generated
                    if(strExpId_Case != null && strExpId_Case.length() > 0)
                    {
                        List<SVMXC__ServiceMax_Processes__c> expProc = new List<SVMXC__ServiceMax_Processes__c>();
                        expProc = [Select Id, Name,SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id=:strExpId_Case]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        if(expProc != null && expProc.size() == 1)
                            strWhereClause = expProc[0].SVMXC__Parent_Object_Criteria__c;
                    }
                    
                    //Consolidation of Cases as per the Account -- One Invoice for One Account in list of Case
                    if(string.valueOf(mapInputValues.get('SVMXC__Primary_Consolidation_Rule__c')) == 'ACCOUNT')
                    {
                        CaseConsolidationAccount( lstCaseIds, strRule1_Case, strRule2_Case, strWhereClause, 'STEP1');
                    }
                    else if(string.valueOf(mapInputValues.get('SVMXC__Primary_Consolidation_Rule__c')) == 'WORK ORDER' || string.valueOf(mapInputValues.get('SVMXC__Primary_Consolidation_Rule__c')) == 'PER RECORD')
                    { 
                        CaseConsolidationPerRecord(lstCaseIds, strWhereClause, 'STEP1');
                    }
                    
                    //Preapring a map of Case Id to Invoice Id to be used to generate Invoice Details
                    map<string, SVMXC__Proforma_Invoice_Detail__c> mapCaseIdToInvoiceDtl = new map<string, SVMXC__Proforma_Invoice_Detail__c>();
                    lstInvoiceDtlToGen.clear();
                    for(Case objCase : lstCases)
                    {
                        SVMXC__Proforma_Invoice_Detail__c invoiceDtl = new SVMXC__Proforma_Invoice_Detail__c();
                        invoiceDtl.SVMXC__Case__c = objCase.Id;
                        invoiceDtl.SVMXC__Total_Amount__c = objCase.SVMXC__Proforma_Invoice_Amount__c;
                        if(UserInfo.isMultiCurrencyOrganization())
                            invoiceDtl.put('CurrencyIsoCode', string.valueOf(objCase.get('CurrencyIsoCode')));
                        
                        lstInvoiceDtlToGen.add(invoiceDtl);
                        mapCaseIdToInvoiceDtl.put(objCase.Id, invoiceDtl);
                        
                        //Preapring a SVMX_map for the Invoice Details calculaed to be generated
                        SVMXC.INTF_WebservicesDef.SVMXMap objInvoiceDtlObj = new SVMXC.INTF_WebservicesDef.SVMXMap();
                        objInvoiceDtlObj.record = invoiceDtl;
                        mapInvoiceObjectDetails.put(objCase.Id, objInvoiceDtlObj);
                    }
                    
                    //Applying the Mapping for the Invoice Details
                    if(lstInvoiceDtlToGen != null && lstInvoiceDtlToGen.size() > 0 && strDetailMapId_Case != null && strDetailMapId_Case.length() > 0)
                        lstInvoiceDtlToGen = objApplyRMAMapping.getApplyMapping1(strDetailMapId_Case, mapCaseIdToInvoiceDtl, false, schemaMap);
                    
                    //Querying the Case Details of Type: Usage/Consumption for the qualified Case
                    List<SVMXC__Time_Tracker__c> lstTimeTracker = new List<SVMXC__Time_Tracker__c>();
                    string CurField = '';
                    if(UserInfo.isMultiCurrencyOrganization())
                        CurField = 'CurrencyIsoCode, ';
                    string strSOQLCaseActis = 'select id, ' + CurField + 'SVMXC__Activity_Type__c, SVMXC__Is_Billable__c ,SVMXC__Applied_Rate_Type__c, SVMXC__Billable_Line_Price__c, SVMXC__Billable_Qty__c, SVMXC__Covered__c,  SVMXC__Line_Price__c, SVMXC__Line_Qty__c, SVMXC__Case__c from SVMXC__Time_Tracker__c where SVMXC__Case__c IN: lstQualifiedCaseIds';
                    
                    lstTimeTracker = database.query(strSOQLCaseActis);
                    lstInvoiceLinesToGen.clear();
                    Map<String, SVMXC__Proforma_Invoice_Line__c> mapCaseActVInvoiceLine = new Map<String, SVMXC__Proforma_Invoice_Line__c>();
                    for(SVMXC__Time_Tracker__c objTimeTracker : lstTimeTracker)
                    {
                        SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                        invoiceLine.SVMXC__Case__c = objTimeTracker.SVMXC__Case__c;
                        invoiceLine.SVMXC__Proforma_Invoice_Detail__c = (mapCaseIdToInvoiceDtl.get(objTimeTracker.SVMXC__Case__c)).Id;
                        invoiceLine.SVMXC__Time_Tracker__c = objTimeTracker.Id;
                        invoiceLine.SVMXC__Billable_Quantity__c = objTimeTracker.SVMXC__Billable_Qty__c;
                        invoiceLine.SVMXC__Applied_Rate_Type__c = objTimeTracker.SVMXC__Applied_Rate_Type__c;
                        invoiceLine.SVMXC__Billable_Line_Price__c = objTimeTracker.SVMXC__Billable_Line_Price__c;
                        invoiceLine.SVMXC__Discount__c = objTimeTracker.SVMXC__Covered__c; 
                        invoiceLine.SVMXC__Is_Billable__c = objTimeTracker.SVMXC__Is_Billable__c; 
                        //invoiceLine.SVMXC__Product__c = objTimeTracker.SVMXC__Product__c;
                        //invoiceLine.SVMXC__Quantity__c = objTimeTracker.SVMXC__Actual_Quantity2__c;
                        //invoiceLine.SVMXC__Line_Type__c = objTimeTracker.SVMXC__Line_Type__c;
                        //invoiceLine.SVMXC__Is_Billable__c = objTimeTracker.SVMXC__Is_Billable__c;
                        //invoiceLine.SVMXC__Price__c = objTimeTracker.SVMXC__Actual_Price2__c;
                        //invoiceLine.SVMXC__Total_Line_Price__c = objTimeTracker.SVMXC__Total_Line_Price__c;
                        //invoiceLine.SVMXC__Expense_Type__c = objTimeTracker.SVMXC__Expense_Type__c;
                        if(UserInfo.isMultiCurrencyOrganization())
                            invoiceLine.put('CurrencyIsoCode', string.valueOf(mapCaseIdToInvoiceDtl.get(objTimeTracker.SVMXC__Case__c).get('CurrencyIsoCode')));
                                
                        lstInvoiceLinesToGen.add(invoiceLine);
                        if(mapCaseIdToLstInvoiceLines.containsKey(objTimeTracker.SVMXC__Case__c))
                            mapCaseIdToLstInvoiceLines.get(objTimeTracker.SVMXC__Case__c).add(invoiceLine);
                        else
                        {
                            List<SVMXC__Proforma_Invoice_Line__c> tempLstInvoiceLines = new List<SVMXC__Proforma_Invoice_Line__c>();
                            tempLstInvoiceLines.add(invoiceLine);
                            mapCaseIdToLstInvoiceLines.put(objTimeTracker.SVMXC__Case__c, tempLstInvoiceLines);
                        }
                        mapCaseActVInvoiceLine.put(objTimeTracker.Id, invoiceLine);
                    }
                    
                    //Applying the Mapping for the Invoice Line
                    if(lstInvoiceLinesToGen != null && lstInvoiceLinesToGen.size() > 0 && strLineMapId_Case != null && strLineMapId_Case.length() > 0)
                        lstInvoiceLinesToGen = objApplyRMAMapping.getApplyMapping1(strLineMapId_Case, mapCaseActVInvoiceLine, false, schemaMap);
                }

                
                //Preparing the SVMX_map for the Invoice Detail Lines for the Response
                set<sObject> tempInvoiceSet = new set<sObject>();
                SVMXC.INTF_WebservicesDef.SVMXMap SVMXMapInvoice = new SVMXC.INTF_WebservicesDef.SVMXMap();
                for(SVMXC__Service_Order__c WO : lstWOs)
                {
                    if(mapWOIdInvoiceObjects.containsKey(WO.Id))
                    {
                        SVMXMapInvoice = mapWOIdInvoiceObjects.get(WO.Id);
                        SVMXC.INTF_WebservicesDef.SVMXMap SVMXMapInvoiceDtl = new SVMXC.INTF_WebservicesDef.SVMXMap();
                        
                        SVMXMapInvoiceDtl.data = new List<sObject>();
                        SVMXMapInvoice.valueMap = new List<SVMXC.INTF_WebservicesDef.SVMXMap>();
                        if(mapInvoiceObjectDetails.containsKey(WO.Id))
                        {
                            SVMXMapInvoiceDtl = mapInvoiceObjectDetails.get(WO.Id);
                            if(mapWOIdToLstInvoiceLines.containsKey(WO.Id))
                                SVMXMapInvoiceDtl.data = mapWOIdToLstInvoiceLines.get(WO.Id);
                        }
                        
                        if(tempInvoiceSet.contains(SVMXMapInvoice.record))
                        {
                            if(mapInvoiceObjectDetails.containsKey(WO.Id))
                                SVMXMapInvoice.valueMap.add(SVMXMapInvoiceDtl);
                        }
                        else
                        {
                            if(mapInvoiceObjectDetails.containsKey(WO.Id))
                            {
                                List<SVMXC.INTF_WebservicesDef.SVMXMap> lstSVMXMapInvoiceDtl = new List<SVMXC.INTF_WebservicesDef.SVMXMap>();
                                lstSVMXMapInvoiceDtl.add(SVMXMapInvoiceDtl);
                                SVMXMapInvoice.valueMap = lstSVMXMapInvoiceDtl;
                            }
                            tempInvoiceSet.add(SVMXMapInvoice.record);
                            lstSVMXMapRes.add(SVMXMapInvoice);
                        }
                        //for Case
                        if(mapWOIdVCaseIds != null && mapWOIdVCaseIds.containsKey(WO.Id) && mapWOIdVCaseIds.get(WO.Id) != null && mapWOIdVCaseIds.get(WO.Id).size() > 0)
                        {
                            SVMXC.INTF_WebservicesDef.SVMXMap SVMXMapInvoiceDtl_Case = new SVMXC.INTF_WebservicesDef.SVMXMap();
                            for(string strCaseId : mapWOIdVCaseIds.get(WO.Id))
                            if(mapInvoiceObjectDetails.containsKey(strCaseId))
                            {
                                SVMXMapInvoiceDtl_Case = mapInvoiceObjectDetails.get(strCaseId);
                                if(mapCaseIdToLstInvoiceLines.containsKey(strCaseId))
                                    SVMXMapInvoiceDtl_Case.data = mapCaseIdToLstInvoiceLines.get(strCaseId);
                            }
                            
                            if(tempInvoiceSet.contains(SVMXMapInvoice.record))
                            {
                                if(mapInvoiceObjectDetails.containsKey(WO.Id))
                                    SVMXMapInvoice.valueMap.add(SVMXMapInvoiceDtl_Case);
                            }
                            else
                            {
                                if(mapInvoiceObjectDetails.containsKey(WO.Id))
                                {
                                    List<SVMXC.INTF_WebservicesDef.SVMXMap> lstSVMXMapInvoiceDtl = new List<SVMXC.INTF_WebservicesDef.SVMXMap>();
                                    lstSVMXMapInvoiceDtl.add(SVMXMapInvoiceDtl_Case);
                                    SVMXMapInvoice.valueMap = lstSVMXMapInvoiceDtl;
                                }
                                tempInvoiceSet.add(SVMXMapInvoice.record);
                                lstSVMXMapRes.add(SVMXMapInvoice);
                            }
                        }
                    }
                }
                System.debug('lstSVMXMapRes 1 : '+lstSVMXMapRes);
                System.debug('lstCases : '+lstCases);
                System.debug('mapCaseIdToInvoiceObj : '+mapCaseIdToInvoiceObj);
                tempInvoiceSet = new set<sObject>();
                for(Case objCase : lstCases)
                {
                    if(mapCaseIdToInvoiceObj.containsKey(objCase.Id))
                    {
                        SVMXMapInvoice = mapCaseIdToInvoiceObj.get(objCase.Id);
                        SVMXC.INTF_WebservicesDef.SVMXMap SVMXMapInvoiceDtl = new SVMXC.INTF_WebservicesDef.SVMXMap();
                        
                        if(mapInvoiceObjectDetails.containsKey(objCase.Id))
                        {
                            SVMXMapInvoiceDtl = mapInvoiceObjectDetails.get(objCase.Id);
                            if(mapCaseIdToLstInvoiceLines.containsKey(objCase.Id))
                                SVMXMapInvoiceDtl.data = mapCaseIdToLstInvoiceLines.get(objCase.Id);
                        }
                        
                        if(tempInvoiceSet.contains(SVMXMapInvoice.record))
                        {
                            if(mapInvoiceObjectDetails.containsKey(objCase.Id))
                                SVMXMapInvoice.valueMap.add(SVMXMapInvoiceDtl);
                        }
                        else
                        {
                            if(mapInvoiceObjectDetails.containsKey(objCase.Id))
                            {
                                List<SVMXC.INTF_WebservicesDef.SVMXMap> lstSVMXMapInvoiceDtl = new List<SVMXC.INTF_WebservicesDef.SVMXMap>();
                                lstSVMXMapInvoiceDtl.add(SVMXMapInvoiceDtl);
                                SVMXMapInvoice.valueMap = lstSVMXMapInvoiceDtl;
                            }
                            tempInvoiceSet.add(SVMXMapInvoice.record);
                            lstSVMXMapRes.add(SVMXMapInvoice);
                        }
                    }
                }
                System.debug('lstSVMXMapRes 2 : '+lstSVMXMapRes);
                res.success = true;
                res.valueMap = lstSVMXMapRes;
            }
        }
        catch(Exception ex)
        {
            res.success = false;
            res.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            res.valueMap.add(new INTF_WebServicesDef.SVMXMap('error', ex.getMessage()));
        }
        return res;
    }
    
    public List<SVMXC.INTF_WebservicesDef.SVMXMap> GenerateInvoiceDocForStep2(List<SVMXC.INTF_WebservicesDef.SVMXMap> lstSVMXMapReq)
    {
        Savepoint sp = Database.setSavepoint();
        string strLogger = '';
        string strSummary = '';
        List<SVMXC.INTF_WebservicesDef.SVMXMap> lstSVMXMapRes = new List<SVMXC.INTF_WebservicesDef.SVMXMap>();
        try
        {
            String strProcessID = '';
            List<SVMXC__Proforma_Invoice__c> lstInvoiceToGen = new List<SVMXC__Proforma_Invoice__c>();
            List<SVMXC__Proforma_Invoice_Detail__c> lstInvoiceDtlToGen = new List<SVMXC__Proforma_Invoice_Detail__c>();
            List<SVMXC__Proforma_Invoice_Line__c> lstInvoiceLinesToGen = new List<SVMXC__Proforma_Invoice_Line__c>();
            map<integer, SVMXC__Proforma_Invoice__c> mapIntToInvoice = new map<integer, SVMXC__Proforma_Invoice__c>();
            map<integer, List<SVMXC__Proforma_Invoice_Detail__c>> mapIntToInvoiceDtlLst = new map<integer, List<SVMXC__Proforma_Invoice_Detail__c>>();
            Map<String, String> mapWOIDVInvoiceID = new Map<String, String>();
            Map<String, String> mapCaseIDVInvoiceID = new Map<String, String>();
            map<string, string> mapPIIdToInvoiceName = new map<string, string>();
            Map<String, SVMXC__Proforma_Invoice_Detail__c> mapWOIDVInvoiceDtl = new Map<String, SVMXC__Proforma_Invoice_Detail__c>();
            Map<String, SVMXC__Proforma_Invoice_Detail__c> mapCaseIDVInvoiceDtl = new Map<String, SVMXC__Proforma_Invoice_Detail__c>();
            if(lstSVMXMapReq != null && lstSVMXMapReq.size() > 0)
            {
                integer i=1;
                strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Process Details';
                for(SVMXC.INTF_WebservicesDef.SVMXMap SVMXMapInvoice : lstSVMXMapReq)
                {
                    if(SVMXMapInvoice.key == 'PROCESSID')
                    {
                        strProcessID = SVMXMapInvoice.value;
                    }
                    else
                    {
                        SVMXC__Proforma_Invoice__c tempInvoice = new SVMXC__Proforma_Invoice__c();
                        tempInvoice = (SVMXC__Proforma_Invoice__c)SVMXMapInvoice.record;
                        mapIntToInvoice.put(i,tempInvoice);
                        lstInvoiceToGen.add(tempInvoice);
                        
                        
                        List<SVMXC.INTF_WebservicesDef.SVMXMap> SVMXMapInvoiceDtlLst = new List<SVMXC.INTF_WebservicesDef.SVMXMap>();
                        SVMXMapInvoiceDtlLst = SVMXMapInvoice.valueMap;
                        
                        if(SVMXMapInvoiceDtlLst != null && SVMXMapInvoiceDtlLst.size() > 0)
                        {
                            List<SVMXC__Proforma_Invoice_Detail__c> lstInvoiceDtl = new List<SVMXC__Proforma_Invoice_Detail__c>();
                            for(SVMXC.INTF_WebservicesDef.SVMXMap SVMXMapInvoiceDtl : SVMXMapInvoiceDtlLst)
                            { 
                                SVMXC__Proforma_Invoice_Detail__c tempInvoiceDtl = new SVMXC__Proforma_Invoice_Detail__c();
                                tempInvoiceDtl = (SVMXC__Proforma_Invoice_Detail__c)SVMXMapInvoiceDtl.record;
                                lstInvoiceDtlToGen.add(tempInvoiceDtl);
                                
                                List<sObject> tempInvoiceLineLst = new List<sObject>();
                                if(SVMXMapInvoiceDtl.data != null)
                                    tempInvoiceLineLst = SVMXMapInvoiceDtl.data;
                                for(sObject tempsObj : tempInvoiceLineLst)
                                {
                                    SVMXC__Proforma_Invoice_Line__c tempInvoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                                    tempInvoiceLine = (SVMXC__Proforma_Invoice_Line__c)tempsObj;
                                    lstInvoiceLinesToGen.add(tempInvoiceLine);
                                }
                                lstInvoiceDtl.add(tempInvoiceDtl);
                            }
                            mapIntToInvoiceDtlLst.put(i,lstInvoiceDtl);
                        }
                        i++;
                    }
                }
                strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Completed Process Retrieval';
                if(lstInvoiceToGen != null && lstInvoiceToGen.size() > 0)
                {
                    strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Inserting Invoice Header(s)';
                    //insert lstInvoiceToGen;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceToGen, COMM_SecurityUtils.Access.Createable)){
					    insert lstInvoiceToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
					}
					else{
					    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
					}
                    strLogger += string.valueOfgmt(system.now()) + ': ' + 'Invoice(s) generated' + ': ' + lstInvoiceToGen.size();
                    strSummary +=  getTAG007() + ': ' + lstInvoiceToGen.size();
                    
                    for(Integer intKey : mapIntToInvoice.keySet())
                    {
                        List<SVMXC__Proforma_Invoice_Detail__c> tempInvoiceDtl = new List<SVMXC__Proforma_Invoice_Detail__c>();
                        tempInvoiceDtl = mapIntToInvoiceDtlLst.get(intKey);
                        if(tempInvoiceDtl != null && tempInvoiceDtl.size() > 0)
                        {
                            string strInvoiceId = mapIntToInvoice.get(intKey).Id;
                            for(SVMXC__Proforma_Invoice_Detail__c objInvoicPD : tempInvoiceDtl)
                            {
                                objInvoicPD.SVMXC__Proforma_Invoice__c = strInvoiceId;
                                if(objInvoicPD.SVMXC__Work_Order__c != null && objInvoicPD.SVMXC__Case__c == null)
                                {   
                                    mapWOIDVInvoiceID.put(objInvoicPD.SVMXC__Work_Order__c, strInvoiceId);
                                    mapWOIDVInvoiceDtl.put(objInvoicPD.SVMXC__Work_Order__c, objInvoicPD);
                                    //mapWOIdToInvoiceName.put(objInvoicPD.SVMXC__Work_Order__c, mapIntToInvoice.get(intKey).Name);
                                }
                                else if(objInvoicPD.SVMXC__Case__c != null && objInvoicPD.SVMXC__Work_Order__c == null)
                                {
                                    mapCaseIDVInvoiceID.put(objInvoicPD.SVMXC__Case__c, strInvoiceId);
                                    mapCaseIDVInvoiceDtl.put(objInvoicPD.SVMXC__Case__c, objInvoicPD);
                                }
                            }
                        }
                    }
                    if(lstInvoiceDtlToGen != null && lstInvoiceDtlToGen.size() > 0)
                    {
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Inserting Invoice Detail(s)';
                        //insert lstInvoiceDtlToGen;
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceDtlToGen, COMM_SecurityUtils.Access.Createable)){
						    insert lstInvoiceDtlToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
						}
						else{
						    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
						}
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Invoice Detail(s) generated: ' + lstInvoiceDtlToGen.size();
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Creating Invoice Line(s)';
                        if(lstInvoiceLinesToGen != null && lstInvoiceLinesToGen.size() > 0)
                        {
                            for(SVMXC__Proforma_Invoice_Line__c objInvoiceLine : lstInvoiceLinesToGen)
                            {
                                if(objInvoiceLine.SVMXC__Work_Order__c != null && objInvoiceLine.SVMXC__Case__c == null)
                                {
                                    objInvoiceLine.SVMXC__Proforma_Invoice__c = mapWOIDVInvoiceID.get(objInvoiceLine.SVMXC__Work_Order__c);
                                    objInvoiceLine.SVMXC__Proforma_Invoice_Detail__c = mapWOIDVInvoiceDtl.get(objInvoiceLine.SVMXC__Work_Order__c).Id;
                                }
                                else if(objInvoiceLine.SVMXC__Case__c != null && objInvoiceLine.SVMXC__Work_Order__c == null)
                                {
                                    objInvoiceLine.SVMXC__Proforma_Invoice__c = mapCaseIDVInvoiceID.get(objInvoiceLine.SVMXC__Case__c);
                                    objInvoiceLine.SVMXC__Proforma_Invoice_Detail__c = mapCaseIDVInvoiceDtl.get(objInvoiceLine.SVMXC__Case__c).Id;
                                }
                            }
                            //insert lstInvoiceLinesToGen;
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceLinesToGen, COMM_SecurityUtils.Access.Createable)){
							    insert lstInvoiceLinesToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
							}
							else{
							    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
							}
                            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Invoice Line(s) generated' + ': ' + lstInvoiceLinesToGen.size();
                        }
                    }
                
                    strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Performing Source Updates';
                    List<String> lstWOIDs = new List<String>();
                    List<String> lstCaseIDs = new List<String>();
                    if(mapWOIDVInvoiceID != null)
                        lstWOIDs.addAll(mapWOIDVInvoiceID.keySet());
                    if(mapCaseIDVInvoiceID != null)
                        lstCaseIDs.addAll(mapCaseIDVInvoiceID.keySet());
                    if(lstWOIDs.size() > 0)
                        strLogger = srcUpdate(lstWOIDs, strProcessID, strLogger,'HEADER_UPD_ON_INVOICE' , false);
                    if(lstCaseIDs.size() > 0)
                        strLogger = srcUpdate(lstCaseIDs, strProcessID, strLogger,'HEADER_UPD_ON_INVOICE_CASE' , true);
                    
                    system.debug('Testing log 1 : '+lstWOIDs+' secong : '+lstCaseIDs);
                    map<string, Decimal> mapPIToPrice = new map<string, Decimal>();
                    
                    for(SVMXC__Proforma_Invoice_Detail__c pID: lstInvoiceDtlToGen)
                    {
                        if(pID.SVMXC__Total_Amount__c != null)
                        {
                            if(mapPIToPrice.containsKey(pID.SVMXC__Proforma_Invoice__c))
                                mapPIToPrice.put(pID.SVMXC__Proforma_Invoice__c, mapPIToPrice.get(pID.SVMXC__Proforma_Invoice__c)+ pID.SVMXC__Total_Amount__c);
                            else
                                mapPIToPrice.put(pID.SVMXC__Proforma_Invoice__c, pID.SVMXC__Total_Amount__c);
                        }
                    }

                    for(SVMXC__Proforma_Invoice__c pI: lstInvoiceToGen)
                    {
                        if(mapPIToPrice != null && mapPIToPrice.containsKey(pI.Id))
                            pI.SVMXC__Total_Invoice__c = mapPIToPrice.get(pI.Id);
                    }
                    //update lstInvoiceToGen;
					if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceToGen, COMM_SecurityUtils.Access.Updateable)){
						update lstInvoiceToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
					}
					else{
						Database.rollback(sp);
						lstSVMXMapRes.add(new SVMXC.INTF_WebservicesDef.SVMXMap('ERROR', System.label.COMM001_TAG142));
						return lstSVMXMapRes;
					}
                    
                    List<string> lstInvoiceIds = new List<string>();
                    for(SVMXC__Proforma_Invoice__c pI: lstInvoiceToGen)
                        lstInvoiceIds.add(pI.Id);
                    
                    List<SVMXC__Proforma_Invoice__c> lstUpdatedInvoices = [select Name from SVMXC__Proforma_Invoice__c where id IN: lstInvoiceIds];
                    
                    for(SVMXC__Proforma_Invoice__c pI: lstUpdatedInvoices)
                        mapPIIdToInvoiceName.put(pI.Id, pI.Name);
                    
                    
                    System.debug('test update for work orders  2: '+mapWOIDVInvoiceID);
                    if(lstWOIds != null && lstWOIds.size() > 0)
                    {
                        List<SVMXC__Service_Order__c> lstWOs = [select id, SVMXC__Invoice_Created__c, SVMXC__Proforma_Invoice__c, SVMXC__Invoice_Number__c from SVMXC__Service_Order__c where id IN: lstWOIds];
                        System.debug('test update for work orders : '+lstWOs);
                        for(SVMXC__Service_Order__c WO : lstWOs)
                        {
                            if(mapWOIDVInvoiceID.containsKey(WO.Id))
                            {
                                WO.SVMXC__Invoice_Created__c = true;
                                WO.SVMXC__Proforma_Invoice__c = mapWOIDVInvoiceID.get(WO.Id);
                                System.debug('test update for work orders  1: '+lstWOs);
                            }
                            if(mapPIIdToInvoiceName.containsKey(mapWOIDVInvoiceID.get(WO.Id)))
                                WO.SVMXC__Invoice_Number__c = mapPIIdToInvoiceName.get(mapWOIDVInvoiceID.get(WO.Id));
                        }
                        System.debug('test update for work orders  2: '+lstWOs);
                        if(lstWOs !=null && lstWOs.size() > 0){
							//update lstWOs;
							if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWOs, COMM_SecurityUtils.Access.Updateable)){
								update lstWOs; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
							}
							else{
								Database.rollback(sp);
								lstSVMXMapRes.add(new SVMXC.INTF_WebservicesDef.SVMXMap('ERROR', System.label.COMM001_TAG142));
								return lstSVMXMapRes;
							}
						}
                    }
                    if(lstCaseIDs != null && lstCaseIDs.size() > 0)
                    {
                        List<Case> lstCases = [select id, SVMXC__Is_Invoice_Created__c, SVMXC__Proforma_Invoice__c from Case where id IN: lstCaseIDs];
                        for(Case ObjCase : lstCases)
                        {
                            if(mapCaseIDVInvoiceID.containsKey(ObjCase.Id))
                            {
                                ObjCase.SVMXC__Is_Invoice_Created__c = true;
                                ObjCase.SVMXC__Proforma_Invoice__c = mapCaseIDVInvoiceID.get(ObjCase.Id);
                            }
                        }
                        //update lstCases;
						if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstCases, COMM_SecurityUtils.Access.Updateable)){
							update lstCases; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
						}
						else{
							Database.rollback(sp);
							lstSVMXMapRes.add(new SVMXC.INTF_WebservicesDef.SVMXMap('ERROR', System.label.COMM001_TAG142));
							return lstSVMXMapRes;
						}
                    }
                }
                lstSVMXMapRes.add(new SVMXC.INTF_WebservicesDef.SVMXMap('SUMMARY', strSummary));
                lstSVMXMapRes.add(new SVMXC.INTF_WebservicesDef.SVMXMap('LOG', strLogger));
            }
            else
            {
                lstSVMXMapRes.add(new SVMXC.INTF_WebservicesDef.SVMXMap('ERROR', getTAG018()));
                lstSVMXMapRes.add(new SVMXC.INTF_WebservicesDef.SVMXMap('SUMMARY', strSummary));
                lstSVMXMapRes.add(new SVMXC.INTF_WebservicesDef.SVMXMap('LOG', strLogger));
            }
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            lstSVMXMapRes.add(new SVMXC.INTF_WebservicesDef.SVMXMap('ERROR', ex.getMessage()));
            lstSVMXMapRes.add(new SVMXC.INTF_WebservicesDef.SVMXMap('SUMMARY', strSummary));
            lstSVMXMapRes.add(new SVMXC.INTF_WebservicesDef.SVMXMap('LOG', strLogger));
        }
        return lstSVMXMapRes;
    }
    //Method to Do the Source Updates for the given source updates for the given Process Ids this method is for Case or work order
    public string srcUpdate(List<string> lstIds, string strProcID, string strLogger, string conf_type, boolean isCase)
    {
        map<String,Schema.SObjectField> mapFldDesc = new map<String,Schema.SObjectField>();
        map<String,Schema.SObjectField> mapSchemaObject = Schema.SObjectType.Case.fields.getMap();
        if(isCase)
            mapSchemaObject = Schema.SObjectType.Case.fields.getMap();
        else
            mapSchemaObject = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
            
        APL_Utils objAPLUtils = new APL_Utils();
        
        RecordType ExpSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        System.debug(Logginglevel.WARN,'Field Map Record Type: ' + ExpSrcUpdate_Rtype);
        //Get the config data for Source Updates
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstConfigSourceUpdates = [select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: ExpSrcUpdate_Rtype.Id and SVMXC__Configuration_Type__c =: conf_type and SVMXC__Dispatch_Process__c =: strProcID Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        System.debug(Logginglevel.WARN,'List of config data Source Update are: ' + lstConfigSourceUpdates);
        if(lstConfigSourceUpdates != null && lstConfigSourceUpdates.size() > 0)
        {
            if(mapSchemaObject.size() > 0)
            {
                for(String strCurrField : mapSchemaObject.keyset())
                {
                    mapFldDesc.put(mapSchemaObject.get(strCurrField).getDescribe().getName(),mapSchemaObject.get(strCurrField));
                }
            }
            
            string strReqFields = '';
            for(SVMXC__ServiceMax_Config_Data__c objCurr : lstConfigSourceUpdates)
            {
                if(objCurr.SVMXC__Target_Field_Name__c != null)
                {
                    strReqFields += objCurr.SVMXC__Target_Field_Name__c + ', ';
                }
            }
            
            List<sObject> lstsObjectToUpdate = new List<sObject>();
            System.debug(Logginglevel.WARN,'Fields to query: ' + strReqFields);
            if(isCase)
                lstsObjectToUpdate = database.query('Select ' + strReqFields + 'Id From Case where id IN:lstIds');
            else
                lstsObjectToUpdate = database.query('Select ' + strReqFields + 'Id, SVMXC__Invoice_Created__c, SVMXC__Proforma_Invoice__c From SVMXC__Service_Order__c where id IN:lstIds');
            
            System.debug(Logginglevel.WARN,'Records queried for source updates are: ' + lstsObjectToUpdate);
            lstsObjectToUpdate = objAPLUtils.DoSourceUpdate( lstsObjectToUpdate , lstConfigSourceUpdates, mapFldDesc);
            System.debug(Logginglevel.WARN,'Records after source update util are: ' + lstsObjectToUpdate);
            //Update lstsObjectToUpdate;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstsObjectToUpdate, COMM_SecurityUtils.Access.Updateable)){
			    update lstsObjectToUpdate; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			} else {
			    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
			}
            System.debug(Logginglevel.WARN,'List of Records Updated: ' + lstsObjectToUpdate + ' and the size is: ' + lstsObjectToUpdate.size());
            
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Record(s) updated' + ': ' + lstsObjectToUpdate.size();
        }
            
        return strLogger;
    }
    
    //Method to send the Email notifications for the Process
    public void statusEmail(string processName, String strSummary, String strLogger, String emailID, boolean isAttachLog)
    {
        Messaging.SingleEmailMessage objMailShpMessage = new Messaging.SingleEmailMessage();
        objMailShpMessage.setToAddresses(new String[] {emailID});
        objMailShpMessage.setSenderDisplayName(getTAG015());
        objMailShpMessage.setSubject(getTAG015() + ': ' + getTAG016()); 
        objMailShpMessage.setBccSender(false);
        objMailShpMessage.setUseSignature(false);
        objMailShpMessage.setPlainTextBody(strSummary);
        if(isAttachLog)
        {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('Attachment');
            efa.setBody(Blob.valueof(strLogger));
            objMailShpMessage.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        }
        
        if( ! Test.isRunningTest() ) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMailShpMessage });       
        }
    }
    
    //Getter methods for the Custom Labels
    public string getTAG001(){return '' + system.label.PINV001_TAG001 + '\n ';} //'has completed with the following results:'
    public string getTAG004(){return system.label.PINV001_TAG002 + ' ';} //'Invoice Process'
    public string getTAG005(){return '\n ' + system.label.COMM001_TAG091;} //'Status: '
    public string getTAG006(){return '\n ' + system.label.PINV001_TAG003;} //'Number of Qualified Work Orders: '
    public string getTAG007(){return '\n ' + system.label.PINV001_TAG004 + ' ';} //'Invoice Generated'
    public string getTAG008(){return '\n ' + system.label.COMM001_TAG092;} //'See attached log for more details.'
    public string getTAG009(){return '\n ' + system.label.COMM001_TAG093 + '\n \n ';} //'NOTE: THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY TO THIS MESSAGE.'
    
    public string getTAG015(){return system.label.COMM001_TAG090;} //'ServiceMax'
    public string getTAG016(){return system.label.PINV001_TAG007;} //'ServiceMax: Invoice Process Status'
    public string getTAG018(){return system.label.PINV001_TAG005;} //'No Invoice, Invoice Details and Invoice Lines are available to generate.'
    public string getTAG034(){return system.label.COMM001_TAG096;} //'Success'
    public string getTAG035(){return system.label.COMM001_TAG097;} //'Failed'
    
    public string getTAG036(){return system.label.PINV001_TAG025;}
    public string getTAG037(){return system.label.PINV001_TAG006;}
    public string getTAG038(){return system.label.PINV001_TAG009;}//Number of Qualified Cases:
}