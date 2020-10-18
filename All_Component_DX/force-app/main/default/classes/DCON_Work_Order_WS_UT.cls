@isTest
Private class DCON_Work_Order_WS_UT {
    static testMethod void DCON_Work_Order_WS_UT_Test()
    {
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id, SVMXC__Setting_Unique_ID__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('DCON001_SET038','DCON001_SET039','DCON001_SET040','DCON001_SET041','DCON001_SET042','DCON001_SET043','DCON001_SET044','DCON001_SET045','DCON001_SET046','DCON001_SET047','GLOB001_GBL007','GLOB001_GBL014','EVER007_SET001','IPRD003_SET007','IPRD003_SET003', 'EVER007_SET002')];
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
            {
                if (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET038'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Dispatch_Response__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Dispatch_Response__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }   
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET039'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Order_Status__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Order_Status__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }   
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET040'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Purpose_of_Visit__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Purpose_of_Visit__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET041'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Customer_Down__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Customer_Down__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET042'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Finished_Onsite_Date_Time__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Finished_Onsite_Date_Time__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET043'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Scheduled_Date__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Scheduled_Date__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET044'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Problem_Description__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Problem_Description__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET045'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__City__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__City__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET046'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Contact__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Contact__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET047'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Country__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Country__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else
                {
                    l.SVMXC__Display_Value__c = 'false';
                    l.SVMXC__Internal_Value__c = 'false';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
            }
        if(lst != null && lst.size() > 0)
           update lst;
        //Creae UT Datas
        String usid=UserInfo.getUserId();
        system.assert(usid!=null);
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        ); 
        insert account;
        

        Contact contact = new Contact(LastName='Last',AccountId =account.Id);
        insert contact;
        
        RecordType RTProcess = [select Id from RecordType where Name = 'View Definition' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RTCfgDta = [select Id from RecordType where Name = 'View Access' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        SVMXC__ServiceMax_Processes__c objSVMXPrcss = new SVMXC__ServiceMax_Processes__c();
        objSVMXPrcss.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSVMXPrcss.SVMXC__Ownership_Type__c = 'All Records';
        objSVMXPrcss.SVMXC__Rule_Type__c = 'Custom View';
        objSVMXPrcss.SVMXC__ProcessID__c = 'testing1234';
        objSVMXPrcss.SVMXC__Name__c = 'testing1234';
        objSVMXPrcss.SVMXC__Advance_Expression__c = '';
        objSVMXPrcss.SVMXC__IsStandard__c = false;
        objSVMXPrcss.RecordTypeId = RTProcess.Id;
        insert objSVMXPrcss;
        
        Case case1 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', ContactId =contact.Id, AccountId=account.Id); 
        insert case1; 
        
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (SVMXC__Case__c = case1.Id , SVMXC__Company__c = account.Id , SVMXC__Contact__c =contact.Id, SVMXC__Latitude__c = 40.739582 , SVMXC__Longitude__c = -73.980772, SVMXC__Order_Status__c = 'Open',SVMXC__Priority__c ='Medium',SVMXC__Order_Type__c='Field Service',SVMXC__Locked_By_DC__c = true);
         upsert svo;

        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 1'
                                            );
        insert team1;
        
        SVMXC__Territory__c ter1 = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert ter1;
        
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = team1.Id ,
                                            SVMXC__Service_Territory__c = ter1.Id
                                            );
        insert tech1;
        
        SVMXC__Dispatcher_Access__c dacc = new SVMXC__Dispatcher_Access__c (
                                            SVMXC__Service_Team__c = team1.Id,
                                            SVMXC__Dispatcher__c = u.Id 
                                            );
        insert dacc;
        
        Group  testgroupobjone=new Group (name='test one');
        insert testgroupobjone;
        GroupMember  testgroupmenberone=new GroupMember (GroupId=testgroupobjone.id,UserOrGroupId=usid);
        
         List<Event> EventList = new List<Event>();
      
      
      
        List<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new List<DCON_Configuration_WS.SVMX_StringMap>();
        test.starttest();
        List<String> WorkOrderIds = new List<String>();
        WorkOrderIds.add(svo.Id);
        system.assert(WorkOrderIds!=null);
        DCON_Work_Order_WS.DCON_Assign_Work_Order_To_MultiTech_WS(u.Id, WorkOrderIds, tech1.Id, NULL, EventList, true);
        DCON_Work_Order_WS.DCON_Assign_Work_Order_To_Team_WS(u.Id, WorkOrderIds, team1.Id, true);
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TECHNICIAN', 'TERRITORY,Name', 'ANY');
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TEAM', 'TERRITORY,Name', 'ALL');
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TECHNICIAN', 'EXPERTISE,Name', 'ANY');
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'a,i', 'TECHNICIAN', 'SVMXC__City__c,Name', 'ANY');        
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TECHNICIAN', 'PRODUCT,EXPERTISE,', 'ALL');
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TEAM', 'PRODUCT,EXPERTISE,', 'ALL');
        
        DCON_Work_Order_WS.DCON_Retrieve_Views_WS(u.Id);
       
        List<String> dispStatus = new List<String>();
        List<String> keyValPairs = new List<String>();
        dispStatus.add('ALL');
        keyValPairs.add('RESPONSETYPE|IDONLY');
        List<String> keyValPairs1 = new List<String>();
        keyValPairs1.add('RESPONSETYPE|'+system.currentTimeMillis());
        DCON_Work_Order_WS.DCON_Retrieve_Delta_Work_Orders_WS(keyValPairs, u.Id, null, dispStatus, null, WorkOrderIds);
        List<String> dispStatus3 = new List<String>();
        dispStatus3.add('QUEUED');
        DCON_Work_Order_WS.DCON_Retrieve_Delta_Work_Orders_WS(keyValPairs, u.Id, null, dispStatus3, null, WorkOrderIds);
        DCON_Work_Order_WS.DCON_Retrieve_Delta_Work_Orders_WS(keyValPairs, u.Id, objSVMXPrcss.Id, dispStatus, null, WorkOrderIds);
        DCON_Work_Order_WS.DCON_Retrieve_Delta_Work_Orders_WS(keyValPairs, u.Id, objSVMXPrcss.Id, dispStatus3, null, WorkOrderIds);
        DCON_Work_Order_WS.DCON_Retrieve_AllWorkOrder_Ids_WS(keyValPairs, u.Id, objSVMXPrcss.Id, dispStatus, 'Asia/Calcutta');
        DCON_Work_Order_WS.DCON_Retrieve_Work_Orders_WS2(keyValPairs, u.Id, objSVMXPrcss.Id, dispStatus, 'Asia/Calcutta', WorkOrderIds);
        DCON_Work_Order_WS.DCON_Retrieve_Work_Orders_WS(u.Id, objSVMXPrcss.Id, dispStatus, 'Asia/Calcutta', WorkOrderIds);
        DCON_Work_Order_WS.DCON_Retrieve_Eliminated_Work_Order_Info(u.Id, 'Asia/Calcutta', WorkOrderIds);
        DCON_Work_Order_WS.DCON_Assign_Work_Order_To_Tech_WS(u.Id, WorkOrderIds, tech1.Id, true);
        DCON_Work_Order_WS.DCON_Assign_Work_Order_To_MultiTech_WS2(u.Id, WorkOrderIds, tech1.Id, 'Asia/Calcutta', EventList, true, lstKeyValue);      
        //DCON_Work_Order_WS.DCON_UnAssignAssign_Work_Order_To_MultiTech_WS2(u.Id, WorkOrderIds, tech1.Id, 'Asia/Calcutta', EventList, true, lstKeyValue);
        DCON_Work_Order_WS.DCON_Retrieve_Work_Order_Info();
        DCON_Work_Order_WS.loadDCsetting();
        DCON_Work_Order_WS.DC_StringListMap obj1 = new DCON_Work_Order_WS.DC_StringListMap();
        DCON_Work_Order_WS.DCON_WO_MultiAssign_Request obj2 = new DCON_Work_Order_WS.DCON_WO_MultiAssign_Request();
        DCON_Work_Order_WS.DCON_WO_MultiAssign_Response obj3 = new DCON_Work_Order_WS.DCON_WO_MultiAssign_Response();
        obj1.getvalueList();
        //obj1.setvalueList('a');
        obj2.getworkOrderIds();
        obj2.getEventlist();
        obj3.getlstTechEventDetails();
        DCON_Work_Order_WS.DCON_Keyword_Search_WS_Wrapper obj4 ;
        set<string> lststr = new set<string>();
        lststr.add('Bangalore');
        lststr.add('Repair');
        DCON_Work_Order_WS.SVMX_getFieldNamesFromList(lststr);
        test.stoptest();
    }
    
    static testMethod void DCON_Work_Order_WS_UT_Test11()
    {
        DCON_Work_Order_WS obj = new DCON_Work_Order_WS();
        //Creae UT Datas
        String usid=UserInfo.getUserId();
        system.assert(usid!=null);
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        Account account = new Account(Name ='Account',ShippingStreet='ABC',ShippingCity='PQR',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ', BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
        insert account;
        

        Contact contact = new Contact(LastName='Last',AccountId =account.Id);
        insert contact;
        
        RecordType RTProcess = [select Id from RecordType where Name = 'View Definition' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RTCfgDta = [select Id from RecordType where Name = 'View Access' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        SVMXC__ServiceMax_Processes__c objSVMXPrcss = new SVMXC__ServiceMax_Processes__c();
        objSVMXPrcss.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSVMXPrcss.SVMXC__Ownership_Type__c = 'All Records';
        objSVMXPrcss.SVMXC__Rule_Type__c = 'Custom View';
        objSVMXPrcss.SVMXC__ProcessID__c = 'testing1234';
        objSVMXPrcss.SVMXC__Name__c = 'testing1234';
        objSVMXPrcss.SVMXC__Advance_Expression__c = '';
        objSVMXPrcss.SVMXC__IsStandard__c = false;
        objSVMXPrcss.RecordTypeId = RTProcess.Id;
        insert objSVMXPrcss;
        
        
        
        
        Case case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId =contact.Id,
                                        AccountId=account.Id                                         
                                        ); 
       //insert case1; 
        
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = case1.Id ,
                                            SVMXC__Company__c = account.Id , 
                                            SVMXC__Contact__c =contact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                            SVMXC__Order_Type__c='Field Service',
                                            SVMXC__Locked_By_DC__c = true
                                            );
         upsert svo;

        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 1'
                                            );
        insert team1;
        
        SVMXC__Territory__c ter1 = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert ter1;
        
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = team1.Id ,
                                            SVMXC__Service_Territory__c = ter1.Id
                                            );
        insert tech1;
        
        SVMXC__Dispatcher_Access__c dacc = new SVMXC__Dispatcher_Access__c (
                                            SVMXC__Service_Team__c = team1.Id,
                                            SVMXC__Dispatcher__c = u.Id 
                                            );
        insert dacc;
        
        Group  testgroupobjone=new Group (name='test one');
        insert testgroupobjone;
        GroupMember  testgroupmenberone=new GroupMember (GroupId=testgroupobjone.id,UserOrGroupId=usid);
       // insert testgroupmenberone;
        
         List<Event> EventList = new List<Event>();
      //Event e = new Event();
    //    e.Location ='test2';
      //  EventList.add(e);
        List<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new List<DCON_Configuration_WS.SVMX_StringMap>();
        test.starttest();
        List<String> WorkOrderIds = new List<String>();
        WorkOrderIds.add(svo.Id);
        system.assert(WorkOrderIds!=null);
        DCON_Work_Order_WS.DCON_Assign_Work_Order_To_MultiTech_WS(u.Id, WorkOrderIds, tech1.Id, NULL, EventList, true);
        DCON_Work_Order_WS.DCON_Assign_Work_Order_To_Team_WS(u.Id, WorkOrderIds, team1.Id, true);
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TECHNICIAN', 'TERRITORY,Name', 'ANY');
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TEAM', 'TERRITORY,Name', 'ALL');
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TECHNICIAN', 'EXPERTISE,Name', 'ANY');
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'a,iMore Than 30 days, Andy Young,United States, New, High, 1/28/2010 12:00 PM, SVO-000008', 'TEAM', 'PRODUCT,EXPERTISE,SVMXC__City__c', 'ALL');
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'a,i', 'TECHNICIAN', 'SVMXC__City__c,Name', 'ANY');        
        DCON_Work_Order_WS.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TECHNICIAN', 'PRODUCT,EXPERTISE,', 'ALL');
        
        DCON_Work_Order_WS.DCON_Retrieve_Views_WS(u.Id);
       // DCON_Work_Order_WS.DCON_Retrieve_Work_Orders_LatLng_WS(u.Id, WorkOrderIds);
       
        List<String> dispStatus = new List<String>();
        List<String> keyValPairs = new List<String>();
        dispStatus.add('NEW');
        keyValPairs.add('LRD|'+system.currentTimeMillis());
        
        //keyValPairs.add('LRD');
        List<String> dispStatus1 = new List<String>();
        dispStatus1.add('ASSIGNED');
        dispStatus1.add('QUEUED'); 
        DCON_Work_Order_WS.DCON_Retrieve_Delta_Work_Orders_WS(keyValPairs, u.Id, null, dispStatus, null, WorkOrderIds);
        DCON_Work_Order_WS.DCON_Retrieve_Delta_Work_Orders_WS(keyValPairs, u.Id, objSVMXPrcss.id, dispStatus, null, WorkOrderIds);
        DCON_Work_Order_WS.DCON_Retrieve_Delta_Work_Orders_WS(keyValPairs, u.Id, null, dispStatus1, null, WorkOrderIds);
        List<String> dispStatus2 = new List<String>();
        dispStatus2.add('NEW');
        dispStatus2.add('QUEUED'); 
        DCON_Work_Order_WS.DCON_Retrieve_Delta_Work_Orders_WS(keyValPairs, u.Id, null, dispStatus2, null, WorkOrderIds);
        List<String> dispStatus3 = new List<String>();
        dispStatus3.add('QUEUED');
        DCON_Work_Order_WS.DCON_Retrieve_Delta_Work_Orders_WS(keyValPairs, u.Id, null, dispStatus3, null, WorkOrderIds);
        
        //DCON_Work_Order_WS.workorder_WP();
        test.stoptest();
    }

    static testMethod void DCON_Work_Order_WS_UT_Test1()
    {
        DCON_Work_Order_WS obj = new DCON_Work_Order_WS();
        //Creae UT Datas
        String usid=UserInfo.getUserId();
        User u = [SELECT id from User where  id =: usid];
        Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        ); 
        insert account;
        

        Contact contact = new Contact(LastName='Last',AccountId =account.Id);
        insert contact;
        
        
        Case case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId =contact.Id,
                                        AccountId=account.Id                                         
                                        ); 
       //insert case1; 
        
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = case1.Id ,
                                            SVMXC__Company__c = account.Id , 
                                            SVMXC__Contact__c =contact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                            SVMXC__Order_Type__c='Field Service',
                                            SVMXC__Locked_By_DC__c = true
                                            );
         upsert svo;

        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 1'
                                            );
        insert team1;
        
        SVMXC__Territory__c ter1 = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert ter1;
        
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = team1.Id ,
                                            SVMXC__Service_Territory__c = ter1.Id,
                                            SVMXC__Salesforce_User__c  = u.Id
                                            );
        insert tech1;
        
        SVMXC__ServiceMax_Config_Data__c confdata1 = new SVMXC__ServiceMax_Config_Data__c (
                                            SVMXC__Configuration_Type__c  = 'Custom_View'
                                            );
        insert confdata1;
        
        SVMXC__Dispatcher_Access__c dacc = new SVMXC__Dispatcher_Access__c (
                                            SVMXC__Service_Team__c = team1.Id,
                                            SVMXC__Dispatcher__c = u.Id 
                                            );
        insert dacc;
        
        Group  testgroupobjone=new Group (name='test one');
        insert testgroupobjone;
        GroupMember  testgroupmenberone=new GroupMember (GroupId=testgroupobjone.id,UserOrGroupId=usid);
        
         List<Event> EventList = new List<Event>();
                
       test.starttest();
        List<String> WorkOrderIds = new List<String>();
        WorkOrderIds.add(svo.Id);
        system.assert(WorkOrderIds!=null);
        List<String> dispStatus = new List<String>();
        DCON_Work_Order_WS.DCON_Assign_Work_Order_To_MultiTech_WS(u.Id, WorkOrderIds, tech1.Id, NULL, EventList, true);
        DCON_Work_Order_WS.DCON_Assign_Work_Order_To_Team_WS(u.Id, WorkOrderIds, team1.Id, true);

        
        DCON_Work_Order_WS.DCON_Retrieve_Views_WS(u.Id);      
        DCON_Work_Order_WS.DCON_Retrieve_Work_Orders_WO_WS(u.Id, NULL, NULL);
        
        dispStatus.add('ALL');
        dispStatus.clear();
        dispStatus.add('NEW');
        dispStatus.add('QUEUED');
        dispStatus.add('ASSIGNED');
        WorkOrderIds.clear();
        WorkOrderIds.add(svo.Id);
        DCON_Work_Order_WS.DCON_Unschedule_Work_Order_WS(u.Id, WorkOrderIds);
        DCON_Work_Order_WS.DCON_Retrieve_Work_Orders_LatLng_WS(u.Id,WorkOrderIds);
        
        DCON_Work_Order_WS.DCON_Retrieve_Views_WS(usid);
        Date myDate = Date.Today();
        String sDate = String.valueOf(myDate); 
        
        DCON_Work_Order_WS DconWorkorder =new DCON_Work_Order_WS();
        DCON_Work_Order_WS.ValidateFieldType('','true');
        DCON_Work_Order_WS.ValidateFieldType('Schema.DisplayType.Date','2009-04-04');
        DCON_Work_Order_WS.ValidateFieldType('Schema.DisplayType.DateTime','2009-04-04 10:10:10');
        DCON_Work_Order_WS.ValidateFieldType('Schema.DisplayType.Time','10:10:10');
        DCON_Work_Order_WS.ValidateFieldType('Schema.DisplayType.Boolean','true');
        DCON_Work_Order_WS.ValidateFieldType('Schema.DisplayType.Currency','49.50');
        DCON_Work_Order_WS.DCON_Unschedule_Work_Order_WS(u.Id,WorkOrderIds);
        DCON_Work_Order_WS.DCON_RESET_WO_Time(WorkOrderIds);
        DCON_Work_Order_WS.DCON_Unassign_Work_Order_WS(u.Id,WorkOrderIds);
        DCON_Work_Order_WS.ExpertisevalidationClause('abc');
        List<String> dispstat = new  List<String>();
        dispstat.add('ALL');
        DCON_Work_Order_WS.DCON_Retrieve_Work_Orders(u.Id,null,dispstat,'Asia/Calcutta', WorkOrderIds,null);
        DCON_Work_Order_WS.DCON_Retrieve_Work_Orders_WO_WS(u.Id,'Asia/Calcutta', WorkOrderIds);
        Account objAccount = new Account(
                                        Name ='Account'  ); 
        insert objAccount;
        

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;
        
        
        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
             SVMXC__Service_Order__c   objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = objCase.Id ,
                                            SVMXC__Company__c = objAccount.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = tech1.Id
                                            );
        insert objWorkOrder;
         Event e1 = new Event();
        e1.ActivityDate = system.today();
        e1.StartDateTime =system.now();
        e1.endDateTime =system.now().addminutes(1);
        e1.ActivityDateTime = e1.StartDateTime;
        e1.Subject = 'test';
        e1.OwnerId = u.id; 
        e1.WhatId=objWorkOrder.Id;
        e1.Description='Test Desc';
    insert e1;
    list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new list<DCON_Configuration_WS.SVMX_StringMap>();
                lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
                lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
                lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));
                DCON_Configuration_WS.SVMX_StringMap datTest1 = new DCON_Configuration_WS.SVMX_StringMap('bb', 'DATE');
                datTest1.DateValue = system.today();
                datTest1.Value = 'DATE';
                lstKeyValue.add(datTest1);
                DCON_Work_Order_WS.workorder_WP obj1 = new DCON_Work_Order_WS.workorder_WP();
                
    DCON_Work_Order_WS.DCON_WO_MultiAssign_Request dcon_Request = new DCON_Work_Order_WS.DCON_WO_MultiAssign_Request();

    dcon_Request.workOrderIds.addall(WorkOrderIds);
    dcon_Request.technicianIds.add(string.valueof(tech1.id));
    dcon_Request.operationType = 'WO_UNASSIGN_NO';
    dcon_Request.timezone = 'Asia/Calcutta';
    dcon_Request.EventList.add(e1);
    dcon_Request.lstKeyValue.addall(lstKeyValue);
    try
    {

    DCON_Work_Order_WS.DCON_WO_MultiAssign_Response resp = DCON_Work_Order_WS.DCON_Manage_Work_Order_MultiAssign_WS(dcon_Request);
    }
    catch(exception e)
    {}
    dcon_Request.operationType = 'WO_UNASSIGN_YES';
    try
    {

    //DCON_Work_Order_WS.DCON_WO_MultiAssign_Response resp = DCON_Work_Order_WS.DCON_Manage_Work_Order_MultiAssign_WS(dcon_Request);
    }
    catch(exception e)
    {}
        test.stoptest();
    }
    
    static testMethod void DCON_Work_Order_WS_UT_Test2()
    {
         Account account = new Account(Name ='Account',ShippingStreet='ABC',ShippingCity='PQR',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ', BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
            insert account;
            

            Contact contact = new Contact(LastName='Last',AccountId =account.Id);
            insert contact;
            Case case1 = new Case(Status ='New', Priority = 'Medium', 
                                            Origin = 'Email',                                        
                                            ContactId =contact.Id,
                                            AccountId=account.Id                                         
                                            ); 
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                                SVMXC__Case__c = case1.Id ,
                                                SVMXC__Company__c = account.Id , 
                                                SVMXC__Contact__c =contact.Id, 
                                                SVMXC__Latitude__c = 40.739582 , 
                                                SVMXC__Longitude__c = -73.980772, 
                                                SVMXC__Order_Status__c = 'Open',
                                                SVMXC__Priority__c ='Medium',
                                                SVMXC__Order_Type__c='Field Service',
                                                SVMXC__Locked_By_DC__c = true,
                                                SVMXC__SM_Estimated_Duration__c = 100,
                                                SVMXC__SM_Scope_Change__c = 0,
                                                SVMXC__SM_Variance__c = 0,
                                                SVMXC__SM_Scheduled_Duration__c = 20,
                                                SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 4
                                                );
        upsert svo;
        List<String> WorkOrderIds = new List<String>();
        WorkOrderIds.add(svo.Id);
        List<String> keyValPairs = new List<String>();
        
        keyValPairs.add('LRD|'+system.currentTimeMillis());
        List<String> dispStatus4 = new List<String>();
        dispStatus4.add('ASSIGNED');
        DCON_Work_Order_WS.DCON_Retrieve_Delta_Work_Orders_WS(keyValPairs,UserInfo.getUserId(), null, dispStatus4, null, WorkOrderIds);
        List<String> dispStatus5 = new List<String>();
        dispStatus5.add('ASSIGNED');
        dispStatus5.add('NEW');
        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                                Name = 'TEAM 1'
                                                );
            insert team1;
            SVMXC__Territory__c ter1 = new SVMXC__Territory__c (
                                                Name = 'TERRITORY 1'
                                                );
            insert ter1;
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                                Name = 'TECH 1' ,
                                                SVMXC__Latitude__c = 40.739582 , 
                                                SVMXC__Longitude__c = -73.980772, 
                                                SVMXC__Service_Group__c = team1.Id ,
                                                SVMXC__Service_Territory__c = ter1.Id
                                                );
            insert tech1;
        DCON_Work_Order_WS.DCON_Retrieve_Delta_Work_Orders_WS(keyValPairs,UserInfo.getUserId(), null, dispStatus5, null, WorkOrderIds);
        List<Event> EventList = new List<Event>();
        Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                        StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                        ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                        DurationInMinutes = 60, Subject = 'test', OwnerId = UserInfo.getUserId(), 
                                        WhatId=svo.Id, Description='Test Desc');
        Eventlist.add(e1);
        List<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new List<DCON_Configuration_WS.SVMX_StringMap>();
        RecordType RTProcess = [select Id from RecordType where Name = 'View Definition' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RTCfgDta = [select Id from RecordType where Name = 'View Access' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
            
            
            List<String> dispStatus = new List<String>();
        //dispStatus.add('ALL');
        dispStatus.add('NEW');
        dispStatus.add('QUEUED');
        dispStatus.add('ASSIGNED');
        try{
        DCON_Work_Order_WS.DCON_Retrieve_AllWorkOrder_Ids_WS(keyValPairs,UserInfo.getUserId(), '', dispStatus, 'Asia/Calcutta');}
        catch(exception e){}
        try{
        DCON_Work_Order_WS.DCON_Retrieve_Work_Orders_WS2(keyValPairs,UserInfo.getUserId(),'', dispStatus, 'Asia/Calcutta', WorkOrderIds);}
        catch(exception e){}
        
        DCON_Work_Order_WS.DCON_Retrieve_Work_Orders_WS(UserInfo.getUserId(), null, dispStatus, 'Asia/Calcutta', WorkOrderIds);
        DCON_Work_Order_WS.DCON_Retrieve_Eliminated_Work_Order_Info(UserInfo.getUserId(), 'Asia/Calcutta', WorkOrderIds);
        DCON_Work_Order_WS.DCON_Retrieve_Work_Order_Info();
        DCON_Work_Order_WS.DCON_Retrieve_Work_Order_EventHover(svo.Id);
        
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('IDLE_' + svo.Id, '10'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('DRIVE_' + svo.Id, '10'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('SERVICE_' + svo.Id, '10'));
        DCON_Configuration_WS.SVMX_StringMap datTest1 = new DCON_Configuration_WS.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCON_Configuration_WS.SVMX_StringMap datTest2 = new DCON_Configuration_WS.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2);
        /* Yatheesh commented this code and placed in a new method DCON_Work_Order_WS_UT_Test3       
        String temp = DCON_Work_Order_WS.getDefaultUserSettings();
        Set<String> tempSet = DCON_Work_Order_WS.getFieldUpdates();
        
        Set<String> setWorkOrderFields =  new Set<String>();
        setWorkOrderFields.add('SVMXC__Latitude__c');
        setWorkOrderFields.add('SVMXC__Longitude__c');
        setWorkOrderFields.add('SVMXC__Order_Status__c');
        setWorkOrderFields.add('SVMXC__Order_Type__c');
        setWorkOrderFields.add('SVMXC__Locked_By_DC__c');
        
        DCON_Work_Order_WS.workorder_WP tempStruct = DCON_Work_Order_WS.getFieldUpdateWrapper(setWorkOrderFields, WorkOrderIds);
        
        try {
            DCON_Work_Order_WS.DCON_UnAssignAssign_Work_Order_To_MultiTech_WS2(UserInfo.getUserId(), WorkOrderIds, tech1.Id, 'Asia/Calcutta', EventList, true, lstKeyValue);
        }
        catch(exception e)
        {}*/
    }
    
    static testMethod void DCON_Work_Order_WS_UT_Test3()
    {
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                                SVMXC__Latitude__c = 40.739582 , 
                                                SVMXC__Longitude__c = -73.980772, 
                                                SVMXC__Order_Status__c = 'Open',
                                                SVMXC__Priority__c ='Medium',
                                                SVMXC__Order_Type__c='Field Service',
                                                SVMXC__Locked_By_DC__c = true,
                                                SVMXC__SM_Estimated_Duration__c = 100,
                                                SVMXC__SM_Scope_Change__c = 0,
                                                SVMXC__SM_Variance__c = 0,
                                                SVMXC__SM_Scheduled_Duration__c = 20,
                                                SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 4
                                                );
        upsert svo;
        List<String> WorkOrderIds = new List<String>();
        WorkOrderIds.add(svo.Id);
        List<String> keyValPairs = new List<String>();
        
        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                                Name = 'TEAM 1'
                                                );
        insert team1;

        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                                Name = 'TECH 1' ,
                                                SVMXC__Latitude__c = 40.739582 , 
                                                SVMXC__Longitude__c = -73.980772, 
                                                SVMXC__Service_Group__c = team1.Id
                                                );
        insert tech1;

        List<Event> EventList = new List<Event>();
        Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                        StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                        ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                        DurationInMinutes = 60, Subject = 'test', OwnerId = UserInfo.getUserId(), 
                                        WhatId=svo.Id, Description='Test Desc');
        Eventlist.add(e1);
        List<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new List<DCON_Configuration_WS.SVMX_StringMap>();

        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('IDLE_' + svo.Id, '10'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('DRIVE_' + svo.Id, '10'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('SERVICE_' + svo.Id, '10'));
        DCON_Configuration_WS.SVMX_StringMap datTest1 = new DCON_Configuration_WS.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCON_Configuration_WS.SVMX_StringMap datTest2 = new DCON_Configuration_WS.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2);
               
        String temp = DCON_Work_Order_WS.getDefaultUserSettings();
        Set<String> tempSet = DCON_Work_Order_WS.getFieldUpdates();
        
        Set<String> setWorkOrderFields =  new Set<String>();
        setWorkOrderFields.add('SVMXC__Latitude__c');
        setWorkOrderFields.add('SVMXC__Longitude__c');
        setWorkOrderFields.add('SVMXC__Order_Status__c');
        setWorkOrderFields.add('SVMXC__Order_Type__c');
        setWorkOrderFields.add('SVMXC__Locked_By_DC__c');
        
        DCON_Work_Order_WS.workorder_WP tempStruct = DCON_Work_Order_WS.getFieldUpdateWrapper(setWorkOrderFields, WorkOrderIds);
        
        try {
            DCON_Work_Order_WS.DCON_UnAssignAssign_Work_Order_To_MultiTech_WS2(UserInfo.getUserId(), WorkOrderIds, tech1.Id, 'Asia/Calcutta', EventList, true, lstKeyValue);
        }
        catch(exception e)
        {}
    }
    
    static testMethod void DCON_AES_Unassign_WO_WS_UT1()
    {
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                                        SVMXC__Latitude__c = 40.739582 , 
                                                        SVMXC__Longitude__c = -73.980772, 
                                                        SVMXC__Order_Status__c = 'Open',
                                                        SVMXC__Priority__c ='Medium',
                                                        SVMXC__Order_Type__c='Field Service',
                                                        SVMXC__Locked_By_DC__c = true,
                                                        SVMXC__SM_Estimated_Duration__c = 100,
                                                        SVMXC__SM_Scope_Change__c = 0,
                                                        SVMXC__SM_Variance__c = 0,
                                                        SVMXC__SM_Scheduled_Duration__c = 20,
                                                        SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 4
                                                    );
        insert svo;
        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                                Name = 'TEAM 1'
                                                );
        insert team1;

        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = team1.Id
                                            );
        insert tech1;
        
        Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                            StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                            ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                            DurationInMinutes = 60, Subject = 'test', OwnerId = tech1.Id, 
                            WhatId=svo.Id, Description='Test Desc');
                                        
        //DateTime dt;
        DCON_Work_Order_WS.DCTech_WO_WP objWoWp = new DCON_Work_Order_WS.DCTech_WO_WP(svo.Id, tech1.Id, '', false, 'Asia/Kolkata');
        try {   
        //Delete event for a given technician Id and woId
        DCON_Work_Order_WS.DCTech_WO_Response_WP statusTmp = new DCON_Work_Order_WS.DCTech_WO_Response_WP();
        statusTmp = DCON_Work_Order_WS.DCON_AES_Unassign_WO_WS(objWoWp);
        }
        catch(exception e) {}
    }
    
    static testMethod void DCON_AES_Unassign_WO_WS_UT2()
    {
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                                        SVMXC__Latitude__c = 40.739582 , 
                                                        SVMXC__Longitude__c = -73.980772, 
                                                        SVMXC__Order_Status__c = 'Open',
                                                        SVMXC__Priority__c ='Medium',
                                                        SVMXC__Order_Type__c='Field Service',
                                                        SVMXC__Locked_By_DC__c = true,
                                                        SVMXC__SM_Estimated_Duration__c = 100,
                                                        SVMXC__SM_Scope_Change__c = 0,
                                                        SVMXC__SM_Variance__c = 0,
                                                        SVMXC__SM_Scheduled_Duration__c = 20,
                                                        SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 4,
                                                        SVMXC__SM_Scheduling_Options__c = 'JDM and LJS Enabled'
                                                    );
        insert svo;
        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                                Name = 'TEAM 1'
                                                );
        insert team1;

        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = team1.Id
                                            );
        insert tech1;
        
        Event e1 = new Event(ActivityDate = Date.valueOf('2016-06-11 00:00:00'),
                            StartDateTime = Datetime.valueOf('2016-06-11 01:00:00') ,
                            ActivityDateTime = Datetime.valueOf('2016-06-11 01:00:00'), 
                            DurationInMinutes = 60, Subject = 'test', OwnerId = tech1.Id, 
                            WhatId=svo.Id, Description='Test Desc');
                                        
        DCON_Work_Order_WS.DCTech_WO_WP objWoWp = new DCON_Work_Order_WS.DCTech_WO_WP(svo.Id, tech1.Id, tech1.Id, false,  'Asia/Kolkata');
        try {   
        //Delete event for a given technician Id
        DCON_Work_Order_WS.DCTech_WO_Response_WP statusTmp = new DCON_Work_Order_WS.DCTech_WO_Response_WP();
        statusTmp = DCON_Work_Order_WS.DCON_AES_Unassign_WO_WS(objWoWp);
        }
        catch(exception e) {}
    }
    
    static testMethod void DCON_Unassign_WO_UT1()
    {
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                                        SVMXC__Latitude__c = 40.739582 , 
                                                        SVMXC__Longitude__c = -73.980772, 
                                                        SVMXC__Order_Status__c = 'Open',
                                                        SVMXC__Priority__c ='Medium',
                                                        SVMXC__Order_Type__c='Field Service',
                                                        SVMXC__Locked_By_DC__c = true,
                                                        SVMXC__SM_Estimated_Duration__c = 100,
                                                        SVMXC__SM_Scope_Change__c = 0,
                                                        SVMXC__SM_Variance__c = 0,
                                                        SVMXC__SM_Scheduled_Duration__c = 20,
                                                        SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 4,
                                                        SVMXC__SM_Scheduling_Options__c = 'JDM and LJS Enabled'
                                                    );
        insert svo;
        
        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                                Name = 'TEAM 1'
                                                );
        insert team1;

        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = team1.Id
                                            );
        insert tech1;
        
        SVMXC__SVMX_Event__c e1 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2016-06-11 00:00:00'),
                            SVMXC__StartDateTime__c = Date.valueOf('2016-06-11 01:00:00'),
                            SVMXC__ActivityDateTime__c = Date.valueOf('2016-06-11 00:00:00'), 
                            SVMXC__DurationInMinutes__c = 60, SVMXC__Technician__c = tech1.Id, 
                            SVMXC__WhatId__c=svo.Id);
        insert e1;
        
        DCON_Work_Order_WS.DCTech_WO_WP objWoWp = new DCON_Work_Order_WS.DCTech_WO_WP(svo.Id, tech1.Id, tech1.Id, true, e1.SVMXC__StartDateTime__c, 'Asia/Kolkata','',false,e1.id,true);
        
        try 
        {   
            //Unassign WO if events are not existing for a given WO
            DCON_Work_Order_WS.DCON_Unassign_WO(objWoWp);
        }
        catch(exception e) {}
    }
    
    static testMethod void DCON_Unassign_WO_UT2()
    {
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                                        SVMXC__Latitude__c = 40.739582 , 
                                                        SVMXC__Longitude__c = -73.980772, 
                                                        SVMXC__Order_Status__c = 'Open',
                                                        SVMXC__Priority__c ='Medium',
                                                        SVMXC__Order_Type__c='Field Service',
                                                        SVMXC__Locked_By_DC__c = true,
                                                        SVMXC__SM_Estimated_Duration__c = 100,
                                                        SVMXC__SM_Scope_Change__c = 0,
                                                        SVMXC__SM_Variance__c = 0,
                                                        SVMXC__SM_Scheduled_Duration__c = 20,
                                                        SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 4,
                                                        SVMXC__SM_Scheduling_Options__c = 'JDM and LJS Enabled'
                                                    );
        insert svo;
        
        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                                Name = 'TEAM 1'
                                                );
        insert team1;

        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = team1.Id
                                            );
        insert tech1;
        
        DateTime dt;
        DCON_Work_Order_WS.DCTech_WO_WP objWoWp = new DCON_Work_Order_WS.DCTech_WO_WP(svo.Id, tech1.Id, tech1.Id, false, dt, 'Asia/Kolkata','',false);
        
        try 
        {   
            //Unassign WO if events are not existing for a given WO
            DCON_Work_Order_WS.DCON_Unassign_WO(objWoWp);
        }
        catch(exception e) {}
    }
}