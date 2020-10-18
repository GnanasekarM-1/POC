public with sharing class CONF_ManageProfiles{
        //======================================== Simple Display Utility ===================================================// 

//SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();

SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('CONF006');

//public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('CONF006');


    public String getTAG001() {return System.Label.CONF006_TAG001;} //'Org-wide Configuration Settings';
    public String getTAG002() {return System.Label.CONF006_TAG002;} //'Localized Configuration Settings';
    public String getTAG003() {return System.Label.CONF006_TAG003;} //'Group-wide Configuration Settings'
    public String getTAG004() {return System.Label.CONF006_TAG004;} //Back To Setup Home';
    public String getTAG005() {return System.Label.CONF006_TAG005;} //Edit';
    public String getTAG006() {return System.Label.CONF006_TAG006;} //'Clone';
    public String getTAG007() {return System.Label.CONF006_TAG007;} //'Delete';
    public String getTAG008() {return System.Label.CONF006_TAG008;} //'Activate';
    public String getTAG009() {return System.Label.CONF006_TAG009;} //'Delete:';} 
    public String getTAG010() {return System.Label.CONF006_TAG010;} //'Record sucessfully deleted';} 
    public String getTAG011() {return System.Label.CONF006_TAG011;} //'No records to display';} 
    public String getTAG012() {return System.Label.CONF006_TAG012;} //'Invalid Data';}
    public String getTAG013() {return System.Label.CONF006_TAG013;} //'Please select a Module You must select a Module in order to delete';}
    public String getTAG014() {return System.Label.CONF006_TAG014;} //'Profile already activated';}
    public String getTAG015() {return System.Label.CONF006_TAG015;} //'Profile sucessfully activated';}
    public String getTAG016() {return System.Label.CONF006_TAG016;} //'Default profiles and Active cannot be deleted';}
    public String getTAG017() {return System.Label.CONF006_TAG017;} //'Last Modified By';}
    public String getTAG018() {return System.Label.CONF006_TAG018;} //'Status';}
    public String getTAG020() {return System.Label.CONF006_TAG020;} //'Select Only one record to edit';}
    public String getTAG021() {return System.Label.CONF006_TAG021;} //'Select Only one record to clone';}
    public String getTAG022() {return System.Label.CONF006_TAG022;} //'Select Only one record to activate';}
    public String getTAG023() {return System.Label.CONF006_TAG023;} //'ServiceMax Configuration Profile Help';}
    public String getTAG035() {return System.Label.CONF006_TAG035;} //'Invalid Data 
    public String getTAG055() {return System.Label.CONF006_TAG055;} //Access protected 
    public String getTAG056() {return System.Label.CONF006_TAG056;} //Default Profile cannot be edited  
    public String getTAG059() {return System.Label.CONF006_TAG059;} //Activation Status 
    public String getTAG069() {return System.Label.CONF006_TAG069;} //Active
    public String getTAG070() {return System.Label.CONF006_TAG070;} //Inactive
    
    //Neeraj(Feeb-7th-2012): Added new tags to resolve translation issue.
    public String getTAG052() {return System.Label.CONF006_TAG052;} //Profile Name
    public String getTAG073() {return System.Label.CONF006_TAG073;} //Last Modified Date
    
    public String getHLPURL() {return System.Label.CONF006_HLPURL;}
    
    public Boolean IsActivatedContract=true; // Flag to be used for Message
    public Boolean getIsActivatedContract(){ return IsActivatedContract;     } 



      Boolean CheckAllLines=false;    
      public Boolean getCheckAllLines() {return CheckAllLines;  }
      public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
      List<SVMXC__ServiceMax_Config_Data__c> GloSVMXprofiles;
      List<SVMXC__ServiceMax_Config_Data__c> LocSVMXprofiles;
      List<SVMXC__ServiceMax_Config_Data__c> DelMaxAccessBuf;
      
        Boolean checkboxfield=false;
        public String sId;
            
    //======================================== Constructure call ===================================================//      
    public CONF_ManageProfiles(){
       GloSVMXprofiles = [Select Id, SVMXC__Profile_Name__c, SVMXC__Active__c, LastModifiedBy.Username, LastModifiedDate, SVMXC__Select__c, SVMXC__IsDefault__c, SVMXC__Configuration_Type__c  From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Configuration Profile' and SVMXC__Configuration_Type__c = 'Global' order by SVMXC__Profile_Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
       LocSVMXprofiles = [Select Id, SVMXC__Profile_Name__c, SVMXC__Active__c, LastModifiedBy.Username, LastModifiedDate, SVMXC__Select__c, SVMXC__IsDefault__c, SVMXC__Configuration_Type__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Configuration Profile' and SVMXC__Configuration_Type__c = 'Group' order by SVMXC__Profile_Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }

        public List<SVMXC__ServiceMax_Config_Data__c> getServiceLocalSettingDetails(){
        return LocSVMXprofiles;
        }
        
        public List<SVMXC__ServiceMax_Config_Data__c> getServiceGlobalSettingDetails(){
        return GloSVMXprofiles;
        }
             
        public Boolean getCheckboxField(){
            return checkboxfield;
        }
        
        public void setCheckboxField(Boolean ckfld){
            this.checkboxfield=ckfld;
        }
        
        public PageReference SourceScrn(){
          PageReference scrn = new PageReference('/' + sId);
          scrn.setRedirect(true);
          return scrn;
        }


    //======================================== Function to check whether the data is valid for selected options ===================================================//
    public Boolean isGloValid(String OpType){
        boolean error=false;
        List<Integer> selectedLines = new List<Integer>();
        Integer i;  
            for (i=0;i<GloSVMXprofiles.size();i++){
            if (GloSVMXprofiles.get(i).SVMXC__Select__c==true){
                            selectedLines.add(i);
                            sId=GloSVMXprofiles.get(i).Id;
            }
        }
        if(selectedLines.size()!=1 && (OpType=='Edit' || OpType=='Clone' || OpType=='Activate') || (OpType=='Delete' && selectedLines.size()<1)){
            error=true;
        }
        return error;
    }
    public Boolean isLocValid(String OpType){
        boolean error=false;
        List<Integer> selectedLines = new List<Integer>();
        Integer i;  
            for (i=0;i<LocSVMXprofiles.size();i++){
            if (LocSVMXprofiles.get(i).SVMXC__Select__c==true){
                            selectedLines.add(i);
                            sId=LocSVMXprofiles.get(i).Id;
            }
        }
        if(selectedLines.size()!=1 && (OpType=='Edit' || OpType=='Clone' || OpType=='Activate') || (OpType=='Delete' && selectedLines.size()<1)){
            error=true;
        }
        return error;
    }
    //======================================== Action for redirecting on edit event ===================================================//
    public PageReference GloeditProf() {
        
        boolean error=false;
        Glo_DisplayBlockLevelMessage = false; 
        error=isGloValid('Edit');
        List<Integer> selectedLines = new List<Integer>();
        Integer i;

        if (error==true){
        Glo_DisplayBlockLevelMessage = true; 
        Grp_DisplayBlockLevelMessage = false; 
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG035(),getTAG020()));  
        return null;    
        }
        return GoEditPage();
    }
    public PageReference LoceditProf() {
        
        boolean error=false;
        Grp_DisplayBlockLevelMessage = false; 
        error=isLocValid('Edit');
        List<Integer> selectedLines = new List<Integer>();
        Integer i; 
        
        if (error==true){
        Grp_DisplayBlockLevelMessage = true; 
        Glo_DisplayBlockLevelMessage = false; 
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG035(),getTAG020()));  
        return null;    
        }
        return GoEditPage();
    }
    
    public PageReference GoEditPage() {
      String url = '/';
      if(svmxSettingList.containsKey('SET003') == true) url =svmxSettingList.get('SET003');
      PageReference ManageProfEd = new PageReference(url);
      //ManageProfEd.getparameters().put('sid',sId);//changed due to sid used by sfdc 29/12/2010 -HH
      ManageProfEd.getparameters().put('svmx_sid',sId);
      ManageProfEd.setRedirect(true);
      return ManageProfEd;      
    }
    //======================================== Action for redirecting on clone event ===================================================//
    public PageReference GlocloneProf() {
        
        boolean error=false;
        Glo_DisplayBlockLevelMessage = false; 
        error=isGloValid('Clone');
        
        if (error==true){
        Glo_DisplayBlockLevelMessage = true; 
        Grp_DisplayBlockLevelMessage = false;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG035(),getTAG021()));    
        CheckAllLines=false;
        return null;    
        }
        return GoClone();
    }
    public PageReference LoccloneProf() {
        
        boolean error=false;
        Grp_DisplayBlockLevelMessage = false; 
        error=isLocValid('Clone');
        
        if (error==true){
        Grp_DisplayBlockLevelMessage = true; 
        Glo_DisplayBlockLevelMessage = false; 
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG035(),getTAG021()));    
        CheckAllLines=false;
        return null;    
        }
        return GoClone();
    }
    
    public PageReference GoClone() {
      String url = '/';
      if(svmxSettingList.containsKey('SET003') == true) url =svmxSettingList.get('SET003');
      PageReference ManageProfCl = new PageReference(url);
      //ManageProfCl.getparameters().put('sid',sId);//changed due to sid used by sfdc 29/12/2010 -HH
      ManageProfCl.getparameters().put('svmx_sid',sId);
      ManageProfCl.getparameters().put('cl','s');
      ManageProfCl.setRedirect(true);
      return ManageProfCl;  
    }
    //======================================== Action for delete event ===================================================//
    public PageReference GlodelProf() {
        Glo_DisplayBlockLevelMessage = true;
        Grp_DisplayBlockLevelMessage = false;
        
            List<SVMXC__ServiceMax_Config_Data__c> recId = new List<SVMXC__ServiceMax_Config_Data__c>();  
            List<SVMXC__ServiceMax_Config_Data__c> BufrecId = new List<SVMXC__ServiceMax_Config_Data__c>();  

            List<Integer> selectedLines = new List<Integer>();
            Integer i; 
            Integer DelCount; 
            for (i=0;i<GloSVMXprofiles.size();i++){
                if (GloSVMXprofiles.get(i).Select__c==true){
                                selectedLines.add(i);
                }
            }
        if(selectedLines.size()==0){
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG012(),getTAG013()));            
        return null;
        }

            for (i=0;i<GloSVMXprofiles.size();i++){
            if (GloSVMXprofiles.get(i).SVMXC__Select__c==true && GloSVMXprofiles.get(i).SVMXC__IsDefault__c != true && GloSVMXprofiles.get(i).SVMXC__Active__c != true){
                            recId.add(GloSVMXprofiles.get(i));
            }
            else
            BufrecId.add(GloSVMXprofiles.get(i));
        }
    GloSVMXprofiles.clear();
    GloSVMXprofiles=BufrecId;
    CheckAllLines=false;
     //deletes only if records exist
     DelCount=recId.size();
    if(recId.size()>0){
        try{
            Boolean isObjectDeleteable = COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c');
            for(Integer j = 0; j < recId.size();j++){
                DelMaxAccessBuf=[Select Id,SVMXC__Profile__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Access' and SVMXC__Access_Configuration_Profile__c = :recId[j].Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                //delete DelMaxAccessBuf;
                if(isObjectDeleteable)
                    delete DelMaxAccessBuf; //SDL-SVMX-DELETE-FLS-ENFORCED
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    return null;
                }
                DelMaxAccessBuf.clear();
                DelMaxAccessBuf = [SELECT SVMXC__Display_Value__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Setting Value' and SVMXC__Setting_Configuration_Profile__c=:recId[j].Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                //delete DelMaxAccessBuf;
                if(isObjectDeleteable)
                    delete DelMaxAccessBuf; //SDL-SVMX-DELETE-FLS-ENFORCED
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    return null;
                }
                
                //BAC-4624 insert view servicemax configuration
                String profileType = recId[j].SVMXC__Configuration_Type__c;
                String actionData = 'Deleted Profile ' + recId[j].SVMXC__Profile_Name__c;
                String entityName = profileType == 'Global' ? 'Org-wide Configuration' : 'Group-wide Configuration';
                COMM_Utils_V2 commUtils = new COMM_Utils_V2();
                commUtils.processServicemaxConfiguration(entityName,'Browser','Deleted',actionData);
            }
            //delete recId;
            if(isObjectDeleteable)
                delete recId; //SDL-SVMX-DELETE-FLS-ENFORCED
            else{
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                return null;
            }           
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG009(),getTAG010())); }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
    }
        if(selectedLines.size()!=DelCount)
        {
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG012(),getTAG016()));  
        recId.clear();
        return null;    
        }
    return null;
    }
    public PageReference LocdelProf() {
        Glo_DisplayBlockLevelMessage = false;
        Grp_DisplayBlockLevelMessage = true;

            List<SVMXC__ServiceMax_Config_Data__c> recId = new List<SVMXC__ServiceMax_Config_Data__c>();  
            List<SVMXC__ServiceMax_Config_Data__c> BufrecId = new List<SVMXC__ServiceMax_Config_Data__c>();  

            List<Integer> selectedLines = new List<Integer>();
            Integer i; 
            Integer DelCount; 
            for (i=0;i<LocSVMXprofiles.size();i++){
                if (LocSVMXprofiles.get(i).Select__c==true){
                                selectedLines.add(i);
                }
            }
        if(selectedLines.size()==0){
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG012(),getTAG013()));            
        return null;
        }

            for (i=0;i<LocSVMXprofiles.size();i++){
            if (LocSVMXprofiles.get(i).SVMXC__Select__c==true && LocSVMXprofiles.get(i).SVMXC__IsDefault__c != true && LocSVMXprofiles.get(i).SVMXC__Active__c != true){
                            recId.add(LocSVMXprofiles.get(i));
            }
            else
            BufrecId.add(LocSVMXprofiles.get(i));
        }
        LocSVMXprofiles.clear();
        LocSVMXprofiles=BufrecId;
        CheckAllLines=false;
        //deletes only if records exist
        DelCount=recId.size();
        List<SVMXC__SM_Device_Mobile_Config__c> lstDeviceMobileConfig = new List<SVMXC__SM_Device_Mobile_Config__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigtoDel = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(recId.size()>0){
            try{
                Boolean isObjectDeleteable = COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c');
                Boolean isDeviceMobileConfigDeleteable = COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Device_Mobile_Config__c');
                for(Integer j = 0; j < recId.size();j++){                   
                    
                    List<SVMXC__SM_Device_Mobile_Config__c> lstDevMobConf = new List<SVMXC__SM_Device_Mobile_Config__c>();
                    lstDevMobConf = [Select SVMXC__SM_Name__c,SVMXC__SM_Description__c,SVMXC__SM_Device_Type__c, SVMXC__SM_IsDefault__c  From SVMXC__SM_Device_Mobile_Config__c where SVMXC__SM_Access_Configuration_Profile__c =:recId[j].Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                        
                    if(!lstDevMobConf.isEmpty()&&lstDevMobConf.size()>0)
                        lstDeviceMobileConfig.addAll(lstDevMobConf);
                    
                    DelMaxAccessBuf=[Select Id,SVMXC__Profile__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Access' and SVMXC__Access_Configuration_Profile__c = :recId[j].Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    //delete DelMaxAccessBuf;
                    
                    /* if(isObjectDeleteable)
                        delete DelMaxAccessBuf;
                    else{
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    }    */
                    
                    
                    if(!DelMaxAccessBuf.isEmpty()&&DelMaxAccessBuf.size()>0)
                        lstConfigtoDel.addAll(DelMaxAccessBuf);
                    
                    

                    
                    DelMaxAccessBuf.clear();
                    DelMaxAccessBuf = [SELECT SVMXC__Display_Value__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Setting Value' and SVMXC__Setting_Configuration_Profile__c=:recId[j].Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    //delete DelMaxAccessBuf;
                    /* if(isObjectDeleteable)
                        delete DelMaxAccessBuf;
                    else{
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    } */
                    
                    if(!DelMaxAccessBuf.isEmpty()&&DelMaxAccessBuf.size()>0)
                        lstConfigtoDel.addAll(DelMaxAccessBuf);
                    

                    
                    DelMaxAccessBuf.clear();
                    DelMaxAccessBuf = [SELECT Id from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Mobile Configuration' and SVMXC__Access_Configuration_Profile__c=:recId[j].Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    //delete DelMaxAccessBuf;
                    /* if(isObjectDeleteable)
                        delete DelMaxAccessBuf;
                    else{
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    } */
                    
                    if(!DelMaxAccessBuf.isEmpty()&&DelMaxAccessBuf.size()>0)
                        lstConfigtoDel.addAll(DelMaxAccessBuf);
                    
                    //BAC-4624 insert view servicemax configuration
                    String profileType = recId[j].SVMXC__Configuration_Type__c;
                    String actionData = 'Deleted Profile ' + recId[j].SVMXC__Profile_Name__c;
                    String entityName = profileType == 'Global' ? 'Org-wide Configuration' : 'Group-wide Configuration';
                    COMM_Utils_V2 commUtils = new COMM_Utils_V2();
                    commUtils.processServicemaxConfiguration(entityName,'Browser','Deleted',actionData);
                }
                if(!lstDeviceMobileConfig.isEmpty()&&lstDeviceMobileConfig.size()>0)
                {
                    if(isDeviceMobileConfigDeleteable && isObjectDeleteable)
                    {
                        
                        delete lstDeviceMobileConfig; //SDL-SVMX-DELETE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    }   
                }
                
                
                if(!lstConfigtoDel.isEmpty()&&lstConfigtoDel.size()>0)
                {

                    if(  isObjectDeleteable)
                    {
                        
                        delete lstConfigtoDel; //SDL-SVMX-DELETE-FLS-ENFORCED
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    }   
                }
                //delete recId;
                if(isObjectDeleteable)
                    delete recId; //SDL-SVMX-DELETE-FLS-ENFORCED
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    return null;
                }
                
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG009(),getTAG010())); 
            }
            catch (Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
            }
        }
        if(selectedLines.size()!=DelCount)
        {
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG012(),getTAG016()));  
        recId.clear();
        return null;    
        }
    return null;
    }
    //======================================== Action for activate event ===================================================//
    public PageReference GloactProf() {
        Glo_DisplayBlockLevelMessage = true;
        Grp_DisplayBlockLevelMessage = false;
        boolean error=false;
        error=isGloValid('Activate');
        Integer i;  
        
        if (error==true){
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG035(),getTAG022())); 
        CheckAllLines=false;
        return null;    
        }
        //add this new variable for resolving defect : 7329
        boolean isActive = false;
        for (i=0;i<GloSVMXprofiles.size();i++){
                if (GloSVMXprofiles.get(i).SVMXC__Select__c==true)
                {
                    isActive = GloSVMXprofiles.get(i).SVMXC__Active__c ? GloSVMXprofiles.get(i).SVMXC__Active__c : isActive;
                    GloSVMXprofiles.get(i).SVMXC__Active__c=true;
                    GloSVMXprofiles.get(i).SVMXC__Select__c=false;
                    
                    //BAC-4624 insert view servicemax configuration
                    String actionData = 'Activated ' + GloSVMXprofiles.get(i).SVMXC__Profile_Name__c;
                    String entityName = GloSVMXprofiles.get(i).SVMXC__Configuration_Type__c == 'Global' ? 'Org-wide Configuration' : 'Group-wide Configuration';
                    COMM_Utils_V2 commUtils = new COMM_Utils_V2();
                    commUtils.processServicemaxConfiguration(entityName,'Browser','Modified',actionData);
                }
                else {
                    if(GloSVMXprofiles.get(i).SVMXC__Active__c == true){
                         //BAC-4624 insert view servicemax configuration
                        String actionData = 'Inactivated ' + GloSVMXprofiles.get(i).SVMXC__Profile_Name__c;
                        String entityName = GloSVMXprofiles.get(i).SVMXC__Configuration_Type__c == 'Global' ? 'Org-wide Configuration' : 'Group-wide Configuration';
                        COMM_Utils_V2 commUtils = new COMM_Utils_V2();
                        commUtils.processServicemaxConfiguration(entityName,'Browser','Modified',actionData);
                    }
                    GloSVMXprofiles.get(i).SVMXC__Active__c=false;
                }
        }
        CheckAllLines=false;
        try{
            //upsert GloSVMXprofiles;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(GloSVMXprofiles, COMM_SecurityUtils.Access.Upsertable)){
                upsert GloSVMXprofiles; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                String message = isActive ? getTAG014() : getTAG015();
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG059(), message)); 
            }
            else{
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
            }
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
        return null;
    }
    //======================================== Set true to display blocklevel messge ===================================================//
    public Boolean Glo_DisplayBlockLevelMessage = false;
    public Boolean getGloDisplayBlockLevelMessage(){ return Glo_DisplayBlockLevelMessage; }     
    public Boolean Grp_DisplayBlockLevelMessage = false;
    public Boolean getGrpDisplayBlockLevelMessage(){ return Grp_DisplayBlockLevelMessage; }     
             
    //======================================== Action "Back To Setup Home" ===================================================//
    public PageReference GoSetupHome(){
      String url = '/';
      //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
      //if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
      if(svmxSettingList.containsKey('SET002') == true){
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url =svmxSettingList.get('SET002');
        }
      }
      //Changes done by Nidhi ends here
      PageReference HomePage = new PageReference(url);
      HomePage.setRedirect(true);
      return HomePage; 
    }
    
    public String getPlatformCacheLabel() {
        
        System.debug(LoggingLevel.DEBUG, 'getPlatformCacheLabel() - enter');
        
        Boolean isPlatformCacheEnabled = false;
        
        try {
            
            final SVMXC__ServiceMax_Properties__c pc001Record = [Select SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name ='PC001' LIMIT 1 ];
            if( pc001Record != null ) {
               isPlatformCacheEnabled = Boolean.valueOf( pc001Record.SVMXC__Value__c );
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'Failed to retrieve platform cache configuration' );
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getPlatformCacheLabel() - exit; isPlatformCacheEnabled = ' + isPlatformCacheEnabled );
        }
        //return isPlatformCacheEnabled ? 'Disable Platform Cache' : 'Enable Platform Cache';
        return isPlatformCacheEnabled ? System.Label.CONF043_TAG015 : System.Label.CONF043_TAG014;
    }
    
    public PageReference TogglePlatformCache() {
        
       System.debug(LoggingLevel.DEBUG, 'TogglePlatformCache() - enter');
        
        try {
            
            final SVMXC__ServiceMax_Properties__c pc001Record = [Select SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name ='PC001' LIMIT 1 ];
            if( pc001Record != null ) {
                
                Boolean isPlatformCacheEnabled = Boolean.valueOf( pc001Record.SVMXC__Value__c );
                pc001Record.SVMXC__Value__c = String.valueOf(!isPlatformCacheEnabled);
                
                update pc001Record;                
            }
        }
        catch(Exception e ){
            System.debug( LoggingLevel.ERROR, 'Failed to enable/disable platform cache configuration' );
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'TogglePlatformCache() - exit');
        }
        
        return null;
    }
}