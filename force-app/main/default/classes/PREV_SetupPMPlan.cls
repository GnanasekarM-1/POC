/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/** 
 * The PM_Plan is controller class for Create PM Plan Page, which 
 * handles the remote calls for various Services implemented.
 * 
 *
 * @author Anchal
 * @version
 * @since 2017
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Anchal               13 feb 2017     Created.
 *****************************************************************************************************/
global with sharing class PREV_SetupPMPlan {


    public String getUserInfo(){
        return JSON.serialize( new SVMXC.SFMDeliveryServiceImpl().getUserInfoInternal() );
    }
    
     //------------------------NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }

     /**
     * To get all the Default Settings for Manual Entitlement based on which the 
     * Entitlement Check has to be performed.
     */
    @RemoteAction
    global static Object getPMPlanData (String requestStr) {
        System.debug(logginglevel.info, 'pm plan() - Request : ' + requestStr);
        PREV_SetupPMPlan_Wrapper.PM_Plan_Request request = (PREV_SetupPMPlan_Wrapper.PM_Plan_Request) JSON.deserialize (requestStr, PREV_SetupPMPlan_Wrapper.PM_Plan_Request.Class);
        
        PREV_SetupPMPlan_Wrapper.PM_Plan_Response response = new PREV_SetupPMPlanImpl().getPMPlanDetails(request);
        System.debug(logginglevel.Info, 'getPMPlanDetails() - Response : ' + response);
        return JSON.serialize(response);
    }
    
    @RemoteAction
    global static Object getPMTemplateDetails (String requestStr) {
        System.debug(logginglevel.info, 'PM Template - Request : ' + requestStr);
        PREV_SetupPMPlan_Wrapper.PM_Plan_Request request = (PREV_SetupPMPlan_Wrapper.PM_Plan_Request) JSON.deserialize (requestStr, PREV_SetupPMPlan_Wrapper.PM_Plan_Request.Class);
        
        PREV_SetupPMPlan_Wrapper.PM_Plan_Response response = new PREV_SetupPMPlanImpl().getPMTemplateDetails(request);
        System.debug(logginglevel.Info, 'PM Template - Response : ' + response);
        return JSON.serialize(response);
    } 
    

    @RemoteAction
    global static Object getsearchData (String requestStr) {
        System.debug(logginglevel.info, 'Search - Request : ' + requestStr);
        PREV_SetupPMPlan_Wrapper.Search_Request request = (PREV_SetupPMPlan_Wrapper.Search_Request) JSON.deserialize (requestStr, PREV_SetupPMPlan_Wrapper.Search_Request.Class);
        
        PREV_SetupPMPlan_Wrapper.Search_Response response = new PREV_PMPlanUtils().getSearchresults(request);
        System.debug(logginglevel.Info, 'Search - Response : ' + response);
        return JSON.serialize(response);
    } 
    
    
    @RemoteAction
    global static Object savePMPlanData (String requestStr) {
        System.debug(logginglevel.info, 'Save PM Plan - Request : ' + requestStr);
        PREV_SetupPMPlan_Wrapper.PM_Plan_Request request = (PREV_SetupPMPlan_Wrapper.PM_Plan_Request) JSON.deserialize (requestStr, PREV_SetupPMPlan_Wrapper.PM_Plan_Request.Class);
        
        PREV_SetupPMPlan_Wrapper.PM_Plan_Response response = new PREV_SetupPMPlanImpl().savePMPlan(request);
        System.debug(logginglevel.Info, 'Save PM Plan - Response : ' + response);
        return JSON.serialize(response);
    } 
    
    @RemoteAction
    global static Object createScheduleRec (String requestStr) {
        System.debug(logginglevel.info, 'Get Covergae Schedule - Request : ' + requestStr);
        PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request request = (PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request) JSON.deserialize (requestStr, PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request.Class);
        
        PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response response = new PREV_SetupPMPlanImpl().createScheduleRec(request);
        System.debug(logginglevel.Info, 'Get Covergae Schedule - Response : ' + response);
        return JSON.serialize(response);
    }    
    
    @RemoteAction
    global static Object getCovergaeTechnicalAtt (String requestStr) {
        System.debug(logginglevel.info, 'Get Technical Att - Request : ' + requestStr);
        PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request request = (PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request) JSON.deserialize (requestStr, PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request.Class);
        
        PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response response = new PREV_SetupPMPlanImpl().getCovergaeTechnicalAtt(request);
        System.debug(logginglevel.Info, 'Get Technical Att - Response : ' + response);
        return JSON.serialize(response);
    } 
    
    @RemoteAction
    global static Object validateExp (String requestStr) {
        System.debug(logginglevel.info, 'Validate - Request : ' + requestStr);
        PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request request = (PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request) JSON.deserialize (requestStr, PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Request.Class);
        
        PREV_SetupPMPlan_Wrapper.Covergae_Schedule_Response response = new PREV_SetupPMPlanImpl().validateExpression(request);
        System.debug(logginglevel.Info, 'Validate - Response : ' + response);
        return JSON.serialize(response);
    }    
 
}