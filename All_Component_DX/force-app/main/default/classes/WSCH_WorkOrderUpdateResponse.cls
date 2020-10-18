public with sharing class WSCH_WorkOrderUpdateResponse {
	
	private WSCH_WorkOrderResponse woResponse;
	private String timeStampOut;
	private boolean more;

	
	public WSCH_WorkOrderResponse getWoResponse() {
		return this.woResponse;
	}
	
	public void setWoResponse(WSCH_WorkOrderResponse woResponse) {
		this.woResponse = woResponse;
	}
	
	public String getTimeStampOut() {
		return this.timeStampOut;
	}
	
	public void setTimeStampOut(String timeStampOut) {
		this.timeStampOut = timeStampOut;
	}
	
	public boolean isMore() {
		return this.more;
	}

	public void setMore(boolean more) {
		this.more = more;
	}
}