@isTest
Private class CONF_QuestionBankManager_UT{
    static testMethod void CONF_QuestionBankManager_Test(){
        List<SVMXC__Question_Bank__c> lstQuestion = new List<SVMXC__Question_Bank__c>();
        for(Integer i=1; i<30; i++){
            SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
            objQuestionBank.SVMXC__QuestionID__c = 'QB000001'+i;
            objQuestionBank.SVMXC__Question__c = 'Test Question '+i;
            objQuestionBank.SVMXC__Response_Type__c = 'Text';
            lstQuestion.add(objQuestionBank);
        }
        insert lstQuestion;
        
        SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        objStringMap.key = 'AllQUESTION';
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(objStringMap);
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request.stringMap = lstStringMap;
        String request  = JSON.serialize(obj_Request);
        
        SVMXC.CONF_QuestionBankManager.JsrGetListOfQuestions(request);
        SVMXC.CONF_QuestionBankManager.JsrGetResponseSetList(request);
        SVMXC.CONF_QuestionBankManager.JsrEditQuestionInfo(request);
        SVMXC.CONF_QuestionBankManager.JsrDeleteQuestion(request);
        SVMXC.CONF_QuestionBankManager.JsrSaveQuestion(request);
        
        SVMXC.CONF_QuestionBankManager objCONF_QuestionBankManager = new SVMXC.CONF_QuestionBankManager();
        Object temp1 = objCONF_QuestionBankManager.listOfQuestion;
        Object temp2 = objCONF_QuestionBankManager.NEXTlistOfQuestion;
        Object temp3 = objCONF_QuestionBankManager.PREVlistOfQuestion;
        objCONF_QuestionBankManager.nextRecords();
        objCONF_QuestionBankManager.previousRecords();
        objCONF_QuestionBankManager.resetSetConroller();
    }
}