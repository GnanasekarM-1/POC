public with sharing class CONF_ServiceFlowAccess {
    public List<SVMXC__ServiceMax_Processes__c> ProcessViewLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> ProcessStandaloneCreateLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> TempProcessViewLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> SVMXprofiles = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> ProfileAccessLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> AccessLstViewAssigned = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> AccessLstCreateAssigned = new List<SVMXC__ServiceMax_Config_Data__c>();
    public Map<String,String> mapfieldApiLabel_Name = new Map<String,String>();
    public Map<String,String> mapfieldApiName_Label = new Map<String,String>();
    public Map<String,Id> mapObject_Process = new Map<String,Id>();
    public set<string> tempLstView = new set<string>();
    public List<String> ViewProcess = new List<String>();
    public List<String> ViewCreateProcess = new List<String>();
    public List<String> ProcessAssigned = new List<String>();
    public List<String> ProcessCreateAssigned = new List<String>();
    public List<string> toDeleteView = new List<string>();
    public List<string> toDeleteCreate = new List<string>();
    public boolean Render = false;
    public boolean ShowWarning = false;
    public boolean ShowButton = false;
    public boolean ShowMessage1 = false;
    public boolean ShowMessage2 = false;
    public boolean alreadySaved = false;
    public string SelectedProfile='';
    public String SelectedSourceObject = '';
    public string LastSelectedObject ='';
    
    //------------------------------------------- Getter Setter Methods --------------------------------------------------------------
    public List<SVMXC__ServiceMax_Processes__c> getProcessViewLst(){return this.ProcessViewLst;}
    public void setProcessViewLst(List<SVMXC__ServiceMax_Processes__c> o){this.ProcessViewLst = o;}
    public List<SVMXC__ServiceMax_Processes__c> getProcessStandaloneCreateLst(){return this.ProcessStandaloneCreateLst;}
    public void setProcessStandaloneCreateLst(List<SVMXC__ServiceMax_Processes__c> o){this.ProcessStandaloneCreateLst = o;}
    public List<SVMXC__ServiceMax_Config_Data__c> getSVMXprofiles(){return this.SVMXprofiles;}
    public void setSVMXprofiles(List<SVMXC__ServiceMax_Config_Data__c> o){this.SVMXprofiles = o;}
    public List<SVMXC__ServiceMax_Config_Data__c> getProfileAccessLst(){return this.ProfileAccessLst;}
    public void setProfileAccessLst(List<SVMXC__ServiceMax_Config_Data__c> o){this.ProfileAccessLst = o;}
    public String getSelectedSourceObject(){return SelectedSourceObject;}
    public void setSelectedSourceObject(string val){SelectedSourceObject = val;}
    public List<String> getViewProcess(){return ViewProcess;}
    public void setViewProcess(List<String> val){ViewProcess = val;}
    public List<String> getViewCreateProcess(){return ViewCreateProcess;}
    public void setViewCreateProcess(List<String> val){ViewCreateProcess = val;}
    public List<String> getProcessAssigned(){return ProcessAssigned;}
    public void setProcessAssigned(List<String> val){ProcessAssigned = val;}
    public List<String> getProcessCreateAssigned(){return ProcessCreateAssigned;}
    public void setProcessCreateAssigned(List<String> val){ProcessCreateAssigned = val;}
    public List<SelectOption> sourceObjectsOptns = new  List<SelectOption>();
    public List<SelectOption> getObjectsWithAction(){return sourceObjectsOptns;}
    public List<SelectOption> AvalViewProcess = new  List<SelectOption>();
    public List<SelectOption> getAvalViewProcess(){return AvalViewProcess;}
    public boolean getRender(){return this.Render;}
    public void setRender(boolean b){this.Render = b;}
    public List<SelectOption> AvalCreateProcess = new  List<SelectOption>();
    public List<SelectOption> getAvalCreateProcess(){return AvalCreateProcess;}
    public List<SelectOption> AssignedViewProcess = new  List<SelectOption>();
    public List<SelectOption> getAssignedViewProcess(){return AssignedViewProcess;}
    public List<SelectOption> AssignedCreateProcess = new  List<SelectOption>();
    public List<SelectOption> getAssignedCreateProcess(){return AssignedCreateProcess;}
    public String getSelectedProfile(){return SelectedProfile;}
    public void setSelectedProfile(string val){SelectedProfile = val;}
    public List<SelectOption> profileOptns = new  List<SelectOption>();
    public List<SelectOption> getProfiles(){return profileOptns;}
    public boolean getShowButton(){return this.ShowButton;}
    public void setShowButton(boolean b){this.ShowButton = b;}
    public boolean getShowMessage1(){return this.ShowMessage1;}
    public void setShowMessage1(boolean b){this.ShowMessage1 = b;}
    public boolean getShowMessage2(){return this.ShowMessage2;}
    public void setShowMessage2(boolean b){this.ShowMessage2 = b;}
    public SVMXC__ServiceMax_Processes__c SVMXEventViewProcess = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c SVMXEventCreateProcess = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c SFEventViewProcess = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c SFEventCreateProcess = new SVMXC__ServiceMax_Processes__c();
    
    //------------------------------------------- Constructor / Onload --------------------------------------------------------------
    public CONF_ServiceFlowAccess()
    {
        retrieveProfiles();
        Render = false;
        sourceObjectsOptns.add(new SelectOption(getTAG016(),getTAG016()));
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        allObjs = Schema.getGlobalDescribe();
        for(String s : allObjs.keyset())
        {
            Schema.DescribeSObjectResult objDesc = allObjs.get(s).getDescribe();
            mapfieldApiLabel_Name.put(objDesc.getName(),objDesc.getLabel());
            mapfieldApiName_Label.put(objDesc.getLabel(),objDesc.getName());
        }
        
        TempProcessViewLst = [Select Id, SVMXC__Process__c, SVMXC__Source_Object_Name__c, SVMXC__Type__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c =: 'Process Node Objects' and SVMXC__Type__c =: 'TARGET' and SVMXC__Process__r.SVMXC__Purpose__c in ('VIEW RECORD','STANDALONE CREATE') AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN ('SVMXEVT_005', 'SVMXEVT_003')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(TempProcessViewLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c temp : TempProcessViewLst)
            {
                mapObject_Process.put(temp.SVMXC__Source_Object_Name__c, temp.Id);
            }
            system.debug('1. Map of objects and related ServiceMax Process Ids for View & Standalone Create processes: '+ mapObject_Process);
            
            for(string s : mapObject_Process.keyset())
            {
                if(mapfieldApiLabel_Name.get(s) != null && mapfieldApiLabel_Name.get(s) != null)
                	sourceObjectsOptns.add(new SelectOption(mapfieldApiLabel_Name.get(s),mapfieldApiLabel_Name.get(s)));
            }
        }
        sourceObjectsOptns = sortingSelectOption(sourceObjectsOptns);
     }
    
    //------------------------------------------- Retrieving all the Profiles --------------------------------------------------------------
    public void retrieveProfiles()
    {
        SVMXprofiles = [Select Id, SVMXC__Select__c, SVMXC__Profile_Name__c, SVMXC__Configuration_Type__c, SVMXC__Description__c, LastModifiedDate From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Configuration Profile' and SVMXC__Configuration_Type__c = 'Group']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        profileOptns.add(new SelectOption(getTAG021(),getTAG021()));
        for(SVMXC__ServiceMax_Config_Data__c profile : SVMXprofiles)
        {
            profileOptns.add(new SelectOption(profile.Id,profile.SVMXC__Profile_Name__c));
        }
        profileOptns = sortingSelectOption(profileOptns);
    }
    
    //-------------------------------------- On changing the Selected Profile in the PickList -------------------------------------------------
    public PageReference OnChangeProfile()
    {
        if(selectedProfile != getTAG021())
            OnSelectProfile();
        else
            Render = false;
        return null;
    }
    
    //------------------------------------------- On Selection of the Profile --------------------------------------------------------------
    public PageReference OnSelectProfile()
    {
        alreadySaved = false;
        SelectedSourceObject = getTAG016();
        LastSelectedObject = SelectedSourceObject;
        fetchProcesses();
        return null;
    }
    
    //----------------------------------- Querying for View Record & Standalone Create Processes according to the Selected Object ------------------------------------------------
    public void fetchProcesses()
    {
        Render = false;
        ProfileAccessLst.clear();
        ProcessViewLst.clear();
        ProcessStandaloneCreateLst.clear();
        AssignedViewProcess.clear();
        AvalViewProcess.clear();
        AssignedCreateProcess.clear();
        AvalCreateProcess.clear();
        AccessLstViewAssigned.clear();
        AccessLstCreateAssigned.clear();
        
        /* Get the list of View & Standalone Create processes for all objects (TAG016 = ALL) */
        if(SelectedSourceObject != getTAG016())
        {
            ProcessViewLst = [Select Id, SVMXC__Select__c, SVMXC__Name__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'VIEW RECORD' and Id IN: tempLstView]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //system.debug('2. View Record process list: ' + ProcessViewLst);
            
            ProcessStandaloneCreateLst = [Select Id, SVMXC__Select__c, SVMXC__Name__c, SVMXC__Purpose__c, SVMXC__Target_Object_Name__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'STANDALONE CREATE' and Id IN: tempLstView]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //system.debug('3. Standalone Create process list: ' + ProcessStandaloneCreateLst);
        }

        /* Get the list of View & Standalone Create processes for the selected object */
        else
        {
            ProcessViewLst = [Select Id, SVMXC__Select__c, SVMXC__Name__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__ProcessID__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'VIEW RECORD' AND SVMXC__ProcessID__c != 'SVMXEVT_005']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //system.debug('4. View Record process list: ' + ProcessViewLst);
            SVMXEventViewProcess = [Select Id, SVMXC__Name__c, SVMXC__Purpose__c, SVMXC__ProcessID__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'VIEW RECORD' AND SVMXC__ProcessID__c = 'SVMXEVT_005' AND SVMXC__isPrivate__c = true AND SVMXC__isStandard__c = true limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            SFEventViewProcess = [Select Id, SVMXC__Name__c, SVMXC__Purpose__c, SVMXC__ProcessID__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'VIEW RECORD' AND SVMXC__ProcessID__c = 'EVT_005' AND SVMXC__isPrivate__c = true AND SVMXC__isStandard__c = true limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            ProcessStandaloneCreateLst = [Select Id, SVMXC__Select__c, SVMXC__Name__c, SVMXC__Purpose__c, SVMXC__Target_Object_Name__c, SVMXC__ProcessID__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'STANDALONE CREATE' AND SVMXC__ProcessID__c != 'SVMXEVT_003']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //system.debug('5. Standalone Create process list: ' + ProcessStandaloneCreateLst);
            SVMXEventCreateProcess =[Select Id, SVMXC__Name__c, SVMXC__Purpose__c, SVMXC__ProcessID__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'STANDALONE CREATE' AND SVMXC__ProcessID__c = 'SVMXEVT_003' AND SVMXC__isPrivate__c = true AND SVMXC__isStandard__c = true limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            SFEventCreateProcess = [Select Id, SVMXC__Name__c, SVMXC__Purpose__c, SVMXC__ProcessID__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'STANDALONE CREATE' AND SVMXC__ProcessID__c = 'EVT_003' AND SVMXC__isPrivate__c = true AND SVMXC__isStandard__c = true limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        
        //==============Querying the Config Data of Service Flow Access record Types for the selected profile==============
        ProfileAccessLst = [Select Id,SVMXC__Access_Configuration_Profile__c,SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Access_Configuration_Profile__c =: selectedProfile and SVMXC__RecordType_Name__c =: 'Service Flow Access']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        //==============Adding the View Process list values for the Available list and Assigned list====================
        if(ProcessViewLst.size()>0)
        {
            for(SVMXC__ServiceMax_Processes__c tempVP: ProcessViewLst)
            {
                if(ProfileAccessLst.size()>0)
                {
                    Boolean isSet = false;
                    for(SVMXC__ServiceMax_Config_Data__c access: ProfileAccessLst)
                    {
                    	system.debug('Access = ' + access);
                        if(tempVP.Id == access.SVMXC__Dispatch_Process__c)
                        {
                            isSet = true;
                            AssignedViewProcess.add(new selectOption(tempVP.id, tempVP.SVMXC__Name__c));
                            AccessLstViewAssigned.add(access);
                            break;
                        }
                    }
                    if(isSet == false)
                    {
                        AvalViewProcess.add(new selectOption(tempVP.id, tempVP.SVMXC__Name__c));
                    }
                }
                else
                {
                    AvalViewProcess.add(new selectOption(tempVP.id, tempVP.SVMXC__Name__c));
                }
            }
        }
        AvalViewProcess = sortingSelectOption(AvalViewProcess);
        AssignedViewProcess = sortingSelectOption(AssignedViewProcess);
        
        //==============Adding the Standalone Create Process list values for the Available list and Assigned list====================
        if(ProcessStandaloneCreateLst.size()>0)
        {
            for(SVMXC__ServiceMax_Processes__c tempVP: ProcessStandaloneCreateLst)
            {
                if(ProfileAccessLst.size()>0)
                {
                    Boolean isSet = false;
                    for(SVMXC__ServiceMax_Config_Data__c access: ProfileAccessLst)
                    {
                        if(tempVP.Id == access.SVMXC__Dispatch_Process__c)
                        {
                            isSet = true;
                            AssignedCreateProcess.add(new selectOption(tempVP.id, tempVP.SVMXC__Name__c));
                            AccessLstCreateAssigned.add(access);
                            break;
                        }
                    }
                    if(isSet == false)
                    {
                        AvalCreateProcess.add(new selectOption(tempVP.id, tempVP.SVMXC__Name__c));
                    }
                }
                else
                {
                    AvalCreateProcess.add(new selectOption(tempVP.id, tempVP.SVMXC__Name__c));
                }
            }
        }
        Render = true;
        AvalCreateProcess = sortingSelectOption(AvalCreateProcess);
        AssignedCreateProcess = sortingSelectOption(AssignedCreateProcess);
    }
    
    //----------------------------------- On change of the Selected Object in the PickList -----------------------------------------
    public void onChngObject()
    {
        if(ShowWarning == true)
        {
            toDeleteView.clear();
            toDeleteCreate.clear();
            ShowMessage2 = true;
            ShowMessage1 = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,getTAG022(),''));
            ShowButton = true;
            return;
        }
        else
        {
            tempLstView.clear();
            for(SVMXC__ServiceMax_Processes__c temp : TempProcessViewLst)
            {
                if(SelectedSourceObject == mapfieldApiLabel_Name.get(temp.SVMXC__Source_Object_Name__c))
                {
                    string tempStr = temp.SVMXC__Process__c;
                    tempLstView.add(tempStr);
                }
            }
            toDeleteView.clear();
            toDeleteCreate.clear();
            alreadySaved = false;
            fetchProcesses();
            LastSelectedObject = SelectedSourceObject;
        }
    }
    
    public void onClickYes()
    {
        ShowWarning = false;
        ShowButton = false;
        ShowMessage2 = false;
        onChngObject();
    }
    
    public void onClickNo()
    {
        ShowButton = false;
        ShowMessage2 = false;
        SelectedSourceObject = LastSelectedObject;
    }
    
    //-----------------Moving the View Process list values from Available list to Assigned list-------------------
    public PageReference OnAddViewProcess()
    {
        List<selectOption> tempOption = new List<selectOption>();
        for(SelectOption availableOptions: AvalViewProcess)
        {
            boolean isSet = false;
            for(String selectedViewProcess: ViewProcess)
            {
                if(toDeleteView.size()>0)
                {
                    for(integer i=0; i< toDeleteView.size(); i++)
                    {
                        if(selectedViewProcess == toDeleteView[i])
                        	toDeleteView.remove(i);
                        break;
                    }
                }
                if(selectedViewProcess == availableOptions.getValue())
                {
                    isSet = true;
                    AssignedViewProcess.add(availableOptions);
                    break;
                }
            }
            if(isSet == false)
            {
                tempOption.add(availableOptions);
            }
        }
        AvalViewProcess = tempOption;
        ShowWarning = true;
        alreadySaved = false;
        return null;
    }
    
    //-----------------------Moving the View Process list values from Assigned list to Available list----------------------
    public PageReference OnRemoveViewProcess()
    {
        List<selectOption> tempOption = new List<selectOption>();
        
        for(SelectOption availableOptions: AssignedViewProcess)
        {
            boolean isSet = false;
            for(String selectedViewProcess: ProcessAssigned)
            {
                if(selectedViewProcess == availableOptions.getValue())
                {
                    isSet = true;
                    AvalViewProcess.add(availableOptions);
                    toDeleteView.add(selectedViewProcess);
                    break;
                }
            }
            if(isSet == false)
            {
                tempOption.add(availableOptions);
            }
        }
        
        AssignedViewProcess = tempOption;
        ShowWarning = true;
        alreadySaved = false;
        return null;
    }
    
    //-------------Moving the Standalone Create Process list values from Available list to Assigned list------------
    public PageReference OnAddCreateProcess()
    {
        List<selectOption> tempOption = new List<selectOption>();
        
        for(SelectOption availableOptions: AvalCreateProcess)
        {
            boolean isSet = false;
            for(String selectedViewProcess: ViewCreateProcess)
            {
                if(toDeleteCreate.size()>0)
                {
                    for(integer i=0; i< toDeleteCreate.size(); i++)
                    {
                        if(selectedViewProcess == toDeleteCreate[i])
                        toDeleteCreate.remove(i);
                        break;
                    }
                }
                if(selectedViewProcess == availableOptions.getValue())
                {
                    isSet = true;
                    AssignedCreateProcess.add(availableOptions);
                    break;
                }
            }
            if(isSet == false)
            {
                tempOption.add(availableOptions);
            }
        }
        AvalCreateProcess = tempOption;
        ShowWarning = true;
        alreadySaved = false;
        return null;
    }
    
    //----------------Moving the Standalone Create Process list values from Assigned list to Available list------------
    public PageReference OnRemoveCreateProcess()
    {
        List<selectOption> tempOption = new List<selectOption>();
        
        for(SelectOption availableOptions: AssignedCreateProcess)
        {
            boolean isSet = false;
            for(String selectedViewProcess: ProcessCreateAssigned)
            {
                if(selectedViewProcess == availableOptions.getValue())
                {
                    isSet = true;
                    AvalCreateProcess.add(availableOptions);
                    toDeleteCreate.add(selectedViewProcess);
                    break;
                }
            }
            if(isSet == false)
            {
                tempOption.add(availableOptions);
            }
        }
        
        AssignedCreateProcess = tempOption;
        ShowWarning = true;
        alreadySaved = false;
        return null;
    }
    
    //------------------------------------- Method to sort the Options of the PickList --------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList) {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }


    //------------------------------------------- Method To Cancel --------------------------------------------------------------   
    public pageReference cancel()
    {
         pageReference pageref1 = Page.CONF_SetupHome;
         return pageref1;
    }
    
    //------------------------------------------- Method To Quick Save --------------------------------------------------------------   
    public pageReference quickSave()
    {
        if(selectedProfile != getTAG021())
        {
            if(alreadySaved == false)
            {
                ShowMessage1 = true;
                ShowMessage2 = false;
                save();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG017(),''));
                fetchProcesses();
            }
        }
        return null;
    }
    
    //------------------------------------------- Method To actually Save the Data -------------------------------------------------------------- 
    public void save()
    {
        set<Id> deletedIds = new set<Id>();
        
        if(SelectedSourceObject == getTAG016()) // TAG016 = ALL
        {
            if(ProfileAccessLst != null || ProfileAccessLst.size() > 0) {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    
                    delete ProfileAccessLst; //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }            
        }
        else
        {
            List<SVMXC__ServiceMax_Config_Data__c> lstProcessAccessToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
            
            //==================Deleting removed View Processes==================
            for(SVMXC__ServiceMax_Config_Data__c data : AccessLstViewAssigned)
            {
                for(String selectedViewProcess: toDeleteView)
                {
                    if(selectedViewProcess == data.SVMXC__Dispatch_Process__c)
                    {
                        if(!deletedIds.contains(data.Id))
                        {
                            deletedIds.add(data.Id);
                            lstProcessAccessToDelete.add(data);
                        }
                        break;
                    }
                }
            }
            //system.debug('6. List of View Processes to be removed: ' + lstProcessAccessToDelete);
            
            //==================Deleting removed Standalone Create Processes==================
            for(SVMXC__ServiceMax_Config_Data__c data : AccessLstCreateAssigned)
            {
                for(String selectedViewProcess: toDeleteCreate)
                {
                    if(selectedViewProcess == data.SVMXC__Dispatch_Process__c)
                    {
                        if(!deletedIds.contains(data.Id))
                        {
                            deletedIds.add(data.Id);
                            lstProcessAccessToDelete.add(data);
                        }
                        break;
                    }
                }
            }
            //system.debug('7. List of View & Standalone Create Processes to be removed: ' + lstProcessAccessToDelete);

            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                
                delete lstProcessAccessToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        
        String ActionRTypeId = '';
        RecordType Action_Rtype;
         
         //========================================== Querying the Record Types for the Service Flow Access =============================================
        Action_Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Service Flow Access' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ActionRTypeId = Action_Rtype.Id;

        //===============Update / Add View Processes assigned==============
        List<SVMXC__ServiceMax_Config_Data__c> lstConfDataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        for(SelectOption availableOptions: AssignedViewProcess)
        {
            SVMXC__ServiceMax_Config_Data__c configAccess = new SVMXC__ServiceMax_Config_Data__c();
            configAccess.RecordTypeId = ActionRTypeId;
            configAccess.SVMXC__Access_Configuration_Profile__c = selectedProfile;
            configAccess.SVMXC__Dispatch_Process__c = availableOptions.getValue();
            lstConfDataToSave.add(configAccess);
            //If Standard View Event Process is assigned then also assign Standard View SVMX Event
            if(SFEventViewProcess.Id == availableOptions.getValue())
            {
	            SVMXC__ServiceMax_Config_Data__c configRec = new SVMXC__ServiceMax_Config_Data__c();
	            configRec.RecordTypeId = ActionRTypeId;
	            configRec.SVMXC__Access_Configuration_Profile__c = selectedProfile;
	            configRec.SVMXC__Dispatch_Process__c = SVMXEventViewProcess.Id;
	            lstConfDataToSave.add(configRec);
            }
        }

        //===============Update / Add Standalone Create Processes assigned==============
        for(SelectOption availableOptions: AssignedCreateProcess)
        {
            SVMXC__ServiceMax_Config_Data__c configAccess = new SVMXC__ServiceMax_Config_Data__c();
            configAccess.RecordTypeId = ActionRTypeId;
            configAccess.SVMXC__Access_Configuration_Profile__c = selectedProfile;
            configAccess.SVMXC__Dispatch_Process__c = availableOptions.getValue();
            lstConfDataToSave.add(configAccess);
            //If Standard Create Event Process is assigned then also assign Standard Create SVMX Event 
            if(SFEventCreateProcess.Id == availableOptions.getValue())
            {
	            SVMXC__ServiceMax_Config_Data__c configRec = new SVMXC__ServiceMax_Config_Data__c();
	            configRec.RecordTypeId = ActionRTypeId;
	            configRec.SVMXC__Access_Configuration_Profile__c = selectedProfile;
	            configRec.SVMXC__Dispatch_Process__c = SVMXEventCreateProcess.Id;
	            lstConfDataToSave.add(configRec);
            }
        }
        
		if(lstConfDataToSave != null && lstConfDataToSave.size() > 0){
			//upsert lstConfDataToSave;
			if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfDataToSave, COMM_SecurityUtils.Access.Upsertable)){
				upsert lstConfDataToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			}
			else{
				throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
			}
		}
        
        alreadySaved = true;
        ShowWarning = false;
        ShowButton = false;
        toDeleteView.clear();
        toDeleteCreate.clear();
    }
    
    //------------------------------------------- Getter Setter for the TAGS -------------------------------------------------------------- 
    
    public String getTAG001(){return system.label.CONF020_TAG001;}//Service Flow Access Configuration
    public String getTAG002(){return system.label.CONF020_TAG002;}//Save
    public String getTAG004(){return system.label.CONF020_TAG003;}//Back To Setup Home
    public String getTAG009(){return system.label.CONF020_TAG009;}//Select Object:
    public String getTAG010(){return system.label.CONF020_TAG010;}//
    public String getTAG011(){return system.label.CONF020_TAG011;}//Available SFM Processes
    public String getTAG012(){return system.label.CONF020_TAG012;}//Assigned SFM Processes
    public String getTAG013(){return system.label.CONF020_TAG013;}//Select SFM Standalone Create Process from Available list and move it to the Assigned list.
    public String getTAG014(){return system.label.CONF020_TAG014;}//Yes
    public String getTAG015(){return system.label.CONF020_TAG015;}//No
    public String getTAG016(){return system.label.CONF020_TAG016;}//--ALL--
    public String getTAG017(){return system.label.CONF020_TAG017;}//Saved successfully
    public String getTAG018(){return system.label.CONF020_TAG004;}//Select Profile:
    public String getTAG019(){return system.label.CONF020_TAG005;}//Processing...
    public String getHlpUrl(){return system.label.CONF020_HLPURL;}//http://www.servicemax.com
    public String getTAG020(){return system.label.CONF020_TAG006;}//Service Flow Access Help
    public String getTAG021(){return system.label.CONF020_TAG007;}//--None--
    public String getTAG022(){return system.label.CONF020_TAG008;}//Changes made have not been saved. Do you want to continue?
}