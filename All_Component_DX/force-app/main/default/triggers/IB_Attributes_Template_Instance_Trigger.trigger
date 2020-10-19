trigger IB_Attributes_Template_Instance_Trigger on SVMXC__SM_IB_Attributes_Template_Instance__c (after  insert, after update) {
    List<Id> intanceIds = new List<Id>();
           intanceIds.addAll(trigger.newmap.keyset());
        TechnicalAttributeUtils.updateIbTechnicalAttributeObject(intanceIds, trigger.isUpdate); 
     
}