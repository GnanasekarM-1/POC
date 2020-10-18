/* Security Scanned */
public with Sharing class SLAT_ManageSLATerms 
{
    
  //Wrapper Class.... 
 
  public class SLAWrapper
  {
      //public SVMXC__SLA_Detail__c Services = new SVMXC__SLA_Detail__c();
      //public SVMXC__SLA_Detail__c getServices(){return Services;}
     // public void setServices(SVMXC__SLA_Detail__c s) {Services = s;} 
      
      public String Commitment {get; set;}
      public SVMXC__SLA_Detail__c SLADetail = new SVMXC__SLA_Detail__c();
      public SVMXC__SLA_Detail__c getSLADetail(){return SLADetail;}
      public void setSLADetail(SVMXC__SLA_Detail__c s) {SLADetail = s;} 
      
      //Connstructor......
      public SLAWrapper(SVMXC__SLA_Detail__c SLA, String xTAG045)
      {
        SLADetail = SLA;
        //system.debug('asdf222222'+SLA);
        if(SLADetail.SVMXC__Available_Services__r.SVMXC__Data_Type__c == 'Text')
        {
            Commitment = SLADetail.SVMXC__Service_Details__c;
        }
        if(SLADetail.SVMXC__Available_Services__r.SVMXC__Data_Type__c == 'Number')
        {
            Commitment = string.valueOf(SLADetail.SVMXC__Number_of_units__c);
        }
        if(SLADetail.SVMXC__Available_Services__r.SVMXC__Data_Type__c == 'Frequency')
        {
            Commitment = string.valueOf(SLADetail.SVMXC__Number_of_units__c);
            Commitment += ' '+ xTAG045 + ' ';
            Commitment +=  SLADetail.SVMXC__Frequency__c;
        }
        if(SLADetail.SVMXC__Available_Services__r.SVMXC__Data_Type__c == 'Boolean')
        {
            //Commitment = string.valueOf(SLADetail.SVMXC__Included_Or_Not__c);
            if(SLADetail.SVMXC__Included_Or_Not__c==true)
              Commitment = 'Yes';              
            if(SLADetail.SVMXC__Included_Or_Not__c==false)
              Commitment = 'No';
            
        }
        
      }
      //Inner class Method....
      public void updateCommitment (SVMXC__SLA_Detail__c SLA,SVMXC__Service__c ser,String TAG045)
      { 
        SLADetail.SVMXC__Service_Name__c = ser.Name;
        SLADetail.SVMXC__Available_Services__c = ser.id;
        SLADetail.SVMXC__Service_Details__c = '';
        SLADetail.SVMXC__Number_of_units__c = null;
        SLADetail.SVMXC__Frequency__c = '';
        SLADetail.SVMXC__Included_Or_Not__c = false;
        if(ser.SVMXC__Data_Type__c == 'Text')
        {
            Commitment = SLA.SVMXC__Service_Details__c;
            SLADetail.SVMXC__Service_Details__c = SLA.SVMXC__Service_Details__c;
        }
        if(ser.SVMXC__Data_Type__c == 'Number')
        {
            Commitment = string.valueOf(SLA.SVMXC__Number_of_units__c);
            SLADetail.SVMXC__Number_of_units__c = SLA.SVMXC__Number_of_units__c;
        }
        if(ser.SVMXC__Data_Type__c == 'Frequency')
        {
            Commitment = string.valueOf(SLA.SVMXC__Number_of_units__c);
            Commitment += ' '+ TAG045 + ' ';
            Commitment +=  SLA.SVMXC__Frequency__c;
            SLADetail.SVMXC__Number_of_units__c = SLA.SVMXC__Number_of_units__c;
            SLADetail.SVMXC__Frequency__c = SLA.SVMXC__Frequency__c;
        }
        if(ser.SVMXC__Data_Type__c == 'Boolean')
        {
            //Commitment = string.valueOf(SLA.SVMXC__Included_Or_Not__c);
            if(SLA.SVMXC__Included_Or_Not__c==true)
              Commitment = 'Yes';
            if(SLA.SVMXC__Included_Or_Not__c==false)
              Commitment = 'No';
            SLADetail.SVMXC__Included_Or_Not__c =  SLA.SVMXC__Included_Or_Not__c;
        }
      } 
        
   }
  
    //Globle Variable Declaration....
    public Integer slaCutoffIR{get;set;}//Added by Nidhi as part of BAC-4646
    public String slaCutoffZoneIR{get;set;}
    public Integer slaCutoffOR{get;set;}
    public String slaCutoffZoneOR{get;set;}
    public Integer slaCutoffRES{get;set;}
    public String slaCutoffZoneRES{get;set;}
    public Integer slaCutoffRESTO{get;set;}
    public String slaCutoffZoneRESTO{get;set;}
    public Boolean isCutOffTimeVisibleIR{get; set;}
    public Boolean isCutOffTimeVisibleOR{get; set;}
    public Boolean isCutOffTimeVisibleREST{get; set;}
    public Boolean isCutOffTimeVisibleRESO{get; set;}
    public List<SelectOption> UnitOptionsIR{get;set;}
    public List<SelectOption> UnitOptionsOR{get;set;}
    public List<SelectOption> UnitOptionsRES{get;set;}
    public List<SelectOption> UnitOptionsRESTO{get;set;}
    public List<SelectOption> slaCutOffTime1Options{get;set;}
    public List<SelectOption> slaCutOffTime2Options{get;set;}
    public Boolean isUnitIR_Disabled{get;set;}
    public Boolean isUnitOR_Disabled{get;set;}
    public Boolean isUnitRES_Disabled{get;set;}
    public Boolean isUnitRESTO_Disabled{get;set;}//Variables Added by Nidhi Ends here
    public Boolean isCaseObjAvailable   {get; set;}
    public string selectedTab;
    public String SearchKeyword = '';
    public string ParameterID;
    public String CommitmentRtypeId;
    public String ServiceRtypeId;
    public String SID = '';
    public Boolean DisbaleChkBox = false;
    public Boolean CheckAllLines = false;
    public Boolean DisbleNewBttn = false;
    public Boolean DisbleEditBttn = false;
    public Boolean DisbleDeleteBttn = false;
    public Boolean DisbleCancleBttn = True;
    public Boolean DisbleSaveBttn = True;
    public Boolean DetailSection = false;
    public Boolean HdrMsg = false;
    public Boolean panelMsg = false;
    public Boolean Tab1Msg = false;
    public Boolean Tab2Msg = false;
    public Boolean Tab3Msg = false;
    public Boolean Tab4Msg = false;
    public Boolean Tab5Msg = false;
    public boolean displayPopUp = false;
    public boolean IsEnterpriseLicense = false;
    public Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();
    public List<RecordType> RecordTypes = new List<RecordType>();
    public SVMXC__Service_Level__c SLA = new SVMXC__Service_Level__c();
    public SVMXC__SLA_Detail__c popupdetail = new SVMXC__SLA_Detail__c();
    public SVMXC__Service__c popupservice = new SVMXC__Service__c();
    public List<SVMXC__Service_Level__c> SLATerms = new list<SVMXC__Service_Level__c>();
    public List<SVMXC__Service_Level__c> DelSLATermData = new List<SVMXC__Service_Level__c>();
    public List<SVMXC__SLA_Detail__c> DelSLADetailsData = new List<SVMXC__SLA_Detail__c>();
    public SVMXC__Service_Level__c SaveSLATermData = new SVMXC__Service_Level__c();
    public List<SVMXC__SLA_Detail__c> SaveSLADetailsData = new List<SVMXC__SLA_Detail__c>();
    public List<SVMXC__SLA_Detail__c> InitialResponse = new List<SVMXC__SLA_Detail__c>();
    public List<SVMXC__SLA_Detail__c> OnsiteResponse = new List<SVMXC__SLA_Detail__c>();
    public List<SVMXC__SLA_Detail__c> Restoration = new List<SVMXC__SLA_Detail__c>();
    public List<SVMXC__SLA_Detail__c> Resolution = new List<SVMXC__SLA_Detail__c>();
    public List<SVMXC__SLA_Detail__c> Services = new List<SVMXC__SLA_Detail__c>();
    public List<SVMXC__SLA_Detail__c> SLADetailall = new List<SVMXC__SLA_Detail__c>();
    public List<SVMXC__Service__c> ServiceSearchLst = new List<SVMXC__Service__c>();
   
    public String SLATermId = '';
    public List<SelectOption> IrType = new List<SelectOption>();
    public List<SelectOption> IrPriority = new List<SelectOption>();
    public List<SelectOption> IrClock = new List<SelectOption>();
    
    public List<SelectOption> OrType = new List<SelectOption>();
    public List<SelectOption> OrPriority = new List<SelectOption>();
    public List<SelectOption> OrClock = new List<SelectOption>();
    
    public List<SelectOption> RestorationType = new List<SelectOption>();
    public List<SelectOption> RestorationPriority = new List<SelectOption>();
    public List<SelectOption> RestorationClock = new List<SelectOption>();
    
    public List<SelectOption> ResolutionType = new List<SelectOption>();
    public List<SelectOption> ResolutionPriority = new List<SelectOption>();
    public List<SelectOption> ResolutionClock = new List<SelectOption>();
    
    public Map<String, String> CaseTypeVal = new Map<String, String>();
    public Map<String, String> CasePriorityVal = new Map<String, String>();
    public Map<String, String> CaseDateTimeFld = new Map<String, String>();
    
    public Map<String, String> WOTypeVal = new Map<String, String>();
    public Map<String, String> WOPriorityVal = new Map<String, String>();
    public Map<String, String> WODateTimeFld = new Map<String, String>();
    
    SVMXC.COMM_Utils Utils = new SVMXC.COMM_Utils();
    
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('SLAT001');

    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('SLAT001'); 
    
    //Create instance of wrapper class......
    public SVMXC__SLA_Detail__c wrapsla = new SVMXC__SLA_Detail__c();
    public SLAWrapper SLAWrapperobj = new SLAWrapper(wrapsla,getTAG045()); //
    
    
    
    
    
    /***************************************************Constructor******************************************/
    public SLAT_ManageSLATerms()
    {   
        //Added by Nidhi as part of BAC-4646
        slaCutOffTime1Options = new List<SelectOption>();
        slaCutOffTime2Options = new List<SelectOption>();
        slaCutOffTime1Options.add(new selectOption('', system.label.SLAT001_TAG031));
        for(Integer i=1; i<=12;i++) slaCutOffTime1Options.add(new selectOption(string.valueOf(i),string.valueOf(i)));
        /*slaCutOffTime1Options.add(new selectOption('1', '1'));
        slaCutOffTime1Options.add(new selectOption('2', '2'));
        slaCutOffTime1Options.add(new selectOption('3', '3'));
        slaCutOffTime1Options.add(new selectOption('4', '4'));
        slaCutOffTime1Options.add(new selectOption('5', '5'));
        slaCutOffTime1Options.add(new selectOption('6', '6'));
        slaCutOffTime1Options.add(new selectOption('7', '7'));
        slaCutOffTime1Options.add(new selectOption('8', '8'));
        slaCutOffTime1Options.add(new selectOption('9', '9'));
        slaCutOffTime1Options.add(new selectOption('10', '10'));
        slaCutOffTime1Options.add(new selectOption('11', '11'));
        slaCutOffTime1Options.add(new selectOption('12', '12'));*/
        
        slaCutOffTime2Options.add(new selectOption('', system.label.SLAT001_TAG031));
        slaCutOffTime2Options.add(new selectOption('AM', 'AM'));
        slaCutOffTime2Options.add(new selectOption('PM', 'PM'));
        //Added by Nidhi as part of BAC-4646 Ends Here
        
        //Defect fix OEM : 013933 Anchal 
        //Check if the customer org has access to case Object or not
        isCaseObjAvailable = utils.SVMX_isObjectLicensed('Case');
        
        //Added by amar on 18/Aug/10 Due to OEM Exercises
        IsEnterpriseLicense = utils.SVMX_isEnterpriseLicense();
        if(IsEnterpriseLicense == false)
        {
           PermitedStndObjMap = utils.SVMX_getPermittedStandardObjectList();
        }
        getLicenseType();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordTypes = Database.query('Select r.Name, r.Id From RecordType r where SobjectType = \'SVMXC__SLA_Detail__c\'');
        //system.debug('RecordTypes'+RecordTypes);
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'Commitment')
            {
                CommitmentRtypeId = r.id;
            }
            if(r.Name == 'Services')
            {
                ServiceRtypeId = r.id;
            }
        }
        
        // 3rd-Aug-2012: Commeneted LastActivityDate to handle defect 005180.
        SLATerms = Database.Query('Select SVMXC__Resolution_Tracked_On__c,SVMXC__Restoration_Tracked_On__c,SVMXC__Onsite_Response_Tracked_On__c, SVMXC__Initial_Response_Tracked_On__c,s.SVMXC__Select__c, s.SVMXC__Description__c, s.SVMXC__Business_Hours__c, s.SVMXC__Active__c,SVMXC__SM_Initial_Unit_of_Measure__c,SVMXC__SM_Onsite_Unit_of_Measure__c,SVMXC__SM_Resolution_Unit_of_Measure__c,SVMXC__SM_Restoration_Unit_of_Measure__c,SVMXC__SM_Initial_SLA_Cutoff_Time__c,SVMXC__SM_Onsite_SLA_Cutoff_Time__c,SVMXC__SM_Resolution_SLA_Cutoff_Time__c,SVMXC__SM_Restoration_SLA_Cutoff_Time__c, s.Name, s.Id From SVMXC__Service_Level__c s Order By Name');
        //system.debug('SLATerms'+SLATerms);
        Map<String, Schema.SObjectField> CaseFieldMap = Schema.SObjectType.Case.fields.getMap();
        //system.debug('CaseFieldMap'+CaseFieldMap);
        for(Schema.SObjectField FT : CaseFieldMap.values())
        {
            Schema.DescribeFieldResult f = FT.getDescribe(); 
            if(f.getName() == 'Type')
            {   
                List<Schema.PicklistEntry> P = f.getPicklistValues();
                for(Integer i = 0; i < P.size(); i++)
                {
                    CaseTypeVal.put(P[i].getValue(),P[i].getLabel());
                }
                
            }
            if(f.getName() == 'Priority')
            {
                List<Schema.PicklistEntry> PV = f.getPicklistValues();
                for(Integer i = 0; i < PV.size(); i++)
                {
                    CasePriorityVal.put(PV[i].getValue(),PV[i].getLabel());
                }
            }
            if( f.getType() == Schema.DisplayType.DATETIME) //f.getType() == Schema.DisplayType.DATE ||(commented by amar on 23/12/09)
            {
                CaseDateTimeFld.put(f.getName(),f.getLabel());
            }   
        }
        //system.debug('CaseTypeVal'+CaseTypeVal);
        //system.debug('CasePriorityVal'+CasePriorityVal);
        //system.debug('CaseDateTimeFld'+CaseDateTimeFld);
       
        Map<String, Schema.SObjectField> WOFieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        //system.debug('WOFieldMap'+WOFieldMap);
        for(Schema.SObjectField FT : WOFieldMap.values())
        {
            Schema.DescribeFieldResult f = FT.getDescribe(); 
            if(f.getName() == 'SVMXC__Order_Type__c')
            {   
                List<Schema.PicklistEntry> P = f.getPicklistValues();
                for(Integer i = 0; i < P.size(); i++)
                {
                    WOTypeVal.put(P[i].getValue(),P[i].getLabel());
                }
                
            }
            if(f.getName() == 'SVMXC__Priority__c')
            {
                List<Schema.PicklistEntry> PV = f.getPicklistValues();
                for(Integer i = 0; i < PV.size(); i++)
                {
                    WOPriorityVal.put(PV[i].getValue(),PV[i].getLabel());
                }
            }
            if( f.getType() == Schema.DisplayType.DATETIME)   //f.getType() == Schema.DisplayType.DATE ||(commented by amar on 23/12/09)
            {
                WODateTimeFld.put(f.getName(),f.getLabel());
            }   
        }
        //system.debug('WOTypeVal'+WOTypeVal);
        //system.debug('WOPriorityVal'+WOPriorityVal);
        //system.debug('WODateTimeFld'+WODateTimeFld);
    }
    public Boolean LicenseType = false;
    public Boolean getLicenseType()
    {
      if(IsEnterpriseLicense == false)
      {
        if(PermitedStndObjMap.containskey('Case') && PermitedStndObjMap.get('Case') == true)
        {
          LicenseType = true;
        }
      }
      else
      {
        LicenseType = true;
      }
      //system.debug('LicenseType'+LicenseType);
      return LicenseType;
      
    }
    
    //PageReferenceMethods.....
   /********************************************************New SLA******************************************************/
    public SVMXC__Service_Level__c newSLA;
    public PageReference SVMX_NewSLATerm()
    {
       for(Integer i =0; i<SLATerms.size(); i++)
       {
            if(SLATerms[i].SVMXC__Select__c == true)
            {
                SLATerms[i].SVMXC__Select__c = false;
            }
       }
       newSLA = new SVMXC__Service_Level__c(SVMXC__Select__c = True); 
       
       //Picklist options for Unit fields on each clock, Added by Nidhi as part of BAC-4646
        UnitOptionsIR = new List<SelectOption>();
        UnitOptionsOR = new List<SelectOption>();
        UnitOptionsRES = new List<SelectOption>();
        UnitOptionsRESTO = new List<SelectOption>();
        Schema.sObjectType sobject_type = SVMXC__Service_Level__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
        getUnitOptions(newSLA,field_map,'SVMXC__SM_Initial_Unit_of_Measure__c',UnitOptionsIR);
        getUnitOptions(newSLA,field_map,'SVMXC__SM_Onsite_Unit_of_Measure__c',UnitOptionsOR);
        getUnitOptions(newSLA,field_map,'SVMXC__SM_Resolution_Unit_of_Measure__c',UnitOptionsRES);
        getUnitOptions(newSLA,field_map,'SVMXC__SM_Restoration_Unit_of_Measure__c',UnitOptionsRESTO);
        //Code added by Nidhi Ends Here
        
        SLATerms.add(newSLA);
        selectedTab = getTAG012();
        DisbaleChkBox = True;
        DisbleNewBttn = True;
        DisbleEditBttn = True;
        DisbleDeleteBttn = True;
        DetailSection = True;
        DisbleCancleBttn = False;
        DisbleSaveBttn = False;
        return null;
    }
    //Added by Nidhi to get the Unit of measure picklist values
    public void getUnitOptions(SVMXC__Service_Level__c SLARecord,Map<String, Schema.SObjectField> field_map,String fieldName,List<SelectOption> options){   
      List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); 
      for (Schema.PicklistEntry a : pick_list_values) {                  
            options.add(new selectOption(a.getValue(), a.getLabel()));
            if (a.defaultValue && String.isBlank(String.valueOf(SLARecord.get(fieldName)))){                
                SLARecord.put(fieldName,a.getValue());//If field value is null assign default value i.e minute                              
            }
      }
    }
    /********************************************************Edit SLA******************************************************/
    public PageReference SVMX_EditSLATerm()
    {
        InitialResponse.clear();
        OnsiteResponse.clear();
        Restoration.clear();
        Resolution.clear();
        Services.clear();
        ServiceWrapper.clear();
        SID = '';
        //system.debug('SVMX_ValidEditSALTerm()'+SVMX_ValidEditSALTerm());
        if(SVMX_ValidEditSALTerm() == True)
        {
            HdrMsg = True;
        }
        else
        {
          //system.debug('SVMX_ValidEditSALTerm()2'+SVMX_ValidEditSALTerm());
            List<integer> SelectedLines = new List<integer>();
            
            for(Integer i = 0; i < SLATerms.size(); i++)
            {
                if(SLATerms[i].SVMXC__Select__c == true)
                {
                    SLA.SVMXC__Initial_Response_Tracked_On__c = SLATerms[i].SVMXC__Initial_Response_Tracked_On__c;
                    SLA.SVMXC__Onsite_Response_Tracked_On__c = SLATerms[i].SVMXC__Onsite_Response_Tracked_On__c;
                    SLA.SVMXC__Restoration_Tracked_On__c = SLATerms[i].SVMXC__Restoration_Tracked_On__c;
                    SLA.SVMXC__Resolution_Tracked_On__c = SLATerms[i].SVMXC__Resolution_Tracked_On__c;
                    //Added by Nidhi as part of BAC-4646
                    SLA.SVMXC__SM_Initial_Unit_of_Measure__c = SLATerms[i].SVMXC__SM_Initial_Unit_of_Measure__c;
                    SLA.SVMXC__SM_Onsite_Unit_of_Measure__c = SLATerms[i].SVMXC__SM_Onsite_Unit_of_Measure__c;
                    SLA.SVMXC__SM_Restoration_Unit_of_Measure__c = SLATerms[i].SVMXC__SM_Restoration_Unit_of_Measure__c;
                    SLA.SVMXC__SM_Resolution_Unit_of_Measure__c = SLATerms[i].SVMXC__SM_Resolution_Unit_of_Measure__c;
                    SLA.SVMXC__SM_Initial_SLA_Cutoff_Time__c = SLATerms[i].SVMXC__SM_Initial_SLA_Cutoff_Time__c;
                    SLA.SVMXC__SM_Onsite_SLA_Cutoff_Time__c = SLATerms[i].SVMXC__SM_Onsite_SLA_Cutoff_Time__c;
                    SLA.SVMXC__SM_Restoration_SLA_Cutoff_Time__c = SLATerms[i].SVMXC__SM_Restoration_SLA_Cutoff_Time__c;
                    SLA.SVMXC__SM_Resolution_SLA_Cutoff_Time__c = SLATerms[i].SVMXC__SM_Resolution_SLA_Cutoff_Time__c;
                    SID = SLATerms[i].id; 
                    
                    //Picklist options for Unit fields on each clock
                    UnitOptionsIR = new List<SelectOption>();
                    UnitOptionsOR = new List<SelectOption>();
                    UnitOptionsRES = new List<SelectOption>();
                    UnitOptionsRESTO = new List<SelectOption>();
                    Schema.sObjectType sobject_type = SVMXC__Service_Level__c.getSObjectType();
                    Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
                    Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
                    getUnitOptions(SLA,field_map,'SVMXC__SM_Initial_Unit_of_Measure__c',UnitOptionsIR);
                    getUnitOptions(SLA,field_map,'SVMXC__SM_Onsite_Unit_of_Measure__c',UnitOptionsOR);
                    getUnitOptions(SLA,field_map,'SVMXC__SM_Resolution_Unit_of_Measure__c',UnitOptionsRES);
                    getUnitOptions(SLA,field_map,'SVMXC__SM_Restoration_Unit_of_Measure__c',UnitOptionsRESTO);
                    
                    
                    //Render Daily CutOff picklists based on time field stored on SLA Terms                 
                    if(SLA.SVMXC__SM_Initial_SLA_Cutoff_Time__c != null){
                        Map<Integer,String> timeFieldSLA = new Map<Integer,String>();
                        timeFieldSLA = getTimeFieldFromSLA(String.valueOf(SLA.SVMXC__SM_Initial_SLA_Cutoff_Time__c));
                        slaCutoffIR = (new list<integer>(timeFieldSLA.keyset()))[0];
                        slaCutoffZoneIR = timeFieldSLA.get(slaCutoffIR);
                    }
                    if(SLA.SVMXC__SM_Onsite_SLA_Cutoff_Time__c != null){
                        Map<Integer,String> timeFieldSLA = new Map<Integer,String>();
                        timeFieldSLA = getTimeFieldFromSLA(String.valueOf(SLA.SVMXC__SM_Onsite_SLA_Cutoff_Time__c));
                        slaCutoffOR = (new list<integer>(timeFieldSLA.keyset()))[0];
                        slaCutoffZoneOR = timeFieldSLA.get(slaCutoffOR);
                    }
                    if(SLA.SVMXC__SM_Resolution_SLA_Cutoff_Time__c != null){
                        Map<Integer,String> timeFieldSLA = new Map<Integer,String>();
                        timeFieldSLA = getTimeFieldFromSLA(String.valueOf(SLA.SVMXC__SM_Resolution_SLA_Cutoff_Time__c));
                        slaCutoffRES = (new list<integer>(timeFieldSLA.keyset()))[0];
                        slaCutoffZoneRES = timeFieldSLA.get(slaCutoffRES);
                    }
                    if(SLA.SVMXC__SM_Restoration_SLA_Cutoff_Time__c != null){
                        Map<Integer,String> timeFieldSLA = new Map<Integer,String>();
                        timeFieldSLA = getTimeFieldFromSLA(String.valueOf(SLA.SVMXC__SM_Restoration_SLA_Cutoff_Time__c));
                        slaCutoffRESTO = (new list<integer>(timeFieldSLA.keyset()))[0];
                        slaCutoffZoneRESTO = timeFieldSLA.get(slaCutoffRESTO);                      
                    }
                    
                    if(SLA.SVMXC__SM_Initial_Unit_of_Measure__c == 'Day'){
                        isCutOffTimeVisibleIR = true;
                    }
                    if(SLA.SVMXC__SM_Onsite_Unit_of_Measure__c == 'Day'){
                        isCutOffTimeVisibleOR = true;
                    }
                    if(SLA.SVMXC__SM_Restoration_Unit_of_Measure__c == 'Day'){
                        isCutOffTimeVisibleREST = true;
                    }
                    if(SLA.SVMXC__SM_Resolution_Unit_of_Measure__c == 'Day'){
                        isCutOffTimeVisibleRESO = true;
                    }
                    
                    //Make Unit Of Measure and SLA Cutoff Time Readonly if SLA tracked on is CASE
                    if(SLA.Initial_Response_Tracked_On__c=='Case'){
                        isUnitIR_Disabled = true;
                    }
                    if(SLA.SVMXC__Onsite_Response_Tracked_On__c=='Case'){
                        isUnitOR_Disabled = true;
                    }
                    if(SLA.SVMXC__Restoration_Tracked_On__c=='Case'){
                        isUnitRES_Disabled = true;
                    }
                    if(SLA.SVMXC__Resolution_Tracked_On__c=='Case'){
                        isUnitRESTO_Disabled = true;
                    }
                    //Added by Nidhi as part of BAC-4646 Ends Here
                }   
            }
            // 3rd-Aug-2012: Commeneted LastActivityDate to handle defect 005180.
            SLADetailall = Database.Query('Select RecordType.Name, s.SVMXC__Service_Name__c, s.SVMXC__Type__c, SVMXC__Frequency__c,s.SVMXC__Service_Details__c, s.SVMXC__Select__c, s.SVMXC__SLA_Terms__c, s.SVMXC__Priority__c, s.SVMXC__Number_of_units__c, s.SVMXC__Internal_Goal__c, s.SVMXC__Included_Or_Not__c,  s.SVMXC__Customer_Commitment__c, s.SVMXC__Commitment_Type__c, s.SVMXC__Clock_Starts_From__c, s.SVMXC__Business_Hours__c, s.SVMXC__Business_Hours_Source__c, s.SVMXC__Available_Services__r.SVMXC__Data_Type__c, s.SVMXC__Available_Services__r.SVMXC__Select__c, s.SVMXC__Available_Services__r.SVMXC__Service_Type__c, s.SVMXC__Available_Services__r.SVMXC__Effective_Date__c, s.SVMXC__Available_Services__r.SVMXC__Active__c, s.SVMXC__Available_Services__r.Name, s.SVMXC__Available_Services__r.Id, s.SVMXC__Available_Services__c, s.RecordTypeId, s.Name, s.Id From SVMXC__SLA_Detail__c s where  SVMXC__SLA_Terms__c = \''+ SID +'\'');
            //system.debug('SLADetailall'+SLADetailall);
            for(Integer j = 0; j<SLADetailall.size(); j++)
            {
               //system.debug('SLADetailall1');
                if(SLADetailall[j].RecordType.Name == 'Commitment')
                {
                  
                    if(SLADetailall[j].SVMXC__Commitment_Type__c == 'InitialResponse')
                    {
                        InitialResponse.add(SLADetailall[j]);
                    }
                    if(SLADetailall[j].SVMXC__Commitment_Type__c == 'OnsiteResponse')
                    {
                        OnsiteResponse.add(SLADetailall[j]);
                    }
                    if(SLADetailall[j].SVMXC__Commitment_Type__c == 'Restoration')
                    {
                        Restoration.add(SLADetailall[j]);
                    }
                    if(SLADetailall[j].SVMXC__Commitment_Type__c == 'Resolution')
                    {
                        Resolution.add(SLADetailall[j]);
                    }   
                }
                if(SLADetailall[j].RecordType.Name == 'Services')
                {
                    Services.add(SLADetailall[j]);
                }
            }
            selectedTab = getTAG012();
            //system.debug('Serviceszzz'+Services.size());
            //system.debug('Services'+Services);
            //system.debug('InitialResponse'+InitialResponse);
            //system.debug('OnsiteResponse'+OnsiteResponse);
            //system.debug('Restoration'+Restoration);
            //system.debug('Resolution'+Resolution);
            //system.debug('asdf1'+ServiceWrapper.size());
            for(integer k = 0; k<Services.size(); k++)
            {
              //system.debug('Serviceszzz'+Services[k].SVMXC__Available_Services__r.SVMXC__Data_Type__c);
              
                ServiceWrapper.add(new SLAWrapper(Services[k],getTAG045()));
                
            }
            SVMX_IR_ChangeCaseWo();
            SVMX_OR_ChangeCaseWo();
            SVMX_Restoration_ChangeCaseWo();
      SVMX_Resolution_ChangeCaseWo();
            //system.debug('asdf'+ServiceWrapper.size()+ServiceWrapper);
            DisbleNewBttn = True;
            DisbleEditBttn = True;
            DisbleDeleteBttn = true;
            DisbleCancleBttn = False;
            DisbleSaveBttn = False;
            DisbaleChkBox = True;
            DetailSection = True;
        }   
        //system.debug('SVMX_ValidEditSALTerm()3'+SVMX_ValidEditSALTerm());
        return null;
    }
    
    //Added by Nidhi as part of BAC-4646 to get the cutOff time fields on SLA term
    public Map<Integer,String> getTimeFieldFromSLA(String cutOffTime){
        Integer hour = Integer.valueOf(cutOffTime.split(':')[0]);
        Map<Integer,String> result = new Map<Integer,String>();
         if(hour>12){
            result.put((hour - 12),'PM');
         }else if(hour==00 || hour==0){//12AM
            result.put(12,'AM');
         }else if(hour==12){//12PM
            result.put(12,'PM');
         }else{
            result.put(hour,'AM');
         }
         return result;
    }
    
    /********************************************************Validation for Edit SLA******************************************************/
    public Boolean SVMX_ValidEditSALTerm = False;
    public Boolean SVMX_ValidEditSALTerm()
    {
        SVMX_ValidEditSALTerm = False;
        List<Integer> SelectedLines = new List<Integer>();
        for(Integer i = 0; i < SLATerms.size(); i++)
        {
            if(SLATerms[i].SVMXC__Select__c == true)
            {
                SelectedLines.add(i);
            }
        }
        if(SelectedLines.size() < 1)
        {
            SVMX_ValidEditSALTerm = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG034()));
        }
        
        else if(SelectedLines.size() > 1)
        {
            for(Integer j = 0; j < SLATerms.size(); j++)
            {
                SLATerms[j].SVMXC__Select__c = False;
            }
            SVMX_ValidEditSALTerm = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG035()));
        }   
        
        return SVMX_ValidEditSALTerm;
    }
    /********************************************************Save SLA******************************************************/
    public PageReference SVMX_SaveSLA()
    {
        pageReference p;
        SaveSLATermData.clear();
        SaveSLADetailsData.clear();
        string aid; 
        if(SVMX_ValidSaveSLA() == true)
        {
            for(SVMXC__Service_Level__c s : SLATerms)
            {
                if(s.SVMXC__Select__c == true && s.id != null)
                {
                    s.SVMXC__Initial_Response_Tracked_On__c = SLA.SVMXC__Initial_Response_Tracked_On__c;
                    s.SVMXC__Onsite_Response_Tracked_On__c = SLA.SVMXC__Onsite_Response_Tracked_On__c;
                    s.SVMXC__Restoration_Tracked_On__c = SLA.SVMXC__Restoration_Tracked_On__c;
                    s.SVMXC__Resolution_Tracked_On__c = SLA.SVMXC__Resolution_Tracked_On__c;                    
                    
                    //Added by Nidhi as part of BAC-4646
                    s.SVMXC__SM_Initial_Unit_of_Measure__c = SLA.SVMXC__SM_Initial_Unit_of_Measure__c;
                    s.SVMXC__SM_Onsite_Unit_of_Measure__c = SLA.SVMXC__SM_Onsite_Unit_of_Measure__c;
                    s.SVMXC__SM_Resolution_Unit_of_Measure__c = SLA.SVMXC__SM_Resolution_Unit_of_Measure__c;
                    s.SVMXC__SM_Restoration_Unit_of_Measure__c = SLA.SVMXC__SM_Restoration_Unit_of_Measure__c;                  
                    s.SVMXC__SM_Initial_SLA_Cutoff_Time__c = SLA.SVMXC__SM_Initial_SLA_Cutoff_Time__c;
                    s.SVMXC__SM_Onsite_SLA_Cutoff_Time__c = SLA.SVMXC__SM_Onsite_SLA_Cutoff_Time__c;
                    s.SVMXC__SM_Resolution_SLA_Cutoff_Time__c = SLA.SVMXC__SM_Resolution_SLA_Cutoff_Time__c;
                    s.SVMXC__SM_Restoration_SLA_Cutoff_Time__c = SLA.SVMXC__SM_Restoration_SLA_Cutoff_Time__c;//Added by Nidhi as part //Added by Nidhi as part of BAC-4646 Ends Here                                      
                    s.SVMXC__Select__c = false;
                    
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( s, COMM_SecurityUtils.Access.Updateable ) ) {
                        //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                        update s;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                    aid = s.id;
                    //SaveSLATermData = s;
                }
                if(s.SVMXC__Select__c == true && s.id == null)
                {
                    s.SVMXC__Initial_Response_Tracked_On__c = SLA.SVMXC__Initial_Response_Tracked_On__c;
                    s.SVMXC__Onsite_Response_Tracked_On__c = SLA.SVMXC__Onsite_Response_Tracked_On__c;
                    s.SVMXC__Restoration_Tracked_On__c = SLA.SVMXC__Restoration_Tracked_On__c;
                    s.SVMXC__Resolution_Tracked_On__c = SLA.SVMXC__Resolution_Tracked_On__c;
                    s.SVMXC__Select__c = false;
                    
                    //Added by Nidhi as part of BAC-4646
                    s.SVMXC__SM_Initial_Unit_of_Measure__c = SLA.SVMXC__SM_Initial_Unit_of_Measure__c;
                    s.SVMXC__SM_Onsite_Unit_of_Measure__c = SLA.SVMXC__SM_Onsite_Unit_of_Measure__c;
                    s.SVMXC__SM_Resolution_Unit_of_Measure__c = SLA.SVMXC__SM_Resolution_Unit_of_Measure__c;
                    s.SVMXC__SM_Restoration_Unit_of_Measure__c = SLA.SVMXC__SM_Restoration_Unit_of_Measure__c;                  
                    s.SVMXC__SM_Initial_SLA_Cutoff_Time__c = SLA.SVMXC__SM_Initial_SLA_Cutoff_Time__c;
                    s.SVMXC__SM_Onsite_SLA_Cutoff_Time__c = SLA.SVMXC__SM_Onsite_SLA_Cutoff_Time__c;
                    s.SVMXC__SM_Resolution_SLA_Cutoff_Time__c = SLA.SVMXC__SM_Resolution_SLA_Cutoff_Time__c;
                    s.SVMXC__SM_Restoration_SLA_Cutoff_Time__c = SLA.SVMXC__SM_Restoration_SLA_Cutoff_Time__c;//Added by Nidhi as part //Added by Nidhi as part of BAC-4646 Ends Here                                      
                    
                    SaveSLATermData = s;
                    //insert s;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( s, COMM_SecurityUtils.Access.Createable ) ) {
                        //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                        insert s;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                    aid = s.id;
                }
            }
            //upsert SLATerms;
            //system.debug('SaveSLATermData'+SaveSLATermData);
            //system.debug('SaveSLATermData'+SaveSLATermData.id);
            for(SVMXC__SLA_Detail__c ir:InitialResponse)
            {
                if(ir.RecordTypeId == null)
                {
                    ir.RecordTypeId = CommitmentRtypeId;
                }
                ir.SVMXC__SLA_Terms__c = aid;//SaveSLATermData.id;
                ir.SVMXC__Commitment_Type__c = 'InitialResponse';
                SaveSLADetailsData.add(ir);
            }
            for(SVMXC__SLA_Detail__c ir:OnsiteResponse)
            {
                if(ir.RecordTypeId == null)
                {
                    ir.RecordTypeId = CommitmentRtypeId;    
                }
                ir.SVMXC__SLA_Terms__c = aid;//SaveSLATermData.id;
                ir.SVMXC__Commitment_Type__c = 'OnsiteResponse';
                SaveSLADetailsData.add(ir);
            }
            for(SVMXC__SLA_Detail__c ir:Restoration)
            {
                if(ir.RecordTypeId == null)
                {
                    ir.RecordTypeId = CommitmentRtypeId;
                }
                ir.SVMXC__SLA_Terms__c = aid;//SaveSLATermData.id;
                ir.SVMXC__Commitment_Type__c = 'Restoration';
                SaveSLADetailsData.add(ir);
            }
            for(SVMXC__SLA_Detail__c ir:Resolution)
            {
                if(ir.RecordTypeId == null)
                {
                    ir.RecordTypeId = CommitmentRtypeId;
                }
                ir.SVMXC__SLA_Terms__c = aid;//SaveSLATermData.id;
                ir.SVMXC__Commitment_Type__c = 'Resolution';
                SaveSLADetailsData.add(ir);
            }
            //system.debug('amar'+ServiceWrapper.size());
            //system.debug('amar'+ServiceWrapper);
            for(Integer i = 0; i<ServiceWrapper.size(); i++)
            {
                if(ServiceWrapper[i].SLADetail.RecordTypeId == null)
                {
                    ServiceWrapper[i].SLADetail.RecordTypeId = ServiceRtypeId;
                }
                ServiceWrapper[i].SLADetail.SVMXC__SLA_Terms__c = aid;//SaveSLATermData.id;
                SaveSLADetailsData.add(ServiceWrapper[i].SLADetail);
            }
            //system.debug('SaveSLADetailsData'+SaveSLADetailsData);
            //upsert SaveSLADetailsData;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SaveSLADetailsData, COMM_SecurityUtils.Access.Upsertable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                upsert SaveSLADetailsData;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
            DisbaleChkBox = False;
            DisbleNewBttn = False;
            DisbleEditBttn = False;
            DisbleDeleteBttn = false;
            DetailSection = False;
            DisbleCancleBttn = True;
            DisbleSaveBttn = True;
            InitialResponse.clear(); 
            OnsiteResponse.clear();  
            Restoration.clear(); 
            Resolution .clear(); 
            Services.clear();
            ServiceWrapper.clear();
            string url = '/apex/SVMXC__SLAT_ManageSLATerms';
            p=new pageReference(url);
      p.setRedirect(true);  
        }
        else{
            HdrMsg = true;
            p=null;
        }
        return p;
    }
    /********************************************************Validation for Save SLA******************************************************/
    public Boolean SVMX_ValidSaveSLA()
    {
        //Added by Nidhi as part of BAC-4646, validation while saving SLA CutOff Time
        if((slaCutoffIR!=null && String.isBlank(slaCutoffZoneIR)) || (slaCutoffOR!=null && String.isBlank(slaCutoffZoneOR)) || (slaCutoffRES!=null && String.isBlank(slaCutoffZoneRES)) || (slaCutoffRESTO!=null && String.isBlank(slaCutoffZoneRESTO)) ||      
        (slaCutoffIR==null && !String.isBlank(slaCutoffZoneIR)) || (slaCutoffOR==null && !String.isBlank(slaCutoffZoneOR)) || (slaCutoffRES==null && !String.isBlank(slaCutoffZoneRES)) || (slaCutoffRESTO==null && !String.isBlank(slaCutoffZoneRESTO))
        ){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, 'Complete The SLA Daily Cutoff Time Field' ) );
            return null;
        }
        
        Boolean SVMX_ValidSLA = true;
        for(Integer j = 0; j < SLATerms.size(); j++)
        {
            if(SLATerms[j].SVMXC__Select__c == true && (SLATerms[j].Name == null || SLATerms[j].Name == ''))
            {
                SVMX_ValidSLA = false;
                SLATerms[j].Name.AddError(getTAG055());
            }
        }
        String dup;
        String dup1;
        for(Integer i = 0; i < SLATerms.size(); i++)
        {
            for(Integer j = i+1; j < SLATerms.size(); j++)
            {
                if(SLATerms[i].Name != null &&  SLATerms[j].Name != null)
                {
                    dup = SLATerms[i].Name.trim();
                    dup1 = SLATerms[j].Name.trim();
                    if(dup.toUpperCase() == dup1.toUpperCase())
                    {
                        SVMX_ValidSLA = false;
                        SLATerms[i].Name.addError(getTAG056());
                    }
                }
            }
        }   
        //Validation for Initial Response.......................
        for(Integer i = InitialResponse.size()-1;i>=0; i--)
        {
            if(InitialResponse[i].SVMXC__Type__c == null && InitialResponse[i].SVMXC__Priority__c == null && InitialResponse[i].SVMXC__Customer_Commitment__c == null && InitialResponse[i].SVMXC__Business_Hours_Source__c == null && InitialResponse[i].SVMXC__Internal_Goal__c == null)
            {
                InitialResponse.remove(i);
            }
        }
        for(SVMXC__SLA_Detail__c ir : InitialResponse)   
        {   
            if(ir.SVMXC__Type__c == null)
            {
                SVMX_ValidSLA = false;
                ir.SVMXC__Type__c.AddError(getTAG057());
            }
            if(ir.SVMXC__Priority__c == null)
            {
                SVMX_ValidSLA = false;
                ir.SVMXC__Priority__c.AddError(getTAG058());
            }
            if(ir.SVMXC__Customer_Commitment__c == null)
            {
                SVMX_ValidSLA = false;
                ir.SVMXC__Customer_Commitment__c.AddError(getTAG059());
            }
            if(ir.SVMXC__Business_Hours_Source__c == null)
            {
                SVMX_ValidSLA = false;
                ir.SVMXC__Business_Hours_Source__c.AddError(getTAG060());
            }
            if(ir.SVMXC__Business_Hours_Source__c == 'Custom' && ir.SVMXC__Business_Hours__c == null)
            {
                SVMX_ValidSLA = false;
                ir.SVMXC__Business_Hours__c.AddError(getTAG060());
            }
        }
        for(Integer j = 0; j < InitialResponse.size(); j++)
        {
            for(Integer k = j+1; k < InitialResponse.size(); k++)
            {
                if(InitialResponse[j].SVMXC__Type__c == InitialResponse[k].SVMXC__Type__c && InitialResponse[j].SVMXC__Priority__c == InitialResponse[k].SVMXC__Priority__c)
                {
                    SVMX_ValidSLA = false;
                    InitialResponse[j].SVMXC__Type__c.AddError(getTAG061());
                    InitialResponse[k].SVMXC__Type__c.AddError(getTAG061());
                }
            }
        }
        //Validation for Onsite Responce..............
        for(Integer l = OnsiteResponse.size()-1;l>=0; l--)
        {
            if(OnsiteResponse[l].SVMXC__Type__c == null && OnsiteResponse[l].SVMXC__Priority__c == null && OnsiteResponse[l].SVMXC__Customer_Commitment__c == null && OnsiteResponse[l].SVMXC__Business_Hours_Source__c == null && OnsiteResponse[l].SVMXC__Internal_Goal__c == null)
            {
                OnsiteResponse.remove(l);
            }
        }
        for(SVMXC__SLA_Detail__c Ore : OnsiteResponse)   
        {   
            if(Ore.SVMXC__Type__c == null)
            {
                SVMX_ValidSLA = false;
                Ore.SVMXC__Type__c.AddError(getTAG062());
            }
            if(Ore.SVMXC__Priority__c == null)
            {
                SVMX_ValidSLA = false;
                Ore.SVMXC__Priority__c.AddError(getTAG063());
            }
            if(Ore.SVMXC__Customer_Commitment__c == null)
            {
                SVMX_ValidSLA = false;
                Ore.SVMXC__Customer_Commitment__c.AddError(getTAG064());
            }
            if(Ore.SVMXC__Business_Hours_Source__c == null)
            {
                SVMX_ValidSLA = false;
                Ore.SVMXC__Business_Hours_Source__c.AddError(getTAG065());
            }
            if(Ore.SVMXC__Business_Hours_Source__c == 'Custom' && Ore.SVMXC__Business_Hours__c == null)
            {
                SVMX_ValidSLA = false;
                Ore.SVMXC__Business_Hours__c.AddError(getTAG065());
            }
        }
        for(Integer m = 0; m < OnsiteResponse.size(); m++)
        {
            for(Integer n = m+1; n < OnsiteResponse.size(); n++)
            {
                if(OnsiteResponse[m].SVMXC__Type__c == OnsiteResponse[n].SVMXC__Type__c && OnsiteResponse[m].SVMXC__Priority__c == OnsiteResponse[n].SVMXC__Priority__c)
                {
                    SVMX_ValidSLA = false;
                    OnsiteResponse[m].SVMXC__Type__c.AddError(getTAG066());
                    OnsiteResponse[n].SVMXC__Type__c.AddError(getTAG066());
                }
            }
        }
        //Validation for Restration....
        for(Integer o = Restoration.size()-1;o>=0; o--)
        {
            if(Restoration[o].SVMXC__Type__c == null && Restoration[o].SVMXC__Priority__c == null && Restoration[o].SVMXC__Customer_Commitment__c == null && Restoration[o].SVMXC__Business_Hours_Source__c == null && Restoration[o].SVMXC__Internal_Goal__c == null)
            {
                Restoration.remove(o);
            }
        }
        for(SVMXC__SLA_Detail__c Resto : Restoration)    
        {   
            if(Resto.SVMXC__Type__c == null)
            {
                SVMX_ValidSLA = false;
                Resto.SVMXC__Type__c.AddError(getTAG067());
            }
            if(Resto.SVMXC__Priority__c == null)
            {
                SVMX_ValidSLA = false;
                Resto.SVMXC__Priority__c.AddError(getTAG068());
            }
            if(Resto.SVMXC__Customer_Commitment__c == null)
            {
                SVMX_ValidSLA = false;
                Resto.SVMXC__Customer_Commitment__c.AddError(getTAG069());
            }
            if(Resto.SVMXC__Business_Hours_Source__c == null)
            {
                SVMX_ValidSLA = false;
                Resto.SVMXC__Business_Hours_Source__c.AddError(getTAG070());
            }
            if(Resto.SVMXC__Business_Hours_Source__c == 'Custom' && Resto.SVMXC__Business_Hours__c == null)
            {
                SVMX_ValidSLA = false;
                Resto.SVMXC__Business_Hours__c.AddError(getTAG070());
            }
        }
        for(Integer p = 0; p < Restoration.size(); p++)
        {
            for(Integer q = p+1; q < Restoration.size(); q++)
            {
                if(Restoration[p].SVMXC__Type__c == Restoration[q].SVMXC__Type__c && Restoration[p].SVMXC__Priority__c == Restoration[q].SVMXC__Priority__c)
                {
                    SVMX_ValidSLA = false;
                    Restoration[p].SVMXC__Type__c.AddError(getTAG071());
                    Restoration[q].SVMXC__Type__c.AddError(getTAG071());
                }
            }
        }
        //Validation for Resolution............
        for(Integer r = Resolution.size()-1;r>=0; r--)
        {
            if(Resolution[r].SVMXC__Type__c == null && Resolution[r].SVMXC__Priority__c == null && Resolution[r].SVMXC__Customer_Commitment__c == null && Resolution[r].SVMXC__Business_Hours_Source__c == null && Resolution[r].SVMXC__Internal_Goal__c == null)
            {
                Resolution.remove(r);
            }
        }
        for(SVMXC__SLA_Detail__c Resolu : Resolution)    
        {   
            if(Resolu.SVMXC__Type__c == null)
            {
                SVMX_ValidSLA = false;
                Resolu.SVMXC__Type__c.AddError(getTAG072());
            }
            if(Resolu.SVMXC__Priority__c == null)
            {
                SVMX_ValidSLA = false;
                Resolu.SVMXC__Priority__c.AddError(getTAG073());
            }
            if(Resolu.SVMXC__Customer_Commitment__c == null)
            {
                SVMX_ValidSLA = false;
                Resolu.SVMXC__Customer_Commitment__c.AddError(getTAG074());
            }
            if(Resolu.SVMXC__Business_Hours_Source__c == null)
            {
                SVMX_ValidSLA = false;
                Resolu.SVMXC__Business_Hours_Source__c.AddError(getTAG075());
            }
            if(Resolu.SVMXC__Business_Hours_Source__c == 'Custom' && Resolu.SVMXC__Business_Hours__c == null)
            {
                SVMX_ValidSLA = false;
                Resolu.SVMXC__Business_Hours__c.AddError(getTAG075());
            }
        }
        for(Integer s = 0; s < Resolution.size(); s++)
        {
            for(Integer t = s+1; t < Resolution.size(); t++)
            {
                if(Resolution[s].SVMXC__Type__c == Resolution[t].SVMXC__Type__c && Resolution[s].SVMXC__Priority__c == Resolution[t].SVMXC__Priority__c)
                {
                    SVMX_ValidSLA = false;
                    Resolution[s].SVMXC__Type__c.AddError(getTAG076());
                    Resolution[t].SVMXC__Type__c.AddError(getTAG076());
                }
            }
        }
        //Validation for Services Tab.....
         for(Integer a = ServiceWrapper.size()-1; a >= 0; a--)
         {
            if(ServiceWrapper[a].SLADetail.SVMXC__Available_Services__c == null)
            {
                ServiceWrapper.remove(a);
            }
        }
        return SVMX_ValidSLA;   
        
    }
     /********************************************************Cancel SLA******************************************************/
    public PageReference SVMX_Cancel()
    {
        /*List<Integer> RemoveLines = new List<Integer>();
        for(Integer i = 0; i < SLATerms.size(); i++)
        {
            if(SLATerms[i].SVMXC__Select__c == true && SLATerms[i].id == null)
            {
                //RemoveLines.add(i);
                SLATerms.remove(i);
            }
        }
        for(Integer j = 0; j < SLATerms.size(); j++)
        {
            if(SLATerms[j].SVMXC__Select__c == true && SLATerms[j].id != null)
            {
                SLATerms[j].SVMXC__Select__c = False;
            }
        }
        
        DisbaleChkBox = False;
        DisbleNewBttn = False;
        DisbleEditBttn = False;
        DisbleDeleteBttn = false;
        DetailSection = False;
        DisbleCancleBttn = True;
        InitialResponse.clear(); 
        OnsiteResponse.clear();  
        Restoration.clear(); 
        Resolution .clear(); 
        Services.clear();
        ServiceWrapper.clear();
        return null;*/
        pageReference newpage = new pageReference('/apex/SLAT_ManageSLATerms');
        newpage.setRedirect(True);
        return newpage;
    }
    public List<integer> SelectedLines = new List<integer>();
    public PageReference SVMX_DeleteSLA()
    {
        SelectedLines.clear();
        DelSLATermData.clear();
        DelSLADetailsData.clear();
        if(SLATerms.size()!= null)
        {
            for(Integer i = 0; i < SLATerms.size(); i++)
            {
                if(SLATerms[i].SVMXC__Select__c == true && SLATerms[i].id != null)
                {
                    SelectedLines.add(i);
                    if(SelectedLines.size() > 0)
                    {
                        if(SLATermId.length() > 0)
                            SLATermId += ',';
                        SLATermId  += '\'' + String.valueOf(SLATerms[i].id)+'\'';
                    }   
                }       
            }          
        }
        //system.debug('SelectedLines'+SelectedLines.size());
        //system.debug('SLATermId'+SLATermId);
        if(SLATermId != null && SLATermId.length() > 0)
        {
            DelSLATermData = Database.Query('Select id,name From SVMXC__Service_Level__c where id in (' + SLATermId + ')');      
            //system.debug('DelSLATermData'+DelSLATermData);
            DelSLADetailsData = Database.Query('Select id,name,SVMXC__Service_Name__c from SVMXC__SLA_Detail__c where SVMXC__SLA_Terms__c in (' + SLATermId + ')');
            //system.debug('DelSLADetailsData'+DelSLADetailsData);
        }   
        if(SelectedLines.size() == 0)
        {
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG034()));
            
        }
        else
        {
            if(DelSLATermData.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Level__c' ) ) {
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete DelSLATermData;
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
                
                HdrMsg = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG054()));  
                for(Integer j = SelectedLines.size()-1; j>=0; j--)
                {
                    SLATerms.remove(SelectedLines.get(j));
                }
            }
            if(DelSLADetailsData.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SLA_Detail__c' ) ) {
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete DelSLADetailsData;
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }            
        }      
        return null;
    }
   
    /*public Boolean getIsWarn()
    {
        boolean IsWarn = false;
        SelectedLines.clear();
        DelSLATermData.clear();
        DelSLADetailsData.clear();
        if(SLATerms.size()!= null)
        {
            for(Integer i = 0; i < SLATerms.size(); i++)
            {
                if(SLATerms[i].SVMXC__Select__c == true && SLATerms[i].id != null)
                {
                    SelectedLines.add(i);
                    if(SelectedLines.size() > 0)
                    {
                        if(SLATermId.length() > 0)
                            SLATermId += ',';
                        SLATermId  += '\'' + String.valueOf(SLATerms[i].id)+'\'';
                    }   
                }       
            }          
        }
        //system.debug('SelectedLines'+SelectedLines.size());
        //system.debug('SLATermId'+SLATermId);
        if(SLATermId != null && SLATermId.length() > 0)
        {
            DelSLATermData = Database.Query('Select id,name From SVMXC__Service_Level__c where id in (' + SLATermId + ')');      
            //system.debug('DelSLATermData'+DelSLATermData);
            DelSLADetailsData = Database.Query('Select id,name,SVMXC__Service_Name__c from SVMXC__SLA_Detail__c where SVMXC__SLA_Terms__c in (' + SLATermId + ')');
            //system.debug('DelSLADetailsData'+DelSLADetailsData);
        }   
        if(DelSLADetailsData.size() > 0)
            str = getTAG077();
        else
            str = getTAG078();
        //system.debug('str'+str);
        if(selectedLines.size()>0)
            IsWarn =  true;
        else
            IsWarn =  false;    
        //system.debug('IsWarn'+IsWarn);
        return IsWarn;    
    }*/
    /*public String str;
    public String getMSG()
    {
        return str;
    }*/
    public PageReference SVMX_BackToSetupHome()
    {
        //pageReference HomePage = page.SVMXC__CONF_SetupHome;
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        pageReference HomePage = new PageReference(url);
        return HomePage;
    }
    
    
    
    
    ////////////////////////////////////////////Getter & Setter Methods///////////////////////////////////////////////////
    public Boolean getHdrMsg(){return HdrMsg;}
    public Boolean getTab1Msg() {return Tab1Msg;}
    public Boolean getTab2Msg() {return Tab2Msg;}
    public Boolean getTab3Msg() {return Tab3Msg;}
    public Boolean getTab4Msg() {return Tab4Msg;}
    public Boolean getTab5Msg() {return Tab5Msg;}
    public Boolean getpanelMsg(){return panelMsg;}
    
    
    public boolean getdisplayPopUp() {return displayPopUp;}
    public String getSearchKeyword() { return SearchKeyword;} 
    public void setSearchKeyword(String s){SearchKeyword = s.trim();}
  
    public Boolean getDisbleNewBttn() {return DisbleNewBttn;}
    public Boolean getDisbleEditBttn() {return DisbleEditBttn;}
    public Boolean getDisbleCancleBttn() {return DisbleCancleBttn;} 
    public Boolean getDisbleSaveBttn() {return DisbleSaveBttn;} 
    public Boolean getDisbleDeleteBttn() {return DisbleDeleteBttn;}
  
    public Boolean getDisbaleChkBox(){ return DisbaleChkBox; }
    public void setDisbaleChkBox(Boolean b){ this.DisbaleChkBox = b; }
    
    public string getselectedTab() {return this.selectedTab;}
    public void setselectedTab(string str) {this.selectedTab = str;}
    
    public Boolean getDetailSection() {return DetailSection;}

    public Boolean getCheckAllLines(){return CheckAllLines;}
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
    
    public List<SVMXC__Service_Level__c> getSLATerms(){return SLATerms;}
    public void setSLATerms(List<SVMXC__Service_Level__c> s) {SLATerms = s;}
    
    public SVMXC__Service_Level__c getSLA() {return SLA;}
    public void setSLA(SVMXC__Service_Level__c s) {SLA = s;}
    
    

    



//************************************************Initial Response Tab's Methods....******************************************
    
    //Getter Setter Method...
    public List<SVMXC__SLA_Detail__c> getInitialResponse() { return InitialResponse;}
    public void setInitialResponse(List<SVMXC__SLA_Detail__c> ir) {InitialResponse = ir;}
    
    public List<SelectOption> getIrType() 
    {
      if(IrType.size() == 0)
      {
        IrType.add(new selectOption('',getTAG031()));
      }
      return IrType;
    }
    public List<SelectOption> getIrPriority()
    {
      if(IrPriority.size() == 0)
      {
        IrPriority.add(new selectOption('',getTAG031()));
      }
      return IrPriority;
    }
    public List<SelectOption> getIrClock() 
    {
      if(IrClock.size() == 0)
      {
        IrClock.add(new selectOption('',getTAG031()));
      }
      return sortingSelectOption(IrClock,true);
    }
    //Action Methods..
    public PageReference SVMX_IR_ChangeCaseWo()
    {
        Tab1Msg = false;
        IrType.clear();
        IrPriority.clear();
        IrClock.clear();
        IrType.add(new selectOption('',getTAG031()));
        IrClock.add(new selectOption('',getTAG031()));
        IrPriority.add(new selectOption('',getTAG031()));
        if(SLA.SVMXC__Initial_Response_Tracked_On__c == 'Case')
        {
            isUnitIR_Disabled = true;//Make Unit Of Measure and SLA Cutoff Time Readonly if SLA tracked on is CASE,added by nidhi as part of BAC-4646
            SLA.SVMXC__SM_Initial_Unit_of_Measure__c = 'Minute';
            isCutOffTimeVisibleIR = false;
            SLA.SVMXC__SM_Initial_SLA_Cutoff_Time__c = null;
          if(LicenseType == true)
          {
              for(String s : CaseTypeVal.keySet())
              {
                  IrType.add(new selectOption(s,CaseTypeVal.get(s)));
              }
              //  IrType.add(new selectOption(getTAG036(),getTAG036()));- Rajat: Made changes for BAC-3327
              IrType.add(new selectOption('All',getTAG036()));
              for(String s1 : CasePriorityVal.keySet())
              {
                  IrPriority.add(new selectOption(s1,CasePriorityVal.get(s1)));
              }
              for(String s2 : CaseDateTimeFld.keySet())
              {
                  IrClock.add(new selectOption(s2,CaseDateTimeFld.get(s2)));
              }
          }
          else
          {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG080()));
            Tab1Msg = true;
          }
        }     
        if(SLA.SVMXC__Initial_Response_Tracked_On__c == 'WorkOrder')
        {
            isUnitIR_Disabled = false;//Enable Unit Of Measure and SLA Cutoff Time if SLA tracked on is CASE,added by nidhi as part of BAC-4646
            for(String s : WOTypeVal.keySet())
            {
                IrType.add(new selectOption(s,WOTypeVal.get(s)));
            }
            //  IrType.add(new selectOption(getTAG036(),getTAG036()));- Rajat: Made changes for BAC-3327
            IrType.add(new selectOption('All',getTAG036()));
            for(String s1 : WOPriorityVal.keySet())
            {
                IrPriority.add(new selectOption(s1,WOPriorityVal.get(s1)));
            }
            for(String s2 : WODateTimeFld.keySet())
            {
                IrClock.add(new selectOption(s2,WODateTimeFld.get(s2)));
            }     
        }
        //system.debug('amar'+Tab1Msg);   
        return null;
    }
    public PageReference SVMX_IR_CustomBH()
    {
        return null;
    }
    //Action function added by NIDHI as part of BAC-4646    
    public void toggleCutOffTimeIR()
    {
        system.debug('test=='+SLA.SVMXC__SM_Initial_Unit_of_Measure__c);
        if(SLA.SVMXC__SM_Initial_Unit_of_Measure__c=='Day'){
            isCutOffTimeVisibleIR=true;
        }else{
            isCutOffTimeVisibleIR=false;
        }
    }
    public void toggleCutOffTimeOR()
    {
        if(SLA.SVMXC__SM_Onsite_Unit_of_Measure__c=='Day'){
            isCutOffTimeVisibleOR=true;
        }else{
            isCutOffTimeVisibleOR=false;
        }
    }
    public void toggleCutOffTimeREST()
    {
        if(SLA.SVMXC__SM_Restoration_Unit_of_Measure__c=='Day'){
            isCutOffTimeVisibleREST=true;
        }else{
            isCutOffTimeVisibleREST=false;
        }
    }
    public void toggleCutOffTimeRESO()
    {
        if(SLA.SVMXC__SM_Resolution_Unit_of_Measure__c=='Day'){
            isCutOffTimeVisibleRESO=true;
        }else{
            isCutOffTimeVisibleRESO=false;
        }
    }
    public void InitialCutoffTime()
    {
        Time cutOffTimeIR = null;
        if(slaCutoffIR!=null && slaCutoffZoneIR == 'PM'){
            if(slaCutoffIR==12)
                cutOffTimeIR = Time.newInstance(12, 0, 0, 0);
            else
                cutOffTimeIR = Time.newInstance(slaCutoffIR+12, 0, 0, 0);
        }else if(slaCutoffIR!=null){
            if(slaCutoffIR==12)
                cutOffTimeIR = Time.newInstance(0, 0, 0, 0);
            else
                cutOffTimeIR = Time.newInstance(slaCutoffIR, 0, 0, 0);
        }
        SLA.SVMXC__SM_Initial_SLA_Cutoff_Time__c = cutOffTimeIR;
    }
    public void OnsiteCutoffTime()
    {
        Time cutOffTimeOR = null;   
        if(slaCutoffOR!=null && slaCutoffZoneOR == 'PM'){
            if(slaCutoffOR==12)
                cutOffTimeOR = Time.newInstance(12, 0, 0, 0);
            else
                cutOffTimeOR = Time.newInstance(slaCutoffOR+12, 0, 0, 0);
        }else if(slaCutoffOR!=null){
            if(slaCutoffOR==12)
                cutOffTimeOR = Time.newInstance(0, 0, 0, 0);
            else
                cutOffTimeOR = Time.newInstance(slaCutoffOR, 0, 0, 0);
        }       
        SLA.SVMXC__SM_Onsite_SLA_Cutoff_Time__c = cutOffTimeOR;
    }
    public void ResolutionCutoffTime()
    {
        Time cutOffTimeRES = null;  
        if(slaCutoffRES!=null && slaCutoffZoneRES == 'PM'){
            if(slaCutoffRES==12)
                cutOffTimeRES = Time.newInstance(12, 0, 0, 0);
            else
                cutOffTimeRES = Time.newInstance(slaCutoffRES+12, 0, 0, 0);
        }else if(slaCutoffRES!=null){
            if(slaCutoffRES==12)
                cutOffTimeRES = Time.newInstance(0, 0, 0, 0);
            else
                cutOffTimeRES = Time.newInstance(slaCutoffRES, 0, 0, 0);
        }
        SLA.SVMXC__SM_Resolution_SLA_Cutoff_Time__c = cutOffTimeRES;
    }
    public void RestorationCutoffTime()
    {
        Time cutOffTimeRESTO = null;    
        if(slaCutoffRESTO!=null && slaCutoffZoneRESTO == 'PM'){
            if(slaCutoffRESTO==12)
                cutOffTimeRESTO = Time.newInstance(12, 0, 0, 0);
            else
                cutOffTimeRESTO = Time.newInstance(slaCutoffRESTO+12, 0, 0, 0);
        }else if(slaCutoffRESTO!=null){
            if(slaCutoffRESTO==12)
                cutOffTimeRESTO = Time.newInstance(0, 0, 0, 0);
            else
                cutOffTimeRESTO = Time.newInstance(slaCutoffRESTO, 0, 0, 0);
        }
        SLA.SVMXC__SM_Restoration_SLA_Cutoff_Time__c = cutOffTimeRESTO;
    }
    public PageReference SVMX_IR_AddRecord()
    {
        SVMXC__SLA_Detail__c  newLine = new  SVMXC__SLA_Detail__c();
        InitialResponse.add(newLine);
        return null;
    }
    public PageReference SVMX_IR_Delete()
    {
        List<Integer> SelectedLines = new List<Integer>();
        List<SVMXC__SLA_Detail__c> DelInitialResponse = new List<SVMXC__SLA_Detail__c>();
        Tab1Msg = false;
        DelInitialResponse.clear();
        //system.debug('amar'+InitialResponse.size()+InitialResponse);
        for(integer i = 0; i<InitialResponse.size();i++)
        {
            if(InitialResponse[i].SVMXC__Select__c == true && InitialResponse[i].id != null)
            {
                
                SelectedLines.add(i);
                DelInitialResponse.add(InitialResponse[i]);
            }
            if(InitialResponse[i].SVMXC__Select__c == true && InitialResponse[i].id == null)
            {
                SelectedLines.add(i);
            }
        }
        //system.debug('amar1'+SelectedLines.size());
        if(SelectedLines.size() <= 0 )
        {
            Tab1Msg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG034()));
        }
        for(Integer j = SelectedLines.size() -1; j>=0; j--)
        {
            InitialResponse.remove(SelectedLines.get(j));
            Tab1Msg = false;
        }
        if(DelInitialResponse.size() > 0)
        {       
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SLA_Detail__c' ) ) {
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete DelInitialResponse;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                return null;
            }
            
            Tab1Msg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG054()));
        }   
        return null;
    }
    
    
    //**************************************Onsite Responce Tab's Methods....**************************************************
    
    //Getter Setter Method...
    public List<SVMXC__SLA_Detail__c> getOnsiteResponse() {return OnsiteResponse;}
    public void setOnsiteResponse(List<SVMXC__SLA_Detail__c> onr) {OnsiteResponse = onr;}
    public List<SelectOption> getOrType() 
    {
        if(OrType.size() == 0)
        {
          OrType.add(new selectOption('',getTAG031()));
        }
        return OrType;
    }
    public List<SelectOption> getOrPriority() 
    {
        if(OrPriority.size() == 0)
        {
          OrPriority.add(new selectOption('',getTAG031()));
        }
        return OrPriority;
    }
    public List<SelectOption> getOrClock() 
    {
        if(OrClock.size() == 0)
        {
          OrClock.add(new selectOption('',getTAG031()));
        }
        return sortingSelectOption(OrClock,true);
    }
    
    //Action Methods..
    public PageReference SVMX_OR_ChangeCaseWo()
    {
        Tab2Msg = false;
        OrType.clear(); 
        OrPriority.clear();
        OrClock.clear();
        OrType.add(new selectOption('',getTAG031()));
        OrPriority.add(new selectOption('',getTAG031()));
        OrClock.add(new selectOption('',getTAG031()));
        if(SLA.SVMXC__Onsite_Response_Tracked_On__c == 'Case')
        {
            isUnitOR_Disabled = true;//Make Unit Of Measure and SLA Cutoff Time Readonly if SLA tracked on is CASE,added by nidhi as part of BAC-4646
            SLA.SVMXC__SM_Onsite_Unit_of_Measure__c = 'Minute';
            isCutOffTimeVisibleOR = false;
            SLA.SVMXC__SM_Onsite_SLA_Cutoff_Time__c = null;
            if(LicenseType == true)
          {
              for(String s : CaseTypeVal.keySet())
              {
                  OrType.add(new selectOption(s,CaseTypeVal.get(s)));
              }
              //  OrType.add(new selectOption(getTAG036(),getTAG036()));- Rajat: Made changes for BAC-3327
              OrType.add(new selectOption('All',getTAG036()));
              for(String s1 : CasePriorityVal.keySet())
              {
                  OrPriority.add(new selectOption(s1,CasePriorityVal.get(s1)));
              }
              for(String s2 : CaseDateTimeFld.keySet())
              {
                  OrClock.add(new selectOption(s2,CaseDateTimeFld.get(s2)));
              }
          }
          else
          {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG080()));
            Tab2Msg = true;
          }    
        }
        if(SLA.SVMXC__Onsite_Response_Tracked_On__c == 'WorkOrder')
        {
            isUnitOR_Disabled = false;//Enable Unit Of Measure and SLA Cutoff Time if SLA tracked on is CASE,added by nidhi as part of BAC-4646
            for(String s : WOTypeVal.keySet())
            {
                OrType.add(new selectOption(s,WOTypeVal.get(s)));
            }
            //  OrType.add(new selectOption(getTAG036(),getTAG036()));- Rajat: Made changes for BAC-3327
            OrType.add(new selectOption('All',getTAG036()));
            for(String s1 : WOPriorityVal.keySet())
            {
                OrPriority.add(new selectOption(s1,WOPriorityVal.get(s1)));
            }
            for(String s2 : WODateTimeFld.keySet())
            {
                OrClock.add(new selectOption(s2,WODateTimeFld.get(s2)));
            }  
        }
        return null;
    }
    public PageReference SVMX_OR_CustomBH()
    {
        return null;
    }
    public PageReference SVMX_OR_AddRecord()
    {
        SVMXC__SLA_Detail__c  newLine = new  SVMXC__SLA_Detail__c();
        OnsiteResponse.add(newLine);
        return null;
    }
    public PageReference SVMX_OR_Delete()
    {
        List<Integer> SelectedLines = new List<Integer>();
        List<SVMXC__SLA_Detail__c> DelOnsiteResponse = new List<SVMXC__SLA_Detail__c>();
        Tab2Msg = false;
        DelOnsiteResponse.clear();
        //system.debug('amar'+InitialResponse.size()+InitialResponse);
        for(integer i = 0; i<OnsiteResponse.size();i++)
        {
            if(OnsiteResponse[i].SVMXC__Select__c == true && OnsiteResponse[i].id != null)
            {
                
                SelectedLines.add(i);
                DelOnsiteResponse.add(OnsiteResponse[i]);
            }
            if(OnsiteResponse[i].SVMXC__Select__c == true && OnsiteResponse[i].id == null)
            {
                SelectedLines.add(i);
            }
        }
        //system.debug('amar1'+SelectedLines.size());
        if(SelectedLines.size() <= 0 )
        {
            Tab2Msg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG034()));
        }
        for(Integer j = SelectedLines.size() -1; j>=0; j--)
        {
            OnsiteResponse.remove(SelectedLines.get(j));
            Tab2Msg = false;
        }
        if(DelOnsiteResponse.size() > 0)
        {       
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SLA_Detail__c' ) ) {
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete DelOnsiteResponse;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                return null;
            }
            
            Tab2Msg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG054()));
        }   
        return null;
    }
    
    
    //*********************************************Restoration Tab's Methods....*********************************************
    
    //Getter Setter Method...
    public List<SVMXC__SLA_Detail__c> getRestoration() {return Restoration;}
    public void setRestoration(List<SVMXC__SLA_Detail__c> res) {Restoration = res;}
    
    public List<SelectOption> getRestorationType() 
    {
        if(RestorationType.size() == 0)
        {
          RestorationType.add(new selectOption('',getTAG031()));
        }   
        return RestorationType;
    }
    public List<SelectOption> getRestorationPriority() 
    {
      if(RestorationPriority.size() == 0)
        {
          RestorationPriority.add(new selectOption('',getTAG031()));
        } 
        return RestorationPriority;
    }
    public List<SelectOption> getRestorationClock() 
    {
        if(RestorationClock.size() == 0)
        {
          RestorationClock.add(new selectOption('',getTAG031()));
        }  
        return sortingSelectOption(RestorationClock,true);
    }
    
    //Action Methods..
    public PageReference SVMX_Restoration_ChangeCaseWo()
    {
      Tab3Msg = false;
      RestorationType.clear();
      RestorationPriority.clear();
      RestorationClock.clear();
         RestorationType.add(new selectOption('',getTAG031()));
        RestorationPriority.add(new selectOption('',getTAG031()));
        RestorationClock.add(new selectOption('',getTAG031()));
        if(SLA.SVMXC__Restoration_Tracked_On__c == 'Case')
        {
            isUnitRESTO_Disabled = true;//Make Unit Of Measure and SLA Cutoff Time Readonly if SLA tracked on is CASE,added by nidhi as part of BAC-4646
            SLA.SVMXC__SM_Restoration_Unit_of_Measure__c = 'Minute';
            isCutOffTimeVisibleREST = false;
            SLA.SVMXC__SM_Restoration_SLA_Cutoff_Time__c = null;
            if(LicenseType == true)
          {
              for(String s : CaseTypeVal.keySet())
              {
                  RestorationType.add(new selectOption(s,CaseTypeVal.get(s)));
              }
            //  RestorationType.add(new selectOption(getTAG036(),getTAG036()));- Rajat: Made changes for BAC-3327
              RestorationType.add(new selectOption('All',getTAG036()));
              for(String s : CasePriorityVal.keySet())
              {
                  RestorationPriority.add(new selectOption(s,CasePriorityVal.get(s)));
              }
              for(String s : CaseDateTimeFld.keySet())
              {
                  RestorationClock.add(new selectOption(s,CaseDateTimeFld.get(s)));
              }
          }
          else
          {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG080()));
            Tab3Msg = true;
          }    
        }
        if(SLA.SVMXC__Restoration_Tracked_On__c == 'WorkOrder')
        {
            isUnitRESTO_Disabled = false;//Enable Unit Of Measure and SLA Cutoff Time if SLA tracked on is CASE,added by nidhi as part of BAC-4646
            for(String s : WOTypeVal.keySet())
            {
                RestorationType.add(new selectOption(s,WOTypeVal.get(s)));
            }
            //  RestorationType.add(new selectOption(getTAG036(),getTAG036())); Rajat: Made changes for BAC-3327
            RestorationType.add(new selectOption('All',getTAG036()));
            for(String s : WOPriorityVal.keySet())
            {
                RestorationPriority.add(new selectOption(s,WOPriorityVal.get(s)));
            }
            for(String s : WODateTimeFld.keySet())
            {
                RestorationClock.add(new selectOption(s,WODateTimeFld.get(s)));
            } 
        }
       return null;
    }
    public PageReference SVMX_Restoration_CustomBH()
    {
        return null;
    }
    public PageReference SVMX_Restoration_AddRecord()
    {
        SVMXC__SLA_Detail__c  newLine = new  SVMXC__SLA_Detail__c();
        Restoration.add(newLine);
        return null;
    }
    public PageReference SVMX_Restoration_Delete()
    {
        List<Integer> SelectedLines = new List<Integer>();
        List<SVMXC__SLA_Detail__c> DelRestoration = new List<SVMXC__SLA_Detail__c>();
        Tab3Msg = false;
        DelRestoration.clear();
        //system.debug('amar'+Restoration.size()+Restoration);
        for(integer i = 0; i<Restoration.size();i++)
        {
            if(Restoration[i].SVMXC__Select__c == true && Restoration[i].id != null)
            {
                
                SelectedLines.add(i);
                DelRestoration.add(Restoration[i]);
            }
            if(Restoration[i].SVMXC__Select__c == true && Restoration[i].id == null)
            {
                SelectedLines.add(i);
            }
        }
        //system.debug('amar1'+SelectedLines.size());
        if(SelectedLines.size() <= 0 )
        {
            Tab3Msg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG034()));
        }
        for(Integer j = SelectedLines.size() -1; j>=0; j--)
        {
            Restoration.remove(SelectedLines.get(j));
            Tab3Msg = false;
        }
        if(DelRestoration.size() > 0)
        {      
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SLA_Detail__c' ) ) {
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete DelRestoration;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                return null;
            }
            
            Tab3Msg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG054()));
        }   
        return null;
    }
    
    //***********************************************************Resolution Tab's Methods....**************************************************
    
    //Getter Setter Method...
    public List<SVMXC__SLA_Detail__c> getResolution() {return Resolution;}
    public void setResolution(List<SVMXC__SLA_Detail__c> reso) {Resolution = reso;}
    
    public List<SelectOption> getResolutionType() 
    {
        if(ResolutionType.size() == 0)
        {
          ResolutionType.add(new selectOption('',getTAG031()));
        }  
        return ResolutionType;
    }
    public List<SelectOption> getResolutionPriority() 
    {
        if(ResolutionPriority.size() == 0)
        {
          ResolutionPriority.add(new selectOption('',getTAG031()));
        }  
         return ResolutionPriority;
    }
    public List<SelectOption> getResolutionClock() 
    {
       if(ResolutionClock.size() == 0)
        {
          ResolutionClock.add(new selectOption('',getTAG031()));
        }
       return sortingSelectOption(ResolutionClock,true);
    }
    
    //Action Methods..
    public PageReference SVMX_Resolution_ChangeCaseWo()
    {
        Tab4Msg = false;
        /* ResolutionClock.clear();
        ResolutionPriority.clear();
        ResolutionPriority.clear();
        ResolutionClock.add(new selectOption('',getTAG031()));
        ResolutionPriority.add(new selectOption('',getTAG031()));
        ResolutionPriority.add(new selectOption('',getTAG031())); */
        //Modified for the defect 011597 - --None-- was coming two times in priority picklist.
        ResolutionClock.clear();
        ResolutionType.clear();
        ResolutionPriority.clear();
        ResolutionClock.add(new selectOption('',getTAG031()));
        ResolutionType.add(new selectOption('',getTAG031()));
        ResolutionPriority.add(new selectOption('',getTAG031()));
      
        if(SLA.SVMXC__Resolution_Tracked_On__c == 'Case')
        {
            isUnitRES_Disabled = true;//Make Unit Of Measure and SLA Cutoff Time Readonly if SLA tracked on is CASE,added by nidhi as part of BAC-4646
            SLA.SVMXC__SM_Resolution_Unit_of_Measure__c = 'Minute';
            isCutOffTimeVisibleRESO = false;
            SLA.SVMXC__SM_Resolution_SLA_Cutoff_Time__c = null;
            if(LicenseType == true)
            {
              for(String s : CaseTypeVal.keySet())
              {
                  ResolutionType.add(new selectOption(s,CaseTypeVal.get(s)));
              }
              //  ResolutionType.add(new selectOption(getTAG036(),getTAG036()));- Rajat: Made changes for BAC-3327
              ResolutionType.add(new selectOption('All',getTAG036()));
              for(String s : CasePriorityVal.keySet())
              {
                  ResolutionPriority.add(new selectOption(s,CasePriorityVal.get(s)));
              }
              for(String s : CaseDateTimeFld.keySet())
              {
                  ResolutionClock.add(new selectOption(s,CaseDateTimeFld.get(s)));
              }
            }
            else
            {
              ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG080()));
            Tab4Msg = true;
            }    
        }
        if(SLA.SVMXC__Resolution_Tracked_On__c == 'WorkOrder')
        {
            isUnitRES_Disabled = false;//Enable Unit Of Measure and SLA Cutoff Time if SLA tracked on is CASE,added by nidhi as part of BAC-4646
            for(String s : WOTypeVal.keySet())
            {
                ResolutionType.add(new selectOption(s,WOTypeVal.get(s)));
            }
            //  ResolutionType.add(new selectOption(getTAG036(),getTAG036()));- Rajat: Made changes for BAC-3327
            ResolutionType.add(new selectOption('All',getTAG036()));
            for(String s : WOPriorityVal.keySet())
            {
                ResolutionPriority.add(new selectOption(s,WOPriorityVal.get(s)));
            }
            for(String s : WODateTimeFld.keySet())
            {
                ResolutionClock.add(new selectOption(s,WODateTimeFld.get(s)));
            }  
        }   
        return null;
    }
    public PageReference SVMX_Resolution_CustomBH()
    {
        return null;
    }
    public PageReference SVMX_Resolution_AddRecord()
    {
        SVMXC__SLA_Detail__c  newLine = new  SVMXC__SLA_Detail__c();
        Resolution.add(newLine);
        return null;
    }
    public PageReference SVMX_Resolution_Delete()
    {
        List<Integer> SelectedLines = new List<Integer>();
        List<SVMXC__SLA_Detail__c> DelResolution = new List<SVMXC__SLA_Detail__c>();
        Tab4Msg = false;
        DelResolution.clear();
        //system.debug('amar'+Restoration.size()+Restoration);
        for(integer i = 0; i<Resolution.size();i++)
        {
            if(Resolution[i].SVMXC__Select__c == true && Resolution[i].id != null)
            {
                
                SelectedLines.add(i);
                DelResolution.add(Resolution[i]);
            }
            if(Resolution[i].SVMXC__Select__c == true && Resolution[i].id == null)
            {
                SelectedLines.add(i);
            }
        }
        //system.debug('amar1'+SelectedLines.size());
        if(SelectedLines.size() <= 0 )
        {
            Tab4Msg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG034()));
        }
        for(Integer j = SelectedLines.size() -1; j>=0; j--)
        {
            Resolution.remove(SelectedLines.get(j));
            Tab4Msg = false;
        }
        if(DelResolution.size() > 0)
        {       
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SLA_Detail__c' ) ) {
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete DelResolution;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                return null;
            }
            
            Tab4Msg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG054()));
        }   
        return null;
    }
    /************************************************Service Tab's Methods...*************************************/
    
    public List<SLAWrapper> ServiceWrapper = new List<SLAWrapper>();
    public List<SLAWrapper> getServiceWrapper() {return ServiceWrapper;}
    public void setServiceWrapper(List<SLAWrapper> s)   {ServiceWrapper = s;}
    
    public List<SVMXC__Service__c> ApplicableService = new List<SVMXC__Service__c>();
    public List<SVMXC__Service__c> getApplicableService(){SearchKeyword = ''; return ApplicableService;}
    public void setApplicableService(List<SVMXC__Service__c> s ){s = ApplicableService;}
  
    public pageReference SVMX_AddService()
    {
        SVMXC__SLA_Detail__c newservice = new SVMXC__SLA_Detail__c();
        ServiceWrapper.add(new SLAWrapper(newservice,getTAG045()));
        return null;
    }
    public pageReference SVMX_DeleteService()
    {
        List<Integer> SelectedLines = new List<Integer>();
        List<SVMXC__SLA_Detail__c> DelService = new List<SVMXC__SLA_Detail__c>();
        Tab5Msg = false;
        DelService.clear();
        //system.debug('amar'+Restoration.size()+Restoration);
        for(integer i = 0; i<ServiceWrapper.size();i++)
        {
            if(ServiceWrapper[i].SLADetail.SVMXC__Select__c == true && ServiceWrapper[i].SLADetail.id != null)
            {
                
                SelectedLines.add(i);
                DelService.add(ServiceWrapper[i].SLADetail);
            }
            if(ServiceWrapper[i].SLADetail.SVMXC__Select__c == true && ServiceWrapper[i].SLADetail.id == null)
            {
                SelectedLines.add(i);
            }
        }
        //system.debug('amar1'+SelectedLines.size());
        if(SelectedLines.size() <= 0 )
        {
            Tab5Msg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG034()));
        }
        for(Integer j = SelectedLines.size() -1; j>=0; j--)
        {
            ServiceWrapper.remove(SelectedLines.get(j));
            Tab5Msg = false;
        }
        if(DelService.size() > 0)
        {       
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SLA_Detail__c' ) ) {
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete DelService;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                return null;
            }
            
            Tab5Msg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG054()));
        }   
        return null;
    }
    public pageReference SVMX_GO()
    {
        ApplicableService.clear();
        ServiceSearchLst.clear();
        SearchKeyword.trim();
        if(SearchKeyword == null || SearchKeyword.length() < 2)
        {
             panelMsg = true;
             ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG047()));    
        }
        else
        {
            ServiceSearchLst = database.query('Select id, Name,SVMXC__Select__c From SVMXC__Service__c s where Name LIKE \'%'+String.escapeSingleQuotes(SearchKeyword)+'%\'order by Name');
        }
        for(Integer i = 0; i<ServiceSearchLst.size(); i++)
        {
            boolean IsNotExist= true;
            for(Integer j = 0; j< ServiceWrapper.size(); j++)
            {
                if(ServiceWrapper[j].SLADetail.SVMXC__Available_Services__c == ServiceSearchLst[i].id )
                    IsNotExist = false;
            }
            if(IsNotExist)
                ApplicableService.add(ServiceSearchLst[i]);
        } 
        if(ApplicableService.size() == 0 && SearchKeyword.length() > 2)
        {
            panelMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG048()));  
        }
        //system.debug('ServiceSearchLst'+ServiceSearchLst);
        return null;
    }
    public pageReference SVMX_AddSelected()
    {
        List<integer> SelectedLines = new List<integer>();
        for(Integer i = 0; i<ApplicableService.size(); i++)
        {
            if(ApplicableService[i].SVMXC__Select__c == True)
            {
                ServiceWrapper.add(new SLAWrapper(new SVMXC__SLA_Detail__c(SVMXC__Available_Services__c = ApplicableService[i].id),getTAG045())); 
                SelectedLines.add(i);
            }
        }
        //system.debug('amar'+ServiceWrapper.size()+ServiceWrapper);
        if(SelectedLines.size() < 1)
        {
            panelMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG034()));  
        }
        for(Integer j = SelectedLines.size()-1; j >=0; j--)
        {
            ApplicableService.remove(SelectedLines.get(j));
        }
        //system.debug('ServiceWrapper'+ServiceWrapper);
        return null;
    }
    public String tabname;
    public pagereference SVMX_OpenPopup()
    {
      for(SLAWrapper oSW :ServiceWrapper)
      {
        if(oSW.SLADetail.SVMXC__Available_Services__c == ParameterID)
        {
          popupdetail.SVMXC__Service_Details__c = oSW.SLADetail.SVMXC__Service_Details__c;
          popupdetail.SVMXC__Included_Or_Not__c = oSW.SLADetail.SVMXC__Included_Or_Not__c;
          popupdetail.SVMXC__Number_Of_Units__c = oSW.SLADetail.SVMXC__Number_Of_Units__c;
          popupdetail.SVMXC__Frequency__c = oSW.SLADetail.SVMXC__Frequency__c;
          break;
        }
      }
        displayPopUp = true;
        return null;
    }
    public pagereference SVMX_ChangeOfService()
    {
        return null;
    }
    
    /************************************************************Prev & Next Button Methods**************/
    
    public pagereference SVMX_NextToOR()
    {
        selectedTab = getTAG013();
        return null;
    }
    public pagereference SVMX_BackToIR()
    {
        selectedTab = getTAG012();
        return null;
    }
    public pagereference SVMX_NextToRestoration()
    {
        selectedTab = getTAG014();
        return null;
    }
    public pagereference SVMX_BackToOR()
    {
        selectedTab = getTAG013();
        return null;
    }
    public pagereference SVMX_NextToResolution()
    {
        selectedTab = getTAG015();
        return null;
    }
    public pagereference SVMX_BackToRestoration()
    {
        selectedTab = getTAG014();
        return null;
    }
    public pagereference SVMX_NextToServices()
    {
        selectedTab = getTAG016();
        return null;
    }
    public pagereference SVMX_BackToResolution()
    {
        selectedTab = getTAG015();
        return null;
    }
    public pagereference Selectchkbox()
    {
        return null;
    }
    //Tags
    public string getHLPURL(){ return system.label.SLAT001_HLPURL;}
    public String getTAG001(){ return system.label.SLAT001_TAG001;}//New SLA Term 
    public String getTAG002(){ return system.label.SLAT001_TAG002;}//Save
    public String getTAG003(){ return system.label.SLAT001_TAG003;}//Delete
    public String getTAG004(){ return system.label.SLAT001_TAG004;}//Back To Setup Home
    public String getTAG005(){ return system.label.SLAT001_TAG005;}//Processing...
    public String getTAG006(){ return system.label.SLAT001_TAG006;}//SLA Terms Help
    public String getTAG007(){ return system.label.SLAT001_TAG007;}//SLA Terms Name
    public String getTAG008(){ return system.label.SLAT001_TAG008;}//Description
    public String getTAG009(){ return system.label.SLAT001_TAG009;}//Active
    public String getTAG010(){ return system.label.SLAT001_TAG010;}//Default Business Hours
    public String getTAG011(){ return system.label.SLAT001_TAG011;}//No Records To Display
    public String getTAG012(){ return system.label.SLAT001_TAG012;}//Initial Response
    public String getTAG013(){ return system.label.SLAT001_TAG013;}//Onsite Response
    public String getTAG014(){ return system.label.SLAT001_TAG014;}//Restoration
    public String getTAG015(){ return system.label.SLAT001_TAG015;}//Resolution
    public String getTAG016(){ return system.label.SLAT001_TAG016;}//Services
    public String getTAG017(){ return system.label.SLAT001_TAG017;}//Initial Response Tracked On
    public String getTAG018(){ return system.label.SLAT001_TAG018;}//Add Record
    public String getTAG019(){ return system.label.SLAT001_TAG019;}//Delete
    public String getTAG020(){ return system.label.SLAT001_TAG020;}//Type
    public String getTAG021(){ return system.label.SLAT001_TAG021;}//Priority
    public String getTAG022() {return system.label.SLAT001_TAG022;}//Clock Starts From
    public String getTAG023() {return system.label.SLAT001_TAG023;}//Internal Goal
    public String getTAG024() {return system.label.SLAT001_TAG024;}//Customer Commitment
    public String getTAG025() {return system.label.SLAT001_TAG025;}//Business Hours
    public String getTAG026() {return system.label.SLAT001_TAG026;}//<< Prev
    public String getTAG027() {return system.label.SLAT001_TAG027;}//Next >>
    public String getTAG028() {return system.label.SLAT001_TAG028;}//Onsite Response Tracked On
    public String getTAG029() {return system.label.SLAT001_TAG029;}//Restoration Tracked On
    public String getTAG030() {return system.label.SLAT001_TAG030;}//Resolution Tracked On
    public String getTAG031() {return system.label.SLAT001_TAG031;}//--None--
    public String getTAG032() {return system.label.SLAT001_TAG032;}//Edit
    public String getTAG033() {return system.label.SLAT001_TAG033;}//Cancel
    public String getTAG034() {return system.label.SLAT001_TAG034;}//Select Atleast one checkbox to perform action
    public String getTAG035() {return system.label.SLAT001_TAG035;}//Please select only one record to edit
    public String getTAG036() {return system.label.SLAT001_TAG036;}//All
    public String getTAG037() {return system.label.SLAT001_TAG037;}//Add Service
    public String getTAG038() {return system.label.SLAT001_TAG038;}//Select
    public String getTAG039() {return system.label.SLAT001_TAG039;}//Service Name
    public String getTAG040() {return system.label.SLAT001_TAG040;}//Click link to set
    public String getTAG041() {return system.label.SLAT001_TAG041;}//Commitment
    public String getTAG042() {return system.label.SLAT001_TAG042;}//Search services by entering a keyword
    public String getTAG043() {return system.label.SLAT001_TAG043;}//Go!
    public String getTAG044() {return system.label.SLAT001_TAG044;}//Add Selected
    public String getTAG045() {return system.label.SLAT001_TAG045;}//Per
    public String getTAG046() {return system.label.SLAT001_TAG046;}//Edit Commitment
    public String getTAG047() {return system.label.SLAT001_TAG047;}//Keyword must be at least 2 characters long
    public String getTAG048() {return system.label.SLAT001_TAG048;}//No Such Record is present in Applicable Service or record is already Exsist in the Service Tab
    public String getTAG049() {return system.label.SLAT001_TAG049;}//Submit
    public String getTAG050() {return system.label.SLAT001_TAG050;}//Yes
    public String getTAG051() {return system.label.SLAT001_TAG051;}//No
    public String getTAG052() {return system.label.SLAT001_TAG052;}//Please Enter Valid Data for Service Commitment
    public String getTAG053() {return system.label.SLAT001_TAG053;}//Record(s) Saved
    public String getTAG054() {return system.label.SLAT001_TAG054;}//Record(s) Deleted 
    public String getTAG055() {return system.label.SLAT001_TAG055;}//Please enter a valid SLA Terms name
    public String getTAG056() {return system.label.SLAT001_TAG056;}//Duplicate SLA Terms name
    public String getTAG057() {return system.label.SLAT001_TAG057;}//Initial Response:Type should not be blank
    public String getTAG058() {return system.label.SLAT001_TAG058;}//Initial Response:Priority should not be blank
    public String getTAG059() {return system.label.SLAT001_TAG059;}//Initial Response:Customer Commitment should not be blank
    public String getTAG060() {return system.label.SLAT001_TAG060;}//Initial Response:Business Hours should not be null
    public String getTAG061() {return system.label.SLAT001_TAG061;}//Initial Response:The combination of Type and Priority must be unique
    public String getTAG062() {return system.label.SLAT001_TAG062;}//Onsite Response:Type should not be blank
    public String getTAG063() {return system.label.SLAT001_TAG063;}//Onsite Response:Priority should not be blank
    public String getTAG064() {return system.label.SLAT001_TAG064;}//Onsite Response:Customer Commitment should not be blank
    public String getTAG065() {return system.label.SLAT001_TAG065;}//Onsite Response:Business Hours should not be null
    public String getTAG066() {return system.label.SLAT001_TAG066;}//Onsite Response:The combination of Type and Priority must be unique
    public String getTAG067() {return system.label.SLAT001_TAG067;}//Restoration:Type should not be blank
    public String getTAG068() {return system.label.SLAT001_TAG068;}//Restoration:Priority should not be blank
    public String getTAG069() {return system.label.SLAT001_TAG069;}//Restoration:Customer Commitment should not be blank
    public String getTAG070() {return system.label.SLAT001_TAG070;}//Restoration:Business Hours should not be null
    public String getTAG071() {return system.label.SLAT001_TAG071;}//Restoration:The combination of Type and Priority must be unique
    public String getTAG072() {return system.label.SLAT001_TAG072;}//Resolutoin:Type should not be blank
    public String getTAG073() {return system.label.SLAT001_TAG073;}//Resolutoin:Priority should not be blank
    public String getTAG074() {return system.label.SLAT001_TAG074;}//Resolutoin:Customer Commitment should not be blank
    public String getTAG075() {return system.label.SLAT001_TAG075;}//Resolutoin:Business Hours should not be null
    public String getTAG076() {return system.label.SLAT001_TAG076;}//Resolutoin:The combination of Type and Priority must be unique
    public String getTAG077() {return system.label.SLAT001_TAG077;}//All SLA commitment and services associated with the selected SLA Terms will be deleted permanently. This action cannot be rolled back. Are you sure to delete?
    public String getTAG078() {return system.label.SLAT001_TAG078;}//Are you sure to delete the selected records?
    public String getTAG079() {return system.label.SLAT001_TAG079;}//Are you sure?
    public String getTAG080() {return system.label.SLAT001_TAG080;}//The ServiceMax license type for your organization does not support this operation. Please contact your ServiceMax administrator for more information.
    
    
    
    
    
    
    
    
    
    
    
    
    
    /***********************************Pupup Method **********************************/
    
    public SVMXC__SLA_Detail__c getpopupdetail(){return popupdetail;}
    public void setpopupdetail(SVMXC__SLA_Detail__c s) {popupdetail = s;}
    
    public SVMXC__Service__c getpopupservice()
    {
        // 3rd-Aug-2012: Commeneted LastActivityDate to handle defect 005180.
        if(ParameterID != null)
            popupservice = Database.Query('Select s.SVMXC__Data_Type__c, s.Name From SVMXC__Service__c s where id = \''+ String.escapeSingleQuotes(ParameterID) +'\'');
        return popupservice;
    }
    
    public List<selectOption> getOptions()
    {
        List<selectOption> option = new List<selectOption>();
        option.add(new selectoption('true',getTAG050()));
        option.add(new selectoption('false',getTAG051()));
        return option;
    }
    
    public PageReference SVMX_Submit()
    {
        if(SVMX_IsValidPopup() == True)
        {
            PopupMsg = true;
        }
        else
        {
            for(Integer i = 0; i < ServiceWrapper.size(); i++)
            {
                if(ServiceWrapper[i].SLADetail.SVMXC__Available_Services__c == ParameterID)
                { 
                    if(popupdetail.SVMXC__Service_Details__c != null ||popupdetail.SVMXC__Included_Or_Not__c != null || popupdetail.SVMXC__Number_of_units__c != null || popupdetail.SVMXC__Frequency__c != null)
                    {
                        ServiceWrapper[i].updateCommitment(popupdetail,popupservice,getTAG045()); //= popupdetail.SVMXC__Service_Details__c; 
                    }
                }
            }   
        }
        popupdetail.SVMXC__Service_Details__c = null;
        popupdetail.SVMXC__Included_Or_Not__c = null;
        popupdetail.SVMXC__Number_of_units__c = null;
        popupdetail.SVMXC__Frequency__c = null;
        //system.debug('ServiceWrapper'+ServiceWrapper);
        displayPopUp = false;
        return null;
        
    }
    public Boolean SVMX_IsValidPopup = false;
    public Boolean SVMX_IsValidPopup()
    {
        if(popupservice.SVMXC__Data_Type__c == 'Text' && popupdetail.SVMXC__Service_Details__c == null)
        {
            SVMX_IsValidPopup = true;
            popupdetail.SVMXC__Service_Details__c.addError(getTAG052());
        }
        if(popupservice.SVMXC__Data_Type__c == 'Number' && popupdetail.SVMXC__Number_of_units__c == null)
        {
            SVMX_IsValidPopup = true;
            popupdetail.SVMXC__Number_of_units__c.addError(getTAG052());
        }
        if(popupservice.SVMXC__Data_Type__c == 'Frequency' && (popupdetail.SVMXC__Number_of_units__c == null || popupdetail.SVMXC__Frequency__c == null))
        {
            SVMX_IsValidPopup = true;
            popupdetail.SVMXC__Number_of_units__c.addError(getTAG052());
            popupdetail.SVMXC__Frequency__c.addError(getTAG052());
        }
        if(popupservice.SVMXC__Data_Type__c == 'Boolean' && popupdetail.SVMXC__Included_Or_Not__c == null)
        {
            SVMX_IsValidPopup = true;
            popupdetail.SVMXC__Included_Or_Not__c.addError(getTAG052());
        }
        return SVMX_IsValidPopup;
    }
    public PageReference SVMX_CancelPopup()
    {
        displayPopUp = false;
        return null;
        
    }
    public Boolean PopupMsg = false;
    public Boolean getPopupMsg() {return PopupMsg;}
    
    public string getParameterID(){return ParameterID;}
    public void setParameterID(string s) {ParameterID = s;}
   
    public List<SelectOption> sortingSelectOption(List<SelectOption> so, boolean bSortByLabel)
    {
        try
        {
            map<string, selectOption> mapTemp = new map<string, SelectOption>();
            if(bSortByLabel)
            {
                 for(selectOption o :so)
                 {  
                    mapTemp.put(o.getLabel()+'-'+o.getValue(), o);
                 }
            }
            else
            {
                 for(selectOption o :so)
                 {
                     mapTemp.put(o.getValue()+'-'+o.getLabel(), o);
                 }
            }
            list<string> lstTemp = new list<string>();
            lstTemp.addAll(mapTemp.KeySet());
            lstTemp.sort();
            so.clear();
            for(string str: lstTemp)
            {       
                so.add(mapTemp.get(str));
            }
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getmessage()));
        }
        return so;
    }
    
}