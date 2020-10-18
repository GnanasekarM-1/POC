/* Security Scanned */
public with sharing class SFM_CreateSubProcess 
{
    public SVMXC.SFM_WrapperDef.SFM_Response createSubProcess(String strSubProcessId, String strSourceRecordId, map<String,Schema.SObjectType> mapAllObjectDescribe, Sobject objTargetHeaderSobject)
    {
        //Since this steps happens in background, Don't required to convert datatime fields back to UserTimezone. Set Mode = background so that 
        //SFM_ParseProcess not convert datatime fields to UserTime Zone and SFM_SaveTargetReocrd not required to convert them back to GMT.
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> lstSFMStringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('SVMX_Execution_Mode','SVMXAUTO');
        lstSFMStringMap.add(stringMap);
        
        SVMXC.SFM_WrapperDef.SFM_Response sfmResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>(); 
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstProcess = [Select  SVMXC__Dispatch_Process_Status__c, SVMXC__ProcessID__c From SVMXC__ServiceMax_Processes__c where RecordType.Name =: 'Target Manager' and Id =: strSubProcessId];
        if(lstProcess.size() == 0)
        {
            sfmResponse.success = false;
            sfmResponse.message = system.label.SFM002_TAG066;
            return sfmResponse;
            
        }
        else if(lstProcess.size() > 0 && lstProcess[0].SVMXC__Dispatch_Process_Status__c != null && lstProcess[0].SVMXC__Dispatch_Process_Status__c.touppercase() != 'COMPLETE' )
        {
            sfmResponse.success = false;
            sfmResponse.message = system.label.SFM002_TAG065+' "'+ lstProcess[0].SVMXC__ProcessID__c+'"';
            return sfmResponse;
        }
        SVMXC.SFM_ParseProcess parseProcess = new SVMXC.SFM_ParseProcess();
        map<String,map<String,Sobject>> mapAliasNameSourceRecIdTargetObject = new map<String,map<String,Sobject>>();
        map<String,List<Sobject>> TargetRecMap = new map<String,List<Sobject>>();
        TargetRecMap = parseProcess.getSFM_ParseProcess2(strSubProcessId,strSourceRecordId,mapAllObjectDescribe,objTargetHeaderSobject,null,null,lstSFMStringMap);
        mapAliasNameSourceRecIdTargetObject = parseProcess.mapAliasNameSourceRecIdTargetObject;
        system.debug('mapAliasNameSourceRecIdTargetObject'+mapAliasNameSourceRecIdTargetObject);
        //Create SFM Target Record to save it.
        SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmTargetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        if(mapAliasNameSourceRecIdTargetObject.size() > 0)
        {
            SVMXC.SFM_Utils sfmutils = new SVMXC.SFM_Utils();
            sfmTargetRecord = sfmutils.buildSFMTargetRecord(strSubProcessId,mapAliasNameSourceRecIdTargetObject);
        }
        if(sfmTargetRecord != null)
        {
            SVMXC.SFM_SaveTargetRecords saveIt = new SVMXC.SFM_SaveTargetRecords();
            sfmResponse = saveIt.SaveTargetRecords(sfmTargetRecord);
        }
        return sfmResponse;
    
    }
    
}