public with sharing class InstalledBaseTreeUtils {

    public void InstalledBaseTreeUtils(){
        
    }
   public Object saveConfiguredColumnsForIB(String request){
    AbstractResponse response = new AbstractResponse();
     
    try{
        ConfiguredFields newConfiguredFields = 
                            (ConfiguredFields)JSON.deserialize(request, ConfiguredFields.class);
        String userId = UserInfo.getUserId();
        SVMXC__SM_User_Preferences__c userPreference = new SVMXC__SM_User_Preferences__c();
        //In the following query, type filter added by Nidhi as part of defect BAC-5582
        List<SVMXC__SM_User_Preferences__c> userPreferenceList = [select Id, SVMXC__SM_Type__c, SVMXC__SM_Configured_Columns__c from SVMXC__SM_User_Preferences__c where SVMXC__SM_User_Reference_Id__c=:userId And SVMXC__SM_Type__c = 'IBTreeWeb']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(!userPreferenceList.isEmpty()){
                SVMXC__SM_User_Preferences__c userPreferenceRecord = userPreferenceList[0];
                
                List<ConfiguredFields> columnsFieldList = 
                            (List<ConfiguredFields>)JSON.deserialize(userPreferenceRecord.SVMXC__SM_Configured_Columns__c, List<ConfiguredFields>.class);
                Integer index = 0;
                for(ConfiguredFields columnsField:columnsFieldList){
                    if(columnsField.objectName.equals(newConfiguredFields.objectName)){
                        columnsFieldList.remove(index);
                        
                        break;
                    }
                    index++;
                    
                }
                Set<String> objectFields;
                if(newConfiguredFields.objectName.equals('IB')) {
                    objectFields = Schema.SObjectType.SVMXC__Installed_Product__c.fields.getMap().keySet();
                } else {
                    objectFields = Schema.SObjectType.SVMXC__Site__c.fields.getMap().keySet();
                }
                String noColumnsMsg = '';
                Boolean noColumns = false; 
                for(ColumnObject columnToDisplay:newConfiguredFields.columnsToDisplay){
                    if(!objectFields.contains(columnToDisplay.fieldName.toLowerCase())) {
                        if(!noColumnsMsg.equals('')) noColumnsMsg += ', ';
                        noColumnsMsg = noColumnsMsg + columnToDisplay.fieldLabel; 
                        noColumns = true;
                    }
                }
                if(noColumns) {
                    String errorMsg = system.Label.PRODIQ001_TAG214 + ': ' + noColumnsMsg;
                    response.status = false;
                    response.message = errorMsg;
                    return response;
                }
                columnsFieldList.add(newConfiguredFields);
                String configuredFieldJSON =  JSON.serialize(columnsFieldList);                     
                userPreference.Id = userPreferenceRecord.Id;
                userPreference.SVMXC__SM_Configured_Columns__c = configuredFieldJSON;


            }else{

                List<ConfiguredFields> newColumnsFieldList = new List<ConfiguredFields>();
                newColumnsFieldList.add(newConfiguredFields);
                userPreference.SVMXC__SM_User_Reference_Id__c = userId;
                userPreference.SVMXC__SM_Configured_Columns__c = JSON.serialize(newColumnsFieldList);
                
            }
        userPreference.SVMXC__SM_Type__c = 'IBTreeWeb';
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(userPreference, COMM_SecurityUtils.Access.Upsertable)){
                    upsert userPreference; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
        return userPreference;
        }catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));    
            response.status = false;
            response.message = ex.getMessage();
            return response;
        }
   }
   public Object getTreeViewData(String requestString){
        AbstractResponse response = new AbstractResponse();
        try{
            Map<String, Object> request = (Map<String, Object>)JSON.deserializeUntyped(requestString);
            String ibId = (String)request.get('recordId');
            Boolean reload = (Boolean)request.get('reload');
            IbTreeData ibTreeData = new IbTreeData(); 
            List<Map<String, String>> treeViewList = new List<Map<String, String>>();
            String topLevelIb ;
            String topLocationId;
            SVMXC__Installed_Product__c topLevelRecord = null;
            List<Map<String, String>> ibTreeList = new List<Map<String, String>>();
            List<Map<String, String>> siteTreeList = new List<Map<String, String>>();
            List<SVMXC__Installed_Product__c> ibList = [select Id,Name,SVMXC__Top_Level__c,SVMXC__Company__c,SVMXC__Company__r.Name,SVMXC__Site__c,SVMXC__Parent__c from SVMXC__Installed_Product__c where Id =: ibId];            
            if(!ibList.isEmpty()){
                SVMXC__Installed_Product__c ibRecord = ibList[0]; 
                IBsAccount ibAcount = new IBsAccount();
                Boolean isValid = true;
                Boolean noAccount = false;
                if(ibRecord.SVMXC__Top_Level__c != null){
                    topLevelIb = ibRecord.SVMXC__Top_Level__c;
                    List<String> queryFields = new List<String>{'SVMXC__Company__c','SVMXC__Site__c'};
                             if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Installed_Product__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                             }
                    List<SVMXC__Installed_Product__c> topLevelList = [select SVMXC__Company__c,SVMXC__Site__c from SVMXC__Installed_Product__c where Id =: topLevelIb]; 
                    if(!topLevelList.isEmpty()) {
                        topLevelRecord = topLevelList[0];
                    }
                } else {
                    topLevelIb = ibId;
                    topLevelRecord = ibRecord;
                }
                if(ibRecord.SVMXC__Company__c == null && ibRecord.SVMXC__Site__c == null) {
                    //account and location is null
                    noAccount = true;
                    isValid = false;
                } else if(ibRecord.SVMXC__Top_Level__c != null && ibRecord.SVMXC__Parent__c == null) {
                    //selected IB's parent is null and toplevel is not null
                    isValid = false;
                } else if(ibRecord.SVMXC__Top_Level__c == null && ibRecord.SVMXC__Parent__c != null) {
                    //selected IB's parent is not null and toplevel is null
                    isValid = false;
                } else if(topLevelRecord != null && ibRecord.SVMXC__Site__c!= null && !ibRecord.SVMXC__Site__c.equals(topLevelRecord.SVMXC__Site__c)) {
                    //toplevel is not null, Selected IB's location is not null, IB and toplevel location are different
                    isValid = false;
                } else if(topLevelRecord != null && ibRecord.SVMXC__Company__c != null && !ibRecord.SVMXC__Company__c.equals(topLevelRecord.SVMXC__Company__c)) {
                    //toplevel is not null, Selected IB's account is not null, IB and toplevel account are different
                    isValid = false;
                } else if(ibRecord.SVMXC__Company__c == null && ibRecord.SVMXC__Site__c != null && topLevelRecord != null) {
                    //IB account is null, location is there
                     List<String> queryFields = new List<String>{'Id', 'SVMXC__Account__c','SVMXC__Account__r.Name'};
                             if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                             }
                    List<SVMXC__Site__c> siteList = [select Id, SVMXC__Account__c,SVMXC__Account__r.Name from SVMXC__Site__c where Id =:topLevelRecord.SVMXC__Site__c];
                    if(!siteList.isEmpty()){
                        SVMXC__Site__c siteRecord = siteList[0];
                        if(siteRecord.SVMXC__Account__c == null) {
                            isValid = false;
                        } else {
                            ibAcount.accountName = siteRecord.SVMXC__Account__r.Name;
                            ibAcount.accountId = siteRecord.SVMXC__Account__c;
                            siteTreeList = getLocationDetails(siteRecord.SVMXC__Account__c, siteRecord.Id,null, siteRecord.Id);
                        }
                    } else {
                        isValid = false;
                    }
                } else if(ibRecord.SVMXC__Site__c == null) {
                    if(topLevelRecord != null && topLevelRecord.SVMXC__Site__c != null){
                        //IB location is null && top level site is not null
                        ibAcount.accountName = ibRecord.SVMXC__Company__r.Name;
                        ibAcount.accountId = ibRecord.SVMXC__Company__c;
                        siteTreeList = getLocationDetails(ibRecord.SVMXC__Company__c, topLevelRecord.SVMXC__Site__c,null,null);
                    } else if(ibRecord.SVMXC__Company__c != null){
                        // if Account is not null
                        ibAcount.accountName = ibRecord.SVMXC__Company__r.Name;
                        ibAcount.accountId = ibRecord.SVMXC__Company__c;
                    } else {
                        isValid = false;
                    }
                } else if(topLevelRecord != null && topLevelRecord.SVMXC__Company__c == null && topLevelRecord.SVMXC__Site__c != null) {
                    //toplevel account is null, toplevel location is there
                    ibAcount.accountName = ibRecord.SVMXC__Company__r.Name;
                    ibAcount.accountId = ibRecord.SVMXC__Company__c;
                    siteTreeList = getLocationDetails(ibRecord.SVMXC__Company__c, topLevelRecord.SVMXC__Site__c,null,topLevelRecord.SVMXC__Site__c);
                } else {
                    ibAcount.accountName = ibRecord.SVMXC__Company__r.Name;
                    ibAcount.accountId = ibRecord.SVMXC__Company__c;
                    siteTreeList = getLocationDetails(ibRecord.SVMXC__Company__c, ibRecord.SVMXC__Site__c,null,ibRecord.SVMXC__Site__c);
                }
                if(siteTreeList == null) {
                    isValid = false;
                }
                ibTreeList = getIbDetails(topLevelRecord, ibAcount.accountId,ibId);
                if(ibTreeList == null) {
                    isValid = false;
                }
                if(isValid) {
                    if(!siteTreeList.isEmpty()){
                        treeViewList.addAll(siteTreeList);
                    }
                    if(!ibTreeList.isEmpty()) treeViewList.addAll(ibTreeList);
                    
                    ibAcount.ibId = ibList[0].Id;
                    ibAcount.ibName = ibList[0].Name;
                    ibAcount.childrenCount = getAccountChildrenCount(ibAcount.accountId);
                    ibTreeData.ibTree = treeViewList;
                    ibTreeData.ibAccount = ibAcount;
                    return ibTreeData;
                } else {
                    response.status = false;
                    if(noAccount){
                        response.message = system.Label.PRODIQ001_TAG119;
                    } else {
                        response.message = system.Label.FSA017_TAG027;
                    }
                    return response;
                }
            }else{
                response.status = false;
                response.message = system.Label.PRODIQ001_TAG119;
                return response;
            }
        }catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));    
            response.status = false;
            response.message = ex.getMessage();
            return response;
        }
    }
    public Object getLocationTreeViewData(String requestString) {
        AbstractResponse response = new AbstractResponse();
        try{
            Map<String, Object> request = (Map<String, Object>)JSON.deserializeUntyped(requestString);
            String locId = (String)request.get('recordId');
            Boolean reload = (Boolean)request.get('reload');
            IbTreeData ibTreeData = new IbTreeData(); 
            List<Map<String, String>> treeViewList = new List<Map<String, String>>();
            List<Map<String, String>> ibTreeList = new List<Map<String, String>>();
            List<Map<String, String>> siteTreeList = new List<Map<String, String>>();
            List<SVMXC__Site__c> siteList = [select Id,Name,SVMXC__Account__c,SVMXC__Account__r.Name,SVMXC__Parent__c from SVMXC__Site__c where Id =:locId];
            if(!siteList.isEmpty()){
                SVMXC__Site__c siteRecord = siteList[0];
                Boolean isValid = true;
                IBsAccount ibAcount = new IBsAccount();
                if(siteRecord.SVMXC__Account__c == null ) {
                    isValid = false;
                } else {
                    ibAcount.accountName = siteRecord.SVMXC__Account__r.Name;
                    ibAcount.accountId = siteRecord.SVMXC__Account__c;
                    List<DefaultFieldObject> configuredFieldList = getDefaultConfiguredFields(false, 'SITE');
                    siteTreeList = getLocationDetails(siteRecord.SVMXC__Account__c, siteRecord.Id,configuredFieldList,siteRecord.SVMXC__Parent__c);
                }
                if(isValid) {
                    if(siteTreeList == null) {
                        response.status = false;
                        response.message = system.Label.FSA017_TAG027;
                        return response;
                    }
                    if(!siteTreeList.isEmpty()){
                        treeViewList.addAll(siteTreeList);
                    }
                    ibAcount.ibId = siteRecord.Id;
                    ibAcount.ibName = siteRecord.Name;
                    ibAcount.childrenCount = getAccountChildrenCount(ibAcount.accountId);
                    ibTreeData.ibTree = treeViewList;
                    ibTreeData.ibAccount = ibAcount;
                    return ibTreeData;
                } else {
                    response.status = false;
                    response.message = system.Label.PRODIQ001_TAG119;
                    return response;
                }            
            }else{
                response.status = false;
                response.message = system.Label.PRODIQ001_TAG119;
                return response;
            }
        }catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));    
            response.status = false;
            response.message = ex.getMessage();
            return response;
        }
    }

    private List<Map<String, String>> getLocationDetails(String accountId, String siteId,List<DefaultFieldObject> configuredFieldList, String parentId){
        Boolean siteAvailable = false;

        IbFieldObject ibFieldObject = getQueryFiledsForSite(configuredFieldList);
        String queryFields = ibFieldObject.queryFields;
        List<String> fieldNameList = ibFieldObject.fieldNameList;
        Map<String, String> fieldTypeMap = ibFieldObject.fieldTypeMap;
        
        String parentSiteId = siteId;
        List<String> tempQueryFields = queryFields.split(',');
         
                            List<String> varifyQueryFields = new List<String>{'SVMXC__Parent__r.Name','SVMXC__Account__r.Name'};
                             varifyQueryFields.addAll(tempQueryFields);
                             system.debug(' location queryFields 1'+varifyQueryFields.size());
                             for (Integer i = (varifyQueryFields.size()-1) ; i>= 0 ; i--){
                                    String stringItem = varifyQueryFields[i];
                                    if(stringItem.contains('CreatedById') || stringItem.contains('CreatedBy.Name') || stringItem.contains('LastModifiedById')|| stringItem.contains('LastModifiedBy.Name') || stringItem.contains('OwnerId') || stringItem.contains('Owner.Name')){
                                        varifyQueryFields.remove(i);
                                    }
                                } 
                                system.debug(' location queryFields 2'+varifyQueryFields.size());
                             if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', varifyQueryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                             }
        List<SVMXC__Site__c> allSiteList = new List<SVMXC__Site__c>();
        //Defect fix : BAC-5065          
        queryFields = getQueryFieldForTranslation(queryFields); 
        do{
            SVMXC__Site__c siteRecord = Database.query('SELECT SVMXC__Parent__r.Name,SVMXC__Account__r.Name,' + queryFields +' from SVMXC__Site__c where Id =:parentSiteId');
            if(siteRecord != null) {
                if(siteRecord.SVMXC__Account__c != null && siteRecord.SVMXC__Account__c.equals(accountId)) {
                    siteAvailable = true;
                } else {
                    siteAvailable = false;
                    break;
                }
                allSiteList.add(siteRecord);
                //Map<String,String> siteMap = getSiteMap(fieldNameList,fieldTypeMap,siteRecord);
                //siteTreeList.add(siteMap);
                parentSiteId = siteRecord.SVMXC__Parent__c;
            }
        }while(parentSiteId != null);
        List<Map<String, String>> siteTreeList  = validateSiteRecords(ibFieldObject, allSiteList,accountId);
        
        /*List<SVMXC__Site__c> siteList = Database.query('SELECT SVMXC__Parent__r.Name,SVMXC__Account__r.Name,' + queryFields +' from SVMXC__Site__c where (SVMXC__Parent__c =:parentId or SVMXC__Parent__c =:siteId) and SVMXC__Account__c=:accountId');

        for(SVMXC__Site__c siteRecord:siteList) {
            if(siteId != null && siteId.equals(siteRecord.Id)) {
                siteAvailable = true;
            }
            if(siteRecord.Id != null && siteRecord.Id.equals(siteId)) {
                continue;
            }
            Map<String,String> siteMap = getSiteMap(fieldNameList,fieldTypeMap,siteRecord);
            siteTreeList.add(siteMap);

        }*/
        if(siteId != null && !siteAvailable) siteTreeList = null;
        return siteTreeList;
    }
    private Map<String,String>  getSiteMap(List<String> fieldNameList,Map<String, String> fieldTypeMap,SVMXC__Site__c siteRecord, String accountId) {
        Map<String,String> siteMap = new Map<String,String> ();

        for(String fieldName : fieldNameList){
            String fieldValue;
            if(fieldName.contains('.Name'))
            {   
                fieldName = fieldName.replace('.Name','');
                String fieldApi = fieldName.replace('__r','__c'); 
                if(fieldApi.equals('CreatedBy') || fieldApi.equals('LastModifiedBy') || fieldApi.equals('Owner') || fieldApi.equals('RecordType')){
                    fieldApi = fieldApi+'Id';
                    } 

                    if(siteRecord.get(fieldApi) != null){
                    fieldValue = String.valueOf(siteRecord.getsObject(fieldName).get('Name'));
                    }

                fieldName=fieldName.replace('__r','__c');  
                if(fieldApi.equals('CreatedById') || fieldApi.equals('LastModifiedById') || fieldApi.equals('OwnerId') || fieldApi.equals('RecordTypeId')){
                    fieldName = fieldApi;
                }                            
            }
            else 
            {   
                if(siteRecord.get(fieldName) != null)
                fieldValue = String.valueOf(siteRecord.get(fieldName));                                                                
            }
                    
            String fieldType = fieldTypeMap.get(fieldName);
            if(fieldType != null && fieldType.equals('DATETIME') && siteRecord.get(fieldName) != null) {
                DATETIME gmtDateTime = (DATETIME)siteRecord.get(fieldName);
                fieldValue = String.valueOf(gmtDateTime.format('YYYY-MM-dd HH:mm:ss',UserInfo.getTimeZone().getID()));
            }
            siteMap.put(fieldName, fieldValue);                            
        }
        siteMap.put('parentNodeId', siteRecord.SVMXC__Parent__c);
        siteMap.put('objectName', 'SVMXC__Site__c');
        Integer childrenCount = getChildrenCount(siteRecord.Id,'site', accountId);
        siteMap.put('childrenCount',string.valueof(childrenCount));
        if(!String.isBlank(siteRecord.SVMXC__Parent__r.Name))siteMap.put('SVMXC__Parent__c', siteRecord.SVMXC__Parent__r.Name);
        if(!String.isBlank(siteRecord.SVMXC__Account__r.Name))siteMap.put('SVMXC__Account__c', siteRecord.SVMXC__Account__r.Name);
        return siteMap;
    }

    public List<Map<String, String>> getIbDetails(SVMXC__Installed_Product__c topLevelRecord, String accountId, String ibId){ 
                    List<DefaultFieldObject> configuredFieldList = getDefaultConfiguredFields(false, 'IB');
                    IbFieldObject ibFieldObject = getQueryFiledsForIb(configuredFieldList);
                    String queryFields = ibFieldObject.queryFields;
                    List<String> fieldNameList = ibFieldObject.fieldNameList;
                    Map<String, String> fieldTypeMap = ibFieldObject.fieldTypeMap;


                    List<SVMXC__Installed_Product__c> allIbList = new  List<SVMXC__Installed_Product__c>();
                    String parentIb = ibId; // Initially self record.
                    Boolean pathFailed = false;
                            List<String> tempQueryFieldsAll = queryFields.split(',');
                            List<String> varifyQueryFieldsAll = new List<String>{'SVMXC__Parent__r.Name' , 'SVMXC__Site__r.Name', 'SVMXC__Company__r.Name', 'SVMXC__Top_Level__r.Name'};
                             varifyQueryFieldsAll.addAll(tempQueryFieldsAll);
                             system.debug(' IB queryFields 1'+varifyQueryFieldsAll.size());
                             for (Integer i = (varifyQueryFieldsAll.size()-1) ; i>= 0 ; i--){
                                    String stringItem = varifyQueryFieldsAll[i];
                                    if(stringItem.contains('CreatedById') || stringItem.contains('CreatedBy.Name') || stringItem.contains('LastModifiedById')|| stringItem.contains('LastModifiedBy.Name') || stringItem.contains('OwnerId') || stringItem.contains('Owner.Name')){
                                        varifyQueryFieldsAll.remove(i);
                                    }
                                } 
                                system.debug(' IB queryFields 2'+varifyQueryFieldsAll.size());
                             if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Installed_Product__c', varifyQueryFieldsAll, COMM_SecurityUtils.Access.Accessible ) ) {
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                             }
                    //Defect fix : BAC-5065          
                    queryFields = getQueryFieldForTranslation(queryFields);         
                    do{
                        SVMXC__Installed_Product__c ibRecord = Database.query('SELECT SVMXC__Parent__r.Name , SVMXC__Site__r.Name, SVMXC__Company__r.Name, SVMXC__Top_Level__r.Name , ' + queryFields +' from SVMXC__Installed_Product__c where Id=:parentIb');
                         if(ibRecord.SVMXC__Parent__c != null && (ibRecord.SVMXC__Company__c == null || topLevelRecord.SVMXC__Company__c == null || ibRecord.SVMXC__Company__c.equals(topLevelRecord.SVMXC__Company__c))){
                            parentIb = ibRecord.SVMXC__Parent__c;
                        }else{
                            parentIb = null;
                            if(ibRecord.Id != topLevelRecord.Id) {
                                pathFailed = true;
                            }
                        }
                        allIbList.add(ibRecord);
                    }while(!String.isBlank(parentIb));
                    if(pathFailed) {
                        return null;
                    }
                    List<Map<String, String>> ibTreeList  = validateIbRecords(ibFieldObject, topLevelRecord, allIbList,accountId);
                return ibTreeList;  
    }

    private Map<String,String> getIBMap(List<String> fieldNameList,Map<String, String> fieldTypeMap,SVMXC__Installed_Product__c ibRecord, String accountId) {
        Map<String,String> ibMap = new Map<String,String>();
        for(String fieldName : fieldNameList){
            String fieldValue;
            if(fieldName.contains('.Name'))
            {   
                fieldName = fieldName.replace('.Name','');
                String fieldApi = fieldName.replace('__r','__c'); 
                if(fieldApi.equals('CreatedBy') || fieldApi.equals('LastModifiedBy') || fieldApi.equals('Owner') || fieldApi.equals('RecordType')){
                    fieldApi = fieldApi+'Id';
                    } 

                    if(ibRecord.get(fieldApi) != null){
                    fieldValue = String.valueOf(ibRecord.getsObject(fieldName).get('Name'));
                    }

                fieldName=fieldName.replace('__r','__c');  
                if(fieldApi.equals('CreatedById') || fieldApi.equals('LastModifiedById') || fieldApi.equals('OwnerId') || fieldApi.equals('RecordTypeId')){
                    fieldName = fieldApi;
                }                            
            }
            else 
            {   
                if(ibRecord.get(fieldName) != null)
                fieldValue = String.valueOf(ibRecord.get(fieldName));                                                                
            }
                    
                    String fieldType = fieldTypeMap.get(fieldName);
                    if(fieldType != null && fieldType.equals('DATETIME') && ibRecord.get(fieldName) != null) {
                        DATETIME gmtDateTime = (DATETIME)ibRecord.get(fieldName);
                        fieldValue = String.valueOf(gmtDateTime.format('YYYY-MM-dd HH:mm:ss',UserInfo.getTimeZone().getID()));
                    }
                    ibMap.put(fieldName, fieldValue);                            
        }
        if(!String.isBlank(ibRecord.SVMXC__Top_Level__r.Name))ibMap.put('SVMXC__Top_Level__c', ibRecord.SVMXC__Top_Level__r.Name);
        if(!String.isBlank(ibRecord.SVMXC__Parent__r.Name))ibMap.put('SVMXC__Parent__c', ibRecord.SVMXC__Parent__r.Name);
        if(!String.isBlank(ibRecord.SVMXC__Site__r.Name))ibMap.put('SVMXC__Site__c', ibRecord.SVMXC__Site__r.Name);
        if(!String.isBlank(ibRecord.SVMXC__Company__r.Name))ibMap.put('SVMXC__Company__c', ibRecord.SVMXC__Company__r.Name);
        ibMap.put('parentNodeId',String.valueOf(ibRecord.get('SVMXC__Parent__c')));
        if(String.isBlank(ibRecord.SVMXC__Parent__c)) ibMap.put('parentNodeId', ibRecord.SVMXC__Site__c);
        ibMap.put('objectName','SVMXC__Installed_Product__c');
        Integer childrenCount = getChildrenCount(ibRecord.Id,'SVMXC__Installed_Product__c', accountId);
        ibMap.put('childrenCount',string.valueof(childrenCount));
        ibMap.put('topLevelId', ibRecord.SVMXC__Top_Level__c);
        return ibMap;
    }
    private List<DefaultFieldObject> getDefaultConfiguredFields(Boolean reload, String objName){
        if(!(objName.equals('IB') || objName.equals('SITE'))) objName = 'IB';
        Boolean fieldsAvailable = false;
        List<DefaultFieldObject> defaultFields = new List<DefaultFieldObject>();
        String userId = UserInfo.getUserId();
        //In the following query, type filter added by Nidhi as part of defect BAC-5582
        List<SVMXC__SM_User_Preferences__c> userPreferenceList = [select Id, SVMXC__SM_Type__c, SVMXC__SM_Configured_Columns__c from SVMXC__SM_User_Preferences__c where SVMXC__SM_User_Reference_Id__c=:userId And SVMXC__SM_Type__c = 'IBTreeWeb']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(!userPreferenceList.isEmpty()){
            SVMXC__SM_User_Preferences__c userPreferenceRecord = userPreferenceList[0];
            List<ConfiguredFields> columnsFieldList = 
                            (List<ConfiguredFields>)JSON.deserialize(userPreferenceRecord.SVMXC__SM_Configured_Columns__c, List<ConfiguredFields>.class);
                for(ConfiguredFields columnsField:columnsFieldList){
                    if(columnsField.objectName.equals(objName)){
                        system.debug('objName:'+objName);
                        fieldsAvailable = true;
                        Set<String> objectFields;
                        if(objName.equals('IB')) {
                            objectFields = Schema.SObjectType.SVMXC__Installed_Product__c.fields.getMap().keySet();
                        } else {
                            objectFields = Schema.SObjectType.SVMXC__Site__c.fields.getMap().keySet();
                        }
                        List<ColumnObject> columnsToDisplayList = columnsField.columnsToDisplay;
                        List<ColumnObject> newColumnsToDisplayList = new List<ColumnObject>();
                        Boolean noColumns = false;
                        for(ColumnObject columnToDisplay:columnsToDisplayList){
                            if(!objectFields.contains(columnToDisplay.fieldName.toLowerCase()) && !reload) {
                                noColumns = true;
                                continue;
                            }
                            newColumnsToDisplayList.add(columnToDisplay);
                            DefaultFieldObject dField = new DefaultFieldObject();
                            dField.fieldName = columnToDisplay.fieldName;
                            dField.fieldLabel = columnToDisplay.fieldLabel;
                            dField.fieldType = columnToDisplay.fieldType;
                            dField.referenceTo = columnToDisplay.referenceTo;
                            dField.relationshipName = columnToDisplay.relationshipName;
                            defaultFields.add(dField);
                        }
                        if(noColumns) {
                            columnsField.columnsToDisplay = newColumnsToDisplayList;
                            saveConfiguredColumnsForIB(JSON.serialize(columnsField));
                        }
                    } 
                }

        }
        if(!fieldsAvailable) {
            if(objName.equals('IB')) {
                DefaultFieldObject dField1 = new DefaultFieldObject();
                dField1.fieldName = 'SVMXC__Product_Name__c';
                dField1.fieldLabel = 'Product Name';
                dField1.fieldType = 'STRING';

                DefaultFieldObject dField2 = new DefaultFieldObject();
                dField2.fieldName = 'SVMXC__Serial_Lot_Number__c';
                dField2.fieldLabel = 'Serial';
                dField2.fieldType = 'STRING';

                DefaultFieldObject dField3 = new DefaultFieldObject();
                dField3.fieldName = 'SVMXC__Status__c';
                dField3.fieldLabel = 'Status';
                dField3.fieldType = 'PICKLIST';

                DefaultFieldObject dField4 = new DefaultFieldObject();
                dField4.fieldName = 'SVMXC__Date_Installed__c';
                dField4.fieldLabel = 'Date Installed';
                dField4.fieldType = 'DATE';

                DefaultFieldObject dField5 = new DefaultFieldObject();
                dField5.fieldName = 'SVMXC__Installation_Notes__c';
                dField5.fieldLabel = 'Installation Notes';
                dField5.fieldType = 'TEXTAREA';
                
                defaultFields.add(dField1);
                defaultFields.add(dField2);
                defaultFields.add(dField3);
                defaultFields.add(dField4);
                defaultFields.add(dField5);
            } else {
                DefaultFieldObject dField1 = new DefaultFieldObject();
                dField1.fieldName = 'SVMXC__Street__c';
                dField1.fieldLabel = 'Street';
                dField1.fieldType = 'TEXTAREA';

                DefaultFieldObject dField2 = new DefaultFieldObject();
                dField2.fieldName = 'SVMXC__City__c';
                dField2.fieldLabel = 'City';
                dField2.fieldType = 'STRING';
                
                DefaultFieldObject dField3 = new DefaultFieldObject();
                dField3.fieldName = 'SVMXC__State__c';
                dField3.fieldLabel = 'State';
                dField3.fieldType = 'STRING';

                DefaultFieldObject dField4 = new DefaultFieldObject();
                dField4.fieldName = 'SVMXC__Country__c';
                dField4.fieldLabel = 'Country';
                dField4.fieldType = 'PICKLIST';

                DefaultFieldObject dField5 = new DefaultFieldObject();
                dField5.fieldName = 'SVMXC__Zip__c';
                dField5.fieldLabel = 'Zip';
                dField5.fieldType = 'STRING';

                defaultFields.add(dField1);
                defaultFields.add(dField2);
                defaultFields.add(dField3);
                defaultFields.add(dField4);
                defaultFields.add(dField5);
            }
        }

        return defaultFields;
    }

    public Object getMetadata(String objName){

        List<String> objectsfrdesc = new List<String>();
        objectsfrdesc.add('SVMXC__Installed_Product__c');
        objectsfrdesc.add('SVMXC__Site__c');
        GetSetupMetadataResponse metadataResponse = new GetSetupMetadataResponse();
        metadataResponse.setSForceObjectDescribes(getObjectDescribes(objectsfrdesc));
        metadataResponse.setdefaultFieldObject(getDefaultConfiguredFields(false,objName));
        metadataResponse.translations =  getTranslations();
        return metadataResponse; 
    }

    private Map<String,SForceObject> getObjectDescribes(List<String> objectNames) {
        
        Map<String,SForceObject> objectDescribeInfosMap = new Map<String,SForceObject>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(objectNames);
        for(Schema.DescribeSobjectResult res : results){
            SForceObject objectDescribeInfo = new SForceObject();
            String objectName = String.valueOf(res.getName());
            objectDescribeInfo.objectLabel = res.getLabel();
            objectDescribeInfo.objectAPIName = objectName;
            objectDescribeInfo.fields = getFields(res);
            objectDescribeInfosMap.put( objectName,objectDescribeInfo);
        }       
        return objectDescribeInfosMap;
    }

    private List<SForceField> getFields(Schema.DescribeSobjectResult objectDescribeRes) {
        
        List<SForceField> allFieldsInfo = new List<SForceField>();
        SForceField field = null;
        Map<String, Schema.SObjectField> objectFields = objectDescribeRes.fields.getMap();
        for (String fieldName : objectFields.keySet()) {
            field = new SForceField();
            Schema.DescribeFieldResult dfr = objectFields.get(fieldName).getDescribe();
            field.fieldName = dfr.getName();
            field.fieldLabel = dfr.getLabel();
            field.fieldType = string.valueof(dfr.getType());
            if(field.fieldType == 'REFERENCE'){              
                field.referenceTo = dfr.getReferenceTo()[0] + '';
            }
            field.relationshipName = dfr.getRelationshipName();
            allFieldsInfo.add(field);
        }    
        return allFieldsInfo;
    }
    private Map<String,String> picklistSet = new Map<String,String>();
    //Added below method to fix defect BAC-5065
    public String getQueryFieldForTranslation(String queryFields)
    {
        if(!String.isEmpty(queryFields))
        {
            String tempqueryFields = '';
            Set<String> setOfFields = new Set<String>();
            queryFields = queryFields.toUpperCase();
            
            for(String field:queryFields.split(','))
            {
                
                field = field.trim();
                if(picklistSet.containsKey(field))
                {
                    setOfFields.add(picklistSet.get(field));
                    
                }else
                {
                    setOfFields.add(field);
                }
            }
            List<String> lstOfFields = new List<String>();
            lstOfFields.addAll(setOfFields);
            tempqueryFields = String.join(lstOfFields,',');
            System.debug('tempqueryFields : '+tempqueryFields); 
            picklistSet.clear();
            return tempqueryFields;
         }
         picklistSet.clear();
         return queryFields;
    }
    public IbFieldObject getQueryFiledsForIb(List<DefaultFieldObject> configuredFieldList){
                    IbFieldObject ibFieldObject = new IbFieldObject();

                    String queryFields = 'Id, Name, SVMXC__Site__c, SVMXC__Parent__c,SVMXC__Top_Level__c';
                    List<String> fieldNameList = new List<String> ();
                    Map<String, String> fieldTypeMap = new Map<String, String> ();
                    fieldNameList.add('Id');
                    fieldTypeMap.put('Id','ID');
                    fieldNameList.add('Name');
                    fieldTypeMap.put('Name','STRING');
                    fieldNameList.add('SVMXC__Site__c');
                    fieldTypeMap.put('SVMXC__Site__c','REFERENCE');
                    fieldNameList.add('SVMXC__Parent__c');
                    fieldTypeMap.put('SVMXC__Parent__c','REFERENCE');
                    fieldNameList.add('SVMXC__Top_Level__c');
                    fieldTypeMap.put('SVMXC__Top_Level__c','REFERENCE');
                    fieldNameList.add('SVMXC__Company__c');
                    fieldTypeMap.put('SVMXC__Company__c','REFERENCE');
                    
                    if(configuredFieldList != null) {
                        for(DefaultFieldObject configuredField: configuredFieldList){

                            if(!configuredField.fieldName.equals('Id') && !configuredField.fieldName.equals('Name')  && !configuredField.fieldName.equals('SVMXC__Parent__c') && !configuredField.fieldName.equals('SVMXC__Site__c')
                                && !configuredField.fieldName.equals('SVMXC__Company__c') && !configuredField.fieldName.equals('SVMXC__Top_Level__c')){
                                String fName = configuredField.fieldName;
                                // Start: Adedd fix for :BAC-5065
                                queryFields += ',' + fName;
                                if(configuredField.fieldType == 'PICKLIST')
                                {
                                  picklistSet.put(fName.trim().toUpperCase(),'toLabel(' + fName + ')');
                                }
                                // End: Adedd fix for :BAC-5065
                                
                                if(configuredField.fieldType == 'REFERENCE'){
                                    fName = configuredField.relationshipName+'.Name';
                                    queryFields += ' , ' + fName;
                                }
                                
                                fieldNameList.add(fName);
                                fieldTypeMap.put(configuredField.fieldName,string.valueof(configuredField.fieldType));
                            }
                            
                        }
                    }
                    ibFieldObject.queryFields = queryFields;
                    ibFieldObject.fieldNameList = fieldNameList;
                    ibFieldObject.fieldTypeMap = fieldTypeMap;
                    return ibFieldObject;
    }
    public IbFieldObject getQueryFiledsForSite(List<DefaultFieldObject> configuredFieldList){
        IbFieldObject ibFieldObject = new IbFieldObject();
        String queryFields = 'Id, Name, SVMXC__Parent__c';
        List<String> fieldNameList = new List<String> ();
        Map<String, String> fieldTypeMap = new Map<String, String> ();
        fieldNameList.add('Id');
        fieldTypeMap.put('Id','ID');
        fieldNameList.add('Name');
        fieldTypeMap.put('Name','STRING');
        fieldNameList.add('SVMXC__Parent__c');
        fieldTypeMap.put('SVMXC__Parent__c','REFERENCE');
        fieldNameList.add('SVMXC__Account__c');
        fieldTypeMap.put('SVMXC__Account__c','REFERENCE');

        if(configuredFieldList != null) {
            for(DefaultFieldObject configuredField: configuredFieldList){

                if(!configuredField.fieldName.equals('Id') && !configuredField.fieldName.equals('Name')  && !configuredField.fieldName.equals('SVMXC__Parent__c')
                    && !configuredField.fieldName.equals('SVMXC__Account__c')){
                    String fName = configuredField.fieldName;
                    queryFields += ' , ' + fName;
                    //Fixed defect : 5065
                    if(configuredField.fieldType == 'PICKLIST')
                    {
                      picklistSet.put(fName.trim().toUpperCase(),'toLabel(' + fName + ')');
                    }
                    if(configuredField.fieldType == 'REFERENCE'){
                        fName = configuredField.relationshipName+'.Name';
                        queryFields += ' , ' + fName;
                    }
                    
                    fieldNameList.add(fName);
                    fieldTypeMap.put(configuredField.fieldName,string.valueof(configuredField.fieldType));
                }
                
            }
        }
        ibFieldObject.queryFields = queryFields;
        ibFieldObject.fieldNameList = fieldNameList;
        ibFieldObject.fieldTypeMap = fieldTypeMap;
        return ibFieldObject;
    }
    public List<Map<String, String>> validateIbRecords(IbFieldObject ibFieldObject,SVMXC__Installed_Product__c topLevelRecord, List<SVMXC__Installed_Product__c> allIbList,String accountId){
                    List<Map<String, String>> ibTreeList = new List<Map<String, String>>();
                    List<String> fieldNameList = ibFieldObject.fieldNameList;
                    Map<String, String> fieldTypeMap = ibFieldObject.fieldTypeMap;
                    for(SVMXC__Installed_Product__c ibRecord : allIbList){
                        if((topLevelRecord != null && topLevelRecord.SVMXC__Company__c != null && ibRecord.SVMXC__Company__c != null
                            && !topLevelRecord.SVMXC__Company__c.equals(ibRecord.SVMXC__Company__c)) || (ibRecord.SVMXC__Top_Level__c != null && ibRecord.SVMXC__Parent__c == null)) {
                            continue;
                        }
                        if(ibRecord.SVMXC__Site__c == null && ibRecord.SVMXC__Parent__c== null && ibRecord.SVMXC__Company__c == null) {
                            continue;
                        } else if(ibRecord.SVMXC__Company__c != null && !ibRecord.SVMXC__Company__c.equals(accountId)) {
                            continue;
                        }
                        Map<String,String> ibMap = getIBMap(fieldNameList,fieldTypeMap,ibRecord, accountId);
                        ibTreeList.add(ibMap);
                    }
                    return ibTreeList;

    }
    public List<Map<String, String>> validateSiteRecords(IbFieldObject ibFieldObject, List<SVMXC__Site__c> allSiteList, String accountId){
        List<Map<String, String>> siteTreeList = new List<Map<String, String>>();
        List<String> fieldNameList = ibFieldObject.fieldNameList;
        Map<String, String> fieldTypeMap = ibFieldObject.fieldTypeMap;
        for(SVMXC__Site__c siteRecord : allSiteList){
            Map<String,String> siteMap = getSiteMap(fieldNameList,fieldTypeMap,siteRecord, accountId);
            siteTreeList.add(siteMap);
        }
        return siteTreeList;
    }
    public Map<String, String> getTranslations() {
        Map<String, String> translations = new Map<String, String>();
        translations.put('AF', system.Label.IPRD004_TAG005);//'Available Fields'
        translations.put('SF', system.Label.IPRD004_TAG006);//'Selected Fields'
        translations.put ('SF_ERROR', system.Label.IPRD004_TAG022);//'Select at least one field'      
        translations.put('PARAMS_ERROR', system.Label.IPRD004_TAG019);//'Insufficient number of parameters provided to Technical Attributes. Please contact your ServiceMax administrator to resolve thisInsufficient number of parameters provided to IB Tree View. Please contact your ServiceMax administrator to resolve this.'
        translations.put('CANCEL', system.Label.PRODIQ001_TAG098);//'Cancel'
        translations.put('APPLY', system.Label.PRODIQ001_TAG176);//'Apply'
        translations.put('CC', system.Label.IPRD004_TAG017);//'Choose Columns'
        translations.put('LOADING',system.Label.IPRD004_TAG024);//loading
        translations.put('ERROR',system.Label.PRODIQ001_TAG057);//Error
        translations.put('MAX_LIMIT',system.Label.IPRD004_TAG025);//Maximum Limit of Expanded node is reached.
        return translations;
    }

    public Integer getChildrenCount(String parentId, String objType, String accountId){
      Integer count;
      if(objType.equals('SVMXC__Installed_Product__c')){
          count = [SELECT count() FROM SVMXC__Installed_Product__c WHERE SVMXC__Parent__c =:parentId AND (SVMXC__Company__c = null OR SVMXC__Company__c =: accountId)];
        }else{
          Integer ibCount = [SELECT count() FROM SVMXC__Installed_Product__c WHERE SVMXC__Site__c = :parentId AND SVMXC__Top_Level__c = null AND SVMXC__Parent__c = null AND (SVMXC__Company__c = null OR SVMXC__Company__c =: accountId)];
          Integer siteCount = [SELECT count() FROM SVMXC__Site__c WHERE SVMXC__Parent__c = :parentId AND SVMXC__Account__c =: accountId];
          count = ibCount + siteCount;
        }
        return count;
    }
    public Integer getAccountChildrenCount(String accountId){
        Integer ibCount = [SELECT count() FROM SVMXC__Installed_Product__c WHERE SVMXC__Site__c = null AND SVMXC__Top_Level__c = null AND SVMXC__Company__c =: accountId];
        Integer siteCount = [SELECT count() FROM SVMXC__Site__c WHERE SVMXC__Parent__c = null AND SVMXC__Account__c =: accountId];
        Integer count = ibCount + siteCount;
        return count;
    }

    public Object getChildren(String request){
        AbstractResponse response = new AbstractResponse();
        try{
                List<Map<String,String>> childrenList = new List<Map<String,String>>();
                LoadMoreNode nodeItem = (LoadMoreNode)JSON.deserialize(request, LoadMoreNode.class);
                if(nodeItem.objType != null && nodeItem.objType.equals('SVMXC__Installed_Product__c')){
                    List<Map<String,String>> ibChildrenList = getIbChildren(nodeItem);
                    childrenList.addAll(ibChildrenList);
                }else{
                    if(nodeItem.isIB) {
                        List<Map<String,String>> ibChildrenList = getIbChildren(nodeItem);
                        childrenList.addAll(ibChildrenList);
                    } else {
                        List<Map<String,String>> siteChildrenList = getSiteChildren(nodeItem);
                        childrenList.addAll(siteChildrenList);
                        if(siteChildrenList.size() < nodeItem.recordsLimit) {
                            nodeItem.isIB = true;
                            nodeItem.ibIndex = 0;
                            nodeItem.recordsLimit = nodeItem.recordsLimit - siteChildrenList.size();
                            List<Map<String,String>> ibChildrenList = getIbChildren(nodeItem);
                            childrenList.addAll(ibChildrenList);
                        }
                    }
                }

                if(!childrenList.isEmpty()){
                    return childrenList;
                }else {
                        response.status = false;
                        response.message = 'No children found';
                        return response;
                    }


            }catch (Exception ex){
            
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));    
            response.status = false;
            response.message = ex.getMessage();
            return response;
        }

    }

    public List<Map<String,String>> getIbChildren(LoadMoreNode nodeItem){
        List<DefaultFieldObject> configuredFieldList;
        if(nodeItem.treeType.equals('SVMXC__Installed_Product__c')) {
            configuredFieldList = getDefaultConfiguredFields(false, 'IB');   
        }else {
            configuredFieldList = null;
        }
        IbFieldObject ibFieldObject = getQueryFiledsForIb(configuredFieldList);
        String queryFields = ibFieldObject.queryFields;
        List<String> fieldNameList = ibFieldObject.fieldNameList;
        Map<String, String> fieldTypeMap = ibFieldObject.fieldTypeMap;
        String parentIb = nodeItem.sfdcId;
        String accountId = nodeItem.accountId;
        String topLevelIb = nodeItem.topLevelIb;
        Integer recordsLimit = nodeItem.recordsLimit;
        Integer index = nodeItem.index;
        if(nodeItem.isIB) {
            index = nodeItem.ibIndex;
        }
        SVMXC__Installed_Product__c topLevelRecord;
        if(topLevelIb != null) topLevelRecord = [select SVMXC__Company__c,SVMXC__Site__c from SVMXC__Installed_Product__c where Id =: topLevelIb]; 
        List<SVMXC__Installed_Product__c> ibRecordList = new  List<SVMXC__Installed_Product__c>();
        String query = '';
        //Defect fix : 5065
        queryFields = getQueryFieldForTranslation(queryFields);
        if(parentIb.equals('root')) {//root for IB's under account
            query = 'SELECT SVMXC__Parent__r.Name , SVMXC__Site__r.Name, SVMXC__Company__r.Name, SVMXC__Top_Level__r.Name , ' + queryFields +' from SVMXC__Installed_Product__c where SVMXC__Site__c = null AND SVMXC__Top_Level__c = null AND SVMXC__Company__c =: accountId';
        } else {
            if(nodeItem.objType.equals('SVMXC__Installed_Product__c')){
                query = 'SELECT SVMXC__Parent__r.Name , SVMXC__Site__r.Name, SVMXC__Company__r.Name, SVMXC__Top_Level__r.Name , ' + queryFields +' from SVMXC__Installed_Product__c where SVMXC__Parent__c =:parentIb';
            }else{
                query = 'SELECT SVMXC__Parent__r.Name , SVMXC__Site__r.Name, SVMXC__Company__r.Name, SVMXC__Top_Level__r.Name , ' + queryFields +' from SVMXC__Installed_Product__c where SVMXC__Site__c =:parentIb AND SVMXC__Top_Level__c = null';
            }
        }
        query += ' ORDER BY LastModifiedDate DESC LIMIT :recordsLimit OFFSET :index';
        ibRecordList = Database.query(query);
        List<Map<String, String>> ibTreeList  = validateIbRecords(ibFieldObject, topLevelRecord, ibRecordList,accountId);
        return ibTreeList;
    }

    public List<Map<String,String>> getSiteChildren(LoadMoreNode nodeItem){
        List<DefaultFieldObject> configuredFieldList;
        if(nodeItem.treeType.equals('SVMXC__Site__c')) {
            configuredFieldList = getDefaultConfiguredFields(false, 'SITE');
        }else {
            configuredFieldList = null;
        }
        IbFieldObject fieldObject = getQueryFiledsForSite(configuredFieldList);
        String queryFields = fieldObject.queryFields;
        List<String> fieldNameList = fieldObject.fieldNameList;
        Map<String, String> fieldTypeMap = fieldObject.fieldTypeMap;
        String parentId = nodeItem.sfdcId;
        String accountId = nodeItem.accountId;
        Integer recordsLimit = nodeItem.recordsLimit;
        Integer index = nodeItem.index;
        List<SVMXC__Site__c> siteRecordList;
        //Defect fix : BAC-5065          
        queryFields = getQueryFieldForTranslation(queryFields);   
        if(parentId.equals('root')) {//root for Site's under account
            siteRecordList = Database.query('SELECT SVMXC__Parent__r.Name,SVMXC__Account__r.Name,' + queryFields +' from SVMXC__Site__c where SVMXC__Parent__c = null AND SVMXC__Account__c =:accountId  ORDER BY LastModifiedDate DESC LIMIT :recordsLimit OFFSET :index');
        } else {
            siteRecordList = Database.query('SELECT SVMXC__Parent__r.Name,SVMXC__Account__r.Name,' + queryFields +' from SVMXC__Site__c where SVMXC__Parent__c =:parentId AND SVMXC__Account__c =:accountId  ORDER BY LastModifiedDate DESC LIMIT :recordsLimit OFFSET :index');
        }
        List<Map<String, String>> siteTreeList  = validateSiteRecords(fieldObject, siteRecordList, accountId);
        return siteTreeList;
    }

     public class LoadMoreNode{
        public String objType;
        public String sfdcId;
        public Integer index;
        public Integer recordsLimit;
        public String accountId;
        public String topLevelIb;
        public String treeType;
        public Boolean isIB;
        public Integer ibIndex;

        public LoadMoreNode(){

        }
    }

    public class IbFieldObject{
        String queryFields ;
        List<String> fieldNameList ;
        Map<String, String> fieldTypeMap ;

        public IbFieldObject(){

        }
    }           
    public virtual class AbstractResponse{
        
        public Boolean status = true;
        public String message = '';
        public AbstractResponse(){
            
        }       
    }

    public class GetSetupMetadataResponse extends AbstractResponse{
        public Map<String,SForceObject> sforceObjectDescribes;
        public List<DefaultFieldObject> defaultFieldObject;
        public Map <String, String> translations;
        public GetSetupMetadataResponse(){
            
        }

        public void setSForceObjectDescribes(Map<String,SForceObject> sforceObjectDescribes) {
            this.sforceObjectDescribes = sforceObjectDescribes;
        }
        public void setdefaultFieldObject(List<DefaultFieldObject> defaultFieldObject) {
            this.defaultFieldObject = defaultFieldObject;
        }
    }
    public class SForceObject {
        public String objectLabel;
        public String objectAPIName;
        public List<SForceField> fields;
    }
    
    public class SForceField {
        public String fieldLabel;
        public String fieldName;
        public String fieldType;
        public String referenceTo;
        public String relationshipName;
          
    }
     public class SForcePickListValues {
        public String fieldLabel;
        public String fieldName;
        
          
    }

    public class DefaultFieldObject{
        public String fieldLabel;
        public String fieldName;
        public String fieldType;
        public String referenceTo;
        public String relationshipName;
    }

    public class ConfiguredFields{
        public List<ColumnObject> columnsToDisplay;
        public String objectName;
        public ConfiguredFields(){

        }
        
    }

    public class ColumnObject{
        public String fieldLabel;
        public String fieldName;
        public String fieldType;
        public String referenceTo;
        public String relationshipName;
        public ColumnObject(){

        }
        
    }

    public class IBsAccount{
        public String accountName;
        public String accountId;
        public String ibName;
        public String ibId;
        public Integer childrenCount;
        public IBsAccount(){

        }
    }

    public class IbTreeData{    
        public IBsAccount ibAccount;
        public List<Map<String, String>> ibTree;

        public IbTreeData(){

        }

    }



}