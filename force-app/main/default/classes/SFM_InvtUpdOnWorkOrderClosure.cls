global with sharing class SFM_InvtUpdOnWorkOrderClosure implements SFM_TriggerBaseInterface{
    public SVMXC.SFM_WrapperDef.SFM_Response executeSFMTrigger(SVMXC.SFM_WrapperDef.SFM_Request request) {
        
        //Variable Declarition. 
        INVT_WrapperDef.INVT_Response invtResponse = new INVT_WrapperDef.INVT_Response();
        SVMXC.SFM_WrapperDef.SFM_Response sfmResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        
        List<SVMXC.INVT_WrapperDef.INVT_StringMap> lstStringMap = new List<SVMXC.INVT_WrapperDef.INVT_StringMap>();
        if(request != null && request.stringMap != null && request.stringMap.size() > 0){
            for(SVMXC.SFM_WrapperDef.SFM_StringMap stringMap : request.stringMap){
                if(stringMap.key.equals('SVMX_HearderId') && stringMap.value != null){
                    SVMXC.INVT_WrapperDef.INVT_StringMap headerRecordIdStringMap = new SVMXC.INVT_WrapperDef.INVT_StringMap(stringMap.key,stringMap.value);
                    lstStringMap.add(headerRecordIdStringMap);
                }
                else if(stringMap.key.equals('SVMX_InventoryProcessId') && stringMap.value != null){
                    SVMXC.INVT_WrapperDef.INVT_StringMap inventoryProcessIdStringMap = new SVMXC.INVT_WrapperDef.INVT_StringMap(stringMap.key,stringMap.value); 
                    lstStringMap.add(inventoryProcessIdStringMap);
                }   
            }
        }
        // Create requset for Inventory API engine.
        if(lstStringMap != null && lstStringMap.size() > 0){
            SVMXC.INVT_WrapperDef.INVT_Request invtRequest = new SVMXC.INVT_WrapperDef.INVT_Request();
            invtRequest.listOfStringMap =  lstStringMap ;
            INVT_InventoryAPIEngine objInventoryAPIEngine = new INVT_InventoryAPIEngine();
            invtResponse = objInventoryAPIEngine.processINVTRequest(invtRequest);
            system.debug(LoggingLevel.WARN,'invtResponse'+invtResponse);
            if(!invtResponse.getValidationSuccess()){
                sfmResponse.success = true;
                sfmResponse.message = system.label.INVT001_TAG068;
            }
            else{
                sfmResponse.success = invtResponse.getSuccess();
                String strMessage = JSON.serialize(invtResponse.getListOfMessage());
               /* List<SVMXC.INVT_WrapperDef.SVMXMessage> messageList = invtResponse.getListOfMessage();
                if( messageList != null ) {
                    for( SVMXC.INVT_WrapperDef.SVMXMessage message : messageList ) {
                        if( strMessage != '' ) {
                            strMessage = strMessage + '\n';
                        }
                        strMessage = strMessage + message.message;
                    } 
                }
                
                List<SFM_WrapperDef.SVMXMessage> svmxMessageList = new List<SFM_WrapperDef.SVMXMessage>();
                SFM_WrapperDef.SVMXMessage svmxMessage = new SFM_WrapperDef.SVMXMessage();
                svmxMessage.message = strMessage;
                svmxMessageList.add( svmxMessage );*/
                
                sfmResponse.messages = (list<SFM_WrapperDef.SVMXMessage>)JSON.deserialize(strMessage, list<SFM_WrapperDef.SVMXMessage>.class);
                //sfmResponse.messages = svmxMessageList;
            }   
            
        }
        return sfmResponse;     
    }
}