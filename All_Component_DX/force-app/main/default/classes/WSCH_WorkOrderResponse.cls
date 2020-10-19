public with sharing class WSCH_WorkOrderResponse {

	private Datetime changetime;

	private List<SVMXC__Service_Order__c> lstWorkOrder = new List<SVMXC__Service_Order__c>();
	
	private List<WSCH_TechnicianEvent> lstTechEvent = new List<WSCH_TechnicianEvent>();
	
	private List<WSCH_Provider_SP_Push_Stubs.WorkItem> lstWorkItem = new List<WSCH_Provider_SP_Push_Stubs.WorkItem>();
	
	private Boolean isDispatched;
	
	public List<SVMXC__Service_Order__c> getLstWorkOrder() {
		return lstWorkOrder;
	}
	
	public void setLstWorkOrder(List<SVMXC__Service_Order__c> lstWorkOrder) {
		this.lstWorkOrder = lstWorkOrder;
	}
	
	public List<WSCH_TechnicianEvent> getLstTechEvent() {
		return lstTechEvent;
	}
	
	public void setLstTechEvent(List<WSCH_TechnicianEvent> lstTechEvent) {
		this.lstTechEvent = lstTechEvent;
	}
	
	public List<WSCH_Provider_SP_Push_Stubs.WorkItem> getLstWorkItem(){
		return lstWorkItem;
	}	
	
	public void setLstWorkItem(List<WSCH_Provider_SP_Push_Stubs.WorkItem> lstWorkItem){
		this.lstWorkItem = lstWorkItem;
	}

	public void setChangeTime(Datetime changeTime) {
		this.changeTime = changeTime;
	}
	
	public Datetime getChangeTime() {
		return changeTime;
	}
	
	public void setIsDispatched(Boolean isDispatched) {
		this.isDispatched = isDispatched;
	}
	
	public Boolean isDispatched(){
		return this.isDispatched;
	}
}