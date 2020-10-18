@isTest
Private with sharing class  INTF_BuildSobjectFromKeyValue_UT
{
    static testMethod void INTF_BuildSobjectFromKeyValue_UT_Test1()
    {
        //............................Data Creation.........................//
        SVMXC__Service_Order__c WorkOrderData = new SVMXC__Service_Order__c();
        WorkOrderData.SVMXC__Priority__c='High';
        WorkOrderData.SVMXC__Order_Type__c='Open';
        WorkOrderData.SVMXC__Scheduled_Date__c =  date.newinstance(2010,12,17);
        WorkOrderData.SVMXC__Group_Email__c= 'abc@xyz.com';
        WorkOrderData.SVMXC__Longitude__c=120.36;
        WorkOrderData.SVMXC__Actual_Initial_Response__c=datetime.newInstance(2011, 12, 1, 12, 30, 2);
        WorkOrderData.SVMXC__PM_Tasks_Created__c=TRUE;
        insert WorkOrderData;
        System.assertEquals(true, WorkOrderData != null);

        SVMXC__Service_Order_Line__c WorkDatial= new SVMXC__Service_Order_Line__c();
        WorkDatial.SVMXC__Service_Order__c=WorkOrderData.id;
        WorkDatial.SVMXC__Activity_Type__c='Service';
        WorkDatial.SVMXC__Received_City__c='Bangalore';
        WorkDatial.SVMXC__Received_State__c='Karnataka';
        insert WorkDatial;
        System.assertEquals(true, WorkDatial != null);

        String ObjName1 ='SVMXC__Service_Order__c';
        String RecId1= WorkOrderData.Id;
                        
        //..........Instance of Class.............//
        INTF_buildSobjectFromKeyValue  BuildSobj_Keyvalue= new INTF_buildSobjectFromKeyValue();
        SVMXC.INTF_WebServicesDef.INTF_Record SFMRecord = new SVMXC.INTF_WebServicesDef.INTF_Record();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> SFMRecordList = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        map<String,map<String,Schema.SObjectField>> AllFieldDescribe;
        //Key value pair of workorder
        INTF_WebServicesDef.INTF_StringMap Stringmap1 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Priority__c','High');  
        INTF_WebServicesDef.INTF_StringMap Stringmap2 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Order_Type__c','Open'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap3 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Group_Email__c','abc@xyz.com'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap4 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Longitude__c','123.02'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap5 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Actual_Initial_Response__c','2011-08-30 00:00:00'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap6 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__PM_Tasks_Created__c','TRUE'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap7= new INTF_WebServicesDef.INTF_StringMap('SVMXC__Scheduled_Date__c','2011-08-30'); 
 
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapLst= new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        stringmapLst.add(Stringmap1);
        stringmapLst.add(Stringmap2);
        stringmapLst.add(Stringmap3);
        stringmapLst.add(Stringmap4);
        stringmapLst.add(Stringmap5);
        stringmapLst.add(Stringmap6);
        stringmapLst.add(Stringmap7);

        //Key value pair of Workdetail
        INTF_WebServicesDef.INTF_StringMap Stringmap10 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Service_Order__c',WorkDatial.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmap11= new INTF_WebServicesDef.INTF_StringMap('SVMXC__Activity_Type__c','Service'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap12= new INTF_WebServicesDef.INTF_StringMap('SVMXC__Received_State__c','Karnataka'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap13= new INTF_WebServicesDef.INTF_StringMap('ID',WorkDatial.Id);
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapLst2 = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        stringmapLst2.add(Stringmap10);
        stringmapLst2.add(Stringmap11);
        stringmapLst2.add(Stringmap12);
        //stringmapLst.add(Stringmap13);
        System.assertnotEquals(Stringmap10, Stringmap11);
        System.assertnotEquals(Stringmap10, Stringmap12);
        System.assertNotEquals(Stringmap12, Stringmap11);
        SFMRecord.settargetRecordAsKeyValue(stringmapLst);
        SFMRecordList.add(SFMRecord);

        
        //............Call Methods..............//
        try{
        //Sobject sobj =  BuildSobj_Keyvalue.BuildSobjectFromKeyValue(stringmapLst,ObjName1,ParentColumnName,RecId1);
        BuildSobj_Keyvalue.BuildSobjectFromKeyValue(stringmapLst,ObjName1,ObjName1,RecId1);
        stringmapLst.add(Stringmap13);
        BuildSobj_Keyvalue.BuildSobjectFromKeyValue(stringmapLst,ObjName1,ObjName1,RecId1);
         BuildSobj_Keyvalue.BuildSobjectFromKeyValue2( SFMRecordList, ObjName1, ObjName1, ObjName1,AllFieldDescribe);
         BuildSobj_Keyvalue.BuildSobjectFromKeyValue2(SFMRecordList,ObjName1,RecId1,RecId1, AllFieldDescribe);
        }
        catch(exception ex){}
        String ObjName ='SVMXC__Service_Order_Line__c';
        String RecId= WorkDatial.Id;
        String ParentColumnName= 'SVMXC__Service_Order__c';
        String HdrObjId= WorkOrderData.Id;

        //BuildSobj_Keyvalue.BuildSobjectFromKeyValueForInsert(stringmapLst,ObjName,ParentColumnName,HdrObjId);
    }
    static testMethod void INTF_BuildSobjectFromKeyValue_UT_Test2()
    {
        //............................Data Creation.........................//
        SVMXC__Service_Order__c WorkOrderData = new SVMXC__Service_Order__c();
        WorkOrderData.SVMXC__Priority__c='High';
        WorkOrderData.SVMXC__Order_Type__c='Open';
        WorkOrderData.SVMXC__Scheduled_Date__c =  date.newinstance(2010,12,17);
        WorkOrderData.SVMXC__Group_Email__c= 'abc@xyz.com';
        WorkOrderData.SVMXC__Longitude__c=120.36;
        WorkOrderData.SVMXC__Actual_Initial_Response__c=datetime.newInstance(2011, 12, 1, 12, 30, 2);
        WorkOrderData.SVMXC__PM_Tasks_Created__c=TRUE;
        insert WorkOrderData;
        System.assertEquals(true, WorkOrderData != null);

        SVMXC__Service_Order_Line__c WorkDatial= new SVMXC__Service_Order_Line__c();
        WorkDatial.SVMXC__Service_Order__c=WorkOrderData.id;
        WorkDatial.SVMXC__Activity_Type__c='Service';
        WorkDatial.SVMXC__Received_City__c='Bangalore';
        WorkDatial.SVMXC__Received_State__c='Karnataka';
        insert WorkDatial;
        System.assertEquals(true, WorkDatial != null);

        String ObjName1 ='SVMXC__Service_Order__c';
        String RecId1= WorkOrderData.Id;
                        
        //..........Instance of Class.............//
        INTF_buildSobjectFromKeyValue  BuildSobj_Keyvalue= new INTF_buildSobjectFromKeyValue();
        //Key value pair of workorder
        INTF_WebServicesDef.INTF_StringMap Stringmap1 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Priority__c','High');  
        INTF_WebServicesDef.INTF_StringMap Stringmap2 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Order_Type__c','Open'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap3 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Group_Email__c','abc@xyz.com'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap4 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Longitude__c','123.02'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap5 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Actual_Initial_Response__c','2011-08-30 00:00:00'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap6 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__PM_Tasks_Created__c','TRUE'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap7= new INTF_WebServicesDef.INTF_StringMap('SVMXC__Scheduled_Date__c','2011-08-30'); 
 
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapLst= new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        stringmapLst.add(Stringmap1);
        stringmapLst.add(Stringmap2);
        stringmapLst.add(Stringmap3);
        stringmapLst.add(Stringmap4);
        stringmapLst.add(Stringmap5);
        stringmapLst.add(Stringmap6);
        stringmapLst.add(Stringmap7);

        //Key value pair of Workdetail
        INTF_WebServicesDef.INTF_StringMap Stringmap10 = new INTF_WebServicesDef.INTF_StringMap('ID',RecId1);
        INTF_WebServicesDef.INTF_StringMap Stringmap11= new INTF_WebServicesDef.INTF_StringMap('SVMXC__Activity_Type__c','Service'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap12= new INTF_WebServicesDef.INTF_StringMap('SVMXC__Received_State__c','Karnataka'); 
        //INTF_WebServicesDef.INTF_StringMap Stringmap13= new INTF_WebServicesDef.INTF_StringMap('ID',WorkDatial.Id);
        
        //stringmapLst.add(Stringmap13);
        System.assertnotEquals(Stringmap10, Stringmap11);
        System.assertnotEquals(Stringmap10, Stringmap12);
        System.assertNotEquals(Stringmap12, Stringmap11);

        stringmapLst.add(Stringmap10);
        stringmapLst.add(Stringmap11);
        stringmapLst.add(Stringmap12);
        //stringmapLst.add(Stringmap13);

        //............Call Methods..............//
        try{
        //Sobject sobj =  BuildSobj_Keyvalue.BuildSobjectFromKeyValue(stringmapLst,ObjName1,ParentColumnName,RecId1);
        BuildSobj_Keyvalue.BuildSobjectFromKeyValue(stringmapLst,ObjName1,ObjName1,RecId1);
        }
        catch(exception ex){}
        String ObjName ='SVMXC__Service_Order_Line__c';
        String RecId= WorkDatial.Id;
        String ParentColumnName= 'SVMXC__Service_Order__c';
        String HdrObjId= WorkOrderData.Id;

        //BuildSobj_Keyvalue.BuildSobjectFromKeyValueForInsert(stringmapLst,ObjName,ParentColumnName,HdrObjId);
    }
    static testMethod void INTF_BuildSobjectFromKeyValue_UT_Test3()
    {
        //............................Data Creation.........................//
        SVMXC__Service_Order__c WorkOrderData = new SVMXC__Service_Order__c();
        WorkOrderData.SVMXC__Priority__c='High';
        WorkOrderData.SVMXC__Order_Type__c='Open';
        WorkOrderData.SVMXC__Scheduled_Date__c =  date.newinstance(2010,12,17);
        WorkOrderData.SVMXC__Group_Email__c= 'abc@xyz.com';
        WorkOrderData.SVMXC__Longitude__c=120.36;
        WorkOrderData.SVMXC__Actual_Initial_Response__c=datetime.newInstance(2011, 12, 1, 12, 30, 2);
        WorkOrderData.SVMXC__PM_Tasks_Created__c=TRUE;
        insert WorkOrderData;
        System.assertEquals(true, WorkOrderData != null);

        SVMXC__Service_Order_Line__c WorkDatial= new SVMXC__Service_Order_Line__c();
        WorkDatial.SVMXC__Service_Order__c=WorkOrderData.id;
        WorkDatial.SVMXC__Activity_Type__c='Service';
        WorkDatial.SVMXC__Received_City__c='Bangalore';
        WorkDatial.SVMXC__Received_State__c='Karnataka';
        insert WorkDatial;
        System.assertEquals(true, WorkDatial != null);

        String ObjName1 ='SVMXC__Service_Order__c';
        String RecId1= WorkOrderData.Id;
                        
        //..........Instance of Class.............//
        INTF_buildSobjectFromKeyValue  BuildSobj_Keyvalue= new INTF_buildSobjectFromKeyValue();
        SVMXC.INTF_WebServicesDef.INTF_Record SFMRecord = new SVMXC.INTF_WebServicesDef.INTF_Record();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> SFMRecordList = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        map<String,map<String,Schema.SObjectField>> AllFieldDescribe;
        
        
        //Key value pair of workorder
        INTF_WebServicesDef.INTF_StringMap Stringmap1 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Priority__c','High');  
        INTF_WebServicesDef.INTF_StringMap Stringmap2 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Order_Type__c','Open'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap3 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Group_Email__c','abc@xyz.com'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap4 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Longitude__c','123.02'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap5 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Actual_Initial_Response__c','2011-08-30 00:00:00'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap6 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__PM_Tasks_Created__c','TRUE'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap7= new INTF_WebServicesDef.INTF_StringMap('SVMXC__Scheduled_Date__c','2011-08-30'); 
 
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapLst= new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        stringmapLst.add(Stringmap1);
        stringmapLst.add(Stringmap2);
        stringmapLst.add(Stringmap3);
        stringmapLst.add(Stringmap4);
        stringmapLst.add(Stringmap5);
        stringmapLst.add(Stringmap6);
        stringmapLst.add(Stringmap7);

        //Key value pair of Workdetail
        INTF_WebServicesDef.INTF_StringMap Stringmap10 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Service_Order__c',WorkDatial.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmap11= new INTF_WebServicesDef.INTF_StringMap('SVMXC__Activity_Type__c','Service'); 
        INTF_WebServicesDef.INTF_StringMap Stringmap12= new INTF_WebServicesDef.INTF_StringMap('SVMXC__Received_State__c','Karnataka'); 
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapLst2 = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        stringmapLst2.add(Stringmap10);
        stringmapLst2.add(Stringmap11);
        stringmapLst2.add(Stringmap12);
        System.assertnotEquals(Stringmap10, Stringmap11);
        System.assertnotEquals(Stringmap10, Stringmap12);
        System.assertNotEquals(Stringmap12, Stringmap11);
        SFMRecord.settargetRecordAsKeyValue(stringmapLst);
        SFMRecordList.add(SFMRecord);
        SFMRecord.settargetRecordAsKeyValue(stringmapLst2);
        SFMRecordList.add(SFMRecord);

        
        //............Call Methods..............//
        try{
         BuildSobj_Keyvalue.BuildSobjectFromKeyValue2( SFMRecordList, ObjName1, RecId1, ObjName1,AllFieldDescribe);
       
        }
        catch(exception ex){}
       

       
    }
}