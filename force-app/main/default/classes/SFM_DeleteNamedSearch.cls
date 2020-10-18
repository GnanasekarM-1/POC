/* Security Scanned */
public with sharing class SFM_DeleteNamedSearch {
  
  //Method to return exemptions
    public class SVMXException extends Exception {}
    
    public SFM_deleteNamedSearch(){}    
    public SFM_WrapperDef.SFM_Response deleteNamedSearch(SFM_WrapperDef.SFM_Request request){
        Boolean response_success;
        String response_message;
        String response_tagId;
        List<SFM_WrapperDef.SFM_StringMap> response_stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SVMX_Debug log = new SVMX_Debug();
        log.login('SFM_deleteNamedSearch', 'deleteNamedSearch');
        Savepoint sp;
        list<string> SFId= new list<string>();
        list<string> namedsearchId = new list<string>();
        list<string> namedsearchId1 = new list<string>();
        List<SFM_WrapperDef.SFM_StringListMap> requestedId = request.StringListMap;
        list<SVMXC__ServiceMax_Processes__c > LstnamedSearch = new list<SVMXC__ServiceMax_Processes__c >();
        list<SVMXC__ServiceMax_Processes__c > LstnamedSearch1 = new list<SVMXC__ServiceMax_Processes__c >();
        list<SVMXC__ServiceMax_Config_Data__c> LstnamedSearchDetails= new list<SVMXC__ServiceMax_Config_Data__c>();
        try
        {
          sp = Database.setSavepoint();
            for(SFM_WrapperDef.SFM_StringListMap req: requestedId)
            {
                if(req.key.toUpperCase() == 'RECORDID')
                    SFId = req.valueList;
            }
            
            System.debug('TEST LOG: ' + SFId);
            
          // Integrity check, if the page is associated to any process this will throw exception
          //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
          List<SVMXC__Page_Layout_Detail__c> lstNamedSearchObject = [Select Name, SVMXC__Named_Search__c From SVMXC__Page_Layout_Detail__c where SVMXC__Named_Search__c IN : SFId];
        system.debug('lstNamedSearchObject'+lstNamedSearchObject.size()+lstNamedSearchObject);
        if(lstNamedSearchObject.size() > 0)
          throw new SVMXException(system.label.SFM001_TAG424);
        
        //Query Top Header Record From given Id.
            if(SFId != null){
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                LstnamedSearch = [SELECT Id, Name, SVMXC__Name__c, SVMXC__Description__c ,SVMXC__Source_Object_Name__c,SVMXC__ProcessID__c,SVMXC__IsStandard__c,SVMXC__Sequence__c,SVMXC__Process__c from SVMXC__ServiceMax_Processes__c where Id IN:SFId];
            }
            // From Top Header Record Query Header(Object) recrods.
            if(LstnamedSearch.size() > 0){
                for(SVMXC__ServiceMax_Processes__c p : LstnamedSearch){
                    namedsearchId.add(p.Id);
                }
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                LstnamedSearch1 = [SELECT Id, Name, SVMXC__Source_Object_Name__c, SVMXC__Process__c ,SVMXC__Sequence__c from SVMXC__ServiceMax_Processes__c where SVMXC__Module__c IN:namedsearchId];
            }
            //From Header Records Query Config Data.
            if(LstnamedSearch1.size() > 0){
                for(SVMXC__ServiceMax_Processes__c p : LstnamedSearch1){
                    namedsearchId1.add(p.Id);
                }
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                LstnamedSearchDetails=[SELECT SVMXC__Sequence__c,SVMXC__Search_Object_Field_Type__c,SVMXC__Field_Name__c, SVMXC__Expression_Rule__c, Name, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:namedsearchId1];
            }
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            delete LstnamedSearchDetails;
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            delete LstnamedSearch1;
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            delete LstnamedSearch;
            response_success = true;
            
        }
        catch(exception ex){
            log.setlog('ERROR', ex.getmessage());
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);
            response_success = false;
            response_message = ex.getmessage();
        }
        //Setting up resultset
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        log.logout();
        log.print();
        response.logMsg = log.getlog();
        response.success = response_success;
        response.message = response_message;
        response.stringMap = response_stringMap;
        
        return response;
    }
}