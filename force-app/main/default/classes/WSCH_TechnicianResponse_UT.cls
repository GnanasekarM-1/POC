@isTest(seeAllData = false)
public with sharing class WSCH_TechnicianResponse_UT {
    
	static testMethod void testTechnicianResponse() {
		WSCH_TechnicianResponse techRes = new WSCH_TechnicianResponse();
		
		List<SVMXC__SVMX_Optimizer__c> techOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
		techRes.getTechOptimizer();
		techRes.setTechOptimizer(techOptimizer);
	}
}