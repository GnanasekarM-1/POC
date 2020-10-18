public with sharing class DCON_DispatchConsole {
    
    //------------------------NPS related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    public string getUserTimezone(){
        return UserInfo.getTimeZone().getID();
    }
    //--------------------------------------
    public String currentSessionId{get;set;} //Added for 046603
    String GMapAPI;
    String clientId;
    public String isOptimaxLicenseEnabled1 = 'false';
    public String strLoadEnglishFont = 'True';
    public String strDefaultStatus = 'All';
    public String getstrLoadEnglishFont(){return strLoadEnglishFont;}
    public String getstrDefaultStatus(){return strDefaultStatus;}
    public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('COMM001');
    public map<String,String> mapDCONSetting = commSettings.SVMX_getSettingList('DCON001');
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
    public DCON_DispatchConsole(){
        if(mapDCONSetting.containskey('SET063') && mapDCONSetting.get('SET063') != null)
            strLoadEnglishFont = mapDCONSetting.get('SET063');
        if(mapDCONSetting.containskey('SET007') && mapDCONSetting.get('SET007') != null)
            strDefaultStatus = mapDCONSetting.get('SET007');
        //Added for 046603
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
        
        //End for 046603
    }
    
    public String getMySessionId() {
        return UserInfo.getSessionId();
    }
    
    public String getGMapAPI(){
        return (svmxSettingList != null && svmxSettingList.containsKey('GBL001'))?svmxSettingList.get('GBL001') : 'ABQIAAAAB0wwxr_S8iKOQA_rHFtvlhQrroEcTVXxNCBMYghN-z6V4Vps5BRsJnPQt8nVzwKal0A9wognXYZwLQ';
    }
    
    public String getclientId(){
        return (svmxSettingList != null && svmxSettingList.containsKey('GBL011'))?svmxSettingList.get('GBL011') : 'gme-servicemaxinc';
    }
    
    public String getworkorderId(){
        String wid = System.currentPageReference().getParameters().get('wid');
         if(wid == null){
          wid ='';
        }
        
        return String.escapeSingleQuotes(wid);
    }
    public String getuserxml()
    {
        String stringxml=DCON_Configuration_WS.DCON_Retrieve_User_Settings_WS(UserInfo.getUserId());
        String loglvl='INFO';
        dom.Document doc = new dom.Document();
        doc.load(stringxml);
        dom.Xmlnode rootElement = doc.getRootElement();
        for(Dom.XMLNode child : rootElement.getChildElements()) 
        {
          if( (child.getAttribute('id', null)) == 'technicianSettings' )
          loglvl=child.getAttributeValue('loglevel', null);
         
        }
        return loglvl;

        
    }
    
    public String getuserxml1()
    {
        String stringxml=DCON_Configuration_WS.DCON_Retrieve_User_Settings_WS(UserInfo.getUserId());
        Map<String,String> woSettings = new map<String,String>();
        dom.Document doc = new dom.Document();
        doc.load(stringxml);
        dom.Xmlnode rootElement = doc.getRootElement();
        for(Dom.XMLNode child : rootElement.getChildElements()) 
        {
          if( (child.getAttribute('id', null)) == 'workOrderSettings' )
          {
            woSettings.put('sortColumn',child.getAttributeValue('sortColumn', null));
            woSettings.put('sortOrder',child.getAttributeValue('sortOrder', null));
            woSettings.put('defaultView',child.getAttributeValue('defaultView', null));
    
          }
        }
        return JSON.serialize(woSettings);

        
    }
    //039656
     public String getEnableGoogleMapApi()
    {
        String stringxml=DCON_Configuration_WS.DCON_Retrieve_User_Settings_WS(UserInfo.getUserId());
        dom.Document doc = new dom.Document();
        String googleAPI;
        doc.load(stringxml);
        dom.Xmlnode rootElement = doc.getRootElement();
        for(Dom.XMLNode child : rootElement.getChildElements()) 
        {
          if( (child.getAttribute('id', null)) == 'technicianSettings' )
          googleAPI=child.getAttributeValue('enableGoogleMapApi', null);
         
        }
        if(googleAPI == null && String.isBlank(googleAPI))
        {   
            googleAPI = 'true';
        }   
        System.debug('googleAPI:'+googleAPI);
        return googleAPI;
       
    }
    //returns true if the Org has Optimax License
    public String getOptimaxLicenseEnabled1()
    {
        String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
        if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO'))
        {
            isOptimaxLicenseEnabled1 = 'true';  
        }
        return isOptimaxLicenseEnabled1;
    }
    
    public String getSET069()
    {
        if(mapDCONSetting.containskey('SET069') && mapDCONSetting.get('SET069') != null)
            return mapDCONSetting.get('SET069');
        else
            return null;
    }
    
    //Based on this setting map library will be loaded
    public String getSET071()
    {
        if(mapDCONSetting.containskey('SET071') && mapDCONSetting.get('SET071') != null)
            return mapDCONSetting.get('SET071');
        else
            return null;
    }
    
    public String getworkorderNo(){
        String wid = System.currentPageReference().getParameters().get('wno');
         if(wid == null){
          wid ='';
        }
        
        return String.escapeSingleQuotes(wid);
    }

    public String getUserInfodat(){
    try{
        User u = [Select Id from User where Id=:UserInfo.getUserId() Limit 1];
        return u.id;
    }
    catch(Exception ex)
    {
        return null;
    }
    
    //PageReference pageRef = new PageReference('/');
    //return null;
    }
    public String getTAG026() {return System.Label.DCON001_TAG026;} //Loading Display Tags   
    public String getTAG028() {return System.Label.DCON001_TAG028;} //Loading user settings    
    public String getTAG029() {return System.Label.DCON001_TAG029;} //Loading Configuration   
    public String getTAG030() {return System.Label.DCON001_TAG030;} //Loading Work Orders    
    public String getTAG031() {return System.Label.DCON001_TAG031;} //Loading Teams and Territories    
    public String getTAG032() {return System.Label.DCON001_TAG032;} //Loading Technicians    
    public String getTAG033() {return System.Label.DCON001_TAG033;} //Loading Events
    public String getTAG245() {return System.Label.DCON001_TAG245;} //Loading...
    public String getTAG246() {return System.Label.DCON001_TAG246;} //Done
    public String getTAG247() {return System.Label.DCON001_TAG247;} //Fail
    public String getTAG252() {return System.Label.DCON001_TAG252;} //Log Information
    public String getTAG253() {return System.Label.DCON001_TAG253;} //Copy to Clipboard
    public String getTAG464() {return System.Label.DCON001_TAG464;} //ServiceMax Dispatch

}