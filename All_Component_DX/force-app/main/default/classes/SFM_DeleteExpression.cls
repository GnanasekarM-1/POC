/* Security Scanned */
public with sharing class SFM_DeleteExpression {
    //Method to return exemptions
    public class SVMXException extends Exception {}
    
    public SFM_deleteExpression()
    {
        
    }
    public SFM_WrapperDef.SFM_Response SFM_deleteExpression(SFM_WrapperDef.SFM_Request request)
    {
        Boolean response_success;
        String response_message;
        String response_tagId;
        Boolean s;
        String msg;
        String tid;
        list<String> lstProcessName = new list<String>();
        map<String,String> mapExpressionLookupFields = new map<String,String>();
        map<String,String> mapConfigDataFields = new map<String,String>();
        mapExpressionLookupFields.put('SVMXC__Module__c','SVMXC__Module__c');
        mapExpressionLookupFields.put('SVMXC__Submodule__c','SVMXC__Submodule__c');
        mapExpressionLookupFields.put('SVMXC__Node_Parent__c','SVMXC__Node_Parent__c');
        mapExpressionLookupFields.put('SVMXC__Final_Exception_Process__c','SVMXC__Final_Exception_Process__c');
        mapExpressionLookupFields.put('SVMXC__Parent_Object__c','SVMXC__Parent_Object__c');
        mapExpressionLookupFields.put('SVMXC__Process__c','SVMXC__Process__c');
        mapExpressionLookupFields.put('SVMXC__Process1__c','SVMXC__Process1__c');
        mapExpressionLookupFields.put('SVMXC__Process2__c','SVMXC__Process2__c');
        mapExpressionLookupFields.put('SVMXC__Process3__c','SVMXC__Process3__c');
        mapConfigDataFields.put('SVMXC__Dispatch_Process__c','SVMXC__Dispatch_Process__c');
        mapConfigDataFields.put('SVMXC__Expression_Rule__c','SVMXC__Expression_Rule__c');
        mapConfigDataFields.put('SVMXC__Inventory_Process__c','SVMXC__Inventory_Process__c');
        mapConfigDataFields.put('SVMXC__MapID__c','SVMXC__MapID__c');
        mapConfigDataFields.put('SVMXC__MapID__c','SVMXC__MapID__c');
        String strWhereClause = '';
        list<string> lstExpressionId= new list<string>();
        list<string> lstProcessId= new list<string>();
        SVMX_Debug  log = new SVMX_Debug();
        list<SVMXC__ServiceMax_Processes__c> lstExpressionHeader= new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstExpressionDetails= new list<SVMXC__ServiceMax_Config_Data__c>();
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
        log.login('SFM_deleteExpression', 'SFM_deleteExpression(SFM_WrapperDef.SFM_Request_Expression)');
        Savepoint sp;
        try
        {
            sp = Database.setSavepoint();//Setting up save point
            system.debug('StringmapLength'+request.StringListMap.size());
            List<SFM_WrapperDef.SFM_StringListMap> requestedId = request.StringListMap;
            for(SFM_WrapperDef.SFM_StringListMap req: requestedId)
            {
                if(req.key.toUpperCase() == 'RECORDID'&& req.valueList.size() > 0){
                    lstExpressionId = req.valueList;
                }
                else if(req.key.toUpperCase() == 'PROCESSID'&& req.valueList.size() > 0){
                    lstProcessId = req.valueList;
                }
            }
            system.debug('lstProcessId'+lstProcessId);
            //Build WhereClause 
            if(mapExpressionLookupFields.size() > 0){
                for(String str : mapExpressionLookupFields.keyset()){
                    if(strWhereClause == ''){
                        strWhereClause +=  str +' IN: lstExpressionId';
                    }
                    else{
                        strWhereClause += ' OR '+str +' IN: lstExpressionId'; 
                    }
                }
            }
            system.debug('strWhereClause'+strWhereClause);
            list<SVMXC__ServiceMax_Processes__c> processNodeObject = new list<SVMXC__ServiceMax_Processes__c>();
            String strRecordType = 'Process Node Objects';
            String strQuery = 'Select Id, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where ';
            list<String> setProcessNodeId = new list<String>();
            map<String,String> mapProIdProName = new map<String,String>();
            if(lstProcessId.size() > 0 && lstExpressionId.size() > 0){
                system.debug('Process Id Present');
                //If Process id sent then get first process node object which are not associated with that process
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processNodeObject = [Select Id, SVMXC__Process__c,SVMXC__Process__r.SVMXC__Name__c From SVMXC__ServiceMax_Processes__c 
                                where Recordtype.Name='Process Node Objects' And SVMXC__Submodule__c IN : lstExpressionId and SVMXC__Process__c NOT IN : lstProcessId];
                system.debug('processNodeObject'+processNodeObject.size()+processNodeObject);
                if(processNodeObject.size() > 0){
                    for(SVMXC__ServiceMax_Processes__c svmxPro : processNodeObject){
                        mapProIdProName.put(svmxPro.SVMXC__Process__c,svmxPro.SVMXC__Process__r.SVMXC__Name__c);
                        setProcessNodeId.add(svmxPro.id);
                    }
                }
                lstProcessName.addall(mapProIdProName.values());
                system.debug('setProcessNodeId'+setProcessNodeId.size()+setProcessNodeId);
                if(lstProcessName.size() > 0)
                    throw new SVMXException(system.label.SFM001_TAG117+' '+String.valueof(lstProcessName).replace('(','').replace(')',''));
                /*if(setProcessNodeId.size() > 0)
                    strQuery += ' ( '+ strWhereClause+' ) AND Id NOT IN : setProcessNodeId';
                else*/
                strQuery += ' SVMXC__Record_Type_Name__c !=: strRecordType AND ( '+strWhereClause+' ) ';
            }   
            else if(lstProcessId.size() == 0 && lstExpressionId.size() > 0){
                system.debug('Process Id Not Present');
                //If Process id sent then get first process node object which are not associated with that process
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processNodeObject = [Select Id, SVMXC__Process__c,SVMXC__Process__r.SVMXC__Name__c From SVMXC__ServiceMax_Processes__c 
                                where Recordtype.Name='Process Node Objects' And SVMXC__Submodule__c IN : lstExpressionId];
                system.debug('processNodeObject'+processNodeObject.size()+processNodeObject);
                
                if(processNodeObject.size() > 0){
                    for(SVMXC__ServiceMax_Processes__c svmxPro : processNodeObject){
                        mapProIdProName.put(svmxPro.SVMXC__Process__c,svmxPro.SVMXC__Process__r.SVMXC__Name__c);
                        setProcessNodeId.add(svmxPro.id);
                    }
                    system.debug('setProcessNodeId'+setProcessNodeId);
                }
                lstProcessName.addall(mapProIdProName.values());
                //if(lstProcessName.size() > 0)
                    //throw new SVMXException(system.label.SFM001_TAG117+' '+String.valueof(lstProcessName).replace('(','').replace(')',''));
                if(setProcessNodeId.size() > 0)
                    strQuery += ' SVMXC__Record_Type_Name__c !=: strRecordType AND Id NOT IN : setProcessNodeId  AND ( '+ strWhereClause+' )';
                else
                    strQuery += ' SVMXC__Record_Type_Name__c !=: strRecordType AND ( '+strWhereClause+' ) ';
            }
            //strQuery += strWhereClause;
            list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
            system.debug('strQuery'+strQuery);
            lstProcess = database.query(strQuery);
            system.debug('lstProcess'+lstProcess);
            if(lstProcess.size() > 0){
                for(SVMXC__ServiceMax_Processes__c svmxPro : lstProcess){
                    lstProcessName.add(svmxPro.SVMXC__Name__c); 
                }
            }
            system.debug('lstProcessName'+lstProcessName);
            //Mobile Configuration
            list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstConfigData = [Select Id,SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN : lstExpressionId and RecordType.Name = 'Mobile Configuration'];
            system.debug('lstConfigData'+lstConfigData.size()+lstConfigData);
            if(lstConfigData.size() > 0){
                for(SVMXC__ServiceMax_Config_Data__c cd : lstConfigData){
                    lstProcessName.add(cd.SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c);
                }
            }
            //Check if there are any expressions configured in SPM Flow.
            Set<String> spmProcessNames = SPM_Utilities.getInstance().getAssociatedProcessNames(lstExpressionId);
            if(spmProcessNames != null && !spmProcessNames.isEmpty()) {
                lstProcessName.addAll(spmProcessNames);
            }
            
            if(lstProcessName.size() > 0)
                throw new SVMXException(system.label.SFM001_TAG117+' '+String.valueof(lstProcessName).replace('(','').replace(')',''));
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstExpressionHeader = [Select Id from SVMXC__ServiceMax_Processes__c where Id IN: lstExpressionId];
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstExpressionDetails = [Select Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN: lstExpressionId];
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            delete lstExpressionDetails;
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            delete lstExpressionHeader;              
            response_success = true;
        }
        catch(DmlException ex)
        {
            log.setlog('ERROR', ex.getDmlMessage(0));
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getDmlMessage(0);
            
        }
        catch(SVMXException ex){
            log.setlog('ERROR', ex.getmessage());
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getmessage();
        }
        catch(Exception ex){
            log.setlog('ERROR', ex.getmessage());
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getmessage();
        }
        log.logout();
        log.print();
        SFM_WrapperDef.SFM_Response oResponse=new SFM_WrapperDef.SFM_Response();
        oResponse.logMsg = log.getlog();
        oResponse.success = response_success;
        oResponse.message = response_message;
        return oResponse;
    }

}




/*log.setlog('SAVEPOINT', 'Setting up savepoint before cloning');
            sp = Database.setSavepoint();//Setting up save point
            
        if(ExpReq.expressions!=null && ExpReq.expressions.size()>0)
        {
            log.setlog('LOOPING-Start', 'To set HeaderExpression and the detailedexpression to delete the Expression');
            for(integer i=0;i<ExpReq.expressions.size();i++)
            {
                LstnamedExpression.add(ExpReq.expressions[i].namedExpression);
                LstexpressionDetails.addAll(ExpReq.expressions[i].expressionDetails);
            }
            log.setlog('LOOPING-End', 'To set HeaderExpression and the detailedexpression to delete the Expression');
        }
        log.setlog('DELETE', 'Deleting Namedexpression');
        delete LstnamedExpression;
        log.setlog('DELETE', 'Deleting Detailedexpression');
        delete LstexpressionDetails;
        response_success = true;*/