trigger PREQ_Trigger1 on SVMXC__Parts_Request__c (before insert,before update) {
    
     //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__Parts_Request__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'PREQ_Trigger1 execution is skipped.');
        return;
    }
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
    
    if(svmxSettingList != null && svmxSettingList.get('GBL009') != null && svmxSettingList.get('GBL009').toUpperCase() == 'TRUE')
    {
        //Added By GM on Jan032010  //To Enabled  trigger on Bulk Record Updates
        Set<String> locIds = new Set<String>();
        for (SVMXC__Parts_Request__c prRq2 : Trigger.new)  
        {
            if(prRq2.SVMXC__Requested_From__c != null)
                locIds.add(prRq2.SVMXC__Requested_From__c); 
            if(prRq2.SVMXC__Required_At_Location__c != null) 
                locIds.add(prRq2.SVMXC__Required_At_Location__c); 
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
        for (SVMXC__Parts_Request__c prRq : Trigger.new)  
        {
            Boolean chkAnotherLoc =true;
            String[] res;
            if(prRq.SVMXC__Requested_From__c != null)
            {
                if(resMap.containsKey(prRq.SVMXC__Requested_From__c))
                {
                ////res = new SMAX_PRM_Inventory_Controller().SVMXC_isPartnerLocation(prRq.SVMXC__Requested_From__c);
                ////if (res != null && res.get(0) == 'True') 
                ////{
                    if(resMap.get(prRq.SVMXC__Requested_From__c).SVMXC__IsPartner__c == 'True')
                        prRq.SVMXC__IsPartnerRecord__c = true ;
                    prRq.SVMXC__Partner_Contact__c = resMap.get(prRq.SVMXC__Requested_From__c).SVMXC__Partner_Contact__c; ////res.get(1);
                    prRq.SVMXC__Partner_Account__c = resMap.get(prRq.SVMXC__Requested_From__c).SVMXC__Partner_Account__c; ////res.get(2);
                    chkAnotherLoc =false;
                ////}
                }
                
            }
            if(chkAnotherLoc && prRq.SVMXC__Required_At_Location__c != null)
            {
                if(resMap.containsKey(prRq.SVMXC__Required_At_Location__c))
                {
                ////res = new SMAX_PRM_Inventory_Controller().SVMXC_isPartnerLocation(prRq.SVMXC__Required_At_Location__c);
                ////if (res != null && res.get(0) == 'True') 
                ////{
                    if(resMap.get(prRq.SVMXC__Required_At_Location__c).SVMXC__IsPartner__c == 'True')
                        prRq.SVMXC__IsPartnerRecord__c = true ;
                    prRq.SVMXC__Partner_Contact__c = resMap.get(prRq.SVMXC__Required_At_Location__c).SVMXC__Partner_Contact__c; ////res.get(1);
                    prRq.SVMXC__Partner_Account__c = resMap.get(prRq.SVMXC__Required_At_Location__c).SVMXC__Partner_Account__c; ////res.get(2);
                ////}
                }            
            }   
            
        }   
    }
}