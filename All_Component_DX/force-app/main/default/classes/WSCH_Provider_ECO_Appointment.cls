global with sharing class WSCH_Provider_ECO_Appointment  {
    
    public String getUserInfo(){
        return JSON.serialize( new SVMXC.SFMDeliveryServiceImpl().getUserInfoInternal() );
    }
    
    @RemoteAction
    global static Object getWOAppointmentSettings (String requestStr) {
        System.debug(logginglevel.Info, 'getWOAppointmentSettings() - Request String : ' + requestStr);
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = (WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request) JSON.deserialize (requestStr, WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request.Class);       
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response response = new WSCH_Provider_ECO_Appointment_Impl().getWOAppointmentSettings (request);
        System.debug(logginglevel.Info, 'getWOAppointmentSettings () - Response : ' + response);
        return JSON.serialize(response);
    }
    //This method is not in use.
    @RemoteAction
    global static Object initiateOptimaxJob(String requestStr) {
        /*System.debug(logginglevel.Info, 'initiateOptimaxJob() - Request String : ' + requestStr);
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = (WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request) JSON.deserialize (requestStr, WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request.Class);
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response response = new WSCH_Provider_ECO_Appointment_Impl().initiateOptimaxJob(request);
        System.debug(logginglevel.Info, 'initiateOptimaxJob() - Response : ' + response);
        return JSON.serialize(response);*/
        return null;
    }
    
    @RemoteAction
    global static Object getWorkOrderDetails (String requestStr) {
        System.debug(logginglevel.Info, 'getWorkOrderDetails() - Request String : ' + requestStr);
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = (WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request) JSON.deserialize (requestStr, WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request.Class);
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response response = new WSCH_Provider_ECO_Appointment_Impl().getWorkOrderDetails(request);
        System.debug(logginglevel.Info, 'getWorkOrderDetails() - Response : ' + response);
        return JSON.serialize(response);
    }
    
    @RemoteAction
    global static Object bookAppointment(String requestStr){
        System.debug(logginglevel.info, 'bookAppointment() - request : ' + requestStr);
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = (WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request) JSON.deserialize (requestStr, WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request.Class);
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response response = new WSCH_Provider_ECO_Appointment_Impl().bookAppointment(request);
        System.debug(logginglevel.info, 'bookAppointment() - response : ' + response);
        return JSON.serialize(response);        
    }
    //This method is not in use.
    @RemoteAction
    global static Object startOptimaxJob(String requestStr){
        /*System.debug(logginglevel.info, 'startOptimaxJob() - request : ' + requestStr);
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = (WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request) JSON.deserialize (requestStr, WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request.Class);
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response response = new WSCH_Provider_ECO_Appointment_Impl().startOptimaxJob(request);
        System.debug(logginglevel.info, 'startOptimaxJob() - response : ' + response);
        return JSON.serialize(response);*/
        return null;   
    }
    
    @RemoteAction
    global static Object getOfferAppointments(String requestStr){       
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment :: getOfferAppointments :: requestStr' + requestStr); 
        System.debug(logginglevel.info, 'getOfferAppointments() - request : ' + requestStr);
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = (WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request) JSON.deserialize (requestStr, WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request.Class);
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response response = new WSCH_Provider_ECO_Appointment_Impl().getOfferAppointments(request);
        System.debug(logginglevel.info, 'getOfferAppointments() - response : ' + response);
        return JSON.serialize(response);        
    }  
}