@isTest(SeeAllData=true)
Private class INVT_SmartEngine_UT
{
   static testMethod void INVT_SmartEngine_UT()
    {
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id, SVMXC__Setting_Unique_ID__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('PORD008_SET007', 'PORD008_SET020', 'PORD008_SET008', 'PORD008_SET012')];
 
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
        {
            if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET007')
                l.SVMXC__Internal_Value__c = 'RMA';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET020')
                l.SVMXC__Internal_Value__c = 'true';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET008')
                l.SVMXC__Internal_Value__c = 'testEmail@servicemax.com';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET012')
                l.SVMXC__Internal_Value__c = 'true';
        }
        upsert  lst;
        
        RecordType shipRType, shipLineRType;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__RMA_Shipment_Order__c' or SobjectType = 'SVMXC__RMA_Shipment_Line__c' or SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        for(RecordType rt : rts){ 
            if(rt.SobjectType == 'SVMXC__RMA_Shipment_Order__c' &&rt.Name == 'Shipment'){
                shipRType = rt;
            } 
            if(rt.SobjectType == 'SVMXC__RMA_Shipment_Line__c' && rt.Name == 'RMA'){
                shipLineRType = rt;
            }
        }
        
        Account  account = new Account(Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
        insert account;
        
        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
          
        Product2 pr1 = new Product2(Name = 'prodPR1',ProductCode='prodPR1',SVMXC__Inherit_Parent_Warranty__c =True, SVMXC__Enable_Serialized_Tracking__c = true,SVMXC__Stockable__c = true );
        insert pr1; 
        
        Case case1 = new Case(Status ='New', Priority = 'Medium',Origin = 'Email',ContactId =contact.Id,AccountId=account.Id, SVMXC__Product__c = pr1.id); 
        insert case1; 
         
        list<SVMXC__Site__c> lstLocation = new list<SVMXC__Site__c>();
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'loc1',SVMXC__Stocking_Location__c = true,SVMXC__Account__c = account.Id,SVMXC__Street__c = 'millers road',SVMXC__Country__c = 'india',SVMXC__Zip__c = '123456', SVMXC__Email__c = 'testEmail@servicemax.com');
        lstLocation.add(location1);
         
        SVMXC__Site__c location2 = new SVMXC__Site__c(Name = 'loc2',SVMXC__Stocking_Location__c = true,SVMXC__Account__c = account.Id,SVMXC__Street__c = 'millers road',SVMXC__Country__c = 'india',SVMXC__Zip__c = '123456', SVMXC__Email__c = 'testEmail@servicemax.com');
        lstLocation.add(location2);
        insert lstLocation;
        
        SVMXC__Parts_Request__c partRequest = new SVMXC__Parts_Request__c(SVMXC__Requested_From__c = location1.id, SVMXC__Required_At_Location__c = location2.id);
        insert partRequest;
        
        SVMXC__Parts_Request_Line__c partRequestLine = new SVMXC__Parts_Request_Line__c (SVMXC__Parts_Request__c = partRequest.id);
        insert partRequestLine;
        
        SVMXC__RMA_Shipment_Order__c PartsOrder = new SVMXC__RMA_Shipment_Order__c(RecordTypeId =shipRType.Id,SVMXC__Company__c = account.Id,SVMXC__Contact__c = contact.Id, SVMXC__Case__c = case1.id, SVMXC__Order_Status__c = 'open',SVMXC__Expected_Delivery_Date__c = system.today(), SVMXC__Source_Location__c = location1.Id,SVMXC__Destination_Location__c = location2.id);
        insert PartsOrder;
        
        SVMXC__RMA_Shipment_Line__c pline1 = new SVMXC__RMA_Shipment_Line__c(RecordTypeId = shipLineRType.Id, SVMXC__RMA_Shipment_Order__c = PartsOrder.id,SVMXC__Product__c = pr1.id,SVMXC__Actual_Quantity2__c=15,SVMXC__Expected_Quantity2__c = 1,SVMXC__Line_Status__c = 'open', SVMXC__Ship_Location__c = location1.Id , SVMXC__Delivery_Location__c = location2.id, SVMXC__Parts_Request_Line__c = partRequestLine.id);
        insert pline1;
        
        list<SVMXC__Product_Stock__c> lstPStock = new list<SVMXC__Product_Stock__c>();
        SVMXC__Product_Stock__c proStock = new SVMXC__Product_Stock__c();
        proStock.SVMXC__Status__c = 'Available';
        proStock.SVMXC__Product__c = pr1.id;
        proStock.SVMXC__Location__c = location1.Id;
        lstPStock.add(proStock);
        
        SVMXC__Product_Stock__c proStock1 = new SVMXC__Product_Stock__c();
        proStock1.SVMXC__Status__c = 'In Transit';
        proStock1.SVMXC__Product__c = pr1.id;
        proStock1.SVMXC__Location__c = location2.Id;
        lstPStock.add(proStock1);
        insert lstPStock;
        
        SVMXC__Product_Serial__c proSerial = new SVMXC__Product_Serial__c();
        proSerial.SVMXC__Product__c = pr1.id;
        proSerial.SVMXC__Product_Stock__c = proStock.id;
        proSerial.SVMXC__Active__c = true;
        proSerial.Name = 'pSerial1';
        insert proSerial;
    
        PageReference pageRef = new PageReference('Page.SVMXC.INVT_SmartEngine');
        pageRef.getParameters().put('hdrId',PartsOrder.id);
        pageRef.getParameters().put('SMId','PORD008');
        pageRef.getParameters().put('LineId',pline1.id);
        Test.setCurrentPageReference(pageRef); 
        
        SVMXC.INVT_SmartEngine smartobject1 = new SVMXC.INVT_SmartEngine();
        
        String [] fromSerial = new String[]{'pSerial1'}; 
        String [] toSerial = new String[]{'tmpPSl^1', 'tmpPS2^1'};
        
        smartobject1.setfromSerial(fromSerial);
        smartobject1.setsnString('tmpPSl');
        smartobject1.setenteredSn('tmpPS2');
        smartobject1.SVMX_moveSerialNumberToTargetList(); 
        smartobject1.SVMX_addSerialNumberToTargetList();
        
        smartobject1.settoSerial(toSerial);
        smartobject1.SVMX_removeSerialFrmTarget();
        
        smartobject1.Do_SelectLine();
        smartobject1.Do_SelectBarCodeScanning();
        smartobject1.getisSourcelocationExists();
        smartobject1.getisTargetlocationExists();
        smartobject1.checkSerialNumber('tmpString');
        smartobject1.SVMX_moveToNextXLine();
        smartobject1.SVMX_moveToPrevXLine();
        smartobject1.SVMX_AddSerialToProductMap(fromSerial);
        smartobject1.getDuplicateSerials();
        smartobject1.SVMX_quickAddSerialNumberToTargetList();
        
        smartobject1.SVMX_DoSubmit();   
        smartobject1.SVMX_DoCancel();   
        
        smartobject1.getUserLocaleKey();
        smartobject1.getUserID();
        smartobject1.getUserOrgID();
        smartobject1.getbtnisdisabled();
        smartobject1.getDuplicateSerialWarned();
        smartobject1.setDuplicateSerialWarned(false);
        smartobject1.getSerSelectionMess();
        smartobject1.getdisableUsrToEnterQty();
        
        boolean IsbarCodeScanning = smartobject1.getIsbarCodeScanning();
        smartobject1.setIsbarCodeScanning(IsbarCodeScanning);
        
        smartobject1.getisInventoryEnabled();
        smartobject1.getisLocationInvolved();
        
        COMM_Inventory_Classes.InventoryProcess invProcess = smartobject1.getinvProcess (); 
        smartobject1.setinvProcess(invProcess);
        
        smartobject1.getxHdrName();
        smartobject1.setxHdrName('aaa');
        smartobject1.getfromSerial();
        smartobject1.getfrmOptions();
        smartobject1.getsnString();
        smartobject1.gettoSerial();
        smartobject1.gettoOptions();
        smartobject1.getenteredSn();
        smartobject1.getquickAddCount();
        smartobject1.setquickAddCount(1);
        smartobject1.getlstHdr();
        smartobject1.gethdrName();
        
        INVT_LineRecords selectedXLine = smartobject1.getselectedXLine();
        smartobject1.setselectedXLine(selectedXLine);
        
        smartobject1.getshowSerialSel();
        smartobject1.getdisableSerialSel();
        smartobject1.getdisableNxt();
        smartobject1.getdisablePrev();
        smartobject1.getLineLable();
        smartobject1.getProductLable();
        smartobject1.getOrignalQuantityLable();
        smartobject1.getActualQuantityProductLable();
        smartobject1.getTagsUtils();
        smartobject1.getPLTAG001();
        smartobject1.getPLTAG002();
        smartobject1.getPLTAG003();
        smartobject1.getGBL002();
        smartobject1.getGBL003();
        smartobject1.getIsSubmitEnabled();
        smartobject1.getIsValidxLines();
        
        smartobject1.mapRecToSerial.clear();
        smartobject1.validateSerialNumbers();
        
        smartobject1.xValidLines[0].trQty =-1;
        smartobject1.validateSerialNumbers();
        
        smartobject1.UpdateCriteria( 'SVMX.CurrantUser Name != null');
        
        smartobject1.SettingObjectList.put('GBL002', new SVMXC__ServiceMax_Config_Data__c(SVMXC__Internal_Value__c = 'TRUE'));
        smartobject1.SettingObjectList.put('GBL003', new SVMXC__ServiceMax_Config_Data__c(SVMXC__Internal_Value__c = 'TRUE'));
        smartobject1.SettingObjectList.put('GBL004', new SVMXC__ServiceMax_Config_Data__c(SVMXC__Internal_Value__c = 'TRUE'));
        smartobject1.getGBL002();
        smartobject1.getGBL003();
        smartobject1.getGBL004();
        
        /* smartobject1.lstRelatedCloserActions.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Parts_Request_Line__c', SVMXC__Field_Name__c = 'SVMXC__Parts_Request__c', SVMXC__Object_Name__c = 'SVMXC__Parts_Request_Line__c', SVMXC__Operator__c = 'SET'));
        smartobject1.lstRelatedCloserActions.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Parts_Request_Line__c', SVMXC__Field_Name__c = 'SVMXC__Parts_Request__c', SVMXC__Object_Name__c = 'SVMXC__Parts_Request_Line__c', SVMXC__Operator__c = 'DECREASE')); */
        smartobject1.SVMX_doUpdateRelatedLines();
        
        smartobject1.xLines[0].selected = false;
        smartobject1.Do_SelectLine();
        
        smartobject1.serialError();
        smartobject1.serialWarning();
        
        //Added to increase UT coverage 13/01/16
        boolean boolvar = smartobject1.SVMX_doUpdateXLines();
        boolvar = smartobject1.SVMX_doUpdateXHeader();
        boolvar = smartobject1.SVMX_doSerialSave();
        boolvar = smartobject1.SVMX_doStockUpdate();
        Set<String> strList = new Set<String>{'a','b','c'};
        String strvar = smartobject1.SVMX_getCommaSepratedStr(strList);
    }
    
    static testMethod void INVT_SmartEngine_UT1()
    {
        Test.startTest();
        
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id, SVMXC__Setting_Unique_ID__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('PORD008_SET007', 'PORD008_SET016', 'PORD008_SET014', 'PORD008_SET030', 'PORD008_SET031', 'PORD008_SET033',   'PORD008_SET038', 'PORD008_SET037', 'PORD008_SET032' , 'PORD008_SET008', 'PORD008_SET012', 'PORD008_SET020')];
 
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
        {
            if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET007')
                l.SVMXC__Internal_Value__c = 'RMA';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET016')
                l.SVMXC__Internal_Value__c = 'false';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET014')
                l.SVMXC__Internal_Value__c = 'false';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET030')
                l.SVMXC__Internal_Value__c = 'SVMXC__Ship_Location__r';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET031')
                l.SVMXC__Internal_Value__c = 'SVMXC__Delivery_Location__r';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET033')
                l.SVMXC__Internal_Value__c = 'SVMXC__Ship_Location__c';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET038')
                l.SVMXC__Internal_Value__c = 'SVMXC__Delivery_Location__c';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET032')
                l.SVMXC__Internal_Value__c = 'Increase';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET037')
                l.SVMXC__Internal_Value__c = 'Decrease';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET008')
                l.SVMXC__Internal_Value__c = 'testEmail@servicemax.com';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET012')
                l.SVMXC__Internal_Value__c = 'true';
            else if(l.SVMXC__Setting_Unique_ID__c == 'PORD008_SET020')
                l.SVMXC__Internal_Value__c = 'true';
        }
        upsert  lst; 
        
        RecordType shipRType, shipLineRType;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__RMA_Shipment_Order__c' or SobjectType = 'SVMXC__RMA_Shipment_Line__c' or SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        for(RecordType rt : rts){ 
            if(rt.SobjectType == 'SVMXC__RMA_Shipment_Order__c' &&rt.Name == 'Shipment'){
                shipRType = rt;
            } 
            if(rt.SobjectType == 'SVMXC__RMA_Shipment_Line__c' && rt.Name == 'RMA'){
                shipLineRType = rt;
            }
        }
        
        Account  account = new Account(Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
        insert account;
        
        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
          
        Product2 pr1 = new Product2(Name = 'prodPR1',ProductCode='prodPR1',SVMXC__Inherit_Parent_Warranty__c =True, SVMXC__Enable_Serialized_Tracking__c = true,SVMXC__Stockable__c = true );
        insert pr1; 
        
        Case case1 = new Case(Status ='New', Priority = 'Medium',Origin = 'Email',ContactId =contact.Id,AccountId=account.Id, SVMXC__Product__c = pr1.id); 
        insert case1; 
         
        list<SVMXC__Site__c> lstLocation = new list<SVMXC__Site__c>();
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'loc1',SVMXC__Stocking_Location__c = true,SVMXC__Account__c = account.Id,SVMXC__Street__c = 'millers road',SVMXC__Country__c = 'india',SVMXC__Zip__c = '123456', SVMXC__Email__c= 'testEmail@servicemax.com');
        lstLocation.add(location1);
         
        SVMXC__Site__c location2 = new SVMXC__Site__c(Name = 'loc2',SVMXC__Stocking_Location__c = true,SVMXC__Account__c = account.Id,SVMXC__Street__c = 'millers road',SVMXC__Country__c = 'india',SVMXC__Zip__c = '123456', SVMXC__Email__c= 'testEmail@servicemax.com');
        lstLocation.add(location2);
        
        insert lstLocation;
        
        SVMXC__RMA_Shipment_Order__c PartsOrder = new SVMXC__RMA_Shipment_Order__c(RecordTypeId =shipRType.Id,SVMXC__Company__c = account.Id,SVMXC__Contact__c = contact.Id, SVMXC__Case__c = case1.id, SVMXC__Order_Status__c = 'open',SVMXC__Expected_Delivery_Date__c = system.today(), SVMXC__Source_Location__c = location1.Id,SVMXC__Destination_Location__c = location2.id);
        insert PartsOrder;
        
        SVMXC__RMA_Shipment_Line__c pline1 = new SVMXC__RMA_Shipment_Line__c(RecordTypeId = shipLineRType.Id, SVMXC__RMA_Shipment_Order__c = PartsOrder.id,SVMXC__Product__c = pr1.id,SVMXC__Actual_Quantity2__c=15,SVMXC__Expected_Quantity2__c = 1,SVMXC__Line_Status__c = 'open', SVMXC__Ship_Location__c = location1.Id , SVMXC__Delivery_Location__c = location2.id);
        insert pline1;
        
        list<SVMXC__Product_Stock__c> lstPStock = new list<SVMXC__Product_Stock__c>();
        SVMXC__Product_Stock__c proStock = new SVMXC__Product_Stock__c();
        proStock.SVMXC__Status__c = 'Available';
        proStock.SVMXC__Product__c = pr1.id;
        proStock.SVMXC__Location__c = location1.Id;
        lstPStock.add(proStock);
        
        SVMXC__Product_Stock__c proStock1 = new SVMXC__Product_Stock__c();
        proStock1.SVMXC__Status__c = 'DECREASED';
        proStock1.SVMXC__Product__c = pr1.id;
        proStock1.SVMXC__Location__c = location1.Id;
        lstPStock.add(proStock1);
        insert lstPStock;
        
        SVMXC__Product_Serial__c proSerial = new SVMXC__Product_Serial__c();
        proSerial.SVMXC__Product__c = pr1.id;
        proSerial.SVMXC__Product_Stock__c = proStock.id;
        proSerial.SVMXC__Active__c = true;
        proSerial.Name = 'pSerial1';
        insert proSerial;
    
        PageReference pageRef = new PageReference('Page.SVMXC.INVT_SmartEngine');
        pageRef.getParameters().put('hdrId',PartsOrder.id);
        pageRef.getParameters().put('SMId','PORD008');
        pageRef.getParameters().put('LineId',pline1.id);
        Test.setCurrentPageReference(pageRef); 
        
        SVMXC.INVT_SmartEngine smartobject1 = new SVMXC.INVT_SmartEngine();
        
        smartobject1.setsnString('pSerial1');
        smartobject1.SVMX_moveSerialNumberToTargetList(); 
        
        smartobject1.SVMX_DoSubmit();   
        
        smartobject1.mapRecFrmSerial.clear();
        smartobject1.buildFromSerialNumber();
        
        smartobject1.xValidLines[0].exQty  = 5;
        smartobject1.xValidLines[0].closeLine = false;
        smartobject1.SVMX_doUpdateXLines();
        
        smartobject1.getisSourcelocationExists();
        smartobject1.getisTargetlocationExists();
        
        smartobject1.iPro.Number_of_locations ='ONE';
        smartobject1.iPro.Source_Action = 'SET';
        smartobject1.SVMX_doSerialSave();
        smartobject1.SVMX_doStockUpdate();
        
        proStock.SVMXC__Status__c = 'ADJUSTED';
        proStock.SVMXC__Location__c = location1.Id;
        upsert proStock;
        smartobject1.CheckStock();
        
        smartobject1.SVMX_DoSubmit();
        
        Test.stopTest();
    }
    
    
}