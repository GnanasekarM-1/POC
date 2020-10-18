public with sharing class INTF_MobileDeviceTagsUtility 
{
  public INTF_WebServicesDef.INTF_SFMResponse getMobileConfigTags(INTF_WebServicesDef.INTF_SFMRequest tagsReq)
  {
    INTF_WebServicesDef.INTF_SFMResponse objTagResponse = new INTF_WebServicesDef.INTF_SFMResponse();
    List<INTF_WebServicesDef.svmxError> lstErrors = new List<INTF_WebServicesDef.svmxError>();
    system.debug('tagsReq' + tagsReq);
        try
        {
            List<INTF_WebServicesDef.SVMXMap> lstReqForTags = tagsReq.valueMap;
            List<INTF_WebServicesDef.SVMXMap> lstTags;
            if(lstReqForTags != null && lstReqForTags.size() > 0)
            {
                COMM_TagsDefinition tagDefination = new COMM_TagsDefinition();
                lstTags = tagDefination.MobileTagvalueCalc(lstReqForTags[0].value,Boolean.valueOf(lstReqForTags[1].value));
        objTagResponse.success = true;
            }else
            {
              INTF_WebServicesDef.svmxError objEror = new INTF_WebServicesDef.svmxError();
            objEror.errorMsg = 'Please specfiy the valid request to get the Tags informations.';
            lstErrors.add(objEror);
        objTagResponse.success = false;
          }
      objTagResponse.valueMap = lstTags;
        }catch(Exception ex)
        {
          INTF_WebServicesDef.svmxError objEror = new INTF_WebServicesDef.svmxError();
          objEror.errorMsg = ex.getMessage();
          lstErrors.add(objEror);
      objTagResponse.success = false;                 
        }
    objTagResponse.eventType = 'DATA';
    objTagResponse.eventName = 'MOBILE_DEVICE_TAGS';
        objTagResponse.errors = lstErrors;
        return objTagResponse;
  }
}