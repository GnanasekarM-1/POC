trigger WORD_Trigger1 on SVMXC__Service_Order__c (before insert, before update, after insert, after update, before delete, after delete){

    //------Start--------Added for the defect 044689 fix
    /*static final string TRIGGER_SETTING_NAME = 'PELE565';
    static final string TRIGGER_NAME = 'SVMXC_WORD_Trigger1';
    
    if(!SVMXC.CONF_TriggerSettingImpl.isTriggerEnabled(TRIGGER_NAME,TRIGGER_SETTING_NAME)){
        System.debug(Logginglevel.WARN,'WORD_Trigger1 execution is skipped.');
        return;
    }*/
    //------End----------Added for the defect 044689 fix
    
    //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__Service_Order__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'WORD_Trigger1 execution is skipped.');
        return;
    }
    
    if(WSCH_OptimizedSchedulingService.triggerExecuted && Trigger.isUpdate) {
        System.debug('End of WORD_Trigger1::WSCH_OptimizedSchedulingService.triggerExecuted :No of Queries used in this trigger code so far: ' + Limits.getQueries());
        WSCH_OptimizedSchedulingService.triggerExecuted = false;
        return;
    }

    WORD_TriggerHandler handlerClass = new WORD_TriggerHandler();

    
    if(trigger.isBefore){
        
        if(trigger.isInsert){
            handlerClass.onBeforeInsert();
        }

        if(trigger.isUpdate){
                handlerClass.onBeforeUpdate();
        }
    }

    if(trigger.isAfter){
        
        if(trigger.isInsert){
            handlerClass.onAfterInsert();
        }

        if(trigger.isUpdate){
            handlerClass.onAfterUpdate();
        }   

        if(trigger.isDelete){
            handlerClass.onAfterDelete();
        }     
    }
}