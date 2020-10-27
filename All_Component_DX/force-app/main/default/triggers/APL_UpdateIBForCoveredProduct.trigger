trigger APL_UpdateIBForCoveredProduct on SVMXC__Service_Contract_Products__c (after insert, after update) 
{
       as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__Service_Contract_Products__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'APL_UpdateIBForCoveredProduct execution is skipped.');
        return;
    }
    //Added by Naveen V on 10-April-2012 For Performance
    //COMM_PerformanceUtils perfUtil = new COMM_PerformanceUtils();
    //perfUtil.begin();
    //COMM_PerformanceUtils.start('001: Getting the Setting Value');
    
    boolean runTrigger = false;
    public Map<String, String>   = new Map<String,String>();
    public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
    if(boolean.valueOf(svmxSettingList.containsKey('GBL014')))
        runTrigger = boolean.valueOf(svmxSettingList.get('GBL014'));
    
    //COMM_PerformanceUtils.stop('001: Getting the Setting Value');
    
    List<String> LstCP = new List<String>();
    
    if(runTrigger == true)
    {
        //COMM_PerformanceUtils.start('002: Loop through the Records Updated');
        for(SVMXC__Service_Contract_Products__c CP : Trigger.new)
        {
            LstCP.add(CP.Id);
        }
        //COMM_PerformanceUtils.stop('002: Loop through the Records Updated');
        
        //COMM_PerformanceUtils.start('003: Method to Update IB is Called');
        APL_Entitlement entitle = new APL_Entitlement();
        entitle.updateIBForCPs(LstCP);
        //COMM_PerformanceUtils.stop('003: Method to Update IB is Called');
    }
    
    //if(LstCP != null && LstCP.size() > 0)
        //for(string str: LstCP)
            //perfUtil.end(str, 'Trigger: APL_UpdateIBForCoveredProduct');
}