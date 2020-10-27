trigger CASE_Trigger1 on Case (after insert, after update, before insert, before update) 
{
    //updated:18Jan2017-Defect 038657-additionally check for setting name along with trigger name to enable/disable trigger logic execution    
    /*static final string TRIGGER_SETTING_NAME = 'PELE528';
    static final string TRIGGER_NAME = 'SVMXC_CASE_Trigger1';
    
    if(!SVMXC. .isTriggerEnabled(TRIGGER_NAME,TRIGGER_SETTING_NAME)){
        System.debug(Logginglevel.WARN,'Case_Trigger1 execution is skipped.');
        return;
    }*/
    //Added by Nidhi   part of BAC-5157
    if(!CONF_TriggerControl.isTriggerEnabled('Case',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'Case_Trigger1 execution is skipped.');
        return;
    }
    
    Map<String, String> mapSetting = new Map<String, String>();
    
    if(SVMX_Constants.AllsvmxSettingListCase == NULL || SVMX_Constants.AllsvmxSettingListCase.size() == 0)
    {
        // Get all settings related to Entitlement.
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSubModules = new list<string>{'EVER004','IPRD003', 'SLAT002'};
        map<string, Map<String, String>> AllsvmxSettingList = new map<string, Map<String, String>>();
        AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);
        if(AllsvmxSettingList != null && AllsvmxSettingList.containsKey('EVER004') && AllsvmxSettingList.get('EVER004') != null )
        {
            Map<String, String> mapSetting1 = AllsvmxSettingList.get('EVER004');
            if(mapSetting1 != null && mapSetting1.size() > 0)
            {
                for(string strSettingId : mapSetting1.keySet())
                {
                    string setValue = mapSetting1.containsKey(strSettingId) ? mapSetting1.get(strSettingId) : '';
                    strSettingId = 'EVER004'+'_'+strSettingId;
                    SVMX_Constants.AllsvmxSettingListCase.put(strSettingId,setValue);
                }
            }
        }
        if(AllsvmxSettingList != null && AllsvmxSettingList.containsKey('IPRD003') && AllsvmxSettingList.get('IPRD003') != null )
        {
            Map<String, String> mapSetting2 = AllsvmxSettingList.get('IPRD003');
            if(mapSetting2 != null && mapSetting2.size() > 0)
            {
                for(string strSettingId : mapSetting2.keySet())
                {
                    string setValue = mapSetting2.containsKey(strSettingId) ? mapSetting2.get(strSettingId) : '';
                    strSettingId = 'IPRD003'+'_'+strSettingId;
                    SVMX_Constants.AllsvmxSettingListCase.put(strSettingId,setValue);
                }
            }
        }
        
        //SLA Settings
        if(AllsvmxSettingList != null && AllsvmxSettingList.containsKey('SLAT002') && AllsvmxSettingList.get('SLAT002') != null ){
            Map<String, String> mapSettingSLA = AllsvmxSettingList.get('SLAT002');
            if(mapSettingSLA != null && mapSettingSLA.size() > 0)
            {
                for(string strSettingId : mapSettingSLA.keySet())
                {
                    string setValue = mapSettingSLA.containsKey(strSettingId) ? mapSettingSLA.get(strSettingId) : '';
                    strSettingId = 'SLAT002' + '_' + strSettingId;
                    SVMX_Constants.AllsvmxSettingListCase.put(strSettingId, setValue);
                }
            }
        }
        
    }
    mapSetting = SVMX_Constants.AllsvmxSettingListCase;
    
    // Actions in before insert & update
    // 1. Derive product from installed product 
    // 2. Auto-entitlement
    // 3. SLA calculation
    
    // CASE_AutoEntitlement class Instantiation
    SVMXC.CASE_AutoEntitlement oAutoEntitlement = new SVMXC.CASE_AutoEntitlement();
    
    if(trigger.isBefore)
    {
        // Derive product from IB
        oAutoEntitlement.SVMX_DeriveProdfrmIB(Trigger.new, mapSetting);

        // Auto entitlement
        oAutoEntitlement.SVMX_DoEntitlement(Trigger.new, mapSetting);
        
        // SLA calculation
        List<Case> ProcessCase = new List<Case>();
        boolean RunTrigger = false;
        if(Trigger.isUpdate)
        {
            for(Integer i =0; i < Trigger.new.size(); i++)
            {
                if(Trigger.new[i].SVMXC__SLA_Terms__c != null && Trigger.new[i].Type != null && Trigger.new[i].Priority != null)
                {
                    if(Trigger.old[i].SVMXC__SLA_Terms__c != null || Trigger.old[i].Type != null || Trigger.old[i].Priority != null)
                    {
                        if(Trigger.new[i].SVMXC__SLA_Terms__c != Trigger.old[i].SVMXC__SLA_Terms__c || Trigger.new[i].Type != Trigger.old[i].Type || Trigger.new[i].Priority != Trigger.old[i].Priority || (Trigger.new[i].SVMXC__Is_SLA_Calculated__c != Trigger.old[i].SVMXC__Is_SLA_Calculated__c && Trigger.new[i].SVMXC__Is_SLA_Calculated__c == true))
                        {
                            Trigger.new[i].SVMXC__Initial_Response_Internal_By__c = null;
                            Trigger.new[i].SVMXC__Initial_Response_Customer_By__c = null;
                            Trigger.new[i].SVMXC__Onsite_Response_Internal_By__c = null;
                            Trigger.new[i].SVMXC__Onsite_Response_Customer_By__c = null;
                            Trigger.new[i].SVMXC__Resolution_Internal_By__c = null;
                            Trigger.new[i].SVMXC__Resolution_Customer_By__c = null;
                            Trigger.new[i].SVMXC__Restoration_Internal_By__c = null;
                            Trigger.new[i].SVMXC__Restoration_Customer_By__c = null;
                            ProcessCase.add(Trigger.new[i]);
                            RunTrigger = true;
                        }
                    }
                }
            }
        }
        if(Trigger.isInsert)
        {
            for(Integer i =0; i < Trigger.new.size(); i++)
            {
                if(Trigger.new[i].SVMXC__SLA_Terms__c != null && Trigger.new[i].Type != null && Trigger.new[i].Priority != null)
                {
                    Trigger.new[i].SVMXC__Initial_Response_Internal_By__c = null;
                    Trigger.new[i].SVMXC__Initial_Response_Customer_By__c = null;
                    Trigger.new[i].SVMXC__Onsite_Response_Internal_By__c = null;
                    Trigger.new[i].SVMXC__Onsite_Response_Customer_By__c = null;
                    Trigger.new[i].SVMXC__Resolution_Internal_By__c = null;
                    Trigger.new[i].SVMXC__Resolution_Customer_By__c = null;
                    Trigger.new[i].SVMXC__Restoration_Internal_By__c = null;
                    Trigger.new[i].SVMXC__Restoration_Customer_By__c = null;
                    ProcessCase.add(Trigger.new[i]);
                    RunTrigger = true;
                }
            }
        }   
        if(RunTrigger)
        {    
            //SVMXC.SLAT_Calculation Obj = new SVMXC.SLAT_Calculation();
            SVMXC.SLAT_Calculation Obj = new SVMXC.SLAT_Calculation(mapSetting);
            Obj.SLAT_CalculationOnCase(ProcessCase);
        }   
    }
    
    // Actions in after insert & update
    // 1. Post entitlement history
    if(trigger.isAfter)
    {
        oAutoEntitlement.SVMX_UpdateEntitlementHistory(Trigger.new, Trigger.old, mapSetting);
    }
    
    //Introduce setting to control SLA behavior (Response Time Calculation).
    Boolean isPerformResponseTimeCalculation = false;
    if(mapSetting != null && mapSetting.containsKey('SLAT002_SET005') && mapSetting.get('SLAT002_SET005') != null){
        isPerformResponseTimeCalculation = Boolean.valueOf(mapSetting.get('SLAT002_SET005'));
    }
    system.debug(Logginglevel.WARN, 'isPerformResponseTimeCalculation setting value: ' + isPerformResponseTimeCalculation);
    
    //added by Manish for calculating response time for different commitment type
    if(isPerformResponseTimeCalculation){
        if(Trigger.isBefore && Trigger.isUpdate){
            Map<String,Case> mapIdCase = new Map<String,Case>();
            Map<String,Case> mapOldIdCase = new Map<String,Case>();
            for(Case objNewCase : Trigger.new){
                Case objOldCase = Trigger.oldMap.get(objNewCase.id);
                if(objNewCase.SVMXC__SLA_Terms__c != null){
                    mapIdCase.put(objNewCase.id,objNewCase);
                    mapOldIdCase.put(objOldCase.id,objOldCase);
                }
            }
            if(mapIdCase.size()>0){
                SLAT_Calculation objSLAT_Calculation = new SLAT_Calculation();
                objSLAT_Calculation.calculateResponseTimeForCase(mapIdCase, mapOldIdCase);
            }
        }
    }
}