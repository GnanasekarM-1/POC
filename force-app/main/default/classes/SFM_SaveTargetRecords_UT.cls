@isTest
private with sharing class SFM_SaveTargetRecords_UT
{
    static testMethod void testForSaveHeaderTargetRecords()
    {
        Case objCase = new Case();
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();   
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>();
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();  

        SVMXC.SFM_WrapperDef.SFM_TargetRecord targetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        List<SFM_WrapperDef.SFM_Record> lstSFMRecord = new List<SFM_WrapperDef.SFM_Record>();
        List<SFM_WrapperDef.SFM_StringMap> lstSFMStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject(); 

        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {  
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            SFMPNodeObject = getSFMPNodeObject(SFMProcess.Id, mapRTypeNameId.get('Process Node Objects'));

            insert objCase;
            System.assertEquals(true, objCase != null);

            SFM_WrapperDef.SFM_StringMap SFMStringMap1 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Is_Entitlement_Performed__c', String.valueof(true));
            lstSFMStringMap.add(SFMStringMap1); 
            
            SFM_WrapperDef.SFM_Record SFMRec1 = new SFM_WrapperDef.SFM_Record();
            SFMRec1.sourceRecordId = objCase.id;
            SFMRec1.targetRecordAsKeyValue = lstSFMStringMap;
            lstSFMRecord.add(SFMRec1);
            
            targetRecordObject.objName = 'SVMXC__Service_Order__c';
            targetRecordObject.records =  lstSFMRecord;
            targetRecord.sfmProcessId = SFMProcess.Id;
            targetRecord.headerRecord = targetRecordObject;
            SFMSaveTargetRecords.SaveTargetRecords(targetRecord);
        }
    }

    //Added for the story BAC-3839
    static testMethod void testForSaveHeaderTargetRecordsAsSobject()
    {
        Case objCase = new Case();
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();   
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>();
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();  

        SVMXC.SFM_WrapperDef.SFM_TargetRecord targetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        List<SFM_WrapperDef.SFM_Record> lstSFMRecord = new List<SFM_WrapperDef.SFM_Record>();
        List<SFM_WrapperDef.SFM_StringMap> lstSFMStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject(); 

        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {  
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            SFMPNodeObject = getSFMPNodeObject(SFMProcess.Id, mapRTypeNameId.get('Process Node Objects'));

            insert objCase;
            System.assertEquals(true, objCase != null);

            SFM_WrapperDef.SFM_StringMap SFMStringMap1 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Is_Entitlement_Performed__c', String.valueof(true));
            lstSFMStringMap.add(SFMStringMap1); 
            
            SFM_WrapperDef.SFM_Record SFMRec1 = new SFM_WrapperDef.SFM_Record();
            SFMRec1.sourceRecordId = objCase.id;
            //SFMRec1.targetRecordAsKeyValue = lstSFMStringMap;
            sObject wo = new SVMXC__Service_Order__c();
            wo.put('SVMXC__Scheduling_Retry_Count__c', 12345);
            SFMRec1.sObjectRecord = wo;
            lstSFMRecord.add(SFMRec1);
            
            targetRecordObject.objName = 'SVMXC__Service_Order__c';
            targetRecordObject.records =  lstSFMRecord;
            targetRecord.sfmProcessId = SFMProcess.Id;
            targetRecord.headerRecord = targetRecordObject;
            SFMSaveTargetRecords.SaveTargetRecords(targetRecord);
        }
    }
    
    static testMethod void testForSaveDetailTargetRecords()
    {
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();       
        SVMXC__Service_Order_Line__c objWorkOrderDetail = new SVMXC__Service_Order_Line__c();       
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>();
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();  
        
        List<String> lstDeleteRecordId = new List<String>();
        List<SFM_WrapperDef.SFM_Record> lstSFMRecord = new List<SFM_WrapperDef.SFM_Record>();
        List<SFM_WrapperDef.SFM_Record> lstSFMRecord1 = new List<SFM_WrapperDef.SFM_Record>();
        List<SFM_WrapperDef.SFM_StringMap> lstSFMStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject1 = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        SVMXC.SFM_WrapperDef.SFM_TargetRecord targetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> lstTargetRecordObject = new List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();  

        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {  
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            
            SVMXC__Page_Layout__c detailPageLayout = new SVMXC__Page_Layout__c();
            detailPageLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
            detailPageLayout.SVMXC__Type__c = 'WorkDetailLine';
            
            insert detailPageLayout; 
            System.assertEquals(true, detailPageLayout != null);
            
            SFMPNodeObject.RecordTypeId = mapRTypeNameId.get('Process Node Objects');
            SFMPNodeObject.SVMXC__Process__c = SFMProcess.id;
            SFMPNodeObject.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
            SFMPNodeObject.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
            SFMPNodeObject.SVMXC__Type__c = 'TARGETCHILD';
            SFMPNodeObject.SVMXC__Page_Layout__c = detailPageLayout.Id;

            insert SFMPNodeObject;
            System.assertEquals(true, SFMPNodeObject != null);  
            
            SVMXC__ServiceMax_Config_Data__c sourceField1 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceField1.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceField1.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            sourceField1.SVMXC__Source_Field_Name__c = 'SVMXC__Product__c';
            sourceField1.SVMXC__Target_Field_Name__c = 'SVMXC__Product__c';  
            sourceField1.SVMXC__Action__c = 'SET';
            sourceField1.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceField1);

            objWorkOrder.SVMXC__City__c = 'Bangalore';
            objWorkOrder.SVMXC__Country__c = 'India';
            objWorkOrder.SVMXC__Street__c = 'Cunninghum';
            
            insert objWorkOrder;
            System.assertEquals(true, objWorkOrder != null);
            
            objWorkOrderDetail.SVMXC__Service_Order__c = objWorkOrder.Id;
            objWorkOrderDetail.SVMXC__Select__c = true;
            
            insert objWorkOrderDetail;
            System.assertEquals(true, objWorkOrderDetail != null);

            lstDeleteRecordId.add(objWorkOrderDetail.Id);

            SFM_WrapperDef.SFM_StringMap SFMStringMap1 = new SFM_WrapperDef.SFM_StringMap('SVMXC__Is_Billable__c', String.valueof(true));
            lstSFMStringMap.add(SFMStringMap1); 
            
            SFM_WrapperDef.SFM_Record SFMRec1 = new SFM_WrapperDef.SFM_Record();
            SFMRec1.sourceRecordId = objWorkOrder.id;
            SFMRec1.targetRecordAsKeyValue = lstSFMStringMap;
            SfmRec1.targetRecordId = objWorkOrderDetail.id;
            lstSFMRecord.add(SFMRec1);
            
            SFM_WrapperDef.SFM_Record SFMRec2 = new SFM_WrapperDef.SFM_Record();
            SFMRec2.sourceRecordId = objWorkOrder.id;
            SFMRec2.targetRecordAsKeyValue = lstSFMStringMap;
            lstSFMRecord.add(SFMRec2);
            
            SFM_WrapperDef.SFM_Record SFMRec3 = new SFM_WrapperDef.SFM_Record();
            SFMRec3.sobjectinfo = objWorkOrder; 
            lstSFMRecord1.add(SFMRec3);
            
            targetRecordObject.objName = 'SVMXC__Service_Order__c';
            targetRecordObject.records =  lstSFMRecord1;

            targetRecordObject1.objName = 'SVMXC__Service_Order_Line__c';
            targetRecordObject1.aliasName = String.valueof(detailPageLayout.id);
            targetRecordObject1.deleteRecID = lstDeleteRecordId;
            targetRecordObject1.parentColumnName = 'SVMXC__Service_Order__c';
            targetRecordObject1.records =  lstSFMRecord;
            lstTargetRecordObject.add(targetRecordObject1);
            
            targetRecord.sfmProcessId = SFMProcess.Id;
            targetRecord.headerRecord = targetRecordObject;
            targetRecord.detailRecords = lstTargetRecordObject;
            SFMSaveTargetRecords.SaveTargetRecords(targetRecord);
        }
    }

    //Added for the story BAC-3839
    static testMethod void testForSaveDetailTargetRecordsAsSobjectForUpdate()
    {
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();       
        SVMXC__Service_Order_Line__c objWorkOrderDetail = new SVMXC__Service_Order_Line__c();       
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>();
        
        List<SFM_WrapperDef.SFM_Record> lstSFMRecord = new List<SFM_WrapperDef.SFM_Record>();
        List<SFM_WrapperDef.SFM_Record> lstSFMRecord1 = new List<SFM_WrapperDef.SFM_Record>();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject1 = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        SVMXC.SFM_WrapperDef.SFM_TargetRecord targetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> lstTargetRecordObject = new List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();  

        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {  
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            
            SVMXC__Page_Layout__c detailPageLayout = new SVMXC__Page_Layout__c();
            detailPageLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
            detailPageLayout.SVMXC__Type__c = 'WorkDetailLine';
            
            insert detailPageLayout; 
            System.assertEquals(true, detailPageLayout != null);
            
            SFMPNodeObject.RecordTypeId = mapRTypeNameId.get('Process Node Objects');
            SFMPNodeObject.SVMXC__Process__c = SFMProcess.id;
            SFMPNodeObject.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
            SFMPNodeObject.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
            SFMPNodeObject.SVMXC__Type__c = 'TARGETCHILD';
            SFMPNodeObject.SVMXC__Page_Layout__c = detailPageLayout.Id;

            insert SFMPNodeObject;
            System.assertEquals(true, SFMPNodeObject != null);

            objWorkOrder.SVMXC__City__c = 'Bangalore';
            objWorkOrder.SVMXC__Country__c = 'India';
            objWorkOrder.SVMXC__Street__c = 'Cunninghum';
            
            insert objWorkOrder;
            System.assertEquals(true, objWorkOrder != null);
            
            objWorkOrderDetail.SVMXC__Service_Order__c = objWorkOrder.Id;
            objWorkOrderDetail.SVMXC__Select__c = true;
            
            insert objWorkOrderDetail;
            System.assertEquals(true, objWorkOrderDetail != null);

            SFM_WrapperDef.SFM_Record SFMRec1 = new SFM_WrapperDef.SFM_Record();
            SFMRec1.sourceRecordId = objWorkOrder.id;
            sObject wd1 = new SVMXC__Service_Order_Line__c();
            wd1.put('SVMXC__Received_City__c', 'fdsflksjdfl dslkfjlkdsjf klsdjflk ajsd fkljadslkf jlkadsj flkasdj fklasdjfklajsdjlkfjklsdjfkl jkldjfk');
            SFMRec1.sObjectRecord = wd1;
            SFMRec1.rowIndex = '0';
            SfmRec1.targetRecordId = objWorkOrderDetail.id;
            lstSFMRecord.add(SFMRec1);

            SFM_WrapperDef.SFM_Record SFMRec3 = new SFM_WrapperDef.SFM_Record();
            SFMRec3.sobjectinfo = objWorkOrder; 
            lstSFMRecord1.add(SFMRec3);
            
            targetRecordObject.objName = 'SVMXC__Service_Order__c';
            targetRecordObject.records =  lstSFMRecord1;

            targetRecordObject1.objName = 'SVMXC__Service_Order_Line__c';
            targetRecordObject1.aliasName = String.valueof(detailPageLayout.id);
            targetRecordObject1.parentColumnName = 'SVMXC__Service_Order__c';
            targetRecordObject1.records =  lstSFMRecord;
            lstTargetRecordObject.add(targetRecordObject1);
            
            targetRecord.sfmProcessId = SFMProcess.Id;
            targetRecord.headerRecord = targetRecordObject;
            targetRecord.detailRecords = lstTargetRecordObject;
            SFMSaveTargetRecords.SaveTargetRecords(targetRecord);
        }
    }

    //Added for the story BAC-3839
    static testMethod void testForSaveDetailTargetRecordsAsSobjectForInsert()
    {
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();     
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>(); 
        
        List<SFM_WrapperDef.SFM_Record> lstSFMRecord = new List<SFM_WrapperDef.SFM_Record>();
        List<SFM_WrapperDef.SFM_Record> lstSFMRecord1 = new List<SFM_WrapperDef.SFM_Record>();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject1 = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        SVMXC.SFM_WrapperDef.SFM_TargetRecord targetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> lstTargetRecordObject = new List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();  

        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {  
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            
            SVMXC__Page_Layout__c detailPageLayout = new SVMXC__Page_Layout__c();
            detailPageLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
            detailPageLayout.SVMXC__Type__c = 'WorkDetailLine';
            
            insert detailPageLayout; 
            System.assertEquals(true, detailPageLayout != null);
            
            SFMPNodeObject.RecordTypeId = mapRTypeNameId.get('Process Node Objects');
            SFMPNodeObject.SVMXC__Process__c = SFMProcess.id;
            SFMPNodeObject.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
            SFMPNodeObject.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
            SFMPNodeObject.SVMXC__Type__c = 'TARGETCHILD';
            SFMPNodeObject.SVMXC__Page_Layout__c = detailPageLayout.Id;

            insert SFMPNodeObject;
            System.assertEquals(true, SFMPNodeObject != null);

            objWorkOrder.SVMXC__City__c = 'Bangalore';
            objWorkOrder.SVMXC__Country__c = 'India';
            objWorkOrder.SVMXC__Street__c = 'Cunninghum';
            
            insert objWorkOrder;
            System.assertEquals(true, objWorkOrder != null);
            
            SFM_WrapperDef.SFM_Record SFMRec2 = new SFM_WrapperDef.SFM_Record();
            SFMRec2.sourceRecordId = objWorkOrder.id;
            sObject wd2 = new SVMXC__Service_Order_Line__c();
            wd2.put('SVMXC__Received_City__c', 'fdsflksjdfl dslkfjlkdsjf klsdjflk ajsd fkljadslkf jlkadsj flkasdj fklasdjfklajsdjlkfjklsdjfkl jkldjfk');
            SFMRec2.sObjectRecord = wd2;
            SFMRec2.rowIndex = '0';
            lstSFMRecord.add(SFMRec2);
            
            SFM_WrapperDef.SFM_Record SFMRec3 = new SFM_WrapperDef.SFM_Record();
            SFMRec3.sobjectinfo = objWorkOrder; 
            lstSFMRecord1.add(SFMRec3);
            
            targetRecordObject.objName = 'SVMXC__Service_Order__c';
            targetRecordObject.records =  lstSFMRecord1;

            targetRecordObject1.objName = 'SVMXC__Service_Order_Line__c';
            targetRecordObject1.aliasName = String.valueof(detailPageLayout.id);
            targetRecordObject1.parentColumnName = 'SVMXC__Service_Order__c';
            targetRecordObject1.records =  lstSFMRecord;
            lstTargetRecordObject.add(targetRecordObject1);
            
            targetRecord.sfmProcessId = SFMProcess.Id;
            targetRecord.headerRecord = targetRecordObject;
            targetRecord.detailRecords = lstTargetRecordObject;
            SFMSaveTargetRecords.SaveTargetRecords(targetRecord);
        }
    }
    
    //Added for the story BAC-4027
    static testMethod void testReturnIdForSaveDetailTargetRecords()
    {
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();     
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>(); 
        
        List<SFM_WrapperDef.SFM_Record> lstSFMRecord = new List<SFM_WrapperDef.SFM_Record>();
        List<SFM_WrapperDef.SFM_Record> lstSFMRecord1 = new List<SFM_WrapperDef.SFM_Record>();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject1 = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        SVMXC.SFM_WrapperDef.SFM_TargetRecord targetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> lstTargetRecordObject = new List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();  

        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {  
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            
            SVMXC__Page_Layout__c detailPageLayout = new SVMXC__Page_Layout__c();
            detailPageLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
            detailPageLayout.SVMXC__Type__c = 'WorkDetailLine';
            
            insert detailPageLayout; 
            System.assertEquals(true, detailPageLayout != null);
            
            SFMPNodeObject.RecordTypeId = mapRTypeNameId.get('Process Node Objects');
            SFMPNodeObject.SVMXC__Process__c = SFMProcess.id;
            SFMPNodeObject.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
            SFMPNodeObject.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
            SFMPNodeObject.SVMXC__Type__c = 'TARGETCHILD';
            SFMPNodeObject.SVMXC__Page_Layout__c = detailPageLayout.Id;

            insert SFMPNodeObject;
            System.assertEquals(true, SFMPNodeObject != null);

            objWorkOrder.SVMXC__City__c = 'Bangalore';
            objWorkOrder.SVMXC__Country__c = 'India';
            objWorkOrder.SVMXC__Street__c = 'Cunninghum';
            
            insert objWorkOrder;
            System.assertEquals(true, objWorkOrder != null);
            
            SFM_WrapperDef.SFM_Record SFMRec2 = new SFM_WrapperDef.SFM_Record();
            SFMRec2.sourceRecordId = objWorkOrder.id;
            sObject wd2 = new SVMXC__Service_Order_Line__c();
            wd2.put('SVMXC__Received_City__c', 'Bangalore');
            SFMRec2.sObjectRecord = wd2;
            SFMRec2.rowIndex = '0';
            lstSFMRecord.add(SFMRec2);
            
            SFM_WrapperDef.SFM_Record SFMRec3 = new SFM_WrapperDef.SFM_Record();
            SFMRec3.sobjectinfo = objWorkOrder; 
            lstSFMRecord1.add(SFMRec3);
            
            targetRecordObject.objName = 'SVMXC__Service_Order__c';
            targetRecordObject.records =  lstSFMRecord1;

            targetRecordObject1.objName = 'SVMXC__Service_Order_Line__c';
            targetRecordObject1.aliasName = String.valueof(detailPageLayout.id);
            targetRecordObject1.parentColumnName = 'SVMXC__Service_Order__c';
            targetRecordObject1.records =  lstSFMRecord;
            lstTargetRecordObject.add(targetRecordObject1);
            
            targetRecord.sfmProcessId = SFMProcess.Id;
            targetRecord.headerRecord = targetRecordObject;
            targetRecord.detailRecords = lstTargetRecordObject;
            targetRecord.callType = 'save for linked sfm';
            SFMSaveTargetRecords.SaveTargetRecords(targetRecord);
        }
    }

    static testMethod void testForHeaderTargetObjectUpdate()
    {
        SVMXC__Service_Order__c  objWorkOrder = new SVMXC__Service_Order__c();
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>();
        list<SVMXC__ServiceMax_Config_Data__c> lstTargetUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();   
        
        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {  
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            SFMPNodeObject = getSFMPNodeObject(SFMProcess.Id, mapRTypeNameId.get('Process Node Objects'));

            SVMXC__ServiceMax_Config_Data__c targetUpdateField1 = new SVMXC__ServiceMax_Config_Data__c(); 
            targetUpdateField1.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            targetUpdateField1.SVMXC__Dispatch_Process__c = SFMProcess.Id;
            targetUpdateField1.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            targetUpdateField1.SVMXC__Source_Field_Name__c = 'SVMXC__Latitude__c';
            targetUpdateField1.SVMXC__Configuration_Type__c = 'Source Update';
            lstTargetUpdateField.add(targetUpdateField1);
            
            SVMXC__ServiceMax_Config_Data__c targetUpdateField2 = new SVMXC__ServiceMax_Config_Data__c(); 
            targetUpdateField2.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            targetUpdateField2.SVMXC__Dispatch_Process__c = SFMProcess.Id;
            targetUpdateField2.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            targetUpdateField2.SVMXC__Source_Field_Name__c = 'SVMXC__Longitude__c';
            targetUpdateField2.SVMXC__Configuration_Type__c = 'Source Update';
            lstTargetUpdateField.add(targetUpdateField2);
            
            insert lstTargetUpdateField;
            System.assertEquals(true, ((lstTargetUpdateField[0] != null) && (lstTargetUpdateField[0].Id != null)));  

            insert objWorkOrder;
            System.assertEquals(true, objWorkOrder != null);
            
            SFMSaveTargetRecords.DoHeaderTargetObjectUpdate('SFMProcess1', String.valueOf(objWorkOrder.Id));
        }
    }
    
    static testMethod void testForHeaderSourceObjectUpdate1()
    {
        Case objCase = new Case();
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>();
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();   
        
        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            SFMPNodeObject = getSFMPNodeObject(SFMProcess.Id, mapRTypeNameId.get('Process Node Objects'));
            
            SVMXC__ServiceMax_Config_Data__c sourceUpdateField1 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceUpdateField1.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceUpdateField1.SVMXC__Setting_ID__c = SFMPNodeObject.Id;
            sourceUpdateField1.SVMXC__Source_Field_Name__c = 'Origin';
            sourceUpdateField1.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceUpdateField1);
            
            SVMXC__ServiceMax_Config_Data__c sourceUpdateField2 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceUpdateField2.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceUpdateField2.SVMXC__Setting_ID__c = SFMPNodeObject.Id;
            sourceUpdateField2.SVMXC__Source_Field_Name__c = 'Priority';
            sourceUpdateField2.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceUpdateField2);
            
            insert lstSourceUpdateField;
            System.assertEquals(true, ((lstSourceUpdateField[0] != null) && (lstSourceUpdateField[0].Id != null)));  

            insert objCase;
            System.assertEquals(true, objCase != null);
            
            SFMSaveTargetRecords.DoHeaderSourceObjectUpdate(SFMProcess.Id, null, objCase.Id, 'SVMXC__Service_Order__c', null, new map<String,map<String,Schema.SObjectField>>());
        }
    }
    
    static testMethod void testForHeaderSourceObjectUpdate2()
    {
        Case objCase = new Case();
        
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        SFM_SaveTargetRecords.CreateSourceUpdateRequest objSourceUpdateRequest;
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();   
        Map<String,Schema.SObjectField> mapSourceField = Schema.SObjectType.Case.fields.getMap();

        SVMXC__ServiceMax_Config_Data__c currencySourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        currencySourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Proforma_Invoice_Amount__c';
        currencySourceField.SVMXC__Display_Value__c = '10';  
        currencySourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(currencySourceField);
    
        SVMXC__ServiceMax_Config_Data__c booleanSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        booleanSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Is_Entitlement_Performed__c';
        booleanSourceField.SVMXC__Display_Value__c = String.valueOf('True');  
        booleanSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(booleanSourceField);
        
        SVMXC__ServiceMax_Config_Data__c dateTimeSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        dateTimeSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Preferred_Start_Time__c';
        dateTimeSourceField.SVMXC__Display_Value__c = String.valueOf(datetime.now());  
        dateTimeSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(dateTimeSourceField);
        
        SVMXC__ServiceMax_Config_Data__c dateTimeTodaySourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        dateTimeTodaySourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Preferred_Start_Time__c';
        dateTimeTodaySourceField.SVMXC__Display_Value__c = 'TODAY';  
        dateTimeTodaySourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(dateTimeTodaySourceField);
        
        SVMXC__ServiceMax_Config_Data__c dateTimeTommSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        dateTimeTommSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Preferred_Start_Time__c';
        dateTimeTommSourceField.SVMXC__Display_Value__c = 'TOMORROW';  
        dateTimeTommSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(dateTimeTommSourceField);
        
        SVMXC__ServiceMax_Config_Data__c dateTimeYestSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        dateTimeYestSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Preferred_Start_Time__c';
        dateTimeYestSourceField.SVMXC__Display_Value__c = 'YESTERDAY';  
        dateTimeYestSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(dateTimeYestSourceField);
        
        SVMXC__ServiceMax_Config_Data__c dateTimeNowSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        dateTimeNowSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Preferred_Start_Time__c';
        dateTimeNowSourceField.SVMXC__Display_Value__c = 'NOW';  
        dateTimeNowSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(dateTimeNowSourceField);
        
        SVMXC__ServiceMax_Config_Data__c dateSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        dateSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        dateSourceField.SVMXC__Display_Value__c = String.valueOf(date.today());  
        dateSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(dateSourceField);
        
        SVMXC__ServiceMax_Config_Data__c dateTodaySourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        dateTodaySourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        dateTodaySourceField.SVMXC__Display_Value__c = 'TODAY';  
        dateTodaySourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(dateTodaySourceField);
        
        SVMXC__ServiceMax_Config_Data__c dateTommSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        dateTommSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        dateTommSourceField.SVMXC__Display_Value__c = 'TOMORROW';  
        dateTommSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(dateTommSourceField);
        
        SVMXC__ServiceMax_Config_Data__c dateYestSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        dateYestSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        dateYestSourceField.SVMXC__Display_Value__c = 'YESTERDAY';  
        dateYestSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(dateYestSourceField);
        
        SVMXC__ServiceMax_Config_Data__c TextSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        TextSourceField.SVMXC__Source_Field_Name__c = 'Subject';
        TextSourceField.SVMXC__Display_Value__c = 'Test Subject';  
        TextSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(TextSourceField);
        
        insert objCase;
        System.assertEquals(true, objCase != null);
        
        objSourceUpdateRequest = new SFM_SaveTargetRecords.CreateSourceUpdateRequest(new SVMXC__Service_Order__c(), objCase, lstSourceUpdateField, mapSourceField);
        SFMSaveTargetRecords.DoHeaderSourceObjectUpdate(objSourceUpdateRequest);
    }
    
    static testMethod void testForHeaderSourceObjectUpdate3()
    {
        Case objCase = new Case();  
        
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        SFM_SaveTargetRecords.CreateSourceUpdateRequest objSourceUpdateRequest;
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();   
        Map<String,Schema.SObjectField> mapSourceField = Schema.SObjectType.Case.fields.getMap();

        SVMXC__ServiceMax_Config_Data__c currencySourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        currencySourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Proforma_Invoice_Amount__c';
        currencySourceField.SVMXC__Target_Field_Name__c = 'SVMXC__Proforma_Invoice_Amount__c';  
        currencySourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(currencySourceField);
        
        SVMXC__ServiceMax_Config_Data__c booleanSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        booleanSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Is_Entitlement_Performed__c';
        booleanSourceField.SVMXC__Target_Field_Name__c = 'SVMXC__Is_Entitlement_Performed__c';  
        booleanSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(booleanSourceField);
        
        SVMXC__ServiceMax_Config_Data__c dateTimeSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        dateTimeSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Preferred_Start_Time__c';
        dateTimeSourceField.SVMXC__Target_Field_Name__c = 'SVMXC__Preferred_Start_Time__c';  
        dateTimeSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(dateTimeSourceField);
        
        SVMXC__ServiceMax_Config_Data__c dateSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        dateSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        dateSourceField.SVMXC__Target_Field_Name__c = 'SVMXC__Scheduled_Date__c';  
        dateSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(dateSourceField);
        
        SVMXC__ServiceMax_Config_Data__c TextSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
        TextSourceField.SVMXC__Source_Field_Name__c = 'Subject';
        TextSourceField.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';  
        TextSourceField.SVMXC__Action__c = 'SET';
        lstSourceUpdateField.add(TextSourceField);
        
        insert objCase;
        System.assertEquals(true, objCase != null);
        
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();
        objWorkOrder.SVMXC__Proforma_Invoice_Amount__c = 10;
        objWorkOrder.SVMXC__Is_Entitlement_Performed__c = true;
        objWorkOrder.SVMXC__Preferred_Start_Time__c = datetime.now();
        objWorkOrder.SVMXC__Scheduled_Date__c = date.today();
        objWorkOrder.SVMXC__City__c = 'Bangalore';

        objSourceUpdateRequest = new SFM_SaveTargetRecords.CreateSourceUpdateRequest(objWorkOrder, objCase, lstSourceUpdateField, mapSourceField);
        SFMSaveTargetRecords.DoHeaderSourceObjectUpdate(objSourceUpdateRequest);
    }
    
    static testMethod void testForHeaderSourceObjectUpdate4()
    {
        Case objCase = new Case();  
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();       
        
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        SFM_SaveTargetRecords.CreateSourceUpdateRequest objSourceUpdateRequest;
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();   
        Map<String,Schema.SObjectField> mapSourceField = Schema.SObjectType.Case.fields.getMap();

        SVMXC__ServiceMax_Config_Data__c sourceField1 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField1.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        sourceField1.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';  
        sourceField1.SVMXC__Action__c = 'INCREASE';
        lstSourceUpdateField.add(sourceField1);
        
        SVMXC__ServiceMax_Config_Data__c sourceField2 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField2.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Hours__c';
        sourceField2.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Hours__c';  
        sourceField2.SVMXC__Action__c = 'INCREASE';
        lstSourceUpdateField.add(sourceField2);
        
        SVMXC__ServiceMax_Config_Data__c sourceField3 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField3.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Minutes__c';
        sourceField3.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Minutes__c';  
        sourceField3.SVMXC__Action__c = 'INCREASE';
        lstSourceUpdateField.add(sourceField3);
        
        SVMXC__ServiceMax_Config_Data__c sourceField4 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField4.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        sourceField4.SVMXC__Display_Value__c = String.valueOf(10);  
        sourceField4.SVMXC__Action__c = 'INCREASE';
        lstSourceUpdateField.add(sourceField4);
        
        SVMXC__ServiceMax_Config_Data__c sourceField5 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField5.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Extension_Minutes__c';
        sourceField5.SVMXC__Display_Value__c = String.valueOf(10);  
        sourceField5.SVMXC__Action__c = 'INCREASE';
        lstSourceUpdateField.add(sourceField5);
        
        objCase.SVMXC__SLA_Clock_Pause_Days__c = 10;
        objCase.SVMXC__SLA_Clock_Pause_Hours__c = 10;
        
        insert objCase;
        System.assertEquals(true, objCase != null);
        
        objWorkOrder.SVMXC__SLA_Clock_Pause_Days__c = 10;
        objWorkOrder.SVMXC__SLA_Clock_Pause_Minutes__c = 10;
        
        objSourceUpdateRequest = new SFM_SaveTargetRecords.CreateSourceUpdateRequest(objWorkOrder, objCase, lstSourceUpdateField, mapSourceField);
        SFMSaveTargetRecords.DoHeaderSourceObjectUpdate(objSourceUpdateRequest);
    }
    
    static testMethod void testForHeaderSourceObjectUpdate5()
    {
        Case objCase = new Case();  
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();   
        
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        SFM_SaveTargetRecords.CreateSourceUpdateRequest objSourceUpdateRequest;
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();   
        Map<String,Schema.SObjectField> mapSourceField = Schema.SObjectType.Case.fields.getMap();

        SVMXC__ServiceMax_Config_Data__c sourceField1 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField1.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        sourceField1.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';  
        sourceField1.SVMXC__Action__c = 'DECREASE';
        lstSourceUpdateField.add(sourceField1);
        
        SVMXC__ServiceMax_Config_Data__c sourceField3 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField3.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Minutes__c';
        sourceField3.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Minutes__c';  
        sourceField3.SVMXC__Action__c = 'DECREASE';
        lstSourceUpdateField.add(sourceField3);
        
        SVMXC__ServiceMax_Config_Data__c sourceField4 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField4.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        sourceField4.SVMXC__Display_Value__c = String.valueOf(10);  
        sourceField4.SVMXC__Action__c = 'DECREASE';
        lstSourceUpdateField.add(sourceField4);
        
        SVMXC__ServiceMax_Config_Data__c sourceField5 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField5.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Extension_Minutes__c';
        sourceField5.SVMXC__Display_Value__c = String.valueOf(10);  
        sourceField5.SVMXC__Action__c = 'DECREASE';
        lstSourceUpdateField.add(sourceField5);
        
        objCase.SVMXC__SLA_Clock_Pause_Days__c = 10;
        objCase.SVMXC__SLA_Clock_Pause_Hours__c = 10;
        
        insert objCase;
        System.assertEquals(true, objCase != null);
        
        objWorkOrder.SVMXC__SLA_Clock_Pause_Days__c = 10;
        objWorkOrder.SVMXC__SLA_Clock_Pause_Minutes__c = 10;
        
        objSourceUpdateRequest = new SFM_SaveTargetRecords.CreateSourceUpdateRequest(objWorkOrder, objCase, lstSourceUpdateField, mapSourceField);
        SFMSaveTargetRecords.DoHeaderSourceObjectUpdate(objSourceUpdateRequest);
    }
    
    static testMethod void testForDetailSourceObjectUpdate1()
    {
        Case objCase = new Case();
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();   
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>();
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();   
        
        map<String,map<String,Schema.SObjectField>> allFieldDescribe = new map<String,map<String,Schema.SObjectField>>();
        allFieldDescribe.put('SVMXC__Service_Order__c', Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap());
        
        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {  
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            SFMPNodeObject = getSFMPNodeObject(SFMProcess.Id, mapRTypeNameId.get('Process Node Objects'));
        
            SVMXC__ServiceMax_Config_Data__c currencySourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            currencySourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            currencySourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            currencySourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Proforma_Invoice_Amount__c';
            currencySourceField.SVMXC__Display_Value__c = '10';  
            currencySourceField.SVMXC__Action__c = 'SET';
            currencySourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(currencySourceField);
        
            SVMXC__ServiceMax_Config_Data__c booleanSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            booleanSourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            booleanSourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            booleanSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Is_Entitlement_Performed__c';
            booleanSourceField.SVMXC__Display_Value__c = String.valueOf('True');  
            booleanSourceField.SVMXC__Action__c = 'SET';
            booleanSourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(booleanSourceField);
            
            SVMXC__ServiceMax_Config_Data__c dateTimeSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            dateTimeSourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            dateTimeSourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            dateTimeSourceField.SVMXC__Source_Field_Name__c = 'Preferred_Start_Time__c';
            dateTimeSourceField.SVMXC__Display_Value__c = String.valueOf(datetime.now());  
            dateTimeSourceField.SVMXC__Action__c = 'SET';
            dateTimeSourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(dateTimeSourceField);
            
            SVMXC__ServiceMax_Config_Data__c dateTimeTodaySourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            dateTimeTodaySourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            dateTimeTodaySourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            dateTimeTodaySourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Resolution_Customer_By__c';
            dateTimeTodaySourceField.SVMXC__Display_Value__c = 'TODAY';  
            dateTimeTodaySourceField.SVMXC__Action__c = 'SET';
            dateTimeTodaySourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(dateTimeTodaySourceField);
            
            SVMXC__ServiceMax_Config_Data__c dateTimeTommSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            dateTimeTommSourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            dateTimeTommSourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            dateTimeTommSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Resolution_Internal_By__c';
            dateTimeTommSourceField.SVMXC__Display_Value__c = 'TOMORROW';  
            dateTimeTommSourceField.SVMXC__Action__c = 'SET';
            dateTimeTommSourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(dateTimeTommSourceField);
            
            SVMXC__ServiceMax_Config_Data__c dateTimeYestSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            dateTimeYestSourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            dateTimeYestSourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            dateTimeYestSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Restoration_Customer_By__c';
            dateTimeYestSourceField.SVMXC__Display_Value__c = 'YESTERDAY';  
            dateTimeYestSourceField.SVMXC__Action__c = 'SET';
            dateTimeYestSourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(dateTimeYestSourceField);
            
            SVMXC__ServiceMax_Config_Data__c dateTimeNowSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            dateTimeNowSourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            dateTimeNowSourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            dateTimeNowSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Restoration_Internal_By__c';
            dateTimeNowSourceField.SVMXC__Display_Value__c = 'NOW';  
            dateTimeNowSourceField.SVMXC__Action__c = 'SET';
            dateTimeNowSourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(dateTimeNowSourceField);
            
            SVMXC__ServiceMax_Config_Data__c dateSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            dateSourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            dateSourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            dateSourceField.SVMXC__Source_Field_Name__c = 'Scheduled_Date__c';
            dateSourceField.SVMXC__Display_Value__c = String.valueOf(date.today());  
            dateSourceField.SVMXC__Configuration_Type__c = 'Source Update';
            dateSourceField.SVMXC__Action__c = 'SET';
            lstSourceUpdateField.add(dateSourceField);
            
            SVMXC__ServiceMax_Config_Data__c dateTodaySourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            dateTodaySourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            dateTodaySourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            dateTodaySourceField.SVMXC__Source_Field_Name__c = 'SVMXC__BW_Date__c';
            dateTodaySourceField.SVMXC__Display_Value__c = 'TODAY';  
            dateTodaySourceField.SVMXC__Action__c = 'SET';
            dateTodaySourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(dateTodaySourceField);
            
            SVMXC__ServiceMax_Config_Data__c TextSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            TextSourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            TextSourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            TextSourceField.SVMXC__Source_Field_Name__c = 'Subject';
            TextSourceField.SVMXC__Display_Value__c = 'Test Subject';  
            TextSourceField.SVMXC__Action__c = 'SET';
            TextSourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(TextSourceField);
            
            insert lstSourceUpdateField;
            System.assertEquals(true, ((lstSourceUpdateField[0] != null) && (lstSourceUpdateField[0].Id != null)));  
            
            insert objCase;
            System.assertEquals(true, objCase != null);
            
            map<String,Sobject> mapSourceRecIdTarget = new map<String,Sobject>();
            mapSourceRecIdTarget.put(objCase.Id, objWorkOrder);
            SFMSaveTargetRecords.DoDetailsSourceObjectUpdate(SFMProcess.Id, mapSourceRecIdTarget, 'SVMXC__Service_Order__c', null, allFieldDescribe);
        }
    }
    
    static testMethod void testForDetailSourceObjectUpdate2()
    {
        Case objCase = new Case();
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();   
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>();
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();   
        
        map<String,map<String,Schema.SObjectField>> allFieldDescribe = new map<String,map<String,Schema.SObjectField>>();
        allFieldDescribe.put('SVMXC__Service_Order__c', Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap());
        
        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {  
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            SFMPNodeObject = getSFMPNodeObject(SFMProcess.Id, mapRTypeNameId.get('Process Node Objects'));
        
            SVMXC__ServiceMax_Config_Data__c currencySourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            currencySourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            currencySourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            currencySourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Proforma_Invoice_Amount__c';
            currencySourceField.SVMXC__Target_Field_Name__c = 'SVMXC__Proforma_Invoice_Amount__c';  
            currencySourceField.SVMXC__Action__c = 'SET';
            currencySourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(currencySourceField);
        
            SVMXC__ServiceMax_Config_Data__c booleanSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            booleanSourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            booleanSourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            booleanSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Is_Entitlement_Performed__c';
            booleanSourceField.SVMXC__Target_Field_Name__c = 'SVMXC__Is_Entitlement_Performed__c';  
            booleanSourceField.SVMXC__Action__c = 'SET';
            booleanSourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(booleanSourceField);
            
            SVMXC__ServiceMax_Config_Data__c dateTimeSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            dateTimeSourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            dateTimeSourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            dateTimeSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Preferred_Start_Time__c';
            dateTimeSourceField.SVMXC__Target_Field_Name__c = 'SVMXC__Preferred_Start_Time__c';  
            dateTimeSourceField.SVMXC__Action__c = 'SET';
            dateTimeSourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(dateTimeSourceField);
            
            SVMXC__ServiceMax_Config_Data__c dateSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            dateSourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            dateSourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            dateSourceField.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
            dateSourceField.SVMXC__Target_Field_Name__c = 'SVMXC__Scheduled_Date__c';  
            dateSourceField.SVMXC__Configuration_Type__c = 'Source Update';
            dateSourceField.SVMXC__Action__c = 'SET';
            lstSourceUpdateField.add(dateSourceField);
            
            SVMXC__ServiceMax_Config_Data__c TextSourceField = new SVMXC__ServiceMax_Config_Data__c(); 
            TextSourceField.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            TextSourceField.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            TextSourceField.SVMXC__Source_Field_Name__c = 'Subject';
            TextSourceField.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';  
            TextSourceField.SVMXC__Action__c = 'SET';
            TextSourceField.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(TextSourceField);
            
            insert lstSourceUpdateField;
            System.assertEquals(true, ((lstSourceUpdateField[0] != null) && (lstSourceUpdateField[0].Id != null)));  

            insert objCase;
            System.assertEquals(true, objCase != null);
            
            objWorkOrder.SVMXC__Proforma_Invoice_Amount__c = 10;
            objWorkOrder.SVMXC__Is_Entitlement_Performed__c = true;
            objWorkOrder.SVMXC__Preferred_Start_Time__c = datetime.now();
            objWorkOrder.SVMXC__Scheduled_Date__c = date.today();
            objWorkOrder.SVMXC__City__c = 'Bangalore';
            
            map<String,Sobject> mapSourceRecIdTarget = new map<String,Sobject>();
            mapSourceRecIdTarget.put(objCase.Id, objWorkOrder);
            SFMSaveTargetRecords.DoDetailsSourceObjectUpdate(SFMProcess.Id, mapSourceRecIdTarget, 'SVMXC__Service_Order__c', null, allFieldDescribe);
        }
    }
    
    static testMethod void testForDetailSourceObjectUpdate3()
    {
        Case objCase = new Case();
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();   
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>();
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();   
        
        map<String,map<String,Schema.SObjectField>> allFieldDescribe = new map<String,map<String,Schema.SObjectField>>();
        allFieldDescribe.put('SVMXC__Service_Order__c', Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap());
        
        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {  
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            SFMPNodeObject = getSFMPNodeObject(SFMProcess.Id, mapRTypeNameId.get('Process Node Objects'));
        
            SVMXC__ServiceMax_Config_Data__c sourceField1 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceField1.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceField1.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            sourceField1.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
            sourceField1.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';  
            sourceField1.SVMXC__Action__c = 'INCREASE';
            sourceField1.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceField1);
            
            SVMXC__ServiceMax_Config_Data__c sourceField2 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceField2.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceField2.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            sourceField2.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Hours__c';
            sourceField2.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Hours__c';  
            sourceField2.SVMXC__Action__c = 'INCREASE';
            sourceField2.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceField2);
            
            SVMXC__ServiceMax_Config_Data__c sourceField3 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceField3.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceField3.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            sourceField3.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Minutes__c';
            sourceField3.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Minutes__c';  
            sourceField3.SVMXC__Action__c = 'INCREASE';
            sourceField3.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceField3);
            
            SVMXC__ServiceMax_Config_Data__c sourceField4 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceField4.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceField4.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            sourceField4.SVMXC__Source_Field_Name__c = 'SVMXC__BW_Slots_Before__c';
            sourceField4.SVMXC__Display_Value__c = String.valueOf(10);  
            sourceField4.SVMXC__Action__c = 'INCREASE';
            sourceField4.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceField4);
            
            SVMXC__ServiceMax_Config_Data__c sourceField5 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceField5.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceField5.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            sourceField5.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Extension_Minutes__c';
            sourceField5.SVMXC__Display_Value__c = String.valueOf(10);  
            sourceField5.SVMXC__Action__c = 'INCREASE';
            sourceField5.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceField5);
            
            insert lstSourceUpdateField;
            System.assertEquals(true, ((lstSourceUpdateField[0] != null) && (lstSourceUpdateField[0].Id != null)));  
            
            objCase.SVMXC__BW_Slots_Before__c = 10;
            objCase.SVMXC__SLA_Clock_Pause_Days__c = 10;
            objCase.SVMXC__SLA_Clock_Pause_Hours__c = 10;
            
            insert objCase;
            System.assertEquals(true, objCase != null);
            
            objWorkOrder.SVMXC__SLA_Clock_Pause_Days__c = 10;
            objWorkOrder.SVMXC__SLA_Clock_Pause_Minutes__c = 10;
            
            map<String,Sobject> mapSourceRecIdTarget = new map<String,Sobject>();
            mapSourceRecIdTarget.put(objCase.Id, objWorkOrder); 
            SFMSaveTargetRecords.DoDetailsSourceObjectUpdate(SFMProcess.Id, mapSourceRecIdTarget, 'SVMXC__Service_Order__c', null, allFieldDescribe);
        }
    }
    
    static testMethod void testForDetailSourceObjectUpdate4()
    {
        Case objCase = new Case();
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();   
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
        
        map<String, Id> mapRTypeNameId = new map<String, Id>();
        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();  

        map<String,map<String,Schema.SObjectField>> allFieldDescribe = new map<String,map<String,Schema.SObjectField>>();
        allFieldDescribe.put('SVMXC__Service_Order__c', Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap());        
        
        mapRTypeNameId = getRecordTypes();
        if(mapRTypeNameId != null)
        {  
            SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
            SFMPNodeObject = getSFMPNodeObject(SFMProcess.Id, mapRTypeNameId.get('Process Node Objects'));
        
            SVMXC__ServiceMax_Config_Data__c sourceField1 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceField1.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceField1.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            sourceField1.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
            sourceField1.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';  
            sourceField1.SVMXC__Action__c = 'DECREASE';
            sourceField1.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceField1);
            
            SVMXC__ServiceMax_Config_Data__c sourceField2 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceField2.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceField2.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            sourceField2.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Minutes__c';
            sourceField2.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Minutes__c';  
            sourceField2.SVMXC__Action__c = 'DECREASE';
            sourceField2.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceField2);
            
            SVMXC__ServiceMax_Config_Data__c sourceField3 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceField3.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceField3.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            sourceField3.SVMXC__Source_Field_Name__c = 'SVMXC__BW_Slots_Before__c';
            sourceField3.SVMXC__Display_Value__c = String.valueOf(10);  
            sourceField3.SVMXC__Action__c = 'DECREASE';
            sourceField3.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceField3);
            
            SVMXC__ServiceMax_Config_Data__c sourceField4 = new SVMXC__ServiceMax_Config_Data__c(); 
            sourceField4.RecordTypeId = mapRTypeNameId.get('Field Mapping');
            sourceField4.SVMXC__Setting_ID__c = SFMPNodeObject.id;
            sourceField4.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Extension_Minutes__c';
            sourceField4.SVMXC__Display_Value__c = String.valueOf(10);  
            sourceField4.SVMXC__Action__c = 'DECREASE';
            sourceField4.SVMXC__Configuration_Type__c = 'Source Update';
            lstSourceUpdateField.add(sourceField4);

            insert lstSourceUpdateField;
            System.assertEquals(true, ((lstSourceUpdateField[0] != null) && (lstSourceUpdateField[0].Id != null)));  
            
            objCase.SVMXC__BW_Slots_Before__c = 10;
            objCase.SVMXC__SLA_Clock_Pause_Days__c = 10;
            objCase.SVMXC__SLA_Clock_Pause_Hours__c = 10;
            
            insert objCase;
            System.assertEquals(true, objCase != null);
            
            objWorkOrder.SVMXC__SLA_Clock_Pause_Days__c = 10;
            objWorkOrder.SVMXC__SLA_Clock_Pause_Minutes__c = 10;
            
            map<String,Sobject> mapSourceRecIdTarget = new map<String,Sobject>();
            mapSourceRecIdTarget.put(objCase.Id, objWorkOrder);
            SFMSaveTargetRecords.DoDetailsSourceObjectUpdate(SFMProcess.Id, mapSourceRecIdTarget, 'SVMXC__Service_Order__c', null, allFieldDescribe);
        }
    }
    
    static map<String, Id> getRecordTypes()
    {
        list<RecordType> lstRecordType = [Select Id, Name From RecordType where Name = 'Target Manager' OR Name = 'Process Node Objects' OR Name = 'Field Mapping'];
        if(lstRecordType != null && lstRecordType.size() > 0)
        {
            map<String, Id> mapRTypeNameId = new map<String, Id>();
            for(RecordType objRecordType : lstRecordType)
                mapRTypeNameId.put(objRecordType.Name, objRecordType.Id);
            return mapRTypeNameId;
        }
        return null;
    }
    
    static SVMXC__ServiceMax_Processes__c getSFMProcess(Id RTypeId)
    {
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SFMProcess.RecordTypeId = RTypeId;
        SFMProcess.SVMXC__ProcessID__c = 'SFMProcess1';
        SFMProcess.SVMXC__IsStandard__c = true;
        
        insert SFMProcess;
        System.assertEquals(true, SFMProcess != null);
        return SFMProcess;
    }
    
    static SVMXC__ServiceMax_Processes__c getSFMPNodeObject(Id SFMProcessId, Id RTypeId)
    {   
        SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
        SFMPNodeObject.RecordTypeId = RTypeId;
        SFMPNodeObject.SVMXC__Process__c = SFMProcessId;
        SFMPNodeObject.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        SFMPNodeObject.SVMXC__Node_Source_Object_API__c = 'Case';
        SFMPNodeObject.SVMXC__Type__c = 'TARGET';

        insert SFMPNodeObject;
        System.assertEquals(true, SFMPNodeObject != null);  
        return SFMPNodeObject;
    }

    static testMethod void testHeaderSourceObjectUpdateForChecklist()
    {
        List<SVMXC__QB_Response_Set__c> lstResponseSet = new List<SVMXC__QB_Response_Set__c>();
        SVMXC__QB_Response_Set__c responseSet1 = new SVMXC__QB_Response_Set__c();
        responseSet1.Name = 'Response Set 1';
        responseSet1.SVMXC__Response_Set_Values__c = 'Success;Not sure;';
        lstResponseSet.add(responseSet1);

        SVMXC__QB_Response_Set__c responseSet2 = new SVMXC__QB_Response_Set__c();
        responseSet2.Name = 'Response Set 2';
        responseSet2.SVMXC__Response_Set_Values__c = 'Contract;Courtesy;Empowerment;Loan;Paid;Warranty;';
        lstResponseSet.add(responseSet2);

        insert lstResponseSet;

        List<SVMXC__Question_Bank__c> lstQuestions =  new List<SVMXC__Question_Bank__c>();
        
        SVMXC__Question_Bank__c que1 = new SVMXC__Question_Bank__c();
        que1.SVMXC__Response_Type__c = 'Text';
        que1.SVMXC__Question__c = 'SOU Text question';
        que1.SVMXC__QuestionID__c = 'QB000011';
        lstQuestions.add(que1);

        SVMXC__Question_Bank__c que2 = new SVMXC__Question_Bank__c();
        que2.SVMXC__Response_Type__c = 'Number';
        que2.SVMXC__Question__c = 'SOU Number question with decimal';
        que2.SVMXC__QuestionID__c = 'QB000012';
        lstQuestions.add(que2);

        SVMXC__Question_Bank__c que3 = new SVMXC__Question_Bank__c();
        que3.SVMXC__Response_Type__c = 'Number';
        que3.SVMXC__Question__c = 'SOU Number without decimal';
        que3.SVMXC__QuestionID__c = 'QB000013';
        lstQuestions.add(que3);

        SVMXC__Question_Bank__c que4 = new SVMXC__Question_Bank__c();
        que4.SVMXC__Response_Type__c = 'Date';
        que4.SVMXC__Question__c = 'SOU Date question';
        que4.SVMXC__QuestionID__c = 'QB000014';
        lstQuestions.add(que4);

        SVMXC__Question_Bank__c que5 = new SVMXC__Question_Bank__c();
        que5.SVMXC__Response_Type__c = 'DateTime';
        que5.SVMXC__Question__c = 'SOU DateTime question';
        que5.SVMXC__QuestionID__c = 'QB000015';
        lstQuestions.add(que5);

        SVMXC__Question_Bank__c que6 = new SVMXC__Question_Bank__c();
        que6.SVMXC__Response_Type__c = 'Picklist';
        que6.SVMXC__Question__c = 'SOU picklist question';
        que6.SVMXC__QuestionID__c = 'QB000016';
        que6.SVMXC__Response_Set__c = lstResponseSet[0].id;
        lstQuestions.add(que6);

        SVMXC__Question_Bank__c que7 = new SVMXC__Question_Bank__c();
        que7.SVMXC__Response_Type__c = 'Radio Button';
        que7.SVMXC__Question__c = 'SOU radio button question';
        que7.SVMXC__QuestionID__c = 'QB000017';
        que6.SVMXC__Response_Set__c = lstResponseSet[1].id;
        lstQuestions.add(que7);

        SVMXC__Question_Bank__c que8 = new SVMXC__Question_Bank__c();
        que8.SVMXC__Response_Type__c = 'Text';
        que8.SVMXC__Question__c = 'Enter email';
        que8.SVMXC__QuestionID__c = 'QB000018';
        lstQuestions.add(que8);

        SVMXC__Question_Bank__c que9 = new SVMXC__Question_Bank__c();
        que9.SVMXC__Response_Type__c = 'Text';
        que9.SVMXC__Question__c = 'Enter url';
        que9.SVMXC__QuestionID__c = 'QB000019';
        lstQuestions.add(que9);

        insert lstQuestions;

        /*
        pageLayout =  new SVMXC__Page_Layout__c ();
        pageLayout.SVMXC__Name__c = 'SOU checklist testing CHK';
        pageLayout.SVMXC__Page_Layout_ID__c = 'SOU_checklist_testing_CHK';
        pageLayout.SVMXC__Object_Name__c = 'SVMXC__Checklist__c';
        pageLayout.SVMXC__Type__c = 'Header';
        insert pageLayout;

        //insert section details
        SVMXC__Page_Layout_Detail__c pLDSection = new SVMXC__Page_Layout_Detail__c();
        pLDSection.SVMXC__Detail_Type__c = 'Section';
        pLDSection.SVMXC__Page_Layout__c = pageLayout.id;
        pLDSection.SVMXC__Sequence__c = 1;
        pLDSection.SVMXC__Title__c = 'Checklist Section Title';
        insert pLDSection;

        //insert page layout details of question
        List<SVMXC__Page_Layout_Detail__c> lstPLDetail = new List<SVMXC__Page_Layout_Detail__c>();
        for(Integer i=0; i<9; i++){
            SVMXC__Page_Layout_Detail__c pLDQuestion = new SVMXC__Page_Layout_Detail__c();
            pLDQuestion.SVMXC__Sequence__c = i+1;
            pLDQuestion.SVMXC__Question__c = lstQuestions[i];
            pLDQuestion.SVMXC__Section__c = pLDSection.id;
            pLDQuestion.SVMXC__Detail_Type__c = 'Question';
            pLDQuestion.SVMXC__Page_Layout__c = pageLayout.id;
            pLDQuestion.SVMXC__DataType__c = 'reference';
            lstPLDetail.add(pLDQuestion);
        }
        insert lstPLDetail;

        targetProcess = new SVMXC__ServiceMax_Processes__c();
        targetProcess.SVMXC__Name__c = 'Checklist_SOU';
        targetProcess.SVMXC__ProcessID__c = 'Checklist_SOU';
        targetProcess.SVMXC__Purpose__c = 'CHECKLIST';
        targetProcess.SVMXC__Page_Layout__c = pageLayout.id;
        targetProcess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        insert targetProcess;
        */

        list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateField = new list<SVMXC__ServiceMax_Config_Data__c>();   
        Map<String,Schema.SObjectField> mapSourceField = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();

        SVMXC__ServiceMax_Config_Data__c sourceField1 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField1.SVMXC__Source_Field_Name__c = 'SVMXC__Order_Type__c';
        sourceField1.SVMXC__SM_Question__c = lstQuestions[5].id;
        sourceField1.SVMXC__Action__c = 'Set';
        lstSourceUpdateField.add(sourceField1);
        
        SVMXC__ServiceMax_Config_Data__c sourceField2 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField2.SVMXC__Source_Field_Name__c = 'SVMXC__Priority__c';
        sourceField2.SVMXC__SM_Question__c = lstQuestions[6].id;
        sourceField2.SVMXC__Action__c = 'Set';
        lstSourceUpdateField.add(sourceField2);
        
        SVMXC__ServiceMax_Config_Data__c sourceField3 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField3.SVMXC__Source_Field_Name__c = 'SVMXC__Time_to_Initial_Response__c';
        sourceField3.SVMXC__SM_Question__c = lstQuestions[1].id;
        sourceField3.SVMXC__Action__c = 'Increase';
        lstSourceUpdateField.add(sourceField3);
        
        SVMXC__ServiceMax_Config_Data__c sourceField4 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField4.SVMXC__Source_Field_Name__c = 'SVMXC__Time_to_Resolve__c';
        sourceField4.SVMXC__SM_Question__c = lstQuestions[2].id;
        sourceField4.SVMXC__Action__c = 'Decrease';
        lstSourceUpdateField.add(sourceField4);
        
        SVMXC__ServiceMax_Config_Data__c sourceField5 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField5.SVMXC__Source_Field_Name__c = 'SVMXC__Driving_Time__c';
        sourceField5.SVMXC__SM_Question__c = lstQuestions[2].id;
        sourceField5.SVMXC__Action__c = 'Set';
        lstSourceUpdateField.add(sourceField5);

        SVMXC__ServiceMax_Config_Data__c sourceField6 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField6.SVMXC__Source_Field_Name__c = 'SVMXC__Latitude__c';
        sourceField6.SVMXC__SM_Question__c = lstQuestions[1].id;
        sourceField6.SVMXC__Action__c = 'Set';
        lstSourceUpdateField.add(sourceField6);
        
        SVMXC__ServiceMax_Config_Data__c sourceField7 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField7.SVMXC__Source_Field_Name__c = 'SVMXC__City__c';
        sourceField7.SVMXC__SM_Question__c = lstQuestions[0].id;
        sourceField7.SVMXC__Action__c = 'Set';
        lstSourceUpdateField.add(sourceField7);
        
        SVMXC__ServiceMax_Config_Data__c sourceField8 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField8.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        sourceField8.SVMXC__SM_Question__c = lstQuestions[3].id;
        sourceField8.SVMXC__Action__c = 'Set';
        lstSourceUpdateField.add(sourceField8);
        
        SVMXC__ServiceMax_Config_Data__c sourceField9 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField9.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date_Time__c';
        sourceField9.SVMXC__SM_Question__c = lstQuestions[4].id;
        sourceField9.SVMXC__Action__c = 'Set';
        lstSourceUpdateField.add(sourceField9);

        SVMXC__ServiceMax_Config_Data__c sourceField10 = new SVMXC__ServiceMax_Config_Data__c(); 
        sourceField10.SVMXC__Source_Field_Name__c = 'SVMXC__Group_Email__c';
        sourceField10.SVMXC__SM_Question__c = lstQuestions[7].id;
        sourceField10.SVMXC__Action__c = 'Set';
        lstSourceUpdateField.add(sourceField10);

        SVMXC__Checklist__c objChecklist = new SVMXC__Checklist__c();
        objChecklist.SVMXC__ChecklistJSON__c = '{"QB000011":"Bangalore","QB000012":234.78,"QB000013":2345,"QB000014":"2018-03-08","QB000015":"2018-03-08 07:19:00","QB000016":"Not sure","QB000017":"Courtesy","QB000018":"test@test11.com","QB000019":"www.test.com"}';
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();
        insert objWorkOrder;

        SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
         SFM_SaveTargetRecords.CreateSourceUpdateRequest objSourceUpdateRequest = new SFM_SaveTargetRecords.CreateSourceUpdateRequest(objChecklist, objWorkOrder, lstSourceUpdateField, mapSourceField, lstQuestions);
        SFMSaveTargetRecords.DoHeaderSourceObjectUpdate(objSourceUpdateRequest);
    }

    /*static testMethod void testForSaveChecklistAttachment()
    {
      String strRequest = '{"headerRecord":{"objName":"SVMXC__SM_Checklist_Attachment__c","pageLayoutId":"a0ZF000000DgxLwMAJ","records":[{"targetRecordAsKeyValue":[{"key":"SVMXC__SM_Checklist__c","value":"a1z0G00001JT5NMQA1"},{"key":"SVMXC__SM_Attachment_ID__c","value":"TestID1"}],"sourceRecordId":"a0H0G00000csrEOUAY"},{"targetRecordAsKeyValue":[{"key":"SVMXC__SM_Checklist__c","value":"a1z0G00001JT5NMQA1"},{"key":"SVMXC__SM_Attachment_ID__c","value":"TestID2"}],"sourceRecordId":"a0H0G00000csrEOUAY"}]},"sfmProcessId":"Checklist_on_IB","eventType":"save checklist attachment","detailRecords":[]}';
      //SFMDeliveryController.JsrSaveTarget();

      //saving record
      SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = (SVMXC.SFM_WrapperDef.SFM_TargetRecord)JSON.deserialize(strRequest, SVMXC.SFM_WrapperDef.SFM_TargetRecord.class);
      SFM_SaveTargetRecords objSaveTarget = new SFM_SaveTargetRecords();
      SVMXC.SFM_WrapperDef.SFM_Response objResponse = objSaveTarget.SaveTargetRecords(sfmtargetrec);
      System.assert(objResponse.records != null);
      System.assert(objResponse.records.size() == 2);

      //deleting record
      String strRecId = (String)objResponse.records[0].get('Id');
      sfmtargetrec.headerRecord.deleteRecID = new List<String>{strRecId};
      objResponse = objSaveTarget.SaveTargetRecords(sfmtargetrec);
      System.assert(objResponse.success == true);
      List<SVMXC__SM_Checklist_Attachment__c> lstCheckAtt = [SELECT Id FROM SVMXC__SM_Checklist_Attachment__c WHERE Id =: strRecId];
    System.assert(lstCheckAtt.size() == 0);

    //create exception
    strRequest = '{"headerRecord":{"objName":"SVMXC__SM_Checklist_Attachment__c","pageLayoutId":"a0ZF000000DgxLwMAJ","records":[{"targetRecordAsKeyValue":[{"key":"SVMXC__SM_Checklist__c","value":"a1z0G00001JT5NMQA1"},{"key":"SVMXC__SM_Attachment_ID__c","value":"TestID1"},{"key":"Id","value":\"'+strRecId+'\"}],"sourceRecordId":"a0H0G00000csrEOUAY"},{"targetRecordAsKeyValue":[{"key":"SVMXC__SM_Checklist__c","value":"a1z0G00001JT5NMQA1"},{"key":"SVMXC__SM_Attachment_ID__c","value":"TestID2"}],"sourceRecordId":"a0H0G00000csrEOUAY"}]},"sfmProcessId":"Checklist_on_IB","eventType":"save checklist attachment","detailRecords":[]}';
    sfmtargetrec = (SVMXC.SFM_WrapperDef.SFM_TargetRecord)JSON.deserialize(strRequest, SVMXC.SFM_WrapperDef.SFM_TargetRecord.class);
    sfmtargetrec.headerRecord.deleteRecID = null;
      objResponse = objSaveTarget.SaveTargetRecords(sfmtargetrec);
      System.assert(objResponse.success == false);
    }*/

     static testMethod void testForSaveDetailTargetRecordsAsSobjectForInsertChunk()
     {
         SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();     
         
         SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
         SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
         SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
         
         map<String, Id> mapRTypeNameId = new map<String, Id>(); 
         
         List<SFM_WrapperDef.SFM_Record> lstSFMRecord = new List<SFM_WrapperDef.SFM_Record>();
         List<SFM_WrapperDef.SFM_Record> lstSFMRecord1 = new List<SFM_WrapperDef.SFM_Record>();
         SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
         SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject1 = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
         SVMXC.SFM_WrapperDef.SFM_TargetRecord targetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
         List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> lstTargetRecordObject = new List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();  
 
         mapRTypeNameId = getRecordTypes();
         if(mapRTypeNameId != null)
         {  
             SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
             
             SVMXC__Page_Layout__c detailPageLayout = new SVMXC__Page_Layout__c();
             detailPageLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
             detailPageLayout.SVMXC__Type__c = 'WorkDetailLine';
             
             insert detailPageLayout; 
             System.assertEquals(true, detailPageLayout != null);
             
             SFMPNodeObject.RecordTypeId = mapRTypeNameId.get('Process Node Objects');
             SFMPNodeObject.SVMXC__Process__c = SFMProcess.id;
             SFMPNodeObject.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
             SFMPNodeObject.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
             SFMPNodeObject.SVMXC__Type__c = 'TARGETCHILD';
             SFMPNodeObject.SVMXC__Page_Layout__c = detailPageLayout.Id;
 
             insert SFMPNodeObject;
             System.assertEquals(true, SFMPNodeObject != null);
 
             objWorkOrder.SVMXC__City__c = 'Bangalore';
             objWorkOrder.SVMXC__Country__c = 'India';
             objWorkOrder.SVMXC__Street__c = 'Cunninghum';
             
             insert objWorkOrder;
             System.assertEquals(true, objWorkOrder != null);
             
             
             for(Integer i=0; i<2002; i++){
                 SFM_WrapperDef.SFM_Record SFMRec2 = new SFM_WrapperDef.SFM_Record();
                 SFMRec2.sourceRecordId = objWorkOrder.id;
                 sObject wd2 = new SVMXC__Service_Order_Line__c();
                 wd2.put('SVMXC__Received_City__c', 'fdsflksjdfl dslkfjlkdsjf klsdjflk ajsd fkljadslkf jlkadsj flkasdj fklasdjfklajsdjlkfjklsdjfkl jkldjfk');
                 SFMRec2.sObjectRecord = wd2;
                 SFMRec2.rowIndex = String.valueOf(i);
                 lstSFMRecord.add(SFMRec2);
             }
             
             
             SFM_WrapperDef.SFM_Record SFMRec3 = new SFM_WrapperDef.SFM_Record();
             SFMRec3.sobjectinfo = objWorkOrder; 
             lstSFMRecord1.add(SFMRec3);
             
             targetRecordObject.objName = 'SVMXC__Service_Order__c';
             targetRecordObject.records =  lstSFMRecord1;
 
             targetRecordObject1.objName = 'SVMXC__Service_Order_Line__c';
             targetRecordObject1.aliasName = String.valueof(detailPageLayout.id);
             targetRecordObject1.parentColumnName = 'SVMXC__Service_Order__c';
             targetRecordObject1.records =  lstSFMRecord;
             lstTargetRecordObject.add(targetRecordObject1);
             
             targetRecord.sfmProcessId = SFMProcess.Id;
             targetRecord.headerRecord = targetRecordObject;
             targetRecord.detailRecords = lstTargetRecordObject;
             SFMSaveTargetRecords.SaveTargetRecords(targetRecord);
         }
     }

   static testMethod void testForSaveDetailTargetRecordsAsSobjectForUpdateChunk()
   {
       SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();       
       SVMXC__Service_Order_Line__c objWorkOrderDetail = new SVMXC__Service_Order_Line__c();       
       
       SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
       SVMXC__ServiceMax_Processes__c SFMPNodeObject = new SVMXC__ServiceMax_Processes__c();
       SFM_SaveTargetRecords SFMSaveTargetRecords = new SFM_SaveTargetRecords();
       
       map<String, Id> mapRTypeNameId = new map<String, Id>();
       
       List<SFM_WrapperDef.SFM_Record> lstSFMRecord = new List<SFM_WrapperDef.SFM_Record>();
       List<SFM_WrapperDef.SFM_Record> lstSFMRecord1 = new List<SFM_WrapperDef.SFM_Record>();
       SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
       SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject1 = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
       SVMXC.SFM_WrapperDef.SFM_TargetRecord targetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
       List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> lstTargetRecordObject = new List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();  

       mapRTypeNameId = getRecordTypes();
       if(mapRTypeNameId != null)
       {  
           SFMProcess = getSFMProcess(mapRTypeNameId.get('Target Manager'));
           
           SVMXC__Page_Layout__c detailPageLayout = new SVMXC__Page_Layout__c();
           detailPageLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
           detailPageLayout.SVMXC__Type__c = 'WorkDetailLine';
           
           insert detailPageLayout; 
           System.assertEquals(true, detailPageLayout != null);
           
           SFMPNodeObject.RecordTypeId = mapRTypeNameId.get('Process Node Objects');
           SFMPNodeObject.SVMXC__Process__c = SFMProcess.id;
           SFMPNodeObject.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
           SFMPNodeObject.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
           SFMPNodeObject.SVMXC__Type__c = 'TARGETCHILD';
           SFMPNodeObject.SVMXC__Page_Layout__c = detailPageLayout.Id;

           insert SFMPNodeObject;
           System.assertEquals(true, SFMPNodeObject != null);

           objWorkOrder.SVMXC__City__c = 'Bangalore';
           objWorkOrder.SVMXC__Country__c = 'India';
           objWorkOrder.SVMXC__Street__c = 'Cunninghum';
           
           insert objWorkOrder;
           System.assertEquals(true, objWorkOrder != null);
           
           objWorkOrderDetail.SVMXC__Service_Order__c = objWorkOrder.Id;
           objWorkOrderDetail.SVMXC__Select__c = true;
           
           insert objWorkOrderDetail;
           System.assertEquals(true, objWorkOrderDetail != null);

           List<SVMXC__Service_Order_Line__c> recordList = new List<SVMXC__Service_Order_Line__c>();       

           for(Integer i=0; i<2002; i++){
                   SVMXC__Service_Order_Line__c detail = new SVMXC__Service_Order_Line__c();
                   detail.SVMXC__Service_Order__c = objWorkOrder.Id;
                   detail.SVMXC__Select__c = true;
                   recordList.add(detail);
           }
           
           insert recordList;

           for(Integer i=0; i<2002; i++){
               SFM_WrapperDef.SFM_Record SFMRec1 = new SFM_WrapperDef.SFM_Record();
               SFMRec1.sourceRecordId = objWorkOrder.id;
               sObject wd1 = new SVMXC__Service_Order_Line__c();
               wd1.put('SVMXC__Received_City__c', 'fdsflksjdfl dslkfjlkdsjf klsdjflk ajsd fkljadslkf jlkadsj flkasdj fklasdjfklajsdjlkfjklsdjfkl jkldjfk');
               SFMRec1.sObjectRecord = wd1;
               SFMRec1.rowIndex = String.valueOf(i);
               SfmRec1.targetRecordId = recordList.get(i).Id;
               lstSFMRecord.add(SFMRec1);
           }
           

           /*SFM_WrapperDef.SFM_Record SFMRec1 = new SFM_WrapperDef.SFM_Record();
           SFMRec1.sourceRecordId = objWorkOrder.id;
           sObject wd1 = new SVMXC__Service_Order_Line__c();
           wd1.put('SVMXC__Received_City__c', 'fdsflksjdfl dslkfjlkdsjf klsdjflk ajsd fkljadslkf jlkadsj flkasdj fklasdjfklajsdjlkfjklsdjfkl jkldjfk');
           SFMRec1.sObjectRecord = wd1;
           SFMRec1.rowIndex = '0';
           SfmRec1.targetRecordId = objWorkOrderDetail.id;
           lstSFMRecord.add(SFMRec1);*/

           SFM_WrapperDef.SFM_Record SFMRec3 = new SFM_WrapperDef.SFM_Record();
           SFMRec3.sobjectinfo = objWorkOrder; 
           lstSFMRecord1.add(SFMRec3);
           
           targetRecordObject.objName = 'SVMXC__Service_Order__c';
           targetRecordObject.records =  lstSFMRecord1;

           targetRecordObject1.objName = 'SVMXC__Service_Order_Line__c';
           targetRecordObject1.aliasName = String.valueof(detailPageLayout.id);
           targetRecordObject1.parentColumnName = 'SVMXC__Service_Order__c';
           targetRecordObject1.records =  lstSFMRecord;
           lstTargetRecordObject.add(targetRecordObject1);
           
           targetRecord.sfmProcessId = SFMProcess.Id;
           targetRecord.headerRecord = targetRecordObject;
           targetRecord.detailRecords = lstTargetRecordObject;
           SFMSaveTargetRecords.SaveTargetRecords(targetRecord);
       }
   }
}