global with sharing class COMM_Utils_ManageTags {

    public class SVMXTagsException extends Exception {} 
    
    private Map<String, SVMXC__ServiceMax_Tags__c> SVMX_mapTagRecords = new Map<String, SVMXC__ServiceMax_Tags__c>();

    global Map<String, SVMXC__ServiceMax_Tags__c> SVMX_cloneTags(Id exSubModule, Id newSubModule, Map<String, SVMXC__ServiceMax_Tags__c> tagsMap, String installKey)
    {
       
        /*Map<String, SVMXC__ServiceMax_Tags__c> allTags = new Map<String, SVMXC__ServiceMax_Tags__c>();
        for( SVMXC__ServiceMax_Tags__c t : tagsMap.values() )
            {
                SVMXC__ServiceMax_Tags__c newTag = t.clone(false, true);
                newTag.SVMXC__Submodule__c = newSubModule;
                newTag.SVMXC__Installation_Key__c = installKey;
                allTags.put(t.Name, t); // This will put all the Master tags
            }
        if(allTags != null  && allTags.size() >0 ) 
            insert allTags.values();
            
        return allTags;*/
       return null;
    }   

global Map<String, SVMXC__ServiceMax_Tags__c> SVMX_getTagRecordList(String subModuleId)
    {
        
        SVMX_getTagList(subModuleId);
        return SVMX_mapTagRecords; //Return the private member, which is/should be poulated by getTagList method
        //return null;
    }   

global Map<String, String> SVMX_getTagList(String subModuleId)
    {
        //throw new SVMXTagsException('ServiceMax tags are no longer supported for submodule ID: ' + subModuleId);
        
        List<SVMXC__ServiceMax_Tags__c> tagRecs = new List<SVMXC__ServiceMax_Tags__c>();
        String SOQLHeader ='';
        
        //Take User Locale and decide the Lang here
        //If subModuleId is NULL then return Blank
        //Query and fill MAp and send Back
        String defLang = 'Master';
        String usrLang = UserInfo.getLanguage(); //Apex Method example for English it will return: returns en_US
        if (usrLang == 'en_US') usrLang = 'English';        
        if (usrLang == 'de') usrLang = 'German';        
        if (usrLang == 'es') usrLang = 'Spanish';       
        if (usrLang == 'fr') usrLang = 'French';        
        if (usrLang == 'it') usrLang = 'Italian';       
        if (usrLang == 'ja') usrLang = 'Japanese';      
        if (usrLang == 'sv') usrLang = 'Swedish';       
        if (usrLang == 'ko') usrLang = 'Korean';        
        if (usrLang == 'zh_TW') usrLang = 'Chinese (Traditional)';      
        if (usrLang == 'zh_CN') usrLang = 'Chinese (Simplified)';       
        if (usrLang == 'pt_BR') usrLang = 'Portuguese (Brazilian)';     
        if (usrLang == 'nl_NL') usrLang = 'Dutch';      
        if (usrLang == 'da') usrLang = 'Danish';        
        if (usrLang == 'th') usrLang = 'Thai';      
        if (usrLang == 'fi') usrLang = 'Finnish';       
        if (usrLang == 'ru') usrLang = 'Russian';       
        
 
        Map<String, String> allTags = new Map<String, String>();
        Map<String, String> usrTags = new Map<String, String>();
        subModuleId = String.isNotBlank(subModuleId) ? String.escapeSingleQuotes(subModuleId) : subModuleId; //#soqlInjectionFix       
        SOQLHeader = 'Select SVMXC__Tag_Text__c, SVMXC__Submodule__c,SVMXC__Language__c, Name, Id FROM SVMXC__ServiceMax_Tags__c ';
        SOQLHeader = SOQLHeader + ' where SVMXC__Submodule__r.SVMXC__SubmoduleID__c =\'' + subModuleId + '\'';
        SOQLHeader = SOQLHeader + ' And SVMXC__Language__c IN (\'' + String.escapeSingleQuotes(usrLang) + '\', \'' + String.escapeSingleQuotes(defLang) +'\')'; //#soqlInjectionFix
         
        System.debug('SOQLHeaderSOQLHeaderSOQLHeader' + SOQLHeader);
        tagRecs = Database.query(SOQLHeader);
        
        if(tagRecs.size() == 0)
            return allTags ;//ERROR
                                                
        for( SVMXC__ServiceMax_Tags__c t : tagRecs )
            {
                if (t.SVMXC__Language__c == defLang) 
                   {
                     allTags.put(t.Name, t.SVMXC__Tag_Text__c); // This will put all the Master tags
                     SVMX_mapTagRecords.put(t.Name, t); //This is returned in SVMX_getTagRecordList method, contains tag records
                   }
                else
                    usrTags.put(t.Name,t.SVMXC__Tag_Text__c);
            }
        
        // Loop thro' all master tags and get translations if available  
        Set <String> tagSet = new Set<String>();
        tagSet = allTags.keySet();

        for (String tagID : tagSet)
            {
            Boolean keyExists = usrTags.containsKey(tagID);
            if (keyExists) 
                {
                 String tagText = usrTags.get(tagID);
                 if(tagText != null)
                    allTags.put(tagID, tagText);
                }
            }
        //System.debug(allTags);            
        
        return allTags;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getMobileConfigTags(INTF_WebServicesDef.INTF_SFMRequest tagsReq)
    {
        INTF_WebServicesDef.INTF_SFMResponse objTagResponse = new INTF_WebServicesDef.INTF_SFMResponse();
        List<INTF_WebServicesDef.svmxError> lstErrors = new List<INTF_WebServicesDef.svmxError>();
        try
        {
            List<INTF_WebServicesDef.SVMXMap> lstTags = new List<INTF_WebServicesDef.SVMXMap>();
            for(INTF_WebServicesDef.SVMXMap objModule : tagsReq.valueMap)
            {
                COMM_TagsDefinition tagDefination = new COMM_TagsDefinition();
                lstTags.addAll(tagDefination.MobileTagvalueCalc(objModule.key, Boolean.valueOf(objModule.value)));
                objTagResponse.success = true;
            }
            objTagResponse.valueMap = lstTags;
        }
        catch(Exception ex)
        {
            INTF_WebServicesDef.svmxError objEror = new INTF_WebServicesDef.svmxError();
            objEror.errorMsg = ex.getMessage();
            lstErrors.add(objEror);
            objTagResponse.success = false;                 
        }
        objTagResponse.eventType = 'DATA';
        objTagResponse.eventName = 'MOBILE_DEVICE_TAGS';
        objTagResponse.errors = lstErrors;
        return objTagResponse;
    }
}