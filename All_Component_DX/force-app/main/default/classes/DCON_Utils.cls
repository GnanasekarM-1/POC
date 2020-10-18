public with sharing class DCON_Utils {
public class SVMXException extends Exception {}
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
                throw new SVMXException(ex.getmessage());
            }
        return ResultSet;
    }

    public String SVMX_getLocalDateFormat(){
        String dateFormat;
        try
        {
        date localDate = date.newinstance(2000, 10, 30);
        dateFormat = string.valueof(localDate.format());
        dateFormat = dateFormat.replace('10','MM');
        dateFormat = dateFormat.replace('30','DD');
        dateFormat = dateFormat.replace('2000','YYYY');   
        }
        catch (Exception ex){
                throw new SVMXException(ex.getmessage());
            }           
        return dateFormat;
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

    public Map<String,Map<String,String>> getRecordTypeMap(){
        Map<String,Map<String,String>> ResultSet = new Map<String,Map<String,String>>();
        try
        {
        Map<String,String> RecordTypeMap;
        List<RecordType> RTypes = new List<RecordType>();
        String SOQL  = 'SELECT Id ,Name, SobjectType  FROM RecordType';       
        RTypes = Database.query(SOQL);
         
        for(RecordType rtl: RTypes){
            RecordTypeMap =new Map<String,String>();
            for(RecordType rt: RTypes){
                if(rtl.SobjectType==rt.SobjectType)
                RecordTypeMap.put(rt.Name, string.valueOf(rt.Id));
            }
            ResultSet.put(rtl.SobjectType, RecordTypeMap);
        }
        system.debug('TESTs'+ResultSet);
        }
        catch (Exception ex){
                throw new SVMXException(ex.getmessage());
            }
        return ResultSet;
    }

    /*  Handles timeZone converstion
        Takes datatime and convert it to the timezone specified and return in requested format/type
    */

    public String TimeZoneConvertor(DateTime givenDateTime, String localTimeZone, String timeZone, String dateType){
        //Create DateTime in GMT format
        String GMTDateStr = givenDateTime.format('yyyy-MM-dd HH:mm:ss', 'GMT');
        //Create DateTime in user selected format
        String initDateStr = givenDateTime.format('yyyy-MM-dd HH:mm:ss', timeZone);
        //Create DateTime in user local format
        String localDateStr = givenDateTime.format('yyyy-MM-dd HH:mm:ss', localTimeZone);
        
        system.debug('TEST TIMEZONE CONV: '+ string.valueof(GMTDateStr)+string.valueof(initDateStr)+string.valueof(localDateStr));
        Long st = datetime.valueof(initDateStr).getTime();
        Long gmt = datetime.valueof(GMTDateStr).getTime();
        
        if(dateType.toUpperCase() == 'GMT' && timeZone.toUpperCase() == 'LOCAL'){   
            Long local = datetime.valueof(localDateStr).getTime();
            Long differenceSec_Local = ( (local - gmt)/60000 );
            //return String.valueof(datetime.valueof(GMTDateStr).addMinutes(integer.valueof(String.valueof(differenceSec_Local))));
            return GMTDateStr;
        }
        
        //Compute the difference
        Long differenceSec = ( (st - gmt)/60000 );
        
        system.debug('--------------------------------------');
        system.debug('TEST Difference for '+timeZone+':=>Given DateTime: '+givenDateTime+' Difference in seconds: '+differenceSec+' : =>'+integer.valueof(String.valueof(differenceSec)));
        //system.debug('--------------------------------------');
        
        if(dateType.toUpperCase() == 'GMT' && timeZone.toUpperCase() != 'LOCAL'){   
            Long local = datetime.valueof(localDateStr).getTime();
            Long differenceSec_Local = ( (local - gmt)/60000 );
            
            system.debug('--------------------------------------');
            system.debug('TEST '+differenceSec_Local+'-----'+differenceSec+'----'+localDateStr+'----'+GMTDateStr);
            //system.debug('--------------------------------------');
            return String.valueof(datetime.valueof(GMTDateStr).addMinutes(integer.valueof(String.valueof(differenceSec_Local))-integer.valueof(String.valueof(differenceSec))));
            //return String.valueof(datetime.valueof(localDateStr).addMinutes(integer.valueof(String.valueof(differenceSec_Local))-integer.valueof(String.valueof(differenceSec))));
        }
        
        if(dateType.toUpperCase() == 'SYSTEMLOCALE')
        return (datetime.valueof(GMTDateStr).addMinutes(integer.valueof(String.valueof(differenceSec))).format());
        else if(dateType.toUpperCase() == 'US')
        return (datetime.valueof(GMTDateStr).addMinutes(integer.valueof(String.valueof(differenceSec))).format('MM/dd/yyyy hh:mm a'));
        else
        return String.valueof(datetime.valueof(GMTDateStr).addMinutes(integer.valueof(String.valueof(differenceSec))));
    }

    public String TimeZoneConvertor(Date givenDate, String localTimeZone, String timeZone, String dateType){
        //Convert Date to Date Time
        Datetime convertedDateTime = datetime.newInstance(givenDate.year(), givenDate.month(), givenDate.day(),0,0,0);
        return (TimeZoneConvertor(convertedDateTime, localTimeZone, timeZone, dateType));
    }


    public String TimeZoneConvertor(DateTime givenDateTime, String fromTimeZone, String toTimeZone){
        system.debug('TEST1 DATE: '+givenDateTime+fromTimeZone+toTimeZone);
        //Create DateTime in GMT format
        String GMTDateStr = givenDateTime.format('yyyy-MM-dd HH:mm:ss', 'GMT');
        //Create DateTime in given format
        String fromTZstr = givenDateTime.format('yyyy-MM-dd HH:mm:ss', fromTimeZone);
        //Create DateTime in user selected timezone
        String toTZstr = givenDateTime.format('yyyy-MM-dd HH:mm:ss', toTimeZone);

        Long localMS = datetime.valueof(givenDateTime).getTime();
        Long gmtMS = datetime.valueof(GMTDateStr).getTime();
        Long frmMS = datetime.valueof(fromTZstr).getTime();
        Long toMS = datetime.valueof(toTZstr).getTime();
        Long differenceGMT_Local = ( (localms - gmtMS)/60000 );
        Long differenceGMT_From = ( (frmms - gmtMS)/60000 );
        Long differenceGMT_To = ( (toMS - gmtMS)/60000 );
            
        system.debug('TEST5 DATE: '+GMTDateStr);
        system.debug('TEST51 DATE: '+differenceGMT_Local);
        system.debug('TEST52 DATE: '+differenceGMT_From);
        system.debug('TEST53 DATE: '+differenceGMT_To);
        return string.valueof(datetime.valueof(GMTDateStr).addMinutes(( 2*integer.valueof( String.valueof(differenceGMT_Local) ) ) + ( integer.valueof(String.valueof(differenceGMT_To)) - integer.valueof(String.valueof(differenceGMT_From)) )));
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

    public Map<String,String> SVMX_getFieldMap( Map<String,Schema.SObjectField> fieldMap, Boolean selectAllFields)
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
            if(f.isUpdateable()){
                if (selectAllFields == true){
                        fieldList.put(fieldName,String.valueof(f.getType()));
                    }
                else {
                    if (f.getName()=='Id' || f.isNameField() || f.isCustom()) {
                        fieldList.put(fieldName,String.valueof(f.getType()));
                    }
                }
            }
        }        
        System.debug('Adding :else: '+fieldList);
        }
        catch (Exception ex){
                throw new SVMXException(ex.getmessage());
            }
        return fieldList;
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
        catch (Exception ex){
                throw new SVMXException(ex.getmessage());
            }
        return fieldList;
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
                throw new SVMXException(ex.getmessage());
            }
        return ResultSet;
    }
    private static Double EARTH_RADIUS = 6371.00; // Radius in Kilometers default
    
    //This function assuems that lattitude and longitude comes as radion and returns the distance between two lattitude and longitude.. 
    public Double getDistanceBetween(Double lat1, Double lon1, Double lat2, Double lon2)
    {
        Double Radius = EARTH_RADIUS; //6371.00;
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
    
    /**
     *
     */
    public List<Datetime> getBHStartEndDateTime(String timeZone, Date givenDate, BusinessHours bussHour) 
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
    
    /**
     *
     */
    public DateTime doTZConversion(DateTime resDateTime, String strSourceTimeZone, String strTargetTimeZone) 
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
    
    /**
     *
     */
    public Boolean GetHolidays(BusinessHours bh, Date givendate)
    {
        DCON_Utils dcUtils = new DCON_Utils();
        Boolean isHoliday = false;
        if(givendate != null && bh != null)
        {
            Datetime dtmDayStartDateTime = dcUtils.getDateTimeInTimezone(givendate, Time.newInstance(0, 0, 0, 0), bh.timeZoneSidKey);
                  
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
}