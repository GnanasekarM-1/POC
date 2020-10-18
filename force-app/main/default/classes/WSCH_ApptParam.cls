/** This class is created to overwrite the request parameters for OfferAppointment call **/

global with sharing class WSCH_ApptParam {
    
    public WSCH_ApptParam(){
        this.startDateTime = null;
        this.endDateTime = null;
        this.costOrDates = null;
        this.numberOfOfferAppts = null;
    }
    
    global DateTime startDateTime;    
    global DateTime endDateTime;
	global String costOrDates;
	global Integer numberOfOfferAppts;
}