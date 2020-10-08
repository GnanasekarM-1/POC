trigger SFA_Trigger1 on SFA_Platform_Event__e (after insert) {
    SFA_PlatformTriggerHandler varPlatformEvent = new SFA_PlatformTriggerHandler();
    varPlatformEvent.afterInsertPlatformEvent(trigger.new);
}