@isTest(SeeAllData = true)
private class SFM_Expressions_UT 
{
    static testMethod void SFM_Expressions_Test() 
    {
        string strReturnURL = '/apex/SVMXC__CONF_SetupHome';
        System.currentPageReference().getParameters().put('SVMX_retURL', strReturnURL);
        SFM_Expressions objSFMExpr = new SFM_Expressions();
        objSFMExpr.getreturnURL();
        objSFMExpr.getuserAuthTag();
        objSFMExpr.getloadingTag();
        objSFMExpr.getloadingProcTag();
        objSFMExpr.getwelcomeTag();        
        objSFMExpr.getUserLocaleKey();
        objSFMExpr.getUserID();
        objSFMExpr.getUserOrgID();
    }
}