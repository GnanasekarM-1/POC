/**
    An adaptor class encapsulating all the complex functionalities of the OptiMaxECO integration.
    This class is responsible to identify the service requested and to create the service instances accordingly.
    It throws a NoServiceFoundException if the service is not yet defined for the provider.
*/

public class WSCH_Provider_ECO_Adaptor implements WSCH_Provider_OptimizationInterface{
	
    public WSCH_IRealTimeOptimizer getRealTimeOptimizer(){

        //Type classType = Type.forName('WSCH_Provider_ECO_RealTimeOptimizer');
        Type classType = Type.forName('WSCH_Provider_ECO_SchedulingService');
        return (WSCH_IRealTimeOptimizer) classType.newInstance();
    }
    
    public WSCH_ITechnicianService getTechnicianService(){

        Type classType = Type.forName('WSCH_Provider_ECO_TechnicianService');
        return (WSCH_ITechnicianService) classType.newInstance();
    }    
    
    /*public WSCH_IJobService getJobService(){

        Type classType = Type.forName('WSCH_Provider_ECO_JobService');
        return (WSCH_IJobService) classType.newInstance();
    } */   
    
}