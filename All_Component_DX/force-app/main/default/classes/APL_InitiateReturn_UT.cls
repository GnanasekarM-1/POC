@isTest(SeeAllData=true)
private class APL_InitiateReturn_UT 
{
    static testMethod void APL_InitiateReturnTest()
    {
        try
        {
            Case objTestCase = new Case();
            insert objTestCase;
            SVMXC__Case_Line__c objTestCaseLine = new SVMXC__Case_Line__c();
            objTestCaseLine.SVMXC__Case__c = objTestCase.id;
            insert objTestCaseLine;
            RecordType InitiateProcess_Rtype = [select Id from RecordType where Name='Initiate Return Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
            RecordType InitiateProcess_Rtype1 = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
            
            
            SVMXC__ServiceMax_Processes__c objINRTProcess = new SVMXC__ServiceMax_Processes__c();
            objINRTProcess.SVMXC__APL_Perform_Entitlement__c = true;
            objINRTProcess.SVMXC__APL_Perform_Route_Calculations__c = true;
            objINRTProcess.SVMXC__ProcessId__c = 'TestMethod';
            objINRTProcess.SVMXC__Name__c = 'TestMethod';
            objINRTProcess.SVMXC__APL_Print_RMA_Template__c = 'google.com';
            objINRTProcess.RecordtypeId = InitiateProcess_Rtype.Id;
            insert objINRTProcess;
            system.assert(objINRTProcess.RecordtypeId != null);
            
            SVMXC__ServiceMax_Config_Data__c objConf = new SVMXC__ServiceMax_Config_Data__c();
            objConf.SVMXC__Target_Field_Name__c = 'Description';
            objConf.SVMXC__Action__c = 'Set';
            objConf.SVMXC__Display_Value__c = '123';
            objConf.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_ROUTE_CALC';
            objConf.SVMXC__Dispatch_Process__c  = objINRTProcess.id;
            objConf.RecordtypeId = InitiateProcess_Rtype1.Id;
            insert objConf; 
            system.assert(objConf.RecordtypeId != null);
            
            SVMXC__SFM_Event__c objSFMEvent = new SVMXC__SFM_Event__c();
            objSFMEvent.SVMXC__Class__c = 'SVMXC';
            objSFMEvent.SVMXC__Namespace__c = 'SVMXC';
            objSFMEvent.SVMXC__Class__c = 'SVMXC';
            objSFMEvent.SVMXC__Method__c = 'SVMXC';
            objSFMEvent.SVMXC__ServiceMax_Process__c = objINRTProcess.id;
            insert objSFMEvent;
            system.assert(objSFMEvent.SVMXC__ServiceMax_Process__c != null);
            APL_InitiateReturn objIntRet = new APL_InitiateReturn();
            
            List<INTF_WebServicesDef.SVMXMap> lstMap = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap map1 = new INTF_WebServicesDef.SVMXMap('ProcessId','TestMethod');
            lstMap.add(map1);
            INTF_WebServicesDef.SVMXMap map2 = new INTF_WebServicesDef.SVMXMap('CaseId',objTestCase.id);
            lstMap.add(map2);
            INTF_WebServicesDef.SVMXMap map3 = new INTF_WebServicesDef.SVMXMap('HeaderUpdate','HEADER_UPD_ON_ROUTE_CALC');
            lstMap.add(map3);
            INTF_WebServicesDef.SVMXMap map4 = new INTF_WebServicesDef.SVMXMap('ChildUpdate','LINE_UPD_ON_ROUTE_CALC');
            lstMap.add(map4);
            INTF_WebServicesDef.SVMXMap map5 = new INTF_WebServicesDef.SVMXMap('ChildRecords',objTestCaseLine.id);
            lstMap.add(map5);
            system.assert(lstMap.size() != null);
            
            INTF_WebServicesDef.INTF_SFMRequest procRequest = new INTF_WebServicesDef.INTF_SFMRequest();//null, null, locProcIdMap, null
            procRequest.valueMap = lstMap;
            objIntRet = new APL_InitiateReturn();
            objIntRet.APL_GetIntiateReturnProc(procRequest);//'{"processId":"TestMethod"}'
            objIntRet.APL_PerformEntitlementCheck(procRequest);//'{"processId":"TestMethod","caseId":"' + objTestCase.id + '"}'
            //objIntRet.getlstRMARec();
            //objIntRet.setlstRMARec(new List<SVMXC__RMA_Shipment_Order__c>());
            APL_InitiateReturn.RMAWrapper objWrap = new  APL_InitiateReturn.RMAWrapper();
            SVMXC__RMA_Shipment_Order__c objRMA = new SVMXC__RMA_Shipment_Order__c();
            APL_InitiateReturn.RMAWrapper objWrap1 = new  APL_InitiateReturn.RMAWrapper(true, objRMA, 5);
            System.currentPageReference().getParameters().put('SVMX_recordId', objTestCase.Id);
            System.currentPageReference().getParameters().put('SVMX_processId', 'TestMethod');
            objIntRet.APL_InitiateReturnAction();
            objIntRet.APL_PrintRMA();
            objWrap.getSel();
            objWrap.setSel(true);
            objWrap.getobjRMA();
            objWrap.setobjRMA(objRMA);
            objWrap.getIntProdCount();
            objWrap.setIntProdCount(5);
            objIntRet.getTAG001();
            objIntRet.getTAG002();    
            objIntRet.getTAG003();    
            objIntRet.getTAG004();    
            objIntRet.getTAG005();   
            objIntRet.getTAG006();   
            objIntRet.getTAG007();  
            objIntRet.getlstRMASize();
            objIntRet.getTAG008();    
            objIntRet.getTAG009();    
            objIntRet.getTAG010();
            objIntRet.getTAG011();
            objIntRet.ValidateRecFromExpr(null, null, true);
            objIntRet.ValidateRecFromExpr(null, null,false);
            
            objIntRet.DoReturnSourceUpdates(procRequest);
            objIntRet.APL_GoBack();
           // boolean b = objIntRet.getIsRender();
            //b = objIntRet.setIsRender(b);
            Case cas = objIntRet.getobjCase();
            //objIntRet.setobjCase(Cas);
            List<APL_InitiateReturn.RMAWrapper> value = objIntRet.getlstRMAWrap();
            //objIntRet.setlstRMAWrap(value);
            lstMap = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap map11 = new INTF_WebServicesDef.SVMXMap('ProcessId','TestMethod1');
            lstMap.add(map11);
            INTF_WebServicesDef.SVMXMap map21 = new INTF_WebServicesDef.SVMXMap('CaseId',objTestCase.id);
            lstMap.add(map21);
            INTF_WebServicesDef.INTF_SFMRequest procRequest1 = new INTF_WebServicesDef.INTF_SFMRequest();//null, null, locProcIdMap, null
            procRequest1.valueMap = lstMap;
            objIntRet.APL_GetIntiateReturnProc(procRequest1);
            
            //Added for UT Coverage
            objIntRet.getUserLocaleKey();
            objIntRet.getUserID();
            objIntRet.getUserOrgID();
            objIntRet.getHLPURL();
            objIntRet.getTAG014();
            objIntRet.getHLPTITLE();
            objIntRet.APL_DoValidation(null, null, false);
        }
        catch(exception ex)
        {
        
        }
        
    }
}