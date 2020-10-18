/**
    An adaptor class encapsulating all the complex functionalities of the ServicePower integration.
    This class is responsible to identify the service requested and to create the service instances accordingly.
    In addition it is required to maintain the session/lifecycle of the ServicePower services.
    It throws a NoServiceFoundException if the service is not yet defined for the provider.
*/

public class WSCH_Provider_SP_Adaptor implements WSCH_Provider_OptimizationInterface{

    public WSCH_IRealTimeOptimizer getRealTimeOptimizer(){

        Type classType = Type.forName('WSCH_Provider_SP_RealTimeOptimizer');
        return (WSCH_IRealTimeOptimizer) classType.newInstance();
    }
    
    public WSCH_ITechnicianService getTechnicianService(){
    	return null;
    }
}