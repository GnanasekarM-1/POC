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
private class SFM_DocTemplateUtils_UT {

    static testMethod void SFM_GetDocTemplateInfo_UT() {
        
        SVMXC__Doc_Template__c objDocTemplate = new SVMXC__Doc_Template__c(SVMXC__Name__c = 'Doc Template', SVMXC__Template_Id__c = 'CUSTOMDOCTEMP001');
        insert objDocTemplate;
        list<SVMXC__Doc_Template_Details__c> lstDetails = new list<SVMXC__Doc_Template_Details__c>(); 
        SVMXC__Doc_Template_Details__c objDetail1 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Type__c = 'Header_Object',SVMXC__Doc_Template__c = objDocTemplate.id);
        lstDetails.add(objDetail1);
        SVMXC__Doc_Template_Details__c objDetail2 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c',SVMXC__Type__c = 'Detail_Object',SVMXC__Doc_Template__c = objDocTemplate.id);
        lstDetails.add(objDetail2);
        insert lstDetails;
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'SFM_Doc_Template.html';
        objAttachment.Body = Blob.valueOf('I am Body of attachment');
        objAttachment.ParentId = objDocTemplate.id;
        insert objAttachment;
        Test.startTest();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request(); 
        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'TEMPLATEID';
        strmap.value = objDocTemplate.id;
        request.stringMap.add(strmap);
        system.assert(request!=null);
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        docTemp.SFM_GetDocTemplateInfo(request);
        Test.stopTest();
    
    }
    static testMethod void SFM_GetListOfDocTemplates_UT() {
        SVMXC__Doc_Template__c objDocTemplate = new SVMXC__Doc_Template__c(SVMXC__Name__c = 'Doc Template', SVMXC__Template_Id__c = 'CUSTOMDOCTEMP001');
        insert objDocTemplate;
        SVMXC__Doc_Template__c objDocTemplate1 = new SVMXC__Doc_Template__c(SVMXC__Name__c = 'Doc Template1', SVMXC__Template_Id__c = 'CUSTOMDOCTEMP002');
        insert objDocTemplate1;
        list<SVMXC__Doc_Template_Details__c> lstDetails = new list<SVMXC__Doc_Template_Details__c>(); 
        SVMXC__Doc_Template_Details__c objDetail1 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Type__c = 'Header_Object',SVMXC__Doc_Template__c = objDocTemplate.id);
        lstDetails.add(objDetail1);
        SVMXC__Doc_Template_Details__c objDetail2 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c',SVMXC__Type__c = 'Detail_Object',SVMXC__Doc_Template__c = objDocTemplate.id);
        lstDetails.add(objDetail2);
        SVMXC__Doc_Template_Details__c objDetail3 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Type__c = 'Header_Object',SVMXC__Doc_Template__c = objDocTemplate1.id);
        lstDetails.add(objDetail3);
        insert lstDetails;
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'SFM_Doc_Template.html';
        objAttachment.Body = Blob.valueOf('I am Body of attachment');
        objAttachment.ParentId = objDocTemplate.id;
        insert objAttachment;
        Attachment objAttachment1 = new Attachment();
        objAttachment1.Name = 'SFM_Doc_Template.html';
        objAttachment1.Body = Blob.valueOf('I am Body of attachment');
        objAttachment1.ParentId = objDocTemplate1.id;
        insert objAttachment1;
        Test.startTest();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request(); 
        SVMXC.SFM_WrapperDef.SFM_StringListMap strLstMap1 = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
        SVMXC.SFM_WrapperDef.SFM_StringListMap strLstMap2 = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
        list<String> lstHeaderObj = new list<String>();
        list<String> lstDetailObj = new list<String>();
        lstHeaderObj.add('SVMXC__Service_Order__c'); 
        lstDetailObj.add('SVMXC__Service_Order_Line__c');
        strLstMap1.key = 'TARGET';
        strLstMap1.valueList = lstHeaderObj;
        strLstMap2.key = 'TARGETCHILD';
        strLstMap2.valueList = lstDetailObj;
        request.stringListMap.add(strLstMap1);
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        docTemp.SFM_GetListOfDocTemplates(request);
        request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.stringListMap.add(strLstMap1);
        request.stringListMap.add(strLstMap2);
        system.assert(request!=null);
        docTemp.SFM_GetListOfDocTemplates(request);
        Test.stopTest();
    }
    static testMethod void SFM_DeleteDocTemplate_UT() {
        SVMXC__Doc_Template__c objDocTemplate = new SVMXC__Doc_Template__c(SVMXC__Name__c = 'Doc Template', SVMXC__Template_Id__c = 'CUSTOMDOCTEMP001');
        insert objDocTemplate;
        list<SVMXC__Doc_Template_Details__c> lstDetails = new list<SVMXC__Doc_Template_Details__c>(); 
        SVMXC__Doc_Template_Details__c objDetail1 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Type__c = 'Header_Object',SVMXC__Doc_Template__c = objDocTemplate.id);
        lstDetails.add(objDetail1);
        SVMXC__Doc_Template_Details__c objDetail2 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c',SVMXC__Type__c = 'Detail_Object',SVMXC__Doc_Template__c = objDocTemplate.id);
        lstDetails.add(objDetail2);
        insert lstDetails;
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'SFM_Doc_Template.html';
        objAttachment.Body = Blob.valueOf('I am Body of attachment');
        objAttachment.ParentId = objDocTemplate.id;
        insert objAttachment;
        
        RecordType targetManager = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' and  Name = 'Target Manager'];
        SVMXC__ServiceMax_Processes__c outputDoc = new SVMXC__ServiceMax_Processes__c();
        outputDoc.SVMXC__Name__c = 'CUSTOMPRO0001';
        outputDoc.RecordTypeId = targetManager.id;
        outputDoc.SVMXC__Purpose__c = 'OUTPUT DOC';
        outputDoc.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        insert outputDoc;
        Test.startTest();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request(); 
        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        SVMXC.SFM_WrapperDef.SFM_StringMap strmap1 = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'TEMPLATEID';
        strmap.value = objDocTemplate.id;
        strmap1.key = 'PROCESSID';
        strmap1.value = outputDoc.id;
        request.stringMap.add(strmap);
        request.stringMap.add(strmap1);
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        docTemp.SFM_DeleteDocTemplate(request);
        
        objDocTemplate = new SVMXC__Doc_Template__c(SVMXC__Name__c = 'Doc Template', SVMXC__Template_Id__c = 'CUSTOMDOCTEMP001');
        insert objDocTemplate;
        objAttachment = new Attachment();
        objAttachment.Name = 'SFM_Doc_Template.html';
        objAttachment.Body = Blob.valueOf('I am Body of attachment');
        objAttachment.ParentId = objDocTemplate.id;
        insert objAttachment;
        request = new SVMXC.SFM_WrapperDef.SFM_Request(); 
        strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        strmap.key = 'TEMPLATEID';
        strmap.value = objDocTemplate.id;
        system.assert(request!=null);
        request.stringMap.add(strmap);
        docTemp.SFM_DeleteDocTemplate(request);
        Test.stopTest();
    
    }
    static testMethod void SFM_GetFunctions_UT() {
        SVMXC__Function_Definition__c objMD = new SVMXC__Function_Definition__c();
        objMD.SVMXC__IsActive__c = true;
        objMD.SVMXC__Macro_Name__c = 'CUSTOMMACRO00001';
        objMD.SVMXC__Type__c = 'String';
        insert objMD;
        Test.startTest();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request(); 
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        docTemp.SFM_GetFunctions(request);
        Test.stopTest();
    
        
    }
    static testMethod void SFM_SaveDocTemplate_UT() {
        SVMXC.SFM_WrapperDef.SFM_DocTemplate docTemplate = new SVMXC.SFM_WrapperDef.SFM_DocTemplate(); 
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        String targetManager;
    	List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
        	for(RecordType r : RTypeList)
        	{
        		if(r.Name == 'Target Manager')
        			targetManager = r.id;
        	}
        }
        SVMXC__ServiceMax_Processes__c outputDocument = new SVMXC__ServiceMax_Processes__c();
    	outputDocument.SVMXC__Name__c = 'CUSTOMPRO0001';
    	outputDocument.RecordTypeId = targetManager;
    	outputDocument.SVMXC__Purpose__c = 'OUTPUT DOCUMENT';
    	outputDocument.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
    	insert outputDocument;
        
        SVMXC__Doc_Template__c objDocTemplate = new SVMXC__Doc_Template__c(SVMXC__Name__c = 'Doc Template', SVMXC__Template_Id__c = 'CUSTOMDOCTEMP001');
        list<SVMXC__Doc_Template_Details__c> lstDetails = new list<SVMXC__Doc_Template_Details__c>(); 
        SVMXC__Doc_Template_Details__c objDetail1 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Type__c = 'Header_Object',SVMXC__Doc_Template__c = objDocTemplate.id);
        lstDetails.add(objDetail1);
        SVMXC__Doc_Template_Details__c objDetail2 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c',SVMXC__Type__c = 'Detail_Object',SVMXC__Doc_Template__c = objDocTemplate.id);
        lstDetails.add(objDetail2);
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'SFM_Doc_Template.html';
        objAttachment.Body = Blob.valueOf('I am Body of attachment');
        objAttachment.ParentId = objDocTemplate.id;
        
        docTemplate.templateRecord = objDocTemplate;
        docTemplate.templateDetails = lstDetails;
        docTemplate.contentRecord = objAttachment;
        docTemplate.contentBody = 'I am Body of attachment';
        
        //Save
        Test.startTest();
        request.docTemplate = docTemplate;
        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'SAVETYPE';
        strmap.value = 'SAVE';
        request.stringMap.add(strmap);
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        docTemp.SFM_SaveDocTemplate(request);
        
        //SaveAs
        request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.docTemplate = docTemplate;
        strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'SAVETYPE';
        strmap.value = 'SAVEAS';
        request.stringMap.add(strmap);
        docTemp.SFM_SaveDocTemplate(request);
        
        //In memory clone
        request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.docTemplate = docTemplate;
        strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'SAVETYPE';
        strmap.value = 'INMEMORYCLONE';
        request.stringMap.add(strmap);
        strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'PROCESSIDFORCLONE';
        strmap.value = outputDocument.id;
        request.stringMap.add(strmap);
        docTemp.SFM_SaveDocTemplate(request);
        
        //Duplicate Check..
        SVMXC__Doc_Template__c objDocTemplate1 = new SVMXC__Doc_Template__c(SVMXC__Name__c = 'Doc Template', SVMXC__Template_Id__c = 'CUSTOMDOCTEMP001');
        insert objDocTemplate1;
        request.docTemplate = docTemplate;
        strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'SAVETYPE';
        strmap.value = 'SAVE';
        request.stringMap.add(strmap);
        docTemp.SFM_SaveDocTemplate(request);
        Test.stopTest();
        
        
    }
	static testMethod void SFM_SaveDocTemplate_for_File_UT() {
		COMM_FileHandlerUtilities.fileSettingForTestClass = true;
        SVMXC.SFM_WrapperDef.SFM_DocTemplate docTemplate = new SVMXC.SFM_WrapperDef.SFM_DocTemplate(); 
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        String targetManager;
    	List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
        	for(RecordType r : RTypeList)
        	{
        		if(r.Name == 'Target Manager')
        			targetManager = r.id;
        	}
        }
        SVMXC__ServiceMax_Processes__c outputDocument = new SVMXC__ServiceMax_Processes__c();
    	outputDocument.SVMXC__Name__c = 'CUSTOMPRO0001';
    	outputDocument.RecordTypeId = targetManager;
    	outputDocument.SVMXC__Purpose__c = 'OUTPUT DOCUMENT';
    	outputDocument.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
    	insert outputDocument;
        
        SVMXC__Doc_Template__c objDocTemplate = new SVMXC__Doc_Template__c(SVMXC__Name__c = 'Doc Template', SVMXC__Template_Id__c = 'CUSTOMDOCTEMP001');
        list<SVMXC__Doc_Template_Details__c> lstDetails = new list<SVMXC__Doc_Template_Details__c>(); 
        SVMXC__Doc_Template_Details__c objDetail1 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Type__c = 'Header_Object',SVMXC__Doc_Template__c = objDocTemplate.id);
        lstDetails.add(objDetail1);
        SVMXC__Doc_Template_Details__c objDetail2 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c',SVMXC__Type__c = 'Detail_Object',SVMXC__Doc_Template__c = objDocTemplate.id);
        lstDetails.add(objDetail2);
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'SFM_Doc_Template.html';
        objAttachment.Body = Blob.valueOf('I am Body of attachment');
        objAttachment.ParentId = objDocTemplate.id;
        ContentVersion cv = COMM_FileHandlerUtilities.createContentVersionInstance(null,'SFM_Doc_Template.html','I am Body of attachment',null);
        docTemplate.templateRecord = objDocTemplate;
        docTemplate.templateDetails = lstDetails;
        docTemplate.contentVersionRecord = cv;
        docTemplate.contentBody = 'I am Body of attachment';
        
        //Save
        Test.startTest();
        request.docTemplate = docTemplate;
        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'SAVETYPE';
        strmap.value = 'SAVE';
        request.stringMap.add(strmap);
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        docTemp.SFM_SaveDocTemplate(request);
        
        //SaveAs
        request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.docTemplate = docTemplate;
        strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'SAVETYPE';
        strmap.value = 'SAVEAS';
        request.stringMap.add(strmap);
        docTemp.SFM_SaveDocTemplate(request);
        
        //In memory clone
        request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.docTemplate = docTemplate;
        strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'SAVETYPE';
        strmap.value = 'INMEMORYCLONE';
        request.stringMap.add(strmap);
        strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'PROCESSIDFORCLONE';
        strmap.value = outputDocument.id;
        request.stringMap.add(strmap);
        docTemp.SFM_SaveDocTemplate(request);
        
        //Duplicate Check..
        SVMXC__Doc_Template__c objDocTemplate1 = new SVMXC__Doc_Template__c(SVMXC__Name__c = 'Doc Template', SVMXC__Template_Id__c = 'CUSTOMDOCTEMP001');
        insert objDocTemplate1;
        request.docTemplate = docTemplate;
        strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'SAVETYPE';
        strmap.value = 'SAVE';
        request.stringMap.add(strmap);
        docTemp.SFM_SaveDocTemplate(request);
        Test.stopTest();
        
        
    }
    static testMethod void SFM_SaveDocTemplateExceptionCoverage_UT() {
        SVMXC__Doc_Template__c objDocTemplate1 = new SVMXC__Doc_Template__c();
        objDocTemplate1.SVMXC__Name__c = 'This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character'; 
        objDocTemplate1.SVMXC__Template_Id__c = 'This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character';
        SVMXC__Doc_Template_Details__c objDetail1 = new SVMXC__Doc_Template_Details__c(SVMXC__Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Type__c = 'Header_Object');
        Attachment objAttach = new Attachment();
        SVMXC.SFM_WrapperDef.SFM_DocTemplate docTemplate = new SVMXC.SFM_WrapperDef.SFM_DocTemplate();
        docTemplate.templateRecord = objDocTemplate1;
        docTemplate.templateDetails.add(objDetail1); 
        docTemplate.contentRecord = objAttach;
        docTemplate.contentBody = 'I am Body of attachment';
        Test.startTest();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.docTemplate = docTemplate;
        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'SAVETYPE';
        strmap.value = 'SAVE';
        request.stringMap.add(strmap);
        SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
        docTemp.SFM_SaveDocTemplate(request);
        
        objDocTemplate1 = new SVMXC__Doc_Template__c();
        objDocTemplate1.SVMXC__Name__c = 'DOCTMEPLATEREC'; 
        objDocTemplate1.SVMXC__Template_Id__c = 'DOCTMEPLATEREC';
        objDetail1 = new SVMXC__Doc_Template_Details__c();
        objDetail1.SVMXC__Object_Name__c = 'This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character This text is more then 255 character';
        objDetail1.SVMXC__Type__c = 'Header_Object';
        docTemplate = new SVMXC.SFM_WrapperDef.SFM_DocTemplate();
        docTemplate.templateRecord = objDocTemplate1;
        docTemplate.templateDetails.add(objDetail1); 
        docTemplate.contentRecord = objAttach;
        docTemplate.contentBody = 'I am Body of attachment';
        request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.docTemplate = docTemplate;
        strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap(); 
        strmap.key = 'SAVETYPE';
        strmap.value = 'SAVE';
        request.stringMap.add(strmap);
        system.assert(request!=null);
        docTemp.SFM_SaveDocTemplate(request);   
        Test.stopTest();
    }
    static testMethod void SFM_GetDefaultOPDOCTemplate_UT() {
    	SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
    	SVMXC.SFM_DocTemplateUtils docTemp = new SVMXC.SFM_DocTemplateUtils();
    	docTemp.SFM_GetDefaultOPDOCTemplate(request);
    }
}