@isTest
Private with sharing class  SFM_BuildSobjectFromKeyValue_UT
{
    static testMethod void SFM_BuildSobjectFromKeyValue_UT_Test1()
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
        WorkDatial.SVMXC__End_Date_and_Time__c = datetime.newInstance(2011, 12, 1, 12, 30, 2);
        WorkDatial.SVMXC__Date_Received__c = date.newinstance(2010,12,17);
        WorkDatial.SVMXC__Is_Billable__c = true;
        WorkDatial.SVMXC__Received_Quantity2__c = 30;
        insert WorkDatial;
        System.assertEquals(true, WorkDatial != null);

        String ObjName1 ='SVMXC__Service_Order__c';
        String ObjNameLine1 ='SVMXC__Service_Order_Line__c';
        String RecId1= WorkOrderData.Id;
        String RecLineId1= WorkDatial.Id;
                        
        //..........Instance of Class.............//
        SFM_BuildSobjectFromKeyValue  BuildSobj_Keyvalue= new SFM_BuildSobjectFromKeyValue();
        //Key value pair of workorder
        SFM_WrapperDef.SFM_StringMap Stringmap1 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Priority__c','High');  
        SFM_WrapperDef.SFM_StringMap Stringmap2 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Order_Type__c','Open'); 
        SFM_WrapperDef.SFM_StringMap Stringmap3 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Group_Email__c','abc@xyz.com'); 
        SFM_WrapperDef.SFM_StringMap Stringmap4 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Longitude__c','123.02'); 
        SFM_WrapperDef.SFM_StringMap Stringmap5 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Actual_Initial_Response__c','2011-08-30 00:00:00'); 
        SFM_WrapperDef.SFM_StringMap Stringmap6 = new SFM_WrapperDef.SFM_StringMap('SVMXC__PM_Tasks_Created__c','TRUE'); 
        SFM_WrapperDef.SFM_StringMap Stringmap7 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Scheduled_Date__c','2011-08-30');
 
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringmapLstForHeader = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        stringmapLstForHeader.add(Stringmap1);
        stringmapLstForHeader.add(Stringmap2);
        stringmapLstForHeader.add(Stringmap3);
        stringmapLstForHeader.add(Stringmap4);
        stringmapLstForHeader.add(Stringmap5);
        stringmapLstForHeader.add(Stringmap6);
        stringmapLstForHeader.add(Stringmap7);

        //Key value pair of Workdetail
        SFM_WrapperDef.SFM_StringMap Stringmap10 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Service_Order__c',WorkDatial.Id);
        SFM_WrapperDef.SFM_StringMap Stringmap11= new SFM_WrapperDef.SFM_StringMap('SVMXC__Activity_Type__c','Service'); 
        SFM_WrapperDef.SFM_StringMap Stringmap12= new SFM_WrapperDef.SFM_StringMap('SVMXC__Received_State__c','Karnataka');
        //SFM_WrapperDef.SFM_StringMap Stringmap15= new SFM_WrapperDef.SFM_StringMap('SVMXC__Discount__c','30'); 
        SFM_WrapperDef.SFM_StringMap Stringmap16= new SFM_WrapperDef.SFM_StringMap('SVMXC__End_Date_and_Time__c','2011-08-30 00:00:00');
        SFM_WrapperDef.SFM_StringMap Stringmap17= new SFM_WrapperDef.SFM_StringMap('SVMXC__Date_Received__c','2011-08-30');
        SFM_WrapperDef.SFM_StringMap Stringmap18= new SFM_WrapperDef.SFM_StringMap('SVMXC__Is_Billable__c','true');
        SFM_WrapperDef.SFM_StringMap Stringmap19= new SFM_WrapperDef.SFM_StringMap('SVMXC__Received_Quantity2__c','30');  
        //SFM_WrapperDef.SFM_StringMap Stringmap13= new SFM_WrapperDef.SFM_StringMap('ID',WorkDatial.Id);
        SFM_WrapperDef.SFM_StringMap Stringmap14= new SFM_WrapperDef.SFM_StringMap('ID',WorkOrderData.Id);
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringmapLstForDetail = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        stringmapLstForDetail.add(Stringmap10);
        stringmapLstForDetail.add(Stringmap11);
        stringmapLstForDetail.add(Stringmap12);
        //stringmapLstForDetail.add(Stringmap13);
        stringmapLstForHeader.add(Stringmap14);
        //stringmapLstForDetail.add(Stringmap15);
        stringmapLstForDetail.add(Stringmap16);
        stringmapLstForDetail.add(Stringmap17);
        stringmapLstForDetail.add(Stringmap18);
        stringmapLstForDetail.add(Stringmap19);
        
        map<String,SObjectType> allObjs = new map<String,SObjectType>();
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        Map<String,Schema.SObjectField> objfieldMap1 = new Map<String,Schema.SObjectField>();
        Map<String,Schema.SObjectField> objfieldMap2 = new Map<String,Schema.SObjectField>();
        Map<String,Schema.SObjectField> objfieldMap3 = new Map<String,Schema.SObjectField>(); 
        map <string, Map<String,Schema.SObjectField>> mMapFieldList = new map<string, Map<String,Schema.SObjectField>> ();
        
        objfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        objfieldMap2 = Schema.SObjectType.SVMXC__Service_Order_Line__c.fields.getMap();
        for(string str : objfieldMap.keyset())
        {
            objfieldMap1.put(objfieldMap.get(str).getdescribe().getName(),objfieldMap.get(str));
        }
        mMapFieldList.put('SVMXC__Service_Order__c', objfieldMap1);
        for(string str : objfieldMap2.keyset())
        {
            objfieldMap3.put(objfieldMap2.get(str).getdescribe().getName(),objfieldMap2.get(str));
        }
        mMapFieldList.put('SVMXC__Service_Order_Line__c', objfieldMap3);
        
        
              
        List<SFM_WrapperDef.SFM_Record> SfmRecList1 = new List<SFM_WrapperDef.SFM_Record>();
        SFM_WrapperDef.SFM_Record SfmRec1 = new SFM_WrapperDef.SFM_Record();
        SfmRec1.sourceRecordId = WorkOrderData.id;
        SfmRec1.targetRecordId = WorkDatial.id;
        SfmRec1.targetRecordAsKeyValue = stringmapLstForDetail;
        SfmRecList1.add(SfmRec1);
        
        String ObjName ='SVMXC__Service_Order_Line__c';
        String RecId= WorkOrderData.Id;
        String ParentColumnName= 'SVMXC__Service_Order__c';
        String HdrObjId= WorkOrderData.Id;

        //............Call Methods..............//
        
            BuildSobj_Keyvalue.BuildSobjectFromKeyValue(stringmapLstForHeader,'SVMXC__Service_Order__c','',String.valueof(WorkOrderData.id));
            BuildSobj_Keyvalue.BuildSobjectFromKeyValue2(SfmRecList1,'SVMXC__Service_Order_Line__c','SVMXC__Service_Order__c',String.valueof(WorkOrderData.id),mMapFieldList);
            BuildSobj_Keyvalue.BuildSobjectFromKeyValue2(SfmRecList1,'SVMXC__Service_Order_Line__c','',String.valueof(WorkOrderData.id),mMapFieldList);
            
            stringmapLstForHeader.remove(stringmapLstForHeader.size()-1);
            BuildSobj_Keyvalue.BuildSobjectFromKeyValue(stringmapLstForHeader,'SVMXC__Service_Order__c','',String.valueof(WorkOrderData.id));
            
             List<SFM_WrapperDef.SFM_Record> SfmRecList11 = new List<SFM_WrapperDef.SFM_Record>();
            SFM_WrapperDef.SFM_Record SfmRec11 = new SFM_WrapperDef.SFM_Record();
            SfmRec11.sourceRecordId = WorkOrderData.id;
            SfmRec11.targetRecordAsKeyValue = stringmapLstForDetail;
            SfmRecList11.add(SfmRec11);
             BuildSobj_Keyvalue.BuildSobjectFromKeyValue2(SfmRecList11,'SVMXC__Service_Order_Line__c','SVMXC__Service_Order__c',String.valueof(WorkOrderData.id),mMapFieldList);
    }
    static testMethod void SFM_BuildSobjectFromKeyValue_UT_Test2()
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
        WorkDatial.SVMXC__End_Date_and_Time__c = datetime.newInstance(2011, 12, 1, 12, 30, 2);
        WorkDatial.SVMXC__Date_Received__c = date.newinstance(2010,12,17);
        WorkDatial.SVMXC__Is_Billable__c = true;
        WorkDatial.SVMXC__Received_Quantity2__c = 30;
        insert WorkDatial;
        System.assertEquals(true, WorkDatial != null);
                        
        //..........Instance of Class.............//
        SFM_BuildSobjectFromKeyValue  BuildSobj_Keyvalue= new SFM_BuildSobjectFromKeyValue();

        Sobject objHeader = new SVMXC__Service_Order__c();
        objHeader.put('SVMXC__Priority__c','High'); 
        objHeader.put('SVMXC__Order_Type__c','Open'); 
        objHeader.put('SVMXC__Group_Email__c','abc@xyz.com');
        objHeader.put('SVMXC__Longitude__c',123.02); 
        objHeader.put('SVMXC__Actual_Initial_Response__c',datetime.newInstance(2011, 12, 1, 12, 30, 2)); 
        objHeader.put('SVMXC__PM_Tasks_Created__c',TRUE); 
        objHeader.put('SVMXC__Scheduled_Date__c',date.newinstance(2010,12,17));
        objHeader.put('SVMXC__Driving_Time__c',123);
        objHeader.put('SVMXC__Proforma_Invoice_Amount__c',123.0);

        Sobject objDetail = new SVMXC__Service_Order_Line__c();
        objDetail.put('SVMXC__Service_Order__c',WorkDatial.Id);
        objDetail.put('SVMXC__Activity_Type__c','Service'); 
        objDetail.put('SVMXC__Received_State__c','Karnataka');
        objDetail.put('SVMXC__End_Date_and_Time__c',datetime.newInstance(2011, 12, 1, 12, 30, 2));
        objDetail.put('SVMXC__Date_Received__c',date.newinstance(2010,12,17));
        objDetail.put('SVMXC__Is_Billable__c',true);
        objDetail.put('SVMXC__Received_Quantity2__c',30);
        objDetail.put('SVMXC__Actual_Price2__c',30.0);
        objDetail.put('SVMXC__Dead_Time__c',30);
        
        map<String,SObjectType> allObjs = new map<String,SObjectType>();
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        Map<String,Schema.SObjectField> objfieldMap1 = new Map<String,Schema.SObjectField>();
        Map<String,Schema.SObjectField> objfieldMap2 = new Map<String,Schema.SObjectField>();
        Map<String,Schema.SObjectField> objfieldMap3 = new Map<String,Schema.SObjectField>(); 
        map <string, Map<String,Schema.SObjectField>> mMapFieldList = new map<string, Map<String,Schema.SObjectField>> ();
        
        objfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        objfieldMap2 = Schema.SObjectType.SVMXC__Service_Order_Line__c.fields.getMap();
        for(string str : objfieldMap.keyset())
        {
            objfieldMap1.put(objfieldMap.get(str).getdescribe().getName(),objfieldMap.get(str));
        }
        mMapFieldList.put('SVMXC__Service_Order__c', objfieldMap1);
        for(string str : objfieldMap2.keyset())
        {
            objfieldMap3.put(objfieldMap2.get(str).getdescribe().getName(),objfieldMap2.get(str));
        }
        mMapFieldList.put('SVMXC__Service_Order_Line__c', objfieldMap3);
        
        List<SFM_WrapperDef.SFM_Record> SfmRecList1 = new List<SFM_WrapperDef.SFM_Record>();
        SFM_WrapperDef.SFM_Record SfmRec1 = new SFM_WrapperDef.SFM_Record();
        SfmRec1.sourceRecordId = WorkOrderData.id;
        SfmRec1.targetRecordId = WorkDatial.id;
        SfmRec1.sObjectRecord = objDetail;
        SfmRecList1.add(SfmRec1);

        //............Call Methods..............//
        BuildSobj_Keyvalue.BuildSobjectFromGivenSobjectForHeader(objHeader.getPopulatedFieldsAsMap(), 'SVMXC__Service_Order__c', null);
        insert objHeader;
        BuildSobj_Keyvalue.BuildSobjectFromGivenSobjectForHeader(objHeader.getPopulatedFieldsAsMap(), 'SVMXC__Service_Order__c', null);
        
        BuildSobj_Keyvalue.BuildSobjectFromGivenSobjectForDetail(SfmRecList1, 'SVMXC__Service_Order_Line__c', 'SVMXC__Service_Order__c', String.valueof(WorkOrderData.id), mMapFieldList);
        BuildSobj_Keyvalue.BuildSobjectFromGivenSobjectForDetail(SfmRecList1, 'SVMXC__Service_Order_Line__c', '',String.valueof(WorkOrderData.id), mMapFieldList);
        
        List<SFM_WrapperDef.SFM_Record> SfmRecList11 = new List<SFM_WrapperDef.SFM_Record>();
        SFM_WrapperDef.SFM_Record SfmRec11 = new SFM_WrapperDef.SFM_Record();
        SfmRec11.sourceRecordId = WorkOrderData.id;
        SfmRec11.sObjectRecord = objDetail;
        SfmRecList11.add(SfmRec11);
        BuildSobj_Keyvalue.BuildSobjectFromGivenSobjectForDetail(SfmRecList11,'SVMXC__Service_Order_Line__c','SVMXC__Service_Order__c',String.valueof(WorkOrderData.id),mMapFieldList);
    }
        /*static testMethod void SFM_BuildSobjectFromKeyValue_UT_Test2()
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
        String ObjNameLine1 ='SVMXC__Service_Order_Line__c';
        String RecId1= WorkOrderData.Id;
        String RecLineId1= WorkDatial.Id;
                        
        //..........Instance of Class.............//
        SFM_BuildSobjectFromKeyValue  BuildSobj_Keyvalue= new SFM_BuildSobjectFromKeyValue();
        //Key value pair of workorder
        SFM_WrapperDef.SFM_StringMap Stringmap1 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Priority__c','High');  
        SFM_WrapperDef.SFM_StringMap Stringmap2 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Order_Type__c','Open'); 
        SFM_WrapperDef.SFM_StringMap Stringmap3 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Group_Email__c','abc@xyz.com'); 
        SFM_WrapperDef.SFM_StringMap Stringmap4 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Longitude__c','123.02'); 
        SFM_WrapperDef.SFM_StringMap Stringmap5 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Actual_Initial_Response__c','2011-08-30 00:00:00'); 
        SFM_WrapperDef.SFM_StringMap Stringmap6 = new SFM_WrapperDef.SFM_StringMap('SVMXC__PM_Tasks_Created__c','TRUE'); 
        SFM_WrapperDef.SFM_StringMap Stringmap7= new SFM_WrapperDef.SFM_StringMap('SVMXC__Scheduled_Date__c','2011-08-30'); 
 
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringmapLst= new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        stringmapLst.add(Stringmap1);
        stringmapLst.add(Stringmap2);
        stringmapLst.add(Stringmap3);
        stringmapLst.add(Stringmap4);
        stringmapLst.add(Stringmap5);
        stringmapLst.add(Stringmap6);
        stringmapLst.add(Stringmap7);

        //Key value pair of Workdetail
        SFM_WrapperDef.SFM_StringMap Stringmap10 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Service_Order__c',WorkDatial.Id);
        SFM_WrapperDef.SFM_StringMap Stringmap11= new SFM_WrapperDef.SFM_StringMap('SVMXC__Activity_Type__c','Service'); 
        SFM_WrapperDef.SFM_StringMap Stringmap12= new SFM_WrapperDef.SFM_StringMap('SVMXC__Received_State__c','Karnataka'); 
        SFM_WrapperDef.SFM_StringMap Stringmap13= new SFM_WrapperDef.SFM_StringMap('ID',WorkDatial.Id);
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringmapLst2 = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        stringmapLst2.add(Stringmap10);
        stringmapLst2.add(Stringmap11);
        stringmapLst2.add(Stringmap12);
        stringmapLst.add(Stringmap13);
        System.assertnotEquals(Stringmap10, Stringmap11);
        System.assertnotEquals(Stringmap10, Stringmap12);
        System.assertNotEquals(Stringmap12, Stringmap11);
        map<String,SObjectType> allObjs = new map<String,SObjectType>();
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        Map<String,Schema.SObjectField> objfieldMap1 = new Map<String,Schema.SObjectField>(); 
        map <string, Map<String,Schema.SObjectField>> mMapFieldList = new map<string, Map<String,Schema.SObjectField>> ();
        objfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        for(string str : objfieldMap.keyset())
        {
            objfieldMap1.put(objfieldMap.get(str).getdescribe().getName(),objfieldMap.get(str));
        }
        mMapFieldList.put('SVMXC__Service_Order__c', objfieldMap1);

        /*List<SVMXC.SFM_WrapperDef.SFM_Record> SFMRecordList;
        SVMXC__Installed_Product__c IB3 = new SVMXC__Installed_Product__c();
        IB3.SVMXC__City__c = 'Bangalore';
        IB3.SVMXC__Country__c = 'India';
        IB3.SVMXC__Street__c = 'Cunninghum';
        //IB3.SVMXC__Top_Level__c = IB1.id;
        //IB3.SVMXC__Parent__c = IB2.id;
        insert IB3;
                
        List<SFM_WrapperDef.SFM_StringMap> ListOfStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap Stringmapcls1 = new SFM_WrapperDef.SFM_StringMap('SVMXC__City__c','Bangalore');
        SFM_WrapperDef.SFM_StringMap Stringmapcls2 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Country__c','India');
        SFM_WrapperDef.SFM_StringMap Stringmapcls3 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Street__c','Cunninghum');
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        
              
        List<SFM_WrapperDef.SFM_Record> SfmRecList1 = new List<SFM_WrapperDef.SFM_Record>();
        SFM_WrapperDef.SFM_Record SfmRec1 = new SFM_WrapperDef.SFM_Record();
        SfmRec1.targetRecordId = null;
        SfmRec1.targetRecordAsKeyValue = ListOfStringMap;
        SfmRecList1.add(SfmRec1);
        
        String ObjName ='SVMXC__Service_Order_Line__c';
        String RecId= WorkOrderData.Id;
        String ParentColumnName= 'SVMXC__Service_Order__c';
        String HdrObjId= WorkOrderData.Id;

        //............Call Methods..............//
        try{
            BuildSobj_Keyvalue.BuildSobjectFromKeyValue(stringmapLst,ObjName1,ObjName1,HdrObjId);
            //stringmapLst.add(Stringmap13);
        }
        catch(exception ex)
        {
            try
            {
                BuildSobj_Keyvalue.BuildSobjectFromKeyValue2(SfmRecList1,ObjName1,ObjNameLine1,RecLineId1,mMapFieldList);
            }
            catch(exception e){}
            
        }
        

        //BuildSobj_Keyvalue.BuildSobjectFromKeyValueForInsert(stringmapLst,ObjName,ParentColumnName,HdrObjId);
        }*/
   
}