@isTest
private class OFFL_TabOrder_UT{
	static testMethod void OFFL_TabOrder_Fnction_UT() {
		//Dummy Data Creation
		SVMXC__Offline_Object__c sobj = new SVMXC__Offline_Object__c(SVMXC__Allow_Tab__c=true,SVMXC__Object_Name__c='Account',SVMXC__Tab_Order__c=1);
		insert sobj;
		SVMXC__Offline_Object__c sobj1 = new SVMXC__Offline_Object__c(SVMXC__Allow_Tab__c=true,SVMXC__Object_Name__c='Contact',SVMXC__Tab_Order__c=2);
		insert sobj1;
		SVMXC__Offline_Object__c sobj2 = new SVMXC__Offline_Object__c(SVMXC__Allow_Tab__c=true,SVMXC__Object_Name__c='Case',SVMXC__Tab_Order__c=3);
		insert sobj2;
		
		test.starttest();
		//Function calling for Coverage		
		string[] selected = new string[]{};
		selected.add(sobj1.Id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(sobj);
		OFFL_TabOrder OFF_T = new OFFL_TabOrder(stdController);
		
		system.assert(OFF_T.getProfileName()!=null,'getProfileName assertion failed');
		OFF_T.getOfflineObjlst();
		
		system.assert(OFF_T.getitems()!=null,'getitems assertion failed');
		OFF_T.setitems(selected);        
		
		OFF_T.UP();
		OFF_T.Down();
		OFF_T.shuffle(1,true); 
		OFF_T.Top();
		OFF_T.shuffle(1,false); 
		OFF_T.Bottom();
		OFF_T.isTopAction = true;
		OFF_T.isBottomAction = false;
		OFF_T.isUpAction = false;
		OFF_T.isDownAction = false;
		OFF_T.sel();
		OFF_T.isTopAction = false;
		OFF_T.isBottomAction = true;
		OFF_T.isUpAction = false;
		OFF_T.isDownAction = false;
		OFF_T.sel();
		OFF_T.isTopAction = false;
		OFF_T.isBottomAction = false;
		OFF_T.isUpAction = true;
		OFF_T.isDownAction = false;
		OFF_T.sel();
		OFF_T.isTopAction = false;
		OFF_T.isBottomAction = false;
		OFF_T.isUpAction = false;
		OFF_T.isDownAction = true;
		OFF_T.sel();
		OFF_T.cancel();
		
		//Translations
		system.assert(OFF_T.getTAG038()!=null,'TAG038 assertion failed');
		system.assert(OFF_T.getTAG039()!=null,'TAG039 assertion failed');
		system.assert(OFF_T.getTAG040()!=null,'TAG040 assertion failed');
		system.assert(OFF_T.getTAG041()!=null,'TAG041 assertion failed');
		system.assert(OFF_T.getTAG042()!=null,'TAG042 assertion failed');
		system.assert(OFF_T.getTAG043()!=null,'TAG043 assertion failed');
		system.assert(OFF_T.getTAG044()!=null,'TAG044 assertion failed');
		system.assert(OFF_T.getTAG045()!=null,'TAG045 assertion failed');
		system.assert(OFF_T.getSET001()!=null,'SET001 assertion failed');
		system.assert(OFF_T.getSET002()!=null,'SET002 assertion failed');
		system.assert(OFF_T.getSET003()!=null,'SET003 assertion failed');
		system.assert(OFF_T.getSET004()!=null,'SET004 assertion failed');
		
		//OFF_T.svmxTagList.clear();
		
		system.assert(OFF_T.getTAG038()!=null,'TAG038 assertion failed');
		system.assert(OFF_T.getTAG039()!=null,'TAG039 assertion failed');
		system.assert(OFF_T.getTAG040()!=null,'TAG040 assertion failed');
		system.assert(OFF_T.getTAG041()!=null,'TAG041 assertion failed');
		system.assert(OFF_T.getTAG042()!=null,'TAG042 assertion failed');
		system.assert(OFF_T.getTAG043()!=null,'TAG043 assertion failed');
		system.assert(OFF_T.getTAG044()!=null,'TAG044 assertion failed');
		system.assert(OFF_T.getTAG045()!=null,'TAG045 assertion failed');
		test.stoptest();
	}
}