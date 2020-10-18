public with sharing class SFM_ParseExpression
{
    
    //public map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>(); //#optiChange
   // public map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>(); //#optiChange
    //SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils();  
    SVMXC.COMM_Utils_V2 commutils = new SVMXC.COMM_Utils_V2();
    public Map<String, Set<String>> mapObjectNameVsListOfFields = new Map<String, Set<String>>(); //Added for the story BAC-4264
    public String calledFromWhere = null; //Valid values are "SFM_ParseProcess" //Added for the story BAC-4264
    public Boolean isDetailRecordQuery = false;//Added by Nidhi as part of Lazy Loading BAC-4680
    public string batchsize = String.valueOf(SFMDeliveryServiceImpl.detailRecBatchSize);//Added by nidhi as part of lazy loading BAC-4680
    public String nameField = '';//Added by Nidhi as part of Lazy Loading BAC-4680
    public Boolean isQueryRecordTypeId = false; //Added for the story BAC-5372
    public Set<String> setObjectHasRecordType = new Set<String>(); //Added for the story BAC-5372
    
    public SFM_parseExpression(){
        //Added If else condition for getting allObjMap for the story BAC-4410
        /*if(SFM_GetData.allObjMap != null && SFM_GetData.allObjMap.size() > 0){
            allobjmap = SFM_GetData.allObjMap;
        }
        else{
            gd = Schema.getGlobalDescribe();
            for(Schema.SObjectType s : gd.values()){
                allobjmap.put(s.getDescribe().getName(),s);
            }
        }*/
    }
    
    public list<Sobject> SFM_ParseExpression1(List<SObject> lstRecs ,SFM_WrapperDef.SFM_Expression expInfo,String strObjectNameParam, String strWhereclauseParam, String strQueryField, String strSortingClause ){
        try{
            system.debug('Called SFM_ExpressionParsing'+lstRecs);
            //Variable Declarations...
            map<String, Schema.SObjectField> Fieldmap = new map<String, Schema.SObjectField>();
            list<String> FieldLst = new list<String>(); 
            String strWhereClause = '';
            String strObjectName = '';
            String strIDs = '';
            String strQuery = '';
            
            if(strObjectNameParam != null)
                strObjectName = strObjectNameParam;
            if(strWhereclauseParam != null)
                strWhereClause  = strWhereclauseParam;
            if(expInfo != null){
                strObjectName = expinfo.namedExpression.SVMXC__Source_Object_Name__c; 
                strWhereClause = expinfo.namedExpression.SVMXC__Parent_Object_Criteria__c;
            }
            system.debug('strObjectName'+strObjectName);
            system.debug('strWhereClause'+strWhereClause);
            
            if( strWhereClause != null){
                list<SObject> lstValidRecs = new list<SObject>();
                if(lstRecs.size() > 0){
                    for(Sobject sobj : lstRecs){
                        strIDs += '\'' +sobj.Id + '\',';
                    }
                }
                //#optiChange starts
                map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
                if(SFM_GetData.allObjMap != null && SFM_GetData.allObjMap.size() > 0){ 
                    allobjmap = SFM_GetData.allObjMap; 
                } 
                                    
                /*if(strObjectName != null && allobjmap.containskey(strObjectName) && strQueryField == null){
                    Fieldmap = allobjmap.get(strObjectName).getDescribe().fields.getMap();
                    if(Fieldmap.size() > 0)
                        FieldLst = commutils.SVMX_getFieldList(Fieldmap,true);
                    system.debug('FieldLst'+FieldLst);
                    FieldLst = commutils.checkDuplicateFields(FieldLst, strObjectName); //Added for the defect 043715
                    if(FieldLst.size() > 0)
                        strQueryField = commutils.SVMX_getFieldNamesFromList(FieldLst);
                    system.debug('strQueryField'+strQueryField);
                }*/
                
                if(String.isNotBlank(strObjectName) && strQueryField == null){
                    if(allobjmap.containskey(strObjectName))
                    Fieldmap = allobjmap.get(strObjectName).getDescribe().fields.getMap();
                    else
                    Fieldmap = COMM_Utils_DescribeCall.getObjectFieldDetails(strObjectName); //#optiChange
                    if(Fieldmap != NULL && Fieldmap.size() > 0)
                        FieldLst = commutils.SVMX_getFieldList(Fieldmap,true);
                    system.debug('FieldLst'+FieldLst);
                    FieldLst = commutils.checkDuplicateFields(FieldLst, strObjectName); //Added for the defect 043715
                    if(FieldLst.size() > 0)
                        strQueryField = commutils.SVMX_getFieldNamesFromList(FieldLst);
                    system.debug('strQueryField'+strQueryField);
                }
                //#optiChange ends
                //Added below condition for the defect 043715
                else if(!String.isBlank(strQueryField)){
                    List<String> lstFieldList = strQueryField.split(',');
                    
                    //-------Start------Added for the story BAC-5372
                    if(isQueryRecordTypeId && !lstFieldList.contains('RecordTypeId') && allobjmap.containskey(strObjectName)){
                        if(setObjectHasRecordType.contains(strObjectName)){
                            lstFieldList.add('RecordTypeId');
                            System.debug('RecordTypeId added in the query - No Describe');
                        }
                        else{
                            Map<String,Schema.SObjectField> mapFieldDesc = allobjmap.get(strObjectName).getDescribe().fields.getMap();
                            if(mapFieldDesc.containsKey('RecordTypeId')){
                                setObjectHasRecordType.add(strObjectName);
                                lstFieldList.add('RecordTypeId');
                                System.debug('RecordTypeId added in the query - Describe');
                            }
                        }
                    }
                    //-------End--------Added for the story BAC-5372
                    
                    lstFieldList = commutils.checkDuplicateFields(lstFieldList, strObjectName); //Added for the defect 043715
                    strQueryField = commutils.SVMX_getFieldNamesFromList(lstFieldList);
                    System.debug('strQueryField: '+strQueryField);
                }  
                //Commented for handling defect 039173 and created a new method getMergeResultSet() to get Results
                if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){ //Check added as part of story BAC-3256
                        if(strQueryField != null && strQueryField.length() > 0 && strIDs != null && strIDs.length() > 0){
                        strQuery = 'Select '+ strQueryField +' from '+ strObjectName +' where ID in (' + strIDs.substring(0, strIDs.length()-1)+') And ( ' + strWhereClause +' )';
                        if(strSortingClause != null && strSortingClause.length() > 0){
                            strQuery += ' Order By '+strSortingClause;
                        }else if(!String.isBlank(nameField)){//Added by Nidhi as part of Lazy Loading BAC-4680, Default order by Name.
                            strQuery += ' Order By '+nameField;
                        }
                        //Added by Nidhi as part of Lazy Loading BAC-4680
                        if(!String.isBlank(batchsize) && Integer.valueOf(batchsize)>0 && isDetailRecordQuery){
                            strQuery += ' Limit '+ batchsize +' OFFSET 0 ';
                        }
                    }
                    system.debug('strQuery'+strQuery);
                    if(strQuery != null && strQuery.length() > 0)
                        lstValidRecs = database.query(strQuery);
                }
                else{
                        lstValidRecs = getMergeResultSet(strQueryField, strObjectName, strIDs, strSortingClause, strWhereClause);
                }
                //This is commented as part of code Optimization BAC-2993
                //lstValidRecs = getMergeResultSet(strQueryField, strObjectName, strIDs, strSortingClause, strWhereClause);
                return lstValidRecs;                
            }
            else{
                return lstRecs;
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //defect 039173
    //New method to split the Total number of fields to query records in two SOQL and then merge and return it.
    private List<Sobject> getMergeResultSet(String strQueryField, String strObjectName, String strIDs, String strSortingClause, String strWhereClause){
        List<String> lstFieldList = new List<String>();
        if(strQueryField != null && strQueryField.length() > 0){
            lstFieldList = strQueryField.split(',');
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
        lstFieldList = commutils.checkDuplicateFields(lstFieldList, strObjectName); //Added for the defect 043715
        secondFieldList = commutils.checkDuplicateFields(secondFieldList, strObjectName); //Added for the defect 043715
        String firstFieldString = commutils.SVMX_getFieldNamesFromList(lstFieldList);
        String secondFieldString = commutils.SVMX_getFieldNamesFromList(secondFieldList);
        String Query1 = 'select ' +firstFieldString+ ' from ' + strObjectName;
        String Query2 = 'select ' +secondFieldString+ ' from ' + strObjectName;
        
        if(strIDs != null && strIDs.length() > 0){
            Query1 += ' where ID in (' + strIDs.substring(0, strIDs.length()-1)+') And ( ' + strWhereClause +' )';
            Query2 += ' where ID in (' + strIDs.substring(0, strIDs.length()-1)+') And ( ' + strWhereClause +' )';
            
            if(strSortingClause != null && strSortingClause.length() > 0){
                Query1 += ' Order By '+strSortingClause;
                Query2 += ' Order By '+strSortingClause;
            }else if(!String.isBlank(nameField)){//Added by Nidhi as part of Lazy Loading BAC-4680, Default order by Name.
                Query1 += ' Order By '+nameField;
                Query2 += ' Order By '+nameField;
            }
        }
        //Added by Nidhi as part of Lazy Loading BAC-4680
        if(!String.isBlank(batchsize) && Integer.valueOf(batchsize)>0 && isDetailRecordQuery){
            Query1 += ' Limit '+ batchsize+' OFFSET 0';
            Query2 += ' Limit '+ batchsize+' OFFSET 0';
        }        
        System.debug('ParseExp-Query1: '+Query1);
        System.debug('ParseExp-Query2: '+Query2);
        
        if(lstFieldList.size() > 0){
            mapIdRecord1 = new Map<Id,Sobject>(Database.query(Query1));
            System.debug('ParseExp-FirstMapRecord: '+mapIdRecord1);
        }
        
        if(secondFieldList.size() > 0){
            mapIdRecord2 = new Map<Id,Sobject>(Database.query(Query2));
            System.debug('ParseExp-SecondMapRecord: '+mapIdRecord2);
        }
        
        for(Id idd: mapIdRecord1.keyset()){
            Map<String,Object> mapFieldAndValueOfRecord1 = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(mapIdRecord1.get(idd)));
            if(mapIdRecord2.containsKey(idd) && mapIdRecord2.get(idd) != null){
                Map<String,Object> mapFieldAndValueOfRecord2 = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(mapIdRecord2.get(idd)));
                for(String key : mapFieldAndValueOfRecord2.keyset()){
                    mapFieldAndValueOfRecord1.put(key, mapFieldAndValueOfRecord2.get(key));
                }                
            }
            Sobject resultSobject = (Sobject)JSON.deserialize(JSON.serialize(mapFieldAndValueOfRecord1), Sobject.class);
            SobjectList.add(resultSobject);
            System.debug('ParseExp-ResultSobject: '+resultSobject);
        }
        System.debug('ParseExp-FullSobjectList: '+SobjectList);
        return SobjectList;
    }

    /*  //--------START-----This is introduced as part of story BAC-2993-----//
        This method is a combination of the below methods
        Class : SFM_BuildSobject
        Method Name: SFM_buildSourceRecords, SFM_buildSourceRecordsWithSorting

        Class : SFM_ParseExpression
        Method Name: SFM_ParseExpression1

        Above methods are used in the getPageData call of SFM Delivery and as a result we were increasing soql query count and processing also
        This new method does the same thing with optimized code. Going forward we can use this method to get list of Sobject.
    */
     public List<Sobject> SFM_GetRecordsAfterApplyingCriteria(String strRecordID, String strObjName, String strParentColumnName, String strWhereClause, String strQueryField, String strSortingClause){
        try{
            System.debug('Called SFM_GetRecordsAfterApplyingCriteria');
            List<SObject> lstQualifiedRecords = new List<SObject>();
            String strQuery = '';

            if(!String.isBlank(strObjName) && !String.isBlank(strRecordID)){
                //#optiChange starts
                map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
                if(SFM_GetData.allObjMap != null && SFM_GetData.allObjMap.size() > 0){ 
                    allobjmap = SFM_GetData.allObjMap; 
                } 
                /*if(allobjmap.containskey(strObjName) && String.isBlank(strQueryField)){
                    Map<String, Schema.SObjectField> fieldMap = allobjmap.get(strObjName).getDescribe().fields.getMap();
                    List<String> fieldList = new List<String>();
                    if(fieldMap.size() > 0)
                        fieldList = commutils.SVMX_getFieldList(fieldMap,true);
                    fieldList = commutils.checkDuplicateFields(fieldList, strObjName); //Added for the defect 043715
                    
                    //------Start-------Added for the story BAC-4264
                    if(calledFromWhere == 'SFM_ParseProcess'){
                        if(!mapObjectNameVsListOfFields.containsKey(strObjName)){
                            mapObjectNameVsListOfFields.put(strObjName, new Set<String>());
                        }
                        mapObjectNameVsListOfFields.get(strObjName).addAll(fieldList);
                    }
                    //------End-------Added for the story BAC-4264
                    if(fieldList.size() > 0)
                        strQueryField = commutils.SVMX_getFieldNamesFromList(fieldList);
                }*/
                if(String.isBlank(strQueryField)){
                    Map<String, Schema.SObjectField> fieldMap;
                    if(allobjmap.containskey(strObjName))
                        fieldMap = allobjmap.get(strObjName).getDescribe().fields.getMap();
                    else
                        fieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(strObjName); 
                //#optiChange ends
                    List<String> fieldList = new List<String>();
                    if(fieldMap != NULL && fieldMap.size() > 0) // #optiChange
                        fieldList = commutils.SVMX_getFieldList(fieldMap,true);
                    fieldList = commutils.checkDuplicateFields(fieldList, strObjName); //Added for the defect 043715
                    //------Start-------Added for the story BAC-4264
                    if(calledFromWhere == 'SFM_ParseProcess'){
                        if(!mapObjectNameVsListOfFields.containsKey(strObjName)){
                            mapObjectNameVsListOfFields.put(strObjName, new Set<String>());
                        }
                        mapObjectNameVsListOfFields.get(strObjName).addAll(fieldList);
                    }
                    //------End-------Added for the story BAC-4264

                   

                    if(fieldList.size() > 0)
                        strQueryField = commutils.SVMX_getFieldNamesFromList(fieldList);
                }
                //----Start----Added for the defect 043715
                else{
                    if(!String.isBlank(strQueryField)){
                        List<String> lstFieldList = strQueryField.split(',');
                        
                        //-------Start------Added for the story BAC-5372
                        if(isQueryRecordTypeId && !lstFieldList.contains('RecordTypeId') && allobjmap.containskey(strObjName)){
                            if(setObjectHasRecordType.contains(strObjName)){
                                lstFieldList.add('RecordTypeId');
                                System.debug('RecordTypeId added in the query - No Describe');
                            }
                            else{
                                Map<String,Schema.SObjectField> mapFieldDesc = allobjmap.get(strObjName).getDescribe().fields.getMap();
                                if(mapFieldDesc.containsKey('RecordTypeId')){
                                    setObjectHasRecordType.add(strObjName);
                                    lstFieldList.add('RecordTypeId');
                                    System.debug('RecordTypeId added in the query - Describe');
                                }
                            }
                        }
                        //-------End--------Added for the story BAC-5372
                        
                        lstFieldList = commutils.checkDuplicateFields(lstFieldList, strObjName);
                        
                        //------Start-------Added for the story BAC-4264
                        if(calledFromWhere == 'SFM_ParseProcess'){
                            if(!mapObjectNameVsListOfFields.containsKey(strObjName)){
                                mapObjectNameVsListOfFields.put(strObjName, new Set<String>());
                            }
                            mapObjectNameVsListOfFields.get(strObjName).addAll(lstFieldList);
                        }
                        //------End-------Added for the story BAC-4264

                        strQueryField = commutils.SVMX_getFieldNamesFromList(lstFieldList);
                    }
                }
                //----End----Added for the defect 043715
                
                strQuery = 'SELECT '+strQueryField+' FROM '+strObjName;

                if(!String.isBlank(strParentColumnName)){
                    strQuery += ' WHERE '+strParentColumnName+ ' =: strRecordID ';
                }else{
                    strQuery += ' WHERE Id =: strRecordID ';
                }
                if(!String.isBlank(strWhereClause)){
                    strQuery += ' AND ('+strWhereClause+') ';
                }
                if(!String.isBlank(strSortingClause)){
                    strQuery += ' Order By '+strSortingClause;
                }
            }
            System.debug(LoggingLevel.INFO, 'strQuery: '+strQuery);
            System.debug(LoggingLevel.INFO, 'strObjName: '+strObjName+ ', strWhereClause: '+strWhereClause+ ', strParentColumnName: '+strParentColumnName);
            System.debug(LoggingLevel.INFO, 'strQueryField: '+strQueryField+ ', strSortingClause: '+strSortingClause);

            if(!String.isBlank(strQuery)){
                lstQualifiedRecords = Database.query(strQuery);
            } 
            return lstQualifiedRecords;
        }
        catch(Exception ex){
            System.debug('Exception in method SFM_GetRecordsAfterApplyingCriteria: '+ex.getMessage());
            System.debug('Exception in method SFM_GetRecordsAfterApplyingCriteria stackTrace: '+ex.getStackTraceString());
            throw ex;
        }
    }
    //--------END----------//
    
    public List<Sobject> SFM_GetRecordsAfterApplyingCriteria1(String strRecordID, String strObjName, String strParentColumnName, String strWhereClause, String strQueryField, String strSortingClause, Boolean isChildObjectQuery){
        try{
            System.debug('Called SFM_GetRecordsAfterApplyingCriteria1');
            List<SObject> lstQualifiedRecords = new List<SObject>();
            String strQuery = '';
            Boolean isLazyLoadingEnabled = false;
            
            if(SFMDeliveryServiceImpl.detailRecBatchSize != null && SFMDeliveryServiceImpl.detailRecBatchSize > 0){
                isLazyLoadingEnabled = true;
            }

            if(!String.isBlank(strObjName) && !String.isBlank(strRecordID)){
                //#optiChange starts
                map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
                if(SFM_GetData.allObjMap != null && SFM_GetData.allObjMap.size() > 0){ 
                    allobjmap = SFM_GetData.allObjMap; 
                } 
               /* if(allobjmap.containskey(strObjName) && String.isBlank(strQueryField)){
                    Map<String, Schema.SObjectField> fieldMap = allobjmap.get(strObjName).getDescribe().fields.getMap();
                    List<String> fieldList = new List<String>();
                    if(fieldMap.size() > 0)
                        fieldList = commutils.SVMX_getFieldList(fieldMap,true);
                    fieldList = commutils.checkDuplicateFields(fieldList, strObjName); //Added for the defect 043715
                    //------Start-------Added for the story BAC-4264
                    if(calledFromWhere == 'SFM_ParseProcess'){
                        if(!mapObjectNameVsListOfFields.containsKey(strObjName)){
                            mapObjectNameVsListOfFields.put(strObjName, new Set<String>());
                        }
                        mapObjectNameVsListOfFields.get(strObjName).addAll(fieldList);
                    }
                    //------End-------Added for the story BAC-4264
                    if(fieldList.size() > 0)
                        strQueryField = commutils.SVMX_getFieldNamesFromList(fieldList);
                }*/
                if(String.isBlank(strQueryField)){
                    Map<String, Schema.SObjectField> fieldMap;
                    if(allobjmap.containskey(strObjName))
                        fieldMap = allobjmap.get(strObjName).getDescribe().fields.getMap();
                    else
                        fieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(strObjName); 
                //#optiChange ends
                    List<String> fieldList = new List<String>();
                    if(fieldMap != NULL && fieldMap.size() > 0) // #optiChange
                        fieldList = commutils.SVMX_getFieldList(fieldMap,true);
                    fieldList = commutils.checkDuplicateFields(fieldList, strObjName); //Added for the defect 043715
                    //------Start-------Added for the story BAC-4264
                    if(calledFromWhere == 'SFM_ParseProcess'){
                        if(!mapObjectNameVsListOfFields.containsKey(strObjName)){
                            mapObjectNameVsListOfFields.put(strObjName, new Set<String>());
                        }
                        mapObjectNameVsListOfFields.get(strObjName).addAll(fieldList);
                    }
                    //------End-------Added for the story BAC-4264

                    if(fieldList.size() > 0)
                        strQueryField = commutils.SVMX_getFieldNamesFromList(fieldList);
                }
                //----Start----Added for the defect 043715
                else{
                    if(!String.isBlank(strQueryField)){
                        List<String> lstFieldList = strQueryField.split(',');
                        
                        //-------Start------Added for the story BAC-5372
                        if(isQueryRecordTypeId && !lstFieldList.contains('RecordTypeId') && allobjmap.containskey(strObjName)){
                            if(setObjectHasRecordType.contains(strObjName)){
                                lstFieldList.add('RecordTypeId');
                                System.debug('RecordTypeId added in the query - No Describe');
                            }
                            else{
                                Map<String,Schema.SObjectField> mapFieldDesc = allobjmap.get(strObjName).getDescribe().fields.getMap();
                                if(mapFieldDesc.containsKey('RecordTypeId')){
                                    setObjectHasRecordType.add(strObjName);
                                    lstFieldList.add('RecordTypeId');
                                    System.debug('RecordTypeId added in the query - Describe');
                                }
                            }
                        }
                        //-------End--------Added for the story BAC-5372
                        
                        lstFieldList = commutils.checkDuplicateFields(lstFieldList, strObjName);
                        
                        //------Start-------Added for the story BAC-4264
                        if(calledFromWhere == 'SFM_ParseProcess'){
                            if(!mapObjectNameVsListOfFields.containsKey(strObjName)){
                                mapObjectNameVsListOfFields.put(strObjName, new Set<String>());
                            }
                            mapObjectNameVsListOfFields.get(strObjName).addAll(lstFieldList);
                        }
                        //------End-------Added for the story BAC-4264

                        strQueryField = commutils.SVMX_getFieldNamesFromList(lstFieldList);
                    }
                }
                //----End----Added for the defect 043715
                
                strQuery = 'SELECT '+strQueryField+' FROM '+strObjName;

                if(!String.isBlank(strParentColumnName)){
                    strQuery += ' WHERE '+strParentColumnName+ ' =: strRecordID ';
                }else{
                    strQuery += ' WHERE Id =: strRecordID ';
                }
                if(!String.isBlank(strWhereClause)){
                    strQuery += ' AND ('+strWhereClause+') ';
                }
                
                if(!String.isBlank(strSortingClause) && strSortingClause.length() > 0){
                    strQuery += ' Order By '+strSortingClause;
                }else if(isLazyLoadingEnabled && !String.isBlank(nameField) && nameField.length() > 0){
                    strQuery += ' Order By '+nameField;
                }
                
                if(isLazyLoadingEnabled && isChildObjectQuery){
                    strQuery += ' Limit '+ batchsize +' OFFSET 0 ';
                }
            }
            System.debug(LoggingLevel.INFO, 'strQuery: '+strQuery);
            System.debug(LoggingLevel.INFO, 'strObjName: '+strObjName+ ', strWhereClause: '+strWhereClause+ ', strParentColumnName: '+strParentColumnName);
            System.debug(LoggingLevel.INFO, 'strQueryField: '+strQueryField+ ', strSortingClause: '+strSortingClause);

            if(!String.isBlank(strQuery)){
                lstQualifiedRecords = Database.query(strQuery);
            } 
            return lstQualifiedRecords;
        }
        catch(Exception ex){
            System.debug('Exception in method SFM_GetRecordsAfterApplyingCriteria1: '+ex.getMessage());
            System.debug('Exception in method SFM_GetRecordsAfterApplyingCriteria1 stackTrace: '+ex.getStackTraceString());
            throw ex;
        }
    }
    
    public list<SObject> SFM_ParseExpression(List<SObject> lstRecs,SFM_WrapperDef.SFM_Expression expInfo){
        return SFM_ParseExpression1(lstRecs,expInfo,null,null);
    }
    
    public list<Sobject> SFM_ParseExpression1(List<SObject> lstRecs,SFM_WrapperDef.SFM_Expression expInfo,String strObjectNameParam, String strWhereclauseParam){
        return SFM_ParseExpression1(lstRecs,expInfo,strObjectNameParam,strWhereclauseParam,null);
    }
    
    public list<Sobject> SFM_ParseExpression1(List<SObject> lstRecs,SFM_WrapperDef.SFM_Expression expInfo,String strObjectNameParam, String strWhereclauseParam, String strQueryField){
        return SFM_ParseExpression1(lstRecs, expInfo, strObjectNameParam, strWhereclauseParam, strQueryField, null);
    }
}