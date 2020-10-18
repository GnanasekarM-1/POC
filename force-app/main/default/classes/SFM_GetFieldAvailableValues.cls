public with sharing class SFM_GetFieldAvailableValues {
	public SFM_GetFieldAvailableValues()
	{
		
	}
/*
    public SFM_WrapperDef.SFM_Response getAvailableValues(SFM_WrapperDef.SFM_Request request)       
    {
        SFM_Utils utils = new SFM_Utils();
        SFM_WrapperDef.SFM_Response reponse = new SFM_WrapperDef.SFM_Response();
        SVMX_Constants constant = new SVMX_Constants();
        Boolean response_success;
        String response_message;
       // List<SFM_WrapperDef.SFM_StringMap> requestedObjects = request.stringMap;
        List<SFM_WrapperDef.SFM_StringMap> options = new List<SFM_WrapperDef.SFM_StringMap>();
        String fieldType=null;
        String orgConstant = 'SVMXCONSTANT';
        try
        {
            if(fieldType.contains('DATE'))
            {
                Map<String, String> dateValues = new Map<String, String>();
                dateValues = constant.getDateOptions();
                for(String dateValue: dateValues.keySet())
                {
                    options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,dateValues.get(dateValue)));
                }
            }else if(fieldType.contains('DATETIME'))
            {
                Map<String, String> dateTimeValues = new Map<String, String>();
                dateTimeValues = constant.getDateTimeOptions();
                for(String dateValue:dateTimeValues.keySet())
                {
                    options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,dateTimeValues.get(dateValue)));
                }
            }else if(fieldType.contains('USER')){
                Map<String, String> userValues = new Map<String, String>();
                userValues = constant.getUserOptions();
                for(String dateValue:userValues.keySet())
                {
                    options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,userValues.get(dateValue)));
                }
            }
            reponse.setstringMap(options);
            reponse.success = true;
            
            
        }catch(Exception ex)
        {
            reponse.success = false;
            reponse.message = ex.getmessage();
        }
        return reponse;
    }

*/
}