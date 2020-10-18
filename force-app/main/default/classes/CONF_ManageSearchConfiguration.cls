public with sharing class CONF_ManageSearchConfiguration 
{
    /*********************** Global variables ***********************/
    public string strSearchId='';
    public string Helptitleonhide{get;set;}
    public string helpUrlonhide {get;set;}
    public string customSecLabel=System.Label.CONF031_TAG030;
    public boolean IsHdrMsg = false;    
    public boolean getIsHdrMsg(){return this.IsHdrMsg;} 
    public boolean IsDisplayStandard = false;
    public boolean getIsDisplayStandard(){return this.IsDisplayStandard;} 
    public List<RecordType> ProcessRType = new List<RecordType>(); 
    public List<RecordType> ConfigRType = new List<RecordType>(); 
    public String ConfigExpRTypeId = '';
    public String ProcessRTypeId = '';
    public  LIST<SVMXC__ServiceMax_Processes__c>  SearchConfLst = new LIST<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> searchLstToDelete = new List<SVMXC__ServiceMax_Processes__c>();
    public LIST<SVMXC__ServiceMax_Processes__c> lstStandardSearch = new LIST<SVMXC__ServiceMax_Processes__c>();
    public  LIST<SVMXC__ServiceMax_Processes__c> getlstStandardSearch(){return lstStandardSearch;}
    public integer getStdLstSize(){return lstStandardSearch.size();}
    public LIST<SVMXC__ServiceMax_Processes__c> lstCustomSearch = new LIST<SVMXC__ServiceMax_Processes__c>();
    public  LIST<SVMXC__ServiceMax_Processes__c> getlstCustomSearch(){return lstCustomSearch;}    
    public integer getCustomLstSize(){return lstCustomSearch.size();}
    
    /*********************** Constructor ***********************/
    public CONF_ManageSearchConfiguration()
    {
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ProcessRTypeId = ProcessRType[0].id;
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ConfigExpRTypeId = ConfigRType[0].id;
        
        SearchConfLst = [select SVMXC__Select__c, SVMXC__ProcessID__c,LastModifiedById, LastModifiedDate, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c ='Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(SearchConfLst != null && SearchConfLst.size() > 0)
        {
            for(integer i=0;i<SearchConfLst.size();i++)
            {
                if(SearchConfLst[i].SVMXC__IsStandard__c)
                    lstStandardSearch.add(SearchConfLst[i]);
                else if(!SearchConfLst[i].SVMXC__IsStandard__c)
                    lstCustomSearch.add(SearchConfLst[i]);
            }
            if(lstStandardSearch != null && lstStandardSearch.size()>0)
            {
                IsDisplayStandard = true;
                helpUrlonhide = '';
                Helptitleonhide = '';
                customSecLabel=System.Label.CONF031_TAG006;
            }
            else 
            {
                IsDisplayStandard = false;
                helpUrlonhide= getHLPURL();
                Helptitleonhide = getHLPTITLE();
                customSecLabel=System.Label.CONF031_TAG030;
                
            }
                
        }
    }
  
    /*********************** EDIT METHOD ***********************/
    public PageReference SVMXEdit() 
    {
        List<integer> selectindex1 = new  List<integer>();
        for(integer i=0;i<lstCustomSearch.size();i++)
        { 
            if(lstCustomSearch[i].SVMXC__Select__c==true)
                selectindex1.add(i);
        }
        if(selectindex1.size() == 0)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG016()));
        }
        else if(selectindex1.size() > 1)
        {
            for(integer i=0;i<lstCustomSearch.size();i++)
            { 
                if(lstCustomSearch[i].SVMXC__Select__c==true)
                    lstCustomSearch[i].SVMXC__Select__c=false;
            }        
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, getTAG019() ));
        }
        else
        {
            for(integer i=0;i<lstCustomSearch.size();i++)
            {
                if(lstCustomSearch[i].SVMXC__Select__c==true)
                    strSearchId = lstCustomSearch[i].id;
            }
            PageReference pageRef = new PageReference('/apex/CONF_SetupSearchConfiguration');
            pageRef.setRedirect(true);
            pageRef.getParameters().put('SVMX_RecordID',strSearchId);
            pageRef.getParameters().put('SVMX_Mode','Edit');
            return pageRef;
        }
        return null;
    } 
    /*********************** Clone METHOD ***********************/
    public PageReference SVMXCustomClone() 
    {
        List<integer> selectindex1 = new  List<integer>();
        for(integer i=0;i<lstCustomSearch.size();i++)
        { 
            if(lstCustomSearch[i].SVMXC__Select__c==true)
                selectindex1.add(i);
        }
        if(selectindex1.size() == 0)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG016()));
        }
        else if(selectindex1.size() > 1)
        {
            for(integer i=0;i<lstCustomSearch.size();i++)
            { 
                if(lstCustomSearch[i].SVMXC__Select__c==true)
                    lstCustomSearch[i].SVMXC__Select__c=false;
            }        
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG019()) );
        }
        else
        {
            for(integer i=0;i<lstCustomSearch.size();i++)
            {
                if(lstCustomSearch[i].SVMXC__Select__c==true)
                    strSearchId = lstCustomSearch[i].id;
            }
            PageReference pageRef = new PageReference('/apex/CONF_SetupSearchConfiguration');
            pageRef.setRedirect(true);
            pageRef.getParameters().put('SVMX_RecordID',strSearchId);
            pageRef.getParameters().put('SVMX_Mode','Clone');
            return pageRef;
        }
        return null;
    }
    
    /*********************** Clone METHOD ***********************/
    public PageReference SVMXStdClone() 
    {
        List<integer> selectindex1 = new  List<integer>();
        for(integer i=0;i<lstStandardSearch.size();i++)
        { 
            if(lstStandardSearch[i].SVMXC__Select__c==true)
                selectindex1.add(i);
        }
        if(selectindex1.size() == 0)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG016()));
        }
        else if(selectindex1.size() > 1)
        {
            for(integer i=0;i<lstStandardSearch.size();i++)
            { 
                if(lstStandardSearch[i].SVMXC__Select__c==true)
                    lstStandardSearch[i].SVMXC__Select__c=false;
            }        
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error, getTAG019()));
        }
        else
        {
            for(integer i=0;i<lstStandardSearch.size();i++)
            {
                if(lstStandardSearch[i].SVMXC__Select__c==true)
                    strSearchId = lstStandardSearch[i].id;
            }
            PageReference pageRef = new PageReference('/apex/CONF_SetupSearchConfiguration');
            pageRef.setRedirect(true);
            pageRef.getParameters().put('SVMX_RecordID',strSearchId);
            pageRef.getParameters().put('SVMX_Mode','Clone');
            return pageRef;
        }
        return null;
    } 
    
    /*********************** METHOD  for Manage Permission ***********************/
    public PageReference SVMXManagePermission() 
    {
        PageReference pRef = new PageReference('/apex/CONF_SearchAccess');  
        pRef.setRedirect(true);
        return pRef;
    } 
    
    /*********************** BackToSetupHome ***********************/
    public PageReference BackToSetupHome() 
    {
         //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        PageReference pRef = new PageReference(url);  
        return pRef;
    }
    
    /*********************** View Method ***********************/
    public PageReference SVMXView()
    {
        List<integer> selectindex1 = new  List<integer>();
        for(integer i=0;i<lstStandardSearch.size();i++)
        { 
            if(lstStandardSearch[i].SVMXC__Select__c==true)
                selectindex1.add(i);
        }
        if(selectindex1.size() == 0)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG016()));
        }
        else if(selectindex1.size() > 1)
        {
            for(integer i=0;i<lstStandardSearch.size();i++)
            { 
                if(lstStandardSearch[i].SVMXC__Select__c==true)
                    lstStandardSearch[i].SVMXC__Select__c=false;
            }        
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error, getTAG019()) );
        }
        else
        {
            for(integer i=0;i<lstStandardSearch.size();i++)
            {
                if(lstStandardSearch[i].SVMXC__Select__c==true)
                    strSearchId = lstStandardSearch[i].id;
            }
            PageReference pageRef = new PageReference('/apex/CONF_SetupSearchConfiguration');
            pageRef.setRedirect(true);
            pageRef.getParameters().put('SVMX_RecordID',strSearchId);
            pageRef.getParameters().put('SVMX_Mode','View');
            return pageRef;
        }
        return null;
    }
    
    /*********************** New Method ***********************/
    public pagereference SVMXNew()
    {
        PageReference pageref= new PageReference('/apex/CONF_SetupSearchConfiguration');
        return pageref;
    }
    
    /*********************** Delete Method ***********************/
    public List<SVMXC__ServiceMax_Processes__c> lstSearchProcess = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> lstSearchObj = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> DeleteConfingLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    //public String StrSearchProcessID = ''; 
    //public String StrSearchObjID = ''; 
    public pagereference SVMXdeleteRules()
    {
        IsHdrMsg = false;
        //StrSearchProcessID = '';
        Set<ID> setSearchProcessId = new Set<ID>();
        PageReference pageref1 = null;
        lstSearchProcess.clear();
        lstSearchObj.clear();
        DeleteConfingLst.clear();
        List<Integer> SelectedLines = new List<Integer>();
        for(integer i=0;i<lstCustomSearch.size();i++)
        {
            if( lstCustomSearch[i].SVMXC__Select__c == true)
            {
                lstSearchProcess.add(lstCustomSearch[i]);
                SelectedLines.add(i);
                setSearchProcessId.add(lstCustomSearch[i].id);
                /*if(StrSearchProcessID.length() > 0)
                    StrSearchProcessID += ',';
                StrSearchProcessID  += '\'' + String.valueOf(lstCustomSearch[i].id)+ '\'';*/
                lstCustomSearch[i].SVMXC__Select__c = false;
            }
        }  
        if(SelectedLines.size() == 0)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG016()));
            return null;
        }
        try
        {
            //lstSearchObj = database.query('select SVMXC__Select__c, SVMXC__Sequence__c, SVMXC__Target_Object_Name__c, SVMXC__ProcessID__c, SVMXC__Module__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where (SVMXC__Rule_Type__c = \'SRCH_OBJECT\' AND RecordTypeId=\''+String.escapeSingleQuotes(ProcessRTypeId)+'\'AND SVMXC__Module__c in('+String.escapeSingleQuotes(StrSearchProcessID)+'))');
            lstSearchObj = [Select SVMXC__Select__c, SVMXC__Sequence__c, SVMXC__Target_Object_Name__c, SVMXC__ProcessID__c, SVMXC__Module__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = 'SRCH_OBJECT' AND RecordTypeId =: String.escapeSingleQuotes(ProcessRTypeId) AND SVMXC__Module__c IN: setSearchProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstSearchObj != null && lstSearchObj.size() > 0)
            {
                //StrSearchObjID = '';
                Set<Id> setProcessId = new Set<Id>();
                for(integer i=0;i<lstSearchObj.size();i++)
                {
                    setProcessId.add(lstSearchObj[i].id);
                    /*if(StrSearchObjID.length() > 0)
                        StrSearchObjID += ',';
                    StrSearchObjID  += '\'' + String.valueOf(lstSearchObj[i].id)+ '\'';*/
                }  
                //if(StrSearchObjID != null && StrSearchObjID.length() > 0){
                if(!setProcessId.isEmpty()){
                    //DeleteConfingLst = database.query('Select SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c,  SVMXC__Field_Name__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where ( RecordTypeId=\''+String.escapeSingleQuotes(ConfigExpRTypeId)+'\' AND (SVMXC__Expression_Type__c = \'SRCH_Object_Fields\' AND SVMXC__Expression_Type__c = \'SRCH_Object_Prefilter_Criteria\') AND SVMXC__Expression_Rule__r.Id in ('+String.escapeSingleQuotes(StrSearchObjID)+'))');
                    DeleteConfingLst = [Select SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c,  SVMXC__Field_Name__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c WHERE RecordTypeId =: String.escapeSingleQuotes(ConfigExpRTypeId) AND (SVMXC__Expression_Type__c = 'SRCH_Object_Fields' OR SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria') AND SVMXC__Expression_Rule__r.Id IN: setProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
            }
            if(lstSearchProcess != null && lstSearchProcess.size() > 0){
                //delete lstSearchProcess;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete lstSearchProcess; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    IsHdrMsg = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,System.label.COMM001_TAG142));
                    return null;
                }
            }
            if(lstSearchObj != null && lstSearchObj.size() > 0){
                //delete lstSearchObj;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete lstSearchObj; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    IsHdrMsg = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,System.label.COMM001_TAG142));
                    return null;
                }
            }
            if(DeleteConfingLst != null && DeleteConfingLst.size() > 0){
                //delete DeleteConfingLst;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete DeleteConfingLst; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    IsHdrMsg = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,System.label.COMM001_TAG142));
                    return null;
                }
            }
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG017()));
            
            for(Integer i=selectedLines.size()-1;i>=0;i--)
                lstCustomSearch.remove(selectedLines.get(i));
            
            pageref1= new PageReference('/apex/CONF_ManageSearchConfiguration');
            pageRef1.setRedirect(true); 
            return null;      
        }
        catch(exception ex)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,ex.getMessage()));
            return null;
        }
    }
    
    /******************************************* Rule Sequence ********************************************************/
    public List<SVMXC__ServiceMax_Processes__c> TempSearchesLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getTempSearchesLst(){return this.TempSearchesLst;}
    public List<SelectOption> Seqoptions = new List<SelectOption>();
    public Map<string,Integer> StrIntMap = new Map<string,Integer>();
    public string[] items = new String[]{};
    public string[] getitems(){return items;}
    public void setitems(string[] o){this.items=o;}
    public boolean displaySeqPopup = false;
    public integer IntSelIndex = 0;
    public boolean IsUpAction = false;
    public boolean IsDownAction = false;
    public boolean IsTopAction = false;
    public boolean IsBottomAction = false;
    public boolean getdisplaySeqPopup(){return displaySeqPopup;}
    
    
    /**************** Rule Sequence Method ************************/
    public void Search_Sequence()
    {
        TempSearchesLst.clear();
        TempSearchesLst = [select SVMXC__Select__c, SVMXC__ProcessID__c, LastModifiedById, LastModifiedBy.LastModifiedDate, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c ='Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        // AND SVMXC__IsStandard__c = false 
        displaySeqPopup = true;
    }   
    
    /**************** Method to display Rule list for sequence changes ************************/
    public List<SelectOption> getSeqoptions()
    { 
        Seqoptions = new List<SelectOption>();   
        if (TempSearchesLst.Size() >0)
        {
            for(SVMXC__ServiceMax_Processes__c s:TempSearchesLst)
            {                
                if (s.SVMXC__Name__c != null)
                Seqoptions.add(new SelectOption(s.Id,s.SVMXC__Name__c));
            }
        }  
        return Seqoptions; 
    }
    
    /**************** shuffle Method ************************/
    public void shuffle(integer IntSelIndex, boolean isTop )
    {
        SVMXC__ServiceMax_Processes__c temp;
        if(isTop)
        {
          temp = TempSearchesLst[IntSelIndex];
          for(integer j=IntSelIndex;j>0;j--)
          {
            TempSearchesLst[j] = TempSearchesLst[j-1];
          }
          TempSearchesLst[0] = temp;
        }
        else 
        {
          temp = TempSearchesLst[IntSelIndex];
          for(integer j=IntSelIndex;j<TempSearchesLst.size()-1;j++)
          {
            TempSearchesLst[j] = TempSearchesLst[j+1];
          }
          TempSearchesLst[TempSearchesLst.size()-1] = temp;
        }
    }  
    public void UP()
    { 
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempSearchesLst.size();j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i]==TempSearchesLst[0].Id)
                {
                    TempSearchesLst[j] = TempSearchesLst[j];
                    break;
                }
                else if(items[i]==TempSearchesLst[j].Id)
                {
                    temp = TempSearchesLst[j]; 
                    TempSearchesLst[j] = TempSearchesLst[j-1];
                    TempSearchesLst[j-1]=temp;     
                    IntSelIndex = j;
                    IsUpAction = true;
                    IsDownAction=false;
                    IsTopAction=false;
                    IsBottomAction=false;
                    TempSearchesLst[IntSelIndex-1].SVMXC__Sequence__c=IntSelIndex-1;
                    TempSearchesLst[IntSelIndex].SVMXC__Sequence__c = IntSelIndex;
                }
            }
        }
    }
    public void Down()
    {  
        SVMXC__ServiceMax_Processes__c temp;
        for(integer i=0;i<items.size();i++)
        {
          StrIntMap.Put(items[i],i);
        }
        for(integer i=0;i<items.size();i++)
        {
            for(integer k=0;k<TempSearchesLst.size()-1;k++)
            {
                if(items[i]==TempSearchesLst[k].Id)
                {
                    temp = TempSearchesLst[k];
                    TempSearchesLst[k] = TempSearchesLst[k+1];
                    TempSearchesLst[k+1]=temp;
                    IntSelIndex = k;
                    IsUpAction = false;
                    IsDownAction=true;
                    IsTopAction=false;
                    IsBottomAction=false;
                    TempSearchesLst[IntSelIndex+1].SVMXC__Sequence__c=IntSelIndex+1;
                    TempSearchesLst[IntSelIndex].SVMXC__Sequence__c = IntSelIndex;
                    break;       
                }
            }
        } 
    }
    public void Top()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempSearchesLst.size()-1;j>0;j--)
        {
            for(integer i=items.size()-1;i>=0;i--)
            {
                if(items[i] == TempSearchesLst[j].Id)
                {
                    IntSelIndex = j;
                    IsUpAction = false;
                    IsDownAction=false;
                    IsTopAction=true;
                    IsBottomAction=false;
                    shuffle(IntSelIndex, true);     
                }
            }
        }  
    }
    public void Bottom()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempSearchesLst.size()-1;j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i] == TempSearchesLst[j].Id)
                {
                    IntSelIndex = j;
                    IsUpAction = false;
                    IsDownAction=false;
                    IsTopAction=false;
                    IsBottomAction=true;     
                    shuffle(IntSelIndex, false); 
                }
            }
        }  
    }
    
    /**************** Method to save Rule Sequences************************/
    public pagereference SVMX_SaveSequence()
    {
        SVMXC__ServiceMax_Processes__c temp;
        double t;
        if(IsUpAction)
        {
            for(integer i=0;i<TempSearchesLst.size();i++)
            {
                TempSearchesLst[i].SVMXC__Sequence__c=i+1;
            }
            //update TempSearchesLst;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempSearchesLst, COMM_SecurityUtils.Access.Updateable)){
                update TempSearchesLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        else if(IsDownAction)
        {
            for(integer i=0;i<TempSearchesLst.size();i++)
            {
                TempSearchesLst[i].SVMXC__Sequence__c=i+1;
            }
            //update TempSearchesLst;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempSearchesLst, COMM_SecurityUtils.Access.Updateable)){
                update TempSearchesLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        else if(IsTopAction)
        {
            for(integer i=0;i<TempSearchesLst.size();i++)
            {
                TempSearchesLst[i].SVMXC__Sequence__c=i+1;
            }
            //update TempSearchesLst;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempSearchesLst, COMM_SecurityUtils.Access.Updateable)){
                update TempSearchesLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        else if(IsBottomAction)
        {
            for(integer i=0;i<TempSearchesLst.size();i++)
            {
                TempSearchesLst[i].SVMXC__Sequence__c=i+1;
            }
            //update TempSearchesLst;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempSearchesLst, COMM_SecurityUtils.Access.Updateable)){
                update TempSearchesLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        lstCustomSearch.clear();
        lstCustomSearch.addAll(TempSearchesLst);
        displaySeqPopup = false;
        return null;  
    }
    public pagereference SVMX_PopupCancel()
    {
        displaySeqPopup = false;
        return null;
    }
    
    
    /***********************Tags methods ***********************/
    public string getHLPURL() {return system.label.CONF031_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
    public String getTAG001(){return System.Label.COMM001_TAG043;} //'View'
    public String getTAG002(){return System.Label.CONF031_TAG001;} //'Standard Searches'
    public String getTAG003(){return System.Label.COMM001_TAG044;} //'Select'
    public String getTAG004(){return System.Label.CONF031_TAG002;} //'Search ID'
    public String getTAG005(){return System.Label.CONF031_TAG003;} //'Search Title'
    public String getTAG006(){return System.Label.COMM001_TAG017;} //'Description'
    public String getTAG007(){return System.Label.CONF031_TAG004;} //'Status'  
    public String getTAG008(){return System.Label.CONF031_TAG005;} //'Last Modified On'
    public String getTAG009(){return              customSecLabel;} //'Custom Searches' or 'SFM Searches' 
    public String getTAG010(){return System.Label.COMM001_TAG045;} //'Clone'
    public String getTAG011(){return System.Label.CONF031_TAG007;} //'Manage Permissions'
    public String getTAG012(){return System.Label.COMM001_TAG046;} //'Back To Setup Home'
    public String getTAG013(){return System.Label.COMM001_TAG047;} //'New'
    public String getTAG014(){return System.Label.COMM001_TAG048;} //'Edit'
    public String getTAG015(){return System.Label.COMM001_TAG049;} //'Delete'
    public String getTAG016(){return System.Label.COMM001_TAG050;} //'Please select atleast one process.'
    public String getTAG017(){return System.Label.COMM001_TAG052;} //'Record(s) Deleted'
    public String getTAG018(){return System.Label.COMM001_TAG057;} //'Are you sure?'
    public String getTAG019(){return System.Label.COMM001_TAG051;} //'Please select only one process.'
}