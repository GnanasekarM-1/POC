public with sharing class COMM_Controller
{
    
    SVMXC.COMM_Utils_ManageSettings objSettings = new SVMXC.COMM_Utils_ManageSettings();
    map<String, String> objCOMMSetts = new map<String, String>();
    Boolean isSFMLightning = false;
    Boolean isLegacyDeliveryEnabled = false;
    
    public COMM_Controller(ApexPages.StandardController controller) 
    {
        try
        {
            objCOMMSetts = objSettings.SVMX_getSettingList('COMM003');
        }
        catch(Exception ex)
        {
            System.debug(logginglevel.Info, 'Stack Trace : ' + ex.getStackTraceString());
        }
    }
    
    public PageReference CreateActivity()
    {
        try
        {
            return RedirectTo('Activity_Master__c',(objCOMMSetts != null && objCOMMSetts.ContainsKey('SET001') && objCOMMSetts.get('SET001').length() > 0) ? objCOMMSetts.get('SET001') : 'SCON_CR_ActivitMaster');
        }catch(Exception ex)
        {
            System.debug(logginglevel.Info, 'Stack Trace : ' + ex.getStackTraceString());
            throw ex;
        }
    }
    
    public PageReference CreateServicePricebook()
    {
        return RedirectTo('Service_Pricebook__c',objCOMMSetts != null && objCOMMSetts.ContainsKey('SET002') && objCOMMSetts.get('SET002').length() > 0 ? objCOMMSetts.get('SET002') : 'SCON_CR_Pricebook');
    }
    
    public PageReference CreateService()
    {
        return RedirectTo('Service__c',objCOMMSetts != null && objCOMMSetts.ContainsKey('SET003') && objCOMMSetts.get('SET003').length() > 0 ? objCOMMSetts.get('SET003') : 'SCON_CR_Service');
    }
    
    public PageReference CreateServiceCatalog()
    {
        return RedirectTo('Service_Plan__c',objCOMMSetts != null && objCOMMSetts.ContainsKey('SET004') && objCOMMSetts.get('SET004').length() > 0 ? objCOMMSetts.get('SET004') : 'SCON_CR_ServicePlan');
    } 
    
    public PageReference CreateWorkTemplate()
    {
        return RedirectTo('SVMXC__Task_Template__c',objCOMMSetts != null && objCOMMSetts.ContainsKey('SET006') && objCOMMSetts.get('SET006').length() > 0 ? objCOMMSetts.get('SET006') : 'CR_WorkTemplate');
    } 
    
    public PageReference CreatePMPlanTemplate()
    {
        return RedirectTo('SVMXC__PM_Plan_Template__c',objCOMMSetts != null && objCOMMSetts.ContainsKey('SET007') && objCOMMSetts.get('SET007').length() > 0 ? objCOMMSetts.get('SET007') : 'CR_PMPlanTemplate');
    } 
    
    public PageReference RedirectTo(String strObjName, String strSFMProc)
    {
        map<String, Schema.SObjectType> objGlobalDescribe = new map<String, Schema.SObjectType>();
        String strObjectName = strObjName;
        String strKeyPrefix = '';
        objGlobalDescribe = Schema.getGlobalDescribe();
        
        //-------Start---------Added for SFM optimization--------
        Boolean isJwtEnabled = false;
        Boolean isCorsEnabled = false;
        Boolean isStatisticsEnabled = false;
        String appInstanceName = SFMDeliveryController.getInstanceName();
        
        COMM_Utils_ManageSettings objManageSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String,Map<String,String>> mapAllSubmoduleSettings = objManageSettings.SVMX_getSettingList(new List<String>{'SFM002','COMM004', 'GLOB001'});
        
        Map<String, String> mapGlobalSettings = new Map<String, String>();
        
        if(mapAllSubmoduleSettings != null){
            mapGlobalSettings = mapAllSubmoduleSettings.get('GLOB001');
            
            if((mapGlobalSettings != null && mapGlobalSettings.containsKey('GBL039') && mapGlobalSettings.get('GBL039') != null && Boolean.valueOf(mapGlobalSettings.get('GBL039')) == true) && Site.getSiteId() != null){
                isJwtEnabled = true;
            }
            
            if(mapGlobalSettings != null && mapGlobalSettings.containsKey('GBL043') && mapGlobalSettings.get('GBL043') != null && Boolean.valueOf(mapGlobalSettings.get('GBL043')) == true){
                isCorsEnabled = true;
            }
            
            Map<String,String> mapSettings = mapAllSubmoduleSettings.get('SFM002');
            if(mapSettings != null && mapSettings.containsKey('SET004') && mapSettings.get('SET004') != null && mapSettings.get('SET004').equalsIgnoreCase('Lightning')){
                isSFMLightning = true;
            }
            //Added for the task BAC-6188
            if(mapSettings != null && mapSettings.containsKey('SET007') && mapSettings.get('SET007') != null){
                isLegacyDeliveryEnabled = Boolean.valueOf(mapSettings.get('SET007'));
            }
            
            mapSettings = mapAllSubmoduleSettings.get('COMM004');
            if(mapSettings != null && mapSettings.containsKey('SET001') && mapSettings.get('SET001') != null && mapSettings.get('SET001').equalsIgnoreCase('Allow')){
                isStatisticsEnabled = true;
            }
        }
        //-------End---------Added for SFM optimization--------
        
        if(!objGlobalDescribe.containsKey('SVMXC__' + strObjectName ))
        {
            //This is to work in base org
            if(objGlobalDescribe.containsKey(strObjectName ))
            {
                Schema.DescribeSObjectResult objSobjectDescribe = objGlobalDescribe.get(strObjectName).getDescribe();
                strKeyPrefix = objSobjectDescribe.getKeyPrefix();
            }
        }
        else
        {
            Schema.DescribeSObjectResult objSobjectDescribe = objGlobalDescribe.get('SVMXC__' + strObjectName).getDescribe();
            strKeyPrefix = objSobjectDescribe.getKeyPrefix();
        }
        
        //-------Start---------Added for SFM optimization--------
        String strURL = '/apex/'+getDeliveryPageName()+'?SVMX_processId=' + strSFMProc + '&SVMX_retURL=../' + strKeyPrefix;
        
        if(isJwtEnabled){
            strURL = strURL + '&SVMX_JWTEnabled=' +isJwtEnabled;
        }
        if(isCorsEnabled){
            strURL = strURL + '&SVMX_CORS_Enabled=' +isCorsEnabled;
        }
        if(isSFMLightning){
            strURL = strURL + '&SVMX_IsSFMLightning=' +isSFMLightning;
        }
        if(isStatisticsEnabled){
            strURL = strURL + '&SVMX_IsStatisticsEnabled=' + isStatisticsEnabled;
        }
        strURL = strURL + '&SVMX_AppInstanceName=' + appInstanceName;
        //-------End---------Added for SFM optimization--------
        
        //PageReference objRedirect = new PageReference('/apex/'+getDeliveryPageName()+'?SVMX_processId=' + strSFMProc + '&SVMX_retURL=../' + strKeyPrefix);
        PageReference objRedirect = new PageReference(strURL);
        objRedirect.setRedirect(true);
        return objRedirect;
    }
    
    public String getDeliveryPageName()
    {
        String strPageName = 'SVMXC__SFM_TDM_Delivery';
        try
        {
            map<String, String> svmxSettingList = objSettings.SVMX_getSettingList('GLOB001');
            if(svmxSettingList.containsKey('GBL021') && svmxSettingList.get('GBL021') != null )
            {
                if(svmxSettingList.get('GBL021').toUpperCase() == 'HTML5')
                    strPageName = 'SVMXC__ServiceMaxConsole';
            }
            //BAC-6188 React Delivery Change
            if(isLegacyDeliveryEnabled && isSFMLightning){
                strPageName = 'SVMXC__SFMDeliveryReactConsole';
            }
            return strPageName;
        }
        catch(Exception ex)
        {
            System.debug(logginglevel.Info, 'Stack Trace : ' + ex.getStackTraceString());
            return strPageName;
        }
    }
    
      
    //Begin : Spring'17 : Overnight Stay
     public PageReference CreateOvernightStayPolicy()
    {
        try
        {
            return RedirectTo('SM_Overnight_Stay_Policy__c',(objCOMMSetts != null && objCOMMSetts.ContainsKey('SET008') && objCOMMSetts.get('SET008').length() > 0) ? objCOMMSetts.get('SET008') : 'SM_Overnight_Stay_Policy');
        }catch(Exception ex)
        {
            System.debug(logginglevel.Info, 'Stack Trace : ' + ex.getStackTraceString());
            throw ex;
        }
    }
     //END : Spring'17 : Overnight Stay
}