/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * Trigger handler class for all Work Order trigger related functionalities which includes  
 * Back Office :  1. Work Order & Product Serviced Line(Work Detail) Auto Entitlement
 *                2. SLA Caclulation
 *                3. SLA Response Time Calculation
 *                4. PM Actions
 *                5. PM Adjustments
 *                6. Set Partner Flag
 *                7. Set Work Order fields
 *                8. Push Notifications
 *                9. APL Outbound Routing
 *
 * DC & Optimax : TBD
 * 
 * @author 
 * @version 
 * @since 2017
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                                Created.
 *              Soumyaranjan Pati       7th July 2018   Security Scanned
 *              Soumyaranjan Pati        24 Dec 2018    Added code for BAC-4367
 *****************************************************************************************************/
/* Security Scanned */
 public class WORD_TriggerHandler{
    
    
    
    Static List<String> lstSubModules = new List<String>{'GLOB001','MOBN001',
                                                            'OMAX001','OMAX003','OMAX004',
                                                            'DCON002','DCON003','DCON004','DCON005',
                                                            'SORG001','SLAT003','PREV004','EVER007',
                                                            'WORD023', 'WORD022','WORD012',
                                                            'IPAD018','IPRD003','IPRD009','SFA002'};
    Static Map<String, String> svmxSettingListEVER007;
    Static Map<String, String> svmxSettingListOMAX003;
    Static Map<String, String> svmxSettingListSLAT003;
    Static Map<String, String> svmxSettingListPREV004;
    Static Map<String, String> svmxSettingListGLOB001;
    Static Map<String, String> svmxSettingListIPRD009;
    Static Map<String, String> svmxSettingListDCON005;
    Static Map<String, String> svmxSettingListMOBN001;
    Static Map<String, String> svmxSettingListIPAD018;
    Static Map<String, String> svmxSettingListIPAD003;
    Static Map<String, String> svmxSettingListWORD023;
    
    Static Map<String, String> svmxSettingListSFA002;//BAC-4711

    /*
        feature enable check
    */
    Static boolean pmActionEnabled = false;
    Static boolean pmAdjustmentEnabled = false;
    Static boolean componentProductMapEnabled = false;
    Static boolean componentTopLevelMapEnabled = false;
    Static boolean setPartnerPortalFlag = false; 
    Static boolean isPerformResponseTimeCalculation = false;
    Static integer evtMinimumDuration = 0;
    Static boolean isAPLActive = false;
    Static boolean isNotificationEnabled = false;
    Static boolean maxDCEnabled = false;
    Static boolean isEntitlementEnabled = false;
    Static boolean isEntitlementWebserviceEnabled = false;//Added by Nidhi as part of BAC-5144
    public static boolean fromWebservice = false;//Added by Nidhi as part of BAC-5144
    Static String strActiveProvider = null;//WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
    Static boolean sLACalculationEnabled = false;
    Static boolean omaxEnabled = false;
    Static boolean isFieldMatchRuleEnabled = false;
    Static boolean isSFAEnabled=false;//BAC-4711
    
    Set<Id> woDeleteIds;
    Set<Id> componentIds;
    Set<Id> accountIds;
    Set<Id> caseIds;
    Set<Id> locationIds;
    Set<Id> ownerIds;
    
    public static integer triggerCount = 0;
    public static boolean isSFAAfterUpdateExecuted=false;//BAC-4711
    public static boolean isSFAAfterInsertExecuted=false;//BAC-4711

    /*
        WO Product Map
    */
    Map<Id,SVMXC__Installed_Product__c> iBMap = new Map<Id,SVMXC__Installed_Product__c>() ;
    Map<Id,User> userMap;
    List<Account> accList = new List<Account>();
    List<Case> caseList = new List<Case>();   
    List<SVMXC__Site__c> locationList = new List<SVMXC__Site__c>();
    List<SVMXC__Service_Order__c> workOrdersForEntitlement;  
    //Ported fix for BAC-4004
    static SVMXC.WORD_AutoEntitlement oAutoEntitlement;
    static boolean isEnttitmentHistoryCreated = false;//ported fix for BAC-4004
    OMAX_PreCalculation Omaxp;

    // Inside the Constructor setting flag is set 
    public WORD_TriggerHandler(){
        
        if(SVMX_Constants.AllsvmxSettingList == null || SVMX_Constants.AllsvmxSettingList.isEmpty()) {
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            SVMX_Constants.AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);
        }

        getSettingsForModules();
        setFeatureFlag();
        system.debug(logginglevel.WARN, '*****SVMX_Constants.AllsvmxSettingList'+SVMX_Constants.AllsvmxSettingList);

    }

    public void getSettingsForModules(){
        if(Test.isRunningTest()){
            svmxSettingListEVER007 = new Map<String,String>();
            svmxSettingListOMAX003 = new Map<String,String>();
            svmxSettingListSLAT003 = new Map<String,String>();
            svmxSettingListPREV004 = new Map<String,String>();
            svmxSettingListGLOB001 = new Map<String,String>();
            svmxSettingListIPRD009 = new Map<String,String>();
            svmxSettingListDCON005 = new Map<String,String>();
            svmxSettingListMOBN001 = new Map<String,String>();
            svmxSettingListIPAD018 = new Map<String,String>();
            svmxSettingListIPAD003 = new Map<String,String>();
            svmxSettingListWORD023 = new Map<String,String>();
            
        svmxSettingListSFA002 = new Map<String,String>();//BAC-4711
        }
        
        if(SVMX_Constants.AllsvmxSettingList != null){

            for(String subModuleId : lstSubModules){
                
                if(SVMX_Constants.AllsvmxSettingList.containsKey(subModuleId) && SVMX_Constants.AllsvmxSettingList.get(subModuleId) != null){

                    if(subModuleId.equals('GLOB001') && (svmxSettingListGLOB001 == null || svmxSettingListGLOB001.isEmpty()) ){
                        svmxSettingListGLOB001 = SVMX_Constants.AllsvmxSettingList.get(subModuleId);

                                        
                    }

                    if(subModuleId.equals('EVER007') && (svmxSettingListEVER007 == null || svmxSettingListEVER007.isEmpty())){
                        svmxSettingListEVER007 = SVMX_Constants.AllsvmxSettingList.get(subModuleId);

                    }

                    if(subModuleId.equals('IPRD003') && (svmxSettingListIPAD003 == null || svmxSettingListIPAD003.isEmpty()) ){
                        
                        svmxSettingListIPAD003 = SVMX_Constants.AllsvmxSettingList.get(subModuleId);
                    }

                    if(subModuleId.equals('OMAX003') && (svmxSettingListOMAX003 == null || svmxSettingListOMAX003.isEmpty()) ){
                        svmxSettingListOMAX003 = SVMX_Constants.AllsvmxSettingList.get(subModuleId);

                        if(svmxSettingListGLOB001 != null){

                            svmxSettingListOMAX003.putAll(svmxSettingListGLOB001);
                        }

                    }

                    if(subModuleId.equals('SLAT003') && (svmxSettingListSLAT003 == null || svmxSettingListSLAT003.isEmpty() )){
                        svmxSettingListSLAT003 = SVMX_Constants.AllsvmxSettingList.get(subModuleId);

                        if(svmxSettingListGLOB001 != null){

                            svmxSettingListSLAT003.putAll(svmxSettingListGLOB001);
                        }
                    }

                    if(subModuleId.equals('PREV004') && (svmxSettingListPREV004 == null || svmxSettingListPREV004.isEmpty()) ){
                        svmxSettingListPREV004 = SVMX_Constants.AllsvmxSettingList.get(subModuleId);


                        if(svmxSettingListGLOB001 != null){

                            svmxSettingListPREV004.putAll(svmxSettingListGLOB001);
                        }                       
                    }

                    if(subModuleId.equals('DCON005') && (svmxSettingListDCON005 == null || svmxSettingListDCON005.isEmpty() )){
                        svmxSettingListDCON005 = SVMX_Constants.AllsvmxSettingList.get(subModuleId);
                    }

                    if(subModuleId.equals('MOBN001') && (svmxSettingListMOBN001 == null || svmxSettingListMOBN001.isEmpty() )){
                        svmxSettingListMOBN001 = SVMX_Constants.AllsvmxSettingList.get(subModuleId);
                    }   
                    
                    if(subModuleId.equals('IPRD009') && (svmxSettingListIPRD009 == null || svmxSettingListIPRD009.isEmpty() )){
                        svmxSettingListIPRD009 = SVMX_Constants.AllsvmxSettingList.get('subModuleId');
                    }
                    
                    if(subModuleId.equals('IPAD018') && (svmxSettingListIPAD018 == null || svmxSettingListIPAD018.isEmpty() ) ){
                        svmxSettingListIPAD018 = SVMX_Constants.AllsvmxSettingList.get(subModuleId);
                    }   

                    if(subModuleId.equals('WORD023') && (svmxSettingListWORD023 == null || svmxSettingListIPAD018.isEmpty() )){
                        svmxSettingListWORD023 = SVMX_Constants.AllsvmxSettingList.get(subModuleId);

                    }
                    //BAC-4711
                    if(subModuleId.equals('SFA002') && (svmxSettingListSFA002 == null || svmxSettingListSFA002.isEmpty()))
                    {
                       svmxSettingListSFA002 = SVMX_Constants.AllsvmxSettingList.get(subModuleId);
                    } 
                }
            }
        }
    }

    public void setFeatureFlag(){
        
        if(svmxSettingListGLOB001 != null){
            
            if(svmxSettingListGLOB001.get('GBL013') != null && svmxSettingListGLOB001.get('GBL013').toUpperCase() == 'TRUE'){
                componentProductMapEnabled = true;
            }

            if(svmxSettingListGLOB001.get('GBL008') != null && svmxSettingListGLOB001.get('GBL008').toUpperCase() == 'TRUE'){
                setPartnerPortalFlag = true;
            }   
            
            if(svmxSettingListGLOB001.get('GBL014') != null){
                isAPLActive = boolean.valueOf(svmxSettingListGLOB001.get('GBL014'));
            }    

            if(svmxSettingListGLOB001.get('GBL034') != null){
                maxDCEnabled = boolean.valueOf(svmxSettingListGLOB001.get('GBL034'));
            }
            //Switch for OptiMax Do Precalculation functionality
            if(svmxSettingListGLOB001.get('GBL007') != null){
                omaxEnabled = boolean.valueOf(svmxSettingListGLOB001.get('GBL007'));
                if(omaxEnabled){
                //WSCH_AuditLogger.rca('Dispatch Optimization (GBL007) is Enabled');
                    Set<String> providersSet = new Set<String>();
                    if(svmxSettingListGLOB001.get('GBL022') != null) {
                        for(String StrProvider : svmxSettingListGLOB001.get('GBL022').split(',')){
                            providersSet.add(StrProvider.touppercase());
                        }
                        //WSCH_AuditLogger.debug('Provider Set: ' + providersSet);
                        //if((providersSet.contains('OPTIMAX') || providersSet.contains('OPTIMAXECO')) && String.isNotBlank(isOptiMaxEcoEnabled) && (Boolean.valueOf(isOptiMaxEcoEnabled))) {
                        if(providersSet.contains('OPTIMAX') || providersSet.contains('OPTIMAXECO')) {
                             //WSCH_AuditLogger.rca('Optimax is set as the provider');
                            strActiveProvider = 'OPTIMAXECO';
                        }else if((providersSet.contains('SERVICEPOWER') || providersSet.contains('SERVICE POWER'))) {
                            strActiveProvider = 'SERVICEPOWER';
                        }
                    }                       
                }
            }
        }

        if(svmxSettingListPREV004 != null){
            if(svmxSettingListPREV004.containsKey('SET003') && svmxSettingListPREV004.get('SET003') != null && svmxSettingListPREV004.get('SET003').toUpperCase() == 'TRUE'){
                pmActionEnabled = true;
            }
    
            if(svmxSettingListPREV004.containsKey('SET004') && svmxSettingListPREV004.get('SET004') != null && svmxSettingListPREV004.get('SET004').equalsIgnoreCase('true')){
                pmAdjustmentEnabled = true;
            }
        }



        if(svmxSettingListIPRD009 != null && svmxSettingListIPRD009.Containskey('SET003') && svmxSettingListIPRD009.get('SET003').toUpperCase() == 'TRUE'){
            componentTopLevelMapEnabled = true;
        }



        if(svmxSettingListSLAT003 != null){ 
            if(svmxSettingListSLAT003.get('SET005') != null && svmxSettingListSLAT003.get('SET005').toUpperCase() == 'TRUE'){
                isPerformResponseTimeCalculation = true;
            }

            if(svmxSettingListSLAT003.get('SET003') != null && svmxSettingListSLAT003.get('SET003').toUpperCase() == 'TRUE'){
                sLACalculationEnabled = true;
            }
        }

        if(svmxSettingListDCON005 != null && svmxSettingListDCON005.containsKey('SET008') && svmxSettingListDCON005.get('SET008') != null){
            evtMinimumDuration = integer.valueOf(svmxSettingListDCON005.get('SET008'));
        }



        if(svmxSettingListMOBN001 != null && svmxSettingListMOBN001.containsKey('SET001') && svmxSettingListMOBN001.get('SET001') != null){
            isNotificationEnabled = Boolean.valueOf(svmxSettingListMOBN001.get('SET001'));
        }else if(svmxSettingListIPAD018 != null && svmxSettingListIPAD018.containsKey('SET017') && svmxSettingListIPAD018.get('SET017') != null){
            isNotificationEnabled = Boolean.valueOf(svmxSettingListIPAD018.get('SET017'));
        }

        if(svmxSettingListEVER007 != null && svmxSettingListEVER007.containsKey('SET001') && svmxSettingListEVER007.get('SET001') != null){
            isEntitlementEnabled = boolean.valueOf(svmxSettingListEVER007.get('SET001'));
        }
        
        //Added by Nidhi as part of BAC-5144
        if(svmxSettingListEVER007 != null && svmxSettingListEVER007.containsKey('SET006') && svmxSettingListEVER007.get('SET006') != null){
           isEntitlementWebserviceEnabled = boolean.valueOf(svmxSettingListEVER007.get('SET006'));
        }//Added by Nidhi as part of BAC-5144 Ends here
        
        //Switch for Field Match Rule Engine functionality
        if(svmxSettingListWORD023 != null){
            if(svmxSettingListWORD023.get('SET001') != null && svmxSettingListWORD023.get('SET001').toUpperCase() == 'TRUE'){
                isFieldMatchRuleEnabled = true;
            }        
        }
        
        //BAC-4711
        if(svmxSettingListSFA002 != null){
             if(svmxSettingListSFA002.containsKey('SET001') && svmxSettingListSFA002.get('SET001') != null )
             {
                 isSFAEnabled = Boolean.valueOf(svmxSettingListSFA002.get('SET001'));
             }
        }
    }

    public void onBeforeInsert(){
        //WSCH_AuditLogger.rca('The WorkOrder Trigger on BEfore Event has started executing ');
        System.debug('No of Queries before starting of beforeinsert: ' + Limits.getQueries());
        List<SVMXC__Service_Order__c> sLAWorkOrdersList = new List<SVMXC__Service_Order__c>();
        workOrdersForEntitlement = new List<SVMXC__Service_Order__c>();

        for(SVMXC__Service_Order__c workOrderRec : (List<SVMXC__Service_Order__c>)trigger.New){
            
            /*
                For Auto Entitlement
                Adding to the list
            */
            //if(isEntitlementEnabled){
            if(isEntitlementEnabled && !(isEntitlementWebserviceEnabled && SFM_SaveTargetRecords.fromSFMSave)){//Added by Nidhi as part of BAC-5144
                // if auto Entitlement flag is true then add to the list
                if(workOrderRec.SVMXC__Perform_Auto_Entitlement__c){
                    workOrdersForEntitlement.add(workOrderRec);
                }
            }    
            /*
                For SLA
            */
            if (workOrderRec.SVMXC__SLA_Terms__c != null && workOrderRec.SVMXC__Order_Type__c != null && workOrderRec.SVMXC__Priority__c != null){

                // Resetting the fields to null .
                workOrderRec = resetSLAFields(workOrderRec);
                
                if(sLACalculationEnabled){  
                    sLAWorkOrdersList.add(workOrderRec);
                }
            }



            getRelatedRecordIDs(workOrderRec);

            // DC 2.0 - Execute only if DC2.0 is disabled
            if(!maxDCEnabled){
                workOrderRec.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = evtMinimumDuration;
            }
            
            if(omaxEnabled){
              //checkWOValidAddress(workOrderRec);
            }

        } // end of for loop .      

        // This function consume 4 SOQL.
        queryRelatedRecords();

        setWorkOrderFields();

        performEntitlement(workOrdersForEntitlement);

        for(SVMXC__Service_Order__c workOrderRec : (List<SVMXC__Service_Order__c>)trigger.New){

            /*
                For SLA
            */
            if (workOrderRec.SVMXC__SLA_Terms__c != null && workOrderRec.SVMXC__Order_Type__c != null && workOrderRec.SVMXC__Priority__c != null){

                // Resetting the fields to null .
                workOrderRec = resetSLAFields(workOrderRec);
                
                if(sLACalculationEnabled){  
                    sLAWorkOrdersList.add(workOrderRec);
                }
            }            
        }

        if(sLACalculationEnabled && !sLAWorkOrdersList.isEmpty()){
            //WSCH_AuditLogger.rca('SLA Calculation is enabled for the workorder');
            SVMXC.SLAT_Calculation objSLAT_Calculation = new SVMXC.SLAT_Calculation(svmxSettingListOMAX003, svmxSettingListSLAT003, accList, caseList , iBMap.values());
            objSLAT_Calculation.SLAT_CalculationOnWO(sLAWorkOrdersList);
             //WSCH_AuditLogger.rca('SLA Calculation is complete');
        }else{
             //WSCH_AuditLogger.rca('SLA Calculation is not applicable for this Work Order');
        }

        // This method wiill check the setting values , if not enabled it would return before executing the code. 
        if(omaxEnabled)
            optimaxPrecalculate();
   
        // inside the function , check is enabled so that it does not execute when setting is turned off.
        if(isFieldMatchRuleEnabled)
            fieldMatchingRules();
            
        System.debug('No of Queries at the end of beforeinsert: ' + Limits.getQueries());
        
    }



    public void onBeforeUpdate(){
       System.debug('No of Queries before starting of onBeforeUpdate: ' + Limits.getQueries());
        
        List<SVMXC__Service_Order__c> sLAWorkOrdersList = new List<SVMXC__Service_Order__c>();
        workOrdersForEntitlement = new List<SVMXC__Service_Order__c>();
        Map<String,SVMXC__Service_Order__c> workOrderNewMap = new Map<String,SVMXC__Service_Order__c>();
        Map<String,SVMXC__Service_Order__c> workOrderOldMap = new Map<String,SVMXC__Service_Order__c>();
        
        for(SVMXC__Service_Order__c workOrderRec : (List<SVMXC__Service_Order__c>)trigger.New){

            SVMXC__Service_Order__c oldWORecord = (SVMXC__Service_Order__c)trigger.oldMap.get(workOrderRec.Id);  

            /*
                For Auto Entitlement
            */
           //if(isEntitlementEnabled){
           if(isEntitlementEnabled && !(isEntitlementWebserviceEnabled && SFM_SaveTargetRecords.fromSFMSave)){//Added by Nidhi as part of BAC-5144
                //if(workOrderRec.SVMXC__Perform_Auto_Entitlement__c && oldWORecord.SVMXC__Perform_Auto_Entitlement__c != workOrderRec.SVMXC__Perform_Auto_Entitlement__c){
                if(workOrderRec.SVMXC__Perform_Auto_Entitlement__c && ((oldWORecord.SVMXC__Perform_Auto_Entitlement__c != workOrderRec.SVMXC__Perform_Auto_Entitlement__c) || fromWebservice)){  
                    workOrdersForEntitlement.add(workOrderRec);
                    fromWebservice = false;
                }
            }


            getRelatedRecordIDs(workOrderRec);

            // DC 2.0 - Execute only if DC2.0 is disabled
            if(!maxDCEnabled){
                workOrderRec.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = evtMinimumDuration;
            }

            if(oldWORecord.SVMXC__Scheduled_Date_Time__c != null &&  workOrderRec.SVMXC__Scheduled_Date_Time__c != oldWORecord.SVMXC__Scheduled_Date_Time__c){
                workOrderRec.SVMXC__Previous_Scheduled_Date_Time__c = oldWORecord.SVMXC__Scheduled_Date_Time__c;
            }

            if(isPerformResponseTimeCalculation && workOrderRec.SVMXC__SLA_Terms__c != null){
                workOrderNewMap.put(workOrderRec.Id, workOrderRec);
                workOrderOldMap.put(workOrderRec.Id,oldWORecord);
            }
            
             if(omaxEnabled){
              //checkWOValidAddress(workOrderRec);
            }
        } // End of loop  
        queryRelatedRecords();

        setWorkOrderFields();

        performEntitlement(workOrdersForEntitlement);  

        if(omaxEnabled)
            optimaxPrecalculate();
   
        if(isFieldMatchRuleEnabled)
            fieldMatchingRules();
        
        for(SVMXC__Service_Order__c workOrderRec : (List<SVMXC__Service_Order__c>)trigger.New){

            SVMXC__Service_Order__c oldWORecord = (SVMXC__Service_Order__c)trigger.oldMap.get(workOrderRec.Id);
            /*
                For SLA
                After comparision with old and new values , we add it to the list.
            */
            if((workOrderRec.SVMXC__SLA_Terms__c != null && workOrderRec.SVMXC__Order_Type__c != null && workOrderRec.SVMXC__Priority__c != null)
                && (oldWORecord.SVMXC__SLA_Terms__c != null || oldWORecord.SVMXC__Order_Type__c != null || oldWORecord.SVMXC__Priority__c != null)
                && (workOrderRec.SVMXC__SLA_Terms__c != oldWORecord.SVMXC__SLA_Terms__c ||workOrderRec.SVMXC__Order_Type__c != oldWORecord.SVMXC__Order_Type__c
                   ||workOrderRec.SVMXC__Priority__c != oldWORecord.SVMXC__Priority__c || (workOrderRec.SVMXC__Is_SLA_Calculated__c == true && workOrderRec.SVMXC__Is_SLA_Calculated__c != oldWORecord.SVMXC__Is_SLA_Calculated__c
                ))){

                workOrderRec = resetSLAFields(workOrderRec);
                
                if(sLACalculationEnabled){
                    sLAWorkOrdersList.add(workOrderRec);
                }
            }
        }
        
        SVMXC.SLAT_Calculation objSLAT_Calculation = new SVMXC.SLAT_Calculation(svmxSettingListOMAX003, svmxSettingListSLAT003, accList, caseList , iBMap.values());
        
        if(sLACalculationEnabled && !sLAWorkOrdersList.isEmpty()){
            
            objSLAT_Calculation.SLAT_CalculationOnWO(sLAWorkOrdersList);
        }
        /*
            Only on Before update
        */
        if(workOrderNewMap.size() > 0){
           
           objSLAT_Calculation.calculateResponseTimeForWO(workOrderNewMap, workOrderOldMap);
        }

        
        if(omaxEnabled){
            /*Method to fetch & update Work Order Resource Preference BEFORE UPDATE. ('OMAX003', 'SET051')*/
            WORD_Service_Order_Resources.setWOResPrefUpdateTrigger((List<SVMXC__Service_Order__c>)trigger.New, (Map<Id,SVMXC__Service_Order__c>)trigger.oldMap);
            
            //added the flag to check if optimax related callout is already executed or not in Trigger update scenario.
            //If it is already executed in an update scenario, then do not allow it to execute further as this is recursive call.
            if(!WSCH_OptimizedSchedulingService.isCallOutExecuted) {
                System.debug('WORD_TriggerHandler:: executing callouts' + Limits.getQueries());
                
                //Invokes the SP API?s based on the type of change in work order
                if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('SERVICEPOWER'))
                    WSCH_TriggerHandler.identifyAPIAndOptimize(trigger.New,trigger.old);
        
                //Invoke QTL calculation using the modified Resource Preference for the work orders BEFORE UPDATE
                //Invoking the below method only if not already executed to avoid recursion.
                if(!WSCH_TriggerHandler.isQTLResourcePrefCalculated) {
                    WSCH_TriggerHandler.doQTLwithResourcePreference(Trigger.isInsert, Trigger.isUpdate);
                }
                //Invokes the OptiMax ECO API?s based on the type of change in work order
                if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO'))
                    WSCH_ECO_TriggerHandler.identifyAPIAndOptimizeEco(trigger.New,trigger.old);
            }
            System.debug('No of Queries at the end of  onBeforeUpdate: ' + Limits.getQueries());
        }              
    }



    public void onAfterInsert(){
       System.debug('No of Queries at the begining  of  onAfterInsert: ' + Limits.getQueries());    
            
        List<SVMXC__Service_Order__c> pmWorkOrders = new List<SVMXC__Service_Order__c>();
        productServiceEntitlementUpdate();
        
        /*
            For PM Actions and OptiMax
        */
        for(SVMXC__Service_Order__c workOrderRec : (List<SVMXC__Service_Order__c>)trigger.New){
            
            if(pmActionEnabled){
                if(workOrderRec.SVMXC__Is_PM_Work_Order__c){ //&& workOrderRec.SVMXC__Order_Status__c == 'Closed'){

                    pmWorkOrders.add(workOrderRec);
                }
            }  
        }
        
        executePMAction(pmWorkOrders);
        
        omaxCreateEvents();

        if(omaxEnabled){
             /*Method to fetch & update Work Order Resource Preference AFTER INSERT.*/
            WORD_Service_Order_Resources.setWOResPrefInsertTrigger(trigger.New);
            
            //Identify the work orders that qualify for Linx Continuous Optimization
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('SERVICEPOWER'))
                WSCH_TriggerHandler.doQualifyWorkorder(trigger.New);
    
            //Invoke QTL calculation using the above created Resource Preference for the work orders AFTER INSERT
            //Invoking the below method only if not already executed to avoid recursion.
            if(!WSCH_TriggerHandler.isQTLResourcePrefCalculated) {
                WSCH_TriggerHandler.doQTLwithResourcePreference(Trigger.isInsert, Trigger.isUpdate);
            }
            
            //Identify the work orders that qualify for OptiMax Continuous Optimization
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO'))
                WSCH_ECO_TriggerHandler.doQualifyWorkorderEco(trigger.New);
        }
        // setting  check is done inside the code. 
        pushNotification();
    //Platform event support : BAC-4711
        if(isSFAEnabled && !isSFAAfterInsertExecuted)
        {
           SFA_PlatformEventPublish sfaPlatformEvent = new SFA_PlatformEventPublish();
           sfaPlatformEvent.PublishEventAfterInsert(trigger.new,'SVMXC__Service_Order__c');
           isSFAAfterInsertExecuted = true;
        }
        System.debug('No of Queries at the end  of  onAfterInsert: ' + Limits.getQueries()); 
    }

    public void onAfterUpdate(){
        System.debug('No of Queries at the begining  of  onAfterUpdate: ' + Limits.getQueries()); 
        
        List<SVMXC__Service_Order__c> pmWorkOrders = new List<SVMXC__Service_Order__c>();
        Set<Id> aplWorkOrdersId = new Set<Id>();
        Map<Id, Datetime> woActivityCloseMap = new Map<Id, DateTime>();
        
        productServiceEntitlementUpdate();  

        /*
            For PM Actions
        */
        for(SVMXC__Service_Order__c workOrderRec : (List<SVMXC__Service_Order__c>)trigger.New){
           SVMXC__Service_Order__c oldWORecord = (SVMXC__Service_Order__c)trigger.oldMap.get(workOrderRec.Id);
            if(pmActionEnabled){
                if(workOrderRec.SVMXC__Is_PM_Work_Order__c){ // BAC-3236 - workOrderRec.SVMXC__Order_Status__c == 'Closed' && oldWORecord.SVMXC__Order_Status__c != workOrderRec.SVMXC__Order_Status__c ){

                    pmWorkOrders.add(workOrderRec);
                }
            }   
            
            if(test.isRunningTest() || pmAdjustmentEnabled){
            
                if(workOrderRec.SVMXC__SM_PM_Activity__c != null && workOrderRec.get(workOrderRec.SVMXC__SM_PM_Activity__c) != null){  //isChanged
                        
                    if(workOrderRec.get(workOrderRec.SVMXC__SM_PM_Activity__c) != oldWORecord.get(workOrderRec.SVMXC__SM_PM_Activity__c)){
                        
                        System.debug(logginglevel.DEBUG, 'Activity Date: ' + workOrderRec.get(workOrderRec.SVMXC__SM_PM_Activity__c));    
                        woActivityCloseMap.put(workOrderRec.Id, Datetime.valueOf(workOrderRec.get(workOrderRec.SVMXC__SM_PM_Activity__c)));  
                    }
                }
            }

            if(isAPLActive){
                aplWorkOrdersId.add(workOrderRec.Id);
            }        
        }
        if(!woActivityCloseMap.isEmpty()){
            PREV_Conditional_Engine_Utils.performConditionalAdjustment(woActivityCloseMap);   
        }         

        executePMAction(pmWorkOrders);


        if(aplWorkOrdersId.isEmpty()){
            WORD_OutboundRouting outboundClass = new WORD_OutboundRouting(aplWorkOrdersId);
        }   
        
        // setting check is handled inside the method.
        omaxCreateEvents(); 

        pushNotification();
        System.debug('No of Queries at the end  of  onAfterUpdate: ' + Limits.getQueries()); 
    //Platform event support : BAC-4711
        if(isSFAEnabled && !isSFAAfterUpdateExecuted)
        {
            SFA_PlatformEventPublish sfaPlatformEvent = new SFA_PlatformEventPublish();
            sfaPlatformEvent.PublishEventAfterUpdate(trigger.new,trigger.old,'SVMXC__Service_Order__c');
            isSFAAfterUpdateExecuted = true;
        }
    }

    public void onAfterDelete(){
        System.debug('No of Queries at the begining   of  onAfterDelete: ' + Limits.getQueries()); 
        Set<Id> woDeleteIds = new Set<Id>();
        for(SVMXC__Service_Order__c workOrderRec : (List<SVMXC__Service_Order__c>)trigger.old){
            
            if(workOrderRec.SVMXC__Dependency_Group__c != null){
                workOrderRec.addError(System.Label.DCON003_TAG091); 
            }

            woDeleteIds.add(workOrderRec.Id);
        }   

        if(!woDeleteIds.isEmpty()){
            //delete [SELECT Id FROM SVMXC__SVMX_Event__c WHERE SVMXC__WhatId__c IN : woDeleteIds];
            //Commented above line and added below line for security scan fix SECSCAN-806
            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c')){
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete [SELECT Id FROM SVMXC__SVMX_Event__c WHERE SVMXC__WhatId__c IN : woDeleteIds];
            }else{
                System.debug('During deleting ServiceMax Events object records: '+System.Label.COMM001_TAG142 + ' SVMXC__SVMX_Event__c');
            }
        }
        
        if(omaxEnabled){
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('SERVICEPOWER'))
                WSCH_TriggerHandler.doQualifyCancelWorkorder(trigger.old);
            System.debug('End of WORD_Trigger1::Trigger.isDelete :No of Queries used in this trigger code so far: ' + Limits.getQueries());
            
            //Deleting the work orders that qualify for OptiMax Continuous Optimization
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO'))
                WSCH_ECO_TriggerHandler.doQualifyCancelWorkorder(trigger.old); 
                System.debug('No of Queries at the end of  onAfterDelete: ' + Limits.getQueries()); 
        }         
    }

    void productServiceEntitlementUpdate(){
        
        //Ported fix for BAC-4004
        if(isEntitlementEnabled && !isEnttitmentHistoryCreated && oAutoEntitlement != null){

            //ported fix for BAC-4004
            //oAutoEntitlement = new SVMXC.WORD_AutoEntitlement();
            
            oAutoEntitlement.updateProductServiceEntitlement();

            Map<String,String> entitlementSettingMap = combineEntitlementSettings();
            oAutoEntitlement.SVMX_UpdateEntitlementHistory(trigger.new, trigger.old, entitlementSettingMap);
            //ported fix BAC-4004
            isEnttitmentHistoryCreated = true;
        }
    }

    Map<String,String> combineEntitlementSettings(){
        Map<String,String> entitlementSettingMap = new Map<String,String>();
        
        if(svmxSettingListEVER007 != null){
            
            for(String settingKey : svmxSettingListEVER007.keySet()){
                entitlementSettingMap.put('EVER007_'+ settingKey , svmxSettingListEVER007.get(settingKey));
            }

            if(svmxSettingListIPAD003 != null){

                for(String settingKey : svmxSettingListIPAD003.keySet()){
                    entitlementSettingMap.put('IPRD003_'+settingKey, svmxSettingListIPAD003.get(settingKey));
                }
            }
        }

        return entitlementSettingMap;
    }

    void performEntitlement(List<SVMXC__Service_Order__c> workOrdersForEntitlement){

        if(isEntitlementEnabled && !workOrdersForEntitlement.isEmpty()){
            Map<String,String> entitlementSettingMap = combineEntitlementSettings();
            oAutoEntitlement = new SVMXC.WORD_AutoEntitlement();
            oAutoEntitlement.SVMX_DoEntitlement(workOrdersForEntitlement,entitlementSettingMap);
        } 
    } 

    /*void calculateSLA(List<SVMXC__Service_Order__c> sLAWorkOrdersList){
        if(sLACalculationEnabled && !sLAWorkOrdersList.isEmpty()){
            SVMXC.SLAT_Calculation objSLAT_Calculation = new SVMXC.SLAT_Calculation(svmxSettingListOMAX003, svmxSettingListSLAT003, accList, caseList , iBMap.values());
            objSLAT_Calculation.SLAT_CalculationOnWO(sLAWorkOrdersList);
        }
    }*/

    void optimaxPrecalculate(){
        /*
            Action : Optimax team
            To Do : Perform setting checks before calling methods  
        */
        if(Omaxp == null){
            Omaxp = new OMAX_PreCalculation(svmxSettingListOMAX003,accList,caseList,iBMap.values(), locationList);
        }
        
        system.debug(LoggingLevel.INFO, 'WORD_TriggerHandler:optimaxPrecalculate:Start:No of Queries used in this apex code so far: ' + Limits.getQueries());
        system.debug(LoggingLevel.INFO, 'WORD_TriggerHandler:optimaxPrecalculate:Start: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize(): ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        
        //Below method gets a list of all the API names stored under field SVMXC__Field_Name__c for the following expression types under configData object
        OMAX_ManagePrecalcData managePrecalcData = new OMAX_ManagePrecalcData();
        Set<String> lstOfConfigDataFieldNames = managePrecalcData.getLstOfFieldNameFromConfigData();
        
        if(Trigger.isInsert && Trigger.isBefore) {
            Omaxp.DoPrecalculation(trigger.new, trigger.old);
        }
        
        //below list of filtered new and old WO list contains only those WOs that are qualified for Precalc
        List<SVMXC__Service_Order__c> lstFilteredOldWOs = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> lstFilteredNewWOs = new List<SVMXC__Service_Order__c>();
        
        if(Trigger.isUpdate && Trigger.isBefore) {
            Boolean isRecursionCheckEnabled = false;
            system.debug('WORD_TriggerHandler:optimaxPrecalculate: svmxSettingListOMAX003.get(\'SET00996\') : ' + svmxSettingListOMAX003.get('SET00996'));
            if(svmxSettingListOMAX003.get('SET00996') != null) {
                isRecursionCheckEnabled = boolean.valueOf(svmxSettingListOMAX003.get('SET00996'));
            }
            system.debug('optimaxPrecalculate isRecursionCheckEnabled : ' + isRecursionCheckEnabled + '\n');
            system.debug('optimaxPrecalculate OMAX_PreCalculation.isPrecalcExecuted : ' + OMAX_PreCalculation.isPrecalcExecuted);
            //allowing the first time beforeUpdate trigger to execute and at the end of first before update we set the boolean to true
            if(!OMAX_PreCalculation.isPrecalcExecuted) {
                Omaxp.DoPrecalculation(trigger.new, trigger.old);
                OMAX_PreCalculation.isPrecalcExecuted = true;
                //WSCH_AuditLogger.debug('optimaxPrecalculate()::before Update when IsPrecalcExecuted is false:WORD_TriggerHandler.triggerCount - ' + WORD_TriggerHandler.triggerCount);
            } //If beforeUpdate trigger is already executed in this transaction, check for the WO if any of the Precalc required fields are changed. If so
            //proceed with the execution of precalc
            else if(OMAX_PreCalculation.isPrecalcExecuted && isRecursionCheckEnabled && isPrecalcRequiredAgain(trigger.new, trigger.old, lstFilteredNewWOs, lstFilteredOldWOs, lstOfConfigDataFieldNames)) {
                //WSCH_AuditLogger.debug('optimaxPrecalculate()::before Update when recursion check is enabled:WORD_TriggerHandler.triggerCount - ' + WORD_TriggerHandler.triggerCount);
                Omaxp.DoPrecalculation(lstFilteredNewWOs, lstFilteredOldWOs);
            } else if(!isRecursionCheckEnabled){
                Omaxp.DoPrecalculation(trigger.new, trigger.old);
            }
        }
        //WSCH_AuditLogger.finish();
    }
    
    public Boolean isPrecalcRequiredAgain(List<SVMXC__Service_Order__c> lstNewWOs, List<SVMXC__Service_Order__c> lstOldWOs, 
                    List<SVMXC__Service_Order__c> lstFilteredNewWOs, List<SVMXC__Service_Order__c> lstFilteredOldWOs, Set<String> lstOfConfigDataFieldNames) {
        Boolean toExecutePrecalc = false;
        system.debug('isPrecalcRequiredAgain lstOfConfigDataFieldNames : '+lstOfConfigDataFieldNames + '\n');
        //WSCH_AuditLogger.debug('isPrecalcRequiredAgain lstOfConfigDataFieldNames : '+lstOfConfigDataFieldNames + '\n');
        if(lstOldWOs != null && lstOldWOs.size() > 0) {
            for(integer i=0; i< lstNewWOs.size(); i++) {
                SVMXC__Service_Order__c oldWO = lstOldWOs.get(i);
                SVMXC__Service_Order__c newWO = lstNewWOs.get(i);
                
                if(oldWO.SVMXC__Case__c != newWO.SVMXC__Case__c) {
                    toExecutePrecalc = true;
                } else if(oldWO.SVMXC__Component__c != newWO.SVMXC__Component__c) {
                    toExecutePrecalc = true;
                } else if(oldWO.SVMXC__Company__c != newWO.SVMXC__Company__c) {
                    toExecutePrecalc = true;
                } else if(oldWO.SVMXC__Site__c != newWO.SVMXC__Site__c) {
                    toExecutePrecalc = true;
                } else if(oldWO.SVMXC__SLA_Terms__c != newWO.SVMXC__SLA_Terms__c) {
                    toExecutePrecalc = true;
                } else if(oldWO.SVMXC__Preferred_Business_Hours__c != newWO.SVMXC__Preferred_Business_Hours__c) {
                    toExecutePrecalc = true;
                } else if(oldWO.SVMXC__Primary_Territory__c != newWO.SVMXC__Primary_Territory__c) {
                    toExecutePrecalc = true;
                }
                    //comparing the WO fields that are used in defining the criteria for qualifying the rules. 
                    //This is done explicitly so that we do not miss the custom fields if at all used in defining the criteria
                  else if(!toExecutePrecalc && lstOfConfigDataFieldNames != null && !lstOfConfigDataFieldNames.isEmpty()) {
                    system.debug('Precalc custom field check condition ... \n');
                    //WSCH_AuditLogger.debug('Precalc custom field check condition ... \n');
                    for(String eachFieldName: lstOfConfigDataFieldNames) {
                        system.debug('Precalc custom field check eachFieldName : '+eachFieldName + '\n');
                        //WSCH_AuditLogger.debug('Precalc custom field check eachFieldName : '+eachFieldName + '\n');
                        if(oldWO.get(eachFieldName) != newWO.get(eachFieldName)) {
                            system.debug('Precalc custom field check ... oldWO.get(eachFieldName): '+oldWO.get(eachFieldName)+' , newWO.get(eachFieldName): '+newWO.get(eachFieldName));
                            //WSCH_AuditLogger.debug('Precalc custom field check ... oldWO.get(eachFieldName): '+oldWO.get(eachFieldName)+' , newWO.get(eachFieldName): '+newWO.get(eachFieldName));
                            toExecutePrecalc = true;
                        }
                        if(toExecutePrecalc) 
                            break;
                    }
                  }
                
                if(toExecutePrecalc) {
                    //add the qualified WO to the respective lists.
                    lstFilteredOldWOs.add(oldWO);
                    lstFilteredNewWOs.add(newWO);
                }
                toExecutePrecalc = false;
            }
        
            if(lstFilteredOldWOs.size() > 0) {
                toExecutePrecalc = true;
            }   
        }
        return toExecutePrecalc;
    }

    void fieldMatchingRules(){
        WSCH_TriggerHandler.doQualifyFieldMatchRuleEngine(SVMX_Constants.AllsvmxSettingList,trigger.new, trigger.isInsert, trigger.isUpdate);  
    }

    void setWorkOrderFields(){
        for(SVMXC__Service_Order__c workOrderRec : (List<SVMXC__Service_Order__c>)trigger.New){

            if(workOrderRec.SVMXC__Component__c != null && iBMap != null && iBMap.containsKey(workOrderRec.SVMXC__Component__c)){
                SVMXC__Installed_Product__c iBRecord = iBMap.get(workOrderRec.SVMXC__Component__c);
                
                if(componentProductMapEnabled && iBRecord.SVMXC__Product__c != null){
                    workOrderRec.SVMXC__Product__c = iBRecord.SVMXC__Product__c;
                }

                if(componentTopLevelMapEnabled && iBRecord.SVMXC__Top_Level__c != null){
                    workOrderRec.SVMXC__Top_Level__c = iBRecord.SVMXC__Top_Level__c;
                }

            }

            if(setPartnerPortalFlag && userMap != null && userMap.containsKey(workOrderRec.ownerId)){
                User userRec = userMap.get(workOrderRec.ownerId);
                
                if(userRec.Contact.AccountId != null){

                    workOrderRec.SVMXC__IsPartnerRecord__c = true;
                    workOrderRec.SVMXC__Partner_Account__c = userRec.Contact.AccountId;
                    workOrderRec.SVMXC__Partner_Contact__c = userRec.ContactId;
                }
            }
        }
    }

    void queryRelatedRecords(){

        if(componentIds != null && !componentIds.isEmpty()){
            iBMap = new Map<Id,SVMXC__Installed_Product__c>([SELECT Id, SVMXC__Preferred_Technician__c,SVMXC__Top_Level__c,SVMXC__Access_Hours__c,SVMXC__Access_Hours__r.IsActive, SVMXC__Product__c, SVMXC__Longitude__c, SVMXC__Latitude__c, SVMXC__Parent__c FROM SVMXC__Installed_Product__c WHERE Id IN :componentIds]);
        }

        if(accountIds != null && !accountIds.isEmpty()){
            accList = [select id,SVMXC__Preferred_Technician__c,SVMXC__Access_Hours__c,SVMXC__Access_Hours__r.IsActive from Account where id in :accountIds];
        }

        if(caseIds != null && !caseIds.isEmpty()){
            caseList = [select SVMXC__BW_Time_Zone__c,Preferred_Start_Time__c ,Preferred_End_Time__c,SVMXC__Booking_Window__c, SVMXC__BW_Territory__c, SVMXC__BW_Date__c, SVMXC__Service_Contract__r.Id, SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c,Type, SystemModstamp, SuppliedPhone, SuppliedName, SuppliedEmail, SuppliedCompany, Subject, Status, SVMXC__Scheduled_Date__c, SVMXC__SLA_Clock_Paused__c, SVMXC__SLA_Clock_Pause_Time__c, SVMXC__SLA_Clock_Pause_Restart_Time__c, SVMXC__SLA_Clock_Pause_Reason__c, SVMXC__SLA_Clock_Pause_Minutes__c, SVMXC__SLA_Clock_Pause_Hours__c, SVMXC__SLA_Clock_Pause_Days__c, SVMXC__SLA_Clock_Extension_Minutes__c, SVMXC__SContract_Business_Hour__c, SVMXC__Restoration_Internal_By__c, SVMXC__Restoration_Customer_By__c, SVMXC__Resolution_Internal_By__c, SVMXC__Resolution_Customer_By__c, SVMXC__PM_Plan__c, SVMXC__Onsite_Response_Internal_By__c, SVMXC__Onsite_Response_Customer_By__c, SVMXC__Is_PM_Case__c, SVMXC__Initial_Response_Internal_By__c, SVMXC__Initial_Response_Customer_By__c, SVMXC__Clock_Paused_Forever__c, SVMXC__Actual_Restoration__c, SVMXC__Actual_Resolution__c, SVMXC__Actual_Onsite_Response__c, SVMXC__Actual_Initial_Response__c, SVMXC__Warranty__c, SVMXC__Top_Level__c, SVMXC__Site__c, SVMXC__Service_Contract__c, SVMXC__SLA_Terms__c, SVMXC__Product__c, SVMXC__Perform_Auto_Entitlement__c, SVMXC__Entitlement_Notes__c, SVMXC__Component__c, SVMXC__Component_Zip__c, SVMXC__Component_Street__c, SVMXC__Component_State__c, SVMXC__Component_Country__c, SVMXC__Component_City__c, SVMXC__Billing_Type__c, SVMXC__Auto_Entitlement_Status__c, Reason, Priority, OwnerId, Origin, LastModifiedDate, LastModifiedById, IsEscalated, IsDeleted, IsClosed, Id, Description, CreatedDate, CreatedById, ContactId, ClosedDate, CaseNumber, AssetId, AccountId From Case  where id in : caseIds];
        }
         
        //if(locationIds != null && !locationIds.isEmpty()){ //BAC-4367
        if(locationIds != null && !locationIds.isEmpty() && omaxEnabled){//Added Optimax check as this SOQL is used by Optimax only -BAC-4367
            locationList = [select Id, SVMXC__Preferred_Business_Hours__c from SVMXC__Site__c where Id IN: locationIds];
        }

        if(setPartnerPortalFlag && ownerIds != null && !ownerIds.isEmpty()){
            //Defect fixed 044975
            //Map<Id,User> userMap = new Map<Id,User>([SELECT Id, ContactId, Contact.AccountId, UserType FROM User WHERE UserType = 'PowerPartner' AND Id in :ownerIds AND ContactId != null]);
             userMap = new Map<Id,User>([SELECT Id, ContactId, Contact.AccountId, UserType FROM User WHERE UserType = 'PowerPartner' AND Id in :ownerIds AND ContactId != null]);
     
        }

    }

    void executePMAction(List<SVMXC__Service_Order__c> pmWorkOrders){
        if(pmActionEnabled && !pmWorkOrders.isEmpty() && !SVMXC.PREV_PMActions.isPMExecutionDone){

            SVMXC.PREV_PMActions oPMActions = new SVMXC.PREV_PMActions(svmxSettingListPREV004);
            /*
                To Do : 
                Data is pre-processed in trigger to check for change. No need to pass all the data
                Previous Method : oPMActions.WorkOrderActions(Trigger.old, Trigger.new, Trigger.isUpdate, Trigger.isInsert);
            */

            //oPMActions.WorkOrderActions(pmWorkOrders);
            oPMActions.WorkOrderActions(trigger.Old, trigger.New, Trigger.isUpdate, Trigger.isInsert);
        }
    }

    void omaxCreateEvents(){
        //WSCH_AuditLogger.rca('Creating Events (Immediate Dispatch Events) for the WorkOrder');
        WSCH_AuditLogger.logGovernerLimits('Before Creating Events');
        if(Omaxp == null){
            Omaxp = new OMAX_PreCalculation(svmxSettingListOMAX003,accList,caseList,iBMap.values(), locationList);
        }
        
        Omaxp.CreateEvents(trigger.New, trigger.Old);
        WSCH_AuditLogger.logGovernerLimits('After Creating Events');
    }

    void pushNotification(){
        if(isNotificationEnabled){
            Map<String,String> combinedSettingsMap = new Map<String,String>();

            for(String settingId: svmxSettingListIPAD018.keyset()){
                
                combinedSettingsMap.put('IPAD018_'+settingId,svmxSettingListIPAD018.get(settingId));
            }

            for(String settingId: svmxSettingListMOBN001.keyset()){

                combinedSettingsMap.put('MOBN001_'+settingId,svmxSettingListMOBN001.get(settingId));
            }

            String strAlertType = trigger.isInsert ? '1' : '2';

            SVMX_PushNotification notify = new SVMX_PushNotification();
            //Map<Id, SVMXC__Service_Order__c> workOrderNewMap = new Map<Id, SVMXC__Service_Order__c>(newWorkOrdersList);
            notify.routingPN(trigger.newMap, 'SVMXC__Service_Order__c', strAlertType, combinedSettingsMap);
        }
    }
    
    SVMXC__Service_Order__c resetSLAFields(SVMXC__Service_Order__c workOrderRecord){

        system.debug('Enterd in if ');
        workOrderRecord.SVMXC__Initial_Response_Internal_By__c = null;
        workOrderRecord.SVMXC__Initial_Response_Customer_By__c = null;
        workOrderRecord.SVMXC__Onsite_Response_Internal_By__c = null;
        workOrderRecord.SVMXC__Onsite_Response_Customer_By__c = null;
        workOrderRecord.SVMXC__Restoration_Internal_By__c = null;
        workOrderRecord.SVMXC__Restoration_Customer_By__c = null;
        workOrderRecord.SVMXC__Resolution_Internal_By__c = null;
        workOrderRecord.SVMXC__Resolution_Customer_By__c = null;
        
        //Added for the SPM Average Response Time metric
        workOrderRecord.SVMXC__SM_SLA_Initial_Response__c = null;
        workOrderRecord.SVMXC__SM_SLA_Onsite_Response__c = null;
        workOrderRecord.SVMXC__SM_SLA_Resolution__c = null;
        workOrderRecord.SVMXC__SM_SLA_Restoration__c = null;
        return workOrderRecord;
    }

    void getRelatedRecordIDs(SVMXC__Service_Order__c workOrderRecord){
        
        /*
            For mapping component product to work order product
        */
        if(workOrderRecord.SVMXC__Component__c != null){
            
            if(componentIds == null){
                componentIds = new Set<Id>();
            }
            componentIds.add(workOrderRecord.SVMXC__Component__c);
        }

        if(workOrderRecord.SVMXC__Company__c != null){

            if(accountIds == null){
                accountIds = new Set<Id>();
            }
            accountIds.add(workOrderRecord.SVMXC__Company__c);
        }

        if(workOrderRecord.SVMXC__Case__c != null){

            if(caseIds == null){
                caseIds = new Set<Id>();
            }
            caseIds.add(workOrderRecord.SVMXC__Case__c);
        }

        if(workOrderRecord.SVMXC__Site__c != null){

            if(locationIds == null){
                locationIds = new Set<Id>();
            }
            locationIds.add(workOrderRecord.SVMXC__Site__c);
        }

        if(setPartnerPortalFlag){

            if(ownerIds == null){
                ownerIds = new Set<Id>();
            }
            ownerIds.add(workOrderRecord.ownerId);
        }

    }   
    
    //It checks whether the workorder has valid address or not as below: 
    //1) If all the fields of the address is empty.
    //2) If complete address is not provided (i.e either of Street,City or State is empty) and both (Zip AND Country) is also empty. 
    //3) If complete address is not provided (i.e either of Street,City or State is empty) and also either (Zip OR Country) is empty. 
    /*public void checkWOValidAddress(SVMXC__Service_Order__c workOrderRec){
         workOrderRec.SVMXC__Violation_Message__c = null;
         if(workOrderRec.SVMXC__Street__c == null && workOrderRec.SVMXC__City__c == null && workOrderRec.SVMXC__State__c == null && workOrderRec.SVMXC__Zip__c == null && workOrderRec.SVMXC__Country__c == null){    
            workOrderRec.SVMXC__Violation_Message__c = 'Either complete address or atleast ZIP and Country should be available';
         }else if((workOrderRec.SVMXC__Street__c == null || workOrderRec.SVMXC__City__c == null || workOrderRec.SVMXC__State__c == null) && ((workOrderRec.SVMXC__Zip__c == null && workOrderRec.SVMXC__Country__c == null))){
           workOrderRec.SVMXC__Violation_Message__c = 'Either complete address or atleast ZIP and Country should be available';
         }else if((workOrderRec.SVMXC__Street__c == null || workOrderRec.SVMXC__City__c == null || workOrderRec.SVMXC__State__c == null) && ((workOrderRec.SVMXC__Zip__c == null && workOrderRec.SVMXC__Country__c != null)
         || (workOrderRec.SVMXC__Zip__c != null && workOrderRec.SVMXC__Country__c == null))){
           workOrderRec.SVMXC__Violation_Message__c = 'ZIP and Country both should be available if complete address is not provided';
         } 
    }*/

}