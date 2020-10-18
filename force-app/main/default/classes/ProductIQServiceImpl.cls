public with sharing class ProductIQServiceImpl extends ProductIQServiceBase{

    public ProductIQServiceImpl(RestRequest req, RestResponse res){
        super(req, res);
    }
    
    public ProductIQServiceImpl(){  
       /**
        * The empty constructor is introduced so that the service methods can be consumed from VF page.
        */
    }
    
    public static string strDevice;
    
    /*All request methods goes here*/
    override public Object getUserConfiguration() {
        INTF_WebServicesDef.INTF_SFMRequest ptr = 
                (INTF_WebServicesDef.INTF_SFMRequest) deserializeRequestTo(INTF_WebServicesDef.INTF_SFMRequest.class);
        
        system.debug(' Request :- ' + ptr);
        
        if(ptr != null){
            if(ptr.clientInfo != null && ptr.clientInfo.size() > 0){
                for(INTF_WebServicesDef.SVMXClient clientInform : ptr.clientInfo){
                    if(clientInform.clientType != null){
                        ProductIQServiceImpl.strDevice = clientInform.clientType;
                        break;
                    }
                }
            }
        }
        
        system.debug(' ClientType Received from Request :- ' + ProductIQServiceImpl.strDevice);
        
        return getUserConfigurationInternal();
    }
    
    public Object getUserConfigurationInternal() {        
         GetUserConfiguration uc = new GetUserConfiguration();
         return uc.getProductIQProfile();
    }
    
    override public Object getTemplates() {    
        ProductIQServiceImpl.ProductIQTemplatesRequest ptr = 
                (ProductIQServiceImpl.ProductIQTemplatesRequest) deserializeRequestTo(ProductIQServiceImpl.ProductIQTemplatesRequest.class);
        return getTemplatesInternal(ptr);
    }
    
    public Object getTemplatesInternal(ProductIQServiceImpl.ProductIQTemplatesRequest ptr) { 
         GetProductIQTemplates uc = new GetProductIQTemplates();
         return uc.getProductIQTemplates(ptr.templateIds);
    } 
    
    override public Object getTranslations() {    
        return getTranslationsInternal();
    }
    
    public Object getTranslationsInternal() { 
         List<Translation> translations = new List<Translation>();
         translations.add(new Translation('FIND_AND_GET', system.Label.PRODIQ001_TAG027));//'Find & Get'
         translations.add(new Translation('FILTERS', system.Label.COMM001_TAG134));//'Filters'
         translations.add(new Translation('ACTIONS', system.Label.PRODIQ001_TAG047));//'Actions'
         translations.add(new Translation('RECORD_VIEW_TITLE', system.Label.PRODIQ001_TAG028));//'Select an item from the tree'
         translations.add(new Translation('SHOW_LOCATIONS', system.Label.PRODIQ001_TAG029));//'Show locations'
         translations.add(new Translation('SHOW_SWAPPED_PRODUCTS', system.Label.PRODIQ001_TAG030));//'Show swapped products'
         translations.add(new Translation('SHOW_DISABLED_ACTIONS', system.Label.PRODIQ001_TAG031));//'Show disabled actions'
         translations.add(new Translation('ADD_NEW_INSTALLED_PRODUCT', system.Label.PRODIQ001_TAG032));//'Add New Installed Product'
         translations.add(new Translation('ADD_NEW_LOCATION', system.Label.PRODIQ001_TAG033));//'Add New Location'
         translations.add(new Translation('SYNC_CONFIG', system.Label.PRODIQ001_TAG048));//'Sync Configuration'
         translations.add(new Translation('SYNC_DATA', system.Label.PRODIQ001_TAG049));//'Sync Data'
         translations.add(new Translation('SYNC_STATUS', system.Label.PRODIQ001_TAG050));//'Sync Status'
         translations.add(new Translation('RESET_APPLICATION_TITLE', system.Label.PRODIQ001_TAG051));//'Reset Application'
         translations.add(new Translation('RESET_APPLICATION_MESSAGE', system.Label.PRODIQ001_TAG034));//'Resetting the application erases ALL ServiceMax data from your device and restores data and configuration from the server. This process cannot be undone.'
         translations.add(new Translation('RESET_YES', system.Label.PRODIQ001_TAG052));//'Reset'
         translations.add(new Translation('RESET_NO', system.Label.COMM001_TAG040));//'Cancel'
         translations.add(new Translation('SEARCH', system.Label.PRODIQ001_TAG053));//'Search'
         translations.add(new Translation('FIND_BY_IB', system.Label.PRODIQ001_TAG035));//'Find By IB'
         translations.add(new Translation('FIND_BY_TEMPLATE', system.Label.PRODIQ001_TAG036));//'Find By Template'
         translations.add(new Translation('FIND_BY_PRODUCT', system.Label.PRODIQ001_TAG037));//'Find By Product'
         translations.add(new Translation('GET', system.Label.PRODIQ001_TAG038));//'Get'
         translations.add(new Translation('FIND_ATTRIBUTE', system.Label.PRODIQ001_TAG039));//'Find an attribute'
         translations.add(new Translation('INSTALLED_PRODUCT_ID_LABEL', system.Label.PRODIQ001_TAG040));//'Installed Product ID'
         translations.add(new Translation('ACCOUNT_LABEL', system.Label.PRODIQ001_TAG054));//'Account'
         translations.add(new Translation('CONTACT_LABEL', system.Label.PRODIQ001_TAG055));//'Contact'
         translations.add(new Translation('STATUS_LABEL', system.Label.COMM001_TAG091));//'Status'
         translations.add(new Translation('DATE_INSTALLED_LABEL', system.Label.PRODIQ001_TAG041));//'Date Installed'
         translations.add(new Translation('PREPARING_APP_MESSAGE', system.Label.PRODIQ001_TAG042));//'Preparing your application for the first time use. Please wait'
         translations.add(new Translation('DOWNLOAD_SELECTED_IB_MESSAGE', system.Label.PRODIQ001_TAG043));//'Downloading the selected Installed Products. Please wait'
         translations.add(new Translation('FIELD_UPDATE_APPLIED_MESSAGE', system.Label.PRODIQ001_TAG044));//'Field updates have been applied.'
         translations.add(new Translation('DELETE_CONFIRM_MESSAGE', system.Label.COMM001_TAG057));//'Are you sure?'
         translations.add(new Translation('DELETE_ERROR_MESSAGE', system.Label.PRODIQ001_TAG045));//'Unable to delete the selected element, as it contains synced records.'
         translations.add(new Translation('MESSAGE_INFO', system.Label.PRODIQ001_TAG056));//'Info'
         translations.add(new Translation('MESSAGE_SUCCESS', system.Label.COMM001_TAG096));//'Success'
         translations.add(new Translation('MESSAGE_ERROR', system.Label.PRODIQ001_TAG057));//'Error'
         translations.add(new Translation('MESSAGE_CONFIRM', system.Label.PRODIQ001_TAG058 ));//'Confirm'
         translations.add(new Translation('MESSAGE_IB_NOT_EXISTS', system.Label.PRODIQ001_TAG046));//Selected Installed Product could not be found in ProductIQ. Use Find and Get to download this record.       
         translations.add(new Translation('MESSAGE_LOC_NOT_EXISTS', system.Label.PRODIQ001_TAG072));//Selected Location could not be found in ProductIQ. Use Find and Get to download this record.   
         //translations.add(new Translation('UPDATING_CONFIG_MESSAGE', 'Configuration Sync in Progress'));
         translations.add(new Translation('MESSAGE_ERRORS', system.Label.PRODIQ001_TAG083));//'Error(s)'
         translations.add(new Translation('MESSAGE_WARNINGS', system.Label.PRODIQ001_TAG084));//'Warning(s)'
         translations.add(new Translation('CONFIG_SYNC_IN_PRGRESS', system.Label.PRODIQ001_TAG122));//'Configuration Sync in Progress'
         translations.add(new Translation('START_CONFIG_SYNC', system.Label.PRODIQ001_TAG087));//'Starting Config Sync'
         translations.add(new Translation('SYNC_CONFLICT_TITLE', system.Label.PRODIQ001_TAG088));//'Synchronization Conflicts/Errors'
         translations.add(new Translation('SYNC_CONFLICT_RECORD_COL', system.Label.PRODIQ001_TAG089));//'Record'
         translations.add(new Translation('SYNC_CONFLICT_MESSAGE_COL', system.Label.PRODIQ001_TAG090));//'Message'
         translations.add(new Translation('SYNC_CONFLICT_ACTION_COL', system.Label.PRODIQ001_TAG091));//'Action'
         translations.add(new Translation('SYNC_CONFLICT_RETRY_BTN', system.Label.PRODIQ001_TAG092));//'Retry'
         translations.add(new Translation('SYNC_CONFLICT_HOLD_BTN', system.Label.PRODIQ001_TAG093));//'Hold'
         translations.add(new Translation('SYNC_CONFLICT_CLOSE_BTN', system.Label.PRODIQ001_TAG094));//'Close'
         translations.add(new Translation('PURGE_DATA_TITLE', system.Label.PRODIQ001_TAG095));//'Purge Data'
         translations.add(new Translation('PURGE_DATA_ERROR_MSG', system.Label.PRODIQ001_TAG096));//'Purging data may remove locally stored ProductIQ data that has grown over time to ensure only relevant data is stored. This process cannot be undone.'
         translations.add(new Translation('PURGE', system.Label.PRODIQ001_TAG097));//'Purge'
         translations.add(new Translation('CANCEL', system.Label.PRODIQ001_TAG098));//'Cancel'
         translations.add(new Translation('SYNC_CONFLICTS', system.Label.PRODIQ001_TAG099));//'Sync Conflicts'
         translations.add(new Translation('CLONE_IB', system.Label.PRODIQ001_TAG100));//'Clone Install Product'
         translations.add(new Translation('DELETE', system.Label.PRODIQ001_TAG101));//'Delete'
         translations.add(new Translation('COMPONENT_REPLACEMENT', system.Label.PRODIQ001_TAG102));//'Component Replacement'
         translations.add(new Translation('DATA_PURGE_IN_PROGRESS', system.Label.PRODIQ001_TAG103));//'Data purge in Progress'
         translations.add(new Translation('UPDATE_BTN', system.Label.PRODIQ001_TAG104));//'Update'
         translations.add(new Translation('COMPONENT_REPLACEMENT_COL_SERIAL_LOT_NUMBER', system.Label.PRODIQ001_TAG105));//'Serial/Lot Number'
         translations.add(new Translation('COMPONENT_REPLACEMENT_COL_PRODUCT', system.Label.PRODIQ001_TAG066));//'Product'
         translations.add(new Translation('START_PRODUCT_SYNC', system.Label.PRODIQ001_TAG106));//'Starting Product Sync'
         translations.add(new Translation('CONTINE_BTN', system.Label.PRODIQ001_TAG107));//'Continue'
         translations.add(new Translation('CONNECTION_WARNING_TITLE', system.Label.PRODIQ001_TAG108));//'Connection Warning'
         translations.add(new Translation('CONNECTION_WARNING_MSG', system.Label.PRODIQ001_TAG109));//'Poor connectivity detected. Please continue when internet connectivity has improved.'
         translations.add(new Translation('CONNECTION_ERROR_TITLE', system.Label.PRODIQ001_TAG110));//'Connection Error'
         translations.add(new Translation('CONNECTION_ERROR_MSG', system.Label.PRODIQ001_TAG111));//'Internet connectivity lost. Please retry when connectivity is available'
         translations.add(new Translation('OK_BTN', system.Label.PRODIQ001_TAG112));//'Ok'
         translations.add(new Translation('SERVER_ERROR_MSG', system.Label.PRODIQ001_TAG113));//'The server is unable to complete your request'
         translations.add(new Translation('SERVER_ERROR_TITLE', system.Label.PRODIQ001_TAG114));//'Server Error'
         translations.add(new Translation('START_WITH', system.Label.PRODIQ001_TAG115));//'Start With'
         translations.add(new Translation('END_WITH', system.Label.PRODIQ001_TAG116));//'End With'
         translations.add(new Translation('EXACT_MATCH', system.Label.PRODIQ001_TAG117));//'Exact Match'
         translations.add(new Translation('CONTAINS', system.Label.PRODIQ001_TAG118));//'Contains'
         translations.add(new Translation('ACCOUNT_NOT_ASSOCIATED', system.Label.PRODIQ001_TAG119));//'The selected record does not have an account associated with it. Please contact your administrator to resolve this issue'
         translations.add(new Translation('MSG', system.Label.PRODIQ001_TAG120));//'Message'
         translations.add(new Translation('SFM_SEARCH_NOT_CONFIGURED', system.Label.PRODIQ001_TAG121));//'Search (SFM) is not configured for this profile.'
         translations.add(new Translation('NO_RECORDS_FOUND', system.Label.PRODIQ001_TAG123));//'No records found
         return translations;
    }
    
    override public Object insertRecords() {    
        InsertRecordsRequest irr = 
                (InsertRecordsRequest) deserializeRequestTo(InsertRecordsRequest.class);
        return insertRecordsInternal(irr);
    }
    
    public Object insertRecordsInternal(InsertRecordsRequest irr) { 
         List<String> ids = new List<String>();
         List<sObject> records = irr.records;
         List<sObject> clonedRecs = new List<sObject>();
         for(sObject rec : records){
            clonedRecs.add(rec.clone());
         }
         Database.SaveResult[] result = database.insert(clonedRecs, false);
         return getResults(records, result, new List<String>()); 
         /*for(integer i = 0; i < records.size(); i++){
             ids.add(records.get(i).Id);
         }
         return ids;*/
    } 
    
    override public Object updateRecords() {    
        UpdateRecordsRequest urr = 
                (UpdateRecordsRequest) deserializeRequestTo(UpdateRecordsRequest.class);
        return updateRecordsInternal(urr);
    }   
    
    public Object updateRecordsInternal(UpdateRecordsRequest urr) { 
                  
         Map<String, SObject> finalToBeUpdatedList = new Map<String, SObject>();
         List<String> conflictedRecs = new List<String>();
         if(urr == null || urr.updateRecordsList == null) return finalToBeUpdatedList;
         for(UpdateRecordsList currRecordList : urr.updateRecordsList){
            finalToBeUpdatedList.putAll(getToBeUpdatedRecords(currRecordList, urr.lastSyncTimestamp, conflictedRecs));  
         }
         Database.SaveResult[] result = database.update(finalToBeUpdatedList.values(), false);
         return getResults(finalToBeUpdatedList.values(), result, conflictedRecs);       
    }  
    
    /*Supporting classes goes here*/
    
    private Response getResults(List<SObject> recs, Database.SaveResult[] result, List<String> conflictedRecs){
         List<RecordStatus> recordsStatus = new List<RecordStatus>();
         Integer i = 0;
         for (Database.SaveResult sr : result) {
            RecordStatus status = new RecordStatus();
            status.success = sr.isSuccess();
            status.recId = recs[i].get('Id') + '';
            status.message = '';
            status.localId = recs[i].id;
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    status.message += err.getMessage() + ';';
                }            
            }else {
                status.recId = sr.getId();
            }
            recordsStatus.add(status);
            i++;
         }
         
         //now loop for conflicted recs
         for(String id : conflictedRecs){
            RecordStatus status = new RecordStatus();
            status.success = false;
            status.recId = id;
            status.message= 'LMD conflict';
            recordsStatus.add(status);
         }
        
         Response res = new Response();
         res.recordsStatus = recordsStatus;
         return res;
    }
    
    private Map<String, SObject> getToBeUpdatedRecords(UpdateRecordsList recordsLst, String lastSyncTime
                                                                , List<String> conflictedRecs) {
        
        List<SObject> records = recordsLst.records;
        List<String> recordIds = new List<String>();
        Map<String, SObject> tobeUpdatedList = new Map<String, SObject>();
        for(SObject rec : records){
            recordIds.add(rec.Id);
        }
        //Now get all the updated records after lastSyncTime
        String query = 'Select Id from ' + recordsLst.objectName  + ' where Id in: recordIds and LastModifiedDate > ' + lastSyncTime;
        Map<String, SObject> updatedRecords = new Map<String,SObject>(database.query(query));
        for(SObject rec : records){
            if(!updatedRecords.containsKey(rec.Id)){
                tobeUpdatedList.put(rec.Id, rec);
            }           
        }
        conflictedRecs.addAll(updatedRecords.keySet());
        return tobeUpdatedList;
    }
    
    public class InsertRecordsRequest {
        public List<sObject> records;
    }
    
    public class UpdateRecordsRequest {
        public String lastSyncTimestamp;
        public List<UpdateRecordsList> updateRecordsList;
    }
    
    public class Response {
        public List<RecordStatus> recordsStatus;
    }
    
    public class RecordStatus {
        public Boolean success;
        public String message;
        public String recId; 
        public SObject record;
        public String localId;
    }
    
    public class UpdateRecordsList {
        public String objectName;
        public List<sObject> records;
    }
    
    public class Translation {
        public String Key;
        public String Text;
        
        public Translation(String k, String t){
            this.Key = k;
            this.Text = t;
        }
    }
    
    public class GetUserConfiguration {
        ProductIQUtils utils = new ProductIQUtils();
        public GetUserConfiguration() {         
             
        }
        
        public ProductIQConfiguration.Profile getProductIQProfile() {
            String userSVMXProfileId = getUserSVMXProfile();
            System.debug( 'SVMXProfile Id for user: ' + userSVMXProfileId);
            
            ProductIQConfiguration.Profile PIQProfile = getProductIQProfile(userSVMXProfileId);
            System.debug( 'Profile configured for user: ' + PIQProfile);
            //get all the mappings configured in actions.
            List<ProductIQConfiguration.Mapping> mappings = getConfiguredMappings(PIQProfile);
            PIQProfile.mappings = mappings;

            getSearchConfiguration(PIQProfile);
            
            List<ProductIQConfiguration.CustomActionURL> customURLs = getCustomURLs(PIQProfile);
            PIQProfile.customUrls = customURLs;
             
            List<ProductIQConfiguration.DataValidationRule> dataValidationRules = getDataValidationRules(PIQProfile);
            PIQProfile.dataValidationRules = dataValidationRules;
            
            return PIQProfile;
        }

        public void getSearchConfiguration(ProductIQConfiguration.Profile PIQProfile){
            List<ProductIQConfiguration.SearchObject> searchObjects = PIQProfile.search;
            if(searchObjects != null){
                for(ProductIQConfiguration.SearchObject currSearch : searchObjects){
                    ProductIQConfiguration.Search search= utils.getSearchConfiguration(currSearch.searches[0].searchName, currSearch.objectName);

                    currSearch.searches[0].searchfields = search.searchfields;
                    currSearch.searches[0].advancedExpression = search.advancedExpression;
                }

            }
            
        }       
        
        public List<ProductIQConfiguration.Mapping> getConfiguredMappings(ProductIQConfiguration.Profile PIQProfile) {
            List<ProductIQConfiguration.Mapping> mappings = new List<ProductIQConfiguration.Mapping>();
            List<ProductIQConfiguration.Action> actions = PIQProfile.actions;         
            //ProductIQUtils utils = new ProductIQUtils();                            
            Set<String> configuredMaps = new Set<String>();
            for(ProductIQConfiguration.Action currAction : actions) {
                if(currAction.actionType == 'fieldupdate' && currAction.action != null) {
                    configuredMaps.add(currAction.action);
                }   
            }
            System.debug( 'Maps Configured for user: ' + configuredMaps); 
            return utils.getMappingsData(configuredMaps);
        }
        
        public List<ProductIQConfiguration.CustomActionURL> getCustomURLs(ProductIQConfiguration.Profile PIQProfile) {
            List<ProductIQConfiguration.Action> actions = PIQProfile.actions;         
            //ProductIQUtils utils = new ProductIQUtils();                            
            Set<String> configuredURLIds = new Set<String>();
            for(ProductIQConfiguration.Action currAction : actions) {
                if(currAction.actionType == 'customurl' && currAction.action != null) {
                    configuredURLIds.add(currAction.action);
                }   
            }
            System.debug( 'Custom URLs Configured for user: ' + configuredURLIds); 
            return utils.getCustomURLs(configuredURLIds);
        }
        
        public List<ProductIQConfiguration.DataValidationRule> getDataValidationRules(ProductIQConfiguration.Profile PIQProfile) {
            List<ProductIQConfiguration.DataValidationRule> dataValidationRules = new List<ProductIQConfiguration.DataValidationRule>();
            List<ProductIQConfiguration.DataValidationRulesWithObjectInfo> rules = PIQProfile.rulesWithObjectInfo;
            //ProductIQUtils utils = new ProductIQUtils();
            set<String> configuredRules = new set<String>();
            
            if(rules == null || rules.size() == 0)
                return dataValidationRules;
                
            for(ProductIQConfiguration.DataValidationRulesWithObjectInfo rule: rules){
                for(ProductIQConfiguration.DataValidationRuleInfo ruleInfo : rule.rules){
                    configuredRules.add(ruleInfo.ruleId);
                }
            }
            System.debug( 'Data Validation Rules Configured for user: ' + configuredRules); 
            return utils.getDataValidationRules(configuredRules);
        }
        
        private String getCurrentUser() {
            return UserInfo.getUserId();
        }
        
        private String getCurrentUserProfile() {
            return UserInfo.getProfileId();
        }
        
        private String getUserSVMXProfile() {
            
            String sfProfileId = getCurrentUserProfile();
            String svmxProfileId = '';
            List<String> queryFields = new List<String>{'Id', 'SVMXC__Access_Configuration_Profile__c' };
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                 throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<SVMXC__ServiceMax_Config_Data__c> profileRecs = [Select Id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c  
                                                where SVMXC__Profile__c =: sfProfileId and RecordType.Name = 'Configuration Access' 
                                                and SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'group'];
            if(profileRecs != null && profilerecs.size() > 0) {
                svmxProfileId = profileRecs[0].SVMXC__Access_Configuration_Profile__c;
            }
            return svmxProfileId;
        }
        
        private ProductIQConfiguration.Profile getProductIQProfile(String profileId) {
            ProductIQUtils utils = new ProductIQUtils();
            Map<String, String> priqSettings = utils.getProductIQSettings();            
            
            List<String> queryFields = new List<String>{'Id', 'SVMXC__ServiceMax_Profile__c', 'SVMXC__Contents__c', 'SVMXC__IsGlobal__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ProductIQProfile__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                 throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            //By default global should also be retrieved
            List<SVMXC__ProductIQProfile__c> productIQProfiles = [Select Id, SVMXC__ServiceMax_Profile__c, SVMXC__Contents__c, SVMXC__IsGlobal__c from SVMXC__ProductIQProfile__c
                                                where SVMXC__ServiceMax_Profile__c =: profileId or SVMXC__IsGlobal__c = true];
            ProductIQConfiguration.Profile PIQProfile = new ProductIQConfiguration.Profile();
            PIQProfile.actions = new List<ProductIQConfiguration.Action>();
            PIQProfile.filters = new List<ProductIQConfiguration.Filter>();
            PIQProfile.search = new List<ProductIQConfiguration.SearchObject>();
            PIQProfile.rulesWithObjectInfo = new List<ProductIQConfiguration.DataValidationRulesWithObjectInfo>();
            PIQProfile.ibPriorityFields = new List<ProductIQConfiguration.Field>();
            PIQProfile.attachment = new List<ProductIQConfiguration.AttachmentConfig>();
            PIQProfile.ibEditProces = new List<ProductIQConfiguration.IBEditProces>();
            PIQProfile.locationEditProces = new List<ProductIQConfiguration.LocationEditProces>();
            
            string strDeviceNameInFilter;
            if(ProductIQServiceImpl.strDevice == 'MFL')
                strDeviceNameInFilter = 'APPPRO006';
            else if(ProductIQServiceImpl.strDevice == 'iPad')
                strDeviceNameInFilter = 'APPPRO002';
            else if(ProductIQServiceImpl.strDevice == 'iPhone')
                strDeviceNameInFilter = 'APPPRO003';
            else if(ProductIQServiceImpl.strDevice == 'Android')
                strDeviceNameInFilter = 'APPPRO004';
            else if(ProductIQServiceImpl.strDevice == 'Android Tablet')
                strDeviceNameInFilter = 'APPPRO005';
            else
                strDeviceNameInFilter = 'APPPRO006';
            
            APFT_Schema.Filters filterstoExclude = APFT_Utilities.getInstance().getDeviceFilters(strDeviceNameInFilter);
            
            for(SVMXC__ProductIQProfile__c currProfile : productIQProfiles) {
                
                String contents = currProfile.SVMXC__Contents__c;
                ProductIQConfiguration.Profile prof = (ProductIQConfiguration.Profile)
                                                            JSON.deserialize(contents, ProductIQConfiguration.Profile.class);
                if(prof.actions != null){
                    for(ProductIQConfiguration.Action action : prof.actions){
                        if(action.actionType == 'customurl' && filterstoExclude != null && filterstoExclude.sfactions != null && filterstoExclude.sfactions.size() > 0){
                            if(!filterstoExclude.sfactions.contains(action.action))
                                PIQProfile.actions.add(action);
                        }else
                            PIQProfile.actions.add(action);
                    }
                }
                if(prof.filters != null)
                    PIQProfile.filters.addAll(prof.filters);
                if(prof.rulesWithObjectInfo != null)
                    PIQProfile.rulesWithObjectInfo.addAll(prof.rulesWithObjectInfo);
                if(prof.search != null)
                    PIQProfile.search.addAll(prof.search);
                if(prof.isTechnicalAttributesEnabled != null)
                    PIQProfile.isTechnicalAttributesEnabled = prof.isTechnicalAttributesEnabled;
                if(prof.attachment != null)
                    PIQProfile.attachment.addAll(prof.attachment);
                if(prof.ibEditProces != null)
                    PIQProfile.ibEditProces.addAll(prof.ibEditProces);
                if(prof.locationEditProces != null)
                    PIQProfile.locationEditProces.addAll(prof.locationEditProces);
                if(prof.serviceFlowWizardDisplay != null)
                    PIQProfile.serviceFlowWizardDisplay = prof.serviceFlowWizardDisplay; 
                if(prof.isAutoSyncEnabled != null)
                    PIQProfile.isAutoSyncEnabled = prof.isAutoSyncEnabled;       
            }

            if(PIQProfile.ibEditProces == null || PIQProfile.ibEditProces.isEmpty())
            {
                PIQProfile.ibEditProces.addAll(getIBEditProcessConfig());
            }
            if(PIQProfile.locationEditProces == null || PIQProfile.locationEditProces.isEmpty())
            {
                PIQProfile.locationEditProces.addAll(getLocationEditProcessConfig());  
            }
            
            PIQProfile.ibPriorityFields = utils.getFields('SVMXC__Installed_Product__c', priqSettings.get('SET001'));
            PIQProfile.ibHiddenFields = utils.getFields('SVMXC__Installed_Product__c', priqSettings.get('SET002'));
            PIQProfile.locPriorityFields = utils.getFields('SVMXC__Site__c', priqSettings.get('SET003'));
            PIQProfile.locHiddenFields = utils.getFields('SVMXC__Site__c', priqSettings.get('SET004'));
            PIQProfile.slocPriorityFields = utils.getFields('SVMXC__Sub_Location__c', priqSettings.get('SET007'));
            PIQProfile.slocHiddenFields = utils.getFields('SVMXC__Sub_Location__c', priqSettings.get('SET008'));
            PIQProfile.accPriorityFields = utils.getFields('Account', priqSettings.get('SET005'));
            PIQProfile.accHiddenFields = utils.getFields('Account', priqSettings.get('SET006'));
            PIQProfile.productDisplayFields = utils.getFields('Product2', priqSettings.get('SET009')); 
            PIQProfile.productSearchFields = utils.getFields('Product2', priqSettings.get('SET010')); 
            PIQProfile.ibDisplayFields = utils.getFields('SVMXC__Installed_Product__c', priqSettings.get('SET011'));
            PIQProfile.ibSearchFields = utils.getFields('SVMXC__Installed_Product__c', priqSettings.get('SET012'));
            
            System.debug( 'ProductIQ profile information: ' + PIQProfile + ' Actions Size: ' + PIQProfile.actions.size());          
            return PIQProfile;
        }

        private List<ProductIQConfiguration.IBEditProces> getIBEditProcessConfig()
        {
            List<String> queryFields = new List<String>{'Id','SVMXC__Name__c', 'SVMXC__ProcessID__c', 'SVMXC__Page_Layout__r.SVMXC__Object_Name__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                 throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<SVMXC__ServiceMax_Processes__c> ibEditProcessQryData = [SELECT Id,SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Purpose__c = 'STANDALONE EDIT' AND SVMXC__Page_Layout__r.SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c' AND SVMXC__ProcessID__c = 'View_And_Edit_Installed_Product'];
            List<ProductIQConfiguration.IBEditProces> ibEditProcessData = new List<ProductIQConfiguration.IBEditProces>();
            if(ibEditProcessQryData != null && !ibEditProcessQryData.isEmpty() && ibEditProcessQryData.size() > 0) 
            {
                if(ibEditProcessQryData[0] != null) 
                {
                    ProductIQConfiguration.IBEditProces ibEditProces = new ProductIQConfiguration.IBEditProces();
                    ibEditProces.sfdcId = ibEditProcessQryData[0].Id;
                    ibEditProces.processId = ibEditProcessQryData[0].SVMXC__ProcessID__c;
                    ibEditProces.processName = ibEditProcessQryData[0].SVMXC__Name__c;
                    ibEditProces.objectName = 'SVMXC__Installed_Product__c';
                    ibEditProcessData.add(ibEditProces);
                }
            }
            return ibEditProcessData;
        }
        private List<ProductIQConfiguration.LocationEditProces> getLocationEditProcessConfig() {
            List<String> queryFields = new List<String>{'Id','SVMXC__Name__c', 'SVMXC__ProcessID__c', 'SVMXC__Page_Layout__r.SVMXC__Object_Name__c' };
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                 throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<SVMXC__ServiceMax_Processes__c> locationEditProcessQryData = [SELECT Id,SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Purpose__c = 'STANDALONE EDIT' AND SVMXC__Page_Layout__r.SVMXC__Object_Name__c = 'SVMXC__Site__c' AND SVMXC__ProcessID__c = 'View_And_Edit_Location'];
            List<ProductIQConfiguration.LocationEditProces> locationEditProcessData = new List<ProductIQConfiguration.LocationEditProces>();
            if(locationEditProcessQryData != null && !locationEditProcessQryData.isEmpty() && locationEditProcessQryData.size() > 0) {
                if(locationEditProcessQryData[0] != null) {
                    ProductIQConfiguration.LocationEditProces locationEditProces = new ProductIQConfiguration.LocationEditProces();
                    locationEditProces.sfdcId = locationEditProcessQryData[0].Id;
                    locationEditProces.processId = locationEditProcessQryData[0].SVMXC__ProcessID__c;
                    locationEditProces.processName = locationEditProcessQryData[0].SVMXC__Name__c;
                    locationEditProces.objectName = 'SVMXC__Site__c';
                    locationEditProcessData.add(locationEditProces);
                }
            } 
            return locationEditProcessData;
        }

    }
    
    public class GetProductIQTemplates {
        
        public GetProductIQTemplates() {
            
        }
        
        public List<ProductIQConfiguration.TemplateHeader> getProductIQTemplates(List<String> templates) {
            ProductIQUtils utils = new ProductIQUtils();
            List<SVMXC__ProductIQTemplate__c> ibTemplatesSF = 
                                            [Select Id, Name, SVMXC__ProductIQTemplateId__c, SVMXC__Contents__c, SVMXC__TemplateContentDetails__c from SVMXC__ProductIQTemplate__c
                                            where Id in: templates];
            return utils.getProductIQTemplatesWithMappings(ibTemplatesSF);
        }
        
    }
    
    public class ProductIQTemplatesRequest {
        public List<String> templateIds;
    }
}