global class SFMDeliveryServiceSOAPIntf {

	global class Request {
		webservice String message {get;set;}
	}
	
	global class Response {
		
		webservice String message {get;set;}
		
		global Response(String message){
			this.message = message;
		}
	}
	
	webservice static SFMDeliveryServiceSOAPIntf.Response getPageLayout(SFMDeliveryServiceSOAPIntf.Request request) {
        
        SFMDeliveryServiceSOAPIntf.PageLayoutRequest plr = 
                (SFMDeliveryServiceSOAPIntf.PageLayoutRequest) deserializeRequestTo(
                	request.message, SFMDeliveryServiceSOAPIntf.PageLayoutRequest.class);      
        // create a request
        SVMXC.SFM_WrapperDef.SFM_Request_PageUI req = new SVMXC.SFM_WrapperDef.SFM_Request_PageUI();
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = req.request.StringMap;
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('PROCESSID', plr.processId));
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', plr.recordId));
        // end of create request
        
        SVMXC.SFM_getPageLayout pagelayout = new SVMXC.SFM_getPageLayout(); 
        return new SFMDeliveryServiceSOAPIntf.Response(
        	serializeResponseFrom(pagelayout.SFM_GetPageLayout(req)) );
    }
    
    webservice static SFMDeliveryServiceSOAPIntf.Response retrieveDisplayTags(SFMDeliveryServiceSOAPIntf.Request request) {
        SFMDeliveryServiceSOAPIntf.DisplayTagRequest dtr = 
                (SFMDeliveryServiceSOAPIntf.DisplayTagRequest) deserializeRequestTo(
                	request.message, SFMDeliveryServiceSOAPIntf.DisplayTagRequest.class);
        
        list<SVMXC.COMM_TagWebServices.TagsMap> TagListValueM = new List<SVMXC.COMM_TagWebServices.TagsMap>();
        TagListValueM = SVMXC.COMM_TagWebServices.TagdataforSubmodule(dtr.moduleId);
        
        return new SFMDeliveryServiceSOAPIntf.Response(serializeResponseFrom(TagListValueM));
    }
    
    static Object deserializeRequestTo(String requestStr, System.Type apexType){
        
        if(requestStr != null && requestStr != ''){
            return JSON.deserialize(requestStr, apexType);
        }
        return null;
    }
    
    static String serializeResponseFrom(Object data){
        return JSON.serialize(data);
    }
    
    global class PageLayoutRequest {
        public String processId;
        public String recordId;
    }
    
    global class DisplayTagRequest {
        public String moduleId;
        public Boolean isSubModule;
    }
}