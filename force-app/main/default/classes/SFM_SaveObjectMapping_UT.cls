//94
@isTest
private class SFM_SaveObjectMapping_UT
{
    static testMethod void SFM_saveObjectMapping_Test()
    {     
        SFM_WrapperDef.SFM_Request_ObjectMap ObjReq = new SFM_WrapperDef.SFM_Request_ObjectMap();
        SFM_WrapperDef.SFM_ObjectMap wrapper_ObjMap_Obj = new SFM_WrapperDef.SFM_ObjectMap();
                
        List<RecordType> lstRecType1  = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Object Mapping'];
        SVMXC__ServiceMax_Processes__c servicemax_process = new SVMXC__ServiceMax_Processes__c(RecordTypeId =lstRecType1[0].Id,SVMXC__Active__c = true,SVMXC__Name__c = 'ObjMaptest1',SVMXC__MapID__c = 'CustomMap1',SVMXC__Source_Object_Name__c='SVMXC__Site__c',SVMXC__Target_Object_Name__c='SVMXC__Installed_Product__c',SVMXC__Description__c='desc001');
        insert servicemax_process;
        System.assert(servicemax_process.id != null);
                
        SVMXC__ServiceMax_Config_Data__c objConfig1 = new SVMXC__ServiceMax_Config_Data__c();   
        objConfig1.SVMXC__Source_Field_Name__c = 'Name';    
        objConfig1.SVMXC__Display_Value__c = 'SVMX.CURRENTRECORDHEADER';
        insert objConfig1;
        System.assert(objConfig1.id != null);
        
        SVMXC__ServiceMax_Config_Data__c objConfig2 = new SVMXC__ServiceMax_Config_Data__c();       
        objConfig2.SVMXC__Display_Value__c = 'SVMX.CURRENTRECORD';
        insert objConfig2;
        System.assert(objConfig2.id != null);
        
        SVMXC__ServiceMax_Config_Data__c objConfig3 = new SVMXC__ServiceMax_Config_Data__c();   
        objConfig3.SVMXC__Display_Value__c = 'SVMX.USERTRUNK';
        insert objConfig3;
        System.assert(objConfig3.id != null);
        
        SVMXC__ServiceMax_Config_Data__c objConfig4 = new SVMXC__ServiceMax_Config_Data__c();           
        objConfig4.SVMXC__Display_Value__c = 'TODAY';
        insert objConfig4;
        System.assert(objConfig4.id != null);
        
        SVMXC__ServiceMax_Config_Data__c objConfig5 = new SVMXC__ServiceMax_Config_Data__c();       
        objConfig5.SVMXC__Display_Value__c = 'SVMX.CURRENTRECORDHEADER.';
        insert objConfig5;
        System.assert(objConfig5.id != null);
        
        SVMXC__ServiceMax_Config_Data__c objConfig6 = new SVMXC__ServiceMax_Config_Data__c();       
        objConfig6.SVMXC__Display_Value__c = 'SVMX.CURRENTRECORD.';
        insert objConfig6;
        System.assert(objConfig6.id != null);
        
        SFM_WrapperDef.SFM_FieldMapping field_mappin1 = new SFM_WrapperDef.SFM_FieldMapping();      
        field_mappin1.fieldMapRecord = objConfig1;
        SFM_WrapperDef.SFM_FieldMapping field_mappin2 = new SFM_WrapperDef.SFM_FieldMapping();      
        field_mappin2.fieldMapRecord = objConfig2;
        SFM_WrapperDef.SFM_FieldMapping field_mappin3 = new SFM_WrapperDef.SFM_FieldMapping();      
        field_mappin3.fieldMapRecord = objConfig3;
        SFM_WrapperDef.SFM_FieldMapping field_mappin4 = new SFM_WrapperDef.SFM_FieldMapping();      
        field_mappin4.fieldMapRecord = objConfig4;
        SFM_WrapperDef.SFM_FieldMapping field_mappin5 = new SFM_WrapperDef.SFM_FieldMapping();      
        field_mappin5.fieldMapRecord = objConfig5;
        SFM_WrapperDef.SFM_FieldMapping field_mappin6 = new SFM_WrapperDef.SFM_FieldMapping();      
        field_mappin6.fieldMapRecord = objConfig6;
        List<SFM_WrapperDef.SFM_FieldMapping> list_fieldMap = new List<SFM_WrapperDef.SFM_FieldMapping>();
        list_fieldMap.add(field_mappin1);
        list_fieldMap.add(field_mappin2);
        list_fieldMap.add(field_mappin3);
        list_fieldMap.add(field_mappin4);
        list_fieldMap.add(field_mappin5);
        list_fieldMap.add(field_mappin6);
        wrapper_ObjMap_Obj.fields = list_fieldMap ;        
        wrapper_ObjMap_Obj.objectMap = servicemax_process;      
        List<SFM_WrapperDef.SFM_ObjectMap> ObjMap_Obj_lst = new List<SFM_WrapperDef.SFM_ObjectMap>();
        ObjMap_Obj_lst.add(wrapper_ObjMap_Obj);     
        ObjReq.objects = ObjMap_Obj_lst;
        SFM_SaveObjectMapping save_Obj = new SFM_SaveObjectMapping();
        save_Obj.SFM_SaveObjectMapping(ObjReq);
        
        ////////////
        SVMXC__ServiceMax_Processes__c servicemax_process1 = new SVMXC__ServiceMax_Processes__c(RecordTypeId =lstRecType1[0].Id,SVMXC__Active__c = true,SVMXC__Name__c = 'ObjMaptest2',SVMXC__MapID__c = 'CustomMap2',SVMXC__Source_Object_Name__c='SVMXC__Site__c',SVMXC__Target_Object_Name__c='SVMXC__Installed_Product__c',SVMXC__Description__c='desc002');
        
        SFM_WrapperDef.SFM_ObjectMap wrapper_ObjMap_Obj1 = new SFM_WrapperDef.SFM_ObjectMap();
        wrapper_ObjMap_Obj1.fields = list_fieldMap;
        wrapper_ObjMap_Obj1.objectMap = servicemax_process1;
        ObjMap_Obj_lst.add(wrapper_ObjMap_Obj1);
        ObjReq.objects = ObjMap_Obj_lst;       
        save_Obj.SFM_SaveObjectMapping(ObjReq);     
        ////////////
        
        //----------- Covering DMLException block
        wrapper_ObjMap_Obj.objectMap = null;
        servicemax_process.SVMXC__MapID__c = 'someId12';
        update servicemax_process;
        wrapper_ObjMap_Obj.objectMap = servicemax_process;
        
        SFM_SaveObjectMapping save_Obj2 = new SFM_SaveObjectMapping();
        save_Obj2.SFM_SaveObjectMapping(ObjReq);
    }
}