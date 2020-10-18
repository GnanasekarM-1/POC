@isTest
private class WORD_ManageTechEligilibilityRules_UT 
{

 
   static testMethod void WORD_ManageTechEligilibilityRulestest() {
    WORD_ManageTechEligilibilityRules objcriteria = new WORD_ManageTechEligilibilityRules();
    WORD_ManageTechEligilibilityRules.ConfigExpWrapper wrapObj = new WORD_ManageTechEligilibilityRules.ConfigExpWrapper();
        wrapObj.getobjConf();
        wrapObj.getlstWOforTechSel();
        wrapObj.getIsRenderpicklist();
       
        RecordType rtype = [select id from RecordType where Name=:'SVMX Rule']; 
        RecordType RC =[select id, Name, SobjectType from RecordType where Name = 'Expressions' and SobjectType ='SVMXC__ServiceMax_Config_Data__c'];
    
        SVMXC__ServiceMax_Processes__c objEligibilityCriteria1 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityCriteria1.RecordTypeId = rtype.Id;
        
        
        objcriteria.strProcessName = 'Eligibility Rule Test';
        objcriteria.strDescription='Description Rule Test';
        objcriteria.isactive = true;
         
       
        objcriteria.newEligibilityCriteria();
        objcriteria.saveEligibilityCriteria();
        objEligibilityCriteria1.SVMXC__Name__c = 'Eligibility Rule Test1';
                objEligibilityCriteria1.SVMXC__Description__c ='Eligibility Rule Test1';
                objEligibilityCriteria1.SVMXC__Select__c = true;
               
                objEligibilityCriteria1.SVMXC__Rule_Type__c = 'Tech Eligibility';
                objEligibilityCriteria1.SVMXC__Source_Object_Name__c='SVMXC__Service_Order__c';
               objEligibilityCriteria1.SVMXC__Sequence__c = 1.0000;
               
                objEligibilityCriteria1.RecordTypeId = objcriteria.ExpHdr_Rtype_Id;
                insert objEligibilityCriteria1;
                
                SVMXC__ServiceMax_Processes__c objEligibilityCriteria2 = new SVMXC__ServiceMax_Processes__c();
                objEligibilityCriteria2.RecordTypeId = rtype.Id;
                objEligibilityCriteria2.SVMXC__Name__c = 'Eligibility Rule Test2';
                objEligibilityCriteria2.SVMXC__Description__c ='Eligibility Rule Test2';
                objEligibilityCriteria2.SVMXC__Select__c = false;
               objEligibilityCriteria2.SVMXC__Sequence__c = 2.0000;
                objEligibilityCriteria2.SVMXC__Rule_Type__c = 'Tech Eligibility';
                objEligibilityCriteria2.SVMXC__Source_Object_Name__c='SVMXC__Service_Order__c';
               
               
                objEligibilityCriteria2.RecordTypeId = objcriteria.ExpHdr_Rtype_Id;
                insert objEligibilityCriteria2;
                objcriteria.lstEligibilityMatchingRules.add(objEligibilityCriteria1);
                objcriteria.lstEligibilityMatchingRules.add(objEligibilityCriteria2);
                objcriteria.editEligibilityCriteria();
                objcriteria.saveEligibilityCriteria();
                objcriteria.editEligibilityCriteria();
                objcriteria.saveEligibilityCriteria();
                
                
        objcriteria.cancelEligibilityCriteria();
        
       
        system.assert(objcriteria.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(objcriteria.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(objcriteria.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(objcriteria.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(objcriteria.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(objcriteria.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(objcriteria.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(objcriteria.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(objcriteria.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(objcriteria.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(objcriteria.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(objcriteria.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(objcriteria.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(objcriteria.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(objcriteria.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(objcriteria.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(objcriteria.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(objcriteria.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(objcriteria.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(objcriteria.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(objcriteria.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(objcriteria.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(objcriteria.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(objcriteria.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(objcriteria.getTAG025()!=null,'TAG025 assertion failed');
        //objcriteria.svmxTagList.clear();
        system.assert(objcriteria.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(objcriteria.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(objcriteria.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(objcriteria.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(objcriteria.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(objcriteria.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(objcriteria.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(objcriteria.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(objcriteria.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(objcriteria.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(objcriteria.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(objcriteria.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(objcriteria.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(objcriteria.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(objcriteria.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(objcriteria.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(objcriteria.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(objcriteria.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(objcriteria.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(objcriteria.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(objcriteria.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(objcriteria.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(objcriteria.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(objcriteria.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(objcriteria.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(objcriteria.getTAG026()!=null,'TAG025 assertion failed');
        system.assert(objcriteria.getTAG027()!=null,'TAG025 assertion failed');
        system.assert(objcriteria.getTAG028()!=null,'TAG025 assertion failed');
        system.assert(objcriteria.getTAG029()!=null,'TAG025 assertion failed');
        system.assert(objcriteria.getTAG030()!=null,'TAG025 assertion failed');
        objcriteria.getTAG031();
        objcriteria.getTAG032();
        objcriteria.getTAG033();
        objcriteria.getTAG034();
        objcriteria.getTAG035();
        objcriteria.getTAG036();
        objcriteria.getTAG037();
        objcriteria.getTAG038();
        objcriteria.getTAG039();
        objcriteria.getTAG040();
        objcriteria.getTAG042();
        objcriteria.getTAG043();
        objcriteria.getTAG044();
        objcriteria.getTAG045();
        objcriteria.getTAG046();
        objcriteria.getTAG047();
        objcriteria.getTAG048();
        objcriteria.getTAG049();
        objcriteria.getTAG050();
        objcriteria.getHLPURL();
        objcriteria.getHLPURL();
        objcriteria.IsValidString('ABCD');
        objcriteria.getobjEligibilityCriteria();        
        objcriteria.getlstEligibilityMatchingRules();       
        objcriteria.getlstWOfield();
        objcriteria.getlstTechfield();
        objcriteria.getlstOperatorSelectLst();       
        objcriteria.getlsteligibilityMatchConfig();
        objcriteria.getlstMatchWOtoTechConfig();
        objcriteria.getlsteligMatchSize();
        objcriteria.getlstMatchWOtoTech();
        //objcriteria.setobjEligibilityCriteria1(new list<SVMXC__ServiceMax_Processes__c>());
        //objcriteria.setlsteligibilityMatchConfig(new list<SVMXC__ServiceMax_Config_Data__c>());
        //objcriteria.setlstMatchWOtoTechConfig(new list<SVMXC__ServiceMax_Config_Data__c>());
        objcriteria.getlstWOforTechSelected();
        objcriteria.getdisplaySeqPopup();
        objcriteria.getisRenderRuleSeq();
        objcriteria.setisRenderRuleSeq(true);
        objcriteria.getLstCriWrap();
        //objcriteria.setLstCriWrap(new List<ConfigExpWrapper>());
        objcriteria.getIntIndex();
        objcriteria.setIntIndex(1);
        objcriteria.getstrselTechField();
        objcriteria.setstrselTechField('ABC');
        objcriteria.getLstCriWrapSize();
        
        objcriteria.newEligibilityCriteria();
        objcriteria.StrSelectedIndex = String.Valueof(1);
        objcriteria.RerenderTextOrPicklist();
        
        SVMXC__ServiceMax_Config_Data__c confobj = new  SVMXC__ServiceMax_Config_Data__c();
                
        confobj.SVMXC__Expression_Type__c = 'Tech_Eligibility';
        confobj.RecordTypeId =RC.id;
        confobj.SVMXC__Expression_Rule__c = objEligibilityCriteria1.id;
        confobj.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confobj.SVMXC__Operator__c = 'eq';
        confobj.SVMXC__Operand__c = 'Bangalore';
        insert confobj;
        objcriteria.lsteligibilityMatchConfig.add(confobj);
        string advep1='';
        objcriteria.submitExp(objEligibilityCriteria1,objcriteria.lsteligibilityMatchConfig,advep1);
        objcriteria.StrDelIndex1 = '1';
        objcriteria.HdrDeleteRow1();
        SVMXC__ServiceMax_Config_Data__c confobj1 = new  SVMXC__ServiceMax_Config_Data__c();
        confobj1.SVMXC__Expression_Type__c = 'Tech_match';
        confobj1.RecordTypeId =RC.id;
        confobj1.SVMXC__Expression_Rule__c = objEligibilityCriteria1.id;
        confobj1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confobj1.SVMXC__Operator__c = 'eq';
        confobj1.Target_Field_Name__c = 'SVMXC__City__c';
        insert confobj1;
        objcriteria.lstMatchWOtoTechConfig.add(confobj1);
        
        objcriteria.editEligibilityCriteria();
        //objcriteria.onchangeTechField();
        objcriteria.items.add(objEligibilityCriteria2.id);
        objcriteria.SVMX_OrderSequence();
        objcriteria.strEligibilityidRearrange.add(objEligibilityCriteria2.id);
        objcriteria.getSeqoptions();
        objcriteria.UP();
        objcriteria.Down();
        objcriteria.Top();
        objcriteria.Bottom();
        objcriteria.shuffle(0,true);
        objcriteria.SVMX_SaveSequence();
        objcriteria.StrDelIndex1 = String.valueof(1);        
        objcriteria.deleteEligibilityCriteria();
        objcriteria.getstrEligibilityidRearrange();
       
        objcriteria.SVMX_GoSetupHome();
        objcriteria.getHLPTITLE();
        objcriteria.getTAG051();
        objcriteria.getTAG052();
        objcriteria.StrDelIndex2 = '1';
        objcriteria.HdrDeleteRow2();
        
    }
    
    
}