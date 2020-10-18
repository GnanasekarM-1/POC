public with sharing class PINV_Utils 
{
  public SVMXC.INTF_WebServicesDef.INTF_PageData PINV_CancelInvoice(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
  {
    SVMXC.INTF_WebServicesDef.INTF_PageData responsePD = new SVMXC.INTF_WebServicesDef.INTF_PageData();
    savepoint sp = Database.setSavepoint();
        try
        {
            SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject wrpHdrTrgtRecObj = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
            List<SVMXC.INTF_WebServicesDef.INTF_Record> lstWrpObjHdrRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
            SVMXC.INTF_BuildSobjectFromKeyValue clsBuildSobjfromKeyValue = new SVMXC.INTF_BuildSobjectFromKeyValue();
            List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstWrpObjHdrTrgtRecAsKeyVal = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            String strHdrObjName = null;
            string strINVId = null;
            
            
            list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMapReq = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            lstStringMapReq =  request.stringMap;
            Boolean isNextStepURL = false;
            String strNextStepURL = '';
            
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
            
            
            responsePD.response.success = true;
            
            if(request.headerRecord != null)
                wrpHdrTrgtRecObj = request.headerRecord;
            
            if(wrpHdrTrgtRecObj.objName != null && wrpHdrTrgtRecObj.objName.length() > 0)
                strHdrObjName = wrpHdrTrgtRecObj.objName;
            
            if(wrpHdrTrgtRecObj.records != null && wrpHdrTrgtRecObj.records.size() > 0)
                lstWrpObjHdrRec = wrpHdrTrgtRecObj.records;
            
            if(lstWrpObjHdrRec != null && lstWrpObjHdrRec.size() > 0)
            {
                if(lstWrpObjHdrRec[0].targetRecordId != null && lstWrpObjHdrRec[0].targetRecordId.length() > 0)
                    strINVId = lstWrpObjHdrRec[0].targetRecordId;
                if(lstWrpObjHdrRec[0].targetRecordAsKeyValue != null && lstWrpObjHdrRec[0].targetRecordAsKeyValue.size() > 0 && strHdrObjName != null && strHdrObjName.length() > 0)
                    lstWrpObjHdrTrgtRecAsKeyVal = lstWrpObjHdrRec[0].targetRecordAsKeyValue;
            }
            
            if(strINVId != null && strINVId.length() > 0)
      {
        set<string> lstWOIds = new set<string>();
        set<string> lstCaseIds = new set<string>();
        List<SVMXC__Proforma_Invoice_Detail__c> lstPInvDtl = [select SVMXC__Work_Order__c, SVMXC__Case__c from SVMXC__Proforma_Invoice_Detail__c where SVMXC__Proforma_Invoice__c =: strINVId];
        
        for(SVMXC__Proforma_Invoice_Detail__c PInvDtl : lstPInvDtl)
        {
            if(PInvDtl.SVMXC__Work_Order__c != null)
                lstWOIds.add(PInvDtl.SVMXC__Work_Order__c);
            else if(PInvDtl.SVMXC__Case__c != null)
                lstCaseIds.add(PInvDtl.SVMXC__Case__c);
        }
        
        if(lstCaseIds.contains(null))
            lstCaseIds.remove(null);
        
        if(lstWOIds.contains(null)) 
          lstWOIds.remove(null);
        
        if(lstWOIds != null && lstWOIds.size() > 0)
        {
          List<SVMXC__Service_Order__c> lstWO = [select id from SVMXC__Service_Order__c where id IN: lstWOIds AND SVMXC__Invoice_Created__c = true];
          
          if(lstWO != null && lstWO.size() > 0)
          {
            for(SVMXC__Service_Order__c WO: lstWO)
            {
              WO.SVMXC__Invoice_Number__c = null;
              WO.SVMXC__Proforma_Invoice__c = null;
              WO.SVMXC__Invoice_Created__c = false;
            }
			//update lstWO;
			if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWO, COMM_SecurityUtils.Access.Updateable)){
				update lstWO; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			}
			else{
				Database.rollback(sp);
				responsePD.response.success = false;
				responsePD.response.message = System.label.COMM001_TAG142;
				return responsePD;
			}
          }
        }
        
        // for case invoice Cancellion
        if(lstCaseIds != null && lstCaseIds.size() > 0)
        {
          List<Case> lstCase = [select id, SVMXC__Is_Invoice_Created__c, SVMXC__Proforma_Invoice__c from Case where id IN: lstCaseIds AND SVMXC__Is_Invoice_Created__c = true];
          
          if(lstCase != null && lstCase.size() > 0)
          {
            for(Case objCase: lstCase)
            {
              objCase.SVMXC__Proforma_Invoice__c = null;
              objCase.SVMXC__Is_Invoice_Created__c = false;
            }
            
            //update lstCase;
			if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstCase, COMM_SecurityUtils.Access.Updateable)){
				update lstCase; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			}
			else{
				Database.rollback(sp);
				responsePD.response.success = false;
				responsePD.response.message = System.label.COMM001_TAG142;
				return responsePD;
			}
          }
        }
        //for case invoice Cancellion complete
        
        
        Map<String,Sobject> mapAction_SCON =  clsBuildSobjfromKeyValue.BuildSobjectFromKeyValue(lstWrpObjHdrTrgtRecAsKeyVal,strHdrObjName,null,null);
              if(mapAction_SCON != null && mapAction_SCON.size() == 1)
              {
                  // Perform Service Contract cancelation field updates.
                  list<Sobject> lstProformaInvoice = new list<Sobject>();
                  lstProformaInvoice = mapAction_SCON.values();
                  if(lstProformaInvoice != null && lstProformaInvoice.size() == 1)
                  {
                    lstProformaInvoice[0].put('SVMXC__Status__c','Canceled');
                    lstProformaInvoice[0].put('SVMXC__Canceled_By__c',UserInfo.getUserId());
                    lstProformaInvoice[0].put('SVMXC__Canceled_On__c',System.now());
                    //update lstProformaInvoice;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstProformaInvoice, COMM_SecurityUtils.Access.Updateable)){
					    update lstProformaInvoice; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
					} else {
					    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
					}
                  }
                  
              }
        
        responsePD.response.message = system.label.COMM001_TAG058;
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> strMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(isNextStepURL){
            strMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO',strNextStepURL));
        }
        else{
            strMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO',strINVId));
        }
        responsePD.response.stringMap = strMap;
      }  
      return responsePD;      
        }
        catch(exception ex)
        {
          system.debug('Error : '+ex.getMessage());
            Database.rollback(sp);
            responsePD.response.success = false;
            responsePD.response.message = ex.getmessage();
            return responsePD;  
        }
  }
}