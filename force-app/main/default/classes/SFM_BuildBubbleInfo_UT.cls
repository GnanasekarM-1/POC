@isTest(SeeAllData=true)
private class SFM_BuildBubbleInfo_UT 
{
	
	static testMethod void SFM_getNamedSearchInfo_Test()
    {
		Product2 pro = new Product2();
       	pro.Name = 'ServicemaxSuite';
      	pro.Family = 'asdf';
        pro.ProductCode = '001';
        insert pro;
		List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Named Search'];
   		SVMXC__ServiceMax_Processes__c processobj1 = new SVMXC__ServiceMax_Processes__c();
   		processobj1.RecordTypeId = lstRecType[0].Id;
	   	processobj1.SVMXC__Name__C = 'Headerprocess';
	   	processobj1.SVMXC__Description__c ='this is header process';
	   	processobj1.SVMXC__ProcessID__c = 'process001';
	   	processobj1.SVMXC__Rule_Type__c ='Automatic';
	   	processobj1.SVMXC__Active__c = true;
	   	insert processobj1;
	   	System.assertEquals(true, processobj1 != null);
   
   		SVMXC__ServiceMax_Processes__c processobj2 = new SVMXC__ServiceMax_Processes__c();
   		processobj2.RecordTypeId = lstRecType[0].Id ;                                                //required
   		processobj2.SVMXC__ProcessID__c='PROCESS11';
	   	processobj2.SVMXC__SettingId__c = 'PROCESS11';
	   	processobj2.SVMXC__MapID__c='PROCESS11';
	   	processobj2.SVMXC__Name__c = 'PROCESS22';
	   	processobj2.SVMXC__Process__c = processobj1.Id ;
	   	processobj2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
	   	processobj2.SVMXC__Module__c = processobj1.Id ;
	   	processobj2.SVMXC__Sequence__c = 12345 ;
	   	processobj2.SVMXC__IsDefault__C = false ;
	   	processobj2.SVMXC__Rule_Type__c='NAMEDSEARCH';
	   	insert processobj2;// We should use Test.startTest and Test.stopTest method
	   	System.assertEquals(true, processobj2 != null);
 
  		SVMXC__ServiceMax_Config_Data__c configDataObj1 = new SVMXC__ServiceMax_Config_Data__c();
	  	configDataObj1.SVMXC__Search_Object_Field_Type__c = 'Bubble';
	  	configDataObj1.SVMXC__Expression_Rule__c = processobj1.Id ;
	  	configDataObj1.SVMXC__Field_Name__c = 'Name';
	  	SVMXC__ServiceMax_Config_Data__c configDataObj2 = new SVMXC__ServiceMax_Config_Data__c();
	  	configDataObj2.SVMXC__Search_Object_Field_Type__c = 'Bubble';
	  	configDataObj2.SVMXC__Expression_Rule__c = processobj1.Id ;
	  	configDataObj2.SVMXC__Field_Name__c = 'Family';
	  	SVMXC__ServiceMax_Config_Data__c configDataObj3 = new SVMXC__ServiceMax_Config_Data__c();
	  	configDataObj3.SVMXC__Search_Object_Field_Type__c = 'Bubble';
	  	configDataObj3.SVMXC__Expression_Rule__c = processobj1.Id ;
	  	configDataObj3.SVMXC__Field_Name__c = 'ProductCode';
	  	List<SVMXC__ServiceMax_Config_Data__c> LstconfigDataObj = new List<SVMXC__ServiceMax_Config_Data__c>();
	  	LstconfigDataObj.add(configDataObj1);
	  	LstconfigDataObj.add(configDataObj2);
	  	LstconfigDataObj.add(configDataObj3);
  		insert LstconfigDataObj ;
  		//create stringmap InfoType
		list<SVMXC.SFM_WrapperDef.SFM_StringMap> StringMapList = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>(); 
		SVMXC.SFM_WrapperDef.SFM_StringMap strmap1 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
		strmap1.key = 'INFOTYPE';
		strmap1.value = 'BUBBLE';
		//create stringmap Lookup config Id
		SVMXC.SFM_WrapperDef.SFM_StringMap strmap2 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
		strmap2.key = 'RECORDID';
		strmap2.value = processobj1.id; 
		//create stringmap Record Id
		SVMXC.SFM_WrapperDef.SFM_StringMap strmap3 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
		strmap3.key = 'SEARCHRECORD';
		strmap3.value = pro.id;
		SVMXC.SFM_WrapperDef.SFM_StringMap strmap4 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
		strmap4.key = 'OBJECTNAME';
		strmap4.value = 'Product2';
		StringMapList.add(strmap1);
		StringMapList.add(strmap2);
		StringMapList.add(strmap3);
		StringMapList.add(strmap4);
		SVMXC.SFM_WrapperDef.SFM_Request SFMRequest = new SVMXC.SFM_WrapperDef.SFM_Request(); 
		SFMRequest.stringMap = StringMapList;
		SFM_BuildBubbleInfo bubble = new SFM_BuildBubbleInfo();
		bubble.getbubbleinfo(SFMRequest);
    }	
}