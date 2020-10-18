@isTest(SeeAllData=true)
private class SFM_GetGlobalObjectList_UT
{
    static testMethod void SFM_getGlobalObjectList_Test()
    {     
        //----------------------------DATA PREPARATION FOR METHOD ONE AND  TWO CALLING THAT METHOD----------------------------------------//
        SFM_WrapperDef.SFM_StringMap wrapper_stringMapObj1 = new SFM_WrapperDef.SFM_StringMap();
        wrapper_stringMapObj1.key = 'OBJECTTYPE' ;
        wrapper_stringMapObj1.value = 'SOURCE' ;
        SFM_WrapperDef.SFM_StringMap wrapper_stringMapObj11 = new SFM_WrapperDef.SFM_StringMap();
        wrapper_stringMapObj11.key = 'OBJECTNAME' ;
        wrapper_stringMapObj11.value = 'SVMXC__Installed_Product__c' ;
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_stringMapObj1 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_stringMapObj1.add(wrapper_stringMapObj1);
        wrapperList_stringMapObj1.add(wrapper_stringMapObj11);
        System.assertNotEquals(wrapper_stringMapObj1, wrapper_stringMapObj11);
        SFM_WrapperDef.SFM_Request prequest1 = new SFM_WrapperDef.SFM_Request();
        prequest1.setstringMap(wrapperList_stringMapObj1);
        SFM_getGlobalObjectList sfm_GlobObjListObj = new SFM_getGlobalObjectList();
        //---------------CALLING METHOD GetParetnObjects(request),GetChildObjects(request)----------------------------------//        
        SFM_WrapperDef.SFM_Response wrapper_resObj1 = sfm_GlobObjListObj.GetParetnObjects(prequest1);
        SFM_WrapperDef.SFM_Response wrapper_resObj11 = sfm_GlobObjListObj.GetChildObjects(prequest1);
        //----------------DATA PREPARATION FOR METHOD ONE AND TWO -----------------------------------------------------------//
        SFM_WrapperDef.SFM_StringMap wrapper_stringMapObj2 = new SFM_WrapperDef.SFM_StringMap();
        wrapper_stringMapObj2.key = 'OBJECTTYPE' ;
        wrapper_stringMapObj2.value = 'TARGET' ;
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_stringMapObj2 = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap wrapper_stringMapObj22 = new SFM_WrapperDef.SFM_StringMap();
        wrapper_stringMapObj22.key = 'OBJECTNAME' ;
        wrapper_stringMapObj22.value = 'SVMXC__Installed_Product__c' ;
        wrapperList_stringMapObj2.add(wrapper_stringMapObj2);
        wrapperList_stringMapObj2.add(wrapper_stringMapObj22);
        System.assertNotEquals(wrapper_stringMapObj2, wrapper_stringMapObj22);
        SFM_WrapperDef.SFM_Request prequest2 = new SFM_WrapperDef.SFM_Request();
        prequest2.setstringMap(wrapperList_stringMapObj2);
        
        //---------------CALLING METHOD GetParetnObjects(request),GetChildObjects(request)----------------------------//
        //SFM_WrapperDef.SFM_Response wrapper_resObj2 = sfm_GlobObjListObj.GetParetnObjects(prequest2);
        SFM_WrapperDef.SFM_Response wrapper_resObj22 = sfm_GlobObjListObj.GetChildObjects(prequest2);
        //----------------------------DATA PREPARATION FOR METHOD ONE AND TWO ----------------------------------------//
        SFM_WrapperDef.SFM_StringMap wrapper_stringMapObj3 = new SFM_WrapperDef.SFM_StringMap();
        wrapper_stringMapObj3.key = 'OBJECTTYPE' ;
        wrapper_stringMapObj3.value = 'SEARCH' ;
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_stringMapObj3 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_stringMapObj3.add(wrapper_stringMapObj3); 
        SFM_WrapperDef.SFM_Request prequest3 = new SFM_WrapperDef.SFM_Request();
        prequest3.setstringMap(wrapperList_stringMapObj3);
        //----------------------CALLING METHOD GetParetnObjects(request),GetParetnObjects(request)----------------------//
        SFM_WrapperDef.SFM_Response wrapper_resObj3 = sfm_GlobObjListObj.GetParetnObjects(prequest3);
        SFM_WrapperDef.SFM_Response wrapper_resObj33 = sfm_GlobObjListObj.GetChildObjects(prequest3);
        //sfm_GlobObjListObj.GetParetnTargetObjects();
        
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_stringMapObj4 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_stringMapObj4.add(new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE', 'AVAILABLE_SOURCE'));
        wrapperList_stringMapObj4.add(new SFM_WrapperDef.SFM_StringMap('Case', 'Case'));
        wrapperList_stringMapObj4.add(new SFM_WrapperDef.SFM_StringMap('SVMXC__Quote__c', 'SVMXC__Quote__c'));
        SFM_WrapperDef.SFM_Request prequest4 = new SFM_WrapperDef.SFM_Request();
        prequest4.setstringMap(wrapperList_stringMapObj4);
        SFM_WrapperDef.SFM_Response wrapper_resObj4 = sfm_GlobObjListObj.GetParetnObjects(prequest4);
        
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_stringMapObj5 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_stringMapObj5.add(new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE', 'AVAILABLE_TARGET'));
        wrapperList_stringMapObj5.add(new SFM_WrapperDef.SFM_StringMap('Case', 'Case'));
        wrapperList_stringMapObj5.add(new SFM_WrapperDef.SFM_StringMap('SVMXC__Quote__c', 'SVMXC__Quote__c'));
        SFM_WrapperDef.SFM_Request prequest5 = new SFM_WrapperDef.SFM_Request();
        prequest5.setstringMap(wrapperList_stringMapObj5);
        SFM_WrapperDef.SFM_Response wrapper_resObj5 = sfm_GlobObjListObj.GetParetnObjects(prequest5);
        
        SFM_WrapperDef.SFM_Response wrapper_resObj6 = sfm_GlobObjListObj.getRelatedObjects('SVMXC__Installed_Product__c');
        
        //----------------------------Code for Smart Object----------------------------------------//
        SFM_WrapperDef.SFM_StringMap stringMapObj1 = new SFM_WrapperDef.SFM_StringMap();
        stringMapObj1.key = 'OBJECTTYPE' ;
        stringMapObj1.value = 'SOURCE' ;
        stringMapObj1.value1 = 'BOTH';
        SFM_WrapperDef.SFM_StringMap stringMapObj11 = new SFM_WrapperDef.SFM_StringMap();
        stringMapObj11.key = 'OBJECTNAME' ;
        stringMapObj11.value = 'SVMXC__Installed_Product__c' ;
        List<SFM_WrapperDef.SFM_StringMap> List_stringMapObj1 = new List<SFM_WrapperDef.SFM_StringMap>();
        List_stringMapObj1.add(stringMapObj1);
        List_stringMapObj1.add(stringMapObj11);
        System.assertNotEquals(stringMapObj1, stringMapObj11);
        SFM_WrapperDef.SFM_Request sfmRrequest1 = new SFM_WrapperDef.SFM_Request();
        sfmRrequest1.setstringMap(List_stringMapObj1);
        SFM_getGlobalObjectList sfm_GlobObjListObj1 = new SFM_getGlobalObjectList();
        SFM_WrapperDef.SFM_Response wrapper_resObj12 = sfm_GlobObjListObj1.GetParetnObjects(sfmRrequest1);
        
        Map<String, SmartObject.DescribeSmartObjectResult> mapSmartObject = SmartObject.getGlobalDescribe();
        List<SFM_WrapperDef.SFM_StringMap> List_stringMapObj4 = new List<SFM_WrapperDef.SFM_StringMap>();
        List_stringMapObj4.add(new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE', 'AVAILABLE_SOURCE'));
        List_stringMapObj4.add(new SFM_WrapperDef.SFM_StringMap('Case', 'Case', 'SFDC_OBJECT'));
        if(mapSmartObject.size()>0){
            for(String s : mapSmartObject.keyset())
                List_stringMapObj4.add(new SFM_WrapperDef.SFM_StringMap(s, s, 'SMART_OBJECT'));
        }
        SFM_WrapperDef.SFM_Request prequest41 = new SFM_WrapperDef.SFM_Request();
        prequest41.setstringMap(List_stringMapObj4);
        SFM_WrapperDef.SFM_Response wrapper_resObj41 = sfm_GlobObjListObj.GetParetnObjects(prequest41);
        //----------------------------Code for Smart Object----------------------------------------//
    }//METHOD       
}//CLASS