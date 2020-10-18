/* This class has utilities to convert user XML to JSON and to give permissions to new field added in existing object*/
global class DCX_UserSettingMigrator  {
  
    // Wrapper request where the search criteria for user setting migration can be set
    global class DCX_MigrationRequest { 
        global String city;
        global String country;
        global String department;
        global String division;
        global String postalCode;
        global String state;
        global String profileId;

        global DCX_MigrationRequest() {}

        global DCX_MigrationRequest(String city, String country, String department, String division, String postalCode, String state, String profileId) {
            this.city = city;
            this.country = country;
            this.department = department;
            this.division = division;
            this.postalCode = postalCode;
            this.state = state;
            this.profileId = profileId;
        }
    }

    global static void enableDCxPermissions(String profileId) {
        // List<FieldPermissions> fpList = [SELECT SobjectType, Field, PermissionsRead, PermissionsEdit, Parent.ProfileId FROM FieldPermissions WHERE SobjectType = 'Account' and Field='Account.Customer_Priority__c' AND Parent.ProfileId IN (SELECT Id FROM PermissionSet WHERE PermissionSet.Profile.Name = 'System Administrator')];
        // if(!fpList.isEmpty()){
        //     Boolean hasReadPermission = fpList[0].PermissionsRead;
        //     Boolean hasEditPermission = fpList[0].PermissionsEdit;
        //     system.debug('Read Permission - ' + hasReadPermission);
        //     system.debug('Edit Permission - ' + hasEditPermission);
        // }
    }

    global static void migrateSelected(DCX_MigrationRequest Req) {
        List<String> userIds = new List<String>();
        List<User> uList = new List<User>();
        if(Req.profileId != null && Req.profileId != '') {
            uList = [Select Id from User where ProfileId = :Req.profileId];
        }
        else if(Req.division != null && Req.division != '') {
            uList = [Select Id from User where Division = :Req.division];
        }
        else if(Req.department != null && Req.department != '') {
            uList = [Select Id from User where Department = :Req.department];
        }

        for(User u : uList) {
            userIds.add(String.valueOf(u.Id));
            system.debug('UserId'+u+'++'+userIds);
        }
        convertForUsers('migrateSelected',userIds);
    }

    global static void migrateSelectedUsers(List<String> userNameList) {
        List<String> userIds = new List<String>();
        for(User u : [Select Id from User where Username IN :userNameList]) {
            userIds.add(String.valueOf(u.Id));
            system.debug('UserId'+u+'++'+userIds);
        }
        convertForUsers('migrateSelectedUsers',userIds);
    }

    global static void migrateAll() {
        List<String> userIds = new List<String>();
        for (User UserId: [Select Id from User]) {
            userIds.add(String.valueOf(UserId.Id));
            system.debug('UserId'+UserId+'++'+userIds);
        }
        convertForUsers('migrateAll',userIds);
    }
    
    private static void convertForUsers(String apiName, List<String> userIds) {
        try {
            String jsonStr;
            List < SVMXC__SM_User_Preferences__c > userPrefList = new List < SVMXC__SM_User_Preferences__c > ();
            Map < Id, SVMXC__SM_User_Preferences__c > userPrefMap = new Map < Id, SVMXC__SM_User_Preferences__c > ();
            SVMXC__SM_User_Preferences__c userPref;

            Map<Id, List<String>> mapTeam = fetchTeamIds(userIds);
            Map<Id, List<String>> mapTerritory = fetchTerritoryIds(userIds);
            List<User> uList = [Select Id, Name ,SVMXC__Dispatch_Console_Settings__c from User where Id IN :userIds];
            List<String> notMigratedUserList = new List<String> ();
            String migratedUser='';
            String notMigratedUser='';
            String erroredUser='';
            for (SVMXC__SM_User_Preferences__c userPrefRec: [Select Id, SVMXC__SM_User_Reference_Id__c, SVMXC__SM_DC_User_Settings__c,
                    SVMXC__SM_Type__c from SVMXC__SM_User_Preferences__c ]) {
                userPrefMap.put(userPrefRec.SVMXC__SM_User_Reference_Id__c, userPrefRec);
            }

            List<String> errList = new List<String>();
            for (User userRec : uList) {
                system.debug('User record ID'+userRec.Id);
                List<String> team = mapTeam.get(userRec.Id);
                system.debug('team team++'+team);
                List<String> territory = mapTerritory.get(userRec.Id);
                try {
                    if (userRec.SVMXC__Dispatch_Console_Settings__c != null && userRec.SVMXC__Dispatch_Console_Settings__c != '') {
                        jsonStr = '';
                        //System.debug('userRec.SVMXC__Dispatch_Console_Settings__c' + userRec.Id + '++' + userRec.SVMXC__Dispatch_Console_Settings__c);
                        jsonStr = ConvertIntoJSON(userRec.SVMXC__Dispatch_Console_Settings__c,userRec.Id,team,territory);
                        system.debug('User id whose json is converted : '+userRec.Id);
                        if (jsonStr !='' && userPrefMap.containsKey(userRec.Id)) {
                            userPref = userPrefMap.get(userRec.Id);
                            //if(userPref.SVMXC__SM_DC_User_Settings__c == null){
                                userPref.SVMXC__SM_DC_User_Settings__c = jsonStr;
                                userPref.SVMXC__SM_Type__c = 'DCx';
                                system.debug('adding user rec :' +userRec.Id);
                                userPrefList.add(userPref);
                        // }                
                        } else {
                            system.debug('user does not exist or could not be migrated : '+userRec.Id);
                            userPref = new SVMXC__SM_User_Preferences__c(SVMXC__SM_DC_User_Settings__c = jsonStr,
                            SVMXC__SM_Type__c = 'DCx', SVMXC__SM_User_Reference_Id__c = userRec.Id);
                            userPrefList.add(userPref);
                        } 
                        //.add(userRec.Name);     
                        if(migratedUser =='')  
                        migratedUser = userRec.Name+' ( '+userRec.Id + ' ) ';
                        else
                        migratedUser += ','+ userRec.Name+' ( '+userRec.Id + ' ) ';
                    }
                    else{
                        notMigratedUserList.add(userRec.Name);
                        if(notMigratedUser =='')  
                        notMigratedUser = userRec.Name +'( '+userRec.Id + ' ) ';
                        else
                        notMigratedUser += ','+ userRec.Name +'( '+userRec.Id + ' ) ';

                    }
                }
                catch(Exception e) {
                    errList.add(userRec.Id);
                   // erroredUser.add(userRec.Name); 
                    if(erroredUser =='')  
                    erroredUser = userRec.Name +'( '+userRec.Id + ' ) ';
                        else
                        erroredUser += ','+ userRec.Name +'( '+userRec.Id + ' ) ';

                }
            }

            if(userPrefList.size() > 0) {
                system.debug('userPrefList.size()' +userPrefList.size());
                upsert userPrefList;
            }

            sendMail(apiName,userPrefList.size(),errList.size(),errList,migratedUser,notMigratedUser,erroredUser,notMigratedUserList);

        } catch (DmlException e) {
            for(Integer k = 0; k < e.getNumDml(); k++) {
                System.debug('  DmlException Encountered  with exception: ' + e.getDmlMessage(k));
            } 
            system.debug(e.getMessage());
            system.debug(logginglevel.error, 'e.getstackTrace() ' + e.getStackTraceString());      
        }

    }

    private static void sendMail(String apiName, Integer migrated, Integer notMigrated, List<String> users, String migratedUser,String notMigratedUser,String erroredUser,List<String> notMigratedUserList) {
        // Step 0: Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo.add(UserInfo.getUserEmail());
        mail.setToAddresses(sendTo);

        // Step 3. Set email contents
        mail.setSubject('DC User Setting Migration Report');
        String body = 'Dear ' + UserInfo.getName() + ', '+'<br/><br/>';
        body += 'The user setting migration was done using the api : '+ apiName +'.'+'<br/><br/>';
        body += 'Find below the report of user setting migration from DC Flash to DC HTML :'+'<br/><br/>';
        body += 'Number of users migrated : '+ String.valueOf(migrated) +'<br/><br/>';
        body += 'Number of users not needing migration as they do not have user setting xml: '+ String.valueOf(notMigratedUserList.size()) +'<br/><br/>';
        body += 'Number of users errored while migratation : '+ String.valueOf(notMigrated)+'<br/><br/>';
        body += 'Users who are  migrated are as follows : '+migratedUser+'<br/><br/>';
        body += 'Users who do not have a user setting xml are as follows:  '+notMigratedUser+'<br/><br/>';
        body += 'Users who are NOT migrated because uase of corrupted XML are as follows  : '+erroredUser+'<br/><br/>';

       // String uList = '';
      //  uList = string.join(users,',');
       // body += 'Users who are NOT migrated are as follows : '+ uList +'.'+'<br/><br/>';
        mail.setHtmlBody(body);
        system.debug('Email sent to : '+UserInfo.getUserEmail());
        system.debug('Email Content : '+body);

        // Step 4. Add your email to the master list
        mails.add(mail);

        // Step 5: Send all emails in the master list
        if(!Test.isRunningTest()){
        Messaging.sendEmail(mails);
        }

    }

    public static string ConvertIntoJSON(String userXML, String userId,List<String> TeamAccess, List<String> territoryAcess) {
    String uJson ='';
     Dom.Document doc = new Dom.Document();
     if(userXML ==null & userXML =='')
     return '';
     if (userXML != null && userXML.length() > 0){
      doc.load(userXML);
     
      }
      try{
                Dom.Xmlnode rootElement = doc.getRootElement();
                List < String > wo_grid_conf_fields = new List < String > ();
                List < String > wo_grid_col_fields = new List < String > ();
                List <String> schedulerColumn = new List <String> ();
                
                
                wo_grid_conf_fields.add('Name');
                wo_grid_conf_fields.add('SVMXC__Company__c');
                wo_grid_conf_fields.add('SVMXC__Contact__c');
                wo_grid_conf_fields.add('SVMXC__Case__c');
                wo_grid_conf_fields.add('SVMXC__Priority__c');
                wo_grid_conf_fields.add('SVMXC__Order_Status__c');
                wo_grid_conf_fields.add('SVMXC__Order_Type__c');
                wo_grid_conf_fields.add('SVMXC__Dispatch_Status__c');
                wo_grid_conf_fields.add('SVMXC__Group_Member__c');
                wo_grid_conf_fields.add('SVMXC__City__c');
                wo_grid_conf_fields.add('SVMXC__Component__c');
                wo_grid_conf_fields.add('SVMXC__State__c');
                wo_grid_conf_fields.add('SVMXC__Zip__c');
                wo_grid_conf_fields.add('SVMXC__Service_Group__c');
                wo_grid_conf_fields.add('SVMXC__Driving_Time__c');
                wo_grid_conf_fields.add('SVMXC__Preferred_Start_Time__c');
                wo_grid_conf_fields.add('SVMXC__Product__c');
                UserSetting deploySetting = new UserSetting();
                List <  WoRules > WoRulesL = new List <  WoRules > ();
                    WoRules WoRule = new  WoRules();
                    deploySetting.wo_woRules = WoRulesL;

                    List <  TechRules > TechRulesL = new List <  TechRules > ();
                    deploySetting.tech_techRules = TechRulesL;

                    deploySetting.tech_territorySequence = new List<String>();

                    List <  TechCol > TechColL = new List <  TechCol > ();
                    deploySetting.tech_techCol = TechColL;
                    deploySetting.tech_teamSequence = new List<String>();
                    deploySetting.tech_ExpandedTeam = new List<String>();
                    deploySetting.tech_expandedTerritory = new List<String>();
                    deploySetting.wo_sch_col_fields = new List < String > ();

                for (Dom.XMLNode firstChild: rootElement.getChildElements()) {
                if (firstChild.getAttribute('id', null) == 'workOrderSettings') {
                deploySetting.wo_autorefresh = replaceNullBoolean(firstChild.getAttributeValue('autorefresh', null));
                deploySetting.wo_columnIndex = replaceNullNumber(firstChild.getAttributeValue('columnIndex', null),'columnIndex');
                deploySetting.wo_defaultView = replaceNullString(firstChild.getAttributeValue('defaultView', null),'defaultView');
                if(deploySetting.wo_defaultView.equalsIgnoreCase('null'))
                    deploySetting.wo_defaultView = '';
                deploySetting.wo_deleteEventWo = replaceNullBoolean(firstChild.getAttributeValue('deleteEventWo', null));
                deploySetting.wo_doNotOverlapExistingEvents = replaceNullBoolean(firstChild.getAttributeValue('doNotOverlapExistingEvents', null));
                deploySetting.wo_filterColumn = replaceNullString(firstChild.getAttributeValue('filterColumn', null),'filterColumn');
                deploySetting.wo_isAdvMode = replaceNullBoolean(firstChild.getAttributeValue('isAdvMode', null));
                deploySetting.wo_isAlldayEvent = replaceNullBoolean(firstChild.getAttributeValue('isAlldayEvent', null));
                deploySetting.wo_refreshtime = replaceNullNumber(firstChild.getAttributeValue('refreshtime', null),'refreshtime');
                deploySetting.wo_resetTime = replaceNullBoolean(firstChild.getAttributeValue('resetTime', null));
                deploySetting.wo_respectMachineAccessHours = replaceNullBoolean(firstChild.getAttributeValue('respectMachineAccessHours', null));
                deploySetting.wo_respectTechnincianWorkHours = replaceNullBoolean(firstChild.getAttributeValue('respectTechnincianWorkHours', null));
                deploySetting.wo_schedulingAsLongJob = replaceNullBoolean(firstChild.getAttributeValue('schedulingAsLongJob', null));
                deploySetting.wo_sortColumn = replaceNullString(firstChild.getAttributeValue('sortColumn', null),'sortColumn');
                deploySetting.wo_sortOrder = replaceNullString(firstChild.getAttributeValue('sortOrder', null),'sortOrder');
                deploySetting.wo_unassignWO = replaceNullBoolean(firstChild.getAttributeValue('unassignWO', null));
                deploySetting.wo_woHoverColor = replaceNullNumber(firstChild.getAttributeValue('woHoverColor', null),'woHoverColor');
                deploySetting.wo_woSelectionColor = replaceNullNumber(firstChild.getAttributeValue('woSelectionColor', null),'woSelectionColor');
              //  deploySetting.wo_sch_col_fields = new List < String > ();
                List < String > conCol = new List < String > ();
                List <WoCol> wocol = new List <WoCol> ();
               
                WoCol woc = new WoCol();
                List <  ViewCounter > viewCouL = new List <  ViewCounter > ();
                    ViewCounter viewCou = new  ViewCounter();
                List <  Views > sortedL = new List <  Views > ();
                    Views sorted = new  Views();
                List <  Operand > OperandL = new List <  Operand > ();
                    Operand Operan = new  Operand();
              
                
                for (Dom.XMLNode secondChild: firstChild.getChildElements()) {
                    if (secondChild.getName() == 'selectedcolumns') {
                    for (Dom.XMLNode thirdChild: secondChild.getChildElements()) {
                    if (thirdChild.getName() == 'column') {
                    woc.name = thirdChild.getAttributeValue('name', null);
                    woc.width = thirdChild.getAttributeValue('width', null);
                    wocol.add(woc);
                    woc = new  WoCol();
                    if (!wo_grid_conf_fields.contains(thirdChild.getAttributeValue('name', null)))
                        wo_grid_conf_fields.add(thirdChild.getAttributeValue('name', null));
                    }
                    }
                    deploySetting.wo_woCol = wocol;
                    wocol = new List <  WoCol > ();
                    }
                    if (secondChild.getName() == 'viewcounter') {
                    for (Dom.XMLNode thirdChild: secondChild.getChildElements()) {
                    if (thirdChild.getName() == 'view1') {
                    viewCou.color = thirdChild.getAttributeValue('color', null);
                    viewCou.name = thirdChild.getAttributeValue('name', null);
                    viewCou.id = thirdChild.getAttributeValue('id', null);
                    viewCou.column = thirdChild.getAttributeValue('column', null);
                    viewCou.sortOrder = thirdChild.getAttributeValue('sortOrder', null);
                    viewCou.columnIndex = thirdChild.getAttributeValue('columnIndex', null);
                    viewCouL.add(viewCou);
                    viewCou = new  ViewCounter();
                    }
                    if (thirdChild.getName() == 'view2') {
                    viewCou.color = thirdChild.getAttributeValue('color', null);
                    viewCou.name = thirdChild.getAttributeValue('name', null);
                    viewCou.id = thirdChild.getAttributeValue('id', null);
                    viewCou.column = thirdChild.getAttributeValue('column', null);
                    viewCou.sortOrder = thirdChild.getAttributeValue('sortOrder', null);
                    viewCou.columnIndex = thirdChild.getAttributeValue('columnIndex', null);
                    viewCouL.add(viewCou);
                    viewCou = new  ViewCounter();
                    }
                    if (thirdChild.getName() == 'view3') {
                    viewCou.color = thirdChild.getAttributeValue('color', null);
                    viewCou.name = thirdChild.getAttributeValue('name', null);
                    viewCou.id = thirdChild.getAttributeValue('id', null);
                    viewCou.column = thirdChild.getAttributeValue('column', null);
                    viewCou.sortOrder = thirdChild.getAttributeValue('sortOrder', null);
                    viewCou.columnIndex = thirdChild.getAttributeValue('columnIndex', null);
                    viewCouL.add(viewCou);
                    viewCou = new  ViewCounter();
                    }
                    }
                    deploySetting.wo_viewCounter = viewCouL;
                    }
                
                    if (secondChild.getName() == 'sortedviews') {
                    for (Dom.XMLNode thirdChild: secondChild.getChildElements()) {
                    if (thirdChild.getName() == 'view1') {
                    sorted.name = thirdChild.getAttributeValue('name', null);
                    sorted.id = thirdChild.getAttributeValue('id', null);
                    sorted.column = thirdChild.getAttributeValue('column', null);
                    sorted.sortOrder = thirdChild.getAttributeValue('sortOrder', null);
                    sorted.columnIndex = thirdChild.getAttributeValue('columnIndex', null);
                    sortedL.add(sorted);
                    sorted = new  Views();
                    }
                    if (thirdChild.getName() == 'view2') {
                    sorted.name = thirdChild.getAttributeValue('name', null);
                    sorted.id = thirdChild.getAttributeValue('id', null);
                    sorted.column = thirdChild.getAttributeValue('column', null);
                    sorted.sortOrder = thirdChild.getAttributeValue('sortOrder', null);
                    sorted.columnIndex = thirdChild.getAttributeValue('columnIndex', null);
                    sortedL.add(sorted);
                    sorted = new  Views();
                    }
                    if (thirdChild.getName() == 'view3') {
                    sorted.name = thirdChild.getAttributeValue('name', null);
                    sorted.id = thirdChild.getAttributeValue('id', null);
                    sorted.column = thirdChild.getAttributeValue('column', null);
                    sorted.sortOrder = thirdChild.getAttributeValue('sortOrder', null);
                    sorted.columnIndex = thirdChild.getAttributeValue('columnIndex', null);
                    sortedL.add(sorted);
                    sorted = new  Views();
                    }
                    }
                    deploySetting.wo_views = sortedL;
                    }
                
                    if (secondChild.getName() == 'rules') {
                    for (Dom.XMLNode thirdChild: secondChild.getChildElements()) {
                    if (thirdChild.getName() == 'rule') {
                
                    for (Dom.XMLNode fourthChild: thirdChild.getChildElements()) {
                        if (fourthChild.getName() == 'row') {
                        Operan.property = fourthChild.getAttributeValue('property', null);
                        Operan.type = 'WO';
                        Operan.fieldType = fourthChild.getAttributeValue('fieldType', null);//.touppercase();
                        Operan.compare = fourthChild.getAttributeValue('compare', null);
                        Operan.value = fourthChild.getAttributeValue('value', null);
                        OperandL.add(Operan);
                        Operan = new  Operand();
                        if (!wo_grid_col_fields.contains(fourthChild.getAttributeValue('property', null)))
                        wo_grid_col_fields.add(fourthChild.getAttributeValue('property', null));
                        }
                    }
                    WoRule.name = thirdChild.getAttributeValue('name', null);
                    WoRule.status = thirdChild.getAttributeValue('status', null);
                    WoRule.expression = thirdChild.getAttributeValue('expression', null);
                    WoRule.color = thirdChild.getAttributeValue('color', null);
                    WoRule.operand = OperandL;
                    OperandL = new List <  Operand > ();
                    WoRulesL.add(WoRule);
                    WoRule = new  WoRules();
                    }
                    }
                    deploySetting.wo_woRules = WoRulesL;
                    }
                }
                deploySetting.wo_grid_col_fields = wo_grid_col_fields;
                
                }
                
                if (firstChild.getAttribute('id', null) == 'technicianSettings') {
                deploySetting.tech_workingHoursColor = replaceNullNumber(firstChild.getAttributeValue('workingHoursColor', null),'workingHoursColor');
                deploySetting.tech_viewAllEventsForToday = replaceNullBoolean(firstChild.getAttributeValue('viewAllEventsForToday', null));
                deploySetting.tech_view = replaceNullString(firstChild.getAttributeValue('view', null),'view');
                deploySetting.tech_toolTipShowDelay = replaceNullString(firstChild.getAttributeValue('toolTipShowDelay', null),'toolTipShowDelay');
                deploySetting.tech_toolTipHideDelay = replaceNullNumber(firstChild.getAttributeValue('toolTipHideDelay', null),'toolTipShowDelay');
                deploySetting.tech_timeIndicatorColor = replaceNullNumber(firstChild.getAttributeValue('timeIndicatorColor', null),'timeIndicatorColor');
                deploySetting.tech_showTimeIndicator = replaceNullBoolean(firstChild.getAttributeValue('showTimeIndicator', null));
                deploySetting.tech_showOptionMenu = replaceNullBoolean(firstChild.getAttributeValue('showOptionMenu', null));
                deploySetting.tech_showFieldUpdates = replaceNullBoolean(firstChild.getAttributeValue('showFieldUpdates', null));
                deploySetting.tech_retainDateOnShowRoute = replaceNullBoolean(firstChild.getAttributeValue('retainDateOnShowRoute', null));
                deploySetting.tech_relatedEventColor = replaceNullNumber(firstChild.getAttributeValue('relatedEventColor', null),'relatedEventColor');
                deploySetting.tech_refreshEventsOnChange = replaceNullBoolean(firstChild.getAttributeValue('refreshEventsOnChange', null));
                deploySetting.tech_pinMapActionBar = replaceNullBoolean(firstChild.getAttributeValue('pinMapActionBar', null));
                deploySetting.tech_overNightStayColor = replaceNullNumber(firstChild.getAttributeValue('overNightStayColor', null),'overNightStayColor');
                deploySetting.tech_overheadColor = replaceNullNumber(firstChild.getAttributeValue('overheadColor', null),'overheadColor');
                deploySetting.tech_noOfDays = replaceNullNumber(firstChild.getAttributeValue('noOfDays', null),'noOfDays');
                deploySetting.tech_mapDefaultZoomLevel = replaceNullNumber(firstChild.getAttributeValue('mapDefaultZoomLevel', null),'mapDefaultZoomLevel');
                deploySetting.tech_mapDefaultLng = replaceNullString(firstChild.getAttributeValue('mapDefaultLng', null),'mapDefaultLng');
                deploySetting.tech_mapDefaultLat = replaceNullString(firstChild.getAttributeValue('mapDefaultLat', null),'mapDefaultLat');
                deploySetting.tech_loglevel = replaceNullString(firstChild.getAttributeValue('loglevel', null),'loglevel');
                deploySetting.tech_locationBase = replaceNullString(firstChild.getAttributeValue('locationBase', null),'locationBase');
                deploySetting.tech_holidayHoursColor = replaceNullNumber(firstChild.getAttributeValue('holidayHoursColor', null),'holidayHoursColor');
                deploySetting.tech_eventRowColor = replaceNullNumber(firstChild.getAttributeValue('eventRowColor', null),'eventRowColor');
                deploySetting.tech_enableGoogleMapApi = replaceNullBoolean(firstChild.getAttributeValue('enableGoogleMapApi', null));
                deploySetting.tech_driveColor = replaceNullNumber(firstChild.getAttributeValue('driveColor', null),'driveColor');
                deploySetting.tech_defaultWOEventColor = replaceNullNumber(firstChild.getAttributeValue('defaultWOEventColor', null),'defaultWOEventColor');
                deploySetting.tech_defaultEventColor = replaceNullNumber(firstChild.getAttributeValue('defaultEventColor', null),'defaultEventColor');
                deploySetting.tech_dataTipOnClick = replaceNullBoolean(firstChild.getAttributeValue('dataTipOnClick', null));
                deploySetting.tech_autoSyncServiceDuration = replaceNullBoolean(firstChild.getAttributeValue('autoSyncServiceDuration', null));
                deploySetting.tech_autoCalculateEndDate = replaceNullBoolean(firstChild.getAttributeValue('autoCalculateEndDate', null));
                deploySetting.tech_dcmap = replaceNullBoolean(firstChild.getAttributeValue('map', null));

                deploySetting.tech_ExpandedTeam = new List<String>();
                deploySetting.tech_expandedTerritory = new List<String>();

                
                deploySetting.tech_condition = firstChild.getAttributeValue('condition', null);
                for (Dom.XMLNode secondChild: firstChild.getChildElements()) {
                    if (secondChild.getName() == 'territory') {
                    deploySetting.tech_favouriteTerritory = secondChild.getAttributeValue('favourite', null);
                    }
                    if (secondChild.getName() == 'team') {
                    deploySetting.tech_favouriteTeam = secondChild.getAttributeValue('favourite', null);
                    }
                    if (secondChild.getName() == 'advncedTechSearch') {
                    for (Dom.XMLNode thirdChild: secondChild.getChildElements()) {
                    AtsSkills AtsSkill = new  AtsSkills();
                    AtsExpertise AtsExpertiseObj = new  AtsExpertise();
                    AtsEligibility AtsEligibilityObj = new  AtsEligibility();
                    AtsPrefTech AtsPrefTechObj = new  AtsPrefTech();
                    if (thirdChild.getName() == 'skills') {
                    deploySetting.tech_showSkills = thirdChild.getAttributeValue('show', null);
                    deploySetting.tech_searchSkills = thirdChild.getAttributeValue('includeForSearch', null);
                    AtsSkill.show = thirdChild.getAttributeValue('show', null);
                    AtsSkill.search = thirdChild.getAttributeValue('includeForSearch', null);
                    deploySetting.adv_atsSkills = AtsSkill;
                    }
                    if (thirdChild.getName() == 'eligibility') {
                    deploySetting.tech_showEligibility = thirdChild.getAttributeValue('show', null);
                    deploySetting.tech_searchEligibility = thirdChild.getAttributeValue('includeForSearch', null);
                    AtsEligibilityObj.show = thirdChild.getAttributeValue('show', null);
                    AtsEligibilityObj.search = thirdChild.getAttributeValue('includeForSearch', null);
                    deploySetting.adv_atsEligibility = AtsEligibilityObj;
                    }
                    if (thirdChild.getName() == 'prefTech') {
                    deploySetting.tech_showPrefTech = thirdChild.getAttributeValue('show', null);
                    deploySetting.tech_searchPrefTech = thirdChild.getAttributeValue('includeForSearch', null);
                    AtsPrefTechObj.show = thirdChild.getAttributeValue('show', null);
                    AtsPrefTechObj.search = thirdChild.getAttributeValue('includeForSearch', null);
                    deploySetting.adv_atsPrefTech = AtsPrefTechObj;
                    }
                    if (thirdChild.getName() == 'productExpertise') {
                    deploySetting.tech_showProductExpertise = thirdChild.getAttributeValue('show', null);
                    deploySetting.tech_searchProductExpertise = thirdChild.getAttributeValue('includeForSearch', null);
                    AtsExpertiseObj.show = thirdChild.getAttributeValue('show', null);
                    AtsExpertiseObj.search = thirdChild.getAttributeValue('includeForSearch', null);
                    deploySetting.adv_atsExpertise = AtsExpertiseObj;
                    }
                    }
                    }
                   // List <  TechCol > TechColL = new List <  TechCol > ();
                    TechCol TechCo = new  TechCol();
                    if (secondChild.getName() == 'selectedcolumns') {
                    for (Dom.XMLNode thirdChild: secondChild.getChildElements()) {
                    if (thirdChild.getName() == 'column') {
                    TechCo.name = thirdChild.getAttributeValue('name', null);
                    TechCo.width = thirdChild.getAttributeValue('width', null);
                    TechColL.add(TechCo);
                    TechCo = new  TechCol();
                    }
                    }
                
                    deploySetting.tech_techCol = TechColL;
                    }
                    
                    TechRules TechRule = new  TechRules();
                    List <  Operand > OperandL = new List <  Operand > ();
                    Operand Operan = new  Operand();
                    if (secondChild.getName() == 'rules') {
                    Boolean IsWoRule = false;
                    Boolean IsEventRule = false;
                    Boolean IsCombiedRule = false;
                
                    for (Dom.XMLNode thirdChild: secondChild.getChildElements()) {
                    if (thirdChild.getName() == 'rule') {
                
                    for (Dom.XMLNode fourthChild: thirdChild.getChildElements()) {
                        IsWoRule = false;
                        IsEventRule = false;
                        if (fourthChild.getName() == 'row') {
                       // system.debug('fourthChild.getAttributeValue ' + fourthChild.getAttributeValue('property', null));
                        Operan.property = fourthChild.getAttributeValue('property', null);
                        Operan.type = fourthChild.getAttributeValue('type', null);
                        Operan.fieldType = fourthChild.getAttributeValue('fieldType', null);//.touppercase();
                        if (fourthChild.getAttributeValue('type', null) == 'WO') {
                            IsWoRule = true;
                            if (!schedulerColumn.contains(fourthChild.getAttributeValue('property', null)))
                                schedulerColumn.add(fourthChild.getAttributeValue('property', null));
                      //  List <String> schedulerColumn = new List <String> ();
                        } else {
                        IsEventRule = true;
                        }
                        Operan.compare = fourthChild.getAttributeValue('compare', null);
                        Operan.value = fourthChild.getAttributeValue('value', null);
                
                        OperandL.add(Operan);
                        Operan = new  Operand();
                        }
                    }
                    TechRule.name = thirdChild.getAttributeValue('name', null);
                    TechRule.status = thirdChild.getAttributeValue('status', null);
                    TechRule.expression = thirdChild.getAttributeValue('expression', null);
                    TechRule.color = thirdChild.getAttributeValue('color', null);
                    if (IsWoRule && IsEventRule) {
                        TechRule.ruleType = 'CombinedRule';
                    } else if (!IsWoRule && IsEventRule) {
                        TechRule.ruleType = 'EventRule';
                    }
                    if (IsWoRule && !IsEventRule) {
                        IsWoRule = true;
                        TechRule.ruleType = 'WorkOrderRule';
                    }
                    TechRule.operand = OperandL;
                    OperandL = new List <  Operand > ();
                    TechRulesL.add(TechRule);
                    TechRule = new  TechRules();
                    }
                    }
                    deploySetting.tech_techRules = TechRulesL;
                    deploySetting.wo_sch_col_fields =  schedulerColumn;
                    }
                
                    if (secondChild.getName() == 'team') {
                    Map < Integer, String > mapl = new Map < Integer, String > ();
                    List < String > teamS = new List < String > ();
                    for (Dom.XMLNode thirdChild: secondChild.getChildElements()) {
                    if (thirdChild.getName() == 'sequence') {
                    String strSeq = thirdChild.getText();
                    strSeq = strSeq.remove('\"');
                    strSeq = strSeq.remove('{');
                    strSeq = strSeq.remove('}');
                    if (strSeq != '' && strSeq != null) {
                        List < String > teamSeq = strSeq.split(',');
                        system.debug('teamSeq :'+teamSeq);
                        Integer i = 10;
                        for (String teamStr: teamSeq) {
                            system.debug('teamStr :'+teamStr);
                            List < String > teamIdList = teamStr.split(':');
                            system.debug('teamIdList :'+teamIdList);
                            if (teamIdList.size() > 1) {
                                mapl.put(Integer.valueof(teamIdList[1]), teamIdList[0]);
                                system.debug('mapl :'+mapl);
                            }
                        }
                    }
                    }
                    
                    if (thirdChild.getName() == 'collapsedTeam') {
                        if(TeamAccess != null && TeamAccess.size() >0){
                           // system.debug('TeamAccess :'+TeamAccess);
                            String TeamIdsStr = thirdChild.getText();
                                TeamIdsStr = TeamIdsStr.remove('\"');
                              //  system.debug('TeamIdsStr :'+TeamIdsStr);
                                if (TeamIdsStr != '' && TeamIdsStr != null) {
                                    List < String > teamids = TeamAccess;
                                 //   system.debug('teamids :'+teamids);
                                    List < String > CollpasedTeamIds = TeamIdsStr.split(',');
                                    List < String > ExpandedTeamIds = new List < String > ();
                                    for (String ss: teamids) {
                                       // system.debug('ss :'+ss);
                                        if (!CollpasedTeamIds.contains(ss) && ss != null) {
                                     //       system.debug('ExpandedTeamIds :'+ExpandedTeamIds);
                                            ExpandedTeamIds.add(ss);
                                        }
                                    }
                                    deploySetting.tech_ExpandedTeam = ExpandedTeamIds;
                                } else {
                                    List < String > teamid = new List < String > ();
                                  //  teamid.addAll(TeamAccess); //TeamIdsStr.split(',');
                                  for(String s: TeamAccess){
                                    if(s != null){
                                        teamid.add(s);
                                    }
                                  }
                                    deploySetting.tech_ExpandedTeam = teamid;
                                }
                            }
                           /* else{
                                deploySetting.tech_ExpandedTeam = new List<String>();
                            }*/
                    
                    }
                    //deploySetting.tech_ExpandedTeam  =new List<String>();
                    }
                    if (mapl.size() > 0) {
                      //  system.debug('mapl ::'+mapl);
                        list<Integer> ranksList = new list<Integer>();
                        ranksList.addAll(mapl.keySet());
                        ranksList.sort();
                        for(Integer rank : ranksList)
                        {
                            String thisEntryName = mapl.get(rank);
                            system.debug('thisEntryName :'+thisEntryName);
                            teamS.add(thisEntryName);
                        }
                        /*for (Integer i = 0; i < mapl.size(); i++) {
                            teamS.add(mapl.get(i));
                        }*/
                    deploySetting.tech_teamSequence = teamS;
                
                    }
                    else
                    deploySetting.tech_teamSequence = new List<String>();
                
                    }
                
                    if (secondChild.getName() == 'territory') {
                    Map < Integer, String > mapl = new Map < Integer, String > ();
                    List < String > teamS = new List < String > ();
                    for (Dom.XMLNode thirdChild: secondChild.getChildElements()) {
                    if (thirdChild.getName() == 'sequence') {
                    String strSeq = thirdChild.getText();
                    strSeq = strSeq.remove('\"');
                    strSeq = strSeq.remove('{');
                    strSeq = strSeq.remove('}');
                    if (strSeq != '' && strSeq != null) {
                
                        List < String > teamSeq = strSeq.split(',');
                        Integer i = 10;
                        for (String teamStr: teamSeq) {
                
                        List < String > teamIdList = teamStr.split(':');
                        if (teamIdList.size() > 1) {
                        mapl.put(Integer.valueof(teamIdList[1]), teamIdList[0]);
                        }
                        }
                    }
                
                    }
                    if (thirdChild.getName() == 'collapsedTerritory') {
                        system.debug('territoryAcess :'+territoryAcess);
                        if(territoryAcess != null && territoryAcess.size() > 0){
                            String TeamIdsStr = thirdChild.getText();
                                TeamIdsStr = TeamIdsStr.remove('\"');
                                //system.debug('TeamIdsStr :'+TeamIdsStr);
                                if (TeamIdsStr != '' && TeamIdsStr != null) {
                                    List < String > teamids = territoryAcess;
                                    List < String > CollpasedTeamIds = TeamIdsStr.split(',');
                                    //system.debug('CollpasedTeamIds :'+CollpasedTeamIds);
                                    List < String > ExpandedTeamIds = new List < String > ();
                                    for (String ss: teamids) {
                                        system.debug('ss :'+ss);
                                        if (!CollpasedTeamIds.contains(ss)&&ss !=null) {
                                           // system.debug('ExpandedTeamIds :'+ExpandedTeamIds);
                                            ExpandedTeamIds.add(ss);
                                        }
                                    }
                                    deploySetting.tech_expandedTerritory = ExpandedTeamIds;
                                } else {
                                    List < String > teamid = new List < String > ();
                                   // teamid.addAll(territoryAcess); //TeamIdsStr.split(',');
                                    for(String s: territoryAcess){
                                        if(s !=null){
                                            teamid.add(s);
                                        }
                                    }
                                    deploySetting.tech_expandedTerritory = teamid;
                                }
                            }
                          /*  else{
                                deploySetting.tech_expandedTerritory = new List<String>();
                            }*/
                    
                    }
                    }
                    if (mapl.size() > 0) {
                        list<Integer> ranksList = new list<Integer>();
                        ranksList.addAll(mapl.keySet());
                        ranksList.sort();
                        for(Integer rank : ranksList)
                        {
                            String thisEntryName = mapl.get(rank);
                            teamS.add(thisEntryName);
                        }
                    /*for (Integer i = 0; i < mapl.size(); i++) {
                    teamS.add(mapl.get(i));
                    }*/
                    deploySetting.tech_territorySequence = teamS;
                    }
                    else
                    deploySetting.tech_territorySequence = new List<String>();
                    }
                }
                }
                if (firstChild.getAttribute('id', null) == 'keywordSettings') {
                List <  Col > ColList = new List <  Col > ();
                    Col ColObject = new  Col();
                    Keyword KeywordO = new  Keyword();
                
                for (Dom.XMLNode secondChild: firstChild.getChildElements()) {
                    if (secondChild.getName() == 'selectedcolumns') {
                    for (Dom.XMLNode thirdChild: secondChild.getChildElements()) {
                    if (thirdChild.getName() == 'column') {
                    ColObject.width = thirdChild.getAttributeValue('width', null);
                    ColObject.name = thirdChild.getAttributeValue('name', null);
                    if (!wo_grid_conf_fields.contains(thirdChild.getAttributeValue('name', null)))
                    wo_grid_conf_fields.add(thirdChild.getAttributeValue('name', null));

                    ColList.add(ColObject);
                    ColObject = new  Col();
                    }
                    }
                    }
                    KeywordO.matchcriteria = '';
                    KeywordO.col = ColList;
                    deploySetting.search_keyword = KeywordO;
                }
                }
                
                if (firstChild.getAttribute('id', null) == 'techKeywordSettings') {
                List <  Col > ColList = new List <  Col > ();
                    Col ColObject = new  Col();
                    TechKeyword TechKeywordO = new  TechKeyword();
                
                for (Dom.XMLNode secondChild: firstChild.getChildElements()) {
                    if (secondChild.getName() == 'selectedcolumns') {
                    for (Dom.XMLNode forthChild: secondChild.getChildElements()) {
                    if (forthChild.getName() == 'column') {
                    ColObject.width = forthChild.getAttributeValue('width', null);
                    ColObject.name = forthChild.getAttributeValue('name', null);
                    ColList.add(ColObject);
                    ColObject = new  Col();
                    }
                    }
                    }
                    TechKeywordO.matchcriteria = firstChild.getAttributeValue('matchcriteria', null);
                    TechKeywordO.col = ColList;
                    deploySetting.search_techKeyword = TechKeywordO;
                }
                }
                
                if (firstChild.getAttribute('id', null) == 'teamKeywordSettings') {
                List <  Col > ColList = new List <  Col > ();
                    Col ColObject = new  Col();
                    TeamKeyword TeamKeywordO = new  TeamKeyword();
                
                for (Dom.XMLNode secondChild: firstChild.getChildElements()) {
                    if (secondChild.getName() == 'selectedcolumns') {
                    for (Dom.XMLNode forthChild: secondChild.getChildElements()) {
                    if (forthChild.getName() == 'column') {
                    ColObject.width = forthChild.getAttributeValue('width', null);
                    ColObject.name = forthChild.getAttributeValue('name', null);
                    ColList.add(ColObject);
                    ColObject = new  Col();
                    }
                    }
                    }
                    TeamKeywordO.matchcriteria = firstChild.getAttributeValue('matchcriteria', null);
                    TeamKeywordO.col = ColList;
                    deploySetting.search_teamKeyword = TeamKeywordO;
                }
                }
                if (firstChild.getName() == 'appDimensions') {
                for (Dom.XMLNode secondChild: firstChild.getChildElements()) {
                  //  system.debug('secondChild :' +secondChild);
                    if (secondChild.getName() == 'map') {
                    deploySetting.map_mapViewportWidth = replaceNullNumber(secondChild.getAttributeValue('width', null),'width');
                    }
                }
                
                }
                deploySetting.wo_grid_conf_fields = wo_grid_conf_fields;
                
                }
                
                uJson = JSON.serialize(deploySetting);
      }
      catch (DmlException ex){
            system.debug('Unable to convert DC user settings from Flash to HTML for user Id: '+userId+'. DML error is - '+ex.getDmlMessage(0));
            throw new DCX_CommonServiceManager.DCxException(ex.getDmlMessage(0));
        }
        catch (Exception ex){
            system.debug('Unable to convert DC user settings from Flash to HTML for user Id: '+userId+'. Error is - '+ex.getmessage());
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
     return uJson;
    
    }
    
   
  private static string replaceNullString(String str, String rootTag) {
      //if(str == null)
      //  return '';
     if(str == null && rootTag == 'filterColumn')
        return 'name';
    else if(str == null && rootTag == 'sortColumn')
        return 'name';
    else if(str == null && rootTag == 'sortOrder')
        return 'DESC';
    else if(str == null && rootTag == 'view')
        return 'territory';
    else if(str == null && rootTag == 'mapDefaultLng')
        return '-118.23761';
    else if(str == null && rootTag == 'loglevel')
        return 'WARN';
    else if(str == null && rootTag == 'locationBase')
        return 'Home';
    else if(str == null && rootTag == 'condition')
        return 'before';   
     else
        return str;
      
  }
    private static string replaceNullNumber(String str, String rootTag) {
        //if(str == null){
            if(str == null && rootTag == 'refreshtime')
                return '7';
            else  if(str == null && rootTag == 'columnIndex')
                return '0';
            else  if(str == null && rootTag == 'toolTipShowDelay')
                return '0';
            else if(str == null && rootTag == 'woHoverColor')
                return '240116';
            else if(str == null && rootTag == 'woSelectionColor')
                return '16761095';
            else if(str == null && rootTag == 'workingHoursColor')
                return '16761095';
            else if(str == null && rootTag == 'toolTipHideDelay')
                return '3000';
            else if(str == null && rootTag == 'timeIndicatorColor')
                return '255';
            else if(str == null && rootTag == 'relatedEventColor')
                return '10066329';
            else if(str == null && rootTag == 'overNightStayColor')
                return '0';
            else if(str == null && rootTag == 'overheadColor')
                return '16750848';
            else if(str == null && rootTag == 'noOfDays')
                return '0';
            else if(str == null && rootTag == 'mapDefaultZoomLevel')
                return '7';
            else if(str == null && rootTag == 'holidayHoursColor')
                return '10592673';
            else if(str == null && rootTag == 'eventRowColor')
                return '11723263';
            else if(str == null && rootTag == 'driveColor')
                return '39372';
            else if(str == null && rootTag == 'defaultWOEventColor')
                return '16776960';
            else if(str == null && rootTag == 'defaultEventColor')
                return '13421568';
            else if(str == null && rootTag == 'width')
                return '300';
       // }
       
        else 
         return str;
  }
  private static string replaceNullBoolean(String str) {
       if(str == null)
        return 'false';
     else
        return str;

  }
  private static Map<Id,List<String>> fetchTeamIds(List<String> userIds) {
    String UserId = UserInfo.getUserId();
    List<SVMXC__Dispatcher_Access__c> AvailTeams = new List<SVMXC__Dispatcher_Access__c>();
    set<String> AvailTeamId = new set<String>();
    Boolean teamAccess = false;
    List<String> teamIds = new List<String>();
    Map<Id,List<String>> dispatcherTeamMap = new Map<Id,List<String>>();
    Map<Id,List<String>> serviceTeamMap = new Map<Id,List<String>>();
    Map<Id,List<String>> finalTeamMap = new Map<Id,List<String>>();
    String QueryStr = 'Select SVMXC__Dispatcher__c,SVMXC__Service_Team__c From SVMXC__Dispatcher_Access__c where SVMXC__Dispatcher__c =: userIds';
   
    try
    {
        for(SVMXC__Dispatcher_Access__c daRec : [Select SVMXC__Dispatcher__c,SVMXC__Service_Team__c From SVMXC__Dispatcher_Access__c 
                                                                                    where SVMXC__Dispatcher__c =: userIds]) {
            if(dispatcherTeamMap.get(daRec.SVMXC__Dispatcher__c) == null) {
                teamIds = new List<String>();
                teamIds.add(daRec.SVMXC__Service_Team__c);
                dispatcherTeamMap.put(daRec.SVMXC__Dispatcher__c,teamIds);
            } else {
                 teamIds = new List<String>();
                teamIds = dispatcherTeamMap.get(daRec.SVMXC__Dispatcher__c);
                teamIds.add(daRec.SVMXC__Service_Team__c);
                dispatcherTeamMap.put(daRec.SVMXC__Dispatcher__c,teamIds);
            }
        }

        for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Salesforce_User__c,SVMXC__Service_Group__c from SVMXC__Service_Group_Members__c where 
                                                                                            SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true]){
            if(serviceTeamMap.get(tech.SVMXC__Salesforce_User__c) == null) {
                teamIds = new List<String>();
                teamIds.add(tech.SVMXC__Service_Group__c);
                serviceTeamMap.put(tech.SVMXC__Salesforce_User__c,teamIds);
            } else {
                 teamIds = new List<String>();
                teamIds = serviceTeamMap.get(tech.SVMXC__Salesforce_User__c);
                teamIds.add(tech.SVMXC__Service_Group__c);
                serviceTeamMap.put(tech.SVMXC__Salesforce_User__c,teamIds);
            }
        }

        for(String uId : userIds) {
            if(dispatcherTeamMap.get(uId) == null) {
                if(serviceTeamMap.get(uId) != null) {
                    finalTeamMap.put(uId,serviceTeamMap.get(uId));
                }
            } else {
                finalTeamMap.put(uId,dispatcherTeamMap.get(uId));
            }
        }
       }
    catch (QueryException ex){
        
    }catch (Exception ex){
        
    }

return finalTeamMap;
}
  
  private static Map<Id,List<String>> fetchTerritoryIds(List<String> userIds) {
   String UserId = UserInfo.getUserId();
        List<SVMXC__Dispatcher_Access__c> AvailTeams = new List<SVMXC__Dispatcher_Access__c>();
        set<String> AvailTeamId = new set<String>();
        Boolean teamAccess = false;
        List<String> teamIds = new List<String>();
        Map<Id,List<String>> dispatcherTeamMap = new Map<Id,List<String>>();
        Map<Id,List<String>> serviceTeamMap = new Map<Id,List<String>>();
        Map<Id,List<String>> finalTeamMap = new Map<Id,List<String>>();
        String QueryStr = 'Select SVMXC__Dispatcher__c,SVMXC__Territory__c From SVMXC__Dispatcher_Access__c where SVMXC__Dispatcher__c =: userIds';
       
        try
        {
            for(SVMXC__Dispatcher_Access__c daRec : [Select SVMXC__Dispatcher__c,SVMXC__Territory__c From SVMXC__Dispatcher_Access__c 
                                                                                        where SVMXC__Dispatcher__c =: userIds]) {
                    system.debug('daRec terr'+daRec);
                if(dispatcherTeamMap.get(daRec.SVMXC__Dispatcher__c) == null) {
                    teamIds = new List<String>();
                    teamIds.add(daRec.SVMXC__Territory__c);
                    dispatcherTeamMap.put(daRec.SVMXC__Dispatcher__c,teamIds);
                } else {
                     teamIds = new List<String>();
                    teamIds = dispatcherTeamMap.get(daRec.SVMXC__Dispatcher__c);
                    teamIds.add(daRec.SVMXC__Territory__c);
                    dispatcherTeamMap.put(daRec.SVMXC__Dispatcher__c,teamIds);
                }
            }

            for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Salesforce_User__c,SVMXC__Service_Territory__c from SVMXC__Service_Group_Members__c where 
                                                                                                SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true]){
                system.debug('tech terr'+tech);
                if(serviceTeamMap.get(tech.SVMXC__Salesforce_User__c) == null) {
                    teamIds = new List<String>();
                    teamIds.add(tech.SVMXC__Service_Territory__c);
                    serviceTeamMap.put(tech.SVMXC__Salesforce_User__c,teamIds);
                } else {
                     teamIds = new List<String>();
                    teamIds = serviceTeamMap.get(tech.SVMXC__Salesforce_User__c);
                    teamIds.add(tech.SVMXC__Service_Territory__c);
                    serviceTeamMap.put(tech.SVMXC__Salesforce_User__c,teamIds);
                }
            }

            for(String uId : userIds) {
                if(dispatcherTeamMap.get(uId) == null) {
                    if(serviceTeamMap.get(uId) != null) {
                        finalTeamMap.put(uId,serviceTeamMap.get(uId));
                    }
                } else {
                    finalTeamMap.put(uId,dispatcherTeamMap.get(uId));
                }
            }
           }
        catch (QueryException ex){
            
        }catch (Exception ex){
            
        }
        return finalTeamMap;

  }
    
    public class ID_WP {
     public Boolean isDispatcher {get; set;}
     public Set<String> ids {get; set;}
     
     public ID_WP(Boolean isDisp, Set<String> idSet) {
       this.isDispatcher = isDisp;
       this.ids = idSet;
     }
   }
    
    public class UserSetting {
        //values are strings
        public String wo_autorefresh {get; set;}
        public String wo_isAlldayEvent {get; set;}
        public String wo_isAdvMode {get; set;}
        public String wo_refreshtime {get; set;}
        public String wo_sortColumn {get; set;}
        public String wo_sortOrder {get; set;}
        public String wo_columnIndex {get; set;}
        public String wo_filterColumn {get; set;}
        public String wo_woHoverColor {get; set;}
        public String wo_defaultView {get; set;}
        public String wo_woSelectionColor {get; set;}
        public String wo_resetTime {get; set;}
        public String wo_unassignWO {get; set;}
        public String wo_deleteEventWo {get; set;}
        public String wo_schedulingAsLongJob {get; set;}
        public String wo_respectTechnincianWorkHours {get; set;}
        public String wo_respectMachineAccessHours {get; set;}
        public String wo_doNotOverlapExistingEvents {get; set;}
        public List<Views> wo_views {get; set;}
        public List<ViewCounter> wo_viewCounter {get; set;}
        public List<WoCol> wo_woCol {get; set;}
        public List<WoRules> wo_woRules {get; set;}
        public String tech_view {get; set;}
        public String tech_enableGoogleMapApi {get; set;}
        public String tech_dcmap {get; set;}
        public String tech_mapDefaultZoomLevel {get; set;}
        public String tech_mapDefaultLat {get; set;}
        public String tech_mapDefaultLng {get; set;}
        public String tech_loglevel {get; set;}
        public String tech_noOfDays {get; set;}
        public String tech_condition {get; set;}
        public String tech_refreshEventsOnChange {get; set;}
        public String tech_retainDateOnShowRoute {get; set;}
        public String tech_autoCalculateEndDate {get; set;}
        public String tech_eventRowColor {get; set;}
        public String tech_driveColor {get; set;}
        public String tech_overheadColor {get; set;}
        public String tech_defaultEventColor {get; set;}
        public String tech_defaultWOEventColor {get; set;}
        public String tech_relatedEventColor {get; set;}
        public String tech_workingHoursColor {get; set;}
        public String tech_holidayHoursColor {get; set;}
        public String tech_overNightStayColor {get; set;}
        public String tech_viewAllEventsForToday {get; set;}
        public String tech_toolTipShowDelay {get; set;}
        public String tech_toolTipHideDelay {get; set;}
        public String tech_pinMapActionBar {get; set;}
        public String tech_showFieldUpdates {get; set;}
        public String tech_showTimeIndicator {get; set;}
        public String tech_timeIndicatorColor {get; set;}
        public String tech_autoSyncServiceDuration {get; set;}
        public String tech_locationBase {get; set;}
        public String tech_dataTipOnClick {get; set;}
        public String tech_showOptionMenu {get; set;}
        public String tech_showSkills {get; set;}
        public String tech_showProductExpertise {get; set;}
        public String tech_showEligibility {get; set;}
        public String tech_showPrefTech {get; set;}
        public String tech_searchSkills {get; set;}
        public String tech_searchProductExpertise {get; set;}
        public String tech_searchEligibility {get; set;}
        public String tech_searchPrefTech {get; set;}
        public String tech_favouriteTeam {get; set;}
        public List<String> tech_ExpandedTeam {get; set;}
        public String tech_favouriteTerritory {get; set;}
        public List<String> tech_expandedTerritory {get; set;}
        public AtsSkills adv_atsSkills {get; set;}
        public AtsExpertise adv_atsExpertise {get; set;}
        public AtsEligibility adv_atsEligibility {get; set;}
        public AtsPrefTech adv_atsPrefTech {get; set;}
        public List<String> tech_teamSequence {get; set;}
        public List<String> tech_territorySequence {get; set;}
        public List<TechCol> tech_techCol {get; set;}
        public List<TechRules> tech_techRules {get; set;}
        public Keyword search_keyword {get; set;}
        public TechKeyword search_techKeyword {get; set;}
        public TeamKeyword search_teamKeyword {get; set;}
        public String map_mapViewportWidth {get; set;}
        public List<String> wo_grid_conf_fields {get; set;}
        public List<String> wo_grid_col_fields {get; set;}
        public List<String> wo_sch_col_fields {get; set;} 
    }
    
    public class Views {
        public String name {get; set;}
        public String id {get; set;}
        public String column {get; set;}
        public String sortOrder {get; set;}
        public String columnIndex {get; set;}
    }
    
    public class ViewCounter {
        public String color {get; set;}
        public String name {get; set;}
        public String id {get; set;}
        public String column {get; set;}
        public String sortOrder {get; set;}
        public String columnIndex {get; set;}
    }
    
    public class  WoCol {
        public String name {get; set;}
        public String width {get; set;}
    }
    
    public class WoRules {
        public String name {get; set;}
        public String status {get; set;}
        public String expression {get; set;}
        public String color {get; set;}
        public List<Operand> operand {get; set;}
    }
    
    public class TechCol {
        public String name {get; set;}
        public String width {get; set;}
    }
    
    public class TechRules {
        public String name {get; set;}
        public String status {get; set;}
        public String expression {get; set;}
        public String color {get; set;}
        public List<Operand> operand {get; set;}
        public String ruleType {get;set;}
    }
    
    public class Operand {
        public String property {get; set;}
        public String type {get; set;}
        public String fieldType {get; set;}
        public String compare {get; set;}
        public String value {get; set;}
    }

    public class Keyword {
        public String matchcriteria {get; set;}
        public List<Col> col {get; set;}
    }
    
    public class TechKeyword {
        public String matchcriteria {get; set;}
        public List<Col> col {get; set;}
    }
    
    public class TeamKeyword {
        public String matchcriteria {get; set;}
        public List<Col> col {get; set;}
    }
    
    public class Col {
        public String name {get; set;}
        public String width {get; set;}
    }
    
    public class AtsSkills {
        public String show {get; set;}
        public String search {get; set;}
    }
    
    public class AtsExpertise {
        public String show {get; set;}
        public String search {get; set;}
    }
    
    public class AtsEligibility {
        public String show {get; set;}
        public String search {get; set;}
    }
    
    public class AtsPrefTech {
        public String show {get; set;}
        public String search {get; set;}
    }
    
    public class testSetting{
        public String autorefresh {get; set;}
        public String isAlldayEvent {get; set;}
        public String isAdvMode {get; set;}
    }

    

    public class KeyValuePair_WP {
        public String keyType{get; set;}
        public String key{get; set;}
        public String value{get; set;}
        public KeyValuePair_WP(){}
        public KeyValuePair_WP(String keyType, String key, String value) {
            this.keyType = keyType;
            this.key = key;
            this.value = value;
        }   
    }


}