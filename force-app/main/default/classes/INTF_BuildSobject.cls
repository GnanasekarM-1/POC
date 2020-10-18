public with sharing class INTF_BuildSobject 
{
    //Commented below line and using class COMM_Utils_V2 which has higher version for defect 043201 fix
    //SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils(); 
    SVMXC.COMM_Utils_V2 commutils = new SVMXC.COMM_Utils_V2(); 
    public map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    public map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    
    public INTF_buildSobject()
    {
        gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            allobjmap.put(s.getDescribe().getName(),s);
        } 
    }
    public List<Sobject> getINTF_BuildSobject(String RecordID,String ObjectName,String ParentColumnName,Integer NoOfSobjects)
    {
        //try{
        system.debug('RecordID'+RecordID);
        system.debug('ObjectName'+ObjectName);
        system.debug('ParentColumnName'+ParentColumnName);
        system.debug('NoOfSobjects'+NoOfSobjects);
        list<Sobject> SobjectList = new list<Sobject>(); 
        map<String, Schema.SObjectField> Fieldmap = new map<String, Schema.SObjectField>();
        map<String,String> LocalFldMap = new map<String,String>();
        list<String> FieldLst = new list<String>(); 
        String FieldName = '';
        if(ObjectName != null && ObjectName.length() > 0 && allobjmap.containskey(ObjectName))
        {
            Fieldmap = allobjmap.get(ObjectName).getDescribe().fields.getMap();
            FieldLst = commutils.SVMX_getFieldList(Fieldmap,true);
            FieldLst = commutils.checkDuplicateFields(FieldLst, ObjectName); //Added for the defect 043715
        }
        //get the sobject Record to populate in the page....
        if(RecordID != null && RecordID.length() > 0 && ObjectName!= null && ObjectName.length() > 0)
        {
            if(ParentColumnName == null || ParentColumnName.length() == 0)
            {
                system.debug('Entered111');
                FieldName = commutils.SVMX_getFieldNamesFromList(FieldLst);
                String Query = 'select ' +FieldName+ ' from ' + ObjectName + ' where Id = \''+RecordID+'\''; 
                system.debug('Query'+Query);
                SobjectList = Database.query(Query);
                system.debug('SobjectList'+SobjectList);
            }
            if(ParentColumnName != null && ParentColumnName.length() > 0)
            {
                FieldName = commutils.SVMX_getFieldNamesFromList(FieldLst);
                String Query = 'select ' +FieldName+ ' from ' + ObjectName + ' where '+ ParentColumnName + ' = \''+RecordID+'\''; 
                system.debug('Query'+Query);
                SobjectList = Database.query(Query);
                system.debug('SobjectList'+SobjectList);
            }   
        }
        if(RecordID == null && ObjectName != null && ObjectName.length() > 0 )
        {
            system.debug('Entered in Record id null and object not null');
            if(NoOfSobjects != null && NoOfSobjects > 0)
            {
                system.debug('Entered in NoOfSobjects not null');
                for(Integer i = 0;i < NoOfSobjects;i++)
                {
                    
                    Sobject Sobj = allobjmap.get(ObjectName).newSObject();
                    SobjectList.add(Sobj);
                }
            }
            if(NoOfSobjects == null)
            {
                system.debug('Entered in NoOfSobjects null');
                Sobject Sobj = allobjmap.get(ObjectName).newSObject();
                SobjectList.add(Sobj);
            }
        }
        system.debug('SobjectList'+SobjectList);   
        return SobjectList;
        //}catch(Exception ex){return null;}
    }
    public List<Sobject> getINTF_BuildSobject2(Set<String> RecordIDs,String ObjectName,Integer NoOfSobjects,map<String,map<String,Schema.SObjectField>> AllFieldDescribe)
    {
        //try{
        system.debug('RecordID'+RecordIDs);
        system.debug('ObjectName'+ObjectName);
        list<Sobject> SobjectList = new list<Sobject>(); 
        map<String, Schema.SObjectField> Fieldmap = new map<String, Schema.SObjectField>();
        list<String> FieldLst = new list<String>(); 
        String FieldName = '';
        if(ObjectName != null && ObjectName.length() > 0 && allobjmap.containskey(ObjectName) && AllFieldDescribe.containskey(ObjectName))
        {
            Fieldmap = AllFieldDescribe.get(ObjectName);
            FieldLst = commutils.SVMX_getFieldList(Fieldmap,true);
            FieldLst = commutils.checkDuplicateFields(FieldLst, ObjectName); //Added for the defect 043715
        }
        system.debug('FieldLst'+FieldLst);
        //get the sobject Record to populate in the page....
        if(RecordIDs != null && RecordIDs.size() > 0 && ObjectName!= null && ObjectName.length() > 0)
        {
            system.debug('Entered111');
            FieldName = commutils.SVMX_getFieldNamesFromList(FieldLst);
            String Query = 'select ' +FieldName+ ' from ' + ObjectName + ' where Id IN : RecordIDs';    //= \''+RecordID+'\''; 
            system.debug('Query'+Query);
            SobjectList = Database.query(Query);
            system.debug('SobjectList'+SobjectList);
        }
        else if(NoOfSobjects != null && NoOfSobjects > 0)
        {
            system.debug('Entered in NoOfSobjects not null');
            for(Integer i = 0;i < NoOfSobjects;i++)
            {
                
                Sobject Sobj = allobjmap.get(ObjectName).newSObject();
                SobjectList.add(Sobj);
            }
        }
        return SobjectList;
        //}catch(Exception ex){return null;}
    }

}