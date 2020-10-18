/**
 * The TOOL_PostPackageInstall will encode the org id and will be involked as 
 * a post install script. This class internally calls TOOL_SeedAppSettingHandler
 * to install seed components.
 *
 *
 * @author D B Sathish Kumar
 * @version Sum 17
 * @created 19/04/2017
 * @updated 14/01/2020
 */

global without sharing class TOOL_PostPackageInstall implements InstallHandler {

    static boolean isManual = false;

    global void onInstall(InstallContext context) {
        try{
            String orgId = userInfo.getOrganizationId().subString(0,15);
            Blob encodeBlob = blob.valueof(orgId);
            String seedKey = EncodingUtil.base64Encode(encodeBlob);
            TOOL_SeedAppSettingHandler.onSeedInstall(seedKey, UserInfo.getUserEmail(), isManual);
        }
        catch(Exception e) {
            System.debug('Error in PostPackageInstall ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
    global void manualInstall() {
        isManual = true;
        InstallContext context = null;
        onInstall(context);
    }
}