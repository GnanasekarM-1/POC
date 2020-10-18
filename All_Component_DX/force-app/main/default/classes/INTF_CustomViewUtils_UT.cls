/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class INTF_CustomViewUtils_UT 
{

    static testMethod void getViewDefinitionTest() 
    {
        RecordType RTNameSearch = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'View Definition' Limit 1];
        RecordType RTExprsson = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Expressions' Limit 1];
        RecordType RTCfgDta = [select Id from RecordType where Name = 'View Access' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 1'
                                            );
        insert team1;
        System.assertEquals(true, team1.Id != null);
        SVMXC__Territory__c ter1 = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert ter1;
        System.assertEquals(true, ter1.Id != null);
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = team1.Id ,
                                            SVMXC__Service_Territory__c = ter1.Id,
                                            SVMXC__Salesforce_User__c = userinfo.getuserid()
                                            );
        insert tech1;
        System.assertEquals(true, tech1.Id != null);
        SVMXC__Dispatcher_Access__c dacc = new SVMXC__Dispatcher_Access__c (
                                            SVMXC__Service_Team__c = team1.Id,
                                            SVMXC__Dispatcher__c = userinfo.getuserid() 
                                            );
        insert dacc;
        System.assertEquals(true, dacc.Id != null);
        SVMXC__ServiceMax_Processes__c objSVMXPrcss = new SVMXC__ServiceMax_Processes__c();
        objSVMXPrcss.SVMXC__IsStandard__c = true;
        objSVMXPrcss.RecordTypeId = RTNameSearch.id;
        objSVMXPrcss.SVMXC__Select__c = true;
        objSVMXPrcss.SVMXC__Rule_Type__c = 'Custom View';
        objSVMXPrcss.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSVMXPrcss.SVMXC__View_For__c = 'Grid';
        insert objSVMXPrcss;
        
        SVMXC__ServiceMax_Config_Data__c objCfg = new SVMXC__ServiceMax_Config_Data__c();
        objCfg.RecordTypeId = RTCfgDta.Id;
        objCfg.SVMXC__Configuration_Type__c = 'Custom_View';
        objCfg.SVMXC__Dispatch_Process__c = objSVMXPrcss.Id;
        objCfg.SVMXC__Access_To__c = 'Dispatcher';
        objCfg.SVMXC__Service_Group__c =team1.Id;
        objCfg.SVMXC__Territory__c =ter1.Id;
        insert objCfg;
        
        SVMXC__ServiceMax_Config_Data__c objCfg1 = new SVMXC__ServiceMax_Config_Data__c();
        objCfg1.RecordTypeId = RTCfgDta.Id;
        objCfg1.SVMXC__Configuration_Type__c = 'Custom_View';
        objCfg1.SVMXC__Dispatch_Process__c = objSVMXPrcss.Id;
        objCfg1.SVMXC__Access_To__c = 'Technician';
        objCfg1.SVMXC__Territory__c =ter1.Id;
        objCfg1.SVMXC__Service_Group__c =team1.Id;
        insert objCfg1;
        
        System.assertEquals(true, objSVMXPrcss.Id != null);
        System.assertEquals(true, objCfg.Id != null);
        System.assertEquals(true, objCfg1.Id != null);
        
        SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        list<SVMXC.INTF_WebServicesDef.INTF_StringListMap> lstStringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringListMap>();
        SVMXC.INTF_WebServicesDef.INTF_StringListMap map1 = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
        map1.key = 'OBJECTNAME';
        map1.valueList.add('SVMXC__Service_Order__c');
        lstStringMap.add(map1);
        SVMXC.INTF_WebServicesDef.INTF_StringListMap map2 = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
        map2.key = 'VIEWFOR';
        map2.valueList.add('Grid');
        lstStringMap.add(map2);
        SVMXC.INTF_WebServicesDef.INTF_StringListMap map3 = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
        map3.key = 'USERID';
        map3.valueList.add(userinfo.getuserid());
        lstStringMap.add(map3);
        SVMXC.INTF_WebServicesDef.INTF_StringListMap map4 = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
        map4.key = 'ISCALLEDFROMDC';
        lstStringMap.add(map4);
        request.stringListMap = lstStringMap;
        SVMXC.INTF_CustomViewUtils viewUtils = new SVMXC.INTF_CustomViewUtils(); 
        System.assertEquals(true, request != null);
        viewUtils.getViewDefinition(request);
        
    }
    static testMethod void getViewDataTestForWO()
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
        objAcc.SVMXC__Latitude__c = 111.11;
        objAcc.SVMXC__Longitude__c = 10.11;
        insert objAcc;
        Contact objCon = new Contact();
        objCon.LastName = 'John';
        insert objCon;
        SVMXC__Service_Order__c objWO = new SVMXC__Service_Order__c();
        objWO.SVMXC__Contact__c = objCon.id;
        objWO.SVMXC__Company__c = objAcc.id;
        objWO.SVMXC__Latitude__c = 111.11;
        objWO.SVMXC__Longitude__c = 10.11;
        insert objWO;
        
        SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
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
        stringMap1.value = '111.11';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'LONGITUDE'; 
        stringMap1.value = '10.11';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'RADIUS'; 
        stringMap1.value = '20';
        lstStringMap.add(stringMap1);
        request.stringMap = lstStringMap;
        SVMXC.INTF_CustomViewUtils viewUtils = new SVMXC.INTF_CustomViewUtils(); 
        System.assertEquals(true, request != null);
        viewUtils.getViewData(request);
       
        
        
    }
    static testMethod void getViewDataTestForLocation()
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
        objAcc.SVMXC__Latitude__c = 111.11;
        objAcc.SVMXC__Longitude__c = 10.11;
        insert objAcc;
        
        SVMXC__Site__c objLocation = new SVMXC__Site__c();
        objLocation.SVMXC__Account__c = objAcc.id;
        objLocation.SVMXC__Latitude__c = 111.11;
        objLocation.SVMXC__Longitude__c = 10.11;
        insert objLocation;
        
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
        stringMap1.value = '111.11';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'LONGITUDE'; 
        stringMap1.value = '10.11';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'RADIUS'; 
        stringMap1.value = '20';
        lstStringMap.add(stringMap1);
        request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        request.stringMap = lstStringMap;
        SVMXC.INTF_CustomViewUtils viewUtils = new SVMXC.INTF_CustomViewUtils();
        System.assertEquals(true, request != null);
        viewUtils.getViewData(request);
    }
    static testMethod void getViewDataTestForAccount()
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
        objAcc.SVMXC__Latitude__c = 111.11;
        objAcc.SVMXC__Longitude__c = 10.11;
        insert objAcc;
        
        SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
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
        stringMap1.value = '111.11';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'LONGITUDE'; 
        stringMap1.value = '10.11';
        lstStringMap.add(stringMap1);
        stringMap1 = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
        stringMap1.key = 'RADIUS'; 
        stringMap1.value = '20';
        lstStringMap.add(stringMap1);
        request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        request.stringMap = lstStringMap;
        SVMXC.INTF_CustomViewUtils viewUtils = new SVMXC.INTF_CustomViewUtils();
        System.assertEquals(true, request != null);
        viewUtils.getViewData(request);
    }
}