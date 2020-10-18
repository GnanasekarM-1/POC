public with sharing class CONF_ManageActions 
{
    //Wrapper to hold list of objects 2000 and display it in the Dropdown on the VF page. It is added as part of defect 027117 fix
    //Updated code as part of 047155 defect fix to support 3000 objects
    public class ObjectListWrapper{
        final Integer COLLECTION_SIZE_LIMIT = 1000;
        public List<SelectOption> collectionList = new List<SelectOption>();

        public void add(SelectOption so){
            collectionList.add(so);
        }       

        public Integer getCollectionSize(){
            return collectionList.size();
        }
        
        public List<SelectOption> getcollectionList(){
            return collectionList;
        }

        public SelectOption get(Integer i){
            if(i >-1 && i< getCollectionSize()){
                return collectionList.get(i);
            }else{
                return null;
            }    
        }

        public List<SelectOption> getSubCollectionList(Integer startValue,Integer endValue){
            List<SelectOption> subCollectionList = new List<SelectOption>();
            
            if(startValue >-1 && startValue < collectionList.size() && endValue > -1 && endValue < collectionList.size() && startValue <= endValue){
                
                for(Integer i= startValue; i <= endValue; i++){
                    
                    subCollectionList.add(get(i));
                }
            }
            return subCollectionList;
        }

        public List<SelectOption> getnthCollectionSubList(Integer i){
            
            List<SelectOption> nthCollectionList = new List<SelectOption>();

            Integer subLPicklistCount= (Integer)(collectionList.size()/COLLECTION_SIZE_LIMIT);
            
            if(Math.mod(collectionList.size(),COLLECTION_SIZE_LIMIT)>0) {
                subLPicklistCount++;
            }
            
            if(i >=0 && i <= subLPicklistCount){
                
                Integer startValue = i * COLLECTION_SIZE_LIMIT;
                Integer endValue = i * COLLECTION_SIZE_LIMIT + (COLLECTION_SIZE_LIMIT-1);
               
                if(endValue >= collectionList.size()){ 
                    endValue= collectionList.size() - 1;
                }
                nthCollectionList = getSubCollectionList(startValue,endValue);
            }

            return nthCollectionList;
        }
        
        public List<SelectOption> get1stList(){
            return getnthCollectionSubList(0);
        }
        public List<SelectOption> get2ndList(){
            return getnthCollectionSubList(1);
        }
        public List<SelectOption> get3rdList(){ // #DefectFix 047155
            return getnthCollectionSubList(2);
        }
    }

    public ObjectListWrapper listOfObjects{
        get{
            if(listOfObjects==null){
                  listOfObjects=new ObjectListWrapper();
                  for(Integer i=0;i<sourceObjectsOptns.size();i++){
                        listOfObjects.add(sourceObjectsOptns[i]);
                  }
            }
            return listOfObjects;
        }
        set;
    }
    public Boolean getIsSecondListHasItem(){
        Integer sizeOfList = listOfObjects.get2ndList().size(); //  // #defectFix 047155 changed get1stList to get2ndList
        if(sizeOfList > 0)
            return true;
        else
            return false;
    }

    // #defectFix 047155
    public Boolean getIsThirdListHasItem(){
        Integer sizeOfList = listOfObjects.get3rdList().size(); 
        if(sizeOfList > 0)
            return true;
        else
            return false;
    }
    
    //=========================================Declarations and Getter-Setter Methods========================================================
    public boolean Render = false;
    public boolean getRender(){return this.Render;}
    public void setRender(boolean b){this.Render = b;}
    public boolean DisableStd = false;
    public boolean getDisableStd(){return this.DisableStd;}
    public void setDisableStd(boolean b){this.DisableStd = b;}
    public boolean DisableCusBtn = false;
    public List<SelectOption> sourceObjectsOptns = new  List<SelectOption>();
    public boolean getDisableCusBtn(){return this.DisableCusBtn;}
    public void setDisableCusBtn(boolean b){this.DisableCusBtn = b;}
    public List<SVMXC__ServiceMax_Processes__c> standardActionsLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getstandardActionsLst(){return this.standardActionsLst;}
    public void setstandardActionsLst(List<SVMXC__ServiceMax_Processes__c> o){this.standardActionsLst = o;}
    public List<SVMXC__ServiceMax_Processes__c> customActionLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getcustomActionLst(){return this.customActionLst;}
    public void setcustomActionLst(List<SVMXC__ServiceMax_Processes__c> o){this.customActionLst = o;}
    boolean isEnterprise;
    public List<SVMXC__ServiceMax_Processes__c> DelProcesses = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> delconfigdata = new List<SVMXC__ServiceMax_Config_Data__c>();
    public string objectName = '';
    public string customSecLabel='';
    public List<SelectOption> getObjectsWithAction()
    {
        return sourceObjectsOptns;
    }
    public String SelectedSourceObject = '';
    public String getSelectedSourceObject() 
    {
        return SelectedSourceObject;
    }
    public void setSelectedSourceObject(string val) 
    {
        SelectedSourceObject = val;
    }
    public Map<String,String> mapfieldApiLabel_Name = new Map<String,String>();
     
    //================================Constructor and On Load================================================
    public CONF_ManageActions()
    {
        Render = false;
        onLoad();
        objectName = System.currentPageReference().getParameters().get('SVMX_ObjectName');
        if(objectName != null && objectName != '' && objectName != getTAG031())
        {
            SelectedSourceObject = objectName;
            Render = true;
            selectedObjectActions();
            System.currentPageReference().getParameters().put('SVMX_ObjectName','');
        }
    }
    public void onLoad()
    {
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
        isEnterprise = utils.SVMX_isEnterpriseLicense();
        Map<String,Boolean> permitdStdObjMap = new Map<String,Boolean>();
        if(!isEnterprise) permitdStdObjMap = utils.SVMX_getPermittedStandardObjectList();
        sourceObjectsOptns.add(new SelectOption(getTAG031(),getTAG031()));
        
        Map<String,String> SFDCSVMXInternalObjectsMap = new Map<String,String>();
        SFDCSVMXInternalObjectsMap = utils.getSFDCSVMXInternalObjects();
        
        for(String s : SFDCSVMXInternalObjectsMap.keyset())
        {
            mapfieldApiLabel_Name.put(s,SFDCSVMXInternalObjectsMap.get(s));
            sourceObjectsOptns.add(new SelectOption(s,SFDCSVMXInternalObjectsMap.get(s)));
        }
        
        /*
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        allObjs = Schema.getGlobalDescribe(); 
        for(String s : allObjs.keyset())
        {
            Schema.DescribeSObjectResult objDesc = allObjs.get(s).getDescribe();
            string objName = (objDesc.getName().toUpperCase());
            boolean custom = objDesc.isCustom();
            if(!(objName.Contains('__FEED')) || !(objName.Contains('__TAG')) || !(objName.Contains('__HISTORY')))
            {
                string internalObj = SFDCSVMXInternalObjectsMap.get(objDesc.getName());
                if(custom == true && internalObj != null)
                {
                    mapfieldApiLabel_Name.put(objDesc.getName(),objDesc.getLabel());
                    sourceObjectsOptns.add(new SelectOption(objDesc.getName(),objDesc.getLabel()));
                }
            }*/
            /*if(objDesc.isAccessible() == true && objDesc.isCreateable() == true && objDesc.isCustom() == true && objDesc.isUpdateable())
            {
                mapfieldApiLabel_Name.put(objDesc.getName(),objDesc.getLabel());
                sourceObjectsOptns.add(new SelectOption(objDesc.getName(),objDesc.getLabel()));
            }
            else if(objDesc.isAccessible() == true && objDesc.isCreateable() == true && objDesc.isCustom() == false && objDesc.isUpdateable() && (permitdStdObjMap.containsKey(objDesc.getName()) || isEnterprise))
            {
                mapfieldApiLabel_Name.put(objDesc.getName(),objDesc.getLabel());
                sourceObjectsOptns.add(new SelectOption(objDesc.getName(),objDesc.getLabel()));
            }
        }*/
        
        //system.debug('1. Map of Name and Label for Objects: '+mapfieldApiLabel_Name);
        sourceObjectsOptns = sortingSelectOption(sourceObjectsOptns);
    }

    //------------------------------------------- Method to sort the Fields --------------------------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList) {
            if(!tempLst.containsKey(SO.getLabel())) //Added this condition to fix defect 027561
                tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }
    
    //==================================Querying the Standard and Custom Actions based on the Selected Object====================================
    public pagereference selectedObjectActions()
    {
        if(SelectedSourceObject == getTAG031())     //TAG031 = '--None--'
        {
            standardActionsLst.clear();
            customActionLst.clear();
            Render = false;
        }
        else
        {
            standardActionsLst = [select Id, SVMXC__ProcessId__c, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate, SVMXC__Custom_action_Type__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='SF Action' and SVMXC__IsStandard__c = true and SVMXC__Source_Object_Name__c =: SelectedSourceObject order by SVMXC__Source_Object_Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            customActionLst = [select Id, SVMXC__ProcessId__c, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate, SVMXC__Custom_action_Type__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='SF Action' and SVMXC__IsStandard__c = false and SVMXC__Source_Object_Name__c =: SelectedSourceObject order by SVMXC__Source_Object_Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            Render = true;
            if(standardActionsLst.size() == 0)
            {
                customSecLabel='';
                DisableStd = true;
            }
            else
            {   customSecLabel=system.label.CONF018_TAG013;
                DisableStd = false;
            }
                
            if(customActionLst.size() == 0)
            {
                DisableCusBtn = true;
            }
            else
                DisableCusBtn = false;
        }
        return null;
    }
    
    //================================On Click of View==========================================
    public pagereference StdView()
    {
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c ActionRec: standardActionsLst)
        {
            if(ActionRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = ActionRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/Conf_SetupAction?SVMX_RecordId='+SVMX_RecordId;
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG022(),''));
            return null;
        }
    }

    //================================On Click of Clone==========================================
    public pagereference StdClone()
    {
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c ActionRec: standardActionsLst)
        {
            if(ActionRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = ActionRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/Conf_SetupAction?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Action=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG022(),''));
            return null;
        }

    }

    //================================On Click of Back To Setup Home==========================================
    public pagereference Stdbacktosetuphme()
    {
        //String location = '/apex/CONF_SetupHome';
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/CONF_SetupHome';
        }
        PageReference pr = new PageReference(url);
        pr.setredirect(true);
        return pr;

    }

    //================================On Click of New==========================================
    public pagereference CustomNew()
    {
        if(SelectedSourceObject != '' && SelectedSourceObject != null && SelectedSourceObject != getTAG031())
        {
            PageReference pageRef = new PageReference('/apex/Conf_SetupAction');
            pageRef.getParameters().put('SVMX_ObjectName',SelectedSourceObject);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }    
    }

    //================================On Click of Edit for Custom Actions==========================================
    public pagereference CustomEdit()
    {
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c ActionRec: customActionLst)
        {
            if(ActionRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = ActionRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/Conf_SetupAction?SVMX_RecordId='+SVMX_RecordId;
            PageReference pr = new PageReference(loc);
            pr.setRedirect(true);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG022(),''));
            return null;
        }

    }

    //================================On Click of Clone for Custom Actions==========================================
    public pagereference CustomClone()
    {
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c ActionRec: customActionLst)
        {
            if(ActionRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = ActionRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/Conf_SetupAction?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Action=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG022(),''));
            return null;
        }
    }

    //================================On Click of Delete for Custom Actions==========================================
    public pagereference CustomDelete()
    {
        String SVMX_RecordId = '';
        Integer i = 0;
        Integer j = 0;
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c ActionRec: customActionLst)
        {
            if(ActionRec.Select__c == true)
            {
                selectedCount += 1;
                j = i;
                SVMX_RecordId = ActionRec.Id;
            }
            i++;
        }
        if( selectedCount == 1 && SVMX_RecordId != null)
        {
            Savepoint sp;
            try
            {
                sp = Database.setSavepoint();
                SVMXC__ServiceMax_Processes__c action = [select Id,SVMXC__ProcessId__c,SVMXC__Source_Object_Name__c,SVMXC__Select__c,SVMXC__Name__C,SVMXC__Description__c,SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate, SVMXC__Custom_action_Type__c from  SVMXC__ServiceMax_Processes__c where Id =: SVMX_RecordId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<SVMXC__ServiceMax_Config_Data__c> actionParam = [select SVMXC__Object_Name__c, SVMXC__Select__c, SVMXC__Expression_Rule__c  from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: action.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                //delete actionParam;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete actionParam; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, System.label.COMM001_TAG142));
                    Database.rollback(sp);
                    return null;
                }
                
                //delete action;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete action; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, System.label.COMM001_TAG142));
                    Database.rollback(sp);
                    return null;
                }
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG028(),''));
                customActionLst = [select Id,SVMXC__ProcessId__c,SVMXC__Source_Object_Name__c,SVMXC__Select__c,SVMXC__Name__C,SVMXC__Description__c,SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate, SVMXC__Custom_action_Type__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='SF Action' and SVMXC__IsStandard__c = false and SVMXC__Source_Object_Name__c =: SelectedSourceObject order by SVMXC__Source_Object_Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(customActionLst.size() == 0)
                {
                    DisableCusBtn = true;
                }
                return null;
            }
            catch(exception ex)
            {
                apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, getTAG033()));
                Database.rollback(sp);
                return null;
            }
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG022(),''));
            return null;
        }
        
    }
    
    //================================Getter-Setters for TAGS==========================================
    public String getTAG001(){return string.escapeSingleQuotes(system.label.CONF018_TAG001);}//ServiceMax Actions
    public String getTAG002(){return string.escapeSingleQuotes(system.label.CONF018_TAG002);}//Action Home Help
    public String getTAG003(){return string.escapeSingleQuotes(system.label.CONF018_TAG003);}//Show Actions for this object: 
    public String getTAG004(){return string.escapeSingleQuotes(system.label.CONF018_TAG004);}//Standard Actions
    public String getTAG005(){return string.escapeSingleQuotes(system.label.CONF018_TAG005);}//View
    public String getTAG006(){return string.escapeSingleQuotes(system.label.CONF018_TAG006);}//Clone
    public String getTAG007(){return string.escapeSingleQuotes(system.label.CONF018_TAG007);}//Back To Setup Home
    public String getTAG008(){return string.escapeSingleQuotes(system.label.CONF018_TAG008);}//Select
    public String getTAG009(){return string.escapeSingleQuotes(system.label.CONF018_TAG009);}//Action Title
    public String getTAG010(){return string.escapeSingleQuotes(system.label.CONF018_TAG010);}//Description
    public String getTAG011(){return string.escapeSingleQuotes(system.label.CONF018_TAG011);}//Action ID
    public String getTAG012(){return string.escapeSingleQuotes(system.label.CONF018_TAG012);}//Last Modified By
    public String getTAG013(){return string.escapeSingleQuotes(customSecLabel);             }//Custom Actions
    public String getTAG014(){return string.escapeSingleQuotes(system.label.CONF018_TAG014);}//New
    public String getTAG015(){return string.escapeSingleQuotes(system.label.CONF018_TAG015);}//Edit
    public String getTAG016(){return string.escapeSingleQuotes(system.label.CONF018_TAG016);}//Please select an Action to perform this operation.
    public String getTAG017(){return string.escapeSingleQuotes(system.label.CONF018_TAG017);}//Delete
    public String getTAG018(){return string.escapeSingleQuotes(system.label.CONF018_TAG018);}//Are you sure you want to delete the selected Action definition?
    public String getTAG019(){return string.escapeSingleQuotes(system.label.CONF018_TAG019);}//Processing...
    public String getTAG022(){return string.escapeSingleQuotes(system.label.CONF018_TAG020);}//Please select only one Action to perform this operation.
    public String getTAG028(){return string.escapeSingleQuotes(system.label.CONF018_TAG021);}//Successfully deleted the selected Action(s).
    public String getTAG031(){return string.escapeSingleQuotes(system.label.CONF018_TAG022);}//--None--
    public String getTAG032(){return string.escapeSingleQuotes(system.label.CONF018_TAG023);}//No Actions found for the selected object
    public String getTAG033(){return string.escapeSingleQuotes(system.label.CONF018_TAG024);}//An internal error occurred. Please contact your ServiceMax administrator to resolve this.
    // newly created
    public String getTAG034(){return string.escapeSingleQuotes(system.label.CONF018_TAG065);}//'Action Type'
    public String getHLPURL(){return string.escapeSingleQuotes(system.label.CONF018_HLPURL);}//
    
    public String getTAG035(){return string.escapeSingleQuotes(system.label.CONF018_TAG072);}//'URL'
    public String getTAG036(){return string.escapeSingleQuotes(system.label.CONF018_TAG071);}//'Web Service'
    public String getTAG037(){return string.escapeSingleQuotes(system.label.CONF018_TAG078);}// app to app
    public String getTAG038(){return string.escapeSingleQuotes(system.label.CONF018_TAG087);}//Mobile Activity Space
}