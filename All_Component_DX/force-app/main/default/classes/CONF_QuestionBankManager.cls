global with sharing class CONF_QuestionBankManager {
    
    class output{
        public String id;
        public String question;
        public String dataType;
        public String lastModifiedDate;
        public output(){}
    }
    @RemoteAction
    global static Object JsrGetListOfQuestions(String requestStr){
        SVMXC.SFM_WrapperDef.SFM_Request objRequest = (SVMXC.SFM_WrapperDef.SFM_Request)JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef.SFM_Request.class);
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = new SVMXC.SFM_QuestionBankUtils().SFM_GetListOfQuestion(objRequest);
        List<output> result = new List<output>();
        for(SVMXC.SFM_WrapperDef.SFM_QuestionBank obj : objResponse.lstQuestionBank){
            output objQInfo = new output();
            objQInfo.id = obj.question.id;
            objQInfo.question = obj.question.SVMXC__Question__c;
            objQInfo.dataType = obj.question.SVMXC__Response_Type__c;
            objQInfo.lastModifiedDate = String.valueof(obj.question.LastModifiedDate.date());
            result.add(objQInfo);
        }
        System.debug('Response in JSR method class :'+result);
        return JSON.serialize(result);
    }
    
    @RemoteAction
    global static Object JsrGetResponseSetList(String requestStr){
        SVMXC.SFM_WrapperDef.SFM_Request objRequest = (SVMXC.SFM_WrapperDef.SFM_Request)JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef.SFM_Request.class);
        return JSON.serialize(new SVMXC.SFM_QuestionBankUtils().SFM_GetListOfResponseSet(objRequest));
    }
    
    @RemoteAction
    global static Object JsrEditQuestionInfo(String requestStr){
        SVMXC.SFM_WrapperDef.SFM_Request objRequest = (SVMXC.SFM_WrapperDef.SFM_Request)JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef.SFM_Request.class);
        return JSON.serialize(new SVMXC.SFM_QuestionBankUtils().SFM_GetQuestionInfo(objRequest));
    }
    
    @RemoteAction
    global static Object JsrDeleteQuestion(String requestStr){
        SVMXC.SFM_WrapperDef.SFM_Request objRequest = (SVMXC.SFM_WrapperDef.SFM_Request)JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef.SFM_Request.class);
        return JSON.serialize(new SVMXC.SFM_QuestionBankUtils().SFM_DeleteQuestion(objRequest));
    }
    
    @RemoteAction
    global static Object JsrSaveQuestion(String requestStr){
        SVMXC.SFM_WrapperDef.SFM_Request objRequest = (SVMXC.SFM_WrapperDef.SFM_Request)JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef.SFM_Request.class);
        return JSON.serialize(new SVMXC.SFM_QuestionBankUtils().SFM_SaveQuestionInfo(objRequest));
    }
    
    public CONF_QuestionBankManager() {}
    
    private ApexPages.Standardsetcontroller standardSetControllerForRecords{
        get{
            if(standardSetControllerForRecords == null){
                List<SVMXC__Question_Bank__c> questionList = [SELECT Id, SVMXC__Question__c, SVMXC__Response_Type__c, LastModifiedDate FROM SVMXC__Question_Bank__c ORDER BY LastModifiedDate DESC LIMIT 10000];
                standardSetControllerForRecords= new ApexPages.StandardSetController(questionList);
                standardSetControllerForRecords.setPageSize(100);
                standardSetControllerForRecords.setPageNumber(1);
            }
            return standardSetControllerForRecords;
        }
        set;
    }
    public Object listOfQuestion{
        get{
            return JSON.serialize((List<SVMXC__Question_Bank__c>)standardSetControllerForRecords.getRecords());
        }
        set;
    }
    public Object NEXTlistOfQuestion{
        get{
            return JSON.serialize((List<SVMXC__Question_Bank__c>)standardSetControllerForRecords.getRecords());
        }
        set;
    }
    public Object PREVlistOfQuestion{
        get{
            return JSON.serialize((List<SVMXC__Question_Bank__c>)standardSetControllerForRecords.getRecords());
        }
        set;
    }
    public void nextRecords(){
        standardSetControllerForRecords.next();
    }
    public void previousRecords(){
        standardSetControllerForRecords.previous();
    }
    public void resetSetConroller(){
        standardSetControllerForRecords = null;
    }
}