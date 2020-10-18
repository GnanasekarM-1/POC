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
private class SFM_CreateSubProcess_UT 
{
	private static map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    private static map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
	private SFM_CreateSubProcess_UT()
	{
		gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            Schema.DescribeSObjectResult result = s.getDescribe();
            allobjmap.put(result.getName(),s);
        }
	}
    
    static testMethod void SFM_CreateSubProcessTest() 
    {
        // TO DO: implement unit test
        String targetManager;
    	String processNodeObjects;
    	String objectMapping; 
	    String fieldMapping;
	    String expression;
	    String SVMXRule;
    	List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
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
        	}
        }
    	//Create PageHeader
    	SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
    	PageHeader.SVMXC__Name__c = 'PAGE00001';
    	PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
    	PageHeader.SVMXC__Type__c = 'Header';
    	insert PageHeader;
    	//Create PageDetail
    	SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
    	PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
    	PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
    	PageDetail.SVMXC__Type__c = 'Detail';
    	insert PageDetail;
    	
    	//Create SFM Process Defination
    	SVMXC__ServiceMax_Processes__c SourceToTargetAll = new SVMXC__ServiceMax_Processes__c();
    	SourceToTargetAll.SVMXC__Name__c = 'CUSTOMPRO0001';
    	SourceToTargetAll.RecordTypeId = targetManager;
    	SourceToTargetAll.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL';
    	SourceToTargetAll.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
    	SourceToTargetAll.SVMXC__Page_Layout__c = PageHeader.id;
    	insert SourceToTargetAll;
    	
    	//Create Mapping For Header Record
    	SVMXC__ServiceMax_Processes__c valMapHdr = new SVMXC__ServiceMax_Processes__c();
    	valMapHdr.SVMXC__MapID__c = 'VMAP000001';
    	valMapHdr.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
    	valMapHdr.RecordTypeId = objectMapping;
    	insert valMapHdr;
    	//Create Mapping For Detail Record
    	SVMXC__ServiceMax_Processes__c valMapDetail = new SVMXC__ServiceMax_Processes__c();
    	valMapDetail.SVMXC__MapID__c = 'VMAP000002';
    	valMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
    	valMapDetail.RecordTypeId = objectMapping;
    	insert valMapDetail;
    	
    	//Creating object mapping for details 
    	SVMXC__ServiceMax_Processes__c objMapDetail = new SVMXC__ServiceMax_Processes__c();
    	objMapDetail.SVMXC__MapID__c = 'OBJMAPDETAIL001';
    	objMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
    	objMapDetail.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
    	objMapDetail.RecordTypeId = objectMapping;
    	insert objMapDetail;
    	
    	//Creating field mapping reocrds for detail 
    	list<SVMXC__ServiceMax_Config_Data__c> lstFieldMapping = new list<SVMXC__ServiceMax_Config_Data__c>();
    	SVMXC__ServiceMax_Config_Data__c fldmap1 = new SVMXC__ServiceMax_Config_Data__c();
    	fldmap1.RecordTypeId = fieldMapping;
    	fldmap1.SVMXC__Source_Field_Name__c = 'SVMXC__Discount__c';
    	fldmap1.SVMXC__Target_Field_Name__c = 'SVMXC__Discount__c';
    	fldmap1.SVMXC__Configuration_Type__c = 'Field Mapping';
    	fldmap1.SVMXC__MapID__c = objMapDetail.id;
    	lstFieldMapping.add(fldmap1);
    	SVMXC__ServiceMax_Config_Data__c fldmap2 = new SVMXC__ServiceMax_Config_Data__c();
    	fldmap2.RecordTypeId = fieldMapping;
    	fldmap2.SVMXC__Source_Field_Name__c = 'SVMXC__Discount_Type__c';
    	fldmap2.SVMXC__Target_Field_Name__c = 'SVMXC__Discount_Type__c';
    	fldmap2.SVMXC__Configuration_Type__c = 'Field Mapping';
    	fldmap2.SVMXC__MapID__c = objMapDetail.id;
    	lstFieldMapping.add(fldmap2);
    	insert lstFieldMapping;
    	
    	
    	//Create Expression Record
    	SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
    	ExpressionRec.RecordTypeId = SVMXRule;
    	ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
    	ExpressionRec.SVMXC__Name__c = 'EXpression111';
    	ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
    	insert ExpressionRec;
    	
    	//Create Process Node object Records.
    	list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
    	SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
    	PNObject1.RecordTypeId = processNodeObjects;
    	PNObject1.SVMXC__Type__c = 'TARGET';
    	PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
    	PNObject1.SVMXC__Process__c = SourceToTargetAll.id;
    	PNObject1.SVMXC__Submodule__c = ExpressionRec.id;
    	PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
    	PNObject1.SVMXC__Module__c = valMapHdr.id;
    	PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote__c';
    	listProcessNodeObjects.add(PNObject1);
    	
    	SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
    	PNObject2.RecordTypeId = processNodeObjects;
    	PNObject2.SVMXC__Type__c = 'TARGETCHILD';
    	PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
    	PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
    	PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
    	PNObject2.SVMXC__Process__c = SourceToTargetAll.id;
    	//PNObject2.SVMXC__Submodule__c = ExpressionRec.id;
    	PNObject2.SVMXC__Module__c = objMapDetail.id;
    	PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
    	PNObject2.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote_Line__c';
    	listProcessNodeObjects.add(PNObject2);
    	
    	SVMXC__ServiceMax_Processes__c PNObject3 = new SVMXC__ServiceMax_Processes__c();
    	PNObject3.RecordTypeId = processNodeObjects;
    	PNObject3.SVMXC__Type__c = 'SOURCE';
    	PNObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
    	PNObject3.SVMXC__Process__c = SourceToTargetAll.id;
    	PNObject3.SVMXC__Final_Exception_Process__c = valMapHdr.id;
    	listProcessNodeObjects.add(PNObject3);
    	
    	SVMXC__ServiceMax_Processes__c PNObject4 = new SVMXC__ServiceMax_Processes__c();
    	PNObject4.RecordTypeId = processNodeObjects;
    	PNObject4.SVMXC__Type__c = 'SOURCECHILD';
    	PNObject4.SVMXC__Page_Layout__c = PageDetail.id;
    	PNObject4.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
    	PNObject4.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
    	PNObject4.SVMXC__Process__c = SourceToTargetAll.id;
    	PNObject4.SVMXC__Final_Exception_Process__c = valMapDetail.id;
    	listProcessNodeObjects.add(PNObject4);
    	insert listProcessNodeObjects;
    	
    	SVMXC__Quote__c Quote = new SVMXC__Quote__c();
    	Quote.SVMXC__Discount__c  = 10;
    	Quote.SVMXC__Discount_Type__c = 'amount';
    	Quote.SVMXC__Valid_Until__c = system.today() + 15;
    	insert Quote;
    	SVMXC__Quote_Line__c QLine = new SVMXC__Quote_Line__c();
    	QLine.SVMXC__Quote__c = Quote.id;
    	QLine.SVMXC__Discount__c  = 10;
    	QLine.SVMXC__Discount_Type__c = 'amount';
    	insert QLine;
    	SVMXC__Quote_Line__c QLine1 = new SVMXC__Quote_Line__c();
    	QLine1.SVMXC__Quote__c = Quote.id;
    	QLine1.SVMXC__Discount__c  = 10;
    	QLine1.SVMXC__Discount_Type__c = 'amount';
    	insert QLine1;
    	Test.startTest();
    	SVMXC.SFM_CreateSubProcess obj = new SVMXC.SFM_CreateSubProcess();
    	obj.createSubProcess(SourceToTargetAll.id, Quote.id, allobjmap, Quote);
    	Test.stopTest();
    }
}