/**
@ Name WSCH_Provider_SP_HookFactory
@ Author Anantha Kumar
@ Description This factory return default callout hook, nothing override or implemented in this class.
*/
global virtual class WSCH_Provider_SP_HookFactory {
	/**
	@ Description Hook implementation for BookJob API
	*/
    global virtual WSCH_ICalloutHook getBookJobHook(){
        return new WSCH_DefaultCalloutHook();
        //this is added for BookJob with forcefix
        //return new WSCH_BookJobCalloutHook();
    }
    
	/**
	@ Description Hook implementation for OfferAppts API
	*/
    global virtual WSCH_ICalloutHook getAppointmentsHook(){
        return new WSCH_DefaultCalloutHook();
    }

	/**
	@ Description Hook implementation for BookAppt API
	*/
    global virtual WSCH_ICalloutHook getBookAppointmentHook(){
        return new WSCH_DefaultCalloutHook();
    }
    
	/**
	@ Description Hook implementation for ChangeWorkItemStatus API
	*/
    global virtual WSCH_ICalloutHook getChangeWorkItemStatusHook(){
        return new WSCH_DefaultCalloutHook();
    }

	/**
	@ Description Hook implementation for GetJobStatus API
	*/
    global virtual WSCH_ICalloutHook getJobStatusHook(){
        return new WSCH_DefaultCalloutHook();
    }
    
	/**
	@ Description Hook implementation for EmpAddAct API
	*/
    global virtual WSCH_ICalloutHook getStdActivityCreateHook(){
        return new WSCH_DefaultCalloutHook();
    }

	/**
	@ Description Hook implementation for ActUpdate API
	*/
    global virtual WSCH_ICalloutHook getStdActivityUpdateHook(){
        return new WSCH_DefaultCalloutHook();
    }
    
	/**
	@ Description Hook implementation for ActDelete API
	*/
    global virtual WSCH_ICalloutHook getStdActivityDeleteHook(){
        return new WSCH_DefaultCalloutHook();
    }        

	/**
	@ Description Hook implementation for UpdateJob API
	*/
    global virtual WSCH_ICalloutHook getUpdateJobHook(){
        return new WSCH_DefaultCalloutHook();
    }        

	/**
	@ Description Hook implementation for CancelJob API
	*/
    global virtual WSCH_ICalloutHook getCancelJobHook(){
        return new WSCH_DefaultCalloutHook();
    }        

	/**
	@ Description Hook implementation for ForceFixJob API
	*/
    global virtual WSCH_ICalloutHook getForceFixJobHook(){
        return new WSCH_DefaultCalloutHook();
    }
    
    /**
	@ Description Hook implementation for BookDependencyGroup API
	*/
	
     global virtual WSCH_ICalloutHook getBookDependencyGroup(){
        return new WSCH_DefaultCalloutHook();
    }
            
}