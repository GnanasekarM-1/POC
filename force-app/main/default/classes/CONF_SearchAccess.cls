public with sharing class CONF_SearchAccess 
{
    public boolean IsRender = false;
    public boolean getIsRender(){return this.IsRender;}
    public RecordType Rtype_SearchPermission;
    
    public string selectedProfile = null;
    public string getselectedProfile(){return this.selectedProfile;}
    public void setselectedProfile(string str){this.selectedProfile = str;}
    
    public ServiceMax_Config_Data__c CurrentprofileAccess = new ServiceMax_Config_Data__c();
    public ServiceMax_Config_Data__c getCurrentprofileAccess(){return this.CurrentprofileAccess;}
    public void setCurrentprofileAccess(ServiceMax_Config_Data__c ConfData){this.CurrentprofileAccess = ConfData;}
    public boolean IsHdrMsg { get; set; }
    public List<String> SelectedSearchSelctd { get; set; }
    public List<String> availableSearchSelctd { get; set; }
    
    public List<SelectOption> SelectedSearchOptns = new List<SelectOption>();
    public List<SelectOption> getSelectedSearchOptns(){return SelectedSearchOptns;}
    public void setSelectedSearchOptns(List<SelectOption> AvailSearch){ this.SelectedSearchOptns = AvailSearch; }
    public List<SelectOption> AvailableProfilesOptns = new List<SelectOption>();
    public List<SelectOption> getAvailableSvmxGrpProfiles(){return AvailableProfilesOptns;}
    
    public  LIST<SVMXC__ServiceMax_Processes__c>  lstSearchProcesses = new LIST<SVMXC__ServiceMax_Processes__c>();
    public  LIST<SVMXC__ServiceMax_Processes__c>  getlstSearchProcesses = new LIST<SVMXC__ServiceMax_Processes__c>();
    public Map<String,String> AvailSearchIdNameMap = new Map<String,String>();
    public Map<String,String> AvailSearchMap = new Map<String,String>();
    public List<SelectOption> AvailableSearchOptns = new List<SelectOption>();
    public List<SelectOption> getAvailableSearchOptns(){return AvailableSearchOptns;}
    public Map<String,String> SelSearchMap = new Map<String,String>();
    
    /***************** Constructor ************************/
    public CONF_SearchAccess()
    {
        
        /******* Create new record type for search access permission. ****************/
        Rtype_SearchPermission = [Select Id,Name from RecordType where Name = 'Search Access' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1 ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstSearchProcesses = [select SVMXC__Select__c, SVMXC__ProcessID__c, SVMXC__Dispatch_Process_Status__c, LastModifiedBy.LastModifiedDate, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c ='Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Processes__c ObjSearch : lstSearchProcesses)
        {
            AvailSearchIdNameMap.put(ObjSearch.Id,ObjSearch.SVMXC__Name__C);
        }
        AvailSearchMap.putAll(AvailSearchIdNameMap);
        AvailableSearchOptns = new List<SelectOption>();
      
        //Query for all group profiles present in database
        List<ServiceMax_Config_Data__c> LstAvailableProfiles = new List<ServiceMax_Config_Data__c>();
        LstAvailableProfiles = Database.query('Select Id, SVMXC__PROFILE_NAME__C, SVMXC__Description__C From ServiceMax_Config_Data__c Where RecordType.Name = \'Configuration Profile\' And SVMXC__CONFIGURATION_TYPE__C = \'Group\'');

        //Loop through resultant group profile records
        Map<String, String> AllGrpProfilesMap = new Map<String, String>();
        Map<String,String> AvailProfMap = new Map<String,String>();
        Map<Id,set<Id>> ProfIdSearchDefMap = new Map<Id,set<Id>>();
        for(ServiceMax_Config_Data__c Rec :LstAvailableProfiles)
        {
            ProfIdSearchDefMap.put(Rec.Id, new set<Id>());
            AllGrpProfilesMap.put(Rec.Id,Rec.SVMXC__Profile_Name__c);
        }
        AvailProfMap.putAll(AllGrpProfilesMap);
        
        AvailableProfilesOptns.add(new SelectOption('SVMX.NONE',getTAG006()));
        for(String AvailProf : AvailProfMap.keyset())
        {
            AvailableProfilesOptns.add(new SelectOption(AvailProf, AvailProfMap.get(AvailProf)));
        }
        
        List<SVMXC__ServiceMax_Config_Data__c> LstPermissionRecs = [Select SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordTypeId =: Rtype_SearchPermission.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Config_Data__c ConfigObj : LstPermissionRecs)
        {
            if(ProfIdSearchDefMap.containsKey(ConfigObj.SVMXC__Access_Configuration_Profile__c))
            {
                ProfIdSearchDefMap.get(ConfigObj.SVMXC__Access_Configuration_Profile__c).add(ConfigObj.SVMXC__Dispatch_Process__c);
            }
            else
            {
                set<Id> tempIdsLst = new set<Id>();
                tempIdsLst.add(ConfigObj.SVMXC__Dispatch_Process__c);
                ProfIdSearchDefMap.put(ConfigObj.SVMXC__Access_Configuration_Profile__c,tempIdsLst);
            }
        }
    }
    
    /******************* Onchange of profile Method**********************/
    public void rerenderAvailableSearchDef()
    {
        if(selectedProfile != 'SVMX.NONE')
        {
            IsRender = true;
            List<SVMXC__ServiceMax_Config_Data__c> LstPermissionRecs = [Select SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordTypeId =: Rtype_SearchPermission.Id AND SVMXC__Access_Configuration_Profile__c =:selectedProfile]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(LstPermissionRecs != null && LstPermissionRecs.size() > 0)
            {
                Set<String> setAvailSrchSlctd = new Set<String>();
                for(SVMXC__ServiceMax_Config_Data__c ConfigObj : LstPermissionRecs)
                    setAvailSrchSlctd.add(ConfigObj.SVMXC__Dispatch_Process__c);
                List<SVMXC__ServiceMax_Processes__c> lstSearchProcesses = new List<SVMXC__ServiceMax_Processes__c>();
                lstSearchProcesses = [select SVMXC__ProcessID__c, SVMXC__Name__C from  SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c ='Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH' And Id =: setAvailSrchSlctd]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                setAvailSrchSlctd.clear();
                setAvailSrchSlctd = new Set<String>();
                for(SVMXC__ServiceMax_Processes__c SearchObj : lstSearchProcesses)
                    setAvailSrchSlctd.add(SearchObj.Id);
                List<SVMXC__ServiceMax_Processes__c> lstAvailSearchProcesses = new List<SVMXC__ServiceMax_Processes__c>();
                lstAvailSearchProcesses = [select SVMXC__Select__c, SVMXC__ProcessID__c, SVMXC__Dispatch_Process_Status__c, LastModifiedBy.LastModifiedDate, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c ='Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH' And Id !=: setAvailSrchSlctd]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                AvailableSearchOptns.clear();
                for(SVMXC__ServiceMax_Processes__c ObjSearch : lstAvailSearchProcesses)
                {
                    AvailableSearchOptns.add(new SelectOption(ObjSearch.Id, ObjSearch.SVMXC__Name__C));
                }
                //Addition to right
                SelectedSearchOptns.clear();
                for(SVMXC__ServiceMax_Processes__c SearchObj : lstSearchProcesses)
                {
                    SelectedSearchOptns.add(new SelectOption(SearchObj.Id, SearchObj.SVMXC__Name__C));
                }
            }
            else
            {
                lstSearchProcesses = [select SVMXC__Select__c, SVMXC__ProcessID__c, SVMXC__Dispatch_Process_Status__c, LastModifiedBy.LastModifiedDate, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c ='Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(SVMXC__ServiceMax_Processes__c ObjSearch : lstSearchProcesses)
                {
                    AvailSearchIdNameMap.put(ObjSearch.Id,ObjSearch.SVMXC__Name__C);
                }
                AvailSearchMap.putAll(AvailSearchIdNameMap);
                AvailableSearchOptns = new List<SelectOption>();
                for(String AvailSearch : AvailSearchMap.keyset())
                {
                    AvailableSearchOptns.add(new SelectOption(AvailSearch, AvailSearchMap.get(AvailSearch)));
                }
                SelectedSearchOptns.clear();
            }
        }
        else
            IsRender = false;
        
    }
    
    
    /******************* Quicksave Method**********************/
    public void Quicksave()
    {
        IsHdrMsg = false;
        if(selectedProfile != 'SVMX.NONE')
        {
            List<SVMXC__ServiceMax_Config_Data__c> PermissionRecLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SelectOption option : SelectedSearchOptns)
            { 
                SVMXC__ServiceMax_Config_Data__c PermissionRec = new SVMXC__ServiceMax_Config_Data__c();
                PermissionRec.RecordTypeId = Rtype_SearchPermission.Id;
                PermissionRec.SVMXC__Dispatch_Process__c = option.getValue();
                PermissionRec.SVMXC__Access_Configuration_Profile__c = selectedProfile;
                PermissionRecLst.add(PermissionRec);
            }
            List<SVMXC__ServiceMax_Config_Data__c> LstPermissionRecsToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
            if(selectedProfile != null && selectedProfile != 'SVMX.NONE' && selectedProfile.length() > 0)
                LstPermissionRecsToDelete = Database.query('Select SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Search Access\' AND SVMXC__Access_Configuration_Profile__c = : selectedProfile');
            try
            {
                if(LstPermissionRecsToDelete!= null && LstPermissionRecsToDelete.size() > 0)
                    Delete LstPermissionRecsToDelete; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(PermissionRecLst != null && PermissionRecLst.size()>0){
					//upsert PermissionRecLst;
					if(COMM_SecurityUtils.getInstance().verifyFieldAccess(PermissionRecLst, COMM_SecurityUtils.Access.Upsertable)){
						upsert PermissionRecLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
					}
					else{
						IsHdrMsg = true;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
					}
				}
                IsHdrMsg = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, getTag007()));
            }
            catch(exception ex)
            {
                IsHdrMsg = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
            }
        }
    }
    /******************* Save and Close Method**********************/
    public pagereference SaveNClose()
    {
        Quicksave();
        PageReference pageref1= new PageReference('/apex/CONF_ManageSearchConfiguration');
        pageRef1.setRedirect(true);
        return pageref1;    
    }
    /******************* Cancel Method**********************/
    public pagereference CancelSearch()
    {
        PageReference pageref1= new PageReference('/apex/CONF_ManageSearchConfiguration');
        pageRef1.setRedirect(true);
        return pageref1;        
    }
    
    //Generic Methods
    public pagereference OnAddsearch()
    {
        IsHdrMsg = false;
        if( AvailSearchMap.size() > 0 )
        {
            Set<String> setAvailSrchSlctd = new Set<String>();
            setAvailSrchSlctd.addAll(availableSearchSelctd);
            //Addition to right
            for(String SearchObj :availableSearchSelctd)
            {
                SelectedSearchOptns.add(new SelectOption(SearchObj, AvailSearchIdNameMap.get(SearchObj)));
            }
            //Removal from left
            List<SelectOption> tempOptnsList = new List<SelectOption>();
            for(integer i=0;i<AvailableSearchOptns.size();i++)
            {
                if(setAvailSrchSlctd.contains(AvailableSearchOptns[i].getValue()))
                    continue;
                tempOptnsList.add(AvailableSearchOptns[i]);
            }
            AvailableSearchOptns.clear();
            if(tempOptnsList != null && tempOptnsList.size() > 0)
                AvailableSearchOptns.addAll(tempOptnsList);
        }
        return null;
    }
    
  
    public pagereference OnRemSearch()
    {
        IsHdrMsg = false;
        if(SelectedSearchOptns.size() > 0 )
        {
            Set<String> setSelectedSrch = new Set<String>();
            setSelectedSrch.addAll(SelectedSearchSelctd);

            //Addition to left
            for(String SearchObj : SelectedSearchSelctd)
            {
              AvailableSearchOptns.add(new SelectOption(SearchObj, AvailSearchIdNameMap.get(SearchObj)));
            }
            //Removal from right
            List<SelectOption> tempOptnsList = new List<SelectOption>();
            for(integer i=0;i<SelectedSearchOptns.size();i++)
            {
              if(setSelectedSrch.contains(SelectedSearchOptns[i].getValue()))
                continue;
              tempOptnsList.add(SelectedSearchOptns[i]);
            }
            SelectedSearchOptns.clear();
            if(tempOptnsList != null && tempOptnsList.size() > 0)
              SelectedSearchOptns.addAll(tempOptnsList);
        }
        return null;
    }
    
    public String getTag001(){ return system.label.CONF031_TAG022;}	//'Profile Access To Search Configurations'
    public String getTag002(){ return system.label.COMM001_TAG041;}	//'Processing...'
    public String getTAG003(){return system.label.COMM001_TAG053;}	//'Quick Save'
    public String getTAG004(){return system.label.COMM001_TAG054;}	//'Save & Close' 
    public String getTAG005(){return system.label.COMM001_TAG040;}	//'Cancel' 
    public String getTAG006(){return system.label.COMM002_TAG005;}	//'--None--'
    public String getTag007(){ return system.label.COMM001_TAG058;}	//'Record(s) Saved.
    public String getTAG008(){return system.label.CONF031_TAG023;}	//'Select ServiceMax Profile' 
    public String getTAG009(){return system.label.CONF031_TAG024;}	//'Available Searches' 
    public String getTAG010(){return system.label.CONF031_TAG025;}	//'Selected Searches'
    
}