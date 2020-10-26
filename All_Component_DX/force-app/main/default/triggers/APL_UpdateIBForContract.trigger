trigger APL_UpdateIBForContract on SVMXC__Service_Contract__c (after update) 
{
    //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__Service_Contract__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'APL_UpdateIBForContract execution is skipped.');
        return;
    }
    boolean runTrigger = false;
    public Map<String, String> svmxSettingList = new Map<String,String>();
    public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
    if(boolean.valueOf(svmxSettingList.containsKey('GBL014')))
        runTrigger = boolean.valueOf(svmxSettingList.get('GBL014'));
    
    List<ID> lstSCID = new List<ID>();
    
    if(runTrigger == true)
    {
        map<ID, SVMXC__Service_Contract__c> mapOldSCIdToSC = new map<ID, SVMXC__Service_Contract__c>();
        
        if(trigger.isUpdate)
            mapOldSCIdToSC = Trigger.oldMap;
        
        //Bulk handle
        for(SVMXC__Service_Contract__c R : Trigger.new)
        {
            if(trigger.isInsert)
                lstSCID.add(R.Id);
            else if(trigger.isUpdate)
            {
                if(mapOldSCIdToSC.get(R.Id).SVMXC__End_Date__c != R.SVMXC__End_Date__c || mapOldSCIdToSC.get(R.Id).SVMXC__Start_Date__c != R.SVMXC__Start_Date__c || mapOldSCIdToSC.get(R.Id).SVMXC__Exchange_Type__c != R.SVMXC__Exchange_Type__c)
                {
                    lstSCID.add(R.Id);
                }
            }
        }  
        APL_Entitlement entitle = new APL_Entitlement();
        if(lstSCID != null && lstSCID.size() > 0)
        entitle.updateIBForContract(lstSCID);
    }
}