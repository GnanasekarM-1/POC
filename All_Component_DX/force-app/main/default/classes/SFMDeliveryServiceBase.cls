public virtual class SFMDeliveryServiceBase extends SVMXRestBase{
	
	protected SFMDeliveryServiceBase(RestRequest req, RestResponse res){
		super(req, res, 'SFMDeliveryServiceIntf');
	}
	
	protected SFMDeliveryServiceBase(){}
	
	override public Object invokeMethod(SVMXRestMethodInfo mi){
		Object res = null;
		
		if(mi.MethodName.equals('getPageLayout')) res = getPageLayout();
		else if(mi.MethodName.equals('getPageLayoutOlder')) res = getPageLayoutOlder();
		else if(mi.MethodName.equals('getPageLayoutOldest')) res = getPageLayoutOldest();
		
		else if(mi.MethodName.equals('getPageData')) res = getPageData();
		else if(mi.MethodName.equals('getPageDataOlder')) res = getPageDataOlder();
		else if(mi.MethodName.equals('getPageDataOldest')) res = getPageDataOldest();
		
		else if(mi.MethodName.equals('retrieveDisplayTags')) res = retrieveDisplayTags();
		else if(mi.MethodName.equals('retrieveDisplayTagsOlder')) res = retrieveDisplayTagsOlder();
		else if(mi.MethodName.equals('retrieveDisplayTagsOldest')) res = retrieveDisplayTagsOldest();
		
		else if(mi.MethodName.equals('retrieveSettings')) res = retrieveSettings();
		else if(mi.MethodName.equals('retrieveSettingsOlder')) res = retrieveSettingsOlder();
		else if(mi.MethodName.equals('retrieveSettingsOldest')) res = retrieveSettingsOldest();
		
		else if(mi.MethodName.equals('getUserInfo')) res = getUserInfo();
		else if(mi.MethodName.equals('getUserInfoOlder')) res = getUserInfoOlder();
		else if(mi.MethodName.equals('getUserInfoOldest')) res = getUserInfoOldest();
		
		else if(mi.MethodName.equals('getLookupConfig')) res = getLookupConfig();
		else if(mi.MethodName.equals('getLookupConfigOlder')) res = getLookupConfigOlder();
		else if(mi.MethodName.equals('getLookupConfigOldest')) res = getLookupConfigOldest();
		
		else if(mi.MethodName.equals('saveTarget')) res = saveTarget();
		else if(mi.MethodName.equals('saveTargetOlder')) res = saveTargetOlder();
		else if(mi.MethodName.equals('saveTargetOldest')) res = saveTargetOldest();
		
		else if(mi.MethodName.equals('getNextStepInfo')) res = getNextStepInfo();
		else if(mi.MethodName.equals('getNextStepInfoOlder')) res = getNextStepInfoOlder();
		else if(mi.MethodName.equals('getNextStepInfoOldest')) res = getNextStepInfoOldest();
		
		else if(mi.MethodName.equals('getSnippetForEvent')) res = getSnippetForEvent();
		else if(mi.MethodName.equals('getSnippetForEventOlder')) res = getSnippetForEventOlder();
		else if(mi.MethodName.equals('getSnippetForEventOldest')) res = getSnippetForEventOldest();
		
		else if(mi.MethodName.equals('addRecords')) res = addRecords();
		else if(mi.MethodName.equals('addRecordsOlder')) res = addRecordsOlder();
		else if(mi.MethodName.equals('addRecordsOldest')) res = addRecordsOldest();
		
		else if(mi.MethodName.equals('getBubbleData')) res = getBubbleData();
		else if(mi.MethodName.equals('getBubbleDataOlder')) res = getBubbleDataOlder();
		else if(mi.MethodName.equals('getBubbleDataOldest')) res = getBubbleDataOldest();
		
		else if(mi.MethodName.equals('getObjectDescription')) res = getObjectDescription();
		else if(mi.MethodName.equals('getObjectDescriptionOlder')) res = getObjectDescriptionOlder();
		else if(mi.MethodName.equals('getObjectDescriptionOldest')) res = getObjectDescriptionOldest();
		
		else if(mi.MethodName.equals('getRecordTypes')) res = getRecordTypes();
		else if(mi.MethodName.equals('getRecordTypesOlder')) res = getRecordTypesOlder();
		else if(mi.MethodName.equals('getRecordTypesOldest')) res = getRecordTypesOldest();

		else if(mi.MethodName.equals('getLayoutDescription')) res = getLayoutDescription();
		else if(mi.MethodName.equals('getLayoutDescriptionOlder')) res = getLayoutDescriptionOlder();
		else if(mi.MethodName.equals('getLayoutDescriptionOldest')) res = getLayoutDescriptionOldest();
		
		else if(mi.MethodName.equals('getLookupData')) res = getLookupData();
		else if(mi.MethodName.equals('getLookupDataOlder')) res = getLookupDataOlder();
		else if(mi.MethodName.equals('getLookupDataOldest')) res = getLookupDataOldest();
        
        //BAC-5929 Delivery Rest Service
		else if(mi.MethodName.equals('getLookupConfiguration')) res = getLookupConfiguration();
		else if(mi.MethodName.equals('getConfigInfo')) res = getConfigInfo();
		else if(mi.MethodName.equals('getIsQualify')) res = getIsQualify();
        //BAC-6067
		else if(mi.MethodName.equals('resolveLookUpDisplayValue')) res = resolveLookUpDisplayValue();
		
		else res = invokeMissingMethod();
		
		return res;
	}
	
	public virtual Object getPageLayout() { return null; }
	public virtual Object getPageLayoutOlder() { return getPageLayout(); }
	public virtual Object getPageLayoutOldest() { return getPageLayoutOlder(); }
	
	public virtual Object getUserInfo() { return null; }
	public virtual Object getUserInfoOlder() { return getUserInfo(); }
	public virtual Object getUserInfoOldest() { return getUserInfoOlder(); }
	
	public virtual Object getLookupConfig() { return null; }
	public virtual Object getLookupConfigOlder() { return getLookupConfig(); }
	public virtual Object getLookupConfigOldest() { return getLookupConfigOlder(); }
	
	public virtual Object getPageData() { return null; }
	public virtual Object getPageDataOlder() { return getPageData(); }
	public virtual Object getPageDataOldest() { return getPageDataOlder(); }
	
	public virtual Object retrieveDisplayTags() { return null; }
	public virtual Object retrieveDisplayTagsOlder() { return retrieveDisplayTags(); }
	public virtual Object retrieveDisplayTagsOldest() { return retrieveDisplayTagsOlder(); }
	
	public virtual Object retrieveSettings() { return null; }
	public virtual Object retrieveSettingsOlder() { return retrieveSettings(); }
	public virtual Object retrieveSettingsOldest() { return retrieveSettingsOlder(); }
	
	public virtual Object saveTarget() { return null; }
	public virtual Object saveTargetOlder() { return saveTarget(); }
	public virtual Object saveTargetOldest() { return saveTargetOlder(); }
	
	public virtual Object getNextStepInfo() { return null; }
	public virtual Object getNextStepInfoOlder() { return getNextStepInfo(); }
	public virtual Object getNextStepInfoOldest() { return getNextStepInfoOlder(); }
	
	public virtual Object getSnippetForEvent() { return null; }
	public virtual Object getSnippetForEventOlder() { return getSnippetForEvent(); }
	public virtual Object getSnippetForEventOldest() { return getSnippetForEventOlder(); }
	
	public virtual Object addRecords() { return null; }
	public virtual Object addRecordsOlder() { return addRecords(); }
	public virtual Object addRecordsOldest() { return addRecordsOlder(); }
	
	public virtual Object getBubbleData() { return null; }
	public virtual Object getBubbleDataOlder() { return getBubbleData(); }
	public virtual Object getBubbleDataOldest() { return getBubbleDataOlder(); }
	
	public virtual Object getObjectDescription() { return null; }
	public virtual Object getObjectDescriptionOlder() { return getObjectDescription(); }
	public virtual Object getObjectDescriptionOldest() { return getObjectDescriptionOlder(); }
	
	public virtual Object getRecordTypes() { return null; }
	public virtual Object getRecordTypesOlder() { return getRecordTypes(); }
	public virtual Object getRecordTypesOldest() { return getRecordTypesOlder(); }
	
	public virtual Object getRecordTypes2() { return null; }
	public virtual Object getRecordTypesOlder2() { return getRecordTypes2(); }
	public virtual Object getRecordTypesOldest2() { return getRecordTypesOlder2(); }
	
	public virtual Object getLayoutDescription() { return null; }
	public virtual Object getLayoutDescriptionOlder() { return getLayoutDescription(); }
	public virtual Object getLayoutDescriptionOldest() { return getLayoutDescriptionOlder(); }
	
	public virtual Object getLookupData() { return null; }
	public virtual Object getLookupDataOlder() { return getLookupData(); }
	public virtual Object getLookupDataOldest() { return getLookupDataOlder(); }
    
    //BAC-5929 Delivery Rest Service
	public virtual Object getLookupConfiguration() { return getLookupConfiguration(); }
	public virtual Object getConfigInfo() { return getConfigInfo(); }
	public virtual Object getIsQualify() { return getIsQualify(); }
    //BAC-6067
	public virtual Object resolveLookUpDisplayValue() { return resolveLookUpDisplayValue(); }
}