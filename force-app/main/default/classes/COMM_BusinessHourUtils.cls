public Class COMM_BusinessHourUtils{
    
    public static Map<String, DayTimings> dayTimesMap = new Map<String, DayTimings>();
    
    public List <HolidayDateAndTime> getHolidaysForBS(BusinessHours BHRec, List<Holiday> listOfAllHolidays, List<Holiday> lstOfPartialHolidays, Date startDate, Date endDate ){
        List <HolidayDateAndTime> lstDateAndTimeRange = new List <HolidayDateAndTime>(); 
        
        // First Get the days between the Start Date and End Date
        List<Date> datesBetweenStartAndEnd = getLstOfDatesBetween(startDate, endDate);
        // We need Business hour timings before starting the execution
        businessHourTimings(BHRec); 
        
        // Do not process further if there are no dates to check for Holiday List
        if(datesBetweenStartAndEnd != null && datesBetweenStartAndEnd.size() >0){
            // Then for each day, check if it's a full day holiday or not
            for( Date eachDate : datesBetweenStartAndEnd) {
                if(dayTimesMap != null && dayTimesMap.size() > 0 ){
                    // This takes care of ALL Day Holiday
                    
                    if(!isWorkingDay(BHRec, eachDate)){
                        HolidayDateAndTime holidayData= getDateTimeRangeForAllDayHoliday(eachDate, BHRec); 
                        lstDateAndTimeRange.add(holidayData);
                    }
                    else{
                        for(Holiday eachPartialHoliday : lstOfPartialHolidays) {
                            DateTime holidayStartTimeGMT = getHolidayDates( eachPartialHoliday.StartTimeInMinutes, eachDate, BHRec.TimeZoneSidKey); 
                            DateTime holidayEndTimeGMT = getHolidayDates(eachPartialHoliday.EndTimeInMinutes, eachDate, BHRec.TimeZoneSidKey); 
                            // Adding -1 as Busineshours.isWithin considers holiday only when 1s or 1m less than exact time for end datetime. 
                            holidayEndTimeGMT = holidayEndTimeGMT.addMinutes(-1); 
                            List<DateTime> lstOfBHDateTime = getBHStartEndDateTime(eachDate, BHRec);
                            
                            
                            // List of BH Start and End Time shouldn't be empty. 
                            if(lstOfBHDateTime != null && lstOfBHDateTime.size() == 2) {
                                DateTime bhStartDateTime = lstOfBHDateTime.get(0);
                                DateTime bhEndDateTime = lstOfBHDateTime.get(1);   
                                // It's possible to have partial holiday to Start before BH start time, therefore update the Holiday start time to BS Start Time
                                if(holidayStartTimeGMT < bhStartDateTime) {
                                    holidayStartTimeGMT = bhStartDateTime;
                                }
                                
                                // It's possible to have partial holiday to End After BH end time, therefore update the Holiday end time to BS Start Time
                                if(holidayEndTimeGMT > bhEndDateTime) {
                                    holidayEndTimeGMT = bhEndDateTime;
                                }
                                if(!Businesshours.isWithin(BHRec.Id, holidayStartTimeGMT) && !Businesshours.isWithin(BHRec.Id, holidayEndTimeGMT)) {
                                    String strSPDateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm:ss';
                                    holidayEndTimeGMT = holidayEndTimeGMT.addMinutes(1); 
                                    HolidayDateAndTime partialHolidayData = new HolidayDateAndTime(holidayStartTimeGMT.formatGmt(strSPDateTimeFormat), holidayEndTimeGMT.formatGmt(strSPDateTimeFormat)); 
                                    system.debug(partialHolidayData); 
                                    lstDateAndTimeRange.add(partialHolidayData);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if(lstDateAndTimeRange != null && lstDateAndTimeRange.size() > 0){
            
            //Only purpose to create set is to remove duplicate
            Set<String> setStartDate = new Set<String>();
            for(HolidayDateAndTime eachHoliday: lstDateAndTimeRange ){
                setStartDate.add(eachHoliday.startDateTime);
            }
            
            // List is used for sorting
            List<String> lstHolidayStartDate = new List<String>();
            lstHolidayStartDate.addAll(setStartDate);
            lstHolidayStartDate.sort();
            
            
            // Create a sorted list of holidays retrived using webservice
            List<HolidayDateAndTime> sortedHolidayList = new List<HolidayDateAndTime>();
            if(lstHolidayStartDate != null && lstHolidayStartDate.size() > 0){
                for(String startDt: lstHolidayStartDate){ 
                    for(HolidayDateAndTime eachSortedHoliday: lstDateAndTimeRange ){
                        if(eachSortedHoliday.startDateTime == startDt){
                            sortedHolidayList.add(eachSortedHoliday);
                        }
                    }
                }
            }
        
            lstDateAndTimeRange.clear(); 
            lstDateAndTimeRange.addAll(sortedHolidayList); 
            System.debug(LoggingLevel.WARN, 'List of Holidays sorted' +lstDateAndTimeRange);
        }   
    
        return lstDateAndTimeRange; 
    }                                       

    public boolean isWorkingDay(BusinessHours objBusinessHour, Date datRequestedDate){
        
        /*Datetime nextStart = BusinessHours.nextStartDate(objBusinessHour.id, datRequestedDate);
        Date datNextWkgDate = Date.valueOf(nextStart.format('yyyy-MM-dd', objBusinessHour.timeZoneSidKey));
        
        system.debug(nextStart + '----' + datNextWkgDate + '-----' + datRequestedDate);
        if(datNextWkgDate == datRequestedDate)
            return TRUE;
        else
            return FALSE;*/
            
        system.debug('datRequestedDate - ' + datRequestedDate);
        // Get the start time of the given date (i.e. start of the day in the given time zone)
        Datetime dtmDayStartDateTime = getDateTimeInTimezone(datRequestedDate, Time.newInstance(0, 0, 0, 0), objBusinessHour.timeZoneSidKey);
        
        system.debug('dtmDayStartDateTime - ' + dtmDayStartDateTime);
        
        // Get the next working date time with respect to the given day's start
        Datetime dtmNextWkgDateTime = BusinessHours.addGmt(objBusinessHour.id, dtmDayStartDateTime, 1L);
        
        // Get the date of the next working date time in the given time zone
        Date datNextWkgDate = Date.valueOf(dtmNextWkgDateTime.format('yyyy-MM-dd', objBusinessHour.timeZoneSidKey));
    
        // If the given date and next working date are the same, the given day is a working day
        if(datNextWkgDate == datRequestedDate)
            return TRUE;
        else
            return FALSE;
    }


    public static List<Date> getLstOfDatesBetween(Date startDate, Date endDate) {
        List<Date> lstDate = new List<Date>();
        for(Date dt = startDate; dt <= endDate; dt = dt.addDays(1)) { 
            lstDate.add(dt);
        }
        return lstDate;
    }

    public static HolidayDateAndTime getDateTimeRangeForAllDayHoliday(Date holidayDate, BusinessHours businessHr) {
        String strSPDateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm:ss';
        
        DateTime holidayStartDateTime = DateTime.newInstanceGmt(holidayDate, Time.newInstance(0,0,0,0));
        DateTime holidayEndDateTime = DateTime.newInstanceGmt(holidayDate, Time.newInstance(23,59,0,0));
        String strSPStartDateTime,strSPEndDateTime;
        
        
        DateTime startDateTime = WSCH_DateUtils.doTZConversion(holidayStartDateTime, businessHr.TimeZoneSidKey, 'GMT');
        strSPStartDateTime = startDateTime.formatGmt(strSPDateTimeFormat);
        
        DateTime endDateTime = WSCH_DateUtils.doTZConversion(holidayEndDateTime, businessHr.TimeZoneSidKey, 'GMT');
        strSPEndDateTime = endDateTime.formatGmt(strSPDateTimeFormat);
        
        HolidayDateAndTime dateAndTimeRangedata = new HolidayDateAndTime(strSPStartDateTime, strSPEndDateTime); 
            
        return dateAndTimeRangedata;
    }


    public DateTime getHolidayDates(Integer timeVal, Date dateVal, String timeZoneKey ){
        Double timeMinDouble = (Double)timeVal/60;
        String[] strTime = String.valueOf(timeMinDouble).split('\\.',2);
        Integer intHour = Integer.valueOf(strTime[0]);
        Integer intMin = Math.mod(timeVal, 60);
        
        //create dateTime object as DateTime.newInstance(eachHolidayObj.ActivityDate, Time.newInstance(hour, minute, 0, 0))
        DateTime dTUsrTZ = null; 
        dTUsrTZ = DateTime.newInstanceGmt(dateVal, Time.newInstance(intHour, intMin, 0, 0));
        
        DateTime dTGMT = WSCH_DateUtils.doTZConversion(dTUsrTZ, timeZoneKey, 'GMT', null);
        return dTGMT;
    }


    public static List<DateTime> getBHStartEndDateTime(Date dateObj, BusinessHours bussHour) {
        DateTime eachDateTime = DateTime.newInstanceGmt(dateObj,Time.newInstance(0,0,0,0));
        String strDay = eachDateTime.formatGmt('EEEE');
        List<DateTime> lstOfBhDateTime = new List<DateTime>();
        DateTime bhStartDateTime, bhEndDateTime;
        if(dayTimesMap !=null && dayTimesMap.size() > 0 && dayTimesMap.get(strDay) != null){
            DayTimings startEndTime = dayTimesMap.get(strDay); 
            // Let's 1st check for 24 hour scenario
            
            // Wondering why we are converting in GMT, coz the startTime and EndTime from BH is given in GMT.
            if(startEndTime.startTime != null){
                bhStartDateTime = DateTime.newInstanceGmt(dateObj, startEndTime.startTime );
                DateTime bhStartDateTimeGMT = WSCH_DateUtils.doTZConversion(bhStartDateTime, bussHour.timeZoneSidKey, 'GMT', null);
                lstOfBhDateTime.add(bhStartDateTimeGMT);
            }
            
            if(startEndTime.endTime != null){
                // check if it's 24 hour holiday or not
                bhEndDateTime = DateTime.newInstanceGmt(dateObj, startEndTime.endTime);
                if(startEndTime.startTime == Time.newInstance(0,0,0,0) && startEndTime.endTime == Time.newInstance(0,0,0,0)){
                    bhEndDateTime = DateTime.newInstance(dateObj, Time.newInstance(23,59,0,0));
                }
        
                DateTime bhEndDateTimeGMT = WSCH_DateUtils.doTZConversion(bhEndDateTime, bussHour.timeZoneSidKey, 'GMT', null);
                lstOfBhDateTime.add(bhEndDateTimeGMT);
            }    
        }
        return lstOfBhDateTime;
    }

    
    public void businessHourTimings(BusinessHours businessHourRec){
        dayTimesMap.put('Monday',new DayTimings(businessHourRec.MondayStartTime, businessHourRec.MondayEndTime));
        dayTimesMap.put('Tuesday',new DayTimings(businessHourRec.TuesdayStartTime, businessHourRec.TuesdayEndTime));
        dayTimesMap.put('Wednesday',new DayTimings(businessHourRec.WednesdayStartTime,businessHourRec.WednesdayEndTime));
        dayTimesMap.put('Thursday',new DayTimings(businessHourRec.ThursdayStartTime,businessHourRec.ThursdayEndTime));
        dayTimesMap.put('Friday',new DayTimings(businessHourRec.FridayStartTime,businessHourRec.FridayEndTime));
        dayTimesMap.put('Saturday',new DayTimings(businessHourRec.SaturdayStartTime,businessHourRec.SaturdayEndTime));
        dayTimesMap.put('Sunday',new DayTimings(businessHourRec.SundayStartTime,businessHourRec.SundayEndTime));
    }
    
    public DateTime getDateTimeInTimezone(Date givenDate, Time givenTime, String timeZoneSidKey){
        DateTime gmtDateTime = DateTime.newInstanceGmt(givenDate, givenTime);
    
        String gmtDateTimeStr = gmtDateTime.formatGmt('yyyy-MM-dd HH:mm:ss');
        Double tmzOffsetMins = (DateTime.valueOfGmt(gmtDateTimeStr).getTime() - DateTime.valueOfGmt(gmtDateTime.format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey)).getTime())/60000;
        DateTime retDateTime = gmtDateTime.addMinutes(tmzOffsetMins.intValue());
    
    
        // Check if the conversion is correct.
        // If not correct (can happen during DST transition points), adjust the returned date time.
        if(retDateTime.format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey) == gmtDateTimeStr)
            return retDateTime;
        else if(retDateTime.addhours(1).format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey) == gmtDateTimeStr)
            return retDateTime.addhours(1);
        else if(retDateTime.addhours(-1).format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey) == gmtDateTimeStr)
            return retDateTime.addhours(-1);
        else // Given date time is illegal for the given time zone, e.g. 13/Mar/2011, 2:30 AM, America/Los_Angeles
            return retDateTime;
    }
    
    public Class HolidayDateAndTime{
        public String startDateTime; 
        public String endDateTime; 
        public HolidayDateAndTime (String startDT, String endDT){
            startDateTime =  startDT;
            endDateTime = endDT;
        }
    }
    
    public class DayTimings {
        public Time  startTime; 
        public Time  endTime; 
        public DayTimings (Time startTimeVal, Time  endTimeVal){
            startTime = startTimeVal; 
            endTime = endTimeVal; 
        }
    }
    
}