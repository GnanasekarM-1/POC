/*****************************************************************************
 *                       Copyright (C) 2017 ServiceMax From GE Digital, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/** 
 * The PREV_SetupPMPlanTemplate is controller class for PM Plan template Page, which 
 * handles the remote calls for various Services implemented.
 * 
 *
 * @author Manish
 * @version
 * @since 2017
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Manish               17 Feb 2017       Created.
 *****************************************************************************************************/
global with sharing class PREV_SetupPMPlanTemplate {

    public String getUserInfo(){
        return JSON.serialize( new SVMXC.SFMDeliveryServiceImpl().getUserInfoInternal() );
    }

    @RemoteAction
    global static Object JsrGetFilterList(String requestStr){
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objRequest = (SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request)JSON.deserialize(requestStr, SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request.class);
        return JSON.serialize(new SVMXC.PREV_SetupPMPlanTemplateImpl().PREV_GetFilterList(objRequest));
    }

    @RemoteAction
    global static Object JsrGetTaskTemplate(String requestStr){
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objRequest = (SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request)JSON.deserialize(requestStr, SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request.class);
        return JSON.serialize(new SVMXC.PREV_SetupPMPlanTemplateImpl().PREV_GetTaskTemplate(objRequest));
    }

    @RemoteAction
    global static Object JsrGetActivityDateList(String requestStr){
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objRequest = (SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request)JSON.deserialize(requestStr, SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request.class);
        return JSON.serialize(new SVMXC.PREV_SetupPMPlanTemplateImpl().PREV_GetActivityDateList(objRequest));
    }

    @RemoteAction
    global static Object JsrGetPicklistValues(String requestStr){
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objRequest = (SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request)JSON.deserialize(requestStr, SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request.class);
        return JSON.serialize(new SVMXC.PREV_SetupPMPlanTemplateImpl().PREV_GetPicklistValues(objRequest));
    }

    @RemoteAction
    global static Object JsrSaveTemplateData(String requestStr){
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objRequest = (SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request)JSON.deserialize(requestStr, SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request.class);
        return JSON.serialize(new SVMXC.PREV_SetupPMPlanTemplateImpl().PREV_SaveTemplateData(objRequest));
    }

    @RemoteAction
    global static Object JsrSearchObject(String requestStr) {
        SVMXC.PREV_SetupPMPlan_Wrapper.Search_Request objRequest = (SVMXC.PREV_SetupPMPlan_Wrapper.Search_Request)JSON.deserialize(requestStr, SVMXC.PREV_SetupPMPlan_Wrapper.Search_Request.Class);
        return JSON.serialize(new SVMXC.PREV_PMPlanUtils().getSearchresults(objRequest));
    }

    @RemoteAction
    global static Object JsrGetRecordInfo(String requestStr){
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objRequest = (SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request)JSON.deserialize(requestStr, SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request.class);
        return JSON.serialize(new SVMXC.PREV_SetupPMPlanTemplateImpl().PREV_GetRecordInfo(objRequest));
    }

    @RemoteAction
    global static Object JsrGetTechnicalAttribute(String requestStr){
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objRequest = (SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request)JSON.deserialize(requestStr, SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request.class);
        return JSON.serialize(new SVMXC.PREV_PMPlanUtils().PREV_GetTechnicalAttribute(objRequest));
    }

    @RemoteAction
    global static Object JsrGetSampleSchedules(String requestStr){
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objRequest = (SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request)JSON.deserialize(requestStr, SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request.class);
        return JSON.serialize(new SVMXC.PREV_SetupPMPlanTemplateImpl().PREV_GetSampleSchedules(objRequest));
    }
    public PREV_SetupPMPlanTemplate(){}
}