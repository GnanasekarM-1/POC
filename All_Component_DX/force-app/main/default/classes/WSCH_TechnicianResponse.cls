public with sharing class WSCH_TechnicianResponse {
    
    private List<SVMXC__SVMX_Optimizer__c> techOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
    
    public List<SVMXC__SVMX_Optimizer__c> getTechOptimizer() {
        return techOptimizer;
    }
    
    public void setTechOptimizer(List<SVMXC__SVMX_Optimizer__c> techOptimizer) {
        this.techOptimizer = techOptimizer;
    }
}