@isTest
private with sharing class SFM_GetRecordTypes_UT
{
    static testMethod void SFM_getRecordTypeUnitTest()
    {  
        //------------------------------------Data Creation--------------------------------
        //-----------Quering the RecordType
        RecordType records = [Select SobjectType, NamespacePrefix, Name, IsActive, Id, DeveloperName, Description From RecordType where IsActive=true][0];
        System.assertEquals(true , records != null );
        
        //Creating SFM_WrapperDef.SFM_Request type object to pass in the method as parameter       
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        //--------------Creating List of StringMap
        SFM_WrapperDef.SFM_StringMap Stringmapcls1 = new SFM_WrapperDef.SFM_StringMap('RECORDID',records.Id);
        SFM_WrapperDef.SFM_StringMap Stringmapcls2 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME',records.SobjectType);
        List<SFM_WrapperDef.SFM_StringMap> ListOfStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        
        System.assertEquals(true , Stringmapcls2 != null );
        System.assertNotEquals(Stringmapcls1 , Stringmapcls2 );

        request.StringMap = ListOfStringMap;
        
        //-------Creating object of SFM_getRecordTypes and calling the methods-----------
        SFM_getRecordTypes recordtype1 = new SFM_getRecordTypes();
        recordtype1.getRecordTypes(request);
     }
}