public with sharing class DCX_Utils {
    public DCX_Utils() {

    }

    public DateTime getDateTimeInTimezone(Date givenDate, Time givenTime, String timeZoneSidKey)
    {
        DateTime gmtDateTime = DateTime.newInstanceGmt(givenDate, givenTime);

        String gmtDateTimeStr = gmtDateTime.formatGmt('yyyy-MM-dd HH:mm:ss');
        Double tmzOffsetMins = (DateTime.valueOfGmt(gmtDateTimeStr).getTime() - DateTime.valueOfGmt(gmtDateTime.format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey)).getTime())/60000;
        DateTime retDateTime = gmtDateTime.addMinutes(tmzOffsetMins.intValue());


        // Check if the conversion is correct.
        // If not correct (can happen during DST transition points), adjust the returned date time.
        if(retDateTime != null && retDateTime.format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey) == gmtDateTimeStr)
            return retDateTime;
        else if(retDateTime.addhours(1).format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey) == gmtDateTimeStr)
            return retDateTime.addhours(1);
        else if(retDateTime != null && retDateTime.addhours(-1).format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey) == gmtDateTimeStr)
            return retDateTime.addhours(-1);
        else // Given date time is illegal for the given time zone, e.g. 13/Mar/2011, 2:30 AM, America/Los_Angeles
            return retDateTime;
    }

    public Map<String,String> SVMX_getAllFieldMap( Map<String,Schema.SObjectField> fieldMap)
    {
        Map<String,String> fieldList = new Map<String,String>();
        //build dynamic list of fieldnames
        try
        {
            for (String fieldKey : fieldMap.keySet())
            {
                Schema.SObjectField fsObj = fieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                String fieldName = f.getName();
                if(f.isUpdateable() || f.isCalculated())
                {
                    fieldList.put(fieldName, String.valueof(f.getType()));
                }
            }
        }
        catch (Exception ex) {
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
        return fieldList;
    }

    public Map<String,String> SVMX_getGlobalReferenceMap(){
        Map<String,String> ResultSet = new Map<String,String>();
        try
        {
        ResultSet.put('CASE','CaseNumber');
        ResultSet.put('SOLUTION','SolutionName');
        ResultSet.put('TASK','Subject');
        ResultSet.put('EVENT','Subject');
        ResultSet.put('CONTRACT','ContractNumber');
        ResultSet.put('ACCOUNT','Name');
        ResultSet.put('ORDERITEM','OrderItemNumber');
        ResultSet.put('ORDER','OrderNumber');
        }
        catch (Exception ex){
                throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
            }
        return ResultSet;
    }

    public referenceFields_WP SVMX_getReferenceFields(Map<String,Schema.SObjectField> fieldMap, Boolean selectAllFields){
        referenceFields_WP resultSet;
        List<String> allFields = new List<String>();
        List<String> specialFields = new List<String>();
        List<String> dateTimeFields = new List<String>();
        List<String> dateFields = new List<String>();
        Map<String, String> replacementRef = new Map<String, String>();
        Map<String, String> replacementField = new Map<String, String>();
        Map<String, String> mapObjectNameField = new Map<String, String>();
        Map<String,String> referenceMap = new Map<String,String>();
        referenceMap = SVMX_getGlobalReferenceMap(); //Get global References
        //system.debug('Reference Map: '+referenceMap);
        String rField;
        String rNameField;
        set<String> highPriority = new set<String>();
        set<String> rejection_L = new set<String>();

        //try
        //{
        //Generate rejection list
        String activeProfile;
        List<SVMXC__ServiceMax_Config_Data__c> allSetRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        allSetRecs = [SELECT SVMXC__Internal_Value__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                                                                                                                    AND SVMXC__Setting_Unique_ID__c = 'DCON001_SET006' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                                                                                                                                                                                                                                    AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile'
                                                                                                                                                                                                                                                                                                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global' Limit 1
        ];                 //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Config_Data__c sp: allSetRecs)
        {
            List<String> rejList = sp.SVMXC__Internal_Value__c.split(',');
            for(String s: rejList)
            {
                rejection_L.add(s.toUpperCase());
            }
        }

        if(rejection_L.contains('ACCOUNT') == false)
            highPriority.add('SVMXC__Company__c');
        if(rejection_L.contains('CONTACT') == false)
            highPriority.add('SVMXC__Contact__c');
        if(rejection_L.contains('SVMXC__INSTALLED_PRODUCT__C') == false)
            highPriority.add('SVMXC__Component__c');
        if(rejection_L.contains('SVMXC__SERVICE_GROUP_MEMBERS__C') == false)
            highPriority.add('SVMXC__Group_Member__c');
        if(rejection_L.contains('SVMXC__SERVICE_GROUP__C') == false)
            highPriority.add('SVMXC__Service_Group__c');
        if(rejection_L.contains('SVMXC__TERRITORY__C') == false)
            highPriority.add('SVMXC__Primary_Territory__c');
        if(rejection_L.contains('CASE') == false)
            highPriority.add('SVMXC__Case__c');
        if(rejection_L.contains('USER') == false)
            highPriority.add('OwnerId');
        if(rejection_L.contains('SVMXC__SKILL__C') == false)
            highPriority.add('SVMXC__Skill__c');

        COMM_Utils_ManageSettings commUtils = new COMM_Utils_ManageSettings();
        integer intLookUpLimit = 35;
        Map<String, String> svmxSettingList = new Map<String, String> ();
        svmxSettingList = commUtils.SVMX_getSettingList('IPAD018','SET013');
        if(svmxSettingList.size() > 0)
            intLookUpLimit = integer.valueOf(svmxSettingList.get('SET013'));

        for (String fieldKey : fieldMap.keySet())
        {
            if(highPriority.size() == intLookUpLimit)
                break;
            Schema.SObjectField fsObj = fieldMap.get(fieldKey);
            Schema.DescribeFieldResult field = fsObj.getDescribe();
            if(field.getType() == Schema.DisplayType.Reference && field.getReferenceTo() != null && field.getReferenceTo().size() > 0)
            {
                String strReferenceObjectName = String.valueof(field.getReferenceTo()[0].getDescribe().getName());
                if(rejection_L.contains(strReferenceObjectName.toUpperCase()) == true)
                    continue;
                if(highPriority.size() < intLookUpLimit)
                {
                    highPriority.add(field.getName());
                }
            }
        }

        for (String fieldKey : fieldMap.keySet())
        {
            Schema.SObjectField fsObj = fieldMap.get(fieldKey);
            Schema.DescribeFieldResult field = fsObj.getDescribe();
            if(field.isAccessible())
            { //GM FEB13: To restrict the fields from being accessed is user doesn't have access, LENNOX heap size issue.
                if (selectAllFields == true)
                {
                    if(field.getType() == Schema.DisplayType.Reference && field.getReferenceTo() != null && field.getReferenceTo().size() > 0)
                    {// If field is Reference
                        String strReferenceObjectName = String.valueof(field.getReferenceTo()[0].getDescribe().getName());
                        if(rejection_L.contains(strReferenceObjectName.toUpperCase()) == true)
                            continue;
                        if(referenceMap.get(strReferenceObjectName.toUpperCase())!=NULL)
                        {
                            rField = string.valueof(field.getRelationshipName())+'.'+referenceMap.get(strReferenceObjectName.toUpperCase());
                            rNameField = referenceMap.get(strReferenceObjectName.toUpperCase());
                        }
                        else
                        {
                            rField = field.getRelationshipName()+'.Name';
                            rNameField = 'Name';
                        }
                        if(highPriority.contains(field.getName()) == true)
                        {
                            allFields.add(rField); //eg: SVMXC__Primary_Territory__r.Name
                            specialFields.add(field.getName()); //eg: SVMXC__Primary_Territory__c
                        }
                        replacementRef.put(field.getName(),field.getRelationshipName()); //eg: SVMXC__Primary_Territory__c => SVMXC__Primary_Territory__r
                        replacementField.put(field.getName(),rNameField); //eg: SVMXC__Primary_Territory__c => Name
                        mapObjectNameField.put(strReferenceObjectName, rNameField); //eg: SVMXC__Service_Order__c => Name
                    }
                    else if(field.getType() == Schema.DisplayType.DateTime)
                    {
                        dateTimeFields.add(field.getName());
                    }
                    else if(field.getType() == Schema.DisplayType.Date)
                    {
                        dateFields.add(field.getName());
                    }
                    allFields.add(field.getName());
                }
                else
                {
                    if (field.getName()=='Id' || field.isNameField() || field.isCustom())
                    {
                        if(field.getType() == Schema.DisplayType.Reference && field.getReferenceTo() != null && field.getReferenceTo().size() > 0)
                        {// If field is Reference
                            String strReferenceObjectName = String.valueof(field.getReferenceTo()[0].getDescribe().getName());
                            if(rejection_L.contains(strReferenceObjectName.toUpperCase()) == true)
                                continue;
                            if(referenceMap.get(String.valueof(fsObj).toUpperCase())!=NULL)
                            {
                                rField = string.valueof(field.getRelationshipName())+'.'+referenceMap.get(strReferenceObjectName.toUpperCase());
                                rNameField = referenceMap.get(strReferenceObjectName.toUpperCase());
                            }
                            else
                            {
                                rField = field.getRelationshipName()+'.Name';
                                rNameField = 'Name';
                            }
                            if(highPriority.contains(field.getName()) == true)
                            {
                                allFields.add(rField); //eg: SVMXC__Primary_Territory__r.Name
                                specialFields.add(field.getName()); //eg: SVMXC__Primary_Territory__c
                            }
                            replacementRef.put(field.getName(),field.getRelationshipName()); //eg: SVMXC__Primary_Territory__c => SVMXC__Primary_Territory__r
                            replacementField.put(field.getName(),rNameField); //eg: SVMXC__Primary_Territory__c => Name
                            mapObjectNameField.put(strReferenceObjectName, rNameField); //eg: SVMXC__Service_Order__c => Name
                        }
                        else if(field.getType() == Schema.DisplayType.DateTime)
                        {
                            dateTimeFields.add(field.getName());
                        }
                        else if(field.getType() == Schema.DisplayType.Date)
                        {
                            dateFields.add(field.getName());
                        }
                        allFields.add(field.getName());
                    }
                }
            }
        }
        resultSet = new referenceFields_WP(allFields, specialFields, dateTimeFields, dateFields, replacementRef, replacementField, mapObjectNameField);
        // }
        //catch (Exception ex){
        // throw new SVMXException(ex.getmessage());
        //}
        return resultSet;
    }

    public class referenceFields_WP{
        public List<String> allFields_L {get; set;}
        public List<String> referenceFields_L {get; set;}
        public List<String> dateTimeFields_L {get; set;}
        public List<String> dateFields_L {get; set;}
        public Map<String, String> replacementReference_M {get; set;}
        public Map<String, String> replacementField_M {get; set;}
        public Map<String, String> objectNameField_M {get; set;}
        
        public referenceFields_WP(List<String> allfields, List<String> reffields, List<String> dateTimeFields, List<String> dateFields, Map<String, String> replacementRef, Map<String, String> replacementField, Map<String, String> mapObjectNameField){
            allFields_L = allfields;
            referenceFields_L = reffields;
            dateTimeFields_L = dateTimeFields;
            dateFields_L = dateFields;
            replacementReference_M = replacementRef;
            replacementField_M = replacementField;
            objectNameField_M = mapObjectNameField;
        }
    }

    public  List<Datetime> getBHStartEndDateTime(String timeZone, Date givenDate, BusinessHours bussHour) 
    {
        DateTime eachDateTime = DateTime.newInstanceGmt(givenDate,Time.newInstance(0,0,0,0));
        String strDay = eachDateTime.formatGmt('EEEE');
        
        Map<String, String> dayTimesMap = new Map<String, String>();
        dayTimesMap.put('Monday',bussHour.MondayStartTime +'-'+bussHour.MondayEndTime);
        dayTimesMap.put('Tuesday',bussHour.TuesdayStartTime+'-'+bussHour.TuesdayEndTime);
        dayTimesMap.put('Wednesday',bussHour.WednesdayStartTime+'-'+bussHour.WednesdayEndTime);
        dayTimesMap.put('Thursday',bussHour.ThursdayStartTime+'-'+bussHour.ThursdayEndTime);
        dayTimesMap.put('Friday',bussHour.FridayStartTime+'-'+bussHour.FridayEndTime);
        dayTimesMap.put('Saturday',bussHour.SaturdayStartTime+'-'+bussHour.SaturdayEndTime);
        dayTimesMap.put('Sunday',bussHour.SundayStartTime+'-'+bussHour.SundayEndTime);
                
        String[] startTimeSplit, endTimeSplit;
        String strStartTime, strEndTime;
        DateTime bhStartDateTime, bhEndDateTime;
        List<DateTime> lstOfBhDateTime = new List<DateTime>();
        List<DateTime> lstOfBhDateTime1 = new List<DateTime>();
        
        //form the datetime object using start and end times for that particular day
        if(dayTimesMap != null && dayTimesMap.containsKey(strDay.trim())) 
        {
            startTimeSplit = dayTimesMap.get(strDay.trim()).split('-')[0].split(':');
            if(startTimeSplit != null && startTimeSplit.size() >= 2) 
            {
                strStartTime = startTimeSplit[0] + ':' + startTimeSplit[1];
                bhStartDateTime = DateTime.newInstanceGmt(givenDate, 
                                                        Time.newInstance(Integer.valueOf(startTimeSplit[0]), 
                                                        Integer.valueOf(startTimeSplit[1]), 
                                                        0, 0));
                lstOfBhDateTime.add(bhStartDateTime);
            }
            
            endTimeSplit = dayTimesMap.get(strDay.trim()).split('-')[1].split(':');
            
            if(endTimeSplit != null && endTimeSplit.size() >= 2) 
            {
                strEndTime = endTimeSplit[0] + ':' + endTimeSplit[1];
                //Incase of SP Linx, they are sending 1 minute less for end time but that is not required in our case
                bhEndDateTime = DateTime.newInstanceGmt(givenDate, Time.newInstance(Integer.valueOf(endTimeSplit[0]), 
                                                        Integer.valueOf(endTimeSplit[1]), 
                                                        0, 0));
                lstOfBhDateTime.add(bhEndDateTime);
            }
        }
        
        if(lstOfBhDateTime != null && lstOfBhDateTime.size() > 0)
        {
            if(lstOfBhDateTime.get(0) == lstOfBhDateTime.get(1))
            {
                lstOfBhDateTime[1] = (lstOfBhDateTime.get(1)).addDays(1);   
            }
            lstOfBhDateTime1.add(doTZConversion(lstOfBhDateTime.get(0), bussHour.timeZoneSidKey, timeZone));
            lstOfBhDateTime1.add(doTZConversion(lstOfBhDateTime.get(1), bussHour.timeZoneSidKey, timeZone));
        }   
        System.debug('lstOfBhStartDateTime - ' + lstOfBhDateTime);
        System.debug('lstOfBhEndDateTime - ' + lstOfBhDateTime1);
        return lstOfBhDateTime1;
    }

    public Static DateTime doTZConversion(DateTime resDateTime, String strSourceTimeZone, String strTargetTimeZone) 
    {
        DateTime finalDateTime;
        System.debug('input:'+ resDateTime + strSourceTimeZone + strTargetTimeZone);
        TimeZone sourceTimeZone,targetTimeZone;
        
        if(resDateTime != null && String.isNotBlank(strSourceTimeZone) && String.isNotBlank(strTargetTimeZone))
        {
            sourceTimeZone= TimeZone.getTimeZone(strSourceTimeZone);
            targetTimeZone= TimeZone.getTimeZone(strTargetTimeZone);
            integer diff = targetTimeZone.getOffset(resDateTime) - sourceTimeZone.getOffset(resDateTime);
            finalDateTime = resDateTime.addSeconds(diff/1000);
        }
        
        System.debug('finalDateTime:'+ finalDateTime);
        return finalDateTime;
    }

    public Double getDistanceBetween(Double lat1, Double lon1, Double lat2, Double lon2)
    {
        Double Radius = 6371.00; //Earth Radius in Kilometers default
        Double dLat = toRadians(lat2-lat1);
        Double dLon = toRadians(lon2-lon1);            
        Double a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(toRadians(lat1)) *   Math.cos(toRadians(lat2)) * Math.sin(dLon/2) * Math.sin(dLon/2);
        Double c = 2 * Math.asin(Math.sqrt(a));
        return Radius * c;
    }
    
    public static Double toRadians(Double degree)
    {
        // Value degree * Pi/180
        Double res = degree * 3.1415926 / 180;
        return res; 
    }

    public static Map<String,String> getConfiguredEventUpdateFieldsMap() {
        Map<String,String> flds = new Map<String,String>();
        //COMM_Utils_ManageSettings util = new COMM_Utils_ManageSettings();
system.debug('inside getConfiguredEventUpdateFieldsMap()') ;
        Map<String, String> fldMap = COMM_Utils_ManageSettings.SVMX_getuniqueSettingValueRange('DCON001','SET038','SET047',null);
system.debug('Update Fields: '+fldMap);     
        for(String fld : fldMap.keySet()) {
            List<String> evtField = fld.split('DCON001_', 2);
            flds.put(evtField[1],fldMap.get(fld));
        }
system.debug('Event fields: '+flds);
        return flds;
    }
        
    public static Map<String,String> getConfiguredEventUpdateFieldsMap(String profileId) {
        Map<String,String> flds = new Map<String,String>();
        //COMM_Utils_ManageSettings util = new COMM_Utils_ManageSettings();
system.debug('inside getConfiguredEventUpdateFieldsMap()'+profileId) ;
        Map<String, String> fldMap = COMM_Utils_ManageSettings.SVMX_getuniqueSettingValueRange('DCON001','SET038','SET047',profileId);
system.debug('Update Fields: '+fldMap);     
        for(String fld : fldMap.keySet()) {
            List<String> evtField = fld.split('DCON001_', 2);
            flds.put(evtField[1],fldMap.get(fld));
        }
system.debug('Event fields: '+flds);
        return flds;
    }

    public static void updateWorkOrder(SVMXC__Service_Order__c woRec, List<DCX_Wrapper.SVMX_StringMap> lstKeyValue, 
                                        String timeZone, Map<String,String> settingvalues) {
        system.debug('woRec : '+woRec );
        Map<String, String> mapNewSettings = new Map<String, String>();
        Map<String, String> mapEventSettings = new Map<String, String>();
        Map<String, String> mapWOSettings = new Map<String, String>();  
        Set<String> strWorkOrderFields = new Set<String>();
        String fieldNames = '';
        DCON_Utils dcUtils = new DCON_Utils();
        Map<String, SObjectField> souObjfieldMapWO = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        Map<String,String> WOFieldDef = new Map<String,String>();
        Integer idleDuration, driveDuration, woScope, woVariance,serviceDuration; 
        String woId = woRec.Id;
        String strQuery;
        WOFieldDef = workOrderFieldMap(souObjfieldMapWO);
        if(settingvalues.keySet().size() > 0) {
            for(String strfld : settingvalues.keySet()) {
                if((settingvalues.containsKey(strfld)) && (String.valueOf(settingvalues.get(strfld)).contains('Event.')))
                {
                    List<String> Evtfield = String.valueOf(settingvalues.get(strfld)).split('Event.',2);
                    mapEventSettings.put(strfld,Evtfield[1]);
                } 
                else {
                    mapWOSettings.put(strfld,settingvalues.get(strfld));
                }     
            }
        }
        system.debug('lstKeyValue = '+lstKeyValue);
        for(DCX_Wrapper.SVMX_StringMap oSVMX_StringMap :lstKeyValue) {
            list<string> lststr = new list<string>();
            lststr = oSVMX_StringMap.Key.split('_');
            if(lststr != null && lststr.size() > 1) {
                system.debug('lststr[0].toUpperCase() = '+lststr[0].toUpperCase());
                system.debug('oSVMX_StringMap.Value = '+Integer.valueOf(oSVMX_StringMap.Value));
                if(lststr[0] != null && lststr[0].toUpperCase() == 'IDLE') {
                    idleDuration = Integer.valueOf(oSVMX_StringMap.Value);
                }
                if(lststr[0] != null && lststr[0].toUpperCase() == 'DRIVE') {
                    driveDuration = Integer.valueOf(oSVMX_StringMap.Value);
                    system.debug('In Drive');
                    system.debug('driveDuration = '+driveDuration);
                }
                if(lststr[0] != null && lststr[0].toUpperCase() == 'SERVICE') {
                    serviceDuration = Integer.valueOf(oSVMX_StringMap.Value);
                }
                if(lststr[0] != null && lststr[0].toUpperCase() == 'SCOPE') {
                    woScope = Integer.valueOf(oSVMX_StringMap.Value);
                }
                if(lststr[0] != null && lststr[0].toUpperCase() == 'VARIANCE') {
                    woVariance = Integer.valueOf(oSVMX_StringMap.Value);
                }
            } else {
                if(oSVMX_StringMap.Value.toUpperCase() == 'DATE')
                    mapNewSettings.put(oSVMX_StringMap.Key,string.valueOf(oSVMX_StringMap.DateValue));
                else if(oSVMX_StringMap.Value.toUpperCase() == 'DATETIME')
                    mapNewSettings.put(oSVMX_StringMap.Key,string.valueOf(oSVMX_StringMap.DateTimeValue));
                else
                    mapNewSettings.put(oSVMX_StringMap.Key,oSVMX_StringMap.Value);
            }
        }
        strWorkOrderFields = wodefaultFields();
        strWorkOrderFields.addAll(getFieldUpdates(settingvalues));
        strWorkOrderFields.addAll(woUpdateFields());

        COMM_Utils_V2 objCOMM_UtilV2 = new COMM_Utils_V2();
        strWorkOrderFields = objCOMM_UtilV2.checkDuplicateFields(strWorkOrderFields, 'SVMXC__Service_Order__c');
        
        for (String fieldName : strWorkOrderFields) {
            if(souObjfieldMapWO.containsKey(fieldName.toLowerCase())){
                if (fieldNames.length()>0) {
                    fieldNames += ',';
                }
                if(!fieldName.contains('__r.')) {
                    if(souObjfieldMapWO.get(fieldName).getDescribe().getType() == Schema.DisplayType.Reference) {
                        if(fieldName.equalsIgnoreCase('createdById')) {
                            fieldNames += 'CreatedBy.Name,';
                        } else if(fieldName.equalsIgnoreCase('LastModifiedById')) {
                            fieldNames += 'LastModifiedBy.Name,';
                        } else if(fieldName.equalsIgnoreCase('OwnerId')) {
                            fieldNames += 'Owner.Name,';
                        } else if(fieldName == 'SVMXC__Case__c') {
                        fieldName = 'SVMXC__Case__r.casenumber';
                        } else {
                            fieldName = fieldName.substringBefore('__c')+'__r.Name';
                        }  
                    }
                }
                fieldNames += fieldName;
            }
        }  

        strQuery = 'SELECT ' + fieldNames + ' FROM SVMXC__Service_Order__c Where Id = :woId';

        SVMXC__Service_Order__c schWO = Database.Query(strQuery);
        schWO.SVMXC__Locked_By_DC__c = true;
        if(schWO.SVMXC__FirstScheduledDateTime__c == NULL)
            schWO.SVMXC__FirstScheduledDateTime__c = system.now();
        if(schWO.SVMXC__First_Assigned_DateTime__c == NULL)
            schWO.SVMXC__First_Assigned_DateTime__c = system.now();
        if(woRec.SVMXC__Scheduled_Date_Time__c != null)
            schWO.SVMXC__Scheduled_Date_Time__c = woRec.SVMXC__Scheduled_Date_Time__c;
        if(woRec.SVMXC__Last_Dispatch_Event__c != null)
            schWO.SVMXC__Last_Dispatch_Event__c = woRec.SVMXC__Last_Dispatch_Event__c;
        if(woRec.SVMXC__Group_Member__c != null && woRec.SVMXC__Group_Member__c != schWO.SVMXC__Group_Member__c){
            schWO.SVMXC__Group_Member__c = woRec.SVMXC__Group_Member__c;
            if(schWO.SVMXC__NoOfTimesAssigned__c == null) 
                schWO.SVMXC__NoOfTimesAssigned__c = 1;
            else 
                schWO.SVMXC__NoOfTimesAssigned__c = schWO.SVMXC__NoOfTimesAssigned__c + 1;
        }
        //if(woRec.SVMXC__First_Assigned_DateTime__c != null)
         //   schWO.SVMXC__First_Assigned_DateTime__c = woRec.SVMXC__First_Assigned_DateTime__c;
        
        if(woRec.SVMXC__NoOfTimesAssigned__c != null)
            schWO.SVMXC__NoOfTimesAssigned__c = woRec.SVMXC__NoOfTimesAssigned__c;
        if(woRec.SVMXC__Service_Group__c != null)
            schWO.SVMXC__Service_Group__c = woRec.SVMXC__Service_Group__c;
        if(woRec.SVMXC__Member_Email__c != null)
            schWO.SVMXC__Member_Email__c = woRec.SVMXC__Member_Email__c;
        if(woRec.SVMXC__Group_Email__c != null)
            schWO.SVMXC__Group_Email__c = woRec.SVMXC__Group_Email__c;
        if(woRec.OwnerId != null)
            schWO.OwnerId = woRec.OwnerId;
        if(idleDuration != null) {
            schWO.SVMXC__Scheduled_Date_Time__c = schWO.SVMXC__Scheduled_Date_Time__c.addMinutes(idleDuration);
            schWO.SVMXC__Idle_Time__c = idleDuration;
        }
        if(driveDuration != null) {
            schWO.SVMXC__Scheduled_Date_Time__c = schWO.SVMXC__Scheduled_Date_Time__c.addMinutes(driveDuration);
            schWO.SVMXC__Driving_Time__c = driveDuration;
        }
        if(woVariance != null) {
            schWO.SVMXC__SM_Variance__c = woVariance;
        }
        if(woScope != null) {
            schWO.SVMXC__SM_Scope_Change__c = woScope;
        }
        if(serviceDuration != null) {
        system.debug('SVMXC__Service_Duration__c  :'+serviceDuration);
            schWO.SVMXC__Service_Duration__c = serviceDuration;
        }
        if(mapNewSettings.keySet().size() > 0) {
            for(String strfld : mapNewSettings.keySet()) {
                if(mapWOSettings.containsKey(strfld)) {
                    if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'DATETIME') {
                        schWO.put(mapWOSettings.get(strfld),dcUtils.getDateTimeInTimezone(DateTime.valueof(mapNewSettings.get(strfld)).dateGmt(), DateTime.valueof(mapNewSettings.get(strfld)).timeGmt(), timeZone));
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'DATE') {
                        schWO.put(mapWOSettings.get(strfld),Date.valueOf(mapNewSettings.get(strfld)));
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'BOOLEAN')
                    {
                        schWO.put(mapWOSettings.get(strfld),Boolean.valueOf(mapNewSettings.get(strfld)));
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'CURRENCY')
                    {
                        if(mapNewSettings.get(strfld) !='')
                            schWO.put(mapWOSettings.get(strfld),Double.valueOf(mapNewSettings.get(strfld)));
                        else
                            schWO.put(mapWOSettings.get(strfld),null);
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'INTEGER')
                    {
                        if(mapNewSettings.get(strfld) !='')
                            schWO.put(mapWOSettings.get(strfld),Integer.valueOf(mapNewSettings.get(strfld)));
                        else
                            schWO.put(mapWOSettings.get(strfld),null);
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'PERCENT')
                    {
                        if(mapNewSettings.get(strfld) !='')
                            schWO.put(mapWOSettings.get(strfld),Decimal.valueOf(mapNewSettings.get(strfld)));
                        else
                            schWO.put(mapWOSettings.get(strfld),null);
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'DOUBLE')
                    {
                        if(mapNewSettings.get(strfld) !='')
                            schWO.put(mapWOSettings.get(strfld),Double.valueOf(mapNewSettings.get(strfld)));
                        else
                            schWO.put(mapWOSettings.get(strfld),null);
                    }
                    else
                    {
                        if(mapNewSettings.get(strfld) !='')
                            schWO.put(mapWOSettings.get(strfld),String.valueOf(mapNewSettings.get(strfld)));
                        else
                            schWO.put(mapWOSettings.get(strfld),null);
                    }
                }
            }
        }
        system.debug('schWO :'+schWO);
            COMM_SecurityUtils.getinstance().updateAsUser(schWO);
    }

    public static Map<Id,SVMXC__Service_Order__c> updateAndReturnWorkOrder(SVMXC__Service_Order__c woRec, List<DCX_Wrapper.SVMX_StringMap> lstKeyValue, 
                                                                            String timeZone,Map<String,String> settingvalues,List<String> woFields) {
        Map<Id,SVMXC__Service_Order__c> workOrderMap = new Map<Id,SVMXC__Service_Order__c>();
        string FieldMapRTypeId,RuleRecordTypeId,strQuery;
        String fieldNames = '';
        String lookUpFieldName = null;
        Map<Id, SVMXC__ServiceMax_Processes__c> mapEventHoverRules  = 
            new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Set<String> strWorkOrderFields = new Set<String>();
        Map<String, String> mapNewSettings = new Map<String, String>();
        Map<String, String> mapEventSettings = new Map<String, String>();
        Map<String, String> mapWOSettings = new Map<String, String>();  
        DCON_Utils dcUtils = new DCON_Utils();
        Map<String, SObjectField> souObjfieldMapWO = 
            Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        Map<String,String> WOFieldDef = new Map<String,String>();
        DCX_CommonServiceManager.UserSetting uSet = DCX_SettingServiceManager.fetchUserSettings();                                                                        
        Integer idleDuration, driveDuration, woScope, woVariance,serviceDuration; 
        WOFieldDef = workOrderFieldMap(souObjfieldMapWO);
        String woId = woRec.Id;
        if(settingvalues.keySet().size() > 0) {
            for(String strfld : settingvalues.keySet()) {
                if((settingvalues.containsKey(strfld)) && (String.valueOf(settingvalues.get(strfld)).contains('Event.')))
                {
                    List<String> Evtfield = String.valueOf(settingvalues.get(strfld)).split('Event.',2);
                    mapEventSettings.put(strfld,Evtfield[1]);
                } 
                else {
                    mapWOSettings.put(strfld,settingvalues.get(strfld));
                }     
            }
        }
        system.debug('lstKeyValue = '+lstKeyValue);
        for(DCX_Wrapper.SVMX_StringMap oSVMX_StringMap :lstKeyValue) {
            list<string> lststr = new list<string>();
            lststr = oSVMX_StringMap.Key.split('_');
            if(lststr != null && lststr.size() > 1) {
                system.debug('lststr[0].toUpperCase() = '+lststr[0].toUpperCase());
                system.debug('oSVMX_StringMap.Value = '+Integer.valueOf(oSVMX_StringMap.Value));
                if(lststr[0] != null && lststr[0].toUpperCase() == 'IDLE') {
                    idleDuration = Integer.valueOf(oSVMX_StringMap.Value);
                }
                if(lststr[0] != null && lststr[0].toUpperCase() == 'DRIVE') {
                    driveDuration = Integer.valueOf(oSVMX_StringMap.Value);
                }
                if(lststr[0] != null && lststr[0].toUpperCase() == 'SERVICE') {
                    serviceDuration = Integer.valueOf(oSVMX_StringMap.Value);
                }
                if(lststr[0] != null && lststr[0].toUpperCase() == 'SCOPE') {
                    woScope = Integer.valueOf(oSVMX_StringMap.Value);
                }
                if(lststr[0] != null && lststr[0].toUpperCase() == 'VARIANCE') {
                    woVariance = Integer.valueOf(oSVMX_StringMap.Value);
                }
            } else {
                if(oSVMX_StringMap.Value.toUpperCase() == 'DATE')
                    mapNewSettings.put(oSVMX_StringMap.Key,string.valueOf(oSVMX_StringMap.DateValue));
                else if(oSVMX_StringMap.Value.toUpperCase() == 'DATETIME')
                    mapNewSettings.put(oSVMX_StringMap.Key,string.valueOf(oSVMX_StringMap.DateTimeValue));
                else
                    mapNewSettings.put(oSVMX_StringMap.Key,oSVMX_StringMap.Value);
            }
        }

        strWorkOrderFields = wodefaultFields();
        strWorkOrderFields.addAll(getFieldUpdates(settingvalues));
        strWorkOrderFields.addAll(woUpdateFields());

        for(RecordType recType : [Select SobjectType, Id, Name From RecordType where 
                                  (SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SVMX Rule') OR
                                  (SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name IN 
                                  ('Expressions', 'Field Mapping'))]) {
            if(recType.Name == 'SVMX Rule')
                RuleRecordTypeId = recType.id;
            if(recType.Name == 'Field Mapping')
                FieldMapRTypeId = recType.id;
        }

        for(SVMXC__ServiceMax_Processes__c oPro : [Select SVMXC__Sequence__c,SVMXC__Advance_Expression__c, 
                                                   Id From SVMXC__ServiceMax_Processes__c  where 
                                                   RecordTypeId =:RuleRecordTypeId and 
                                                   SVMXC__Rule_Type__c = 'Event Hover Rule']) {
            mapEventHoverRules.put(oPro.Id, oPro);
        }
        for(SVMXC__ServiceMax_Config_Data__c objEventHoverField: [Select Id, SVMXC__Target_Field_Name__c,
                                                                  SVMXC__Sequence__c, 
                                                                  SVMXC__Expression_Rule__c From 
                                                                  SVMXC__ServiceMax_Config_Data__c where
                                                                  RecordTypeId = :FieldMapRTypeId and 
                                                                  SVMXC__Expression_Rule__c 
                                                                  IN :mapEventHoverRules.keyset() 
                                                                  order by SVMXC__Sequence__c DESC]) {
            strWorkOrderFields.add(objEventHoverField.SVMXC__Target_Field_Name__c);
        }
        
        for(String colorField : uSet.wo_sch_col_fields) {
           strWorkOrderFields.add(colorField); 
        }                                                                 

        COMM_Utils_V2 objCOMM_UtilV2 = new COMM_Utils_V2();
        strWorkOrderFields = objCOMM_UtilV2.checkDuplicateFields(strWorkOrderFields, 'SVMXC__Service_Order__c');
        
        for (String fieldName : strWorkOrderFields) {
            if(souObjfieldMapWO.containsKey(fieldName.toLowerCase())){
                if (fieldNames.length()>0) {
                    fieldNames += ',';
                }
                if(!fieldName.contains('__r.')) {
                    if(souObjfieldMapWO.get(fieldName).getDescribe().getType() == Schema.DisplayType.Reference) {
                        if(fieldName.equalsIgnoreCase('createdById')) {
                            fieldNames += 'CreatedBy.Name,';
                        } else if(fieldName.equalsIgnoreCase('LastModifiedById')) {
                            fieldNames += 'LastModifiedBy.Name,';
                        } else if(fieldName.equalsIgnoreCase('OwnerId')) {
                            fieldNames += 'Owner.Name,';
                        } else if(fieldName == 'SVMXC__Case__c') {
                        fieldName = 'SVMXC__Case__r.casenumber';
                        } 
                        else if(fieldName.equalsIgnoreCase('RecordTypeId'))
                           fieldName = 'RecordType.Name';// (String)workOrderObj.getSobject('RecordType').get('Name');
                        else {
                            fieldName = fieldName.substringBefore('__c')+'__r.Name';
                        }  
                    }
                }
                fieldNames += fieldName;
            }
        }  
        
        strQuery = 'SELECT ' + fieldNames + ' FROM SVMXC__Service_Order__c Where Id = :woId';
        system.debug('strQuery = '+strQuery);
        SVMXC__Service_Order__c schWO = Database.Query(strQuery);
        schWO.SVMXC__Locked_By_DC__c = true;
        if(woRec.SVMXC__Scheduled_Date_Time__c != null)
            schWO.SVMXC__Scheduled_Date_Time__c = woRec.SVMXC__Scheduled_Date_Time__c;
        if(woRec.SVMXC__Last_Dispatch_Event__c != null)
            schWO.SVMXC__Last_Dispatch_Event__c = woRec.SVMXC__Last_Dispatch_Event__c;
        if(woRec.SVMXC__Group_Member__c != null && woRec.SVMXC__Group_Member__c != schWO.SVMXC__Group_Member__c){
            schWO.SVMXC__Group_Member__c = woRec.SVMXC__Group_Member__c;
            if(schWO.SVMXC__NoOfTimesAssigned__c == null) 
                schWO.SVMXC__NoOfTimesAssigned__c = 1;
            else 
                schWO.SVMXC__NoOfTimesAssigned__c = schWO.SVMXC__NoOfTimesAssigned__c + 1;
        }
        if(schWO.SVMXC__FirstScheduledDateTime__c == NULL)
            schWO.SVMXC__FirstScheduledDateTime__c = system.now();
        if(schWO.SVMXC__First_Assigned_DateTime__c == null)
            schWO.SVMXC__First_Assigned_DateTime__c = system.now();
        if(woRec.SVMXC__Service_Group__c != null)
            schWO.SVMXC__Service_Group__c = woRec.SVMXC__Service_Group__c;
        if(woRec.SVMXC__Member_Email__c != null)
            schWO.SVMXC__Member_Email__c = woRec.SVMXC__Member_Email__c;
        if(woRec.SVMXC__Group_Email__c != null)
            schWO.SVMXC__Group_Email__c = woRec.SVMXC__Group_Email__c;
        if(woRec.OwnerId != null)
            schWO.OwnerId = woRec.OwnerId;
        if(idleDuration != null) {
            schWO.SVMXC__Scheduled_Date_Time__c = schWO.SVMXC__Scheduled_Date_Time__c.addMinutes(idleDuration);
            schWO.SVMXC__Idle_Time__c = idleDuration;
        }
        if(driveDuration != null) {
            schWO.SVMXC__Scheduled_Date_Time__c = schWO.SVMXC__Scheduled_Date_Time__c.addMinutes(driveDuration);
            schWO.SVMXC__Driving_Time__c = driveDuration;
        }
        if(woVariance != null) {
            schWO.SVMXC__SM_Variance__c = woVariance;
        }
        if(woScope != null) {
            schWO.SVMXC__SM_Scope_Change__c = woScope;
        }
        if(serviceDuration != null) {
            schWO.SVMXC__Service_Duration__c = serviceDuration;
        }
        if(mapNewSettings.keySet().size() > 0) {
            for(String strfld : mapNewSettings.keySet()) {
                if(mapWOSettings.containsKey(strfld)) {
                    if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'DATETIME') {
                        schWO.put(mapWOSettings.get(strfld),dcUtils.getDateTimeInTimezone(DateTime.valueof(mapNewSettings.get(strfld)).dateGmt(), DateTime.valueof(mapNewSettings.get(strfld)).timeGmt(), timeZone));
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'DATE') {
                        schWO.put(mapWOSettings.get(strfld),Date.valueOf(mapNewSettings.get(strfld)));
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'BOOLEAN')
                    {
                        schWO.put(mapWOSettings.get(strfld),Boolean.valueOf(mapNewSettings.get(strfld)));
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'CURRENCY')
                    {
                        if(mapNewSettings.get(strfld) !='')
                            schWO.put(mapWOSettings.get(strfld),Double.valueOf(mapNewSettings.get(strfld)));
                        else
                            schWO.put(mapWOSettings.get(strfld),null);
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'INTEGER')
                    {
                        if(mapNewSettings.get(strfld) !='')
                            schWO.put(mapWOSettings.get(strfld),Integer.valueOf(mapNewSettings.get(strfld)));
                        else
                            schWO.put(mapWOSettings.get(strfld),null);
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'PERCENT')
                    {
                        if(mapNewSettings.get(strfld) !='')
                            schWO.put(mapWOSettings.get(strfld),Decimal.valueOf(mapNewSettings.get(strfld)));
                        else
                            schWO.put(mapWOSettings.get(strfld),null);
                    }
                    else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'DOUBLE')
                    {
                        if(mapNewSettings.get(strfld) !='')
                            schWO.put(mapWOSettings.get(strfld),Double.valueOf(mapNewSettings.get(strfld)));
                        else
                            schWO.put(mapWOSettings.get(strfld),null);
                    }
                    else
                    {
                        if(mapNewSettings.get(strfld) !='')
                            schWO.put(mapWOSettings.get(strfld),String.valueOf(mapNewSettings.get(strfld)));
                        else
                            schWO.put(mapWOSettings.get(strfld),null);
                    }
                }
            }
        }
        COMM_SecurityUtils.getinstance().updateAsUser(schWO);
        workOrderMap.put(schWO.Id,Database.Query(strQuery));
        return workOrderMap;
    }

    public static Map<String,String> workOrderFieldMap( Map<String,Schema.SObjectField> fieldMap)
    {
        Map<String,String> fieldList = new Map<String,String>();
        //build dynamic list of fieldnames
        try
        {
            for (String fieldKey : fieldMap.keySet())
            {
                Schema.SObjectField fsObj = fieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                String fieldName = f.getName();
                if(f.isUpdateable() || f.isCalculated())
                {
                    fieldList.put(fieldName, String.valueof(f.getType()));
                }
            }
        }
        catch (Exception ex) {
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
        return fieldList;
    }

    public static List<String> getConfiguredEventFields() {
        List<String> flds = new List<String>();
        //COMM_Utils_ManageSettings util = new COMM_Utils_ManageSettings();
        Map<String, String> fldMap = COMM_Utils_ManageSettings.SVMX_getuniqueSettingValueRange('DCON001','SET038','SET047',null);
        
        for(String fld : fldMap.values()) {
            if(fld.contains('Event.')) {
                List<String> evtField = fld.split('Event.', 2);
                flds.add(evtField[1]);
            }
        }
        return flds;
    }

    public static Set<String> wodefaultFields() {
        Set<String> strWorkOrderFields = new Set<String>();
        //add following default work order fileds
        strWorkOrderFields.add('SVMXC__Dispatch_Status__c');
        strWorkOrderFields.add('SVMXC__Group_Member__c');
        strWorkOrderFields.add('SVMXC__Service_Group__c');
        strWorkOrderFields.add('SVMXC__Service_Duration__c');
        strWorkOrderFields.add('SVMXC__Driving_Time__c');
        strWorkOrderFields.add('SVMXC__Preferred_Start_Time__c');
        strWorkOrderFields.add('SVMXC__Product__c');
        strWorkOrderFields.add('SVMXC__Idle_Time__c');
        strWorkOrderFields.add('SVMXC__Preferred_Business_Hours__c');
        strWorkOrderFields.add('SVMXC__SM_Estimated_Duration__c');
        strWorkOrderFields.add('SVMXC__SM_Scope_Change__c');
        strWorkOrderFields.add('SVMXC__SM_Variance__c');
        strWorkOrderFields.add('SVMXC__SM_Revised_Duration__c');
        strWorkOrderFields.add('SVMXC__SM_Scheduled_Duration__c');
        strWorkOrderFields.add('SVMXC__SM_Unscheduled_Duration__c');
        strWorkOrderFields.add('OwnerId');
        
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

    public static Set<String> woUpdateFields() {
        Set<String> strWorkOrderFields = new Set<String>();
        strWorkOrderFields.add('Id');
        strWorkOrderFields.add('SVMXC__Last_Dispatch_Event__c');
        strWorkOrderFields.add('SVMXC__Service_Duration__c');
        strWorkOrderFields.add('SVMXC__FirstScheduledDateTime__c');
        strWorkOrderFields.add('SVMXC__NoOfTimesScheduled__c');
        strWorkOrderFields.add('SVMXC__Group_Member__c');
        strWorkOrderFields.add('SVMXC__Group_Member__r.SVMXC__Salesforce_User__c');
        strWorkOrderFields.add('SVMXC__Idle_Time__c');
        strWorkOrderFields.add('SVMXC__Driving_Time__c');
        strWorkOrderFields.add('SVMXC__SM_Scope_Change__c');
        strWorkOrderFields.add('SVMXC__Locked_By_DC__c');
        strWorkOrderFields.add('SVMXC__Service_Group__c');
        strWorkOrderFields.add('OwnerId');
        strWorkOrderFields.add('SVMXC__First_Assigned_DateTime__c');
        strWorkOrderFields.add('SVMXC__NoOfTimesAssigned__c');
        strWorkOrderFields.add('Id');
        strWorkOrderFields.add('Name');
        strWorkOrderFields.add('SVMXC__Latitude__c');
        strWorkOrderFields.add('SVMXC__Longitude__c');
        
        return strWorkOrderFields;
    }

    public static set<string> getFieldUpdates()
    {
        set<string> setWorkOrderFields = new set<string>();
        Map<String, String> svmxSettingList = new Map<String, String>();
        List<String> settingIds = new List<String>{'DCON001_SET038','DCON001_SET039','DCON001_SET040',
                                                   'DCON001_SET041','DCON001_SET042','DCON001_SET043',
                                                   'DCON001_SET044','DCON001_SET045','DCON001_SET046',
                                                   'DCON001_SET047'};
         svmxSettingList = COMM_Utils_ManageSettings.SVMX_getSettingValueForList(settingIds);

        //Load Dispatch Console Fields - We have to get all WO fields by skipping Event fields
            Map<String,String> mapValidSettingsForUpdate = new Map<String,String>();
            if(svmxSettingList.get('DCON001_SET038') != null && 
               !svmxSettingList.get('DCON001_SET038').contains('Event')) 
                mapValidSettingsForUpdate.put('SET038', svmxSettingList.get('DCON001_SET038'));
            if(svmxSettingList.get('DCON001_SET039') != null)
                mapValidSettingsForUpdate.put('SET039', svmxSettingList.get('DCON001_SET039'));
            if(svmxSettingList.get('DCON001_SET040') != null)
                mapValidSettingsForUpdate.put('SET040', svmxSettingList.get('DCON001_SET040'));
            if(svmxSettingList.get('DCON001_SET041') != null)
                mapValidSettingsForUpdate.put('SET041', svmxSettingList.get('DCON001_SET041'));
            if(svmxSettingList.get('DCON001_SET042') != null)
                mapValidSettingsForUpdate.put('SET042', svmxSettingList.get('DCON001_SET042'));
            if(svmxSettingList.get('DCON001_SET043') != null)
                mapValidSettingsForUpdate.put('SET043', svmxSettingList.get('DCON001_SET043'));
            if(svmxSettingList.get('DCON001_SET044') != null)
                mapValidSettingsForUpdate.put('SET044', svmxSettingList.get('DCON001_SET044'));
            if(svmxSettingList.get('DCON001_SET045') != null)
                mapValidSettingsForUpdate.put('SET045', svmxSettingList.get('DCON001_SET045'));
            if(svmxSettingList.get('DCON001_SET046') != null)
                mapValidSettingsForUpdate.put('SET046', svmxSettingList.get('DCON001_SET046'));
            if(svmxSettingList.get('DCON001_SET047') != null)
                mapValidSettingsForUpdate.put('SET047', svmxSettingList.get('DCON001_SET047'));

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
    
    public static set<string> getFieldUpdates(Map<String,String> svmxSettingList)
    {
        set<string> setWorkOrderFields = new set<string>();
        //Load Dispatch Console Fields - We have to get all WO fields by skipping Event fields
            
            System.debug('mapValidSettingsForUpdate contents are:' + svmxSettingList);
            if(svmxSettingList.keySet().size() > 0)
            {
                for(String strfld : svmxSettingList.keySet())
                {
                    if(!String.valueOf(svmxSettingList.get(strfld)).contains('Event'))
                    {
                        setWorkOrderFields.add(svmxSettingList.get(strfld));    
                    }
                }
            }
             return setWorkOrderFields;
    }
    public  list<Date> GetHolidays(BusinessHours bh, Date startdate, Date enddate)
    {
        //DCON_Utils dcUtils = new DCON_Utils();
        DCX_Utils dcUtils = new DCX_Utils();
        List<date> lstHolidays = new List<date>();
        List<Date> lstDate = new List<Date>();
        for(Date dt = startDate; dt <= endDate; dt = dt.addDays(1)) 
        {            
            lstDate.add(dt);
        }
        for(Date objlstDate : lstDate)
        {
            Datetime dtmDayStartDateTime = dcUtils.getDateTimeInTimezone(objlstDate, Time.newInstance(0, 0, 0, 0), bh.timeZoneSidKey);
                  
            // Get the next working date time with respect to the given day's start
            Datetime dtmNextWkgDateTime = BusinessHours.addGmt(bh.id, dtmDayStartDateTime, 1L);
                
            // Get the date of the next working date time in the given time zone
            Date datNextWkgDate = Date.valueOf(dtmNextWkgDateTime.format('yyyy-MM-dd', bh.timeZoneSidKey));
              
            // If the given date and next working date are the same, the given day is a working day else given day is Holiday
            if(datNextWkgDate != objlstDate)
                lstHolidays.add(objlstDate);    
        }
        System.debug('list of Holidays:' + lstHolidays);
        System.debug('Heap size1: ' + Limits.getHeapSize());
        
        Set<String> lstdays = new Set<String>();
        List<Date> lstHolidays1 = new List<date>();
        if(bh.SundayStartTime != null && bh.SundayEndTime != null)
        {
            lstdays.add('SUNDAY');
        }
        if(bh.MondayStartTime != null && bh.MondayEndTime != null)
        {
            lstdays.add('MONDAY');
        }
        if(bh.TuesdayStartTime != null && bh.TuesdayEndTime != null)
        {
            lstdays.add('TUESDAY');
        }
        if(bh.WednesdayStartTime != null && bh.WednesdayEndTime != null)
        {
            lstdays.add('WEDNESDAY');
        }
        if(bh.ThursdayStartTime != null && bh.ThursdayEndTime != null)
        {
            lstdays.add('THURSDAY');
        }
        if(bh.FridayStartTime != null && bh.FridayEndTime != null)
        {
            lstdays.add('FRIDAY');
        }
        if(bh.SaturdayStartTime != null && bh.SaturdayEndTime != null)
        {
            lstdays.add('SATURDAY');
        }
        System.debug('List of business hrs days:' + lstdays);
        
        for(Date objdate : lstholidays)
        {
            DateTime tempdate = DateTime.newInstanceGmt(objdate,Time.newInstance(0,0,0,0));
            If(lstdays.contains((tempdate.formatGmt('EEEE')).toUpperCase()))
            {
                lstHolidays1.add(objdate);  
            }
        }
        System.debug('List of non working hrs and holidays:' + lstHolidays1);
        System.debug('Heap sizex: ' + Limits.getHeapSize());
        return lstHolidays1;
        
    }

    public Boolean GetHolidays(BusinessHours bh, Date givendate)
    {
        Boolean isHoliday = false;
        if(givendate != null && bh != null)
        {
            Datetime dtmDayStartDateTime = getDateTimeInTimezone(givendate, Time.newInstance(0, 0, 0, 0), bh.timeZoneSidKey);
                  
            // Get the next working date time with respect to the given day's start
            Datetime dtmNextWkgDateTime = BusinessHours.addGmt(bh.id, dtmDayStartDateTime, 1L);
                
            // Get the date of the next working date time in the given time zone
            Date datNextWkgDate = Date.valueOf(dtmNextWkgDateTime.format('yyyy-MM-dd', bh.timeZoneSidKey));
              
            // If the given date and next working date are the same, the given day is a working day else given day is Holiday
            if(datNextWkgDate != givendate)
                isHoliday = true;
        }
        return isHoliday;
    }
    public String SVMX_getFieldNamesFromList(List<String> fieldList) {
        String fieldNames = '';
        for (String field : fieldList) {
            if (fieldNames.length()>0) {
                fieldNames += ',';
            }
            fieldNames += field;
        }        
        return fieldNames;
    } 

    public Map<String,Boolean> SVMX_getPermittedStandardObjectList(){
        Map<String,Boolean> retMap = new Map<String,Boolean>();
        List<SVMXC__ServiceMax_Properties__c> sprop = new List<SVMXC__ServiceMax_Properties__c>();
        sprop = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where SVMXC__Key__c = 'License Type' and Name = 'PROP001' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if (sprop != null && sprop.size() >0) {
            String licenseType = sprop[0].SVMXC__Value__c;
            system.debug('licenseType'+licenseType);
            List<SVMXC__ServiceMax_Property_Elements__c> spropLst = new List<SVMXC__ServiceMax_Property_Elements__c>();
            spropLst = [Select Name, SVMXC__Element_Type__c, SVMXC__Element_Value__c from SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c =:licenseType ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('spropLst'+spropLst);
            if(spropLst != null && spropLst.size() >0) {
                for(SVMXC__ServiceMax_Property_Elements__c sp: spropLst){
                    String objName = String.valueOf(sp.SVMXC__Element_Value__c);
                    system.debug('objName'+objName);
                    retMap.put(objName, true);      
                }
    
            }
        }
        return retMap;
      }

      public List<String> SVMX_getFieldList( Map<String,Schema.SObjectField> fieldMap, Boolean selectAllFields)
      {
          List<String> fieldList = new List<String>();        
          //build dynamic list of fieldnames
          for (String fieldKey : fieldMap.keySet()) 
              {
              Schema.SObjectField fsObj = fieldMap.get(fieldKey);
              Schema.DescribeFieldResult f = fsObj.getDescribe();
              String fieldName = f.getName();            
              if (selectAllFields == true) 
                  {
                      fieldList.add(fieldName);
                      //System.debug('Adding '+fieldName);
                  } 
              else {
                  if (f.getName()=='Id' || f.isNameField() || f.isCustom()) {
                      fieldList.add(fieldName);
                      //System.debug('Adding :else: '+fieldName);
                  }
              }
          }        
          return fieldList;
     }

     public static string ExpertisevalidationClause(String WhereClause)
    {
        return '(' + WhereClause + ') and ' + '((SVMXC__Availability_Start_Date__c != null and SVMXC__Availability_End_Date__c != null and SVMXC__Availability_Start_Date__c <=: dtToday and SVMXC__Availability_End_Date__c >=: dtToday ) OR (SVMXC__Availability_Start_Date__c = null and SVMXC__Availability_End_Date__c >=: dtToday ) OR (SVMXC__Availability_Start_Date__c <=: dtToday and SVMXC__Availability_End_Date__c = null) OR (SVMXC__Availability_Start_Date__c = null and SVMXC__Availability_End_Date__c = null))';

    }

    public String SVMX_get_ListOfValues( List<String> Values)
    {
        String ResultSet='';   
        try
        {     
        //build dynamic list of fieldnames
        for (String val : Values){
            if(ResultSet=='')
            ResultSet='(\'';
            else
            ResultSet +='\',\'';
            ResultSet +=val;
        }
        ResultSet +='\')';
        }
        catch (Exception ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
            }
        return ResultSet;
    }
    
    public DCON_referenceFields_WP DCON_getReferenceFields(Map<String,Schema.SObjectField> fieldMap, Boolean selectAllFields){
        system.debug('Method : SVMX_getReferenceFields');
        Long start = DateTime.Now().getTime();
        DCON_referenceFields_WP resultSet;
        List<String> allFields = new List<String>();
        List<String> specialFields = new List<String>();
        List<String> dateTimeFields = new List<String>();
        List<String> dateFields = new List<String>();
        List<String> pick_list = new List<String>();
        Map<String, String> replacementRef = new Map<String, String>();
        Map<String, String> replacementField = new Map<String, String>();
        Map<String, String> mapObjectNameField = new Map<String, String>();
        Map<String,String> referenceMap = new Map<String,String>();
        referenceMap = SVMX_getGlobalReferenceMap(); //Get global References
        //system.debug('Reference Map: '+referenceMap);

        String rField;
        String rNameField;
        set<String> highPriority = new set<String>();
        set<String> rejection_L = new set<String>();

        //try
        //{
        //Generate rejection list
        String activeProfile;
        List<SVMXC__ServiceMax_Config_Data__c> allSetRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        allSetRecs = [SELECT SVMXC__Internal_Value__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value' 
                        AND SVMXC__Setting_Unique_ID__c = 'DCON001_SET006' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                        AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile'  
                        AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global' Limit 1
                        ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Config_Data__c sp: allSetRecs)
        {
            List<String> rejList = sp.SVMXC__Internal_Value__c.split(',');
            for(String s: rejList)
            {
                rejection_L.add(s.toUpperCase());
            }
        }
        
        if(rejection_L.contains('ACCOUNT') == false)
            highPriority.add('SVMXC__Company__c');
        if(rejection_L.contains('CONTACT') == false)
            highPriority.add('SVMXC__Contact__c');
        if(rejection_L.contains('SVMXC__INSTALLED_PRODUCT__C') == false)
            highPriority.add('SVMXC__Component__c');
        if(rejection_L.contains('SVMXC__SERVICE_GROUP_MEMBERS__C') == false)
            highPriority.add('SVMXC__Group_Member__c');
        if(rejection_L.contains('SVMXC__SERVICE_GROUP__C') == false)
            highPriority.add('SVMXC__Service_Group__c');
        if(rejection_L.contains('SVMXC__TERRITORY__C') == false)
            highPriority.add('SVMXC__Primary_Territory__c');
        if(rejection_L.contains('CASE') == false)
            highPriority.add('SVMXC__Case__c');
        if(rejection_L.contains('USER') == false)
            highPriority.add('OwnerId');
        if(rejection_L.contains('SVMXC__SKILL__C') == false)
            highPriority.add('SVMXC__Skill__c');

            COMM_Utils_ManageSettings commUtils = new COMM_Utils_ManageSettings();
        integer intLookUpLimit = 35;
        Map<String, String> svmxSettingList = new Map<String, String> ();
        svmxSettingList = commUtils.SVMX_getSettingList('IPAD018','SET013');
        if(svmxSettingList.size() > 0)
            intLookUpLimit = integer.valueOf(svmxSettingList.get('SET013'));
        
        for (String fieldKey : fieldMap.keySet())
        {
            if(highPriority.size() == intLookUpLimit)
                break;
            Schema.SObjectField fsObj = fieldMap.get(fieldKey);
            Schema.DescribeFieldResult field = fsObj.getDescribe(); 
            if(field.getType() == Schema.DisplayType.Reference && field.getReferenceTo() != null && field.getReferenceTo().size() > 0)
            {
                String strReferenceObjectName = String.valueof(field.getReferenceTo()[0].getDescribe().getName());
                if(rejection_L.contains(strReferenceObjectName.toUpperCase()) == true)
                    continue;
                if(highPriority.size() < intLookUpLimit)
                {
                    highPriority.add(field.getName());
                }       
            }
        }

        for (String fieldKey : fieldMap.keySet())
        {
            Schema.SObjectField fsObj = fieldMap.get(fieldKey); 
            Schema.DescribeFieldResult field = fsObj.getDescribe();
            if(field.isAccessible())
            { //GM FEB13: To restrict the fields from being accessed is user doesn't have access, LENNOX heap size issue.
                if (selectAllFields == true)
                {
                    if(field.getType() == Schema.DisplayType.Reference && field.getReferenceTo() != null && field.getReferenceTo().size() > 0)
                    {// If field is Reference
                        String strReferenceObjectName = String.valueof(field.getReferenceTo()[0].getDescribe().getName());
                        if(rejection_L.contains(strReferenceObjectName.toUpperCase()) == true)
                            continue;
                        if(referenceMap.get(strReferenceObjectName.toUpperCase())!=NULL)
                        {
                            rField = string.valueof(field.getRelationshipName())+'.'+referenceMap.get(strReferenceObjectName.toUpperCase());
                            rNameField = referenceMap.get(strReferenceObjectName.toUpperCase());
                        }
                        else
                        {
                            rField = field.getRelationshipName()+'.Name';
                            rNameField = 'Name';
                        }
                        if(highPriority.contains(field.getName()) == true)
                        {
                            allFields.add(rField); //eg: SVMXC__Primary_Territory__r.Name
                            specialFields.add(field.getName()); //eg: SVMXC__Primary_Territory__c
                        }
                        replacementRef.put(field.getName(),field.getRelationshipName()); //eg: SVMXC__Primary_Territory__c => SVMXC__Primary_Territory__r
                        replacementField.put(field.getName(),rNameField); //eg: SVMXC__Primary_Territory__c => Name
                        mapObjectNameField.put(strReferenceObjectName, rNameField); //eg: SVMXC__Service_Order__c => Name
                    }
                    else if(field.getType() == Schema.DisplayType.DateTime)
                    {
                        dateTimeFields.add(field.getName());
                    }
                    else if(field.getType() == Schema.DisplayType.Date)
                    {
                        dateFields.add(field.getName());
                    }
                     else if(field.getType() == Schema.DisplayType.PickList)
                    {
                      pick_list.add(field.getName());
                    }
                    allFields.add(field.getName());
                }
                else
                {
                    if (field.getName()=='Id' || field.isNameField() || field.isCustom())
                    {
                        if(field.getType() == Schema.DisplayType.Reference && field.getReferenceTo() != null && field.getReferenceTo().size() > 0)
                        {// If field is Reference
                            String strReferenceObjectName = String.valueof(field.getReferenceTo()[0].getDescribe().getName());
                            if(rejection_L.contains(strReferenceObjectName.toUpperCase()) == true)
                                continue;
                            if(referenceMap.get(String.valueof(fsObj).toUpperCase())!=NULL)
                            {
                                rField = string.valueof(field.getRelationshipName())+'.'+referenceMap.get(strReferenceObjectName.toUpperCase());
                                rNameField = referenceMap.get(strReferenceObjectName.toUpperCase());
                            }
                            else
                            {
                                rField = field.getRelationshipName()+'.Name';
                                rNameField = 'Name';
                            }
                            if(highPriority.contains(field.getName()) == true)
                            {
                                allFields.add(rField); //eg: SVMXC__Primary_Territory__r.Name
                                specialFields.add(field.getName()); //eg: SVMXC__Primary_Territory__c
                            }
                            replacementRef.put(field.getName(),field.getRelationshipName()); //eg: SVMXC__Primary_Territory__c => SVMXC__Primary_Territory__r
                            replacementField.put(field.getName(),rNameField); //eg: SVMXC__Primary_Territory__c => Name
                            mapObjectNameField.put(strReferenceObjectName, rNameField); //eg: SVMXC__Service_Order__c => Name
                        }
                        else if(field.getType() == Schema.DisplayType.DateTime)
                        {
                            dateTimeFields.add(field.getName());
                        }
                        else if(field.getType() == Schema.DisplayType.Date)
                        {
                            dateFields.add(field.getName());
                        }
                        allFields.add(field.getName());
                    }
                }
            }
        }
        resultSet = new DCON_referenceFields_WP(allFields, specialFields, dateTimeFields, dateFields, replacementRef, replacementField, mapObjectNameField,pick_list);
       // }
        //catch (Exception ex){
               // throw new SVMXException(ex.getmessage());
            //}
        Long Stop = DateTime.Now().getTime();
        system.debug('Time taken for SVMX_getReferenceFields : '+(stop-start));
        return resultSet;
    }
    
     public class DCON_referenceFields_WP{
        public List<String> allFields_L {get; set;}
        public List<String> referenceFields_L {get; set;}
        public List<String> dateTimeFields_L {get; set;}
        public List<String> dateFields_L {get; set;}
        public Map<String, String> replacementReference_M {get; set;}
        public Map<String, String> replacementField_M {get; set;}
        public Map<String, String> objectNameField_M {get; set;}
        public List<String> pickList_L{get;set;}
        
        public DCON_referenceFields_WP(List<String> allfields, List<String> reffields, List<String> dateTimeFields, List<String> dateFields, Map<String, String> replacementRef, Map<String, String> replacementField, Map<String, String> mapObjectNameField,List<String> pickList1){
            allFields_L = allfields;
            referenceFields_L = reffields;
            dateTimeFields_L = dateTimeFields;
            dateFields_L = dateFields;
            replacementReference_M = replacementRef;
            replacementField_M = replacementField;
            objectNameField_M = mapObjectNameField;
            pickList_L = pickList1;
            system.debug(pickList_L);
        }
    }
    public String DCON_getFieldNamesFromList(List<String> fieldList,List<String> pickList_L) {
        String fieldNames = '';
        for (String field : fieldList) {
            if (fieldNames.length()>0) {
                fieldNames += ',';
            }
            if(pickList_L.contains(field)){
                fieldNames += 'toLabel('+field+')';
            }
            else {
                fieldNames += field;
            }
           
        }        
        return fieldNames;
    } 
   
}