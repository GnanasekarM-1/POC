global class DCON_Work_Order_WS { 

    // To restrict MultiAssignment repeated trigger execution
    public static boolean allowtriggerExecution = true;

    //Method to return exemptions
    public class SVMXException extends Exception {}
    public static Map<String, String> svmxSettingList = new Map<String, String>(DCON_Event_WS.loadDCsetting());
    public static Map<String, String> loadDCsetting()
    {
        if(SVMX_Constants.AllDCSettingList == NULL || SVMX_Constants.AllDCSettingList.size() == 0)
        {
            list<string> lstSubModules = new list<string>{'DCON001'};
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            SVMX_Constants.AllDCSettingList = commSettings.SVMX_getSettingList(lstSubModules);          
        }
        system.debug('svmxSettingList '+svmxSettingList);
        return  SVMX_Constants.AllDCSettingList.get('DCON001');

    }
    //This method returns the name of Work Order views (queues and personal) to which the login user has access to.
    WebService public static List<DCON_Configuration_WS.SVMX_StringMap> DCON_Retrieve_Views_WS(String UserId)
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

            for(Group r : [SELECT Id,Name,RelatedId,Type FROM Group where RelatedId =: userinfo.getUserRoleId() and (Type = 'Role' Or Type = 'RoleAndSubordinates')]){
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
            throw new SVMXException(ex);
        }
        system.debug('ViewList'+ViewList);
        return ViewList;
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

    global class workorder_WP{
        WebService SVMXC__Service_Order__c workorder_O {get;set;}
        WebService List<workorderSpecialFields_WP> specialFields_LWP {get; set;}
        WebService long lastSyncedTime;
        public workorder_WP()
        {

        }
        public workorder_WP(SVMXC__Service_Order__c wo, List<workorderSpecialFields_WP> references){
            workorder_O = wo;
            specialFields_LWP = references;
        }
    }

    global class workorderSpecialFields_WP{
        WebService String key {get; set;}
        WebService String value {get; set;}
        public workorderSpecialFields_WP(String tK, String tV){
            this.key = tK;
            this.value = tV;
        }
    }

    global class workorderDelta_WP{
        WebService List<String> lstDeltaWorkOrderIds {get; set;}
        WebService List<String> lstDeletedWorkOrderIds {get; set;}
        workorderDelta_WP()
        {

        }
        workorderDelta_WP(List<String> lstDeltaWorkOrderIds, List<String> lstDeletedWorkOrderIds)
        {
            this.lstDeltaWorkOrderIds = lstDeltaWorkOrderIds;
            this.lstDeletedWorkOrderIds = lstDeletedWorkOrderIds;
        }
    }

    global class workorderInfo_WP{
        WebService List<String> refFields = new List<String>();
        WebService List<String> dateTimeFields = new List<String>();
        WebService List<String> dateFields = new List<String>();
        WebService List<String> replacementRef = new List<String>();
        WebService List<String> replacementField = new List<String>();
        WebService String querySelect;
    }
    global class DC_StringListMap
    {
        webservice String key {get;set;} //Technician Id
        webservice List<String> valueList = new List<String>();//Details of all Events for Technician(EventID, ActivityDateTime, DurationInMinutes )
        webservice String fieldsToNull{get;set;}

        global DC_StringListMap(String key,List<String> valueList)
        {
            this.key = key;
            this.valueList = valueList;
        }
        global DC_StringListMap()
        {

        }

        global List<String> getvalueList(){return valueList;}
        global void setvalueList(List<String> s ){valueList = s;}
    }
    /* this class holds generic Request for DCON_Manage_Work_Order_MultiAssign_WS */
    global class DCON_WO_MultiAssign_Request 
    { 
        WebService List<String> workOrderIds = new List<String>();
        WebService List<String> technicianIds = new List<String>();
        WebService String operationType{get; set;}   // MULTIASSIGN_YES (if user selects to unassign wo) or MULTIASSIGN_NO (if user selects to keep the assignment and create/delete events)
        WebService String timezone{get; set;}
        WebService List<Event> Eventlist = new list<Event>();
        WebService List< String > EventIds = new List<String>();//Event Ids to delete in MutiTech;
        WebService List<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new List<DCON_Configuration_WS.SVMX_StringMap>();
        global List<String> getworkOrderIds(){return workOrderIds;}
        global void setworkOrderIds(List<String> s ){workOrderIds = s;}
        global List<Event> getEventlist(){return Eventlist;}
        global void setEventlist(List<Event> s ){Eventlist = s;}
    }
    /* this class holds generic Response for DCON_Manage_Work_Order_MultiAssign_WS */
    global class DCON_WO_MultiAssign_Response
    {
        WebService List< DC_StringListMap > lstTechEventDetails =  new List< DC_StringListMap >();// Having Technician as key and list having details of all Events for the technician
        global List<DC_StringListMap> getlstTechEventDetails(){return lstTechEventDetails;}
        global void setlstTechEventDetails(List<DC_StringListMap> s ){lstTechEventDetails = s;}
    }
    //Generic Web service entry point:
    //This works for technician having no overlapping events.If we  have to support overlapping events for a technician,we need a unique identifier from client end to uniquely identify each event.(Key=Unique Id from client, Value= Events)
    WebService static DCON_WO_MultiAssign_Response DCON_Manage_Work_Order_MultiAssign_WS(DCON_WO_MultiAssign_Request dcon_Request) 
    {
        /* this is a generic Web Service that can be used as a common entry point for all WO related services */
        // Pavitra: postpone the WO trigger execution
        // WO Trigger is getting executed 8 times (4 set of After + Before)
        allowtriggerExecution = false;
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
        if(mapSettingValues.containsKey('DCON001_SET009'))
            setOwner = boolean.valueOf(mapSettingValues.get('DCON001_SET009'));
        system.debug(LoggingLevel.Warn, ' Request object  '+dcon_Request);
        try
        {
            If(dcon_Request.operationType == 'WO_UNASSIGN_YES')
            {
                if(dcon_Request.WorkOrderIds != NULL && dcon_Request.WorkOrderIds.size() > 0)
                    StatusMessage = DCON_Work_Order_WS.DCON_Unassign_Work_Order_WS(UserId, dcon_Request.WorkOrderIds);
                // When technician id is not given don't do work order assignment
                if(dcon_Request.technicianIds.get(0) != NULL && dcon_Request.technicianIds.get(0) != '')
                    DCON_Work_Order_WS.DCON_Assign_Work_Order_To_Tech_WS(UserId, dcon_Request.WorkOrderIds, dcon_Request.technicianIds.get(0), setOwner);
                if(dcon_Request.EventList!= null && dcon_Request.EventList.size()>0)                    
                    EventIds = DCON_Event_WS.DCON_Upsert_Events_WS4(UserId, dcon_Request.EventList, dcon_Request.timeZone, dcon_Request.lstKeyValue);

            }
            else if(dcon_Request.operationType == 'WO_UNASSIGN_NO')
            {   
                if(dcon_Request.technicianIds.get(0) != NULL && dcon_Request.technicianIds.get(0) != '')
                {
                    DCON_Work_Order_WS.DCON_Assign_Work_Order_To_Tech_WS(UserId, dcon_Request.WorkOrderIds, dcon_Request.technicianIds.get(0), setOwner);
                }   
                if(dcon_Request.EventIds != null && dcon_Request.EventIds.size()>0)
                    DCON_Event_WS.DCON_Delete_Events_WS (UserId, dcon_Request.EventIds);
                if(dcon_Request.EventList != null && dcon_Request.EventList.size()>0)
                    EventIds = DCON_Event_WS.DCON_Upsert_Events_WS4 (UserId, dcon_Request.EventList, dcon_Request.timeZone, dcon_Request.lstKeyValue);

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
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            system.debug(logginglevel.warn,'ex.getstackTrace()'+ex.getStackTraceString());
            system.debug('Main error list'+ex.getmessage());
            throw new SVMXException(ex.getmessage());
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
        return DCON_Response;
    }

    WebService static workorderInfo_WP DCON_Retrieve_Work_Order_Info(){
        DCON_Utils dcUtils = new DCON_Utils(); 
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        workorderInfo_WP response = new workorderInfo_WP();
        Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
        Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap(); // Get field definition map for work order
        
        //START: DNS-623
        //get the list of WO fields which are to be loaded instead of loading all WO fields
        Set<String> setWOFields = getWorkOrderFieldstoLoad();
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
        DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);    
        newSchemaFieldMap.clear();
        souObjfieldMap.clear();
        List<String> limitedFields_L = reference_M.allFields_L; //Get the all field list
        //END: DNS-623
        
        response.refFields = reference_M.referenceFields_L; //Get the reference field list
        response.dateTimeFields = reference_M.dateTimeFields_L; //Get the dateTime field list
        response.dateFields = reference_M.dateFields_L; //Get the date field list
        String fieldValue;

        //Get the replacement reference field map
        Map<String,String> replacementRef = reference_M.replacementReference_M;
        for (String fieldKey : replacementRef.keySet())
        {
            fieldValue = replacementRef.get(fieldKey);
            response.replacementRef.add(fieldKey + '|' + fieldValue);
        }

        //Get the name field for reference map
        Map<String,String> replacementField = reference_M.replacementField_M;
        for (String fieldKey : replacementField.keySet())
        {
            fieldValue = replacementField.get(fieldKey);
            response.replacementField.add(fieldKey + '|' + fieldValue);
        }

        response.querySelect = utils.SVMX_getFieldNamesFromList(limitedFields_L); //Convert the list of strings to coma seperated string

        return response;
    }

    WebService static workorderDelta_WP DCON_Retrieve_Delta_Work_Orders_WS(List<String> keyValPairs, String UserId, String ViewId, List<String> DispatchStatus, String timeZone, List<String> workorderIds){ ////GM Feb3\tNew Call Introduced
        String WhereClause;
        String FirstWhereClause = '';
        String SecondWhereClause = '';
        String strPreFilterCriteria = '';
        String strOwnerShipType = '';
        Datetime dtmLastRetrievedDateTime;
        workorderDelta_WP response = new workorderDelta_WP();
        List<String> lstDeltaWorkOrderIds = new List<String>();
        List<String> lstDeletedWorkOrderIds = new List<String>();
        List<SVMXC__Service_Order__c> workorder_LO = new List<SVMXC__Service_Order__c>();

        //Processing the key value pairs
        system.debug('keyValPairs: ' + keyValPairs);
        if(keyValPairs != null && keyValPairs.size() > 0)
        {
            for(Integer i = 0;i<keyValPairs.size();i++)
            {
                String keyvaluepair = keyValPairs[i];
                keyvaluepair = keyvaluepair.replace('|',':');
                list<String> keyvaluepairlist = new list<String>(); 
                keyvaluepairlist = keyvaluepair.split(':');
                if(keyvaluepairlist != NULL && keyvaluepairlist[0] == 'LRD')
                {
                    if(keyvaluepairlist[1] != NULL)
                    {
                        try
                        {
                            dtmLastRetrievedDateTime = Datetime.valueOf(long.valueOf(keyvaluepairlist[1]));
                            system.debug('LRD: ' + dtmLastRetrievedDateTime);
                        }
                        catch(Exception ex)
                        {
                        }
                    }
                }
            }
        }

        /* If no view id is passed, it sets "My Work Order" view as default */
        if(ViewId == null || ViewId == '')
        {
            List<DCON_Configuration_WS.SVMX_StringMap> viewList = new List<DCON_Configuration_WS.SVMX_StringMap>();
            viewList = DCON_Work_Order_WS.DCON_Retrieve_Views_WS(UserId);
            if(viewList[0]!=NULL)
                ViewId = viewList[0].Key; //Selects the first view
        }
        system.debug('View Id: ' + ViewId + '; Work Order IDs: ' + workorderIds + '; Last Retrieved Date Time: ' + dtmLastRetrievedDateTime);

        if(dtmLastRetrievedDateTime != NULL)
        {
            /* Building where clause for getting new/updated work orders*/
            if(ViewId != '')
            {
                //Added by Amar for to support deliverable D-00000082
                // Check if ViewId is Owner Id / Queue Id or Work Order View Id
                String strPrefix  = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.getKeyPrefix();
                if(strPrefix == ViewId.substring(0,3))
                {
                    list<SVMXC__ServiceMax_Processes__c> lstViews = new list<SVMXC__ServiceMax_Processes__c>();
                    lstViews = [select Id, SVMXC__Name__c, SVMXC__Values__c,SVMXC__Ownership_Type__c,SVMXC__Parent_Object_Criteria__c  from SVMXC__ServiceMax_Processes__c where id =: ViewId];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(lstViews.size() > 0)
                    {
                        if(lstViews[0].SVMXC__Parent_Object_Criteria__c != null)
                            strPreFilterCriteria = lstViews[0].SVMXC__Parent_Object_Criteria__c;
                        if(lstViews[0].SVMXC__Ownership_Type__c != null)
                            strOwnerShipType = lstViews[0].SVMXC__Ownership_Type__c;    
                    }
                    else
                    {
                        throw new SVMXException(system.label.DCON001_TAG328);
                    }
                    if( strPreFilterCriteria != null && strPreFilterCriteria.length() > 0)//isView &&
                    {
                        FirstWhereClause = strPreFilterCriteria;
                    }
                    if( strOwnerShipType != null && strOwnerShipType.length() > 0 && strOwnerShipType == 'User\'s Records')//isView &&
                    {
                        String strUserId = Userinfo.getUserId();
                        if(FirstWhereClause != null && FirstWhereClause.length() > 0)
                            FirstWhereClause = ' ( ' + FirstWhereClause + ' ) ' + ' AND OwnerId =: strUserId';
                        else 
                            FirstWhereClause += 'OwnerId =: strUserId';
                    }
                }
                else
                {
                    FirstWhereClause = 'OwnerId =: ViewId';
                }   
            }

            if(DispatchStatus[0].toUpperCase()!='ALL')
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
                            SecondWhereClause += ' (SVMXC__Group_Member__c != NULL) ';//Apurva :Defect - 011238
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
                            SecondWhereClause += ' (SVMXC__Group_Member__c != NULL) ';   //Apurva :Defect - 011238 
                    }
                }   
            }

            if(FirstWhereClause != null && FirstWhereClause.length() > 0)
            {
                if(SecondWhereClause != null && SecondWhereClause.length() > 0)
                    WhereClause = ' ( '+FirstWhereClause+' ) ' + SecondWhereClause;
                else
                    WhereClause = FirstWhereClause + SecondWhereClause;   
            }
            else
            {
                WhereClause = SecondWhereClause;
            }
            system.debug('WhereClause to get new/updated records: ' + WhereClause);

            String strQuery1 = '';
            if(WhereClause != null && WhereClause.length() > 0)
                strQuery1 = 'SELECT Id FROM SVMXC__Service_Order__c WHERE LastModifiedDate > :dtmLastRetrievedDateTime AND ( ' + WhereClause + ')';//string.escapeSingleQuotes(
            else
                strQuery1 = 'SELECT Id FROM SVMXC__Service_Order__c WHERE LastModifiedDate > :dtmLastRetrievedDateTime ';
            system.debug('strQuery1 to get new/updated records: ' + strQuery1);
            workorder_LO = Database.query(strQuery1);
        }

        // Process the work orders that are modified/added newly
        for(SVMXC__Service_Order__c objWO: workorder_LO)
        {
            lstDeltaWorkOrderIds.add(objWO.Id);
        }
        system.debug('lstDeltaWorkOrderIds: ' + lstDeltaWorkOrderIds);

        // Get the work orders that no longer qualify the critieria / got deleted
        workorder_LO.clear();
        FirstWhereClause = '';
        SecondWhereClause = '';

        if(ViewId != '' && ViewId != null)
        {
            //Added by Amar for to support deliverable D-00000082
            // Check if ViewId is Owner Id / Queue Id or Work Order View Id
            String strPrefix  = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.getKeyPrefix();
            if(strPrefix == ViewId.substring(0,3))
            {
                list<SVMXC__ServiceMax_Processes__c> lstViews = new list<SVMXC__ServiceMax_Processes__c>();
                lstViews = [select Id, SVMXC__Name__c, SVMXC__Values__c,SVMXC__Ownership_Type__c,SVMXC__Parent_Object_Criteria__c  from SVMXC__ServiceMax_Processes__c where id =: ViewId];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstViews.size() > 0)
                {
                    if(lstViews[0].SVMXC__Parent_Object_Criteria__c != null)
                        strPreFilterCriteria = lstViews[0].SVMXC__Parent_Object_Criteria__c;
                    if(lstViews[0].SVMXC__Ownership_Type__c != null)
                        strOwnerShipType = lstViews[0].SVMXC__Ownership_Type__c;    
                }
                else
                {
                    throw new SVMXException(system.label.DCON001_TAG328);
                }

                if( strPreFilterCriteria != null && strPreFilterCriteria.length() > 0)
                {
                    FirstWhereClause = strPreFilterCriteria;
                }
                if(strOwnerShipType != null && strOwnerShipType.length() > 0 && strOwnerShipType == 'User\'s Records') 
                {
                    String strUserId = Userinfo.getUserId();
                    if(FirstWhereClause != null && FirstWhereClause.length() > 0)
                        FirstWhereClause = ' (Not( ( ' + FirstWhereClause + ' ) ' + ' AND (OwnerId =: strUserId) ) )';
                    else
                        FirstWhereClause += '(Not (OwnerId =: strUserId) )';       
                }
                else
                {
                    if(FirstWhereClause != null && FirstWhereClause.length() > 0)
                        FirstWhereClause = ' (Not ( ' + FirstWhereClause + ' ) )';
                }    
            }    
            else
            {
                FirstWhereClause = 'OwnerId != : ViewId';
            }   
        }

        if(DispatchStatus[0].toUpperCase()!='ALL')
        {
            if(DispatchStatus.size() == 1)
            {
                if(FirstWhereClause != null && FirstWhereClause.length() > 0)
                {
                    for(String ds: DispatchStatus)
                    {
                        if(SecondWhereClause == '')
                            SecondWhereClause += ' OR ( ';
                        else if(ds.toUpperCase()=='NEW' || ds.toUpperCase()=='QUEUED' || ds.toUpperCase()=='ASSIGNED')
                            SecondWhereClause += ' OR ';
                        if(ds.toUpperCase()=='NEW')
                            SecondWhereClause += ' ( SVMXC__Group_Member__c != NULL ) OR ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c != NULL ) ';//Apurva :Defect - 011238
                        else if(ds.toUpperCase()=='QUEUED')
                            SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c = NULL ) OR ( SVMXC__Group_Member__c != NULL )';//Apurva :Defect - 011238
                        else if(ds.toUpperCase()=='ASSIGNED')
                            SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c = NULL ) OR ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c != NULL )';
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
                            SecondWhereClause += ' ( SVMXC__Group_Member__c != NULL  ) OR ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c != NULL ) ';//Apurva :Defect - 011238
                        else if(ds.toUpperCase()=='QUEUED')
                            SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c = NULL ) OR ( SVMXC__Group_Member__c != NULL)';//Apurva :Defect - 011238
                        else if(ds.toUpperCase()=='ASSIGNED')
                            SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c = NULL ) OR ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c != NULL )';    
                    }
                }   
            }
            if(DispatchStatus.size() == 2)
            {
                Boolean isEntered = false;
                if(FirstWhereClause != null && FirstWhereClause.length() > 0)
                {
                    if((DispatchStatus[0].toUpperCase()=='NEW' && DispatchStatus[1].toUpperCase()=='ASSIGNED') || (DispatchStatus[0].toUpperCase()=='ASSIGNED' && DispatchStatus[1].toUpperCase()=='NEW'))
                    {
                        if(SecondWhereClause == '')
                            SecondWhereClause += ' OR ( ';
                        SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c != NULL ) ';
                        SecondWhereClause += ' ) ';
                    }
                    if((DispatchStatus[0].toUpperCase()=='NEW' && DispatchStatus[1].toUpperCase()=='QUEUED') || (DispatchStatus[0].toUpperCase()=='QUEUED' && DispatchStatus[1].toUpperCase()=='NEW'))
                    {
                        if(SecondWhereClause == '')
                            SecondWhereClause += ' OR ( ';
                        SecondWhereClause += ' (SVMXC__Group_Member__c != NULL ) ';
                        SecondWhereClause += ' ) ';
                    }
                    if((DispatchStatus[0].toUpperCase()=='QUEUED' && DispatchStatus[1].toUpperCase()=='ASSIGNED') || (DispatchStatus[0].toUpperCase()=='ASSIGNED' && DispatchStatus[1].toUpperCase()=='QUEUED'))
                    {
                        if(SecondWhereClause == '')
                            SecondWhereClause += ' OR ( ';
                        SecondWhereClause += ' (SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c = NULL ) ';
                        SecondWhereClause += ' ) '; 
                    }
                }
                else
                {
                    if((DispatchStatus[0].toUpperCase()=='NEW' && DispatchStatus[1].toUpperCase()=='ASSIGNED') || (DispatchStatus[0].toUpperCase()=='ASSIGNED' && DispatchStatus[1].toUpperCase()=='NEW'))
                    {
                        if(SecondWhereClause == '')
                            SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c != NULL ) ';
                        else
                        {
                            SecondWhereClause += ' OR ( ';
                            SecondWhereClause += ' ( SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c != NULL ) ';
                            SecondWhereClause += ' ) ';
                        }

                    }
                    if((DispatchStatus[0].toUpperCase()=='NEW' && DispatchStatus[1].toUpperCase()=='QUEUED') || (DispatchStatus[0].toUpperCase()=='QUEUED' && DispatchStatus[1].toUpperCase()=='NEW'))
                    {
                        if(SecondWhereClause == '')
                            SecondWhereClause += ' (SVMXC__Group_Member__c != NULL ) ';
                        else
                        {   
                            SecondWhereClause += ' OR ( ';
                            SecondWhereClause += ' (SVMXC__Group_Member__c != NULL ) ';
                            SecondWhereClause += ' ) ';
                        }   
                    }
                    if((DispatchStatus[0].toUpperCase()=='QUEUED' && DispatchStatus[1].toUpperCase()=='ASSIGNED') || (DispatchStatus[0].toUpperCase()=='ASSIGNED' && DispatchStatus[1].toUpperCase()=='QUEUED'))
                    {
                        if(SecondWhereClause == '')
                            SecondWhereClause += ' (SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c = NULL ) ';
                        else
                        {   
                            SecondWhereClause += ' OR ( ';
                            SecondWhereClause += ' (SVMXC__Group_Member__c = NULL and SVMXC__Service_Group__c = NULL ) ';
                            SecondWhereClause += ' ) ';
                        }    
                    }
                }   
            }
        }

        WhereClause =  FirstWhereClause + SecondWhereClause;//
        String strQuery = '';
        if(WhereClause != null && WhereClause.length() > 0)
            strQuery = 'SELECT Id FROM SVMXC__Service_Order__c WHERE Id IN :workorderIds AND ((' + WhereClause + ') OR ( isdeleted = true ))  all rows'; //string.escapeSingleQuotes(
        else
            strQuery = 'SELECT Id FROM SVMXC__Service_Order__c WHERE Id IN :workorderIds AND isdeleted = true  all rows'; //string.escapeSingleQuotes(

        for(SVMXC__Service_Order__c objWO: Database.query(strQuery))
        {
            lstDeletedWorkOrderIds.add(objWO.Id);
        }
        response.lstDeltaWorkOrderIds = lstDeltaWorkOrderIds;
        response.lstDeletedWorkOrderIds = lstDeletedWorkOrderIds;
        return response; 
    }

    WebService static List<workorder_WP> DCON_Retrieve_Work_Orders_WO_WS(String UserId, String timeZone, List<String> workorderIds){
        List<String> DispatchStatus = new List<String>();
        DispatchStatus.add('ALL'); 
        return DCON_Work_Order_WS.DCON_Retrieve_Work_Orders(UserId, '', DispatchStatus, timeZone, workorderIds, NULL); // Gm Feb3\tchanged to call DCON_Retrieve_Work_Orders instead of DCON_Retrieve_Work_Orders_WS
        //The Second parameter is '' bcoz flex is setting it as '' and in code we r checking against '' not against NULL
    }

    WebService static List<workorder_WP> DCON_Retrieve_AllWorkOrder_Ids_WS(List<String> keyValPairs, String UserId, String ViewId, List<String> DispatchStatus,String timeZone){ ////GM Feb14\tNew Call Introduced for implementing pagination, should return only Ids
        return DCON_Work_Order_WS.DCON_Retrieve_Work_Orders(UserId, ViewId, DispatchStatus, timeZone, Null, keyValPairs); 
    }
    WebService static List<workorder_WP> DCON_Retrieve_Work_Orders_WS2(List<String> keyValPairs, String UserId, String ViewId, List<String> DispatchStatus,String timeZone, List<String> workorderIds){ ////GM Feb3\tNew Call Introduced
        return DCON_Work_Order_WS.DCON_Retrieve_Work_Orders(UserId, ViewId, DispatchStatus, timeZone, workorderIds, keyValPairs); 
    }

    WebService static List<workorder_WP> DCON_Retrieve_Work_Orders_WS(String UserId, String ViewId, List<String> DispatchStatus,String timeZone, List<String> workorderIds){
        return DCON_Work_Order_WS.DCON_Retrieve_Work_Orders(UserId, ViewId, DispatchStatus, timeZone, workorderIds, NULL); //GM Feb3\tNot Supported in w11, migrated to public method : DCON_Retrieve_Work_Orders, additional parameter added to SORT the WO
    }

    public static List<workorder_WP> DCON_Retrieve_Eliminated_Work_Order_Info(String UserId, String timeZone, List<String> workorderIds){

        /* Import required classes */
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        DCON_Utils dcUtils = new DCON_Utils(); 
        /* Variable definitions */ 
        String WhereClause;
        String FirstWhereClause = '';
        String querySelect; 
        Boolean isLocal = false;
        List<workorder_WP> workorder_LWP = new List<workorder_WP>(); //Result set for the method
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
        Set<String> setWOFields = getWorkOrderFieldstoLoad();
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
        DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);    
        newSchemaFieldMap.clear();
        souObjfieldMap.clear();
        List<String> limitedFields_L = reference_M.allFields_L; //Get the all field list
        //END: DNS-623
        
        refFields_L = reference_M.referenceFields_L; //Get the reference field list
        dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
        dateFields_L = reference_M.dateFields_L; //Get the date field list
        replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
        replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
        querySelect = utils.SVMX_getFieldNamesFromList(limitedFields_L); //Convert the list of strings to coma seperated string

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
        
        workorder_WP workorder_WP;
        List<workorderSpecialFields_WP> specialFields_LWP;
        try
        {
            for(SVMXC__Service_Order__c wo:  Database.query('SELECT ' + querySelect +' FROM SVMXC__Service_Order__c WHERE '+string.escapeSingleQuotes(WhereClause))){
                specialFields_LWP = new List<workorderSpecialFields_WP>();

                for(String s : refFields_L){
                    workorderSpecialFields_WP tRef;
                    Sobject ref_TO = wo.getSobject(replacementRef.get(s));
                    if(ref_TO!=NULL){
                        tRef = new workorderSpecialFields_WP(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
                        specialFields_LWP.add(tRef);
                    }
                }

                for(String s : dateTimeFields_L){
                    workorderSpecialFields_WP tDateTime;
                    if(wo.get(s) != NULL){
                        tDateTime = new workorderSpecialFields_WP(s, dcUtils.getDateTimeInTimezone(Datetime.valueof(wo.get(s)).date(), Datetime.valueof(wo.get(s)).time(), timeZone).format() );
                        specialFields_LWP.add(tDateTime);
                    }
                }

                for(String s : dateFields_L){
                    workorderSpecialFields_WP tDate;
                    if(wo.get(s) != NULL){
                        tDate = new workorderSpecialFields_WP(s, Date.valueof(String.valueof(wo.get(s))).format() );
                        specialFields_LWP.add(tDate);
                    }
                }
                workorder_WP = new workorder_WP(wo,specialFields_LWP);
                workorder_LWP.add(workorder_WP);
            }
        }
        catch(Exception ex){
            throw new SVMXException(ex.getmessage());
        }
        return workorder_LWP;

    }

    Public  static List<workorder_WP> DCON_Retrieve_Work_Orders(String UserId, 
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
            List<DCON_Configuration_WS.SVMX_StringMap> viewList = new List<DCON_Configuration_WS.SVMX_StringMap>();
            viewList = DCON_Work_Order_WS.DCON_Retrieve_Views_WS(UserId);
            if(viewList[0] != NULL)
                ViewId = viewList[0].Key;
        }

        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        DCON_Utils dcUtils = new DCON_Utils();

        String WhereClause;
        String FirstWhereClause = '';
        String SecondWhereClause = '';
        String strPreFilterCriteria = '';
        String strOwnerShipType = '';
        String querySelect; 
        List<workorder_WP> workorder_LWP = new List<workorder_WP>();
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
            Set<String> setWOFields = getWorkOrderFieldstoLoad();
            
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
            querySelect = utils.SVMX_getFieldNamesFromList(limitedFields_L);        
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
                    throw new SVMXException(system.label.DCON001_TAG328);
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

        workorder_WP workorder_WP;
        List<workorderSpecialFields_WP> specialFields_LWP;

        if(querySelect == 'Id')
        {
            for(SVMXC__Service_Order__c wo: Database.query(strQuery))
            {
                workorder_WP = new workorder_WP(wo, specialFields_LWP);
                workorder_LWP.add(workorder_WP);
            }
        }
        else
        {
            for(SVMXC__Service_Order__c wo: Database.query(strQuery))
            {
                specialFields_LWP = new List<workorderSpecialFields_WP>();
                
                for(String s : refFields_L){
                    workorderSpecialFields_WP tRef;
                    Sobject ref_TO = wo.getSobject(replacementRef.get(s));
                    if(ref_TO!=NULL){
                        tRef = new workorderSpecialFields_WP(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
                        specialFields_LWP.add(tRef);
                    }
                }
                
                for(String s : dateTimeFields_L){
                    if(wo.get(s) != NULL){
                        system.debug(logginglevel.warn,'WO datetime value'+wo.get(s));
                        workorderSpecialFields_WP tDateTime = new workorderSpecialFields_WP(s, ((Datetime)(wo.get(s))).format() );
                        specialFields_LWP.add(tDateTime);
                    }
                }
                for(String s : dateFields_L){
                    if(wo.get(s) != NULL){
                        workorderSpecialFields_WP tDate = new workorderSpecialFields_WP(s, Date.valueof(String.valueof(wo.get(s))).format() );
                        specialFields_LWP.add(tDate);
                    }
                }
                workorder_WP = new workorder_WP(wo, specialFields_LWP);
                workorder_LWP.add(workorder_WP);
            }
        }

        if(workorder_LWP != null && workorder_LWP.size() > 0 )
            workorder_LWP.get(workorder_LWP.size()-1).lastSyncedTime = DateTime.now().getTime();
        else
        {
            set<string> setWorkOrderFields = new set<string>();
            workorder_WP obj = new workorder_WP();
            setWorkOrderFields  = getFieldUpdates();
            List<workorderSpecialFields_WP> FieldUpdateWrapper = new List<workorderSpecialFields_WP> ();
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
                obj = new workorder_WP();
                obj.lastSyncedTime = DateTime.now().getTime();  
            }       
            workorder_LWP.add(obj);
        }

        return workorder_LWP;
    }

    //Returns the Work orders for the list of work order Ids
    WebService static List<SVMXC__Service_Order__c> DCON_Retrieve_Work_Orders_LatLng_WS(String UserId, List<String> WorkOrderIds){
        List<SVMXC__Service_Order__c> workorder_LO = new List<SVMXC__Service_Order__c>();
        try
        {
            String souObjFieldNames;
            DCON_Utils dcUtils = new DCON_Utils(); 
            if(WorkOrderIds.size()==0)
                throw new SVMXException('Please give some work order ids to fetch geo details');
            Map<String,String> FieldDef = new Map<String,String>();
            String InVal = dcUtils.SVMX_get_ListOfValues(WorkOrderIds);
            String WhereClause = 'Id IN ' +InVal;
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getmessage());
        }

        return Database.query('SELECT Name, SVMXC__Longitude__c, SVMXC__Latitude__c, SVMXC__City__c, SVMXC__Street__c, SVMXC__Country__c FROM SVMXC__Service_Order__c WHERE Id IN :WorkOrderIds');    
    }
    
    //Retrieve Event hover information for the given WO Id
    WebService static list<String> DCON_Retrieve_Work_Order_EventHover(String WorkOrderId)
    {    
        List<SVMXC__Service_Order__c> lstWorkOrders = new List<SVMXC__Service_Order__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> mapEventHoverRules  = new Map<Id, SVMXC__ServiceMax_Processes__c>();   
        Map<Id, SVMXC__ServiceMax_Config_Data__c> mapEventHoverFields = new Map<Id, SVMXC__ServiceMax_Config_Data__c>();
        Map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEventHoverRuleIdExpr  = new Map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        Map<Id, List<Id>> mapEventHoverRuleIdFieldIdList = new Map<Id, List<Id>>();
        Map<String, SObjectField> objWorkOrderFieldMap = new Map<String, SObjectField>();
        Set<String> setWOQueryFields = new Set<String>();

        set<String> setDateTimeFields = new set<String>();
        set<String> setDateFields = new set<String>();
        set<String> setRefFields = new set<String>();
        Map<String, String> mapWOFieldNameLabel = new Map<String, String>();
        List<String> lstEventHoverInfo = new List<String>();
        string FieldMapRTypeId;
        string RuleRecordTypeId;
        string ExpressionRTypeId;
        if(WorkOrderId != null)
        {
            try
            {
                list<RecordType> RecordTypes = Database.query('Select SobjectType, Id, Name From RecordType where (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'SVMX Rule\') OR (SobjectType = \'SVMXC__ServiceMax_Config_Data__c\' AND Name IN (\'Expressions\', \'Field Mapping\'))');
                for(RecordType recType : RecordTypes)
                {
                    if(recType.Name == 'SVMX Rule')
                        RuleRecordTypeId = recType.id;
                    else if(recType.Name == 'Expressions')
                        ExpressionRTypeId = recType.id;
                    else if(recType.Name == 'Field Mapping')
                        FieldMapRTypeId = recType.id;
                }  

                DCON_Utils dcUtils = new DCON_Utils();
                objWorkOrderFieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
                DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(objWorkOrderFieldMap,true);
                List<String> allFields_L = reference_M.allFields_L; //Get the all field list
                List<String> refFields_L = reference_M.referenceFields_L; //Get the reference field list
                List<String> dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
                List<String> dateFields_L = reference_M.dateFields_L; //Get the date field list
                Map<String,String> replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
                Map<String,String> replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
                setDateTimeFields.addAll(dateTimeFields_L);
                setDateFields.addAll(dateFields_L);
                setRefFields.addAll(refFields_L);
                for (String fieldKey : objWorkOrderFieldMap.keySet())
                {
                    Schema.SObjectField fsObj = objWorkOrderFieldMap.get(fieldKey); 
                    Schema.DescribeFieldResult field = fsObj.getDescribe();
                    if(field.isAccessible())
                        mapWOFieldNameLabel.put(field.getName(), field.getLabel());
                }
                // Get the Event Hover Rules' header definition
                mapEventHoverRules = (new Map<Id, SVMXC__ServiceMax_Processes__c> ([Select Id,SVMXC__Sequence__c, SVMXC__Advance_Expression__c From SVMXC__ServiceMax_Processes__c  where RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c = 'Event Hover Rule']));
                system.debug(LoggingLevel.WARN, 'Size of mapEventHoverRules: ' + mapEventHoverRules.size() + '; Map: ' + mapEventHoverRules);

                if(mapEventHoverRules.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c oExp : [Select Id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c From SVMXC__ServiceMax_Config_Data__c where RecordTypeId = :ExpressionRTypeId and SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule' and SVMXC__Expression_Rule__c IN :mapEventHoverRules.keyset() Order By SVMXC__Sequence__c])
                    {
                        if(!mapEventHoverRuleIdExpr.ContainsKey(oExp.SVMXC__Expression_Rule__c))
                            mapEventHoverRuleIdExpr.put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                        mapEventHoverRuleIdExpr.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                        setWOQueryFields.add(oExp.SVMXC__Field_Name__c);
                    }
                    system.debug(LoggingLevel.WARN, 'Size of mapEventHoverRuleIdExpr: ' + mapEventHoverRuleIdExpr.size() + '; Map: ' + mapEventHoverRuleIdExpr);

                    for(SVMXC__ServiceMax_Config_Data__c objEventHoverField: [Select Id, SVMXC__Target_Field_Name__c, SVMXC__Sequence__c, SVMXC__Expression_Rule__c From SVMXC__ServiceMax_Config_Data__c where RecordTypeId = :FieldMapRTypeId and SVMXC__Expression_Rule__c IN :mapEventHoverRules.keyset() order by SVMXC__Sequence__c DESC])
                    {
                        mapEventHoverFields.put(objEventHoverField.Id, objEventHoverField);
                        List<Id> lstHoverFieldId = new List<Id>();
                        lstHoverFieldId.add(objEventHoverField.Id);
                        if(mapEventHoverRuleIdFieldIdList.get(objEventHoverField.SVMXC__Expression_Rule__c) != NULL)
                            lstHoverFieldId.addAll(mapEventHoverRuleIdFieldIdList.get(objEventHoverField.SVMXC__Expression_Rule__c));
                        mapEventHoverRuleIdFieldIdList.put(objEventHoverField.SVMXC__Expression_Rule__c, lstHoverFieldId);
                        setWOQueryFields.add(objEventHoverField.SVMXC__Target_Field_Name__c);
                    }

                    system.debug(LoggingLevel.WARN, 'Size of mapEventHoverRuleIdFieldIdList: ' + mapEventHoverRuleIdFieldIdList.size() + '; Map: ' + mapEventHoverRuleIdFieldIdList);
                }

                // Get the list of Work Orders associated with the events retrieved
                for(String fieldName : allFields_L)
                {
                    // Add the name fields for the reference fields
                    if(fieldName.contains('.'))
                    {
                        if(setWOQueryFields.contains(fieldName.split('\\.',2)[0].replace('__r','__c')))
                            setWOQueryFields.add(fieldName);
                        else if((fieldName == 'Owner.Name' && setWOQueryFields.contains('OwnerId')) || (fieldName == 'CreatedBy.Name' && setWOQueryFields.contains('CreatedById')) || (fieldName == 'LastModifiedBy.Name' && setWOQueryFields.contains('LastModifiedById')) || (fieldName == 'RecordType.Name' && setWOQueryFields.contains('RecordTypeId')))
                            setWOQueryFields.add(fieldName);
                    }
                }
                setWOQueryFields.retainAll(allFields_L);
                String querySelect = SVMX_getFieldNamesFromList(setWOQueryFields); //Convert the set of strings to comma separated string
                system.debug(LoggingLevel.WARN, 'Work Order select clause fields: ' + querySelect);
                if(querySelect != null && querySelect.length() >0)
                    lstWorkOrders = Database.query('SELECT ' + querySelect + ' FROM SVMXC__Service_Order__c WHERE Id =:WorkOrderId');
                Map<id, sObject> mapWorkOrder = new Map<id, SVMXC__Service_Order__c>(); 
                if(lstWorkOrders != null && lstWorkOrders.size()>0)         
                    mapWorkOrder.put(lstWorkOrders[0].Id, (sObject)lstWorkOrders[0]);

                // For the given Work Order, find the matching Event Hover Rule Id if any
                COMM_SVMXC_Utils4 oUtils = new COMM_SVMXC_Utils4();
                Map<Id, string> mapWOIdEventHoverRuleId = oUtils.SVMX_ExpressionParsing(mapWorkOrder, mapEventHoverRuleIdExpr, mapEventHoverRules);
                system.debug(LoggingLevel.WARN, 'Size of mapWOIdEventHoverRuleId: ' + mapWOIdEventHoverRuleId.size() + '; Map: ' + mapWOIdEventHoverRuleId);
                lstWorkOrders.clear();
                mapEventHoverRuleIdExpr.clear();
                mapEventHoverRules.clear();

                if(mapWOIdEventHoverRuleId != null)
                {
                    // Build the Event Hover info for Work Order and attach to the associated events
                    if(mapEventHoverFields != null && mapEventHoverFields.size() > 0)
                    {
                        // Build the Event Hover info for each Work Order as HTML formatted string
                        Map<Id, List<String>> mapWOIdEventHoverInfo = new Map<Id, List<String>>();
                        for(id idWorkOrder : mapWOIdEventHoverRuleId.keySet())
                        {

                            if(mapEventHoverRuleIdFieldIdList.get(mapWOIdEventHoverRuleId.get(idWorkOrder)) != NULL)
                            {
                                sObject objWO = mapWorkOrder.get(idWorkOrder);
                                for(Id idHoverField: mapEventHoverRuleIdFieldIdList.get(mapWOIdEventHoverRuleId.get(idWorkOrder)))
                                {
                                    SVMXC__ServiceMax_Config_Data__c objHoverField = mapEventHoverFields.get(idHoverField);
                                    if(!setWOQueryFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                        continue;
                                    if(mapWOFieldNameLabel.containsKey(objHoverField.SVMXC__Target_Field_Name__c))
                                    {
                                        String strFieldValue;

                                        // For reference fields: Process the reference field and get the name field for the lookup
                                        if(setRefFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                        {
                                            Sobject ref_TO = objWO.getSobject(replacementRef.get(objHoverField.SVMXC__Target_Field_Name__c));
                                            if(ref_TO != NULL)
                                            {
                                                strFieldValue = String.valueof(ref_TO.get(replacementNameField.get(objHoverField.SVMXC__Target_Field_Name__c)));
                                            }
                                            if(strFieldValue == NULL)
                                                strFieldValue = '--';
                                        }
                                        // For datetime fields: Get the datetime formatted in logged in user's timezone
                                        else if(setDateTimeFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                        {
                                            if(objWO.get(objHoverField.SVMXC__Target_Field_Name__c) != NULL)
                                                strFieldValue = ((Datetime)(objWO.get(objHoverField.SVMXC__Target_Field_Name__c))).format();
                                            else
                                                strFieldValue = '--';
                                        }
                                        // For date fields: Get the date formatted in logged in user's timezone
                                        else if(setDateFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                        {
                                            strFieldValue = String.valueOf(objWO.get(objHoverField.SVMXC__Target_Field_Name__c));
                                            if(strFieldValue != NULL)
                                                strFieldValue = Date.valueof(strFieldValue).format();
                                            else
                                                strFieldValue = '--';
                                        }
                                        // All other fields: Just pass the value as it is stored
                                        else
                                        {
                                            strFieldValue = String.valueOf(objWO.get(objHoverField.SVMXC__Target_Field_Name__c));
                                            if(strFieldValue == NULL)
                                                strFieldValue = '--';
                                        }
                                        //lstEventHoverInfo.add('<font size="11" color="#6B6B6B">' + mapWOFieldNameLabel.get(objHoverField.SVMXC__Target_Field_Name__c)  + '</font>' + '\n' + strFieldValue +'\n');
                                        //lstEventHoverInfo.add('<B>' + mapWOFieldNameLabel.get(objHoverField.SVMXC__Target_Field_Name__c)  + '</B>' + ': ' + '\n' + strFieldValue + '\n');
                                        lstEventHoverInfo.add('<B>' + mapWOFieldNameLabel.get(objHoverField.SVMXC__Target_Field_Name__c)  + '</B>' + ': ' + strFieldValue);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch(DmlException ex)
            {
                throw new SVMXException(ex.getDmlMessage(0));
            }
            catch(Exception ex)
            {
                throw new SVMXException(ex.getMessage());
            }
        }
        return lstEventHoverInfo;
    }  

    public static String SVMX_getFieldNamesFromList(set<String> fieldList) {
        String fieldNames = '';
        for (String field : fieldList) {
            if (fieldNames.length()>0) {
                fieldNames += ',';
            }
            fieldNames += field;
        }
        return fieldNames;
    }
    
    //This method accepts search criteria, search settings and performs a keyword search on technicians and 
    //the related data such as team, territory, expertise and products if applicable.
    //It returns a list of team of technician IDs matching the criteria.
    public class DCON_Keyword_Search_WS_Wrapper
    {
        public set<String> TIds{get; set;}
        public String SearchType{get; set;}
        public String MatchedKeyword{get; set;}
        public DCON_Keyword_Search_WS_Wrapper(set<String> IP_TIds, String IP_SearchType, String IP_MatchedKeyword){
            TIds = IP_TIds;
            SearchType = IP_SearchType;
            MatchedKeyword = IP_MatchedKeyword;
        }
    }
    
    public static string ExpertisevalidationClause(String WhereClause)
    {
        return '(' + WhereClause + ') and ' + '((SVMXC__Availability_Start_Date__c != null and SVMXC__Availability_End_Date__c != null and SVMXC__Availability_Start_Date__c <=: dtToday and SVMXC__Availability_End_Date__c >=: dtToday ) OR (SVMXC__Availability_Start_Date__c = null and SVMXC__Availability_End_Date__c >=: dtToday ) OR (SVMXC__Availability_Start_Date__c <=: dtToday and SVMXC__Availability_End_Date__c = null) OR (SVMXC__Availability_Start_Date__c = null and SVMXC__Availability_End_Date__c = null))';

    }
    
    WebService static List<String> DCON_Keyword_Search_WS(String UserId, String Keyword, String FindWhat, String KeywordMatch, String SearchType){
        system.debug(LoggingLevel.WARN, 'DCON_Keyword_Search_WS input parameters: UserId - ' + UserId + '; Keyword - ' + Keyword + '; FindWhat - ' + FindWhat + '; KeywordMatch - ' + KeywordMatch + '; SearchType - ' + SearchType);
        // Keeping the Web Service method member names the same, but assigning them to local variables with proper names
        String strSearchText = Keyword;
        String strSearchFields = KeywordMatch;

        // If strSearchText is blank, return error
        if(strSearchText == NULL)
            throw new SVMXException('Please enter valid key values to search');

        List<SVMXC__Service_Group_Members__c> lstAllMatchedTechs = new List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__Service_Group_Product__c> lstTechTeamProducts = new List<SVMXC__Service_Group_Product__c>();
        List<SVMXC__Service_Group_Skills__c> lstTechTeamSkills = new List<SVMXC__Service_Group_Skills__c>();
        List<SVMXC__Territory_Coverage__c> lstTerrCoverage = new List<SVMXC__Territory_Coverage__c>();
        List<SVMXC__Service_Group__c> lstServiceTeams = new List<SVMXC__Service_Group__c>();

        COMM_SVMXC_Utils4 DC_Utils = new COMM_SVMXC_Utils4();
        DCON_Utils dcUtils = new DCON_Utils(); 
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();  
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
                lstSObjFields = utils.SVMX_getFieldList(mapSObjFields, true); 
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
                lstSObjFields = utils.SVMX_getFieldList(mapSObjFields, true); 
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
            strTechTeamQueryFields = utils.SVMX_getFieldNamesFromList(lstDirectQrySrchFields);

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
                TeamTechSet = DC_Utils.SearchTechnician2(lstAllMatchedTechs, lstTechTeamProducts, lstTechTeamSkills, lstTerrCoverage, lstSearchKeyValues, lstDirectQrySrchFields, SearchType.toUpperCase()=='ALL', isMatchProduct, isMatchSkill, isMatchTerritory);
            else if(FindWhat.toUpperCase() == 'TEAM')
                TeamTechSet = DC_Utils.SearchTeam(lstServiceTeams, lstTechTeamProducts, lstTechTeamSkills, lstSearchKeyValues, lstDirectQrySrchFields, SearchType.toUpperCase()=='ALL', isMatchProduct, isMatchSkill);

            if(TeamTechSet != NULL){
                for(Id s: TeamTechSet){
                    TeamTechList.add(String.valueof(s));
                }
            }
        }
        catch(DmlException ex)
        {
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        system.debug(LoggingLevel.WARN, 'TeamTechList: ' + TeamTechList);

        return TeamTechList;
    }

    WebService static String DCON_Assign_Work_Order_To_Tech_WS(String UserId, List<String> WorkOrderIds, String TechnicianId, Boolean SetOwner){
        String StatusMessage;
        //Validations
        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to assign');
        else if(TechnicianId=='')
            throw new SVMXException('Please provide some technician to assign');
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
                throw new SVMXException(ex.getDmlMessage(0));
            }
            catch(Exception ex)
            {
                throw new SVMXException(ex.getMessage());
            }
        }
        return StatusMessage;
    }

    //This method accepts a list of work orders and service teams, and assigns each work order to the specified service team (queue).
    WebService static String DCON_Assign_Work_Order_To_Team_WS(String UserId, List<String> WorkOrderIds, String TeamId, Boolean SetOwner){
        String StatusMessage;
        //Validations

        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to assign');
        else if(TeamId=='')
            throw new SVMXException('Please provide some team to assign');

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
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }

        return StatusMessage;
    }

    //This method accepts a list of work orders, and clears the current assignment to technician or team whichever is applicable.
    WebService static String DCON_Unassign_Work_Order_WS(String UserId, List<String> WorkOrderIds){
        String StatusMessage;
        //Validations
        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to unassign');

        try
        {
            boolean settingRetainDCLock = false;
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();

            if(svmxSettingList.Containskey('SET022') && svmxSettingList.get('SET022')=='True')
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
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return StatusMessage;
    }

    //This method accepts a list of work orders, and clears any future events of the work orders in Salesforce Event or ServiceMax Event objects.
    //The current assignment of the work order to a technician or team remains unaltered.
    WebService static String DCON_Unschedule_Work_Order_WS(String UserId, List<String> WorkOrderIds){
        String StatusMessage = '';

        List<Event> events = new List<Event>();
        List<SVMXC__SVMX_Event__c> SVMXevents = new List<SVMXC__SVMX_Event__c>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        //Validations

        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to unschedule');    
        try{

            if(svmxSettingList.Containskey('SET024') && svmxSettingList.get('SET024')=='True')
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
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return StatusMessage;
    }

    //Depreciated: No longer used
    //Call two methods 1->Assign technician to workorder 2->Create multiple events
    WebService static List<String> DCON_Assign_Work_Order_To_MultiTeam_WS(String UserId, List<String> WorkOrderIds, String TechnicianId, String timeZone, List<Event> EventList){

        return null;
    }

    //Call two methods 1->Assign technician to workorder 2->Create multiple events
    WebService static List<String> DCON_Assign_Work_Order_To_MultiTech_WS(String UserId, List<String> WorkOrderIds, String TechnicianId, String timeZone, List<Event> EventList, Boolean setOwner){

        return null;
    }
    
    WebService static List<String> DCON_Assign_Work_Order_To_MultiTech_WS2(String UserId, List<String> WorkOrderIds, String TechnicianId, String timeZone, List<Event> EventList, Boolean setOwner, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue){
        List<String> EventIds = new List<String>();
        Savepoint sp = Database.setSavepoint();
        System.debug('INPUT EVENT LIST: ' + EventList);
        try
        {
            // Bala(24-3-11): When technician id is not given don't do work order assignment
            if(TechnicianId != NULL && TechnicianId != '')
            {
                DCON_Work_Order_WS.DCON_Assign_Work_Order_To_Tech_WS(UserId, WorkOrderIds, TechnicianId, setOwner);
            }
            if(EventList.size()>0)
            {
                system.debug('Entered Event List');
                EventIds = DCON_Event_WS.DCON_Create_Events_WS3(UserId, EventList, timeZone, lstKeyValue); //Changed by Gm to WS3 on 7jun10
            }
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            system.debug('Main error list'+ex.getmessage());
            throw new SVMXException(ex.getmessage());
        }
        return EventIds;
    }

    global class unassignAssign_WP{
        WebService String deletedEvents{get; set;}
        WebService List<String> techEventIds{get; set;}
    }

    WebService static unassignAssign_WP DCON_UnAssignAssign_Work_Order_To_MultiTech_WS2(String UserId, List<String> WorkOrderIds, String TechnicianId, String timeZone, List<Event> EventList, Boolean setOwner, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue){
        unassignAssign_WP response = new unassignAssign_WP();
        List<String> EventIds = new List<String>();
        String StatusMessage;

        //set the flag true when technician is unassigned using DC(linx for servicepower integration)
        WSCH_OptimizedSchedulingService.isUnAssignDC=true;

        Savepoint sp = Database.setSavepoint();
        try
        {
            // Bala(1-4-11): If work order is passed do unassignment
            if(WorkOrderIds != NULL && WorkOrderIds.size() > 0)
            {
               String strEventId = '';
                 if(EventList.size()>0){
                       strEventId = EventList[0]. Id;
                 }
                    StatusMessage = DCON_Work_Order_WS.DCON_Unassign_Work_Order_WS_1(UserId, WorkOrderIds,strEventId);
            }
                //StatusMessage = DCON_Work_Order_WS.DCON_Unassign_Work_Order_WS(UserId, WorkOrderIds);
            // Bala(24-3-11): When technician id is not given don't do work order assignment
            if(TechnicianId != NULL && TechnicianId != '')
                DCON_Work_Order_WS.DCON_Assign_Work_Order_To_Tech_WS(UserId, WorkOrderIds, TechnicianId, setOwner);
            if(EventList.size()>0)

                EventIds = DCON_Event_WS.DCON_Create_Events_WS3(UserId, EventList, timeZone, lstKeyValue); //Changed by Gm to WS3 on 7jun10
            response.deletedEvents = StatusMessage;
            response.techEventIds = EventIds;
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getmessage());
        }
        return response;
    }
    
    global class UnAssignTechToWO_Request 
    {
        webservice String UserId{get;set;}
        webservice List<String> WorkOrderIds = new List<String>();
        webservice String TechnicianId{get;set;}      
        webservice String timeZone{get;set;}      
        webservice List<Event> EventList = new List<Event>(); 
        webservice Boolean setOwner{get;set;}
        webservice list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new list<DCON_Configuration_WS.SVMX_StringMap>();
        webservice Boolean isUpdate{get;set;}
         
        public UnAssignTechToWO_Request(string UserId, 
                        List<String> WorkOrderIds,
                        String TechnicianId,
                        String timeZone,
                        List<Event> EventList, 
                        Boolean setOwner,
                        List<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue,
                        Boolean isUpdate
                        ) 
        {
            this.UserId = UserId;
            this.WorkOrderIds = WorkOrderIds; 
            this.TechnicianId = TechnicianId;
            this.timeZone = timeZone;
            this.EventList = EventList;
            this.setOwner = setOwner;
            this.lstKeyValue = lstKeyValue;
            this.isUpdate = isUpdate;
                       
        }
        public UnAssignTechToWO_Request() {}
    }

    /**
    * Method Name:  DCON_Update_WOTech_WS
    * Description:  Update primary technician of WO with given technician and don't delete existing events
                    If 'isUpdate' parameter of input wrapper is true, it updates the existing event otherwise create new event
    * Parameters:   UnAssignTechToWO_Request
    * Return:       unassignAssign_WP  
    */
    WebService static unassignAssign_WP DCON_Update_WOTech_WS(UnAssignTechToWO_Request req){
        unassignAssign_WP response = new unassignAssign_WP();
        List<String> EventIds = new List<String>();
        String StatusMessage;

        //set the flag true when technician is unassigned using DC(linx for servicepower integration)
        WSCH_OptimizedSchedulingService.isUnAssignDC=true;

        Savepoint sp = Database.setSavepoint();
        try
        {
            // Bala(1-4-11): If work order is passed do unassignment
            if(req.WorkOrderIds != NULL && req.WorkOrderIds.size() > 0)
                StatusMessage = DCON_Update_WO(req.UserId, req.WorkOrderIds);
            // Bala(24-3-11): When technician id is not given don't do work order assignment
            if(req.TechnicianId != NULL && req.TechnicianId != '')
               DCON_Assign_Work_Order_To_Tech_WS(req.UserId, req.WorkOrderIds, req.TechnicianId, req.setOwner);
            if(req.EventList.size()>0)
            {
                if(req.isUpdate)
                {
                    //EventIds.add(DCON_Event_WS.DCON_Upsert_Events_WS3(req.UserId, req.EventList, req.timeZone, req.lstKeyValue));   
                    response.deletedEvents = DCON_Event_WS.DCON_Upsert_Events_WS3(req.UserId, req.EventList, req.timeZone, req.lstKeyValue);
                }
                else
                {
                    EventIds = DCON_Event_WS.DCON_Create_Events_WS3(req.UserId, req.EventList, req.timeZone, req.lstKeyValue); 
                }
                response.techEventIds = EventIds;
            }   
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getmessage());
        }
        return response;
    }
    /**
    * Method Name:  DCON_Update_WO
    * Description:  Update primary technician of WO with given technician and don't delete existing events
    * Parameters:   String UserId, List<String> WorkOrderIds
    * Return:       String  
    */
    public static String DCON_Update_WO(String UserId, List<String> WorkOrderIds){
        String StatusMessage;
        //Validations
        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to unassign');

        try
        {
            boolean settingRetainDCLock = false;
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();

            if(svmxSettingList.Containskey('SET022') && svmxSettingList.get('SET022')=='True')
                settingRetainDCLock = true;
            else
                settingRetainDCLock = false;
            /*
            //Unschedule the work orders related events
            StatusMessage = DCON_Unschedule_Work_Order_WS(UserId, WorkOrderIds);
            */

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
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return StatusMessage;
    }
    
    
    WebService static String DCON_RESET_WO_Time(List<String> WorkOrderIds)
    {
        string StatusMsg;
        try
        {
            if(WorkOrderIds!=null && WorkOrderIds.size()>0)
            {
                List<SVMXC__Service_Order__c> WorkOrder = new List<SVMXC__Service_Order__c>();
                WorkOrder = [SELECT Id,SVMXC__Driving_Time__c,SVMXC__Idle_Time__c,SVMXC__Locked_By_DC__c  from SVMXC__Service_Order__c where Id IN :WorkOrderIds];
                for(SVMXC__Service_Order__c wo : WorkOrder)
                {
                    wo.SVMXC__Driving_Time__c = 0;
                    wo.SVMXC__Idle_Time__c = 0;
                    wo.SVMXC__Locked_By_DC__c = true;
                }
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(WorkOrder,COMM_SecurityUtils.Access.Updateable)){
                    update WorkOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }                
                StatusMsg = 'Work Orders updated successfully';
            }
        }
        catch(DmlException ex)
        {
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return StatusMsg;
    }
    
    //START: DNS-623: Lazy loading code changes begins
   /**
    * Method Name:  getDefaultUserSettings
    * Description:  Get the default UI setting from static resource if UI settings do not exist for a user
    * Parameters:   
    * Return:       string  
    */
    public static string getDefaultUserSettings()
    {
        StaticResource sr = [Select  s.Name, s.Id, s.Body From StaticResource s where s.Name ='DCON_UI_Settings'];

        blob tempBlob = sr.Body;
        String tempString ='';
        tempString = tempBlob.toString();
        System.debug('tempString  '+tempString);
        
        if(tempString ==null)
           tempString ='';
       
        return tempString;
    }
    
   /**
    * Method Name:  getWorkOrderFieldstoLoad
    * Description:  Get list of WO fields to be loaded when DC launches, this is to help DC loading time by not loading all the WO fields
    * Parameters:
    * Return:       Set<String> 
    */
    public static Set<String> getWorkOrderFieldstoLoad() {
        Set<String> woFldSet = null;
        /*COMM_Utils_ManageSettings commManageSetting = new COMM_Utils_ManageSettings();
        String settingValue = commManageSetting.SVMX_getGlobalSettingList('GBL044');
        Boolean flag = false;
        Set<String> woFldSet = null;
        if(!String.isBlank(settingValue)){
            flag = Boolean.valueOf(settingValue);
        }
        
        //if DCx is enabled
        if(flag)
            woFldSet = getWorkOrderFieldstoLoadDCx();
        else*/
            woFldSet = getWorkOrderFieldstoLoadClassic();
            
        return woFldSet;
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

    public static Set<String> getWorkOrderFieldstoLoadClassic()
    {
        String userXML = '';
        Set<String> strWorkOrderFields = new Set<String>();
        User DispatcherRecord = [Select Id, SVMXC__Dispatch_Console_Settings__c from User where Id =:Userinfo.getUserId()];

        userXML = DispatcherRecord.SVMXC__Dispatch_Console_Settings__c;
        if(userXML == null || userXML.length() == 0)
            userXML = getDefaultUserSettings(); //update the method name
        
        Dom.Document doc = new Dom.Document();
        if(userXML != null && userXML.length() > 0)
            doc.load(userXML);
        else
            return strWorkOrderFields;

        Dom.Xmlnode rootElement = doc.getRootElement();
        
        //Load Dispatch Console Fields - We have to get all WO fields by skipping Event fields       
        strWorkOrderFields.addall(getFieldUpdates());
        
        /*From the UI settings we can get number of columns configured in the current/default view
        the color coding rules, work order rules and keyword search fields - only these will be loaded when DC launches
        other fields will be loaded only on demand */
        for(Dom.XMLNode firstChild : rootElement.getChildElements()) 
        {
            if(firstChild.getAttribute('id', null) == 'workOrderSettings')
            {
                for(Dom.XMLNode secondChild : firstChild.getChildElements())
                {
                    if(secondChild.getName() == 'selectedcolumns')
                    {
                        for(Dom.XMLNode thirdChild : secondChild.getChildElements())
                        {
                            if(thirdChild.getName() == 'column')
                            {
                                strWorkOrderFields.add(thirdChild.getAttributeValue(thirdChild.getAttributeKeyAt(0), thirdChild.getAttributeKeyNsAt(0)));
                            }
                        }
                    }
                    if(secondChild.getName() == 'rules')
                    {
                        for(Dom.XMLNode thirdChild : secondChild.getChildElements())
                        {
                            if(thirdChild.getName() == 'rule')
                            {
                                for(Dom.XMLNode fourthChild : thirdChild.getChildElements())
                                {
                                    if(fourthChild.getName() == 'row')
                                    {
                                        strWorkOrderFields.add(fourthChild.getAttributeValue(fourthChild.getAttributeKeyAt(0), fourthChild.getAttributeKeyNsAt(0)));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(firstChild.getAttribute('id', null) == 'technicianSettings')
            {
                for(Dom.XMLNode secondChild : firstChild.getChildElements())
                {
                    if(secondChild.getName() == 'rules')
                    {
                        for(Dom.XMLNode thirdChild : secondChild.getChildElements())
                        {
                            if(thirdChild.getName() == 'rule')
                            {
                                for(Dom.XMLNode fourthChild : thirdChild.getChildElements())
                                {
                                    if(fourthChild.getName() == 'row')
                                    {
                                        //get only the WO fields
                                        if(fourthChild.getAttributeValue(fourthChild.getAttributeKeyAt(1), fourthChild.getAttributeKeyNsAt(1)) == 'WO')
                                        {
                                            strWorkOrderFields.add(fourthChild.getAttributeValue(fourthChild.getAttributeKeyAt(0), fourthChild.getAttributeKeyNsAt(0)));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(firstChild.getAttribute('id', null) == 'keywordSettings')
            {
                for(Dom.XMLNode secondChild : firstChild.getChildElements())
                {
                    if(secondChild.getName() == 'selectedcolumns')
                    {
                        for(Dom.XMLNode thirdChild : secondChild.getChildElements())
                        {
                            if(thirdChild.getName() == 'column')
                            {
                                strWorkOrderFields.add(thirdChild.getAttributeValue(thirdChild.getAttributeKeyAt(0), thirdChild.getAttributeKeyNsAt(0)));
                            }
                        }
                    }
                }
            }
        }
        
        strWorkOrderFields.addAll(getDefaultWoFieldstoLoad());
         
        return strWorkOrderFields;
            
    }
    //END: DNS-623: Lazy loading code change ends

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

    public static set<string> getFieldUpdates()
    {
        set<string> setWorkOrderFields = new set<string>();

        //Load Dispatch Console Fields - We have to get all WO fields by skipping Event fields
            Map<String,String> mapValidSettingsForUpdate = new Map<String,String>();
            if(svmxSettingList.get('SET038') != null)
                mapValidSettingsForUpdate.put('SET038', svmxSettingList.get('SET038'));
            if(svmxSettingList.get('SET039') != null)
                mapValidSettingsForUpdate.put('SET039', svmxSettingList.get('SET039'));
            if(svmxSettingList.get('SET040') != null)
                mapValidSettingsForUpdate.put('SET040', svmxSettingList.get('SET040'));
            if(svmxSettingList.get('SET041') != null)
                mapValidSettingsForUpdate.put('SET041', svmxSettingList.get('SET041'));
            if(svmxSettingList.get('SET042') != null)
                mapValidSettingsForUpdate.put('SET042', svmxSettingList.get('SET042'));
            if(svmxSettingList.get('SET043') != null)
                mapValidSettingsForUpdate.put('SET043', svmxSettingList.get('SET043'));
            if(svmxSettingList.get('SET044') != null)
                mapValidSettingsForUpdate.put('SET044', svmxSettingList.get('SET044'));
            if(svmxSettingList.get('SET045') != null)
                mapValidSettingsForUpdate.put('SET045', svmxSettingList.get('SET045'));
            if(svmxSettingList.get('SET046') != null)
                mapValidSettingsForUpdate.put('SET046', svmxSettingList.get('SET046'));
            if(svmxSettingList.get('SET047') != null)
                mapValidSettingsForUpdate.put('SET047', svmxSettingList.get('SET047'));

            System.debug('mapValidSettingsForUpdate contents are:' + mapValidSettingsForUpdate);
            if(mapValidSettingsForUpdate.keySet().size() > 0)
            {
                for(String strfld : mapValidSettingsForUpdate.keySet())
                {
                    if(!String.valueOf(mapValidSettingsForUpdate.get(strfld)).contains('Event'))
                    {
                        setWorkOrderFields.add(mapValidSettingsForUpdate.get(strfld));    
                    }
                }
            }
             return setWorkOrderFields;
    }
    public static workorder_WP getFieldUpdateWrapper(set<string> setWorkOrderFields, List<String> workorderIds) 
    {
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        list<string> lstWorkOrderFields = new list<string>(setWorkOrderFields);
        workorder_WP WO_WP; 
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
            List<workorderSpecialFields_WP> FieldUpdateWrapper = new List<workorderSpecialFields_WP>();
            
            for(String s : refFields_L)
            {
                workorderSpecialFields_WP tRef;
                
                Sobject ref_TO = wo.getSobject(replacementRef.get(s));
                if(ref_TO!=NULL)
                {
                    tRef = new workorderSpecialFields_WP(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
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
                    workorderSpecialFields_WP tDateTime = new workorderSpecialFields_WP(s, ((Datetime)(wo.get(s))).format() );
                    FieldUpdateWrapper.add(tDateTime);
                    if(setWorkOrderFields.contains(s))
                        setWorkOrderFields.remove(s);
                }
            }
            for(String s : dateFields_L){
                if(wo.get(s) != NULL)
                {
                    workorderSpecialFields_WP tDate = new workorderSpecialFields_WP(s, Date.valueof(String.valueof(wo.get(s))).format() );
                    FieldUpdateWrapper.add(tDate);
                    if(setWorkOrderFields.contains(s))
                        setWorkOrderFields.remove(s);
                }
            }
            if(!setWorkOrderFields.isempty() && setWorkOrderFields.size()>0)
            {
                for(string s :new list<string>(setWorkOrderFields))
                {
                    workorderSpecialFields_WP WOField = new workorderSpecialFields_WP(s, String.valueof(wo.get(s)));
                    FieldUpdateWrapper.add(WOField);
                }
            }
            WO_WP = new workorder_WP(null,FieldUpdateWrapper);
        }       
            System.debug('WO_WP: '+WO_WP);
        return WO_WP;
    }

    //START: Delete events for a given technician Id and WorkOrder Id   
    global class DCTech_WO_WP
    {
        WebService String WorkOrderId {get; set;}
        WebService String TechId {get; set;}
        WebService String OwnerId {get; set;}
        Webservice String EventStartDateTime {get; set;} /** @deprecated **/
        WebService DateTime EventStartDtTm {get; set;}
        Webservice boolean isEarlierEvents {get; set;}
        Webservice String timeZone {get; set;}
        Webservice String eventId {get; set;} //will get this event Id only when we are trying to select and delete an event from past. 
        Webservice boolean isDeleteAllEvents {get; set;}
        Webservice String deleteSingleEventId {get; set;} //When user selects single event for delete, this variable will be fed.
        Webservice boolean isUnassignTech{get; set;}
        
        public DCTech_WO_WP(String WoId, String TechnicianId, String OwnId, boolean earlierEvents, DateTime EventSDTime, String userTimeZone,String eventId,boolean isDeleteAllEvents,String deleteSingleEventId,boolean isUnassignTech){
            this.WorkOrderId = WoId;
            this.TechId = TechnicianId;
            this.OwnerId = OwnId;
            this.isEarlierEvents = earlierEvents;
            this.EventStartDtTm = EventSDTime;
            this.timeZone = userTimeZone;
            this.eventId = eventId;
            this.isDeleteAllEvents = isDeleteAllEvents;
            this.deleteSingleEventId = deleteSingleEventId;
            this.isUnassignTech = isUnassignTech;
        }
        
        public DCTech_WO_WP(String WoId, String TechnicianId, String OwnId, boolean earlierEvents, DateTime EventSDTime, String userTimeZone,String eventId,boolean isDeleteAllEvents){
            this.WorkOrderId = WoId;
            this.TechId = TechnicianId;
            this.OwnerId = OwnId;
            this.isEarlierEvents = earlierEvents;
            this.EventStartDtTm = EventSDTime;
            this.timeZone = userTimeZone;
            this.eventId = eventId;
            this.isDeleteAllEvents = isDeleteAllEvents;
        }
               
        public DCTech_WO_WP(String WoId, String TechnicianId, String OwnId, boolean earlierEvents, String userTimeZone){
            this.WorkOrderId = WoId;
            this.TechId = TechnicianId;
            this.OwnerId = OwnId;
            this.isEarlierEvents = earlierEvents;
            this.timeZone = userTimeZone;
        }
        public DCTech_WO_WP() {}
    }
    
    global class DCTech_WO_Response_WP 
    {
        webservice String StatusMessage {get;set;}
        public DCTech_WO_Response_WP(String resp)
        {
            this.StatusMessage = resp;
        }
        public DCTech_WO_Response_WP() {}           
    }

    public static map<string, Map<String, String>> lstDCEventMgmtSettings = new map<string, Map<String, String>>();
    
    /**
     * Name             :   loadDCEventMgmtSettings
     * Params           :   None
     * Returns          :   Map<Key, Values> where Key is a module# 'DCON005' and values are the settings SET001, SET002., etc
     * Description      :   This is to get all the settings under the 'Event Management' submodule of 'Dispatch Management' module
     */
    public static Map<String, String> loadDCEventMgmtSettings()
    { 
        try
        {
            if(lstDCEventMgmtSettings == NULL || lstDCEventMgmtSettings.size() == 0)
            {
                list<String> eventSubModule = new list<string>{'DCON005'};
                SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                lstDCEventMgmtSettings = commSettings.SVMX_getSettingList(eventSubModule);          
            }
        } catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return lstDCEventMgmtSettings.get('DCON005');
    }
    
    /**
     * Name             :   DCON_AES_Unassign_WO_WS
     * Params           :   DCTech_WO_WP wrapper as a request having WOId, TechId/OwnerId, timeZone
     * Returns          :   DCTech_WO_Response_WP wrapper as a reponse
     * Description      :   This web service deletes events for a given technician id and work order id
     */
    WebService static DCTech_WO_Response_WP DCON_AES_Unassign_WO_WS(DCTech_WO_WP request)
    {
        DCTech_WO_Response_WP resp = new DCTech_WO_Response_WP();
        //Validations
        if(request.WorkOrderId == '' || request.TechId == '')
            throw new SVMXException('Please provide workorderId and/or techId to unassign');

        try
        {
            boolean settingRetainDCLock = false;
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();

            if(svmxSettingList.Containskey('SET022') && svmxSettingList.get('SET022') == 'True')
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
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return resp;
    }

    /**
     * Name             :   DCON_UnAssign_WO
     * Params           :   DCTech_WO_WP wrapper as a request having WOId, TechId/OwnerId, timeZone
     * Returns          :   void 
     * Description      :   This Method deletes events for a given technician id and work order id
     */
    public static void DCON_UnAssign_WO(DCTech_WO_WP request)
    {
        try 
        {
            boolean settingRetainDCLock = false;
            if(svmxSettingList.Containskey('SET022') && svmxSettingList.get('SET022') == 'True')
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
            throw new SVMXException(ex.getMessage());
        }
    }
    /**
     * Name             :   DCON_AES_Delete_Tech_Events
     * Params           :   DCTech_WO_WP wrapper as a request having WOId, TechId/OwnerId, timeZone 
     * Returns          :   DCTech_WO_Response_WP wrapper as a reponse
     * Description      :   This method takes care of SOQL queries in deleting events for a given technician id and work order id
     */
    public static DCTech_WO_Response_WP DCON_AES_Delete_Tech_Events(DCTech_WO_WP request)
    {
        Map<String, String> mapDCEventMgmtSettings = new Map<String, String>(loadDCEventMgmtSettings());
        DCON_Utils dcUtils = new DCON_Utils();
        DateTime dtmStartDateTime;
        DCTech_WO_Response_WP resp = new DCTech_WO_Response_WP();
        
        List<Event> SFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> SVMXEvents = new List<SVMXC__SVMX_Event__c>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();

        if(request.WorkOrderId.length() == 0)
            throw new SVMXException('Please provide some workorders to unschedule'); 
        
        try
        {
            if(request.timeZone == NULL || request.timeZone == '')
            {
                request.timeZone = Userinfo.getTimeZone().getID();
            }
            System.debug('request.EventStartDtTm:' + request.EventStartDtTm);
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
                dtmStartDateTime = dcUtils.doTZConversion(request.EventStartDtTm, request.timeZone, 'GMT');
                
                if(request.isEarlierEvents)
                {
                    //Check if deleting past events are allowed
                    if(svmxSettingList.Containskey('SET024') && svmxSettingList.get('SET024') == 'true')
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
                    if(svmxSettingList.Containskey('SET024') && svmxSettingList.get('SET024') == 'true')
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
                if(svmxSettingList.Containskey('SET024') && svmxSettingList.get('SET024') == 'true')
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
                if(svmxSettingList.Containskey('SET024') && svmxSettingList.get('SET024') == 'true')
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
                   throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }                  
            }
        
            if(SVMXEvents.size() > 0)
            { 
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){
                    delete SVMXEvents;  //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
                   throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }                
            }
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return resp;
    }
    /***** END: Delete events for a given technician Id and WorkOrder Id *****/
    
    /***** START: Retrieve WO details for a WOId passed *****/
    global class getWoRequest
    {
        WebService String WOId {get; set;}
         
        public getWoRequest(String WOId)
        {
            this.WOId = WOId;
        }
        public getWoRequest() {}
    }
    
    global class getWoResponse
    {
        WebService SVMXC__Service_Order__c WOdetails {get; set;}
         
        public getWoResponse(SVMXC__Service_Order__c WOdetails)
        {
            this.WOdetails = WOdetails;
        }
        public getWoResponse() {}
    }
    
    /**
    * Method Name:  DCON_Retrieve_WO_WS
    * Description:  Retrieve all fields of workorder for the given Workorder Id
    * Parameters:   getWoRequest - a wrapper having WOId
    * Return:       getWoResponse  
    */
    WebService static getWoResponse DCON_Retrieve_WO_WS(getWoRequest req){
        getWoResponse response = new getWoResponse();
        If(req != null)
        {
            DCON_Utils dcUtils = new DCON_Utils(); 
            SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
            Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
            Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap(); // Get field definition map for work order
            String strQuery;
            String querySelect;
            String WOId = req.WOId;
            
            Set<String> setWOFields = getWorkOrderFieldstoLoad();
            for (String fieldKey : souObjfieldMap.keySet()) 
            {
                String fieldName='';
                Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                fieldName = f.getName();
                newSchemaFieldMap.put(fieldName, fsObj);
            }
            DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);    
            newSchemaFieldMap.clear();
            souObjfieldMap.clear();
            List<String> limitedFields_L = reference_M.allFields_L; //Get the all field list
                  
            querySelect = utils.SVMX_getFieldNamesFromList(limitedFields_L); //Convert the list of strings to coma seperated string
            strQuery = 'SELECT ' + querySelect + ' FROM SVMXC__Service_Order__c WHERE ID =:WOId'; 
            response.WOdetails = Database.query(strQuery);
        }   
        System.debug('response:'+ response);
        return response;
    }
    /***** END: Retrieve WO details for a WOId passed *****/
    /***** START: Retrieve workorder count of view Id passed *****/
    global class ViewWoCountReq
    {
        WebService String viewId {get; set;}
         
        public ViewWoCountReq(String viewId)
        {
            this.viewId = viewId;
        }
        public ViewWoCountReq() {}
    }
    
    global class ViewWoCountResponse
    {
        Webservice String viewId {get; set;}
        WebService Integer WOcount {get; set;}
         
        public ViewWoCountResponse(String viewId,Integer WOcount)
        {
            this.viewId = viewId;
            this.WOcount = WOcount;
        }
        public ViewWoCountResponse() {}
    }
    /**
    * Method Name:  DCON_ViewWoCount_WS
    * Description:  Retrieve workorder count of view Id passed
    * Parameters:   ViewWoCountReq - a wrapper having view Id
    * Return:       ViewWoCountResponse  
    */
    WebService static ViewWoCountResponse DCON_ViewWoCount_WS(ViewWoCountReq req)
    {
        ViewWoCountResponse response;
        System.debug('ViewId:' + req.viewId);
        list<SVMXC__ServiceMax_Processes__c> lstViewrecords = new list<SVMXC__ServiceMax_Processes__c>();
        if(req.viewId != NULL)
        {
            String viewId = req.viewId;
            lstViewrecords = [select Id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__Ownership_Type__c, SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Processes__c where Id =: req.viewId];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                // Check if ViewId is Owner Id / Queue Id or Work Order View Id
            String strPrefix  = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.getKeyPrefix();
            // Build the Work Order query           
            String strPreFilterCriteria = '';
            String strOwnerShipType = '';
            String FirstWhereClause = '';
            String WhereClause = '';
            String strQuery = '';
                   
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
                    FirstWhereClause = 'OwnerId =: viewId';
                }   
            
            WhereClause = FirstWhereClause;
            if(WhereClause != null && WhereClause.length() > 0) //string.escapeSingleQuotes(
                strQuery = 'SELECT COUNT(Id) woViewCount_c FROM SVMXC__Service_Order__c WHERE ' + WhereClause;
            else
                strQuery = 'SELECT COUNT(Id) woViewCount_c FROM SVMXC__Service_Order__c';
                
            System.debug('strQuery:' + strQuery);
            
            AggregateResult woCount = Database.query(strQuery);
            response  = new ViewWoCountResponse(viewId,Integer.valueOf(woCount.get('woViewCount_c')));
            System.debug('response.WOcount:' + response.WOcount);
        }   
        return response;
    }       
    /***** END: Retrieve workorder count of view Id passed *****/   
    public static String DCON_Unschedule_Work_Order_WS_1(String UserId, List<String> WorkOrderIds,String EventId){
        String StatusMessage = '';
        List<String> eventsId = new List<String>();
        eventsId.add(EventId);
        List<Event> events = new List<Event>();
        List<SVMXC__SVMX_Event__c> SVMXevents = new List<SVMXC__SVMX_Event__c>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        //Validations
system.debug('EventId' + EventId);
        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to unschedule');    
        try{

            if(svmxSettingList.Containskey('SET024') && svmxSettingList.get('SET024')=='True')
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
                system.debug('EventId set024'  + false);
                if(eventsId.size()> 0){
                           events = [SELECT Id from event where( (WhatId IN :WorkOrderIds and StartDateTime > :System.now()) or (WhatId IN :WorkOrderIds and Id IN :eventsId))];
                            SVMXevents = [SELECT Id from SVMXC__SVMX_Event__c where ((SVMXC__WhatId__c IN :WorkOrderIds and SVMXC__StartDateTime__c > :System.now()) or (SVMXC__WhatId__c IN :WorkOrderIds and Id IN :eventsId) )];
               
                }
                else {
                     events = [SELECT Id from event where WhatId IN :WorkOrderIds and StartDateTime > :System.now()];
                     SVMXevents = [SELECT Id from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :WorkOrderIds and SVMXC__StartDateTime__c > :System.now()];
               
                }
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
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return StatusMessage;
    }

   public static String DCON_Unassign_Work_Order_WS_1(String UserId, List<String> WorkOrderIds,String EventId){
        String StatusMessage;
        //Validations
        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to unassign');

        try
        {
            boolean settingRetainDCLock = false;
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();

            if(svmxSettingList.Containskey('SET022') && svmxSettingList.get('SET022')=='True')
                settingRetainDCLock = true;
            else
                settingRetainDCLock = false;

            //Unschedule the work orders related events
            StatusMessage = DCON_Unschedule_Work_Order_WS_1(UserId, WorkOrderIds,EventId);

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
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return StatusMessage;
    }
}