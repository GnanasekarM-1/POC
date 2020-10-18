public with sharing class SFM_BuildSobject 
{
    public string batchsize = String.valueOf(SFMDeliveryServiceImpl.detailRecBatchSize);//Added by nidhi as part of lazy loading BAC-4680
    //SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils(); 
    SVMXC.COMM_Utils_V2 commutils = new SVMXC.COMM_Utils_V2();
    //public map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    //public map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    public Map<String, Set<String>> mapObjectNameVsListOfFields = new Map<String, Set<String>>(); //Added for the story BAC-4264
    public String calledFromWhere = null; //Valid values are "SFM_ParseProcess" //Added for the story BAC-4264
    public Boolean isDetailRecordQuery = false;//Added by Nidhi as part of Lazy Loading BAC-4680
    public Boolean isSubmoduleEmpty = false;//Added by Nidhi as part of Lazy Loading BAC-4680
    public String nameField = '';//Added by Nidhi as part of Lazy Loading BAC-4680
    public Boolean isQueryRecordTypeId = false; //Added for the story BAC-5372
    public Set<String> setObjectHasRecordType = new Set<String>(); //Added for the story BAC-5372
    public SFM_buildSobject()
    {
        //Added If else condition for getting allObjMap for the story BAC-4410
        //BAC-5357
        /*if(SFM_GetData.allObjMap != null && SFM_GetData.allObjMap.size() > 0){
            allobjmap = SFM_GetData.allObjMap;
        }*/
        /*else{
            System.debug('getData22');
            gd = Schema.getGlobalDescribe();
            for(Schema.SObjectType s : gd.values())
            {
                allobjmap.put(s.getDescribe().getName(),s);
            } 
        }*/
    }
    public String buildQueryStringFromSet(set<String> setFields){
        system.debug('setFields'+setFields);
        if(!(setFields.contains('ID') || setFields.contains('iD') ||setFields.contains('Id') ||setFields.contains('id')))
            setFields.add('Id');
         if(!(setFields.contains('LastModifiedDate') || setFields.contains('LASTMODIFIEDDATE') || setFields.contains('lastmodifieddate'))) //Added for BAC-5200
            setFields.add('LastModifiedDate'); // Added for BAC-4682/SFD-1246
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
    public list<Sobject> SFM_buildSourceRecords(String strSourceRecId, String strObjName, String ParentColumnName, String strSourceFields){
        return SFM_buildSourceRecordsWithSorting(strSourceRecId,strObjName,ParentColumnName,strSourceFields,null);
    }
    public list<Sobject> SFM_buildSourceRecordsWithSorting(String strSourceRecId, String strObjName, String ParentColumnName, String strSourceFields,String strSortingClause){
        //----Start----Added for the defect 043715
        if(!String.isBlank(strSourceFields)){
            List<String> lstFieldList = strSourceFields.split(',');
            lstFieldList = commutils.checkDuplicateFields(lstFieldList, strObjName);
            strSourceFields = commutils.SVMX_getFieldNamesFromList(lstFieldList);
        }
        //----End----Added for the defect 043715
        list<Sobject> lstSobject = new list<Sobject>(); 
        String strQuery = '';
        if(ParentColumnName != null){
            strQuery += 'Select '+strSourceFields+' From '+strObjName+ ' where '+ParentColumnName+ ' =: strSourceRecId';
        }else{
            strQuery += 'Select '+strSourceFields+' From '+strObjName+ ' where id =: strSourceRecId';
        }
        if(strSortingClause != null)
            strQuery += ' Order By '+strSortingClause;
        system.debug('strQuery'+strQuery);
        lstSobject = database.query(strQuery);
        system.debug('lstSobject'+lstSobject);
        return lstSobject;
    }
    public List<Sobject> getSFM_BuildSobject(String RecordID,String ObjectName,String ParentColumnName,Integer NoOfSobjects)
    {
        return SFM_buildTargetSobjectFromInputFieldsWithSorting(RecordID,ObjectName,ParentColumnName,NoOfSobjects,null,null);
    }
    public list<Sobject> SFM_buildTargetSobjectFromInputFieldsWithSorting(String RecordID,String ObjectName,String ParentColumnName,Integer NoOfSobjects,set<String> lstInputField, String strSortingClause){
        system.debug('strSortingClause'+strSortingClause);
        system.debug('RecordID'+RecordID);
        system.debug('ObjectName'+ObjectName);
        system.debug('ParentColumnName'+ParentColumnName);
        system.debug('NoOfSobjects'+NoOfSobjects);
        system.debug('lstInputField'+lstInputField);
        String strFieldName = '';
        String strOrderByClause = '';
        list<Sobject> SobjectList = new list<Sobject>(); 
        //If fields are given then build Fields string from field list.
        if(lstInputField != null && (!lstInputField.isEmpty())){
        //-------Start------Added for the story BAC-5372
        Map<String,Schema.SObjectField> mapFieldDesc = COMM_Utils_DescribeCall.getObjectFieldDetails(ObjectName);
            if(isQueryRecordTypeId && !lstInputField.contains('RecordTypeId') && !mapFieldDesc.isEmpty()){
                if(setObjectHasRecordType.contains(ObjectName)){
                    lstInputField.add('RecordTypeId');
                    System.debug('RecordTypeId added in the query - No Describe');
                }
                else{
                    if(mapFieldDesc.containsKey('RecordTypeId')){
                        setObjectHasRecordType.add(ObjectName);
                        lstInputField.add('RecordTypeId');
                        System.debug('RecordTypeId added in the query - Describe');
                    }
                }
            }
            //-------End--------Added for the story BAC-5372
            
            lstInputField = commutils.checkDuplicateFields(lstInputField, ObjectName); //Added for the defect 043715
            
            //------Start-------Added for the story BAC-4264
            if(calledFromWhere == 'SFM_ParseProcess'){
                if(!mapObjectNameVsListOfFields.containsKey(ObjectName)){
                    mapObjectNameVsListOfFields.put(ObjectName, new Set<String>());
                }
                mapObjectNameVsListOfFields.get(ObjectName).addAll(lstInputField);
            }
            //------End-------Added for the story BAC-4264
            //BAC-5357
            if(lstInputField != null && !lstInputField.isEmpty())
            {
               List<String> lstofFields = new List<String>();
               lstofFields.addAll(lstInputField);
               strFieldName  = String.join(lstofFields, ',');
            }
        }//if fields are not given then describe object and get fields from the describe.
        else if(lstInputField == null && String.isNotBlank(RecordID)){
           // if(allobjmap.containskey(ObjectName)){ // #optiChange
            //map<String, Schema.SObjectField> mapFieldDesc = new map<String, Schema.SObjectField>();
            Map<String, Schema.SObjectField> mapFieldDesc = COMM_Utils_DescribeCall.getObjectFieldDetails(ObjectName); //#optiChange
            if(mapFieldDesc != null && !mapFieldDesc.isEmpty()){ // #optiChange
                list<String> lstFieldT = new list<String>();
                Map<String,String> LocalFldMap = new map<String,String>();
               // mapFieldDesc = allobjmap.get(ObjectName).getDescribe().fields.getMap(); //#optiChange
                lstFieldT = commutils.SVMX_getFieldList(mapFieldDesc,true);
                lstFieldT = commutils.checkDuplicateFields(lstFieldT, ObjectName); //Added for the defect 043715
                
                //------Start-------Added for the story BAC-4264
                if(calledFromWhere == 'SFM_ParseProcess'){
                    if(!mapObjectNameVsListOfFields.containsKey(ObjectName)){
                        mapObjectNameVsListOfFields.put(ObjectName, new Set<String>());
                    }
                    mapObjectNameVsListOfFields.get(ObjectName).addAll(lstFieldT);
                }
                //------End-------Added for the story BAC-4264

                strFieldName = commutils.SVMX_getFieldNamesFromList(lstFieldT);
            }
            
        } 
        //make Order By Clause 
        /*if(setSortingFields != null && setSortingFields.size() > 0){
            String strOrderByFields = '';
            for(String str : setSortingFields){
                if(strOrderByFields != ''){
                    strOrderByFields += ','+str;
                }
                else{
                    strOrderByFields += str;
                }
            }
            strOrderByClause += ' ORDER BY '+strOrderByFields;
        }*/
        if(strSortingClause != null){
            strOrderByClause += ' ORDER BY '+strSortingClause;
        }else if(!String.isBlank(nameField)){//Added by Nidhi as part of Lazy Loading BAC-4680, Default order by Name.
            strOrderByClause += ' ORDER BY '+ nameField;
        }
        system.debug('strOrderByClause'+strOrderByClause);
        //get the sobject Record to populate in the page....
        if(RecordID != null && RecordID.length() > 0 && ObjectName!= null && ObjectName.length() > 0){
            //Commented for handling defect 039173 and created a new method getMergeResultSet() to get Results
            if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){ //Check added as part of story BAC-3256
                    if(ParentColumnName == null || ParentColumnName.length() == 0){
                    String Query = 'select ' +strFieldName+ ' from ' + ObjectName + ' where Id = \''+RecordID+'\''+strOrderByClause;
                    //Added by Nidhi as part of Lazy Loading BAC-4680
                    if(!String.isBlank(batchsize) &&  Integer.valueOf(batchsize)>0 && isDetailRecordQuery && isSubmoduleEmpty){
                        Query += ' Limit '+ batchsize +' OFFSET 0';
                    }
                    //Strng qStr = StringUtil.format("select {0} from {1} where Id=\'{2}\'", new Array('a', 'b')); 
                    system.debug(LoggingLevel.WARN,'Query'+Query);
                    SobjectList = Database.query(Query);
                    system.debug(LoggingLevel.WARN,'SobjectList'+SobjectList);   
                }
                if(ParentColumnName != null && ParentColumnName.length() > 0){
                    String Query = 'select ' +strFieldName+ ' from ' + ObjectName + ' where '+ ParentColumnName + ' = \''+RecordID+'\''+strOrderByClause; 
                    //Added by Nidhi as part of Lazy Loading BAC-4680
                    if(!String.isBlank(batchsize) && Integer.valueOf(batchsize)>0 && isDetailRecordQuery && isSubmoduleEmpty){
                        Query += ' Limit '+ batchsize+' OFFSET 0';
                    }
                    system.debug(LoggingLevel.WARN,'Query'+Query);
                    SobjectList = Database.query(Query);
                    system.debug(LoggingLevel.WARN,'SobjectList'+SobjectList);
                }
            }
            else{
                    SobjectList = getMergeResultSet(strFieldName, ObjectName, RecordID, strOrderByClause, ParentColumnName);
            }
            //This is commented as part of Optimization of code BAC-2993
            //SobjectList = getMergeResultSet(strFieldName, ObjectName, RecordID, strOrderByClause, ParentColumnName);
        }
        else if(RecordID == null && ObjectName != null && ObjectName.length() > 0 )
        {
            system.debug('Entered in Record id null and object not null');
            if(NoOfSobjects != null && NoOfSobjects > 0)
            {
                system.debug('Entered in NoOfSobjects not null');
                for(Integer i = 0;i < NoOfSobjects;i++)
                {
                    
                   // Sobject Sobj = allobjmap.get(ObjectName).newSObject(); // #optiChange
                    Sobject Sobj = (SObject)Type.forName(ObjectName).newInstance(); //#optiChange ToBeAskedBala
                    SobjectList.add(Sobj);
                }
            }
            if(NoOfSobjects == null)
            {
                system.debug('Entered in NoOfSobjects null');
                //Sobject Sobj = allobjmap.get(ObjectName).newSObject(); //#optiChange
                Sobject Sobj = (SObject)Type.forName(ObjectName).newInstance(); //#optiChange ToBeAskedBala
                SobjectList.add(Sobj);
            }
        }
        system.debug('SobjectList'+SobjectList);   
        return SobjectList;
        
    
    }
    //defect 039173
    //New method to split the Total number of fields to query records in two SOQL and then merge and return it.
    private List<Sobject> getMergeResultSet(String strFieldList, String ObjectName, String RecordID, String strOrderByClause, String ParentColumnName){
        List<String> lstFieldList = new List<String>();
        if(strFieldList != null && strFieldList.length() > 0){
            lstFieldList = strFieldList.split(',');
        }
        List<String> secondFieldList = new List<String>();
        Integer listHalfSize = 0;
        if(lstFieldList.size() > 0){
            listHalfSize = lstFieldList.size()/2;
        }
        list<Sobject> SobjectList = new list<Sobject>();
        Map<Id,Sobject> mapIdRecord1 = new Map<Id,Sobject>();
        Map<Id,Sobject> mapIdRecord2 = new Map<Id,Sobject>();
        
        for(Integer i=0; i<listHalfSize; i++){
            secondFieldList.add(lstFieldList[i]);
            lstFieldList.remove(i);
        }
        lstFieldList = commutils.checkDuplicateFields(lstFieldList, ObjectName); //Added for the defect 043715
        secondFieldList = commutils.checkDuplicateFields(secondFieldList, ObjectName); //Added for the defect 043715
        //------Start-------Added for the story BAC-4264
        if(calledFromWhere == 'SFM_ParseProcess'){
            if(!mapObjectNameVsListOfFields.containsKey(ObjectName)){
                mapObjectNameVsListOfFields.put(ObjectName, new Set<String>());
            }
            mapObjectNameVsListOfFields.get(ObjectName).addAll(lstFieldList);
            mapObjectNameVsListOfFields.get(ObjectName).addAll(secondFieldList);
        }
        //------End-------Added for the story BAC-4264
        String firstFieldString = commutils.SVMX_getFieldNamesFromList(lstFieldList);
        String secondFieldString = commutils.SVMX_getFieldNamesFromList(secondFieldList);
        String Query1 = 'select ' +firstFieldString+ ' from ' + ObjectName;
        String Query2 = 'select ' +secondFieldString+ ' from ' + ObjectName;
        
        if(ParentColumnName == null || ParentColumnName.length() == 0){
            Query1 += ' where Id = \''+RecordID+'\''+strOrderByClause;
            Query2 += ' where Id = \''+RecordID+'\''+strOrderByClause; 
        }
        else if(ParentColumnName != null && ParentColumnName.length() > 0){
            Query1 += ' where '+ ParentColumnName + ' = \''+RecordID+'\''+strOrderByClause; 
            Query2 += ' where '+ ParentColumnName + ' = \''+RecordID+'\''+strOrderByClause;
        }
        if(!String.isBlank(batchsize) &&  Integer.valueOf(batchsize)>0 && isDetailRecordQuery && isSubmoduleEmpty){
            Query1 += ' Limit '+ batchsize+' OFFSET 0 ';
            Query2 += ' Limit '+ batchsize+' OFFSET 0 ';
        }        
        System.debug('Query1: '+Query1);
        System.debug('Query2: '+Query2);

        
        
        if(lstFieldList.size() > 0){
            mapIdRecord1 = new Map<Id,Sobject>(Database.query(Query1));
            System.debug('FirstMapRecord: '+mapIdRecord1);
        }
        
        if(secondFieldList.size() > 0){
            mapIdRecord2 = new Map<Id,Sobject>(Database.query(Query2));
            System.debug('SecondMapRecord: '+mapIdRecord2);
        }

        for(Id idd: mapIdRecord1.keyset()){

            /*
                Defect fix : 040455,040432
                The Salesforce XML serialization failed because the sobject passed in the response was untyped(JSON serialization done for defect 039173).
            */
            Map<String,Object> mapFieldAndValueOfRecord1 = new Map<String,object>(mapIdRecord1.get(idd).getPopulatedFieldsAsMap());
            
            if(mapIdRecord2.containsKey(idd) && mapIdRecord2.get(idd) != null){
                Map<String,Object> mapFieldAndValueOfRecord2 = new Map<String,object>(mapIdRecord2.get(idd).getPopulatedFieldsAsMap());
                for(String key : mapFieldAndValueOfRecord2.keyset()){
                    mapFieldAndValueOfRecord1.put(key, mapFieldAndValueOfRecord2.get(key));
                }                
            }            
            /*Map<String,Object> mapFieldAndValueOfRecord1 = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(mapIdRecord1.get(idd)));
            if(mapIdRecord2.containsKey(idd) && mapIdRecord2.get(idd) != null){
                Map<String,Object> mapFieldAndValueOfRecord2 = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(mapIdRecord2.get(idd)));
                for(String key : mapFieldAndValueOfRecord2.keyset()){
                    mapFieldAndValueOfRecord1.put(key, mapFieldAndValueOfRecord2.get(key));
                }                
            }*/
            type stype= type.forName(ObjectName);
            Sobject resultSobject = (Sobject)JSON.deserialize(JSON.serialize(mapFieldAndValueOfRecord1), stype);
            SobjectList.add(resultSobject);
            System.debug('ResultSobject: '+resultSobject);
        }
        
        System.debug('FullSobjectList: '+SobjectList);
        return SobjectList;
    }
    
    public List<Sobject> getSFM_BuildSobject2(Set<String> RecordIDs,String ObjectName,Integer NoOfSobjects,map<String,map<String,Schema.SObjectField>> AllFieldDescribe){
        return getSFM_BuildSobjectsFromInputField(RecordIDs,ObjectName,NoOfSobjects,AllFieldDescribe,null);
    }
    public List<Sobject> getSFM_BuildSobjectsFromInputField(Set<String> RecordIDs,String ObjectName,Integer NoOfSobjects,map<String,map<String,Schema.SObjectField>> AllFieldDescribe,set<String> setInputField){
        list<Sobject> SobjectList = new list<Sobject>(); 
        String strFieldName = '';
        //If fields are given then build Fields string from field list.
        if(setInputField != null && setInputField.size() > 0){
            setInputField = commutils.checkDuplicateFields(setInputField, ObjectName); //Added for the defect 043715
            for(String str : setInputField){
                if(strFieldName != ''){
                    strFieldName += ',' + str;
                }
                else {
                    strFieldName += str;
                }
            }
        }//if fields are not given then describe object and get fields from the describe.
        else if(setInputField == null ){
            if(!(COMM_Utils_DescribeCall.getObjectFieldDetails(ObjectName).isEmpty()) && AllFieldDescribe.containskey(ObjectName)){
                map<String, Schema.SObjectField> mapFieldDesc = new map<String, Schema.SObjectField>();
                mapFieldDesc = AllFieldDescribe.get(ObjectName);
                list<String> lstFieldT = commutils.SVMX_getFieldList(mapFieldDesc,true);
                lstFieldT = commutils.checkDuplicateFields(lstFieldT, ObjectName); //Added for the defect 043715
                strFieldName = commutils.SVMX_getFieldNamesFromList(lstFieldT);
            }
            
        } 
        //get the sobject Record to populate in the page....
        if(RecordIDs != null && !RecordIDs.isEmpty() && String.isNotEmpty(ObjectName))
        {
            system.debug('Entered111');
            String Query = 'select ' +strFieldName+ ' from ' + ObjectName + ' where Id IN : RecordIDs';    //= \''+RecordID+'\''; 
            system.debug('Query'+Query);
            SobjectList = Database.query(Query);
            system.debug('SobjectList'+SobjectList);
        }
        else if(NoOfSobjects != null && NoOfSobjects > 0)
        {
            system.debug('Entered in NoOfSobjects not null');
            for(Integer i = 0;i < NoOfSobjects;i++){
                //Sobject Sobj = allobjmap.get(ObjectName).newSObject(); //#optiChange
                Sobject Sobj = (SObject)Type.forName(ObjectName).newInstance(); //#optiChange ToBeAskedBala 
                SobjectList.add(Sobj);
            }
        }
        return SobjectList;
    }
}