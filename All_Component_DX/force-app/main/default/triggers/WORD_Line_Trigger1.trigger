trigger WORD_Line_Trigger1 on SVMXC__Service_Order_Line__c (before insert, before update) {
     //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__Service_Order_Line__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'WORD_Line_Trigger1 execution is skipped.');
        return;
    }
    boolean RunTrigger = false;
    for(SVMXC__Service_Order_Line__c R : Trigger.new){
        if(R.SVMXC__Use_Price_From_Pricebook__c==true && R.SVMXC__Product__c!=NULL){ 
            RunTrigger = true;
        }
    }
    system.debug('WorkLines'+Trigger.new.size()+Trigger.new);
    if(RunTrigger){
        SVMXC.COMM_PriceClass.SVMXC_SetSVOLinePriceLst(Trigger.new); //Prefixed lst in method name to avoid security conflicts as method was overloaded.// Gm Aug11-2011
    } 
}