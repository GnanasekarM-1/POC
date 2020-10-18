public class SFMWizardDeliveryServiceImpl extends SFMWizardDeliveryServiceBase{

    public SFMWizardDeliveryServiceImpl(RestRequest req, RestResponse res){
        super(req, res);
    }
    
    public SFMWizardDeliveryServiceImpl(){}
    
    override public Object getWizardInfo() { 
        SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest wir = 
            (SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest) deserializeRequestTo(SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest.class);
        return getWizardInfoInternal(wir); 
    }
    
    public Object getWizardInfoInternal(SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest wir) {     
        SVMXC.SFM_WrapperDef.SFM_Request req = new SVMXC.SFM_WrapperDef.SFM_Request();
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> inputKeyValues = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        List<SVMXC.SFM_WrapperDef.SFM_StringListMap> inputKey_Valuelst = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        
        inputKeyValues.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', wir.RecordId));
        inputKey_Valuelst.add(new SVMXC.SFM_WrapperDef.SFM_StringListMap('ACTIONTYPE', wir.ActionTypes));
        
        req.stringMap = inputKeyValues;
        req.stringListMap = inputKey_Valuelst;
        
        SVMXC.INTF_WebServicesDef.INTF_Response_SFWInfo sfwInfo = 
            SVMXC.INTF_WebServicesDef.INTF_GetSFWWrapper_WS(req);
        //return new SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoResponse(sfwInfo, extractSettings());
        return new SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoResponse(sfwInfo, extractSettings(), extractUrlParameter());
    }
    
    private List<SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting> extractSettings(){
        List<SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting> Settings = 
            new List<SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting>();
        
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        String deliveryType = 'FLEX';
            
        Map<String, String> svmxSettingListGLOB = commSettings.SVMX_getSettingList('GLOB001');
        if(svmxSettingListGLOB.containsKey('GBL021') && svmxSettingListGLOB.get('GBL021') != null )
        {
            if(svmxSettingListGLOB.get('GBL021').toUpperCase() == 'HTML5')
                deliveryType = 'HTML5';
        }
        
        Settings.add(new SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting('GBL021', deliveryType));
        return Settings;
    }
    
    private List<SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting> extractUrlParameter(){
        List<SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting> urlParameterList = new List<SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting>();
        
        String appInstanceName = SFMDeliveryController.getInstanceName();
        urlParameterList.add(new SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting('SVMX_AppInstanceName', appInstanceName));

        COMM_Utils_ManageSettings objManageSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String,Map<String,String>> mapAllSubmoduleSettings = objManageSettings.SVMX_getSettingList(new List<String>{'SFM002','COMM004', 'GLOB001'});
        
        Map<String, String> mapGlobalSettings = new Map<String, String>();
        
        if(mapAllSubmoduleSettings != null){
            mapGlobalSettings = mapAllSubmoduleSettings.get('GLOB001');
            
            if((mapGlobalSettings != null && mapGlobalSettings.containsKey('GBL039') && mapGlobalSettings.get('GBL039') != null && Boolean.valueOf(mapGlobalSettings.get('GBL039')) == true) && Site.getSiteId() != null){
                urlParameterList.add(new SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting('SVMX_JWTEnabled', 'true'));
            }
            
            if(mapGlobalSettings != null && mapGlobalSettings.containsKey('GBL043') && mapGlobalSettings.get('GBL043') != null && Boolean.valueOf(mapGlobalSettings.get('GBL043')) == true){
                urlParameterList.add(new SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting('SVMX_CORS_Enabled', 'true'));
            }
            
            Map<String,String> mapSettings = mapAllSubmoduleSettings.get('SFM002');
            if(mapSettings != null && mapSettings.containsKey('SET004') && mapSettings.get('SET004') != null && mapSettings.get('SET004').equalsIgnoreCase('Lightning')){
                urlParameterList.add(new SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting('SVMX_IsSFMLightning', 'true'));
            }
            
            mapSettings = mapAllSubmoduleSettings.get('COMM004');
            if(mapSettings != null && mapSettings.containsKey('SET001') && mapSettings.get('SET001') != null && mapSettings.get('SET001').equalsIgnoreCase('Allow')){
                urlParameterList.add(new SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting('SVMX_IsStatisticsEnabled', 'true'));
            }
        }
        
        return urlParameterList;
    }
    
    public class WizardInfoRequest{
        String RecordId;
        List<String> ActionTypes;
    }
    
    public class WizardInfoResponse{
        SVMXC.INTF_WebServicesDef.INTF_Response_SFWInfo SFWInfo;
        List<SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting> Settings;
        List<SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting> urlParameterListAndValue;
        
        public WizardInfoResponse(SVMXC.INTF_WebServicesDef.INTF_Response_SFWInfo SFWInfo,
        List<SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting> Settings){
            this.SFWInfo = SFWInfo;
            this.Settings = Settings;
        }
        
        public WizardInfoResponse(SVMXC.INTF_WebServicesDef.INTF_Response_SFWInfo SFWInfo,
        List<SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting> Settings, 
        List<SVMXC.SFMWizardDeliveryServiceImpl.WizardSetting> urlParameterListAndValue){
            this.SFWInfo = SFWInfo;
            this.Settings = Settings;
            this.urlParameterListAndValue = urlParameterListAndValue;
        }
    }
    
    public class WizardSetting{
        public String Key;
        public String Value;
        
        public WizardSetting(String Key, String Value){
            this.Key = Key;
            this.Value = Value;
        }
    }
}