@isTest
Private with sharing class  INTF_Get_Tasks_UT
{
    static testMethod void INTF_Get_Tasks_UT_Test()
    {  
    SVMXC__Service_Order__c objWO  = new SVMXC__Service_Order__c();
    objWO.SVMXC__Priority__c = 'High';
    objWO.OwnerId = Userinfo.getUserId();
    insert objWO;
    system.assert(objWO.SVMXC__Priority__c!=null);
    
    Task objNewEvent = new Task();
    objNewEvent.ReminderDateTime = system.Today();
    system.assert(objNewEvent.ReminderDateTime!=null);
    //objNewEvent.DurationInMinutes = 180;
    objNewEvent.OwnerId = Userinfo.getUserId();
    objNewEvent.WhatId = objWO.Id;
    insert objNewEvent;
    
    objNewEvent = new Task ();
    objNewEvent.ReminderDateTime = system.Today();
    system.assert(objNewEvent.ReminderDateTime!=null);
    //objNewEvent.DurationInMinutes = 180;
    objNewEvent.OwnerId = Userinfo.getUserId();
    objNewEvent.Description ='This is for a test class';
    //objNewEvent.WhatId = objWO.Id;
    insert objNewEvent;
    
    Task objNewEvent2 = new Task();
    objNewEvent2.ReminderDateTime = system.Today() - 1;
    system.assert(objNewEvent2.ReminderDateTime!=null);
    //objNewEvent2.DurationInMinutes = 180;
    objNewEvent2.OwnerId = Userinfo.getUserId();
    objNewEvent2.WhatId = objWO.Id;
    insert objNewEvent2;
    
    Task objNewEvent3 = new Task();
    objNewEvent3.ReminderDateTime = system.Today() + 1;
    system.assert(objNewEvent3.ReminderDateTime!=null);
    //objNewEvent3.DurationInMinutes = 180;
    objNewEvent3.OwnerId = Userinfo.getUserId();
    objNewEvent3.WhatId = objWO.Id;
    insert objNewEvent3;
    
    INTF_WebServicesDef.INTF_StringMap[] lstMaps = new INTF_WebServicesDef.INTF_StringMap[3];
    INTF_Get_Tasks obj = new INTF_Get_Tasks();
    INTF_WebServicesDef.INTF_Request_For_Tasks objReq = new INTF_WebServicesDef.INTF_Request_For_Tasks();
            
        INTF_WebServicesDef.INTF_StringMap objStrMap = new INTF_WebServicesDef.INTF_StringMap();
        objStrMap.key = 'startDate';
        objStrMap.value = ''+system.Today();
        lstMaps[0] = objStrMap;
        objStrMap = new INTF_WebServicesDef.INTF_StringMap();
        objStrMap.key = 'endDate';
        objStrMap.value = ''+system.Today();
        lstMaps[1] = objStrMap;
        objStrMap = new INTF_WebServicesDef.INTF_StringMap();
        objStrMap.key = 'userID';
        objStrMap.value = Userinfo.getUserId();
        lstMaps[2] = objStrMap;
        objReq.taskReqInfo = lstMaps;
        INTF_WebServicesDef.INTF_Response_For_Tasks res = obj.INTF_Get_Tasks(objReq);
    }

}