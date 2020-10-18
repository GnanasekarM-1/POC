@isTest
Private with sharing class SFM_SaveAsExpression_UT
{
    static testMethod void SFM_saveAsExpression_UT_Test()
    {
        //..............Data Creation............
        List<RecordType> RtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
        System.assertEquals(true, RtypeLst != null);
        
        SVMXC__ServiceMax_Processes__c processobj = new SVMXC__ServiceMax_Processes__c();
        processobj.RecordTypeId=RtypeLst[0].Id;
        processobj.SVMXC__Name__c='NamedExpression001';
        processobj.SVMXC__Rule_Type__c = 'Named Expression';
        processobj.SVMXC__SettingId__c='expid001';
        processobj.SVMXC__Source_Object_Name__c='SVMXC__Site__c';
        insert processobj;
        System.assertEquals(true, processobj != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfigData=new SVMXC__ServiceMax_Config_Data__c();
        List<SVMXC__ServiceMax_Config_Data__c> ConfigDataLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        ConfigDataLst.add(ConfigData);
        SFM_WrapperDef.SFM_Expression ExpObj=  new SFM_WrapperDef.SFM_Expression(processobj,ConfigDataLst);
        List<SFM_WrapperDef.SFM_Expression>  ExpObj_List= new List<SFM_WrapperDef.SFM_Expression>();
        ExpObj_List.add(ExpObj);
        System.assertEquals(true, ExpObj_List != null);
            
        //...............class instantiation and calling various methods.............
        SFM_WrapperDef.SFM_Request_Expression ExpReq= new SFM_WrapperDef.SFM_Request_Expression(ExpObj_List);
        SFM_saveAsExpression saveAsExp_Obj = new SFM_saveAsExpression();
        saveAsExp_Obj.SFM_saveAsExpression(ExpReq);
    
    }
}