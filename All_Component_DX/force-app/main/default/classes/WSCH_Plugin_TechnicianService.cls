/**
    The Plugin to handle only RealTimeOptimization related functionalities such as adding and modifying technicians.
    Plugins are simple Named API?s to provide a cleaner interface to handle various functionalities.
    TechnicianServicerPlugin would invoke the ServiceProviderAdaptor to get a handle to the configured service providers Technician service. Once the handle is obtained, it invokes the corresponding methods on the handle.
    It would also handle general exceptions thrown by ServiceProviderAdaptor such as NoServiceFoundException.
*/
public with sharing class WSCH_Plugin_TechnicianService {

	public static void manageTechnicians(List<SVMXC__SVMX_Optimizer__c> technicians){
        try{ 
            WSCH_ITechnicianService technicianService = WSCH_Provider_OptimizationFactory.getTechnicianService();
            WSCH_AuditLogger.debug('WSCH_Plugin_TechnicianService::manageTechnicians()::start, heap size before manageTechnicians() call - ' + Limits.getHeapSize());
            WSCH_TechnicianResponse techResponse = technicianService.manageTechnicians(technicians);
            WSCH_AuditLogger.debug('WSCH_Plugin_TechnicianService::manageTechnicians()::techResponse : ' + techResponse);
            WSCH_AuditLogger.debug('WSCH_Plugin_TechnicianService::manageTechnicians()::start, No of Queries used in this transaction so far: ' + Limits.getQueries());
            WSCH_AuditLogger.debug('WSCH_Plugin_TechnicianService::manageTechnicians()::start, heap size after manageTechnicians() call- ' + Limits.getHeapSize());
            WSCH_ECO_WorkOrderEventHelper.updateTechnicianOptimizer(techResponse.getTechOptimizer());
        } catch(WSCH_ServiceNotFoundException ex){
            WSCH_AuditLogger.error('WSCH_Plugin_TechnicianService::manageTechnicians():Service not found for this organization. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        } catch (Exception ex){
            WSCH_AuditLogger.error('WSCH_Plugin_TechnicianService::manageTechnicians(): Exception raised while managing technicians() call. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }		
	}
}