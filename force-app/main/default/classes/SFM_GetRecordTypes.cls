/* Security Scanned */
public with sharing class SFM_GetRecordTypes {
    public SFM_getRecordTypes(){}
    public SFM_WrapperDef.SFM_Response_RecordTypes getRecordTypes(SFM_WrapperDef.SFM_Request prequest)
    {
        Boolean response_success;
        String response_message;
        String response_tagId;
        Boolean s = false; 
        String msg;
        String tid;
        
        SVMX_Debug  log = new SVMX_Debug();
        List<SFM_WrapperDef.SFM_StringMap> result = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SObject> records = new List<SObject>();
        List<sObject> Resultdata;
        String RId;
        String stype;
        
        
        try
        {
            List<SFM_WrapperDef.SFM_StringMap> requestedData = prequest.stringMap;
            for(SFM_WrapperDef.SFM_StringMap req: requestedData)
            {
                if(req.key.toUpperCase() == 'RECORDID')
                    RId = req.value;
                if(req.key.toUpperCase() == 'OBJECTNAME')
                    stype = req.value;
            }
            system.debug('RId'+RId);
            system.debug('stype'+stype);
            if(RId != null)
            {
                //Jaysukh - Defect fix 42506:Added toLabel in below query for RecordType translated value
                //records = [Select SobjectType, NamespacePrefix, Name, IsActive, Id, DeveloperName, Description From RecordType where Id = :RId And IsActive=true];
                
                records = [Select SobjectType, NamespacePrefix, toLabel(Name), IsActive, Id, DeveloperName, Description From RecordType where Id = :RId And IsActive=true]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
  
            }
            if(stype != null)
            {
                // records give all the record types associated to Profile. We will be filtering it out using Schema.recordtypeinfo
                /*List <String> recordTypeName = COMM_Utils_V2.getObjectAvailRecordType(stype); 
                records = [Select SobjectType, NamespacePrefix, Name, IsActive, Id, DeveloperName, Description From RecordType where SobjectType= :stype And IsActive=true AND Name IN :recordTypeName];
                */
                //Jaysukh - Defect fix 42506: Using RecordTypeId for querying record instead of Name
                List <ID> recordTypeID = COMM_Utils_V2.getObjectAvailRecordType(stype); 
                
                records = [Select SobjectType, NamespacePrefix, toLabel(Name), IsActive, Id, DeveloperName, Description From RecordType where SobjectType= :stype And IsActive=true AND ID IN :recordTypeID]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            }
         
            response_success = true;
            
        }
        catch (Exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            response_message = ex.getmessage();
            response_success = false;
        }
        log.logout();
        log.print();
        log.getlog();
       
        system.debug('Result'+records);
        SFM_WrapperDef.SFM_Response_RecordTypes LKCD=new SFM_WrapperDef.SFM_Response_RecordTypes(records);
        LKCD.response.stringMap = result;
        LKCD.response.success=response_success;
        LKCD.response.logMsg=log.getlog();
        LKCD.response.message = response_message;
        return LKCD;
    }

}