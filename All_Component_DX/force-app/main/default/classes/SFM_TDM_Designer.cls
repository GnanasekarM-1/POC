public class SFM_TDM_Designer {
   String GMapAPI;
   String clientId;
   public String returnURL= '';
   public String partnerServerURL= 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/';
   //public String strAPIVersion = '19';
   //Changed API version to 39 for the defect BAC-3746
   public String strAPIVersion = '39';
   public String strPrivate = '';
   public String strProcessID = '';
   public String strDefaultSortingColumn = '5'; 
   public Boolean isEnableAPITab = false;
   public Boolean isEnableChecklist = false;
   public Boolean isStandAloneChecklist = false;
   public Boolean enableChecklistTitle = false; //Added for BAC-4764
   public Boolean isChecklistDisabled{get;set;} //Added for BAC-5181
   public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
   public map<String, String> mapSettings = commSettings.SVMX_getSettingList('SFM001');
   public Map<String, String> mapGlobalSettingValues = commSettings.SVMX_getSettingList('GLOB001');
   public Boolean isEnableFileProperties = false; //Added to check Salesforce file global setting --BAC-3573
   
    public String getreturnURL() {
        //Added for the story BAC-4797
        if(UserInfo.getUiThemeDisplayed()=='Theme4d'|| UserInfo.getUiThemeDisplayed()=='Theme4u'){
            returnURL = '/lightning/n/SVMXC__ServiceMax_Setup';
        }
           
        return returnURL;
    }
   /*public String getretURL(){
    //return '/home/home.jsp';
    return retURL;
  }*/
   //public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
   //public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('COMM001');
   public Map<String, String> PageHeaderMap  = new Map<String, String>();
   
  public SFM_TDM_Designer(){
    system.debug('amar'+ApexPages.currentPage().getUrl());
    PageHeaderMap  = ApexPages.currentPage().getParameters();
    if(mapSettings.containsKey('SET002') && mapSettings.get('SET002') != null)
        strAPIVersion = mapSettings.get('SET002');
    partnerServerURL += strAPIVersion+'/'+Userinfo.getOrganizationId();
    if(mapSettings.containsKey('SET003') && mapSettings.get('SET003') != null)
        strDefaultSortingColumn = mapSettings.get('SET003');
    if(mapSettings.containsKey('SET004') && mapSettings.get('SET004') != null)
        isEnableAPITab = Boolean.valueof(mapSettings.get('SET004'));
    if(mapGlobalSettingValues.containsKey('GBL029') && mapGlobalSettingValues.get('GBL029') != null)
        isEnableChecklist = Boolean.valueof(mapGlobalSettingValues.get('GBL029'));
    if(mapGlobalSettingValues.containsKey('GBL037') && mapGlobalSettingValues.get('GBL037') != null)
        isEnableFileProperties = Boolean.valueof(mapGlobalSettingValues.get('GBL037')); //Added to check Salesforce file global setting --BAC-3573
    
    if(PageHeaderMap.size()>0)
      {
        if(PageHeaderMap.containskey('SVMX_retURL'))
                returnURL=  PageHeaderMap.get('SVMX_retURL');
        if(pageHeaderMap.containskey('SVMX_ShowPrivate'))        
                strPrivate = pageHeaderMap.get('SVMX_ShowPrivate');
        if(pageHeaderMap.containskey('processID'))        
                strProcessID = pageHeaderMap.get('processID');
        if(PageHeaderMap.containskey('isStandAloneChecklist'))
                isStandAloneChecklist = true;
        if(PageHeaderMap.containskey('enableChecklistTitle')) //Added for BAC-4764
                enableChecklistTitle = true;
        if(PageHeaderMap.containskey('isChecklistDisabled') && pageHeaderMap.get('isChecklistDisabled').equalsIgnoreCase('true')) //Added for BAC-4764
            {
                isChecklistDisabled = true; //Added for BAC-5181
                isEnableChecklist = false; 
            }
      }
  }
  
  public String getMySessionId() {
   return UserInfo.getSessionId();
  }
  public String getpartnerServerURL(){ system.debug('partnerServerURL'+partnerServerURL);return partnerServerURL;}
  public String getShowPrivate(){return strPrivate;}
  public String getstrDefaultSortingColumn(){return strDefaultSortingColumn;}
  public void setShowPrivate(string strPrivate) {this.strPrivate = strPrivate;}
  public String getuserAuthTag(){return system.label.SFM001_TAG088;}
  public String getloadingTag(){return system.label.SFM001_TAG102;}
  public String getloadingProcTag(){
    //Added if check for the story BAC-3774
    if(isStandAloneChecklist){
        return system.label.SFM001_TAG618;
    }
    else{
        return system.label.SFM001_TAG090;
    }
  }
  public String getwelcomeTag(){
    //Added if check for the story BAC-3774
    if(isStandAloneChecklist){
        return System.label.SFM001_TAG617;
    }
    else{
        return System.label.SFM001_TAG021;
    }
  } 
  public Boolean getisEnableFileProperties(){return isEnableFileProperties;} //Added to check Salesforce file global setting --BAC-3573
  public Boolean getisEnableAPITab(){return isEnableAPITab;}
  public Boolean getisEnableChecklist(){return isEnableChecklist;}
  public Boolean getisStandAloneChecklist(){return isStandAloneChecklist;}
  public Boolean getenableChecklistTitle(){return enableChecklistTitle;} //Added for BAC-4764
  public String getProcessID(){return strProcessID;}
  public void setProcessID(string strProcessID) {this.strProcessID = strProcessID;}
}