@isTest
Private  class CONF_FeatureSetup_UT
{
    public static testMethod void CONF_FeatureSetup()
    {
        test.starttest();
         CONF_FeatureSetup featureApplicationSetup = new CONF_FeatureSetup();
        featureApplicationSetup.getUserLocaleKey();
        featureApplicationSetup.getUserID();
        featureApplicationSetup.getUserOrgID();
        featureApplicationSetup.getIsChecklistFeatureEnabled();
        featureApplicationSetup.GetSvmxLogoId();
        featureApplicationSetup.getTagGroupName1();
        featureApplicationSetup.getTagGroupTitle1();
        featureApplicationSetup.getTagGroupDes1();
        featureApplicationSetup.getTagName1();
        featureApplicationSetup.getTagTitle1();
        featureApplicationSetup.getTagDesc1();
        featureApplicationSetup.getTagName2();
        featureApplicationSetup.getTagTitle2();
        featureApplicationSetup.getTagDesc2();
        featureApplicationSetup.getTagName3();
        featureApplicationSetup.getTagTitle3();
        featureApplicationSetup.getTagDesc3();
        featureApplicationSetup.getTAG001();
        featureApplicationSetup.getTAG002();
        featureApplicationSetup.getTagGroupNote();
        featureApplicationSetup.getTagURL120();
        featureApplicationSetup.isHtmlView = true;
        featureApplicationSetup.getTagURL52();
        featureApplicationSetup.getTagURL95();
        featureApplicationSetup.getTagHLPURL();
        featureApplicationSetup.getTagGroupText1();
        featureApplicationSetup.getLicenseType();
        featureApplicationSetup.getVersionNo();
        featureApplicationSetup.getCONF005_TAG004();
        featureApplicationSetup.getCONF005_TAG005();
        test.stoptest();
     }
}