public with sharing class CONF_ManageServiceFlowWizard
{
    public string customSecLabel=system.label.CONF016_TAG122;
    public Boolean renderSFWSections = false;
    public Boolean getrenderSFWSections(){ return renderSFWSections;}
    public Boolean DisableStandardSFW = true;
    public Boolean getDisableStandardSFW(){ return DisableStandardSFW;}
    public Boolean DisableCustomSFWButtons = true;
    public Boolean getDisableCustomSFWButtons(){ return DisableCustomSFWButtons;}
    public Set<String> ObjNamesHavingSFWs = new Set<String>(); 
    //Jaysukh:defect 040618:View State issue:below varibles marked as transient
    transient public Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    transient public Map<String,String> Map_ObjName_Label = new Map<String,String>();
    public Map<String,String> getMap_ObjName_Label(){return Map_ObjName_Label;}
    public Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();
    public Boolean stdMode = false;
    public Boolean getstdMode(){ return stdMode;}
    
    // add variables for introduce a picklist of object
    //Jaysukh:defect 040618:View State issue:below varibles marked as transient
    transient public List<SVMXC__ServiceMax_Processes__c> standardSFWLstTemp = new List<SVMXC__ServiceMax_Processes__c>();
    transient public List<SVMXC__ServiceMax_Processes__c> customSFWLstTemp = new List<SVMXC__ServiceMax_Processes__c>();
    public String stringSelectObj{get;set;}
    public List<selectOption> objectOptns = new List<selectOption>();
    public List<selectOption> getObjectOptns(){return objectOptns;}
    public void setObjectOptns(List<selectOption> e){objectOptns = e;}
    
    public String stringSelectActive{get;set;}
    public List<selectOption> optnsActive = new List<selectOption>();
    public List<selectOption> getOptnsActive(){return optnsActive;}
    public void setOptnsActive(List<selectOption> e){optnsActive = e;}
    
    
    //Picklist onchange method
    public PageReference displayStdNCustomSFWs()
    {
        standardSFWLstTemp = Database.query('Select Id, SVMXC__Select__c, SVMXC__ProcessID__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, LastModifiedById, SVMXC__Active__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where SVMXC__isStandard__c = true and SVMXC__Source_Object_Name__c IN :ObjNamesHavingSFWs and RecordType.Name = \'Wizard\' ORDER BY SVMXC__ProcessID__c ASC ');// LastModifiedById,//SVMXC__ProcessID__c ASC
        customSFWLstTemp = Database.query('Select Id, SVMXC__Select__c, SVMXC__ProcessID__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, LastModifiedById, SVMXC__Active__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where SVMXC__isStandard__c = false and SVMXC__Source_Object_Name__c IN :ObjNamesHavingSFWs and RecordType.Name = \'Wizard\' ORDER BY SVMXC__ProcessID__c ASC');//LastModifiedById,// //SVMXC__ProcessID__c ASC
        
        
        Map<String, String> obj_Label_Api_Name = new Map<String, String>();
       
        if((standardSFWLstTemp != null && standardSFWLstTemp.size() > 0))
        {
            for(SVMXC__ServiceMax_Processes__c stdRec :standardSFWLstTemp)
            {
                if(!obj_Label_Api_Name.containsKey(stdRec.SVMXC__Source_Object_Name__c))
                    obj_Label_Api_Name.put(stdRec.SVMXC__Source_Object_Name__c, Map_ObjName_Label.get(stdRec.SVMXC__Source_Object_Name__c));
            }
        }
        if((customSFWLstTemp != null && customSFWLstTemp.size() > 0))
        {
            for(SVMXC__ServiceMax_Processes__c custRec :customSFWLstTemp)
            {
                if(!obj_Label_Api_Name.containsKey(custRec.SVMXC__Source_Object_Name__c))
                    obj_Label_Api_Name.put(custRec.SVMXC__Source_Object_Name__c, Map_ObjName_Label.get(custRec.SVMXC__Source_Object_Name__c));
            }
        }
        
        
        
        List<selectOption> objectOptnsTemp = new List<selectOption>();
        
        if(obj_Label_Api_Name !=  null && obj_Label_Api_Name.size() > 0)
        {
            for(String strKey : obj_Label_Api_Name.keySet())
            {   
                system.debug(obj_Label_Api_Name.get(strKey)+ '------');
                objectOptnsTemp.add(new SelectOption(strKey, obj_Label_Api_Name.get(strKey)));
            }
        }
        
        objectOptnsTemp = sortingSelectOption(objectOptnsTemp);
        
        objectOptns.clear();
        objectOptns.add(new SelectOption('SVMX.None', getTAG013()));
        for(selectOption selOptn : objectOptnsTemp)
            objectOptns.add(selOptn);
        System.debug('Size:  '+objectOptns.size()+'objectOptns: '+objectOptns);
        renderSFWSections = true;
        if(stringSelectObj != null && stringSelectObj != 'SVMX.None')
            onSelectObject();

        return null;
    }
    
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO : sortList) 
        {
            tempLst.put(SO.getLabel().toUpperCase(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel().toUpperCase()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }

    public void onSelectObject()
    {
    
        //Jaysukh:defect 040618:View State issue:Again querying the below varible for post-back request
        standardSFWLstTemp = Database.query('Select Id, SVMXC__Select__c, SVMXC__ProcessID__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, LastModifiedById, SVMXC__Active__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where SVMXC__isStandard__c = true and SVMXC__Source_Object_Name__c IN :ObjNamesHavingSFWs and RecordType.Name = \'Wizard\' ORDER BY SVMXC__ProcessID__c ASC ');// LastModifiedById,//SVMXC__ProcessID__c ASC //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        customSFWLstTemp = Database.query('Select Id, SVMXC__Select__c, SVMXC__ProcessID__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, LastModifiedById, SVMXC__Active__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where SVMXC__isStandard__c = false and SVMXC__Source_Object_Name__c IN :ObjNamesHavingSFWs and RecordType.Name = \'Wizard\' ORDER BY SVMXC__ProcessID__c ASC');//LastModifiedById,// //SVMXC__ProcessID__c ASC //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        standardSFWLst.clear();
        customSFWLst.clear();
        boolean isActive = true;
        if(stringSelectActive == 'Active')
            isActive = true;
        else if(stringSelectActive == 'Inactive')
            isActive = false;
        
        if(stringSelectObj != null && stringSelectObj != 'SVMX.None')
        {
            boolean isHavStandrd = false;
            boolean isHavCustom = false;
            if((standardSFWLstTemp != null && standardSFWLstTemp.size() > 0))
            {
                if(stringSelectActive == 'All')
                {
                    for(SVMXC__ServiceMax_Processes__c stdRec :standardSFWLstTemp)
                    {
                        if(stdRec.SVMXC__Source_Object_Name__c == stringSelectObj)
                        {
                            isHavStandrd = true;
                            standardSFWLst.add(stdRec);
                        }
                    }
                }
                else
                {
                    for(SVMXC__ServiceMax_Processes__c stdRec :standardSFWLstTemp)
                    {
                        if(stdRec.SVMXC__Source_Object_Name__c == stringSelectObj && stdRec.SVMXC__Active__c == isActive)
                        {
                            isHavStandrd = true;
                            standardSFWLst.add(stdRec);
                        }
                    }
                }
            }
                
            if((customSFWLstTemp != null && customSFWLstTemp.size() > 0))
            {
                if(stringSelectActive == 'All')
                {
                    for(SVMXC__ServiceMax_Processes__c custRec :customSFWLstTemp)
                    {
                        if(custRec.SVMXC__Source_Object_Name__c == stringSelectObj)
                        {
                            isHavCustom = true;
                            customSFWLst.add(custRec);
                        }
                    }
                }
                else
                {
                    for(SVMXC__ServiceMax_Processes__c custRec :customSFWLstTemp)
                    {
                        if(custRec.SVMXC__Source_Object_Name__c == stringSelectObj && custRec.SVMXC__Active__c == isActive)
                        {
                            isHavCustom = true;
                            customSFWLst.add(custRec);
                        }
                    }
                }
            }
                
            
            if(isHavStandrd)
            {
                customSecLabel=system.label.CONF016_TAG023;
                DisableStandardSFW = false;
            }
            else
            {
                customSecLabel=system.label.CONF016_TAG122;
                DisableStandardSFW = true;
            }
                
            if(isHavCustom)
                DisableCustomSFWButtons = false;
            else
                DisableCustomSFWButtons = true;  
        }
        else
        {
            DisableCustomSFWButtons = true;
            DisableStandardSFW = true;
           
        }
        
    }
    public List<SVMXC__ServiceMax_Processes__c> standardSFWLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getstandardSFWLst(){return this.standardSFWLst;}
    public void setstandardSFWLst(List<SVMXC__ServiceMax_Processes__c> o){this.standardSFWLst = o;}

    public List<SVMXC__ServiceMax_Processes__c> customSFWLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getcustomSFWLst(){return this.customSFWLst;}
    public void setcustomSFWLst(List<SVMXC__ServiceMax_Processes__c> o){this.customSFWLst = o;}

    //Picklist and related getter setter methods
    List<SelectOption> sourceObjectsOptns = new  List<SelectOption>();
    public List<SelectOption> getObjectsWithSFW()
    {
        return sourceObjectsOptns;
    }


    public CONF_ManageServiceFlowWizard(){
        //String 
        /*If( SVMXObjName != null && SVMXObjName != '' )
        {
            SelectedSourceObject = SVMXObjName;
            renderSFWSections = true;
            displayStdNCustomSFWs();
        }*/
        stringSelectObj = '';
        stringSelectObj = System.currentPageReference().getParameters().get('SVMX_ObjectName');
        if(stringSelectObj == '')
            stringSelectObj = 'SVMX.None';
        COMM_Utils commUtils = new COMM_Utils();
        allObjs = Schema.getGlobalDescribe();
        for(String key: allObjs.keySet())
        {
            Schema.SObjectType objT = allObjs.get(key) ;
            String CurrentObjName = objT.getDescribe().getName();
            if(!((CurrentObjName.toUpperCase()).Contains('__SHARE')) && !((CurrentObjName.toUpperCase()).Contains('__FEED')) && !((CurrentObjName.toUpperCase()).Contains('__HISTORY')) && objT.getDescribe().isAccessible())
            {    
                Map_ObjName_Label.put(CurrentObjName,objT.getDescribe().getLabel());
                system.debug(CurrentObjName + '-------CurrentObjName');
            }
        }
        system.debug('zzzz 1:'+Map_ObjName_Label);
        Boolean IsEnterpriseLicense = commUtils.SVMX_isEnterpriseLicense();
        /*if(!IsEnterpriseLicense)
        {
            PermitedStndObjMap = commUtils.SVMX_getPermittedStandardObjectList();
            system.debug('Objects returned'+PermitedStndObjMap);
            Map<String,String> TempMap_ObjName_Label = new Map<String,String>();
            for(String ObjName: Map_ObjName_Label.keyset())
            {
                if((PermitedStndObjMap.Containskey(ObjName)))
                {
                    //Map_ObjName_Label.remove(ObjName);
                    TempMap_ObjName_Label.put(ObjName, Map_ObjName_Label.get(ObjName));
                }
            }
            Map_ObjName_Label = TempMap_ObjName_Label;
        }*/
        system.debug('zzzz 2:'+Map_ObjName_Label);
        

        //Create Instance of the class SFW_Utils
        ServiceFlowWizard_Utils SFWUtils = new ServiceFlowWizard_Utils();
        
        //Map declaration to store Inventory actions, sfm actions and other actions obtained by calling respective methods in SFW_utils
        Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_InvActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_SfmActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_OtherActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_OutputDocActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        
        //Methods are called below
        Map_InvActions = SFWUtils.SVMX_GetInventoryActions('ALL');
        Map_SfmActions = SFWUtils.SVMX_GetSFMActions('ALL');
        Map_OtherActions = SFWUtils.SVMX_GetOtherActions('ALL');
        Map_OutputDocActions = SFWUtils.SVMX_GetSFMOutputDocActions('ALL');
        
        system.debug('zzzz 21 :'+Map_InvActions);
        system.debug('zzzz 21 :'+Map_SfmActions);
        system.debug('zzzz 21 :'+Map_OtherActions);
        system.debug('zzzz 21 :'+Map_OutputDocActions);
        for(String ObjName: Map_SfmActions.keyset())
            system.debug('Map_SfmActions :'+ObjName);
    
        for(String ObjName: Map_InvActions.keyset())
            system.debug('Map_InvActions :'+ObjName);
    
        for(String ObjName: Map_OtherActions.keyset())
            system.debug('Map_OtherActions :'+ObjName);
    
        for(String ObjName: Map_OutputDocActions.keyset())
            system.debug('Map_OutputDocActions :'+ObjName);

        
        sourceObjectsOptns.add(new SelectOption(getTAG013(),getTAG013()));
        for(String ObjName: Map_ObjName_Label.keyset())
        {
            if(Map_InvActions.ContainsKey(ObjName) || Map_SfmActions.ContainsKey(ObjName) || Map_OtherActions.ContainsKey(ObjName) || Map_OutputDocActions.ContainsKey(ObjName))
                ObjNamesHavingSFWs.add(ObjName);
                //sourceObjectsOptns.add(new SelectOption(ObjName, Map_ObjName_Label.get(ObjName)));
        }
        
        optnsActive.add(new SelectOption('Active', getTAG043()));
        optnsActive.add(new SelectOption('Inactive', getTAG044()));
        optnsActive.add(new SelectOption('All', getTAG045()));
        stringSelectActive = 'Active';
        
        
        displayStdNCustomSFWs();
        //Picklist creation ends here

        //Standard and custom SFW records are initially populated as below on page load
        //standardSFWLst.add(new SVMXC__ServiceMax_Processes__c(SVMXC__ProcessID__c='Tool001',Name__c='Field Repair Actions',Description__c='SFW Details'));
        //customSFWLst.add(new SVMXC__ServiceMax_Processes__c(SVMXC__ProcessID__c='CustomTool001',Name__c='Close Work Order reports',Description__c='SFW Details'));
    }

    //Standard SFW button methods

    public pagereference StdView(){
        stdMode = true;
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c SFWRec: standardSFWLst){
            if(SFWRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = SFWRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/SVMXC__Conf_SetupServiceFlowWizard?SVMX_RecordId='+SVMX_RecordId;
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG002(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG003(),''));
            return null;
        }
    }

    public pagereference StdClone(){
        stdMode = true;
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c SFWRec: standardSFWLst){
            if(SFWRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = SFWRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/SVMXC__Conf_SetupServiceFlowWizard?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Action=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG008(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG009(),''));
            return null;
        }

    }

    public pagereference Stdbacktosetuphme(){
        stdMode = true;
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        PageReference pr = new PageReference(url);
        pr.setredirect(true);
        return pr;


    }

    public pagereference CustomNew()
    {
        stdMode = false;
        String loc = '';
        if(stringSelectObj != null && stringSelectObj != '' && stringSelectObj != 'SVMX.None')
        {
            loc = '/apex/SVMXC__CONF_SetupServiceFlowWizard?SVMX_ObjectName='+stringSelectObj;
        }
        else
            loc = '/apex/SVMXC__CONF_SetupServiceFlowWizard';
        PageReference pr = new PageReference(loc);
        pr.setRedirect(true);
        return pr;  
    }

    public pagereference CustomEdit(){
        stdMode = false;
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c SFWRec: customSFWLst){
            if(SFWRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = SFWRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/SVMXC__CONF_SetupServiceFlowWizard?SVMX_RecordId='+SVMX_RecordId;
            PageReference pr = new PageReference(loc);
            pr.setRedirect(true);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG004(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG005(),''));
            return null;
        }

    }

    public pagereference CustomClone(){
        stdMode = false;
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c SFWRec: customSFWLst){
            if(SFWRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = SFWRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/SVMXC__CONF_SetupServiceFlowWizard?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Action=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG008(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG009(),''));
            return null;
        }

    }

    public pagereference LayoutConfiguration(){
        String loc;
        if(stringSelectObj != null && stringSelectObj != 'None.SVMX' && stringSelectObj.length() > 1)
            loc = '/apex/SVMXC__CONF_SetupServiceFlowWizardLayout?SVMX_ObjectName='+stringSelectObj;
        else
            loc = '/apex/SVMXC__CONF_SetupServiceFlowWizardLayout';
        PageReference pr = new PageReference(loc);
        pr.setRedirect(true);
        return pr;
    }
    public pagereference CustomDelete(){
        stdMode = false;
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        List<SVMXC__ServiceMax_Processes__c> LstSFWRecToDelete = new List<SVMXC__ServiceMax_Processes__c>();
        for(SVMXC__ServiceMax_Processes__c SFWRec: customSFWLst){
            if(SFWRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = SFWRec.Id;
                LstSFWRecToDelete.add(SFWRec);
            }
        }
        if( selectedCount == 1 )
        {
            //Delete action happens here
            Savepoint sp;
            sp = Database.setSavepoint();
            try
            {
                //Delete SFW permissions
                List<SVMXC__ServiceMax_Config_Data__c> LstSFWPermissions = new List<SVMXC__ServiceMax_Config_Data__c>();
                LstSFWPermissions = Database.query('Select Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Wizard Permission\' and SVMXC__Dispatch_Process__c = :SVMX_RecordId');
                //delete LstSFWPermissions;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete LstSFWPermissions; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    Database.rollback(sp);
                    return null;
                }

                //Delete SFW Actions
                List<SVMXC__ServiceMax_Processes__c> LstSFWActions = new List<SVMXC__ServiceMax_Processes__c>();
                LstSFWActions = Database.query('Select Id,  SVMXC__Module__c, SVMXC__Process__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Action_Type__c, SVMXC__Action_URL__c, SVMXC__Submodule__c , SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = \'Wizard Action\' and SVMXC__Module__c = :SVMX_RecordId');
                //delete LstSFWActions;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete LstSFWActions; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    Database.rollback(sp);
                    return null;
                }
                
                //Delete the SFWLayoutRecs for the selected SFW
                List<SVMXC__ServiceMax_Config_Data__c> SFWLayoutRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
                SFWLayoutRecs = Database.query('Select Id, SVMXC__Dispatch_Process__c, SVMXC__Object_Name__c  From ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Layout\' And SVMXC__Dispatch_Process__c = :SVMX_RecordId');
                //Delete SFWLayoutRecs;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete SFWLayoutRecs; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    Database.rollback(sp);
                    return null;
                }
                
                //Delete SFW Definition
                //delete LstSFWRecToDelete;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete LstSFWRecToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    Database.rollback(sp);
                    return null;
                }
                
                //Jaysukh: 040618 :Fixed View state defect 
                /* customSFWLstTemp.clear();                    
                customSFWLstTemp = Database.query('Select Id, SVMXC__Dispatch_Process_Status__c, SVMXC__Select__c , SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Description__c, LastModifiedBy.Name, LastModifiedDate, SVMXC__Active__c,  SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where SVMXC__isStandard__c = false and RecordType.Name = \'Wizard\' ORDER BY SVMXC__ProcessID__c ASC');
                */
                onSelectObject();

                //Display success message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG035(),''));
            }
            catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG015(),''));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage(),''));
                Database.rollback(sp);
            }
            return null;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG006(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG007(),''));
            return null;
        }
    }

public String getTAG001(){return system.label.CONF016_TAG068;}//Object //TAG001
public String getTAG002(){return system.label.CONF016_TAG002;}//Please select a SFW to view
public String getTAG003(){return system.label.CONF016_TAG003;}//Please select only one SFW to view
public String getTAG004(){return system.label.CONF016_TAG002;}//Please select a SFW to edit
public String getTAG005(){return system.label.CONF016_TAG003;}//Please select only one SFW to edit
public String getTAG006(){return system.label.CONF016_TAG002;}//Please select a SFW to delete
public String getTAG007(){return system.label.CONF016_TAG003;}//Please select only one SFW to delete
public String getTAG008(){return system.label.CONF016_TAG002;}//Please select a SFW to clone
public String getTAG009(){return system.label.CONF016_TAG003;}//Please select only one SFW to clone
public String getTAG010(){return system.label.CONF016_TAG002;}//Please select a SFW to design layout
public String getTAG011(){return system.label.CONF016_TAG003;}//Please select only one SFW to design layout
//public String getTAG012(){return system.label.CONF016_TAG004;}//No Record Found
public String getTAG013(){return system.label.CONF016_TAG067;}//--None-- //TAG005
public String getTAG014(){return String.EscapeSingleQuotes(system.label.CONF016_TAG006);}//Are you sure you want to delete the selected SFW definition?
public String getTAG015(){return system.label.CONF016_TAG007;}//An internal error occurred. Please contact your ServiceMax administrator to resolve this.
public String getTAG016(){return system.label.CONF016_TAG008;}//View
public String getTAG017(){return system.label.CONF016_TAG009;}//Clone
public String getTAG018(){return system.label.CONF016_TAG010;}//Layout Configuration
public String getTAG019(){return system.label.CONF016_TAG011;}//Back to Setup Home
public String getTAG020(){return system.label.CONF016_TAG012;}//New
public String getTAG021(){return system.label.CONF016_TAG013;}//Edit
public String getTAG022(){return system.label.CONF016_TAG014;}//Delete
public String getTAG023(){return system.label.CONF016_TAG015;}//Select
public String getTAG024(){return system.label.CONF016_TAG016;}//SFW Id
public String getTAG025(){return system.label.CONF016_TAG017;}//SFW Title
public String getTAG026(){return system.label.CONF016_TAG018;}//Description
public String getTAG027(){return system.label.CONF016_TAG019;}//Last Modified By
//public String getTAG028(){return system.label.CONF016_TAG020;}//Source Objects
//public String getTAG029(){return system.label.CONF016_TAG021;}//Manage SFWs
public String getTAG030(){return system.label.CONF016_TAG022;}//Standard SFWs
public String getTAG031(){return              customSecLabel;}//Custom SFWs
public String getTAG032(){return system.label.CONF016_TAG024;}//Processing...
public String getTAG033(){return system.label.CONF016_TAG025;}//SFW Home Help
//public String getTAG034(){return system.label.CONF016_TAG026;}//Please Select a valid Source Object.
public String getTAG035(){return system.label.CONF016_TAG027;}//Successfully deleted the SFW.
//public String getTAG036(){return system.label.CONF016_TAG028;}//object related sentence was there
public String getTAG037(){return system.label.CONF016_TAG029;}//status
public String getTAG038(){return system.label.CONF016_HLPURL1;}//SFW help url
public String getTAG039(){return system.label.CONF016_TAG079;}//Active
public String getTAG040(){return system.label.CONF016_TAG095;}//Last Modified Date/Time
public String getTAG041(){return system.label.COMM001_TAG094;}//'Select Object'
public String getTAG042(){return system.label.CONF016_TAG109;}//'Service Flow Wizards'
public String getTAG043(){return system.label.COMM001_TAG016;}//'Active'
public String getTAG044(){return system.label.COMM001_TAG104;}//'Inactive'
public String getTAG045(){return system.label.COMM001_TAG105;}//'All'
public String getTAG046(){return system.label.CONF016_TAG110;}//'Wizard Status'
}