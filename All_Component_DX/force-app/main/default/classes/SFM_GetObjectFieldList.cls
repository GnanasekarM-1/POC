public with sharing class SFM_GetObjectFieldList {
    
    private Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    public Map<String, Schema.SObjectType> mapObjAPINameDescribe = new Map<String, Schema.SObjectType>();
    private SFM_Utils utils = new SFM_Utils(); 
    private SVMX_Constants constants = new SVMX_Constants();
    SVMXC.COMM_Utils comutils = new SVMXC.COMM_Utils();
    
    public integer bubbleCount = 0;
    public integer resultCount = 0;
    public integer maxBubbleCount = constants.maxBubbleCount;
    public integer maxResultsetCount = constants.maxResultsetCount;
    
    
    public SFM_getObjectFieldList(){
        allObjs = Schema.getGlobalDescribe();
        for(String str : allObjs.keyset()){
            mapObjAPINameDescribe.put(allObjs.get(str).getDescribe().getName(),allObjs.get(str));
        } 
    }
    
    public SFM_WrapperDef.SFM_Response_ObjectFields getObjectFieldList(SFM_WrapperDef.SFM_Request req){
        SFM_WrapperDef.SFM_Response_ObjectFields result = new SFM_WrapperDef.SFM_Response_ObjectFields();
        set<String> blacklistedObjects = new set<String>();
        set<String> whitelistedObjects = new set<String>();
        Map<String,String> request = new Map<String,String>();
        request = utils.getStringMap(req.stringMap);
        
        Map<String,Boolean> whitelist = new Map<String,Boolean>();
        whitelist = comutils.SVMX_getPermittedStandardObjectList();
        for(String whitefield: whitelist.keySet())
        {
            system.debug('whitefield: '+whitefield);
            whitelistedObjects.add(whitefield);
        }
        system.debug('whitelistedObjects'+whitelistedObjects);
        system.debug('TETS LOG:3'+req);
        String reqType = request.get('OBJECTTYPE');
        if(reqType.toUpperCase() == 'EXPRESSION'){
            List<String> checkProperty = new List<String>();
            checkProperty.add('isFilterable');
            //blacklistedObjects = utils.getBlackList('RESTRICTED LIST5');
            blacklistedObjects = utils.getBlackList('BLOCKED IN EXPRESSIONS');
            system.debug('BlakObject'+blacklistedObjects);
            result = getObjectFieldList(request.get('OBJECTNAME'), checkProperty, blacklistedObjects, whitelistedObjects,reqType.toUpperCase());
        }
        else if(reqType.toUpperCase() == 'SEARCH'){
            List<String> checkProperty = new List<String>();
            //checkProperty.add('isUpdateable');
            checkProperty.add('isFilterable');
            //blacklistedObjects = utils.getBlackList('RESTRICTED LIST6');
            blacklistedObjects = utils.getBlackList('BLOCKED IN SEARCH');
            result = getObjectFieldList(request.get('OBJECTNAME'), checkProperty, blacklistedObjects, whitelistedObjects,reqType.toUpperCase());
        }
        else if(reqType.toUpperCase() == 'LOOKUPCONFIG'){
            List<String> checkProperty = new List<String>();
            //checkProperty.add('isUpdateable');//commented this property as Workorder Number was not appearing in the lookUP configuration
            //checkProperty.add('isFilterable');
            //blacklistedObjects = utils.getBlackList('RESTRICTED LIST6');
            blacklistedObjects = utils.getBlackList('BLOCKED IN SEARCH');
            result = getObjectFieldList(request.get('OBJECTNAME'), checkProperty, blacklistedObjects, whitelistedObjects,reqType.toUpperCase());
        }
        else if(reqType.toUpperCase() == 'SOURCEOBJECTUPDATE'){
            List<String> checkProperty = new List<String>();
            checkProperty.add('isUpdateable');
            //blacklistedObjects = utils.getBlackList('RESTRICTED LIST8');
            blacklistedObjects = utils.getBlackList('BLOCKED IN SRC OBJ UPD');
            result = getObjectFieldList(request.get('OBJECTNAME'), checkProperty, blacklistedObjects, whitelistedObjects,reqType.toUpperCase());
        }
        else if(reqType.toUpperCase() == 'MAPPING'){
            List<String> checkProperty = new List<String>();
            checkProperty.add('isCreateable');
            checkProperty.add('isUpdateable');
            //blacklistedObjects = utils.getBlackList('RESTRICTED LIST7');
            blacklistedObjects = utils.getBlackList('BLOCKED IN MAP');
            result = getObjectFieldList(request.get('OBJECTNAME'), checkProperty, blacklistedObjects, whitelistedObjects,reqType.toUpperCase());
        }
        else if(reqType.toUpperCase() == 'SCREEN'){ //GMFEB10-2011: Introduced for UI to restrict ref fields based on License
            List<String> checkProperty = new List<String>();
            checkProperty.add('isAccessible');
            blacklistedObjects = utils.getBlackList('BLOCKED IN SCREEN');
            system.debug('blacklistedObjects'+blacklistedObjects);
            result = getObjectFieldList(request.get('OBJECTNAME'), checkProperty, blacklistedObjects, whitelistedObjects,reqType.toUpperCase());
        }
        else if(reqType.toUpperCase() == 'REPORTDESIGNER')
        {
            List<String> checkProperty = new List<String>();
            checkProperty.add('isAccessible');
            blacklistedObjects = utils.getBlackList('BLOCKED IN SCREEN');
            system.debug('blacklistedObjects'+blacklistedObjects);
            result = getObjectFieldList(request.get('OBJECTNAME'), checkProperty, blacklistedObjects, whitelistedObjects,reqType.toUpperCase());
        }
        else if(reqType.toUpperCase() == 'EXPRESSIONFORBIZRULE'){
            list<String> checkProperty = new list<String>();
            checkProperty.add('isFilterable');
            blacklistedObjects = utils.getBlackList('BLOCKED IN EXPRESSIONS');
            system.debug('BlakObject'+blacklistedObjects);
            result = getObjectFieldList(request.get('OBJECTNAME'), checkProperty, blacklistedObjects, whitelistedObjects,reqType.toUpperCase());
        }
        system.debug('result: '+result);
        return result;
    }
    
    public SFM_WrapperDef.SFM_Response_ObjectFields getObjectFieldList(String objectName, List<String> checkProperty, set<String> blacklistedObjects, set<String> whitelistedObjects,String rectype)
    {
        SFM_WrapperDef.SFM_Response_ObjectFields response = new SFM_WrapperDef.SFM_Response_ObjectFields();
        SVMX_Debug  log = new SVMX_Debug();
        log.login('SFM_GetObjectFieldList', 'getObjectFieldList');
        List<SFM_WrapperDef.fieldProperties> fieldProp = new List<SFM_WrapperDef.fieldProperties>();
        List<Schema.SObjectType> dfdf = new List<Schema.SObjectType>();
        //If object exist in org
        boolean vartype;
        String APIName = utils.getOriginalAPIName(objectName, allObjs);
        if(objectName != NULL && allObjs.get(APIName)!= NULL)
        {
            Schema.SObjectType selectedObject = allObjs.get(APIName);
            Map<String,Schema.SObjectField> fieldMapping = selectedObject.getDescribe().fields.getMap();
            
            //-----Start------Added for the task BAC-4401 and defect 043715
            COMM_Utils_V2 objCOMM_UtilV2 = new COMM_Utils_V2();
            fieldMapping = objCOMM_UtilV2.removeDuplicateFields(fieldMapping);
            //-----End--------Added for the task BAC-4401 and defect 043715
            
            //Setup all blacklisted fields
            set<String> blacklistedFields = new set<String>();
            //Setup all blacklisted objects
            //set<String> blacklistedObjects = new set<String>();
            for(Schema.SObjectField fieldMap: fieldMapping.values())
            {
                //Describe the field to get all properties
                Schema.DescribeFieldResult field = fieldMap.getDescribe();
                system.debug('Field Describe'+field);
                String fieldRelatedTo = '';
                String fieldRelationshipname = '';
                //Special handeling for allowing Long TextArea field for Business Rule Expression.
                //Fixed defect 42663: Added filterable condition because isFilterable always false for Long text area
                if(rectype == 'EXPRESSIONFORBIZRULE' && field.getType().name() == 'TEXTAREA' && (!field.isFilterable())){
                    fieldProp.add(utils.DCX_makeFieldProperty(objectName,field.getName(), field.getLabel(),field.getType(),fieldRelatedTo,fieldRelationshipname,true, vartype, checkBubble('RESULTSET',field),field));    
                }
                if(utils.checkFieldAccessPermission(field, checkProperty))
                {
                    //Check to remove the rich text fields to be shown on page
                    if((rectype.toUpperCase() == 'SCREEN' ||rectype.toUpperCase() == 'LOOKUPCONFIG' ) && field.isHtmlFormatted())
                        continue;
                    if(!blacklistedFields.contains(field.getName()))
                    {
                        //if field is of reference type check the object permissions for the field
                        if(field.getType() == Schema.DisplayType.Reference && field.getReferenceTo() != null && field.getReferenceTo().size() > 0)
                        {
                            Schema.DescribeSObjectResult obejctDef = field.getReferenceTo()[0].getDescribe();
                            if(!blacklistedObjects.contains(obejctDef.getName()))
                            {
                                system.debug('Entered blaclist'+obejctDef);
                                if(!obejctDef.isCustom()) //If field points to standard objects
                                {
                                    if(whitelistedObjects.contains(obejctDef.getName()))
                                    {
                                        system.debug('Entered whiltelist'+obejctDef);
                                        //fieldProp.add(new SFM_WrapperDef.fieldProperties(field.getName(),field.getLabel(), field.isFilterable(), utils.getAvailableValues_Fields(String.valueof(field.getType()))));
                                        if(rectype.toUpperCase() == 'SEARCH')
                                           vartype = false;
                                        else
                                           vartype = checkBubble('BUBBLE',field);
                                            
                                        fieldRelationshipname = field.getRelationshipName();
                                        List<Schema.sObjectType> P = field.getReferenceTo();
                                        if(P.size() == 2)
                                        fieldRelatedTo = String.valueOf(P[1]);
                                        else
                                        fieldRelatedTo = String.valueOf(P[0]);
                                        fieldProp.add(utils.DCX_makeFieldProperty(objectName,field.getName(), field.getLabel(),field.getType(),fieldRelatedTo,fieldRelationshipname,field.isFilterable(), vartype, checkBubble('RESULTSET',field),field));
                                    }
                                }
                                else{//If field points to custom objects
                                    //fieldProp.add(new SFM_WrapperDef.fieldProperties(field.getName(), field.getLabel(), field.isFilterable(), utils.getAvailableValues_Fields(String.valueof(field.getType()))));
                                    if(rectype.toUpperCase() == 'SEARCH')
                                        vartype = false;
                                    else
                                        vartype = checkBubble('BUBBLE',field);
                                            
                                        fieldRelationshipname = field.getRelationshipName();
                                        List<Schema.sObjectType> P = field.getReferenceTo();
                                        if(P.size() == 2)
                                        fieldRelatedTo = String.valueOf(P[1]);
                                        else
                                        fieldRelatedTo = String.valueOf(P[0]);
                                        
                                    fieldProp.add(utils.DCX_makeFieldProperty(objectName,field.getName(), field.getLabel(),field.getType(),fieldRelatedTo,fieldRelationshipname,field.isFilterable(), vartype, checkBubble('RESULTSET',field),field));
                                }
                            }
                        }
                        //for other than reference fields
                        else
                        {
                            //fieldProp.add(new SFM_WrapperDef.fieldProperties(field.getName(), field.getLabel(), field.isFilterable(), utils.getAvailableValues_Fields(String.valueof(field.getType()))));
                            if(rectype.toUpperCase() == 'SEARCH')
                                vartype = false;
                            else
                                vartype = checkBubble('BUBBLE',field);
                                
                            if(rectype.toUpperCase() == 'LOOKUPCONFIG')
                            {
                                //if(field.getType() == Schema.Displaytype.Boolean){}
                                //else if(field.getType() == Schema.Displaytype.date){}
                                //else 
                                if(field.getType() == Schema.Displaytype.datetime){}
                                else
                                {
                                    // Bala(9-5-11): Ordering was not right adjusted the ordering to display the fields properly on lookup configuration
                                    fieldProp.add(utils.DCX_makeFieldProperty(objectName,field.getName(),field.getLabel(),field.getType(),fieldRelatedTo,fieldRelationshipname, checkSearchable(field), checkBubble('RESULTSET',field), checkDisplayable(field),field));
                                }
                            }
                            else
                            {
                                /*if(field.isHtmlFormatted() && rectype.toUpperCase() == 'REPORTDESIGNER'){
                                    fieldProp.add(utils.makeFieldProperty(field.getName(), field.getLabel(),field.getType(),fieldRelatedTo,fieldRelationshipname,field.isFilterable(), true, true));
                                }*/
                                fieldProp.add(utils.DCX_makeFieldProperty(objectName,field.getName(), field.getLabel(),field.getType(),fieldRelatedTo,fieldRelationshipname,field.isFilterable(), vartype, checkBubble('RESULTSET',field),field));
                                
                            }
                        }
                    }
                }
            }
        }
        system.debug('fieldProp:'+fieldProp);
        response.fields = fieldProp;
        response.response.success = true;
        response.response.logMsg = log.getlog();
        return response;
    }
    
    boolean checkBubble(String typ, Schema.DescribeFieldResult field){
        system.debug('fieldsBubble'+field);
        if(typ == 'BUBBLE' && bubbleCount > maxBubbleCount)
        return false;
        if(typ == 'RESULTSET' && resultCount > maxResultsetCount)
        return false;
        // If text area bubble is true, if long text area bubble is false
        if(field.getType()==Schema.DisplayType.TextArea)
        {
            if(field.isHtmlFormatted() || field.getLength() > 255)
                return false;
            else
                return true;
        }
        else if(field.getType()==Schema.DisplayType.Boolean)
        {
            return false;
        }
        else
            return true;
    }
    
    boolean checkSearchable(Schema.DescribeFieldResult field){
        if(!field.isFilterable() || field.getType() == Schema.Displaytype.Boolean || field.getType() == Schema.Displaytype.date || field.getType() == Schema.Displaytype.datetime)
            return false;
        else
            return true;
    }
    
    boolean checkDisplayable(Schema.DescribeFieldResult field){
        if(field.getType() == Schema.DisplayType.TextArea)
        {
            if(field.isHtmlFormatted())
                return false;
            else
                return true;
        }
        else
            return true;
    }
    public SFM_WrapperDef.SFM_Response getSortableFields(set<String> setObjectName){
        system.debug('setObjectName'+setObjectName);
        system.debug('allObjs'+allObjs);
        SVMXC.COMM_Utils comutils = new SVMXC.COMM_Utils();
        set<String> setWhiteListObject = new set<String>();
        map<String,String> mapObjectNameField = new map<String,String>();
        setWhiteListObject = comutils.SVMX_getPermittedStandardObjectList().keyset();
        list<SVMXC.SFM_WrapperDef.FieldSetWithSorting> lstFieldSetWithSorting = new list<SVMXC.SFM_WrapperDef.FieldSetWithSorting>();
        for(String objName : setObjectName){
            if(mapObjAPINameDescribe.containskey(objName)){
                system.debug('Entered');
                list<SVMXC.SFM_WrapperDef.SortingRec> lstSortingRec = new list<SVMXC.SFM_WrapperDef.SortingRec>();
                map<String,Schema.SObjectField> mapFieldDescribe = mapObjAPINameDescribe.get(objName).getDescribe().fields.getMap();
                //-----Start------Added for the task BAC-4401 and defect 043715
                COMM_Utils_V2 objCOMM_UtilV2 = new COMM_Utils_V2();
                mapFieldDescribe = objCOMM_UtilV2.removeDuplicateFields(mapFieldDescribe);
                //-----End--------Added for the task BAC-4401 and defect 043715
                system.debug('mapFieldDescribe'+mapFieldDescribe);
                if(mapFieldDescribe != null){
                    for(String fieldName : mapFieldDescribe.keyset()){
                        
                        Schema.DescribeFieldResult F = mapFieldDescribe.get(fieldName).getDescribe();
                        if(F.isSortable()){
                            SVMXC.SFM_WrapperDef.SortingRec sortingRec;
                            if(F.getType().name().equalsIgnoreCase('reference')){
                                Boolean doEnter = true;
                                Schema.DescribeSObjectResult obejctDef = F.getReferenceTo()[0].getDescribe();
                                
                                if(!obejctDef.isCustom()  && !setWhiteListObject.contains(obejctDef.getName())){
                                    doEnter = false;
                                }
                                
                                if(doEnter){
                                    String strNameField = '';
                                    if(!mapObjectNameField.containskey(obejctDef.getName())){
                                        map<String,Schema.SObjectField> mapFieldDescribe2 = mapObjAPINameDescribe.get(obejctDef.getName()).getDescribe().fields.getMap();
                                        for(String str : mapFieldDescribe2.keyset()){
                                            if(mapFieldDescribe2.get(str).getDescribe().isNameField()){
                                                strNameField = mapFieldDescribe2.get(str).getDescribe().getName();
                                                mapObjectNameField.put(obejctDef.getName(),mapFieldDescribe2.get(str).getDescribe().getName());
                                                break;
                                            }   
                                        }
                                    }else{
                                        strNameField = mapObjectNameField.get(obejctDef.getName());
                                    }
                                    sortingRec = new SVMXC.SFM_WrapperDef.SortingRec(F.getName(),null,F.getRelationshipName()+'.'+strNameField,F.getType().name(),obejctDef.getName(),F.getRelationshipName(),strNameField);
                                }   
                            }
                            else{ 
                                sortingRec = new SVMXC.SFM_WrapperDef.SortingRec(F.getName(),null,F.getName(),F.getType().name(),null,null,null);
                            }
                            lstSortingRec.add(sortingRec);
                        }
                    }
                    SVMXC.SFM_WrapperDef.FieldSetWithSorting fieldSetWithSorting = new SVMXC.SFM_WrapperDef.FieldSetWithSorting(null,lstSortingRec,objName,null,null,null);
                    lstFieldSetWithSorting.add(fieldSetWithSorting);
                }
            }
            SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
            system.debug('lstFieldSetWithSorting'+lstFieldSetWithSorting);
            response.lstFieldSetWithSorting = lstFieldSetWithSorting;
            return response;
        }   
        return null;       
    } 
    
}