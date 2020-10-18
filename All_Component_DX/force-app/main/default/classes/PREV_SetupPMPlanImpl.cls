/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The PM_PlanImpl is called by class PM_Plan and is used to retrieve data from Salesforce. It mainly gets
 * data from PM Plan and its relational objects.  
 * 
 *
 * @author Anchal 
 * @version 
 * @since 2017
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Anchal               13 Feb 2017     Created.
 *              Manish               03 July 2017   Modified for supporting Condition type = Criteria/Comparision based
 *              Manish               27 July 2017   Modified for edit condition for pm plan
 *****************************************************************************************************/
 
 
public with sharing class PREV_SetupPMPlanImpl{
    
    private List<Account> listAcc = new List<Account>();
    private List<SVMXC__Service_Level__c > listSLA = new List<SVMXC__Service_Level__c >();
    private List<SVMXC__PM_Plan_Template__c > listPMTemplate = new List<SVMXC__PM_Plan_Template__c >();
    private List<SVMXC__Service_Contract__c  > listServiceContract = new List<SVMXC__Service_Contract__c  >();
    PREV_PMPlanUtils callUtilMethods = new PREV_PMPlanUtils();
    List<SVMXC__Installed_Product__c> lstInstalledProducts = new List<SVMXC__Installed_Product__c>();
    List<PREV_SetupPMPlan_Wrapper.Schedule> listSchWrapper = new  List<PREV_SetupPMPlan_Wrapper.Schedule>(); 
    Integer scheduleSeq= 1; 

    

    
    /* Input parameter: Method accepts PREV_SetupPMPlan_Wrapper.PM_Plan_Request as request
     * Output parameter:  Returns PREV_SetupPMPlan_Wrapper.PM_Plan_Response
     * Functionality: It queries PM plan record and respective records if Id is given, 
     *                else create empty PM_Plan_Data data structure
    */
    public PREV_SetupPMPlan_Wrapper.PM_Plan_Response getPMPlanDetails(PREV_SetupPMPlan_Wrapper.PM_Plan_Request request) {
        PREV_SetupPMPlan_Wrapper.PM_Plan_Response pmPlanRes = new PREV_SetupPMPlan_Wrapper.PM_Plan_Response();
        PREV_SetupPMPlan_Wrapper.PM_Plan_Data pmPlanData = new PREV_SetupPMPlan_Wrapper.PM_Plan_Data();

        Map<String, String> svmxSettingList = new Map<String,String>();

        // Get setting values only once and make them part of wrapper.

        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map <String, ID>  mapExpNameId = new Map <String, ID>();
        if(commSettings.SVMX_getSettingList('PREV001') != null)
            svmxSettingList = commSettings.SVMX_getSettingList('PREV001');



        List<String> mappingList = new List <String>();
            

        if(svmxSettingList.containsKey('SET004') && !String.isBlank(svmxSettingList.get('SET004'))){
            mappingList.add(svmxSettingList.get('SET004')); 
        }

        if(svmxSettingList.containsKey('SET005') && !String.isBlank(svmxSettingList.get('SET005'))){
            mappingList.add(svmxSettingList.get('SET005')); 
        }

        if(svmxSettingList.containsKey('SET006') && !String.isBlank(svmxSettingList.get('SET006'))){
            mappingList.add(svmxSettingList.get('SET006')); 
        }

        if(svmxSettingList.containsKey('SET007') && !String.isBlank(svmxSettingList.get('SET007'))){
            mappingList.add(svmxSettingList.get('SET007')); 
        }

        if(svmxSettingList.containsKey('SET008') && !String.isBlank(svmxSettingList.get('SET008'))){
            mappingList.add(svmxSettingList.get('SET008')); 
        }

        if(mappingList != null && mappingList.size()>0){
            for(SVMXC__ServiceMax_Processes__c mapProcesses : [Select Id, SVMXC__Source_Object_Name__c
                                                                    FROM SVMXC__ServiceMax_Processes__c
                                                                        WHERE SVMXC__MapID__c IN :mappingList]){
                mapExpNameId.put(mapProcesses.SVMXC__Source_Object_Name__c, mapProcesses.id);
            }
        }

        system.debug(mapExpNameId);

        if(request.pmPlanId != null ){
            SVMXC__PM_Plan__c pmPlanRec = [SELECT ID, Name, SVMXC__Account__c,SVMXC__Account__r.Name,SVMXC__SM_Advanced_Expression__c,SVMXC__SM_Condition_Type__c,
                                                SVMXC__Coverage_Type__c, SVMXC__End_Date__c, SVMXC__PM_Plan_Template__c,
                                                SVMXC__PM_Plan_Template__r.Name, SVMXC__PM_Plan_Template__r.SVMXC__SM_Use_Current_Field_Value__c,SVMXC__Schedule_Type__c, SVMXC__Service_Contract__c, 
                                                SVMXC__Service_Contract__r.Name, SVMXC__SLA_Terms__c, SVMXC__SLA_Terms__r.Name,
                                                SVMXC__Start_Date__c, SVMXC__Description__c,SVMXC__SM_Adjustment_Activity_Date__c, SVMXC__Location__c,SVMXC__Location__r.Name,
                                                SVMXC__Task_Template__c,
                                                (SELECT Id, Name, SVMXC__SM_Value__c, SVMXC__Frequency__c , SVMXC__Frequency_Unit__c , SVMXC__Processed__c ,SM_Adjusted_Units__c,
                                                    SM_Adjusted_Value__c, SM_Adjustment_Type__c, SM_Attr_Data_type__c, SM_Attribute_Field__c,SM_Max_Activity_Changed__c,
                                                    SM_Min_Activity_Changed__c,SM_Operator__c, SM_Start_At__c, SM_Stop_At__c, SM_Threshold__c, SM_Threshold_Type__c, 
                                                    SM_PM_Coverage__c, SVMXC__SM_Sequence__c,SVMXC__Recurring__c , SVMXC__Schedule_Type__c , SVMXC__Work_Order_Purpose__c ,
                                                    SM_Attribute_Type__c,SVMXC__Visit_Description__c 
                                                    FROM SVMXC__PM_Schedule_Definition__r 
                                                        WHERE SVMXC__SM_PM_Coverage__c = null ORDER BY SVMXC__SM_Sequence__c ASC),
                                                (SELECT Id, Name, SVMXC__Location_Name__c, SVMXC__Location_Name__r.Name, SVMXC__Next_PM_Cycle__c, SVMXC__PM_Cycle_Type__c,
                                                    SVMXC__PM_Frequency__c, SVMXC__PM_Limit__c, SVMXC__Product_Name__c, SVMXC__Product_Name__r.Name, SVMXC__Product_Name__r.SVMXC__Product__c,
                                                    SVMXC__Select__c
                                                    FROM SVMXC__PM_Coverage__r),
                                                (SELECT Id, Name, SVMXC__SM_Expression_Internal_Value__c, SVMXC__Last_Run_Date__c, SVMXC__SM_PM_Coverage__c,
                                                    SVMXC__PM_Schedule_Definition__c, SVMXC__Scheduled_On__c, SVMXC__SM_Expression_Actual_Output_Value__c,
                                                    SVMXC__SM_Status__c , SVMXC__SM_Expression_Display_Value__c, SVMXC__SM_Sequence__c
                                                    FROM SVMXC__PM_Schedule__r ORDER BY SVMXC__SM_Sequence__c ASC)
                                             FROM SVMXC__PM_Plan__c
                                             WHERE ID =:request.pmPlanId];
            pmPlanData = getPMPlanData(pmPlanRec); 
            SVMXC__PM_Plan__c clonePMPlan = pmPlanRec.clone(false);
            pmPlanData.pmPlanMappedValues = clonePMPlan;
            
            system.debug(loggingLevel.WARN, 'Pm Plan rec: ' + pmPlanRec);
            
        }
        else{
            // Create new instance of PM_Plan_Data and fill in the values.
            // If Service Contract record details are provided, then poupulte Account, SLA and Service Contract information for PM plan
            //pmPlanData = getPMPlanData(new SVMXC__PM_Plan__c()); 
            
            SVMXC__PM_Plan__c createPMPlanRec = new SVMXC__PM_Plan__c();
            //pmPlanData = new PREV_SetupPMPlan_Wrapper.PM_Plan_Data();
            
            List<PREV_SetupPMPlan_Wrapper.Coverage> IBLoadlistCov = new List <PREV_SetupPMPlan_Wrapper.Coverage>();
            

            system.debug(loggingLevel.WARN, 'Mapping from Source Object and PM Template' + mapExpNameId);
            
            if(mapExpNameId != null && mapExpNameId.size() > 0){
                Map<String,Sobject> SourceRecIdTargetObjMap = new Map<String,Sobject> (); 
                SFM_ApplyMapping applyMapping = new SFM_ApplyMapping();
                Map <String, Schema.SObjectType> schemaMap = new Map <String, Schema.SObjectType>();
                Map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                for(Schema.SObjectType s : gd.values()){
                    schemaMap.put(s.getDescribe().getName(),s);
                }
                SourceRecIdTargetObjMap.put(request.sourceId,  createPMPlanRec);

                
                // Based on mode apply mapping
                if(request.mode.equalsIgnoreCase('sc') && !String.isBlank(mapExpNameId.get('SVMXC__Service_Contract__c'))){
                    List <Sobject> appliedMappingRec = applyMapping.getApplyMapping1(mapExpNameId.get('SVMXC__Service_Contract__c') ,SourceRecIdTargetObjMap, false,schemaMap);
                    if(appliedMappingRec != null & appliedMappingRec.size() > 0){
                        createPMPlanRec = (SVMXC__PM_Plan__c)appliedMappingRec[0];
                    }
                }
                else if(request.mode.equalsIgnoreCase('ib') && !String.isBlank(mapExpNameId.get('SVMXC__Installed_Product__c'))){
                    List <Sobject> appliedIBMappingRec = applyMapping.getApplyMapping1(mapExpNameId.get('SVMXC__Installed_Product__c') ,SourceRecIdTargetObjMap, false,schemaMap);
                    if(appliedIBMappingRec != null & appliedIBMappingRec.size() > 0){
                        createPMPlanRec = (SVMXC__PM_Plan__c)appliedIBMappingRec[0];
                    }
                }
                else if(request.mode.equalsIgnoreCase('account') && !String.isBlank(mapExpNameId.get('Account'))){
                    List <Sobject> appliedAccMappingRec = applyMapping.getApplyMapping1(mapExpNameId.get('Account') ,SourceRecIdTargetObjMap, false,schemaMap);
                    if(appliedAccMappingRec != null & appliedAccMappingRec.size() > 0){
                        createPMPlanRec = (SVMXC__PM_Plan__c)appliedAccMappingRec[0];
                    }
                }
                else if(request.mode.equalsIgnoreCase('location') && !String.isBlank(mapExpNameId.get('SVMXC__Site__c'))){
                    List <Sobject> appliedLocMappingRec = applyMapping.getApplyMapping1(mapExpNameId.get('SVMXC__Site__c') ,SourceRecIdTargetObjMap, false,schemaMap);
                    if(appliedLocMappingRec != null & appliedLocMappingRec.size() > 0){
                        createPMPlanRec = (SVMXC__PM_Plan__c)appliedLocMappingRec[0];
                    }
                }
            }

            pmPlanData = getPMPlanData(createPMPlanRec); 

            system.debug(loggingLevel.WARN, 'PM Plan record after applyMapping mapping' + pmPlanData);
            
            if(request.sourceId != null){
                if(request.mode.equalsIgnoreCase('SC')){
                    // If the mapped PM plan has a value for Service Contract, query from there & store the values
                    String scId = request.sourceId;
                    if(createPMPlanRec.SVMXC__Service_Contract__c != null){
                        scId  = createPMPlanRec.SVMXC__Service_Contract__c; 
                    }

                    SVMXC__Service_Contract__c scDetails = [Select Id, Name, 
                                                            SVMXC__Company__c, SVMXC__Company__r.Name,
                                                            SVMXC__Service_Level__c, SVMXC__Service_Level__r.Name 
                                                            FROM SVMXC__Service_Contract__c
                                                            WHERE id=:scId ];
                
                    if(scDetails != null){
                        List<PREV_SetupPMPlan_Wrapper.ObjectInfo> listObjRecPicklist = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
                        
                        if(createPMPlanRec.SVMXC__Account__c == null){
                            if(scDetails.SVMXC__Company__c != null ){
                                listObjRecPicklist = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
                                PREV_SetupPMPlan_Wrapper.ObjectInfo accPicklistVal = callUtilMethods.objRecPicklistVal(scDetails.SVMXC__Company__c, scDetails.SVMXC__Company__r.Name);
                                listObjRecPicklist.add(accPicklistVal);
                                pmPlanData.accountList = listObjRecPicklist;
                                pmPlanData.accountId  = scDetails.SVMXC__Company__c;
                                createPMPlanRec.SVMXC__Account__c = scDetails.SVMXC__Company__c;
                            
                            }
                        }
                        else{
                            // IF account value is already mapped, query the value name and create picklist option
                            Account acountDetails = [Select Id, Name
                                                    FROM Account
                                                    WHERE id=:createPMPlanRec.SVMXC__Account__c ];
                            listObjRecPicklist = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
                            PREV_SetupPMPlan_Wrapper.ObjectInfo accPicklistVal = callUtilMethods.objRecPicklistVal(acountDetails.id, acountDetails.Name);
                            listObjRecPicklist.add(accPicklistVal);
                            pmPlanData.accountList = listObjRecPicklist;
                        }
                        
                        if(createPMPlanRec.SVMXC__SLA_Terms__c == null){
                            if(scDetails.SVMXC__Service_Level__c != null ){
                                pmPlanData.slaId   = scDetails.SVMXC__Service_Level__c;
                                createPMPlanRec.SVMXC__SLA_Terms__c = scDetails.SVMXC__Service_Level__c;
                            }
                        }
                        
                        PREV_SetupPMPlan_Wrapper.ObjectInfo scPicklistVal = callUtilMethods.objRecPicklistVal(scDetails.id, scDetails.name);
                        listObjRecPicklist = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
                        listObjRecPicklist.add(scPicklistVal);
                        pmPlanData.serviceContractList = listObjRecPicklist;
                        pmPlanData.serviceContractId = scDetails.Id;

                        //createPMPlanRec.SVMXC__Service_Contract__c = scDetails.Id;
                    }    
                }
                else if(request.mode.equalsIgnoreCase('Account')){
                        
                    String accId = request.sourceId;
                    if(createPMPlanRec.SVMXC__Account__c != null){
                        accId  = createPMPlanRec.SVMXC__Account__c; 
                    }

                    Account acountDetails = [Select Id, Name
                                                FROM Account
                                                WHERE id=:accId ];

                    if(acountDetails != null){
                        List<PREV_SetupPMPlan_Wrapper.ObjectInfo> listAccRecPicklist = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
                        PREV_SetupPMPlan_Wrapper.ObjectInfo accPicklistVal = callUtilMethods.objRecPicklistVal(acountDetails.id, acountDetails.name);
                        listAccRecPicklist.add(accPicklistVal);
                        pmPlanData.accountList  = listAccRecPicklist;
                        pmPlanData.accountId    = acountDetails.id;
                        createPMPlanRec.SVMXC__Account__c = acountDetails.id;
                    }                            
                }
                else if(request.mode.equalsIgnoreCase('Location')){
                    
                    String locId = request.sourceId;
                    if(createPMPlanRec.SVMXC__Location__c != null){
                        locId  = createPMPlanRec.SVMXC__Location__c; 
                    }
                    SVMXC__Site__c locationDetails = [Select Id, Name
                                                FROM SVMXC__Site__c
                                                WHERE id=:locId ];

                    if(locationDetails != null){
                        List<PREV_SetupPMPlan_Wrapper.ObjectInfo> listLocRecPicklist = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
                        PREV_SetupPMPlan_Wrapper.ObjectInfo locPicklistVal = callUtilMethods.objRecPicklistVal(locationDetails.id, locationDetails.name);
                        listLocRecPicklist.add(locPicklistVal);
                        pmPlanData.locationList  = listLocRecPicklist;
                        pmPlanData.locationId    = locationDetails.id;
                        createPMPlanRec.SVMXC__Location__c = locationDetails.id;
                    } 
                }
                else if(request.mode.equalsIgnoreCase('IB')){

                    SVMXC__Installed_Product__c IBdetails = [Select Id, Name, SVMXC__Company__c, SVMXC__Service_Contract__c, SVMXC__Service_Contract__r.Name,
                                                                SVMXC__Company__r.Name, SVMXC__Product__c
                                                                    FROM SVMXC__Installed_Product__c
                                                                    WHERE id=:request.sourceId ];


                    if(IBdetails != null){
                        List<PREV_SetupPMPlan_Wrapper.ObjectInfo> listIBRecPicklist = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
                        
                        if(createPMPlanRec.SVMXC__Account__c == null){
                            if(IBdetails.SVMXC__Company__c != null ){
                                listIBRecPicklist = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
                                PREV_SetupPMPlan_Wrapper.ObjectInfo IbPicklistVal = callUtilMethods.objRecPicklistVal(IBdetails.SVMXC__Company__c, IBdetails.SVMXC__Company__r.Name);
                                listIBRecPicklist.add(IbPicklistVal);
                                pmPlanData.accountList = listIBRecPicklist;
                                pmPlanData.accountId  = IBdetails.SVMXC__Company__c;
                                createPMPlanRec.SVMXC__Account__c = IBdetails.SVMXC__Company__c;
                            }
                        }
                        else{
                            // IF account value is already mapped, query the value name and create picklist option
                            Account acountDetails = [Select Id, Name
                                                    FROM Account
                                                    WHERE id=:createPMPlanRec.SVMXC__Account__c ];
                            listIBRecPicklist = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
                            PREV_SetupPMPlan_Wrapper.ObjectInfo accPicklistVal = callUtilMethods.objRecPicklistVal(acountDetails.id, acountDetails.Name);
                            listIBRecPicklist.add(accPicklistVal);
                            pmPlanData.accountList = listIBRecPicklist;
                        }
                        
                        if(createPMPlanRec.SVMXC__Service_Contract__c == null){
                            if(IBdetails.SVMXC__Service_Contract__c != null ){
                                listIBRecPicklist = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
                                PREV_SetupPMPlan_Wrapper.ObjectInfo slaPicklistVal = callUtilMethods.objRecPicklistVal(IBdetails.SVMXC__Service_Contract__c, IBdetails.SVMXC__Service_Contract__r.Name );
                                listIBRecPicklist.add(slaPicklistVal);
                                pmPlanData.serviceContractList = listIBRecPicklist;
                                pmPlanData.serviceContractId   = IBdetails.SVMXC__Service_Contract__c;
                                createPMPlanRec.SVMXC__Service_Contract__c = IBdetails.SVMXC__Service_Contract__c;
                            }
                        }
                        else{
                            SVMXC__Service_Contract__c scAccDetails = [Select Id, Name
                                                            FROM SVMXC__Service_Contract__c
                                                            WHERE id=:createPMPlanRec.SVMXC__Service_Contract__c ];
                            listIBRecPicklist = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
                            PREV_SetupPMPlan_Wrapper.ObjectInfo ibscPicklistVal = callUtilMethods.objRecPicklistVal(scAccDetails.id, scAccDetails.Name);
                            listIBRecPicklist.add(ibscPicklistVal);
                            pmPlanData.serviceContractList = listIBRecPicklist;
                        }
                        

                        PREV_SetupPMPlan_Wrapper.Coverage covRcWrapper = new PREV_SetupPMPlan_Wrapper.Coverage();
                        covRcWrapper.installedProductId = IBdetails.id;
                        covRcWrapper.installedProductName = IBdetails.name;
                        covRcWrapper.productId = IBdetails.SVMXC__Product__c;

                        IBLoadlistCov.add(covRcWrapper);

                        //pmPlanData.coverageList = listCov;

                    }
                }

                pmPlanData.pmPlanMappedValues = createPMPlanRec; 

            }

            // As we have got asssigned value for 
            
            if(IBLoadlistCov != null && IBLoadlistCov.size() >0) {
                pmPlanData.coverageList = IBLoadlistCov;
            }

        }


        if(svmxSettingList.containsKey('SET002') && !String.isBlank(svmxSettingList.get('SET002'))){
            pmPlanData.activatePMPlan = svmxSettingList.get('SET002');
        }

        if(svmxSettingList.containsKey('SET004') && !String.isBlank(svmxSettingList.get('SET004'))){
            pmPlanData.scPMPlanMapping = mapExpNameId.get('SVMXC__Service_Contract__c'); 
        }

        if(svmxSettingList.containsKey('SET005') && !String.isBlank(svmxSettingList.get('SET005'))){
            pmPlanData.locationPMPlanMapping = mapExpNameId.get('SVMXC__Site__c');  
        }

        if(svmxSettingList.containsKey('SET006') && !String.isBlank(svmxSettingList.get('SET006'))){
            pmPlanData.IBPMPlanMapping = mapExpNameId.get('SVMXC__Installed_Product__c');
        }

        if(svmxSettingList.containsKey('SET007')  && !String.isBlank(svmxSettingList.get('SET007')) ){
            pmPlanData.accountPMPlanMapping = mapExpNameId.get('Account');
        }

        if(svmxSettingList.containsKey('SET008') && !String.isBlank(svmxSettingList.get('SET008'))){
            pmPlanData.pmTemplatePMPlanMapping = mapExpNameId.get('SVMXC__PM_Plan_Template__c');
        }
        
        List<SObject> listPMTemplate = [Select id, name 
                                            FROM SVMXC__PM_Plan_Template__c
                                                WHERE SVMXC__SM_Schedule_Type__c = 'Condition Based' 
                                                    ORDER BY Name ASC];
        pmPlanData.pmTemplateList = callUtilMethods.recordCombobox(listPMTemplate, null); 

        
        List<PREV_SetupPMPlan_Wrapper.ObjectInfo> allPmTemplateList = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
        for(PREV_SetupPMPlan_Wrapper.ObjectInfo obj : pmPlanData.pmTemplateList){
            allPmTemplateList.add(obj);
        }
        pmPlanData.pmTemplateList.clear();
        PREV_SetupPMPlan_Wrapper.ObjectInfo objNone = new PREV_SetupPMPlan_Wrapper.ObjectInfo();
        objNone.Id = 'NONE';
        objNone.name = System.Label.COMM002_TAG005;
        pmPlanData.pmTemplateList.add(objNone);
        pmPlanData.pmTemplateList.addAll(allPmTemplateList);
        
        
        List<SObject> listSLATerms = [Select id, name 
                                        FROM SVMXC__Service_Level__c 
                                            ORDER BY Name ASC];
        pmPlanData.slaList = callUtilMethods.recordCombobox(listSLATerms, null); 
      
        List<SObject> listWOPurpose = [Select id, name,SVMXC__Template_Name__c  
                                        FROM SVMXC__Task_Template__c 
                                            ORDER BY Name ASC];  
        pmPlanData.woPurposeList = callUtilMethods.recordCombobox(listWOPurpose, 'SVMXC__Template_Name__c');

        pmPlanData.activityDateList = callUtilMethods.getActivityDateFieldList();

    
        pmPlanRes.success = true;
        pmPlanRes.warning = false;
        pmPlanRes.pmPlanRecord = pmPlanData; 
        return pmPlanRes;
    }

    public PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response getConditionGridFields( String productID, String conditionType){
        PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request fieldReq = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response fieldRes = new PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response();
        PREV_PMPlanUtils objPMPlanUtils = new PREV_PMPlanUtils();
            
        // Find the Applicable product for PM Teplate of PM Plan

        if(!String.isBlank(productID)){
            fieldReq.productId = productID;
            fieldReq.pmPlanTemplate = new PREV_SetupPMPlan_Wrapper.PM_Template_Detail();
            fieldReq.pmPlanTemplate.conditionType = conditionType;
            fieldRes = objPMPlanUtils.PREV_GetTechnicalAttribute(fieldReq);
        }
        System.debug(loggingLevel.WARN, 'Field Attirbutes' + fieldRes);
            
        
        return fieldRes; 
    }

    public PREV_SetupPMPlan_Wrapper.PM_Plan_Data getPMPlanData(SVMXC__PM_Plan__c planRec){
        System.debug(loggingLevel.WARN, 'PM Plan Rec: Get PM Plan Data' + planRec);
        

        PREV_SetupPMPlan_Wrapper.PM_Plan_Data pmPlanDataUpdate = new PREV_SetupPMPlan_Wrapper.PM_Plan_Data();
        List<PREV_SetupPMPlan_Wrapper.ObjectInfo> listobjPicklistDetail; 
        pmPlanDataUpdate.pmPlanName             = planRec.Name;
        pmPlanDataUpdate.pmPlanId               = planRec.Id;
        pmPlanDataUpdate.serviceContractId      = planRec.SVMXC__Service_Contract__c;
        pmPlanDataUpdate.pmPlanTemplateId       = planRec.SVMXC__PM_Plan_Template__c;
        pmPlanDataUpdate.accountId              = planRec.SVMXC__Account__c;
        pmPlanDataUpdate.slaId                  = planRec.SVMXC__SLA_Terms__c;
        pmPlanDataUpdate.startDate              = String.valueOf(planRec.SVMXC__Start_Date__c);
        pmPlanDataUpdate.endDate                = String.valueOf(planRec.SVMXC__End_Date__c);
        pmPlanDataUpdate.description            = planRec.SVMXC__Description__c;
        pmPlanDataUpdate.coverageType           = getCoverageType('SVMXC__Coverage_Type__c');
        pmPlanDataUpdate.scheduleType           = getCoverageType('SVMXC__Schedule_Type__c');
        pmPlanDataUpdate.woPurposeId            = planRec.SVMXC__Task_Template__c;
        pmPlanDataUpdate.locationId             = planRec.SVMXC__Location__c;
        pmPlanDataUpdate.selectedActivityDate   = planRec.SVMXC__SM_Adjustment_Activity_Date__c ;
        pmPlanDataUpdate.conditionType          = planRec.SVMXC__SM_Condition_Type__c;

        String strConditionType = planRec.SVMXC__SM_Condition_Type__c;

        
        if(pmPlanDataUpdate.accountId != null ){
            listobjPicklistDetail = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
            PREV_SetupPMPlan_Wrapper.ObjectInfo accPicklistDetail = callUtilMethods.objRecPicklistVal (planRec.SVMXC__Account__c, planRec.SVMXC__Account__r.Name);
            listobjPicklistDetail.add(accPicklistDetail);
            pmPlanDataUpdate.accountList = listobjPicklistDetail;
        }
        
        if(pmPlanDataUpdate.serviceContractId != null ){
            listobjPicklistDetail = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
            PREV_SetupPMPlan_Wrapper.ObjectInfo scPicklistDetail = callUtilMethods.objRecPicklistVal (planRec.SVMXC__Service_Contract__c, planRec.SVMXC__Service_Contract__r.Name);
            listobjPicklistDetail.add(scPicklistDetail);
            pmPlanDataUpdate.serviceContractList = listobjPicklistDetail;
        }

        if(pmPlanDataUpdate.locationId != null ){
            listobjPicklistDetail = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
            PREV_SetupPMPlan_Wrapper.ObjectInfo locPicklistDetail = callUtilMethods.objRecPicklistVal (planRec.SVMXC__Location__c, planRec.SVMXC__Location__r.Name);
            listobjPicklistDetail.add(locPicklistDetail);
            pmPlanDataUpdate.locationList = listobjPicklistDetail;
        }

        PREV_SetupPMPlan_Wrapper.PM_Template_Detail parentPMPlantemplate = new PREV_SetupPMPlan_Wrapper.PM_Template_Detail();
        parentPMPlantemplate.templateName = planRec.SVMXC__PM_Plan_Template__r.Name;
        parentPMPlantemplate.templateId = planRec.SVMXC__PM_Plan_Template__c;
        parentPMPlantemplate.advancedExpression = planRec.SVMXC__SM_Advanced_Expression__c;
        parentPMPlantemplate.useCurrentFieldVal = String.valueOf(planRec.SVMXC__PM_Plan_Template__r.SVMXC__SM_Use_Current_Field_Value__c);

        

        List<PREV_SetupPMPlan_Wrapper.ConditionRules> listscheduleDefConRule = new List<PREV_SetupPMPlan_Wrapper.ConditionRules>();

        
        for(SVMXC__PM_Schedule_Definition__c schDef: planRec.SVMXC__PM_Schedule_Definition__r){
            PREV_SetupPMPlan_Wrapper.ConditionRules schDefConRule = new PREV_SetupPMPlan_Wrapper.ConditionRules();
            schDefConRule.sequence                          = String.valueOf(schDef.SVMXC__SM_Sequence__c) ;
            schDefConRule.selectedField                     = schDef.SVMXC__SM_Attribute_Field__c;
            schDefConRule.fieldDataType                     = schDef.SVMXC__SM_Attr_Data_type__c;
            schDefConRule.fieldAttType                      = schDef.SVMXC__SM_Attribute_Type__c;
            schDefConRule.selectedOperator                  = schDef.SVMXC__SM_Operator__c;
            schDefConRule.frequency                         = String.valueOf(schDef.SVMXC__Frequency__c);
            schDefConRule.selectedFreqUnit                  = schDef.SVMXC__Frequency_Unit__c;
            schDefConRule.startAt                           = schDef.SVMXC__SM_Start_At__c;
            schDefConRule.stopAt                            = schDef.SVMXC__SM_Stop_At__c;
            schDefConRule.threshold                         = String.valueOf(schDef.SVMXC__SM_Threshold__c);
            schDefConRule.minAdjustment                     = String.valueOf(schDef.SVMXC__SM_Min_Activity_Changed__c);
            schDefConRule.maxAdjustment                     = String.valueOf(schDef.SVMXC__SM_Max_Activity_Changed__c);
            schDefConRule.adjustmentVal                     = String.valueOf(schDef.SVMXC__SM_Adjusted_Value__c);
            schDefConRule.selectedAdjustedUnit              = schDef.SVMXC__SM_Adjusted_Units__c ;
            schDefConRule.selectedAdjustmentType            = schDef.SM_Adjustment_Type__c ;
            schDefConRule.value                             = schDef.SVMXC__SM_Value__c ;

            listscheduleDefConRule.add(schDefConRule);
        }
        parentPMPlantemplate.conditionRuleList = listscheduleDefConRule;

        if( parentPMPlantemplate.conditionRuleList != null && parentPMPlantemplate.conditionRuleList.size() > 0 && String.isBlank(parentPMPlantemplate.advancedExpression)){
            parentPMPlantemplate.advancedExpression = advancedExp(parentPMPlantemplate.conditionRuleList.size());
        } 

        pmPlanDataUpdate.pmTemplateDetail = parentPMPlantemplate;


        List<PREV_SetupPMPlan_Wrapper.Coverage> planCoverageList  = new List<PREV_SetupPMPlan_Wrapper.Coverage> ();
                
        List <SVMXC__PM_Coverage__c> listPmCovergaes = new List <SVMXC__PM_Coverage__c>();
        listPmCovergaes = planRec.SVMXC__PM_Coverage__r;

        List <Id> covergaeIds = new List<Id>();
        if(listPmCovergaes != null && listPmCovergaes.size() > 0){
            for(SVMXC__PM_Coverage__c coverageRec: listPmCovergaes){
                covergaeIds.add(coverageRec.id);
            }
            
        }

        // For coverages find schedule record too

        List <String> status = new List<String>();
        status.add('Work Order Created');
        status.add('Work Order Done');
        status.add('Work Order Closed');
        status.add('Cancelled');
        status.add('Skipped');
        status.add('');

        List<SVMXC__PM_Coverage__c> listCovSchCond = [Select name, SVMXC__Product_Name__c, SVMXC__Product_Name__r.name, SVMXC__Product_Name__r.SVMXC__Product__c,SVMXC__SM_Advanced_Expression__c
                                                        FROM  SVMXC__PM_Coverage__c 
                                                            WHERE  ID IN : covergaeIds];

        Map <Id, List<SVMXC__PM_Schedule_Definition__c>> mapSchDefRec = new Map <Id, List<SVMXC__PM_Schedule_Definition__c>> ();

        for(SVMXC__PM_Schedule_Definition__c schDef: [SELECT Id, Name, SVMXC__Frequency__c , SVMXC__Frequency_Unit__c , SVMXC__Processed__c ,SM_Adjusted_Units__c, SVMXC__SM_Value__c,
                                                            SM_Adjusted_Value__c, SM_Adjustment_Type__c, SM_Attr_Data_type__c, SM_Attribute_Field__c,SM_Max_Activity_Changed__c,
                                                            SM_Min_Activity_Changed__c,SM_Operator__c, SM_Start_At__c, SM_Stop_At__c, SM_Threshold__c, SM_Threshold_Type__c, 
                                                            SM_PM_Coverage__c, SM_Sequence__c,SVMXC__Recurring__c , SVMXC__Schedule_Type__c , SVMXC__Work_Order_Purpose__c ,
                                                            SM_Attribute_Type__c 
                                                                FROM SVMXC__PM_Schedule_Definition__c WHERE SVMXC__SM_PM_Coverage__c IN : covergaeIds 
                                                                ORDER BY SVMXC__SM_Sequence__c ASC] ){

            if(!mapSchDefRec.containsKey(schDef.SVMXC__SM_PM_Coverage__c))
                mapSchDefRec.put(schDef.SVMXC__SM_PM_Coverage__c,new List<SVMXC__PM_Schedule_Definition__c>());
            mapSchDefRec.get(schDef.SVMXC__SM_PM_Coverage__c).add(schDef);    
        }

        Map <Id, List<SVMXC__PM_Schedule__c>> mapSchRec = new Map <Id, List<SVMXC__PM_Schedule__c>> ();

        for(SVMXC__PM_Schedule__c schRec: [SELECT Id, Name, SVMXC__SM_Expression_Internal_Value__c, SVMXC__SM_Work_Order_Purpose__c,SVMXC__SM_Expression_Actual_Output_Value__c,
                                                            SVMXC__PM_Schedule_Definition__c,  SVMXC__SM_Status__c, SVMXC__SM_Expression_Display_Value__c, SVMXC__SM_Sequence__c, SVMXC__SM_PM_Coverage__c, SVMXC__SM_Advanced_Expression__c
                                                                FROM SVMXC__PM_Schedule__c 
                                                                    WHERE SVMXC__SM_PM_Coverage__c IN : covergaeIds AND SVMXC__SM_Status__c IN :status 
                                                                    ORDER BY SVMXC__SM_Sequence__c ASC] ){

            if(!mapSchRec.containsKey(schRec.SVMXC__SM_PM_Coverage__c))
                mapSchRec.put(schRec.SVMXC__SM_PM_Coverage__c,new List<SVMXC__PM_Schedule__c>());
            mapSchRec.get(schRec.SVMXC__SM_PM_Coverage__c).add(schRec);    
        }

        Map <String, String> mapUniqOrderSeq = new Map <String, String>();

        for(integer j =1 ;  j<=5; j++){
            mapUniqOrderSeq.put(String.valueOf(j), '~'+String.valueOf(j));
        }


        if(listCovSchCond != null && listCovSchCond.size() > 0){
            //PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response fieldResponse = getConditionGridFields(planRec.SVMXC__PM_Plan_Template__c);
            for(SVMXC__PM_Coverage__c coverageRec: listCovSchCond){
                PREV_SetupPMPlan_Wrapper.Coverage covRcWrapper = new PREV_SetupPMPlan_Wrapper.Coverage();
                covRcWrapper.pmCovergaeId = coverageRec.id;
                covRcWrapper.pmCoverageName = coverageRec.name;
                covRcWrapper.installedProductName = coverageRec.SVMXC__Product_Name__r.name;
                covRcWrapper.installedProductId = coverageRec.SVMXC__Product_Name__c;
                covRcWrapper.productId = coverageRec.SVMXC__Product_Name__r.SVMXC__Product__c;
                covRcWrapper.advancedExpression= coverageRec.SVMXC__SM_Advanced_Expression__c;


                List<PREV_SetupPMPlan_Wrapper.Schedule> listCovSch = new List<PREV_SetupPMPlan_Wrapper.Schedule>();

                // Get Common PM Template and see if individual records have conditions, then add them to coverages
                // Add schedule record too to coverages
                if(mapSchRec != null && mapSchRec.size()> 0 && mapSchRec.get(coverageRec.id) != null){
                    for(SVMXC__PM_Schedule__c scheduleRec : mapSchRec.get(coverageRec.id)){
                        PREV_SetupPMPlan_Wrapper.Schedule covSch = new PREV_SetupPMPlan_Wrapper.Schedule();
                        covSch.scheduleId = scheduleRec.id;
                        covSch.sequence = String.valueOf(scheduleRec.SVMXC__SM_Sequence__c);
                        covSch.status = scheduleRec.SVMXC__SM_Status__c;
                        
                        // Anchal - BAC-3226. We will be using Status Label value to display in UI
                        covSch.statusLabel = getStatusType(scheduleRec.SVMXC__SM_Status__c);
                        covSch.selectedWOPurpose = scheduleRec.SVMXC__SM_Work_Order_Purpose__c != null ? scheduleRec.SVMXC__SM_Work_Order_Purpose__c : pmPlanDataUpdate.woPurposeId;
                        covSch.internalExpression = scheduleRec.SVMXC__SM_Expression_Internal_Value__c;
                        covSch.advancedExpression = scheduleRec.SVMXC__SM_Advanced_Expression__c; // Added for defect BAC - 2991 fix
                        covSch.actualOpExpression = scheduleRec.SVMXC__SM_Expression_Actual_Output_Value__c; //Added for defect BAC- 3062 fix
                        system.debug(scheduleRec.SVMXC__SM_Expression_Internal_Value__c);

                        //Added if condition for fixing defect BAC-2849
                        //This is for fixing defect BAC-2957. Added more condition of status check
                        if(!String.isBlank(scheduleRec.SVMXC__SM_Expression_Internal_Value__c)){

                            //Procssed records
                            if(!String.isBlank(scheduleRec.SVMXC__SM_Status__c) && (scheduleRec.SVMXC__SM_Status__c.equalsIgnoreCase('Work Order Created') || scheduleRec.SVMXC__SM_Status__c.equalsIgnoreCase('Work Order Done'))){
                                if(!String.isBlank(scheduleRec.SVMXC__SM_Advanced_Expression__c)){
                                    String advExpVal = scheduleRec.SVMXC__SM_Advanced_Expression__c;

                                    if(strConditionType == null || strConditionType == '' || strConditionType == 'Usage_Frequency'){
                                        covSch.scheduleName = actualOpNameMethod(scheduleRec.SVMXC__SM_Expression_Internal_Value__c, advExpVal, mapUniqOrderSeq);
                                    }
                                    else if(strConditionType == 'Criteria_Comparison'){
                                        covSch.scheduleName = actualOpNameMethodForCriteria(scheduleRec.SVMXC__SM_Expression_Internal_Value__c, advExpVal, mapUniqOrderSeq);
                                    }
                                }
                                else{
                                    covSch.scheduleName = '';
                                }
                            }
                            else{ //Non processed or other records
                                String advExpVal = String.isBlank(covRcWrapper.advancedExpression)?  pmPlanDataUpdate.pmTemplateDetail.advancedExpression : covRcWrapper.advancedExpression;

                                if(strConditionType == null || strConditionType == '' || strConditionType == 'Usage_Frequency'){
                                    covSch.scheduleName = actualOpNameMethod(scheduleRec.SVMXC__SM_Expression_Internal_Value__c, advExpVal, mapUniqOrderSeq);
                                }
                                else if(strConditionType == 'Criteria_Comparison'){
                                    covSch.scheduleName = actualOpNameMethodForCriteria(scheduleRec.SVMXC__SM_Expression_Internal_Value__c, advExpVal, mapUniqOrderSeq);
                                }
                            }
                        }

                        //covSch.scheduleName = scheduleRec.SVMXC__SM_Expression_Display_Value__c;
                        //Added if condition for fixing defect BAC-2849
                        if(!String.isBlank(scheduleRec.SVMXC__SM_Expression_Actual_Output_Value__c)){
                            //String advExpVal = String.isBlank(covRcWrapper.advancedExpression)?  pmPlanDataUpdate.pmTemplateDetail.advancedExpression : covRcWrapper.advancedExpression;

                            //This is for fixing defect BAC-2957. For processed schedules records get the advanced expresssion from schedule recrod if present
                            if(!String.isBlank(scheduleRec.SVMXC__SM_Status__c) && !String.isBlank(scheduleRec.SVMXC__SM_Advanced_Expression__c) && (scheduleRec.SVMXC__SM_Status__c.equalsIgnoreCase('Work Order Created') || scheduleRec.SVMXC__SM_Status__c.equalsIgnoreCase('Work Order Done'))){
                                String advExpVal = scheduleRec.SVMXC__SM_Advanced_Expression__c;

                                if(strConditionType == null || strConditionType == '' || strConditionType == 'Usage_Frequency'){
                                    covSch.actualOpName = actualOpNameMethod(scheduleRec.SVMXC__SM_Expression_Actual_Output_Value__c, advExpVal, mapUniqOrderSeq);
                                }
                                else if(strConditionType == 'Criteria_Comparison'){
                                    covSch.actualOpName = actualOpNameMethodForCriteria(scheduleRec.SVMXC__SM_Expression_Actual_Output_Value__c, advExpVal, mapUniqOrderSeq);
                                }
                            }
                            else{
                                covSch.actualOpName = '';
                            }
                        }
                        listCovSch.add(covSch);
                    }    
                }
                
                ///Added for defect BAC-2849 fix
                List<PREV_SetupPMPlan_Wrapper.Schedule> lstStatusBlank = new List<PREV_SetupPMPlan_Wrapper.Schedule>();
                List<PREV_SetupPMPlan_Wrapper.Schedule> lstStatusNotBlank = new List<PREV_SetupPMPlan_Wrapper.Schedule>();
                for(PREV_SetupPMPlan_Wrapper.Schedule objSchedule : listCovSch){
                    if(String.isBlank(objSchedule.status)){
                        lstStatusBlank.add(objSchedule);
                    }
                    else{
                        lstStatusNotBlank.add(objSchedule);
                    }
                }
                covRcWrapper.scheduleList = new List<PREV_SetupPMPlan_Wrapper.Schedule>();
                if(lstStatusNotBlank.size() > 0){
                    covRcWrapper.scheduleList.addAll(lstStatusNotBlank);
                }
                covRcWrapper.scheduleList.addAll(lstStatusBlank);
                System.debug('covRcWrapper.scheduleList: '+covRcWrapper.scheduleList);
                //
                //covRcWrapper.scheduleList = listCovSch;

                List<PREV_SetupPMPlan_Wrapper.ConditionRules> listCovCon = new List<PREV_SetupPMPlan_Wrapper.ConditionRules>();

                if(mapSchDefRec != null && mapSchDefRec.size()> 0 && mapSchDefRec.get(coverageRec.id) != null){
                    for(SVMXC__PM_Schedule_Definition__c coverageDefRec : mapSchDefRec.get(coverageRec.id)){

                        PREV_SetupPMPlan_Wrapper.ConditionRules covConRec;

                        if(strConditionType == null || strConditionType == '' || strConditionType == 'Usage_Frequency'){
                            covConRec = new PREV_SetupPMPlan_Wrapper.ConditionRules();
                            covConRec.sequence                          = String.valueOf(coverageDefRec.SVMXC__SM_Sequence__c) ;
                            covConRec.selectedField                     = coverageDefRec.SVMXC__SM_Attribute_Field__c;
                            covConRec.fieldDataType                      = coverageDefRec.SVMXC__SM_Attr_Data_type__c;
                            covConRec.fieldAttType                      = coverageDefRec.SVMXC__SM_Attribute_Type__c;
                            covConRec.selectedOperator                  = coverageDefRec.SVMXC__SM_Operator__c;
                            covConRec.value                             = coverageDefRec.SVMXC__SM_Value__c;
                        covConRec.frequency                         = String.valueOf(coverageDefRec.SVMXC__Frequency__c);
                        covConRec.selectedFreqUnit                  = coverageDefRec.SVMXC__Frequency_Unit__c;
                            String subStrSD = coverageDefRec.SVMXC__SM_Start_At__c; 

                            if(coverageDefRec.SVMXC__SM_Start_At__c != null){
                               Integer indexOfValSD = coverageDefRec.SVMXC__SM_Start_At__c.indexOf(' '); 
                                if(indexOfValSD != -1){
                                    subStrSD = subStrSD.substring(0, indexOfValSD); 
                                } 
                            }
                        
                        String subStrED = coverageDefRec.SVMXC__SM_Stop_At__c; 
                            if(coverageDefRec.SVMXC__SM_Stop_At__c != null){
                                Integer indexOfValED = coverageDefRec.SVMXC__SM_Stop_At__c.indexOf(' '); 
                                if(indexOfValED != -1){
                                    subStrED = subStrED.substring(0, indexOfValED); 
                                }
                        }

                            covConRec.startAt                           = subStrSD;
                            covConRec.stopAt                            = subStrED; 
                            covConRec.threshold                         = String.valueOf(coverageDefRec.SVMXC__SM_Threshold__c);
                            covConRec.minAdjustment                     = String.valueOf(coverageDefRec.SVMXC__SM_Min_Activity_Changed__c);
                            covConRec.maxAdjustment                     = String.valueOf(coverageDefRec.SVMXC__SM_Max_Activity_Changed__c);
                            covConRec.adjustmentVal                     = String.valueOf(coverageDefRec.SVMXC__SM_Adjusted_Value__c);
                            covConRec.selectedAdjustedUnit              = coverageDefRec.SVMXC__SM_Adjusted_Units__c;
                            covConRec.selectedAdjustmentType            = coverageDefRec.SVMXC__SM_Adjustment_Type__c ;
                            
                        }
                        else if(strConditionType == 'Criteria_Comparison'){
                            covConRec = new PREV_SetupPMPlan_Wrapper.ConditionRules();
                            covConRec.sequence = String.valueOf(coverageDefRec.SVMXC__SM_Sequence__c) ;
                            covConRec.selectedField = coverageDefRec.SVMXC__SM_Attribute_Field__c;
                            covConRec.fieldDataType = coverageDefRec.SVMXC__SM_Attr_Data_type__c;
                            covConRec.fieldAttType = coverageDefRec.SVMXC__SM_Attribute_Type__c;
                            covConRec.selectedOperator = coverageDefRec.SVMXC__SM_Operator__c;
                            covConRec.value = coverageDefRec.SVMXC__SM_Value__c;
                        }
                        listCovCon.add(covConRec);
                    }
                }
                
                covRcWrapper.conditionRuleList = listCovCon;
                planCoverageList.add(covRcWrapper);
            }
            pmPlanDataUpdate.coverageList = planCoverageList;
        }
        else{
            pmPlanDataUpdate.coverageList = planCoverageList; 
        }

        System.debug(loggingLevel.WARN, 'PM Plan wrapper record' + pmPlanDataUpdate);
            
        
        return pmPlanDataUpdate; 
    }

    public String advancedExp (Integer conditionRuleSize){
        String strCriteria = '';
        for(Integer i = 0; i<conditionRuleSize; i++){
            if(strCriteria.length() > 0)
                strCriteria += ' AND ';
            strCriteria += i+1;
        }
        return strCriteria;
    }


    public String actualOpNameMethod (String json, String advExp, Map<String, String>mapUniqOrderSeq){
        ScheduleInternalExpression extractedJSON =  new ScheduleInternalExpression();
        ScheduleInternalExpression  respExtractedObj = extractedJSON.parse(json);

        advExp = parseAdvExp ( advExp, respExtractedObj.rules.size(), mapUniqOrderSeq);
        
        for(integer acS = 0; acS <respExtractedObj.rules.size(); acS++){
            String ScheOPOrder = '~'+respExtractedObj.rules[acS].order; 
            Pattern MyPattern = Pattern.compile(ScheOPOrder);
            Matcher MyMatcher = MyPattern.matcher(advExp);
            advExp = MyMatcher.replaceAll(respExtractedObj.rules[acS].attrValue);
        }

        return advExp;
    }
    
    public String actualOpNameMethodForCriteria (String json, String advExp, Map<String, String>mapUniqOrderSeq){
        ScheduleInternalExpression extractedJSON =  new ScheduleInternalExpression();
        ScheduleInternalExpression  respExtractedObj = extractedJSON.parse(json);
        Map<String, String> mapOperatorTextToOperatorSymbol = new Map<String, String>();
        mapOperatorTextToOperatorSymbol.put('eq', '=');
        mapOperatorTextToOperatorSymbol.put('gt', '>');
        mapOperatorTextToOperatorSymbol.put('lt', '<');

        advExp = parseAdvExp ( advExp, respExtractedObj.rules.size(), mapUniqOrderSeq);
        
        for(integer acS = 0; acS <respExtractedObj.rules.size(); acS++){
            String ScheOPOrder = '~'+respExtractedObj.rules[acS].order; 
            Pattern MyPattern = Pattern.compile(ScheOPOrder);
            Matcher MyMatcher = MyPattern.matcher(advExp);

            String strOperatorSymbol = '';
            String strOperatorText = respExtractedObj.rules[acS].operator;
            if(strOperatorText != null && mapOperatorTextToOperatorSymbol.containsKey(strOperatorText)){
                strOperatorSymbol = mapOperatorTextToOperatorSymbol.get(strOperatorText);
            }
            String strOutputName = respExtractedObj.rules[acS].attrLabel+' '+strOperatorSymbol+' '+respExtractedObj.rules[acS].attrValue;
            advExp = MyMatcher.replaceAll(strOutputName);
        }

        return advExp;
    }
    
    public PREV_SetupPMPlan_Wrapper.PM_Plan_Response getPMTemplateDetails(PREV_SetupPMPlan_Wrapper.PM_Plan_Request request){
        

        PREV_SetupPMPlan_Wrapper.PM_Plan_Response pmPlanRes = new PREV_SetupPMPlan_Wrapper.PM_Plan_Response();
        PREV_SetupPMPlan_Wrapper.PM_Plan_Data pmPlanData = request.pmPlanDataUpdates;
        
        pmPlanRes.success = true;

        // Don't create coverages, if no template Id is defined.
        if(request.pmTemplateId != null) {
            try{
                SVMXC__PM_Plan_Template__c  pmTemplateRec = [Select Id, Name, SVMXC__SM_Work_Order_Purpose__c, SVMXC__Coverage_Type__c, SVMXC__SM_Condition_Type__c, SVMXC__SM_Schedule_Type__c,
                                                                SVMXC__SM_Adjustment_Activity_Date__c , SVMXC__IB_Criteria__c, SVMXC__SM_Advanced_Expression__c, SVMXC__SM_Use_Current_Field_Value__c,
                                                                (SELECT Id, Name, SVMXC__SM_Adjusted_Units__c, SVMXC__SM_Adjusted_Value__c, SVMXC__SM_Adjustment_Type__c,SVMXC__Frequency__c, SVMXC__Frequency_Unit__c, 
                                                                    SVMXC__SM_Attr_Data_type__c, SVMXC__SM_Attribute_Type__c, SVMXC__SM_IB_Attribute__c,SVMXC__SM_Max_Activity_Changed__c,
                                                                    SVMXC__SM_Min_Activity_Changed__c,SVMXC__SM_Operator__c,SVMXC__SM_Value__c,SVMXC__SM_Start_At__c, SVMXC__SM_Stop_At__c,SVMXC__SM_Threshold__c,
                                                                    SVMXC__SM_Threshold_Type__c, SVMXC__Sequence__c
                                                                    FROM SVMXC__PM_Schedule_Templates__r),
                                                                (SELECT id, SVMXC__Product_Line__c, SVMXC__Product_Family__c, SVMXC__Product__c, SVMXC__PM_Plan_Template__c 
                                                                        FROM SVMXC__PM_Applicable_Products__r )
                                                                From SVMXC__PM_Plan_Template__c 
                                                                WHERE id =: request.pmTemplateId];
                
                //pmPlanData.woPurposeId = pmTemplateRec.SVMXC__SM_Work_Order_Purpose__c;
                //pmPlanData.selectedActivityDate = pmTemplateRec.SVMXC__SM_Adjustment_Activity_Date2__c ;

                //Get field store for condition grid
                // Get field store for condition grid
                //PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objTAResponse = getConditionGridFields(pmTemplateRec.id, '');
                pmPlanData.pmPlanMappedValues.SVMXC__SM_Advanced_Expression__c = pmTemplateRec.SVMXC__SM_Advanced_Expression__c;
                System.debug(loggingLevel.WARN, 'pmPlanData.pmTemplatePMPlanMapping: ' + pmPlanData.pmTemplatePMPlanMapping);

                if(!String.isBlank(pmPlanData.pmTemplatePMPlanMapping)) {
                    Map<String,Sobject> SourceRecIdTargetObjMap = new Map<String,Sobject> (); 
                    SFM_ApplyMapping applyMapping = new SFM_ApplyMapping();
                    Map <String, Schema.SObjectType> schemaMap = new Map <String, Schema.SObjectType>();
                    Map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                    for(Schema.SObjectType s : gd.values()){
                        schemaMap.put(s.getDescribe().getName(),s);
                    }
                    SourceRecIdTargetObjMap.put(request.pmTemplateId,  pmPlanData.pmPlanMappedValues);

                    system.debug(pmPlanData.pmPlanMappedValues);
                    List <Sobject> appliedPMTempMappingRec = applyMapping.getApplyMapping1(pmPlanData.pmTemplatePMPlanMapping ,SourceRecIdTargetObjMap, false,schemaMap);
                    if(appliedPMTempMappingRec != null & appliedPMTempMappingRec.size() > 0){
                        pmPlanData.pmPlanMappedValues = (SVMXC__PM_Plan__c)appliedPMTempMappingRec[0];
                    }

                }                                              

                System.debug(loggingLevel.WARN, 'PM Plan after applying PM Template Mapping' + pmPlanData.pmPlanMappedValues);
         
                
                PREV_SetupPMPlan_Wrapper.PM_Template_Detail templateDetail = new PREV_SetupPMPlan_Wrapper.PM_Template_Detail();
                templateDetail.templateName = pmTemplateRec.name;
                templateDetail.templateId = pmTemplateRec.id;
                templateDetail.scheduleType = pmTemplateRec.SVMXC__SM_Schedule_Type__c ;
                templateDetail.coverageType = pmTemplateRec.SVMXC__Coverage_Type__c;
                templateDetail.installedProductFilter = pmTemplateRec.SVMXC__IB_Criteria__c;
                templateDetail.conditionType = pmTemplateRec.SVMXC__SM_Condition_Type__c;

                if(pmTemplateRec.SVMXC__PM_Applicable_Products__r != null && pmTemplateRec.SVMXC__PM_Applicable_Products__r.size()> 0){
                    templateDetail.product = pmTemplateRec.SVMXC__PM_Applicable_Products__r[0].SVMXC__Product__c;
                }
                else{
                    templateDetail.product = '';
                }
                
                
                if(pmPlanData.pmPlanMappedValues != null){
                    if(!String.isBlank(pmPlanData.pmPlanMappedValues.SVMXC__SM_Adjustment_Activity_Date__c)){
                        templateDetail.activityDate = pmPlanData.pmPlanMappedValues.SVMXC__SM_Adjustment_Activity_Date__c;
                    }
                    else{
                        templateDetail.activityDate = pmTemplateRec.SVMXC__SM_Adjustment_Activity_Date__c;
                        pmPlanData.pmPlanMappedValues.SVMXC__SM_Adjustment_Activity_Date__c = pmTemplateRec.SVMXC__SM_Adjustment_Activity_Date__c;
                    }

                    if(pmPlanData.pmPlanMappedValues.SVMXC__Task_Template__c != null){
                        templateDetail.workOrderPurpose = pmPlanData.pmPlanMappedValues.SVMXC__Task_Template__c;
                    }
                    else{
                        templateDetail.workOrderPurpose = pmTemplateRec.SVMXC__SM_Work_Order_Purpose__c;
                        pmPlanData.pmPlanMappedValues.SVMXC__Task_Template__c = pmTemplateRec.SVMXC__SM_Work_Order_Purpose__c;
                    }

                    if(!String.isBlank(pmPlanData.pmPlanMappedValues.SVMXC__SM_Advanced_Expression__c)){
                        templateDetail.advancedExpression = pmPlanData.pmPlanMappedValues.SVMXC__SM_Advanced_Expression__c;
                    }else{
                        templateDetail.advancedExpression = pmTemplateRec.SVMXC__SM_Advanced_Expression__c;
                        pmPlanData.pmPlanMappedValues.SVMXC__SM_Advanced_Expression__c = pmTemplateRec.SVMXC__SM_Advanced_Expression__c;
                    }
                }
                else{
                    templateDetail.activityDate = pmTemplateRec.SVMXC__SM_Adjustment_Activity_Date__c;
                    templateDetail.workOrderPurpose = pmTemplateRec.SVMXC__SM_Work_Order_Purpose__c;
                    templateDetail.advancedExpression = pmTemplateRec.SVMXC__SM_Advanced_Expression__c;
                    System.debug(loggingLevel.WARN, 'pmTemplateRec.SVMXC__SM_Work_Order_Purpose__c else: ' + pmTemplateRec.SVMXC__SM_Work_Order_Purpose__c);
                }
                templateDetail.useCurrentFieldVal = String.valueOf(pmTemplateRec.SVMXC__SM_Use_Current_Field_Value__c);
                //templateDetail.mapOfKeyAndListOfKeyValue = objTAResponse.mapOfKeyAndListOfKeyValue;


                // We need to create coverages for IB as well
                SVMXC__PM_Plan__c createPMPlan = new SVMXC__PM_Plan__c(
                                                                             SVMXC__Account__c = pmPlanData.pmPlanMappedValues.SVMXC__Account__c,
                                                                             SVMXC__Service_Contract__c = pmPlanData.pmPlanMappedValues.SVMXC__Service_Contract__c,
                                                                             SVMXC__Location__c = pmPlanData.pmPlanMappedValues.SVMXC__Location__c);
                
                
                if(pmPlanData.startDate != null && pmPlanData.startDate != 'undefined'){
                    String startDateTimeUnsaved = Datetime.valueOf(pmPlanData.startDate.replace('T', ' ')).format('yyyy-MM-dd HH:mm:ss',UserInfo.getTimeZone().getID());
                    createPMPlan.SVMXC__Start_Date__c = Datetime.valueOf(startDateTimeUnsaved).date();

                }

                if(pmPlanData.endDate != null && pmPlanData.endDate != 'undefined'){
                    String endDateTimeUnsaved = Datetime.valueOf(pmPlanData.endDate.replace('T', ' ')).format('yyyy-MM-dd HH:mm:ss',UserInfo.getTimeZone().getID());
                    createPMPlan.SVMXC__End_Date__c = Datetime.valueOf(endDateTimeUnsaved).date();
                }

                // clear existing values of schedules
                listSchWrapper.clear();
                

                // While creating new PM Coverages, always load conditions to parent pm Plan structure
                List<SVMXC__PM_Schedule_Template__c> listSchTemplates = new List<SVMXC__PM_Schedule_Template__c>(); 
                listSchTemplates =  pmTemplateRec.SVMXC__PM_Schedule_Templates__r;

                List<PREV_SetupPMPlan_Wrapper.ConditionRules> listWrapperConditionRule = new List<PREV_SetupPMPlan_Wrapper.ConditionRules>();


                for(SVMXC__PM_Schedule_Template__c schTemp : listSchTemplates){
                    PREV_SetupPMPlan_Wrapper.ConditionRules struConditionRule = new PREV_SetupPMPlan_Wrapper.ConditionRules();
                    struConditionRule.sequence                          = String.valueOf(Integer.valueOf(schTemp.SVMXC__Sequence__c)) ;
                    struConditionRule.selectedField                     = schTemp.SVMXC__SM_IB_Attribute__c;
                    struConditionRule.fieldDataType                      = schTemp.SVMXC__SM_Attr_Data_type__c;
                    struConditionRule.fieldAttType                      = schTemp.SVMXC__SM_Attribute_Type__c;
                    struConditionRule.selectedOperator                  = schTemp.SVMXC__SM_Operator__c;
                    struConditionRule.value                             = schTemp.SVMXC__SM_Value__c;
                    struConditionRule.frequency                         = String.valueOf(schTemp.SVMXC__Frequency__c);
                    struConditionRule.selectedFreqUnit                  = schTemp.SVMXC__Frequency_Unit__c;
                    struConditionRule.startAt                           = schTemp.SVMXC__SM_Start_At__c;
                    struConditionRule.stopAt                            = schTemp.SVMXC__SM_Stop_At__c;
                    struConditionRule.threshold                         = String.valueOf(schTemp.SVMXC__SM_Threshold__c);
                    struConditionRule.minAdjustment                     = String.valueOf(schTemp.SVMXC__SM_Min_Activity_Changed__c);
                    struConditionRule.maxAdjustment                     = String.valueOf(schTemp.SVMXC__SM_Max_Activity_Changed__c);
                    struConditionRule.adjustmentVal                     = String.valueOf(schTemp.SVMXC__SM_Adjusted_Value__c);
                    struConditionRule.selectedAdjustedUnit              = schTemp.SVMXC__SM_Adjusted_Units__c;
                    struConditionRule.selectedAdjustmentType            = schTemp.SVMXC__SM_Adjustment_Type__c ;
                    
                    listWrapperConditionRule.add(struConditionRule);
                }

                String pmPlanMode = request.mode;
                if(!String.isBlank(pmPlanMode) && !pmPlanMode.equalsIgnoreCase('IB')){
                system.debug(pmTemplateRec);
                    List<SVMXC__PM_Coverage__c> listOfPMPlanCov = createIBCoverage(createPMPlan, pmTemplateRec, request.mode);
                    if(listOfPMPlanCov != null && listOfPMPlanCov.size() > 0){
                        pmPlanData.coverageList = getPMPlanCovergaes(listOfPMPlanCov);
                    }
                }
                else {
                    pmPlanData.coverageList = pmPlanData.coverageList;
                }

                templateDetail.conditionRuleList = listWrapperConditionRule;


                System.debug(loggingLevel.WARN, 'PM Template Wrapper' +templateDetail);

                
                if(templateDetail.conditionRuleList != null && templateDetail.conditionRuleList.size() > 0 && String.isBlank(templateDetail.advancedExpression)){
                    templateDetail.advancedExpression  = advancedExp(templateDetail.conditionRuleList.size()); 
                } 

                System.debug(loggingLevel.WARN, 'PM Template Adv Exp' +templateDetail.advancedExpression);

                //System.debug(pmPlanData.coverageList);
                pmPlanData.pmTemplateDetail = templateDetail; 

                pmPlanRes.pmPlanRecord = pmPlanData;
                pmPlanRes.success = true;
            }
            catch(Exception e){
                pmPlanRes.success = false;
                pmPlanRes.messageList = new List<String>();
                pmPlanRes.messageList.add(e.getMessage());
            }
            
        }    


        return pmPlanRes; 
    }


    // To do: Use activatePMPlan value to active PM Plan.
    public List<SVMXC__PM_Coverage__c> createIBCoverage(SVMXC__PM_Plan__c prodBasedPMPlans, SVMXC__PM_Plan_Template__c templateRec, String mode)
    {
        String PMTemplateID ;
        List<SVMXC__PM_Applicable_Product__c> lstApplicablePMProducts = new List<SVMXC__PM_Applicable_Product__c>();
        List<SVMXC__PM_Coverage__c> lstPMCov = new List<SVMXC__PM_Coverage__c>();
        Map<string, set<string>> mapPMTempLstApplProd = new Map<string, set<string>>();
        Map<string, set<string>> mapPMTempLstApplProdLine = new Map<string, set<string>>();
        Map<string, set<string>> mapPMTempLstApplProdFamily = new Map<string, set<string>>();
        
        SVMXC__ServiceMax_Processes__c productCriteria; 

        if(templateRec != null)
        {
            if(templateRec.SVMXC__IB_Criteria__c != null){
                productCriteria = [select id, SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id =:templateRec.SVMXC__IB_Criteria__c ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            
            lstApplicablePMProducts = [select id, SVMXC__Product_Line__c, SVMXC__Product_Family__c, SVMXC__Product__c, SVMXC__PM_Plan_Template__c from SVMXC__PM_Applicable_Product__c where SVMXC__PM_Plan_Template__c =: templateRec.id];
            
            system.debug(loggingLevel.WARN, 'List of Applicable Products queried are: ' + lstApplicablePMProducts + ' and size is: ' + lstApplicablePMProducts.size());
            
            for(SVMXC__PM_Applicable_Product__c appProd : lstApplicablePMProducts)
            {
                if(appProd.SVMXC__Product__c != null)
                {
                    if(!mapPMTempLstApplProd.containsKey(appProd.SVMXC__PM_Plan_Template__c))
                        mapPMTempLstApplProd.put(appProd.SVMXC__PM_Plan_Template__c, new set<string>());
                    mapPMTempLstApplProd.get(appProd.SVMXC__PM_Plan_Template__c).add(appProd.SVMXC__Product__c);
                }
                if(appProd.SVMXC__Product_Line__c != null)
                {
                    if(!mapPMTempLstApplProdLine.containsKey(appProd.SVMXC__PM_Plan_Template__c))
                        mapPMTempLstApplProdLine.put(appProd.SVMXC__PM_Plan_Template__c, new set<string>());
                    mapPMTempLstApplProdLine.get(appProd.SVMXC__PM_Plan_Template__c).add(appProd.SVMXC__Product_Line__c);
                }
                if(appProd.SVMXC__Product_Family__c != null)
                {
                    if(!mapPMTempLstApplProdFamily.containsKey(appProd.SVMXC__PM_Plan_Template__c))
                        mapPMTempLstApplProdFamily.put(appProd.SVMXC__PM_Plan_Template__c, new set<string>());
                    mapPMTempLstApplProdFamily.get(appProd.SVMXC__PM_Plan_Template__c).add(appProd.SVMXC__Product_Family__c);
                }
            }
            
            system.debug(loggingLevel.WARN, '=======Product==== ' + mapPMTempLstApplProd + '\n=======Product Line==== ' + mapPMTempLstApplProdLine + '\n=======Product Family==== ' + mapPMTempLstApplProdFamily);
            PMTemplateID = templateRec.id;
        }   
            string querySOQL = '';
            
            set<string> setStr = new set<string>(); 
            set<string> setStr1 = new set<string>();
            set<string> setStr2 =  new set<string>();
            string whereClause = null;

            if(productCriteria != null){
                whereClause = productCriteria.SVMXC__Parent_Object_Criteria__c;   
            }
                    
            if(mode.equalsIgnoreCase('Account'))
            {
                string strAccId = prodBasedPMPlans.SVMXC__Account__c;
                if(whereClause != null && whereClause.length() > 0)
                    querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where SVMXC__Company__c =: strAccId AND (' + whereClause + ')';
                else
                    querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where SVMXC__Company__c =: strAccId' ;
            }
            else if(mode.equalsIgnoreCase('Location'))
            {
                string strLocId = prodBasedPMPlans.SVMXC__Location__c;
                if(whereClause != null && whereClause.length() > 0)
                    querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where SVMXC__Site__c =: strLocId AND (' + whereClause + ')';
                else
                    querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where SVMXC__Site__c =: strLocId';
            }
            else if(mode.equalsIgnoreCase('SC'))
            {
                map<string, string> mapIBToSC = new map<string, string>();
                
                List<SVMXC__Service_Contract_Products__c> lstCoveredProds = [select id, SVMXC__Service_Contract__c, SVMXC__Installed_Product__c from SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__c =: prodBasedPMPlans.SVMXC__Service_Contract__c];
                system.debug(loggingLevel.WARN, 'List of Covered Products queried are: ' + lstCoveredProds + ' and size is: ' + lstCoveredProds.size());
                if(lstCoveredProds != null && lstCoveredProds.size() >0)
                {
                    Set<string> setIBIDs = new Set<string>();
                    for(SVMXC__Service_Contract_Products__c covProd : lstCoveredProds)
                        setIBIDs.add(covProd.SVMXC__Installed_Product__c);
                    if(whereClause != null && whereClause.length() > 0)
                        querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where Id IN: setIBIDs AND (' + whereClause + ')';
                    else
                        querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where Id IN: setIBIDs';
                }
            }
            
            if(((mapPMTempLstApplProd != null && mapPMTempLstApplProd.size() > 0) || (mapPMTempLstApplProdLine != null && mapPMTempLstApplProdLine.size() > 0) || (mapPMTempLstApplProdFamily != null && mapPMTempLstApplProdFamily.size() > 0)) && querySOQL != null && querySOQL.length() >0)
                querySOQL += ' AND (';
            
            if(mapPMTempLstApplProd != null && mapPMTempLstApplProd.size() > 0)
            {
                if(mapPMTempLstApplProd.containsKey(PMTemplateID) && mapPMTempLstApplProd.get(PMTemplateID) != null && mapPMTempLstApplProd.get(PMTemplateID).size() > 0)
                {
                    setStr = mapPMTempLstApplProd.get(PMTemplateID);
                    if(querySOQL != null && querySOQL.length() > 0)
                    querySOQL += 'SVMXC__Product__c IN: setStr';
                }
            }
            if(mapPMTempLstApplProdLine != null && mapPMTempLstApplProdLine.size() > 0)
            {
                if(mapPMTempLstApplProd != null && mapPMTempLstApplProd.size() > 0)
                {
                    if(querySOQL != null && querySOQL.length() > 0)
                    querySOQL += ' OR ';
                }
                if(mapPMTempLstApplProdLine.containsKey(PMTemplateID) && mapPMTempLstApplProdLine.get(PMTemplateID) != null && mapPMTempLstApplProdLine.get(PMTemplateID).size() > 0)
                {
                    setStr1 = mapPMTempLstApplProdLine.get(PMTemplateID);
                    if(querySOQL != null && querySOQL.length() > 0)
                    querySOQL += 'SVMXC__Product__r.SVMXC__Product_Line__c IN: setStr1';
                }
            }
            if(mapPMTempLstApplProdFamily != null && mapPMTempLstApplProdFamily.size() > 0)
            {
                if((mapPMTempLstApplProd != null && mapPMTempLstApplProd.size() > 0) || (mapPMTempLstApplProdLine != null && mapPMTempLstApplProdLine.size() > 0))
                {
                    if(querySOQL != null && querySOQL.length() > 0)
                    querySOQL += ' OR ';
                }
                if(mapPMTempLstApplProdFamily.containsKey(PMTemplateID) && mapPMTempLstApplProdFamily.get(PMTemplateID) != null && mapPMTempLstApplProdFamily.get(PMTemplateID).size() > 0)
                {
                    setStr2 = mapPMTempLstApplProdFamily.get(PMTemplateID);
                    if(querySOQL != null && querySOQL.length() > 0)
                    querySOQL += 'SVMXC__Product__r.Family IN: setStr2';
                }
            }
            
            if(((mapPMTempLstApplProd != null && mapPMTempLstApplProd.size() > 0) || (mapPMTempLstApplProdLine != null && mapPMTempLstApplProdLine.size() > 0) || (mapPMTempLstApplProdFamily != null && mapPMTempLstApplProdFamily.size() > 0)) && querySOQL != null && querySOQL.length() > 0){
                querySOQL += ')';
            }
            
            system.debug(loggingLevel.WARN, 'Query Prepared is: ' + querySOQL);
            if(querySOQL != null && querySOQL.length() > 0)
                lstInstalledProducts = database.query(querySOQL);
            system.debug(loggingLevel.WARN, 'List of IBs queried: ' + lstInstalledProducts);
                
            if(lstInstalledProducts != null && lstInstalledProducts.size() > 0)
            {
                for(SVMXC__Installed_Product__c IB: lstInstalledProducts)
                {
                    SVMXC__PM_Coverage__c pmCov = new SVMXC__PM_Coverage__c();
                    pmCov.SVMXC__Product_Name__c = IB.Id;
                    lstPMCov.add(pmCov);
                }
            }
            system.debug(loggingLevel.WARN, 'List of PM Coverage to Create: ' + lstPMCov);

        return lstPMCov;
        
    }
    
    /** Input parameter: Method accepts PREV_SetupPMPlan_Wrapper.PM_Plan_Request as request
     * Output parameter:  Returns PREV_SetupPMPlan_Wrapper.PM_Plan_Response
     * Functionality: It saves/updates PM plan and it's corresponding records. If pmPlanId is not given, 
     *                then it's a new record else update to existing one 
    **/
    
    public PREV_SetupPMPlan_Wrapper.PM_Plan_Response savePMPlan(PREV_SetupPMPlan_Wrapper.PM_Plan_Request request) {
        PREV_SetupPMPlan_Wrapper.PM_Plan_Response savePmPlanRes = new PREV_SetupPMPlan_Wrapper.PM_Plan_Response();
        PREV_SetupPMPlan_Wrapper.PM_Plan_Data pmPlanData = request.pmPlanDataUpdates; 
        Savepoint objSavepoint; 
        try{


            objSavepoint = Database.setSavepoint();

            // TO DO: Activate PM Plan only when there are schedule & covergaes associated with PM Plan
            Boolean activatePMPlan = Boolean.valueOf(pmPlanData.activatePMPlan);

            
            SVMXC__PM_Plan__c newPMPlanRec = new SVMXC__PM_Plan__c();

            // Use all mapped values to create a PM Plan recrod, then update them with latest values
            if(pmPlanData.pmPlanMappedValues != null){
                newPMPlanRec = (SVMXC__PM_Plan__c)pmPlanData.pmPlanMappedValues;
            }


            system.debug(loggingLevel.WARN, 'PM Plan record to Save ' + newPMPlanRec);

            newPMPlanRec.SVMXC__Service_Contract__c = pmPlanData.serviceContractId;
            newPMPlanRec.Name = pmPlanData.pmPlanName;
            newPMPlanRec.SVMXC__PM_Plan_Template__c = pmPlanData.pmPlanTemplateId;
            newPMPlanRec.SVMXC__Account__c = pmPlanData.accountId;
            newPMPlanRec.SVMXC__Location__c = pmPlanData.locationId;
            newPMPlanRec.SVMXC__SLA_Terms__c = pmPlanData.slaId;

            
            String startDateTime = Datetime.valueOf(pmPlanData.startDate.replace('T', ' ')).format('yyyy-MM-dd HH:mm:ss',UserInfo.getTimeZone().getID());
            newPMPlanRec.SVMXC__Start_Date__c = Datetime.valueOf(startDateTime).date();

            String endDateTime = Datetime.valueOf(pmPlanData.endDate.replace('T', ' ')).format('yyyy-MM-dd HH:mm:ss',UserInfo.getTimeZone().getID());
            newPMPlanRec.SVMXC__End_Date__c = Datetime.valueOf(endDateTime).date();
            
            newPMPlanRec.SVMXC__SM_Adjustment_Activity_Date__c  = pmPlanData.pmTemplateDetail.activityDate;
            newPMPlanRec.SVMXC__Task_Template__c = pmPlanData.pmTemplateDetail.workOrderPurpose;
            newPMPlanRec.SVMXC__Description__c  = pmPlanData.description;
            newPMPlanRec.SVMXC__Coverage_Type__c  = pmPlanData.selectedCovergaeType;
            newPMPlanRec.SVMXC__Schedule_Type__c  = pmPlanData.selectedScheduleType;
            newPMPlanRec.SVMXC__SM_Condition_Type__c  = pmPlanData.conditionType;

            // Check if PM template Expression is valid, then only do further processing
            Boolean isValidExp = true; 
            if(pmPlanData.pmTemplateDetail.conditionRuleList != null && pmPlanData.pmTemplateDetail.conditionRuleList.size() > 0){
                PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request validateExp = new PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request();
                validateExp.advancedExpression =  pmPlanData.pmTemplateDetail.advancedExpression;
                validateExp.conditionRuleList = pmPlanData.pmTemplateDetail.conditionRuleList;
                PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response  validExpRes = validateExpression(validateExp);
                isValidExp = Boolean.valueOf(validExpRes.success);
            }
            
            if(isValidExp){
                newPMPlanRec.SVMXC__SM_Advanced_Expression__c  = pmPlanData.pmTemplateDetail.advancedExpression;
            

                List<SVMXC__PM_Schedule_Definition__c> listScheduleDefId = new List <SVMXC__PM_Schedule_Definition__c>();
                List<SVMXC__PM_Coverage__c> listCovId = new List <SVMXC__PM_Coverage__c>();
                List<SVMXC__PM_Schedule__c> listScheduleRecId = new List <SVMXC__PM_Schedule__c>();
        
        
                
                if(pmPlanData.pmPlanId != null){
                    newPMPlanRec.Id  = pmPlanData.pmPlanId;

                    SVMXC__PM_Plan__c pmPlanRec = [SELECT ID, 
                                        (SELECT Id 
                                            FROM SVMXC__PM_Schedule_Definition__r),
                                        (SELECT Id
                                            FROM SVMXC__PM_Coverage__r),
                                        (SELECT Id, SVMXC__SM_Status__c
                                            FROM SVMXC__PM_Schedule__r 
                                            //WHERE SVMXC__SM_Status__c = '')
                                            //This condition is commented for fixing defect BAC-2849 where 2nd issue: Processed schedules getting deleted when template is removed.
                                            WHERE SVMXC__SM_Status__c = '' OR SVMXC__SM_Status__c = 'Work Order Created' OR SVMXC__SM_Status__c = 'Work Order Done')
                                     FROM SVMXC__PM_Plan__c
                                     WHERE ID =:pmPlanData.pmPlanId];

                    for(SVMXC__PM_Schedule_Definition__c scheduleDefinition : pmPlanRec.SVMXC__PM_Schedule_Definition__r){
                        listScheduleDefId.add(scheduleDefinition);
                    }

                    for(SVMXC__PM_Coverage__c pmPlancovergaeRec : pmPlanRec.SVMXC__PM_Coverage__r){
                        listCovId.add(pmPlancovergaeRec);
                    }

                    for(SVMXC__PM_Schedule__c pmPlanScheduleRec : pmPlanRec.SVMXC__PM_Schedule__r){
                        //if(String.isBlank(pmPlanScheduleRec.SVMXC__SM_Status__c)){ Edited for fixing defect BAC-2849
                            listScheduleRecId.add(pmPlanScheduleRec);
                        //}
                    }
                }

                system.debug(loggingLevel.WARN, 'PM Plan record to Save: later stage ' + newPMPlanRec);

                
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(newPMPlanRec, COMM_SecurityUtils.Access.Upsertable)){
                    upsert newPMPlanRec; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
                

                // Default conditions should always be there
                List<PREV_SetupPMPlan_Wrapper.ConditionRules> listPMPlanSchDef = new List<PREV_SetupPMPlan_Wrapper.ConditionRules>();
                listPMPlanSchDef = pmPlanData.pmTemplateDetail.conditionRuleList; 

                List <SVMXC__PM_Schedule_Definition__c> listSchDef = new List <SVMXC__PM_Schedule_Definition__c>();


                
                // Default Schedule Definition
                if(listPMPlanSchDef != null){ //Added condition for defect BAC-2720 fix. Null was coming for the variable 'listPMPlanSchDef' and it was throwing an exception 'Attempt to de-reference a null object'.
                    for(PREV_SetupPMPlan_Wrapper.ConditionRules pmPlanSchdef : listPMPlanSchDef){
                        SVMXC__PM_Schedule_Definition__c schdefRule;
                        if(newPMPlanRec.SVMXC__SM_Condition_Type__c == null || newPMPlanRec.SVMXC__SM_Condition_Type__c == '' || newPMPlanRec.SVMXC__SM_Condition_Type__c == 'Usage_Frequency'){
                            schdefRule = new SVMXC__PM_Schedule_Definition__c(SVMXC__SM_Sequence__c = Decimal.valueOf(pmPlanSchdef.sequence),
                                SVMXC__SM_Attribute_Field__c = pmPlanSchdef.selectedField,
                                SVMXC__SM_Attribute_Type__c = pmPlanSchdef.fieldAttType,
                                SVMXC__SM_Attr_Data_type__c = pmPlanSchdef.fieldDataType,
                                SVMXC__SM_Operator__c = pmPlanSchdef.selectedOperator,
                                SVMXC__Frequency__c = Decimal.valueOf(pmPlanSchdef.frequency),
                                SVMXC__Frequency_Unit__c = pmPlanSchdef.selectedFreqUnit,
                                SVMXC__SM_Start_At__c = pmPlanSchdef.startAt,
                                SVMXC__SM_Stop_At__c = pmPlanSchdef.stopAt,
                                SVMXC__SM_Threshold__c = pmPlanSchdef.threshold != null? Decimal.valueOf(pmPlanSchdef.threshold): null,
                                SVMXC__SM_Adjustment_Type__c = pmPlanSchdef.selectedAdjustmentType,
                                SVMXC__SM_Min_Activity_Changed__c = pmPlanSchdef.minAdjustment != null? Decimal.valueOf(pmPlanSchdef.minAdjustment): null,
                                SVMXC__SM_Max_Activity_Changed__c = pmPlanSchdef.maxAdjustment != null ? Decimal.valueOf(pmPlanSchdef.maxAdjustment): null,
                                SVMXC__SM_Adjusted_Value__c = pmPlanSchdef.adjustmentVal != null ? Decimal.valueOf(pmPlanSchdef.adjustmentVal): null,
                                SVMXC__SM_Adjusted_Units__c = pmPlanSchdef.selectedAdjustedUnit,
                                SVMXC__PM_Plan__c = newPMPlanRec.id
                            );
                        }
                        else if(newPMPlanRec.SVMXC__SM_Condition_Type__c == 'Criteria_Comparison'){
                            schdefRule = new SVMXC__PM_Schedule_Definition__c(SVMXC__SM_Sequence__c = Decimal.valueOf(pmPlanSchdef.sequence),
                                SVMXC__SM_Attribute_Field__c = pmPlanSchdef.selectedField,
                                SVMXC__SM_Attribute_Type__c = pmPlanSchdef.fieldAttType,
                                SVMXC__SM_Attr_Data_type__c = pmPlanSchdef.fieldDataType,
                                SVMXC__SM_Operator__c = pmPlanSchdef.selectedOperator,
                                SVMXC__SM_Value__c = pmPlanSchdef.value,
                                SVMXC__PM_Plan__c = newPMPlanRec.id
                            );
                        }
                        listSchDef.add(schdefRule); 
                    }
                }
                
                if(pmPlanData.coverageList.size() > 0){

                    // If there are coveregaes, recreate the Schedule

                    // After inserting PM Plan, update the default Schedule definition values from PM Template Detail
                    List<SVMXC__PM_Coverage__c>  pmCoverage = new List<SVMXC__PM_Coverage__c>();
                    List<SVMXC__PM_Schedule__c>  listSch    = new List<SVMXC__PM_Schedule__c>();

                    if(pmPlanData.coverageList != null && pmPlanData.coverageList.size() >0){
                        for(PREV_SetupPMPlan_Wrapper.Coverage wrappperCov : pmPlanData.coverageList ){
                            SVMXC__PM_Coverage__c covRec = new SVMXC__PM_Coverage__c (  SVMXC__Product_Name__c = wrappperCov.installedProductId,
                                                                                            SVMXC__SM_Advanced_Expression__c = wrappperCov.advancedExpression,
                                                                                            SVMXC__PM_Plan__c = newPMPlanRec.Id
                                                                                            );

                            if(Boolean.valueOf(pmPlanData.pmTemplateDetail.useCurrentFieldVal) && pmPlanData.pmPlanId == null){
                                if(String.isBlank(covRec.SVMXC__SM_Advanced_Expression__c)){
                                    covRec.SVMXC__SM_Advanced_Expression__c = pmPlanData.pmTemplateDetail.advancedExpression;
                                }
                            }
                            pmCoverage.add(covRec);
                        }
                    }

                    
                    if(pmCoverage != null && pmCoverage.size() > 0){
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(pmCoverage, COMM_SecurityUtils.Access.Upsertable)){
                            upsert pmCoverage; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else{
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                        
                        // update all coverages with ID
                        for(integer i=0; i  < pmCoverage.size();  i++){
                            pmPlanData.coverageList[i].pmCovergaeId = pmCoverage[i].id;
                            
                            // Update Schedule Definition if any
                            // Covergae Schedule Def
                            
                            if(pmPlanData.coverageList[i].conditionRuleList != null && pmPlanData.coverageList[i].conditionRuleList.size() >0){
                                for(PREV_SetupPMPlan_Wrapper.ConditionRules coverageSchdef : pmPlanData.coverageList[i].conditionRuleList){
                                    SVMXC__PM_Schedule_Definition__c covSchdefRule;

                                    if(newPMPlanRec.SVMXC__SM_Condition_Type__c == null || newPMPlanRec.SVMXC__SM_Condition_Type__c == '' || newPMPlanRec.SVMXC__SM_Condition_Type__c == 'Usage_Frequency'){

                                        covSchdefRule = new SVMXC__PM_Schedule_Definition__c( 
                                            SVMXC__SM_Sequence__c = Decimal.valueOf(coverageSchdef.sequence),
                                            SVMXC__SM_Attribute_Field__c = coverageSchdef.selectedField,
                                            SVMXC__SM_Attribute_Type__c = coverageSchdef.fieldAttType,
                                            SVMXC__SM_Attr_Data_type__c = coverageSchdef.fieldDataType,
                                            SVMXC__SM_Operator__c = coverageSchdef.selectedOperator,
                                            SVMXC__SM_Value__c = coverageSchdef.value,
                                            SVMXC__Frequency__c = Decimal.valueOf(coverageSchdef.frequency),
                                            SVMXC__Frequency_Unit__c = coverageSchdef.selectedFreqUnit,
                                            SVMXC__SM_Start_At__c = coverageSchdef.startAt,
                                            SVMXC__SM_Stop_At__c = coverageSchdef.stopAt,
                                            SVMXC__SM_Threshold__c = (coverageSchdef.threshold != null && coverageSchdef.threshold != '')? Decimal.valueOf(coverageSchdef.threshold): null,
                                            SVMXC__SM_Adjustment_Type__c = coverageSchdef.selectedAdjustmentType,
                                            SVMXC__SM_Min_Activity_Changed__c = (coverageSchdef.minAdjustment != null && coverageSchdef.minAdjustment != '')? Decimal.valueOf(coverageSchdef.minAdjustment): null,
                                            SVMXC__SM_Max_Activity_Changed__c = (coverageSchdef.maxAdjustment != null && coverageSchdef.maxAdjustment != '') ? Decimal.valueOf(coverageSchdef.maxAdjustment): null,
                                            SVMXC__SM_Adjusted_Value__c = (coverageSchdef.adjustmentVal != null && coverageSchdef.adjustmentVal != '')? Decimal.valueOf(coverageSchdef.adjustmentVal): null,
                                            SVMXC__SM_Adjusted_Units__c = coverageSchdef.selectedAdjustedUnit,
                                            SVMXC__PM_Plan__c = newPMPlanRec.id,
                                            SVMXC__SM_PM_Coverage__c = pmCoverage[i].id
                                        );
                                    }
                                    else if(newPMPlanRec.SVMXC__SM_Condition_Type__c == 'Criteria_Comparison'){
                                        covSchdefRule = new SVMXC__PM_Schedule_Definition__c( 
                                            SVMXC__SM_Sequence__c = Decimal.valueOf(coverageSchdef.sequence),
                                            SVMXC__SM_Attribute_Field__c = coverageSchdef.selectedField,
                                            SVMXC__SM_Attribute_Type__c = coverageSchdef.fieldAttType,
                                            SVMXC__SM_Attr_Data_type__c = coverageSchdef.fieldDataType,
                                            SVMXC__SM_Operator__c = coverageSchdef.selectedOperator,
                                            SVMXC__SM_Value__c = coverageSchdef.value,
                                            SVMXC__PM_Plan__c = newPMPlanRec.id,
                                            SVMXC__SM_PM_Coverage__c = pmCoverage[i].id
                                        );
                                    }
                                    
                                    listSchDef.add(covSchdefRule); 
                                }
                            } 


                            if(pmPlanData.coverageList[i].scheduleList == null || pmPlanData.coverageList[i].scheduleList.size() == 0){
                                PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request covSchrequest = new PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request();
                                covSchrequest.coverageId = pmCoverage[i].SVMXC__Product_Name__c; 

                                system.debug(pmPlanData.pmTemplateDetail.conditionRuleList);
                                covSchrequest.conditionRuleList = pmPlanData.coverageList[i].conditionRuleList != null? pmPlanData.coverageList[i].conditionRuleList: (List<PREV_SetupPMPlan_Wrapper.ConditionRules>)JSON.deserialize(JSON.serialize(pmPlanData.pmTemplateDetail.conditionRuleList), List<PREV_SetupPMPlan_Wrapper.ConditionRules>.class);  
                                
                                system.debug(covSchrequest.conditionRuleList);
                                // Before assigning trim 
                                covSchrequest.pmPlanRecord = pmPlanData; 
                                covSchrequest.advancedExpression = !String.isBlank(pmPlanData.coverageList[i].advancedExpression)? pmPlanData.coverageList[i].advancedExpression: pmPlanData.pmTemplateDetail.advancedExpression;
                                covSchrequest.workOrderPurposeId = pmPlanData.woPurposeId;

                                // Clear the previous schedule values for this Covergae
                                listSchWrapper.clear();
                                scheduleSeq = 1;


                                PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response  coverageResponse = createScheduleRec(covSchrequest);
                                pmPlanData.coverageList[i].scheduleList = coverageResponse.scheduleList;

                                system.debug(pmPlanData.coverageList[i].scheduleList);
                                
                                if(Boolean.valueOf(pmPlanData.pmTemplateDetail.useCurrentFieldVal) && pmPlanData.pmPlanId == null){
                                    system.debug(coverageResponse.conditionRuleList);
                                    pmPlanData.coverageList[i].conditionRuleList = coverageResponse.conditionRuleList;
                                    

                                    for(PREV_SetupPMPlan_Wrapper.ConditionRules coverageCurrValCondition : pmPlanData.coverageList[i].conditionRuleList){
                                        SVMXC__PM_Schedule_Definition__c covCurrValSchdefRule = new SVMXC__PM_Schedule_Definition__c( SVMXC__SM_Sequence__c = Decimal.valueOf(coverageCurrValCondition.sequence),
                                                                                                        SVMXC__SM_Attribute_Field__c = coverageCurrValCondition.selectedField,
                                                                                                        SVMXC__SM_Attribute_Type__c = coverageCurrValCondition.fieldAttType,
                                                                                                        SVMXC__SM_Attr_Data_type__c = coverageCurrValCondition.fieldDataType,
                                                                                                        SVMXC__SM_Operator__c = coverageCurrValCondition.selectedOperator,
                                                                                                        SVMXC__SM_Value__c = coverageCurrValCondition.value,
                                                                                                        SVMXC__Frequency__c = Decimal.valueOf(coverageCurrValCondition.frequency),
                                                                                                        SVMXC__Frequency_Unit__c = coverageCurrValCondition.selectedFreqUnit,
                                                                                                        SVMXC__SM_Threshold__c = (coverageCurrValCondition.threshold != null && coverageCurrValCondition.threshold != '')? Decimal.valueOf(coverageCurrValCondition.threshold): null,
                                                                                                        SVMXC__SM_Adjustment_Type__c = coverageCurrValCondition.selectedAdjustmentType,
                                                                                                        SVMXC__SM_Min_Activity_Changed__c = (coverageCurrValCondition.minAdjustment != null && coverageCurrValCondition.minAdjustment != '')? Decimal.valueOf(coverageCurrValCondition.minAdjustment): null,
                                                                                                        SVMXC__SM_Max_Activity_Changed__c = (coverageCurrValCondition.maxAdjustment != null && coverageCurrValCondition.maxAdjustment != '') ? Decimal.valueOf(coverageCurrValCondition.maxAdjustment): null,
                                                                                                        SVMXC__SM_Adjusted_Value__c = (coverageCurrValCondition.adjustmentVal != null && coverageCurrValCondition.adjustmentVal != '')? Decimal.valueOf(coverageCurrValCondition.adjustmentVal): null,
                                                                                                        SVMXC__SM_Adjusted_Units__c = coverageCurrValCondition.selectedAdjustedUnit,
                                                                                                        SVMXC__PM_Plan__c = newPMPlanRec.id,
                                                                                                        SVMXC__SM_PM_Coverage__c = pmCoverage[i].id

                                                                                                        );

                                        system.debug(coverageCurrValCondition);
                                        String subStrSD = coverageCurrValCondition.startAt; 

                                        Integer indexOfValSD = coverageCurrValCondition.startAt.indexOf(' '); 
                                        if(indexOfValSD != -1){
                                            subStrSD = subStrSD.substring(0, indexOfValSD); 
                                        }
                                        
                                        String subStrED = coverageCurrValCondition.stopAt; 
                                        Integer indexOfValED = coverageCurrValCondition.stopAt.indexOf(' '); 
                                        if(indexOfValED != -1){
                                            subStrED = subStrED.substring(0, indexOfValED); 
                                        }


                                        covCurrValSchdefRule.SVMXC__SM_Start_At__c = subStrSD;
                                        covCurrValSchdefRule.SVMXC__SM_Stop_At__c = subStrED;
                                        
                                        listSchDef.add(covCurrValSchdefRule); 
                                    }
                                }
                            }
                            
                            
                            if(pmPlanData.coverageList[i].scheduleList != null || pmPlanData.coverageList[i].scheduleList.size() > 0){
                                // Update Schedule Output if any
                                for(PREV_SetupPMPlan_Wrapper.Schedule coverageSch : pmPlanData.coverageList[i].scheduleList ){
                                    //This condition is added for fixing defect BAC-2720 where 2nd issue: Processed schedules getting deleted when template is removed.
                                    //if(String.isBlank(coverageSch.status) || (!coverageSch.status.equalsIgnoreCase('Work Order Created') && !coverageSch.status.equalsIgnoreCase('Work Order Done'))){
                                        SVMXC__PM_Schedule__c covSchedule = new SVMXC__PM_Schedule__c(
                                                                                                        SVMXC__SM_Expression_Display_Value__c = coverageSch.scheduleName,
                                                                                                        SVMXC__SM_Expression_Internal_Value__c = coverageSch.internalExpression,
                                                                                                        SVMXC__SM_PM_Coverage__c  = pmCoverage[i].id,
                                                                                                        SVMXC__PM_Plan__c = newPMPlanRec.id ,
                                                                                                        SVMXC__SM_Sequence__c = Decimal.valueOf(coverageSch.sequence),
                                                                                                        SVMXC__SM_Status__c = coverageSch.status ,
                                                                                                        SVMXC__SM_Work_Order_Purpose__c = coverageSch.selectedWOPurpose,
                                                                                                        SVMXC__SM_Advanced_Expression__c = coverageSch.advancedExpression, // Added for defect BAC - 2991 fix
                                                                                                        SVMXC__SM_Expression_Actual_Output_Value__c = coverageSch.actualOpExpression //Added for defect BAC- 3062 fix
                                                                                                    );
                                        listSch.add(covSchedule);
                                    //}
                                }
                            } 

                            System.debug(listSch);  
                        }
                    }

                    

                    // if we are in edit scenario delete all the Coverges, Schedule Def & Schedule records (status != 'Work Order Created' || 'Work Order Done' || 'Skipped')
                    system.debug(listSchDef);
                    if(listSchDef != null && listSchDef.size() >0){
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listSchDef, COMM_SecurityUtils.Access.Upsertable)){
                            upsert listSchDef; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else{
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                        
                    }

                    if(listSch != null && listSch.size() >0){
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listSch, COMM_SecurityUtils.Access.Upsertable)){
                            upsert listSch; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else{
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                    }
                }

                
                if(listScheduleDefId != null && listScheduleDefId.size() > 0){
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__PM_Schedule_Definition__c')){
                        delete listScheduleDefId; //SDL-SVMX-DELETE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.COMM001_TAG142));
                        Database.rollback(objSavePoint);
                        return null;
                    }
                }

                
                if(listCovId != null && listCovId.size() > 0){
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__PM_Coverage__c')){
                        delete listCovId; //SDL-SVMX-DELETE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.COMM001_TAG142));
                        Database.rollback(objSavePoint);
                        return null;
                    }
                }

                System.debug('listScheduleRecId: '+listScheduleRecId);
                if(listScheduleRecId != null && listScheduleRecId.size() > 0){
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__PM_Schedule__c')){
                        delete listScheduleRecId; //SDL-SVMX-DELETE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.COMM001_TAG142));
                        Database.rollback(objSavePoint);
                        return null;
                    }
                }
                

                // Update PM Plan Status to active using setPMPlanStatus method in class PREV_PMPlanUtils
                // Input - Activate PM plan value, List of PM Plan, Coverage type
                // Output - List of PM Plan
                // We will always have only 1 pm plan created from this screen. Hence can use [0]

                if(pmPlanData.pmPlanId == null){
                    List <SVMXC__PM_Plan__c> listUpdatedPMPlan = new PREV_PMPlanUtils().setPMPlanStatus(activatePMPlan, new List<SVMXC__PM_Plan__c> {newPMPlanRec}, 'Product (Must Have IB)');
                    newPMPlanRec = listUpdatedPMPlan[0];
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(newPMPlanRec, COMM_SecurityUtils.Access.Upsertable)){
                        upsert newPMPlanRec; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }

                savePmPlanRes.success = true;
                pmPlanData.pmPlanId = newPMPlanRec.id;
                savePmPlanRes.pmPlanRecord = pmPlanData;    
            }
            else{
                savePmPlanRes.success = false;
                savePmPlanRes.messageList.add(System.Label.PREV004_TAG052);
                System.debug(LoggingLevel.WARN, 'Invalid Advanced Expression');
            }
        }
        catch(Exception e){
             Database.rollback(objSavepoint);
             savePmPlanRes.success = false;
             savePmPlanRes.messageList = new List<String>();
             savePmPlanRes.messageList.add(e.getMessage());
        }
        
        return savePmPlanRes;
    }


    
    // While creating Coverages, add condition rule & Schedule to it. 
    // Condition rules will be part of Main PM Plan and Schedule should be child of coverage.
    public List<PREV_SetupPMPlan_Wrapper.Coverage> getPMPlanCovergaes(List<SVMXC__PM_Coverage__c> listPmCovergae){
        List<PREV_SetupPMPlan_Wrapper.Coverage> listPMCoverageWrapper = new List<PREV_SetupPMPlan_Wrapper.Coverage>();
        
        
        for(SVMXC__PM_Coverage__c pmCovRec: listPmCovergae){
            PREV_SetupPMPlan_Wrapper.Coverage wrapperCovRec= new PREV_SetupPMPlan_Wrapper.Coverage();
            wrapperCovRec.pmCovergaeId          = pmCovRec.Id;
            
            for(SVMXC__Installed_Product__c installedProdRec: lstInstalledProducts){
                if(installedProdRec.id == pmCovRec.SVMXC__Product_Name__c){
                    wrapperCovRec.productId  = installedProdRec.SVMXC__Product__c;
                    if(installedProdRec.name != null){
                        wrapperCovRec.installedProductName       = installedProdRec.name;
                    }
                    break;
                }
            }
            wrapperCovRec.installedProductId             = pmCovRec.SVMXC__Product_Name__c;

            listPMCoverageWrapper.add(wrapperCovRec);
        }
        
        return listPMCoverageWrapper; 
    }


    // This is for already calclulated schedule records
    public PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response getCovergaeTechnicalAtt(PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request request){
        PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response covergaeSchRes = new PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response();

        if (String.isBlank(request.productId) && !String.isBlank(request.coverageId)){
            SVMXC__Installed_Product__c ibProduct = [Select SVMXC__Product__c from SVMXC__Installed_Product__c where id= :request.coverageId limit 1 ];
            request.productId = ibProduct.SVMXC__Product__c; 
        }

        PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response covTAResponse = getConditionGridFields(request.productId, request.pmPlanRecord.conditionType);
        covergaeSchRes.mapOfKeyAndListOfKeyValue = covTAResponse.mapOfKeyAndListOfKeyValue; 
        covergaeSchRes.success = true;
        return covergaeSchRes;
    }


    public PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response createScheduleRec(PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request request) {
        PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response covergaeSchRes = new PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response();

        
        PREV_SetupPMPlan_Wrapper.PM_Plan_Data pmPlanData = request.pmPlanRecord;
        String strConditionType = request.pmPlanRecord.conditionType;

       // Create Field Picklist Value with technical attributes

        // In this only 1 coverege record can be passed.
        // Create Schedule records for the covergae given & pass it as response
        // If the condition grid says use current value, get current value and populate it in Condition grid

        List<PREV_SetupPMPlan_Wrapper.Schedule> listScheduleWrapper = new List<PREV_SetupPMPlan_Wrapper.Schedule>();

        List<PREV_SetupPMPlan_Wrapper.ConditionRules> listConditionRules =  new List<PREV_SetupPMPlan_Wrapper.ConditionRules>();

        List<String> listTechnicalAttName = new List<String>();
        List<String> listSchemaAttName = new List<String>();
        Map <String, String > mapTechnicalAttVal = new Map <String, String >();
        Map <String, String > mapSchemaAttVal = new Map <String, String >();

        //Before modifying the condition rules, create a copy of it

        List<PREV_SetupPMPlan_Wrapper.ConditionRules> listOriginalConRule = new List<PREV_SetupPMPlan_Wrapper.ConditionRules>();
        listOriginalConRule = (List<PREV_SetupPMPlan_Wrapper.ConditionRules>)JSON.deserialize(JSON.serialize(request.conditionRuleList), List<PREV_SetupPMPlan_Wrapper.ConditionRules>.class);
                                    
        if(pmPlanData.pmTemplateDetail != null && pmPlanData.pmTemplateDetail.useCurrentFieldVal != null && Boolean.valueOf(pmPlanData.pmTemplateDetail.useCurrentFieldVal)){
            // Get all the technical attribute start at value 
            if (request.conditionRuleList != null){
                for(PREV_SetupPMPlan_Wrapper.ConditionRules conWrap: request.conditionRuleList){
                    if(conWrap.fieldDataType.equalsIgnoreCase('number') && String.isBlank(pmPlanData.pmPlanId)){
                        if(conWrap.fieldAttType.equalsIgnoreCase('schema')){
                            listSchemaAttName.add(conWrap.selectedField); 
                        }
                        else if(conWrap.fieldAttType.equalsIgnoreCase('technical')){
                            listTechnicalAttName.add(conWrap.selectedField); 
                        }
                    }
                }
            }

            
            if(listTechnicalAttName != null && listTechnicalAttName.size() >0){
                mapTechnicalAttVal = getTechnicalAttValue (request.coverageId, listTechnicalAttName);
            }

            if(listSchemaAttName != null && listSchemaAttName.size()>0){
                mapSchemaAttVal = getSchemaAttValue (request.coverageId, listSchemaAttName);
            }    
        }
        
        if(strConditionType == null || strConditionType == '' || strConditionType == 'Usage_Frequency'){
            for(PREV_SetupPMPlan_Wrapper.ConditionRules condStartAtUpdate: request.conditionRuleList){
                if(condStartAtUpdate.fieldDataType.equalsIgnoreCase('number') && (String.isBlank(pmPlanData.pmPlanId) || pmPlanData.pmPlanId == null)){
                    String templateStartAt = condStartAtUpdate.startAt; 
                    if(pmPlanData.pmTemplateDetail != null && pmPlanData.pmTemplateDetail.useCurrentFieldVal != null && Boolean.valueOf(pmPlanData.pmTemplateDetail.useCurrentFieldVal)){
                        condStartAtUpdate.startAt = '0';
                        if(condStartAtUpdate.fieldAttType.equalsIgnoreCase('technical')){
                            condStartAtUpdate.startAt = mapTechnicalAttVal.get(condStartAtUpdate.selectedField); 
                        } 
                        else if(condStartAtUpdate.fieldAttType.equalsIgnoreCase('schema')){
                            condStartAtUpdate.startAt = mapSchemaAttVal.get(condStartAtUpdate.selectedField);
                        } 

                        if(condStartAtUpdate.startAt == null){
                            condStartAtUpdate.startAt = '0';
                        }
                    }
                    else{
                        condStartAtUpdate.startAt = templateStartAt;
                    }

                    
                }
                listConditionRules.add(condStartAtUpdate);  
            }
            
            List<PREV_SetupPMPlan_Wrapper.ConditionRules> listUpdatedConditionRules =  new List<PREV_SetupPMPlan_Wrapper.ConditionRules>();

            // Need to update the condition rules with Valid date ranges
            for(PREV_SetupPMPlan_Wrapper.ConditionRules condRuleTemp : listConditionRules){

                PREV_SetupPMPlan_Wrapper.ConditionRules updatedSchTemp = new PREV_SetupPMPlan_Wrapper.ConditionRules();
                updatedSchTemp = condRuleTemp; 

            if(condRuleTemp.fieldDataType.equalsIgnoreCase('Date') && pmPlanData.startDate != null &&  pmPlanData.endDate != null){
               
                Date identifyStartDate = Date.valueOf(pmPlanData.startDate); 
                Date identifyEndDate = Date.valueOf(pmPlanData.endDate); 

                Boolean isStartDateInvalid = true;
                Boolean isEndDateInvalid = true; 

                // Update Start and End date to todays date, if its empty
                if(String.isBlank(condRuleTemp.startAt)){
                    condRuleTemp.startAt = String.valueOf(Date.Today());
                }

                if(String.isBlank(condRuleTemp.stopAt)){
                    // Stop at value cant be before start valueOf
                    condRuleTemp.stopAt = String.valueOf(Date.Today());
                    if(Date.valueOf(condRuleTemp.stopAt) < Date.valueOf(condRuleTemp.startAt)){
                        condRuleTemp.stopAt = condRuleTemp.startAt;
                    }
                }

                
                if (Date.valueOf(condRuleTemp.startAt) >= identifyStartDate && Date.valueOf(condRuleTemp.startAt) <= identifyEndDate){
                    identifyStartDate = Date.valueOf(condRuleTemp.startAt);
                    isStartDateInvalid = false; 
                }

                
                if (Date.valueOf(condRuleTemp.stopAt) <= identifyEndDate && Date.valueOf(condRuleTemp.stopAt) >= identifyStartDate){
                    identifyEndDate = Date.valueOf(condRuleTemp.stopAt);
                    isEndDateInvalid = false;
                }

                
                if(isStartDateInvalid && isEndDateInvalid){
                    // Check if PM plan SD and ED is between Template SD & ED, if its out, then its invalid
                    if(!(Date.valueOf(condRuleTemp.startAt) <  identifyStartDate && Date.valueOf(condRuleTemp.stopAt) > identifyEndDate)){
                        updatedSchTemp.startAt = 'invalid';
                        updatedSchTemp.stopAt = 'invalid';
                    }
                    else{
                        updatedSchTemp.startAt = String.valueOf(pmPlanData.startDate); 
                        updatedSchTemp.stopAt  = String.valueOf(pmPlanData.endDate); 
                    }
                }
                else{

                    updatedSchTemp.startAt = String.valueOf(identifyStartDate);
                    updatedSchTemp.stopAt = String.valueOf(identifyEndDate);
                }    
            }
            
            listUpdatedConditionRules.add(updatedSchTemp);
        }

        //if(String.isBlank(pmPlanData.pmPlanId)){
            //pmPlanData.pmTemplateDetail.conditionRuleList 
            for(PREV_SetupPMPlan_Wrapper.ConditionRules condRuleDisplay: listUpdatedConditionRules){
                 System.debug('Came in Schedule Rec ----' + condRuleDisplay );
                String sequenceConRul = condRuleDisplay.sequence;
                if(listOriginalConRule != null && listOriginalConRule.size() > 0){
                    for(integer seq=1; seq <= listOriginalConRule.size(); seq ++){
                        if(seq == Integer.valueOf(sequenceConRul)){
                            if((condRuleDisplay.startAt != null && !condRuleDisplay.startAt.equalsIgnoreCase('invalid')) || ( condRuleDisplay.stopAt != null && !condRuleDisplay.stopAt.equalsIgnoreCase('invalid') )){
                                listOriginalConRule[seq-1] = condRuleDisplay; 
                            }
                        }
                    }
                }
            }
            System.debug('Came in Schedule Rec ----' + listOriginalConRule );
            //System.debug(newInstanceConRule);
            covergaeSchRes.conditionRuleList = listOriginalConRule; 

       // }


        Map <String, String> mapUniqOrderSeq = new Map <String, String>();

            for(integer j =1 ;  j<=5; j++){
                mapUniqOrderSeq.put(String.valueOf(j), '~'+String.valueOf(j));
            }
            
            listScheduleWrapper = wrapperScheduleRec (listUpdatedConditionRules, null, request.advancedExpression, request.workOrderPurposeId, covergaeSchRes.conditionRuleList, mapUniqOrderSeq);
        }
        else if (strConditionType == 'Criteria_Comparison'){
            covergaeSchRes.conditionRuleList = listOriginalConRule; 

            Map <String, String> mapUniqOrderSeq = new Map <String, String>();
            for(integer j =1 ;  j<=5; j++){
                mapUniqOrderSeq.put(String.valueOf(j), '~'+String.valueOf(j));
            }
            listScheduleWrapper = wrapperScheduleRecForCriteria (covergaeSchRes.conditionRuleList, request.advancedExpression, request.workOrderPurposeId, mapUniqOrderSeq);
        }
        system.debug(listScheduleWrapper);
        
        covergaeSchRes.success = true;
        covergaeSchRes.coverageId = request.coverageId; 
        
        ///Added for defect BAC-2849 fix
        covergaeSchRes.runScheduleCoverageId = request.runScheduleCoverageId;
        List<PREV_SetupPMPlan_Wrapper.Schedule> listSchWrapper = new List<PREV_SetupPMPlan_Wrapper.Schedule>();
        System.debug('request.runScheduleCoverageId: '+request.runScheduleCoverageId);

        if(!String.isBlank(request.runScheduleCoverageId)){
            List<String> status = new List<String>();
            status.add('Work Order Created');
            status.add('Work Order Done');

            List<SVMXC__PM_Schedule__c> lstPMSchedule = [SELECT Id, Name, SVMXC__SM_Expression_Internal_Value__c, SVMXC__SM_Work_Order_Purpose__c, SVMXC__SM_Expression_Actual_Output_Value__c, SVMXC__PM_Schedule_Definition__c, SVMXC__SM_Status__c, SVMXC__SM_Expression_Display_Value__c, SVMXC__SM_Sequence__c, SVMXC__SM_PM_Coverage__c, SVMXC__SM_Advanced_Expression__c FROM SVMXC__PM_Schedule__c WHERE SVMXC__SM_PM_Coverage__c =: request.runScheduleCoverageId AND SVMXC__SM_Status__c IN :status ORDER BY SVMXC__SM_Sequence__c ASC];
            System.debug('lstPMSchedule: '+lstPMSchedule);

            Map<String,String> mapUniqOrderSeq = new Map<String,String>();
            for(Integer j=1 ;  j<=5; j++){
                mapUniqOrderSeq.put(String.valueOf(j), '~'+String.valueOf(j));
            }

            for(SVMXC__PM_Schedule__c schRec : lstPMSchedule){
                PREV_SetupPMPlan_Wrapper.Schedule scheduleData = new PREV_SetupPMPlan_Wrapper.Schedule();
                scheduleData.scheduleId = schRec.Id;
                scheduleData.sequence = String.valueOf(schRec.SVMXC__SM_Sequence__c);
                scheduleData.status = schRec.SVMXC__SM_Status__c;
                
                // Anchal - BAC-3226. We will be using Status Label value to display in UI
                scheduleData.statusLabel = getStatusType(schRec.SVMXC__SM_Status__c);
                scheduleData.selectedWOPurpose = schRec.SVMXC__SM_Work_Order_Purpose__c;
                scheduleData.internalExpression = schRec.SVMXC__SM_Expression_Internal_Value__c;
                scheduleData.advancedExpression = schRec.SVMXC__SM_Advanced_Expression__c; //Added for defect BAC-2991 fix
                scheduleData.actualOpExpression = schRec.SVMXC__SM_Expression_Actual_Output_Value__c; //Added for defect BAC- 3062 fix

                if(!String.isBlank(schRec.SVMXC__SM_Expression_Internal_Value__c) && !String.isBlank(schRec.SVMXC__SM_Advanced_Expression__c)){
                    String advExpVal = schRec.SVMXC__SM_Advanced_Expression__c;

                    if(strConditionType == null || strConditionType == '' || strConditionType == 'Usage_Frequency'){
                        scheduleData.scheduleName = actualOpNameMethod(schRec.SVMXC__SM_Expression_Internal_Value__c, advExpVal, mapUniqOrderSeq);
                    }
                    else if(strConditionType == 'Criteria_Comparison'){
                        scheduleData.scheduleName = actualOpNameMethodForCriteria(schRec.SVMXC__SM_Expression_Internal_Value__c, advExpVal, mapUniqOrderSeq);
                    }
                }
                else{
                    scheduleData.scheduleName = '';
                }

                //This is for fixing defect BAC-2957. For processed schedules records get the advanced expresssion from schedule recrod if present and set the actualOpName
                if(!String.isBlank(schRec.SVMXC__SM_Expression_Actual_Output_Value__c) && !String.isBlank(schRec.SVMXC__SM_Advanced_Expression__c)){
                    String advExpVal = schRec.SVMXC__SM_Advanced_Expression__c;

                    if(strConditionType == null || strConditionType == '' || strConditionType == 'Usage_Frequency'){
                        scheduleData.actualOpName = actualOpNameMethod(schRec.SVMXC__SM_Expression_Actual_Output_Value__c, advExpVal, mapUniqOrderSeq);
                    }
                    else if(strConditionType == 'Criteria_Comparison'){
                        scheduleData.actualOpName = actualOpNameMethodForCriteria(schRec.SVMXC__SM_Expression_Actual_Output_Value__c, advExpVal, mapUniqOrderSeq);
                    }
                }
                else{
                    scheduleData.actualOpName = '';
                }
                listSchWrapper.add(scheduleData);
            }
            System.debug('listSchWrapper: '+listSchWrapper);
        }
        covergaeSchRes.scheduleList = new List<PREV_SetupPMPlan_Wrapper.Schedule>();
        if(listSchWrapper.size() > 0){
            covergaeSchRes.scheduleList.addAll(listSchWrapper);
        }
        covergaeSchRes.scheduleList.addAll(listScheduleWrapper);
        System.debug('covergaeSchRes.scheduleList: '+covergaeSchRes.scheduleList);
        //covergaeSchRes.scheduleList = listScheduleWrapper;
        
        return covergaeSchRes; 
    }

    public Map <String, String > getTechnicalAttValue (String IBId, List<String> attName){
        Map <String, String > mapAttVal = new Map <String, String >();
        for(SVMXC__SM_IB_Technical_Attributes__c technicalAttrRec : [SELECT Id, SVMXC__SM_Attr_Name__c, SVMXC__SM_Attr_Value__c , SVMXC__SM_IBAttr_ExtId__c, SVMXC__SM_Installed_Product_id__c 
                                                                        FROM SVMXC__SM_IB_Technical_Attributes__c 
                                                                            WHERE SVMXC__SM_IsActive__c = true 
                                                                                AND SVMXC__SM_Installed_Product_id__c =: IBId
                                                                                    AND SVMXC__SM_Attr_Name__c IN : attName]){

            mapAttVal.put(technicalAttrRec.SVMXC__SM_Attr_Name__c, technicalAttrRec.SVMXC__SM_Attr_Value__c);
        }
        return mapAttVal;      
    }

    public Map<String, String> getSchemaAttValue (String IBId, List<String> attName){
        Map <String, String > mapSchemaAttVal = new Map <String, String >();
        String queryFields='';
        for (String field : attName) {
           if (queryFields.length()>0) {
               queryFields += ',';
           }
           queryFields += field;
        }

        String queryString = 'SELECT ' + queryFields + ' , SVMXC__Preferred_Technician__r.SVMXC__Salesforce_User__c, SVMXC__Preferred_Technician__r.SVMXC__Salesforce_User__r.IsActive FROM SVMXC__Installed_Product__c WHERE ID =: IBId LIMIT 1';

        SObject  installedProductsList = Database.query(queryString);

        for(String fieldname: attName){
            mapSchemaAttVal.put(fieldname, String.valueOf(installedProductsList.get(fieldname)));
        }
        return mapSchemaAttVal;
    }

    public List<PREV_SetupPMPlan_Wrapper.Schedule> wrapperScheduleRec (List<PREV_SetupPMPlan_Wrapper.ConditionRules> listConRul, List<PREV_SetupPMPlan_Wrapper.InternalExpression> prevSchedule, String advancedExpression, Id workOdPurpose, List<PREV_SetupPMPlan_Wrapper.ConditionRules> nonModConRule, Map <String, String> mapUniqOrderSeq){
        Boolean stopLoop = false;

        List<PREV_SetupPMPlan_Wrapper.InternalExpression> listScheduleWrapperInst = new List<PREV_SetupPMPlan_Wrapper.InternalExpression>();
    
        if(listConRul != null && listConRul.size() > 0) {
            
            for( integer i = 0; i < listConRul.size(); i++){
                
                PREV_SetupPMPlan_Wrapper.InternalExpression intExp = new PREV_SetupPMPlan_Wrapper.InternalExpression();

                intExp.order = String.valueOf(Integer.valueOf(listConRul[i].sequence) );
                intExp.attrName = !String.isBlank(listConRul[i].selectedField ) ? listConRul[i].selectedField :'TODAY' ;
                intExp.operator = listConRul[i].selectedOperator;
                intExp.datatype = listConRul[i].fieldDataType; 
                intExp.attrType = intExp.attrName.equalsIgnoreCase('TODAY')? 'Literal':listConRul[i].fieldAttType; 
                intExp.adjType  = listConRul[i].selectedAdjustmentType;
                intExp.adjValue = listConRul[i].adjustmentVal;
                intExp.adjMin   = listConRul[i].minAdjustment;
                intExp.adjMax   = listConRul[i].maxAdjustment;
                intExp.adjUnit  = listConRul[i].selectedAdjustedUnit;
                if(nonModConRule != null && nonModConRule.size()>0){
                    intExp.stopAt   = nonModConRule[i].stopAt;
                }
                
                // This is the first schedule record to be created.
                // Calculate first value using Start AT, Threshold, Frequency
                // Calculate first Value and check if it greater than Stop At value or not 
                if(intExp.datatype.equalsIgnoreCase ('Date')){
                    
                    System.debug(listConRul[i]);
                    if((listConRul[i].startAt != null && listConRul[i].startAt.equalsIgnoreCase('invalid')) || ( listConRul[i].stopAt != null && listConRul[i].stopAt.equalsIgnoreCase('invalid') )){
                        return listSchWrapper; 
                    }
                    
                    System.debug(listConRul[i]);
                    Date startAt = Date.today();
                    Date stopAt = listConRul[i].stopAt != null? Date.valueOf(listConRul[i].stopAt): Date.today(); 

                    if(prevSchedule != null && prevSchedule.size() > 0){
                        startAt = Date.valueOf(prevSchedule[i].attrValue); 
                    }
                    else{
                        if(!String.isBlank(listConRul[i].startAt )&& !listConRul[i].startAt.equalsIgnoreCase('invalid')){
                            startAt = Date.valueOf(listConRul[i].startAt);
                        }
                    }

                    if(prevSchedule != null && prevSchedule.size() > 0){

                        if(listConRul[i].selectedFreqUnit.equalsIgnoreCase('Months')){
                            startAt = startAt.addMonths(Integer.valueOf(listConRul[i].frequency));
                        }


                        if(listConRul[i].selectedFreqUnit.equalsIgnoreCase('Weeks')){
                            startAt =  startAt.addDays(Integer.valueOf(listConRul[i].frequency) * 7) ;
                        }

                        if(listConRul[i].selectedFreqUnit.equalsIgnoreCase('Years')){
                            startAt = startAt.addYears(Integer.valueOf(listConRul[i].frequency)) ;
                        }
                    }
                    
                    // Go out of loop to stop calculation schedule, if Start At is greater than Stop at
                    if(startAt > stopAt ){
                        stopLoop = true; 
                    }
                    
                    intExp.attrValue = String.valueOf(startAt);
                }

                if(intExp.datatype.equalsIgnoreCase ('Number')){
                    Decimal startAtVal = 0;

                   
                    // if there is previous schedule created, then use it to find updated start at values
                    if(prevSchedule != null && prevSchedule.size() > 0 && listSchWrapper != null && listSchWrapper.size() > 1){
                        if(listConRul[i].threshold != null && !String.isBlank(listConRul[i].threshold) && Integer.valueOf(listConRul[i].threshold) != 0){
                            if (intExp.operator.equalsIgnoreCase('EYI')){
                                startAtVal = addMethod (Decimal.valueOf(prevSchedule[i].attrValue),  (( (100 - Decimal.valueOf(listConRul[i].threshold) )/100)  * Decimal.valueOf(listConRul[i].frequency )));
                            }

                            if (intExp.operator.equalsIgnoreCase('EYD')){
                                startAtVal = subMethod (Decimal.valueOf(prevSchedule[i].attrValue),  (( (100 - Decimal.valueOf(listConRul[i].threshold) )/100)  * Decimal.valueOf(listConRul[i].frequency )));
                            }
                        }
                        else{
                            startAtVal = Decimal.valueOf(prevSchedule[i].attrValue); 
                        }
                    }
                    else{
                        if(!String.isBlank(listConRul[i].startAt )){
                            startAtVal = Decimal.valueOf(listConRul[i].startAt);
                        }
                    }

                    
                    // Calculated threshold updated start date
                    if(listConRul[i].selectedFreqUnit.equalsIgnoreCase('Count')){
                        if(prevSchedule != null && prevSchedule.size() > 0){
                            Decimal thresholdCal = 0.0;
                            if(listConRul[i].threshold != null && !String.isBlank(listConRul[i].threshold) && Integer.valueOf(listConRul[i].threshold) != 0){
                                thresholdCal = (( Decimal.valueOf(listConRul[i].threshold)) /100)  * Decimal.valueOf(listConRul[i].frequency)  ;
                            }
                            else{
                                thresholdCal = Decimal.valueOf(listConRul[i].frequency); 
                            }
                            
                            if (intExp.operator.equalsIgnoreCase('EYI')){
                                startAtVal = addMethod (startAtVal, thresholdCal);
                            }

                            if (intExp.operator.equalsIgnoreCase('EYD')){
                                startAtVal = subMethod (startAtVal, thresholdCal);
                            }
                        }
                    }

                    
                    if(String.isBlank(listConRul[i].stopAt)){
                        listConRul[i].stopAt = '0';
                    }

                    Decimal stopAtVal = Decimal.valueOf(listConRul[i].stopAt);
                    
                    if(intExp.operator.equalsIgnoreCase('EYI')){
                        if(startAtVal > stopAtVal){
                            stopLoop = true; 
                        }    
                    }

                    if(intExp.operator.equalsIgnoreCase('EYD')){
                        if(startAtVal < stopAtVal){
                            stopLoop = true; 
                        }    
                    }
                    

                    intExp.attrValue = String.valueOf(startAtVal);
                }
                
                if(stopLoop){
                    break ;

                }
                listScheduleWrapperInst.add(intExp);

            } 

           
            if(listScheduleWrapperInst.size() == listConRul.size()){
                // Create schedule name here
                String updatedADVEXP = advancedExpression;
                PREV_SetupPMPlan_Wrapper.Schedule uniqueScheduleData = new PREV_SetupPMPlan_Wrapper.Schedule();
                if(!String.isBlank(updatedADVEXP)){
                    uniqueScheduleData.scheduleName =  advancedExpression; 

                    // Loop through to replace expression with mapUniqOrderSeq

                    uniqueScheduleData.scheduleName = parseAdvExp (uniqueScheduleData.scheduleName, listScheduleWrapperInst.size(), mapUniqOrderSeq);

                    for(integer repS = 0; repS <listScheduleWrapperInst.size(); repS++){
                        String ScheOPOrder = '~'+listScheduleWrapperInst[repS].order; 
                        Pattern MyPattern = Pattern.compile(ScheOPOrder);
                        Matcher MyMatcher = MyPattern.matcher(uniqueScheduleData.scheduleName);
                        uniqueScheduleData.scheduleName = MyMatcher.replaceAll(listScheduleWrapperInst[repS].attrValue);
                        uniqueScheduleData.selectedWOPurpose = workOdPurpose;
                    }

                    ScheduleInternalExpression schIntExp = new ScheduleInternalExpression();
                    schIntExp.rules = listScheduleWrapperInst; 
                    uniqueScheduleData.internalExpression = JSON.serializePretty(schIntExp);
                    uniqueScheduleData.sequence = String.valueOf(scheduleSeq);
                    uniqueScheduleData.advancedExpression = advancedExpression; //Added for defect BAC-2991 fix
                    scheduleSeq ++ ;
                    listSchWrapper.add(uniqueScheduleData);
                }
                
            }
            
            if(!stopLoop){
                wrapperScheduleRec(listConRul, listScheduleWrapperInst, advancedExpression, workOdPurpose, nonModConRule, mapUniqOrderSeq);
            }   
        }

        system.debug(listSchWrapper);

        return listSchWrapper; 
    }

    public String parseAdvExp ( String advExp, Integer wrapperSize, Map<String, string> mapUniqOrderSeq){
        String uniqueExpName = advExp;

        for(integer schWrapSize = 1; schWrapSize <=wrapperSize; schWrapSize++){
            String key = String.valueOf(schWrapSize);
            String val = mapUniqOrderSeq.get(String.valueOf(schWrapSize));
            
            Pattern MyPatternKey = Pattern.compile('\\b'+ key+ '\\b');
            Matcher MyMatcherSub = MyPatternKey.matcher(uniqueExpName);
            uniqueExpName = MyMatcherSub.replaceAll(val);
        }

        return uniqueExpName;
    }

    public class ScheduleInternalExpression{
        List <PREV_SetupPMPlan_Wrapper.InternalExpression> rules; 
        public scheduleInternalExpression(){

        }

        public ScheduleInternalExpression parse(String json) {
            return (ScheduleInternalExpression) System.JSON.deserialize(json, ScheduleInternalExpression.class);
        }
    }

    public Decimal addMethod(Decimal a, Decimal b){
        Decimal addVal = a+b;
        return addVal;
    }

    public Decimal subMethod(Decimal a, Decimal b){
        Decimal subVal = a-b;
        return subVal;
    }
    
    public List<PREV_SetupPMPlan_Wrapper.Schedule > getPMPlanSchedules(List<SVMXC__PM_Schedule__c> listPmSchedule){
        List<PREV_SetupPMPlan_Wrapper.Schedule> listPMScheduleWrapper = new List<PREV_SetupPMPlan_Wrapper.Schedule>();
        
        for(SVMXC__PM_Schedule__c pmSchRec: listPmSchedule){
            PREV_SetupPMPlan_Wrapper.Schedule wrapperSchRec= new PREV_SetupPMPlan_Wrapper.Schedule();
            wrapperSchRec.scheduleId            = pmSchRec.Id;
            wrapperSchRec.scheduleName          = pmSchRec.Name;
            //wrapperSchRec.scheduledOn           = pmSchRec.SVMXC__Scheduled_On__c;
            listPMScheduleWrapper.add(wrapperSchRec);
        }
        
        return listPMScheduleWrapper; 
    }
    
    // getCoverageType - Input Paramerter :  Field API name for which picklist needs to be retrieved
    // Output: List<SelectOption>
    public List<PREV_SetupPMPlan_Wrapper.KeyValue> getCoverageType(String fieldName){
        List<PREV_SetupPMPlan_Wrapper.KeyValue> coverageOptions = new List<PREV_SetupPMPlan_Wrapper.KeyValue>();
            
        Map<String, Schema.SObjectField> field_map = Schema.sObjectType.SVMXC__PM_Plan__c.fields.getMap() ;
        List<Schema.PicklistEntry> optionVal = field_map.get(fieldName).getDescribe().getPickListValues();
            
        for( Schema.PicklistEntry f : optionVal){
            coverageOptions.add(new PREV_SetupPMPlan_Wrapper.KeyValue(f.getLabel(), f.getValue()));
        }      
        return coverageOptions;
    }
    
    // Anchal - BAC-3226. As status is a text field in UI, we should pass translated value in UI which we can 
    // obtain by schema describe.
    public String getStatusType(String fieldName){
        Map<String, Schema.SObjectField> field_map = Schema.sObjectType.SVMXC__PM_Schedule__c.fields.getMap() ;
        List<Schema.PicklistEntry> optionVal = field_map.get('SVMXC__SM_Status__c').getDescribe().getPickListValues();
        
        String translatedStatusVal =  fieldName;    
        for( Schema.PicklistEntry f : optionVal){
            if(f.getValue().equalsIgnoreCase(fieldName)){
                translatedStatusVal = f.getLabel();
                break; 
            }
        }      
        
        return translatedStatusVal;
    }

    public PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response validateExpression(PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request request) {
        PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response validateExpRes = new PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response();
        
        PREV_PMPlanUtils objPMPlanUtils = new PREV_PMPlanUtils();

        Integer countOfRules = 0;
        String strAdvExpr = request.advancedExpression;
        if(request.conditionRuleList != null){
            countOfRules = request.conditionRuleList.size();
        }
        Boolean isAdvExprValid = objPMPlanUtils.validateAdvExpression(strAdvExpr, countOfRules);
        validateExpRes.success = true;
        if(!isAdvExprValid){
            validateExpRes.success = false;
            validateExpRes.messageList.add(System.Label.PREV004_TAG052);
            System.debug(LoggingLevel.WARN, 'Invalid Advanced Expression');
            return validateExpRes;
        }

        return  validateExpRes; 
    }

    public List<PREV_SetupPMPlan_Wrapper.Schedule> wrapperScheduleRecForCriteria (List<PREV_SetupPMPlan_Wrapper.ConditionRules> listConRul, String advancedExpression, Id workOdPurpose, Map <String, String> mapUniqOrderSeq){
        List<PREV_SetupPMPlan_Wrapper.InternalExpression> listScheduleWrapperInst = new List<PREV_SetupPMPlan_Wrapper.InternalExpression>();
        Map<String, String> mapRuleSeqToExpression = new Map<String, String>();
        Map<String, String> mapOperatorTextToOperatorSymbol = new Map<String, String>();
        mapOperatorTextToOperatorSymbol.put('eq', '=');
        mapOperatorTextToOperatorSymbol.put('gt', '>');
        mapOperatorTextToOperatorSymbol.put('lt', '<');

        if(listConRul != null && listConRul.size() > 0) {
            for( integer i = 0; i < listConRul.size(); i++){
                
                PREV_SetupPMPlan_Wrapper.InternalExpression intExp = new PREV_SetupPMPlan_Wrapper.InternalExpression();

                intExp.order = String.valueOf(Integer.valueOf(listConRul[i].sequence) );
                intExp.attrName = listConRul[i].selectedField;
                intExp.attrLabel = listConRul[i].selectedFieldLabel;
                intExp.operator = listConRul[i].selectedOperator;
                intExp.datatype = listConRul[i].fieldDataType; 
                intExp.attrType = listConRul[i].fieldAttType;
                intExp.attrValue = listConRul[i].value;
                listScheduleWrapperInst.add(intExp);

                String strOperatorSymbol = '';
                String strOperatorText = listConRul[i].selectedOperator;
                if(strOperatorText != null && mapOperatorTextToOperatorSymbol.containsKey(strOperatorText)){
                    strOperatorSymbol = mapOperatorTextToOperatorSymbol.get(strOperatorText);
                }
                String expression = listConRul[i].selectedFieldLabel+' '+strOperatorSymbol+' '+listConRul[i].value;
                mapRuleSeqToExpression.put(intExp.order, expression);
            }
           
            if(listScheduleWrapperInst.size() == listConRul.size()){
                // Create schedule name here
                String updatedADVEXP = advancedExpression;
                PREV_SetupPMPlan_Wrapper.Schedule uniqueScheduleData = new PREV_SetupPMPlan_Wrapper.Schedule();
                if(!String.isBlank(updatedADVEXP)){
                    uniqueScheduleData.scheduleName =  advancedExpression; 

                    // Loop through to replace expression with mapUniqOrderSeq
                    uniqueScheduleData.scheduleName = parseAdvExp (uniqueScheduleData.scheduleName, listScheduleWrapperInst.size(), mapUniqOrderSeq);

                    for(integer repS = 0; repS <listScheduleWrapperInst.size(); repS++){
                        String ScheOPOrder = '~'+listScheduleWrapperInst[repS].order; 
                        Pattern MyPattern = Pattern.compile(ScheOPOrder);
                        Matcher MyMatcher = MyPattern.matcher(uniqueScheduleData.scheduleName);
                        uniqueScheduleData.scheduleName = MyMatcher.replaceAll(mapRuleSeqToExpression.get(listScheduleWrapperInst[repS].order));
                        uniqueScheduleData.selectedWOPurpose = workOdPurpose;
                    }

                    ScheduleInternalExpression schIntExp = new ScheduleInternalExpression();
                    schIntExp.rules = listScheduleWrapperInst; 
                    uniqueScheduleData.internalExpression = JSON.serializePretty(schIntExp);
                    uniqueScheduleData.sequence = '1';
                    uniqueScheduleData.advancedExpression = advancedExpression; //Added for defect BAC-2991 fix
                    listSchWrapper.add(uniqueScheduleData);
                }
                
            }
        }
        system.debug(listSchWrapper);
        return listSchWrapper; 
    }
}