@isTest(SeeAllData=true)
private class INTF_PORDAddress_UT {

    static testMethod void myUnitTest() {
        SVMXC.INTF_PORDAddress gtPordAddress = new SVMXC.INTF_PORDAddress();
        
        
        SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c ();
        ib.SVMXC__Street__c = 'Street';
        ib.SVMXC__City__c = 'City';
        ib.SVMXC__State__c = 'State';
        ib.SVMXC__Zip__c = 'Zip';
        ib.SVMXC__Country__c = 'Country';
        insert ib;
        System.assertEquals(true, ib != null);
        
        String ObjName ='SVMXC__Service_Order_Line__c';
        Account acc = new Account();
        acc.Name = 'Company';
        acc.BillingStreet = 'Street';
        acc.BillingCity= 'city';
        acc.BillingState = 'State';
        acc.BillingPostalCode = '60065';
        acc.BillingCountry = 'Country';
        
        insert acc;
        System.assertEquals(true, acc != null);
        
        
        Case cas = new Case();
        cas.Account = acc;
        cas.SVMXC__Component__c = ib.id;
        insert cas;
        System.assertEquals(true, cas != null);
        
        SVMXC__RMA_Shipment_Order__c svoSObj = new SVMXC__RMA_Shipment_Order__c();  
        svoSObj.SVMXC__Address_Type__c = 'Account Billing Address';
        svoSObj.SVMXC__Company__c = acc.id;
        insert svoSObj;
        System.assertEquals(true, svoSObj != null);
        
        INTF_WebServicesDef.INTF_StringMap Stringmapadd1 = new INTF_WebServicesDef.INTF_StringMap('ADDRESSTYPE','TOADDRESS');
        INTF_WebServicesDef.INTF_StringMap Stringmapadd2= new INTF_WebServicesDef.INTF_StringMap('IBID',ib.id);
        
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapLst= new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        stringmapLst.add(Stringmapadd1);
        stringmapLst.add(Stringmapadd2);
        
        SVMXC.INTF_getAddress gtAddress = new SVMXC.INTF_getAddress();
        gtAddress.getAddress(svoSObj, stringmapLst);
        
        SVMXC__Service_Order__c WorkOrder = new SVMXC__Service_Order__c();
        WorkOrder.SVMXC__Priority__c='High';
        WorkOrder.SVMXC__Order_Type__c='Open';
        WorkOrder.SVMXC__Scheduled_Date__c =  date.newinstance(2010,12,17);
        WorkOrder.SVMXC__Group_Email__c= 'abc@xyz.com';
        WorkOrder.SVMXC__Longitude__c=120.36;
        WorkOrder.SVMXC__Actual_Initial_Response__c=datetime.newInstance(2011, 12, 1, 12, 30, 2);
        WorkOrder.SVMXC__PM_Tasks_Created__c=TRUE;
        WorkOrder.SVMXC__Component__c = ib.Id;
        insert WorkOrder;
        System.assertEquals(true, WorkOrder != null);
        
        List<INTF_WebServicesDef.INTF_StringMap> List_StringMap = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmap1 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Priority__c','High');  
        INTF_WebServicesDef.INTF_StringMap Stringmap2 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Company__c',acc.id); 
        INTF_WebServicesDef.INTF_StringMap Stringmap3 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Source_City__c','Chennai'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap4 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Warehouse__c','123.02');
        INTF_WebServicesDef.INTF_StringMap Stringmap5= new INTF_WebServicesDef.INTF_StringMap('SVMXC__Service_Order__c',WorkOrder.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmap6= new INTF_WebServicesDef.INTF_StringMap('SVMXC__Case__c',cas.Id);
        List_StringMap.add(Stringmap1);
        List_StringMap.add(Stringmap2);
        List_StringMap.add(Stringmap3);
        List_StringMap.add(Stringmap4);
        List_StringMap.add(Stringmap5);
        List_StringMap.add(Stringmap6);
        
        List<String> list_string = new List<String>();
        list_string.add(ib.id);
        
        
        
        List<INTF_WebServicesDef.INTF_Record> list_rec = new List<INTF_WebServicesDef.INTF_Record>();
        INTF_WebServicesDef.INTF_Record SfmRec = new INTF_WebServicesDef.INTF_Record();
        SfmRec.sourceRecordId = ib.id;
        SfmRec.targetRecordAsKeyValue = List_StringMap;
        list_rec.add(SfmRec);
        
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject TargetRecObj = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        TargetRecObj.objName = 'SVMXC__RMA_Shipment_Order__c';
        TargetRecObj.deleteRecID = list_string;
        TargetRecObj.records =  list_rec;
       
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> list_TargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
        list_TargetRecordObject.add(TargetRecObj);
        
        
        
        list<RecordType> RecordTypeList = new list<RecordType>();
        RecordTypeList = [Select SobjectType, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        System.assertEquals(true, RecordTypeList != null);
        
        String FldmappingId = '';
        String ProcessNodeobj = '';
        String TargetManager = '';
        if(RecordTypeList.size() > 0)
        {
            for(RecordType R : RecordTypeList)
            {
                if(R.Name == 'Field Mapping')
                    FldmappingId = R.id;
                if(R.Name == 'Process Node Objects')
                    ProcessNodeobj = R.id;
                if(R.Name == 'Target Manager')
                    TargetManager = R.id;       
            }
        }
        
        
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        processNodes.RecordTypeId = TargetManager;
        processNodes.SVMXC__Name__c = 'SVMXC__Name__c';
        processNodes.SVMXC__Description__c = 'SVMXC__Description__c';
        processNodes.SVMXC__ProcessID__c = 'SVMXC__ProcessID__c';
        processNodes.SVMXC__IsStandard__c = true;
        insert processNodes;
        System.assertEquals(true, processNodes != null);

        
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        sfmtargetrec.sfmProcessId = processNodes.Id;
        sfmtargetrec.headerRecord = TargetRecObj;
        sfmtargetrec.detailRecords = list_TargetRecordObject ;
        
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        
        
        gtPordAddress.getSelFromAddressWO(sfmtargetrec);
        gtPordAddress.getSelToAddressWO(sfmtargetrec);
        gtPordAddress.getSelFromAddressCase(sfmtargetrec);
        gtPordAddress.getSelToAddressCase(sfmtargetrec);
        gtPordAddress.getPopulateToLocation(sfmtargetrec);
        gtPordAddress.getPopulateFromLocation(sfmtargetrec);
        gtPordAddress.getPopulateToLocation_RMA(sfmtargetrec);
        gtPordAddress.getPopulateFromLocation_Shipment(sfmtargetrec);
    }
    }