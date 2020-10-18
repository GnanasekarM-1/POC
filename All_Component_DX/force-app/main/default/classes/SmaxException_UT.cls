@isTest
private class SmaxException_UT 
{
    static testMethod void testMethod1()
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        try
        {
            String str = null;
            Integer len = str.length();
        }
        catch(Exception e)
        {
            Map<String, String> mapCustomMsgs = new Map<String, String>();
            mapCustomMsgs.put('Exception test','String Exception');
            SmaxException exceptionobj = new SmaxException(mapCustomMsgs, e);
            response.errors.add(exceptionobj.getDetailedErrorMsg());
        }
    }
}