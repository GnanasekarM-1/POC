/* Security Scanned */
public with sharing class SFM_DeleteObjectMapping {
  //Method to return exemptions
    public class SVMXException extends Exception {}
    
    public SFM_deleteObjectMapping()
    {
        
    }
    public SFM_WrapperDef.SFM_Response SFM_deleteObjectMapping(SFM_WrapperDef.SFM_Request ObjReq){
        Boolean response_success;
        String response_message;
        String response_tagId;
        String tid;
        List<String> resultIds=new List<String>();
        SVMX_Debug  log = new SVMX_Debug();
        SFM_Utils utils = new SFM_Utils();
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringListMap> request = new List<SFM_WrapperDef.SFM_StringListMap>();
        request = ObjReq.StringListMap;
        list<string> LstObjectMapId = new list<string>();
        list<SVMXC__ServiceMax_Processes__c >   LstObjectMap = new list<SVMXC__ServiceMax_Processes__c >(); 
        list<SVMXC__ServiceMax_Config_Data__c> LstField= new list<SVMXC__ServiceMax_Config_Data__c>();
        List<SFM_WrapperDef.SFM_ObjectMap> LstSFM_Obj = new List<SFM_WrapperDef.SFM_ObjectMap>();
        String strWhereClause = '';
        list<String> lstProcessName = new list<String>();
        map<String,String> mapFieldMapLookupFields = new map<String,String>();
        mapFieldMapLookupFields.put('SVMXC__Module__c','SVMXC__Module__c');
        mapFieldMapLookupFields.put('SVMXC__Submodule__c','SVMXC__Submodule__c');
        mapFieldMapLookupFields.put('SVMXC__Node_Parent__c','SVMXC__Node_Parent__c');
        mapFieldMapLookupFields.put('SVMXC__Final_Exception_Process__c','SVMXC__Final_Exception_Process__c');
        mapFieldMapLookupFields.put('SVMXC__Parent_Object__c','SVMXC__Parent_Object__c');
        mapFieldMapLookupFields.put('SVMXC__Process__c','SVMXC__Process__c');
        mapFieldMapLookupFields.put('SVMXC__Process1__c','SVMXC__Process1__c');
        mapFieldMapLookupFields.put('SVMXC__Process2__c','SVMXC__Process2__c');
        mapFieldMapLookupFields.put('SVMXC__Process3__c','SVMXC__Process3__c');
        log.login('SFM_deleteObjectMapping', 'SFM_deleteObjectMapping(SFM_WrapperDef.SFM_Request_ObjectMap)');
        Savepoint sp;
        try
        {
            log.setlog('SAVEPOINT', 'Setting up savepoint before cloning');
            sp = Database.setSavepoint();//Setting up save point
            list<String>  lstMappinId = new List<String> ();
            list<String>  lstProcessId = new List<String> ();
            for(SFM_WrapperDef.SFM_StringListMap str: request)
            {
                if(str.key == 'RECORDID')
                    lstMappinId = str.valueList;
                else if(str.key == 'PROCESSID')
                    lstProcessId = str.valueList;    
            }
            system.debug('lstMappinId'+lstMappinId);
            system.debug('lstProcessId'+lstProcessId);
            //Build WhereClause 
            if(mapFieldMapLookupFields.size() > 0){
              for(String str : mapFieldMapLookupFields.keyset()){
                if(strWhereClause == ''){
                  strWhereClause +=  str +' IN: lstMappinId';
                }
                else{
                  strWhereClause += ' OR '+str +' IN: lstMappinId'; 
                }
              }
            }
            system.debug('strWhereClause'+strWhereClause);
            list<SVMXC__ServiceMax_Processes__c> processNodeObject = new list<SVMXC__ServiceMax_Processes__c>();
            String strRecordType = 'Process Node Objects';
            String strQuery = 'Select Id, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where ';
            list<String> setProcessNodeId = new list<String>();
            map<String,String> mapProIdProName = new map<String,String>();
            if(lstProcessId.size() > 0 && lstMappinId.size() > 0){
               system.debug('Process Id Present');
               //If Process id sent then get first process node object which are not associated with that process
               //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
               processNodeObject = [Select Id, SVMXC__Process__c,SVMXC__Process__r.SVMXC__Name__c From SVMXC__ServiceMax_Processes__c 
                      where Recordtype.Name='Process Node Objects' and SVMXC__Process__c NOT IN : lstProcessId And (SVMXC__Module__c  IN : lstMappinId OR SVMXC__Final_Exception_Process__c  IN : lstMappinId)];
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
          throw new SVMXException(system.label.SFM001_TAG108+' '+String.valueof(lstProcessName).replace('(','').replace(')',''));
              /*if(setProcessNodeId.size() > 0)
              strQuery += ' ( '+ strWhereClause+' ) AND Id NOT IN : setProcessNodeId';
            else*/
            strQuery += ' SVMXC__Record_Type_Name__c !=: strRecordType AND ( '+strWhereClause+' ) ';
          }  
            else if(lstProcessId.size() == 0 && lstMappinId.size() > 0){
              system.debug('Process Id Not Present');
              //If Process id sent then get first process node object which are not associated with that process
              //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
               processNodeObject = [Select Id, SVMXC__Process__c,SVMXC__Process__r.SVMXC__Name__c From SVMXC__ServiceMax_Processes__c 
                      where Recordtype.Name='Process Node Objects' And (SVMXC__Module__c  IN : lstMappinId OR SVMXC__Final_Exception_Process__c  IN : lstMappinId)];
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
          //throw new SVMXException(system.label.SFM001_TAG108+' '+String.valueof(lstProcessName).replace('(','').replace(')',''));
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
            if(lstProcessName.size() > 0)
            throw new SVMXException(system.label.SFM001_TAG108+' '+String.valueof(lstProcessName).replace('(','').replace(')',''));
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            LstObjectMap = [Select id from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Object Mapping' AND Id IN :lstMappinId];
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            LstField = [Select id from SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c IN :lstMappinId and Recordtype.Name='Field Mapping'];
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            delete LstField;
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            delete LstObjectMap;
            response_success = true;
            
        }
          catch (DmlException ex)
        {
          log.setlog('ERROR', ex.getDmlMessage(0));
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getDmlMessage(0);
          
      }
        catch (Exception ex){
            log.setlog('ERROR', ex.getmessage());
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getmessage();
        }
        log.logout();
        log.print();
        SFM_WrapperDef.SFM_Response oResponse=new SFM_WrapperDef.SFM_Response(response_success,response_message,tid,stringMap,log.getlog(),resultIds);
        return oResponse;
        
    }

}