public class SFM_Migrator {
	String GMapAPI;
	String clientId;
	public String returnURL= '';
	public String getreturnURL() {
	return returnURL;
	}
	public Map<String, String> PageHeaderMap  = new Map<String, String>();

	public SFM_Migrator(){
		PageHeaderMap  = ApexPages.currentPage().getParameters();
		if(PageHeaderMap.size()>0)
		{
			if(PageHeaderMap.containskey('SVMX_retURL'))
			returnURL=  PageHeaderMap.get('SVMX_retURL'); 
		}
	}

	public String getMySessionId() {
		return UserInfo.getSessionId();
	}
  

}