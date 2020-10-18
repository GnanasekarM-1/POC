@isTest
private class OFFL_ManageOfflineProfile_UT{
	static testMethod void OFFL_ManageOfflineProfile_Test(){
		//Dummy Data Creation for Coverage
		RecordType[] rtConf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];   
		Profile AdminProf = [Select Id, Name From Profile where Name='System Administrator'];		
		SVMXC__ServiceMax_Config_Data__c confProf = new SVMXC__ServiceMax_Config_Data__c();
		
		for(RecordType rt1 : rtConf){ //Loop to take a record type at a time
			if(rt1.Name == 'Offline Profile'){
				SVMXC__ServiceMax_Config_Data__c set2 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId =rt1.Id,SVMXC__Profile_Name__c='Test Def 1',SVMXC__Description__c = 'Test IV1',Enable_Calendar__c=true);
				insert set2;
				SVMXC__ServiceMax_Config_Data__c set1 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId =rt1.Id,SVMXC__Profile_Name__c='Test Def 2',SVMXC__Description__c = 'Test IV1',Enable_Calendar__c=true);
				confProf = set1;
			} 
		} 
		insert confProf;
		
		for(RecordType rt1 : rtConf){ //Loop to take a record type at a time
			if(rt1.Name == 'Configuration Access'){
				SVMXC__ServiceMax_Config_Data__c acc1 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId =rt1.Id,SVMXC__Profile__c=AdminProf.Id,SVMXC__Access_Configuration_Profile__c=confProf.Id);
				insert acc1;
			} 
		} 
		Offline_Object__c Ds1 = new Offline_Object__c(SVMXC__Select__c=true,SVMXC__Tab_Order__c=2,SVMXC__Object_Name__c='Event',
		SVMXC__User_Defined__c=false, SVMXC__Allow_Upload__c=true, SVMXC__Allow_Tab__c=true,SVMXC__Offline_Profile__c=confProf.Id);
		insert Ds1;
		Offline_Object__c Ds2 = new Offline_Object__c(SVMXC__Select__c=false,SVMXC__Tab_Order__c=1,SVMXC__Object_Name__c='Task',
		SVMXC__User_Defined__c=true, SVMXC__Allow_Upload__c=true, SVMXC__Allow_Tab__c=true,SVMXC__Offline_Profile__c=confProf.Id);
		insert Ds2;
		
		System.currentPageReference().getParameters().put('pid', confProf.Id);
		for(RecordType rt1 : rtConf){ //Loop to take a record type at a time
			if(rt1.Name == 'Offline Profile'){
				SVMXC__ServiceMax_Config_Data__c set1 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId =rt1.Id,SVMXC__Profile_Name__c='Test Def 1',SVMXC__Description__c = 'Test IV1',Enable_Calendar__c=true);
				insert set1;
		 	}           
		}
		
		System.currentPageReference().getParameters().put('cl', 'i');		
		SVMXC.OFFL_ManageOfflineProfile myPageCon = new SVMXC.OFFL_ManageOfflineProfile();
		void T_CL1 = myPageCon.onLoad();		
		myPageCon.Clone=NULL;
		myPageCon.PId=NULL;
		void T_CL12 = myPageCon.onLoad();
		
		test.starttest();
		//Translations
		system.assert(myPageCon.getTAG001()!=null,'getTAG001 assertion failed');
		system.assert(myPageCon.getTAG002()!=null,'getTAG002 assertion failed');
		system.assert(myPageCon.getTAG003()!=null,'getTAG003 assertion failed');
		system.assert(myPageCon.getTAG004()!=null,'getTAG004 assertion failed');
		system.assert(myPageCon.getTAG005()!=null,'getTAG005 assertion failed');		
		system.assert(myPageCon.getTAG007()!=null,'getTAG007 assertion failed');
		system.assert(myPageCon.getTAG008()!=null,'getTAG008 assertion failed');		
		system.assert(myPageCon.getTAG010()!=null,'getTAG010 assertion failed');
		system.assert(myPageCon.getTAG011()!=null,'getTAG011 assertion failed');
		system.assert(myPageCon.getTAG012()!=null,'getTAG012 assertion failed');
		system.assert(myPageCon.getTAG013()!=null,'getTAG013 assertion failed');
		system.assert(myPageCon.getTAG014()!=null,'getTAG014 assertion failed');
		system.assert(myPageCon.getTAG015()!=null,'getTAG015 assertion failed');
		system.assert(myPageCon.getTAG016()!=null,'getTAG016 assertion failed');
		system.assert(myPageCon.getTAG017()!=null,'getTAG017 assertion failed');
		system.assert(myPageCon.getTAG018()!=null,'getTAG018 assertion failed');		
		system.assert(myPageCon.getTAG021()!=null,'getTAG021 assertion failed');
		system.assert(myPageCon.getTAG022()!=null,'getTAG022 assertion failed');
		system.assert(myPageCon.getTAG023()!=null,'getTAG023 assertion failed');
		system.assert(myPageCon.getTAG024()!=null,'getTAG024 assertion failed');
		system.assert(myPageCon.getTAG025()!=null,'getTAG025 assertion failed');
		system.assert(myPageCon.getTAG026()!=null,'getTAG026 assertion failed');
		system.assert(myPageCon.getTAG027()!=null,'getTAG027 assertion failed');
		system.assert(myPageCon.getTAG028()!=null,'getTAG028 assertion failed');
		system.assert(myPageCon.getTAG029()!=null,'getTAG029 assertion failed');
		system.assert(myPageCon.getTAG030()!=null,'getTAG030 assertion failed');
		//system.assert(myPageCon.getTAG031()!=null,'getTAG031 assertion failed');
		system.assert(myPageCon.getTAG032()!=null,'getTAG032 assertion failed'); 
		system.assert(myPageCon.getTAG033()!=null,'getTAG033 assertion failed');
		system.assert(myPageCon.getTAG034()!=null,'getTAG034 assertion failed');
		//system.assert(myPageCon.getTAG035()!=null,'getTAG035 assertion failed');
		system.assert(myPageCon.getTAG036()!=null,'getTAG036 assertion failed');
		system.assert(myPageCon.getTAG037()!=null,'getTAG037 assertion failed');
		system.assert(myPageCon.getTAG046()!=null,'getTAG046 assertion failed');
		system.assert(myPageCon.getTAG051()!=null,'getTAG051 assertion failed');
		system.assert(myPageCon.getTAG052()!=null,'getTAG052 assertion failed');
		system.assert(myPageCon.getTAG053()!=null,'getTAG053 assertion failed');
		system.assert(myPageCon.getHLPURL()!=null,'getHLPURL assertion failed');
		system.assert(myPageCon.getSET001()!=null,'getSET001 assertion failed');
		system.assert(myPageCon.getSET002()!=null,'getSET002 assertion failed');
		system.assert(myPageCon.getSET003()!=null,'getSET003 assertion failed');
		system.assert(myPageCon.getSET004()!=null,'getSET004 assertion failed');
		
		//myPageCon.svmxTagList.clear();
		
		system.assert(myPageCon.getTAG001()!=null,'getTAG001 assertion failed');
		system.assert(myPageCon.getTAG002()!=null,'getTAG002 assertion failed');
		system.assert(myPageCon.getTAG003()!=null,'getTAG003 assertion failed');
		system.assert(myPageCon.getTAG004()!=null,'getTAG004 assertion failed');
		system.assert(myPageCon.getTAG005()!=null,'getTAG005 assertion failed');
		system.assert(myPageCon.getTAG007()!=null,'getTAG007 assertion failed');
		system.assert(myPageCon.getTAG008()!=null,'getTAG008 assertion failed');		
		system.assert(myPageCon.getTAG010()!=null,'getTAG010 assertion failed');
		system.assert(myPageCon.getTAG011()!=null,'getTAG011 assertion failed');
		system.assert(myPageCon.getTAG012()!=null,'getTAG012 assertion failed');
		system.assert(myPageCon.getTAG013()!=null,'getTAG013 assertion failed');
		system.assert(myPageCon.getTAG014()!=null,'getTAG014 assertion failed');
		system.assert(myPageCon.getTAG015()!=null,'getTAG015 assertion failed');
		system.assert(myPageCon.getTAG016()!=null,'getTAG016 assertion failed');
		system.assert(myPageCon.getTAG017()!=null,'getTAG017 assertion failed');
		system.assert(myPageCon.getTAG018()!=null,'getTAG018 assertion failed');		
		system.assert(myPageCon.getTAG021()!=null,'getTAG021 assertion failed');
		system.assert(myPageCon.getTAG022()!=null,'getTAG022 assertion failed');
		system.assert(myPageCon.getTAG023()!=null,'getTAG023 assertion failed');
		system.assert(myPageCon.getTAG024()!=null,'getTAG024 assertion failed');
		system.assert(myPageCon.getTAG025()!=null,'getTAG025 assertion failed');
		system.assert(myPageCon.getTAG026()!=null,'getTAG026 assertion failed');
		system.assert(myPageCon.getTAG027()!=null,'getTAG027 assertion failed');
		system.assert(myPageCon.getTAG028()!=null,'getTAG028 assertion failed');
		system.assert(myPageCon.getTAG029()!=null,'getTAG029 assertion failed');
		system.assert(myPageCon.getTAG030()!=null,'getTAG030 assertion failed');
		//system.assert(myPageCon.getTAG031()!=null,'getTAG031 assertion failed');
		system.assert(myPageCon.getTAG032()!=null,'getTAG032 assertion failed'); 
		system.assert(myPageCon.getTAG033()!=null,'getTAG033 assertion failed');
		system.assert(myPageCon.getTAG034()!=null,'getTAG034 assertion failed');
		//system.assert(myPageCon.getTAG035()!=null,'getTAG035 assertion failed');
		system.assert(myPageCon.getTAG036()!=null,'getTAG036 assertion failed');
		system.assert(myPageCon.getTAG037()!=null,'getTAG037 assertion failed');
		system.assert(myPageCon.getTAG046()!=null,'getTAG046 assertion failed');
		system.assert(myPageCon.getTAG051()!=null,'getTAG051 assertion failed');
		system.assert(myPageCon.getTAG052()!=null,'getTAG052 assertion failed');
		system.assert(myPageCon.getTAG053()!=null,'getTAG053 assertion failed');
		system.assert(myPageCon.getHLPURL()!=null,'getHLPURL assertion failed');
		system.assert(myPageCon.getSET001()!=null,'getSET001 assertion failed');
		system.assert(myPageCon.getSET002()!=null,'getSET002 assertion failed');
		system.assert(myPageCon.getSET003()!=null,'getSET003 assertion failed');
		system.assert(myPageCon.getSET004()!=null,'getSET004 assertion failed');
		
		//Method Calling for Coverage
		system.assert(myPageCon.getCheckAllLines()!=null,'getCheckAllLines assertion failed');
		myPageCon.setCheckAllLines(true);
		myPageCon.getAccessMessage();
		myPageCon.custSize=2;
		system.assert(myPageCon.getIsListAvail()!=null,'getIsListAvail assertion failed');
		system.assert(myPageCon.getcustSize()!=null,'getcustSize assertion failed');
		
		List<SelectOption> T_CL6 = myPageCon.getAvailProf();
		List<SelectOption> T_CL7 = myPageCon.getSelectedProf();
		myPageCon.Clone='i';
		
		system.assert(myPageCon.getProf_Detail()!=null,'getProf_Detail assertion failed');
		system.assert(myPageCon.getProfDisplayBlockLevelMessage()!=null,'getProfDisplayBlockLevelMessage assertion failed');
		system.assert(myPageCon.getObjDisplayBlockLevelMessage()!=null,'getObjDisplayBlockLevelMessage assertion failed');
		
		PageReference T_CL10w = myPageCon.MSaveProf();  
		myPageCon.conf_data.SVMXC__Profile_Name__c='TeST-PB-001-tmp-001';
		myPageCon.Clone='i';
		PageReference T_CL10k = myPageCon.MSaveProf();
		myPageCon.Clone='u';
		PageReference T_CL10ke = myPageCon.MSaveProf();
		myPageCon.conf_data.SVMXC__Profile_Name__c='TeST-PB-001-tmp-002';
		myPageCon.Clone='s';
		PageReference T_CL10ks = myPageCon.MSaveProf();
		myPageCon.Clone=NULL;
		PageReference T_CL10kw = myPageCon.MSaveProf();
		myPageCon.conf_data.SVMXC__Profile_Name__c='';
		PageReference T_CL11 = myPageCon.MQSaveProf();
		myPageCon.conf_data.SVMXC__Profile_Name__c='TeST-PB-001-tm-003';
		myPageCon.Clone='i';
		PageReference T_CL10ko = myPageCon.MQSaveProf();
		myPageCon.Clone='u';
		PageReference T_CL10keo = myPageCon.MQSaveProf();
		myPageCon.conf_data.SVMXC__Profile_Name__c='TeST-PB-001-tmp-004';
		myPageCon.Clone='s';
		PageReference T_CL10kso = myPageCon.MQSaveProf();
		myPageCon.Clone=NULL;
		PageReference T_CL10kwo = myPageCon.MQSaveProf();
		myPageCon.conf_data.Enable_Calendar__c=false;
		PageReference T_CL123 = myPageCon.check_conf_CalStatus();
		myPageCon.conf_data.Enable_Calendar__c=true;
		PageReference T_CL124 = myPageCon.check_conf_CalStatus();
		PageReference T_CL13 = myPageCon.CloneDatasetValue();       
		PageReference T_CL14 = myPageCon.onInsertProfile();
		myPageCon.getCriticalErr();
		myPageCon.Clone=NULL;
		myPageCon.saveAccessProf();
		myPageCon.Clone='u';
		myPageCon.saveAccessProf();
		PageReference T_CL18 = myPageCon.cancelProf();
		string T_CL19 = myPageCon.getProfileName();
		List<Offline_Object__c> T_CL21 = myPageCon.getOfflineObjlst();
		Boolean T_CL22 = myPageCon.isValid('Edit');
		myPageCon.OfflineObjlst[0].SVMXC__Select__c=true;
		myPageCon.OfflineObjlst[0].SVMXC__User_Defined__c=false;
		PageReference T_CL23 = myPageCon.EditObj(); 
		PageReference T_CL24 = myPageCon.delObj();
		myPageCon.OfflineObjlst[0].SVMXC__Select__c=true;
		myPageCon.OfflineObjlst[0].SVMXC__User_Defined__c=true;
		PageReference T_CL23A = myPageCon.EditObj();
		PageReference T_CL24D = myPageCon.delObj(); 
		myPageCon.taborder();
		string T_CL27 = myPageCon.getClone();
		List<String> T_CL28 = myPageCon.getProfile();
		String[] s = new String[1];
		myPageCon.setProfile(s);
		List<String> T_CL29 = myPageCon.getSProfile();
		myPageCon.setSProfile(s);
		PageReference T_CL30 = myPageCon.GoAddObj();
		test.stoptest();
	}
}