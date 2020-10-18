@isTest(SeeAllData=true)
Private class SFM_BuildSobject_UT{
    static testMethod void SFM_BuildSobject_test(){
    
        //*****instance of class*****
        SFM_buildSobject buildSobj = new SFM_buildSobject ();
        
        //***** Data Creation*****
        
        list<RecordType> list_RType = [SELECT Id, Name, IsActive from RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND NAME='Named Search' limit 1];
        System.assertEquals(true, list_RType != null);
        
        //*****Variable declaration for 1st Data*****
        String recordID = list_RType[0].Id;
        String objectName = 'SVMXC__ServiceMax_Processes__c';
        String parentColumnName;
        integer noOfSobjects = 1;
        
        //*****Variable declaration for 2nd Data*****
        String recordID_2 ;
        String objectName_2 = 'SVMXC__ServiceMax_Processes__c';
        String parentColumnName_2 = 'SVMXC__Assign_Work_Order_To__c';
        integer noOfSobjects_2 = 1;
        
        //*****Variable declaration for 3rd Data*****
        String recordID_3 ;
        String objectName_3 = 'SVMXC__ServiceMax_Processes__c';
        String parentColumnName_3 = 'SVMXC__Assign_Work_Order_To__c';
        integer noOfSobjects_3 ;
        
        //*****Variable declaration for 4th Data*****
        String recordID_4 = list_RType[0].Id;
        String objectName_4 = 'SVMXC__ServiceMax_Processes__c';
        String parentColumnName_4 = 'SVMXC__Assign_Work_Order_To__c';
        integer noOfSobjects_4 = 10;
        
        //String ObjectName = 'Case';
        //Map<String, Schema.SObjectType> mapStrSchema = new Map<String, Schema.SObjectType>();
        //mapStrSchema.put('ObjectName',Case.getSobjectType());
        //mapStrSchema.containskey(ObjectName);
        //System.debug('*****'+mapStrSchema.containskey(ObjectName));
        //System.debug('*****ObjectName.length()'+ObjectName.length());
        
        
        //*****Calling Method*****
        SVMXC__ServiceMax_Processes__c obj = new SVMXC__ServiceMax_Processes__c();
        obj.SVMXC__MapID__c = 'fdafdsfdasfadsfdsfa';
        insert obj;
        recordID = obj.Id;
        buildSobj.getSFM_BuildSobject(recordID,objectName,parentColumnName,noOfSobjects);
        buildSobj.getSFM_BuildSobject(recordID_2,objectName_2,parentColumnName_2,noOfSobjects_2);
        buildSobj.getSFM_BuildSobject(recordID_3,objectName_3,parentColumnName_3,noOfSobjects_3);
        buildSobj.getSFM_BuildSobject(recordID_4,objectName_4,parentColumnName_4,noOfSobjects_4);
        buildSobj.SFM_buildTargetSobjectFromInputFieldsWithSorting(recordID_4,objectName_4,parentColumnName_4,noOfSobjects_4, new Set<String>{'Id','CreatedDate'}, 'CreatedDate');
        
        SFMDeliveryServiceImpl.setIsQueryOptimizerEnabled(true);
        buildSobj.getSFM_BuildSobject(recordID,objectName,parentColumnName,noOfSobjects);
        
        set<String> setFields = new set<String>();
        setFields.add('SVMXC__Assign_Work_Order_To__c');
        setFields.add('Name');
        buildSobj.buildQueryStringFromSet(setFields);
        SVMXC__Service_Order__c WorkOrder  = new SVMXC__Service_Order__c();
        WorkOrder.SVMXC__City__c = 'Blore';
        insert WorkOrder;
        set<String> setId = new set<String>();
        setId.add(WorkOrder.id);
        buildSobj.SFM_buildSourceRecords(WorkOrder.id, 'SVMXC__Service_Order__c', null, 'Name,Id');
        buildSobj.SFM_buildSourceRecords(WorkOrder.id, 'SVMXC__Service_Order_Line__c', 'SVMXC__Service_Order__c', 'Name,Id');
        buildSobj.SFM_buildSourceRecordsWithSorting(recordID_4, objectName_4, parentColumnName_4, 'Id,Name','Name');
        map<String,map<String,Schema.SObjectField>> AllFieldDescribe = new map<String,map<String,Schema.SObjectField>>();
        AllFieldDescribe.put('SVMXC__Service_Order__c',Schema.Sobjecttype.SVMXC__Service_Order__c.fields.getMap());
        buildSobj.getSFM_BuildSobject2(setId, 'SVMXC__Service_Order__c', null, AllFieldDescribe);
        buildSobj.getSFM_BuildSobject2(null, 'SVMXC__Service_Order__c', 2, AllFieldDescribe);
        buildSobj.getSFM_BuildSobjectsFromInputField(setId, 'SVMXC__Service_Order__c', null, AllFieldDescribe, new Set<String>{'Id','CreatedDate'});
        System.assertEquals(true, buildSobj.getSFM_BuildSobject(recordID,objectName,parentColumnName,noOfSobjects) != null);
        System.assertEquals(true, buildSobj.getSFM_BuildSobject(recordID_2,objectName_2,parentColumnName_2,noOfSobjects_2) != null);
        System.assertEquals(true, buildSobj.getSFM_BuildSobject(recordID_3,objectName_3,parentColumnName_3,noOfSobjects_3) != null);
        System.assertEquals(true, buildSobj.getSFM_BuildSobject(recordID_4,objectName_4,parentColumnName_4,noOfSobjects_4) != null);
    }
}