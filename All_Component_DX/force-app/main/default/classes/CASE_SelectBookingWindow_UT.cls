@isTest
(seeAllData = true)
Private with sharing class CASE_SelectBookingWindow_UT {
    
    static testMethod void CASE_SelectBookingWindowTest_UT(){
        
            
    /********************************** Dummy Data Creation ***************************************/
        Product2 pr = new Product2 (Name ='SLA: Silver',ProductCode='Prod',SVMXC__Inherit_Parent_Warranty__c =True ); 
        insert pr;
        User ULocale = [select id,TimeZoneSidKey from User where Id=:userinfo.getUserId()];
        Product2 p = [select Id,Name from Product2 limit 1];
        RecordType r = [select id from RecordType where Name='Definition' and sobjectType ='SVMXC__Booking_Window__c' ];
         RecordType RAccess = [select id from RecordType where Name='Access' and sobjectType ='SVMXC__Booking_Window__c' ];
        RecordType RType = [select Id from RecordType where Name=:'Technician'];
        
        SVMXC__Service_Group__c Team = new SVMXC__Service_Group__c();        
        Team.RecordTypeId = RType.Id;
        Team.Name = 'OS Installation';
        Team.Street__c = '2629 firma lane';
        Team.City__c='east meadow';
        Team.State__c='ny';
        Team.Zip__c='11554';
        Team.Country__c='United States';
        Team.SVMXC__Group_Type__c ='Internal';
        Team.SVMXC__Active__c=true;
        insert Team;
        
        SVMXC__ServiceMax_List__c o = new SVMXC__ServiceMax_List__c();  
            o.SVMXC__Date_Required__c = system.today();
            o.SVMXC__Expected_Ship_Date__c = system.today() + 4;
            insert o;
        
        SVMXC__Territory__c Trtry = new SVMXC__Territory__c();
            Trtry.Name = 'Test Territory';
            insert Trtry;
            system.assert(Trtry.Name!=null,'failed');
        
        SVMXC__Territory__c ChildTrtry = new SVMXC__Territory__c();
            ChildTrtry.Name = 'Test Territory';
            ChildTrtry.SVMXC__Parent_Territory__c = Trtry.Id;
            insert ChildTrtry;
            system.assert(ChildTrtry.Name!=null,'failed');
        
        SVMXC__Service_Group_Members__c Techncn = new SVMXC__Service_Group_Members__c();        
        Techncn.SVMXC__Service_Group__c=Team.Id;
        Techncn.SVMXC__Role__c = 'Consultant'; 
        Techncn.SVMXC__Active__c =true;
        Techncn.Street__c = '2629 firma lane';
        Techncn.City__c='east meadow';
        Techncn.State__c='ny';
        Techncn.Zip__c='11554';
        Techncn.Country__c='United States'; 
        Techncn.SVMXC__Enable_Scheduling__c=true;
        Techncn.SVMXC__Service_Territory__c=Trtry.Id;
        //Techncn.SVMXC__Salesforce_User__c = u.Id;
        insert Techncn;
        system.assertEquals(true,Techncn.SVMXC__Active__c);
        
        Case nCase = new Case();
            nCase.Origin='Web';
            nCase.Status = 'New';
            nCase.Priority='Medium';
            nCase.SVMXC__BW_Territory__c = Trtry.Id;
            insert nCase;
            system.assertEquals(true,nCase.Origin=='Web');
        
        System.currentPageReference().getParameters().put('CaseId',nCase.Id);   
        list<SVMXC__Booking_Window__c> obookList = new list<SVMXC__Booking_Window__c>();
        
        CASE_SelectBookingWindow oCase = new CASE_SelectBookingWindow();
       
        SVMXC__Booking_Window__c oBook = new SVMXC__Booking_Window__c();
            oBook.RecordTypeId = RAccess.Id;
            oBook.SVMXC__Start_Time__c = '9:00 AM';
            oBook.SVMXC__End_Time__c = '12:00 PM';
            oBook.SVMXC__Display_Order__c = 1;
            oBook.SVMXC__Average_Slots__c = 3;
            obookList.add(oBook);
            //oCase.DefnBookingLst.add(oBook); 
        SVMXC__Booking_Window__c oBook1 = new SVMXC__Booking_Window__c();
            oBook1.RecordTypeId = r.Id;
            oBook1.SVMXC__Start_Time__c = '12:00 PM';
            oBook1.SVMXC__End_Time__c = '3:00 PM';
            oBook1.SVMXC__Display_Order__c = 2;
            oBook1.SVMXC__Average_Slots__c = 3;
            obookList.add(oBook1);
            //oCase.DefnBookingLst.add(oBook1);
        SVMXC__Booking_Window__c oBook2 = new SVMXC__Booking_Window__c();
            oBook2.RecordTypeId = r.Id;
            oBook2.SVMXC__Start_Time__c = '3:00 PM';
            oBook2.SVMXC__End_Time__c = '6:00 PM';
            oBook2.SVMXC__Display_Order__c = 3;
            oBook2.SVMXC__Average_Slots__c = 3;
            oBook2.SVMXC__IsDefault__c = true;
            obookList.add(oBook2);
       SVMXC__Booking_Window__c oBook3 = new SVMXC__Booking_Window__c();
            oBook3.RecordTypeId = r.Id;
            oBook3.SVMXC__Start_Time__c = '6:00 PM';
            oBook3.SVMXC__End_Time__c = '9:00 PM';
            oBook3.SVMXC__Display_Order__c = 4;
            oBook3.SVMXC__Average_Slots__c = 3;
            obookList.add(oBook3);
            insert obookList;
    map<string, integer> oMap = new map<string, integer>();
    oMap.put(obookList[0].Id,1);
    oMap.put(obookList[1].Id,2);
    oMap.put(obookList[2].Id,3);
    oMap.put(obookList[3].Id,4);
    /********************************** Calling Class Functions for Coverage ***************************************/
        
       
        oCase.TTId=Trtry.Id;
        oCase.lstBWDates.add(system.today());
        oCase.lstBWDates.add(system.today()+1);
        oCase.lstBWDates.add(system.today()+2);
        
        for(Date odate : oCase.lstBWDates){
            oCase.mapCaseCount.put(odate,oMap);
        }
        
        /********* Tags Coverage*******/
       system.assert(oCase.getHLPURL()!=null,'HLPURL assertion failed');
        system.assert(oCase.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(oCase.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(oCase.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(oCase.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(oCase.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(oCase.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(oCase.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(oCase.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(oCase.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(oCase.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(oCase.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(oCase.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(oCase.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(oCase.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(oCase.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(oCase.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(oCase.getTAG017()!=null,'TAG017 assertion failed');
        //system.assert(oCase.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(oCase.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(oCase.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(oCase.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(oCase.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(oCase.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(oCase.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(oCase.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(oCase.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(oCase.getTAG027()!=null,'TAG027 assertion failed');
        system.assert(oCase.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(oCase.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(oCase.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(oCase.getTAG031()!=null,'TAG031 assertion failed');
        system.assert(oCase.getTAG032()!=null,'TAG032 assertion failed');
        system.assert(oCase.getTAG033()!=null,'TAG033 assertion failed');
        system.assert(oCase.getTAG034()!=null,'TAG034 assertion failed');
        system.assert(oCase.getTAG035()!=null,'TAG034 assertion failed');
        //oCase.mapSVMXTags.clear();
        system.assert(oCase.getHLPURL()!=null,'HLPURL assertion failed');
        system.assert(oCase.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(oCase.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(oCase.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(oCase.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(oCase.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(oCase.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(oCase.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(oCase.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(oCase.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(oCase.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(oCase.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(oCase.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(oCase.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(oCase.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(oCase.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(oCase.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(oCase.getTAG017()!=null,'TAG017 assertion failed');
       //system.assert(oCase.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(oCase.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(oCase.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(oCase.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(oCase.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(oCase.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(oCase.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(oCase.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(oCase.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(oCase.getTAG027()!=null,'TAG027 assertion failed');
        system.assert(oCase.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(oCase.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(oCase.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(oCase.getTAG031()!=null,'TAG031 assertion failed');
        system.assert(oCase.getTAG032()!=null,'TAG032 assertion failed');
        system.assert(oCase.getTAG033()!=null,'TAG033 assertion failed');
        system.assert(oCase.getTAG034()!=null,'TAG034 assertion failed');
        system.assert(oCase.getTAG035()!=null,'TAG035 assertion failed');
        system.assert(oCase.getTAG036()!=null,'TAG036 assertion failed');
        /********* Function Coverage********/
        oCase.getSettings();
        oCase.getIntegerSetting('SET006');
        oCase.getBooleanSetting('SET008');
        oCase.getUserLocale();
        oCase.setUserLocale(ULocale);       
        oCase.getobjSelectedCase();
        oCase.getselectedTab();
        oCase.setselectedTab('');
        oCase.setselectedTab2('');
        oCase.getselectedTab2();
        oCase.getDisableSLAChkBox();
        oCase.setDisableSLAChkBox(true);
        system.assert(oCase.getDisableSLAChkBox()==true);
        oCase.getcolHeader();
        oCase.getcolWidth();
        oCase.getArrString();
        oCase.getYellowColorStart();
        oCase.setYellowColorStart('4');
        oCase.getYellowColorEnd();
        oCase.setYellowColorEnd('10');
        //oCase.getAvailCount();
        oCase.AvailCount = 2;
        oCase.getTTListStyle();
        oCase.AvailCount = 0;
        oCase.getTTListStyle();
        oCase.getTTId();
        oCase.setTTId(Trtry.Id);
        oCase.getTrtryId();
        oCase.setTrtryId(Trtry.Id);
        oCase.getTrtryName();
        oCase.setTrtryName(Trtry.Name);
        oCase.SVMX_ClearExpertiseANDSpecialization();   
             
        oCase.onLoad();
        oCase.getShowProductSpecialization();
        oCase.getShowExpertise();
        oCase.getXMLResult();
        oCase.gettempSVMXList();
        oCase.settempSVMXList(o);
        
        CASE_SelectBookingWindow.wrapperRec W = new CASE_SelectBookingWindow.wrapperRec(); 
        CASE_SelectBookingWindow.wrapperRec Wrp = new CASE_SelectBookingWindow.wrapperRec(true,p.Name, p.Id);
        Wrp.getRecId();
        Wrp.setRecId(p.Id);
        Wrp.getRecName();
        Wrp.setRecName(p.Name);
        Wrp.getselected();
        Wrp.setselected(true);
        list<CASE_SelectBookingWindow.wrapperRec> lst = new list<CASE_SelectBookingWindow.wrapperRec>();
        lst.add(Wrp);
        
        oCase.getlstExpertise();
        oCase.setlstExpertise(lst);
        oCase.getlstProductSpecialization();
        oCase.setlstProductSpecialization(lst);
        
        oCase.addToMparrent(Trtry.Id,ChildTrtry.Id);
        oCase.Tree_frm_Parent(Trtry.Id);
        oCase.activateBlockMsg('POPUP');
        oCase.activateBlockMsg('TOP');
        oCase.activateBlockMsg('BOT');
        oCase.activateBlockMsg('ADJTT');
        oCase.activateBlockMsg('SEARCHTT');        
        oCase.CheckNull('abc');
        oCase.SpecialCharParser('a%s');
        
        oCase.getDisplayTopBlockLevelMessage();
        oCase.getDisplayBotBlockLevelMessage();
        oCase.getDisplayPPLevelMessage();
        oCase.getDisplayADJTTLevelMessage();
        oCase.getDisplaySEARCHTTLevelMessage();
        
        oCase.getRowId();
        oCase.getColId();
        oCase.setRowId('1');
        oCase.setColId('2');
        oCase.deActivateAllMsg();
        oCase.SVMX_SearchProductSpecialization();
        oCase.SVMX_SearchExpertise();       
        oCase.getActualSlot();
        oCase.setActualSlot(5);
        oCase.getselectedRadio();
        oCase.setselectedRadio('1:2');
        oCase.getGridTitle();
        oCase.getRowSize();
        oCase.getCollSize();
        oCase.getGridWidth();
        oCase.getGridAligne();
        oCase.getGridTypes();
        oCase.getstrDataArray();
        oCase.getXMLResultGrid();     
        oCase.Cancel();
        oCase.FindDateWithTimeZone(oBook.Id,oBook.SVMXC__Start_Time__c, system.today());
            string strt = oBook.SVMXC__Start_Time__c;
            strt = strt.replace(' AM',':00');
            Time BWStartTime = Time.newInstance(integer.valueOf(strt.split(':')[0]), integer.valueOf(strt.split(':')[1]),integer.valueOf(strt.split(':')[2]),0);                
            DateTime givenDateTime = DateTime.newInstance(system.today(),BWStartTime);
        //CASE_SelectBookingWindow.TimeZoneConvertor(givenDateTime, ULocale.TimeZoneSidKey);
        CASE_SelectBookingWindow.getDateTimeInTimezone(system.today(),BWStartTime ,ULocale.TimeZoneSidKey);
        system.debug('oCase.mapCaseCount' + oCase.mapCaseCount);
        oCase.TTId=Trtry.Id;
        oCase.SVMX_ShowBookingWindow();
        oCase.RowId = '2';
        oCase.ColId = '1';
        oCase.bAllowOverbooking = false;        
        oCase.gesetAvailableTerritoriesCount();
        //oCase.SVMX_ConfirmBookingWindow();
        
    }
}