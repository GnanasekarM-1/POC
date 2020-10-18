@isTest
private class DCX_MapServiceManager_UT {

    @isTest static void  getViewDataTestForWO()
    {
        
        RecordType RTNameSearch = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'View Definition' Limit 1];
        RecordType RTExprsson = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Expressions' Limit 1];
        RecordType RTRule = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SVMX Rule' Limit 1]; 
        
        SVMXC__ServiceMax_Processes__c objSVMXPrcss = new SVMXC__ServiceMax_Processes__c();
        objSVMXPrcss.RecordTypeId = RTNameSearch.id;
        objSVMXPrcss.SVMXC__Select__c = true;
        objSVMXPrcss.SVMXC__Rule_Type__c = 'Custom View';
        objSVMXPrcss.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSVMXPrcss.SVMXC__View_For__c = 'Grid';
        objSVMXPrcss.SVMXC__Values__c = 'Id,Name,SVMXC__Company__r.Name,SVMXC__Contact__r.Name';
        objSVMXPrcss.SVMXC__Parent_Object_Criteria__c = 'Name != \'ABC\'';
        insert objSVMXPrcss;
        
        SVMXC__ServiceMax_Processes__c objMapHoverHdr = new SVMXC__ServiceMax_Processes__c();
        objMapHoverHdr.RecordTypeId = RTRule.id;
        objMapHoverHdr.SVMXC__Rule_Type__c = 'Column Info';
        objMapHoverHdr.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objMapHoverHdr.SVMXC__Name__c = 'Work Order map hpver';
        insert objMapHoverHdr;
        
        
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c  hoverColumn1 = new SVMXC__ServiceMax_Config_Data__c();
        hoverColumn1.RecordTypeId = RTExprsson.id;
        hoverColumn1.SVMXC__Field_Name__c = 'Name';
        hoverColumn1.SVMXC__Display_Type__c = 'STRING';
        hoverColumn1.SVMXC__Expression_Rule__c = objMapHoverHdr.id;
        hoverColumn1.SVMXC__Expression_Type__c = 'Column Field';
        lstConfigData.add(hoverColumn1);
        SVMXC__ServiceMax_Config_Data__c  hoverColumn2 = new SVMXC__ServiceMax_Config_Data__c();
        hoverColumn2.RecordTypeId = RTExprsson.id;
        hoverColumn2.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        hoverColumn2.SVMXC__Display_Type__c = 'REFERENCE';
        hoverColumn2.SVMXC__Expression_Rule__c = objMapHoverHdr.id;
        hoverColumn2.SVMXC__Expression_Type__c = 'Column Field';
        hoverColumn2.SVMXC__Field_Relationship_Name__c = 'SVMXC__Company__r';
        hoverColumn2.SVMXC__FKey_Name_Field__c = 'Name';
        lstConfigData.add(hoverColumn2);
        insert lstConfigData;
        
        Account objAcc = new Account();
        objAcc.Name = 'ABC Inc';
        objAcc.SVMXC__Latitude__c = 12.96489764639294;
        objAcc.SVMXC__Longitude__c = 77.47316882765995;
        insert objAcc;
        Contact objCon = new Contact();
        objCon.LastName = 'John';
        insert objCon;
        SVMXC__Service_Order__c objWO = new SVMXC__Service_Order__c();
        objWO.SVMXC__Contact__c = objCon.id;
        objWO.SVMXC__Company__c = objAcc.id;
        objWO.SVMXC__Latitude__c = 12.96489764639294;
        objWO.SVMXC__Longitude__c = 77.47316882765995;
        insert objWO;
        
        string objectname = 'SVMXC__Service_Order__c';
        string viewId = objSVMXPrcss.id;
        Integer recordlimit= 1;
        Double latitude= 12.96489764639294;
        Double longitude=77.47316882765995;
        Double radius =180;
        
       /* SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap = new  list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC.INTF_WebServicesDef.INTF_StringMap stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'OBJECTNAME'; 
        stringMap1.value = 'SVMXC__Service_Order__c';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'VIEWID'; 
        stringMap1.value = objSVMXPrcss.id;
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'RECORDLIMIT'; 
        stringMap1.value = '1';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'LATITUDE'; 
        stringMap1.value = '12.96489764639294';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'LONGITUDE'; 
        stringMap1.value = '77.47316882765995';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'RADIUS'; 
        stringMap1.value = '20';
        lstStringMap.add(stringMap1);
        request.stringMap = lstStringMap;*/
       // SVMXC.DCX_MapServiceManager viewUtils = new SVMXC.DCX_MapServiceManager(); 
        //System.assertEquals(true, request != null);
        SVMXC.DCX_MapServiceManager.getMapData(objectname,viewId,recordlimit,latitude,longitude,radius);
        //DCX_ServiceManager DCXS = new DCX_ServiceManager();
        
       // INTF_WebServicesDef.INTF_Response inf =  DCXS.getMapData(objectname,viewId,recordlimit,latitude,longitude,radius);
       
       
        
    
        
    }
    @isTest static void  getViewDataTestForLocation()
    {
        RecordType RTNameSearch = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'View Definition' Limit 1];
        RecordType RTExprsson = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Expressions' Limit 1];
        RecordType RTRule = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SVMX Rule' Limit 1]; 
        
        SVMXC__ServiceMax_Processes__c objSVMXPrcss = new SVMXC__ServiceMax_Processes__c();
        objSVMXPrcss.RecordTypeId = RTNameSearch.id;
        objSVMXPrcss.SVMXC__Select__c = true;
        objSVMXPrcss.SVMXC__Rule_Type__c = 'Custom View';
        objSVMXPrcss.SVMXC__Source_Object_Name__c = 'SVMXC__Site__c';
        objSVMXPrcss.SVMXC__View_For__c = 'Grid';
        objSVMXPrcss.SVMXC__Values__c = 'Id,Name,SVMXC__Account__r.Name';
        objSVMXPrcss.SVMXC__Parent_Object_Criteria__c = 'Name != \'ABC\'';
        insert objSVMXPrcss;
        
        SVMXC__ServiceMax_Processes__c objMapHoverHdr = new SVMXC__ServiceMax_Processes__c();
        objMapHoverHdr.RecordTypeId = RTRule.id;
        objMapHoverHdr.SVMXC__Rule_Type__c = 'Column Info';
        objMapHoverHdr.SVMXC__Source_Object_Name__c = 'SVMXC__Site__c';
        objMapHoverHdr.SVMXC__Name__c = 'Work Order map hpver';
        insert objMapHoverHdr;
        
        
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c  hoverColumn1 = new SVMXC__ServiceMax_Config_Data__c();
        hoverColumn1.RecordTypeId = RTExprsson.id;
        hoverColumn1.SVMXC__Field_Name__c = 'Name';
        hoverColumn1.SVMXC__Display_Type__c = 'STRING';
        hoverColumn1.SVMXC__Expression_Rule__c = objMapHoverHdr.id;
        hoverColumn1.SVMXC__Expression_Type__c = 'Column Field';
        lstConfigData.add(hoverColumn1);
        SVMXC__ServiceMax_Config_Data__c  hoverColumn2 = new SVMXC__ServiceMax_Config_Data__c();
        hoverColumn2.RecordTypeId = RTExprsson.id;
        hoverColumn2.SVMXC__Field_Name__c = 'SVMXC__Account__c';
        hoverColumn2.SVMXC__Display_Type__c = 'REFERENCE';
        hoverColumn2.SVMXC__Expression_Rule__c = objMapHoverHdr.id;
        hoverColumn2.SVMXC__Expression_Type__c = 'Column Field';
        lstConfigData.add(hoverColumn2);
        
        insert lstConfigData;
        
        Account objAcc = new Account();
        objAcc.Name = 'ABC Inc';
        objAcc.SVMXC__Latitude__c = 12.96489764639294;
        objAcc.SVMXC__Longitude__c = 77.47316882765995;
        insert objAcc;
        
        SVMXC__Site__c objLocation = new SVMXC__Site__c();
        objLocation.SVMXC__Account__c = objAcc.id;
        objLocation.SVMXC__Latitude__c = 12.96489764639294;
        objLocation.SVMXC__Longitude__c = 77.47316882765995;
        insert objLocation;
        
        string objectname = 'SVMXC__Site__c';
        string viewId = objSVMXPrcss.id;
        Integer recordlimit= 1;
        Double latitude= 12.96489764639294;
        Double longitude=77.47316882765995;
        Double radius =180;
        
        // For Location Object
        SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap = new  list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC.INTF_WebServicesDef.INTF_StringMap stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        lstStringMap.clear();
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'OBJECTNAME'; 
        stringMap1.value = 'SVMXC__Site__c';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'VIEWID'; 
        stringMap1.value = objSVMXPrcss.id;
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'RECORDLIMIT'; 
        stringMap1.value = '1';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'LATITUDE'; 
        stringMap1.value = '12.96489764639294';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'LONGITUDE'; 
        stringMap1.value = '77.47316882765995';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'RADIUS'; 
        stringMap1.value = '20';
        lstStringMap.add(stringMap1);
        request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        request.stringMap = lstStringMap;
        SVMXC.DCX_MapServiceManager viewUtils = new SVMXC.DCX_MapServiceManager();
        //System.assertEquals(true, request != null);
        Test.startTest();
        SVMXC.DCX_MapServiceManager.getMapData(objectname,viewId,recordlimit,latitude,longitude,radius);
        Test.stopTest();
    }
    
     @isTest static void  getViewDataTestForAccount()
    {
        RecordType RTNameSearch = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'View Definition' Limit 1];
        RecordType RTExprsson = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Expressions' Limit 1];
        RecordType RTRule = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SVMX Rule' Limit 1]; 
        
        SVMXC__ServiceMax_Processes__c objSVMXPrcss = new SVMXC__ServiceMax_Processes__c();
        objSVMXPrcss.RecordTypeId = RTNameSearch.id;
        objSVMXPrcss.SVMXC__Select__c = true;
        objSVMXPrcss.SVMXC__Rule_Type__c = 'Custom View';
        objSVMXPrcss.SVMXC__Source_Object_Name__c = 'Account';
        objSVMXPrcss.SVMXC__View_For__c = 'Grid';
        objSVMXPrcss.SVMXC__Values__c = 'Id,Name,SVMXC__Access_Hours__r.Name';
        objSVMXPrcss.SVMXC__Parent_Object_Criteria__c = 'Name != \'ABC\'';
        insert objSVMXPrcss;
        
        SVMXC__ServiceMax_Processes__c objMapHoverHdr = new SVMXC__ServiceMax_Processes__c();
        objMapHoverHdr.RecordTypeId = RTRule.id;
        objMapHoverHdr.SVMXC__Rule_Type__c = 'Column Info';
        objMapHoverHdr.SVMXC__Source_Object_Name__c = 'Account';
        objMapHoverHdr.SVMXC__Name__c = 'Work Order map hpver';
        insert objMapHoverHdr;
        
        
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c  hoverColumn1 = new SVMXC__ServiceMax_Config_Data__c();
        hoverColumn1.RecordTypeId = RTExprsson.id;
        hoverColumn1.SVMXC__Field_Name__c = 'Name';
        hoverColumn1.SVMXC__Display_Type__c = 'STRING';
        hoverColumn1.SVMXC__Expression_Rule__c = objMapHoverHdr.id;
        hoverColumn1.SVMXC__Expression_Type__c = 'Column Field';
        lstConfigData.add(hoverColumn1);
        SVMXC__ServiceMax_Config_Data__c  hoverColumn2 = new SVMXC__ServiceMax_Config_Data__c();
        hoverColumn2.RecordTypeId = RTExprsson.id;
        hoverColumn2.SVMXC__Field_Name__c = 'SVMXC__Access_Hours__c';
        hoverColumn2.SVMXC__Display_Type__c = 'REFERENCE';
        hoverColumn2.SVMXC__Expression_Rule__c = objMapHoverHdr.id;
        hoverColumn2.SVMXC__Expression_Type__c = 'Column Field';
        lstConfigData.add(hoverColumn2);
        
        insert lstConfigData;
        
        Account objAcc = new Account();
        objAcc.Name = 'ABC Inc';
        objAcc.SVMXC__Latitude__c = 12.96489764639294;
        objAcc.SVMXC__Longitude__c = 77.47316882765995;
        insert objAcc;
        
        string objectname = 'Account';
        string viewId = objSVMXPrcss.id;
        Integer recordlimit= 1;
        Double latitude= 12.96489764639294;
        Double longitude=77.47316882765995;
        Double radius =180;
        
       /* SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap = new  list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC.INTF_WebServicesDef.INTF_StringMap stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'OBJECTNAME'; 
        stringMap1.value = 'Account';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'VIEWID'; 
        stringMap1.value = objSVMXPrcss.id;
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'RECORDLIMIT'; 
        stringMap1.value = '1';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'LATITUDE'; 
        stringMap1.value = '12.96489764639294';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'LONGITUDE'; 
        stringMap1.value = '77.47316882765995';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'RADIUS'; 
        stringMap1.value = '20';
        lstStringMap.add(stringMap1);
        request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        request.stringMap = lstStringMap;*/
        //SVMXC.DCX_MapServiceManager viewUtils = new SVMXC.DCX_MapServiceManager();
       // System.assertEquals(true, request != null);
        //DCX_ServiceManager DCXS = new DCX_ServiceManager();
        SVMXC.DCX_MapServiceManager.getMapData(objectname,viewId,recordlimit,latitude,longitude,radius);
        
    }
}