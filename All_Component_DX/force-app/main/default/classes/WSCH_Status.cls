/**
@ Name WSCH_Status
@ Author Anantha Kumar
@ Description This object can contain a field for storing the callout exceptions and flags to control the further processing in the SP adaptor..
*/
global class WSCH_Status{
    
    public WSCH_Status(){
        
        this.exceptionObj= null;
        this.apiName =null;
    }

	global Exception exceptionObj{get;set;}
	global String apiName{get;set;}
	
}