public with sharing class SFM_SaveAsNamedSearch {
    public SFM_saveAsNamedSearch(){}
    public SFM_WrapperDef.SFM_Response cloneNamedSearchInfo(SFM_WrapperDef.SFM_Request prequest)
     {
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SVMX_Debug log = new SVMX_Debug();
        List<SFM_WrapperDef.SFM_StringMap> requestedId = prequest.stringMap;
        String SFId;
        log.login('SFM_saveAsNamedSearch', 'cloneNamedSearchInfo(SFM_WrapperDef.SFM_Request prequest)');
        Boolean response_success;
        String response_message;
        String response_tagId;
        SFM_Utils utils = new SFM_Utils();
        List<SFM_WrapperDef.SFM_StringMap> response_stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        List<String> resultIds = new List<String>();
        List<SVMXC__ServiceMax_Processes__c> namedSearchHdr = new List<SVMXC__ServiceMax_Processes__c>();
        List<SFM_WrapperDef.SFM_NamedSearchInfoDetail> namedSearchDetails = new List<SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        List<SVMXC__ServiceMax_Processes__c> namedSearchHdr2 = new List<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> fieldsData = new list<SVMXC__ServiceMax_Config_Data__c>();
        Map<string,list<SVMXC__ServiceMax_Config_Data__c>> MapNamedExpDetail = new Map<string,list<SVMXC__ServiceMax_Config_Data__c>>();
        Map<String, Id> searchHeadersId_Map = new Map<String, Id>();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Named Search');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        Savepoint sp;
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();//member of SFM_Response_ProcessNodeInfo
        List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail> processNodeSourceObject = new List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail>();//member of SFM_Response_ProcessNodeInfo
        SVMXC__ServiceMax_Processes__c CloneprocessNodes = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail> CloneprocessNodeSourceObject = new List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        List<SFM_WrapperDef.SFM_NamedSearchInfo> NSI1=new List<SFM_WrapperDef.SFM_NamedSearchInfo>();
     
            log.setlog('SAVEPOINT', 'Setting up savepoint before creating');
            sp = Database.setSavepoint();
            SVMXC.SFM_WrapperDef.SFM_Response_NamedSearchInfo ResNamedSearch;
            SVMXC.SFM_getNamedSearchInfo getnamedsearch = new SVMXC.SFM_getNamedSearchInfo();
            ResNamedSearch = getnamedsearch.getNamedSearchInfo(prequest);
            
                for(SFM_WrapperDef.SFM_NamedSearchInfo namedsrchinfo: ResNamedSearch.namedSearch)
                 {
                  
                   processNodes = namedsrchinfo.namedSearchHdr;
                   processNodeSourceObject.addAll(namedsrchinfo.namedSearchDetails);
                   if(processNodes != null)
                   CloneprocessNodes = processNodes.clone(false,true);
                   CloneprocessNodes.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                   CloneprocessNodes.SVMXC__Name__c = CloneprocessNodes.SVMXC__Name__c + ' ' + system.now();
                   CloneprocessNodes.SVMXC__IsStandard__c = false;
                   CloneprocessNodes.SVMXC__ProcessID__c = CloneprocessNodes.SVMXC__Name__c;
                 
                 }
                
                 if(processNodeSourceObject.size() > 0)
        {
            for(Integer i = 0;i<processNodeSourceObject.size();i++)
            {
                SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail ProcessNodeDetail; //= new SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail();
                ProcessNodeDetail = processNodeSourceObject[i];
                SVMXC__ServiceMax_Processes__c processNodeObejct = new SVMXC__ServiceMax_Processes__c();
                List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
                processNodeObejct = ProcessNodeDetail.objectDetails.clone(false,true);
                processNodeObejct.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                processNodeObejct.SVMXC__Name__c = processNodeObejct.SVMXC__Name__c + ' ' + system.now();
                processNodeObejct.SVMXC__ProcessID__c = processNodeObejct.SVMXC__ProcessID__c + ' ' + system.now();
                for(Integer j = 0;j<ProcessNodeDetail.fields.size();j++)
                {
                    SVMXC__ServiceMax_Config_Data__c tempconfigdata = new SVMXC__ServiceMax_Config_Data__c();
                    tempconfigdata = ProcessNodeDetail.fields[j].clone(false,true);
                    tempconfigdata.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
                    tempconfigdata.SVMXC__Expression_Type__c='SRCH_Object_Fields';
                    processSourceUpdates.add(tempconfigdata);
                }
                CloneprocessNodeSourceObject.add(new SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail(processNodeObejct,processSourceUpdates));
            }
        }
                
            SFM_WrapperDef.SFM_NamedSearchInfo oSFM_Exp1 = new SFM_WrapperDef.SFM_NamedSearchInfo(CloneprocessNodes,CloneprocessNodeSourceObject);
            NSI1.add(oSFM_Exp1);
            SFM_WrapperDef.SFM_Request_NamedSearchInfo ReqNamedSearch = new SFM_WrapperDef.SFM_Request_NamedSearchInfo(NSI1);
            SVMXC.SFM_saveNamedSearch saveprocess = new SVMXC.SFM_saveNamedSearch();
            return saveprocess.saveNamedSearch(ReqNamedSearch);
            
            
        
            
            
        
        
     }
     
}