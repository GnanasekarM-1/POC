@isTest
private with sharing class SFM_GetFieldAvailableValues_UT 
{
    static testMethod void SFM_GetFieldAvailableValuesUnitTest()
    {
        /*//--------------------------Creating List of StringMap
        List<SFM_WrapperDef.SFM_StringMap> StringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap Stringmapcls1 = new SFM_WrapperDef.SFM_StringMap('RECORDID','');
        SFM_WrapperDef.SFM_StringMap Stringmapcls2 = new SFM_WrapperDef.SFM_StringMap('PAGEID','');
        SFM_WrapperDef.SFM_StringMap Stringmapcls3 = new SFM_WrapperDef.SFM_StringMap('PROCESSID','');
        StringMap.add(Stringmapcls1);
        StringMap.add(Stringmapcls2);
        StringMap.add(Stringmapcls3);
        System.assertEquals(true, StringMap != null);
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();*/
        SFM_GetFieldAvailableValues fieldavail = new SFM_GetFieldAvailableValues();
        System.assertEquals(true, fieldavail!= null);
        /*fieldavail.getAvailableValues(request);
        System.assertEquals(true, fieldavail.getAvailableValues(request)!= null);*/
    }

}