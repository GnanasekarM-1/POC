@isTest
Private class PREV_SetupPMPlanTemplate_UT{
    static testMethod void JsrGetFilterList_Test(){
        SVMXC.PREV_SetupPMPlanTemplate objPREV_SetupPMPlanTemplate = new SVMXC.PREV_SetupPMPlanTemplate();
        objPREV_SetupPMPlanTemplate.getUserInfo();
        
        try{
            SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
            String request  = JSON.serialize(objPM_Plan_Template_Request);
            SVMXC.PREV_SetupPMPlanTemplate.JsrGetFilterList(request);
        }
        catch(Exception e){
        }
    }

    static testMethod void JsrGetActivityDateList_Test(){
        try{
            SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
            String request  = JSON.serialize(objPM_Plan_Template_Request);
            SVMXC.PREV_SetupPMPlanTemplate.JsrGetActivityDateList(request);
        }
        catch(Exception e){
        }
    }

    static testMethod void JsrGetPicklistValues_Test(){
        try{
            SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
            String request  = JSON.serialize(objPM_Plan_Template_Request);
            SVMXC.PREV_SetupPMPlanTemplate.JsrGetPicklistValues(request);
        }
        catch(Exception e){
        }
    }

    static testMethod void JsrGetTaskTemplate_Test(){
        try{
            SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
            String request  = JSON.serialize(objPM_Plan_Template_Request);
            SVMXC.PREV_SetupPMPlanTemplate.JsrGetTaskTemplate(request);
        }
        catch(Exception e){
        }
    }

    static testMethod void JsrSaveTemplateData_Test(){
        try{
            SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
            String request  = JSON.serialize(objPM_Plan_Template_Request);
            SVMXC.PREV_SetupPMPlanTemplate.JsrSaveTemplateData(request);
        }
        catch(Exception e){
        }
    }

    static testMethod void JsrSearchObject_Test(){
        try{
            SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
            String request  = JSON.serialize(objPM_Plan_Template_Request);
            SVMXC.PREV_SetupPMPlanTemplate.JsrSearchObject(request);
        }
        catch(Exception e){
        }
    }

    static testMethod void JsrGetRecordInfo_Test(){
        try{
            SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
            String request  = JSON.serialize(objPM_Plan_Template_Request);
            SVMXC.PREV_SetupPMPlanTemplate.JsrGetRecordInfo(request);
        }
        catch(Exception e){
        }
    }

    static testMethod void JsrGetTechnicalAttribute_Test(){
        try{
            SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
            String request  = JSON.serialize(objPM_Plan_Template_Request);
            SVMXC.PREV_SetupPMPlanTemplate.JsrGetTechnicalAttribute(request);
        }
        catch(Exception e){
        }
    }

    static testMethod void JsrGetSampleSchedules_Test(){
        try{
            SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
            String request  = JSON.serialize(objPM_Plan_Template_Request);
            SVMXC.PREV_SetupPMPlanTemplate.JsrGetSampleSchedules(request);
        }
        catch(Exception e){
        }
    }
}