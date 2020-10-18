/* Unit test class for SVMX_LauncHelp Controller*/
@istest
private class SVMX_LaunchHelp_UT {
  /*This tests launching of HELP URL specific to user language. */
    static testmethod void getURL_TestMethod(){
        test.startTest();
        SVMXC.SVMX_LaunchHelp launchHelp = new SVMXC.SVMX_LaunchHelp();
        PageReference redirectURL = launchHelp.getHelpURL();   
        System.assertEquals(System.Label.HELPSC1_HLPURL,redirectURL.getUrl());
        test.stopTest();
    }
}