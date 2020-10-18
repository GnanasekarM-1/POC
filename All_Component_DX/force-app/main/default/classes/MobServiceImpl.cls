public class MobServiceImpl extends MobServiceBase
{
    public MobServiceImpl(RestRequest req, RestResponse res)
    {
        super(req, res);
    }

    override public Object DataSyncRequest()
    {
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        request = (SVMXC.INTF_WebServicesDef.INTF_SFMRequest)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_SFMRequest.class);
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(request);
        return resp;
    }

    override public Object MetaSyncRequest()
    {
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        request = (SVMXC.INTF_WebServicesDef.INTF_SFMRequest)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_SFMRequest.class);
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = SVMXC.INTF_WebServicesDef.INTF_MetaSync_WS(request);
        return resp;
    }

    override public Object getSVMXVersion()
    {
        List<SVMXC.COMM_Webservices.KeyValue> request = new List<SVMXC.COMM_Webservices.KeyValue>();
        request = (List<SVMXC.COMM_Webservices.KeyValue>)deserializeRequestTo(List<SVMXC.COMM_Webservices.KeyValue>.class);
        List<SVMXC.COMM_Webservices.KeyValue> resp = SVMXC.INTF_WebServicesDef.SVMX_GetSvmxVersion(request);
        return resp;
    }

    override public Object generateWOInvoice()
    {
        SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        request = (SVMXC.INTF_WebServicesDef.INTF_Request)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_Request.class);
        SVMXC.INTF_WebServicesDef.INTF_Response resp = SVMXC.INTF_WebServicesDef.PINV_GenerateWOInvoiceDoc_WS(request);
        return resp;
    }

    override public Object getLookUpResults()
    {
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request = (SVMXC.SFM_WrapperDef.SFM_Request)deserializeRequestTo(SVMXC.SFM_WrapperDef.SFM_Request.class);
        SVMXC.SFM_WrapperDef.SFM_Response resp = SVMXC.INTF_WebServicesDef.lookupSearchResults(request);
        return resp;
    }
    
    override public Object insertSNSDetails()
    {
        INTF_WebServicesDef.INTF_SFMRequest request= new INTF_WebServicesDef.INTF_SFMRequest();
        request = (INTF_WebServicesDef.INTF_SFMRequest)deserializeRequestTo(INTF_WebServicesDef.INTF_SFMRequest.class);
        INTF_WebServicesDef.INTF_SFMResponse resp = SNSMobClientData.insertClientDetails(request);
        return resp;
    }

    override public Object retrieveDisplayTags()
    {
        SVMXC.MobServiceImpl.DisplayTagsResponse resp = new SVMXC.MobServiceImpl.DisplayTagsResponse();

        // Laptop Login Screen
        List<SVMXC.COMM_TagWebServices.TagsMap> SFML = new List<SVMXC.COMM_TagWebServices.TagsMap>();
        SFML = SVMXC.COMM_TagWebServices.TagdataforSubmodule('OFFL013');
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0001',system.label.OFFL016_TAG029));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0002',system.label.OFFL012_TAG028));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0003',system.label.OFFL007_TAG030));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0004',system.label.OFFL015_TAG017));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0005',system.label.OFFL015_TAG018));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0006',system.label.OFFL010_TAG012));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0007',system.label.OFFL010_TAG005));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0008',system.label.OFFL015_TAG014));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0009',system.label.OFFL015_TAG015));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0010',system.label.OFFL015_TAG016));

        //LM API
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0011',system.label.OFFL008_TAG066));

        //LM Calendar Tags
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0012',system.label.OFFL007_TAG044));

        //LM API
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0013',system.label.OFFL015_TAG021));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0014',system.label.OFFL015_TAG022));

        //SFMConsole
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0015',system.label.IPAD006_TAG071));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0016',system.label.IPAD006_TAG072));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0017',system.label.IPAD006_TAG073));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0018',system.label.IPAD006_TAG074));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0019',system.label.IPAD006_TAG075));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0020',system.label.IPAD006_TAG076));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0021',system.label.IPAD006_TAG077));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0022',system.label.IPAD006_TAG078));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0023',system.label.IPAD006_TAG079));
        SFML.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0024',system.label.IPAD006_TAG080));


        resp.AllTags.add(new SVMXC.MobServiceImpl.DisplayTags('ContainerTags', SFML));

        // SFM Delivery
        List<SVMXC.COMM_TagWebServices.TagsMap> SFMD = new List<SVMXC.COMM_TagWebServices.TagsMap>();
        SFMD = SVMXC.COMM_TagWebServices.TagdataforSubmodule('SFM002');
        //the tag names is added to prevent future tag id conflicts * 1000
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0001',system.label.IPAD006_TAG054));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0002',system.label.OFFL015_TAG003));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0003',system.label.IPAD006_TAG055));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0004',system.label.IPAD006_TAG056));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0005',system.label.IPAD006_TAG057));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0006',system.label.IPAD006_TAG058));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0007',system.label.IPAD006_TAG059));

        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0008',system.label.IPAD006_TAG060));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0009',system.label.COMM001_TAG049));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0010',system.label.IPAD006_TAG061));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0011',system.label.IPAD006_TAG062));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0012',system.label.OFFL001_TAG008));

        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0013',system.label.IPAD006_TAG059));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0014',system.label.IPAD006_TAG064));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0015',system.label.IPAD006_TAG065));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0016',system.label.IPAD006_TAG066));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0017',system.label.OFFL001_TAG008));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0018',system.label.IPAD006_TAG067));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0019',system.label.IPAD006_TAG068));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0020',system.label.IPAD006_TAG069));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0021',system.label.COMM001_TAG067));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0022',system.label.OFFL001_TAG009));
        SFMD.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0024',system.label.IPAD006_TAG136));

        resp.AllTags.add(new SVMXC.MobServiceImpl.DisplayTags('SFMDELIVERY', SFMD));

        // SFM Search
        List<SVMXC.COMM_TagWebServices.TagsMap> SFMS = new List<SVMXC.COMM_TagWebServices.TagsMap>();
        SFMS = SVMXC.COMM_TagWebServices.TagdataforSubmodule('SFM003');
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0002',system.label.SFM003_TAG002));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0003',system.label.SFM003_TAG003));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0004',system.label.SFM003_TAG004));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0005',system.label.SFM003_TAG005));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0006',system.label.SFM003_TAG006));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0007',system.label.SFM003_TAG007));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0008',system.label.SFM003_TAG008));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0009',system.label.SFM003_TAG009));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('COMM001_TAG012',system.label.COMM001_TAG012));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('COMM001_TAG013',system.label.COMM001_TAG013));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('COMM001_TAG014',system.label.COMM001_TAG014));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('COMM001_TAG015',system.label.COMM001_TAG015));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('COMM001_TAG031',system.label.COMM001_TAG031));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('SFW_TITLE',system.label.CONF005_TEXT73));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('SFW_AVLBL_SRCH',system.label.CONF031_TAG024));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('SFW_YES_BTN',system.label.COMM001_TAG119));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('SFW_NO_BTN',system.label.COMM001_TAG120));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('CONF016_TAG113',system.label.CONF016_TAG113));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('CONF016_TAG114',system.label.CONF016_TAG114));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('CONF016_TAG032',system.label.CONF016_TAG032));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('CONF016_TAG115',system.label.CONF016_TAG115));
        SFMS.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0010',system.label.SFM002_TAG088));
        resp.AllTags.add(new SVMXC.MobServiceImpl.DisplayTags('SFMSEARCH', SFMS));

        // SFW
        List<SVMXC.COMM_TagWebServices.TagsMap> SFW = new List<SVMXC.COMM_TagWebServices.TagsMap>();
        SFW = SVMXC.COMM_TagWebServices.TagdataforSubmodule('SFW001');
        SFW.add(new SVMXC.COMM_TagWebServices.TagsMap('SFW_TITLE',system.label.CONF005_TEXT73));
        SFW.add(new SVMXC.COMM_TagWebServices.TagsMap('SFW_AVLBL_SRCH',system.label.CONF031_TAG024));
        SFW.add(new SVMXC.COMM_TagWebServices.TagsMap('SFW_YES_BTN',system.label.COMM001_TAG119));
        SFW.add(new SVMXC.COMM_TagWebServices.TagsMap('SFW_NO_BTN',system.label.COMM001_TAG120));
        SFW.add(new SVMXC.COMM_TagWebServices.TagsMap('CONF016_TAG113',system.label.CONF016_TAG113));
        SFW.add(new SVMXC.COMM_TagWebServices.TagsMap('CONF016_TAG114',system.label.CONF016_TAG114));
        SFW.add(new SVMXC.COMM_TagWebServices.TagsMap('CONF016_TAG032',system.label.CONF016_TAG032));
        SFW.add(new SVMXC.COMM_TagWebServices.TagsMap('CONF016_TAG115',system.label.CONF016_TAG115));
        SFW.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0025',system.label.CONF019_TAG025));
        SFW.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0026',system.label.IPAD006_TAG063));
        SFW.add(new SVMXC.COMM_TagWebServices.TagsMap('TAG0027',system.label.IPAD006_TAG070));

        resp.AllTags.add(new SVMXC.MobServiceImpl.DisplayTags('SFWDELIVERY', SFW));

        //LM Data Access API
        List<SVMXC.COMM_TagWebServices.TagsMap> SFMLMAPI = new List<SVMXC.COMM_TagWebServices.TagsMap>();
        SFMLMAPI = SVMXC.COMM_TagWebServices.TagdataforSubmodule('OFFL016');
        resp.AllTags.add(new SVMXC.MobServiceImpl.DisplayTags('LMAPI', SFMLMAPI ));

        return resp;
    }

    override public Object getUserInfo()
    {
        SVMXC.MobServiceImpl.UserInfoResponse resp = new SVMXC.MobServiceImpl.UserInfoResponse();

        // server version
        List<SVMXC.COMM_Webservices.KeyValue> ver = SVMXC.INTF_WebServicesDef.SVMX_GetSvmxVersion(null);
        resp.svmxVersion = ver.get(0).value;

        resp.UserId = UserInfo.getUserId();
        resp.Language = UserInfo.getLanguage();
        resp.OrgId = UserInfo.getOrganizationId();
        resp.UserName = UserInfo.getName();
        resp.UserLogin = UserInfo.getUsername();
        resp.UserSessionId = UserInfo.getSessionId();
        resp.DateFormat = SVMXC.DCON_Configuration_WS.DCON_GetLocalDate_WS(resp.UserId);
        resp.TimezoneOffset = new SVMXC.SVMX_Constant_Utils().getUserTimezoneOffset();
        resp.UserLocale = UserInfo.getLocale();

        // trunk location
        List<SVMXC__Service_Group_Members__c> objTech =
            [select SVMXC__Inventory_Location__c,SVMXC__Inventory_Location__r.Name
             from SVMXC__Service_Group_Members__c
             where  SVMXC__Salesforce_User__c =: UserInfo.getUserId() limit 1];

        ID location = null;

        if(objTech != null && objTech.size() > 0) {
            location = objTech[0].SVMXC__Inventory_Location__c;
            resp.UserTrunk = location;

            List<SVMXC__Site__c> objSite = [select Id,Name,SVMXC__City__c,SVMXC__Country__c,SVMXC__Email__c,SVMXC__Latitude__c,SVMXC__Location_Type__c,SVMXC__Longitude__c,SVMXC__State__c,SVMXC__Stocking_Location__c,SVMXC__Street__c
            from SVMXC__Site__c
            where id =: location];

            if(objSite != null && objSite.size() > 0) {
                resp.UserTrunkDetail = objSite[0];
            }
        }else{
            resp.UserTrunk = null;
            resp.UserTrunkDetail = null;
        }

        // end trunk location

        // user's servicemax profile id
        SVMXC.Sync_Utility util = new SVMXC.Sync_Utility();
        resp.SvmxProfileId = util.getGroupProfileId(null, false);
        // end profile id

        // can't find an api to do this.
        // TODO;
        // time format
        resp.TimeFormat = 'h:mm a';
        // end time format

        //MFL Issue addressed
        resp.Address = new OPDOC_DeliveryImpl().getAddress();
        return resp;
    }

    override public Object getCRTemplatesInfo() {
        SVMXC.MobServiceImpl.CRTemplateRequest request =
            (SVMXC.MobServiceImpl.CRTemplateRequest)deserializeRequestTo(SVMXC.MobServiceImpl.CRTemplateRequest.class);
        return getCRTemplatesInfoInternal(request);
    }

    private CRTemplateResponse getCRTemplatesInfoInternal(CRTemplateRequest request){
        SVMXC.MobServiceImpl.CRTemplateResponse response =
            new SVMXC.MobServiceImpl.CRTemplateResponse();

        response.TemplatesInfo = new List<Document>();
        if(request.ProcessIds != null && request.ProcessIds.size() > 0){
            response.TemplatesInfo =
            [select id, Name, Type, DeveloperName from Document where DeveloperName IN: request.ProcessIds];
        }
        return response;
    }

    public class CRTemplateRequest {
        List<String> ProcessIds;
    }

    public class CRTemplateResponse {
        List<Document> TemplatesInfo;
    }

    public class UserInfoResponse{
        public String SvmxVersion;
        public String UserId;
        public String OrgId;
        public String DateFormat;
        public String TimeFormat;
        public String Language;
        public String UserName;
        public String UserLogin;
        public ID UserTrunk;
        public Object UserTrunkDetail;
        public String UserSessionId;
        public String TimezoneOffset;
        public ID SvmxProfileId;
        //MFL Address Issue
        public String Address; 
        public String UserLocale;       
    }

    public class DisplayTags
    {
        public DisplayTags(String ModuleId, Object Tags)
        {
            this.ModuleId = ModuleId;
            this.Tags = Tags;
        }

        public String ModuleId;
        public Object Tags;
    }

    public class DisplayTagsResponse
    {
        public DisplayTagsResponse()
        {
            AllTags = new List<DisplayTags>();
        }

        public List<DisplayTags> AllTags;
    }
}