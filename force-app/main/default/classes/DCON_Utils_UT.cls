@isTest(SeeAllData=true)
Private class DCON_Utils_UT{
    static testMethod void DCON_Utils_UT()
    {
        DCON_Utils DconUtils = new DCON_Utils();
        List<String> allfields = new List<String>();
        allfields.add('abcd');
        allfields.add('efgh');
        List<String> reffields = new List<String>();
        List<String> dateTimeFields = new List<String>();
        List<String> dateFields = new List<String>();
        Map<String, String> replacementRef = new Map<String, String>();
        Map<String, String> replacementField = new Map<String, String>();
        Schema.SObjectField F = Account.AccountNumber;
        Account a = new Account();
        Schema.DescribeFieldResult F1 = Account.AccountNumber.getDescribe();
        // Map<String,Schema.SObjectField> mapsobj = new Map<String,Schema.SObjectField>();
        Map<String, Schema.SObjectField> mapsobj = Account.sObjectType.getDescribe().fields.getMap();   
        system.assert(mapsobj!=null);
        //Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 


        //  DCON_Utils.referenceFields_WP DconUtilsReffields= new DCON_Utils.referenceFields_WP(allfields,NULL,NULL,NULL,NULL,NULL);
        DconUtils.SVMX_getGlobalReferenceMap();
        DconUtils.SVMX_getReferenceFields(mapsobj,true);
        DconUtils.SVMX_getReferenceFields(mapsobj,false);
        DconUtils.SVMX_get_ListOfValues(allfields);
        DconUtils.SVMX_getFieldMap(mapsobj,true);
        DconUtils.SVMX_getallFieldMap(mapsobj);
        DconUtils.SVMX_getLocalDateFormat();
        DconUtils.TimeZoneConvertor(system.now(), 'ASIA/Calcutta','LOCAL', 'GMT');
        DconUtils.TimeZoneConvertor(system.today(), 'ASIA/Calcutta','LOCAL', 'GMT');
        DconUtils.TimeZoneConvertor(system.now(), 'ASIA/Calcutta','', 'GMT');
        DconUtils.TimeZoneConvertor(system.now(), '','', '');
        DconUtils.TimeZoneConvertor(system.now(), '','', 'SYSTEMLOCALE');
        DconUtils.TimeZoneConvertor(system.now(), 'ASIA/Calcutta', 'GMT');

        DconUtils.getRecordTypeMap();

        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c (Name = 'TEAM 1');
        insert objTeam;

        SVMXC__Service_Group__c objTeam_1 = new SVMXC__Service_Group__c (Name = 'TEAM 2');
        insert objTeam_1;

        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true
                                            );    
        SVMXC__Service_Group_Members__c objTechnician1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 2' ,
                                            SVMXC__Latitude__c = 13.644862 , 
                                            SVMXC__Longitude__c = 76.301082, 
                                            SVMXC__Service_Group__c = objTeam_1.Id ,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true
                                            ); 
                                                    
        system.assertEquals(objTechnician.SVMXC__Service_Group__c, objTeam.Id); 
        system.assertEquals(objTechnician1.SVMXC__Service_Group__c, objTeam_1.Id); 
        insert objTechnician;
        insert objTechnician1;

        RecordType rt = [select id,Name from RecordType where SobjectType='SVMXC__Service_Group_Site__c' and Name='Home Bases' Limit 1];

        SVMXC__Service_Group_Site__c objTechLoc = new SVMXC__Service_Group_Site__c (
                                            //Name = '0000001',
                                            SVMXC__Technician_Equipment__c =  objTechnician.Id ,
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Latitude__c = 13.644862 , 
                                            SVMXC__Longitude__c = 76.301082 , 
                                            SVMXC__IsCurrent__c = true ,
                                            recordTypeId=rt.id
                                            ); 
        insert objTechLoc;

        SVMXC__Service_Group_Site__c objTechLoc_1 = new SVMXC__Service_Group_Site__c (
                                            //Name = '0000001',
                                            SVMXC__Technician_Equipment__c =  objTechnician.Id ,
                                            SVMXC__Service_Group__c = objTeam_1.Id ,
                                            SVMXC__Latitude__c = 13.644862 , 
                                            SVMXC__Longitude__c = 76.301082 , 
                                            SVMXC__IsCurrent__c = true ,
                                            recordTypeId=rt.id
                                            ); 
        insert objTechLoc_1; 
       
        Double lat1 = 13.644862;
        Double long1 = 76.301082;
        Double lat2 = 12.976594;
        Double long2 = 77.599271;
        DconUtils.getDistanceBetween(lat1, long1, lat2, long2);
        
        String timeZone = 'Asia/Kolkata@YYYY-MM-DD hh:mm:ss';
        Time myTime = Time.newInstance(3, 14, 15, 926);
        DateTime dt;
        dt = DconUtils.getDateTimeInTimezone(Date.valueOf('2015-11-15 00:00:00')+2, myTime, timeZone);
        
        List<BusinessHours> lstdefaultbh = [SELECT FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE IsActive = true AND IsDefault = true];
        
        BusinessHours defaultBh = lstdefaultbh.get(0);
        
        dt = DconUtils.doTZConversion(system.now(), 'Asia/Kolkata', 'GMT');
        List<DateTime> lstDt = new List<DateTime>();
        lstDt = DconUtils.getBHStartEndDateTime(timeZone, system.now().date(), defaultBh);

        boolean isHoliday = DconUtils.GetHolidays(defaultBh, system.now().date());
    }
}