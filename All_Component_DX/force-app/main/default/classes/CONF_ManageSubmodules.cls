/*******************************************************************************************************************
ServiceMax Controller Class for the VF Page CONF_ManageSubmodules:
-----------------------------------------------------------------------

*******************************************************************************************************************/
public  with sharing class CONF_ManageSubmodules {
   
/*******************************************************************************************************************
Global variables   
*******************************************************************************************************************/
    Boolean CheckAllLines=false;
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
    public String emptyString='';
     public  List<SVMXC__ServiceMax_Processes__c> deleteCustomSubModules ;
    
    
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    Map<String, String> svmxSettingList = settings.SVMX_getSettingList('CONF008');
    //COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('CONF008'); 
    String moduleView;
    public ID ModuleID;    
    public ID RecordTypeId;
    public Integer custSize=0;
    public ID mId;
    Boolean isAdd=false; 
    List<SVMXC__ServiceMax_Processes__c> sMaxStandSubmodule;
    List<SVMXC__ServiceMax_Processes__c> sMaxCustomSubmodule;
    List<SVMXC__ServiceMax_Processes__c> modules;
    List<SVMXC__ServiceMax_Processes__c> smodulesID;
  
//======================================== Constructor To get the module List  ===================================================//                
    public CONF_ManageSubmodules()
    {
        
        /* if(System.currentPageReference().getParameters().get('mid')!= null){
             mId = System.currentPageReference().getParameters().get('mid');
              modules=[Select SVMXC__Name__c,  SVMXC__ModuleID__c, Id From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c = 'Module'and SVMXC__ModuleID__c=:mId order by SVMXC__ModuleID__c];
         }
         else{*/
         
         
          mId = System.currentPageReference().getParameters().get('mid');
           if(mId != null){
            moduleView=mId;
            ModuleID = moduleView;
            sMaxStandSubmodule = [Select Select__c,RecordTypeId,SVMXC__Module__c,SVMXC__SubmoduleID__c,  SVMXC__Name__c,  SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Submodule' and SVMXC__IsStandard__c=true and SVMXC__Module__c = :mId order by SVMXC__SubmoduleID__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            sMaxCustomSubmodule = [Select Select__c,RecordTypeId,SVMXC__Module__c,SVMXC__SubmoduleID__c,  SVMXC__Name__c,  SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Submodule' and SVMXC__IsStandard__c=false and SVMXC__Module__c = :mId order by SVMXC__SubmoduleID__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            custSize = sMaxCustomSubmodule.size();
         }
            modules=[Select SVMXC__Name__c,  SVMXC__ModuleID__c, Id From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c = 'Module' order by SVMXC__ModuleID__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA    
         //}   
         RecordTypeId=getRecordType().Id;
    }
    
//======================================== Counts custom records ===================================================//

public boolean getIsCustAvail(){
        boolean avail=false;
        if(custSize>0 || isAdd==true)
        avail=true;
        return avail;
}
public Integer getcustSize(){
        return custSize;
}
 
//======================================== Function to get the Pick list is onchange  ===================================================//             
    public PageReference submodule() 
    { 
        isAdd=false;
        //This two List get the Standard and Custom Module records when picklist is onchange 
         //mId = System.currentPageReference().getParameters().get('mid');
            if(moduleView  !=getTAG026()){
       
             sMaxStandSubmodule = [Select Select__c,RecordTypeId,SVMXC__Module__c,SVMXC__SubmoduleID__c,  SVMXC__Name__c,  SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Submodule' and SVMXC__IsStandard__c=true and SVMXC__Module__c = :moduleView  order by SVMXC__SubmoduleID__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
             sMaxCustomSubmodule = [Select Select__c,RecordTypeId,SVMXC__Module__c,SVMXC__SubmoduleID__c,  SVMXC__Name__c,  SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Submodule' and SVMXC__IsStandard__c=false and SVMXC__Module__c = :moduleView order by SVMXC__SubmoduleID__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                 custSize=sMaxCustomSubmodule.size();
           ModuleID = moduleView;
           return null;
         }
         else {
             sMaxStandSubmodule =null;
             sMaxCustomSubmodule =null;
             return null;
         }
         
    }
/*******************************************************************************************************************
 Method to get RecordType
*******************************************************************************************************************/
 
    public RecordType getRecordType()
        {
        RecordType rType;
        String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Processes__c\' and Name=\'Submodule\'';        
        try{
            rType = Database.query(SOQL); 
           } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}   
        return rType;
        }
/*******************************************************************************************************************
 Method to get Pick list values from module object
*******************************************************************************************************************/
         
    public List<SelectOption> getItems() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(getTAG026(),getTAG026()));
        for(SVMXC__ServiceMax_Processes__c svmx_processes :modules ){
            options.add(new SelectOption(svmx_processes.Id,svmx_processes.SVMXC__Name__c));
        }
     
        return options;
    }
 //=================================get and Set for module view=================================================   
    public String getModuleView()
    {
        return moduleView;
    }        
    public void setModuleView(String moduleView)
    {
        this.moduleView = moduleView;
    }

//=================================get and Set for StandardSubModules=================================================    
    public List<SVMXC__ServiceMax_Processes__c> getStandSubModule() {
             
                return sMaxStandSubmodule;
    }
    public List<SVMXC__ServiceMax_Processes__c> getCustomSubModule() {
                 return sMaxCustomSubmodule ;
    }
/*******************************************************************************************************************
 Method to Return back to Home Page
*******************************************************************************************************************/  
   public PageReference BackToHomePage(){
        //String url = svmxSettingList.get('SET001');
        // PageReference hoPage = new PageReference('/apex/CONF_SetupHome');
        //hoPage.setRedirect(true);
        //return hoPage;
        String url = '/';
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        //if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
        if(svmxSettingList.containsKey('SET001') == true){         
            if(UserInfo.getUiThemeDisplayed()=='Theme4d'){
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
 /*******************************************************************************************************************
 Method for Save 
*******************************************************************************************************************/ 
   public PageReference Save(){
        boolean error=false;
        Integer i;
            DisplayBlockLevelMessage = false; 
            CustomDisplayBlockLevelMessage = true;
       
        error=isValidData();
       
        if(error==true){
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG019(),getTAG013()));//,getTAG019()));      
            return null;    
        }
        else{
            //upsert sMaxCustomSubmodule;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(sMaxCustomSubmodule, COMM_SecurityUtils.Access.Upsertable)){
                upsert sMaxCustomSubmodule; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG008()+ ':', getTAG014() ));
                return null;
            }
            else{
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                return null;
            }
        }
          /*****************Removing below lines as it is dead code which will never get executed . this is done while API upgrade *********/
        //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG011(),getTAG014() ));
        //return null;
    }
    
     
    
 /*******************************************************************************************************************
 Method for check Duplicates for creation of custom Submodules
*******************************************************************************************************************/ 
     
    public Boolean  hasDuplicateInList(List<SObject> listOfRecs, String fldNameInList,Object valToChk ){
        Integer duplicateFound = 0;
        for(SObject recToChk : listOfRecs){
                if(recToChk.get(fldNameInList) == valToChk ) {duplicateFound++ ;}
        }
        if(duplicateFound >1) return true;
        else return false;
    }
/*******************************************************************************************************************
 Method for Validate the data creation of custom Submodules
*******************************************************************************************************************/ 
     public Boolean isValidData(){
            Integer i =0;  
            boolean error=false;


            if(sMaxCustomSubmodule.size()==0 ){
                    error=true;
            }
            

            for (i=0;i<sMaxCustomSubmodule.size();i++)
            {
               //if(sMaxCustomSubmodule[i].SVMXC__Select__c == false)
               {
                    if (hasDuplicateInList(sMaxCustomSubmodule, 'SVMXC__SubmoduleID__c',sMaxCustomSubmodule.get(i).SVMXC__SubmoduleID__c) == true){
                            error=true;
                            sMaxCustomSubmodule.get(i).SVMXC__SubmoduleID__c.addError('Duplicate' + getTAG024());
                    }
                    if (sMaxCustomSubmodule.get(i).SVMXC__Name__c==null){
                            error=true;
                            sMaxCustomSubmodule.get(i).SVMXC__Name__c.addError(getTAG025());
                    }
                    if (sMaxCustomSubmodule.get(i).SVMXC__SubmoduleID__c==null ||(sMaxCustomSubmodule.get(i).SVMXC__SubmoduleID__c =='')){
                            error=true;
                            sMaxCustomSubmodule.get(i).SVMXC__SubmoduleID__c.addError(getTAG024());
                    }
                    else if ((sMaxCustomSubmodule.get(i).SVMXC__SubmoduleID__c.length()< 8)){
                            error=true;
                            sMaxCustomSubmodule.get(i).SVMXC__SubmoduleID__c.addError(getTAG024());
                    }                    
                    
                  }
            }

            return error;
    }
 /*******************************************************************************************************************
 Method Delete 
*******************************************************************************************************************/ 
        
         public PageReference RemoveCustomSubmoduleLine()
        {  

         List<SVMXC__ServiceMax_Processes__c> unDeletedSubModules = new List<SVMXC__ServiceMax_Processes__c>(); 
         deleteCustomSubModules   = new List<SVMXC__ServiceMax_Processes__c>();      
         List<Integer> selectedLines = new List<Integer>();
         Integer i;   
         isAdd=false;
            
         for (i=0;i<sMaxCustomSubmodule.size();i++)
            {
            if (sMaxCustomSubmodule.get(i).Select__c == true)
                {
                        selectedLines.add(i);
                        if(sMaxCustomSubmodule.get(i).Id != NULL)
                        {
                            deleteCustomSubModules.add(sMaxCustomSubmodule.get(i));
                        }
                }
                else unDeletedSubModules.add(sMaxCustomSubmodule.get(i));
            }
            custSize=unDeletedSubModules.size();
                if(selectedLines.size()==0)
             {
             CustomDisplayBlockLevelMessage = true;
             ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011(), getTAG022())); //when nothing is selected  on settings         
             return null;    
            }
            
            sMaxCustomSubmodule.clear();
            sMaxCustomSubmodule = unDeletedSubModules;
            custSize=sMaxCustomSubmodule.size();
            if(deleteCustomSubModules.size() >0 ){
                //delete deleteCustomSubModules;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete deleteCustomSubModules; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    CustomDisplayBlockLevelMessage= true; 
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    return null;
                }
            }
        CustomDisplayBlockLevelMessage= true; 
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTag009() + ':',getTAG016()));
        return null;
    }
/*******************************************************************************************************************
 Method for Check the multiple check box and redirect the page 
*******************************************************************************************************************/ 
    public PageReference standardSettings() {
        List<SVMXC__ServiceMax_Processes__c> selectedLines = new List<SVMXC__ServiceMax_Processes__c>();
        Integer i;
         String pgName;
        
        for(i = 0; i<sMaxStandSubmodule.size(); i++ ){
            if (sMaxStandSubmodule.get(i).Select__c==true)
                {
                        selectedLines.add(sMaxStandSubmodule.get(i));
                }
        }
        if (selectedLines.size()!= 1)
            {
                DisplayBlockLevelMessage = true;
                CustomDisplayBlockLevelMessage =false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag011(),getTAG020()));            
                 return null;    
            }
        if (selectedLines.size()==1)
            {
                String subModuleID = selectedLines[0].Id;  
               // String moduleId = selectedLines[0].Id;
               
                 if(svmxSettingList.containsKey('SET002') == true) 
               
                pgName = svmxSettingList.get('SET002');
                //String urlToLaunch = pgName + '?sid=' + subModuleID + '&mid=' + moduleView;//changed due to sid being used by sfdc 29/12/2010 - HH
                String urlToLaunch = pgName + '?svmx_sid=' + subModuleID + '&mid=' + moduleView;
                    PageReference hoPage = new PageReference(urlToLaunch);   
                    hoPage.setRedirect(true);
                    return hoPage;             
            } 
              
        return null;
    }
 /*******************************************************************************************************************
 Method for Check the multiple check box and redirect the page 
*******************************************************************************************************************/ 
    public PageReference customSettings() {
        String subModuleID;
        PageReference hoPage;
        String moduleID;
        String pgName;
        List<Integer> selectedLines = new List<Integer>();
        Integer i;
        
        for(i = 0; i<sMaxCustomSubmodule.size(); i++ ){
            if (sMaxCustomSubmodule.get(i).Select__c==true)
                {
                        if(sMaxCustomSubmodule.get(i).Id != NULL)
                        {
                            selectedLines.add(i);
                        }
                        
                }
        }
        if (selectedLines.size()!= 1)
            {
                DisplayBlockLevelMessage = false;
                CustomDisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011(),getTAG021()));//messg to show when nothing is selected            
                 return null;    
            }
        if (selectedLines.size()==1)
            {
                for(i = 0; i<sMaxCustomSubmodule.size(); i++ ){
                    if (sMaxCustomSubmodule.get(i).Select__c==true)
                        {
                             subModuleID = sMaxCustomSubmodule.get(i).Id; 
                             //moduleID = sMaxCustomSubmodule.get(i).Id;
                             
                        }
                }
                     if(svmxSettingList.containsKey('SET002') == true) 
                     
                     pgName = svmxSettingList.get('SET002');
                    //String urlToLaunch = pgName + '?sid=' + subModuleID + '&mid=' + moduleView;//changed due to sid beign used by sfdc 29/12/2010 - HH
                    String urlToLaunch = pgName + '?svmx_sid=' + subModuleID + '&mid=' + moduleView;
                    hoPage = new PageReference(urlToLaunch);   
                    
                //hoPage = new PageReference('/apex/CONF_ManageSettings?sId='+subModuleID+'?mId='+moduleID);   
            } 
              
      
        hoPage.setRedirect(true);
        return hoPage;             
    }
/*******************************************************************************************************************
Method used to display/hide pageBlock Table column headings     
*******************************************************************************************************************/   
    public Boolean getDisplayTableColumns() {       
        if (sMaxCustomSubmodule.size()==0)
            {
            //CheckAllLines = false;
            return false;
            }
        else
            return true;        
    }
/*******************************************************************************************************************
 Method for Adding a Custom SubModule Line 
*******************************************************************************************************************/ 

     public PageReference AddCustomSubModuleLine() {
       isAdd=true;
       system.debug('1zzzzzzzz'+ModuleID);
       SVMXC__ServiceMax_Processes__c newListLine = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RecordTypeId ,SVMXC__Module__c =ModuleID  ,SVMXC__IsStandard__c=false );
       system.debug('2zzzzzzzz'+newListLine);  
         sMaxCustomSubmodule.add(newListLine );   
          return null;
    }
    
/*******************************************************************************************************************
 Method for Set true to display blocklevel message
*******************************************************************************************************************/ 
 
    public Boolean DisplayBlockLevelMessage = false;
    public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }  
     public Boolean CustomDisplayBlockLevelMessage = false;
    public Boolean getCustomDisplayBlockLevelMessage(){ return CustomDisplayBlockLevelMessage; }      
   
/*******************************************************************************************************************
Getter & Setter Methods
*******************************************************************************************************************/
    public Boolean getCheckAllLines() {return CheckAllLines;  }
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;} 
    //public String gethelpURL(){return helpURL;    }  
    //public void sethelpURL(String txt){helpURL=txt;}
    //public String getTAG001() {return svmxTagList.get('TAG001');}
    public String getTAG001(){ return System.Label.CONF008_TAG001;}//
    public String getTAG002(){ return System.Label.CONF008_TAG002;}//Back to Home Setup
    public String getTAG003(){ return System.Label.CONF008_TAG003;}//Manage Submodule Definitions Help
    public String getTAG004(){ return System.Label.CONF008_TAG004;}//Select Module
    public String getTAG005(){ return System.Label.CONF008_TAG005;}//Standard Submodules
    public String getTAG006(){ return System.Label.CONF008_TAG006;}//Custom Submodules
    public String getTAG007(){ return System.Label.CONF008_TAG007;}//New Submodules
    public String getTAG008(){ return System.Label.CONF008_TAG008;}//Save
    public String getTAG009(){ return System.Label.CONF008_TAG009;}//Delete
    public String getTAG010(){ return System.Label.CONF008_TAG010;}//Settings
    public String getTAG011(){ return System.Label.CONF008_TAG011;}//Invalid Data 
    public String getTAG012(){ return System.Label.CONF008_TAG012;}//Review all error messages below and click save 
    //public String getTAG013(){ return System.Label.CONF008_TAG013;}//Save: 
    public String getTAG014(){ return System.Label.CONF008_TAG014;}//Record saved sucessfully 
    public String getTAG015(){ return System.Label.CONF008_TAG015;}//Delete: 
    public String getTAG016(){ return System.Label.CONF008_TAG016;}//Record sucessfully deleted 
    public String getTAG017(){ return System.Label.CONF008_TAG017;}//No records to display 
    public String getTAG019(){ return System.Label.CONF008_TAG019;}//Record was not saved
    public String getTAG020(){ return System.Label.CONF008_TAG020;}//Please select a one Standard SubModule
    public String getTAG021(){ return System.Label.CONF008_TAG021;}//Please select a one Custom SubModule
    public String getTAG022(){ return System.Label.CONF008_TAG022;}//Please select atleast one to Delete
    public String getTAG023(){ return System.Label.CONF008_TAG023;}//Records  Deleted Successfully
    public String getTAG024(){ return System.Label.CONF008_TAG024;}//Enter SubModule ID
    public String getTAG025(){ return System.Label.CONF008_TAG025;}//Enter Name
    public String getTAG026(){ return System.Label.CONF008_TAG026;}//--None--
    public String getTAG027(){ return System.Label.CONF008_TAG027;}//No Records to Display
    public String getTAG028(){ return System.Label.CONF008_TAG028;}//Loding....
    
    //Neeraj(Feb-7th-2012): Added new tags to resolve translation issue.
    public String getTAG029(){ return System.Label.CONF008_TAG029;}//Submodule ID
    public String getTAG030(){ return System.Label.CONF008_TAG030;}//Name
    public String getTAG031(){ return System.Label.CONF008_TAG031;}//Description
    
    public String getHLPURL() {return System.Label.CONF008_HLPURL;}        
    
}