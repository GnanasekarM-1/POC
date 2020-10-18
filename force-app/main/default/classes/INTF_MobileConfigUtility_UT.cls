@isTest
private class INTF_MobileConfigUtility_UT
 {

    static testMethod void INTF_MobileConfigUtility_Test() 
    {
        INTF_MobileConfigUtility mobileConfigObj = new INTF_MobileConfigUtility();
        Map<String,Set<String>> objectsSFMProcess = new Map<String,Set<String>>();
        objectsSFMProcess.put('Account', new Set<String>());
        Map<String,String> objectsSFMPurpose = new Map<String,String>();
        String profileId = '';
        
        mobileConfigObj.getObjectPermissions(objectsSFMProcess,objectsSFMPurpose);
        mobileConfigObj.getSFMPurposePermissions();
        mobileConfigObj.calculateTwoPermissions('', '');
        mobileConfigObj.getMobileConfig(profileId,'iPad', false);
    }
}