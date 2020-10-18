@isTest(seeAllData = true)
private with sharing class INTF_Get_Events_UT 
{
  static testMethod void getEventsCoverage()
  {
    
    SVMXC__Service_Order__c objWO  = new SVMXC__Service_Order__c();
    objWO.SVMXC__Priority__c = 'High';
    objWO.OwnerId = Userinfo.getUserId();
    insert objWO;
    system.assert(objWO.SVMXC__Priority__c!=null);
    
    
    Event objNewEvent = new Event();
    objNewEvent.StartDateTime = system.now().addHours(2);
    objNewEvent.DurationInMinutes = 180;
    objNewEvent.OwnerId = Userinfo.getUserId();
    objNewEvent.WhatId = objWO.Id;
    insert objNewEvent;
    system.assert(objNewEvent.DurationInMinutes!=null);
    
    
    objNewEvent = new Event();
    objNewEvent.StartDateTime = system.now().addHours(2);
    system.assert(objNewEvent.StartDateTime!=null);
    objNewEvent.DurationInMinutes = 180;
    system.assert(objNewEvent.DurationInMinutes!=null);
    objNewEvent.OwnerId = Userinfo.getUserId();
    objNewEvent.Description ='This is for a test class';
    //objNewEvent.WhatId = objWO.Id;
    insert objNewEvent;
    
    INTF_WebServicesDef.INTF_StringMap[] lstMaps = new INTF_WebServicesDef.INTF_StringMap[3];
    INTF_Get_Events obj = new INTF_Get_Events();
    INTF_WebServicesDef.INTF_Request_For_Events objReq = new INTF_WebServicesDef.INTF_Request_For_Events();
            
        INTF_WebServicesDef.INTF_StringMap objStrMap = new INTF_WebServicesDef.INTF_StringMap();
        objStrMap.key = 'startDate';
        objStrMap.value = ''+system.now();
        lstMaps[0] = objStrMap;
        objStrMap = new INTF_WebServicesDef.INTF_StringMap();
        objStrMap.key = 'endDate';
        objStrMap.value = ''+system.now();
        lstMaps[1] = objStrMap;
        objStrMap = new INTF_WebServicesDef.INTF_StringMap();
        objStrMap.key = 'userID';
        objStrMap.value = Userinfo.getUserId();
        lstMaps[2] = objStrMap;
        objReq.eventReqInfo = lstMaps;
        INTF_WebServicesDef.INTF_Response_For_Events res = obj.INTF_Get_Events(objReq);
    
  } 
}