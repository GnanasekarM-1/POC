@isTest
Private with sharing class SFM_SaveExpression_UT
{
    static testMethod void SFM_saveExpression_UT_Test()
    {
    RecordType[] array_Sobj = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
    System.assertEquals(true, array_Sobj != null);
    
    RecordType[] ConfigDataRtype = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Expressions' ];
    System.assertEquals(true, ConfigDataRtype != null);
           
           SVMXC__Site__c loc = new SVMXC__Site__c();
           loc.Name = '1';
           insert loc;
            //process
            SVMXC__ServiceMax_Processes__c process_Obj = new SVMXC__ServiceMax_Processes__c();
            process_Obj.RecordTypeId=array_Sobj[0].Id;
            process_Obj.SVMXC__Name__c='NamedExpression';
            //process_Obj.SVMXC__Rule_Type__c = 'Named Expression';   // For else condition
            process_Obj.SVMXC__SettingId__c='expid001';
            process_Obj.SVMXC__Source_Object_Name__c='SVMXC__Site__c';
            process_Obj.SVMXC__Advance_Expression__c = 'Name != null ';
            insert process_Obj;
            System.assertEquals(true, process_Obj != null);
            
            //Config Data
            SVMXC__ServiceMax_Config_Data__c svmx_configData_Obj = new SVMXC__ServiceMax_Config_Data__c();
            svmx_configData_Obj.RecordTypeId = ConfigDataRtype[0].Id;
            svmx_configData_Obj.SVMXC__Operator__c ='+';
            svmx_configData_Obj.SVMXC__Operand__c = '1';
            svmx_configData_Obj.SVMXC__Description__c = '1';
            svmx_configData_Obj.SVMXC__Field_Name__c = 'SVMXC__Description__c';
            insert svmx_configData_Obj;
            System.assertEquals(true, svmx_configData_Obj != null);

            List<SVMXC__ServiceMax_Config_Data__c> lst_svmx_configData_Obj = new List<SVMXC__ServiceMax_Config_Data__c>();
            lst_svmx_configData_Obj.add(svmx_configData_Obj);
            
            //Instance of class
            SFM_saveExpression SaveExp = new SFM_saveExpression();
    
            //DATA creation
            List<SFM_WrapperDef.SFM_Expression> expressionsLst = new List<SFM_WrapperDef.SFM_Expression>();
            
            SFM_WrapperDef.SFM_Expression expressionsObj = new SFM_WrapperDef.SFM_Expression(process_Obj,lst_svmx_configData_Obj);
            expressionsLst.add(expressionsObj);
            
            SFM_WrapperDef.SFM_Request_Expression ExpReq = new SFM_WrapperDef.SFM_Request_Expression(expressionsLst);
            
            //Call methods
            SaveExp.SFM_saveExpression(ExpReq);
    }
    
    static testMethod void SFM_saveExpression_UT_Test1()
    {
    RecordType[] array_Sobj = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
    System.assertEquals(true, array_Sobj != null);
    
    RecordType[] ConfigDataRtype = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Expressions' ];
    System.assertEquals(true, array_Sobj != null);
           
           SVMXC__Site__c loc = new SVMXC__Site__c();
           loc.Name = '1';
           insert loc;
           System.assertEquals(true, loc != null);
            //process
            SVMXC__ServiceMax_Processes__c process_Obj = new SVMXC__ServiceMax_Processes__c();
            process_Obj.RecordTypeId=array_Sobj[0].Id;
            process_Obj.SVMXC__Name__c='NamedExpression';
            process_Obj.SVMXC__Rule_Type__c = 'Named Expression';
            process_Obj.SVMXC__SettingId__c='expid001';
            process_Obj.SVMXC__Source_Object_Name__c='SVMXC__Site__c';
            process_Obj.SVMXC__Advance_Expression__c = 'Name != null ';
            process_Obj.SVMXC__ProcessID__c = 'INV001_Process';
            insert process_Obj;
            System.assertEquals(true, process_Obj != null);
            
            //process 2
            SVMXC__ServiceMax_Processes__c process_Obj1 = new SVMXC__ServiceMax_Processes__c();
            process_Obj1.RecordTypeId=array_Sobj[0].Id;
            process_Obj1.SVMXC__Name__c='NamedExpression';
            process_Obj1.SVMXC__Rule_Type__c = 'Named Expression';
            process_Obj1.SVMXC__SettingId__c='expid001';
            process_Obj1.SVMXC__Source_Object_Name__c='SVMXC__Site__c';
            process_Obj1.SVMXC__Advance_Expression__c = 'Name != null ';
            process_Obj1.SVMXC__ProcessID__c = process_Obj.Id;
            insert process_Obj1;
            System.assertEquals(true, process_Obj1 != null);
            
            //Config Data
            SVMXC__ServiceMax_Config_Data__c svmx_configData_Obj = new SVMXC__ServiceMax_Config_Data__c();
            svmx_configData_Obj.RecordTypeId = ConfigDataRtype[0].Id;
            svmx_configData_Obj.SVMXC__Expression_Rule__c = process_Obj1.Id;
            svmx_configData_Obj.SVMXC__Operator__c ='+';
            svmx_configData_Obj.SVMXC__Operand__c = '1';
            svmx_configData_Obj.SVMXC__Description__c = '1';
            svmx_configData_Obj.SVMXC__Field_Name__c = 'SVMXC__Description__c';
            insert svmx_configData_Obj;
            System.assertEquals(true, svmx_configData_Obj != null);

            List<SVMXC__ServiceMax_Config_Data__c> lst_svmx_configData_Obj = new List<SVMXC__ServiceMax_Config_Data__c>();
            lst_svmx_configData_Obj.add(svmx_configData_Obj);
            
            //Instance of class
            SFM_saveExpression SaveExp = new SFM_saveExpression();
    
            //DATA creation
            List<SFM_WrapperDef.SFM_Expression> expressionsLst = new List<SFM_WrapperDef.SFM_Expression>();
            
            SFM_WrapperDef.SFM_Expression expressionsObj = new SFM_WrapperDef.SFM_Expression(process_Obj,lst_svmx_configData_Obj);
            expressionsLst.add(expressionsObj);
            
            SFM_WrapperDef.SFM_Request_Expression ExpReq = new SFM_WrapperDef.SFM_Request_Expression(expressionsLst);
            
            //Call methods
            SaveExp.SFM_saveExpression(ExpReq);
    }
}