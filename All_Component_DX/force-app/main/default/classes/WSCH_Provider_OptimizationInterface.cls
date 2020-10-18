/**
	A common interface for all the service provider adaptors. It defines all the generic methods such as get
	services related to various functionalities. In addition to obtaining the services, there may be other common 
	definitions such as to check if a service is available, or if the service provider is online or offline etc.
*/

public interface WSCH_Provider_OptimizationInterface{
    
	WSCH_IRealTimeOptimizer getRealTimeOptimizer();
	
	WSCH_ITechnicianService getTechnicianService();
	
	//WSCH_IJobService getJobService();
}