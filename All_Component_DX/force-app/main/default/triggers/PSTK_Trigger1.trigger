trigger PSTK_Trigger1 on SVMXC__Product_Stock__c (before insert, before update) 
{
    //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__Product_Stock__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'PSTK_Trigger execution is skipped.');
        return;
    }
    list<String> lstSubmoduleId = new list<String>();
    lstSubmoduleId.add('GLOB001');
    lstSubmoduleId.add('INVT001');
    map<String, map<String,String>> mapAllSettings = new  map<String, map<String,String>>();
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    mapAllSettings = commSettings.SVMX_getSettingList(lstSubmoduleId);
    Map<String, String> mapGlobalSettings = new Map<String, String>();
    Map<String, String> mapINVTSettings = new Map<String, String>();
    Boolean doCalculateCompositeKey = true;
    if(mapAllSettings != null && mapAllSettings.containskey('GLOB001')){
        mapGlobalSettings = mapAllSettings.get('GLOB001');
    }
    if(mapAllSettings != null && mapAllSettings.containskey('INVT001')){
        mapINVTSettings = mapAllSettings.get('INVT001');
        if(mapINVTSettings != null && mapINVTSettings.containskey('SET001') && mapINVTSettings.get('SET001') != null){
            doCalculateCompositeKey = Boolean.valueof(mapINVTSettings.get('SET001'));
        }
    }
    
    if(mapGlobalSettings != null && mapGlobalSettings.get('GBL009') != null && mapGlobalSettings.get('GBL009').toUpperCase() == 'TRUE'){

        //Added By GM on Jan022010  //To Enabled  trigger on Bulk Record Updates
        Set<String> locIds = new Set<String>();
        for (SVMXC__Product_Stock__c prodStk2 : Trigger.new){
            if(prodStk2.SVMXC__Location__c != null) 
                locIds.add(prodStk2.SVMXC__Location__c); 
        }
        Map<String,SVMXC__Site__c> resMap = new Map<String,SVMXC__Site__c>(); //SMAX_PRM_Inventory_Controller().SVMXC_isPartnerLocation(locIds);
        List<SVMXC__Site__c> locList = new List<SVMXC__Site__c>(); 
        if(locIds != null && locIds.size()>0)
            locList = [Select Id, SVMXC__IsPartner__c, SVMXC__Partner_Contact__c, SVMXC__Partner_Account__c  from SVMXC__Site__c  where Id in :locIds];
        if(locList != null && locList.size() >0){
            for (SVMXC__Site__c lc : locList){
                resMap.put(lc.Id, lc);  
            }
        }
        //Old Code is commented using //// by GM on Jan022010
        for (SVMXC__Product_Stock__c prodStk : Trigger.new){
            ////String[] res;
            if(prodStk.SVMXC__Location__c != null){
                if(resMap.containsKey(prodStk.SVMXC__Location__c)){
                ////res = new SMAX_PRM_Inventory_Controller().SVMXC_isPartnerLocation(prodStk.SVMXC__Location__c);
                ////if (res != null && res.get(0) == 'True') 
                ////{
                    if(resMap.get(prodStk.SVMXC__Location__c).SVMXC__IsPartner__c == 'True')
                        prodStk.SVMXC__IsPartnerRecord__c = true ;
                    prodStk.SVMXC__Partner_Contact__c = resMap.get(prodStk.SVMXC__Location__c).SVMXC__Partner_Contact__c; ////res.get(1);
                    prodStk.SVMXC__Partner_Account__c = resMap.get(prodStk.SVMXC__Location__c).SVMXC__Partner_Account__c; ////res.get(2);
                ////}
                }            
            }
        }
    }
    if(Trigger.isUpdate){
        for (Integer i =0;i<Trigger.old.size();i++)  
        {
            if(Trigger.new[i].SVMXC__ActualQtyBeforeUpdate__c != null && Trigger.old[i].SVMXC__Quantity2__c != Trigger.new[i].SVMXC__ActualQtyBeforeUpdate__c){
                trigger.new[i].adderror(Label.INVT001_TAG074);
            }
            // TODO synchronous negitive stock entry.
            Trigger.new[i].SVMXC__ActualQtyBeforeUpdate__c = null;
        }
    }
    if(Trigger.isBefore && doCalculateCompositeKey){
        for(SVMXC__Product_Stock__c objPS : Trigger.new){
            if(objPS.SVMXC__Product__c != null && objPS.SVMXC__Location__c != null && objPS.SVMXC__Status__c != null){
                objPS.SVMXC__ProdStockCompositeKey__c = objPS.SVMXC__Product__c+'_'+objPS.SVMXC__Location__c+'_'+ objPS.SVMXC__Status__c;
            }
        }
    }    
}