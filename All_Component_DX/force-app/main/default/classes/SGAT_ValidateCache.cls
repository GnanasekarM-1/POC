public with sharing class SGAT_ValidateCache
{
    //NOT IN USE ANY-MORE
    //This class supposed to be deleted in future.
    /*
    private static final String COMPONENT_NAME = 'componentName';
    private static final String TAGS_HASH_CODE = 'tagsHashCode';
    private static final String HASH_CODE = 'hashCode';
    private static final String OBJECT_PERMISSIONS = 'OBJECT_PERMISSIONS';
    private static final String SVMX_SETTINGS = 'SVMX_SETTINGS';
    private static final String MOBILE_CONFIG = 'MOBILE_CONFIG';
    private static final String CODE_SNIPPET = 'CODE_SNIPPET';
    private static final String APPLICATION_FILTER = 'APPLICATION_FILTER';
    private static final String TRANSLATIONS = 'TRANSLATIONS';
    private static final String SFMTRANSLATIONS = 'SFMTRANSLATIONS';
    private static final String BATCH_API = 'BATCH-API';
    private static final String SETTINGS = 'SETTINGS';
    private static final String OBJ_PARAM_SFM = 'OBJ-PARAM-SFM';
    private static final String ALL_SFM_WIZARDS = 'ALL_SFM_WIZARDS';
    private static final String ALL_SFM_TRANSACTIONS = 'ALL_SFM_TRANSACTIONS';
    private static final String SFA_CONFIG = 'SFA_CONFIG';
    private static final String ALL_SFM_SEARCH = 'ALL_SFM_SEARCH';
    private static final String CALLBACK = 'CALLBACK';
    private static final String STEP = 'STEP';
    private static final String RESOURCE_PERCENT = 'RESOURCE-PERCENT';
    private static final String LAST_SYNC_TIME = 'lastSyncTime';
    private static final String SVMX_PROFILE_ID = 'svmxProfileId';
    private static final String BLACK_LIST_OBJECT = 'blackListObject';
    private static final String WHITE_LIST_OBJECT = 'whiteListObject';
    private String svmxProfileId;
    private String profileId;
    private String userId;
    private DateTime lastSyncTimeConfig;
    private Long objectHashCode;
    private Long tagsHashCode;
    private String batchAPI;
    private Integer resourcePercent;
    private Boolean isCallBack;
    private Integer callbackStep;
    private Set<String> lstObjectsProcessed;
    private Set<String> lstObjectsIgnored;
    private Set<String> whiteListObjects;

    public SGAT_ValidateCache() {
        resourcePercent = 80;
        isCallBack = false;
        batchAPI = 'ALL';
        callbackStep = 1;
        lstObjectsProcessed = new Set<String>();
        lstObjectsIgnored = new Set<String>();
        whiteListObjects = new Set<String>();
    }

    public SGAT_WebServicesDef.SGAT_Response validateCache(SGAT_WebServicesDef.SGAT_Request request) {
        List<SGAT_WebServicesDef.SVMXMap> responseMap = new List<SGAT_WebServicesDef.SVMXMap>();
        SGAT_WebServicesDef.SGAT_Response response = new SGAT_WebServicesDef.SGAT_Response(responseMap);
        if (!validateRequest(request, response)) {
            return response;
        }
        profileId = UserInfo.getProfileId();
        userId = UserInfo.getUserId();
        List<String> lstComponentsChanged = new List<String>();

        try {
            if (lastSyncTimeConfig == null) {
                Long newObjDescHashCode = getDescribeHashCode();
                Long newTagsHashCode = getTagsHashCode();
                responseMap.add(new SGAT_WebServicesDef.SVMXMap(HASH_CODE, String.valueOf(newObjDescHashCode)));
                responseMap.add(new SGAT_WebServicesDef.SVMXMap(TAGS_HASH_CODE, String.valueOf(newTagsHashCode)));
                lstComponentsChanged.add(OBJECT_PERMISSIONS);
                lstComponentsChanged.add(SVMX_SETTINGS);
                lstComponentsChanged.add(MOBILE_CONFIG);
                lstComponentsChanged.add(CODE_SNIPPET);
                lstComponentsChanged.add(APPLICATION_FILTER);
                lstComponentsChanged.add(TRANSLATIONS);
                lstComponentsChanged.add(SFMTRANSLATIONS);
                lstComponentsChanged.add(SFA_CONFIG);
                responseMap.add(new SGAT_WebServicesDef.SVMXMap(COMPONENT_NAME, null, lstComponentsChanged));
                return response;
            }

            if(batchAPI == null || batchAPI == 'ALL') {
                batchAll(lstComponentsChanged, responseMap);
            } else if(batchAPI != null && batchAPI == OBJ_PARAM_SFM) {
                responseMap.add(new SGAT_WebServicesDef.SVMXMap(BATCH_API, batchAPI));
                batchObjPerm(lstComponentsChanged, responseMap);
            } else if(batchAPI != null && batchAPI == SETTINGS) {
                responseMap.add(new SGAT_WebServicesDef.SVMXMap(BATCH_API, batchAPI));
                batchSettings(lstComponentsChanged, responseMap);
            }

            responseMap.add(new SGAT_WebServicesDef.SVMXMap(COMPONENT_NAME, null, lstComponentsChanged));
        } catch(Exception ex) {
            responseMap.add(new SGAT_WebServicesDef.SVMXMap('ERROR', 'Internal Error: ' + ex.getMessage()));
        }

        return response;
    }

    private void batchAll(List<String> lstComponentsChanged, List<SGAT_WebServicesDef.SVMXMap> responseMap) {
        Long newObjDescHashCode = getDescribeHashCode();
        responseMap.add(new SGAT_WebServicesDef.SVMXMap(HASH_CODE, String.valueOf(newObjDescHashCode)));
        Long newTagsHashCode = getTagsHashCode();
        responseMap.add(new SGAT_WebServicesDef.SVMXMap(TAGS_HASH_CODE, String.valueOf(newTagsHashCode)));

        if (arePermissionsChanged(newObjDescHashCode)) {
          lstComponentsChanged.add(OBJECT_PERMISSIONS);
        }
        if (isSFMWizardsChanged()) {
            lstComponentsChanged.add(ALL_SFM_WIZARDS);
        } else {
            if (isSFMTransactionsChanged()) {
                lstComponentsChanged.add(ALL_SFM_TRANSACTIONS);
            }
        }
        if (isSFMSearchConfigChanged()) {
            lstComponentsChanged.add(ALL_SFM_SEARCH);
        }
        if (isSVMXSettingsChanged()) {
            lstComponentsChanged.add(SVMX_SETTINGS);
        }
        if (isMobileConfigChanged()) {
            lstComponentsChanged.add(MOBILE_CONFIG);
        }
        if (isCodeSnippetChanged()) {
            lstComponentsChanged.add(CODE_SNIPPET);
        }
        if (isApplicationFilterChanged()) {
            lstComponentsChanged.add(APPLICATION_FILTER);
        }
        if (isTranslationChanged(newTagsHashCode)) {
            lstComponentsChanged.add(TRANSLATIONS);
        }
        if (isSFMTranslationsChanged()) {
            lstComponentsChanged.add(SFMTRANSLATIONS);
        }
        if(isSFAConfigChanged()) {
          lstComponentsChanged.add(SFA_CONFIG);
        }
    }

    private void batchSettings(List<String> lstComponentsChanged, List<SGAT_WebServicesDef.SVMXMap> responseMap) {
        if (callbackStep <= 1) {
            if (isSVMXSettingsChanged()) {
                lstComponentsChanged.add(SVMX_SETTINGS);
            }
            if (isCPUTimeLimitClose()) {
                addCallBackToResponse(2, new List<String>(), responseMap);
                return;
            }
        }
        if (callbackStep <= 2) {
            if (isMobileConfigChanged()) {
                lstComponentsChanged.add(MOBILE_CONFIG);
            }
            if (isCPUTimeLimitClose()) {
                addCallBackToResponse(3, new List<String>(), responseMap);
                return;
            }
        }
        if (callbackStep <= 3) {
            if (isCodeSnippetChanged()) {
                lstComponentsChanged.add(CODE_SNIPPET);
            }
            if (isSFMTranslationsChanged()) {
                lstComponentsChanged.add(SFMTRANSLATIONS);
            }

            if (isCPUTimeLimitClose()) {
                addCallBackToResponse(4, new List<String>(), responseMap);
                return;
            }
        }

        if (callbackStep <= 4) {
            if (isApplicationFilterChanged()) {
                lstComponentsChanged.add(APPLICATION_FILTER);
            }
            if(isSFAConfigChanged()) {
              lstComponentsChanged.add(SFA_CONFIG);
            }

            Long newTagsHashCode = getTagsHashCode();
            responseMap.add(new SGAT_WebServicesDef.SVMXMap(TAGS_HASH_CODE, String.valueOf(newTagsHashCode)));
            if (isTranslationChanged(newTagsHashCode)) {
                lstComponentsChanged.add(TRANSLATIONS);
            }
        }
    }

    private void batchObjPerm(List<String> lstComponentsChanged, List<SGAT_WebServicesDef.SVMXMap> responseMap) {
        if (callbackStep <= 1) {
            Boolean didLimitHit = getBatchHashCode(lstComponentsChanged, responseMap);

            if(didLimitHit) {
                return;
            } else if (isCPUTimeLimitClose()) {
                addCallBackToResponse(2, new List<String>(), responseMap);
                return;
            }
        }
        if (callbackStep <= 2) {
            if (isSFMWizardsChanged()) {
                lstComponentsChanged.add(ALL_SFM_WIZARDS);
            } else {
                if (isSFMTransactionsChanged()) {
                    lstComponentsChanged.add(ALL_SFM_TRANSACTIONS);
                }
            }
            if (isCPUTimeLimitClose()) {
                addCallBackToResponse(3, new List<String>(), responseMap);
                return;
            }
        }
        if (callbackStep <= 3) {
            if (isSFMSearchConfigChanged()) {
                lstComponentsChanged.add(ALL_SFM_SEARCH);
            }
        }
    }

    private boolean isCPUTimeLimitClose() {
        if (((Double)Limits.getCpuTime() / (Double)Limits.getLimitCpuTime()) * 100 > resourcePercent)
            return true;
        return false;
    }

    private boolean isHeapLimitClose() {
        if (((Double)Limits.getHeapSize() / (Double)Limits.getLimitHeapSize()) * 100 > resourcePercent)
            return true;
        return false;
    }

    @TestVisible private void addCallBackToResponse(integer stepNumber, List<String> objectsProcessed, List<SGAT_WebServicesDef.SVMXMap> responseMap) {
        SGAT_WebServicesDef.SVMXMap callbackValueMap = new SGAT_WebServicesDef.SVMXMap(CALLBACK, 'true');
        callbackValueMap.valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
        SGAT_WebServicesDef.SVMXMap stepNoSVMXMap = new SGAT_WebServicesDef.SVMXMap(STEP, String.valueOf(stepNumber));
        stepNoSVMXMap.values = objectsProcessed;
        callbackValueMap.valueMap.add(stepNoSVMXMap);
        responseMap.add(callbackValueMap);
    }

    private Boolean getBatchHashCode(List<String> lstComponentsChanged, List<SGAT_WebServicesDef.SVMXMap> responseMap) {
        Long hashCode = 0;
        system.debug('object Processed: ' + lstObjectsProcessed);

        map<String, Schema.SObjectType> GlobalMap = Schema.getGlobalDescribe();

        Set<String> objKeys = GlobalMap.keyset();
        Set<String> keysNotNeeded = new Set<String>();
        objKeys.removeAll(lstObjectsProcessed);
        if (lstObjectsIgnored != null && lstObjectsIgnored.size() > 0) {
          for (String objKey: objKeys) {
              for (String objIgnore: lstObjectsIgnored) {
                  if (objKey.endsWith(objIgnore)) {
                      keysNotNeeded.add(objKey);
                      continue;
                  }
              }
          }
        }
        if (whiteListObjects != null && whiteListObjects.size() > 0) {
            keysNotNeeded.removeAll(whiteListObjects);
        }

        objKeys.removeAll(keysNotNeeded);
        lstObjectsProcessed.addAll(keysNotNeeded);

        for(String objKey: objKeys) {
          Schema.SObjectType Obj = GlobalMap.get(objKey);
          Schema.DescribeSObjectResult ObjDesc = Obj.getDescribe();
          if(!ObjDesc.isAccessible()){
            lstObjectsProcessed.add(objKey);
            continue;
          }

          if (isCPUTimeLimitClose() || isHeapLimitClose()) {
              responseMap.add(new SGAT_WebServicesDef.SVMXMap(HASH_CODE, String.valueOf(hashCode)));
              addCallBackToResponse(1, new List<String>(lstObjectsProcessed), responseMap);
              return true;
          }

          lstObjectsProcessed.add(objKey);
          hashCode += system.hashCode(ObjDesc);
          Map <String, Schema.SObjectField> fieldMap = ObjDesc.fields.getMap();
          for(Schema.SObjectField sfield : fieldMap.Values())
          {
            schema.describefieldresult dfield = sfield.getDescribe();
            hashCode += system.hashCode(dfield);
          }
        }

        responseMap.add(new SGAT_WebServicesDef.SVMXMap(HASH_CODE, String.valueOf(hashCode)));
        if (arePermissionsChanged(hashCode)) {
          lstComponentsChanged.add(OBJECT_PERMISSIONS);
        }
        return false;
    }

    private boolean isCodeSnippetChanged() {
        List<SVMXC__SFM_Event__c> lstSFMEvents = [SELECT SVMXC__Code_Snippet__c, LastModifiedDate FROM SVMXC__SFM_Event__c WHERE SVMXC__Event_Call_Type__c = 'JAVASCRIPT'];
        List<String> lstCodeSnippetIds = new List<String>();
        for (SVMXC__SFM_Event__c sfmEvent: lstSFMEvents) {
            lstCodeSnippetIds.add(sfmEvent.SVMXC__Code_Snippet__c);
            if (sfmEvent.LastModifiedDate.getTime() > lastSyncTimeConfig.getTime()) {
                return true;
            }
        }
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        Integer intNoOfModifiedCodeSnippets = [SELECT count() FROM SVMXC__Code_Snippet__c WHERE (ID IN :lstCodeSnippetIds OR SVMXC__Type__c = 'SB CONFIG') AND LastModifiedDate >: lastSyncTimeConfig ALL ROWS];
        if (intNoOfModifiedCodeSnippets > 0) {
            return true;
        }
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        Integer intNoOfModifiedCodeSnippetManifests = [SELECT count() FROM SVMXC__Code_Snippet_Manifest__c WHERE SVMXC__Code_Snippet__c IN :lstCodeSnippetIds AND LastModifiedDate >: lastSyncTimeConfig ALL ROWS];
        if (intNoOfModifiedCodeSnippetManifests > 0) {
            return true;
        }

        return false;
    }

    private boolean isApplicationFilterChanged() {
      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
      Integer intNoOfModifiedApplicationFilters = [SELECT count() FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Application Profile' AND SVMXC__IsStandard__c = true AND LastModifiedDate >: lastSyncTimeConfig ALL ROWS];
      if (intNoOfModifiedApplicationFilters > 0) {
          return true;
      }

      return false;
    }

    private Boolean isSFAConfigChanged() {
      List<SVMXC__SM_SFA_Process__c> lstSFAs = [SELECT SVMXC__SM_Expression__c, LastModifiedDate FROM SVMXC__SM_SFA_Process__c];
      List<String> lstExpressionIds = new List<String>();
      for (SVMXC__SM_SFA_Process__c sfa: lstSFAs) {
          lstExpressionIds.add(sfa.SVMXC__SM_Expression__c);
          if (sfa.LastModifiedDate.getTime() > lastSyncTimeConfig.getTime()) {
              return true;
          }
      }

      if (lstExpressionIds.size() > 0) {
          Integer intNoOfModifiedSFAExpression = [SELECT count() FROM SVMXC__ServiceMax_Processes__c WHERE LastModifiedDate >: lastSyncTimeConfig AND Id IN: lstExpressionIds];
          if(intNoOfModifiedSFAExpression > 0) {
              return true;
          }
          intNoOfModifiedSFAExpression = [SELECT count() FROM SVMXC__ServiceMax_Config_Data__c WHERE LastModifiedDate >: lastSyncTimeConfig AND SVMXC__Expression_Rule__c IN: lstExpressionIds ALL ROWS];
          if(intNoOfModifiedSFAExpression > 0) {
              return true;
          }
      }

      return false;
    }

    private boolean isSFMTranslationsChanged() {
      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
      Integer intNoOfModifiedSFMTranslations = [SELECT count() FROM SVMXC__ServiceMax_Tags__c WHERE LastModifiedDate >: lastSyncTimeConfig ALL ROWS];
      if (intNoOfModifiedSFMTranslations > 0) {
          return true;
      }

      return false;
    }

    private boolean isTranslationChanged(Long newTagsHashCode) {
        if (tagsHashCode == null || tagsHashCode == 0) {
          return true;
        }
        if (tagsHashCode == newTagsHashCode) {
          return false;
        }
        return true;
    }

    private boolean arePermissionsChanged(Long newObjDescHashCode) {
        if (objectHashCode == null || objectHashCode == 0) {
          return true;
        }
        if (objectHashCode == newObjDescHashCode) {
          return false;
        }
        return true;
    }

    public Long getTagsHashCode() {
        COMM_TagsDefinition com = new COMM_TagsDefinition();
        com.getFSAPhoneLabels();
        com.getCommonTags();
        return system.hashCode(com.tags);
    }

    public Long getDescribeHashCode() {
      Long hashCode = 0;

      map<String, Schema.SObjectType> GlobalMap = Schema.getGlobalDescribe();
      for (Schema.SObjectType Obj : GlobalMap.values()) {
        Schema.DescribeSObjectResult ObjDesc = Obj.getDescribe();
        hashCode += system.hashCode(ObjDesc);
        Map <String, Schema.SObjectField> fieldMap = ObjDesc.fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
          schema.describefieldresult dfield = sfield.getDescribe();
          hashCode += system.hashCode(dfield);
        }
      }

      return hashCode;
    }

    private boolean validateRequest(SGAT_WebServicesDef.SGAT_Request request, SGAT_WebServicesDef.SGAT_Response response) {
        for(SGAT_WebServicesDef.SVMXMap svmxMap: request.valueMap) {
            if (svmxMap.key == SVMX_PROFILE_ID) {
                svmxProfileId = svmxMap.value;
            } else if (svmxMap.key == LAST_SYNC_TIME) {
                lastSyncTimeConfig = DateTime.valueOfGmt(svmxMap.value);
            } else if (svmxMap.key == HASH_CODE) {
                try {
                  if(svmxMap.value != null && svmxMap.value.length() > 0) {
                    objectHashCode = long.valueOf(svmxMap.value);
                  } else {
                    objectHashCode = 0;
                  }
                } catch(Exception ex) {
                  objectHashCode = 0;
                }
            }  else if (svmxMap.key == TAGS_HASH_CODE) {
                try {
                  if(svmxMap.value != null && svmxMap.value.length() > 0) {
                    tagsHashCode = long.valueOf(svmxMap.value);
                  } else {
                    tagsHashCode = 0;
                  }
                } catch(Exception ex) {
                  tagsHashCode = 0;
                }
            } else if (svmxMap.key == BLACK_LIST_OBJECT) {
                if (svmxMap.values != null && svmxMap.values.size() > 0) {
                  lstObjectsIgnored.addAll(svmxMap.values);
                }
            } else if (svmxMap.key == WHITE_LIST_OBJECT) {
                if (svmxMap.values != null && svmxMap.values.size() > 0) {
                  whiteListObjects.addAll(svmxMap.values);
                }
            } else if (svmxMap.key == BATCH_API) {
                batchAPI = svmxMap.value;
                if(svmxMap.valueMap != null) {
                    for (SGAT_WebServicesDef.SVMXMap batchMap: svmxMap.valueMap) {
                        if(batchMap.key == RESOURCE_PERCENT) {
                            resourcePercent = Integer.valueOf(batchMap.value);
                        } else if (batchMap.key == CALLBACK) {
                            isCallBack = Boolean.valueOf(batchMap.value);
                            if(isCallBack && batchMap.valueMap != null) {
                                for (SGAT_WebServicesDef.SVMXMap callbackMap: batchMap.valueMap) {
                                    if(callbackMap.key == STEP) {
                                        callbackStep = Integer.valueOf(callbackMap.value);
                                        lstObjectsProcessed.addAll(callbackMap.values);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if (svmxProfileId == null || svmxProfileId.length() == 0) {
            response.valueMap.add(new SGAT_WebServicesDef.SVMXMap('ERROR', 'Request not Valid: Profile Id is missing.'));
            return false;
        }

        return true;
    }

    private boolean isMobileConfigChanged() {
        string strSOQLMobileConfig = 'SELECT count() FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Access_Configuration_Profile__c != null AND SVMXC__RecordType_Name__c = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =: svmxProfileId AND (LastModifiedDate >: lastSyncTimeConfig  OR SVMXC__Dispatch_Process__r.LastModifiedDate >: lastSyncTimeConfig) ALL ROWS';
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Integer intNoOfModifiedMobileConfig = Database.countQuery(strSOQLMobileConfig);
        system.debug('No. of Mobile Config modified: - ' + intNoOfModifiedMobileConfig);
        if (intNoOfModifiedMobileConfig > 0) {
            return true;
        }

        return false;
    }

    private boolean isSFMSearchConfigChanged() {
        String strSOQLAssgndSFMSearch = 'SELECT SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = \'Search Access\'';
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        List<SVMXC__ServiceMax_Config_Data__c> lstAssgndSFMSearch = Database.query(strSOQLAssgndSFMSearch);
        Set<String> setSearchAssignedToOthers = new Set<String>();
        Set<String> setSearchAssigned = new Set<String>();
        for(SVMXC__ServiceMax_Config_Data__c eachSearch :lstAssgndSFMSearch){
          if(eachSearch.SVMXC__Access_Configuration_Profile__c != svmxProfileId)
              setSearchAssignedToOthers.add(eachSearch.SVMXC__Dispatch_Process__c);
          if (eachSearch.SVMXC__Access_Configuration_Profile__c == svmxProfileId)
              setSearchAssigned.add(eachSearch.SVMXC__Dispatch_Process__c);
        }
        setSearchAssignedToOthers.removeAll(setSearchAssigned);
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        strSOQLAssgndSFMSearch = 'SELECT count() FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = \'Search Access\' AND LastModifiedDate >: lastSyncTimeConfig ALL ROWS';
        Integer intNoOfModifiedSearches = Database.countQuery(strSOQLAssgndSFMSearch);
        if (intNoOfModifiedSearches > 0) {
            return true;
        }
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        intNoOfModifiedSearches = [SELECT count() FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH' AND ID NOT IN :setSearchAssignedToOthers AND LastModifiedDate > :lastSyncTimeConfig];
        system.debug('No. of SFM Search modified: - ' + intNoOfModifiedSearches);
        if (intNoOfModifiedSearches > 0) {
            return true;
        }

        return false;
    }

    private boolean isSFMTransactionsChanged() {
        String strSOQLAssignedSFMs = 'SELECT SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = \'Service Flow Access\'';
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        List<SVMXC__ServiceMax_Config_Data__c> lstAssignedSFMs = Database.query(strSOQLAssignedSFMs);
        Set<String> setSFMsAssignedToOtherProfiles = new Set<String>();
        Set<String> setSFMsAssignedToProfile = new Set<String>();
        for(SVMXC__ServiceMax_Config_Data__c eachSFM :lstAssignedSFMs){
          if(eachSFM.SVMXC__Access_Configuration_Profile__c != svmxProfileId)
              setSFMsAssignedToOtherProfiles.add(eachSFM.SVMXC__Dispatch_Process__c);
          if (eachSFM.SVMXC__Access_Configuration_Profile__c == svmxProfileId)
              setSFMsAssignedToProfile.add(eachSFM.SVMXC__Dispatch_Process__c);
        }
        setSFMsAssignedToOtherProfiles.removeAll(setSFMsAssignedToProfile);

        strSOQLAssignedSFMs = 'SELECT count() FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = \'Service Flow Access\' AND SVMXC__Access_Configuration_Profile__c =: svmxProfileId AND LastModifiedDate >: lastSyncTimeConfig ALL ROWS';
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Integer intNoOfModifiedSFMs = Database.countQuery(strSOQLAssignedSFMs);
        system.debug('No. of Assigned SFM modified: - ' + intNoOfModifiedSFMs);
        if (intNoOfModifiedSFMs > 0) {
            return true;
        }
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        intNoOfModifiedSFMs = [SELECT count() FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Target Manager' AND ID NOT IN :setSFMsAssignedToOtherProfiles AND (LastModifiedDate > :lastSyncTimeConfig OR SVMXC__Page_Layout__r.LastModifiedDate > :lastSyncTimeConfig)];
        system.debug('No. of SFM modified: - ' + intNoOfModifiedSFMs);
        if (intNoOfModifiedSFMs > 0) {
            return true;
        }

        intNoOfModifiedSFMs = [SELECT count() FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Process Node Objects' AND SVMXC__Process__c NOT IN :setSFMsAssignedToOtherProfiles AND (LastModifiedDate > :lastSyncTimeConfig OR SVMXC__Submodule__r.LastModifiedDate > :lastSyncTimeConfig OR SVMXC__Module__r.LastModifiedDate > :lastSyncTimeConfig OR SVMXC__Final_Exception_Process__r.LastModifiedDate > :lastSyncTimeConfig)];
        if (intNoOfModifiedSFMs > 0) {
            return true;
        }

        return false;
    }

    private boolean isSFMWizardsChanged() {
        String strSOQLAssgndSFMWizards = 'SELECT SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = \'Wizard Access\'';
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        List<SVMXC__ServiceMax_Config_Data__c> lstAssgndSFMWizards = Database.query(strSOQLAssgndSFMWizards);
        Set<String> setWizardsAssignedToOtherProfiles = new Set<String>();
        Set<String> setWizardsAssignedToProfile = new Set<String>();
        for(SVMXC__ServiceMax_Config_Data__c eachWizard :lstAssgndSFMWizards){
            if(eachWizard.SVMXC__Access_Configuration_Profile__c != svmxProfileId)
                setWizardsAssignedToOtherProfiles.add(eachWizard.SVMXC__Dispatch_Process__c);
            if (eachWizard.SVMXC__Access_Configuration_Profile__c == svmxProfileId)
                setWizardsAssignedToProfile.add(eachWizard.SVMXC__Dispatch_Process__c);
        }
        setWizardsAssignedToOtherProfiles.removeAll(setWizardsAssignedToProfile);

        strSOQLAssgndSFMWizards = 'SELECT count() FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = \'Wizard Access\' AND SVMXC__Access_Configuration_Profile__c =: svmxProfileId AND LastModifiedDate >: lastSyncTimeConfig ALL ROWS';
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Integer intNoOfModifiedWizards = Database.countQuery(strSOQLAssgndSFMWizards);
        system.debug('No. of Assigned SFM Wizard modified: - ' + intNoOfModifiedWizards);

        if (intNoOfModifiedWizards > 0) {
            return true;
        }
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        intNoOfModifiedWizards = [SELECT count() FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Wizard' AND ID NOT IN :setWizardsAssignedToOtherProfiles AND (LastModifiedDate >: lastSyncTimeConfig OR SVMXC__Submodule__r.LastModifiedDate >: lastSyncTimeConfig)];
        system.debug('No. of SFM Wizard modified: - ' + intNoOfModifiedWizards);

        if (intNoOfModifiedWizards > 0) {
            return true;
        }

        intNoOfModifiedWizards = [SELECT count() FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Wizard Step' AND SVMXC__Module__c  NOT IN :setWizardsAssignedToOtherProfiles AND (LastModifiedDate >: lastSyncTimeConfig OR SVMXC__Submodule__r.LastModifiedDate >: lastSyncTimeConfig OR SVMXC__Process__r.LastModifiedDate >: lastSyncTimeConfig)];

        if (intNoOfModifiedWizards > 0) {
            return true;
        }

        return false;
    }

    private boolean isSVMXSettingsChanged() {
        string strSVMXSettings = 'Select count() from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c=\'Setting Value\' AND LastModifiedDate >:lastSyncTimeConfig AND ((SVMXC__Setting_ID__r.SVMXC__Search_Order__c IN (\'Group, Global\', \'Group,Global\') AND SVMXC__Setting_Configuration_Profile__c = \'' + svmxProfileId + '\') OR (SVMXC__Setting_ID__r.SVMXC__Search_Order__c = \'Global\' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true))';
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Integer noOfModifiedSettings = Database.countQuery(strSVMXSettings);
        system.debug('No. of SVMX Settings modified: - ' + noOfModifiedSettings);
        if(noOfModifiedSettings > 0){
            return true;
        }

        return false;
    }
    */
}