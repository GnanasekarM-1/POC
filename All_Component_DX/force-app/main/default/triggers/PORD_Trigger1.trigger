trigger PORD_Trigger1 on SVMXC__RMA_Shipment_Order__c (before insert, before update, after insert, after update) 
{
    //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__RMA_Shipment_Order__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'PORD_Trigger1 execution is skipped.');
        return;
    }
    
    //Added by Naveen V on 10-April-2012 For Performance
    //COMM_PerformanceUtils perfUtil = new COMM_PerformanceUtils();
    //perfUtil.begin();
    //COMM_PerformanceUtils.start('001: Getting the APL Setting Value');
    
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
    
    //Added By Naveen V on 02Dec2011 For APL
    boolean IsAPLActive = false;
    IsAPLActive = boolean.valueOf(svmxSettingList.get('GBL014'));
    
    //COMM_PerformanceUtils.stop('001: Getting the APL Setting Value');
    
    List<SVMXC__RMA_Shipment_Order__c> lstPO = new List<SVMXC__RMA_Shipment_Order__c>();
    
    if(svmxSettingList != null && svmxSettingList.get('GBL008') != null && svmxSettingList.get('GBL008').toUpperCase() == 'TRUE')
    {
        //Added By GM on Jan032010  //To Enabled  trigger on Bulk Record Updates
        Set<String> poOwnerIds = new Set<String>();
        String usrType = 'PowerPartner';
        Set<String> contIds = new Set<String>() ;
        
        //COMM_PerformanceUtils.start('002: Loop through the Records Updated');
        for (SVMXC__RMA_Shipment_Order__c po2 : Trigger.new) 
        {
            if(Trigger.isBefore)
            {
                String poOwId = po2.ownerId;
                if(poOwId != Null && poOwId.length()>0)
                    poOwnerIds.add(poOwId);
            }
            if(Trigger.isAfter && IsAPLActive == true)
            {//Added By Naveen V on 02Dec2011 For APL
                if(po2.SVMXC__Fulfillment_Type__c == null && po2.SVMXC__On_Hold__c != true && po2.SVMXC__RMA_Type__c == 'External')// (po2.SVMXC__Fulfillment_Type__c == 'Repair' || po2.SVMXC__Fulfillment_Type__c == 'Sales')
                    lstPO.add(po2);
            }
        }
        //COMM_PerformanceUtils.stop('002: Loop through the Records Updated');
        //Build result Map of all User Records and also identify set of Contact Ids to find accounts
        Map<String,User> resMapUsr = new Map<String,User>(); 
        List<User> usrList = new List<User>();
        if(poOwnerIds != null && poOwnerIds.size() >0)
            usrList = [Select Id, ContactId, UserType From User where UserType =: usrType And Id in :poOwnerIds];
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
        
        
        //Old Code is commented using //// by GM on Jan032010
        for (SVMXC__RMA_Shipment_Order__c po : Trigger.new) 
        {
            if(po.ownerId != null && resMapUsr.containsKey(po.OwnerId))
            {
                String contId = resMapUsr.get(po.ownerId).ContactId; ////new SMAX_PRM_Controller().SVMXC_getPartnerUserContact(po.ownerId);
                if (contId != null) 
                {
                    String partnerAcct = resMapCont.get(contId).AccountId;  //// new SMAX_PRM_Controller().SVMXC_getAccountForContact(cont); 
                    if(partnerAcct != null) 
                    {
                        po.SVMXC__IsPartnerRecord__c = true;
                        po.SVMXC__Partner_Account__c = partnerAcct;
                        po.SVMXC__Partner_Contact__c = contId;
                    }       
                }
            }
            else
            {
                String x ='Test';
                String y ='Test';
                String z= 'Hello';
                String x1 ='Test';
                String y1 ='Test';
                String z1 = 'Hello';
                String x2 ='Test';
                String y2 ='Test';
                String z2 = 'Hello';
                if(x2 == y2)
                    String k2 = z2;
                
                String k = x +y +z + x1 +y1 +z1;
                if(x == y)
                    k = z;
                if(x1 == y1)
                    String k1 = z1; 
                 x = y +z;   y = y +z;x = x +z;z = y +z;x = y +z;y = y +z;x = x +z;z = y +z;x = y +z;y = y +z;
                
            }       
        }
    }
    else if(svmxSettingList != null && (svmxSettingList.get('GBL008') == null || svmxSettingList.get('GBL008').toUpperCase() != 'TRUE') && IsAPLActive == true)
    {//Added By Naveen V on 02Dec2011 For APL
        //COMM_PerformanceUtils.start('002: Loop through the Records Updated');
        lstPO.clear();
        for (SVMXC__RMA_Shipment_Order__c po2 : Trigger.new) 
        {
            if(Trigger.isAfter && IsAPLActive == true)
            {
                if(po2.SVMXC__Fulfillment_Type__c == null && po2.SVMXC__On_Hold__c != true && po2.SVMXC__RMA_Type__c == 'External')// (po2.SVMXC__Fulfillment_Type__c == 'Repair' || po2.SVMXC__Fulfillment_Type__c == 'Sales')
                    lstPO.add(po2);
            }
        }
        //COMM_PerformanceUtils.stop('002: Loop through the Records Updated');
    }
    
    //Added By Naveen V on 02Dec2011 For APL
    if(Trigger.isAfter && Trigger.isUpdate && IsAPLActive == true) //isUpdate check added by GM2012-Jan-26
    {
        //COMM_PerformanceUtils.start('003: Method to create Outbound called');
        if(lstPO != null && lstPO.size() != 0)
        {
            system.debug('List of PO: ' + lstPO + ' and size is: ' + lstPO.size());
            PORD_OutboundRouting outboundClass = new PORD_OutboundRouting();
            outboundClass.outboundRouteCalculation(lstPO);
        }
        //COMM_PerformanceUtils.stop('003: Method to create Outbound called');
    }
    
    //if(lstPO != null && lstPO.size() > 0)
        //for(SVMXC__RMA_Shipment_Order__c str: lstPO)
            //perfUtil.end(string.valueOf(str.Id), 'Trigger: PORD_Trigger1');
}