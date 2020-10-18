public with sharing class INTF_BuildSobjectFromKeyValue 
{
    
    SVMXC.INTF_buildSobject BuildSobject = new SVMXC.INTF_buildSobject();
    public map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    public map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    public INTF_buildSobjectFromKeyValue()
    {
        gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            allobjmap.put(s.getDescribe().getName(),s);
        }  
        system.debug('allobjmap'+allobjmap);
    }
    public Map<String,Sobject> BuildSobjectFromKeyValue(List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmap,String ObjName,String ParentColumnName,String HdrObjId)//
    {
        //try{
        system.debug('amarstringmap'+stringmap.size()+stringmap);
        system.debug('ObjName'+ObjName);
        map<String,Sobject> SobjectMap = new map<String,Sobject>();  
        Boolean IsIDPresent = false;
        String RecId = '';
        List<Sobject> Sobjlist = new List<Sobject>();
        Map<String,Schema.SObjectField> FieldMap = new Map<String,Schema.SObjectField>();
        Map<String,Schema.SObjectField> LocalFieldMap = new Map<String,Schema.SObjectField>(); 
        if(ObjName != null && ObjName.length() > 0 && allobjmap.containskey(ObjName))
        {
            FieldMap = allobjmap.get(ObjName).getDescribe().fields.getMap();
            if(FieldMap.size() > 0) 
            {
                for(String s : FieldMap.keyset())
                {
                    system.debug('TEST LOG: ' + FieldMap.get(s).getDescribe().getname().toUpperCase());
                    LocalFieldMap.put(FieldMap.get(s).getDescribe().getname().toUpperCase(),FieldMap.get(s));
                }
            }
        }
        //system.debug('FieldMap '+FieldMap );
        if(stringmap.size() > 0)
        {
            for(Integer i=0;i<stringmap.size();i++)
            {
                //system.debug('venu'+stringmap[i].key);
                if(stringmap[i].key.touppercase() == 'ID')
                {
                    //system.debug('amarEntered');
                    IsIDPresent = true;
                    RecId = stringmap[i].value;
                }   
            }
        }
        system.debug('IsIDPresent'+IsIDPresent);
        system.debug('RecId'+RecId);
        if(IsIDPresent)//Aready Exsisting Record(Header)(It alwyas to be updated)
        {
            if(ObjName != null && ObjName.length() > 0 && RecId != null && RecId.length() > 0 ) //ParentColumnName == null && HdrObjId == null
            {   
                Sobjlist = BuildSobject.getINTF_BuildSobject(RecID,ObjName,null,null);
                system.debug('Sobjlist'+Sobjlist);
                if(Sobjlist.size() > 0)
                {
                    for(Integer i=0;i<stringmap.size();i++)
                    {
                        system.debug('amarkey '+stringmap[i].key );
                        system.debug('amarvalue '+stringmap[i].value );
                        if(stringmap[i].key != null && stringmap[i].key.length() > 0 && LocalFieldMap.containskey(stringmap[i].key.toUpperCase()) && stringmap[i].key.touppercase() != 'ID' && stringmap[i].key.touppercase() != 'LASTVIEWEDDATE' && stringmap[i].key.touppercase() != 'LASTREFERENCEDDATE') //added check for # defect #48041 && stringmap[i].value != null && stringmap[i].value.length() > 0 
                        {
                            Schema.DescribeFieldResult f = LocalFieldMap.get(stringmap[i].key.toUpperCase()).getDescribe();
                            system.debug('SUCESS ' + f);
                            if((f.getType() == schema.Displaytype.Date || f.getType() == schema.Displaytype.DateTime) && !f.isAccessible()){// Added for BAC-4486/043861/BAC-4648
                                Sobjlist[0].put(stringmap[i].key,null);
                            }else if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isUpdateable())//if Field Type is Double,persent,currency 
                            {
                                if(f.getPrecision() > 0)
                                {
                                    if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                        Sobjlist[0].put(stringmap[i].key,Double.valueof(stringmap[i].value));
                                    else
                                        Sobjlist[0].put(stringmap[i].key,Null);
                                }
                                else
                                {
                                    if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                        Sobjlist[0].put(stringmap[i].key,integer.valueof(stringmap[i].value));
                                    else
                                        Sobjlist[0].put(stringmap[i].key,Null);
                                }       
                            }
                            else if(f.getType() == schema.Displaytype.Integer && f.isUpdateable())//if field type is Integer
                            {
                                if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    Sobjlist[0].put(stringmap[i].key,Integer.valueof(stringmap[i].value));
                                else
                                    Sobjlist[0].put(stringmap[i].key,Null);
                            }
                            else if(f.getType() == schema.Displaytype.Boolean && f.isUpdateable())//if field type is Boolean
                            {
                                if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    Sobjlist[0].put(stringmap[i].key,Boolean.valueof(stringmap[i].value));
                                else
                                    Sobjlist[0].put(stringmap[i].key,Null);
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
                                    system.debug('zzzzz'+val);
                                    system.debug('zzzzz'+DateTime.valueOfgmt(val));
                                    Sobjlist[0].put(stringmap[i].key,DateTime.valueOfgmt(val));
                                }   
                                else
                                    Sobjlist[0].put(stringmap[i].key,Null);
                            }
                            else if(f.getType() == schema.Displaytype.Date && f.isUpdateable())//if field type is Date
                            {
                                if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    Sobjlist[0].put(stringmap[i].key,Date.valueOf(stringmap[i].value));
                                else
                                    Sobjlist[0].put(stringmap[i].key,Null);
                            }
                            else if(f.getType() == schema.Displaytype.MultiPicklist && f.isUpdateable())//if field type is MultiPicklist
                            {
                               if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    Sobjlist[0].put(stringmap[i].key,String.valueof(stringmap[i].value));
                                else
                                    Sobjlist[0].put(stringmap[i].key,Null);
                            }
                            else if(f.getType() == schema.Displaytype.Picklist && f.isUpdateable())//if field type is Picklist
                            {
                                if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    Sobjlist[0].put(stringmap[i].key,String.valueof(stringmap[i].value));
                                else
                                    Sobjlist[0].put(stringmap[i].key,Null);
                                system.debug('SUCESS2 ' + Sobjlist[0].get(stringmap[i].key));
                            }
                            else //else field type is REFERENCE,String 
                            {
                                if(f.isUpdateable())
                                {
                                    if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                        Sobjlist[0].put(stringmap[i].key,(String)stringmap[i].value);
                                    else
                                        Sobjlist[0].put(stringmap[i].key,stringmap[i].value);   
                                }
                            }
                        }
                    }
                }           
                SobjectMap.put('UPDATE',Sobjlist[0]);
                system.debug('SUCESS ' + Sobjlist[0]);
            }   
        }    
        else//Its new Reocrds(Needs to inserted)
        {
            system.debug('New Record');
            if(ObjName != null && ObjName.length() > 0 && (RecId == null || RecId.length() == 0))
                Sobjlist =  BuildSobject.getINTF_BuildSobject(null,ObjName,null,null);
            system.debug('Sobjlist'+Sobjlist);
            if(Sobjlist.size() > 0 )//&& ParentColumnName == null && HdrObjId == null
            {
                set<String> FieldApiName = new set<String>(); 
                for(Integer i=0;i<stringmap.size();i++)
                {
                    system.debug('key '+stringmap[i].key );
                    system.debug('value '+stringmap[i].value );
                    if(stringmap[i].key != null && stringmap[i].key.length() > 0  && LocalFieldMap.containskey(stringmap[i].key.toUpperCase()))//&& stringmap[i].value != null && stringmap[i].value.length() > 0
                    {
                        //Desctibe the field to check differen attributes of fields..
                        Schema.DescribeFieldResult f = LocalFieldMap.get(stringmap[i].key.toUpperCase()).getDescribe();
                        if(ParentColumnName != null && ParentColumnName.length() > 0 && HdrObjId != null && HdrObjId.length() > 0 && stringmap[i].key == ParentColumnName)
                        {
                            Sobjlist[0].put(stringmap[i].key,HdrObjId);
                        }
                        else
                        {
                            FieldApiName.add(stringmap[i].key);
                            if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                            {
                                if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    Sobjlist[0].put(stringmap[i].key,(double.valueOf(stringmap[i].value)));
                                //else
                                    //Sobjlist[0].put(stringmap[i].key,null);
                            }
                            else if(f.getType() == schema.Displaytype.Integer && f.isCreateable())//if field type is Integer
                            {
                                if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    Sobjlist[0].put(stringmap[i].key,Integer.valueof(stringmap[i].value));
                                //else
                                    //Sobjlist[0].put(stringmap[i].key,stringmap[i].value);
                            }
                            else if(f.getType() == schema.Displaytype.Boolean && f.isCreateable())//if field type is Boolean
                            {
                                if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    Sobjlist[0].put(stringmap[i].key,Boolean.valueof(stringmap[i].value));
                                //else
                                    //Sobjlist[0].put(stringmap[i].key,stringmap[i].value);
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
                                    Sobjlist[0].put(stringmap[i].key,DateTime.valueOfgmt(val));
                                }   
                                //else
                                    //Sobjlist[0].put(stringmap[i].key,null);
                            }
                            else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                            {
                                if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    Sobjlist[0].put(stringmap[i].key,Date.valueOf(stringmap[i].value));
                                //else
                                    //Sobjlist[0].put(stringmap[i].key,null);
                            }
                            else if(f.getType() == schema.Displaytype.MultiPicklist && f.isCreateable())//if field type is MultiPicklist
                            {
                                if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    Sobjlist[0].put(stringmap[i].key,String.valueof(stringmap[i].value));
                                //else
                                //  Sobjlist[0].put(stringmap[i].key,null);
                            }
                            else if(f.getType() == schema.Displaytype.Picklist && f.isUpdateable())//if field type is Picklist
                            {
                                if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                    Sobjlist[0].put(stringmap[i].key,String.valueof(stringmap[i].value));
                                //else
                                    //Sobjlist[0].put(stringmap[i].key,null);
                            }
                            else //else field type is REFERENCE,String 
                            {
                                if(f.isCreateable())//
                                {
                                    if(stringmap[i].value != null && stringmap[i].value.length() > 0)
                                        Sobjlist[0].put(stringmap[i].key,(String)stringmap[i].value);
                                   // else
                                    //  Sobjlist[0].put(stringmap[i].key,null);
                                }
                            }
                        }    
                    }   
                }
                if(ParentColumnName != null && ParentColumnName.length() > 0 && FieldApiName.contains(ParentColumnName) == false && HdrObjId != null && HdrObjId.length() > 0)
                {
                    Sobjlist[0].put(ParentColumnName,HdrObjId);
                }
                SobjectMap.put('INSERT',Sobjlist[0]);
            }
        }
        system.debug('SobjectMap'+SobjectMap);
        return SobjectMap;
        //}catch(Exception ex){return null;}
    }
    public Map<String,List<Sobject>> BuildSobjectFromKeyValue2(List<SVMXC.INTF_WebServicesDef.INTF_Record> SFMRecordList,String ObjName,String ParentColumnName,String HdrObjId,map<String,map<String,Schema.SObjectField>> AllFieldDescribe)//
    {
        //try{
        system.debug('SFMRecordList'+SFMRecordList.size()+SFMRecordList);
        system.debug('ObjName'+ObjName);
        map<String,list<Sobject>> SobjectMap = new map<String,list<Sobject>>();  
        Set<String> RecIds = new Set<String>();
        map<String,list<SVMXC.INTF_WebServicesDef.INTF_StringMap>> ExsistingRecords = new map<String,list<SVMXC.INTF_WebServicesDef.INTF_StringMap>>();
        map<Integer,list<SVMXC.INTF_WebServicesDef.INTF_StringMap>> NewRecords = new map<Integer,list<SVMXC.INTF_WebServicesDef.INTF_StringMap>>();
        map<Integer,String> SourceRecID = new map<Integer,String>();
        Map<String,Schema.SObjectField> LocalFieldMap = new Map<String,Schema.SObjectField>(); 
        if(AllFieldDescribe.containskey(ObjName))
            LocalFieldMap = AllFieldDescribe.get(ObjName);
        if(SFMRecordList.size() > 0)
        {
            Integer j = 0;
            for(Integer i = 0;i<SFMRecordList.size();i++)
            {
                if(SFMRecordList[i].targetRecordId != null && SFMRecordList[i].targetRecordId.length() > 0)
                {
                    RecIds.add(SFMRecordList[i].targetRecordId);
                    ExsistingRecords.put(SFMRecordList[i].targetRecordId,SFMRecordList[i].targetRecordAsKeyValue);
                }
                else
                {
                    system.debug('NewRecords:New:'+SFMRecordList[i].targetRecordAsKeyValue);
                    NewRecords.put(j,SFMRecordList[i].targetRecordAsKeyValue);
                    if(SFMRecordList[i].sourceRecordId != null && SFMRecordList[i].sourceRecordId.length() > 0)
                        SourceRecID.put(j,SFMRecordList[i].sourceRecordId);
                    j = j+1;
                    
                }
            }
        }
        system.debug('RecIds'+RecIds);
        system.debug('ExsistingRecords'+ExsistingRecords.size()+ExsistingRecords);
        system.debug('NewRecords'+NewRecords.size()+NewRecords);
        system.debug('SourceRecID'+SourceRecID.size()+SourceRecID);
        //Process Exsisting Records first
        if(ExsistingRecords.size() > 0)
        {
            List<Sobject> Sobjlist = new List<Sobject>();
            Sobjlist = BuildSobject.getINTF_BuildSobject2(RecIds,ObjName,null,AllFieldDescribe);
            if(Sobjlist.size() > 0)
            {
                for(Integer j = 0;j< Sobjlist.size();j++)
                {
                    String RecId = String.valueof(Sobjlist[j].get('Id'));
                    List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmap = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                    if(ExsistingRecords.containskey(RecId))
                        stringmap = ExsistingRecords.get(RecId);
                    if(stringmap.size() > 0)
                    {
                        for(Integer i=0;i<stringmap.size();i++)
                        {
                            system.debug('amarkey '+stringmap[i].key );
                            system.debug('amarvalue '+stringmap[i].value );
                            if(stringmap[i].key != null && stringmap[i].key.length() > 0 && LocalFieldMap.containskey(stringmap[i].key) && stringmap[i].key.touppercase() != 'ID'&& stringmap[i].key.touppercase() != 'LASTVIEWEDDATE' && stringmap[i].key.touppercase() != 'LASTREFERENCEDDATE') //Added check for defect # 48041 && stringmap[i].value != null && stringmap[i].value.length() > 0 
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
                                        system.debug('zzzzz'+val);
                                        system.debug('zzzzz'+DateTime.valueOfgmt(val));
                                        Sobjlist[j].put(stringmap[i].key,DateTime.valueOfgmt(val));
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
            Sobjlist =  BuildSobject.getINTF_BuildSobject2(null,ObjName,NewRecords.size(),AllFieldDescribe);
            system.debug('Sobjlist'+Sobjlist.size()+Sobjlist);
            if(Sobjlist.size() > 0)
            {
                for(Integer j = 0; j<Sobjlist.size();j++)
                {
                    List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmap = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                    if(NewRecords.containskey(j))
                        stringmap = NewRecords.get(j);
                    if(stringmap.size() > 0)
                    {
                        set<String> FieldApiName = new set<String>(); 
                        for(Integer i=0;i<stringmap.size();i++)
                        {
                            system.debug('key '+stringmap[i].key );
                            system.debug('value '+stringmap[i].value );
                            if(stringmap[i].key != null && stringmap[i].key.length() > 0  && LocalFieldMap.containskey(stringmap[i].key ))//&& stringmap[i].value != null && stringmap[i].value.length() > 0
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
                                            Sobjlist[j].put(stringmap[i].key,DateTime.valueOfgmt(val));
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
     
}