@isTest(SeeAllData=true)
private class APL_ForwardShipmentEngine_UT 
{
  static testMethod void APL_ForwardShipmentEngineTest() 
  {
    
    SVMXC__Site__c objLoc = new SVMXC__Site__c();
    insert objLoc;
    
    // create Forward shipment process
    List<RecordType> lstRecordTypes = [Select id, Name from RecordType where Name in ('Forward Shipment Process')];
    SVMXC__ServiceMax_Processes__c objFwdShipProc = new SVMXC__ServiceMax_Processes__c();
    objFwdShipProc.RecordTypeId = lstRecordTypes[0].id;
    objFwdShipProc.SVMXC__ProcessID__c = 'TESTCLASS001';
    objFwdShipProc.SVMXC__Name__c = 'TESTCLASS001';
    objFwdShipProc.SVMXC__Email_On_Success__c = 'abc@abc.com';
    objFwdShipProc.SVMXC__Email_On_Error__c = 'abc@abc.com';
    objFwdShipProc.SVMXC__Location__c = objLoc.id;
    insert objFwdShipProc;
    
    
    //now Schedule details
    lstRecordTypes = [Select id, Name from RecordType where Name in ('Schedule')];
    SVMXC__ServiceMax_Config_Data__c objSchedule = new SVMXC__ServiceMax_Config_Data__c();
    objSchedule.SVMXC__Sequence__c = 1;
    objSchedule.SVMXC__Run_At__c = '4:00 PM';
    objSchedule.SVMXC__Schedule_Days__c = Datetime.now().formatGMT('EEEE');
    objSchedule.SVMXC__Dispatch_Process__c = objFwdShipProc.id;
    objSchedule.RecordTypeid = lstRecordTypes[0].id;    
    insert objSchedule;
    
    SVMXC__RMA_Shipment_Order__c objSHipmentOrder = new SVMXC__RMA_Shipment_Order__c();
    insert objSHipmentOrder;
    
    SVMXC__RMA_Shipment_Line__c objSHipmentOrderLine = new SVMXC__RMA_Shipment_Line__c();
    objSHipmentOrderLine.SVMXC__RMA_Shipment_Order__c = objSHipmentOrder.id;
    insert objSHipmentOrderLine;
    
    SVMXC__Route_Card__c objRotCards = new SVMXC__Route_Card__c();
    objRotCards.SVMXC__RMA__c = objSHipmentOrder.id;
    objRotCards.SVMXC__RMA_Line__c = objSHipmentOrderLine.id;
    objRotCards.SVMXC__Current_Stop__c = objLoc.id;
    objRotCards.SVMXC__Next_Stop__c = objLoc.id;
    objRotCards.SVMXC__Route_Type__c = 'Inbound';
    insert objRotCards;
    
    SVMXC__Route_Stop__c objStop = new SVMXC__Route_Stop__c();
    objStop.SVMXC__Record_Card__c = objRotCards.id;
    objStop.SVMXC__Next_Stop__c = objLoc.id;
    objStop.SVMXC__Stop_Location__c = objLoc.id;
    objStop.SVMXC__Delivered__c = true;
    objStop.SVMXC__Shipment_Initiated__c = false;
    insert objStop;
    
    objStop = new SVMXC__Route_Stop__c();
    objStop.SVMXC__Record_Card__c = objRotCards.id;
    objStop.SVMXC__Next_Stop__c = objLoc.id;
    objStop.SVMXC__Stop_Location__c = objLoc.id;
    insert objStop;
    
    DateTime dtCurrTime = Datetime.now().addMinutes(1);
    String strCrnExpr = '0 ' + dtCurrTime.time().minute() + ' ' + dtCurrTime.time().hour() + ' ' + dtCurrTime.day() + ' ' + dtCurrTime.month() + ' ' + ' ? ' + dtCurrTime.year();
    APL_ForwardShipmentEngine objShipRemaining = new APL_ForwardShipmentEngine();
    objShipRemaining.isTestClass = true;
    SchedulableContext sc;
    system.assert(objShipRemaining.execute(sc) == null);    
  }
}