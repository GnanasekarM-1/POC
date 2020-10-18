/*
 This is a UT class for WSCH_DateUtils  for more code coverage.
*/
@isTest
public with sharing class WSCH_DateUtils_UT {
    static testMethod void dateUtilTest() 
    {
        WSCH_DateUtils.formatDate(date.newInstance(2014, 2, 17),'GMT','yyyy-MM-dd HH:mm:ss');
        
        WSCH_DateUtils.parseSPDateTimeGmt('2014-03-13T13:30');
        
        WSCH_DateUtils.parseSPDateTime('2014-03-13T13:30');
        
        WSCH_DateUtils.parseDateGmt('2014-05-12');
        
        WSCH_DateUtils.parseDate('2014-05-12');
        
        WSCH_DateUtils.parseTime('05:45:05');
        
        WSCH_DateUtils.parseTimeGmt('05:45:05');
        
        WSCH_DateUtils.getSPDateTime(DateTime.now());
        
        WSCH_DateUtils.getCurrentTimeStamp();
        
        WSCH_DateUtils.getDurationInMinutes(DateTime.now(),DateTime.now());
        
        WSCH_DateUtils.formatSPEndTime(Time.newInstance(18, 30, 2, 20),'GMT');
        
        WSCH_DateUtils.formatDateTime(DateTime.now(), 'GMT', 'yyyy-MM-dd HH:mm:ss');
        
        WSCH_DateUtils.parseDateTimeGmt('2014-05-15 13:30:22');
        
        WSCH_DateUtils.parseDateTime('2014-05-15 13:30:22');
    }
    
    static testMethod void dateUtilTest2(){
        
        WSCH_DateUtils.formatSPTime(Time.newInstance(18, 30, 2, 20),'GMT');
        
        WSCH_DateUtils.getSFDateAndTime('2014-03-13T13:30');
        
        WSCH_DateUtils.parseSPDateTimeNew('2014-02-18T16:30');
        
        WSCH_DateUtils.parseDateTimeNew('2014-12-18 12:07:32');
        
        DateTime dt = DateTime.now();
        
        WSCH_DateUtils.formatSPTime(dt.time());
        
        WSCH_DateUtils.getSPDate(DateTime.now());
        
        WSCH_DateUtils.getDateTimeInUserLocale('2014-02-18T16:30');
        
        WSCH_DateUtils.getDateFromDT(DateTime.now(), 'Asia/Colombo', 'gmt');
        
        WSCH_DateUtils.getDateFromDT(DateTime.now(), 'Asia/Colombo', 'usr');
        
        WSCH_DateUtils.getTimeFromDT(DateTime.now(), 'Asia/Colombo', 'gmt');
        
        WSCH_DateUtils.getTimeFromDT(DateTime.now(), 'Asia/Colombo', 'usr');
        
        WSCH_DateUtils.doTZConversion(DateTime.now(), 'Asia/Colombo', 'GMT', 60);
        
        WSCH_DateUtils.doTZConversion(DateTime.now(), 'Asia/Colombo', 'GMT', -1);
        
        WSCH_DateUtils.getIntOffsetFromSPDate('2014-11-07T22:30-06:00');
        
        WSCH_DateUtils.getIntOffsetFromSPDate('2014-11-07T22:30+06:00');
        
        //below methods for exception coverage
        
        WSCH_DateUtils.formatDateTime(DateTime.now(), '', '');
        
        WSCH_DateUtils.formatDate(date.newInstance(2014, 2, 17),'GMT', '');
        
        WSCH_DateUtils.formatSPEndTime(Time.newInstance(0, 0, 2, 20), 'GMT');
        
        WSCH_DateUtils.getDurationInMinutes(null, null);
        
        WSCH_DateUtils.formatSPTime(Time.newInstance(1, 2, 3, 4), 10);
        
        WSCH_DateUtils.getLocaleDateFormat();
        
        //String str;
        //str = WSCH_DateUtils.getLocaleTimeFormat();
        //System.debug('str-->'+str);
        
        String[] parts = DateTime.now().format().split(' ');
        String str1 = (parts.size() == 3) ? (parts[1] + ' ' + parts[2]) : parts[1]; 
        system.debug('str1-->'+str1);
        
        //WSCH_DateUtils.getXmlDateTimeFormat();
    } 
}