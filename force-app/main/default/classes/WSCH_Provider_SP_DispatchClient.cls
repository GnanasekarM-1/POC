global class WSCH_Provider_SP_DispatchClient{
    private String[] ns_map_type_info = new String[]{'http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient', 'WSCH_Provider_SP_DispatchClient'};

    global class DispOutputResponse {
        webservice Integer resultCode { get; set; }
        private String[] resultCode_type_info = new String[]{'resultCode','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient','true','false'};
        private String[] field_order_type_info = new String[]{'resultCode'};
    }

    global class DispOutputRequest {
        webservice WSCH_Provider_SP_DispatchClient.DispJobEarmarked jobInfo { get; set; }
        private String[] jobInfo_type_info = new String[]{'jobInfo','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient','false','false'};
        private String[] field_order_type_info = new String[]{'jobInfo'};
    }

    global class DispJobEarmarked {
        webservice WSCH_Provider_SP_DispatchClient.LoginRequest loginRequest { get; set; }
        webservice String jobID { get; set; }
        webservice String earmarkType { get; set; }
        webservice Boolean reEarmark { get; set; }
        webservice String dateEarmarked { get; set; }
        webservice String empID { get; set; }
        webservice String ETS { get; set; }
        webservice String ETA { get; set; }
        webservice String ETF { get; set; }
        webservice Long jobCountTentative { get; set; }
        webservice Long totalBreakTime { get; set; }
        webservice WSCH_Provider_SP_DispatchClient.BreakTimes[] breaks { get; set; }
        webservice String bookLoc { get; set; }
        webservice String bookLocName { get; set; }
        webservice String postcode { get; set; }
        webservice String teamID { get; set; }
        webservice String IRUID { get; set; }
        webservice String companyID { get; set; }
        private String[] loginRequest_type_info = new String[]{'loginRequest','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'0','1','true'};
        private String[] jobID_type_info = new String[]{'jobID','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','2','true'};
        private String[] earmarkType_type_info = new String[]{'earmarkType','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','false'};
        private String[] reEarmark_type_info = new String[]{'reEarmark','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','false'};
        private String[] dateEarmarked_type_info = new String[]{'dateEarmarked','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] empID_type_info = new String[]{'empID','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] ETS_type_info = new String[]{'ETS','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] ETA_type_info = new String[]{'ETA','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] ETF_type_info = new String[]{'ETF','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] jobCountTentative_type_info = new String[]{'jobCountTentative','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','false'};
        private String[] totalBreakTime_type_info = new String[]{'totalBreakTime','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','false'};
        private String[] breaks_type_info = new String[]{'breaks','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'0','5','false'};
        private String[] bookLoc_type_info = new String[]{'bookLoc','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient','bookLoc','1','4','true'};
        private String[] bookLocName_type_info = new String[]{'bookLocName','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] postcode_type_info = new String[]{'postcode','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] teamID_type_info = new String[]{'teamID','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] IRUID_type_info = new String[]{'IRUID','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] companyID_type_info = new String[]{'companyID','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient','false','false'};
        private String[] field_order_type_info = new String[]{'loginRequest','jobID','earmarkType','reEarmark','dateEarmarked','empID','ETS','ETA','ETF','jobCountTentative','totalBreakTime','breaks','bookLoc','bookLocName','postcode','teamID','IRUID','companyID'};
    }

    global class LoginRequest {
        webservice String databaseUser { get; set; }
        webservice String password { get; set; }
        webservice String spUser { get; set; }
        private String[] databaseUser_type_info = new String[]{'databaseUser','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] password_type_info = new String[]{'password','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] spUser_type_info = new String[]{'spUser','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient','false','false'};
        private String[] field_order_type_info = new String[]{'databaseUser','password','spUser'};
    }

    global class BreakTimes {
        webservice String BreakName { get; set; }
        webservice String BreakType { get; set; }
        webservice String BreakStart { get; set; }
        webservice Long BreakDuration { get; set; }
        private String[] BreakName_type_info = new String[]{'BreakName','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] BreakType_type_info = new String[]{'BreakType','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','false'};
        private String[] BreakStart_type_info = new String[]{'BreakStart','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','true'};
        private String[] BreakDuration_type_info = new String[]{'BreakDuration','http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/SPR14/WSCH_Provider_SP_DispatchClient','false','false'};
        private String[] field_order_type_info = new String[]{'BreakName','BreakType','BreakStart','BreakDuration'};
    }

    /*
     * Web service to be used by SP's Dispatch Client to send earmaked jobs.
     */
    webservice static WSCH_Provider_SP_DispatchClient.DispOutputResponse DispOutput(WSCH_Provider_SP_DispatchClient.DispJobEarmarked jobInfo) {

        WSCH_Provider_SP_DispatchClient.DispOutputResponse dispOutputResponse = new WSCH_Provider_SP_DispatchClient.DispOutputResponse();
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClient : DispOutput :  DispJobEarmarked : ' + Json.serializePretty(jobInfo));
        dispOutputResponse.resultCode = WSCH_Provider_SP_DispatchClientHelper.processDispatchedWorkOrder(jobInfo);
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClient : DispOutput : dispOutputResponse : ' + Json.serializePretty(dispOutputResponse));
        WSCH_AuditLogger.finish();
        return dispOutputResponse;
    }
}