public  with sharing class CONF_ManageModules{
       
//======================================== Simple Display Utility ===================================================// 
    //=========================================== Translation ===============================================//
    // Call a Method in UTIL class to return Tags, Send SubModule ID for getting TAGS
    //SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();

    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    Public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('CONF001');

    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('CONF001');

    public String getTAG001(){ return System.Label.CONF001_TAG001;} //Standard Module Definitions
    public String getTAG002(){ return System.Label.CONF001_TAG002;} //Custom Module Definitions
    public String getTAG003(){ return System.Label.CONF001_TAG003;} //List Submodules
    public String getTAG004(){ return System.Label.CONF001_TAG004;} //Back To Setup Home
    public String getTAG005(){ return System.Label.CONF001_TAG005;} //Add Module
    public String getTAG006(){ return System.Label.CONF001_TAG006;} //List Submodules
    public String getTAG007(){ return System.Label.CONF001_TAG007;} //Save
    public String getTAG008(){ return System.Label.CONF001_TAG008;} //Delete
    public String getTAG009(){ return System.Label.CONF001_TAG009;} //Module Definitions
    public String getTAG010(){ return System.Label.CONF001_TAG010;} //Invalid Data
    public String getTAG011(){ return System.Label.CONF001_TAG011;} //Please select a Module You must select a Module in order to delete
    public String getTAG012(){ return System.Label.CONF001_TAG012;} //Please select a Module You must select a Module in order to list its Submodules
    public String getTAG013(){ return System.Label.CONF001_TAG013;}//You must enter a Module Id
    public String getTAG014(){ return System.Label.CONF001_TAG014;} //You must enter a Name
    public String getTAG015(){ return System.Label.CONF001_TAG015;} //Manage Modules Help
    public String getTAG018(){ return System.Label.CONF001_TAG018;}//Review all error messages below and click save 
    public String getTAG020(){ return System.Label.CONF001_TAG020;} //Record saved sucessfully
    public String getTAG022(){ return System.Label.CONF001_TAG022;}//Record sucessfully deleted 
    public String getTAG023(){ return System.Label.CONF001_TAG023;} //No records to display
    public String getTAG024(){ return System.Label.CONF001_TAG024;}//Requesting...
    public String getTAG025(){ return System.Label.CONF001_TAG025;}//Duplicate Module Id Found
    
    //Neeraj(Feb-7th-2012): Added new tags to fix translation related issues.
    public String getTAG026(){ return System.Label.CONF001_TAG026;}//Module ID
    public String getTAG027(){ return System.Label.CONF001_TAG027;}//Name
    public String getTAG028(){ return System.Label.CONF001_TAG028;}//Description
    
    public String getHLPURL() {return System.Label.CONF001_HLPURL;}

//======================================== Module Unique ===================================================//
public Boolean  hasDuplicateInList(List<SObject> listOfRecs, String fldNameInList,Object valToChk ){
        Integer duplicateFound = 0;
        for(SObject recToChk : listOfRecs){
                if(recToChk.get(fldNameInList) == valToChk ) {duplicateFound++ ;}
        }
        if(duplicateFound >1) return true;
        else return false;
    }

//======================================== Setting Initial Checklist status ===================================================//
Boolean CheckAllLines=false;  
Boolean isAdd=false;  
public String SelModId;
//public Boolean getCheckAllLines() {return CheckAllLines;  }
//public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
Id EstRecType = getEstRecordTypes().Id;
public Integer custSize=0;
  
List<SVMXC__ServiceMax_Processes__c> serviceMaxProcesses;
List<SVMXC__ServiceMax_Processes__c> cust_serviceMaxProcesses;
public  List<SVMXC__ServiceMax_Processes__c> deleteCustomModules = new List<SVMXC__ServiceMax_Processes__c>();  

//======================================== Constructure call ===================================================//      
public CONF_ManageModules(){
   cust_serviceMaxProcesses = [Select Id, SVMXC__ModuleID__c,SVMXC__Name__c,SVMXC__Description__c,SVMXC__Select__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Module' and SVMXC__IsStandard__c=false order by SVMXC__ModuleID__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        serviceMaxProcesses = [Select SVMXC__ModuleID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Select__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Module' and SVMXC__IsStandard__c=true order by SVMXC__ModuleID__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    custSize=cust_serviceMaxProcesses.size();
}


public List<SVMXC__ServiceMax_Processes__c> getStandModule() {
        return serviceMaxProcesses;
}

public List<SVMXC__ServiceMax_Processes__c> getCustModule() {
        custSize=cust_serviceMaxProcesses.size();
        return cust_serviceMaxProcesses;
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
//======================================== Setting Initial Checklist status ===================================================//
public RecordType getEstRecordTypes(){
RecordType erTypes;
try{
String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Processes__c\' and Name=\'Module\'';       
            erTypes = Database.query(SOQL);      
}
catch (Exception e){}   
return erTypes;
}

//======================================== Function to check whether the data is valid for custom modules ===================================================//
public Boolean isValidData(String OpType){
        Integer i;  
        boolean error=false;
        if(cust_serviceMaxProcesses.size()==0){
                error=true;
        }

        for (i=0;i<cust_serviceMaxProcesses.size();i++)
        {
            if(cust_serviceMaxProcesses.get(i).Select__c==false || OpType=='Save')
            {
                if (hasDuplicateInList(cust_serviceMaxProcesses, 'ModuleID__c',cust_serviceMaxProcesses.get(i).ModuleID__c) == true){
                        error=true;
                        cust_serviceMaxProcesses.get(i).ModuleID__c.addError(getTAG025());
                }
                if (cust_serviceMaxProcesses.get(i).ModuleID__c==null){
                        error=true;
                        cust_serviceMaxProcesses.get(i).ModuleID__c.addError(getTAG013());
                }
                if (cust_serviceMaxProcesses.get(i).Name__c==null){
                        error=true;
                        cust_serviceMaxProcesses.get(i).Name__c.addError(getTAG014());
                }
            }
        }
        return error;
}
//======================================== Action for adding modules in as line items ===================================================//
public PageReference AddNewMod() {
isAdd=true;
//boolean error=false;
//error=isValidData();

    /* if (error==true){
    Cust_DisplayBlockLevelMessage = true;
    Std_DisplayBlockLevelMessage = false;     
    return null;    
    }
    else{ 
  SVMXC__ServiceMax_Processes__c newListLine = new SVMXC__ServiceMax_Processes__c(RecordTypeId=EstRecType);  
    cust_serviceMaxProcesses.add(newListLine);
    return null;
    } */
  SVMXC__ServiceMax_Processes__c newListLine = new SVMXC__ServiceMax_Processes__c(RecordTypeId=EstRecType);  
    cust_serviceMaxProcesses.add(newListLine);
    return null;
}

//======================================== Action for saving the custom field changes ===================================================//
public PageReference saveMod() {
boolean error=false;
error=isValidData('Save');
Integer i;
List<Integer> selectedLines = new List<Integer>();

  if(error==true){
       Cust_DisplayBlockLevelMessage = true; 
        Std_DisplayBlockLevelMessage = false;
        //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG010(),getTAG018()));    
    return null;    
    }

    try {
        if(cust_serviceMaxProcesses.size() >0){
      //upsert cust_serviceMaxProcesses;
      if(COMM_SecurityUtils.getInstance().verifyFieldAccess(cust_serviceMaxProcesses, COMM_SecurityUtils.Access.Upsertable)){
        upsert cust_serviceMaxProcesses; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
      }
      else{
        Cust_DisplayBlockLevelMessage = true;
        Std_DisplayBlockLevelMessage = false;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, System.label.COMM001_TAG142));     
        return null;
      }
    }      
        Cust_DisplayBlockLevelMessage = true;
        Std_DisplayBlockLevelMessage = false;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG007()+ ':',getTAG020()));     
        }
    catch (Exception ex)
        {
           ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
        return null;
}
//======================================== Action for deleting the custom field changes ===================================================//
public PageReference deleteMod() {
    Cust_DisplayBlockLevelMessage = true; 
    Std_DisplayBlockLevelMessage = false;
    isAdd=false;
boolean error=false;
//error=isValidData('Del');
Integer i;
List<Integer> selectedLines = new List<Integer>();

  if(error==true){

    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG010(),getTAG018()));      
    return null;    
    }
        for (i=0;i<cust_serviceMaxProcesses.size();i++){
            if(cust_serviceMaxProcesses.get(i).Select__c==true)
            {          
                selectedLines.add(i);
               if(cust_serviceMaxProcesses.get(i).Id!=NULL)
               deleteCustomModules.add(cust_serviceMaxProcesses.get(i));
            }
        }
        for (i=selectedLines.size()-1;i>=0;i--){
        cust_serviceMaxProcesses.remove(selectedLines.get(i));
        }
        custSize=cust_serviceMaxProcesses.size();
        if(selectedLines.size()==0)
        {
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG010(),getTAG011()));
        return null;
        }
    try {
        if(deleteCustomModules.size()>0) {
      //delete deleteCustomModules;
      if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
        delete deleteCustomModules; //SDL-SVMX-DELETE-FLS-ENFORCED
      }
      else{
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, System.label.COMM001_TAG142));     
        return null;
      }
    }
        deleteCustomModules.clear();
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG008()+ ':',getTAG022()));     
        }
    catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
        return null;
}
//======================================== Action for listing submodules for selected modules ===================================================//
public PageReference MoveStdListSubmod(){
String mod_id;
List<Integer> selectedLines = new List<Integer>();
Integer i;      

  for (i=0;i<serviceMaxProcesses.size();i++){
    if (serviceMaxProcesses.get(i).Select__c==true){
        mod_id=serviceMaxProcesses.get(i).Id;
        selectedLines.add(i);
        }
    }
    for (i=0;i<cust_serviceMaxProcesses.size();i++){
    if (cust_serviceMaxProcesses.get(i).Select__c==true){
        mod_id=cust_serviceMaxProcesses.get(i).Id;
        if(mod_id!=NULL)
        selectedLines.add(i);
        }
    }
  //If selected lines doesnot have any ids associated with it Error will be thrown
    if(selectedLines.size()!=1){
    Std_DisplayBlockLevelMessage = true; 
    Cust_DisplayBlockLevelMessage = false;
    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG010(),getTAG012()));  
    return null;    
    }
SelModId=mod_id;
      return GoSubMod(); 
}
//======================================== Action for listing submodules for selected modules ===================================================//
public PageReference MoveCustListSubmod(){
String mod_id;
List<Integer> selectedLines = new List<Integer>();
Integer i;      

  for (i=0;i<serviceMaxProcesses.size();i++){
    if (serviceMaxProcesses.get(i).Select__c==true){
        mod_id=serviceMaxProcesses.get(i).Id;
        selectedLines.add(i);
        }
    }
    for (i=0;i<cust_serviceMaxProcesses.size();i++){
    if (cust_serviceMaxProcesses.get(i).Select__c==true){
        mod_id=cust_serviceMaxProcesses.get(i).Id;
        if(mod_id!=NULL)
        selectedLines.add(i);
        }
    }
  //If selected lines doesnot have any ids associated with it Error will be thrown
    if(selectedLines.size()!=1){
    Cust_DisplayBlockLevelMessage = true; 
    Std_DisplayBlockLevelMessage = false; 
    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG010(),getTAG012()));  
    return null;    
    }
SelModId=mod_id;
      return GoSubMod(); 
}

//======================================== Action "Back To Setup Home" ===================================================//
public PageReference GoSubMod(){
      String url = '/';
      if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
      PageReference ManageSubmod = new PageReference(url);
      ManageSubmod.getparameters().put('mid',SelModId);
      ManageSubmod.setRedirect(true);
      return ManageSubmod;  
}
//======================================== Action "Back To Setup Home" ===================================================//
public PageReference GoSetupHome(){
      String url = '/';
      //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
      //if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
      
      if(svmxSettingList.containsKey('SET002') == true){ 
        if(UserInfo.getUiThemeDisplayed()=='Theme4d'|| UserInfo.getUiThemeDisplayed()=='Theme4u'){
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
//======================================== Set true to display blocklevel messge ===================================================//
public Boolean Std_DisplayBlockLevelMessage = false;
public Boolean getStdDisplayBlockLevelMessage(){ return Std_DisplayBlockLevelMessage; }     
public Boolean Cust_DisplayBlockLevelMessage = false;
public Boolean getCustDisplayBlockLevelMessage(){ return Cust_DisplayBlockLevelMessage; }          
}