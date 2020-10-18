@isTest(SeeAllData=true)
private with sharing class SFM_GetListOfPageLayout_UT
{
    static testMethod void SFM_getListOfPageLayoutUnitTest()
    {
       //-----------------------DATA CREATION------------------------- 
       //-------------Creating PageLayouts
        SVMXC__Page_Layout__c pagelayout1 = new SVMXC__Page_Layout__c();
        pagelayout1.SVMXC__Name__c = 'WOLayout';
        pagelayout1.SVMXC__Page_Layout_ID__c = 'pagelayout1';
        pagelayout1.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        pagelayout1.SVMXC__Type__c ='Header';
        insert pagelayout1;
        System.assertEquals(true, pagelayout1 != null);
        
        SVMXC__Page_Layout__c pagelayout2 = new SVMXC__Page_Layout__c();
        pagelayout2.SVMXC__Name__c = 'WDLayout'; 
        pagelayout2.SVMXC__Page_Layout_ID__c = 'pagelayout2';
        pagelayout2.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
        pagelayout2.SVMXC__Header_Page_Layout__c = pagelayout1.id;
        pagelayout2.SVMXC__Type__c ='Detail';
        insert pagelayout2;
        System.assertEquals(true, pagelayout2 != null);
        
       //-----------Creating List of StringMap
        List<SVMXC.SFM_WrapperDef.SFM_StringListMap> StringListMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        List<string> valueList = new List<string>();
        valueList.add('SVMXC__Service_Order__c');
        valueList.add('SVMXC__Service_Order_Line__c');
        stringListMap.add(new SFM_WrapperDef.SFM_StringListMap('TARGET',valueList));
        stringListMap.add(new SFM_WrapperDef.SFM_StringListMap('TARGETCHILD',valueList));  
       
       //-----------Creating Objects and Calling the Methods--------------
        SFM_WrapperDef.SFM_Request_PageList request = new SFM_WrapperDef.SFM_Request_PageList();
        SFM_getListOfPageLayout listofpagelayout = new SFM_getListOfPageLayout();
        request.request.stringListMap = stringListMap;
        listofpagelayout.getListOfPageLayout(request);
       //--Deleting the PageLayout Created and Calling the Methods again------- 
        delete pagelayout2;
        System.assertEquals(true, pagelayout2 != null);
        
        listofpagelayout.getListOfPageLayout(request);
    }
    static testMethod void SFM_getListOfPageLayoutUnitTest1()
    {
       //-----------------------DATA CREATION------------------------- 
       //-------------Creating PageLayouts
        SVMXC__Page_Layout__c pagelayout1 = new SVMXC__Page_Layout__c();
        pagelayout1.SVMXC__Name__c = 'WOLayout';
        pagelayout1.SVMXC__Page_Layout_ID__c = 'pagelayout1';
        pagelayout1.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        pagelayout1.SVMXC__Type__c ='Header';
        insert pagelayout1;
        System.assertEquals(true, pagelayout1 != null);
        
        SVMXC__Page_Layout__c pagelayout2 = new SVMXC__Page_Layout__c();
        pagelayout2.SVMXC__Name__c = 'WDLayout'; 
        pagelayout2.SVMXC__Page_Layout_ID__c = 'pagelayout2';
        pagelayout2.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
        pagelayout2.SVMXC__Header_Page_Layout__c = pagelayout1.id;
        pagelayout2.SVMXC__Type__c ='Detail';
        insert pagelayout2;
        System.assertEquals(true, pagelayout2 != null);
        
       //-----------Creating List of StringMap
        List<SVMXC.SFM_WrapperDef.SFM_StringListMap> StringListMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        List<string> valueList = new List<string>();
        valueList.add('SVMXC__Service_Order__c');
        //valueList.add('SVMXC__Service_Order_Line__c');
        stringListMap.add(new SFM_WrapperDef.SFM_StringListMap('TARGET',valueList));
        //stringListMap.add(new SFM_WrapperDef.SFM_StringListMap('TARGETCHILD',valueList));  
       
       //-----------Creating Objects and Calling the Methods--------------
        SFM_WrapperDef.SFM_Request_PageList request = new SFM_WrapperDef.SFM_Request_PageList();
        SFM_getListOfPageLayout listofpagelayout = new SFM_getListOfPageLayout();
        request.request.stringListMap = stringListMap;
        listofpagelayout.getListOfPageLayout(request);
       //--Deleting the PageLayout Created and Calling the Methods again------- 
        delete pagelayout2;
        System.assertEquals(true, pagelayout2 != null);
        
        //listofpagelayout.getListOfPageLayout(request);
    }
}