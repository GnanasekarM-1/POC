@isTest(SeeAllData = true)
private class SFM_Mappings_UT 
{
    static testMethod void SFM_Mappings_Test() 
    {
        string strReturnURL = '/apex/SVMXC__CONF_SetupHome';
        System.currentPageReference().getParameters().put('SVMX_retURL', strReturnURL);
        SFM_Mappings objSFMMapping = new SFM_Mappings();
        objSFMMapping.getreturnURL();
        objSFMMapping.getuserAuthTag();
        objSFMMapping.getloadingTag();
        objSFMMapping.getloadingProcTag();
        objSFMMapping.getwelcomeTag();
        objSFMMapping.getUserLocaleKey();
        objSFMMapping.getUserID();
        objSFMMapping.getUserOrgID();
    }
}