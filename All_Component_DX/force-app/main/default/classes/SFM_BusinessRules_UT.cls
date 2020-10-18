@isTest(SeeAllData = true)
public class SFM_BusinessRules_UT 
{
    static testMethod void SFM_BusinessRules_Test() 
    {
        string strReturnURL = '/apex/SVMXC__CONF_SetupHome';
        System.currentPageReference().getParameters().put('SVMX_retURL', strReturnURL);
        SFM_BusinessRules objBizRules = new SFM_BusinessRules();
        objBizRules.getreturnURL();
        objBizRules.getuserAuthTag();
        objBizRules.getloadingTag();
        objBizRules.getloadingProcTag();
        objBizRules.getwelcomeTag();
        objBizRules.getUserLocaleKey();
        objBizRules.getUserID();
        objBizRules.getUserOrgID();
    }
}