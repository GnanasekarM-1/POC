public with sharing class INTF_GetObjectDefinition 
{
    public List<String> objectFields = new List<String>();
    public String objectName;
    public class SVMXException extends Exception{}
    Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    Map<String, String> mapAllObjs = new Map<String, String>();
    SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
    map<String, String> mapSettingsForIPAD018 = new map<String, String>();
    
    public INTF_GetObjectDefinition()
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('INTF_GetObjectDefinition');
        allObjs = Schema.getGlobalDescribe();
        for(String obj : allObjs.keyset())
        {
            if(obj.contains('__c'))
            {
                Schema.DescribeSObjectResult objDesc = allObjs.get(obj).getDescribe();
                mapAllObjs.put(objDesc.getName(), obj);
                //system.debug(Logginglevel.WARN, 'Object Name: ' + objDesc.getName() + '; Original API Name of object: ' + obj);
            }   
        }
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<String> lstSettingId = new list<String>();
        lstSettingId.add('SET008');
        mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
        system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'INTF_GetObjectDefinition');
    }
    
    public INTF_WebServicesDef.SVMXMap INTF_GetObjectDefinition()
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('INTF_GetObjectDefinition');   
        Boolean skipField = false;
        if(mapSettingsForIPAD018.containskey('SET008') && mapSettingsForIPAD018.get('SET008') != null)
            skipField = Boolean.valueOf(mapSettingsForIPAD018.get('SET008'));
        else
            skipField = false;
            
        // Clearing old values if exist
        objectFields = new List<String>();
        INTF_WebServicesDef.SVMXMap response = new INTF_WebServicesDef.SVMXMap();
        system.debug(Logginglevel.WARN, 'Object Name: ' + objectName);
        List<INTF_WebServicesDef.SVMXMap> fields = new List<INTF_WebServicesDef.SVMXMap>();
        objectName = utils.getOriginalAPIName(objectName, mapAllObjs);
        if(objectName != NULL && allObjs.get(objectName)!= NULL)
        {
            Schema.SObjectType selectedObject = allObjs.get(objectName);
            Schema.DescribeSObjectResult objDescribe = selectedObject.getDescribe();
            Map<String,Schema.SObjectField> fieldMapping = objDescribe.fields.getMap();
            
            for(Schema.SObjectField fieldMap: fieldMapping.values())
            {
                if(skipField && !fieldMap.getDescribe().isAccessible())
                    continue;
                //Describe the field to get all properties
                Schema.DescribeFieldResult fieldDescribe = fieldMap.getDescribe();
                List<INTF_WebServicesDef.SVMXMap> fieldProp = new List<INTF_WebServicesDef.SVMXMap>();
                if(fieldDescribe.getType() == Schema.DisplayType.Reference)
                {
                    List<Schema.sObjectType> P = fieldDescribe.getReferenceTo();
                    if((objectName.toUpperCase() == 'USER') && fieldDescribe.getName().toUpperCase() == 'PROFILEID')
                        fieldProp.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO', 'Profile'));
                    else if(P != null && P.size() > 0)
                    {
                        if(P.size() == 2)
                            fieldProp.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO', String.valueOf(P[1])));
                        else
                            fieldProp.add(new INTF_WebServicesDef.SVMXMap('REFERENCETO', String.valueOf(P[0])));
                    }
                    fieldProp.add(new INTF_WebServicesDef.SVMXMap('RELATIONSHIPNAME', fieldDescribe.getRelationshipName()));
                }
                INTF_WebServicesDef.SVMXMap field = new INTF_WebServicesDef.SVMXMap('FIELD', fieldDescribe.getName());
                fieldProp.add(new INTF_WebServicesDef.SVMXMap('LABEL', String.valueOf(fieldDescribe.getLabel())));
                fieldProp.add(new INTF_WebServicesDef.SVMXMap('TYPE', String.valueOf(fieldDescribe.getType())));
                fieldProp.add(new INTF_WebServicesDef.SVMXMap('CREATEABLE', String.valueOf(fieldDescribe.isCreateable())));
                fieldProp.add(new INTF_WebServicesDef.SVMXMap('UPDATEABLE', String.valueOf(fieldDescribe.isUpdateable())));
                fieldProp.add(new INTF_WebServicesDef.SVMXMap('LENGTH', String.valueOf(fieldDescribe.getlength())));
                fieldProp.add(new INTF_WebServicesDef.SVMXMap('SCALE', String.valueOf(fieldDescribe.getScale())));
                fieldProp.add(new INTF_WebServicesDef.SVMXMap('PRECISION', String.valueOf(fieldDescribe.getPrecision())));
                  if((selectedObject == Account.SObjectType && fieldDescribe.getName() == 'Name') || (selectedObject != Account.SObjectType &&fieldDescribe.isNameField()))
                    fieldProp.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD', 'TRUE'));
                else
                    fieldProp.add(new INTF_WebServicesDef.SVMXMap('NAMEFIELD', 'FALSE'));
                objectFields.add(fieldDescribe.getName());
                field.valueMap = fieldProp;
                fields.add(field);
            }
            
            List<INTF_WebServicesDef.SVMXMap> objectProperties = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap objectProp = new INTF_WebServicesDef.SVMXMap('OBJECTPROPERTY', '');
            INTF_WebServicesDef.SVMXMap fieldProp = new INTF_WebServicesDef.SVMXMap('FIELDPROPERTY', '');
            fieldProp.valueMap = fields;
            INTF_WebServicesDef.SVMXMap recordTypeProp = new INTF_WebServicesDef.SVMXMap('RECORDTYPE', '');
            List<INTF_WebServicesDef.SVMXMap> availableRecordTypeProp = new List<INTF_WebServicesDef.SVMXMap>();
            for(Schema.RecordTypeInfo recordType: objDescribe.getRecordTypeInfos())
            {
                if(recordType.isAvailable())
                    availableRecordTypeProp.add(new INTF_WebServicesDef.SVMXMap(recordType.getRecordTypeId(), recordType.getName()));
            }
            recordTypeProp.valueMap = availableRecordTypeProp;
            
            INTF_WebServicesDef.SVMXMap coreObjectProp = new INTF_WebServicesDef.SVMXMap('OBJECTDEFINITION', '');
            List<INTF_WebServicesDef.SVMXMap> availablecoreObjectProp = new List<INTF_WebServicesDef.SVMXMap>();
            availablecoreObjectProp.add(new INTF_WebServicesDef.SVMXMap('KEYPREFIX', objDescribe.getKeyPrefix()));
            availablecoreObjectProp.add(new INTF_WebServicesDef.SVMXMap('LABEL', objDescribe.getLabel()));
            availablecoreObjectProp.add(new INTF_WebServicesDef.SVMXMap('PLURALLABEL', objDescribe.getLabelPlural()));
            availablecoreObjectProp.add(new INTF_WebServicesDef.SVMXMap('QUERYABLE', objDescribe.isQueryable()?'true':'false')); //added pr 14th Jan 2012 4:00PM
            
            // Identify master childs and attach it to describe result
            List<schema.Childrelationship> ChildObj = objDescribe.getChildRelationships();
            if(ChildObj.size() > 0)
            {
                List<INTF_WebServicesDef.SVMXMap> coreChilds = new List<INTF_WebServicesDef.SVMXMap>();
                for(schema.Childrelationship CR:ChildObj)
                {
                    String strChildObjectName = CR.getChildSObject().getDescribe().getName();
                    if(CR.isCascadeDelete() == true)
                    {
                        Schema.sObjectField field = CR.getField();
                        coreChilds.add(new INTF_WebServicesDef.SVMXMap(strChildObjectName, field.getDescribe().getName()));
                    }
                }
                if(coreChilds != NULL && coreChilds.size() > 0)
                {
                    INTF_WebServicesDef.SVMXMap lstChilds = new INTF_WebServicesDef.SVMXMap('MASTERDETAILS', null);
                    lstChilds.valueMap = coreChilds;
                    availablecoreObjectProp.add(lstChilds);
                }
            }
            coreObjectProp.valueMap = availablecoreObjectProp;

            objectProp.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            objectProp.valueMap.add(coreObjectProp);
            objectProp.valueMap.add(recordTypeProp);
            
            objectProperties.add(objectProp);
            objectProperties.add(fieldProp);
            
            response.key = 'OBJECT';
            response.value = objDescribe.getName();
            response.valueMap = objectProperties;
        }
        else
        {
            INTF_DataSync.logMethodEndTS(intMethodCount, 'INTF_GetObjectDefinition');
            throw new SVMXException('Original API Name of object is null or object not found in global describe; check if object exists and is deployed');
        }
        system.debug(Logginglevel.WARN, 'INTF_GetObjectDefinition return value: ' + response);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'INTF_GetObjectDefinition');
        return response;
    }
    
    public INTF_WebServicesDef.SVMXMap INTF_GetMasterChildDefinition()
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('INTF_GetMasterChildDefinition');
        objectFields = new List<String>();
        INTF_WebServicesDef.SVMXMap response = new INTF_WebServicesDef.SVMXMap();
        system.debug(Logginglevel.WARN, 'Object Name: ' + objectName);
        objectName = utils.getOriginalAPIName(objectName, mapAllObjs);
        if(objectName != NULL && allObjs.get(objectName)!= NULL)
        {
            Schema.SObjectType selectedObject = allObjs.get(objectName);
            Schema.DescribeSObjectResult objDescribe = selectedObject.getDescribe();           
            List<SVMXC.INTF_WebServicesDef.SVMXMap> objectProperties = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
            SVMXC.INTF_WebServicesDef.SVMXMap objectProp = new SVMXC.INTF_WebServicesDef.SVMXMap('OBJECTPROPERTY', '');
            SVMXC.INTF_WebServicesDef.SVMXMap coreObjectProp = new SVMXC.INTF_WebServicesDef.SVMXMap('OBJECTDEFINITION', '');
            List<SVMXC.INTF_WebServicesDef.SVMXMap> availablecoreObjectProp = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
            availablecoreObjectProp.add(new SVMXC.INTF_WebServicesDef.SVMXMap('KEYPREFIX', objDescribe.getKeyPrefix()));
            availablecoreObjectProp.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LABEL', objDescribe.getLabel()));
            availablecoreObjectProp.add(new SVMXC.INTF_WebServicesDef.SVMXMap('PLURALLABEL', objDescribe.getLabelPlural()));
            availablecoreObjectProp.add(new SVMXC.INTF_WebServicesDef.SVMXMap('QUERYABLE', objDescribe.isQueryable()?'true':'false'));
            
            // Identify master childs and attach it to describe result
            List<schema.Childrelationship> ChildObj = objDescribe.getChildRelationships();
            if(ChildObj.size() > 0)
            {
                List<SVMXC.INTF_WebServicesDef.SVMXMap> coreChilds = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
                for(schema.Childrelationship CR:ChildObj)
                {
                    String strChildObjectName = CR.getChildSObject().getDescribe().getName();
                    if(CR.isCascadeDelete() == true)
                    {
                        Schema.sObjectField field = CR.getField();
                        coreChilds.add(new SVMXC.INTF_WebServicesDef.SVMXMap(strChildObjectName, field.getDescribe().getName()));
                    }
                }
                if(coreChilds != NULL && coreChilds.size() > 0)
                {
                    SVMXC.INTF_WebServicesDef.SVMXMap lstChilds = new SVMXC.INTF_WebServicesDef.SVMXMap('MASTERDETAILS', null);
                    lstChilds.valueMap = coreChilds;
                    availablecoreObjectProp.add(lstChilds);
                }
            }
            coreObjectProp.valueMap = availablecoreObjectProp;

            objectProp.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
            objectProp.valueMap.add(coreObjectProp);
            
            objectProperties.add(objectProp);
            
            response.key = 'OBJECT';
            response.value = objDescribe.getName();
            response.valueMap = objectProperties;
        }
        system.debug('INTF_GetMasterChildDefinition return value: ' + response);
        INTF_DataSync.logMethodEndTS(intMethodCount,'INTF_GetMasterChildDefinition');
        return response;
    }
    
    public INTF_WebServicesDef.SVMXMap INTF_GetPicklistDefinition(Set<String> allowedPicklistFields)
    {
        INTF_WebServicesDef.SVMXMap response = new INTF_WebServicesDef.SVMXMap();
        List<INTF_WebServicesDef.SVMXMap> fields = new List<INTF_WebServicesDef.SVMXMap>();
        objectName = utils.getOriginalAPIName(objectName, mapAllObjs);
        if(objectName != NULL && allObjs.get(objectName)!= NULL && allowedPicklistFields != NULL && allowedPicklistFields.size() > 0)
        {
            Schema.SObjectType selectedObject = allObjs.get(objectName);
            Schema.DescribeSObjectResult objDescribe = selectedObject.getDescribe();
            Map<String,Schema.SObjectField> fieldMapping = objDescribe.fields.getMap();
            system.debug(LoggingLevel.WARN, 'INTF_GetPicklistDefinition - Object Name: ' + objectName + '; selectedObject = ' + selectedObject);
            for(Schema.SObjectField fieldMap: fieldMapping.values())
            {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.getDescribe();
                List<INTF_WebServicesDef.SVMXMap> fieldProp = new List<INTF_WebServicesDef.SVMXMap>();
                    if(allowedPicklistFields.contains(fieldDescribe.getName()))
                    {
                        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                        for(Schema.PicklistEntry entry: picklistEntries)
                        {
                            if(entry.isActive())
                            {
                                if(entry.getLabel() == NULL)
                                break;
                                fieldProp.add(new INTF_WebServicesDef.SVMXMap('PICKLISTVALUE', entry.getValue()));
                                fieldProp.add(new INTF_WebServicesDef.SVMXMap('PICKLISTLABEL', entry.getLabel()));
                                if(entry.isDefaultValue())
                                fieldProp.add(new INTF_WebServicesDef.SVMXMap('DEFAULTPICKLISTVALUE', entry.getValue()));
                            }
                        }
                        if(fieldDescribe.getType() == Schema.DisplayType.MultiPicklist)
                            fieldProp.add(new INTF_WebServicesDef.SVMXMap('ISMULTIPICKLIST', 'TRUE'));
                        else
                            fieldProp.add(new INTF_WebServicesDef.SVMXMap('ISMULTIPICKLIST', 'FALSE'));
                        
                        INTF_WebServicesDef.SVMXMap field = new INTF_WebServicesDef.SVMXMap('FIELD', fieldDescribe.getName());
                        field.valueMap = fieldProp;
                        field.key = 'FIELD';
                        field.value = fieldDescribe.getName();
                        fields.add(field);
                    }
            }

            response.key = 'OBJECT';
            response.value = objDescribe.getName();
            response.valueMap = fields;
        }
        system.debug(LoggingLevel.WARN, 'INTF_GetPicklistDefinition - response: ' + response);
        return response;
    }
    
    public String getObjectFieldNames(List<String> fields)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getObjectFieldNames');
        String response = '';
        for(String field: fields)
        {
            if(response != '')
                response += ',';
            response += field;
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getObjectFieldNames');
        return response;
    }
    public String getObjectFieldNames()
    {
        String response = '';
        for(String field: objectFields)
        {
            if(response != '')
                response += ',';
            response += field;
        }
        return response;
    }
    
    public void INTF_ValidateProcessObjects(Map<String, Schema.SObjectType> allObjs, set<String> setObjectNames)
    {
        set<String> unaccessableObejcts = new set<String>();
        for(String objName: setObjectNames)
        {
            if(allObjs.get(objName) != NULL)
            {
                Schema.SObjectType selectedObject = allObjs.get(objName);
                Schema.DescribeSObjectResult objDesc = selectedObject.getDescribe();
                if(!objDesc.isAccessible())
                    unaccessableObejcts.add(objName);
            }
            else
                unaccessableObejcts.add(objName);
        }
    }
}