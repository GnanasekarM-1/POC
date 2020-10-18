@isTest
private class DCON_MultiCriteriaTechMatch_WS_UT {    
    public DCON_MultiCriteriaTechMatch_WS_UT()
    {
        SVMX_Constants.AllDCSettingList = null;
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('GLOB001_GBL007','GLOB001_GBL014','EVER007_SET001','IPRD003_SET007','IPRD003_SET003', 'EVER007_SET002')];
        
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
        {
            l.SVMXC__Display_Value__c = 'false';
            l.SVMXC__Internal_Value__c = 'false';
            l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        }
        if(lst != null && lst.size() > 0)
        update lst;
    }
    static
    {
        DCON_MultiCriteriaTechMatch_WS_UT obj = new DCON_MultiCriteriaTechMatch_WS_UT();
    }
    static testMethod void DCON_MultiCriteriaTechMatch_WS_UT_Test()
    {
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Work_Order_Resource__c objWOResource;   
        SVMXC__Work_Order_Resource__c objWOResource2;  
        SVMXC__Work_Order_Resource__c objWOResource3;  
        SVMXC__Work_Order_Resource__c objWOResource4;  
        DCON_MultiCriteriaTechMatch_WS.stackRank objstackRank = new DCON_MultiCriteriaTechMatch_WS.stackRank();
        //DCON_MultiCriteriaTechMatch_WS.MCTM_Request objMCTM_Request = new DCON_MultiCriteriaTechMatch_WS.MCTM_Request(null,null,null,null,null,null); //Constructor is deprecated in class so commented here
        DCON_MultiCriteriaTechMatch_WS.MCTMDetails objMCTMDetails = new DCON_MultiCriteriaTechMatch_WS.MCTMDetails(null,null,null,null);
        DCON_MultiCriteriaTechMatch_WS.techAddress objtechAddress = new DCON_MultiCriteriaTechMatch_WS.techAddress(null,null,null,null);
        //SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
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
        SVMXC__Service_Group_Members__c objTechnician3 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 3' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true
                                            );
        SVMXC__Service_Group_Members__c objTechnician4 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 4' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true
                                            );  
        SVMXC__Service_Group_Members__c objTechnician5 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 5' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Hyderabad',
                                            SVMXC__Active__c = true
                                            );                                  
        insert objTechnician2;                 
        insert objTechnician;
        insert objTechnician3;    
        insert objTechnician4;
        insert objTechnician5;      
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
                                            SVMXC__Preferred_Technician__c = objTechnician2.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true
                                            //SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;
        objWOResource = new SVMXC__Work_Order_Resource__c (
                                            SVMXC__Work_Order__c = objWorkOrder.Id ,
                                            SVMXC__Group_Member__c = objTechnician.Id ,
                                            SVMXC__Preference_Type__c   = 'Mandatory'                                       
                                            );
        objWOResource2 = new SVMXC__Work_Order_Resource__c (
                                            SVMXC__Work_Order__c = objWorkOrder.Id ,
                                            SVMXC__Group_Member__c = objTechnician2.Id ,
                                            SVMXC__Preference_Type__c   = 'Preferred'                                       
                                            );
        objWOResource3 = new SVMXC__Work_Order_Resource__c (
                                            SVMXC__Work_Order__c = objWorkOrder.Id ,
                                            SVMXC__Group_Member__c = objTechnician3.Id ,
                                            SVMXC__Preference_Type__c   = 'Prohibited'                                      
                                            );  
        objWOResource4 = new SVMXC__Work_Order_Resource__c (
                                            SVMXC__Work_Order__c = objWorkOrder.Id ,
                                            SVMXC__Group_Member__c = objTechnician4.Id ,
                                            SVMXC__Preference_Type__c   = 'Prohibited'                                      
                                            );                                      
        insert objWOResource;
        insert objWOResource2;
        insert objWOResource3;
        insert objWOResource4;

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
        SVMXC__ServiceMax_Processes__c objEligibilityCriteria1 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityCriteria1.RecordTypeId = rtype.Id;
        objEligibilityCriteria1.SVMXC__Name__c = 'Eligibility Rule Test1';
        objEligibilityCriteria1.SVMXC__Description__c ='Eligibility Rule Test1';
        objEligibilityCriteria1.SVMXC__Select__c = true;

        objEligibilityCriteria1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityCriteria1.SVMXC__Source_Object_Name__c='SVMXC__Service_Order__c';
        objEligibilityCriteria1.SVMXC__Sequence__c = 1.0000;
        //objEligibilityCriteria1.RecordTypeId = objcriteria.ExpHdr_Rtype_Id;
        insert objEligibilityCriteria1;
        SVMXC__ServiceMax_Config_Data__c confobj = new  SVMXC__ServiceMax_Config_Data__c();
                
        confobj.SVMXC__Expression_Type__c = 'Tech_Eligibility';
        confobj.RecordTypeId =RC.id;
        confobj.SVMXC__Expression_Rule__c = objEligibilityCriteria1.id;
        confobj.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confobj.SVMXC__Operator__c = 'eq';
        confobj.SVMXC__Operand__c = 'Bangalore';
        insert confobj;
        SVMXC__ServiceMax_Config_Data__c confobj11 = new  SVMXC__ServiceMax_Config_Data__c();
        confobj11.SVMXC__Expression_Type__c = 'Tech_match';
        confobj11.RecordTypeId =RC.id;
        confobj11.SVMXC__Expression_Rule__c = objEligibilityCriteria1.id;
        confobj11.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confobj11.SVMXC__Operator__c = 'eq';
        confobj11.Target_Field_Name__c = 'SVMXC__City__c';
        insert confobj11;
                
        DCON_MultiCriteriaTechMatch_WS.MCTM_Request obj = new DCON_MultiCriteriaTechMatch_WS.MCTM_Request();
        list<DCON_MultiCriteriaTechMatch_WS.skill> wrpSkillValues = new list<DCON_MultiCriteriaTechMatch_WS.skill>();
        DCON_MultiCriteriaTechMatch_WS.skill skill1 = new DCON_MultiCriteriaTechMatch_WS.skill(Skillobj2.id,'Hardware', true, 3);
        DCON_MultiCriteriaTechMatch_WS.skill skill2 = new DCON_MultiCriteriaTechMatch_WS.skill(Skillobj3.id,'Test Skill', false, 3);
        DCON_MultiCriteriaTechMatch_WS.Eligibility Elig = new DCON_MultiCriteriaTechMatch_WS.Eligibility('SVMXC__City__c','eq', null,'Bangalore');
        list<DCON_MultiCriteriaTechMatch_WS.Eligibility> lstElig = new list<DCON_MultiCriteriaTechMatch_WS.Eligibility>();
         obj.lstEligibility.add(Elig);
         obj.lstSkill.add(skill1);
         //obj.lstSkill.add(new DCON_MultiCriteriaTechMatch_WS.skill(Skillobj2.id,'Hardware', true, 4));
         //list<string>lstTech = new list<string>();
         obj.lstTech.add(objTechnician2.id);
         obj.lstTech.add(objTechnician.id);
         
         obj.lstTech.add(objTechnician3.id);     
         obj.lstTech.add(objTechnician4.id);
         DCON_MultiCriteriaTechMatch_WS.MPXtechnicians mpx1 = new DCON_MultiCriteriaTechMatch_WS.MPXtechnicians(objTechnician.id, 'Mandatory','');
         obj.lstMPXTechnicans.add(mpx1);
         DCON_MultiCriteriaTechMatch_WS.MPXtechnicians mpx2 = new DCON_MultiCriteriaTechMatch_WS.MPXtechnicians(objTechnician2.id, 'Mandatory','');
         obj.lstMPXTechnicans.add(mpx2);
         DCON_MultiCriteriaTechMatch_WS.MPXtechnicians mpx3 = new DCON_MultiCriteriaTechMatch_WS.MPXtechnicians(objTechnician3.id, 'Preferred','');
         obj.lstMPXTechnicans.add(mpx3);
         DCON_MultiCriteriaTechMatch_WS.MPXtechnicians mpx4 = new DCON_MultiCriteriaTechMatch_WS.MPXtechnicians(objTechnician4.id, 'Prohibited','Deleted');
         obj.lstMPXTechnicans.add(mpx4);
            
            
         obj.WOid=objWorkOrder.id;
         //obj.preferredTechId=objTechnician.id;
         obj.isPreferredTechEnabled=true;
         obj.isproductExpertiseEnabled=true;
         obj.isSkillsEnabled=true;
         obj.isEligibilityEnabled=true;
        list<String> lstWOId = new list<String>();
        lstWOId.add(objWorkOrder.id);
        DCON_MultiCriteriaTechMatch_WS.getMCTMDetails(lstWOId);
        //DCON_MultiCriteriaTechMatch_WS.getQualifiedTechList(obj);
         System.debug('++++  '+DCON_MultiCriteriaTechMatch_WS.getMCTMDetails(lstWOId));
        System.debug('++++  '+DCON_MultiCriteriaTechMatch_WS.getQualifiedTechList(obj));
        DCON_MultiCriteriaTechMatch_WS objMCTM = new DCON_MultiCriteriaTechMatch_WS();
        DCON_MultiCriteriaTechMatch_WS.getSkillDetails();
        //RecordType rtype = [select id from RecordType where Name=:'SVMX Rule']; 
        //RecordType RC =[select id, Name, SobjectType from RecordType where Name = 'Expressions' and SobjectType ='SVMXC__ServiceMax_Config_Data__c'];

        DCON_MultiCriteriaTechMatch_WS.getQualifiedTechList(obj);
 //       DCON_MultiCriteriaTechMatch_WS.getMCTMDetails(lstWOId);
        DCON_MultiCriteriaTechMatch_WS.SVMXMap objSVMXMap = new DCON_MultiCriteriaTechMatch_WS.SVMXMap();
        DCON_MultiCriteriaTechMatch_WS.SVMXMap objSVMXMap1 = new DCON_MultiCriteriaTechMatch_WS.SVMXMap(null,null,null);
        obj.getlstTech();
        obj.setlstTech(new list<string>());
        //obj.getlstSkill();
        obj.getlstEligibility();
        obj.setlstEligibility(new list<DCON_MultiCriteriaTechMatch_WS.Eligibility>());
        //obj.setlstSkill(new list<DCON_MultiCriteriaTechMatch_WS.skill>());
        //DCON_MultiCriteriaTechMatch_WS.getQualifiedTechList(obj);
        DCON_MultiCriteriaTechMatch_WS.Skill_Request SkillReq = new DCON_MultiCriteriaTechMatch_WS.Skill_Request();
        SkillReq.lstWorkOrder.add(objWorkOrder);
        SkillReq.lstTech.add(objTechnician.id);
        SkillReq.lstTech.add(objTechnician2.id);
        SVMXC__Service_Group_Skills__c objExpertise = new SVMXC__Service_Group_Skills__c();
        objExpertise.SVMXC__Service_Group__c = objTeam .id;
        objExpertise.SVMXC__Group_Member__c = objTechnician2.id;
        objExpertise.SVMXC__Select__c = true;
        objExpertise.SVMXC__Skill__c = Skillobj3.id;
        objExpertise.SVMXC__Skill_Level__c = 5;
        insert objExpertise;
        SkillReq.lstSkills.add(skill2);
        list<DCON_MultiCriteriaTechMatch_WS.SVMXMap> lstSkillset = new list<DCON_MultiCriteriaTechMatch_WS.SVMXMap>();
        lstSkillset = DCON_MultiCriteriaTechMatch_WS.buildSkillScore_WS(SkillReq);
        system.debug(logginglevel.warn, 'lstSkillset: ' + lstSkillset);
        
        //added following 5 new webservices
        List<Id> workOrderId = new List<Id>();
        workOrderId.add(objWorkOrder.id);
        DCON_MultiCriteriaTechMatch_WS.getSkillsForGivenWOIds(workOrderId);
        
        SVMXC__Service_Order__c objWO = [SELECT SVMXC__Skill_Set__c FROM SVMXC__Service_Order__c WHERE Id = :objWorkOrder.id];
        DCON_MultiCriteriaTechMatch_WS.encodeToSkillObj(objWO.SVMXC__Skill_Set__c);
        
        List<DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill> mapWOidJsonStrOfSkill = new List<DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill>();
        DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill objSVMXMapofIdandSkill = new DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill();
        objSVMXMapofIdandSkill.key = objWorkOrder.id;
        objSVMXMapofIdandSkill.value = 'repair';
        mapWOidJsonStrOfSkill.add(objSVMXMapofIdandSkill);
        objSVMXMapofIdandSkill.key = objWorkOrder.id;
        objSVMXMapofIdandSkill.value = 'technician';
        mapWOidJsonStrOfSkill.add(objSVMXMapofIdandSkill);
        DCON_MultiCriteriaTechMatch_WS.decodeSkillObjMapToJSON(mapWOidJsonStrOfSkill);

        DCON_MultiCriteriaTechMatch_WS.skill skillObject = new DCON_MultiCriteriaTechMatch_WS.skill();
        skillObject.skillId = '1';
        skillObject.skillName = 'Installation';
        skillObject.isSkillMandatory = true;
        skillObject.skillLevel = 1;
        List<DCON_MultiCriteriaTechMatch_WS.skill> skillList = new List<DCON_MultiCriteriaTechMatch_WS.skill>();
        skillList.add(skillObject);
        DCON_MultiCriteriaTechMatch_WS.decodeSkillListToJSON(skillList);

        DCON_MultiCriteriaTechMatch_WS test1 = new DCON_MultiCriteriaTechMatch_WS();
        SVMXC__Skill__c Skillobj = new SVMXC__Skill__c();
        insert Skillobj;
        Id woId = Id.valueOf(objWorkOrder.id);
        DCON_MultiCriteriaTechMatch_WS.skill skill7 = new DCON_MultiCriteriaTechMatch_WS.skill(Skillobj.id,'Hardware', true, 3);
        List<DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill> mapWOidJsonStrOfSkillOne = new List<DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill>();
        DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill objSVMXMapofIdandSkillOne = new DCON_MultiCriteriaTechMatch_WS.SVMXMapofIdandSkill();
        objSVMXMapofIdandSkillOne.key = woId;
        objSVMXMapofIdandSkillOne.skillValue = skill7;
        mapWOidJsonStrOfSkillOne.add(objSVMXMapofIdandSkillOne);
        DCON_MultiCriteriaTechMatch_WS.putSkillsForGivenWOIds(mapWOidJsonStrOfSkillOne);
    } 
}