public with sharing class CONF_InventoryProcesses 
{
    // Global Variables Declaration...
    public List<SVMXC__ServiceMax_Processes__c> stdProcesses = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> custProcesses = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> DelProcesses = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> delconfigdata = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    public Boolean error = false;     
    public String SId; 
    public Boolean DisplayBlock1Message = false;
    public Boolean DisplayBlock2Message = false;
    public Integer CustSize;
    public Integer StdSize;
    public string recordtype = 'Inventory Process';
    public string CustSOQLHeader;
    
    SVMXC.COMM_Utils util = new SVMXC.COMM_Utils();
    transient SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('CONF009');
    //SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('CONF009');
    public Map<String, SObjectField> fieldMap = new Map<String, SObjectField>();
    transient public List<String> fieldList = new List<String>();      
    public String fieldNames; 

    public Boolean isDisplayStandardSec=true;
    public Boolean getisDisplayStandardSec(){ return isDisplayStandardSec;}
    public String customSecLabel=System.Label.CONF009_TAG013;

     //Constructor
   
    public CONF_InventoryProcesses()
    {  
        Schema.DescribeSObjectResult dsoResult = SVMXC__ServiceMax_Processes__c.sObjectType.getDescribe();
        fieldMap = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.fields.getMap();
        fieldList = util.SVMX_getFieldList(fieldMap,true);
        fieldNames = util.SVMX_getFieldNamesFromList(fieldList);
       
        string StdSOQLHeader;
        StdSOQLHeader = ' select ' + fieldNames + ' FROM  SVMXC__ServiceMax_Processes__c where recordtype.Name =\''+recordtype+'\'';
        StdSOQLHeader = StdSOQLHeader + 'and SVMXC__IsStandard__c = True  order by SVMXC__ProcessID__c';
        stdProcesses = Database.query(StdSOQLHeader);
      
        CustSOQLHeader = ' select ' + fieldNames + ' FROM  SVMXC__ServiceMax_Processes__c where recordtype.Name =\''+recordtype+'\'';
        CustSOQLHeader = CustSOQLHeader + 'and SVMXC__IsStandard__c = False  order by SVMXC__ProcessID__c';
        
        if(stdProcesses.size() == 0)
        {
                isDisplayStandardSec=false;
                customSecLabel=System.Label.CONF009_TAG024;
                //DisplayBlock1Message = True;
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011()));                    
        }else
        {
                isDisplayStandardSec=true;
                customSecLabel=System.Label.CONF009_TAG013;
        }
    }
  
   // Validation for displaying Error Messages..
   public Boolean stdValidata()
    {
        
        StdSize = stdProcesses.size();
        List<Integer> stdselLines = new List<Integer>();
        for(Integer j = 0; j < StdSize; j++)
        {
            if(stdProcesses.get(j).SVMXC__Select__c == true)
            {
                stdselLines.add(j);
                SId = stdProcesses.get(j).Id;
            }
        }
            if(stdselLines.size()!= 1)
            {
                error = true;
            }
        return error;
    }
     public Boolean custValidata()
    {
        CustSize = custProcesses.size();
        List<Integer> custselLines = new List<Integer>();
        for(Integer i = 0; i < CustSize; i++)
        {
            if(custProcesses.get(i).SVMXC__Select__c == true)
            {
                custselLines.add(i);
                SId = custProcesses.get(i).Id;
            }
        }
         if(custselLines.size()!= 1)
         {
                error = true;
         }
        return error;
    }
  
  // Getter & Setter Methods
    public list<SVMXC__ServiceMax_Processes__c> getstdProcesses() {return this.stdProcesses;}  
    public list<SVMXC__ServiceMax_Processes__c> getcustProcesses() { custProcesses = Database.query(CustSOQLHeader); return this.custProcesses;}  
    public Boolean getDisplayBlock1Message(){return DisplayBlock1Message;}
    public Boolean getDisplayBlock2Message(){return DisplayBlock2Message;}
// Getter Methods for Tags..
   
    public String getHLPURL() {return System.Label.CONF009_HLPURL;} //HLPURL
    public String getTAG001() {return System.Label.CONF009_TAG001;}//Standard Inventory Processes
    public String getTAG002() {return System.Label.CONF009_TAG002;}//Inventory Processes Help
    public String getTAG003() {return System.Label.CONF009_TAG003;}// New
    public String getTAG004() {return System.Label.CONF009_TAG004;}//Edit
    public String getTAG005() {return System.Label.CONF009_TAG005;}//Clone
    public String getTAG006() {return System.Label.CONF009_TAG006;}//Back To Home
    public String getTAG007() {return System.Label.CONF009_TAG007;}//Invalid Data
    public String getTAG008() {return System.Label.CONF009_TAG008;}//You should not select CheckBox while creating a new Inventory Process
    public String getTAG009() {return System.Label.CONF009_TAG009;}//You should not select multiple CheckBox while editing the Inventory Process
    public String getTAG010() {return System.Label.CONF009_TAG010;}//You should not select multiple CheckBox while cloning the Inventory Process
    public String getTAG011() {return System.Label.CONF009_TAG011;}//No Inventory Process are there Contact ServiceMax Admin
    public String getTAG012() {return System.Label.CONF009_TAG012;}//Delete
    public String getTAG013() {return              customSecLabel;}//'Custom Inventory Processes' or 'Inventory Processes'
    public String getTAG014() {return System.Label.CONF009_TAG014;}//Delete Successfully
    public String getTAG015() {return System.Label.CONF009_TAG015;}//Proccessing......
    public String getTAG016() {return System.Label.CONF009_TAG016;}//View
    public String getTAG017() {return System.Label.CONF009_TAG017;}//You should have to select only one chechbox to view the Inventory Process
    public String getTAG018() {return System.Label.CONF009_TAG018;}//Select
    public String getTAG019() {return System.Label.CONF009_TAG019;}//
    public String getTAG020() {return System.Label.CONF009_TAG020;}//
    public String getTAG021() {return System.Label.CONF009_TAG021;}//
    public String getTAG022() {return System.Label.CONF009_TAG022;}//You should have to select atleast one chechbox to delete the Inventory Process
    public String getTAG023() {return System.Label.CONF009_TAG023;}//Are you sure want to delete the record(s)? 
    
    //Button events
    
    // For Creating a new Inventory Process..
   
    public pageReference SVMX_View()
    {
        DisplayBlock1Message = false;
        error = false;
        error = stdValidata();
        if(error == true)
        {
          DisplayBlock1Message = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG017()));
          return null;
        }
        String url = '/';
        if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
        PageReference ViewPage = new pageReference(url);
        ViewPage.setRedirect(true);
        ViewPage.getParameters().put('Pid',SId);  
        return ViewPage;
    }
   
    public pageReference SVMX_new()
    {
        DisplayBlock2Message = false;
        List<Integer> selline = new List<Integer>();
        for(Integer j = 0; j<custProcesses.size(); j++)
        {
            if(custProcesses.get(j).SVMXC__Select__c == true)
            {
                selline.add(j);
            }       
        }       
        if(selline.size()!= 0)
        {
         DisplayBlock2Message = true;
         ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG008())); 
         return null;
        }
        String url = '/';
        if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
        PageReference NewPage = new PageReference(url);
        NewPage.setRedirect(true);
        return NewPage;
    }   
    
    // For Editing an Exsisting Inventory Process..
    public pageReference SVMX_doedit()
    {
        DisplayBlock2Message = false;
        error = false;
        error = custValidata();
        if(error == true)
        {
          DisplayBlock2Message = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG009()));
          return null;
        }
        String url = '/';
        if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
        PageReference EditPage = new PageReference(url);
        EditPage.setRedirect(true);
        EditPage.getParameters().put('Pid',SId);  
       
        return EditPage;
    }   
    
    // For Cloning an Inventory Process..
    public pageReference SVMX_dostdClone()
    {
        DisplayBlock1Message = false;
        error = false;
        error = stdValidata();
        if(error == true)
        {
          DisplayBlock1Message = true;
          ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG010())); 
          return null;
        }
        String url = '/';
        if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
        PageReference ClonePage = new pageReference(url);
        ClonePage.setRedirect(true);
        ClonePage.getParameters().put('Cid',SId);  
        return ClonePage;
    }   
    public pageReference SVMX_docustClone()
    {
        DisplayBlock2Message = false;
        error = false;
        error = custValidata();
        if(error == true)
        {
          DisplayBlock2Message = true;
          ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG010())); 
          return null;
        }
        String url = '/';
        if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
        PageReference ClonePage = new PageReference(url);
        ClonePage.setRedirect(true);
        ClonePage.getParameters().put('Cid',SId);  
        
        return ClonePage;
    }   
    //Back to Home Page    
    public pageReference SVMX_GoHome()
    {
        String url = '/';
        //if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
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
    public pageReference SVMX_doDelete()
    {
        DelProcesses.clear();//Added by amar 11/12/09
        delconfigdata.clear();//Added by amar 11/12/09
        String obj = '';
        Set<String> setobj = new Set<String>();
        list<String> lstProcessId = new list<String>();
        set<Id> lstSubModuleId = new set<Id>();
        map<string,string> mapProcessIdName = new map<string,string>();
        boolean isAnyProcessDelete = false;
        //Retriving all the available Inventory Config records
        List<SVMXC__SM_Inventory_Config__c> listPartsConfig = new List<SVMXC__SM_Inventory_Config__c>();
        set<string> setInvProcessId = new set<string>();
        List<string> listInvProcessName = new List<string>();
        
        listPartsConfig = [Select id,SVMXC__SM_Content__c FROM SVMXC__SM_Inventory_Config__c where SVMXC__SM_ServiceMax_Profile__c != null]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        System.debug('listPartsConfig: '+listPartsConfig.size()+'  '+listPartsConfig);
        
        for(SVMXC__SM_Inventory_Config__c invtConfig:listPartsConfig)
        {
            INVT_SpareParts_Wrapper.SpareParts_Request  invtConfigwrp;
            invtConfigwrp = (INVT_SpareParts_Wrapper.SpareParts_Request  ) JSON.deserialize (invtConfig.SVMXC__SM_Content__c, INVT_SpareParts_Wrapper.SpareParts_Request .Class);
            
             if(invtConfigwrp != null && invtConfigwrp.locatepartsetup != null && !String.isBlank(invtConfigwrp.locatepartsetup.inventoryprocess) )
        
            setInvProcessId.add(invtConfigwrp.locatepartsetup.inventoryprocess);
        }
        System.debug('setInvProcessId: '+setInvProcessId);
        for(Integer i = 0; i<custProcesses.size(); i++)
        {
            if(custProcesses.get(i).SVMXC__Select__c == true)
            {
                obj = custProcesses.get(i).name;
                if(custProcesses.get(i).SVMXC__Submodule__c != null)
                    lstSubModuleId.add(custProcesses.get(i).SVMXC__Submodule__c);
                DelProcesses.add(custProcesses.get(i));
                //Check if the record which is getting deleted is associated with any  Inventory Config records. If so throw error 
                if(setInvProcessId.contains(custProcesses.get(i).SVMXC__ProcessID__c))
                    listInvProcessName.add(custProcesses.get(i).SVMXC__Name__c);
                isAnyProcessDelete = true;
                setobj.add(obj);
            }   
        }
        System.debug('listInvProcessName: '+listInvProcessName);
        if(!listInvProcessName.isEmpty())
        {
            isAnyProcessDelete = false;
            
        }
        if(isAnyProcessDelete)
        {
            
          if(lstSubModuleId != null && lstSubModuleId.size() > 0)
          {
              list<SVMXC__ServiceMax_Tags__c> lstTags = [Select Id FROM SVMXC__ServiceMax_Tags__c where SVMXC__Submodule__c IN :lstSubModuleId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
              map<string, SVMXC__ServiceMax_Processes__c> mapSettingDef = new map<string, SVMXC__ServiceMax_Processes__c>(); 
              map<string, SVMXC__ServiceMax_Processes__c> mapSubmodule = new map<string, SVMXC__ServiceMax_Processes__c>(); 
  
              if(lstTags != null && lstTags.size() > 0) {
                  if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Tags__c' ) ) {
                      
                      DisplayBlock2Message = true;
                      ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                      return null;
                  }
                  delete lstTags; //SDL-SVMX-DELETE-FLS-ENFORCED
              }
              
              mapSettingDef.putAll([SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE recordType.Name = 'Settings' AND SVMXC__Submodule__c IN :lstSubModuleId]);
              mapSubmodule.putAll([SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE recordType.Name = 'Submodule' AND Id IN :lstSubModuleId]);
              
              if(mapSettingDef != null && mapSettingDef.size() > 0)
              {
                  list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = [Select Id FROM SVMXC__ServiceMax_Config_Data__c where RecordType.Name ='Setting Value' And SVMXC__Setting_ID__c IN :mapSettingDef.keySet()]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA        
                  if(lstConfigData != null && lstConfigData.size() > 0) {
                      if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                          
                          DisplayBlock2Message = true;
                          ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                          return null;
                      }
                      delete lstConfigData; //SDL-SVMX-DELETE-FLS-ENFORCED
                  }
                  
                  if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {
                      
                      DisplayBlock2Message = true;
                      ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                      return null;
                  }
                  
                  delete mapSettingDef.values();
              }
              if(mapSubmodule != null && mapSubmodule.size() > 0) {
                  if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {
                      
                      DisplayBlock2Message = true;
                      ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                      return null;
                  }
                  delete mapSubmodule.values();
              }
                  
          }
          if(setobj.contains(null))
            setobj.remove(null);
        
        if(setobj != NULL && setobj.size() > 0)
            delconfigdata = [select id from SVMXC__ServiceMax_Config_Data__c where recordtype.Name = 'Expressions' and SVMXC__Inventory_Process__r.Name IN :setobj AND SVMXC__Inventory_Process__r.Name != NULL]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
          
            if(delconfigdata != null && delconfigdata.size() > 0) {
                if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    
                    DisplayBlock2Message = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
                delete delconfigdata; //SDL-SVMX-DELETE-FLS-ENFORCED
            }
            
          
            if(DelProcesses != null && DelProcesses.size() > 0) {
                if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {
                    
                    DisplayBlock2Message = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
                delete DelProcesses; //SDL-SVMX-DELETE-FLS-ENFORCED
            }
            
          
        DisplayBlock2Message = true;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG014()));   
      }
      else
      {
        DisplayBlock2Message = true;
        if(!listInvProcessName.isEmpty())
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.CONF009_TAG025+listInvProcessName));
        }
        else
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG022()));
      }
      return null;
    }
}