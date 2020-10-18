public class MobEntServiceImpl extends MobEntServiceBase 
{
    public RestRequest request;
    public RestResponse response;
    public String strRequest;
    public String strRequestURI;
    
    public MobEntServiceImpl(RestRequest req, RestResponse res)
    {
        super(req, res);
    }
    
    override public Object getSvmxVersion()
    {
        List<SVMXC.COMM_Webservices.KeyValue> request = new List<SVMXC.COMM_Webservices.KeyValue>();
        request = (List<SVMXC.COMM_Webservices.KeyValue>)deserializeRequestTo(List<SVMXC.COMM_Webservices.KeyValue>.class);
        List<SVMXC.COMM_Webservices.KeyValue> resp = SVMXC.INTF_WebServicesDef.SVMX_GetSvmxVersion(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object updateEvents()
    {
        List<SVMXC.INTF_WebServicesDef.INTF_Event_WP> request = new List<SVMXC.INTF_WebServicesDef.INTF_Event_WP>();
        request = (List<SVMXC.INTF_WebServicesDef.INTF_Event_WP>)deserializeRequestTo(List<SVMXC.INTF_WebServicesDef.INTF_Event_WP>.class);
        String resp = SVMXC.INTF_WebServicesDef.INTF_Update_Events_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object addRecords()
    {
        SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        request = (SVMXC.INTF_WebServicesDef.INTF_Request)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_Request.class);
        List<SVMXC.INTF_WebServicesDef.INTF_PageDataSet> resp = SVMXC.INTF_WebServicesDef.INTF_AddRecords_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object saveTargetRecords()
    {
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord request = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        request = (SVMXC.INTF_WebServicesDef.INTF_TargetRecord)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_TargetRecord.class);
        system.debug('Request== ' + request);
        SVMXC.INTF_WebServicesDef.INTF_Response resp = SVMXC.INTF_WebServicesDef.SFM_SaveTargetRecords_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object getTags()
    {
        SVMXC.INTF_WebServicesDef.INTF_Request_For_Tags request = new SVMXC.INTF_WebServicesDef.INTF_Request_For_Tags();
        request = (SVMXC.INTF_WebServicesDef.INTF_Request_For_Tags)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_Request_For_Tags.class);
        SVMXC.INTF_WebServicesDef.INTF_Response_For_Tags resp = SVMXC.INTF_WebServicesDef.INTF_Get_Tags_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object getTasks()
    {
        SVMXC.INTF_WebServicesDef.INTF_Request_For_Tasks request = new SVMXC.INTF_WebServicesDef.INTF_Request_For_Tasks();
        request = (SVMXC.INTF_WebServicesDef.INTF_Request_For_Tasks)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_Request_For_Tasks.class);
        SVMXC.INTF_WebServicesDef.INTF_Response_For_Tasks resp = SVMXC.INTF_WebServicesDef.INTF_Get_Tasks_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object getViewLayouts()
    {
        SVMXC.INTF_WebServicesDef.INTF_Response_For_Get_View_Layouts resp = SVMXC.INTF_WebServicesDef.INTF_Get_View_Layouts_WS();
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object getWorkOrderMapView()
    {
        SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        request = (SVMXC.INTF_WebServicesDef.INTF_Request)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_Request.class);
        SVMXC.INTF_WebServicesDef.INTF_Response resp = SVMXC.INTF_WebServicesDef.INTF_Get_WorkOrderMapView_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
     override public Object getStandaloneCreateLayouts()
    {
        SVMXC.INTF_WebServicesDef.INTF_Response_For_Get_StandaloneCreate_Layouts resp = SVMXC.INTF_WebServicesDef.INTF_Get_StandaloneCreate_Layouts();
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object getEvents()
    {
        SVMXC.INTF_WebServicesDef.INTF_Request_For_Events request = new SVMXC.INTF_WebServicesDef.INTF_Request_For_Events();
        request = (SVMXC.INTF_WebServicesDef.INTF_Request_For_Events)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_Request_For_Events.class);
        SVMXC.INTF_WebServicesDef.INTF_Response_For_Events resp = SVMXC.INTF_WebServicesDef.INTF_Get_Events_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object getPageLayouts()
    {
        SVMXC.INTF_WebServicesDef.INTF_Request_PageUI request = new SVMXC.INTF_WebServicesDef.INTF_Request_PageUI();
        request = (SVMXC.INTF_WebServicesDef.INTF_Request_PageUI)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_Request_PageUI.class);
        SVMXC.INTF_WebServicesDef.INTF_Response_PageUI resp = SVMXC.INTF_WebServicesDef.INTF_getPageLayout_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object savePageLayouts()
    {
        SVMXC.INTF_WebServicesDef.INTF_Request_PageUI request = new SVMXC.INTF_WebServicesDef.INTF_Request_PageUI();
        request = (SVMXC.INTF_WebServicesDef.INTF_Request_PageUI)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_Request_PageUI.class);
        SVMXC.INTF_WebServicesDef.INTF_Response resp = SVMXC.INTF_WebServicesDef.INTF_SavePageLayout_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object getLookupConfigWithData()
    {
        SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        request = (SVMXC.INTF_WebServicesDef.INTF_Request)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_Request.class);
        SVMXC.INTF_WebServicesDef.INTF_LookUpConfigData resp = SVMXC.INTF_WebServicesDef.INTF_getLookUpConfigWithData_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object getAccountHistory()
    {
        SVMXC.INTF_WebServicesDef.INTF_Request_For_History request = new SVMXC.INTF_WebServicesDef.INTF_Request_For_History();
        request = (SVMXC.INTF_WebServicesDef.INTF_Request_For_History)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_Request_For_History.class);
        SVMXC.INTF_WebServicesDef.INTF_Response_For_History resp = SVMXC.INTF_WebServicesDef.INTF_Get_Account_History_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object getProductHistory()
    {
        SVMXC.INTF_WebServicesDef.INTF_Request_For_History request = new SVMXC.INTF_WebServicesDef.INTF_Request_For_History();
        request = (SVMXC.INTF_WebServicesDef.INTF_Request_For_History)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_Request_For_History.class);
        SVMXC.INTF_WebServicesDef.INTF_Response_For_History resp = SVMXC.INTF_WebServicesDef.INTF_Get_Product_History_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
    
    override public Object getPREQGetPrice()
    {
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord request = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        request = (SVMXC.INTF_WebServicesDef.INTF_TargetRecord)deserializeRequestTo(SVMXC.INTF_WebServicesDef.INTF_TargetRecord.class);
        SVMXC.INTF_WebServicesDef.INTF_PageData resp = SVMXC.INTF_WebServicesDef.INTF_PREQ_GetPrice_WS(request);
        system.debug('Response== ' + resp);
        return resp;
    }
}