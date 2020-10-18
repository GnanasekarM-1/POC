/**
@ Name WSCH_ICalloutHook
@ Author Anantha Kumar
@ Description common interface for different hook implementation.
*/
global interface WSCH_ICalloutHook {
    void configure();
    void beforeCall(WSCH_IRequest request, List<Sobject> sObjects,WSCH_Status status);
    void afterCall(WSCH_IResponse response, List<Sobject> sObjects,WSCH_Status status);
}