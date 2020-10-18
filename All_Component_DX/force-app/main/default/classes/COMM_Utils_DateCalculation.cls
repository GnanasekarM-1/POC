public class COMM_Utils_DateCalculation 
{
    public Long  secondsPerMinute = 60;
    public Long minutesPerHour = 60;
    public Long hourPerday = 24;
    public Long intSecondsToConvert;
    public Long intSeconds;
    //constructor....
    public COMM_Utils_DateCalculation()
    {
    
    }
    public string convertSecondsToHHMMSS(Long intSecondsToConvert)
    {
        Long days = convertDay(intSecondsToConvert);
        Long hours = convertHours(intSecondsToConvert, days);
        Long minutes = getRemainingMinutes(intSecondsToConvert, days, hours);
        minutes = (minutes == 60) ? 00 : minutes;
        Long seconds = getRemainingSeconds(intSecondsToConvert);
        system.debug('Pankaj'+days+':'+hours+':'+minutes+':'+seconds);
        return days+':'+hours+':'+minutes+':'+seconds;
    }
    public Long  convertHours(Long intSeconds, Long days)
    {
        Long minutes = convertMinutes(intSeconds);
        Long hours = minutes/minutesPerHour;
        return hours - (days*hourperday);
    }
    public Long convertDay(Long intSeconds)
    {
        Long minutes = convertMinutes(intSeconds);
        Long hours = minutes/minutesPerHour;
        Long days = hours/hourperday;
        
        return days;
    }
    public Long  convertMinutes(Long intSeconds)
    {
        return intSeconds/secondsPerMinute;
    }
    public Long  getRemainingSeconds(Long intTotalSeconds)
    {
        return intTotalSeconds/secondsPerMinute;
    }
    public Long  getRemainingMinutes(Long intSeconds, Long days, Long hours)
    {
        Long intTotalMinutes = convertMinutes(intSeconds);
        return intTotalMinutes -  ((days*hourperday*minutesPerHour) + (hours*minutesPerHour));
    }
    public String getCountDown(long uptime)
    {
        String result; 
        long days;
        long hours;
        long minutes;
        long secs;
        if(uptime <= 0) 
        {
            result = '00:00:00:00';
        }
        else
        {   
            secs = uptime/1000; 
            days = secs/(24 * 3600);
            secs =  Math.mod(secs, 24 * 3600);
            hours = secs/3600;
            secs = Math.mod(secs,3600);
            minutes = secs/60;
            secs = Math.mod(secs,60);
            if(Math.round(secs) > 0) 
            {
                //secs += Math.round(secs) ; Commented this line for defect : 010416
                secs = Math.round(secs);
            }   
            if(Math.round(secs) <= 0) 
            {
                secs += 00;
            }
            result =  days + ':' + hours + ':' + minutes + ':' + secs;
        }
        return result;  
    }
}