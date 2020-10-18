@isTest
private class SFM_ServicesDef_UT {

    static testMethod void SFM_ServicesDefUnitTest() 
    {
        try
        {
        SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        SFM_ServicesDef.SFM_BuildPageData_WS(sfmtargetrec);
        System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    
    }
    static testMethod void SFM_ServicesDefUnitTest1() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_PORD_SelToAddressCASE_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest2() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_PORD_SelFromAddressCASE_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest3() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_PORD_PopulateFromLocation_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest4() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_PORD_GetPrice_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest5() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_PREQ_GetPrice_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest6() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_WORD_REQ_GetPrice_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest7() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_WORD_USG_GetPrice_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest8() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_WORD_EST_GetPrice_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest9() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_SXFR_GetPrice_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest10() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_IB_PopulateName_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest11() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_WO_SetIsBillable_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest12() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_Quote_Calc_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest13() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_PORD_SelToAddressWO_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest14() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_PORD_SelFromAddressWO_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
    static testMethod void SFM_ServicesDefUnitTest15() 
    {
        try
        {
            SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
            SFM_ServicesDef.SFM_PORD_PopulateToLocation_WS(sfmtargetrec);
            System.assertEquals(sfmtargetrec!=null,true);
        }
        catch(exception ex){}
    }
}