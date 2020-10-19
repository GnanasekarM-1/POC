trigger SADJ_Trigger1 on SVMXC__Stock_Adjustment__c (before insert, before update)
{
    //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__Stock_Adjustment__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'SADJ_Trigger1 execution is skipped.');
        return;
    }
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
    
    if(svmxSettingList != null && svmxSettingList.get('GBL009') != null && svmxSettingList.get('GBL009').toUpperCase() == 'TRUE')
    {
        //Added By GM on Jan032010  //To Enabled  trigger on Bulk Record Updates
        Set<String> locIds = new Set<String>();
        for (SVMXC__Stock_Adjustment__c stkAdj2 : Trigger.new)  
        {
            if(stkAdj2.SVMXC__Location__c != null)
                locIds.add(stkAdj2.SVMXC__Location__c); 
            
        }
        Map<String,SVMXC__Site__c> resMap = new Map<String,SVMXC__Site__c>(); 
        List<SVMXC__Site__c> locList = new List<SVMXC__Site__c>() ; 
        if(locIds != null && locIds.size()>0)
            locList = [Select Id, SVMXC__IsPartner__c, SVMXC__Partner_Contact__c, SVMXC__Partner_Account__c  from SVMXC__Site__c  where Id in :locIds];
        if(locList != null && locList.size() >0)
        {
            for (SVMXC__Site__c lc : locList)
            {
                resMap.put(lc.Id, lc);  
            }
        }
        
        //Old Code is commented using //// by GM on Jan032010
        for (SVMXC__Stock_Adjustment__c stkAdj : Trigger.new)  
        {
            if(stkAdj.SVMXC__Location__c != null)
            {
                if(resMap.containsKey(stkAdj.SVMXC__Location__c))
                {
                ////String[] res = new SMAX_PRM_Inventory_Controller().SVMXC_isPartnerLocation(stkAdj.SVMXC__Location__c);
                ////if (res != null && res.get(0) == 'True') 
                ////{ 
                    if(resMap.get(stkAdj.SVMXC__Location__c).SVMXC__IsPartner__c == 'True')
                        stkAdj.SVMXC__IsPartnerRecord__c = true ;
                    stkAdj.SVMXC__Partner_Contact__c = resMap.get(stkAdj.SVMXC__Location__c).SVMXC__Partner_Contact__c; ////res.get(1);
                    stkAdj.SVMXC__Partner_Account__c = resMap.get(stkAdj.SVMXC__Location__c).SVMXC__Partner_Account__c; ////res.get(2);
                ////}
                }
                
            }
        }   
    }
}