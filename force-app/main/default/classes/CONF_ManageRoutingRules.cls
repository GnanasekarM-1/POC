public with sharing class CONF_ManageRoutingRules 
{
    /*********************** Global variables ***********************/
    public boolean IsHdrMsg = false;
    public boolean getIsHdrMsg(){return this.IsHdrMsg = IsHdrMsg;}
    public void setIsHdrMsg(boolean b){IsHdrMsg = b;}
    public string StrRoutID='';
    public List<RecordType> ProcessRType = new List<RecordType>(); 
    public String StrSVMXRuleId = ''; 
    public List<RecordType> ConfigRType = new List<RecordType>(); 
    public String StrConfigExpId = '';     
    public LIST<SVMXC__ServiceMax_Processes__c> RulesProcessLst = new LIST<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getRulesProcessLst(){return RulesProcessLst;}
    public void setRulesProcessLst(List<SVMXC__ServiceMax_Processes__c> processLst){RulesProcessLst = processLst;}
    public boolean getRuleLstSize()
    {
        if(RulesProcessLst.size() == 0)
            return true;
        else
            return false;
    }
    
    /*********************** Constructor ***********************/
    public CONF_ManageRoutingRules()
    {
        ProcessRType = Database.query('Select r.Name, r.Id From RecordType r where SobjectType=\'SVMXC__ServiceMax_Processes__c\'');
        for(RecordType r : ProcessRType)
        {
            if(r.Name == 'SVMX Rule')
                StrSVMXRuleId = r.id;
        }
        ConfigRType = Database.query('Select r.Name, r.IsActive, r.Id From RecordType r where SobjectType=\'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRType)
        {
            if(r.Name == 'Expressions')
                StrConfigExpId = r.id;
        }   
        RulesProcessLst = [select SVMXC__Select__c, SVMXC__Sequence__c, SVMXC__Active__c, LastModifiedBy.Name, SVMXC__APL_Route_Rule_Type__c ,LastModifiedDate , LastModifiedBy.LastModifiedDate, SVMXC__Name__C, SVMXC__Description__c, SVMXC__Advance_Expression__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='SVMX Rule' And SVMXC__Rule_Type__c = 'Routing Rule'  ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
    }
  
    /*********************** EDIT METHOD ***********************/
    public PageReference SVMXEditRules() 
    {
        if(IsValid() == true)
        {
            for(integer i=0;i<RulesProcessLst.size();i++)
            {
                if(RulesProcessLst[i].SVMXC__Select__c==true)
                    StrRoutID = RulesProcessLst[i].id;
            }
            PageReference pageRef = new PageReference('/apex/CONF_SetupRoutingRules');
            pageRef.setRedirect(true);
            pageRef.getParameters().put('SVMX_RecordID',StrRoutID);
            pageRef.getParameters().put('SVMX_Mode','Edit');
            return pageRef;
        }
        return null;
    } 
    
    /*********************** Clone METHOD ***********************/
    public PageReference SVMXCloneRules() 
    {
        if(IsValid() == true)
        {
            for(integer i=0;i<RulesProcessLst.size();i++)
            {
                if(RulesProcessLst[i].SVMXC__Select__c==true)
                    StrRoutID = RulesProcessLst[i].id;
            }
            PageReference pageRef = new PageReference('/apex/CONF_SetupRoutingRules');
            pageRef.setRedirect(true);
            pageRef.getParameters().put('SVMX_RecordID',StrRoutID);
            pageRef.getParameters().put('SVMX_Mode','Clone');
            return pageRef;
        }
        return null;
    } 
    
    /*********************** BackToSetupHome Method ***********************/
    public PageReference BackToSetupHome() 
    {
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        //PageReference pRef = new PageReference('/apex/CONF_SetupHome');  
        PageReference pRef = new PageReference(url);  
        return pRef;
    }
    
    /*********************** New Method ***********************/
    public pagereference SVMXNewRules() 
    {
        PageReference pageref= new PageReference('/apex/CONF_SetupRoutingRules');
        pageRef.setRedirect(true);
        pageRef.getParameters().put('SVMX_Mode','New');
        return pageref; 
    }
    
    /*********************** Delete Method ***********************/
    public List<SVMXC__ServiceMax_Processes__c> RouteRuleProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> DeleteConfingLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    public String StrRouteRuleID = ''; 
    public pagereference SVMXdeleteRules()
    {
        IsHdrMsg = false;
        PageReference pageref1 = null;
        RouteRuleProcessLst.clear();
        DeleteConfingLst.clear();
        List<Integer> SelectedLines = new List<Integer>();
        for(integer i=0;i<RulesProcessLst.size();i++)
        {
            if( RulesProcessLst[i].SVMXC__Select__c==true)
            {
                RouteRuleProcessLst.add(RulesProcessLst[i]);
                SelectedLines.add(i);
                if(StrRouteRuleID.length() > 0)
                    StrRouteRuleID += ',';
                StrRouteRuleID  += '\'' + String.valueOf(RulesProcessLst[i].id)+ '\'';
                RulesProcessLst[i].SVMXC__Select__c = false;
            }
        }  
        if(SelectedLines.size() == 0)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017()));
            return null;
        }
        try
        {
            DeleteConfingLst = database.query('Select SVMXC__Location__c, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c,  SVMXC__Field_Name__c,  SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where (SVMXC__Dispatch_Process__r.SVMXC__Rule_Type__c = \'Routing Rule\' and  RecordTypeId=\''+StrConfigExpId+'\'and SVMXC__Expression_Type__c =\'ROUTE_RULE_EXP\' and SVMXC__Dispatch_Process__r.Id in('+StrRouteRuleID+') ) or (SVMXC__Dispatch_Process__r.Id in('+StrRouteRuleID+') ) ');
        
            if(RouteRuleProcessLst.size() > 0){
                //delete RouteRuleProcessLst;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete RouteRuleProcessLst; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    IsHdrMsg = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    return null;
                }
            }
            if(DeleteConfingLst.size() > 0){
                //delete DeleteConfingLst;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete DeleteConfingLst; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    IsHdrMsg = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    return null;
                }
            }
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG018()));
            for(Integer i=selectedLines.size()-1;i>=0;i--)
            {
                RulesProcessLst.remove(selectedLines.get(i));
            }
            for(integer i=0; i<RulesProcessLst.size();i++) 
                RulesProcessLst[i].SVMXC__Sequence__c = i+1;
            //update RulesProcessLst;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( RulesProcessLst, COMM_SecurityUtils.Access.Updateable ) ) {
                update RulesProcessLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                IsHdrMsg = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
            pageref1= new PageReference('/apex/CONF_ManageRoutingRules');
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
      
    /*********************** Method for Validation ***********************/
    public  Boolean IsValid()
    {
        Boolean IsValid = true;
        IsHdrMsg = false;
        List<integer> selectindex1 = new  List<integer>();
        system.debug('Test1:'+RulesProcessLst);
        for(integer i=0;i<RulesProcessLst.size();i++)
        { 
            if(RulesProcessLst[i].SVMXC__Select__c==true)
                selectindex1.add(i);
        }
        if(selectindex1.size() == 0)
        {
            IsValid = false;
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG020()));
        }
        else if(selectindex1.size() > 1)
        {
            for(integer i=0;i<RulesProcessLst.size();i++)
            { 
                if(RulesProcessLst[i].SVMXC__Select__c==true)
                    RulesProcessLst[i].SVMXC__Select__c=false;
            }        
            IsValid = false;
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG021()) );
        }
        return IsValid;
    } 
    
    /******************************************* Rule Sequence ********************************************************/
    public List<SVMXC__ServiceMax_Processes__c> TempRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
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
    public void SVMX_RuleSequence()
    {
        TempRuleLst.clear();
        TempRuleLst = Database.Query('select SVMXC__Select__c, SVMXC__Sequence__c, SVMXC__Active__c, LastModifiedBy.Name, SVMXC__APL_Route_Rule_Type__c ,LastModifiedDate , LastModifiedBy.LastModifiedDate, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c where  RecordTypeId = \'' + StrSVMXRuleId + '\' And SVMXC__Rule_Type__c = \'Routing Rule\'  ORDER BY SVMXC__Sequence__c');
        displaySeqPopup = true;
    }   
    
    /**************** Method to display Rule list for sequence changes ************************/
    public List<SelectOption> getSeqoptions()
    { 
        Seqoptions = new List<SelectOption>();   
        if (TempRuleLst.Size() >0)
        {
            for(SVMXC__ServiceMax_Processes__c s:TempRuleLst)
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
          temp = TempRuleLst[IntSelIndex];
          for(integer j=IntSelIndex;j>0;j--)
          {
            TempRuleLst[j] = TempRuleLst[j-1];
          }
          TempRuleLst[0] = temp;
        }
        else 
        {
          temp = TempRuleLst[IntSelIndex];
          for(integer j=IntSelIndex;j<TempRuleLst.size()-1;j++)
          {
            TempRuleLst[j] = TempRuleLst[j+1];
          }
          TempRuleLst[TempRuleLst.size()-1] = temp;
        }
    }  
    public void UP()
    { 
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempRuleLst.size();j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i]==TempRuleLst[0].Id)
                {
                    TempRuleLst[j] = TempRuleLst[j];
                    break;
                }
                else if(items[i]==TempRuleLst[j].Id)
                {
                    temp = TempRuleLst[j]; 
                    TempRuleLst[j] = TempRuleLst[j-1];
                    TempRuleLst[j-1]=temp;     
                    IntSelIndex = j;
                    IsUpAction = true;
                    IsDownAction=false;
                    IsTopAction=false;
                    IsBottomAction=false;
                    TempRuleLst[IntSelIndex-1].SVMXC__Sequence__c=IntSelIndex-1;
                    TempRuleLst[IntSelIndex].SVMXC__Sequence__c = IntSelIndex;
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
            for(integer k=0;k<TempRuleLst.size()-1;k++)
            {
                if(items[i]==TempRuleLst[k].Id)
                {
                    temp = TempRuleLst[k];
                    TempRuleLst[k] = TempRuleLst[k+1];
                    TempRuleLst[k+1]=temp;
                    IntSelIndex = k;
                    IsUpAction = false;
                    IsDownAction=true;
                    IsTopAction=false;
                    IsBottomAction=false;
                    TempRuleLst[IntSelIndex+1].SVMXC__Sequence__c=IntSelIndex+1;
                    TempRuleLst[IntSelIndex].SVMXC__Sequence__c = IntSelIndex;
                    break;       
                }
            }
        } 
    }
    public void Top()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempRuleLst.size()-1;j>0;j--)
        {
            for(integer i=items.size()-1;i>=0;i--)
            {
                if(items[i] == TempRuleLst[j].Id)
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
        for(integer j=0;j<TempRuleLst.size()-1;j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i] == TempRuleLst[j].Id)
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
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            //update TempRuleLst;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempRuleLst, COMM_SecurityUtils.Access.Updateable ) ) {
                update TempRuleLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
        }
        else if(IsDownAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            //update TempRuleLst;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempRuleLst, COMM_SecurityUtils.Access.Updateable ) ) {
                update TempRuleLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
        }
        else if(IsTopAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            //update TempRuleLst;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempRuleLst, COMM_SecurityUtils.Access.Updateable ) ) {
                update TempRuleLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
        }
        else if(IsBottomAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            //update TempRuleLst;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempRuleLst, COMM_SecurityUtils.Access.Updateable ) ) {
                update TempRuleLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
        }
        RulesProcessLst.clear();
        RulesProcessLst.addAll(TempRuleLst);
        displaySeqPopup = false;
        return null;  
    }
    public pagereference SVMX_PopupCancel()
    {
        displaySeqPopup = false;
        return null;
    }
    
    
    /***********************Tags methods ***********************/
    public String getTAG001(){return System.Label.CONF022_TAG001;}  // Routing Rules
    public String getTAG002(){return System.Label.CONF022_TAG002;}  //Select
    public String getTAG003(){return System.Label.CONF022_TAG003;}  //Sequence
    public String getTAG004(){return System.Label.CONF022_TAG004;}  //Rule Title
    public String getTAG005(){return System.Label.CONF022_TAG005;}  //Rule Type
    public String getTAG006(){return System.Label.CONF022_TAG006;}  //Rule Details
    public String getTAG007(){return System.Label.CONF022_TAG007;}  //Active
    public String getTAG008(){return System.Label.CONF022_TAG008;}  //Last Modified By
    public String getTAG009(){return System.Label.CONF022_TAG009;}  //Processing...
    public String getTAG010(){return System.Label.CONF022_TAG010;}  //New
    public String getTAG011(){return System.Label.CONF022_TAG011;}  //Edit
    public String getTAG012(){return System.Label.CONF022_TAG012;}  //Clone
    public String getTAG013(){return System.Label.CONF022_TAG013;}  //Rule Sequence
    public String getTAG014(){return System.Label.CONF022_TAG014;}  //Delete
    public String getTAG015(){return System.Label.CONF022_TAG015;}  //Back To Setup Home
    public String getTAG016(){return System.Label.CONF022_TAG016;}  //No record to display
    public String getTAG017(){return System.Label.CONF022_TAG017;}  //Please select atleast one record to perform action
    public String getTAG018(){return System.Label.CONF022_TAG018;}  //Record(s) Deleted'
    public String getTAG019(){return System.Label.CONF022_TAG019;}  //Are you sure to delete the selected Rule(s)?
    public String getTAG020(){return System.Label.CONF022_TAG020;}  //Please select atleast one Rule.
    public String getTAG021(){return System.Label.CONF022_TAG021;}  //Please select only one Rule.
    public string getHLPURL() {return system.label.CONF022_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
}