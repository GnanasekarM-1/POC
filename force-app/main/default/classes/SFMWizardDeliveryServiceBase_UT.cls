@isTest
private class SFMWizardDeliveryServiceBase_UT {

    class Derived extends SFMWizardDeliveryServiceBase{
        Derived() {
            try {
                super(null,null);
            }   catch( Exception ex ) {}         
        }
    }
    
    static testMethod void testSFM_GetFieldUpdateRuleIds() {
        
        Test.startTest();
        
		SVMXRestMethodInfo info = new SVMXRestMethodInfo();        
        SFMWizardDeliveryServiceBase base = new Derived();
        
        info.MethodName = 'getWizardInfo';
        base.invokeMethod(info);
        
        info.MethodName = 'getWizardInfoOlder';
        base.invokeMethod(info);
        
        info.MethodName = 'getWizardInfoOldest';
        base.invokeMethod(info);
        
        info.MethodName = '';
        base.invokeMethod(info);
        
        try {
        	SFMWizardDeliveryServiceIntf.doPost();    
        } catch( Exception ex ) {}
        
        SFMWizardDeliveryServiceImpl impl = new SFMWizardDeliveryServiceImpl();
        try {
        	impl.getWizardInfo();
        } catch( Exception ex ) {}
        
        try {
        	impl.getWizardInfoInternal( new SFMWizardDeliveryServiceImpl.WizardInfoRequest() );
        } catch( Exception ex ) {}
                        
        Test.stopTest();
    }
}