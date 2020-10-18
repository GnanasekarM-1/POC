/* Security Scanned */
public with sharing class SFM_ExecuteAPEX 
{
    public String strClssNm{get; set;}
    public String strMethDNm{get; set;}
    public String strNmSpace{get; set;}
    public String strProcessinMsg{get; set;}
    public String strRecordId{get; set;}
    public boolean isShowMsg{get; set;}
    public String ActionTitl{get; set;}
    public String RecodNmFld{get; set;}
    public String strPrcssId;
    public String strCfgDtaRecordId;
    public String strNxtPrcssId;
    public boolean isFail1{get;set;}
    public boolean isFail2{get;set;}
    public SVMXC__ServiceMax_Processes__c objPrcss = new SVMXC__ServiceMax_Processes__c();
    public List<SVMXC__ServiceMax_Config_Data__c> lstCfgDta = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstCfgDtaSend = new List<SVMXC__ServiceMax_Config_Data__c>();
    public String strJSON{get; set;}
    public String strNxtURL{get; set;}
    public String strRespoMsg{get; set;}
    public boolean Msgg1{get; set;}
    public boolean Msgg2{get; set;}
    public String strNavigateTo{get; set;}
    public RecordType recrdTyp = new RecordType();
    // this method is call when page loaded it initialize and query all the required records.
    public PageReference onloadfun()
    {
        isShowMsg = true;
        isFail1 = false;
        isFail2 = false;
        Msgg1 = true;
        Msgg2 = true;
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        recrdTyp = [select Id from RecordType where Name='SF Action'and SobjectType='SVMXC__ServiceMax_Processes__c' limit 1];
        strRespoMsg = '';
          strRecordId = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('SVMX_recordId'));
        strPrcssId =  System.currentPageReference().getParameters().get('SVMX_processId');
        strNxtPrcssId = System.currentPageReference().getParameters().get('SVMX_NxtStepID');
        ActionTitl= System.currentPageReference().getParameters().get('SVMX_title');
        System.debug('get title 1 : '+ActionTitl);
        if(ActionTitl != null)
        ActionTitl = EncodingUtil.urlDecode(ActionTitl, 'UTF-8');
        System.debug('get title 2 : '+ActionTitl);
        System.debug('SVMX_recordId : '+strRecordId);
        System.debug('SVMX_processId : '+strPrcssId);
        System.debug('SVMX_NxtStepID : '+strNxtPrcssId);
        System.debug('SVMX_Record type id is : '+recrdTyp.Id);
        String ObjName;
        String NamedField;
        
        if(strPrcssId != null && strPrcssId != '')
        {
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            objPrcss = [select Id, SVMXC__Service_Namespace__c, SVMXC__Service_Class_Name__c, SVMXC__Service_Method_Name__c,  SVMXC__Parent_Error_Msg__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: strPrcssId And RecordTypeId =: recrdTyp.Id];
        }
        if(objPrcss != null)
        {
            
                
                strNmSpace = objPrcss.SVMXC__Service_Namespace__c;
                strClssNm = objPrcss.SVMXC__Service_Class_Name__c;
                strMethDNm = objPrcss.SVMXC__Service_Method_Name__c;
                strProcessinMsg = objPrcss.SVMXC__Parent_Error_Msg__c;
                strCfgDtaRecordId = objPrcss.Id;
                
                if(strRecordId != null && strRecordId != '')
                {
                    
                    String ObjectKeyPrefix =  strRecordId.subString(0, 3);
                    Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
                    for(String Obj : allObjs.keySet())
                    {
                        Schema.DescribeSObjectResult R = allObjs.get(Obj).getDescribe();
                        if(R.getKeyPrefix() != null && R.getKeyPrefix().equals(ObjectKeyPrefix))
                        {
                            ObjName = R.getName();
                            for(String fld : R.fields.getMap().keySet())
                            {
                                if(R.fields.getMap().get(fld).getDescribe().isNameField())
                                {
                                    NamedField = R.fields.getMap().get(fld).getDescribe().getName();
                                    break;
                                }
                            }
                            break;
                        }
                    }
                    
                }
                
                if(ObjName!= null && NamedField != null)
                {
                    Set<String> setFieldAPINames = new Set<String>();
                    String fieldString = ' ';
                    
                    lstCfgDta.clear();
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstCfgDta = [Select Id, SVMXC__Object_Name__c, SVMXC__Parameter_Name__c, SVMXC__Parameter_Type__c, SVMXC__Parameter_Value__c, SVMXC__Expression_Rule__c, SVMXC__Dispatch_Process__c, SVMXC__Lookup_Field_API_Name__c From SVMXC__ServiceMax_Config_Data__c Where SVMXC__Dispatch_Process__c =: strCfgDtaRecordId AND RecordType.Name = 'SF Action Parameter' AND SVMXC__Dispatch_Process__c != null];
                    
                    if(lstCfgDta != null && lstCfgDta.size() > 0)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c p : lstCfgDta)
                        {
                            if(p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD NAME')
                            {   
                                if(p.SVMXC__Parameter_Value__c != null )
                                    setFieldAPINames.add((p.SVMXC__Parameter_Value__c).ToUpperCase());
                            }
                            else if(p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD SOURCE' && p.SVMXC__Lookup_Field_API_Name__c != null && p.SVMXC__Parameter_Value__c != null){
                            	setFieldAPINames.add((p.SVMXC__Lookup_Field_API_Name__c +'.'+ p.SVMXC__Parameter_Value__c));
                            }
                        }
                    }
                    fieldString = NamedField;
                    if(setFieldAPINames != null && setFieldAPINames.size() > 0)
                    {
                        
                        for (String field : setFieldAPINames)
                        {
                            if(fieldString != ' ')
                                fieldString += ', ' + field;
                            else
                                fieldString += field;
                        }
                    }
                    
                    system.debug('10. Fields to be Queried: ' + fieldString);
                    String SOQLStr = 'select '+ fieldString + ' from ' + ObjName + ' where ' + 'id =\'' + strRecordId + '\'';
                    system.debug('11. Query String: ' + SOQLStr);
                    sObject rec = database.query(SOQLStr);
                    system.debug('12. Record Queried: ' + rec);
                    RecodNmFld = (String)rec.get(NamedField);
                    
                    SVMXC__ServiceMax_Config_Data__c  tempObj = new SVMXC__ServiceMax_Config_Data__c();
                    tempObj.SVMXC__Parameter_Name__c = 'SVMX_RECORDID';
                    tempObj.SVMXC__Parameter_Value__c = strRecordId;
                    lstCfgDtaSend.add(tempObj);
                    if (lstCfgDta != null)
                    {
                        for (SVMXC__ServiceMax_Config_Data__c p : lstCfgDta)
                        {
                            SVMXC__ServiceMax_Config_Data__c  tempObj1 = new SVMXC__ServiceMax_Config_Data__c();
                            tempObj1.SVMXC__Parameter_Name__c = p.SVMXC__Parameter_Name__c;
                            if (p.SVMXC__Parameter_Type__c.toUpperCase() == 'VALUE')
                                tempObj1.SVMXC__Parameter_Value__c = p.SVMXC__Parameter_Value__c;
                            else if (p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD NAME' && rec.get(p.SVMXC__Parameter_Value__c) != null)
                                tempObj1.SVMXC__Parameter_Value__c = String.Valueof(rec.get(p.SVMXC__Parameter_Value__c));
                            else if(p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD SOURCE'){
                            	//Added by Sathish for story BAC-4914
                            	Map<String, Object> valueMap = rec.getPopulatedFieldsAsMap();
                            	String lkpFieldValue = null;
                                if(valueMap.containsKey(p.SVMXC__Lookup_Field_API_Name__c)){
                                    lkpFieldValue = String.valueOf(rec.getSObject(p.SVMXC__Lookup_Field_API_Name__c).get(p.SVMXC__Parameter_Value__c));
                                }
                            	
                            	if(lkpFieldValue != null && lkpFieldValue != ''){
                            		tempObj1.SVMXC__Parameter_Value__c = lkpFieldValue;
                            	}
                            	else{
                            		tempObj1.SVMXC__Parameter_Value__c = '';
                            	}
                            }    
                            lstCfgDtaSend.add(tempObj1);
                        }
                    }
                }
                strJSON = JSON.serialize(lstCfgDtaSend);
            ServiceFlowWizard_Utils objSFWUtil = new ServiceFlowWizard_Utils();
            strNxtURL = objSFWUtil.SVMX_GetNextStepURL(strRecordId,strNxtPrcssId);
        }
        return null;
    }
    
    
    public PageReference shoErrConfMsg()
    {
        isShowMsg = false;
        isFail1 = true;
        isFail2 = false;
        Msgg1 = false;
        Msgg2 = true;
        String strmsg1 = '';
        try{
            strRespoMsg = strRespoMsg.replace('&apos;','"');
            XmlStreamReader xsr = new XmlStreamReader(strRespoMsg);
            if(xsr.getEventType() == XmlTag.START_DOCUMENT)
            {
                xsr.next();
                while(xsr.hasNext())
                {
                    if(xsr.getLocalName() == 'faultstring')
                    {
                        xsr.next();
                        if(xsr.getEventType() == XmlTag.CHARACTERS)
                            strmsg1 = xsr.getText();
                    }
                    xsr.next();
                }
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG001()));
        }
        
        
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG001(),strmsg1));
        return null;
    }
    
    public PageReference callMethWOMsg()
    {
        PageReference pageRef;
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); //Added for the Security fixes
        if(strNxtPrcssId != null && strNxtPrcssId.length() > 0)
        {
            if(strNxtURL.length() > 3 && strNxtURL.substring(0,3) == '../')
            {
                String getNxtURL = strNxtURL.substring(2);
                //pageRef = new PageReference(getNxtURL); //Commented for the Security fixes
                pageRef = new PageReference(baseURL + getNxtURL);
            }
            else{
                //pageRef = new PageReference(strNxtURL); //Commented for the Security fixes
                pageRef = new PageReference(baseURL + strNxtURL);
            }
        }
        else if(strNavigateTo != null && strNavigateTo.length() > 0)
        {
            if(strNavigateTo.length() > 3 &&  strNavigateTo.substring(0,3) == '../')
                strNavigateTo = strNavigateTo.substring(2);
            pageRef = new PageReference(strNavigateTo);
        }
        else
        {
            String retURL = '/'+strRecordId;
            pageRef = new PageReference(retURL);
        }
        pageRef.setRedirect(true);
        return pageRef; 
    }
    
    // this method call when web service responce with messageType is WARN
    public PageReference showWarnMsg()
    {
        Msgg1 = true;
        Msgg2 = false;
        isShowMsg = false;
        if(strNavigateTo.length() > 3 && strNavigateTo.substring(0,3) == '../')
                strNavigateTo = strNavigateTo.substring(2);
        if((strNxtPrcssId != null && strNxtPrcssId.length() > 0) || (strNavigateTo != null && strNavigateTo.length() > 0) )
        {
            isFail1 = false;
            isFail2 = true;
        }
        else
        {
            isFail1 = true;
            isFail2 = false;
        }
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.WARNING,strRespoMsg));
        return null;
    }
    
    // this method call when web service responce with messageType is INFO
    public PageReference showInfoMsg()
    {
        Msgg1 = true;
        Msgg2 = false;
        isShowMsg = false;
        if(strNavigateTo.length() > 3 && strNavigateTo.substring(0,3) == '../')
                strNavigateTo = strNavigateTo.substring(2);
        if((strNxtPrcssId != null && strNxtPrcssId.length() > 0) || (strNavigateTo != null && strNavigateTo.length() > 0) )
        {
            isFail1 = false;
            isFail2 = true;
        }
        else
        {
            isFail1 = true;
            isFail2 = false;
        }
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO,strRespoMsg));
        return null;
    }
    
    
    public PageReference webServiceFailWM()
    {
        Msgg1 = false;
        Msgg2 = true;
        isShowMsg = false;
        isFail1 = true;
        isFail2 = false;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG001(),strRespoMsg));
        return null;
    }
    
    
    public PageReference doContinue()
    {
        PageReference pageRef;
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); //Added for the Security fixes
        if(strNxtURL != ('/'+strRecordId))
        {
            if(strNxtURL.length() > 3 && strNxtURL.substring(0,3) == '../')
            {
                String getNxtURL = strNxtURL.substring(2);
                //pageRef = new PageReference(getNxtURL); //Commented for the Security fixes
                pageRef = new PageReference(baseURL + getNxtURL); 
            }
            else{
                //pageRef = new PageReference(strNxtURL); //Commented for the Security fixes
                pageRef = new PageReference(baseURL + strNxtURL);
            }
        }
        else
        {
            if(strNavigateTo.length() > 3 && strNavigateTo.substring(0,3) == '../')
                strNavigateTo = strNavigateTo.substring(2);
            if(strNavigateTo != null && strNavigateTo.length() > 0)
                pageRef = new PageReference(strNavigateTo);
        }
        pageRef.setRedirect(true);
        return pageRef; 
    }
    
    public PageReference goBack()
    {
        String retURL = '/'+strRecordId;
        PageReference pageRef = new PageReference(retURL);
        pageRef.setRedirect(true);
        return pageRef; 
    } 
    
    
    //custom labels
    public String getTAG001(){return System.label.CONF018_TAG070;}//'Your Web Service call failed'
    public String getTAG002(){return System.label.CONF018_TAG073;}//'Return'
    public String getTAG003(){return System.label.CONF018_TAG074;}//'Continue'
    
}