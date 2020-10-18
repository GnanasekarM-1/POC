public class SFM_GetGlobalObjectList {
    
    public Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    public Map<String, Schema.DescribeSObjectResult> mapAPINameObjDesc = new Map<String, Schema.DescribeSObjectResult>();
    public List<Schema.SObjectType> listObjName = new List<Schema.SObjectType>();
    public Map<String,String> APITokenMap = new Map<String,String>(); 
    public Map<String,Boolean> PermittedStandardObjectList = new Map<String,Boolean>();
    SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
    SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils();
    private Boolean isSmartObjectRequired = false;//---based on this Smart Object will be added---//
    //Constructor
    public SFM_getGlobalObjectList()
    {
        allObjs = Schema.getGlobalDescribe(); 
        listObjName = allObjs.values();
        if(allObjs.size() > 0)
        {
            for(String s : allObjs.keyset())
            {
                Schema.DescribeSObjectResult objDesc = allObjs.get(s).getDescribe();
                APITokenMap.put(objDesc.getName(),s);
                if(!mapAPINameObjDesc.containskey(objDesc.getName()))
                    mapAPINameObjDesc.put(objDesc.getName(),objDesc);
            }
        }
        PermittedStandardObjectList = commutils.SVMX_getPermittedStandardObjectList();
    }
    //The method which called by webservice
    public SFM_WrapperDef.SFM_Response GetParetnObjects(SFM_WrapperDef.SFM_Request prequest)
    {
        List<SFM_WrapperDef.SFM_StringMap> StringMaplst = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();//Response
        if(prequest.stringMap != null)
            StringMaplst = prequest.stringMap;
        
        if(StringMaplst.size() > 0)
        {
            for(Integer i = 0;i<StringMaplst.size();i++)
            {
                if(StringMaplst[i].key.toUppercase() == 'OBJECTTYPE' && StringMaplst[i].value.toUppercase() == 'SOURCE'){
                    //---adding Smart Object---//
                    if(StringMaplst[i].value1 != null && StringMaplst[i].value1.toUppercase() == 'BOTH')
                        isSmartObjectRequired = true;
                    //-----//
                    response = GetALLParentObjectAPI(utils.getRestrictedListMap('BLOCKED SOURCE HEADER'));
                }
                    
                if(StringMaplst[i].key.toUppercase() == 'OBJECTTYPE' && StringMaplst[i].value.toUppercase() == 'AVAILABLE_SOURCE')
                    response = GetAllowedParentObjectAPI(StringMaplst);
                    
                if(StringMaplst[i].key.toUppercase() == 'OBJECTTYPE' && StringMaplst[i].value.toUppercase() == 'TARGET')
                    response = GetALLParentObjectAPI(utils.getRestrictedListMap('BLOCKED TARGET HEADER'));
                    
                if(StringMaplst[i].key.toUppercase() == 'OBJECTTYPE' && StringMaplst[i].value.toUppercase() == 'AVAILABLE_TARGET')
                    response = GetAllowedParentObjectAPI(StringMaplst);
                    
                //if(StringMaplst[i].key.toUppercase() == 'OBJECTTYPE' && StringMaplst[i].value.toUppercase() == 'SOURCE')
                    //response = GetParetnSourceObjects();
                //if(StringMaplst[i].key.toUppercase() == 'OBJECTTYPE' && StringMaplst[i].value.toUppercase() == 'TARGET')
                    //response = GetParetnTargetObjects();
                    
                if(StringMaplst[i].key.toUppercase() == 'OBJECTTYPE' && StringMaplst[i].value.toUppercase() == 'SEARCH')
                    response = GetSearchObjects();
                
                //List of all objects (Business Rules)
                if(StringMaplst[i].key.toUppercase() == 'OBJECTTYPE' && StringMaplst[i].value.toUppercase() == 'ALL')
                    response = GetSearchObjects();
            }
        }
        
        return response;
    }
    
    //The method which called by webservice
    public SFM_WrapperDef.SFM_Response GetChildObjects(SFM_WrapperDef.SFM_Request prequest)
    {
        system.debug('prequest'+prequest);
        List<SFM_WrapperDef.SFM_StringMap> StringMaplst = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();//Response
        Map<String,String> StringMap = new Map<String,String>();
        String ObjectType = '';
        if(prequest.stringMap != null)
            StringMaplst = prequest.stringMap;
        
        if(StringMaplst.size() > 0)
        {
            for(Integer i = 0;i<StringMaplst.size();i++)
            {
                if(StringMaplst[i].key.touppercase() == 'OBJECTTYPE')
                    ObjectType = StringMaplst[i].value;
                StringMap.put(StringMaplst[i].key.touppercase(),StringMaplst[i].value);
            }
        }
        if(StringMap.size() > 0)
        {
            if(ObjectType.toUpperCase() == 'SOURCE' && StringMap.containskey('OBJECTNAME'))//PARENTOBJECT
            {
                response = getChildSourceObject(StringMap.get('OBJECTNAME'));//PARENTOBJECT
            }
            if(ObjectType.toUpperCase() == 'TARGET' && StringMap.containskey('OBJECTNAME'))//PARENTOBJECT
            {
                response = getChildTargetObject(StringMap.get('OBJECTNAME'));//PARENTOBJECT
            }
            if(ObjectType.toUpperCase() == 'ALLCHILD' && StringMap.containskey('OBJECTNAME'))//PARENTOBJECT
            {
                response = getRelatedObjects(StringMap.get('OBJECTNAME'));//PARENTOBJECT
            }
        }
        return response;    
    }
    
    //This method will return all API name of Parent Source Object
    public SFM_WrapperDef.SFM_Response GetALLParentObjectAPI(Map<String,String> RestrictedMap)
    {
        system.debug('mapAPINameObjDesc'+mapAPINameObjDesc);
        system.debug('RestrictedMap'+RestrictedMap);
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> resultMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        try{
            if(mapAPINameObjDesc.size() > 0){
                for(String str : mapAPINameObjDesc.keyset()){
                    system.debug('APIName: '+str+' Describe Result: '+mapAPINameObjDesc.get(str));
                    if(mapAPINameObjDesc.get(str).isAccessible() && mapAPINameObjDesc.get(str).isUpdateable () && mapAPINameObjDesc.get(str).isQueryable()){
                        if(mapAPINameObjDesc.get(str).isCustom()){
                            if(!RestrictedMap.containskey(str)){
                                resultMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap(str,str,'SFDC_OBJECT'));
                            }
                        }
                        else{
                            //Added RestrictedMap check for standard object 
                            if(PermittedStandardObjectList.size() > 0 && PermittedStandardObjectList.containskey(str) && !RestrictedMap.containskey(str)){
                                resultMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap(str,str,'SFDC_OBJECT'));
                            }
                        }
                    }
                }
                //adding Smart Object
                if(isSmartObjectRequired){
                    Map<String, SmartObject.DescribeSmartObjectResult> mapAPINameAndSmartObject = SmartObject.getGlobalDescribe();
                    for(String apiName : mapAPINameAndSmartObject.keyset())
                        resultMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap(apiName,apiName,'SMART_OBJECT'));
                }
                if(resultMap.size() > 0){
                    response.stringMap = resultMap;
                    response.success = true;
                }
                else{
                    response.message = system.Label.SFM001_TAG171;
                    response.success = false;
                }
            }
        }
        catch(Exception ex){
            response.success = false;
            response.message = ex.getmessage();
        }
        return response;    
    }

    //This method will return all the Parent Source Object
    public SFM_WrapperDef.SFM_Response GetAllowedParentObjectAPI(List<SFM_WrapperDef.SFM_StringMap> StringMaplst)
    {
        List<SFM_WrapperDef.SFM_StringMap> resultMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        try
        {
            //calling global describe of Smart object
            Map<String, SmartObject.DescribeSmartObjectResult> mapAPINameAndSmartObject = new Map<String, SmartObject.DescribeSmartObjectResult>();
            for(SFM_WrapperDef.SFM_StringMap keyValue: StringMaplst)
            {
                if(keyValue.key.touppercase() != 'OBJECTTYPE')
                {
                    Schema.SObjectType lON = allObjs.get(APITokenMap.get(keyValue.value));
                    if(lON != NULL)
                    {
                        Schema.DescribeSObjectResult objDesc = lON.getDescribe();
                        resultMap.add(new SFM_WrapperDef.SFM_StringMap(objDesc.getName(),objDesc.getlabel(),'SFDC_OBJECT'));
                    }
                    else if(keyValue.value1 != null && keyValue.value1.touppercase() == 'SMART_OBJECT'){
                        if(mapAPINameAndSmartObject.isEmpty())
                            mapAPINameAndSmartObject = SmartObject.getGlobalDescribe();
                        if(mapAPINameAndSmartObject.containsKey(keyValue.value)){
                            resultMap.add(new SFM_WrapperDef.SFM_StringMap(keyValue.value,mapAPINameAndSmartObject.get(keyValue.value).label,'SMART_OBJECT'));
                        }
                    }
                }
            }
            if(resultMap.size() > 0)
            {
                response.stringMap = resultMap;
                response.success = true;
            }
            else
            {
                response.message = system.Label.SFM001_TAG171;
                response.success = false;
            }   
        }
        catch(Exception ex)
        {
            response.success = false;
            response.message = ex.getmessage();
        }
        return response;    
    }
    
    //This method will return all the Parent Source Object
    /*
    public SFM_WrapperDef.SFM_Response GetParetnSourceObjects()
    {
        Map<String,String> RestrictedMap1 = new Map<String,String>(); 
        //RestrictedMap1 = utils.getRestrictedListMap('RESTRICTED LIST1');
        RestrictedMap1 = utils.getRestrictedListMap('BLOCKED SOURCE HEADER');
        system.debug('RestrictedMap1'+RestrictedMap1);
        Map<String,String> mapPermittedAsHdr1 = new Map<String,String>(); 
        //mapPermittedAsHdr1 = utils.getRestrictedListMap('PERMITTED AS HDR1');
        mapPermittedAsHdr1 = utils.getRestrictedListMap('SOURCE HEADER EXCEPTION');
        
        List<SFM_WrapperDef.SFM_StringMap> resultMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        Map<String,String> AvaliableObj = new Map<String,String>();
        List<String> ChildObjLst = new List<String>();
        String strChildObjectName;
        try
        {
            if(listObjName.size() > 0)
            {
                for(Schema.SObjectType lON : listObjName) //Loop List of all Objects and describe each 
                {
                    Schema.DescribeSObjectResult objDesc = lON.getDescribe();
                    if(objDesc.isAccessible() == true && objDesc.isUpdateable () == true && objDesc.isQueryable() == true)
                    {
                        if(objDesc.isCustom())
                        {
                            if(!RestrictedMap1.containskey(objDesc.getname()))
                            {
                                system.debug('Entered'+objDesc.getname());
                                List<schema.Childrelationship> ChildObj = objDesc.getChildRelationships();
                                if(ChildObj.size() > 0)
                                {
                                    for(schema.Childrelationship CR:ChildObj)
                                    {
                                        strChildObjectName = CR.getChildSObject().getDescribe().getName();
                                        if(CR.isCascadeDelete() == true && !mapPermittedAsHdr1.containsKey(strChildObjectName))
                                        {
                                            ChildObjLst.add(strChildObjectName);
                                        }
                                    }
                                }
                                AvaliableObj.put(objDesc.getName(),objDesc.getlabel());
                            }
                        }
                        else
                        {
                            if(PermittedStandardObjectList.size() > 0 && PermittedStandardObjectList.containskey(objDesc.getname()))
                            {
                                List<schema.Childrelationship> ChildObj = objDesc.getChildRelationships();
                                if(ChildObj.size() > 0)
                                {
                                    for(schema.Childrelationship CR:ChildObj)
                                    {
                                        strChildObjectName = CR.getChildSObject().getDescribe().getName();
                                        if(CR.isCascadeDelete() == true && !mapPermittedAsHdr1.containsKey(strChildObjectName))
                                        {
                                            ChildObjLst.add(CR.getChildSObject().getDescribe().getName());
                                        }
                                    }
                                }
                                AvaliableObj.put(objDesc.getName(),objDesc.getlabel());
                            }
                        }       
                    }
                 }
                 if(ChildObjLst.size() > 0)
                 {
                    for(Integer i = 0;i<ChildObjLst.size();i++)
                    {
                        if(AvaliableObj.containskey(ChildObjLst[i]))
                            AvaliableObj.remove(ChildObjLst[i]);
                    }
                 }
                 if(AvaliableObj.size() > 0)
                 {
                    for(String s : AvaliableObj.keyset())
                    {
                        resultMap.add(new SFM_WrapperDef.SFM_StringMap(s,AvaliableObj.get(s)));
                    }
                 }
                 
                 if(resultMap.size() > 0)
                 {
                     response.stringMap = resultMap;
                     //response.message = 'Succes';
                     response.message = system.Label.SFM001_TAG171;
                     response.success = true;
                 }
                 else
                 {
                    //response.message = 'String map is empty';
                    response.message = system.Label.SFM001_TAG171;
                    response.success = false;
                 }   
            }
        }
        catch(Exception ex)
        {
            response.success = false;
            response.message = ex.getmessage();
        }
        return response;    
    }
    */
    //This Method will return the all Parent Target Object 
    /*
    public SFM_WrapperDef.SFM_Response GetParetnTargetObjects()
    {
        
        List<SFM_WrapperDef.SFM_StringMap> resultMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        Map<String,String> AvaliableObj = new Map<String,String>();
        map<String,String> RestrictedMap3 = new map<String,String>();
        //RestrictedMap3 = utils.getRestrictedListMap('RESTRICTED LIST3');
        RestrictedMap3 = utils.getRestrictedListMap('BLOCKED TARGET HEADER');
        Map<String,String> mapPermittedAsHdr2 = new Map<String,String>(); 
        //mapPermittedAsHdr2 = utils.getRestrictedListMap('PERMITTED AS HDR2');
        mapPermittedAsHdr2 = utils.getRestrictedListMap('TARGET HEADER EXCEPTION');
        List<String> ChildObjLst = new List<String>();
        String strChildObjectName;
        try
        {
            if(listObjName.size() > 0)
            {
                for(Schema.SObjectType lON : listObjName) //Loop List of all Objects and describe each 
                {
                    Schema.DescribeSObjectResult objDesc = lON.getDescribe();
                    if(objDesc.isAccessible() == true && objDesc.isUpdateable () == true && objDesc.isQueryable() == true && objDesc.isCreateable() == true)
                    {
                        if(objDesc.isCustom())
                        {
                            if(! RestrictedMap3.containskey(objDesc.getname()))
                            {
                                List<schema.Childrelationship> ChildObj = objDesc.getChildRelationships();
                                if(ChildObj.size() > 0)
                                {
                                    for(schema.Childrelationship CR:ChildObj)
                                    {
                                        strChildObjectName = CR.getChildSObject().getDescribe().getName();
                                        if(CR.isCascadeDelete() == true && !mapPermittedAsHdr2.containsKey(strChildObjectName))
                                        {
                                            ChildObjLst.add(strChildObjectName);
                                        }
                                    }
                                }
                                AvaliableObj.put(objDesc.getName(),objDesc.getlabel());
                            }
                        }
                        else
                        {
                            if(PermittedStandardObjectList.size() > 0 && PermittedStandardObjectList.containskey(objDesc.getname()))
                            {
                                List<schema.Childrelationship> ChildObj = objDesc.getChildRelationships();
                                if(ChildObj.size() > 0)
                                {
                                    for(schema.Childrelationship CR:ChildObj)
                                    {
                                        strChildObjectName = CR.getChildSObject().getDescribe().getName();
                                        if(CR.isCascadeDelete() == true && !mapPermittedAsHdr2.containsKey(strChildObjectName))
                                        {
                                            ChildObjLst.add(strChildObjectName);
                                        }
                                    }
                                }
                                AvaliableObj.put(objDesc.getName(),objDesc.getlabel());
                            }
                        }
                    }
                 }
                 if(ChildObjLst.size() > 0)
                 {
                    for(Integer i = 0;i<ChildObjLst.size();i++)
                    {
                        if(AvaliableObj.containskey(ChildObjLst[i]))
                            AvaliableObj.remove(ChildObjLst[i]);
                    }
                 }
                 if(AvaliableObj.size() > 0)
                 {
                    for(String s : AvaliableObj.keyset())
                    {
                        resultMap.add(new SFM_WrapperDef.SFM_StringMap(s,AvaliableObj.get(s)));
                    }
                 }
                 if(resultMap.size() > 0)
                 {
                     response.stringMap = resultMap;
                     response.message = system.Label.SFM001_TAG171;//'Succes';
                     response.success = true;
                 }
                 else
                 {
                    response.message = system.Label.SFM001_TAG171;//'String map is empty';
                    response.success = false;
                 }   
            }
        }
        catch(Exception ex)
        {
            response.success = false;
            response.message = ex.getmessage();
        }
        return response;
    }*/
    //This Method will return the all searchable objects
    public SFM_WrapperDef.SFM_Response GetSearchObjects()
    {
        List<SFM_WrapperDef.SFM_StringMap> resultMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        map<String,String> RestrictedMap9 = new map<String,String>();
        RestrictedMap9 = utils.getRestrictedListMap('RESTRICTED LIST9');
        try
        {
            if(listObjName.size() > 0)
            {
                for(Schema.SObjectType lON : listObjName) //Loop List of all Objects and describe each 
                {
                    Schema.DescribeSObjectResult objDesc = lON.getDescribe();
                    if(objDesc.isCustom())
                    {
                        if(!RestrictedMap9.containskey(objDesc.getname()))
                        resultMap.add(new SFM_WrapperDef.SFM_StringMap(objDesc.getName(),objDesc.getLabel()));

                    }
                    else
                    {
                        if(RestrictedMap9.containskey(objDesc.getname())==false)
                        {
                            if(PermittedStandardObjectList.size() > 0 && PermittedStandardObjectList.containskey(objDesc.getname()))
                            resultMap.add(new SFM_WrapperDef.SFM_StringMap(objDesc.getName(),objDesc.getLabel()));
                        
                        }
                    }       
                }
                
                if(resultMap.size() > 0)
                 {
                     response.stringMap = resultMap;
                     //response.message = system.Label.SFM001_TAG172;//'Success';
                     response.success = true;
                 }
                 else
                 {
                    response.message = system.Label.SFM001_TAG171;//'String map is empty';
                    response.success = false;
                 } 
            }
        }
        catch(Exception ex)
        {
            response.success = false;
            response.message = ex.getmessage();
        }
        return response;        
    }
    //This Method will return the child Source object
    public SFM_WrapperDef.SFM_Response getChildSourceObject(String APIName)
    {
        list<SFM_WrapperDef.SFM_StringFieldMap> resultMap = new list<SFM_WrapperDef.SFM_StringFieldMap>();
        list<schema.Childrelationship> ChildObj = new list<schema.Childrelationship>();
        map<String,String> RestrictedMap2 = new map<String,String>();
        map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
        RestrictedMap2 = utils.getRestrictedListMap('BLOCKED SOURCE CHILD');
        
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        system.debug('RestrictedMap2'+RestrictedMap2);
        String ObjectName = APIName;
        String Token = '';
        String chilRelName;
        if(APITokenMap.containskey(ObjectName))
            Token = APITokenMap.get(ObjectName);
        
        try{
            if(Token != null && Token.length() > 0)
                ChildObj  = allObjs.get(Token).getDescribe().getChildRelationships();
            system.debug('ChildObj'+ChildObj.size());
            if(ChildObj.size() > 0){
                for(Schema.ChildRelationship CR :ChildObj){
                    Schema.DescribeSObjectResult D = CR.getChildSObject().getDescribe();
                    chilRelName = CR.getField().getDescribe().getName();
                    String strObjLabelRelatedObjLabel = D.getLabel() +' ('+ CR.getField().getDescribe().getLabel() +')';
                    if( D.isAccessible() == true && D.isQueryable() == true && D.isUpdateable() == true){
                        if(D.isCustom()){
                            if(! RestrictedMap2.containskey(D.getname()))
                                resultMap.add(new SFM_WrapperDef.SFM_StringFieldMap(D.getName(),strObjLabelRelatedObjLabel,chilRelName));
                        }
                        else{
                            if(PermittedStandardObjectList.size() > 0 && PermittedStandardObjectList.containskey(D.getname()) == true  && RestrictedMap2.containskey(D.getName()) == false)
                                resultMap.add(new SFM_WrapperDef.SFM_StringFieldMap(D.getName(),strObjLabelRelatedObjLabel,chilRelName));
                        }   
                    }       
                }
            }
            if(resultMap.size() > 0)
             {
                 response.stringFieldMap = resultMap;
                 system.debug('stringFieldMap'+resultMap);
                 //response.message = system.Label.SFM001_TAG172;//'Succes';
                 response.success = true;
             }
             else
             {
                response.message = system.Label.SFM001_TAG171;//'The object dont have child object ';
                response.success = true;
             }   
        }
        catch(Exception ex)
        {
            response.success = false;
            response.message = ex.getmessage();
        }       
        return response;
    }
    //This Method will return the child Target object
    public SFM_WrapperDef.SFM_Response getChildTargetObject(String APIName)
    {
        List<SFM_WrapperDef.SFM_StringFieldMap> resultMap = new List<SFM_WrapperDef.SFM_StringFieldMap>();
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        List<schema.Childrelationship> ChildObj = new List<schema.Childrelationship>();
        map<String,String> RestrictedMap4 = new map<String,String>();
        RestrictedMap4 = utils.getRestrictedListMap('BLOCKED TARGET CHILD');
        String ObjectName = APIName;
        String Token = '';
        String chilRelName;
        system.debug('ObjectName :'+ObjectName);
        if(APITokenMap.containskey(ObjectName))
            Token = APITokenMap.get(ObjectName);
            
        try
        {
            if(Token != null)
            ChildObj  = allObjs.get(Token).getDescribe().getChildRelationships();
            //system.debug('ChildObjsize :'+ChildObj.size());
            if(ChildObj.size() > 0)
            {
                for(Schema.ChildRelationship CR :ChildObj)
                {
                    //if(CR.isCascadeDelete() ) //Commented by Amar to support task# 000525
                    //{
                        //system.debug('isCascadeDelete :');
                        Schema.DescribeSObjectResult D = CR.getChildSObject().getDescribe();
                        chilRelName = CR.getField().getDescribe().getName(); 
                        String strObjLabelRelatedObjLabel = D.getLabel() +' ('+ CR.getField().getDescribe().getLabel() +')';
                        //system.debug('isCascadeDelete :'+chilRelName);
                        if(D.isAccessible() == true && D.isQueryable() == true && D.isUpdateable() == true && D.isCreateable() == true)
                        {
                           // system.debug('isAccessible :');
                            if(D.isCustom())
                            {
                                //system.debug('isCustom():'+D.getname());
                                //system.debug('RestrictedMap4:'+RestrictedMap4);
                                if(! RestrictedMap4.containskey(D.getname()))
                                resultMap.add(new SFM_WrapperDef.SFM_StringFieldMap(D.getName(),strObjLabelRelatedObjLabel,chilRelName));
                                
                            }
                            else
                            {
                                //system.debug('NotCustom():'+D.getname());
                                //system.debug('RestrictedMap4:'+RestrictedMap4);
                                //system.debug('PermittedStandardObjectList:'+PermittedStandardObjectList);
                                if(PermittedStandardObjectList.size() > 0 && PermittedStandardObjectList.containskey(D.getname()) == true && RestrictedMap4.containskey(D.getName()) == false)
                                resultMap.add(new SFM_WrapperDef.SFM_StringFieldMap(D.getName(),D.getLabelPlural(),chilRelName));
                                
                            }       
                        }   
                    //}       
                }
            }
            if(resultMap.size() > 0)
             {
                 system.debug('Success:'+resultMap);
                 response.stringFieldMap = resultMap;
                 //response.message = system.Label.SFM001_TAG172;//'Succes';
                 response.success = true;
             }
             else
             {
                system.debug('False:'+resultMap);
                response.message = '';//system.Label.SFM001_TAG171;//'String map is empty or this object dont have child object';
                response.success = true;
             }   
        }
        catch(Exception ex)
        {
            response.success = false;
            response.message = ex.getmessage();
        }       
        return response;
    }
    //This Method will return the child Source object
    public SFM_WrapperDef.SFM_Response getRelatedObjects(String APIName)
    {
        List<SFM_WrapperDef.SFM_StringFieldMap> resultMap = new List<SFM_WrapperDef.SFM_StringFieldMap>();
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        List<schema.Childrelationship> ChildObj = new List<schema.Childrelationship>();
        map<String,String> RestrictedMap2 = new map<String,String>();
        Map<String, Schema.SObjectField> FieldMap = new Map<String, Schema.SObjectField>();
        //RestrictedMap2 = utils.getRestrictedListMap('RESTRICTED LIST2');
        RestrictedMap2 = utils.getRestrictedListMap('BLOCKED SOURCE CHILD');
        system.debug('RestrictedMap2'+RestrictedMap2);
        String ObjectName = APIName;
        String Token = '';
        String chilRelName;
        if(APITokenMap.containskey(ObjectName))
            Token = APITokenMap.get(ObjectName);

        try
        {
            if(Token != null && Token.length() > 0)
                ChildObj  = allObjs.get(Token).getDescribe().getChildRelationships();
            //system.debug('ChildObj'+ChildObj.size()+ChildObj);
            if(ChildObj.size() > 0)
            {
                for(Schema.ChildRelationship CR :ChildObj)
                {
                    Schema.DescribeSObjectResult D = CR.getChildSObject().getDescribe();
                    chilRelName = CR.getField().getDescribe().getName();
                    String strObjLabelRelatedObjLabel = D.getLabel() +' ('+ CR.getField().getDescribe().getLabel() +')'; 
                    if( D.isAccessible() == true && D.isQueryable() == true && D.isUpdateable() == true)
                    {
                        if(D.isCustom())
                        {
                            if(! RestrictedMap2.containskey(D.getname()))
                                resultMap.add(new SFM_WrapperDef.SFM_StringFieldMap(D.getName(),strObjLabelRelatedObjLabel,chilRelName));
                            
                        }
                        else
                        {
                            if(PermittedStandardObjectList.size() > 0 && PermittedStandardObjectList.containskey(D.getname()) == true  && RestrictedMap2.containskey(D.getName()) == false)
                                resultMap.add(new SFM_WrapperDef.SFM_StringFieldMap(D.getName(),strObjLabelRelatedObjLabel,chilRelName));
                            
                        }   
                    }       
                }
                //system.debug('resultMap'+resultMap.size()+resultMap);
            }
            if(resultMap.size() > 0)
             {
                 response.stringFieldMap = resultMap;
                 system.debug('stringFieldMap'+resultMap);
                 //response.message = system.Label.SFM001_TAG172;//'Succes';
                 response.success = true;
             }
             else
             {
                response.message = system.Label.SFM001_TAG171;//'The object dont have child object ';
                response.success = true;
             }   
        }
        catch(Exception ex)
        {
            response.success = false;
            response.message = ex.getmessage();
        }       
        return response;
    }
}