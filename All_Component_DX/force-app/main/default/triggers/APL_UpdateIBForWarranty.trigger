trigger APL_UpdateIBForWarranty on SVMXC__Warranty__c (after insert, after update) 
{
    //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__Warranty__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'APL_UpdateIBForWarranty execution is skipped.');
        return;
    }
    //Added by Naveen V on 10-April-2012 For Performance
    //COMM_PerformanceUtils perfUtil = new COMM_PerformanceUtils();
    //perfUtil.begin();
    //COMM_PerformanceUtils.start('001: Getting the Setting Value');
    
    boolean runTrigger = false;
    public Map<String, String> svmxSettingList = new Map<String,String>();
    public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    
    svmxSettingList = commSettings.SVMX_getSettingList('IPRD002');
    if(svmxSettingList.containsKey('SET012'))
    {
        if(svmxSettingList.get('SET012') != null && boolean.valueOf(svmxSettingList.get('SET012')) == true)
        {
            svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
            if(boolean.valueOf(svmxSettingList.containsKey('GBL014')))
                runTrigger = boolean.valueOf(svmxSettingList.get('GBL014'));
            
            //COMM_PerformanceUtils.stop('001: Getting the Setting Value');
            
            List<ID> lstIBId = new List<ID>();
            if(runTrigger == true)
            {
                //COMM_PerformanceUtils.start('002: Loop through the Records Updated');
                for(SVMXC__Warranty__c R : Trigger.new)
                {
                    lstIBId.add(R.SVMXC__Installed_Product__c);        
                }
                //COMM_PerformanceUtils.stop('002: Loop through the Records Updated');
                
                //COMM_PerformanceUtils.start('003: Method to Update IB is Called');
                APL_Entitlement entitle = new APL_Entitlement();
                entitle.updateIBForInvalidWarranty(lstIBId);
                //COMM_PerformanceUtils.stop('003: Method to Update IB is Called');
            }
            
            //if(lstIBId != null && lstIBId.size() > 0)
                //for(ID str: lstIBId)
                    //perfUtil.end(string.valueOf(str), 'Trigger: APL_UpdateIBForWarranty');
        }
    }
}