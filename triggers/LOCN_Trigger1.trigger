trigger LOCN_Trigger1 on SVMXC__Site__c (before insert, before update) 
{
     //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__Site__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'LOCN_Trigger1 execution is skipped.');
        return;
    }
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
    
    if(svmxSettingList != null && svmxSettingList.get('GBL009') != null && svmxSettingList.get('GBL009').toUpperCase() == 'TRUE')
    {
        //Added By GM on Jan022010  //To Enabled  trigger on Bulk Record Updates
        Set<String> locEnggIds = new Set<String>();
        String usrType = 'PowerPartner';
        Set<String> contIds = new Set<String>();
        
        for (SVMXC__Site__c loc2 : Trigger.new) 
        {
            String locId = loc2.SVMXC__Service_Engineer__c;
            if(locId != Null && locId.length()>0)
            {
                    locEnggIds.add(locId);
            } 
        }
        //Build result Map of all User Records and also identify set of Contact Ids to find accounts
        Map<String,User> resMapUsr = new Map<String,User>(); 
        List<User> usrList = new List<User>();
        if(locEnggIds != null && locEnggIds.size() >0)
            usrList = [Select Id, ContactId, UserType From User where UserType =: usrType And Id in :locEnggIds];
        if(usrList != null && usrList.size() >0)
        {
            for (User ur : usrList)
            {
                resMapUsr.put(ur.Id, ur);   
                contIds.add(ur.ContactId);
            }
        }
        
        //Build result Map of all Contacts/accounts 
        Map<String,Contact> resMapCont = new Map<String,Contact>(); 
        List<Contact> contList = new List<Contact>() ;
        if(contIds != null && contIds.size() >0 )
            contList = [select Id, AccountId from Contact where Id in :contIds];
        if(contList != null && contList.size() >0)
        {
            for (Contact ct : contList)
            {
                resMapCont.put(ct.Id, ct);  
            }
        }
        
        
        //Old Code is commented using //// by GM on Jan022010
        for (SVMXC__Site__c loc : Trigger.new) 
            {
                if(loc.SVMXC__Service_Engineer__c != null && resMapUsr.containsKey(loc.SVMXC__Service_Engineer__c) )
                {
                    String contId = resMapUsr.get(loc.SVMXC__Service_Engineer__c).ContactId; ////new SMAX_PRM_Inventory_Controller().SVMXC_getPartnerUserContact(loc.SVMXC__Service_Engineer__c);
                    if (contId != null && resMapCont.containsKey(contId) == true) 
                    {            
                        String locAcct = resMapCont.get(contId).AccountId;  ////new SMAX_PRM_Inventory_Controller().SVMXC_getAccountForContact(contId);
                        if (locAcct != null)  
                        {       
                            loc.SVMXC__IsPartnerRecord__c = true ;
                            loc.SVMXC__Partner_Contact__c = contId;
                            loc.SVMXC__Partner_Account__c = locAcct;
                        }
                    }
                }            
            }
    }
}