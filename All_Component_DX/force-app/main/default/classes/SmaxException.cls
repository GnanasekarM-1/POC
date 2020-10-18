public class SmaxException extends Exception
{
    Exception ex;
    String strMessage = null;
    Map<String, String> mapCustomMsgs= new Map<String, String>();
    
    public SmaxException(Map<String, String> mapMessage, Exception exc)
    {
        ex = exc;
        if(mapMessage != null && mapMessage.size() >= 0)
        {
            for(String strMsg : mapMessage.keySet())
            {
                String strMsgTitle = strMsg + ' : ' + mapMessage.get(strMsg) + '\n';
                setMessage(strMsgTitle);
            }
        }
    }
    
    public INTF_WebServicesDef.SVMXError getDetailedErrorMsg()
    {
        INTF_WebServicesDef.SVMXError error = new INTF_WebServicesDef.SVMXError();
        List<String> lstDMLExceptionDetail = new List<String>();
        system.debug(LoggingLevel.WARN, 'Custom Error Message' + strMessage);    
        String strCorrectiveActn = /*'\nCause of Exception : ' + ex.getCause().getMessage() +*/ '\nError type : ' + ex.getTypeName() + '\nError Message : ' + ex.getMessage() + '\nLine Number : ' + ex.getLineNumber() + '\nStack Trace : ' + ex.getStackTraceString();
        error.errorTitle = strMessage;
        error.errorMsg = ex.getMessage();
        error.errorType = ex.getTypeName();
        List<String> lstErrFields;
        Set<String> setExceptions = new Set<String>{'System.DMLException', 'System.EmailExceptions'};
        if(setExceptions.contains(ex.getTypeName()))
        {
            for(Integer i =0; i<getNumDml(); i++)
            {
                lstErrFields = new List<String>();
                lstErrFields = ex.getDmlFieldNames(i);
                lstDMLExceptionDetail.add('\nRecord ID : ' + ex.getDmlId(i) + '\nDML Error Message : ' + ex.getDmlMessage(i) + '\nDML Type : ' + ex.getDmlType(i) + '\nErroneous Fields :' + lstErrFields);
            }
            strCorrectiveActn += 'DML Exception Details : ' + lstDMLExceptionDetail;
        }
        error.correctiveAction = strCorrectiveActn;
        return error;
    }
    
    override public void setMessage(String strMsgTitle)
    {
    	if(strMessage != null)
    		strMessage += strMsgTitle;
    	else	
        	strMessage = strMsgTitle;  
    }
}