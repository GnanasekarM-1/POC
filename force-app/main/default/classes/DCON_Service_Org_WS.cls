global class DCON_Service_Org_WS {

    //Method to return exemptions
    public class SVMXException extends Exception {}
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    
    global class Technician_WP{
        WebService SVMXC__Service_Group_Members__c technician_O {get;set;}
        //DNS-572: Sending Service_Group_Site object to client for active homebase address
        WebService SVMXC__Service_Group_Site__c location_O {get;set;}
        WebService List<TechnicianSpecialFields_WP> specialFields_LWP {get; set;}
        Webservice list<String> hoverInfo = new  list<String>();
        public Technician_WP(SVMXC__Service_Group_Members__c t, SVMXC__Service_Group_Site__c l, List<TechnicianSpecialFields_WP> references){
            technician_O = t;
            location_O = l;
            specialFields_LWP = references;
        }
        global list<String> gethoverInfo(){return hoverInfo;}
        global void sethoverInfo(){this.hoverInfo = hoverInfo;}
    }
    global class Team_WP{
        WebService SVMXC__Service_Group__c team_O {get;set;}
        Webservice list<String> hoverInfo = new  list<String>();
        public Team_WP(SVMXC__Service_Group__c objTeam){
            team_O = objTeam;
        }
        global list<String> gethoverInfo(){return hoverInfo;}
        global void sethoverInfo(){this.hoverInfo = hoverInfo;}
    }
    global class TechnicianSpecialFields_WP{
        WebService String key {get; set;}
        WebService String value {get; set;}
        public TechnicianSpecialFields_WP(String tK, String tV){
            this.key = tK;
            this.value = tV;
        }
    }
    
    //DNS #1043 
    global class Tech_WorkingHours{
        WebService List<tech_business_break_hrs> tech_business_break_Ids {get; set;}
        WebService List<BusinessHours> tech_business_hrs {get; set;}
        WebService List<BusinessHours> tech_break_hrs {get; set;}
        WebService List<Businesshrs_Holidays> businesshrs_lstholidays {get; set;}
        
        public Tech_WorkingHours(List<tech_business_break_hrs> business_break_Ids,List<BusinessHours> business_hrs,List<BusinessHours> break_hrs, List<Businesshrs_Holidays> bh_holidays){
            this.tech_business_break_Ids = business_break_Ids;
            this.tech_business_hrs = business_hrs;
            this.tech_break_hrs = break_hrs;
            this.businesshrs_lstholidays = bh_holidays;
        }
        
    }
    //DNS #1043 
    global class tech_business_break_hrs
    {
        webservice String techID{get; set;}
        webservice String businesshrID{get; set;}
        webservice String breakhrID{get; set;}
        public tech_business_break_hrs(String t, String bs, String br)
        {
            this.techID = t;
            this.businesshrID = bs;
            this.breakhrID = br;    
        }
    }
    //DNS #1043 
    global class Businesshrs_Holidays
    {
        webservice String BHID{get; set;}
        webservice List<Date> Holidays{get; set;}
        webservice String TimeZoneSidKey{get; set;}
        public Businesshrs_Holidays(String bid, List<Date> h, String tz)
        {
            this.BHID = bid;
            this.Holidays = h;
            this.TimeZoneSidKey = tz;
        }
    }

    //This method provides list of Teams for building the Tean/Technician Tree
    WebService static List<SVMXC__Service_Group__c> DCON_Retrieve_Team_Tree_WS(String UserId, Boolean RetrieveAllRecords){
        RetrieveAllRecords = false;
        List<SVMXC__Dispatcher_Access__c> AvailTeams = new List<SVMXC__Dispatcher_Access__c>();
        List<SVMXC__Service_Group__c> TeamList = new List<SVMXC__Service_Group__c>();
        set<String> AvailTeamId = new set<String>();
        String QueryStr = 'Select SVMXC__Service_Team__c From SVMXC__Dispatcher_Access__c';
        if(RetrieveAllRecords==false)
            QueryStr += ' where SVMXC__Dispatcher__c =: UserId';
        
        try
        {
            system.debug('TESET QUERY:'+QueryStr);    
            AvailTeams = Database.query(QueryStr);
            if(AvailTeams.size() == 0){
                for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Group__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true]){
                    AvailTeamId.add(tech.SVMXC__Service_Group__c);
                }
            }
            else {
                for(SVMXC__Dispatcher_Access__c at: AvailTeams){
                    AvailTeamId.add(at.SVMXC__Service_Team__c);
                }
            }
        }
        catch (DmlException ex){
            throw new SVMXException(ex.getDmlMessage(0));
        }catch (Exception ex){
            throw new SVMXException(ex.getmessage());
        }
        return [Select Id, Name, SVMXC__Latitude__c, SVMXC__Longitude__c,SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Zip__c,SVMXC__Country__c From SVMXC__Service_Group__c where Id IN :AvailTeamId];
    }
    
    WebService static List<Team_WP> DCON_Retrieve_Team_Tree_WS1(String UserId)
    {
        List<Team_WP> team_LWP = new List<Team_WP>();
        List<SVMXC__Dispatcher_Access__c> AvailTeams = new List<SVMXC__Dispatcher_Access__c>();
        set<String> AvailTeamId = new set<String>();        
        SVMXC__ServiceMax_Processes__c objHoverHeader = new SVMXC__ServiceMax_Processes__c();
        list<SVMXC__ServiceMax_Processes__c> lstHoverHeader = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstHoverConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        map<String,String> mapAPINameLabel = new map<String,String>();
        DCON_Utils.referenceFields_WP reference_M;
        Map<String,String> replacementRef = new Map<String,String>();
        Map<String,String> replacementNameField = new  Map<String,String> ();
        DCON_Utils dcUtils = new DCON_Utils(); 
        String QueryStr = 'Select SVMXC__Service_Team__c From SVMXC__Dispatcher_Access__c where SVMXC__Dispatcher__c =: UserId';
        try
        {
            system.debug('TESET QUERY:'+QueryStr);      
            AvailTeams = Database.query(QueryStr);        
            if(AvailTeams.size() == 0){
                for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Group__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true]){
                    AvailTeamId.add(tech.SVMXC__Service_Group__c);
                }
            }
            else{
                for(SVMXC__Dispatcher_Access__c at: AvailTeams){
                    AvailTeamId.add(at.SVMXC__Service_Team__c);
                }
            }
            // Get Hover Info for team     
            lstHoverHeader = [select id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Column Info' and SVMXC__Source_Object_Name__c = 'SVMXC__Service_Group__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('objHoverHeader: '+objHoverHeader);
            if(lstHoverHeader != null && lstHoverHeader.size() > 0)
            {
                objHoverHeader = lstHoverHeader[0];
            }
            //Getting corresponding config data having list of fields to be dispalyed on hover
            if(objHoverHeader != null && objHoverHeader.id != null)
                lstHoverConfigData = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: objHoverHeader.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field' order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('lstHoverConfigData'+lstHoverConfigData);
            Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Group__c.fields.getMap(); // Get field definition map for Team       
            
            //Loop it and create map of APIName and label for Map Hover
            if(souObjfieldMap.size() > 0)
            {
                for(String str : souObjfieldMap.keyset())
                    mapAPINameLabel.put(souObjfieldMap.get(str).getDescribe().getName(),souObjfieldMap.get(str).getDescribe().getLabel());
                reference_M = dcUtils.SVMX_getReferenceFields(souObjfieldMap,true);
                replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map 
                replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
            }
            
            String querySelect = '';
            SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();  
            List<String> allFields_L = reference_M.allFields_L; //Get the all field list
            querySelect = utils.SVMX_getFieldNamesFromList(allFields_L); //Convert the list f strings to coma seperated string
            System.debug('Team Ref  '+querySelect);
            String queryString = '';
            if(querySelect != '')
                queryString = 'Select ' + querySelect ;   
            
            queryString = queryString + ' From SVMXC__Service_Group__c where Id IN :AvailTeamId';
            System.debug('queryString hover  '+queryString);
            System.debug('allFields_L hover  '+allFields_L);
            
            if(queryString != NULL)
            {
                for(SVMXC__Service_Group__c objTeam: Database.query(queryString))
                {
                    Team_WP objTeam_WP = new Team_WP(objTeam);
                    //Building Hover info(each string is in the format field name:value)
                    if(lstHoverConfigData.size() > 0)
                    {
                        list<String> lstHover = new list<String>();
                        for(Integer j = 0;j<lstHoverConfigData.size();j++)
                        {
                            String str = '';
                            if(lstHoverConfigData[j].SVMXC__Field_Name__c != null && mapAPINameLabel.containskey(lstHoverConfigData[j].SVMXC__Field_Name__c))
                            {
                                //Adding field label
                                str = '<B>'+mapAPINameLabel.get(lstHoverConfigData[j].SVMXC__Field_Name__c)+ '</B>: ';
                                //Adding value
                                //Checking whether the field is a referernce field
                                if(lstHoverConfigData[j].SVMXC__Display_Type__c != null && lstHoverConfigData[j].SVMXC__Display_Type__c.touppercase() == 'REFERENCE' && objTeam.get(lstHoverConfigData[j].SVMXC__Field_Name__c) != null)
                                {
                                    Sobject objRef = objTeam.getSobject(replacementRef.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                                    if(objRef!=NULL)
                                        str = str +String.valueof(objRef.get(replacementNameField.get(lstHoverConfigData[j].SVMXC__Field_Name__c)));
                                }
                                else if(lstHoverConfigData[j].SVMXC__Display_Type__c != null && lstHoverConfigData[j].SVMXC__Display_Type__c.touppercase() != 'REFERENCE' && objTeam.get(lstHoverConfigData[j].SVMXC__Field_Name__c) != null)
                                    str = str + String.valueof(objTeam.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                                
                                lstHover.add(str);
                            }   
                        }
                    }
                    system.debug('TEST EACH team. '+objTeam_WP);
                    team_LWP.add(objTeam_WP);
                }
            }  
        }
        catch (DmlException ex)
        {
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch (Exception ex)
        {
            throw new SVMXException(ex.getmessage());
        }
        return team_LWP;
    }

    public class Address{
        String street{get; set;}
        String city{get; set;}
        String state{get; set;}
        String zip{get; set;}
        String country{get; set;}
        Double latitude{get; set;}
        Double longitude{get; set;}
    }

    //This method provides the details of tech's if they are updated
    WebService static List<Technician_WP> DCON_Retrieve_TechnicianInfo_Tree_WS(String keyValPairs, List<String> TechIds, String UserId)
    {
        String timeZone;
        Datetime dtmLastRetrievedDateTime = null;
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();  
        DCON_Utils dcUtils = new DCON_Utils(); 
        String querySelect;
        List<Technician_WP> technician_LWP = new List<Technician_WP>();
        try
        {
            if(!UserId.equals(Userinfo.getUserId()))
                timeZone = [SELECT TimeZoneSidKey from User where Id = :UserId].TimeZoneSidKey;
            else
                timeZone = Userinfo.getTimeZone().getID();

            if(keyValPairs != null && keyValPairs.length()> 0)
            {
                String keyvaluepair = keyValPairs;
                keyvaluepair = keyvaluepair.replace('|',':');
                list<String> keyvaluepairlist = new list<String>(); 
                keyvaluepairlist = keyvaluepair.split(':');
                if(keyvaluepairlist != NULL && keyvaluepairlist[0] == 'LRD')
                {
                    if(keyvaluepairlist[1] != NULL)
                    {
                    try{
                        dtmLastRetrievedDateTime = Datetime.valueOf(long.valueOf(keyvaluepairlist[1]));
                        }
                        catch(Exception ex)
                          {
                          }
                    }
                }
            }
            // Get Hover Info for Technician
            SVMXC__ServiceMax_Processes__c objHoverHeader = new SVMXC__ServiceMax_Processes__c();
            list<SVMXC__ServiceMax_Processes__c> lstHoverHeader = new list<SVMXC__ServiceMax_Processes__c>();
            list<SVMXC__ServiceMax_Config_Data__c> lstHoverConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
            //Getting hover info
            lstHoverHeader = [select id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Column Info' and SVMXC__Source_Object_Name__c = 'SVMXC__Service_Group_Members__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('objHoverHeader: '+objHoverHeader);
            if(lstHoverHeader != null && lstHoverHeader.size() > 0)
            {
                objHoverHeader = lstHoverHeader[0];
            }
            
            //Retrieving related config which has list of fields to be displayed on hover
            if(objHoverHeader != null && objHoverHeader.id != null)
                lstHoverConfigData = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: objHoverHeader.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field' order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            system.debug('lstHoverConfigData'+lstHoverConfigData);
            system.debug('dtmLastRetrievedDateTime'+dtmLastRetrievedDateTime);
            String QueryStr;
            // Get field definition map for work order
            Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap();
            map<String,String> mapAPINameLabel = new map<String,String>();
            
            //Loop it and create map of APIName and label for Map Hover
            if(souObjfieldMap.size() > 0)
            {
                for(String str : souObjfieldMap.keyset())
                {
                    mapAPINameLabel.put(souObjfieldMap.get(str).getDescribe().getName(),souObjfieldMap.get(str).getDescribe().getLabel());
                }
            }

            system.debug('lstHoverConfigData'+lstHoverConfigData);
            Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
            List<String> lstTechFieldsToLoad = new list<string>();
            set<String> setTechFieldsToLoad = new set<string>();
            setTechFieldsToLoad = getTechFieldstoLoad();

            //Get only those WO fields which has to be populated, we can skip the rest
            for (String fieldKey : souObjfieldMap.keySet()) 
            {
                String fieldName='';
                Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                fieldName = f.getName();
                if(setTechFieldsToLoad.contains(fieldName))
                    newSchemaFieldMap.put(fieldName, fsObj);
            }
            
            DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);
            souObjfieldMap.clear();
            lstTechFieldsToLoad = reference_M.allFields_L;
            List<String> refFields_L = reference_M.referenceFields_L; //Get the reference field list
            List<String> dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
            List<String> dateFields_L = reference_M.dateFields_L; //Get the date field list
            Map<String,String> replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
            Map<String,String> replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map

            System.debug('lstTechFieldsToLoad: '+lstTechFieldsToLoad);
            querySelect = utils.SVMX_getFieldNamesFromList(lstTechFieldsToLoad);
            
            if(dtmLastRetrievedDateTime!=null)
                QueryStr = 'Select '+querySelect+',SVMXC__Service_Group__r.SVMXC__Latitude__c,SVMXC__Service_Group__r.SVMXC__Longitude__c,SVMXC__Service_Group__r.SVMXC__Street__c,SVMXC__Service_Group__r.SVMXC__City__c,SVMXC__Service_Group__r.SVMXC__State__c,SVMXC__Service_Group__r.SVMXC__Zip__c,SVMXC__Service_Group__r.SVMXC__Country__c  From SVMXC__Service_Group_Members__c where Id IN :TechIds AND LastModifiedDate >= :dtmLastRetrievedDateTime';
            else
                QueryStr = 'Select '+querySelect+',SVMXC__Service_Group__r.SVMXC__Latitude__c,SVMXC__Service_Group__r.SVMXC__Longitude__c,SVMXC__Service_Group__r.SVMXC__Street__c,SVMXC__Service_Group__r.SVMXC__City__c,SVMXC__Service_Group__r.SVMXC__State__c,SVMXC__Service_Group__r.SVMXC__Zip__c,SVMXC__Service_Group__r.SVMXC__Country__c  From SVMXC__Service_Group_Members__c where Id IN :TechIds';
            
            system.debug('QueryStr'+QueryStr);
            Technician_WP Technician_WP;
            List<TechnicianSpecialFields_WP> specialFields_LWP;
            //Setup the latlong of Home base if exist
            set<String> tech_s = new set<String>();
            Map<String, Address> techHB_M = new Map<String, Address>();
            
            if((QueryStr != NULL) && (QueryStr != ''))
            {   
                for(SVMXC__Service_Group_Members__c tech: Database.query(QueryStr)){
                    tech_s.add(tech.Id);
                }
                if(tech_s.size() > 0)
                {
                    Map<String, SVMXC__Service_Group_Site__c> temp_techHB = new Map<String, SVMXC__Service_Group_Site__c>();
                    for(SVMXC__Service_Group_Site__c hb: [SELECT SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Technician_Equipment__c, SVMXC__Zip__c from SVMXC__Service_Group_Site__c where SVMXC__Technician_Equipment__c IN :tech_s AND SVMXC__Latitude__c != NULL AND SVMXC__Longitude__c != NULL AND SVMXC__IsCurrent__c = TRUE AND RecordType.Name='Home Bases']){
                        Address tempAddress = new Address();
                        tempAddress.street = hb.SVMXC__Street__c;
                        tempAddress.city = hb.SVMXC__City__c;
                        tempAddress.state = hb.SVMXC__State__c;
                        tempAddress.country = hb.SVMXC__Country__c;
                        tempAddress.zip = hb.SVMXC__Zip__c;
                        tempAddress.latitude = hb.SVMXC__Latitude__c;
                        tempAddress.longitude = hb.SVMXC__Longitude__c;
                        techHB_M.put(hb.SVMXC__Technician_Equipment__c, tempAddress);
                        temp_techHB.put(hb.SVMXC__Technician_Equipment__c,hb);
                    }
                    tech_s.clear(); // Defect 24494: releasing the data - not used anymore
                    for(SVMXC__Service_Group_Members__c tech: Database.query(QueryStr)){
                        specialFields_LWP = new List<TechnicianSpecialFields_WP>();
                        for(String s : refFields_L){
                            TechnicianSpecialFields_WP tRef;
                            Sobject ref_TO;
                            
                            if(setTechFieldsToLoad.contains(s))
                                ref_TO = tech.getSobject(replacementRef.get(s));
                            
                            if(ref_TO!=NULL){
                                tRef = new TechnicianSpecialFields_WP(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
                                specialFields_LWP.add(tRef);
                            }      
                        }

                        for(String s : dateTimeFields_L){
                            TechnicianSpecialFields_WP tDateTime;
                            if(setTechFieldsToLoad.contains(s) && tech.get(s) != NULL){
                                system.debug('TEST DateTime Local Format '+tech.get(s)+Datetime.valueof(String.valueof(tech.get(s))).format() );
                                tDateTime = new TechnicianSpecialFields_WP(s, dcUtils.getDateTimeInTimezone(Datetime.valueof(tech.get(s)).date(), Datetime.valueof(tech.get(s)).time(), timeZone).format() );
                                specialFields_LWP.add(tDateTime);
                            }
                        }

                        for(String s : dateFields_L){
                            TechnicianSpecialFields_WP tDate;
                            if(setTechFieldsToLoad.contains(s) && tech.get(s) != NULL){
                                system.debug('TEST EACH local DATE: '+tech.get(s)+Date.valueof(String.valueof(tech.get(s))).format() );
                                tDate = new TechnicianSpecialFields_WP(s, Date.valueof(String.valueof(tech.get(s))).format() );
                                specialFields_LWP.add(tDate);
                            }
                            //defect no: 039592 
                            //moving following lines out of the loop to details of technician record when it get updated irrespective of dateFields_L availability
                            /*
                            //DNS-572
                            if(temp_techHB.get(tech.id) != NULL)
                            {
                                Technician_WP = new Technician_WP(tech,temp_techHB.get(tech.id),specialFields_LWP);  
                            }
                            else
                            {
                                Technician_WP = new Technician_WP(tech,null,specialFields_LWP);  
                            }
                            */
                            //Building hover info  (Field name:Value)
                            if(lstHoverConfigData.size() > 0)
                            {
                                list<String> lstHover = new list<String>();
                                for(Integer j = 0;j<lstHoverConfigData.size();j++)
                                {
                                    String str = '';
                                    if(lstHoverConfigData[j].SVMXC__Field_Name__c != null && mapAPINameLabel.containskey(lstHoverConfigData[j].SVMXC__Field_Name__c))
                                    {
                                        //Adding field label
                                        str = '<B>'+mapAPINameLabel.get(lstHoverConfigData[j].SVMXC__Field_Name__c)+ '</B>: ';
                                        //Checking if it is a reference field
                                        if(lstHoverConfigData[j].SVMXC__Display_Type__c != null && lstHoverConfigData[j].SVMXC__Display_Type__c.touppercase() == 'REFERENCE' && tech.get(lstHoverConfigData[j].SVMXC__Field_Name__c) != null)
                                        {   
                                            Sobject objRef = tech.getSobject(replacementRef.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                                            if(objRef!=NULL)
                                                str = str +String.valueof(objRef.get(replacementNameField.get(lstHoverConfigData[j].SVMXC__Field_Name__c)));
                                        }
                                        else if(lstHoverConfigData[j].SVMXC__Display_Type__c != null && lstHoverConfigData[j].SVMXC__Display_Type__c.touppercase() != 'REFERENCE' && tech.get(lstHoverConfigData[j].SVMXC__Field_Name__c) != null)                           
                                            str = str + String.valueof(tech.get(lstHoverConfigData[j].SVMXC__Field_Name__c));

                                        lstHover.add(str);
                                    }   
                                }
                            }   
                            //update defect no: 039592      
                           /* system.debug('TEST EACH tech. '+Technician_WP);
                            technician_LWP.add(Technician_WP); */
                        }
                        if(temp_techHB.get(tech.id) != NULL)
                        {
                            Technician_WP = new Technician_WP(tech,temp_techHB.get(tech.id),specialFields_LWP);  
                        }
                        else
                        {
                            Technician_WP = new Technician_WP(tech,null,specialFields_LWP);  
                        }
                        system.debug('TEST EACH tech. '+Technician_WP);
                        technician_LWP.add(Technician_WP);  
                    } 
                }
            }
        }
        catch (DmlException ex)
        {
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch (Exception ex){
            system.debug('printing in catch block'+ ex.getStacktracestring());
            throw new SVMXException(ex.getmessage());
        }
        return technician_LWP;
    }

    //This method provides list of Technicians for building the Tean/Technician Tree or Territory Tree
    WebService static List<Technician_WP> DCON_Retrieve_Technician_Tree_WS(String UserId, String SearchType, Boolean RetrieveAllRecords,String timeZone,List<String> ServiceTeamTerr)
    {
        RetrieveAllRecords = false;
        system.debug('TEST S: '+UserId+ServiceTeamTerr+SearchType+RetrieveAllRecords+timeZone);
        
        if(SearchType.toUpperCase()!='TERRITORY' && SearchType.toUpperCase()!='TEAM')
            throw new SVMXException('Please specify searchtype for your request');
        
        /* Import required classes */
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();  
        DCON_Utils dcUtils = new DCON_Utils(); 
        /* Variable definitions */
        String querySelect; 
        Boolean isLocal = false;
        Boolean isDispatcher = true;
        List<Technician_WP> technician_LWP = new List<Technician_WP>(); //Result set for the method
        
        try
        {
            if(!UserId.equals(Userinfo.getUserId()))
                timeZone = [SELECT TimeZoneSidKey from User where Id = :UserId].TimeZoneSidKey;
            else
            {
                timeZone = Userinfo.getTimeZone().getID();
                isLocal = true;
            }
            Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap(); // Get field definition map for work order
            map<String,String> mapAPINameLabel = new map<String,String>();
            //Loop it and create map of APIName and label for Map Hover
            if(souObjfieldMap.size() > 0)
            {
                for(String str : souObjfieldMap.keyset())
                {
                    mapAPINameLabel.put(souObjfieldMap.get(str).getDescribe().getName(),souObjfieldMap.get(str).getDescribe().getLabel());
                }
            }
            // Get Hover Info for Technician
            SVMXC__ServiceMax_Processes__c objHoverHeader = new SVMXC__ServiceMax_Processes__c();
            list<SVMXC__ServiceMax_Processes__c> lstHoverHeader = new list<SVMXC__ServiceMax_Processes__c>();
            list<SVMXC__ServiceMax_Config_Data__c> lstHoverConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
            lstHoverHeader = [select id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Column Info' and SVMXC__Source_Object_Name__c = 'SVMXC__Service_Group_Members__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('objHoverHeader: '+objHoverHeader);
            if(lstHoverHeader != null && lstHoverHeader.size() > 0)
            {
                objHoverHeader = lstHoverHeader[0];
            }
            if(objHoverHeader != null && objHoverHeader.id != null)
                lstHoverConfigData = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: objHoverHeader.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field' order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            system.debug('lstHoverConfigData'+lstHoverConfigData);
            Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
            List<String> lstTechFieldsToLoad = new list<string>();
            set<String> setTechFieldsToLoad = new set<string>();
            setTechFieldsToLoad = getTechFieldstoLoad();

            //Get only those WO fields which has to be populated, we can skip the rest
            for (String fieldKey : souObjfieldMap.keySet()) 
            {
                String fieldName='';
                Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                fieldName = f.getName();
                if(setTechFieldsToLoad.contains(fieldName))
                    newSchemaFieldMap.put(fieldName, fsObj);
            }
            
            DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);
            souObjfieldMap.clear();
            lstTechFieldsToLoad = reference_M.allFields_L;
            List<String> refFields_L = reference_M.referenceFields_L; //Get the reference field list
            List<String> dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
            List<String> dateFields_L = reference_M.dateFields_L; //Get the date field list
            Map<String,String> replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
            Map<String,String> replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map

            System.debug('lstTechFieldsToLoad: '+lstTechFieldsToLoad);
            querySelect = utils.SVMX_getFieldNamesFromList(lstTechFieldsToLoad);

            if(ServiceTeamTerr.size()==0 && SearchType=='TEAM'){
                List<SVMXC__Service_Group__c> serviceTeamList = new List<SVMXC__Service_Group__c>();
                serviceTeamList = DCON_Service_Org_WS.DCON_Retrieve_Team_Tree_WS(UserId, RetrieveAllRecords);
                for(SVMXC__Service_Group__c sl: serviceTeamList){
                    ServiceTeamTerr.add(sl.Id);
                }
                serviceTeamList.clear(); // Defect 24494: releasing the data - not used anymore
                List<SVMXC__Dispatcher_Access__c> AvailTeams = new List<SVMXC__Dispatcher_Access__c>();
                String QueryStr = 'Select SVMXC__Service_Team__c From SVMXC__Dispatcher_Access__c where SVMXC__Dispatcher__c =: UserId';
                AvailTeams = Database.query(QueryStr);
                if(AvailTeams.size() == 0){
                    isDispatcher = false;
                } else {    
                    AvailTeams.clear(); // Defect 24494: releasing the data - not used anymore
                }
                system.debug('TEST WSNOP:');
            }
            system.debug('TEST WS'+ServiceTeamTerr+ServiceTeamTerr.size());
            if(ServiceTeamTerr.size()==0 && SearchType=='TERRITORY'){
                List<SVMXC__Territory__c> TerritoryList = new List<SVMXC__Territory__c>();
                TerritoryList = DCON_Service_Org_WS.DCON_Retrieve_Territory_Tree_WS(UserId, RetrieveAllRecords);
                for(SVMXC__Territory__c tt: TerritoryList){
                    ServiceTeamTerr.add(tt.Id);
                }
                TerritoryList.clear(); // Defect 24494: releasing the data - not used anymore   
                List<SVMXC__Dispatcher_Access__c> AvailTeams = new List<SVMXC__Dispatcher_Access__c>();
                String QueryStr = 'Select SVMXC__Territory__c From SVMXC__Dispatcher_Access__c where SVMXC__Dispatcher__c =: UserId';
                AvailTeams = Database.query(QueryStr);
                if(AvailTeams.size() == 0){
                    isDispatcher = false;
                } else {
                    AvailTeams.clear(); // Defect 24494: releasing the data - not used anymore  
                }
            }
            String QueryStr;  
            String serviceTeamInVal = dcUtils.SVMX_get_ListOfValues(ServiceTeamTerr);  
            if(SearchType.toUpperCase()=='TEAM' && ServiceTeamTerr.size()>0){
                if(isDispatcher == true)
                    QueryStr = 'Select '+querySelect+',SVMXC__Service_Group__r.SVMXC__Latitude__c,SVMXC__Service_Group__r.SVMXC__Longitude__c,SVMXC__Service_Group__r.SVMXC__Street__c,SVMXC__Service_Group__r.SVMXC__City__c,SVMXC__Service_Group__r.SVMXC__State__c,SVMXC__Service_Group__r.SVMXC__Zip__c,SVMXC__Service_Group__r.SVMXC__Country__c  From SVMXC__Service_Group_Members__c where SVMXC__Service_Group__c IN :ServiceTeamTerr AND SVMXC__Active__c=true';
                else
                    QueryStr = 'Select '+querySelect+',SVMXC__Service_Group__r.SVMXC__Latitude__c,SVMXC__Service_Group__r.SVMXC__Longitude__c,SVMXC__Service_Group__r.SVMXC__Street__c,SVMXC__Service_Group__r.SVMXC__City__c,SVMXC__Service_Group__r.SVMXC__State__c,SVMXC__Service_Group__r.SVMXC__Zip__c,SVMXC__Service_Group__r.SVMXC__Country__c  From SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true';
            }
            else if(SearchType.toUpperCase()=='TERRITORY' && ServiceTeamTerr.size()>0){
                if(isDispatcher == true)
                    QueryStr = 'Select '+querySelect+' From SVMXC__Service_Group_Members__c where SVMXC__Service_Territory__c IN :ServiceTeamTerr AND SVMXC__Active__c=true';
                else
                    QueryStr = 'Select '+querySelect+' From SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true';
            }
            
            system.debug('TEST QUERY: Select '+querySelect+' From SVMXC__Service_Group_Members__c where SVMXC__Service_Group__c IN :ServiceTeamTerr AND SVMXC__Active__c=true');
            Technician_WP Technician_WP;
            List<TechnicianSpecialFields_WP> specialFields_LWP;
            //Setup the latlong of Home base if exist
            set<String> tech_s = new set<String>();
            Map<String, Address> techHB_M = new Map<String, Address>();
            
            if((QueryStr != NULL) && (QueryStr != ''))
            {
                for(SVMXC__Service_Group_Members__c tech: Database.query(QueryStr)){
                    tech_s.add(tech.Id);
                }
                if(tech_s.size() > 0)
                {
                    Map<String, SVMXC__Service_Group_Site__c> temp_techHB = new Map<String, SVMXC__Service_Group_Site__c>();
                    for(SVMXC__Service_Group_Site__c hb: [SELECT SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Technician_Equipment__c, SVMXC__Zip__c from SVMXC__Service_Group_Site__c where SVMXC__Technician_Equipment__c IN :tech_s AND SVMXC__Latitude__c != NULL AND SVMXC__Longitude__c != NULL AND SVMXC__IsCurrent__c = TRUE AND RecordType.Name='Home Bases']){
                        Address tempAddress = new Address();
                        tempAddress.street = hb.SVMXC__Street__c;
                        tempAddress.city = hb.SVMXC__City__c;
                        tempAddress.state = hb.SVMXC__State__c;
                        tempAddress.country = hb.SVMXC__Country__c;
                        tempAddress.zip = hb.SVMXC__Zip__c;
                        tempAddress.latitude = hb.SVMXC__Latitude__c;
                        tempAddress.longitude = hb.SVMXC__Longitude__c;
                        techHB_M.put(hb.SVMXC__Technician_Equipment__c, tempAddress);
                        temp_techHB.put(hb.SVMXC__Technician_Equipment__c, hb);
                    }

                    tech_s.clear(); // Defect 24494: releasing the data - not used anymore     
                    //14494 
                    for(SVMXC__Service_Group_Members__c tech: Database.query(QueryStr)){
                        specialFields_LWP = new List<TechnicianSpecialFields_WP>();
                        //Setup homebase lat lng if any
                        if(techHB_M.get(tech.id) != NULL){
                            Address tempAddress = techHB_M.get(tech.id);
                        }
                        for(String s : refFields_L){
                            TechnicianSpecialFields_WP tRef;
                            Sobject ref_TO;
                            if(setTechFieldsToLoad.contains(s))
                            {
                                system.debug(' s: '+s+' replacementRef.get(s): '+replacementRef.get(s));
                                ref_TO = tech.getSobject(replacementRef.get(s));
                            }
                            if(ref_TO!=NULL){
                                tRef = new TechnicianSpecialFields_WP(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
                                specialFields_LWP.add(tRef);
                            }
                        }

                        for(String s : dateTimeFields_L){
                            TechnicianSpecialFields_WP tDateTime;
                            if(setTechFieldsToLoad.contains(s) && tech.get(s) != NULL){
                            //if(tech.get(s) != NULL){
                                system.debug('TEST DateTime Local Format '+tech.get(s)+Datetime.valueof(String.valueof(tech.get(s))).format() );
                                tDateTime = new TechnicianSpecialFields_WP(s, dcUtils.getDateTimeInTimezone(Datetime.valueof(tech.get(s)).date(), Datetime.valueof(tech.get(s)).time(), timeZone).format() );
                                specialFields_LWP.add(tDateTime);
                            }
                        }

                        for(String s : dateFields_L){
                            TechnicianSpecialFields_WP tDate;
                            if(setTechFieldsToLoad.contains(s) &&tech.get(s) != NULL){
                            //if(tech.get(s) != NULL){
                                system.debug('TEST EACH local DATE: '+tech.get(s)+Date.valueof(String.valueof(tech.get(s))).format() );
                                tDate = new TechnicianSpecialFields_WP(s, Date.valueof(String.valueof(tech.get(s))).format() );
                                specialFields_LWP.add(tDate);
                            }
                        }
                        //DNS-572
                        if(temp_techHB.get(tech.id) != NULL)
                        {
                            Technician_WP = new Technician_WP(tech,temp_techHB.get(tech.id),specialFields_LWP);  
                        }
                        else
                        {
                            Technician_WP = new Technician_WP(tech,null,specialFields_LWP);   
                        }

                        if(lstHoverConfigData.size() > 0)
                        {
                            list<String> lstHover = new list<String>();
                            for(Integer j = 0;j<lstHoverConfigData.size();j++)
                            {
                                String str = '';
                                if(lstHoverConfigData[j].SVMXC__Field_Name__c != null && mapAPINameLabel.containskey(lstHoverConfigData[j].SVMXC__Field_Name__c))
                                {
                                    str = '<B>'+mapAPINameLabel.get(lstHoverConfigData[j].SVMXC__Field_Name__c) +'</B>: ';
                                    if(lstHoverConfigData[j].SVMXC__Display_Type__c != null && lstHoverConfigData[j].SVMXC__Display_Type__c.touppercase() == 'REFERENCE' && tech.get(lstHoverConfigData[j].SVMXC__Field_Name__c) != null)
                                    {
                                        Sobject objRef = tech.getSobject(replacementRef.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                                        if(objRef!=NULL)
                                            str = Str +String.valueof(objRef.get(replacementNameField.get(lstHoverConfigData[j].SVMXC__Field_Name__c)));
                                    }
                                    else if(lstHoverConfigData[j].SVMXC__Display_Type__c != null && lstHoverConfigData[j].SVMXC__Display_Type__c.touppercase() != 'REFERENCE' && tech.get(lstHoverConfigData[j].SVMXC__Field_Name__c) != null)
                                    {
                                        str = str + String.valueof(tech.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                                    }
                                    lstHover.add(str);
                                }   
                            }
                        }
                        system.debug('TEST EACH tech. '+Technician_WP);
                        technician_LWP.add(Technician_WP);
                    }
                } 
            }
        }
        catch (DmlException ex){
            throw new SVMXException(ex.getDmlMessage(0));
        }catch (Exception ex){
            system.debug('printing in catch block'+ ex.getStacktracestring());
            throw new SVMXException(ex.getmessage());
        }
        return technician_LWP;
    }

    //This method provides list of Territories for building the Territory Tree
    WebService static List<SVMXC__Territory__c> DCON_Retrieve_Territory_Tree_WS(String UserId, Boolean RetrieveAllRecords)
    {
        RetrieveAllRecords = false;
        List<SVMXC__Dispatcher_Access__c> AvailTrr = new List<SVMXC__Dispatcher_Access__c>();
        List<SVMXC__Territory__c> TerritoryList = new List<SVMXC__Territory__c>();
        set<String> AvailTrrId = new set<String>();
        String QueryStr = 'Select SVMXC__Territory__c From SVMXC__Dispatcher_Access__c';
        
        if(RetrieveAllRecords==false)
            QueryStr += ' where SVMXC__Dispatcher__c =: UserId';
        
        try
        {
            AvailTrr = Database.query(QueryStr);
            if(AvailTrr.size() == 0){
                for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Territory__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true]){
                    AvailTrrId.add(tech.SVMXC__Service_Territory__c);
                }
            }
            else{
                for(SVMXC__Dispatcher_Access__c at: AvailTrr){
                    if(at.SVMXC__Territory__c != NULL)
                        AvailTrrId.add(at.SVMXC__Territory__c);
                }
            }
        }
        catch (DmlException ex){
            throw new SVMXException(ex.getDmlMessage(0));
        }catch (Exception ex){
            system.debug('printing in catch block'+ ex.getStacktracestring());
            throw new SVMXException(ex.getmessage());
        }
        TerritoryList = [Select Id, Name, SVMXC__Parent_Territory__c, SVMXC__Active__c From SVMXC__Territory__c where Id IN :AvailTrrId];

        for(SVMXC__Territory__c tt: TerritoryList){
            if(AvailTrrId.contains(tt.SVMXC__Parent_Territory__c) == false)
                tt.SVMXC__Parent_Territory__c = NULL;
        }
        system.debug('TST TERRITORY:'+AvailTrrId+TerritoryList);
        return TerritoryList;
    }
    
   /**
    * DNS #1043
    * If technician working hours is not associated with any of active BusinessHours, we will take technician's territory active BusinessHours.If technician's territory doesnot have active BusinessHours, we will take default businessHours.
    * Method Name:  DCON_Retrieve_Tech_WorkingHrs_WS
    * Description:  To display technician working hours, break hours and holidays on DC gantt.
    * Parameters:   lsttechId       List<String>    List of technicians send by Client
                    startdate       Date            Start date of gantt
                    enddate         Date            End date of gantt
    * Return:       Tech_WorkingHours
    */
    WebService static Tech_WorkingHours DCON_Retrieve_Tech_WorkingHrs_WS(List<String> lsttechId, String startdate, String enddate)
    {
        COMM_Utils_ManageSettings commUtils = new COMM_Utils_ManageSettings();
        Map<String, String> svmxSetting = new Map<String, String> ();
        svmxSetting = commUtils.SVMX_getSettingList('DCON001','SET001');
        List<tech_business_break_hrs> lsttechhrs = new List<tech_business_break_hrs>();
        List<BusinessHours> lstbusinesshrs = new List<BusinessHours>();
        //List<BusinessHours> lstbreakhrs = new List<BusinessHours>();
        List<Businesshrs_Holidays> lstHolidays = new List<Businesshrs_Holidays>();  
        System.debug('lsttechId: '+lsttechId);
        System.debug('startdate:' + startdate);
        System.debug('endate:' + enddate);
        Date DstartDate;
        Date DendDate;
                
        try
        {
            If (String.isBlank(startDate))
                DstartDate = System.today();
            else
                DstartDate = Date.valueOf(startdate);   
            If (String.isBlank(enddate))
                DendDate = Dstartdate.addDays(integer.valueOf(svmxSetting.get('SET001')) - 1);
            else
                DendDate = Date.valueOf(endDate);   
                
            If (lsttechId.size() > 0 && lsttechId != NULL)
            {
                Set<String> tech_t = new Set<string>(); 
                set<String> techlst = new set<String>();
                set<String> tech_businesshr_Ids = new set<String>();
                //set<String> tech_breakhr_Ids = new set<String>();
                techlst.addAll(lsttechId);
                for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Territory__c, SVMXC__Working_Hours__c, SVMXC__Break_Hours__c From SVMXC__Service_Group_Members__c where Id IN : techlst])
                {
                    If(tech.SVMXC__Service_Territory__c != null)              
                        tech_t.add(tech.SVMXC__Service_Territory__c);
                    If(tech.SVMXC__Working_Hours__c != null)  
                        tech_businesshr_Ids.add(tech.SVMXC__Working_Hours__c);
                    /*If(tech.SVMXC__Break_Hours__c != null)    
                        tech_breakhr_Ids.add(tech.SVMXC__Break_Hours__c);*/
                    
                }
                
                System.debug('tech_t:' + tech_t);
                System.debug('tech_businesshr_Ids' + tech_businesshr_Ids);
                //System.debug('tech_breakhr_Ids' + tech_breakhr_Ids);
            
                Map<Id,Id> territory_businesshrs = new Map<Id,Id>();
                Map<Id,SVMXC__Territory__c> techTerritory = new Map<Id,SVMXC__Territory__c>();
                //retrieving territory details of technicians if technicians don't have active working hours
                for(SVMXC__Territory__c lstterritory : Database.Query('Select SVMXC__Territory_s_Business_Hours__c,SVMXC__Territory_s_Business_Hours__r.IsActive, Id From SVMXC__Territory__c where Id IN :tech_t and SVMXC__Territory_s_Business_Hours__r.IsActive = true')) 
                {
                    If(lstterritory.SVMXC__Territory_s_Business_Hours__c != null)
                    {
                        tech_businesshr_Ids.add(lstterritory.SVMXC__Territory_s_Business_Hours__c);   
                    }
                    territory_businesshrs.put(lstterritory.Id,lstterritory.SVMXC__Territory_s_Business_Hours__c);
                }
                tech_t.clear();
                System.debug('tech_businesshr_Ids after territory' + tech_businesshr_Ids);
                     
                Set<Id> active_Businesshrs = new Set<Id>(); 
                //Set<Id> active_Breakhrs = new Set<Id>();
                for(BusinessHours lstbh :Database.Query('SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime,TimeZoneSidKey from BusinessHours where Id IN : tech_businesshr_Ids and IsActive = true')) 
                {
                    lstbusinesshrs.add(lstbh);
                    active_Businesshrs.add(lstbh.Id);
                    lstHolidays.add(new Businesshrs_Holidays(String.valueOf(lstbh.Id),GetHolidays(lstbh, DstartDate, DendDate), lstbh.TimeZoneSidKey));
                }
                tech_businesshr_Ids.clear();
                System.debug('active_Businesshrs:' + active_Businesshrs);
                System.debug('Heap size5: ' + Limits.getHeapSize());        
                
                //retrieving default businesshour if techinician and technician territory doesn't have active working hours.
                BusinessHours default_businesshr = [SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime,TimeZoneSidKey from BusinessHours where IsDefault = true and IsActive = true];
                System.debug('Boolean status:' + active_Businesshrs.contains(default_businesshr.Id));
                If(!active_Businesshrs.contains(default_businesshr.Id))
                {
                    lstbusinesshrs.add(default_businesshr);
                    lstHolidays.add(new Businesshrs_Holidays(String.valueOf(default_businesshr.Id),GetHolidays(default_businesshr, DstartDate, DendDate),default_businesshr.TimeZoneSidKey));   
                }
            
                System.debug('lstbusinesshrs:' + lstbusinesshrs);
                System.debug('lstHolidays:' + lstHolidays);
            
                /*for(BusinessHours lstbh :Database.Query('SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime,TimeZoneSidKey from BusinessHours where Id IN : tech_breakhr_Ids and IsActive = true')) 
                {
                    active_Breakhrs.add(lstbh.Id);
                    lstbreakhrs.add(lstbh);
                }
                System.debug('active_Breakhrs:' + active_Breakhrs);
                tech_breakhr_Ids.clear(); */
                    
                String temp_Businesshr_ID;
                //String temp_break_ID;
                //loop to retrieve each technician with technician Id, workinghours Id, breakhours Id.
                for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Territory__c, SVMXC__Working_Hours__c, SVMXC__Break_Hours__c From SVMXC__Service_Group_Members__c where Id IN : techlst])
                {
                    
                    if(tech.SVMXC__Working_Hours__c!=null && active_Businesshrs.contains(tech.SVMXC__Working_Hours__c))
                    {
                        temp_Businesshr_ID = String.valueOf(tech.SVMXC__Working_Hours__c);
                    }
                    else if(tech.SVMXC__Service_Territory__c!=null && territory_businesshrs.containsKey(tech.SVMXC__Service_Territory__c) && territory_businesshrs.get(tech.SVMXC__Service_Territory__c)!=null) 
                    {
                        temp_Businesshr_ID = String.valueOf(territory_businesshrs.get(tech.SVMXC__Service_Territory__c));
                    }
                    else
                    {
                        temp_Businesshr_ID = String.valueOf(default_businesshr.Id);
                    }
                    /*
                    if(tech.SVMXC__Break_Hours__c!=null && active_Breakhrs.contains(tech.SVMXC__Break_Hours__c))    
                    {
                        temp_break_ID = tech.SVMXC__Break_Hours__c;   
                    }
                    else
                    {
                        temp_break_ID = null;   
                    }
                    lsttechhrs.add(new tech_business_break_hrs(String.valueOf(tech.Id),temp_Businesshr_ID,temp_break_ID)); */
                    lsttechhrs.add(new tech_business_break_hrs(String.valueOf(tech.Id),temp_Businesshr_ID,null));
                }
                techlst.clear();
                territory_businesshrs.clear();
                //active_Breakhrs.clear();
                active_Businesshrs.clear();
                default_businesshr = null;
                System.debug('lsttechhrs: ' + lsttechhrs);  
            }       
        }
        catch (DmlException ex){
            throw new SVMXException(ex.getDmlMessage(0));
        }catch (Exception ex){
            system.debug('printing in catch block'+ ex.getStacktracestring());
            throw new SVMXException(ex.getmessage());
        }
        //System.debug('return value:' + new Tech_WorkingHours(lsttechhrs, lstbusinesshrs, lstbreakhrs, lstHolidays)); 
        System.debug('return value:' + new Tech_WorkingHours(lsttechhrs, lstbusinesshrs, null, lstHolidays));   
        System.debug('Heap size9: ' + Limits.getHeapSize());    
        //return  new Tech_WorkingHours(lsttechhrs, lstbusinesshrs, lstbreakhrs, lstHolidays);  
        return  new Tech_WorkingHours(lsttechhrs, lstbusinesshrs, null, lstHolidays);   
    }
    
   /**
    * DNS #1043
    * Method Name:  GetHolidays
    * Description:  To retrieve holidays between given startdate and enddate based on BusinessHours.
    * Parameters:   bh              BusinessHours   BusinessHours
                    startdate       Date            Start date of gantt
                    enddate         Date            End date of gantt
    * Return:       list<Date>
    */
    public static list<Date> GetHolidays(BusinessHours bh, Date startdate, Date enddate)
    {
        DCON_Utils dcUtils = new DCON_Utils();
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
    
   /**
    * Method Name : getnamespace
    * Description : This method is to know the current names space the technician tree is construted for 
                    it can be either 'Service Team View' or 'Territory View'
    * Parameters  : None
    * Return Type : string
    */
    public static string getnamespace()
    {
        //CRUD - removing semicolon before the static string since static string cannot be bind variable
        //ApexClass cs =[select NamespacePrefix from ApexClass where Name = :'DCON_Service_Org_WS'];
        String prefixString;
        ApexClass cs =[select NamespacePrefix from ApexClass where Name = 'DCON_Service_Org_WS'];
        System.debug('NamespacePrefix: '+cs.NamespacePrefix);       
        
        //CRUD
        if(cs != null)
        {
            if (!securityUtils.verifyFieldAccess(cs, COMM_SecurityUtils.Access.Accessible))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }           
            else
                {
                    prefixString = cs.NamespacePrefix;
                    return prefixString;
                }
        }   
            
        return '';
    }
    
   /**
    * Method Name : getTechFieldstoLoad
    * Description : This method is to get technican record fileds which have to be loaded instead of loading all fields
    * Parameters  : None
    * Return Type : set<string>
    */
    public static Set<String> getTechFieldstoLoad() {
        Set<String> techFldSet = null;
        /*COMM_Utils_ManageSettings commManageSetting = new COMM_Utils_ManageSettings();
        String settingValue = commManageSetting.SVMX_getGlobalSettingList('GBL044');
        Boolean flag = false;
        Set<String> techFldSet = null;
        if(!String.isBlank(settingValue)){
            flag = Boolean.valueOf(settingValue);
        }
        
        //if DCx is enabled
        if(flag)
            techFldSet = getTechFieldstoLoadDCx();
        else*/
            techFldSet = getTechFieldstoLoadClassic();
            
        return techFldSet;
    }
    
    private static Set<String> getTechFieldstoLoadDCx() {
        Set<String> setTechFields = new Set<String>();
        
        //1. Get he default tech fields to load
        setTechFields.addAll(getDefaultTechFieldstoLoad());
        
        //2. Get the configured tech fields from user settings
        DCX_CommonServiceManager.UserSetting userSettings = DCX_SettingServiceManager.fetchUserSettings();
        if(userSettings.tech_techCol != null && userSettings.tech_techCol.size() > 0) {
            for(DCX_CommonServiceManager.TechCol col : userSettings.tech_techCol)
                setTechFields.add(col.name);
        }
        
        return setTechFields;
    }
    
    private static Set<String> getTechFieldstoLoadClassic()
    {
        String userXML = '';
        Set<String> setTechFields = new Set<String>();
        User DispatcherRecord = [Select Id, SVMXC__Dispatch_Console_Settings__c from User where Id =:Userinfo.getUserId()];

        userXML = DispatcherRecord.SVMXC__Dispatch_Console_Settings__c;
        if(userXML == null || userXML.length() == 0)
            userXML = getDefaultUserSettings(); //update the method name
        
        Dom.Document doc = new Dom.Document();
        if(userXML != null && userXML.length() > 0)
            doc.load(userXML);
        else
            return setTechFields;

        Dom.Xmlnode rootElement = doc.getRootElement();
        
        /** 
        From the UI settings we can get number of columns configured in the current/default view
        the color coding rules, work order rules and keyword search fields - only these will be loaded when DC launches
        other fields will be loaded only on demand 
        */
        for(Dom.XMLNode firstChild : rootElement.getChildElements()) 
        {
            if(firstChild.getAttribute('id', null) == 'technicianSettings')
            {
                for(Dom.XMLNode secondChild : firstChild.getChildElements())
                {
                    if(secondChild.getName() == 'selectedcolumns')
                    {
                        for(Dom.XMLNode thirdChild : secondChild.getChildElements())
                        {
                            if(thirdChild.getName() == 'column')
                            {
                                setTechFields.add(thirdChild.getAttributeValue(thirdChild.getAttributeKeyAt(0), thirdChild.getAttributeKeyNsAt(0)));
                            }
                        }
                    }
                }
            }            
        }
        set<string> setDefaultTechFields = new set<string>();
        setDefaultTechFields = getDefaultTechFieldstoLoad();
        setTechFields.addAll(setDefaultTechFields);
        System.debug(logginglevel.warn,'setTechFields: '+setTechFields);
        return setTechFields;
    }
    
   public static Set<String> getDefaultTechFieldstoLoad()
    {
        Set<string> setDefaultTechFields = new set<string>();
                
        Set<string> setDefaultTechFieldLabels = new set<string>{'CreatedById', 'LastModifiedById','Name','SVMXC__Service_Group__c','SVMXC__Street__c','SVMXC__City__c','SVMXC__State__c','SVMXC__Country__c','SVMXC__Zip__c','SVMXC__Latitude__c','SVMXC__Longitude__c','SVMXC__Latitude_Home__c','SVMXC__Longitude_Home__c','SVMXC__Enable_Scheduling__c','SVMXC__Salesforce_User__c','SVMXC__Service_Territory__c'};
        
        
        Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap();
        map<String,String> mapAPINameLabel = new map<String,String>();
        
        //Loop it and create map of label and APIName for Map Hover
        if(souObjfieldMap.size() > 0)
        {
            for(String str : souObjfieldMap.keyset())
            {
                Schema.SObjectField fsObj = souObjfieldMap.get(str); 
                Schema.DescribeFieldResult field = fsObj.getDescribe();
                if(field.isAccessible())
                {                   
                    mapAPINameLabel.put(souObjfieldMap.get(str).getDescribe().getName(),souObjfieldMap.get(str).getDescribe().getName());
                }
            }
        }
        for(string str:setDefaultTechFieldLabels)
        {
            if(str != '' && str != null && mapAPINameLabel.containskey(str) && mapAPINameLabel.get(str) != null)
            setDefaultTechFields.add(mapAPINameLabel.get(str));
        }
        
        //The fields which have relationship are to be added as below (not all relationship fileds to be added, only the default required)
        if(mapAPINameLabel.containskey('SVMXC__Service_Group__c') && mapAPINameLabel.get('SVMXC__Service_Group__c') != null)
            setDefaultTechFields.add('SVMXC__Service_Group__r.Name');
        
        
        if(mapAPINameLabel.containskey('SVMXC__Service_Territory__c') && mapAPINameLabel.get('SVMXC__Service_Territory__c') != null)
            setDefaultTechFields.add('SVMXC__Service_Territory__r.Name');
    
        if(mapAPINameLabel.containskey('SVMXC__Salesforce_User__c') && mapAPINameLabel.get('SVMXC__Salesforce_User__c') != null)
            setDefaultTechFields.add('SVMXC__Salesforce_User__r.Name');
        
        System.debug(logginglevel.warn,'setDefaultTechFields: '+setDefaultTechFields);
        return setDefaultTechFields;
    }

   /**
    * Method Name : getDefaultUserSettings
    * Description : This method is to get the default UI settings
    * Parameters  : None
    * Return Type : string
    */
    public static string getDefaultUserSettings()
    {
        StaticResource sr = [Select  s.Name, s.Id, s.Body From StaticResource s where s.Name ='DCON_UI_Settings'];

        blob tempBlob = sr.Body;

        String tempString ='';
        tempString = tempBlob.toString();
        System.debug('tempString  '+tempString);

        if(tempString ==null)
           tempString ='';

        return tempString;
    }
    /***** START: Retrieve salesforce user details for technicians passed *****/
    global class getTechDetailsReq
    {
        WebService List<String> lstTechIds {get; set;}
         
        public getTechDetailsReq(List<String> lstTechIds)
        {
            this.lstTechIds = lstTechIds;
        }
        public getTechDetailsReq() {}
    }
    
    global class getTechDetailsResponse
    {
        WebService String TechId {get; set;}    
        Webservice User userRecord {get; set;}
        
        public getTechDetailsResponse(String TechId, User userRecord)
        {
            this.TechId = TechId;
            this.userRecord = userRecord;
        }
        public getTechDetailsResponse() {}
    }
    /**
    * Method Name:  getTechDetails
    * Description:  Retrieve firstname, lastname, shortphotoUrl fields of salesforce user the given technician Ids
    * Parameters:   getTechDetailsReq - a wrapper having technician ids
    * Return:       getTechDetailsResponse  
    */
    WebService static List<getTechDetailsResponse> getTechDetails(getTechDetailsReq req)
    {
        List<getTechDetailsResponse> response = new List<getTechDetailsResponse>();
        Map<String,String> TechUserIds = new Map<String,String>();
        Map<String,User> Userdetails = new Map<String,User>();
        if(req.lstTechIds != null && req.lstTechIds.size() > 0)
        {   
            List<SVMXC__Service_Group_Members__c> lstTechRecords = [SELECT Id, SVMXC__Salesforce_User__c FROM SVMXC__Service_Group_Members__c where Id IN :req.lstTechIds];
            Set<String> lstUserIds = new Set<String>();
            for(SVMXC__Service_Group_Members__c techRecord: lstTechRecords)
            {
                TechUserIds.put(techRecord.Id,techRecord.SVMXC__Salesforce_User__c);    
                lstUserIds.add(techRecord.SVMXC__Salesforce_User__c);
            }
            System.debug('TechUserIds:'+ TechUserIds);  
            List<User> userRecords = new List<User>();
            String selectQuery = 'SELECT Id,FirstName,LastName,SmallPhotoUrl FROM User where Id IN :lstUserIds';
            String selectQuery1 = 'SELECT Id,FirstName,LastName FROM User where Id IN :lstUserIds';
            if(ConnectApi.Organization.getSettings().features.chatter) 
            {
                userRecords = Database.Query(selectQuery);
            }
            else
            {
                userRecords = Database.Query(selectQuery1);
            }
            for(User userRecord: userRecords)
            {
                Userdetails.put(userRecord.Id, userRecord); 
            }
            for(SVMXC__Service_Group_Members__c techRecord: lstTechRecords)
            {   
                getTechDetailsResponse techSFRecord = new getTechDetailsResponse(techRecord.Id,Userdetails.get(techRecord.SVMXC__Salesforce_User__c));
                response.add(techSFRecord);
            }
        }
        return response;
    }
    /***** END: Retrieve technicain details for technicians passed *****/   
}