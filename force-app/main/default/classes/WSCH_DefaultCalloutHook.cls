/**
@ Name WSCH_DefaultCalloutHook
@ Author Anantha Kumar
@ Description Default Hook Factory nothing override or implemented in this class.
*/
public class WSCH_DefaultCalloutHook implements WSCH_ICalloutHook {

    public void configure(){
    }
    
    public void beforeCall(WSCH_IRequest request, List<SObject> sObjects,WSCH_Status status) {
    }
    
    public void afterCall(WSCH_IResponse response, List<SObject> sObjects,WSCH_Status status) {
    }
}