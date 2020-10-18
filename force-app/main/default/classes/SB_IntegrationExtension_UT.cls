@isTest
public class SB_IntegrationExtension_UT
{
    static testMethod void getServiceBoardSettings(){
        SB_IntegrationExtension ext = new SB_IntegrationExtension();
        ext.getServiceBoardSettings();
    }
    
    static testMethod void getSBSettings(){
        SB_IntegrationExtension ext = new SB_IntegrationExtension();
        ext.getSBSettings(new Set<String>{'IPAD018'});
    }
}