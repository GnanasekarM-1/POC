public  with sharing class CONF_ManageObjectMappings {
        public List<SVMXC__ServiceMax_Processes__c> serviceMaxStandardObjects = new List<SVMXC__ServiceMax_Processes__c>();
        public List<SVMXC__ServiceMax_Processes__c> ServiceMaxCustomObjects = new List<SVMXC__ServiceMax_Processes__c>();
         Boolean isAdd=false; 
         SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
         
          SVMXC.COMM_Utils_ManageSettings commUtilSettings = new SVMXC.COMM_Utils_ManageSettings();
           Map<String, String> svmxSettingList = commUtilSettings.SVMX_getSettingList('CONF011');
          //SVMXC.COMM_Utils_ManageTags commUtilTags = new SVMXC.COMM_Utils_ManageTags();
          //public Map<String, String> svmxTagList = commUtilTags.SVMX_getTagList('CONF011');
          
        
    
    public CONF_ManageObjectMappings (){
    
        serviceMaxStandardObjects= [Select id,SVMXC__Select__c, SVMXC__MapID__c, SVMXC__Name__c,  SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' and SVMXC__IsStandard__c=true and SVMXC__Source_Object_Name__c != Null order by SVMXC__MapID__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ServiceMaxCustomObjects= [Select id,SVMXC__Select__c ,SVMXC__MapID__c, SVMXC__Name__c,  SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' and SVMXC__IsStandard__c=false and SVMXC__Source_Object_Name__c != Null order by SVMXC__MapID__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

    }
         
    
    //Select SVMXC__MapID__c,  Name,  SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' and SVMXC__IsStandard__c=true
    public List<SVMXC__ServiceMax_Processes__c> getStandAutomation() {
                                 return serviceMaxStandardObjects;
    }
    public List<SVMXC__ServiceMax_Processes__c> getCustomAutomation() {
                                return ServiceMaxCustomObjects;
    }
    //=================================================== View Function===============
    public PageReference view(){
        
        List<Integer> selectedLines = new List<Integer>();
         Integer i;  
        String mapID=null; 
        String pid=null;  
        String pgName;  
        String retURL;
         for (i=0;i<serviceMaxStandardObjects.size();i++)
            {
            if (serviceMaxStandardObjects.get(i).SVMXC__Select__c == true)
                {
                        selectedLines.add(i);
                }
            }
            if (selectedLines.size()!= 1)
            {
                DisplayBlockLevelMessage = true;
                CustomDisplayBlockLevelMessage =false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag014(),getTAG012()));            
                return null;    
            }
            if (selectedLines.size()== 1){
                for(i = 0; i< serviceMaxStandardObjects.size(); i++ ){
                    if (serviceMaxStandardObjects.get(i).SVMXC__Select__c==true)
                        {
                             mapID = serviceMaxStandardObjects.get(i).SVMXC__MapID__c; 
                             pid =  serviceMaxStandardObjects.get(i).Id;
                        }
                }
                    if(svmxSettingList.containsKey('SET001') == true)                   
                     pgName = svmxSettingList.get('SET001');
                    
                    String urlToLaunch = pgName + '?sMode=sView&objMapId='+pid;
                    PageReference hoPage = new PageReference(urlToLaunch);   
                    hoPage.setRedirect(true);
                    return hoPage; 
                           
            }
        
        return null;
    }
    //====================================Standard Clone==================================
    public PageReference StandardClone(){
        
        List<Integer> selectedLines = new List<Integer>();
         Integer i;  
        String mapID=null;
        String pgName;
         String pid=null;   
         String retURL;   
         for (i=0;i<serviceMaxStandardObjects.size();i++)
            {
            if (serviceMaxStandardObjects.get(i).SVMXC__Select__c == true)
                {
                        selectedLines.add(i);
                }
            }
            if (selectedLines.size()!= 1)
            {
                DisplayBlockLevelMessage = true;
                CustomDisplayBlockLevelMessage =false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag014(),getTAG012()));            
                return null;    
            }
            if (selectedLines.size()== 1){
                for(i = 0; i< serviceMaxStandardObjects.size(); i++ ){
                    if (serviceMaxStandardObjects.get(i).SVMXC__Select__c==true)
                        {
                             mapID = serviceMaxStandardObjects.get(i).SVMXC__MapID__c;
                             pid =  serviceMaxStandardObjects.get(i).Id;  
                        }
                }
                     if(svmxSettingList.containsKey('SET001') == true)                   
                     pgName = svmxSettingList.get('SET001');
                    
                     if(svmxSettingList.containsKey('SET002') == true)                  
                     retURL = svmxSettingList.get('SET002');
                    
                    
                                     
                    String urlToLaunch = pgName + '?&sMode=sClone&objMapId='+pid;
                    PageReference hoPage = new PageReference(urlToLaunch);   
                    hoPage.setRedirect(true);
                    return hoPage; 
                    
                    
                           
            }
        
        return null;
    }
    
    
 //====================================New Function===============
 public PageReference NewButton(){
                    String pgName ;
                    String retURL; 
                    if(svmxSettingList.containsKey('SET001') == true)                   
                     pgName = svmxSettingList.get('SET001');
                    
                     if(svmxSettingList.containsKey('SET002') == true)                  
                     retURL = svmxSettingList.get('SET002');
                    
                    
                    
                    String urlToLaunch =  pgName + '?&mid=null&sMode=sNew&objMapId=null';
                    PageReference hoPage = new PageReference(urlToLaunch);   
                    hoPage.setRedirect(true);
                    return hoPage; 
               
      
        
    }
    //=======================================Edit Funtion==============================================
    public PageReference EditButton(){
           List<Integer> selectedLines = new List<Integer>();
         Integer i;  
        String mapID=null;
        String pgName;
         String pid=null; 
         String retURL;    
         for (i=0;i<ServiceMaxCustomObjects.size();i++)
            {
            if (ServiceMaxCustomObjects.get(i).SVMXC__Select__c == true)
                {
                        selectedLines.add(i);
                }
            }
            
            system.debug(selectedLines.size() + '-------' );
            if (selectedLines.size()!= 1)
            {
                DisplayBlockLevelMessage = false;
                CustomDisplayBlockLevelMessage =true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag014(),getTAG012()));            
                return null;    
            }
            if (selectedLines.size()== 1){
                for(i = 0; i< ServiceMaxCustomObjects.size(); i++ ){
                    if (ServiceMaxCustomObjects.get(i).SVMXC__Select__c==true)
                        {
                             mapID = ServiceMaxCustomObjects.get(i).SVMXC__MapID__c;
                             pid =  ServiceMaxCustomObjects.get(i).Id;  
                        }
                }
                    if(svmxSettingList.containsKey('SET001') == true)                   
                     pgName = svmxSettingList.get('SET001');
                     
                    
                    String urlToLaunch =  pgName + '?&sMode=sEdit&objMapId='+pid;
                    PageReference hoPage = new PageReference(urlToLaunch);   
                    hoPage.setRedirect(true);
                    return hoPage; 
                    
                    
                           
            }
        
        return null;


        
    }
    //=====================================Clone Function==============================================
    public PageReference CloneButton(){
              List<Integer> selectedLines = new List<Integer>();
         Integer i;  
        String mapID=null;
        String pid=null; 
        String pgName ;  
        String retURL ; 
         for (i=0;i<ServiceMaxCustomObjects.size();i++)
            {
            if (ServiceMaxCustomObjects.get(i).SVMXC__Select__c == true)
                {
                        selectedLines.add(i);
                }
            }
            
            system.debug(selectedLines.size() + '-------' );
            if (selectedLines.size()!= 1)
            {
                 DisplayBlockLevelMessage = false;
                 CustomDisplayBlockLevelMessage =true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag014(),getTAG012()));            
                return null;    
            }
            if (selectedLines.size()== 1){
                for(i = 0; i< ServiceMaxCustomObjects.size(); i++ ){
                    if (ServiceMaxCustomObjects.get(i).SVMXC__Select__c==true)
                        {
                             mapID = ServiceMaxCustomObjects.get(i).SVMXC__MapID__c;
                             pid =  ServiceMaxCustomObjects.get(i).Id;  
                        }
                }
                    if(svmxSettingList.containsKey('SET001') == true)                   
                     pgName = svmxSettingList.get('SET001');
                   
                     if(svmxSettingList.containsKey('SET002') == true)                  
                    retURL = svmxSettingList.get('SET002');
                   
                    
                    
                    String urlToLaunch =  pgName + '?&sMode=sClone&objMapId='+pid;
                    PageReference hoPage = new PageReference(urlToLaunch);   
                    hoPage.setRedirect(true);
                    return hoPage; 
                    
                
                           
            }
        
        return null;
         
    } 


   
   //======================================== Delete===================================================//
   
     public PageReference RemoveCustomObjectMapping(){
           List<SVMXC__ServiceMax_Processes__c>  deleteCustomObjects = new List<SVMXC__ServiceMax_Processes__c>();  
           List<SVMXC__ServiceMax_Processes__c>  unDeleteCustomObjects = new List<SVMXC__ServiceMax_Processes__c>();  
           List<SVMXC__ServiceMax_Config_Data__c> deleteConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();     
         List<ID> customObjectsIDs=new List<ID>();
         for (Integer i=0;i<ServiceMaxCustomObjects.size();i++)
            {
            if (ServiceMaxCustomObjects.get(i).SVMXC__Select__c == true)
                    deleteCustomObjects.add(ServiceMaxCustomObjects.get(i));
            else unDeleteCustomObjects.add(ServiceMaxCustomObjects.get(i));
            }
        if (deleteCustomObjects.size() == 0)
            {
             DisplayBlockLevelMessage = false;
             CustomDisplayBlockLevelMessage =true;
             ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag014(), getTAG012()));            
             return null;    
            }
         
          if(deleteCustomObjects.size()>0)
          {
            for(SVMXC__ServiceMax_Processes__c cOList : deleteCustomObjects){
               customObjectsIDs.add(cOList.Id);
            } 
            /*Commented as part of Security Scanner issue fix
            String idStr = SVMX_getCommaSepratedStr(customObjectsIDs);// 
            String  soqlStr = '  SELECT Id, Name FROM SVMXC__ServiceMax_Config_Data__c where Id in('+ idStr +')';  
            deleteConfigData = Database.query(soqlStr);*/
            
            deleteConfigData = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c where Id IN: customObjectsIDs]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(deleteConfigData.size()>0)
            {
               // System.debug('configData to delete'+deleteConfigData);
                //delete deleteConfigData;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete deleteConfigData; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    DisplayBlockLevelMessage = false;
                    CustomDisplayBlockLevelMessage =true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, System.label.COMM001_TAG142));
                    return null;
                }
            }   
              //  System.debug('ObjectsMapping to delete'+deleteCustomObjects);
                //delete deleteCustomObjects;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete deleteCustomObjects; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    DisplayBlockLevelMessage = false;
                    CustomDisplayBlockLevelMessage =true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, System.label.COMM001_TAG142));
                    return null;
                }
                DisplayBlockLevelMessage = false;
                CustomDisplayBlockLevelMessage =true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG009(),getTAG011()));
          }
          ServiceMaxCustomObjects = unDeleteCustomObjects;
        return null;
        }      
        
     //==============================================================isMultiSelected========
     public Boolean isMultiSelected(List<SVMXC__ServiceMax_Processes__c> listOfRecs){
        Integer i;  
        List<SVMXC__ServiceMax_Processes__c> selectedRecords=new List<SVMXC__ServiceMax_Processes__c>() ;
        boolean warning=false;
            for(SVMXC__ServiceMax_Processes__c recToChk : listOfRecs){
                if(recToChk.Select__c == true ) {selectedRecords.add(recToChk);}
          }
          if(selectedRecords.size() == 1)
                warning =true;
                return warning;
    }
    /*******************************************************************************************************************
Method used to display/hide pageBlock Table column headings     
*******************************************************************************************************************/   
    public Boolean getDisplayTableColumns() {       
        if (ServiceMaxCustomObjects.size()==0)
            {
            //CheckAllLines = false;
            return false;
            }
        else
            return true;        
    }

    
/*******************************************************************************************************************
 Method to Return back to Home Page
*******************************************************************************************************************/  
   public PageReference BackToHomePage(){
        //String url = svmxSettingList.get('SET001');
        // PageReference hoPage = new PageReference('/apex/CONF_SetupHome');
        //hoPage.setRedirect(true);
        //return hoPage;
        String retURL = '/';
        if(svmxSettingList.containsKey('SET002') == true)                  
        retURL = svmxSettingList.get('SET002');       
        PageReference HomePage = new PageReference(retURL);
        HomePage.setRedirect(true);
        return HomePage;  
    
    }

     

    //======================================== Set true to display blocklevel messge ===================================================//
public Boolean DisplayBlockLevelMessage = false;
public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; } 

public Boolean customDisplayBlockLevelMessage = false;
public Boolean getCustomDisplayBlockLevelMessage(){ return customDisplayBlockLevelMessage; } 

    public String getTAG001() {  return System.Label.CONF011_TAG001; }//title for the Standard Object mapping
    public String getTAG002() {return System.Label.CONF011_TAG002;}//title for the view button
    public String getTAG003() {return System.Label.CONF011_TAG003;} //title for the Clone
     public String getTAG004() {return System.Label.CONF011_TAG004;}//title for Standard Object mapping Help
        public String getTAG005() {return System.Label.CONF011_TAG005;}//title for Custom Object mapping
        public String getTAG006() {return System.Label.CONF011_TAG006;}//New Button
        public String getTAG007() {return System.Label.CONF011_TAG007;}//Edit Button
        public String getTAG008() {return System.Label.CONF011_TAG008;}//Clone Button
        public String getTAG009() {return System.Label.CONF011_TAG009;}//Delete Button
        public String getTAG011(){ return System.Label.CONF011_TAG011;}//Record Delete Success
        public String getTAG012(){ return System.Label.CONF011_TAG012;} //Pls Sel one Obj
        public String getTAG013(){ return System.Label.CONF011_TAG013;} //Back to Home Page    
        public String getTAG014() {return System.Label.CONF011_TAG014;}//Invalid Data:
        
        //Neeraj(Feb-7th-2012): Added new tags to resolve translation issue.
        public String getTAG015() {return System.Label.CONF011_TAG015;}//Map ID
        public String getTAG016() {return System.Label.CONF011_TAG016;}//Name
        public String getTAG017() {return System.Label.CONF011_TAG017;}//Description
        
        public String getHLPURL() {return System.Label.CONF011_HLPURL;}//return System.Label.CONF011_HLPURL;}
  
    public String SVMX_getCommaSepratedStr(List<Id> strAr) {
            String retStr = '';
            for (String str : strAr) {
                if (retStr.length()>0) {
                    retStr += ',';
                }
                retStr += '\'' + str + '\'';
            }        
          //  System.debug('retStr: ' + retStr);
            return retStr;
        }    


}