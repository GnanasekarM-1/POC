@isTest
private class WSCH_Utils_API_UT
    {
        public WSCH_Utils_API_UT()
        { }
        static
         {
            WSCH_Utils_API_UT obj = new WSCH_Utils_API_UT();
         }
        
           
        static testMethod void WSCH_Utils_API_UT_Test()
        {
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        List<SVMXC__Service_Group_Members__c> lstObjTech; 
        Account objAccount = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        ); 
        insert objAccount;

        system.assert(objAccount!=null, true);

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;

        system.assert(objContact!=null, true);

        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        insert objCase; 

        system.assertEquals(objCase.ContactId, objContact.Id);
        system.assertEquals(objCase.AccountId, objAccount.Id);
                       
        objTeam = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 1'
                                            );
        insert objTeam;

        objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;

        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true
                                            );
                                            
        system.assertEquals(objTechnician.SVMXC__Service_Group__c, objTeam.Id);
        system.assertEquals(objTechnician.SVMXC__Service_Territory__c, objTerritory.Id);
                       
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 2' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Active__c = true
                                            );
        insert objTechnician2;                 
        insert objTechnician;
        //Create Products..
        Product2 p1 = new Product2();
        p1.Name = 'Product1';
        p1.SVMXC__Enable_Serialized_Tracking__c = true;
        p1.SVMXC__Stockable__c = true;
        p1.Family = 'Laptop';

        insert p1;
        objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = objCase.Id ,
                                            SVMXC__Company__c = objAccount.Id , 
                                            SVMXC__Product__c = p1.Id , 
                                            //SVMXC__Preferred_Technician__c = objTechnician2.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
           insert objWorkOrder;
           RecordType rtype = [select id from RecordType where Name=:'SVMX Rule']; 
        RecordType RC = [select id, Name, SobjectType from RecordType where Name = 'Expressions' and SobjectType ='SVMXC__ServiceMax_Config_Data__c'];
        SVMXC__ServiceMax_Processes__c objSkillrule1 = new SVMXC__ServiceMax_Processes__c();
        objSkillrule1.RecordTypeId = rtype.Id;
        objSkillrule1.SVMXC__Name__c = 'Skill Rule Test1';
        objSkillrule1.SVMXC__Description__c = 'Skill Rule Test1';
        objSkillrule1.SVMXC__Select__c = true;               
        //objSkillrule1.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillrule1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillrule1.SVMXC__Sequence__c = 0.0000;
        objSkillrule1.SVMXC__Rule_Type__c = 'Skill Matching';
        //objSkillrule1.RecordTypeId = objrule.ExpHdr_Rtype_Id;
        insert objSkillrule1;
        SVMXC__ServiceMax_Config_Data__c confobj1 = new  SVMXC__ServiceMax_Config_Data__c();
        confobj1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        confobj1.RecordTypeId = RC.id;
        confobj1.SVMXC__Expression_Rule__c = objSkillrule1.id;
        confobj1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confobj1.SVMXC__Operator__c = 'eq';
        confobj1.SVMXC__Operand__c = 'SVMXC__City__c';
        insert confobj1; 
        SVMXC__Skill__c Skillobj2 = new SVMXC__Skill__c();
        Skillobj2.Name = 'HardWare';
        Skillobj2.SVMXC__Skill_Category__c = 'Installation';
        //Skillobj2.SVMXC__Skill__Tag = 'Electric';
        SVMXC__Skill__c Skillobj3 = new SVMXC__Skill__c();
        Skillobj3.Name = 'Test Skill';
        Skillobj3.SVMXC__Skill_Category__c = 'Installation';
        insert Skillobj2; 
        insert Skillobj3; 
        SVMXC__ServiceMax_Config_Data__c confobj2 = new  SVMXC__ServiceMax_Config_Data__c();
        confobj1.SVMXC__Skill__c = Skillobj2.id;
        //confobj1.RecordTypeId = objrule.ExpDtl_AppSkill_Id;
        confobj1.SVMXC__Expression_Rule__c = objSkillrule1.id;        
        insert confobj2;   
        WSCH_Utils_API.skill skill1 = new WSCH_Utils_API.skill(Skillobj2.id,'Hardware', true, 3);
        WSCH_Utils_API.skill skill2 = new WSCH_Utils_API.skill(Skillobj3.id,'Test Skill', false, 3);
        List<WSCH_Utils_API.skill> lstSkills = new List<WSCH_Utils_API.skill>();
        WSCH_Utils_API.WorkOrderSkill workOrderSkill1 = new WSCH_Utils_API.WorkOrderSkill(objWorkOrder.Id,lstSkills);       
           List<Id> lstWorkOrderId = new List<Id>();
           lstWorkOrderId.add(objWorkOrder.Id);
           List<WSCH_Utils_API.WorkOrderSkill> lstWoSkills = WSCH_Utils_API.getWorkOrderSkills(lstWorkOrderId);
           System.debug('workorder skills:' + lstWoSkills);
           WSCH_Utils_API.setWorkOrderSkills(lstWoSkills, true);
        }
        static testMethod void WSCH_Utils_API_UT_Test1()
        {
           SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        List<SVMXC__Service_Group_Members__c> lstObjTech; 
        Account objAccount = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        ); 
        insert objAccount;

        system.assert(objAccount!=null, true);

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;

        system.assert(objContact!=null, true);

        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        insert objCase; 

        system.assertEquals(objCase.ContactId, objContact.Id);
        system.assertEquals(objCase.AccountId, objAccount.Id);
                       
        objTeam = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 1'
                                            );
        insert objTeam;

        objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;

        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true
                                            );
                                            
        system.assertEquals(objTechnician.SVMXC__Service_Group__c, objTeam.Id);
        system.assertEquals(objTechnician.SVMXC__Service_Territory__c, objTerritory.Id);
                       
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 2' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Active__c = true
                                            );
        insert objTechnician2;                 
        insert objTechnician;
        //Create Products..
        Product2 p1 = new Product2();
        p1.Name = 'Product1';
        p1.SVMXC__Enable_Serialized_Tracking__c = true;
        p1.SVMXC__Stockable__c = true;
        p1.Family = 'Laptop';

        insert p1;
        objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = objCase.Id ,
                                            SVMXC__Company__c = objAccount.Id , 
                                            SVMXC__Product__c = p1.Id , 
                                            //SVMXC__Preferred_Technician__c = objTechnician2.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;
           RecordType rtype = [select id from RecordType where Name=:'SVMX Rule']; 
        RecordType RC = [select id, Name, SobjectType from RecordType where Name = 'Expressions' and SobjectType ='SVMXC__ServiceMax_Config_Data__c'];
        SVMXC__ServiceMax_Processes__c objSkillrule1 = new SVMXC__ServiceMax_Processes__c();
        objSkillrule1.RecordTypeId = rtype.Id;
        objSkillrule1.SVMXC__Name__c = 'Skill Rule Test1';
        objSkillrule1.SVMXC__Description__c = 'Skill Rule Test1';
        objSkillrule1.SVMXC__Select__c = true;               
        //objSkillrule1.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillrule1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillrule1.SVMXC__Sequence__c = 0.0000;
        objSkillrule1.SVMXC__Rule_Type__c = 'Skill Matching';
        //objSkillrule1.RecordTypeId = objrule.ExpHdr_Rtype_Id;
        insert objSkillrule1;
        SVMXC__ServiceMax_Config_Data__c confobj1 = new  SVMXC__ServiceMax_Config_Data__c();
        confobj1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        confobj1.RecordTypeId = RC.id;
        confobj1.SVMXC__Expression_Rule__c = objSkillrule1.id;
        confobj1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confobj1.SVMXC__Operator__c = 'eq';
        confobj1.SVMXC__Operand__c = 'SVMXC__City__c';
        insert confobj1; 
        SVMXC__Skill__c Skillobj2 = new SVMXC__Skill__c();
        Skillobj2.Name = 'HardWare';
        Skillobj2.SVMXC__Skill_Category__c = 'Installation';
        //Skillobj2.SVMXC__Skill__Tag = 'Electric';
        SVMXC__Skill__c Skillobj3 = new SVMXC__Skill__c();
        Skillobj3.Name = 'Test Skill';
        Skillobj3.SVMXC__Skill_Category__c = 'Installation';
        insert Skillobj2; 
        insert Skillobj3; 
        SVMXC__ServiceMax_Config_Data__c confobj2 = new  SVMXC__ServiceMax_Config_Data__c();
        confobj1.SVMXC__Skill__c = Skillobj2.id;
        //confobj1.RecordTypeId = objrule.ExpDtl_AppSkill_Id;
        confobj1.SVMXC__Expression_Rule__c = objSkillrule1.id;        
        insert confobj2;   
        WSCH_Utils_API.skill skill1 = new WSCH_Utils_API.skill(Skillobj2.id,'Hardware', true, 3);
        WSCH_Utils_API.skill skill2 = new WSCH_Utils_API.skill(Skillobj3.id,'Test Skill', false, 3);        
        List<WSCH_Utils_API.skill> lstSkills = new List<WSCH_Utils_API.skill>();
        WSCH_Utils_API.WorkOrderSkill workOrderSkill1 = new WSCH_Utils_API.WorkOrderSkill(objWorkOrder.Id,lstSkills);
           List<Id> lstWorkOrderId = new List<Id>();
           lstWorkOrderId.add(objWorkOrder.Id);
           List<WSCH_Utils_API.WorkOrderSkill> lstWoSkills = WSCH_Utils_API.getWorkOrderSkills(lstWorkOrderId);
           System.debug('workorder skills:' + lstWoSkills);
           WSCH_Utils_API.setWorkOrderSkills(lstWoSkills, false);
           
        //changes for DNS-572 start
        SVMXC__Service_Group__c objTeam_1 = new SVMXC__Service_Group__c (Name = 'TEAM 2');
        insert objTeam_1;

        List<SVMXC__Service_Group__c> listServiceTeamId = new List<SVMXC__Service_Group__c>();
        listServiceTeamId.add(objTeam);
        listServiceTeamId.add(objTeam_1);
        WSCH_Utils_API wschUtilsAPI = new WSCH_Utils_API();
        wschUtilsAPI.updateTechHomelatlog(listServiceTeamId);
        wschUtilsAPI.updateTechHomelatlog();
        //changes for DNS-572 ends
    } 
}