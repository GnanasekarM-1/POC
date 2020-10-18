public with sharing class SVMX_Constant_Utils {

    public string strUserTrunkId = '';
    public string strUserTrunkName = '';
    private static SVMX_Constant_Utils instance = null;
    
    public SVMX_Constant_Utils(){
        //Get Inveontory loation of Technician  
        try{
            List<SVMXC__Service_Group_Members__c> lstTech = [Select SVMXC__Inventory_Location__c, SVMXC__Inventory_Location__r.Name From SVMXC__Service_Group_Members__c Where SVMXC__Salesforce_User__c =: userinfo.getUserId() AND SVMXC__Inventory_Location__c != NULL limit 1];
            if(lstTech != NULL && lstTech.size() > 0){
                strUserTrunkId = lstTech[0].SVMXC__Inventory_Location__c;
                if(lstTech[0].SVMXC__Inventory_Location__r.Name != NULL){
                    strUserTrunkName = lstTech[0].SVMXC__Inventory_Location__r.Name;
                }
            }
        }
        catch(Exception ex){
            
        }   
    }
    
    public static SVMX_Constant_Utils getInstance(){
        if(instance == null) 
            instance = new SVMX_Constant_Utils();
        return instance;
    }
    //Return Salesforce ID of Tachnician location for SVMX.USERTRUNK constant
    public string getSVMXUserTrunkId(){
        return strUserTrunkId;
    }
    //Return Name of Tachnician location for SVMX.USERTRUNK constant
    public string getSVMXUserTrunkName(){
        return strUserTrunkName;
    }
    //Return value of the SVMX.CURRENTUSER
    public string getSVMXCurrentUserId(){
        return userinfo.getUserId();
    }
    //Return value of the SVMX.CURRENTUSER as UserName 
    public string getSVMXCurrentUserName(){
        return userinfo.getUserName();
    }
    public string replaceConstants(String whereClause, map<String,String> mapConstants){
        whereClause = whereClause.replace('SVMX.CURRENTUSER',  String.escapeSingleQuotes(getSVMXCurrentUserName()));
        whereClause = whereClause.replace('SVMX.USERTRUNK',  getSVMXUserTrunkName());
        if(mapConstants != null && mapConstants.size() > 0){
            for(String str : mapConstants.keyset()){
                whereClause = whereClause.replace(str, mapConstants.get(str));
            }
        }   
        return whereClause;
    }
    
    // Get the User Time Zone Offset
    public String getUserTimezoneOffset(){
        String OffsetSign = '+', Hours = '00', Minutes = '00';
        
        try{
            Integer TimeZoneOffsetMiliSec = UserInfo.getTimeZone().getOffset(DateTime.now());
            if(TimeZoneOffsetMiliSec < 0) OffsetSign = '-';
            Integer TimeZoneOffsetMinutes = Integer.valueOf((math.abs(TimeZoneOffsetMiliSec))/60000);
            if(TimeZoneOffsetMinutes >= 60){
                Hours = String.valueOf(TimeZoneOffsetMinutes/60);
                Minutes = String.valueOf(math.mod(TimeZoneOffsetMinutes, 60));
            }
            else
                Minutes = String.valueOf(TimeZoneOffsetMinutes);
            
            if(Hours != NULL && Hours.length() < 2)
                Hours = '0' + Hours;
                
            if(Minutes != NULL && Minutes.length() < 2)
                Minutes = '0' + Minutes;
        }
        catch(Exception ex){
            System.debug('Error: '+ ex.getMessage());
        }
        String retOffset = OffsetSign + Hours + ':' + Minutes;
        System.debug('Offset: '+ retOffset);
        return retOffset;
    }

    public Map<String,String> getDecimalSeparator(){
        Decimal decValue = 1000.11;
        String userLocaleFormat = decValue.format();
        String thousandSeparator = userLocaleFormat.substring(1,2);
        String decimalSeparator = userLocaleFormat.substring(5,6);
        return new Map<String,String>{'TS' => thousandSeparator, 'DS' => decimalSeparator};
    }
}