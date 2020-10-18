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
private class SFM_ClonePageLayout_UT {

    static testMethod void SFM_ClonePageLayout_Test() {
        
        String targetManager;
    	String processNodeObjects;
    	String objectMapping; 
	    String fieldMapping;
	    String expression;
	    String SVMXRule;
	    String nameSearch;
    	List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        
        if(RTypeList.size() > 0)
        {
        	for(RecordType r : RTypeList)
        	{
        		if(r.Name == 'Target Manager')
        			targetManager = r.id; 
        		else if(r.Name ==  'Process Node Objects')
        			processNodeObjects = r.id;
        		else if(r.Name == 'Object Mapping')
        			objectMapping = r.id;
        		else if(r.Name == 'Field Mapping')
        			fieldMapping = r.id;
        		else if(r.Name == 'Expressions')
        			expression = r.id;	
        		else if(r.Name == 'SVMX Rule')
        			SVMXRule = r.id;	
        		else if(r.Name == 'Named Search')	
        			nameSearch = r.id;	
        	}
        }
        
        SVMXC__ServiceMax_Processes__c objNameSearch = new SVMXC__ServiceMax_Processes__c();
        objNameSearch.RecordTypeId=nameSearch;
        objNameSearch.SVMXC__IsDefault__C=true;
        objNameSearch.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
        objNameSearch.SVMXC__ProcessID__c='Account Lookup Config';
        objNameSearch.SVMXC__Source_Object_Name__c = 'Account';
        objNameSearch.SVMXC__Default_Lookup_Column__c = 'Name';
        insert objNameSearch;
        
        SVMXC__ServiceMax_Processes__c objNameSearch1 = new SVMXC__ServiceMax_Processes__c();
        objNameSearch1.RecordTypeId=nameSearch;
        objNameSearch1.SVMXC__IsDefault__C=true;
        objNameSearch1.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
        objNameSearch1.SVMXC__ProcessID__c='Product Lookup Config';
        objNameSearch1.SVMXC__Source_Object_Name__c = 'Product2';
        objNameSearch1.SVMXC__Default_Lookup_Column__c = 'Name';
        insert objNameSearch1;
    	//Create Header Page layout
    	SVMXC__Page_Layout__c objHeaderLayout = new SVMXC__Page_Layout__c();
        objHeaderLayout.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        objHeaderLayout.SVMXC__Type__c = 'Header';
        insert objHeaderLayout;
        System.assertEquals(true, objHeaderLayout != null);
        //Create Detail Page layout
        SVMXC__Page_Layout__c objDetailLayout = new SVMXC__Page_Layout__c();
        objDetailLayout.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        objDetailLayout.SVMXC__Type__c = 'Detail';
        objDetailLayout.SVMXC__Header_Page_Layout__c = objHeaderLayout.Id;
        objDetailLayout.SVMXC__Header_Reference_Field__c = 'SVMXC__Quote__c';
        insert objDetailLayout; 
        
        //Create Sections for header 
        list<SVMXC__Page_Layout_Detail__c> lstSection = new list<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c objSection1 = new SVMXC__Page_Layout_Detail__c();
        objSection1.SVMXC__Detail_Type__c = 'Section';
        objSection1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        objSection1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objSection1.SVMXC__Title__c = 'Service Quote';
        objSection1.SVMXC__Sequence__c = 1;
        lstSection.add(objSection1);
        SVMXC__Page_Layout_Detail__c objSection2 = new SVMXC__Page_Layout_Detail__c();
        objSection2.SVMXC__Detail_Type__c = 'Section';
        objSection2.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout2';
        objSection2.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objSection2.SVMXC__Sequence__c = 2;
        lstSection.add(objSection2);
        insert lstSection;
       
       	//Create Fields for Header Layout
        List<SVMXC__Page_Layout_Detail__c> lstHeaderFields = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c objfld1 = new SVMXC__Page_Layout_Detail__c();
        objfld1.SVMXC__Detail_Type__c = 'Field';
        objfld1.SVMXC__Field_API_Name__c = 'SVMXC__Company__c';
        objfld1.SVMXC__Related_Object_Name__c = 'Account';
        objfld1.SVMXC__Related_Object_Name_Field__c = 'Name';
        objfld1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld1.SVMXC__Section__c = lstSection[0].Id;
        objfld1.SVMXC__DataType__c = 'REFERENCE';
        objfld1.SVMXC__Sequence__c = 1;
        objfld1.SVMXC__Named_Search__c = objNameSearch.id;
        lstHeaderFields.add(objfld1);
        SVMXC__Page_Layout_Detail__c objfld2 = new SVMXC__Page_Layout_Detail__c();
        objfld2.SVMXC__Detail_Type__c = 'Field';
        objfld2.SVMXC__Field_API_Name__c = 'SVMXC__Discount__c';
        objfld2.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld2.SVMXC__Section__c = lstSection[0].Id;
        objfld2.SVMXC__DataType__c = 'DOUBLE';
        objfld2.SVMXC__Sequence__c = 2;
        lstHeaderFields.add(objfld2);
        SVMXC__Page_Layout_Detail__c objfld3 = new SVMXC__Page_Layout_Detail__c();
        objfld3.SVMXC__Detail_Type__c = 'Field';
        objfld3.SVMXC__Field_API_Name__c = 'SVMXC__Discount_Type__c';
        objfld3.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld3.SVMXC__Section__c = lstSection[1].Id;
        objfld3.SVMXC__DataType__c = 'PICKLIST';
        objfld3.SVMXC__Sequence__c = 1;
        lstHeaderFields.add(objfld3);
        insert lstHeaderFields;
        //Create Fields for Detail Layout
        List<SVMXC__Page_Layout_Detail__c> lstDetailFields = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c objfld4 = new SVMXC__Page_Layout_Detail__c();
        objfld4.SVMXC__Detail_Type__c = 'Field';
        objfld4.SVMXC__Field_API_Name__c = 'SVMXC__Product__c';
        objfld4.SVMXC__Related_Object_Name__c = 'Product2';
        objfld4.SVMXC__Related_Object_Name_Field__c = 'Name';
        objfld4.SVMXC__Page_Layout__c = objDetailLayout.Id;
        objfld4.SVMXC__DataType__c = 'REFERENCE';
        objfld4.SVMXC__Sequence__c = 1;
        objfld4.SVMXC__Named_Search__c = objNameSearch1.id;
        lstDetailFields.add(objfld4);
        SVMXC__Page_Layout_Detail__c objfld5 = new SVMXC__Page_Layout_Detail__c();
        objfld5.SVMXC__Detail_Type__c = 'Field';
        objfld5.SVMXC__Field_API_Name__c = 'SVMXC__Line_Description__c';
        objfld5.SVMXC__Page_Layout__c = objDetailLayout.Id;
        objfld5.SVMXC__DataType__c = 'TEXTAREA';
        objfld5.SVMXC__Sequence__c = 2;
        lstDetailFields.add(objfld5);
        insert lstDetailFields;
        System.assertEquals(true, lstDetailFields != null);
        
        //Create Buttons
        SVMXC__Page_Layout_Detail__c Button1 = new SVMXC__Page_Layout_Detail__c();
        Button1.SVMXC__Detail_Type__c = 'Button';
        Button1.SVMXC__Title__c = 'Get Price';
        Button1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        Button1.SVMXC__Sequence__c = 2;
        insert Button1;
        SVMXC__Page_Layout_Detail__c Button2 = new SVMXC__Page_Layout_Detail__c();
        Button2.SVMXC__Detail_Type__c = 'Button';
        Button2.SVMXC__Title__c = 'Get Price';
        Button2.SVMXC__Page_Layout__c = objDetailLayout.Id;
        Button2.SVMXC__Sequence__c = 2;
        insert Button2;
        
        //Create Events 
        List<SVMXC__SFM_Event__c> lstEvents = new List<SVMXC__SFM_Event__c>();
        SVMXC__SFM_Event__c PageEvent = new SVMXC__SFM_Event__c();
        PageEvent.SVMXC__Event_Type__c = 'On Page Load';
        PageEvent.SVMXC__Event_Type__c = 'WEBSERVICE';
        PageEvent.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        PageEvent.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        lstEvents.add(PageEvent);
        SVMXC__SFM_Event__c DetailPageEvent = new SVMXC__SFM_Event__c();
        DetailPageEvent.SVMXC__Event_Type__c = 'On Page Load';
        DetailPageEvent.SVMXC__Event_Type__c = 'WEBSERVICE';
        DetailPageEvent.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        DetailPageEvent.SVMXC__Page_Layout__c = objDetailLayout.Id;
        lstEvents.add(DetailPageEvent);
        SVMXC__SFM_Event__c ButtonEvent = new SVMXC__SFM_Event__c();
        ButtonEvent.SVMXC__Event_Type__c = 'On Button Click';
        ButtonEvent.SVMXC__Event_Type__c = 'WEBSERVICE';
        ButtonEvent.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        ButtonEvent.SVMXC__Page_Layout_Detail__c = Button1.Id;
        lstEvents.add(ButtonEvent);
        SVMXC__SFM_Event__c ButtonEvent2 = new SVMXC__SFM_Event__c();
        ButtonEvent2.SVMXC__Event_Type__c = 'On Button Click';
        ButtonEvent2.SVMXC__Event_Type__c = 'WEBSERVICE';
        ButtonEvent2.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        ButtonEvent2.SVMXC__Page_Layout_Detail__c = Button2.Id;
        lstEvents.add(ButtonEvent2);
        SVMXC__SFM_Event__c FieldChange = new SVMXC__SFM_Event__c();
        FieldChange.SVMXC__Event_Type__c = 'Field Change';
        FieldChange.SVMXC__Event_Type__c = 'WEBSERVICE';
        FieldChange.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        FieldChange.SVMXC__Page_Layout_Detail__c = lstHeaderFields[0].Id;
        lstEvents.add(FieldChange);
        insert lstEvents;
        System.assertEquals(true, lstEvents != null);
        
        
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        SVMXC.SFM_WrapperDef.SFM_StringMap StringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
		StringMap.key = 'PAGEID';
		StringMap.value = objHeaderLayout.id;
		request.stringMap.add(StringMap);
		SVMXC.SFM_WrapperDef.SFM_StringMap StringMap1 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
		StringMap1.key = 'CLIENT_TYPE';
		StringMap1.value = 'DESIGNER';
		request.stringMap.add(StringMap1);
		SVMXC.SFM_ClonePageLayout clonePage = new SVMXC.SFM_ClonePageLayout();
		clonePage.clonePageLayout(request); 
    }
}