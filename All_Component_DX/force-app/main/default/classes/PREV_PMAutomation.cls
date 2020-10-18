/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 *
 * @author Manish Kushwah
 * @version 19.3
 * @since 2019
 */
/*****************************************************************************************************
 *   Name                   Date              Comment
 *****************************************************************************************************
 *   Manish Kushwah         10 October 2019     Created only class and methods signature. 
 *****************************************************************************************************/
global with sharing class PREV_PMAutomation{

    //------Start-------Wrapper classes--------------//
    global class PREV_PMAutomationRequest{
        webservice List<String> pmPlanIdList {get;set;} 
    }

    global class PREV_PMAutomationResponse{
        webservice Boolean success {get;set;}
        webservice String message {get;set;}
        webservice String messageType {get;set;}
        webservice List<SVMXC.PREV_PMAutomation.PREV_PMAutomationResult> results{get;set;}
    }

    global class PREV_PMAutomationResult {
        webservice String pmPlanId {get;set;}
        webservice String errorMessage {get;set;}
        webservice Boolean success {get;set;}
    }
    //------End-------Wrapper classes--------------//

    //---------Start------------WebService Methods-----------//
    webservice static SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse createPMPlanFromAccount(SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request){
        SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = new SVMXC.PREV_PMAutomationImpl().createPMPlanFromAccountImpl(request);
        return response;
    }

    webservice static SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse createPMPlanFromLOC(SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request){
        SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = new SVMXC.PREV_PMAutomationImpl().createPMPlanFromLOCImpl(request);
        return response;
    }

    webservice static SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse createPMPlanFromSC(SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request){
        SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = new SVMXC.PREV_PMAutomationImpl().createPMPlanFromSCImpl(request);
        return response;
    }

    webservice static SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse createPMPlanFromIB(SVMXC.PREV_PMAutomation.PREV_PMAutomationRequest request){
        SVMXC.PREV_PMAutomation.PREV_PMAutomationResponse response = new SVMXC.PREV_PMAutomationImpl().createPMPlanFromIBImpl(request);
        return response;
    }
    //---------End------------WebService Methods-----------//
}