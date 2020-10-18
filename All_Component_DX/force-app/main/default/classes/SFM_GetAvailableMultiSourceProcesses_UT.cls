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
private class SFM_GetAvailableMultiSourceProcesses_UT {

    static testMethod void getAvailableMultiSourceProcessesTest() {
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
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Contract__c';
        PNObject1.SVMXC__Process__c = SourceToTargetAll.id;
        PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Contract__c';
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject3 = new SVMXC__ServiceMax_Processes__c();
        PNObject3.RecordTypeId = processNodeObjects;
        PNObject3.SVMXC__Type__c = 'SOURCE';
        PNObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Plan__c';
        PNObject3.SVMXC__Process__c = SourceToTargetAll.id;
        listProcessNodeObjects.add(PNObject3);
        
        insert listProcessNodeObjects;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SFMProcess.SVMXC__Name__c = 'CUSTOMPRO0002';
        SFMProcess.RecordTypeId = targetManager;
        SFMProcess.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL';
        SFMProcess.SVMXC__ProcessID__c = 'CUSTOMPRO0002';
        SFMProcess.SVMXC__Page_Layout__c = PageHeader.id;
        insert SFMProcess;
        
        listProcessNodeObjects.clear();
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'TARGET';
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Contract__c';
        PNObject2.SVMXC__Process__c = SFMProcess.id;
        PNObject2.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Contract__c';
        listProcessNodeObjects.add(PNObject2);
        
        SVMXC__ServiceMax_Processes__c PNObject4 = new SVMXC__ServiceMax_Processes__c();
        PNObject4.RecordTypeId = processNodeObjects;
        PNObject4.SVMXC__Type__c = 'SOURCE';
        PNObject4.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Plan__c';
        PNObject4.SVMXC__Process__c = SFMProcess.id;
        listProcessNodeObjects.add(PNObject4);
        
        insert listProcessNodeObjects;
        
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        stringMap.key = 'OBJECTAPINAME';
        stringMap.value = 'SVMXC__Service_Contract__c';
        request.stringMap.add(stringMap);
        stringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        stringMap.key = 'SFMPROCSSID';
        stringMap.value = SFMProcess.id;
        request.stringMap.add(stringMap);
        stringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        stringMap.key = 'SFMSFID';
        stringMap.value = 'CUSTOMPRO0002';
        request.stringMap.add(stringMap);
        SFM_GetAvailableMultiSourceProcesses inst = new SFM_GetAvailableMultiSourceProcesses();
        Test.startTest();
        inst.getAvailableMultiSourceProcesses(request);
        Test.stopTest();
        
    }
}