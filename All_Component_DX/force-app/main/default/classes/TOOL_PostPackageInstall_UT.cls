@isTest
public class TOOL_PostPackageInstall_UT {
    
    public static testMethod void onInstall() {
        InstallContext context = null;
        TOOL_PostPackageInstall postInstall = new TOOL_PostPackageInstall();
        postInstall.onInstall(context); 
    }
    
    public static testMethod void manualInstall() {
        TOOL_PostPackageInstall postInstall = new TOOL_PostPackageInstall();
        postInstall.manualInstall();
    }        
}