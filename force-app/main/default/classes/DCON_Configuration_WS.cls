global without sharing class DCON_Configuration_WS
{
    //Method to return exemptions
    public class SVMXException extends Exception {}

    //Wrapper class for passing key values
    global class SVMX_StringMap{
        webservice String woViewType {get; set;} // This member indicate whether it's Queue or View
        webservice String columnInfo {get;set;} // This member 
        webservice String Key{get; set;}
        webservice String Value{get; set;}
        webservice List<String> ValueList{get; set;}
        webservice DateTime DateTimeValue{get; set;}
        webservice Date DateValue{get; set;}
        webservice String fieldsToNull{get; set;}
        webservice Dcon_DeployUserSetting.DCUserSettings dcSetting{get; set;}
        
        global SVMX_StringMap(String k, String v ){
            this.Key = k;
            this.Value = v;
        }
    }
    //Wrapper to send BusinessHour Attributes
    global class SVMX_BuisnessHourAttribute{
        webservice String Day{get; set;}
        webservice String StartTime{get; set;}
        webservice String EndTime{get;set;}
        global SVMX_BuisnessHourAttribute(string d, string s, string e){
            this.Day = d;
            this.StartTime = s;
            this.EndTime = e;
        }
    }
    /*global class SVMX_Response{
    webservice list<string> WoFields{get; set;}
    webservice list<string> Evntfields{get; set;}
    }*/
    /*
     *Type : Global Method
     *Used : Utilities
     *Desc : Get a map of all available timezones
     */
    WebService static List<SVMX_StringMap> DCON_GetAllTimeZone_WS(String UserId){
        List<SVMX_StringMap> timeZone_M = new List<SVMX_StringMap>();
        
        Schema.DescribeFieldResult CT =user.TimeZoneSidKey.getDescribe();
        List<Schema.PicklistEntry> P = CT.getPicklistValues();

        SVMX_StringMap tZone;
        for(Schema.PicklistEntry pl: P){
            tZone = new SVMX_StringMap(pl.getValue(),pl.getLabel());
            timeZone_M.add(tZone);
        }
        system.debug(LoggingLevel.Error, 'Returning TimeZones : ' + timeZone_M);
        return timeZone_M;
    }

    /*
     *Type : Webservice Method
     *Desc : Gets local date format
     */
    WebService static String DCON_GetLocalDate_WS(String UserId){
        DCON_Utils utils = new DCON_Utils();
        return utils.SVMX_getLocalDateFormat();
    }

    /*
     *Type : Webservice Method
     *Desc : Gets whether user is dispatch manager or technician
     */
    WebService static String DCON_GetUserType_WS(String UserId){
        String userType;
        try
        {
        List<SVMXC__Dispatcher_Access__c> AvailTeams = new List<SVMXC__Dispatcher_Access__c>();
        String QueryStr = 'Select SVMXC__Service_Team__c From SVMXC__Dispatcher_Access__c where SVMXC__Dispatcher__c =:UserId';
        AvailTeams = Database.query(QueryStr);
        if(AvailTeams.size() > 0)
        userType = 'Dispatcher';
        else
        userType = 'Technician';
        }
        catch (Exception ex){
            throw new SVMXException(ex.getmessage());
        }
        return userType;
    }


    //This method retrieves all the display tags to be used in Dispatch console user interface for the given user?s language and sends the result as an array of objects.
    WebService static List<COMM_TagWebServices.TagsMap> DCON_Retrieve_Display_Tags_WS(String UserId){
        List<COMM_TagWebServices.TagsMap> TagListValueM = COMM_TagWebServices.TagdataforSubmodule('DCON001');
        List<COMM_TagWebServices.TagsMap> DCON005TagListValueM = COMM_TagWebServices.TagdataforSubmodule('DCON005');
        List<COMM_TagWebServices.TagsMap> DCON006TagListValueM = COMM_TagWebServices.TagdataforSubmodule('DCON006');
        TagListValueM.addAll(DCON005TagListValueM);
        TagListValueM.addAll(DCON006TagListValueM);
        return TagListValueM;
    }
        
    //This method retrieves all the settings to be used in Dispatch console userand sends the result as an array of objects.
    WebService static List<SVMX_StringMap> DCON_Retrieve_Settings_WS(String UserId){
            List<SVMX_StringMap> SubModSetting = new List<SVMX_StringMap>();
            try
            {
                list<String> listSettingId = new list<String>(); 
                map<string, Map<String, String>> MapSetting = new map<string, Map<String, String>>(); // The Result List
                SVMXC.COMM_Utils_ManageSettings utils = new SVMXC.COMM_Utils_ManageSettings();
                listSettingId.add('DCON001');
                listSettingId.add('DCON005');
                listSettingId.add('DCON006');
                listSettingId.add('OMAX003');
                listSettingId.add('SLAT003');
                MapSetting = utils.SVMX_getSettingList(listSettingId);
                system.debug('TEST TAGS'+MapSetting);
                
                SVMX_StringMap SS;
                for(String k: MapSetting.keySet())
                {
                    if(k=='DCON001')
                    {
                        for(String id: MapSetting.get('DCON001').keySet())
                        {
                            SS = new SVMX_StringMap(id, MapSetting.get('DCON001').get(id));
                            SubModSetting.add(SS);
                            system.debug('SubMod Setting'+SS);
                        }
                    }
                    else if(k=='DCON005')
                    {
                        for(String id: MapSetting.get('DCON005').keySet())
                        {
                            SS = new SVMX_StringMap('DCON005_'+id, MapSetting.get('DCON005').get(id));
                            SubModSetting.add(SS);
                            system.debug('SubMod Setting'+SS);
                        }
                    }
                    else if(k=='DCON006')
                    {
                        for(String id: MapSetting.get('DCON006').keySet())
                        {
                            SS = new SVMX_StringMap('DCON006_'+id, MapSetting.get('DCON006').get(id));
                            SubModSetting.add(SS);
                            system.debug('SubMod Setting'+SS);
                        }
                    }
                    else if(k=='OMAX003')
                    {
                        for(String id: MapSetting.get('OMAX003').keySet())
                        {
                            if('SET042'.equalsIgnoreCase(id) == true || 'SET043'.equalsIgnoreCase(id)|| 'SET044'.equalsIgnoreCase(id)|| 'SET047'.equalsIgnoreCase(id))
                            {
                                SS = new SVMX_StringMap('OMAX003_'+id, MapSetting.get('OMAX003').get(id));
                                SubModSetting.add(SS);
                                system.debug('SubMod Setting'+SS);
                            }
                        }
                    }
                    else if(k=='SLAT003')
                    {
                        for(String id: MapSetting.get('SLAT003').keySet())
                        {
                            if('SET001'.equalsIgnoreCase(id) == true)
                            {
                                SS = new SVMX_StringMap('SLAT003_'+id, MapSetting.get('SLAT003').get(id));
                                SubModSetting.add(SS);
                                system.debug('SubMod Setting'+SS);
                            }
                        }
                    }
                    else
                    {                   
                        for(String id: MapSetting.get(k).keySet())
                        {
                            SS = new SVMX_StringMap(id, MapSetting.get(k).get(id));
                            SubModSetting.add(SS);
                            system.debug('SubMod Setting'+SS);
                        }
                    }
                            
                }
                
            }
            catch (Exception ex)
            {
                throw new SVMXException(ex.getmessage());
            }
            
            return   SubModSetting; 
    }

    //This method retrieves the current user?s UI settings for dispatch console. 
    //If not available, it returns the org-wide default settings for dispatch console UI.
    WebService static String DCON_Retrieve_User_Settings_WS(String UserId){
        String UserSettings = null;
        dom.Document doc = null;
        
        try{
            // Read User Settings from Dispatch Console Settings field in User record
            User userdetail = new User();
            userdetail = [SELECT SVMXC__Dispatch_Console_Settings__c from User where Id= :UserId];
            if(userdetail.SVMXC__Dispatch_Console_Settings__c != NULL){
                UserSettings = userdetail.SVMXC__Dispatch_Console_Settings__c;
                try{
                    doc = new dom.Document();
                    doc.load(UserSettings);
                }
                catch(XmlException xe){
                    doc = null;
                    UserSettings = null;
                }
            }
            
            // If User record does not have valid User Settings, use Custom UI Settings if they exist
            if(UserSettings == NULL){
                StaticResource customStaticResource = new StaticResource();
                try{
                    customStaticResource = [Select Name, Body From StaticResource where Name =  'DC_Custom_UI_Settings' limit 1];
                    UserSettings = customStaticResource.Body.toString();
                    doc = new dom.Document();
                    doc.load(UserSettings);
                }
                catch(QueryException qe){
                    //Do nothing - this exception is thrown when DC_Custom_UI_Settings does not exist
                }
                catch(XmlException xe){
                    doc = null;
                    UserSettings = null;
                }
            }
            
            // If Custom UI Settings do not exist, use managed UI Settings
            if(UserSettings == NULL){
                StaticResource managedStaticResource = new StaticResource();
                try{
                    managedStaticResource = [Select Name, Body From StaticResource where Name =  'DCON_UI_Settings' limit 1];
                    UserSettings = managedStaticResource.Body.toString();
                    doc = new dom.Document();
                    doc.load(UserSettings);
                }
                catch(QueryException qe){
                    //Do nothing - this exception is thrown when DCON_UI_Settings does not exist, which is not possible
                }
                catch(XmlException xe){
                    doc = null;
                    UserSettings = null; // Improbable, as managed UI Settings should be valid
                }
            }

            if(UserSettings == NULL) // Improbable, as at least managed UI Settings should exist and be valid
                UserSettings = 'User Settings not available for this organization. Please contact system administrator.';
        }
        catch (DmlException ex){
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch (Exception ex){
            throw new SVMXException(ex.getmessage());
        }
        return UserSettings;
    }

    WebService static String DCON_Update_User_Settings_WS(String UserId, String UserSettings){
        String StatusMessage;
        if(UserSettings==NULL)
        throw new SVMXException('No user setting passed for this user');

        try{
            User userdetail = new User();
            userdetail = [SELECT SVMXC__Dispatch_Console_Settings__c from User where Id= :UserId];
            userdetail.SVMXC__Dispatch_Console_Settings__c= UserSettings;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(userdetail, COMM_SecurityUtils.Access.Updateable)){
                update userdetail; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            StatusMessage='TAG173';
        }
        catch (DmlException ex){
                 throw new SVMXException(ex.getDmlMessage(0));
    }
        catch (Exception ex){
            throw new SVMXException(ex.getmessage());
        }
        return UserSettings;
    }

    WebService static String DCON_Restore_DCSettings_WS(String UserId){
        String StatusMessage;
        String UserSettings;
        try{
            List<StaticResource> DefaultSetting = new List<StaticResource>();

            DefaultSetting = [Select Name, Body From StaticResource where Name= 'DC_Custom_UI_Settings' or Name= 'DCON_UI_Settings'];
            if(DefaultSetting.isEmpty() == false){
                for(StaticResource sr: DefaultSetting){
                    if(sr.Name == 'DC_Custom_UI_Settings' || UserSettings == NULL)
                        UserSettings = sr.Body.toString();
                }
            }
            
            if(UserSettings == NULL)
                throw new SVMXException('No user setting found for this organization');
            else
                DCON_Configuration_WS.DCON_Update_User_Settings_WS(UserId, UserSettings);
            StatusMessage='TAG175';
        }
        catch (DmlException ex){
                 throw new SVMXException(ex.getDmlMessage(0));
    }
        catch (Exception ex){
            throw new SVMXException(ex.getmessage());
        }
        return StatusMessage;
    }
    //Method to send Buisness hour Attributes - created by Akash on 20th May 2010
    WebService static DateTime getDateTimeInTimezone(Date givenDate, Time givenTime, String timeZoneSidKey){
        DateTime tempDateTime = DateTime.newInstanceGmt(givenDate, givenTime);
        String gmtDateTimeStr = tempDateTime.formatGmt('yyyy-MM-dd HH:mm:ss');
        String tmzDateTimeStr = tempDateTime.format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey);
        DateTime gmtDateTime = DateTime.valueOfGmt(gmtDateTimeStr);
        DateTime tmzDateTime = DateTime.valueOfGmt(tmzDateTimeStr);
        Long gmtMillisecs = gmtDateTime.getTime();
        Long tmzMillisecs = tmzDateTime.getTime();
        Integer tmzOffsetMins = Integer.valueOf(String.valueOf((gmtMillisecs - tmzMillisecs)/60000));
        DateTime retDateTime = gmtDateTime.addMinutes(tmzOffsetMins);
        // Check if the givenTime and returnedTime are the same.
        // If not (can happen during DST transition points), adjust the returned date time.
        try
        {
        String[] convTimeStr = retDateTime.format('HH:mm:ss', timeZoneSidKey).split(':');
        Time convTime = Time.newInstance(Integer.valueOf(convTimeStr[0]), Integer.valueOf(convTimeStr[1]), Integer.valueOf(convTimeStr[2]), 0);
        if (givenTime != convTime) {
            Integer givenHrMin = (givenTime.hour() * 60) + givenTime.minute();
            Integer convHrMin = (convTime.hour() * 60) + convTime.minute();
            Integer diff = givenHrMin - convHrMin;
            retDateTime = retDateTime.addMinutes(diff);
        }
        }
        catch (Exception ex){
            throw new SVMXException(ex);
        }
        //system.debug('Returned Date Time in ' + timeZoneSidKey + ' is: ' + retDateTime);
        return retDateTime;// Returns DateTime in Given TZ
    }

    /***** THIS SERVICE HAS TO BE DEPRECATED ONCE SUPPORT FOR LEGACY DC IS DISCONTINUED AS WE HAVE INTRODUCED NEW SERVICE DCON_EventWarnings_WS FOR HANDLING WARNINGS *****/
    WebService static boolean EventExistinBusinessHour(string TechId, DateTime StrtDate, String TimZonKey){
        string BHId;
        Boolean EvntExist = false;
    try
    {
        BusinessHours bh = new BusinessHours();
        SVMXC__Territory__c Teritory = new SVMXC__Territory__c();
        list<SVMX_BuisnessHourAttribute> BHAttribute = new list<SVMX_BuisnessHourAttribute>();  
        SVMXC__Service_Group_Members__c Tech = [Select SVMXC__Working_Hours__c,SVMXC__Working_Hours__r.IsActive, SVMXC__Service_Territory__c, Id From SVMXC__Service_Group_Members__c where Id=:TechId];
        if(Tech.SVMXC__Working_Hours__c!=null && Tech.SVMXC__Working_Hours__r.IsActive){
            BHId = Tech.SVMXC__Working_Hours__c;
        }
        else{
            if(Tech.SVMXC__Service_Territory__c!=null)
                Teritory = [Select SVMXC__Territory_s_Business_Hours__c,SVMXC__Territory_s_Business_Hours__r.IsActive, Id From SVMXC__Territory__c where Id=:Tech.SVMXC__Service_Territory__c];
            if(Teritory.SVMXC__Territory_s_Business_Hours__c!=null && Teritory.SVMXC__Territory_s_Business_Hours__r.IsActive){
                BHId = Teritory.SVMXC__Territory_s_Business_Hours__c;
            }
        }
        if(BHId!=null)
            bh = [SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where IsActive = true and Id=:BHId];
        else
            bh = [SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where IsActive = true and IsDefault = true];
        
        if(bh!=null){                   
            DateTime StartDateTime = getDateTimeInTimezone(StrtDate.dateGMT(),StrtDate.timeGMT(),TimZonKey);        
            DateTime newDatTime = BusinessHours.addGmt(bh.id,StartDateTime,1L);         
            dateTime onenewDT = BusinessHours.addGmt(bh.id,newDatTime,-1L); 
            system.debug('StartDateTime ,newDatTime,onenewDT '+StartDateTime+' , '+newDatTime+' , '+onenewDT) ; 
            if(onenewDT==StartDateTime){
                EvntExist = true;
            }
            else{
                EvntExist = false;
            }                   
        }  
    }
    catch (Exception ex){
            throw new SVMXException(ex);
        }     
        
        return EvntExist;
    }

    WebService static list<SVMX_BuisnessHourAttribute> GetEvent_BuisnessHour(string TechId){
        list<SVMX_BuisnessHourAttribute> BHAttribute = new list<SVMX_BuisnessHourAttribute>();  
        /*string BHId;
        string Day;
        string starttime;
        string endtime;
        BusinessHours bh = new BusinessHours();
        SVMXC__Territory__c Teritory = new SVMXC__Territory__c();   
        SVMXC__Service_Group_Members__c Tech = [Select SVMXC__Working_Hours__c,SVMXC__Working_Hours__r.IsActive, SVMXC__Service_Territory__c, Id From SVMXC__Service_Group_Members__c where Id=:TechId];
        if(Tech.SVMXC__Working_Hours__c!=null && Tech.SVMXC__Working_Hours__r.IsActive){
            BHId = Tech.SVMXC__Working_Hours__c;
        }
        else{
            if(Tech.SVMXC__Service_Territory__c!=null)
                Teritory = [Select SVMXC__Territory_s_Business_Hours__c,SVMXC__Territory_s_Business_Hours__r.IsActive, Id From SVMXC__Territory__c where Id=:Tech.SVMXC__Service_Territory__c];
            if(Teritory.SVMXC__Territory_s_Business_Hours__c!=null && Teritory.SVMXC__Territory_s_Business_Hours__r.IsActive){
                BHId = Teritory.SVMXC__Territory_s_Business_Hours__c;
            }
        }
        if(BHId!=null)
            bh = [SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where IsActive = true and Id=:BHId];
        else
            bh = [SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where IsActive = true and IsDefault = true];
        if(bh!=null){
            for(integer i=0;i<7;i++){
                if(i==0){  
                    if(bh.SundayStartTime==null && bh.SundayEndTime==null){
                        Day = 'Sunday';
                        starttime = '';
                        endtime = '';
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                    else{
                        Day = 'Sunday';
                        starttime = string.valueOf(bh.SundayStartTime);
                        endtime = string.valueOf(bh.SundayEndTime);
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                }
                if(i==1){  
                    if(bh.MondayStartTime==null && bh.MondayEndTime==null){
                        Day = 'Monday';
                        starttime = '';
                        endtime = '';
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                    else{
                        Day = 'Monday';
                        starttime = string.valueOf(bh.MondayStartTime);
                        endtime = string.valueOf(bh.MondayEndTime);
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                }
                if(i==2){  
                    if(bh.TuesdayStartTime==null && bh.TuesdayEndTime==null){
                        Day = 'Tuesday';
                        starttime = '';
                        endtime = '';
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                    else{
                        Day = 'Tuesday';
                        starttime = string.valueOf(bh.TuesdayStartTime);
                        endtime = string.valueOf(bh.TuesdayEndTime);
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                }
                if(i==3){  
                    if(bh.WednesdayStartTime==null && bh.WednesdayEndTime==null){
                        Day = 'Wednesday';
                        starttime = '';
                        endtime = '';
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                    else{
                        Day = 'Wednesday';
                        starttime = string.valueOf(bh.WednesdayStartTime);
                        endtime = string.valueOf(bh.WednesdayEndTime);
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                }
                if(i==4){  
                    if(bh.ThursdayStartTime==null && bh.ThursdayEndTime==null){
                        Day = 'Thursday';
                        starttime = '';
                        endtime = '';
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                    else{
                        Day = 'Thursday';
                        starttime = string.valueOf(bh.ThursdayStartTime);
                        endtime = string.valueOf(bh.ThursdayEndTime);
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                }
                if(i==5){  
                    if(bh.FridayStartTime==null && bh.FridayEndTime==null){
                        Day = 'Friday';
                        starttime = '';
                        endtime = '';
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                    else{
                        Day = 'Friday';
                        starttime = string.valueOf(bh.FridayStartTime);
                        endtime = string.valueOf(bh.FridayEndTime);
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                }
                if(i==6){  
                    if(bh.SaturdayStartTime==null && bh.SaturdayEndTime==null){
                        Day = 'Saturday';
                        starttime = '';
                        endtime = '';
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                    else{
                        Day = 'Saturday';
                        starttime = string.valueOf(bh.SaturdayStartTime);
                        endtime = string.valueOf(bh.SaturdayEndTime);
                        SVMX_BuisnessHourAttribute b = new SVMX_BuisnessHourAttribute(Day,starttime,endtime);
                        BHAttribute.add(b);
                    }
                }           
            }
        }*/
        return BHAttribute;         
    }

    global class SVMX_Response{
    webservice list<string> WoFields{get; set;}
    webservice list<string> Evntfields{get; set;}
    webservice List<SVMX_StringMap> DispatcherList{get;set;} //introduced 29/08/2011 - hh - Reason:parameter needed to hold and return response dispatcher List.
    webservice List<SObject> RecordList{get; set;}
    webservice Boolean success{get; set;}
    webservice string message{get; set;}
    }

    webservice static SVMX_Response SVMX_getDispatcherList_WS(SVMX_StringMap request){
        string TeamLabel = string.escapeSingleQuotes(System.Label.DCON001_TAG314);
        string TerritoryLabel = string.escapeSingleQuotes(System.Label.DCON001_TAG315);
        string SuperDispatcherUserId = request.value;
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> svmxSettingList = new Map<String,String>();
        svmxSettingList = commSettings.SVMX_getSettingList('DCON001');
        String strAllowOverRide;
        if(svmxSettingList.get('SET053') != null)
            strAllowOverRide = string.escapeSingleQuotes(svmxSettingList.get('SET053'));
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
        SVMX_Response DispatcherListResponse = new SVMX_Response();

        //Build List<StringMap> and put it in DispatcherListResponse.StringMap
        List<SVMX_StringMap> LstStringMap = new List<SVMX_StringMap>();
        for(Id TeamId:mapTeamId_LstUserId.keyset())
        {
            SVMX_StringMap ResultStrMap = new SVMX_StringMap(TeamId,null);
            ResultStrMap.valueList = new List<String>();
            ResultStrMap.valueList.addAll(mapTeamId_LstUserId.get(TeamId));
            ResultStrMap.value = TeamLabel + ' ' +mapTeam_Terr_Id_Name.get(TeamId);
            LstStringMap.add(ResultStrMap);
        }
        for(Id TerritoryId:mapTerritoryId_LstUserId.keyset())
        {
            SVMX_StringMap ResultStrMap = new SVMX_StringMap(TerritoryId,null);
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

    webservice static SVMX_Response SVMX_DeployUIConfiguration_WS(SVMX_StringMap request)
    {
        /*String SuperDispatcherId = request.value;
        SVMX_Response response = new SVMX_Response();
        if(request.ValueList != null)
        {
            User UserRec = [Select SVMXC__Dispatch_Console_Settings__c from User where Id = :SuperDispatcherId];
            List<String> LstUserIds = request.ValueList;
            List<User> AllDispatchers = database.query('Select Id, SVMXC__Dispatch_Console_Settings__c from User where Id IN :LstUserIds');
            for(User DispatcherRec:AllDispatchers)
            {
                DispatcherRec.SVMXC__Dispatch_Console_Settings__c = UserRec.SVMXC__Dispatch_Console_Settings__c;
            }
            
            try
            {
                if(LstUserIds.size() >0) 
                {
                    update AllDispatchers;
                    response.success = true;
                }
                else
                    response.success = false;
            }
            catch(exception ex)
            {
                response.success = false;
            }
        }*/
        SVMX_Response response = new SVMX_Response();
        //System.debug(logginglevel.warn,'dcSetting:  '+request.dcSetting);
        //System.debug(logginglevel.warn,'request:  '+request);
        response = Dcon_DeployUserSetting.deploySelectivelyDCUSerSetting(request);
       // response = testDCON_DeployUserSetting.deploySelectivelyDCUSerSetting(request);
        return response;
    }

    WebService static SVMX_Response DCON_getObjectFieldList_WS(){
            SVMX_Response response = new SVMX_Response();
            SVMXC.COMM_Utils comutils = new SVMXC.COMM_Utils();
            set<String> whitelistedObjects = new set<String>();
            Map<String,Boolean> whitelist = new Map<String,Boolean>();
            whitelist = comutils.SVMX_getPermittedStandardObjectList();
            list<string> lstwofields = new list<string>();
            list<string> lstevtfields = new list<string>();
            for(String whitefield: whitelist.keySet())
            {
                whitelistedObjects.add(whitefield);
            }
            Map<String, SObjectField> objWorkOrderFieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
            for (String fieldKey : objWorkOrderFieldMap.keySet())
            {
                Schema.SObjectField fsObj = objWorkOrderFieldMap.get(fieldKey); 
                Schema.DescribeFieldResult field = fsObj.getDescribe();
                if(field.getType()== Schema.DisplayType.Reference)
                {
                    Schema.DescribeSObjectResult obejctDef = field.getReferenceTo()[0].getDescribe();
                     if(whitelistedObjects.contains(obejctDef.getName()))
                     lstwofields.add(field.getName());
                }
                else
                {
                     lstwofields.add(field.getName());
                }
            }

            lstevtfields.add('ActivityDate');
            lstevtfields.add('ActivityDateTime');
            lstevtfields.add('DurationInMinutes');
            lstevtfields.add('Subject');
            lstevtfields.add('Description');
            lstevtfields.add('WhatId');
            lstevtfields.add('StartDateTime');
            lstevtfields.add('EndDateTime');
            lstevtfields.add('Location');
            //039583 - added following line
            lstevtfields.add('Type');
            
            Map<String, Schema.SObjectField> mapEventFieldDef = new Map<String, Schema.SObjectField>();
            mapEventFieldDef = Event.SObjectType.getDescribe().fields.getMap();

            Map<String, Schema.SObjectField> mapSVMXEventFieldDef = new Map<String, Schema.SObjectField>();
            mapSVMXEventFieldDef = SVMX_Event__c.SObjectType.getDescribe().fields.getMap();
            
            for (String eventField : mapEventFieldDef.keySet()) 
            {
                 Schema.SObjectField fieldDetail = mapSVMXEventFieldDef.get(eventField);
                 if(fieldDetail != null)
                  {
                    Schema.DescribeFieldResult f1 = fieldDetail.getDescribe();
                    Schema.SObjectField fsObj = mapEventFieldDef.get(eventField);
                    Schema.DescribeFieldResult f = fsObj.getDescribe(); 
                    if(f.getName() == f1.getName() && f.getType() == f1.getType() && f.getLength() == f1.getLength())
                    {
                        lstevtfields.add(f.getName());
                    }
                  }
            }
            response.Evntfields = lstevtfields;
            response.WoFields = lstwofields;
            return response;
    }
    
    /**
     *
     */
    global class DCEventWarningReq_WP
    {
        Webservice String WorkOrderId {get; set;}
        Webservice String TechId {get; set;}
        Webservice DateTime EventStartDateTime {get; set;}
        Webservice DateTime EventEndDateTime {get; set;}
        Webservice String timeZone {get; set;}
        Webservice boolean isMachineAccessHrsEnabled {get; set;}
        Webservice boolean isBusinessHrsEnabled {get; set;}
        
        public DCEventWarningReq_WP(String WoId, 
                                    String TechnicianId, 
                                    DateTime eventStDt, 
                                    DateTime eventEdDt, 
                                    String timZone,
                                    boolean isMacAccessHrs,
                                    boolean isBussHrs)
        {
            this.WorkOrderId = WoId;
            this.TechId = TechnicianId;
            this.EventStartDateTime = eventStDt;
            this.EventEndDateTime = eventEdDt;
            this.timeZone = timZone;
            this.isMachineAccessHrsEnabled = isMacAccessHrs;
            this.isBusinessHrsEnabled = isBussHrs;
        }
    
        public DCEventWarningReq_WP() {}
    }
    
    /**
     *
     */
    global class DCEventWarningResp_WP 
    {
        Webservice DateTime STOutsideBusinessHrs {get;set;}
        Webservice DateTime ETOutsideBusinessHrs {get;set;}
        Webservice DateTime STOutsideMachineAccesshrs {get; set;}
        Webservice DateTime ETOutsideMachineAccesshrs {get; set;}
        
        public DCEventWarningResp_WP(DateTime StartDateOTBussHrs, 
                                    DateTime EndDateOTBussHrs, 
                                    DateTime StartDateOTMacAccesHhrs, 
                                    DateTime EndDateOTMacAccessHrs)
        {
            this.STOutsideBusinessHrs = StartDateOTBussHrs;
            this.ETOutsideBusinessHrs = EndDateOTBussHrs;
            this.STOutsideMachineAccesshrs = StartDateOTMacAccesHhrs;
            this.ETOutsideMachineAccesshrs = EndDateOTMacAccessHrs;
        }
        public DCEventWarningResp_WP() {}           
    }
    
    /**
     * Method Name      :   DCEventWarningResp_WP
     * Parameters       :   DCEventWarningReq_WP wrapper as a request
     * Description      :   This method will calculate if the given events startdate and enddate are falling outside of business hours 
                            OR outside machine access hours startdate and enddate respectively and returns the start datetime and/or 
                            end datetime of  business hours and/or machine access hours
     * Return Value     :   DCEventWarningResp_WP wrapper as a response
     */
    WebService static DCEventWarningResp_WP DCON_EventWarnings_WS(DCEventWarningReq_WP request)
    {
        String BHId;
        String PreferredBHId;
        DCEventWarningResp_WP resp = new DCEventWarningResp_WP();
        DCON_Utils utils = new DCON_Utils();
        
        try
        {
            BusinessHours bh = new BusinessHours();
            BusinessHours prefBh = new BusinessHours();
            SVMXC__Territory__c Teritory = new SVMXC__Territory__c();
            list<SVMX_BuisnessHourAttribute> BHAttribute = new list<SVMX_BuisnessHourAttribute>();  
            
            SVMXC__Service_Group_Members__c TechRec = [SELECT SVMXC__Working_Hours__c,SVMXC__Working_Hours__r.IsActive, SVMXC__Service_Territory__c, Id FROM SVMXC__Service_Group_Members__c WHERE Id =: request.TechId];
                
            SVMXC__Service_Order__c WorkOrderRec = [SELECT Id, SVMXC__Preferred_Business_Hours__c, SVMXC__Preferred_Business_Hours__r.IsActive FROM SVMXC__Service_Order__c WHERE Id =: request.WorkOrderId];
            
            if(request.isBusinessHrsEnabled)
            {               
                //Validations for checking if an event's start/end time is outside technician business access hours
                if(TechRec.SVMXC__Working_Hours__c != null && TechRec.SVMXC__Working_Hours__r.IsActive)
                {
                    BHId = TechRec.SVMXC__Working_Hours__c;
                }
                else
                {
                    if(TechRec.SVMXC__Service_Territory__c != null)
                    {
                        Teritory = [Select SVMXC__Territory_s_Business_Hours__c,SVMXC__Territory_s_Business_Hours__r.IsActive, Id From SVMXC__Territory__c where Id=:TechRec.SVMXC__Service_Territory__c];
                    }
                    if(Teritory.SVMXC__Territory_s_Business_Hours__c != null && Teritory.SVMXC__Territory_s_Business_Hours__r.IsActive)
                    {
                        BHId = Teritory.SVMXC__Territory_s_Business_Hours__c;
                    }
                }
                
                if(BHId != null)
                {
                    bh = [SELECT MondayStartTime, MondayEndTime,
                            TuesdayStartTime, TuesdayEndTime,
                            WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime,
                            FridayStartTime, FridayEndTime,                     
                            SaturdayStartTime, SaturdayEndTime,
                            SundayStartTime, SundayEndTime, 
                            IsDefault, IsActive, Id,
                            TimeZoneSidKey
                            FROM BusinessHours 
                            WHERE IsActive = true 
                            AND Id =: BHId];
                }
                else
                {
                    bh = [SELECT MondayStartTime, MondayEndTime,
                            TuesdayStartTime, TuesdayEndTime,
                            WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime,
                            FridayStartTime, FridayEndTime,
                            SaturdayStartTime, SaturdayEndTime,
                            SundayStartTime, SundayEndTime, 
                            IsDefault, IsActive, Id,
                            TimeZoneSidKey
                            FROM BusinessHours 
                            WHERE IsActive = true 
                            AND IsDefault = true];
                }

                if(bh != null)
                {  
                    Date dt = request.EventStartDateTime.dateGMT();
                    List<DateTime> lstbHDt =  utils.getBHStartEndDateTime(request.timeZone, dt, bh);
                    
                    if(lstbHDt.size() > 0)
                    {
                        if(lstbHDt[0].dateGMT() > request.EventStartDateTime.dateGMT())
                        {
                            lstbHDt.clear();
                            lstbHDt =  utils.getBHStartEndDateTime(request.timeZone, dt.addDays(-1), bh);
                        }
                        else if(lstbHDt[0].dateGMT() < request.EventStartDateTime.dateGMT())
                        {
                            lstbHDt.clear();
                            lstbHDt =  utils.getBHStartEndDateTime(request.timeZone, dt.addDays(1), bh);
                        }
                    }
                                            
                    if(!utils.GetHolidays(bh, dt))
                    {
                        if(lstbHDt.size() > 0)
                        {
                            if(request.EventStartDateTime < lstbHDt[0])
                                resp.STOutsideBusinessHrs = lstbHDt[0];
                            
                            if(request.EventEndDateTime > lstbHDt[1])
                                resp.ETOutsideBusinessHrs = lstbHDt[1];
                        }
                    }
                } 
            }
            
            if(request.isMachineAccessHrsEnabled)
            {
                //Validations for checking if an event's start/end time is outside machine access hours
                if(WorkOrderRec.SVMXC__Preferred_Business_Hours__c != null && WorkOrderRec.SVMXC__Preferred_Business_Hours__r.IsActive)
                {
                    PreferredBHId = WorkOrderRec.SVMXC__Preferred_Business_Hours__c;
                }
                
                if(PreferredBHId != null)
                {
                    prefBh = [SELECT MondayStartTime, MondayEndTime,
                                TuesdayStartTime, TuesdayEndTime,
                                WednesdayStartTime, WednesdayEndTime,
                                ThursdayStartTime, ThursdayEndTime,
                                FridayStartTime, FridayEndTime,
                                SaturdayStartTime, SaturdayEndTime,
                                SundayStartTime, SundayEndTime, 
                                IsDefault, IsActive, Id,
                                TimeZoneSidKey
                                FROM BusinessHours 
                                WHERE IsActive = true 
                                AND Id =: PreferredBHId];

                    if(prefBh != null)
                    {                   
                        Date dt = request.EventStartDateTime.dateGMT();
                        List<DateTime> lstbHDt =  utils.getBHStartEndDateTime(request.timeZone, dt, prefBh);
                    
                        if(lstbHDt.size() > 0)
                        {
                            if(lstbHDt[0].dateGMT() > request.EventStartDateTime.dateGMT())
                            {
                                lstbHDt.clear();
                                lstbHDt =  utils.getBHStartEndDateTime(request.timeZone, dt.addDays(-1), prefBh);
                            }
                            else if(lstbHDt[0].dateGMT() < request.EventStartDateTime.dateGMT())
                            {
                                lstbHDt.clear();
                                lstbHDt =  utils.getBHStartEndDateTime(request.timeZone, dt.addDays(1), prefBh);
                            }
                        }
                        
                        if(!utils.GetHolidays(prefBh, dt))
                        {
                            if(lstbHDt.size() > 0)
                            {
                                if(request.EventStartDateTime < lstbHDt[0])
                                    resp.STOutsideMachineAccesshrs = lstbHDt[0];
                                
                                if(request.EventEndDateTime > lstbHDt[1])
                                    resp.ETOutsideMachineAccesshrs = lstbHDt[1];
                            }
                        }
                    }
                }
            }           
        }
        catch (Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }     
        return resp;
    }
}