public with sharing class APL_InitiateReturn 
{
    //--------------------NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    //-----------------------------------
    
    public integer lstRMASize;
    public integer getlstRMASize() {return lstRMARec.size();}
    public RMAWrapper objWrap;
    public Case objCase= new Case();
    public Case getobjCase(){ return this.objCase;}
    public List<SVMXC__RMA_Shipment_Order__c> lstRMARec = new List<SVMXC__RMA_Shipment_Order__c>();
    public List<RMAWrapper> lstRMAWrap = new List<RMAWrapper>();
    public List<RMAWrapper> getlstRMAWrap(){ return this.lstRMAWrap;}
    public List<SVMXC__Case_Line__c> lstOpenCaseLines = new List<SVMXC__Case_Line__c>();
    public List<SVMXC__Case_Line__c> lstCaseLine = new List<SVMXC__Case_Line__c>();
    public List<SVMXC__RMA_Shipment_Line__c> lstRMALine = new List<SVMXC__RMA_Shipment_Line__c>();
    
    /* ***************Constructor ************************/
    public APL_InitiateReturn()
    {
        try
        {
            disablePrintRMA = false; 
            if(ApexPages.currentPage() != null && ApexPages.currentPage().getParameters() != null && ApexPages.currentPage().getParameters().get('SVMX_processId') != null)
            {
                String strProcID = ApexPages.currentPage().getParameters().get('SVMX_processId');
                String strRMATemplate = null;
                List<String> queryFields = new List<String> {'Id', 'SVMXC__APL_Print_RMA_Template__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, System.Label.COMM001_TAG142 ) );                    
                    return;
                }
                SVMXC__ServiceMax_Processes__c objProcDef = [Select Id, SVMXC__APL_Print_RMA_Template__c From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessId__c = :strProcID and Recordtype.Name='Initiate Return Process']; //SDL-SVMX-READ-FLS-ENFORCED
                strRMATemplate = objProcDef.SVMXC__APL_Print_RMA_Template__c;
                System.debug('Template :' + strRMATemplate);
                if(objProcDef == null || strRMATemplate == null || strRMATemplate.length() == 0)
                {
                    System.debug('Template1 :' + strRMATemplate);
                    // Hide the Print RMA Button
                    disablePrintRMA = true;         
                }
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage(),''));
        }        
    }
    
    /* *************** Method to Go Back to the Case ************************/
    public PageReference APL_GoBack()
    {
        string strCaseId;
        
        if(ApexPages.currentPage().getParameters().get('SVMX_recordId') != null)
            strCaseId = ApexPages.currentPage().getParameters().get('SVMX_recordId');
            
        PageReference pagRef = new PageReference('/' + strCaseId);
        
        return pagRef;
    }
    
    /* *************** Method to print selected RMa(s) ************************/
    public PageReference APL_PrintRMA()
    {
        String strProcID = ApexPages.currentPage().getParameters().get('SVMX_processId');
        String strRMATemplate = null;
        try
        {
            if( strProcID != null)
            {
                List<String> queryFields = new List<String> {'Id', 'SVMXC__APL_Print_RMA_Template__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, System.Label.COMM001_TAG142 ) );                    
                    return null;
                }
                SVMXC__ServiceMax_Processes__c objProcDef = [Select Id, SVMXC__APL_Print_RMA_Template__c From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessId__c = :strProcID and Recordtype.Name='Initiate Return Process']; //SDL-SVMX-READ-FLS-ENFORCED
                strRMATemplate = objProcDef.SVMXC__APL_Print_RMA_Template__c;
                if(objProcDef != null && strRMATemplate != null && strRMATemplate.length() > 0)
                {
                    String qryString = '';
                    if(lstRMAWrap != null && lstRMAWrap.size() > 0)
                    {
                        for(RMAWrapper objCurr : lstRMAWrap)
                        {
                            if(objCurr.getSel())
                            {
                                if(qryString.length() > 0) qryString += ';'; 
                                qryString += objCurr.objRMA.Id;
                            }
                        }
                    }
                    if(qryString.length() <= 0)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG013(),''));
                        return null;
                        // Create a tag and say not selected. and return null
                    }
                    PageReference ReturnPage = new PageReference('/apex/' + strRMATemplate + '?RecordId=' + qryString);
                    ReturnPage.setRedirect(true);
                    return ReturnPage;                  
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG014(),''));
                    //Create a tag and say not configured.
                }    
            }
            return null;    
        }catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG012(),''));
            return null;
        }        
    }
    public Boolean disablePrintRMA{ get; set;}
    public void APL_InitiateReturnAction()
    {
        try
        {
            string strCaseId = null; 
            string strCaseLineIds = '';
            string strPORDIds = '';
            string strRMAIDs = '';
            strRMAIDs = ApexPages.currentPage().getParameters().get('RMAIds');
            List<String> lstRMAIDs = new List<String>();
            if(strRMAIDs != null && strRMAIDs.length() > 0) 
            {
                lstRMAIDs = strRMAIDs.split(',');   
            }
            
            
            if(ApexPages.currentPage().getParameters().get('SVMX_recordId') != null)
            {
                if(ApexPages.currentPage().getParameters().get('SVMX_recordId') != null)
                    strCaseId = ApexPages.currentPage().getParameters().get('SVMX_recordId'); 
                
                if(strCaseId != null && strCaseId.length() > 0) 
                {
                    List<String> queryFields = new List<String> {'Id', 'Account.Name', 'Account.ShippingCountry', 'Account.ShippingPostalCode', 'Account.ShippingState', 'Account.ShippingCity', 'Account.ShippingStreet', 'CaseNumber'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Case', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, System.Label.COMM001_TAG142 ) );                    
                        return;
                    }
                    objCase = [Select Id, Account.Name, Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingCity, Account.ShippingStreet, CaseNumber From Case where Id =: strCaseId]; //SDL-SVMX-READ-FLS-ENFORCED
                    
                    queryFields = new List<String> {'SVMXC__Case__c', 'SVMXC__Product__c'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Case_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, System.Label.COMM001_TAG142 ) );                    
                        return;
                    }
                    lstCaseLine = [Select SVMXC__Case__c, SVMXC__Product__c  From SVMXC__Case_Line__c where SVMXC__Case__c =:  strCaseID]; //SDL-SVMX-READ-FLS-ENFORCED
                    system.debug('CaseLine Records:'+lstCaseLine);
                    for(SVMXC__Case_Line__c objTemp : lstCaseLine)
                    {
                        if(strCaseLineIds.length() > 0)
                            strCaseLineIds += ',';
                        strCaseLineIds = objTemp.Id;
                    }
                    queryFields = new List<String> {'SVMXC__RMA_Shipment_Order__c', 'SVMXC__Case_Line__c', 'Id'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, System.Label.COMM001_TAG142 ) );                    
                        return;
                    }
                    lstRMALine = [Select SVMXC__RMA_Shipment_Order__c, SVMXC__Case_Line__c, Id From SVMXC__RMA_Shipment_Line__c where SVMXC__Case_Line__r.Id =: strCaseLineIds ]; //SDL-SVMX-READ-FLS-ENFORCED
                    system.debug('lstRMALine Records:'+lstRMALine);
                    set<Id> setAllRMARecs = new Set<Id>();
                    for(SVMXC__RMA_Shipment_Line__c objTemp : lstRMALine)
                    {
                        setAllRMARecs.add(objTemp.SVMXC__RMA_Shipment_Order__c);
                    }
                    
                    queryFields = new List<String> {'SVMXC__Number_of_units_returned__c', 'SVMXC__Destination_Location__c', 'SVMXC__Destination_Location__r.Name', 'SVMXC__Case__c', 'Name'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, System.Label.COMM001_TAG142 ) );                    
                        return;
                    }
                    
                    lstRMARec = [Select SVMXC__Number_of_units_returned__c, SVMXC__Destination_Location__c, SVMXC__Destination_Location__r.Name, SVMXC__Case__c, Name From SVMXC__RMA_Shipment_Order__c where ID IN :lstRMAIDs];//setAllRMARecs AND SVMXC__Case__c =: strCaseId AND SVMXC__Destination_Location__c != null]; //SDL-SVMX-READ-FLS-ENFORCED
                    system.debug('RMA Records:'+lstRMARec);
                }
                
                
                if(lstRMARec != null && lstRMARec.size() > 0)   
                {
                    for(SVMXC__RMA_Shipment_Order__c objRMA: lstRMARec)
                    {
                        objWrap = new RMAWrapper();
                        objWrap.Sel = false;
                        objWrap.objRMA = objRMA;
                        //objWrap.IntProdCount = objRMA;  Query for PO Line....
                        lstRMAWrap.add(objWrap);
                    }               
                }else
                {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.Label.APL001_TAG009 , ''));
                }
            }
        }catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage(),''));
        }
    }
    
    /***************** Wrapper calss to deisplay List of RMA(s). *********************/
    public class RMAWrapper
    {
        /********* All getter setter of wrapper class ***********/
        public boolean Sel = false;
        public boolean getSel(){return Sel;}
        public void setSel(boolean i){this.Sel = i;}
        
        public SVMXC__RMA_Shipment_Order__c objRMA = new SVMXC__RMA_Shipment_Order__c();
        public SVMXC__RMA_Shipment_Order__c getobjRMA(){return this.objRMA;}
        public void setobjRMA(SVMXC__RMA_Shipment_Order__c objRMA){this.objRMA = objRMA;}
        
        public integer IntProdCount;
        public integer getIntProdCount() { return this.IntProdCount;}
        public void setIntProdCount(integer count){this.IntProdCount = count;}
                        
        /*********** Constructor ******************/
        public RMAWrapper() {}
        public RMAWrapper(boolean Sel, SVMXC__RMA_Shipment_Order__c objRMA, integer IntProdCount )
        {
            this.Sel = Sel;
            this.objRMA = objRMA;
            this.IntProdCount = IntProdCount;
        }
    }
    /***************** tags method ******************/
    
    public String getTAG001()
    {
        return (objCase.CaseNumber != null && objCase.CaseNumber != '') ? System.Label.APL001_TAG001 + ': ' + objCase.CaseNumber : System.Label.APL001_TAG001;
    } // 'RMA(s) Created For Case: 
    public String getTAG002(){return System.Label.APL001_TAG002;} //'Customer:'
    public String getTAG003(){return System.Label.APL001_TAG003;} //'From Location:'
    public String getTAG004(){return System.Label.APL001_TAG004;} //'RMA Number'
    public String getTAG005(){return System.Label.APL001_TAG005;} //'To Location'
    public String getTAG006(){return System.Label.APL001_TAG006;} //'Number of units returned'
    public String getTAG007(){return System.Label.APL001_TAG007;} //'No RMA was created because neither the Case nor any Case Lines match the RMA criteria'
    public String getTAG008(){return System.Label.APL001_TAG008;} //'Print RMA'
    public String getTAG009(){return System.Label.APL001_TAG009;} //'The specified Return process was not found. Please contact your ServiceMax administrator to resolve this issue.'
    public String getTAG010(){return System.Label.APL001_TAG010;} // System.Label.APL001_TAG010
    public String getTAG011(){return System.Label.APL001_TAG023;} // System.Label.APL001_TAG010
    public String getTAG012(){return System.Label.APL001_TAG019;} // 'Unable to proceed. Required number of parameters not available in the URL or the given parameters are invalid. Please contact your ServiceMax administrator to resolve this.'
    public String getTAG013(){return System.Label.APL001_TAG012;} // 'Please select one or more RMA's from the list'
    public String getTAG014(){return System.Label.APL001_TAG011;} // 'Page for printing RMA has not been configured for the Return process.'
     public string getHLPURL() {return system.label.APL001_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
    
    
    //Method to get the Initate Return Processes properties.
    public INTF_WebServicesDef.INTF_SFMResponse APL_GetIntiateReturnProc(INTF_WebServicesDef.INTF_SFMRequest procRequest)
    {
        //Perform entitlement check in the beginning based on Process-attribute
        Boolean isEntitReq, isRoutingReq;
        INTF_WebServicesDef.INTF_SFMResponse objResForInitReturnProce = new INTF_WebServicesDef.INTF_SFMResponse();
        objResForInitReturnProce.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        String strProcID = null;
        String strCaseID = null;
        try
        {
            List<INTF_WebServicesDef.SVMXMap> objProcRequest = new List<INTF_WebServicesDef.SVMXMap>();
            objProcRequest = procRequest.valueMap;
            
            for(INTF_WebServicesDef.SVMXMap objTemp : objProcRequest)
            {
                if(objTemp.key == 'CaseId')
                    strCaseID = objTemp.value;
                else if(objTemp.key == 'ProcessId')
                    strProcID = objTemp.value;
            }
            /* if(objProcRequest != null && objProcRequest.valueMap != null && objProcRequest.valueMap[0].value != null)
            {
                strProcID = objProcRequest.valueMap[0].value;                                
            }
            if(objProcRequest != null && objProcRequest.valueMap != null && objProcRequest.valueMap[1].value != null )
            {
                strCaseID = objProcRequest.valueMap[1].value;
            } */
            System.debug('Case ID: ' + strCaseID + 'Process ID: ' + strProcID);
            
            if(strCaseID != null && strProcID != null)
            {
                List<String> queryFields = new List<String> {'Id','SVMXC__Parent_Error_Msg__c','SVMXC__Child_Error_Msg__c', 'SVMXC__Node_Parent__c', 'SVMXC__Submodule__c', 'SVMXC__APL_Perform_Entitlement__c', 'SVMXC__APL_Perform_Route_Calculations__c', 'SVMXC__Process1__c', 'SVMXC__Process2__c', 'SVMXC__Consider_Location_From_Object__c', 'SVMXC__Consider_Location_From__c' };
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            
                    objResForInitReturnProce.success = false;
                    objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', System.Label.COMM001_TAG142 ));
                    return objResForInitReturnProce;
                }
                SVMXC__ServiceMax_Processes__c objProcDef = [Select Id,SVMXC__Parent_Error_Msg__c,SVMXC__Child_Error_Msg__c, SVMXC__Node_Parent__c, SVMXC__Submodule__c, SVMXC__APL_Perform_Entitlement__c, SVMXC__APL_Perform_Route_Calculations__c, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__Consider_Location_From_Object__c, SVMXC__Consider_Location_From__c From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessId__c = :strProcID and Recordtype.Name='Initiate Return Process']; //SDL-SVMX-READ-FLS-ENFORCED
                
                if(objProcDef == null) 
                {
                    objResForInitReturnProce.success = false;
                    objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', getTAG009()));
                    return objResForInitReturnProce;
                }else
                {
                    String strIsValid = APL_DoValidation(strCaseID,objProcDef.SVMXC__Node_Parent__c,true);
                    if(strIsValid != null && strIsValid.length() > 0) 
                    {
                        objResForInitReturnProce.success = false;
                        objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', objProcDef.SVMXC__Parent_Error_Msg__c ));
                        return objResForInitReturnProce;
                    }
                    strIsValid = APL_DoValidation(strCaseID,objProcDef.SVMXC__Submodule__c,false);
                    if(strIsValid != null && strIsValid.length() > 0) 
                    {
                        objResForInitReturnProce.success = false;
                        objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', objProcDef.SVMXC__Child_Error_Msg__c ));
                        return objResForInitReturnProce;
                    }
                    
                    objResForInitReturnProce.success = true;    
                    objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__APL_Perform_Entitlement__c',string.valueOf(objProcDef.SVMXC__APL_Perform_Entitlement__c)));
                    objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__APL_Perform_Route_Calculations__c',string.valueOf(objProcDef.SVMXC__APL_Perform_Route_Calculations__c)));
                    objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('HeaderMapId',string.valueOf(objProcDef.SVMXC__Process1__c)));    //added by Vasu
                    objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('ChildMapId',string.valueOf(objProcDef.SVMXC__Process2__c))); //added by Vasu
                    objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('ConsiderLocationFromObject',string.valueOf(objProcDef.SVMXC__Consider_Location_From_Object__c)));    //added by Vasu
                    objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('ConsiderLocationFrom',string.valueOf(objProcDef.SVMXC__Consider_Location_From__c))); //added by Vasu
                
                    queryFields = new List<String> {'Id', 'SVMXC__Event_Type__c','SVMXC__Class__c','SVMXC__Method__c','SVMXC__Namespace__c'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SFM_Event__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            
                        objResForInitReturnProce.success = false;
                        objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', System.Label.COMM001_TAG142 ));
                        return objResForInitReturnProce;
                    }
                    //Get the events for the SFM and place in the value map
                    List<SVMXC__SFM_Event__c> lstProEventsDef = [Select Id, SVMXC__Event_Type__c,SVMXC__Class__c,SVMXC__Method__c,SVMXC__Namespace__c From SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c = :objProcDef.Id]; //SDL-SVMX-READ-FLS-ENFORCED
                    if(lstProEventsDef != null && lstProEventsDef.Size() > 0)
                    {
                        String strNameSpace = null, strClassName = null, strMethodName = null;
                        List<String> lstEventInfo = null;
                        INTF_WebServicesDef.SVMXMap objResForResponse = null;
                        for(SVMXC__SFM_Event__c objCurrEvent : lstProEventsDef)
                        {
                            strNameSpace = objCurrEvent.SVMXC__Namespace__c;
                            strClassName = objCurrEvent.SVMXC__Class__c;
                            strMethodName = objCurrEvent.SVMXC__Method__c;
                            if(strClassName != null && strMethodName != null && strClassName.length() > 0 && strMethodName.length() > 0)
                            {
                                lstEventInfo = new List<String>();                          
                                lstEventInfo.add(strNameSpace != null && strNameSpace.length() > 0 ? strNameSpace : '-1');
                                lstEventInfo.add(strClassName);
                                lstEventInfo.add(strMethodName);
                                objResForResponse = new INTF_WebServicesDef.SVMXMap();
                                objResForResponse.key = objCurrEvent.SVMXC__Event_Type__c;
                                objResForResponse.values = lstEventInfo;                                
                                objResForInitReturnProce.valueMap.add(objResForResponse);
                            }
                        }
                    }
                }
            }else
            {
                objResForInitReturnProce.success = false;
                objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ''));
            }
            system.debug('Reponse Object: ' + objResForInitReturnProce);
        }catch(Exception ex)
        {
            objResForInitReturnProce.success = false;
            objResForInitReturnProce.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', getTAG012()));
        }
        return objResForInitReturnProce;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse APL_PerformEntitlementCheck(INTF_WebServicesDef.INTF_SFMRequest entitRequest)
    {
        String strCaseID = null, strProcID = null;
        String strWhereClause = null;
        INTF_WebServicesDef.INTF_SFMResponse objResForEntiChek = new INTF_WebServicesDef.INTF_SFMResponse();
        objResForEntiChek.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        List<INTF_WebServicesDef.SVMXMap> objEntitRequest = new List<INTF_WebServicesDef.SVMXMap>();
        objEntitRequest = entitRequest.valueMap;
        try
        {       
            for(INTF_WebServicesDef.SVMXMap objTemp : objEntitRequest)
            {
                if(objTemp.key == 'CaseId')
                    strCaseID = objTemp.value;
                else if(objTemp.key == 'ProcessId')
                    strProcID = objTemp.value;
            }
            
            List<String> queryFields = new List<String> {'Id', 'SVMXC__Node_Parent__c', 'SVMXC__Submodule__c', 'SVMXC__Module__c', 'SVMXC__Final_Exception_Process__c', 'SVMXC__APL_Perform_Entitlement__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                
                objResForEntiChek.success = false;
                objResForEntiChek.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', System.Label.COMM001_TAG142 ) );
                return objResForEntiChek;
            }
            
            //Get the process object
            SVMXC__ServiceMax_Processes__c objProcess = [select Id, SVMXC__Node_Parent__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Final_Exception_Process__c, SVMXC__APL_Perform_Entitlement__c From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessId__c = :strProcID and Recordtype.Name='Initiate Return Process']; //SDL-SVMX-READ-FLS-ENFORCED
            ID idCaseCrit = objProcess.SVMXC__Module__c;
            if(idCaseCrit != null)
            {
                queryFields = new List<String> {'Id', 'SVMXC__Parent_Object_Criteria__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        
                    objResForEntiChek.success = false;
                    objResForEntiChek.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', System.Label.COMM001_TAG142 ) );
                    return objResForEntiChek;
                }
                
                SVMXC__ServiceMax_Processes__c objCaseExpression = [Select Id, SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :idCaseCrit]; //SDL-SVMX-READ-FLS-ENFORCED
                strWhereClause = '(' + objCaseExpression.SVMXC__Parent_Object_Criteria__c + ')';
                
                ID idInitCaseCrit = objProcess.SVMXC__Node_Parent__c;
                if(idInitCaseCrit != null)
                {
                    SVMXC__ServiceMax_Processes__c objCaseExpression1 = [Select Id, SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :idInitCaseCrit]; //SDL-SVMX-READ-FLS-ENFORCED
                    string strWhereClause1 = objCaseExpression1.SVMXC__Parent_Object_Criteria__c;
                
                    strWhereClause += ' and ( ' + strWhereClause1 + ' )';
                }
            }
            System.debug('Case Where clause: ' + strWhereClause);
            Case objCaseRec = new Case();
            List<Case> lstObjCaseRec = new List<Case>(); 
            
            queryFields = new List<String> {'Id'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Case', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                
                objResForEntiChek.success = false;
                objResForEntiChek.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', System.Label.COMM001_TAG142 ) );
                return objResForEntiChek;
            }
            
            if(strWhereClause != null)
                lstObjCaseRec = database.query('Select Id From Case where Id= :strCaseID and (' +  strWhereClause + ')');
            else
                lstObjCaseRec = database.query('Select Id From Case where Id= :strCaseID');
            
            if(lstObjCaseRec != null && lstObjCaseRec.size()>0)
                objCaseRec = lstObjCaseRec[0];
            
            String strChildCriteria;
            if(objCaseRec != null)
            {
                ID idChildCrit = objProcess.SVMXC__Final_Exception_Process__c;
                if(idChildCrit != null)
                {
                    queryFields = new List<String> {'Id','SVMXC__Parent_Object_Criteria__c' };
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {                            
                        objResForEntiChek.success = false;
                        objResForEntiChek.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', System.Label.COMM001_TAG142 ) );
                        return objResForEntiChek;
                    }
                    
                    SVMXC__ServiceMax_Processes__c objChildExpression = [Select Id, SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :idChildCrit]; //SDL-SVMX-READ-FLS-ENFORCED
                    strChildCriteria = '(( ' + objChildExpression.SVMXC__Parent_Object_Criteria__c + ' )';
                    
                    ID idInitCaseLineCrit = objProcess.SVMXC__Submodule__c;
                    if(idInitCaseLineCrit != null)
                    { 
                        SVMXC__ServiceMax_Processes__c objChildExpression1 = [Select Id, SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :idInitCaseLineCrit]; //SDL-SVMX-READ-FLS-ENFORCED
                        string strWhereClause1 = objChildExpression1.SVMXC__Parent_Object_Criteria__c;
                        if(strWhereClause1 != null)
                            strChildCriteria += ' and ( ' + strWhereClause1 + ' )';
                    }
                    strChildCriteria += ')';
                }
                
                System.debug('Case line Where clause: ' + strChildCriteria);
                INTF_WebServicesDef.INTF_SFMRequest objReqForEntit = new INTF_WebServicesDef.INTF_SFMRequest();
                objReqForEntit.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                objReqForEntit.valueMap.add(new INTF_WebServicesDef.SVMXMap('CaseID',strCaseID));
                objReqForEntit.valueMap.add(new INTF_WebServicesDef.SVMXMap('ChildRecsCriteria',strChildCriteria));
                
                objResForEntiChek = new INTF_WebServicesDef.INTF_SFMResponse();
                objResForEntiChek.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                APL_Entitlement objPerEnti = new APL_Entitlement();
                objResForEntiChek = objPerEnti.APL_PerformEntitlement(objReqForEntit);
            }
        }catch(Exception ex)
        {
            objResForEntiChek.success = false;          
            objResForEntiChek.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ex.getMessage()));
        }
        system.debug(objResForEntiChek);
        return objResForEntiChek;
    }
    
    public String APL_DoValidation(String caseId, String exprId, boolean forCaseOrLine)
    {
        String strValidationMessage = '';
        if(caseId == null) 
        {
            strValidationMessage = 'Please provide the valid Information to process the Request';
            return strValidationMessage;
        }
        if (exprId != null)
        {
            strValidationMessage += ValidateRecFromExpr(caseId,exprId,forCaseOrLine) ? '' : getTAG009();
        }
        return strValidationMessage;
    }
    
      
    //SFM Validate Expression for header hardcoded for case.,
    public boolean ValidateRecFromExpr(String recId,String exprId, boolean forCaseOrLine)
    {
        String strWhereClause = null;
        if(exprId == null || exprId.length() == 0) return true;
        
        List<String> queryFields = new List<String> {'Id', 'Name', 'SVMXC__Parent_Object_Criteria__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        SVMXC__ServiceMax_Processes__c objExpression = [Select Id, Name,SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :exprId]; //SDL-SVMX-READ-FLS-ENFORCED
        strWhereClause = objExpression.SVMXC__Parent_Object_Criteria__c;
        if(forCaseOrLine)
        {
            if(strWhereClause != null && strWhereClause.length() > 0)
            {
                List<Case> lstCaseRec = new List<Case>();
                queryFields = new List<String> {'Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Case', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                lstCaseRec = database.query('Select Id From Case where Id= :recId and (' +  strWhereClause + ')');
                if(lstCaseRec != null && lstCaseRec.size() > 0) return true;
            }
        }
        else
        {
            if(strWhereClause != null && strWhereClause.length() > 0)
            {
                queryFields = new List<String> {'Id', 'SVMXC__Case__c' };
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Case_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                lstOpenCaseLines = database.query('Select Id From SVMXC__Case_Line__c where SVMXC__Case__c= :recId and (' +  strWhereClause + ')');//+ ' and SVMXC__Line_Status__c = \'Open\'');
                if(lstOpenCaseLines != null && lstOpenCaseLines.size() > 0) return true;
            }
        }
        return false;
    }
    
    //Do source updates for the header child records
    public INTF_WebServicesDef.INTF_SFMResponse DoReturnSourceUpdates(INTF_WebServicesDef.INTF_SFMRequest sourceUpdateRequest)
    {
        String strCaseID = null, strProcID = null, strHeaderUpdate = null, strChildUpdate = null;
        List<String> lstChildIds = new List<String>();
        String strWhereClause = null;
        INTF_WebServicesDef.INTF_SFMResponse objResForSouUpd = new INTF_WebServicesDef.INTF_SFMResponse();
        objResForSouUpd.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        List<INTF_WebServicesDef.SVMXMap> objSouUpdRequest = new List<INTF_WebServicesDef.SVMXMap>();
        objSouUpdRequest = sourceUpdateRequest.valueMap;
        APL_Utils objAPLUtils = new APL_Utils();
        Map<String,Schema.SObjectField> mapCaseFldDesc = new Map<String,Schema.SObjectField>();
        Map<String,Schema.SObjectField> mapCaseLinesFldDesc = new Map<String,Schema.SObjectField>();
        try
        {
            for(INTF_WebServicesDef.SVMXMap objTemp : objSouUpdRequest)
            {
                if(objTemp.key == 'CaseId')
                    strCaseID = objTemp.value;
                else if(objTemp.key == 'ProcessId')
                    strProcID = objTemp.value;
                else if(objTemp.key == 'HeaderUpdate')
                    strHeaderUpdate = objTemp.value;
                else if(objTemp.key == 'ChildUpdate')
                    strChildUpdate = objTemp.value;
                else if(objTemp.key == 'ChildRecords')
                    lstChildIds = objTemp.values;                   
            }
            System.debug('Process Id' + strProcID + ' Case ID:' + strCaseID);
            //Field describe
            map<String,Schema.SObjectField> mapHeader = Schema.SObjectType.Case.fields.getMap();
            map<String,Schema.SObjectField> mapChild = Schema.SObjectType.SVMXC__Case_Line__c.fields.getMap(); 
            if(mapHeader.size() > 0)
            {
                for(String strCurrField : mapHeader.keyset())
                {
                    mapCaseFldDesc.put(mapHeader.get(strCurrField).getDescribe().getName(),mapHeader.get(strCurrField));
                }
            }
            if(mapChild.size() > 0)
            {
                for(String strCurrField : mapChild.keyset())
                {
                    mapCaseLinesFldDesc.put(mapChild.get(strCurrField).getDescribe().getName(),mapChild.get(strCurrField));
                }
            }
            
            List<String> queryFields = new List<String> { 'Id', 'SVMXC__ProcessId__c' };
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                objResForSouUpd.success = false;          
                objResForSouUpd.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', System.Label.COMM001_TAG142 ) );
                return objResForSouUpd;
            }
            
            //Now get the Process for the ProcId
            SVMXC__ServiceMax_Processes__c objProcDef = [Select Id From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessId__c = :strProcID and Recordtype.Name='Initiate Return Process']; //SDL-SVMX-READ-FLS-ENFORCED
            
            //Get the config data for header
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigHeaSourceUpdates = GetSourceUpdatesFor(strHeaderUpdate,objProcDef.id);           
            
            if(lstConfigHeaSourceUpdates != null && lstConfigHeaSourceUpdates.size() > 0)
            {
                String fields = GetSourceUpdatesFieldsFor(lstConfigHeaSourceUpdates);
                queryFields = fields.split(',');
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Case', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    
                    objResForSouUpd.success = false;          
                    objResForSouUpd.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', System.Label.COMM001_TAG142 ) );
                    return objResForSouUpd;
                }
                //Get the header records                
                List<Case> lstCase = database.query('Select ' + fields + 'Id From case where id= :strCaseID');    
                //now call the APL_Utils Do source Update
                List<Case> lstUpdatedCases = objAPLUtils.DoSourceUpdate( lstCase , lstConfigHeaSourceUpdates, mapCaseFldDesc);
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstUpdatedCases, COMM_SecurityUtils.Access.Updateable ) ) {
                    Update lstUpdatedCases; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {                    
                    objResForSouUpd.success = false;          
                    objResForSouUpd.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', System.Label.COMM001_TAG142 ) );
                    return objResForSouUpd;                    
                }
            }
            
             //Get the config data for header
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigChiSourceUpdates = GetSourceUpdatesFor(strChildUpdate, objProcDef.id);           
            if(lstConfigChiSourceUpdates != null && lstConfigChiSourceUpdates.size() > 0)
            {
                String fields = GetSourceUpdatesFieldsFor(lstConfigChiSourceUpdates);
                queryFields = fields.split(',');
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Case_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    
                    objResForSouUpd.success = false;          
                    objResForSouUpd.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', System.Label.COMM001_TAG142 ) );
                    return objResForSouUpd;
                }
                
                //Get the header records                
                List<SVMXC__Case_Line__c> lstCaseLines = database.query('Select ' + fields + 'Id From SVMXC__Case_Line__c where id= :lstChildIds');    
                //now call the APL_Utils Do source Update
                List<SVMXC__Case_Line__c> lstUpdatedCasesLines = objAPLUtils.DoSourceUpdate( lstCaseLines , lstConfigChiSourceUpdates, mapCaseLinesFldDesc);
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstUpdatedCasesLines, COMM_SecurityUtils.Access.Updateable ) ) {
                    Update lstUpdatedCasesLines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {                    
                    objResForSouUpd.success = false;          
                    objResForSouUpd.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', System.Label.COMM001_TAG142 ) );
                }               
            }
            
        }catch(Exception ex)
        {
            objResForSouUpd.success = false;          
            objResForSouUpd.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ex.getMessage()));
        }
        return objResForSouUpd; 
    }
    
    private List<SVMXC__ServiceMax_Config_Data__c> GetSourceUpdatesFor(String configType, String procId)
    {
        List<String> queryFields = new List<String> {'SVMXC__Configuration_Type__c', 'SVMXC__Target_Field_Name__c', 'SVMXC__Action__c', 'SVMXC__Display_Value__c' };
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigData = [Select SVMXC__Configuration_Type__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Configuration_Type__c = :configType and RecordType.Name = 'Field Mapping' and SVMXC__Dispatch_Process__c = :procId]; //SDL-SVMX-READ-FLS-ENFORCED
        return lstConfigData;
    }
    
    // loop through all the records and build the where clause
    private string GetSourceUpdatesFieldsFor(List<SVMXC__ServiceMax_Config_Data__c> configData)
    {
        string strReqFields = '';
        for(SVMXC__ServiceMax_Config_Data__c objCurr : configData)
        {
            if(objCurr.SVMXC__Target_Field_Name__c != null)
            {
                strReqFields += objCurr.SVMXC__Target_Field_Name__c + ', ';
            }
        }
        return strReqFields;
    }
}