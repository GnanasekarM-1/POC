@isTest(SeeAllData=true)
public with sharing class CONF_ManageDeliveryRules_UT 
{
    static testMethod void CONF_SetupDeliveryRule_Test() 
    {
       CONF_ManageDeliveryRules objDeliveryRules = new CONF_ManageDeliveryRules();
       objDeliveryRules.backToSetupHome();
       objDeliveryRules.getOperatorSelectLst();
       objDeliveryRules.getslctLstSelect_Hub();
       objDeliveryRules.getslctLstDelLocs();
       objDeliveryRules.getslctLstDeliveryRuleFldNames();
       objDeliveryRules.getDisplayRuleInfo();
       objDeliveryRules.getDisplayRuleLineInfo();
       objDeliveryRules.deliveryRuleSelIndex = 1;
       CONF_ManageDeliveryRules.ObjExpressionWrapper objWrap = new CONF_ManageDeliveryRules.ObjExpressionWrapper();
       objWrap.getExpressionRec();
       objWrap.setExpressionRec(new SVMXC__ServiceMax_Config_Data__c ());
       objWrap.getObjectFields();
       objWrap.setObjectFields(new List<SelectOption>());
       objWrap.ExpressionRec = new SVMXC__ServiceMax_Config_Data__c();
       objWrap.ExpressionRec.SVMXC__Sequence__c = 1;
       objWrap.ExpressionRec.SVMXC__Object_Name2__c = 'Account';
       objDeliveryRules.DeliveryRuleAddLine();
       objDeliveryRules.DeliveryRuleDelLine();
     
        //objDeliveryRules.getTag145();
        //objDeliveryRules.getTag146();
        objDeliveryRules.getTag147();
        objDeliveryRules.getTag148();
        objDeliveryRules.getTag149();
        objDeliveryRules.getTAG001();
        objDeliveryRules.getTAG002();
        objDeliveryRules.getTAG003();
        objDeliveryRules.getTag171();
        objDeliveryRules.getIsdisableValue();
        objDeliveryRules.getTag171();
        
       RecordType RTDeliveryRule = [select Id from RecordType where Name='Delivery Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
       RecordType RTSVMXRule = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
       RecordType RTDepot = [select id, Name from RecordType where Name = 'Depot'and SobjectType='SVMXC__Site__c' Limit 1];
       RecordType RTDepotChild = [select id, Name from RecordType where Name = 'Depot Child'and SobjectType='SVMXC__Site__c' Limit 1];
       
        
       SVMXC__Site__c objLoc = new SVMXC__Site__c();
       objLoc.Name = 'Test Loc';
       objLoc.RecordTypeId = RTDepot.Id;
       insert objLoc;
       
       SVMXC__Site__c objLocChild = new SVMXC__Site__c();
       objLocChild.RecordTypeId = RTDepotChild.Id;
       objLocChild.SVMXC__Parent__c = objLoc.Id;
       objLocChild.SVMXC__IsDelivery_Location__c = true;
       insert objLocChild;
       
       SVMXC__ServiceMax_Processes__c objDeliveryRule = new SVMXC__ServiceMax_Processes__c();
       objDeliveryRule.RecordTypeId = RTDeliveryRule.Id;        
       objDeliveryRule.SVMXC__Name__c = 'TEST000000001';
       objDeliveryRule.SVMXC__ProcessId__c = 'TEST00000000001';
       objDeliveryRule.SVMXC__Select__c = true;
       objDeliveryRule.SVMXC__Location__c = objLoc.id;
       insert objDeliveryRule;
       
       objDeliveryRules.populateRuleANDHubsOnEdit();
       
       SVMXC__ServiceMax_Processes__c deliveryRuleLine = new SVMXC__ServiceMax_Processes__c ();
       deliveryRuleLine.RecordTypeId = RTSVMXRule.Id;
       deliveryRuleLine.SVMXC__Name__c = 'TEST000000002';
       deliveryRuleLine.SVMXC__ProcessId__c = 'TEST00000000002';
       deliveryRuleLine.SVMXC__Select__c = true;
       deliveryRuleLine.SVMXC__Rule_Type__c = 'Delivery Rule Line';
       deliveryRuleLine.SVMXC__Module__c = objDeliveryRule.Id;
       insert deliveryRuleLine;
          
       SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
       confData.SVMXC__Expression_Rule__c = deliveryRuleLine.Id;
       confData.SVMXC__Sequence__c = 1;
       confData.SVMXC__Object_Name2__c = 'SVMXC__Service_Oredr__c';
       insert confData;
       
       objDeliveryRules.populateRuleANDHubsOnEdit();   
       objDeliveryRules.DeliveryRuleLineRecsLst.add(deliveryRuleLine);
       objDeliveryRules.populateDeliveryLocations();
       objDeliveryRules.editRuleLine();
       objDeliveryRules.onchangeObjectName();       
          
       SVMXC__ServiceMax_Processes__c objDeliveryRuleLine = new SVMXC__ServiceMax_Processes__c();
       objDeliveryRuleLine.RecordTypeId = RTDeliveryRule.Id;        
       objDeliveryRuleLine.SVMXC__Name__c = 'TEST000000003';
       objDeliveryRuleLine.SVMXC__ProcessId__c = 'TEST00000000003';
       objDeliveryRuleLine.SVMXC__Select__c = false;
       objDeliveryRuleLine.SVMXC__Location__c = objLoc.id;
       insert objDeliveryRuleLine;
       objDeliveryRules.DeliveryRuleRec = objDeliveryRuleLine;
       objDeliveryRules.deliveryRuleLineRec = objDeliveryRuleLine;
       objDeliveryRules.SaveDeliveryRule();
       objDeliveryRules.populateDefLocs();
       
       objDeliveryRules.CreateNewDeliveryRule();
       objDeliveryRules.DeleteDeliveryRule();
       objDeliveryRules.Cancel_DeliveryRule();
       objDeliveryRules.getAccProdSelectLst();
       List<SVMXC__ServiceMax_Processes__c> val = objDeliveryRules.getDeliveryRulesLst();
       objDeliveryRules.setDeliveryRulesLst(val);
       objDeliveryRules.getDeliveryRuleLineRecsLst();
       
       objDeliveryRules.getTag067();objDeliveryRules.getTag070();objDeliveryRules.getTag087();objDeliveryRules.getTag089();
       objDeliveryRules.getTag092();objDeliveryRules.getTag055();objDeliveryRules.getTag027();objDeliveryRules.getTag124();
       objDeliveryRules.getTag028();objDeliveryRules.getTag093();objDeliveryRules.getTag094();objDeliveryRules.getTag057();
       objDeliveryRules.getTag058();objDeliveryRules.getTag059();objDeliveryRules.getTag062();objDeliveryRules.getTag063();
       objDeliveryRules.getTag066();objDeliveryRules.getTag125();objDeliveryRules.getTag072();objDeliveryRules.getTag031();
       objDeliveryRules.getTag032();objDeliveryRules.getTag033();objDeliveryRules.getTag034();objDeliveryRules.getTag131();
       objDeliveryRules.getTag132();objDeliveryRules.getTag133();objDeliveryRules.getTag134();objDeliveryRules.getTag135();
       objDeliveryRules.getTag136();objDeliveryRules.getTag137();objDeliveryRules.getTag138();objDeliveryRules.getTag139();
       objDeliveryRules.getTag140();objDeliveryRules.getTag141();objDeliveryRules.getTag142();objDeliveryRules.getTag143();
       objDeliveryRules.getTag144();objDeliveryRules.getTag004();objDeliveryRules.getTag005();objDeliveryRules.getTag007();
       objDeliveryRules.getTag006();objDeliveryRules.getTag008();objDeliveryRules.getTag009();objDeliveryRules.getTag011();
       objDeliveryRules.getTag012();
       objDeliveryRules.getTag013();
       objDeliveryRules.getTag014();
       objDeliveryRules.getTag015();
       objDeliveryRules.Cancel_DeliveryRuleLine();
       objDeliveryRules.DeliveryRuleCriteriaDelLines();
       
        
       System.currentPageReference().getParameters().put('SVMX_RecordId', objLoc.Id);
       System.currentPageReference().getParameters().put('SVMX_RetURL', 'CONF_SetupLocations');
       CONF_ManageDeliveryRules objDeliveryRules2 = new CONF_ManageDeliveryRules();
       objDeliveryRules2.backToSetupHome();
       
       System.currentPageReference().getParameters().put('SVMX_RecordId', null);
       System.currentPageReference().getParameters().put('SVMX_RetURL', 'CONF_SetupLocations');
       CONF_ManageDeliveryRules objDeliveryRules3 = new CONF_ManageDeliveryRules();
    }
    
    
}