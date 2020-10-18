@isTest
private with sharing class INTF_GetPrice_UT
{
    static testMethod void INTF_GetPriceUnitTest()
    {
        /*-----------------------------------------DATA CREATION-------------------------------------------------*/
        
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('GLOB001_GBL014','EVER007_SET001','IPRD003_SET007','IPRD003_SET003', 'EVER007_SET002')];
        
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
        {
            l.SVMXC__Display_Value__c = 'false';
            l.SVMXC__Internal_Value__c = 'false';
        }
        if(lst != null && lst.size() > 0)
        update lst;
        //---------------------------------Creating RecordTypeList-----------------------------------------
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
        
        //---------------------------------Creating the process object-------------------------------------
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        processNodes.RecordTypeId = TargetManager;
        processNodes.SVMXC__Name__c = 'process11';
        processNodes.SVMXC__Description__c = 'newprocess1';
        processNodes.SVMXC__ProcessID__c = 'process21';
        processNodes.SVMXC__IsStandard__c = true;
        insert processNodes;
        System.assertEquals(true, processNodes != null);
        
        //-----------------------------------------------------------------------------------------------------------------------------------------------------------
        //------------------------------------------------FOR PARTS ORDER---------------------------------------------------------------------------------------------
        //-----------------------------------------------------------------------------------------------------------------------------------------------------------
        
        Product2  prod = new Product2();
        prod.name = 'prod1';
        prod.Isactive = true;
        insert prod;
        
        SVMXC__RMA_Shipment_Order__c PartsOrder = new SVMXC__RMA_Shipment_Order__c();
        ////PartsOrder.CurrencyIsoCode = 'USD';
        PartsOrder.SVMXC__Order_Status__c = 'Open';
        insert PartsOrder;
        
        SVMXC__RMA_Shipment_Line__c POLine = new SVMXC__RMA_Shipment_Line__c();
        POLine.SVMXC__Line_Price2__c = 15000.10;
        POLine.SVMXC__Use_Price_From_Pricebook__c = true;
        POLine.SVMXC__Product__c = prod.id;
        POLine.SVMXC__Line_Status__c = 'Open';
        POLine.SVMXC__RMA_Shipment_Order__c = PartsOrder.id;
        insert POLine;
        
         //----------------------Creating List of StringMap for Header Target Record---------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls1 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Source_City__c','Bangalore');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls2 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Source_Country__c','India');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls3 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Source_Street__c','Cunninghum');
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        
         //----------------------Creating List of StringMap for Detail Target Record(For Update)----------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap1 = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls4 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Billing_Type__c','Paid');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls5 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Address_Type__c','Account Billing Address');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls6 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Source_Country__c','India');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls7 = new INTF_WebServicesDef.INTF_StringMap('Id',string.valueof(POLine.id));
        ListOfStringMap1.add(Stringmapcls4);
        ListOfStringMap1.add(Stringmapcls5);
        ListOfStringMap1.add(Stringmapcls6);
        ListOfStringMap1.add(Stringmapcls7);
        
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap2 = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls8 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__RMA_Shipment_Order__c',String.valueof(PartsOrder.Id));
        INTF_WebServicesDef.INTF_StringMap Stringmapcls9 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Billing_Type__c','Paid');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls10 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Address_Type__c','Account Billing Address');
        ListOfStringMap2.add(Stringmapcls8);
        ListOfStringMap2.add(Stringmapcls9);
        ListOfStringMap2.add(Stringmapcls10);
        
         //Create case for source record update
        Case c = new Case();
        c.Origin = 'Email';
        c.Priority = 'High';
        c.SVMXC__SLA_Clock_Pause_Days__c = 1;
        insert c;
        System.assertEquals(true, c != null);
        
        //-------------------------------Creating List of Work Order Object---------------------------------
        List<SVMXC__RMA_Shipment_Order__c> POList = new List<SVMXC__RMA_Shipment_Order__c>();
        SVMXC__RMA_Shipment_Order__c PO1 = new SVMXC__RMA_Shipment_Order__c();
        SVMXC__RMA_Shipment_Order__c PO2 = new SVMXC__RMA_Shipment_Order__c();
        POList.add(PO1);
        POList.add(PO2);
        insert POList;
        System.assertEquals(true, POList != null);
        
        //----------------Creating String List to pass to the method of Header TargetRecObj-------------------
        List<String> strLst1 = new List<String>();
        String str1 = PO1.Id;
        String str2 = PO2.Id;
        strLst1.add(str1);
        strLst1.add(str2);
        
        //---------------------Creating String List to pass to the method of DtlTargetRecordObject------------
        List<String> strLst2 = new List<String>();
        String str3 = POLine.Id;
        strLst2.add(str3);
        
        //-----------------------------Creating List of INTF_Record for Header TargetRecObj----------------------------
        List<INTF_WebServicesDef.INTF_Record> SfmRecList1 = new List<INTF_WebServicesDef.INTF_Record>();
        INTF_WebServicesDef.INTF_Record SfmRec1 = new INTF_WebServicesDef.INTF_Record();
        SfmRec1.sourceRecordId = c.id;
        SfmRec1.targetRecordAsKeyValue = ListOfStringMap;
        SfmRecList1.add(SfmRec1);
        
        //-------------------------Creating List of INTF_Record for DtlTargetRecordObject(for update)-------------------------
        List<INTF_WebServicesDef.INTF_Record> SfmRecList2 = new List<INTF_WebServicesDef.INTF_Record>();
        INTF_WebServicesDef.INTF_Record SfmRec2 = new INTF_WebServicesDef.INTF_Record();
        SfmRec2.sourceRecordId = '';
        SfmRec2.targetRecordAsKeyValue = ListOfStringMap1;
        SfmRecList2.add(SfmRec2);
        
        //-------------------------Creating List of INTF_Record for DtlTargetRecordObject(for insert)-------------------------
        INTF_WebServicesDef.INTF_Record SfmRec3 = new INTF_WebServicesDef.INTF_Record();
        SfmRec3.sourceRecordId = '';
        SfmRec3.targetRecordAsKeyValue = ListOfStringMap2;
        SfmRecList2.add(SfmRec3);
        
        //-------------------------------Creating Header Target Record Object-------------------------------------
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject TargetRecObj = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        TargetRecObj.objName = 'SVMXC__RMA_Shipment_Order__c';
        TargetRecObj.deleteRecID = strLst1;
        TargetRecObj.records =  SfmRecList1;
        
        //---------------------------Creating List of Detail Target Record-------------------------------------
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject TargetRecObj1 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        TargetRecObj1.objName = 'SVMXC__RMA_Shipment_Line__c';
        TargetRecObj1.deleteRecID = strLst2;
        TargetRecObj1.parentColumnName = 'SVMXC__RMA_Shipment_Order__c';
        TargetRecObj1.AliasName = 'TestAliasName';
        TargetRecObj1.records =  SfmRecList2;
        DtlTargetRecordObject.add(TargetRecObj1);
        
        //---------------------------------Creating Target Record Object---------------------------------------
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        sfmtargetrec.sfmProcessId = processNodes.Id;
        sfmtargetrec.headerRecord = TargetRecObj;
        sfmtargetrec.detailRecords = DtlTargetRecordObject;
        
        //-----------------------------------------------------------------------------------------------------------------------------------------------------------
        //------------------------------------------------FOR WORK ORDER---------------------------------------------------------------------------------------------
        //-----------------------------------------------------------------------------------------------------------------------------------------------------------
        
        //-------------------------------Creating List of Work Order Object---------------------------------
        List<SVMXC__Service_Order__c> WOList = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c();
        SVMXC__Service_Order__c WO2 = new SVMXC__Service_Order__c();
        WOList.add(WO1);
        WOList.add(WO2);
        insert WOList;
        System.assertEquals(true, WOList != null);
        
        //----------------Creating String List to pass to the method of Header TargetRecObj-------------------
        List<String> strLst3 = new List<String>();
        String str4 = WO1.Id;
        String str5 = WO2.Id;
        strLst3.add(str4);
        strLst3.add(str5);
        
        SVMXC__Service_Order__c WOrder = new SVMXC__Service_Order__c();
        WOrder.SVMXC__City__c = 'Bangalore';
        WOrder.SVMXC__Country__c = 'India';
        WOrder.SVMXC__Street__c = 'Cunninghum';
        ////WOrder.CurrencyIsoCode = 'USD';
        WOrder.SVMXC__Product__c = prod.id;
        insert WOrder;
        System.assertEquals(true, WOrder != null);
         
        //--------------Creating Work Detail Object to pass to the method of DtlTargetRecordObject-----------
        SVMXC__Service_Order_Line__c WOLine = new SVMXC__Service_Order_Line__c();
        WOLine.SVMXC__Service_Order__c = WOrder.Id;
        WOLine.SVMXC__Select__c = true;
        WOLine.SVMXC__Product__c = prod.id;
        
        insert WOLine;
        System.assertEquals(true, WOLine != null);
        
        //-----------------------Creating Work Detail Object to pass to the method of Record------------------
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c();
        WOLine1.SVMXC__Service_Order__c = WOrder.Id;
        WOLine1.SVMXC__Select__c = true;
        WOLine1.SVMXC__Use_Price_From_Pricebook__c = true;
        WOLine1.SVMXC__Actual_Price2__c = 1500.20;
        insert WOLine1;
        System.assertEquals(true, WOLine1 != null);
        
        //---------------------Creating String List to pass to the method of DtlTargetRecordObject------------
        List<String> strLst4 = new List<String>();
        String str6 = WOLine.Id;
        strLst4.add(str6);
        
        //----------------------Creating List of StringMap for Header Target Record---------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap3 = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls11 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__City__c','Bangalore');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls12 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Country__c','India');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls13 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Street__c','Cunninghum');
        ListOfStringMap3.add(Stringmapcls11);
        ListOfStringMap3.add(Stringmapcls12);
        ListOfStringMap3.add(Stringmapcls13);
        
        //----------------------Creating List of StringMap for Detail Target Record(For Update)----------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap4 = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls14 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Activity_Type__c','Installation');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls15 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Cost_Category__c','Straight');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls16 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Received_Country__c','India');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls17 = new INTF_WebServicesDef.INTF_StringMap('Id',string.valueof(WOLine1.id));
        ListOfStringMap4.add(Stringmapcls14);
        ListOfStringMap4.add(Stringmapcls15);
        ListOfStringMap4.add(Stringmapcls16);
        ListOfStringMap4.add(Stringmapcls17);
        
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap5 = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls18 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Service_Order__c',String.valueof(WOrder.Id));
        INTF_WebServicesDef.INTF_StringMap Stringmapcls19 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Activity_Type__c','Installation');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls20 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Cost_Category__c','Straight');
        ListOfStringMap5.add(Stringmapcls18);
        ListOfStringMap5.add(Stringmapcls19);
        ListOfStringMap5.add(Stringmapcls20);
        
        //-----------------------------Creating List of INTF_Record for Header TargetRecObj----------------------------
        List<INTF_WebServicesDef.INTF_Record> SfmRecList3 = new List<INTF_WebServicesDef.INTF_Record>();
        INTF_WebServicesDef.INTF_Record SfmRec4 = new INTF_WebServicesDef.INTF_Record();
        SfmRec4.sourceRecordId = c.id;
        SfmRec4.targetRecordAsKeyValue = ListOfStringMap3;
        SfmRecList3.add(SfmRec4);
        //-------------------------Creating List of INTF_Record for DtlTargetRecordObject(for update)-------------------------
        List<INTF_WebServicesDef.INTF_Record> SfmRecList4 = new List<INTF_WebServicesDef.INTF_Record>();
        INTF_WebServicesDef.INTF_Record SfmRec5 = new INTF_WebServicesDef.INTF_Record();
        SfmRec5.sourceRecordId = '';
        SfmRec5.targetRecordAsKeyValue = ListOfStringMap4;
        SfmRecList4.add(SfmRec5);
        
        //-------------------------Creating List of INTF_Record for DtlTargetRecordObject(for insert)-------------------------
        INTF_WebServicesDef.INTF_Record SfmRec6 = new INTF_WebServicesDef.INTF_Record();
        SfmRec6.sourceRecordId = '';
        SfmRec6.targetRecordAsKeyValue = ListOfStringMap5;
        SfmRecList4.add(SfmRec6);
        
        //-------------------------------Creating Header Target Record Object-------------------------------------
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject TargetRecObj2 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        TargetRecObj2.objName = 'SVMXC__Service_Order__c';
        TargetRecObj2.deleteRecID = strLst3;
        TargetRecObj2.records =  SfmRecList3;
        
        //---------------------------Creating List of Detail Target Record-------------------------------------
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject1 = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject TargetRecObj3 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        TargetRecObj3.objName = 'SVMXC__Service_Order_Line__c';
        TargetRecObj3.aliasName = 'WorkDetailLine';
        TargetRecObj3.deleteRecID = strLst4;
        TargetRecObj3.parentColumnName = 'SVMXC__Service_Order__c';
        TargetRecObj3.records =  SfmRecList4;
        DtlTargetRecordObject1.add(TargetRecObj3);
        
        
        //---------------------------------Creating Target Record Object---------------------------------------
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec1 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        sfmtargetrec1.sfmProcessId = processNodes.Id;
        sfmtargetrec1.headerRecord = TargetRecObj2;
        sfmtargetrec1.detailRecords = DtlTargetRecordObject1;
        //.............................................................................................................................................................
        //.............................................................................................................................................................
        //.............................................................................................................................................................
        
        
        Pricebook2 PriceBook = new Pricebook2();
        String CurrencyIsoCode;
        set<String> ProductId = new set<String>();
        
        INTF_GetPrice getprice = new INTF_GetPrice();
        getprice.INTF_PORD_GetPrice(sfmtargetrec);
        getprice.INTF_PREQ_GetPrice(sfmtargetrec);
        getprice.INTF_WORD_REQ_GetPrice(sfmtargetrec1);
        getprice.INTF_WORD_USG_GetPrice(sfmtargetrec1);
        getprice.INTF_WORD_EST_GetPrice(sfmtargetrec);
        getprice.INTF_SXFR_GetPrice(sfmtargetrec1);
        getprice.GetUntiPriceFromPricebook(PriceBook,CurrencyIsoCode,ProductId);
        getprice.GetPrice(sfmtargetrec,'','SET003','SVMXC__Product__c','SVMXC__Use_Price_From_Pricebook__c','SVMXC__Unit_Price2__c','CurrencyIsoCode',null);
    }
}