/**
 * @description This class implements unit test scenario for SFMDeliveryServiceBase.
 
 * @author      Ramachandra Mohan
 * @date        06 Jun 2015
 */
@isTest
private class SFMDeliveryServiceBase_UT {

    class Derived extends SFMDeliveryServiceBase {
        Derived() {
        }
    }
    
    static testMethod void invokeMethod() {

        Test.startTest();
        
        SFMDeliveryServiceBase base = new Derived();
               
        SVMXRestMethodInfo info = new SVMXRestMethodInfo();
        info.MethodName = 'Missing';
        base.invokeMethod( info );
        
        info.MethodName = 'getPageLayout';
        base.invokeMethod( info );
        
        info.MethodName = 'getPageLayoutOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'getPageLayoutOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'getPageData';
        base.invokeMethod( info );
        
        info.MethodName = 'getPageDataOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'getPageDataOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'retrieveDisplayTags';
        base.invokeMethod( info );
        
        info.MethodName = 'retrieveDisplayTagsOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'retrieveDisplayTagsOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'retrieveSettings';
        base.invokeMethod( info );
        
        info.MethodName = 'retrieveSettingsOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'retrieveSettingsOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'getUserInfo';
        base.invokeMethod( info );
        
        info.MethodName = 'getUserInfoOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'getUserInfoOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'getLookupConfig';
        base.invokeMethod( info );
        
        info.MethodName = 'getLookupConfigOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'getLookupConfigOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'saveTarget';
        base.invokeMethod( info );
        
        info.MethodName = 'saveTargetOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'saveTargetOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'getNextStepInfo';
        base.invokeMethod( info );
        
        info.MethodName = 'getNextStepInfoOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'getNextStepInfoOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'getSnippetForEvent';
        base.invokeMethod( info );
        
        info.MethodName = 'getSnippetForEventOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'getSnippetForEventOldest';
        base.invokeMethod( info );
		
        info.MethodName = 'addRecords';
        base.invokeMethod( info );
        
        info.MethodName = 'addRecordsOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'addRecordsOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'getBubbleData';
        base.invokeMethod( info );
        
        info.MethodName = 'getBubbleDataOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'getBubbleDataOldest';
        base.invokeMethod( info );
		
        info.MethodName = 'getObjectDescription';
        base.invokeMethod( info );
        
        info.MethodName = 'getObjectDescriptionOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'getObjectDescriptionOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'getRecordTypes';
        base.invokeMethod( info );
        
        info.MethodName = 'getRecordTypesOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'getRecordTypesOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'getLayoutDescription';
        base.invokeMethod( info );
        
        info.MethodName = 'getLayoutDescriptionOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'getLayoutDescriptionOldest';
        base.invokeMethod( info );
        
        info.MethodName = 'getLookupData';
        base.invokeMethod( info );
        
        info.MethodName = 'getLookupDataOlder';
        base.invokeMethod( info );
        
        info.MethodName = 'getLookupDataOldest';
        base.invokeMethod( info );
        
        try {
            SFMDeliveryServiceIntf.doGet();
        } catch (Exception ex){}
        
        try {
            SFMDeliveryServiceIntf.doPost();
        } catch (Exception ex){}
        
        Test.stopTest();
    }
}