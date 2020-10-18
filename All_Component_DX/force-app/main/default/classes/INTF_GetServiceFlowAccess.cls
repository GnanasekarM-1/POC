public with sharing class INTF_GetServiceFlowAccess 
{
    Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    Set<String> setAccessibleObjs = new Set<String>();
    public set<String> transactionalObjects = new set<String>();
    public set<String> lookupObjects = new set<String>();
    public Map<String, set<String>> mapObjectProcess = new Map<String, set<String>>();
    public Map<String , Set<String>> mapProcessObject = new Map<String, Set<String>>();
    public Map<String , String > mapProcessPurpose = new Map<String, String>();
    public Map<String , Set<String>> mapLookupObjectProcess = new Map<String , Set<String>>();
    
    public static String strLastRecName = null;
    public static String strProcessName = null;
    public static Boolean client = false;
    public Integer noOfRec = 20000; 
    integer intLimitPercent = 70;
    Integer intCPULimit,intHeapLimit,intQueryLimit,intQueryRowLimit;
            
    public INTF_GetServiceFlowAccess()
    {
        allObjs = Schema.getGlobalDescribe();
        for(String objName : allObjs.keySet())
        {
            try
            {
                if(allObjs.get(objName).getDescribe().isAccessible())
                    setAccessibleObjs.add(allObjs.get(objName).getDescribe().getName().toLowerCase());
                /*else    
                    system.debug(LoggingLevel.WARN, 'Object Name which is not accessible is ' + objName);*/
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception for Object Name = ' + objName + ': ' + ex.getMessage());
            }
        }
        Id svmxprofileId = new SYNC_Utility().getGroupProfileId(null,false);
        List<SVMXC__ServiceMax_Config_Data__c> lstSettings = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET011'}, svmxprofileId);
        if(lstSettings != null && lstSettings.size() > 0)
        {
            for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings)
            {
                intLimitPercent = Integer.valueOf(cnf.SVMXC__Internal_Value__c);
            }
        }
        System.debug('What is the percentage '+intLimitPercent);
        
        intCPULimit = intLimitPercent * Limits.getLimitCPUTime()/100;
        intHeapLimit = intLimitPercent * Limits.getLimitHeapSize()/100;
        intQueryLimit = intLimitPercent * Limits.getLimitQueries()/100;
        intQueryRowLimit = intLimitPercent * Limits.getLimitQueryRows()/100;
                
        if(client)
            noOfRec = 50;
    }
    public INTF_GetServiceFlowAccess(Map<String, Schema.SObjectType> allObjs)
    {
        allObjs = allObjs;
    }
    // Returns the SFM process for the requested type validating all profile access configured
    public Map<Id, SVMXC__ServiceMax_Processes__c> getAllowedProcesses(String strPurpose)
    {
        String profileId = UserInfo.getProfileId();
        List<SVMXC__ServiceMax_Config_Data__c> profileAccessLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> lstAllLayouts = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> allowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        set<Id> processAccessSet = new set<Id>();
        profileAccessLst = [SELECT Id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Configuration Access' AND SVMXC__Profile__c = :profileId];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        lstAllLayouts.putAll([Select Id, SVMXC__ProcessID__c,SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__Page_Layout__c FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= 'Target Manager' AND SVMXC__Purpose__c = :strPurpose]);
        
        List<SVMXC__ServiceMax_Config_Data__c> lstProcessAccess = [Select Id, SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Access_Configuration_Profile__c != NULL and SVMXC__RecordType_Name__c =: 'Service Flow Access'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        // Identify allowed process
        if(profileAccessLst != NULL && profileAccessLst.size() > 0)
        {
            List<SVMXC__ServiceMax_Config_Data__c> allowedProfileAccessLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SVMXC__ServiceMax_Config_Data__c access: lstProcessAccess)
            {
              for(SVMXC__ServiceMax_Config_Data__c profile: profileAccessLst)
              {
                  if(lstAllLayouts.containsKey(access.SVMXC__Dispatch_Process__c) && access.SVMXC__Access_Configuration_Profile__c == profile.SVMXC__Access_Configuration_Profile__c)
                  {
                  processAccessSet.add(access.SVMXC__Dispatch_Process__c);
                      allowedProcess.put(lstAllLayouts.get(access.SVMXC__Dispatch_Process__c).Id, lstAllLayouts.get(access.SVMXC__Dispatch_Process__c));
                  }
              }
            }
        }
        
        // If no access is defined get all processes
        if(processAccessSet.size() == 0)
        {
          // Get the process which are not associated any profiles
          for(SVMXC__ServiceMax_Processes__c proces: lstAllLayouts.values())
          {
              allowedProcess.put(proces.Id, proces);
          }
        }
        return allowedProcess;
    }
    
    public set<string> getSFWBasedSFMTransactionIds(string profileId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getSFWBasedSFMTransactionIds');
        set<String> wizards = new set<String>();
        set<String> sfms = new set<String>();
        set<String> sfactions = new set<String>();
        
        if(INTF_ServiceEventUtility.filterstoExclude != null)
        {
            if(INTF_ServiceEventUtility.filterstoExclude.wizards != null && INTF_ServiceEventUtility.filterstoExclude.wizards.size() > 0)
            {
                wizards.addAll(INTF_ServiceEventUtility.filterstoExclude.wizards);
            }
            if(INTF_ServiceEventUtility.filterstoExclude.sfms != null && INTF_ServiceEventUtility.filterstoExclude.sfms.size() > 0)
            {
                sfms.addAll(INTF_ServiceEventUtility.filterstoExclude.sfms);
            }
            if(INTF_ServiceEventUtility.filterstoExclude.sfactions != null && INTF_ServiceEventUtility.filterstoExclude.sfactions.size() > 0)
            {
                sfactions.addAll(INTF_ServiceEventUtility.filterstoExclude.sfactions);
            }
        }
        
        SYNC_Utility utilityObj = new SYNC_Utility();
        Id usrSVMXProfileId = utilityObj.getGroupProfileId(profileId, false);
        INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: \'Wizard Access\' AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Dispatch_Process__c != null');
        List<SVMXC__ServiceMax_Config_Data__c> lstWizardAccess = [Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: 'Wizard Access' AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Dispatch_Process__c != null];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        set<string> setOfWizardToInclude = new set<string>();
        set<string> setOfWizardToExclude = new set<string>();
        set<string> setOfSFMProcesses = new set<string>();
        
        for(SVMXC__ServiceMax_Config_Data__c access: lstWizardAccess)
        {
            if(usrSVMXProfileId == access.SVMXC__Access_Configuration_Profile__c)
                setOfWizardToInclude.add(access.SVMXC__Dispatch_Process__c);
            else
                setOfWizardToExclude.add(access.SVMXC__Dispatch_Process__c);
        }
        setOfWizardToExclude.removeAll(setOfWizardToInclude);
        
        string strSOQLWizardStep = 'select SVMXC__Process__c from SVMXC__ServiceMax_Processes__c where ';
        string whereClauseWStep = '';
        if(setOfWizardToExclude != null && setOfWizardToExclude.size() > 0)
            whereClauseWStep += ' SVMXC__Module__c NOT IN: setOfWizardToExclude ';
        if(wizards != null && wizards.size() > 0)
        {
            if(whereClauseWStep.length() == 0)
                whereClauseWStep += ' SVMXC__Module__r.SVMXC__ProcessID__c NOT IN: wizards ';
            else
                whereClauseWStep += ' AND SVMXC__Module__r.SVMXC__ProcessID__c NOT IN: wizards ';
        }
        if(sfms != null && sfms.size() > 0)
        {
            if(whereClauseWStep.length() == 0)
                whereClauseWStep += ' SVMXC__Process__r.SVMXC__ProcessID__c NOT IN: sfms ';
            else
                whereClauseWStep += ' AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN: sfms ';
        }
        if(sfactions != null && sfactions.size() > 0)
        {
            if(whereClauseWStep.length() == 0)
                whereClauseWStep += ' SVMXC__Process__r.SVMXC__ProcessID__c NOT IN: sfactions ';
            else
                whereClauseWStep += ' AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN: sfactions ';
        }
        if(whereClauseWStep.length() == 0)
            whereClauseWStep += ' SVMXC__Module__r.SVMXC__Active__c = true AND (SVMXC__Action_Type__c = \'SFM\' OR SVMXC__Action_Type__c = \'OUTPUT_DOCUMENT\') AND Recordtype.Name=\'Wizard Step\' AND SVMXC__Process__r.SVMXC__Purpose__c NOT IN (\'VIEW RECORD\', \'STANDALONE CREATE\') ';
        else
            whereClauseWStep += ' AND SVMXC__Module__r.SVMXC__Active__c = true AND (SVMXC__Action_Type__c = \'SFM\' OR SVMXC__Action_Type__c = \'OUTPUT_DOCUMENT\') AND Recordtype.Name=\'Wizard Step\' AND SVMXC__Process__r.SVMXC__Purpose__c NOT IN (\'VIEW RECORD\', \'STANDALONE CREATE\') ';
        
        system.debug('Wizard Step Query Prepared: ' + strSOQLWizardStep + ' :: ' + whereClauseWStep);
        system.debug('Wizard Step Query Data: wizards - ' + wizards + ' :: sfms - ' + sfms + ' :: sfactions - ' + sfactions);
        
        INTF_DataSync.logSOQL(intMethodCount,strSOQLWizardStep + whereClauseWStep);
        for(SVMXC__ServiceMax_Processes__c WS : database.query(strSOQLWizardStep + whereClauseWStep))
            setOfSFMProcesses.add(WS.SVMXC__Process__c);
        
        string strSOQLLinkedPro = 'select Id, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__Process3__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = \'Linked Process\'';
        if(sfms != null && sfms.size() > 0)
            strSOQLLinkedPro += ' AND SVMXC__Process1__r.SVMXC__ProcessID__c NOT IN: sfms AND SVMXC__Process2__r.SVMXC__ProcessID__c NOT IN: sfms AND SVMXC__Process3__r.SVMXC__ProcessID__c NOT IN: sfms ';
        
        INTF_DataSync.logSOQL(intMethodCount,strSOQLLinkedPro);
        for(SVMXC__ServiceMax_Processes__c lnkPro: database.query(strSOQLLinkedPro))
        {
            setOfSFMProcesses.add(lnkPro.SVMXC__Process1__c);
            setOfSFMProcesses.add(lnkPro.SVMXC__Process2__c);
            setOfSFMProcesses.add(lnkPro.SVMXC__Process3__c);
        }
        
        set<string> setEventObjects = new set<string>{'Event', 'SVMXC__SVMX_Event__c'};
        string strSOQLPNOEvents = 'select id, SVMXC__Source_Object_Name__c, SVMXC__Process__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Process Node Objects\' AND SVMXC__Source_Object_Name__c IN: setEventObjects';
        if(sfms != null && sfms.size() > 0)
        {
            strSOQLPNOEvents += ' AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN: sfms ';
        }
        INTF_DataSync.logSOQL(intMethodCount,strSOQLPNOEvents);
        for(SVMXC__ServiceMax_Processes__c eventPro:database.query(strSOQLPNOEvents))
        {
            setOfSFMProcesses.add(eventPro.SVMXC__Process__c);
        } 
        
        INTF_DataSync.logMethodEndTS(intMethodCount ,'getSFWBasedSFMTransactionIds');
        return setOfSFMProcesses;
    }
    
    public Map<Id, SVMXC__ServiceMax_Processes__c> INTF_getAllAllowedProcessed(String profileId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('INTF_getAllAllowedProcessed');
        Map<Id, SVMXC__ServiceMax_Processes__c> mapAllowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> mapAllowedTempProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> mapTempProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        
        set<string> setSFMProcessesToInclude = getSFWBasedSFMTransactionIds(profileId);
        
        List<String> listProcess = new List<String>();
        listProcess.add('VIEW RECORD');
        listProcess.add('STANDALONE CREATE');
        listProcess.add('STANDALONE EDIT');
        listProcess.add('SOURCE TO TARGET ALL');
        listProcess.add('SOURCE TO TARGET CHILD');
        listProcess.add('OUTPUT DOCUMENT');
        
        Integer i=0,j=0;
        // For initial sync the process type is VIEW RECORD
        if(strProcessName == null)
            strProcessName = listProcess[0];
        for(i=0; i<listProcess.size(); i++)
        {
            if(strProcessName == listProcess[i])
            {
                if(listProcess[i] != 'VIEW RECORD' && listProcess[i] != 'STANDALONE CREATE')
                    mapTempProcess = getProfileBasedProcesses(listProcess[i], profileId, setSFMProcessesToInclude);
                else
                    mapTempProcess = getProfileBasedProcesses(listProcess[i], profileId, null);
                    
                mapAllowedTempProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
                if(mapTempProcess != NULL && mapTempProcess.size() > 0)
                {
                    mapAllowedProcess.putAll(mapTempProcess);
                    mapAllowedTempProcess.putAll(mapTempProcess);
                }
                
                // If we haven't reached the limit(Query Record)
                if(noOfRec <= 0 || Limits.getCPUTime()>=intCPULimit || Limits.getHeapSize() >=intHeapLimit || Limits.getQueries()>=intQueryLimit || Limits.getQueryRows()>=intQueryRowLimit)
                {
                    break;
                }
                // If the current process type still has records, continue retrieving the same
                if(strLastRecName != null)
                    i -= 1;
                // Else, start retrieving the next process type records
                else if(i < listProcess.size()-1)
                    strProcessName = listProcess[i+1];
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'INTF_getAllAllowedProcessed'); 
        return mapAllowedProcess;
    }
     
    public Map<Id, SVMXC__ServiceMax_Processes__c> getProfileBasedProcesses(String strPurpose, String profileId, set<string> setSFMProcessesToInclude)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getProfileBasedProcesses');
        Id usrSVMXProfileId;
        Map<Id, SVMXC__ServiceMax_Processes__c> mapIdProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> allowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        SYNC_Utility utilityObj = new SYNC_Utility();
        usrSVMXProfileId = utilityObj.getGroupProfileId(profileId, false);
        system.debug(LoggingLevel.Warn, 'Last Record Name: ' +  strLastRecName + '; Query row limit: ' + noOfRec + '; Process Type: ' + strPurpose);
        
        set<String> sfms = new set<String>();
        if(INTF_ServiceEventUtility.filterstoExclude != null)
        {
            if(INTF_ServiceEventUtility.filterstoExclude.sfms != null && INTF_ServiceEventUtility.filterstoExclude.sfms.size() > 0)
            {
                sfms.addAll(INTF_ServiceEventUtility.filterstoExclude.sfms);
            }
        }
        system.debug(loggingLevel.WARN, 'SFM Processes to be Filtered: ' + sfms);
        
        // For Initial Sync, strLastRecName will be null
        if(strLastRecName !=null)
        {
            String strLastRecord = strLastRecName.substring(strLastRecName.indexOf('|')+1);
            string strSOQL = 'Select Id, Name, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__Page_Layout__c, SVMXC__Doc_Template__c FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= \'Target Manager\' AND SVMXC__Purpose__c = :strPurpose AND SVMXC__Dispatch_Process_Status__c = \'Complete\' AND Name > :strLastRecord';
            
            if(strPurpose == 'OUTPUT DOCUMENT')
                strSOQL += ' AND SVMXC__Doc_Template__c != null';
            else
                strSOQL += ' AND SVMXC__Page_Layout__c != null';
            
            if(sfms != null && sfms.size() > 0)
                strSOQL += ' AND SVMXC__ProcessID__c NOT IN: sfms';
                
            if(setSFMProcessesToInclude != null && setSFMProcessesToInclude.size() > 0)
                strSOQL += ' AND ID IN: setSFMProcessesToInclude order by Name limit :noOfRec';
            else
                strSOQL += ' order by Name limit :noOfRec';
                
            system.debug(loggingLevel.WARN, 'SOQL For SFM Processes: ' + strSOQL);
            
            INTF_DataSync.logSOQL(intMethodCount, strSOQL);
            mapIdProcess.putAll((List<SVMXC__ServiceMax_Processes__c>)database.query(strSOQL));        
        }
        else
        {
            string strSOQL = 'Select Id, Name, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__Page_Layout__c, SVMXC__Doc_Template__c FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= \'Target Manager\' AND SVMXC__Purpose__c = :strPurpose AND SVMXC__Dispatch_Process_Status__c = \'Complete\'';
            
            if(strPurpose == 'OUTPUT DOCUMENT')
                strSOQL += ' AND SVMXC__Doc_Template__c != null';
            else
                strSOQL += ' AND SVMXC__Page_Layout__c != null';
            
            if(sfms != null && sfms.size() > 0)
                strSOQL += ' AND SVMXC__ProcessID__c NOT IN: sfms';
                
            if(setSFMProcessesToInclude != null && setSFMProcessesToInclude.size() > 0)
                strSOQL += ' AND ID IN: setSFMProcessesToInclude order by Name limit :noOfRec';
            else
                strSOQL += ' order by Name limit :noOfRec';
                
            system.debug(loggingLevel.WARN, 'SOQL For SFM Processes: ' + strSOQL);
            INTF_DataSync.logSOQL(intMethodCount, strSOQL);
            mapIdProcess.putAll((List<SVMXC__ServiceMax_Processes__c>)database.query(strSOQL));
        }
        system.debug(LoggingLevel.Warn, 'Number of processes returned:' + mapIdProcess.size());
        if(mapIdProcess != null && mapIdProcess.size() > 0)
        {
            // Last processed record name
            if(mapIdProcess.size() == noOfRec)
            {
                List<SVMXC__ServiceMax_Processes__c> lstTempProcesses = new List<SVMXC__ServiceMax_Processes__c>();
                List<String> lstTempNames = new List<String>();
                lstTempProcesses.addAll(mapIdProcess.values());
                for(SVMXC__ServiceMax_Processes__c obj : lstTempProcesses)
                {
                    lstTempNames.add(obj.Name);
                }
                // Performing sort to get last record name 
                lstTempNames.sort();
                strLastRecName = strProcessName + '|' + lstTempNames.get(lstTempNames.size() - 1);
                system.debug(LoggingLevel.WARN, 'strLastRecName: ' + strLastRecName);
            }
            // If there are no more processes of this type available
            else
            {
                strLastRecName = null;
            }
            
            set<Id> setProcessIdsWithTargetPNO = new set<Id>();
            set<Id> setProcessIdsToRemove = new set<Id>();
            INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Type__c, SVMXC__Doc_Template_Details__c, SVMXC__Page_Layout__c, SVMXC__Source_Object_Name__c, SVMXC__Process__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name=\'Process Node Objects\' And SVMXC__Process__c IN :mapIdProcess.keySet()');
            for(SVMXC__ServiceMax_Processes__c process : [Select Id, SVMXC__Type__c, SVMXC__Doc_Template_Details__c, SVMXC__Page_Layout__c, SVMXC__Source_Object_Name__c, SVMXC__Process__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Process Node Objects' And SVMXC__Process__c IN :mapIdProcess.keySet()])
            {
                if(!setAccessibleObjs.contains(process.SVMXC__Source_Object_Name__c.toLowerCase()))
                {
                    if(mapIdProcess.containsKey(process.SVMXC__Process__c))
                    {
                        //remove the SFM processes if the user is not having permission on objects on which those processes are defined.
                        mapIdProcess.remove(process.SVMXC__Process__c);
                        system.debug(LoggingLevel.WARN, 'Removed Process is ' + process.SVMXC__Process__c);
                    }
                }
                if(process.SVMXC__Type__c == 'TARGET' || process.SVMXC__Type__c == 'TARGETCHILD')
                {
                    if(process.SVMXC__Type__c == 'TARGET')
                        setProcessIdsWithTargetPNO.add(process.SVMXC__Process__c);
                    system.debug(loggingLevel.WARN, '==Process with Target Page layout/Doc template: ' + process + ' ==: ' + process.SVMXC__Page_Layout__c + ' ==: ' + process.SVMXC__Doc_Template_Details__c);
                    
                    if(process.SVMXC__Type__c == 'TARGETCHILD')
                        if(process.SVMXC__Page_Layout__c == null && process.SVMXC__Doc_Template_Details__c == null)
                            setProcessIdsToRemove.add(process.SVMXC__Process__c);
                }
            }
            
            system.debug(loggingLevel.WARN, '==Process with Target: ' + setProcessIdsWithTargetPNO);
            system.debug(loggingLevel.WARN, '==Process to Remove withour removing non target: ' + setProcessIdsToRemove);
            
            for(ID processID : mapIdProcess.keyset())
            {
                if(!setProcessIdsWithTargetPNO.contains(processID))
                    setProcessIdsToRemove.add(processID);
            }
            
            system.debug(loggingLevel.WARN, '==Process from Map: ' + mapIdProcess.keyset());
            system.debug(loggingLevel.WARN, '==Process to Remove: ' + setProcessIdsToRemove);
            
            if(setProcessIdsToRemove != null && setProcessIdsToRemove.size() > 0)
                for(ID processIdToRemove: setProcessIdsToRemove)
                    mapIdProcess.remove(processIdToRemove);
            system.debug(loggingLevel.WARN, '==Process from Map after removing: ' + mapIdProcess.keyset());
            
            //create map of PageLayoutIds and List of SFM Process Ids
            Map<Id, List<Id>> mapPageIdProcessId = new Map<Id, List<Id>>();
            for(SVMXC__ServiceMax_Processes__c SFMprocess : mapIdProcess.values())
            {
                if(!mapPageIdProcessId.containsKey(SFMprocess.SVMXC__Page_Layout__c))
                {
                    List<Id> lstIds = new List<Id>();
                    lstIds.add(SFMprocess.Id);
                    mapPageIdProcessId.put(SFMprocess.SVMXC__Page_Layout__c,lstIds);
                }   
                else
                {
                    mapPageIdProcessId.get(SFMprocess.SVMXC__Page_Layout__c).add(SFMprocess.Id);
                }
            }   
            
            INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Related_Object_Name__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN (Select Id from SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c in :mapPageIdProcessId.keySet() OR Id in :mapPageIdProcessId.keySet()) AND SVMXC__DataType__c = \'reference\'');
            for(SVMXC__Page_Layout_Detail__c pageLayoutDetail : [Select Id, SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Related_Object_Name__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN (Select Id from SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c in :mapPageIdProcessId.keySet() OR Id in :mapPageIdProcessId.keySet()) AND SVMXC__DataType__c = 'reference'])
            { 
                if(pageLayoutDetail.SVMXC__Related_Object_Name__c != null && pageLayoutDetail.SVMXC__Related_Object_Name__c != '')
                {
                    if(!setAccessibleObjs.contains(pageLayoutDetail.SVMXC__Related_Object_Name__c.toLowerCase()))
                    {
                        if(mapPageIdProcessId.containsKey(pageLayoutDetail.SVMXC__Page_Layout__c))
                        {
                            for(Id sfmProID : mapPageIdProcessId.get(pageLayoutDetail.SVMXC__Page_Layout__c))
                            {
                                mapIdProcess.remove(sfmProID);
                                system.debug(LoggingLevel.WARN, 'Removed Process is ' + sfmProID + ', Page Layout Id is ' + pageLayoutDetail.SVMXC__Page_Layout__c);
                            }
                        }
                        else if(pageLayoutDetail.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c != null && mapPageIdProcessId.containsKey(pageLayoutDetail.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c))
                        {
                            for(Id sfmProID : mapPageIdProcessId.get(pageLayoutDetail.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c))
                            {
                                mapIdProcess.remove(sfmProID);
                                system.debug(LoggingLevel.WARN, 'Removed Process is ' + sfmProID + ', Header Page Layout Id is ' + pageLayoutDetail.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c);
                            }
                        }
                    }
                }
            }
        }
        // If there are no more processes of this type available
        else
        {
            strLastRecName = null;
        }
        
        // If there are processes available after excluding those related to inaccessible objects,
        // check how many of these are available to the logged in user's SVMX Group Profile
        if(mapIdProcess != null && mapIdProcess.size() > 0)
        {
            Set<Id> setAllAccessProcessId = new Set<Id>();
            setAllAccessProcessId.addAll(mapIdProcess.keyset());
            List<SVMXC__ServiceMax_Config_Data__c> lstProcessAccess = new List<SVMXC__ServiceMax_Config_Data__c>();
            INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Service Flow Access\' AND SVMXC__Dispatch_Process__c In: setAllAccessProcessId');
            lstProcessAccess = [Select Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = 'Service Flow Access' AND SVMXC__Dispatch_Process__c In: setAllAccessProcessId];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
            if(usrSVMXProfileId != null)
            {
                set<Id> setProcessId = new set<Id>();
                set<Id> setProcessIdWithAccess = new set<Id>();
                for (SVMXC__ServiceMax_Config_Data__c ConfigObj : lstProcessAccess)
                {
                    if(ConfigObj.SVMXC__Access_Configuration_Profile__c != null)
                    {
                        if(usrSVMXProfileId == ConfigObj.SVMXC__Access_Configuration_Profile__c)
                            setProcessId.add(ConfigObj.SVMXC__Dispatch_Process__c);
                        else
                            setProcessIdWithAccess.add(ConfigObj.SVMXC__Dispatch_Process__c);
                    }
                }
                setAllAccessProcessId.removeAll(setProcessIdWithAccess);
                setAllAccessProcessId.addAll(setProcessId);
            }
            for(Id CurrentId : setAllAccessProcessId)
                allowedProcess.put(CurrentId, mapIdProcess.get(CurrentId));
        
            system.debug(LoggingLevel.WARN, 'ALLOWED PROCESS: ' + strPurpose + ':' + allowedProcess.size() + allowedProcess);
            noOfRec = noOfRec - allowedProcess.size();
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getProfileBasedProcesses');
        return allowedProcess;
    }
    
    public Map<Id, SVMXC__ServiceMax_Processes__c> getAllowedProcesses(String strPurpose, String profileId)
    {
        List<SVMXC__ServiceMax_Config_Data__c> profileAccessLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> lstAllProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> allowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        set<Id> processAccessSet = new set<Id>();
        if(profileId == NULL)
            profileAccessLst = [SELECT Id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Configuration Access' AND SVMXC__Profile__c = :UserInfo.getProfileId()];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        else
            profileAccessLst = [SELECT Id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Configuration Access' AND SVMXC__Profile__c = :UserInfo.getProfileId() AND SVMXC__Access_Configuration_Profile__c =: profileId];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        
        lstAllProcess.putAll([Select Id, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__Page_Layout__c FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= 'Target Manager' AND SVMXC__Purpose__c = :strPurpose]);  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        List<SVMXC__ServiceMax_Config_Data__c> lstProcessAccess = [Select Id, SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Access_Configuration_Profile__c != NULL and SVMXC__RecordType_Name__c =: 'Service Flow Access'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        // Identify allowed process
        if(profileAccessLst != NULL && profileAccessLst.size() > 0)
        {
            List<SVMXC__ServiceMax_Config_Data__c> allowedProfileAccessLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SVMXC__ServiceMax_Config_Data__c access: lstProcessAccess)
            {
              for(SVMXC__ServiceMax_Config_Data__c profile: profileAccessLst)
              {
                  if(lstAllProcess.containsKey(access.SVMXC__Dispatch_Process__c) && access.SVMXC__Access_Configuration_Profile__c == profile.SVMXC__Access_Configuration_Profile__c)
                  {
                      processAccessSet.add(access.SVMXC__Dispatch_Process__c);
                      allowedProcess.put(lstAllProcess.get(access.SVMXC__Dispatch_Process__c).Id, lstAllProcess.get(access.SVMXC__Dispatch_Process__c));
                  }
              }
            }
        }
        
        // If no access is defined get all processes
        if(processAccessSet.size() == 0)
        {
          // Get the process which are not associated any profiles
          for(SVMXC__ServiceMax_Processes__c proces: lstAllProcess.values())
          {
              allowedProcess.put(proces.Id, proces);
          }
        }
        return allowedProcess;
    }
    
    // Get objects for the process
    public void INTF_GetProcessObjects(Map<Id, SVMXC__ServiceMax_Processes__c> objProcess)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('INTF_GetProcessObjects');
        //INTF_GetDistinctTransactionalObj(objProcess);
        //INTF_GetDistinctMasterObj(objProcess);
        getTransactionalObj(objProcess);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'INTF_GetProcessObjects');
    }
    
    // Gets transactional objects related to the process
    public void INTF_GetDistinctTransactionalObj(Map<Id, SVMXC__ServiceMax_Processes__c> mapProcess)
    {
        List<SVMXC__ServiceMax_Processes__c> lstProcessDetails = [Select Id, SVMXC__Source_Object_Name__c, SVMXC__Process__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c IN :mapProcess.keySet() AND Recordtype.Name='Process Node Objects'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        // Get all main objects related to process
        for(SVMXC__ServiceMax_Processes__c processDetail: lstProcessDetails)
        {
            String APIName = processDetail.SVMXC__Source_Object_Name__c;
            if(!mapObjectProcess.containsKey(APIName))
                mapObjectProcess.put(APIName, new set<String>());
         
            mapObjectProcess.get(APIName).add(processDetail.SVMXC__Process__c);
       
            if(!mapProcessObject.containsKey(processDetail.SVMXC__Process__c))
                mapProcessObject.put(processDetail.SVMXC__Process__c, new set<String>());
       
            mapProcessObject.get(processDetail.SVMXC__Process__c).add(APIName);
         
            transactionalObjects.add(APIName);
        }
    }
    
    public void INTF_GetDistinctMasterObj(Map<Id, SVMXC__ServiceMax_Processes__c> mapProcess)
    {
        set<Id> setPageIds = new set<Id>();
        Map<Id, Id> mapProcessPage = new Map<Id, Id>();
    
        for(SVMXC__ServiceMax_Processes__c proces: mapProcess.values())
        {
            if(proces.SVMXC__Purpose__c != NULL)
                mapProcessPurpose.put(proces.Id, proces.SVMXC__Purpose__c);
            if(proces.SVMXC__Page_Layout__c != NULL)
            {
                mapProcessPage.put(proces.Id, proces.SVMXC__Page_Layout__c);
                setPageIds.add(proces.SVMXC__Page_Layout__c);
            }
        }
        
        // Get page details and identify the reference fields
        List<SVMXC__Page_Layout_Detail__c> lstProcessPageDetails = [Select Id, SVMXC__Page_Layout__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN :setPageIds AND SVMXC__DataType__c = 'reference'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
     
        for(SVMXC__Page_Layout_Detail__c pageDetail: lstProcessPageDetails)
        {
            if(!transactionalObjects.contains(pageDetail.SVMXC__Related_Object_Name__c))
            {
                String APIName = pageDetail.SVMXC__Related_Object_Name__c;
                lookupObjects.add(APIName);
                for(String procesId: mapProcessPage.keyset())
                {
                    if(mapProcessPage.get(procesId) == pageDetail.SVMXC__Page_Layout__c)
                    {
                        if(!mapLookupObjectProcess.containsKey(APIName))
                            mapLookupObjectProcess.put(APIName, new set<String>());
                        mapLookupObjectProcess.get(APIName).add(procesId);
             
                        if(!mapObjectProcess.containsKey(APIName))
                            mapObjectProcess.put(APIName, new set<String>());
                        mapObjectProcess.get(APIName).add(procesId);
             
             
                        if(!mapProcessObject.containsKey(procesId))
                            mapProcessObject.put(procesId, new set<String>());
               
                        mapProcessObject.get(procesId).add(APIName);
                    }
                }
            }
        }
    }
    
    public void getTransactionalObj(Map<Id, SVMXC__ServiceMax_Processes__c> mapProcess)
    {
        integer intMethodCount = INTF_DataSync.logMethodStartTS('getTransactionalObj');
        INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Page_Layout__c, SVMXC__Source_Object_Name__c, SVMXC__Process__c, SVMXC__Process__r.SVMXC__Page_Layout__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c IN :mapProcess.keySet() AND Recordtype.Name=\'Process Node Objects\'');
        List<SVMXC__ServiceMax_Processes__c> lstProcessNodeObjects = [Select Id, SVMXC__Page_Layout__c, SVMXC__Source_Object_Name__c, SVMXC__Process__c, SVMXC__Process__r.SVMXC__Page_Layout__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c IN :mapProcess.keySet() AND Recordtype.Name='Process Node Objects'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        set<string> setPgLayoutIds = new set<string>();
        map<string, List<string>> mapPageToProcesses = new map<string, List<string>>();
        for(SVMXC__ServiceMax_Processes__c processDetail: lstProcessNodeObjects)
        {
            String APIName = processDetail.SVMXC__Source_Object_Name__c;
            if(!mapObjectProcess.containsKey(APIName))
                mapObjectProcess.put(APIName, new set<String>());
         
            mapObjectProcess.get(APIName).add(processDetail.SVMXC__Process__c);
       
            if(!mapProcessObject.containsKey(processDetail.SVMXC__Process__c))
                mapProcessObject.put(processDetail.SVMXC__Process__c, new set<String>());
       
            mapProcessObject.get(processDetail.SVMXC__Process__c).add(APIName);
         
            transactionalObjects.add(APIName);
            
            if(processDetail.SVMXC__Page_Layout__c != null)
            {
                setPgLayoutIds.add(processDetail.SVMXC__Page_Layout__c);
                if(!mapPageToProcesses.containsKey(processDetail.SVMXC__Page_Layout__c))
                    mapPageToProcesses.put(processDetail.SVMXC__Page_Layout__c, new List<string>());
                mapPageToProcesses.get(processDetail.SVMXC__Page_Layout__c).add(processDetail.SVMXC__Process__c);
            }
            if(processDetail.SVMXC__Process__r.SVMXC__Page_Layout__c != null)
            {
                setPgLayoutIds.add(processDetail.SVMXC__Process__r.SVMXC__Page_Layout__c);
                if(!mapPageToProcesses.containsKey(processDetail.SVMXC__Process__r.SVMXC__Page_Layout__c))
                    mapPageToProcesses.put(processDetail.SVMXC__Process__r.SVMXC__Page_Layout__c, new List<string>());
                mapPageToProcesses.get(processDetail.SVMXC__Process__r.SVMXC__Page_Layout__c).add(processDetail.SVMXC__Process__c);
            }
        }
        if(transactionalObjects.contains('SVMXC__Checklist__c')){
            transactionalObjects.add('SVMXC__SM_Checklist_Attachment__c'); //If there is a process on Checklist object, include Checklist_Attachment object name
        }        
        INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Page_Layout__c, SVMXC__Related_Object_Name__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN :setPgLayoutIds AND SVMXC__DataType__c = \'reference\'');
        List<SVMXC__Page_Layout_Detail__c> lstProcessPageDetails = [Select Id, SVMXC__Page_Layout__c, SVMXC__Related_Object_Name__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN :setPgLayoutIds AND SVMXC__DataType__c = 'reference'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        for(SVMXC__Page_Layout_Detail__c pageDetail: lstProcessPageDetails)
        {
            List<string> processIds = mapPageToProcesses.get(pageDetail.SVMXC__Page_Layout__c);
            string objAPIName = pageDetail.SVMXC__Related_Object_Name__c;
            
            for(string strProcessId: processIds)
            {
                if(!mapProcessObject.containsKey(strProcessId))
                    mapProcessObject.put(strProcessId, new set<String>());
                mapProcessObject.get(strProcessId).add(objAPIName);
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getTransactionalObj');
    }
}