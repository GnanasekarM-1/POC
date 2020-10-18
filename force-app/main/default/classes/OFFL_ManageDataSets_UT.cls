@isTest
private class OFFL_ManageDataSets_UT {
	private static OFFL_ManageDataSets.wraperOfflObj_RefObj wrap = new OFFL_ManageDataSets.wraperOfflObj_RefObj()  ;
	
	static testMethod void OFFL_ManageDataSets_Test(){   
		//Creating the all Objects
		Map<String, Schema.SObjectType> allObjs;
		allObjs = Schema.getGlobalDescribe();       
		Set<String> s =allObjs.keySet(); 
		List<String> reqObjName =new List<String>(); 
		//getting all the CustomObject  Name into the set 
		for(Schema.SObjectType lON : allObjs.values()){ //Loop List of all Objects and describe each
			Schema.DescribeSObjectResult D = lON.getDescribe();
			if(D.isAccessible() == true && D.isCustom() == true )
				reqObjName.add( D.getName() );
		}
		//Adding some Standard Object Names                 
		//reqObjName.add(0,'Case');
		reqObjName.add(0,'Account');
		reqObjName.add(1,'Contact');
		RecordType[] rtConf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];   
		Profile AdminProf = [Select Id, Name From Profile where Name='System Administrator'];
		// creating the profile object
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
		SVMXC__Offline_Object__c offlineObject = new SVMXC__Offline_Object__c(
			SVMXC__Object_Name__c ='SVMXC__Service_Order__c',
			SVMXC__User_Defined__c =true,
			SVMXC__Allow_Tab__c =true,
			SVMXC__Allow_Upload__c=true,
			SVMXC__SOQL_Query__c ='select ID, Name form Dummy Object ',
			SVMXC__Offline_Query__c='select ID, Name form Dummy Object ',
			SVMXC__Allow_View_Override__c=true,
			SVMXC__Ownership_Limit__c='MyRecords', 
			SVMXC__Lock_Criteria__c='TestONE Data',
			SVMXC__Archival_Criteria__c='TestONe Data',
			SVMXC__Use_Object_As_Home_Tab__c=true,                                      
			SVMXC__Select__c=true,
			SVMXC__Parent_Object__c ='Test one Data'
		);                                  
		insert offlineObject;
		
		SVMXC__Offline_View__c objOfflView1 = new SVMXC__Offline_View__c(SVMXC__Field_Name__c = 'Account',SVMXC__Object_Name__c = offlineObject.id,SVMXC__Display_Order__c = 1);
		            
		SVMXC__Offline_View__c objOfflView2 = new SVMXC__Offline_View__c(SVMXC__Field_Name__c = 'Contact',SVMXC__Object_Name__c= offlineObject.id,SVMXC__Display_Order__c = 2);
		
		SVMXC__Offline_View__c objOfflView3 = new SVMXC__Offline_View__c(SVMXC__Field_Name__c = 'Origin',SVMXC__Object_Name__c= offlineObject.id,SVMXC__Display_Order__c = 3);
		
		SVMXC__Offline_View__c objOfflView4 = new SVMXC__Offline_View__c(SVMXC__Field_Name__c = 'ContactEmail',SVMXC__Object_Name__c= offlineObject.id,SVMXC__Display_Order__c = 4);
		
		SVMXC__Offline_View__c objOfflView5 = new SVMXC__Offline_View__c(SVMXC__Field_Name__c = 'ContactMobile',SVMXC__Object_Name__c= offlineObject.id,SVMXC__Display_Order__c = 5);
		
		insert objOfflView1;
		insert objOfflView2;
		
		list<SVMXC__Offline_Object__c> lstofflineObject = new list<SVMXC__Offline_Object__c >();
		
		SVMXC__Offline_Object__c offlineObject1 = new SVMXC__Offline_Object__c(
			SVMXC__Object_Name__c ='Account',
			SVMXC__User_Defined__c =true,
			SVMXC__Allow_Tab__c =true,
			SVMXC__Allow_Upload__c=true,
			SVMXC__SOQL_Query__c ='select ID, Name form Dummy Object ',
			SVMXC__Offline_Query__c='select ID, Name form Dummy Object ',
			SVMXC__Allow_View_Override__c=true,
			SVMXC__Ownership_Limit__c='MyRecords', 
			SVMXC__Lock_Criteria__c='TestONE Data',
			SVMXC__Archival_Criteria__c='TestONe Data',
			SVMXC__Use_Object_As_Home_Tab__c=true,                                      
			SVMXC__Select__c=false,
			SVMXC__Related_To__c =offlineObject.id
		);                                  
		
		SVMXC__Offline_Object__c offlineObject2 = new SVMXC__Offline_Object__c(
			SVMXC__Object_Name__c ='Contact',
			SVMXC__User_Defined__c =true,
			SVMXC__Allow_Tab__c =true,
			SVMXC__Allow_Upload__c=true,
			SVMXC__SOQL_Query__c ='select ID, Name form Dummy Object ',
			SVMXC__Offline_Query__c='select ID, Name form Dummy Object ',
			SVMXC__Allow_View_Override__c=true,
			SVMXC__Ownership_Limit__c='MyRecords', 
			SVMXC__Lock_Criteria__c='TestONE Data',
			SVMXC__Archival_Criteria__c='TestONe Data',
			SVMXC__Use_Object_As_Home_Tab__c=true,                                      
			SVMXC__Select__c=true,
			SVMXC__Related_To__c =offlineObject.id
		);                                  
		
		SVMXC__Offline_Object__c offlineObject3 = new SVMXC__Offline_Object__c(
			SVMXC__Object_Name__c ='Account',
			SVMXC__User_Defined__c =true,
			SVMXC__Allow_Tab__c =true,
			SVMXC__Allow_Upload__c=true,
			SVMXC__SOQL_Query__c ='select ID, Name form Dummy Object ',
			SVMXC__Offline_Query__c='select ID, Name form Dummy Object ',
			SVMXC__Allow_View_Override__c=true,
			SVMXC__Ownership_Limit__c='MyRecords', 
			SVMXC__Lock_Criteria__c='TestONE Data',
			SVMXC__Archival_Criteria__c='TestONe Data',
			SVMXC__Use_Object_As_Home_Tab__c=true,                                      
			SVMXC__Parent_Object__c ='SVMXC__Service_Order__c',
			SVMXC__Related_To__c =offlineObject.id
		);                                  
		
		SVMXC__Offline_Object__c offlineObject4 = new SVMXC__Offline_Object__c(
			SVMXC__Object_Name__c ='Contact',
			SVMXC__User_Defined__c =true,
			SVMXC__Allow_Tab__c =true,
			SVMXC__Allow_Upload__c=true,
			SVMXC__SOQL_Query__c ='select ID, Name form Dummy Object ',
			SVMXC__Offline_Query__c='select ID, Name form Dummy Object ',
			SVMXC__Allow_View_Override__c=true,
			SVMXC__Ownership_Limit__c='MyRecords', 
			SVMXC__Lock_Criteria__c='TestONE Data',
			SVMXC__Archival_Criteria__c='TestONe Data',
			SVMXC__Use_Object_As_Home_Tab__c=true,                                      
			SVMXC__Parent_Object__c ='SVMXC__Service_Order__c',
			SVMXC__Related_To__c =offlineObject.id
		);                                  
		lstofflineObject.add(offlineObject1);
		lstofflineObject.add(offlineObject2);
		lstofflineObject.add(offlineObject3);
		lstofflineObject.add(offlineObject4);
		insert lstofflineObject;
		
		list<SVMXC__Offline_Dataset_Expression__c > lstOfflDtExp = new List<SVMXC__Offline_Dataset_Expression__c >();
		SVMXC__Offline_Dataset_Expression__c objOfflDtExpDW1 = new SVMXC__Offline_Dataset_Expression__c(SVMXC__Type__c = 'Download Criteria',SVMXC__Sequence__c =1,SVMXC__Operator__c = 'eq',SVMXC__Operand__c = 'test Operand',Name = 'SuppliedCompany',SVMXC__Offline_Object__c = offlineObject.Id);
		
		SVMXC__Offline_Dataset_Expression__c objOfflDtExpDW2 = new SVMXC__Offline_Dataset_Expression__c(SVMXC__Type__c = 'Download Criteria',SVMXC__Sequence__c =1,SVMXC__Operator__c = 'eq',SVMXC__Operand__c = 'test Operand',Name = 'Subject',SVMXC__Offline_Object__c = offlineObject.Id);
		
		SVMXC__Offline_Dataset_Expression__c objOfflDtExpAR1 = new SVMXC__Offline_Dataset_Expression__c(SVMXC__Type__c ='Archival Criteria',SVMXC__Sequence__c =1,SVMXC__Operator__c = 'eq',SVMXC__Operand__c = 'test Operand',Name = 'SuppliedCompany',SVMXC__Offline_Object__c = offlineObject.Id);
		
		SVMXC__Offline_Dataset_Expression__c objOfflDtExpAR2 = new SVMXC__Offline_Dataset_Expression__c(SVMXC__Type__c = 'Archival Criteria',SVMXC__Sequence__c =1,SVMXC__Operator__c = 'eq',SVMXC__Operand__c = 'test Operand',Name = 'Subject',SVMXC__Offline_Object__c = offlineObject.Id);
		
		SVMXC__Offline_Dataset_Expression__c objOfflDtExpLK1 = new SVMXC__Offline_Dataset_Expression__c(SVMXC__Type__c =  'Lock Criteria',SVMXC__Sequence__c =1,SVMXC__Operator__c = 'eq',SVMXC__Operand__c = 'test Operand',Name = 'SuppliedCompany',SVMXC__Offline_Object__c = offlineObject.Id);
		
		SVMXC__Offline_Dataset_Expression__c objOfflDtExpLK2 = new SVMXC__Offline_Dataset_Expression__c(SVMXC__Type__c =  'Lock Criteria',SVMXC__Sequence__c =1,SVMXC__Operator__c = 'eq',SVMXC__Operand__c = 'test Operand',Name = 'Subject',SVMXC__Offline_Object__c = offlineObject.Id);   
		
		lstOfflDtExp.add(objOfflDtExpLK1);
		lstOfflDtExp.add(objOfflDtExpLK2);
		lstOfflDtExp.add(objOfflDtExpDW1);
		lstOfflDtExp.add(objOfflDtExpDW2);
		lstOfflDtExp.add(objOfflDtExpAR1);
		lstOfflDtExp.add(objOfflDtExpAR2);
		
		insert lstOfflDtExp;
		
		PageReference pageRef = new PageReference('Page.SVMXC.OFFL_ManageDataSets');
		pageRef.getParameters().put('did', offlineObject.id);
		
		Test.setCurrentPage(pageRef);
		OFFL_ManageDataSets controller = new OFFL_ManageDataSets();
		test.starttest();
		controller.delind = 1;
		controller.getisEditMode();
		controller.getlstOwnShipLimit();
		controller.lstSrcObjOpt.add(new selectOption('a','a'));
		controller.lstSrcObjOpt.add(new selectOption('b','b'));
		controller.getlstSrcObjOpt(); 
		controller.getisEditMode();
		controller.getlstOffl_DSExp(); 
		controller.setlstOffl_DSExp(lstOfflDtExp);
		controller.isExpExists('Subject', 'Lock Criteria');
		controller.isExpExists('Subject', 'Test Criteria');
		controller.setlstOffl_DSExpDW(lstOfflDtExp);
		controller.getlstOffl_DSExpDW();
		controller.SVMX_editDownload();
		controller.SVMX_addRow();
		controller.SVMX_removeRow();
		controller.setlstOffl_DSExpLK(lstOfflDtExp);
		controller.getlstOffl_DSExpLK(); 
		controller.SVMX_editLock();
		controller.setlstOffl_DSExpAR(lstOfflDtExp);
		controller.getlstOffl_DSExpAR();
		controller.SVMX_editArchival();
		
		SVMXC__Offline_Dataset_Expression__c objOfflDtExpDW3 = new SVMXC__Offline_Dataset_Expression__c(SVMXC__Type__c = 'Download Criteria',SVMXC__Sequence__c =9,SVMXC__Operator__c = 'eq',SVMXC__Operand__c = 'test Operand',Name = 'SuppliedCompany',SVMXC__Offline_Object__c = offlineObject.Id);
		
		controller.setlstTempOffl_DSExp(controller.getlstOffl_DSExpDW());
		controller.getlstTempOffl_DSExp(); 
		controller.lstTempOffl_DSExp.add(objOfflDtExpDW3);
		
		list<SVMXC__Offline_Dataset_Expression__c> lstobjOfflDtExp4 = new list<SVMXC__Offline_Dataset_Expression__c>();
		SVMXC__Offline_Dataset_Expression__c objOfflDtExp4 = new SVMXC__Offline_Dataset_Expression__c(SVMXC__Sequence__c =9);
		lstobjOfflDtExp4.add(objOfflDtExp4);
		
		controller.updateExpLst(lstobjOfflDtExp4, 'Download Criteria'); 
		controller.strAdvanceOption ='';
		controller.getCriteria('Download Criteria');
		controller.strAdvanceOption ='1';
		controller.getCriteria('Download Criteria');
		controller.lstTempOffl_DSExp[0].Name = controller.getTAG016();
		controller.strAdvanceOption ='1 and 2 and 9';
		controller.getCriteria('Download Criteria');
		
		list<String> lststring = new list<string>();
		lststring.add('test');
		
		controller.getlstAvlbFields();
		controller.setlstAvlbFields(lststring);
		controller.getlstSelFields();
		controller.setlstSelFields(lstString);
		controller.getshowPageError();
		controller.setshowPageError(true);
		controller.getoOfflObj();
		controller.getlstOfflView();
		controller.getlstOfflObj_RefObj();
		controller.setlstOfflObj_RefObj(lstofflineObject);
		controller.getlstFields();
		controller.getlstFieldsOpt();
		controller.getlstSFieldsOpt();
		
		list<OFFL_ManageDataSets.wraperOfflObj_RefObj> lstWrp = new list<OFFL_ManageDataSets.wraperOfflObj_RefObj>();
		controller.lstSFieldsOpt.add( new selectoption('test1','test1')); 
		controller.lstSFieldsOpt.add( new selectoption('test2','test2'));  
		controller.lstSFieldsOpt.add( new selectoption('test3','test3'));
		controller.lstSFieldsOpt.add( new selectoption('test4','test4'));   
		controller.lstSFieldsOpt.add( new selectoption('test5','test5'));  
		controller.lstFieldsOpt.add( new selectoption('test6','test6')); 
		controller.lstFieldsOpt.add( new selectoption('test7','test7'));  
		controller.lstFieldsOpt.add( new selectoption('test8','test8'));
		controller.lstFieldsOpt.add( new selectoption('test9','test9'));   
		controller.lstFieldsOpt.add( new selectoption('test0','test0'));        
		
		controller.getlstWrpOfflObj_RefObj();
		controller.setlstWrpOfflObj_RefObj(lstWrp);
		controller.getlstOfflObj_MstChdList();
		controller.getstrAdvanceOption();
		controller.setstrAdvanceOption(' '); 
		controller.IsValidSFID('testtest');
		controller.IsValidSFID('');
		controller.SVMX_doCancel();
		controller.getisHomeTab();
		
		SVMXC__Offline_Object__c offlineObjValidData = new SVMXC__Offline_Object__c(SVMXC__Object_Name__c = controller.getTAG016());
		
		controller.oOfflObj=offlineObjValidData ;
		controller.isValidData();
		offlineObjValidData.SVMXC__Object_Name__c = 'testtest';
		controller.oOfflObj=offlineObjValidData;
		controller.isValidData();
		controller.SVMX_Update_Download();
		controller.SVMX_Update_Archival();
		controller.SVMX_Update_Lock();
		controller.lstSelFields.add('test2');
		controller.SVMX_MoveUp();
		controller.lstSelFields.add('test4');
		controller.SVMX_MoveDown();
		controller.SVMX_MoveTop();
		controller.SVMX_MoveBottom();
		controller.getisValidCri();
		controller.getintDSExpSize();
		controller.getdelind();
		controller.setdelind(1);
		controller.lstAvlbFields.add('test6');
		controller.SVMX_onAddFields();
		controller.lstSelFields.add('test1');
		controller.SVMX_onRemField();
		controller.mapExstOfflObj.put('Contact', offlineObject4);
		controller.addObject('TestObject', 'TestLable');
		controller.getDisplayBlockLevelMessage();
		controller.getProfDisplayBlockLevelMessage();
		controller.getheaderDisplayBlockLevelMessage();
		controller.getheaderRecDisplayBlockLevelMessage();
		controller.getallowPageRender();
		controller.lstOfflView.add(objOfflView1);
		controller.isFieldObjExist('Account');
		controller.isFieldObjExist('TestField');
		controller.lstOfflObj_MstChdList.add(offlineObject4);
		controller.isRelatedObjExist('Contact');
		controller.isRelatedObjExist('TestObject');
		controller.getOperatorSelectList();
		controller.getInputDateFormat();
		controller.getInputDateFormat(12,01,01);
		controller.getInputDateFormat(20,01,01);
		controller.getInputDateFormat(31,01,01);
		controller.isEditMode=false;
		controller.oOfflObj=offlineObject;
		controller.SVMX_onSelectObject();
		controller.mapfieldType.put('BOOLEAN','BOOLEAN');
		controller.mapfieldType.put('Date','Date');
		controller.mapfieldType.put('string','string');
		controller.mapfieldType.put('MULTIPICKLIST','MULTIPICKLIST');
		controller.mapfieldType.put('DATE','DATE');
		controller.mapfieldType.put('DATETIME','DATETIME');
		list<string> lstOperator = new list<string>();
		lstOperator.add('eq');
		lststring.add('ne');
		lstOperator.add('gt');
		lstOperator.add('ge');
		lstOperator.add('lt');
		lstOperator.add('le');
		lstOperator.add('starts');
		lstOperator.add('contains'); 
		lstOperator.add('notcontain');
		lstOperator.add('in'); 
		lstOperator.add('notin');
		for (string strOperator :lstOperator){
		    for(string strfield :controller.mapfieldType.keySet()){
				OFFL_ManageDataSets_UT.testwhereclause(controller, strField, strOperator, 'testOperand');
		    }
		}
		OFFL_ManageDataSets_UT.testwhereclause(controller, '', 'eq', 'testOperand');
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('string'), 'eq', 'test,Operand');
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('string'), 'ne', 'test,Operand');
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('string'), 'ne', 'testOperand');
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('BOOLEAN'), 'eq', 'true');
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('BOOLEAN'), 'ne', 'true');
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('DATE'), 'eq', 'TODAY');
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('DATETIME'), 'eq', date.newInstance(2009, 12, 31).format());
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('DATETIME'), 'ne', date.newInstance(2009, 12, 31).format());
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('DATETIME'), 'gt', date.newInstance(2009, 2, 31).format());
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('DATETIME'), 'ge', date.newInstance(2009, 2, 31).format());
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('DATETIME'), 'lt', date.newInstance(2009, 12, 1).format());
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('DATETIME'), 'le', date.newInstance(2009, 12, 1).format());
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('DATE'), 'le', 'NEXT 10 DAYS');
		OFFL_ManageDataSets_UT.testwhereclause(controller, controller.mapfieldType.get('DATE'), 'le', 'NEXT 10 WEEK');
		
		controller.StringToDate('2009/12/31');
		controller.StringToDate('12/31/2009');
		controller.StringToDate('31/12/82');
		
		SVMXC.OFFL_ManageDataSets.wraperOfflObj_RefObj oWrpOffltest = new SVMXC.OFFL_ManageDataSets.wraperOfflObj_RefObj();
		oWrpOffltest.getobjOfflObj();
		oWrpOffltest.getobjObjlabel();
		
		//calling all the Tags
		system.assert(controller.getTAG001()!=null,'getTAG001 assertion failed');
		system.assert(controller.getTAG002()!=null,'getTAG002 assertion failed');
		system.assert(controller.getTAG003()!=null,'getTAG003 assertion failed');
		system.assert(controller.getTAG004()!=null,'getTAG004 assertion failed');
		system.assert(controller.getTAG005()!=null,'getTAG005 assertion failed');
		system.assert(controller.getTAG006()!=null,'getTAG006 assertion failed');
		system.assert(controller.getTAG007()!=null,'getTAG007 assertion failed');
		system.assert(controller.getTAG008()!=null,'getTAG008 assertion failed');
		system.assert(controller.getTAG009()!=null,'getTAG009 assertion failed');
		system.assert(controller.getTAG010()!=null,'getTAG010 assertion failed');
		system.assert(controller.getTAG011()!=null,'getTAG011 assertion failed');
		system.assert(controller.getTAG012()!=null,'getTAG012 assertion failed');
		system.assert(controller.getTAG013()!=null,'getTAG013 assertion failed');
		system.assert(controller.getTAG014()!=null,'getTAG014 assertion failed');
		system.assert(controller.getTAG015()!=null,'getTAG015 assertion failed');
		system.assert(controller.getTAG016()!=null,'getTAG016 assertion failed');
		system.assert(controller.getTAG017()!=null,'getTAG017 assertion failed');
		system.assert(controller.getTAG018()!=null,'getTAG018 assertion failed');
		system.assert(controller.getTAG019()!=null,'getTAG019 assertion failed');
		system.assert(controller.getTAG020()!=null,'getTAG020 assertion failed');
		system.assert(controller.getTAG021()!=null,'getTAG021 assertion failed');
		system.assert(controller.getTAG022()!=null,'getTAG022 assertion failed');
		system.assert(controller.getTAG023()!=null,'getTAG023 assertion failed');
		system.assert(controller.getTAG024()!=null,'getTAG024 assertion failed');
		system.assert(controller.getTAG025()!=null,'getTAG025 assertion failed');
		system.assert(controller.getTAG026()!=null,'getTAG026 assertion failed');
		system.assert(controller.getTAG027()!=null,'getTAG027 assertion failed');
		system.assert(controller.getTAG028()!=null,'getTAG028 assertion failed');
		system.assert(controller.getTAG029()!=null,'getTAG029 assertion failed');
		system.assert(controller.getTAG030()!=null,'getTAG030 assertion failed');
		system.assert(controller.getTAG031()!=null,'getTAG031 assertion failed');
		system.assert(controller.getTAG032()!=null,'getTAG032 assertion failed');
		system.assert(controller.getTAG033()!=null,'getTAG033 assertion failed');
		system.assert(controller.getTAG034()!=null,'getTAG034 assertion failed');
		system.assert(controller.getTAG035()!=null,'getTAG035 assertion failed');
		system.assert(controller.getTAG036()!=null,'getTAG036 assertion failed');
		system.assert(controller.getHLPURL()!=null,'getHLPURL assertion failed');
		system.assert(controller.getTAG037()!=null,'getTAG037 assertion failed');
		system.assert(controller.getTAG038()!=null,'getTAG038 assertion failed');
		system.assert(controller.getTAG039()!=null,'getTAG039 assertion failed');
		system.assert(controller.getTAG040()!=null,'getTAG040 assertion failed');
		system.assert(controller.getTAG041()!=null,'getTAG041 assertion failed');
		system.assert(controller.getTAG042()!=null,'getTAG042 assertion failed');
		system.assert(controller.getTAG043()!=null,'getTAG043 assertion failed');
		system.assert(controller.getTAG044()!=null,'getTAG044 assertion failed');
		system.assert(controller.getTAG045()!=null,'getTAG045 assertion failed');
		system.assert(controller.getTAG046()!=null,'getTAG046 assertion failed');
		system.assert(controller.getTAG047()!=null,'getTAG047 assertion failed');
		
		//controller.svmxTagList.clear();
		
		system.assert(controller.getTAG001()!=null,'getTAG001 assertion failed');
		system.assert(controller.getTAG002()!=null,'getTAG002 assertion failed');
		system.assert(controller.getTAG003()!=null,'getTAG003 assertion failed');
		system.assert(controller.getTAG004()!=null,'getTAG004 assertion failed');
		system.assert(controller.getTAG005()!=null,'getTAG005 assertion failed');
		system.assert(controller.getTAG006()!=null,'getTAG006 assertion failed');
		system.assert(controller.getTAG007()!=null,'getTAG007 assertion failed');
		system.assert(controller.getTAG008()!=null,'getTAG008 assertion failed');
		system.assert(controller.getTAG009()!=null,'getTAG009 assertion failed');
		system.assert(controller.getTAG010()!=null,'getTAG010 assertion failed');
		system.assert(controller.getTAG011()!=null,'getTAG011 assertion failed');
		system.assert(controller.getTAG012()!=null,'getTAG012 assertion failed');
		system.assert(controller.getTAG013()!=null,'getTAG013 assertion failed');
		system.assert(controller.getTAG014()!=null,'getTAG014 assertion failed');
		system.assert(controller.getTAG015()!=null,'getTAG015 assertion failed');
		system.assert(controller.getTAG016()!=null,'getTAG016 assertion failed');
		system.assert(controller.getTAG017()!=null,'getTAG017 assertion failed');
		system.assert(controller.getTAG018()!=null,'getTAG018 assertion failed');
		system.assert(controller.getTAG019()!=null,'getTAG019 assertion failed');
		system.assert(controller.getTAG020()!=null,'getTAG020 assertion failed');
		system.assert(controller.getTAG021()!=null,'getTAG021 assertion failed');
		system.assert(controller.getTAG022()!=null,'getTAG022 assertion failed');
		system.assert(controller.getTAG023()!=null,'getTAG023 assertion failed');
		system.assert(controller.getTAG024()!=null,'getTAG024 assertion failed');
		system.assert(controller.getTAG025()!=null,'getTAG025 assertion failed');
		system.assert(controller.getTAG026()!=null,'getTAG026 assertion failed');
		system.assert(controller.getTAG027()!=null,'getTAG027 assertion failed');
		system.assert(controller.getTAG028()!=null,'getTAG028 assertion failed');
		system.assert(controller.getTAG029()!=null,'getTAG029 assertion failed');
		system.assert(controller.getTAG030()!=null,'getTAG030 assertion failed');
		system.assert(controller.getTAG031()!=null,'getTAG031 assertion failed');
		system.assert(controller.getTAG032()!=null,'getTAG032 assertion failed');
		system.assert(controller.getTAG033()!=null,'getTAG033 assertion failed');
		system.assert(controller.getTAG034()!=null,'getTAG034 assertion failed');
		system.assert(controller.getTAG035()!=null,'getTAG035 assertion failed');
		system.assert(controller.getTAG036()!=null,'getTAG036 assertion failed');
		system.assert(controller.getHLPURL()!=null,'getHLPURL assertion failed');
		system.assert(controller.getTAG037()!=null,'getTAG037 assertion failed');
		system.assert(controller.getTAG038()!=null,'getTAG038 assertion failed');
		system.assert(controller.getTAG039()!=null,'getTAG039 assertion failed');
		system.assert(controller.getTAG040()!=null,'getTAG040 assertion failed');
		system.assert(controller.getTAG041()!=null,'getTAG041 assertion failed');
		system.assert(controller.getTAG042()!=null,'getTAG042 assertion failed');
		system.assert(controller.getTAG043()!=null,'getTAG043 assertion failed');
		system.assert(controller.getTAG044()!=null,'getTAG044 assertion failed');
		system.assert(controller.getTAG045()!=null,'getTAG045 assertion failed');
		system.assert(controller.getTAG046()!=null,'getTAG046 assertion failed');
		system.assert(controller.getTAG047()!=null,'getTAG047 assertion failed');
		test.stoptest();
	}
	
	static void testwhereclause(OFFL_ManageDataSets controller, string strField, string strOperator, string strOperand){
		
		SVMXC__Offline_Dataset_Expression__c o = new SVMXC__Offline_Dataset_Expression__c();
		o.SVMXC__Operator__c = strOperator; 
		o.SVMXC__Operand__c = strOperand;
		o.Name = strField;
		controller.buildWhereClause(false,o,1); 
		
	}
	
	static testMethod void OFFL_ManageDataSets_TestProcessSave(){
		OFFL_ManageDataSets controller = new OFFL_ManageDataSets();
		
		controller.delind = 1;
		SVMXC__Offline_Object__c offlineObjectprocessSave = new SVMXC__Offline_Object__c( SVMXC__Object_Name__c ='SVMXC__Service_Order__c');   
		controller.oOfflObj = offlineObjectprocessSave; 
		
		SVMXC__Offline_Object__c offlineObjectprocessSaveWrp1 = new SVMXC__Offline_Object__c( SVMXC__Object_Name__c ='account', SVMXC__Select__c = true);
		SVMXC__Offline_Object__c offlineObjectprocessSaveWrp2 = new SVMXC__Offline_Object__c( SVMXC__Object_Name__c ='account', SVMXC__Select__c = false);
		insert offlineObjectprocessSaveWrp2;
		
		SVMXC.OFFL_ManageDataSets.wraperOfflObj_RefObj oWrpOfflprocessSave1 = new SVMXC.OFFL_ManageDataSets.wraperOfflObj_RefObj();
		oWrpOfflprocessSave1.objOfflObj = offlineObjectprocessSaveWrp1;
		controller.lstWrpOfflObj_RefObj.add(oWrpOfflprocessSave1);
		SVMXC.OFFL_ManageDataSets.wraperOfflObj_RefObj oWrpOfflprocessSave2 = new SVMXC.OFFL_ManageDataSets.wraperOfflObj_RefObj();
		oWrpOfflprocessSave2.objOfflObj = offlineObjectprocessSaveWrp2; 
		controller.lstWrpOfflObj_RefObj.add(oWrpOfflprocessSave2);
		
		SVMXC__Offline_Object__c offlineObjectMCHprocessSave = new SVMXC__Offline_Object__c( SVMXC__Object_Name__c ='account');
		controller.lstOfflObj_MstChdList.add(offlineObjectMCHprocessSave);
		
		
		SVMXC__Offline_View__c objOfflViewprocessSave1 = new SVMXC__Offline_View__c( SVMXC__Field_Name__c = 'Origin');
		SVMXC__Offline_View__c objOfflViewprocessSave2 = new SVMXC__Offline_View__c( SVMXC__Field_Name__c = 'Account');
		insert objOfflViewprocessSave1;
		
		controller.lstOfflView.add(objOfflViewprocessSave1);
		controller.lstOfflView.add(objOfflViewprocessSave2);
		
		controller.lstSFieldsOpt.add(new selectOption('Account', 'Account'));
		controller.lstSFieldsOpt.add(new selectOption('ID', 'ID'));
		
		list<SVMXC__Offline_Dataset_Expression__c> lstOfflDtExpprocessSave = new list<SVMXC__Offline_Dataset_Expression__c >(); 
		SVMXC__Offline_Dataset_Expression__c objOfflDtExpprocessSave1 = new SVMXC__Offline_Dataset_Expression__c(SVMXC__Type__c = 'Download Criteria');
		SVMXC__Offline_Dataset_Expression__c objOfflDtExpprocessSave2 = new SVMXC__Offline_Dataset_Expression__c(SVMXC__Type__c = 'Download Criteria');
		
		insert objOfflDtExpprocessSave1;
		controller.lstOffl_DSExp.add(objOfflDtExpprocessSave1);
		controller.lstOffl_DSExp.add(objOfflDtExpprocessSave2);
		controller.lstOffl_DSExpDW.add(objOfflDtExpprocessSave2);
		controller.strAdvanceOption ='1';
		system.assertEquals('1',controller.strAdvanceOption);		
		system.assert(controller.SVMX_processSave()==null,'Asserion Failed');
		controller.lstSFieldsOpt.clear();
		controller.lstWrpOfflObj_RefObj.clear();
		controller.lstOfflObj_MstChdList.clear();
		controller.lstOfflView.clear();
		controller.lstOffl_DSExp.clear();
		controller.lstOffl_DSExpDW.clear();
		controller.lstOfflView.clear();		
			
		system.assert(controller.SVMX_doQuickSave()==null,'Asserion Failed');
		system.assert(controller.SVMX_doSave()==null,'Asserion Failed');
		system.assert(controller.SVMX_doCancel()==null,'Asserion Failed');
			
		controller.oOfflObj = null;
		controller.SVMX_doQuickSave();
		controller.SVMX_doSave();
		
	}
	
	static testMethod void OFFL_ManageDataSets_new_Test2(){
		Map<String, Schema.SObjectType> allObjs;
		allObjs = Schema.getGlobalDescribe();   
		Set<String> s =allObjs.keySet(); 
		List<String> reqObjName =new List<String>(); 
		
		//getting all the CustomObject  Name into the set 
		for(Schema.SObjectType lON : allObjs.values()){ //Loop List of all Objects and describe each
			Schema.DescribeSObjectResult D = lON.getDescribe(); 
			if(D.isAccessible() == true && D.isCustom() == true ){
			   reqObjName.add( D.getName() );
			}
		}
		
		//Adding some Standard Object Names 
		//reqObjName.add('SVMXC__Service_Order__c');
		reqObjName.add('Account');
		reqObjName.add('Contact');
		system.assert(reqObjName!=null,'Assertion failed');
		
		RecordType[] rtConf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];   
		Profile AdminProf = [Select Id, Name From Profile where Name='System Administrator'];
		
		// creating the profile object
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
		
		SVMXC__Offline_Object__c offlineObjecttest = new SVMXC__Offline_Object__c(SVMXC__Object_Name__c ='Account',SVMXC__Offline_Profile__c = confProf.Id);
		insert offlineObjecttest;
		system.assertEquals('Account',offlineObjecttest.SVMXC__Object_Name__c);
		
		PageReference pageRef2 = new PageReference('Page.SVMXC.OFFL_ManageDataSets');
		pageRef2.getParameters().put('pid', confProf.id);
		Test.setCurrentPage(pageRef2);
		OFFL_ManageDataSets controller = new OFFL_ManageDataSets();
		
	}    
}