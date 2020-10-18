/**
    A common interface to define all the operations supported by the technician functionality/plugin.
    All the service providers who are providing real time optimization should implement this interface.
*/
public interface WSCH_ITechnicianService {
	
	WSCH_TechnicianResponse manageTechnicians(List<SVMXC__SVMX_Optimizer__c> technicians);	
    
}