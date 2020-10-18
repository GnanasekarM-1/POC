public with sharing class SFM_AddRecordTemplate {

    public class RecordTemplate{
        public Sobject recordTemplate;
        public list<SVMXC.SFM_WrapperDef.SFM_StringMap> mappedValues = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        public list<SVMXC.SFM_WrapperDef.SFM_StringMap> mappedLiterals = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        public list<SVMXC.SFM_WrapperDef.SFM_StringMap> fieldMappedLiterals = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();//Added by Nidhi as part of BAC-4963
        
        public RecordTemplate(Sobject recordTemplate, list<SVMXC.SFM_WrapperDef.SFM_StringMap> mappedValues, list<SVMXC.SFM_WrapperDef.SFM_StringMap> mappedLiterals){
            this.recordTemplate = recordTemplate;
            this.mappedValues = mappedValues;
            this.mappedLiterals = mappedLiterals;
        }
         public RecordTemplate(Sobject recordTemplate, list<SVMXC.SFM_WrapperDef.SFM_StringMap> mappedValues, list<SVMXC.SFM_WrapperDef.SFM_StringMap> mappedLiterals,list<SVMXC.SFM_WrapperDef.SFM_StringMap> fieldMappedLiterals){
            this.recordTemplate = recordTemplate;
            this.mappedValues = mappedValues;
            this.mappedLiterals = mappedLiterals;
            this.fieldMappedLiterals = fieldMappedLiterals;
        }
    
    }
    
    public map<String,RecordTemplate> getRecordTemplate(map<String,SVMXC__ServiceMax_Processes__c> mapPagelayoutIdProcessNodeObject, map<String, Schema.SObjectType> allobjmap){
        SVMXC.SFM_Utils SFMUtils = new SVMXC.SFM_Utils();
        map<String,RecordTemplate> mapRecordTemplate = new map<String,RecordTemplate>();
        map<String,list<String>> mapAllObjDateTimeFields = new map<String,list<String>>();
        list<String> lstDateTimeField = new list<String>();
        list<Sobject> lstSobject = new list<Sobject>(); 
        SVMXC.SFM_ApplyMapping Mapping = new SVMXC.SFM_ApplyMapping();
        
        for(String str : mapPagelayoutIdProcessNodeObject.keyset()){
            lstDateTimeField.clear();
            if(allobjmap.containskey(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Source_Object_Name__c)){
                lstSobject.clear();
                list<SVMXC.SFM_WrapperDef.SFM_StringMap> mappedValues = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                list<SVMXC.SFM_WrapperDef.SFM_StringMap> mappedLiterals = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                list<SVMXC.SFM_WrapperDef.SFM_StringMap> fieldMappedLiterals = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                Sobject Sobj = allobjmap.get(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Source_Object_Name__c).newSObject();
                lstSobject.add(Sobj);
                //Added by Nidhi as part of BAC-4963
                //Get list of fields with litrals
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                Set<Id> mapIds = new Set<Id>();
                if(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Module__c !=null){
                    mapIds.add(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Module__c);
                }
                if(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Final_Exception_Process__c !=null){
                    mapIds.add(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Final_Exception_Process__c);
                }

                list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = [select Id,SVMXC__Display_Value__c,SVMXC__Target_Field_Name__c,SVMXC__MapID__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c =: mapIds and SVMXC__Display_Value__c != null];
                //Added by Nidhi as part of BAC-4963 Ends Here
            
                if(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Final_Exception_Process__c != null){
                    //This method (getValueMapping1) will always be called for new records only. So process type is not required. Call this method without Process type will check only isCreatable permission for new record.
                    lstSobject = Mapping.getValueMapping1(lstSobject,mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Final_Exception_Process__c,allobjmap,null); // mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Process__r.SVMXC__Purpose__c
                    
                    //Get list of fields with litrals
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    //list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = [select Id,SVMXC__Display_Value__c,SVMXC__Target_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c =: mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Final_Exception_Process__c and SVMXC__Display_Value__c != null];//Commented by Nidhi as part of BAC-4963
                    if(lstConfigData.size() > 0){
                        for(SVMXC__ServiceMax_Config_Data__c cd : lstConfigData){
                            if(cd.SVMXC__MapID__c == mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Final_Exception_Process__c){//Added by Nidhi as part of BAC-4963
                                if(cd.SVMXC__Display_Value__c == 'Today' || cd.SVMXC__Display_Value__c == 'Tomorrow' || cd.SVMXC__Display_Value__c == 'Yesterday' || cd.SVMXC__Display_Value__c == 'Now' || cd.SVMXC__Display_Value__c == 'SVMX.USERTRUNK' || cd.SVMXC__Display_Value__c == 'SVMX.SETNULL'){//BAC-5089 Added SVMX.SETNULL
                                    SVMXC.SFM_WrapperDef.SFM_StringMap strMap = new SVMXC.SFM_WrapperDef.SFM_StringMap(cd.SVMXC__Target_Field_Name__c,cd.SVMXC__Display_Value__c);
                                    mappedLiterals.add(strMap);
                                }   
                                else if(cd.SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORD.') || cd.SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORDHEADER.')){
                                    SVMXC.SFM_WrapperDef.SFM_StringMap strMap = new SVMXC.SFM_WrapperDef.SFM_StringMap(cd.SVMXC__Target_Field_Name__c,cd.SVMXC__Display_Value__c);
                                    mappedLiterals.add(strMap);
                                }else if(cd.SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LATITUDE') || cd.SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LONGITUDE') || cd.SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.ACCURACY')){ // Added for BAC-4677
                                        SVMXC.SFM_WrapperDef.SFM_StringMap strMap = new SVMXC.SFM_WrapperDef.SFM_StringMap(cd.SVMXC__Target_Field_Name__c,cd.SVMXC__Display_Value__c);
                                        mappedLiterals.add(strMap);
                                }
                            }
                        }
                    }
                    //Get Reference fields and resolve id to name 
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    list<SVMXC__Page_Layout_Detail__c> lstFields = [Select SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,  SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c,  SVMXC__IsStandard__c, SVMXC__Field_API_Name__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: str and SVMXC__DataType__c = 'reference'];
                    if(lstFields.size() > 0)
                    {
                        for(SVMXC__Page_Layout_Detail__c pld : lstFields){
                            map<String,String> valuemap = new map<String,String>();
                            if(lstSobject[0].get(pld.SVMXC__Field_API_Name__c) != null){
                                String strVal = String.valueof(lstSobject[0].get(pld.SVMXC__Field_API_Name__c));
                                if(pld.SVMXC__Named_Search__c != null && pld.SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != null && pld.SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != pld.SVMXC__Related_Object_Name_Field__c){
                                    String FldName = pld.SVMXC__Related_Object_Name_Field__c + ','+ pld.SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c;
                                    valuemap = SFMUtils.GetRelationshipData(new set<String>{strVal},pld.SVMXC__Related_Object_Name__c,FldName);
                                }
                                else{
                                    valuemap = SFMUtils.GetRelationshipData(new set<String>{strVal},pld.SVMXC__Related_Object_Name__c,pld.SVMXC__Related_Object_Name_Field__c);
                                }
                                if(valuemap.containskey(strVal)){
                                    SVMXC.SFM_WrapperDef.SFM_StringMap strMap = new SVMXC.SFM_WrapperDef.SFM_StringMap(pld.SVMXC__Field_API_Name__c,valuemap.get(strVal));
                                    mappedValues.add(strMap);
                                }
                                           
                            }     
                        }      
                    } 
                }
                
                //Added by Nidhi as part of BAC-4963
                if(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Module__c !=null){
                    system.debug('Test Nidhi4'+mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Process__r.SVMXC__Purpose__c);
                    system.debug('Test Nidhi5'+mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Type__c);
                    for(SVMXC__ServiceMax_Config_Data__c cd : lstConfigData){
                        if(cd.SVMXC__MapID__c == mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Module__c){
                            if(cd.SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LATITUDE') || cd.SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LONGITUDE') || cd.SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.ACCURACY')){ // Added for BAC-4677
                                    SVMXC.SFM_WrapperDef.SFM_StringMap strMap = new SVMXC.SFM_WrapperDef.SFM_StringMap(cd.SVMXC__Target_Field_Name__c,cd.SVMXC__Display_Value__c);
                                    fieldMappedLiterals.add(strMap);
                            }
                        }
                    }
                }
                //Added by Nidhi as part of BAC-4963 Ends here
                //Convert DateTime fields as per the SFM_AddRecord.cls Implementation.
                if(mapAllObjDateTimeFields.containskey(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Source_Object_Name__c)){
                    lstDateTimeField = mapAllObjDateTimeFields.get(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Source_Object_Name__c);
                }
                else{
                    map<String, Schema.SObjectField> mapFieldDescribe = new map<String, Schema.SObjectField>();
                    mapFieldDescribe = allobjmap.get(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Source_Object_Name__c).getDescribe().fields.getMap();
                    if(mapFieldDescribe.size() > 0){
                        for(String s : mapFieldDescribe.keyset()){
                            Schema.DescribeFieldResult f = mapFieldDescribe.get(s).getDescribe();
                            if(f.isAccessible() && f.isCreateable() && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime){
                                lstDateTimeField.add(f.getName());
                            }
                        }
                        mapAllObjDateTimeFields.put(mapPagelayoutIdProcessNodeObject.get(str).SVMXC__Source_Object_Name__c,lstDateTimeField);
                    }
                }
                system.debug('lstDateTimeField: '+lstDateTimeField);
                if(lstDateTimeField.size() > 0){
                    for(integer j = 0;j<lstDateTimeField.size();j++){
                        if(lstSobject[0].get(lstDateTimeField[j]) != null){
                            String dat = (datetime.valueof(lstSobject[0].get(lstDateTimeField[j]))).format('yyyy-MM-dd HH:mm:ss');
                            lstSobject[0].put(lstDateTimeField[j],Datetime.valueofgmt(dat));
                        }    
                    }
                }
                mapRecordTemplate.put(str,new RecordTemplate(lstSobject[0],mappedValues,mappedLiterals,fieldMappedLiterals));
            }       
        }
        system.debug('mapRecordTemplate'+mapRecordTemplate);
        return mapRecordTemplate;
    }
}