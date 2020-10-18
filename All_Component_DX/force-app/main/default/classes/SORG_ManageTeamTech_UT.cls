@isTest(SeeAllData=true)
Private class SORG_ManageTeamTech_UT {
    static testMethod void Manage_TeamTechUnitTest() {
        SORG_ManageTeamTech objTeamTech = new SORG_ManageTeamTech();

        objTeamTech.SVMX_AddnewTeam();
        objTeamTech.objTeam.Name = 'team1';
        objTeamTech.SVMX_SaveTeam();
        objTeamTech.loadTeam();
        objTeamTech.SVMX_EditTeamTech();
        objTeamTech.SVMX_SaveTeam();
        
        objTeamTech.setKeyword('None');
        objTeamTech.SVMX_AdvTeamSearch();
        objTeamTech.setShowOnlySel('1');
        objTeamTech.SVMX_AdvTeamSearch();
        objTeamTech.setPrdctSearch(true);
        objTeamTech.setExptSearch(true);
        objTeamTech.SVMX_AdvTeamSearch();
        objTeamTech.SVMX_Reset();

        objTeamTech.getUserLocaleKey();
        objTeamTech.getUserID();
        objTeamTech.getUserOrgID();
        objTeamTech.getXMLResult();
        objTeamTech.setXMLResult('');
        objTeamTech.getExptSearch();
        objTeamTech.getPrdctSearch();
        objTeamTech.getRenderAllTabs();
        objTeamTech.setRenderAllTabs(true);
        objTeamTech.getSearchClicked();
        objTeamTech.setSearchClicked(true);
        objTeamTech.getDisableButtons();
        objTeamTech.setDisableButtons(true);
        objTeamTech.getRenderDispatchTab();
        objTeamTech.setRenderDispatchTab(true);
        objTeamTech.getdisplayResetBtn();
        objTeamTech.getEnableScheduling();
        objTeamTech.setEnableScheduling(true);
        objTeamTech.getEnableAutoCheckBox();
        objTeamTech.setEnableAutoCheckBox(true);
        objTeamTech.getCreateAutoLoc();
        objTeamTech.setCreateAutoLoc(true);
        objTeamTech.getrenderBreakDuration();
        objTeamTech.setrenderBreakDuration(true);
        objTeamTech.getTeamTechExist();
        objTeamTech.setTeamTechExist(true);
        objTeamTech.getCheckAllExprt();
        objTeamTech.getCheckAllPrdct();
        objTeamTech.getCheckAllCost();
        objTeamTech.getCheckAllDisp();
        objTeamTech.getCheckAllHmeBase();
        objTeamTech.setCheckAllExprt(true);
        objTeamTech.setCheckAllPrdct(true);
        objTeamTech.setCheckAllCost(true);
        objTeamTech.setCheckAllDisp(true);
        objTeamTech.setCheckAllHmeBase(true);
        objTeamTech.getTeamId();
        objTeamTech.setTeamId('');
        objTeamTech.getShowOnlySel();
        objTeamTech.getgoogleUrl();
        objTeamTech.getConfirmMesg();
        objTeamTech.setConfirmMesg('');
        objTeamTech.getRecTypeName();
        objTeamTech.setRecTypeName(null);
        objTeamTech.getGroupType();
        objTeamTech.setGroupType('Internal');
        objTeamTech.getRole();
        objTeamTech.setRole('Consultant');
        objTeamTech.getBreakTyp();
        objTeamTech.setBreakTyp('Time Window');
        objTeamTech.getlongitude();
        double tt=33.888;
        objTeamTech.setlongitude(tt);
        objTeamTech.getlatitude();
        double lat = 11.65;
        objTeamTech.setlatitude(lat);
        objTeamTech.getlstlongitude();
        objTeamTech.setlstlongitude('0~33.888,1~33.999');
        objTeamTech.getlstlatitude();
        objTeamTech.setlstlatitude('0~11.65,1~11.55');
        objTeamTech.getSpeed();
        objTeamTech.setSpeed('');
        objTeamTech.getDistance();
        objTeamTech.setDistance('');
        objTeamTech.getCost();
        objTeamTech.setCost('');
        objTeamTech.getDisplayTopBlockLevelMessage();
        objTeamTech.getDisplayBotBlockLevelMessage();
        objTeamTech.getDisplayPPLevelMessage();
        objTeamTech.getTeam();
        objTeamTech.getTech();
        objTeamTech.geteditmode();
        objTeamTech.seteditmode(true);
        objTeamTech.getTechEditMode();
        objTeamTech.setTechEditMode(true);
        objTeamTech.getdisplayTeamPopup();
        objTeamTech.getdisplayTechPopup();
        objTeamTech.getHomeBaseTab();
        objTeamTech.setHomeBaseTab(true);
        objTeamTech.getaddline();
        objTeamTech.setaddline(1);
        objTeamTech.getAddrsError();
        objTeamTech.setAddrsError(false);
        objTeamTech.getExprtList();
        objTeamTech.getprodList();
        objTeamTech.getLaborCostList();
        objTeamTech.getHomeBaseList();
        objTeamTech.getDsptchrList();
        objTeamTech.getUserList();
        objTeamTech.getPrdcts();
        objTeamTech.getSkillList();
        objTeamTech.getHomeBaseObj();
        objTeamTech.getKeyword();
        objTeamTech.getDispKywrd();
        objTeamTech.getExprtKywrd();
        objTeamTech.getPrdctKywrd();
        objTeamTech.getTeamRecType();      
        objTeamTech.TeamPopUpCancel();
        objTeamTech.TechPopUpCancel();
        objTeamTech.DisableAutoChkbox();
        objTeamTech.SkillSearchCancel();
        objTeamTech.PrdctSearchCancel(); 
        objTeamTech.showBreakDuration();
        objTeamTech.showEnableScheduling();
        objTeamTech.SVMX_GoSetupHome();
        objTeamTech.UserSearchCancel();
        
        
        //-------- Translation Get Methods Block Starts
        objTeamTech.getHLPURL();
        objTeamTech.getGBL001();
        objTeamTech.getGBL006();
        objTeamTech.getGBL011();
        objTeamTech.getTAG001();   
        objTeamTech.getTAG002();
        objTeamTech.getTAG003();
        objTeamTech.getTAG004(); 
        objTeamTech.getTAG005();
        objTeamTech.getTAG006();
        objTeamTech.getTAG007();
        objTeamTech.getTAG008();
        objTeamTech.getTAG009();
        objTeamTech.getTAG010();
        objTeamTech.getTAG011();
        objTeamTech.getTAG012();
        objTeamTech.getTAG013();
        objTeamTech.getTAG014();
        objTeamTech.getTAG015();
        objTeamTech.getTAG016();
        objTeamTech.getTAG017();
        objTeamTech.getTAG018();
        objTeamTech.getTAG019();
        objTeamTech.getTAG020();
        objTeamTech.getTAG021();
        objTeamTech.getTAG022();
        objTeamTech.getTAG023();
        objTeamTech.getTAG024();
        objTeamTech.getTAG025();
        objTeamTech.getTAG026();
        objTeamTech.getTAG027();
        objTeamTech.getTAG028();
        objTeamTech.getTAG029();
        objTeamTech.getTAG030();
        objTeamTech.getTAG031();
        objTeamTech.getTAG032();
        objTeamTech.getTAG033();
        objTeamTech.getTAG034();
        objTeamTech.getTAG035();
        objTeamTech.getTAG036();
        objTeamTech.getTAG037();
        objTeamTech.getTAG038();
        objTeamTech.getTAG039();
        objTeamTech.getTAG040();
        objTeamTech.getTAG041();
        objTeamTech.getTAG042();
        objTeamTech.getTAG043();
        objTeamTech.getTAG044();
        objTeamTech.getTAG045();
        objTeamTech.getTAG046();
        objTeamTech.getTAG047();
        objTeamTech.getTAG048();
        objTeamTech.getTAG051();
        objTeamTech.getTAG052();
        objTeamTech.getTAG053();
        objTeamTech.getTAG054();
        objTeamTech.getTAG055();
        objTeamTech.getTAG057();
        objTeamTech.getTAG058();
        objTeamTech.getTAG059();
        objTeamTech.getTAG060();
        objTeamTech.getTAG061();
        objTeamTech.getTAG062();
        objTeamTech.getTAG063();
        objTeamTech.getTAG064();
        objTeamTech.getTAG065();
        objTeamTech.getTAG066();
        objTeamTech.getTAG067();
        objTeamTech.getTAG068();
        objTeamTech.getTAG070();
        objTeamTech.getTAG071();
        objTeamTech.getTAG072();
        objTeamTech.getTAG073();
        objTeamTech.getTAG074();
        objTeamTech.getTAG075();
        objTeamTech.getTAG076();
        objTeamTech.getTAG077();
        objTeamTech.getTAG078();
        objTeamTech.getTAG079();
        objTeamTech.getTAG080();
        objTeamTech.getTAG082();
        objTeamTech.getTAG083();
        objTeamTech.getTAG084();
        objTeamTech.getTAG085();
        objTeamTech.getTAG086();
        objTeamTech.getTAG087();
        objTeamTech.getTAG088();
        objTeamTech.getTAG089();
        objTeamTech.getTAG090();
        objTeamTech.getTAG091();
        objTeamTech.getTAG092();
        objTeamTech.getTAG093();
        objTeamTech.getTAG094();
        objTeamTech.getTAG095();
        objTeamTech.getTAG096();
        objTeamTech.getTAG097();
        objTeamTech.getTAG098();
        objTeamTech.getTAG099();
        objTeamTech.getTAG100();
        objTeamTech.getTAG101();
        objTeamTech.getTAG102();
        objTeamTech.getTAG103();
        objTeamTech.getTAG104();
        objTeamTech.getTAG105();
        objTeamTech.getTAG106();
        objTeamTech.getTAG107();
        objTeamTech.getTAG108();
        objTeamTech.getTAG109();
        objTeamTech.getTAG113();
        objTeamTech.getTAG114();
        objTeamTech.getTAG115();
        objTeamTech.getTAG116();
        objTeamTech.getTAG117();
        objTeamTech.getTAG118();
        objTeamTech.getTAG119();
        objTeamTech.getTAG120();
        objTeamTech.getTAG121();
        objTeamTech.getTAG122();
        objTeamTech.getTAG123();
        objTeamTech.getTAG124();
        objTeamTech.getTAG125();
        objTeamTech.getTAG126();
        objTeamTech.getTAG127();
        objTeamTech.getTAG134();
        objTeamTech.getTAG135();
        objTeamTech.getTAG136();
        objTeamTech.getTAG137();
        objTeamTech.getTAG138();
        objTeamTech.getTAG139();
        objTeamTech.getTAG144();
        objTeamTech.getTAG145();
        objTeamTech.getTAG146();
        objTeamTech.getTAG147();
        objTeamTech.getTAG148();
        objTeamTech.getTAG149();
        objTeamTech.getTAG150();       
        objTeamTech.getTAG151();
        objTeamTech.getTAG152();
        objTeamTech.getTAG153();
        objTeamTech.getTAG154();
        objTeamTech.getTAG155();
        objTeamTech.getTAG156();       
        objTeamTech.getTAG157();
        objTeamTech.getTAG159(); 
        objTeamTech.getTAG160();
        objTeamTech.getTAG161();
        objTeamTech.getTAG164();
        objTeamTech.getTAG165();
        objTeamTech.getTAG166();
        objTeamTech.getTAG167();
        objTeamTech.getTAG168();
        objTeamTech.getTAG169(); 
        objTeamTech.getTAG170();
        objTeamTech.getTAG171();
        objTeamTech.getTAG172();
        objTeamTech.getTAG173();
    }
    
    static testMethod void Manage_TeamTechUnitTest1() {
        SORG_ManageTeamTech objTeamTech = new SORG_ManageTeamTech();
        
        objTeamTech.SVMX_AddnewTeam();
        objTeamTech.objTeam.Name = 'team2';
        objTeamTech.SVMX_SaveTeam();
        objTeamTech.loadTeam();
        
        objTeamTech.SVMX_AddExprt();
        objTeamTech.SVMX_AddPrdct();
        objTeamTech.SVMX_AddnewCostRec();
        objTeamTech.SVMX_AddDisptacher();
        
        SVMXC__Skill__c skill = new SVMXC__Skill__c(Name='TestSkill',SVMXC__Active__c =true, SVMXC__Select__c=true);
        Product2 prod =new Product2 (Name ='SLA: Silver',ProductCode='Prod',SVMXC__Inherit_Parent_Warranty__c =True, SVMXC__Select__c=true);
        insert skill;
        insert prod;
        
        objTeamTech.lstGroupExpertise[0].SVMXC__Skill__c = skill.Id;
        objTeamTech.lstExpertiseSkill.add(skill);
        objTeamTech.SVMX_AddSkilltoExpertise();
        
        objTeamTech.lstGroupProduct[0].SVMXC__Product__c = prod.Id;
        objTeamTech.lstExpertiseProduct.add(prod); 
        objTeamTech.SVMX_AddPrdcttoSrvcPrdct();
        
        User currUser = [select Id,Name,SVMXC__Select__c from User where Id=:UserInfo.getUserId()];
        currUser.SVMXC__Select__c = true;
        objTeamTech.lstGroupDispatcher[0].SVMXC__Dispatcher__c = currUser.Id;
        objTeamTech.lstUser.add(currUser);
        objTeamTech.SVMX_AddUsertoDispatch();
        
        objTeamTech.lstLaborCost[0].SVMXC__Hourly_Cost2__c =1;
        objTeamTech.lstLaborCost[0].SVMXC__Billable_Cost2__c =1;
        
        objTeamTech.SVMX_SaveExptToTeam();
        objTeamTech.SVMX_SaveProdToTeam();
        objTeamTech.SVMX_SaveCostToTeam();
        objTeamTech.SVMX_SaveDispToTeam();
        
        objTeamTech.setExprtKywrd('TestSkill');
        objTeamTech.SVMX_ExprtSearch();
        
        objTeamTech.setPrdctKywrd('SLA: Silver');
        objTeamTech.SVMX_PrdctSearch();
        
        objTeamTech.setDispKywrd(currUser.Name);
        objTeamTech.SVMX_DispatchSearch();
        
        objTeamTech.lstGroupExpertise[0].SVMXC__Select__c = true;
        objTeamTech.lstGroupProduct[0].SVMXC__Select__c= true;
        objTeamTech.lstLaborCost[0].SVMXC__Select__c= true;
        objTeamTech.lstGroupDispatcher[0].SVMXC__Select__c= true;
        
        objTeamTech.SVMX_DelExprt();
        objTeamTech.SVMX_DelPrdct();
        objTeamTech.SVMX_DelCostRec();
        objTeamTech.SVMX_DelDisptch();
        objTeamTech.SVMX_DelTeamTechwithChild();
    }
    
    static testMethod void Manage_TeamTechUnitTest2() {
        SORG_ManageTeamTech objTeamTech = new SORG_ManageTeamTech();
        
        objTeamTech.SVMX_AddnewTeam();
        objTeamTech.objTeam.Name = 'team3';
        objTeamTech.SVMX_SaveTeam();
        objTeamTech.loadTeam();
        
        objTeamTech.SVMX_AddnewTech();
        objTeamTech.objTech.Name = 'tech1';
        //Added on 22/07/15
        objTeamTech.objTech.Salesforce_User__c = userinfo.getUserId();
        objTeamTech.showEnableScheduling();
        objTeamTech.SVMX_SaveTech();
        objTeamTech.loadTeam();

        objTeamTech.SVMX_AddnewCostRec();
        objTeamTech.SVMX_AddHomeBase();
        
        SVMXC__Skill__c skill = new SVMXC__Skill__c(Name='TestSkill',SVMXC__Active__c =true, SVMXC__Select__c=true);
        Product2 prod =new Product2 (Name ='SLA: Silver',ProductCode='Prod',SVMXC__Inherit_Parent_Warranty__c =True, SVMXC__Select__c=true);
         
        objTeamTech.lstExpertiseSkill.add(skill);
        objTeamTech.SVMX_AddSkilltoExpertise();

        objTeamTech.lstExpertiseProduct.add(prod); 
        objTeamTech.SVMX_AddPrdcttoSrvcPrdct();
        
        objTeamTech.SVMX_SaveExptToTeam();
        objTeamTech.SVMX_SaveProdToTeam();
        objTeamTech.SVMX_SaveCostToTeam();
        objTeamTech.SVMX_SaveHomeBase();
        
        objTeamTech.SVMX_DelExprt();
        objTeamTech.SVMX_DelPrdct();
        objTeamTech.SVMX_DelCostRec();
        objTeamTech.SVMX_DelHomeBaseRec();
        objTeamTech.SVMX_DelTeamTechwithChild();
    }
}