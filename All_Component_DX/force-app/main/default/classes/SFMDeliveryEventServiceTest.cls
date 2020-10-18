global class SFMDeliveryEventServiceTest {

	webservice static SVMXC.INTF_WebServicesDef.INTF_PageData Test_WS(
			SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
    	SVMXC.INTF_WebServicesDef.INTF_Record header = request.headerRecord.records[0];
    	List<SVMXC.INTF_WebServicesDef.INTF_StringMap> targetRecordAsKeyValue = header.targetRecordAsKeyValue;
    	Integer i = 0, l = targetRecordAsKeyValue.size();
    	
    	for(i = 0; i < l; i++){
    		if(targetRecordAsKeyValue[i].value == 'Indresh')
    			targetRecordAsKeyValue[i].value = 'Hi! Indresh';
    	}
    	
        SVMXC.INTF_WebServicesDef.INTF_PageData PageData = null;
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        PageData = buildpagedata.INTF_buildPageData(request);
        PageData.response.success = true;
        PageData.response.message = 'What is beautiful world! What is beautiful world! What is beautiful world! What is beautiful world! What is beautiful world! What is beautiful world! What is beautiful world! What is beautiful world!';
        PageData.response.messageType = 'SVMX_SUCCESS';
        return PageData;
    }
}