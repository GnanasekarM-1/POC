/* Security Scanned */
public with sharing class SFM_GetAllNamedSearch {
    public SFM_getAllNamedSearch(){}    
    //Get all Named Search information
    public SFM_WrapperDef.SFM_Response_NamedSearch getAllNamedSearch(SFM_WrapperDef.SFM_Request prequest){
        Boolean response_success;
        String response_message;
        String response_tagId;
        SFM_WrapperDef.SFM_Response presponse = new SFM_WrapperDef.SFM_Response();
        List<SFM_WrapperDef.SFM_StringMap> response_stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SVMX_Debug log = new SVMX_Debug();
        log.login('SFM_getAllNamedSearch', 'getAllNamedSearch');
        SFM_Utils utils = new SFM_Utils();
        List<SVMXC__ServiceMax_Processes__c> searchHeader = new List<SVMXC__ServiceMax_Processes__c>();
        List<SFM_WrapperDef.SFM_StringMap> request = prequest.stringMap;
        String SrchType;
        String sourceObjectName;
        try
        {
            for(SFM_WrapperDef.SFM_StringMap req: request)
            {
                if(req.key.toUpperCase() == 'OBJECTNAME')
                    sourceObjectName = req.value;
                if(req.key.toUpperCase() == 'SEARCHTYPE')
                    SrchType = req.value;
            }
            if(SrchType == 'NAMEDSEARCH')
            {
                if(sourceObjectName != null)
                
                    searchHeader = [SELECT Id, Name, SVMXC__Name__c, SVMXC__Description__c ,SVMXC__Source_Object_Name__c,SVMXC__Process__c,SVMXC__IsStandard__c,SVMXC__Sequence__c,SVMXC__IsDefault__C,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__Rule_Type__c='SRCH_NAMED_SEARCH' And SVMXC__Source_Object_Name__c = :sourceObjectName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                else
                
                    searchHeader = [SELECT Id, Name, SVMXC__Name__c, SVMXC__Description__c ,SVMXC__Source_Object_Name__c,SVMXC__Process__c,SVMXC__IsStandard__c,SVMXC__Sequence__c,SVMXC__IsDefault__C,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__Rule_Type__c='SRCH_NAMED_SEARCH']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            if(SrchType == 'LOOKUPCONFIG')
            {
                if(sourceObjectName != null)
                
                    searchHeader = [SELECT Id, Name, SVMXC__Name__c, SVMXC__Description__c ,SVMXC__Source_Object_Name__c,SVMXC__Process__c,SVMXC__IsStandard__c,SVMXC__Sequence__c,SVMXC__IsDefault__C,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__Rule_Type__c='SRCH_LOOKUP_CONFIG' AND SVMXC__Source_Object_Name__c = :sourceObjectName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                else
                
                    searchHeader = [SELECT Id, Name, SVMXC__Name__c, SVMXC__Description__c ,SVMXC__Source_Object_Name__c,SVMXC__Process__c,SVMXC__IsStandard__c,SVMXC__Sequence__c,SVMXC__IsDefault__C,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__Rule_Type__c='SRCH_LOOKUP_CONFIG']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            response_success = true;
        }
        catch(exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            response_success = false;
            response_message = ex.getmessage();
        }
        SFM_WrapperDef.SFM_Response_NamedSearch response = new SFM_WrapperDef.SFM_Response_NamedSearch(searchHeader);
        log.logout();
        log.print();
        response.response=presponse;
        presponse.stringMap=response_stringMap;
        presponse.logMsg = log.getlog();
        presponse.success = response_success;
        presponse.message = response_message;
        return response;
    }
}