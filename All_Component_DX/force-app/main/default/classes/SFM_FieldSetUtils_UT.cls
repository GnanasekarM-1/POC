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
private class SFM_FieldSetUtils_UT {
    
    static testMethod void SFM_FieldSetUtilsTest() {
        
        // TO DO: implement unit test
        list<String> lstFieldSetAPIName = new list<String>();
        list<SFM_WrapperDef.SortingRec> lstSortingRec = new list<SFM_WrapperDef.SortingRec>();
        String strObjectName;
        ID fieldMapId;
        ID valueMapId;
        ID pageLayoutId; 
        SVMXC.SFM_WrapperDef.FieldSetWithSorting fs = new SVMXC.SFM_WrapperDef.FieldSetWithSorting();
        SVMXC.SFM_WrapperDef.SortingRec sr = new SVMXC.SFM_WrapperDef.SortingRec('abc','def','','','','','');
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        SVMXC.SFM_WrapperDef.SFM_StringListMap stringListMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
        stringListMap.key = 'OBJECTAPINAME';
        stringListMap.valueList.add('SVMXC__Service_Order__c');
        request.stringListMap.add(stringListMap);
        SFM_FieldSetUtils fsu = new SFM_FieldSetUtils();
        fsu.SFM_getFieldSetDefinition(request);
        
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
                    SVMXRule = r.Name;      
            }
        }
        
        //----Start---Added for the defect fix BAC-3884
        SVMXC__ServiceMax_Processes__c ObjectFieldMap = new SVMXC__ServiceMax_Processes__c();
        ObjectFieldMap.SVMXC__Source_Object_Name__c = 'Account';
        ObjectFieldMap.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        ObjectFieldMap.SVMXC__MapID__c='Account_to_WO_Map';
        ObjectFieldMap.SVMXC__Name__c = 'Account to WO Map';
        ObjectFieldMap.RecordTypeId = objectMapping;
        insert ObjectFieldMap;

        SVMXC__ServiceMax_Config_Data__c objFieldMap = new SVMXC__ServiceMax_Config_Data__c();
        objFieldMap.RecordTypeId = Fieldmapping;
        objFieldMap.SVMXC__Configuration_Type__c = 'Field Mapping';
        objFieldMap.SVMXC__Parameter_Type__c = 'Field Value';
        objFieldMap.SVMXC__MapID__c = ObjectFieldMap.id;
        objFieldMap.SVMXC__Source_Field_Name__c ='CreatedDate' ;
        objFieldMap.SVMXC__Target_Field_Name__c ='SVMXC__FirstScheduledDateTime__c' ;
        insert objFieldMap;
        //----End-----Added for the defect fix BAC-3884

        SVMXC__Page_Layout__c objHeaderLayout = new SVMXC__Page_Layout__c();
        objHeaderLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        objHeaderLayout.SVMXC__Type__c = 'Header';
        insert objHeaderLayout;
        
        List<SVMXC__Page_Layout_Detail__c> lstHeaderFields = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c objfld1 = new SVMXC__Page_Layout_Detail__c();
        objfld1.SVMXC__Detail_Type__c = 'Field';
        objfld1.SVMXC__Field_API_Name__c = 'SVMXC__Company__c';
        objfld1.SVMXC__Related_Object_Name__c = 'Account';
        objfld1.SVMXC__Related_Object_Name_Field__c = 'Name';
        objfld1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld1.SVMXC__DataType__c = 'REFERENCE';
        objfld1.SVMXC__Sequence__c = 1;
        objfld1.SVMXC__Field_Mapping__c = ObjectFieldMap.id; //Added for the defect fix BAC-3884
        lstHeaderFields.add(objfld1);
        SVMXC__Page_Layout_Detail__c objfld2 = new SVMXC__Page_Layout_Detail__c();
        objfld2.SVMXC__Detail_Type__c = 'Field';
        objfld2.SVMXC__Field_API_Name__c = 'Name';
        objfld2.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld2.SVMXC__DataType__c = 'String';
        objfld2.SVMXC__Sequence__c = 2;
        lstHeaderFields.add(objfld2);
        
        SVMXC__Page_Layout_Detail__c objfld3 = new SVMXC__Page_Layout_Detail__c();
        objfld3.SVMXC__Detail_Type__c = 'Field';
        objfld3.SVMXC__Field_API_Name__c = 'SVMXC__Auto_Entitlement_Status__c ';
        objfld3.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld3.SVMXC__DataType__c = 'picklist';
        objfld3.SVMXC__Sequence__c = 3;
        lstHeaderFields.add(objfld3);
        insert lstHeaderFields;
        
        SVMXC__ServiceMax_Processes__c ObjectMap = new SVMXC__ServiceMax_Processes__c();
        ObjectMap.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        ObjectMap.SVMXC__MapID__c='CUSTOMMAP0001';
        ObjectMap.SVMXC__Name__c = 'CUSTOMMAP0001';
        ObjectMap.RecordTypeId = objectMapping;
        insert ObjectMap;
        
        list<SVMXC__ServiceMax_Config_Data__c> FieldMapList = new list<SVMXC__ServiceMax_Config_Data__c>();        
        /*SVMXC__ServiceMax_Config_Data__c FieldMap = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap.RecordTypeId =Fieldmapping;
        FieldMap.SVMXC__MapID__c = ObjectMap.id ;
        FieldMap.SVMXC__Source_Field_Name__c ='SVMXC__City__c' ;
        FieldMap.SVMXC__Target_Field_Name__c ='SVMXC__City__c' ;
        FieldMapList.add(FieldMap); */
        
        SVMXC__ServiceMax_Config_Data__c FieldMap1 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap1.RecordTypeId =Fieldmapping;
        FieldMap1.SVMXC__MapID__c = ObjectMap.id;
        FieldMap1.SVMXC__Source_Field_Name__c ='SVMXC__Contact__c' ;
        FieldMap1.SVMXC__Target_Field_Name__c ='SVMXC__Contact__c' ;
        FieldMapList.add(FieldMap1); 

        SVMXC__ServiceMax_Config_Data__c FieldMap2 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap2.RecordTypeId =Fieldmapping;
        FieldMap2.SVMXC__MapID__c = ObjectMap.id;
        FieldMap2.SVMXC__Target_Field_Name__c ='SVMXC__Contact__c' ;
        FieldMap2.SVMXC__Parameter_Type__c = 'Field Value';
        FieldMap2.SVMXC__Display_Value__c = 'SVMX.CURRENTRECORD.SVMXC__Contact__c';
        FieldMapList.add(FieldMap2);

        SVMXC__ServiceMax_Config_Data__c FieldMap3 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap3.RecordTypeId =Fieldmapping;
        FieldMap3.SVMXC__MapID__c = ObjectMap.id;
        FieldMap3.SVMXC__Target_Field_Name__c ='SVMXC__City__c' ;
        FieldMap3.SVMXC__Parameter_Type__c = 'Header Field Value';
        FieldMap3.SVMXC__Display_Value__c = 'SVMX.CURRENTRECORDHEADER.SVMXC__City__c';
        FieldMapList.add(FieldMap3); 
        insert FieldMapList;
        
        SFMDeliveryServiceImpl.setIsQueryOptimizerEnabled(true);
        map<String, Schema.SObjectType> mapAllObjectDescribe = new map<String, Schema.SObjectType>();
        map<String,SVMXC.SFM_WrapperDef.FieldSetWithSorting> mapFS = new map<String,SVMXC.SFM_WrapperDef.FieldSetWithSorting>();
        mapAllObjectDescribe.put('SVMXC__Service_Order__c',SVMXC__Service_Order__c.sObjectType);
        fs = new SVMXC.SFM_WrapperDef.FieldSetWithSorting(lstFieldSetAPIName,lstSortingRec,'SVMXC__Service_Order__c',ObjectMap.id,ObjectMap.id,objHeaderLayout.Id);
        mapFS.put('SVMX_key',fs);
        fsu.SFM_buildFieldListFromFieldSet(mapFS,mapAllObjectDescribe);
    }
}