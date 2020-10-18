/*
    Following class contains all the Date and time related utility methods , which will be in use for communication with external systems.
*/
global class WSCH_DateUtils {

    /*
        Return the date and time in the specified timezone and in the format passed as parameter. if format is null the method falls back to some
        default format. if the timezone is null the date and time string is passed in users timezone format. The parameter format should following java date and time format pattern.
    */
    global static String formatDateTime(DateTime sfDate, String timezone, string format) {

        if(String.isBlank(format)) {
            format = 'yyyy-MM-dd HH:mm:ss';
        }
        if (String.isBlank(timezone)){
            return sfDate.format(format);
        } else {
            return sfDate.format(format,timezone);
        }
    }

    /*
        Return the date in the specified timezone and in the format passed as parameter. if format is null the method falls back to some
        default format. if the timezone is null the date string is passed in users timezone format. The parameter format should following java date format pattern.
    */
    global static String formatDate(Date sfDate, String timezone, string format) {

        DateTime dateAndTime = DateTime.newInstance(sfDate.year(), sfDate.month(), sfDate.day());
        if(String.isBlank(format)) {
            return formatDateTime(dateAndTime, timezone, 'yyyy-MM-dd');
        } else {
            return formatDateTime(dateAndTime, timezone, format);
        }

    }

    /*
        Parse the SP returned datetime based on GMT.
    */
    global static DateTime parseSPDateTimeGmt(String spDateTime) {

        String sfDateAndTime = getSFDateAndTime(spDateTime);
        return parseDateTimeGmt(sfDateAndTime);
    }

    /*
        Parse the SP returned datetime based on local time zone.
    */
    global static DateTime parseSPDateTime(String spDateTime) {

        String sfDateAndTime = getSFDateAndTime(spDateTime);
        return parseDateTime(sfDateAndTime);
    }

    //This method converts datatype string to datetime using the local timezone.
    // input datetime should be SP Format
    global static DateTime parseSPDateTimeNew(String spDateTime) {
        DateTime finalDateTime;
        String sfDateAndTime = getSFDateAndTime(spDateTime);
        finalDateTime = Datetime.valueOfGmt(sfDateAndTime);
        return finalDateTime;   
    }

    //This method converts datatype string to datetime using the local timezone.
    // input datetime should be SF Format
    global static DateTime parseDateTimeNew(String strDateTime) {
        DateTime finalDateTime;
        finalDateTime = Datetime.valueOfGmt(strDateTime);
        return finalDateTime;   
    }   

    /*
        Parse the datetime based on the GMT.
        The datetime should be passed in the format of 'yyyy-MM-dd HH:mm:ss�.
    */
    global static DateTime parseDateTimeGmt(String strDateTime) {

        return Datetime.valueOfGmt(strDateTime);
    }

    /*
        Parse the date based on the GMT.
        The date should be passed in the format of 'yyyy-MM-dd�.
    */
    global static Date parseDateGmt(String strDate) {

        String[] strDateComponent = strDate.split('-',3);
        DateTime dateAndTime = DateTime.newInstanceGmt(Integer.valueOf(strDateComponent[0]),Integer.valueOf(strDateComponent[1]),Integer.valueOf(strDateComponent[2]));
        return dateAndTime.dateGmt();
    }

    /*
        Parse the datetime based on locale time zone.
        The datetime should be passed in the format of 'yyyy-MM-dd HH:mm:ss�.
    */
    global static DateTime parseDateTime(String strDateTime) {

        return Datetime.valueOf(strDateTime);
    }

    /*
        Parse the date based on the local time zone.
        The date should be passed in the format of 'yyyy-MM-dd�.
    */
    global static Date parseDate(String strDate) {

        String[] strDateComponent = strDate.split('-',3);
        return Date.newInstance(Integer.valueOf(strDateComponent[0]),Integer.valueOf(strDateComponent[1]),Integer.valueOf(strDateComponent[2]));
    }

    /*
        Parse the time in local time zone format(The time should be passed 'HH:mm:ss').
    */
    global static Time parseTime(String strTime) {

        String[] strTimeComponent = strTime.split(':',3);
        return Time.newInstance(Integer.valueOf(strTimeComponent[0]),Integer.valueOf(strTimeComponent[1]),Integer.valueOf(strTimeComponent[2]), 0);
    }

    /*
        Parse the time in GMT.
    */
    global static Time parseTimeGmt(String strTime) {

        String[] strTimeComponent = strTime.split(':',3);
        DateTime dateAndTime = DateTime.newInstanceGmt(0,0,0,Integer.valueOf(strTimeComponent[0]),Integer.valueOf(strTimeComponent[1]), Integer.valueOf(strTimeComponent[2]));
        return dateAndTime.timeGmt();
    }

    /**
     * Format the time in different timezone to a format in GMT timezone.
     */
    global static String formatSPTime(Time bhTime, String timeZoneSIDKey) {

        TimeZone tz = TimeZone.getTimeZone(timeZoneSIDKey);
        Datetime now = Datetime.now();
        Datetime gmtDate = Datetime.newInstanceGmt(now.yearGmt(), now.monthGmt(), now.dayGmt());
        DateTime dt = Datetime.newInstanceGmt(now.dateGmt(), bhTime);
        dt = dt.addSeconds(-(tz.getOffset(gmtDate)/1000));
        return dt.formatGmt('HH:mm');
    }
    
    /**
     * Format the time in different timezone to a format in GMT timezone using offSet.
     */
    public static String formatSPTime(Time bhTime, Integer tzOffSetinMinutes) {
        Datetime now = Datetime.now();
        Datetime gmtDate = Datetime.newInstanceGmt(now.yearGmt(), now.monthGmt(), now.dayGmt());
        DateTime dt = Datetime.newInstanceGmt(now.dateGmt(), bhTime);
        dt = dt.addMinutes(tzOffSetinMinutes);
        return dt.formatGmt('HH:mm');
    }
    
    /**
     * Format the time in to a format.
     */    
    public static String formatSPTime(Time bhTime) {
        Datetime now = Datetime.now();
        Datetime gmtDate = Datetime.newInstanceGmt(now.yearGmt(), now.monthGmt(), now.dayGmt());
        DateTime dt = Datetime.newInstanceGmt(now.dateGmt(), bhTime);
        return dt.formatGmt('HH:mm');
    }    

    /**
     * Format the time in different timezone to a format in GMT timezone.
     */
    global static String formatSPEndTime(Time bhTime, String timeZoneSIDKey) {

        if(bhTime.hour() == 0 && bhTime.minute() == 0) {
            bhTime = bhTime.addMinutes(-1);
        }
        return formatSPTime(bhTime, timeZoneSIDKey);
    }
    
    /**
     * Format the time in different timezone to a format in GMT timezone.
     */
    global static String formatSPEndTime(Time bhTime, Integer tzOffsetinMinutes) {

        if(bhTime.hour() == 0 && bhTime.minute() == 0) {
            bhTime = bhTime.addMinutes(-1);
        }
        return formatSPTime(bhTime, tzOffsetinMinutes);
    }

    /*
        Returns the Date and Time in SP Format.
    */
    global static String getSPDateTime(DateTime sfDateTime){

        return formatDateTime(sfDateTime, 'GMT', 'yyyy-MM-dd\'T\'HH:mm');
    }

    /*
        Returns the Date in SP Format.
    */
    global static String getSPDate(DateTime sfDateTime){

        return formatDateTime(sfDateTime, 'GMT', 'yyyy-MM-dd');
    }

    /*
        Returns the SP Date and Time in 'yyyy-MM-dd HH:mm:ss' format. Input date would be 2014-11-07T15:00+06:00 or 2014-11-07T15:00-06:00
        or 2014-11-07T15:00
    */
    global static String getSFDateAndTime(String spDateTime){
        
        //WSCH_AuditLogger.debug('Input date from SP - ' + spDateTime);
        //if spDateTime length is > 16 then it contains the GMT offset
        if(spDateTime.length() > 16) {
            spDateTime = spDateTime.subString(0, 16);
        }
        String strDateTime = spDatetime.replace('T',' ');
        return strDateTime + ':00';
    }

    /*
        Returns the current timestamp..
    */
    global static String getCurrentTimeStamp(){
        //return '' + DateTime.now().getTime()/1000;
        return '' + DateTime.now().addSeconds(-59).getTime()/1000;
    }

    /*
        Finds the time difference in minutes between two given Date and Times.
    */
    global static Integer getDurationInMinutes(DateTime startDateTime, DateTime endDateTime){
        Integer minutes=0;
        try{
            minutes = Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));
        }catch(Exception ex){
            WSCH_AuditLogger.debug('Exception caught:WSCH_DateUtils:getDurationInMinutes() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return minutes;
    }

    /*
        Returns the Datetime as per the user locale
    */
    global static Datetime getDateTimeInUserLocale(String spDateTime) {
        //Input date format = '2014-02-18T16:30';
        if(spDateTime.length() > 16) {
            spDateTime = spDateTime.subString(0, 16);
        }
        String[] strDateTimeSplit = spDateTime.split('T',2);
        String[] strDateComponent = strDateTimeSplit[0].split('-',3);
        String[] strTimeComponent = strDateTimeSplit[1].split(':',2);

        Datetime dt = DateTime.newInstance(Integer.valueOf(strDateComponent[0].trim()),Integer.valueOf(strDateComponent[1].trim()),
                                            Integer.valueOf(strDateComponent[2].trim()),Integer.valueOf(strTimeComponent[0].trim()),
                                            Integer.valueOf(strTimeComponent[1].trim()),0);
        return dt;
    }
    
    public static String getDateFromDT(DateTime sfDateTime, String strTimeZone, String tzType){
        String strDate;
        //convert the above DateTime as per the time zone
        if(tzType.equalsIgnoreCase('gmt')){
            strDate = sfDateTime.format('yyyy-MM-dd',strTimeZone);
        }else if(tzType.equalsIgnoreCase('usr')){
            DateTime dateTimeGmt = doTZConversion(sfDateTime,strTimeZone,'GMT');
            strDate = dateTimeGmt.format('yyyy-MM-dd',strTimeZone);
        }
        return strDate;
    }

    public static String getTimeFromDT(DateTime sfDateTime, String strTimeZone, String tzType){
        //convert the above DateTime as per the time zone
        String strTime;
        if(tzType.equalsIgnoreCase('gmt')){
            strTime = sfDateTime.format('HHmm',strTimeZone);
        }else if(tzType.equalsIgnoreCase('usr')){
            DateTime dateTimeGmt = doTZConversion(sfDateTime,strTimeZone,'GMT');
            strTime = dateTimeGmt.format('HHmm',strTimeZone);
        }       
        return strTime;
    }
    
    global static DateTime doTZConversion(DateTime resDateTime, String strSourceTimeZone, String strTargetTimeZone) {
        DateTime finalDateTime;
        TimeZone sourceTimeZone,targetTimeZone;
        if(resDateTime != null && String.isNotBlank(strSourceTimeZone) && String.isNotBlank(strTargetTimeZone)){
            sourceTimeZone= TimeZone.getTimeZone(strSourceTimeZone);
            targetTimeZone= TimeZone.getTimeZone(strTargetTimeZone);
            integer diff = targetTimeZone.getOffset(resDateTime) - sourceTimeZone.getOffset(resDateTime);
            finalDateTime = resDateTime.addSeconds(diff/1000);
        }
        WSCH_AuditLogger.debug('ConvertedDateTime from  SourceTZ('+sourceTimeZone+') To targetTZ ('+targetTimeZone+'): ' + finalDateTime );
        return finalDateTime;
    }
    
    public static DateTime doTZConversion(DateTime resDateTime, String strSourceTimeZone, String strTargetTimeZone, Integer tzOffSetinMinutes) {
        DateTime finalDateTime;
        if(tzOffSetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1){
            finalDateTime = doTZConversion(resDateTime,strSourceTimeZone,strTargetTimeZone);
        } else {
            finalDateTime = resDateTime.addMinutes(tzOffSetinMinutes);
        }
        WSCH_AuditLogger.debug('ConvertedDateTime : ' + finalDateTime );
        return finalDateTime;
    }
    
    public static Integer getIntOffsetFromSPDate(String spDateTime) {
        //WSCH_AuditLogger.debug('Input date from SP - ' + spDateTime);
        Integer intOffset = -1;
        //if spDateTime length is > 16 then it contains the GMT offset
        if(spDateTime != null && String.isNotBlank(spDateTime) && spDateTime.length() > 16) {
            if(spDateTime.contains('+')) {
                Integer index = spDateTime.indexOf('+');
                String strOffset = spDateTime.subString(index + 1, spDateTime.length());
                //WSCH_AuditLogger.debug(' substring offset - ' + strOffset);
                String[] strOffsetSplit = strOffset.split(':');
                intOffset = Integer.valueOf(strOffsetSplit[0]) * 60 + Integer.valueOf(strOffsetSplit[1]);
                intOffset = -1 * intOffset;
            } else {
                Integer index = spDateTime.lastIndexOf('-');
                String strOffset = spDateTime.subString(index + 1, spDateTime.length());
                //WSCH_AuditLogger.debug(' substring date - ' + spDateTime);
                String[] strOffsetSplit = strOffset.split(':');
                intOffset = Integer.valueOf(strOffsetSplit[0]) * 60 + Integer.valueOf(strOffsetSplit[1]);
            }
        }
        return intOffset;
    }
    
    public static String getLocaleDateFormat() {
        
        String dateFormat;
    
        Date localDate = Date.newInstance(2000, 10, 30);
        dateFormat = string.valueof(localDate.format());
        dateFormat = dateFormat.replace('10','%m');
        dateFormat = dateFormat.replace('30','%d');
        dateFormat = dateFormat.replace('2000','%Y');
        
        return dateFormat;
    }
    /*
    public static String getLocaleTimeFormat() {
        
        String strTimeFormat;
        
        Date d = Date.newInstance(2015,12,25);
        DateTime dt = DateTime.newInstanceGmt(d, Time.newInstance(14,30,0,0));
        system.debug('dt - ' + dt);
        
        String strDateTimeLocale = dt.format();
        system.debug('strDateTimeLocale - ' + strDateTimeLocale);
        
        String strDateLocale = dt.dateGmt().format();
        system.debug('strDateLocale - ' + strDateLocale);
        
        String strTime = dt.format('HH:mm');
        system.debug('strTime - ' + strTime);
        
        String strTimeLocale = strDateTimeLocale.replace(strDateLocale,'');
        system.debug('strTimeLocale - ' + strTimeLocale);
        
        //strTimeLocale = dt.format('yyyy-MM-dd ah:mm');  //Chinese - 2015-12-25 AM8:00
        //strTimeLocale = dt.format('dd/MM/yyyy h:mm a');  //English(India) - 25/12/2015 8:00 AM
        // strTimeLocale = dt.format('MM/dd/yyyy h:mm a');  //English(United States) - 12/25/2015 8:00 AM
        // strTimeLocale = dt.format('yyyy. MM. dd a h:mm');  //Korean - 2015. 12. 25 AM 8:00
        // strTimeLocale = dt.format('dd/MM/yyyy hh:mm a');  //Arabic(Saudi Arabia) - 25/12/2015 08:00 AM
        // strTimeLocale = dt.format('dd/MM/yyyy HH:mm');  //English(United Kingdom) - 12/25/2015 20:00
        
        strTimeLocale = strDateTimeLocale.replace(strDateLocale,'').trim();
        system.debug('strTimeLocale - ' + strTimeLocale);
        

        if(strTimeLocale != null && String.isNotBlank(strTimeLocale)) {
        system.debug('Inside main if');
          if((strTimeLocale.length() == 7 || strTimeLocale.length() == 6)){
          system.debug('Inside if 7 or 6');
            if(strTimeLocale.contains('8:00')) {
              strTimeLocale = strTimeLocale.replace('8:00','h:mm');
              strTimeLocale = strTimeLocale.replace('PM','a');
            } else if(strTimeLocale.contains('08:00')) {
              strTimeLocale = strTimeLocale.replace('08:00','hh:mm');
              strTimeLocale = strTimeLocale.replace('PM','a');
            }
          } else if(strTimeLocale.length() == 8 && strTimeLocale.contains('08:00')) {
              system.debug('Inside if 8');
              strTimeLocale = strTimeLocale.replace('08:00','hh:mm');
              strTimeLocale = strTimeLocale.replace('PM','a');
          
          } else if(strTimeLocale.contains('20:00')) {
              system.debug('Inside 20:00');
              strTimeLocale = strTimeLocale.replace('20:00','HH:mm');
          }
          strTimeFormat = strTimeLocale;
        }
        
        system.debug('strTimeFormat - ' + strTimeFormat);
        
        return strTimeFormat;
    }*/
    
    public static String userTimeFormat(DateTime userDateTime){
        DateTime gmtDateTime = doTZConversion(userDateTime, String.valueof(UserInfo.getTimeZone()), 'GMT');
        String formatedTime;
        formatedTime = gmtDateTime.format().replace(gmtDateTime.date().format(), '').trim();
        system.debug('formatedTime-->'+formatedTime);
        return formatedTime;
    }
}