@isTest
Private with sharing class DCON_DispatchConsole_UT {
    
    static testMethod void DCON_DispatchConsole_UT_Test(){
        DCON_DispatchConsole dc = new DCON_DispatchConsole();
        
        dc.getMySessionId();
        //// system.assert(dc.getMySessionId()!=null, 'dc.getMySessionId() assertion failed');
        //// dc.getMySessionId();
        dc.getGMapAPI();
        system.assert(dc.getGMapAPI()!=null, 'dc.getGMapAPI() assertion failed');
        dc.getworkorderId();
        //system.assert(dc.getworkorderId()==null, 'dc.getworkorderId() assertion failed');
        dc.getUserLocaleKey();
        dc.getUserID();
        dc.getUserOrgID();
        dc.getUserTimezone();
        dc.getstrLoadEnglishFont();
        dc.getSET069();
        dc.getSET071();
        dc.getworkorderNo();
        dc.getUserInfodat();
        dc.getclientId();
        dc.getuserxml1();
        dc.getEnableGoogleMapApi();
        dc.getOptimaxLicenseEnabled1();
        dc.getuserxml();
        dc.getTAG026();
        dc.getTAG028();
        dc.getTAG029();
        dc.getTAG030();
        dc.getTAG031();
        dc.getTAG032();
        dc.getTAG033();
        dc.getTAG245();
        dc.getTAG246();
        dc.getTAG247();
        dc.getTAG252();
        dc.getTAG253();
        dc.getTAG464();
       // system.assert(dc.getworkorderNo()==null, 'dc.getworkorderNo() assertion failed');
    }
}