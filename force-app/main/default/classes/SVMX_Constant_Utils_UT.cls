/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData = true)
private class SVMX_Constant_Utils_UT {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        SVMXC__Site__c  location = new SVMXC__Site__c(Name = 'MG Road',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Email__c = 'testEmail@test.com');
                
        insert location;     
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();        
        team.Name = 'OS Installation';
        team.Street__c = '2629 firma lane';
        team.City__c='east meadow';
        team.State__c='ny';
        team.Zip__c='11554';
        team.Country__c='United States';
        team.SVMXC__Group_Type__c ='Internal';
        team.SVMXC__Active__c=true;
        insert team;
        
      SVMXC__Service_Group_Members__c technicion = new SVMXC__Service_Group_Members__c(SVMXC__Salesforce_User__c = userinfo.getUserId(),
          SVMXC__Inventory_Location__c = location.id,
          SVMXC__Service_Group__c = team.id);
      insert technicion;
      map<String,String> mapConstants = new map<String,String>(); 
      mapConstants.put('Available','Available');
    String whereClause = 'SVMXC__Status__c=Available AND SVMXC__Location__c= SVMX.USERTRUNK AND SVMXC__Location__c = SVMX.CURRENTUSER';
    SVMX_Constant_Utils.getInstance();
    SVMX_Constant_Utils utils = new SVMX_Constant_Utils();
    utils.getSVMXCurrentUserId();
    utils.getSVMXCurrentUserName();
    utils.getSVMXUserTrunkId();
    utils.getSVMXUserTrunkName();
    utils.getUserTimezoneOffset();
    utils.replaceConstants(whereClause, mapConstants);    
    }
    static testMethod void myUnitTestConst() {
		SVMX_Constants svmxConst = new SVMX_Constants();
		svmxConst.getAdvLookupHdrDef();
		svmxConst.getSFWWizard();
		svmxConst.getSFWWizardActions();
		svmxConst.getSFWWizardCustomActions();
		svmxConst.getSFWWizardSyncOverride();
		svmxConst.getLinkedProHdrDef();
		svmxConst.getSFMDocTemplateDef();
		svmxConst.getSFMDocTemplateDtlDef();
		svmxConst.getAttachmentDef();
		svmxConst.getSourceUpdate();
		svmxConst.getSFMWizardLayout();
		svmxConst.getSFWWizardCustomActionParams();
		
	}
}