@isTest(SeeAllData=true)
private class COMM_Utils_ObjectMapping_UT {

    static testMethod void COMM_Utils_ObjectMappingUnitTest() {
        RecordType Rtypemap = [select Id from RecordType where Name=:'Object Mapping'and SobjectType=:'SVMXC__ServiceMax_Processes__c'];
        RecordType Rtypefieldmap = [select Id from RecordType where Name=:'Field Mapping'and SobjectType=:'SVMXC__ServiceMax_Config_Data__c'];
        system.assertNotEquals(Rtypemap,null);
        system.assertNotEquals(Rtypefieldmap,null);
        List<SVMXC__Installed_Product__c> ListSobj = new  List<SVMXC__Installed_Product__c>();
        
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        System.assertEquals('TestAccount', acc.name);
        Product2 prod1 = new Product2(Name = 'Prod1', ProductCode = '1234', Family = 'Accessory', SVMXC__Inherit_Parent_Warranty__c =False);
        insert prod1;
        System.assertEquals('Prod1', prod1.name);
        Product2 prod2 = new Product2(Name = 'Prod2', ProductCode = '1235', Family = 'Accessory', SVMXC__Inherit_Parent_Warranty__c =True);
        insert prod2;
        System.assertEquals('Prod2', prod2.name);
        Product2 prod3 = new Product2(Name = 'Prod3', ProductCode = '12353', SVMXC__Inherit_Parent_Warranty__c =True);
        insert prod3;
         System.assertEquals('Prod3', prod3.name);
        //create service template1 

        SVMXC__Service_Template__c st1 = new SVMXC__Service_Template__c(Name = '6 Months from Install Date', SVMXC__Template_Type__c = 'Warranty', SVMXC__Coverage_Effective_From__c = 'Install Date', Duration_of_Time_Coverage__c =6, SVMXC__Duration_of_Material_Coverage__c = 6, Duration_of_Expenses__c = 6, SVMXC__Unit_of_Time__c = 'Months', SVMXC__Unit_of_Time_Material__c = 'Months', SVMXC__Unit_of_Time_Expenses__c = 'Months');
        insert st1; 
        SVMXC__Service_Template_Products__c stp11 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st1.Id, SVMXC__Product__c = prod1.Id );
        insert stp11;
        SVMXC__Service_Template_Products__c stp12 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st1.Id, SVMXC__Product__c = prod2.Id );
        insert stp12;
        //create service template2 
        SVMXC__Service_Template__c st2 = new SVMXC__Service_Template__c(Name = '12 Months from Ship Date', SVMXC__Template_Type__c = 'Warranty', SVMXC__Coverage_Effective_From__c = 'Ship Date', Duration_of_Time_Coverage__c = 12, SVMXC__Duration_of_Material_Coverage__c = 12, Duration_of_Expenses__c = 12, SVMXC__Unit_of_Time__c = 'Months', SVMXC__Unit_of_Time_Material__c = 'Days', SVMXC__Unit_of_Time_Expenses__c = 'Weeks');
        insert st2;
        SVMXC__Service_Template_Products__c stp21 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st2.Id, SVMXC__Product__c = prod1.Id );
        insert stp21;
        SVMXC__Service_Template_Products__c stp22 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st2.Id, SVMXC__Product__c = prod2.Id );
        insert stp22;
        //create service template3

        SVMXC__Service_Template__c st3 = new SVMXC__Service_Template__c(Name = '6 Months from Entry Date', SVMXC__Template_Type__c = 'Warranty', SVMXC__Coverage_Effective_From__c = 'Entry Date', Duration_of_Time_Coverage__c = 6, SVMXC__Duration_of_Material_Coverage__c = 6, Duration_of_Expenses__c = 6, SVMXC__Unit_of_Time__c = 'Days', SVMXC__Unit_of_Time_Material__c = 'Years', SVMXC__Unit_of_Time_Expenses__c = 'Years');
        insert st3;
        SVMXC__Service_Template_Products__c stp31 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st3.Id, SVMXC__Product__c = prod1.Id );
        insert stp31;
        SVMXC__Service_Template_Products__c stp32 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st3.Id, SVMXC__Product__c = prod2.Id );
        insert stp32;
        //create IB
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(SVMXC__Product__c = prod1.Id, SVMXC__Company__c = acc.Id, SVMXC__Status__c = 'Installed', SVMXC__Serial_Lot_Number__c = 'Test1', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(), SVMXC__Date_Ordered__c = System.today(), SVMXC__Last_Date_Shipped__c = System.today());
        insert IB1;
        ListSobj.add(IB1);
        
        SVMXC__ServiceMax_Processes__c svmxcprocess = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__c='Process',SVMXC__Target_Object_Name__c='Case',SVMXC__Source_Object_Name__c='SVMXC__Installed_Product__c',SVMXC__MapID__c='MAP001002',RecordTypeId = Rtypemap.Id);
        SVMXC__ServiceMax_Processes__c svmxcprocess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__c='Process',SVMXC__Target_Object_Name__c='SVMXC__ServiceMax_List__c',SVMXC__Source_Object_Name__c='SVMXC__Installed_Product__c',SVMXC__MapID__c='MAP001003',RecordTypeId = Rtypemap.Id);
        insert svmxcprocess;
        insert svmxcprocess1;
        SVMXC__ServiceMax_Config_Data__c svmxcconfig = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Target_Field_Name__c='Subject',SVMXC__Source_Field_Name__c='SVMXC__State__c',SVMXC__Active__c = true,SVMXC__MapID__c=svmxcprocess.Id,RecordTypeId = Rtypefieldmap.Id);
        SVMXC__ServiceMax_Config_Data__c svmxcconfig1 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Target_Field_Name__c='Description',SVMXC__Source_Field_Name__c='SVMXC__Installation_Notes__c',SVMXC__Active__c = true,SVMXC__MapID__c=svmxcprocess.Id,RecordTypeId = Rtypefieldmap.Id);
        SVMXC__ServiceMax_Config_Data__c svmxcconfig2 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Target_Field_Name__c='SVMXC__Additional_Information__c',SVMXC__Source_Field_Name__c='SVMXC__Installation_Notes__c',SVMXC__Active__c = true,SVMXC__MapID__c=svmxcprocess1.Id,RecordTypeId = Rtypefieldmap.Id);
        List<SVMXC__ServiceMax_Config_Data__c> conflist= new List<SVMXC__ServiceMax_Config_Data__c>();
        conflist.add(svmxcconfig);
        conflist.add(svmxcconfig1);
        conflist.add(svmxcconfig2);
        insert conflist;
        
        test.starttest();
        system.assertEquals(svmxcprocess.Id,svmxcconfig.SVMXC__MapID__c);
        system.assertEquals(svmxcprocess.Id,svmxcconfig1.SVMXC__MapID__c);
        system.assertEquals(svmxcprocess1.Id,svmxcconfig2.SVMXC__MapID__c);
        SVMXC.COMM_Utils_ObjectMapping Commobjmapping = new SVMXC.COMM_Utils_ObjectMapping();
        SVMXC.COMM_Utils_ObjectMapping.ObjectMappingResult CommobjmappingRes = new SVMXC.COMM_Utils_ObjectMapping.ObjectMappingResult(ListSobj,true,'success');
        system.assert(Commobjmapping.fieldMapSettingRecords==null);
        Commobjmapping.getTargerRecordlist(svmxcprocess.SVMXC__MapID__c,null,ListSobj);
        Commobjmapping.getTargerRecord(svmxcprocess.SVMXC__MapID__c,IB1.Id);
        Commobjmapping.getTargerRecordlist(svmxcprocess1.SVMXC__MapID__c,null,ListSobj);
        Commobjmapping.getTargerRecord(svmxcprocess1.SVMXC__MapID__c,IB1.Id);
        test.stoptest();
    }
}