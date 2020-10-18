public with sharing class SVMXMessageUtils {
    
    public SVMXC.SFM_WrapperDef.SVMXMessage buildExceptionMessage(Exception ex, String strMessage, String strExceptionContext){
        String strDefaultMessage = system.label.COMM001_TAG077;
        String strMessageInfo = '';
        String strDetails = strExceptionContext+'\n';
        SVMXC.SFM_WrapperDef.SVMXMessage message;
        System.debug('Exception: ' + ex);
        if(ex.getTypeName() == 'System.DmlException'){
            if(strMessage != null && strMessage.length() > 0 ){
                strMessageInfo = strMessage;
            }
            else if(ex.getDmlMessage(0) != null){
                strMessageInfo = ex.getDmlMessage(0);
            }
            else{
                strMessageInfo = strDefaultMessage;
            }
            //Build Details 
            for (Integer i = 0; i < ex.getNumDml(); i++) 
            {
                strDetails += ex.getDmlIndex(i);
                if(ex.getDmlId(i) != null)
                    strDetails += '-'+ex.getDmlId(i);
                if(ex.getDmlFieldNames(i) != null){
                    strDetails += '-'+String.valueof(ex.getDmlFieldNames(i));
                }
                else if(ex.getDmlFields(i) != null){
                    strDetails += '-'+String.valueof(ex.getDmlFields(i));
                }
                if(ex.getDmlType(i) != null)
                    strDetails += '-'+ex.getDmlType(i);
                strDetails += '-'+  ex.getDmlMessage(i)+'\n';
            }
            message = new SVMXC.SFM_WrapperDef.SVMXMessage(strMessageInfo,strDetails);
        }else if(ex.getTypeName().contains('SecurityAccessException') || ex.getTypeName().contains('NoAccessException') || Test.isRunningTest()){//Added for BAC-4094
            if(strMessage != null && strMessage.length() > 0 ){
                strMessageInfo = strMessage;
            }
            else if(ex.getMessage() != null){
                strMessageInfo = ex.getMessage();
            }
            else{
                strMessageInfo = strDefaultMessage;
            }
            message = new SVMXC.SFM_WrapperDef.SVMXMessage(strMessageInfo,strDetails);
        }
        return message;
    } 
}