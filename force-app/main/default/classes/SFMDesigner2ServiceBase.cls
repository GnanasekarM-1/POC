/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * This is the base class for all designer 2.0 services, this will direct to the 
 * correponding service definition (implementaion of which is available in class SFMDesigner2ServiceImpl)   
 * based on the rest url end point.
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
public abstract class SFMDesigner2ServiceBase extends SVMXRestBase{
    
    /*
        Rest url end point method keys
    */
    Static final String REST_RETRIEVETAGS = 'retrieveDisplayTags'; 
    Static final String REST_LISTOFPROCESSES = 'listOfProcesses'; 
    Static final String REST_USERINFO = 'userInfo'; 
    Static final String REST_WHEREUSED = 'whereUsed';
    Static final String REST_ALLSFMTAGS = 'allSFMTags';
    Static final String REST_CLONESFMPROCESS = 'cloneProcess';
    Static final String REST_LISTOFRULES = 'listOfRules';
    Static final String REST_SOBJECTS = 'getsObjects';
    Static final String REST_OBJECTFIELDS = 'getsObjectFields';
    Static final String REST_PROPERTYELEMENTS = 'getPropertyElements';
    Static final String REST_DELETEENTITY = 'removeEntities';
    Static final String REST_CLONERULE = 'cloneRule';
    Static final String REST_SAVERULE = 'saveRule';
    Static final String REST_OPERATORS = 'getOperators';
    Static final String REST_FETCHLOOKUPRECORDS = 'getLookupRecords';
    Static final String REST_CHECKDUPLICATENAME = 'checkDuplicateName';
    Static final String REST_SAVEPROCESS = 'saveProcess';
    Static final String REST_LISTOFLAYOUT = 'listOfLayouts';
    Static final String REST_LISTOFTEMPLATE = 'listOfTemplates';
    Static final String REST_CHILD_RELATIONSHIP = 'getChildRelationships';
    Static final String REST_CLONELAYOUT = 'cloneLayout';
    Static final String REST_CLONETEMPLATE = 'cloneTemplate';
    Static final String REST_SAVELAYOUT = 'saveLayout';
    Static final String REST_SAVETEMPLATE = 'saveTemplate';
    Static final String REST_FIELDSETS = 'getFieldSets';
    Static final String REST_CLONELKPCONIG = 'cloneLkpConfig';
    Static final String REST_SAVELKPCONIG = 'saveLkpConfig';
    Static final String REST_GETCODESNIPPETS = 'getCodeSnippets';
    Static final String REST_GETCUSTOMACTIONS = 'getCustomActions';
    Static final String REST_GETMULTISOURCEPROCESS = 'getMultiSourceProcess';
    Static final String REST_GETLINKEDPROCESS = 'getLinkedProcess';
    Static final String REST_GETSFMFUNCTIONS = 'getSFMFunctions';
    Static final String REST_GETCHECKLISTPROCESS = 'getChecklistProcess';
    Static final String REST_SETTINGINFO = 'getSettingInfo';
    Static final String REST_GETCHECKLISTQUESTIONS = 'getChecklistQuestions';
    Static final String REST_GETLISTOFQUESTIONS = 'getListOfQuestions';
    Static final String REST_GETLISTOFRESPONSESET = 'getListOfResponseSet';
    Static final String REST_GETAPICONFIGURATION = 'getApiConfiguration';
    static final String REST_SAVERESPONSESET        = 'saveResponseSet';
    static final String REST_SAVE_QUESTION_INFO     = 'saveQuestionInfo';

    SFM_WrapperDef2.SFM2_Request request ;
    
    public SFMDesigner2ServiceBase(){
        
    }
    
    protected SFMDesigner2ServiceBase(RestRequest req, RestResponse res) {
        super(req, res, 'SFMDesigner2ServiceIntf');
        request = (SFM_WrapperDef2.SFM2_Request) deserializeRequestTo(SFM_WrapperDef2.SFM2_Request.class);     
    }

    /*
        Based on the end point URL invokes corresponding services
    */
    override public Object invokeMethod(SVMXRestMethodInfo mi){
        Object res = null;
        SFM_WrapperDef2.SFM2_Response response;
        if(mi != null && mi.MethodName != null && mi.MethodName != ''){
            if(mi.MethodName.equalsIgnoreCase(REST_RETRIEVETAGS)){
                return getDisplayTags(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_LISTOFPROCESSES)){
                return getListOfProcesses(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_USERINFO)){
                return getUserInfo(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_WHEREUSED)){
                return getWhereUsedInfo(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_ALLSFMTAGS)){
                return getSFMTagsList(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_CLONESFMPROCESS)){
                return cloneSFMProcess(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_LISTOFRULES)){
                return getListOfRules(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_SOBJECTS)){
                return getUserPermittedObjects(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_OBJECTFIELDS)){
                return getsObjectFields(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_PROPERTYELEMENTS)){
                return getAllPropertyElements(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_DELETEENTITY)){
                return deleteEntites(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_CLONERULE)){
                return cloneRule(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_SAVERULE)){
                return saveRule(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_OPERATORS)){
                return getOperators(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_FETCHLOOKUPRECORDS)){
                return getLookupRecords(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_CHECKDUPLICATENAME)){
                return checkDuplicateName(request);  
            }else if(mi.MethodName.equalsIgnoreCase(REST_SAVEPROCESS)){    
                return saveSFMProcess(request);  
            }else if(mi.MethodName.equalsIgnoreCase(REST_LISTOFLAYOUT)){    
                return getListOfLayouts(request);  
            }else if(mi.MethodName.equalsIgnoreCase(REST_LISTOFTEMPLATE)){    
                return getListOfTemplates(request);  
            }else if(mi.MethodName.equalsIgnoreCase(REST_CHILD_RELATIONSHIP)){    
                return getRelatedObjects(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_CLONELAYOUT)){    
                return cloneLayout(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_CLONETEMPLATE)){    
                return cloneDocTemplate(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_SAVELAYOUT)){    
                return saveLayout(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_FIELDSETS)){    
                return getFieldSets(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_CLONELKPCONIG)){    
                return cloneLookupConfig(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_SAVELKPCONIG)){    
                return saveLookupConfig(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_GETCODESNIPPETS)){    
                return getCodeSnippets(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_GETCUSTOMACTIONS)){    
                return getCustomActions(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_GETMULTISOURCEPROCESS)){    
                return getMultiSourceProcess(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_GETLINKEDPROCESS)){    
                return getLinkedProcess(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_GETSFMFUNCTIONS)){    
                return getSFMFunctions(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_SAVETEMPLATE)){    
                return saveTemplate(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_GETCHECKLISTPROCESS)){
                return getChecklistProcess(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_SETTINGINFO)){
                return getSettingInfo(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_GETCHECKLISTQUESTIONS)){
                return getChecklistQuestions(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_GETLISTOFQUESTIONS)){
                return getListOfQuestions(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_GETLISTOFRESPONSESET)){
                return getListOfResponseSet(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_GETAPICONFIGURATION)){
                return getApiConfiguration(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_SAVERESPONSESET)){
                return saveResponseSet(request);
            }else if(mi.MethodName.equalsIgnoreCase(REST_SAVE_QUESTION_INFO)){
                return saveQuestionInfo(request);
            }else{
                 response = new SFM_WrapperDef2.SFM2_Response();    
                 response.success = false;
                 response.message = 'Invalid Request';
            }
        }else{
            response = new SFM_WrapperDef2.SFM2_Response();
            response.success = false;
            response.message = 'Invalid Request'; //TBD custom label to be added 
        }

        return response;
    }

    /*
        Base method for all the services
    */
    public abstract SFM_WrapperDef2.SFM2_Response getDisplayTags(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getListOfProcesses(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getUserInfo(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getWhereUsedInfo(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getSFMTagsList(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response cloneSFMProcess(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getListOfRules(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getUserPermittedObjects(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getsObjectFields(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getAllPropertyElements(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response deleteEntites(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response cloneRule(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response saverule(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getOperators(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getLookupRecords(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response checkDuplicateName(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response saveSFMProcess(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getListOfLayouts(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getListOfTemplates(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getRelatedObjects(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response cloneLayout(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response cloneDocTemplate(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response saveLayout(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getFieldSets(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response cloneLookupConfig(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response saveLookupConfig(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getCodeSnippets(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getCustomActions(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getMultiSourceProcess(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getLinkedProcess(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getSFMFunctions(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response saveTemplate(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getChecklistProcess(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getSettingInfo(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getChecklistQuestions(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getListOfQuestions(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getListOfResponseSet(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response getApiConfiguration(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response saveResponseSet(SFM_WrapperDef2.SFM2_Request request);
    public abstract SFM_WrapperDef2.SFM2_Response saveQuestionInfo(SFM_WrapperDef2.SFM2_Request request);
}