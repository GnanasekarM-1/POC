/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * Service manager which has business logic for all the services, related to work order object, re-written for DCx
 * @author Vinay Vijay
 * @version 19.2000
 * @since 2019
 */
public with sharing class DCX_WOServiceManager {

    public static boolean allowtriggerExecution = true;
    
        /**************************************Pagination service for WO**************************************/
    
    public static workorderDCx retrieveWorkOrders(String viewId, Boolean isInitial,Boolean isQueue, List<String> dispatchStatus, List<String> invisibleWorkOrderIds, String pageSize, String sortField, Boolean isAscending, String searchField, String searchFieldValue) {
// long t1 = DateTime.now().getTime();
// system.debug('Inside retrieveWorkOrders');
        String UserId = UserInfo.getUserId();
        Boolean hasCreatedBy,hasLastModifiedBy;
        system.debug('dispatchStatus ::'+dispatchStatus);
        List<DCX_Wrapper.SVMX_StringMap> views = new List<DCX_Wrapper.SVMX_StringMap>();
        hasCreatedBy = false;
        hasLastModifiedBy = false;
        Boolean viewCriteriaFailed = false;
        String errorMsg;
        //fetch the default views if any
        SVMXC.DCX_CommonServiceManager.UserSetting userSettings = SVMXC.DCX_SettingServiceManager.fetchUserSettings();
        Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap(); // Get field definition map for work order

        

      //  Map<String, SObjectField> objWorkOrderFieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        // system.debug('objWorkOrderFieldMap: ' +objWorkOrderFieldMap);
         Set<String> LongTextAreaFields = new Set<String>();

         for (String fieldKey : souObjfieldMap.keySet())
         {
             Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
             Schema.DescribeFieldResult field = fsObj.getDescribe();
            // system.debug('souObjfieldMap '+field.getType()+'   --' +field);
             if(String.valueOf(field.getType()) == 'TEXTAREA' && INTEGER.valueOf(field.getLength()) > 255 ) 
             {
                LongTextAreaFields.add(field.getName());
             }
         }

         if(!isInitial){
            if( sortField != null && LongTextAreaFields.contains(sortField))
            {
                throw new DCX_CommonServiceManager.DCxException('TAG522');
            }
            if( (searchField != null  && searchFieldValue != null)&& LongTextAreaFields.contains(searchField))
            {
                throw new DCX_CommonServiceManager.DCxException('TAG523');
            }
         }


        
        views = DCON_Retrieve_Views(UserId); //get all the views accessible for the user

        if(isInitial) viewId = userSettings.wo_defaultView; //get the default view from user settings

        if(viewId == null || viewId == '') viewId = UserId; //set default queue id as view id

        boolean isViewPresentAndAccessible = false;
        //check if the view is present and user has access to it
        for(DCX_Wrapper.SVMX_StringMap s : views) {
            if(s.Key.equals(viewId)) {
                isViewPresentAndAccessible = true;
                break;
            }
        }

        if(!isViewPresentAndAccessible) viewId = UserId; //set default queue id as view id if view is deleted or not accessible

        List<string> lstSubModules = new List<string>{'DCON001'};
        Map<String,String> appSetting = COMM_Utils_ManageSettings.SVMX_getuniqueSettingValueRange('DCON001','SET001','SET073',null);
       // Map<String,String> appSetting = COMM_Utils_ManageSettings.SVMX_getDCSetting(lstSubModules);

system.debug('APP SETTINGS: '+appSetting);      

        //fetch pageSize from app settings
        if(pageSize == null) {
            if(appSetting.containskey('DCON001_SET073') && appSetting.get('DCON001_SET073') != null) {
                Integer size = Integer.valueOf(appSetting.get('DCON001_SET073'));
                if(size < 200)
                    pageSize = '200';
                else 
                    pageSize = String.valueOf(size);
            }
            else {
                pageSize = '200';
            }
        }

        //fetch the default svmx setting for dispatch status if any
        //This is executed only for initial DCx launch  
        Boolean setSortField = false;  
        if(isInitial) {
            if(appSetting.containskey('DCON001_SET007') && appSetting.get('DCON001_SET007') != null) {
                String strDefaultStatus = appSetting.get('DCON001_SET007');
                dispatchStatus = strDefaultStatus.split(',');
                if(viewId != null && viewId != UserId) {
                    if(userSettings.wo_viewCounter != null && userSettings.wo_viewCounter.size() > 0){
                        for(DCX_CommonServiceManager.ViewCounter viewCon : userSettings.wo_viewCounter) {
                            if(viewCon.id == viewId) {
                                setSortField = true;
                                if(viewCon.column != null &&  !LongTextAreaFields.contains(viewCon.column)) {
                                    sortField = viewCon.column;
                                } else {
                                    sortField = 'Name';
                                }
                                if(viewCon.sortOrder != null) {
                                    if(viewCon.sortOrder.equalsIgnoreCase('asc')) {
                                        isAscending = true;
                                    } else {
                                        isAscending = false;
                                    }
                                } else {
                                    isAscending = true;
                                }
                            }
                        }
                    }
                }
              
                if(!setSortField) {
                    if(sortField != null &&  userSettings.wo_sortColumn != '' && !LongTextAreaFields.contains(userSettings.wo_sortColumn)) 
                        sortField = userSettings.wo_sortColumn;
                    if( userSettings.wo_sortOrder == 'asc')
                        isAscending = true;
                    else
                        isAscending = false;
                }
            }
        }
                
// long t2 = DateTime.now().getTime();
        //SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        DCX_Utils dcUtils = new DCX_Utils();

        String WhereClause = '';
        String FirstWhereClause = '';
        String SecondWhereClause = '';
        String strPreFilterCriteria = '';
        String strOwnerShipType = '';
        String querySelect = ''; 
//        List<workorder_WPDCx> workorder_LWP = new List<workorder_WPDCx>();
        List<SVMXC__Service_Order__c> workorder_LO = new List<SVMXC__Service_Order__c>();
        List<String> refFields_L = new List<String>();
        List<String> dateTimeFields_L = new List<String>();
        List<String> dateFields_L = new List<String>();
        Map<String,String> replacementRef = new Map<String,String>();
        Map<String,String> replacementNameField = new Map<String,String>();
        Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
// long t21 = DateTime.now().getTime();        
// long t22 = DateTime.now().getTime();
        //get wo fields configured in svmx settings       
        Set<string> setWorkOrderFields = getConfiguredWoUpdateFields();
// long t23 = DateTime.now().getTime();        
        //START: DNS-623
        //get the list of WO fields which are to be loaded instead of loading all WO fields
        Set<String> setWOFields = getWOFieldsToLoadInDCx(setWorkOrderFields, userSettings);
// long t24 = DateTime.now().getTime();        
        //get the list of fileds configured by user for a view in SFDC page under 'Dispatch Process -> Dispatch Console Views'
        if(viewId != '' && viewId != null) {
            List<SVMXC__ServiceMax_Config_Data__c> listConfViewFields = new List<SVMXC__ServiceMax_Config_Data__c>();
            listConfViewFields = [Select SVMXC__Field_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: viewId and SVMXC__Expression_Type__c ='SRCH_Object_Fields'];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__ServiceMax_Config_Data__c objConf : listConfViewFields)
                setWOFields.add(objConf.SVMXC__Field_Name__c);
        }
// long t3 = DateTime.now().getTime();                    
// system.debug('decl: '+(t21-t2));
// system.debug('obj describe: '+(t22-t21));
// system.debug('getConfiguredWoUpdateFields: '+(t23-t22));
// system.debug('getWOFieldsToLoadInDCx: '+(t24-t23));
// system.debug('loop: '+(t3-t24));
//system.debug('--------------wo fields=default+user+svmx----------');
//for(String s : setWoFields)
//  system.debug(s);
    
        //Get only those WO fields which has to be populated, we can skip the rest
/*        for (String fieldKey : souObjfieldMap.keySet()) {
            String fieldName='';
            Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            fieldName = f.getName();
            if(setWOFields.contains(fieldName))
                newSchemaFieldMap.put(fieldName, fsObj);
        }*/
//system.debug('----------newSchemaMap-------');
//for(String s:newSchemaFieldMap.keySet())
//  system.debug(s);
        for(String fieldName : setWoFields) {
            if(!fieldName.equalsIgnoreCase('id') && souObjfieldMap.containsKey(fieldName)) {
                Schema.SObjectField fsObj = souObjfieldMap.get(fieldName);
                newSchemaFieldMap.put(fieldName, fsObj);
            }
        }
// long t4 = DateTime.now().getTime();        
       DCX_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);
     //DCX_Utils.DCON_referenceFields_WP reference_M = dcUtils.DCON_getReferenceFields(newSchemaFieldMap,true);
        newSchemaFieldMap.clear();
        //souObjfieldMap.clear();
        List<String> limitedFields_L = reference_M.allFields_L; //Get all fields list
        limitedFields_L.add('SVMXC__Violation_Status2__c');
        limitedFields_L.add('SVMXC__Violation_Message__c');
        limitedFields_L.add('SVMXC__Longitude__c');
        limitedFields_L.add('SVMXC__Latitude__c');
        for(String fld : limitedFields_L) {
            if(fld.equalsIgnoreCase('CreatedById'))
                hasCreatedBy = true;
            if(fld.equalsIgnoreCase('LastModifiedById'))
                hasLastModifiedBy = true;
        }
        if(hasCreatedBy)
            limitedFields_L.add('CreatedBy.Name');
        if(hasLastModifiedBy)
            limitedFields_L.add('LastModifiedBy.Name');
        Set<String> limitedFieldSet = new Set<String>();
        limitedFieldSet.addAll(limitedFields_L);
        limitedFields_L.clear();
        limitedFields_L.addAll(limitedFieldSet);
        limitedFieldSet.clear();
        //END: DNS-623
        List<String> pickList_L = new List<String>();
        
        refFields_L = reference_M.referenceFields_L; //Get the reference field list
        dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
        dateFields_L = reference_M.dateFields_L; //Get the date field list
        replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
        replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
       // pickList_L = reference_M.pickList_L;
        
     //  querySelect = dcUtils.DCON_getFieldNamesFromList(limitedFields_L,pickList_L); 
        querySelect = dcUtils.SVMX_getFieldNamesFromList(limitedFields_L); 
        
// long t5 = DateTime.now().getTime();
        // Build the Work Order query
        if(viewId != '' && viewId != null) {
            // Check if viewId is Owner Id / Queue Id or Work Order View Id
            String strPrefix  = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.getKeyPrefix();
            if(strPrefix == viewId.substring(0,3)) {// It is a Work Order View Id
                list<SVMXC__ServiceMax_Processes__c> lstViews = new list<SVMXC__ServiceMax_Processes__c>();
                lstViews = [select Id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__Ownership_Type__c, SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Processes__c where id =: viewId];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstViews.size() > 0) {
                    list<SVMXC__ServiceMax_Config_Data__c> lstConfig = [Select Id, SVMXC__Field_Name__c  from 
                                                                        SVMXC__ServiceMax_Config_Data__c where 
                                                                        SVMXC__Expression_Rule__c = :lstViews[0].Id and 
                                                                        SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria'];
                    for(SVMXC__ServiceMax_Config_Data__c cData : lstConfig) {
                        if(!souObjfieldMap.containsKey(cData.SVMXC__Field_Name__c.toLowerCase())) {
                            if(isInitial) {
                                viewCriteriaFailed = true;
                                errorMsg = 'The field '+ cData.SVMXC__Field_Name__c + ' is deleted from the view. Please select a different view.';
                            } else {
                                throw new DCX_CommonServiceManager.DCxException('The field '+ cData.SVMXC__Field_Name__c + ' is deleted from the view. Please select a different view.');
                            }
                        }
                    }
                    if(lstViews[0].SVMXC__Parent_Object_Criteria__c != null)
                        strPreFilterCriteria = lstViews[0].SVMXC__Parent_Object_Criteria__c;
                    if(lstViews[0].SVMXC__Ownership_Type__c != null)
                        strOwnerShipType = lstViews[0].SVMXC__Ownership_Type__c;    
                }
                else {
                    throw new DCX_CommonServiceManager.DCxException(system.label.DCON001_TAG328);
                }

                if(strPreFilterCriteria != null && strPreFilterCriteria.length() > 0) {
                    //strPreFilterCriteria = strPreFilterCriteria.replace(' ','+');
                    FirstWhereClause = strPreFilterCriteria;
                }

                if(strOwnerShipType != null && strOwnerShipType.length() > 0 && strOwnerShipType == 'User\'s Records') {
                    String strUserId = Userinfo.getUserId();
                    if(FirstWhereClause != null && FirstWhereClause.length() > 0)
                        FirstWhereClause = ' ( '+FirstWhereClause+ ' ) '+' AND OwnerId = \''+strUserId+'\'';
                    else 
                        FirstWhereClause += 'OwnerId = \''+strUserId+'\'';
                }
            }
            else { // It is Owner Id or Queue Id
            system.debug('OwnerId');
               FirstWhereClause = 'OwnerId = \''+ViewId+'\'';
            }  
//            FirstWhereClause = FirstWhereClause.replace('%','%25'); 
//            FirstWhereClause = FirstWhereClause.replace('\'','%27');
        }
// long t6 = DateTime.now().getTime();
        if(invisibleWorkOrderIds != NULL && invisibleWorkOrderIds.size() > 0) {
            String InVal = dcUtils.SVMX_get_ListOfValues(invisibleWorkOrderIds);
            if(FirstWhereClause != '')
                FirstWhereClause = ' ( '+FirstWhereClause+' ) '+' AND ';
            FirstWhereClause += 'Id IN :invisibleWorkOrderIds';
        }
system.debug('FirstWhereClause : '+FirstWhereClause);
system.debug('dispatchStatus : '+dispatchStatus);
        if(dispatchStatus != null && dispatchStatus.size() > 0 && dispatchStatus[0].toUpperCase() != 'ALL') {
            //Adding conditions based on the dispatchStatus
            
            if(FirstWhereClause != null && FirstWhereClause.length() > 0) {
                for(String ds: dispatchStatus) {
                    if(SecondWhereClause == '')
                        SecondWhereClause += ' AND ( ';
                    else if(ds.toUpperCase()=='NEW' || ds.toUpperCase()=='QUEUED' || ds.toUpperCase()=='ASSIGNED')
                        SecondWhereClause += ' OR ';
                    if(ds.toUpperCase()=='NEW')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c = NULL ) ';
                    else if(ds.toUpperCase()=='QUEUED')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c != NULL ) ';
                    else if(ds.toUpperCase()=='ASSIGNED')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c != NULL) ';//Apurva :Defect - 011238
                }
                SecondWhereClause += ' ) ';
            }      
            else {
                for(String ds: dispatchStatus) {
                    if((SecondWhereClause != null && SecondWhereClause.length() > 0) && (ds.toUpperCase()=='NEW' || ds.toUpperCase()=='QUEUED' || ds.toUpperCase()=='ASSIGNED'))
                        SecondWhereClause += ' OR ';
                    if(ds.toUpperCase()=='NEW')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c = NULL ) ';
                    else if(ds.toUpperCase()=='QUEUED')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c != NULL ) ';
                    else if(ds.toUpperCase()=='ASSIGNED')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c != NULL ) ';  //Apurva :Defect - 011238  
                }
            }              
        }

        if(FirstWhereClause != null && FirstWhereClause.length() > 0) {
            if(SecondWhereClause != null && SecondWhereClause.length() > 0)
                WhereClause = ' ( '+FirstWhereClause+' ) ' + SecondWhereClause;
            else
                WhereClause = FirstWhereClause;
        }
        else        {
            WhereClause = SecondWhereClause;
        }
// long t7 = DateTime.now().getTime();        
        //soql generation for search filter
       
        if(searchField != null && searchField.length() > 0 && searchFieldValue != null && searchFieldValue.length() > 0 ) {
            if(WhereClause != null && WhereClause.length() > 0) {
                 system.debug('searchField  : '+searchField);
        system.debug('searchFieldValue  : '+searchFieldValue);
         system.debug('WhereClause  : '+WhereClause);
                WhereClause = '('+WhereClause+')';
                WhereClause += ' AND' + buildSearchClause(searchField,searchFieldValue);
            }
            else {
                WhereClause = buildSearchClause(searchField,searchFieldValue);              
            }
        }
// long t8 = DateTime.now().getTime();        
        String orderClause = '';
        //soql generation for sort order
        if(sortField != null && sortField.length() > 0) {
            orderClause = ' ORDER BY '+ sortField + ' ';
            if(!isAscending) {
                if(appSetting.containskey('DCON001_SET031') && appSetting.get('DCON001_SET031') != null) {
                    orderClause += 'DESC NULLS ' + appSetting.get('DCON001_SET031');
                } else {
                    orderClause += 'DESC NULLS LAST';    
                }
            }
            else {
                if(appSetting.containskey('DCON001_SET030') && appSetting.get('DCON001_SET030') != null) {
                    orderClause += 'ASC NULLS ' + appSetting.get('DCON001_SET030');
                } else {
                    orderClause += 'ASC NULLS FIRST';  
                }
            }
        }
        //sort by wo id by default, if no sort field is mentioned
        else {
            orderClause = ' ORDER BY Name';
        }
        
        String strQuery = '';

        if(WhereClause != null && WhereClause.length() > 0) //string.escapeSingleQuotes(
            strQuery = 'SELECT ID,' + querySelect + ' FROM SVMXC__Service_Order__c WHERE ' + WhereClause;
        else
            strQuery = 'SELECT ID,' + querySelect + ' FROM SVMXC__Service_Order__c';

        if(orderClause != null & orderClause.length() > 0) {
            strQuery += orderClause;
        }
// long t9 = DateTime.now().getTime();        
system.debug('WO Query: '+strQuery);
        //replace whitespace with plus sign
        strQuery = EncodingUtil.urlEncode(strQuery, 'UTF-8');
// long t10 = DateTime.now().getTime();        
system.debug('WO Query for Rest API: '+strQuery);       
system.debug('pageSize: '+pageSize);
        //call the sfdc query rest api to get the paginated results
        workorderDCx_INT wowp ;
        if(!Test.isRunningTest()){
            if(!viewCriteriaFailed) {
             wowp = doGet(strQuery, pageSize,false);
            }
        }
        Long dbsyncTime = DateTime.Now().getTime();
// long t11 = DateTime.now().getTime();        
/*        workorder_WPDCx workorder_WPDCx;
        List<workorderSpecialFields_WPDCx> specialFields_LWP;
system.debug('----------post processing---------');             
        for(SVMXC__Service_Order__c wo: wowp.records) {
            specialFields_LWP = new List<workorderSpecialFields_WPDCx>();
system.debug('wo: '+wo.NAME);
            
            for(String s : refFields_L){
system.debug('refFields_L: '+s);
                workorderSpecialFields_WPDCx tRef;
                Sobject ref_TO = wo.getSobject(replacementRef.get(s));
system.debug('replacementRef.get(s): '+replacementRef.get(s));
                if(ref_TO!=NULL){
system.debug('ref_TO: '+ref_TO.get(replacementNameField.get(s)));
                    tRef = new workorderSpecialFields_WPDCx(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
                    specialFields_LWP.add(tRef);
                }
            }
            
            for(String s : dateTimeFields_L){
system.debug('dateTimeFields_L: '+s);
                if(wo.get(s) != NULL){
system.debug(logginglevel.warn,'WO datetime value'+wo.get(s));
system.debug(logginglevel.warn,'WO datetime value with format'+((Datetime)(wo.get(s))).format());
                    workorderSpecialFields_WPDCx tDateTime = new workorderSpecialFields_WPDCx(s, ((Datetime)(wo.get(s))).format() );
                    specialFields_LWP.add(tDateTime);
                }
            }
            for(String s : dateFields_L){
                if(wo.get(s) != NULL){
system.debug('dateFields_L: '+s);
                    workorderSpecialFields_WPDCx tDate = new workorderSpecialFields_WPDCx(s, Date.valueof(String.valueof(wo.get(s))).format() );
                    specialFields_LWP.add(tDate);
                }
            }

            workorder_WPDCx = new workorder_WPDCx(wo, specialFields_LWP);
            workorder_LWP.add(workorder_WPDCx);
        }
        
        if(workorder_LWP != null && workorder_LWP.size() > 0 )
            workorder_LWP.get(workorder_LWP.size()-1).lastSyncedTime = DateTime.now().getTime();
        else{
            workorder_WPDCx obj = new workorder_WPDCx();
            List<workorderSpecialFields_WPDCx> FieldUpdateWrapper = new List<workorderSpecialFields_WPDCx> ();
            if(setWorkOrderFields != null && setWorkOrderFields.size()>0) {
                if(invisibleWorkOrderIds != NULL && invisibleWorkOrderIds.size() > 0)
                    obj = getFieldUpdateWrapper(setWorkOrderFields, invisibleWorkOrderIds);
            }
            //DNS-1493
            if(obj != null) {   
                obj.lastSyncedTime = DateTime.now().getTime();
            }
            else {
                obj = new workorder_WPDCx();
                obj.lastSyncedTime = DateTime.now().getTime();  
            }       
            workorder_LWP.add(obj);
        }
*/  if(!Test.isRunningTest()){
        LocalTimeZone localTz = new LocalTimeZone(UserInfo.getTimeZone().getDisplayName(),UserInfo.getTimeZone().getID(),UserInfo.getLocale(),UserInfo.getLanguage());
        //create the workorderDCx to be returned with metadata
        workorderDCx woData; 
        if(viewCriteriaFailed) {
           woData = new workorderDCx(isInitial?localTz:null,viewId,isInitial?views:null,errorMsg);    
        } else {
           woData = new workorderDCx(wowp.totalSize,wowp.done,wowp.nextRecordsUrl,dbsyncTime,wowp.records,isInitial?localTz:null,viewId,isInitial?views:null,strQuery);
        }
       // workorderDCx woData = new workorderDCx(wowp.totalSize,wowp.done,wowp.nextRecordsUrl,dbsyncTime,wowp.records,isInitial?userSettings:null,isInitial?localTz:null,viewId,isInitial?views:null,isInitial?appSetting:null,strQuery);

// long t12 = DateTime.now().getTime();
// system.debug('fetch view: '+(t2-t1));
// system.debug('fetch list of configured fields for the view: '+(t3-t2));
// system.debug('fetch wo fields that have to be populated: '+(t4-t3));
// system.debug('fetch reference fields: '+(t5-t4));
// system.debug('where clause without invisible wo: '+(t6-t5));
// system.debug('where clause with invisible wo: '+(t7-t6));
// system.debug('filter clause: '+(t8-t7));
// system.debug('order clause: '+(t9-t8));
// system.debug('Whitespace encoding: '+(t10-t9));
// system.debug('SFDC Query API: '+(t11-t10));
// system.debug('Timestamping: '+(t12-t11));
// system.debug('total time: '+(t12-t1));
        return woData;
}
else{
    return null;
}
    }
    
        private static String buildSearchClause(String searchField, String searchFieldValue) {
        
        String expression = '';
    String searchStr;
        //expression will be '%value%' for String... datatype
        //it will be %value% for Integer, Boolean... datatype
        SObjectType r = ((SObject)(Type.forName('Schema.SVMXC__Service_Order__c').newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        Schema.SObjectField obj;
        Schema.DisplayType typ;
        Schema.Describesobjectresult lookUpObj;
        Map<String, Schema.SObjectField> fieldMap = d.fields.getMap();
        if(searchField.containsIgnoreCase('__r.')) {
            Schema.DescribeFieldResult f = fieldMap.get(searchField.substringBefore('__r.')+'__c').getDescribe();
            for(Schema.SObjectType reference : f.getReferenceTo()) {
                lookUpObj = reference.getDescribe();
            }
            typ = lookUpObj.fields.getMap().get(searchField.substringAfter('__r.')).getDescribe().getType();
        } else {
            if(searchField.contains('.Name')) {
                obj = fieldMap.get('Name');
                typ = obj.getDescribe().getType();
            } else {
                obj = fieldMap.get(searchField);
                typ = obj.getDescribe().getType();
            }
        }
        String typStr = String.valueOf(typ);
system.debug('TYPEEEE: '+typStr);
        if(typStr.equalsIgnoreCase('Boolean') || typStr.equalsIgnoreCase('Date') || typStr.equalsIgnoreCase('Double') 
           || typStr.equalsIgnoreCase('Integer') || typStr.equalsIgnoreCase('Long')) {
            expression =  searchFieldValue;
            searchStr = ' ' + searchField + ' = ' + expression;
        } else if(typStr.equalsIgnoreCase('DateTime')) {
            //String dateValue = searchFieldValue.left(10);
            Integer yearVal = Integer.valueOf(searchFieldValue.left(4));
            Integer monthVal = Integer.valueOf(searchFieldValue.substring (5,7));
            Integer dateVal = Integer.valueOf(searchFieldValue.substring(8,10));
            Integer hourVal = Integer.valueOf(searchFieldValue.substring(11,13));
            Integer minVal = Integer.valueOf(searchFieldValue.substring(14,16));
            Integer secVal = Integer.valueOf(searchFieldValue.substring(17,19));
            //dateTime startVal = DateTime.newInstanceGmt(yearVal, monthVal, dateVal);
            dateTime startVal = DateTime.newInstanceGmt(yearVal, monthVal, dateVal,hourVal,minVal,secVal);
            dateTime endVal = startVal.addHours(24);
            String endDateTimeString = endVal.format('yyyy-MM-dd') + 'T' + endVal.format('HH:mm:ss.SSS') + 'Z';
            system.debug('startVal = '+startVal+ ' -- endVal = '+endVal + ' -- searchFieldValue = ' +searchFieldValue + ' --endDateTimeString = '+endDateTimeString);
            searchStr = ' ' + searchField + ' >= ' + searchFieldValue + ' AND ' + searchField + ' <= ' + endDateTimeString;
        }
        else {
            expression = '\'' + '%' + string.escapeSingleQuotes(searchFieldValue) + '%' + '\''; 
            searchStr = ' ' + searchField + ' LIKE '+expression;
        }
        
        return searchStr;
    }
    
    private static workorderDCx_INT doGet(String query, String pageSize,boolean isWorkorser)  {
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        String url =  salesforceHost + '/services/data/v43.0/query?q=' + query;
                
        HttpRequest req = new HttpRequest();
                    
        req.setMethod('GET');
        req.setEndpoint(url);
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Sforce-Query-Options', 'batchSize=' + pageSize);
        req.setTimeout(120000);//setting it to 120s, which is maximum
                    
        Http http = new Http();
          
        HTTPResponse res = http.send(req);
        system.debug('Query Rest API Results: '+res.getBody());
        
        workorderDCx_INT wowp = (workorderDCx_INT)JSON.deserialize(res.getBody(), workorderDCx_INT.class);
system.debug('totalSize::: '+wowp.totalSize);                   
system.debug('done::: '+wowp.done);                 
system.debug('nextRecordsUrl::: '+wowp.nextRecordsUrl);                 
system.debug('records::: '+wowp.records.size());                    
         
         return wowp;
    }
        
    private static Set<String> getWOFieldsToLoadInDCx(Set<string> setWorkOrderFields, SVMXC.DCX_CommonServiceManager.UserSetting userSettings) {
        //1. Add default wo fields to load
        Set<String> strWorkOrderFields = DCX_Utils.wodefaultFields();
try {
        
        //2. Add all the wo fields that are configured by the user, that are used in wo rules, 
        //that are used in technician rules and that are used in keywords
        if(userSettings.wo_grid_conf_fields != null && userSettings.wo_grid_conf_fields.size() > 0) {
            strWorkOrderFields.addAll(userSettings.wo_grid_conf_fields);
        }
        if(userSettings.wo_grid_col_fields != null && userSettings.wo_grid_col_fields.size() > 0) {
            strWorkOrderFields.addAll(userSettings.wo_grid_col_fields);
        }

        COMM_Utils_V2 objCOMM_UtilV2 = new COMM_Utils_V2();
        strWorkOrderFields = objCOMM_UtilV2.checkDuplicateFields(strWorkOrderFields, 'SVMXC__Service_Order__c');
        
} catch(Exception e) {
system.debug('===================>'+e.getStackTraceString());
}
        
        //3. add work order fields from svmx settings
        strWorkOrderFields.addall(setWorkOrderFields);
        
        return strWorkOrderFields;
    }
    
    //replace whitespace with plus sign
//    private static String substituteQueryWhitespace(String query) {
        //replace whitespaces that is not within single quotes with +
        //regex reference - https://stackabuse.com/regex-splitting-by-character-unless-in-quotes/
        // actual expression is \\s+(?=([^\']*\'[^\']*\')*[^\']*$)
        //below \s has been escaped with \\s
//        String regex = '\\s+(?=([^\']*\'[^\']*\')*[^\']*$)';
//        query = query.replaceAll(regex,'\\+');
//        system.debug('Query Rest API SOQL: '+query);
//        return query;
//    }
    
    private static Set<String> getConfiguredWoUpdateFields() {
        Set<String> flds = new Set<String>();
        //COMM_Utils_ManageSettings util = new COMM_Utils_ManageSettings();
        Map<String, String> fldMap = COMM_Utils_ManageSettings.SVMX_getuniqueSettingValueRange('DCON001','SET038','SET047',null);
        
        for(String fld : fldMap.values()) {
            if(!fld.contains('Event.')) {
                flds.add(fld);
            }
        }
        
        return flds;
    }

/*    
    private static workorder_WPDCx getFieldUpdateWrapper(set<string> setWorkOrderFields, List<String> workorderIds) 
    {
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        list<string> lstWorkOrderFields = new list<string>(setWorkOrderFields);
        workorder_WPDCx WO_WP; 
        string strFieldUpdateFields  = utils.SVMX_getFieldNamesFromList(lstWorkOrderFields); 
        Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap(); 

        List<String> refFields_L = new List<String>();
        List<String> dateTimeFields_L = new List<String>();
        List<String> dateFields_L = new List<String>();
        Map<String,String> replacementRef = new Map<String,String>();
        Map<String,String> replacementNameField = new Map<String,String>();
        Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
        for (String fieldKey : souObjfieldMap.keySet()) 
        {
            String fieldName='';
            Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            fieldName = f.getName();
            if(setWorkOrderFields.contains(fieldName))
                newSchemaFieldMap.put(fieldName, fsObj);
        }
        DCON_Utils dcUtils = new DCON_Utils(); 
        DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);
        newSchemaFieldMap.clear();
        souObjfieldMap.clear();
        List<String> limitedFields_L = reference_M.allFields_L; //Get all fields list
        //END: DNS-623
        refFields_L = reference_M.referenceFields_L; //Get the reference field list
        dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
        dateFields_L = reference_M.dateFields_L; //Get the date field list
        replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
        replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
        string queryWO = 'Select '+strFieldUpdateFields+' From SVMXC__Service_Order__c where Id IN :workorderIds';
        
        System.debug('setWorkOrderFields: '+setWorkOrderFields);
        System.debug('queryWO: '+queryWO);
        for(SVMXC__Service_Order__c wo: Database.query(queryWO))
        {
            System.debug('+++++ Enetered  ');
            List<workorderSpecialFields_WPDCx> FieldUpdateWrapper = new List<workorderSpecialFields_WPDCx>();
            
            for(String s : refFields_L)
            {
                workorderSpecialFields_WPDCx tRef;
                
                Sobject ref_TO = wo.getSobject(replacementRef.get(s));
                if(ref_TO!=NULL)
                {
                    tRef = new workorderSpecialFields_WPDCx(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
                    FieldUpdateWrapper.add(tRef);
                    if(setWorkOrderFields.contains(s))
                        setWorkOrderFields.remove(s);
                }
            }
            
            for(String s : dateTimeFields_L)
            {
                if(wo.get(s) != NULL)
                {
                    system.debug(logginglevel.warn,'WO datetime value'+wo.get(s));
                    workorderSpecialFields_WPDCx tDateTime = new workorderSpecialFields_WPDCx(s, ((Datetime)(wo.get(s))).format() );
                    FieldUpdateWrapper.add(tDateTime);
                    if(setWorkOrderFields.contains(s))
                        setWorkOrderFields.remove(s);
                }
            }
            for(String s : dateFields_L){
                if(wo.get(s) != NULL)
                {
                    workorderSpecialFields_WPDCx tDate = new workorderSpecialFields_WPDCx(s, Date.valueof(String.valueof(wo.get(s))).format() );
                    FieldUpdateWrapper.add(tDate);
                    if(setWorkOrderFields.contains(s))
                        setWorkOrderFields.remove(s);
                }
            }
            if(!setWorkOrderFields.isempty() && setWorkOrderFields.size()>0)
            {
                for(string s :new list<string>(setWorkOrderFields))
                {
                    workorderSpecialFields_WPDCx WOField = new workorderSpecialFields_WPDCx(s, String.valueof(wo.get(s)));
                    FieldUpdateWrapper.add(WOField);
                }
            }
            WO_WP = new workorder_WPDCx(null,FieldUpdateWrapper);
        }       
            System.debug('WO_WP: '+WO_WP);
        return WO_WP;
    }
*/
    //This method returns the name of Work Order views (queues and personal) to which the login user has access to.
    /*public static List<DCON_Configuration_WS.SVMX_StringMap> DCON_Retrieve_Views(String UserId)
    {
        List<SVMXC.DCON_Configuration_WS.SVMX_StringMap> ViewList = new List<SVMXC.DCON_Configuration_WS.SVMX_StringMap>();
        SVMXC.DCON_Configuration_WS.SVMX_StringMap view;
        set<String> UserOrGroupId = new set<String>();
        set<String> GroupIds = new set<String>();
        set<Id> setUniqueGroupId = new set<Id>();
        view = new SVMXC.DCON_Configuration_WS.SVMX_StringMap(UserId, 'TAG194');
        ViewList.add(view);
        String ObjectName ='SVMXC__Service_Order__c';
        try
        {
            for(QueueSObject q:[SELECT QueueId FROM QueueSObject WHERE SobjectType  = :ObjectName Order By Queue.Name]){ 
                GroupIds.add(q.QueueId);
            }
            UserOrGroupId.add(UserId);

            for(GroupMember q:[SELECT GroupId FROM GroupMember WHERE UserOrGroupId IN :UserOrGroupId])
            {
                UserOrGroupId.add(q.GroupId);
            }

            for(Group r : [SELECT Id,Name,RelatedId,Type FROM Group where RelatedId =: userinfo.getUserRoleId() and 
                           (Type = 'Role' Or Type = 'RoleAndSubordinates')]){
                UserOrGroupId.add(r.id);
                system.debug('Roles'+r);
            }

            for(GroupMember q:[SELECT GroupId,Group.Name FROM GroupMember WHERE UserOrGroupId IN :UserOrGroupId AND GroupId IN :GroupIds])
            {
                if(!setUniqueGroupId.contains(q.GroupId)){
                    view = new SVMXC.DCON_Configuration_WS.SVMX_StringMap(q.GroupId, q.Group.Name);
                    view.woViewType = 'QUEUE';
                    ViewList.add(view);
                    setUniqueGroupId.add(q.GroupId);
                }   
            }
            system.debug('ViewList'+ViewList.size()+ViewList);
            SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
            SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
            list<SVMXC.INTF_WebServicesDef.INTF_StringListMap> lstStringListMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringListMap>();
            SVMXC.INTF_WebServicesDef.INTF_StringListMap stringListMap = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
            stringListMap.key = 'ISCALLEDFROMDC';
            lstStringListMap.add(stringListMap);
            SVMXC.INTF_WebServicesDef.INTF_StringListMap stringListMap1 = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
            stringListMap1.key = 'USERID';
            stringListMap1.valueList.add(UserId);
            lstStringListMap.add(stringListMap1);
            SVMXC.INTF_WebServicesDef.INTF_StringListMap stringListMap2 = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
            stringListMap2.key = 'OBJECTNAME';
            stringListMap2.valueList.add('SVMXC__Service_Order__c');
            lstStringListMap.add(stringListMap2);
            SVMXC.INTF_WebServicesDef.INTF_StringListMap stringListMap3 = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
            stringListMap3.key = 'VIEWFOR';
            stringListMap3.valueList.add('Grid');
            stringListMap3.valueList.add('Grid And Map');
            lstStringListMap.add(stringListMap3);
            request.stringListMap = lstStringListMap;
            SVMXC.INTF_CustomViewUtils customUtils = new SVMXC.INTF_CustomViewUtils();
            response = customUtils.getViewDefinition(request);

            if(response != null && response.stringMap != null && response.stringMap.size() > 0)
            {
                for(Integer i = 0;i<response.stringMap.size();i++)
                {
                    view = new SVMXC.DCON_Configuration_WS.SVMX_StringMap(response.stringMap[i].value1, response.stringMap[i].value);
                    view.woViewType = 'VIEW';
                    view.columnInfo = response.stringMap[i].type;
                    ViewList.add(view);
                }
            }
        }
        catch(Exception ex)
        {
            throw new DCX_CommonServiceManager.DCxException(ex);
        }
        system.debug('ViewList'+ViewList);
        return ViewList;
    }
*/
    public static List<DCX_Wrapper.SVMX_StringMap> DCON_Retrieve_Views(String UserId)
    {
        List<SVMXC.DCX_Wrapper.SVMX_StringMap> ViewList = new List<SVMXC.DCX_Wrapper.SVMX_StringMap>();
        SVMXC.DCX_Wrapper.SVMX_StringMap view;
        set<String> GroupIds = new set<String>();
        set<Id> setUniqueGroupId = new set<Id>();
        view = new SVMXC.DCX_Wrapper.SVMX_StringMap(UserId, 'TAG194');
        ViewList.add(view);
        String ObjectName ='SVMXC__Service_Order__c';
        set<String> UserOrGroupId = new set<String>();
        try
        {

            for(QueueSObject q:[SELECT QueueId FROM QueueSObject WHERE SobjectType  = :ObjectName Order By Queue.Name]){ 
                GroupIds.add(q.QueueId);
            }
            UserOrGroupId.add(UserId);
            for(GroupMember q:[SELECT GroupId FROM GroupMember WHERE UserOrGroupId IN :UserOrGroupId])
            {
                UserOrGroupId.add(q.GroupId);
            }

            for(Group r : [SELECT Id,Name,RelatedId,Type FROM Group where RelatedId =: userinfo.getUserRoleId() and (Type = 'Role' Or Type = 'RoleAndSubordinates')]){
                UserOrGroupId.add(r.id);
                system.debug('Roles'+r);
            }
            for(GroupMember q:[SELECT GroupId,Group.Name FROM GroupMember WHERE UserOrGroupId IN :UserOrGroupId AND GroupId IN :GroupIds])
            {
                if(!setUniqueGroupId.contains(q.GroupId)){
                    view = new SVMXC.DCX_Wrapper.SVMX_StringMap(q.GroupId, q.Group.Name);
                    view.woViewType = 'QUEUE';
                    ViewList.add(view);
                    setUniqueGroupId.add(q.GroupId);
                }   
            }
           /* for(QueueSObject q:[SELECT QueueId FROM QueueSObject WHERE SobjectType  = :ObjectName 
                                Order By Queue.Name]){ 
                GroupIds.add(q.QueueId);
            }
            
            for(GroupMember q:[SELECT GroupId,Group.Name FROM GroupMember WHERE 
                               ((Group.RelatedId = :userinfo.getUserRoleId() 
                               and (Group.Type = 'Role' or Group.Type = 'RoleAndSubordinates')) 
                               OR UserOrGroupId = :userinfo.getUserId()) AND GroupId IN :GroupIds])
            {
                if(!setUniqueGroupId.contains(q.GroupId)){
                    view = new SVMXC.DCX_Wrapper.SVMX_StringMap(q.GroupId, q.Group.Name);
                    view.woViewType = 'QUEUE';
                    ViewList.add(view);
                    setUniqueGroupId.add(q.GroupId);
                }   
            }*/
            system.debug('ViewList'+ViewList.size()+ViewList);
            SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
            SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
            list<SVMXC.INTF_WebServicesDef.INTF_StringListMap> lstStringListMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringListMap>();
            SVMXC.INTF_WebServicesDef.INTF_StringListMap stringListMap = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
            stringListMap.key = 'ISCALLEDFROMDC';
            lstStringListMap.add(stringListMap);
            SVMXC.INTF_WebServicesDef.INTF_StringListMap stringListMap1 = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
            stringListMap1.key = 'USERID';
            stringListMap1.valueList.add(UserId);
            lstStringListMap.add(stringListMap1);
            SVMXC.INTF_WebServicesDef.INTF_StringListMap stringListMap2 = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
            stringListMap2.key = 'OBJECTNAME';
            stringListMap2.valueList.add('SVMXC__Service_Order__c');
            lstStringListMap.add(stringListMap2);
            SVMXC.INTF_WebServicesDef.INTF_StringListMap stringListMap3 = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
            stringListMap3.key = 'VIEWFOR';
            stringListMap3.valueList.add('Grid');
            stringListMap3.valueList.add('Grid And Map');
            lstStringListMap.add(stringListMap3);
            request.stringListMap = lstStringListMap;
            SVMXC.INTF_CustomViewUtils customUtils = new SVMXC.INTF_CustomViewUtils();
            response = customUtils.getViewDefinition(request);

            if(response != null && response.stringMap != null && response.stringMap.size() > 0)
            {
                for(Integer i = 0;i<response.stringMap.size();i++)
                {
                    view = new SVMXC.DCX_Wrapper.SVMX_StringMap(response.stringMap[i].value1, response.stringMap[i].value);
                    view.woViewType = 'VIEW';
                    view.columnInfo = response.stringMap[i].type;
                    ViewList.add(view);
                }
            }
        }
        catch(Exception ex)
        {
            throw new DCX_CommonServiceManager.DCxException(ex);
        }
        system.debug('ViewList'+ViewList);
        return ViewList;
    }

    public class workorderDCx_INT{
        public Integer totalSize {get; set;}
        public Boolean done {get; set;}
        public String nextRecordsUrl {get; set;}
        public List<SVMXC__Service_Order__c> records {get; set;}
        public workorderDCx_INT(Integer size, Boolean isDone, String nextPageUrl, List<SVMXC__Service_Order__c> woList){
            this.totalSize = size;
            this.done = isDone;
            this.nextRecordsUrl = nextPageUrl;
            this.records = woList;
        }
    }
    
    public class workorderDCx{
        public String totalSize {get; set;}
        public String done {get; set;}
        public String nextRecordsUrl {get; set;}
        public String dbSyncTime {get; set;}
        public LocalTimeZone localTimeZone {get; set;}
        public String viewId {get; set;}
        public String soql {get; set;}
        public List<DCX_Wrapper.SVMX_StringMap> views {get; set;}
        public List<SVMXC__Service_Order__c> records {get; set;}
      //  public SVMXC.DCX_CommonServiceManager.UserSetting userSettings {get; set;}
      //  public Map<String, String> appSettings {get; set;}
        public workorderDCx(Integer size, Boolean isDone, String nextPageUrl, Long dbsyncTime, List<SVMXC__Service_Order__c> woList,  LocalTimeZone localDT, String view, List<DCX_Wrapper.SVMX_StringMap> viewList,  String sql){
         //public workorderDCx(Integer size, Boolean isDone, String nextPageUrl, Long dbsyncTime, List<SVMXC__Service_Order__c> woList, SVMXC.DCX_CommonServiceManager.UserSetting settings, LocalTimeZone localDT, String view, List<DCON_Configuration_WS.SVMX_StringMap> viewList, Map<String, String> appset, String sql){

            this.totalSize = String.valueOf(size);
            this.done = String.valueOf(isDone);
            this.nextRecordsUrl = nextPageUrl;
            this.dbSyncTime = String.valueOf(dbsyncTime);
            this.records = woList;
         //   userSettings = settings;
         //   appSettings = appset;
            localTimeZone = localDT;
            viewId = view;
            views = viewList;
            this.soql = sql;
        }
        
        public workorderDCx(LocalTimeZone localDTm, String viewNum, List<DCX_Wrapper.SVMX_StringMap> viewsList,  String que) {
            localTimeZone = localDTm;
            viewId = viewNum;
            views = viewsList;
            this.soql = que;
        }
    }
    
    public class LocalTimeZone {
        public String displayName {get; set;}
        public String id {get; set;}
        public String locale {get; set;}
        public String language {get; set;}
        public LocalTimeZone(String dispName, String tz, String locale, String lang) {
            this.displayName = dispName;
            this.id = tz;
            this.locale = locale;
            this.language = lang;
        }
    }
/*    
    public class workorder_WPDCx{
        public SVMXC__Service_Order__c workorder_O {get;set;}
        public List<workorderSpecialFields_WPDCx> specialFields_LWP {get; set;}
        public long lastSyncedTime;
        public workorder_WPDCx()
        {

        }
        public workorder_WPDCx(SVMXC__Service_Order__c wo){
            workorder_O = wo;
            specialFields_LWP = references;
        }
    }

    public class workorderSpecialFields_WPDCx{
        public String key {get; set;}
        public String value {get; set;}
        public workorderSpecialFields_WPDCx(String tK, String tV){
            this.key = tK;
            this.value = tV;
        }
    }
*/ 

public static workorderDCx singleWO(String woIds, Boolean isInitial) {
long t1 = DateTime.now().getTime();
system.debug('Inside retrieveWorkOrders');
        String UserId = UserInfo.getUserId();
        List<String> dispatchStatus = new List<String>();
        String viewId = '';
         Boolean hasCreatedBy,hasLastModifiedBy;
         hasCreatedBy = false;
        hasLastModifiedBy = false;
       // system.debug('dispatchStatus ::'+dispatchStatus);
        List<DCX_Wrapper.SVMX_StringMap> views = new List<DCX_Wrapper.SVMX_StringMap>();
        
        //fetch the default views if any
        SVMXC.DCX_CommonServiceManager.UserSetting userSettings = SVMXC.DCX_SettingServiceManager.fetchUserSettings();
      //  if(viewId == null || viewId == '')
       //     viewId = userSettings.wo_defaultView;
        
        List<string> lstSubModules = new List<string>{'DCON001'};
        Map<String,String> appSetting = COMM_Utils_ManageSettings.SVMX_getDCSetting(lstSubModules);
system.debug('APP SETTINGS: '+appSetting);      
//      Map<String,String> appSetting = commSettings.SVMX_getSettingList('DCON001');
  
        //fetch pageSize from app settings
        

        //fetch the default svmx setting for dispatch status if any
        //This is executed only for initial DCx launch    
        if(isInitial) {
            if(appSetting.containskey('DCON001_SET007') && appSetting.get('DCON001_SET007') != null) {
                String strDefaultStatus = appSetting.get('DCON001_SET007');
                dispatchStatus = strDefaultStatus.split(',');
            }
            
            views = DCON_Retrieve_Views(UserId);
        }
                
        viewId = UserId;
//long t2 = DateTime.now().getTime();
       // SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        DCX_Utils dcUtils = new DCX_Utils();

        String WhereClause = '';
        String FirstWhereClause = '';
        String SecondWhereClause = '';
        String strPreFilterCriteria = '';
        String strOwnerShipType = '';
        String querySelect = ''; 
//        List<workorder_WPDCx> workorder_LWP = new List<workorder_WPDCx>();
        List<SVMXC__Service_Order__c> workorder_LO = new List<SVMXC__Service_Order__c>();
        List<String> refFields_L = new List<String>();
        List<String> dateTimeFields_L = new List<String>();
        List<String> dateFields_L = new List<String>();
        Map<String,String> replacementRef = new Map<String,String>();
        Map<String,String> replacementNameField = new Map<String,String>();
        Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
//long t21 = DateTime.now().getTime();        
        Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap(); // Get field definition map for work order
//long t22 = DateTime.now().getTime();
        //get wo fields configured in svmx settings       
        Set<string> setWorkOrderFields = getConfiguredWoUpdateFields();
//long t23 = DateTime.now().getTime();        
        //START: DNS-623
        //get the list of WO fields which are to be loaded instead of loading all WO fields
        Set<String> setWOFields = getWOFieldsToLoadInDCx(setWorkOrderFields, userSettings);
//long t24 = DateTime.now().getTime();        
        //get the list of fileds configured by user for a view in SFDC page under 'Dispatch Process -> Dispatch Console Views'
        if(viewId != '' && viewId != null) {
            List<SVMXC__ServiceMax_Config_Data__c> listConfViewFields = new List<SVMXC__ServiceMax_Config_Data__c>();
            listConfViewFields = [Select SVMXC__Field_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: viewId and SVMXC__Expression_Type__c ='SRCH_Object_Fields'];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            for(SVMXC__ServiceMax_Config_Data__c objConf : listConfViewFields)
                setWOFields.add(objConf.SVMXC__Field_Name__c);
        }

        for(String fieldName : setWoFields) {
            if(!fieldName.equalsIgnoreCase('id') && souObjfieldMap.containsKey(fieldName)) {
                Schema.SObjectField fsObj = souObjfieldMap.get(fieldName);
                newSchemaFieldMap.put(fieldName, fsObj);
            }
        }
//long t4 = DateTime.now().getTime();        
DCX_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);
        newSchemaFieldMap.clear();
        souObjfieldMap.clear();
        List<String> limitedFields_L = reference_M.allFields_L; //Get all fields list
        limitedFields_L.add('SVMXC__Violation_Status2__c');
        limitedFields_L.add('SVMXC__Violation_Message__c');
        limitedFields_L.add('SVMXC__Longitude__c');
        limitedFields_L.add('SVMXC__Latitude__c');
        for(String fld : limitedFields_L) {
            if(fld.equalsIgnoreCase('CreatedById'))
                hasCreatedBy = true;
            if(fld.equalsIgnoreCase('LastModifiedById'))
                hasLastModifiedBy = true;
        }
        if(hasCreatedBy)
            limitedFields_L.add('CreatedBy.Name');
        if(hasLastModifiedBy)
            limitedFields_L.add('LastModifiedBy.Name');
        Set<String> limitedFieldSet = new Set<String>();
        limitedFieldSet.addAll(limitedFields_L);
        limitedFields_L.clear();
        limitedFields_L.addAll(limitedFieldSet);
        limitedFieldSet.clear();
        refFields_L = reference_M.referenceFields_L; //Get the reference field list
        dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
        dateFields_L = reference_M.dateFields_L; //Get the date field list
        replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
        replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
        querySelect = dcUtils.SVMX_getFieldNamesFromList(limitedFields_L); 
        system.debug('querySelect :'+querySelect);
//long t5 = DateTime.now().getTime();
        // Build the Work Order query
    
        String strQuery = '';
         WhereClause = 'Id = \''+woIds+'\'';

        if(WhereClause != null && WhereClause.length() > 0) //string.escapeSingleQuotes(
            strQuery = 'SELECT ID,' + querySelect + ' FROM SVMXC__Service_Order__c WHERE ' + WhereClause;
        else
            strQuery = 'SELECT ID,' + querySelect + ' FROM SVMXC__Service_Order__c';

        strQuery = EncodingUtil.urlEncode(strQuery, 'UTF-8');
system.debug('Query Rest API SOQL: '+strQuery);
        String pageSize = '1';
        workorderDCx_INT wowp;
          if(!Test.isRunningTest()){
        wowp = doGet(strQuery, pageSize,true);
          }

        system.debug('wowp '+wowp);
        Long dbsyncTime = DateTime.Now().getTime();
//long t11 = DateTime.now().getTime();        

        LocalTimeZone localTz = new LocalTimeZone(UserInfo.getTimeZone().getDisplayName(),UserInfo.getTimeZone().getID(),UserInfo.getLocale(),UserInfo.getLanguage());
        //create the workorderDCx to be returned with metadata
          if(!Test.isRunningTest()){
        workorderDCx woData = new workorderDCx(wowp.totalSize,wowp.done,null,dbsyncTime,wowp.records,isInitial?localTz:null,viewId,isInitial?views:null,null);

//long t12 = DateTime.now().getTime();
system.debug('woData :'+woData);
        return woData;
          }
          else 
          return null;
    }


    public static DCON_WO_MultiAssign_Response DCX_Manage_Work_Order_MultiAssign_WS(DCON_WO_MultiAssign_Request dcon_Request) 
    {
        /* this is a generic Web Service that can be used as a common entry point for all WO related services */
        // Pavitra: postpone the WO trigger execution
        // WO Trigger is getting executed 8 times (4 set of After + Before)
        allowtriggerExecution = false;
        DCX_WOServiceManager_Util woServUtil = new DCX_WOServiceManager_Util();
        // Create, Delete and Update operation 
        //Save point
        Savepoint sp = Database.setSavepoint();
        string UserId = UserInfo.getUserId();
        DCON_WO_MultiAssign_Response DCON_Response = new DCON_WO_MultiAssign_Response();
        list<string> EventIds = new list<string>();
        SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>{'DCON001_SET009'};
        map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);
        boolean setOwner;
        String StatusMessage;
        DCX_CommonServiceManager.DCEvent_WO_WP eventData = 
            new DCX_CommonServiceManager.DCEvent_WO_WP();
        if(mapSettingValues.containsKey('DCON001_SET009'))
            setOwner = boolean.valueOf(mapSettingValues.get('DCON001_SET009'));
        system.debug(LoggingLevel.Warn, ' Request object  '+dcon_Request);
        try
        {
            If(dcon_Request.operationType == 'WO_UNASSIGN_YES')
            {
                if(dcon_Request.WorkOrderIds != NULL && dcon_Request.WorkOrderIds.size() > 0)
                    StatusMessage = woServUtil.DCON_Unassign_Work_Order_WS(UserId, dcon_Request.WorkOrderIds);
                // When technician id is not given don't do work order assignment
                if(dcon_Request.technicianIds.get(0) != NULL && dcon_Request.technicianIds.get(0) != '')
                woServUtil.DCON_Assign_Work_Order_To_Tech_WS(UserId, dcon_Request.WorkOrderIds, dcon_Request.technicianIds.get(0), setOwner);
                if(dcon_Request.EventList!= null && dcon_Request.EventList.size()>0)                    
                    eventData = 
                        DCX_EventServiceManager.DCX_Upsert_Events_WS4(UserId, 
                                                                      dcon_Request.EventList, 
                                                                      dcon_Request.timeZone, 
                                                                      dcon_Request.lstKeyValue,
                                                                      dcon_Request.technicianIds[0],
                                                                      dcon_Request.techSFId,
                                                                      dcon_Request.woFields);

            }
            else if(dcon_Request.operationType == 'WO_UNASSIGN_NO')
            {   
                if(dcon_Request.EventIds != null && dcon_Request.EventIds.size()>0) {
                    //deleteEvents(dcon_Request.EventIds);
                    woServUtil.deleteEventsUtil(dcon_Request.EventIds);
                }
                if(dcon_Request.EventList != null && dcon_Request.EventList.size()>0)
                    eventData = 
                        DCX_EventServiceManager.DCX_Upsert_Events_WS4 (UserId, dcon_Request.EventList, 
                                                                       dcon_Request.timeZone, 
                                                                       dcon_Request.lstKeyValue,
                                                                       dcon_Request.technicianIds[0],
                                                                       dcon_Request.techSFId,
                                                                       dcon_Request.woFields);

                
                if(dcon_Request.EventIds != null)
                {
                    for(string Eventid :dcon_Request.EventIds)
                    {
                        if(StatusMessage != '')
                            StatusMessage += ',';
                        StatusMessage += Eventid; 
                    }
                }
            }
            //Any exception transaction is rolled back using save point created and throw the exception 
        }   
        catch(DmlException ex)
        {
            Database.rollback(sp);
            system.debug(logginglevel.warn,'ex.getstackTrace()'+ex.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            system.debug(logginglevel.warn,'ex.getstackTrace()'+ex.getStackTraceString());
            system.debug('Main error list'+ex.getmessage());
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
        //Building the Response containg list DC_StringListMap 
        map<String,list<String>> mapTechEventInfo = new map<String,list<String>>();
        for(string eventInfo:EventIds)
        {
            if(eventInfo.contains('_'))
            {
                string TechId = eventInfo.split('_').get(0);    
                if(mapTechEventInfo.containskey(TechId))            
                    mapTechEventInfo.get(TechId).add(eventInfo.substring(TechId.length() +1));
                else
                {
                    list<string> lsteventinfo = new list<string>();
                    lsteventinfo.add(eventInfo.substring(TechId.length() +1));
                    mapTechEventInfo.put(TechId,lsteventinfo);
                }
            }
        }
        for(string TechId:mapTechEventInfo.keyset())
        {
            DC_StringListMap TechEventinfo =  new DC_StringListMap();
            TechEventinfo.key = TechId;
            TechEventinfo.valueList.addall(mapTechEventInfo.get(TechId));
            DCON_Response.lstTechEventDetails.add(TechEventinfo);
        }
        DC_StringListMap DeletedEventinfo =  new DC_StringListMap();
        DeletedEventinfo.key = 'DELETED_EVENT_IDS';
        DeletedEventinfo.valueList.add(StatusMessage);
        DCON_Response.lstTechEventDetails.add(DeletedEventinfo);
        // Pavitra: postpone the WO trigger execution
        // WO Trigger is getting executed 8 times (4 set of After + Before)
        allowtriggerExecution = true;
        system.debug(logginglevel.warn,'DCON_Response:  '+DCON_Response);
        DCON_Response.eventWorkOrderInfo = eventData;
        return DCON_Response;
    }

    public static void deleteEvents(List<String> evtIds) {
        List<Event> SalesforceEventList = [Select Id from Event where Id in :evtIds];
        if(SalesforceEventList.size() > 0){
            delete SalesforceEventList;
        } 
        List<SVMXC__SVMX_Event__c> svmxEvents = [Select Id from SVMXC__SVMX_Event__c where
                                                 Id in :evtIds];
        if(svmxEvents.size() > 0){
            delete svmxEvents;
        }
    }

    public class DCON_WO_MultiAssign_Response
    {
        public List< DC_StringListMap > lstTechEventDetails =  new List< DC_StringListMap >();// Having Technician as key and list having details of all Events for the technician
        public List<DC_StringListMap> getlstTechEventDetails(){return lstTechEventDetails;}
        public void setlstTechEventDetails(List<DC_StringListMap> s ){lstTechEventDetails = s;}
        public DCX_CommonServiceManager.DCEvent_WO_WP eventWorkOrderInfo;
    }

    public class DC_StringListMap
    {
        public String key {get;set;} //Technician Id
        public List<String> valueList = new List<String>();//Details of all Events for Technician(EventID, ActivityDateTime, DurationInMinutes )
        public String fieldsToNull{get;set;}

        public DC_StringListMap(String key,List<String> valueList)
        {
            this.key = key;
            this.valueList = valueList;
        }
        public DC_StringListMap()
        {

        }

        public List<String> getvalueList(){return valueList;}
        public void setvalueList(List<String> s ){valueList = s;}
    }

    public class DCON_WO_MultiAssign_Request 
    { 
        public List<String> workOrderIds = new List<String>();
        public List<String> technicianIds = new List<String>();
        public String operationType{get; set;}   // MULTIASSIGN_YES (if user selects to unassign wo) or MULTIASSIGN_NO (if user selects to keep the assignment and create/delete events)
        public String timezone{get; set;}
        public List<Event> Eventlist = new list<Event>();
        public List< String > EventIds = new List<String>();//Event Ids to delete in MutiTech;
        public List<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new List<DCX_Wrapper.SVMX_StringMap>();
        public String techSFId;
        public List<String> getworkOrderIds(){return workOrderIds;}
        public void setworkOrderIds(List<String> s ){workOrderIds = s;}
        public List<Event> getEventlist(){return Eventlist;}
        public void setEventlist(List<Event> s ){Eventlist = s;}
        public List<String> woFields = new List<String>();
    }

   public static assignWOTeam_Response assignWOTeam(assignWOTeam_Request req) {
        assignWOTeam_Response res = new assignWOTeam_Response();
        List<String> WorkOrderIds =req.WorkOrderIds;
        String TeamId =req.TeamId;
        String dispatchStatus =req.dispatchStatus;
        Boolean unassignWorkorder =req.unassignWorkorder;
        Boolean SetOwner =req.SetOwner;
        String StatusMessage;
        String UserId = UserInfo.getUserId();
        DCX_WOServiceManager_Util woServUtil = new DCX_WOServiceManager_Util();
        if(!Test.isRunningTest()){
         if(dispatchStatus.toUpperCase()!= 'NEW' && unassignWorkorder == true){
                res.deletedEventIds = woServUtil.DCON_Unassign_Work_Order_WS(UserId, WorkOrderIds);
        }
         res.assingedStatus = woServUtil.DCON_Assign_Work_Order_To_Team_WS(UserId,WorkOrderIds,TeamId,SetOwner);
         }
         return res;

    }

        public class assignWOTeam_Response 
        { 
            String deletedEventIds = '';
            String assingedStatus = '';
        }
        public class assignWOTeam_Request 
        { 
            public List<String> WorkOrderIds;
            public String TeamId;
            public Boolean SetOwner;
            public String dispatchStatus;
            public Boolean unassignWorkorder;
            public assignWOTeam_Request() {
                
        }
        
        public assignWOTeam_Request( List<String> WorkOrderIds, String TeamId, Boolean SetOwner,String dispatchStatus,Boolean unassignWorkorder) {
            
            this.WorkOrderIds = WorkOrderIds;
            this.TeamId = TeamId;
            this.SetOwner = SetOwner;
            this.dispatchStatus = dispatchStatus;
            this.unassignWorkorder = unassignWorkorder;
        }
    }

    public static assignWOTeam_Response assignWOTech(assignWOTeam_Request req) {
        assignWOTeam_Response res = new assignWOTeam_Response();
        List<String> WorkOrderIds =req.WorkOrderIds;
        String TeamId =req.TeamId;
        String dispatchStatus =req.dispatchStatus;
        Boolean unassignWorkorder =req.unassignWorkorder;
        Boolean SetOwner =req.SetOwner;
        String StatusMessage;
        String UserId = UserInfo.getUserId();
        DCX_WOServiceManager_Util woServUtil = new DCX_WOServiceManager_Util();
        if(!Test.isRunningTest()){
        if(dispatchStatus.toUpperCase()!= 'NEW' && unassignWorkorder == true){
                    res.deletedEventIds = woServUtil.DCON_Unassign_Work_Order_WS(UserId, WorkOrderIds);
        }
         res.assingedStatus = woServUtil.DCON_Assign_Work_Order_To_Tech_WS(UserId,WorkOrderIds,TeamId,SetOwner);
         }
        return res;
    }
    
    public without sharing class DCX_WOServiceManager_Util {
    
        public void deleteEventsUtil(List<String> eIds) {
            List<Event> SalesforceEventList = [SELECT Id, ActivityDateTime, WhatId, OwnerId from Event where Id 
                                           IN :eIds];
            List<SVMXC__SVMX_Event__c> ServiceMaxEventList = [SELECT Id, SVMXC__ActivityDateTime__c, 
                                                              SVMXC__WhatId__c, SVMXC__Technician__c 
                                                              from SVMXC__SVMX_Event__c where Id IN :eIds];
            if(SalesforceEventList.size() > 0) {
                if( COMM_SecurityUtils.getInstance().isDeletableObject('Event') ) {
                    delete SalesforceEventList;
                } else {
                    throw new DCX_CommonServiceManager.DCxException(System.Label.COMM001_TAG142);
                } 
            }
            if(ServiceMaxEventList.size() > 0)
                COMM_SecurityUtils.getinstance().deleteAsUser(ServiceMaxEventList);    
        }
        
        public  String DCON_Unassign_Work_Order_WS(String UserId, List<String> WorkOrderIds){
            String StatusMessage;
            //Validations
            if(WorkOrderIds.size()==0)
            throw new DCX_CommonServiceManager.DCxException('Please provide some workorders to unassign');
    
            try
            {
                boolean settingRetainDCLock = false;
                SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
            list<string> lstSettings = new list<string>{'DCON001_SET022'};
            map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);
    
                if(mapSettingValues.containsKey('DCON001_SET022') && mapSettingValues.get('DCON001_SET022')=='True')
                    settingRetainDCLock = true;
                else
                    settingRetainDCLock = false;
    
                //Unschedule the work orders related events
                StatusMessage = DCON_Unschedule_Work_Order_WS(UserId, WorkOrderIds);
    
                List<SVMXC__Service_Order__c> UpdatedWorkOrder = new List<SVMXC__Service_Order__c>();
                //updating records
                for(SVMXC__Service_Order__c wo: [SELECT Id,SVMXC__Last_Dispatch_Event__c, SVMXC__Member_Email__c,SVMXC__Service_Duration__c,SVMXC__Idle_Time__c,SVMXC__Driving_Time__c,SVMXC__Group_Email__c,SVMXC__Locked_By_DC__c,SVMXC__Service_Group__c, SVMXC__Group_Member__c, OwnerId, SVMXC__Scheduled_Date_Time__c  from SVMXC__Service_Order__c where Id IN :WorkOrderIds])
                {
                    if(wo.SVMXC__Group_Member__c !=NULL)
                        wo.SVMXC__Last_Dispatch_Event__c = 'UnAssigned';
                    if(wo.SVMXC__Group_Member__c ==NULL && wo.SVMXC__Service_Group__c!=null)
                        wo.SVMXC__Last_Dispatch_Event__c = 'UnQueued';
                    wo.SVMXC__Service_Group__c = NULL;
                    wo.SVMXC__Group_Member__c = NULL;
                    // Bala(4/2/11): Commented
                    //wo.SVMXC__Service_Duration__c=null;
                    //wo.SVMXC__Idle_Time__c = null;
                    //wo.SVMXC__Driving_Time__c = null;
                    wo.SVMXC__Group_Email__c = null;
                    wo.SVMXC__Member_Email__c = null;
                    wo.SVMXC__Scheduled_Date_Time__c = NULL;                
    
                    if(settingRetainDCLock)
                        wo.SVMXC__Locked_By_DC__c = true;
                    else
                        wo.SVMXC__Locked_By_DC__c = false;                
                    wo.SVMXC__Scheduled_Date__c = NULL;
                    UpdatedWorkOrder.add(wo);
                }
    
                //upsert UpdatedWorkOrder;
                // -CRUD
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdatedWorkOrder,COMM_SecurityUtils.Access.Upsertable)) 
                {
                    upsert UpdatedWorkOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } 
                else 
                {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
                //StatusMessage = 'TAG175';
            }
            catch(DmlException ex)
            {
                throw new DCX_CommonServiceManager.DCxException(ex);
            }
            catch(Exception ex)
            {
                throw new DCX_CommonServiceManager.DCxException(ex);
            }
            return StatusMessage;
        }
    
        public  String DCON_Unschedule_Work_Order_WS(String UserId, List<String> WorkOrderIds){
            String StatusMessage = '';
    
            List<Event> events = new List<Event>();
            List<SVMXC__SVMX_Event__c> SVMXevents = new List<SVMXC__SVMX_Event__c>();
            SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
            list<string> lstSettings = new list<string>{'DCON001_SET024'};
            map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);
    
                
            //Validations
    
            if(WorkOrderIds.size()==0)
            throw new DCX_CommonServiceManager.DCxException('Please provide some workorders to unschedule');    
            try{
    
                if(mapSettingValues.containsKey('DCON001_SET024') && mapSettingValues.get('DCON001_SET024')=='True')
                {// Setting to delete Past Events or not
                    events = [SELECT Id from event where WhatId IN :WorkOrderIds];
                    SVMXevents = [SELECT Id from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :WorkOrderIds];
                    for(event objEvent: events)
                    {
                        if(StatusMessage != '')
                            StatusMessage += ',';
                        StatusMessage += objEvent.Id;
                    }
                    for(SVMXC__SVMX_Event__c objEvent: SVMXevents)
                    {
                        if(StatusMessage != '')
                            StatusMessage += ',';
                        StatusMessage += objEvent.Id;
                    }
                }
                else
                {
                    events = [SELECT Id from event where WhatId IN :WorkOrderIds and StartDateTime > :System.now()];
                    SVMXevents = [SELECT Id from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :WorkOrderIds and SVMXC__StartDateTime__c > :System.now()];
                    for(event objEvent: events)
                    {
                        if(StatusMessage != '')
                            StatusMessage += ',';
                        StatusMessage += objEvent.Id;
                    }
                    for(SVMXC__SVMX_Event__c objEvent: SVMXevents)
                    {
                        if(StatusMessage != '')
                            StatusMessage += ',';
                        StatusMessage += objEvent.Id;
                    }
                }
                if(events.size()>0){
                    if( COMM_SecurityUtils.getInstance().isDeletableObject('Event') ){
                        delete events; //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                       throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }                
                }
                if(SVMXevents.size()>0){
                    if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){
                        delete SVMXevents; //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                       throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }                
                }
            }
            catch(DmlException ex)
            {
                throw new DCX_CommonServiceManager.DCxException(ex);
                //throw new SVMXException(ex.getDmlMessage(0));
            }
            catch(Exception ex)
            {
                throw new DCX_CommonServiceManager.DCxException(ex);
                //throw new SVMXException(ex.getMessage());
            }
            return StatusMessage;
        }
    
        public  String DCON_Assign_Work_Order_To_Tech_WS(String UserId, List<String> WorkOrderIds, String TechnicianId, Boolean SetOwner){
            String StatusMessage;
            //Validations
            if(WorkOrderIds.size()==0)
            throw new DCX_CommonServiceManager.DCxException('Please provide some workorders to assign');
            else if(TechnicianId=='')
            throw new DCX_CommonServiceManager.DCxException('Please provide some technician to assign');
            else
            {
                try
                {
                    List<SVMXC__Service_Group_Members__c> tech = new List<SVMXC__Service_Group_Members__c>();
                    tech = [SELECT Id, SVMXC__Salesforce_User__c, SVMXC__Service_Group__c, SVMXC__Service_Group__r.SVMXC__Email__c, SVMXC__Enable_Scheduling__c, SVMXC__Email__c from SVMXC__Service_Group_Members__c where Id = :TechnicianId];
                    List<SVMXC__Service_Order__c> UpdatedWorkOrder = new List<SVMXC__Service_Order__c>();
    
                    //updating records
                    for(SVMXC__Service_Order__c wo: [SELECT Id, SVMXC__Last_Dispatch_Event__c,SVMXC__Locked_By_DC__c,SVMXC__Service_Group__c, SVMXC__Group_Member__c, OwnerId, SVMXC__First_Assigned_DateTime__c, SVMXC__NoOfTimesAssigned__c  from SVMXC__Service_Order__c where Id IN :WorkOrderIds])
                    {
                        //Set the Assigned time and count
                        if(wo.SVMXC__First_Assigned_DateTime__c == NULL)
                        {
                            wo.SVMXC__First_Assigned_DateTime__c = system.now();
                        }
                        if(wo.SVMXC__NoOfTimesAssigned__c == NULL)
                        {
                            wo.SVMXC__NoOfTimesAssigned__c = 1;
                        }
                        else
                        {
                            wo.SVMXC__NoOfTimesAssigned__c = wo.SVMXC__NoOfTimesAssigned__c + 1;
                        }
                        wo.SVMXC__Locked_By_DC__c = true;
                        wo.SVMXC__Last_Dispatch_Event__c = 'Assigned';
                        system.debug('Wo is assigned to');
                        if(tech.isEmpty() == false)
                        {
                            if(tech[0].SVMXC__Service_Group__c!=NULL)
                                wo.SVMXC__Service_Group__c = tech[0].SVMXC__Service_Group__c;
                            wo.SVMXC__Member_Email__c = tech[0].SVMXC__Email__c;
                            wo.SVMXC__Group_Email__c = tech[0].SVMXC__Service_Group__r.SVMXC__Email__c;
                            wo.SVMXC__Group_Member__c = TechnicianId;
                            if(SetOwner==true && tech[0].SVMXC__Salesforce_User__c!=NULL)
                                wo.OwnerId = tech[0].SVMXC__Salesforce_User__c;
                            UpdatedWorkOrder.add(wo);
                        }
                    }
                    if(UpdatedWorkOrder.size() > 0) 
                    {   
                        //upsert UpdatedWorkOrder;
                        // -CRUD
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdatedWorkOrder,COMM_SecurityUtils.Access.Upsertable)) 
                        {
                            upsert UpdatedWorkOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        } 
                        else 
                        {
                            throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                        }
                    }   
    
                    StatusMessage = 'TAG174';
                }
                catch(DmlException ex)
                {
                    throw new DCX_CommonServiceManager.DCxException(ex);
                }
                catch(Exception ex)
                {
                    throw new DCX_CommonServiceManager.DCxException(ex);
                }
            }
            return StatusMessage;
        }

        public  String DCON_Assign_Work_Order_To_Team_WS(String UserId, List<String> WorkOrderIds, String TeamId, Boolean SetOwner){
            String StatusMessage;
            //Validations
    
            if(WorkOrderIds.size()==0)
                throw new DCX_CommonServiceManager.DCxException('Please provide some workorders to assign');
            else if(TeamId=='')
                throw new DCX_CommonServiceManager.DCxException('Please provide some team to assign');
    
            try{
    
                List<SVMXC__Service_Group__c> team = new List<SVMXC__Service_Group__c>();
                team = [SELECT Id, Name, SVMXC__Email__c from SVMXC__Service_Group__c where Id = :TeamId];
    
                //Gettin gqueue Id for the team 
                List<QueueSobject> queue = new List<QueueSobject>();
                if(team.isEmpty() == false)
                {
                    String SOQL  = 'SELECT Id from QueueSobject where SobjectType=\'SVMXC__Service_Order__c\' and Queue.Name = \'' + string.escapeSingleQuotes(team[0].Name) + '\' LIMIT 1';
                    system.debug('TEST TEAM ASSIGN: '+SOQL);       
                    queue = Database.query(SOQL);
                }
                List<SVMXC__Service_Order__c> UpdatedWorkOrder = new List<SVMXC__Service_Order__c>();
    
                //updating records
                for(SVMXC__Service_Order__c wo: [SELECT Id, SVMXC__Last_Dispatch_Event__c,SVMXC__Locked_By_DC__c,SVMXC__Service_Group__c, SVMXC__Group_Member__c, OwnerId, SVMXC__First_Queued_DateTime__c, SVMXC__NoOfTimesQueued__c  from SVMXC__Service_Order__c where Id IN :WorkOrderIds])
                {
                    //Set the Queued time and count
                    if(wo.SVMXC__First_Queued_DateTime__c == NULL)
                    {
                        wo.SVMXC__First_Queued_DateTime__c = system.now();
                    }
                    if(wo.SVMXC__NoOfTimesQueued__c == NULL)
                    {
                        wo.SVMXC__NoOfTimesQueued__c = 1;
                    }
                    else
                    {
                        wo.SVMXC__NoOfTimesQueued__c = wo.SVMXC__NoOfTimesQueued__c + 1;
                    }
                    wo.SVMXC__Last_Dispatch_Event__c = 'Queued';
                    wo.SVMXC__Service_Group__c = TeamId;
                    if(team != null && team.size() > 0)
                        wo.SVMXC__Group_Email__c = team[0].SVMXC__Email__c;
                    wo.SVMXC__Locked_By_DC__c = true;
                    wo.SVMXC__Group_Member__c = NULL;
                    wo.SVMXC__Member_Email__c = NULL;
                    if(SetOwner == true && queue.isEmpty() == false)
                        wo.OwnerId = queue[0].Id;
                    UpdatedWorkOrder.add(wo);
                }
                //upsert UpdatedWorkOrder;
                // -CRUD
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdatedWorkOrder,COMM_SecurityUtils.Access.Upsertable)) 
                {
                    upsert UpdatedWorkOrder;//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } 
                else 
                {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
                StatusMessage = 'TAG174';
    
            }
            catch(DmlException ex)
            {
                throw new DCX_CommonServiceManager.DCxException(ex);
            }
            catch(Exception ex)
            {
                throw new DCX_CommonServiceManager.DCxException(ex);
            }
    
            return StatusMessage;
        }
        
    }

  

    public static list<SVMXC__Service_Order__c> getWO(list<Id> lstWorkOrderIds)
    {
        DCX_Utils utils = new DCX_Utils();
        list<String> lstWorkOrderFields = new list<String>();
        list<SVMXC__Service_Order__c> lstWorkOrder = new list<SVMXC__Service_Order__c>();
        try
        {
            if(lstWorkOrderIds != null && lstWorkOrderIds.size() > 0)
            {
                lstWorkOrderFields = getFieldDefinition(Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap());
                // Get all Work Orders that needs to be preprocessed
                string querySelect = utils.SVMX_getFieldNamesFromList(lstWorkOrderFields); //Convert the list of strings to coma seperated string
                querySelect = querySelect+',SVMXC__Company__r.SVMXC__Preferred_Technician__c' + ',SVMXC__Component__r.SVMXC__Preferred_Technician__c';
                string WhereClause = 'Id IN :lstWorkOrderIds';
                lstWorkOrder = Database.query('SELECT ' + querySelect +' FROM SVMXC__Service_Order__c WHERE '+string.escapeSingleQuotes(WhereClause));
            }
            
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
             throw new DCX_CommonServiceManager.DCxException(ex);
        }
        return lstWorkOrder;
    }

    public static list<String> getFieldDefinition(map<String, SObjectField> objectFieldDefinition)
    {
        list<String> objectFields = new list<String>();
        try
        {
            for(Schema.SObjectField fieldMap: objectFieldDefinition.values())
            {
                // Describe the field to get all properties
                list<SelectOption> lstWofl = new list<SelectOption>();
                Schema.DescribeFieldResult fieldDescribe = fieldMap.getDescribe();
                //CRUD
                //Accessing only updateable fields, isAccessible will retrieve readonly fields also which will create security exception when we are updating readonly fields 
                if(fieldDescribe.isAccessible())
                //if(fieldDescribe.isUpdateable())    
                    objectFields.add(fieldDescribe.getName());
            }
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
             throw new DCX_CommonServiceManager.DCxException(ex);
        }
        return objectFields;
    }


    

    public static SVMXC.DCX_Wrapper.ViewWoCountResponse DCON_ViewWoCount_WS(DCX_Wrapper.ViewWoCountReq req)
    {
        SVMXC.DCX_Wrapper.ViewWoCountResponse response;
        System.debug('ViewId:' + req.viewId);
        
        list<SVMXC__ServiceMax_Processes__c> lstViewrecords = new list<SVMXC__ServiceMax_Processes__c>();
        
        
            if(req.viewId != NULL)
            {
                String viewId = req.viewId;
                try{
                    
                    lstViewrecords = [select Id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__Ownership_Type__c, SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Processes__c where Id =: req.viewId];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        // Check if ViewId is Owner Id / Queue Id or Work Order View Id
                    String strPrefix  = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.getKeyPrefix();
                    // Build the Work Order query           
                    String strPreFilterCriteria = '';
                    String strOwnerShipType = '';
                    String FirstWhereClause = '';
                    String WhereClause = '';
                    String strQuery = '';
                /* Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();   
                    Set<String> setWOFields  = new Set<String>();
                    List<SVMXC__ServiceMax_Config_Data__c> listConfViewFields = new List<SVMXC__ServiceMax_Config_Data__c>();
                    listConfViewFields = [Select SVMXC__Field_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: viewId and SVMXC__Expression_Type__c ='SRCH_Object_Fields'];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(SVMXC__ServiceMax_Config_Data__c objConf : listConfViewFields)
                        setWOFields.add(objConf.SVMXC__Field_Name__c);
                    
                    for(String fieldName : setWoFields) {
                        if(! souObjfieldMap.containsKey(fieldName)) {
                        // Schema.SObjectField fsObj = souObjfieldMap.get(fieldName);
                            //newSchemaFieldMap.put(fieldName, fsObj);
                            return (response  = new SVMXC.DCX_Wrapper.ViewWoCountResponse(viewId,-1));
                        }
                    }*/
                    
                    if(strPrefix == ((req.viewId).substring(0,3))) // It is a Work Order View Id
                        {
                            if(lstViewrecords != NULL && lstViewrecords.size() >0 ) 
                            {
                                if(lstViewrecords[0].SVMXC__Parent_Object_Criteria__c != null)
                                    strPreFilterCriteria = lstViewrecords[0].SVMXC__Parent_Object_Criteria__c;
                                if(lstViewrecords[0].SVMXC__Ownership_Type__c != null)
                                    strOwnerShipType = lstViewrecords[0].SVMXC__Ownership_Type__c;    
                            }
                            else
                            {
                                System.debug('system.label.DCON001_TAG328');
                            }

                            if(strPreFilterCriteria != null && strPreFilterCriteria.length() > 0)
                            {
                                
                                FirstWhereClause = strPreFilterCriteria ;
                                system.debug('FirstWhereClause '+FirstWhereClause);
                            }

                            if(strOwnerShipType != null && strOwnerShipType.length() > 0 && strOwnerShipType == 'User\'s Records')
                            {
                                String strUserId = Userinfo.getUserId();
                                if(FirstWhereClause != null && FirstWhereClause.length() > 0)
                                    FirstWhereClause = ' ( '+FirstWhereClause+ ' ) '+' AND OwnerId =: strUserId';
                                else 
                                    FirstWhereClause += 'OwnerId =: strUserId';
                            }
                        }
                    else // It is Owner Id or Queue Id
                        {
                            FirstWhereClause = 'OwnerId =: viewId';
                        }   
                    
                    WhereClause = FirstWhereClause;
                    if(WhereClause != null && WhereClause.length() > 0) //string.escapeSingleQuotes(
                        strQuery = 'SELECT COUNT(Id) woViewCount_c FROM SVMXC__Service_Order__c WHERE ' + WhereClause;
                    else
                        strQuery = 'SELECT COUNT(Id) woViewCount_c FROM SVMXC__Service_Order__c';
                        
                    System.debug('strQuery:' + strQuery);
                    
                    AggregateResult woCount = Database.query(strQuery);
                    //
                    response  = new SVMXC.DCX_Wrapper.ViewWoCountResponse(viewId,Integer.valueOf(woCount.get('woViewCount_c')));
                    System.debug('response.WOcount:' + response.WOcount);
                }
                catch(Exception ex){
                    response  = new SVMXC.DCX_Wrapper.ViewWoCountResponse(viewId,-1);
                    //return response;
                } 
            }  
       
        return response;
    }  
    public static Set<String> getWorkOrderFieldstoLoadDCx() {
        Set<String> woFldSet = new Set<String>();

        //1. Get the default wo fields to load
        woFldSet.addAll(getDefaultWoFieldstoLoad());
        
        //2. Get the configured wo fields from user settings
        DCX_CommonServiceManager.UserSetting userSettings = DCX_SettingServiceManager.fetchUserSettings();
        Set<String> woCol;
        if(userSettings.wo_grid_conf_fields != null && userSettings.wo_grid_conf_fields.size() > 0) {
            woCol = new Set<String>(userSettings.wo_grid_conf_fields);
            woFldSet.addAll(woCol);
        }
        if(userSettings.wo_grid_col_fields != null && userSettings.wo_grid_col_fields.size() > 0) {
            woCol = new Set<String>(userSettings.wo_grid_col_fields);
            woFldSet.addAll(woCol);
        }
        
        return woFldSet;
        
    }

    private static Set<String> getDefaultWoFieldstoLoad() {
        Set<String> strWorkOrderFields = new Set<String>();
        
        //add following default work order fileds
        strWorkOrderFields.add('SVMXC__Dispatch_Status__c');
        strWorkOrderFields.add('SVMXC__Group_Member__c');
        strWorkOrderFields.add('SVMXC__Service_Group__c');
        strWorkOrderFields.add('SVMXC__Service_Duration__c');
        strWorkOrderFields.add('SVMXC__Driving_Time__c');
        strWorkOrderFields.add('SVMXC__Preferred_Start_Time__c');
        strWorkOrderFields.add('SVMXC__Product__c');
        
        //load JDM fields by default
        strWorkOrderFields.add('SVMXC__SM_Scheduling_Options__c');
        strWorkOrderFields.add('SVMXC__SM_Estimated_Duration__c');
        strWorkOrderFields.add('SVMXC__SM_Scope_Change__c');
        strWorkOrderFields.add('SVMXC__SM_Variance__c');
        strWorkOrderFields.add('SVMXC__SM_Revised_Duration__c');
        strWorkOrderFields.add('SVMXC__SM_Scheduled_Duration__c');
        strWorkOrderFields.add('SVMXC__SM_Unscheduled_Duration__c');
        strWorkOrderFields.add('SVMXC__SM_LJS_Minimum_Schedule_Duration__c');
        strWorkOrderFields.add('SVMXC__Preferred_Business_Hours__c');
        
        //load SLA terms
        strWorkOrderFields.add('SVMXC__Initial_Response_Customer_By__c');
        strWorkOrderFields.add('SVMXC__Onsite_Response_Customer_By__c');
        strWorkOrderFields.add('SVMXC__Resolution_Customer_By__c');
        strWorkOrderFields.add('SVMXC__Restoration_Customer_By__c');
        strWorkOrderFields.add('SVMXC__Initial_Response_Internal_By__c');
        strWorkOrderFields.add('SVMXC__Onsite_Response_Internal_By__c');
        strWorkOrderFields.add('SVMXC__Resolution_Internal_By__c');
        strWorkOrderFields.add('SVMXC__Restoration_Internal_By__c');
        
        //violation fields
        strWorkOrderFields.add('SVMXC__Violation_Status2__c');
        strWorkOrderFields.add('SVMXC__Violation_Message__c');
        
        //Appointment booking
        strWorkOrderFields.add('SVMXC__Work_Order_Scheduling_Status__c');
        strWorkOrderFields.add('SVMXC__SM_Appointment_Type__c');
        strWorkOrderFields.add('SVMXC__Primary_Territory__c');
        
        //location
        strWorkOrderFields.add('SVMXC__City__c');
        strWorkOrderFields.add('SVMXC__Country__c');
        strWorkOrderFields.add('SVMXC__Street__c');
        strWorkOrderFields.add('SVMXC__Zip__c');
        
        //work order level dependency
        strWorkOrderFields.add('SVMXC__Dependency_Group__c');
        strWorkOrderFields.add('SVMXC__Scheduled_Date_Time__c'); 
        
        return strWorkOrderFields;
    }

    
    public static List<DCX_Wrapper.workorder_WP> DCON_Retrieve_Work_Orders(String UserId, 
                                                                String ViewId, 
                                                                List<String> DispatchStatus,
                                                                String timeZone, 
                                                                List<String> workorderIds, 
                                                                List<String> keyValPairs)
    {
        system.debug('Request: ' + workorderIds);
        system.debug('ViewId: ' + ViewId);
        String responseType = '';
        List<String> keyvaluepairlist;
        if(keyValPairs != null && keyValPairs.size() > 0)
        {
            for(Integer i = 0; i < keyValPairs.size(); i++)
            {
                keyvaluepairlist = keyValPairs[i].replace('|', ':').split(':');
                if(keyvaluepairlist == NULL)
                    continue;
                else if(keyvaluepairlist[0] == 'RESPONSETYPE')
                {
                    if(keyvaluepairlist[1] != NULL) 
                        responseType = keyvaluepairlist[1];
                }
            }
        }

        /* If no View Id is passed, set "My Work Orders" view as default */
        if(ViewId == '' && workorderIds == NULL){
            List<DCX_Wrapper.SVMX_StringMap> viewList = new List<DCX_Wrapper.SVMX_StringMap>();
            viewList = DCON_Retrieve_Views(UserId);
            if(viewList[0] != NULL)
                ViewId = viewList[0].Key;
        }

        //SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        DCX_Utils dcUtils = new DCX_Utils();

        String WhereClause;
        String FirstWhereClause = '';
        String SecondWhereClause = '';
        String strPreFilterCriteria = '';
        String strOwnerShipType = '';
        String querySelect; 
        List<DCX_Wrapper.workorder_WP> workorder_LWP = new List<DCX_Wrapper.workorder_WP>();
        List<SVMXC__Service_Order__c> workorder_LO = new List<SVMXC__Service_Order__c>();
        List<String> refFields_L = new List<String>();
        List<String> dateTimeFields_L = new List<String>();
        List<String> dateFields_L = new List<String>();
        Map<String,String> replacementRef = new Map<String,String>();
        Map<String,String> replacementNameField = new Map<String,String>();
        Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
        
        if(responseType.touppercase() == 'IDONLY')
            querySelect = 'Id';
        else if((responseType.touppercase() == 'COMPLETEINFO') || (keyValPairs == null))
        {
            Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap(); // Get field definition map for work order
            
            //START: DNS-623
            //get the list of WO fields which are to be loaded instead of loading all WO fields
            Set<String> setWOFields = getWorkOrderFieldstoLoadDCx();
            
            //get the list of fileds configured by user for a view in SFDC page under 'Dispatch Process -> Dispatch Console Views'
            if(ViewId != '' && ViewId != null)
            {
                List<SVMXC__ServiceMax_Config_Data__c> listConfViewFields = new List<SVMXC__ServiceMax_Config_Data__c>();
                listConfViewFields = [Select SVMXC__Field_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: ViewId and SVMXC__Expression_Type__c ='SRCH_Object_Fields'];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                for(SVMXC__ServiceMax_Config_Data__c objConf : listConfViewFields)
                    setWOFields.add(objConf.SVMXC__Field_Name__c);
            }
            
            //Get only those WO fields which has to be populated, we can skip the rest
            for (String fieldKey : souObjfieldMap.keySet()) 
            {
                String fieldName='';
                Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                fieldName = f.getName();
                if(setWOFields.contains(fieldName))
                    newSchemaFieldMap.put(fieldName, fsObj);
            }
            
            DCX_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);
            newSchemaFieldMap.clear();
            souObjfieldMap.clear();
            List<String> limitedFields_L = reference_M.allFields_L; //Get all fields list
            //END: DNS-623
            refFields_L = reference_M.referenceFields_L; //Get the reference field list
            dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
            dateFields_L = reference_M.dateFields_L; //Get the date field list
            replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
            replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
            querySelect = dcUtils.SVMX_getFieldNamesFromList(limitedFields_L);        
        }

        // Build the Work Order query
        if(ViewId != '' && ViewId != null)
        {
            // Check if ViewId is Owner Id / Queue Id or Work Order View Id
            String strPrefix  = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.getKeyPrefix();
            if(strPrefix == ViewId.substring(0,3)) // It is a Work Order View Id
            {
                list<SVMXC__ServiceMax_Processes__c> lstViews = new list<SVMXC__ServiceMax_Processes__c>();
                lstViews = [select Id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__Ownership_Type__c, SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Processes__c where id =: ViewId];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstViews.size() > 0)
                {
                    if(lstViews[0].SVMXC__Parent_Object_Criteria__c != null)
                        strPreFilterCriteria = lstViews[0].SVMXC__Parent_Object_Criteria__c;
                    if(lstViews[0].SVMXC__Ownership_Type__c != null)
                        strOwnerShipType = lstViews[0].SVMXC__Ownership_Type__c;    
                }
                else
                {
                    throw new DCX_CommonServiceManager.DCxException(system.label.DCON001_TAG328);
                    //throw new SVMXException();
                }

                if(strPreFilterCriteria != null && strPreFilterCriteria.length() > 0)
                {
                    FirstWhereClause = strPreFilterCriteria;
                }

                if(strOwnerShipType != null && strOwnerShipType.length() > 0 && strOwnerShipType == 'User\'s Records')
                {
                    String strUserId = Userinfo.getUserId();
                    if(FirstWhereClause != null && FirstWhereClause.length() > 0)
                        FirstWhereClause = ' ( '+FirstWhereClause+ ' ) '+' AND OwnerId =: strUserId';
                    else 
                        FirstWhereClause += 'OwnerId =: strUserId';
                }
            }
            else // It is Owner Id or Queue Id
            {
                FirstWhereClause = 'OwnerId =: ViewId';
            }   
        }

        if(workorderIds != NULL && workorderIds.size() > 0)
        {
            String InVal = dcUtils.SVMX_get_ListOfValues(workorderIds);
            if(FirstWhereClause != '')
                FirstWhereClause = ' ( '+FirstWhereClause+' ) '+' AND ';
            FirstWhereClause += 'Id IN :workorderIds';
        }

        if(DispatchStatus[0].toUpperCase() != 'ALL')
        {
            //Adding conditions based on the DispatchStatus
            if(FirstWhereClause != null && FirstWhereClause.length() > 0)
            {
                for(String ds: DispatchStatus)
                {
                    if(SecondWhereClause == '')
                        SecondWhereClause += ' AND ( ';
                    else if(ds.toUpperCase()=='NEW' || ds.toUpperCase()=='QUEUED' || ds.toUpperCase()=='ASSIGNED')
                        SecondWhereClause += ' OR ';
                    if(ds.toUpperCase()=='NEW')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c = NULL ) ';
                    else if(ds.toUpperCase()=='QUEUED')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c != NULL ) ';
                    else if(ds.toUpperCase()=='ASSIGNED')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c != NULL) ';//Apurva :Defect - 011238
                }
                SecondWhereClause += ' ) ';
            }      
            else
            {
                for(String ds: DispatchStatus)
                {
                    if((SecondWhereClause != null && SecondWhereClause.length() > 0) && (ds.toUpperCase()=='NEW' || ds.toUpperCase()=='QUEUED' || ds.toUpperCase()=='ASSIGNED'))
                        SecondWhereClause += ' OR ';
                    if(ds.toUpperCase()=='NEW')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c = NULL ) ';
                    else if(ds.toUpperCase()=='QUEUED')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c != NULL ) ';
                    else if(ds.toUpperCase()=='ASSIGNED')
                        SecondWhereClause += ' ( SVMXC__Group_Member__c != NULL ) ';  //Apurva :Defect - 011238  
                }
            }              
        }

        if(FirstWhereClause != null && FirstWhereClause.length() > 0)
        {
            if(SecondWhereClause != null && SecondWhereClause.length() > 0)
                WhereClause = ' ( '+FirstWhereClause+' ) ' + SecondWhereClause;
            else
                WhereClause = FirstWhereClause;
        }
        else
        {
            WhereClause = SecondWhereClause;
        }          

        String strQuery = '';

        if(WhereClause != null && WhereClause.length() > 0) //string.escapeSingleQuotes(
            strQuery = 'SELECT ' + querySelect + ' FROM SVMXC__Service_Order__c WHERE ' + WhereClause;
        else
            strQuery = 'SELECT ' + querySelect + ' FROM SVMXC__Service_Order__c';

            DCX_Wrapper.workorder_WP workorder_WP;
        List<DCX_Wrapper.workorderSpecialFields_WP> specialFields_LWP;

        if(querySelect == 'Id')
        {
            for(SVMXC__Service_Order__c wo: Database.query(strQuery))
            {
                workorder_WP = new DCX_Wrapper.workorder_WP(wo, specialFields_LWP);
                workorder_LWP.add(workorder_WP);
            }
        }
        else
        {
            for(SVMXC__Service_Order__c wo: Database.query(strQuery))
            {
                specialFields_LWP = new List<DCX_Wrapper.workorderSpecialFields_WP>();
                
                for(String s : refFields_L){
                    DCX_Wrapper.workorderSpecialFields_WP tRef;
                    Sobject ref_TO = wo.getSobject(replacementRef.get(s));
                    if(ref_TO!=NULL){
                        tRef = new DCX_Wrapper.workorderSpecialFields_WP(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
                        specialFields_LWP.add(tRef);
                    }
                }
                
                for(String s : dateTimeFields_L){
                    if(wo.get(s) != NULL){
                        system.debug(logginglevel.warn,'WO datetime value'+wo.get(s));
                        DCX_Wrapper.workorderSpecialFields_WP tDateTime = new DCX_Wrapper.workorderSpecialFields_WP(s, ((Datetime)(wo.get(s))).format() );
                        specialFields_LWP.add(tDateTime);
                    }
                }
                for(String s : dateFields_L){
                    if(wo.get(s) != NULL){
                        DCX_Wrapper.workorderSpecialFields_WP tDate = new DCX_Wrapper.workorderSpecialFields_WP(s, Date.valueof(String.valueof(wo.get(s))).format() );
                        specialFields_LWP.add(tDate);
                    }
                }
                workorder_WP = new DCX_Wrapper.workorder_WP(wo, specialFields_LWP);
                workorder_LWP.add(workorder_WP);
            }
        }

        if(workorder_LWP != null && workorder_LWP.size() > 0 )
            workorder_LWP.get(workorder_LWP.size()-1).lastSyncedTime = DateTime.now().getTime();
        else
        {
            set<string> setWorkOrderFields = new set<string>();
            DCX_Wrapper.workorder_WP obj = new DCX_Wrapper.workorder_WP();
            setWorkOrderFields  = getConfiguredWoUpdateFields();
            List<DCX_Wrapper.workorderSpecialFields_WP> FieldUpdateWrapper = new List<DCX_Wrapper.workorderSpecialFields_WP> ();
            if(setWorkOrderFields != null && setWorkOrderFields.size()>0)
            {
                if(workorderIds != NULL && workorderIds.size() > 0)
                    obj = getFieldUpdateWrapper(setWorkOrderFields, workorderIds);
            }
            if(obj != null)
            {   
                obj.lastSyncedTime = DateTime.now().getTime();
            }
            else
            {
                obj = new DCX_Wrapper.workorder_WP();
                obj.lastSyncedTime = DateTime.now().getTime();  
            }       
            workorder_LWP.add(obj);
        }

        return workorder_LWP;
    }

    public static DCX_Wrapper.workorder_WP getFieldUpdateWrapper(set<string> setWorkOrderFields, List<String> workorderIds) 
    {
        SVMXC.DCX_Utils utils = new SVMXC.DCX_Utils(); 
        list<string> lstWorkOrderFields = new list<string>(setWorkOrderFields);
        DCX_Wrapper.workorder_WP WO_WP; 
        string strFieldUpdateFields  = utils.SVMX_getFieldNamesFromList(lstWorkOrderFields); 
        Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap(); 

        List<String> refFields_L = new List<String>();
        List<String> dateTimeFields_L = new List<String>();
        List<String> dateFields_L = new List<String>();
        Map<String,String> replacementRef = new Map<String,String>();
        Map<String,String> replacementNameField = new Map<String,String>();
        Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
        for (String fieldKey : souObjfieldMap.keySet()) 
        {
            String fieldName='';
            Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            fieldName = f.getName();
            if(setWorkOrderFields.contains(fieldName))
                newSchemaFieldMap.put(fieldName, fsObj);
        }
        DCON_Utils dcUtils = new DCON_Utils(); 
        DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);
        newSchemaFieldMap.clear();
        souObjfieldMap.clear();
        List<String> limitedFields_L = reference_M.allFields_L; //Get all fields list
        //END: DNS-623
        refFields_L = reference_M.referenceFields_L; //Get the reference field list
        dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
        dateFields_L = reference_M.dateFields_L; //Get the date field list
        replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
        replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
        string queryWO = 'Select '+strFieldUpdateFields+' From SVMXC__Service_Order__c where Id IN :workorderIds';
        
        System.debug('setWorkOrderFields: '+setWorkOrderFields);
        System.debug('queryWO: '+queryWO);
        for(SVMXC__Service_Order__c wo: Database.query(queryWO))
        {
            System.debug('+++++ Enetered  ');
            List<DCX_Wrapper.workorderSpecialFields_WP> FieldUpdateWrapper = new List<DCX_Wrapper.workorderSpecialFields_WP>();
            
            for(String s : refFields_L)
            {
                DCX_Wrapper.workorderSpecialFields_WP tRef;
                
                Sobject ref_TO = wo.getSobject(replacementRef.get(s));
                if(ref_TO!=NULL)
                {
                    tRef = new DCX_Wrapper.workorderSpecialFields_WP(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
                    FieldUpdateWrapper.add(tRef);
                    if(setWorkOrderFields.contains(s))
                        setWorkOrderFields.remove(s);
                }
            }
            
            for(String s : dateTimeFields_L)
            {
                if(wo.get(s) != NULL)
                {
                    system.debug(logginglevel.warn,'WO datetime value'+wo.get(s));
                    DCX_Wrapper.workorderSpecialFields_WP tDateTime = new DCX_Wrapper.workorderSpecialFields_WP(s, ((Datetime)(wo.get(s))).format() );
                    FieldUpdateWrapper.add(tDateTime);
                    if(setWorkOrderFields.contains(s))
                        setWorkOrderFields.remove(s);
                }
            }
            for(String s : dateFields_L){
                if(wo.get(s) != NULL)
                {
                    DCX_Wrapper.workorderSpecialFields_WP tDate = new DCX_Wrapper.workorderSpecialFields_WP(s, Date.valueof(String.valueof(wo.get(s))).format() );
                    FieldUpdateWrapper.add(tDate);
                    if(setWorkOrderFields.contains(s))
                        setWorkOrderFields.remove(s);
                }
            }
            if(!setWorkOrderFields.isempty() && setWorkOrderFields.size()>0)
            {
                for(string s :new list<string>(setWorkOrderFields))
                {
                    DCX_Wrapper.workorderSpecialFields_WP WOField = new DCX_Wrapper.workorderSpecialFields_WP(s, String.valueof(wo.get(s)));
                    FieldUpdateWrapper.add(WOField);
                }
            }
            WO_WP = new DCX_Wrapper.workorder_WP(null,FieldUpdateWrapper);
        }       
            System.debug('WO_WP: '+WO_WP);
        return WO_WP;
    }

    public static List<DCX_Wrapper.workorder_WP> DCON_Retrieve_Eliminated_Work_Order_Info(String UserId, String timeZone, List<String> workorderIds){

        /* Import required classes */
       // SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        DCX_Utils dcUtils = new DCX_Utils(); 
        /* Variable definitions */ 
        String WhereClause;
        String FirstWhereClause = '';
        String querySelect; 
        Boolean isLocal = false;
        List<DCX_Wrapper.workorder_WP> workorder_LWP = new List<DCX_Wrapper.workorder_WP>(); //Result set for the method
        List<SVMXC__Service_Order__c> workorder_LO = new List<SVMXC__Service_Order__c>();
        List<String> refFields_L = new List<String>();
        List<String> dateTimeFields_L = new List<String>();
        List<String> dateFields_L = new List<String>();
        Map<String,String> replacementRef = new Map<String,String>();
        Map<String,String> replacementNameField = new Map<String,String>();
        Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
        
        Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap(); // Get field definition map for work order
        
        //START: DNS-623
        //get the list of WO fields which are to be loaded instead of loading all WO fields
        Set<String> setWOFields = getConfiguredWoUpdateFields();
        //Get only those WO fields which has to be populated, we can skip the rest
        for (String fieldKey : souObjfieldMap.keySet()) 
        {
            String fieldName='';
            Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            fieldName = f.getName();
            if(setWOFields.contains(fieldName))
                newSchemaFieldMap.put(fieldName, fsObj);
        }
        DCX_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);    
        newSchemaFieldMap.clear();
        souObjfieldMap.clear();
        List<String> limitedFields_L = reference_M.allFields_L; //Get the all field list
        //END: DNS-623
        
        refFields_L = reference_M.referenceFields_L; //Get the reference field list
        dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
        dateFields_L = reference_M.dateFields_L; //Get the date field list
        replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
        replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
        querySelect = dcUtils.SVMX_getFieldNamesFromList(limitedFields_L); //Convert the list of strings to coma seperated string

        //Check for User TimeZone
        //User UserDetail = [SELECT TimeZoneSidKey from User where Id = :UserId];
        if(!UserId.equals(Userinfo.getUserId()))
            timeZone = [SELECT TimeZoneSidKey from User where Id = :UserId].TimeZoneSidKey;
        else
            timeZone = Userinfo.getTimeZone().getID();
        isLocal = true;

        if(workorderIds != NULL && workorderIds.size()>0){
            String InVal = dcUtils.SVMX_get_ListOfValues(workorderIds);
            if(FirstWhereClause != '')
                FirstWhereClause += ' AND ';
            FirstWhereClause += 'Id IN :workorderIds';
            system.debug('FirstWhereClause'+FirstWhereClause);
            WhereClause = FirstWhereClause;
        }
        
        DCX_Wrapper.workorder_WP workorder_WP;
        List<DCX_Wrapper.workorderSpecialFields_WP> specialFields_LWP;
        try
        {
            for(SVMXC__Service_Order__c wo:  Database.query('SELECT ' + querySelect +' FROM SVMXC__Service_Order__c WHERE '+string.escapeSingleQuotes(WhereClause))){
                specialFields_LWP = new List<DCX_Wrapper.workorderSpecialFields_WP>();

                for(String s : refFields_L){
                    DCX_Wrapper.workorderSpecialFields_WP tRef;
                    Sobject ref_TO = wo.getSobject(replacementRef.get(s));
                    if(ref_TO!=NULL){
                        tRef = new DCX_Wrapper.workorderSpecialFields_WP(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
                        specialFields_LWP.add(tRef);
                    }
                }

                for(String s : dateTimeFields_L){
                    DCX_Wrapper.workorderSpecialFields_WP tDateTime;
                    if(wo.get(s) != NULL){
                        tDateTime = new DCX_Wrapper.workorderSpecialFields_WP(s, dcUtils.getDateTimeInTimezone(Datetime.valueof(wo.get(s)).date(), Datetime.valueof(wo.get(s)).time(), timeZone).format() );
                        specialFields_LWP.add(tDateTime);
                    }
                }

                for(String s : dateFields_L){
                    DCX_Wrapper.workorderSpecialFields_WP tDate;
                    if(wo.get(s) != NULL){
                        tDate = new DCX_Wrapper.workorderSpecialFields_WP(s, Date.valueof(String.valueof(wo.get(s))).format() );
                        specialFields_LWP.add(tDate);
                    }
                }
                workorder_WP = new DCX_Wrapper.workorder_WP(wo,specialFields_LWP);
                workorder_LWP.add(workorder_WP);
            }
        }
        catch(Exception ex){
            throw new DCX_CommonServiceManager.DCxException(ex);
        }
        return workorder_LWP;

    }

    public class Workorder_Dependency_Request 
    {
        public List<Event> lstSFEvent = new list<Event>();
        public List<SVMXC__SVMX_Event__c> lstSVMXEvent = new List<SVMXC__SVMX_Event__c>();
        public String timeZone{get;set;}
        public String userId{get;set;}
        public List<String> listWOIds = new List<String>();
        public Workorder_Dependency_Request(List<Event> lstSFEvent, List<SVMXC__SVMX_Event__c> lstSVMXEvent, String timeZone,String userId,List<String> listWOIds)
        {
            this.lstSFEvent = lstSFEvent; 
            this.timeZone = timeZone;
            this.lstSVMXEvent = lstSVMXEvent;
            this.userId = userId;
            this.listWOIds = listWOIds;
        }
        public Workorder_Dependency_Request() {}
    }   

public class Workorder_Dependency_Response
    {
        public List<Preferrable_Workorder_Timings> woDetails= new List<Preferrable_Workorder_Timings>();
        public List<EventErrorMessage> eventDetails= new List<EventErrorMessage>();
        
        public Workorder_Dependency_Response(List<Preferrable_Workorder_Timings> woDetails, List<EventErrorMessage> eventDetails)
        {
            this.woDetails = woDetails;
            this.eventDetails = eventDetails;
        }
        public Workorder_Dependency_Response() {}    
    }
public class EventErrorMessage
{
    public String eventId{get;set;}
    public String woId{get;set;}
    public String errorMessage{get;set;}
    public String typeOfTimeDependency{get;set;}
    public String typeOfResourceDependency{get;set;}
    public EventErrorMessage(String eventId, String woId, String errorMessage, String typeOfTimeDependency,String typeOfResourceDependency)
        {
            this.eventId = eventId; 
            this.woId = woId;   
            this.errorMessage = errorMessage;
            this.typeOfTimeDependency = typeOfTimeDependency;
            this.typeOfResourceDependency = typeOfResourceDependency;   
        }
    
    public EventErrorMessage() {}
}   
public class Preferrable_Workorder_Timings 
{
    public String woId{get;set;} 
    public String minStarttime{get;set;} 
    public String maxStarttime{get;set;} 
    public String minEndtime{get;set;} 
    public String maxEndtime{get;set;}
    public String dependencyGroupName{get;set;}
    public Preferrable_Workorder_Timings(String woId,String minStarttime,String maxStarttime,String minEndtime,String maxEndtime,String dependencyGroupName)
    {
        this.woId = woId;
        this.minStarttime = minStarttime;
        this.maxStarttime = maxStarttime;   
        this.minEndtime = minEndtime;
        this.maxEndtime = maxEndtime;
        this.dependencyGroupName = dependencyGroupName;
                    
    }
    public Preferrable_Workorder_Timings() {}    
}
public class Dependency_Details 
{
    public String woId{get;set;}
    public Boolean isPrimaryWorkOrder{get;set;}
    public String dependencyGroup{get;set;}
    public String maximumDeviation{get;set;}
    public String maximumDeviationUnits{get;set;}
    public String minimumDeviation{get;set;}
    public String minimumDeviationUnits{get;set;}
    public String primaryWorkOrder{get;set;}
    public String secondaryWorkOrder{get;set;}
    public String primaryWorkOrderName{get;set;}
    public String secondaryWorkOrderName{get;set;}
    public String resourceDependency{get;set;}
    public String timeDependency{get;set;}
    public String technicianId{get;set;}
    public String technicianName{get;set;}
    public String scheduledStartTime{get;set;}
    public String serviceDuration{get;set;}
    public String breakTime{get;set;}
    public String driveTimeBefore{get;set;}
    public String driveTimeAfter{get;set;}
    public String overHeadTimeBefore{get;set;}
    public String overHeadTimeAfter{get;set;}
    public String primaryWOName{get;set;}
    public String dependencyGroupName{get;set;}
    public Dependency_Details(String woId,Boolean isPrimaryWorkOrder,String dependencyGroup,String maximumDeviation,String maximumDeviationUnits,
                              String minimumDeviation,String minimumDeviationUnits,String primaryWorkOrder,String secondaryWorkOrder,String resourceDependency,String timeDependency) 
    {
        this.woId =woId;
        this.isPrimaryWorkOrder = isPrimaryWorkOrder;
        this.dependencyGroup = dependencyGroup;
        this.maximumDeviation = maximumDeviation;
        this.maximumDeviationUnits = maximumDeviationUnits;
        this.minimumDeviation = minimumDeviation;
        this.minimumDeviationUnits = minimumDeviationUnits;
        this.primaryWorkOrder = primaryWorkOrder;
        this.secondaryWorkOrder = secondaryWorkOrder;
        this.resourceDependency = resourceDependency;
        this.timeDependency = timeDependency;
    }
    public Dependency_Details() {}

}  
/**
@ public Name : DCON_WO_Dependency_Check_WS
@ Description     : Method used to check whether workorder is scheduling according to workorder dependencies or not
@ Input Parameter : Workorder_dependency_request req
                    lstSFEvent   - list of salesforce events going to be created
                    lstSVMXEvent - list of servicemax event going to be created
                    timezone     - timezone to maintain datetime fields in sync 
                    userId       - user Id 
@ Output Parameter: Workorder_Dependency_Response response
                    Preferrable_Workorder_Timings (wrapper)
                        woId - workorder Id
                        minStarttime  - minimium scheduleable start time of workorder according to the dependencies exists.
                        maxStarttime  - maximium scheduleable start time of workorder according to the dependencies exists.
                        minEndtime    - minimium scheduleable end time of workorder according to the dependencies exists.
                        maxEndtime    - maximium scheduleable end time of workorder according to the dependencies exists.   
                        dependencyGroupName - dependency group where above workorder belongs
                    EventErrorMessage (Wrapper) 
                        eventId      - event Id incase of reassigning workorder
                        woId         - workorder Id for which event is going to be created
                        errorMessage - Error message if time and resource dependency are violated while scheduling workorder
                        typeOfTimeDependency     - type of time dependency that workorder belongs
                        typeOfResourceDependency - type of resource dependency that workorder belongs
                         
                    
*/  
public static Workorder_Dependency_Response DCON_WO_Dependency_Check_WS(Workorder_Dependency_Request req)
    {
        Workorder_Dependency_Response response = new Workorder_Dependency_Response();
        try
        {
             system.debug(logginglevel.warn,'Req:  '+ Req);
             response = DCON_WO_Dependency_Check(req.lstSFEvent, req.lstSVMXEvent, req.timeZone);
             System.Debug(logginglevel.warn,'response : '+response);
        }
        catch(DmlException ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(ex);
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(ex);
        }
        return response;
    }
/**
@ Method Name     : DCON_WO_Dependency_Check
@ Description     : Method used to check whether workorder is scheduling according to workorder dependencies or not
@ Input Parameter : lstSFEvent   - list of salesforce events going to be created
                    lstSVMXEvent - list of servicemax event going to be created
                    timezone     - timezone to maintain datetime fields in sync
@ Output Parameter: Workorder_Dependency_Response response
*/  

 public static Workorder_Dependency_Response DCON_WO_Dependency_Check(List<Event> lstSFEvent, List<SVMXC__SVMX_Event__c> lstSVMXEvent, String timeZone)
 {
     DCX_Utils dcUtils =new DCX_Utils();
    Workorder_Dependency_Response response = new Workorder_Dependency_Response();
    List<EventErrorMessage> lstEventErrorMsgs = new List<EventErrorMessage>();
    List<Preferrable_Workorder_Timings> lstWOtimings = new List<Preferrable_Workorder_Timings>();
    Set<String> eventWOIds = new Set<String>();
    Set<String> eventWOIds1 = new Set<String>();
    Map<String,String> mapSFEventIdWOId = new Map<String,String>();
    Map<String,String> mapSVMXEventIdWOId = new Map<String,String>();
    Map<String,String> mapWOIdGroupId = new Map<String,String>();
    String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
    Map<String,List<SVMXC__Service_Order_Dependency__c>> mapGroupWODependencies = new Map<String,List<SVMXC__Service_Order_Dependency__c>>();
    Set<String> setownerIds = new Set<String>();
    Map<String,String> mapTechSFUser = new Map<String,String>();
    Map<String, List<Datetime>> mapWOStartEndtime = new Map<String, List<Datetime>>();
    Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
    Schema.Describesobjectresult discResUser = allObjs.get('User').getDescribe();
    List<String> lstTechnicians = new List<String>();           
    Map<String,String> mapPicklistValLable = new Map<String,String>();
    String strtimeDependacncyLabel = '';
    
    Schema.DescribeFieldResult fieldResult = SVMXC__Service_Order_Dependency__c.SVMXC__Time_Dependency__c.getDescribe();
    List<Schema.PicklistEntry> plv = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry f : plv)
    {
       System.debug('Field Label ' + f.getLabel());
       System.debug('Field Value ' + f.getValue());
       mapPicklistValLable.put(f.getValue(),f.getLabel());
    }
    if(lstSFEvent != null && lstSFEvent.size() > 0)
    {
        for(Event sfevt: lstSFEvent)
        {
            if(String.valueOf(sfevt.WhatId) != null && !String.isBlank(String.valueOf(sfevt.WhatId)))
            {
                if(woKeyPrefix.equals(String.valueOf(sfevt.WhatId).substring(0,3)))
                {
                    eventWOIds.add(String.valueOf(sfevt.whatId));
                    mapSFEventIdWOId.put(String.valueOf(sfevt.Id), String.valueOf(sfevt.whatId));
                    if(String.valueof(sfevt.OwnerId).startsWith(discResUser.getKeyPrefix()))
                    {
                        setownerIds.add(sfevt.OwnerId); 
                    }   
                    else
                    {
                        lstTechnicians.add(sfevt.OwnerId);  
                    }       
                }   
            }
        }
    }
    
    if(lstSVMXEvent != null && lstSVMXEvent.size() > 0)
    {
        for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvent)
        {
            if(String.valueOf(svmxevt.SVMXC__WhatId__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__WhatId__c)))
            {
                if(woKeyPrefix.equals(String.valueOf(svmxevt.SVMXC__WhatId__c).substring(0,3)))
                {
                    eventWOIds.add(String.valueOf(svmxevt.SVMXC__WhatId__c));
                    mapSVMXEventIdWOId.put(String.valueOf(svmxevt.Id), String.valueOf(svmxevt.SVMXC__WhatId__c));
                    lstTechnicians.add(svmxevt.SVMXC__Technician__c);
                }
            }
        }
    }
    
    Map<Id,SVMXC__Service_Order__c> mapWOIdRecord1;
    if(eventWOIds != null && eventWOIds.size() > 0)
    {
        mapWOIdRecord1 = new Map<Id,SVMXC__Service_Order__c>([SELECT Id, 
                                                                SVMXC__Dependency_Group__c,
                                                                SVMXC__Service_Duration__c,
                                                                SVMXC__Scheduled_Date_Time__c,
                                                                SVMXC__Dispatch_Process__c,
                                                                SVMXC__Driving_Time__c 
                                                                FROM SVMXC__Service_Order__c WHERE Id IN :eventWOIds]);
    }                                                           
    
    for(SVMXC__Service_Order__c wo: mapWOIdRecord1.values())
    {
        mapWOIdGroupId.put(String.valueOf(wo.Id), String.valueOf(wo.SVMXC__Dependency_Group__c));   
    }
    
    Map<Id,SVMXC__Dependency_Management__c> mapGroupIdRecord = new Map<Id,SVMXC__Dependency_Management__c>([SELECT Id,SVMXC__Dependency_Group_Name__c,Name
                                                                FROM SVMXC__Dependency_Management__c WHERE Id IN :mapWOIdGroupId.values()]); 
                                                                
    Map<Id,SVMXC__Service_Order_Dependency__c> mapdependencyIdRecord = new Map<Id,SVMXC__Service_Order_Dependency__c>([SELECT Id,                                                          
                                                                SVMXC__Dependency_Group__c,                                                           
                                                                SVMXC__Maximum_Time_Deviation__c,
                                                                SVMXC__Maximum_Time_Deviation_Units__c,
                                                                SVMXC__Minimum_Time_Deviation__c,
                                                                SVMXC__Minimum_Time_Deviation_Units__c,
                                                                SVMXC__Primary_Work_Order__c,
                                                                SVMXC__Resource_Dependency__c,
                                                                SVMXC__Secondary_Work_Order__c,
                                                                SVMXC__Time_Dependency__c 
                                                                FROM SVMXC__Service_Order_Dependency__c WHERE SVMXC__Dependency_Group__c IN :mapWOIdGroupId.values()]);
    
    eventWOIds1.addAll(eventWOIds); 
    for(SVMXC__Service_Order_Dependency__c dependency: mapdependencyIdRecord.values())
    {
        eventWOIds1.add(dependency.SVMXC__Primary_Work_Order__c);
        eventWOIds1.add(dependency.SVMXC__Secondary_Work_Order__c);
        if(mapGroupWODependencies.containsKey(dependency.SVMXC__Dependency_Group__c))
        {
            mapGroupWODependencies.get(dependency.SVMXC__Dependency_Group__c).add(dependency);
        }
        else
        {
            List<SVMXC__Service_Order_Dependency__c> tempdep = new List<SVMXC__Service_Order_Dependency__c>();
            tempdep.add(dependency);
            mapGroupWODependencies.put(String.valueOf(dependency.SVMXC__Dependency_Group__c),tempdep);
        }   
        
    }
    System.debug('mapGroupWODependencies:'+ mapGroupWODependencies);
    
    Map<Id,SVMXC__Service_Order__c> mapWOIdRecord;
    
    if(eventWOIds1 != null && eventWOIds1.size() > 0)
    {
        mapWOIdRecord = new Map<Id,SVMXC__Service_Order__c>([SELECT Id,Name,                                                           
                                                                SVMXC__Dependency_Group__c,
                                                                SVMXC__Service_Duration__c,
                                                                SVMXC__Scheduled_Date_Time__c,
                                                                SVMXC__Dispatch_Process__c,
                                                                SVMXC__Driving_Time__c,
                                                                SVMXC__Group_Member__c  
                                                                FROM SVMXC__Service_Order__c WHERE Id IN :eventWOIds1]);
    }
    System.debug('mapWOIdRecord:'+ mapWOIdRecord);
    
    for(SVMXC__Service_Order_Dependency__c dependency: mapdependencyIdRecord.values())
    {
        if(mapWOIdRecord.containsKey(dependency.SVMXC__Primary_Work_Order__c)){
            lstTechnicians.add(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c);  
        }
    }   
    
    
    Map<Id,SVMXC__Service_Group_Members__c> mapTechIdRecord;
    
    if(setownerIds != null && setownerIds.size() > 0 && lstTechnicians != null && lstTechnicians.size() > 0)
    {   
        mapTechIdRecord = new Map<Id,SVMXC__Service_Group_Members__c>([Select Id, Name, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c IN :setownerIds OR Id IN :lstTechnicians]);
    }
    else if(setownerIds != null && setownerIds.size() > 0)
    {
        mapTechIdRecord = new Map<Id,SVMXC__Service_Group_Members__c>([Select Id, Name, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c IN :setownerIds]);   
    }
    else if(lstTechnicians != null && lstTechnicians.size() > 0)
    {
        mapTechIdRecord = new Map<Id,SVMXC__Service_Group_Members__c>([Select Id, Name, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where Id IN :lstTechnicians]);   
    }       
    for(SVMXC__Service_Group_Members__c tech: mapTechIdRecord.values())    
        {
            if(tech.SVMXC__Salesforce_User__c != null)
                mapTechSFUser.put(tech.SVMXC__Salesforce_User__c,tech.Id);    
        }
    Boolean primaryWOOfDependency = false;
    Boolean secondaryWOOfDependency = false;
    Boolean isResourceDependencyPassed = true; 
    Integer serviceDuration = 0;
    Integer minDeviation = 0;
    Integer maxDeviation = 0;
    String typeOfTimeDependency = '';
    String typeOfResourceDependency = '';
    Datetime MinStartdatetime;
    Datetime MaxStartdatetime;
    Datetime MinEnddatetime;
    Datetime MaxEnddatetime;
    Boolean minGreatThanMax;
    
    if(lstSFEvent != null && lstSFEvent.size() > 0)
    {
    for(Event sfevt : lstSFEvent)
    {
        primaryWOOfDependency = false;
        secondaryWOOfDependency = false;
        typeOfTimeDependency = '';
        typeOfResourceDependency = '';
        String infoString = '';
        isResourceDependencyPassed = true; 
        
        if(sfevt.whatId != null && woKeyPrefix.equals(String.valueOf(sfevt.whatId).substring(0,3)))
        {
        
        for(SVMXC__Service_Order_Dependency__c dependency: mapGroupWODependencies.get(mapWOIdRecord.get(sfevt.whatId).SVMXC__Dependency_Group__c))
        {
            serviceDuration = 0;
            minDeviation = 0;
            maxDeviation = 0;
            if(String.isBlank(infoString))
            {   
            
            if((String.valueOf(sfevt.whatId)).equals(String.valueOf(dependency.SVMXC__Primary_Work_Order__c)) || (String.valueOf(sfevt.whatId)).equals(String.valueOf(dependency.SVMXC__Secondary_Work_Order__c)))
            {
                if((String.valueOf(sfevt.whatId)).equals(String.valueOf(dependency.SVMXC__Primary_Work_Order__c)))
                {
                    primaryWOOfDependency = true;   
                    
                }
                else if((String.valueOf(sfevt.whatId)).equals(String.valueOf(dependency.SVMXC__Secondary_Work_Order__c)))
                {
                    secondaryWOOfDependency = true;
                    if(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c != null && mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c != null)
                    {
                        if(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c != null)
                        {   
                            if(dependency.SVMXC__Resource_Dependency__c == 'Same Resource')
                                {
                                    if(String.valueof(sfevt.OwnerId).startsWith(discResUser.getKeyPrefix()))
                                    {
                                        if(mapTechSFUser.get(sfevt.ownerId) == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c)
                                            isResourceDependencyPassed = true;  
                                        else
                                        {
                                            isResourceDependencyPassed = false; 
                                            typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                            infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG002 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" ' + system.label.DCON006_TAG003;
                                            /*infoString = infoString + 'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must also assign this work order to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" or remove the resource dependency of type "Same".';
                                            infoString = infoString + 'Because you assigned the primary work order in this dependency to Technician "xyz", you must also assign this work order to Technician "xyz" or remove the resource dependency of type "Same".'; */
                                        }
                                    }
                                    else
                                    {
                                        if(sfevt.ownerId == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c)
                                            isResourceDependencyPassed = true;  
                                        else
                                        {
                                            isResourceDependencyPassed = false; 
                                            typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                            infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG002 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" ' + system.label.DCON006_TAG003;
                                            /*infoString = infoString + 'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must also assign this work order to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" or remove the resource dependency of type "Same".'; 
                                            infoString = infoString + 'Because you assigned the primary work order in this dependency to Technician "xyz", you must also assign this work order to Technician "xyz" or remove the resource dependency of type "Same".'; */
                                        }
                                    }   
                                }
                            
                            if(dependency.SVMXC__Resource_Dependency__c == 'Different Resource')
                                {
                                    if(String.valueof(sfevt.OwnerId).startsWith(discResUser.getKeyPrefix()))
                                    {
                                        if(!(mapTechSFUser.get(sfevt.ownerId) == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c))
                                            isResourceDependencyPassed = true;  
                                        else
                                        {
                                            isResourceDependencyPassed = false; 
                                            typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                            infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG004;
                                            /*infoString = infoString +'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must assign this work order to a different technician or remove the resource dependency of type "Different".';
                                            infoString = infoString +'Because you assigned the primary work order in this dependency to Technician "xyz", you must assign this work order to a different technician or remove the resource dependency of type "Different".'; */
                                        }
                                    }
                                    else
                                    {
                                        if(!(sfevt.ownerId == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c))
                                            isResourceDependencyPassed = true;  
                                        else
                                        {
                                            isResourceDependencyPassed = false; 
                                            typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                            infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG004;
                                            /*infoString = infoString +'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must assign this work order to a different technician or remove the resource dependency of type "Different".';
                                            infoString = infoString +'Because you assigned the primary work order in this dependency to Technician "xyz", you must assign this work order to a different technician or remove the resource dependency of type "Different".'; */ 
                                        }
                                    }   
                                    
                                }
                                
                        }
                        else
                        {
                            isResourceDependencyPassed = true;
                        }   
                        
                        if(isResourceDependencyPassed)
                        {   
                            if(!mapWOStartEndtime.containsKey(String.valueOf(sfevt.whatId)))
                            {
                            if(dependency.SVMXC__Maximum_Time_Deviation__c != null){
                                if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Hours'){
                                    maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c * 60);
                                }
                                else if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Days'){
                                    maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c * 24 *60);
                                }
                                else if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Minutes'){
                                    maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c);
                                }
                            }
                            if(dependency.SVMXC__Minimum_Time_Deviation__c != null){
                                if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Hours'){
                                    minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c * 60);
                                }
                                else if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Days'){
                                    minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c * 24 *60);
                                }
                                else if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Minutes'){
                                    minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c);
                                }
                            }

                            if(maxDeviation != null && minDeviation != null) {
                                if(minDeviation > maxDeviation) {
                                    minDeviation = 0;
                                    maxDeviation = 0;
                                    minGreatThanMax = true;
                                }
                            }
                            
                            if(dependency.SVMXC__Time_Dependency__c == 'Start to Start' || dependency.SVMXC__Time_Dependency__c == 'Start in Unison')
                            {
                                if(dependency.SVMXC__Time_Dependency__c == 'Start in Unison')
                                {
                                    minDeviation = 0;
                                    maxDeviation = 0;
                                }
                                typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                    strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                minStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c).addMinutes(minDeviation);
                                if((dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) && dependency.SVMXC__Time_Dependency__c == 'Start to Start') 
                                {
                                    maxStartdatetime = null;
                                } else {
                                    maxStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c).addMinutes(maxDeviation);
                                }           
                            }
                            else if(dependency.SVMXC__Time_Dependency__c == 'Start to Finish')
                            {
                                typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                    strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                minEnddatetime = mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation);
                                if(dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) 
                                {
                                    maxEnddatetime = null;
                                } else {
                                    maxEnddatetime = mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation);
                                }
                            }
                            else if(dependency.SVMXC__Time_Dependency__c == 'Finish to Start')
                            {
                                typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                    strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                minStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                if(dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) 
                                {
                                    maxStartdatetime = null;
                                } else {
                                    maxStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                }               
                            }
                            else if(dependency.SVMXC__Time_Dependency__c == 'Finish to Finish' || dependency.SVMXC__Time_Dependency__c == 'Finish in Unison')
                            {
                                if(dependency.SVMXC__Time_Dependency__c == 'Finish in Unison')
                                {
                                    minDeviation = 0;
                                    maxDeviation = 0;
                                }
                                typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                    strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                minEnddatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                if((dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) && dependency.SVMXC__Time_Dependency__c == 'Finish to Finish')
                                {
                                    maxEnddatetime = null;
                                } else {
                                    maxEnddatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                }                           
                            }
                            }   
                        }
                    }
                    else
                    {
                        infoString = infoString + system.label.DCON006_TAG005 + ' ' + mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).Name + ' ' + system.label.DCON006_TAG006;
                        System.debug('The primary work order <WO> has not been scheduled.  You must schedule the primary work that this depends on order before attempting to schedule this one.');
                    }
                }
            }
        }
        }

        System.debug('wo exists:'+ mapWOStartEndtime.containsKey(String.valueOf(sfevt.whatId)));
        if(!mapWOStartEndtime.containsKey(String.valueOf(sfevt.whatId)))
        {   
            List<datetime> lstdatetimes = new List<datetime>();
            lstdatetimes.add(minStartdatetime);
            lstdatetimes.add(maxStartdatetime);
            lstdatetimes.add(minEnddatetime);
            lstdatetimes.add(maxEnddatetime);
            System.debug('lstdatetimes:'+lstdatetimes);
            mapWOStartEndtime.put(String.valueOf(sfevt.whatId),lstdatetimes);
        }
        System.debug('mapWOStartEndtime:'+ mapWOStartEndtime);              
        if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)) != null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).size() > 0)
        {   
            if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) != null || mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(1) != null || mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) != null || mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) != null)
            {
                If(sfevt.SVMXC__Overhead_Time_After__c == null)
                    sfevt.SVMXC__Overhead_Time_After__c = 0;
        
                If(sfevt.SVMXC__Overhead_Time_Before__c == null)
                    sfevt.SVMXC__Overhead_Time_Before__c = 0;
        
                If(sfevt.SVMXC__Break_Time_Total__c == null)
                    sfevt.SVMXC__Break_Time_Total__c = 0;
        
                If(sfevt.SVMXC__Driving_Time_Home__c == null)
                    sfevt.SVMXC__Driving_Time_Home__c = 0;
        
                If(sfevt.SVMXC__Driving_Time__c == null)
                    sfevt.SVMXC__Driving_Time__c = 0;
                
                datetime tempWOstarttime =  DCX_Utils.doTZConversion(((sfevt.StartDateTime.addMinutes(Integer.valueOf(sfevt.SVMXC__Driving_Time__c))).addMinutes(Integer.valueOf(sfevt.SVMXC__Overhead_Time_Before__c))),timeZone,'GMT');
                System.debug('tempWOstarttime:'+ tempWOstarttime);
                //calculate end time if does not exist
                datetime tempWOendtime;
                if(sfevt.EndDateTime != null)
                {
                    tempWOendtime = DCX_Utils.doTZConversion(((sfevt.EndDateTime.addMinutes(-Integer.valueOf(sfevt.SVMXC__Driving_Time_Home__c))).addMinutes(-Integer.valueOf(sfevt.SVMXC__Overhead_Time_After__c))),timeZone,'GMT');
                    System.debug('tempWOstarttime:'+ tempWOstarttime);
                }
                else
                {
                    tempWOendtime = DCX_Utils.doTZConversion((((sfevt.StartDateTime.addMinutes(Integer.valueOf(sfevt.DurationInMinutes))).addMinutes(-Integer.valueOf(sfevt.SVMXC__Driving_Time_Home__c))).addMinutes(-Integer.valueOf(sfevt.SVMXC__Overhead_Time_After__c))),timeZone,'GMT'); 
                    System.debug('tempWOstarttime:'+ tempWOstarttime);                          
                }       
                if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) != null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(1) != null && tempWOstarttime < mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) || tempWOstarttime > mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(1))
                {
                    infoString = infoString + system.label.DCON006_TAG007;  
                }
                if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) != null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(3) != null && tempWOendtime < mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) || tempWOendtime > mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(3))
                {
                    infoString = infoString + system.label.DCON006_TAG008;  
                }
                if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) != null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(1) == null && tempWOstarttime < mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) )
                {
                    infoString = infoString + system.label.DCON006_TAG007;  
                }   
                
                if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) != null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(3) == null && tempWOendtime < mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2))
                {
                    infoString = infoString + system.label.DCON006_TAG008;  
                }
            }
        }
        system.debug('primaryWOOfDependency:'+ primaryWOOfDependency);
        system.debug('secondaryWOOfDependency:'+ secondaryWOOfDependency);
        if(mapWOStartEndtime.containsKey(String.valueOf(sfevt.whatId)) && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) == null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(1) == null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) == null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(3) == null)     
        {   
            if(primaryWOOfDependency == true && secondaryWOOfDependency == false)
            {
                infoString = infoString + 'SUCCESSFUL';
                System.debug('event can be created anywhere');
            }
        }
        EventErrorMessage e = new EventErrorMessage(String.valueOf(sfevt.Id),String.valueOf(sfevt.whatId),infoString,strtimeDependacncyLabel,typeOfResourceDependency);
        lstEventErrorMsgs.add(e);
        
        minStartdatetime = null;
        maxStartdatetime = null;
        minEnddatetime = null;
        maxEnddatetime = null;
        }
    }
    }
    if(lstSVMXEvent != null && lstSVMXEvent.size() > 0)
    {
    for(SVMXC__SVMX_Event__c svmxevt : lstSVMXEvent)
    {
        primaryWOOfDependency = false;
        secondaryWOOfDependency = false;
        typeOfTimeDependency = '';
        typeOfResourceDependency = '';
        String infoString = '';
        isResourceDependencyPassed = true; 
        
        if(svmxevt.SVMXC__WhatId__c != null && woKeyPrefix.equals(String.valueOf(svmxevt.SVMXC__WhatId__c).substring(0,3)))
        {
        
        for(SVMXC__Service_Order_Dependency__c dependency: mapGroupWODependencies.get(mapWOIdRecord.get(svmxevt.SVMXC__WhatId__c).SVMXC__Dependency_Group__c))
        {
            serviceDuration = 0;
            minDeviation = 0;
            maxDeviation = 0;
            if(String.isBlank(infoString))
            {   
            
            if((String.valueOf(svmxevt.SVMXC__WhatId__c)).equals(String.valueOf(dependency.SVMXC__Primary_Work_Order__c)) || (String.valueOf(svmxevt.SVMXC__WhatId__c)).equals(String.valueOf(dependency.SVMXC__Secondary_Work_Order__c)))
            {
                if((String.valueOf(svmxevt.SVMXC__WhatId__c)).equals(String.valueOf(dependency.SVMXC__Primary_Work_Order__c)))
                {
                    primaryWOOfDependency = true;   
                    
                }
                else if((String.valueOf(svmxevt.SVMXC__WhatId__c)).equals(String.valueOf(dependency.SVMXC__Secondary_Work_Order__c)))
                {
                    secondaryWOOfDependency = true;
                    if(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c != null && mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c != null)
                    {
                        if(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c != null)
                        {   
                            if(dependency.SVMXC__Resource_Dependency__c == 'Same Resource')
                            {
                                if(dependency.SVMXC__Resource_Dependency__c == 'Same Resource' && (svmxevt.SVMXC__Technician__c == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c))
                                {
                                    isResourceDependencyPassed = true;  
                                }
                                else
                                {
                                    isResourceDependencyPassed = false; 
                                    typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                    infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG002 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" ' + system.label.DCON006_TAG003;
                                    /*infoString = infoString + 'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must also assign this work order to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" or remove the resource dependency of type "Same".';
                                    infoString = infoString +'Because you assigned the primary work order in this dependency to Technician "xyz", you must also assign this work order to Technician "xyz" or remove the resource dependency of type "Same".';  */  
                                }
                            }
                            if(dependency.SVMXC__Resource_Dependency__c == 'Different Resource')
                            {   
                                if(dependency.SVMXC__Resource_Dependency__c == 'Different Resource'  && !(svmxevt.SVMXC__Technician__c == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c))
                                {
                                    isResourceDependencyPassed = true;  
                                }
                                else
                                {
                                    isResourceDependencyPassed = false; 
                                    typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                    infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG004;
                                    /*infoString = infoString +'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must assign this work order to a different technician or remove the resource dependency of type "Different".';
                                    infoString = infoString +'Because you assigned the primary work order in this dependency to Technician "xyz", you must assign this work order to a different technician or remove the resource dependency of type "Different".'; */
                                }
                            }   
                        }
                        else
                        {
                            isResourceDependencyPassed = true;
                        }   
                        
                        if(isResourceDependencyPassed)
                        {   
                            if(!mapWOStartEndtime.containsKey(String.valueOf(svmxevt.SVMXC__WhatId__c)))
                            {
                            if(dependency.SVMXC__Maximum_Time_Deviation__c != null){
                                if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Hours'){
                                    maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c * 60);
                                }
                                else if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Days'){
                                    maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c * 24 *60);
                                }
                                else if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Minutes'){
                                    maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c);
                                }
                            }
                            if(dependency.SVMXC__Minimum_Time_Deviation__c != null){
                                if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Hours'){
                                    minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c * 60);
                                }
                                else if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Days'){
                                    minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c * 24 *60);
                                }
                                else if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Minutes'){
                                    minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c);
                                }
                            }
                            if(maxDeviation != null && minDeviation != null) {
                                if(minDeviation > maxDeviation) {
                                    minDeviation = 0;
                                    maxDeviation = 0;
                                    minGreatThanMax = true;
                                }
                            }
                            if(dependency.SVMXC__Time_Dependency__c == 'Start to Start' || dependency.SVMXC__Time_Dependency__c == 'Start in Unison')
                            {
                                if(dependency.SVMXC__Time_Dependency__c == 'Start in Unison')
                                {
                                    minDeviation = 0;
                                    maxDeviation = 0;
                                }
                                typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                    strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                minStartdatetime = mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation);
                                if((dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) && dependency.SVMXC__Time_Dependency__c == 'Start to Start') 
                                {
                                    maxStartdatetime = null;
                                } else {
                                    maxStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c).addMinutes(maxDeviation);
                                }
                            }
                            else if(dependency.SVMXC__Time_Dependency__c == 'Start to Finish')
                            {
                                typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                    strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                minEnddatetime = mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation);
                                if(dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) 
                                {
                                    maxEnddatetime = null;
                                } else {
                                    maxEnddatetime = mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation);
                                }
                            }
                            else if(dependency.SVMXC__Time_Dependency__c == 'Finish to Start')
                            {
                                typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                    strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                minStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                if(dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) 
                                {
                                    maxStartdatetime = null;
                                } else {
                                    maxStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                }                        
                            }
                            else if(dependency.SVMXC__Time_Dependency__c == 'Finish to Finish' || dependency.SVMXC__Time_Dependency__c == 'Finish in Unison')
                            {
                                if(dependency.SVMXC__Time_Dependency__c == 'Finish in Unison')
                                {
                                    minDeviation = 0;
                                    maxDeviation = 0;
                                }
                                typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                    strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                minEnddatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                if((dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) && dependency.SVMXC__Time_Dependency__c == 'Finish to Finish')
                                {
                                    maxEnddatetime = null;
                                } else {
                                    maxEnddatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                }                           
                            }
                            }   
                        }
                    }
                    else
                    {
                        infoString = infoString + system.label.DCON006_TAG005 + ' ' + mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).Name + ' ' + system.label.DCON006_TAG006;
                        System.debug('Schedule date time and Service duration of primary work order is not available to calculate start time and end time of secondary workorder');
                    }
                }
            }
        }
        }
        System.debug('wo exists:'+ mapWOStartEndtime.containsKey(String.valueOf(svmxevt.SVMXC__WhatId__c)));
        System.debug('wo not exists:'+ !mapWOStartEndtime.containsKey(String.valueOf(svmxevt.SVMXC__WhatId__c)));
        if(!mapWOStartEndtime.containsKey(String.valueOf(svmxevt.SVMXC__WhatId__c)))
        {   
            System.debug('entering:');
            List<datetime> lstdatetimes = new List<datetime>();
            lstdatetimes.add(minStartdatetime);
            lstdatetimes.add(maxStartdatetime);
            lstdatetimes.add(minEnddatetime);
            lstdatetimes.add(maxEnddatetime);
            System.debug('lstdatetimes:'+lstdatetimes);
            mapWOStartEndtime.put(String.valueOf(svmxevt.SVMXC__WhatId__c),lstdatetimes);
        }
        System.debug('mapWOStartEndtime:'+ mapWOStartEndtime);
        if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)) != null && mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).size() > 0)
        {   
            if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(0) != null || mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(1) != null || mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2) != null || mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2) != null)
            {
                If(svmxevt.SVMXC__Overhead_Time_After__c == null)
                    svmxevt.SVMXC__Overhead_Time_After__c = 0;
        
                If(svmxevt.SVMXC__Overhead_Time_Before__c == null)
                    svmxevt.SVMXC__Overhead_Time_Before__c = 0;
        
                If(svmxevt.SVMXC__Break_Time_Total__c == null)
                    svmxevt.SVMXC__Break_Time_Total__c = 0;
        
                If(svmxevt.SVMXC__Driving_Time_Home__c == null)
                    svmxevt.SVMXC__Driving_Time_Home__c = 0;
        
                If(svmxevt.SVMXC__Driving_Time__c == null)
                    svmxevt.SVMXC__Driving_Time__c = 0;
                
                datetime tempWOstarttime =  DCX_Utils.doTZConversion(((svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueOf(svmxevt.SVMXC__Driving_Time__c))).addMinutes(Integer.valueOf(svmxevt.SVMXC__Overhead_Time_Before__c))),timeZone,'GMT');
                //calculate end time if does not exist
                datetime tempWOendtime;
                if(svmxevt.SVMXC__EndDateTime__c != null)
                {
                    tempWOendtime = DCX_Utils.doTZConversion(((svmxevt.SVMXC__EndDateTime__c.addMinutes(-Integer.valueOf(svmxevt.SVMXC__Driving_Time_Home__c))).addMinutes(-Integer.valueOf(svmxevt.SVMXC__Overhead_Time_After__c))),timeZone,'GMT');
                }
                else
                {
                    tempWOendtime = DCX_Utils.doTZConversion((((svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueOf(svmxevt.SVMXC__DurationInMinutes__c))).addMinutes(-Integer.valueOf(svmxevt.SVMXC__Driving_Time_Home__c))).addMinutes(-Integer.valueOf(svmxevt.SVMXC__Overhead_Time_After__c))),timeZone,'GMT');    
                }       
                if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(0) != null && mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(1) != null && tempWOstarttime < mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(0) || tempWOstarttime > mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(1))
                {
                    infoString = infoString + system.label.DCON006_TAG007;  
                }
                if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2) != null && mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(3) != null && tempWOendtime < mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2) || tempWOendtime > mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(3))
                {
                    infoString = infoString + system.label.DCON006_TAG008;  
                }
                if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(0) != null && mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(1) == null && tempWOstarttime < mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(0) )
                {
                    infoString = infoString + system.label.DCON006_TAG007;  
                }   
                
                if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2) != null && mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(3) == null && tempWOendtime < mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2))
                {
                    infoString = infoString + system.label.DCON006_TAG008;  
                }
            }
        }
        system.debug('primaryWOOfDependency:'+ primaryWOOfDependency);
        system.debug('secondaryWOOfDependency:'+ secondaryWOOfDependency);
        if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).size() == 0) 
        {   
            if(primaryWOOfDependency == true && secondaryWOOfDependency == false)
            {
                infoString = infoString + 'SUCCESSFUL';
                System.debug('event can be created anywhere');
            }
        }
        EventErrorMessage e = new EventErrorMessage(String.valueOf(svmxevt.Id),String.valueOf(svmxevt.SVMXC__WhatId__c),infoString,strtimeDependacncyLabel,typeOfResourceDependency);
        lstEventErrorMsgs.add(e);
        
        minStartdatetime = null;
        maxStartdatetime = null;
        minEnddatetime = null;
        maxEnddatetime = null;
        }
    }
    }
    for(String wo: mapWOStartEndtime.keySet())
    {
        if(mapWOStartEndtime.get(wo) != null && mapWOStartEndtime.get(wo).size() > 0)
        {
            if(((mapWOStartEndtime.get(wo)).get(1)) != null || ((mapWOStartEndtime.get(wo)).get(3))!= null)
            {
                Preferrable_Workorder_Timings tempWODetails = new Preferrable_Workorder_Timings(wo,String.valueOfGmt(DCX_Utils.doTZConversion(((mapWOStartEndtime.get(wo)).get(0)),'GMT',timeZone)),String.valueOfGmt(DCX_Utils.doTZConversion(((mapWOStartEndtime.get(wo)).get(1)),'GMT',timeZone)),String.valueOfGmt(DCX_Utils.doTZConversion(((mapWOStartEndtime.get(wo)).get(2)),'GMT',timeZone)),String.valueOfGmt(DCX_Utils.doTZConversion(((mapWOStartEndtime.get(wo)).get(3)),'GMT',timeZone)),String.valueOf(mapGroupIdRecord.get(mapWOIdRecord.get(wo).SVMXC__Dependency_Group__c).Name));
                lstWOtimings.add(tempWODetails);
            }
            if(((mapWOStartEndtime.get(wo)).get(1)) == null && ((mapWOStartEndtime.get(wo)).get(3))== null)
            {
                Preferrable_Workorder_Timings tempWODetails = new Preferrable_Workorder_Timings(wo,String.valueOfGmt(DCX_Utils.doTZConversion(((mapWOStartEndtime.get(wo)).get(0)),'GMT',timeZone)),null,String.valueOfGmt(DCX_Utils.doTZConversion(((mapWOStartEndtime.get(wo)).get(2)),'GMT',timeZone)),null,String.valueOf(mapGroupIdRecord.get(mapWOIdRecord.get(wo).SVMXC__Dependency_Group__c).Name));
                lstWOtimings.add(tempWODetails);
            }
        }
    }

    response.woDetails.addAll(lstWOtimings);
    response.eventDetails.addAll(lstEventErrorMsgs);
    lstWOtimings.clear();
    lstEventErrorMsgs.clear();
    System.debug('response:'+ response);
    return response;
}
/**
@ public Name : DCON_WO_Get_Dependency_Details_WS
@ Description     : Method used to fetch dependency details for work order id's sent in the request
@ Input Parameter : Workorder_dependency_request req
                    listWOIds - list of WO id's
@ Output Parameter: List<Dependency_Details>
                    list of wrapper containing dependency details.     
                    
*/
public static List<Dependency_Details> DCON_WO_Get_Dependency_Details_WS(Workorder_Dependency_Request req) {
    DCX_Utils dcUtils =new DCX_Utils();
    Set<String> setReqWOIds = new Set<String>();
    setReqWOIds.addAll(req.listWOIds);
    List<Dependency_Details> listDependencyDetails = new List<Dependency_Details>();
    Set<String> setWOIds = new Set<String>();
    setWOIds.addAll(setReqWOIds);
    System.debug('setWOIds '+setWOIds);
    List<SVMXC__Service_Order_Dependency__c> listDependency = new list<SVMXC__Service_Order_Dependency__c>([SELECT Id,                                                            
                                                            SVMXC__Dependency_Group__r.name,                                                             
                                                            SVMXC__Maximum_Time_Deviation__c,
                                                            SVMXC__Maximum_Time_Deviation_Units__c,
                                                            SVMXC__Minimum_Time_Deviation__c,
                                                            SVMXC__Minimum_Time_Deviation_Units__c,
                                                            SVMXC__Primary_Work_Order__c,
                                                            SVMXC__Resource_Dependency__c,
                                                            SVMXC__Secondary_Work_Order__c,
                                                            SVMXC__Time_Dependency__c 
                                                            FROM SVMXC__Service_Order_Dependency__c WHERE SVMXC__Primary_Work_Order__c IN :setReqWOIds OR SVMXC__Secondary_Work_Order__c IN :setReqWOIds]);
    for(SVMXC__Service_Order_Dependency__c dependency : listDependency) {
        setWOIds.add(dependency.SVMXC__Primary_Work_Order__c);
        setWOIds.add(dependency.SVMXC__Secondary_Work_Order__c);
    }

    Map<Id,SVMXC__Service_Order__c> mapWo = new Map<Id,SVMXC__Service_Order__c>([Select id,SVMXC__Group_Member__c,SVMXC__Group_Member__r.name, 
                                                                                                SVMXC__Scheduled_Date_Time__c
                                                                                                FROM SVMXC__Service_Order__c WHERE id IN :setWOIds]);
    
    List<event> lstSFEvent = new List<event>([Select id, StartDateTime,SVMXC__Service_Duration__c, SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, WhatId,
                                                        SVMXC__Break_Time_Total__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c 
                                                        FROM event WHERE WhatId IN : setWOIds]);
                                                        System.debug('lstSFEvent '+lstSFEvent.size());                                                  
    List<SVMXC__SVMX_Event__c> lstSVMXEvent = new List<SVMXC__SVMX_Event__c>([Select id,SVMXC__StartDateTime__c, SVMXC__Service_Duration__c, SVMXC__Driving_Time__c,SVMXC__Service_Order__c,
                                                                                            SVMXC__Driving_Time_Home__c, SVMXC__Break_Time_Total__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c
                                                                                            FROM SVMXC__SVMX_Event__c WHERE SVMXC__Service_Order__c IN : setWOIds]);
                                                                                            System.debug('lstSVMXEvent '+lstSVMXEvent.size()); 
    Map<String,event> mapWOEvents = new Map<String,Event>();
    Map<String,SVMXC__SVMX_Event__c> mapWOSvmxEvents = new Map<String,SVMXC__SVMX_Event__c>();
    for(event sfevent: lstSFEvent) {
        if(mapWo.containsKey(sfevent.Whatid) && mapWo.get(sfevent.Whatid).SVMXC__Scheduled_Date_Time__c != null) {
            if(sfevent.StartDateTime == mapWo.get(sfevent.Whatid).SVMXC__Scheduled_Date_Time__c) {
                mapWOEvents.put(sfevent.whatId,sfevent);
            }
        }
    }
    System.debug('mapWOEvents '+mapWOEvents.size()); 
    for(SVMXC__SVMX_Event__c svmxevent : lstSVMXEvent) {
        if(mapWo.containsKey(svmxevent.SVMXC__Service_Order__c) && mapWo.get(svmxevent.SVMXC__Service_Order__c).SVMXC__Scheduled_Date_Time__c != null) {
            if(svmxevent.SVMXC__StartDateTime__c == mapWo.get(svmxevent.SVMXC__Service_Order__c).SVMXC__Scheduled_Date_Time__c) {
                mapWOSvmxEvents.put(svmxevent.SVMXC__Service_Order__c,svmxevent);
            }
        }
    }
    System.debug('mapWOSvmxEvents '+mapWOSvmxEvents.size()); 
    for(SVMXC__Service_Order_Dependency__c dependency : [SELECT Id,                                                            
                                                            SVMXC__Dependency_Group__c,
                                                            SVMXC__Dependency_Group__r.Name,                                                             
                                                            SVMXC__Maximum_Time_Deviation__c,
                                                            SVMXC__Maximum_Time_Deviation_Units__c,
                                                            SVMXC__Minimum_Time_Deviation__c,
                                                            SVMXC__Minimum_Time_Deviation_Units__c,
                                                            SVMXC__Primary_Work_Order__c,
                                                            SVMXC__Primary_Work_Order__r.SVMXC__Group_Member__c,
                                                            SVMXC__Primary_Work_Order__r.Name,
                                                            SVMXC__Resource_Dependency__c,
                                                            SVMXC__Secondary_Work_Order__c,
                                                            SVMXC__Secondary_Work_Order__r.name,
                                                            SVMXC__Time_Dependency__c 
                                                            FROM SVMXC__Service_Order_Dependency__c WHERE SVMXC__Primary_Work_Order__c IN :setReqWOIds OR SVMXC__Secondary_Work_Order__c IN :setReqWOIds]) {

        if(setReqWOIds.contains(dependency.SVMXC__Primary_Work_Order__c)) {
            Dependency_Details dependencyDetails = new Dependency_Details();
            dependencyDetails.woId = dependency.SVMXC__Primary_Work_Order__c;
            dependencyDetails.isPrimaryWorkOrder = true;
            dependencyDetails.dependencyGroup = dependency.SVMXC__Dependency_Group__c;
            dependencyDetails.maximumDeviation = String.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c);
            dependencyDetails.maximumDeviationUnits = dependency.SVMXC__Maximum_Time_Deviation_Units__c;
            dependencyDetails.minimumDeviation = String.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c);
            dependencyDetails.minimumDeviationUnits = dependency.SVMXC__Minimum_Time_Deviation_Units__c;
            dependencyDetails.primaryWorkOrder = dependency.SVMXC__Primary_Work_Order__c;
            dependencyDetails.secondaryWorkOrder = dependency.SVMXC__Secondary_Work_Order__c;
            dependencyDetails.primaryWorkOrderName = dependency.SVMXC__Primary_Work_Order__r.Name;
            dependencyDetails.secondaryWorkOrderName = dependency.SVMXC__Secondary_Work_Order__r.Name;
            dependencyDetails.resourceDependency = dependency.SVMXC__Resource_Dependency__c;
            dependencyDetails.timeDependency = dependency.SVMXC__Time_Dependency__c;
            dependencyDetails.technicianId = null;
            listDependencyDetails.add(dependencyDetails);
        }
        if(setReqWOIds.contains(dependency.SVMXC__Secondary_Work_Order__c)) {
            Dependency_Details dependencyDetails = new Dependency_Details();
            dependencyDetails.woId = dependency.SVMXC__Secondary_Work_Order__c;
            dependencyDetails.isPrimaryWorkOrder = false;
            dependencyDetails.dependencyGroup = dependency.SVMXC__Dependency_Group__c;
            dependencyDetails.maximumDeviation = String.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c);
            dependencyDetails.maximumDeviationUnits = dependency.SVMXC__Maximum_Time_Deviation_Units__c;
            dependencyDetails.minimumDeviation = String.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c);
            dependencyDetails.minimumDeviationUnits = dependency.SVMXC__Minimum_Time_Deviation_Units__c;
            dependencyDetails.primaryWorkOrder = dependency.SVMXC__Primary_Work_Order__c;
            dependencyDetails.secondaryWorkOrder = dependency.SVMXC__Secondary_Work_Order__c;
            dependencyDetails.primaryWorkOrderName = dependency.SVMXC__Primary_Work_Order__r.Name;
            dependencyDetails.secondaryWorkOrderName = dependency.SVMXC__Secondary_Work_Order__r.Name;
            dependencyDetails.resourceDependency = dependency.SVMXC__Resource_Dependency__c;
            dependencyDetails.timeDependency = dependency.SVMXC__Time_Dependency__c;
            if(mapWo.get(dependency.SVMXC__Primary_Work_Order__c) != null) {
                dependencyDetails.technicianId = mapWo.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c;
                dependencyDetails.technicianName = mapWo.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__r.name;
            }
            dependencyDetails.primaryWOName = dependency.SVMXC__Primary_Work_Order__r.Name;
            dependencyDetails.dependencyGroupName = dependency.SVMXC__Dependency_Group__r.Name;
            List<event> sfEvents = new List<event>();
            List<SVMXC__SVMX_Event__c> svmxEvents = new List<SVMXC__SVMX_Event__c>();
            system.debug('mapWo '+mapWo);
            if(mapWo.containsKey(dependency.SVMXC__Primary_Work_Order__c)) {
                if(mapWOEvents.get(dependency.SVMXC__Primary_Work_Order__c) != null) {
                    sfEvents.add(mapWOEvents.get(dependency.SVMXC__Primary_Work_Order__c));
                }
                if(mapWOSvmxEvents.get(dependency.SVMXC__Primary_Work_Order__c) != null) {
                    svmxEvents.add(mapWOSvmxEvents.get(dependency.SVMXC__Primary_Work_Order__c));
                }
            }
            
            if (sfEvents.size() == 0 && svmxEvents.size() == 0) {
                listDependencyDetails.add(dependencyDetails);
                continue;
            }
            if(svmxEvents.size() == 0 || (sfEvents.size() != 0 && svmxEvents.size() != 0 && sfEvents[0].StartDateTime > svmxEvents[0].SVMXC__StartDateTime__c)) {
                if(sfEvents.size() != 0) {
                    dependencyDetails.scheduledStartTime = String.valueOfGMT(DCX_Utils.doTZConversion(sfEvents[0].StartDateTime,'GMT',req.timezone));
                    dependencyDetails.serviceDuration = String.valueOf(sfEvents[0].SVMXC__Service_Duration__c);
                    dependencyDetails.breakTime = String.valueOf(sfEvents[0].SVMXC__Break_Time_Total__c);
                    dependencyDetails.driveTimeBefore = String.valueOf(sfEvents[0].SVMXC__Driving_Time__c);
                    dependencyDetails.driveTimeAfter = String.valueOf(sfEvents[0].SVMXC__Driving_Time_Home__c);
                    dependencyDetails.overHeadTimeBefore = String.valueOf(sfEvents[0].SVMXC__Overhead_Time_Before__c);
                    dependencyDetails.overHeadTimeAfter = String.valueOf(sfEvents[0].SVMXC__Overhead_Time_After__c);
                }
            }

            if(sfEvents.size() == 0 || (sfEvents.size() != 0 && svmxEvents.size() != 0 && sfEvents[0].StartDateTime < svmxEvents[0].SVMXC__StartDateTime__c)) {
                if(svmxEvents.size() != 0) {
                    dependencyDetails.scheduledStartTime = String.valueOfGMT(DCX_Utils.doTZConversion(svmxEvents[0].SVMXC__StartDateTime__c,'GMT',req.timezone));
                    dependencyDetails.serviceDuration = String.valueOf(svmxEvents[0].SVMXC__Service_Duration__c);
                    dependencyDetails.breakTime = String.valueOf(svmxEvents[0].SVMXC__Break_Time_Total__c);
                    dependencyDetails.driveTimeBefore = String.valueOf(svmxEvents[0].SVMXC__Driving_Time__c);
                    dependencyDetails.driveTimeAfter = String.valueOf(svmxEvents[0].SVMXC__Driving_Time_Home__c);
                    dependencyDetails.overHeadTimeBefore = String.valueOf(svmxEvents[0].SVMXC__Overhead_Time_Before__c);
                    dependencyDetails.overHeadTimeAfter = String.valueOf(svmxEvents[0].SVMXC__Overhead_Time_After__c);
                }
            }


            
            listDependencyDetails.add(dependencyDetails);
        }

    }

    //Workorder_Dependency_Response response = new Workorder_Dependency_Response();
    //response.listDependencyDetails = listDependencyDetails;
    return listDependencyDetails;
}

        public static DCX_Wrapper.DCTech_WO_Response_WP DCON_AES_Unassign_WO_WS(DCX_Wrapper.DCTech_WO_WP request)
        {
            SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>{'DCON001_SET022'};
        map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);
            DCX_Wrapper.DCTech_WO_Response_WP resp = new DCX_Wrapper.DCTech_WO_Response_WP();
            //Validations
            if(request.WorkOrderId == '' || request.TechId == '')
                throw new DCX_CommonServiceManager.DCxException('Please provide workorderId and/or techId to unassign');
                //throw new SVMXException('Please provide workorderId and/or techId to unassign');

            try
            {
                boolean settingRetainDCLock = false;

                if(mapSettingValues.Containskey('DCON001_SET022') && mapSettingValues.get('DCON001_SET022') == 'True')
                    settingRetainDCLock = true;
                else
                    settingRetainDCLock = false;

                //Unschedule the work orders related events
                resp = DCON_AES_Delete_Tech_Events(request);
                If(request.isUnassignTech)
                {
                    DCON_UnAssign_WO(request);
                }   
            }
            catch(DmlException ex)
            {
                throw new DCX_CommonServiceManager.DCxException(ex);
            }
            catch(Exception ex)
            {
                throw new DCX_CommonServiceManager.DCxException(ex);
            }
            return resp;
        }

        public static DCX_Wrapper.DCTech_WO_Response_WP DCON_AES_Delete_Tech_Events(DCX_Wrapper.DCTech_WO_WP request)
    {
        DCX_Utils dcUtils = new DCX_Utils();
        DateTime dtmStartDateTime;
        DCX_Wrapper.DCTech_WO_Response_WP resp = new DCX_Wrapper.DCTech_WO_Response_WP();
        
        List<Event> SFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> SVMXEvents = new List<SVMXC__SVMX_Event__c>();

        SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>{'DCON001_SET024'};
        map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);
        
        if(request.WorkOrderId.length() == 0)
            throw new DCX_CommonServiceManager.DCxException('Please provide some workorders to unschedule');
            //throw new SVMXException('Please provide some workorders to unschedule'); 
        
        try
        {
            if(request.timeZone == NULL || request.timeZone == '')
            {
                request.timeZone = Userinfo.getTimeZone().getID();
            }
            System.debug('request.EventStartDtTm:' + request.EventStartDtTm);
            System.debug('request.isDeleteAllEvents'+request.isDeleteAllEvents);
            System.debug('request.deleteSingleEventId'+request.deleteSingleEventId);
            if(request.EventStartDtTm == null && !request.isDeleteAllEvents && !String.isBlank(request.deleteSingleEventId))
            {
                List<String> evtIds = new List<String>();
                evtIds.add(request.deleteSingleEventId);
                String statusMsg = DCON_Event_WS.DCON_Delete_Events_WS(null,evtIds); 
                If (statusMsg.equalsIgnoreCase('Events deleted successfully'))
                {
                    if(resp.StatusMessage != '')
                    resp.StatusMessage += ',';
                
                    resp.StatusMessage += request.deleteSingleEventId;  
                }
            }   
            else if(request.EventStartDtTm != null)
            {
                dtmStartDateTime = DCX_Utils.doTZConversion(request.EventStartDtTm, request.timeZone, 'GMT');
                
                if(request.isEarlierEvents)
                {
                    //Check if deleting past events are allowed
                    if(mapSettingValues.Containskey('DCON001_SET024') && mapSettingValues.get('DCON001_SET024') == 'true')
                    {
                        SFEvents = [SELECT Id, SVMXC__Service_Duration__c
                                    FROM event 
                                    WHERE WhatId =:request.WorkOrderId
                                    AND OwnerId =:request.OwnerId
                                    AND StartDateTime <= :dtmStartDateTime];
                                        
                        SVMXEvents = [SELECT Id, SVMXC__Service_Duration__c
                                    FROM SVMXC__SVMX_Event__c 
                                    WHERE (SVMXC__WhatId__c =:request.WorkOrderId 
                                    OR SVMXC__Service_Order__c =:request.WorkOrderId)
                                    AND SVMXC__Technician__c =:request.TechId
                                    AND SVMXC__StartDateTime__c <= :dtmStartDateTime];
                    }
                    //Check if only the selected events and the events earlier than the selected events are to be deleted
                    else
                    {
                        SFEvents = [SELECT Id, SVMXC__Service_Duration__c
                                    FROM event 
                                    WHERE (WhatId =:request.WorkOrderId
                                    AND OwnerId =:request.OwnerId
                                    AND StartDateTime <= :dtmStartDateTime
                                    AND StartDateTime >= :System.now()) OR Id = :request.eventId];
                                        
                        SVMXEvents = [SELECT Id, SVMXC__Service_Duration__c
                                    FROM SVMXC__SVMX_Event__c 
                                    WHERE ((SVMXC__WhatId__c =:request.WorkOrderId 
                                    OR SVMXC__Service_Order__c =:request.WorkOrderId)
                                    AND SVMXC__Technician__c =:request.TechId
                                    AND SVMXC__StartDateTime__c <= :dtmStartDateTime
                                    AND SVMXC__StartDateTime__c >= :System.now()) OR Id = :request.eventId];
                    }
                }
                //for deleting later events
                else
                {
                    if(mapSettingValues.Containskey('DCON001_SET024') && mapSettingValues.get('DCON001_SET024') == 'true')
                    {
                        SFEvents = [SELECT Id, SVMXC__Service_Duration__c
                                    FROM event 
                                    WHERE WhatId =:request.WorkOrderId
                                    AND OwnerId =:request.OwnerId
                                    AND StartDateTime >= :dtmStartDateTime];
                                        
                        SVMXEvents = [SELECT Id, SVMXC__Service_Duration__c
                                    FROM SVMXC__SVMX_Event__c 
                                    WHERE (SVMXC__WhatId__c =:request.WorkOrderId 
                                    OR SVMXC__Service_Order__c =:request.WorkOrderId)
                                    AND SVMXC__Technician__c =:request.TechId
                                    AND SVMXC__StartDateTime__c >= :dtmStartDateTime];
                    }
                    //Check if only the selected events and the events earlier than the selected events are to be deleted
                    else
                    {
                        SFEvents = [SELECT Id, SVMXC__Service_Duration__c
                                    FROM event 
                                    WHERE (WhatId =:request.WorkOrderId
                                    AND OwnerId =:request.OwnerId
                                    AND StartDateTime >= :dtmStartDateTime
                                    AND StartDateTime >= :System.now()) OR Id = :request.eventId];
                                        
                        SVMXEvents = [SELECT Id, SVMXC__Service_Duration__c
                                    FROM SVMXC__SVMX_Event__c 
                                    WHERE ((SVMXC__WhatId__c =:request.WorkOrderId 
                                    OR SVMXC__Service_Order__c =:request.WorkOrderId)
                                    AND SVMXC__Technician__c =:request.TechId
                                    AND SVMXC__StartDateTime__c >= :dtmStartDateTime
                                    AND SVMXC__StartDateTime__c >= :System.now()) OR Id = :request.eventId];
                    }
                }
            }
            else if(request.EventStartDtTm == null && request.isDeleteAllEvents)
            {
                //This is the setting to delete PAST Events if SET024 is true
                if(mapSettingValues.Containskey('DCON001_SET024') && mapSettingValues.get('DCON001_SET024') == 'true')
                {
                    SFEvents = [SELECT Id, SVMXC__Service_Duration__c
                                FROM event 
                                WHERE WhatId =:request.WorkOrderId];
                                
                    SVMXEvents = [SELECT Id, SVMXC__Service_Duration__c
                                FROM SVMXC__SVMX_Event__c 
                                WHERE (SVMXC__WhatId__c =:request.WorkOrderId 
                                OR SVMXC__Service_Order__c =:request.WorkOrderId)];
                }
                //Check if the past event deletion is not allowed then delete events from the current datetime
                //if SET024 = false, then past events deletion is not allowed
                else
                {
                    SFEvents = [SELECT Id, SVMXC__Service_Duration__c 
                                FROM event 
                                WHERE (WhatId =: request.WorkOrderId 
                                AND StartDateTime >= :System.now()) OR Id = :request.eventId];
                                
                    SVMXEvents = [SELECT Id, SVMXC__Service_Duration__c
                                FROM SVMXC__SVMX_Event__c 
                                WHERE ((SVMXC__Service_Order__c =: request.WorkOrderId
                                OR SVMXC__WhatId__c =:request.WorkOrderId)
                                AND SVMXC__StartDateTime__c >= :System.now()) OR Id = :request.eventId];
                }
            }
            else if(request.EventStartDtTm == null && !request.isDeleteAllEvents)
            {
                //This is the setting to delete PAST Events if SET024 is true
                if(mapSettingValues.Containskey('DCON001_SET024') && mapSettingValues.get('DCON001_SET024') == 'true')
                {
                    SFEvents = [SELECT Id, SVMXC__Service_Duration__c
                                FROM event 
                                WHERE WhatId =:request.WorkOrderId
                                AND OwnerId =:request.OwnerId];
                                
                    SVMXEvents = [SELECT Id, SVMXC__Service_Duration__c
                                FROM SVMXC__SVMX_Event__c 
                                WHERE (SVMXC__WhatId__c =:request.WorkOrderId 
                                OR SVMXC__Service_Order__c =:request.WorkOrderId)
                                AND SVMXC__Technician__c =:request.TechId];
                }
                //Check if the past event deletion is not allowed then delete events from the current datetime
                //if SET024 = false, then past events deletion is not allowed
                else
                {
                    SFEvents = [SELECT Id, SVMXC__Service_Duration__c 
                                FROM event 
                                WHERE (WhatId =: request.WorkOrderId 
                                AND OwnerId =: request.OwnerId
                                AND StartDateTime >= :System.now()) OR Id = :request.eventId];
                                
                    SVMXEvents = [SELECT Id, SVMXC__Service_Duration__c
                                FROM SVMXC__SVMX_Event__c 
                                WHERE ((SVMXC__Service_Order__c =: request.WorkOrderId
                                OR SVMXC__WhatId__c =:request.WorkOrderId)
                                AND SVMXC__Technician__c =: request.TechId
                                AND SVMXC__StartDateTime__c >= :System.now()) OR Id = :request.eventId];
                }
            }
            
            for(event objEvent: SFEvents)
            {
                if(resp.StatusMessage != '')
                    resp.StatusMessage += ',';
                
                resp.StatusMessage += objEvent.Id;
            }
            
            for(SVMXC__SVMX_Event__c objEvent: SVMXEvents)
            {
                if(resp.StatusMessage != '')
                    resp.StatusMessage += ',';
                
                resp.StatusMessage += objEvent.Id;
            }
                    
            if(SFEvents.size() > 0)
            { 
                if( COMM_SecurityUtils.getInstance().isDeletableObject('Event') ){
                    delete SFEvents;  //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
  
                    throw new DCX_CommonServiceManager.DCxException(System.label.COMM001_TAG142);
                }                  
            }
        
            if(SVMXEvents.size() > 0)
            { 
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){
                    delete SVMXEvents;  //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
                    throw new DCX_CommonServiceManager.DCxException(System.label.COMM001_TAG142);
                }                
            }
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(ex);
        }
        return resp;
    }

    public static void DCON_UnAssign_WO(DCX_Wrapper.DCTech_WO_WP request)
    {
        try 
        {
            SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>{'DCON001_SET022'};
        map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);
            boolean settingRetainDCLock = false;
            if(mapSettingValues.Containskey('DCON001_SET022') && mapSettingValues.get('DCON001_SET022') == 'True')
                settingRetainDCLock = true;
            else
                settingRetainDCLock = false;
            
            
             List<SVMXC__Service_Order__c> UpdatedWorkOrder = new List<SVMXC__Service_Order__c>();

            //updating WO record if there are no more evens existing for this WO
            for(SVMXC__Service_Order__c wo: [SELECT Id,
                                            SVMXC__Last_Dispatch_Event__c, 
                                            SVMXC__Member_Email__c,
                                            SVMXC__Service_Duration__c,
                                            SVMXC__Idle_Time__c,
                                            SVMXC__Driving_Time__c,
                                            SVMXC__Group_Email__c,
                                            SVMXC__Locked_By_DC__c,
                                            SVMXC__Service_Group__c, 
                                            SVMXC__Group_Member__c, 
                                            OwnerId, 
                                            SVMXC__Scheduled_Date_Time__c 
                                            FROM SVMXC__Service_Order__c 
                                            WHERE Id =: request.WorkOrderId])
                {
                    if(wo.SVMXC__Group_Member__c != null)
                        wo.SVMXC__Last_Dispatch_Event__c = 'UnAssigned';
                        
                    if(wo.SVMXC__Group_Member__c == null && wo.SVMXC__Service_Group__c != null)
                        wo.SVMXC__Last_Dispatch_Event__c = 'UnQueued';
                        
                    wo.SVMXC__Service_Group__c = null;
                    wo.SVMXC__Group_Member__c = null;
                    wo.SVMXC__Service_Duration__c = null;
                    wo.SVMXC__Group_Email__c = null;
                    wo.SVMXC__Member_Email__c = null;
                    wo.SVMXC__Scheduled_Date_Time__c = null;               

                    if(settingRetainDCLock)
                        wo.SVMXC__Locked_By_DC__c = true;
                    else
                        wo.SVMXC__Locked_By_DC__c = false;
                        
                    wo.SVMXC__Scheduled_Date__c = null;
                    
                    UpdatedWorkOrder.add(wo);
                }
                //upsert UpdatedWorkOrder;
                // -CRUD
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdatedWorkOrder,COMM_SecurityUtils.Access.Upsertable)) 
                    {
                        upsert UpdatedWorkOrder;//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } 
                else 
                    {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                    }
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(ex);
        }
    }

    public static List<String> DCON_Keyword_Search_WS(String UserId, String Keyword, String FindWhat, String KeywordMatch, String SearchType){
        system.debug(LoggingLevel.WARN, 'DCON_Keyword_Search_WS input parameters: UserId - ' + UserId + '; Keyword - ' + Keyword + '; FindWhat - ' + FindWhat + '; KeywordMatch - ' + KeywordMatch + '; SearchType - ' + SearchType);
        // Keeping the Web Service method member names the same, but assigning them to local variables with proper names
        String strSearchText = Keyword;
        String strSearchFields = KeywordMatch;

        // If strSearchText is blank, return error
        if(strSearchText == NULL)
        throw new DCX_CommonServiceManager.DCxException('Please enter valid key values to search');

        List<SVMXC__Service_Group_Members__c> lstAllMatchedTechs = new List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__Service_Group_Product__c> lstTechTeamProducts = new List<SVMXC__Service_Group_Product__c>();
        List<SVMXC__Service_Group_Skills__c> lstTechTeamSkills = new List<SVMXC__Service_Group_Skills__c>();
        List<SVMXC__Territory_Coverage__c> lstTerrCoverage = new List<SVMXC__Territory_Coverage__c>();
        List<SVMXC__Service_Group__c> lstServiceTeams = new List<SVMXC__Service_Group__c>();

        DCX_Utils dcUtils = new DCX_Utils(); 
        List<String> TeamTechList = new List<String>();
        set<String> setTerritoryIds = new set<String>();
        set<Id> TeamTechSet = new set<Id>();
        List<String> lstSearchKeyValues = new List<String>();
        List<String> lstSearchFields = new List<String>();
        List<String> lstKeywordSearchFields = new List<String>();
        List<String> lstDirectQrySrchFields = new List<String>();
        String strTechTeamQueryFields = '';

        // Build an array of search key values by splitting the strSearchText string 
        for(String s : strSearchText.split(',')){
            lstSearchKeyValues.add(s.trim());
        }
        
        // Build an array of search fields by splitting the strSearchFields string
        lstSearchFields = strSearchFields.split(',');
        system.debug(LoggingLevel.WARN, 'lstSearchFields: ' + lstSearchFields);

        List<String> lstSObjFields = new List<String>();
        set<String> setSObjFields = new set<String>();
        Map<String, String> mapFieldNameType = new Map<String, String>();
        Boolean isMatchProduct = false;
        Boolean isMatchSkill = false;
        Boolean isMatchTerritory = false;
        Boolean isIdFieldIncluded = false;

        // Field Types which need quotes while building where clause
        set<String> setStringFieldTypes = new set<String>();
        setStringFieldTypes.add('STRING');
        setStringFieldTypes.add('EMAIL');
        setStringFieldTypes.add('URL');
        setStringFieldTypes.add('TEXT'); 
        setStringFieldTypes.add('PICKLIST');
        setStringFieldTypes.add('Schema.DisplayType.STRING');
        setStringFieldTypes.add('Schema.DisplayType.EMAIL');
        setStringFieldTypes.add('Schema.DisplayType.URL');
        setStringFieldTypes.add('Schema.DisplayType.TEXT'); 
        setStringFieldTypes.add('Schema.DisplayType.PICKLIST');

        try
        {
            // Get the details of all the fields (name & type) for the relevant object
            // DC Utils function SVMX_getAllFieldMap returns field type only if the field is Updateble or is a Formula field
            // Not sure why it was done that way, and not sure which other caller of that function will need it
            // So, not changing the function and commenting the call to that function here
            // But, reusing that function code by embedding it here, except for field type check part.

            if(FindWhat.toUpperCase() == 'TECHNICIAN'){
                Map<String, SObjectField> mapSObjFields = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap();

                for (String fieldKey : mapSObjFields.keySet()) 
                {
                    Schema.SObjectField fsObj = mapSObjFields.get(fieldKey); 
                    Schema.DescribeFieldResult f = fsObj.getDescribe();
                    String fieldName = f.getName();  
                    mapFieldNameType.put(fieldName, String.valueof(f.getType()));
                    system.debug(LoggingLevel.WARN, 'mapFieldNameType  '+fieldName+'  '+String.valueof(f.getType()));
                }
                lstSObjFields = dcUtils.SVMX_getFieldList(mapSObjFields, true); 
            }
            else if(FindWhat.toUpperCase() == 'TEAM'){
                Map<String, SObjectField> mapSObjFields = Schema.SObjectType.SVMXC__Service_Group__c.fields.getMap();

                for (String fieldKey : mapSObjFields.keySet()) 
                {
                    Schema.SObjectField fsObj = mapSObjFields.get(fieldKey); 
                    Schema.DescribeFieldResult f = fsObj.getDescribe();
                    String fieldName = f.getName();  
                    mapFieldNameType.put(fieldName, String.valueof(f.getType()));
                    system.debug(LoggingLevel.WARN, 'Block  ');
                    system.debug(LoggingLevel.WARN, 'mapFieldNameType  '+fieldName+'  '+String.valueof(f.getType()));
                }
                lstSObjFields = dcUtils.SVMX_getFieldList(mapSObjFields, true); 
            }
            for(String s:lstSObjFields){
                setSObjFields.add(s);      
            }
            for(String strSearchField : lstSearchFields){
                if(setSObjFields.contains(strSearchField))
                {
                    lstDirectQrySrchFields.add(strSearchField);
                    if(strSearchField == 'Id')
                        isIdFieldIncluded = true;
                }
            }
            if(!isIdFieldIncluded)
                lstDirectQrySrchFields.add('Id');
            system.debug(LoggingLevel.WARN, 'Size of valid search key fields list: ' + lstDirectQrySrchFields.size() + '; list: ' + lstDirectQrySrchFields);
            strTechTeamQueryFields = dcUtils.SVMX_getFieldNamesFromList(lstDirectQrySrchFields);

            // If the parameter FindWhat is Technician, loop through list of search fields to match
            if(FindWhat.toUpperCase() == 'TECHNICIAN'){
                if(!strTechTeamQueryFields.contains('SVMXC__Service_Territory__c'))
                    strTechTeamQueryFields += ', SVMXC__Service_Territory__c ';
                system.debug(LoggingLevel.WARN, 'Select clause of Tech query: ' + strTechTeamQueryFields);

                for(String strSearchField: lstSearchFields){
                    // If the search field is Territory, match Territory Coverage Value field value with search key values
                    if(strSearchField.toUpperCase() == 'TERRITORY'){
                        isMatchTerritory = true;
                        RecordType recTypeTerrCoverage = new RecordType();
                        recTypeTerrCoverage = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__Territory_Coverage__c' and Name = 'Coverage' Limit 1];
                        List<SVMXC__Service_Group_Members__c> lstTechWithTerrCoverage = new List<SVMXC__Service_Group_Members__c>();
                        String WhereClause = '';
                        for(String strSearchKeyValue: lstSearchKeyValues){
                            if(WhereClause != '')
                                WhereClause += ' OR ';
                            WhereClause += ' SVMXC__value__c like \'%' + string.escapeSingleQuotes(strSearchKeyValue)+'%\'';
                        }
                        String SOQL  = 'SELECT SVMXC__Territory__c, SVMXC__Value__c from SVMXC__Territory_Coverage__c where RecordTypeId = \'' + string.valueOf(recTypeTerrCoverage.Id) + '\' AND (' + WhereClause + ')';
                        system.debug(LoggingLevel.WARN, 'Query for matching Territory Coverage records: ' + SOQL);
                        lstTerrCoverage = Database.query(SOQL);

                        for(SVMXC__Territory_Coverage__c t: lstTerrCoverage){
                            setTerritoryIds.add(t.SVMXC__Territory__c);
                        }

                        SOQL  = 'SELECT ' + strTechTeamQueryFields + ' FROM SVMXC__Service_Group_Members__c where SVMXC__Service_Territory__r.Id IN :setTerritoryIds';
                        system.debug(LoggingLevel.WARN, 'Query for technicians of territories having matching Territory Coverage records: ' + SOQL);
                        lstTechWithTerrCoverage = Database.query(SOQL);
                        lstAllMatchedTechs.addAll(lstTechWithTerrCoverage);
                        system.debug(LoggingLevel.WARN, 'lstAllMatchedTechs: ' + lstAllMatchedTechs);
                    }
                    // If the search field is Expertise, match Expertise Name field value with search key values
                    else if(strSearchField.toUpperCase() == 'EXPERTISE'){
                        isMatchSkill = true;

                        String WhereClause = '';
                        date dtToday = date.today();

                        for(String strSearchKeyValue: lstSearchKeyValues){
                            if(WhereClause != '')
                                WhereClause += ' OR ';
                            WhereClause += 'SVMXC__Skill__r.Name like \'%' + string.escapeSingleQuotes(strSearchKeyValue)+'%\'';

                        }
                        string strExpertiseValidation;
                        String SOQL;
                        if(WhereClause != null && WhereClause != '')
                            strExpertiseValidation = ExpertisevalidationClause(WhereClause);
                        SOQL  = 'SELECT SVMXC__Group_Member__r.Id, SVMXC__Skill__r.Name from SVMXC__Service_Group_Skills__c where ' + strExpertiseValidation ;
                        system.debug(LoggingLevel.WARN, 'Query for technicians with expertise match: ' + SOQL);
                        lstTechTeamSkills = Database.query(SOQL); 
                    }
                    // If the search field is Product, match Product Name field value with search key values
                    else if(strSearchField.toUpperCase() == 'PRODUCT'){
                        isMatchProduct = true;

                        String WhereClause = '';
                        for(String strSearchKeyValue: lstSearchKeyValues){
                            if(WhereClause != '')
                                WhereClause += ' OR ';
                            WhereClause += 'SVMXC__Product__r.Name like \'%' + string.escapeSingleQuotes(strSearchKeyValue) + '%\'';
                        }
                        String SOQL  = 'SELECT SVMXC__Group_Member__r.Id, SVMXC__Product__r.Name from SVMXC__Service_Group_Product__c where ' + WhereClause;
                        //system.debug(LoggingLevel.WARN, 'Query for technicians with product match: ' + SOQL);
                        lstTechTeamProducts = Database.query(SOQL);
                    }
                    // Add all other search fields to a new list
                    else{
                        lstKeywordSearchFields.add(strSearchField);
                    }
                }
                // If there are search fields other than Product, Expertise, and Territory, match the search key values directly
                if(lstKeywordSearchFields.size() > 0)
                {
                    system.debug(LoggingLevel.WARN, 'Count of other search fields: ' + lstKeywordSearchFields.size() + '; fields: ' + lstKeywordSearchFields);
                    List<SVMXC__Service_Group_Members__c> lstTechWithKeywordMatch = new List<SVMXC__Service_Group_Members__c>();
                    String WhereClause = ' where ';
                    Boolean isSet;
                    String whereStr;
                    for(String strSearchKeyValue: lstSearchKeyValues){
                        system.debug(LoggingLevel.WARN, 'strSearchKeyValue '+strSearchKeyValue);
                        isSet = false;
                        whereStr = '';
                        for(String strSearchField: lstKeywordSearchFields){
                            system.debug(LoggingLevel.WARN, 'strSearchField '+strSearchField);
                            if(strSearchField != NULL && strSearchField != '' && mapFieldNameType.get(strSearchField) != NULL){
                                system.debug(LoggingLevel.WARN, 'Block  ');

                                system.debug(LoggingLevel.WARN, 'Block  ');
                                if( setStringFieldTypes.contains(mapFieldNameType.get(strSearchField)) )
                                {
                                    if(isSet == true)
                                        whereStr += ' OR ';
                                    whereStr += strSearchField+' like \'%' + string.escapeSingleQuotes(strSearchKeyValue) + '%\'';
                                    isSet = true;
                                    system.debug(LoggingLevel.WARN, 'Block 1 ');
                                }
                                else if(mapFieldNameType.get(strSearchField) == 'Schema.DisplayType.MULTIPICKLIST' || mapFieldNameType.get(strSearchField) == 'MULTIPICKLIST')
                                {
                                    if(isSet == true)
                                        whereStr += ' OR ';
                                    whereStr += strSearchField + ' INCLUDES (\'' + string.escapeSingleQuotes(strSearchKeyValue) + '\')';
                                    isSet = true;
                                    system.debug(LoggingLevel.WARN, 'Block 2 ');
                                }
                                else if(ValidateFieldType( mapFieldNameType.get(strSearchField), strSearchKeyValue) == true)
                                {
                                    if(isSet == true)
                                        whereStr += ' OR ';
                                    whereStr += strSearchField + ' = ' + string.escapeSingleQuotes(strSearchKeyValue);
                                    isSet = true;
                                    system.debug(LoggingLevel.WARN, 'Block 3 ');
                                }
                            }
                        }
                        if(whereStr != '')
                        {
                            if(WhereClause == ' where ')
                                WhereClause += ' ( ' + whereStr + ' ) ';
                            else
                                WhereClause += ' OR ( ' + whereStr + ' ) ';
                            system.debug(LoggingLevel.WARN, 'Block 4 ');
                        }
                    }
                    if(WhereClause == ' where ')
                        WhereClause = '';
                    system.debug(LoggingLevel.WARN, 'WhereClause '+WhereClause);
                    String SOQL  = 'SELECT ' + strTechTeamQueryFields + ' FROM SVMXC__Service_Group_Members__c' + WhereClause;
                    system.debug(LoggingLevel.WARN, 'Technician query: ' + SOQL);
                    lstTechWithKeywordMatch = Database.query(SOQL);
                    lstAllMatchedTechs.addAll(lstTechWithKeywordMatch);
                }
            }
            // If the parameter FindWhat is Team, loop through list of search fields to match
            else if(FindWhat.toUpperCase() == 'TEAM'){

                for(String strSearchField: lstSearchFields){
                    // If the search field is Expertise, match Expertise Name field value with search key values
                    if(strSearchField.toUpperCase() == 'EXPERTISE'){
                        isMatchSkill = true;

                        String WhereClause = '';
                        date dtToday = date.today();
                        string strExpertiseValidation;

                        for(String strSearchKeyValue: lstSearchKeyValues){
                            if(WhereClause != '')
                                WhereClause += ' OR ';
                            WhereClause += 'SVMXC__Skill__r.Name like \'%'+string.escapeSingleQuotes(strSearchKeyValue)+'%\'';
                        }
                        if(WhereClause != null && WhereClause != '')
                            strExpertiseValidation = ExpertisevalidationClause(WhereClause);
                        String SOQL  = 'SELECT SVMXC__Service_Group__r.Id, SVMXC__Skill__r.Name from SVMXC__Service_Group_Skills__c where ' + strExpertiseValidation + 'and SVMXC__Group_Member__c=null';
                        system.debug(LoggingLevel.WARN, 'Query for teams with expertise match: ' + SOQL);
                        lstTechTeamSkills = Database.query(SOQL);
                    }
                    // If the search field is Product, match Product Name field value with search key values
                    else if(strSearchField.toUpperCase() == 'PRODUCT'){
                        isMatchProduct = true;

                        String WhereClause = '';
                        for(String strSearchKeyValue: lstSearchKeyValues){
                            if(WhereClause != '')
                                WhereClause += ' OR ';
                            WhereClause += 'SVMXC__Product__r.Name like \'%'+string.escapeSingleQuotes(strSearchKeyValue)+'%\'';
                        }
                        String SOQL  = 'SELECT SVMXC__Service_Group__r.Id, SVMXC__Product__r.Name from SVMXC__Service_Group_Product__c where ' + WhereClause;
                        lstTechTeamProducts = Database.query(SOQL); 
                    }
                    // Add all other search fields to a new list
                    else{
                        lstKeywordSearchFields.add(strSearchField);
                    }
                }
                // If there are search fields other than Product, Expertise, and Territory, match the search key values directly
                if(lstKeywordSearchFields.size() > 0)
                {
                    //system.debug(LoggingLevel.WARN, 'Count of other search fields: ' + lstKeywordSearchFields.size() + '; fields: ' + lstKeywordSearchFields);
                    List<SVMXC__Service_Group__c> team = new List<SVMXC__Service_Group__c>();
                    String WhereClause = ' where ';
                    Boolean isSet;
                    String whereStr;
                    for(String strSearchKeyValue: lstSearchKeyValues){
                        isSet = false;
                        whereStr = '';
                        for(String strSearchField: lstKeywordSearchFields){
                            if(strSearchField != NULL && strSearchField != '' && mapFieldNameType.get(strSearchField) != NULL){
                                if( setStringFieldTypes.contains(mapFieldNameType.get(strSearchField)) ){
                                    if(isSet == true)
                                        whereStr += ' OR ';
                                    whereStr += strSearchField+' like \'%'+string.escapeSingleQuotes(strSearchKeyValue)+'%\'';
                                    isSet = true;
                                }
                                else if(mapFieldNameType.get(strSearchField) == 'Schema.DisplayType.MULTIPICKLIST' || mapFieldNameType.get(strSearchField) == 'MULTIPICKLIST')
                                {
                                    if(isSet == true)
                                        whereStr += ' OR ';
                                    whereStr += strSearchField + ' INCLUDES (\'' + string.escapeSingleQuotes(strSearchKeyValue) + '\')';
                                    isSet = true;
                                }
                                else if(ValidateFieldType( mapFieldNameType.get(strSearchField), strSearchKeyValue) == true){
                                    if(isSet == true)
                                        whereStr += ' OR ';
                                    whereStr += strSearchField + ' = ' + string.escapeSingleQuotes(strSearchKeyValue);
                                    isSet = true;
                                }
                            }
                        }
                        if(whereStr != '')
                        {
                            if(WhereClause == ' where ')
                                WhereClause += ' ( ' + whereStr + ' ) ';
                            else
                                WhereClause += ' OR ( ' + whereStr + ' ) ';
                            system.debug(LoggingLevel.WARN, 'Block 1 ');
                        }
                    }
                    if(WhereClause == ' where ')
                        WhereClause ='';

                    String SOQL  = 'SELECT ' + strTechTeamQueryFields + '  FROM SVMXC__Service_Group__c' + WhereClause;       
                    system.debug(LoggingLevel.WARN, 'Team query: ' + SOQL);
                    lstServiceTeams = Database.query(SOQL);
                }
            }

            if(FindWhat.toUpperCase() == 'TECHNICIAN')
                TeamTechSet = SearchTechnician2(lstAllMatchedTechs, lstTechTeamProducts, lstTechTeamSkills, lstTerrCoverage, lstSearchKeyValues, lstDirectQrySrchFields, SearchType.toUpperCase()=='ALL', isMatchProduct, isMatchSkill, isMatchTerritory);
            else if(FindWhat.toUpperCase() == 'TEAM')
                TeamTechSet = SearchTeam(lstServiceTeams, lstTechTeamProducts, lstTechTeamSkills, lstSearchKeyValues, lstDirectQrySrchFields, SearchType.toUpperCase()=='ALL', isMatchProduct, isMatchSkill);

            if(TeamTechSet != NULL){
                for(Id s: TeamTechSet){
                    TeamTechList.add(String.valueof(s));
                }
            }
        }
        catch(DmlException ex)
        {
            throw new DCX_CommonServiceManager.DCxException(ex);
        }
        catch(Exception ex)
        {
            throw new DCX_CommonServiceManager.DCxException(ex);
        }
        system.debug(LoggingLevel.WARN, 'TeamTechList: ' + TeamTechList);

        return TeamTechList;
    }
    public static string ExpertisevalidationClause(String WhereClause)
    {
        return '(' + WhereClause + ') and ' + '((SVMXC__Availability_Start_Date__c != null and SVMXC__Availability_End_Date__c != null and SVMXC__Availability_Start_Date__c <=: dtToday and SVMXC__Availability_End_Date__c >=: dtToday ) OR (SVMXC__Availability_Start_Date__c = null and SVMXC__Availability_End_Date__c >=: dtToday ) OR (SVMXC__Availability_Start_Date__c <=: dtToday and SVMXC__Availability_End_Date__c = null) OR (SVMXC__Availability_Start_Date__c = null and SVMXC__Availability_End_Date__c = null))';

    }
    public static set<Id> SearchTechnician2(list<SVMXC__Service_Group_Members__c> lstTechnician, list<SVMXC__Service_Group_Product__c> lstProductServiced, list<SVMXC__Service_Group_Skills__c> lstExpertise, list<SVMXC__Territory_Coverage__c> lstTerritoryCoverage, list<string> lstSearchString, list<string> lstField, boolean bMatchAll, boolean bMatchProduct, boolean bMatchExpertise, boolean bMatchTerritory)
    {
        system.debug('lstTechnician in search tech '+lstTechnician.size()+'  ++  '+lstSearchString.size());
        set<Id> setIdSortedTechnician = new set<Id>();
        map<Id, set<Id>> mapTerritoryTechnician = new map<Id, set<Id>>();
        for(SVMXC__Service_Group_Members__c oTechnician :lstTechnician)
        {
            if(oTechnician.SVMXC__Service_Territory__c != null){
                if(!mapTerritoryTechnician.containskey(oTechnician.SVMXC__Service_Territory__c))
                    mapTerritoryTechnician.put(oTechnician.SVMXC__Service_Territory__c, new set<Id>());
                mapTerritoryTechnician.get(oTechnician.SVMXC__Service_Territory__c).add(oTechnician.Id);
            }
        }
        if(bMatchAll)
        {
            map<Id, map<string, boolean>> mapTechinicianValidity = new map<Id, map<string, boolean>>();
            if(lstSearchString != null && lstSearchString.size() > 0)
            {
                for(string strSearchString :lstSearchString)
                {
                    if(lstTechnician != null && lstTechnician.size() > 0)
                    {
                        for(SVMXC__Service_Group_Members__c oTechnician :lstTechnician)
                        {
                            if(!mapTechinicianValidity.containsKey(oTechnician.Id))
                            {
                                mapTechinicianValidity.put(oTechnician.Id, new map<string, boolean>());
                                mapTechinicianValidity.get(oTechnician.Id).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oTechnician.Id).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oTechnician.Id).put(strSearchString, false);
                            }
                            for(string strField :lstField)
                            {
                                if(oTechnician.get(strField) != null && string.valueOf(oTechnician.get(strField)) != null && string.valueOf(oTechnician.get(strField)).toUpperCase().contains(strSearchString.toUpperCase()))
                                {
                                    mapTechinicianValidity.get(oTechnician.Id).put(strSearchString, true);
                                    break;
                                }
                            }
                        }
                    }
                    if(bMatchProduct && lstProductServiced != null && lstProductServiced.size() > 0)
                    {
                        for(SVMXC__Service_Group_Product__c oProductServiced :lstProductServiced)
                        {
                            if(!mapTechinicianValidity.containsKey(oProductServiced.SVMXC__Group_Member__c))
                            {
                                mapTechinicianValidity.put(oProductServiced.SVMXC__Group_Member__c, new map<string, boolean>());
                                mapTechinicianValidity.get(oProductServiced.SVMXC__Group_Member__c).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oProductServiced.SVMXC__Group_Member__c).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oProductServiced.SVMXC__Group_Member__c).put(strSearchString, false);
                            }
                            if(oProductServiced.SVMXC__Product__r.Name != null && oProductServiced.SVMXC__Product__r.Name.toUpperCase().contains(strSearchString.toUpperCase()))
                                mapTechinicianValidity.get(oProductServiced.SVMXC__Group_Member__c).put(strSearchString, true);
                        }
                    }
                    if(bMatchExpertise && lstExpertise != null && lstExpertise.size() > 0)
                    {
                        for(SVMXC__Service_Group_Skills__c oExpertise :lstExpertise)
                        {
                            if(!mapTechinicianValidity.containsKey(oExpertise.SVMXC__Group_Member__c))
                            {
                                mapTechinicianValidity.put(oExpertise.SVMXC__Group_Member__c, new map<string, boolean>());
                                mapTechinicianValidity.get(oExpertise.SVMXC__Group_Member__c).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oExpertise.SVMXC__Group_Member__c).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oExpertise.SVMXC__Group_Member__c).put(strSearchString, false);
                            }
                            if(oExpertise.SVMXC__Skill__r.Name != null && oExpertise.SVMXC__Skill__r.Name.toUpperCase().contains(strSearchString.toUpperCase()))
                                mapTechinicianValidity.get(oExpertise.SVMXC__Group_Member__c).put(strSearchString, true);
                        }
                    }
                    if(bMatchTerritory && lstTerritoryCoverage != null && lstTerritoryCoverage.size() > 0)
                    {
                        for(SVMXC__Territory_Coverage__c oTerritoryCoverage :lstTerritoryCoverage)
                        {
                            if(oTerritoryCoverage.SVMXC__Value__c != null && oTerritoryCoverage.SVMXC__Value__c.toUpperCase().contains(strSearchString.toUpperCase()))
                            {
                                set<Id> lstIdTechnician = new set<Id>();
                                lstIdTechnician = mapTerritoryTechnician.get(oTerritoryCoverage.SVMXC__Territory__c);
                                if(lstIdTechnician != NULL)
                                {
                                    for(Id IdTechnician :lstIdTechnician)
                                    {
                                        if(!mapTechinicianValidity.containsKey(IdTechnician))
                                            mapTechinicianValidity.put(IdTechnician, new map<string, boolean>());
                                        mapTechinicianValidity.get(IdTechnician).put(strSearchString, true);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(mapTechinicianValidity != null && mapTechinicianValidity.size() > 0)
            {
                for(Id IdTechnician :mapTechinicianValidity.KeySet())
                {
                    map<string, Boolean> m = mapTechinicianValidity.get(IdTechnician);
                    boolean IsValidTechnician = true;
                    for(boolean b :m.values())
                    {
                        if(!b)
                        {
                            IsValidTechnician = false;
                            break;
                        }
                    }
                    if(IsValidTechnician)
                        setIdSortedTechnician.add(IdTechnician);
                }
            }
        }
        else
        {
            for(SVMXC__Service_Group_Members__c oTechnician :lstTechnician)
            {
                setIdSortedTechnician.add(oTechnician.Id);
            }
            for(SVMXC__Service_Group_Product__c oProductServiced :lstProductServiced)
            {
                setIdSortedTechnician.add(oProductServiced.SVMXC__Group_Member__c);
            }
            for(SVMXC__Service_Group_Skills__c oExpertise :lstExpertise)
            {
                setIdSortedTechnician.add(oExpertise.SVMXC__Group_Member__c);
            }
        }
        return setIdSortedTechnician;
    }
    public static set<Id> SearchTeam(list<SVMXC__Service_Group__c> lstTeam, list<SVMXC__Service_Group_Product__c> lstProductServiced, list<SVMXC__Service_Group_Skills__c> lstExpertise, list<string> lstSearchString, list<string> lstField, boolean bMatchAll, boolean bMatchProduct, boolean bMatchExpertise)
    {
        set<Id> setIdSortedTeam = new set<Id>();
        if(bMatchAll)
        {
            map<Id, map<string, boolean>> mapTechinicianValidity = new map<Id, map<string, boolean>>();
            if(lstSearchString != null && lstSearchString.size() > 0)
            {
                for(string strSearchString :lstSearchString)
                {
                    if(lstTeam != null && lstTeam.size() > 0)
                    {
                        for(SVMXC__Service_Group__c oTeam :lstTeam)
                        {
                            if(!mapTechinicianValidity.containsKey(oTeam.Id))
                            {
                                mapTechinicianValidity.put(oTeam.Id, new map<string, boolean>());
                                mapTechinicianValidity.get(oTeam.Id).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oTeam.Id).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oTeam.Id).put(strSearchString, false);
                            }
                            for(string strField :lstField)
                            {
                                if(oTeam.get(strField) != null && string.valueOf(oTeam.get(strField)) != null && string.valueOf(oTeam.get(strField)).toUpperCase().contains(strSearchString.toUpperCase()))
                                {
                                    mapTechinicianValidity.get(oTeam.Id).put(strSearchString, true);
                                    break;
                                }
                            }
                        }
                    }
                    if(bMatchProduct && lstProductServiced != null && lstProductServiced.size() > 0)
                    {
                        for(SVMXC__Service_Group_Product__c oProductServiced :lstProductServiced)
                        {
                            if(!mapTechinicianValidity.containsKey(oProductServiced.SVMXC__Service_Group__c))
                            {
                                mapTechinicianValidity.put(oProductServiced.SVMXC__Service_Group__c, new map<string, boolean>());
                                mapTechinicianValidity.get(oProductServiced.SVMXC__Service_Group__c).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oProductServiced.SVMXC__Service_Group__c).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oProductServiced.SVMXC__Service_Group__c).put(strSearchString, false);
                            }
                            if(oProductServiced.SVMXC__Product__r.Name != null && oProductServiced.SVMXC__Product__r.Name.toUpperCase().contains(strSearchString.toUpperCase()))
                                mapTechinicianValidity.get(oProductServiced.SVMXC__Service_Group__c).put(strSearchString, true);
                        }
                    }
                    if(bMatchExpertise && lstExpertise != null && lstExpertise.size() > 0)
                    {
                        for(SVMXC__Service_Group_Skills__c oExpertise :lstExpertise)
                        {
                            if(!mapTechinicianValidity.containsKey(oExpertise.SVMXC__Service_Group__c))
                            {
                                mapTechinicianValidity.put(oExpertise.SVMXC__Service_Group__c, new map<string, boolean>());
                                mapTechinicianValidity.get(oExpertise.SVMXC__Service_Group__c).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oExpertise.SVMXC__Service_Group__c).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oExpertise.SVMXC__Service_Group__c).put(strSearchString, false);
                            }
                            if(oExpertise.SVMXC__Skill__r.Name != null && oExpertise.SVMXC__Skill__r.Name.toUpperCase().contains(strSearchString.toUpperCase()))
                                mapTechinicianValidity.get(oExpertise.SVMXC__Service_Group__c).put(strSearchString, true);
                        }
                    }
                }
            }
            if(mapTechinicianValidity != null && mapTechinicianValidity.size() > 0)
            {
                for(Id IdTeam :mapTechinicianValidity.KeySet())
                {
                    map<string, Boolean> m = mapTechinicianValidity.get(IdTeam);
                    boolean IsValidTeam = true;
                    for(boolean b :m.values())
                    {
                        if(!b)
                        {
                            IsValidTeam = false;
                            break;
                        }
                    }
                    if(IsValidTeam)
                        setIdSortedTeam.add(IdTeam);
                }
            }
        }
        else
        {
            for(SVMXC__Service_Group__c oTeam :lstTeam)
            {
                setIdSortedTeam.add(oTeam.Id);
            }
            for(SVMXC__Service_Group_Product__c oProductServiced :lstProductServiced)
            {
                setIdSortedTeam.add(oProductServiced.SVMXC__Service_Group__c);
            }
            for(SVMXC__Service_Group_Skills__c oExpertise :lstExpertise)
            {
                setIdSortedTeam.add(oExpertise.SVMXC__Service_Group__c);
            }
        }
        return setIdSortedTeam;
    }
    public static Boolean ValidateFieldType( String fieldType, String fieldValue)
    {
        Boolean isValid = true;

        if(fieldType == 'BOOLEAN' || fieldType == 'Schema.DisplayType.BOOLEAN'){
            if(fieldValue != 'true' && fieldValue != 'false')
                isValid = false;
        }
        else if(fieldType == 'INTEGER' || fieldType == 'Schema.DisplayType.INTEGER'){
            try{Integer d = Integer.valueOf(fieldValue);}catch(Exception ex){isValid = false;}
        }
        else if(fieldType == 'CURRENCY' || fieldType == 'PERCENT' || fieldType == 'DOUBLE' || fieldType == 'Schema.DisplayType.CURRENCY' || fieldType == 'Schema.DisplayType.PERCENT' || fieldType == 'Schema.DisplayType.DOUBLE'){
            try{Decimal d = Decimal.valueOf(fieldValue);}catch(Exception ex){isValid = false;}
        }
        /*
    // The following code for Date and DateTime field types is correct, but the field value
    // cannot be used directly as done for Boolean or numeric fields.
    // Update required in the calling function to create date / datetime instance, assign it to variable, and use the variable in the where clause.
    // And, the scenario of there being more than 1 date / datetime fields needs to be handled.
    // This involves more & involved coding, and these fields are not likely to be search fields.
    // So, keeping this commented for now.
    else if(fieldType == 'DATE' || fieldType == 'Schema.DisplayType.Date'){
        try{Date d = Date.parse(fieldValue);}catch(Exception ex){isValid = false;}
    }
    else if(fieldType == 'DATETIME' || fieldType == 'Schema.DisplayType.DATETIME'){
        try{DateTime d = DateTime.parse(fieldValue);}catch(Exception ex){isValid = false;}       
    }
         */
        else
            isValid = false;
        system.debug(LoggingLevel.WARN, 'ValidateFieldType - return value: ' + isValid);
        return isValid;
    }

    public static DCX_Wrapper.SVMX_Response SVMX_getDispatcherList_WS(DCX_Wrapper.SVMX_StringMap request){
        string TeamLabel = string.escapeSingleQuotes(System.Label.DCON001_TAG314);
        string TerritoryLabel = string.escapeSingleQuotes(System.Label.DCON001_TAG315);
        string SuperDispatcherUserId = request.value;
        SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> svmxSettingList = new list<string>{'DCON001_SET053'};
        map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(svmxSettingList);
        String strAllowOverRide;
        if(mapSettingValues.get('DCON001_SET053') != null)
            strAllowOverRide = string.escapeSingleQuotes(mapSettingValues.get('DCON001_SET053'));
        Boolean AllowOverride_OtherSuperDispatchers = true; //get this from setting
        if(strAllowOverRide != null) AllowOverride_OtherSuperDispatchers = Boolean.valueOf(strAllowOverRide);
        Set<Id> AllSuperDispatcherUIds = new Set<Id>();
        Set<Id> setServiceTeamIds = new Set<Id>();
        Set<Id> setTerritoryIds = new Set<Id>();
        Set<Id> setUserIds = new Set<Id>();
        
        Set<Id> setAllDispatchers = new Set<Id>();
        List<User> LstQualifiedDispatcher = new List<User>();
        Map<Id,User> mapQualifiedDispatchers = new Map<Id,User>();
        List<SVMXC__Dispatcher_Access__c> SuperDispatcherAccessRecs = database.query('Select Id, SVMXC__Dispatcher__c, SVMXC__Service_Team__c, SVMXC__Territory__c from SVMXC__Dispatcher_Access__c where SVMXC__Dispatcher__c = :SuperDispatcherUserId ');
        //Loop through and build a set of setServiceTeamIds, set of setTerritoryIds, set of setUserIds
        for(SVMXC__Dispatcher_Access__c DispatcherAccessRec: SuperDispatcherAccessRecs)
        {
            if(DispatcherAccessRec.SVMXC__Service_Team__c != null && !(setServiceTeamIds.contains(DispatcherAccessRec.SVMXC__Service_Team__c)))
                setServiceTeamIds.add(DispatcherAccessRec.SVMXC__Service_Team__c);
            if(DispatcherAccessRec.SVMXC__Territory__c != null && !(setTerritoryIds.contains(DispatcherAccessRec.SVMXC__Territory__c)))
                setTerritoryIds.add(DispatcherAccessRec.SVMXC__Territory__c);
            if(DispatcherAccessRec.SVMXC__Dispatcher__c != null && !(setUserIds.contains(DispatcherAccessRec.SVMXC__Dispatcher__c)))
                setUserIds.add(DispatcherAccessRec.SVMXC__Dispatcher__c);
        }
        
        //a. Get List of all the Dispatches for that territory/Team
        //b. Filter Out the given super-dispatcher (#1)
        //c. Filter out other super dispatchers if exist and DCON001_SET054 is set to False
        Map<String,String> mapTeam_Terr_Id_Name = new Map<String,String>();
        List<SVMXC__Dispatcher_Access__c> AllDispatchersRecs_Above_Team_Territory = new List<SVMXC__Dispatcher_Access__c>();
        system.debug('test log: ' + setServiceTeamIds + setTerritoryIds);
        if(setServiceTeamIds != null && setTerritoryIds != null && setServiceTeamIds.size() > 0 && setTerritoryIds.size() > 0)
        {    
            if(AllowOverride_OtherSuperDispatchers)
                AllDispatchersRecs_Above_Team_Territory = database.query('Select Id, SVMXC__Dispatcher__c, SVMXC__Service_Team__c, SVMXC__Territory__c, SVMXC__Service_Team__r.Name, SVMXC__Territory__r.Name from SVMXC__Dispatcher_Access__c where ( SVMXC__Service_Team__c IN : setServiceTeamIds OR SVMXC__Territory__c IN :setTerritoryIds ) AND (SVMXC__Dispatcher__c != null AND SVMXC__Dispatcher__c != :SuperDispatcherUserId )');
            else
                AllDispatchersRecs_Above_Team_Territory = database.query('Select Id, SVMXC__Dispatcher__c, SVMXC__Service_Team__c, SVMXC__Territory__c, SVMXC__Service_Team__r.Name, SVMXC__Territory__r.Name from SVMXC__Dispatcher_Access__c where ( SVMXC__Service_Team__c IN : setServiceTeamIds OR SVMXC__Territory__c IN :setTerritoryIds ) AND (SVMXC__Dispatcher__c != null AND  SVMXC__Dispatcher__r.SVMXC__Is_Super_Dispatcher__c = false )');
        }
        else if(setServiceTeamIds != null && setServiceTeamIds.size() > 0)
        {
            if(AllowOverride_OtherSuperDispatchers)
                AllDispatchersRecs_Above_Team_Territory = database.query('Select Id, SVMXC__Dispatcher__c, SVMXC__Service_Team__c, SVMXC__Territory__c, SVMXC__Service_Team__r.Name, SVMXC__Territory__r.Name from SVMXC__Dispatcher_Access__c where SVMXC__Service_Team__c IN : setServiceTeamIds AND (SVMXC__Dispatcher__c != null AND SVMXC__Dispatcher__c != :SuperDispatcherUserId ) ');
            else
                AllDispatchersRecs_Above_Team_Territory = database.query('Select Id, SVMXC__Dispatcher__c, SVMXC__Service_Team__c, SVMXC__Territory__c, SVMXC__Service_Team__r.Name, SVMXC__Territory__r.Name from SVMXC__Dispatcher_Access__c where SVMXC__Service_Team__c IN : setServiceTeamIds AND SVMXC__Dispatcher__r.SVMXC__Is_Super_Dispatcher__c = false');
        }
        else if(setTerritoryIds != null && setTerritoryIds.size() > 0)
        {
            if(AllowOverride_OtherSuperDispatchers)
                AllDispatchersRecs_Above_Team_Territory = database.query('Select Id, SVMXC__Dispatcher__c, SVMXC__Service_Team__c, SVMXC__Territory__c, SVMXC__Service_Team__r.Name, SVMXC__Territory__r.Name from SVMXC__Dispatcher_Access__c where SVMXC__Territory__c IN :setTerritoryIds AND (SVMXC__Dispatcher__c != null AND SVMXC__Dispatcher__c != :SuperDispatcherUserId )');
            else
                AllDispatchersRecs_Above_Team_Territory = database.query('Select Id, SVMXC__Dispatcher__c, SVMXC__Service_Team__c, SVMXC__Territory__c, SVMXC__Service_Team__r.Name, SVMXC__Territory__r.Name from SVMXC__Dispatcher_Access__c where SVMXC__Territory__c IN :setTerritoryIds AND SVMXC__Dispatcher__r.SVMXC__Is_Super_Dispatcher__c = false');
        }

        //Team/TerritoryId, List<User Id>
        Map<Id,List<String>> mapTeamId_LstUserId = new Map<Id,List<String>>();
        Map<Id,List<String>> mapTerritoryId_LstUserId = new Map<Id,List<String>>();
        //Result variables declaration
        if(AllDispatchersRecs_Above_Team_Territory != null)
            for(SVMXC__Dispatcher_Access__c DispatcherRecord:AllDispatchersRecs_Above_Team_Territory)
            {
                if(DispatcherRecord.SVMXC__Dispatcher__c == null) continue;
        
                Set<String> setTempUserIds_Team = new Set<String>();
                Set<String> setTempUserIds_Territory = new Set<String>();
        
                if(DispatcherRecord.SVMXC__Service_Team__c != null)
                {
                    if(mapTeamId_LstUserId.containskey(DispatcherRecord.SVMXC__Service_Team__c))
                        setTempUserIds_Team.addAll(mapTeamId_LstUserId.get(DispatcherRecord.SVMXC__Service_Team__c));
                    setTempUserIds_Team.add(DispatcherRecord.SVMXC__Dispatcher__c);
                    List<String> LstTempUserIds = new List<String>();
                    LstTempUserIds.addAll(setTempUserIds_Team);
                    mapTeamId_LstUserId.put(DispatcherRecord.SVMXC__Service_Team__c, LstTempUserIds);
        
                    //Populate the unique set of users
                    setAllDispatchers.add(DispatcherRecord.SVMXC__Dispatcher__c);
        
                    //Populate the id name map of the service team
                    mapTeam_Terr_Id_Name.put(DispatcherRecord.SVMXC__Service_Team__c,DispatcherRecord.SVMXC__Service_Team__r.Name);
                    
                }
                
                if(DispatcherRecord.SVMXC__Territory__c != null)
                {
                    if(mapTerritoryId_LstUserId.containskey(DispatcherRecord.SVMXC__Territory__c))
                        setTempUserIds_Territory.addAll(mapTerritoryId_LstUserId.get(DispatcherRecord.SVMXC__Territory__c));
                    setTempUserIds_Territory.add(DispatcherRecord.SVMXC__Dispatcher__c);
                    List<String> LstTempUserIds1 = new List<String>();
                    LstTempUserIds1.addAll(setTempUserIds_Territory);
                    mapTerritoryId_LstUserId.put(DispatcherRecord.SVMXC__Territory__c, LstTempUserIds1);
                    
                    //Populate the unique set of users
                    setAllDispatchers.add(DispatcherRecord.SVMXC__Dispatcher__c);
        
                    //Populate the id name map of the territory
                    mapTeam_Terr_Id_Name.put(DispatcherRecord.SVMXC__Territory__c,DispatcherRecord.SVMXC__Territory__r.Name);
                }
            }
        //Build Response variables
        DCX_Wrapper.SVMX_Response DispatcherListResponse = new DCX_Wrapper.SVMX_Response();

        //Build List<StringMap> and put it in DispatcherListResponse.StringMap
        List<DCX_Wrapper.SVMX_StringMap> LstStringMap = new List<DCX_Wrapper.SVMX_StringMap>();
        for(Id TeamId:mapTeamId_LstUserId.keyset())
        {
            DCX_Wrapper.SVMX_StringMap ResultStrMap = new DCX_Wrapper.SVMX_StringMap(TeamId,null);
            ResultStrMap.valueList = new List<String>();
            ResultStrMap.valueList.addAll(mapTeamId_LstUserId.get(TeamId));
            ResultStrMap.value = TeamLabel + ' ' +mapTeam_Terr_Id_Name.get(TeamId);
            LstStringMap.add(ResultStrMap);
        }
        for(Id TerritoryId:mapTerritoryId_LstUserId.keyset())
        {
            DCX_Wrapper.SVMX_StringMap ResultStrMap = new DCX_Wrapper.SVMX_StringMap(TerritoryId,null);
            ResultStrMap.valueList = new List<String>();
            if(mapTerritoryId_LstUserId.get(TerritoryId) != null)
                ResultStrMap.valueList.addAll(mapTerritoryId_LstUserId.get(TerritoryId));
            ResultStrMap.value = TerritoryLabel + ' ' + mapTeam_Terr_Id_Name.get(TerritoryId);
            LstStringMap.add(ResultStrMap);
        }
        //populate LstQualifiedDispatcher
        LstQualifiedDispatcher = database.query('select Id, Name from User where Id IN :setAllDispatchers');

        //Build Response
        DispatcherListResponse.DispatcherList = LstStringMap;
        DispatcherListResponse.RecordList = (List<SObject>)LstQualifiedDispatcher;//List of qualifed users/Dispatchers are sent here
        DispatcherListResponse.success = true;
        system.debug('Final response'+DispatcherListResponse);
        return DispatcherListResponse;
    }

}