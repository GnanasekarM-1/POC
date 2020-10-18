/* Security Scanned */
public with sharing class COMM_ServerCacheUtils
{
   
    public list<SVMXC.COMM_Webservices.ObjectDefination> getObjectDefinationForServceCache(){
        
        map<String,set<String>> mapObjectNameListRecordTypeId = new map<String,set<String>>();
        map<String,set<String>> mapObjectNameListPicklistField = new map<String,set<String>>();
        
        set<String> setObjectName = new set<String>();
        map<String,schema.Sobjecttype> gd = Schema.getGlobalDescribe();
        map<String,String> mapAllobjAPINameLabel = new map<String,String>();
        for(String str : gd.keyset()){
            mapAllobjAPINameLabel.put(gd.get(str).getDescribe().getName(),gd.get(str).getDescribe().getlabel());
        }
        
        list<SVMXC.COMM_Webservices.ObjectDefination> lstObjectDef = new list<SVMXC.COMM_Webservices.ObjectDefination>();
        list<SVMXC__Page_Layout_Detail__c> lstPageLayoutdetail = new list<SVMXC__Page_Layout_Detail__c>();
        list<RecordType> lstRecordType = new list<RecordType>();
        list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObject = [select id, SVMXC__Name__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Process Node Objects']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(lstProcessNodeObject.size() > 0){
            for(SVMXC__ServiceMax_Processes__c pro : lstProcessNodeObject){
                if(pro.SVMXC__Source_Object_Name__c != null)
                    setObjectName.add(pro.SVMXC__Source_Object_Name__c);
            }
        }
        if(setObjectName.size() > 0){
            lstRecordType = [select Id,Name, SobjectType From RecordType where SobjectType IN : setObjectName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstPageLayoutdetail = [select Id, SVMXC__Field_API_Name__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__r.SVMXC__Object_Name__c IN : setObjectName and (SVMXC__DataType__c = 'picklist' or SVMXC__DataType__c = 'multipicklist' or SVMXC__DataType__c = 'boolean')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        if(lstRecordType.size() > 0){
            for(RecordType R : lstRecordType){
                if(mapObjectNameListRecordTypeId.containskey(R.SobjectType))
                    mapObjectNameListRecordTypeId.get(R.SobjectType).add(R.Id);
                else{
                    mapObjectNameListRecordTypeId.put(R.SobjectType, new set<String>());
                    mapObjectNameListRecordTypeId.get(R.SobjectType).add(R.Id);
                }   
            }
        }
        if(lstPageLayoutdetail.size() > 0){
            for(SVMXC__Page_Layout_Detail__c PLD : lstPageLayoutdetail){
                if(PLD.SVMXC__Page_Layout__r.SVMXC__Object_Name__c != null && PLD.SVMXC__Field_API_Name__c != null){
                    if(mapObjectNameListPicklistField.containskey(PLD.SVMXC__Page_Layout__r.SVMXC__Object_Name__c))
                        mapObjectNameListPicklistField.get(PLD.SVMXC__Page_Layout__r.SVMXC__Object_Name__c).add(PLD.SVMXC__Field_API_Name__c);
                    else{
                        mapObjectNameListPicklistField.put(PLD.SVMXC__Page_Layout__r.SVMXC__Object_Name__c, new set<String>());
                        mapObjectNameListPicklistField.get(PLD.SVMXC__Page_Layout__r.SVMXC__Object_Name__c).add(PLD.SVMXC__Field_API_Name__c);
                    }   
                }       
            }
        }
        if(setObjectName.size() > 0){
            for(String str : setObjectName){
                list<String> lstRType = new list<String>();
                list<String> lstPicklistfield = new list<String>();
                if(mapObjectNameListRecordTypeId.containskey(str) )
                    lstRType.addall(mapObjectNameListRecordTypeId.get(str));
                if(mapObjectNameListPicklistField.containskey(str))
                    lstPicklistfield.addall(mapObjectNameListPicklistField.get(str));
                if(lstRType.size() > 0 || lstPicklistfield.size() > 0)
                    lstObjectDef.add(new SVMXC.COMM_Webservices.ObjectDefination(str, lstRType, lstPicklistfield, mapAllobjAPINameLabel.get(str)));
            }
        }
        system.debug('lstObjectDef'+lstObjectDef);
        return lstObjectDef;
       
         
    }
    
    
    public Object saveDescribeLayoutCache(String recordTypePicklist, String strObjectName)
    {
        deleteServerCache(strObjectName);
        system.debug('recordTypePicklist'+recordTypePicklist);
        system.debug('strObjectName'+strObjectName);
        //Variable Decleration..
        map<String, Schema.SObjectType> mapObjectAPINameDescribe = new map<String, Schema.SObjectType>();
        map<String, Schema.DescribeFieldResult> mapFieldAPINameDesc = new map<String, Schema.DescribeFieldResult>();
        map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        map<String,list<Schema.PicklistEntry>> mapFldAPINamePicklistValues = new map<String,list<Schema.PicklistEntry>>();
        map<String,SVMXC__Field_Cache__c> mapFldAPINameFldCacheRec = new map<String,SVMXC__Field_Cache__c>();
        map<String,list<SVMXC__Picklist_Cache__c>> mapFldAPINamePicklistCacheRec = new map<String,list<SVMXC__Picklist_Cache__c>>();
        map<String,String> mapFldAPINameFldCacheId = new map<String,String>();
        SVMXC__Object_Cache__c objObjectCache = new SVMXC__Object_Cache__c();
        SVMXC__Field_Cache__c objSourceField = new SVMXC__Field_Cache__c();
        list<SVMXC__Field_Cache__c> lstFieldCache = new list<SVMXC__Field_Cache__c>();
        
        system.debug('globalDesc'+gd);
        system.debug('recordTypePicklist'+recordTypePicklist);
        //Conver JSON String to User Defined Type
        list<SVMXDescribeObjectUtils.RecordTypeMappings> recordTypeMap = 
                (list<SVMXDescribeObjectUtils.RecordTypeMappings>) deserializeRequestTo(
                    recordTypePicklist, list<SVMXDescribeObjectUtils.RecordTypeMappings>.class);
        
        //Loop global describe and get describe object result.
        for(String str : gd.keyset()){
            if(gd.get(str).getDescribe().getName() == strObjectName){
                mapObjectAPINameDescribe.put(gd.get(str).getDescribe().getName(),gd.get(str));
            }   
        }
        system.debug('mapObjectAPINameDescribe'+mapObjectAPINameDescribe);
        map<String, Schema.SObjectField> mapFieldDesc = mapObjectAPINameDescribe.get(strObjectName).getDescribe().fields.getMap();
        //Do Field Describe of given object..
        if(mapFieldDesc.size() > 0)
        {
            for(String str : mapFieldDesc.keyset())
            {
                Schema.DescribeFieldResult result = mapFieldDesc.get(str).getDescribe();
                if(result.getType().name() == 'Picklist' || result.getType().name() == 'MultiPicklist')
                    mapFieldAPINameDesc.put(result.getName(),result);   
            }
        }
        //Check whether object's record  is availabel in database.
        list<SVMXC__Object_Cache__c> lstObjectCache = [select id, SVMXC__Object_API_Name__c from SVMXC__Object_Cache__c where SVMXC__Object_API_Name__c =: strObjectName limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstObjectCache.size() > 0){
            objObjectCache = lstObjectCache[0];
        }
        else{
            objObjectCache.SVMXC__Object_API_Name__c = strObjectName;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objObjectCache, COMM_SecurityUtils.Access.Createable ) ) {
                insert objObjectCache; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        //Check whether object's fields are available in database.
        lstFieldCache = [select id, SVMXC__Field_API_Name__c, SVMXC__Object_Cache__c from SVMXC__Field_Cache__c where SVMXC__Object_Cache__c =: objObjectCache.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstFieldCache.size() > 0){
            for(SVMXC__Field_Cache__c fld : lstFieldCache){
                if(!mapFldAPINameFldCacheRec.containskey(fld.SVMXC__Field_API_Name__c)){
                    mapFldAPINameFldCacheRec.put(fld.SVMXC__Field_API_Name__c,fld);
                }
            }
        }
        system.debug('mapFldAPINameFldCacheRec'+mapFldAPINameFldCacheRec); 
        if(mapFldAPINameFldCacheRec.containskey('RecordTypeId')){
            objSourceField = mapFldAPINameFldCacheRec.get('RecordTypeId');
        }
        else{
            objSourceField.SVMXC__Field_API_Name__c = 'RecordTypeId';    
            objSourceField.SVMXC__Object_Cache__c = objObjectCache.id;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objSourceField, COMM_SecurityUtils.Access.Createable ) ) {
                insert objSourceField; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        SVMXC__Field_Cache__c objFieldCache;
        SVMXC__Picklist_Cache__c objPicklistCache;
        system.debug('Heapsize:'+Limits.getHeapSize());
        //For Record Type based picklist..
        if(recordTypeMap.size() > 0){
            for(Integer a = 0;a<recordTypeMap.size();a++){
                list<SVMXC.SVMXDescribeObjectUtils.PicklistForRecordType> picklistForRecordType = new list<SVMXC.SVMXDescribeObjectUtils.PicklistForRecordType>();
                picklistForRecordType = recordTypeMap[a].picklistsForRecordType;
                if(picklistForRecordType !=null && picklistForRecordType.size() > 0){
                    Integer i=0,l=picklistForRecordType.size();
                    for(i=0;i<l;i++){
                        if(!mapFldAPINameFldCacheRec.containskey(picklistForRecordType[i].picklistName)){
                            objFieldCache = new SVMXC__Field_Cache__c(SVMXC__Object_Cache__c = objObjectCache.id,SVMXC__Field_API_Name__c = picklistForRecordType[i].picklistName);
                            mapFldAPINameFldCacheRec.put(picklistForRecordType[i].picklistName,objFieldCache);
                        }
                        system.debug('mapFldAPINameFldCacheRec'+mapFldAPINameFldCacheRec);   
                        list<SVMXC.SVMXDescribeObjectUtils.ObjectPicklistFieldEntry> picklistValues = new list<SVMXC.SVMXDescribeObjectUtils.ObjectPicklistFieldEntry>();
                        picklistValues = picklistForRecordType[i].picklistValues;
                        system.debug('picklistValues'+picklistValues);
                        if(picklistValues.size() > 0){
                            Integer j=0, m=picklistValues.size();
                            String strTargetval = '';
                            //set<String> setValues = new set<String>();
                            for(j=0;j<m;j++){
                                //setValues.add(picklistValues[j].value);
                                if(strTargetval != null && strTargetval.length() > 0)
                                    strTargetval += ';'+picklistValues[j].index;
                                else
                                    strTargetval += picklistValues[j].index;
                            }
                            /*if(setValues.size() > 0 && mapFieldAPINameDesc.containskey(picklistForRecordType[i].picklistName)){
                                list<Schema.PicklistEntry> lstPickListEntry = new list<Schema.PicklistEntry>();
                                if(! mapFldAPINamePicklistValues.containskey(picklistForRecordType[i].picklistName)){
                                     lstPickListEntry =  mapFieldAPINameDesc.get(picklistForRecordType[i].picklistName).getPicklistValues();
                                     mapFldAPINamePicklistValues.put(picklistForRecordType[i].picklistName,lstPickListEntry);
                                }
                                else{
                                    lstPickListEntry =  mapFldAPINamePicklistValues.get(picklistForRecordType[i].picklistName);
                                }
                                
                                if(lstPickListEntry.size() > 0){
                                    Integer k = 0, n = lstPickListEntry.size();
                                    String strTargetval = '';
                                    for(k=0;k<n;k++){
                                        if(setValues.contains(lstPickListEntry[k].getValue())){
                                            if(strTargetval != null && strTargetval.length() > 0)
                                                strTargetval += ';'+String.valueOf(k);
                                            else
                                                strTargetval += String.valueOf(k);
                                        }
                                    }
                                    if(strTargetval != null && strTargetval.length() > 0){
                                        objPicklistCache = new SVMXC__Picklist_Cache__c(SVMXC__Target_Value__c = strTargetval,SVMXC__Source_Field__c = objSourceField.id,SVMXC__Source_Value__c = recordTypeMap[a].recordTypeId);
                                        if(mapFldAPINamePicklistCacheRec.containskey(picklistForRecordType[i].picklistName))
                                        {
                                            mapFldAPINamePicklistCacheRec.get(picklistForRecordType[i].picklistName).add(objPicklistCache);
                                        }
                                        else
                                        {
                                            mapFldAPINamePicklistCacheRec.put(picklistForRecordType[i].picklistName, new list<SVMXC__Picklist_Cache__c>());
                                            mapFldAPINamePicklistCacheRec.get(picklistForRecordType[i].picklistName).add(objPicklistCache);
                                        }   
                                    }
                                }
                            }*/
                            if(strTargetval != null && strTargetval.length() > 0){
                                objPicklistCache = new SVMXC__Picklist_Cache__c(SVMXC__Target_Value__c = strTargetval,SVMXC__Source_Field__c = objSourceField.id,SVMXC__Source_Value__c = recordTypeMap[a].recordTypeId);
                                if(mapFldAPINamePicklistCacheRec.containskey(picklistForRecordType[i].picklistName)){
                                    mapFldAPINamePicklistCacheRec.get(picklistForRecordType[i].picklistName).add(objPicklistCache);
                                }
                                else{
                                    mapFldAPINamePicklistCacheRec.put(picklistForRecordType[i].picklistName, new list<SVMXC__Picklist_Cache__c>());
                                    mapFldAPINamePicklistCacheRec.get(picklistForRecordType[i].picklistName).add(objPicklistCache);
                                }   
                            }
                        }
                    }
                }
            }
        }
       system.debug('Heapsize:'+Limits.getHeapSize()); 
       system.debug('mapFldAPINameFldCacheRec'+mapFldAPINameFldCacheRec.size()+mapFldAPINameFldCacheRec);
        
        if(mapFldAPINameFldCacheRec.size() > 0 && mapFldAPINamePicklistCacheRec.size() > 0){
            list<SVMXC__Picklist_Cache__c> lstPicklistCacheToBeInserted = new list<SVMXC__Picklist_Cache__c>();
            list<SVMXC__Field_Cache__c> lstFieldCacheForUpsert =  mapFldAPINameFldCacheRec.values();
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstFieldCacheForUpsert, COMM_SecurityUtils.Access.Upsertable ) ) {
                upsert lstFieldCacheForUpsert; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            mapFldAPINameFldCacheRec.clear();
            for(SVMXC__Field_Cache__c fld :lstFieldCacheForUpsert){
                mapFldAPINameFldCacheId.put(fld.SVMXC__Field_API_Name__c,fld.id);
            }
            for(String str : mapFldAPINamePicklistCacheRec.keyset()){
                if(mapFldAPINameFldCacheId.containskey(str)){
                    list<SVMXC__Picklist_Cache__c> lstPicklistCache = new list<SVMXC__Picklist_Cache__c>();
                    lstPicklistCache = mapFldAPINamePicklistCacheRec.get(str);
                    if(lstPicklistCache.size() > 0){
                        for(SVMXC__Picklist_Cache__c picklist : lstPicklistCache){
                            picklist.SVMXC__Target_Field__c = mapFldAPINameFldCacheId.get(str);
                        }
                        lstPicklistCacheToBeInserted.addall(lstPicklistCache);
                    }
                    
                }   
            }
            if(lstPicklistCacheToBeInserted.size() > 0){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstPicklistCacheToBeInserted, COMM_SecurityUtils.Access.Createable ) ) {
                    insert lstPicklistCacheToBeInserted; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            system.debug('lstPicklistCacheToBeInserted'+lstPicklistCacheToBeInserted);   
        }
        
        return null;
    }
    public object saveDescribeObjectCache(String strDependendPicklist,String strObjectName){
        
        system.debug('strDependendPicklist'+strDependendPicklist);
        map<String, Schema.SObjectType> mapObjectAPINameDescribe = new map<String, Schema.SObjectType>();
        map<String, Schema.DescribeFieldResult> mapFieldAPINameDesc = new map<String, Schema.DescribeFieldResult>();
        map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        map<String,list<Schema.PicklistEntry>> mapFldAPINamePicklistValues = new map<String,list<Schema.PicklistEntry>>();
        map<String,SVMXC__Field_Cache__c> mapFldAPINameFldCacheRec = new map<String,SVMXC__Field_Cache__c>();
        map<String,String> mapFldAPINameFldCacheId = new map<String,String>();
        SVMXC__Object_Cache__c objObjectCache = new SVMXC__Object_Cache__c();
        list<SVMXC__Field_Cache__c> lstFieldCache = new list<SVMXC__Field_Cache__c>();
        
        SVMXDescribeObjectUtils.SaveObjectDescriptionRequest dependendPicklistMap = 
                (SVMXDescribeObjectUtils.SaveObjectDescriptionRequest) deserializeRequestTo(
                    strDependendPicklist, SVMXDescribeObjectUtils.SaveObjectDescriptionRequest.class);
        
        //Check whether object's record  is availabel in database.
        list<SVMXC__Object_Cache__c> lstObjectCache = [select id, SVMXC__Object_API_Name__c from SVMXC__Object_Cache__c where SVMXC__Object_API_Name__c =: strObjectName limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstObjectCache.size() > 0){
            objObjectCache = lstObjectCache[0];
        }
        else{
            objObjectCache.SVMXC__Object_API_Name__c = strObjectName;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objObjectCache, COMM_SecurityUtils.Access.Createable ) ) {
                insert objObjectCache;    
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        //Check whether object's fields are availabel in database.
        lstFieldCache = [select id, SVMXC__Field_API_Name__c, SVMXC__Object_Cache__c from SVMXC__Field_Cache__c where SVMXC__Object_Cache__c =: objObjectCache.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        set<Id> setFieldCache = new set<Id>();
        if(lstFieldCache.size() > 0){
            for(SVMXC__Field_Cache__c fld : lstFieldCache){
                if(!mapFldAPINameFldCacheRec.containskey(fld.SVMXC__Field_API_Name__c)){
                    mapFldAPINameFldCacheRec.put(fld.SVMXC__Field_API_Name__c,fld);
                }
                if(fld.SVMXC__Field_API_Name__c != 'RecordTypeId')
                    setFieldCache.add(fld.id);
            }
        }
        system.debug('setFieldCache'+setFieldCache);
        //Delete picklist cache other then RecordType Id fields..
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        list<SVMXC__Picklist_Cache__c> lstPickListCache = [select Id From SVMXC__Picklist_Cache__c where SVMXC__Source_Field_API_Name__c != 'RecordTypeId' and SVMXC__Source_Field__c IN :setFieldCache]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('lstPickListCache'+lstPickListCache);
        if(lstPickListCache.size() > 0) {
            if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Picklist_Cache__c' ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            delete lstPickListCache; //SDL-SVMX-DELETE-FLS-ENFORCED
        }
            
        SVMXC__Field_Cache__c objFieldCache;
        SVMXC__Picklist_Cache__c objPicklistCache; 
         //For Dependent picklist
        list<SVMXC.SVMXDescribeObjectUtils.ObjectPicklistFieldDescription> lstFields = new list<SVMXC.SVMXDescribeObjectUtils.ObjectPicklistFieldDescription>();
        lstFields = dependendPicklistMap.lstFields;
        system.debug('lstFields'+lstFields);
        map<String,SVMXC__Picklist_Cache__c> mapUniqueIdPicklistCacheRec = new map<String,SVMXC__Picklist_Cache__c>(); 
        if(lstFields.size() > 0)
        {   Integer i = 0,l=lstFields.size();
            for(i = 0;i<l;i++)
            {
                if( ! mapFldAPINameFldCacheRec.containskey(lstFields[i].name)){
                    objFieldCache = new SVMXC__Field_Cache__c(SVMXC__Object_Cache__c = objObjectCache.id,SVMXC__Field_API_Name__c = lstFields[i].name);
                    mapFldAPINameFldCacheRec.put(lstFields[i].name,objFieldCache);
                }
                list<SVMXC.SVMXDescribeObjectUtils.ObjectPicklistFieldEntry> picklistValues = new list<SVMXC.SVMXDescribeObjectUtils.ObjectPicklistFieldEntry>();
                picklistValues = lstFields[i].picklistValues;
                system.debug('picklistValues'+picklistValues);
                if(picklistValues != null && picklistValues.size() > 0)
                {
                    Integer j = 0,m=picklistValues.size();
                    for(j = 0;j < m;j++)
                    {
                        String strUnique = lstFields[i].name+'~'+picklistValues[j].value;
                        list<SVMXC.SVMXDescribeObjectUtils.DependendPicklist> dependendPicklist = new list<SVMXC.SVMXDescribeObjectUtils.DependendPicklist>();
                        if(picklistValues[j].dependendPicklist != null && picklistValues[j].dependendPicklist.size() > 0){
                            dependendPicklist = picklistValues[j].dependendPicklist;
                            Integer k = 0,n=dependendPicklist.size();
                            for(k=0;k<n;k++){
                                String strUniqueAll = strUnique + '~'+ dependendPicklist[k].fieldAPIName;
                                //strUnique += '~'+ dependendPicklist[k].fieldAPIName;
                                if( ! mapUniqueIdPicklistCacheRec.containskey(strUniqueAll) )//&& mapFieldAPINameDesc.containskey(dependendPicklist[k].fieldAPIName)
                                {
                                    SVMXC__Picklist_Cache__c objPicklist = new SVMXC__Picklist_Cache__c(SVMXC__Source_Value__c = picklistValues[j].value, SVMXC__Target_Value__c = dependendPicklist[k].value);
                                    mapUniqueIdPicklistCacheRec.put(strUniqueAll,objPicklist); 
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('mapUniqueIdPicklistCacheRec'+mapUniqueIdPicklistCacheRec.size()+mapUniqueIdPicklistCacheRec);
        if(mapFldAPINameFldCacheRec.size() > 0){
            list<SVMXC__Field_Cache__c> lstFieldCacheForUpsert =  mapFldAPINameFldCacheRec.values();
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstFieldCacheForUpsert, COMM_SecurityUtils.Access.Upsertable ) ) {
                upsert lstFieldCacheForUpsert; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            mapFldAPINameFldCacheRec.clear();
            for(SVMXC__Field_Cache__c fld :lstFieldCacheForUpsert){
                mapFldAPINameFldCacheId.put(fld.SVMXC__Field_API_Name__c,fld.id);
            }
        }               
        if(mapFldAPINameFldCacheId.size() > 0 && mapUniqueIdPicklistCacheRec.size() > 0)
        {
            for(String str : mapUniqueIdPicklistCacheRec.keyset()){
                list<String> lstString = new list<String>();
                lstString = str.split('~');
                system.debug('lstString'+lstString);
                if(lstString.size() > 0){
                    String strSourceField = lstString[0];
                    String strSourceValue = lstString[1];
                    String strTargetField = lstString[2];
                    if(mapFldAPINameFldCacheId.containskey(strSourceField) && mapFldAPINameFldCacheId.containskey(strTargetField)){
                        mapUniqueIdPicklistCacheRec.get(str).SVMXC__Source_Field__c = mapFldAPINameFldCacheId.get(strSourceField);
                        mapUniqueIdPicklistCacheRec.get(str).SVMXC__Source_Value__c = strSourceValue;
                        mapUniqueIdPicklistCacheRec.get(str).SVMXC__Target_Field__c = mapFldAPINameFldCacheId.get(strTargetField);
                    }
                }
            }
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( mapUniqueIdPicklistCacheRec.values(), COMM_SecurityUtils.Access.Upsertable ) ) {
                upsert mapUniqueIdPicklistCacheRec.values(); //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            system.debug('picklistcache'+mapUniqueIdPicklistCacheRec.values());
        }
        return null;
    
    }
    //Delete 
    public void deleteServerCache(String strObjectName)
    {
        List<String> queryFields = new List<String> {'Id'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Object_Cache__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        //Delete Object if exsisting..
        list<SVMXC__Object_Cache__c> objObjectCacheForDelete = [select id from SVMXC__Object_Cache__c where SVMXC__Object_API_Name__c =: strObjectName limit 1];
        if(objObjectCacheForDelete.size() > 0)
        {
            map<String,SVMXC__Field_Cache__c> mapFldCacheForDelete = new map<String,SVMXC__Field_Cache__c>();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            mapFldCacheForDelete.putall([select id from SVMXC__Field_Cache__c where SVMXC__Object_Cache__c =: objObjectCacheForDelete[0].id]);
            if(mapFldCacheForDelete.size() > 0)
            {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                list<SVMXC__Picklist_Cache__c> lstPicklstCacheForDelete = [select id from SVMXC__Picklist_Cache__c where SVMXC__Target_Field__c IN: mapFldCacheForDelete.keyset() OR SVMXC__Source_Field__c IN: mapFldCacheForDelete.keyset()];
                if(lstPicklstCacheForDelete.size() > 0) {
                    
                    if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Picklist_Cache__c' ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete lstPicklstCacheForDelete;
                }
                
                if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Field_Cache__c' ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete  mapFldCacheForDelete.values();
            }
            
            if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Object_Cache__c' ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            //SDL-SVMX-DELETE-FLS-ENFORCED
            delete objObjectCacheForDelete;
        }
    }
    
    static Object deserializeRequestTo(String requestStr, System.Type apexType){
        
        if(requestStr != null && requestStr != ''){
            return JSON.deserialize(requestStr, apexType);
        }
        return null;
    }
}