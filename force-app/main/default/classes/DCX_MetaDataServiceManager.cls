/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * Metadata Service manager which has business logic for all the services, related to user settings and svmx settings, re-written for DCx
 * @author Sandeep Dhariwal
 * @version 19.2000
 * @since 2019
 */
public with sharing class DCX_MetaDataServiceManager {
    
    public static metaDataSetting fetchMetaData() {
        long startDC = DateTime.Now().getTime();
        metaDataSetting metaDataSet = new metaDataSetting();
        String userId = String.Valueof(UserInfo.getUserId());
        List<SFM_WrapperDef.FieldProperties> fieldPropertyList;
        Boolean isTextArea;
        
        try {

            long startDisp = DateTime.Now().getTime();
            metaDataSet.displayTags = 
                DCX_Retrieve_Display_Tags_WS(userId);
            long stopDisp = DateTime.Now().getTime();
            system.debug('Time takenx for DCON_Retrieve_Display_Tags_WS: '+(stopDisp-startDisp));

            long startTZ = DateTime.Now().getTime();
            metaDataSet.timeZoneInfo = DCX_GetAllTimeZone_WS(userId);
            long stopTZ = DateTime.Now().getTime();
            system.debug('Time takenx for DCON_GetAllTimeZone_WS: '+(stopTZ-startTZ));
            
            long startGO = DateTime.Now().getTime();
            SVMX_Response objectFieldInfo = 
                new SVMX_Response();
            objectFieldInfo = DCX_getObjectFieldList_WS();
            long stopGO = DateTime.Now().getTime();
            system.debug('Time takenx for DCON_getObjectFieldList_WS: '+(stopGO-startGO));
            
            long startSFM = DateTime.Now().getTime();
            fieldPropertyList = new List<SFM_WrapperDef.FieldProperties>();
            metaDataSet.sfmWorkOrderFields = 
                SFM_WebServicesDef.SFM_getObjectFieldList_WS(setSFMFieldsWrapper('SVMXC__Service_Order__c','SCREEN'));
                long stopSFM = DateTime.Now().getTime();
                system.debug('Time takenx for Work Order SFM_getObjectFieldList_WS: '+(stopSFM-startSFM));
            
            long startEv = DateTime.Now().getTime();
            // get skills
            long startskill = DateTime.Now().getTime();
            metaDataSet.skills = getSkillDetails();
            long stopskill = DateTime.Now().getTime();
            system.debug('Time takenx for getSkillDetails: '+(stopskill-startskill));
            metaDataSet.sfmEventFields = fetchEventColorFields();
            metaDataSet.sfmServiceGroupMembers = fetchFields('SVMXC__Service_Group_Members__c');
            metaDataSet.sfmServiceGroup = fetchFields('SVMXC__Service_Group__c');
            long stopEv = DateTime.Now().getTime();
            system.debug('Time takenx for Event SFM_getObjectFieldList_WS: '+(stopEv-startEv));
            
        } catch (Exception ex) {
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
        long stopDC = DateTime.Now().getTime();
        system.debug('Time taken for fetchMetaDataSettings: '+(stopDC-startDC));
        return metaDataSet;
    }

    public static SFM_WrapperDef.SFM_Request setSFMFieldsWrapper (String objectName, String objectType) {
        SFM_WrapperDef.SFM_Request wrapper = new SFM_WrapperDef.SFM_Request();
        List<SFM_WrapperDef.SFM_StringMap> sfmMaps = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap sfmMap;
        sfmMap = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME',objectName);
        sfmMaps.add(sfmMap);
        sfmMap = new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE',objectType);
        sfmMaps.add(sfmMap);
        wrapper.setstringMap(sfmMaps);
        return wrapper;
    }

    public static List<objFieldInfo> fetchEventColorFields() {
        List<String> evtFields = new List<string> {'Id', 'Subject','DurationInMinutes','Description','WhatId','WhoId','ActivityDate','ActivityDateTime','StartDateTime','EndDateTime','Location','LastModifiedDate','SVMXC__Driving_Time__c','SVMXC__Overhead_Time_Before__c','SVMXC__Overhead_Time_After__c','SVMXC__Driving_Time_Home__c','SVMXC__Service_Duration__c','SVMXC__Break_Time_Total__c','Type','IsAllDayEvent','SVMXC__SM_Latitude__c','SVMXC__SM_Longitude__c'};
        List<objFieldInfo> eventFields = new List<objFieldInfo>();
        List<String> fieldList = new List<String>();
        List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
        Map<String, Schema.SObjectField> fieldMap = Event.sObjectType.getDescribe().fields.getMap();
        Schema.SObjectField fieldN;
        Schema.DescribeFieldResult fieldDes;
        String defaultVal;
        map<string, object> mapToSerialize = new map<string, object>();
        eventFields.add(new objFieldInfo('Id','Activity Id','id',String.Valueof(fieldMap.get('Id').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('Subject','Subject','subject',String.Valueof(fieldMap.get('Subject').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('DurationInMinutes','Duration','durationInMinutes',String.Valueof(fieldMap.get('DurationInMinutes').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('Description','Description','description',String.Valueof(fieldMap.get('Description').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('WhatId','Related To','whatId',String.Valueof(fieldMap.get('WhatId').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('WhoId','Name','whoId',String.Valueof(fieldMap.get('WhoId').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('ActivityDate','Due Date Only','activityDate',String.Valueof(fieldMap.get('ActivityDate').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('ActivityDateTime','Due Date Time','activityDateTime',String.Valueof(fieldMap.get('ActivityDateTime').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('StartDateTime','Start','startDateTime',String.Valueof(fieldMap.get('StartDateTime').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('EndDateTime','End','endDateTime',String.Valueof(fieldMap.get('EndDateTime').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('Location','Location','location',String.Valueof(fieldMap.get('Location').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('LastModifiedDate','Last Modified Date','lastModifiedDateTime',String.Valueof(fieldMap.get('LastModifiedDate').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('SVMXC__Driving_Time__c','Travel Time to Workorder Location (Mins)','Driving_Time',String.Valueof(fieldMap.get('SVMXC__Driving_Time__c').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('SVMXC__Overhead_Time_Before__c','Overhead Time at Start of the Job (Mins)','Overhead_Time_Before',String.Valueof(fieldMap.get('SVMXC__Overhead_Time_Before__c').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('SVMXC__Overhead_Time_After__c','Overhead Time at End of the Job (Mins)','Overhead_Time_After',String.Valueof(fieldMap.get('SVMXC__Overhead_Time_After__c').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('SVMXC__Driving_Time_Home__c','Travel Time Back to Home Base (Mins)','Driving_Time_Home',String.Valueof(fieldMap.get('SVMXC__Driving_Time_Home__c').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('SVMXC__Service_Duration__c','Service Time (in Seconds)','Service_Duration',String.Valueof(fieldMap.get('SVMXC__Service_Duration__c').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('SVMXC__Break_Time_Total__c','Total Break Time (Mins)','Break_Time_Total',String.Valueof(fieldMap.get('SVMXC__Break_Time_Total__c').getDescribe().getType()),null));
        ple = fieldMap.get('Type').getDescribe().getPicklistValues();
        
        mapToSerialize.put('','TAG280');
        
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.isDefaultValue()) {
                defaultVal = pickListVal.getValue();
            } 
            mapToSerialize.put(pickListVal.getValue(),pickListVal.getLabel());
            
        }
        if(!String.isEmpty(defaultVal)) {
            mapToSerialize.put('defaultValue',defaultVal);
        }
        system.debug('mapToSerialize +'+mapToSerialize);
        system.debug('Json mapToSerialize +'+JSON.serialize(mapToSerialize));
        
        eventFields.add(new objFieldInfo('Type','Type','Type',String.Valueof(fieldMap.get('Type').getDescribe().getType()),JSON.serialize(mapToSerialize)));
        eventFields.add(new objFieldInfo('IsAllDayEvent','All-Day Event','IsAllDayEvent',String.Valueof(fieldMap.get('IsAllDayEvent').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('SVMXC__SM_Latitude__c','Latitude','latitude',String.Valueof(fieldMap.get('SVMXC__SM_Latitude__c').getDescribe().getType()),null));
        eventFields.add(new objFieldInfo('SVMXC__SM_Longitude__c','Longitude','longitude',String.Valueof(fieldMap.get('SVMXC__SM_Longitude__c').getDescribe().getType()),null));

        fieldList = DCX_Utils.getConfiguredEventFields();
        fieldList = DCX_getObjectFieldList_WS_1();
            for(String settingVal : fieldList) {
                if(fieldMap.containsKey(settingVal.toLowerCase())) {
                    if(!evtFields.contains(settingVal)) {
                        fieldN = fieldMap.get(settingVal);
                        fieldDes = fieldN.getDescribe();
                        if(fieldDes.getType() == Schema.DisplayType.Picklist) {
                            mapToSerialize.clear();
                            defaultVal = null;
                            ple = new List<Schema.PicklistEntry>();
                            ple = fieldDes.getPicklistValues();
                            for( Schema.PicklistEntry pickListVal : ple){
                                if(pickListVal.isDefaultValue()) {
                                    defaultVal = pickListVal.getValue();
                                } 
                                mapToSerialize.put(pickListVal.getValue(),pickListVal.getLabel());
                            }
                            if(!String.isEmpty(defaultVal)) {
                                mapToSerialize.put('defaultValue',defaultVal);
                            }
                            eventFields.add(new objFieldInfo(settingVal,fieldDes.getLabel(),settingVal,String.Valueof(fieldDes.getType()),JSON.serialize(mapToSerialize)));
                        } else {
                            eventFields.add(new objFieldInfo(settingVal,fieldDes.getLabel(),settingVal,String.Valueof(fieldDes.getType()),null));
                        }
                    } 
                }  
            }
        return eventFields;
    }

    public static List<String> DCX_getObjectFieldList_WS_1(){

        Map<String, Schema.SObjectField> mapEventFieldDef = new Map<String, Schema.SObjectField>();
        mapEventFieldDef = Event.SObjectType.getDescribe().fields.getMap();


        Map<String, Schema.SObjectField> mapSVMXEventFieldDef = new Map<String, Schema.SObjectField>();
        mapSVMXEventFieldDef = SVMX_Event__c.SObjectType.getDescribe().fields.getMap();
        List<String> lstevtfields = new List<String>();

        for (String eventField : mapEventFieldDef.keySet()) 
        {
             Schema.SObjectField fieldDetail = mapSVMXEventFieldDef.get(eventField);
             if(fieldDetail != null)
              {
                Schema.DescribeFieldResult f1 = fieldDetail.getDescribe();
                Schema.SObjectField fsObj = mapEventFieldDef.get(eventField);
                Schema.DescribeFieldResult f = fsObj.getDescribe(); 
                if(f.getName() == f1.getName() && f.getType() == f1.getType() && f.getLength() == f1.getLength())
                {
                    lstevtfields.add(f.getName());
                }
              }
        }
        return lstevtfields;

    }

    public static List<objFieldInfo> fetchFields(String objectName) {
        List<objFieldInfo> objectFields = new List<objFieldInfo>();
        String apiName,labelName,dataType;
        Schema.DescribeFieldResult fieldDesc;
        Map<String, Schema.SObjectField> fieldMap;
        if(objectName == 'SVMXC__Service_Group_Members__c') {
            fieldMap = SVMXC__Service_Group_Members__c.sObjectType.getDescribe().fields.getMap();   
        }
        else {
            fieldMap = SVMXC__Service_Group__c.sObjectType.getDescribe().fields.getMap();
        }
        for(Schema.SObjectField fieldName: fieldMap.values()) {
            fieldDesc = fieldName.getDescribe();
            apiName = String.Valueof(fieldDesc.getName());
            labelName = String.Valueof(fieldDesc.getLabel());
            dataType = String.Valueof(fieldDesc.getType());
            objectFields.add(new objFieldInfo(apiName,labelName,null,dataType,null));   
        }
        return objectFields;
    }

    public class metaDataSetting {
        public List<COMM_TagWebServices.TagsMap> displayTags {get; set;}
        public List<DCX_Wrapper.SVMX_StringMap> timeZoneInfo {get; set;}
        public SFM_WrapperDef.SFM_Response_ObjectFields sfmWorkOrderFields {get; set;}
        public List<objFieldInfo> sfmEventFields {get;set;}
        public List<objFieldInfo> sfmServiceGroupMembers {get;set;}
        public List<objFieldInfo> sfmServiceGroup {get;set;}
        public list<DCX_MultiCriteriaTechMatch.skill> skills {get;set;}
    }

    public class objFieldInfo {
        public String apiName;
        public String labelName;
        public String wrapperName;
        public String dataType;
        public String pickListVals;

        objFieldInfo(String apiName,String labelName,String wrapperName, String dataType, String val) {
            this.apiName = apiName;
            this.labelName = labelName;
            this.wrapperName = wrapperName;
            this.dataType = dataType;
            this.pickListVals = val;
        }   
    }

    public static List<COMM_TagWebServices.TagsMap> DCX_Retrieve_Display_Tags_WS(String UserId){
        List<COMM_TagWebServices.TagsMap> TagListValueM = COMM_TagWebServices.TagdataforSubmodule('DCON001');
        List<COMM_TagWebServices.TagsMap> DCON005TagListValueM = COMM_TagWebServices.TagdataforSubmodule('DCON005');
        List<COMM_TagWebServices.TagsMap> DCON006TagListValueM = COMM_TagWebServices.TagdataforSubmodule('DCON006');
        TagListValueM.addAll(DCON005TagListValueM);
        TagListValueM.addAll(DCON006TagListValueM);
        return TagListValueM;
    }

    public static List<DCX_Wrapper.SVMX_StringMap> DCX_GetAllTimeZone_WS(String UserId){
        List<DCX_Wrapper.SVMX_StringMap> timeZone_M = new List<DCX_Wrapper.SVMX_StringMap>();
        
        Schema.DescribeFieldResult CT =user.TimeZoneSidKey.getDescribe();
        List<Schema.PicklistEntry> P = CT.getPicklistValues();

        DCX_Wrapper.SVMX_StringMap tZone;
        for(Schema.PicklistEntry pl: P){
            tZone = new DCX_Wrapper.SVMX_StringMap(pl.getValue(),pl.getLabel());
            timeZone_M.add(tZone);
        }
        system.debug(LoggingLevel.Error, 'Returning TimeZones : ' + timeZone_M);
        return timeZone_M;
    }

    public static SVMX_Response DCX_getObjectFieldList_WS(){
        SVMX_Response response = new SVMX_Response();
        SVMXC.DCX_Utils comutils = new SVMXC.DCX_Utils();
        set<String> whitelistedObjects = new set<String>();
        Map<String,Boolean> whitelist = new Map<String,Boolean>();
        whitelist = comutils.SVMX_getPermittedStandardObjectList();
        list<string> lstwofields = new list<string>();
        list<string> lstevtfields = new list<string>();
        for(String whitefield: whitelist.keySet())
        {
            whitelistedObjects.add(whitefield);
        }
        Map<String, SObjectField> objWorkOrderFieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        for (String fieldKey : objWorkOrderFieldMap.keySet())
        {
            Schema.SObjectField fsObj = objWorkOrderFieldMap.get(fieldKey); 
            Schema.DescribeFieldResult field = fsObj.getDescribe();
            if(field.getType()== Schema.DisplayType.Reference)
            {
                Schema.DescribeSObjectResult obejctDef = field.getReferenceTo()[0].getDescribe();
                 if(whitelistedObjects.contains(obejctDef.getName()))
                 lstwofields.add(field.getName());
            }
            else
            {
                 lstwofields.add(field.getName());
            }
        }

        lstevtfields.add('ActivityDate');
        lstevtfields.add('ActivityDateTime');
        lstevtfields.add('DurationInMinutes');
        lstevtfields.add('Subject');
        lstevtfields.add('Description');
        lstevtfields.add('WhatId');
        lstevtfields.add('StartDateTime');
        lstevtfields.add('EndDateTime');
        lstevtfields.add('Location');
        //039583 - added following line
        lstevtfields.add('Type');
        
        Map<String, Schema.SObjectField> mapEventFieldDef = new Map<String, Schema.SObjectField>();
        mapEventFieldDef = Event.SObjectType.getDescribe().fields.getMap();

        Map<String, Schema.SObjectField> mapSVMXEventFieldDef = new Map<String, Schema.SObjectField>();
        mapSVMXEventFieldDef = SVMX_Event__c.SObjectType.getDescribe().fields.getMap();
        
        for (String eventField : mapEventFieldDef.keySet()) 
        {
             Schema.SObjectField fieldDetail = mapSVMXEventFieldDef.get(eventField);
             if(fieldDetail != null)
              {
                Schema.DescribeFieldResult f1 = fieldDetail.getDescribe();
                Schema.SObjectField fsObj = mapEventFieldDef.get(eventField);
                Schema.DescribeFieldResult f = fsObj.getDescribe(); 
                if(f.getName() == f1.getName() && f.getType() == f1.getType() && f.getLength() == f1.getLength())
                {
                    lstevtfields.add(f.getName());
                }
              }
        }
        response.Evntfields = lstevtfields;
        response.WoFields = lstwofields;
        return response;
}

public static list<DCX_MultiCriteriaTechMatch.skill> getSkillDetails()
{

    List<SVMXC__Skill__c > lstSkillobj = new List<SVMXC__Skill__c >();
    lstSkillobj = [SELECT Id,Name FROM SVMXC__Skill__c where name != null and SVMXC__Active__c = true];
    list<DCX_MultiCriteriaTechMatch.skill> lstSkilldetails = new list<DCX_MultiCriteriaTechMatch.skill> ();
    try
    {
        for(SVMXC__Skill__c obj :lstSkillobj)
        {
            DCX_MultiCriteriaTechMatch.skill objskill = new DCX_MultiCriteriaTechMatch.skill();
            objskill.skillId = obj.id;
            objskill.skillName = obj.Name;
            lstSkilldetails.add(objskill);
        }
    }
    catch(Exception ex)
    {
         system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
         throw new DCX_CommonServiceManager.DCxException(ex.getMessage());
    }
    return lstSkilldetails;
}
public class SVMX_Response{
    public list<string> WoFields{get; set;}
    public list<string> Evntfields{get; set;}
    public List<DCX_Wrapper.SVMX_StringMap> DispatcherList{get;set;} //introduced 29/08/2011 - hh - Reason:parameter needed to hold and return response dispatcher List.
    public List<SObject> RecordList{get; set;}
    public Boolean success{get; set;}
    public string message{get; set;}
    }

}