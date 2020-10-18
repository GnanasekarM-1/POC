/* Security Scanned */
public with sharing class SFM_DeployServiceFlow {
    Boolean isSucess = TRUE;
    SVMX_Debug log = new SVMX_Debug();
    SFM_Utils clsUtils = new SFM_Utils();
    public SFM_DeployServiceFlow()
    {
    }
    
    public SFM_WrapperDef.SFM_Response SFM_DeployProcess(SFM_WrapperDef.SFM_Request_ProcessNodeInfo request)
    {
        SFM_WrapperDef.SFM_Response wrpResponse=new SFM_WrapperDef.SFM_Response();
        SFM_SaveProcess saveProcess = new SFM_SaveProcess();
        Set<String> setRequestedProcessName = new Set<String>();
        Set<String> setExistingProcessName = new Set<String>();
        List<String> lstCreatedProcessName = new List<String>();
        Map<String,String> mapProRequest = new Map<String,String>();
        mapProRequest = clsUtils.getStringMap(request.request.stringMap);
        
        //log.login('SFM_DeployProcess', 'SFM_DeployProcess\n');
        Savepoint sp = Database.setSavepoint();//Setting up save point
        try
        {
            SVMXC__ServiceMax_Processes__c objProcessHeaderDetail = request.processNodes;
            setRequestedProcessName.add(objProcessHeaderDetail.SVMXC__ProcessID__c);
            
            List<SVMXC__ServiceMax_Processes__c> lstAvailableprocessHeader = new List<SVMXC__ServiceMax_Processes__c>();
            
            lstAvailableprocessHeader = [Select Id, SVMXC__ProcessID__c, SVMXC__Purpose__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Target Manager' AND SVMXC__ProcessID__c IN :setRequestedProcessName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(lstAvailableprocessHeader != NULL && lstAvailableprocessHeader.size() > 0)
            {
            // Data already available, check for object definition and push only expression details
            for(SVMXC__ServiceMax_Processes__c objProcessHeader: lstAvailableprocessHeader)
            {
                setExistingProcessName.add(objProcessHeader.SVMXC__ProcessID__c);
                // Check whether both process are associate with same definitions
                if(objProcessHeader.SVMXC__Purpose__c == objProcessHeaderDetail.SVMXC__Purpose__c)
                {
                    if(objProcessHeader.Id == objProcessHeaderDetail.Id)
                    {
                        log.setlog('INFO', system.label.CONF019_TAG048);
                        SFM_WrapperDef.SFM_Response response = saveProcess.saveProcess(request);
                        if(response.success)
                            log.setlog('FINE', system.label.CONF019_TAG049);
                        else
                        {
                            isSucess = FALSE;
                            log.setlog('ERROR', system.label.CONF019_TAG050 + ' ' + objProcessHeader.SVMXC__ProcessID__c);
                            if(wrpResponse.logMsg != null)
                                wrpResponse.logMsg.addAll(response.logMsg);
                            else
                                wrpResponse.logMsg = response.logMsg;
                        }
                    }
                    // Send the existing process Id to flex
                    else
                    {
                        log.setlog('FINE', system.label.CONF019_TAG051);
                        wrpResponse.stringMap.add(new SFM_WrapperDef.SFM_StringMap('EXISTINGPROCESSID', objProcessHeader.Id));
                        break;
                    }
                }
                else
                {
                    isSucess = FALSE;
                    log.setlog('ERROR', system.label.CONF019_TAG050 + ' ' + objProcessHeader.SVMXC__ProcessID__c);
                    log.setlog('ERROR', system.label.CONF019_TAG053 + ' ' + objProcessHeader.SVMXC__Purpose__c);
                    log.setlog('ERROR', system.label.CONF019_TAG054 + ' ' + objProcessHeaderDetail.SVMXC__Purpose__c);
                }
            }
            }
            else
            {
                SFM_WrapperDef.SFM_Response resp = saveProcess.saveProcess(request);
                if(wrpResponse.logMsg != null)
                    wrpResponse.logMsg.addAll(resp.logMsg);
                else
                    wrpResponse.logMsg = resp.logMsg;
                isSucess = resp.success;
            }
            
        }
        catch (DmlException ex)
        {
            log.setlog('ERROR', ex.getDmlMessage(0));
            Database.rollback(sp);
            isSucess = false;
            wrpResponse.message = ex.getDmlMessage(0);
        }
        catch (Exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            Database.rollback(sp);//When fails rollback data donot commit
            isSucess = false;
            wrpResponse.message = ex.getmessage();
        }
        // Setup collective data
        List<String> lstRequestedMappings = new List<String>();
        List<String> lstExistingMappings = new List<String>();
        lstRequestedMappings.addAll(setRequestedProcessName);
        lstExistingMappings.addAll(setExistingProcessName);
        wrpResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('REQUEST', lstRequestedMappings));
        wrpResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('DEPLOYED_EXISTING', lstExistingMappings));
        wrpResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('DEPLOYED', lstCreatedProcessName));
        wrpResponse.resultIds.add(mapProRequest.get('PROCESSID'));
        if(wrpResponse.logMsg != null)
            wrpResponse.logMsg.addAll(log.getlog());
        else
            wrpResponse.logMsg = log.getlog();
        wrpResponse.success = isSucess;
        return wrpResponse;   
    }
}