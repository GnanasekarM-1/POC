public class SFMSearchDeliveryServiceImpl extends SFMSearchDeliveryServiceBase{

    public SFMSearchDeliveryServiceImpl(RestRequest req, RestResponse res){
        super(req, res);
    }
    
    public SFMSearchDeliveryServiceImpl(){}
    
    override public Object getSearchInfo() { 
        SVMXC.SFMSearchDeliveryServiceImpl.SearchInfoRequest sir = new SVMXC.SFMSearchDeliveryServiceImpl.SearchInfoRequest();
        return getSearchInfoInternal(sir); 
    }
    
    public Object getSearchInfoInternal(SVMXC.SFMSearchDeliveryServiceImpl.SearchInfoRequest sir) { 
         SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
         return SVMXC.INTF_WebServicesDef.SFM_GetSearchInfo_WS(req);
    }
    
    override public Object getSearchResult() { 
        SVMXC.SFMSearchDeliveryServiceImpl.SearchResultRequest srr = 
                (SVMXC.SFMSearchDeliveryServiceImpl.SearchResultRequest) deserializeRequestTo(SVMXC.SFMSearchDeliveryServiceImpl.SearchResultRequest.class);
                
        return getSearchResultInternal(srr);
    }
    
    public Object getSearchResultInternal(SVMXC.SFMSearchDeliveryServiceImpl.SearchResultRequest srr) { 
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('SearchProcessId', srr.ProcessId));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('SVMXSearchProcessId', srr.ProcessName));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('ObjectId', srr.ObjectId));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('KeyWord', srr.KeyWord));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', srr.Operator));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('RecordLimit', String.valueOf(srr.RecordLimit)));
        return SVMXC.INTF_WebServicesDef.SFM_GetSearchResult_WS(req);
    }


    override public Object getUserInfo(){
        return this.getUserInfoInternal();
    }

    public Object getUserInfoInternal(){
        /**
         * The internal method is introduced so that the service methods can be consumed from VF page.
         */
        return new UserInfoResponse();
    }   
    public class SearchInfoRequest{
        
    }
    
    public class SearchResultRequest{
        public String ProcessId;
        public String ProcessName;
        public String ObjectId;
        public String KeyWord;
        public String Operator;
        public Integer RecordLimit;
    }

    public class UserInfoResponse{
        public String UserId;
        public String DateFormat;
        public String Language;
        public String TimezoneOffset;
        public UserInfoResponse(){
            UserId = UserInfo.getUserId();
            Language = UserInfo.getLanguage();
            DateFormat = SVMXC.DCON_Configuration_WS.DCON_GetLocalDate_WS(UserId);
            TimezoneOffset = new SVMXC.SVMX_Constant_Utils().getUserTimezoneOffset();
        }
    }   
}