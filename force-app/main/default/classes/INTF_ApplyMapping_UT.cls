@isTest
private class INTF_ApplyMapping_UT
{
    static testMethod void getApplyMapping_Test()
    { 
        map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>(); 
        map<String,Schema.SObjectType> Allobj = new map<String,Schema.SObjectType>();
        gd = Schema.getGlobalDescribe();
        if(gd.size() > 0)
        {
            for(Schema.SObjectType s : gd.values()) 
            {
                Schema.DescribeSObjectResult result = s.getDescribe();
                Allobj.put(result.getName(),s);
            }
        }
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        System.assertEquals(true, lstRecType != null);
        String TargetManager = '';
        String ObjectMapping = '';
        String Fieldmapping = '';
        String ProcessNodeObj = '';
        for(RecordType r : lstRecType)
        {   
            if(r.Name == 'Target Manager')
                TargetManager = r.id;
            if(r.Name == 'Object Mapping')  
                ObjectMapping = r.id;
            if(r.Name == 'Field Mapping')
                Fieldmapping = r.id;    
            if(r.Name == 'Process Node Objects')    
                ProcessNodeObj = r.id;
        }
                
       //-------------------------------DATA PREPARATION------------------------------------------------------------------//
        SVMXC__ServiceMax_Processes__c ObjectMap = new SVMXC__ServiceMax_Processes__c();
        ObjectMap.SVMXC__Target_Object_Name__c = 'SVMXC__Installed_Product__c';
        ObjectMap.RecordTypeId =lstRecType[0].Id;
        ObjectMap.SVMXC__MapID__c='CUSTOMMAP0001';
        ObjectMap.SVMXC__Name__c = 'CUSTOMMAP0001';
        ObjectMap.RecordTypeId = ObjectMapping;
        insert ObjectMap;
        
        list<SVMXC__ServiceMax_Config_Data__c> FieldMapList = new list<SVMXC__ServiceMax_Config_Data__c>();        
        SVMXC__ServiceMax_Config_Data__c FieldMap = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap.RecordTypeId =Fieldmapping;
        FieldMap.SVMXC__MapID__c = ObjectMap.Id ;
        FieldMap.SVMXC__Source_Field_Name__c ='SVMXC__City__c' ;
        FieldMap.SVMXC__Target_Field_Name__c ='SVMXC__City__c' ;
        FieldMapList.add(FieldMap); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap1 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap1.RecordTypeId =Fieldmapping;
        FieldMap1.SVMXC__MapID__c = ObjectMap.Id ;
        FieldMap1.SVMXC__Source_Field_Name__c ='SVMXC__Contact__c' ;
        FieldMap1.SVMXC__Target_Field_Name__c ='SVMXC__Contact__c' ;
        FieldMapList.add(FieldMap1); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap2 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap2.RecordTypeId =Fieldmapping;
        FieldMap2.SVMXC__MapID__c = ObjectMap.Id ;
        FieldMap2.SVMXC__Source_Field_Name__c ='SVMXC__Date_Shipped__c' ;
        FieldMap2.SVMXC__Target_Field_Name__c ='SVMXC__Date_Shipped__c' ;
        FieldMapList.add(FieldMap2);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap3 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap3.RecordTypeId =Fieldmapping;
        FieldMap3.SVMXC__MapID__c = ObjectMap.Id ;
        FieldMap3.SVMXC__Source_Field_Name__c ='SVMXC__Latitude__c' ;
        FieldMap3.SVMXC__Target_Field_Name__c ='SVMXC__Latitude__c' ;
        FieldMapList.add(FieldMap3);
        
        insert FieldMapList;       
        
        Account acc1 = new Account();
        acc1.Name = 'Maxplore';
        acc1.AccountNumber = 'acc0002';
        acc1.Phone = null;
        acc1.Fax = null ;
        acc1.Website = 'www.maxplore.com';
        acc1.Sic = 'sicnumber001';
        insert acc1;
        
        Contact cont1 = new Contact();
        cont1.Account=acc1;
        cont1.FirstName = 'Ranjeet';
        cont1.LastName = 'Jaiswal';
        insert cont1 ;
        
        Product2 pro= new Product2();
        pro.Family = 'Apple';
        pro.IsActive = true;
        pro.ProductCode = '0001';
        pro.Name = 'Apple';
        insert pro;
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c();
        IB1.Name = 'TopLevel';
        IB1.SVMXC__Product__c = pro.id; 
        IB1.SVMXC__City__c = 'Bangalore';
        IB1.SVMXC__Contact__c = cont1.id;
        IB1.SVMXC__Date_Shipped__c = system.today();
        IB1.SVMXC__Latitude__c = 123;
        insert IB1;
        SVMXC__Installed_Product__c IB2 = new SVMXC__Installed_Product__c();
        IB2.Name = 'Parent';
        IB2.SVMXC__Product__c = pro.id;
        IB2.SVMXC__Parent__c =  IB1.id;
        insert IB2;  
        list<Sobject> SobjList = new list<Sobject>();
        SobjList.add(IB2);
        INTF_applyMapping MappingObj = new INTF_applyMapping();
        MappingObj.getApplyMapping(SobjList, ObjectMap.id, IB1.id, true, Allobj);
        ObjectMap.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        update ObjectMap;
        MappingObj.getApplyMapping(SobjList, ObjectMap.id, IB1.id, false, Allobj);
        
        //For Record Type
        SVMXC__ServiceMax_Processes__c ObjectMap2 = new SVMXC__ServiceMax_Processes__c();
        ObjectMap2.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjectMap2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjectMap2.RecordTypeId =lstRecType[0].Id;
        ObjectMap2.SVMXC__MapID__c='CUSTOMMAP00001';
        ObjectMap2.SVMXC__Name__c = 'CUSTOMMAP00001';
        ObjectMap2.RecordTypeId = ObjectMapping;
        insert ObjectMap2;
        
        SVMXC__ServiceMax_Config_Data__c FieldMap4 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap4.RecordTypeId =Fieldmapping;
        FieldMap4.SVMXC__MapID__c = ObjectMap2.Id ;
        FieldMap4.SVMXC__Display_Value__c ='Estimate' ;
        FieldMap4.SVMXC__Target_Field_Name__c ='RecordTypeId' ;
        FieldMapList.add(FieldMap4); 
        
        upsert FieldMapList;
        
         SVMXC__Service_Order__c workorder = new SVMXC__Service_Order__c(
                                                    SVMXC__Order_Status__c = 'Open',
                                                    SVMXC__Priority__c = 'Medium',
                                                    SVMXC__Order_Type__c = 'Field Service'
                                                    );
        insert workorder;
        SVMXC__Service_Order_Line__c wd = new SVMXC__Service_Order_Line__c();
        wd.SVMXC__Service_Order__c = workorder.id;
        wd.SVMXC__Line_Type__c = 'Parts';
        wd.SVMXC__Use_Price_From_Pricebook__c = true;
        wd.SVMXC__Actual_Price2__c = 100;
        wd.SVMXC__Actual_Quantity2__c = 100;
        wd.SVMXC__Date_Received__c = system.today();
        wd.SVMXC__Discount__c = 10;
        wd.SVMXC__Received_City__c = 'Bangalore';
        insert wd;
        SVMXC__Service_Order_Line__c wd1 = new SVMXC__Service_Order_Line__c();
        list<Sobject> SobjList1 = new list<Sobject>();
        SobjList1.add(wd1);
        MappingObj.getApplyMapping(SobjList1, ObjectMap2.id, wd.id, false, Allobj);
        
        //For Value mapping
        //For Record Type
        SVMXC__ServiceMax_Processes__c ObjectMap3 = new SVMXC__ServiceMax_Processes__c();
        ObjectMap3.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjectMap3.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjectMap3.RecordTypeId =lstRecType[0].Id;
        ObjectMap3.SVMXC__MapID__c='CUSTOMMAP00001';
        ObjectMap3.SVMXC__Name__c = 'CUSTOMMAP00001';
        ObjectMap3.RecordTypeId = ObjectMapping;
        insert ObjectMap3;
        
        SVMXC__ServiceMax_Config_Data__c FieldMap5 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap5.RecordTypeId =Fieldmapping;
        FieldMap5.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap5.SVMXC__Display_Value__c ='Estimate' ;
        FieldMap5.SVMXC__Target_Field_Name__c ='RecordTypeId' ;
        FieldMapList.add(FieldMap5); 
        
        
        SVMXC__ServiceMax_Config_Data__c FieldMap6 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap6.RecordTypeId =Fieldmapping;
        FieldMap6.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap6.SVMXC__Display_Value__c ='parts' ;
        FieldMap6.SVMXC__Target_Field_Name__c ='SVMXC__Line_Type__c' ;
        FieldMapList.add(FieldMap6); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap7 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap7.RecordTypeId =Fieldmapping;
        FieldMap7.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap7.SVMXC__Display_Value__c ='true' ;
        FieldMap7.SVMXC__Target_Field_Name__c ='SVMXC__Use_Price_From_Pricebook__c' ;
        FieldMapList.add(FieldMap7); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap8 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap8.RecordTypeId =Fieldmapping;
        FieldMap8.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap8.SVMXC__Display_Value__c ='100' ;
        FieldMap8.SVMXC__Target_Field_Name__c ='SVMXC__Actual_Price2__c' ;
        FieldMapList.add(FieldMap8);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap9 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap9.RecordTypeId =Fieldmapping;
        FieldMap9.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap9.SVMXC__Display_Value__c ='100' ;
        FieldMap9.SVMXC__Target_Field_Name__c ='SVMXC__Actual_Quantity2__c' ;
        FieldMapList.add(FieldMap9); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap10 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap10.RecordTypeId =Fieldmapping;
        FieldMap10.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap10.SVMXC__Display_Value__c ='Today' ;
        FieldMap10.SVMXC__Target_Field_Name__c ='SVMXC__Date_Received__c' ;
        FieldMapList.add(FieldMap10); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap11 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap11.RecordTypeId =Fieldmapping;
        FieldMap11.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap11.SVMXC__Display_Value__c ='10' ;
        FieldMap11.SVMXC__Target_Field_Name__c ='SVMXC__Discount__c' ;
        FieldMapList.add(FieldMap11);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap12 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap12.RecordTypeId =Fieldmapping;
        FieldMap12.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap12.SVMXC__Display_Value__c ='Bangalore' ;
        FieldMap12.SVMXC__Target_Field_Name__c ='SVMXC__Received_City__c' ; 
        FieldMapList.add(FieldMap12);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap13 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap13.RecordTypeId =Fieldmapping;
        FieldMap13.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap13.SVMXC__Display_Value__c ='Today' ;
        FieldMap13.SVMXC__Target_Field_Name__c ='SVMXC__Start_Date_and_Time__c';
        FieldMapList.add(FieldMap13); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap14 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap14.RecordTypeId =Fieldmapping;
        FieldMap14.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap14.SVMXC__Display_Value__c ='Tomorrow' ;
        FieldMap14.SVMXC__Target_Field_Name__c ='SVMXC__Canceled_On__c';
        FieldMapList.add(FieldMap14);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap15 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap15.RecordTypeId =Fieldmapping;
        FieldMap15.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap15.SVMXC__Display_Value__c ='Yesterday' ;
        FieldMap15.SVMXC__Target_Field_Name__c ='SVMXC__Closed_On__c';
        FieldMapList.add(FieldMap15);
        
        SVMXC__ServiceMax_Config_Data__c FieldMap16 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap16.RecordTypeId =Fieldmapping;
        FieldMap16.SVMXC__MapID__c = ObjectMap3.Id ;
        FieldMap16.SVMXC__Display_Value__c ='Yesterday' ;
        FieldMap16.SVMXC__Target_Field_Name__c ='SVMXC__Date_Requested__c';
        FieldMapList.add(FieldMap16);
        
        upsert FieldMapList; 
        map<String,Sobject> SourceRecIdTargetObjMap = new map<String,Sobject>();
        SourceRecIdTargetObjMap.put(wd.id,wd);
        MappingObj.getValueMapping(SobjList1, ObjectMap3.id, Allobj);
        MappingObj.getApplyMapping1(ObjectMap2.id,SourceRecIdTargetObjMap,false,Allobj);
        MappingObj.getValueMappingAsKeyValue(SobjList1, ObjectMap3.Id, Allobj);
        
        
    }
}