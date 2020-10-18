@isTest
Private class DCON_Service_Org_WS_UT {
    static testMethod void DCON_Service_Org_WS_UT_Test()  //Technician_WP DCON_Retrieve_Team_Tree_WS SVMXC__Dispatcher_Access__c
    {
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        List<String> ServiceTeam = new List<String>();
        List<String> Territory = new List<String>();
        List<String> TechList = new List<String>();
        
        SVMXC__Service_Group__c SerTeam = new SVMXC__Service_Group__c();
        SerTeam.Name='TeamABC';
        Upsert SerTeam;
        List<BusinessHours> lstdefaultbh = [SELECT FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE IsDefault = true];
        BusinessHours defaultbh = lstdefaultbh.get(0);  
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1', SVMXC__Territory_s_Business_Hours__c = defaultbh.Id
                                            );
        insert objTerritory;
        List<SVMXC__Service_Group_Members__c> TechList123 = new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c Tech1 = new SVMXC__Service_Group_Members__c();
        Tech1.Name='Tech1';
        Tech1.SVMXC__Service_Group__c=SerTeam.Id;
        Tech1.SVMXC__Enable_Scheduling__c=true;
        //
        Tech1.SVMXC__Salesforce_User__c = u.Id;
        Tech1.SVMXC__Active__c = true;
        //
        SVMXC__Service_Group_Members__c Tech2 = new SVMXC__Service_Group_Members__c();
        Tech2.Name='Tech2';
        Tech2.SVMXC__Service_Group__c=SerTeam.Id;
        Tech2.SVMXC__Enable_Scheduling__c=true;
        //
        Tech2.SVMXC__Salesforce_User__c = u.Id;
        Tech2.SVMXC__Active__c = true;
        //
        Tech2.SVMXC__Working_Hours__c = defaultbh.Id;
        Tech2.SVMXC__Break_Hours__c = defaultbh.Id;
        //
        SVMXC__Service_Group_Members__c Tech3 = new SVMXC__Service_Group_Members__c();
        Tech3.Name='Tech3';
        Tech3.SVMXC__Service_Group__c=SerTeam.Id;
        Tech3.SVMXC__Enable_Scheduling__c=true;
        Tech3.SVMXC__Salesforce_User__c = u.Id;
        Tech3.SVMXC__Active__c = true;
        Tech3.SVMXC__Service_Territory__c = objTerritory.Id;
        //
        TechList123.add(Tech1);
        TechList123.add(Tech2);
        TechList123.add(Tech3);
        upsert TechList123;
        for(SVMXC__Service_Group_Members__c p : TechList123)
        {
            TechList.add(p.Id);
        }
        
        
        SVMXC__Service_Group_Site__c SrvcGrpSit = new SVMXC__Service_Group_Site__c();
        SrvcGrpSit.SVMXC__Latitude__c = 45;
        SrvcGrpSit.SVMXC__Longitude__c = 78;
        SrvcGrpSit.SVMXC__IsCurrent__c = true;
        //insert SrvcGrpSit;
        
        String keyValPairs='LRD|'+System.now();
        
        test.starttest();
        system.assert(u.Id!=null);
        DCON_Service_Org_WS.DCON_Retrieve_Team_Tree_WS(u.Id, true); 
        DCON_Service_Org_WS.DCON_Retrieve_Team_Tree_WS(u.Id, false); 
        DCON_Service_Org_WS.DCON_Retrieve_Team_Tree_WS1(u.Id); 
        /*
        SVMXC__Dispatcher_Access__c objDispatcher = new SVMXC__Dispatcher_Access__c();
        objDispatcher.SVMXC__Service_Team__c = 'abc';
        objDispatcher.SVMXC__Dispatcher__c = u.Id;
        insert objDispatcher;
        DCON_Service_Org_WS.DCON_Retrieve_Team_Tree_WS(u.Id, true);
        */
        DCON_Service_Org_WS.DCON_Retrieve_TechnicianInfo_Tree_WS(keyValPairs,TechList,u.Id);
        
        List<DCON_Service_Org_WS.Technician_WP> tech = DCON_Service_Org_WS.DCON_Retrieve_Technician_Tree_WS(u.Id, 'TERRITORY', true, NULL,Territory);
        DCON_Service_Org_WS.DCON_Retrieve_Technician_Tree_WS(u.Id, 'TEAM', true, NULL,ServiceTeam);
        
        DCON_Service_Org_WS.DCON_Retrieve_Territory_Tree_WS(u.Id, true);
        
        SVMXC__Service_Group_Members__c testTechClassTO = new SVMXC__Service_Group_Members__c();
        SVMXC__Service_Group_Site__c testTechHBClassTO = new SVMXC__Service_Group_Site__c(); 
        List<DCON_Service_Org_WS.TechnicianSpecialFields_WP> testTechClassSPL;
        if(tech.size() > 0)
        {
            for(DCON_Service_Org_WS.Technician_WP t: tech){
                testTechClassTO = t.technician_O;
                testTechHBClassTO = t.location_O;
                testTechClassSPL = t.specialFields_LWP;
            }
        } 
        DCON_Service_Org_WS.Technician_WP testTechClass = new DCON_Service_Org_WS.Technician_WP(testTechClassTO,testTechHBClassTO,testTechClassSPL);
        testTechClass.gethoverInfo();
        testTechClass.sethoverInfo();
        DCON_Service_Org_WS.TechnicianSpecialFields_WP tspl= new DCON_Service_Org_WS.TechnicianSpecialFields_WP('T1','T1');
        DCON_Service_Org_WS.Address add= new DCON_Service_Org_WS.Address();
        DCON_Service_Org_WS.Tech_WorkingHours tech_workinghrs = DCON_Service_Org_WS.DCON_Retrieve_Tech_WorkingHrs_WS(TechList,null,null);
        
        test.stoptest();
    }
}