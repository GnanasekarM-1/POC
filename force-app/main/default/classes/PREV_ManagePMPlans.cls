public  with Sharing class PREV_ManagePMPlans 
{
    //------------------------NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    //--------------------------------------
   
    //Global Variable Declaration......
    
    public List<SVMXC__PM_Plan__c> PMPlan = new List<SVMXC__PM_Plan__c>();
    public SVMXC__Service_Contract__c SContract = new SVMXC__Service_Contract__c();
    public List<SVMXC__PM_Plan__c> PMDeleteList = new List<SVMXC__PM_Plan__c>();
    public List<SVMXC__PM_Coverage__c> PMCoverageData = new List<SVMXC__PM_Coverage__c>();
    public List<SVMXC__Service_Order__c> WOLst = new List<SVMXC__Service_Order__c>();
    public List<Case> CaseLst = new List<Case>();
    public List<Integer> selectedLines = new List<Integer>();
    public string SCID = System.currentPageReference().getParameters().get('scid');
    public String PMId;
    public String PCID = '';
    public String strid = '';
    public String PMPlanid = '';
    public Map<id,List<SVMXC__PM_Coverage__c>> mapofpm = new Map<id,List<SVMXC__PM_Coverage__c>>();
    public List<SVMXC__PM_Coverage__c> DelPMC = new List<SVMXC__PM_Coverage__c>();
    public String PMPlanFieldNames;
    public Boolean DisplayRecord = false;
    public boolean SVMX_checkBoxValidation = true;
    
    SVMXC.COMM_Utils Utils = new SVMXC.COMM_Utils();
    
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('PREV001');

    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('PREV001'); 
   
   
    //Constructor......
    public PREV_ManagePMPlans() 
    {   
        try
        {      
            //Get the PM Plan Fields Names .........
            Schema.DescribeSObjectResult dsoResultPM = SVMXC__PM_Plan__c.sObjectType.getDescribe();
            Map<String, SObjectField> PMPlanfieldMap = Schema.SObjectType.SVMXC__PM_Plan__c.fields.getMap();
             /**********Duplicate Check*********************/
             SVMXC.COMM_Utils_V2 commutils = new SVMXC.COMM_Utils_V2();
             PMPlanfieldMap = commutils.removeDuplicateFields(PMPlanfieldMap);
            /***********************************************/
            
            PMPlanFieldNames = utils.SVMX_getFieldNamesFromList(utils.SVMX_getFieldList(PMPlanfieldMap,true));      
            
            if(SVMX_IsValidID(SCID))
            {
                //First Query the Service Controct.... 
                SContract = Database.Query('Select id,name From SVMXC__Service_Contract__c s where id =\''+SCID+'\''); 
                system.debug('SContract'+SContract);
                
                //Second Query the PM Plan....
                PMPlan = Database.Query(' SELECT ' + PMPlanFieldNames + ' From SVMXC__PM_Plan__c s where  s.SVMXC__Service_Contract__c  =\''+SCID+'\' order by CreatedDate DESC');                  
                system.debug('PMPlan'+PMPlan);
                /*if(PMPlan.size() > 0)
                {
                    for(SVMXC__PM_Plan__c PM : PMPlan)
                    {
                        if(strid.length() > 0)
                            strid += ',';
                        strid  += '\'' + String.valueOf(PM.id)+ '\'';
                        
                    }
                    PMCoverageData = Database.Query('Select s.SVMXC__Product_Name__c, s.SVMXC__PM_Plan__c, name, s.Id  From SVMXC__PM_Coverage__c s where SVMXC__PM_Plan__c in('+strid+')');
                }
                for(Integer i = 0; i < PMPlan.size(); i++)
                {   
                    List<SVMXC__PM_Coverage__c> PMCData = new List<SVMXC__PM_Coverage__c>();
                    for(Integer j = 0; j<PMCoverageData.size(); j++)
                    {   
                        if(PMPlan[i].id == PMCoverageData[j].SVMXC__PM_Plan__c)
                            PMCData.add(PMCoverageData[j]);
                    }   
                    mapofpm.put(PMPlan[i].id,PMCData);
                }
                system.debug('mapofpm'+mapofpm);    */
            }
        }
        catch (Exception ex)
        {
            HdrMsg =true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
        }
    }   
    
    
    // Getter & Setter ......   
    public SVMXC__Service_Contract__c getSContract(){ return SContract;}
    public void setSContract(SVMXC__Service_Contract__c SC) {SContract = SC;}
    public List<SVMXC__PM_Plan__c> getPMPlans() { return PMPlan; }
    public void setPMPlans(List<SVMXC__PM_Plan__c> PM) {PMPlan = PM;}
    
    //Button Methods..........
   
    //////// New PM Plan...................
    public PageReference SVMX_NewPMPlan()
    {
        try
        {
            string url = '';
            if(svmxSettingList.containsKey('SET001'))
                 url = svmxSettingList.get('SET001');
            PageReference newPage = new PageReference(url);
            newPage.getparameters().put('scid',SCID);
            newPage.setRedirect(true); 
            return newPage;
        }
        catch(Exception ex)
        {
            HdrMsg =true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
        }
         return null;
    }
    //Edit PM Plan........
    public PageReference SVMX_EditPMPlan()
    {
        try
        {
            System.debug('hari'+PMPlan);
            if(SVMX_checkBoxValidation())
            {
                string url = '';
                if(svmxSettingList.containsKey('SET001'))
                    url = svmxSettingList.get('SET001');
                PageReference editPage = new PageReference(url);
                editPage.getparameters().put('scid',SCID);
                editPage.getparameters().put('peid',PMId);
                editPage.setRedirect(true);
                return editPage;
            }
            else
            {
                HdrMsg =true;
                
                return null;
            }
        }
        catch(Exception ex)
        {
            HdrMsg =true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
        }    
        return null;
    }

    //Delete PM Plan....
    public PageReference SVMX_DeletePMPlan()
    {
        try
        {
            PMDeleteList.clear();
            selectedLines.clear();
            if(SVMX_IsValid() == true)
            {
                for(integer i = 0; i<PMPlan.size();i++)
                {
                    if(PMPlan[i].SVMXC__select__c == true)
                    {
                        selectedLines.add(i); 
                        PMDeleteList.add(PMPlan[i]);
                        if(PMPlanid.length() > 0)
                            PMPlanid += ',';
                        PMPlanid  += '\'' + String.valueOf(PMPlan[i].id)+ '\'';
                    }
               }
               system.debug('PMPlanid'+PMPlanid);
               if(PMPlanid.length() > 0)
               {
                    WOLst = Database.Query('Select s.Id From SVMXC__Service_Order__c s where SVMXC__PM_Plan__c in (' + PMPlanid + ')'); 
                    CaseLst = Database.Query('Select c.Id From Case c where SVMXC__PM_Plan__c in (' + PMPlanid + ')'); 
               }
               system.debug('WOLst'+WOLst.size());  
               system.debug('CaseLst'+CaseLst.size());  
               system.debug('PMDeleteList'+PMDeleteList.size());  
               system.debug('selectedLines'+selectedLines.size());  
               if(selectedLines.size() == 0)
               {
                  HdrMsg = true;
                  ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,getTAG015()));   
               }
               if(WOLst.size() > 0 )
               {
                    HdrMsg = true;
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,getTAG018())); 
               }
               if(CaseLst.size() > 0 )
               {
                    HdrMsg = true;
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,getTAG023())); 
               }
            }
            else
            {
                HdrMsg = true;
            }
            if(PMDeleteList.size()>0 && CaseLst.size() == 0 && WOLst.size() == 0)
            {   
                
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__PM_Plan__c' ) ) {
                    
                    delete PMDeleteList; //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
                    HdrMsg = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
                
                HdrMsg = true;
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.CONFIRM,getTAG021())); 
                for(Integer i=selectedLines.size()-1;i>=0;i--)
                {
                    PMPlan.remove(selectedLines.get(i));
                }
            }
            
        }
        catch(Exception ex)
        {
            HdrMsg =true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
        }      
           
        return null;
    }
    //clone PM plan......
    public PageReference SVMX_ClonePMPlan()
    {
        try
        {
            if(SVMX_checkBoxValidation())
            {
                string url = '';
                if(svmxSettingList.containsKey('SET001'))
                    url = svmxSettingList.get('SET001');
                PageReference clonePage = new PageReference(url);
                clonePage.getparameters().put('scid',SCID);
                clonePage.getparameters().put('pcid',PMId);
                clonePage.setRedirect(true);
                return clonePage;
            }
            else
            {
                HdrMsg =true;
                return null;    
            }
        } 
        catch(Exception ex)
        {
            HdrMsg =true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
        }  
        return null;
    }
    //Back To Service Contarct.......
    public PageReference SVMX_BackToSC()
    { 
        try
        {
            PageReference NewPage = new PageReference('/' + SCID);
            NewPage.setRedirect(true);
            return NewPage;
        }
        catch(Exception ex)
        {
            HdrMsg =true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
        }   
        return null;  
    }
    
    //Validation Methods........
    public boolean SVMX_IsValidID(String id)
    {
        if (id <> null && id <> '' && id.length() > 0)
            return true;
        else
            return false;
    }
    
    
    public Boolean SVMX_checkBoxValidation()
    {
        try
        {
            SVMX_checkBoxValidation = true;
            List<Integer> selectedLines = new List<Integer>();
            for(Integer i=0;i<PMPlan.size();i++)
            {
                if(PMPlan.get(i).SVMXC__Select__c == true)
                {
                    selectedLines.add(i);
                    PMId = PMPlan.get(i).id;    
                }
            }
            if(selectedLines.size() == 0)
            {
                SVMX_checkBoxValidation =  false; 
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG015()));         
            }
            if(selectedLines.size() > 1)
            {
                SVMX_checkBoxValidation =  false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG022()));        
            }
        }
        catch(Exception ex)
        {
            HdrMsg =true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
        }  
        return SVMX_checkBoxValidation;    
    }
    public Boolean IsValid = true;
    public Boolean SVMX_IsValid()
    {
        try
        {
            IsValid = true;
            List<Integer> selectedLines = new List<Integer>();
            for(Integer i = 0;i < PMPlan.size(); i++)
            {
                if(PMPlan[i].SVMXC__Processed__c == true)
                {
                    IsValid =false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG018())); 
                    
                }   
            }
        }
        catch(Exception ex)
        {
            HdrMsg =true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
        }    
       return IsValid;
    }
    
    
    //======================================== Set true to display blocklevel messge ===================================================//
    public Boolean HdrMsg = false;
    public Boolean getHdrMsg(){ return HdrMsg; }  
    
    
    public Boolean getDisplayRecord()
    {
        if(PMPlan.size() > 0)
        {
            DisplayRecord = true;
        }
        
        return DisplayRecord; 
    }  
//  public Boolean getIsWarn(){ if(QuoteSaveStatus.toUpperCase()=='WARN' && IsWarn==true)return true;else return false; }
    
    
    // Tags 
    public string getHLPURL(){return system.label.PREV001_HLPURL;}
    public String getTAG001(){ return system.label.PREV001_TAG001;}//Preventive Manitenance Plan for Service Contract 
    public String getTAG002(){ return system.label.PREV001_TAG002;}//Help
    public String getTAG003(){ return system.label.PREV001_TAG003;}//New Plan PM
    public String getTAG004(){ return system.label.PREV001_TAG004;}//Edit
    public String getTAG005(){ return system.label.PREV001_TAG005;}//Delete
    public String getTAG006(){ return system.label.PREV001_TAG006;}//Clone
    public String getTAG007(){ return system.label.PREV001_TAG007;}//Back To Service Controat
    public String getTAG008(){ return system.label.PREV001_TAG008;}//Select
    public String getTAG009(){ return system.label.PREV001_TAG009;}//PM Plan Name
    public String getTAG010(){ return system.label.PREV001_TAG010;}//Description
    public String getTAG011(){ return system.label.PREV001_TAG011;}//Status
    public String getTAG012(){ return system.label.PREV001_TAG012;}//Start Date
    public String getTAG013(){ return system.label.PREV001_TAG013;}//End Date
    public String getTAG014(){ return system.label.PREV001_TAG014;}//Next Date
    public String getTAG015(){ return system.label.PREV001_TAG015;}//Select Atleast one checkbox to perform action
    public String getTAG016(){ return system.label.PREV001_TAG016;}//No Record to Display
    public String getTAG017(){ return system.label.PREV001_TAG017;}//Processing...
    public String getTAG018(){ return system.label.PREV001_TAG018;}//This plan cannot be deleted since it has already been used to create work orders. To prevent future work orders, please deactivate the plan
    public String getTAG019(){ return system.label.PREV001_TAG019;}//All information including product coverage in this PM plan will be removed permanently. Are you sure to proceed?
    public String getTAG020(){ return system.label.PREV001_TAG020;}//Are you sure to proceed
    public String getTAG021(){ return system.label.PREV001_TAG021;}//Record(s) Deleted
    public String getTAG022(){ return system.label.PREV001_TAG022;}//You can not perfrom this action on multiple PM plans
    public String getTAG023(){ return system.label.PREV001_TAG023;}
    
    /*public boolean IsWarn = false;
    public Boolean getIsWarn()  
    { 
        HdrMsg = false;
        
        selectedLines.clear(); 
        if(SVMX_IsValid() == true)
        {
            for(integer i = 0; i<PMPlan.size();i++)
            {
                if(PMPlan[i].SVMXC__select__c == true)
                {
                    selectedLines.add(i); 
                    PMDeleteList.add(PMPlan[i]);
                    if(PMPlanid.length() > 0)
                        PMPlanid += ',';
                    PMPlanid  += '\'' + String.valueOf(PMPlan[i].id)+ '\'';
                 }
           }
         }
         else
         {
            HdrMsg = true;
         }  
         if(PMPlanid.length() > 0)
         {
            WOLst = Database.Query('Select s.SystemModstamp, s.SVMXC__Work_Performed__c, s.SVMXC__Turnaround_Time__c, s.SVMXC__Total_Work_Order_Cost__c, s.SVMXC__Total_Estimate__c, s.SVMXC__Total_Billable_Amount__c, s.SVMXC__Top_Level__c, s.SVMXC__Symptom__c, s.SVMXC__Special_Instructions__c, s.SVMXC__Service_Group__c, s.SVMXC__Scheduled_Date__c, s.SVMXC__SESSION_ID__c, s.SVMXC__Root_Cause__c, s.SVMXC__Purpose_of_Visit__c, s.SVMXC__Problem_Description__c, s.SVMXC__Priority__c, s.SVMXC__PM_Tasks_Created__c, s.SVMXC__PM_SC__c, s.SVMXC__PM_Plan__c, s.SVMXC__Order_Type__c, s.SVMXC__Order_Status__c, s.SVMXC__Is_PM_Work_Order__c, s.SVMXC__How_Fixed__c, s.SVMXC__Group_Member__c, s.SVMXC__Failure_Location__c, s.SVMXC__Failed_Assembly__c, s.SVMXC__EndpointURL__c, s.SVMXC__Dispatch_Process__c, s.SVMXC__Customer_Failure_Feedback__c, s.SVMXC__Customer_Down__c, s.SVMXC__Customer_Down_Status__c, s.SVMXC__Corrective_Action__c, s.SVMXC__Contact__c, s.SVMXC__Configuration_Before__c, s.SVMXC__Configuration_After__c, s.SVMXC__Component__c, s.SVMXC__Company__c, s.SVMXC__Closed_On__c, s.SVMXC__Closed_By__c, s.SVMXC__Case__c, s.SVMXC__Billing_Type__c, s.SVMXC__Age__c, s.SVMXC__Age_Bucket__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById From SVMXC__Service_Order__c s where SVMXC__PM_Plan__c in (' + PMPlanid + ')'); 
            CaseLst = Database.Query('Select c.Type, c.SystemModstamp, c.SuppliedPhone, c.SuppliedName, c.SuppliedEmail, c.SuppliedCompany, c.Subject, c.Status, c.SVMXC__Scheduled_Date__c, c.SVMXC__PM_Plan__c, c.SVMXC__Is_PM_Case__c, c.SVMXC__Warranty__c, c.SVMXC__Top_Level__c, c.SVMXC__Site__c, c.SVMXC__Service_Contract__c, c.SVMXC__SLA_Terms__c, c.SVMXC__Product__c, c.SVMXC__Entitlement_Notes__c, c.SVMXC__Component__c, c.SVMXC__Component_Zip__c, c.SVMXC__Component_Street__c, c.SVMXC__Component_State__c, c.SVMXC__Component_Country__c, c.SVMXC__Component_City__c, c.SVMXC__Billing_Type__c, c.Reason, c.Priority, c.OwnerId, c.Origin, c.LastModifiedDate, c.LastModifiedById, c.IsEscalated, c.IsDeleted, c.IsClosed, c.Id, c.HasSelfServiceComments, c.HasCommentsUnreadByOwner, c.Description, c.CreatedDate, c.CreatedById, c.ContactId, c.ClosedDate, c.CaseNumber, c.AssetId, c.AccountId From Case c where SVMXC__PM_Plan__c in (' + PMPlanid + ')'); 
         }
         system.debug('WOLst'+WOLst.size());  
         system.debug('CaseLst'+CaseLst.size());  
         system.debug('PMDeleteList'+PMDeleteList.size());  
         system.debug('selectedLines'+selectedLines.size());  
         /*if(selectedLines.size() == 0)
         {
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,getTAG015()));     
            IsWarn = false;
         }
         if(WOLst.size() > 0 )
         {
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,getTAG023()));
            IsWarn = false;
         }
         else if(CaseLst.size() > 0 )
         {
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,getTAG024())); 
            IsWarn = false;
         }
         else
         {
            IsWarn = true;
         }
         return IsWarn;
    }   
    public String str;
    public String getMSG()
    {
        return str;
    }
    public pagereference SelctCheck()
    {
        return null;
    }*/
}