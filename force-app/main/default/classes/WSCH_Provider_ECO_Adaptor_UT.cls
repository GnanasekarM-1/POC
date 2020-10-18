@isTest(seeAllData = false)
private class WSCH_Provider_ECO_Adaptor_UT{

    static testMethod void WSCH_Provider_ECO_Adaptor_UnitTest() {   
        WSCH_Provider_ECO_Adaptor ecoAdaptor = new WSCH_Provider_ECO_Adaptor();
        ecoAdaptor.getRealTimeOptimizer();
        ecoAdaptor.getTechnicianService();  
        //ecoAdaptor.getJobService();
    }
    
}