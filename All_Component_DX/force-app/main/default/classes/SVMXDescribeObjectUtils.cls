/**
 * @description This class implements the core capabilities for the Describe Object .
 
 * @author      Amar Joshi
 * @date        29.08.2012 
 * !!! Note :  
 */
public with sharing class SVMXDescribeObjectUtils {
    
    public object getDescribe(String strObjectName){ 
        
        map<String,list<String>> mapSourceValLstTargetFldVal = new map<String,list<String>>();
        map<String,map<String,list<String>>> mapSourceFldMapSourceValLstTargetFldValue = new map<String,map<String,list<String>>>();
        map<ID,String> mapRecordTypeIdLable = new map<ID,String>();
        list<RecordType> lstRecordType = [select Id, DeveloperName, Name from RecordType where SobjectType =: strObjectName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        set<String> setRecordTypeId = new set<String>();
        for(RecordType rt : lstRecordType){
            setRecordTypeId.add(rt.id);
            mapRecordTypeIdLable.put(rt.Id, rt.Name);
        }
        //Query For Record Type Describe
        map<Id,SVMXC__Field_Cache__c> mapFieldCache = new map<Id,SVMXC__Field_Cache__c>();
        list<SVMXC__Picklist_Cache__c> lstPicklistCache = new list<SVMXC__Picklist_Cache__c>();
        mapFieldCache.putall([select id,SVMXC__Field_API_Name__c,SVMXC__Object_Cache__c from SVMXC__Field_Cache__c where SVMXC__Object_Cache__r.SVMXC__Object_API_Name__c =: strObjectName and SVMXC__Field_API_Name__c = 'RecordTypeId' ]);//
        if(mapFieldCache.size() > 0 && setRecordTypeId.size() > 0){
            lstPicklistCache = [select Id, SVMXC__Source_Field_API_Name__c, SVMXC__Target_Field_API_Name__c, SVMXC__Source_Field__c, SVMXC__Source_Field__r.SVMXC__Field_API_Name__c, SVMXC__Source_Value__c, SVMXC__Target_Field__c, SVMXC__Target_Value__c, SVMXC__Target_Field__r.SVMXC__Field_API_Name__c from SVMXC__Picklist_Cache__c where SVMXC__Source_Field__c IN: mapFieldCache.keyset() and SVMXC__Source_Value__c IN : setRecordTypeId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            mapSourceValLstTargetFldVal = getServerCacheForRecordType(lstPicklistCache);
        }
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType targetType = null;
   
        targetType = gd.get(strObjectName);
        if(targetType == null){
            targetType = gd.get(strObjectName.replace('SVMXC__', ''));
        }
        
        Schema.DescribeSObjectResult result = targetType.getDescribe();
        mapFieldCache.clear();
        lstPicklistCache.clear();
        //Query for Dependent Picklist
        mapFieldCache.putall([select id,SVMXC__Field_API_Name__c,SVMXC__Object_Cache__c from SVMXC__Field_Cache__c where SVMXC__Object_Cache__r.SVMXC__Object_API_Name__c =: strObjectName]);
        if(mapFieldCache.size() > 0){
            lstPicklistCache = [select Id, SVMXC__Source_Field_API_Name__c, SVMXC__Target_Field_API_Name__c, SVMXC__Source_Field__c, SVMXC__Source_Field__r.SVMXC__Field_API_Name__c, SVMXC__Source_Value__c, SVMXC__Target_Field__c, SVMXC__Target_Value__c, SVMXC__Target_Field__r.SVMXC__Field_API_Name__c from SVMXC__Picklist_Cache__c where SVMXC__Source_Field__c IN: mapFieldCache.keyset()]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstPicklistCache.size() > 0){
                mapSourceFldMapSourceValLstTargetFldValue = getServerCache(mapFieldCache,lstPicklistCache);
            }   
            
        }
        system.debug('Result:'+new ObjectDescription(result,mapSourceFldMapSourceValLstTargetFldValue,mapSourceValLstTargetFldVal,mapRecordTypeIdLable));
        return new ObjectDescription(result,mapSourceFldMapSourceValLstTargetFldValue,mapSourceValLstTargetFldVal,mapRecordTypeIdLable);    
    }
    
   
    public class SaveObjectDescriptionRequest{
        
        public list<ObjectPicklistFieldDescription> lstFields = new list<ObjectPicklistFieldDescription>();
        
        public SaveObjectDescriptionRequest(){}
    }
    
    
    public class RecordTypeMappings{
        
        public Boolean available;
        public Boolean defaultRecordTypeMapping;
        public Id layoutId;
        public String name;
        public list<PicklistForRecordType> picklistsForRecordType = new list<PicklistForRecordType>();
        public Id recordTypeId;
        
        public RecordTypeMappings(String recordTypeId, String name, list<String> lstTargetFldVal){
            this.name = name;
            this.recordTypeId = recordTypeId;
            if(lstTargetFldVal.size() > 0){
                Integer i,l=lstTargetFldVal.size();
                for(i=0;i<l;i++){
                    picklistsForRecordType.add(new PicklistForRecordType(lstTargetFldVal[i]));
                }
            }           
            
        }
        public RecordTypeMappings(){}
    
    }
    public class PicklistForRecordType{
        
        public String picklistName; 
        public list<ObjectPicklistFieldEntry> picklistValues = new list<ObjectPicklistFieldEntry>();
        
        public PicklistForRecordType(String targetFldVal){
            list<String> lstString = targetFldVal.split('~');
            this.picklistName = lstString[0];
            picklistValues.add(new ObjectPicklistFieldEntry(new PicklistResultFromCache(lstString[1])));
        }    
        public PicklistForRecordType(){}
    }
    
    

    public class ObjectDescription{
        public String name;
        public String label;
        public String labelPlural;
        public Boolean updateable;
        public Boolean accessible;
        public List<ObjectFieldDescription> fields = new List<ObjectFieldDescription>();
        public list<RecordTypeMappings> recordTypeMapping = new list<RecordTypeMappings>();
        
        public ObjectDescription(Schema.DescribeSObjectResult result,map<String,map<String,list<String>>> mapSourceFldMapSourceValLstTargetFldValue,map<String,list<String>> mapSourceValLstTargetFldVal,map<ID,String> mapRecordTypeIdLable){
            
            name = result.getName();
            label = result.getLabel();
            labelPlural = result.getLabelPlural();
            accessible = result.isAccessible();
            updateable = result.isUpdateable();
            
            map<String,Schema.SObjectField> fldMap = result.fields.getMap();
            Schema.DescribeFieldResult f = null;
            ObjectFieldDescription fdesc = null;
            
            if(fldMap != null && fldMap.size() > 0){
                for(String s : fldMap.keyset()) {
                    f = fldMap.get(s).getdescribe();
                    if(f.getType().name() == 'Picklist' || f.getType().name() == 'MultiPicklist') {
                        map<String,list<String>> mapSourceValLstTargetFieldVal = null;
                        if(mapSourceFldMapSourceValLstTargetFldValue.size() > 0 && mapSourceFldMapSourceValLstTargetFldValue.containskey(f.getName())){
                            mapSourceValLstTargetFieldVal = mapSourceFldMapSourceValLstTargetFldValue.get(f.getName());
                        }
                        fdesc = new ObjectPicklistFieldDescription(f,mapSourceValLstTargetFieldVal);    
                    }
                    else if(f.getType().name() == 'boolean'){
                        system.debug('Entered'+f.getName());
                        map<String,list<String>> mapSourceValLstTargetFieldVal = null;
                        if(mapSourceFldMapSourceValLstTargetFldValue.size() > 0 && mapSourceFldMapSourceValLstTargetFldValue.containskey(f.getName())){
                            mapSourceValLstTargetFieldVal = mapSourceFldMapSourceValLstTargetFldValue.get(f.getName());
                        }
                        fdesc = new ObjectBooleanFieldDescriptoin(f,mapSourceValLstTargetFieldVal);
                        system.debug('Bla'+fdesc);  
                    }
                    else if(  f.getType().name() == 'double' 
                            || f.getType().name() == 'currency' 
                            || f.getType().name() == 'percent'){
                        fdesc = new ObjectNumberFieldDescription(f);
                    }
                    else{
                        fdesc = new ObjectFieldDescription(f);
                    }
                    fields.add(fdesc);
                }
            }
            if(mapSourceValLstTargetFldVal.size() > 0){
                for(String str : mapSourceValLstTargetFldVal.keyset()){
                    if(mapRecordTypeIdLable.containskey(str))
                        recordTypeMapping.add(new RecordTypeMappings(str, mapRecordTypeIdLable.get(str), mapSourceValLstTargetFldVal.get(str)));
                    else    
                        recordTypeMapping.add(new RecordTypeMappings(str, null, mapSourceValLstTargetFldVal.get(str)));
                }
            }
            
            
        }
        public ObjectDescription(){}
    }
    
    public virtual class ObjectFieldDescription {
        
        public String name;
        public String label;
        public Boolean updateable;
        public Boolean accessible;
        public Boolean nillable;
        public String inlineHelpText;
        public String dataType;
        public list<String> referenceTo = new list<String>();
        public ObjectFieldDescription(Schema.DescribeFieldResult result){
            name = result.getName();
            label = result.getLabel();
            accessible = result.isAccessible();
            updateable = result.isUpdateable();
            nillable = result.isNillable();
            inlineHelpText = result.getInlineHelpText();
            dataType = result.getType().name().toLowerCase();
            for(integer i = 0;i<result.getReferenceTo().size();i++){
                referenceTo.add(String.valueof(result.getReferenceTo()[i]));
            }
        }
    }
    
    public class ObjectNumberFieldDescription extends ObjectFieldDescription{
        public integer precision;
        public integer scale;
        public ObjectNumberFieldDescription(Schema.DescribeFieldResult result){
            super(result);
            precision = result.getPrecision();
            scale = result.getScale();
        }
    }
    public class ObjectBooleanFieldDescriptoin extends ObjectFieldDescription{
        public List<ObjectBooleanFieldEntry> picklistValues = new List<ObjectBooleanFieldEntry>();
        public Boolean dependentPicklist;
        public String controllerName;
        
        public ObjectBooleanFieldDescriptoin(Schema.DescribeFieldResult result,map<String,list<String>> mapSourceValLstTargetFieldVal){
            super(result);
            
            dependentPicklist = result.isDependentPicklist();
            if(dependentPicklist){
                controllerName = result.getController().getDescribe().getName();
            }
            
            list<String> picklistValue = new list<String>();
            picklistValue.add('false');
            picklistValue.add('true');
            Integer i = 0, l = picklistValue.size();
            for(i = 0; i < l; i++){
                list<String> lstTargetFldVal = null;
                if(mapSourceValLstTargetFieldVal != null)
                    lstTargetFldVal = mapSourceValLstTargetFieldVal.get(picklistValue[i]);
                    
                picklistValues.add(new ObjectBooleanFieldEntry(new PicklistResultForBoolean(picklistValue[i],lstTargetFldVal)));
            }
            System.debug(result);
        }
    
    }
    
    public class ObjectBooleanFieldEntry{
        public String label;
        public String value;
        public list<DependendPicklist> dependendPicklist = new list<DependendPicklist>();
        public ObjectBooleanFieldEntry(PicklistResult result){
            label = result.getLabel();
            value = result.getValue();
            dependendPicklist = result.getDependendPicklist();
        }
        public ObjectBooleanFieldEntry(){}
    }
    
    
    public class ObjectPicklistFieldDescription extends ObjectFieldDescription{
        public List<ObjectPicklistFieldEntry> picklistValues = new List<ObjectPicklistFieldEntry>();
        public Boolean dependentPicklist;
        public String controllerName;
        
        public ObjectPicklistFieldDescription(Schema.DescribeFieldResult result,map<String,list<String>> mapSourceValLstTargetFieldVal){
            super(result);
            
            dependentPicklist = result.isDependentPicklist();
            if(dependentPicklist){
                controllerName = result.getController().getDescribe().getName();
            }
            
            list<Schema.PicklistEntry> pleList = result.getPicklistValues();
            Integer i = 0, l = pleList.size();
            for(i = 0; i < l; i++){
                list<String> lstTargetFldVal = null;
                if(mapSourceValLstTargetFieldVal != null)
                    lstTargetFldVal = mapSourceValLstTargetFieldVal.get(pleList[i].getValue());
                    
                picklistValues.add(new ObjectPicklistFieldEntry(new PicklistResultFromDescribe(pleList[i],lstTargetFldVal)));
            }
            System.debug(result);
        }
        
    }
    
    public virtual class PicklistResult{
        public PicklistResult(){}
        public virtual Boolean active(){ return false; }
        public virtual String getValue(){ return ''; }
        public virtual String getLabel(){ return ''; }
        public virtual Boolean defaultValue(){ return false; }
        public virtual list<DependendPicklist> getDependendPicklist(){ return null; } 
    }
    
    public class PicklistResultFromDescribe extends PicklistResult{
        private Schema.PicklistEntry result;
        private list<String> lstTargetFldVal;
        public PicklistResultFromDescribe(Schema.PicklistEntry result,list<String> lstTargetFldVal){
            super();
            this.result = result;
            this.lstTargetFldVal = lstTargetFldVal;
        }
        public PicklistResultFromDescribe(){}
        
        public override String getValue(){ 
            return result.getValue(); 
        }
        public override String getLabel(){ 
            return result.getLabel(); 
        }
        public override Boolean defaultValue(){ 
            return result.isDefaultValue();
        }
        public override Boolean active(){ 
            return result.isActive();
        }
        public override list<DependendPicklist> getDependendPicklist(){ 
            list<DependendPicklist> dependendPicklist = new list<DependendPicklist>();
            if(lstTargetFldVal != null){
                Integer i,l=lstTargetFldVal.size();
                for(i=0;i<l;i++){
                    list<String> lstString = new list<String>();
                    lstString  = lstTargetFldVal[i].split('~');
                    dependendPicklist.add(new DependendPicklist(lstString[0],lstString[1]));
                }
            }
            return dependendPicklist;
        }
        
    }
    public class PicklistResultForBoolean extends PicklistResult{
        private String value;
        private list<String> lstTargetFldVal;
        public PicklistResultForBoolean(String value,list<String> lstTargetFldVal){
            super();
            this.value = value;
            this.lstTargetFldVal = lstTargetFldVal;
        }
        public PicklistResultForBoolean(){}
        
        public override String getValue(){ 
            return value; 
        }
        public override String getLabel(){ 
            return value; 
        }
        public override list<DependendPicklist> getDependendPicklist(){ 
            list<DependendPicklist> dependendPicklist = new list<DependendPicklist>();
            if(lstTargetFldVal != null){
                Integer i,l=lstTargetFldVal.size();
                for(i=0;i<l;i++){
                    list<String> lstString = new list<String>();
                    lstString  = lstTargetFldVal[i].split('~');
                    dependendPicklist.add(new DependendPicklist(lstString[0],lstString[1]));
                }
            }
            return dependendPicklist;
        }
        
    }
    public class PicklistResultFromCache extends PicklistResult{
        private String strTargetVal;
        public PicklistResultFromCache(String strTargetVal){
            super();
            this.strTargetVal = strTargetVal;
        }
        
        public override String getValue(){ 
            return strTargetVal;  
        }
        public override String getLabel(){ 
            return ''; 
        }
        public override Boolean defaultValue(){ 
            return false; 
        }
        public override Boolean active(){ 
            return false; 
        }
        
        public PicklistResultFromCache(){}
    }
    
    public class ObjectPicklistFieldEntry {
        public String label;
        public String value;
        public Boolean defaultValue;
        public Boolean active;
        public Integer index;
        public list<DependendPicklist> dependendPicklist = new list<DependendPicklist>();
        public ObjectPicklistFieldEntry(PicklistResult result){
            label = result.getLabel();
            value = result.getValue();
            active = result.active();
            defaultValue = result.defaultValue();
            dependendPicklist = result.getDependendPicklist();
        }
        public ObjectPicklistFieldEntry(){}
    }
    
    public class DependendPicklist{
        
        public String fieldAPIName;
        public String value;
        
        public DependendPicklist(String fieldAPIName, String value){
            this.fieldAPIName = fieldAPIName;
            this.value = value;
        }
        public DependendPicklist(){}
        
    }
    
    public static map<String,map<String,list<String>>> getServerCache(map<Id,SVMXC__Field_Cache__c> mapFieldCache,list<SVMXC__Picklist_Cache__c> lstPicklistCache)
    {
        //Variables..
        map<String,map<String,list<String>>> mapSourceFldMapSourceValLstTargetFldValue = new map<String,map<String,list<String>>>();
        for(SVMXC__Picklist_Cache__c pc:lstPicklistCache)
        {
            if(pc.SVMXC__Source_Value__c != null)
            {
                map<String,list<String>> mapSourceValLstTargetFldVal;
                if(mapSourceFldMapSourceValLstTargetFldValue.containskey(pc.SVMXC__Source_Field_API_Name__c))
                {
                    mapSourceValLstTargetFldVal = new map<String,list<String>>();
                    mapSourceValLstTargetFldVal = mapSourceFldMapSourceValLstTargetFldValue.get(pc.SVMXC__Source_Field_API_Name__c);
                    if(mapSourceValLstTargetFldVal.containskey(pc.SVMXC__Source_Value__c))
                    {
                        mapSourceFldMapSourceValLstTargetFldValue.get(pc.SVMXC__Source_Field_API_Name__c).get(pc.SVMXC__Source_Value__c).add(pc.SVMXC__Target_Field_API_Name__c+'~'+pc.SVMXC__Target_Value__c);
                    }
                    else
                    {
                        list<String> lstTargetFldVal = new list<String>();
                        lstTargetFldVal.add(pc.SVMXC__Target_Field_API_Name__c+'~'+pc.SVMXC__Target_Value__c);
                        if(mapSourceFldMapSourceValLstTargetFldValue.containskey(pc.SVMXC__Source_Field_API_Name__c))
                        {
                            mapSourceFldMapSourceValLstTargetFldValue.get(pc.SVMXC__Source_Field_API_Name__c).put(pc.SVMXC__Source_Value__c,lstTargetFldVal);
                        }
                        else
                        {
                            mapSourceValLstTargetFldVal = new map<String,list<String>>();
                            lstTargetFldVal = new list<String>();
                            lstTargetFldVal.add(pc.SVMXC__Target_Field_API_Name__c+'~'+pc.SVMXC__Target_Value__c);
                            mapSourceValLstTargetFldVal.put(pc.SVMXC__Source_Value__c,lstTargetFldVal);
                            mapSourceFldMapSourceValLstTargetFldValue.put(pc.SVMXC__Source_Field_API_Name__c,mapSourceValLstTargetFldVal);
                        }
                    }
                }
                else
                {
                    mapSourceValLstTargetFldVal = new map<String,list<String>>();
                    list<String> lstTargetFldVal = new list<String>();
                    lstTargetFldVal.add(pc.SVMXC__Target_Field_API_Name__c+'~'+pc.SVMXC__Target_Value__c);
                    mapSourceValLstTargetFldVal.put(pc.SVMXC__Source_Value__c,lstTargetFldVal);
                    mapSourceFldMapSourceValLstTargetFldValue.put(pc.SVMXC__Source_Field_API_Name__c,mapSourceValLstTargetFldVal);
                }
            }       
        }
        system.debug('mapSourceFldMapSourceValLstTargetFldValue: '+mapSourceFldMapSourceValLstTargetFldValue);
        return mapSourceFldMapSourceValLstTargetFldValue;
    }
    public map<String,list<String>> getServerCacheForRecordType(list<SVMXC__Picklist_Cache__c> lstPicklistCache)
    {
        map<String,list<String>> mapSourceValLstTargetFldVal = new map<String,list<String>>();
        if(lstPicklistCache.size() > 0)
        {
            for(SVMXC__Picklist_Cache__c pc : lstPicklistCache)
            {
                if(pc.SVMXC__Source_Value__c != null && pc.SVMXC__Target_Field_API_Name__c != null && pc.SVMXC__Target_Value__c != null)
                {
                    
                    if(mapSourceValLstTargetFldVal.containskey(pc.SVMXC__Source_Value__c))
                    {
                        mapSourceValLstTargetFldVal.get(pc.SVMXC__Source_Value__c).add(pc.SVMXC__Target_Field_API_Name__c+'~'+pc.SVMXC__Target_Value__c);
                    }
                    else
                    {
                        mapSourceValLstTargetFldVal.put(pc.SVMXC__Source_Value__c,new list<String>());
                        mapSourceValLstTargetFldVal.get(pc.SVMXC__Source_Value__c).add(pc.SVMXC__Target_Field_API_Name__c+'~'+pc.SVMXC__Target_Value__c);
                    }
                }     
            }
        }
        system.debug('mapSourceValLstTargetFldVal: '+mapSourceValLstTargetFldVal);
        return mapSourceValLstTargetFldVal;    
    }
    
}