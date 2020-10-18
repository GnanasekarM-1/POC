/*

*/
public with sharing class INTF_SFMEngine 
{

    /* #splitWork starts */
    public SVMXC.INTF_WebServicesDef.INTF_Response SVMX_ExecuteEngine(SVMXC.INTF_WebServicesDef.INTF_Request request){
        SFM_WrapperDef.SFM_TargetRecord sfmTargetRecord = getTargetRecord(request);
        INTF_SFMEngine sfmEngine = new INTF_SFMEngine();
        return sfmEngine.saveTargetRecord(sfmTargetRecord);        
    }
    /* #splitWork ends */ 
	
    public INTF_WebServicesDef.INTF_Response saveTargetRecord(SFM_WrapperDef.SFM_TargetRecord sfmTargetRecord){
        System.debug('sfmTargetRecord###inENGINE'+sfmTargetRecord);
        SVMXC.SFM_WrapperDef.SFM_Response sfmResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
        
        if(sfmTargetRecord != null) 
        {
            system.debug(LoggingLevel.WARN,'Query issued3: '+Limits.getQueries() + ' Heap Size: '+Limits.getHeapSize());
            SVMXC.SFM_SaveTargetRecords saveIt = new SVMXC.SFM_SaveTargetRecords();
            sfmResponse = saveIt.SaveTargetRecords(sfmTargetRecord);
            system.debug(LoggingLevel.WARN,'Query issued4: '+Limits.getQueries() + ' Heap Size: '+Limits.getHeapSize());
        } 
        if(sfmResponse.success)
        {    
            system.debug(LoggingLevel.WARN,'sfmResponse'+sfmResponse);
            list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstOutputStringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            SVMXC.INTF_WebServicesDef.INTF_StringMap strmap1 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
            strmap1.key ='HEADERTARGETRECID';
            if(sfmResponse.resultIds != null && sfmResponse.resultIds.size() > 0)
                strmap1.value = sfmResponse.resultIds[0];
            lstOutputStringMap.add(strmap1);
            response.stringMap = lstOutputStringMap;
            response.message = 'SUCCESS';
            response.success = true;
        }
        else
        {
            response.message = sfmResponse.message;
            response.success = sfmResponse.success;
            return response;
        }  
        return response;
    }
    public static SFM_WrapperDef.SFM_TargetRecord getTargetRecord(SVMXC.INTF_WebServicesDef.INTF_Request request){
        map<String,map<String,Sobject>> mapAliasNameSourceRecIdTargetObject = new map<String,map<String,Sobject>>();
        SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmTargetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        
        String strRecordId = '';
        string strProcessId = '';
        String headerTargetObject = '';
        String hdrTargetRecId = '';
        map<String,List<Sobject>> mapTargetRec = new map<String,List<Sobject>>();
        map<String,String> mapAliasParetnColumnName = new map<String,String>();
        SVMXC.SFM_parseProcess parseProcess = new SVMXC.SFM_parseProcess();
        SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        lstStringMap = request.StringMap;
        //if(lstStringMap.size() > 0) //#optiChange
       // {
            for(Integer i = 0;i<lstStringMap.size();i++)
            {
                if(lstStringMap[i].key != null && lstStringMap[i].key.toUppercase() == 'RECORDID')
                {
                    strRecordId = lstStringMap[i].value;
                }
                if(lstStringMap[i].key != null && lstStringMap[i].key.toUppercase() == 'TDMID')
                {
                    strProcessId = lstStringMap[i].value;
                } 
            }
       // }
        //Get the processNode objects
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SFM_ScheduledSFM_Utils.SFMProcess = new SVMXC__ServiceMax_Processes__c();
        list<SVMXC__ServiceMax_Processes__c> ProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SFM_ScheduledSFM_Utils.processNodeList = new list<SVMXC__ServiceMax_Processes__c>();
       // if(strProcessId != null && strProcessId.length() > 0) //#optiChange
        if(String.isNotBlank(strProcessId)) 
        {
            list<SVMXC__ServiceMax_Processes__c> ProList = new list<SVMXC__ServiceMax_Processes__c>();
            ProList = SFM_ScheduledSFM_Utils.querySFMProcess(strProcessId);
            
           // if(ProList.size() > 0) // #optiChange #newChange
           // {
                for(SVMXC__ServiceMax_Processes__c pro : ProList)
                {
                    if(pro.RecordType.Name == 'Target Manager'){
                        SFMProcess = pro;
                        SFM_ScheduledSFM_Utils.SFMProcess = pro;    
                    } else if(pro.RecordType.Name == 'Process Node Objects'){
                        ProcessNodeObjects.add(pro);
                        SFM_ScheduledSFM_Utils.processNodeList.add(pro);
                        if(pro.SVMXC__Type__c.touppercase() == 'TARGET')
                            headerTargetObject = pro.SVMXC__Source_Object_Name__c;
                        if(pro.SVMXC__Page_Layout__c != null && pro.SVMXC__Parent_Column_Name__c != null)
                            mapAliasParetnColumnName.put(String.valueof(pro.SVMXC__Page_Layout__c).substring(0,15),pro.SVMXC__Parent_Column_Name__c);   
                    }    
                }
                SFM_ScheduledSFM_Utils.processId = strProcessId;
            //}
            
        } 
        
        system.debug(LoggingLevel.WARN,'headerTargetObject'+headerTargetObject);
        system.debug(LoggingLevel.WARN,'mapAliasParetnColumnName'+mapAliasParetnColumnName);
        //try
        // {
        //Call Parse Process 
        system.debug(LoggingLevel.WARN,'Query issued: '+Limits.getQueries());
        
        // Create Stringmap for SFM_ParseProcess to say it's Background execution
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> lstSFMStringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('SVMX_Execution_Mode','SVMXAUTO');
        lstSFMStringMap.add(stringMap);
        
       // if(strRecordId != null && strRecordId.length() > 0 && strProcessId != null && strProcessId.length() > 0) //#optiChange
       if(String.isNotBlank(strRecordId) && String.isNotBlank(strProcessId)) 
        {
            // mapTargetRec =  parseProcess.getSFM_ParseProcess2(strProcessId,strRecordId,allobjmap,null,null,null,lstSFMStringMap); // #optiChange
            mapTargetRec =  parseProcess.getSFM_ParseProcess2(strProcessId,strRecordId,null,null,null,null,lstSFMStringMap); // #optiChange
            mapAliasNameSourceRecIdTargetObject = parseProcess.mapAliasNameSourceRecIdTargetObject;
            system.debug(LoggingLevel.WARN,'mapTargetRec'+mapTargetRec+mapTargetRec.size());
            system.debug(LoggingLevel.WARN,'mapAliasNameSourceRecIdTargetObject'+mapAliasNameSourceRecIdTargetObject);
        }
       // else if(strProcessId != null && strProcessId.length() > 0 && (strRecordId == null && strRecordId.length() == 0))  // #optiChange
       else if(String.isNotBlank(strProcessId) && String.isBlank((strRecordId)))
        {
            // mapTargetRec = parseProcess.getSFM_ParseProcess2(strProcessId,null,allobjmap,null,null,null,lstSFMStringMap); // #optiChange
            mapTargetRec = parseProcess.getSFM_ParseProcess2(strProcessId,null,null,null,null,null,lstSFMStringMap); // #optiChange
            system.debug(LoggingLevel.WARN,'mapTargetRec'+mapTargetRec);
        }
        system.debug(LoggingLevel.WARN,'mapTargetRec'+mapTargetRec+mapTargetRec.size());
        system.debug(LoggingLevel.WARN,'mapAliasNameSourceRecIdTargetObject'+mapAliasNameSourceRecIdTargetObject);
        system.debug(LoggingLevel.WARN,'Query issued1: '+Limits.getQueries() + ' Heap Size '+Limits.getHeapSize());
        //Get the result and convert it to SFM_TargetRecord to save it.
        SVMXC.SFM_WrapperDef.SFM_Response sfmResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        if(mapTargetRec != null && mapTargetRec.size() > 0 && mapAliasNameSourceRecIdTargetObject.size() == 0)
        {
            system.debug(LoggingLevel.WARN, 'If condition execution');
            SVMXC.SFM_Utils sfmutils = new SVMXC.SFM_Utils();
            sfmTargetRecord = sfmutils.buildSFMTargetRecord1(SFMProcess.SVMXC__ProcessID__c,mapTargetRec);
            system.debug(LoggingLevel.WARN, 'build SFMTarget Record Response: ' + sfmTargetRecord);
        }
        else if((mapTargetRec == null  || (mapTargetRec != null && mapTargetRec.size() == 0)) && mapAliasNameSourceRecIdTargetObject.size() > 0)
        {
            system.debug(LoggingLevel.WARN, 'Else if condition execution');
            SVMXC.SFM_Utils sfmutils = new SVMXC.SFM_Utils(); 
            sfmTargetRecord = sfmutils.buildSFMTargetRecord(SFMProcess.SVMXC__ProcessID__c,mapAliasNameSourceRecIdTargetObject);
            system.debug(LoggingLevel.WARN, 'build SFMTarget Record Response: ' + sfmTargetRecord);
        }
        system.debug(LoggingLevel.WARN, 'build SFMTarget Record Response: ' + sfmTargetRecord);
        system.debug(LoggingLevel.WARN,'sfmTargetRecord'+mapTargetRec+mapTargetRec.size());
        system.debug(LoggingLevel.WARN,'Query issued2: '+Limits.getQueries() + ' Heap Size: '+Limits.getHeapSize());
        //After converting it SFM_TargetRecord call Save method to save it.
        System.debug('in getTargetRecord method@@@@'+sfmTargetRecord);
        return sfmTargetRecord;
        
        
    }
}