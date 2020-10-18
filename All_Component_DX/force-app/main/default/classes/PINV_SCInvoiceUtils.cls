public with sharing class PINV_SCInvoiceUtils
{
    //Method to generate Invoice from Service Contract (used by Webservice)
    public SVMXC.INTF_WebServicesDef.INTF_Response PINV_GenerateSCInvoiceDoc(SVMXC.INTF_WebServicesDef.INTF_Request req)
    {
        if(req.valueMap != null && req.valueMap.size() > 0)
        {
            SVMXC.INTF_WebServicesDef.INTF_Request reqToSend = new SVMXC.INTF_WebServicesDef.INTF_Request();
            List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringListMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
            List<SVMXC.INTF_WebservicesDef.INTF_StringMap> lstStringMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringMap>();
            for(SVMXC.INTF_WebServicesDef.SVMXMap sfw : req.valueMap)
            {
                if(sfw.key == 'SVMX_RECORDID')
                {
                    SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
                    string SCID = sfw.value;
                    strLstMap.valueList = new List<string>();
                    strLstMap.key = 'SC';
                    strLstMap.valueList.add(SCID);
                    lstStringListMapReq.add(strLstMap);
                }
                else if(sfw.key == 'PROCESSID')
                {
                    SVMXC.INTF_WebservicesDef.INTF_StringMap strMap = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
                    strMap.key = 'ProcId';
                    strMap.value = sfw.value;
                    lstStringMapReq.add(strMap);
                }
            }
            SVMXC.INTF_WebservicesDef.INTF_StringMap strMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
            strMap1.key = 'StepDetails';
            strMap1.value = 'All';
            lstStringMapReq.add(strMap1);
            
            reqToSend.stringListMap = lstStringListMapReq;
            reqToSend.stringMap = lstStringMapReq;
            return PINV_GenerateSCInvoiceDocs(reqToSend);
        }
        else
            return PINV_GenerateSCInvoiceDocs(req);
    }
     
    //Method to generate Invoice from Service Contract
    public SVMXC.INTF_WebServicesDef.INTF_Response PINV_GenerateSCInvoiceDocs(SVMXC.INTF_WebServicesDef.INTF_Request req)
    {
        Savepoint sp = Database.setSavepoint();
        string strRunDate = string.valueOfgmt(system.now());
        SVMXC.INTF_WebservicesDef.INTF_Response res = new SVMXC.INTF_WebservicesDef.INTF_Response();
        List<SVMXC__Service_Contract__c> lstSCs = new List<SVMXC__Service_Contract__c>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringListMap> stringListMap = new List<SVMXC.INTF_WebServicesDef.INTF_StringListMap>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringMap = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC__ServiceMax_Processes__c sconProcessInfo = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__Proforma_Invoice__c> lstInvoiceToGen = new List<SVMXC__Proforma_Invoice__c>(); 
        map<String, Schema.SObjectType> schemaMap = new map<String, Schema.SObjectType>(); 
        map<String,String> mapInputValues = new map<string, string>();
        INTF_ApplyMapping objApplyRMAMapping = new INTF_ApplyMapping();
        map<string,SVMXC__Proforma_Invoice__c> mapSCIdToInvoice = new map<string,SVMXC__Proforma_Invoice__c>();
        List<SVMXC__Proforma_Invoice_Detail__c> lstInvoiceDtlToGen = new List<SVMXC__Proforma_Invoice_Detail__c>();
        map<string, List<SVMXC__Proforma_Invoice_Line__c>> mapSCIdToLstInvoiceLines = new map<string, List<SVMXC__Proforma_Invoice_Line__c>>();
        List<SVMXC__Proforma_Invoice_Line__c> lstInvoiceLinesToGen = new List<SVMXC__Proforma_Invoice_Line__c>();
        Map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
            schemaMap.put(s.getDescribe().getName(),s);
        
        string strExpId = '';
        string strSummary = '';
        string strAccountId = '';
        String strProcID  = '';
        String strStepInfo = '';
        string strInvoiceMapId = '';
        string strDetailMapId = '';
        string strRule = '';
        string strRule1 ='';
        string strRule2 ='';
        string strLogger ='';
        string strNavigateTo = '';
        boolean isNonBillableLinesIncluded = false;
        boolean isCaptureLog = false;
        List<string> lstSCIds = new List<string>();
        List<string> lstQualifiedSCIds = new List<string>();
        
        system.debug('1. Request is: ' + req);
        stringListMap = req.stringListMap;
        stringMap = req.stringMap;
        
        //Extracting the Request and assigning the useful values to the variables
        for(SVMXC.INTF_WebServicesDef.INTF_StringListMap slm : stringListMap)
        {
            if(slm.key == 'ACCOUNT')
               strAccountId = slm.valueList[0];
            else if(slm.key == 'SC')
               lstSCIds.addAll(slm.valueList);
        }
                
        for(SVMXC.INTF_WebServicesDef.INTF_StringMap sm : stringMap)
        {
            if(sm.key == 'PROCID')
                strProcID = sm.value;
            if(sm.key == 'STEPDETAILS')
                strStepInfo = sm.value;
        }

        system.debug('2. Extracted Account Id: ' + strAccountId + ' Process ID: ' + strProcID + ' Step Info is: ' + strStepInfo);
        res.success = true;
        
        if(strProcID != null && strProcID.length() > 0)
        {
            //Querying the Process with the given Process ID in the Request
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Process Details';
            
            RecordType SCBilProcess_Rtype = [select Id from RecordType where Name='Contract Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            list<SVMXC__ServiceMax_Processes__c> lstSconProcess= new list<SVMXC__ServiceMax_Processes__c>();            
            lstSconProcess = [select id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Module__c, SVMXC__Node_Parent__c, SVMXC__Process__c, SVMXC__Primary_Consolidation_Rule__c, SVMXC__Secondary_Consolidation_Rule__c, SVMXC__Tertiary_Consolidation_Rule__c, SVMXC__Include_Product__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Capture_Log__c from SVMXC__ServiceMax_Processes__c where  SVMXC__Active__c = true and SVMXC__ProcessID__c = :strProcID and  RecordTypeId =: SCBilProcess_Rtype.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
             
             
            if(lstSconProcess.size()>0)
                sconProcessInfo = lstSconProcess.get(0);
            else
            {               
                res.messageType = 'INFO';
                res.message = getTAG041();
                return res;
            }
            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Completed Process Retrieval';
            
            
            
         //   system.debug('3. SCON Billing Process queried is: ' + sconProcessInfo);
            
            if(sconProcessInfo != null)
            {               
                strSummary += getTAG009() + getTAG001() + getTAG004() + ' ' + sconProcessInfo.SVMXC__ProcessID__c;
                strInvoiceMapId = sconProcessInfo.SVMXC__Node_Parent__c;
                strDetailMapId = sconProcessInfo.SVMXC__Process__c;
                isNonBillableLinesIncluded = sconProcessInfo.SVMXC__Include_Product__c;
                strRule = sconProcessInfo.SVMXC__Primary_Consolidation_Rule__c;
                strRule1 = sconProcessInfo.SVMXC__Secondary_Consolidation_Rule__c;
                strRule2 = sconProcessInfo.SVMXC__Tertiary_Consolidation_Rule__c;
                strExpId = sconProcessInfo.SVMXC__Module__c;
                isCaptureLog = sconProcessInfo.SVMXC__Capture_Log__c;
                
                //For Step 1 - Calling the method to generate the Response for the user to manipulate the Invoices, Invoice Details and Lines before commiting to insert
                if(strStepInfo == 'STEP1')
                {
                    mapInputValues.put('SVMXC__Node_Parent__c', strInvoiceMapId);
                    mapInputValues.put('SVMXC__Process__c', strDetailMapId);
                    mapInputValues.put('SVMXC__Include_Product__c', string.valueOf(isNonBillableLinesIncluded));
                    mapInputValues.put('SVMXC__Primary_Consolidation_Rule__c', strRule);
                    mapInputValues.put('SVMXC__Secondary_Consolidation_Rule__c', strRule1);
                    mapInputValues.put('SVMXC__Tertiary_Consolidation_Rule__c', strRule2);
                    mapInputValues.put('SVMXC__Module__c', strExpId);
                    
                    res = GenerateInvoiceDocForStep1(lstSCIds, mapInputValues);
                }
                else if(strStepInfo == 'STEP2')
                {
                    //For Step 2 - Calling the method to generate the Invoices, Invoice Details and Lines after the manipulation done by the User
                    req.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('ProcessID', sconProcessInfo.Id));
                    res.valueMap = GenerateInvoiceDocForStep2(req.valueMap);
                    integer errorFound = 0;
                    for(SVMXC.INTF_WebservicesDef.SVMXMap tempMap : res.valueMap)
                    {
                        if(tempMap.key == 'ERROR')
                        {
                            strSummary += getTAG005() + ': ' + getTAG035();
                            strLogger += '\n Status' + ': ' + 'Failed' + '\n Error Details' + ': ' + tempMap.value;
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
                            strSummary += getTAG008();
                        
                        if(sconProcessInfo.SVMXC__Email_On_Error__c != null && sconProcessInfo.SVMXC__Email_On_Error__c.length()>0)
                            statusEmail(sconProcessInfo.SVMXC__Name__c, strSummary, strLogger, sconProcessInfo.SVMXC__Email_On_Error__c, isCaptureLog);
                        else
                        {
                            User u = [Select Email From User where id =: UserInfo.getUserId() limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            statusEmail(sconProcessInfo.SVMXC__Name__c, strSummary, strLogger, u.Email, isCaptureLog);
                        }
                    }
                    
                    strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Process Execution Ends';
                    if(isCaptureLog == true)
                        strSummary += getTAG008();
                    
                    //Method called to send the Email notification for the Process
                    if(sconProcessInfo.SVMXC__Email_On_Success__c != null && sconProcessInfo.SVMXC__Email_On_Success__c.length() >0)
                        statusEmail(sconProcessInfo.SVMXC__Name__c, strSummary, strLogger, sconProcessInfo.SVMXC__Email_On_Success__c,isCaptureLog);
                }
                else if(strStepInfo == 'ALL')
                {
                    try
                    {
                        //For All - All the processing is done and commits the generated Invoices, Invoice Details and Lines
                        
                        //Preparing the Where Clause for querying the Service Contracts for which the Invoice is to generated
                        string strSOQLForSC = '';
                        string strWhereClause = '';
                        if(strExpId != null && strExpId.length() > 0)
                        {
                            List<SVMXC__ServiceMax_Processes__c> expProc = new List<SVMXC__ServiceMax_Processes__c>();
                            expProc = [Select Id, Name,SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id=:strExpId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            if(expProc != null && expProc.size() == 1)
                                strWhereClause = expProc[0].SVMXC__Parent_Object_Criteria__c;
                        }
                      
                        //Consolidation of Service Contracts as per the Account -- One Invoice for One Account in list of Service Contract
                        if(strRule == 'ACCOUNT')
                        {
                            //Querying the Service Contracts as per the qualification criteria defined with the Process
                            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Service Contract(s)';

                            string fieldToAdd = '';
                            if(strRule1 != null && strRule1.length() > 0)
                                fieldToAdd += strRule1 + ', ';
                            if(strRule2 != null && strRule2.length() > 0)
                                fieldToAdd += strRule2 + ', ';
                            if(UserInfo.isMultiCurrencyOrganization())
                                fieldToAdd += 'CurrencyIsoCode, ';
                            
                            strSOQLForSC = 'select id, ' + fieldToAdd + 'SVMXC__Company__c, SVMXC__Company__r.BillingStreet, SVMXC__Company__r.BillingState, SVMXC__Company__r.BillingPostalCode, SVMXC__Company__r.BillingCountry, SVMXC__Company__r.BillingCity from SVMXC__Service_Contract__c';
                            if(lstSCIds != null && lstSCIds.size() > 0)
                            {
                                if(strWhereClause != null && strWhereClause.length()>0)
                                    strSOQLForSC += ' where id IN: lstSCIds and (' + strWhereClause + ')';
                                else
                                    strSOQLForSC += ' where id IN: lstSCIds';
                            }   
                            else if(strWhereClause != null && strWhereClause.length()>0)
                                strSOQLForSC += ' where (' + strWhereClause + ')';
                  
                            system.debug('4. Query string for SC is: ' + strSOQLForSC);
                            lstSCs.clear();
                            lstQualifiedSCIds.clear();
                            if(strSOQLForSC != null && strSOQLForSC.length() >0)
                                lstSCs = database.query(strSOQLForSC);
                            
                            strSummary +=  getTAG006() + ' ' + lstSCs.size();
                            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Service Contract(s) retrieved' + ': ' + lstSCs.size() + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Start Service Contract Consolidation' + ': ' + strRule;
                            
                            if(lstSCs == null || lstSCs.size() == 0)
                            {
                                res.messageType = 'INFO';
                                res.message = getTAG040();
                                return res;
                            }
                            system.debug('5. SC queried are: ' + lstSCs);
                            //Preparing the Map to find the unique consolidations for the Service Contracts to generate Invoices
                            if(lstSCs != null && lstSCs.size() >0)
                            {
                                map<string, List<SVMXC__Service_Contract__c>> mapRulesAndLstSCs = new map<string, List<SVMXC__Service_Contract__c>>();
                                for(SVMXC__Service_Contract__c SC : lstSCs)
                                {
                                    fieldToAdd = '';
                                    if(UserInfo.isMultiCurrencyOrganization())
                                        fieldToAdd = ':' + SC.get('CurrencyIsoCode');
                                    
                                    if(SC.SVMXC__Company__c != null)
                                    {
                                        if(strRule1 != null && strRule1.length() > 0 && strRule2 != null && strRule2.length() > 0)
                                        {
                                            if(!mapRulesAndLstSCs.containsKey(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':' + SC.get(strRule2) + fieldToAdd))
                                                mapRulesAndLstSCs.put(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':' + SC.get(strRule2) + fieldToAdd, new List<SVMXC__Service_Contract__c>());
                                            mapRulesAndLstSCs.get(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':' + SC.get(strRule2) + fieldToAdd).add(SC);
                                        }
                                        else if(strRule1 != null && strRule1.length() > 0 && (strRule2 == null || strRule2.length() == 0))
                                        {
                                            if(!mapRulesAndLstSCs.containsKey(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':null' + fieldToAdd))
                                                mapRulesAndLstSCs.put(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':null' + fieldToAdd, new List<SVMXC__Service_Contract__c>());
                                            mapRulesAndLstSCs.get(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':null' + fieldToAdd).add(SC);
                                        }
                                        else if(strRule2 != null && strRule2.length() > 0 && (strRule1 == null || strRule1.length() == 0))
                                        {
                                            if(!mapRulesAndLstSCs.containsKey(SC.get('SVMXC__Company__c')+':null:' + SC.get(strRule2) + fieldToAdd))
                                                mapRulesAndLstSCs.put(SC.get('SVMXC__Company__c')+':null:' + SC.get(strRule2) + fieldToAdd, new List<SVMXC__Service_Contract__c>());
                                            mapRulesAndLstSCs.get(SC.get('SVMXC__Company__c')+':null:' + SC.get(strRule2) + fieldToAdd).add(SC);
                                        }
                                        else
                                        {
                                            if(!mapRulesAndLstSCs.containsKey(SC.get('SVMXC__Company__c')+':null:null' + fieldToAdd))
                                                mapRulesAndLstSCs.put(SC.get('SVMXC__Company__c')+':null:null' + fieldToAdd, new List<SVMXC__Service_Contract__c>());
                                            mapRulesAndLstSCs.get(SC.get('SVMXC__Company__c')+':null:null' + fieldToAdd).add(SC);
                                        }
                                    }
                                    lstQualifiedSCIds.add(SC.Id);
                                }
                                
                                //Preparing the list of Invoices to be generated as per the above calculations
                                system.debug('6. Map Prepared after consolidation is: ' + mapRulesAndLstSCs + ' and the size is: ' + mapRulesAndLstSCs.size());
                                lstInvoiceToGen.clear();
                                integer count = 1;
                                SVMXC__Proforma_Invoice__c invoiceToGen = new SVMXC__Proforma_Invoice__c();
                                lstInvoiceToGen.add(invoiceToGen);
                                
                                strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Applying Value Map to create Invoice header';
                                
                                if(strInvoiceMapId != null && strInvoiceMapId.length() > 0)
                                    lstInvoiceToGen = objApplyRMAMapping.getValueMapping(lstInvoiceToGen, strInvoiceMapId, schemaMap);
                                    
                                for(string strMapKey : mapRulesAndLstSCs.keyset())
                                {
                                    //5.Copy the billing address from the SC's Account to Invoice Billing Address for the 1st Invoice  also
                                    SVMXC__Proforma_Invoice__c newInvoiceToGen = null;
                                    if(count > 1)
                                    {
                                        newInvoiceToGen = new SVMXC__Proforma_Invoice__c(); 
                                        newInvoiceToGen = lstInvoiceToGen[0].clone(false, false, false, false);
                                        lstInvoiceToGen.add(newInvoiceToGen);
                                    }
                                    else
                                        newInvoiceToGen = lstInvoiceToGen[0];
                                        
                                    newInvoiceToGen.SVMXC__Type__c = 'Contract';
                                    newInvoiceToGen.SVMXC__Status__c = 'Open';
                                    List<SVMXC__Service_Contract__c> tempLstSC = new List<SVMXC__Service_Contract__c>();
                                    tempLstSC = mapRulesAndLstSCs.get(strMapKey);
                                    for(SVMXC__Service_Contract__c SC : tempLstSC)
                                    {
                                        if(UserInfo.isMultiCurrencyOrganization())
                                            newInvoiceToGen.put('CurrencyIsoCode', string.valueOf(SC.get('CurrencyIsoCode')));
                                        newInvoiceToGen.SVMXC__Billing_City__c = SC.SVMXC__Company__r.BillingCity ;
                                        newInvoiceToGen.SVMXC__Billing_Country__c = SC.SVMXC__Company__r.BillingCountry ;
                                        newInvoiceToGen.SVMXC__Billing_State__c = SC.SVMXC__Company__r.BillingState ;
                                        newInvoiceToGen.SVMXC__Billing_Postal_Code__c = SC.SVMXC__Company__r.BillingPostalCode ;
                                        newInvoiceToGen.SVMXC__Billing_Street__c = SC.SVMXC__Company__r.BillingStreet ;
                                        newInvoiceToGen.SVMXC__Account__c = SC.SVMXC__Company__c;
                                        mapSCIdToInvoice.put(SC.Id, newInvoiceToGen);
                                    }  
                                    count++;
                                }
                            }
                        }
                        else if(strRule == 'CONTRACT')
                        {
                            //Consolidation of Service Contracts as per the Work Order -- One Invoice for One Work Order
                            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Service Contract(s)';
                                
                            string fieldToAdd = '';
                            if(UserInfo.isMultiCurrencyOrganization())
                                fieldToAdd = 'CurrencyIsoCode, ';
                            
                            strSOQLForSC = 'select id, ' + fieldToAdd + 'SVMXC__Company__c, SVMXC__Company__r.BillingStreet, SVMXC__Company__r.BillingState, SVMXC__Company__r.BillingPostalCode, SVMXC__Company__r.BillingCountry, SVMXC__Company__r.BillingCity from SVMXC__Service_Contract__c';
                            
                            if(lstSCIds != null && lstSCIds.size() > 0)
                            {
                                if(strWhereClause != null && strWhereClause.length()>0)
                                    strSOQLForSC += ' where id IN: lstSCIds AND (' + strWhereClause + ')';
                                else
                                    strSOQLForSC += ' where id IN: lstSCIds';
                            }
                            else if(strWhereClause != null && strWhereClause.length()>0)
                               strSOQLForSC += ' where (' + strWhereClause + ')';
                               
                            system.debug('4. Query string for SC is: ' + strSOQLForSC);
                               
                            //Querying the Service Contracts as per the qualification criteria defined with the Process
                            lstSCs.clear();
                            lstQualifiedSCIds.clear();
                            if(strSOQLForSC.length() > 0)
                               lstSCs = database.query(strSOQLForSC);
                            
                            strSummary += getTAG006() + ' ' + lstSCs.size();
                            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Service Contract(s) retrieved' + ': ' + lstSCs.size() + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Start Service Contract Consolidation' + ': ' + strRule;
                            
                            if(lstSCs == null || lstSCs.size() == 0)
                            {
                                res.messageType = 'INFO';
                                res.message = getTAG040();
                                return res;
                            }
                            system.debug('5. SC queried are: ' + lstSCs);
                            
                            if(lstSCs != null && lstSCs.size() > 0)
                            {
                                //Preparing the list of Invoices to be generated as per the above calculations
                                lstInvoiceToGen.clear();
                                integer count = 1;
                                SVMXC__Proforma_Invoice__c invoiceToGen = new SVMXC__Proforma_Invoice__c();
                                lstInvoiceToGen.add(invoiceToGen);
                                
                                strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Applying Value Map to create Invoice header';
                                
                                if(strInvoiceMapId != null && strInvoiceMapId.length() > 0)
                                    lstInvoiceToGen = objApplyRMAMapping.getValueMapping(lstInvoiceToGen, strInvoiceMapId, schemaMap);
                                
                                for(SVMXC__Service_Contract__c SC : lstSCs)
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
                                        
                                    newInvoiceToGen.SVMXC__Type__c = 'Contract';
                                    newInvoiceToGen.SVMXC__Status__c = 'Open';
                                    if(UserInfo.isMultiCurrencyOrganization())
                                        newInvoiceToGen.put('CurrencyIsoCode', string.valueOf(lstSCs[0].get('CurrencyIsoCode')));
                                    newInvoiceToGen.SVMXC__Billing_City__c = SC.SVMXC__Company__r.BillingCity ;
                                    newInvoiceToGen.SVMXC__Billing_Country__c = SC.SVMXC__Company__r.BillingCountry ;
                                    newInvoiceToGen.SVMXC__Billing_State__c = SC.SVMXC__Company__r.BillingState ;
                                    newInvoiceToGen.SVMXC__Billing_Postal_Code__c = SC.SVMXC__Company__r.BillingPostalCode ;
                                    newInvoiceToGen.SVMXC__Billing_Street__c = SC.SVMXC__Company__r.BillingStreet ;
                                    newInvoiceToGen.SVMXC__Account__c = SC.SVMXC__Company__c;
                                    
                                    mapSCIdToInvoice.put(SC.Id, newInvoiceToGen);
                                    
                                    count++;
                                    lstQualifiedSCIds.add(SC.Id);
                                }
                            }
                        }
                        
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Completed Service Contract consolidation; number of Invoice(s) generated' + ': ' + lstInvoiceToGen.size() + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Inserting Invoice Header(s)';
                        
                        //Inserting the Invoices to be generated
                        If(lstInvoiceToGen!= null && lstInvoiceToGen.size()>0)
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
                        
                        strSummary += getTAG007() + ' ' + lstInvoiceToGen.size();
                        system.debug('6. Invoices Created are: ' + lstInvoiceToGen);
                           
                        //Preapring list of Invoice Details to be generated -- One Per Service Contract
                        map<string, SVMXC__Proforma_Invoice_Detail__c> mapSCIdToInvoiceDtl = new map<string, SVMXC__Proforma_Invoice_Detail__c>();
                        for(SVMXC__Service_Contract__c SC : lstSCs)
                        {
                            SVMXC__Proforma_Invoice_Detail__c invoiceDtl = new SVMXC__Proforma_Invoice_Detail__c();
                            invoiceDtl.SVMXC__Service_Contract__c = SC.Id;
                            invoiceDtl.SVMXC__Proforma_Invoice__c = (mapSCIdToInvoice.get(SC.Id)).Id;
                            if(UserInfo.isMultiCurrencyOrganization())
                                invoiceDtl.put('CurrencyIsoCode', mapSCIdToInvoice.get(SC.Id).get('CurrencyIsoCode'));
                            lstInvoiceDtlToGen.add(invoiceDtl);
                            mapSCIdToInvoiceDtl.put(SC.Id, invoiceDtl);
                        }
                        system.debug('Map of SC ID and Invoice Detail: ' + mapSCIdToInvoiceDtl + ' SC Ids are: ' + lstQualifiedSCIds + ' : : SC : : ' + lstSCs);
                        
                        //Applying Mapping and inserting the Invoice Details
                        if(lstInvoiceDtlToGen!= null && lstInvoiceDtlToGen.size()>0)
                        {
                            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Applying Field Mapping to create Invoice Details';
                            
                            if(strDetailMapId != null && strDetailMapId.length()>0)
                                lstInvoiceDtlToGen = objApplyRMAMapping.getApplyMapping1(strDetailMapId, mapSCIdToInvoiceDtl, false, schemaMap);
                            
                            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Inserting Invoice Detail(s)';
                            
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess( lstInvoiceDtlToGen, COMM_SecurityUtils.Access.Createable)){
                            	insert lstInvoiceDtlToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            }else{
                  				throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            				}
                        }
                        
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Invoice Detail(s) generated' + ': ' + lstInvoiceDtlToGen.size() + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Service Contract Product(s)';
                        
                        //Querying the SC Details             
                        List<SVMXC__Service_Contract_Products__c> lstSCProducts = new List<SVMXC__Service_Contract_Products__c>();
                        List<SVMXC__Service_Contract_Services__c> lstSCincldservices = new List<SVMXC__Service_Contract_Services__c>();
                        List<SVMXC__Service_Contract_Sites__c> lstSCSites = new List<SVMXC__Service_Contract_Sites__c>();
    
                        string strSCProd = 'select id,SVMXC__Is_Billable__c, SVMXC__Installed_Product__c, SVMXC__Product__c, SVMXC__Line_Price__c,SVMXC__Service_Contract__c from SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__c IN: lstQualifiedSCIds';
                        if(isNonBillableLinesIncluded == false)
                            strSCProd += ' AND SVMXC__Is_Billable__c = true';
                        
                        lstSCProducts = database.query(strSCProd);
                            
                        system.debug('8a. List of Service contract Details queried are: ' + lstSCProducts + ' and the size is: ' + lstSCProducts.size());
                        for(SVMXC__Service_Contract_Products__c SCDtl : lstSCProducts)
                        {
                            SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                            invoiceLine.SVMXC__Service_Contract__c = SCDtl.SVMXC__Service_Contract__c;
                            if(UserInfo.isMultiCurrencyOrganization())
                                invoiceLine.put('CurrencyIsoCode', mapSCIdToInvoice.get(SCDtl.SVMXC__Service_Contract__c).get('CurrencyIsoCode'));
                            invoiceLine.SVMXC__Line_Type__c = 'Contract Products';
                            if(SCDtl.SVMXC__Is_Billable__c == true)
                            {
                                invoiceLine.SVMXC__Price__c = SCDtl.SVMXC__Line_Price__c;
                                invoiceLine.SVMXC__Total_Line_Price__c = SCDtl.SVMXC__Line_Price__c;
                            }
                            else
                            {
                                invoiceLine.SVMXC__Price__c = 0.0;
                                invoiceLine.SVMXC__Total_Line_Price__c = 0.0;
                            }
                            invoiceLine.SVMXC__Covered_Products__c = SCDtl.Id;
                            invoiceLine.SVMXC__Proforma_Invoice__c = (mapSCIdToInvoiceDtl.get(SCDtl.SVMXC__Service_Contract__c)).SVMXC__Proforma_Invoice__c;
                            invoiceLine.SVMXC__Product__c = SCDtl.SVMXC__Product__c;
                            invoiceLine.SVMXC__Installed_Product__c = SCDtl.SVMXC__Installed_Product__c;
                            invoiceLine.SVMXC__Proforma_Invoice_Detail__c  = (mapSCIdToInvoiceDtl.get(SCDtl.SVMXC__Service_Contract__c)).Id;
                            lstInvoiceLinesToGen.add(invoiceLine);
                        }
                        
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Service Contract Product(s) retrieved' + ': ' + lstSCProducts.size();
                        
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Service Contract PM Offering(s)';
                        
                        List<SVMXC__PM_Offering__c> lstSCPMoffer = new List<SVMXC__PM_Offering__c>();
                        string strSCPMOffer = 'select id,SVMXC__Is_Billable__c, SVMXC__Line_Price__c,SVMXC__Service_Contract__c from SVMXC__PM_Offering__c where SVMXC__Service_Contract__c IN: lstQualifiedSCIds';
                        if(isNonBillableLinesIncluded == false)
                            strSCPMOffer += ' AND SVMXC__Is_Billable__c = true';
                        
                        lstSCPMoffer = database.query(strSCPMOffer);
                        system.debug('8b. List of Service Contract Details queried are: ' + lstSCPMoffer + ' and the size is: ' + lstSCPMoffer.size());
                        for(SVMXC__PM_Offering__c SCDtl : lstSCPMoffer)
                        {
                            SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                            if(UserInfo.isMultiCurrencyOrganization())
                                invoiceLine.put('CurrencyIsoCode', mapSCIdToInvoice.get(SCDtl.SVMXC__Service_Contract__c).get('CurrencyIsoCode'));
                            invoiceLine.SVMXC__Service_Contract__c = SCDtl.SVMXC__Service_Contract__c;
                            invoiceLine.SVMXC__Line_Type__c = 'PM Offering';
                            if(SCDtl.SVMXC__Is_Billable__c == true)
                            {
                                invoiceLine.SVMXC__Price__c = SCDtl.SVMXC__Line_Price__c;
                                invoiceLine.SVMXC__Total_Line_Price__c = SCDtl.SVMXC__Line_Price__c;
                            }
                            else
                            {
                                invoiceLine.SVMXC__Price__c = 0.0;
                                invoiceLine.SVMXC__Total_Line_Price__c = 0.0;
                            }
                            invoiceLine.SVMXC__PM_Offering__c = SCDtl.Id;
                            invoiceLine.SVMXC__Proforma_Invoice__c = (mapSCIdToInvoiceDtl.get(SCDtl.SVMXC__Service_Contract__c)).SVMXC__Proforma_Invoice__c;
                            invoiceLine.SVMXC__Proforma_Invoice_Detail__c  = mapSCIdToInvoiceDtl.get(SCDtl.SVMXC__Service_Contract__c).Id;
                            lstInvoiceLinesToGen.add(invoiceLine);
                        }
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Service Contract PM Offering(s) retrieved' + ': ' + lstSCPMoffer.size();
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Service Contract Service(s)';
                        
                        string strSCIncludeSer = 'select id,SVMXC__Is_Billable__c, SVMXC__Line_Price__c, SVMXC__Notes__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c IN: lstQualifiedSCIds';
                        if(isNonBillableLinesIncluded == false)
                            strSCIncludeSer += ' AND SVMXC__Is_Billable__c = true';
                        
                        lstSCincldservices = database.query(strSCIncludeSer);
                            
                        system.debug('8c. List of Service Contract Details queried are: ' + lstSCincldservices + ' and the size is: ' + lstSCincldservices.size());
                        for(SVMXC__Service_Contract_Services__c SCDtl : lstSCincldservices)
                        {
                            SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                            invoiceLine.SVMXC__Service_Contract__c = SCDtl.SVMXC__Service_Contract__c;
                            if(UserInfo.isMultiCurrencyOrganization())
                                invoiceLine.put('CurrencyIsoCode', mapSCIdToInvoice.get(SCDtl.SVMXC__Service_Contract__c).get('CurrencyIsoCode'));
                            invoiceLine.SVMXC__Line_Type__c = 'Included Services';
                            if(SCDtl.SVMXC__Is_Billable__c == true)
                            {
                                invoiceLine.SVMXC__Price__c = SCDtl.SVMXC__Line_Price__c;
                                invoiceLine.SVMXC__Total_Line_Price__c = SCDtl.SVMXC__Line_Price__c;
                            }
                            else
                            {
                                invoiceLine.SVMXC__Price__c = 0.0;
                                invoiceLine.SVMXC__Total_Line_Price__c = 0.0;
                            }
                            invoiceLine.SVMXC__Included_Services__c = SCDtl.Id;
                            invoiceLine.SVMXC__Line_Notes__c = SCDtl.SVMXC__Notes__c;
                            invoiceLine.SVMXC__Proforma_Invoice__c = (mapSCIdToInvoiceDtl.get(SCDtl.SVMXC__Service_Contract__c)).SVMXC__Proforma_Invoice__c;
                            invoiceLine.SVMXC__Proforma_Invoice_Detail__c  = mapSCIdToInvoiceDtl.get(SCDtl.SVMXC__Service_Contract__c).Id;
                            lstInvoiceLinesToGen.add(invoiceLine);
                        }  
                        
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Service Contract Service(s) retrieved' + ': ' + lstSCincldservices.size() + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Retrieving Service Contract Site(s)';
                        
                        string strSCSite = 'select id,SVMXC__Is_Billable__c, SVMXC__Line_Price__c, SVMXC__Notes__c, SVMXC__Site__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Sites__c where SVMXC__Service_Contract__c IN: lstQualifiedSCIds';
                        if(isNonBillableLinesIncluded == false)
                            strSCSite += ' AND SVMXC__Is_Billable__c = true';
                        
                        lstSCSites = database.query(strSCSite);
                        
                        system.debug('8d. List of Service Contract Details queried are: ' + lstSCSites + ' and the size is: ' + lstSCSites.size());
                        for(SVMXC__Service_Contract_Sites__c SCDtl : lstSCSites)
                        {
                            SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                            invoiceLine.SVMXC__Service_Contract__c = SCDtl.SVMXC__Service_Contract__c;
                            if(UserInfo.isMultiCurrencyOrganization())
                                invoiceLine.put('CurrencyIsoCode', mapSCIdToInvoice.get(SCDtl.SVMXC__Service_Contract__c).get('CurrencyIsoCode'));
                            invoiceLine.SVMXC__Line_Type__c = 'Covered Location';
                            if(SCDtl.SVMXC__Is_Billable__c == true)
                            {
                                invoiceLine.SVMXC__Price__c = SCDtl.SVMXC__Line_Price__c;
                                invoiceLine.SVMXC__Total_Line_Price__c = SCDtl.SVMXC__Line_Price__c;
                            }
                            else
                            {
                                invoiceLine.SVMXC__Price__c = 0.0;
                                invoiceLine.SVMXC__Total_Line_Price__c = 0.0;
                            }
                            invoiceLine.SVMXC__Covered_Locations__c = SCDtl.Id;
                            invoiceLine.SVMXC__Location__c = SCDtl.SVMXC__Site__c;
                            invoiceLine.SVMXC__Line_Notes__c = SCDtl.SVMXC__Notes__c;
                            invoiceLine.SVMXC__Proforma_Invoice_Detail__c  = mapSCIdToInvoiceDtl.get(SCDtl.SVMXC__Service_Contract__c).Id;
                            invoiceLine.SVMXC__Proforma_Invoice__c = (mapSCIdToInvoiceDtl.get(SCDtl.SVMXC__Service_Contract__c)).SVMXC__Proforma_Invoice__c;
                            lstInvoiceLinesToGen.add(invoiceLine);
                        }
                        
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Service Contract Site(s) retrieved' + ': ' + lstSCSites.size() + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Creating Invoice Line(s)';
                        
                        //Inserting all the Invoice Detail Lines to be generated
                        if(lstInvoiceLinesToGen != null && lstInvoiceLinesToGen.size() > 0){
                           //insert lstInvoiceLinesToGen;
                           if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceLinesToGen, COMM_SecurityUtils.Access.Createable)){
							    insert lstInvoiceLinesToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
							}
							else{
							    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
							}
                        }
                       
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Invoice Line(s) generated' + ': ' + lstInvoiceLinesToGen.size() + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Performing Source Updates';
                        
                        //Method called to Do the Source Updates to the Service Contracts
                        strLogger = srcUpdateForSC(lstQualifiedSCIds, sconProcessInfo.Id, strLogger);
                        
                        map<string, Decimal> mapPIDToPrice = new map<string, Decimal>();
                        map<string, Decimal> mapPIToPrice = new map<string, Decimal>();
                        for(SVMXC__Proforma_Invoice_Line__c pIL: lstInvoiceLinesToGen)
                        {
                            if(mapPIDToPrice.containsKey(pIL.SVMXC__Proforma_Invoice_Detail__c))
                            {
                                if(mapPIDToPrice.get(pIL.SVMXC__Proforma_Invoice_Detail__c) != null && pIL.SVMXC__Total_Line_Price__c != null)
                                    mapPIDToPrice.put(pIL.SVMXC__Proforma_Invoice_Detail__c, mapPIDToPrice.get(pIL.SVMXC__Proforma_Invoice_Detail__c)+pIL.SVMXC__Total_Line_Price__c);
                                else if(mapPIDToPrice.get(pIL.SVMXC__Proforma_Invoice_Detail__c) != null)
                                    mapPIDToPrice.put(pIL.SVMXC__Proforma_Invoice_Detail__c, mapPIDToPrice.get(pIL.SVMXC__Proforma_Invoice_Detail__c));
                                else if(pIL.SVMXC__Total_Line_Price__c != null)
                                    mapPIDToPrice.put(pIL.SVMXC__Proforma_Invoice_Detail__c, pIL.SVMXC__Total_Line_Price__c);
                            }
                            else
                                mapPIDToPrice.put(pIL.SVMXC__Proforma_Invoice_Detail__c, pIL.SVMXC__Total_Line_Price__c);
                        }
                        
                        for(SVMXC__Proforma_Invoice_Detail__c pID: lstInvoiceDtlToGen)
                        {
                            if(mapPIDToPrice != null && mapPIDToPrice.containsKey(pID.Id))
                                pID.SVMXC__Total_Amount__c = mapPIDToPrice.get(pID.Id);
                        }
                        
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess( lstInvoiceDtlToGen, COMM_SecurityUtils.Access.Updateable)){
                        	update lstInvoiceDtlToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }else{
                  			throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            			}   
                        
                        for(SVMXC__Proforma_Invoice_Detail__c pID: lstInvoiceDtlToGen)
                        {
                            if(mapPIToPrice.containsKey(pID.SVMXC__Proforma_Invoice__c))
                            {
                                if(pID.SVMXC__Total_Amount__c != null && mapPIToPrice.get(pID.SVMXC__Proforma_Invoice__c) != null)
                                    mapPIToPrice.put(pID.SVMXC__Proforma_Invoice__c, mapPIToPrice.get(pID.SVMXC__Proforma_Invoice__c)+ pID.SVMXC__Total_Amount__c);
                                else if(mapPIToPrice.get(pID.SVMXC__Proforma_Invoice__c) != null)
                                    mapPIToPrice.put(pID.SVMXC__Proforma_Invoice__c, mapPIToPrice.get(pID.SVMXC__Proforma_Invoice__c));
                                else if(pID.SVMXC__Total_Amount__c != null)
                                    mapPIToPrice.put(pID.SVMXC__Proforma_Invoice__c, pID.SVMXC__Total_Amount__c);
                            }
                            else
                                mapPIToPrice.put(pID.SVMXC__Proforma_Invoice__c, pID.SVMXC__Total_Amount__c);
                        }
                        
                        for(SVMXC__Proforma_Invoice__c pI: lstInvoiceToGen)
                        {
                            if(mapPIToPrice != null && mapPIToPrice.containsKey(pI.Id))
                                pI.SVMXC__Total_Invoice__c = mapPIToPrice.get(pI.Id);
                        }
                        
                        //update lstInvoiceToGen;
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceToGen, COMM_SecurityUtils.Access.Updateable)){
						    update lstInvoiceToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
						} else {
						    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
						}
                        
                        strSummary += getTAG005() + ': ' + getTAG034();
                        strLogger += '\n Status' + ': ' + 'Success' + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Process Execution Ends';
                        if(isCaptureLog == true)
                            strSummary += getTAG008();
                        
                        //Method called to send the Email notification for the Process
                        if(sconProcessInfo.SVMXC__Email_On_Success__c != null && sconProcessInfo.SVMXC__Email_On_Success__c.length() >0)
                            statusEmail(sconProcessInfo.SVMXC__Name__c, strSummary, strLogger, sconProcessInfo.SVMXC__Email_On_Success__c, isCaptureLog);  
                    }
                    catch(Exception ex)
                    {
                        Database.rollback(sp);
                        strSummary = getTAG009() + getTAG001() + getTAG004() + ' ' + sconProcessInfo.SVMXC__ProcessID__c + getTAG005() + ': ' + getTAG035();
                        strLogger += '\n Status' + ': ' + 'Failed' + '\n Error Details' + ': ' + ex.getMessage() + '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Process Execution Ends';
                        if(isCaptureLog == true)
                            strSummary += getTAG008();
                        system.debug('Exception generated is: ' + ex.getMessage());
                        //Method called to send the Email notification for the Process
                        if(sconProcessInfo.SVMXC__Email_On_Error__c != null && sconProcessInfo.SVMXC__Email_On_Error__c.length()>0)
                            statusEmail(sconProcessInfo.SVMXC__Name__c, strSummary, strLogger, sconProcessInfo.SVMXC__Email_On_Error__c, isCaptureLog);
                        else
                        {
                            User u = [Select Email From User where id =: UserInfo.getUserId() limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            statusEmail(sconProcessInfo.SVMXC__Name__c, strSummary, strLogger, u.Email, isCaptureLog);
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
        system.debug('Response generated is: ' + res);
        return res;
    }

    public SVMXC.INTF_WebservicesDef.INTF_Response GenerateInvoiceDocForStep1(List<string>lstSCIds, map<string,string> mapInputValues)
    {
        SVMXC.INTF_WebservicesDef.INTF_Response res = new SVMXC.INTF_WebservicesDef.INTF_Response();
        try
        {
            map<string,SVMXC__Proforma_Invoice__c> mapSCIdToInvoice = new map<string,SVMXC__Proforma_Invoice__c>();
            List<SVMXC__Proforma_Invoice__c> lstInvoiceToGen = new List<SVMXC__Proforma_Invoice__c>();
            map<string, SVMXC.INTF_WebservicesDef.SVMXMap> mapInvoiceObjects = new map<string, SVMXC.INTF_WebservicesDef.SVMXMap>();
            map<string, SVMXC.INTF_WebservicesDef.SVMXMap> mapInvoiceObjectDetails = new map<string, SVMXC.INTF_WebservicesDef.SVMXMap>();
            map<String, Schema.SObjectType> schemaMap = new map<String, Schema.SObjectType>();
            INTF_ApplyMapping objApplyRMAMapping = new INTF_ApplyMapping();
            List<SVMXC__Service_Contract__c> lstSCs = new List<SVMXC__Service_Contract__c>();
            List<SVMXC__Proforma_Invoice_Detail__c> lstInvoiceDtlToGen = new List<SVMXC__Proforma_Invoice_Detail__c>();
            List<SVMXC__Proforma_Invoice_Line__c> lstInvoiceLinesToGen = new List<SVMXC__Proforma_Invoice_Line__c>();
            Map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(Schema.SObjectType s : gd.values())
                schemaMap.put(s.getDescribe().getName(),s);
            
            if(mapInputValues != null && mapInputValues.size() > 0)
            {
                string strRule1 = string.valueOf(mapInputValues.get('SVMXC__Secondary_Consolidation_Rule__c'));
                string strRule2 = string.valueOf(mapInputValues.get('SVMXC__Tertiary_Consolidation_Rule__c'));
                string strInvoiceMapId = mapInputValues.get('SVMXC__Node_Parent__c');
                string strDetailMapId = mapInputValues.get('SVMXC__Process__c');
                string strExpId = mapInputValues.get('SVMXC__Module__c');
                boolean isNonBillableLinesIncluded = boolean.valueOf(mapInputValues.get('SVMXC__Include_Product__c'));
                string strSOQLForSC = '';
                string strWhereClause = '';
                List<string> lstQualifiedSCIDs = new List<string>();
                
                //Preparing the Where Clause for querying the Work Orders for which the Invoice is to generated
                if(strExpId != null && strExpId.length() > 0)
                {
                    List<SVMXC__ServiceMax_Processes__c> expProc = new List<SVMXC__ServiceMax_Processes__c>();
                    expProc = [Select Id, Name,SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id=:strExpId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(expProc != null && expProc.size() == 1)
                        strWhereClause = expProc[0].SVMXC__Parent_Object_Criteria__c;
                }
        
                //Consolidation of Service Contracts as per the Account -- One Invoice for One Account in list of Service Contracts
                if(string.valueOf(mapInputValues.get('SVMXC__Primary_Consolidation_Rule__c')) == 'ACCOUNT')
                {     
                    string fieldToAdd = '';
                    if(strRule1 != null && strRule1.length() > 0)
                        fieldToAdd += strRule1 + ', ';
                    if(strRule2 != null && strRule2.length() > 0)
                        fieldToAdd += strRule2 + ', ';
                    if(UserInfo.isMultiCurrencyOrganization())
                        fieldToAdd += 'CurrencyIsoCode, ';
                    
                    strSOQLForSC = 'select id, ' + fieldToAdd + 'SVMXC__Company__c, SVMXC__Company__r.BillingStreet, SVMXC__Company__r.BillingState, SVMXC__Company__r.BillingPostalCode, SVMXC__Company__r.BillingCountry, SVMXC__Company__r.BillingCity from SVMXC__Service_Contract__c';
                    
                    if(lstSCIds != null && lstSCIds.size() > 0)
                    {
                        if(strWhereClause != null && strWhereClause.length()>0)
                            strSOQLForSC += ' where id IN: lstSCIds and (' + strWhereClause + ')';
                        else
                            strSOQLForSC += ' where id IN: lstSCIds';
                    } 
                    else if(strWhereClause != null && strWhereClause.length()>0)
                        strSOQLForSC += ' where (' + strWhereClause + ')';
                    
                    //Querying the Service Contracts as per the qualification criteria defined with the Process
                    lstSCs.clear();
                    lstQualifiedSCIDs.clear();
                    if(strSOQLForSC != null && strSOQLForSC.length() >0)
                        lstSCs = database.query(strSOQLForSC);
                        
                    system.debug('5. SC queried are: ' + lstSCs);
                    if(lstSCs != null && lstSCs.size() >0)
                    {
                        //Preparing the Map to find the unique consolidations for the Service Contracts to generate Invoices
                        map<string, List<SVMXC__Service_Contract__c >> mapRulesAndLstSCs = new map<string, List<SVMXC__Service_Contract__c>>();
                        for(SVMXC__Service_Contract__c SC : lstSCs)
                        {
                            fieldToAdd = '';
                            if(UserInfo.isMultiCurrencyOrganization())
                                fieldToAdd = ':' + SC.get('CurrencyIsoCode');
                                    
                            if(SC.SVMXC__Company__c != null)
                            {
                                if(strRule1 != null && strRule1.length() > 0 && strRule2 != null && strRule2.length() > 0)
                                {
                                    if(!mapRulesAndLstSCs.containsKey(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':' + SC.get(strRule2) + fieldToAdd))
                                        mapRulesAndLstSCs.put(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':' + SC.get(strRule2) + fieldToAdd, new List<SVMXC__Service_Contract__c>());
                                    mapRulesAndLstSCs.get(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':' + SC.get(strRule2) + fieldToAdd).add(SC);
                                }
                                else if(strRule1 != null && strRule1.length() > 0 && (strRule2 == null || strRule2.length() == 0))
                                {
                                    if(!mapRulesAndLstSCs.containsKey(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':null' + fieldToAdd))
                                        mapRulesAndLstSCs.put(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':null' + fieldToAdd, new List<SVMXC__Service_Contract__c>());
                                    mapRulesAndLstSCs.get(SC.get('SVMXC__Company__c')+':'+ SC.get(strRule1) + ':null' + fieldToAdd).add(SC);
                                }
                                else if(strRule2 != null && strRule2.length() > 0 && (strRule1 == null || strRule1.length() == 0))
                                {
                                    if(!mapRulesAndLstSCs.containsKey(SC.get('SVMXC__Company__c')+':null:' + SC.get(strRule2) + fieldToAdd))
                                        mapRulesAndLstSCs.put(SC.get('SVMXC__Company__c')+':null:' + SC.get(strRule2) + fieldToAdd, new List<SVMXC__Service_Contract__c>());
                                    mapRulesAndLstSCs.get(SC.get('SVMXC__Company__c')+':null:' + SC.get(strRule2) + fieldToAdd).add(SC);
                                }
                                else
                                {
                                    if(mapRulesAndLstSCs.containsKey(SC.get('SVMXC__Company__c')+':null:null' + fieldToAdd))
                                        mapRulesAndLstSCs.put(SC.get('SVMXC__Company__c')+':null:null' + fieldToAdd, new List<SVMXC__Service_Contract__c>());
                                    mapRulesAndLstSCs.get(SC.get('SVMXC__Company__c')+':null:null' + fieldToAdd).add(SC);
                                }
                            }
                            lstQualifiedSCIDs.add(SC.Id);
                        }
                        
                        system.debug('6. Map Prepared is: ' + mapRulesAndLstSCs + ' and the size is: ' + mapRulesAndLstSCs.size());
                        
                        //Preparing the list of Invoices to be generated as per the above calculations
                        integer count = 1;
                        SVMXC__Proforma_Invoice__c invoiceToGen = new SVMXC__Proforma_Invoice__c();
                        lstInvoiceToGen.add(invoiceToGen);
                            
                        if(strInvoiceMapId != null && strInvoiceMapId.length() > 0)
                           lstInvoiceToGen = objApplyRMAMapping.getValueMapping(lstInvoiceToGen, strInvoiceMapId, schemaMap);
                        
                        for(string strMapKey : mapRulesAndLstSCs.keyset())
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
                            
                            newInvoiceToGen.SVMXC__Status__c = 'Open';
                            List<SVMXC__Service_Contract__c> tempLstSC = new List<SVMXC__Service_Contract__c>();
                            tempLstSC = mapRulesAndLstSCs.get(strMapKey);
                            SVMXC.INTF_WebservicesDef.SVMXMap objInvoiceObj = new SVMXC.INTF_WebservicesDef.SVMXMap();
                            objInvoiceObj.record = newInvoiceToGen;
                                              
                             for(SVMXC__Service_Contract__c SC : tempLstSC)
                            {
                                if(UserInfo.isMultiCurrencyOrganization())
                                    newInvoiceToGen.put('CurrencyIsoCode', string.valueOf(SC.get('CurrencyIsoCode')));
                                newInvoiceToGen.SVMXC__Billing_City__c = SC.SVMXC__Company__r.BillingCity ;
                                newInvoiceToGen.SVMXC__Billing_State__c = SC.SVMXC__Company__r.BillingState ;
                                newInvoiceToGen.SVMXC__Billing_Postal_Code__c = SC.SVMXC__Company__r.BillingPostalCode ;
                                newInvoiceToGen.SVMXC__Billing_Street__c = SC.SVMXC__Company__r.BillingStreet ;
                                newInvoiceToGen.SVMXC__Billing_Country__c = SC.SVMXC__Company__r.BillingCountry ;
                                newInvoiceToGen.SVMXC__Account__c = SC.SVMXC__Company__c;
                                mapSCIdToInvoice.put(SC.Id, newInvoiceToGen);
                            }   
                            count++;
                        }
                    }
                }
                else if(string.valueOf(mapInputValues.get('SVMXC__Primary_Consolidation_Rule__c')) == 'CONTRACT')
                {
                    string fieldToAdd = '';
                    if(UserInfo.isMultiCurrencyOrganization())
                        fieldToAdd += 'CurrencyIsoCode, ';
                    strSOQLForSC = 'select id, ' + fieldToAdd + 'SVMXC__Company__c, SVMXC__Company__r.BillingStreet, SVMXC__Company__r.BillingState, SVMXC__Company__r.BillingPostalCode, SVMXC__Company__r.BillingCountry, SVMXC__Company__r.BillingCity from SVMXC__Service_Contract__c';
                    
                    if(lstSCIds != null && lstSCIds.size() > 0)
                    {
                        if(strWhereClause != null && strWhereClause.length()>0)
                            strSOQLForSC += ' where id IN: lstSCIds and (' + strWhereClause + ')';
                        else
                            strSOQLForSC += ' where id IN: lstSCIds';
                    }
                    else if(strWhereClause != null && strWhereClause.length()>0)
                        strSOQLForSC += ' where (' + strWhereClause + ')';
                    
                    system.debug('4. Query string for SC is: ' + strSOQLForSC);
                    lstSCs.clear();
                    lstQualifiedSCIDs.clear();
                    if(strSOQLForSC != null && strSOQLForSC.length() >0)
                        lstSCs = database.query(strSOQLForSC);
                        
                    if(lstSCs != null && lstSCs.size() > 0)
                    {
                        //Preparing the list of Invoices to be generated as per the above calculations
                        integer count = 1;
                        SVMXC__Proforma_Invoice__c invoiceToGen = new SVMXC__Proforma_Invoice__c();
                        lstInvoiceToGen.add(invoiceToGen);
                        
                        if(strInvoiceMapId != null && strInvoiceMapId.length() > 0)
                            lstInvoiceToGen = objApplyRMAMapping.getValueMapping(lstInvoiceToGen, strInvoiceMapId, schemaMap);
                        
                        for(SVMXC__Service_Contract__c SC : lstSCs)
                        {
                            SVMXC__Proforma_Invoice__c newInvoiceToGen = null;
                            if(count > 1)
                            {
                                newInvoiceToGen = new SVMXC__Proforma_Invoice__c(); 
                                newInvoiceToGen = lstInvoiceToGen[0].clone(false, false, false, false);
                                lstInvoiceToGen.add(newInvoiceToGen);
                            }
                                newInvoiceToGen = lstInvoiceToGen[0];
                            
                            if(UserInfo.isMultiCurrencyOrganization())
                                newInvoiceToGen.put('CurrencyIsoCode', string.valueOf(SC.get('CurrencyIsoCode')));
                            newInvoiceToGen.SVMXC__Billing_City__c = SC.SVMXC__Company__r.BillingCity ;
                            newInvoiceToGen.SVMXC__Billing_Country__c = SC.SVMXC__Company__r.BillingCountry ;
                            newInvoiceToGen.SVMXC__Billing_State__c = SC.SVMXC__Company__r.BillingState ;
                            newInvoiceToGen.SVMXC__Billing_Postal_Code__c = SC.SVMXC__Company__r.BillingPostalCode ;
                            newInvoiceToGen.SVMXC__Billing_Street__c = SC.SVMXC__Company__r.BillingStreet ;
                            newInvoiceToGen.SVMXC__Account__c = SC.SVMXC__Company__c;
                            
                            mapSCIdToInvoice.put(SC.Id, newInvoiceToGen);
                            
                            SVMXC.INTF_WebservicesDef.SVMXMap objInvoiceObject = new SVMXC.INTF_WebservicesDef.SVMXMap();
                            objInvoiceObject.record = lstInvoiceToGen[0];
                            mapInvoiceObjects.put(SC.Id, objInvoiceObject);
                            
                            count++;
                            lstQualifiedSCIDs.add(SC.Id);
                        }
                    }
                }
                
                //Preapring a map of SC Id to Invoice Id to be used to generate Invoice Details
                map<string, SVMXC__Proforma_Invoice_Detail__c> mapSCIdToInvoiceDtl = new map<string, SVMXC__Proforma_Invoice_Detail__c>();
                for(SVMXC__Service_Contract__c SC : lstSCs)
                {
                    SVMXC__Proforma_Invoice_Detail__c invoiceDtl = new SVMXC__Proforma_Invoice_Detail__c();
                    invoiceDtl.SVMXC__Service_Contract__c =SC.Id;
                    lstInvoiceDtlToGen.add(invoiceDtl);
                    mapSCIdToInvoiceDtl.put(SC.Id, invoiceDtl);
                    
                    //Preapring a SVMX_map for the Invoice Details calculaed to be generated
                    SVMXC.INTF_WebservicesDef.SVMXMap objInvoiceDtlObj = new SVMXC.INTF_WebservicesDef.SVMXMap();
                    objInvoiceDtlObj.record = invoiceDtl;
                    mapInvoiceObjectDetails.put(SC.Id, objInvoiceDtlObj);
                }
                
                //Applying the Mapping for the Invoice Details
                if(strDetailMapId != null && strDetailMapId.length() > 0)
                    lstInvoiceDtlToGen = objApplyRMAMapping.getApplyMapping1(strDetailMapId, mapSCIdToInvoiceDtl, false, schemaMap);
                
                //Querying the SC Details for the qualified SC
                Map<String,list<SVMXC__Proforma_Invoice_Line__c>> mapSCIdToLstInvoiceLines = new Map<String,list<SVMXC__Proforma_Invoice_Line__c>>();
                List<SVMXC__Service_Contract_Products__c> lstSCProducts = new List<SVMXC__Service_Contract_Products__c>();
                List<SVMXC__Service_Contract_Services__c> lstSCincldservices = new List<SVMXC__Service_Contract_Services__c>();
                List<SVMXC__Service_Contract_Sites__c> lstSCSites = new List<SVMXC__Service_Contract_Sites__c>();
                
                string strSCProd = 'select id, SVMXC__Is_Billable__c, SVMXC__Line_Price__c, SVMXC__Product__c, SVMXC__Installed_Product__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__c IN: lstQualifiedSCIds';
                if(isNonBillableLinesIncluded != true)
                    strSCProd += ' AND SVMXC__Is_Billable__c = true';
                    
                lstSCProducts = database.query(strSCProd);
                    
                system.debug('8A. List of Service contract Details queried are: ' + lstSCProducts + ' and the size is: ' + lstSCProducts.size());
                for(SVMXC__Service_Contract_Products__c SCDtl : lstSCProducts)
                {
                    SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                    invoiceLine.SVMXC__Service_Contract__c = SCDtl.SVMXC__Service_Contract__c;
                    invoiceLine.SVMXC__Line_Type__c = 'Contract Products';
                    if(SCDtl.SVMXC__Is_Billable__c == true)
                    {
                        invoiceLine.SVMXC__Price__c = SCDtl.SVMXC__Line_Price__c;
                        invoiceLine.SVMXC__Total_Line_Price__c = SCDtl.SVMXC__Line_Price__c;
                    }
                    else
                    {
                        invoiceLine.SVMXC__Price__c = 0.0;
                        invoiceLine.SVMXC__Total_Line_Price__c = 0.0;
                    }
                    invoiceLine.SVMXC__Covered_Products__c = SCDtl.Id;
                    invoiceLine.SVMXC__Product__c = SCDtl.SVMXC__Product__c;
                    invoiceLine.SVMXC__Installed_Product__c = SCDtl.SVMXC__Installed_Product__c;
                    lstInvoiceLinesToGen.add(invoiceLine);
                    
                    if(mapSCIdToLstInvoiceLines.containsKey(SCDtl.SVMXC__Service_Contract__c))
                        mapSCIdToLstInvoiceLines.get(SCDtl.SVMXC__Service_Contract__c).add(invoiceLine);
                    else
                    {
                        List<SVMXC__Proforma_Invoice_Line__c> tempLstInvoiceLines = new List<SVMXC__Proforma_Invoice_Line__c>();
                        tempLstInvoiceLines.add(invoiceLine);
                        mapSCIdToLstInvoiceLines.put(SCDtl.SVMXC__Service_Contract__c, tempLstInvoiceLines);
                    }
                }   
                
                List<SVMXC__PM_Offering__c> lstSCPMoffer = new List<SVMXC__PM_Offering__c>();
                string strSCPMOffer = 'select id,SVMXC__Is_Billable__c, SVMXC__Line_Price__c,SVMXC__Service_Contract__c from SVMXC__PM_Offering__c where SVMXC__Service_Contract__c IN: lstQualifiedSCIds';            
                if(isNonBillableLinesIncluded != true)
                    strSCPMOffer += ' AND SVMXC__Is_Billable__c = true';
                
                lstSCPMoffer = database.query(strSCPMOffer);
                    
                system.debug('8B. List of Service Contract Details queried are: ' + lstSCPMoffer + ' and the size is: ' + lstSCPMoffer.size());
                for(SVMXC__PM_Offering__c SCDtl : lstSCPMoffer)
                {
                    SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                    invoiceLine.SVMXC__Service_Contract__c = SCDtl.SVMXC__Service_Contract__c;
                    invoiceLine.SVMXC__Line_Type__c = 'PM Offering';
                    if(SCDtl.SVMXC__Is_Billable__c == true)
                    {
                        invoiceLine.SVMXC__Price__c = SCDtl.SVMXC__Line_Price__c;
                        invoiceLine.SVMXC__Total_Line_Price__c = SCDtl.SVMXC__Line_Price__c;
                    }
                    else
                    {
                        invoiceLine.SVMXC__Price__c = 0.0;
                        invoiceLine.SVMXC__Total_Line_Price__c = 0.0;
                    }
                    invoiceLine.SVMXC__PM_Offering__c = SCDtl.Id;
                    lstInvoiceLinesToGen.add(invoiceLine);
                    
                    if(mapSCIdToLstInvoiceLines.containsKey(SCDtl.SVMXC__Service_Contract__c))
                        mapSCIdToLstInvoiceLines.get(SCDtl.SVMXC__Service_Contract__c).add(invoiceLine);
                    else
                    {
                        List<SVMXC__Proforma_Invoice_Line__c> tempLstInvoiceLines = new List<SVMXC__Proforma_Invoice_Line__c>();
                        tempLstInvoiceLines.add(invoiceLine);
                        mapSCIdToLstInvoiceLines.put(SCDtl.SVMXC__Service_Contract__c, tempLstInvoiceLines);
                    }
                }
                
                string strSCIncludeSer = 'select id,SVMXC__Is_Billable__c, SVMXC__Line_Price__c, SVMXC__Notes__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c IN: lstQualifiedSCIds';
                if(isNonBillableLinesIncluded != true)
                    strSCIncludeSer += ' AND SVMXC__Is_Billable__c = true';
                
                lstSCincldservices = database.query(strSCIncludeSer);
                
                system.debug('8C. List of Service Contract Details queried are: ' + lstSCincldservices + ' and the size is: ' + lstSCincldservices.size());
                for(SVMXC__Service_Contract_Services__c SCDtl : lstSCincldservices)
                {
                    SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                    invoiceLine.SVMXC__Service_Contract__c = SCDtl.SVMXC__Service_Contract__c;
                    invoiceLine.SVMXC__Line_Type__c = 'Included Services';
                    if(SCDtl.SVMXC__Is_Billable__c == true)
                    {
                        invoiceLine.SVMXC__Price__c = SCDtl.SVMXC__Line_Price__c;
                        invoiceLine.SVMXC__Total_Line_Price__c = SCDtl.SVMXC__Line_Price__c;
                    }
                    else
                    {
                        invoiceLine.SVMXC__Price__c = 0.0;
                        invoiceLine.SVMXC__Total_Line_Price__c = 0.0;
                    }
                    invoiceLine.SVMXC__Included_Services__c = SCDtl.Id;
                    invoiceLine.SVMXC__Line_Notes__c = SCDtl.SVMXC__Notes__c;
                    lstInvoiceLinesToGen.add(invoiceLine);
                    
                    if(mapSCIdToLstInvoiceLines.containsKey(SCDtl.SVMXC__Service_Contract__c))
                        mapSCIdToLstInvoiceLines.get(SCDtl.SVMXC__Service_Contract__c).add(invoiceLine);
                    else
                    {
                        List<SVMXC__Proforma_Invoice_Line__c> tempLstInvoiceLines = new List<SVMXC__Proforma_Invoice_Line__c>();
                        tempLstInvoiceLines.add(invoiceLine);
                        mapSCIdToLstInvoiceLines.put(SCDtl.SVMXC__Service_Contract__c, tempLstInvoiceLines);
                    }
                }  
                
                string strSCSites = 'select id,SVMXC__Is_Billable__c, SVMXC__Line_Price__c,SVMXC__Service_Contract__c from SVMXC__Service_Contract_Sites__c where SVMXC__Service_Contract__c IN: lstQualifiedSCIds';
                if(isNonBillableLinesIncluded != true)
                    strSCSites += ' AND SVMXC__Is_Billable__c = true';
                
                lstSCSites = database.query(strSCSites);
                    
                system.debug('8d. List of Service Contract Details queried are: ' + lstSCSites + ' and the size is: ' + lstSCSites.size());
                for(SVMXC__Service_Contract_Sites__c SCDtl : lstSCSites)
                {
                    SVMXC__Proforma_Invoice_Line__c invoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                    invoiceLine.SVMXC__Service_Contract__c = SCDtl.SVMXC__Service_Contract__c;
                    invoiceLine.SVMXC__Line_Type__c = 'Service Contract sites';
                    if(SCDtl.SVMXC__Is_Billable__c == true)
                    {
                        invoiceLine.SVMXC__Price__c = SCDtl.SVMXC__Line_Price__c;
                        invoiceLine.SVMXC__Total_Line_Price__c = SCDtl.SVMXC__Line_Price__c;
                    }
                    else
                    {
                        invoiceLine.SVMXC__Price__c = 0.0;
                        invoiceLine.SVMXC__Total_Line_Price__c = 0.0;
                    }
                    invoiceLine.SVMXC__Covered_Locations__c = SCDtl.Id;
                    invoiceLine.SVMXC__Location__c = SCDtl.SVMXC__Site__c;
                    invoiceLine.SVMXC__Line_Notes__c = SCDtl.SVMXC__Notes__c;
                    lstInvoiceLinesToGen.add(invoiceLine);
                    
                    if(mapSCIdToLstInvoiceLines.containsKey(SCDtl.SVMXC__Service_Contract__c))
                        mapSCIdToLstInvoiceLines.get(SCDtl.SVMXC__Service_Contract__c).add(invoiceLine);
                    else
                    {
                        List<SVMXC__Proforma_Invoice_Line__c> tempLstInvoiceLines = new List<SVMXC__Proforma_Invoice_Line__c>();
                        tempLstInvoiceLines.add(invoiceLine);
                        mapSCIdToLstInvoiceLines.put(SCDtl.SVMXC__Service_Contract__c, tempLstInvoiceLines);
                    }
                }
                
                //Preparing the SVMX_map for the Invoice Detail Lines for the Response
                set<sObject> tempInvoiceSet = new set<sObject>();
                SVMXC.INTF_WebservicesDef.SVMXMap SVMXMapInvoice = new SVMXC.INTF_WebservicesDef.SVMXMap();
                List<SVMXC.INTF_WebservicesDef.SVMXMap> lstSVMXMapRes = new List<SVMXC.INTF_WebservicesDef.SVMXMap>();
                for(SVMXC__Service_Contract__c SC : lstSCs)
                {
                    if(mapInvoiceObjects.containsKey(SC.Id))
                    {
                        SVMXMapInvoice = mapInvoiceObjects.get(SC.Id);
                        SVMXC.INTF_WebservicesDef.SVMXMap SVMXMapInvoiceDtl = new SVMXC.INTF_WebservicesDef.SVMXMap();
                        
                        if(mapInvoiceObjectDetails.containsKey(SC.Id))
                        {
                            SVMXMapInvoiceDtl = mapInvoiceObjectDetails.get(SC.Id);
                            if(mapSCIdToLstInvoiceLines.containsKey(SC.Id))
                                SVMXMapInvoiceDtl.data = mapSCIdToLstInvoiceLines.get(SC.Id);
                        }
                        
                        if(tempInvoiceSet.contains(SVMXMapInvoice.record))
                        {
                            if(mapInvoiceObjectDetails.containsKey(SC.Id))
                                SVMXMapInvoice.valueMap.add(SVMXMapInvoiceDtl);
                        }
                        else
                        {
                            if(mapInvoiceObjectDetails.containsKey(SC.Id))
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
            List<SVMXC__Proforma_Invoice__c> lstInvoiceToGen = new List<SVMXC__Proforma_Invoice__c>();  
            List<SVMXC__Proforma_Invoice_Detail__c> lstInvoiceDetailsObject = new List<SVMXC__Proforma_Invoice_Detail__c>();
            List<SVMXC__Proforma_Invoice_Line__c> lstInvoiceLineObject = new List<SVMXC__Proforma_Invoice_Line__c>();
            map<integer, SVMXC__Proforma_Invoice__c> mapIntToInvoice = new map<integer, SVMXC__Proforma_Invoice__c>();
            map<integer, List<SVMXC__Proforma_Invoice_Detail__c>> mapIntToInvoiceDtlLst = new map<integer, List<SVMXC__Proforma_Invoice_Detail__c>>();
            map<string, SVMXC__Proforma_Invoice_Detail__c> mapSCIdToInvoiceDtlLst = new map<string, SVMXC__Proforma_Invoice_Detail__c>();
            map<string, List<SVMXC__Proforma_Invoice_Line__c>> mapSCIdToInvoiceLines = new map<string, List<SVMXC__Proforma_Invoice_Line__c>>();
            List<string> lstSCIds = new List<string>(); 
            string strProcessID = '';
            string successEmailID = '';
            string errorEmailID = '';
            List<string> lstInvDtlIDs = new List<string>();
            
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
                        lstInvoiceToGen.add(tempInvoice);
                        mapIntToInvoice.put(i, tempInvoice);
                        
                        List<SVMXC.INTF_WebservicesDef.SVMXMap> SVMXMapInvoiceDtlLst = new List<SVMXC.INTF_WebservicesDef.SVMXMap>();
                        SVMXMapInvoiceDtlLst = SVMXMapInvoice.valueMap;
                        
                        if(SVMXMapInvoiceDtlLst != null && SVMXMapInvoiceDtlLst.size() > 0)
                        {
                            List<SVMXC__Proforma_Invoice_Detail__c> lstInvoiceDtl = new List<SVMXC__Proforma_Invoice_Detail__c>();
                            for(SVMXC.INTF_WebservicesDef.SVMXMap SVMXMapInvoiceDtl : SVMXMapInvoiceDtlLst)
                            { 
                                SVMXC__Proforma_Invoice_Detail__c tempInvoiceDtl = new SVMXC__Proforma_Invoice_Detail__c();
                                tempInvoiceDtl = (SVMXC__Proforma_Invoice_Detail__c)SVMXMapInvoiceDtl.record;
                                lstInvoiceDetailsObject.add(tempInvoiceDtl);
                                
                                List<sObject> tempInvoiceLineLst = new List<sObject>();
                                tempInvoiceLineLst = SVMXMapInvoiceDtl.data;
                                for(sObject tempsObj : tempInvoiceLineLst)
                                {
                                    SVMXC__Proforma_Invoice_Line__c tempInvoiceLine = new SVMXC__Proforma_Invoice_Line__c();
                                    tempInvoiceLine = (SVMXC__Proforma_Invoice_Line__c)tempsObj;
                                    lstInvoiceLineObject.add(tempInvoiceLine);
                                }
                                lstInvoiceDtl.add(tempInvoiceDtl);
                                mapSCIdToInvoiceDtlLst.put(tempInvoiceDtl.SVMXC__Service_Contract__c, tempInvoiceDtl);
                            }
                                mapIntToInvoiceDtlLst.put(i, lstInvoiceDtl);
                        }
                        i++;
                    }
                }
                
                strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Completed Process Retrieval';
                
                //Inserting the Invoices to be generated
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
                
                    strLogger += string.valueOfgmt(system.now()) + ': ' + 'Number of Invoice(s) created:  ' + lstInvoiceToGen.size();
                    strSummary +=  getTAG007() + ' ' + lstInvoiceToGen.size();
                    
                    for(integer j : mapIntToInvoiceDtlLst.keySet())
                    {
                        List<SVMXC__Proforma_Invoice_Detail__c> lstInvoiceDtl = new List<SVMXC__Proforma_Invoice_Detail__c>();
                        lstInvoiceDtl = mapIntToInvoiceDtlLst.get(j);
                        for(SVMXC__Proforma_Invoice_Detail__c invoiceDtl : lstInvoiceDtl)
                        {
                            invoiceDtl.SVMXC__Proforma_Invoice__c = mapIntToInvoice.get(j).Id;
                            lstSCIds.add(invoiceDtl.SVMXC__Service_Contract__c);
                        }
                    }
                    
                    if(lstInvoiceDetailsObject != null && lstInvoiceDetailsObject.size() > 0)
                    {
                        strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Inserting Invoice Detail(s)';
                        
                        //insert lstInvoiceDetailsObject;
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceDetailsObject, COMM_SecurityUtils.Access.Createable)){
						    insert lstInvoiceDetailsObject; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
						}
						else{
						    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
						}
                        
                        if(lstInvoiceDetailsObject != null && lstInvoiceDetailsObject.size() > 0)
                        {
                            for(SVMXC__Proforma_Invoice_Line__c proformaInvoiceLine : lstInvoiceLineObject)
                            {
                                proformaInvoiceLine.SVMXC__Proforma_Invoice_Detail__c = mapSCIdToInvoiceDtlLst.get(proformaInvoiceLine.SVMXC__Service_Contract__c).Id;
                                proformaInvoiceLine.SVMXC__Proforma_Invoice__c = mapSCIdToInvoiceDtlLst.get(proformaInvoiceLine.SVMXC__Service_Contract__c).SVMXC__Proforma_Invoice__c;
                            }
                            
                            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Creating Invoice Line(s)';
                            
                            //insert lstInvoiceLineObject;
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceLineObject, COMM_SecurityUtils.Access.Createable)){
							    insert lstInvoiceLineObject; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
							}
							else{
							    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
							}
                            
                            strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Invoice Line(s) generated' + ': ' + lstInvoiceLineObject.size();
                        }
                   }
                    strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Performing Source Updates';
                    
                    strLogger = srcUpdateForSC(lstSCIds, strProcessID, strLogger);
                    
                    map<string, Decimal> mapPIDToPrice = new map<string, Decimal>();
                    map<string, Decimal> mapPIToPrice = new map<string, Decimal>();
                    for(SVMXC__Proforma_Invoice_Line__c pIL: lstInvoiceLineObject)
                    {
                        if(mapPIDToPrice.containsKey(pIL.SVMXC__Proforma_Invoice_Detail__c))
                            mapPIDToPrice.put(pIL.SVMXC__Proforma_Invoice_Detail__c, mapPIDToPrice.get(pIL.SVMXC__Proforma_Invoice_Detail__c)+pIL.SVMXC__Price__c);
                        else
                            mapPIDToPrice.put(pIL.SVMXC__Proforma_Invoice_Detail__c, pIL.SVMXC__Price__c);
                    }
                    
                    for(SVMXC__Proforma_Invoice_Detail__c pID: lstInvoiceDetailsObject)
                        pID.SVMXC__Total_Amount__c = mapPIDToPrice.get(pID.Id);
                    
                    //update lstInvoiceDetailsObject;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceDetailsObject, COMM_SecurityUtils.Access.Updateable)){
					    update lstInvoiceDetailsObject; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
					} else {
					    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
					}
                    
                    for(SVMXC__Proforma_Invoice_Detail__c pID: lstInvoiceDetailsObject)
                    {
                        if(mapPIToPrice.containsKey(pID.SVMXC__Proforma_Invoice__c))
                            mapPIToPrice.put(pID.SVMXC__Proforma_Invoice__c, mapPIToPrice.get(pID.SVMXC__Proforma_Invoice__c)+ pID.SVMXC__Total_Amount__c);
                        else
                            mapPIToPrice.put(pID.SVMXC__Proforma_Invoice__c, pID.SVMXC__Total_Amount__c);
                    }
                    
                    for(SVMXC__Proforma_Invoice__c pI: lstInvoiceToGen)
                        pI.SVMXC__Total_Invoice__c = mapPIToPrice.get(pI.Id);
                    
                    //update lstInvoiceToGen;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstInvoiceToGen, COMM_SecurityUtils.Access.Updateable)){
					    update lstInvoiceToGen; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
					} else {
					    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
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
    
    //Method to Do the Source Updates for the given source updates for the given Process Ids
    public string srcUpdateForSC(List<string> lstSCIds, string strProcID, string strLogger)
    {
        map<String,Schema.SObjectField> mapSCFldDesc = new map<String,Schema.SObjectField>();
        map<String,Schema.SObjectField> mapSC = Schema.SObjectType.SVMXC__Service_Contract__c.fields.getMap();
        APL_Utils objAPLUtils = new APL_Utils();
        RecordType ExpSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        system.debug('Field Map Record Type: ' + ExpSrcUpdate_Rtype);
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstConfigSourceUpdates = [select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: ExpSrcUpdate_Rtype.Id and SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE' and SVMXC__Dispatch_Process__c =: strProcID Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        system.debug('List of config data Source Update are: ' + lstConfigSourceUpdates);
        if(lstConfigSourceUpdates != null && lstConfigSourceUpdates.size() > 0)
        {
            if(mapSC.size() > 0)
            {
                for(String strCurrField : mapSC.keyset())
                {
                    mapSCFldDesc.put(mapSC.get(strCurrField).getDescribe().getName(),mapSC.get(strCurrField));
                }
            }
            
            string strReqFields = '';
            for(SVMXC__ServiceMax_Config_Data__c objCurr : lstConfigSourceUpdates)
            {
                if(objCurr.SVMXC__Target_Field_Name__c != null)
                {
                    strReqFields += objCurr.SVMXC__Target_Field_Name__c + ',';
                }
            }
            List<SVMXC__Service_Contract__c> lstSCsToUpdate = new List<SVMXC__Service_Contract__c>();
            system.debug('Fields to query: ' + strReqFields);
            lstSCsToUpdate = database.query('Select ' + strReqFields + 'Id From SVMXC__Service_Contract__c where id IN:lstSCIds');
            
            system.debug('SCs after source update util are: ' + lstSCsToUpdate);
            if(lstSCsToUpdate!= null && lstSCsToUpdate.size()>0)
            {
                system.debug('SCs queried for source updates are: ' + lstSCsToUpdate);
                lstSCsToUpdate = objAPLUtils.DoSourceUpdate( lstSCsToUpdate , lstConfigSourceUpdates, mapSCFldDesc);
                //Update lstSCsToUpdate;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSCsToUpdate, COMM_SecurityUtils.Access.Updateable)){
				    update lstSCsToUpdate; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
				} else {
				    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
				}
                
                strLogger += '\n ' + string.valueOfgmt(system.now()) + ': ' + 'Number of Service Contract(s) updated' + ': ' + lstSCsToUpdate.size(); 
            }
            system.debug('List of SC Updated: ' + lstSCsToUpdate + ' and the size is: ' + lstSCsToUpdate.size());
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
            Messaging.EmailFileAttachment emailatt = new Messaging.EmailFileAttachment();
            emailatt.setFileName('Attachment');
            emailatt.setBody(Blob.valueof(strLogger));
            objMailShpMessage.setFileAttachments(new Messaging.EmailFileAttachment[] {emailatt});
        }
        if(!Test.isRunningTest())
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMailShpMessage });      
    }
 
    //Getter methods for the Custom Labels
    public string getTAG001(){return '' + system.label.PINV001_TAG001 + '\n ';} //'has completed with the following results:'
    public string getTAG004(){return system.label.PINV001_TAG002 + ' ';} //'Invoice Process'
    public string getTAG005(){return '\n ' + system.label.COMM001_TAG091;} //'Status: '
    public string getTAG006(){return '\n ' + system.label.PINV002_TAG001;} //'Number of Qualified Service Contracts: '
    public string getTAG007(){return '\n ' + system.label.PINV001_TAG004;} //'Invoice Generated: '
    public string getTAG008(){return '\n \n ' + system.label.PINV001_TAG008;} //'See attached log for more details.'
    public string getTAG009(){return '\n ' + system.label.COMM001_TAG093 + '\n \n ';} //'NOTE: THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY TO THIS MESSAGE.'
    public string getTAG033(){return '\n '+ 'Error Details';} //'Error details'
    
    public string getTAG015(){return system.label.COMM001_TAG090;} //'ServiceMax'
    public string getTAG016(){return system.label.PINV001_TAG007;} //'ServiceMax: Invoice Process Status'
    public string getTAG018(){return system.label.PINV001_TAG005;} //'No Invoice, Invoice Details and Invoice Lines are available to generate.'
    public string getTAG034(){return system.label.COMM001_TAG096;} //'Success'
    public string getTAG035(){return system.label.COMM001_TAG097;} //'Failed'
    
    public string getTAG040(){return system.label.PINV002_TAG013;}
    public string getTAG041(){return system.label.PINV001_TAG006;}
 }