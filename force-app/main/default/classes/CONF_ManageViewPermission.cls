public with sharing class CONF_ManageViewPermission
{
    //------------- variables ------
    public String strSVMX_PrecssId{get; set;}
    public boolean isSave;
    public String RetURL;
    public boolean CheckAllLines{get; set;}
    public boolean CheckAllLines1{get; set;}
    public boolean CheckAllLines2{get; set;}
    public boolean CheckAllLines3{get; set;}
    public String ParameterID{get; set;}
    public String setprcss{get; set;}
    public String SearchKeyword{get; set;}
    public boolean isLstPrcss{get; set;}
    public String SearchTerriKeyword{get; set;}
    public String SelectedTab{get; set;}
    public boolean topComp{get; set;}
    public boolean teamComp{get; set;}
    public boolean teriComp{get; set;}
    public boolean teamCompSrch{get; set;}
    public boolean teriCompSrch{get; set;}
    
    public List<SVMXC__ServiceMax_Processes__c> lstSVMXPrcss = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstMstrSVMXCfgDta = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstSVMXCfgDtaTeam = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getLstSVMXCfgDtaTeam() {return lstSVMXCfgDtaTeam;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstSVMXCfgDtaTerritory = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getLstSVMXCfgDtaTerritory() {return lstSVMXCfgDtaTerritory;}
    
    public List<SelectOption> selAccssOptn = new List<SelectOption>();
    public List<SelectOption> getSelAccssOptn() {return selAccssOptn;}
    public void SetSelAccssOptn(List<SelectOption> rr) {selAccssOptn = rr;}
    
    public List<SVMXC__Service_Group__c> ServiceTeams = new List<SVMXC__Service_Group__c>();
    public List<SVMXC__Service_Group__c> getServiceTeams() {return ServiceTeams;}
    
    public List<SVMXC__Territory__c> lstTerritory = new List<SVMXC__Territory__c>();
    public List<SVMXC__Territory__c> getLstTerritory() {return lstTerritory;}
    
    public List<SelectOption> selPrcssOptn = new List<SelectOption>();
    public List<SelectOption> getSelPrcssOptn() {return selPrcssOptn;}
    public void setSelPrcssOptn(List<SelectOption> ls) {selPrcssOptn = ls;}
    
    
    public RecordType RTProcess = new RecordType();
    public RecordType RTCfgDta = new RecordType();
    
    //----- contractor-----
    public CONF_ManageViewPermission()
    {
        isLstPrcss = false;
        isSave = false;
        onLoad();
        exeQuerry();  
        SelectedTab = getTAG017();      
    }
    
    
    public void onLoad()
    {
        topComp = false;
        teamComp = false;
        teriComp = false;
        teamCompSrch = false;
        teriCompSrch = false;
        
        strSVMX_PrecssId = 'SVMX.None';
        PageReference pageRef = ApexPages.currentPage();
        strSVMX_PrecssId = pageRef.getParameters().get('SVMX_PrcssId');
        RetURL = pageRef.getParameters().get('SVMX_RetURL');
        if(strSVMX_PrecssId == '')
        {
            strSVMX_PrecssId = 'SVMX.None';
        }
        
        RTProcess = [select Id from RecordType where Name = 'View Definition' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RTCfgDta = [select Id from RecordType where Name = 'View Access' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        lstSVMXPrcss.clear();
        lstSVMXPrcss = [select Id, SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where RecordTypeId =: RTProcess.Id and SVMXC__Rule_Type__c = : 'Custom View']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        //lstTeam.clear();
        //lstTeam = [select Id, Name, SVMXC__Select__c from SVMXC__Service_Group__c];
        
        //lstTerritry.clear();
        //lstTerritry = [select Id, Name, SVMXC__Select__c from SVMXC__Territory__c];
        
        List<SelectOption> templstOptn = new List<SelectOption>();
        selPrcssOptn.clear();
        selPrcssOptn.add(new SelectOption('SVMX.None' , getTAG014()));
        for(SVMXC__ServiceMax_Processes__c objPrcss : lstSVMXPrcss)
        {
            templstOptn.add(new SelectOption(objPrcss.Id , objPrcss.SVMXC__Name__c));
        }
        
        //templstOptn = sortingSelectOption(templstOptn);
        for(SelectOption slctOptn : templstOptn)
        {
            selPrcssOptn.add(slctOptn);
        }
        templstOptn.clear();
        
        
        Schema.DescribeFieldResult F = SVMXC__ServiceMax_Config_Data__c.SVMXC__Access_To__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        for(Schema.PicklistEntry pp : p)
        {
            selAccssOptn.add(new SelectOption(pp.getLabel() , pp.getLabel()));
        } 
        
        
        
    }
    
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO : sortList) 
        {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }
    
    public void exeQuerry()
    {
        isSave = false;
        lstMstrSVMXCfgDta.clear();
        lstTerritory.clear();
        ServiceTeams.clear();
        SearchKeyword = '';
        SearchTerriKeyword = '';
        
        if(strSVMX_PrecssId != null && strSVMX_PrecssId != '' && strSVMX_PrecssId != 'SVMX.None' && strSVMX_PrecssId != 'None')
        {
            isLstPrcss = true;
            lstMstrSVMXCfgDta = [select Id, SVMXC__Dispatch_Process__c, SVMXC__Select__c , SVMXC__Configuration_Type__c, SVMXC__Service_Group__c, SVMXC__Territory__c, SVMXC__Access_To__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: RTCfgDta.Id and SVMXC__Dispatch_Process__c =: strSVMX_PrecssId and SVMXC__Configuration_Type__c =: 'Custom_View' ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            lstSVMXCfgDtaTeam.clear();
            lstSVMXCfgDtaTerritory.clear();
            for(SVMXC__ServiceMax_Config_Data__c cfgDta : lstMstrSVMXCfgDta)
            {
                if(cfgDta.SVMXC__Service_Group__c != null)
                    lstSVMXCfgDtaTeam.add(cfgDta);
                else if(cfgDta.SVMXC__Territory__c != null)
                    lstSVMXCfgDtaTerritory.add(cfgDta);
            }
        }
    }

    public void onChangeProcessOptn()
    {
        SelectedTab = getTAG017();
        if(strSVMX_PrecssId != '' && strSVMX_PrecssId != 'SVMX.None')
        {
            exeQuerry();
        }
        else
            isLstPrcss = false;
    }
    
    public void SVMX_GOTeam()
    {
        topComp = false;
        teamComp = false;
        teriComp = false;
        teamCompSrch = true;
        teriCompSrch = false;
        List<String> lstHvIds = new List<String>();
        
        for(SVMXC__ServiceMax_Config_Data__c objcfgdta : lstSVMXCfgDtaTeam)
        {
            if(objcfgdta.SVMXC__Service_Group__c != null)
                lstHvIds.add(objcfgdta.SVMXC__Service_Group__c);
        }
        
        ServiceTeams.clear();
        if(SearchKeyword != '')
        {
            try
            {
                ServiceTeams = [select Id, Name, SVMXC__Select__c from SVMXC__Service_Group__c where Name LIKE : '%'+SearchKeyword+'%' and  Id NOT IN: lstHvIds];
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + ex.getMessage() ));
            }
        }
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG031() ));
    }
    
    public void SVMX_GOTerritory()
    {
        topComp = false;
        teamComp = false;
        teriComp = false;
        teamCompSrch = false;
        teriCompSrch = true;
        List<String> lstHvIds = new List<String>();
        
        for(SVMXC__ServiceMax_Config_Data__c objcfgdta : lstSVMXCfgDtaTerritory)
        {
            if(objcfgdta.SVMXC__Territory__c != null)
                lstHvIds.add(objcfgdta.SVMXC__Territory__c);
        }
        
        lstTerritory.clear();
        if(SearchTerriKeyword != '')
        {
            try
            {
            lstTerritory = [select Id, Name, SVMXC__Select__c from SVMXC__Territory__c where Name LIKE : '%'+SearchTerriKeyword+'%' and  Id NOT IN: lstHvIds];
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + ex.getMessage() ));
            }
        }
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG031() ));
    }
    
    public void SVMX_AddTeam()
    {
        SVMXC__ServiceMax_Config_Data__c tmpObj = new SVMXC__ServiceMax_Config_Data__c();
        tmpObj.SVMXC__Access_To__c = 'All';
        lstSVMXCfgDtaTeam.add(tmpObj);
    }
    
    public void SVMX_CencelTeam()
    {
        ServiceTeams.clear();
        SearchKeyword = '';
    }
    
    public void SVMX_CencelTerritory()
    {
        lstTerritory.clear();
        SearchTerriKeyword = '';
    }
    
    public void SVMX_AddSelectedTerritory()
    {
        topComp = false;
        teamComp = false;
        teriComp = false;
        teamCompSrch = false;
        teriCompSrch = true;
        Integer intCuntSel =0 ;
        for(SVMXC__Territory__c ObjTem : lstTerritory)
        {
            if(ObjTem.Select__c == true)
                intCuntSel++;
        }
        if(intCuntSel != 0 )
        {
            for(SVMXC__Territory__c ObjTem1 : lstTerritory)
            {
                if(ObjTem1.Select__c == true)
                {
                    SVMXC__ServiceMax_Config_Data__c tmpObj1 = new SVMXC__ServiceMax_Config_Data__c();
                    tmpObj1.SVMXC__Territory__c = ObjTem1.Id;
                    tmpObj1.SVMXC__Access_To__c = 'All';
                    lstSVMXCfgDtaTerritory.add(tmpObj1);
                }
            }
        }
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG026() ));
        SVMX_GOTerritory();
    }
    
    public void SVMX_AddSelectedTeam()
    {
        topComp = false;
        teamComp = false;
        teriComp = false;
        teamCompSrch = true;
        teriCompSrch = false;
        Integer intCuntSel =0 ;
        for(SVMXC__Service_Group__c ObjTem : ServiceTeams)
        {
            if(ObjTem.Select__c == true)
                intCuntSel++;
        }
        if(intCuntSel != 0 )
        {
            for(SVMXC__Service_Group__c ObjTem : ServiceTeams)
            {
                if(ObjTem.Select__c == true)
                {
                    SVMXC__ServiceMax_Config_Data__c tmpObj = new SVMXC__ServiceMax_Config_Data__c();
                    tmpObj.SVMXC__Service_Group__c = ObjTem.Id;
                    tmpObj.SVMXC__Access_To__c = 'All';
                    lstSVMXCfgDtaTeam.add(tmpObj);
                }
            }
        }
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG026() ));
        SVMX_GOTeam();
    }
    
    public void SVMX_AddTerritory()
    {
        
        SVMXC__ServiceMax_Config_Data__c tmpObj1 = new SVMXC__ServiceMax_Config_Data__c();
        tmpObj1.SVMXC__Access_To__c = 'All';
        lstSVMXCfgDtaTerritory.add(tmpObj1);
    }
    
    
    
    public void SVMX_DeleteTeam()
    {
        topComp = false;
        teamComp = true;
        teriComp = false;
        teamCompSrch = false;
        teriCompSrch = false;
        Integer intCount = 0;
        List<SVMXC__ServiceMax_Config_Data__c> lstTmpCfgDta = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstTmpDelCfgDta = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstSVMXCfgDtaTeam)
        {
            if(objCfgDta.Select__c == true)
            {
                intCount++;
                if(objCfgDta.Id !=null)
                {
                    List<SVMXC__ServiceMax_Config_Data__c> lstTmpMstrCfgDta = new List<SVMXC__ServiceMax_Config_Data__c>();
                    lstTmpMstrCfgDta = lstMstrSVMXCfgDta.deepClone(true,true,true);
                    lstMstrSVMXCfgDta.clear();
                    for(SVMXC__ServiceMax_Config_Data__c objCfgDta2 : lstTmpMstrCfgDta)
                    {
                        if(objCfgDta.Id != objCfgDta2.Id)
                        {
                            lstMstrSVMXCfgDta.add(objCfgDta2);
                        }
                        else
                        {
                            lstTmpDelCfgDta.add(objCfgDta2);
                        }
                    }
                }
                
            }
            else
            {
                lstTmpCfgDta.add(objCfgDta);
            }
        }
        if(intCount != 0 )
        {
            try
            {
                if(lstTmpDelCfgDta != null && lstTmpDelCfgDta.size() > 0){
                    if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c') ) {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    }
                    delete lstTmpDelCfgDta; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                lstSVMXCfgDtaTeam.clear();
                lstSVMXCfgDtaTeam = lstTmpCfgDta.deepClone(true,true,true);
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.CONFIRM, '' + getTAG027() ));
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + ex.getMessage() ));
            }
        }
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG026() ));
        lstTmpCfgDta.clear();
    }
    
    
    public void SVMX_DeleteTerritory()
    {
        topComp = false;
        teamComp = false;
        teriComp = true;
        teamCompSrch = false;
        teriCompSrch = false;
        Integer intCount1 = 0;
        List<SVMXC__ServiceMax_Config_Data__c> lstTmpCfgDta1 = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        List<SVMXC__ServiceMax_Config_Data__c> lstTmpDelCfgDta = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        for(SVMXC__ServiceMax_Config_Data__c objCfgDta1 : lstSVMXCfgDtaTerritory)
        {
            if(objCfgDta1.Select__c == true)
            {
                intCount1++;
                if(objCfgDta1.Id != null)
                {
                    List<SVMXC__ServiceMax_Config_Data__c> lstTmpMstrCfgDta = new List<SVMXC__ServiceMax_Config_Data__c>();
                    lstTmpMstrCfgDta = lstMstrSVMXCfgDta.deepClone(true,true,true);
                    lstMstrSVMXCfgDta.clear();
                    for(SVMXC__ServiceMax_Config_Data__c objCfgDta2 : lstTmpMstrCfgDta)
                        if(objCfgDta1.Id != objCfgDta2.Id)
                            lstMstrSVMXCfgDta.add(objCfgDta2);
                        else
                            lstTmpDelCfgDta.add(objCfgDta1);
                }
            }
            else
            {
               lstTmpCfgDta1.add(objCfgDta1);
            }
        }
        if(intCount1 != 0 )
        {
            try
            {
                if(lstTmpDelCfgDta != null && lstTmpDelCfgDta.size() > 0){
                    
                    if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c') ) {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    }
                    delete lstTmpDelCfgDta; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                lstSVMXCfgDtaTerritory.clear();
                lstSVMXCfgDtaTerritory = lstTmpCfgDta1.deepClone(true,true,true);
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.CONFIRM, '' + getTAG027() ));
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + ex.getMessage() ));
            }
        }
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG026() ));
        lstTmpCfgDta1.clear();
    }   
    
    public void saveData()
    {
        topComp = true;
        teamComp = false;
        teriComp = false;
        teamCompSrch = false;
        teriCompSrch = false;
        List<SVMXC__ServiceMax_Config_Data__c> lstToSaveTeam = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstToSaveTerri = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        Set<String> chkDuplicateTeam = new Set<String>();
        Set<String> chkDuplicateTerri = new Set<String>();
        
        
        for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstSVMXCfgDtaTeam)
        {
            if(chkDuplicateTeam.contains(objCfgDta.SVMXC__Service_Group__c) == false)
            {
                SVMXC__ServiceMax_Config_Data__c tempCfgDta = new SVMXC__ServiceMax_Config_Data__c();
                tempCfgDta.RecordTypeId = RTCfgDta.Id;
                tempCfgDta.SVMXC__Configuration_Type__c = 'Custom_View';
                tempCfgDta.SVMXC__Dispatch_Process__c = strSVMX_PrecssId;
                tempCfgDta.SVMXC__Access_To__c = objCfgDta.SVMXC__Access_To__c;
                tempCfgDta.SVMXC__Service_Group__c =objCfgDta.SVMXC__Service_Group__c;
                lstToSaveTeam.add(tempCfgDta);
                chkDuplicateTeam.add(objCfgDta.SVMXC__Service_Group__c);
            }
        }
        
        for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstSVMXCfgDtaTerritory)
        {
            if(chkDuplicateTerri.contains(objCfgDta.SVMXC__Territory__c) == false)
            {
                SVMXC__ServiceMax_Config_Data__c tempCfgDta = new SVMXC__ServiceMax_Config_Data__c();
                tempCfgDta.RecordTypeId = RTCfgDta.Id;
                tempCfgDta.SVMXC__Configuration_Type__c = 'Custom_View';
                tempCfgDta.SVMXC__Dispatch_Process__c = strSVMX_PrecssId;
                tempCfgDta.SVMXC__Access_To__c = objCfgDta.SVMXC__Access_To__c;
                tempCfgDta.SVMXC__Territory__c =objCfgDta.SVMXC__Territory__c;
                lstToSaveTerri.add(tempCfgDta);
                chkDuplicateTerri.add(objCfgDta.SVMXC__Territory__c);
            }
        }
        

        try
        {
            if(lstMstrSVMXCfgDta != null && lstMstrSVMXCfgDta.size() > 0){
                if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c') ) {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                }
                delete lstMstrSVMXCfgDta; //SDL-SVMX-DELETE-FLS-ENFORCED
            }
                
            if(lstToSaveTeam != null && lstToSaveTeam.size() > 0){
                //Insert lstToSaveTeam;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstToSaveTeam, COMM_SecurityUtils.Access.Createable)){
                    Insert lstToSaveTeam; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                    isSave = false;
                }
            }
                
            if(lstToSaveTerri != null && lstToSaveTerri.size() > 0){
                //Insert lstToSaveTerri;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstToSaveTerri, COMM_SecurityUtils.Access.Createable)){
                    Insert lstToSaveTerri; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                    isSave = false;
                }
            }
            
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.CONFIRM, '' + getTAG013() ));
            isSave = true;
            
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + ex.getMessage() ));
            isSave = false;
        }

    }
    
    public void quickSave()
    {
        saveData();
        if(isSave)
        {
            exeQuerry();
        }
    }
    
    public pageReference saveNClose()
    {
        saveData();
        if(isSave)
        {
            PageReference pageRef = new PageReference('/apex/CONF_ManageViews');
            pageRef.setRedirect(true);
            return pageRef; 
        }
        return null;
    }
    
    public pageReference cancel()
    {
       PageReference pageRef;
        if(RetURL != null && RetURL.length() > 0)
        {
            String tempRetURL = '/apex/CONF_ManageViews';  
            pageRef = new PageReference(tempRetURL);
        }
        //Security check
            //pageRef = new PageReference(RetURL);
        else
            pageRef = new PageReference('/apex/CONF_SetupHome');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public void SVMX_BackToTeam()
    {
        selectedTab = 'Team';
    
    }
    
    public void SVMX_BackToTerritory()
    {
        selectedTab = 'Territory';
    }
    
    
    
     
    
    //------------ Custom Labels-------------
    
    public String getHLPURL() {return System.label.CONF033_HLPURL2;}
    public String getTAG001() {return System.label.CONF033_TAG017;}//'Manage View Permissions'
    public String getTAG002() {return System.label.COMM001_TAG064;}//'Help'
    public String getTAG003() {return System.label.COMM001_TAG053;}//'Quick Save'
    public String getTAG004() {return System.label.COMM001_TAG054;}//'Save & Close'
    public String getTAG005() {return System.label.COMM001_TAG040;}//'Cancel'
    public String getTAG006() {return System.label.CONF033_TAG018;}//'Select View'
    public String getTAG012() {return System.label.COMM001_TAG041;}//'Processing...'
    public String getTAG013() {return System.label.COMM001_TAG058;}//'Record(s) Save Sucessfully'
    public String getTAG014() {return System.label.COMM002_TAG005;}//'--None--'
    
    
    public String getTAG017() {return System.label.CONF033_TAG014;}//'Service Team'
    public String getTAG018() {return System.label.CONF033_TAG015;}//'Territory'
    public String getTAG019() {return System.label.CONF033_TAG019;}//'Add Team'
    public String getTAG020() {return System.label.COMM001_TAG049;}//'Delete'
    public String getTAG021() {return System.label.CONF033_TAG021;}//'Assign To'
    public String getTAG022() {return System.label.COMM001_TAG057;}//'Are You Sure ?'
    public String getTAG023() {return System.label.CONF033_TAG022;}//'Search Service Team by entering keyword'
    public String getTAG024() {return System.label.COMM001_TAG068;}//'Go!'
    public String getTAG025() {return System.label.COMM001_TAG069;}//'Add Selected'
    public String getTAG026() {return System.label.COMM001_TAG050;}//'Please select at least one record to perform this action'
    public String getTAG027() {return System.label.COMM001_TAG052;}//'Record(s) Deleted Sucessfully'

    
    public String getTAG029() {return System.label.CONF033_TAG020;}//'Add Territory'
    public String getTAG030() {return System.label.CONF033_TAG023;}//'Search Territory by entering keyword'
    public String getTAG031() {return System.label.CONF033_TAG028;}//'Please enter a keyword'
    public String getTAG032() {return System.label.CONF033_TAG025;}//'Territory >>'
    public String getTAG033() {return System.label.CONF033_TAG026;}//'<< Service Team'
}