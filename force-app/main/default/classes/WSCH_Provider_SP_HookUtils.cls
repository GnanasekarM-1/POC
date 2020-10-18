/**
@ Name WSCH_Provider_SP_HookUtils
@ Author Anantha Kumar
@ Description This utils class reads the setting and instantiates the appropriate HookFactory and return the corresponding hook.
*/
public with sharing class WSCH_Provider_SP_HookUtils {
    
    public static WSCH_Provider_SP_HookFactory getHookFactory() {
        WSCH_Provider_SP_HookFactory factory;
        try{
            String settingValue = WSCH_CommonUtils.getSettingValue('DCON004','SET005');
            system.debug('Setting Value '+settingValue);
            if(String.isNotEmpty(settingValue)) {
                Type t = Type.forName(settingValue);
                factory = (WSCH_Provider_SP_HookFactory) t.newInstance();
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_HookUtils:getHookFactory() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }finally{
            if(null == factory){
                factory = new WSCH_Provider_SP_HookFactory();
                WSCH_AuditLogger.info('Default hook factory');
                
            }
        }
        return factory;
    }
    
    public static WSCH_ICalloutHook getCalloutHook(String api){
        WSCH_Provider_SP_HookFactory factory = getHookFactory();
        try{
            if(api.equalsIgnoreCase('bookJob')) {
                return (WSCH_ICalloutHook)factory.getBookJobHook();
            } else if(api.equalsIgnoreCase('OfferAppts')) {
                return (WSCH_ICalloutHook)factory.getAppointmentsHook();
            } else if(api.equalsIgnoreCase('BookAppt')) {
                return (WSCH_ICalloutHook)factory.getBookAppointmentHook();
            } else if(api.equalsIgnoreCase('ChangeWorkItemStatus')) {
                return (WSCH_ICalloutHook)factory.getChangeWorkItemStatusHook();
            } else if(api.equalsIgnoreCase('GetJobStatus')) {
                return (WSCH_ICalloutHook)factory.getJobStatusHook();
            } else if(api.equalsIgnoreCase('EmpAddAct')) {
                return (WSCH_ICalloutHook)factory.getStdActivityCreateHook();
            } else if(api.equalsIgnoreCase('ActDelete')) {
                return (WSCH_ICalloutHook)factory.getStdActivityDeleteHook();
            } else if(api.equalsIgnoreCase('ActUpdate')) {
                return (WSCH_ICalloutHook)factory.getStdActivityUpdateHook();
            } else if(api.equalsIgnoreCase('UpdateJob')) {
                return (WSCH_ICalloutHook)factory.getUpdateJobHook();
            } else if(api.equalsIgnoreCase('CancelJob')) {
                return (WSCH_ICalloutHook)factory.getCancelJobHook();
            } else if(api.equalsIgnoreCase('ForceFixJob')) {
                return (WSCH_ICalloutHook)factory.getForceFixJobHook();
            }
            /*else if(api.equalsIgnoreCase('BookDependencyGroup')) {
                return (WSCH_ICalloutHook)factory.getBookDependencyGroup();
            }*/
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_HookUtils:getCalloutHook() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return new WSCH_DefaultCalloutHook();
            WSCH_AuditLogger.info('Default hook factory');
        }
        return new WSCH_DefaultCalloutHook();
    } 

}