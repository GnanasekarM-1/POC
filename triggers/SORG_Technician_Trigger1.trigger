trigger SORG_Technician_Trigger1 on SVMXC__Service_Group_Members__c (before insert, after insert,before update, before delete) {

    /* Variable definitions */ 
    Boolean isValid = true;
    String isCheckUniqueness;
    
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    list<string> lstSubModules = new list<string>{'GLOB001','OMAX001','OMAX003','SLAT003','PREV004','IPRD009','EVER007','IPRD003','DCON002','DCON003','DCON004','WORD023', 'WORD012','IPAD018','SORG001'};
    map<string, Map<String, String>> AllsvmxSettingList = new map<string, Map<String, String>>();
    
    //create settings cache..
    if(SVMX_Constants.AllsvmxSettingList == NULL || SVMX_Constants.AllsvmxSettingList.size() == 0)
    {
        SVMX_Constants.AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);
    }
    system.debug(loggingLevel.WARN, 'Caching..' + SVMX_Constants.AllsvmxSettingList);
    AllsvmxSettingList = SVMX_Constants.AllsvmxSettingList;    

    //getting active real time optimization provider
    String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
    System.debug('Active Provider: ' + strActiveProvider);
    
    
    //setting for Create Warranty on IB Creation
    if(AllsvmxSettingList != NULL || AllsvmxSettingList.size() != 0){
        if(AllsvmxSettingList.containsKey('SORG001') && AllsvmxSettingList.get('SORG001') != null && AllsvmxSettingList.get('SORG001').get('SET002') != null) {
            isCheckUniqueness = AllsvmxSettingList.get('SORG001').get('SET002');//setting for Create Warranty on IB Creation
        }
    }    

    /*SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    List<String> settingIdList = new List<String>();
    settingIdList.add('SET002');
    Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('SORG001', settingIdList);
    if(AllSubModuleSettings.containsKey('SET002')== true) 
        isCheckUniqueness = AllSubModuleSettings.get('SET002');*/ 
    //Fixed defect : 045403 :BAC-4737 : added below condition  
    if(trigger.isBefore && (trigger.isUpdate || trigger.isInsert))
    {
        Map<Integer, Id> mapTechSFUser = new map<Integer, Id>();
        Map<Id, set<Id>> mapExtSFUserTech = new map<Id, set<Id>>();
        if(!Test.isRunningTest()){
            if(isCheckUniqueness.toUpperCase() == 'TRUE')
            { //If check uniquness setting is set to true, enforce uniqueness in salesforce user.
                Set<ID> sfids=new Set<ID>();
                map<Id, SVMXC__Service_Group_Members__c> mapTech = new map<Id, SVMXC__Service_Group_Members__c>();
                
                for(integer iIndex = 0; iIndex < Trigger.new.size(); iIndex++)
                {
                    SVMXC__Service_Group_Members__c sgm = Trigger.new[iIndex];
                    if(sgm.SVMXC__Salesforce_User__c !=null && ((String)sgm.SVMXC__Salesforce_User__c).length()>0 )
                    {
                        mapTechSFUser.put(iIndex, sgm.SVMXC__Salesforce_User__c);
                        if(!sfids.contains(sgm.SVMXC__Salesforce_User__c))
                            sfids.add(sgm.SVMXC__Salesforce_User__c);
                        else 
                            sgm.addError(System.Label.SORG001_TAG147);
                    }
                }
                if(mapTechSFUser!=null && mapTechSFUser.size()>0)
                {
                    mapTech.putAll([SELECT Id, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c in : mapTechSFUser.values()]);
                    if(mapTech !=null && mapTech.size()>0)
                    {
                        for(SVMXC__Service_Group_Members__c oSGM :mapTech.values())
                        {
                            if(oSGM.SVMXC__Salesforce_User__c != null)
                            {
                                if(!mapExtSFUserTech.ContainsKey(oSGM.SVMXC__Salesforce_User__c))
                                    mapExtSFUserTech.put(oSGM.SVMXC__Salesforce_User__c, new set<Id>());
                                mapExtSFUserTech.get(oSGM.SVMXC__Salesforce_User__c).add(oSGM.Id);
                            }
                        }   
                    }
                    for(SVMXC__Service_Group_Members__c sgm:Trigger.new)
                    {
                        if(mapExtSFUserTech.containsKey(sgm.SVMXC__Salesforce_User__c))
                        {
                            if(mapExtSFUserTech.get(sgm.SVMXC__Salesforce_User__c).size() > 0)
                            {
                                if(sgm.Id != null)
                                {
                                    if(mapExtSFUserTech.get(sgm.SVMXC__Salesforce_User__c).size() == 1)
                                    {
                                        if(!mapExtSFUserTech.get(sgm.SVMXC__Salesforce_User__c).contains(sgm.Id))
                                            sgm.addError(System.Label.SORG001_TAG147);
                                    }
                                    else 
                                        sgm.addError(System.Label.SORG001_TAG147);
                                }
                                else 
                                    sgm.addError(System.Label.SORG001_TAG147);
                            }
                        }
                    }
                }
            }
        }
    }   
    //Reparenting Expertise and Product Serviced if Team is changed for a tech
    if(Trigger.isUpdate && Trigger.isBefore)
    {
        list<String> lstTechId = new list<String>();
        list<SVMXC__Service_Group_Skills__c> lstExpertise = new list<SVMXC__Service_Group_Skills__c>();
        list<SVMXC__Service_Group_Skills__c> lstExpertiseUpdated = new list<SVMXC__Service_Group_Skills__c>();
        list<SVMXC__Service_Group_Product__c> lstProdServiced = new list<SVMXC__Service_Group_Product__c>();
        list<SVMXC__Service_Group_Product__c> lstProdServicedUpdated = new list<SVMXC__Service_Group_Product__c>();
       // map<id,list<id>> mapTechIdlstExpertiseId = new map<id,list<id>>();
        //map<id,SVMXC__Service_Group_Skills__c> mapExpertiseIDObj = new map<id,SVMXC__Service_Group_Skills__c> ();
        //map<id,list<id>> mapTechIdlstProdServicedId = new map<id,list<id>>();
        map<id,id> mapTechIdNewTeamId = new map<id,id>();
        //map<id,SVMXC__Service_Group_Product__c>> mapProdServicedIdObj = new map<id,SVMXC__Service_Group_Product__c>> ();
        boolean isExpToBeUpdated = false;
        boolean isProdServicedToBeUpdated = false;
        try

        {
            for(integer i=0; i<Trigger.new.size();i++)
            {
                if(Trigger.new[i].SVMXC__Service_Group__c != null && Trigger.old[i].SVMXC__Service_Group__c != null && !String.valueOf(Trigger.new[i].SVMXC__Service_Group__c).equals(String.valueOf(Trigger.old[i].SVMXC__Service_Group__c)))
                {
                    lstTechId.add(Trigger.new[i].id);
                    mapTechIdNewTeamId.put(Trigger.new[i].id,Trigger.new[i].SVMXC__Service_Group__c);
                }   
            }


            //Querying Expertise and Product Serviced 
            lstExpertise = [Select id,SVMXC__Service_Group__c,SVMXC__Group_Member__c from SVMXC__Service_Group_Skills__c where SVMXC__Group_Member__c in:lstTechId];
            lstProdServiced = [Select id,SVMXC__Service_Group__c,SVMXC__Group_Member__c from SVMXC__Service_Group_Product__c where SVMXC__Group_Member__c in:lstTechId];
            for(SVMXC__Service_Group_Skills__c obj:lstExpertise)
            {
                if(obj.SVMXC__Group_Member__c != null)
                {
                    if(mapTechIdNewTeamId.containsKey(obj.SVMXC__Group_Member__c))
                    {
                        obj.SVMXC__Service_Group__c = mapTechIdNewTeamId.get(obj.SVMXC__Group_Member__c);
                        lstExpertiseUpdated.add(obj);
                        isExpToBeUpdated = true;
                    }
                    
                }
            }
            for(SVMXC__Service_Group_Product__c obj:lstProdServiced)
            {   
                if(obj.SVMXC__Group_Member__c != null)
                {
                    if(mapTechIdNewTeamId.containsKey(obj.SVMXC__Group_Member__c))
                    {   

                        obj.SVMXC__Service_Group__c = mapTechIdNewTeamId.get(obj.SVMXC__Group_Member__c);
                        lstProdServicedUpdated.add(obj);
                        isProdServicedToBeUpdated = true;
                    }
                }
            

            }
            
            /*// Updating Expertise and Product Serviced WITH NEW Team
            for(integer i=0; i<Trigger.new.size();i++)
            {
                if(Trigger.new[i].SVMXC__Service_Group__c != null && Trigger.old[i].SVMXC__Service_Group__c != null && !String.valueOf(Trigger.new[i].SVMXC__Service_Group__c).equals(String.valueOf(Trigger.old[i].SVMXC__Service_Group__c)))
                {
                    system.debug('mapProdServicedIdObj: '+mapProdServicedIdObj);
                    
                    if(mapTechIdlstExpertiseId != null && mapTechIdlstExpertiseId.size()>0 && mapTechIdlstExpertiseId.containskey(Trigger.new[i].id) && mapTechIdlstExpertiseId.get(Trigger.new[i].id) != null && Trigger.new[i].SVMXC__Service_Group__c != null)
                    {
                        list<id> lstExptId = new list<id>();
                        lstExptId.mapTechIdlstExpertiseId.get(obj.SVMXC__Group_Member__c);
                        for 
                        mapExpertiseIDObj.get(Trigger.new[i].id).SVMXC__Service_Group__c = Trigger.new[i].SVMXC__Service_Group__c;
                    }
                    if(mapProdServicedIdObj != null && mapProdServicedIdObj.size()>0 && mapProdServicedIdObj.containskey(Trigger.new[i].id) && mapProdServicedIdObj.get(Trigger.new[i].id) != null && Trigger.new[i].SVMXC__Service_Group__c != null)
                        mapProdServicedIdObj.get(Trigger.new[i].id).SVMXC__Service_Group__c = Trigger.new[i].SVMXC__Service_Group__c;
                    
                }
            }*/
            system.debug('mapTechIdNewTeamId: '+mapTechIdNewTeamId);
            system.debug('lstExpertiseUpdated: '+lstExpertiseUpdated);
            system.debug('lstProdServicedUpdated: '+lstProdServicedUpdated);
            if(isExpToBeUpdated){
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstExpertiseUpdated, COMM_SecurityUtils.Access.Updateable ) ) {
            
            update lstExpertiseUpdated; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            }
                
                
            if(isProdServicedToBeUpdated){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstProdServicedUpdated, COMM_SecurityUtils.Access.Updateable ) ) {
            
             update lstProdServicedUpdated; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            }
               
            
        }catch(exception ex){
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
        }

    }
    
    if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO') && !WSCH_OptimizedSchedulingService.triggerExecuted){
        if(Trigger.isInsert && Trigger.isAfter) 
        {
            WSCH_TechnicianTriggerHandler.handleTechnicianInsert(Trigger.new);            
        }
        else if(Trigger.isUpdate && Trigger.isBefore) 
        {
            WSCH_TechnicianTriggerHandler.handleTechnicianUpdate(Trigger.new,Trigger.old);            
        }
        
        else if(Trigger.isDelete) 
        {
            WSCH_TechnicianTriggerHandler.handleTechnicianDelete(Trigger.old);            
        }    
    }    

}