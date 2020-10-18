/* Security Scanned */
public with sharing class SFM_Utils
{
    //Configuration
    //BAC-5357
    private static boolean is_sfm_get_Header_executed = false;
    private static Sobject hdrSObject1 = null;
    
    List<SVMXC__ServiceMax_Property_Elements__c> ProElements = new List<SVMXC__ServiceMax_Property_Elements__c>();
    public Integer maxBubbleCount = 5;
    public Integer maxResultsetCount = 10;
    public List<String> excludeTargetFieldsProperties = new List<String>{'isCreateable'};
    //public set<String> excludeTargetFieldsBlackList = new Set<String>{'RESTRICTED LIST3', 'RESTRICTED LIST4'};
    public set<String> excludeTargetFieldsBlackList = new Set<String>{'BLOCKED TARGET HEADER', 'BLOCKED TARGET CHILD'};
    //Constructor.....
    public SFM_Utils()
    {
        
    }
    //This method gives the map of Restricted List
    public map<String,String> getRestrictedListMap(String s)
    {
        String RestrictedList = '';
        RestrictedList = s.toUpperCase();
        List<SVMXC__ServiceMax_Property_Elements__c> ProElements = new List<SVMXC__ServiceMax_Property_Elements__c>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ProElements = [Select SVMXC__Property_Key__c, SVMXC__Element_Value__c, SVMXC__Element_Type__c, Name, Id From SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c =: RestrictedList];
        map<String,String> RestrictedListMap = new map<String,String>();
        if(ProElements.size() > 0)
        {
            for(SVMXC__ServiceMax_Property_Elements__c SPE : ProElements)
            {
                RestrictedListMap.put(SPE.SVMXC__Element_Value__c,SPE.SVMXC__Element_Value__c);
            }
        }
        return RestrictedListMap;
    }
    public set<String> getBlackList(String blackListName)
    {
        List<SVMXC__ServiceMax_Property_Elements__c> ProElements = new List<SVMXC__ServiceMax_Property_Elements__c>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ProElements = [Select SVMXC__Property_Key__c, SVMXC__Element_Value__c, SVMXC__Element_Type__c, Name, Id From SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c = :blackListName];
        set<String> RestrictedList = new set<String>();
        if(ProElements.size() > 0)
        {
            for(SVMXC__ServiceMax_Property_Elements__c SPE : ProElements)
            {
                RestrictedList.add(SPE.SVMXC__Element_Value__c);
            }
        }
        return RestrictedList;
    }
    //Converst the given stringMap to MAP for direct access of values
    public Map<String,String> getStringMap(List<SFM_WrapperDef.SFM_StringMap> strMap){
        Map<String,String> response = new Map<String,String>();
        for(SFM_WrapperDef.SFM_StringMap SM: strMap){
            response.put(SM.key,SM.value);
        }
        return response;
    }
    
    public Map<String,String> WhiteList()
    {
        Map<String,String> Permited = new Map<String,String>();//The map of Label/API Name
        Permited.put('Account','Account');
        Permited.put('Contact','Contact');
        Permited.put('Case','Case');
        return Permited;
    }
    
    //Returns the available options for all the fields
    public List<SFM_WrapperDef.SFM_StringMap> getAvailableValues(Schema.DescribeFieldResult field){
        SVMX_Constants constant = new SVMX_Constants();
        String orgConstant = 'SVMXCONSTANT';
        String fieldType = String.valueOf(field.getType()).toUpperCase();
        MAP<String, List<String>> availableValues = new MAP<String, List<String>>();
        //Boolean
        List<SFM_WrapperDef.SFM_StringMap> options = new List<SFM_WrapperDef.SFM_StringMap>();
        if(fieldType.contains('BOOLEAN')){
            options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,'True'));
            options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,'False'));
        }
        else if(fieldType.contains('PICKLIST')){
            
            for(Schema.PicklistEntry entry: field.getPicklistValues()){
                options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,entry.getValue()));
            }
        }
        else if(fieldType.contains('DATE')){
            Map<String, String> dateValues = new Map<String, String>();
            dateValues = constant.getDateOptions();
            for(String dateValue: dateValues.keySet()){
                options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,dateValues.get(dateValue)));
            }
        }
        else if(fieldType.contains('DATETIME')){
            Map<String, String> dateTimeValues = new Map<String, String>();
            dateTimeValues = constant.getDateTimeOptions();
            for(String dateValue:dateTimeValues.keySet()){
                options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,dateTimeValues.get(dateValue)));
            }
        }
        return options;
    }
    
    //Checks the access permission and returns true if it meets all the criteria
    public boolean checkFieldAccessPermission(Schema.DescribeFieldResult field, List<String> criteria_L)
    {
        if(criteria_L == NULL || criteria_L.size()==0)
            return true;
        for(String criteria: criteria_L)
        {
            if(!checkFieldAccessPermission(field, criteria))
            {
                return false;
            }
        }
        return true;
    }
    //Checks the access permission and returns true if it meets specific criteria
    public boolean checkFieldAccessPermission(Schema.DescribeFieldResult field, String criteria){
        if(criteria==NULL || criteria=='') return true;
        else if(criteria=='isCreateable' && field.isCreateable()) return true;
        else if(criteria=='isUpdateable' && field.isUpdateable()) return true;
        else if(criteria=='isAccessible' && field.isAccessible()) return true;
        else if(criteria=='isCustom' && field.isCustom()) return true;
        else if(criteria=='isFilterable' && field.isFilterable()) return true;
        else if(criteria=='isHtmlFormatted' && field.isHtmlFormatted()) return true;
        else if(criteria=='isCalculated' && field.isCalculated()) return true;
        else return false;
    }
    
    //Get original API name which describe can understand, support only one object
    public String getOriginalAPIName(String objectName, Map<String, Schema.SObjectType> allObjs){
        if(!objectName.contains('__c')){
            return objectName;
        }
        for(String obj : allObjs.keyset())
        {
            //if(obj!='dashboardfeed')
            try{
                if(obj.contains('__c')){
                    Schema.DescribeSObjectResult objDesc = allObjs.get(obj).getDescribe();
                    if(objectName == objDesc.getName())
                        return obj;
            }
            }catch(exception ex){}
        }
        return null;
    }
    
    public String getOriginalAPIName(String objectName, Map<String, String> mapAllObjs){
      Integer intMethodCount = INTF_DataSync.logMethodStartTS('getOriginalAPIName');
        if(!objectName.contains('__c')){
          INTF_DataSync.logMethodEndTS(intMethodCount, 'getOriginalAPIName');
            return objectName;
        }
        else if(mapAllObjs.containsKey(objectName))
        {
          INTF_DataSync.logMethodEndTS(intMethodCount, 'getOriginalAPIName');
            return (mapAllObjs.get(objectName));
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getOriginalAPIName');
        return null;
    }
    
    //Get original API name which describe can understand, supports multiple objects
    public Map<String, String> getOriginalAPIName(set<String> objectName, Map<String, Schema.SObjectType> allObjs){
        Map<String, String> originalAPI = new Map<String, String>();
        for(String obj : allObjs.keyset())
        {
            Schema.SObjectType objectType = allObjs.get(obj);
            Schema.DescribeSObjectResult objDesc = objectType.getDescribe();
            if(objectName.contains(objDesc.getName()))
                originalAPI.put(objDesc.getName(),obj);
            if(objectName.size()==originalAPI.size())
                break;
        }
        return originalAPI;
    }
    
    //Get allowed fields for the given object, considering field accessibility
    public set<String> getAllowedFields(String objectName, List<String> permissions, set<String> blacklistedObjects, set<String> whitelistedObjects, Map<String, Schema.SObjectType> allObjs){
        set<String> response = new set<String>();
        Map<String, Schema.SObjectField> givenFieldMap;
        Schema.DescribeFieldResult givenFieldDesc;
        
        //Get the original API name of the object
        system.debug('Object Name:3'+objectName);
        objectName = getOriginalAPIName(objectName, allObjs);
        system.debug('Object Name:4'+objectName);
        Schema.DescribeSObjectResult givenObject = (allObjs.get(objectName)).getDescribe();
        if(givenObject.isAccessible() == true){
            givenFieldMap = givenObject.fields.getMap();
            //Describe all given fields and storing against field API
            for(String fieldAPI: givenFieldMap.keySet()){
                Schema.SObjectField givenField = givenFieldMap.get(fieldAPI); 
                givenFieldDesc = givenField.getDescribe();
                if(checkFieldAccessPermission(givenFieldDesc, permissions)){
                    //Field is permitted
                    response.add(givenFieldDesc.getName());
                }
            }// End of : Describe all given fields and storing against field API
        }
        System.debug('TEST LOG 1033:'+response.size());
        return response;
    }
    
    public boolean checkReferenceValidation(Schema.DescribeFieldResult fieldDesc, set<String> blackList, set<String> whiteList){
        boolean isValid = true;
        //validate:  If target object is a child, referenceTo is target parent object, and getRelationshipOrder() = 1
        if(fieldDesc.getRelationshipOrder()== 1)
        return false;
        else{
            String fieldAPI = fieldDesc.getReferenceTo()[0].getDescribe().getName();
            system.debug('fieldAPI'+fieldAPI);
            //Validate blacklist
            if(blackList.contains(fieldAPI))
            {
                system.debug('Entered blacklist');
                return false;
            }
            //validate with white list if it is referenced to standard object
            //if(fieldDesc.isCustom() && !whiteList.contains(fieldAPI))
            /*if(fieldDesc.isCustom() && !whiteList.contains(fieldAPI))
            {
                system.debug('Entered Second loop');
                return false;
            }*/
        }
        return true;
    }
    
    public SFM_WrapperDef.FieldProperties makeFieldProperty(String fieldAPI, String fieldLabel,Schema.Displaytype fieldType,String fieldRelatedTo,String fieldRelationshipname,boolean isSearchable,boolean isBubblable, boolean isDisplayable){
        SFM_WrapperDef.FieldProperties prop = new SFM_WrapperDef.FieldProperties(fieldAPI);
        List<SFM_WrapperDef.SFM_StringMap> properties = new List<SFM_WrapperDef.SFM_StringMap>();
        prop.key= fieldAPI;
        prop.value = fieldLabel;
        system.debug('RelKey'+prop.key);
        system.debug('RelVal'+prop.value );
        system.debug('RelVal2'+isSearchable + isDisplayable + isBubblable+ fieldType);
        //Set whether is searchable or not
        if(isSearchable == true)properties.add(new SFM_WrapperDef.SFM_StringMap('SEARCHABLE', 'TRUE'));else properties.add(new SFM_WrapperDef.SFM_StringMap('SEARCHABLE', 'FALSE'));
        if(isDisplayable == true)properties.add(new SFM_WrapperDef.SFM_StringMap('DISPLAYABLE', 'TRUE'));else properties.add(new SFM_WrapperDef.SFM_StringMap('DISPLAYABLE', 'FALSE'));
        if(isBubblable == true)properties.add(new SFM_WrapperDef.SFM_StringMap('BUBBLABLE', 'TRUE'));else properties.add(new SFM_WrapperDef.SFM_StringMap('BUBBLABLE', 'FALSE'));
        //properties.add(new SFM_WrapperDef.SFM_StringMap('TYPE', fieldType.name().touppercase()));
        if(fieldType==Schema.DisplayType.Reference)
        {
            system.debug('RelRelatedTo'+fieldRelatedTo);
            properties.add(new SFM_WrapperDef.SFM_StringMap('TYPE', 'REFERENCE'));
            properties.add(new SFM_WrapperDef.SFM_StringMap('REFERENCETO', fieldRelatedTo));
            properties.add(new SFM_WrapperDef.SFM_StringMap('RELATIONSHIPNAME', fieldRelationshipname));
        } else {
            properties.add(new SFM_WrapperDef.SFM_StringMap('TYPE', String.Valueof(fieldType)));  
        }
        
        prop.properties = properties;
        return prop;
    }
    
    public SFM_WrapperDef.FieldProperties DCX_makeFieldProperty(String objectName, String fieldAPI, String fieldLabel,Schema.Displaytype fieldType,String fieldRelatedTo,String fieldRelationshipname,boolean isSearchable,boolean isBubblable, boolean isDisplayable,Schema.DescribeFieldResult fieldDesc){
        SFM_WrapperDef.FieldProperties prop = new SFM_WrapperDef.FieldProperties(fieldAPI);
        List<SFM_WrapperDef.SFM_StringMap> properties = new List<SFM_WrapperDef.SFM_StringMap>();
        Map<String,String> referenceMap = new Map<String,String>();
        String relationshipFieldName;
        String defaultVal;
        referenceMap.put('CASE','CaseNumber');
        referenceMap.put('SOLUTION','SolutionName');
        referenceMap.put('TASK','Subject');
        referenceMap.put('EVENT','Subject');
        referenceMap.put('CONTRACT','ContractNumber');
        referenceMap.put('ACCOUNT','Name');
        referenceMap.put('ORDERITEM','OrderItemNumber');
        referenceMap.put('ORDER','OrderNumber');
        prop.key= fieldAPI;
        prop.value = fieldLabel;
        system.debug('RelKey'+prop.key);
        system.debug('RelVal'+prop.value );
        system.debug('RelVal2'+isSearchable + isDisplayable + isBubblable+ fieldType);
        //Set whether is searchable or not
        if(isSearchable == true)properties.add(new SFM_WrapperDef.SFM_StringMap('SEARCHABLE', 'TRUE'));else properties.add(new SFM_WrapperDef.SFM_StringMap('SEARCHABLE', 'FALSE'));
        if(isDisplayable == true)properties.add(new SFM_WrapperDef.SFM_StringMap('DISPLAYABLE', 'TRUE'));else properties.add(new SFM_WrapperDef.SFM_StringMap('DISPLAYABLE', 'FALSE'));
        if(isBubblable == true)properties.add(new SFM_WrapperDef.SFM_StringMap('BUBBLABLE', 'TRUE'));else properties.add(new SFM_WrapperDef.SFM_StringMap('BUBBLABLE', 'FALSE'));
        //properties.add(new SFM_WrapperDef.SFM_StringMap('TYPE', fieldType.name().touppercase()));
        if(fieldType==Schema.DisplayType.Reference)
        {
            system.debug('RelRelatedTo'+fieldRelatedTo);
            if(referenceMap.get(fieldRelatedTo.toUpperCase())!=NULL)
                relationshipFieldName = referenceMap.get(fieldRelatedTo.toUpperCase());
            else
                relationshipFieldName = 'Name';
            properties.add(new SFM_WrapperDef.SFM_StringMap('TYPE', 'REFERENCE',relationshipFieldName));
            properties.add(new SFM_WrapperDef.SFM_StringMap('REFERENCETO', fieldRelatedTo));
            properties.add(new SFM_WrapperDef.SFM_StringMap('RELATIONSHIPNAME', fieldRelationshipname));
        } else {
            if(fieldType==Schema.DisplayType.Picklist) {
                map<string, object> mapToSerialize = new map<string, object>();
                List<Schema.PicklistEntry> ple = fieldDesc.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    if(pickListVal.isDefaultValue()) {
                    	defaultVal = pickListVal.getValue();
                    } 
                    mapToSerialize.put(pickListVal.getValue(),pickListVal.getLabel());
                }
                if(!String.isEmpty(defaultVal)) {
                	mapToSerialize.put('defaultValue',defaultVal);
                }
                properties.add(new SFM_WrapperDef.SFM_StringMap('TYPE', 'PICKLIST', JSON.serialize(mapToSerialize)));
            } else {
                properties.add(new SFM_WrapperDef.SFM_StringMap('TYPE', String.Valueof(fieldType)));  
            }  
        }
       
        
        prop.properties = properties;
        return prop;
    }
    
    public boolean checkAllowedProperties(Schema.DescribeFieldResult target, Schema.DescribeFieldResult source){
        Schema.DisplayType sourceType = source.getType();
        Schema.DisplayType targetType = target.getType();
        if(sourceType == targetType && targetType != Schema.DisplayType.TextArea){
            if(targetType == Schema.DisplayType.Integer || targetType == Schema.DisplayType.Currency || targetType == Schema.DisplayType.String || targetType == Schema.DisplayType.TextArea || targetType == Schema.DisplayType.Percent || targetType == Schema.DisplayType.Phone)
                return checksize(source.getLength(), target.getLength());
            else
                return true;
        }
        //Number: Number and Currency fields (if source size <= target size)
        else if(targetType == Schema.DisplayType.Integer){
            if(sourceType == Schema.DisplayType.Currency)
            return checksize(source.getLength(), target.getLength());
        }
        //Currency: Number and Currency fields (if source size <= target size)
        else if(targetType == Schema.DisplayType.Currency){
            if(sourceType == Schema.DisplayType.Integer)
            return checksize(source.getLength(), target.getLength());
        }
        //Date: Datetime and Date
        else if(targetType == Schema.DisplayType.Date){
            if(sourceType == Schema.DisplayType.DateTime)
            return true;
        }
        //Text: Text, Picklist, URL, Email, ID, Phone (if source size <= target size)
        else if(targetType == Schema.DisplayType.String){
            if(sourceType == Schema.DisplayType.Picklist)
            return checksize(source.getLength(), target.getLength());
            else if(sourceType == Schema.DisplayType.URL)
            return checksize(source.getLength(), target.getLength());
            else if(sourceType == Schema.DisplayType.Email)
            return checksize(source.getLength(), target.getLength());
            else if(sourceType == Schema.DisplayType.Reference)
            return checksize(source.getLength(), target.getLength());
            else if(sourceType == Schema.DisplayType.Phone)
            return checksize(source.getLength(), target.getLength());
        }
        //Long Text: Text, Long Text, Picklist, URL, Email, ID, Phone (if source size <= target size)
        else if(targetType == Schema.DisplayType.TextArea){
            // Differentiate between text area and rich text area and then validate type
            if(targetType == sourceType)
            {
                // If target is rich text return true
                if(target.isHtmlFormatted() == true)
                    return(true);
                // If target is source is rich text and target is text area return false
                if(target.isHtmlFormatted() == false && source.isHtmlFormatted() == true)
                    return(false);
                else
                    return(true);
            }
            if(sourceType == Schema.DisplayType.String)
            return checksize(source.getLength(), target.getLength());
            if(sourceType == Schema.DisplayType.Picklist)
            return checksize(source.getLength(), target.getLength());
            else if(sourceType == Schema.DisplayType.URL)
            return checksize(source.getLength(), target.getLength());
            else if(sourceType == Schema.DisplayType.Email)
            return checksize(source.getLength(), target.getLength());
            else if(sourceType == Schema.DisplayType.Reference)
            return checksize(source.getLength(), target.getLength());
            else if(sourceType == Schema.DisplayType.Phone)
            return checksize(source.getLength(), target.getLength());
        }
        //URL: Text, URL, Email
        else if(targetType == Schema.DisplayType.URL){
            if(sourceType == Schema.DisplayType.String)
            return true;
            else if(sourceType == Schema.DisplayType.Email)
            return true;
        }
        //Email: Text, URL, Email
        else if(targetType == Schema.DisplayType.Email){
            if(sourceType == Schema.DisplayType.String)
            return true;
            else if(sourceType == Schema.DisplayType.URL)
            return true;
        }
        //Percent: Number, Percent  (if source size <= target size)
        else if(targetType == Schema.DisplayType.Percent){
            if(sourceType == Schema.DisplayType.Integer)
            return checksize(source.getLength(), target.getLength());
        }
        //Percent: Number, Percent  (if source size <= target size)
        else if(targetType == Schema.DisplayType.Phone){
            if(sourceType == Schema.DisplayType.String)
            return checksize(source.getLength(), target.getLength());
        }
        return false;
    }
    
    public boolean checksize(Integer source, Integer target){
        if(target >= source)
        return true;
        else
        return false;
    }
    
    public Map<String, Id> getRecordTypes(List<String> recTypeNames){
        String whereClass = '';
        boolean isValid = false;
        if(recTypeNames.size()>0)
        isValid = true;
        set<String> objectNames = new set<String>();
        set<String> recTypeName = new set<String>();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> objectRecType;
        for(String recNames: recTypeNames){
            objectRecType = new List<String>();
            objectRecType = recNames.split('~');
            if(objectRecType[0]!=NULL && objectRecType[1]!=NULL){
                objectNames.add(objectRecType[0]);
                recTypeName.add(objectRecType[1]);
            }
            else{
                isValid = false;
                break;
            }
        }
        if(isValid == true){
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<RecordType> recTypes = [SELECT Id, Name, SobjectType  FROM RecordType where SobjectType IN: objectNames AND Name IN: recTypeName];
            for(RecordType rec: recTypes){
                objectRecType_Map.put(rec.SobjectType+'~'+rec.Name, rec.Id);
            }
        }
        return objectRecType_Map;
    }
    public map<String,String> GetRelationshipData(set<String> ids ,String ObjectName,String FieldName)
    {
      Integer intMethodCount = INTF_DataSync.logMethodStartTS('GetRelationshipData');
        map<String,String> ReturnvalueMap = new map<String,String>();
        if(ids != null && ids.size() > 0 && ObjectName != null && ObjectName.length() > 0 && FieldName != null && FieldName.length() > 0)
        {
            
        //Jaysukh Added below condition for defect BAC-3036
      String FieldName1 = FieldName.toLowerCase();
            String Query = ''; 
            if(FieldName1.equalsIgnoreCase('id') || FieldName1.contains('id,') || FieldName1.contains(',id') || FieldName1.contains('id ,') || FieldName1.contains(', id'))
      {
        Query = 'Select '+FieldName+' From '+ ObjectName + ' where Id IN : ids ';   // := \''+id+'\'';
        
      }else
      {
                Query = 'Select id, '+FieldName+' From '+ ObjectName + ' where Id IN : ids ';   // := \''+id+'\'';
      } 
            system.debug('amar'+Query);
            INTF_DataSync.logSOQL(intMethodCount, Query);
            List<Sobject> sobj = Database.query(Query);
            system.debug('amar'+sobj);
            list<String> FldList = new list<String>();
            FldList = FieldName.split(',');
            if(sobj.size() > 0)
            {
                for(Integer i = 0;i<sobj.size();i++)
                {
                    if(FldList.size() == 2 && sobj[i].get('id') != null && sobj[i].get(FldList[1]) != null)
                        ReturnvalueMap.put(String.valueof(sobj[i].get('id')),String.valueof(sobj[i].get(FldList[1])));
                    else if(FldList.size() == 2 && sobj[i].get('id') != null && sobj[i].get(FldList[1]) == null && sobj[i].get(FldList[0]) != null)
                        ReturnvalueMap.put(String.valueof(sobj[i].get('id')),String.valueof(sobj[i].get(FldList[0])));
                    else if(FldList.size() == 1 && sobj[i].get('id') != null && sobj[i].get(FldList[0]) != null)    
                        ReturnvalueMap.put(String.valueof(sobj[i].get('id')),String.valueof(sobj[i].get(FldList[0])));
                }   
            }
            INTF_DataSync.logMethodEndTS(intMethodCount, 'GetRelationshipData');
            return ReturnvalueMap;  
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'GetRelationshipData');
        return null;    
    }
    public List<SVMXC.SFM_WrapperDef.SFM_StringMap> getBubbleinfo(String DefaultValue,String LookupConfigId,String RelatedObjName)
    {
        system.debug('LookupConfigId'+LookupConfigId);
        SVMXC.SFM_getLookUpConfigWithData GetLkD = new SVMXC.SFM_getLookUpConfigWithData();
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> StrMapLst = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>(); 
        list<SVMXC.SFM_WrapperDef.bubble_wp> BubbleWpList = new list<SVMXC.SFM_WrapperDef.bubble_wp>(); 
        SVMXC.SFM_WrapperDef.SFM_LookUpConfigData LookupConfigdata = new SVMXC.SFM_WrapperDef.SFM_LookUpConfigData();
        SVMXC.SFM_WrapperDef.SFM_Request SFMRequest = new SVMXC.SFM_WrapperDef.SFM_Request(); 
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> StringMapList = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>(); 
        //create stringmap InfoType
        SVMXC.SFM_WrapperDef.SFM_StringMap strmap1 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        strmap1.key = 'INFOTYPE';
        strmap1.value = 'BUBBLE';
        //create stringmap Lookup config Id
        SVMXC.SFM_WrapperDef.SFM_StringMap strmap2 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        strmap2.key = 'RECORDID';
        strmap2.value = LookupConfigId; 
        //create stringmap Record Id
        SVMXC.SFM_WrapperDef.SFM_StringMap strmap3 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        strmap3.key = 'SEARCHRECORD';
        strmap3.value = DefaultValue;
        SVMXC.SFM_WrapperDef.SFM_StringMap strmap4 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        strmap4.key = 'OBJECTNAME';
        strmap4.value = RelatedObjName;
        StringMapList.add(strmap1);
        StringMapList.add(strmap2);
        StringMapList.add(strmap3);
        StringMapList.add(strmap4);
        SFMRequest.stringMap = StringMapList;
        system.debug('StringMapList'+StringMapList);
        LookupConfigdata = GetLkD.getLookUpConfigWithData(SFMRequest);
        system.debug('LookupConfigdata'+LookupConfigdata);
        if(LookupConfigdata != null && LookupConfigdata.data != null && LookupConfigdata.data.size() > 0)
            BubbleWpList =  LookupConfigdata.data;
        system.debug('BubbleWpList'+BubbleWpList);  
        if(BubbleWpList.size() > 0)
        {
            for(Integer i = 0;i<BubbleWpList.size();i++)
            {
                list<SVMXC.SFM_WrapperDef.SFM_StringFieldMap> StringFieldMap = new list<SVMXC.SFM_WrapperDef.SFM_StringFieldMap>(); 
                StringFieldMap = BubbleWpList[i].FieldMap;
                if(StringFieldMap.size() > 0)
                {
                    for(Integer j = 0;j< StringFieldMap.size();j++)
                    {
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        strmap.key = StringFieldMap[j].key;
                        strmap.value = StringFieldMap[j].value;
                        StrMapLst.add(strmap);
                    }
                }       
            }
        }   
        system.debug('StrMapLst'+StrMapLst);
        return StrMapLst;
    }
    
    public Map<String, String> getReferenceLabels(Map<String, String> setObject, set<String> setIds)
    {
        Map<String, String> mapResponse = new Map<String, String>();
        List<sObject> sobObjects;
        String strQuery;
        String strNameField;
        for(String obj: setObject.keySet())
        {
            strNameField = setObject.get(obj);
            strQuery = 'SELECT Id, ' + strNameField + ' from ' + obj + ' where Id IN :setIds';
            sobObjects = Database.query(strQuery);
            for(sObject resObj: sobObjects)
            {
                mapResponse.put(resObj.Id, String.valueOf(resObj.get(strNameField)));
            }
        }
        return mapResponse;
    }
    //This utility will give the sobject for header record
    public sobject SFM_Page_GetHeaderRecord(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec,map<String,Schema.SObjectType> Allobj)
    {
        //Process Header 
        system.debug('sfmtargetrec'+sfmtargetrec);
        SVMXC.SFM_BuildSobjectFromKeyValue sobjectfromkevalue = new SVMXC.SFM_BuildSobjectFromKeyValue();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject HdrTargetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        if(sfmtargetrec.headerRecord != null)
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        String HeaderObjName = '';
        Sobject HeaderSobject;   
        List<SVMXC.SFM_WrapperDef.SFM_Record> HeaderRecord = new List<SVMXC.SFM_WrapperDef.SFM_Record>();
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.objName != null)
            HeaderObjName = HdrTargetRecordObject.objName;  
        if(HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        system.debug('HeaderRecord'+HeaderRecord.size()+HeaderRecord);
        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>();
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> HdrTargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        if(HeaderRecord.size() > 0)
        {
            if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0 && Allobj.containskey(HeaderObjName))
            {
                HdrTargetRecordAsKeyValue = HeaderRecord[0].targetRecordAsKeyValue;
                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null);        
            }
        }
        if(HeaderSobjMap.size() > 0)
        {
            HeaderSobject = HeaderSobjMap.values();
        }
        //BAC-5357
        hdrSObject1 = HeaderSobject;
        is_sfm_get_Header_executed = true;
        //Jaysukh op
        system.debug('HeaderSobject'+HeaderSobject);
        return HeaderSobject;
    }
    //This utility will return the map<,List<sobject>> for detail record
    public Map<String,List<Sobject>> SFM_Page_GetDetailRecords(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec,map<String,Schema.SObjectType> Allobj)
    {
        map<String,list<Sobject>> detailRecordMap = new map<String,list<Sobject>>();
        map<String,map<String,Schema.SObjectField>> AllFieldDescribe = new map<String,map<String,Schema.SObjectField>>();
        //first get the header sobject to know the header sobject id is present or not
        //BAC-5357
    //Sobject HdrSObject = SFM_Page_GetHeaderRecord(sfmtargetrec,Allobj);
        //BAC-5357
        Sobject HdrSObject = null;
        if(is_sfm_get_Header_executed && hdrSObject1 != null)
        {
           HdrSObject = hdrSObject1;
        }
        else
        {
          HdrSObject = SFM_Page_GetHeaderRecord(sfmtargetrec,Allobj);
        }
        
        SVMXC.SFM_BuildSobjectFromKeyValue sobjectfromkevalue = new SVMXC.SFM_BuildSobjectFromKeyValue();
        list<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> DtlTargetRecordObject = new list<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();//Third member of the SFM_TargetRecord Class
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        system.debug('DtlTargetRecordObject'+DtlTargetRecordObject);
        //now process the detail Reocrds..
        //BAC-5357 No use
        //list<Sobject> DetailRecordsForUpdate = new list<Sobject>();
        //list<Sobject> DetailRecordsForInsert = new list<Sobject>();
        map<Integer,List<SVMXC.SFM_WrapperDef.SFM_Record>> TargetRecMap = new map<Integer,List<SVMXC.SFM_WrapperDef.SFM_Record>>(); 
        map<Integer,String> DetailObjName = new map<Integer,String>();
        map<Integer,String> AliasNameMap = new map<Integer,String>(); 
        map<Integer,String> ParentColumnNameMap = new map<Integer,String>();
        //map<Integer,List<String>> DeleteRecordIdMap = new map<Integer,List<String>>();
        if(DtlTargetRecordObject.size() > 0)
        {
            for(Integer i = 0;i<DtlTargetRecordObject.size();i++)
            {
                if(DtlTargetRecordObject[i].records != null && DtlTargetRecordObject[i].records.size() > 0 )
                    TargetRecMap.put(i,DtlTargetRecordObject[i].records);
                if(DtlTargetRecordObject[i].objName != null && DtlTargetRecordObject[i].objName.length() > 0)
                    DetailObjName.put(i,DtlTargetRecordObject[i].objName);
                if(DtlTargetRecordObject[i].aliasName != null && DtlTargetRecordObject[i].aliasName.length() > 0)
                    AliasNameMap.put(i,DtlTargetRecordObject[i].aliasName);  
                if(DtlTargetRecordObject[i].parentColumnName != null && DtlTargetRecordObject[i].parentColumnName.length() > 0)
                    ParentColumnNameMap.put(i,DtlTargetRecordObject[i].parentColumnName);
                //if(DtlTargetRecordObject[i].deleteRecID != null && DtlTargetRecordObject[i].deleteRecID.size() > 0)
                   // DeleteRecordIdMap.put(i,DtlTargetRecordObject[i].deleteRecID);//recordIds to be delete          
            }
        }
        system.debug('TargetRecMap'+TargetRecMap);
        system.debug('DetailObjName'+DetailObjName);
        system.debug('AliasNameMap'+AliasNameMap);
        system.debug('ParentColumnNameMap'+ParentColumnNameMap);
        //system.debug('DeleteRecordIdMap'+DeleteRecordIdMap);
        if(TargetRecMap.size() > 0)
        {
            for(Integer i : TargetRecMap.keyset())
            {
                List<SVMXC.SFM_WrapperDef.SFM_Record> SfmReocrdlst = new List<SVMXC.SFM_WrapperDef.SFM_Record>(); 
                SVMXC__ServiceMax_Processes__c DetailNodeObject = new  SVMXC__ServiceMax_Processes__c();
                list<SVMXC__ServiceMax_Config_Data__c> DetailSourceUpdates = new list<SVMXC__ServiceMax_Config_Data__c>();
                set<String> DetailSourceUpdateIds = new set<String>();
                if(TargetRecMap.containskey(i))
                    SfmReocrdlst = TargetRecMap.get(i);
                String ObjectName = '';
                String AliasName = '';
                String ParentColumnName = '';
                list<String> DetailSourceRecUpdateIds = new list<String>(); 
                if(DetailObjName.containskey(i))
                    ObjectName = DetailObjName.get(i);
                if(AliasNameMap.containskey(i))
                    AliasName = AliasNameMap.get(i);
                if(ParentColumnNameMap.containskey(i))
                    ParentColumnName = ParentColumnNameMap.get(i);
                //BAC-5357  
                Map<String,Schema.SObjectField> DetailFieldMap = new Map<String,Schema.SObjectField>(); 
                if(String.isNotEmpty(ObjectName) && AllFieldDescribe.containskey(ObjectName)== false)
                {   
                    Map<String,Schema.SObjectField> dFieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(ObjectName);
                    if(!dFieldMap.isEmpty())
                    {
                        for(String s : dFieldMap.keyset())
                        {
                            DetailFieldMap.put(dFieldMap.get(s).getDescribe().getname(),dFieldMap.get(s));
                        }
                        AllFieldDescribe.put(ObjectName,DetailFieldMap);
                    }
                }
                system.debug('AllFieldDescribe'+AllFieldDescribe);
                system.debug('SfmReocrdlst'+SfmReocrdlst.size()+SfmReocrdlst);
               //BAC-5357
                if(!SfmReocrdlst.isEmpty())
                {
                    //-------Start------Added for the defect 044697
                    List<String> lstRecordIds = new List<String>();
                    for(SVMXC.SFM_WrapperDef.SFM_Record objRec: SfmReocrdlst){
                        if(!String.isBlank(objRec.targetRecordId)){
                            lstRecordIds.add(objRec.targetRecordId);
                        }
                    }
                    //-------End--------Added for the defect 044697
                    //BAC-5357 no use
                    //DetailRecordsForUpdate = new list<Sobject>();
                    //DetailRecordsForInsert = new list<Sobject>();  
                    //Build the Detail Sobject from key-value 
                    map<String,list<Sobject>> DetailSobjMap = new map<String,list<Sobject>>();
                    //Update scenario
                    //BAC-5357
                    if(String.isNotEmpty(ObjectName) && String.isNotEmpty(ParentColumnName) && HdrSObject != null && HdrSObject.get('Id') != null && String.isNotEmpty(String.valueof(HdrSObject.get('Id')))) 
                    {
                        //map<String,list<Sobject>> localmap = new  map<String,list<Sobject>>(); 
                        map<String,list<Sobject>> localmap = sobjectfromkevalue.BuildSobjectFromKeyValue2(SfmReocrdlst,ObjectName,ParentColumnName,String.valueof(HdrSObject.get('Id')),AllFieldDescribe);//AllFieldDescribe
                        if(!localmap.isEmpty())
                        {
                            for(String s :localmap.keyset())
                            {
                                if(s.touppercase() == 'UPDATE'){
                                    //-------Start------Added for the defect 044697
                                    List<Sobject> lstRecords = localmap.get(s);
                                    Map<String, Sobject> mapIdVsRecord = new Map<String, Sobject>();
                                    if(lstRecords != null && lstRecords.size() > 0){
                                        for(Sobject obj : lstRecords){
                                            mapIdVsRecord.put(String.valueOf(obj.get('Id')), obj);
                                        }
                                        lstRecords.clear();
                                        for(String recId : lstRecordIds){
                                            lstRecords.add(mapIdVsRecord.get(recId));
                                        }
                                        mapIdVsRecord = null;
                                        DetailSobjMap.put(s,lstRecords);
                                    }
                                    //-------End--------Added for the defect 044697
                                    //DetailSobjMap.put(s,localmap.get(s)); //Commented for defect 044697 fix
                                }
                            }
                        }
                    }
                    //insert scenario
                    //BAC-5357
                    if(!SfmReocrdlst.isEmpty() && String.isNotEmpty(ObjectName ) && String.isNotEmpty(ParentColumnName ))
                    {
                        //map<String,list<Sobject>> localmap = new  map<String,list<Sobject>>(); 
                        Map<String,list<Sobject>> localmap  = sobjectfromkevalue.BuildSobjectFromKeyValue2(SfmReocrdlst,ObjectName,ParentColumnName,null,AllFieldDescribe);//AllFieldDescribe
                        if(!localmap.isEmpty())
                        {
                            for(String s :localmap.keyset())
                            {
                                if(s.touppercase() == 'INSERT')
                                DetailSobjMap.put(s,localmap.get(s));
                            }
                        }
                    }
                    //BAC-5357
                    if(!DetailSobjMap.isEmpty())
                    {
                        list<Sobject> sobjList = new list<Sobject>();
                        for(String s : DetailSobjMap.keyset())
                        {
                            sobjList.addall(DetailSobjMap.get(s));
                        }
                        detailRecordMap.put(AliasName,sobjList);
                    }
                }    
            }
        }
        //BAC-5357 again set to false if it used in another webservice
        is_sfm_get_Header_executed = false;
        hdrSObject1 = null;
        return detailRecordMap;   
    }
    public SVMXC.SFM_WrapperDef.SFM_PageData SFM_Page_BuildResponse(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec,Sobject headerSobject,map<String,List<Sobject>> detailRecordMap)
    {
        SVMXC.SFM_WrapperDef.SFM_PageData pageData = new SVMXC.SFM_WrapperDef.SFM_PageData();
        //First get the Header Targrt Record anf Detail Target Record List.
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject hdrTargetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();//Second member of the SFM_TargetRecord Class
        List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> dtlTargetRecordObject = new List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();//Third member of the SFM_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)
            hdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            dtlTargetRecordObject = sfmtargetrec.detailRecords;
        system.debug('dtlTargetRecordObject'+dtlTargetRecordObject.size()+dtlTargetRecordObject);
        
        //Now Prcess the Header Taget Record.
        list<SVMXC.SFM_WrapperDef.SFM_Record> headerRecord = new list<SVMXC.SFM_WrapperDef.SFM_Record>();
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> hdrTargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        if(hdrTargetRecordObject.records.size() > 0)
                headerRecord = hdrTargetRecordObject.records;
        if(headerRecord.size() > 0)
        {
            if(headerRecord[0].targetRecordAsKeyValue != null && headerRecord[0].targetRecordAsKeyValue.size() > 0)
                hdrTargetRecordAsKeyValue = headerRecord[0].targetRecordAsKeyValue;
        }
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> targetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        if(hdrTargetRecordAsKeyValue.size() > 0 && headerSobject != null)
        {
            for(Integer i = 0 ;i<hdrTargetRecordAsKeyValue.size();i++)
            {
                if(hdrTargetRecordAsKeyValue[i].key != null && hdrTargetRecordAsKeyValue[i].key.length() > 0)//&& hdrTargetRecordAsKeyValue[i].value != null && hdrTargetRecordAsKeyValue[i].value.length() > 0
                {
                    SVMXC.SFM_WrapperDef.SFM_StringMap temp = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                    temp.key = hdrTargetRecordAsKeyValue[i].key;
                    temp.value = String.valueof(headerSobject.get(hdrTargetRecordAsKeyValue[i].key));
                    if(hdrTargetRecordAsKeyValue[i].value1 != null)
                        temp.value1 = hdrTargetRecordAsKeyValue[i].value1;
                    targetRecordAsKeyValue.add(temp);
                }   
            }
        }
        headerRecord[0].targetRecordAsKeyValue = null;
        headerRecord[0].targetRecordAsKeyValue = targetRecordAsKeyValue;
        headerRecord[0].sobjectinfo = headerSobject;
        //Create/update key/value for the Detail object
        if(dtlTargetRecordObject.size() > 0 && detailRecordMap.size() > 0)
        {
            for(Integer i = 0;i<dtlTargetRecordObject.size();i++)
            {   
                if(dtlTargetRecordObject[i].records != null && dtlTargetRecordObject[i].records.size() > 0)
                {
                    List<SVMXC.SFM_WrapperDef.SFM_Record> sfmReocrdlst = new List<SVMXC.SFM_WrapperDef.SFM_Record>(); 
                    sfmReocrdlst = dtlTargetRecordObject[i].records;
                    system.debug('sfmReocrdlst'+sfmReocrdlst.size()+sfmReocrdlst);
                    list<Sobject> detailSobjList = new list<Sobject>(); 
                    if(detailRecordMap.containskey(dtlTargetRecordObject[i].aliasName))
                        detailSobjList = detailRecordMap.get(dtlTargetRecordObject[i].aliasName);
                    system.debug('detailSobjList'+detailSobjList.size()+detailSobjList);
                    if(sfmReocrdlst.size() > 0)
                    {
                        for(Integer a = 0;a<sfmReocrdlst.size();a++)
                        {
                            list<SVMXC.SFM_WrapperDef.SFM_StringMap> detailTargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                            list<SVMXC.SFM_WrapperDef.SFM_StringMap> detailNewTargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                            detailTargetRecordAsKeyValue = sfmReocrdlst[a].targetRecordAsKeyValue;
                            system.debug('detailTargetRecordAsKeyValue'+detailTargetRecordAsKeyValue.size()+':Purav'+detailSobjList[a]);
                            if(detailTargetRecordAsKeyValue.size() > 0)
                            {
                                for(Integer b = 0;b<detailTargetRecordAsKeyValue.size();b++)
                                {
                                    if(detailTargetRecordAsKeyValue[b].key != null && detailTargetRecordAsKeyValue[b].key.length() > 0 )//&& detailTargetRecordAsKeyValue[b].value != null && detailTargetRecordAsKeyValue[b].value.length() > 0
                                    {
                                        SVMXC.SFM_WrapperDef.SFM_StringMap temp = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                                        temp.key = detailTargetRecordAsKeyValue[b].key;
                                        system.debug('amar'+detailSobjList[a]+':purav'+temp.key);
                                        system.debug('amarrrr'+detailSobjList[a]+detailTargetRecordAsKeyValue[b].key);
                                        //Commenting the below line as it is the root cause for 042708
                                        //Possible affected area - AutoEntitlementFromDetail
                                        temp.value = String.valueof(detailSobjList[a].get(detailTargetRecordAsKeyValue[b].key)); //Reverted the code fix of defect 042708 to fixing defect 044697
                                        //temp.value = detailTargetRecordAsKeyValue[b].value;
                                        if(detailTargetRecordAsKeyValue[b].value1 != null)
                                            temp.value1 = detailTargetRecordAsKeyValue[b].value1;
                                        system.debug('temp'+temp);
                                        detailNewTargetRecordAsKeyValue.add(temp); 
                                    }
                                }
                            }
                            sfmReocrdlst[a].targetRecordAsKeyValue = null;
                            sfmReocrdlst[a].targetRecordAsKeyValue = detailNewTargetRecordAsKeyValue;
                            sfmReocrdlst[a].sobjectinfo = detailSobjList[a];
                        }
                    }    
                }    
            }
        }
        SVMXC.SFM_buildPageData buildpagedata = new SVMXC.SFM_buildPageData();
        system.debug('sfmtargetrec'+sfmtargetrec);
        pageData = buildpagedata.SFM_buildPageData(sfmtargetrec);
        system.debug('pageData'+pageData);
        return pageData;
    } 
    public SVMXC.SFM_WrapperDef.SFM_TargetRecord buildSFMTargetRecord(String strProcessId, map<String,map<String,Sobject>> mapAliasNameMapSourceRecordIdTargetRecord)
    {
        system.debug('buildSFMTargetRecord called');
        SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmTargetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        map<String,SVMXC__ServiceMax_Processes__c> mapAliasNameChildNode = new map<String,SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObject = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c objSFMProcess = new SVMXC__ServiceMax_Processes__c();
        String strHeaderTargetObject = '';
       
        if(strProcessId != null && strProcessId.length() > 0)
        {
            sfmTargetRecord.sfmProcessId = strProcessId;
            if(SFM_ScheduledSFM_Utils.processId != null && SFM_ScheduledSFM_Utils.processId == strProcessId && SFM_ScheduledSFM_Utils.SFMProcess != null && SFM_ScheduledSFM_Utils.SFMProcess.id != null){
                objSFMProcess = SFM_ScheduledSFM_Utils.SFMProcess;
            }else {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                objSFMProcess = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c,SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c, SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C, SVMXC__Installation_Key__c,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c,SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById From  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Target Manager' and (Id =: strProcessId OR SVMXC__ProcessID__c =: strProcessId)];    
            }
            
            if(SFM_ScheduledSFM_Utils.processId != null && SFM_ScheduledSFM_Utils.processId == strProcessId && SFM_ScheduledSFM_Utils.processNodeList != null && SFM_ScheduledSFM_Utils.processNodeList.size() > 0){
                lstProcessNodeObject = SFM_ScheduledSFM_Utils.processNodeList;
            } else if(objSFMProcess != null && objSFMProcess.id != null){
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstProcessNodeObject = [Select Name,SVMXC__ProcessID__c,SVMXC__Page_Layout__c,SVMXC__Parent_Column_Name__c,SVMXC__Final_Exception_Process__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Node_Source_Object_API__c,SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c  From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: objSFMProcess.id and RecordType.Name  = 'Process Node Objects'];    
            }
            system.debug('objSFMProcess'+objSFMProcess);
            system.debug('lstProcessNodeObject'+lstProcessNodeObject);
       
            if(lstProcessNodeObject.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c PND : lstProcessNodeObject)
                {
                    if(PND.SVMXC__Type__c.touppercase() == 'TARGET')
                    {
                         if(PND.SVMXC__Source_Object_Name__c != null)   
                            strHeaderTargetObject = PND.SVMXC__Source_Object_Name__c;
                    }
                    else if(PND.SVMXC__Type__c.touppercase() == 'TARGETCHILD')
                    {
                        if(PND.SVMXC__Page_Layout__c != null)
                            mapAliasNameChildNode.put(String.valueof(PND.SVMXC__Page_Layout__c).substring(0,15),PND);
                    }
                }
            }
       
        }
        system.debug('mapAliasNameChildNode'+mapAliasNameChildNode);    
        if(mapAliasNameMapSourceRecordIdTargetRecord != null && mapAliasNameMapSourceRecordIdTargetRecord.size() > 0)
        {
            list<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> lstTargetRecordObject = new list<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();
            for(String strAliasName : mapAliasNameMapSourceRecordIdTargetRecord.keyset())
            {
                map<String,Sobject> mapSourceRecIdTargetRecord = new map<String,Sobject>();
                SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
                mapSourceRecIdTargetRecord = mapAliasNameMapSourceRecordIdTargetRecord.get(strAliasName);
                if(strHeaderTargetObject != null && strHeaderTargetObject.length() > 0 && strAliasName == strHeaderTargetObject)
                {
                    system.debug('Entered');
                    targetRecordObject.objName = strAliasName;
                    if(mapSourceRecIdTargetRecord != null && mapSourceRecIdTargetRecord.size() > 0)
                    {
                        list<SVMXC.SFM_WrapperDef.SFM_Record> lstSFMRecord = new list<SVMXC.SFM_WrapperDef.SFM_Record>();
                        for(String strSourceRecordId : mapSourceRecIdTargetRecord.keyset())
                        {
                            SVMXC.SFM_WrapperDef.SFM_Record sfmRecord = new SVMXC.SFM_WrapperDef.SFM_Record();
                            if(strSourceRecordId != 'NOSOURCEID')
                                sfmRecord.sourceRecordId = strSourceRecordId;
                            sfmRecord.sobjectinfo = mapSourceRecIdTargetRecord.get(strSourceRecordId);
                            if(mapSourceRecIdTargetRecord.get(strSourceRecordId).get('Id') != null)
                                sfmRecord.targetRecordId = String.valueof(mapSourceRecIdTargetRecord.get(strSourceRecordId).get('Id'));
                            lstSFMRecord.add(sfmRecord);    
                        }
                        targetRecordObject.records = lstSFMRecord;
                        sfmTargetRecord.headerRecord = targetRecordObject;
                    }
                    
                }
                else if(mapAliasNameChildNode.containskey(strAliasName))
                {
                    targetRecordObject.aliasName = strAliasName;
                    targetRecordObject.objName = mapAliasNameChildNode.get(strAliasName).SVMXC__Source_Object_Name__c;
                    targetRecordObject.parentColumnName = mapAliasNameChildNode.get(strAliasName).SVMXC__Parent_Column_Name__c;
                    targetRecordObject.pageLayoutId = strAliasName;
                    system.debug('mapSourceRecIdTargetRecord'+mapSourceRecIdTargetRecord);
                    if(mapSourceRecIdTargetRecord != null && mapSourceRecIdTargetRecord.size() > 0)
                    {
                        list<SVMXC.SFM_WrapperDef.SFM_Record> lstSFMRecord = new list<SVMXC.SFM_WrapperDef.SFM_Record>();
                        for(String strSourceRecordId : mapSourceRecIdTargetRecord.keyset())
                        {
                            SVMXC.SFM_WrapperDef.SFM_Record sfmRecord = new SVMXC.SFM_WrapperDef.SFM_Record();
                            if(strSourceRecordId != 'NOSOURCEID')
                                sfmRecord.sourceRecordId = strSourceRecordId;
                            sfmRecord.sobjectinfo = mapSourceRecIdTargetRecord.get(strSourceRecordId);
                            if(mapSourceRecIdTargetRecord.get(strSourceRecordId).get('Id') != null)
                                sfmRecord.targetRecordId = String.valueof(mapSourceRecIdTargetRecord.get(strSourceRecordId).get('Id'));
                            lstSFMRecord.add(sfmRecord);    
                        }
                        targetRecordObject.records = lstSFMRecord;
                        lstTargetRecordObject.add(targetRecordObject);
                    }
                }
                sfmTargetRecord.detailRecords = lstTargetRecordObject;
            }
        }
        system.debug('sfmTargetRecord'+sfmTargetRecord);
        return sfmTargetRecord;
    }
    public SVMXC.SFM_WrapperDef.SFM_TargetRecord buildSFMTargetRecord1(String strProcessId, map<String,list<Sobject>> mapAliasNamelistOfTargetRecords)
    {
        SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmTargetRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecord();
        map<String,SVMXC__ServiceMax_Processes__c> mapAliasNameChildNode = new map<String,SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObject = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c objSFMProcess = new SVMXC__ServiceMax_Processes__c();
        String strHeaderTargetObject = '';
       
        if(strProcessId != null && strProcessId.length() > 0)
        {
            sfmTargetRecord.sfmProcessId = strProcessId;
            if(SFM_ScheduledSFM_Utils.processId != null && SFM_ScheduledSFM_Utils.processId == strProcessId && SFM_ScheduledSFM_Utils.SFMProcess != null && SFM_ScheduledSFM_Utils.SFMProcess.id != null){
                objSFMProcess = SFM_ScheduledSFM_Utils.SFMProcess;
            }else {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                objSFMProcess = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c,SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c, SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C, SVMXC__Installation_Key__c,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c,SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById From  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Target Manager' and (Id =: strProcessId OR SVMXC__ProcessID__c =: strProcessId)];    
            }
            
            if(SFM_ScheduledSFM_Utils.processId != null && SFM_ScheduledSFM_Utils.processId == strProcessId && SFM_ScheduledSFM_Utils.processNodeList != null && SFM_ScheduledSFM_Utils.processNodeList.size() > 0){
                lstProcessNodeObject = SFM_ScheduledSFM_Utils.processNodeList;
            } else if(objSFMProcess != null && objSFMProcess.id != null){
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstProcessNodeObject = [Select Name,SVMXC__ProcessID__c,SVMXC__Page_Layout__c,SVMXC__Parent_Column_Name__c,SVMXC__Final_Exception_Process__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Node_Source_Object_API__c,SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c  From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: objSFMProcess.id and RecordType.Name  = 'Process Node Objects'];    
            }
            system.debug('objSFMProcess'+objSFMProcess);
            system.debug('lstProcessNodeObject'+lstProcessNodeObject);
       
            if(lstProcessNodeObject.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c PND : lstProcessNodeObject)
                {
                    if(PND.SVMXC__Type__c.touppercase() == 'TARGET')
                    {
                         if(PND.SVMXC__Source_Object_Name__c != null)   
                            strHeaderTargetObject = PND.SVMXC__Source_Object_Name__c;
                    }
                    else if(PND.SVMXC__Type__c.touppercase() == 'TARGETCHILD')
                    {
                        if(PND.SVMXC__Page_Layout__c != null)
                            mapAliasNameChildNode.put(String.valueof(PND.SVMXC__Page_Layout__c).substring(0,15),PND);
                    }
                }
            }
        }
        if(mapAliasNamelistOfTargetRecords != null && mapAliasNamelistOfTargetRecords.size() > 0)
        {
            list<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> lstTargetRecordObject = new list<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();
            for(String strAliasName : mapAliasNamelistOfTargetRecords.keyset())
            {
                SVMXC.SFM_WrapperDef.SFM_TargetRecordObject targetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
                list<Sobject> lstSobject = new list<Sobject>();
                if(strHeaderTargetObject != null && strHeaderTargetObject.length() > 0 && strAliasName == strHeaderTargetObject)
                {
                    targetRecordObject.objName = strAliasName;
                    lstSobject = mapAliasNamelistOfTargetRecords.get(strAliasName);
                    list<SVMXC.SFM_WrapperDef.SFM_Record> lstSFMRecord = new list<SVMXC.SFM_WrapperDef.SFM_Record>();
                    if(lstSobject.size() > 0)
                    {
                        SVMXC.SFM_WrapperDef.SFM_Record sfmRecord = new SVMXC.SFM_WrapperDef.SFM_Record();
                        sfmRecord.sobjectinfo = lstSobject[0];
                        if(lstSobject[0].get('Id') != null)
                            sfmRecord.targetRecordId = String.valueof(lstSobject[0].get('Id'));
                        lstSFMRecord.add(sfmRecord);    
                    }   
                    targetRecordObject.records = lstSFMRecord;
                    sfmTargetRecord.headerRecord = targetRecordObject;
                }
                else if(mapAliasNameChildNode.containskey(strAliasName))
                {
                    targetRecordObject.aliasName = strAliasName;
                    targetRecordObject.objName = mapAliasNameChildNode.get(strAliasName).SVMXC__Source_Object_Name__c;
                    targetRecordObject.parentColumnName = mapAliasNameChildNode.get(strAliasName).SVMXC__Parent_Column_Name__c;
                    targetRecordObject.pageLayoutId = strAliasName;
                    lstSobject = mapAliasNamelistOfTargetRecords.get(strAliasName);
                    if(lstSobject.size() > 0)
                    {
                        list<SVMXC.SFM_WrapperDef.SFM_Record> lstSFMRecord = new list<SVMXC.SFM_WrapperDef.SFM_Record>();
                        for(Integer i = 0;i<lstSobject.size();i++)
                        {
                            SVMXC.SFM_WrapperDef.SFM_Record sfmRecord = new SVMXC.SFM_WrapperDef.SFM_Record();
                            sfmRecord.sobjectinfo = lstSobject[i];
                            if(lstSobject[i].get('Id') != null)
                                sfmRecord.targetRecordId = String.valueof(lstSobject[i].get('Id'));
                            lstSFMRecord.add(sfmRecord);    
                        }
                        targetRecordObject.records = lstSFMRecord;
                        lstTargetRecordObject.add(targetRecordObject);
                    }
                }
                sfmTargetRecord.detailRecords = lstTargetRecordObject;
            }
        }
        system.debug('sfmTargetRecord'+sfmTargetRecord);    
        return sfmTargetRecord;
    }
    public static String buildQueryColumnsFromSet(set<String> setFields){
        String strFields = '';
        if(setFields.size() > 0){
            for(String str : setFields){
                if(strFields != null && strFields.length() > 0){
                    strFields += ','+str;
                }
                else{
                    strFields += str;
                }
            }
        }
        return strFields;
    }
    
}