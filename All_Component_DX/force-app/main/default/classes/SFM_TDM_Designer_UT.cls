@isTest(seeAllData=true)
Private class SFM_TDM_Designer_UT{
    static testMethod void SFM_TDM_Designer_test(){
        
        System.currentPagereference().getParameters().put('SVMX_retURL','/apex/CONF_SetupHome');
        System.currentPagereference().getParameters().put('SVMX_ShowPrivate','true');
        System.currentPagereference().getParameters().put('processID','test');
        //*****Instance of class*****
        SVMXC.SFM_TDM_Designer designer = new SVMXC.SFM_TDM_Designer ();
        
        //*****Calling Method*****
        designer.getMySessionId();
        designer.getreturnURL();
        designer.getuserAuthTag();
        designer.getloadingTag();
        designer.getloadingProcTag();
        designer.getwelcomeTag();
        designer.getpartnerServerURL();
        designer.getShowPrivate();
        designer.getstrDefaultSortingColumn();
        designer.setShowPrivate('aa');
        designer.getisEnableAPITab();
        designer.getisEnableChecklist();
        designer.getProcessID();
        designer.setProcessID('aa');
        ////System.assertEquals(true, designer.getMySessionId() != null);
        System.assertEquals(true, designer.getreturnURL() != null);
    }
    
    //Added for the story BAC-3774
    static testMethod void SFM_TDM_Designer_Checklist_test(){
        System.currentPagereference().getParameters().put('SVMX_retURL','/apex/SVMXC__CONF_FeatureSetup');
        System.currentPagereference().getParameters().put('isStandAloneChecklist','true');
        //*****Instance of class*****
        SVMXC.SFM_TDM_Designer designer = new SVMXC.SFM_TDM_Designer ();
        //*****Calling Method*****
        designer.getloadingProcTag();
        designer.getwelcomeTag();
        designer.getisStandAloneChecklist();
    }
}