public with sharing class CONF_ManageTranslations 
{
    public String installation_Key = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
    public Boolean IsOverWrite = true;
    public void copyMaster(){isRenderPOPUP = true;}
    public Boolean isRenderPOPUP{get; set;}
    public Boolean isRenderProcesses{get; set;}
    public String strSearchKeyword = NULL;
    public String getstrSearchKeyword(){return this.strSearchKeyword;}
    public void setstrSearchKeyword(String Keyword){this.strSearchKeyword = Keyword;}
    public List<TagWrapper> lstTagsWrapper = new List<TagWrapper>();
    public List<TagWrapper> getlstTagsWrapper(){return this.lstTagsWrapper;}
    public void setlstTagsWrapper(List<TagWrapper> lst){this.lstTagsWrapper = lst;}
    public Boolean isRenderTranslationBlock{get; set;}
    public String selectedProType{get; set;}
    public String selectedLanguage{get; set;}
    public String selectedProcess{get; set;}
    public List<selectOption> lstSOProcessType = new List<selectOption>();
    public List<selectOption> getlstSOProcessType(){return this.lstSOProcessType;}
    public List<selectOption> lstSOLanguage = new List<selectOption>();
    public List<selectOption> getlstSOLanguage(){return this.lstSOLanguage;}
    public List<selectOption> lstSOProcesses = new List<selectOption>();
    public List<selectOption> getlstSOProcesses(){return this.lstSOProcesses;}
    public List<String> lstRecordType;
    
    /** Wrapper Class **/
    public class TagWrapper
    {
        public String TagKey {get; set;}
        public String TagLanguage {get; set;}
        public SVMXC__ServiceMax_Tags__c SVMXMasterTag {get; set;}
        public SVMXC__ServiceMax_Tags__c TranslatedTag {get; set;}
        public TagWrapper(String TagKey, String TagLanguage, SVMXC__ServiceMax_Tags__c SVMXMasterTag, SVMXC__ServiceMax_Tags__c TranslatedTag)
        {
            this.TagKey = TagKey;
            this.TagLanguage = TagLanguage;
            this.SVMXMasterTag = SVMXMasterTag;
            this.TranslatedTag = TranslatedTag;
        }
    }
    public class TranslationWrapper
    {
        public Set<String> setTranslationKeys {get; set;}
        public List<SVMXC__ServiceMax_Processes__c> lstSVMXProcesses {get; set;}
        public TranslationWrapper(Set<String> setTranslationKeys, List<SVMXC__ServiceMax_Processes__c> lstSVMXProcesses)
        {
            this.setTranslationKeys = setTranslationKeys;
            this.lstSVMXProcesses = lstSVMXProcesses;
        }
    }
    
    /** Constructor **/
    public CONF_ManageTranslations()
    {
        lstRecordType = new List<String>{'Target Manager', 'Wizard', 'Inventory Process'};
        selectedLanguage = UserInfo.getLanguage();
        isRenderTranslationBlock = false;
        isRenderProcesses = true;
        selectedProcess = 'All';
        selectedProType = 'All';
        isRenderPOPUP = false;
        preparingPicklist();
        QueryTranslationData();
        performSearch();
    }
    
     /** Update picklist bu querying translation data **/
    public void QueryTranslationData()
    {
        List<SVMXC__ServiceMax_Processes__c> lstSVMXProcesses = new List<SVMXC__ServiceMax_Processes__c>();
        lstSVMXProcesses = getAllProcessTranslations().lstSVMXProcesses;
        lstSOProcesses = new List<selectOption>();
        lstSOProcesses.add(new selectOption('All', getTAG007()));
        
        List<selectOption> lstTempSO = new List<selectOption>();
        if(lstSVMXProcesses != NULL && lstSVMXProcesses.size() != 0 && lstSVMXProcesses.size() <= 1000){
            for(SVMXC__ServiceMax_Processes__c pro : lstSVMXProcesses){
                lstTempSO.add(new selectOption(pro.Id, pro.SVMXC__Name__c.escapeHtml4()));// BAC-4055 Security Fix for XSS volubility 
                }
        }
        else if(lstSVMXProcesses.size() > 1000){
            for(Integer k=0; k<1000; k++)
                lstTempSO.add(new selectOption(lstSVMXProcesses[k].Id, lstSVMXProcesses[k].SVMXC__Name__c.escapeHtml4()));// BAC-4055 Security Fix for XSS volubility 
        }
        lstTempSO = sortingSelectOption(lstTempSO);
        lstSOProcesses.addAll(lstTempSO);
    }
    
    /** Update picklists **/
    public void preparingPicklist(){
        lstSOProcessType = new List<selectOption>();
        lstSOProcessType.add(new selectOption('All', getTAG007()));
        lstSOProcessType.add(new selectOption('SFM', getTAG008()));
        lstSOProcessType.add(new selectOption('SFW', getTAG009()));
        lstSOProcessType.add(new selectOption('SFM_Search', getTAG010()));
        lstSOProcessType.add(new selectOption('Inventory_Process', getTAG011()));
        lstSOProcessType.add(new selectOption('Checklist_Process', getTAG050())); //Added by Manish for supporting checklist translation
        
        lstSOLanguage = new List<selectOption>();
        for(Schema.PicklistEntry currLanguage : User.LanguageLocaleKey.getDescribe().getPicklistValues())
            lstSOLanguage.add(new selectOption(currLanguage.getValue(), currLanguage.getLabel()));
        lstSOLanguage = sortingSelectOption(lstSOLanguage);
    }
    
    /** Perform Search functionality **/
    public PageReference performSearch()
    {
        if(selectedLanguage != NULL && selectedLanguage.length() > 0 && selectedLanguage != 'SVMX.None')
        {
            isRenderTranslationBlock = true;
            if(strSearchKeyword != NULL && strSearchKeyword.length() > 0)
            {
                if(selectedProType == 'All'){
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapBasedOnSrchKwrd(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage, strSearchKeyword);
                    else
                        updateTranslatedTagWrapBasedOnSrchKwrd(getAllProcessTranslations().setTranslationKeys, selectedLanguage, strSearchKeyword);
                }
                else if(selectedProType == 'SFM'){
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapBasedOnSrchKwrd(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage, strSearchKeyword);
                    else
                        updateTranslatedTagWrapBasedOnSrchKwrd(getSFMTranxTranslation().setTranslationKeys, selectedLanguage, strSearchKeyword);
                }
                else if(selectedProType == 'SFW'){
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapBasedOnSrchKwrd(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage, strSearchKeyword);
                    else
                        updateTranslatedTagWrapBasedOnSrchKwrd(getSFMWizardTranslation().setTranslationKeys, selectedLanguage, strSearchKeyword);
                }
                else if(selectedProType == 'SFM_Search'){
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapBasedOnSrchKwrd(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage, strSearchKeyword);
                    else
                        updateTranslatedTagWrapBasedOnSrchKwrd(getSFMSearchTranslation().setTranslationKeys, selectedLanguage, strSearchKeyword);
                }
                else if(selectedProType == 'Inventory_Process')
                {
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapBasedOnSrchKwrd(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage, strSearchKeyword);
                    else
                        updateTranslatedTagWrapBasedOnSrchKwrd(getINVTProTranslation().setTranslationKeys, selectedLanguage, strSearchKeyword);
                }
                else if(selectedProType == 'Checklist_Process')//Added by Manish for supporting checklist translation
                {
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapBasedOnSrchKwrd(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage, strSearchKeyword);
                    else
                        updateTranslatedTagWrapBasedOnSrchKwrd(getSFMChecklistTranslation().setTranslationKeys, selectedLanguage, strSearchKeyword);
                }
            }
            else
            {
                if(selectedProType == 'All'){
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapList(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage);
                    else
                        updateTranslatedTagWrapList(getAllProcessTranslations().setTranslationKeys, selectedLanguage);
                }
                else if(selectedProType == 'SFM'){
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapList(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage);
                    else
                        updateTranslatedTagWrapList(getSFMTranxTranslation().setTranslationKeys, selectedLanguage);
                }
                else if(selectedProType == 'SFW'){
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapList(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage);
                    else
                        updateTranslatedTagWrapList(getSFMWizardTranslation().setTranslationKeys, selectedLanguage);
                }
                else if(selectedProType == 'SFM_Search'){
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapList(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage);
                    else
                        updateTranslatedTagWrapList(getSFMSearchTranslation().setTranslationKeys, selectedLanguage);
                }
                else if(selectedProType == 'Inventory_Process'){
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapList(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage);
                    else
                        updateTranslatedTagWrapList(getINVTProTranslation().setTranslationKeys, selectedLanguage);
                }
                else if(selectedProType == 'Checklist_Process'){//Added by Manish for supporting checklist translation
                    if(selectedProcess != 'All')
                        updateTranslatedTagWrapList(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage);
                    else
                        updateTranslatedTagWrapList(getSFMChecklistTranslation().setTranslationKeys, selectedLanguage);
                }
            }
        }
        return NULL;
    }
    
    /** Back to Setup Home method **/
    public PageReference BackToSetupHome(){
        //return new PageReference('/apex/SVMXC__CONF_SetupHome');
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        PageReference HomePage = new PageReference(url);
        HomePage.setRedirect(true);
        return HomePage;
        //Changes done by Nidhi ends here
    }
    
    /** On Process Type Change Method **/
    public void onChngProcessType(){
        strSearchKeyword = '';
        isRenderProcesses = true;
        isRenderTranslationBlock = false;
        Set<String> setTranslationKeys = new Set<String>();
        List<SVMXC__ServiceMax_Processes__c> lstProcesses = new List<SVMXC__ServiceMax_Processes__c>();
        
        if(selectedProType == 'All'){
            TranslationWrapper objTranslationWrapper = getAllProcessTranslations();
            setTranslationKeys = objTranslationWrapper.setTranslationKeys;
            lstProcesses = objTranslationWrapper.lstSVMXProcesses;
        }
        else if(selectedProType == 'SFM'){
            TranslationWrapper objTranslationWrapper = getSFMTranxTranslation();
            setTranslationKeys = objTranslationWrapper.setTranslationKeys;
            lstProcesses = objTranslationWrapper.lstSVMXProcesses;
        }
        else if(selectedProType == 'SFW'){
            TranslationWrapper objTranslationWrapper = getSFMWizardTranslation();
            setTranslationKeys = objTranslationWrapper.setTranslationKeys;
            lstProcesses = objTranslationWrapper.lstSVMXProcesses;
        }
        else if(selectedProType == 'SFM_Search'){
            TranslationWrapper objTranslationWrapper = getSFMSearchTranslation();
            setTranslationKeys = objTranslationWrapper.setTranslationKeys;
            lstProcesses = objTranslationWrapper.lstSVMXProcesses;
        }
        else if(selectedProType == 'Inventory_Process'){
            TranslationWrapper objTranslationWrapper = getINVTProTranslation();
            setTranslationKeys = objTranslationWrapper.setTranslationKeys;
            lstProcesses = objTranslationWrapper.lstSVMXProcesses;
        }
        else if(selectedProType == 'Checklist_Process'){//Added by Manish for supporting checklist translation
            TranslationWrapper objTranslationWrapper = getSFMChecklistTranslation();
            setTranslationKeys = objTranslationWrapper.setTranslationKeys;
            lstProcesses = objTranslationWrapper.lstSVMXProcesses;
        }
        
        lstSOProcesses.clear();
        lstSOProcesses.add(new selectOption('All', getTAG007()));
        
        List<selectOption> lstTempSO = new List<selectOption>();
        if(lstProcesses != NULL && lstProcesses.size() != 0 && lstProcesses.size() <= 1000){
            for(SVMXC__ServiceMax_Processes__c pro : lstProcesses)
                lstTempSO.add(new selectOption(pro.Id, pro.SVMXC__Name__c));
        }
        else if(lstProcesses.size() > 1000){
            for(Integer k=0; k<1000; k++)
                lstTempSO.add(new selectOption(lstProcesses[k].Id, lstProcesses[k].SVMXC__Name__c));
        }
        lstTempSO = sortingSelectOption(lstTempSO);
        lstSOProcesses.addAll(lstTempSO);
        updateTranslatedTagWrapList(setTranslationKeys, selectedLanguage);
        selectedProcess = 'All';
    }
    
    /** On Process Change Method **/
    public void onChngProcess(){
        strSearchKeyword = '';
        isRenderTranslationBlock = false;
        if(selectedProcess != 'All'){
            isRenderTranslationBlock = true;
            updateTranslatedTagWrapList(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage);
        }
        else{
            Set<String> setTranslationKeys = new Set<String>();
            List<SVMXC__ServiceMax_Processes__c> lstProcesses = new List<SVMXC__ServiceMax_Processes__c>();
            if(selectedProType == 'All'){
                TranslationWrapper objTranslationWrapper = getAllProcessTranslations();
                setTranslationKeys = objTranslationWrapper.setTranslationKeys;
                lstProcesses = objTranslationWrapper.lstSVMXProcesses;
            }
            else if(selectedProType == 'SFM'){
                TranslationWrapper objTranslationWrapper = getSFMTranxTranslation();
                setTranslationKeys = objTranslationWrapper.setTranslationKeys;
                lstProcesses = objTranslationWrapper.lstSVMXProcesses;
            }
            else if(selectedProType == 'SFW'){
                TranslationWrapper objTranslationWrapper = getSFMWizardTranslation();
                setTranslationKeys = objTranslationWrapper.setTranslationKeys;
                lstProcesses = objTranslationWrapper.lstSVMXProcesses;
            }
            else if(selectedProType == 'SFM_Search'){
                TranslationWrapper objTranslationWrapper = getSFMSearchTranslation();
                setTranslationKeys = objTranslationWrapper.setTranslationKeys;
                lstProcesses = objTranslationWrapper.lstSVMXProcesses;
            }
            else if(selectedProType == 'Inventory_Process'){
                TranslationWrapper objTranslationWrapper = getINVTProTranslation();
                setTranslationKeys = objTranslationWrapper.setTranslationKeys;
                lstProcesses = objTranslationWrapper.lstSVMXProcesses;
            }
            else if(selectedProType == 'Checklist_Process'){//Added by Manish for supporting checklist translation
                TranslationWrapper objTranslationWrapper = getSFMChecklistTranslation();
                setTranslationKeys = objTranslationWrapper.setTranslationKeys;
                lstProcesses = objTranslationWrapper.lstSVMXProcesses;
            }
            lstSOProcesses.clear();
            lstSOProcesses.add(new selectOption('All', getTAG007()));
            List<selectOption> lstTempSO = new List<selectOption>();
            if(lstProcesses != NULL && lstProcesses.size() != 0 && lstProcesses.size() <= 1000){
                for(SVMXC__ServiceMax_Processes__c pro : lstProcesses)
                    lstTempSO.add(new selectOption(pro.Id, pro.SVMXC__Name__c));
            }
            else if(lstProcesses.size() > 1000){
                for(Integer k=0; k<1000; k++)
                    lstTempSO.add(new selectOption(lstProcesses[k].Id, lstProcesses[k].SVMXC__Name__c));
            }
            lstTempSO = sortingSelectOption(lstTempSO);
            lstSOProcesses.addAll(lstTempSO);
            updateTranslatedTagWrapList(setTranslationKeys, selectedLanguage);
        }
    }
    
    public List<TagWrapper> prepareTagWrapper(Map<String, SVMXC__ServiceMax_Tags__c> mapSelectedLangTags, Map<String, SVMXC__ServiceMax_Tags__c> mapSVMXMasterTags){
        List<TagWrapper> lstTagsWrapper = new List<TagWrapper>();
        for(String TagKey : mapSVMXMasterTags.keyset()){
            if(mapSVMXMasterTags.containsKey(TagKey) && mapSVMXMasterTags.get(TagKey) != NULL){
                SVMXC__ServiceMax_Tags__c Tag = mapSelectedLangTags.get(TagKey) != NULL ? mapSelectedLangTags.get(TagKey) : new SVMXC__ServiceMax_Tags__c();
                if(mapSVMXMasterTags.get(TagKey).SVMXC__Tag_Context__c != NULL && mapSVMXMasterTags.get(TagKey).SVMXC__Tag_Context__c.length() > 0)
                    //mapSVMXMasterTags.get(TagKey).SVMXC__Tag_Context__c = mapSVMXMasterTags.get(TagKey).SVMXC__Tag_Context__c.replace('INVENTORY_PROCESS_TITLE', System.Label.CONF004_TAG023).replace('INVENTORY_PROCESS_DESCRIPTION', System.Label.CONF004_TAG024).replace('HEADER_ERROR_MESSAGE', System.Label.CONF004_TAG025).replace('DETAIL_ERROR_MESSAGE', System.Label.CONF004_TAG026).replace('SFM_SEARCH_NAME', System.Label.CONF004_TAG027).replace('SFM_SEARCH_DESCRIPTION', System.Label.CONF004_TAG028).replace('SEARCH_RESULT_SECTION_TITLE', System.Label.CONF004_TAG029).replace('SEARCH_RESULT_SECTION_DESCRIPTION', System.Label.CONF004_TAG030).replace('WIZARD_NAME', System.Label.CONF004_TAG031).replace('WIZARD_DESCRIPTION', System.Label.CONF004_TAG032).replace('WIZARD_STEP_NAME', System.Label.CONF004_TAG033).replace('WIZARD_STEP_DESCRIPTION', System.Label.CONF004_TAG034).replace('WIZARD_STEP_CONFIRMATION_MESSAGE', System.Label.CONF004_TAG035).replace('SFM_PROCESS_NAME', System.Label.CONF004_TAG036).replace('SFM_PROCESS_DESCRIPTION', System.Label.CONF004_TAG037).replace('SFM_SECTION_TITLE', System.Label.CONF004_TAG038).replace('SFM_PAGE_HELP', System.Label.CONF004_TAG039).replace('SFM_BUTTON_TITLE', System.Label.CONF004_TAG040).replace('DATA_VALIDATION_RULE_MESSAGE', System.Label.CONF004_TAG041).replace('TARGET_NAME', '').replace('LINKED_PROCESS_TITLE', getTAG049());
                    
                    //Added by Manish for supporting checklist translation
                    //mapSVMXMasterTags.get(TagKey).SVMXC__Tag_Context__c = mapSVMXMasterTags.get(TagKey).SVMXC__Tag_Context__c.replace('INVENTORY_PROCESS_TITLE', System.Label.CONF004_TAG023).replace('INVENTORY_PROCESS_DESCRIPTION', System.Label.CONF004_TAG024).replace('HEADER_ERROR_MESSAGE', System.Label.CONF004_TAG025).replace('DETAIL_ERROR_MESSAGE', System.Label.CONF004_TAG026).replace('SFM_SEARCH_NAME', System.Label.CONF004_TAG027).replace('SFM_SEARCH_DESCRIPTION', System.Label.CONF004_TAG028).replace('SEARCH_RESULT_SECTION_TITLE', System.Label.CONF004_TAG029).replace('SEARCH_RESULT_SECTION_DESCRIPTION', System.Label.CONF004_TAG030).replace('WIZARD_NAME', System.Label.CONF004_TAG031).replace('WIZARD_DESCRIPTION', System.Label.CONF004_TAG032).replace('WIZARD_STEP_NAME', System.Label.CONF004_TAG033).replace('WIZARD_STEP_DESCRIPTION', System.Label.CONF004_TAG034).replace('WIZARD_STEP_CONFIRMATION_MESSAGE', System.Label.CONF004_TAG035).replace('SFM_PROCESS_NAME', System.Label.CONF004_TAG036).replace('SFM_PROCESS_DESCRIPTION', System.Label.CONF004_TAG037).replace('SFM_SECTION_TITLE', System.Label.CONF004_TAG038).replace('SFM_PAGE_HELP', System.Label.CONF004_TAG039).replace('SFM_BUTTON_TITLE', System.Label.CONF004_TAG040).replace('DATA_VALIDATION_RULE_MESSAGE', System.Label.CONF004_TAG041).replace('TARGET_NAME', '').replace('LINKED_PROCESS_TITLE', getTAG049()).replace('SFM_QUESTION_TEXT', getTAG051()).replace('SFM_RESPONSE_TEXT', getTAG052());
                    mapSVMXMasterTags.get(TagKey).SVMXC__Tag_Context__c = mapSVMXMasterTags.get(TagKey).SVMXC__Tag_Context__c.replace('INVENTORY_PROCESS_TITLE', System.Label.CONF004_TAG023).replace('INVENTORY_PROCESS_DESCRIPTION', System.Label.CONF004_TAG024).replace('HEADER_ERROR_MESSAGE', System.Label.CONF004_TAG025).replace('DETAIL_ERROR_MESSAGE', System.Label.CONF004_TAG026).replace('SFM_SEARCH_NAME', System.Label.CONF004_TAG027).replace('SFM_SEARCH_DESCRIPTION', System.Label.CONF004_TAG028).replace('SEARCH_RESULT_SECTION_TITLE', System.Label.CONF004_TAG029).replace('SEARCH_RESULT_SECTION_DESCRIPTION', System.Label.CONF004_TAG030).replace('WIZARD_NAME', System.Label.CONF004_TAG031).replace('WIZARD_DESCRIPTION', System.Label.CONF004_TAG032).replace('WIZARD_STEP_NAME', System.Label.CONF004_TAG033).replace('WIZARD_STEP_DESCRIPTION', System.Label.CONF004_TAG034).replace('WIZARD_STEP_CONFIRMATION_MESSAGE', System.Label.CONF004_TAG035).replace('SFM_PROCESS_NAME', System.Label.CONF004_TAG036).replace('SFM_PROCESS_DESCRIPTION', System.Label.CONF004_TAG037).replace('SFM_SECTION_TITLE', System.Label.CONF004_TAG038).replace('SFM_PAGE_HELP', System.Label.CONF004_TAG039).replace('SFM_BUTTON_TITLE', System.Label.CONF004_TAG040).replace('DATA_VALIDATION_RULE_MESSAGE', System.Label.CONF004_TAG041).replace('TARGET_NAME', '').replace('LINKED_PROCESS_TITLE', getTAG049()).replace('SFM_QUESTION_TEXT', getTAG051()).replace('SFM_RESPONSE_TEXT', getTAG052()).replace('SFM_RESPONSE_DEFAULT_ANSWER',getTAG053());
                lstTagsWrapper.add(new TagWrapper(TagKey, selectedLanguage, mapSVMXMasterTags.get(TagKey), Tag));
            }
        }
        return lstTagsWrapper;
    }
    
    /** On Language Change Method **/
    public void onChngLanguage(){
        try{
            if(selectedLanguage != 'SVMX.None'){
                strSearchKeyword = '';
                if(selectedProcess == 'All')
                    updateTranslatedTagWrapList(getAllProcessTranslations().setTranslationKeys, selectedLanguage);
                else
                    updateTranslatedTagWrapList(getSpecificProcessTranslation(selectedProcess).setTranslationKeys, selectedLanguage);
            }
        }
        catch(exception ex){
            system.debug(LoggingLevel.Warn, 'Error: ' + ex.getMessage());
        }
    }
    
    /** Save Method **/
    public PageReference saveTranslations(){
        Set<String> setExistingTagKeys = new Set<String>();
        List<SVMXC__ServiceMax_Tags__c> lstSVMXTagsToSave = new List<SVMXC__ServiceMax_Tags__c>();
        List<SVMXC__ServiceMax_Tags__c> lstSVMXTagsToDelete = new List<SVMXC__ServiceMax_Tags__c>();
        system.debug(LoggingLevel.Warn, 'Selected Language: ' + selectedLanguage + '; Size: '+ lstTagsWrapper.size() +'; records: ' + lstTagsWrapper);
        
        try{
            if(lstTagsWrapper != NULL && lstTagsWrapper.size() > 0){
                for(TagWrapper tgwrpr: lstTagsWrapper){
                    SVMXC__ServiceMax_Tags__c SVMXTag = new SVMXC__ServiceMax_Tags__c();
                    SVMXTag.SVMXC__Tag_Value__c = tgwrpr.TranslatedTag.SVMXC__Tag_Value__c;
                    if(SVMXTag != NULL && SVMXTag.SVMXC__Tag_Value__c != NULL && SVMXTag.SVMXC__Tag_Value__c.length() > 0){
                        setExistingTagKeys.add(tgwrpr.SVMXMasterTag.SVMXC__Tag_Key__c);
                        SVMXTag.SVMXC__Tag_Key__c = tgwrpr.SVMXMasterTag.SVMXC__Tag_Key__c;
                        SVMXTag.SVMXC__Tag_Context__c = tgwrpr.SVMXMasterTag.SVMXC__Tag_Context__c;
                        SVMXTag.SVMXC__Language__c = selectedLanguage;
                        lstSVMXTagsToSave.add(SVMXTag);
                    }else if(tgwrpr.TranslatedTag.Id != NULL && String.valueOf(tgwrpr.TranslatedTag.Id).length() > 0){
                        system.debug(LoggingLevel.Warn, 'Current tag to be deleted: ' + tgwrpr.TranslatedTag);
                        setExistingTagKeys.add(tgwrpr.SVMXMasterTag.SVMXC__Tag_Key__c);
                    }
                }
                if(setExistingTagKeys != NULL && setExistingTagKeys.size() > 0){
                    if(setExistingTagKeys.contains(NULL))
                        setExistingTagKeys.remove(NULL);
                    lstSVMXTagsToDelete = [Select Id from SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN: setExistingTagKeys AND SVMXC__Language__c =: selectedLanguage]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    system.debug(LoggingLevel.Warn, 'lstSVMXTagsToDelete: ' + lstSVMXTagsToDelete.size() + ', List: ' + lstSVMXTagsToDelete);
                    if(lstSVMXTagsToDelete != NULL && lstSVMXTagsToDelete.size() > 0){
                        //delete lstSVMXTagsToDelete;
                        if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Tags__c')){
                            delete lstSVMXTagsToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                        }
                        else{
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                            return null;
                        }
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG017()));
                    }
                }
                system.debug(LoggingLevel.Warn, 'lstSVMXTagsToSave: ' + lstSVMXTagsToSave.size() +', list: ' + lstSVMXTagsToSave);
                if(lstSVMXTagsToSave != NULL && lstSVMXTagsToSave.size() > 0){
                    //insert lstSVMXTagsToSave;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSVMXTagsToSave, COMM_SecurityUtils.Access.Createable)){
                        insert lstSVMXTagsToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG017())); 
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    }
                }
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
        }
        return NULL;
    }
    
    /** Method to set IsOverwrite boolean true on click of YES in the popup **/
    public void POPUP_YES(){
        isRenderPOPUP = false;
        IsOverWrite = true;
        copyMasterTranslation();
    }
    
    /** Method to set IsOverwrite boolean false on click of NO in the popup **/
    public void POPUP_NO(){
        isRenderPOPUP = false;
        IsOverWrite = false;
        copyMasterTranslation();
    }
    
    /** Method to cancel popup **/
    public void POPUP_CANCEL(){
        isRenderPOPUP = false;
    }
    
    /** Method to Copy master translation **/
    public void copyMasterTranslation(){
        if(lstTagsWrapper != NULL && lstTagsWrapper.size() > 0){
            for(TagWrapper tgwrpr : lstTagsWrapper){
                if(IsOverWrite){
                    tgwrpr.TranslatedTag = new SVMXC__ServiceMax_Tags__c(SVMXC__Tag_Key__c = tgwrpr.SVMXMasterTag.SVMXC__Tag_Key__c, SVMXC__Language__c = selectedLanguage, SVMXC__Tag_Context__c = tgwrpr.SVMXMasterTag.SVMXC__Tag_Context__c, SVMXC__Tag_Value__c = tgwrpr.SVMXMasterTag.SVMXC__Tag_Value__c);
                }
                else if(tgwrpr.TranslatedTag.SVMXC__Tag_Value__c == NULL || tgwrpr.TranslatedTag.SVMXC__Tag_Value__c == ''){
                    tgwrpr.TranslatedTag = new SVMXC__ServiceMax_Tags__c(SVMXC__Tag_Key__c = tgwrpr.SVMXMasterTag.SVMXC__Tag_Key__c, SVMXC__Language__c = selectedLanguage, SVMXC__Tag_Context__c = tgwrpr.SVMXMasterTag.SVMXC__Tag_Context__c, SVMXC__Tag_Value__c = tgwrpr.SVMXMasterTag.SVMXC__Tag_Value__c);
                }
            }
        }
    }
    
    /** Reset Method **/
    public void resetText(){
        onChngLanguage();
    }
    
    /** Selectoption sorting Method **/
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList){
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String, List<SelectOption>> tempLst = new Map<String, List<SelectOption>>();
        for(SelectOption SO : sortList){
            tempLst.put(SO.getLabel(), new List<SelectOption>());
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key : keys)
            resultList.addAll(tempLst.get(key));
        return resultList;
    }
    
    private TranslationWrapper getAllProcessTranslations(){
        Set<String> setTranslationKeys = new Set<String>();
        List<SVMXC__ServiceMax_Processes__c> lstSVMXProToTranslate = new List<SVMXC__ServiceMax_Processes__c>();
        lstSVMXProToTranslate = [Select SVMXC__Tag_Keys__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c Where (SVMXC__Record_Type_Name__c IN: lstRecordType OR (SVMXC__Record_Type_Name__c = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH'))];
        system.debug(LoggingLevel.Warn, 'List of Translatable Processes: ' + lstSVMXProToTranslate + ', Size: ' + lstSVMXProToTranslate.size());
        return new TranslationWrapper(getTranslationsKeys(lstSVMXProToTranslate), lstSVMXProToTranslate);
    }
    
    private TranslationWrapper getSpecificProcessTranslation(String selectedProcess){
        Set<String> setTranslationKeys = new Set<String>();
        List<SVMXC__ServiceMax_Processes__c> lstSVMXProToTranslate = new List<SVMXC__ServiceMax_Processes__c>();
        lstSVMXProToTranslate = [Select Id, SVMXC__Tag_Keys__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where Id =: selectedProcess AND (SVMXC__Record_Type_Name__c IN: lstRecordType OR (SVMXC__Record_Type_Name__c = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH'))]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug(LoggingLevel.Warn, 'List of Translatable Processes: ' + lstSVMXProToTranslate + ', Size: ' + lstSVMXProToTranslate.size());
        return new TranslationWrapper(getTranslationsKeys(lstSVMXProToTranslate), lstSVMXProToTranslate);
    }
    
    private TranslationWrapper getSFMSearchTranslation(){
        List<SVMXC__ServiceMax_Processes__c> lstSFMSearches = new List<SVMXC__ServiceMax_Processes__c>();
        lstSFMSearches = [Select SVMXC__Tag_Keys__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Record_Type_Name__c = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH'];
        system.debug(LoggingLevel.Warn, 'List of Processes: ' + lstSFMSearches + ', Size: ' + lstSFMSearches.size());
        return new TranslationWrapper(getTranslationsKeys(lstSFMSearches), lstSFMSearches);
    }
    
    private TranslationWrapper getSFMWizardTranslation(){
        List<SVMXC__ServiceMax_Processes__c> lstSFMWizards = new List<SVMXC__ServiceMax_Processes__c>();
        lstSFMWizards = [Select SVMXC__Tag_Keys__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Record_Type_Name__c = 'Wizard'];
        system.debug(LoggingLevel.Warn, 'List of Processes: ' + lstSFMWizards + ', Size: ' + lstSFMWizards.size());
        return new TranslationWrapper(getTranslationsKeys(lstSFMWizards), lstSFMWizards);
    }
    
    private TranslationWrapper getSFMTranxTranslation(){
        List<SVMXC__ServiceMax_Processes__c> lstSFMTrans = new List<SVMXC__ServiceMax_Processes__c>();
        //lstSFMTrans = [Select SVMXC__Tag_Keys__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Record_Type_Name__c = 'Target Manager'];
        //Added by Manish for supporting checklist translation
        lstSFMTrans = [Select SVMXC__Tag_Keys__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Record_Type_Name__c = 'Target Manager' AND SVMXC__Purpose__c != 'CHECKLIST'];
        system.debug(LoggingLevel.Warn, 'List of Translatable Processes: ' + lstSFMTrans + ', Size: ' + lstSFMTrans.size());
        return new TranslationWrapper(getTranslationsKeys(lstSFMTrans), lstSFMTrans);
    }
    
    //Added by Manish for supporting checklist translation
    private TranslationWrapper getSFMChecklistTranslation(){
        List<SVMXC__ServiceMax_Processes__c> lstSFMChecklist = new List<SVMXC__ServiceMax_Processes__c>();
        lstSFMChecklist = [Select SVMXC__Tag_Keys__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Record_Type_Name__c = 'Target Manager' AND SVMXC__Purpose__c = 'CHECKLIST'];
        System.debug(LoggingLevel.Warn, 'List of Checklist Translatable Processes: ' + lstSFMChecklist + ', Size: ' + lstSFMChecklist.size());
        return new TranslationWrapper(getTranslationsKeys(lstSFMChecklist), lstSFMChecklist);
    }
    
    private TranslationWrapper getINVTProTranslation(){
        List<SVMXC__ServiceMax_Processes__c> lstINVTProcesses = new List<SVMXC__ServiceMax_Processes__c>();
        lstINVTProcesses = [Select SVMXC__Tag_Keys__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Record_Type_Name__c = 'Inventory Process'];
        system.debug(LoggingLevel.Warn, 'List of Translatable Processes: ' + lstINVTProcesses + ', Size: ' + lstINVTProcesses.size());
        return new TranslationWrapper(getTranslationsKeys(lstINVTProcesses), lstINVTProcesses);
    }
    
    private Set<String> getTranslationsKeys(List<SVMXC__ServiceMax_Processes__c> Processes){
        Set<String> setTranslationKeys = new Set<String>();
        for(SVMXC__ServiceMax_Processes__c Process : Processes)
            if(Process.SVMXC__Tag_Keys__c != NULL && Process.SVMXC__Tag_Keys__c.length() > 0)
                setTranslationKeys.addAll(Process.SVMXC__Tag_Keys__c.split(';'));
        system.debug(LoggingLevel.Warn, 'Keys: ' + setTranslationKeys + ', Size: ' + setTranslationKeys.size());
        return setTranslationKeys;
    }
    
    private void updateTranslatedTagWrapList(Set<String> setTranslationKeys, String Language){
        Map<String, SVMXC__ServiceMax_Tags__c> mapMasterLanguageTags = new Map<String, SVMXC__ServiceMax_Tags__c>();
        Map<String, SVMXC__ServiceMax_Tags__c> mapSelectedLanguageTags = new Map<String, SVMXC__ServiceMax_Tags__c>();
        for(SVMXC__ServiceMax_Tags__c Tag : [Select SVMXC__Tag_Key__c, SVMXC__Tag_Text__c, SVMXC__Tag_Value__c, SVMXC__Tag_Context__c, SVMXC__Language__c from SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN: setTranslationKeys AND SVMXC__Language__c = 'Master' Limit 1000])
            mapMasterLanguageTags.put(Tag.SVMXC__Tag_Key__c, Tag);
        for(SVMXC__ServiceMax_Tags__c Tag : [Select SVMXC__Tag_Key__c, SVMXC__Tag_Text__c, SVMXC__Tag_Value__c, SVMXC__Tag_Context__c, SVMXC__Language__c from SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN: setTranslationKeys AND SVMXC__Language__c =: Language  Limit 1000])
            mapSelectedLanguageTags.put(Tag.SVMXC__Tag_Key__c, Tag);
        lstTagsWrapper = prepareTagWrapper(mapSelectedLanguageTags, mapMasterLanguageTags); 
    }
    
    private void updateTranslatedTagWrapBasedOnSrchKwrd(Set<String> setTranslationKeys, String Language, String strKeyWord){
        Map<String, SVMXC__ServiceMax_Tags__c> mapMasterLanguageTags = new Map<String, SVMXC__ServiceMax_Tags__c>();
        Map<String, SVMXC__ServiceMax_Tags__c> mapSelectedLanguageTags = new Map<String, SVMXC__ServiceMax_Tags__c>();
        Set<String> setSearchResultKeys = new Set<String>();
        for(SVMXC__ServiceMax_Tags__c Tag : [Select SVMXC__Tag_Key__c, SVMXC__Tag_Text__c, SVMXC__Tag_Value__c, SVMXC__Tag_Context__c, SVMXC__Language__c from SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN: setTranslationKeys AND SVMXC__Tag_Text__c LIKE: '%'+ String.escapeSingleQuotes(strKeyWord) + '%' AND SVMXC__Language__c = 'Master' Limit 1000]){
            mapMasterLanguageTags.put(Tag.SVMXC__Tag_Key__c, Tag);
            setSearchResultKeys.add(Tag.SVMXC__Tag_Key__c);
        }
        if(setSearchResultKeys != null && setSearchResultKeys.size() > 0){
            for(SVMXC__ServiceMax_Tags__c Tag : [Select SVMXC__Tag_Key__c, SVMXC__Tag_Text__c, SVMXC__Tag_Value__c, SVMXC__Tag_Context__c, SVMXC__Language__c from SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN: setSearchResultKeys AND SVMXC__Language__c =: selectedLanguage  Limit 1000])
            mapSelectedLanguageTags.put(Tag.SVMXC__Tag_Key__c, Tag);
        }
        lstTagsWrapper = prepareTagWrapper(mapSelectedLanguageTags, mapMasterLanguageTags); 
    }
    
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
    public String getHLPURL(){return System.Label.CONF004_HLPURL;} //'Help URL'
    public String getTAG001(){return System.Label.CONF004_TAG001;} //'Manage Translations'
    public String getTAG002(){return System.Label.CONF004_TAG002;} //'Back To Setup Home'
    public String getTAG003(){return System.Label.CONF004_TAG004;}//'Process Type'
    public String getTAG004(){return System.Label.CONF004_TAG008;} //'Master Text'
    public String getTAG005(){return System.Label.CONF004_TAG009;} //'Text'
    public String getTAG006(){return System.Label.CONF004_TAG003;} //Language
    public String getTAG007(){return System.Label.COMM001_TAG105;} //'All'
    public String getTAG008(){return System.Label.CONF004_TAG019;} //'SFM Process'
    public String getTAG009(){return System.Label.CONF004_TAG020;} //'SFM Wizard'
    public String getTAG010(){return System.Label.CONF004_TAG021;}//'SFM Search'
    public String getTAG011(){return System.Label.CONF004_TAG022;}//'Inventory Process'
    public String getTAG012(){return System.Label.CONF004_TAG014;} //'Processing...'
    public String getTAG013(){return System.Label.CONF004_TAG010;} //'--None--'
    public String getTAG014(){return System.Label.CONF004_TAG007;} //'Save'
    public String getTAG015(){return System.Label.CONF004_TAG015;} //'Copy Master Text'
    public String getTAG016(){return System.Label.CONF004_TAG016;} //'Reset'
    public String getTAG017(){return System.Label.COMM001_TAG058;} //'Record(s) saved successfully.'
    public String getTAG018(){return System.Label.CONF004_TAG005;}//'Process to be Translated'
    public String getTAG019(){return System.Label.CONF004_TAG043;}//'Enter Keyword to Filter...'
    public String getTAG020(){return System.Label.CONF004_TAG017;}//'Keyword to Search...'
    public String getTAG021(){return System.Label.CONF004_TAG011;} //' Get Translations'
    public String getTAG022(){return System.Label.CONF004_TAG006;}//'Are you sure to overwrite'
    public String getTAG023(){return System.Label.COMM001_TAG119;} //'Yes'
    public String getTAG024(){return System.Label.COMM001_TAG120;} //'No'
    public String getTAG025(){return System.Label.COMM001_TAG040;} //'Cancel'
    public String getTAG026(){return System.Label.CONF004_TAG018;} //'Context'
    public String getTAG029(){return System.Label.CONF004_TAG023;} //'Inventory Process Title'
    public String getTAG030(){return System.Label.CONF004_TAG024;} //'Inventory Process Description'
    public String getTAG031(){return System.Label.CONF004_TAG025;} //'Header Error Message'
    public String getTAG032(){return System.Label.CONF004_TAG026;} //'Detail Error Message'
    public String getTAG033(){return System.Label.CONF004_TAG027;} //'SFM Search Name'
    public String getTAG034(){return System.Label.CONF004_TAG028;} //'SFM Search Description'
    public String getTAG035(){return System.Label.CONF004_TAG029;} //'Searchable Object Name'
    public String getTAG036(){return System.Label.CONF004_TAG030;} //'Searchable Object Description'
    public String getTAG037(){return System.Label.CONF004_TAG031;} //'SFM Wizard Name'
    public String getTAG038(){return System.Label.CONF004_TAG032;} //'SFM Wizard Description'
    public String getTAG039(){return System.Label.CONF004_TAG033;} //'SFM Wizard Step Name'
    public String getTAG040(){return System.Label.CONF004_TAG034;} //'Wizard Step Description'
    public String getTAG041(){return System.Label.CONF004_TAG035;} //'Wizard Step Confirmation Message'
    public String getTAG042(){return System.Label.CONF004_TAG036;} //'SFM Process Name'
    public String getTAG043(){return System.Label.CONF004_TAG037;} //'SFM Process Description'
    public String getTAG044(){return System.Label.CONF004_TAG038;} //'SFM Section Title'
    public String getTAG045(){return System.Label.CONF004_TAG039;} //'SFM Page Help'
    public String getTAG046(){return System.Label.CONF004_TAG040;} //'SFM Button Title'
    public String getTAG047(){return System.Label.CONF004_TAG041;} //'Data Validation Rules'
    public String getTAG048(){return System.Label.CONF004_TAG042;} //'Detail Alias Name'
    public String getTAG049(){return System.Label.CONF004_TAG012;} //'Linked SFM Title'
    
    //Added by Manish for supporting checklist translation
    public String getTAG050(){return System.Label.CONF004_TAG044;} //'SFM Checklist Process'
    public String getTAG051(){return System.Label.CONF004_TAG045;} //'SFM Question Text'
    public String getTAG052(){return System.Label.CONF004_TAG046;} //'SFM Response Text'
    public String getTAG053(){return System.Label.CONF004_TAG048;} //'SFM Default Answer' 
    /** 
    Logic to generate Translation keys for below type of Processes: 
    1) SFM Transaction Delivery 2) SFM Wizard Delivery 3) SFM Search Delivery 4) Inventory Engine Delivery 5) Checklist Type of Process
    **/
    /*public Transient Set<String> setUniqueKey = new Set<String>();
    public Transient Map<String, SVMXC__ServiceMax_Tags__c> MapServiceMaxTags = new Map<String, SVMXC__ServiceMax_Tags__c>();*/
    public void generateMasterTag(String processID)
    {
       try{
            //Get serviceMax process
            SVMXC__ServiceMax_Processes__c svmxProcess = [Select SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Description__c, SVMXC__Parent_Error_Msg__c, SVMXC__Child_Error_Msg__c, SVMXC__Record_Type_Name__c, SVMXC__Page_Layout__c, SVMXC__Tag_Keys__c, SVMXC__Module__c, SVMXC__Rule_Type__c from SVMXC__ServiceMax_Processes__c where SVMXC__IsStandard__c = false and Id =: processID];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            String processTagKey =  SVMXProcess.SVMXC__Tag_Keys__c;
            svmxProcess.SVMXC__Tag_Keys__c = '';
            //For SFM Processes 
            if(svmxProcess !=null)
            {
                if(svmxProcess.SVMXC__Record_Type_Name__c == 'Target Manager' && svmxProcess.SVMXC__Purpose__c != 'OUTPUT DOCUMENT' && SVMXProcess.SVMXC__Purpose__c != 'CHECKLIST')
                {
                   i18N_SFM_Translation(svmxProcess);  
                }
                //FOR SFW Wizard start
                if(svmxProcess.SVMXC__Record_Type_Name__c == 'Wizard')
                {
                    i18N_SFW_Translation(svmxProcess);
                }
                //SFW Wizard
                //SFM search
                if(svmxProcess.SVMXC__Record_Type_Name__c == 'Named Search' && svmxProcess.SVMXC__Rule_Type__c == 'SRCH_NAMED_SEARCH')
                {
                    i18N_Search_Translation(svmxProcess);
                }
                //SFM search
                //Inventory
                if(svmxProcess.SVMXC__Record_Type_Name__c == 'Inventory Process')
                {
                    i18N_INVT_Translation(svmxProcess);
                }
                //Invetory
                //Checklist
                if(svmxProcess.SVMXC__Record_Type_Name__c == 'Target Manager' && svmxProcess.SVMXC__Purpose__c == 'CHECKLIST')
                {
                    i18N_Checklist_Translation(svmxProcess);
                }
                //checklist
                if(processTagKey != svmxProcess.SVMXC__Tag_Keys__c)
                {
                     if(COMM_SecurityUtils.getInstance().verifyFieldAccess(svmxProcess, COMM_SecurityUtils.Access.Updateable)){
                        update svmxProcess;//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                     }
                     else
                     {
                         throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                     }   
                }
                if(lstWizardStepsSearchObjs.size() > 0)
                {
                     if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWizardStepsSearchObjs, COMM_SecurityUtils.Access.Updateable)){
                        update lstWizardStepsSearchObjs;//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                     }
                     else
                     {
                         throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                     } 
                }           
                if(mapServiceMaxTags.size()>0)
                {
                    List<SVMXC__ServiceMax_Tags__c> seviceMaxTagTagsTobeUpdated = new List<SVMXC__ServiceMax_Tags__c>();
                    List<SVMXC__ServiceMax_Tags__c> lstSeviceMaxTag = [Select SVMXC__Tag_Key__c, SVMXC__Tag_Value__c,SVMXC__Tag_Context__c from SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN: mapServiceMaxTags.keyset() AND SVMXC__Language__c = 'Master'];
                    System.debug('mapServiceMaxTags: '+mapServiceMaxTags);
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(SVMXC__ServiceMax_Tags__c seviceMaxTag : lstSeviceMaxTag )
                        {
                            System.debug('Tag key: '+seviceMaxTag.SVMXC__Tag_Key__c); 
                            SVMXC__ServiceMax_Tags__c mapTag = mapServiceMaxTags.get(seviceMaxTag.SVMXC__Tag_Key__c);
                            System.debug('mapTag: '+mapTag);
                         if(mapTag != null) 
                         {
                            boolean isSameContext = seviceMaxTag.SVMXC__Tag_Context__c == mapTag.SVMXC__Tag_Context__c;
                            boolean isSameContextContain = (seviceMaxTag.SVMXC__Tag_Context__c).contains(mapTag.SVMXC__Tag_Context__c);
                            boolean isSameValue = seviceMaxTag.SVMXC__Tag_Value__c == mapTag.SVMXC__Tag_Value__c;
                            
                            System.debug('isSameContext '+isSameContext);
                            System.debug('isSameValue '+isSameValue);
                            if(isSameContext)
                            {
                                if(isSameValue)
                                {
                                    mapServiceMaxTags.remove(seviceMaxTag.SVMXC__Tag_Key__c);
                                }else
                                {
                                    mapServiceMaxTags.remove(seviceMaxTag.SVMXC__Tag_Key__c);
                                    seviceMaxTag.SVMXC__Tag_Value__c = mapTag.SVMXC__Tag_Value__c;
                                    seviceMaxTagTagsTobeUpdated.add(seviceMaxTag);
                                }
                                
                            }
                            else
                            {
                                if(!isSameContextContain)
                                {
                                    String str = ' <br/> ' + mapTag.SVMXC__Tag_Context__c;
                                    seviceMaxTag.SVMXC__Tag_Context__c = seviceMaxTag.SVMXC__Tag_Context__c + str;
                                    mapServiceMaxTags.remove(seviceMaxTag.SVMXC__Tag_Key__c);
                                    seviceMaxTagTagsTobeUpdated.add(seviceMaxTag);
                                }
                                
                            }
                         }  
                            
                    }
                    if(mapServiceMaxTags != null && mapServiceMaxTags.size() > 0){
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapServiceMaxTags.values(), COMM_SecurityUtils.Access.Createable)){
                           insert mapServiceMaxTags.values(); //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else
                        {
                            throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                        }   
                    }
                    if(seviceMaxTagTagsTobeUpdated != null && seviceMaxTagTagsTobeUpdated.size() > 0){
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(seviceMaxTagTagsTobeUpdated, COMM_SecurityUtils.Access.Updateable)){
                           update seviceMaxTagTagsTobeUpdated;//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else
                        {
                            throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                        }
                    }
                    mapServiceMaxTags = null;
                    seviceMaxTagTagsTobeUpdated = null;
                    
                }
            }
       }
       catch(Exception ex)
       {
            System.debug(LoggingLevel.Warn, 'Exception: ' + ex.getMessage());
       }
    }
    public void UpdateKeysBeforeConstructor()
    {
        // Removed this method code as part of translation story BAC-4012
    }
    
    /**
    * This method generates Translation Keys and update all keys in SVMXC__Tag_Keys__c fields for all Inventory Processes
    * @param list of Inventory Processes
    * @return update all keys in SVMXC__Tag_Keys__c fields for all Inventory Processes
    */
    public SVMXC__ServiceMax_Processes__c i18N_INVT_Translation(SVMXC__ServiceMax_Processes__c svmxProcess)
    {   
        System.debug('svmxProcess id'+svmxProcess.id);
        svmxProcess.SVMXC__Installation_Key__c = installation_Key;
        if(svmxProcess.SVMXC__Name__c != null && svmxProcess.SVMXC__Name__c.length() > 0)
           {
                String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Name__c, null, null, 'INVENTORY_PROCESS_TITLE');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
           }
        if(svmxProcess.SVMXC__Description__c != null && svmxProcess.SVMXC__ProcessID__c != null)
           {
                String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Description__c, svmxProcess.SVMXC__ProcessID__c, '_DESC', 'INVENTORY_PROCESS_DESCRIPTION');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
           }
         if(svmxProcess.SVMXC__Parent_Error_Msg__c != null)
           {
                String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Parent_Error_Msg__c, null, null, 'HEADER_ERROR_MESSAGE');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
           }
         if(svmxProcess.SVMXC__Child_Error_Msg__c != null)
           {
                String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Child_Error_Msg__c, null, null, 'DETAIL_ERROR_MESSAGE');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
           }    
        return svmxProcess;
    }
    
    /**
    * This method generates Translation Keys and update all keys in SVMXC__Tag_Keys__c fields for all SFM Search Processes
    * @param list of SFM Search Processes
    * @return update all keys in SVMXC__Tag_Keys__c fields for all SFM Search Processes
    */
    public SVMXC__ServiceMax_Processes__c i18N_Search_Translation(SVMXC__ServiceMax_Processes__c svmxProcess)
    {
        System.debug('svmxProcess id'+svmxProcess.id);
        svmxProcess.SVMXC__Installation_Key__c = installation_Key;
        List<SVMXC__ServiceMax_Processes__c> lstSearchObj = [Select Name,SVMXC__Name__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__Module__c =: SVMXProcess.id AND SVMXC__Rule_Type__c = 'SRCH_OBJECT'];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(svmxProcess.SVMXC__Name__c != null && svmxProcess.SVMXC__Name__c.length() > 0)
        {
            String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Name__c, null, null, 'SFM_SEARCH_NAME');
            if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey)){
              svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
            }
                 
        }
        if(svmxProcess.SVMXC__Description__c != null && svmxProcess.SVMXC__ProcessID__c != null)
        {
                String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Description__c, svmxProcess.SVMXC__ProcessID__c, '_DESC', 'SFM_SEARCH_DESCRIPTION');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
        }
        for(SVMXC__ServiceMax_Processes__c searchObj : lstSearchObj )
        {
             if(searchObj.SVMXC__ProcessID__c == null)
             {
                 searchObj.SVMXC__ProcessID__c = searchObj.name;
                 lstWizardStepsSearchObjs.add(searchObj);
             }
             if(searchObj.SVMXC__Name__c != null && searchObj.SVMXC__Name__c.length() > 0)
             {
                 String strUniqueKey = generate_UniqueKeys(searchObj.SVMXC__Name__c, null, null, 'SEARCH_RESULT_SECTION_TITLE');
                 if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                     svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;   
             }
             if(searchObj.SVMXC__Description__c != null && svmxProcess.SVMXC__ProcessID__c != null && searchObj.SVMXC__ProcessID__c != null)
             {
                 String strCompositeKey = svmxProcess.SVMXC__ProcessID__c + '_' + searchObj.SVMXC__ProcessID__c;
                 String strUniqueKey = generate_UniqueKeys(searchObj.SVMXC__Description__c, strCompositeKey, '_DESC', 'SEARCH_RESULT_SECTION_DESCRIPTION');
                 if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                       svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;   
             }
                
        }
        return svmxProcess;
    }
    
    /**
    * This method generates Translation Keys and update all keys in SVMXC__Tag_Keys__c fields for all SFM Wizard Processes
    * @param list of SFM Wizard Processes
    * @return update all keys in SVMXC__Tag_Keys__c fields for all SFM Wizard Processes
    */
    public SVMXC__ServiceMax_Processes__c I18N_SFW_Translation(SVMXC__ServiceMax_Processes__c svmxProcess)
    {      
           System.debug('svmxProcess id'+svmxProcess.id);
           svmxProcess.SVMXC__Installation_Key__c = installation_Key;
           if(svmxProcess.SVMXC__Name__c != null && svmxProcess.SVMXC__Name__c.length() > 0)
            {
                String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Name__c, null, null, 'WIZARD_NAME');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
            }
            if(svmxProcess.SVMXC__Description__c != null && svmxProcess.SVMXC__ProcessID__c != null)
            {
                String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Description__c, svmxProcess.SVMXC__ProcessID__c, '_DESC', 'WIZARD_DESCRIPTION');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
            }
            
            for(SVMXC__ServiceMax_Processes__c SFWAction : [Select Name,SVMXC__Confirmation_Message__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Module__c from SVMXC__ServiceMax_Processes__c where SVMXC__Module__c =:svmxProcess.id AND Recordtype.Name = 'Wizard Step'])//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            {
                if(SFWAction.SVMXC__ProcessID__c == null)
                {
                    SFWAction.SVMXC__ProcessID__c = SFWAction.Name;
                    lstWizardStepsSearchObjs.add(SFWAction);
                }
                if(SFWAction.SVMXC__Name__c != null && SFWAction.SVMXC__Name__c.length() > 0)
                    {
                        String strUniqueKey = generate_UniqueKeys(SFWAction.SVMXC__Name__c, null, null, 'WIZARD_STEP_NAME');
                        if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                            svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                    }
                    if(SFWAction.SVMXC__Description__c != null && svmxProcess.SVMXC__ProcessID__c != null && SFWAction.SVMXC__ProcessID__c != null)
                    {
                        String strCompositeKey = svmxProcess.SVMXC__ProcessID__c + '_' + SFWAction.SVMXC__ProcessID__c;
                        String strUniqueKey = generate_UniqueKeys(SFWAction.SVMXC__Description__c, strCompositeKey, '_DESC', 'WIZARD_STEP_DESCRIPTION');
                        if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                            svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                    }
                    if(SFWAction.SVMXC__Confirmation_Message__c != null && svmxProcess.SVMXC__ProcessID__c != null && SFWAction.SVMXC__ProcessID__c != null)
                    {
                        String strUniqueKey = generate_UniqueKeys(SFWAction.SVMXC__Confirmation_Message__c, null, null, 'WIZARD_STEP_CONFIRMATION_MESSAGE');
                        if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                            svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                    }
            }
        
        return svmxProcess;
    }

    
    /**
    * This method generates Translation Keys and update all keys in SVMXC__Tag_Keys__c fields for all SFM Processes
    * @param list of SFM Processes
    * @return update all keys in SVMXC__Tag_Keys__c fields for all SFM Processes
    */
    public SVMXC__ServiceMax_Processes__c i18N_SFM_Translation(SVMXC__ServiceMax_Processes__c svmxProcess)
    {
        System.debug('svmxProcess id'+svmxProcess.id);
        svmxProcess.SVMXC__Installation_Key__c = installation_Key;
        if(svmxProcess.SVMXC__Name__c != null && svmxProcess.SVMXC__Name__c.length() > 0)
            {
                String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Name__c, null, null, 'SFM_PROCESS_NAME');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
            }
            if(svmxProcess.SVMXC__Description__c != null && svmxProcess.SVMXC__ProcessID__c != null)
            {
                String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Description__c, svmxProcess.SVMXC__ProcessID__c, '_DESC', 'SFM_PROCESS_DESCRIPTION');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
            }
            List<SVMXC__ServiceMax_Processes__c> lstProBizRule = new List<SVMXC__ServiceMax_Processes__c>();
            lstProBizRule = [Select Id, SVMXC__Parent_Error_Msg__c, SVMXC__Process1__c, SVMXC__Name__c, SVMXC__Process3__c, SVMXC__Process3__r.SVMXC__Parent_Error_Msg__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Process1__c =: svmxProcess.ID AND Recordtype.Name = 'Process Business Rule'];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstProBizRule != null && lstProBizRule.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c proBizRule : lstProBizRule)
                {
                     if(proBizRule.SVMXC__Parent_Error_Msg__c != null && proBizRule.SVMXC__Parent_Error_Msg__c.length() > 0)
                    {
                        String strUniqueKey = generate_UniqueKeys(proBizRule.SVMXC__Parent_Error_Msg__c, null, null, 'DATA_VALIDATION_RULE_MESSAGE');
                        if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                            svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                    }
                }
            }
            List<SVMXC__Page_Layout__c> pageLayoutList = new List<SVMXC__Page_Layout__c>();
            if(svmxProcess.SVMXC__Page_Layout__c != null)
            {
                for(SVMXC__Page_Layout__c objPageLayout : [Select Id, SVMXC__Page_Help__c, SVMXC__Page_Layout_ID__c, SVMXC__Type__c, SVMXC__Name__c,  SVMXC__Header_Page_Layout__c from SVMXC__Page_Layout__c where (Id =: svmxProcess.SVMXC__Page_Layout__c OR SVMXC__Header_Page_Layout__c =: svmxProcess.SVMXC__Page_Layout__c) AND SVMXC__Type__c IN ('Header', 'Detail') AND SVMXC__Type__c != null])//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                {
                    if(objPageLayout.SVMXC__Name__c != null && objPageLayout.SVMXC__Type__c == 'Detail')
                    {
                        String strUniqueKey = generate_UniqueKeys(objPageLayout.SVMXC__Name__c, null, null, 'SFM_SECTION_TITLE');
                        if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                            svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                    }
                    if(objPageLayout.SVMXC__Page_Help__c != null && objPageLayout.SVMXC__Page_Layout_ID__c != null)
                    {
                        String strUniqueKey = generate_UniqueKeys(objPageLayout.SVMXC__Page_Help__c, objPageLayout.SVMXC__Page_Layout_ID__c, '_PAGEHELP', 'SFM_PAGE_HELP');
                        if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                            svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                    }
                    pageLayoutList.add(objPageLayout);
                    
                }               
                for(SVMXC__Page_Layout_Detail__c objPageLayoutDetail : [Select SVMXC__Page_Layout__c, SVMXC__Detail_Type__c, SVMXC__Page_Layout__r.SVMXC__Type__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__r.SVMXC__Type__c, SVMXC__Title__c from SVMXC__Page_Layout_Detail__c where (SVMXC__Page_Layout__c IN: pageLayoutList OR SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c IN: pageLayoutList) AND SVMXC__Detail_Type__c IN ('Button', 'Section')])//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                {
                    if(objPageLayoutDetail.SVMXC__Title__c != null && objPageLayoutDetail.SVMXC__Title__c.length() > 0)
                    {
                        String strTagContext = '';
                        if(objPageLayoutDetail.SVMXC__Detail_Type__c == 'Section')
                            strTagContext = 'SFM_SECTION_TITLE';
                        else if(objPageLayoutDetail.SVMXC__Detail_Type__c == 'Button')
                            strTagContext = 'SFM_BUTTON_TITLE';
                        String strUniqueKey = generate_UniqueKeys(objPageLayoutDetail.SVMXC__Title__c, null, null, strTagContext);
                        if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                            svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                    }
                }
                
                
            }
            //Get linked processes
            List<SVMXC__ServiceMax_Processes__c> lstLinkedProcesses = [Select Id, SVMXC__Process1__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Process1__c =: svmxProcess.id AND Recordtype.Name = 'Linked Process'];
            for(SVMXC__ServiceMax_Processes__c LinkedProcess : lstLinkedProcesses)
            {
                if(LinkedProcess.SVMXC__Name__c != null && LinkedProcess.SVMXC__Name__c.length() > 0)
                {
                String strUniqueKey = generate_UniqueKeys(LinkedProcess.SVMXC__Name__c, null, null, 'LINKED_PROCESS_TITLE');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                }
            }

            //Qualification criteria error message
            List<SVMXC__ServiceMax_Processes__c> lstProNodeObj = [Select Id, SVMXC__Process__c, SVMXC__Submodule__r.SVMXC__Parent_Error_Msg__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Process__c =:svmxProcess.id AND Recordtype.Name = 'Process Node Objects' AND SVMXC__Submodule__r.Recordtype.Name = 'SVMX Rule' AND SVMXC__Submodule__c != null AND SVMXC__Submodule__r.SVMXC__Parent_Error_Msg__c != null];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
          if(lstProNodeObj !=null && lstProNodeObj.size() > 0 )
            {
                String strUniqueKey = generate_UniqueKeys(lstProNodeObj[0].SVMXC__Submodule__r.SVMXC__Parent_Error_Msg__c, null, null, 'HEADER_ERROR_MESSAGE');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
            }
        return svmxProcess; 
    }
    
    //Added by Manish for supporting checklist translation
    public SVMXC__ServiceMax_Processes__c i18N_Checklist_Translation(SVMXC__ServiceMax_Processes__c svmxProcess)
    {
          svmxProcess.SVMXC__Installation_Key__c = installation_Key;
          Set<ID> setQuestionIds = new Set<ID>();
          Map<Id, List<String>> mapQuesIDListResponseValue = new Map<Id, List<String>>();
          Map<Id, List<String>> mapQuesIDListDefaultResponseValue = new Map<Id, List<String>>();
          List<SVMXC__Page_Layout_Detail__c> lstobjPLD = new List<SVMXC__Page_Layout_Detail__c>();
          if(svmxProcess.SVMXC__Page_Layout__c != null)
          {
            lstobjPLD = [SELECT SVMXC__Question__c, SVMXC__Question__r.SVMXC__Question__c, SVMXC__Page_Layout__c, SVMXC__Detail_Type__c, SVMXC__Page_Layout__r.SVMXC__Type__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__r.SVMXC__Type__c, SVMXC__Title__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Page_Layout__c =: svmxProcess.SVMXC__Page_Layout__c AND SVMXC__Detail_Type__c IN ('Section', 'Question')];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__Page_Layout_Detail__c pageLayoutDetail : lstobjPLD)
            {
                if(pageLayoutDetail.SVMXC__Detail_Type__c == 'Question' && pageLayoutDetail.SVMXC__Question__c != null)
                {
                     setQuestionIds.add(pageLayoutDetail.SVMXC__Question__c);
                }
            }
          }
          
          if(setQuestionIds.size() > 0)
          {
              Set<String> setTempQuesID = new Set<String>();
              Set<String> setTempTransQText = new Set<String>();
              List<SVMXC__Question_Bank__c> lstQBank = [SELECT Id, SVMXC__Response_Type__c, SVMXC__Response_Set__c, SVMXC__Response_Set__r.SVMXC__Response_Set_Values__c FROM SVMXC__Question_Bank__c WHERE Id IN : setQuestionIds];
              for(SVMXC__Question_Bank__c objQuesBank : lstQBank)
              {
                  if(objQuesBank.SVMXC__Response_Set__c != null && objQuesBank.SVMXC__Response_Set__r.SVMXC__Response_Set_Values__c != '')
                  {
                      if(!mapQuesIDListResponseValue.containsKey(objQuesBank.Id))
                          mapQuesIDListResponseValue.put(objQuesBank.Id, new List<String>());
                      List<String> lstTempRespVal = new List<String>();
                      lstTempRespVal = objQuesBank.SVMXC__Response_Set__r.SVMXC__Response_Set_Values__c.split(';');
                      mapQuesIDListResponseValue.get(objQuesBank.Id).addAll(lstTempRespVal);
                  }
                  else if(objQuesBank.SVMXC__Response_Set__c == null && (objQuesBank.SVMXC__Response_Type__c == 'Checkbox' || objQuesBank.SVMXC__Response_Type__c == 'Picklist' || objQuesBank.SVMXC__Response_Type__c == 'Multi-select Picklist' || objQuesBank.SVMXC__Response_Type__c == 'Radio Button')){
                      setTempQuesID.add(objQuesBank.Id);
                  }
                  else if(objQuesBank.SVMXC__Response_Set__c == null && objQuesBank.SVMXC__Response_Type__c == 'Text')
                  {
                      setTempTransQText.add(objQuesBank.Id);
                  }
              }
              if(setTempQuesID.size() > 0)
              {
                List<SVMXC__QB_Response_Options__c> lstQBResponse = [SELECT SVMXC__Question_Bank__c, SVMXC__Response__c FROM SVMXC__QB_Response_Options__c WHERE SVMXC__Question_Bank__c IN: setTempQuesID];
                for(SVMXC__QB_Response_Options__c objQB : lstQBResponse)
                {
                    if(!mapQuesIDListResponseValue.containsKey(objQB.SVMXC__Question_Bank__c))
                        mapQuesIDListResponseValue.put(objQB.SVMXC__Question_Bank__c, new List<String>());
                    mapQuesIDListResponseValue.get(objQB.SVMXC__Question_Bank__c).add(objQB.SVMXC__Response__c);
                }
              }
              if(setTempTransQText!=null && setTempTransQText.size() > 0)
              {
                  List<SVMXC__SM_Default_Checklist_Response__c> lstQBDefaultResponse = [SELECT Id, SVMXC__SM_Question__c,SVMXC__SM_Default_Response__c FROM SVMXC__SM_Default_Checklist_Response__c WHERE SVMXC__SM_Question__c IN: setTempTransQText];
                  for(SVMXC__SM_Default_Checklist_Response__c objQB : lstQBDefaultResponse)
                  {
                     if(objQB.SVMXC__SM_Default_Response__c != null)
                     {
                        SFM_WrapperDef.SFM_DefaultResponseJSON obj=(SFM_WrapperDef.SFM_DefaultResponseJSON)JSON.deserialize(objQB.SVMXC__SM_Default_Response__c, SFM_WrapperDef.SFM_DefaultResponseJSON.class);
                        if(obj.listOfDefaultValues != null && obj.listOfDefaultValues.size() > 0 )
                        {
                            if(!mapQuesIDListDefaultResponseValue.containsKey(objQB.SVMXC__SM_Question__c))
                            {
                                mapQuesIDListDefaultResponseValue.put(objQB.SVMXC__SM_Question__c, new List<String>());
                            }   
                            mapQuesIDListDefaultResponseValue.get(objQB.SVMXC__SM_Question__c).add(obj.listOfDefaultValues[0]);
                        } 
                     }
                  }
              }
             
          }
          if(svmxProcess.SVMXC__Name__c != null && svmxProcess.SVMXC__Name__c.length() > 0)
          {
                String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Name__c, null, null, 'SFM_PROCESS_NAME');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
          }
          if(svmxProcess.SVMXC__Description__c != null && svmxProcess.SVMXC__ProcessID__c != null)
          {
                String strUniqueKey = generate_UniqueKeys(svmxProcess.SVMXC__Description__c, svmxProcess.SVMXC__ProcessID__c, '_DESC', 'SFM_PROCESS_DESCRIPTION');
                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
          }
          for(SVMXC__Page_Layout_Detail__c objPageLayoutDetail : lstobjPLD)
          {
                String strTagContext = '';
                String strUniqueKey = '';
                if(objPageLayoutDetail.SVMXC__Title__c != null && objPageLayoutDetail.SVMXC__Title__c.length() > 0 && objPageLayoutDetail.SVMXC__Detail_Type__c == 'Section'){
                    strTagContext = 'SFM_SECTION_TITLE';
                    strUniqueKey = generate_UniqueKeys(objPageLayoutDetail.SVMXC__Title__c, null, null, strTagContext);
                    if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                        svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                }
                else if(objPageLayoutDetail.SVMXC__Detail_Type__c == 'Question' && objPageLayoutDetail.SVMXC__Question__c != null)
                {
                    strTagContext = 'SFM_QUESTION_TEXT';
                    strUniqueKey = generate_UniqueKeys(objPageLayoutDetail.SVMXC__Question__r.SVMXC__Question__c, null, null, strTagContext);
                    if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                        svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                    if(mapQuesIDListResponseValue != null && mapQuesIDListResponseValue.size() > 0 && mapQuesIDListResponseValue.containsKey(objPageLayoutDetail.SVMXC__Question__c))
                    {
                            strTagContext = 'SFM_RESPONSE_TEXT';
                            for(String strResponse : mapQuesIDListResponseValue.get(objPageLayoutDetail.SVMXC__Question__c))
                            {
                                strUniqueKey = generate_UniqueKeys(strResponse, null, null, strTagContext);
                                if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                            }
                            
                    }
                    if(mapQuesIDListDefaultResponseValue!=null && mapQuesIDListDefaultResponseValue.size() > 0 && mapQuesIDListDefaultResponseValue.containsKey(objPageLayoutDetail.SVMXC__Question__c))
                    {
                            strTagContext = 'SFM_RESPONSE_DEFAULT_ANSWER';
                            for(String strResponse : mapQuesIDListDefaultResponseValue.get(objPageLayoutDetail.SVMXC__Question__c))
                            {
                                strUniqueKey = generate_UniqueKeys(strResponse, null, null, strTagContext);
                                  if(strUniqueKey != null && !createProcessKeySet(svmxProcess.SVMXC__Tag_Keys__c).contains(strUniqueKey))
                                    svmxProcess.SVMXC__Tag_Keys__c += strUniqueKey;
                            } 
                    }
                    
                }
          }
       return svmxProcess;
    }
    
    private Set<String> createProcessKeySet(String strTagKeys)
    {
        Set<String> setExistingKeys = new Set<String>();
        if(strTagKeys != NULL && strTagKeys.length() > 0)
            setExistingKeys.addAll(strTagKeys.split(';'));
        return setExistingKeys;
    }
    /*
    //Commented as part of BAC-4012
    private SVMXC__ServiceMax_Processes__c updateProcessTagKeyField(SVMXC__ServiceMax_Processes__c SFMProcess)
    {
        if(SFMProcess.SVMXC__Tag_Keys__c.containsAny('SVMX_NONE') && SFMProcess.SVMXC__Tag_Keys__c.split('SVMX_NONE').size() > 0)
            SFMProcess.SVMXC__Tag_Keys__c = SFMProcess.SVMXC__Tag_Keys__c.split('SVMX_NONE')[1];
        else
            SFMProcess.SVMXC__Tag_Keys__c = NULL;
        return SFMProcess;
    }*/
    
    public String generate_UniqueKeys(String fieldName, String SVMXProcessNameField, String SVMXLiteral, String TagContext)
    {
        
        
        String keyAsField = null;
        
        if(SVMXLiteral != null && SVMXProcessNameField != null)
            keyAsField = SVMXProcessNameField.replaceAll(' ', '_') + SVMXLiteral;
        else
            keyAsField = fieldName.replaceAll(' ', '_');
        System.debug('keyAsField:'+keyAsField);
        if(keyAsField != null && keyAsField.length() > 0 && keyAsField.length() <= 255)
        {   
            keyAsField = keyAsField.toUpperCase();
            System.debug('mapServiceMaxTags:'+mapServiceMaxTags.get(keyAsField));
             if(mapServiceMaxTags.containsKey(keyAsField) && mapServiceMaxTags.get(keyAsField) != null)
            {
                Set<String> setTagContext = new Set<String>();
                
                if(mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c != null && mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c.length() > 0 && mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c.containsAny('<br/>'))
                    setTagContext.addAll(mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c.split(' <br/> '));
                else
                    setTagContext.add(mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c);
                
                setTagContext.add(TagContext);
                if(setTagContext.contains(null))
                    setTagContext.remove(null);
                
                mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c = null;
                for(String context : setTagContext)
                {
                   
                    if(mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c == null)
                        mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c = context;
                    else
                    {
                        if(mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c.length() > 0)
                            mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c += ' <br/> ';
                        mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c += context;
                    }
                }
                
                if(mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c.length() > 255)
                    mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c = mapServiceMaxTags.get(keyAsField).SVMXC__Tag_Context__c.substring(0, 255);
            }
            else
            {
                mapServiceMaxTags.put(keyAsField, new SVMXC__ServiceMax_Tags__c(SVMXC__Tag_Key__c = keyAsField, SVMXC__Tag_Value__c = fieldName, SVMXC__Tag_Context__c = TagContext, SVMXC__Language__c = 'Master', SVMXC__Installation_Key__c = installation_Key));
            
            }     
        }
        
        if(keyAsField != null && keyAsField.length() > 0 && keyAsField.length() <= 255)
            return keyAsField + ';';
        else
            return null;
    }

    public void updateServiceMaxTagKeys() {
        System.debug('Map ServiceMaxTags : ' + mapServiceMaxTags.keyset());
        if (mapServiceMaxTags != null && !mapServiceMaxTags.isEmpty())  {
            List<SVMXC__ServiceMax_Tags__c> seviceMaxTagKeysTobeUpdated = new List<SVMXC__ServiceMax_Tags__c>();
            if (!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Tags__c', new List<String>{'SVMXC__Tag_Key__c','SVMXC__Tag_Value__c', 'SVMXC__Tag_Context__c', 'SVMXC__Language__c'}, COMM_SecurityUtils.Access.Accessible)) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            for (SVMXC__ServiceMax_Tags__c seviceMaxTag : [Select SVMXC__Tag_Key__c, SVMXC__Tag_Value__c,SVMXC__Tag_Context__c from SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN: mapServiceMaxTags.keyset() AND SVMXC__Language__c = 'Master'] ) {
                SVMXC__ServiceMax_Tags__c mapTag = mapServiceMaxTags.get(seviceMaxTag.SVMXC__Tag_Key__c);
                if (mapTag != null)  {
                    boolean isSameContextContain = false;
                    boolean isSameContext = seviceMaxTag.SVMXC__Tag_Context__c == mapTag.SVMXC__Tag_Context__c;
                    if (String.isNotBlank(seviceMaxTag.SVMXC__Tag_Context__c)) {
                        isSameContextContain = seviceMaxTag.SVMXC__Tag_Context__c.contains(mapTag.SVMXC__Tag_Context__c);
                    }
                    boolean isSameValue = seviceMaxTag.SVMXC__Tag_Value__c == mapTag.SVMXC__Tag_Value__c;
                    System.debug(isSameContext + ': isSameContext | isSameValue :' + isSameValue);
                    mapServiceMaxTags.remove(seviceMaxTag.SVMXC__Tag_Key__c);
                    if (isSameContext) {
                        if(!isSameValue) {
                            seviceMaxTag.SVMXC__Tag_Value__c = mapTag.SVMXC__Tag_Value__c;
                            seviceMaxTagKeysTobeUpdated.add(seviceMaxTag);
                        }
                    } else if (!isSameContextContain){
                        String str = ' <br/> ' + mapTag.SVMXC__Tag_Context__c;
                        seviceMaxTag.SVMXC__Tag_Context__c = seviceMaxTag.SVMXC__Tag_Context__c + str;
                        seviceMaxTagKeysTobeUpdated.add(seviceMaxTag);
                    }
                }   
             }
            if (!mapServiceMaxTags.isEmpty()) {
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(mapServiceMaxTags.values(), COMM_SecurityUtils.Access.Createable)) {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
                insert mapServiceMaxTags.values();
            }
            if (!seviceMaxTagKeysTobeUpdated.isEmpty()) {
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(seviceMaxTagKeysTobeUpdated, COMM_SecurityUtils.Access.Updateable)) {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
                 update seviceMaxTagKeysTobeUpdated;
            }
        }
    }

    public Transient Map<String, SVMXC__ServiceMax_Tags__c> mapServiceMaxTags = new Map<String, SVMXC__ServiceMax_Tags__c>();
    private List<SVMXC__ServiceMax_Processes__c> lstWizardStepsSearchObjs = new List<SVMXC__ServiceMax_Processes__c>();
}