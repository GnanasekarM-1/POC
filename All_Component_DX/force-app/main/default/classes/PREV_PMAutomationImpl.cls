/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * 
 * 
 *
 * @author Manish Kushwah
 * @version 19.3
 * @since 2019
 */
/*****************************************************************************************************
 *   Name                   Date              Comment
 *****************************************************************************************************
 *   Manish Kushwah         10 October 2019      Created only class and methods signature. 
 *   Manish Kushwah         10 December 2019     Implemented the methods as part of story BAC-5153. 
 *****************************************************************************************************/
public with sharing class PREV_PMAutomationImpl{

    List<PREV_PMAutomation.PREV_PMAutomationResult> pmResults = new List<PREV_PMAutomation.PREV_PMAutomationResult>();
    Map<String, String> mapPMPlanIdVsTemplateId = new Map<String, String>();
    Map<String, String> mapPlanIdVsCoverageType = new Map<String, String>();
    Boolean isFieldAccessible = true;

    public PREV_PMAutomation.PREV_PMAutomationResponse createPMPlanFromAccountImpl(PREV_PMAutomation.PREV_PMAutomationRequest request){
        pmResults.clear();
        PREV_PMAutomation.PREV_PMAutomationResponse response = new PREV_PMAutomation.PREV_PMAutomationResponse();
        response.success = false;

        //Do validations
        Set<String> setPMPlanIds = new Set<String>();
        if(request != null && request.pmPlanIdList != null && !request.pmPlanIdList.isEmpty()){
            
            setPMPlanIds = checkForValidPMTemplate(new Set<String>(request.pmPlanIdList));

            Set<String> setPlanIdsWhichNeedsScheduleCheck = new Set<String>();
            Set<String> setPlanIdsWhichNeedsSchAndCovCheck = new Set<String>();

            if(!setPMPlanIds.isEmpty()){
                for(String strPMPlanId : setPMPlanIds){
                    String strCovType = mapPlanIdVsCoverageType.get(strPMPlanId);
                    if(strCovType == 'Account (Visit Only)'){
                        setPlanIdsWhichNeedsScheduleCheck.add(strPMPlanId);
                    }
                    else if(strCovType == 'Product (Must Have IB)' || strCovType == 'Location (Must Have Location)'){
                        setPlanIdsWhichNeedsSchAndCovCheck.add(strPMPlanId);
                    }
                }
                setPMPlanIds.clear();

                if(!setPlanIdsWhichNeedsScheduleCheck.isEmpty()){
                    setPlanIdsWhichNeedsScheduleCheck = checkSchedule(setPlanIdsWhichNeedsScheduleCheck);
                    setPMPlanIds.addAll(setPlanIdsWhichNeedsScheduleCheck);
                }

                if(!setPlanIdsWhichNeedsSchAndCovCheck.isEmpty()){
                    setPlanIdsWhichNeedsSchAndCovCheck = checkCoverageAndSchedule(setPlanIdsWhichNeedsSchAndCovCheck);
                    setPMPlanIds.addAll(setPlanIdsWhichNeedsSchAndCovCheck);
                }

                if(!setPMPlanIds.isEmpty()){
                    setPMPlanIds = checkAndCreatePMScheduleDefinition(setPMPlanIds);
                }
            }
        }

        INTF_WebservicesDef.INTF_Request requestINTF = createINTFRequest(setPMPlanIds, 'Account');
        response.results = new List<PREV_PMAutomation.PREV_PMAutomationResult>(pmResults);

        if(requestINTF != null){
            PREV_PMPlanUtils objPREV_PMPlanUtils = new PREV_PMPlanUtils();
            SVMXC.INTF_WebservicesDef.INTF_Response objINTFResponse = objPREV_PMPlanUtils.PREV_CalculatePMPlanDetails(requestINTF);
            response.success = objINTFResponse.success;
            response.message = objINTFResponse.message;
            response.messageType = objINTFResponse.messageType;
        }

        if(!isFieldAccessible){
            response.message = System.label.COMM001_TAG142;
            isFieldAccessible = true;
        }

        pmResults.clear();
        mapPMPlanIdVsTemplateId.clear();
        mapPlanIdVsCoverageType.clear();
        System.debug('ResponesJSON: '+JSON.serialize(response));
        return response;
    }

    public PREV_PMAutomation.PREV_PMAutomationResponse createPMPlanFromLOCImpl(PREV_PMAutomation.PREV_PMAutomationRequest request){
        pmResults.clear();
        PREV_PMAutomation.PREV_PMAutomationResponse response = new PREV_PMAutomation.PREV_PMAutomationResponse();
        response.success = false;

        //Do validations
        Set<String> setPMPlanIds = new Set<String>();
        if(request != null && request.pmPlanIdList != null && !request.pmPlanIdList.isEmpty()){

            setPMPlanIds = checkForValidPMTemplate(new Set<String>(request.pmPlanIdList));

            Set<String> setPlanIdsWhichNeedsScheduleCheck = new Set<String>();
            Set<String> setPlanIdsWhichNeedsSchAndCovCheck = new Set<String>();

            if(!setPMPlanIds.isEmpty()){
                for(String strPMPlanId : setPMPlanIds){
                    String strCovType = mapPlanIdVsCoverageType.get(strPMPlanId);
                    if(strCovType == 'Account (Visit Only)'){
                        setPlanIdsWhichNeedsScheduleCheck.add(strPMPlanId);
                    }
                    else if(strCovType == 'Product (Must Have IB)' || strCovType == 'Location (Must Have Location)'){
                        setPlanIdsWhichNeedsSchAndCovCheck.add(strPMPlanId);
                    }
                }
                setPMPlanIds.clear();

                if(!setPlanIdsWhichNeedsScheduleCheck.isEmpty()){
                    setPlanIdsWhichNeedsScheduleCheck = checkSchedule(setPlanIdsWhichNeedsScheduleCheck);
                    setPMPlanIds.addAll(setPlanIdsWhichNeedsScheduleCheck);
                }

                if(!setPlanIdsWhichNeedsSchAndCovCheck.isEmpty()){
                    setPlanIdsWhichNeedsSchAndCovCheck = checkCoverageAndSchedule(setPlanIdsWhichNeedsSchAndCovCheck);
                    setPMPlanIds.addAll(setPlanIdsWhichNeedsSchAndCovCheck);
                }

                if(!setPMPlanIds.isEmpty()){
                    setPMPlanIds = checkAndCreatePMScheduleDefinition(setPMPlanIds);
                }
            }
        }

        INTF_WebservicesDef.INTF_Request requestINTF = createINTFRequest(setPMPlanIds, 'Location');
        response.results = new List<PREV_PMAutomation.PREV_PMAutomationResult>(pmResults);

        if(requestINTF != null){
            PREV_PMPlanUtils objPREV_PMPlanUtils = new PREV_PMPlanUtils();
            SVMXC.INTF_WebservicesDef.INTF_Response objINTFResponse = objPREV_PMPlanUtils.PREV_CalculatePMPlanDetails(requestINTF);
            response.success = objINTFResponse.success;
            response.message = objINTFResponse.message;
            response.messageType = objINTFResponse.messageType;
        }

        if(!isFieldAccessible){
            response.message = System.label.COMM001_TAG142;
            isFieldAccessible = true;
        }
        pmResults.clear();
        mapPMPlanIdVsTemplateId.clear();
        mapPlanIdVsCoverageType.clear();
        System.debug('ResponesJSON: '+JSON.serialize(response));
        return response;
    }

    public PREV_PMAutomation.PREV_PMAutomationResponse createPMPlanFromSCImpl(PREV_PMAutomation.PREV_PMAutomationRequest request){
        pmResults.clear();
        PREV_PMAutomation.PREV_PMAutomationResponse response = new PREV_PMAutomation.PREV_PMAutomationResponse();
        response.success = false;

        //Do validations
        Set<String> setPMPlanIds = new Set<String>();
        if(request != null && request.pmPlanIdList != null && !request.pmPlanIdList.isEmpty()){

            setPMPlanIds = checkForValidPMTemplate(new Set<String>(request.pmPlanIdList));

            Set<String> setPlanIdsWhichNeedsScheduleCheck = new Set<String>();
            Set<String> setPlanIdsWhichNeedsSchAndCovCheck = new Set<String>();

            if(!setPMPlanIds.isEmpty()){
                for(String strPMPlanId : setPMPlanIds){
                    String strCovType = mapPlanIdVsCoverageType.get(strPMPlanId);
                    if(strCovType == 'Account (Visit Only)'){
                        setPlanIdsWhichNeedsScheduleCheck.add(strPMPlanId);
                    }
                    else if(strCovType == 'Product (Must Have IB)' || strCovType == 'Location (Must Have Location)'){
                        setPlanIdsWhichNeedsSchAndCovCheck.add(strPMPlanId);
                    }
                }
                setPMPlanIds.clear();

                if(!setPlanIdsWhichNeedsScheduleCheck.isEmpty()){
                    setPlanIdsWhichNeedsScheduleCheck = checkSchedule(setPlanIdsWhichNeedsScheduleCheck);
                    setPMPlanIds.addAll(setPlanIdsWhichNeedsScheduleCheck);
                }

                if(!setPlanIdsWhichNeedsSchAndCovCheck.isEmpty()){
                    setPlanIdsWhichNeedsSchAndCovCheck = checkCoverageAndSchedule(setPlanIdsWhichNeedsSchAndCovCheck);
                    setPMPlanIds.addAll(setPlanIdsWhichNeedsSchAndCovCheck);
                }

                if(!setPMPlanIds.isEmpty()){
                    setPMPlanIds = checkAndCreatePMScheduleDefinition(setPMPlanIds);
                }
            }
        }

        //Create Request
        INTF_WebservicesDef.INTF_Request requestINTF = createINTFRequest(setPMPlanIds, 'SC');
        response.results = new List<PREV_PMAutomation.PREV_PMAutomationResult>(pmResults);

        if(requestINTF != null){
            PREV_PMPlanUtils objPREV_PMPlanUtils = new PREV_PMPlanUtils();
            SVMXC.INTF_WebservicesDef.INTF_Response objINTFResponse = objPREV_PMPlanUtils.PREV_CalculatePMPlanDetails(requestINTF);
            response.success = objINTFResponse.success;
            response.message = objINTFResponse.message;
            response.messageType = objINTFResponse.messageType;
        }

        if(!isFieldAccessible){
            response.message = System.label.COMM001_TAG142;
            isFieldAccessible = true;
        }

        pmResults.clear();
        mapPMPlanIdVsTemplateId.clear();
        mapPlanIdVsCoverageType.clear();
        System.debug('ResponesJSON: '+JSON.serialize(response));
        return response;
    }

    public PREV_PMAutomation.PREV_PMAutomationResponse createPMPlanFromIBImpl(PREV_PMAutomation.PREV_PMAutomationRequest request){
        pmResults.clear();
        PREV_PMAutomation.PREV_PMAutomationResponse response = new PREV_PMAutomation.PREV_PMAutomationResponse();
        response.success = false;

        //Do validations
        Set<String> setPMPlanIds = new Set<String>();
        if(request != null && request.pmPlanIdList != null && !request.pmPlanIdList.isEmpty()){
            setPMPlanIds = checkForValidPMTemplate(new Set<String>(request.pmPlanIdList));
            setPMPlanIds = checkSchedule(setPMPlanIds);
            setPMPlanIds = checkAndCreatePMScheduleDefinition(setPMPlanIds);
        }

        INTF_WebservicesDef.INTF_Request requestINTF = createINTFRequest(setPMPlanIds, 'IB');
        response.results = new List<PREV_PMAutomation.PREV_PMAutomationResult>(pmResults);

        if(requestINTF != null){
            PREV_PMPlanUtils objPREV_PMPlanUtils = new PREV_PMPlanUtils();
            SVMXC.INTF_WebservicesDef.INTF_Response objINTFResponse = objPREV_PMPlanUtils.PREV_CalculatePMPlanDetails(requestINTF);
            response.success = objINTFResponse.success;
            response.message = objINTFResponse.message;
            response.messageType = objINTFResponse.messageType;
        }
        
        if(!isFieldAccessible){
            response.message = System.label.COMM001_TAG142;
            isFieldAccessible = true;
        }

        pmResults.clear();
        mapPMPlanIdVsTemplateId.clear();
        mapPlanIdVsCoverageType.clear();
        System.debug('ResponesJSON: '+JSON.serialize(response));
        return response;
    }

    public INTF_WebservicesDef.INTF_Request createINTFRequest(Set<String> setPMPlanIds, String strMode){
        INTF_WebservicesDef.INTF_Request requestINTF;

        if(!setPMPlanIds.isEmpty() && String.isNotBlank(strMode)){

            List<INTF_WebservicesDef.INTF_StringListMap> stringListMap = new List<INTF_WebservicesDef.INTF_StringListMap>();

            INTF_WebservicesDef.INTF_StringListMap objMode = new INTF_WebservicesDef.INTF_StringListMap();
            objMode.key = 'Mode';
            objMode.valueList = new List<String>{strMode};
            stringListMap.add(objMode);

            INTF_WebservicesDef.INTF_StringListMap objPMPlanIds = new INTF_WebservicesDef.INTF_StringListMap();
            objPMPlanIds.key = 'PM Plan';
            objPMPlanIds.valueList = new List<String>(setPMPlanIds);
            stringListMap.add(objPMPlanIds);

            requestINTF = new INTF_WebservicesDef.INTF_Request();
            requestINTF.stringListMap = stringListMap;
        }
        System.debug('RequestINTF: '+requestINTF);
        return requestINTF;
    }

    public Set<String> checkSchedule(Set<String> setPMPlanIds){

        if(!setPMPlanIds.isEmpty()){
            System.debug('setPMPlanIds: '+setPMPlanIds);
            
            //Check which PM plan ids has schedule details
            Set<String> setPMPlanIdWhichHasSchedule = new Set<String>();
            if(Schema.sObjectType.SVMXC__PM_Schedule__c.fields.SVMXC__PM_Plan__c.IsAccessible()){
                for(SVMXC__PM_Schedule__c objPMSch : [SELECT SVMXC__PM_Plan__c FROM SVMXC__PM_Schedule__c WHERE SVMXC__PM_Plan__c IN: setPMPlanIds]){
                    setPMPlanIdWhichHasSchedule.add(objPMSch.SVMXC__PM_Plan__c);
                }
            }
            else{
                isFieldAccessible = false;
                return new Set<String>();
            }

            if(!setPMPlanIdWhichHasSchedule.isEmpty()){
                setPMPlanIds.removeAll(setPMPlanIdWhichHasSchedule);
            }
            System.debug('setPMPlanIdWhichHasSchedule: '+setPMPlanIdWhichHasSchedule);

            //Create error details for the response
            for(String strPMPlanId : setPMPlanIdWhichHasSchedule){
                PREV_PMAutomation.PREV_PMAutomationResult result = new PREV_PMAutomation.PREV_PMAutomationResult();
                result.pmPlanId = strPMPlanId;
                result.errorMessage = 'Processing of PM Plan has been skipped as it already has Schedule.';
                result.success = false;

                pmResults.add(result);
            }
            setPMPlanIdWhichHasSchedule.clear();

            System.debug('setPMPlanIds: '+setPMPlanIds);
            return setPMPlanIds;
        }
        else{
            return new Set<String>();
        }
    }

    public Set<String> checkCoverageAndSchedule(Set<String> setPMPlanIds){

        if(!setPMPlanIds.isEmpty()){
            System.debug('setPMPlanIds: '+setPMPlanIds);
            //Check which PM plan ids has coverage details
            Set<String> setPMPlanIdWhichHasCov = new Set<String>();
            if(Schema.sObjectType.SVMXC__PM_Coverage__c.fields.SVMXC__PM_Plan__c.IsAccessible()){
                for(SVMXC__PM_Coverage__c objPMCov : [SELECT SVMXC__PM_Plan__c FROM SVMXC__PM_Coverage__c WHERE SVMXC__PM_Plan__c IN: setPMPlanIds]){
                    setPMPlanIdWhichHasCov.add(objPMCov.SVMXC__PM_Plan__c);
                }
            }
            else{
                isFieldAccessible = false;
                return new Set<String>();
            }

            if(!setPMPlanIdWhichHasCov.isEmpty()){
                setPMPlanIds.removeAll(setPMPlanIdWhichHasCov);
            }
            System.debug('setPMPlanIdWhichHasCov: '+setPMPlanIdWhichHasCov);

            //Check which PM plan ids has schedule details
            Set<String> setPMPlanIdWhichHasSchedule = new Set<String>();
            if(Schema.sObjectType.SVMXC__PM_Schedule__c.fields.SVMXC__PM_Plan__c.IsAccessible()){
                for(SVMXC__PM_Schedule__c objPMSch : [SELECT SVMXC__PM_Plan__c FROM SVMXC__PM_Schedule__c WHERE SVMXC__PM_Plan__c IN: setPMPlanIds]){
                    setPMPlanIdWhichHasSchedule.add(objPMSch.SVMXC__PM_Plan__c);
                }
            }
            else{
                isFieldAccessible = false;
                return new Set<String>();
            }

            if(!setPMPlanIdWhichHasSchedule.isEmpty()){
                setPMPlanIds.removeAll(setPMPlanIdWhichHasSchedule);
            }
            System.debug('setPMPlanIdWhichHasSchedule: '+setPMPlanIdWhichHasSchedule);

            //Create error details for the response
            setPMPlanIdWhichHasCov.addAll(setPMPlanIdWhichHasSchedule);
            for(String strPMPlanId : setPMPlanIdWhichHasCov){
                PREV_PMAutomation.PREV_PMAutomationResult result = new PREV_PMAutomation.PREV_PMAutomationResult();
                result.pmPlanId = strPMPlanId;
                result.errorMessage = 'Processing of PM Plan has been skipped as it has either Coverage or Schedule.';
                result.success = false;

                pmResults.add(result);
            }
            setPMPlanIdWhichHasCov.clear();
            setPMPlanIdWhichHasSchedule.clear();

            System.debug('setPMPlanIds: '+setPMPlanIds);
            return setPMPlanIds;
        }
        else{
            return new Set<String>();
        }
    }

    public Set<String> checkForValidPMTemplate(Set<String> setPMPlanIds){

        if(!setPMPlanIds.isEmpty()){
            System.debug('setPMPlanIds: '+setPMPlanIds);
            Set<String> setEighteenCharacIds = new Set<String>();

            //Query PM Plans and check the associated template is there or not and also if it is there then it is valid or not
            Set<String> setPMPlanIdWithInValidTemplate = new Set<String>();
            Set<String> setPMPlanIdsNotTimeBased = new Set<String>();
            if(Schema.sObjectType.SVMXC__PM_Plan__c.fields.SVMXC__PM_Plan_Template__c.IsAccessible() && Schema.sObjectType.SVMXC__PM_Plan__c.fields.SVMXC__Schedule_Type__c.IsAccessible() && Schema.sObjectType.SVMXC__PM_Plan__c.fields.SVMXC__Coverage_Type__c.IsAccessible() && Schema.sObjectType.SVMXC__PM_Plan_Template__c.fields.SVMXC__Status__c.IsAccessible()){

                for(SVMXC__PM_Plan__c objPMPlan : [SELECT Id, SVMXC__PM_Plan_Template__c, SVMXC__PM_Plan_Template__r.SVMXC__Status__c, SVMXC__Schedule_Type__c, SVMXC__Coverage_Type__c FROM SVMXC__PM_Plan__c WHERE Id IN: setPMPlanIds]){
                    if(objPMPlan.SVMXC__Schedule_Type__c != 'Time Based'){
                        setPMPlanIdsNotTimeBased.add(objPMPlan.Id);
                    }
                    else if(objPMPlan.SVMXC__PM_Plan_Template__c == null || objPMPlan.SVMXC__PM_Plan_Template__r.SVMXC__Status__c == 'Incomplete'){
                        setPMPlanIdWithInValidTemplate.add(objPMPlan.Id);    
                    }
                    else{
                        mapPMPlanIdVsTemplateId.put(objPMPlan.Id, objPMPlan.SVMXC__PM_Plan_Template__c);
                    }
                    setEighteenCharacIds.add(objPMPlan.Id);
                    mapPlanIdVsCoverageType.put(objPMPlan.Id, objPMPlan.SVMXC__Coverage_Type__c);
                }
            }
            else{
                isFieldAccessible = false;
                return new Set<String>();
            }
            
            System.debug('setPMPlanIdWithInValidTemplate: '+setPMPlanIdWithInValidTemplate);
            System.debug('setPMPlanIdsNotTimeBased: '+setPMPlanIdsNotTimeBased);
            setPMPlanIds.clear();
            setEighteenCharacIds.removeAll(setPMPlanIdWithInValidTemplate);
            setEighteenCharacIds.removeAll(setPMPlanIdsNotTimeBased);

            //Create error details for the response where PMPlanId With InValid Template
            for(String strPMPlanId : setPMPlanIdWithInValidTemplate){
                PREV_PMAutomation.PREV_PMAutomationResult result = new PREV_PMAutomation.PREV_PMAutomationResult();
                result.pmPlanId = strPMPlanId;
                result.errorMessage = 'Processing of PM Plan is failed due to PM Plan Template is missing OR Incomplete PM Plan Template.';
                result.success = false;
                pmResults.add(result);
            }
            setPMPlanIdWithInValidTemplate.clear();

            //Create error details for the response where PMPlanId is not Time Based
            for(String strPMPlanId : setPMPlanIdsNotTimeBased){
                PREV_PMAutomation.PREV_PMAutomationResult result = new PREV_PMAutomation.PREV_PMAutomationResult();
                result.pmPlanId = strPMPlanId;
                result.errorMessage = 'Processing of PM Plan is failed as it is not Time Based PM Plan.';
                result.success = false;
                pmResults.add(result);
            }
            setPMPlanIdsNotTimeBased.clear();

            System.debug('setEighteenCharacIds: '+setEighteenCharacIds);
            return setEighteenCharacIds;
        }
        else{
            return new Set<String>();
        }
    }

    public Set<String> checkAndCreatePMScheduleDefinition(Set<String> setPMPlanIds){

        if(!setPMPlanIds.isEmpty()){
            System.debug('setPMPlanIds: '+setPMPlanIds);
            //Check which all PM Plans has Schedule Definition and don't consider them for Schedule Definition creation
            Set<String> setPMPlanWhichHasDefi = new Set<String>();
            if(Schema.sObjectType.SVMXC__PM_Schedule_Definition__c.fields.SVMXC__PM_Plan__c.IsAccessible() && Schema.sObjectType.SVMXC__PM_Plan__c.fields.SVMXC__PM_Plan_Template__c.IsAccessible()){
                for(SVMXC__PM_Schedule_Definition__c objPMScheDefi : [SELECT Id, SVMXC__PM_Plan__c, SVMXC__PM_Plan__r.SVMXC__PM_Plan_Template__c FROM SVMXC__PM_Schedule_Definition__c WHERE SVMXC__PM_Plan__c IN: setPMPlanIds]){
                    setPMPlanWhichHasDefi.add(objPMScheDefi.SVMXC__PM_Plan__c);
                }
            }
            else{
                isFieldAccessible = false;
                return new Set<String>();
            }
            System.debug('setPMPlanWhichHasDefi: '+setPMPlanWhichHasDefi);
            
            setPMPlanIds.removeAll(setPMPlanWhichHasDefi);

            System.debug('setPMPlanIds: '+setPMPlanIds);

            //Query Schedule Template and create a map of template id and list of Schedule Template records
            if(!(Schema.sObjectType.SVMXC__PM_Schedule_Template__c.fields.SVMXC__Frequency__c.IsAccessible() && Schema.sObjectType.SVMXC__PM_Schedule_Template__c.fields.SVMXC__Frequency_Unit__c.IsAccessible() && Schema.sObjectType.SVMXC__PM_Schedule_Template__c.fields.SVMXC__Recurring__c.IsAccessible() && Schema.sObjectType.SVMXC__PM_Schedule_Template__c.fields.SVMXC__Schedule_Type__c.IsAccessible() && Schema.sObjectType.SVMXC__PM_Schedule_Template__c.fields.SVMXC__Visit_Description__c.IsAccessible() && Schema.sObjectType.SVMXC__PM_Schedule_Template__c.fields.SVMXC__Work_Order_Purpose__c.IsAccessible() && Schema.sObjectType.SVMXC__PM_Schedule_Template__c.fields.SVMXC__PM_Plan_Template__c.IsAccessible())){
                isFieldAccessible = false;
                return new Set<String>();
            }
            List<SVMXC__PM_Schedule_Template__c> lstPMScheduleTemplate = [SELECT Id, SVMXC__Frequency__c, SVMXC__Frequency_Unit__c, SVMXC__Recurring__c, SVMXC__Schedule_Type__c, SVMXC__Visit_Description__c, SVMXC__Work_Order_Purpose__c, SVMXC__PM_Plan_Template__c FROM SVMXC__PM_Schedule_Template__c WHERE SVMXC__PM_Plan_Template__c IN: mapPMPlanIdVsTemplateId.values()];

            Map<String, List<SVMXC__PM_Schedule_Template__c>> mapPlanTemplateIdVsListScheTemplate = new Map<String, List<SVMXC__PM_Schedule_Template__c>>();
            
            for(SVMXC__PM_Schedule_Template__c objST : lstPMScheduleTemplate){
                
                if(!mapPlanTemplateIdVsListScheTemplate.containsKey(objST.SVMXC__PM_Plan_Template__c)){
                    mapPlanTemplateIdVsListScheTemplate.put(objST.SVMXC__PM_Plan_Template__c, new List<SVMXC__PM_Schedule_Template__c>());
                }

                mapPlanTemplateIdVsListScheTemplate.get(objST.SVMXC__PM_Plan_Template__c).add(objST);
            }
            System.debug('mapPlanTemplateIdVsListScheTemplate: '+mapPlanTemplateIdVsListScheTemplate);

            //Iterate over PM Plan ids and create Schedule Definition from the associated template for the pm plans
            List<SVMXC__PM_Schedule_Definition__c> lstScheduleDefinitionForCreation = new List<SVMXC__PM_Schedule_Definition__c>();
            for(String strPMPlanId : setPMPlanIds){
                System.debug('strPMPlanId: '+strPMPlanId);
                if(mapPMPlanIdVsTemplateId.containsKey(strPMPlanId)){
                    String strTemplateId = mapPMPlanIdVsTemplateId.get(strPMPlanId);
                    System.debug('strTemplateId: '+strTemplateId);
                    if(mapPlanTemplateIdVsListScheTemplate.containsKey(strTemplateId)){
                        List<SVMXC__PM_Schedule_Template__c> lstScheduleTemplate = mapPlanTemplateIdVsListScheTemplate.get(strTemplateId);
                        System.debug('lstScheduleTemplate: '+lstScheduleTemplate);
                        for(SVMXC__PM_Schedule_Template__c objScheduleTemplate : lstScheduleTemplate){
                            SVMXC__PM_Schedule_Definition__c objPMSheduleDefinition = new SVMXC__PM_Schedule_Definition__c();
                            objPMSheduleDefinition.SVMXC__Frequency__c = objScheduleTemplate.SVMXC__Frequency__c;
                            objPMSheduleDefinition.SVMXC__Frequency_Unit__c = objScheduleTemplate.SVMXC__Frequency_Unit__c;
                            objPMSheduleDefinition.SVMXC__Recurring__c = objScheduleTemplate.SVMXC__Recurring__c;
                            objPMSheduleDefinition.SVMXC__Schedule_Type__c = objScheduleTemplate.SVMXC__Schedule_Type__c;
                            objPMSheduleDefinition.SVMXC__Visit_Description__c = objScheduleTemplate.SVMXC__Visit_Description__c;
                            objPMSheduleDefinition.SVMXC__Work_Order_Purpose__c = objScheduleTemplate.SVMXC__Work_Order_Purpose__c;
                            objPMSheduleDefinition.SVMXC__PM_Plan__c = strPMPlanId;
                            lstScheduleDefinitionForCreation.add(objPMSheduleDefinition);
                        }
                    }
                }
            }

            if(!lstScheduleDefinitionForCreation.isEmpty())
                insert lstScheduleDefinitionForCreation;

            setPMPlanIds.addAll(setPMPlanWhichHasDefi);

            return setPMPlanIds;
        }
        else{
            return new Set<String>();
        }
    }
}