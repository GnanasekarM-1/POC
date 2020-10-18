trigger PORD_Line_Trigger1 on SVMXC__RMA_Shipment_Line__c (before insert, before update) 
{
    //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__RMA_Shipment_Line__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'PORD_Line_Trigger1 execution is skipped.');
        return;
    }
    boolean RunTrigger = false;
    for(SVMXC__RMA_Shipment_Line__c R : Trigger.new)
    {
        if(R.SVMXC__Use_Price_From_Pricebook__c==true)
        {
            RunTrigger = true;
        } 
    }
    if(RunTrigger)
    {
        SVMXC.COMM_PriceClass.SVMXC_SetRMA_ShipmentLinePriceLst(Trigger.new);
    }
}