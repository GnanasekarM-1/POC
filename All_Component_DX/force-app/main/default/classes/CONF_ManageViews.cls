public with sharing class CONF_ManageViews
{
    public List<SVMXC__ServiceMax_Processes__c> lstStdViwCnfgr =  new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getLstStdViwCnfgr() {return lstStdViwCnfgr;}
    public void setLstStdViwCnfgr(List<SVMXC__ServiceMax_Processes__c> lst) {lstStdViwCnfgr = lst;}
    public List<SVMXC__ServiceMax_Processes__c> lstCustViwCnfgr =  new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getLstCustViwCnfgr() {return lstCustViwCnfgr;}
    public void setLstCustViwCnfgr(List<SVMXC__ServiceMax_Processes__c> lst) {lstCustViwCnfgr = lst;}
    public String strEditRView{get; set;}
    public String strManagPrmmsin{get; set;}
    public boolean chkStrdlst{get; set;}
    public boolean chkCustlst{get; set;}
    public CONF_ManageViews()
    {
       /* map<String, Schema.SObjectType> mapAllObjDesc = Schema.getGlobalDescribe();
        if(mapAllObjDesc.size() > 0)
        {
            for(String str : mapAllObjDesc.keyset())
            {
                mapObjAPINameLabel.put(mapAllObjDesc.get(str).getDescribe().getName(),mapAllObjDesc.get(str).getDescribe().getlabel());
            }   
        } */
        getqueryResult();
    }
    public void getqueryResult()
    {
        map<String,String> mapObjAPINameLabel = new map<String,String>();
        map<String, Schema.SObjectType> mapAllObjDesc = Schema.getGlobalDescribe();
        if(mapAllObjDesc.size() > 0)
        {
            for(String str : mapAllObjDesc.keyset())
            {
                mapObjAPINameLabel.put(mapAllObjDesc.get(str).getDescribe().getName(),mapAllObjDesc.get(str).getDescribe().getlabel());
            }   
        }
        mapAllObjDesc.clear();
        RecordType RTNameSearch = new RecordType();
        List<SVMXC__ServiceMax_Processes__c> lstAllViwCnfgr =  new List<SVMXC__ServiceMax_Processes__c>();
        RTNameSearch = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'View Definition' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstAllViwCnfgr.clear();
        lstAllViwCnfgr = [Select Id, LastModifiedById, LastModifiedBy.Name, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Rule_Type__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Description__c, LastModifiedDate From SVMXC__ServiceMax_Processes__c where RecordTypeId  =: RTNameSearch.Id and SVMXC__Rule_Type__c = 'Custom View' order by SVMXC__Source_Object_Name__c, SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        lstStdViwCnfgr.clear();
        lstCustViwCnfgr.clear();
        for(SVMXC__ServiceMax_Processes__c lstPrss : lstAllViwCnfgr )
        {
            if(lstPrss.SVMXC__Source_Object_Name__c != null &&  mapObjAPINameLabel.containskey(lstPrss.SVMXC__Source_Object_Name__c))
                lstPrss.SVMXC__Source_Object_Name__c = mapObjAPINameLabel.get(lstPrss.SVMXC__Source_Object_Name__c);
            if(lstPrss.SVMXC__IsStandard__c == true)
                lstStdViwCnfgr.add(lstPrss);
            else
                lstCustViwCnfgr.add(lstPrss);
        }
        lstAllViwCnfgr.clear();
        if(lstCustViwCnfgr.size() == 0)
            chkCustlst = true;
        else
            chkCustlst = false;
            
        if(lstStdViwCnfgr.size() == 0)
            chkStrdlst = true;
        else
            chkStrdlst = false;
    }
    
    public pageReference ViewREditProcess()
    {
        List<String> lstSelctId = new List<String>();
        List<SVMXC__ServiceMax_Processes__c> lstTempPrcss = new List<SVMXC__ServiceMax_Processes__c>();
        if(strEditRView == 'View')
            lstTempPrcss = lstStdViwCnfgr;
        else if(strEditRView == 'Edit')
            lstTempPrcss = lstCustViwCnfgr;
        for(SVMXC__ServiceMax_Processes__c lstPrss : lstTempPrcss)
        {
            if(lstPrss.SVMXC__Select__c == true)
                lstSelctId.add(lstPrss.Id);
        }
        if(lstSelctId.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG020()));
            return null;
        }
        else if(lstSelctId.size() > 1)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG021()));
            return null;
        }
        else
        {
            PageReference pageRef = new PageReference('/apex/CONF_SetupViews');
            pageRef.getParameters().put('SVMX_ViewId', lstSelctId[0]);
            pageRef.setRedirect(true);
            return pageRef;
        }
    }
    
    public pageReference managePermission()
    {
        /*List<String> lstSelctId = new List<String>();
        List<SVMXC__ServiceMax_Processes__c> lstTempPrcss = new List<SVMXC__ServiceMax_Processes__c>();
        if(strManagPrmmsin == 'lstStdViwCnfgr')
            lstTempPrcss = lstStdViwCnfgr;
        else if(strManagPrmmsin == 'lstCustViwCnfgr')
            lstTempPrcss = lstCustViwCnfgr;
        for(SVMXC__ServiceMax_Processes__c lstPrss : lstTempPrcss)
        {
            if(lstPrss.SVMXC__Select__c == true)
                lstSelctId.add(lstPrss.Id);
        }
        if(lstSelctId.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG020()));
            return null;
        }
        else if(lstSelctId.size() > 1)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG021()));
            return null;
        }
        else
        {*/
            PageReference pageRef = new PageReference('/apex/CONF_ManageViewPermission');
            //pageRef.getParameters().put('SVMX_PrcssId', lstSelctId[0]);
            pageRef.getParameters().put('SVMX_RetURL', '/apex/CONF_ManageViews');
            pageRef.setRedirect(true);
            return pageRef;
        //}
    }
    
    
    public pageReference cloneProcess()
    {
        List<String> lstSelctId = new List<String>();
        List<SVMXC__ServiceMax_Processes__c> lstTempPrcss = new List<SVMXC__ServiceMax_Processes__c>();
        if(strEditRView == 'Clone1')
            lstTempPrcss = lstStdViwCnfgr;
        else if(strEditRView == 'Clone2')
            lstTempPrcss = lstCustViwCnfgr;
        for(SVMXC__ServiceMax_Processes__c lstPrss : lstTempPrcss)
        {
            if(lstPrss.SVMXC__Select__c == true)
                lstSelctId.add(lstPrss.Id);
        }
        if(lstSelctId.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG020()));
            return null;
        }
        else if(lstSelctId.size() > 1)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG021()));
            return null;
        }
        else
        {
            PageReference pageRef = new PageReference('/apex/CONF_SetupViews');
            pageRef.getParameters().put('SVMX_ViewId', lstSelctId[0]);
            pageRef.getParameters().put('SVMX_Mode', 'Clone');
            pageRef.setRedirect(true);
            return pageRef;
        }
    }
    
    
    
    public pageReference backToSetup()
    {
         //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public pageReference deletPross()
    {
        List<SVMXC__ServiceMax_Processes__c> lstDeletePrcss = new List<SVMXC__ServiceMax_Processes__c>();
        List<String> delprssIds = new List<String>();
        for(SVMXC__ServiceMax_Processes__c lstPrss : lstCustViwCnfgr)
        {
            if(lstPrss.SVMXC__Select__c == true)
                {
                    lstDeletePrcss.add(lstPrss);
                    delprssIds.add(lstPrss.Id);
                }
        }
        if(lstDeletePrcss.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG020()));
            return null;
        }
        else if(lstDeletePrcss.size() > 0)
        {
            try
            {
                List<SVMXC__ServiceMax_Config_Data__c> lstCfgDtaToDel = [select id from SVMXC__ServiceMax_Config_Data__c where  RecordType.Name = 'Expressions' and ( SVMXC__Expression_Type__c =: 'SRCH_Object_Prefilter_Criteria' OR SVMXC__Expression_Type__c =: 'SRCH_Object_Fields' ) and SVMXC__Expression_Rule__c IN : delprssIds]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                List<SVMXC__ServiceMax_Config_Data__c> lstCfgDtaToTechNTeri = [select id from SVMXC__ServiceMax_Config_Data__c where  RecordType.Name = 'View Access' and SVMXC__Dispatch_Process__c IN : delprssIds]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                
                if(lstCfgDtaToDel != null && lstCfgDtaToDel.size() > 0) {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                        
                        Delete lstCfgDtaToDel; //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                }                    
                    
                if(lstCfgDtaToTechNTeri != null && lstCfgDtaToTechNTeri.size() > 0) {
                    
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                        
                        Delete lstCfgDtaToTechNTeri; //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                }                    
                
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {
                    
                    Delete lstDeletePrcss; //SDL-SVMX-DELETE-FLS-ENFORCED
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG022()));
                    getqueryResult();                    
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
            }
            
        }
        return null;
    }
    
    
    
    public pageReference newPrcss()
    {
        PageReference pageRef = new PageReference('/apex/CONF_SetupViews');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    //==========================Custome Labels===============================
    
    public String getHLPURL() {return System.label.CONF033_HLPURL;}
    public String getTAG001() {return System.label.CONF033_TAG001;}//'Manage Views'
    public String getTAG002() {return System.label.COMM001_TAG064;}//'Help'
    public String getTAG003() {return System.label.CONF033_TAG002;}//'Standard Views'
    public String getTAG004() {return System.label.COMM001_TAG043;}//'View'
    public String getTAG005() {return System.label.COMM001_TAG045;}//'Clone'
    public String getTAG006() {return System.label.CONF033_TAG003;}//'Manage Permissions'
    public String getTAG007() {return System.label.COMM001_TAG046;}//'Back To Setup Home'
    public String getTAG008() {return System.label.COMM001_TAG044;}//'Select'
    public String getTAG009() {return System.label.CONF033_TAG004;}//'View Id'
    public String getTAG010() {return System.label.CONF033_TAG005;}//'View Name'
    public String getTAG011() {return System.label.COMM001_TAG017;}//'Description'
    public String getTAG013() {return System.label.COMM001_TAG067;}//'Last Modified Date'
    public String getTAG014() {return System.label.CONF033_TAG007;}//'Custom Views'
    public String getTAG015() {return System.label.COMM001_TAG047;}//'New'
    public String getTAG016() {return System.label.COMM001_TAG048;}//'Edit'
    public String getTAG017() {return System.label.COMM001_TAG045;}//'Clone'
    public String getTAG018() {return System.label.COMM001_TAG049;}//'Delete'
    public String getTAG019() {return System.label.COMM001_TAG041;}//'Processing...'
    public String getTAG020() {return System.label.COMM001_TAG050;}//'Please select at least one record to perform this action'
    public String getTAG021() {return System.label.COMM001_TAG051;}//'Please select only one record to perform this action'
    public String getTAG022() {return System.label.COMM001_TAG052;}//'Record(s) Deleted Sucessfully'
    public String getTAG023() {return System.label.COMM001_TAG057;}//'Are you sure?'
}