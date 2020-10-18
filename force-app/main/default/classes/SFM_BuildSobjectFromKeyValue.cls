public with sharing class SFM_BuildSobjectFromKeyValue 
{
    
    SVMXC.SFM_buildSobject BuildSobject = new SVMXC.SFM_buildSobject();
    public map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    public map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    public Set<String> setAllFieldsUsedInSobject = new Set<String>(); //Added for the defect fix 042831
    public SFM_buildSobjectFromKeyValue()
    {
        /*gd = Schema.getGlobalDescribe(); #optiChange
        for(Schema.SObjectType s : gd.values())
        {
            allobjmap.put(s.getDescribe().getName(),s);
        }  
        system.debug('allobjmap'+allobjmap);*/
    }
    public Map<String,Sobject> BuildSobjectFromKeyValue(List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringmap,String ObjName,String ParentColumnName,String HdrObjId){
        return BuildSobjectFromGivenKeyValue(stringmap,ObjName,ParentColumnName,HdrObjId,false,null);
    }
    public Map<String,Sobject> BuildSobjectFromGivenKeyValue(List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringmap,String ObjName,String ParentColumnName,String HdrObjId,Boolean doQueryIdOnly, set<String> setFieldSetFields){
        //try{
        //system.debug('amarstringmap'+stringmap.size()+stringmap);
        //system.debug('ObjName'+ObjName);
        map<String,Sobject> SobjectMap = new map<String,Sobject>();  
        Boolean IsIDPresent = false;
        String RecId = '';
        List<Sobject> Sobjlist = new List<Sobject>();
        Map<String,Schema.SObjectField> FieldMap = new Map<String,Schema.SObjectField>();
        Map<String,Schema.SObjectField> LocalFieldMap = new Map<String,Schema.SObjectField>(); 
        //if(ObjName != null && ObjName.length() > 0 && allobjmap.containskey(ObjName)) #optiChange
        if(String.isNotEmpty(ObjName)) //#optiChange
        {
            //FieldMap = allobjmap.get(ObjName).getDescribe().fields.getMap(); #optiChange
            FieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(ObjName); //#optiChange
            if(FieldMap != NULL && !FieldMap.isEmpty()) 
            {
                for(String s : FieldMap.keyset())
                {
                    LocalFieldMap.put(FieldMap.get(s).getDescribe().getname(),FieldMap.get(s));
                }
            }
        }
        if(!stringmap.isEmpty())
        {
            Integer j = stringmap.size();
            for(Integer i=0;i<j;i++)
            {
                if(stringmap[i].key.touppercase() == 'ID'){
                    IsIDPresent = true;
                    RecId = stringmap[i].value;
                    break;
                }   
            }
        }
        Boolean isValid = false;
        if(setFieldSetFields == null){
            isValid = true;                     
        }
        system.debug('IsIDPresent'+IsIDPresent);
        system.debug('RecId'+RecId);
        if(IsIDPresent)//Aready Exsisting Record(Header)(It alwyas to be updated)
        {
            if(String.isNotEmpty(ObjName) && String.isNotEmpty(RecId)) //ParentColumnName == null && HdrObjId == null
            {   
                if(!doQueryIdOnly){
                    Sobjlist = BuildSobject.getSFM_BuildSobject(RecID,ObjName,null,null);
                }
                else{ 
                    Sobjlist = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(RecID,ObjName,null,null,new set<String> {'Id'} ,null);
                }   
                system.debug('Sobjlist'+Sobjlist);
                if(!Sobjlist.isEmpty())
                {
                    Integer sizeOfstringmap = stringmap.size();
                    for(Integer i=0;i<sizeOfstringmap;i++)
                    {
                        String keyfield = stringmap[i].key;
                         // Added check for the defect #048041
                        if(String.isNotEmpty(keyfield) && LocalFieldMap.containskey(keyfield) && keyfield.touppercase() != 'ID' && keyfield.touppercase() != 'LASTVIEWEDDATE' && keyfield.touppercase() !='LASTREFERENCEDDATE'  && (isValid || setFieldSetFields.contains(keyfield))) 
                        {   
                                                    
                            Schema.DescribeFieldResult f = LocalFieldMap.get(keyfield).getDescribe();
                            Schema.DisplayType fieldType = f.getType(); 
                            Boolean isUpdatable = f.isUpdateable();
                            String value = stringmap[i].value;
                            Boolean isValueNotEmpty = String.isNotEmpty(value); 
                            if((fieldType== schema.Displaytype.Date || fieldType == schema.Displaytype.DateTime) && !f.isAccessible())
                            {// Added for BAC-4486/043861/BAC-4648
                                Sobjlist[0].put(keyfield,null);
                            }
                            else if(isUpdatable)
                            {

                                if(fieldType == schema.Displaytype.Double  || fieldType == schema.Displaytype.Percent || fieldType== schema.Displaytype.Currency)//if Field Type is Double,persent,currency 
                                {
                                    if(f.getPrecision() > 0)
                                    {
                                        if(isValueNotEmpty)
                                            Sobjlist[0].put(keyfield,Double.valueof(value));
                                        else
                                            Sobjlist[0].put(keyfield,null);
                                    }
                                    else
                                    {
                                        if(isValueNotEmpty)
                                            Sobjlist[0].put(keyfield,integer.valueof(value));
                                        else
                                            Sobjlist[0].put(keyfield,null);
                                    }       
                                }
                                else if(fieldType == schema.Displaytype.Integer)//if field type is Integer
                                {
                                    if(isValueNotEmpty)
                                        Sobjlist[0].put(keyfield,Integer.valueof(value));
                                    else
                                        Sobjlist[0].put(keyfield,null);
                                }
                                else if(fieldType == schema.Displaytype.Boolean)//if field type is Boolean
                                {
                                    if(isValueNotEmpty)
                                        Sobjlist[0].put(keyfield,Boolean.valueof(value));
                                    else
                                        Sobjlist[0].put(keyfield,null);
                                }
                                else if(fieldType == schema.Displaytype.DateTime)//if field type is DateTime
                                {
                                    if(isValueNotEmpty)
                                    {
                                        String val = value;
                                        val = val.replace('T',' ');
                                        List<String> valList = new List<String>(); 
                                        val = val.replace('.','~');
                                        valList = val.split('~');
                                        if(valList.size() == 0)
                                        {
                                            valList = new List<String>(); 
                                            valList = val.split('\\+');
                                        }
                                        if(valList.size() == 0)
                                        {
                                            valList = new List<String>(); 
                                            valList = val.split('\\-');
                                        }
                                        val = valList[0];
                                        datetime dt;
                                        try
                                        {
                                            dt = DateTime.valueOfgmt(val);
                                        }
                                        catch(Exception ex)
                                        {
                                            dt = Datetime.newInstancegmt(Date.valueOf(val), time.newInstance(0, 0, 0, 0));
                                        }   
                                        Sobjlist[0].put(keyfield,dt);
                                    }   
                                    else
                                        Sobjlist[0].put(keyfield,null);
                                }
                                else if(fieldType == schema.Displaytype.Date)//if field type is Date
                                {
                                    if(isValueNotEmpty)
                                        Sobjlist[0].put(keyfield,Date.valueOf(value));
                                    else
                                        Sobjlist[0].put(keyfield,null);
                                }
                                else if(fieldType == schema.Displaytype.MultiPicklist)//if field type is MultiPicklist
                                {
                                   if(isValueNotEmpty)
                                        Sobjlist[0].put(keyfield,String.valueof(value));
                                    else
                                        Sobjlist[0].put(keyfield,null);
                                }
                                else if(fieldType == schema.Displaytype.Picklist)//if field type is Picklist
                                {
                                    if(isValueNotEmpty)
                                        Sobjlist[0].put(keyfield,String.valueof(value));
                                    else
                                        Sobjlist[0].put(keyfield,null);
                                }
                                else //else field type is REFERENCE,String 
                                {
                                    
                                        system.debug('BLABLA: '+keyfield+' '+value);
                                        if(isValueNotEmpty)
                                            Sobjlist[0].put(keyfield,(String)value);
                                        else
                                            Sobjlist[0].put(keyfield,value);   
                                    
                                }
                            } 
                        }
                    }
                }           
                SobjectMap.put('UPDATE',Sobjlist[0]);
            }   
        }    
        else//Its new Reocrds(Needs to inserted)
        {
            system.debug('New Record');
            if(String.isNotEmpty(ObjName) && String.isEmpty(RecId))
                Sobjlist =  BuildSobject.getSFM_BuildSobject(null,ObjName,null,null);
            system.debug('Sobjlist'+Sobjlist);
            if(!Sobjlist.isEmpty())//&& ParentColumnName == null && HdrObjId == null
            {
                set<String> FieldApiName = new set<String>(); 
                Integer sizeofstringmap = stringmap.size();
                for(Integer i=0;i<sizeofstringmap;i++)
                {
                    String keyfield = stringmap[i].key;
                    if(String.isNotEmpty(keyfield) && LocalFieldMap.containskey(keyfield) && (isValid || setFieldSetFields.contains(keyfield)))
                    {
                        String fieldValue = stringmap[i].value;
                        //Desctibe the field to check differen attributes of fields..
                        Schema.DescribeFieldResult f = LocalFieldMap.get(keyfield).getDescribe();
                        Schema.DisplayType fieldType = f.getType(); 
                        Boolean isCreatable = f.isCreateable();
                        Boolean isValueNotEmpty = String.isNotEmpty(fieldValue);
                        if(String.isNotEmpty(ParentColumnName) && String.isNotEmpty(HdrObjId) && keyfield == ParentColumnName)
                        {
                            Sobjlist[0].put(keyfield,HdrObjId);
                        }
                        else
                        {
                            if(isCreatable)
                            {
                                FieldApiName.add(keyfield);
                                if(fieldType == schema.Displaytype.Double  || fieldType == schema.Displaytype.Percent || fieldType== schema.Displaytype.Currency)//if Field Type is Double,persent,currency 
                                {
                                    if(isValueNotEmpty)
                                        Sobjlist[0].put(keyfield,(double.valueOf(fieldValue)));
                                    //else
                                        //Sobjlist[0].put(stringmap[i].key,null);
                                }
                                else if(fieldType == schema.Displaytype.Integer)//if field type is Integer
                                {
                                    if(isValueNotEmpty)
                                        Sobjlist[0].put(keyfield,Integer.valueof(fieldValue));
                                    //else
                                       // Sobjlist[0].put(stringmap[i].key,Null);
                                }
                                else if(fieldType == schema.Displaytype.Boolean)//if field type is Boolean
                                {
                                    if(isValueNotEmpty)
                                        Sobjlist[0].put(keyfield,Boolean.valueof(fieldValue));
                                    //else
                                        //Sobjlist[0].put(stringmap[i].key,stringmap[i].value);
                                }
                                else if(fieldType == schema.Displaytype.DateTime)//if field type is DateTime
                                {
                                    system.debug('Log: '+keyfield+'-'+ fieldValue);
                                    if(isValueNotEmpty)
                                    {
                                        String val = fieldValue;
                                        val = val.replace('T',' ');
                                        List<String> valList = new List<String>(); 
                                        val = val.replace('.','~');
                                        valList = val.split('~');
                                        if(valList.size() == 0)
                                        {
                                            valList = new List<String>(); 
                                            valList = val.split('\\+');
                                        }
                                        if(valList.size() == 0)
                                        {
                                            valList = new List<String>(); 
                                            valList = val.split('\\-');
                                        }
                                        val = valList[0];
                                        datetime dt;
                                        try
                                        {
                                            dt = DateTime.valueOfgmt(val);
                                        }
                                        catch(Exception ex)
                                        {
                                            dt = Datetime.newInstancegmt(Date.valueOf(val), time.newInstance(0, 0, 0, 0));
                                        }   
                                        Sobjlist[0].put(keyfield,dt);
                                    }   
                                    //else
                                        //Sobjlist[0].put(stringmap[i].key,null);
                                }
                                else if(fieldType == schema.Displaytype.Date)//if field type is Date
                                {
                                    if(isValueNotEmpty)
                                        Sobjlist[0].put(keyfield,Date.valueOf(fieldValue));
                                    //else
                                        //Sobjlist[0].put(stringmap[i].key,null);
                                }
                                else if(fieldType== schema.Displaytype.MultiPicklist)//if field type is MultiPicklist
                                {
                                    if(isValueNotEmpty)
                                        Sobjlist[0].put(keyfield,String.valueof(fieldValue));
                                    //else
                                    //  Sobjlist[0].put(stringmap[i].key,null);
                                }
                                else if(fieldType == schema.Displaytype.Picklist)//if field type is Picklist
                                {
                                    if(isValueNotEmpty)
                                        Sobjlist[0].put(keyfield,String.valueof(fieldValue));
                                    //else
                                        //Sobjlist[0].put(stringmap[i].key,null);
                                }
                                else //else field type is REFERENCE,String 
                                {
                                      system.debug('BLABLA: '+keyfield+' '+fieldValue);
                                        if(isValueNotEmpty)
                                            Sobjlist[0].put(keyfield,(String)fieldValue);
                                       // else
                                        //  Sobjlist[0].put(stringmap[i].key,null);
                                    
                                }
                            }
                        }    
                    }   
                }
                if(String.isNotEmpty(ParentColumnName) && FieldApiName.contains(ParentColumnName) == false && String.isNotEmpty(HdrObjId))
                {
                    Sobjlist[0].put(ParentColumnName,HdrObjId);
                }
                SobjectMap.put('INSERT',Sobjlist[0]);
            }
        }
        system.debug('SobjectMap'+SobjectMap);
        return SobjectMap;
    }

    //This method is added for parsing Sobject which is send as part save call of SFM delivery for code optimization.
    public Map<String,Sobject> BuildSobjectFromGivenSobjectForHeader(Map<String, Object> recordFieldValuesAsMap,String ObjName, set<String> setFieldSetFields){
        Map<String,Sobject> SobjectMap = new Map<String,Sobject>();  
        Boolean IsIDPresent = false;
        String RecId = '';
        List<Sobject> Sobjlist = new List<Sobject>();
        Map<String,Schema.SObjectField> FieldMap = new Map<String,Schema.SObjectField>();
        Map<String,Schema.SObjectField> LocalFieldMap = new Map<String,Schema.SObjectField>(); 
        //if(ObjName != null && ObjName.length() > 0 && allobjmap.containskey(ObjName)){ #optiChange
        if(String.isNotEmpty(ObjName)){ // #optiChange
            //FieldMap = allobjmap.get(ObjName).getDescribe().fields.getMap(); // #optiChange
            FieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(ObjName); //#optiChange
            if(FieldMap != NULL && FieldMap.size() > 0){
                for(String s : FieldMap.keyset()){
                    LocalFieldMap.put(FieldMap.get(s).getDescribe().getname(),FieldMap.get(s));
                }
            }
        }
        if(recordFieldValuesAsMap != null && recordFieldValuesAsMap.size() > 0 && recordFieldValuesAsMap.containsKey('Id')){
            IsIDPresent = true;
            RecId = String.valueOf(recordFieldValuesAsMap.get('Id'));
        }
        Boolean isValid = false;
        if(setFieldSetFields == null){
          isValid = true;                
        }
        System.debug('IsIDPresent: '+IsIDPresent);
        System.debug('RecId: '+RecId);
        //Aready Exsisting Record -Header
        if(IsIDPresent){
            if(ObjName != null && ObjName.length() > 0 && RecId != null && RecId.length() > 0){   
                Sobjlist = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(RecId, ObjName, null, null, new set<String> {'Id'} , null);  
                System.debug('Sobjlist: '+Sobjlist);

                if(Sobjlist != null && Sobjlist.size() > 0){
                    for(String keyField: recordFieldValuesAsMap.keySet()){
                      //Added check for the #defect 048041
                        if(LocalFieldMap.containskey(keyField) && keyField.touppercase() != 'ID' && keyField.touppercase() != 'LASTVIEWEDDATE' && keyField.touppercase() != 'LASTREFERENCEDDATE' && (isValid || setFieldSetFields.contains(keyField))){
                            Schema.DescribeFieldResult f = LocalFieldMap.get(keyField).getDescribe();

                            if(f.isUpdateable()){
                                if(recordFieldValuesAsMap.get(keyField) != null && String.valueOf(recordFieldValuesAsMap.get(keyField)).length() > 0){
                                    //if Field Type is Double,persent,currency
                                    if(f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency){
                                        if(f.getPrecision() > 0){
                                            Sobjlist[0].put(keyField, Double.valueof(recordFieldValuesAsMap.get(keyField)));
                                        }
                                        else{
                                            Sobjlist[0].put(keyField, Integer.valueof(recordFieldValuesAsMap.get(keyField)));
                                        }       
                                    }
                                    //if field type is Integer
                                    else if(f.getType() == schema.Displaytype.Integer){
                                        Sobjlist[0].put(keyField, Integer.valueof(recordFieldValuesAsMap.get(keyField)));
                                    }
                                    //if field type is Boolean
                                    else if(f.getType() == schema.Displaytype.Boolean){
                                        Sobjlist[0].put(keyField, Boolean.valueof(recordFieldValuesAsMap.get(keyField)));
                                    }
                                    //if field type is DateTime
                                    else if(f.getType() == schema.Displaytype.DateTime){
                                        String val = String.valueOf(recordFieldValuesAsMap.get(keyField));
                                        val = val.replace('T',' ');
                                        List<String> valList = new List<String>(); 
                                        val = val.replace('.','~');
                                        valList = val.split('~');
                                        if(valList.size() == 0)
                                        {
                                            valList = new List<String>(); 
                                            valList = val.split('\\+');
                                        }
                                        if(valList.size() == 0)
                                        {
                                            valList = new List<String>(); 
                                            valList = val.split('\\-');
                                        }
                                        val = valList[0];
                                        datetime dt;
                                        try
                                        {
                                            dt = DateTime.valueOfgmt(val);
                                        }
                                        catch(Exception ex)
                                        {
                                            dt = Datetime.newInstancegmt(Date.valueOf(val), time.newInstance(0, 0, 0, 0));
                                        }   
                                        Sobjlist[0].put(keyField, dt);
                                    }
                                    //if field type is Date
                                    else if(f.getType() == schema.Displaytype.Date){
                                        Sobjlist[0].put(keyField, Date.valueOf(recordFieldValuesAsMap.get(keyField)));
                                    }
                                    //if field type is MultiPicklist OR Picklist
                                    else if(f.getType() == schema.Displaytype.MultiPicklist || f.getType() == schema.Displaytype.Picklist){
                                        Sobjlist[0].put(keyField, String.valueof(recordFieldValuesAsMap.get(keyField)));
                                    }
                                    //field type is REFERENCE, String 
                                    else{
                                        Sobjlist[0].put(keyField, (String)recordFieldValuesAsMap.get(keyField));
                                    }
                                }
                                else{
                                    Sobjlist[0].put(keyField, null);
                                }
                            }
                        }
                    }
                }           
                SobjectMap.put('UPDATE',Sobjlist[0]);
            }
        }
        //It is new Record
        else{
            if(ObjName != null && ObjName.length() > 0 && (RecId == null || RecId.length() == 0))
                Sobjlist =  BuildSobject.getSFM_BuildSobject(null,ObjName,null,null);
            System.debug('Sobjlist: '+Sobjlist);

            if(Sobjlist != null && Sobjlist.size() > 0){
                for(String keyField: recordFieldValuesAsMap.keySet()){
                    if(LocalFieldMap.containskey(keyField) && (isValid || setFieldSetFields.contains(keyField))){   
                        //Desctibe the field to check differen attributes of fields..
                        Schema.DescribeFieldResult f = LocalFieldMap.get(keyField).getDescribe();

                        if(f.isCreateable()){
                            if(recordFieldValuesAsMap.get(keyField) != null && String.valueOf(recordFieldValuesAsMap.get(keyField)).length() > 0){
                                //if Field Type is Double,persent,currency
                                if(f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency){
                                    Sobjlist[0].put(keyField, (Double.valueOf(recordFieldValuesAsMap.get(keyField))));
                                }
                                //if field type is Integer
                                else if(f.getType() == schema.Displaytype.Integer){
                                    Sobjlist[0].put(keyField, Integer.valueof(recordFieldValuesAsMap.get(keyField)));
                                }
                                //if field type is Boolean
                                else if(f.getType() == schema.Displaytype.Boolean){
                                    Sobjlist[0].put(keyField, Boolean.valueof(recordFieldValuesAsMap.get(keyField)));
                                }
                                //if field type is DateTime
                                else if(f.getType() == schema.Displaytype.DateTime){
                                    String val = String.valueOf(recordFieldValuesAsMap.get(keyField));
                                    val = val.replace('T',' ');
                                    List<String> valList = new List<String>(); 
                                    val = val.replace('.','~');
                                    valList = val.split('~');
                                    if(valList.size() == 0)
                                    {
                                        valList = new List<String>(); 
                                        valList = val.split('\\+');
                                    }
                                    if(valList.size() == 0)
                                    {
                                        valList = new List<String>(); 
                                        valList = val.split('\\-');
                                    }
                                    val = valList[0];
                                    datetime dt;
                                    try
                                    {
                                        dt = DateTime.valueOfgmt(val);
                                    }
                                    catch(Exception ex)
                                    {
                                        dt = Datetime.newInstancegmt(Date.valueOf(val), time.newInstance(0, 0, 0, 0));
                                    }   
                                    Sobjlist[0].put(keyField, dt);
                                }
                                //if field type is Date
                                else if(f.getType() == schema.Displaytype.Date){
                                    Sobjlist[0].put(keyField, Date.valueOf(recordFieldValuesAsMap.get(keyField)));
                                }
                                //if field type is MultiPicklist OR Picklist
                                else if(f.getType() == schema.Displaytype.MultiPicklist || f.getType() == schema.Displaytype.Picklist){
                                    Sobjlist[0].put(keyField, String.valueof(recordFieldValuesAsMap.get(keyField)));
                                }
                                //field type is REFERENCE, String 
                                else{
                                    Sobjlist[0].put(keyField, (String)recordFieldValuesAsMap.get(keyField));
                                }
                            }
                        } 
                    }   
                }
                SobjectMap.put('INSERT',Sobjlist[0]);
            }
        }
        System.debug('SobjectMap: '+SobjectMap);
        return SobjectMap;
    }

    public Map<String,List<Sobject>> BuildSobjectFromKeyValue2(List<SVMXC.SFM_WrapperDef.SFM_Record> SFMRecordList,String ObjName,String ParentColumnName,String HdrObjId,map<String,map<String,Schema.SObjectField>> AllFieldDescribe){
        return BuildSobjectFromGivenKeyValue2(SFMRecordList,ObjName,ParentColumnName,HdrObjId,AllFieldDescribe,false,null);
    }
    public Map<String,List<Sobject>> BuildSobjectFromGivenKeyValue2(List<SVMXC.SFM_WrapperDef.SFM_Record> SFMRecordList,String ObjName,String ParentColumnName,String HdrObjId,map<String,map<String,Schema.SObjectField>> AllFieldDescribe,Boolean doQueryIdOnly, set<String> setFieldSetFields){
        system.debug('SFMRecordList'+SFMRecordList.size()+SFMRecordList);
        system.debug('ObjName'+ObjName);
        map<String,list<Sobject>> SobjectMap = new map<String,list<Sobject>>();  
        Set<String> RecIds = new Set<String>();
        map<String,list<SVMXC.SFM_WrapperDef.SFM_StringMap>> ExsistingRecords = new map<String,list<SVMXC.SFM_WrapperDef.SFM_StringMap>>();
        map<Integer,list<SVMXC.SFM_WrapperDef.SFM_StringMap>> NewRecords = new map<Integer,list<SVMXC.SFM_WrapperDef.SFM_StringMap>>();
        map<Integer,String> SourceRecID = new map<Integer,String>();
        Map<String,Schema.SObjectField> LocalFieldMap = new Map<String,Schema.SObjectField>(); 
        Boolean isValid = false;
        if(setFieldSetFields == null){
            isValid = true;                     
        }
        if(AllFieldDescribe.containskey(ObjName))
            LocalFieldMap = AllFieldDescribe.get(ObjName);
        if(SFMRecordList.size() > 0)
        {
            Integer j = 0;
            list<Sobject> lstSobjectForUpdate = new list<Sobject>();
            list<Sobject> lstSobjectForInsert = new list<Sobject>();
            for(Integer i = 0;i<SFMRecordList.size();i++)
            {
                if(SFMRecordList[i].targetRecordAsKeyValue != null && SFMRecordList[i].targetRecordAsKeyValue.size() > 0 && SFMRecordList[i].sobjectinfo == null)
                {
                    if(SFMRecordList[i].targetRecordId != null && SFMRecordList[i].targetRecordId.length() > 0)
                    {
                        RecIds.add(SFMRecordList[i].targetRecordId);
                        ExsistingRecords.put(SFMRecordList[i].targetRecordId,SFMRecordList[i].targetRecordAsKeyValue);
                    }
                    else
                    {
                        NewRecords.put(j,SFMRecordList[i].targetRecordAsKeyValue);
                        if(SFMRecordList[i].sourceRecordId != null && SFMRecordList[i].sourceRecordId.length() > 0)
                            SourceRecID.put(j,SFMRecordList[i].sourceRecordId);
                        j = j+1;
                        
                    }
                }
                else if(SFMRecordList[i].sobjectinfo != null && (SFMRecordList[i].targetRecordAsKeyValue == null || (SFMRecordList[i].targetRecordAsKeyValue != null && SFMRecordList[i].targetRecordAsKeyValue.size() == 0)))
                {
                    // If Target records is present the it's edit mode so alwyas update
                    if(SFMRecordList[i].targetRecordId != null && SFMRecordList[i].targetRecordId.length() > 0)
                    {
                        lstSobjectForUpdate.add(SFMRecordList[i].sobjectinfo);
                    }
                    // If Target Recoed Id is not present then it's new record so aloways insert this record
                    else 
                    {
                        SFMRecordList[i].sobjectinfo.put(ParentColumnName,HdrObjId);
                        list<Sobject> lstSobject = new list<Sobject>();
                        lstSobjectForInsert.add(SFMRecordList[i].sobjectinfo);
                        lstSobject.add(SFMRecordList[i].sobjectinfo);
                        // If Source Record id is present then there is source update required so create map<sourceRecordId,TargetRecord> for source update.
                        if(SFMRecordList[i].sourceRecordId != null && SFMRecordList[i].sourceRecordId.length() > 0)
                        {
                            SobjectMap.put(SFMRecordList[i].sourceRecordId,lstSobject);
                        }
                    }
                }   
            }
            if(lstSobjectForInsert.size() > 0)
                SobjectMap.put('INSERT',lstSobjectForInsert); 
            if(lstSobjectForUpdate.size() > 0)
                SobjectMap.put('UPDATE',lstSobjectForUpdate);
        }
        system.debug('SobjectMap'+SobjectMap);
        system.debug('RecIds'+RecIds);
        system.debug('ExsistingRecords'+ExsistingRecords.size()+ExsistingRecords);
        system.debug('NewRecords'+NewRecords.size()+NewRecords);
        system.debug('SourceRecID'+SourceRecID.size()+SourceRecID);
        //Process Exsisting Records first
        if(ExsistingRecords.size() > 0)
        {
            List<Sobject> Sobjlist = new List<Sobject>();
            if(!doQueryIdOnly){
                Sobjlist = BuildSobject.getSFM_BuildSobject2(RecIds,ObjName,null,AllFieldDescribe);
            }
            else {
                Sobjlist = BuildSobject.getSFM_BuildSobjectsFromInputField(RecIds,ObjName,null,AllFieldDescribe,new set<String>{'Id'});
            }   
            if(Sobjlist.size() > 0)
            {
                for(Integer j = 0;j< Sobjlist.size();j++)
                {
                    String RecId = String.valueof(Sobjlist[j].get('Id'));
                    List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringmap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                    if(ExsistingRecords.containskey(RecId))
                        stringmap = ExsistingRecords.get(RecId);
                    if(stringmap.size() > 0)
                    {
                        for(Integer i=0;i<stringmap.size();i++)
                        {
                             // added check for the defect #048041
                            if(stringmap[i].key != null && stringmap[i].key.length() > 0 && LocalFieldMap.containskey(stringmap[i].key) && stringmap[i].key.touppercase() != 'ID' && stringmap[i].key.touppercase() != 'LASTVIEWEDDATE' && stringmap[i].key.touppercase() != 'LASTREFERENCEDDATE' && (isValid || setFieldSetFields.contains(stringmap[i].key))) 
                            {
                                Schema.DescribeFieldResult f = LocalFieldMap.get(stringmap[i].key).getDescribe();
                                if((f.getType() == schema.Displaytype.Date || f.getType() == schema.Displaytype.DateTime) && !f.isAccessible()){// Added for BAC-4486/043861/BAC-4648
                                    Sobjlist[j].put(stringmap[i].key,null);
                                }else if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isUpdateable())//if Field Type is Double,persent,currency 
                                {
                                    if(f.getPrecision() > 0)
                                    {
                                        if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                            Sobjlist[j].put(stringmap[i].key,Double.valueof(stringmap[i].value));
                                        else
                                            Sobjlist[j].put(stringmap[i].key,Null);
                                    }
                                    else
                                    {
                                        if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                            Sobjlist[j].put(stringmap[i].key,integer.valueof(stringmap[i].value));
                                        else
                                            Sobjlist[j].put(stringmap[i].key,Null);
                                    }       
                                }
                                else if(f.getType() == schema.Displaytype.Integer && f.isUpdateable())//if field type is Integer
                                {
                                    if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                        Sobjlist[j].put(stringmap[i].key,Integer.valueof(stringmap[i].value));
                                    else
                                        Sobjlist[j].put(stringmap[i].key,Null);
                                }
                                else if(f.getType() == schema.Displaytype.Boolean && f.isUpdateable())//if field type is Boolean
                                {
                                    if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                        Sobjlist[j].put(stringmap[i].key,Boolean.valueof(stringmap[i].value));
                                    else
                                        Sobjlist[j].put(stringmap[i].key,Null);
                                }
                                else if(f.getType() == schema.Displaytype.DateTime && f.isUpdateable())//if field type is DateTime
                                {
                                    if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    {
                                        String val = stringmap[i].value;
                                        val = val.replace('T',' ');
                                        List<String> valList = new List<String>(); 
                                        val = val.replace('.','~');
                                        valList = val.split('~');
                                        if(valList.size() == 0)
                                        {
                                            valList = new List<String>(); 
                                            valList = val.split('\\+');
                                        }
                                        if(valList.size() == 0)
                                        {
                                            valList = new List<String>(); 
                                            valList = val.split('\\-');
                                        }
                                        val = valList[0];
                                        datetime dt;
                                        try
                                        {
                                            dt = DateTime.valueOfgmt(val);
                                        }
                                        catch(Exception ex)
                                        {
                                            dt = Datetime.newInstancegmt(Date.valueOf(val), time.newInstance(0, 0, 0, 0));
                                        }   
                                        Sobjlist[j].put(stringmap[i].key,dt);
                                    }   
                                    else
                                        Sobjlist[j].put(stringmap[i].key,Null);
                                }
                                else if(f.getType() == schema.Displaytype.Date && f.isUpdateable())//if field type is Date
                                {
                                    if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                        Sobjlist[j].put(stringmap[i].key,Date.valueOf(stringmap[i].value));
                                    else
                                        Sobjlist[j].put(stringmap[i].key,Null);
                                }
                                else if(f.getType() == schema.Displaytype.MultiPicklist && f.isUpdateable())//if field type is MultiPicklist
                                {
                                   if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                        Sobjlist[j].put(stringmap[i].key,String.valueof(stringmap[i].value));
                                    else
                                        Sobjlist[j].put(stringmap[i].key,Null);
                                }
                                else if(f.getType() == schema.Displaytype.Picklist && f.isUpdateable())//if field type is Picklist
                                {
                                    if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                        Sobjlist[j].put(stringmap[i].key,String.valueof(stringmap[i].value));
                                    else
                                        Sobjlist[j].put(stringmap[i].key,Null);
                                }
                                else //else field type is REFERENCE,String 
                                {
                                    if(f.isUpdateable())
                                    {
                                        if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                            Sobjlist[j].put(stringmap[i].key,(String)stringmap[i].value);
                                        else
                                            Sobjlist[j].put(stringmap[i].key,stringmap[i].value);   
                                    }
                                }
                            }
                        }
                    }
                }
                SobjectMap.put('UPDATE',Sobjlist);
            }
        } 
        if(NewRecords.size() > 0)
        {
            List<Sobject> Sobjlist = new List<Sobject>();
            Sobjlist =  BuildSobject.getSFM_BuildSobject2(null,ObjName,NewRecords.size(),AllFieldDescribe);
            system.debug('Sobjlist'+Sobjlist.size()+Sobjlist);
            if(Sobjlist.size() > 0)
            {
                for(Integer j = 0; j<Sobjlist.size();j++)
                {
                    List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringmap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                    if(NewRecords.containskey(j))
                        stringmap = NewRecords.get(j);
                    if(stringmap.size() > 0)
                    {
                        set<String> FieldApiName = new set<String>(); 
                        for(Integer i=0;i<stringmap.size();i++)
                        {
                            system.debug('key '+stringmap[i].key );
                            system.debug('value '+stringmap[i].value );
                            if(stringmap[i].key != null && stringmap[i].key.length() > 0  && LocalFieldMap.containskey(stringmap[i].key) && (isValid || setFieldSetFields.contains(stringmap[i].key)))
                            {
                                //Desctibe the field to check differen attributes of fields..
                                Schema.DescribeFieldResult f = LocalFieldMap.get(stringmap[i].key).getDescribe();
                                if(ParentColumnName != null && ParentColumnName.length() > 0 && HdrObjId != null && HdrObjId.length() > 0 && stringmap[i].key == ParentColumnName)
                                {
                                    Sobjlist[j].put(stringmap[i].key,HdrObjId);
                                }
                                else
                                {
                                    FieldApiName.add(stringmap[i].key);
                                    if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                                    {
                                        if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                            Sobjlist[j].put(stringmap[i].key,(double.valueOf(stringmap[i].value)));
                                        //else
                                            //Sobjlist[j].put(stringmap[i].key,null);
                                    }
                                    else if(f.getType() == schema.Displaytype.Integer && f.isCreateable())//if field type is Integer
                                    {
                                        if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                            Sobjlist[j].put(stringmap[i].key,Integer.valueof(stringmap[i].value));
                                        //else
                                            //Sobjlist[j].put(stringmap[i].key,stringmap[i].value);
                                    }
                                    else if(f.getType() == schema.Displaytype.Boolean && f.isCreateable())//if field type is Boolean
                                    {
                                        if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                            Sobjlist[j].put(stringmap[i].key,Boolean.valueof(stringmap[i].value));
                                        //else
                                            //Sobjlist[j].put(stringmap[i].key,stringmap[i].value);
                                    }
                                    else if(f.getType() == schema.Displaytype.DateTime && f.isCreateable())//if field type is DateTime
                                    {
                                        if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                        {
                                            String val = stringmap[i].value;
                                            val = val.replace('T',' ');
                                            List<String> valList = new List<String>(); 
                                            val = val.replace('.','~');
                                            valList = val.split('~');
                                            if(valList.size() == 0)
                                            {
                                                valList = new List<String>(); 
                                                valList = val.split('\\+');
                                            }
                                            if(valList.size() == 0)
                                            {
                                                valList = new List<String>(); 
                                                valList = val.split('\\-');
                                            }
                                            val = valList[0];
                                            datetime dt;
                                            try
                                            {
                                                dt = DateTime.valueOfgmt(val);
                                            }
                                            catch(Exception ex)
                                            {
                                                dt = Datetime.newInstancegmt(Date.valueOf(val), time.newInstance(0, 0, 0, 0));
                                            }   
                                            Sobjlist[j].put(stringmap[i].key,dt); 
                                        }   
                                        //else
                                            //Sobjlist[j].put(stringmap[i].key,null);
                                    }
                                    else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                                    {
                                        if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                            Sobjlist[j].put(stringmap[i].key,Date.valueOf(stringmap[i].value));
                                        //else
                                            //Sobjlist[j].put(stringmap[i].key,null);
                                    }
                                    else if(f.getType() == schema.Displaytype.MultiPicklist && f.isCreateable())//if field type is MultiPicklist
                                    {
                                        if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                            Sobjlist[j].put(stringmap[i].key,String.valueof(stringmap[i].value));
                                        //else
                                        //  Sobjlist[j].put(stringmap[i].key,null);
                                    }
                                    else if(f.getType() == schema.Displaytype.Picklist && f.isUpdateable())//if field type is Picklist
                                    {
                                        if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                            Sobjlist[j].put(stringmap[i].key,String.valueof(stringmap[i].value));
                                        //else
                                            //Sobjlist[j].put(stringmap[i].key,null);
                                    }
                                    else //else field type is REFERENCE,String 
                                    {
                                        if(f.isCreateable())//
                                        {
                                            if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                                Sobjlist[j].put(stringmap[i].key,(String)stringmap[i].value);
                                           // else
                                            //  Sobjlist[j].put(stringmap[i].key,null);
                                        }
                                    }
                                }    
                            }   
                        }
                        if(ParentColumnName != null && ParentColumnName.length() > 0 && FieldApiName.contains(ParentColumnName) == false && HdrObjId != null && HdrObjId.length() > 0)
                        {
                            Sobjlist[j].put(ParentColumnName,HdrObjId);
                        }
                    }
                    if(SourceRecID.containskey(j))
                    {
                        list<Sobject> temp = new list<Sobject>();
                        temp.add(Sobjlist[j]);
                        SobjectMap.put(SourceRecID.get(j),temp);
                    }   
                }
                SobjectMap.put('INSERT',Sobjlist); 
            }
        }
        system.debug('SobjectMap'+SobjectMap);
        return SobjectMap;
    }

    //This method is added for parsing list of Sobject which is send as part save call of SFM delivery for code optimization.
    public Map<String,List<Sobject>> BuildSobjectFromGivenSobjectForDetail(List<SVMXC.SFM_WrapperDef.SFM_Record> SFMRecordList,String objName,String parentColumnName,String hdrObjId,map<String,map<String,Schema.SObjectField>> AllFieldDescribe){
        System.debug('SFMRecordList-records:'+SFMRecordList);
        System.debug('objName: '+objName);
        System.debug('parentColumnName: '+parentColumnName);
        System.debug('hdrObjId: '+hdrObjId);

        Map<String, List<Sobject>> sObjectMap = new Map<String, List<Sobject>>();  
        Set<String> existingRecIds = new Set<String>();
        Map<String, Sobject> existingRecordMap = new Map<String, Sobject>();
        Map<Integer, Sobject> newRecordMap = new Map<Integer, Sobject>();
        Map<Integer,String> sourceRecID = new Map<Integer,String>();
        Map<String,Schema.SObjectField> localFieldMap = new Map<String,Schema.SObjectField>();
        setAllFieldsUsedInSobject.clear(); //Added for the defect fix 042831
        
        if(AllFieldDescribe.containskey(objName))
            localFieldMap = AllFieldDescribe.get(objName);
        
        if(SFMRecordList != null && SFMRecordList.size() > 0){
            Integer j = 0;
            list<Sobject> lstSobjectForUpdate = new list<Sobject>();
            list<Sobject> lstSobjectForInsert = new list<Sobject>();
            Integer intSizeOfRecList = SFMRecordList.size();
            for(Integer i = 0; i < intSizeOfRecList; i++){   
                System.debug('Records List: ' + SFMRecordList[i]);
                if(SFMRecordList[i].sObjectRecord != null && SFMRecordList[i].sobjectinfo == null){
                    if(SFMRecordList[i].targetRecordId != null && SFMRecordList[i].targetRecordId.length() > 0){
                        existingRecIds.add(SFMRecordList[i].targetRecordId);
                        existingRecordMap.put(SFMRecordList[i].targetRecordId,SFMRecordList[i].sObjectRecord);
                    }
                    else{
                        newRecordMap.put(j,SFMRecordList[i].sObjectRecord);
                        if(SFMRecordList[i].sourceRecordId != null && SFMRecordList[i].sourceRecordId.length() > 0)
                            sourceRecID.put(j,SFMRecordList[i].sourceRecordId);
                        j = j+1;
                    }
                }
                else if(SFMRecordList[i].sobjectinfo != null && SFMRecordList[i].sObjectRecord == null){
                    //If Target records is present the it's edit mode so alwyas update
                    if(SFMRecordList[i].targetRecordId != null && SFMRecordList[i].targetRecordId.length() > 0){
                        lstSobjectForUpdate.add(SFMRecordList[i].sobjectinfo);
                    }
                    // If Target Recoed Id is not present then it's new record so aloways insert this record
                    else{
                        SFMRecordList[i].sobjectinfo.put(parentColumnName,hdrObjId);
                        list<Sobject> lstSobject = new list<Sobject>();
                        lstSobjectForInsert.add(SFMRecordList[i].sobjectinfo);
                        lstSobject.add(SFMRecordList[i].sobjectinfo);
                        // If Source Record id is present then there is source update required so create map<sourceRecordId,TargetRecord> for source update.
                        if(SFMRecordList[i].sourceRecordId != null && SFMRecordList[i].sourceRecordId.length() > 0){
                            SobjectMap.put(SFMRecordList[i].sourceRecordId,lstSobject);
                        }
                    }
                }   
            }
            if(lstSobjectForInsert.size() > 0)
                sObjectMap.put('INSERT',lstSobjectForInsert); 
            if(lstSobjectForUpdate.size() > 0)
                sObjectMap.put('UPDATE',lstSobjectForUpdate);
        }
        System.debug('existingRecIds: '+existingRecIds);
        System.debug('existingRecordMap: '+existingRecordMap.size()+existingRecordMap);
        System.debug('newRecordMap: '+newRecordMap.size()+newRecordMap);
        System.debug('sourceRecID: '+sourceRecID.size()+sourceRecID);
        
        //Process Exsisting Records first
        if(existingRecordMap.size() > 0){
            List<Sobject> Sobjlist = new List<Sobject>();
            Sobjlist = BuildSobject.getSFM_BuildSobjectsFromInputField(existingRecIds,objName,null,AllFieldDescribe,new set<String>{'Id'});
            if(Sobjlist != null && Sobjlist.size() > 0){
                Integer intSizeOfRecList = Sobjlist.size();
                for(Integer j = 0; j < intSizeOfRecList; j++){
                    String RecId = String.valueof(Sobjlist[j].get('Id'));
                    //Sobject record = new Sobject();
                    Sobject record;
                    if(existingRecordMap.containskey(RecId)){
                        record = existingRecordMap.get(RecId);
                    }
                    Map<String, Object> recordFieldValuesAsMap = record.getPopulatedFieldsAsMap();

                    if(recordFieldValuesAsMap.size() > 0){
                        for(String keyField: recordFieldValuesAsMap.keySet()){
                            // Added check for the defect #048041
                            if(localFieldMap.containskey(keyField) && keyField.touppercase() != 'ID' && keyField.touppercase() != 'LASTVIEWEDDATE' && keyField.touppercase() != 'LASTREFERENCEDDATE'){
                                setAllFieldsUsedInSobject.add(keyField); //Added for the defect fix 042831
                                Schema.DescribeFieldResult f = localFieldMap.get(keyField).getDescribe();
                                if(f.isUpdateable()){
                                    if(recordFieldValuesAsMap.get(keyField) != null && String.valueOf(recordFieldValuesAsMap.get(keyField)).length() > 0){
                                        //if Field Type is Double,persent,currency 
                                        if(f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency){
                                            if(f.getPrecision() > 0){
                                                Sobjlist[j].put(keyField,Double.valueOf(recordFieldValuesAsMap.get(keyField)));
                                            }
                                            else{
                                                Sobjlist[j].put(keyField,Integer.valueOf(recordFieldValuesAsMap.get(keyField)));
                                            }
                                        }
                                        //if field type is Integer
                                        else if(f.getType() == schema.Displaytype.Integer){
                                            Sobjlist[j].put(keyField, Integer.valueOf(recordFieldValuesAsMap.get(keyField)));
                                        }
                                        //if field type is Boolean
                                        else if(f.getType() == schema.Displaytype.Boolean){
                                            Sobjlist[j].put(keyField, Boolean.valueof(recordFieldValuesAsMap.get(keyField)));
                                        }
                                        //if field type is DateTime
                                        else if(f.getType() == schema.Displaytype.DateTime){
                                            String val = String.valueOf(recordFieldValuesAsMap.get(keyField));
                                            val = val.replace('T',' ');
                                            List<String> valList = new List<String>(); 
                                            val = val.replace('.','~');
                                            valList = val.split('~');
                                            if(valList.size() == 0){
                                                valList = new List<String>(); 
                                                valList = val.split('\\+');
                                            }
                                            if(valList.size() == 0){
                                                valList = new List<String>(); 
                                                valList = val.split('\\-');
                                            }
                                            val = valList[0];
                                            datetime dt;
                                            try{
                                                dt = DateTime.valueOfgmt(val);
                                            }
                                            catch(Exception ex){
                                                dt = Datetime.newInstancegmt(Date.valueOf(val), time.newInstance(0, 0, 0, 0));
                                            }   
                                            Sobjlist[j].put(keyField, dt);
                                        }
                                        //if field type is Date
                                        else if(f.getType() == schema.Displaytype.Date){
                                            Sobjlist[j].put(keyField, Date.valueOf(recordFieldValuesAsMap.get(keyField)));
                                        }
                                        //if field type is MultiPicklist Or picklist
                                        else if(f.getType() == schema.Displaytype.MultiPicklist || f.getType() == schema.Displaytype.Picklist){
                                            Sobjlist[j].put(keyField, String.valueof(recordFieldValuesAsMap.get(keyField)));
                                        }
                                        //field type is REFERENCE, String 
                                        else{
                                            Sobjlist[j].put(keyField, (String)recordFieldValuesAsMap.get(keyField));
                                        }
                                    }
                                    else{
                                        Sobjlist[j].put(keyField, null);
                                    }
                                }
                            }
                        }
                    }
                }
                sObjectMap.put('UPDATE',Sobjlist);
            }
        } 
        if(newRecordMap.size() > 0){
            List<Sobject> Sobjlist = new List<Sobject>();
            Sobjlist =  BuildSobject.getSFM_BuildSobject2(null,objName,newRecordMap.size(),AllFieldDescribe);
            system.debug('Sobjlist'+Sobjlist.size()+Sobjlist);
            if(Sobjlist != null && Sobjlist.size() > 0){
                Integer intSizeOfRecList = Sobjlist.size();
                for(Integer j = 0; j < intSizeOfRecList; j++){
                    //Sobject record = new Sobject();
                    Sobject record;
                    if(newRecordMap.containskey(j)){
                        record = newRecordMap.get(j);
                    }
                    Map<String, Object> recordFieldValuesAsMap = record.getPopulatedFieldsAsMap();
                    if(recordFieldValuesAsMap.size() > 0){
                        Set<String> FieldApiName = new Set<String>(); 
                        for(String keyField: recordFieldValuesAsMap.keySet()){
                            if(localFieldMap.containskey(keyField)){
                                setAllFieldsUsedInSobject.add(keyField); //Added for the defect fix 042831
                                //Describe the field to check different attributes of fields..
                                Schema.DescribeFieldResult f = localFieldMap.get(keyField).getDescribe();
                                if(parentColumnName != null && parentColumnName.length() > 0 && hdrObjId != null && hdrObjId.length() > 0 && keyField == parentColumnName){
                                    Sobjlist[j].put(keyField, hdrObjId);
                                }
                                else{
                                    FieldApiName.add(keyField);
                                    if(f.isCreateable()){
                                        if(recordFieldValuesAsMap.get(keyField) != null && String.valueOf(recordFieldValuesAsMap.get(keyField)).length() > 0){
                                            //if Field Type is Double,persent,currency 
                                            if(f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency){
                                                Sobjlist[j].put(keyField, Double.valueOf(recordFieldValuesAsMap.get(keyField)));
                                            }
                                            //if field type is Integer
                                            else if(f.getType() == schema.Displaytype.Integer){
                                                Sobjlist[j].put(keyField, Integer.valueOf(recordFieldValuesAsMap.get(keyField)));
                                            }
                                            //if field type is Boolean
                                            else if(f.getType() == schema.Displaytype.Boolean){
                                                Sobjlist[j].put(keyField, Boolean.valueOf(recordFieldValuesAsMap.get(keyField)));
                                            }
                                            //if field type is DateTime
                                            else if(f.getType() == schema.Displaytype.DateTime){
                                                String val = String.valueOf(recordFieldValuesAsMap.get(keyField));
                                                val = val.replace('T',' ');
                                                List<String> valList = new List<String>(); 
                                                val = val.replace('.','~');
                                                valList = val.split('~');
                                                if(valList.size() == 0){
                                                    valList = new List<String>(); 
                                                    valList = val.split('\\+');
                                                }
                                                if(valList.size() == 0){
                                                    valList = new List<String>(); 
                                                    valList = val.split('\\-');
                                                }
                                                val = valList[0];
                                                datetime dt;
                                                try{
                                                    dt = DateTime.valueOfgmt(val);
                                                }
                                                catch(Exception ex){
                                                    dt = Datetime.newInstancegmt(Date.valueOf(val), time.newInstance(0, 0, 0, 0));
                                                }   
                                                Sobjlist[j].put(keyField, dt);
                                            }
                                            //if field type is Date
                                            else if(f.getType() == schema.Displaytype.Date){
                                                Sobjlist[j].put(keyField, Date.valueOf(recordFieldValuesAsMap.get(keyField)));
                                            }
                                            //if field type is MultiPicklist OR Picklist
                                            else if(f.getType() == schema.Displaytype.MultiPicklist || f.getType() == schema.Displaytype.Picklist){
                                                Sobjlist[j].put(keyField, String.valueOf(recordFieldValuesAsMap.get(keyField)));
                                            }
                                            //field type is REFERENCE, String 
                                            else{
                                                Sobjlist[j].put(keyField, (String)recordFieldValuesAsMap.get(keyField));
                                            }
                                        }
                                    }
                                }    
                            }   
                        }
                        if(parentColumnName != null && parentColumnName.length() > 0 && !FieldApiName.contains(parentColumnName) && hdrObjId != null && hdrObjId.length() > 0){
                            Sobjlist[j].put(parentColumnName,hdrObjId);
                        }
                    }
                    if(sourceRecID.containskey(j)){
                        list<Sobject> temp = new list<Sobject>();
                        temp.add(Sobjlist[j]);
                        sObjectMap.put(sourceRecID.get(j),temp);
                    }   
                }
                sObjectMap.put('INSERT',Sobjlist); 
            }
        }
        System.debug('sObjectMap: '+sObjectMap);
        return sObjectMap;
    }
}