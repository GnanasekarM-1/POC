/**
	A factory to return the require service provider service instance for a customer organization.
	The factory fetches the adaptor instance and then using the adaptor instance returns the service requested.
	For ex: If ServicePower is the configured adaptor for the customer and IRealTimeOptimizer is the required service,
	it fetches the ServicePowerAdaptor and invokes the method to fetch the required service. This class encapsulates
	the logic to identify the appropriate service to get and the appropriate service provider to use.
*/

public class WSCH_Provider_OptimizationFactory{

    public static WSCH_IRealTimeOptimizer getRealTimeOptimizer(){
       String providerType = getConfig().get('RTO.ServiceProvider.Name');
       if (String.isNotEmpty(providerType)) {
       		return getServiceProvider(providerType).getRealTimeOptimizer();
       }
       throw new WSCH_ServiceNotFoundException('No service provider found for mentioned provider type');
    }
    
	public static WSCH_ITechnicianService getTechnicianService(){
       String providerType = getConfig().get('RTO.ServiceProvider.Name');
       if (String.isNotEmpty(providerType)) {
       		return getServiceProvider(providerType).getTechnicianService();
       }
       throw new WSCH_ServiceNotFoundException('No service provider found for mentioned provider type');		
	}    

	/*public static WSCH_IJobService getJobService(){
       String providerType = getConfig().get('RTO.ServiceProvider.Name');
       if (String.isNotEmpty(providerType)) {
       		return getServiceProvider(providerType).getJobService();
       }
       throw new WSCH_ServiceNotFoundException('No service provider found for mentioned provider type');		
	}*/   

	private static WSCH_Provider_OptimizationInterface getServiceProvider(String providerType){
        if(providerType.equalsIgnoreCase('_SERVICE_POWER')){
	    	Type classType = Type.forName('WSCH_Provider_SP_Adaptor');
    		return (WSCH_Provider_OptimizationInterface) classType.newInstance();
        } else if(providerType.equalsIgnoreCase('_OPTIMAX_ECO')){
	    	Type classType = Type.forName('WSCH_Provider_ECO_Adaptor');
    		return (WSCH_Provider_OptimizationInterface) classType.newInstance();
        }
        throw new WSCH_Exception('No Provider Found');
    }
    
    private static Map<String,String> getConfig(){
        //TODO : This is a dummy implementation now.
        Map<String,String> configMap = new Map<String,String>();
        String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
        if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO')){
        	configMap.put('RTO.ServiceProvider.Name', '_OPTIMAX_ECO');
        }else{
        	configMap.put('RTO.ServiceProvider.Name', '_SERVICE_POWER');
        }
        return configMap;
    }
}