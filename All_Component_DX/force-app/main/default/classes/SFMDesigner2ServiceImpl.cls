/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * This is the class which provides implementation for all the rest services defined in the 
 * SFMDesigner2ServiceBase base class.
 * Note : Methods are overloaded so that same can be consumed directly using JSR calls 
 *
 * @author Servicemax
 * @version 
 * @since 2018
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
                Sachin S                Mar 2018
 *****************************************************************************************************/
public with sharing class SFMDesigner2ServiceImpl extends SFMDesigner2ServiceBase{

    
    public SFMDesigner2ServiceImpl(RestRequest req, RestResponse res){
        super(req,res);   
    }

    public SFMDesigner2ServiceImpl(){
        
    }

    /*
       Over loaded Rest methods to support JSR calls
    */
    override public SFM_WrapperDef2.SFM2_Response getDisplayTags(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            response.data = COMM_TagWebServices.getSFMDesignerTags();
            response.success = true;
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response getListOfProcesses(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            if(request.entityType != null){
                response.data = new SFM_GetListOfProcesses().getListOfProcess_V2(request.entityType);
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }    
        return response; 
    } 



    override public SFM_WrapperDef2.SFM2_Response getUserInfo(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            SVMX_Constant_Utils constantUtils = new SVMXC.SVMX_Constant_Utils();
            
            SFM_WrapperDef2.UserInfoWrapper userRecord = new SFM_WrapperDef2.UserInfoWrapper();
            userRecord.userId = UserInfo.getUserId();
            userRecord.firstName = UserInfo.getFirstName();
            userRecord.lastName = UserInfo.getLastName();
            userRecord.dateFormat = SVMXC.DCON_Configuration_WS.DCON_GetLocalDate_WS(userRecord.userId);  
            userRecord.timeZoneOffSet = constantUtils.getUserTimezoneOffset();
            userRecord.timeFormat = 'h:mm A';
            Map<String,String> numberFormatMap = constantUtils.getDecimalSeparator();
            userRecord.thousandSepartor = numberFormatMap.get('TS') ;
            userRecord.decimalSeparator = numberFormatMap.get('DS') ;
            userRecord.userCurrency = UserInfo.getDefaultCurrency();
            userRecord.svmxNameSpace = [SELECT NamespacePrefix FROM ApexClass WHERE Name =:'SFM_DesignerUtils'].NamespacePrefix;
			userRecord.organizationId = UserInfo.getOrganizationId();
            userRecord.organizationName = UserInfo.getOrganizationName();
            userRecord.organizationType = [SELECT OrganizationType FROM Organization LIMIT 1].OrganizationType;
            userRecord.userLocale = UserInfo.getLocale();
            userRecord.applicationType = SFM_DesignerUtils.APPLICATION_TYPE;

            response.data = userRecord;
            response.success = true;
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    /**
     * This method is used to retrieve SFM Transaction Global and Group settings.
     */
    override public SFM_WrapperDef2.SFM2_Response getSettingInfo(SFM_WrapperDef2.SFM2_Request request){

        System.debug( LoggingLevel.DEBUG, 'getSettingInfo() - enter');

        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        try {
            System.debug( LoggingLevel.INFO, 'getSettingInfo() : Retrieving SFM transaction manager settings');
            /* Retrieving SFM Transaction Manager setting values. */
            COMM_Utils_ManageSettings commSettings = new COMM_Utils_ManageSettings();
            Map<String,String> sfmTransactionSettings = commSettings.SVMX_getSettingList( SFM_DesignerUtils.SFM_TRANSACTION_MANAGER, SFM_DesignerUtils.SFM_SETTINGS );
            Map<String,String> commonGlobalSettings = commSettings.SVMX_getSettingList( SFM_DesignerUtils.COMMON_GLOBAL_SETTINGS, SFM_DesignerUtils.GBL_SETTINGS );
            /* Updating response structure with setting values. */
            SFM_WrapperDef2.SettingInfoWrapper settingInfo = new SFM_WrapperDef2.SettingInfoWrapper();
            settingInfo.maxSortFields = Integer.valueOf( sfmTransactionSettings.get(SFM_DesignerUtils.SETTING_MAX_SORT_FIELDS) );
            settingInfo.isChecklistEnabled = Boolean.valueOf( commonGlobalSettings.get(SFM_DesignerUtils.ENABLE_CHECKLIST_CAPABILITIES) );
            settingInfo.isSalesforceFilesEnabled = Boolean.valueOf( commonGlobalSettings.get(SFM_DesignerUtils.ENABLE_SALESFORCE_FILES) );
            Map<String,String> usageTrackingSettings = commSettings.SVMX_getSettingList(SFM_DesignerUtils.USAGE_TRACKING_SETTINGS, SFM_DesignerUtils.SETTING_USAGE_TRACKING_ALLOW );
            String isAllow = usageTrackingSettings.get(SFM_DesignerUtils.SETTING_USAGE_TRACKING_ALLOW);
            settingInfo.isUsageTrackingAllowed = ('Allow').equalsIgnoreCase( isAllow ) ? true : false;

            String isApiConfigurationEnabled = sfmTransactionSettings.get(SFM_DesignerUtils.ENABLE_API_CONFIGURATION); 
            settingInfo.isApiConfigurationEnabled = ('true').equalsIgnoreCase( isApiConfigurationEnabled ) ? true : false;

            response.data = settingInfo;
            response.success = true;
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSettingInfo() - exit; success: ' + response.success );
        }
        return response;
    }
    override public SFM_WrapperDef2.SFM2_Response getWhereUsedInfo(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            if(request.entityIds != null && request.entityType != null){
                response.data = SFM_GetEntityDependencies.getWhereUsedDetails(request.entityIds, request.entityType);
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
       }catch(Exception ex){
            setFailureResponse(response, ex);
       }
       
        return response;                
    }


    override public SFM_WrapperDef2.SFM2_Response getSFMTagsList(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            List<String> tagsList = new List<String>();
            
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SM_Tag_Definition__c', new List<String>{'Id', 'Name'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            for(SVMXC__SM_Tag_Definition__c tagRecord : [SELECT Id, Name FROM SVMXC__SM_Tag_Definition__c]){
                tagsList.add(tagRecord.Name);
            }

            response.data = tagsList;
            response.success = true;
        
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;         
    }

    override public SFM_WrapperDef2.SFM2_Response cloneSFMProcess(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{
            if(request.entityIds != null){
                List<String> entityIds = (List<String>)request.entityIds;
                SFM_WrapperDef2.SFM2_ProcessInfo clonedProcessInfo = new SFM_CloneProcess().cloneProcess_V2(entityIds);
                response.data = clonedProcessInfo;
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;        
    }

    override public SFM_WrapperDef2.SFM2_Response cloneLayout(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{
            if(request.entityIds != null){
                boolean isClone = request.isClone != null ? request.isClone: false;
                response.data = new SFM_GetPageLayout().clonePageLayout(request.entityIds, isClone);
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;        
    }

    override public SFM_WrapperDef2.SFM2_Response cloneDocTemplate(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{
            if(request.entityIds != null){
                response.data = new SFM_DocTemplateUtils().cloneDocTemplate_V2(request.entityIds);
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;        
    }

    override public SFM_WrapperDef2.SFM2_Response saveLayout(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{
            if(request.sfm_Layout != null){
                new SFM_SavePageLayout().savePageLayout_v2(request.sfm_Layout, request.auditData);
                response.data = request.sfm_Layout;
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;        
    }

    override public SFM_WrapperDef2.SFM2_Response saveTemplate(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{
            if(request.sfm_Template != null){
                new SFM_DocTemplateUtils().saveDocTemplate_V2(request.sfm_Template, request.auditData);
                response.data = request.sfm_Template;
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;        
    }

    override public SFM_WrapperDef2.SFM2_Response getListOfRules(SFM_WrapperDef2.SFM2_Request request){

        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            if(request.entityType != null){
                response.data = new SFM_GetNamedExpressionList().getListOfRules(request.entityType, request.criteria);
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response getListOfLayouts(SFM_WrapperDef2.SFM2_Request request){

        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{
            if(request.sfm_ObjectList != null && !request.sfm_ObjectList.isEmpty()){
                response.data = new SFM_GetListOfPageLayout().getListOfPageLayout_V2(request.sfm_ObjectList);
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response getListOfTemplates(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{
            if(request.sfm_ObjectList != null && !request.sfm_ObjectList.isEmpty()){
                response.data = new SFM_DocTemplateUtils().SFM_GetListOfDocTemplates_V2(request.sfm_ObjectList);
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;        
    }

    override public SFM_WrapperDef2.SFM2_Response getUserPermittedObjects(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            List<String> requestEntityIds;
            if(request != null && request.entityids != null){
                requestEntityIds = request.entityids;
            }
            /*
                If null value is passed, the method returns sobject info for all the objects else 
                it will return only for the requested set of objects.
            */
            response.data = SFM_DesignerUtils.getPermittedObjects(requestEntityIds);
            response.success = true;
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;

    }

    override public SFM_WrapperDef2.SFM2_Response getsObjectFields(SFM_WrapperDef2.SFM2_Request request){

        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            if(request.entityIds != null){
                response.data = SFM_DesignerUtils.getsObjectFields(request.entityIds, request.entityType);
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
       

    }


    override public SFM_WrapperDef2.SFM2_Response getAllPropertyElements(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            response.data = SFM_DesignerUtils.getServicemaxPropertyElements();
            response.success = true;
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response deleteEntites(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            if(request.entityIds != null && request.entityType != null){
               SFM_DeleteProcesses.deleteEntities(request.entityIds, request.entityType, request.auditData);
               response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }


   override public SFM_WrapperDef2.SFM2_Response cloneRule(SFM_WrapperDef2.SFM2_Request request){
       
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            if(request.entityIds != null && request.entityType != null){
                response.data = new SFM_SaveAsExpression().cloneRule(request.entityIds, request.entityType);  
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }
        catch(SFM_DesignerUtils.ServicemaxNestedException ex) {
            setFailureResponse(response, ex);
        }
        catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response saveRule(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            if(request.sfm_Rule != null && request.entityType != null){
                response.data = new SFM_SaveExpression().saveRule(request.sfm_Rule, request.entityType, false, request.auditData);
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }


    override public SFM_WrapperDef2.SFM2_Response getOperators(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            response.data = SFM_DesignerUtils.getDataTypeOperatorsMap();
            response.success = true;
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response getLookupRecords(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            
            if(request.entityids != null){
                response.data = SFM_DesignerUtils.fetchLookupValues(request.entityids, request.entityType);
                response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response checkDuplicateName(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            
            if((request.entityids != null && request.entityids.size() == 1) && request.entityType != null){
                boolean duplicateExist = false;
                duplicateExist = SFM_DesignerUtils.isEntityNameAlreadyUsed(request.entityids[0], request.entityType, null);
                response.success = true;

                if(duplicateExist){
                    response.success = false;
                    response.message = System.Label.SFM001_TAG685 ;//TBD :Create Custom Label
                    
                }
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response saveSFMProcess(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{

            if(request.sfm_Process != null && request.tabinfo != null){
               response.data = new SFM_SaveProcess().saveProcess_V2(request.entityType ,request.sfm_Process, request.tabinfo, request.isChildCardAddedDeleted, request.auditData);
               response.success = true;
            }else{
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response getRelatedObjects(SFM_WrapperDef2.SFM2_Request request) {
        
        System.debug( System.LoggingLevel.DEBUG, 'getRelatedObjects() - enter');
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{
            if(request != null && request.entityids != null && request.entityids.size() > 0 ) {
              
               response.data = SFM_DesignerUtils.getChildRelationship(request.entityids);
               response.success = true;
            } else {
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        } 
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        finally {
            System.debug( System.LoggingLevel.DEBUG, 'getRelatedObjects() - exit');
        }
        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response getFieldSets(SFM_WrapperDef2.SFM2_Request request){

        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{

            if(request != null && request.entityids != null){
                response.data = SFM_DesignerUtils.getFieldSetDefition(request.entityids);
                response.success = true;
            }else {
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;

    }

    override public SFM_WrapperDef2.SFM2_Response cloneLookupConfig(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{

            if(request != null && request.entityids != null && request.entityids.size() == 1){
                response.data = new SFM_GetNamedSearchInfo().getLookupConfig_v2(request.entityids[0]);
                response.success = true;
            }else {
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response saveLookupConfig(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{

            if(request != null && request.sfm_LkpConfig != null){
                new SFM_SaveNamedSearch().saveNamedSearch_v2(request.sfm_LkpConfig, request.auditData);
                response.data = request.sfm_LkpConfig;
                response.success = true;
            }else {
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response getCodeSnippets(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            response.data = SFM_DesignerUtils.getCodeSnippets();
            response.success = true;
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response getCustomActions(SFM_WrapperDef2.SFM2_Request request) {
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();

        try{
            if(request != null && request.entityids != null && !request.entityids.isEmpty() ) {
              
               response.data = SFM_DesignerUtils.getCustomActions(request.entityids);
               response.success = true;
            } else {
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        } 
        catch(Exception ex){
            setFailureResponse(response, ex);
        }
        finally {
            System.debug( System.LoggingLevel.DEBUG, 'getCustomActions() - exit');
        }
        return response;
    }

    override public SFM_WrapperDef2.SFM2_Response getMultiSourceProcess(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        try{

            if(request != null && request.criteria != null && request.criteria.targetObject != null){
                response.data = new SFM_GetAvailableMultiSourceProcesses().getAvailableMultiSourceProcesses_v2(request.criteria.targetObject, request.entityids);
                response.success = true;
            }else {
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;        
    }

    override public SFM_WrapperDef2.SFM2_Response getLinkedProcess(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        try{
            if(request != null && request.criteria != null && request.criteria.targetObjectList != null){
                response.data = new SFM_GetListOfProcesses().getListOfLinkedProcess(request.criteria.targetObjectList);
                response.success = true;
            }else {
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }

        return response;    
    }

    override public SFM_WrapperDef2.SFM2_Response getChecklistProcess(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        try{
            if(request != null && request.criteria != null && request.criteria.targetObjectList != null){
                response.data = new SFM_GetListOfProcesses().getListOfChecklistProcess(request.criteria.targetObjectList);
                response.success = true;
            }else {
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    override public SFM_WrapperDef2.SFM2_Response getSFMFunctions(SFM_WrapperDef2.SFM2_Request request){
        
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        
        try{
            response.data = SFM_DesignerUtils.getSFMFunctions(request.entityType);
            response.success = true;
       }catch(Exception ex){
            setFailureResponse(response, ex);
       }
       
        return response;                
    }

    override public SFM_WrapperDef2.SFM2_Response getChecklistQuestions(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        try{
            if(request.entityIds != null){
                response.data = new SFM_QuestionBankUtils().getChecklistQuestions(request.entityIds);
                response.success = true;
            }else {
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    override public SFM_WrapperDef2.SFM2_Response getListOfQuestions(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        try{
            response.data = new SFM_QuestionBankUtils().getListOfQuestions();
            response.success = true;
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    override public SFM_WrapperDef2.SFM2_Response getListOfResponseSet(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        try{
            response.data = new SFM_QuestionBankUtils().getListOfResponseSet();
            response.success = true;
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    override public SFM_WrapperDef2.SFM2_Response saveResponseSet(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        try{
            response = new SFM_QuestionBankUtils().saveResponseSet(request.responseSet);
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    override public SFM_WrapperDef2.SFM2_Response saveQuestionInfo(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        try{
            response = new SFM_QuestionBankUtils().saveQuestionInfo(request.questionInfo);
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    override public SFM_WrapperDef2.SFM2_Response getApiConfiguration(SFM_WrapperDef2.SFM2_Request request){
        SFM_WrapperDef2.SFM2_Response response = new SFM_WrapperDef2.SFM2_Response();
        try{
            if(request != null && request.criteria != null && request.criteria.targetObject != null){
                response.data = new SFM_GetAPIConfiguration().getAPIConfiguration_v2(request.criteria.targetObject);
                response.success = true;
            }else {
                response.success = false;
                response.message = SFM_DesignerUtils.customLabelTranslations.get('message1');
            }
        }catch(Exception ex){
            setFailureResponse(response, ex);
        }
        return response;
    }
    void setFailureResponse(SFM_WrapperDef2.SFM2_Response response, Exception ex){
        response.success = false;
        response.message = ex.getMessage();
        System.debug( LoggingLevel.ERROR, ex);
    }
}