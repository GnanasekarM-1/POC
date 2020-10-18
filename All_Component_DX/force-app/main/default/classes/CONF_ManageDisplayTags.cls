public  with sharing class CONF_ManageDisplayTags 
{
   
  



//-------------------------------------Declaration of url Variables----------------------------------------------------------
String Sid= System.currentPageReference().getParameters().get('sid');
String Submod;
Boolean isLaunch=true;    
//-------------------------------------Declaration Of Globle Variables..-------------------------------------
SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 

SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('CONF002');

//SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
//public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('CONF002');

public String Firsrlabel =System.Label.CONF002_TAG019; // Printing the first --NA--
Boolean CheckAllLines=false; 
public List<SVMXC__ServiceMax_Tags__c> standardtag = new List<SVMXC__ServiceMax_Tags__c>();
public List<SVMXC__ServiceMax_Tags__c> customtag = new List<SVMXC__ServiceMax_Tags__c>();
public List<SVMXC__ServiceMax_Tags__c> ctag = new List<SVMXC__ServiceMax_Tags__c>();
public List<SVMXC__ServiceMax_Processes__c> module = new List<SVMXC__ServiceMax_Processes__c>();
public List<SVMXC__ServiceMax_Processes__c> submodule = new List<SVMXC__ServiceMax_Processes__c>();
Public String moduleView {get; set;}
public String s;
//Public String submoduleView {get{if(Sid!=null && isLaunch==true){return Sid;}else {return submoduleView;}} set;}
Public String submoduleView {get; set;}
Boolean isAdd=false; 
public Integer custSize=0;
public Integer stdSize=0;
//-------------------------------------------Constructure call--------------------------------------------------
public CONF_ManageDisplayTags()
{
    DisplayTags = false;
    Suboptions .add(new SelectOption(Firsrlabel,Firsrlabel));    
    module     = [Select  SVMXC__Name__c,SVMXC__ModuleID__c,SVMXC__IsStandard__c,SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c = 'Module'order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
   
          
}
//-----------------------------------------Declaration Of Gatter Setter Methods.. ----------------------------------------------   
    
    public Boolean getCheckAllLines() {return CheckAllLines;}
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;} 
    public String getTAG001() {return System.Label.CONF002_TAG001;}//Manage Display Tags
    public String getTAG002() {return System.Label.CONF002_TAG002;} //Back To Home Setup
    public String getTAG003() {return System.Label.CONF002_TAG003;} // Select Module
    public String getTAG004() {return System.Label.CONF002_TAG004;} //Select Submodule
    public String getTAG005() {return System.Label.CONF002_TAG005;}// Standard Tags 
    public String getTAG006() {return System.Label.CONF002_TAG006;} // Custom Tags
    public String getTAG007() {return System.Label.CONF002_TAG007;} //Add Tag
    public String getTAG008() {return System.Label.CONF002_TAG008;} //Save
    public String getTAG009() {return System.Label.CONF002_TAG009;} //Delete
    public String getTAG010() {return System.Label.CONF002_TAG010;}// Record(s) saved
    public String getTAG011() {return System.Label.CONF002_TAG011;} //Please select one or more records from the list first.  
    public String getTAG012() {return System.Label.CONF002_TAG012;}//Record(s) deleted
    public String getTAG013() {return System.Label.CONF002_TAG013;} //Please enter a valid Tag ID that is unique and at least 8 characters long
    public String getTAG014() {return System.Label.CONF002_TAG014;} //You must have to enter the Tag Text
    public String getTAG015() {return System.Label.CONF002_TAG015;} //Invalid Data
    public String getTAG016() {return System.Label.CONF002_TAG016;} //Review all error messages below and click save
    public String getTAG017() {return System.Label.CONF002_TAG017;} //No records to display
    public String getTAG018() {return System.Label.CONF002_TAG018;} //Duplicate tag ID. Please note Tag IDs must be unique.
    public String getTAG020() {return System.Label.CONF002_TAG020;}  //Manage Display Tags Help
    public String getTAG021() {return System.Label.CONF002_TAG021;}  //Requesting...
    public String getTAG022() {return System.Label.CONF002_TAG022;}  //Are You Sure?
    public String getTAG023() {return System.Label.CONF002_TAG023;}  //No records selectes to delete
    //public String getTAG024(){ return System.Label.CONF002_TAG024;} //Invalid Data
    public String getHLPURL() {return System.Label.CONF002_HLPURL;}
//-----------------------------------Methods for Selecting & Returning Modules-------------------------------------------------
    public List<SelectOption> getModule()
    {
      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption(Firsrlabel,Firsrlabel));
      If(module.size()>0)
      { 
        for(Integer i = 0; i < module.size();i++)
        {
          
          options.add(new SelectOption(module[i].SVMXC__ModuleID__c,module[i].SVMXC__Name__c));
        }
      }
        
        return options;
     }
     
//-------------------------------------Call Submodule-------------------------------------    
    public PageReference Callsubmodule() 
    {
        DisplayTags = false;
         Suboptions.clear();
         
         submodule = [Select SVMXC__SubmoduleID__c,SVMXC__Module__r.SVMXC__ModuleID__c,SVMXC__Module__c,SVMXC__IsStandard__c, SVMXC__Description__c,SVMXC__Active__c,SVMXC__Record_Type_Name__c,Name,Id ,SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='submodule' and SVMXC__Module__r.SVMXC__ModuleID__c = :moduleView order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

           Suboptions .add(new SelectOption(Firsrlabel,Firsrlabel));    
        If(submodule.size()>0)
        { 
          for(Integer i = 0; i < submodule.size();i++)
          {
          Suboptions.add(new SelectOption(submodule[i].id,submodule[i].SVMXC__Name__c));
          }
        }
                return null;
    }
    
//---------------------------Methods for Selecting & Returning SubModules..-----------------------------------------
    public  List<SelectOption> Suboptions = new List<SelectOption>();
    public List<SelectOption> getSubModule()
    {                  
        
         return Suboptions ;
    }  
    
    //-------------------------------------Call Tags -------------------------------------   
   
    public PageReference Calltags() 
    { 
         DisplayTags = true;
         standardtag = [Select name,SVMXC__Tag_Text__c,Id,SVMXC__Submodule__c From SVMXC__ServiceMax_Tags__c where SVMXC__Language__c ='Master' and SVMXC__Iscustom__c = false and SVMXC__Submodule__c =:submoduleView order by Name]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA                  
         customtag  = [Select name,Id,SVMXC__Tag_Text__c,SVMXC__Select_Tag__c From SVMXC__ServiceMax_Tags__c Where SVMXC__Language__c ='Master' and SVMXC__Iscustom__c = True and SVMXC__Submodule__c =:submoduleView order by Name]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
         stdSize=standardtag.size();
          custSize=customtag.size();
        return null;
    }
    
//-------------------------------------Geting the Standad Tags ----------------------------------------------------
    
    public List<SVMXC__ServiceMax_Tags__c> getStandardtag() 
    {
          return standardtag;
    }
//------------------------------------- Geting the Custom Tags -----------------------------------------------------------   
    
    public List<SVMXC__ServiceMax_Tags__c> getCustomtag() 
    {
      CheckAllLines = false;
      return customtag;
    }
   
//======================================== Counts custom records ===================================================//
public boolean getIsStdAvail(){
    boolean avail=false;
    if(stdSize>0)
    avail=true;
    return avail;
}

public boolean getIsCustAvail(){
    boolean avail=false;
    if(custSize>0 || isAdd==true)
    avail=true;
    return avail;
}

//======================================== Function to check whether the data is valid for custom modules ===================================================//
    
      
       public Boolean  hasDuplicateInList(List<SObject>listOfRecs, String fldNameInList,Object valToChk )
       { 
        Integer duplicateFound = 0;
        for(SObject recToChk : listOfRecs){
                if(recToChk.get(fldNameInList) == valToChk ) {duplicateFound++ ;}
       }
        if(duplicateFound >1) return true;
        else return false;
       }
              
        public Boolean isValidData()
        {  
          Integer i =0;  
          boolean error=false;
          if(customtag.size()==0 && isAdd==false)
          {error=true;}
         
         
          for (i=0;i<customtag.size();i++)
          {
          //if(customtag[i].SVMXC__Select_Tag__c == false)
            {
             if (hasDuplicateInList(customtag,'Name',customtag.get(i).Name) == true)
             {
                            error=true;
                            customtag.get(i).Name.addError(getTAG018());
             }
             if (customtag.get(i).Name==null)
             {
                        error=true;
                        customtag.get(i).Name.addError(getTAG013());
             }
             if (customtag.get(i).Tag_Text__c==null)
             {
                        error=true;
                        customtag.get(i).Tag_Text__c.addError(getTAG014());
             }
            }
          }
       return error;
      }
      
      // -------------------------------------All PageReference Methodes.....-------------------------------------
  
  // ------------------------------------- Back TO Home -------------------------------------     
       public PageReference BacktoHome() 
       {
         String url = '/';
         //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
         //if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
         if(svmxSettingList.containsKey('SET001') == true){
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                url = '/lightning/n/SVMXC__ServiceMax_Setup';
            }else{
                url =svmxSettingList.get('SET001');
            }
         }
         //Changes done by Nidhi ends here
         PageReference HomePage = new PageReference(url);
         HomePage.setRedirect(true);
        return HomePage; 
       }
      
      
      //********************************************************Method for ADD TAG****************************************
       public PageReference AddTag() 
       {
         SVMXC__ServiceMax_Tags__c newListLine = new SVMXC__ServiceMax_Tags__c(SVMXC__Language__c ='Master',SVMXC__Iscustom__c = true,SVMXC__Submodule__c = submoduleView);                 
         customtag.add(newListLine);
         custSize = customtag.size();
         return null;
       }
       // ********************************************************Method for Save  Tags****************************************
       public PageReference Save() 
       {
          boolean error=false;
          error=isValidData();
          if(error==true)
          { 
            DisplayBlockLevelMessage = true;   
            return null;    
          }
          try 
          {
                //upsert customtag;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(customtag, COMM_SecurityUtils.Access.Upsertable)){
                    upsert customtag; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    DisplayBlockLevelMessage = true; 
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG008(),getTAG010()));     
                }
                else{
                    DisplayBlockLevelMessage = true; 
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, System.label.COMM001_TAG142));
                    return null;
                }
          }
          catch (Exception ex)
          { 
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
          }
          custsize = customtag.size();
          return null;
       }
          
 //========================================================== Method for Delete Tags ===================================================/
 
 public PageReference del()
 {
List<SVMXC__ServiceMax_Tags__c> delrecId = new List<SVMXC__ServiceMax_Tags__c>();
    DisplayBlockLevelMessage = true; 

Integer i;
List<Integer> selectedLines = new List<Integer>();

        for (i=0;i<customtag.size();i++){
            if(customtag.get(i).SVMXC__Select_Tag__c==true)
            {          
                selectedLines.add(i);
               if(customtag.get(i).Id!=NULL)
               delrecId.add(customtag.get(i));
            }
        }
        for (i=selectedLines.size()-1;i>=0;i--){
        customtag.remove(selectedLines.get(i));
        }
        custSize=customtag.size();
        if(selectedLines.size()==0)
        {
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG015(),getTAG023()));
        return null;
        }
        try {
            if(delrecId.size()>0){
                //delete delrecId;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Tags__c')){
                    delete delrecId; //SDL-SVMX-DELETE-FLS-ENFORCED
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG009(),getTAG012()));     
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    return null;
                }
            }
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
          /*****************Removing below lines as it is dead code which will never get executed . this is done while API upgrade *********/
       // return null;
        
    //List<SVMXC__ServiceMax_Tags__c> delrecId = new List<SVMXC__ServiceMax_Tags__c>();
    List<Integer> dellines = new List<Integer>();
     
    for ( Integer j=0;j<customtag.size();j++)
    {
      if (customtag.get(j).SVMXC__Select_Tag__c==true)
      {
         dellines.add(j);
         Integer DL = dellines.size();
         if(customtag.get(j).Id!=NULL)
         {
            delrecId.add(customtag.get(j));
            Integer dr = delrecId.size();
         }
       }
    }  
    if(delrecId.size()>0)
    {
      try
      {
        //delete delrecId;
        if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Tags__c')){
            delete delrecId; //SDL-SVMX-DELETE-FLS-ENFORCED
            DisplayBlockLevelMessage = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG009(),getTAG012()));// Message Record(s) deleted
        }
        else{
            DisplayBlockLevelMessage = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
            return null;
        }
      }
      catch (Exception ex)
      { 
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
      }
    }
    if(dellines.size()>0)
    {
      dellines.sort();          
      for (i=dellines.size()-1;i>=0;i--)
      {
        customtag.remove(dellines.get(i));
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG009(),getTAG012()));
      }
    }
    else
    { 
        DisplayBlockLevelMessage = true; 
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG015(),getTAG023()));      
        return null;    
    }
    custsize = customtag.size();
  return null;
  
 }
     
//========================================================== Set true to display blocklevel messges ===================================================//
        public Boolean DisplayBlockLevelMessage = false;
        public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }   
//========================================================== Set true to display Standard & Custom Tags Pageblock ===================================================//
        public Boolean DisplayTags = false;
        public Boolean getDisplayTags(){ return DisplayTags; }  
}