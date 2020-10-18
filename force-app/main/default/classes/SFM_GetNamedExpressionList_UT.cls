@isTest(SeeAllData=true)
private class SFM_GetNamedExpressionList_UT
{
    static testMethod void SFM_getNamedExpressionList_Test()
    {
    //-----------------DATA PREPARATION PART----------------------------------------------------------------------------//
        // Putttin one record into SVMXC__ServiceMax_Processes__c Object where Record type is 'OBJECT MAPPING'
           List<RecordType> lstRecType  = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
           
           
            SVMXC__ServiceMax_Processes__c process_Obj = new SVMXC__ServiceMax_Processes__c(RecordTypeId =lstRecType[0].Id,SVMXC__Name__c='NamedExpression001',SVMXC__Rule_Type__c = 'Named Expression',SVMXC__SettingId__c='expid001',SVMXC__Description__c='desc0001' ,SVMXC__Advance_Expression__c='advanceExpressoin', SVMXC__Source_Object_Name__c='SVMXC__Site__c');
            process_Obj.SVMXC__ProcessID__c='PROCESS11';
            process_Obj.SVMXC__SettingId__c = 'PROCESS11';
            process_Obj.SVMXC__MapID__c='PROCESS11';
            process_Obj.SVMXC__Name__c = 'PROCESS22';
            
             insert process_Obj;// We should use Test.startTest and Test.stopTest method
       // test.starttest();
       System.assertEquals(true, process_Obj != null);
       
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj1 = new SFM_WrapperDef.SFM_StringMap();
        wrapper_strMapObj1.key = 'OBJECTNAME' ;
        wrapper_strMapObj1.value = process_Obj.SVMXC__Source_Object_Name__c ;
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj1 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj1.add(wrapper_strMapObj1);
        SFM_WrapperDef.SFM_Request ExpReq1 = new SFM_WrapperDef.SFM_Request();
        ExpReq1.setstringMap(wrapperList_strMapObj1);
        
        
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj2 = new SFM_WrapperDef.SFM_StringMap();
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj3 = new SFM_WrapperDef.SFM_StringMap();
        wrapper_strMapObj2.key = 'OBJECTNAME' ;
        wrapper_strMapObj2.value = process_Obj.SVMXC__Source_Object_Name__c ;
         wrapper_strMapObj3.key = 'EXPRESSIONID' ;
        wrapper_strMapObj3.value = process_Obj.SVMXC__SettingId__c ;
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj2 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj2.add(wrapper_strMapObj2);
        wrapperList_strMapObj2.add(wrapper_strMapObj3);
        SFM_WrapperDef.SFM_Request ExpReq2 = new SFM_WrapperDef.SFM_Request();
        ExpReq2.setstringMap(wrapperList_strMapObj2);
        System.assertEquals(true, process_Obj != null);
        System.assertNotEquals(wrapper_strMapObj2, wrapper_strMapObj3);
        
        //INSTANTIATING THE CLASS
        SFM_getNamedExpressionList objnamedexprList_Obj = new SFM_getNamedExpressionList();
        
        //CALLING THE METHODS
        SFM_WrapperDef.SFM_Response wrapper_resObj1= objnamedexprList_Obj.SFM_getAllObjectNamedExpressionList(ExpReq1);
        SFM_WrapperDef.SFM_Response wrapper_resObj2= SFM_WebServicesDef.SFM_getCustomActionList_WS(ExpReq1);
        SFM_WrapperDef.SFM_Response_Expression wrapper_resExpObj2= objnamedexprList_Obj.SFM_getNamedExpressionList(ExpReq2);
       // test.stoptest();
    }//method
}//class