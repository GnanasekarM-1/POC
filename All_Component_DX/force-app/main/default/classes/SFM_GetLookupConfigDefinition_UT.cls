/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SFM_GetLookupConfigDefinition_UT {

    static testMethod void SFM_GetLookupConfigDefinition_Test() {
        // TO DO: implement unit test
        
        
        String namedSearch;
    	String expression;
    	List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0){
        	for(RecordType r : RTypeList){
        		if(r.Name == 'Named Search')
        			namedSearch = r.id;
        		else if(r.Name == 'Expressions')
        			expression = r.id;		
        	}
        }
        SVMXC__ServiceMax_Processes__c LookupConfigTop = new SVMXC__ServiceMax_Processes__c();
       	LookupConfigTop.RecordTypeId = namedSearch;
       	LookupConfigTop.SVMXC__Name__c = 'Lookup Config For WO';
        LookupConfigTop.SVMXC__Default_Lookup_Column__c = 'Name';
        LookupConfigTop.SVMXC__Number_of_Lookup_Records__c = 10;
        LookupConfigTop.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        LookupConfigTop.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
        LookupConfigTop.SVMXC__ProcessID__c = 'Lookup Config For WO';
        insert LookupConfigTop;
        
        SVMXC__ServiceMax_Processes__c LookupConfig1 = new SVMXC__ServiceMax_Processes__c();
        LookupConfig1.SVMXC__Module__c = LookupConfigTop.id;
        LookupConfig1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        LookupConfig1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        LookupConfig1.RecordTypeId = namedSearch;
        LookupConfig1.SVMXC__ProcessID__c = 'Lookup Config For WO';
        insert LookupConfig1;
        
        SVMXC__ServiceMax_Processes__c LookupConfig2 = new SVMXC__ServiceMax_Processes__c();
        LookupConfig2.SVMXC__Module__c = LookupConfigTop.id;
        LookupConfig2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        LookupConfig2.SVMXC__Rule_Type__c = 'SRCH_CRITERIA';
        LookupConfig2.RecordTypeId = namedSearch;
        LookupConfig2.SVMXC__ProcessID__c = 'Lookup Config For WO';
        insert LookupConfig2;
       
       	list<SVMXC__ServiceMax_Config_Data__c> lstCongigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c obj7 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=1,SVMXC__Search_Object_Field_Type__c='Result',
        SVMXC__Field_Name__c='SVMXC__Priority__c',SVMXC__Expression_Rule__c=LookupConfig1.Id,SVMXC__Expression_Type__c = 'SRCH_Object_Fields',
        RecordTypeId = expression);
        
        SVMXC__ServiceMax_Config_Data__c obj8 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=2,SVMXC__Search_Object_Field_Type__c='Search',
        SVMXC__Field_Name__c='SVMXC__Order_Type__c',SVMXC__Expression_Rule__c=LookupConfig1.Id,SVMXC__Expression_Type__c = 'SRCH_Object_Fields',
        RecordTypeId = expression);
        
        SVMXC__ServiceMax_Config_Data__c obj9 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=3,SVMXC__Search_Object_Field_Type__c='Search',
        SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=LookupConfig1.Id,SVMXC__Display_Type__c='PICKLIST',
        SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = expression); 
        
        SVMXC__ServiceMax_Config_Data__c obj10 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=4,SVMXC__Search_Object_Field_Type__c='Result',
        SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=LookupConfig1.Id,SVMXC__Display_Type__c='String',
        SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = expression);
       	
       	SVMXC__ServiceMax_Config_Data__c obj11 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=5,SVMXC__Search_Object_Field_Type__c='Result',
       	SVMXC__Field_Name__c='SVMXC__Company__c',SVMXC__Expression_Rule__c=LookupConfig1.Id,SVMXC__Display_Type__c='REFERENCE',
       	SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = expression, SVMXC__Field_Relationship_Name__c = 'SVMXC__Company__r', 
       	SVMXC__FKey_Name_Field__c = 'Name', SVMXC__Object_Name__c='Account');
       	
       	SVMXC__ServiceMax_Config_Data__c obj12 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=6,SVMXC__Search_Object_Field_Type__c='BUBBLE',
       	SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Expression_Rule__c=LookupConfig1.Id,SVMXC__Display_Type__c='String',
       	SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = expression);
       	
       	SVMXC__ServiceMax_Config_Data__c obj13 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=7,SVMXC__Search_Object_Field_Type__c='BUBBLE',
       	SVMXC__Field_Name__c='SVMXC__Company__c',SVMXC__Expression_Rule__c=LookupConfig1.Id,SVMXC__Display_Type__c='REFERENCE',
       	SVMXC__Expression_Type__c = 'SRCH_Object_Fields',RecordTypeId = expression, SVMXC__Field_Relationship_Name__c = 'SVMXC__Company__r', 
       	SVMXC__FKey_Name_Field__c = 'Name', SVMXC__Object_Name__c='Account'); 
      	
      	lstCongigData.add(obj10);
        lstCongigData.add(obj11);
        lstCongigData.add(obj13);
        lstCongigData.add(obj7);
        lstCongigData.add(obj8);
        lstCongigData.add(obj9);
        lstCongigData.add(obj12);
        
        insert lstCongigData;
        
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        SVMXC.SFM_WrapperDef.SFM_StringListMap stringListMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
        stringListMap.key = 'LOOKCONFIGID';
		stringListMap.valueList.add(LookupConfigTop.id);
		request.stringListMap.add(stringListMap);
		SVMXC.SFM_GetLookupConfigDefinition lookup = new SVMXC.SFM_GetLookupConfigDefinition(); 
		lookup.getLookupConfigDefinition(request);
    }
}