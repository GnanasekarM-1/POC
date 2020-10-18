public with sharing class DispatchConsole_DCH{

  public String UserTimeFormate { get; set; }
public String baseURL {get;set;}
public String nameSpace {get;set;}
public String isOptimaxLicenseEnabled1 {get;set;}
public String workOrderId {get;set;}
public String userId {get;set;}
//public String dateTimeFormat {get;set;}
public String UserTimeFormat {get;set;}
public String workOrderName {get;set;}
public String IsSidebar {get;set;}
public String UserDateFormat {get;set;}
public String isDependencyEnabled {get;set;}
public String currentSessionId{get;set;} 

    private Boolean checkCommunityUser(){
        Boolean retVal = false;
        //String userType = UserInfo.getUserType();
        //if(userType.equalsIgnoreCase('CSPLitePortal')){
        if(Site.getSiteId() != null){ //Added for 046603
            retVal = true;
        }else{
            retVal = false;
        }
        return retVal;
    }

    private void initSession() {
       if(checkCommunityUser()){
        Boolean isJWTTokenEnabled = false;
        String issDetails = '';
        String tokenEndpoint = '';
        String certificateName = '';
        String accessToken = '';
        
        COMM_Utils_ManageSettings commManageSetting = new COMM_Utils_ManageSettings();
        List<String> lstSettingIds = new List<String>();
        
        lstSettingIds.add('GLOB001_GBL039');
        lstSettingIds.add('GLOB001_GBL040');
        lstSettingIds.add('GLOB001_GBL041');
        lstSettingIds.add('GLOB001_GBL042');
        
        Map<String,String> mapAllSettings =  commManageSetting.SVMX_getGlobalSettingList(lstSettingIds);
            if(mapAllSettings.size() > 0){
                if(mapAllSettings.containskey('GLOB001_GBL039'))
                    isJWTTokenEnabled = Boolean.valueOf(mapAllSettings.get('GLOB001_GBL039'));
                if(mapAllSettings.containskey('GLOB001_GBL040'))
                    tokenEndpoint = mapAllSettings.get('GLOB001_GBL040');
                if(mapAllSettings.containskey('GLOB001_GBL041'))
                    certificateName = mapAllSettings.get('GLOB001_GBL041');
                if(mapAllSettings.containskey('GLOB001_GBL042'))
                    issDetails = mapAllSettings.get('GLOB001_GBL042');
            }

            if(isJWTTokenEnabled){

                String loginURL = '';
                List<String> loginUrlvar = tokenEndpoint.split('services');

                loginURL = loginUrlvar[0];
                Auth.JWT jwt = new Auth.JWT();
                jwt.setSub(UserInfo.getUserName()); 
                jwt.setAud(loginURL); 
                jwt.setIss(issDetails);
               
                //Create the object that signs the JWT bearer token
                Auth.JWS jws = new Auth.JWS(jwt, certificateName);
                try{
                    if(!Test.isRunningTest()){
                        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
                        accessToken = bearer.getAccessToken();
                    }
                    else{
                        accessToken ='Success';
                    }
                    currentSessionId = accessToken;
                }catch(Exception e){
                    System.debug('Exception in getting JWT token '+e);
                    currentSessionId = '';
                }
                
                 
            }else{
                currentSessionId = UserInfo.getSessionId();
            }
        }else{
            currentSessionId = UserInfo.getSessionId();
        }    
    }
    
public DispatchConsole_DCH() {
  initSession();
  
  Organization org = [select InstanceName, NamespacePrefix, Name, isSandbox from Organization];
  ApexClass cs = [select NamespacePrefix from ApexClass where Name = 'DispatchConsole_DCH'];
  baseURL = 'https://'+org.InstanceName+'.salesforce.com';
  nameSpace = cs.NamespacePrefix;
  //dateTimeFormat = UserInfo.dateTimeFormat;
  userId = UserInfo.getuserid();
  String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
  isOptimaxLicenseEnabled1 = 'false';
  if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO'))
  {
    isOptimaxLicenseEnabled1 = 'true';  
  }
 /* isDependencyEnabled = 'false';
  if(mapDCONSetting.containskey('SET005') && mapDCONSetting.get('SET005') != null)
    isDependencyEnabled = mapDCONSetting.get('SET005');*/
  String wid = System.currentPageReference().getParameters().get('woId');
  if(wid != null){
    workOrderId = wid;
    IsSidebar = 'WorkOrder';
    }
    else{
    IsSidebar ='SideBar';
    }
    
  String wName = System.currentPageReference().getParameters().get('wno');
  if(wName != null)
    workOrderName = wName ;
}

public string getUserTimezone(){
      return UserInfo.getTimeZone().getID();
  }

/*  public string getDependencyValue(){
    return isDependencyEnabled;
}*/

  public String getTAG028() {return System.Label.DCON001_TAG028;} //Loading user settings    
  public String getTAG029() {return System.Label.DCON001_TAG029;} //Loading Configuration   
  public String getTAG030() {return System.Label.DCON001_TAG030;} //Loading Work Orders    
  public String getTAG031() {return System.Label.DCON001_TAG031;} //Loading Teams and Territories    
  public String getTAG032() {return System.Label.DCON001_TAG032;} //Loading Technicians    
  public String getTAG033() {return System.Label.DCON001_TAG033;} //Loading Events
  
   public String getTimeFormat(){
  Map<String, String> mappedValues = new Map<String, String>(); //map for holding locale to datetime format
      mappedValues = MapValues(); //populate the map with all the locale specific datetime formats
      String user_locale = UserInfo.getLocale(); //grab the locale of the user
      UserTimeFormat = 'h:mm a'; //variable for the datetime format defaulted to the US format
      if (mappedValues.containsKey(user_locale)) { //if the map contains the correct datetime format
          UserTimeFormat = mappedValues.get(user_locale); //grab the datetime format for the locale
      }
      //UserTimeFormat = date_time.format(datetime_format); //create a string with the proper format
      return UserTimeFormat;
      
 }
 
 public String getDateFormat(){
  Map<String, String> mappedValues = new Map<String, String>(); //map for holding locale to datetime format
      mappedValues = MapValuesDate(); //populate the map with all the locale specific datetime formats
      String user_locale = UserInfo.getLocale(); //grab the locale of the user
      UserDateFormat = 'MM/DD/YYYY'; //variable for the datetime format defaulted to the US format
      if (mappedValues.containsKey(user_locale)) { //if the map contains the correct datetime format

          UserDateFormat = mappedValues.get(user_locale); //grab the datetime format for the locale
      }
      //UserTimeFormat = date_time.format(datetime_format); //create a string with the proper format
      return UserDateFormat;
      
 
 }
 
 public String getSET001()
    {
    
     SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
//public map<String,String> mapDCONSetting = commSettings.SVMX_getSettingList('DCON006');
  map<String,String> mapComm4Setting = commSettings.SVMX_getSettingList('COMM004');
        if(mapComm4Setting.containskey('SET001') && mapComm4Setting.get('SET001') != null)
            return mapComm4Setting.get('SET001');
        else
            return null;
    }
    
    public string getUserLocaleKey(){
    User u = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id = :UserInfo.getUserId()];
        return u.LanguageLocaleKey;
        //return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    
    public string getServicemaxVersion(){
        String j = String.valueof(System.requestVersion().major());
        String n = String.valueof(System.requestVersion().minor());
        String p = String.valueof(System.requestVersion().patch());
        String v = '';
        if(String.valueof(System.requestVersion().patch()) != null)
            v = j+'.'+n+'.'+p;
        else
            v = j+'.'+n;
        return v;
    }
    
    public String getUIThemeDescription() {
        String theme = UserInfo.getUiThemeDisplayed();
        if(theme == 'Theme1'){
            theme = 'Obsolete Salesforce ';
        }
       else if(theme == 'Theme2'){
         theme = 'Salesforce Classic 2005 user interface';
        }
        else if(theme == 'Theme3'){
         theme = 'Salesforce Classic 2010 user interface ';
        }
        else if(theme == 'Theme4d'){
         theme = 'Modern "Lightning Experience" Salesforce theme';
        }
        
        else if(theme == 'Theme4t'){
         theme = 'Salesforce mobile app';
        }
        else if(theme == 'Theme4u'){
         theme = 'Lightning Console';
        }
        else if(theme == 'PortalDefault'){
         theme = 'Salesforce Customer Portal';
        }
         else if(theme == 'Webstore'){
          theme = 'Salesforce AppExchange';
        }
        
        return theme;
    }
    
     public String getOrganizationType() { // Method to check of environement is Production ORG or not
        Organization org = [select IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
        return (org.IsSandbox == true) ? 'Sandbox' : 'Production';
    }
    
     public String getOrganizationName() { 
     
        //Organization org = [select Name from Organization where Id =:UserInfo.getOrganizationId()];
      //  return (org.Name );
       String name = UserInfo.getOrganizationName();
       return name;
    }
 
 private Map<String, String> MapValues() {
      Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
      locale_map.put('af_ZA', 'HH:mm');
      locale_map.put('ar_AE', 'h:mm A');
      locale_map.put('ar_BH', 'h:mm A');
      locale_map.put('ar_DZ', 'h:mm A');
      locale_map.put('ar_EG', 'h:mm A');
      locale_map.put('ar_IQ', 'h:mm A');
      locale_map.put('ar_JO', 'hh:mm A');
      locale_map.put('ar_KW', 'h:mm A');
      locale_map.put('ar_LB', 'hh:mm A');
      locale_map.put('ar_LY', 'h:mm A');
      locale_map.put('ar_MA', 'HH:mm');
      locale_map.put('ar_OM', 'h:mm A');
      locale_map.put('ar_QA', 'h:mm A');
      locale_map.put('ar_SA', 'hh:mm A');
      locale_map.put('ar_SD', 'h:mm A');
      locale_map.put('ar_SY', 'hh:mm A');
      locale_map.put('ar_TN', 'h:mm A');
      locale_map.put('ar_YE', 'h:mm A');
      locale_map.put('az_AZ', 'HH:mm');
      locale_map.put('be_BY', 'H.mm');
      locale_map.put('bg_BG', 'HH:mm');
      locale_map.put('bn_BD', 'h:mm A');
      locale_map.put('bn_IN', 'h:mm A');
      locale_map.put('bs_BA', 'HH:mm');
      locale_map.put('ca_ES', 'HH:mm');
      locale_map.put('ca_ES_EURO', 'HH:mm');
      locale_map.put('cs_CZ', 'H:mm');
      locale_map.put('cy_GB', 'HH:mm');
      locale_map.put('da_DK', 'HH:mm');
      locale_map.put('de_AT', 'HH:mm');
      locale_map.put('de_AT_EURO', 'HH:mm');
      locale_map.put('de_BE', 'HH:mm');
      locale_map.put('de_DE', ' HH:mm');
      locale_map.put('de_DE_EURO', 'HH:mm');
      locale_map.put('de_LU', 'HH:mm');
      locale_map.put('de_LU_EURO', 'HH:mm');
      locale_map.put('de_CH', 'HH:mm');
      locale_map.put('dz_BT', 'h:mm A');
      locale_map.put('el_GR', 'h:mm A');
      locale_map.put('en_AG', 'h:mm A');
      locale_map.put('en_AU', 'h:mm A');
      locale_map.put('en_BB', 'HH:mm');
      locale_map.put('en_BS', 'h:mm A');
      locale_map.put('en_BZ', 'HH:mm');
      locale_map.put('en_BM', 'HH:mm');
      locale_map.put('en_BW', 'HH:mm');
      locale_map.put('en_CA', 'h:mm A');
      locale_map.put('en_CM', 'HH:mm');
      locale_map.put('en_KY', 'h:mm A');
      locale_map.put('en_ER', 'h:mm A');
      locale_map.put('en_FK', 'HH:mm');
      locale_map.put('en_FJ', 'h:mm A');
      locale_map.put('en_GM', 'h:mm A');
      locale_map.put('en_GH', 'HH:mm');
      locale_map.put('en_GI', 'HH:mm');
      locale_map.put('en_GY', 'h:mm A');
      locale_map.put('en_HK', 'h:mm A');
      locale_map.put('en_IN', 'h:mm A');
      locale_map.put('en_ID', 'HH:mm');
      locale_map.put('en_IE', 'HH:mm');
      locale_map.put('en_IE_EURO', 'HH:mm');
      locale_map.put('en_JM', 'h:mm A');
      locale_map.put('en_KE', 'HH:mm');
      locale_map.put('en_LR', 'h:mm A');
      locale_map.put('en_MG', 'HH:mm');
      locale_map.put('en_MW', 'h:mm A');
      locale_map.put('en_MY', 'HH:mm');
      locale_map.put('en_MU', 'HH:mm');
      locale_map.put('en_NA', 'h:mm A');
      locale_map.put('en_NZ', 'h:mm A');
      locale_map.put('en_NG', 'HH:mm');
      locale_map.put('en_PK', 'h:mm A');
      locale_map.put('en_PG', 'h:mm A');
      locale_map.put('en_PH', 'h:mm A');
      locale_map.put('en_RW', 'HH:mm');
      locale_map.put('en_SH', 'HH:mm');
      locale_map.put('en_WS', 'h:mm A');
      locale_map.put('en_SC', 'HH:mm');
      locale_map.put('en_SL', 'h:mm A');
      locale_map.put('en_SG', 'HH:mm');
      locale_map.put('en_SX', 'HH:mm');
      locale_map.put('en_SB', 'h:mm A');
      locale_map.put('en_ZA', 'h:mm A');
      locale_map.put('en_SZ', 'h:mm A');
      locale_map.put('en_TZ', 'HH:mm');
      locale_map.put('en_TO', 'h:mm A');
      locale_map.put('en_TT', 'h:mm A');
      locale_map.put('en_UG', 'HH:mm');
      locale_map.put('en_GB', 'HH:mm');
      locale_map.put('en_US', 'h:mm A');
      locale_map.put('en_VU', 'h:mm A');
      locale_map.put('es_AR', 'HH:mm');
      locale_map.put('es_BO', 'hh:mm A');
      locale_map.put('es_CL', 'H:mm');
      locale_map.put('es_CO', 'hh:mm A');
      locale_map.put('es_CR', 'hh:mm A');
      locale_map.put('es_CU', 'HH:mm');
      locale_map.put('es_DO', 'hh:mm A');
      locale_map.put('es_EC', 'H:mm');
      locale_map.put('es_ES', 'H:mm');
      locale_map.put('es_ES_EURO', 'H:mm');
      locale_map.put('es_GT', 'hh:mm A');
      locale_map.put('es_HN', 'hh:mm A');
      locale_map.put('es_MX', 'hh:mm A');
      locale_map.put('es_NI', 'hh:mm A');
      locale_map.put('es_PA', 'hh:mm A');
      locale_map.put('es_PE', 'hh:mm A');
      locale_map.put('es_PR', 'hh:mm A');
      locale_map.put('es_PY', 'hh:mm A');
      locale_map.put('es_SV', 'hh:mm A');
      locale_map.put('es_US', 'h:mm A');
      locale_map.put('es_UY', 'hh:mm A');
      locale_map.put('es_VE', 'hh:mm A');
      locale_map.put('et_EE', 'H:mm');
      locale_map.put('eu_ES', 'HH:mm');
      locale_map.put('fa_IR', 'H:mm');
      locale_map.put('fi_FI', 'H:mm');
      locale_map.put('fi_FI_EURO', 'H:mm');
      locale_map.put('fr_BE', 'H:mm');
      locale_map.put('fr_CA', 'HH:mm');
      locale_map.put('fr_KM', 'HH:mm');
      locale_map.put('fr_FR', 'HH:mm');
      locale_map.put('fr_FR_EURO', 'HH:mm');
      locale_map.put('fr_GN', 'HH:mm');
      locale_map.put('fr_HT', 'HH:mm');
      locale_map.put('fr_LU', 'HH:mm');
      locale_map.put('fr_MR', 'h:mm A');
      locale_map.put('fr_MC', 'HH:mm');
      locale_map.put('fr_CH', 'HH:mm');
      locale_map.put('fr_WF', 'HH:mm');
      locale_map.put('ga_IE', 'HH:mm');
      locale_map.put('gu_IN', 'hh:mm A');
      locale_map.put('hi_IN', 'h:mm A');
      locale_map.put('hr_HR', 'HH:mm');
      locale_map.put('hu_HU', 'H:mm');
      locale_map.put('hy_AM', 'HH:mm');
      locale_map.put('in_ID', 'H:mm');
      locale_map.put('is_IS', 'HH:mm');
      locale_map.put('it_CH', 'HH:mm');
      locale_map.put('it_IT', 'H.mm');
      locale_map.put('iw_IL', 'HH:mm');
      locale_map.put('ja_JP', 'H:mm');
      locale_map.put('ka_GE', 'HH:mm');
      locale_map.put('kk_KZ', 'HH:mm');
      locale_map.put('km_KH', 'h:mm A');
      locale_map.put('kn_IN', 'hh:mm A');
      locale_map.put('ko_KP', 'A h:mm');
      locale_map.put('ko_KR', 'A h:mm');
      locale_map.put('ky_KG', 'HH:mm');
      locale_map.put('lb_LU', 'HH:mm');
      locale_map.put('lo_LA', 'H:mm');
      locale_map.put('lt_LT', 'HH.mm');
      locale_map.put('lu_CD', 'HH:mm');
      locale_map.put('lv_LV', 'HH:mm');
      locale_map.put('mk_MK', 'HH:mm');
      locale_map.put('ml_IN', 'h:mm A');
      locale_map.put('mr_IN', 'h:mm A');
      locale_map.put('ms_BN', 'h:mm A');
      locale_map.put('ms_MY', 'h:mm A');
      locale_map.put('mt_MT', 'HH:mm');
      locale_map.put('my_MM', 'H:mm');
      locale_map.put('ne_NP', 'HH:mm');
      locale_map.put('nl_AW', 'HH:mm');
      locale_map.put('nl_BE', 'H:mm');
      locale_map.put('nl_NL', 'H:mm');
      locale_map.put('nl_SR', 'HH:mm');
      locale_map.put('no_NO', 'HH:mm');
      locale_map.put('pl_PL', 'HH:mm');
      locale_map.put('ps_AF', 'H:mm');
      locale_map.put('pt_AO', 'HH:mm');
      locale_map.put('pt_BR', 'HH:mm');
      locale_map.put('pt_CV', 'HH:mm');
      locale_map.put('pt_MZ', 'HH:mm');
      locale_map.put('pt_PT', 'H:mm');
      locale_map.put('pt_ST', 'HH:mm');
      locale_map.put('rm_CH', 'HH:mm');
      locale_map.put('rn_BI', 'HH:mm');
      locale_map.put('ro_MD', 'HH:mm');
      locale_map.put('ro_RO', 'HH:mm');
      locale_map.put('ru_KZ', 'H:mm');
      locale_map.put('ru_RU', 'H:mm');
      locale_map.put('sh_BA', 'HH:mm');
      locale_map.put('sh_CS', 'HH:mm');
      locale_map.put('sh_ME', 'HH:mm');
      locale_map.put('sk_SK', 'H:mm');
      locale_map.put('sl_SI', 'H:mm');
      locale_map.put('so_DJ', 'h:mm A');
      locale_map.put('so_SO', 'h:mm A');
      locale_map.put('sr_BA', 'HH:mm');
      locale_map.put('sr_CS', 'HH.mm');
      locale_map.put('sr_RS', 'HH.mm');
      locale_map.put('sq_AL', 'h.mm.A');
      locale_map.put('sv_SE', 'HH:mm');
      locale_map.put('sw_KE', 'HH:mm');
      locale_map.put('ta_IN', 'A h:mm');
      locale_map.put('ta_LK', 'HH:mm');
      locale_map.put('te_IN', 'h:mm A');
      locale_map.put('tg_TJ', 'HH:mm');
      locale_map.put('th_TH', 'H:mm');
      locale_map.put('ti_ET', 'h:mm A');
      locale_map.put('tl_PH', 'h:mm A');
      locale_map.put('tr_TR', 'HH:mm');
      locale_map.put('uk_UA', 'H:mm');
      locale_map.put('ur_PK', 'h:mm A');
      locale_map.put('uz_LATN_UZ', 'HH:mm');
      locale_map.put('vi_VN', 'HH:mm');
      locale_map.put('yo_BJ', 'HH:mm');
      locale_map.put('xh_ZA', 'h:mm A');
      locale_map.put('zh_CN', 'A h:mm');
      locale_map.put('zh_CN_PINYIN', 'A h:mm');
      locale_map.put('zh_CN_STROKE', 'A h:mm');
      locale_map.put('zh_HK', 'A h:mm');
      locale_map.put('zh_HK_STROKE', 'A h:mm');
      locale_map.put('zh_MO', 'A h:mm');
      locale_map.put('zh_SG', 'A hh:mm');
      locale_map.put('zh_TW', 'A h:mm');
      locale_map.put('zh_TW_STROKE', 'A h:mm');
      locale_map.put('zu_ZA', 'HH:mm');

      locale_map.put('de', 'HH:mm');
      locale_map.put('ca', 'HH:mm');
      locale_map.put('cs', 'H:mm');
      locale_map.put('da', 'H:mm');
      locale_map.put('es', 'HH:mm');
      locale_map.put('fi', 'H:mm');
      locale_map.put('fr', 'HH:mm');
      locale_map.put('hu', 'HH:mm');
      locale_map.put('it', 'H.mm');
      locale_map.put('iw', 'HH:mm');
      locale_map.put('ja', 'H:mm');
      locale_map.put('ko', 'a h:mm');
      locale_map.put('nl', 'H:mm');
      locale_map.put('no', 'HH:mm');
      locale_map.put('pl', 'HH:mm');
      locale_map.put('pt', 'HH:mm');
      locale_map.put('ru', 'H:mm');
      locale_map.put('sv', 'HH:mm');
      locale_map.put('th', 'h:mm a');
      locale_map.put('tr', 'ah:mm');
      locale_map.put('zh', 'HH:mm');
      return locale_map; //return the map
  }
   private Map<String, String> MapValuesDate() {
      Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
      locale_map.put('af_ZA', 'YYYY-MM-DD');
      locale_map.put('ar_AE', 'D/M/YYYY');
      locale_map.put('ar_BH', 'D/M/YYYY');
      locale_map.put('ar_DZ', 'D/M/YYYY');
      locale_map.put('ar_EG', 'D/M/YYYY');
      locale_map.put('ar_IQ', 'D/M/YYYY');
      locale_map.put('ar_JO', 'DD/MM/YYYY');
      locale_map.put('ar_KW', 'D/M/YYYY');
      locale_map.put('ar_LB', 'DD/MM/YYYY');
      locale_map.put('ar_LY', 'D/M/YYYY');
      locale_map.put('ar_MA', 'D/M/YYYY');
      locale_map.put('ar_OM', 'D/M/YYYY');
      locale_map.put('ar_QA', 'D/M/YYYY');
      locale_map.put('ar_SA', 'DD/MM/YYYY');
      locale_map.put('ar_SD', 'D/M/YYYY');
      locale_map.put('ar_SY', 'DD/MM/YYYY');
      locale_map.put('ar_TN', 'D/M/YYYY');
      locale_map.put('ar_YE', 'D/M/YYYY');
      locale_map.put('az_AZ', 'DD.MM.YYYY');
      locale_map.put('be_BY', 'D.M.YYYY');
      locale_map.put('bg_BG', 'DD.MM.YYYY');
      locale_map.put('bn_BD', 'D/M/YYYY');
      locale_map.put('bn_IN', 'D/M/YYYY');
      locale_map.put('bs_BA', 'D.M.YYYY');
      locale_map.put('ca_ES', 'DD/MM/YYYY');
      locale_map.put('ca_ES_EURO', 'DD/MM/YYYY');
      locale_map.put('cs_CZ', 'DD.M.YYYY');
      locale_map.put('cy_GB', 'DD/MM/YYYY');
      locale_map.put('da_DK', 'DD-MM-YYYY');
      locale_map.put('de_AT', 'DD.MM.YYYY');
      locale_map.put('de_AT_EURO', 'DD.MM.YYYY');
      locale_map.put('de_BE', 'DD.MM.YYYY');
      locale_map.put('de_DE', 'DD.MM.YYYY');
      locale_map.put('de_DE_EURO', 'DD.MM.YYYY');
      locale_map.put('de_LU', 'DD.MM.YYYY');
      locale_map.put('de_LU_EURO', 'DD.MM.YYYY');
      locale_map.put('de_CH', 'DD.MM.YYYY');
      locale_map.put('dz_BT', 'YYYY-MM-DD');
      locale_map.put('el_GR', 'D/M/YYYY');
      locale_map.put('en_AG', 'DD/MM/YYYY,');
      locale_map.put('en_AU', 'D/MM/YYYY');
      locale_map.put('en_BB', 'DD/MM/YYYY');
      locale_map.put('en_BS', 'DD/MM/YYYY');
      locale_map.put('en_BZ', 'DD/MM/YYYY');
      locale_map.put('en_BM', 'DD/MM/YYYY');
      locale_map.put('en_BW', 'DD/MM/YYYY');
      locale_map.put('en_CA', 'DD/MM/YYYY');
      locale_map.put('en_CM', 'DD/MM/YYYY');
      locale_map.put('en_KY', 'DD/MM/YYYY');
      locale_map.put('en_ER', 'DD/MM/YYYY');
      locale_map.put('en_FK', 'DD/MM/YYYY');
      locale_map.put('en_FJ', 'DD/MM/YYYY');
      locale_map.put('en_GM', 'DD/MM/YYYY');
      locale_map.put('en_GH', 'DD/MM/YYYY');
      locale_map.put('en_GI', 'DD/MM/YYYY');
      locale_map.put('en_GY', 'DD/MM/YYYY');
      locale_map.put('en_HK', 'D/M/YYYY');
      locale_map.put('en_IN', 'DD/MM/YYYY');
      locale_map.put('en_ID', 'DD/MM/YYYY');
      locale_map.put('en_IE', 'DD/MM/YYYY');
      locale_map.put('en_IE_EURO', 'DD/MM/YYYY');
      locale_map.put('en_JM', 'DD/MM/YYYY');
      locale_map.put('en_KE', 'DD/MM/YYYY');
      locale_map.put('en_LR', 'DD/MM/YYYY');
      locale_map.put('en_MG', 'DD/MM/YYYY');
      locale_map.put('en_MW', 'DD/MM/YYYY');
      locale_map.put('en_MY', 'DD/MM/YYYY');
      locale_map.put('en_MU', 'DD/MM/YYYY');
      locale_map.put('en_NA', 'DD/MM/YYYY');
      locale_map.put('en_NZ', 'D/MM/YYYY');
      locale_map.put('en_NG', 'DD/MM/YYYY');
      locale_map.put('en_PK', 'DD/MM/YYYY');
      locale_map.put('en_PG', 'DD/MM/YYYY');
      locale_map.put('en_PH', 'M/D/YYYY');
      locale_map.put('en_RW', 'DD/MM/YYYY');
      locale_map.put('en_SH', 'DD/MM/YYYY');
      locale_map.put('en_WS', 'DD/MM/YYYY');
      locale_map.put('en_SC', 'DD/MM/YYYY');
      locale_map.put('en_SL', 'DD/MM/YYYY');
      locale_map.put('en_SG', 'DD/MM/YYYY');
      locale_map.put('en_SX', 'DD/MM/YYYY');
      locale_map.put('en_SB', 'DD/MM/YYYY');
      locale_map.put('en_ZA', 'YYYY/MM/DD');
      locale_map.put('en_SZ', 'DD/MM/YYYY');
      locale_map.put('en_TZ', 'DD/MM/YYYY');
      locale_map.put('en_TO', 'DD/MM/YYYY');
      locale_map.put('en_TT', 'DD/MM/YYYY');
      locale_map.put('en_UG', 'DD/MM/YYYY');
      locale_map.put('en_GB', 'DD/MM/YYYY');
      locale_map.put('en_US', 'M/D/YYYY');
      locale_map.put('en_VU', 'DD/MM/YYYY');
      locale_map.put('es_AR', 'DD/MM/YYYY');
      locale_map.put('es_BO', 'DD-MM-YYYY');
      locale_map.put('es_CL', 'DD-MM-YYYY');
      locale_map.put('es_CO', 'D/MM/YYYY');
      locale_map.put('es_CR', 'DD/MM/YYYY');
      locale_map.put('es_CU', 'D/M/YYYY');
      locale_map.put('es_DO', 'DD/MM/YYYY');
      locale_map.put('es_EC', 'DD/MM/YYYY');
      locale_map.put('es_ES', 'D/MM/YYYY');
      locale_map.put('es_ES_EURO', 'D/MM/YYYY');
      locale_map.put('es_GT', 'D/MM/YYYY');
      locale_map.put('es_HN', 'MM-DD-YYYY');
      locale_map.put('es_MX', 'D/MM/YYYY');
      locale_map.put('es_NI', 'MM-DD-YYYY');
      locale_map.put('es_PA', 'MM/DD/YYYY');
      locale_map.put('es_PE', 'DD/MM/YYYY');
      locale_map.put('es_PR', 'MM-DD-YYYY');
      locale_map.put('es_PY', 'DD/MM/YYYY');
      locale_map.put('es_SV', 'MM-DD-YYYY');
      locale_map.put('es_US', 'M/D/YYYY');
      locale_map.put('es_UY', 'DD/MM/YYYY');
      locale_map.put('es_VE', 'DD/MM/YYYY');
      locale_map.put('et_EE', 'D.MM.YYYY');
      locale_map.put('eu_ES', 'YYYY/M/D');
      locale_map.put('fa_IR', 'YYYY/M/D');
      locale_map.put('fi_FI', 'DD.M.YYYY');
      locale_map.put('fi_FI_EURO', 'DD.M.YYYY');
      locale_map.put('fr_BE', 'D/MM/YYYY');
      locale_map.put('fr_CA', 'YYYY-MM-DD');
      locale_map.put('fr_KM', 'DD/MM/YYYY');
      locale_map.put('fr_FR', 'DD/MM/YYYY');
      locale_map.put('fr_FR_EURO', 'DD/MM/YYYY');
      locale_map.put('fr_GN', 'DD/MM/YYYY');
      locale_map.put('fr_HT', 'DD/MM/YYYY');
      locale_map.put('fr_LU', 'DD/MM/YYYY');
      locale_map.put('fr_MR', 'DD/MM/YYYY');
      locale_map.put('fr_MC', 'DD/MM/YYYY');
      locale_map.put('fr_CH', 'DD.MM.YYYY');
      locale_map.put('fr_WF', 'DD/MM/YYYY');
      locale_map.put('ga_IE', 'DD/MM/YYYY');
      locale_map.put('gu_IN', 'D/M/YYYY');
      locale_map.put('hi_IN', 'D/M/YYYY');
      locale_map.put('hr_HR', 'DD.MM.YYYY');
      locale_map.put('hu_HU', 'YYYY.MM.DD');
      locale_map.put('hy_AM', 'DD.MM.YYYY');
      locale_map.put('in_ID', 'DD/MM/YYYY');
      locale_map.put('is_IS', 'DD.M.YYYY');
      locale_map.put('it_CH', 'DD.MM.YYYY');
      locale_map.put('it_IT', 'DD/MM/YYYY ');
      locale_map.put('iw_IL', 'DD/MM/YYYY');
      locale_map.put('ja_JP', 'YYYY/MM/DD');
      locale_map.put('ka_GE', 'DD.MM.YYYY');
      locale_map.put('kk_KZ', 'DD.MM.YYYY');
      locale_map.put('km_KH', 'D/M/YYYY');
      locale_map.put('kn_IN', 'D/M/YYYY');
      locale_map.put('ko_KP', 'YYYY.M.D');
      locale_map.put('ko_KR', 'YYYY.M.D');
      locale_map.put('ky_KG', 'D/M/YYYY');
      locale_map.put('lb_LU', 'DD.MM.YYYY');
      locale_map.put('lo_LA', 'D/M/YYYY');
      locale_map.put('lt_LT', 'YYYYY.M.D');
      locale_map.put('lu_CD', 'D/M/YYYY');
      locale_map.put('lv_LV', 'DD.MM.YYYY');
      locale_map.put('mk_MK', 'DD.M.YYYY');
      locale_map.put('ml_IN', 'D/M/YYYY');
      locale_map.put('mr_IN', 'D/M/YYYY');
      locale_map.put('ms_BN', 'D/MM/YYYY');
      locale_map.put('ms_MY', 'DD/MM/YYYY');
      locale_map.put('mt_MT', 'DD/MM/YYYY');
      locale_map.put('my_MM', 'DD-MM-YYYY');
      locale_map.put('ne_NP', 'YYYY/M/D');
      locale_map.put('nl_AW', 'DD-MM-YYYY');
      locale_map.put('nl_BE', 'D/MM/YYYY');
      locale_map.put('nl_NL', 'D-M-YYYY');
      locale_map.put('nl_SR', 'DD-MM-YYYY');
      locale_map.put('no_NO', 'DD.MM.YYYY');
      locale_map.put('pl_PL', 'DD.MM.YYYY');
      locale_map.put('ps_AF', 'YYYY/M/D');
      locale_map.put('pt_AO', 'DD/MM/YYYY');
      locale_map.put('pt_BR', 'DD/MM/YYYY');
      locale_map.put('pt_CV', 'DD/MM/YYYY');
      locale_map.put('pt_MZ', 'DD/MM/YYYY');
      locale_map.put('pt_PT', 'DD-MM-YYYY');
      locale_map.put('pt_ST', 'DD/MM/YYYY');
      locale_map.put('rm_CH', 'DD-MM-YYYY');
      locale_map.put('rn_BI', 'D/M/YYYY');
      locale_map.put('ro_MD', 'DD.MM.YYYY,');
      locale_map.put('ro_RO', 'DD.MM.YYYY');
      locale_map.put('ru_KZ', 'DD.MM.YYYY');
      locale_map.put('ru_RU', 'DD.MM.YYYY');
      locale_map.put('sh_BA', 'DD.MM.YYYY');
      locale_map.put('sh_CS', 'DD.MM.YYYY');
      locale_map.put('sh_ME', 'DD.MM.YYYY');
      locale_map.put('sk_SK', 'DD.M.YYYY');
      locale_map.put('sl_SI', 'DD.M.YYYY');
      locale_map.put('so_DJ', 'DD/MM/YYYY');
      locale_map.put('so_SO', 'DD/MM/YYYY');
      locale_map.put('sr_BA', 'YYYY-MM-DD');
      locale_map.put('sr_CS', 'DD.M.YYYY');
      locale_map.put('sr_RS', 'DD.M.YYYY');
      locale_map.put('sq_AL', 'YYYY-MM-DD');
      locale_map.put('sv_SE', 'YYYY-MM-DD');
      locale_map.put('sw_KE', 'DD/MM/YYYY');
      locale_map.put('ta_IN', 'D/M/YYYY');
      locale_map.put('ta_LK', 'D/M/YYYY');
      locale_map.put('te_IN', 'DD-MM-YYYY');
      locale_map.put('tg_TJ', 'DD/MM/YYYY');
      locale_map.put('th_TH', 'D/M/YYYY');
      locale_map.put('ti_ET', 'DD/MM/YYYY');
      locale_map.put('tl_PH', 'M/D/YYYY');
      locale_map.put('tr_TR', 'DD.MM.YYYY');
      locale_map.put('uk_UA', 'DD.MM.YYYY');
      locale_map.put('ur_PK', 'D/M/YYYY');
      locale_map.put('uz_LATN_UZ', 'DD/MM/YYYY');
      locale_map.put('vi_VN', 'DD/MM/YYYY');
      locale_map.put('yo_BJ', 'DD/MM/YYYY');
      locale_map.put('xh_ZA', 'M/D/YYYY');
      locale_map.put('zh_CN', 'YYYY-M-D');
      locale_map.put('zh_CN_PINYIN', 'YYYY/M/D');
      locale_map.put('zh_CN_STROKE', 'YYYY/M/D');
      locale_map.put('zh_HK', 'yyyy年M月d日');
      locale_map.put('zh_HK_STROKE', 'D/M/YYYY');
      locale_map.put('zh_MO', 'D/M/YYYY');
      locale_map.put('zh_SG', 'DD/MM/YYYY');
      locale_map.put('zh_TW', 'YYYY/M/D');
      locale_map.put('zh_TW_STROKE', 'YYYY/M/D');
      locale_map.put('zu_ZA', 'M/D/YYYY');

      locale_map.put('de', 'DD.MM.YYYY');
      locale_map.put('ca', 'DD/MM/YYYY');
      locale_map.put('cs', 'D.M.YYYY');
      locale_map.put('da', 'DD-MM-YYYY');
      locale_map.put('es', 'D/MM/YYYY');
      locale_map.put('fi', 'D.M.YYYY');
      locale_map.put('fr', 'DD/MM/YYYY');
      locale_map.put('hu', 'YYYY.MM.DD');
      locale_map.put('it', 'DD/MM/YYYY');
      locale_map.put('iw', 'DD/MM/YYYY');
      locale_map.put('ja', 'YYYY/MM/DD');
      locale_map.put('ko', 'YYYY. M. D');
      locale_map.put('nl', 'D-M-YYYY');
      locale_map.put('no', 'DD.MM.YYYY');
      locale_map.put('pl', 'DD.MM.YYYY');
      locale_map.put('pt', 'DD-MM-YYYY');
      locale_map.put('ru', 'DD.MM.YYYY');
      locale_map.put('sv', 'YYYY-MM-DD');
      locale_map.put('th', 'M/D/YYYY');
      locale_map.put('tr', 'DD.MM.YYYY');
      locale_map.put('zh', 'YYYY-M-D');

      return locale_map; //return the map
  }
 

}