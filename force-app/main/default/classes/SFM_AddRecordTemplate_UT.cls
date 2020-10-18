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
 *///76
@isTest
private class SFM_AddRecordTemplate_UT {

    static testMethod void SFM_AddRecordTemplateTest() {
        // TO DO: implement unit test
        
        String processNodeObjects;
        String objectMapping; 
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
            for(RecordType r : RTypeList)
            {
                
                if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
                else if(r.Name == 'Object Mapping')
                    objectMapping = r.id;
            }
        }
        SVMXC__ServiceMax_Processes__c valMapHdr = new SVMXC__ServiceMax_Processes__c();
        valMapHdr.SVMXC__MapID__c = 'VMAP000001';
        valMapHdr.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
        valMapHdr.RecordTypeId = objectMapping;
        insert valMapHdr;
        System.assert(valMapHdr.id != null);
        
        SVMXC__Page_Layout__c objPageLay = new SVMXC__Page_Layout__c();
        objPageLay.SVMXC__Name__c = 'testPage';
        objPageLay.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        insert objPageLay;
        System.assert(objPageLay.id != null);
    
        SVMXC__Page_Layout_Detail__c objPageDetail =  new SVMXC__Page_Layout_Detail__c();   
        objPageDetail.SVMXC__Page_Layout__c = objPageLay.id;
        objPageDetail.SVMXC__DataType__c = 'reference';     
        objPageDetail.SVMXC__Field_API_Name__c = 'SVMXC__Company__c';
        insert objPageDetail;
        System.assert(objPageDetail.id != null);
        
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
        PNObject1.SVMXC__Page_Layout__c = objPageLay.id;
        insert PNObject1;
        System.assert(PNObject1.id != null);
        
        SVMXC__ServiceMax_Config_Data__c objConfig = new SVMXC__ServiceMax_Config_Data__c();
        objConfig.SVMXC__MapID__c = valMapHdr.id;
        objConfig.SVMXC__Display_Value__c = 'Today';
        insert objConfig;
        System.assert(objConfig.id != null);    
        
        map<String,SVMXC__ServiceMax_Processes__c> mapPagelayoutIdProcessNodeObject = new map<String,SVMXC__ServiceMax_Processes__c>();
        mapPagelayoutIdProcessNodeObject.put(objPageLay.id,PNObject1);
        map<String, Schema.SObjectType> allobjmap = new map<String, Schema.SObjectType> ();
        map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            Schema.DescribeSObjectResult result = s.getDescribe();
            if(result.getName() == 'SVMXC__Quote__c')
                allobjmap.put(result.getName(),s);
        } 
        SVMXC.SFM_AddRecordTemplate temp = new SVMXC.SFM_AddRecordTemplate();
        System.assert(temp != null);
        temp.getRecordTemplate(mapPagelayoutIdProcessNodeObject,allobjmap);
    }
}